# Skills 测试

本目录包含用于验证 skills 质量的测试脚本和测试用例。

## 测试类型

### 1. 结构验证 (`validate-skills.sh`)

验证所有 SKILL.md 文件的格式和结构：

- YAML frontmatter 完整性（name, description）
- 必需章节存在（Overview, When to Use, Core Pattern, Quick Reference, Common Mistakes）
- 命令语法检查
- 模板文件引用检查

**运行方式：**

```bash
./tests/validate-skills.sh
```

### 2. 集成测试 (GitHub Actions)

在 CI/CD 中自动运行：

- **validate-structure**: 结构验证
- **test-dependency-audit**: 依赖审计测试
- **test-git-hooks-setup**: Git Hooks 配置测试
- **test-docker-build-deploy**: Docker 构建部署测试

### 3. 测试用例 (`fixtures/`)

模拟真实项目结构：

- `nodejs-express/`: Node.js Express 项目
- `go-api/`: Go API 项目
- `python-fastapi/`: Python FastAPI 项目

## 运行测试

### 本地运行

```bash
# 运行结构验证
./tests/validate-skills.sh

# 运行特定测试
cd tests/fixtures/nodejs-express
npm audit
```

### CI/CD 运行

每次推送到 main 分支或创建 PR 时自动运行：

```bash
git push origin main
# GitHub Actions 会自动运行测试
```

## 添加新测试

### 1. 添加新的测试用例

在 `fixtures/` 目录下创建新的项目结构：

```bash
mkdir -p tests/fixtures/new-project
cd tests/fixtures/new-project
# 创建项目文件
```

### 2. 添加新的测试 job

在 `.github/workflows/skills-test.yml` 中添加新的 job：

```yaml
test-new-skill:
  name: Test New Skill
  runs-on: ubuntu-latest
  needs: validate-structure
  steps:
    - uses: actions/checkout@v4
    - name: Test new skill
      run: |
        echo "Testing new skill..."
        # 测试逻辑
```

## 测试覆盖

| Skill | 结构验证 | 集成测试 | 测试用例 |
|-------|----------|----------|----------|
| db-migration-helper | ✅ | ✅ | ✅ |
| dependency-audit | ✅ | ✅ | ✅ |
| docker-build-deploy | ✅ | ✅ | ✅ |
| git-hooks-setup | ✅ | ✅ | ✅ |
| github-figure-bed | ✅ | ✅ | ✅ |

**图例：** ✅ 已实现 | ⏳ 待实现

## 故障排除

### 常见问题

1. **验证脚本无法运行**
   ```bash
   chmod +x tests/validate-skills.sh
   ```

2. **GitHub Actions 测试失败**
   - 检查 workflow 文件语法
   - 确认测试用例文件存在
   - 查看 Actions 日志

3. **添加新 skill 后测试失败**
   - 确保 SKILL.md 格式正确
   - 检查 frontmatter 完整性
   - 验证模板文件引用

## 贡献指南

1. 添加新 skill 时，同步更新测试用例
2. 确保所有测试通过后再提交 PR
3. 为新功能添加相应的集成测试
