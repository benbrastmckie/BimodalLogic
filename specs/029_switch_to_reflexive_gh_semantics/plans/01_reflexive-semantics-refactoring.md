# Implementation Plan: Task #29

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/01_team-research.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/02_historical-issues-analysis.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/01_teammate-b-findings.md
- **Artifacts**: plans/01_reflexive-semantics-refactoring.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Switch TM metalogic from strict temporal semantics (`<`) to reflexive semantics (`<=`) for G and H operators. Under reflexive semantics, `G phi` means "phi holds at all t >= now" (including now), making the T-axiom (`G phi -> phi`) valid. This eliminates the `canonicalR_irreflexive_axiom` (which becomes FALSE under reflexive semantics) and enables proving `discreteImmediateSuccSeed_consistent_axiom` directly via T-axiom.

### Research Integration

Key findings integrated into this plan:
- **Axiom elimination**: `canonicalR_irreflexive_axiom` becomes FALSE (must be removed, not proven)
- **Axiom becomes theorem**: `discreteImmediateSuccSeed_consistent_axiom` becomes provable via T-axiom
- **Frame class collapse**: All 4 extension axioms (DN, DF, SF, SP) become trivially valid on any linear order
- **Documentation conflict**: ROAD_MAP.md says reflexive (Task 967), Truth.lean says strict (Task 991)
- **Antisymmetry pattern**: Irreflexivity transforms to antisymmetry (`CanonicalR M N /\ CanonicalR N M -> M = N`)

## Goals & Non-Goals

**Goals**:
- Change temporal operator semantics from `<` to `<=` in Truth.lean
- Add T-axioms (`temp_t_future`, `temp_t_past`) to proof system
- Remove `canonicalR_irreflexive_axiom` (it becomes FALSE)
- Prove `discreteImmediateSuccSeed_consistent_axiom` using T-axiom
- Update all downstream code relying on irreflexivity to use antisymmetry
- Repair soundness proofs for reflexive semantics
- Resolve documentation/code inconsistency (ROAD_MAP.md vs Truth.lean)

**Non-Goals**:
- Proving `discrete_Icc_finite_axiom` (independent of strict/reflexive choice)
- Complete restructuring of FrameClass enum (architectural simplification is out of scope)
- Major changes to completeness pipeline structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Unforeseen downstream breakages | H | M | Incremental phases with `lake build` after each |
| Soundness proof complexity | M | M | Phase 3 focuses entirely on soundness repairs |
| Gabbay IRR infrastructure bit rot | H | L | Historical code was working under Task 967, test reactivation carefully |
| Antisymmetry proof difficulty | M | M | Use existing 1170-line Gabbay infrastructure from CanonicalIrreflexivity.lean |
| T-axiom interactions in MCS properties | M | L | MCS membership closure already handles valid axioms |

## Implementation Phases

### Phase 1: Core Semantic Change [NOT STARTED]

**Goal**: Change temporal operator truth definition from strict to reflexive

**Tasks**:
- [ ] Update `Truth.lean` lines 121-122: change `s < t` to `s <= t` and `t < s` to `t <= s`
- [ ] Update docstring in Truth.lean to reflect reflexive semantics
- [ ] Add `temp_t_future` and `temp_t_past` axiom constructors to `ProofSystem/Axioms.lean`
- [ ] Update Axioms.lean docstring explaining T-axioms are now valid
- [ ] Run `lake build Bimodal.Semantics.Truth Bimodal.ProofSystem.Axioms` to verify syntax

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Change `<` to `<=` (2 lines)
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Add T-axiom constructors

**Verification**:
- `lake build` on the two modified files succeeds
- No syntax errors in modified code

---

### Phase 2: FMCS Structure Update [NOT STARTED]

**Goal**: Update FMCS coherence fields and TemporalCoherence signatures for reflexive semantics

**Tasks**:
- [ ] Update `FMCSDef.lean` lines 119, 127: change `t < t'` to `t <= t'` and `t' < t` to `t' <= t`
- [ ] Update FMCSDef.lean docstrings to reflect reflexive coherence
- [ ] Update `TemporalCoherence.lean` signatures for `temporal_backward_G/H` if needed
- [ ] Run `lake build Bimodal.Metalogic.Bundle.FMCSDef` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - Change `<` to `<=` (2 lines)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Signature updates if needed

**Verification**:
- `lake build` on FMCSDef.lean succeeds
- Downstream modules that import FMCSDef still compile (may have errors to fix in later phases)

---

### Phase 3: Soundness Proof Repairs [NOT STARTED]

**Goal**: Fix all soundness proofs for reflexive temporal semantics

**Tasks**:
- [ ] Add `temp_t_valid_future` proof to Soundness.lean: `forall phi, valid (phi.all_future.imp phi)`
- [ ] Add `temp_t_valid_past` proof to Soundness.lean: `forall phi, valid (phi.all_past.imp phi)`
- [ ] Fix `temp_4_valid`: change `lt_trans` to `le_trans`
- [ ] Fix `temp_a_valid`: add `s = t` case using `le_refl`
- [ ] Fix `temp_l_valid`: handle reflexive case in trichotomy
- [ ] Fix `density_valid`: add `s = t` case (trivially satisfied by reflexivity)
- [ ] Fix `discreteness_forward_valid`: adjust for reflexive H semantics
- [ ] Fix `seriality_future_valid` and `seriality_past_valid`: trivially true via T-axiom
- [ ] Update `axiom_base_valid` to include T-axioms
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Add T-axiom validity, fix proofs

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` succeeds
- All axiom validity proofs compile

---

### Phase 4: Truth Lemma Adjustment [NOT STARTED]

**Goal**: Update truth lemma for reflexive G/H semantics

**Tasks**:
- [ ] Update `ParametricTruthLemma.lean` `all_future` case (line 274): add `s = t` case using T-axiom
- [ ] Update `all_past` case similarly
- [ ] Adjust backward direction proofs for reflexive quantification
- [ ] Run `lake build Bimodal.Metalogic.Algebraic.ParametricTruthLemma` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Add reflexive cases

**Verification**:
- `lake build` on ParametricTruthLemma succeeds
- G/H truth lemma cases handle both s > t and s = t

---

### Phase 5: Remove canonicalR_irreflexive_axiom [NOT STARTED]

**Goal**: Remove the now-FALSE axiom and replace irreflexivity with antisymmetry

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from CanonicalIrreflexivity.lean
- [ ] Add `theorem canonicalR_reflexive`: prove `CanonicalR M M` using T-axiom (g_content M subset M)
- [ ] Add `theorem canonicalR_antisymmetric`: prove `CanonicalR M N /\ CanonicalR N M -> M = N`
- [ ] Update `CanonicalIrreflexivityAxiom.lean` wrapper theorem to use antisymmetry
- [ ] Update `canonicalR_antisymmetric_strict` to derive from antisymmetry + distinctness
- [ ] Update `canonicalR_strict` to use antisymmetry pattern
- [ ] Find and update all downstream uses of `canonicalR_irreflexive` to use antisymmetry
- [ ] Run `lake build` to find and fix all breakages

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Remove axiom, add theorems
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Update wrapper
- Any files importing CanonicalIrreflexivity that use irreflexivity

**Verification**:
- No `axiom canonicalR_irreflexive_axiom` in codebase
- `canonicalR_reflexive` and `canonicalR_antisymmetric` are proven theorems
- `lake build` succeeds

---

### Phase 6: Prove discreteImmediateSuccSeed_consistent [NOT STARTED]

**Goal**: Convert the axiom to a proven theorem using T-axiom

**Tasks**:
- [ ] Remove `axiom discreteImmediateSuccSeed_consistent_axiom` from DiscreteSuccSeed.lean
- [ ] Complete Case 2 proof in `discreteImmediateSuccSeed_consistent`:
  - Use T-axiom: `g_content(M) subset M` now holds
  - Blocking formula `not psi or not G(psi)` is derivable from `not G(psi) in M`
  - Show any finite subset of seed is consistent using closure properties
- [ ] Run `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - Remove axiom, prove

**Verification**:
- No `axiom discreteImmediateSuccSeed_consistent_axiom` in codebase
- `discreteImmediateSuccSeed_consistent` is a proven theorem
- `lake build` succeeds

---

### Phase 7: Documentation and Final Verification [NOT STARTED]

**Goal**: Update documentation, resolve conflicts, verify full build

**Tasks**:
- [ ] Update ROAD_MAP.md: confirm reflexive semantics is current (resolve Task 991 inconsistency)
- [ ] Update Truth.lean header docstring to remove strict semantics references
- [ ] Update Axioms.lean docstring to include T-axioms
- [ ] Update CanonicalIrreflexivity.lean docstring to describe antisymmetry approach
- [ ] Run full `lake build` to verify no regressions
- [ ] Grep for remaining `axiom` declarations to assess remaining axiom count
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `ROAD_MAP.md` - Resolve documentation conflict
- Various Lean files - Docstring updates

**Verification**:
- Full `lake build` succeeds
- `grep -r "^axiom" Theories/` shows reduced axiom count
- Documentation is consistent with implementation

## Testing & Validation

- [ ] Full `lake build` passes after each phase
- [ ] `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results after Phase 5
- [ ] `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results after Phase 6
- [ ] `grep -r "^axiom" Theories/Bimodal/` shows expected remaining axioms only (`discrete_Icc_finite_axiom`)
- [ ] No new `sorry` introduced (verify via `grep -r "sorry" Theories/`)

## Artifacts & Outputs

- Updated `Truth.lean` with reflexive semantics
- Updated `Axioms.lean` with T-axiom constructors
- Proven `canonicalR_reflexive` and `canonicalR_antisymmetric` theorems
- Proven `discreteImmediateSuccSeed_consistent` theorem
- Resolved ROAD_MAP.md documentation conflict
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/01_reflexive-semantics-summary.md`

## Rollback/Contingency

If significant issues arise:
1. Git revert to pre-implementation commit
2. Document blocking issues in errors.json
3. Consider hybrid approach: keep strict semantics but add explicit T-axiom where needed
4. Alternative: accept `canonicalR_irreflexive_axiom` as permanent (document semantic justification)

The core semantic change (Phase 1) is the foundation; if it causes cascading failures, evaluate whether a more incremental approach is needed (e.g., prove T-axiom soundness first, then gradually adopt reflexive semantics in downstream modules).
