---
name: ob-set-project
description: Configure the Obsidian task project mapping for the current repository — links a git repo to a parent note and task prefix in the vault. Use when the user says "set project", "configure project", "link this repo to tasks", or wants to set up Obsidian task tracking for a new repo. Config at ~/.obsidian-tasks/.
---

# ob-set-project — Configure project mapping for current repo

Parent path in `projects.json` is **always relative to vault root** (e.g. `Knowledge/Work Diary/My Project.md`).

## Steps

1. Read `~/.obsidian-tasks/config.json` → get `vault_path`
2. Read the current directory basename (e.g. `obsidian-bases-kanban`)
3. Read `~/.obsidian-tasks/projects.json` — show any existing entry for this repo
4. Ask the user for the parent note name (basename or relative path) if not provided

### Find the note in the vault

5. `Glob("{vault}/**/{input}*.md")` to locate matching notes
6. If multiple matches, prefer notes under `Knowledge/Work Diary/` — present the options to the user if still ambiguous
7. Determine the note's path **relative to vault root** (e.g. `Knowledge/Work Diary/Personal Knowledge Base.md`)

### Read task prefix from frontmatter

8. Read the matched note file
9. Extract the `task-prefix:` frontmatter value
10. If `task-prefix` is missing:
    - Ask the user if they want to add one
    - If yes: prompt for the prefix string, then `StrReplace` the frontmatter to add `task-prefix: {PREFIX}` after the `tags:` block (or before `---` if no tags)
    - If no: ask the user to provide the prefix to use in `projects.json`

### Write the mapping

11. Write/update the entry in `~/.obsidian-tasks/projects.json`:

```json
"{dir-basename}": {
  "parent": "{vault-relative/path/to/Note.md}",
  "task_prefix": "{PREFIX}"
}
```

12. Confirm the mapping to the user, showing the resolved note path and prefix
