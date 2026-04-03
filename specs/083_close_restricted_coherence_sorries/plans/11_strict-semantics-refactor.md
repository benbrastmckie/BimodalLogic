# Implementation Plan: Strict Semantics Refactor for Task #83

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 66 hours
- **Dependencies**: None (clean-break refactor)
- **Research Inputs**: reports/11_strict-refactor-specification.md, reports/11_team-research.md, reports/10_team-research.md, reports/09_team-research.md
- **Artifacts**: plans/11_strict-semantics-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Complete clean-break refactor from reflexive (<=) to fully strict (<) temporal semantics for G, H, Until, and Since in the bimodal logic formalization. This refactor replaces the current reflexive quantification in `truth_at` with strict inequalities, removes the 2 invalid temporal T-axioms (G phi -> phi, H phi -> phi), replaces 6 Until/Since axioms with X/Y-based versions, adds 3 new axioms (temp_a_dual, disc_next, disc_prev), and propagates these changes through soundness, the algebraic layer, and canonical completeness. The backward truth lemma for Until is resolved via the contrapositive argument (forward truth lemma + MCS maximality), eliminating the need for an explicit X truth lemma. Net axiom count: 34 -> 33.

### Research Integration

- **Report 11 (strict refactor specification)**: Provides exact Lean 4 signatures, file-by-file change catalog, 67 T-axiom call sites, proof strategies for all new soundness theorems, and the contrapositive resolution for the backward Until truth lemma.
- **Report 11 (team research)**: Establishes that half-open semantics is mathematically impossible (unsound axiom), partial strict breaks F-U equivalence, and fully strict is the only correct path.
- **Report 10 (team research)**: IRR rules and axiom system analysis.
- **Report 09 (team research)**: Strict vs weak semantics comparative analysis.

## Goals & Non-Goals

**Goals**:
- Change all temporal quantification from reflexive (<=) to strict (<) in truth_at
- Remove temp_t_future and temp_t_past axioms
- Replace 6 Until/Since axioms with X/Y-based strict versions (unfold, intro, induction)
- Add temp_a_dual, disc_next, disc_prev axioms
- Add Formula.next and Formula.prev derived operators
- Prove soundness of all new/replaced axioms
- Update FMCS structure to use strict inequalities
- Remove all T-axiom dependencies across ~67 call sites
- Close the 2 original task-83 sorries (restricted_tc_family_to_fmcs forward_G/backward_H)
- Clean up auxiliary sorries in RestrictedTruthLemma.lean
- Achieve sorry-free canonical completeness over Int

**Non-Goals**:
- FMP TruthPreservation (task 82)
- dense_completeness_fc (task 68)
- The old full-coherence sorry (bfmcs_from_mcs_temporally_coherent)
- Changes to modal logic (S5 axioms unchanged)
- Changes to propositional logic layer

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency proof without T-axiom harder than expected | H | M | Fall back to routing through temporal_theory_witness_exists directly |
| g_content forward propagation breaks in DovetailedChain | H | M | Verify temporal_theory_witness_exists seed includes g_content |
| Backward truth lemma contrapositive has subtle gap | M | L | Fall back to direct induction with strengthened chain construction |
| TenseS5Algebra TL_quot restructure complex | M | M | Restructure to take always(phi) directly instead of H&G |
| New axiom formula encoding subtle errors | M | M | Use lean_verify after each axiom to check soundness proof compiles |
| Cascade of downstream breakage larger than cataloged | M | L | Use lake build incrementally; fix files in dependency order |

## Implementation Phases

### Phase 1: Syntax and Axiom Foundation [COMPLETED]

**Goal**: Establish the new syntactic operators and axiom system. This is the foundation all other phases build on.

**Tasks**:
- [ ] Add `Formula.next` and `Formula.prev` definitions to Formula.lean
- [ ] Add `swap_temporal_next` and `swap_temporal_prev` theorems to Formula.lean
- [ ] Rewrite `Axiom` inductive in Axioms.lean: remove `temp_t_future`, `temp_t_past`; replace 6 Until/Since axioms with X/Y-based versions (until_unfold, until_intro, until_induction, since_unfold, since_intro, since_induction); add `temp_a_dual`, `disc_next`, `disc_prev`
- [ ] Update `Axiom.frameClass` for all changed/new axioms (temp_a_dual = Base, disc_next/disc_prev = Discrete)
- [ ] Update `Axiom.isDenseCompatible` and `Axiom.isDiscreteCompatible` match cases
- [ ] Update `Axiom.isBase` match cases
- [ ] Update `subst_axiom` in Substitution.lean for all changed/new axiom cases
- [ ] Run `lake build` to verify Formula.lean and Axioms.lean compile

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` -- add next/prev operators and swap lemmas
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- rewrite axiom inductive and classifications
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- update subst_axiom cases

**Verification**:
- `lake build` succeeds for Formula.lean, Axioms.lean, Substitution.lean
- All 33 axioms present in the Axiom inductive
- Frame class assignments match research specification

---

### Phase 2: Semantic Truth Definition [COMPLETED]

**Goal**: Change the core semantic truth evaluation from reflexive to strict inequalities, establishing the semantic foundation for the refactor.

**Tasks**:
- [ ] Rewrite `truth_at` in Truth.lean: change `s <= t` to `s < t` for all_past, `t <= s` to `t < s` for all_future, and corresponding changes for untl/snce clauses
- [ ] Update `past_iff` lemma: `s <= t` to `s < t`
- [ ] Update `future_iff` lemma: `t <= s` to `t < s`
- [ ] Rewrite `time_shift_preserves_truth`: change `sub_le_sub_right`/`add_le_add_right` to strict variants
- [ ] Rewrite `truth_double_shift_cancel`: same inequality adjustments
- [ ] Update module docstrings to reference strict semantics
- [ ] Run `lake build` on Truth.lean (expect downstream failures)

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- rewrite truth_at and all dependent lemmas

**Verification**:
- Truth.lean compiles
- `lean_verify` confirms truth_at uses strict `<` in all temporal cases
- time_shift_preserves_truth and truth_double_shift_cancel compile

---

### Phase 3: Soundness -- Core Axiom Validity [NOT STARTED]

**Goal**: Prove soundness (validity) for all new and replaced axioms. This is the largest single-file effort and the mathematical core of the refactor.

**Tasks**:
- [ ] Delete `temp_t_future_valid` and `temp_t_past_valid`
- [ ] Write `temp_a_dual_valid`: phi -> H(F(phi)), proof via witness r=t for F(phi) at each s < t
- [ ] Write `disc_next_valid`: F(top) -> X(top), proof via successor s=t+1 with empty guard interval
- [ ] Write `disc_prev_valid`: P(top) -> Y(top), mirror of disc_next
- [ ] Write `until_unfold_valid`: phi U psi -> X(psi v (phi & (phi U psi))), proof via discrete case analysis on witness s
- [ ] Write `until_intro_valid`: X(psi v (phi & (phi U psi))) -> phi U psi, proof showing u=t+1 from bot guard
- [ ] Write `until_induction_valid`: strong induction on witness distance k = s-(t+1), the most complex new proof
- [ ] Write `since_unfold_valid`, `since_intro_valid`, `since_induction_valid` (mirrors of above)
- [ ] Rewrite `temp_linearity_valid`: change `<=` to `<` in witness extraction
- [ ] Rewrite `seriality_future_valid`: remove reflexive trick, use genuine NoMaxOrder witness
- [ ] Rewrite `seriality_past_valid`: mirror
- [ ] Rewrite `density_valid`: change to genuine density argument with strict inequalities
- [ ] Rewrite `discreteness_forward_valid`: update for strict semantics
- [ ] Update `axiom_valid` master dispatch for all changed cases
- [ ] Update `_valid_dense` and `_valid_discrete` dispatch tables
- [ ] Run `lake build` on Soundness.lean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- all validity proofs

**Verification**:
- Soundness.lean compiles without sorry
- All 33 axiom cases covered in axiom_valid dispatch
- `lean_verify` on axiom_valid

---

### Phase 4: Soundness Lemmas and Algebraic Layer [NOT STARTED]

**Goal**: Update SoundnessLemmas.lean (swapped axiom validity, bridge theorems) and the algebraic infrastructure (TenseS5Algebra, InteriorOperators).

**Tasks**:
- [ ] Rewrite `swapped_axiom_valid` in SoundnessLemmas.lean: delete T-axiom swap cases, add temp_a_dual swap case (dispatches to temp_a_valid), update seriality_past swap to use genuine NoMaxOrder
- [ ] Update bridge theorems in SoundnessLemmas.lean for `<=` to `<` in temporal quantification
- [ ] Rewrite `TL_quot` in TenseS5Algebra.lean: change from `H phi & G phi -> always phi` to taking `always phi = H phi & phi & G phi` directly via temp_l
- [ ] Delete `G_interior` and `H_interior` instances in InteriorOperators.lean (G/H are no longer interior operators under strict semantics)
- [ ] Update documentation in LinearityDerivedFacts.lean: remove references to temp_t_future/temp_t_past
- [ ] Verify Perpetuity module compiles unchanged (box_to_future uses modal T, not temporal T)
- [ ] Run `lake build` on all modified files

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- swapped validity, bridges
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` -- TL_quot restructure
- `Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean` -- delete G/H interior instances
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- documentation
- `Theories/Bimodal/Theorems/Perpetuity/` -- verify unchanged

**Verification**:
- All modified files compile
- TenseS5Algebra.lean has no T-axiom references
- InteriorOperators.lean has no G_interior/H_interior

---

### Phase 5: Canonical Model -- FMCS and Chain Infrastructure [NOT STARTED]

**Goal**: Update the FMCS structure to strict inequalities and refactor the chain construction files (SuccChainFMCS, CanonicalIrreflexivity) to remove T-axiom dependencies.

**Tasks**:
- [ ] Rewrite FMCS structure in FMCSDef.lean: change `t <= t'` to `t < t'` in forward_G, `t' <= t` to `t' < t` in backward_H
- [ ] Delete `existsTask_reflexive` and `existsTask_past_reflexive` from CanonicalIrreflexivity.lean
- [ ] Delete `lt_of_existsTask_and_not_reverse` from CanonicalIrreflexivity.lean
- [ ] In SuccChainFMCS.lean: delete `succ_chain_forward_G_le` and `succ_chain_backward_H_le` wrappers
- [ ] Update `SuccChainFMCS` construction to use `succ_chain_forward_G` and `succ_chain_backward_H` directly (strict < versions already exist)
- [ ] Remove T-axiom at line 4449 (neg_neg_bot): derive from propositional axioms directly
- [ ] Update all remaining T-axiom call sites in SuccChainFMCS.lean (lines 1274, 4039, 4306)
- [ ] Run `lake build` on modified files

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` -- FMCS structure
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` -- delete reflexive ExistsTask
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- remove _le wrappers and T-axiom sites

**Verification**:
- FMCSDef.lean compiles with strict inequalities
- No remaining references to temp_t_future/temp_t_past in these files
- SuccChainFMCS construction compiles

---

### Phase 6: Dovetailed Chain and Seed Consistency [NOT STARTED]

**Goal**: The highest-difficulty phase. Refactor DovetailedChain.lean and SuccExistence.lean to remove all T-axiom dependencies, restructure g_content/h_content propagation proofs, and establish seed consistency without `g_content(u) subset u`.

**Tasks**:
- [ ] Rewrite `forward_step_g_content` in DovetailedChain.lean: route through seed membership (temporal_theory_witness_exists includes g_content in seed) instead of T-axiom pattern G(a) in W -> a in W
- [ ] Rewrite `forward_dovetailed_forward_G`: remove n=m base case (strict semantics only needs n < m), adjust theorem statement
- [ ] Rewrite `forward_dovetailed_backward_H`: remove n=m base case, adjust to strict < requirement
- [ ] Rewrite `backward_step_h_content`: mirror of forward_step, route through predecessor seed membership
- [ ] Rewrite `backward_dovetailed_forward_G` and `backward_dovetailed_backward_H`: remove base cases, strict inequalities
- [ ] Address all 9 T-axiom sites in DovetailedChain.lean (lines 142, 224, 277, 282, 762, 891, 896, 912, 917)
- [ ] Restructure `constrained_successor_seed_consistent` in SuccExistence.lean: prove consistency via proof-theoretic argument (G-distribution + deduction theorem) instead of showing seed subset u
- [ ] Restructure `successor_deferral_seed_consistent_axiom`: same proof-theoretic approach
- [ ] Restructure `predecessor_deferral_seed_consistent_axiom`: mirror for h_content
- [ ] Run `lake build` on DovetailedChain.lean and SuccExistence.lean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- g/h_content propagation, base cases
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- seed consistency proofs

**Verification**:
- DovetailedChain.lean compiles without sorry
- SuccExistence.lean compiles without sorry
- No T-axiom references remain in either file
- `lake build` passes for both files

---

### Phase 7: UltrafilterChain, Witness Successor, and Targeted Chain [NOT STARTED]

**Goal**: Update the remaining chain construction files to remove T-axiom dependencies and use strict inequalities throughout.

**Tasks**:
- [ ] Delete `R_G_refl` and `R_H_refl` from UltrafilterChain.lean (G/H no longer reflexive)
- [ ] Rewrite `g_content_forward_propagation` (line 520): remove T-axiom usage
- [ ] Rewrite `h_content_backward_propagation` (line 559): remove T-axiom usage
- [ ] Rewrite `temporal_witness_g_persistence` (line 2578): use direct seed membership
- [ ] Address all T-axiom sites in UltrafilterChain.lean (lines 97, 267, 520, 565, 1009, 1318, 2591)
- [ ] Rewrite `mcs_witness_successor_g_content` in MCSWitnessSuccessor.lean: route through seed membership
- [ ] Rewrite `mcs_witness_predecessor_h_content`: mirror
- [ ] Rewrite `targeted_forward_chain_forward_G` in TargetedChain.lean: remove n=m base case
- [ ] Rewrite all targeted chain backward theorems (lines 346, 478, 512): remove base cases
- [ ] Run `lake build` on all three files

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- R_G/R_H reflexivity, propagation
- `Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean` -- witness g/h content
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- base case removal

**Verification**:
- All three files compile without sorry
- No T-axiom references remain
- `lake build` passes

---

### Phase 8: Canonical Construction and Truth Lemma [NOT STARTED]

**Goal**: Close the original task-83 sorries in CanonicalConstruction.lean and implement the backward truth lemma for Until via the contrapositive argument.

**Tasks**:
- [ ] Rewrite `restricted_tc_family_to_fmcs` in CanonicalConstruction.lean: the 2 sorries (forward_G and backward_H for restricted chain) now use strict `<` instead of `<=`, eliminating the t=t' case
- [ ] Implement forward truth lemma for Until: structural induction on witness (straightforward -- from phi U psi in mcs(t), extract witness s, use IH for phi and psi subformulas)
- [ ] Implement backward truth lemma for Until via contrapositive: if truth_at t (phi U psi), suppose neg(phi U psi) in mcs(t), by forward truth lemma for negation get contradiction, conclude phi U psi in mcs(t) by MCS maximality
- [ ] Implement forward/backward truth lemma for Since (mirrors of Until)
- [ ] Clean up auxiliary sorries in RestrictedTruthLemma.lean: restricted_chain_G_step and restricted_chain_H_step (may become unnecessary or trivially provable under strict semantics)
- [ ] Run `lake build` on CanonicalConstruction.lean and RestrictedTruthLemma.lean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- close the 2 original sorries
- `Theories/Bimodal/Metalogic/Bundle/RestrictedTruthLemma.lean` -- clean up auxiliary sorries

**Verification**:
- The 2 original task-83 sorries are closed
- RestrictedTruthLemma auxiliary sorries are resolved
- `lake build` passes for both files
- `lean_verify` on restricted_tc_family_to_fmcs

---

### Phase 9: Integration, Cleanup, and Full Build [NOT STARTED]

**Goal**: Full integration build, cleanup of documentation and any remaining issues, verification that the entire project compiles sorry-free for canonical completeness.

**Tasks**:
- [ ] Run full `lake build` and fix any remaining compilation errors
- [ ] Verify no references to `temp_t_future` or `temp_t_past` remain anywhere in codebase
- [ ] Verify no references to `R_G_refl`, `R_H_refl`, or `existsTask_reflexive` remain
- [ ] Update Automation/ proof search if axiom names changed
- [ ] Update Examples/ if any referenced theorems changed
- [ ] Run `lean_verify` on key theorems: axiom_valid, soundness, SuccChainFMCS, canonical completeness
- [ ] Grep for remaining `sorry` in Theories/Bimodal/ and confirm none are in the canonical completeness path
- [ ] Update module docstrings across all modified files to reference strict semantics

**Timing**: 2 hours

**Files to modify**:
- Various files across `Theories/Bimodal/` -- cleanup and documentation
- `Theories/Bimodal/Automation/` -- potential axiom name updates
- `Theories/Bimodal/Examples/` -- potential theorem reference updates

**Verification**:
- Full `lake build` succeeds
- Zero `sorry` on the canonical completeness path
- No stale references to removed axioms or theorems
- All docstrings updated for strict semantics

## Testing & Validation

- [ ] `lake build` succeeds with zero errors on all Theories/Bimodal/ files
- [ ] `lean_verify` passes on axiom_valid (all 33 axioms dispatched)
- [ ] `lean_verify` passes on soundness master theorem
- [ ] `lean_verify` passes on SuccChainFMCS construction
- [ ] `lean_verify` passes on restricted_tc_family_to_fmcs (the original task-83 target)
- [ ] Grep for `sorry` in canonical completeness path returns empty
- [ ] Grep for `temp_t_future|temp_t_past` in Theories/ returns empty
- [ ] Grep for `R_G_refl|R_H_refl|existsTask_reflexive` in Theories/ returns empty

## Artifacts & Outputs

- plans/11_strict-semantics-refactor.md (this file)
- Modified files across ~20 Lean source files in Theories/Bimodal/
- summaries/11_strict-semantics-summary.md (post-implementation)

## Rollback/Contingency

- All changes are on the `until` branch; main branch is unaffected
- Git history preserves all prior plan versions (v1-v8) and half-open implementation (phases 1-3)
- If seed consistency proofs (Phase 6) prove intractable, fall back to routing through `temporal_theory_witness_exists` directly as the successor/predecessor construction
- If the contrapositive backward truth lemma (Phase 8) has a gap, fall back to strengthened chain construction with backward X-content in predecessor seeds (documented in research report Task 4)
- If any individual phase blocks, partial progress can be committed and the phase resumed
