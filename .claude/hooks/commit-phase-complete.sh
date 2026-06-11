#!/usr/bin/env bash
# PostToolUse/Write — After a key pipeline output is written, auto-commit the ticket folder.
# Triggers on: test_plan_PENDING.md, FINAL_TEST_CASES_*_PENDING.md,
#              EXECUTION_FINDINGS_*.md, FINAL_CLOSURE_REPORT_*.md, AIO_SYNC_LOG.md

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

BASENAME=$(basename "$FILE_PATH")

# Determine which phase completed
PHASE=""
TICKET_DIR=""

case "$BASENAME" in
    test_plan_PENDING.md)
        PHASE="Expert"
        TICKET_DIR=$(echo "$FILE_PATH" | sed -E 's|/1_Expert/.*||')
        ;;
    FINAL_TEST_CASES_*_PENDING.md)
        PHASE="Validator"
        TICKET_DIR=$(echo "$FILE_PATH" | sed -E 's|/2_Validator/.*||')
        ;;
    EXECUTION_FINDINGS_*.md)
        PHASE="Reviewer"
        TICKET_DIR=$(echo "$FILE_PATH" | sed -E 's|/4_Reviewer/.*||')
        ;;
    FINAL_CLOSURE_REPORT_*.md)
        PHASE="Reviewer"
        TICKET_DIR=$(echo "$FILE_PATH" | sed -E 's|/4_Reviewer/.*||')
        ;;
    AIO_SYNC_LOG.md)
        PHASE="AIO-Sync"
        TICKET_DIR=$(dirname "$FILE_PATH")
        ;;
    *)
        exit 0
        ;;
esac

# Extract ticket ID (e.g., POS-1234, ACV2-642) from folder name
TICKET_ID=$(basename "$TICKET_DIR" | grep -oE '[A-Z]+-[0-9]+' || echo "")
if [[ -z "$TICKET_ID" ]]; then
    exit 0
fi

# Navigate to repo root and commit
REPO_ROOT=$(git -C "$(dirname "$FILE_PATH")" rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -z "$REPO_ROOT" ]]; then
    exit 0
fi

cd "$REPO_ROOT"
git add "${TICKET_DIR}/" 2>/dev/null || exit 0

# Skip commit if nothing staged
if git diff --cached --quiet 2>/dev/null; then
    exit 0
fi

git commit -m "${TICKET_ID}: ${PHASE} phase complete" 2>/dev/null
echo "Committed: ${TICKET_ID} ${PHASE} phase"
exit 0
