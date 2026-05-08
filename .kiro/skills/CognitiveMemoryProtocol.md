# Skill: Cognitive-Memory-Protocol

## Mission
Ensure all agents operate with project-wide context and contribute to the "Collective Brain" of the Qu POS automation squad.

## Phase 1: The Recall (Input)
BEFORE executing any task, the agent must:
1. **Context Scan**: Read `.kiro/memory/project_context.md` to understand module dependencies.
2. **Mistake Avoidance**: Read `.kiro/memory/lessons_learned.md`. If the current task involves a documented "Issue," apply the "Lesson" immediately.
3. **Pattern Matching**: Read `.kiro/memory/pattern_registry.md` to reuse successful code or logic structures.

## Phase 2: The Relate (Execution)
During execution, the agent must:
1. Reference why a specific decision was made based on the memory files (e.g., "Applying 2s wait as per lessons_learned.md regarding WinAppDriver lag").

## Phase 3: The Learning (Output)
AFTER completing a task or identifying a failure, the agent must:
1. **New Lesson**: If a fix was required, append the root cause and the permanent solution to `lessons_learned.md`.
2. **New Pattern**: If a reusable code block or logic was created, document it in `pattern_registry.md`.

## Phase 4: The Refinement (Promotion)
AFTER recording a lesson, the agent must ask: **"Does this change what we know about how the product works?"**

1. **Product Knowledge Check**: Re-read the new lesson and ask:
   - Does this reveal a new module dependency or service relationship? → Update `project_context.md` Module Relationships or Key Services
   - Does this correct a previous assumption about how a feature works? → Update the relevant section in `project_context.md`
   - Does this establish a new architectural truth (not just a one-off incident)? → Mark the lesson as `[PROMOTED]` in `lessons_learned.md`
2. **Promotion Criteria**: A lesson should be promoted when it's a verified architectural truth that will affect future investigations — not just a specific incident fix. Examples:
   - "Job titles always return isFullDataset:true" → PROMOTED (architectural truth)
   - "tc02 failed due to transient 500" → LOGGED (specific incident, not promoted)
3. **Context Update**: If promoted, update `.kiro/steering/product.md` with the new product knowledge (this is the "How It Works" source of truth). If the lesson also reveals a new module dependency or service relationship, additionally update `.kiro/memory/project_context.md`. Change the lesson status from `[LOGGED]` to `[PROMOTED]`.