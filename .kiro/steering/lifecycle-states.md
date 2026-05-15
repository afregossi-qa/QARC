---
inclusion: manual
description: Deprecated state machine documentation - kept for audit reference only
---

# Ticket Lifecycle State Machine

> **DEPRECATION NOTICE (v5.1 — April 17, 2026):** State-based routing via `.state.json` + `advance-phase.ps1` has been deprecated. Kiro's `fileCreated` event does not reliably detect files created by external processes (PowerShell), causing the router hook to miss triggers. The pipeline has reverted to file-rename triggers (suffix convention) as the primary mechanism. The `.state.json` files remain for reference/audit but are no longer used to drive pipeline transitions.

## Overview
Each ticket folder may contain a `.state.json` file that tracks pipeline phase history for audit purposes. This file is no longer used for routing — the file-rename suffix convention drives all pipeline transitions.

## State File Schema (v2 — with Audit Log)

```json
{
  "ticketId": "PROJ-9967",
  "currentPhase": "VALIDATOR_PENDING",
  "phases": {
    "INIT": { "enteredAt": "2026-03-15T10:00:00Z", "exitedAt": "2026-03-15T10:05:00Z" },
    "EXPERT_DRAFT": { "enteredAt": "2026-03-15T10:05:00Z", "exitedAt": "2026-03-15T11:00:00Z" },
    "EXPERT_OK": { "enteredAt": "2026-03-15T11:00:00Z", "exitedAt": "2026-03-15T11:30:00Z" },
    "VALIDATOR_PENDING": { "enteredAt": "2026-03-15T11:30:00Z", "exitedAt": null }
  },
  "lastAgent": "QA-Validator-Agent",
  "lastUpdated": "2026-03-15T11:30:00Z",
  "remediationCount": 0,
  "verdict": null,
  "auditLog": [
    {
      "timestamp": "2026-03-15T10:00:00Z",
      "agent": "ProjectHydrator",
      "action": "initState",
      "fromPhase": null,
      "toPhase": "INIT",
      "note": "Ticket folder created and hydrated."
    },
    {
      "timestamp": "2026-03-15T10:05:00Z",
      "agent": "QA-Expert-Agent",
      "action": "transitionTo",
      "fromPhase": "INIT",
      "toPhase": "EXPERT_DRAFT",
      "note": "Expert started analysis."
    },
    {
      "timestamp": "2026-03-15T11:00:00Z",
      "agent": "human",
      "action": "transitionTo",
      "fromPhase": "EXPERT_DRAFT",
      "toPhase": "EXPERT_OK",
      "note": "Expert outputs approved."
    },
    {
      "timestamp": "2026-03-15T11:30:00Z",
      "agent": "QA-Validator-Agent",
      "action": "transitionTo",
      "fromPhase": "EXPERT_OK",
      "toPhase": "VALIDATOR_PENDING",
      "note": "Generated FINAL_TEST_CASES from approved test plan."
    }
  ]
}
```

### Audit Log Entry Schema

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `timestamp` | ISO 8601 | Yes | When the action occurred |
| `agent` | string | Yes | Agent name or `"human"` |
| `action` | enum | Yes | `initState`, `transitionTo`, `setVerdict`, `note` |
| `fromPhase` | string/null | Yes | Previous phase (null for init) |
| `toPhase` | string/null | Yes | New phase (null for notes) |
| `note` | string | Yes | What happened and why (max 120 chars) |

### Rules
- **Never overwrite** `auditLog` — always append.
- The deprecated `notes` field (singular string) should not be used.
- If a `.state.json` has no `auditLog` key, backfill from `phases` history on next write.

## Phase Definitions

| Phase | Description | Entry Trigger | Exit Trigger |
|-------|-------------|---------------|--------------|
| `INIT` | Folder created, awaiting analysis | Hydrator creates structure | Expert starts |
| `EXPERT_DRAFT` | Expert agent generating outputs | Expert hook triggered | Expert saves all 3 files |
| `EXPERT_OK` | Human approved Expert outputs | User renames to `_OK.md` | Validator hook triggered |
| `VALIDATOR_PENDING` | Validator generating test cases | Validator hook triggered | Validator saves FINAL_TEST_CASES |
| `VALIDATOR_OK` | Human approved test cases | User renames to `_OK.md` | Exporter or Reviewer triggered |
| `EXECUTION_PENDING` | Tests being executed | Evidence dropped | EVIDENCE_READY.md saved |
| `REVIEWER_PENDING` | Reviewer analyzing evidence | Reviewer hook triggered | Reviewer saves reports |
| `STABLE` | All tests passed | Reviewer verdict = STABLE | Ticket closed |
| `UNSTABLE` | Failures detected | Reviewer verdict = UNSTABLE | Remediation triggered |
| `REMEDIATION_Rn` | Iteration n of remediation | Remediation hook triggered | New test cases saved |

## State Transitions

```
INIT → EXPERT_DRAFT → EXPERT_OK → VALIDATOR_PENDING → VALIDATOR_OK
                                                          ↓
                                              EXECUTION_PENDING
                                                          ↓
                                              REVIEWER_PENDING
                                                    ↓         ↓
                                                STABLE    UNSTABLE
                                                              ↓
                                                      REMEDIATION_R1
                                                              ↓
                                                      (loop back to EXECUTION_PENDING)
```

## Agent Responsibilities

| Agent | Reads State | Writes State |
|-------|-------------|--------------|
| QA-Expert-Agent | INIT | EXPERT_DRAFT → EXPERT_OK |
| QA-Validator-Agent | EXPERT_OK | VALIDATOR_PENDING → VALIDATOR_OK |
| QA-Evidence-Reviewer-Agent | EXECUTION_PENDING | REVIEWER_PENDING → STABLE/UNSTABLE |
| QA-Dashboard-Agent | All phases | Never (read-only) |

## Usage in Hooks

Hooks should update `.state.json` when:
1. Entering a new phase (set `enteredAt`, clear `exitedAt`, append to `auditLog`)
2. Exiting a phase (set `exitedAt`)
3. Changing verdict (set `verdict` field, append to `auditLog`)
4. Starting remediation (increment `remediationCount`, append to `auditLog`)
5. Adding observations or corrections (append `"action": "note"` entry)

Example update in hook prompt:
```
After saving outputs, update .state.json via @LifecycleStateManager.md:
- Call transitionTo(ticketPath, "VALIDATOR_PENDING", "QA-Validator-Agent", "Generated FINAL_TEST_CASES from approved test plan.")
```

## State-Based Pipeline Router

The `state-pipeline-router.kiro.hook` watches for `.state.json` edits and automatically routes to the appropriate agent based on the `currentPhase` value.

### How It Works

1. Human reviews agent output (e.g., test plan in Expert/)
2. Human runs `advance-phase.ps1` or manually edits `.state.json`
3. Hook detects the edit and reads `currentPhase`
4. Hook checks `lastAgent` — if it's "human", proceeds; if it's an agent name, stops (prevents loops)
5. Hook routes to the appropriate agent workflow
6. Agent completes work and updates `lastAgent` to its name

### Routing Table

| currentPhase | Triggered Agent | Action |
|--------------|-----------------|--------|
| `EXPERT_OK` | QA-Validator-Agent | Generate test cases |
| `VALIDATOR_OK` | QA-Exporter-Agent | Generate CSV export |
| `VALIDATOR_CSV` | QA-Exporter-Agent | Export to CSV file |
| `VALIDATOR_API` | QA-AIO-Direct-Agent | Sync to AIO Tests |
| `VALIDATOR_REVISE` | QA-Validator-Agent | Revise test cases based on comments |
| `EXECUTION_PENDING` | None | Wait for evidence |
| `REVIEWER_PENDING` | QA-Evidence-Reviewer-Agent | Analyze evidence |
| `UNSTABLE` | Remediation workflow | Update test cases |
| `STABLE` | None | Pipeline complete |

### CLI Helper

Use the advance-phase script to transition phases:

```powershell
# After reviewing Expert outputs
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "EXPERT_OK"

# After reviewing test cases
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "VALIDATOR_OK"

# To revise test cases with feedback (add comments to FINAL_TEST_CASES file first)
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "VALIDATOR_REVISE"

# After dropping evidence
.\.kiro\scripts\advance-phase.ps1 -TicketPath "path/to/ticket" -NewPhase "REVIEWER_PENDING"
```

### Loop Prevention

The router checks `lastAgent` before executing:
- If `lastAgent` is an agent name → Agent just updated the file, do nothing
- If `lastAgent` is "human" → Human initiated the transition, proceed

This prevents infinite loops where an agent updates the state, triggering the router, which triggers the agent again.
