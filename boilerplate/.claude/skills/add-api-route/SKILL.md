---
name: add-api-route
description: >
  Use this skill when adding a new Express API route.
  Covers file structure, Zod validation, auth middleware,
  error handling, and test setup.
---

# Adding an Express API route

## Steps

### 1. Define Zod schemas first
In `src/server/schemas/[resource].ts`:
```ts
import { z } from "zod";

export const CreateResourceSchema = z.object({
  name: z.string().min(1).max(255),
  // add fields
});

export type CreateResourceInput = z.infer<typeof CreateResourceSchema>;
```

### 2. Create the route handler
In `src/server/routes/[resource].ts`:
```ts
import { Router } from "express";
import { z } from "zod";
import { asyncHandler } from "@/lib/async-handler";
import { requireAuth } from "@/lib/auth";
import { CreateResourceSchema } from "@/server/schemas/[resource]";
import { db } from "@/db";

export const resourceRouter = Router();

resourceRouter.post(
  "/",
  requireAuth,
  asyncHandler(async (req, res) => {
    const input = CreateResourceSchema.parse(req.body);

    const result = await db.resource.create({ data: input });

    res.status(201).json({ data: result });
  })
);
```

### 3. Register the router
In `src/server/app.ts`:
```ts
import { resourceRouter } from "./routes/resource";
app.use("/api/resources", resourceRouter);
```

### 4. Write integration tests
```ts
describe("POST /api/resources", () => {
  it("creates resource with valid input", async () => { ... });
  it("returns 400 for invalid input", async () => { ... });
  it("returns 401 when unauthenticated", async () => { ... });
});
```

### 5. Checklist
- [ ] Input validated with Zod before any DB call
- [ ] Auth middleware applied to protected routes
- [ ] asyncHandler wrapper used (handles async errors)
- [ ] Response excludes sensitive fields
- [ ] Tests cover happy path + error cases
