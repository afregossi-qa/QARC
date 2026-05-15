# Skill: Lifecycle-State-Manager

## Purpose
Manages the `.state.json` file in ticket folders to track pipeline phase transitions with a full audit trail.

## Schema (v2 — with Audit Log)

```json
{
  "ticketId": "{TICKET_ID}",
  "currentPhase": "VALIDATOR_PENDING",
  "phases": {
    "INIT": { "enteredAt": "ISO", "exitedAt": "ISO" },
    "EXPERT_DRAFT": { "enteredAt": "ISO", "exitedAt": "ISO" },
    "VALIDATOR_PENDING": { "enteredAt": "ISO", "exitedAt": null }
  },
  "lastAgent": "QA-Validator-Agent",
  "lastUpdated": "ISO",
  "remediationCount": 0,
  "verdict": null,
  "auditLog": [
    {
      "timestamp": "ISO",
      "agent": "agent-name or human",
      "action": "initState | transitionTo | setVerdict | note",
      "fromPhase": "previous phase or null",
      "toPhase": "new phase or null",
      "note": "Brief description of what happened and why"
    }
  ]
}
```

## Functions

### initState(ticketId, ticketPath)
Creates initial `.state.json` with the first audit log entry.

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
  "verdict": null,
  "auditLog": [
    {
      "timestamp": "{ISO_TIMESTAMP}",
      "agent": "ProjectHydrator",
      "action": "initState",
      "fromPhase": null,
      "toPhase": "INIT",
      "note": "Ticket folder created and hydrated."
    }
  ]
}
```

### transitionTo(ticketPath, newPhase, agentName, note)
Transitions to a new phase AND appends to audit log:
1. Read current `.state.json`
2. Set `exitedAt` on current phase to now
3. Add new phase with `enteredAt` = now
4. Update `currentPhase`, `lastAgent`, `lastUpdated`
5. **Append** to `auditLog` array:
   ```json
   {
     "timestamp": "{ISO_TIMESTAMP}",
     "agent": "{agentName}",
     "action": "transitionTo",
     "fromPhase": "{previousPhase}",
     "toPhase": "{newPhase}",
     "note": "{note}"
   }
   ```
6. Write back to `.state.json`

### setVerdict(ticketPath, verdict, agentName, note)
Sets the final verdict (STABLE/UNSTABLE) and logs it:
1. Read current `.state.json`
2. Set `verdict` field
3. If UNSTABLE, increment `remediationCount`
4. **Append** to `auditLog`:
   ```json
   {
     "timestamp": "{ISO_TIMESTAMP}",
     "agent": "{agentName}",
     "action": "setVerdict",
     "fromPhase": "{currentPhase}",
     "toPhase": "{verdict}",
     "note": "{note}"
   }
   ```
5. Write back

### addNote(ticketPath, agentName, note)
Appends a non-transition audit entry (for corrections, observations, or human notes):
1. Read current `.state.json`
2. Update `lastUpdated`
3. **Append** to `auditLog`:
   ```json
   {
     "timestamp": "{ISO_TIMESTAMP}",
     "agent": "{agentName}",
     "action": "note",
     "fromPhase": null,
     "toPhase": null,
     "note": "{note}"
   }
   ```
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

## Rules
- **Never overwrite** the `auditLog` — always append.
- The `note` field is mandatory on every audit entry. Keep it under 120 chars.
- `agent` must be the actual agent name or `"human"` for manual transitions.
- The `notes` field (singular string) from schema v1 is deprecated. Do not use it.

## Example Hook Integration

In hook prompt, add:
```
Use @LifecycleStateManager.md to:
1. Call transitionTo("{ticketPath}", "VALIDATOR_PENDING", "QA-Validator-Agent", "Generated FINAL_TEST_CASES from approved test plan.")
2. Proceed with your main task
```

## Error Handling
- If `.state.json` doesn't exist, call `initState` first
- If `.state.json` exists but has no `auditLog` key, create the array and backfill from `phases` history
- If phase transition is invalid (e.g., INIT → REVIEWER_PENDING), log warning in audit but proceed
- Never block agent execution due to state file issues
