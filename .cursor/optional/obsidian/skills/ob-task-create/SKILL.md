---
name: ob-task-create
description: Create a new task in the Obsidian vault. Use when the user asks to create a task, add a task, or log new work to track. Drafts first and waits for approval before writing any files. Config at ~/.obsidian-tasks/.
---

# ob-task-create — Create a new task

**Always draft first; write files only after user confirms.**

**Valid priorities**: `0 Low` · `1 Medium` · `2 High` · `3 Critical`

## Steps

1. Read `~/.obsidian-tasks/config.json` → get `vault_path`
2. Determine parent note + prefix:
   - Read `~/.obsidian-tasks/projects.json`, match key against current directory basename
   - If not found, infer from conversation or ask the user
3. Propose title, priority, and optional description — wait for user approval
4. After approval:
   a. Read `{vault}/Resources/Tasks/.meta.json`
   b. Increment counter for the prefix (e.g. `"PKB": 6` → `7`), write back
   c. Zero-pad to 4 digits: `PKB-0007`
   d. Write `{vault}/Resources/Tasks/{CODE} {clean-title}.md`:

```markdown
---
tags:
  - type/task
task-id: {CODE}
status: Backlog
priority: {priority}
parent: "[[{ParentName}]]"
created: {YYYY-MM-DD}
---

# {YYYY-MM-DD}

{description if provided, using ## and below for any sub-sections}
```

   e. Append to the parent note — find today's `# {YYYY-MM-DD}` section and add:
      `- [[{CODE} {clean-title}|{CODE}]] {title}`
      If today's section doesn't exist, append:
      ```
      # {YYYY-MM-DD}
      - [[{CODE} {clean-title}|{CODE}]] {title}
      ```
