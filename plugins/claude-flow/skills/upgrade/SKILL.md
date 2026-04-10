---
name: upgrade
description: "Upgrade claude-flow plugin and project-level configuration"
argument-hint: [--force]
---

# /upgrade

Upgrades the current project's claude-flow configuration. Handles both plugin updates and project-level file upgrades.

## Phase 1: Plugin Update

1. Check if claude-flow is installed as a plugin:
   - Run `/plugin update claude-flow` to get the latest version
   - If not installed as a plugin, suggest: `/plugin marketplace add CookiRui/claude-flow && /plugin install claude-flow@claude-flow`

2. Report what changed in the plugin update (new skills, agents, hooks).

## Phase 2: Project-Level Files

Check project-level files that are NOT managed by the plugin:

1. For each project-level file, classify:

| Status | Condition | Action |
|--------|-----------|--------|
| **OUTDATED** | File uses older patterns or missing new sections | Suggest update |
| **CUSTOM** | User has customized the file | Show what's new, let user decide |
| **CURRENT** | File is up to date | Skip |

2. Files to check:
   - `.claude/constitution.md` — check for new governance sections
   - `.claude/rules/*.md` — check for new rule patterns
   - `REVIEW.md` — check for new review dimensions
   - `.claudeignore` — check for new ignore patterns

3. Output a summary table and ask user to confirm changes.

## Phase 3: Apply

- **OUTDATED**: Apply update, show brief diff of what changed.
- **CUSTOM**: Show side-by-side diff. Options: (a) Keep mine (b) Take upstream (c) Merge
- **CURRENT**: Skip.

## Phase 4: Post-upgrade

1. List all changes made.
2. If new skills were added to the plugin, mention them.
3. Suggest: `git add .claude/ && git commit -m "chore: upgrade claude-flow configuration"`

## Notes

- Never delete user files.
- Never overwrite user customizations without explicit confirmation.
- Custom skills in `.claude/skills/` that are not part of the plugin are left untouched.
