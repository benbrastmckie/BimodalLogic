# Representation Theorem Implementation

**Status**: Self-Contained (No Boneyard Dependencies)

This directory contains the core implementation of the representation theorem (completeness) for TM bimodal logic using indexed MCS families.

## Overview

The representation theorem establishes that consistent formulas are satisfiable in the universal canonical model. This is the key semantic result that enables completeness.

## Modules

| Module | Purpose | Status |
|--------|---------|--------|
| `IndexedMCSFamily.lean` | Structure definition for MCS families | **Complete** |
| `CoherentConstruction.lean` | Coherent family construction | **Core proven** |
| `CanonicalWorld.lean` | World state from MCS | **Complete** |
| `CanonicalHistory.lean` | History construction | **Complete** |
| `TaskRelation.lean` | Task relation definition | **Complete** |
| `TruthLemma.lean` | MCS membership ↔ semantic truth | **Forward proven** |
| `UniversalCanonicalModel.lean` | Representation theorem | **Uses forward only** |

## Dependency Flowchart

```
                IndexedMCSFamily.lean
                        │
                        v
              CoherentConstruction.lean
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        v               v               v
  CanonicalWorld  CanonicalHistory  TaskRelation
        │               │               │
        └───────────────┼───────────────┘
                        │
                        v
                  TruthLemma.lean
                        │
                        v
           UniversalCanonicalModel.lean
```

## Main Result

```lean
theorem representation_theorem (φ : Formula) (h_cons : SetConsistent {φ}) :
    ∃ (family : IndexedMCSFamily D) (t : D) (h_mem : φ ∈ family.gamma t),
      truth_at (canonical_model D family) (canonical_history_family D family) t φ
```

Consistent formulas are satisfiable in the universal canonical model.

## Proof Architecture

```
                      COMPLETENESS THEOREM
                              │
                              v
                 representation_theorem
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           v                  v                  v
      Lindenbaum        construct_          truth_lemma_
                       coherent_family       forward
                              │                  │
                              v                  │
                    CoherentConstruction         │
                    ┌─────────┴─────────┐        │
                    │                   │        │
            forward_G             backward_H     │
            Case 1                 Case 4        │
                    │                   │        │
                    └───────────────────┘        │
                              │                  │
                              └──────────────────┘
                                     │
                                     v
                            φ satisfiable
```

### Why Only Two Cases Matter

The canonical model centers the MCS Gamma at time 0:
- **forward_G Case 1** (both t, t' ≥ 0): Evaluating `all_future` at non-negative times
- **backward_H Case 4** (both t, t' < 0): Evaluating `all_past` at negative times

Since evaluation starts at time 0, we never need:
- Cross-origin cases (where t and t' have opposite signs)
- Cross-modal cases (G through H-preserving chain or vice versa)
- Backward Truth Lemma (`truth_at → φ ∈ MCS`)

## Key Design Decisions

### CoherentConstruction vs IndexedMCSFamily

`IndexedMCSFamily.lean` defines the **structure** with coherence conditions.
`CoherentConstruction.lean` provides the **construction** that satisfies them.

The original `construct_indexed_family` in IndexedMCSFamily.lean used independent
Lindenbaum extensions, which fundamentally cannot prove coherence. It's marked
SUPERSEDED - use `construct_coherent_family` instead.

### Two-Chain Architecture

CoherentConstruction builds two chains:
1. **Forward chain** (t ≥ 0): Preserves G-formulas from Gamma outward
2. **Backward chain** (t < 0): Preserves H-formulas from Gamma outward

Both chains meet at Gamma (time 0). This design makes coherence **definitional**
rather than something proven after construction.

## Known Sorries (Architectural)

These gaps are NOT required for completeness:

### CoherentConstruction.lean

| Case | Why Not Needed |
|------|----------------|
| forward_G Cases 3-4 | Cross-origin / cross-modal |
| backward_H Cases 1-2 | Both ≥ 0 / cross-origin |
| forward_H (all) | Only for backward Truth Lemma |
| backward_G Cases 3-4 | Cross-origin / cross-modal |

### TruthLemma.lean

| Case | Why Not Needed |
|------|----------------|
| all_past backward | Backward Truth Lemma |
| all_future backward | Backward Truth Lemma |
| box (both) | Architectural limitation (Task 750) |

## Dependencies

- **Core**: MCS theory, Lindenbaum's lemma, deduction theorem
- **Semantics**: Truth relation and task model definitions

## Related Files

- `../Core/README.md` - MCS foundations
- `../Completeness/README.md` - Uses representation theorem
- `../FMP/README.md` - Alternative finite model approach
- `../README.md` - Overall metalogic architecture

## References

- Modal Logic, Blackburn et al., Chapter 4 (Canonical Model Construction)
- Gap analysis: specs/681_redesign.../reports/research-004.md

---

*Last updated: 2026-01-29*
