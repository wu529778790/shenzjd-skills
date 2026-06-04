# 🎨 GitHub Profile Beautifier

One-click generation of beautiful GitHub profile READMEs. Auto-detects repos, analyzes tech stacks, and intelligently recommends projects and themes.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s github-profile-beautifier -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/github-profile-beautifier ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/github-profile-beautifier username
/github-profile-beautifier username --sort stars --theme tokyonight
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `username` | GitHub username | Interactive prompt |
| `--sort` | `stars` / `smart` / `updated` | `smart` |
| `--theme` | `radical` / `tokyonight` / `dracula` / `minimalist` / `professional` | `radical` |

## Themes

| Theme | Style | Best For |
|-------|-------|----------|
| radical | Vibrant, colorful | Personal projects, creative dev (default) |
| tokyonight | Modern, dark | Tech showcase |
| dracula | Dark, purple | Dark theme, eye-friendly |
| minimalist | Clean, professional | Corporate users, formal occasions |
| professional | Business, blue | Job seekers, corporate showcase |

## Prerequisites

- **`gh` CLI** — Must be installed and authenticated (`gh auth login`)
- **Snake contribution graph** (optional) — Dark themes include a snake contribution graph; requires forking [platane/snk](https://github.com/platane/snk) and setting up GitHub Actions
