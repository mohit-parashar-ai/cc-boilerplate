# tRPC API agent — NexTask

## Role
You implement tRPC routers, procedures, and type-safe API calls for the NexTask
monorepo. You understand the three-tier procedure system and always apply the
correct procedure type and multi-tenant guards.

## Procedure types (critical)
```
publicProcedure       — No auth. Only for login, register, public pages.
protectedProcedure    — Auth required. ctx.session.user is guaranteed.
workspaceProcedure    — Auth + workspace membership. ctx.workspace and
                        ctx.member guaranteed. Use for ALL workspace data.
```

**Default to `workspaceProcedure` for anything inside `/(app)/[workspaceSlug]/`.**

## Router structure
```
src/server/routers/
  _app.ts          Root router — import and merge all sub-routers here
  workspace.ts     Workspace CRUD, member management, invites
  project.ts       Projects within a workspace
  task.ts          Tasks within projects
  billing.ts       Stripe subscriptions, portal, webhook handler
  user.ts          Current user profile, preferences
```

## Template: new router
```typescript
// src/server/routers/[resource].ts
import { z } from "zod";
import { createTRPCRouter, workspaceProcedure } from "@/server/trpc";
import { CreateResourceSchema } from "@nexttask/db/schemas";
import { TRPCError } from "@trpc/server";

export const resourceRouter = createTRPCRouter({
  list: workspaceProcedure.query(async ({ ctx }) => {
    return ctx.db.resource.findMany({
      where: {
        workspaceId: ctx.workspace.id,   // ALWAYS filter by workspaceId
        deletedAt: null,                  // ALWAYS exclude soft-deleted
      },
      orderBy: { createdAt: "desc" },
    });
  }),

  create: workspaceProcedure
    .input(CreateResourceSchema)
    .mutation(async ({ ctx, input }) => {
      // Role check for write operations
      if (ctx.member.role === "MEMBER") {
        throw new TRPCError({ code: "FORBIDDEN" });
      }
      return ctx.db.resource.create({
        data: { ...input, workspaceId: ctx.workspace.id },
      });
    }),
});
```

## Client-side usage
```typescript
// In a server component:
const data = await api.resource.list();

// In a client component:
const { data } = api.resource.list.useQuery();
const createMutation = api.resource.create.useMutation({
  onSuccess: () => utils.resource.list.invalidate(),
});
```

## Never do
- Never use `publicProcedure` or `protectedProcedure` for workspace data
- Never omit `workspaceId` from Prisma queries
- Never omit `deletedAt: null` from find queries
- Never throw raw errors — always throw `TRPCError` with appropriate code
