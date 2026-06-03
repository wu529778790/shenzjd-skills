# Radical Theme Template

<div align="center">

# 🚀 {{name}} 🚀

## 👋 {{bio}}

[![Typing SVG](https://readme-typing-svg.herokuapp.com/?lines={{typing_lines}}&font=Fira+Code&size=20&color=F7587A&vCenter=true&width=500&height=50)](https://git.io/typing-svg)

### 🔥 GitHub 账号状态

![Profile Views](https://komarev.com/ghpvc/?username={{username}}&label=Profile%20views&color=0e75b6&style=for-the-badge)
![GitHub Followers](https://img.shields.io/github/followers/{{username}}?color=blue&style=for-the-badge)
![GitHub Stars](https://img.shields.io/github/stars/{{username}}?color=yellow&style=for-the-badge)

</div>

---

### 📊 GitHub 统计

<p align="center">
  <img src="https://github-readme-stats-eight-mu.vercel.app/api?username={{username}}&theme=radical&hide_border=true&show_icons=true&count_private=true" alt="GitHub Stats" />
</p>

<p align="center">
  <img src="https://github-readme-stats-eight-mu.vercel.app/api/top-langs/?username={{username}}&layout=compact&theme=radical&hide_border=true" alt="Top Languages" />
</p>

<p align="center">
  <img src="https://streak-stats.demolab.com?user={{username}}&theme=radical&hide_border=true&background=0D1117" alt="GitHub Streak" />
</p>

---

### 🐍 贡献图

<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/{{username}}/{{username}}/output/github-snake-dark.svg" />
    <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/{{username}}/{{username}}/output/github-snake.svg" />
    <img alt="github-snake" src="https://raw.githubusercontent.com/{{username}}/{{username}}/output/github-snake-dark.svg" />
  </picture>
</p>

---

## 📊 热门项目

<div align="center">

| 🌐 项目 | ⭐ Stars | 📝 描述 | 🔗 链接 |
|:---:|:---:|:---|:---:|
{{#each projects}}
| **{{name}}** | ⭐ {{stars}} | {{description}} | [🔗 GitHub]({{url}}) |
{{/each}}

</div>

---

## 💻 技术栈

<div align="center">

### 🎨 主要语言

{{#each languages}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=for-the-badge&logo={{logo}}&logoColor=white)
{{/each}}

### ⚙️ 工具 & 框架

{{#each tools}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=for-the-badge&logo={{logo}}&logoColor=white)
{{/each}}

</div>

---

## 📞 联系我

<div align="center">

[![Website](https://img.shields.io/badge/Website-个人网站-0077B5?style=for-the-badge&logo=googlechrome&logoColor=white)]({{website}})
[![Blog](https://img.shields.io/badge/Blog-技术博客-00A98F?style=for-the-badge&logo=blogger&logoColor=white)]({{blog}})
[![Email](https://img.shields.io/badge/Email-发送邮件-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:{{email}})
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/{{username}})

</div>
