# Diagram Generator

Generate architecture diagrams, flowcharts, and sequence diagrams from natural language descriptions. Supports Mermaid and Excalidraw formats.

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
/diagram-generator                         # Interactive
/diagram-generator --type flowchart        # Specify type
/diagram-generator --format excalidraw     # Excalidraw format
/diagram-generator --render                # Auto-render PNG
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| `--type` | flowchart / sequence / er / state / class / gantt | Auto-detect |
| `--format` | mermaid / excalidraw | mermaid |
| `--output` | Output directory | `./` |
| `--render` | Render to PNG | false |

## Supported Diagram Types

| Type | Use Case | Keywords |
|------|----------|----------|
| flowchart | Flowchart | process, steps, decision, condition |
| sequence | Sequence diagram | call, request, response, interaction |
| er | ER diagram | table, relationship, foreign key, database |
| state | State diagram | state, lifecycle, transition |
| class | Class diagram | class, inheritance, interface, implementation |
| gantt | Gantt chart | schedule, plan, milestone |

## Output Formats

| Format | Extension | Rendering |
|--------|-----------|-----------|
| Mermaid | `.mmd` | GitHub / Notion / Typora / VS Code |
| Excalidraw | `.excalidraw` | excalidraw.com |
