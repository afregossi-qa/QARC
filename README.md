# QARC — AI-Powered QA Pipeline Framework

An AI-assisted QA pipeline that automates the lifecycle of test documentation — from ticket analysis to test plan generation, evidence review, and production readiness verdicts.

**Human-in-the-loop:** AI agents generate artifacts, humans validate and approve at every gate. No output advances without explicit human sign-off.

**Platform:** Built for [Kiro IDE](https://kiro.dev) using its native agents, hooks, steering, and MCP protocol.

---

## Quick Start

1. Clone this repo
2. Open the folder in Kiro IDE
3. Copy `.kiro/settings/mcp.example.json` → `.kiro/settings/mcp.json`
4. Fill in your credentials (Atlassian API token, Azure DevOps PAT, AIO Tests token)
5. Trigger the Expert hook or invoke the Expert agent in chat with a Jira ticket ID

---

## How It Works

```
① Expert    → Fetches Jira + PRs + Confluence + Human Input → generates test plan
② Validator → Structures test cases with steps, priorities, tags
③ Export    → Direct push to AIO Tests or CSV for TCMS import
④ Execute   → Human runs tests, drops evidence
⑤ Reviewer  → AI audits evidence + Human Input → STABLE or UNSTABLE verdict
⑥ Closure   → Dashboard + archive (or remediation loop)
```

Every transition requires human approval via file-rename convention:
- `_PENDING.md` → agent draft, awaiting review
- `_OK.md` → approved, triggers next stage
- `_UPDATED.md` → rejected with feedback, triggers revision

---

## What's in This Repo

| Folder | Content |
|--------|---------|
| `.kiro/agents/` | 8 core agent configurations |
| `.kiro/hooks/` | 18 event-driven pipeline hooks |
| `.kiro/steering/` | Domain knowledge, workflow rules, standards |
| `.kiro/skills/` | Reusable procedural instructions |
| `.kiro/memory/` | Cognitive memory protocol + investigation template |
| `.kiro/memory-templates/` | Starter templates for memory files |
| `.kiro/mcp-servers/` | Custom AIO Tests MCP server |
| `Tools/` | LiteDB readers for local database analysis |

---

## Setup Requirements

- [Kiro IDE](https://kiro.dev)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) — Python package runner (runs the Atlassian MCP server via `uvx`)
- Node.js — runs the custom AIO Tests MCP server
- npx — runs the Azure DevOps MCP server (comes with Node.js)

### MCP Credentials Needed

| Server | What you need |
|--------|---------------|
| Atlassian | Jira/Confluence API token ([generate here](https://id.atlassian.com/manage-profile/security/api-tokens)) |
| Azure DevOps | Personal Access Token with Code (Read) scope |
| AIO Tests | API token from AIO Tests settings |

---

## Folder Structure (Created at Runtime)

When you trigger the Expert agent, it creates:
```
{year}/Q{quarter}/Version {version}/PROJ-{TICKET} - {description}/
├── 1_Expert/       ← Test plan, logic analysis, manual input
├── 2_Validator/    ← Structured test cases, CSV export
├── 3_Evidence/     ← Screenshots, logs, API captures
├── 4_Reviewer/     ← Execution findings, closure report
└── 5_Snapshots/    ← Auto-backups before overwrites
```

---

## Documentation

- [QARC Summary](https://qubeyond.atlassian.net/wiki/spaces/POS/pages/3098738744)
- [QARC Architecture & Roadmap](https://qubeyond.atlassian.net/wiki/spaces/POS/pages/3099262997)
- [Pipeline Trigger Flow](https://qubeyond.atlassian.net/wiki/spaces/POS/pages/3098247267)

See `.kiro/steering/` for all workflow and standards documentation.

---

## Authors

**Agostina Fregossi** — Architecture design & implementation  
**Kiro AI** — Execution engine
