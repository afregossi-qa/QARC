#!/usr/bin/env bash
# PreToolUse/Write — Before overwriting a file in 1_Expert/, 2_Validator/, or 4_Reviewer/,
# copy the existing file to 5_Snapshots/ with a timestamp suffix for rollback.

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

# Only snapshot files in the three mutable pipeline folders
if ! echo "$FILE_PATH" | grep -qE '/(1_Expert|2_Validator|4_Reviewer)/'; then
    exit 0
fi

# Skip .gitkeep files
BASENAME=$(basename "$FILE_PATH")
if [[ "$BASENAME" == ".gitkeep" ]]; then
    exit 0
fi

# Only snapshot if the file already exists (i.e., this is an overwrite)
if [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Derive the 5_Snapshots/ path from the file's ticket directory
TICKET_DIR=$(echo "$FILE_PATH" | sed -E 's|/(1_Expert|2_Validator|4_Reviewer)/.*||')
SNAPSHOTS_DIR="${TICKET_DIR}/5_Snapshots"
mkdir -p "$SNAPSHOTS_DIR"

TIMESTAMP=$(date +"%Y-%m-%dT%H-%M-%S")
EXT="${BASENAME##*.}"
NAME="${BASENAME%.*}"

SNAPSHOT_PATH="${SNAPSHOTS_DIR}/${NAME}_${TIMESTAMP}.${EXT}"
cp "$FILE_PATH" "$SNAPSHOT_PATH"

echo "Snapshot saved: $SNAPSHOT_PATH"
exit 0
