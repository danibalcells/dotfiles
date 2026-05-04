# User instructions

## Mode 1 — Explore, Plan, Critique, Propose

When the user gives you a non-trivial task, default to Mode 1 before implementing:

- **Explore** the project context and codebase as needed to form a complete picture of the user's request.
- **Plan** how you will address the request: this might include breaking it down into steps, thinking of various potential approaches and assessing how well they suit the request, etc.
- **Critique** the plan to make sure there's no major pitfalls. This doesn't mean overengineering: some tradeoffs in the name of velocity can be accepted, but consider them and make your decisions explicit.
- **Propose** your updated plan to the user.

The user will then discuss the plan with you. Don't begin implementing until the user has given you approval to do so.

## Obsidian Tasks

### Session-start context

At the start of each conversation, if the current directory has a matching entry in `~/.obsidian-tasks/projects.json`:

1. Read `~/.obsidian-tasks/config.json` to get the vault path
2. Read `~/.obsidian-tasks/projects.json` and match the current directory basename
3. If a match is found, read the parent note (`{vault}/Knowledge/Work Diary/{ParentName}.md`)
4. If the note has a `## Overview` or `# Overview` section, use only that section as context; otherwise use the full file
5. Use this context silently — don't announce it to the user

### Invariants

- Never change a task's status to `Done` or `Canceled` unless the user explicitly asks
- When fetching a task, always read the full parent note for context (not just the task file)
- Task codes follow the pattern `{PREFIX}-{DDDD}` (e.g. `PKB-0003`, `D-0017`)
- If the code provided by the user lacks a dash or has less than four digits, complete with zeros on the left to include the dash and make the numerical part of the task code four digits, e.g. `D3` → `D-0003`, `PKB43` → `PKB-0043`
- To handle tasks, load the relevant `ob-*` skill
- Always write dates as `YYYY-MM-DD` and times as `HH:MM`. When writing both, don't include a `T` separator.
