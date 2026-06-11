#!/usr/bin/env bash
# PostToolUse/Write — After a Shared Brain memory file is updated, auto-commit the changes.
# Triggers on: lessons_learned.md, pattern_registry.md, project_context.md

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

# Only trigger for Shared Brain memory files
case "$BASENAME" in
    lessons_learned.md|pattern_registry.md|project_context.md)
        ;;
    *)
        exit 0
        ;;
esac

# Navigate to repo root
REPO_ROOT=$(git -C "$(dirname "$FILE_PATH")" rev-parse --show-toplevel 2>/dev/null || echo "")
if [[ -z "$REPO_ROOT" ]]; then
    exit 0
fi

cd "$REPO_ROOT"

# Stage all memory files and product.md
git add ".kiro/memory/" ".kiro/steering/product.md" 2>/dev/null || exit 0

# Skip if nothing staged
if git diff --cached --quiet 2>/dev/null; then
    exit 0
fi

git commit -m "memory: shared brain learn phase update" 2>/dev/null
echo "Memory files committed"
exit 0
