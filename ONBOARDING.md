# QARC — Onboarding Guide

> Get your first ticket through the pipeline in under 30 minutes.

## Prerequisites

- Kiro IDE installed
- Jira access (for ticket fetching)
- AIO Tests access (optional — for TCMS sync)

## Step 1: Configure MCP Servers

Edit `.kiro/settings/mcp.json` with your credentials:
- **Atlassian** — Jira + Confluence (required)
- **Azure DevOps** — PRs and commits (optional)
- **AIO Tests** — TCMS sync (optional)

See `SETUP.md` for detailed MCP configuration.

## Step 2: Fill Product Context

Edit these steering files with your product's information:
- `.kiro/steering/product.md` — What your product does, key features, domain terms
- `.kiro/steering/tech.md` — Tech stack, APIs, sync patterns, testing approach

These give agents the context they need to generate relevant test plans.

## Step 3: Run Your First Ticket

1. Click the **"Trigger Expert"** button in Kiro's hook panel
2. Provide your Jira ticket ID (e.g., PROJ-1234) and sprint version
3. The Expert agent fetches the ticket, linked PRs, and Confluence docs
4. Review the generated files in `1_Expert/`:
   - `logic_explanation.md` — Logic audit and gap analysis
   - `test_plan_PENDING.md` — Draft test plan
   - `manual_input.md` — Template for your observations

## Step 4: Approve and Advance

1. Fill `manual_input.md` with any observations from exploratory testing
2. Rename it to `manual_input_OK.md` — this triggers test plan revision
3. Review `test_plan_PENDING.md`:
   - Approve → rename to `test_plan_OK.md` (triggers Validator)
   - Request changes → rename to `test_plan_UPDATED.md` (triggers revision)

## Step 5: Validate Test Cases

1. The Validator generates `2_Validator/FINAL_TEST_CASES_*_PENDING.md`
2. Review the structured test cases
3. Approve → rename to `_OK.md`, `_CSV.md` (export), or `_API.md` (AIO sync)

## Step 6: Execute and Review

1. Execute tests manually and drop evidence (JSON logs, screenshots) into `3_Evidence/`
2. Click **"Trigger Reviewer"** button
3. The Reviewer audits evidence against test cases and produces a verdict

## Pipeline Flow Summary

```
Expert → [human review] → Validator → [human review] → Export/AIO
                                                            ↓
                                              Drop evidence to 3_Evidence/
                                                            ↓
                                              Reviewer → STABLE or UNSTABLE
```

## Key Concepts

- **Suffix convention**: `_PENDING` (draft) → `_OK` (approved) → next stage
- **Human-in-the-loop**: Nothing advances without your explicit rename
- **Shared Brain**: Agents learn from past tickets automatically
- **Snapshots**: Files are backed up before any overwrite (in `5_Snapshots/`)

## Folder Structure

```
{year}/Q{N}/Version {V}/PROJ-{ticket} - {description}/
├── 1_Expert/       # Test plan, logic analysis
├── 2_Validator/    # Structured test cases
├── 3_Evidence/     # Raw execution data
├── 4_Reviewer/     # Findings and closure report
└── 5_Snapshots/    # Auto-backups
```

## Need Help?

- `SETUP.md` — MCP server configuration
- `.kiro/steering/` — All framework rules and workflows
- `.kiro/memory/` — Shared Brain knowledge base (grows as you work)
