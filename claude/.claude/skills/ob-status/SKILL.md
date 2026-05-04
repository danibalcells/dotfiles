---
name: ob-status
description: Update the status of an Obsidian vault task. Use when the user asks to update, change, or set the status of a task like PKB-0003 or D-0017, or says "mark as In Progress", "set to Done", etc. Config at ~/.obsidian-tasks/.
---

# ob-status — Update task status

**Valid statuses**: `To Do` · `In Progress` · `Backlog` · `Done` · `Canceled`

**Invariant**: never change to `Done` or `Canceled` unless the user explicitly requests it.

## Steps

1. Read `~/.obsidian-tasks/config.json` → get `vault_path`
2. `Glob("{vault}/Resources/Tasks/{CODE}*.md")` → read the matched file
3. `StrReplace` the `status:` line in frontmatter with the new value
4. Confirm the update to the user
