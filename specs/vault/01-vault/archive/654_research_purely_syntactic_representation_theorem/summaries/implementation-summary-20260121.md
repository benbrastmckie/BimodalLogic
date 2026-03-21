# Implementation Summary: Task #654

**Status**: BLOCKED
**Completed**: 2026-01-21
**Duration**: ~2 hours
**Session**: sess_1768955728_3752bb

## Overview

This implementation attempt for the Universal Parametric Canonical Model encountered a fundamental design flaw in the canonical history construction. The approach cannot be completed without architectural changes.

## Changes Made

### Phase 0: Archive and Setup [COMPLETED]
- Moved `Bimodal/Metalogic_v2/` to `Bimodal/Boneyard/Metalogic_v2/`
- Created fresh `Bimodal/Metalogic/` directory structure
- Established module hierarchy: Core/, Representation/

### Phase 1: Port Core MCS Infrastructure [COMPLETED]
- Created `Metalogic/Core/MaximalConsistent.lean` re-exporting Boneyard MCS theory
- Set-based MCS definitions available: `SetConsistent`, `SetMaximalConsistent`
- `set_lindenbaum` (Lindenbaum's lemma) available

### Phase 2: Define Canonical World Structure [COMPLETED]
- Created `Metalogic/Representation/CanonicalWorld.lean`
- Defined `CanonicalWorld D` structure pairing MCS with abstract time point
- Contains 2 sorries for MCS properties (neg_complete, deductively_closed)
  - These require set-based proofs not available in Boneyard

### Phase 3: Define Canonical Task Relation [BLOCKED]
- Created `Metalogic/Representation/TaskRelation.lean`
- Defined `canonical_task_rel` using formula propagation conditions
- `canonical_task_rel_nullity` proven (trivial)
- `canonical_task_rel_comp` has 6 sorries for compositionality cases

### Phase 4: Construct Canonical WorldHistory [BLOCKED]
- Created `Metalogic/Representation/CanonicalHistory.lean`
- Defined `UniversalCanonicalFrame D : TaskFrame D`
- Defined `canonical_history` construction using same MCS at all times
- **FUNDAMENTAL ISSUE**: `canonical_history_respects` has 2 sorries requiring T-axiom for temporal operators

### Phases 5-6: [NOT ATTEMPTED]
- Blocked by Phase 4 design issue

## Files Modified

| File | Status | Description |
|------|--------|-------------|
| `Bimodal/Metalogic/Core/MaximalConsistent.lean` | Created | Re-exports Boneyard MCS theory |
| `Bimodal/Metalogic/Representation/CanonicalWorld.lean` | Created | CanonicalWorld structure (2 sorries) |
| `Bimodal/Metalogic/Representation/TaskRelation.lean` | Created | Task relation definition (6 sorries) |
| `Bimodal/Metalogic/Representation/CanonicalHistory.lean` | Created | History construction (2 sorries) |

## Verification

- Lake build: SUCCESS (with sorry warnings)
- No type errors
- All files compile

## Fundamental Issue Discovered

### Problem Statement

The `canonical_history` construction assigns the SAME MCS (Gamma) to every time point:
```lean
def canonical_history_states (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    (t : D) -> full_domain D t -> (UniversalCanonicalFrame D).WorldState :=
  fun t _ => { mcs := Gamma, time := t, is_mcs := h_mcs }
```

For the history to respect the task relation, we need to prove:
```lean
canonical_task_rel (Gamma, s) (t - s) (Gamma, t)  -- for s <= t
```

When `t - s > 0`, the task relation requires:
- `G phi in Gamma -> phi in Gamma` (for all phi)
- `H phi in Gamma -> phi in Gamma` (for all phi)

These are the **T-axioms for temporal operators** (`G phi -> phi` and `H phi -> phi`).

### Critical Insight

**TM logic does NOT have temporal T-axioms.** The axiom system includes:
- Modal T: `[]phi -> phi` (reflexivity for necessity)
- Temporal 4: `Fphi -> FFphi` (transitivity)
- Temporal A, L: (connectedness, introspection)

But there is NO axiom of the form:
- `Gphi -> phi` (what's always true in future is true now)
- `Hphi -> phi` (what's always true in past is true now)

This is by design - temporal operators in TM are "strict" in the sense that `G phi` (always in future) doesn't imply `phi` at the present moment.

### Why This Is Fundamental

The canonical history construction where all worlds share the same MCS cannot work because:
1. The task relation requires formula propagation from temporal operators
2. When source and target MCS are the same, this reduces to T-axiom conditions
3. T-axioms for temporal operators are NOT derivable in TM

### Required Architectural Change

The canonical history construction needs to be redesigned to use DIFFERENT MCS at different times:

1. **Multiple MCS**: Instead of a single Gamma, we need a family of MCS indexed by time
2. **Formula Propagation**: MCS at adjacent times must satisfy:
   - If `G phi in MCS(t)` then `phi in MCS(t')` for all t' > t
   - If `H phi in MCS(t)` then `phi in MCS(t')` for all t' < t
3. **Construction**: Use Lindenbaum's lemma to construct compatible MCS at each time point
4. **Compositionality**: Follows from the construction, not from a single MCS

This is similar to the approach in classical temporal logic completeness proofs where the canonical model has distinct maximal consistent sets at different times, connected by the appropriate accessibility relations.

## Recommendations

### Option 1: Redesign Canonical History (Estimated: 20-30 hours)

1. Define `WorldHistoryMCS : Set D -> (D -> Set Formula)` representing MCS at each time
2. Prove existence of compatible MCS families using Lindenbaum + Choice
3. Construct canonical history from MCS family
4. Prove truth lemma for MCS-based history
5. Complete representation theorem

### Option 2: Use Semantic Canonical Model (Existing)

The `SemanticCanonicalModel` in Boneyard uses a different approach:
- World states are equivalence classes of (History, Time) pairs
- Task relation defined via history existence
- Avoids the T-axiom issue by not using formula propagation

Limitation: Fixed to `Int` time type, compositionality has a sorry due to finite bounds.

### Option 3: Hybrid Approach

Combine the universal parametric frame idea with the semantic history approach:
- Keep `CanonicalWorld D` structure
- Redefine task relation via history existence (like SemanticCanonicalModel)
- Avoid formula propagation entirely

## Notes

The research report (research-003.md) did not anticipate this issue because it assumed:
> "G phi in w.mcs -> phi in v.mcs"

could be satisfied when building histories through an MCS. The implicit assumption was that all times would share the same MCS, which requires temporal T-axioms.

The report's formula propagation approach is correct for the DEFINITION of task_rel, but the CONSTRUCTION of canonical histories that satisfy this relation requires more care.

## Files for Reference

- Current code: `Bimodal/Metalogic/Representation/*.lean`
- Boneyard approach: `Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
- Research report: `specs/654_.../reports/research-003.md`
- Implementation plan: `specs/654_.../plans/implementation-003.md`
