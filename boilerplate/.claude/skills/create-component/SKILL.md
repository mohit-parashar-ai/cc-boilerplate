---
name: create-component
description: >
  Use this skill when creating a new React component from scratch.
  Covers file structure, TypeScript props interface, accessibility,
  Tailwind styling, and test scaffolding.
---

# Creating a React component

## Steps

### 1. Check if it already exists
```bash
find src/components -name "*.tsx" | xargs grep -l "ComponentName" 2>/dev/null
```

### 2. Create the component file
Location: `src/components/[ComponentName]/index.tsx`

```tsx
import { cn } from "@/lib/utils";

interface ComponentNameProps {
  className?: string;
  // TODO: add props
}

export function ComponentName({ className, ...props }: ComponentNameProps) {
  return (
    <div className={cn("", className)} {...props}>
      {/* content */}
    </div>
  );
}
```

### 3. Export from barrel file
Add to `src/components/index.ts`:
```ts
export { ComponentName } from "./ComponentName";
```

### 4. Scaffold the test
Create `src/components/[ComponentName]/index.test.tsx`:
```tsx
import { render, screen } from "@testing-library/react";
import { ComponentName } from ".";

describe("ComponentName", () => {
  it("renders without crashing", () => {
    render(<ComponentName />);
    // TODO: add assertions
  });
});
```

### 5. Accessibility checklist
- [ ] Interactive elements have accessible labels
- [ ] Focusable elements reachable by keyboard
- [ ] Color is not the only means of conveying information
- [ ] Images have alt text
