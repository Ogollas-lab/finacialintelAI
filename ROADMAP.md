# FinancialIntelAI — Product Roadmap

> **Timeline:** June 2026 – June 2027 (12 months)
> **Version:** 1.0
> **Date:** June 7, 2026
> **Methodology:** 6-week cycles (Shape Up inspired)

---

## Table of Contents

1. [Roadmap Overview](#1-roadmap-overview)
2. [Phase 0: Foundation Sprint (Weeks 1–3)](#2-phase-0-foundation-sprint-weeks-1-3)
3. [Phase 1: MVP Launch (Weeks 4–6)](#3-phase-1-mvp-launch-weeks-4-6)
4. [Phase 2: Product-Market Fit (Weeks 7–18)](#4-phase-2-product-market-fit-weeks-7-18)
5. [Phase 3: Growth Engine (Weeks 19–30)](#5-phase-3-growth-engine-weeks-19-30)
6. [Phase 4: Scale & Expand (Weeks 31–52)](#6-phase-4-scale--expand-weeks-31-52)
7. [Feature Prioritization Matrix](#7-feature-prioritization-matrix)
8. [Technical Debt & Infrastructure Roadmap](#8-technical-debt--infrastructure-roadmap)
9. [Key Milestones & KPIs](#9-key-milestones--kpis)
10. [Risk Register](#10-risk-register)

---

## 1. Roadmap Overview

### Visual Timeline

```
  Jun 2026            Sep 2026            Dec 2026            Mar 2027            Jun 2027
    │                   │                   │                   │                   │
    ▼                   ▼                   ▼                   ▼                   ▼
    ┌───────────────────┬───────────────────┬───────────────────┬───────────────────┐
    │  PHASE 0 + 1      │    PHASE 2        │    PHASE 3        │    PHASE 4        │
    │  Foundation + MVP  │    PMF            │    Growth         │    Scale          │
    │                   │                   │                   │                   │
    │  Weeks 1-6        │    Weeks 7-18     │    Weeks 19-30    │    Weeks 31-52    │
    │                   │                   │                   │                   │
    │  • Core infra     │    • Iterate on   │    • Revenue      │    • New verticals│
    │  • 3 integrations │      feedback     │      forecasting  │    • API platform │
    │  • Dashboard      │    • 2 new integ. │    • Team features│    • White-label  │
    │  • Forecasting    │    • AI insights  │    • Investor pack│    • Mobile app   │
    │  • Benchmarks     │      v2           │    • Paid growth  │    • Marketplace  │
    │  • Beta launch    │    • Onboarding   │    • Partnerships │                   │
    │                   │      optimization │                   │                   │
    │  50 beta users    │    300 users      │    1,000 users    │    3,000+ users   │
    │  5 paying         │    80 paying      │    400 paying     │    1,000+ paying  │
    │  $500 MRR         │    $10K MRR       │    $60K MRR       │    $150K+ MRR     │
    └───────────────────┴───────────────────┴───────────────────┴───────────────────┘
```

### Cycle Structure

Each 6-week cycle consists of:
- **Week 1:** Shape & plan — define scope, write specs, design
- **Week 2–5:** Build — engineering sprints
- **Week 6:** Cool-down — bug fixes, polish, deploy, retrospective

---

## 2. Phase 0: Foundation Sprint (Weeks 1–3)

> **Goal:** Ship the technical foundation. Nothing user-facing yet.
> **Team:** 2 engineers

### Week 1: Project Setup & Infrastructure

| Day | Task | Owner | Status |
|---|---|---|---|
| 1 | Initialize Next.js 15 project with TypeScript + Tailwind v4 + Biome | Eng 1 | ⬜ |
| 1 | Set up Supabase project (Postgres, Auth, Storage, Edge Functions) | Eng 2 | ⬜ |
| 1 | Configure Vercel deployment (preview + production environments) | Eng 1 | ⬜ |
| 2 | Install and configure shadcn/ui component library | Eng 1 | ⬜ |
| 2 | Create complete database schema (all 15 tables, enums, RLS) | Eng 2 | ⬜ |
| 2 | Run migrations, generate TypeScript types | Eng 2 | ⬜ |
| 3 | Set up Supabase Auth (email/password, Google OAuth, magic link) | Eng 2 | ⬜ |
| 3 | Build authentication middleware + protected route layout | Eng 1 | ⬜ |
| 3 | Configure Stripe Billing (3 products, 6 prices, webhook endpoint) | Eng 2 | ⬜ |
| 4 | Build signup/login/forgot-password pages | Eng 1 | ⬜ |
| 4 | Implement Stripe customer creation on signup + trial activation | Eng 2 | ⬜ |
| 5 | Set up CI/CD pipeline (GitHub Actions: lint, typecheck, test) | Eng 1 | ⬜ |
| 5 | Set up Sentry error tracking + PostHog analytics | Eng 2 | ⬜ |
| 5 | Seed benchmark database with curated industry data | Eng 2 | ⬜ |

**Deliverable:** Authenticated app skeleton with database, billing, and CI/CD ready.

---

### Week 2: Integration Engine + Data Pipeline

| Day | Task | Owner | Status |
|---|---|---|---|
| 1 | Build Shopify OAuth flow (connect → callback → token storage) | Eng 1 | ⬜ |
| 1 | Build QuickBooks OAuth flow (connect → callback → token storage) | Eng 2 | ⬜ |
| 2 | Implement AES-256-GCM token encryption/decryption module | Eng 1 | ⬜ |
| 2 | Build Stripe Connect OAuth flow | Eng 2 | ⬜ |
| 3 | Build Shopify data sync (orders, refunds, products → raw_transactions) | Eng 1 | ⬜ |
| 3 | Build QBO data sync (P&L, balance sheet → raw_transactions) | Eng 2 | ⬜ |
| 4 | Build Stripe data sync (charges, payouts, refunds → raw_transactions) | Eng 1 | ⬜ |
| 4 | Build data normalization layer + deduplication engine | Eng 2 | ⬜ |
| 5 | Build daily_financials aggregation pipeline | Eng 1 | ⬜ |
| 5 | Build KPI calculation engine (all 15 metrics → metric_snapshots) | Eng 2 | ⬜ |
| 5 | Implement real-time sync status via Supabase Realtime | Eng 1 | ⬜ |

**Deliverable:** Data flows from Shopify/QBO/Stripe → normalized → KPIs calculated.

---

### Week 3: Dashboard + Forecast + Benchmarks (Core UI)

| Day | Task | Owner | Status |
|---|---|---|---|
| 1 | Build dashboard layout (sidebar, header, responsive shell) | Eng 1 | ⬜ |
| 1 | Build forecast service (time-series decomposition, 3-month projection) | Eng 2 | ⬜ |
| 2 | Build metric card component (value, sparkline, trend, health indicator) | Eng 1 | ⬜ |
| 2 | Build scenario modeling (best/base/worst case calculations) | Eng 2 | ⬜ |
| 3 | Build summary strip (4 hero metrics) + KPI grid (15 metric cards) | Eng 1 | ⬜ |
| 3 | Build benchmark comparison engine (percentile ranking) | Eng 2 | ⬜ |
| 4 | Build time range selector + benchmark toggle | Eng 1 | ⬜ |
| 4 | Build benchmark overlay UI (horizontal bars, gauge charts) | Eng 2 | ⬜ |
| 5 | Build forecast page (chart with confidence bands, scenario toggle) | Eng 1 | ⬜ |
| 5 | Build forecast override form + override list | Eng 2 | ⬜ |
| 5 | Integration testing: full flow from OAuth → sync → dashboard render | Both | ⬜ |

**Deliverable:** Functional dashboard showing real KPI data + forecast + benchmarks.

---

## 3. Phase 1: MVP Launch (Weeks 4–6)

> **Goal:** Ship AI insights, reports, onboarding, landing page. Launch to 50 beta users.
> **Team:** 2 engineers + 1 designer (part-time)

### Week 4: AI Insights + Reports

| Task | Owner | Status |
|---|---|---|
| Integrate Claude API (Anthropic SDK, prompt templates for 5 insight types) | Eng 2 | ⬜ |
| Build insight generation Edge Function (weekly cron) | Eng 2 | ⬜ |
| Build insight card UI component (title, body, metric, feedback buttons) | Eng 1 | ⬜ |
| Build insight feed on dashboard (collapsible sidebar) | Eng 1 | ⬜ |
| Build insights page (`/insights` — chronological feed with filters) | Eng 1 | ⬜ |
| Build PDF report template (Monthly Financial Snapshot, 4–6 pages) | Eng 2 | ⬜ |
| Build report generation Edge Function (PDF creation via @react-pdf/renderer) | Eng 2 | ⬜ |
| Build reports page (`/reports` — generate, history, download) | Eng 1 | ⬜ |
| Build CSV export for all data types (KPIs, cash flow, forecast) | Eng 1 | ⬜ |
| Build weekly email digest (HTML template via Resend) | Eng 2 | ⬜ |

---

### Week 5: Onboarding + Landing Page + Settings

| Task | Owner | Status |
|---|---|---|
| Build 3-step onboarding wizard (company profile → connect → dashboard) | Eng 1 | ⬜ |
| Build guided tour overlay (5 tooltips on first dashboard visit) | Eng 1 | ⬜ |
| Build empty states for all pages (CTAs to connect data) | Eng 1 | ⬜ |
| Build landing page (hero, features, social proof, pricing) | Eng 1 | ⬜ |
| Build pricing page with monthly/annual toggle | Eng 1 | ⬜ |
| Build settings pages (profile, company, integrations, billing, notifications) | Eng 2 | ⬜ |
| Build Stripe Checkout flow (plan selection → checkout → confirmation) | Eng 2 | ⬜ |
| Build Stripe Customer Portal integration (manage subscription) | Eng 2 | ⬜ |
| Build trial expiry flow (banner, email reminder, upgrade modal) | Eng 2 | ⬜ |
| SEO: meta tags, OG images, sitemap, robots.txt | Eng 1 | ⬜ |

---

### Week 6: QA, Security, Beta Launch

| Task | Owner | Status |
|---|---|---|
| End-to-end QA: signup → onboarding → connect → dashboard → forecast → report | Both | ⬜ |
| Cross-browser testing (Chrome, Safari, Firefox, Edge) | Eng 1 | ⬜ |
| Mobile responsiveness testing (375px–1920px) | Eng 1 | ⬜ |
| Security audit (RLS policies, token encryption, CSP headers, rate limiting) | Eng 2 | ⬜ |
| Performance testing (dashboard < 2s, API p95 < 500ms) | Eng 2 | ⬜ |
| Deploy privacy policy + terms of service | Eng 1 | ⬜ |
| Set up pg_cron jobs (daily sync, weekly insights, monthly reports) | Eng 2 | ⬜ |
| Write beta outreach emails + launch announcements | Both | ⬜ |
| **LAUNCH: Open beta to 50 DTC founders** | Both | ⬜ |
| Set up feedback collection (in-app widget, 5 user interview slots) | Both | ⬜ |

**Milestone:** 🚀 **MVP LIVE** — 50 beta users, 5 paying customers, $500 MRR target.

---

## 4. Phase 2: Product-Market Fit (Weeks 7–18)

> **Goal:** Iterate based on beta feedback. Reach 80 paying customers and $10K MRR.
> **Team:** 2–3 engineers + 1 designer

### Cycle 1 (Weeks 7–12): Feedback Loop + Polish

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Onboarding optimization** | Fix drop-off points identified in analytics. Reduce time-to-value to < 3 minutes. | Activation rate ≥ 75% |
| 🔴 P0 | **Bug fixes & stability** | Address top 10 bugs from beta feedback. Fix data sync reliability. | Sync success > 99% |
| 🔴 P0 | **KPI accuracy improvements** | Refine calculation formulas based on user feedback ("my numbers don't match QBO"). | 100% reconciliation accuracy |
| 🟠 P1 | **Xero integration** | 4th integration — high demand from UK/AU customers. | New integration live |
| 🟠 P1 | **Insight quality v2** | Improve Claude prompts based on feedback. Add "not helpful" retraining loop. | Insight helpfulness > 70% |
| 🟠 P1 | **Dashboard customization** | Drag-and-drop KPI card reordering. Pin/unpin metrics. | User engagement +20% |
| 🟡 P2 | **Dark mode** | Full dark theme for dashboard and all pages. | Design system update |
| 🟡 P2 | **Free tool: Benchmark Checker** | Public-facing PLG tool at `/tools/benchmark-checker`. | 200 leads/month |

---

### Cycle 2 (Weeks 13–18): Core Feature Expansion

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Amazon integration** | Seller Central data sync (revenue, fees, FBA costs). | New integration live |
| 🔴 P0 | **Advanced alerts** | Configurable threshold alerts for any KPI. Email + in-app delivery. | Feature adoption > 40% |
| 🟠 P1 | **Drill-down analytics** | Click any metric card → detailed breakdown (by channel, product, period). | Time on dashboard +30% |
| 🟠 P1 | **Revenue forecasting (12-month)** | Growth tier feature: AI-powered revenue projection. | Growth tier conversion +15% |
| 🟠 P1 | **Improved benchmarks** | User data aggregation (anonymized) supplements curated data. | Benchmark accuracy +25% |
| 🟡 P2 | **Free tool: Cash Runway Calculator** | Second PLG tool at `/tools/cash-runway`. | 300 leads/month |
| 🟡 P2 | **Webhook notifications** | Slack/Discord webhook delivery for alerts. | Integration engagement |
| 🟡 P2 | **Mobile PWA optimization** | Install-to-homescreen, offline dashboard caching. | Mobile usage +50% |

**Milestone:** 📈 **PMF Signal** — 80 paying, $10K MRR, NPS ≥ 40, monthly churn ≤ 5%.

---

## 5. Phase 3: Growth Engine (Weeks 19–30)

> **Goal:** Scale acquisition. Build features that drive upgrades. Reach $60K MRR.
> **Team:** 3–4 engineers + 1 designer + 1 growth marketer

### Cycle 3 (Weeks 19–24): Monetization + Team Features

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Multi-user team access** | Invite team members (editor, viewer roles). Growth: 3 users. Scale: 10 users. | Team plan adoption 30% |
| 🔴 P0 | **Advisor/accountant seats** | Read-only seats at $29/mo for external bookkeepers/advisors. | New revenue stream |
| 🔴 P0 | **Investor Readiness Pack** | Add-on: fundraising dashboard, auto-populated pitch deck financials, data room. | $149/mo add-on upsell |
| 🟠 P1 | **WooCommerce integration** | 5th integration — expands addressable market. | TAM expansion |
| 🟠 P1 | **Custom KPIs** | Scale tier: define custom metrics with formula builder. | Scale tier stickiness |
| 🟠 P1 | **Board reporting templates** | Scale tier: auto-generated quarterly board packs. | Scale tier value prop |
| 🟡 P2 | **Shopify App Store listing** | Official Shopify App Store presence. | Distribution channel |
| 🟡 P2 | **Referral program** | "Invite a founder, both get 1 month free." | Viral coefficient > 0.2 |

---

### Cycle 4 (Weeks 25–30): Advanced Analytics + Partnerships

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Scenario planning workspace** | Full what-if modeling: adjust revenue, headcount, COGS, marketing spend → see impact on P&L, cash, runway. | Power user retention |
| 🔴 P0 | **Cohort analysis** | Customer cohort retention, LTV by cohort, repurchase curves. | Analytics depth |
| 🟠 P1 | **Partner portal** | Dashboard for accounting firms: manage multiple client companies. | Partner acquisition |
| 🟠 P1 | **Automated anomaly alerts** | Real-time: "Revenue dropped 30% today" — don't wait for weekly digest. | Engagement + retention |
| 🟠 P1 | **Budget vs. actual tracking** | Users set monthly budgets → dashboard shows variance. | Planning feature |
| 🟡 P2 | **Data enrichment** | Integrate weather, industry events, competitor data for forecast improvement. | Forecast MAPE < 15% |
| 🟡 P2 | **Content marketing engine** | Auto-generated SEO blog posts from anonymized benchmark data. | Organic traffic 10x |

**Milestone:** 🚀 **Growth Mode** — 400 paying, $60K MRR, LTV:CAC > 3:1, team of 6+.

---

## 6. Phase 4: Scale & Expand (Weeks 31–52)

> **Goal:** Expand into adjacent verticals. Build platform moat. Target $150K+ MRR.
> **Team:** 5–7 engineers + 2 designers + 2 growth

### Cycle 5 (Weeks 31–36): Platform & API

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Public API (v1)** | REST API for customers to pull their data programmatically. | Platform stickiness |
| 🔴 P0 | **Zapier / Make integration** | No-code automation: trigger workflows based on KPI changes. | Integration ecosystem |
| 🟠 P1 | **White-label reports** | Remove FinancialIntelAI branding. Custom logo, colors, domain. | Enterprise upsell |
| 🟠 P1 | **Multi-currency support** | GBP, EUR, CAD, AUD — required for international expansion. | UK/EU/AU market |
| 🟡 P2 | **Data warehouse export** | Nightly data push to BigQuery/Snowflake for advanced analytics users. | Enterprise feature |

---

### Cycle 6 (Weeks 37–42): SaaS Vertical Expansion

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **SaaS metrics module** | MRR, ARR, churn, expansion revenue, net dollar retention, magic number. | New vertical |
| 🔴 P0 | **Stripe Billing integration (for SaaS)** | Pull subscription data for SaaS companies using Stripe Billing. | SaaS data source |
| 🟠 P1 | **SaaS benchmarks** | OpenView/Bessemer/KeyBanc SaaS benchmarks dataset. | SaaS comparison data |
| 🟠 P1 | **Baremetrics/ChartMogul migration tool** | Import data from competing tools. | Competitor displacement |
| 🟡 P2 | **SaaS-specific insights** | AI prompts tuned for SaaS metrics and growth patterns. | SaaS insight quality |

---

### Cycle 7 (Weeks 43–48): Mobile + Advanced AI

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Native mobile app (React Native)** | iOS + Android app with push notification alerts. | Mobile engagement |
| 🟠 P1 | **AI chat assistant** | "Ask your CFO" — natural language queries about your financials. | AI differentiation |
| 🟠 P1 | **Predictive cash flow alerts** | Proactive: "You'll run low on cash in 6 weeks based on current trajectory." | Predictive value |
| 🟡 P2 | **AI-generated action plans** | Beyond insights: full action plans with estimated financial impact. | Strategic AI |

---

### Cycle 8 (Weeks 49–52): Year-End & 2027 Planning

| Priority | Feature | Description | Target |
|---|---|---|---|
| 🔴 P0 | **Annual benchmark report** | "2026 DTC Financial Benchmarks" — flagship content piece. | SEO + brand authority |
| 🔴 P0 | **SOC 2 Type I certification** | Required for enterprise sales and partner trust. | Compliance |
| 🟠 P1 | **Professional services vertical** | Agency/consultancy metrics module. | Third vertical |
| 🟡 P2 | **Marketplace** | Third-party integrations and template marketplace. | Platform ecosystem |

**Milestone:** 🏆 **Scale** — 1,000+ paying, $150K+ MRR ($1.8M+ ARR run rate), 3 verticals.

---

## 7. Feature Prioritization Matrix

### ICE Score Ranking (Impact × Confidence × Ease)

| Rank | Feature | Impact | Confidence | Ease | ICE Score | Phase |
|---|---|---|---|---|---|---|
| 1 | KPI Dashboard (15 metrics) | 10 | 10 | 7 | 700 | 0 |
| 2 | Shopify Integration | 10 | 10 | 6 | 600 | 0 |
| 3 | Cash Flow Forecast (3mo) | 9 | 9 | 6 | 486 | 0 |
| 4 | Industry Benchmarking | 9 | 8 | 7 | 504 | 0 |
| 5 | QuickBooks Integration | 9 | 9 | 5 | 405 | 0 |
| 6 | AI Insights (Claude) | 8 | 7 | 6 | 336 | 1 |
| 7 | Onboarding Wizard | 9 | 9 | 8 | 648 | 1 |
| 8 | PDF Reports | 7 | 9 | 7 | 441 | 1 |
| 9 | Stripe Connect Integration | 7 | 9 | 6 | 378 | 0 |
| 10 | Free Tool: Benchmark Checker | 7 | 7 | 8 | 392 | 2 |
| 11 | Xero Integration | 6 | 8 | 5 | 240 | 2 |
| 12 | Revenue Forecasting (12mo) | 8 | 6 | 4 | 192 | 2 |
| 13 | Multi-user Teams | 7 | 8 | 4 | 224 | 3 |
| 14 | Investor Readiness Pack | 7 | 6 | 5 | 210 | 3 |
| 15 | Amazon Integration | 6 | 7 | 4 | 168 | 2 |
| 16 | Custom KPIs | 5 | 7 | 4 | 140 | 3 |
| 17 | Scenario Planning | 8 | 6 | 3 | 144 | 3 |
| 18 | Public API | 6 | 7 | 3 | 126 | 4 |
| 19 | SaaS Metrics Module | 7 | 5 | 3 | 105 | 4 |
| 20 | Mobile App | 6 | 6 | 2 | 72 | 4 |
| 21 | AI Chat Assistant | 7 | 4 | 3 | 84 | 4 |
| 22 | White-label | 5 | 6 | 3 | 90 | 4 |
| 23 | Multi-currency | 5 | 7 | 3 | 105 | 4 |

---

## 8. Technical Debt & Infrastructure Roadmap

### Planned Tech Debt Paydowns

| Week | Item | Description | Business Impact |
|---|---|---|---|
| 8 | **Test coverage to 80%** | Add unit tests for KPI service, forecast service, benchmark service | Reduce regression bugs |
| 12 | **E2E test suite** | Full Playwright suite for critical paths (signup, connect, dashboard, checkout) | Deploy confidence |
| 14 | **Database query optimization** | Analyze slow queries, add missing indexes, optimize RLS functions | Dashboard < 1.5s load |
| 18 | **Service extraction** | Extract forecast engine to standalone module (prep for future microservice) | Maintainability |
| 20 | **Data pipeline hardening** | Retry logic, dead-letter queue for failed syncs, sync monitoring dashboard | Sync reliability > 99.9% |
| 24 | **Caching layer** | Add Redis (Upstash) for frequently-accessed queries (dashboard KPIs) | API latency reduction |
| 30 | **Database sharding prep** | Evaluate TimescaleDB for metric_snapshots + raw_transactions | Scalability |
| 36 | **API versioning** | Implement v2 API alongside v1 with deprecation plan | Platform stability |
| 42 | **Infrastructure as Code** | Terraform for Supabase + Vercel configuration | Reproducible environments |
| 48 | **SOC 2 compliance** | Security controls, access logging, vendor risk assessments | Enterprise readiness |

### Infrastructure Scaling Triggers

| Trigger | Current | Action | When |
|---|---|---|---|
| Database CPU > 60% sustained | Supabase Pro (shared) | Upgrade to Supabase Team (dedicated compute) | ~200 customers |
| API p95 > 400ms | Vercel Serverless | Add Upstash Redis caching layer | ~500 customers |
| Storage > 50GB | Supabase Storage (included) | Evaluate CDN for report delivery | ~500 customers |
| metric_snapshots > 100M rows | PostgreSQL | Add TimescaleDB hypertables | ~1,000 customers |
| Concurrent sessions > 500 | Vercel auto-scaling | Add connection pooling (PgBouncer) | ~1,000 customers |
| Edge Function concurrency > 50 | Supabase Edge | Evaluate dedicated worker infrastructure (Inngest/Trigger.dev) | ~1,000 customers |

---

## 9. Key Milestones & KPIs

### Milestone Timeline

```
    Week 3         Week 6         Week 12        Week 18        Week 24        Week 36        Week 52
      │              │              │              │              │              │              │
      ▼              ▼              ▼              ▼              ▼              ▼              ▼
   ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐
   │ Tech │      │ MVP  │      │ PMF  │      │ PMF  │      │Profit│      │Scale │      │Series│
   │ Ready│      │Launch│      │Signal│      │Confir│      │-able │      │ Mode │      │  A   │
   │      │      │      │      │      │      │med   │      │      │      │      │      │Ready │
   └──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘      └──────┘
   
   Metrics:
   Users:    0        50         200         350          600         1,500       3,000+
   Paying:   0         5          50          80          250          700       1,000+
   MRR:     $0      $500       $5,000      $10,000     $35,000     $100,000   $150,000+
   Integ:    3         3           4           5            6            8          10+
```

### KPI Targets by Phase

| KPI | Phase 1 (W6) | Phase 2 (W18) | Phase 3 (W30) | Phase 4 (W52) |
|---|---|---|---|---|
| **Total Users** | 50 | 350 | 1,000 | 3,000+ |
| **Paying Customers** | 5 | 80 | 400 | 1,000+ |
| **MRR** | $500 | $10,000 | $60,000 | $150,000+ |
| **ARR Run Rate** | $6K | $120K | $720K | $1.8M+ |
| **Activation Rate** | 50% | 70% | 80% | 85% |
| **Trial → Paid** | 10% | 20% | 25% | 28% |
| **Monthly Churn** | — | 5% | 3.5% | 2.5% |
| **NPS** | 30 | 45 | 55 | 60+ |
| **LTV:CAC** | — | 2.5:1 | 3.5:1 | 4:1+ |
| **Avg Revenue/Customer** | $100 | $125 | $150 | $150 |
| **Data Sync Success** | 95% | 99% | 99.5% | 99.9% |
| **Dashboard Load Time** | < 3s | < 2s | < 1.5s | < 1s |
| **Integrations Available** | 3 | 5 | 7 | 10+ |
| **Team Size** | 2 | 4 | 7 | 10+ |

### Revenue Breakdown Target (Week 52)

```
  $150,000+ MRR Composition
  
  ┌─────────────────────────────────────────────────────────┐
  │                                                         │
  │  Starter ($99/mo)    ████████████████░░░░░░░  500 × $99 │ = $49,500
  │  Growth  ($299/mo)   ████████████████████░░░  300 × $299│ = $89,700
  │  Scale   ($699/mo)   ██████░░░░░░░░░░░░░░░░░   20 × $699│ = $13,980
  │  Add-ons             ███░░░░░░░░░░░░░░░░░░░░░           │ = ~$5,000
  │                                                         │
  │  Total: ~$158,000 MRR                                   │
  │                                                         │
  └─────────────────────────────────────────────────────────┘
```

---

## 10. Risk Register

| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|
| **Shopify API rate limits** throttle data sync | Medium | High | Implement intelligent batching, incremental sync, webhook-first architecture | Eng |
| **QuickBooks OAuth tokens expire** causing sync failures | High | Medium | Proactive token refresh (24h before expiry), user notification on failure | Eng |
| **AI insight quality is low** — users mark most as "not helpful" | Medium | High | A/B test prompts, build feedback loop into Claude prompt, human-in-the-loop curation for first 100 users | Eng + Product |
| **Benchmark data is stale or inaccurate** | Medium | High | Quarterly refresh schedule, supplement with anonymized user data, clearly label data sources + dates | Data |
| **Data deduplication fails** (double-counting Shopify + Stripe revenue) | Medium | High | Robust matching logic (order_id, timestamp windows), manual reconciliation flag | Eng |
| **Supabase performance bottleneck** at scale | Low | High | Connection pooling, read replicas, TimescaleDB for time-series, Redis caching layer | Eng |
| **Competitor launches DTC-specific tool** | Medium | Medium | Move fast, build community moat (benchmarking network effect), focus on insight quality over feature quantity | Product |
| **Low trial-to-paid conversion** (< 10%) | Medium | High | Optimize onboarding, add in-trial value demonstration, implement trial extension for engaged users | Growth |
| **GDPR/data privacy complaint** | Low | High | Implement data export + deletion, DPA with Supabase, encrypt all PII, privacy-first architecture | Legal + Eng |
| **Key employee departure** | Medium | Medium | Document everything, pair programming, no single points of failure in codebase | Team |
| **Cash burn exceeds projections** | Medium | High | Maintain 6-month runway, monitor burn weekly, define go/no-go criteria at each milestone | Founder |

### Decision Points

| Week | Decision | Go Criteria | Pivot Criteria |
|---|---|---|---|
| **Week 6** | Continue building or pivot niche? | > 40 trials, > 5 paid, NPS > 30 | < 20 trials, < 2 paid |
| **Week 12** | Scale marketing spend? | > 50 paying, churn < 8%, LTV:CAC > 2:1 | Churn > 10%, negative NPS feedback |
| **Week 18** | Hire engineer #3 + #4? | > $8K MRR, clear feature backlog, proven unit economics | MRR plateau, unclear PMF signal |
| **Week 24** | Raise seed round? | > $30K MRR, > 3:1 LTV:CAC, growing MoM | Growth stalling, high churn |
| **Week 36** | Expand to SaaS vertical? | DTC vertical stable, > $80K MRR, team capacity | DTC not profitable, team stretched |
| **Week 52** | Raise Series A? | > $150K MRR, > 1,000 paying, proven expansion model | Growth rate < 10% MoM |

---

> *This roadmap is a living document. Updated monthly based on customer feedback, market signals, and team capacity. Last updated: June 7, 2026.*
