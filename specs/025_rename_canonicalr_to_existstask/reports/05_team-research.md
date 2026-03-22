# Research Report: Task 25 Blocker Analysis

**Task**: 25 - Rename CanonicalR to ExistsTask
**Date**: 2026-03-22
**Session**: sess_1774214243_f002cc
**Focus**: Why is per-witness strictness required? What can be simplified given Task 29's reflexive semantics goal?

## Executive Summary

**Critical Finding**: Task 25's Phase 1-2 work (proving per-witness strictness via fresh G-atoms) is **duplicated in Task 29's Phase 5**. Since Task 29 is the comprehensive reflexive semantics refactoring, Task 25 should be **restructured to depend on Task 29** rather than independently proving the same theorems.

**Recommendation**: Revise Task 25's plan to:
1. Skip Phases 1-2 entirely (defer to Task 29)
2. Execute Phase 3 (retire Gabbay infrastructure) after Task 29 completes
3. Execute Phase 4 (rename CanonicalR to ExistsTask) after Task 29 completes
4. Make Phase 5 (optional theorems) truly optional

## Key Findings

### 1. Task 25 and Task 29 Have Overlapping Work

| Task 25 Phase | Task 29 Phase | Overlap |
|---------------|---------------|---------|
| Phase 1: Fresh G-atom infrastructure | Phase 5.1: Fresh atom infrastructure | **100% overlap** |
| Phase 1: `existsTask_strict_fresh_atom` | Phase 5.2: `canonicalR_strict_successor` | **Same theorem** |
| Phase 2: Update 12 call sites | Phase 5.3-5.4: Update ~35 call sites | **Superset** |
| Phase 2: Delete `canonicalR_irreflexive_axiom` | Phase 5.5: Remove axiom | **Same** |

Task 29's Phase 5 is a **superset** of Task 25's Phases 1-2. Proving both separately wastes effort.

### 2. The 12 Call Sites Analysis

All 12 `canonicalR_strict` call sites follow the same pattern in `Antisymmetrization` quotient proofs:

**Pattern**: Proving `[M] < [W]` in the quotient requires:
1. `M ≤ W` (from `CanonicalR M W` or `M = W`)
2. `¬(W ≤ M)` (requires BOTH `W ≠ M` AND `¬CanonicalR W M`)

**Call site breakdown**:
- `CanonicalSerialFrameInstance.lean`: 4 sites (NoMaxOrder, NoMinOrder)
- `CantorApplication.lean`: 4 sites (NoMaxOrder, NoMinOrder, DenselyOrdered)
- `DovetailedTimelineQuot.lean`: 4 sites (same pattern)
- `DiscreteTimeline.lean`: 2 sites (NoMaxOrder, NoMinOrder)

All sites need `¬CanonicalR W M` for the constructed witness W, which is exactly what `canonicalR_strict_successor/predecessor` provides.

### 3. Under Reflexive Semantics

Task 29 makes `CanonicalR M M` TRUE (reflexive) by definition:
- `g_content M ⊆ M` holds via T-axiom
- The axiom `canonicalR_irreflexive` becomes FALSE

This means:
- Universal irreflexivity is **impossible** under reflexive semantics
- Per-witness strictness (∃W, CanonicalR M W ∧ ¬CanonicalR W M) is still **TRUE** and needed
- The fresh G-atom approach works identically under reflexive semantics

### 4. Why Per-Witness Strictness IS Required

Even under reflexive semantics, we still need strictness for order properties:

1. **NoMaxOrder/NoMinOrder**: Given any MCS M, must find W where M < W (strictly greater)
   - Reflexive CanonicalR gives M ≤ W
   - Strictness requires ¬(W ≤ M), which needs `¬CanonicalR W M`

2. **DenselyOrdered**: Given M < N, must find W where M < W < N
   - Requires strict ordering at both ends

3. **Antisymmetrization quotient**: The quotient construction collapses M ~ N when both `CanonicalR M N` and `CanonicalR N M`
   - Distinct points require asymmetry: `CanonicalR M N` but `¬CanonicalR N M`

**Bottom line**: Per-witness strictness is NOT about irreflexivity of CanonicalR itself, but about proving distinct MCS exist in the quotient structure.

### 5. Task Dependency Analysis

Current state:
- Task 29: Phases 0-4, 7-8 COMPLETED; Phases 5-6 NOT STARTED
- Task 25: Phase 1 PARTIAL (3 sorries in fresh G-atom proofs)

Correct dependency:
```
Task 29 Phase 5 (fresh G-atom strictness)
    ↓
Task 25 Phase 3 (retire Gabbay infrastructure)
    ↓
Task 25 Phase 4 (rename CanonicalR → ExistsTask)
```

## Recommended Revisions to Task 25

### Current Plan (5 phases)
1. [PARTIAL] Fresh G-Atom Infrastructure (3h) - BLOCKED
2. [NOT STARTED] Update Call Sites (3.5h)
3. [NOT STARTED] Retire Gabbay Infrastructure (1h)
4. [NOT STARTED] Rename CanonicalR to ExistsTask (5h)
5. [NOT STARTED] Optional theorems (2.5h)

### Revised Plan (3 phases)

**Phase 1: Wait for Task 29 Phase 5** [BLOCKED]
- Dependency: Task 29 Phase 5 must complete first
- Task 29 provides: `canonicalR_strict_successor`, `canonicalR_strict_predecessor`
- Task 29 removes: `canonicalR_irreflexive_axiom`
- Effort: 0h (done by Task 29)

**Phase 2: Retire Gabbay Infrastructure** [NOT STARTED]
- Delete the 1200-line naming set infrastructure
- Keep only: `canonicalR_reflexive`, `canonicalR_past_reflexive`
- Verification: File reduced to <100 lines
- Effort: 1h

**Phase 3: Rename CanonicalR to ExistsTask** [NOT STARTED]
- Rename definition in CanonicalFrame.lean
- Add `@[simp] lemma ExistsTask_def`
- Batch rename across ~49 files
- Handle edge cases (5 rw tactic sites)
- Effort: 5h

**Skip Phase 5**: The new CanonicalTask theorems are optional enrichment; defer indefinitely.

### Immediate Actions

1. **Mark Task 25 as BLOCKED by Task 29**
   - Add dependency: `[29]` in TODO.md
   - Update state.json with dependency

2. **Abandon Phase 1-2 work**
   - The 3 sorries in CanonicalIrreflexivity.lean should be deleted
   - The `existsTask_strict_fresh_atom` etc. will be superseded by Task 29

3. **Resume Task 29 Phase 5**
   - This is the correct place to prove fresh G-atom strictness
   - Once complete, Task 25 can proceed with Phases 2-3

## 3 Sorries Analysis

The current sorries in `CanonicalIrreflexivity.lean` (lines 1283, 1294, 1405):

1. **Line 1283**: Case when `q ∈ M` - needs atom selection strategy
2. **Line 1294**: "Always false" atom case - needs infinite atoms argument
3. **Line 1405**: Seed consistency when `G(q) ∈ L` - proof structure issue

These are real mathematical gaps, but they should be solved **in Task 29, not Task 25**. Task 29's FreshAtom.lean (planned new file) is the correct location.

## Confidence Level

**High confidence** in recommendations:
- The overlap between Task 25 Phase 1-2 and Task 29 Phase 5 is clear from plan comparison
- The call site analysis confirms per-witness strictness is needed for quotient properties
- The dependency structure is logically sound

## References

- Task 29 Plan v3: `specs/029_switch_to_reflexive_gh_semantics/plans/03_fresh-g-atom-approach.md`
- Task 25 Plan: `specs/025_rename_canonicalr_to_existstask/plans/01_implementation-plan.md`
- Call sites: `grep -r "canonicalR_strict\|canonicalR_irreflexive" Theories/`
- CanonicalSerialFrameInstance.lean: Lines 43-78 (NoMaxOrder), 88-124 (NoMinOrder)
