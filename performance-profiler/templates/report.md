# Performance Report: {{project_name}}

Generated: {{date}}

## Overview

| Metric | Value |
|--------|-------|
| 项目类型 | {{project_type}} |
| 直接依赖数 | {{dep_count}} |
| 总依赖数（含间接） | {{total_dep_count}} |
| 过时依赖 | {{outdated_count}} |
| 健康度评分 | {{health_score}}/100 |

## High Priority

{{#each high_priority}}
### {{title}}

- **影响**: {{impact}}
- **问题**: {{description}}
- **修复**: `{{fix_command}}`

{{/each}}

## Medium Priority

{{#each medium_priority}}
### {{title}}

- **影响**: {{impact}}
- **问题**: {{description}}
- **修复**: `{{fix_command}}`

{{/each}}

## Low Priority

{{#each low_priority}}
### {{title}}

- **问题**: {{description}}
- **建议**: {{suggestion}}

{{/each}}

## Dependency Breakdown

| 包名 | 版本 | 大小 | 类型 |
|------|------|------|------|
{{#each deps}}
| {{name}} | {{version}} | {{size}} | {{type}} |
{{/each}}
