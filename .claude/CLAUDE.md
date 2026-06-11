# QARC — AI-Powered QA Pipeline (Claude Code)

AI-assisted QA pipeline that automates the lifecycle of test documentation — from ticket analysis to test plan generation, evidence review, and production readiness verdicts.

**Human-in-the-loop:** AI agents generate artifacts, humans validate and approve at every gate. No output advances without explicit sign-off.

---

## Slash Command Reference

| Command | What it does | When to run |
|---------|-------------|-------------|
| `/qa-expert` | Fetch Jira ticket → generate test plan, logic analysis, manual input | Start of every ticket |
| `/qa-validate` | Generate structured test cases from approved test plan | After approving `test_plan_OK.md` |
| `/qa-revise-plan` | Rewrite test plan incorporating feedback in `test_plan_UPDATED.md` | After adding feedback to test plan |
| `/qa-revise-plan-from-input` | Draft test plan from `manual_input_OK.md` | After filling and approving manual input |
| `/qa-revise-cases` | Revise test cases incorporating feedback in `FINAL_TEST_CASES_*_UPDATED.md` | After adding feedback to test cases |
| `/qa-export-csv` | Convert approved test cases to TCMS CSV | After approving `FINAL_TEST_CASES_*_OK.md` |
| `/qa-export-aio` | Push approved test cases to AIO Tests via API | After renaming to `_API.md` |
| `/qa-review` | Audit evidence and produce STABLE/UNSTABLE verdict | After dropping evidence in `3_Evidence/` |
| `/qa-remediate` | Analyze failures and produce revised test cases | After marking closure report `_REMEDIATE.md` |
| `/qa-dashboard` | Generate QA_DASHBOARD.md and SUMMARY.md | After reviewer phase |

---

## Pipeline Flow

```
① /qa-expert   → Fetch Jira + PRs + Confluence → test plan, logic, manual input
② /qa-validate → Structure test cases with steps, priorities, tags
③ /qa-export-* → Push to AIO Tests (API) or generate CSV for TCMS
④  Human       → Execute tests, drop evidence into 3_Evidence/
⑤ /qa-review   → Audit evidence → STABLE or UNSTABLE verdict
⑥ /qa-dashboard → Dashboard + archive (or /qa-remediate loop)
```

**Suffix convention — how approval works:**

| Suffix | Meaning | What to do next |
|--------|---------|-----------------|
| `_PENDING` | Agent draft, awaiting review | Review, then rename |
| `_OK` | Human approved → triggers next stage | Run next slash command |
| `_UPDATED` | Human feedback added → triggers revision | Run revise command |
| `_API` | AIO sync requested | Run `/qa-export-aio` |
| `_CSV` | Export requested | Run `/qa-export-csv` |
| `_VALIDATED` | Closure approved (STABLE) | Run `/qa-dashboard` |
| `_REMEDIATE` | UNSTABLE, needs rework | Run `/qa-remediate` |

---

## Folder Structure

```
{TICKET_ID} - {description}/
├── 1_Expert/       # logic_explanation, test_plan, manual_input
├── 2_Validator/    # FINAL_TEST_CASES, CSV export, QA summary
├── 3_Evidence/     # Raw data ONLY (JSON, PNG, JPG, .db)
├── 4_Reviewer/     # EXECUTION_FINDINGS, FINAL_CLOSURE_REPORT
├── 5_Snapshots/    # Auto-backups before overwrites
└── 6_Automation/   # Test scripts and logs (optional)
```

Tickets live under `{year}/Q{N}/Version {V}/`. Ticket ID is the full Jira key (e.g., `POS-9967`).

**Files allowed at ticket root:**
`.state.json`, `AIO_SYNC_LOG.md`, `PROGRESS_TRACKER.md`, `REMEDIATION_LOG.md`, `QA_DASHBOARD.md`, `SUMMARY.md`, `*_ERROR.md`, `Automation_Blueprint*.md`

**Folder rules (enforced by PreToolUse hook):**

| File pattern | Must go in |
|---|---|
| `logic_explanation*.md`, `test_plan*.md`, `manual_input*.md` | `1_Expert/` |
| `FINAL_TEST_CASES*.md`, `*_TCMS_Import.csv`, `FINAL_QA_SUMMARY*.md` | `2_Validator/` |
| `*.json`, `*.png`, `*.jpg`, `EVIDENCE_READY.md`, `EVIDENCE_GAP_REPORT.md` | `3_Evidence/` |
| `EXECUTION_FINDINGS*.md`, `FINAL_CLOSURE_REPORT*.md` | `4_Reviewer/` |
| Any timestamped backup | `5_Snapshots/` |

---

## RECALL Protocol — Read Before Every Task

Before executing any task, read these files in order (skip if empty or missing):

1. `.kiro/memory/universal/lessons_learned.md`
2. `.kiro/memory/universal/pattern_registry.md`
3. `.kiro/memory/products/{product}/lessons_learned.md`
4. `.kiro/memory/products/{product}/pattern_registry.md`
5. `.kiro/memory/products/{product}/project_context.md`

The `{product}` folder matches the Jira project prefix (e.g., `pos` for POS-XXXX, `acv2` for ACV2-XXX).

Reference memory in reasoning: e.g., "Per lessons_learned.md, TCP 3000ms = IPv4/IPv6 mismatch."

**LEARN — After every task:**
- Append new findings to the appropriate memory file. Deduplicate first — scan before appending.
- Domain-agnostic findings → `universal/`
- Product-specific findings → `products/{product}/`
- Format: `[DATE] [TICKET-ID] [LOGGED] [TAG] — {concise lesson in one sentence}`
- Tags: `[EXPERT]` `[VALIDATOR]` `[REVIEWER]` `[DOMAIN]` `[AUTO]` `[FIELD]`

---

## Skills Location

Skills are plain Markdown files in `.kiro/skills/`. When a command references a skill, read that file first.

| Skill | Path | Used by |
|-------|------|---------|
| CognitiveMemoryProtocol | `.kiro/skills/CognitiveMemoryProtocol.md` | All agents |
| GapAnalyzer | `.kiro/skills/GapAnalyzer.md` | Expert |
| ContextIntegrator | `.kiro/skills/ContextIntegrator.md` | Validator |
| TestCaseStandardizer | `.kiro/skills/TestCaseStandardizer.md` | Validator |
| TestCasesDesign | `.kiro/steering/TestCasesDesign.md` | Validator |
| EvidenceAuditAnalyzer | `.kiro/skills/EvidenceAuditAnalyzer.md` | Reviewer |
| ReportLifecycleUpdater | `.kiro/skills/ReportLifecycleUpdater.md` | Reviewer |
| MarkdownTestParser | `.kiro/skills/MarkdownTestParser.md` | Exporter |
| MultiRowCSVTransformer | `.kiro/skills/MultiRowCSVTransformer.md` | Exporter |
| AIO-API-Mapper | `.kiro/skills/AIO-API-Mapper.md` | AIO agent |
| ExecutiveDocumentGenerator | `.kiro/skills/ExecutiveDocumentGenerator.md` | Dashboard |
| LifecycleStateScraper | `.kiro/skills/LifecycleStateScraper.md` | Dashboard |
| LifecycleStateManager | `.kiro/skills/LifecycleStateManager.md` | All agents |

Detailed workflow docs (load only when needed):
- `.kiro/steering/qa-expert-workflow.md`
- `.kiro/steering/qa-validator-workflow.md`
- `.kiro/steering/qa-reviewer-workflow.md`
- `.kiro/steering/qa-exporter-workflow.md`
- `.kiro/steering/qa-aio-workflow.md`
- `.kiro/steering/qa-dashboard-workflow.md`
- `.kiro/steering/TestCasesDesign.md`
- `.kiro/steering/csv-export-format.md`
- `.kiro/steering/evidence_standards.md`
- `.kiro/steering/dashboard_standards.md`

---

## Context & Token Efficiency Rules

| File size | Action |
|-----------|--------|
| <5KB | Read fully |
| 5–10KB | Read fully, summarize in response |
| >10KB | Use line ranges — never full read |
| >50KB | Extract specific sections only |

- **Lazy loading**: Only read files needed for the current step.
- **Logs/JSON evidence**: First 50 + last 50 lines unless error detected.
- **Single-file writes**: One Write call per output file. Never split across Write + Append. Overwrite if exists — no duplicates.
- **Folder-locked**: Each agent writes only to its designated folder.

---

## Agent Design Principles

**No chat.** Pipeline agents produce structured output files — never conversational responses. Every invocation results in a file write, not a chat message.

**No assumptions.** If evidence is missing, say so. Never fill knowledge gaps with speculation presented as fact.

**No bias.** Agents describe what they see — not what they expect. A test that passes in one scenario is not assumed to pass in another without evidence.

**Cite your evidence.** Every claim references a specific file, line, or timestamp.

**RECALL before work.** Read memory files before producing any output. Non-negotiable first step — never skip.

**Fail cleanly.** On error, write `{PHASE}_ERROR.md` at ticket root (what failed + error + what completed) and STOP.

**Append-only memory.** Never delete or edit existing memory entries. Deduplicate before appending.
