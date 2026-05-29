# Feature spec: Stripe billing — subscription tiers

> Status: In Progress
> Author: Mohit Parshar
> Created: 2025-05-22

## Overview
Add paid subscription tiers (Free / Pro / Team) to NexTask using Stripe.
Workspaces on the Free tier are limited to 3 projects and 1 member.
Pro unlocks unlimited projects and up to 10 members. Team adds SSO and audit logs.

## User stories
- As a workspace owner, I want to upgrade my plan so my team can create more projects.
- As a workspace owner, I want to manage my subscription from the settings page.
- As a workspace member, I want to see a clear upgrade prompt when we hit a plan limit.
- As a workspace owner, I want to cancel my subscription and retain access until period end.

## Acceptance criteria
- [ ] Workspace settings page has a `/billing` tab
- [ ] Current plan and next billing date are displayed
- [ ] Upgrade/downgrade buttons open Stripe Checkout or the Customer Portal
- [ ] Creating a 4th project on Free tier shows an upgrade modal, not an error
- [ ] Webhook handler processes all 5 events (see billing agent)
- [ ] Failed payment flags the workspace and sends a dunning email via Resend
- [ ] Cancellation retains Pro access until `current_period_end`
- [ ] Plan limits are enforced server-side in tRPC procedures (not just UI)

## Technical approach

### Schema changes
```prisma
model Workspace {
  // Add these fields:
  stripeCustomerId       String?  @unique
  stripeSubscriptionId   String?  @unique
  stripePriceId          String?
  stripeCurrentPeriodEnd DateTime?
  paymentFailed          Boolean  @default(false)
  plan                   Plan     @default(FREE)
}

enum Plan {
  FREE
  PRO
  TEAM
}
```

### API changes
| Method | Procedure | Auth | Description |
|--------|-----------|------|-------------|
| tRPC mutation | `billing.createCheckoutSession` | workspace | Create Stripe Checkout for upgrade |
| tRPC mutation | `billing.createPortalSession` | workspace | Open Customer Portal |
| tRPC query | `billing.subscription` | workspace | Get current plan + limits |
| POST | `/api/webhooks/stripe` | Stripe sig | Handle subscription events |

### Component changes
- `BillingPage` — new page at `(app)/settings/billing/page.tsx`
- `PlanCard` — displays current plan, usage, and upgrade CTA
- `UpgradeModal` — shown when a feature gate is hit
- `checkPlanLimit()` — server util called in tRPC mutations before writes

## Out of scope
- Annual billing (monthly only for v1)
- Per-seat billing (flat rate per plan for v1)
- Invoice history UI (Stripe Portal handles this)

## Open questions
- [ ] Do we prorate downgrades immediately or at period end? (leaning: period end)
- [ ] Should Team plan require SSO to be configured, or just unlock it?
