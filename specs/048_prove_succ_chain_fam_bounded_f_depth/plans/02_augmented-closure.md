# Implementation Plan: Task #48 (v2)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 47 (RestrictedMCS infrastructure - completed)
- **Research Inputs**: specs/048_prove_succ_chain_fam_bounded_f_depth/reports/02_team-research.md
- **Previous Plan**: plans/01_restricted-succ-chain.md (phases 1-2 partial, phases 3-4 blocked)
- **Artifacts**: plans/02_augmented-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the augmented deferral closure approach identified by team research. The decisive question "Is `chi ∨ F(chi) ∈ closureWithNeg(phi)` when `F(chi) ∈ closureWithNeg(phi)`?" has been resolved: **NO**. The closure only contains subformulas and their negations, not arbitrary disjunctions.

The solution is to define `deferralClosure(phi)` that extends `closureWithNeg(phi)` with the deferral disjunctions needed for the successor seed construction. This closure is still finite, and F/P-depth is still bounded.

### Research Integration

Key findings from `02_team-research.md`:
- Both teammates independently converged on the RestrictedMCS + augmented closure approach
- The deferral seed introduces `psi ∨ F(psi)` formulas NOT in `closureWithNeg(phi)`
- Solution: Define `deferralClosure(phi) = closureWithNeg(phi) ∪ {chi ∨ F(chi) | F(chi) ∈ closureWithNeg(phi)} ∪ {chi ∨ P(chi) | P(chi) ∈ closureWithNeg(phi)}`
- This set is finite, F-depth is bounded, and the deferral seed lies within it by construction

### What v1 Accomplished

From `01_restricted-succ-chain-summary.md`:
- Phase 1 (partial): Added `RestrictedSerialMCS` structure, P-nesting infrastructure
- Phase 2 (completed): Added provable `f_nesting_is_bounded_restricted`, `p_nesting_is_bounded_restricted`, deprecated old versions
- Phases 3-4: Not started (require augmented closure approach)

## Goals & Non-Goals

**Goals**:
- Define `deferralClosure` extending `closureWithNeg` with deferral disjunctions
- Prove `deferralClosure` is finite and has bounded F/P-depth
- Define restricted chain builders using `restricted_lindenbaum` over `deferralClosure`
- Thread RestrictedMCS through `succ_chain_fam` construction
- Update FMCS coherence proofs to use restricted versions
- Update completeness theorem to use restricted construction
- Remove all sorries related to F/P boundedness

**Non-Goals**:
- Changing the fundamental structure of the completeness proof
- Proving finite model property (not needed for this approach)
- Modifying the Succ relation definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `deferralClosure` finiteness proof complex | Medium | Low | Finset operations; closure is union of two finite sets |
| F-depth bounding for deferral disjunctions | Medium | Medium | `f_nesting_depth (chi ∨ F(chi)) = 0` (disjunction, not F-formula) |
| `restricted_lindenbaum` doesn't preserve F_top/P_top | High | Low | Prove explicitly; seed contains F_top from seriality |
| Constrained successor seed escapes `deferralClosure` | Medium | Medium | Include H(neg phi) formulas if needed (Task 50 concern) |
| Type mismatches during chain construction refactor | Medium | Medium | Define coercion functions and update incrementally |

## Implementation Phases

### Phase 0: Verify Closure Question and Analyze Deferral Seed [COMPLETED]

**Goal**: Confirm the closure question answer and understand exactly which formulas the deferral seed introduces.

**Tasks**:
- [ ] Read `SubformulaClosure.lean` definition of `closureWithNeg`
- [ ] Verify `chi ∨ F(chi)` is NOT a subformula when `F(chi)` is a subformula
- [ ] Read `SuccExistence.lean` `successor_deferral_seed` and `constrained_successor_seed`
- [ ] Document all formula sets that go into the seed:
  - `g_content(u)` - verified in closure via `closure_all_future`
  - `deferralDisjunctions(u)` - NOT in closure (the problem)
  - `p_step_blocking_formulas(u)` - check if `H(neg phi)` is in closure
- [ ] Determine if `H(neg phi)` escapes closure (Task 50 consideration)

**Timing**: 0.5 hours

**Files to examine**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - closure definition
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - deferral seed definition

**Verification**:
- Clear documentation of which formula sets escape `closureWithNeg`
- Decision on whether to include H-blocking formulas in `deferralClosure`

---

### Phase 1: Define Deferral Closure [COMPLETED]

**Goal**: Create `deferralClosure` type that extends `closureWithNeg` with deferral disjunctions.

**Tasks**:
- [ ] Define `deferralDisjunctionSet` in SubformulaClosure.lean:
  ```lean
  def deferralDisjunctionSet (phi : Formula) : Finset Formula :=
    -- {chi ∨ F(chi) | F(chi) ∈ closureWithNeg(phi)}
    (closureWithNeg phi).filterMap (fun f =>
      match extractFutureInner f with
      | some chi => some (Formula.or chi (Formula.some_future chi))
      | none => none)
  ```
- [ ] Define symmetric `backwardDeferralSet` for P-formulas:
  ```lean
  def backwardDeferralSet (phi : Formula) : Finset Formula :=
    -- {chi ∨ P(chi) | P(chi) ∈ closureWithNeg(phi)}
    (closureWithNeg phi).filterMap (fun f =>
      match extractPastInner f with
      | some chi => some (Formula.or chi (Formula.some_past chi))
      | none => none)
  ```
- [ ] Define `deferralClosure`:
  ```lean
  def deferralClosure (phi : Formula) : Finset Formula :=
    closureWithNeg phi ∪ deferralDisjunctionSet phi ∪ backwardDeferralSet phi
  ```
- [ ] Prove `closureWithNeg_subset_deferralClosure`
- [ ] Prove `deferralClosure_finite` (follows from Finset)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add deferral closure definitions

**Verification**:
- `lake build Bimodal.Syntax.SubformulaClosure` succeeds
- No sorries in new definitions

---

### Phase 2: Prove F/P-Depth Bounding for Deferral Closure [COMPLETED]

**Goal**: Prove that F/P-nesting depth is still bounded in `deferralClosure`.

**Tasks**:
- [ ] Prove `f_nesting_depth_disjunction`:
  ```lean
  theorem f_nesting_depth_disjunction (chi psi : Formula) :
      f_nesting_depth (Formula.or chi psi) = 0
  ```
  (Disjunction `Formula.or` is `imp (neg chi) psi`, not an F-formula pattern)
- [ ] Prove `f_depth_deferralDisjunction`:
  ```lean
  theorem f_depth_deferralDisjunction (chi : Formula) :
      f_nesting_depth (Formula.or chi (Formula.some_future chi)) = 0
  ```
- [ ] Define `max_F_depth_in_deferralClosure`:
  ```lean
  def max_F_depth_in_deferralClosure (phi : Formula) : Nat :=
    (deferralClosure phi).sup f_nesting_depth
  ```
- [ ] Prove `max_F_depth_deferral_eq_closure`:
  ```lean
  theorem max_F_depth_deferral_eq_closure (phi : Formula) :
      max_F_depth_in_deferralClosure phi = max_F_depth_in_closure phi
  ```
  (Deferral disjunctions have f_nesting_depth 0, don't increase max)
- [ ] Prove symmetric results for P-nesting depth

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add depth bounding proofs

**Verification**:
- `lake build` succeeds
- F/P depth bounds proven without sorries
- Key insight verified: deferral disjunctions don't increase max depth

---

### Phase 3: Define RestrictedMCS over Deferral Closure [COMPLETED]

**Goal**: Create `DeferralRestrictedMCS` type and prove restricted Lindenbaum produces it.

**Tasks**:
- [ ] Define `DeferralRestrictedMCS` in RestrictedMCS.lean:
  ```lean
  structure DeferralRestrictedMCS (phi : Formula) where
    world : Set Formula
    h_mcs : SetMaximalConsistent world
    h_subset : world ⊆ (deferralClosure phi : Set Formula)
  ```
- [ ] Prove `deferral_restricted_lindenbaum`:
  ```lean
  theorem deferral_restricted_lindenbaum (phi : Formula) (seed : Set Formula)
      (h_cons : SetConsistent seed) (h_subset : seed ⊆ (deferralClosure phi : Set Formula)) :
      ∃ M : Set Formula, SetMaximalConsistent M ∧ seed ⊆ M ∧ M ⊆ (deferralClosure phi : Set Formula)
  ```
  (Reuse `restricted_lindenbaum` with `deferralClosure` as the closure)
- [ ] Prove `deferral_mcs_F_bounded`:
  ```lean
  theorem deferral_mcs_F_bounded (phi : Formula) (M : DeferralRestrictedMCS phi)
      (psi : Formula) (h : Formula.some_future psi ∈ M.world) :
      ∃ n, n ≥ 2 ∧ iter_F n psi ∉ M.world
  ```
- [ ] Prove symmetric `deferral_mcs_P_bounded`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Add deferral-restricted types

**Verification**:
- `lake build` succeeds
- F/P boundedness proven for DeferralRestrictedMCS

---

### Phase 4: Define Restricted Chain Builders [PARTIAL]

**Goal**: Create forward/backward chain builders that produce `DeferralRestrictedMCS` elements.

**Tasks**:
- [ ] Prove `g_content_subset_deferralClosure`:
  ```lean
  theorem g_content_subset_deferralClosure (phi : Formula) (M : DeferralRestrictedMCS phi) :
      g_content M.world ⊆ (deferralClosure phi : Set Formula)
  ```
  (Uses `closure_all_future`: G(psi) subformula implies psi subformula)
- [ ] Prove `deferralDisjunctions_subset_deferralClosure`:
  ```lean
  theorem deferralDisjunctions_subset_deferralClosure (phi : Formula) (M : DeferralRestrictedMCS phi) :
      deferralDisjunctions M.world ⊆ (deferralClosure phi : Set Formula)
  ```
  (Key insight: if F(chi) ∈ M.world ⊆ deferralClosure phi, then chi ∨ F(chi) ∈ deferralClosure phi by construction)
- [ ] Prove `successor_deferral_seed_subset_deferralClosure`:
  ```lean
  theorem successor_deferral_seed_subset_deferralClosure (phi : Formula) (M : DeferralRestrictedMCS phi) :
      successor_deferral_seed M.world ⊆ (deferralClosure phi : Set Formula)
  ```
- [ ] Define `restricted_forward_chain`:
  ```lean
  def restricted_forward_chain (phi : Formula) (M0 : DeferralRestrictedMCS phi) :
      Nat → DeferralRestrictedMCS phi
  ```
  Uses `deferral_restricted_lindenbaum` to extend seed
- [ ] Prove `restricted_forward_chain_succ`: Each step satisfies Succ
- [ ] Define symmetric `restricted_backward_chain` for P-direction

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add restricted chain builders

**Verification**:
- `lake build` succeeds
- Chain elements proven to be DeferralRestrictedMCS
- Succ relation preserved through chain

---

### Phase 5: Update FMCS Coherence Proofs [NOT STARTED]

**Goal**: Update the succ_chain forward/backward coherence lemmas to use restricted versions.

**Tasks**:
- [ ] Define `restricted_succ_chain_fam`:
  ```lean
  def restricted_succ_chain_fam (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi) :
      Int → DeferralRestrictedMCS phi
  ```
  Combines restricted forward and backward chains
- [ ] Update `succ_chain_forward_F`:
  - Now takes `DeferralRestrictedSerialMCS`
  - Uses `deferral_mcs_F_bounded` for boundary
  - At usage site (line 836), pass closure through
- [ ] Update `succ_chain_forward_F_neg` similarly
- [ ] Update `succ_chain_backward_P`:
  - Uses `deferral_mcs_P_bounded` for boundary
  - At usage site (line 788), pass closure through
- [ ] Update `succ_chain_backward_P_neg` similarly
- [ ] Prove `restricted_succ_chain_fmcs_coherent`: FMCS conditions hold
- [ ] Define coercion from `restricted_succ_chain_fam` to `succ_chain_fam` for compatibility

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Update coherence proofs

**Verification**:
- `lake build` succeeds
- All 3 usage sites (lines 836, 788, 1103) updated
- No new sorries in coherence proofs

---

### Phase 6: Update Completeness Theorem [NOT STARTED]

**Goal**: Modify completeness proof to use restricted construction with target formula closure.

**Tasks**:
- [ ] Update `succ_chain_completeness`:
  - When starting from {neg phi}, build `DeferralRestrictedMCS phi`
  - Pass phi as closure parameter throughout
- [ ] Define `target_formula_deferral_lindenbaum`:
  ```lean
  theorem target_formula_deferral_lindenbaum (phi : Formula)
      (h_cons : SetConsistent {phi.neg}) :
      ∃ M : DeferralRestrictedMCS phi, phi.neg ∈ M.world
  ```
  (The target formula phi.neg is in closureWithNeg phi, hence in deferralClosure phi)
- [ ] Update SerialMCS construction to produce `DeferralRestrictedSerialMCS`
- [ ] Verify truth lemmas still apply (signatures may need minor updates)
- [ ] Remove or deprecate old unrestricted versions

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Update completeness proof

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness` succeeds
- Completeness theorem has no new sorries
- Total sorry count decreases by 2 (original f_nesting and p_nesting sorries)

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows 0 F/P boundedness sorries
- [ ] `grep -r "sorry" Theories/Bimodal/Syntax/SubformulaClosure.lean` shows no new sorries
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` shows no new sorries
- [ ] `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness` succeeds
- [ ] Total project sorry count decreases
- [ ] Documentation updated explaining deferral closure approach

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - deferralClosure definition and depth bounds
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - DeferralRestrictedMCS and F/P boundedness
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Restricted chain builders and FMCS
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Updated completeness proof
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/02_augmented-closure-summary.md` - Implementation summary

## Rollback/Contingency

If implementation proves more invasive than expected:

1. **Partial completion**: Mark task [PARTIAL] with phases completed, continue in new session
2. **Scope reduction**: If constrained seed (Task 50) complicates matters, implement basic deferral closure first without H-blocking, create follow-up task for constrained version
3. **Alternative**: If `deferralClosure` approach fails, consider frame-based argument using FMCS transfer from dovetailed model
4. **Blocking condition**: If restricted Lindenbaum cannot extend seeds while staying in closure, document precise failure and spawn theoretical investigation task

## Notes

- The key mathematical insight: deferral disjunctions `chi ∨ F(chi)` have f_nesting_depth 0 because they're disjunctions, not F-formulas. This means adding them to the closure doesn't increase the max F-depth bound.
- Task 50 adds `p_step_blocking_formulas` with `H(neg phi)` formulas. These need to be checked: if `H(neg phi)` escapes closure when `P(phi)` is a subformula, the deferral closure must include them too.
- The structure `DeferralRestrictedMCS` is separate from `RestrictedMCS` to clearly indicate the closure type used.
- Plan v1's `RestrictedSerialMCS` can be reused; we just need to parametrize the closure type.
