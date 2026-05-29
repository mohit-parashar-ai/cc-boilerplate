---
name: create-trpc-router
description: >
  Use this skill when adding a new tRPC router and its procedures to NexTask.
  Covers schema definition, router file, merging into the app router, and
  client-side usage patterns.
---

# Creating a tRPC router

## Step 1 — Define Zod schemas in packages/db
```bash
# File: packages/db/src/schemas/[resource].ts
```
```typescript
import { z } from "zod";

export const CreateResourceSchema = z.object({
  name: z.string().min(1).max(255),
  description: z.string().optional(),
});

export const UpdateResourceSchema = CreateResourceSchema.partial().extend({
  id: z.string().cuid(),
});

export type CreateResourceInput = z.infer<typeof CreateResourceSchema>;
export type UpdateResourceInput = z.infer<typeof UpdateResourceSchema>;
```

Export from `packages/db/src/schemas/index.ts`.

## Step 2 — Create the router file
```bash
# File: apps/web/src/server/routers/[resource].ts
```
```typescript
import { z } from "zod";
import { createTRPCRouter, workspaceProcedure } from "@/server/trpc";
import { CreateResourceSchema, UpdateResourceSchema } from "@nexttask/db/schemas";
import { TRPCError } from "@trpc/server";

export const resourceRouter = createTRPCRouter({
  list: workspaceProcedure.query(async ({ ctx }) => {
    return ctx.db.resource.findMany({
      where: { workspaceId: ctx.workspace.id, deletedAt: null },
      orderBy: { createdAt: "desc" },
    });
  }),

  byId: workspaceProcedure
    .input(z.object({ id: z.string().cuid() }))
    .query(async ({ ctx, input }) => {
      const resource = await ctx.db.resource.findFirst({
        where: { id: input.id, workspaceId: ctx.workspace.id, deletedAt: null },
      });
      if (!resource) throw new TRPCError({ code: "NOT_FOUND" });
      return resource;
    }),

  create: workspaceProcedure
    .input(CreateResourceSchema)
    .mutation(async ({ ctx, input }) => {
      return ctx.db.resource.create({
        data: { ...input, workspaceId: ctx.workspace.id },
      });
    }),

  update: workspaceProcedure
    .input(UpdateResourceSchema)
    .mutation(async ({ ctx, input }) => {
      const { id, ...data } = input;
      await ctx.db.resource.findFirstOrThrow({
        where: { id, workspaceId: ctx.workspace.id },
      });
      return ctx.db.resource.update({ where: { id }, data });
    }),

  delete: workspaceProcedure
    .input(z.object({ id: z.string().cuid() }))
    .mutation(async ({ ctx, input }) => {
      await ctx.db.resource.findFirstOrThrow({
        where: { id: input.id, workspaceId: ctx.workspace.id },
      });
      // Soft delete
      return ctx.db.resource.update({
        where: { id: input.id },
        data: { deletedAt: new Date() },
      });
    }),
});
```

## Step 3 — Merge into the app router
In `apps/web/src/server/routers/_app.ts`:
```typescript
import { resourceRouter } from "./resource";

export const appRouter = createTRPCRouter({
  // ... existing routers
  resource: resourceRouter,
});
```

## Step 4 — Use on the client
```typescript
// Server component
const resources = await api.resource.list();

// Client component
const { data, isLoading } = api.resource.list.useQuery();

const createMutation = api.resource.create.useMutation({
  onSuccess: () => {
    utils.resource.list.invalidate();
    toast.success("Created!");
  },
});
```

## Checklist
- [ ] Schemas defined in `packages/db/src/schemas/`
- [ ] All queries include `workspaceId` filter
- [ ] All queries include `deletedAt: null`
- [ ] Delete uses soft delete (`deletedAt: new Date()`)
- [ ] Router merged in `_app.ts`
- [ ] Integration tests written
- [ ] `pnpm typecheck` passes
