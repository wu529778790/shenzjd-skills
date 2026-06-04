# 📊 Diagram Generator

Generate professional dark-themed SVG diagrams from natural language descriptions. Supports architecture, flowchart, sequence, structural, mind map, timeline, and state machine diagrams.

## Installation

```bash
# npx skills (recommended)
npx skills add wu529778790/shenzjd-skills -s diagram-generator -y

# Manual (Claude Code)
git clone https://github.com/wu529778790/shenzjd-skills.git
cp -r shenzjd-skills/diagram-generator ~/.claude/skills/

# Manual (Cursor)
# Copy SKILL.md content to .cursorrules or .cursor/rules/
```

## Usage

```bash
/diagram-generator                         # Interactive — asks for diagram type
/diagram-generator 架构图                   # Architecture diagram
/diagram-generator 流程图                   # Flowchart
/diagram-generator 时序图                   # Sequence diagram
/diagram-generator 类图                     # Class diagram
```

| Hint | Description | Default |
|------|-------------|---------|
| `类型` | Diagram type (architecture/flowchart/sequence/structural/mindmap/timeline/state) | Auto-detect |
| `方向` | Layout direction (ltr/ttb) | Auto-select |

## Supported Diagram Types

| Type | Use Case | Output |
|------|----------|--------|
| 🏗️ Architecture | System components & relationships | SVG |
| 🔄 Flowchart | Decision logic, process steps | SVG |
| 📨 Sequence | Time-ordered interactions | SVG |
| 📐 Structural | Class/ER/org chart diagrams | SVG |
| 🧠 Mind Map | Brainstorming, topic exploration | SVG |
| ⏱️ Timeline | Chronological events | SVG |
| ⚙️ State Machine | State transitions, lifecycle | SVG |

## Design System

- **Theme:** Dark (slate-900 background with grid)
- **Colors:** 8 semantic colors (cyan, emerald, violet, amber, rose, orange, slate, blue)
- **Font:** JetBrains Mono + Noto Sans SC (CJK support)
- **Output:** Single self-contained SVG file

## Prerequisites

- None — SVG output is self-contained
