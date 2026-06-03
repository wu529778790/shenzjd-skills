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

### 自定义颜色

```bash
# 自定义主题颜色
/github-profile-beautifier username --primary-color "#FF6B6B" --secondary-color "#4ECDC4"
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

所有模板都使用相同的变量：

| 变量 | 说明 | 示例 |
|------|------|------|
| `{{name}}` | 用户名 | wu529778790 |
| `{{bio}}` | 个人简介 | 神族九帝，永不言弃 |
| `{{username}}` | GitHub 用户名 | wu529778790 |
| `{{typing_lines}}` | 打字动画文本 | Welcome;AI Agent |
| `{{projects}}` | 项目列表 | 见下方 |
| `{{languages}}` | 语言列表 | 见下方 |
| `{{tools}}` | 工具列表 | 见下方 |

### 项目变量

```json
{
  "name": "项目名",
  "stars": 1302,
  "description": "项目描述",
  "url": "https://github.com/..."
}
```

### 语言变量

```json
{
  "name": "JavaScript",
  "color": "F7DF1E",
  "logo": "javascript"
}
```

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
3. 添加到 `themes.json`

### 使用 CSS 样式

```html
<div align="center" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 10px;">
  <h1 style="color: white;">Your Name</h1>
</div>
```

---

## 📚 参考资源

- [Shields.io 文档](https://shields.io/)
- [GitHub Readme Stats](https://github.com/anuraghazra/github-readme-stats)
- [Readme Typing SVG](https://github.com/DenverCoder1/readme-typing-svg)
