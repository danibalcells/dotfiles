---
name: ob-task-comment
description: Add a comment or note to an existing Obsidian vault task. Use when the user asks to add a note, comment, update, or log progress on a task like PKB-0003. Config at ~/.obsidian-tasks/.
---

# ob-task-comment — Add a comment to a task

## Steps

1. Read `~/.obsidian-tasks/config.json` → get `vault_path`
2. `Glob("{vault}/Resources/Tasks/{CODE}*.md")` → read the matched file
3. Append to the task file:

```
---
# {YYYY-MM-DD HH:MM}

{content, using ## and below for any sub-sections — no additional H1s}
```

   Timestamp format: `YYYY-MM-DD HH:MM` in local time (no T separator, no UTC/Z suffix).
