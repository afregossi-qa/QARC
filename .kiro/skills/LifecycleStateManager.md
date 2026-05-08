# Lifecycle State Manager Skill

## Purpose
Manages the `.state.json` file in ticket folders to track pipeline phase transitions.

## Usage
Call this skill when entering or exiting a pipeline phase.

## Functions

### initState(ticketId, ticketPath)
Creates initial `.state.json` when a ticket folder is hydrated.

```json
{
  "ticketId": "{ticketId}",
  "currentPhase": "INIT",
  "phases": {
    "INIT": { "enteredAt": "{ISO_TIMESTAMP}", "exitedAt": null }
  },
  "lastAgent": "ProjectHydrator",
  "lastUpdated": "{ISO_TIMESTAMP}",
  "remediationCount": 0,
  "verdict": null
}
```

### transitionTo(ticketPath, newPhase, agentName)
Transitions to a new phase:
1. Read current `.state.json`
2. Set `exitedAt` on current phase
3. Add new phase with `enteredAt`
4. Update `currentPhase`, `lastAgent`, `lastUpdated`
5. Write back to `.state.json`

### setVerdict(ticketPath, verdict)
Sets the final verdict (STABLE/UNSTABLE):
1. Read current `.state.json`
2. Set `verdict` field
3. If UNSTABLE, increment `remediationCount`
4. Write back

### getState(ticketPath)
Returns current state for dashboard aggregation.

## Phase Constants
```
INIT
EXPERT_DRAFT
EXPERT_OK
VALIDATOR_PENDING
VALIDATOR_OK
EXECUTION_PENDING
REVIEWER_PENDING
STABLE
UNSTABLE
REMEDIATION_R1, REMEDIATION_R2, ...
```

## Example Hook Integration

In hook prompt, add:
```
Use @LifecycleStateManager.md to:
1. Call transitionTo("{ticketPath}", "VALIDATOR_PENDING", "QA-Validator-Agent")
2. Proceed with your main task
```

## Error Handling
- If `.state.json` doesn't exist, call `initState` first
- If phase transition is invalid (e.g., INIT → REVIEWER_PENDING), log warning but proceed
- Never block agent execution due to state file issues
