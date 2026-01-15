# Research Report: Task #473

**Task**: 473 - Fix compositionality gaps from Task 458
**Started**: 2026-01-13T17:40:00Z
**Completed**: 2026-01-13T18:00:00Z
**Effort**: 8-12 hours (estimated implementation)
**Priority**: Medium
**Parent**: Task 458
**Dependencies**: None (builds on Task 458 and 464 work)
**Sources/Inputs**:
  - FiniteCanonicalModel.lean (current implementation with gaps)
  - Task 458 implementation-summary-20260113.md
  - Task 464 research-001.md (Strategy A analysis)
  - Task 464 implementation-summary-20260112.md
  - Lean MCP tools (lean_goal, lean_diagnostic_messages)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md, artifact-formats.md

## Executive Summary

- **7 compositionality gaps** in `finite_task_rel` compositionality proof (mixed-sign duration cases)
- **8 truth lemma gaps** requiring negation-completeness of world states
- **2 history construction gaps** requiring proper witness construction
- **Root Cause**: `IsLocallyConsistent` only captures soundness (forward direction) but not completeness (backward direction / negation-completeness)
- **Primary Solution**: Strengthen `IsLocallyConsistent` to include negation-completeness and implication-completeness, or restructure to use already-proven `SetMaximalConsistent` properties
- **Alternative Solution**: Accept gaps as documented limitations and prove compositionality semantically after model construction

## Context & Scope

### Problem Overview

Task 458 implemented a finite canonical model approach for completeness of TM bimodal logic. The implementation created `FiniteCanonicalModel.lean` with 1432 lines defining:

1. **FiniteTime** - Bounded time domain `Fin (2*k+1)` for temporal depth k
2. **FiniteWorldState** - Truth assignments on subformula closure with local consistency
3. **finite_task_rel** - Task relation with box/future/past transfer and persistence properties
4. **FiniteCanonicalFrame/Model** - TaskFrame and TaskModel structures
5. **finite_truth_lemma** - Truth lemma connecting membership to semantic truth

### Gap Classification

| Category | Count | Location | Description |
|----------|-------|----------|-------------|
| Compositionality | 7 | Lines 808, 825, 841, 848, 863, 866, 874, 876 | Mixed-sign duration cases |
| Truth Lemma | 8 | Lines 1296, 1300, 1328, 1338, 1360, 1382 | Negation-completeness cases |
| History Construction | 2 | Lines 1131, 1134 | Relation witness construction |

## Findings

### 1. Compositionality Gaps Analysis

The `finite_task_rel` compositionality proof has 7 sorry gaps in the mixed-sign duration cases. Inspecting the goal state reveals the core pattern:

**Case: x > 0, y < 0, x + y > 0 (Future Transfer)**

```
Given:
- h_wu_fut: x > 0 -> (Gpsi in w -> psi in u)
- h_wu_fut_pers: x >= 0 -> (Gpsi in w -> Gpsi in u)
- h_uv_past: y < 0 -> (Hpsi in u -> psi in v)
- h_w_fut: w.models Gpsi
- h_u_psi: u.models psi  (from future_transfer w->u)

Goal: v.models psi
```

**Why This Fails**: We have `psi` at time x (in u), and we need `psi` at time x+y > 0 (in v). But:
- From u to v (duration y < 0), only past_transfer applies
- past_transfer gives: `Hpsi in u -> psi in v`
- We don't have `Hpsi in u`; we only have `psi in u`

**Semantic Truth vs Syntactic Derivability**: The semantic fact that `v` is at time x+y > 0 from `w` means `Gpsi in w` should imply `psi in v`. But the syntactic relation only captures endpoint properties, not path properties.

**Case: x < 0, y > 0, x + y > 0 (Future Transfer)**

```
Given:
- h_wu_past: x < 0 -> (Hpsi in w -> psi in u)
- h_uv_fut: y > 0 -> (Gpsi in u -> psi in v)
- h_uv_fut_pers: y >= 0 -> (Gpsi in u -> Gpsi in v)
- h_w_fut: w.models Gpsi

Goal: v.models psi
```

**Why This Fails**: We have `Gpsi in w` and need `psi in v`. But:
- From w to u (duration x < 0), only past_transfer applies
- We don't get `Gpsi in u` from `Gpsi in w` when going backward (x < 0)
- Future persistence only applies when x >= 0

### 2. Truth Lemma Gaps Analysis

The truth lemma has gaps in the "backward direction" of each connective case:

**Implication Case (Lines 1296, 1300)**

```
Goal: (psi -> chi true semantically) -> (psi -> chi) in state
```

This requires: If semantic implication holds, the syntactic implication formula is in the state. This is **negation-completeness**: for any formula, either it or its negation is in the state.

**Box Case (Lines 1328, 1338)**

```
Forward: box(psi) in state -> psi true at all histories
Backward: psi true at all histories -> box(psi) in state
```

The backward direction requires the **canonical property**: if psi holds semantically in all accessible worlds, then box(psi) must be in the state. This is part of negation-completeness.

**Temporal Cases (Lines 1360, 1382)**

Similar pattern: forward direction uses task relation transfer; backward direction requires negation-completeness.

### 3. IsLocallyConsistent Limitation

The current `IsLocallyConsistent` definition only captures **soundness** (forward direction):

```lean
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- Bot is false
  (∀ h : Formula.bot ∈ closure phi, v ⟨Formula.bot, h⟩ = false) ∧
  -- Implications are respected (soundness direction only)
  (∀ psi chi, h_imp : imp psi chi ∈ closure, h_psi : psi ∈ closure, h_chi : chi ∈ closure,
    v (imp psi chi) = true → v psi = true → v chi = true) ∧
  -- Modal T axiom, temporal reflexivity...
```

Missing: **Negation-completeness** and **implication-completeness**:

```lean
-- Needed for truth lemma backward directions:
(∀ psi h_psi : psi ∈ closure, v psi = true ∨ v (neg psi) = true)  -- if neg psi in closure
-- Or equivalently, implication completeness:
(∀ psi chi h_imp h_psi h_chi, v psi = false ∨ v chi = true → v (imp psi chi) = true)
```

### 4. Relationship to Task 464 Strategy A

Task 464 implemented Strategy A (strengthened `canonical_task_rel` with persistence conditions) for the infinite model in `Completeness.lean`. That work:

1. **Added G-persistence**: `d > 0 -> Gpsi in S -> Gpsi in T`
2. **Added H-persistence**: `d < 0 -> Hpsi in S -> Hpsi in T`
3. **Proved uniform-sign cases** (x > 0, y > 0 and x < 0, y < 0)
4. **Left mixed-sign cases** with sorry (same as current FiniteCanonicalModel)

The finite model (`FiniteCanonicalModel.lean`) already incorporates these persistence conditions in `finite_task_rel` (lines 725-733). The gaps are identical to the infinite model gaps.

### 5. Potential Solutions

#### Solution A: Accept Mixed-Sign Gaps as Documented Limitation

**Approach**: Document that compositionality holds for uniform-sign cases only, and note that mixed-sign cases require additional structure (path-based construction or Duration discreteness).

**Pros**:
- No additional implementation work
- Honest about current limitations
- Matches Task 464 conclusion

**Cons**:
- Compositionality is incomplete
- History construction remains problematic

#### Solution B: Add Negation-Completeness to IsLocallyConsistent

**Approach**: Extend `IsLocallyConsistent` to require negation-completeness:

```lean
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- ... existing conditions ...
  -- NEW: Negation-completeness (restricted to closure)
  (∀ psi : Formula,
    ∀ h_psi : psi ∈ closure phi,
    ∀ h_neg : psi.neg ∈ closure phi,
    v ⟨psi, h_psi⟩ = true ∨ v ⟨psi.neg, h_neg⟩ = true)
```

**Pros**:
- Enables truth lemma backward directions
- Matches `SetMaximalConsistent` property

**Cons**:
- Closure may not contain negations of all formulas
- Need to define `closureWithNeg` or extend closure
- More complex world state construction

#### Solution C: Bridge to SetMaximalConsistent

**Approach**: Use the already-proven properties of `SetMaximalConsistent` from `Completeness.lean` by showing `FiniteWorldState` world states correspond to restrictions of maximal consistent sets.

```lean
def worldStateFromMCS (phi : Formula) (S : SetMaximalConsistent) : FiniteWorldState phi :=
  ⟨fun ⟨psi, _⟩ => if psi ∈ S.val then true else false, ...⟩

theorem worldStateFromMCS_negation_complete (S : SetMaximalConsistent) (psi : Formula)
    (h_psi : psi ∈ closure phi) (h_neg : psi.neg ∈ closure phi) :
    (worldStateFromMCS phi S).satisfies psi h_psi ∨
    (worldStateFromMCS phi S).satisfies psi.neg h_neg := by
  -- Use set_mcs_negation_complete from Completeness.lean
  ...
```

**Pros**:
- Reuses existing proven infrastructure
- Negation-completeness automatic from MCS properties
- Clean separation of concerns

**Cons**:
- Requires showing consistency of the bridge
- May need Lindenbaum extension to create MCS from world states

#### Solution D: Strengthen Task Relation for Compositionality

**Approach**: Add "backward persistence" conditions that capture path information:

```lean
def finite_task_rel_strong (phi : Formula) (w : FiniteWorldState phi) (d : Int)
    (u : FiniteWorldState phi) : Prop :=
  -- ... existing conditions ...
  -- NEW: "Semantic" persistence that bridges mixed signs
  (d > 0 → ∀ psi, psi ∈ closure phi →
    (psi ∈ w.toSet → psi ∈ u.toSet ∨ psi.neg ∈ u.toSet))  -- psi remains decidable
```

**Cons**: This doesn't actually solve the problem; the issue is fundamentally about the relationship between syntactic membership and semantic truth.

### 6. Compositionality Gap Semantic Analysis

The mixed-sign compositionality gaps represent a **fundamental semantic-syntactic gap**:

**Semantic Level**:
- If `v` is at time `x+y > 0` from `w`, and `Gpsi ∈ w`, then `psi` must hold at `v`
- This is because `x+y > 0` means `v` is strictly after `w`

**Syntactic Level**:
- The task relation `finite_task_rel` only captures **endpoint** properties
- Going through intermediate state `u` loses information about the **total displacement**
- When `x > 0` and `y < 0`, the intermediate state `u` is "further in the future" than `v`, but we can't recover `psi` at `v` from `psi` at `u`

**Why Persistence Doesn't Help**: Even with `Gpsi ∈ w → Gpsi ∈ u` (persistence), we need `Gpsi ∈ u → psi ∈ v` when going backward. But backward transfer gives `Hpsi ∈ u → psi ∈ v`, not `Gpsi ∈ u → psi ∈ v`.

### 7. Truth Lemma Gap Detailed Analysis

**Implication Case - Backward Direction**:
```
Hypothesis: h_impl : finite_truth_at phi h t psi → finite_truth_at phi h t chi
Goal: (h.states t).models (imp psi chi) h_imp
```

The proof splits on whether `psi` is syntactically true:
- If `psi` true: By `h_impl`, `chi` is semantically true, hence syntactically true by IH.
  Then need: `psi` true AND `chi` true implies `imp psi chi` true.
  This is NOT automatic from `IsLocallyConsistent`!

- If `psi` false: Need `imp psi chi` true (vacuously).
  This requires: NOT(psi) implies (imp psi chi).
  This is implication-completeness / negation-completeness.

**Box Case - Backward Direction**:
```
Hypothesis: h_all : ∀ h', finite_truth_at phi h' t psi
Goal: (h.states t).models (box psi) h_box
```

Even if `psi` is true at all histories at time `t`, we need `box psi` to be in the world state. This requires the canonical property: if something is true everywhere, the box formula is in the state. This is negation-completeness for `box psi`.

## Decisions

1. **Primary Recommendation**: Solution C (Bridge to SetMaximalConsistent)
   - Most principled approach
   - Reuses proven infrastructure
   - Cleanly separates finite model structure from MCS properties

2. **Fallback**: Solution A (Accept as documented limitation)
   - If bridging is too complex
   - Document that truth lemma requires additional infrastructure

3. **For Compositionality**: Accept mixed-sign gaps remain
   - These are fundamental to pointwise transfer approach
   - Require either Duration discreteness or path-based construction
   - Match the gaps in the infinite model (Task 464)

## Recommendations

### Immediate Actions

1. **Add closureWithNeg**: Extend closure to include negations for negation-completeness

2. **Strengthen IsLocallyConsistent**: Add negation-completeness condition for formulas whose negation is in closure

3. **Bridge to MCS**: Create `worldStateFromMCS` function and prove it preserves all MCS properties restricted to closure

### Implementation Strategy

**Phase 1: Extend Closure** (2 hours)
- Define `closureWithNeg` that includes negations
- Prove closure properties for extended closure
- Update `FiniteTruthAssignment` to use extended closure

**Phase 2: Strengthen World States** (3 hours)
- Add negation-completeness to `IsLocallyConsistent`
- Update world state construction to ensure negation-completeness
- Prove `FiniteWorldState.ext` still works

**Phase 3: Complete Truth Lemma** (4 hours)
- Use negation-completeness to prove backward directions
- Implication case: use implication-completeness
- Box case: use negation-completeness for `box psi`
- Temporal cases: similar pattern

**Phase 4: Compositionality (Optional)** (3 hours)
- Document mixed-sign gaps as limitations
- Or implement path-based construction if time permits

### Alternative Path: Minimal Fix

If full solution is too time-consuming:

1. **Accept compositionality gaps** (documented in Phase 3 comments already)
2. **For truth lemma**: Require Lindenbaum for finite closures (separate Task 472)
3. **Mark existence lemmas** as depending on Lindenbaum (already axioms)

This path acknowledges that full completeness proof requires infrastructure from Task 472 (Lindenbaum extension for finite closures).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure extension breaks existing proofs | Medium | Medium | Keep original closure, use extended only where needed |
| Negation-completeness hard to prove for constructed states | High | Medium | Bridge to MCS avoids this |
| Compositionality gaps fundamentally unfixable | Medium | Low | Accept as limitation, document approach |
| Implementation complexity exceeds estimate | Medium | Medium | Fallback to minimal fix path |

## Appendix

### Key Code Locations

| Component | Lines | Status |
|-----------|-------|--------|
| IsLocallyConsistent | 413-441 | Needs negation-completeness |
| finite_task_rel | 705-733 | Persistence conditions present |
| compositionality | 773-877 | 7 sorry gaps |
| finite_truth_lemma | 1241-1382 | 8 sorry gaps |
| finite_history_from_state | 1119-1134 | 2 sorry gaps |

### Relevant Theorems from Completeness.lean

| Theorem | Purpose |
|---------|---------|
| set_mcs_negation_complete | Every MCS has psi or neg(psi) |
| set_mcs_implication_property | Implication completeness |
| set_mcs_all_future_all_future | G-4: Gpsi -> GGpsi |
| set_mcs_all_past_all_past | H-4: Hpsi -> HHpsi |
| future_formula_persistence | Gpsi persists forward |
| past_formula_persistence | Hpsi persists backward |

### Mathlib Theorems

| Theorem | Use |
|---------|-----|
| FirstOrder.Language.Theory.IsMaximal | Analogous negation-completeness |
| FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem | Pattern for our proof |

## Next Steps

1. Run `/plan 473` to create implementation plan based on these recommendations
2. Consider dependency on Task 472 (Lindenbaum for finite closures)
3. Coordinate with Task 449 (truth lemma work in progress)
