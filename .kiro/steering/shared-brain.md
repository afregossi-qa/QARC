---
description: Implements the RECALL-RELATE-LEARN loop by forcing checks of lessons, patterns, and project context.
inclusion: auto
---

# Shared Brain — RECALL Protocol

**Before every task, read these files (in order):**

1. `.kiro/memory/universal/lessons_learned.md` — Domain-agnostic lessons (all products)
2. `.kiro/memory/universal/pattern_registry.md` — Cross-product error signatures
3. `.kiro/memory/products/{product}/lessons_learned.md` — Product-specific lessons
4. `.kiro/memory/products/{product}/pattern_registry.md` — Product-specific error patterns
5. `.kiro/memory/products/{product}/project_context.md` — Product module dependencies

The `{product}` folder matches the team's Jira project (e.g., `pos/`, `acv2/`, `qupos/`). If a file is empty or missing, skip it and proceed.

Reference memory in reasoning: e.g., "Per lessons_learned, TCP 3000ms = IPv4/IPv6 mismatch."

**After every task (LEARN):** Append new findings to the appropriate memory file. Deduplicate first.
- Domain-agnostic findings → `universal/`
- Product-specific findings → `products/{product}/`

For full protocol details (RELATE, REFINE, setup): read `@shared-brain-details.md`
