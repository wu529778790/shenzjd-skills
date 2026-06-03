# Professional Theme Template

<div align="center">

# {{name}}

## {{bio}}

[![Typing SVG](https://readme-typing-svg.herokuapp.com/?lines={{typing_lines}}&font=Fira+Code&size=18&color=2E86AB&vCenter=true&width=400&height=40)](https://git.io/typing-svg)

</div>

---

### 📊 GitHub 统计

<p align="center">
  <img src="https://github-readme-stats-eight-mu.vercel.app/api?username={{username}}&theme=transparent&hide_border=true&show_icons=true&count_private=true&bg_color=ffffff00&title_color=2E86AB&icon_color=2E86AB&text_color=333333" alt="GitHub Stats" />
</p>

<p align="center">
  <img src="https://github-readme-stats-eight-mu.vercel.app/api/top-langs/?username={{username}}&layout=compact&theme=transparent&hide_border=true&bg_color=ffffff00&title_color=2E86AB&text_color=333333" alt="Top Languages" />
</p>

---

## 📊 项目

<div align="center">

| 项目 | 描述 | 技术栈 | 链接 |
|:---:|:---|:---:|:---:|
{{#each projects}}
| **{{name}}** | {{description}} | {{tech}} | [GitHub]({{url}}) |
{{/each}}

</div>

---

## 💻 技术栈

<div align="center">

### 前端

{{#each frontend}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=for-the-badge&logo={{logo}}&logoColor=white)
{{/each}}

### 后端

{{#each backend}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=for-the-badge&logo={{logo}}&logoColor=white)
{{/each}}

### 工具

{{#each tools}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=for-the-badge&logo={{logo}}&logoColor=white)
{{/each}}

</div>

---

## 📞 联系方式

<div align="center">

[![Website](https://img.shields.io/badge/Website-{{website_name}}-2E86AB?style=for-the-badge&logo=googlechrome&logoColor=white)]({{website}})
[![LinkedIn](https://img.shields.io/badge/LinkedIn-{{linkedin}}-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)]({{linkedin_url}})
[![Email](https://img.shields.io/badge/Email-{{email}}-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:{{email}})
[![GitHub](https://img.shields.io/badge/GitHub-{{username}}-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/{{username}})

</div>
