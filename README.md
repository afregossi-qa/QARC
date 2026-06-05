# QARC — AI-Powered QA Pipeline Framework

> **This framework is a starting point.** It requires human surveillance at all times — agents generate artifacts, but you review, approve, and course-correct. The pipeline learns from your feedback through the Shared Brain, but it's your judgment that drives quality.

An AI-assisted QA pipeline that automates the lifecycle of test documentation — from ticket analysis to test plan generation, evidence review, and production readiness verdicts.

**Human-in-the-loop:** AI agents generate artifacts, humans validate and approve at every gate. No output advances without explicit human sign-off.

**Platform:** Built for [Kiro IDE](https://kiro.dev) using its native agents, hooks, steering, and MCP protocol.

---

## Quick Start

1. Clone this repo
2. Open the folder in Kiro IDE
3. Follow `SETUP.md` to configure MCP servers and credentials
4. Follow `ONBOARDING.md` to run your first ticket

---

## How It Works

```
① Expert    → Fetches Jira + PRs + Confluence + Human Input → generates test plan
② Validator → Structures test cases with steps, priorities, tags
③ Export    → Direct push to AIO Tests or CSV for TCMS import
④ Execute   → Human runs tests, drops evidence
⑤ Reviewer  → AI audits evidence + Human Input → STABLE or UNSTABLE verdict
⑥ Closure   → Dashboard + Lessons Learned + archive (or remediation loop)
```

Every transition requires human approval via file-rename convention:
- `_PENDING.md` → agent draft, awaiting review
- `_OK.md` → approved, triggers next stage
- `_UPDATED.md` → rejected with feedback, triggers revision
- `_STABLE.md` / `_VALIDATED.md` → closure approved, triggers learning + dashboard

---

## No Model Training Required

QARC doesn't fine-tune or train any AI model. It uses **context engineering** — steering files, memory files, skills, and structured prompts shape how a general-purpose LLM behaves. All the "intelligence" lives in the repo as markdown files that you can read, edit, and version control. When you improve a steering file or add a lesson to memory, every agent immediately benefits on the next run.

---

## Core Pipeline Inventory

| Category | Count | Location |
|----------|-------|----------|
| Agents | 6 | `.kiro/agents/` |
| Hooks | 27 | `.kiro/hooks/` |
| Steering | 18 | `.kiro/steering/` |
| Skills | 12 | `.kiro/skills/` |
| Memory files | 8 | `.kiro/memory/` |

### Agents

| Agent | Role |
|-------|------|
| QA-Expert | Fetch ticket data, analyze logic, generate test plan |
| QA-Validator | Finalize test cases with priorities and automation tags |
| QA-Evidence-Reviewer | Audit evidence against test cases, produce verdict |
| QA-AIO-Direct | Push test cases to AIO Tests via API |
| QA-Exporter | Transform test cases to TCMS-compatible CSV |
| QA-Dashboard | Generate QA_DASHBOARD.md and SUMMARY.md |

### MCP Servers Required

| Server | Package | Purpose | Required? |
|--------|---------|---------|-----------|
| Atlassian | `uvx mcp-atlassian` | Jira tickets + Confluence docs | Yes |
| Azure DevOps | `npx @azure-devops/mcp` | PR diffs + commits | Optional |
| AIO Tests | Custom (`.kiro/mcp-servers/aio-tests/`) | Test case management | Optional |
| Image Extractor | `npx mcp-image-extractor` | Screenshot analysis | Yes |

---

## Shared Brain (Cognitive Memory)

The pipeline learns across tickets through an append-only knowledge base:

```
.kiro/memory/
├── universal/              ← Cross-product knowledge
├── products/{name}/        ← Product-specific lessons and patterns
│   ├── project_context.md  ← Architectural truths (the "constitution")
│   ├── lessons_learned.md  ← Grows automatically per ticket
│   └── pattern_registry.md ← Error signatures and diagnostics
└── cognitive-memory-protocol.md  ← The RECALL-RELATE-LEARN protocol
```

**RECALL** → Agents read memory before every task
**RELATE** → Agents cross-reference during analysis
**LEARN** → Hook auto-appends discoveries on ticket closure (`_STABLE`/`_VALIDATED`)

---

## Folder Structure (Created at Runtime)

```
{year}/Q{quarter}/Version {version}/PROJ-{TICKET} - {description}/
├── 1_Expert/       ← Test plan, logic analysis, manual input
├── 2_Validator/    ← Structured test cases, CSV export
├── 3_Evidence/     ← Screenshots, logs, DB files, API captures
├── 4_Reviewer/     ← Execution findings, closure report
├── 5_Snapshots/    ← Auto-backups before overwrites
└── 6_Automation/   ← Test scripts and logs (optional)
```

---

## Setup Requirements

| Prerequisite | Purpose |
|--------------|---------|
| [Kiro IDE](https://kiro.dev) | Runtime environment |
| [uv](https://docs.astral.sh/uv/getting-started/installation/) | Runs Atlassian MCP server (`uvx`) |
| [Node.js](https://nodejs.org/) | Runs AIO Tests + Azure DevOps + Image Extractor MCPs |
| Jira API token | Ticket fetching |
| Azure DevOps PAT | PR review (optional) |
| AIO Tests token | TCMS sync (optional) |

---

## Documentation

| File | Purpose |
|------|---------|
| `README.md` | What QARC is and how it's structured |
| `SETUP.md` | Technical setup (MCP, credentials, prerequisites) |
| `ONBOARDING.md` | Step-by-step guide to run your first ticket |

---

## Contributing

This framework is designed to be extended and adapted. The Shared Brain learns from your changes — improve a steering file, add a lesson to memory, or create a new hook, and every agent benefits on the next run.
