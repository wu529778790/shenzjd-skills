# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a collection of Claude Code skills (slash-command plugins). Each skill lives in `skills/<skill-name>/` and consists of a `SKILL.md` definition file plus supporting resources (templates, configs). When a user invokes a skill, Claude Code reads its `SKILL.md` and follows the documented execution flow.

The project and all documentation are written in **Chinese (Mandarin)**.

## Skill Structure

```
skills/
  <skill-name>/
    SKILL.md              # Entry point: YAML frontmatter + execution flow
    templates/            # Skill-specific templates and configs
      themes.json         # Theme definitions (colors, badges, styles)
      *.md                # Handlebars-style Markdown templates
```

**SKILL.md** contains:
- YAML frontmatter with `description` (used by Claude Code to match user requests to skills)
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

1. Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`description` field is critical for skill matching)
2. Document the execution flow as numbered steps with embedded pseudocode
3. Add any templates to `skills/<skill-name>/templates/`
4. Register in the README.md skills table

## Claude Code Configuration

`.claude/settings.local.json` pre-authorizes: `WebFetch(domain:www.skills.sh)`, `WebSearch`, `Bash(gh auth *)`, `Bash(gh repo *)`, `Bash(git remote *)`. If a new skill needs additional permissions, add them here.
