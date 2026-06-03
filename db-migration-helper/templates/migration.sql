-- Migration: {{migration_name}}
-- Created: {{date}}
-- Risk Level: {{risk_level}}
-- Description: {{description}}

-- ============================================
-- UP: 正向迁移
-- ============================================
{{#each up_statements}}
{{this}};
{{/each}}

-- ============================================
-- DOWN: 回滚迁移
-- ============================================
{{#each down_statements}}
{{this}};
{{/each}}
