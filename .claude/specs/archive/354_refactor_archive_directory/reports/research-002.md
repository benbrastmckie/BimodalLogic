# Research Report: Task #354 (Follow-up)

**Task**: Research and refactor Archive/ directory
**Date**: 2026-01-11
**Focus**: Should examples move to Bimodal/Examples/ with future Logos layer examples co-located?

## Summary

After analyzing the Mathlib4 pattern, the existing Logos layer architecture, and your long-term vision, **moving examples into `Bimodal/Examples/` makes strong sense** for the bimodal logic examples. This sets a pattern where each Logos layer extension can have its own `Examples/` subdirectory, creating a consistent, scalable architecture.

## Findings

### 1. Mathlib4 Pattern Analysis

[Mathlib4](https://github.com/leanprover-community/mathlib4) uses a **separation model**:
- `Mathlib/` - Main library (definitions, theorems)
- `MathlibTest/` - Separate test directory
- `Counterexamples/` - Dedicated examples/counterexamples directory
- `Archive/` - Historical/archived content

Key insight: Mathlib's `Counterexamples/` is **standalone**, not embedded within `Mathlib/`. However, this pattern evolved for a massive 8000+ module library. For a modular, layered system like Logos, **embedding examples within each layer** may be more appropriate.

### 2. Current Logos Architecture

The Logos project has a **modular layer architecture**:

```
Logos/
├── Core.lean           # Re-exports Bimodal (backwards compat)
├── Examples/           # Shims → Archive/ (current, confusing)
├── Explanatory/        # Layer 1 (planned, stub only)
├── Epistemic/          # Layer 2 (planned, stub only)
├── Normative/          # Layer 3 (planned, stub only)
└── Lint/               # Linting utilities

Bimodal/                # Layer 0 implementation (independent)
├── Syntax/
├── ProofSystem/
├── Semantics/
├── Metalogic/
├── Theorems/
└── Automation/

Archive/                # Actual examples (pedagogical content)
```

**Problem**: The current `Logos/Examples/` → `Archive/` shim architecture is confusing and doesn't scale to multiple layers.

### 3. Proposed Architecture: Co-located Examples

Your proposed structure makes excellent sense:

```
Bimodal/
├── Syntax/
├── ProofSystem/
├── Semantics/
├── Metalogic/
├── Theorems/
├── Automation/
└── Examples/                   # NEW: Move from Archive/
    ├── ModalProofs.lean
    ├── ModalProofStrategies.lean
    ├── TemporalProofs.lean
    ├── TemporalProofStrategies.lean
    ├── BimodalProofs.lean
    ├── BimodalProofStrategies.lean
    └── TemporalStructures.lean

Logos/
├── Explanatory/
│   ├── Syntax/
│   ├── Semantics/
│   └── Examples/               # FUTURE: Layer 1 examples
├── Epistemic/
│   ├── Syntax/
│   ├── Semantics/
│   └── Examples/               # FUTURE: Layer 2 examples
├── Normative/
│   ├── Syntax/
│   ├── Semantics/
│   └── Examples/               # FUTURE: Layer 3 examples
└── Examples.lean               # Aggregates all layer examples
```

### 4. Benefits of Co-located Examples

| Benefit | Description |
|---------|-------------|
| **Discoverability** | Examples live next to the code they demonstrate |
| **Independence** | Each layer's examples can evolve independently |
| **Imports** | `import Bimodal.Examples` - clean, consistent |
| **Scalability** | Pattern extends naturally to future layers |
| **Maintenance** | Changes to layer code are close to examples |
| **Testing** | Examples serve as integration tests for each layer |

### 5. Import Path Comparison

**Current (Confusing)**:
```lean
import Archive.ModalProofs          -- Works
import Logos.Examples.ModalProofs   -- Works (shim)
```

**Proposed (Clean)**:
```lean
import Bimodal.Examples.ModalProofs  -- Direct
import Bimodal.Examples              -- All Bimodal examples

-- Future layer examples
import Logos.Explanatory.Examples.CausalReasoning
import Logos.Epistemic.Examples.BeliefRevision
import Logos.Normative.Examples.PermissionLogic
```

### 6. What Happens to Archive/?

**Option A (Recommended)**: Remove `Archive/` entirely after migration
- Move `.lean` files to `Bimodal/Examples/`
- Move `logos-original/` to `.claude/archive/logos-original/` (documentation history)
- Update lakefile to remove `lean_lib Archive`
- Provides clean break, eliminates confusion

**Option B**: Keep `Archive/` as thin shim for backwards compatibility
- `Archive/` files import and re-export `Bimodal.Examples.*`
- Similar to current `Logos/Core.lean` → `Bimodal` pattern
- More complex but preserves existing import paths

### 7. What Happens to Logos/Examples/?

The current `Logos/Examples/` directory contains shim files that re-export Archive. After migration:

**Recommended**: Repurpose `Logos/Examples/` as an aggregator:
```lean
-- Logos/Examples.lean
import Bimodal.Examples           -- All Bimodal (Layer 0) examples
-- Future:
-- import Logos.Explanatory.Examples
-- import Logos.Epistemic.Examples
-- import Logos.Normative.Examples
```

This allows `import Logos.Examples` to provide ALL examples across all layers.

### 8. Implementation Considerations

**lakefile.lean Changes**:
```lean
-- Current
lean_lib Archive

-- After migration
-- Remove Archive line
-- Bimodal already includes Examples/ implicitly
```

**Namespace Changes**:
```lean
-- Current
namespace Archive

-- After migration
namespace Bimodal.Examples
```

**Import Updates**:
All 8 files in `Archive/` need:
1. Move to `Bimodal/Examples/`
2. Change `namespace Archive` → `namespace Bimodal.Examples`
3. Imports already correct (use `Bimodal.*`)

## Recommendations

### Primary Recommendation

**Move examples to `Bimodal/Examples/`** with the following plan:

1. Create `Bimodal/Examples/` directory
2. Move 7 example `.lean` files from `Archive/`
3. Update namespaces from `Archive` to `Bimodal.Examples`
4. Create `Bimodal/Examples.lean` aggregator
5. Update `Bimodal/Bimodal.lean` to import Examples
6. Repurpose `Logos/Examples.lean` as layer aggregator
7. Remove `Archive/` directory (or convert to backwards-compat shim)
8. Move `logos-original/` to `.claude/archive/`
9. Update lakefile to remove `lean_lib Archive`

### Secondary Consideration

Keep backwards compatibility with `Archive.*` imports during transition:
- Create thin `Archive/` shims that re-export `Bimodal.Examples.*`
- Mark as deprecated, remove in future release

### Future Layer Pattern

When implementing Logos layers (Explanatory, Epistemic, Normative):
```
Logos/{Layer}/Examples/
├── {Layer}Proofs.lean
├── {Layer}ProofStrategies.lean
└── {Layer}Structures.lean
```

## References

- [Mathlib4 GitHub](https://github.com/leanprover-community/mathlib4) - Directory structure reference
- `Archive/logos-original/LOGOS_LAYERS.md` - Layer architecture specification
- `Logos/Explanatory/README.md` - Layer 1 placeholder documentation

## Next Steps

1. `/plan 354` - Create detailed implementation plan
2. Execute migration (move files, update imports)
3. Test build with `lake build`
4. Document new import paths in README files
