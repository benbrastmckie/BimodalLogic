# Implementation Plan: Task 67 - Extend deferralClosure with Seriality Formulas

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [PARTIAL]
- **Effort**: 8-12 hours
- **Dependencies**: None (builds on existing sorry-free infrastructure)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/10_team-research.md
- **Artifacts**: plans/05_extend-deferral-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Previous Plans**: 04_bypass-z-chain-plan.md (Phase 1 blocked on F_top not in deferralClosure)

## Overview

This plan implements the resolution identified by team research: extend `deferralClosure` to always include seriality formulas `{F_top, P_top, neg bot}`. The blocker from Plan 04 was that `F_top = F(neg bot)` is not in `deferralClosure(phi)` for general phi, making `DeferralRestrictedSerialMCS` construction impossible. By extending the closure definition, F_top and P_top become automatically available in any DeferralRestrictedMCS, enabling the chain construction to proceed.

### Research Integration

From report 10_team-research.md:
- **Root cause confirmed**: `DeferralRestrictedSerialMCS` requires F_top in deferralClosure, but `some_future_in_deferralClosure_is_in_closureWithNeg` proves F-formulas in deferralClosure must be in closureWithNeg
- **Resolution**: Extend deferralClosure with `{F_top, P_top, neg bot}` (seriality formulas)
- **Downstream impact**: ~16 call sites need updates for F_top/P_top special-casing
- **Mathematical justification**: Standard textbook completeness proofs include seriality formulas in the closure

## Goals & Non-Goals

**Goals**:
- Extend `deferralClosure` definition to include `{F_top, P_top, neg bot}`
- Update `some_future_in_deferralClosure_is_in_closureWithNeg` theorem statement
- Fix all downstream call sites (~16 total across 3 files)
- Prove `DeferralRestrictedSerialMCS` construction for any phi
- Eliminate sorry in `bundle_validity_implies_provability`

**Non-Goals**:
- Proving Z_chain_forward_F (bypassed by restricted coherence approach)
- Full family-level temporal coherence (same-chain suffices)
- Dense completeness (separate concern, Rat canonical model)
- Restructuring the overall proof architecture

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-nesting depth bound affected by F_top (depth 1) | Medium | Low | Termination uses B^2 fuel, depth 1 adds at most 1, still bounded |
| Negation completeness needs neg F_top, neg P_top | Medium | Medium | Add to extended closure if needed; analyze DRM negation arguments |
| Many call sites need coordinated changes | Medium | High | Phase 2 is dedicated to fixing all call sites systematically |
| Truth lemma compatibility | Medium | Low | Extended closure is superset; existing proofs remain valid |

## Implementation Phases

### Phase 1: Define Extended Deferral Closure [COMPLETED]

**Goal**: Create `extendedDeferralClosure` or modify `deferralClosure` to include seriality formulas

**Tasks**:
- [ ] Define `serialityFormulas : Finset Formula := {F_top, P_top, Formula.neg Formula.bot}`
- [ ] Define `extendedDeferralClosure phi := deferralClosure phi ∪ serialityFormulas`
  - Alternative: modify existing `deferralClosure` definition inline
- [ ] Prove `deferralClosure_subset_extendedDeferralClosure`
- [ ] Prove `F_top_mem_extendedDeferralClosure` for any phi
- [ ] Prove `P_top_mem_extendedDeferralClosure` for any phi
- [ ] Prove `neg_bot_mem_extendedDeferralClosure` for any phi
- [ ] Update `max_F_depth_deferralClosure_eq` for extended closure (F_top has depth 1)
- [ ] Verify the extended closure is still finite (`extendedDeferralClosure phi : Finset Formula`)

**Design decision**: Whether to modify `deferralClosure` in place or create a new `extendedDeferralClosure`:
- **In-place modification**: Cleaner but more downstream changes
- **New definition**: Preserves existing code but requires switching call sites

Recommendation: Modify `deferralClosure` in place (add union with serialityFormulas).

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` (lines ~649-660)

**Timing**: 1.5-2 hours

**Verification**:
- `lake build Bimodal.Syntax.SubformulaClosure` passes
- `F_top_mem_deferralClosure` theorem exists and is sorry-free

---

### Phase 2: Update F/P in deferralClosure Theorems [COMPLETED]

**Goal**: Update `some_future_in_deferralClosure_is_in_closureWithNeg` and related theorems to handle F_top as special case

**Tasks**:
- [ ] Analyze current theorem (SubformulaClosure.lean:919):
  ```lean
  theorem some_future_in_deferralClosure_is_in_closureWithNeg (phi chi : Formula)
      (h : Formula.some_future chi ∈ deferralClosure phi) :
      Formula.some_future chi ∈ closureWithNeg phi
  ```
- [ ] New statement must handle two cases:
  - If `F(chi) = F_top`, chi = neg bot is in extended closure directly
  - Otherwise, existing proof applies (F(chi) in closureWithNeg)
- [ ] Option A: Split into two theorems:
  ```lean
  theorem F_in_deferralClosure_cases (phi chi : Formula)
      (h : Formula.some_future chi ∈ deferralClosure phi) :
      Formula.some_future chi ∈ closureWithNeg phi ∨ Formula.some_future chi = F_top
  ```
- [ ] Option B: Weaker conclusion sufficient for downstream:
  ```lean
  theorem F_inner_in_deferralClosure (phi chi : Formula)
      (h : Formula.some_future chi ∈ deferralClosure phi) :
      chi ∈ deferralClosure phi
  ```
- [ ] Update symmetric theorem `some_past_in_deferralClosure_is_in_closureWithNeg` similarly
- [ ] Add helper: `neg_bot_mem_deferralClosure`

**Analysis of downstream usage pattern** (from grep):
```
F(chi) ∈ deferralClosure →
  some_future_in_deferralClosure_is_in_closureWithNeg →
  F(chi) ∈ closureWithNeg →
  some_future_in_closureWithNeg_inner_in_subformulaClosure →
  chi ∈ subformulaClosure →
  chi ∈ deferralClosure
```

The key need is: `F(chi) ∈ deferralClosure → chi ∈ deferralClosure`. For F_top, chi = neg bot, which IS in extended closure.

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` (lines ~919-970)

**Timing**: 2-3 hours

**Verification**:
- Updated theorems compile without sorry
- `lake build Bimodal.Syntax.SubformulaClosure` passes

---

### Phase 3: Fix SuccChainFMCS.lean Call Sites [COMPLETED]

**Goal**: Update all 9 call sites of `some_future_in_deferralClosure_is_in_closureWithNeg` in SuccChainFMCS.lean

**Call sites identified** (line numbers from grep):
1. Line 1020: `deferralDisjunctionSet_subset_deferralClosure_ext`
2. Line 1244: F-formula deferral disjunction membership
3. Line 1493: G(neg psi) subformula extraction
4. Line 1568: Similar G(neg psi) extraction
5. Line 1868: F(psi) inner in subformula
6. Line 2098: psi in deferralClosure from F(psi)
7. Line 2423: F_top inner (neg bot) in deferralClosure - **CRITICAL**
8. Line 3145: F(chi) inner extraction
9. Line 3782: chi in deferralClosure from F(chi)

**Tasks**:
- [ ] For each call site, determine if F_top can occur:
  - Call sites handling general F(chi): need branching for F_top case
  - Call sites where F(chi) comes from closureWithNeg: existing proof still applies
- [ ] Line 2423 (`F_top_in_restricted_successor`): This is the CRITICAL fix
  - Currently tries to derive neg bot ∈ subformulaClosure from F_top ∈ closureWithNeg
  - After extension: neg bot ∈ deferralClosure directly (by definition)
- [ ] For other call sites: Add `Or.elim` with F_top case using new helper lemmas
- [ ] Update symmetric P_top call sites (lines 1040, 3305, 3578, 3854)

**Pattern for fixes**:
```lean
-- Old pattern:
have h_F_in_cwn := some_future_in_deferralClosure_is_in_closureWithNeg phi chi h_F_in_dc
have h_chi_in_sub := some_future_in_closureWithNeg_inner_in_subformulaClosure phi chi h_F_in_cwn
have h_chi_in_dc := closureWithNeg_subset_deferralClosure phi (subformulaClosure_subset_closureWithNeg phi h_chi_in_sub)

-- New pattern:
have h_chi_in_dc := F_inner_in_deferralClosure phi chi h_F_in_dc
-- Direct: chi ∈ deferralClosure (handles both F_top and non-F_top cases)
```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (~13 call sites)

**Timing**: 3-4 hours

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` passes
- No new sorries introduced

---

### Phase 4: Fix SuccExistence.lean and RestrictedMCS.lean [COMPLETED]

**Goal**: Update remaining call sites in other files

**Call sites**:
- `SuccExistence.lean:316`: F(chi) inner extraction
- `SuccExistence.lean:232`: P(chi) inner extraction
- `RestrictedMCS.lean:961`: P(psi) inner extraction

**Tasks**:
- [ ] Apply same pattern as Phase 3 to these 3 call sites
- [ ] Verify existing proofs in these files still work
- [ ] Check for any additional theorem dependencies

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`

**Timing**: 1-1.5 hours

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccExistence` passes
- `lake build Bimodal.Metalogic.Core.RestrictedMCS` passes

---

### Phase 5: DeferralRestrictedSerialMCS Construction [COMPLETED]
<!-- Phase 5 confirmed complete: build_restricted_serial_mcs_from_neg_consistent is sorry-free -->

**Goal**: Prove that any consistent neg(phi) extends to DeferralRestrictedSerialMCS

**Tasks**:
- [ ] With extended closure, prove:
  ```lean
  theorem build_restricted_serial_mcs_from_neg_consistent (phi : Formula)
      (h_cons : SetConsistent {phi.neg}) :
      ∃ M : DeferralRestrictedSerialMCS phi, phi.neg ∈ M.world
  ```
- [ ] Use `deferral_restricted_lindenbaum` to extend {neg phi} to DRM
- [ ] F_top ∈ DRM by `F_top_mem_deferralClosure` + theorem property
- [ ] P_top ∈ DRM similarly
- [ ] Package as DeferralRestrictedSerialMCS

**Key insight**: With extended closure:
- F_top ∈ deferralClosure phi (by definition of extended closure)
- F_top is a theorem, so it's in any maximal consistent subset of deferralClosure
- Therefore F_top ∈ DeferralRestrictedMCS

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (new theorem)

**Timing**: 1-1.5 hours

**Verification**:
- `build_restricted_serial_mcs_from_neg_consistent` compiles without sorry

---

### Phase 6: Complete bundle_validity_implies_provability [PARTIAL]

**Goal**: Eliminate the sorry in the main theorem

**Tasks**:
- [ ] Apply Phase 5 construction to get DeferralRestrictedSerialMCS with neg(phi)
- [ ] Use `build_restricted_tc_family` to get RestrictedTemporallyCoherentFamily
- [ ] Build TaskModel from restricted chain
- [ ] Apply restricted truth lemma at position 0
- [ ] Show neg(phi) TRUE at (model, 0)
- [ ] Derive contradiction with validity hypothesis
- [ ] Remove sorry, complete by_contra proof

**Proof sketch**:
```lean
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ) := by
  by_contra h_not_prov
  push_neg at h_not_prov
  -- Step 1: neg(φ) is consistent
  have h_neg_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 2: Build DeferralRestrictedSerialMCS with neg(φ) [Phase 5]
  obtain ⟨seed, h_neg_in_seed⟩ := build_restricted_serial_mcs_from_neg_consistent φ h_neg_cons
  -- Step 3: Build RestrictedTemporallyCoherentFamily [existing]
  let fam := build_restricted_tc_family φ seed
  -- Step 4: Build TaskModel from restricted chain
  let model := restricted_canonical_model fam
  -- Step 5: neg(φ) is TRUE at (model, 0) via truth lemma
  have h_neg_true := (restricted_truth_lemma_at_zero φ fam φ.neg h_neg_sub).mp h_neg_in_seed
  -- Step 6: φ is TRUE at (model, 0) by validity
  have h_phi_true := h_valid model 0
  -- Step 7: Contradiction
  exact truth_neg_contra h_phi_true h_neg_true
```

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` (line 176)

**Timing**: 1.5-2 hours

**Verification**:
- `bundle_validity_implies_provability` compiles without sorry
- `#print axioms bundle_validity_implies_provability` shows no `sorryAx`

---

### Phase 7: Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification and documentation

**Tasks**:
- [ ] Run `lake build` to verify complete build
- [ ] Verify: `grep sorry Theories/Bimodal/FrameConditions/Completeness.lean`
  - Should only show `dense_completeness_fc` (separate concern)
- [ ] Run: `#print axioms completeness_over_Int`
- [ ] Update docstrings in modified files
- [ ] Remove any dead code from previous attempts
- [ ] Create implementation summary

**Files to modify**:
- Various documentation updates

**Timing**: 1 hour

**Verification**:
- Full `lake build` passes
- Axiom check shows no sorryAx in completeness theorems

---

## Testing & Validation

- [ ] Phase 1: `F_top_mem_deferralClosure` compiles
- [ ] Phase 2: Updated theorems handle F_top case
- [ ] Phase 3: SuccChainFMCS.lean builds without errors
- [ ] Phase 4: SuccExistence.lean and RestrictedMCS.lean build
- [ ] Phase 5: `build_restricted_serial_mcs_from_neg_consistent` compiles
- [ ] Phase 6: `bundle_validity_implies_provability` sorry-free
- [ ] Phase 7: `#print axioms bundle_validity_implies_provability` shows no sorryAx

## Artifacts & Outputs

- `plans/05_extend-deferral-closure.md` (this file)
- Modified: `Theories/Bimodal/Syntax/SubformulaClosure.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
- Modified: `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- `summaries/05_completeness-final-summary.md` (post-implementation)

## Rollback/Contingency

If implementation fails:
1. `git checkout HEAD -- Theories/Bimodal/` to restore original state
2. Document failure point in errors.json
3. If Phase 1 fails: verify Finset union semantics for serialityFormulas
4. If Phase 2 fails: consider weaker theorem statement that still supports downstream
5. If Phases 3-4 fail: may need individual case analysis at each call site
6. If Phase 5 fails: verify theorem_in_drm applies for F_top after closure extension
7. If Phase 6 fails: verify truth lemma compatibility with extended closure

## Technical Notes

### Why Extended Closure Is Mathematically Sound

Standard textbook completeness proofs for temporal logic (Blackburn, de Rijke, Venema) include seriality formulas in the Fischer-Ladner closure:
1. F_top = F(neg bot) and P_top = P(neg bot) are theorems (seriality axioms)
2. Any maximal consistent set contains all theorems
3. The closure must contain these for the chain construction to work
4. Our original omission was an oversight in formalizing the standard approach

### Impact on F-Nesting Depth

Adding F_top (depth 1) to the closure affects the depth bound:
- `max_F_depth_deferralClosure_eq` currently proves depth equals max over closureWithNeg
- With F_top, the max becomes `max(max_over_closureWithNeg, 1)`
- For most phi, this is unchanged (any F-formula in phi already has depth >= 1)
- The termination argument uses B^2 fuel which handles depth + 1

### Call Site Classification

| Call Site Pattern | Count | Fix Strategy |
|-------------------|-------|--------------|
| Extract chi from F(chi) for membership | 6 | New direct theorem |
| Extract G(neg chi) as subformula | 2 | Existing + F_top branch |
| Deferral disjunction membership | 2 | Existing proof + extension |
| F_top/P_top propagation | 2 | Directly in closure |
| P variants | 4 | Symmetric to F fixes |

### Comparison with Plan 04

| Plan 04 Status | Plan 05 Approach |
|----------------|------------------|
| Phase 1: BLOCKED (F_top not in closure) | Phase 1: Define extended closure with F_top |
| Tried: prove F_top ∈ deferralClosure | Solution: Make F_top ∈ deferralClosure by definition |
| Fundamental gap in current definitions | Addresses root cause at definition level |
