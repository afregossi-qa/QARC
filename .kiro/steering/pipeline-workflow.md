---
inclusion: manual
---

# QA Pipeline Workflow Guide

## Overview

The QA pipeline uses **automatic hook triggering** via the `advance-phase.ps1` script. When you run the script, it creates a `.phase-trigger.md` file that Kiro detects, automatically invoking the appropriate agent.


## How It Works

```
1. Run advance-phase.ps1 script
       ↓
2. Script updates .state.json + creates .phase-trigger.md
       ↓
3. Kiro detects new file (fileCreated event)
       ↓
4. state-pipeline-router hook fires automatically
       ↓
5. Hook reads state, deletes trigger file, routes to agent
       ↓
6. Agent executes workflow, updates state
```

## Pipeline Phases

```
INIT → EXPERT_DRAFT → EXPERT_OK → VALIDATOR_PENDING → VALIDATOR_OK
                                                          ↓
                                              EXECUTION_PENDING
                                                          ↓
                                              REVIEWER_PENDING
                                                    ↓         ↓
                                                STABLE    UNSTABLE
```

## Phase Transitions

### Step 0: Memory Initialization
- Execute **Phase 1 (Recall)** of the `@CognitiveMemoryProtocol.md`. 
- Ensure you have read the latest `lessons_learned.md` before writing any Java code.

### Phase 1: Expert Analysis
**Trigger:** Click "Trigger Expert Analysis" hook OR ask: `@qa-expert-agent analyze POS-XXXX`

**Outputs:**
- `1_Expert/logic_explanation.md`
- `1_Expert/test_plan_POS-XXXX.md`
- `1_Expert/manual_input.md`

### Phase 2: Validator (Test Case Generation)
**After reviewing Expert outputs, run:**

```powershell
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "EXPERT_OK"
```

**Hook triggers automatically** → QA-Validator-Agent generates test cases

**Outputs:**
- `2_Validator/FINAL_TEST_CASES_POS-XXXX_PENDING.md`

### Phase 2b: Revise Test Cases (Optional)
**If test cases need revision based on feedback:**

1. Add comments to `FINAL_TEST_CASES_POS-XXXX_PENDING.md` using:
   - HTML comments: `<!-- Add edge case for empty input -->`
   - Or inline markers: `[COMMENT: Need to add negative test]`

2. Run:
```powershell
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "VALIDATOR_REVISE"
```

**Hook triggers automatically** → QA-Validator-Agent reads comments, revises test cases, removes addressed comments

### Phase 3: Export (CSV or AIO)
**After reviewing test cases, choose your export method:**

```powershell
# For CSV export:
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "VALIDATOR_CSV"

# For AIO API sync:
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "VALIDATOR_API"
```

**Hook triggers automatically** → Appropriate exporter agent runs

**Outputs:**
- CSV: `2_Validator/POS-XXXX_TCMS_Import.csv`
- AIO: `AIO_SYNC_LOG.md` at ticket root

### Phase 4: Evidence Collection
**Manual step:** Execute test cases and drop evidence files into `3_Evidence/`

Naming convention: `tc01_description.json`, `tc02_screenshot.png`

**When done, run:**
```powershell
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "REVIEWER_PENDING"
```

**Hook triggers automatically** → QA-Evidence-Reviewer-Agent analyzes evidence

### Phase 5: Review Complete
**Outputs:**
- `4_Reviewer/EXECUTION_FINDINGS_POS-XXXX.md`
- `4_Reviewer/FINAL_CLOSURE_REPORT_POS-XXXX.md`
- `.state.json` updated to STABLE or UNSTABLE

## Quick Reference

| Phase | Command | Auto-Triggered Agent |
|-------|---------|---------------------|
| Start Expert | Click hook or ask agent | QA-Expert-Agent |
| Start Validator | `advance-phase.ps1 -NewPhase "EXPERT_OK"` | QA-Validator-Agent |
| Revise Test Cases | `advance-phase.ps1 -NewPhase "VALIDATOR_REVISE"` | QA-Validator-Agent (revision mode) |
| Export CSV | `advance-phase.ps1 -NewPhase "VALIDATOR_CSV"` | QA-Exporter-Agent |
| Export AIO | `advance-phase.ps1 -NewPhase "VALIDATOR_API"` | QA-AIO-Direct-Agent |
| Start Review | `advance-phase.ps1 -NewPhase "REVIEWER_PENDING"` | QA-Evidence-Reviewer-Agent |

## Technical Details

### Trigger Mechanism
- Script creates `.phase-trigger.md` in ticket root
- Kiro's `fileCreated` event detects the new file
- `state-pipeline-router` hook reads the trigger, then deletes it
- Hook routes to appropriate agent based on `currentPhase` in `.state.json`

### Files at Ticket Root
| File | Purpose |
|------|---------|
| `.state.json` | Pipeline state tracker |
| `.phase-trigger.md` | Temporary trigger file (auto-deleted) |
| `PROGRESS_TRACKER.md` | Human-readable status |
| `AIO_SYNC_LOG.md` | AIO sync history |

## Troubleshooting

**Hook didn't trigger?**
- Check if `.phase-trigger.md` was created in the ticket folder
- Ensure Kiro is running and watching the workspace
- Try running the script again

**Agent not finding ticket?**
- Ensure `.state.json` exists in ticket root
- Ensure `lastAgent` is set to "human" (not an agent name)

**Manual fallback:**
If automatic triggering fails, you can always ask the agent directly:
- `@qa-validator-agent generate test cases for POS-XXXX`
- `@qa-exporter-agent export test cases for POS-XXXX`
- `@qa-evidence-reviewer-agent review evidence for POS-XXXX`
