# Skill: Cognitive-Memory-Protocol

## Mission
Ensure all pipeline agents operate with full project context and contribute to the framework's growing knowledge base. Every ticket processed — from requirements analysis through test case design and evidence review — refines the understanding of the product, its edge cases, and its failure modes.

## Phase 1: The Recall (Input)
BEFORE executing any task, the agent must:
1. **Context Scan**: Read `.kiro/memory/products/pos/project_context.md` to understand module dependencies.
2. **Domain Knowledge**: Check for `manual_input.md` in the ticket's `1_Expert/` folder — it contains human observations and product behavior notes that take precedence over assumptions.
3. **Mistake Avoidance**: Read `.kiro/memory/products/pos/lessons_learned.md`. If the current task involves a documented "Issue," apply the "Lesson" immediately.
4. **Pattern Matching**: Read `.kiro/memory/products/pos/pattern_registry.md` to reuse successful test patterns, edge case categories, or verification approaches.

## Phase 2: The Relate (Execution)
During execution, the agent must:
1. Cross-reference requirements (Jira acceptance criteria) against implementation (PR code changes in logic_explanation.md). Identify gaps in both directions.
2. Reference why a specific decision was made based on the memory files (e.g., "Including timezone edge case as per lessons_learned.md from POS-9967").
3. Factor in `manual_input.md` domain knowledge — human testers often know product behaviors that aren't documented elsewhere.

## Phase 3: The Learning (Output)
AFTER completing a task or identifying a finding, the agent must:
1. **New Lesson**: If a requirement gap, logic insight, or product behavior was discovered, append it to `lessons_learned.md`. Tags: `[EXPERT]` for requirements/logic, `[VALIDATOR]` for test design, `[REVIEWER]` for evidence/execution, `[DOMAIN]` for manual_input discoveries.
2. **New Pattern**: If a reusable test pattern, edge case category, or verification approach was created, document it in `pattern_registry.md`.

## Phase 4: The Refinement (Promotion)
AFTER recording a lesson, the agent must ask: **"Does this change what we know about how the product works?"**

1. **Product Knowledge Check**: Re-read the new lesson and ask:
   - Does this reveal a new module dependency or service relationship? → Update `project_context.md`
   - Does this correct a previous assumption about how a feature works? → Update the relevant section in `project_context.md`
   - Does this establish a new architectural truth (not just a one-off incident)? → Mark the lesson as `[PROMOTED]` in `lessons_learned.md`
2. **Promotion Criteria**: A lesson should be promoted when it's a verified architectural truth that will affect future test design — not just a specific ticket finding. Examples:
   - "Job titles always return isFullDataset:true" → PROMOTED (architectural truth)
   - "OutBoxCheck entries are purged after successful upload" → PROMOTED (product behavior)
   - "tc02 failed due to transient 500" → LOGGED (specific incident, not promoted)
3. **Context Update**: If promoted, update `.kiro/steering/product.md` with the new product knowledge. Change the lesson status from `[LOGGED]` to `[PROMOTED]`.