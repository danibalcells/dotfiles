---
name: ob-task-start
description: Fetch and start an Obsidian vault task. Use when the user inputs a bare task code (e.g. PKB-0003, D-0017) or says "start task PKB-0003", "work on PKB-0003", "fetch PKB-0003", or similar. Reads the task file and full parent note, marks the task In Progress, then executes Mode 1 (Explore → Plan → Critique → Propose).
---

# ob-task-start — Fetch and start a task

## Steps

1. Read `~/.obsidian-tasks/config.json` → get `vault_path`
2. `Glob("{vault}/Resources/Tasks/{CODE}*.md")` → read the matched task file. 
3. Parse the `parent:` frontmatter value (strip `[[` and `]]`)
4. Read `~/.obsidian-tasks/projects.json` to resolve the parent note path; if not found, `Glob("{vault}/**/{ParentName}.md")` to locate it
5. Read the full parent note for context
6. If the task status is not already `In Progress`, `Done`, or `Canceled`, update it to `In Progress` via `StrReplace` on the `status:` frontmatter line
7. Execute **Mode 1**. 