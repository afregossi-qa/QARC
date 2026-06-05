# QARC — Onboarding Guide

> Get your first ticket through the pipeline in under 30 minutes.

## Prerequisites

- Kiro IDE installed and MCP servers configured (see `SETUP.md`)
- Jira access with at least one ticket to test
- (Optional) AIO Tests access for TCMS sync

---

## Step 1: Trigger Expert Analysis

1. Click **"Trigger Expert"** in Kiro's Agent Hooks panel
2. Provide: Jira ticket ID (e.g., `POS-1234`) and sprint version number
3. The Expert agent:
   - Fetches the ticket, linked tickets, comments, and attachments from Jira
   - Fetches PR diffs from Azure DevOps (if configured)
   - Fetches linked Confluence docs
   - Analyzes Jira image attachments for UI requirements
   - Creates the folder structure and generates output

**Output** (in `1_Expert/`):
- `logic_explanation.md` — Logic audit, gap analysis, architecture
- `test_plan_PENDING.md` — Draft test plan
- `manual_input.md` — Template for your manual observations

---

## Step 2: Add Human Input (Optional)

Fill `manual_input.md` with observations from exploratory testing:
- What you noticed testing the feature
- Edge cases discovered
- Environment-specific behaviors

When done, rename to `manual_input_OK.md` → triggers test plan revision with your input merged.

---

## Step 3: Approve Test Plan

Review `test_plan_PENDING.md`:

| Action | Rename to | What happens |
|--------|-----------|--------------|
| Approve as-is | `test_plan_OK.md` | Triggers Validator (generates test cases) |
| Request changes | `test_plan_UPDATED.md` | Triggers revision (add comments in the file) |

---

## Step 4: Review Test Cases

The Validator generates `2_Validator/FINAL_TEST_CASES_{TICKET}_PENDING.md`.

Review the structured test cases, then:

| Action | Rename to | What happens |
|--------|-----------|--------------|
| Approve | `_OK.md` | Ready for export or execution |
| Request changes | `_UPDATED.md` | Triggers revision |
| Push to AIO | `_API.md` | Triggers AIO sync |

---

## Step 5: Export (Choose One)

| Method | How | Output |
|--------|-----|--------|
| **AIO Tests** | Rename test cases to `_API.md` OR click "Trigger AIO Direct" | `AIO_SYNC_LOG.md` at ticket root |
| **CSV** | Click "Trigger Exporter" | `{TICKET}_TCMS_Import.csv` in `2_Validator/` |

---

## Step 6: Execute Tests & Collect Evidence

1. Execute test cases manually against the build under test
2. Drop evidence into `3_Evidence/` subfolders:

| Subfolder | What goes there |
|-----------|----------------|
| `screenshots/` | UI screenshots (.png, .jpg) |
| `localstate/` | App logs (.log), databases (.db) |
| `external/` | API responses, cloud data |
| `manual/` | Manual notes, scenario descriptions |

Evidence can be named freely — the Reviewer uses content-based matching.

---

## Step 7: Trigger Review

Click **"Trigger Reviewer"** in the Agent Hooks panel (with any ticket file open).

The Reviewer agent:
- Scans ALL evidence files (logs, screenshots, databases)
- Analyzes images visually using the Image Extractor MCP
- Queries LiteDB databases for data validation
- Cross-references against test case expected results
- Produces a verdict

**Output** (in `4_Reviewer/`):
- `EXECUTION_FINDINGS_{TICKET}.md` — Detailed findings per test case
- `FINAL_CLOSURE_REPORT_{TICKET}.md` — Overall verdict

**Re-triggerable:** You can add more evidence and re-trigger at any time.

---

## Step 8: Approve Closure

Review the closure report:

| Verdict | Action | What happens |
|---------|--------|--------------|
| STABLE | Rename to `_STABLE.md` | Dashboard + Lessons Learned generated automatically |
| UNSTABLE | Rename to `_REMEDIATE.md` | Triggers remediation cycle (updates test cases) |

---

## Pipeline Flow Summary

```
Expert → [human review] → Validator → [human review] → Export/AIO
                                                         ↓
                                       Execute tests, drop evidence to 3_Evidence/
                                                         ↓
                                       Reviewer → STABLE or UNSTABLE
                                          ↓                    ↓
                                    Dashboard + Learn     Remediation loop
```

---

## Key Concepts

| Concept | Description |
|---------|-------------|
| Suffix convention | `_PENDING` → `_OK` → next stage. Human renames drive the pipeline. |
| Shared Brain | Agents read past lessons before working (RECALL) and write back on closure (LEARN) |
| Snapshots | Files are backed up before overwrites (in `5_Snapshots/`) |
| Remediation | UNSTABLE verdicts enter a loop: adjust test cases → re-execute → re-review |
| Image analysis | Reviewer uses `mcp-image-extractor` to visually analyze screenshots |

---

## Folder Structure

```
{year}/Q{N}/Version {V}/PROJ-{ticket} - {description}/
├── 1_Expert/       # Test plan, logic analysis, manual input
├── 2_Validator/    # Structured test cases, CSV export
├── 3_Evidence/     # Raw execution data (logs, screenshots, DBs)
│   ├── screenshots/
│   ├── localstate/
│   ├── external/
│   └── manual/
├── 4_Reviewer/     # Findings and closure report
├── 5_Snapshots/    # Auto-backups
└── 6_Automation/   # Test scripts (optional)
```

---

## Need Help?

- `SETUP.md` — MCP server configuration and troubleshooting
- `.kiro/steering/` — All framework rules and workflows
- `.kiro/memory/` — Shared Brain knowledge base (grows as you work)
