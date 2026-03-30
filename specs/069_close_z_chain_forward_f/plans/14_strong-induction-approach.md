# Implementation Plan: Close Z_chain_forward_F via Strong Induction Restructuring

- **Task**: 69 - close_z_chain_forward_f
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/069_close_z_chain_forward_f/reports/12_team-research.md
  - specs/069_close_z_chain_forward_f/reports/14_remaining-sorry-analysis.md
- **Artifacts**: plans/14_strong-induction-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Plan Version**: 14 (strong induction restructuring)
- **Lean Intent**: true

## Overview

**Critical Finding**: The previous approach (plan v13) attempted incremental fixes to a fundamentally flawed proof structure. The research report (14_remaining-sorry-analysis.md) identified that the 700+ line proof at lines 1384-2101 has an unsalvageable asymmetry: it handles `phi` extraction separately from F-formula extraction, which breaks in the `neg(G(phi))` branch.

**Solution**: Delete the existing proof and replace with an 80-120 line strong induction proof that extracts ALL formulas (including phi) uniformly into a disjunction.

### Key Insight from Research

When `neg(G(phi)) in M`:
- The implication `G(phi) -> G(neg psi)` is vacuously true
- Cannot derive `G(neg psi) in M` via modus ponens
- The entire case analysis falls apart

The fix: Don't treat `phi` specially. Include it in the disjunction accumulator from the start.

### Critical Path (Updated)

```
f_preserving_seed_consistent (lines 1384-2101 -> 80-120 lines)
  -> temporal_theory_witness_F_preserving (uses f_preserving_seed_consistent)
    -> omega_chain_F_preserving_forward construction
      -> omega_F_preserving_forward_F_resolution (CLOSED)
        -> Z_chain_forward_F
```

## Goals & Non-Goals

**Goals**:
- Delete current 700-line proof of `f_preserving_seed_consistent`
- Replace with 80-120 line strong induction proof
- Close downstream sorries (Z_chain_forward_F)

**Non-Goals**:
- Fixing the existing proof incrementally (research confirms this is unsalvageable)
- P-preserving backward chain (leave for future task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Disjunction accumulation harder than expected | Medium | Medium | Verify lemma signatures before starting |
| Missing helper lemmas | Medium | Low | Check Mathlib for countP manipulation |
| Final G-lift step fails | High | Low | Research confirms pattern works |

## Implementation Phases

### Phase 1: Setup and Helper Lemmas [NOT STARTED]

**Goal**: Add helper lemma for countP decrease on filter

**Analysis**: Need to prove that filtering out an element with property p decreases countP p.

**Tasks**:
- [ ] Add helper lemma near line 1370:
  ```lean
  private theorem countP_filter_remove_element_lt {α} [DecidableEq α]
      (p : α → Bool) (L : List α) (x : α) (hx : x ∈ L) (hp : p x) :
      List.countP p (L.filter (· ≠ x)) < List.countP p L
  ```
- [ ] Verify `Nat.strong_induction_on` signature
- [ ] Run `lake build`

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (near line 1370)

**Verification**:
- [ ] Helper lemma compiles
- [ ] No interference with existing code

---

### Phase 2: Delete Current Proof [NOT STARTED]

**Goal**: Remove the flawed 700-line proof structure

**Analysis**: Lines 1384-2101 contain the current proof with two unfixable sorries. Delete everything between the `theorem f_preserving_seed_consistent` signature and its sorry/end.

**Tasks**:
- [ ] Backup or note the signature:
  ```lean
  theorem f_preserving_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
      SetConsistent (f_preserving_seed M phi)
  ```
- [ ] Delete lines 1384-2101 (the proof body)
- [ ] Replace with `sorry` placeholder
- [ ] Run `lake build` to confirm clean deletion

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1384-2101)

**Verification**:
- [ ] File compiles with single sorry
- [ ] No cascading errors from deletion

---

### Phase 3: Implement Strong Induction Core [NOT STARTED]

**Goal**: Implement the main strong induction proof

**Analysis**: The proof uses strong induction on `countFUnresolved M phi L` where:
- `countFUnresolved` counts F-formulas in L that are NOT in `{phi} ∪ temporal_box_seed M`
- Base case (count = 0): all elements in `{phi} ∪ temporal_box_seed M`, use existing `temporal_theory_witness_consistent`
- Inductive case: extract one F(sigma), build disjunction, recurse

**Tasks**:
- [ ] Define count function:
  ```lean
  private def countFUnresolved (M : Set Formula) (phi : Formula) (L : List Formula) : Nat :=
    L.countP (fun x => x.is_some_future ∧ x ∈ F_unresolved_theory M ∧ x ≠ phi.some_future)
  ```
- [ ] Start proof with `Nat.strong_induction_on`
- [ ] Base case: when count = 0, elements are in temporal_box_seed or equal to phi
- [ ] Apply `temporal_theory_witness_consistent`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1384+)

**Verification**:
- [ ] Base case compiles
- [ ] Induction structure set up

---

### Phase 4: Inductive Case - F-Formula Extraction [NOT STARTED]

**Goal**: Complete the inductive case with disjunction accumulation

**Analysis**: For count > 0:
1. Find F(sigma) in L from F_unresolved_theory (not phi)
2. Filter to get `L_no_F := L.filter (· ≠ F(sigma))`
3. Use deduction theorem: `L ⊢ bot` → `L_no_F ⊢ neg(F(sigma))` → `L_no_F ⊢ G(neg sigma)`
4. Recurse with smaller count
5. Accumulate G(neg sigma) into disjunction

**Tasks**:
- [ ] Extract F(sigma) using `countP_pos` and `exists`
- [ ] Apply deduction theorem for F-extraction
- [ ] Show count decreases via `countP_filter_remove_element_lt`
- [ ] Recursively handle remaining
- [ ] Build final disjunction

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- [ ] Inductive case compiles
- [ ] Proof of count decrease works

---

### Phase 5: Final Contradiction via G-Lift [NOT STARTED]

**Goal**: Complete the proof with G-lift and MCS contradiction

**Analysis**: After extracting all F-formulas AND phi:
1. `L_final ⊆ temporal_box_seed M` (pure G-theorems)
2. `L_final ⊢ (G(neg sigma_1) ∨ ... ∨ G(neg sigma_k) ∨ neg(phi))`
3. G-lift: `G((G(neg sigma_1) ∨ ... ∨ G(neg sigma_k) ∨ neg(phi))) ∈ M`
4. Modal distribution: `G(G(neg sigma_1)) ∨ ... ∨ G(neg phi) ∈ M`
5. T-axiom: at least one `G(neg sigma_i) ∈ M` or `G(neg phi) ∈ M`
6. Contradiction with respective F-formula in M

**Key lemmas to use**:
- `G_lift_from_context` (line 1066)
- `G_of_disjunction_in_mcs_elim` (line 1255)
- `some_future_excludes_all_future_neg` (line 1090)

**Tasks**:
- [ ] Apply `G_lift_from_context` to get `G(disjunction) ∈ M`
- [ ] Apply modal distribution (may need helper)
- [ ] Use `G_of_disjunction_in_mcs_elim` to get witness
- [ ] Apply `some_future_excludes_all_future_neg` for contradiction
- [ ] Close the proof

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Verification**:
- [ ] `f_preserving_seed_consistent` has no sorry
- [ ] `lake build` succeeds
- [ ] Downstream `temporal_theory_witness_F_preserving` compiles

---

### Phase 6: Verify Downstream and Continue Z_chain [NOT STARTED]

**Goal**: Verify downstream sorries close and continue with Z_chain phases

**Analysis**: With `f_preserving_seed_consistent` closed:
1. `temporal_theory_witness_F_preserving` should compile
2. `omega_chain_F_preserving_forward` construction works
3. Can proceed to Z_chain redefinition (plan v13 phases 2-6)

**Tasks**:
- [ ] Verify `temporal_theory_witness_F_preserving` compiles
- [ ] Count remaining sorries in file
- [ ] If < 5 sorries, proceed to Z_chain redefinition
- [ ] Otherwise, document remaining gaps

**Timing**: 0.25 hours

**Files to modify**:
- None (verification only)

**Verification**:
- [ ] Sorry count decreased
- [ ] Full `lake build` succeeds
- [ ] Clear path to Z_chain phases

---

## Continuation Plan

If Phase 6 succeeds with f_preserving_seed_consistent closed, continue with plan v13 phases 2-6:
- Phase 2: Add omega_chain_F_preserving_forward_G_monotone
- Phase 3: Redefine Z_chain for Forward Direction
- Phase 4: Update Z_chain Property Lemmas
- Phase 5: Close Z_chain_forward_F Sorries
- Phase 6: Verify Downstream and Document Gaps

## Testing & Validation

- [ ] After Phase 1: helper lemma compiles
- [ ] After Phase 2: clean deletion, single sorry
- [ ] After Phase 5: `f_preserving_seed_consistent` fully proved
- [ ] After Phase 6: sorry count report, downstream status

## Key Code References

| Location | Description |
|----------|-------------|
| Line 1066 | `G_lift_from_context` - lifts derivation under G-closure |
| Line 1090 | `some_future_excludes_all_future_neg` - F/G contradiction |
| Line 1255 | `G_of_disjunction_in_mcs_elim` - extracts witness |
| Line 1372 | `f_preserving_seed M phi` - the seed definition |
| Lines 1384-2101 | Current proof (to be deleted) |

## What NOT To Do

1. **Don't try to fix the existing proof incrementally** - research confirms it has fundamental structural issues
2. **Don't handle `phi` separately from F-formulas** - this is the root cause of the current failure
3. **Don't skip the disjunction accumulation** - direct contradiction doesn't work

## Rollback/Contingency

If the strong induction approach fails:
1. Revert to v13 plan with documented gaps
2. Consider weak coherence alternative
3. Mark `f_preserving_seed_consistent` as fundamental gap requiring new theory
