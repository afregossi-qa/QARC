# QARC — AI-Powered QA Pipeline Framework

> **This framework is a starting point.** It requires human surveillance at all times — agents generate artifacts, but you review, approve, and course-correct. Expect to make improvements and adjustments as you use it. The pipeline learns from your feedback through the Shared Brain, but it's your judgment that drives quality.

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

## No Model Training Required

QARC doesn't fine-tune or train any AI model. It uses **context engineering** — steering files, memory files, skills, and structured prompts shape how a general-purpose LLM behaves. All the "intelligence" lives in the repo as markdown files that you can read, edit, and version control. When you improve a steering file or add a lesson to memory, every agent immediately benefits on the next run. No retraining, no datasets, no GPU time.

---

## What's in This Repo

| Folder | Content |
|--------|---------|
| `.kiro/agents/` | 6 core pipeline agents |
| `.kiro/hooks/` | 17 event-driven pipeline hooks |
| `.kiro/steering/` | Domain knowledge, workflow rules, standards |
| `.kiro/skills/` | Reusable procedural instructions |
| `.kiro/memory-templates/` | Starter templates for memory files |
| `.kiro/mcp-servers/` | Custom AIO Tests MCP server |

> **Additional Flows (In Progress):** Two flows integrate with the core pipeline but are not yet published:
> - **Field Bug Triage Flow** — Investigates production incidents using POS logs, local databases, and screenshots. Findings feed back into the Expert phase as domain knowledge via `manual_input.md`.
> - **Automation Flow** — Converts validated test cases into executable automation scripts. Regression candidates identified by the Reviewer feed into automation backlog.
>
> Both are working locally and will be published once stable.

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

---

## Contributing

This framework is a starting point, not a finished product. The agents, hooks, and steering files are designed to be extended and adapted. If you find a better way to structure test cases, a smarter hook trigger, or a new agent workflow — improve it. The Shared Brain will learn from your changes.
