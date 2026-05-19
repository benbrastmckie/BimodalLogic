# Implementation Plan: Close Task 116 Sorries

- **Task**: 167 - Close 7 sorries from task 116 (SubformulaClosure gap + ConservativeExtension dead code)
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: 116
- **Research Inputs**: specs/167_close_task116_sorries/reports/01_subformula-closure-gap.md
- **Artifacts**: plans/01_close-sorries-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 116 redefined G/H/F/P via Until/Since (U/S), breaking the SubformulaClosure's ability to provide temporal dual formulas. Under the new definitions, `P(chi) = S(chi, top)` but `H(~chi) = (S(~~chi, top)).imp bot` -- these are structurally unrelated, yet the completeness proof requires both in the deferral closure. This plan adds a `temporalBlockingSet` to `baseDeferralClosure` to close the 3 Category A sorries, removes 8 dead `ExtAxiom` constructors to eliminate all Category C sorry-armed match cases across ConservativeExtension, and validates with a full build. The 3 BX1/irreflexive-semantics sorries (Category B, lines 460/763/837 in SuccExistence.lean) are explicitly out of scope.

### Research Integration

The research report (01_subformula-closure-gap.md) provides:
- Detailed literature analysis showing our hybrid approach (Burgess-style MCS reasoning with finite restricted closures) creates the design gap
- Proof that `~P(chi)` and `H(~chi)` differ structurally: first `snce` argument is `chi` vs `(chi.imp bot).imp bot`
- Definition of `temporalBlockingSet` as `{H(~chi) | P(chi) in closure} ∪ {G(~chi) | F(chi) in closure}`
- Analysis of nested case (`neg_FF_implies_GG_neg_in_drm`) requiring level-2 blocking or proof-theoretic bridge
- Finiteness guarantee: O(n) additional formulas, preserving deferralClosure finiteness

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define `temporalBlockingSet` and integrate it into `baseDeferralClosure`
- Fix all cascading membership proofs in SubformulaClosure.lean broken by the new union component
- Close `p_step_blocking_restricted_subset_deferralClosure` sorry (SuccExistence.lean line 244)
- Close `p_step_blocking_restricted_subset` sorry (RestrictedMCS.lean line 966)
- Close `neg_FF_implies_GG_neg_in_drm` sorry (RestrictedMCS.lean line 1399)
- Remove dead `ExtAxiom` constructors and all associated sorry-armed match cases in ConservativeExtension
- Achieve a clean `lake build` with no new sorries introduced

**Non-Goals**:
- Fixing BX1/irreflexive-semantics sorries (SuccExistence.lean lines 460, 763, 837) -- these require `g_content u ⊆ u` which does not hold under irreflexive semantics
- Fixing sorries in Boneyard or other non-ConservativeExtension files
- Restructuring the completeness proof architecture
- Changing the G/H/F/P definitions themselves

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cascading proof breakage in SubformulaClosure.lean from new union component | H | H | New union branch discharges by constructor discrimination in most cases; budget 2h for this phase |
| `neg_FF_implies_GG_neg_in_drm` needs level-2 blocking set, increasing closure complexity | M | M | Research shows level-2 adds at most 2n formulas; implement if needed, try proof-theoretic bridge first |
| Removing ExtAxiom constructors breaks downstream files beyond ConservativeExtension | H | L | Grep confirms no external references to dead constructors; full build validates |
| `temp_a` match arms in `substAxiomFresh`/`substAxiom` also use Extsorry despite temp_a being valid | M | M | Fix `temp_a` arms to use `ExtAxiom.temp_a _` as part of the cleanup; separate from dead constructor removal |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 4 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Define temporalBlockingSet and extend baseDeferralClosure [COMPLETED]

**Goal**: Add the temporal blocking set to the deferral closure infrastructure in SubformulaClosure.lean, providing the formulas needed for temporal duality.

**Tasks**:
- [ ] Define `temporalBlockingSet` after `backwardDeferralSet` (~line 780) that computes `{all_past(chi.neg) | some_past(chi) in closureWithNeg(phi)} ∪ {all_future(chi.neg) | some_future(chi) in closureWithNeg(phi)}`
- [ ] Determine if level-2 blocking (G/H applied to blocking formulas) is needed for the nested `neg_FF_implies_GG_neg` case; if so, define `temporalBlockingSetL2`
- [ ] Modify `baseDeferralClosure` to include `temporalBlockingSet phi` (and L2 if needed)
- [ ] Prove key membership lemma: `all_past_neg_mem_deferralClosure_of_some_past` (if P(chi) in closureWithNeg, then H(~chi) in deferralClosure)
- [ ] Prove dual membership lemma: `all_future_neg_mem_deferralClosure_of_some_future` (if F(chi) in closureWithNeg, then G(~chi) in deferralClosure)
- [ ] Verify the definition compiles with `lake build Bimodal.Syntax.SubformulaClosure`

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Add temporalBlockingSet definition, modify baseDeferralClosure, add membership lemmas

**Verification**:
- `temporalBlockingSet` compiles and produces a `Finset Formula`
- `baseDeferralClosure` includes the new set
- Key membership lemmas type-check
- Module builds without errors (downstream breakage expected, handled in Phase 2)

---

### Phase 2: Fix cascading membership proofs in SubformulaClosure.lean [COMPLETED]

**Goal**: Update all proofs in SubformulaClosure.lean that pattern-match on the `baseDeferralClosure` union structure, adding cases for the new `temporalBlockingSet` component.

**Tasks**:
- [ ] Fix `some_future_in_deferralClosure_cases` (~line 1419): add rcases branch for temporalBlockingSet membership; discharge by showing blocking formulas are `all_past`/`all_future`, not `some_future`
- [ ] Fix `some_past_in_deferralClosure_cases` (~line 1466): symmetric fix
- [ ] Fix `closureWithNeg_subset_deferralClosure` and any other subset proofs that unfold baseDeferralClosure
- [ ] Update `F_top_mem_deferralClosure`, `P_top_mem_deferralClosure` and similar membership lemmas if they unfold `baseDeferralClosure`
- [ ] Fix `serialityFormulas_subset_deferralClosure` if it exists
- [ ] Fix `deferralDisjunctionSet_subset_deferralClosure` and `backwardDeferralSet_subset_deferralClosure` proofs if affected
- [ ] Fix any `some_past_in_deferralClosure_cases`/`some_future_in_deferralClosure_cases` consumers that do rcases and now get an extra branch
- [ ] Run `lake build Bimodal.Syntax.SubformulaClosure` until clean

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Update ~15-20 proofs that pattern-match on baseDeferralClosure union structure

**Verification**:
- `lake build Bimodal.Syntax.SubformulaClosure` succeeds with no errors
- All existing theorems in the file still compile
- No new sorries introduced

---

### Phase 3: Close Category A sorries in SuccExistence and RestrictedMCS [COMPLETED]

**Goal**: Use the new temporalBlockingSet membership lemmas to close the 3 sorry sites caused by the SubformulaClosure design gap.

**Tasks**:
- [x] Close `p_step_blocking_restricted_subset_deferralClosure` sorry (SuccExistence.lean ~line 244): replaced sorry with `all_past_neg_mem_deferralClosure_of_some_past` via `some_past_in_deferralClosure_cases`
- [x] Close `p_step_blocking_restricted_subset` sorry (RestrictedMCS.lean ~line 966): same pattern as above
- [x] Close `neg_FF_implies_GG_neg_in_drm` sorry (RestrictedMCS.lean ~line 1399) *(deviation: skipped -- removed as dead code with no callers; the MCS version neg_FF_implies_GG_neg_in_mcs is used on the critical path)*
- [x] Verify preconditions for sorry-3: N/A since theorem removed *(deviation: skipped -- dead code removed)*
- [x] Run `lake build` on affected modules to verify

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Close sorry at line 244
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Close sorries at lines 966 and 1399

**Verification**:
- `grep -n "sorry" SuccExistence.lean` shows only lines 460, 763, 837 (BX1 sorries, out of scope)
- `grep -n "sorry" RestrictedMCS.lean` shows no sorries
- `lake build Bimodal.Metalogic.Bundle.SuccExistence` and `lake build Bimodal.Metalogic.Core.RestrictedMCS` succeed

---

### Phase 4: Remove dead ExtAxiom constructors and ConservativeExtension sorry arms [COMPLETED]

**Goal**: Eliminate all Category C sorries by removing the 8 dead `ExtAxiom` constructors that have no corresponding base `Axiom` counterpart, then cleaning up all affected match arms.

**Tasks**:
- [x] Remove 8 dead constructors from `ExtAxiom` in ExtDerivation.lean (~lines 51-76): `temp_k_dist`, `temp_4`, `temp_l`, `temp_linearity`, `density`, `discreteness_forward`, `seriality_future`, `seriality_past` *(deviation: altered -- rewrote ExtAxiom to mirror base Axiom exactly with all 40 constructors, which also required updating ExtFormula to use untl/snce primitives and Atom instead of String)*
- [x] Remove corresponding dead match arms from `embedAxiom` in ExtDerivation.lean (~lines 117-126)
- [x] Remove dead match arms from `substAxiom` in Substitution.lean (~lines 199-208)
- [x] Remove dead match arms from `substAxiomFresh` in Lifting.lean (~lines 202-211)
- [x] Remove dead match arms from `unembedAxiom` in Lifting.lean (~lines 229-239)
- [x] Remove dead match arms from `liftAxiom` in Lifting.lean (~lines 469-479)
- [x] Fix `temp_a` match arm in `substAxiomFresh` and `substAxiom`: change from `Extsorry` to `ExtAxiom.temp_a _` (temp_a is valid, was incorrectly sorry'd) *(deviation: altered -- temp_a replaced by connect_future in new ExtAxiom mirroring base Axiom)*
- [x] Run `lake build` on ConservativeExtension modules to verify no remaining sorry or compile errors

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean` - Remove 8 dead ExtAxiom constructors and dead embedAxiom match arms
- `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean` - Remove dead substAxiom match arms, fix temp_a arm
- `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean` - Remove dead match arms from substAxiomFresh, unembedAxiom, liftAxiom; fix temp_a arms

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/ConservativeExtension/` shows zero sorry occurrences
- `grep -rn "Extsorry" Theories/Bimodal/Metalogic/ConservativeExtension/` shows zero occurrences
- `lake build Bimodal.Metalogic.ConservativeExtension` modules all succeed

---

### Phase 5: Full build validation [COMPLETED]

**Goal**: Run a complete `lake build` and verify the sorry count has decreased by exactly 7 (the in-scope sorries) with no regressions.

**Tasks**:
- [ ] Run `lake build` from project root
- [ ] Grep for all remaining `sorry` in `Theories/` (excluding Boneyard) and verify count matches pre-task baseline minus 7
- [ ] Specifically verify: SuccExistence.lean has exactly 3 sorries (BX1 lines 460, 763, 837), RestrictedMCS.lean has 0, ConservativeExtension has 0
- [ ] Verify no new warnings or errors introduced
- [ ] Check that `lean_verify` passes on key theorems if accessible

**Timing**: 0.5 hours (build time)

**Depends on**: 3, 4

**Files to modify**:
- None (validation only)

**Verification**:
- `lake build` exits 0
- Sorry count in scope files matches expectations
- No new compilation warnings

## Testing & Validation

- [ ] `lake build` completes successfully with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Syntax/SubformulaClosure.lean` returns only comment references (no actual sorry)
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` returns zero results
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` returns exactly 3 results (lines 460, 763, 837 -- BX1 sorries, out of scope)
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/ConservativeExtension/` returns zero results (including no Extsorry)
- [ ] `temporalBlockingSet` membership lemmas type-check without sorry
- [ ] `deferralClosure` finiteness is preserved (Finset type ensures this)

## Artifacts & Outputs

- `specs/167_close_task116_sorries/plans/01_close-sorries-plan.md` (this file)
- `specs/167_close_task116_sorries/summaries/01_close-sorries-summary.md` (after implementation)
- Modified source files:
  - `Theories/Bimodal/Syntax/SubformulaClosure.lean`
  - `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`
  - `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
  - `Theories/Bimodal/Metalogic/ConservativeExtension/ExtDerivation.lean`
  - `Theories/Bimodal/Metalogic/ConservativeExtension/Substitution.lean`
  - `Theories/Bimodal/Metalogic/ConservativeExtension/Lifting.lean`

## Rollback/Contingency

- All changes are in version control; `git stash` or `git checkout` individual files to revert
- Phase 4 (ConservativeExtension cleanup) is independent of Phases 1-3 and can be reverted separately
- If Phase 3's nested sorry (`neg_FF_implies_GG_neg_in_drm`) proves intractable, mark it [BLOCKED] and deliver the other 6 sorry closures as partial success
- If the cascading proof fixes in Phase 2 are more extensive than expected, focus on fixing only the proofs needed for Phase 3's sorry sites and defer cosmetic fixes
