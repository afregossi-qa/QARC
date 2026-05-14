# QARC — AI-Powered QA Pipeline Framework

> **This framework is a starting point.** It requires human surveillance at all times — agents generate artifacts, but you review, approve, and course-correct. Expect to make improvements and adjustments as you use it. The pipeline learns from your feedback through the Shared Brain, but it's your judgment that drives quality.

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
| `.kiro/hooks/` | Event-driven pipeline hooks |
| `.kiro/steering/` | Domain knowledge, workflow rules, standards |
| `.kiro/skills/` | Reusable procedural instructions |
| `.kiro/memory-templates/` | Starter templates for the Shared Brain |
| `.kiro/mcp-servers/` | Custom AIO Tests MCP server |
| `examples/` | Reference implementations by product domain |

---

## Shared Brain (Cognitive Memory)

The pipeline learns across tickets through an append-only knowledge base:

```
.kiro/memory-templates/
├── universal/          ← Cross-product knowledge (domain-agnostic)
├── products/{name}/    ← Product-specific lessons and patterns
└── platform/{os}/      ← Platform-specific knowledge
```

Agents read memory before every task (RECALL) and write back discoveries after (LEARN). Knowledge accumulates automatically — no manual logging required.

> **V2 in progress:** We're building a smarter retrieval layer that replaces full-file reads with semantic search — agents will get only the most relevant lessons for each ticket instead of reading everything. This will include index-first RECALL, confidence scoring, cross-project sharing, and optional vector-based retrieval. The current system works well at small scale; V2 makes it scale indefinitely.

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

| File | Purpose |
|------|---------|
| `README.md` | This file — what QARC is |
| `SETUP.md` | Technical setup (MCP, credentials, prerequisites) |
| `ONBOARDING.md` | Step-by-step guide to run your first ticket |
| `examples/pos/README.md` | POS product reference implementation |

See `.kiro/steering/` for all workflow and standards documentation.


---


## Agent Design Principles

QARC agents are designed to be sharp, efficient, and honest. When extending or creating new agents, follow these principles:

### Quality

**No chat.** Pipeline agents produce structured output files — never conversational responses. Every agent invocation results in a `fsWrite` call, not a chat message.

**No assumptions.** If evidence is missing, say so. If a file can't be read, report it. Never fill knowledge gaps with speculation presented as fact. Observations and interpretations are always labeled separately.

**No bias.** Agents describe what they see in the evidence, not what they expect to see. A test that passes in one scenario is not assumed to pass in another without evidence.

**Cite your evidence.** Every claim must reference a specific file, line number, or timestamp. No unsourced conclusions. If two variables correlate, state the correlation — don't claim causation without proof.

**RECALL before work.** Read memory files before producing any output. This is the non-negotiable first step of every agent invocation — never skip it.

**Fail cleanly.** On error, write `{PHASE}_ERROR.md` at ticket root (what failed, the error, what completed) and STOP. Never leave partial outputs without an error file.

### Token Efficiency

**Lazy loading.** Only read files strictly necessary for the current step. Never pre-load "just in case."

**Targeted reads.** Files over 10KB are read in sections (line ranges or selectors), never fully. Logs use the Head/Tail rule (first 50 + last 50 lines unless an error is detected).

**Compressed prompts.** Hook prompts reference `@workflow.md` files for detailed steps — never embed full workflows inline. Always-on steering files are kept under 1KB each.

**Single-file writes.** Use one `fsWrite` per output file. Never split across `fsWrite` + `fsAppend`. Overwrite if exists — don't create duplicates.

**Folder-locked.** Each agent writes only to its designated folder. No traversing parent directories or reading across ticket boundaries (except Dashboard).

### Memory

**Append-only.** Agents never delete or edit existing memory entries. They deduplicate before appending.

**Deduplicate first.** Before writing to any memory file, scan it for a similar existing entry. If found, skip — don't create near-duplicates.

**Promote deliberately.** Elevation from `[LOGGED]` to `[PROMOTED]` is a separate, conscious step that only the Reviewer hook performs. Lightweight LEARN hooks never promote.

These principles are enforced through steering files (`context_efficiency.md`, `evidence_standards.md`) and guard hooks (`enforce-folder-structure`, `snapshot-before-write`). They're not suggestions — they're structural constraints baked into the pipeline.


## Contributing

This framework is a starting point, not a finished product. The agents, hooks, and steering files are designed to be extended and adapted. If you find a better way to structure test cases, a smarter hook trigger, or a new agent workflow — improve it. The Shared Brain will learn from your changes.

---