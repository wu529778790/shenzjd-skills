export const meta = {
  name: 'publish-skill',
  description: 'Create and register a new skill in the repository',
  phases: [
    { title: 'Collect Info', detail: 'Gather skill name, description, emoji from user' },
    { title: 'Create Files', detail: 'Create SKILL.md, README.md, templates/' },
    { title: 'Register', detail: 'Update README, CLAUDE.md, daily-discovery.yml' },
    { title: 'Verify', detail: 'Check consistency across all files' },
    { title: 'Commit', detail: 'Stage, commit, and push' },
  ],
}

// Note: This script runs via Claude Code's Workflow runtime.
// phase(), agent(), parallel(), log() are provided by the runtime.
// Do NOT run with `node` directly.

phase('Collect Info')

const skillName = await agent('Ask the user for the skill name in kebab-case (e.g., my-new-skill). Just return the name, nothing else.', { label: 'info:name' })
const skillDesc = await agent('Ask the user for the English description of the skill. This will be used in the YAML frontmatter for AI tool matching. Format: "Use when user wants to [action]". Just return the description, nothing else.', { label: 'info:description' })
const skillEmoji = await agent('Ask the user for an emoji icon for the skill (e.g., 🔧, 📊, 🚀). Just return the emoji, nothing else.', { label: 'info:emoji' })
const needTemplates = await agent('Ask the user if this skill needs a templates/ directory. Return only "yes" or "no".', { label: 'info:templates' })

const name = skillName.trim()
const description = skillDesc.trim()
const emoji = skillEmoji.trim()
const title = name.split('-').map(w => w.charAt(0).toUpperCase() + w.slice(1)).join(' ')

log(`Creating skill: ${emoji} ${name}`)

phase('Create Files')

await parallel([
  () => agent(`Create the file /Users/mac/github/shenzjd-skills/${name}/SKILL.md with this content:

---
name: ${name}
description: ${description}
---

# ${emoji} ${title}

<中文一句话概述此 skill 的功能>

## Overview

<中文详细说明此 skill 的工作原理和价值>

## When to Use

- <英文触发条件 1>
- <英文触发条件 2>
- User inputs \`/${name}\`

**When NOT to Use:**
- <英文排除条件 1>
- <英文排除条件 2>

## Core Pattern

### Step 1: <中文步骤名>

<步骤说明，包含伪代码和示例>

### Step 2: <中文步骤名>

<步骤说明>

## Quick Reference

\`\`\`
/${name}                    # 默认用法
/${name} --option value     # 带参数用法
\`\`\`

| Parameter | Description | Default |
|-----------|-------------|---------|
| \`--option\` | 参数说明 | 默认值 |

## Common Mistakes

| Error | Correct Approach | Reason |
|-------|-----------------|--------|
| 错误做法 1 | 正确做法 1 | 原因 1 |
| 错误做法 2 | 正确做法 2 | 原因 2 |

Write the actual file using the Write tool. Follow the mixed language convention: English for frontmatter and When to Use, Chinese for Core Pattern and Common Mistakes.`, { label: 'create:skill-md', phase: 'Create Files' }),

  () => agent(`Create the file /Users/mac/github/shenzjd-skills/${name}/README.md with this content:

# ${emoji} ${title}

<English one-line description>

## Installation

\`\`\`bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s ${name} -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/${name} ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
\`\`\`

## Usage

\`\`\`
/${name}                    # Default usage
/${name} --option value     # With options
\`\`\`

| Parameter | Description | Default |
|-----------|-------------|---------|
| \`--option\` | Option description | Default value |

## Prerequisites

<List prerequisites>

Write the actual file using the Write tool.`, { label: 'create:readme-md', phase: 'Create Files' }),

  ...(needTemplates.trim().toLowerCase() === 'yes' ? [
    () => agent(`Create the directory /Users/mac/github/shenzjd-skills/${name}/templates/ and add a placeholder README.md explaining what templates are available. Use Bash mkdir -p and Write tools.`, { label: 'create:templates', phase: 'Create Files' })
  ] : [])
])

phase('Register')

await parallel([
  () => agent(`Update /Users/mac/github/shenzjd-skills/README.md:

1. Change the count on line 3 from "10" to "11" (or increment whatever the current number is)
2. Add a new row to the Skills Overview table (around line 28):
   | ${emoji} **${name}** | <English description> | \`/${name}\` |
3. Add a new install command to the "Install Individual Skills" code block:
   npx skills add wu529778790/shenzjd-skills -s ${name} -y

Use the Edit tool for each change. Read the file first to find exact line numbers.`, { label: 'register:readme', phase: 'Register' }),

  () => agent(`Update /Users/mac/github/shenzjd-skills/CLAUDE.md:

Add a new row to the "Current Skills" table (around line 41):
| \`${name}\` | <English trigger condition> | <English description> |

Use the Edit tool. Read the file first to find the exact location.`, { label: 'register:claude-md', phase: 'Register' }),

  () => agent(`Update /Users/mac/github/shenzjd-skills/.github/workflows/daily-discovery.yml:

Find the hardcoded skill list on line 44 (the \`for skill in ...\` line) and append "${name}" to the end of the list.

Use the Edit tool. Read the file first to find the exact line.`, { label: 'register:daily-discovery', phase: 'Register' })
])

phase('Verify')

const verifyResult = await agent(`Verify all files are consistent after adding the ${name} skill:

1. Read /Users/mac/github/shenzjd-skills/${name}/SKILL.md - check frontmatter has name and description
2. Read /Users/mac/github/shenzjd-skills/${name}/README.md - check installation command includes ${name}
3. Read /Users/mac/github/shenzjd-skills/README.md - check count is updated, skill is in table, install command exists
4. Read /Users/mac/github/shenzjd-skills/CLAUDE.md - check skill is in the table
5. Read /Users/mac/github/shenzjd-skills/.github/workflows/daily-discovery.yml - check ${name} is in the list

Report any inconsistencies. If all good, say "ALL OK".`, { label: 'verify:consistency', phase: 'Verify' })

log(`Verification: ${verifyResult}`)

phase('Commit')

const commitResult = await agent(`Stage and commit all changes for the new ${name} skill:

1. Run: git add -A
2. Run: git commit -m "🆕 新增 ${name} skill: ${description}"
3. Run: git push

Report the result of each command.`, { label: 'commit:push', phase: 'Commit' })

log(`Done! New skill ${emoji} ${name} has been published.`)
log(`Commit: ${commitResult}`)
