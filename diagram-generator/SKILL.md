---
name: diagram-generator
description: Generate dark-themed SVG diagrams from text descriptions — architecture, flowchart, sequence, ER, mind map, state machine, timeline, data flow.
---

# Diagram Generator

从自然语言描述生成专业暗色主题 SVG 架构图、流程图、时序图等。

## Overview

根据用户描述自动生成可渲染的 SVG 图表文件。使用完整设计系统（语义颜色、字体规范、间距规则、组件模式），输出单个自包含 SVG 文件，支持中文。

## When to Use

- User wants to create architecture diagrams, flowcharts, or sequence diagrams
- User mentions diagram, flowchart, architecture, ER diagram, class diagram, org chart
- User wants to visualize system design, data flow, or API call chains
- User says "画个图" / "画架构图" / "draw diagram"
- User inputs `/diagram-generator`
- User wants to draw a mind map or brainstorming diagram
- User wants to visualize a state machine or lifecycle
- User wants to create a project timeline or milestone chart
- User wants to diagram a data pipeline or ETL flow
- User wants to document an event-driven architecture

**When NOT to Use:**
- User only wants to view code structure (use AST analysis)
- User wants UI prototypes/wireframes (use Figma, Sketch, or Adobe XD)
- User wants to edit existing diagrams (provide the original file)
- User wants to create interactive diagrams (consider D3.js or Mermaid)
- User wants to generate diagrams from data (use charting libraries like Chart.js)

## Core Pattern

### Step 1: 确定图表类型

| 用户描述关键词 | 图表类型 | 参考文件 |
|--------------|---------|---------|
| 架构、组件、部署、系统 | Architecture | `references/architecture.md` |
| 流程、步骤、判断、决策 | Flowchart | `references/flowchart.md` |
| 调用、请求、响应、交互 | Sequence | `references/sequence.md` |
| 类、继承、实现、ER、关系 | Structural | `references/structural.md` |
| 思维、头脑风暴、主题 | Mind Map | — |
| 时间线、历史、排期 | Timeline | — |
| 状态、生命周期、转换 | State Machine | — |

### Step 2: 收集信息

```bash
# 如果是项目架构图，先扫描项目结构
ls -la
find . -name "*.ts" -o -name "*.go" -o -name "*.py" | head -20
cat package.json 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d.get('dependencies',{}).keys())[:10])" 2>/dev/null
```

提取：
- 项目类型和技术栈
- 模块/服务划分
- 数据流向
- 外部依赖

### Step 3: 读取参考文件

在开始绘制前，读取对应图表类型的参考文件：

```bash
# 确定 skill 目录路径
SKILL_DIR="<skill-install-path>/diagram-generator"

# 读取对应类型的参考文件
cat $SKILL_DIR/references/architecture.md   # 架构图
cat $SKILL_DIR/references/flowchart.md      # 流程图
cat $SKILL_DIR/references/sequence.md       # 时序图
cat $SKILL_DIR/references/structural.md     # 结构图
```

### Step 4: 规划布局

在绘制前，先列出所有组件并计算位置：

1. **列出所有组件** — 名称、类型、分类
2. **确定分组** — 哪些组件属于同一层级/区域
3. **计算位置** — 按照参考文件的布局算法分配坐标
4. **确定流向** — LTR 或 TTB

### Step 5: 生成 SVG

**⚠️ 关键顺序：先写所有内容，最后算 viewBox。**

执行步骤：
1. 先写 `<svg>` 标签，viewBox 暂时留空：`<svg xmlns="..." viewBox="0 0 0 0">`
2. 按分层顺序写所有内容（背景→边界→箭头→遮罩→组件→文字→图例→标题）
3. **全部写完后**，扫描所有元素的坐标，计算实际 viewBox
4. 回去修改 `<svg>` 标签的 viewBox 值

**SVG 分层顺序（从底到顶）：**
1. 背景填充 + 网格
2. 区域/组边界（虚线）— 边界也是元素，有自己的 x/y/width/height
3. 连接箭头和线
4. 不透明遮罩矩形（与组件框同位置）
5. 组件框（半透明填充 + 描边）
6. 文字标签
7. 图例 — 在所有内容下方
8. 标题块

**设计系统：**

| 类别 | 填充 (rgba) | 描边 | 用途 |
|------|-------------|------|------|
| Primary | `rgba(8, 51, 68, 0.4)` | `#22d3ee` (cyan) | 前端、用户界面、输入 |
| Secondary | `rgba(6, 78, 59, 0.4)` | `#34d399` (emerald) | 后端、服务、处理 |
| Tertiary | `rgba(76, 29, 149, 0.4)` | `#a78bfa` (violet) | 数据库、存储、持久化 |
| Accent | `rgba(120, 53, 15, 0.3)` | `#fbbf24` (amber) | 云、基础设施、区域 |
| Alert | `rgba(136, 19, 55, 0.4)` | `#fb7185` (rose) | 安全、错误、警告 |
| Connector | `rgba(251, 146, 60, 0.3)` | `#fb923c` (orange) | 总线、队列、中间件 |
| Neutral | `rgba(30, 41, 59, 0.5)` | `#94a3b8` (slate) | 外部、通用、未知 |
| Highlight | `rgba(59, 130, 246, 0.3)` | `#60a5fa` (blue) | 活动状态、焦点 |

**字体规范：**
- 标题：16px, weight 700
- 组件名：11-12px, weight 600
- 描述/子标签：9px, weight 400, color `#94a3b8`
- 注释：8px, weight 400
- 箭头标签：7-8px

**中文支持：** 当标签包含中文时，使用 `font-family: 'JetBrains Mono', 'Noto Sans SC', 'PingFang SC', sans-serif'` 并增加组件框宽度。

**间距规则：**
- 组件框高度：50-70px（标准），80-120px（大/复杂）
- 组件间最小间距：40px 垂直，30px 水平
- 箭头标签距组件边：10px
- 区域边界内边距：20px（边界内所有组件必须完全包含在内）
- **区域内组件居中：** 同一区域内的组件组必须水平居中。计算：`start_x = region_x + (region_w - total_content_w) / 2`
- **区域标签位置：** 必须放在边界顶部上方（y=边界y-4），避免被组件框的不透明遮罩覆盖
- 图例位置：最低元素下方至少 20px
- 标题块：距左上角 20px
- viewBox：所有内容 + 四周 30px padding

**溢出预防（必须遵守）：**

1. **先计算所有组件位置，再画区域边界** — 列出每个组件的 y+height，区域边界高度 = 最低组件 y+height + 20px 内边距
2. **viewBox 最后确定** — 写完所有 SVG 元素后，扫描全部元素（包括区域边界）的坐标，viewBox = 所有内容 + 四周 30px padding。计算完后回去修改 `<svg>` 标签
3. **区域边界也是元素** — 它们有自己的 x/width/y/height，必须纳入 viewBox 计算
4. **检查清单** — 画完后逐项验证：
   - [ ] 每个区域边界完全包含其所有子组件
   - [ ] 没有元素（包括边界框）超出 viewBox
   - [ ] 区域标签在组件框遮罩层之上（标签 y < 区域边界 y）

**布局计算方法：**

```
1. 列出所有组件的坐标（x, y, width, height）
2. 画区域边界（边界本身也是元素，有自己的坐标）
3. 画图例和标题
4. 扫描全部元素，找到最大 x+width 和最大 y+height
5. viewBox = "0 0 (max_x+60) (max_y+60)"（四周各 30px padding）
```

**基础 SVG 模板：**

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 WIDTH HEIGHT">
  <style>
    @import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600;700&amp;display=swap');
    text { font-family: 'JetBrains Mono', 'Noto Sans SC', 'PingFang SC', monospace; }
  </style>
  <defs>
    <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
      <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#1e293b" stroke-width="0.5"/>
    </pattern>
    <marker id="arrow" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="#64748b"/>
    </marker>
  </defs>
  <!-- Layer 1: Background -->
  <rect width="100%" height="100%" fill="#0f172a"/>
  <rect width="100%" height="100%" fill="url(#grid)"/>
  <!-- Layer 2-7: Diagram content -->
  ...
  <!-- Layer 8: Title -->
  <text x="30" y="35" fill="white" font-size="16" font-weight="700">Diagram Title</text>
</svg>
```

**标准组件框：**

```svg
<!-- Mask layer -->
<rect x="X" y="Y" width="160" height="60" rx="6" fill="#0f172a"/>
<!-- Visual layer -->
<rect x="X" y="Y" width="160" height="60" rx="6" fill="FILL_COLOR" stroke="STROKE_COLOR" stroke-width="1.5"/>
<!-- Name -->
<text x="CX" y="Y+24" fill="white" font-size="11" font-weight="600" text-anchor="middle">Component Name</text>
<!-- Description -->
<text x="CX" y="Y+40" fill="#94a3b8" font-size="9" text-anchor="middle">description</text>
```

**数据库圆柱：**

```svg
<g transform="translate(X, Y)">
  <rect x="0" y="10" width="120" height="50" rx="2" fill="#0f172a"/>
  <ellipse cx="60" cy="10" rx="60" ry="12" fill="#0f172a"/>
  <ellipse cx="60" cy="60" rx="60" ry="12" fill="#0f172a"/>
  <rect x="0" y="10" width="120" height="50" fill="rgba(76,29,149,0.4)"/>
  <ellipse cx="60" cy="10" rx="60" ry="12" fill="rgba(76,29,149,0.4)" stroke="#a78bfa" stroke-width="1.5"/>
  <ellipse cx="60" cy="60" rx="60" ry="12" fill="rgba(76,29,149,0.4)" stroke="#a78bfa" stroke-width="1.5"/>
  <line x1="0" y1="10" x2="0" y2="60" stroke="#a78bfa" stroke-width="1.5"/>
  <line x1="120" y1="10" x2="120" y2="60" stroke="#a78bfa" stroke-width="1.5"/>
  <text x="60" y="40" fill="white" font-size="11" font-weight="600" text-anchor="middle">PostgreSQL</text>
</g>
```

**区域边界：**

```svg
<rect x="X" y="Y" width="W" height="H" rx="12" fill="none" stroke="#fbbf24" stroke-width="1" stroke-dasharray="8,4"/>
<text x="X+12" y="Y+16" fill="#fbbf24" font-size="9" font-weight="600">Region Name</text>
```

**XML 转义规则（重要）：**

SVG 是 XML 格式，以下字符必须转义：

| 字符 | 转义 | 使用场景 |
|------|------|---------|
| `&` | `&amp;` | 标签文字中的 "A & B" |
| `<` | `&lt;` | 比较符号 |
| `>` | `&gt;` | 比较符号 |
| `"` | `&quot;` | 属性值中的双引号 |

**`<style>` 标签必须用 CDATA 包裹：**

```svg
<style><![CDATA[
  @import url('https://fonts.googleapis.com/css2?family=...');
  text { font-family: 'JetBrains Mono', monospace; }
]]></style>
```

### Step 6: QA 质量检查

生成完成后，读取 `references/qa-checklist.md` 逐项检查：

```bash
# 读取 QA 检查清单
cat $SKILL_DIR/references/qa-checklist.md
```

**必须通过的检查项：**
- 视觉一致性（颜色、大小、间距统一）
- 布局合理性（无重叠、流向清晰）
- SVG 规范（viewBox、转义、图层顺序）
- 边界处理（区域包含子组件）

### Step 7: 保存文件

- 保存为 `.svg` 文件
- 如果输入是文件，保存到 `{inputFileDir}/diagram/`
- 否则保存到 `{projectDir}/diagram/{topic-slug}/`
- 创建目录（如不存在）

## Quick Reference

```bash
/diagram-generator                         # 交互式询问图表类型
/diagram-generator 架构图                   # 生成架构图
/diagram-generator 流程图                   # 生成流程图
/diagram-generator 时序图                   # 生成时序图
```

| 提示 | 说明 | 默认值 |
|------|------|--------|
| `类型` | 图表类型（architecture/flowchart/sequence/structural/mindmap/timeline/state） | 自动检测 |
| `方向` | 布局方向（ltr/ttb） | 自动选择 |

## Common Mistakes

| 错误 | 正确做法 | 原因 |
|------|----------|------|
| 跳过参考文件直接画 | 先读取对应类型的参考文件 | 布局算法和组件模式在参考文件中 |
| 不用遮罩层 | 每个组件框前加不透明遮罩 | 半透明组件会透出底下的箭头 |
| 不分层 | 严格按 8 层顺序绘制 | SVG 按绘制顺序渲染，顺序错误会导致遮挡 |
| 不加区域边界 | 用虚线框分组相关组件 | 读者无法理解组件的组织关系 |
| 中文不加宽 | CJK 字符比拉丁字符宽 | 组件框宽度需要增加以容纳中文 |
| viewBox 太小 | 预留 30px padding | 内容可能超出预期边界 |
| 组件间距不一致 | 统一使用参考文件的间距规则 | 间距混乱影响专业感 |
| 箭头标签位置随意 | 标签放在箭头中间偏上 | 遮挡箭头或脱离箭头导致混淆 |
| 区域内组件未居中 | 计算 start_x = region_x + (region_w - total_w) / 2 | 未居中看起来不对称 |
| 忘记 XML 转义 | `&` 必须转义为 `&amp;` 等 | SVG 是 XML，未转义会导致渲染失败 |
| viewBox 不包含区域边界 | 区域边界也是元素，必须纳入计算 | 边界超出 viewBox 被裁切 |
