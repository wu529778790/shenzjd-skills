## {{VERSION}} ({{DATE}})

{{SUMMARY}}

{{#if features}}
### 🚀 Features
{{#each features}}
- {{message}}
{{/each}}
{{/if}}

{{#if fixes}}
### 🐛 Bug Fixes
{{#each fixes}}
- {{message}}
{{/each}}
{{/if}}

{{#if docs}}
### 📝 Documentation
{{#each docs}}
- {{message}}
{{/each}}
{{/if}}

{{#if refactor}}
### ♻️ Refactor
{{#each refactor}}
- {{message}}
{{/each}}
{{/if}}

{{#if perf}}
### ⚡ Performance
{{#each perf}}
- {{message}}
{{/each}}
{{/if}}

{{#if tests}}
### 🧪 Tests
{{#each tests}}
- {{message}}
{{/each}}
{{/if}}

{{#if security}}
### 🔒 Security
{{#each security}}
- {{message}}
{{/each}}
{{/if}}

{{#if breaking}}
### 💥 Breaking Changes
{{#each breaking}}
- {{message}}
{{/each}}
{{/if}}

{{#if chores}}
### 🔧 Chores
{{#each chores}}
- {{message}}
{{/each}}
{{/if}}

{{#if others}}
### 📦 Other
{{#each others}}
- {{message}}
{{/each}}
{{/if}}

{{#if contributors}}
### 👥 Contributors
{{#each contributors}}
- @{{username}} {{contribution}}
{{/each}}
{{/if}}

**Full Changelog**: {{COMPARE_URL}}
