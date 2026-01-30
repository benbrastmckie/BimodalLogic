# Canonical Model Core Definitions

This directory contains the core definition files for canonical model construction. These are the sorry-free foundational components used by `FMP/` for the completeness proof.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `IndexedMCSFamily.lean` | Indexed MCS family structure | Complete |
| `CanonicalWorld.lean` | Canonical world state definitions | Complete |

## Overview

### IndexedMCSFamily.lean

Defines the `IndexedMCSFamily` structure - a time-indexed collection of maximal consistent sets with coherence conditions:

```lean
structure IndexedMCSFamily (D : Type*) where
  gamma : D → MCS
  coherence_G : ∀ t₁ t₂, t₁ ≤ t₂ → ... -- G-preservation
  coherence_H : ∀ t₁ t₂, t₁ ≥ t₂ → ... -- H-preservation
```

Key results:
- Family structure definition
- Coherence condition specifications
- Basic family operations

### CanonicalWorld.lean

Defines canonical world states constructed from MCS membership:

```lean
def canonical_world_state (family : IndexedMCSFamily D) (t : D) : WorldState := ...
```

Provides the interface between MCS membership and semantic world states.

## Relationship to Other Directories

The complete canonical model construction and representation theorem live in `UnderDevelopment/RepresentationTheorem/`. This directory contains only the sorry-free core definitions that are stable and imported by `FMP/`.

For completeness proofs, use `semantic_weak_completeness` from `FMP/SemanticCanonicalModel.lean` which provides a sorry-free completeness result via a contrapositive approach.

## Dependencies

- `Core/` - MCS theory and Lindenbaum's lemma

## Related Files

- `../FMP/SemanticCanonicalModel.lean` - Uses these definitions for completeness
- `../UnderDevelopment/RepresentationTheorem/` - Full canonical model construction
- `../Core/README.md` - MCS foundations

---

*Last updated: 2026-01-30*
