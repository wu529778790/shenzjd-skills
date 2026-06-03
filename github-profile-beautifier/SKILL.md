---
name: github-profile-beautifier
description: Use when user wants to create or improve their GitHub profile README, generate a new profile page, or beautify their existing GitHub homepage with stats, projects, and tech stack badges
---

# GitHub Profile Beautifier

一键生成漂亮的 GitHub 个人主页 README。自动检测仓库、分析技术栈、智能推荐项目和主题。

## When to Use

- 用户想要创建 GitHub 个人主页
- 用户想要美化现有的 README
- 用户想要展示项目和技术栈
- 用户输入 `/github-profile-beautifier [username]`

**When NOT to Use:**
- 用户只是想修改现有 README 的小部分
- 用户已经有完美的 README，只是想微调
- 用户想要创建非 GitHub 的个人主页

## Core Pattern

### 执行流程

```dot
digraph flow {
    "获取用户信息" -> "分析仓库";
    "分析仓库" -> "智能推荐";
    "智能推荐" -> "生成 README";
    "生成 README" -> "输出文件";
}
```

### Step 0: 解析参数

从用户输入中提取参数：

```
/github-profile-beautifier [username] [--sort stars|smart|updated] [--theme radical|tokyonight|dracula|minimalist|professional]
```

- `username`：GitHub 用户名（位置参数，可选）
- `--sort`：排序方式（默认 `smart`）
- `--theme`：主题风格（默认 `radical`）

如果用户未提供 username，交互式询问。如果未提供 `--sort` 和 `--theme`，交互式让用户选择。

### Step 1: 获取用户信息

使用 `gh` 命令获取用户基本信息和仓库列表：

```bash
# 检查 gh CLI 是否安装
if ! command -v gh &> /dev/null; then
  echo "错误：请先安装 gh CLI"
  echo "安装命令：brew install gh"
  exit 1
fi

# 检查用户是否存在
if ! gh api users/$USERNAME > /dev/null 2>&1; then
  echo "错误：用户 $USERNAME 不存在"
  exit 1
fi

# 获取用户信息
gh api users/$USERNAME --jq '.login,.name,.bio'

# 获取仓库列表
gh repo list $USERNAME --limit 50 --json name,description,primaryLanguage,url,updatedAt,stargazerCount,isFork
```

**关键点：**
- 使用 `gh api users/$USERNAME`（不是 `gh api user`），确保获取指定用户的信息
- `gh repo list` 添加 `isFork` 字段，用于后续筛选 fork 仓库
- 限制 50 个仓库，避免信息过载

### Step 2: 分析仓库

分析仓库信息，识别：
- 主要项目（根据排序方式选择）
- 技术栈（从语言分布和 package.json）
- 项目分类（AI Agent、前端、后端、工具等）

**分析逻辑：**
```typescript
// 检查是否有仓库
if (repos.length === 0) {
  // 生成基础 README，提示用户添加仓库
  return generateBasicReadme(username);
}

// 筛选非 fork 仓库
const nonForkRepos = repos.filter(repo => !repo.isFork);

// 根据排序方式选择项目
let topProjects;
switch (sortMethod) {
  case 'stars':
    // 按 star 数排序
    topProjects = nonForkRepos
      .sort((a, b) => b.stargazerCount - a.stargazerCount)
      .slice(0, 5);
    break;
  
  case 'updated':
    // 按更新时间排序
    topProjects = nonForkRepos
      .sort((a, b) => new Date(b.updatedAt) - new Date(a.updatedAt))
      .slice(0, 5);
    break;
  
  case 'smart':
  default:
    // 智能排序：综合 star、更新时间、描述质量
    topProjects = nonForkRepos
      .sort((a, b) => {
        // 计算综合分数
        const scoreA = calculateSmartScore(a);
        const scoreB = calculateSmartScore(b);
        return scoreB - scoreA;
      })
      .slice(0, 5);
    break;
}

// 智能排序分数计算
function calculateSmartScore(repo) {
  let score = 0;
  
  // Star 数权重（40%）
  score += (repo.stargazerCount || 0) * 0.4;
  
  // 更新时间权重（30%）
  const daysSinceUpdate = (Date.now() - new Date(repo.updatedAt)) / (1000 * 60 * 60 * 24);
  score += Math.max(0, 30 - daysSinceUpdate) * 0.3; // 30天内更新得满分
  
  // 描述质量权重（30%）
  const description = repo.description || '';
  if (description.length > 20) score += 30 * 0.3; // 描述详细得满分
  else if (description.length > 10) score += 20 * 0.3;
  else if (description.length > 0) score += 10 * 0.3;
  
  return score;
}

// 统计语言分布
const languageStats = repos.reduce((acc, repo) => {
  const lang = repo.primaryLanguage?.name || 'Unknown';
  acc[lang] = (acc[lang] || 0) + 1;
  return acc;
}, {});
```

### Step 3: 智能推荐

根据分析结果推荐：
- **项目展示**：根据排序方式选择 Top 5 项目
- **主题风格**：用户选择或智能匹配
- **技术栈徽章**：从语言分布生成
- **Widget 组合**：统计卡片、连续贡献等

**主题选择逻辑：**
```typescript
// 检查用户是否指定了主题
let selectedTheme = theme || 'radical'; // 默认使用 radical

// 如果没有指定主题，智能匹配
if (!theme) {
  // 检查用户现有 README
  const existingReadme = await getExistingReadme(username);
  
  if (existingReadme) {
    // 分析现有 README 的颜色风格
    const existingTheme = analyzeReadmeTheme(existingReadme);
    selectedTheme = existingTheme || 'radical';
  } else {
    // 新用户使用 radical 主题（流行且美观）
    selectedTheme = 'radical';
  }
}

// 加载主题配置
const themeConfig = themes[selectedTheme];
```

**推荐逻辑：**
- 如果用户指定了主题 → 使用指定主题
- 如果用户有 README → 分析现有风格，智能匹配
- 如果用户无 README → 使用 radical 主题（默认）
- 如果仓库有 AI 相关项目 → 突出展示 AI Agent 部分

### Step 4: 准备模板数据

根据所选模板准备不同的数据结构。所有模板共享以下基础变量：

| 变量 | 说明 | 来源 |
|------|------|------|
| `username` | GitHub 用户名 | `gh api` |
| `name` | 用户显示名 | `gh api`（为空则用 username） |
| `bio` | 个人简介 | `gh api`（为空则用默认文案） |
| `typing_lines` | 打字动画文本 | 从 bio 或项目名生成，用 `;` 分隔多行 |
| `website` | 个人网站 URL | 用户提供或从 GitHub profile 获取 |
| `website_name` | 网站显示名 | 用户提供（默认"个人网站"） |
| `blog` | 博客 URL | 用户提供 |
| `blog_name` | 博客显示名 | 用户提供（默认"技术博客"） |
| `email` | 邮箱 | 用户提供 |
| `linkedin` | LinkedIn 显示名 | 用户提供 |
| `linkedin_url` | LinkedIn 个人页 URL | 用户提供 |

**项目表格变量（所有模板）：**

| 变量 | 说明 |
|------|------|
| `projects` | 项目数组，每项包含 `name`, `description`, `url` |
| `stars` | 项目 star 数（仅 radical/tokyonight/dracula 使用） |
| `tech` | 技术栈标签（仅 professional 使用） |

**技术栈变量（按模板区分）：**

| 模板 | 变量 | 说明 |
|------|------|------|
| radical / tokyonight / dracula / minimalist | `languages` | 语言数组：`{name, color, logo}` |
| | `tools` | 工具数组：`{name, color, logo}` |
| professional | `frontend` | 前端技术数组：`{name, color, logo}` |
| | `backend` | 后端技术数组：`{name, color, logo}` |
| | `tools` | 工具数组：`{name, color, logo}` |

**Professional 模板的前端/后端分类逻辑：**

```typescript
const frontendTechs = ['JavaScript', 'TypeScript', 'Vue', 'React', 'HTML', 'CSS', 'Svelte'];
const backendTechs = ['Python', 'Go', 'Java', 'Rust', 'PHP', 'Ruby', 'C#', 'Node.js'];

const frontend = languages.filter(l => frontendTechs.includes(l.name));
const backend = languages.filter(l => backendTechs.includes(l.name));
const tools = languages.filter(l => !frontendTechs.includes(l.name) && !backendTechs.includes(l.name));
```

**语言/工具颜色配置从 `themes.json` 的 `languages` 和 `tools` 字段获取。**

**Snake 贡献图注意事项：** radical / tokyonight / dracula 模板包含蛇形贡献图（snake animation），该功能依赖用户仓库中已配置 [github-snake](https://github.com/platane/snk) GitHub Actions 工作流。如果用户未配置，该图片会显示 404。在生成 README 后应提示用户：如需蛇形贡献图，需先 fork [platane/snk](https://github.com/platane/snk) 并配置 GitHub Actions。

### Step 5: 生成 README

使用模板生成完整的 README.md：

**模板结构：**
```markdown
<div align="center">

# {用户名}

## {个人介绍}

[打字动画]

</div>

---

## 📊 GitHub 统计

[统计卡片]

---

## 🤖 项目展示

[项目表格]

---

## 💻 技术栈

[技术栈徽章]

---

## 📞 联系方式

[联系按钮]

</div>
```

## Quick Reference

### 基本命令

| 命令 | 说明 | 示例 |
|------|------|------|
| `/github-profile-beautifier` | 交互式生成 | 询问用户名和选项 |
| `/github-profile-beautifier username` | 指定用户名 | 使用默认选项生成 |

### 排序方式

| 参数 | 说明 | 示例 |
|------|------|------|
| `--sort stars` | 按 star 数排序 | 展示最受欢迎的项目 |
| `--sort smart` | 智能排序 | 综合 star、更新时间、描述质量 |
| `--sort updated` | 按更新时间排序 | 展示最近活跃的项目 |

### 主题选择

| 参数 | 说明 | 风格 |
|------|------|------|
| `--theme radical` | Radical 主题 | 活泼、鲜艳（默认） |
| `--theme tokyonight` | Tokyo Night 主题 | 现代、深色 |
| `--theme dracula` | Dracula 主题 | 暗黑、紫色 |
| `--theme minimalist` | Minimalist 主题 | 简洁、专业 |
| `--theme professional` | Professional 主题 | 商务、蓝色 |

### 完整示例

```bash
# 按 star 数排序，使用 Tokyo Night 主题
/github-profile-beautifier wu529778790 --sort stars --theme tokyonight

# 智能排序，使用 Dracula 主题
/github-profile-beautifier wu529778790 --sort smart --theme dracula

# 按更新时间排序，使用 Minimalist 主题
/github-profile-beautifier wu529778790 --sort updated --theme minimalist
```

## Implementation

### 可用模板

| 模板 | 风格 | 适合场景 |
|------|------|----------|
| Radical | 活泼、鲜艳 | 个人项目、创意开发 |
| Tokyo Night | 现代、深色 | 技术展示、深色主题 |
| Dracula | 暗黑、紫色 | 深色主题、护眼 |
| Minimalist | 简洁、专业 | 企业用户、正式场合 |
| Professional | 商务、蓝色 | 求职者、企业展示 |

### 排序方式

| 排序方式 | 说明 | 适合场景 |
|----------|------|----------|
| stars | 按 star 数排序 | 展示最受欢迎的项目 |
| smart | 智能排序 | 综合 star、更新时间、描述质量 |
| updated | 按更新时间排序 | 展示最近活跃的项目 |

### 完整执行流程

```
0. 解析参数
   - 提取 username、--sort、--theme
   - 缺少参数时交互式询问

1. 获取用户信息
   - 检查 gh CLI 是否安装（未安装 → 提示安装）
   - 验证用户是否存在（gh api users/$USERNAME）
   - 获取用户信息：gh api users/$USERNAME --jq '.login,.name,.bio'
   - 获取仓库列表：gh repo list $USERNAME --limit 50 --json ...

2. 分析仓库
   - 筛选非 fork 仓库
   - 根据排序方式筛选 Top 5 项目
   - 统计语言分布

3. 智能推荐
   - 应用选择的主题
   - 从 themes.json 获取语言/工具颜色配置
   - 准备模板所需的数据结构

4. 准备模板数据
   - 基础变量：username, name, bio, typing_lines, 联系方式
   - 项目列表：projects (name, description, url, stars, tech)
   - 技术栈：languages/tools 或 frontend/backend/tools（取决于模板）

5. 生成 README
   - 读取对应主题的模板文件
   - 用 {{#if}} 处理可选字段（website, blog, email, linkedin）
   - 填充所有变量，输出完整 README.md

6. 输出结果
   - 显示在终端
   - 可选：保存到文件
```

### 模板配置

**主题配置文件 (themes.json)** 包含三个部分：

- `themes`：主题定义（颜色、模板文件、badge 样式、打字动画颜色等）
- `languages`：语言徽章配置（颜色、logo、logo 颜色）
- `tools`：工具徽章配置（颜色、logo）

语言和工具的 `color` 字段不含 `#` 前缀（shields.io 两种格式都支持）。

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 使用外部 API 获取统计数据 | 使用 `gh` 命令本地获取 | API 可能不稳定或被暂停 |
| 硬编码主题颜色 | 从配置文件读取 | 方便用户自定义 |
| 忽略用户现有 README | 分析现有风格并匹配 | 保持一致性 |
| 展示所有仓库 | 智能推荐 Top 5 | 避免信息过载 |
| 使用复杂的模板引擎 | 使用简单的字符串替换 | 降低依赖和复杂度 |
| 不检查 gh CLI 是否安装 | 先检查再执行 | 避免运行时错误 |
| 不处理用户不存在的情况 | 先验证用户存在性 | 避免无效操作 |
| 使用不稳定的外部 API | 使用本地 gh 命令 | 保证可靠性 |
| 只按 star 数排序 | 提供多种排序方式 | 满足不同用户需求 |
| 强制使用默认主题 | 让用户选择主题 | 尊重用户偏好 |

## Real-World Impact

**Before (没有 skill):**
- 使用不稳定的外部 API
- 图片裂开（404 错误）
- 信息过载（展示所有仓库）
- 风格不一致
- 不处理错误情况
- 只能按 star 数排序
- 强制使用默认主题

**After (有 skill):**
- 使用本地 `gh` 命令
- 所有图片正常显示
- 智能推荐 Top 5 项目
- 风格统一美观
- 完善的错误处理
- 多种排序方式可选
- 多种主题可选

## Edge Cases

### 1. 用户不存在
```bash
# 检查用户是否存在
if ! gh api users/$USERNAME > /dev/null 2>&1; then
  echo "错误：用户 $USERNAME 不存在"
  exit 1
fi
```

### 2. 没有仓库
```typescript
if (repos.length === 0) {
  // 生成基础 README，提示用户添加仓库
  return generateBasicReadme(username);
}
```

### 3. 所有仓库都是 fork
```typescript
// 筛选非 fork 仓库
const nonForkRepos = repos.filter(repo => !repo.isFork);

if (nonForkRepos.length === 0) {
  // 使用所有仓库，包括 fork
  topProjects = repos.slice(0, 5);
} else {
  // 只使用非 fork 仓库
  topProjects = nonForkRepos.slice(0, 5);
}
```

### 4. gh CLI 未安装
```bash
if ! command -v gh &> /dev/null; then
  echo "错误：请先安装 gh CLI"
  echo "安装命令：brew install gh"
  exit 1
fi
```

### 5. 网络问题
```bash
# 检查网络连接
if ! gh api users/$USERNAME > /dev/null 2>&1; then
  echo "错误：无法连接到 GitHub 或用户不存在"
  echo "请检查网络连接"
  exit 1
fi
```
