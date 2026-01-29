# Implementation Plan: Task #753 (Revised)

- **Task**: 753 - Prove sorries in CoherentConstruction for standard completeness
- **Status**: [NOT STARTED]
- **Version**: 002 (revised from 001)
- **Effort**: 12-18 hours
- **Priority**: medium
- **Dependencies**: None (overlaps with 749, 750, 755 but independently achievable)
- **Research Inputs**: specs/753_prove_sorries_in_coherentconstruction/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Context

Version 001 had 11 phases targeting zero sorries across all of Metalogic/. After partial implementation:

**Completed (already sorry-free):**
- Phase 2: UniversalCanonicalModel - files already clean
- Phase 4: CanonicalWorld - files already clean
- Phase 5: CanonicalHistory - files already clean

**Blocked:**
- Phase 1: CoherentConstruction infrastructure sorries - circular dependency in definition
- Phase 3: IndexedMCSFamily - unused in main theorem path
- Phase 6: TaskRelation - complex case analysis
- Phases 7-10: Depend on architectural decisions being made in tasks 749/750/755

**Revision Strategy:**
This revised plan focuses on what task 753 can uniquely accomplish:
1. Infrastructure sorries via refactored chain construction
2. TaskRelation compositionality (self-contained)
3. Cross-origin coherence cases (optional but achievable)

The TruthLemma and FMP sorries are handled by tasks 749/750/755 with different approaches.

## Goals & Non-Goals

**Goals**:
- Zero sorries in `CoherentConstruction.lean`
- Zero sorries in `TaskRelation.lean`
- Maintain backward compatibility

**Non-Goals** (handled by other tasks):
- TruthLemma backward sorries (Task 750/755)
- FMP/SemanticCanonicalModel sorries (Task 749)
- WeakCompleteness soundness sorry (Boneyard migration)
- AlgebraicSemanticBridge sorries (separate effort)
- IndexedMCSFamily sorries (unused code)

## Implementation Phases

### Phase 1: CoherentConstruction Chain Refactoring [NOT STARTED]

**Goal**: Prove the 2 infrastructure sorries by refactoring chain construction to carry invariant.

**Problem Analysis**:
The current definition creates a circular dependency:
```lean
def mcs_forward_chain ... : Nat -> Set Formula
  | n+1 => extendToMCS (forward_seed prev) (by sorry)  -- needs no_G_bot for prev
```
The sorry needs `no_G_bot (mcs_forward_chain n)`, but `mcs_forward_chain_is_mcs` which would prove this is defined AFTER the definition.

**Solution**: Refactor to use sigma-type carrying the invariant:

```lean
noncomputable def mcs_forward_chain_aux (Gamma : Set Formula)
    (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) :
    (n : Nat) → { S : Set Formula // SetMaximalConsistent S ∧ Formula.all_future Formula.bot ∉ S }
  | 0 => ⟨Gamma, h_mcs, h_no_G_bot⟩
  | n+1 =>
    let ⟨S, h_S_mcs, h_S_no_G_bot⟩ := mcs_forward_chain_aux Gamma h_mcs h_no_G_bot n
    let h_seed_cons := forward_seed_consistent_of_no_G_bot S h_S_mcs h_S_no_G_bot
    let T := extendToMCS (forward_seed S) h_seed_cons
    let h_T_mcs := extendToMCS_is_mcs _ h_seed_cons
    let h_T_no_G_bot : Formula.all_future Formula.bot ∉ T := by
      intro h_G_bot_in_T
      -- Use forward_G_persistence to trace back to Gamma
      have : Formula.all_future Formula.bot ∈ S := forward_G_persistence S T _ h_G_bot_in_T
      exact absurd this h_S_no_G_bot
    ⟨T, h_T_mcs, h_T_no_G_bot⟩

noncomputable def mcs_forward_chain (Gamma : Set Formula)
    (h_mcs : SetMaximalConsistent Gamma)
    (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : Nat) : Set Formula :=
  (mcs_forward_chain_aux Gamma h_mcs h_no_G_bot n).val
```

**Tasks**:
- [x] Analyze circular dependency structure
- [ ] Create `mcs_forward_chain_aux` with sigma-type return
- [ ] Prove `h_T_no_G_bot` using `forward_G_persistence`
- [ ] Define `mcs_forward_chain` as projection
- [ ] Prove `mcs_forward_chain_is_mcs` from aux
- [ ] Create symmetric `mcs_backward_chain_aux` for H-bot
- [ ] Update dependent lemmas to use new definitions
- [ ] Verify `lake build` succeeds

**Key lemma needed**: `forward_G_persistence` must support the argument that G-bot in MCS extension implies G-bot in seed, which implies G-bot in previous MCS. Check if this exists or needs to be proven.

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- `lake build` passes
- Lines 403, 416 no longer contain sorry

---

### Phase 2: TaskRelation Compositionality [NOT STARTED]

**Goal**: Prove the 5 sorries in `canonical_task_rel_comp`.

**Problem Analysis**:
The compositionality property states: if `task_rel w d1 w'` and `task_rel w' d2 w''`, then `task_rel w (d1+d2) w''`.

The sorries arise from case analysis on signs of d1, d2, d1+d2:
- Line 151: MCS equality when both paths lead to same destination
- Lines 164, 168: Forward/backward propagation for positive composite duration
- Lines 174, 177: Forward/backward propagation for negative composite duration

**Solution Strategy**:
1. For MCS equality (line 151): The coherent construction ensures unique MCS at each index. Use `mcs_forward_chain_eq` or similar uniqueness lemmas.
2. For propagation: Track formula membership through the chain construction, using coherence lemmas.

**Tasks**:
- [ ] Analyze `canonical_task_rel_comp` structure at line 140+
- [ ] Identify which uniqueness/coherence lemmas exist
- [ ] Prove case: d1 >= 0, d2 >= 0 (forward composition)
- [ ] Prove case: d1 < 0, d2 < 0 (backward composition)
- [ ] Prove case: mixed signs (cross-origin composition)
- [ ] Verify all 5 sorries eliminated

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`

**Verification**:
- `lake build` passes
- Lines 151, 164, 168, 174, 177 no longer contain sorry

---

### Phase 3: CoherentConstruction Coherence Cases [NOT STARTED]

**Goal**: Prove the 8 coherence case sorries (cross-origin and cross-modal).

**Problem Analysis**:
These sorries are in the coherence proofs for the constructed family. Per file documentation, only some are exercised by completeness, but all are needed for full sorry-free status:

| Line | Case | Description |
|------|------|-------------|
| 654 | forward_G Case 3 | t < 0, t' >= 0 (cross-origin) |
| 657 | forward_G Case 4 | Both < 0 toward origin |
| 665 | backward_H Case 1 | Both >= 0 |
| 668 | backward_H Case 2 | t >= 0, t' < 0 (cross-origin) |
| 686 | forward_H Case 1 | Both >= 0 |
| 693 | forward_H Case 3 | t < 0, t' >= 0 (cross-origin) |
| 741 | backward_G Case 3 | t' < 0, t >= 0 (cross-origin) |
| 744 | backward_G Case 4 | Both < 0 |

**Solution Strategy**:
These require proving that G/H-formulas propagate correctly across the origin (between forward and backward chains). The key is that both chains share Gamma as their base:

```
... ← mcs_backward_chain(2) ← mcs_backward_chain(1) ← Gamma → mcs_forward_chain(1) → mcs_forward_chain(2) → ...
```

For cross-origin cases:
- If G phi ∈ mcs_backward_chain(n), need phi ∈ mcs_backward_chain(n+1) or trace through Gamma
- This requires showing the G/H-formula structure respects the chain topology

**Tasks**:
- [ ] Prove helper lemma: G-formulas in backward chain trace forward through Gamma
- [ ] Prove helper lemma: H-formulas in forward chain trace backward through Gamma
- [ ] Complete forward_G Cases 3-4 using cross-origin bridge
- [ ] Complete backward_H Cases 1-2 using cross-origin bridge
- [ ] Complete forward_H Cases 1, 3 using cross-origin bridge
- [ ] Complete backward_G Cases 3-4 using cross-origin bridge
- [ ] Verify all 8 coherence case sorries eliminated

**Timing**: 6-8 hours (most complex phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- `lake build` passes
- Lines 654, 657, 665, 668, 686, 693, 741, 744 no longer contain sorry
- `grep "sorry" CoherentConstruction.lean` returns empty (code only)

---

### Phase 4: Final Verification [NOT STARTED]

**Goal**: Verify target files are sorry-free.

**Tasks**:
- [ ] Run `lake build`
- [ ] Verify `grep "sorry" CoherentConstruction.lean` shows only comments
- [ ] Verify `grep "sorry" TaskRelation.lean` shows only comments
- [ ] Update file headers to document sorry-free status
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (header update)
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean` (header update)

**Verification**:
- `lake build` succeeds
- Target files contain no code-level sorries

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No new warnings introduced
- [ ] All existing theorem signatures preserved
- [ ] Dependent lemmas still compile

## Artifacts & Outputs

- Modified Lean files: CoherentConstruction.lean, TaskRelation.lean
- Implementation summary at `specs/753_prove_sorries_in_coherentconstruction/summaries/`

## Rollback/Contingency

If Phase 1 (chain refactoring) proves infeasible:
1. Document the circular dependency as architectural limitation
2. Consider alternative construction (e.g., well-founded recursion)
3. Mark infrastructure sorries as "requires definition restructure"

If Phase 3 (coherence cases) proves too complex:
1. Focus on cases exercised by completeness (documented in file header)
2. Mark remaining cross-origin cases as "not on main theorem path"

## Sorry Inventory (This Task)

| File | Line(s) | Count | Phase |
|------|---------|-------|-------|
| CoherentConstruction.lean | 403, 416 | 2 | 1 |
| TaskRelation.lean | 151, 164, 168, 174, 177 | 5 | 2 |
| CoherentConstruction.lean | 654, 657, 665, 668, 686, 693, 741, 744 | 8 | 3 |
| **Total for Task 753** | | **15** | |

## Out of Scope (Other Tasks)

| File | Count | Handling Task |
|------|-------|---------------|
| TruthLemma.lean | 4 | Task 750/755 |
| IndexedMCSFamily.lean | 4 | Unused code - defer |
| SemanticCanonicalModel.lean | 2 | Task 749 |
| FiniteModelProperty.lean | 1 | Task 749 |
| WeakCompleteness.lean | 1 | Boneyard migration |
| AlgebraicSemanticBridge.lean | 8 | Separate effort |
