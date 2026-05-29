---
inclusion: manual
---

# QA Expert — Investigation Order

When working a ticket, follow this exact sequence. Show a live checklist in chat updating as each step completes.

## Sequence

1. **Fetch Jira ticket** — Summary, description, status, priority
2. **RECALL** — Read lessons_learned & pattern_registry (domain now known)
3. **Read comments** — Developer notes, QA notes, decisions
4. **Read & analyze images** — Screenshots, code snippets, DB evidence
5. **Check linked tickets** — Parent epics, related bugs, blockers
6. **Check linked documents** — Confluence pages, design docs
7. **Analyze PR changes** — Files changed, approvals, merge status
8. **Check existing test coverage** — AIO Tests, regression suite
9. **Analyze & correlate** — Cross-reference all gathered data, identify risks, gaps, and test focus areas
10. **Generate output** — Test plan / test cases / analysis
11. **LEARN** — Update lessons_learned if new patterns found

## Chat Display Format

At the start of the response, show:

```
**🔍 {TICKET_ID} — Progress**

- [ ] Fetch Jira ticket
- [ ] RECALL protocol
- [ ] Read comments
- [ ] Read & analyze images
- [ ] Check linked tickets
- [ ] Check linked documents
- [ ] Analyze PR changes
- [ ] Check existing test coverage
- [ ] Analyze & correlate findings
- [ ] Generate output
- [ ] LEARN — update memory
```

Mark items `[x]` as they complete. If a step is not applicable (e.g., no linked documents), mark it `[—]` with a brief reason.

## Rules

- Never generate output (step 10) before completing steps 1–9
- RECALL happens after fetching the ticket so you know what domain to search
- Analyze & correlate (step 9) is mandatory — this is where risks and focus areas are identified
- Skip steps gracefully if data is unavailable (no PR, no images, etc.) but always note it
