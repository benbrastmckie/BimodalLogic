# FMP Bridge - Archived Due to Architectural Limitations

## Files in this Archive

- `ConsistentSatisfiable.lean` - 9 sorries
- `FiniteStrongCompleteness.lean` - 1 sorry

## Why These Files Were Archived

These files attempted to bridge between two different semantic notions:
1. **FMP-internal validity**: Truth at `SemanticWorldState` (finite closure-based models)
2. **General validity**: Truth in all `TaskModel` instances

### The Core Problem

The bridge lemma `mcs_world_truth_correspondence` attempts to prove:
```lean
w.models psi h_mem <-> truth_at (fmpTaskModel phi) (fmpWorldHistory phi w) 0 psi
```

**Problem 1 (Modal Box)**: The FMP TaskFrame has all `FiniteWorldState` values as possible
world states with permissive accessibility (`task_rel = True`). For `truth_at ... (box psi)`,
we need psi true at ALL reachable states, not just MCS-derived ones. But non-MCS states
don't satisfy modal axioms, making the correspondence fail.

**Problem 2 (Temporal Operators)**: The FMP WorldHistory is constant (same state at all times).
Temporal operators require truth at strictly future/past times, but constant history
trivializes temporal structure, breaking the correspondence for `all_future` and `all_past`.

### What This Breaks

1. **ConsistentSatisfiable.lean**: The `consistent_satisfiable` theorem depends on
   `mcs_world_truth_correspondence` to embed FMP models into the general semantic
   framework. With 6 sorries in the modal/temporal cases, this bridge is incomplete.

2. **FiniteStrongCompleteness.lean**: The `weak_completeness` helper depends on converting
   general validity to FMP-internal validity, which requires the same blocked bridge.

## What Still Works

The sorry-free completeness results that DON'T require this bridge:

1. **`semantic_weak_completeness`** in `FMP/SemanticCanonicalModel.lean` - SORRY-FREE
   - Uses FMP-internal validity directly, no bridge needed
   - This is the primary completeness result for the project

2. **BMCS completeness** in `Bundle/Completeness.lean` - SORRY-FREE core
   - `bmcs_weak_completeness` and `bmcs_strong_completeness`
   - Uses Henkin-style bundled MCS families

## Alternative Approaches

### Approach A: Different Semantic Framework
Instead of general `TaskModel` validity, define validity directly over FMP-internal models.
This is what `semantic_weak_completeness` already does and is the recommended approach.

### Approach B: Restricted Accessibility
Modify `fmpTaskFrame` to have restricted accessibility that only connects MCS-derived states.
This would require:
- Tracking which world states are MCS-derived
- Defining accessibility based on MCS relationships
- Proving the resulting frame satisfies TM axioms

### Approach C: Multi-History Construction
Use the FDSM multi-history saturation (being developed in task 826) to ensure all
accessible states are properly MCS-derived. This is the approach taken by
`ModalSaturation.lean` with `MCSTrackedHistory`.

## Decision

These files are archived rather than deleted because:
1. The propositional cases ARE proven correctly
2. The architecture documents why modal/temporal cases fail
3. Future work might find alternative approaches

The recommended path is to use:
- `semantic_weak_completeness` for FMP-based completeness
- `bmcs_weak_completeness` for Henkin-style completeness
- The upcoming FDSM completeness for bounded temporal logic

## References

- Task 810 research-005: Original blockage analysis
- Task 826: FDSM completeness with saturated construction (current work)
- `SemanticCanonicalModel.lean`: Working sorry-free completeness

## Date Archived

2026-02-03 (Task 826, Phase 0)
