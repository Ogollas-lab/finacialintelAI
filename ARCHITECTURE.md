# FinancialIntelAI — System Architecture

> **Stack:** Next.js 15 · TypeScript · Tailwind CSS v4 · Supabase · Stripe · Claude API
> **Version:** 1.0 — Production Architecture
> **Date:** June 7, 2026

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [System Context Diagram](#2-system-context-diagram)
3. [Technology Stack](#3-technology-stack)
4. [Application Architecture](#4-application-architecture)
5. [Frontend Architecture](#5-frontend-architecture)
6. [Backend Architecture](#6-backend-architecture)
7. [Data Integration Architecture](#7-data-integration-architecture)
8. [AI & Forecasting Architecture](#8-ai--forecasting-architecture)
9. [Authentication & Authorization](#9-authentication--authorization)
10. [Billing & Subscription Architecture](#10-billing--subscription-architecture)
11. [Infrastructure & Deployment](#11-infrastructure--deployment)
12. [Security Architecture](#12-security-architecture)
13. [Monitoring & Observability](#13-monitoring--observability)
14. [Performance Architecture](#14-performance-architecture)
15. [API Design](#15-api-design)

---

## 1. Architecture Overview

### Design Principles

| Principle | Implementation |
|---|---|
| **Monorepo, Modular Boundaries** | Single Next.js app with clear domain modules — avoids microservice overhead at MVP scale |
| **Edge-First Rendering** | Server Components by default, Client Components only for interactivity (charts, forms) |
| **Supabase as Backend** | Auth, Postgres, Row-Level Security, Edge Functions, Realtime — single managed platform |
| **Type Safety End-to-End** | TypeScript everywhere — frontend, API routes, database queries (via Supabase codegen), Zod validation |
| **Async-Heavy Processing** | Data syncs, forecasts, AI insights run as background jobs — never block the user |
| **Security by Default** | RLS on every table, encrypted tokens, zero-trust API design |

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENTS                                        │
│    ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────┐        │
│    │ Browser  │    │ Mobile   │    │ Email    │    │ Webhook      │        │
│    │ (React)  │    │ (PWA)    │    │ Client   │    │ Receivers    │        │
│    └────┬─────┘    └────┬─────┘    └────┬─────┘    └──────┬───────┘        │
└─────────┼──────────────┼──────────────┼────────────────────┼────────────────┘
          │              │              │                    │
          ▼              ▼              ▼                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EDGE / CDN LAYER                                    │
│                        Vercel Edge Network                                  │
│              (Static assets, ISR, Edge Middleware)                          │
└─────────────────────────────────┬───────────────────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      APPLICATION LAYER (Next.js 15)                        │
│                                                                             │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌────────────────┐    │
│  │   Server Components  │  │   API Routes         │  │  Middleware     │    │
│  │   (Dashboard, Pages) │  │   /api/v1/*           │  │  (Auth, CORS)  │    │
│  └──────────┬───────────┘  └──────────┬───────────┘  └────────────────┘    │
│             │                         │                                     │
│  ┌──────────┴─────────────────────────┴───────────────────────────────┐    │
│  │                    SERVICE LAYER (TypeScript)                       │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐ │    │
│  │  │ KPI      │ │ Forecast │ │ Benchmark│ │ Insight  │ │ Report  │ │    │
│  │  │ Service  │ │ Service  │ │ Service  │ │ Service  │ │ Service │ │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └─────────┘ │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                             │
└──────────────────────────────────┬──────────────────────────────────────────┘
                                   │
          ┌────────────────────────┼────────────────────────┐
          ▼                        ▼                        ▼
┌──────────────────┐  ┌──────────────────────┐  ┌────────────────────────┐
│   SUPABASE       │  │   EXTERNAL SERVICES  │  │  BACKGROUND WORKERS   │
│                  │  │                      │  │                        │
│  ┌────────────┐  │  │  ┌────────────────┐  │  │  ┌──────────────────┐ │
│  │ PostgreSQL │  │  │  │ Shopify API    │  │  │  │ Data Sync Cron   │ │
│  │ + RLS      │  │  │  ├────────────────┤  │  │  ├──────────────────┤ │
│  ├────────────┤  │  │  │ QuickBooks API │  │  │  │ Forecast Engine  │ │
│  │ Auth       │  │  │  ├────────────────┤  │  │  ├──────────────────┤ │
│  ├────────────┤  │  │  │ Stripe API     │  │  │  │ Insight Generator│ │
│  │ Storage    │  │  │  ├────────────────┤  │  │  ├──────────────────┤ │
│  ├────────────┤  │  │  │ Claude API     │  │  │  │ Report Generator │ │
│  │ Edge Funcs │  │  │  ├────────────────┤  │  │  ├──────────────────┤ │
│  ├────────────┤  │  │  │ Resend (Email) │  │  │  │ Email Scheduler  │ │
│  │ Realtime   │  │  │  └────────────────┘  │  │  └──────────────────┘ │
│  └────────────┘  │  │                      │  │                        │
└──────────────────┘  └──────────────────────┘  └────────────────────────┘
```

---

## 2. System Context Diagram

```
                                    ┌──────────────┐
                                    │   Founder /  │
                                    │   CEO        │
                                    │  (Primary)   │
                                    └──────┬───────┘
                                           │ Uses
                                           ▼
┌──────────────┐   OAuth    ┌─────────────────────────────┐   Webhooks    ┌──────────────┐
│   Shopify    │◄──────────►│                             │◄────────────►│   Stripe     │
│   Platform   │   Data     │     FinancialIntelAI        │   Payments   │   Billing    │
└──────────────┘   Sync     │                             │              └──────────────┘
                            │   Next.js + Supabase App    │
┌──────────────┐   OAuth    │                             │   API Calls  ┌──────────────┐
│  QuickBooks  │◄──────────►│                             │─────────────►│  Claude API  │
│  Online      │   Data     │                             │   Insights   │  (Anthropic) │
└──────────────┘   Sync     └──────────┬──────────────────┘              └──────────────┘
                                       │
┌──────────────┐   OAuth               │ Sends         ┌──────────────┐
│   Stripe     │◄──────────────────────┤               │   Resend     │
│  (Payments)  │   Transaction Data    │ Emails        │  (Email API) │
└──────────────┘                       └──────────────►└──────────────┘
```

---

## 3. Technology Stack

### Core Stack

| Layer | Technology | Version | Purpose |
|---|---|---|---|
| **Runtime** | Node.js | 22 LTS | Server runtime |
| **Framework** | Next.js | 15.x (App Router) | Full-stack React framework |
| **Language** | TypeScript | 5.x | Type safety across entire codebase |
| **Styling** | Tailwind CSS | v4 | Utility-first CSS framework |
| **UI Components** | shadcn/ui | Latest | Radix-based accessible component primitives |
| **Charts** | Recharts | 2.x | React charting library (composable, responsive) |
| **Forms** | React Hook Form + Zod | Latest | Form management + schema validation |
| **State** | Zustand + React Query | Latest | Client state + server state management |

### Backend & Data

| Layer | Technology | Purpose |
|---|---|---|
| **Database** | Supabase PostgreSQL | Primary data store with RLS |
| **Auth** | Supabase Auth | Authentication (email, Google OAuth, magic link) |
| **File Storage** | Supabase Storage | Generated reports (PDFs), avatars |
| **Edge Functions** | Supabase Edge Functions (Deno) | Webhook handlers, scheduled jobs |
| **Realtime** | Supabase Realtime | Live sync status updates |
| **Database Types** | supabase gen types | Auto-generated TypeScript types from schema |
| **Migrations** | Supabase CLI (SQL) | Version-controlled database migrations |

### External Services

| Service | Purpose | Integration Method |
|---|---|---|
| **Stripe** | Subscription billing + payments | Stripe SDK + webhooks |
| **Claude API (Anthropic)** | AI insight generation | REST API (claude-sonnet-4-20250514 model) |
| **Resend** | Transactional email delivery | REST API |
| **Shopify** | E-commerce data source | Admin REST API + OAuth |
| **QuickBooks Online** | Accounting data source | REST API + OAuth 2.0 |
| **Stripe Connect** | Payment data source | REST API + OAuth |
| **Vercel** | Hosting, CDN, CI/CD | Git integration |
| **Sentry** | Error tracking & performance monitoring | SDK |
| **PostHog** | Product analytics | SDK |

### Development Tools

| Tool | Purpose |
|---|---|
| **pnpm** | Package manager (fast, disk-efficient) |
| **Turborepo** | Monorepo build orchestration (if needed later) |
| **Biome** | Linting + formatting (fast Rust-based) |
| **Vitest** | Unit + integration testing |
| **Playwright** | End-to-end testing |
| **GitHub Actions** | CI/CD pipeline |
| **Supabase CLI** | Local development, migrations, type generation |

---

## 4. Application Architecture

### 4.1 Directory Structure

```
financialintelai/
├── .github/
│   └── workflows/
│       ├── ci.yml                    # Lint, test, type-check
│       └── deploy.yml                # Vercel production deploy
│
├── supabase/
│   ├── migrations/                   # SQL migration files (versioned)
│   │   ├── 00001_initial_schema.sql
│   │   ├── 00002_rls_policies.sql
│   │   ├── 00003_benchmark_seed.sql
│   │   └── ...
│   ├── functions/                    # Supabase Edge Functions
│   │   ├── sync-shopify/
│   │   ├── sync-quickbooks/
│   │   ├── sync-stripe/
│   │   ├── generate-insights/
│   │   ├── generate-forecast/
│   │   ├── generate-report/
│   │   ├── stripe-webhook/
│   │   └── scheduled-digest/
│   ├── seed.sql                      # Benchmark + test data
│   └── config.toml                   # Local Supabase config
│
├── src/
│   ├── app/                          # Next.js App Router
│   │   ├── (auth)/                   # Auth layout group
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   ├── signup/
│   │   │   │   └── page.tsx
│   │   │   ├── forgot-password/
│   │   │   │   └── page.tsx
│   │   │   └── layout.tsx
│   │   │
│   │   ├── (dashboard)/              # Dashboard layout group (authenticated)
│   │   │   ├── dashboard/
│   │   │   │   └── page.tsx          # Main KPI dashboard
│   │   │   ├── forecast/
│   │   │   │   └── page.tsx          # Cash flow forecast
│   │   │   ├── benchmarks/
│   │   │   │   └── page.tsx          # Industry benchmarking
│   │   │   ├── insights/
│   │   │   │   └── page.tsx          # AI insight feed
│   │   │   ├── reports/
│   │   │   │   └── page.tsx          # Report generation & history
│   │   │   ├── settings/
│   │   │   │   ├── page.tsx          # General settings
│   │   │   │   ├── integrations/
│   │   │   │   │   └── page.tsx      # Data source connections
│   │   │   │   ├── billing/
│   │   │   │   │   └── page.tsx      # Subscription management
│   │   │   │   └── profile/
│   │   │   │       └── page.tsx      # Company profile
│   │   │   ├── onboarding/
│   │   │   │   └── page.tsx          # 3-step onboarding wizard
│   │   │   └── layout.tsx            # Sidebar + header layout
│   │   │
│   │   ├── (marketing)/              # Public marketing pages
│   │   │   ├── page.tsx              # Landing page (home)
│   │   │   ├── pricing/
│   │   │   │   └── page.tsx
│   │   │   ├── tools/
│   │   │   │   ├── benchmark-checker/
│   │   │   │   │   └── page.tsx
│   │   │   │   ├── cash-runway/
│   │   │   │   │   └── page.tsx
│   │   │   │   └── kpi-scorecard/
│   │   │   │       └── page.tsx
│   │   │   └── layout.tsx
│   │   │
│   │   ├── api/                      # API Routes
│   │   │   ├── v1/
│   │   │   │   ├── metrics/
│   │   │   │   │   └── route.ts
│   │   │   │   ├── forecast/
│   │   │   │   │   └── route.ts
│   │   │   │   ├── benchmarks/
│   │   │   │   │   └── route.ts
│   │   │   │   ├── insights/
│   │   │   │   │   └── route.ts
│   │   │   │   ├── reports/
│   │   │   │   │   └── route.ts
│   │   │   │   └── integrations/
│   │   │   │       ├── shopify/
│   │   │   │       │   ├── callback/route.ts
│   │   │   │       │   └── route.ts
│   │   │   │       ├── quickbooks/
│   │   │   │       │   ├── callback/route.ts
│   │   │   │       │   └── route.ts
│   │   │   │       └── stripe-connect/
│   │   │   │           ├── callback/route.ts
│   │   │   │           └── route.ts
│   │   │   └── webhooks/
│   │   │       ├── stripe/route.ts
│   │   │       ├── shopify/route.ts
│   │   │       └── quickbooks/route.ts
│   │   │
│   │   ├── layout.tsx                # Root layout
│   │   ├── not-found.tsx
│   │   └── error.tsx
│   │
│   ├── components/                   # Shared UI components
│   │   ├── ui/                       # shadcn/ui primitives
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── dropdown-menu.tsx
│   │   │   ├── input.tsx
│   │   │   ├── select.tsx
│   │   │   ├── skeleton.tsx
│   │   │   ├── toast.tsx
│   │   │   └── ...
│   │   ├── charts/                   # Chart components
│   │   │   ├── area-chart.tsx
│   │   │   ├── bar-chart.tsx
│   │   │   ├── gauge-chart.tsx
│   │   │   ├── sparkline.tsx
│   │   │   └── forecast-chart.tsx
│   │   ├── dashboard/                # Dashboard-specific components
│   │   │   ├── metric-card.tsx
│   │   │   ├── kpi-grid.tsx
│   │   │   ├── summary-strip.tsx
│   │   │   ├── benchmark-overlay.tsx
│   │   │   ├── time-range-selector.tsx
│   │   │   └── health-indicator.tsx
│   │   ├── forecast/                 # Forecast-specific components
│   │   │   ├── scenario-toggle.tsx
│   │   │   ├── override-form.tsx
│   │   │   ├── override-list.tsx
│   │   │   └── runway-bar.tsx
│   │   ├── insights/                 # Insight components
│   │   │   ├── insight-card.tsx
│   │   │   ├── insight-feed.tsx
│   │   │   └── insight-feedback.tsx
│   │   ├── reports/                  # Report components
│   │   │   ├── report-generator.tsx
│   │   │   ├── report-list.tsx
│   │   │   └── csv-exporter.tsx
│   │   ├── onboarding/              # Onboarding components
│   │   │   ├── step-company.tsx
│   │   │   ├── step-connect.tsx
│   │   │   ├── step-dashboard.tsx
│   │   │   └── progress-bar.tsx
│   │   ├── layout/                   # Layout components
│   │   │   ├── sidebar.tsx
│   │   │   ├── header.tsx
│   │   │   ├── mobile-nav.tsx
│   │   │   └── breadcrumbs.tsx
│   │   └── shared/                   # Shared components
│   │       ├── logo.tsx
│   │       ├── loading-spinner.tsx
│   │       ├── empty-state.tsx
│   │       ├── error-boundary.tsx
│   │       └── data-freshness.tsx
│   │
│   ├── lib/                          # Core libraries & utilities
│   │   ├── supabase/
│   │   │   ├── client.ts             # Browser Supabase client
│   │   │   ├── server.ts             # Server-side Supabase client
│   │   │   ├── admin.ts              # Service-role Supabase client
│   │   │   ├── middleware.ts         # Auth middleware helper
│   │   │   └── types.ts             # Auto-generated database types
│   │   ├── stripe/
│   │   │   ├── client.ts             # Stripe SDK instance
│   │   │   ├── plans.ts              # Plan configuration
│   │   │   └── webhook.ts            # Webhook signature verification
│   │   ├── integrations/
│   │   │   ├── shopify/
│   │   │   │   ├── client.ts         # Shopify API client
│   │   │   │   ├── sync.ts           # Data sync logic
│   │   │   │   └── types.ts          # Shopify response types
│   │   │   ├── quickbooks/
│   │   │   │   ├── client.ts
│   │   │   │   ├── sync.ts
│   │   │   │   └── types.ts
│   │   │   └── stripe-connect/
│   │   │       ├── client.ts
│   │   │       ├── sync.ts
│   │   │       └── types.ts
│   │   ├── services/
│   │   │   ├── kpi.service.ts        # KPI calculation engine
│   │   │   ├── forecast.service.ts   # Forecast engine
│   │   │   ├── benchmark.service.ts  # Benchmark comparison engine
│   │   │   ├── insight.service.ts    # AI insight generation
│   │   │   ├── report.service.ts     # Report generation
│   │   │   └── sync.service.ts       # Data sync orchestration
│   │   ├── ai/
│   │   │   ├── claude.ts             # Claude API client
│   │   │   ├── prompts/
│   │   │   │   ├── anomaly.ts        # Anomaly detection prompt
│   │   │   │   ├── trend.ts          # Trend analysis prompt
│   │   │   │   ├── benchmark.ts      # Benchmark comparison prompt
│   │   │   │   ├── predictive.ts     # Predictive warning prompt
│   │   │   │   └── opportunity.ts    # Opportunity identification prompt
│   │   │   └── types.ts              # AI response types
│   │   ├── utils/
│   │   │   ├── formatting.ts         # Number, currency, date formatters
│   │   │   ├── calculations.ts       # Financial calculation helpers
│   │   │   ├── dates.ts              # Date range utilities
│   │   │   ├── encryption.ts         # Token encryption/decryption (AES-256-GCM)
│   │   │   └── constants.ts          # App-wide constants
│   │   └── validators/
│   │       ├── company.schema.ts     # Company profile Zod schemas
│   │       ├── forecast.schema.ts    # Forecast override schemas
│   │       ├── report.schema.ts      # Report request schemas
│   │       └── integration.schema.ts # Integration config schemas
│   │
│   ├── hooks/                        # Custom React hooks
│   │   ├── use-metrics.ts            # Fetch & cache KPI data
│   │   ├── use-forecast.ts           # Fetch & manage forecast
│   │   ├── use-benchmarks.ts         # Fetch benchmark data
│   │   ├── use-insights.ts           # Fetch AI insights
│   │   ├── use-integrations.ts       # Integration status
│   │   ├── use-subscription.ts       # Current subscription plan
│   │   ├── use-company.ts            # Company profile
│   │   └── use-realtime-sync.ts      # Supabase Realtime for sync status
│   │
│   ├── stores/                       # Zustand stores
│   │   ├── dashboard.store.ts        # Time range, benchmark toggle state
│   │   ├── forecast.store.ts         # Active scenario, overrides
│   │   └── onboarding.store.ts       # Onboarding step progress
│   │
│   └── types/                        # Global TypeScript types
│       ├── database.ts               # Supabase-generated DB types
│       ├── metrics.ts                # KPI metric types
│       ├── forecast.ts               # Forecast types
│       ├── integrations.ts           # Integration types
│       └── api.ts                    # API request/response types
│
├── public/
│   ├── images/
│   ├── fonts/
│   └── favicon.ico
│
├── tests/
│   ├── unit/
│   │   ├── services/
│   │   │   ├── kpi.service.test.ts
│   │   │   ├── forecast.service.test.ts
│   │   │   └── benchmark.service.test.ts
│   │   └── utils/
│   │       ├── calculations.test.ts
│   │       └── formatting.test.ts
│   ├── integration/
│   │   ├── api/
│   │   │   ├── metrics.test.ts
│   │   │   └── forecast.test.ts
│   │   └── integrations/
│   │       └── shopify.test.ts
│   └── e2e/
│       ├── onboarding.spec.ts
│       ├── dashboard.spec.ts
│       └── forecast.spec.ts
│
├── .env.local.example                # Environment variable template
├── .env.local                        # Local secrets (git-ignored)
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── vitest.config.ts
├── playwright.config.ts
├── biome.json
├── package.json
└── pnpm-lock.yaml
```

### 4.2 Module Dependency Graph

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION                              │
│   pages (App Router) → components → hooks → stores              │
└─────────────────────────┬───────────────────────────────────────┘
                          │ imports
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        SERVICES                                  │
│   kpi.service → forecast.service → benchmark.service            │
│   insight.service → report.service → sync.service               │
└─────────────────────────┬───────────────────────────────────────┘
                          │ imports
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│                        INFRASTRUCTURE                            │
│   supabase/client → integrations/* → ai/claude → stripe/client  │
│   utils/* → validators/*                                        │
└─────────────────────────────────────────────────────────────────┘

  RULE: Arrows go DOWN only. No circular dependencies.
  RULE: Presentation never imports from infrastructure directly.
  RULE: Services are the only layer that talks to infrastructure.
```

---

## 5. Frontend Architecture

### 5.1 Rendering Strategy

| Page | Rendering | Rationale |
|---|---|---|
| **Landing page** | Static (SSG) | SEO-critical, rarely changes |
| **Pricing page** | Static (SSG) | SEO-critical |
| **Free tools** | Static + Client | SEO for the page, client for the calculator |
| **Login / Signup** | Server Component | Auth handled server-side by Supabase |
| **Dashboard** | Server Component + Client Islands | Server fetches data, charts render client-side |
| **Forecast** | Server Component + Client Islands | Server fetches base data, scenarios are client-interactive |
| **Benchmarks** | Server Component | Primarily read-only data display |
| **Insights** | Server Component + Client Islands | Server fetches, feedback buttons are client |
| **Reports** | Server Component + Client Islands | Report list is server, generation triggers are client |
| **Settings** | Client Component | Heavily interactive forms |

### 5.2 Client State Management

```
┌─────────────────────────────────────────────────────────┐
│                    STATE ARCHITECTURE                     │
│                                                          │
│  ┌──────────────────────┐  ┌─────────────────────────┐  │
│  │   SERVER STATE        │  │   CLIENT STATE           │  │
│  │   (React Query /      │  │   (Zustand)              │  │
│  │    TanStack Query)    │  │                          │  │
│  │                       │  │                          │  │
│  │  • KPI metrics        │  │  • Time range selection  │  │
│  │  • Forecast data      │  │  • Benchmark toggle      │  │
│  │  • Benchmark data     │  │  • Active scenario       │  │
│  │  • Insight feed       │  │  • Override drafts       │  │
│  │  • Integration status │  │  • Onboarding step       │  │
│  │  • Report history     │  │  • Sidebar collapsed     │  │
│  │  • Subscription info  │  │  • Dark/light mode       │  │
│  │                       │  │                          │  │
│  │  Cache: 5 min stale   │  │  Persist: localStorage   │  │
│  │  Refetch on focus     │  │  (display preferences)   │  │
│  └──────────────────────┘  └─────────────────────────┘  │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 5.3 Component Architecture

```typescript
// COMPONENT PATTERN: Composition + Server/Client Split

// Server Component (data fetching)
// src/app/(dashboard)/dashboard/page.tsx
export default async function DashboardPage() {
  const supabase = createServerClient();
  const metrics = await getMetrics(supabase, timeRange);
  const benchmarks = await getBenchmarks(supabase, companyProfile);

  return (
    <DashboardShell>
      <SummaryStrip metrics={metrics.hero} />        {/* Server */}
      <KPIGrid metrics={metrics.all}                  {/* Client */}
               benchmarks={benchmarks} />
      <InsightFeed companyId={company.id} />          {/* Client */}
    </DashboardShell>
  );
}

// Client Component (interactive charts)
// src/components/dashboard/kpi-grid.tsx
"use client";
export function KPIGrid({ metrics, benchmarks }) {
  const { timeRange } = useDashboardStore();
  const { showBenchmarks } = useDashboardStore();
  // ... renders interactive metric cards with charts
}
```

### 5.4 Design System (Tailwind Configuration)

```typescript
// tailwind.config.ts
import type { Config } from "tailwindcss";

const config: Config = {
  darkMode: "class",
  content: ["./src/**/*.{ts,tsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          50: "#E6F7F3",
          100: "#B3E8D9",
          200: "#80D9BF",
          300: "#4DCAA5",
          400: "#26BF91",
          500: "#00D4AA",  // Primary teal
          600: "#00B893",
          700: "#009C7C",
          800: "#008066",
          900: "#005544",
        },
        navy: {
          50: "#E8EDF3",
          100: "#C5D0E0",
          200: "#9FB2CC",
          300: "#7994B8",
          400: "#5D7DA9",
          500: "#41679A",
          600: "#385A88",
          700: "#2D4A71",
          800: "#233B5B",
          900: "#1E3A5F",  // Primary navy
          950: "#0F172A",  // Background dark
        },
        success: "#22C55E",
        danger:  "#EF4444",
        warning: "#F59E0B",
        muted:   "#64748B",
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        mono: ["JetBrains Mono", "monospace"],
      },
      borderRadius: {
        card: "12px",
      },
      backdropBlur: {
        card: "12px",
      },
      animation: {
        "pulse-slow": "pulse 3s cubic-bezier(0.4, 0, 0.6, 1) infinite",
        "shimmer": "shimmer 2s linear infinite",
      },
    },
  },
  plugins: [require("tailwindcss-animate")],
};
```

---

## 6. Backend Architecture

### 6.1 API Route Design

All API routes live under `src/app/api/v1/` and follow REST conventions:

```
GET    /api/v1/metrics                    # Get KPIs for dashboard
GET    /api/v1/metrics/:metricName        # Get single KPI detail
GET    /api/v1/forecast                   # Get current forecast
POST   /api/v1/forecast/overrides         # Add manual override
PUT    /api/v1/forecast/overrides/:id     # Update override
DELETE /api/v1/forecast/overrides/:id     # Delete override
GET    /api/v1/benchmarks                 # Get benchmark comparisons
GET    /api/v1/insights                   # Get AI insights
POST   /api/v1/insights/:id/feedback      # Submit insight feedback
GET    /api/v1/reports                    # List generated reports
POST   /api/v1/reports                    # Generate new report
GET    /api/v1/reports/:id/download       # Download report file
GET    /api/v1/integrations               # List connected integrations
POST   /api/v1/integrations/:source/connect    # Initiate OAuth
DELETE /api/v1/integrations/:id           # Disconnect integration
POST   /api/v1/integrations/:id/refresh   # Trigger manual sync
POST   /api/v1/billing/checkout           # Create Stripe Checkout session
POST   /api/v1/billing/portal             # Create Stripe Customer Portal
GET    /api/v1/company                    # Get company profile
PUT    /api/v1/company                    # Update company profile
POST   /api/v1/tools/benchmark-check      # Free tool: benchmark checker
POST   /api/v1/tools/cash-runway          # Free tool: runway calculator
```

### 6.2 API Route Pattern

```typescript
// Standard API route pattern
// src/app/api/v1/metrics/route.ts

import { NextRequest, NextResponse } from "next/server";
import { createServerClient } from "@/lib/supabase/server";
import { KPIService } from "@/lib/services/kpi.service";
import { metricsQuerySchema } from "@/lib/validators/metrics.schema";

export async function GET(request: NextRequest) {
  // 1. Auth check
  const supabase = createServerClient();
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
  }

  // 2. Input validation
  const searchParams = request.nextUrl.searchParams;
  const parsed = metricsQuerySchema.safeParse({
    timeRange: searchParams.get("timeRange"),
    period: searchParams.get("period"),
  });
  if (!parsed.success) {
    return NextResponse.json(
      { error: "Invalid parameters", details: parsed.error.flatten() },
      { status: 400 }
    );
  }

  // 3. Authorization (company access via RLS)
  const company = await getCompanyForUser(supabase, user.id);
  if (!company) {
    return NextResponse.json({ error: "No company found" }, { status: 404 });
  }

  // 4. Business logic
  const kpiService = new KPIService(supabase);
  const metrics = await kpiService.getMetrics(company.id, parsed.data);

  // 5. Response
  return NextResponse.json({ data: metrics }, { status: 200 });
}
```

### 6.3 Service Layer Pattern

```typescript
// src/lib/services/kpi.service.ts

import { SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "@/types/database";
import type { MetricSnapshot, KPIDashboard } from "@/types/metrics";

export class KPIService {
  constructor(private supabase: SupabaseClient<Database>) {}

  async getMetrics(
    companyId: string,
    options: { timeRange: string; period: string }
  ): Promise<KPIDashboard> {
    const { startDate, endDate } = this.resolveTimeRange(options.timeRange);

    // Fetch raw metric snapshots from database
    const { data, error } = await this.supabase
      .from("metric_snapshots")
      .select("*")
      .eq("company_id", companyId)
      .gte("period_date", startDate)
      .lte("period_date", endDate)
      .order("period_date", { ascending: true });

    if (error) throw new ServiceError("Failed to fetch metrics", error);

    // Transform into dashboard format
    return this.buildDashboard(data, options);
  }

  async calculateAndStore(companyId: string): Promise<void> {
    // Called by sync service after data ingestion
    const revenue = await this.calculateRevenue(companyId);
    const profitability = await this.calculateProfitability(companyId);
    const cash = await this.calculateCash(companyId);
    const efficiency = await this.calculateEfficiency(companyId);
    const operations = await this.calculateOperations(companyId);

    // Upsert all metric snapshots
    await this.upsertMetrics(companyId, [
      ...revenue, ...profitability, ...cash, ...efficiency, ...operations
    ]);
  }

  // ... private calculation methods
}
```

### 6.4 Background Job Architecture (Supabase Edge Functions + pg_cron)

```
┌─────────────────────────────────────────────────────────────────┐
│                    BACKGROUND JOB SYSTEM                         │
│                                                                  │
│  ┌────────────────┐     ┌─────────────────────────────────────┐ │
│  │  pg_cron        │     │  Supabase Edge Functions            │ │
│  │  (Scheduler)    │────▶│                                     │ │
│  │                 │     │  ┌──────────────────────────────┐   │ │
│  │  Daily 2AM:     │     │  │ sync-all-connections         │   │ │
│  │  → sync data    │     │  │ For each active connection:  │   │ │
│  │                 │     │  │   1. Fetch new data from API  │   │ │
│  │  Daily 3AM:     │     │  │   2. Normalize & deduplicate  │   │ │
│  │  → recalculate  │     │  │   3. Store in raw tables      │   │ │
│  │    forecasts    │     │  │   4. Recalculate KPIs          │   │ │
│  │                 │     │  │   5. Update sync_log           │   │ │
│  │  Monday 8AM:    │     │  └──────────────────────────────┘   │ │
│  │  → generate     │     │                                     │ │
│  │    insights     │     │  ┌──────────────────────────────┐   │ │
│  │                 │     │  │ generate-insights             │   │ │
│  │  1st of month:  │     │  │ 1. Gather last 7 days of KPIs │   │ │
│  │  → generate     │     │  │ 2. Build Claude prompt         │   │ │
│  │    reports      │     │  │ 3. Parse structured response   │   │ │
│  │                 │     │  │ 4. Store insight records        │   │ │
│  └────────────────┘     │  │ 5. Queue email digest           │   │ │
│                          │  └──────────────────────────────┘   │ │
│                          │                                     │ │
│  ┌────────────────┐     │  ┌──────────────────────────────┐   │ │
│  │  Webhook Trigger│     │  │ stripe-webhook               │   │ │
│  │  (Event-driven) │────▶│  │ Handles:                     │   │ │
│  │                 │     │  │   checkout.session.completed  │   │ │
│  │  Stripe events  │     │  │   invoice.paid                │   │ │
│  │  Shopify events │     │  │   customer.subscription.*     │   │ │
│  └────────────────┘     │  └──────────────────────────────┘   │ │
│                          └─────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

### 6.5 Job Scheduling (via pg_cron in Supabase)

```sql
-- Daily data sync at 2:00 AM UTC
SELECT cron.schedule(
  'daily-data-sync',
  '0 2 * * *',
  $$SELECT net.http_post(
    url := 'https://<project>.supabase.co/functions/v1/sync-all-connections',
    headers := '{"Authorization": "Bearer <service-role-key>"}'::jsonb
  )$$
);

-- Daily forecast recalculation at 3:00 AM UTC
SELECT cron.schedule(
  'daily-forecast-recalc',
  '0 3 * * *',
  $$SELECT net.http_post(
    url := 'https://<project>.supabase.co/functions/v1/generate-forecast',
    headers := '{"Authorization": "Bearer <service-role-key>"}'::jsonb
  )$$
);

-- Weekly insight generation (Monday 8:00 AM UTC)
SELECT cron.schedule(
  'weekly-insights',
  '0 8 * * 1',
  $$SELECT net.http_post(
    url := 'https://<project>.supabase.co/functions/v1/generate-insights',
    headers := '{"Authorization": "Bearer <service-role-key>"}'::jsonb
  )$$
);

-- Monthly report generation (1st of month, 6:00 AM UTC)
SELECT cron.schedule(
  'monthly-reports',
  '0 6 1 * *',
  $$SELECT net.http_post(
    url := 'https://<project>.supabase.co/functions/v1/generate-report',
    headers := '{"Authorization": "Bearer <service-role-key>"}'::jsonb
  )$$
);
```

---

## 7. Data Integration Architecture

### 7.1 Integration Flow

```
┌──────────────────────────────────────────────────────────────────┐
│                     INTEGRATION PIPELINE                          │
│                                                                   │
│  Step 1: CONNECT                                                  │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  User clicks "Connect Shopify"                           │    │
│  │  → Redirect to Shopify OAuth consent screen              │    │
│  │  → User approves                                         │    │
│  │  → Callback receives authorization code                   │    │
│  │  → Exchange for access_token + refresh_token              │    │
│  │  → Encrypt tokens with AES-256-GCM (per-company key)     │    │
│  │  → Store in connections table                             │    │
│  └──────────────────────────────────────────────────────────┘    │
│                              │                                    │
│  Step 2: INITIAL SYNC        ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Trigger: Immediately after OAuth completion              │    │
│  │  → Fetch last 12 months of historical data                │    │
│  │  → Paginate through API (cursor-based)                    │    │
│  │  → Store raw data in source-specific staging tables       │    │
│  │  → Emit progress via Supabase Realtime channel            │    │
│  │  → On completion: trigger KPI calculation                 │    │
│  └──────────────────────────────────────────────────────────┘    │
│                              │                                    │
│  Step 3: NORMALIZE           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  Map source-specific fields to unified schema:            │    │
│  │                                                           │    │
│  │  Shopify Order → {                                        │    │
│  │    date, gross_revenue, discounts, refunds, net_revenue,  │    │
│  │    cogs, order_count, source: 'shopify'                   │    │
│  │  }                                                        │    │
│  │                                                           │    │
│  │  QBO Transaction → {                                      │    │
│  │    date, account_name, account_type, amount,              │    │
│  │    category, source: 'quickbooks'                         │    │
│  │  }                                                        │    │
│  │                                                           │    │
│  │  Deduplicate: Shopify revenue + Stripe payments           │    │
│  │  (match by order_id or timestamp window)                  │    │
│  └──────────────────────────────────────────────────────────┘    │
│                              │                                    │
│  Step 4: CALCULATE           ▼                                    │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  KPIService.calculateAndStore(companyId)                  │    │
│  │  → Compute all 15 KPIs from normalized data              │    │
│  │  → Store as metric_snapshots (daily granularity)          │    │
│  │  → Trigger forecast recalculation                         │    │
│  └──────────────────────────────────────────────────────────┘    │
│                              │                                    │
│  Step 5: INCREMENTAL SYNC   (Daily cron)                         │
│  ┌──────────────────────────────────────────────────────────┐    │
│  │  → Fetch only data since last_sync_at                     │    │
│  │  → Same normalize → calculate pipeline                    │    │
│  │  → Update last_sync_at in connections table               │    │
│  │  → Log result in sync_logs table                          │    │
│  └──────────────────────────────────────────────────────────┘    │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
```

### 7.2 OAuth Token Management

```typescript
// Token encryption pattern
// src/lib/utils/encryption.ts

import { createCipheriv, createDecipheriv, randomBytes } from "crypto";

const ALGORITHM = "aes-256-gcm";
const MASTER_KEY = Buffer.from(process.env.ENCRYPTION_MASTER_KEY!, "hex"); // 32 bytes

export function encryptToken(plaintext: string): {
  ciphertext: string;
  iv: string;
  authTag: string;
} {
  const iv = randomBytes(16);
  const cipher = createCipheriv(ALGORITHM, MASTER_KEY, iv);
  let ciphertext = cipher.update(plaintext, "utf8", "hex");
  ciphertext += cipher.final("hex");
  return {
    ciphertext,
    iv: iv.toString("hex"),
    authTag: cipher.getAuthTag().toString("hex"),
  };
}

export function decryptToken(encrypted: {
  ciphertext: string;
  iv: string;
  authTag: string;
}): string {
  const decipher = createDecipheriv(
    ALGORITHM,
    MASTER_KEY,
    Buffer.from(encrypted.iv, "hex")
  );
  decipher.setAuthTag(Buffer.from(encrypted.authTag, "hex"));
  let plaintext = decipher.update(encrypted.ciphertext, "hex", "utf8");
  plaintext += decipher.final("utf8");
  return plaintext;
}
```

### 7.3 Real-Time Sync Status (Supabase Realtime)

```typescript
// Client-side sync status listener
// src/hooks/use-realtime-sync.ts

"use client";
import { useEffect, useState } from "react";
import { createBrowserClient } from "@/lib/supabase/client";

export function useRealtimeSyncStatus(connectionId: string) {
  const [status, setStatus] = useState<"idle" | "syncing" | "complete" | "error">("idle");
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const supabase = createBrowserClient();

    const channel = supabase
      .channel(`sync:${connectionId}`)
      .on(
        "postgres_changes",
        {
          event: "UPDATE",
          schema: "public",
          table: "connections",
          filter: `id=eq.${connectionId}`,
        },
        (payload) => {
          setStatus(payload.new.sync_status);
          setProgress(payload.new.sync_progress ?? 0);
        }
      )
      .subscribe();

    return () => { supabase.removeChannel(channel); };
  }, [connectionId]);

  return { status, progress };
}
```

---

## 8. AI & Forecasting Architecture

### 8.1 Claude API Integration

```typescript
// src/lib/ai/claude.ts

import Anthropic from "@anthropic-ai/sdk";
import type { InsightType, GeneratedInsight } from "@/types/metrics";

const anthropic = new Anthropic({
  apiKey: process.env.CLAUDE_API_KEY!,
});

export async function generateFinancialInsights(
  context: {
    companyName: string;
    industry: string;
    revenueRange: string;
    metricsLast30Days: Record<string, number[]>;
    benchmarks: Record<string, { p25: number; p50: number; p75: number }>;
    previousInsights: string[]; // For deduplication
  }
): Promise<GeneratedInsight[]> {
  const response = await anthropic.messages.create({
    model: "claude-sonnet-4-20250514",
    max_tokens: 2000,
    system: FINANCIAL_ANALYST_SYSTEM_PROMPT,
    messages: [
      {
        role: "user",
        content: buildInsightPrompt(context),
      },
    ],
  });

  // Parse structured response
  return parseInsightResponse(response.content[0].text);
}

const FINANCIAL_ANALYST_SYSTEM_PROMPT = `You are a senior financial analyst 
specializing in DTC/e-commerce brands. You analyze financial data and produce 
actionable insights. 

Rules:
- Always reference specific numbers from the data provided
- Never give generic advice like "consider cutting costs"
- Each insight must be actionable with a clear next step
- Use a friendly, jargon-light tone (like a helpful CFO)
- Never provide tax, legal, or investment advice
- Respond in JSON format with the specified schema
- Generate exactly 3-5 insights per analysis
- Categorize each as: anomaly, trend, benchmark, predictive, or opportunity
- Include a confidence level: high or medium`;
```

### 8.2 Prompt Templates

```typescript
// src/lib/ai/prompts/anomaly.ts

export function buildAnomalyPrompt(metrics: MetricsContext): string {
  return `
Analyze these financial metrics for ${metrics.companyName}, a ${metrics.industry} 
DTC brand doing ${metrics.revenueRange} in annual revenue.

## Last 30 Days — Daily Metrics
${JSON.stringify(metrics.metricsLast30Days, null, 2)}

## Industry Benchmarks (${metrics.industry}, ${metrics.revenueRange})
${JSON.stringify(metrics.benchmarks, null, 2)}

## Previously Generated Insights (avoid repeating)
${metrics.previousInsights.join("\n")}

## Task
Identify anomalies, trends, benchmark deviations, predictive warnings, 
and opportunities. Return JSON:

{
  "insights": [
    {
      "type": "anomaly" | "trend" | "benchmark" | "predictive" | "opportunity",
      "title": "Short headline (max 80 chars)",
      "body": "2-3 sentence explanation with specific numbers",
      "metric": "The primary KPI this relates to",
      "confidence": "high" | "medium",
      "action": "One concrete recommended action"
    }
  ]
}`;
}
```

### 8.3 Forecasting Engine

```typescript
// src/lib/services/forecast.service.ts

export class ForecastService {
  constructor(private supabase: SupabaseClient<Database>) {}

  async generateForecast(companyId: string): Promise<ForecastResult> {
    // 1. Fetch historical data
    const historicalCashFlow = await this.getHistoricalCashFlow(companyId, 180); // 6 months
    const overrides = await this.getActiveOverrides(companyId);

    // 2. Decompose time series
    const { trend, seasonality, residual } = this.decompose(historicalCashFlow);

    // 3. Project forward 13 weeks
    const baseCase = this.projectForward(trend, seasonality, 13);
    const bestCase = this.projectScenario(baseCase, "optimistic", residual);
    const worstCase = this.projectScenario(baseCase, "pessimistic", residual);

    // 4. Apply manual overrides
    const adjustedBase = this.applyOverrides(baseCase, overrides);
    const adjustedBest = this.applyOverrides(bestCase, overrides);
    const adjustedWorst = this.applyOverrides(worstCase, overrides);

    // 5. Calculate confidence bands (80% CI)
    const confidenceBands = this.calculateConfidenceBands(
      adjustedBase, residual, 0.80
    );

    // 6. Calculate summary metrics
    const currentCash = historicalCashFlow[historicalCashFlow.length - 1].balance;
    const avgBurn = this.calculateAvgMonthlyBurn(historicalCashFlow, 3);
    const runway = avgBurn > 0 ? currentCash / avgBurn : Infinity;

    // 7. Store forecast
    await this.storeForecast(companyId, {
      weeks: adjustedBase.map((week, i) => ({
        weekStart: week.date,
        baseCase: adjustedBase[i].value,
        bestCase: adjustedBest[i].value,
        worstCase: adjustedWorst[i].value,
        confidenceLower: confidenceBands[i].lower,
        confidenceUpper: confidenceBands[i].upper,
      })),
      summary: { currentCash, avgBurn, runway },
    });

    return { weeks: adjustedBase, summary: { currentCash, avgBurn, runway } };
  }

  private decompose(data: TimeSeriesPoint[]): Decomposition {
    // STL-like decomposition:
    // 1. Extract trend via moving average (window = 4 weeks)
    // 2. Detrend, then extract weekly seasonality pattern
    // 3. Residual = original - trend - seasonality
    // ...
  }

  private projectScenario(
    base: TimeSeriesPoint[],
    type: "optimistic" | "pessimistic",
    residual: number[]
  ): TimeSeriesPoint[] {
    const stdDev = this.standardDeviation(residual);
    const multiplier = type === "optimistic" ? 1.28 : -1.28; // ~80th / 20th percentile
    return base.map((point) => ({
      ...point,
      value: point.value + multiplier * stdDev,
    }));
  }
}
```

---

## 9. Authentication & Authorization

### 9.1 Auth Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   AUTHENTICATION FLOW                        │
│                                                              │
│  ┌─────────┐     ┌─────────────┐     ┌──────────────────┐  │
│  │ Browser │     │ Next.js     │     │ Supabase Auth    │  │
│  │         │     │ Middleware  │     │                  │  │
│  └────┬────┘     └──────┬──────┘     └────────┬─────────┘  │
│       │                 │                      │            │
│       │  GET /dashboard │                      │            │
│       │────────────────►│                      │            │
│       │                 │  Verify JWT cookie   │            │
│       │                 │─────────────────────►│            │
│       │                 │                      │            │
│       │                 │  ✅ Valid / ❌ Invalid │            │
│       │                 │◄─────────────────────│            │
│       │                 │                      │            │
│       │  If invalid:    │                      │            │
│       │  Redirect /login│                      │            │
│       │◄────────────────│                      │            │
│       │                 │                      │            │
│       │  If valid:      │                      │            │
│       │  Render page    │                      │            │
│       │◄────────────────│                      │            │
│       │                 │                      │            │
└───────┴─────────────────┴──────────────────────┴────────────┘
```

### 9.2 Middleware Configuration

```typescript
// src/middleware.ts

import { createServerClient } from "@supabase/ssr";
import { NextResponse, type NextRequest } from "next/server";

const PUBLIC_PATHS = ["/", "/pricing", "/tools", "/login", "/signup", "/forgot-password"];
const AUTH_PATHS = ["/login", "/signup", "/forgot-password"];

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll: () => request.cookies.getAll(),
        setAll: (cookies) => {
          cookies.forEach(({ name, value, options }) => {
            response.cookies.set(name, value, options);
          });
        },
      },
    }
  );

  const { data: { user } } = await supabase.auth.getUser();
  const pathname = request.nextUrl.pathname;

  // Redirect authenticated users away from auth pages
  if (user && AUTH_PATHS.some((p) => pathname.startsWith(p))) {
    return NextResponse.redirect(new URL("/dashboard", request.url));
  }

  // Redirect unauthenticated users to login
  if (!user && !PUBLIC_PATHS.some((p) => pathname === p || pathname.startsWith("/tools"))) {
    return NextResponse.redirect(new URL("/login", request.url));
  }

  return response;
}

export const config = {
  matcher: ["/((?!_next/static|_next/image|favicon.ico|api/webhooks).*)"],
};
```

### 9.3 Row-Level Security (RLS)

```sql
-- Every table has RLS enabled. Users can only access their own company's data.

-- Pattern: user → company → resource
-- All queries are automatically scoped by Supabase RLS.

-- Helper function: get company IDs for current user
CREATE OR REPLACE FUNCTION get_user_company_ids()
RETURNS SETOF uuid AS $$
  SELECT id FROM companies WHERE owner_id = auth.uid()
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Example RLS policy on metric_snapshots
ALTER TABLE metric_snapshots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own company metrics"
  ON metric_snapshots FOR SELECT
  USING (company_id IN (SELECT get_user_company_ids()));

CREATE POLICY "System can insert metrics"
  ON metric_snapshots FOR INSERT
  WITH CHECK (company_id IN (SELECT get_user_company_ids()));
```

---

## 10. Billing & Subscription Architecture

### 10.1 Stripe Integration Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SUBSCRIPTION LIFECYCLE                             │
│                                                                      │
│  TRIAL START                                                         │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │ User signs up → Supabase creates user → We create Stripe      │   │
│  │ Customer → Store stripe_customer_id in profiles table         │   │
│  │ → Set subscription_status = 'trialing'                        │   │
│  │ → Set trial_ends_at = now() + 14 days                         │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                           │                                          │
│  CHECKOUT                 ▼                                          │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │ User clicks "Upgrade" → POST /api/v1/billing/checkout         │   │
│  │ → Create Stripe Checkout Session with:                        │   │
│  │   • price_id (from plan selection)                            │   │
│  │   • customer (stripe_customer_id)                             │   │
│  │   • trial_end (if still in trial)                             │   │
│  │   • success_url, cancel_url                                   │   │
│  │ → Redirect to Stripe Checkout                                 │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                           │                                          │
│  WEBHOOK: checkout.session.completed                                 │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │ → Update profiles: subscription_status = 'active'             │   │
│  │ → Store subscription_id, current_plan, period_end              │   │
│  │ → Unlock plan-gated features                                  │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                           │                                          │
│  WEBHOOK: invoice.paid (recurring)                                   │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │ → Extend period_end date                                      │   │
│  │ → Log invoice in billing_events table                         │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                           │                                          │
│  WEBHOOK: customer.subscription.deleted                              │
│  ┌───────────────────────────────────────────────────────────────┐   │
│  │ → Set subscription_status = 'canceled'                        │   │
│  │ → Dashboard becomes read-only after period_end                │   │
│  └───────────────────────────────────────────────────────────────┘   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 10.2 Plan Configuration

```typescript
// src/lib/stripe/plans.ts

export const PLANS = {
  starter: {
    name: "Starter",
    stripePriceIdMonthly: process.env.STRIPE_STARTER_MONTHLY_PRICE_ID!,
    stripePriceIdAnnual: process.env.STRIPE_STARTER_ANNUAL_PRICE_ID!,
    priceMonthly: 99,
    priceAnnual: 79,
    limits: {
      integrations: 2,
      kpiCount: 15,
      forecastMonths: 3,
      forecastScenarios: false,
      benchmarkLevel: "broad",
      users: 1,
      dataHistoryMonths: 12,
      reportTypes: ["monthly_snapshot"],
      csvExport: true,
      revenueForecasting: false,
      customKpis: false,
    },
  },
  growth: {
    name: "Growth",
    stripePriceIdMonthly: process.env.STRIPE_GROWTH_MONTHLY_PRICE_ID!,
    stripePriceIdAnnual: process.env.STRIPE_GROWTH_ANNUAL_PRICE_ID!,
    priceMonthly: 299,
    priceAnnual: 249,
    limits: {
      integrations: 5,
      kpiCount: 40,
      forecastMonths: 12,
      forecastScenarios: true,
      benchmarkLevel: "subcategory",
      users: 3,
      dataHistoryMonths: 24,
      reportTypes: ["monthly_snapshot", "investor_deck"],
      csvExport: true,
      revenueForecasting: true,
      customKpis: false,
    },
  },
  scale: {
    name: "Scale",
    stripePriceIdMonthly: process.env.STRIPE_SCALE_MONTHLY_PRICE_ID!,
    stripePriceIdAnnual: process.env.STRIPE_SCALE_ANNUAL_PRICE_ID!,
    priceMonthly: 699,
    priceAnnual: 599,
    limits: {
      integrations: Infinity,
      kpiCount: Infinity,
      forecastMonths: 24,
      forecastScenarios: true,
      benchmarkLevel: "custom_peer",
      users: 10,
      dataHistoryMonths: Infinity,
      reportTypes: ["monthly_snapshot", "investor_deck", "board_pack"],
      csvExport: true,
      revenueForecasting: true,
      customKpis: true,
    },
  },
} as const;

export type PlanId = keyof typeof PLANS;
```

### 10.3 Feature Gating Middleware

```typescript
// src/lib/services/plan-gate.ts

import { PLANS, type PlanId } from "@/lib/stripe/plans";

export function checkPlanAccess(
  userPlan: PlanId,
  feature: string,
  value?: number
): { allowed: boolean; upgradeRequired?: PlanId } {
  const limits = PLANS[userPlan].limits;

  switch (feature) {
    case "integrations":
      if (value && value > limits.integrations) {
        return { allowed: false, upgradeRequired: "growth" };
      }
      return { allowed: true };

    case "revenue_forecasting":
      if (!limits.revenueForecasting) {
        return { allowed: false, upgradeRequired: "growth" };
      }
      return { allowed: true };

    case "custom_kpis":
      if (!limits.customKpis) {
        return { allowed: false, upgradeRequired: "scale" };
      }
      return { allowed: true };

    // ... more feature checks
    default:
      return { allowed: true };
  }
}
```

---

## 11. Infrastructure & Deployment

### 11.1 Deployment Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                     DEPLOYMENT TOPOLOGY                               │
│                                                                       │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │                        VERCEL                                  │   │
│  │                                                                │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌──────────────────────┐  │   │
│  │  │ Edge Network│  │ Serverless   │  │ Static Assets        │  │   │
│  │  │ (CDN)       │  │ Functions    │  │ (ISR / SSG pages)    │  │   │
│  │  │             │  │ (API Routes) │  │                      │  │   │
│  │  │ 30+ regions │  │ Auto-scaling │  │ Landing, Pricing,    │  │   │
│  │  │             │  │ 0 → ∞       │  │ Free Tools           │  │   │
│  │  └─────────────┘  └──────────────┘  └──────────────────────┘  │   │
│  │                                                                │   │
│  │  Environments:                                                 │   │
│  │  ├── Production  (main branch)     → app.financialintelai.com │   │
│  │  ├── Preview     (PR branches)     → pr-123.vercel.app        │   │
│  │  └── Development (dev branch)      → dev.financialintelai.com │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                              │                                        │
│                              │ Connects to                            │
│                              ▼                                        │
│  ┌────────────────────────────────────────────────────────────────┐   │
│  │                       SUPABASE                                 │   │
│  │                                                                │   │
│  │  Region: us-east-1 (closest to majority of DTC brands)        │   │
│  │                                                                │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │   │
│  │  │ PostgreSQL   │  │ Auth         │  │ Edge Functions       │ │   │
│  │  │ (Dedicated)  │  │ (GoTrue)     │  │ (Deno Deploy)       │ │   │
│  │  │              │  │              │  │                      │ │   │
│  │  │ • 4 vCPU     │  │ • Email/Pass │  │ • Webhook handlers  │ │   │
│  │  │ • 8GB RAM    │  │ • Google     │  │ • Cron jobs          │ │   │
│  │  │ • 100GB SSD  │  │ • Magic Link │  │ • Background syncs   │ │   │
│  │  │ • PITR backup│  │              │  │                      │ │   │
│  │  └──────────────┘  └──────────────┘  └──────────────────────┘ │   │
│  │                                                                │   │
│  │  ┌──────────────┐  ┌──────────────┐                           │   │
│  │  │ Storage      │  │ Realtime     │                           │   │
│  │  │ (S3-compat)  │  │ (WebSocket)  │                           │   │
│  │  │              │  │              │                           │   │
│  │  │ • PDF reports│  │ • Sync status│                           │   │
│  │  │ • Avatars    │  │ • Live alerts│                           │   │
│  │  └──────────────┘  └──────────────┘                           │   │
│  └────────────────────────────────────────────────────────────────┘   │
│                                                                       │
└──────────────────────────────────────────────────────────────────────┘
```

### 11.2 CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main, dev]
  push:
    branches: [main]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: pnpm run typecheck          # tsc --noEmit
      - run: pnpm run lint                # biome check
      - run: pnpm run test:unit           # vitest
      - run: pnpm run test:integration    # vitest (integration suite)

  e2e:
    runs-on: ubuntu-latest
    needs: quality
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: pnpm
      - run: pnpm install --frozen-lockfile
      - run: npx playwright install --with-deps
      - run: pnpm run test:e2e            # playwright

  deploy-preview:
    if: github.event_name == 'pull_request'
    needs: quality
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
```

### 11.3 Environment Variables

```bash
# .env.local.example

# ── Supabase ──
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOi...           # Server-only, never exposed to client

# ── Stripe ──
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_STARTER_MONTHLY_PRICE_ID=price_...
STRIPE_STARTER_ANNUAL_PRICE_ID=price_...
STRIPE_GROWTH_MONTHLY_PRICE_ID=price_...
STRIPE_GROWTH_ANNUAL_PRICE_ID=price_...
STRIPE_SCALE_MONTHLY_PRICE_ID=price_...
STRIPE_SCALE_ANNUAL_PRICE_ID=price_...

# ── Claude API (Anthropic) ──
CLAUDE_API_KEY=sk-ant-...

# ── Integrations ──
SHOPIFY_CLIENT_ID=...
SHOPIFY_CLIENT_SECRET=...
QUICKBOOKS_CLIENT_ID=...
QUICKBOOKS_CLIENT_SECRET=...
STRIPE_CONNECT_CLIENT_ID=ca_...

# ── Email ──
RESEND_API_KEY=re_...
EMAIL_FROM=insights@financialintelai.com

# ── Security ──
ENCRYPTION_MASTER_KEY=...                          # 64-char hex (256-bit AES key)

# ── App ──
NEXT_PUBLIC_APP_URL=https://app.financialintelai.com

# ── Monitoring ──
SENTRY_DSN=https://...@sentry.io/...
NEXT_PUBLIC_POSTHOG_KEY=phc_...
NEXT_PUBLIC_POSTHOG_HOST=https://us.i.posthog.com
```

---

## 12. Security Architecture

### 12.1 Security Layers

```
┌─────────────────────────────────────────────────────────────────┐
│                     SECURITY IN DEPTH                            │
│                                                                  │
│  Layer 1: NETWORK                                                │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • TLS 1.3 everywhere (Vercel + Supabase enforce)         │   │
│  │ • HSTS headers (max-age=31536000, includeSubDomains)     │   │
│  │ • CSP headers (script-src 'self', style-src 'self')      │   │
│  │ • Rate limiting: 100 req/min per IP (Vercel Edge)        │   │
│  │ • DDoS protection (Vercel built-in)                      │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Layer 2: AUTHENTICATION                                         │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Supabase Auth (GoTrue) — battle-tested                 │   │
│  │ • JWT stored in httpOnly, Secure, SameSite=Lax cookies   │   │
│  │ • Refresh token rotation                                  │   │
│  │ • Brute-force protection: 5 attempts → 15 min lockout    │   │
│  │ • Email verification required                             │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Layer 3: AUTHORIZATION                                          │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Row-Level Security (RLS) on EVERY table                │   │
│  │ • All queries scoped to user's company_id                │   │
│  │ • API routes verify auth before any data access          │   │
│  │ • Stripe webhook signature verification                  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Layer 4: DATA PROTECTION                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • OAuth tokens encrypted at rest (AES-256-GCM)           │   │
│  │ • Database encrypted at rest (Supabase managed)          │   │
│  │ • Secrets in environment variables (never in code)       │   │
│  │ • Financial data never logged                             │   │
│  │ • PII redacted in error reports (Sentry)                 │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  Layer 5: APPLICATION                                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │ • Zod validation on all API inputs                       │   │
│  │ • Parameterized queries (Supabase client prevents SQLi)  │   │
│  │ • XSS prevention (React auto-escaping + CSP)             │   │
│  │ • CSRF protection (SameSite cookies + origin checking)   │   │
│  │ • Dependency scanning (GitHub Dependabot)                │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 13. Monitoring & Observability

### 13.1 Monitoring Stack

| Layer | Tool | What It Monitors |
|---|---|---|
| **Error Tracking** | Sentry | Unhandled exceptions, API errors, React error boundaries |
| **Product Analytics** | PostHog | User events, feature adoption, funnel conversion, session replays |
| **Uptime** | Vercel / BetterUptime | Endpoint health, response times, SSL expiry |
| **Database** | Supabase Dashboard | Query performance, connection pool, storage usage |
| **Logs** | Vercel Logs + Supabase Logs | API request logs, Edge Function logs, cron job output |
| **Business Metrics** | Internal admin dashboard | MRR, churn, active users, sync success rate |

### 13.2 Key Alerts

| Alert | Trigger | Channel | Severity |
|---|---|---|---|
| API Error Rate > 5% | 5-minute window | Slack + PagerDuty | 🔴 Critical |
| Data Sync Failure | Any sync fails 3x consecutively | Slack | 🟡 Warning |
| P95 Latency > 2s | 5-minute window | Slack | 🟡 Warning |
| Database CPU > 80% | 10-minute sustained | Slack + PagerDuty | 🔴 Critical |
| Stripe Webhook Failure | Any delivery failure | Slack | 🟡 Warning |
| User Signup Spike > 3x | Compared to 7-day average | Slack | 🔵 Info |

---

## 14. Performance Architecture

### 14.1 Caching Strategy

| Data | Cache Layer | TTL | Invalidation |
|---|---|---|---|
| **KPI metrics** | React Query (client) | 5 minutes | Manual refresh, window focus |
| **Benchmark data** | React Query (client) + ISR | 24 hours | Quarterly update |
| **Forecast** | React Query (client) | 1 hour | After sync, after override change |
| **AI Insights** | React Query (client) | 24 hours | After new insights generated |
| **Company profile** | React Query (client) | 30 minutes | After profile update |
| **Static pages** | Vercel CDN (ISR) | 1 hour | On deploy |
| **API responses** | Vercel Edge Cache | 60 seconds (stale-while-revalidate) | Cache-Control headers |

### 14.2 Database Optimization

```sql
-- Critical indexes for dashboard performance

-- Metric lookups (most frequent query)
CREATE INDEX idx_metric_snapshots_company_date
  ON metric_snapshots (company_id, period_date DESC);

CREATE INDEX idx_metric_snapshots_company_metric_date
  ON metric_snapshots (company_id, metric_name, period_date DESC);

-- Forecast lookups
CREATE INDEX idx_forecasts_company_date
  ON forecasts (company_id, forecast_date DESC);

-- Insight lookups
CREATE INDEX idx_insights_company_created
  ON insights (company_id, created_at DESC)
  WHERE NOT is_dismissed;

-- Connection sync queries
CREATE INDEX idx_connections_company_status
  ON connections (company_id, status);

-- Benchmark lookups
CREATE INDEX idx_benchmarks_category_range
  ON industry_benchmarks (industry_category, revenue_range, metric_name);
```

### 14.3 Performance Budgets

| Metric | Budget | Measurement |
|---|---|---|
| **First Contentful Paint** | ≤ 1.2s | Lighthouse CI |
| **Largest Contentful Paint** | ≤ 2.0s | Lighthouse CI |
| **Time to Interactive** | ≤ 2.5s | Lighthouse CI |
| **Cumulative Layout Shift** | ≤ 0.1 | Lighthouse CI |
| **Total JS Bundle** | ≤ 250 KB (gzipped) | Bundle analyzer |
| **Dashboard API (p95)** | ≤ 400ms | Sentry performance |
| **Chart render** | ≤ 500ms | Custom performance mark |

---

## 15. API Design

### 15.1 Response Format

```typescript
// Standard success response
{
  "data": { ... },
  "meta": {
    "timestamp": "2026-06-07T10:30:00Z",
    "requestId": "req_abc123"
  }
}

// Standard error response
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid time range parameter",
    "details": [
      { "field": "timeRange", "message": "Must be one of: 1m, 3m, 6m, 12m, custom" }
    ]
  },
  "meta": {
    "timestamp": "2026-06-07T10:30:00Z",
    "requestId": "req_abc123"
  }
}

// Paginated list response
{
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 47,
    "totalPages": 3
  },
  "meta": { ... }
}
```

### 15.2 Error Codes

| HTTP Status | Error Code | Description |
|---|---|---|
| 400 | `VALIDATION_ERROR` | Request body/params failed Zod validation |
| 401 | `UNAUTHORIZED` | Missing or invalid JWT |
| 403 | `FORBIDDEN` | Valid JWT but insufficient permissions (wrong company) |
| 403 | `PLAN_LIMIT_EXCEEDED` | Feature requires a higher plan |
| 404 | `NOT_FOUND` | Resource doesn't exist |
| 409 | `CONFLICT` | Duplicate resource (e.g., integration already connected) |
| 429 | `RATE_LIMITED` | Too many requests |
| 500 | `INTERNAL_ERROR` | Unexpected server error |
| 502 | `INTEGRATION_ERROR` | Third-party API failure (Shopify, QBO, etc.) |
| 503 | `SERVICE_UNAVAILABLE` | Temporary outage |

---

> *Architecture designed for a team of 2–4 engineers building an MVP in 21 days, scaling to $2M ARR.*
