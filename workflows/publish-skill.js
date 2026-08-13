export const meta = {
  name: 'publish-skill',
  description: 'Create and register a new skill in the repository',
  phases: [
    { title: 'Collect Info', detail: 'Gather skill name, description, emoji from user' },
    { title: 'Create Files', detail: 'Create SKILL.md, README.md, templates/' },
    { title: 'Register', detail: 'Update README.md, README.zh.md, tests coverage' },
    { title: 'Verify', detail: 'Check consistency across all files' },
    { title: 'Commit', detail: 'Stage, commit, and push' },
  ],
}

// Note: This script runs via Claude Code's Workflow runtime.
// phase(), agent(), parallel(), log() are provided by the runtime.
// Do NOT run with `node` directly.
// 路径约定: workflow 在仓库根目录运行, 一律使用相对路径(不要硬编码绝对路径)。

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
  () => agent(`Create the file ${name}/SKILL.md with this content:

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

  () => agent(`Create the file ${name}/README.md with this content:

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
    () => agent(`Create the directory ${name}/templates/ and add a placeholder README.md explaining what templates are available. Use Bash mkdir -p and Write tools.`, { label: 'create:templates', phase: 'Create Files' })
  ] : [])
])

phase('Register')

await parallel([
  () => agent(`Update README.md for the new skill ${name}:

1. Read README.md first. Find the line starting with "> " that contains a skill count (e.g. "> 5 production-ready AI coding skill modules"). Increment the number by 1 (e.g. 5 → 6). The count must equal the number of rows in the Skills Overview table.
2. Add a new row to the "Skills Overview" table (alphabetical order by skill name is fine, otherwise append at the end):
   | ${emoji} **${name}** | <English description> | \`/${name}\` |
3. Add a new install command to the "Install Individual Skills" code block:
   npx skills add wu529778790/shenzjd-skills -s ${name} -y

Use the Edit tool for each change. Do not edit .well-known/agent-skills/index.json (CI regenerates it).`, { label: 'register:readme', phase: 'Register' }),

  () => agent(`Update README.zh.md for the new skill ${name}:

1. Read README.zh.md first. Find the line starting with "> " that contains a skill count (e.g. "> 5 个生产级 AI 编程技能模块"). Increment the number by 1 (e.g. 5 → 6). The count must equal the number of rows in the 技能一览 table.
2. Add a new row to the "技能一览" table (alphabetical order by skill name is fine, otherwise append at the end):
   | ${emoji} **${name}** | <中文说明> | \`/${name}\` |
3. Add a new install command to the "单独安装某个 Skill" code block:
   npx skills add wu529778790/shenzjd-skills -s ${name} -y

Use the Edit tool for each change. Do not edit .well-known/agent-skills/index.json (CI regenerates it).`, { label: 'register:readme-zh', phase: 'Register' }),

  () => agent(`Update tests/README.md for the new skill ${name}:

1. Read tests/README.md first. Add a row to the "测试覆盖" coverage table:
   | ${name} | ✅ | ✅ | ✅ |
2. If a unit test file tests/skills/${name}.test.sh was NOT created yet, create one by mirroring an existing test (e.g. tests/skills/git-hooks-setup.test.sh): check the skill's SKILL.md sections and any templates/scripts files exist, report PASS/FAIL. Make it a static check that does not require network access.

Use the Edit and Write tools.`, { label: 'register:tests', phase: 'Register' }),

  () => agent(`Update CLAUDE.md for the new skill ${name} (only if a count or list needs updating):

1. Read CLAUDE.md first. If it contains a hardcoded skill count (e.g. "Five skills cover the DevOps pipeline"), increment/adjust it to match reality.
2. If the "Adding a new skill" section exists, no change is needed there — it already describes the generic flow.

Note: daily-discovery.yml uses a dynamic \`for skill in */\` loop — no hardcoded skill list to update. Do NOT modify it. Use the Edit tool if a count needs updating; otherwise report "no change needed".`, { label: 'register:claude-md', phase: 'Register' })
])

phase('Verify')

const verifyResult = await agent(`Verify all files are consistent after adding the ${name} skill:

1. Read ${name}/SKILL.md - check frontmatter has name and description, and has the 5 required sections: Overview, When to Use, Core Pattern, Quick Reference, Common Mistakes
2. Read ${name}/README.md - check installation command includes ${name}
3. Read README.md - check count matches table rows, skill is in table, install command exists
4. Read README.zh.md - check count matches table rows, skill is in table
5. Read tests/README.md - check ${name} is in the coverage table
6. Check tests/skills/${name}.test.sh exists and is executable (chmod +x if not)
7. Run ./tests/validate-skills.sh and confirm it passes (warnings about missing sections are failures for a new skill)

Report any inconsistencies. If all good, say "ALL OK".`, { label: 'verify:consistency', phase: 'Verify' })

log(`Verification: ${verifyResult}`)

phase('Commit')

const commitResult = await agent(`Stage and commit all changes for the new ${name} skill:

1. Run: git add -A
2. Run: git commit -m "🆕 新增 ${name} skill: ${description}"
3. Report the result. Do NOT push — the user will review first.

Report the result of each command.`, { label: 'commit', phase: 'Commit' })

log(`Done! New skill ${emoji} ${name} has been created.`)
log(`Commit: ${commitResult}`)
