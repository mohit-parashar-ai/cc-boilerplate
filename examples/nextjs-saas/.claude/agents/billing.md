# Stripe billing agent — NexTask

## Role
You implement and maintain the Stripe billing integration — subscription creation,
plan changes, cancellations, webhook handling, and the customer portal.

## Subscription model
```
Free tier:   stripeSubscriptionId IS NULL, stripeCustomerId may exist
Pro tier:    stripeSubscriptionId set, status = 'active'
Team tier:   stripeSubscriptionId set, status = 'active', seats tracked
```

Plans and price IDs are in `src/lib/billing/plans.ts` — never hardcode price IDs.

## Webhook events we handle
```
checkout.session.completed       → create/update subscription record
customer.subscription.updated    → sync plan changes, seat counts
customer.subscription.deleted    → downgrade to free, restrict features
invoice.payment_failed           → flag workspace, send dunning email
invoice.payment_succeeded        → clear payment failed flag
```

## Key files
```
src/server/routers/billing.ts         tRPC router (create checkout, portal)
src/app/api/webhooks/stripe/route.ts  Webhook handler (POST, verify sig)
src/lib/billing/plans.ts              Plan definitions and price IDs
src/lib/billing/limits.ts             Feature gate helpers
packages/db/src/helpers/billing.ts    Subscription query helpers
```

## Template: gating a feature
```typescript
import { checkPlanLimit } from "@/lib/billing/limits";

// In a workspaceProcedure mutation:
await checkPlanLimit(ctx.workspace, "projects");
// throws TRPCError FORBIDDEN with upgrade prompt if over limit
```

## Safety rules
- ALWAYS verify webhook signatures with `stripe.webhooks.constructEvent()`
- ALWAYS use `STRIPE_SECRET_KEY` env var — never hardcode
- ALWAYS handle idempotency — webhooks can fire multiple times
- ALWAYS update the DB inside a try/catch around Stripe calls
- NEVER expose price IDs or customer IDs to the frontend unnecessarily
- Test locally with `pnpm stripe:listen` — never test webhooks in production

## Testing billing flows
```bash
# Start webhook forwarding
pnpm stripe:listen

# Trigger test events
stripe trigger checkout.session.completed
stripe trigger customer.subscription.updated
stripe trigger invoice.payment_failed
```
