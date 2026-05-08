# Skill: Cognitive-Memory-Protocol (The Shared Brain)

## 🎯 Goal
To eliminate silos between Field Triage and Automation Design. Ensure the Automation team learns from Production failures and the Triage team uses Automation history to speed up root-cause identification.

---

## 📥 Phase 1: The Recall (Input & Context)
**Objective: Understand the "Law" and the "History" before touching a log.**

1.  **Context Scan (The Constitution)**: 
    - Read `@product_overview.md` and `@project_context.md`. 
    - You must identify the specific module's intended behavior (e.g., How many sync triggers exist? Is this endpoint delta-capable?).
2.  **Mistake Avoidance (The News Feed)**: 
    - Search `@lessons_learned.md` for the current error signature (e.g., `TcpTimeout`) or Ticket ID.
    - **Rule**: If a lesson is marked `[PROMOTED]`, it is now a fundamental rule in the Product/Context docs; apply it as a hard constraint.
3.  **Signature Matching**: 
    - Compare current log patterns against `@pattern_registry.md`. Do not re-invent a diagnostic path if a proven SQL query or Grep pattern already exists.

---

## 🔄 Phase 2: The Relational Work (Triangulation)
**Objective: Connect the current incident to the rest of the ecosystem.**

1.  **Cross-Workspace Bridge**: 
    - **If Triage**: "Did the Automation squad see this 'flaky' behavior before it hit production?" (Search lessons for `[AUTO]`).
    - **If Automation**: "Has a field bug recently forced a change in how this module works?" (Search for `[FIELD]`).
2.  **Vision-Log Correlation**: 
    - Use Gemini 3 Pro to synchronize the **Screenshot Time** with the **Log Timestamp**. 
    - Verify if the "Truth" in the Database matches the "Evidence" on the screen.
3.  **The Gap Analysis**: 
    - Identify *why* the current framework missed this. Is it a missing network latency simulation? A missing edge-case in sync triggers?

---

## 📤 Phase 3: The Learning & Promotion (Output)
**Objective: Permanent refinement of the framework's intelligence.**

1.  **New Lesson Capture**: 
    - Append findings to `@lessons_learned.md`. 
    - **Format**: `[DATE] [TICKET] [STATUS] — Lesson`. 
    - Tags: Use `[FIELD]` for triage insights and `[AUTO]` for test design insights.
2.  **Technical Standardization**: 
    - If a new diagnostic SQL query or a specific Log Regex was successful, record it in `@pattern_registry.md`.
3.  **Knowledge Promotion (The Loop)**:
    - **Crucial**: If a lesson reveals a permanent architectural change or a "hidden" product rule (e.g., "Job titles never sync deltas"), you **MUST** update `@product_overview.md` or `@project_context.md`.
    - **Cleanup**: Mark the original lesson as `[PROMOTED]` to signal that it has been integrated into the "Constitution."

---

## 🏁 Success Criteria
- No agent ever spends time debugging a "feature" as if it were a "bug."
- Every production hotfix results in a new, specific regression test case.
- The steering docs (`product.md`) grow more accurate with every field failure.