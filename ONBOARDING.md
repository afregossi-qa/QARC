# QARC — Onboarding Guide

> Get your first ticket through the pipeline in under 30 minutes.

## Prerequisites

- Claude Code installed (CLI: `npm install -g @anthropic-ai/claude-code` or use the desktop/IDE app)
- Jira access (for ticket fetching)
- AIO Tests access (optional — for TCMS sync)

## Step 1: Configure MCP Servers

Create `.claude/settings.local.json` with your credentials — see `SETUP.md` for the full template.

Required: **Atlassian** (Jira + Confluence)
Optional: **Azure DevOps** (PRs and commits), **AIO Tests** (TCMS sync)

## Step 2: Fill Product Context

Edit these steering files with your product's information:

- `.kiro/steering/product.md` — What your product does, key features, domain terms
- `.kiro/steering/tech.md` — Tech stack, APIs, sync patterns, testing approach

These give agents the context they need to generate relevant test plans.

## Step 3: Initialize Memory

```bash
mkdir -p .kiro/memory/universal .kiro/memory/products/your-product
cp .kiro/memory-templates/universal/*.md .kiro/memory/universal/
cp .kiro/memory-templates/products/pos/*.md .kiro/memory/products/your-product/
```

Update `.kiro/steering/shared-brain.md` to reference your product folder name.

## Step 4: Run Your First Ticket

In Claude Code, type:

```
/qa-expert
```

Provide your Jira ticket ID (e.g., `PROJ-1234`) and sprint version when asked.

The Expert agent fetches the ticket, linked PRs, and Confluence docs, then generates:
- `1_Expert/logic_explanation.md` — Logic audit and gap analysis
- `1_Expert/test_plan_PENDING.md` — Draft test plan
- `1_Expert/manual_input.md` — Template for your observations

## Step 5: Approve and Advance

**Option A — Direct approval:**
1. Review `test_plan_PENDING.md`
2. Rename it to `test_plan_OK.md`
3. Run `/qa-validate`

**Option B — With tester observations (recommended):**
1. Fill `manual_input.md` with observations from exploratory testing
2. Rename it to `manual_input_OK.md`
3. Run `/qa-revise-plan-from-input` — drafts a test plan using your input
4. Review the revised `test_plan_PENDING.md`
5. Rename to `test_plan_OK.md`, then run `/qa-validate`

**To request changes to the test plan:**
1. Add feedback at the top of `test_plan_PENDING.md`
2. Rename it to `test_plan_UPDATED.md`
3. Run `/qa-revise-plan`

## Step 6: Validate Test Cases

1. `/qa-validate` generates `2_Validator/FINAL_TEST_CASES_{TICKET_ID}_PENDING.md`
2. Review the structured test cases
3. To add feedback: write it under `## QA Comments` and rename to `_UPDATED.md`, then run `/qa-revise-cases`
4. To approve: rename to `_OK.md`
5. To export: rename to `_CSV.md` and run `/qa-export-csv`, OR rename to `_API.md` and run `/qa-export-aio`

## Step 7: Execute and Review

1. Execute test cases manually
2. Drop evidence (JSON logs, screenshots, `.db` files) into `3_Evidence/`
   - Naming: `tc01_description.json`, `tc02_screenshot.png`
3. Run `/qa-review`
4. The Reviewer audits evidence and produces a STABLE or UNSTABLE verdict

## Step 8: Close or Remediate

**STABLE verdict:**
- Run `/qa-dashboard` to generate the closure dashboard
- Archive the ticket folder

**UNSTABLE verdict:**
- Add notes to the closure report
- Rename it to `_REMEDIATE.md`
- Run `/qa-remediate`
- Re-execute failed tests with new evidence
- Run `/qa-review` again

---

## Pipeline Flow Summary

```
/qa-expert
    ↓ review 1_Expert/ files
rename test_plan → _OK.md
    ↓
/qa-validate
    ↓ review 2_Validator/ test cases
rename FINAL_TEST_CASES → _OK.md
    ↓
/qa-export-csv  OR  /qa-export-aio
    ↓
Drop evidence into 3_Evidence/
    ↓
/qa-review
    ↓
STABLE → /qa-dashboard → archive
UNSTABLE → /qa-remediate → re-execute → /qa-review
```

---

## Key Concepts

- **Suffix convention**: `_PENDING` (draft) → `_OK` (approved) → next stage
- **Human-in-the-loop**: Nothing advances without your explicit rename
- **Shared Brain**: Agents RECALL memory before every task and LEARN after — knowledge accumulates automatically
- **Snapshots**: Files are backed up before any overwrite (in `5_Snapshots/`) — auto-hook handles this
- **Folder enforcement**: The PreToolUse hook blocks writes to the wrong subfolder automatically

---

## Folder Structure

```
{year}/Q{N}/Version {V}/PROJ-{ticket} - {description}/
├── 1_Expert/       # Test plan, logic analysis
├── 2_Validator/    # Structured test cases
├── 3_Evidence/     # Raw execution data
├── 4_Reviewer/     # Findings and closure report
└── 5_Snapshots/    # Auto-backups
```

---

## Need Help?

- `SETUP.md` — MCP server configuration
- `.claude/CLAUDE.md` — Full context document (auto-loaded)
- `.kiro/steering/` — All framework rules and workflows
- `.kiro/memory/` — Shared Brain knowledge base (grows as you work)
