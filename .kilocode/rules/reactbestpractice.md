---
alwaysApply: true
---
## 0.1 The Senior Mindset Protocol (Human-Like Flow)

**Mandatory Rule**: The AI must simulate the thought process of a Senior React Engineer, avoiding "robotic" code generation.

1.  **Think First, Code Second**: Do not rush to `export default function`. First, define the _Component Interface (Props)_ and _State Model_.
2.  **Logical Implementation Flow**:
    - 1. Define Types/Zod Schemas.
    - 2. Implement Custom Hooks (Logic).
    - 3. Build the UI Layout (JSX).
    - 4. Integrate Logic with UI.
3.  **Purposeful Code**: Avoid "filler" JSX or generic styles. Every `div`, `className`, and `useEffect` must have a specific architectural reason.
4.  **Senior Commentary**: Explain _why_ a pattern is chosen (e.g., "Using `useOptimistic` here to reduce perceived latency") rather than describing what the code does.

## 0.2 Pixel-Perfect & Logic-Proof Execution (Absolute Adherence)

**Mandatory Rule**: Frontend code must be a fortress of logic and a mirror of design.

1.  **Visual Integrity (Pixel-Perfect):**
    - **Strict Spacing:** Use Tailwind's spacing scale rigidly (e.g., `gap-4`, `p-6`). Do not eyeball values like `p-[13px]`.
    - **Alignment:** Ensure absolute vertical/horizontal alignment. A 1px misalignment is a failure.
    - **Responsive:** Mobile-first is not optional. It must look perfect on all breakpoints.
2.  **Logical Integrity (Bulletproof Flow):**
    - **State Completeness:** Handle ALL states: `Idle`, `Loading`, `Success`, `Error`, `Empty`.
    - **Validation:** Never trust user input. Validate locally (Zod) before sending to Server Actions.
    - **Error Boundaries:** No component should crash the whole app. Wrap risky sections in Error Boundaries.

---

## 1. Interactive Collaboration Protocol (Human-AI)

- **Stop & Ask:** If a request is unclear or lacks technical details, the AI must stop and ask the user for clarification.
- **Option Proposal:** Provide at least 2 solutions (Trade-offs) before execution to let the user choose the "Big Picture".
- **Validation:** Every step must be validated before proceeding to the next one.
- **Proactive Refactoring (The Boy Scout Rule):** If you encounter legacy code, anti-patterns, or suboptimal implementations while working on a feature, **STOP and ask the user for permission** to fix it. Do not ignore technical debt just because it "works".

---

## 2. Hexagonal Architecture (The Foundation)

All business logic must be completely separated from the Framework (Next.js/React).

### A. The Core (Domain Layer) - `src/core/domain/`

- Contains Entities, Business Logic, and Pure Functions.
- **FORBIDDEN:** Do NOT import any UI libraries or Framework hooks here.

### B. The Ports (Interfaces) - `src/core/ports/`

- Defines "contracts" for data and actions (e.g., `IUserRepository`, `IPaymentGateway`).

### C. The Adapters (Infrastructure) - `src/core/adapters/`

- Specific implementations of Ports (e.g., `AxiosAuthAdapter`, `SupabaseStorageAdapter`).
- If changing technology (e.g., REST to GraphQL), only modify this layer.

---

## 3. Component Engineering (Atomic & Proprietary Handling)

UI components must be broken down to the minimum level (Atomic Design) to ensure absolute reusability and maintainability.

### A. Atomic Design Rules

- **Atoms (`src/components/ui/`):** Button, Input, Badge (Dumb components, no business logic).
- **Molecules/Organisms (`src/components/features/`):** LoginForm, ProfileCard (Combinations of Atoms).
- **Granularity Rule:** If a Component exceeds **80 lines of code**, it MUST be refactored into sub-components or custom hooks. Each component does **one thing only** (Single Responsibility).
- **Accessibility (a11y) is Mandatory:**
  - **Semantic HTML:** Use `<button>`, `<main>`, `<article>`, `<nav>` correctly. Do NOT use `div` for clickable elements.
  - **Keyboard Navigation:** All interactive elements must be focusable and usable via keyboard.
  - **ARIA:** Use `aria-label` for icon-only buttons. Ensure strict contrast ratios.

### B. Proprietary Component Strategy (Handling Missing Dependencies)

If a proprietary component or internal library is missing:

1.  **Placeholder:** Create a temporary placeholder to avoid breaking the development flow.
    ```tsx
    // Example Placeholder
    <div className="p-4 border-2 border-dashed border-yellow-500 bg-yellow-50 text-yellow-700 rounded-md">
      <strong>[Proprietary Component Missing: {ComponentName}]</strong>
      <p>Please implement or import the proprietary component here.</p>
    </div>
    ```
2.  **Explicit TODO:** Add a clear `TODO` comment right where the replacement is needed.
    ```tsx
    {
      /* TODO: REPLACE WITH PROPRIETARY COMPONENT [ComponentName] */
    }
    ```
3.  **Notification:** Clearly notify the user in the output about this shortage and the location needing modification.

---

## 4. Technology Stack (Bleeding Edge & Future-Proof)

**Mandatory Rule:** We do not build legacy code. We build for the future. **Always** select the absolute latest stable version of any library.

- **Framework:** **Next.js (Latest)**. STRICTLY App Router. NO Pages Router.
- **Core:** **React 19+**. Aggressively use `use`, `useOptimistic`, `useActionState`, and Server Components (RSC).
- **Data Fetching:** **TanStack Query v5+** (Client side) & **Server Actions** (Mutations).
- **State Management:**
  - **Global:** **Zustand** (Minimalist & Performance).
  - **Server:** **TanStack Query**.
  - **URL:** **Nuqs** (Type-safe search params) or native `useSearchParams`.
- **Styling:** **Tailwind CSS (Latest/v4)** + **Shadcn/UI**.
- **Forms:** **React Hook Form** + **Zod**.
- **Build Tool:** **Turbopack** (where applicable).

### 4.1 Design Intelligence (Color & UI)

- **No Random Colors:** DO NOT pick arbitrary Hex/RGB values.
- **Harmonious Palettes:**
  - **Standard:** Use standard Tailwind colors (`slate`, `indigo`) or Shadcn semantic variables (`primary`, `muted`).
  - **Research-Based:** If a custom palette is needed, the AI MUST **search online** (e.g., "modern dashboard color palette 2025") or reference established design systems (e.g., Linear, Vercel, Tailwind UI) to select a cohesive set. **Never guess.**
- **Accessibility:** Ensure sufficient contrast (WCAG AA standard).

---

## 5. Absolute Type Safety & Naming Conventions

### A. Type Safety

- **Strict Mode:** TypeScript `strict: true`.
- **Branded Types:** Use for IDs and critical data (e.g., `type UserId = string & { __brand: 'UserId' }`).
- **Zod Validation:** Validate all Inputs/Outputs.
- **No `any`:** Absolutely NO `any`.

### B. Naming Conventions (Professional)

- **Files/Components:** `PascalCase` (e.g., `UserProfile.tsx`).
- **Functions/Variables:** `camelCase` (e.g., `getUserProfile`, `isLoading`).
- **Constants:** `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).
- **Folders:** `kebab-case` (e.g., `user-profile`, `auth-provider`).

---

## 6. Directory Structure (The Enterprise Tree)

The directory structure must strictly follow a hybrid **Domain-Driven Design (DDD)** and **Feature-Sliced Design (FSD)** model to ensure maximum scalability.

```text
/src
├── app/                        # Next.js App Router (Routing & Entry Points Only)
│   ├── (auth)/                 # Route Groups (Logic-free)
│   │   ├── login/              # Login Page Route
│   │   │   └── page.tsx
│   │   └── register/           # Register Page Route
│   │       └── page.tsx
│   ├── (dashboard)/            # Dashboard Route Group
│   │   ├── layout.tsx          # Dashboard Layout
│   │   └── page.tsx            # Dashboard Home
│   ├── api/                    # API Routes (Use Server Actions preferably)
│   │   └── route.ts
│   ├── layout.tsx              # Root Layout
│   └── page.tsx                # Landing Page
│
├── features/                   # Feature Modules (Vertical Slices - MOST IMPORTANT)
│   ├── [feature-name]/         # e.g., "auth", "checkout", "product-details"
│   │   ├── components/         # Feature-specific UI Components
│   │   │   ├── [Feature]Form.tsx
│   │   │   └── [Feature]List.tsx
│   │   ├── hooks/              # Feature-specific Hooks
│   │   │   └── use[Feature].ts
│   │   ├── server/             # Server Actions & Data Fetching
│   │   │   ├── actions.ts      # Server Actions
│   │   │   └── queries.ts      # Data Fetching Queries
│   │   ├── utils/              # Feature-specific Helpers
│   │   │   └── [feature]Helper.ts
│   │   └── types.ts            # Feature-specific Types
│
├── components/                 # Shared UI (Horizontal Layers)
│   ├── ui/                     # Atomic Design (Shadcn/UI primitives)
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   └── card.tsx
│   ├── layout/                 # Global Layouts
│   │   ├── header.tsx
│   │   ├── sidebar.tsx
│   │   └── footer.tsx
│   ├── shared/                 # Generic Business Components
│   │   └── user-avatar.tsx
│   └── icons/                  # SVG Icons collection
│       └── icons.tsx
│
├── core/                       # Core Business Logic & Infrastructure (Hexagonal)
│   ├── domain/                 # Entities & Pure Business Logic (No React code)
│   │   ├── entities/           # Domain Models
│   │   └── services/           # Domain Services
│   ├── ports/                  # Interfaces (Repository Patterns)
│   │   └── [entity]Repository.ts
│   └── adapters/               # Implementations (API Clients, Storage)
│       ├── http/               # HTTP Clients (Axios/Fetch)
│       └── storage/            # LocalStorage/SessionStorage
│
├── lib/                        # Configuration & 3rd Party Setup
│   ├── utils.ts                # Global helpers (cn, formatters)
│   ├── constants.ts            # Global constants (Env vars, Configs)
│   └── prisma.ts               # Database Client Instance
│
├── hooks/                      # Global Hooks
│   ├── use-toast.ts
│   └── use-media-query.ts
│
├── store/                      # Global State Managers (Zustand)
│   └── use-store.ts
│
├── types/                      # Global TypeScript Definitions
│   └── global.d.ts
│
└── styles/                     # Global Styles
    └── globals.css
```

**"Colocation" Rule:**

- Everything closely related to a feature MUST be located within `features/[feature-name]`.
- Only move code to `components/shared` or global `hooks` if it is used by **at least 2 different features**.

---

## 7. Operational Rules, Security & Globalization

- **Idempotency:** Check if the file exists before creating it.
- **Security First:**
  - **Input Validation:** Validate all inputs from user/API (Zod).
  - **Authorization:** Server Actions must check permissions on the very first line.
  - **Secrets:** NEVER hardcode secrets/API keys.
- **Internationalization (i18n):**
  - **No Hardcoded Strings:** All user-facing text must be extracted (e.g., `t('welcome_message')`).
  - **Libraries:** Use `next-intl` or `react-i18next`.
- **Observability:**
  - **No Console Logs:** `console.log` is forbidden in production code. Use a proper Logger adapter.
  - **Error Tracking:** Integrate with Sentry/OpenTelemetry for unhandled exceptions.

---

## 9. Enterprise Quality Assurance (The Safety Net)

**Mandatory Rule:** Code without tests is technical debt. Code that is slow is a bug.

### 9.1 Testing Strategy (The Pyramid)

- **Unit Tests (Vitest):** 100% coverage for all `utils/`, `hooks/`, and complex logic in `core/domain`.
- **Component Tests (React Testing Library):** Test behavior (User Interactions), not implementation details.
- **E2E Tests (Playwright):** Critical paths (Login, Checkout, Critical Business Flows) must be automated.

### 9.2 Performance Budget (Speed is a Feature)

- **Core Web Vitals:** Target all Green (LCP < 2.5s, CLS < 0.1, INP < 200ms).
- **Optimization Tactics:**
  - **Images:** STRICTLY use `next/image` with proper sizing.
  - **Code Splitting:** Use `next/dynamic` for heavy components (charts, maps, editors).
  - **Memoization:** Use `useMemo`/`useCallback` _only_ for referential stability or expensive calculations. Do not premature optimize.

---

## 10. Mandatory Output Template (Strict)

Every response involving file creation/modification MUST follow this structure:

**1. Context & Analysis:**

- Read relevant files: [List files read]
- Brief analysis of changes.

**2. File Execution:**

> **Action:** [Create / Modify]
>
> **File Path:** `[EXACT_PATH_TO_FILE]` (e.g., `src/components/ui/Button.tsx`)

```tsx
// [FILE CONTENT SNIPPET]
// ...
```

_(If the file is too long, show only critical changes, but provide full content or reasonable chunks when creating new files)_

**3. Proprietary/Missing Components Check:**

- [ ] No proprietary components missing.
- [x] Missing [Component Name] -> Placeholder inserted at line [Line Number].
