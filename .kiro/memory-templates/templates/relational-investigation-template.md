# Relational Investigation Template

> Use this template when investigating a field incident that spans multiple modules or requires cross-referencing automation history.

## Incident Summary

| Field | Value |
|-------|-------|
| Ticket | |
| Store/Location | |
| Version | |
| Date Reported | |
| Severity | |

## Phase 1: Recall

### Lessons Check
- [ ] Searched `lessons_learned.md` for error signature
- [ ] Searched `lessons_learned.md` for ticket ID
- [ ] Checked for `[PROMOTED]` lessons that apply as constraints

### Pattern Check
- [ ] Compared log patterns against `pattern_registry.md`
- [ ] Identified reusable diagnostic queries

### Context Check
- [ ] Identified affected module(s) in `project_context.md`
- [ ] Mapped upstream/downstream dependencies

## Phase 2: Relate

### Cross-Reference Findings

| Source | Finding | Relevance |
|--------|---------|-----------|
| Automation History (`[AUTO]` lessons) | | |
| Field History (`[FIELD]` lessons) | | |
| Pattern Registry match | | |

### Vision-Log Correlation

| Screenshot Time | Log Timestamp | Match? | Notes |
|-----------------|---------------|--------|-------|
| | | | |

### Gap Analysis
- What did the framework miss?
- Why wasn't this caught earlier?
- What edge case is new?

## Phase 3: Learn

### New Lessons (append to lessons_learned.md)
```
[DATE] [TICKET] [STATUS] [TAG] — Lesson text
```

### New Patterns (append to pattern_registry.md)
```
### {Error Name}
{signature}
- Cause:
- Diagnosis:
- Resolution:
```

### Promotion Candidates
- [ ] Does this change what we know about how the product works?
- [ ] If yes → update product.md and mark lesson as [PROMOTED]
