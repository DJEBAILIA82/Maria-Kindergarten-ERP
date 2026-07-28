# AI_WORKFLOW.md
## Maria Kindergarten ERP — AI Collaboration Workflow & Engineering Principles

> **Purpose:** This document is the permanent reference for any AI assistant (or human developer) working on this project. It defines how work is analyzed, proposed, approved, and executed. It must be read and followed before any code change.

---

## 1. Project Nature

- **Maria Kindergarten ERP** is an **offline-first** kindergarten management system.
- Stack: **Flutter**, **SQLite**, **Material 3**.
- Treated as a **production-quality commercial application** intended to be maintained for many years.
- **SQLite is the single source of truth.** No hardcoded data in the UI, ever.

---

## 2. Core Mental Model

The project must always be treated as **one integrated system**, not a collection of independent files. Before touching anything, the relationships below must be understood:

```
Database (SQLite)  →  Models  →  Services  →  Pages / Widgets (UI)
```

- **Database**: schema, migrations, single source of truth.
- **Models**: typed representations of DB rows/entities.
- **Services**: business logic, data access, orchestration — kept separate from presentation.
- **Pages/Widgets**: presentation layer only; no business logic, no hardcoded data.

No file is edited in isolation. Every change is evaluated against its ripple effects across this chain.

---

## 3. Development Workflow (Mandatory Sequence)

For every non-trivial request, the following steps are followed **in order**:

1. **Analyze** the problem or request.
2. **Explain the root cause** — do not assume the existing implementation is wrong; understand why it was built that way first.
3. **Identify affected files and dependencies** across Models/Services/Database/Pages/Widgets.
4. **Evaluate risks and possible side effects.**
5. **Propose the recommended solution**, with alternatives when appropriate, including trade-offs.
6. **Wait for explicit approval** before implementing any major change.
7. **Implement** the approved solution — one phase at a time.
8. **Verify** the result.
9. **Update documentation** if needed.

### Hard Rules
- **Only one phase/stage is implemented per turn.** No bundling of unrelated changes.
- **No major change is implemented without prior approval.**
- If a change requires touching related/dependent files, those files are **identified and updated together** — not left inconsistent.
- **No duplicate logic** is ever created for something that already exists (no parallel/competing implementations of the same feature).
- **No breaking changes** to currently working features.

---

## 4. Engineering Principles

- **SQLite is the single source of truth** for all application data.
- **Never hardcode data in the UI** — all dynamic data flows from the database through services.
- **Business logic stays out of the presentation layer.** Pages/Widgets render and dispatch; Services decide and compute.
- **Maintainability over quick fixes.** Short-term convenience never justifies long-term debt.
- **Avoid technical debt** — if a shortcut is taken, it must be explicitly flagged as such.
- **No breaking changes** without an explicit, approved migration plan.
- **Design with future backend integration in mind** — even though the app is offline-first today, service/data-access boundaries should not assume SQLite is the *only* possible backend forever.
- **Gradual move toward Clean Architecture** — improve structure incrementally, without destabilizing what already works.

---

## 5. Response & Communication Standards

Every substantive response should:

- **Explain the reasoning**, not just state a conclusion.
- **Separate assumptions from facts.** Anything not confirmed by the code/user is labeled as an assumption.
- **Highlight trade-offs** between possible approaches.
- **Warn about architectural risks**, even if the user didn't ask.
- **Ask concise clarification questions** when information is missing, instead of guessing.

---

## 6. Post-Implementation Report Template

After **every phase** of implementation, a report is provided with exactly these four sections:

1. **الملفات المعدلة** / Files modified
2. **سبب التعديل** / Reason for the change
3. **تأثير التعديل** / Impact of the change
4. **الآثار الجانبية المحتملة** / Potential side effects

No phase is considered "done" without this report.

---

## 7. Pre-Change Checklist (applies to every edit, big or small)

- [ ] Have I understood *why* the current code is written this way?
- [ ] Have I traced this change through Database → Model → Service → UI?
- [ ] Are there other files/features depending on what I'm about to change?
- [ ] Does this introduce a second implementation of existing logic?
- [ ] Could this break a currently working feature?
- [ ] Have I separated what I *know* from what I'm *assuming*?
- [ ] For major changes: has the plan been explicitly approved?

---

## 8. Language & Continuity Note

- The project owner may communicate in Arabic or English interchangeably; both are treated as equally authoritative.
- This document itself is the continuity mechanism: any new AI session (or the same session after context loss) must read this file first and operate under these rules by default, without needing them to be repeated.

---

*This document should be updated whenever the workflow or principles evolve, as part of step 9 (Update documentation) of the standard workflow.*