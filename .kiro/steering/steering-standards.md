---
inclusion: manual
---

# Steering & Skills File Standards

Rules for creating and editing `.kiro/steering/` and `.kiro/skills/` files.

## Front-Matter (Steering Files Only)

Every steering file MUST start with a YAML front-matter block:

```yaml
---
inclusion: auto | manual | fileMatch
description: One-sentence purpose (optional but recommended)
fileMatchPattern: 'glob pattern' # required only for fileMatch
---
```

| Inclusion Type | When to Use | Size Limit |
|----------------|-------------|------------|
| `auto` | Rules that apply to EVERY interaction | <1KB strictly |
| `manual` | Loaded on demand via `#filename` or `@filename.md` | No hard limit (prefer <5KB) |
| `fileMatch` | Auto-loaded when matching files are in context | No hard limit (prefer <8KB) |

Skills files (`.kiro/skills/`) do NOT use front-matter — they are referenced via `@filename.md`.

## File Naming

| Type | Convention | Examples |
|------|-----------|----------|
| Agent workflow | `qa-{agent}-workflow.md` | `qa-validator-workflow.md` |
| Format/template | `PascalCase.md` or `kebab-case.md` | `TestCasesDesign.md`, `csv-export-format.md` |
| Standards/policy | `kebab-case.md` | `regression-automation-criteria.md` |
| Skills | `PascalCase.md` | `AIO-API-Mapper.md`, `CognitiveMemoryProtocol.md` |

## Structure Rules

1. **No duplication** — Each piece of knowledge lives in ONE file. Other files reference it via `@filename.md`.
2. **Workflow vs Detail split** — Workflow files define execution steps. Detail files (skills/format docs) define HOW to do each step. Workflows reference details, never embed them.
3. **Single authority** — For each topic, one file is the authority:

| Topic | Authority File | Type |
|-------|---------------|------|
| Test case formatting | `TestCasesDesign.md` | steering |
| AIO field mapping | `AIO-API-Mapper.md` | skill |
| CSV export format | `csv-export-format.md` | steering |
| Regression/automation criteria | `regression-automation-criteria.md` | steering |
| Project structure | `structure.md` + `structure-details.md` | steering |
| Memory protocol | `shared-brain.md` + `CognitiveMemoryProtocol.md` | steering + skill |
| Agent workflows | `qa-{agent}-workflow.md` (one per agent) | steering |

## Content Guidelines

- **Tables over bullet lists** for structured data
- **No TODO placeholders** — if content isn't ready, don't create the file
- **Cross-references** use `@filename.md` syntax (not full paths)
- **Confluence links** always include `/wiki/` segment: `https://qubeyond.atlassian.net/wiki/spaces/...`
- **Version footer** recommended for files that change frequently:
  ```
  **Last Updated:** YYYY-MM-DD
  ```

## When Creating New Files

1. Check if the topic already has an authority file (see table above)
2. If yes → update that file instead of creating a new one
3. If no → create with proper front-matter and add to the authority table above
4. Keep `auto` files under 1KB — use summary + `@detail-file.md` pattern if needed

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Duplicate field mapping in workflow AND skill | Put mapping in skill, reference from workflow |
| Create template file with only TODOs | Wait until content is ready |
| Use `inclusion: auto` for >1KB files | Use `manual` or `fileMatch` |
| Embed full instructions in hook prompts | Reference `@steering-file.md` |
| Create both `lifecycle-*.md` steering AND skill | Pick one authority |

---

## Current Inventory (June 2026)

| Category | Count | Location |
|----------|-------|----------|
| Steering files (core) | 18 | `.kiro/steering/` |
| Skills files (core) | 12 | `.kiro/skills/` |
| Hooks (core) | 27 | `.kiro/hooks/` |
| Auto-included (always-on) | 2 | `context_efficiency.md`, `structure.md` |

**Last Updated:** June 5, 2026
