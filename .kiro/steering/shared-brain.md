---
description: Implements the RECALL-RELATE-LEARN loop by forcing checks of lessons, patterns, and project context.
inclusion: auto
---

# Shared Brain — Cognitive Memory Protocol

All QA agents operate with a shared memory. The loop is: **RECALL → RELATE → LEARN**.

## Setup (First Time)

If memory files don't exist yet, copy the templates:
```
cp .kiro/memory-templates/lessons_learned.md .kiro/memory/lessons_learned.md
cp .kiro/memory-templates/pattern_registry.md .kiro/memory/pattern_registry.md
cp .kiro/memory-templates/project_context.md .kiro/memory/project_context.md
cp .kiro/memory-templates/cognitive-memory-protocol.md .kiro/memory/cognitive-memory-protocol.md
cp .kiro/memory-templates/relational-investigation-template.md .kiro/memory/relational-investigation-template.md
```

Or simply create the `.kiro/memory/` directory and copy all templates into it. Agents will populate these as they work.

---

## RECALL (Before Every Task — MANDATORY)

**Never skip this step.** Before writing any output, read:

1. `.kiro/memory/lessons_learned.md` — Check if the current ticket/error has a documented lesson. If found, apply it immediately as a constraint.
2. `.kiro/memory/pattern_registry.md` — Check if the current error signature matches a known pattern. If found, reuse the diagnostic path.
3. `.kiro/memory/project_context.md` — Understand module dependencies relevant to the task.

**If a file is empty or doesn't exist yet, note it and proceed.** The files grow over time.

Reference memory in your reasoning: e.g., "Per lessons_learned.md, TCP 3000ms timeouts indicate IPv4/IPv6 mismatch (POS-10326)."

---

## RELATE (During Analysis)

Connect the current task to the broader system:

1. **Cross-reference**: Does this ticket touch a module documented in project_context.md? What are its dependencies?
2. **Pattern match**: Does the error signature match anything in pattern_registry.md? Don't reinvent a diagnostic path that already exists.
3. **Gap detection**: If the current investigation reveals something NOT in the memory files, flag it for the LEARN phase.

---

## LEARN (After Every Task)

When you discover something new during execution:

- **New lesson**: Append to `.kiro/memory/lessons_learned.md` using format: `[DATE] [TICKET] [STATUS] — Lesson`
- **New error pattern**: Append to `.kiro/memory/pattern_registry.md` with signature, cause, diagnosis, resolution
- **New module/service info**: Append to `.kiro/memory/project_context.md` in the appropriate section

Tags: `[FIELD]` for production insights, `[AUTO]` for test design insights, `[FRAMEWORK]` for pipeline insights.

---

## REFINE (Promotion Check)

After recording a lesson, ask: **"Does this change what we know about how the product works?"**

- If YES (new architectural truth, not a one-off) → mark as `[PROMOTED]` and update `.kiro/steering/product.md` + `project_context.md`
- If NO (specific incident only) → leave as `[LOGGED]`

**Promotion test**: Will this lesson affect how future investigations are approached? If yes → PROMOTE.

---

## Rules

- **Never skip RECALL.** It's the first step of every task, every time.
- Memory files are **append-only** during LEARN. Never delete existing entries.
- Keep entries concise — one line per lesson, structured blocks per pattern.
- If memory files are empty, that's fine — you're building them from scratch.
