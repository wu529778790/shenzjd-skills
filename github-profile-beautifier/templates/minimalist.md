# Minimalist Theme Template

<div align="center">

# {{name}}

## {{bio}}

</div>

---

### 📊 GitHub 统计

<p align="center">
  <img src="https://github-readme-stats-eight-mu.vercel.app/api?username={{username}}&hide_border=true&show_icons=true&count_private=true&bg_color=ffffff00" alt="GitHub Stats" />
</p>

<p align="center">
  <img src="https://github-readme-stats-eight-mu.vercel.app/api/top-langs/?username={{username}}&layout=compact&hide_border=true&bg_color=ffffff00" alt="Top Languages" />
</p>

---

## 📊 项目

<div align="center">

| 项目 | 描述 | 链接 |
|:---:|:---|:---:|
{{#each projects}}
| **{{name}}** | {{description}} | [GitHub]({{url}}) |
{{/each}}

</div>

---

## 💻 技术栈

<div align="center">

{{#each languages}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=flat-square&logo={{logo}}&logoColor=white)
{{/each}}

{{#each tools}}
![{{name}}](https://img.shields.io/badge/{{name}}-{{color}}?style=flat-square&logo={{logo}}&logoColor=white)
{{/each}}

</div>

---

## 📞 联系

<div align="center">

{{#if website}}
[![Website](https://img.shields.io/badge/Website-{{website_name|default:"个人网站"}}-0077B5?style=flat-square&logo=googlechrome&logoColor=white)]({{website}})
{{/if}}
{{#if blog}}
[![Blog](https://img.shields.io/badge/Blog-{{blog_name|default:"技术博客"}}-00A98F?style=flat-square&logo=blogger&logoColor=white)]({{blog}})
{{/if}}
{{#if email}}
[![Email](https://img.shields.io/badge/Email-发送邮件-D14836?style=flat-square&logo=gmail&logoColor=white)](mailto:{{email}})
{{/if}}
{{#if linkedin}}
[![LinkedIn](https://img.shields.io/badge/LinkedIn-{{linkedin}}-0077B5?style=flat-square&logo=linkedin&logoColor=white)]({{linkedin_url}})
{{/if}}
[![GitHub](https://img.shields.io/badge/GitHub-{{username}}-181717?style=flat-square&logo=github&logoColor=white)](https://github.com/{{username}})

</div>
