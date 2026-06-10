-- ═══════════════════════════════════════════════════════════════
-- ENUM DEFINITIONS
-- ═══════════════════════════════════════════════════════════════

-- Company enums
CREATE TYPE industry_category_enum AS ENUM (
  'apparel', 'beauty', 'food_beverage', 'health_wellness',
  'home', 'electronics', 'pets', 'sports', 'kids', 'other'
);

CREATE TYPE revenue_range_enum AS ENUM (
  'under_500k', '500k_1m', '1m_3m', '3m_5m', '5m_10m', '10m_20m', 'over_20m'
);

CREATE TYPE company_role_enum AS ENUM (
  'owner', 'admin', 'editor', 'viewer'
);

-- Integration enums
CREATE TYPE source_type_enum AS ENUM (
  'shopify', 'quickbooks', 'stripe', 'xero', 'amazon', 'woocommerce'
);

CREATE TYPE connection_status_enum AS ENUM (
  'pending', 'active', 'error', 'expired', 'disconnected'
);

CREATE TYPE sync_status_enum AS ENUM (
  'idle', 'syncing', 'complete', 'error'
);

CREATE TYPE sync_type_enum AS ENUM (
  'initial', 'incremental', 'manual'
);

CREATE TYPE sync_log_status_enum AS ENUM (
  'running', 'completed', 'failed', 'cancelled'
);

-- Transaction enums
CREATE TYPE transaction_type_enum AS ENUM (
  'sale', 'refund', 'expense', 'payout', 'transfer', 'adjustment'
);

-- Metric enums
CREATE TYPE metric_category_enum AS ENUM (
  'revenue', 'profitability', 'cash', 'efficiency', 'operations'
);

CREATE TYPE period_type_enum AS ENUM (
  'daily', 'weekly', 'monthly', 'quarterly', 'yearly'
);

CREATE TYPE trend_direction_enum AS ENUM (
  'up', 'down', 'flat'
);

-- Forecast enums
CREATE TYPE override_type_enum AS ENUM (
  'one_time_expense', 'one_time_revenue',
  'recurring_expense_change', 'recurring_revenue_change'
);

CREATE TYPE recurrence_freq_enum AS ENUM (
  'weekly', 'monthly'
);

-- Insight enums
CREATE TYPE insight_type_enum AS ENUM (
  'anomaly', 'trend', 'benchmark', 'predictive', 'opportunity'
);

CREATE TYPE insight_confidence_enum AS ENUM (
  'high', 'medium'
);

CREATE TYPE insight_feedback_enum AS ENUM (
  'helpful', 'not_helpful'
);

-- Report enums
CREATE TYPE report_type_enum AS ENUM (
  'monthly_snapshot', 'custom_range', 'investor_deck', 'board_pack'
);

CREATE TYPE report_status_enum AS ENUM (
  'pending', 'generating', 'completed', 'failed'
);

CREATE TYPE report_generation_type_enum AS ENUM (
  'manual', 'scheduled', 'auto_monthly'
);

-- Billing enums
CREATE TYPE plan_id_enum AS ENUM (
  'starter', 'growth', 'scale'
);

CREATE TYPE billing_interval_enum AS ENUM (
  'monthly', 'annual'
);

CREATE TYPE subscription_status_enum AS ENUM (
  'trialing', 'active', 'past_due', 'canceled', 'unpaid', 'incomplete'
);

-- Free tools enums
CREATE TYPE free_tool_enum AS ENUM (
  'benchmark_checker', 'cash_runway', 'kpi_scorecard'
);

CREATE TABLE profiles (
  -- Primary key matches auth.users.id
  id                UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Profile data
  full_name         TEXT NOT NULL DEFAULT '',
  avatar_url        TEXT,

  -- Preferences
  date_format       TEXT NOT NULL DEFAULT 'MM/DD/YYYY'
                    CHECK (date_format IN ('MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD')),
  number_format     TEXT NOT NULL DEFAULT 'en-US'
                    CHECK (number_format IN ('en-US', 'de-DE', 'fr-FR')),
  theme             TEXT NOT NULL DEFAULT 'system'
                    CHECK (theme IN ('light', 'dark', 'system')),
  email_digest      BOOLEAN NOT NULL DEFAULT TRUE,
  digest_day        SMALLINT NOT NULL DEFAULT 1
                    CHECK (digest_day BETWEEN 0 AND 6),  -- 0=Sun, 1=Mon, ..., 6=Sat

  -- Onboarding
  onboarding_step   SMALLINT NOT NULL DEFAULT 0
                    CHECK (onboarding_step BETWEEN 0 AND 3),
  onboarding_done   BOOLEAN NOT NULL DEFAULT FALSE,

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

COMMENT ON TABLE profiles IS 'User profile data extending Supabase auth.users';
COMMENT ON COLUMN profiles.digest_day IS '0=Sunday through 6=Saturday';
COMMENT ON COLUMN profiles.onboarding_step IS '0=not started, 1=company, 2=connect, 3=done';

CREATE TABLE companies (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id          UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Company info
  name              TEXT NOT NULL,
  industry_category industry_category_enum NOT NULL DEFAULT 'other',
  revenue_range     revenue_range_enum NOT NULL DEFAULT '1m_3m',
  employee_count    INTEGER NOT NULL DEFAULT 1
                    CHECK (employee_count >= 1),
  currency          TEXT NOT NULL DEFAULT 'USD'
                    CHECK (currency = 'USD'),  -- MVP: USD only
  fiscal_year_start SMALLINT NOT NULL DEFAULT 1
                    CHECK (fiscal_year_start BETWEEN 1 AND 12),
  logo_url          TEXT,
  website           TEXT,

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_companies_owner ON companies(owner_id);

COMMENT ON TABLE companies IS 'Customer companies — core entity for all financial data';

CREATE TABLE company_members (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  user_id           UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  role              company_role_enum NOT NULL DEFAULT 'viewer',

  -- Timestamps
  invited_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  accepted_at       TIMESTAMPTZ,

  UNIQUE(company_id, user_id)
);

CREATE INDEX idx_company_members_user ON company_members(user_id);
CREATE INDEX idx_company_members_company ON company_members(company_id);

COMMENT ON TABLE company_members IS 'Team members and advisors with access to a company';

CREATE TABLE connections (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Integration identity
  source_type       source_type_enum NOT NULL,
  external_id       TEXT,              -- e.g., Shopify shop domain, QBO realm_id
  display_name      TEXT,              -- Human-friendly name ("my-store.myshopify.com")

  -- OAuth tokens (encrypted at application level before storage)
  access_token      TEXT NOT NULL,     -- AES-256-GCM encrypted
  refresh_token     TEXT,              -- AES-256-GCM encrypted
  token_iv          TEXT NOT NULL,     -- Initialization vector
  token_auth_tag    TEXT NOT NULL,     -- GCM authentication tag
  token_expires_at  TIMESTAMPTZ,       -- When access token expires

  -- Sync state
  status            connection_status_enum NOT NULL DEFAULT 'pending',
  sync_status       sync_status_enum NOT NULL DEFAULT 'idle',
  sync_progress     SMALLINT DEFAULT 0
                    CHECK (sync_progress BETWEEN 0 AND 100),
  last_sync_at      TIMESTAMPTZ,
  last_sync_error   TEXT,
  data_start_date   DATE,              -- Earliest date of synced data
  data_end_date     DATE,              -- Latest date of synced data

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Each company can have only one connection per source type
  UNIQUE(company_id, source_type)
);

CREATE INDEX idx_connections_company ON connections(company_id);
CREATE INDEX idx_connections_status ON connections(status) WHERE status = 'active';

COMMENT ON TABLE connections IS 'OAuth connections to third-party data sources';
COMMENT ON COLUMN connections.access_token IS 'Encrypted with AES-256-GCM — never store plaintext';

CREATE TABLE sync_logs (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  connection_id     UUID NOT NULL REFERENCES connections(id) ON DELETE CASCADE,
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Sync details
  sync_type         sync_type_enum NOT NULL DEFAULT 'incremental',
  status            sync_log_status_enum NOT NULL DEFAULT 'running',
  records_fetched   INTEGER DEFAULT 0,
  records_created   INTEGER DEFAULT 0,
  records_updated   INTEGER DEFAULT 0,
  records_skipped   INTEGER DEFAULT 0,

  -- Error handling
  error_message     TEXT,
  error_code        TEXT,

  -- Timing
  started_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at      TIMESTAMPTZ,
  duration_ms       INTEGER GENERATED ALWAYS AS (
    EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000
  ) STORED
);

CREATE INDEX idx_sync_logs_connection ON sync_logs(connection_id, started_at DESC);
CREATE INDEX idx_sync_logs_company ON sync_logs(company_id, started_at DESC);

COMMENT ON TABLE sync_logs IS 'Audit log of all data sync operations';

CREATE TABLE raw_transactions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  connection_id     UUID NOT NULL REFERENCES connections(id) ON DELETE CASCADE,

  -- Source reference
  source_type       source_type_enum NOT NULL,
  external_id       TEXT NOT NULL,       -- Original ID from source system
  external_parent_id TEXT,               -- Parent reference (e.g., order_id for a refund)

  -- Normalized transaction data
  transaction_date  DATE NOT NULL,
  transaction_type  transaction_type_enum NOT NULL,
  category          TEXT,                -- e.g., "revenue", "cogs", "marketing", "shipping"
  subcategory       TEXT,                -- e.g., "paid_ads", "organic", "product_cost"
  description       TEXT,

  -- Amounts (always in company's currency)
  amount            DECIMAL(14,2) NOT NULL,  -- Positive = inflow, Negative = outflow
  quantity          INTEGER,                  -- For order-related transactions

  -- Metadata
  metadata          JSONB DEFAULT '{}',  -- Source-specific additional data
  is_reconciled     BOOLEAN NOT NULL DEFAULT FALSE,

  -- Deduplication
  dedup_key         TEXT NOT NULL,       -- Composite key for deduplication

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Prevent duplicate transactions
  UNIQUE(company_id, source_type, dedup_key)
);

CREATE INDEX idx_raw_transactions_company_date
  ON raw_transactions(company_id, transaction_date DESC);
CREATE INDEX idx_raw_transactions_company_type_date
  ON raw_transactions(company_id, transaction_type, transaction_date DESC);
CREATE INDEX idx_raw_transactions_category
  ON raw_transactions(company_id, category, transaction_date DESC);

COMMENT ON TABLE raw_transactions IS 'Normalized financial transactions from all sources';
COMMENT ON COLUMN raw_transactions.dedup_key IS 'Prevents duplicate ingestion. Format: {source}:{external_id}:{type}';

CREATE TABLE daily_financials (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  date              DATE NOT NULL,

  -- Revenue
  gross_revenue     DECIMAL(14,2) NOT NULL DEFAULT 0,
  discounts         DECIMAL(14,2) NOT NULL DEFAULT 0,
  refunds           DECIMAL(14,2) NOT NULL DEFAULT 0,
  net_revenue       DECIMAL(14,2) NOT NULL DEFAULT 0,  -- gross - discounts - refunds
  order_count       INTEGER NOT NULL DEFAULT 0,
  new_customer_count INTEGER NOT NULL DEFAULT 0,

  -- Cost & Expenses
  cogs              DECIMAL(14,2) NOT NULL DEFAULT 0,
  marketing_spend   DECIMAL(14,2) NOT NULL DEFAULT 0,
  shipping_cost     DECIMAL(14,2) NOT NULL DEFAULT 0,
  operating_expenses DECIMAL(14,2) NOT NULL DEFAULT 0,  -- All other opex
  total_expenses    DECIMAL(14,2) NOT NULL DEFAULT 0,

  -- Profitability
  gross_profit      DECIMAL(14,2) NOT NULL DEFAULT 0,   -- net_revenue - cogs
  net_income        DECIMAL(14,2) NOT NULL DEFAULT 0,   -- net_revenue - total_expenses

  -- Cash
  cash_inflow       DECIMAL(14,2) NOT NULL DEFAULT 0,
  cash_outflow      DECIMAL(14,2) NOT NULL DEFAULT 0,
  net_cash_flow     DECIMAL(14,2) NOT NULL DEFAULT 0,
  cash_balance      DECIMAL(14,2),                       -- End-of-day cash balance (from QBO)

  -- Operations
  refund_count      INTEGER NOT NULL DEFAULT 0,
  avg_order_value   DECIMAL(14,2) NOT NULL DEFAULT 0,

  -- Timestamps
  calculated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(company_id, date)
);

CREATE INDEX idx_daily_financials_company_date
  ON daily_financials(company_id, date DESC);

COMMENT ON TABLE daily_financials IS 'Daily aggregated financials — computed from raw_transactions';
COMMENT ON COLUMN daily_financials.cash_balance IS 'From QuickBooks balance sheet — may be NULL if QBO not connected';

CREATE TABLE metric_snapshots (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Metric identity
  metric_name       TEXT NOT NULL,       -- e.g., "gross_margin_pct", "cac", "ltv"
  metric_category   metric_category_enum NOT NULL,

  -- Time dimension
  period_date       DATE NOT NULL,       -- Start date of the period
  period_type       period_type_enum NOT NULL,  -- daily, weekly, monthly

  -- Value
  metric_value      DECIMAL(14,4) NOT NULL,
  metric_unit       TEXT NOT NULL DEFAULT 'number',  -- 'currency', 'percentage', 'ratio', 'months', 'number'

  -- Trend (vs. prior period)
  prior_value       DECIMAL(14,4),
  change_pct        DECIMAL(8,4),        -- Percentage change from prior
  trend_direction   trend_direction_enum, -- up, down, flat

  -- Metadata
  data_sources      TEXT[],              -- Which integrations contributed to this metric
  metadata          JSONB DEFAULT '{}',

  -- Timestamps
  calculated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(company_id, metric_name, period_date, period_type)
);

CREATE INDEX idx_metric_snapshots_dashboard
  ON metric_snapshots(company_id, period_date DESC, period_type);
CREATE INDEX idx_metric_snapshots_single_metric
  ON metric_snapshots(company_id, metric_name, period_date DESC, period_type);

COMMENT ON TABLE metric_snapshots IS 'Computed KPI values — the main data source for the dashboard';

CREATE TABLE industry_benchmarks (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Segmentation
  industry_category industry_category_enum NOT NULL,
  revenue_range     revenue_range_enum NOT NULL,

  -- Benchmark data
  metric_name       TEXT NOT NULL,
  p10               DECIMAL(14,4),       -- 10th percentile
  p25               DECIMAL(14,4) NOT NULL,  -- 25th percentile
  p50               DECIMAL(14,4) NOT NULL,  -- Median
  p75               DECIMAL(14,4) NOT NULL,  -- 75th percentile
  p90               DECIMAL(14,4),       -- 90th percentile
  sample_size       INTEGER,             -- Number of companies in sample
  metric_unit       TEXT NOT NULL DEFAULT 'number',

  -- Source
  data_source       TEXT NOT NULL,       -- e.g., "NYU Stern 2025", "Internal Aggregation"
  effective_date    DATE NOT NULL,       -- When this benchmark was published
  expires_at        DATE,                -- When it should be refreshed

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(industry_category, revenue_range, metric_name, effective_date)
);

CREATE INDEX idx_benchmarks_lookup
  ON industry_benchmarks(industry_category, revenue_range, metric_name);

COMMENT ON TABLE industry_benchmarks IS 'Industry benchmark reference data — seeded from curated datasets';

CREATE TABLE forecasts (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Forecast identity
  forecast_date     DATE NOT NULL,       -- Date the forecast was generated
  week_start        DATE NOT NULL,       -- Start of the forecast week

  -- Projections
  base_case         DECIMAL(14,2) NOT NULL,
  best_case         DECIMAL(14,2) NOT NULL,
  worst_case        DECIMAL(14,2) NOT NULL,

  -- Confidence interval (80%)
  confidence_lower  DECIMAL(14,2) NOT NULL,
  confidence_upper  DECIMAL(14,2) NOT NULL,

  -- Actual (filled in after the week passes)
  actual_value      DECIMAL(14,2),

  -- Model metadata
  model_version     TEXT NOT NULL DEFAULT 'v1',
  model_inputs      JSONB DEFAULT '{}',

  -- Timestamps
  generated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(company_id, forecast_date, week_start)
);

CREATE INDEX idx_forecasts_company_latest
  ON forecasts(company_id, forecast_date DESC, week_start);

COMMENT ON TABLE forecasts IS 'Weekly cash flow forecast projections — 13 rows per forecast run';

CREATE TABLE forecast_overrides (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Override details
  event_name        TEXT NOT NULL,
  override_type     override_type_enum NOT NULL,
  amount            DECIMAL(14,2) NOT NULL,  -- Positive = inflow, Negative = outflow
  event_date        DATE NOT NULL,

  -- Recurrence (optional)
  is_recurring      BOOLEAN NOT NULL DEFAULT FALSE,
  recurrence_freq   recurrence_freq_enum,
  recurrence_end    DATE,

  -- State
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_forecast_overrides_company
  ON forecast_overrides(company_id) WHERE is_active = TRUE;

COMMENT ON TABLE forecast_overrides IS 'Manual forecast adjustments — planned expenses/revenue';

CREATE TABLE insights (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Insight content
  insight_type      insight_type_enum NOT NULL,
  title             TEXT NOT NULL,
  body              TEXT NOT NULL,
  action_text       TEXT,                -- Recommended action

  -- Reference
  primary_metric    TEXT,                -- KPI this insight relates to
  metric_value      DECIMAL(14,4),       -- The specific value referenced
  confidence        insight_confidence_enum NOT NULL DEFAULT 'medium',

  -- State
  is_dismissed      BOOLEAN NOT NULL DEFAULT FALSE,
  dismissed_at      TIMESTAMPTZ,
  is_read           BOOLEAN NOT NULL DEFAULT FALSE,
  read_at           TIMESTAMPTZ,

  -- Feedback
  feedback          insight_feedback_enum,  -- helpful, not_helpful, NULL
  feedback_at       TIMESTAMPTZ,

  -- Delivery
  included_in_digest BOOLEAN NOT NULL DEFAULT FALSE,
  digest_sent_at    TIMESTAMPTZ,

  -- AI metadata
  model_used        TEXT NOT NULL DEFAULT 'claude-sonnet-4-20250514',
  prompt_version    TEXT NOT NULL DEFAULT 'v1',
  raw_response      JSONB,               -- Full AI response for debugging

  -- Deduplication
  content_hash      TEXT NOT NULL,        -- Hash of title+body to prevent exact duplicates

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),

  UNIQUE(company_id, content_hash)
);

CREATE INDEX idx_insights_company_feed
  ON insights(company_id, created_at DESC)
  WHERE NOT is_dismissed;
CREATE INDEX idx_insights_digest
  ON insights(company_id, created_at DESC)
  WHERE NOT included_in_digest;

COMMENT ON TABLE insights IS 'AI-generated financial insights and recommendations';

CREATE TABLE reports (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Report identity
  report_type       report_type_enum NOT NULL,
  report_name       TEXT NOT NULL,       -- Generated: "May 2026 Financial Snapshot"

  -- Date range
  range_start       DATE NOT NULL,
  range_end         DATE NOT NULL,

  -- Options
  include_benchmarks BOOLEAN NOT NULL DEFAULT TRUE,
  include_forecast  BOOLEAN NOT NULL DEFAULT TRUE,
  include_insights  BOOLEAN NOT NULL DEFAULT TRUE,

  -- File
  file_path         TEXT,                -- Supabase Storage path
  file_url          TEXT,                -- Signed URL (regenerated on access)
  file_size_bytes   INTEGER,
  file_format       TEXT NOT NULL DEFAULT 'pdf',

  -- Generation
  status            report_status_enum NOT NULL DEFAULT 'pending',
  generation_type   report_generation_type_enum NOT NULL DEFAULT 'manual',
  error_message     TEXT,

  -- Timestamps
  generated_at      TIMESTAMPTZ,
  expires_at        TIMESTAMPTZ,         -- URL expiration
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_reports_company ON reports(company_id, created_at DESC);

COMMENT ON TABLE reports IS 'Generated financial reports — files stored in Supabase Storage';

CREATE TABLE subscriptions (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE UNIQUE,

  -- Stripe references
  stripe_customer_id   TEXT NOT NULL UNIQUE,
  stripe_subscription_id TEXT UNIQUE,

  -- Plan
  plan_id           plan_id_enum NOT NULL DEFAULT 'starter',
  billing_interval  billing_interval_enum NOT NULL DEFAULT 'monthly',

  -- Status
  status            subscription_status_enum NOT NULL DEFAULT 'trialing',

  -- Dates
  trial_start       TIMESTAMPTZ,
  trial_end         TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end   TIMESTAMPTZ,
  canceled_at       TIMESTAMPTZ,

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_subscriptions_stripe_customer
  ON subscriptions(stripe_customer_id);
CREATE INDEX idx_subscriptions_status
  ON subscriptions(status);

COMMENT ON TABLE subscriptions IS 'Stripe subscription state — synced via webhooks';

CREATE TABLE billing_events (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id        UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,

  -- Stripe event
  stripe_event_id   TEXT NOT NULL UNIQUE,
  event_type        TEXT NOT NULL,        -- e.g., "invoice.paid", "customer.subscription.updated"
  event_data        JSONB NOT NULL,       -- Full event payload

  -- Quick access fields
  amount            DECIMAL(14,2),
  currency          TEXT DEFAULT 'usd',
  invoice_url       TEXT,

  -- Timestamps
  event_created_at  TIMESTAMPTZ NOT NULL,
  processed_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_billing_events_company ON billing_events(company_id, event_created_at DESC);

COMMENT ON TABLE billing_events IS 'Stripe webhook event audit log';

CREATE TABLE leads (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Lead info
  email             TEXT NOT NULL,
  company_name      TEXT,

  -- Source
  tool_used         free_tool_enum NOT NULL,
  utm_source        TEXT,
  utm_medium        TEXT,
  utm_campaign      TEXT,

  -- Tool results (stored for follow-up personalization)
  input_data        JSONB NOT NULL DEFAULT '{}',  -- What they entered
  results           JSONB NOT NULL DEFAULT '{}',  -- What we showed them

  -- Conversion tracking
  signed_up         BOOLEAN NOT NULL DEFAULT FALSE,
  signed_up_at      TIMESTAMPTZ,
  opted_in_email    BOOLEAN NOT NULL DEFAULT FALSE,

  -- Timestamps
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_leads_email ON leads(email);
CREATE INDEX idx_leads_conversion ON leads(signed_up, created_at DESC);

COMMENT ON TABLE leads IS 'Free tool leads for PLG funnel';

-- ═══════════════════════════════════════════════════════════════
-- ROW-LEVEL SECURITY (RLS)
-- ═══════════════════════════════════════════════════════════════

-- Helper: Get all company IDs the current user has access to
CREATE OR REPLACE FUNCTION get_user_company_ids()
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT id FROM companies WHERE owner_id = auth.uid()
  UNION
  SELECT company_id FROM company_members WHERE user_id = auth.uid() AND accepted_at IS NOT NULL
$$;

-- Helper: Check if user owns a specific company
CREATE OR REPLACE FUNCTION user_owns_company(target_company_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM companies WHERE id = target_company_id AND owner_id = auth.uid()
  )
$$;

-- ─── profiles ───
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON profiles FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (id = auth.uid());

-- ─── companies ───
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own companies"
  ON companies FOR SELECT
  USING (id IN (SELECT get_user_company_ids()));

CREATE POLICY "Users can create companies"
  ON companies FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "Owners can update companies"
  ON companies FOR UPDATE
  USING (owner_id = auth.uid());

CREATE POLICY "Owners can delete companies"
  ON companies FOR DELETE
  USING (owner_id = auth.uid());

-- ─── connections ───
ALTER TABLE connections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own company connections"
  ON connections FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

CREATE POLICY "Owners can manage connections"
  ON connections FOR ALL
  USING (user_owns_company(company_id));

-- ─── sync_logs ───
ALTER TABLE sync_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own sync logs"
  ON sync_logs FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── raw_transactions ───
ALTER TABLE raw_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own transactions"
  ON raw_transactions FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── daily_financials ───
ALTER TABLE daily_financials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own daily financials"
  ON daily_financials FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── metric_snapshots ───
ALTER TABLE metric_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own metrics"
  ON metric_snapshots FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── industry_benchmarks ───
ALTER TABLE industry_benchmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Benchmarks are readable by all authenticated users"
  ON industry_benchmarks FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- ─── forecasts ───
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own forecasts"
  ON forecasts FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── forecast_overrides ───
ALTER TABLE forecast_overrides ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own overrides"
  ON forecast_overrides FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

CREATE POLICY "Owners can manage overrides"
  ON forecast_overrides FOR ALL
  USING (user_owns_company(company_id));

-- ─── insights ───
ALTER TABLE insights ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own insights"
  ON insights FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

CREATE POLICY "Users can update own insights"
  ON insights FOR UPDATE
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── reports ───
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own reports"
  ON reports FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

CREATE POLICY "Owners can manage reports"
  ON reports FOR ALL
  USING (user_owns_company(company_id));

-- ─── subscriptions ───
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own subscription"
  ON subscriptions FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

-- ─── billing_events ───
ALTER TABLE billing_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Owners can view billing events"
  ON billing_events FOR SELECT
  USING (user_owns_company(company_id));

-- ─── leads ───
-- Leads table does NOT have RLS — it's accessed via service role only
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
-- No user-facing policies — only service role can read/write

-- ═══════════════════════════════════════════════════════════════
-- PERFORMANCE INDEXES
-- ═══════════════════════════════════════════════════════════════

-- Most critical path: Dashboard loading KPI data
-- Query: SELECT * FROM metric_snapshots WHERE company_id = $1 AND period_type = $2 AND period_date BETWEEN $3 AND $4
CREATE INDEX IF NOT EXISTS idx_metric_snapshots_dashboard_query
  ON metric_snapshots(company_id, period_type, period_date DESC);

-- Forecast loading: Latest forecast for a company
-- Query: SELECT * FROM forecasts WHERE company_id = $1 AND forecast_date = (SELECT MAX(forecast_date) FROM forecasts WHERE company_id = $1)
CREATE INDEX IF NOT EXISTS idx_forecasts_latest
  ON forecasts(company_id, forecast_date DESC);

-- Insight feed: Active insights for dashboard
-- Query: SELECT * FROM insights WHERE company_id = $1 AND NOT is_dismissed ORDER BY created_at DESC LIMIT 5
CREATE INDEX IF NOT EXISTS idx_insights_active_feed
  ON insights(company_id, created_at DESC)
  WHERE NOT is_dismissed;

-- Daily financials aggregation
CREATE INDEX IF NOT EXISTS idx_daily_financials_aggregation
  ON daily_financials(company_id, date DESC);

-- Transaction queries for KPI calculation
CREATE INDEX IF NOT EXISTS idx_raw_transactions_kpi_calc
  ON raw_transactions(company_id, transaction_type, transaction_date DESC);

-- Active connections for sync scheduler
CREATE INDEX IF NOT EXISTS idx_connections_active_sync
  ON connections(status, last_sync_at)
  WHERE status = 'active';

-- ═══════════════════════════════════════════════════════════════
-- FUNCTIONS & TRIGGERS
-- ═══════════════════════════════════════════════════════════════

-- ─── Auto-update updated_at timestamp ───
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Apply to all tables with updated_at
CREATE TRIGGER set_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON companies
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON connections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON forecast_overrides
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON industry_benchmarks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();


-- ─── Auto-create profile on user signup ───
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO profiles (id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', '')
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();


-- ─── Auto-create subscription on company creation ───
CREATE OR REPLACE FUNCTION handle_new_company()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO subscriptions (company_id, stripe_customer_id, status, trial_start, trial_end)
  VALUES (
    NEW.id,
    'pending_' || NEW.id,  -- Temporary ID until Stripe Customer is created
    'trialing',
    now(),
    now() + INTERVAL '14 days'
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_company_created
  AFTER INSERT ON companies
  FOR EACH ROW EXECUTE FUNCTION handle_new_company();


-- ─── Calculate sync duration ───
-- (duration_ms is a GENERATED column — no trigger needed)


-- ─── Notify on connection status change (for Realtime) ───
-- Supabase Realtime automatically picks up changes on tables with RLS enabled.
-- No additional trigger needed — the frontend subscribes to postgres_changes.

-- ═══════════════════════════════════════════════════════════════
-- SEED: Industry Benchmarks
-- Source: NYU Stern (Damodaran), Shopify Commerce Reports, 
--         SBA Industry Standards, DTC benchmark surveys
-- ═══════════════════════════════════════════════════════════════

-- Gross Margin % — Beauty
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty', '1m_3m',   'gross_margin_pct', 55.0, 62.0, 70.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('beauty', '3m_5m',   'gross_margin_pct', 58.0, 65.0, 72.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('beauty', '5m_10m',  'gross_margin_pct', 60.0, 67.0, 74.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('beauty', '10m_20m', 'gross_margin_pct', 62.0, 68.0, 75.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01');

-- Gross Margin % — Apparel
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('apparel', '1m_3m',   'gross_margin_pct', 45.0, 52.0, 60.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel', '3m_5m',   'gross_margin_pct', 48.0, 55.0, 62.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel', '5m_10m',  'gross_margin_pct', 50.0, 57.0, 64.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel', '10m_20m', 'gross_margin_pct', 52.0, 58.0, 65.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01');

-- Gross Margin % — Food & Beverage
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('food_beverage', '1m_3m',   'gross_margin_pct', 30.0, 38.0, 48.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '3m_5m',   'gross_margin_pct', 33.0, 40.0, 50.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '5m_10m',  'gross_margin_pct', 35.0, 42.0, 52.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '10m_20m', 'gross_margin_pct', 38.0, 45.0, 54.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01');

-- CAC — All categories (USD)
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'cac', 18.0, 35.0, 65.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'cac', 25.0, 45.0, 80.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'cac', 15.0, 28.0, 50.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','cac', 22.0, 42.0, 75.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01');

-- LTV:CAC Ratio
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'ltv_cac_ratio', 1.8, 3.0, 5.2, 'ratio', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'ltv_cac_ratio', 1.5, 2.5, 4.0, 'ratio', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'ltv_cac_ratio', 2.0, 3.5, 6.0, 'ratio', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','ltv_cac_ratio', 1.6, 2.8, 4.5, 'ratio', 'Compiled Industry Data 2025', '2025-01-01');

-- AOV
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'aov', 35.0, 55.0, 85.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'aov', 50.0, 80.0, 130.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'aov', 25.0, 42.0, 65.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','aov', 40.0, 65.0, 100.0, 'currency', 'Compiled Industry Data 2025', '2025-01-01');

-- Net Margin %
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'net_margin_pct', 2.0, 8.0, 15.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'net_margin_pct', 1.0, 5.0, 12.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'net_margin_pct', 0.5, 4.0, 10.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','net_margin_pct', 3.0, 9.0, 16.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01');

-- Revenue Growth Rate (MoM %)
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'mom_growth_rate', 2.0, 5.0, 12.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'mom_growth_rate', 1.5, 4.0, 10.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'mom_growth_rate', 2.5, 6.0, 14.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','mom_growth_rate', 2.0, 5.0, 11.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01');

-- Refund Rate (%)
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'refund_rate', 1.0, 3.0, 6.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'refund_rate', 5.0, 10.0, 18.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'refund_rate', 0.5, 2.0, 4.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','refund_rate', 2.0, 5.0, 9.0, 'percentage', 'Compiled Industry Data 2025', '2025-01-01');

-- Burn Rate (monthly, USD)
INSERT INTO industry_benchmarks (industry_category, revenue_range, metric_name, p25, p50, p75, metric_unit, data_source, effective_date) VALUES
('beauty',        '1m_3m', 'burn_rate', 8000, 20000, 45000, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('apparel',       '1m_3m', 'burn_rate', 10000, 25000, 55000, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('food_beverage', '1m_3m', 'burn_rate', 12000, 30000, 60000, 'currency', 'Compiled Industry Data 2025', '2025-01-01'),
('health_wellness','1m_3m','burn_rate', 9000, 22000, 48000, 'currency', 'Compiled Industry Data 2025', '2025-01-01');