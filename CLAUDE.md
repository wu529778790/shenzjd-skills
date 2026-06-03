# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A collection of AI coding assistant skills — prompt/rule documents that work across Claude Code, Cursor, Copilot, Windsurf, and other AI programming tools. Each skill is a `SKILL.md` file containing execution flow, parameters, and edge case handling that any AI tool can follow.

The project and all documentation are written in **Chinese (Mandarin)**.

## Skill Structure

```
<skill-name>/
  SKILL.md              # Entry point: YAML frontmatter + execution flow
  templates/            # Skill-specific templates and configs (optional)
    themes.json         # Theme definitions
    *.md                # Handlebars-style Markdown templates
```

**SKILL.md** contains:
- YAML frontmatter with `description` (used by tools like Claude Code to match user requests to skills)
- Step-by-step execution flow with embedded pseudocode
- Edge case handling (missing CLI tools, network errors, etc.)

**Templates** use `{{variable}}` and `{{#each items}}` syntax. Variables are injected at runtime from data gathered by the skill's execution flow (e.g., GitHub API responses).

## Current Skills

| Skill | Trigger | Description |
|-------|---------|-------------|
| `github-profile-beautifier` | User wants to create/improve GitHub profile README | Generates themed profile READMEs using GitHub API data |

## Runtime Dependencies

- **`gh` CLI** — required for GitHub API access (authentication, repo listing). Skills check for this at runtime.
- **External services** — templates reference third-party image/stats services (shields.io, github-readme-stats, etc.) that the end user's README will use.

## Adding a New Skill

1. Create `<skill-name>/SKILL.md` with YAML frontmatter (`description` field is critical for skill matching)
2. Document the execution flow as numbered steps with embedded pseudocode
3. Add any templates to `<skill-name>/templates/`
4. Register in the README.md skills table

## Claude Code Configuration

`.claude/settings.local.json` pre-authorizes: `WebFetch(domain:www.skills.sh)`, `WebSearch`, `Bash(gh auth *)`, `Bash(gh repo *)`, `Bash(git remote *)`. If a new skill needs additional permissions, add them here.
