# Math Context Directory

Mathematical foundations context for the ProofChecker project.

## Subdirectories

| Directory | Content |
|-----------|---------|
| `algebra/` | Algebraic structures (groups, rings, monoids) |
| `lattice-theory/` | Lattice structures, complete lattices, quantales |
| `order-theory/` | Partial orders, well-founded relations |
| `topology/` | Topological structures, metric spaces |
| `foundations/` | Foundational mathematics (dependent type theory) |

## Loading Pattern

Load files dynamically using index.json queries:

```bash
# Find all math context files
jq -r '.entries[] |
  select(.path | contains("/math/")) |
  "\(.path): \(.summary)"' .claude/context/index.json
```

## Related Context

- Logic domain: `.claude/context/project/logic/` - Modal logic and Kripke semantics
- Lean patterns: `.claude/context/project/lean4/patterns/` - Proof tactics and patterns
