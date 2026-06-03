# Dependency Audit Report: {{project_name}}

Generated: {{date}}

## Summary

| Metric | Value |
|--------|-------|
| 直接依赖 | {{direct_deps}} |
| 间接依赖 | {{transitive_deps}} |
| 安全漏洞 | {{vuln_count}} |
| 高危漏洞 | {{high_vuln_count}} |
| 过时依赖 | {{outdated_count}} |
| License 风险 | {{license_risk_count}} |

## Security Vulnerabilities

{{#each vulns}}
### {{severity}}: {{name}}

- **CVE**: {{cve}}
- **描述**: {{description}}
- **影响版本**: {{affected_versions}}
- **修复版本**: {{fixed_version}}
- **修复命令**: `{{fix_command}}`

{{/each}}

{{#if no_vulns}}
No known vulnerabilities found.
{{/if}}

## Outdated Dependencies

| 包名 | 当前版本 | 最新版本 | 升级类型 |
|------|---------|---------|---------|
{{#each outdated}}
| {{name}} | {{current}} | {{latest}} | {{upgrade_type}} |
{{/each}}

## License Compliance

| 许可证 | 数量 | 风险等级 |
|--------|------|---------|
{{#each licenses}}
| {{name}} | {{count}} | {{risk}} |
{{/each}}

{{#if gpl_licenses}}
### ⚠️ GPL/AGPL Dependencies

以下依赖使用 copyleft 许可证，可能影响项目license：

{{#each gpl_licenses}}
- **{{name}}**: {{license}}
{{/each}}
{{/if}}

## Recommended Actions

{{#each actions}}
{{@index}}. {{description}}
   Command: `{{command}}`

{{/each}}
