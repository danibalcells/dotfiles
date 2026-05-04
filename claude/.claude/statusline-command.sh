#!/usr/bin/env bash
input=$(cat)

IFS=$'\t' read -r model used project_dir cost < <(python3 -c '
import json, sys
d = json.loads(sys.stdin.read() or "{}")
fields = [
    (d.get("model") or {}).get("display_name", "") or "",
    str((d.get("context_window") or {}).get("used_percentage", "") or ""),
    (d.get("workspace") or {}).get("project_dir") or (d.get("workspace") or {}).get("current_dir", "") or "",
    str((d.get("cost") or {}).get("total_cost_usd", "") or ""),
]
print("\t".join(fields))
' <<<"$input")

project_name=""
[ -n "$project_dir" ] && project_name=$(basename "$project_dir")

branch=""
dirty=""
if [ -n "$project_dir" ] && git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$project_dir" symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$project_dir" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$(git -C "$project_dir" status --porcelain 2>/dev/null)" ]; then
        dirty="*"
    fi
fi

# [Model]
[ -n "$model" ] && printf '\033[01;35m[%s]\033[00m' "$model"

# project-name
[ -n "$project_name" ] && printf ' \033[01;34m%s\033[00m' "$project_name"

# (branch*)
[ -n "$branch" ] && printf ' \033[01;32m(%s%s)\033[00m' "$branch" "$dirty"

# ctx:N%
[ -n "$used" ] && printf ' ctx:%.0f%%' "$used"

# $cost (only if > 0)
if [ -n "$cost" ]; then
    nonzero=$(python3 -c "import sys; print('1' if float(sys.argv[1]) > 0 else '')" "$cost" 2>/dev/null)
    [ -n "$nonzero" ] && printf ' \033[01;33m$%.2f\033[00m' "$cost"
fi

printf '\n'
