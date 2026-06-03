# GitHub Profile Beautifier Templates

## 📋 可用模板

### 1. Radical Theme 🎨
**描述：** vibrant and colorful theme
**适合：** 个人项目、创意开发者、喜欢鲜艳颜色的用户
**特点：**
- 粉色和黄色为主色调
- 活泼、有活力
- 适合展示个人品牌

**示例颜色：**
- Primary: `#fe428e` (粉色)
- Secondary: `#f8d847` (黄色)
- Accent: `#a9fef7` (青色)

---

### 2. Tokyo Night Theme 🌙
**描述：** Modern dark theme with blue tones
**适合：** 喜欢现代感、深色主题的用户
**特点：**
- 蓝色和紫色为主色调
- 现代、科技感强
- 适合展示技术能力

**示例颜色：**
- Primary: `#7aa2f7` (蓝色)
- Secondary: `#bb9af7` (紫色)
- Accent: `#9ece6a` (绿色)

---

### 3. Dracula Theme 🧛
**描述：** Popular dark theme with purple accents
**适合：** 喜欢深色主题、紫色调的用户
**特点：**
- 紫色和粉色为主色调
- 深色背景，护眼
- 适合展示暗黑风格

**示例颜色：**
- Primary: `#ff79c6` (粉色)
- Secondary: `#bd93f9` (紫色)
- Accent: `#50fa7b` (绿色)

---

### 4. Minimalist Theme ✨
**描述：** Clean and simple design
**适合：** 喜欢简洁、专业风格的用户
**特点：**
- 黑白灰为主色调
- 简洁、专业
- 适合展示正式项目

**示例颜色：**
- Primary: `#333333` (深灰)
- Secondary: `#666666` (灰色)
- Accent: `#0077B5` (蓝色)

---

### 5. Professional Theme 💼
**描述：** Business-oriented design
**适合：** 企业用户、求职者、需要展示专业形象的用户
**特点：**
- 蓝色和橙色为主色调
- 专业、商务
- 适合展示工作经验

**示例颜色：**
- Primary: `#2E86AB` (蓝色)
- Secondary: `#A23B72` (紫色)
- Accent: `#F18F01` (橙色)

---

## 🚀 使用方法

### 选择模板

```bash
# 使用 Radical 主题（默认）
/github-profile-beautifier username --theme radical

# 使用 Tokyo Night 主题
/github-profile-beautifier username --theme tokyonight

# 使用 Dracula 主题
/github-profile-beautifier username --theme dracula

# 使用 Minimalist 主题
/github-profile-beautifier username --theme minimalist

# 使用 Professional 主题
/github-profile-beautifier username --theme professional
```

---

## 📊 模板对比

| 模板 | 风格 | 颜色 | 适合场景 |
|------|------|------|----------|
| Radical | 活泼 | 粉色/黄色 | 个人项目、创意开发 |
| Tokyo Night | 现代 | 蓝色/紫色 | 技术展示、深色主题 |
| Dracula | 暗黑 | 紫色/粉色 | 深色主题、护眼 |
| Minimalist | 简洁 | 黑白灰 | 专业、正式 |
| Professional | 商务 | 蓝色/橙色 | 企业、求职 |

---

## 🎨 颜色自定义

### 修改主题颜色

在 `themes.json` 中修改：

```json
{
  "themes": {
    "radical": {
      "colors": {
        "primary": "#your-color",
        "secondary": "#your-color",
        "accent": "#your-color"
      }
    }
  }
}
```

### 添加新主题

1. 在 `templates/` 目录创建新的模板文件
2. 在 `themes.json` 中添加主题配置
3. 使用新模板生成 README

---

## 📝 模板变量

### 基础变量（所有模板通用）

| 变量 | 说明 | 示例 |
|------|------|------|
| `{{name}}` | 用户显示名 | wu529778790 |
| `{{bio}}` | 个人简介 | 神族九帝，永不言弃 |
| `{{username}}` | GitHub 用户名 | wu529778790 |
| `{{typing_lines}}` | 打字动画文本（`;` 分隔多行） | Welcome;AI Agent |
| `{{website}}` | 个人网站 URL | https://example.com |
| `{{website_name}}` | 网站显示名（默认"个人网站"） | 我的网站 |
| `{{blog}}` | 博客 URL | https://blog.example.com |
| `{{blog_name}}` | 博客显示名（默认"技术博客"） | 技术笔记 |
| `{{email}}` | 邮箱地址 | user@example.com |
| `{{linkedin}}` | LinkedIn 显示名 | john-doe |
| `{{linkedin_url}}` | LinkedIn 个人页 URL | https://linkedin.com/in/john-doe |

> 联系方式字段均为可选，模板使用 `{{#if}}` 处理空值，不会显示空白链接。

### 项目变量

```json
{
  "name": "项目名",
  "stars": 1302,
  "description": "项目描述",
  "url": "https://github.com/...",
  "tech": "Vue, TypeScript"
}
```

- `stars`：仅 radical / tokyonight / dracula 模板显示
- `tech`：仅 professional 模板显示

### 语言/工具变量

```json
{
  "name": "JavaScript",
  "color": "F7DF1E",
  "logo": "javascript"
}
```

### 技术栈分类（仅 Professional 模板）

Professional 模板将技术栈分为三组：

| 变量 | 说明 |
|------|------|
| `{{#each frontend}}` | 前端技术（JavaScript, TypeScript, Vue, React 等） |
| `{{#each backend}}` | 后端技术（Python, Go, Java 等） |
| `{{#each tools}}` | 开发工具（Docker, Git 等） |

其他模板使用 `{{#each languages}}` 和 `{{#each tools}}` 两组。

---

## 💡 最佳实践

### 1. 选择合适的主题
- **个人项目** → Radical 或 Tokyo Night
- **技术展示** → Tokyo Night 或 Dracula
- **企业用户** → Professional 或 Minimalist
- **求职者** → Professional

### 2. 保持一致性
- 选择一个主题后，保持整个 README 风格一致
- 不要混合使用多个主题

### 3. 定期更新
- 定期重新运行 skill 更新 README
- 保持项目信息最新

---

## 🔧 高级自定义

### 创建自定义模板

1. 复制现有模板
2. 修改颜色和样式
3. 在 `themes.json` 的 `themes` 中添加新主题配置
4. 确保模板中的颜色值与 `themes.json` 中的配置一致

---

## 📚 参考资源

- [Shields.io 文档](https://shields.io/)
- [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats)
- [Readme Typing SVG](https://github.com/DenverCoder1/readme-typing-svg)
