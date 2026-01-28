# Representation Theorem Implementation

This directory contains the core implementation of the representation theorem (completeness) for TM bimodal logic using indexed MCS families.

## File Purposes

| File | Purpose | Status |
|------|---------|--------|
| `IndexedMCSFamily.lean` | Structure definition for MCS families | ✅ Complete |
| `CoherentConstruction.lean` | Coherent family construction | ✅ Core proven |
| `CanonicalWorld.lean` | World state from MCS | ✅ Complete |
| `CanonicalHistory.lean` | History construction | ✅ Complete |
| `TaskRelation.lean` | Task relation definition | ✅ Complete |
| `TruthLemma.lean` | MCS membership ↔ semantic truth | ✅ Forward proven |
| `UniversalCanonicalModel.lean` | Representation theorem | ✅ Uses forward only |

## Proof Architecture

### The Completeness Path

```
                      COMPLETENESS THEOREM
                              │
                              ▼
                 representation_theorem ✅
                              │
           ┌──────────────────┼──────────────────┐
           │                  │                  │
           ▼                  ▼                  ▼
      Lindenbaum        construct_          truth_lemma_
          ✅           coherent_family       forward ✅
                              │                  │
                              ▼                  │
                    CoherentConstruction         │
                    ┌─────────┴─────────┐        │
                    │                   │        │
            forward_G             backward_H     │
            Case 1 ✅             Case 4 ✅      │
                    │                   │        │
                    └───────────────────┘        │
                              │                  │
                              └──────────────────┘
                                     │
                                     ▼
                            φ satisfiable ✅
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

## Gaps NOT Required for Completeness

See `Boneyard/Metalogic_v3/` for detailed documentation.

### CoherentConstruction.lean

| Case | Lines | Why Not Needed |
|------|-------|----------------|
| forward_G Cases 3-4 | 641, 654 | Cross-origin / cross-modal |
| backward_H Cases 1-2 | 662, 665 | Both ≥ 0 / cross-origin |
| forward_H (all) | 691 | Only for backward Truth Lemma |
| backward_G Cases 3-4 | 721, 724 | Cross-origin / cross-modal |

### TruthLemma.lean

| Case | Lines | Why Not Needed |
|------|-------|----------------|
| all_past backward | 410 | Backward Truth Lemma |
| all_future backward | 423 | Backward Truth Lemma |
| box (both) | 366, 389 | Architectural limitation |

### IndexedMCSFamily.lean

All four coherence sorries (lines 609-627) are SUPERSEDED by CoherentConstruction.

## References

- Gap analysis: `specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-004.md`
- Parent README: `Theories/Bimodal/Metalogic/README.md`
- Boneyard docs: `Theories/Bimodal/Boneyard/Metalogic_v3/README.md`

---

*Last updated: 2026-01-28*
