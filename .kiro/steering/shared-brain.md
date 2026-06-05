# Shared Brain — RECALL-RELATE-LEARN

## Scope

This protocol applies **only** when working on Jira tickets or product-related tasks. Do NOT execute RECALL for general questions, documentation edits, configuration changes, or non-ticket conversations.

## RECALL (Before Every Ticket Task)

Read these files in order:

1. `.kiro/memory/products/{product}/project_context.md` — Module dependencies, architectural truths
2. `.kiro/memory/products/{product}/lessons_learned.md` — Product-specific lessons
3. `.kiro/memory/products/{product}/pattern_registry.md` — Error signatures & diagnostics
4. `.kiro/memory/platform/{platform}/lessons_learned.md` — Platform-specific lessons
5. `.kiro/memory/platform/{platform}/pattern_registry.md` — Platform-specific patterns
6. `.kiro/memory/universal/lessons_learned.md` — Cross-product lessons
7. `.kiro/memory/universal/pattern_registry.md` — Cross-product patterns

The `{product}` folder matches the Jira project (e.g., `pos/`). The `{platform}` folder matches the target platform (e.g., `windows/`). If a file is missing, skip it.

Reference memory in reasoning: e.g., "Per project_context, Save() is the sole writer of MenuHead fields."

**`[PROMOTED]` entries are hard constraints** — apply them as rules, not suggestions.

## RELATE (During Analysis)

1. **Cross-reference**: Does this ticket touch a module in project_context.md? What are its dependencies?
2. **Pattern match**: Does the error signature match pattern_registry.md? Don't reinvent a diagnostic path that already exists.
3. **Gap detection**: If investigation reveals something NOT in memory, flag it for LEARN.

## LEARN (Handled by Hook)

Learning happens automatically via `learn-on-findings.kiro.hook` when a closure report is marked `_STABLE` or `_VALIDATED`. No agent needs to manually write to memory files.

## Rules

- **Never skip RECALL** — first step of every ticket task, every time.
- **Skip RECALL entirely** for non-ticket work (docs, config, general questions).
- Memory files are **append-only**. Never delete or rewrite existing entries.
- `[PROMOTED]` entries are periodically archived to `lessons_learned_archive.md`.
- Tags: `[FIELD]` = production insights, `[AUTO]` = test design, `[FRAMEWORK]` = pipeline.
