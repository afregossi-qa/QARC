# QARC — AI-Powered QA Pipeline Framework

> **This framework is a starting point.** It requires human surveillance at all times — agents generate artifacts, but you review, approve, and course-correct. Expect to make improvements and adjustments as you use it. The pipeline learns from your feedback through the Shared Brain, but it's your judgment that drives quality.

An AI-assisted QA pipeline that automates the lifecycle of test documentation — from ticket analysis to test plan generation, evidence review, and production readiness verdicts.

**Human-in-the-loop:** AI agents generate artifacts, humans validate and approve at every gate. No output advances without explicit human sign-off.

**Platform:** Built for [Claude Code](https://claude.ai/code) using its native slash commands, hooks, and MCP protocol. The `.kiro/` folder is kept for historical reference and contains the original Kiro IDE version of the framework.

---

## Quick Start

1. Clone this repo
2. Open the folder in Claude Code
3. Follow `SETUP.md` to configure MCP servers and credentials
4. Follow `ONBOARDING.md` to run your first ticket

---

## How It Works

```
① /qa-expert   → Fetch Jira + PRs + Confluence + Human Input → generates test plan
② /qa-validate → Structure test cases with steps, priorities, tags
③ /qa-export-* → Direct push to AIO Tests or CSV for TCMS import
④  Human       → Execute tests, drop evidence into 3_Evidence/
⑤ /qa-review   → AI audits evidence + Human Input → STABLE or UNSTABLE verdict
⑥ /qa-dashboard → Dashboard + archive (or /qa-remediate loop)
```

Every transition requires human approval via file-rename convention:
- `_PENDING.md` → agent draft, awaiting review
- `_OK.md` → approved, run the next slash command
- `_UPDATED.md` → rejected with feedback, run the revise command

---

## No Model Training Required

QARC doesn't fine-tune or train any AI model. It uses **context engineering** — steering files, memory files, skills, and structured prompts shape how a general-purpose LLM behaves. All the "intelligence" lives in the repo as Markdown files that you can read, edit, and version control. When you improve a steering file or add a lesson to memory, every agent immediately benefits on the next run.

---

## Slash Command Reference

| Command | What it does |
|---------|-------------|
| `/qa-expert` | Fetch Jira ticket → test plan, logic analysis, manual input template |
| `/qa-validate` | Generate structured test cases from approved test plan |
| `/qa-revise-plan` | Rewrite test plan incorporating `_UPDATED.md` feedback |
| `/qa-revise-plan-from-input` | Draft test plan from approved `manual_input_OK.md` |
| `/qa-revise-cases` | Revise test cases incorporating `_UPDATED.md` feedback |
| `/qa-export-csv` | Convert approved test cases to TCMS CSV |
| `/qa-export-aio` | Push approved test cases to AIO Tests via API |
| `/qa-review` | Audit evidence → STABLE or UNSTABLE verdict |
| `/qa-remediate` | Analyze failures, revise test cases for next iteration |
| `/qa-dashboard` | Generate QA_DASHBOARD.md and SUMMARY.md |

---

## What's in This Repo

| Folder | Content |
|--------|---------|
| `.claude/` | Claude Code configuration: CLAUDE.md, settings.json, slash commands, hook scripts |
| `.claude/commands/` | Slash commands (one per pipeline stage) |
| `.claude/hooks/` | Shell hook scripts (folder validation, snapshots, auto-commits) |
| `.kiro/steering/` | Domain knowledge, workflow rules, standards (used by slash commands) |
| `.kiro/skills/` | Reusable procedural instructions (used by slash commands) |
| `.kiro/memory-templates/` | Starter templates for the Shared Brain |
| `.kiro/mcp-servers/` | Custom AIO Tests MCP server |
| `.kiro/` | Original Kiro IDE version (kept for reference) |
| `examples/` | Reference implementations by product domain |

---

## Shared Brain (Cognitive Memory)

The pipeline learns across tickets through an append-only knowledge base:

```
.kiro/memory/
├── universal/          ← Cross-product knowledge (domain-agnostic)
├── products/{name}/    ← Product-specific lessons and patterns
└── platform/{os}/      ← Platform-specific knowledge
```

Agents read memory before every task (RECALL) and write back discoveries after (LEARN). Knowledge accumulates automatically with every slash command invocation.

---

## Hooks (Auto-Behaviors)

These run automatically on every Claude Code file write — no manual intervention needed:

| Hook | Trigger | What it does |
|------|---------|-------------|
| `enforce-folder-structure` | PreToolUse/Write | Blocks writes that violate QARC folder conventions |
| `snapshot-before-write` | PreToolUse/Write | Backs up files in `1_Expert/`, `2_Validator/`, `4_Reviewer/` before overwrite |
| `commit-phase-complete` | PostToolUse/Write | Auto-commits after key phase outputs are written |
| `commit-memory-updates` | PostToolUse/Write | Auto-commits Shared Brain memory file changes |

---

## Setup Requirements

- [Claude Code](https://claude.ai/code) (CLI, desktop app, or IDE extension)
- [uv](https://docs.astral.sh/uv/getting-started/installation/) — Python package runner (runs the Atlassian MCP server via `uvx`)
- Node.js — runs the custom AIO Tests MCP server
- npx — runs the Azure DevOps MCP server (comes with Node.js)
- [.NET SDK 8.0+](https://dotnet.microsoft.com/download) — required for LiteDB evidence reading

### MCP Credentials Needed

| Server | What you need |
|--------|---------------|
| Atlassian | Jira/Confluence API token |
| Azure DevOps | Personal Access Token with Code (Read) scope |
| AIO Tests | API token from AIO Tests settings |

---

## Folder Structure (Created at Runtime)

When you run `/qa-expert`, it creates:
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

| File | Purpose |
|------|---------|
| `README.md` | This file — what QARC is |
| `SETUP.md` | Technical setup (MCP, credentials, prerequisites) |
| `ONBOARDING.md` | Step-by-step guide to run your first ticket |
| `.claude/CLAUDE.md` | Main agent context file (auto-loaded by Claude Code) |
| `examples/pos/README.md` | POS product reference implementation |

See `.kiro/steering/` for all workflow and standards documentation.

---

## Agent Design Principles

### Quality

**No chat.** Pipeline agents produce structured output files — never conversational responses.

**No assumptions.** If evidence is missing, say so. Never fill knowledge gaps with speculation.

**No bias.** Agents describe what they see, not what they expect.

**Cite your evidence.** Every claim references a specific file, line, or timestamp.

**RECALL before work.** Read memory files before producing any output — non-negotiable.

**Fail cleanly.** On error, write `{PHASE}_ERROR.md` at ticket root and STOP.

### Token Efficiency

**Lazy loading.** Only read files strictly necessary for the current step.

**Targeted reads.** Files over 10KB are read in sections, never fully.

**Single-file writes.** One Write call per output file. Overwrite if exists — no duplicates.

**Folder-locked.** Each agent writes only to its designated folder.

### Memory

**Append-only.** Agents never delete or edit existing memory entries.

**Deduplicate first.** Before writing to any memory file, scan for a similar existing entry.

**Promote deliberately.** Only the Reviewer phase promotes lessons from `[LOGGED]` to `[PROMOTED]`.

---

## Contributing

This framework is a starting point, not a finished product. The agents, hooks, and steering files are designed to be extended and adapted. If you find a better way to structure test cases, a smarter hook trigger, or a new agent workflow — improve it. The Shared Brain will learn from your changes.
