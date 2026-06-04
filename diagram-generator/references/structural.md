# Structural Diagram Layout

## Types

| Type | Use Case | Key Features |
|------|----------|--------------|
| Class Diagram | OOP class relationships | Compartmented boxes (name/attrs/methods) |
| ER Diagram | Database schema | Entity boxes, relationship lines with cardinality |
| Org Chart | Team hierarchy | Tree layout, top-down reporting lines |

## Class Diagram

### Compartmented Box

```svg
<g transform="translate(X, Y)">
  <!-- Mask -->
  <rect width="180" height="120" rx="6" fill="#0f172a"/>
  <!-- Box -->
  <rect width="180" height="120" rx="6" fill="rgba(8,51,68,0.4)" stroke="#22d3ee" stroke-width="1.5"/>
  <!-- Divider: name | attrs -->
  <line x1="0" y1="30" x2="180" y2="30" stroke="#22d3ee" stroke-width="0.5" stroke-opacity="0.5"/>
  <!-- Divider: attrs | methods -->
  <line x1="0" y1="75" x2="180" y2="75" stroke="#22d3ee" stroke-width="0.5" stroke-opacity="0.5"/>
  <!-- Name -->
  <text x="90" y="20" fill="white" font-size="12" font-weight="700" text-anchor="middle">ClassName</text>
  <!-- Attributes -->
  <text x="10" y="48" fill="#94a3b8" font-size="9">- field: Type</text>
  <text x="10" y="62" fill="#94a3b8" font-size="9">+ method(): void</text>
  <!-- Methods -->
  <text x="10" y="90" fill="#94a3b8" font-size="9">+ getField(): Type</text>
  <text x="10" y="104" fill="#94a3b8" font-size="9">+ setField(v: Type)</text>
</g>
```

### Relationship Lines

| Relationship | Line Style | Marker |
|-------------|-----------|--------|
| Inheritance | Solid, hollow triangle | `stroke-width="1.5"` |
| Implementation | Dashed, hollow triangle | `stroke-dasharray="6,3"` |
| Composition | Solid, filled diamond | Diamond at parent |
| Aggregation | Solid, hollow diamond | Diamond at parent |
| Association | Solid, no marker | Arrow at target |
| Dependency | Dashed, open arrow | Arrow at target |

```svg
<!-- Inheritance (solid line + hollow triangle) -->
<line x1="FROM_CX" y1="FROM_Y" x2="TO_CX" y2="TO_Y" stroke="#94a3b8" stroke-width="1.5"/>
<polygon points="TO_CX,TO_Y TO_CX-6,TO_Y-10 TO_CX+6,TO_Y-10" fill="#0f172a" stroke="#94a3b8" stroke-width="1.5"/>

<!-- Composition (solid line + filled diamond) -->
<line x1="FROM_CX" y1="FROM_Y" x2="TO_CX" y2="TO_Y" stroke="#94a3b8" stroke-width="1.5"/>
<polygon points="FROM_CX,FROM_Y FROM_CX+8,FROM_Y-5 FROM_CX+16,FROM_Y FROM_CX+8,FROM_Y+5" fill="#22d3ee" stroke="#22d3ee"/>
```

## ER Diagram

### Entity Box

```svg
<g transform="translate(X, Y)">
  <rect width="160" height="90" rx="6" fill="#0f172a"/>
  <rect width="160" height="90" rx="6" fill="rgba(76,29,149,0.4)" stroke="#a78bfa" stroke-width="1.5"/>
  <!-- Header -->
  <rect width="160" height="28" rx="6" fill="rgba(76,29,149,0.6)"/>
  <text x="80" y="19" fill="white" font-size="11" font-weight="700" text-anchor="middle">TableName</text>
  <!-- Fields -->
  <text x="10" y="46" fill="#e2e8f0" font-size="9">🔑 id: UUID</text>
  <text x="10" y="60" fill="#94a3b8" font-size="9">name: VARCHAR(255)</text>
  <text x="10" y="74" fill="#94a3b8" font-size="9">created_at: TIMESTAMP</text>
</g>
```

### Cardinality Notation

Use crow's foot notation on relationship lines:

```
1 ──────── 1    One-to-One
1 ──────── ∅    One-to-Zero-or-One
1 ──────── ∞    One-to-Many
∅ ──────── ∞    Zero-or-One-to-Many
∞ ──────── ∞    Many-to-Many
```

## Org Chart

### Layout

- Tree structure, top-down
- Root node at top center
- Children spread horizontally below parent
- Spacing: 80px horizontal between siblings, 100px vertical between levels

### Node

```svg
<g transform="translate(X, Y)">
  <rect width="140" height="50" rx="8" fill="#0f172a"/>
  <rect width="140" height="50" rx="8" fill="rgba(59,130,246,0.3)" stroke="#60a5fa" stroke-width="1.5"/>
  <text x="70" y="22" fill="white" font-size="10" font-weight="600" text-anchor="middle">Name</text>
  <text x="70" y="38" fill="#94a3b8" font-size="8" text-anchor="middle">Title / Role</text>
</g>
```
