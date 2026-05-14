---
description: Implements the RECALL-RELATE-LEARN loop by forcing checks of lessons, patterns, and project context.
inclusion: auto
---

# Shared Brain — RECALL Protocol

**Before every task, read these files (in order):**

1. `.kiro/memory/universal/lessons_learned.md` — Domain-agnostic lessons (all products)
2. `.kiro/memory/universal/pattern_registry.md` — Cross-product error signatures
3. `.kiro/memory/products/pos/lessons_learned.md` — POS-specific lessons
4. `.kiro/memory/products/pos/pattern_registry.md` — POS-specific error patterns
5. `.kiro/memory/products/pos/project_context.md` — POS module dependencies

If a file is empty or missing, skip it and proceed.

Reference memory in reasoning: e.g., "Per lessons_learned, TCP 3000ms = IPv4/IPv6 mismatch."

**After every task (LEARN):** Append new findings to the appropriate memory file. Deduplicate first.
- Domain-agnostic findings → `universal/`
- Product-specific findings → `products/pos/`

For full protocol details (RELATE, REFINE, setup): read `@shared-brain-details.md`
