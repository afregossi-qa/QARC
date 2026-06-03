---
description: Full Shared Brain protocol details — RELATE, REFINE, setup instructions
inclusion: manual
---

# Shared Brain — Full Protocol Details

## Setup (First Time)

If memory files don't exist yet, copy the templates:
```
cp .kiro/memory-templates/lessons_learned.md .kiro/memory/products/pos/lessons_learned.md
cp .kiro/memory-templates/pattern_registry.md .kiro/memory/products/pos/pattern_registry.md
cp .kiro/memory-templates/project_context.md .kiro/memory/products/pos/project_context.md
cp .kiro/memory-templates/cognitive-memory-protocol.md .kiro/memory/cognitive-memory-protocol.md
cp .kiro/memory-templates/relational-investigation-template.md .kiro/memory/relational-investigation-template.md
```

---

## RELATE (During Analysis)

Connect the current task to the broader system:

1. **Cross-reference**: Does this ticket touch a module documented in project_context.md? What are its dependencies?
2. **Pattern match**: Does the error signature match anything in pattern_registry.md? Don't reinvent a diagnostic path that already exists.
3. **Gap detection**: If the current investigation reveals something NOT in the memory files, flag it for the LEARN phase.

---

## LEARN (After Every Task)

When you discover something new during execution:

- **New lesson**: Append to `.kiro/memory/products/pos/lessons_learned.md` using format: `[DATE] [TICKET] [STATUS] — Lesson`
- **New error pattern**: Append to `.kiro/memory/products/pos/pattern_registry.md` with signature, cause, diagnosis, resolution
- **New module/service info**: Append to `.kiro/memory/products/pos/project_context.md` in the appropriate section

Tags: `[FIELD]` for production insights, `[AUTO]` for test design insights, `[FRAMEWORK]` for pipeline insights.

---

## REFINE (Promotion Check)

After recording a lesson, ask: **"Does this change what we know about how the product works, how it fails, or how it should be investigated?"**

- If YES (new architectural truth, behavioral constraint, retry/timing rule, safety-net gap, or operational rule that would affect future investigations) → mark as `[PROMOTED]` and update `project_context.md` in the appropriate section (Module Relationships, Key Services, Sync Behavior, Local Database, Cloud Posting, Timestamps, or create a new section if needed).
- If NO (specific incident only) → leave as `[LOGGED]`

**Promotion test**: Will this lesson affect how future investigations are approached? If yes → PROMOTE.

---

## Rules

- **Never skip RECALL.** It's the first step of every task, every time.
- Memory files are **append-only** during LEARN. Never delete existing entries.
- Keep entries concise — one line per lesson, structured blocks per pattern.
- `[PROMOTED]` entries are periodically evicted to `lessons_learned_archive.md` to control file size.
- If memory files are empty, that's fine — you're building them from scratch.
