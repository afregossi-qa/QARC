#!/usr/bin/env bash
# PreToolUse/Write — Block writes that violate the QARC folder structure convention.
# Exits 2 (block) when a file destined for a numbered subfolder lands at ticket root,
# or a file destined for ticket root lands in the wrong numbered subfolder.

set -euo pipefail

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

# Only check paths inside dated ticket folders: 20xx/Qx/Version x/{TICKET_ID} - .../
if ! echo "$FILE_PATH" | grep -qE '/20[0-9]{2}/Q[1-4]/Version [0-9]+/[A-Z]+-[0-9]+'; then
    exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# Files in a numbered subfolder — always allow (internal subfolder rules are enforced by Claude via CLAUDE.md)
if echo "$FILE_PATH" | grep -qE '/(1_Expert|2_Validator|3_Evidence|4_Reviewer|5_Snapshots|6_Automation)/'; then
    exit 0
fi

# File is at ticket root — check against the allowed-root whitelist
ALLOWED=false

# Exact matches
for NAME in "QA_DASHBOARD.md" "PROGRESS_TRACKER.md" "SUMMARY.md" "AIO_SYNC_LOG.md" \
            "REMEDIATION_LOG.md" ".state.json" ".phase-trigger.md" ".env" \
            "EVIDENCE_READY.md" "EVIDENCE_GAP_REPORT.md"; do
    if [[ "$BASENAME" == "$NAME" ]]; then
        ALLOWED=true
        break
    fi
done

# Pattern matches
if [[ "$ALLOWED" == "false" ]]; then
    if echo "$BASENAME" | grep -qE '^[A-Z_]*_ERROR\.md$'; then ALLOWED=true; fi
    if echo "$BASENAME" | grep -qE '^Automation_Blueprint'; then ALLOWED=true; fi
    if echo "$BASENAME" | grep -qE '^\.gitkeep$'; then ALLOWED=true; fi
fi

if [[ "$ALLOWED" == "false" ]]; then
    echo "BLOCKED: '$BASENAME' must be written to a numbered subfolder (1_Expert/, 2_Validator/, 3_Evidence/, 4_Reviewer/) per QARC structure.md."
    echo "Allowed at ticket root: QA_DASHBOARD.md, SUMMARY.md, AIO_SYNC_LOG.md, PROGRESS_TRACKER.md, REMEDIATION_LOG.md, *_ERROR.md, .state.json, Automation_Blueprint*.md"
    exit 2
fi

exit 0
