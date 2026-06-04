# Shared Brain — RECALL-RELATE-LEARN

## RECALL (Before Every Task)

Read these files in order:

1. `.kiro/memory/products/{product}/project_context.md` — Module dependencies, architectural truths
2. `.kiro/memory/products/{product}/lessons_learned.md` — Product-specific lessons
3. `.kiro/memory/products/{product}/pattern_registry.md` — Error signatures & diagnostics
4. `.kiro/memory/universal/lessons_learned.md` — Cross-product lessons
5. `.kiro/memory/universal/pattern_registry.md` — Cross-product patterns

The `{product}` folder matches the Jira project (e.g., `pos/`). If a file is missing, skip it.

Reference memory in reasoning: e.g., "Per project_context, Save() is the sole writer of MenuHead fields."

**`[PROMOTED]` entries are hard constraints** — apply them as rules, not suggestions.

## RELATE (During Analysis)

1. **Cross-reference**: Does this ticket touch a module in project_context.md? What are its dependencies?
2. **Pattern match**: Does the error signature match pattern_registry.md? Don't reinvent a diagnostic path that already exists.
3. **Gap detection**: If investigation reveals something NOT in memory, flag it for LEARN.

## LEARN (Handled by Hook)

Learning happens automatically via `learn-on-findings.kiro.hook` when a closure report is marked `_STABLE` or `_VALIDATED`. No agent needs to manually write to memory files.

## Rules

- **Never skip RECALL.** First step of every task, every time.
- Memory files are **append-only**. Never delete or rewrite existing entries.
- `[PROMOTED]` entries are periodically archived to `lessons_learned_archive.md`.
- Tags: `[FIELD]` = production insights, `[AUTO]` = test design, `[FRAMEWORK]` = pipeline.
