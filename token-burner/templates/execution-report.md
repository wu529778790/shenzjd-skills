# Token Burner 执行报告

## 运行概览

| 指标 | 值 |
|------|-----|
| 项目 | {{project_name}} |
| 运行时间 | {{start_time}} ~ {{end_time}} |
| 总耗时 | {{duration}} |
| 扫描任务数 | {{total_tasks}} |
| 执行任务数 | {{executed_tasks}} |
| 成功 | {{success_count}} |
| 失败 | {{failed_count}} |
| 跳过 | {{skipped_count}} |
| 成功率 | {{success_rate}}% |

## 任务详情

| # | 类型 | 优先级 | 文件 | 状态 | 说明 | 耗时 |
|---|------|--------|------|------|------|------|
{{#each tasks}}
| {{@number}} | {{type_icon}} {{type}} | {{priority}} | `{{file}}` | {{status_icon}} {{status}} | {{description}} | {{duration}} |
{{/each}}

## 失败任务分析

{{#if failed_tasks}}
{{#each failed_tasks}}
### {{type}}: {{file}}

- **错误信息：** {{error}}
- **重试次数：** {{retries}}
- **失败原因：** {{reason}}
- **建议：** {{suggestion}}

{{/each}}
{{else}}
无失败任务。
{{/if}}

## 未执行任务

{{#if skipped_tasks}}
| # | 类型 | 文件 | 跳过原因 |
|---|------|------|---------|
{{#each skipped_tasks}}
| {{@number}} | {{type}} | `{{file}}` | {{reason}} |
{{/each}}
{{else}}
所有任务均已执行。
{{/if}}

## 改动统计

| 类型 | 文件数 | 新增行 | 删除行 |
|------|--------|--------|--------|
| 测试 | {{test_files}} | +{{test_add}} | -{{test_del}} |
| 文档 | {{doc_files}} | +{{doc_add}} | -{{doc_del}} |
| 重构 | {{refactor_files}} | +{{refactor_add}} | -{{refactor_del}} |
| 修复 | {{fix_files}} | +{{fix_add}} | -{{fix_del}} |
| **合计** | **{{total_files}}** | **+{{total_add}}** | **-{{total_del}}** |

## 下次运行建议

{{#each suggestions}}
- {{this}}
{{/each}}
