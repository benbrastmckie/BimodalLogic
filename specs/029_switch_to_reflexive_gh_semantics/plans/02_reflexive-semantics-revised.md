# Implementation Plan: Task #29 (Revised)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [NOT STARTED]
- **Effort**: 17-18 hours (revised from 12 hours)
- **Dependencies**: None (self-contained refactoring; other tasks wait on this)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/01_team-research.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/02_historical-issues-analysis.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/05_team-research.md (Wave 2)
  - specs/029_switch_to_reflexive_gh_semantics/reports/05_teammate-a-findings.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/05_teammate-b-findings.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/05_teammate-c-findings.md
  - specs/029_switch_to_reflexive_gh_semantics/reports/06_theoretical-analysis.md
- **Supersedes**: plans/01_reflexive-semantics-refactoring.md (v1)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Switch TM metalogic from strict temporal semantics (`<`) to reflexive semantics (`<=`) for G and H operators. Under reflexive semantics, `G phi` means "phi holds at all t >= now" (including now), making the T-axiom (`G phi -> phi`) valid.

### Key Consequences (from Theoretical Analysis)

1. **T-axiom becomes valid**: `G phi -> phi` and `H phi -> phi` are definitionally valid
2. **Frame class collapse**: DN, DF, SF, SP become trivially valid on ANY linear order
3. **Axiom elimination**: `canonicalR_irreflexive_axiom` becomes FALSE (removed, not proven)
4. **Axiom proven**: `discreteImmediateSuccSeed_consistent_axiom` becomes provable via T-axiom
5. **Three completeness theorems collapse to one**: Base/Dense/Discrete distinction vanishes
6. **Task 26 superseded**: Entirely subsumed by this task's Phase 5

### Why This Change (Research Consensus)

The theoretical analysis (06_theoretical-analysis.md) recommends reflexive semantics because:
- Eliminates the irreflexivity blocker (the major obstacle in completeness proofs)
- The 1170-line Gabbay infrastructure can be used for antisymmetry proofs
- Simplifies completeness architecture from three theorems to one
- Aligns with existing ROAD_MAP.md documentation (Task 991 inconsistency)
- FMCS coherence conditions are documented for reflexive semantics
- Loss of frame-definability for density/seriality is acceptable for TM's goals

### Research Integration (Revised Scope)

Key findings from Wave 2 research (05_team-research.md):

- **Phase 5 blast radius**: ~35 call sites across 11 files (not a small wrapper change)
- **Axiom coverage gap**: Plan v1 addressed 2 axioms; codebase has 10 total
- **FMCS is currently STRICT**: Code uses `<`, documentation says `<=` (Task 991 inconsistency)
- **Task ordering**: Task 29 should proceed FIRST; Tasks 18, 22, 24 wait on this

## Goals & Non-Goals

**Goals**:
- Change temporal operator semantics from `<` to `<=` in Truth.lean
- Add T-axioms (`temp_t_future`, `temp_t_past`) to proof system
- Update FMCS coherence conditions from `<` to `<=`
- Remove `canonicalR_irreflexive_axiom` (it becomes FALSE)
- Add `canonicalR_reflexive` and `canonicalR_antisymmetric` theorems
- Fix all ~35 downstream call sites using irreflexivity
- Prove `discreteImmediateSuccSeed_consistent_axiom` using T-axiom
- Assess provability of additional axioms under T-axiom
- Repair soundness proofs for reflexive semantics
- Simplify frame class architecture (three variants -> one)
- Resolve documentation/code inconsistency (ROAD_MAP.md vs Truth.lean)

**Non-Goals**:
- Proving `discrete_Icc_finite_axiom` (independent of strict/reflexive choice)
- Proving nesting boundary axioms (`f_nesting_boundary`, `p_nesting_boundary`)
- Removing pre-existing sorries in DovetailedTimelineQuot.lean (semantics-independent)
- Complete restructuring of FrameClass enum (simplification, not removal)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| NoMaxOrder/NoMinOrder proof collapse | H | M | Phase 0 enumeration; draft replacement arguments before starting |
| Phase 5 blast radius (~35 sites) | H | H | Budget 5 hours; enumerate all sites in Phase 0 |
| `lt_of_canonicalR` invalidation in FMCSTransfer.lean | H | H | Redesign to require `a ≠ b` hypothesis or handle `a = b` case |
| DovetailedTimelineQuot.lean sorries | M | M | Touch carefully; 12 sites near 4 pre-existing sorries |
| Unaddressed axioms (7 not in v1 plan) | M | M | Phase 6 expanded; document as semantics-independent where applicable |
| Soundness proof complexity | M | L | Phase 3 focuses entirely on soundness repairs |
| Truth lemma backward G/H direction | M | L | T-axiom constructors added in Phase 1 enable Phase 4 |

## Implementation Phases

### Phase 0: Enumeration and Pattern Catalog [COMPLETED]

**Goal**: Complete enumeration before any code changes

**Tasks**:
- [ ] Enumerate all ~35 `canonicalR_irreflexive` call sites with grep
- [ ] Categorize each site: NoMaxOrder, NoMinOrder, DenselyOrdered, strict antisymmetry, other
- [ ] For each DovetailedTimelineQuot.lean proof (~12 sites), draft replacement argument
- [ ] Assess `lt_of_canonicalR` in FMCSTransfer.lean — determine redesign approach
- [ ] List all 10 axioms; categorize: removed, provable via T-axiom, semantics-independent
- [ ] Create enumeration report at `specs/029_switch_to_reflexive_gh_semantics/reports/07_enumeration.md`

**Timing**: 2 hours

**Files to analyze** (read-only):
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Source axiom
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` - ~12 sites
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean` - ~6 sites
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - ~4 sites
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` - Critical `lt_of_canonicalR`
- All files with `axiom` declarations

**Verification**:
- Complete call site inventory
- Draft replacement argument for each category
- Axiom assessment table complete

---

### Phase 1: Core Semantic Change [COMPLETED]

**Goal**: Change temporal operator truth definition from strict to reflexive

**Tasks**:
- [ ] Update `Truth.lean` lines 121-122: change `s < t` to `s <= t` and `t < s` to `t <= s`
- [ ] Update Truth.lean header docstring: remove "STRICT Temporal Semantics (Task #991)" label
- [ ] Add `temp_t_future` axiom constructor to `ProofSystem/Axioms.lean`:
  ```lean
  | temp_t_future (φ : Formula) : Axiom (φ.all_future.imp φ)
  ```
- [ ] Add `temp_t_past` axiom constructor to `ProofSystem/Axioms.lean`:
  ```lean
  | temp_t_past (φ : Formula) : Axiom (φ.all_past.imp φ)
  ```
- [ ] Update Axioms.lean docstring explaining T-axioms are now valid
- [ ] Classify T-axioms with `FrameClass.Base` (valid on all linear orders)
- [ ] Run `lake build Bimodal.Semantics.Truth Bimodal.ProofSystem.Axioms` to verify syntax

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Change `<` to `<=` (2 lines + docstring)
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Add T-axiom constructors + docstring

**Verification**:
- `lake build` on the two modified files succeeds
- `grep "temp_t_future\|temp_t_past" Theories/Bimodal/ProofSystem/Axioms.lean` shows new axioms

---

### Phase 2: FMCS Structure Update [COMPLETED]

**Goal**: Update FMCS coherence fields for reflexive semantics

**Tasks**:
- [ ] Update `FMCSDef.lean` line 119: change `t < t'` to `t <= t'` in `forward_G`
- [ ] Update `FMCSDef.lean` line 127: change `t' < t` to `t' <= t` in `backward_H`
- [ ] Update FMCSDef.lean docstrings: remove "irreflexive semantics" and "no T-axiom" references
- [ ] Update `TemporalCoherence.lean` signatures if needed (assess during implementation)
- [ ] Note: `temporal_backward_G/H` likely unchanged (uses strict witnesses from F/P)
- [ ] Run `lake build Bimodal.Metalogic.Bundle.FMCSDef` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - Change `<` to `<=` (2 lines + docstrings)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Signature updates if needed

**Verification**:
- `lake build` on FMCSDef.lean succeeds
- Docstrings accurately describe reflexive coherence

---

### Phase 3: Soundness Proof Repairs [COMPLETED]

**Goal**: Fix all soundness proofs for reflexive temporal semantics

**Tasks**:
- [ ] Add `temp_t_valid_future` proof: `forall phi, valid (phi.all_future.imp phi)` using `le_refl`
- [ ] Add `temp_t_valid_past` proof: `forall phi, valid (phi.all_past.imp phi)` using `le_refl`
- [ ] Fix `temp_4_valid` (line 186-201): change `lt_trans` to `le_trans`
- [ ] Fix `temp_a_valid` (line ~208): add `s = t` case using `le_refl`
- [ ] Fix `temp_l_valid` (line 208-229): handle reflexive case in trichotomy (may already work)
- [ ] Simplify `density_valid`: `s = t` case trivially satisfied by reflexivity
- [ ] Simplify `seriality_future_valid` / `seriality_past_valid`: trivially true via T-axiom
- [ ] Simplify `discreteness_forward_valid`: adjust for reflexive H semantics
- [ ] Update `axiom_base_valid` to include T-axiom cases
- [ ] Run `lake build Bimodal.Metalogic.Soundness` to verify

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Add T-axiom validity, fix proofs

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` succeeds
- All axiom validity proofs compile
- `grep "temp_t_valid" Theories/Bimodal/Metalogic/Soundness.lean` shows new proofs

---

### Phase 4: Truth Lemma Adjustment [COMPLETED]

**Goal**: Update truth lemma for reflexive G/H semantics

**Tasks**:
- [ ] Update `ParametricTruthLemma.lean` `all_future` forward case (line 279-281):
  - Change `hts : t < s` to `hts : t <= s`
  - Rely on updated `FMCS.forward_G` signature
- [ ] Handle `s = t` case in G forward: use T-axiom membership (`G φ ∈ mcs t → φ ∈ mcs t`)
- [ ] Update `all_past` forward case similarly
- [ ] Verify backward cases (`temporal_backward_G/H`): likely unchanged (strict F/P witnesses)
- [ ] Check `DenseInstantiation.lean` for any strict-`<` logic that needs updating
- [ ] Run `lake build Bimodal.Metalogic.Algebraic.ParametricTruthLemma` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Add reflexive cases
- `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` - If needed

**Verification**:
- `lake build` on ParametricTruthLemma succeeds
- G/H truth lemma forward cases handle both `s > t` and `s = t`

---

### Phase 5: Axiom Removal and Downstream Repair [PARTIAL]

**Goal**: Remove `canonicalR_irreflexive_axiom` and fix all ~35 downstream call sites

**Critical Context from Research**:
- `canonicalR_irreflexive` is called at ~35 sites across 11 files
- Under reflexive semantics, `CanonicalR M M` is TRUE (T-axiom: `g_content(M) ⊆ M`)
- Existing proofs use pattern: `canonicalR_irreflexive M hM (canonicalR_transitive M N M hM h_MN h_NM)`
- Replacement approach: antisymmetry + distinctness guards

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from CanonicalIrreflexivity.lean (line 1212)
- [ ] Add `theorem canonicalR_reflexive`: prove `CanonicalR M M` using T-axiom
- [ ] Add `theorem canonicalR_antisymmetric`: prove `CanonicalR M N ∧ CanonicalR N M → M = N`
- [ ] Add `theorem canonicalR_strict_of_ne`: prove `CanonicalR M N → M ≠ N → ¬CanonicalR N M`
- [ ] Update `CanonicalIrreflexivityAxiom.lean` wrapper to export antisymmetry, not irreflexivity
- [ ] Fix `FMCSTransfer.lean`:
  - Redesign `lt_of_canonicalR` to require `a ≠ b` hypothesis OR
  - Add separate handling for `a = b` case in `transfer_forward_F` / `transfer_backward_P`
- [ ] Fix DovetailedTimelineQuot.lean (~12 sites):
  - NoMaxOrder proofs: use blocking formula construction to show seriality witness ≠ M
  - NoMinOrder proofs: similar approach
  - DenselyOrdered proofs: use antisymmetry to establish strict ordering
- [ ] Fix SaturatedChain.lean (~6 sites): use antisymmetry + distinctness
- [ ] Fix CantorApplication.lean (~4 sites): adjust density/seriality proofs
- [ ] Fix remaining files (ClosureSaturation, IncrementalTimeline, TimelineQuotCanonical, etc.)
- [ ] Fix DiscreteTimeline.lean (2 sites): NoMaxOrder/NoMinOrder with antisymmetry
- [ ] Fix CanonicalSerialFrameInstance.lean (2 sites): serial frame instance
- [ ] Run `lake build` to find and fix all remaining breakages

**Timing**: 5 hours (expanded from 2.5)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Remove axiom, add theorems
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Update exports
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` - Redesign `lt_of_canonicalR`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` - ~12 sites
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean` - ~6 sites
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` - ~4 sites
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - 2 sites
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean` - 1 site
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - 1 site
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - 2 sites
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean` - 2 sites

**Verification**:
- `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results
- `canonicalR_reflexive` and `canonicalR_antisymmetric` are proven theorems
- `lake build` succeeds on all modified files

---

### Phase 6: Additional Axiom Conversion [NOT STARTED]

**Goal**: Convert provable axioms to theorems; document remaining axioms

**Axiom Assessment Table** (from research):

| Axiom | File | Under Reflexive | Action |
|-------|------|-----------------|--------|
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean | FALSE | Phase 5: REMOVE |
| `discreteImmediateSuccSeed_consistent_axiom` | DiscreteSuccSeed.lean | Provable | Phase 6: PROVE |
| `discrete_Icc_finite_axiom` | DiscreteTimeline.lean | Unaffected | Document as debt |
| `discreteImmediateSucc_covers_axiom` | DiscreteSuccSeed.lean | Possibly provable | Phase 6: ASSESS |
| `successor_deferral_seed_consistent_axiom` | SuccExistence.lean | Possibly provable | Phase 6: ASSESS |
| `predecessor_deferral_seed_consistent_axiom` | SuccExistence.lean | Possibly provable | Phase 6: ASSESS |
| `predecessor_f_step_axiom` | SuccExistence.lean | Unaffected | Document as debt |
| `succ_chain_fam_p_step` | SuccChainFMCS.lean | Unaffected | Document as debt |
| `f_nesting_boundary` | SuccChainFMCS.lean | Unaffected | Document as debt |
| `p_nesting_boundary` | SuccChainFMCS.lean | Unaffected | Document as debt |

**Tasks**:
- [ ] Remove `axiom discreteImmediateSuccSeed_consistent_axiom` from DiscreteSuccSeed.lean
- [ ] Complete Case 2 proof in `discreteImmediateSuccSeed_consistent`:
  - Use T-axiom: `g_content(M) ⊆ M` now holds
  - Blocking formula `¬ψ ∨ ¬G(ψ)` derivable from `¬G(ψ) ∈ M`
  - Show seed consistency using closure properties
- [ ] Assess `discreteImmediateSucc_covers_axiom`: attempt proof via T-axiom
- [ ] Assess `successor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Assess `predecessor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Document remaining axioms as semantics-independent in code comments
- [ ] Run `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` to verify

**Timing**: 2 hours (expanded from 1.5)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` - Remove axiom, prove
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Assess/document axioms
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Document axioms

**Verification**:
- `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results
- `discreteImmediateSuccSeed_consistent` is a proven theorem
- All assessed axioms documented with reflexive semantics status

---

### Phase 7: Frame Class Simplification [NOT STARTED]

**Goal**: Simplify frame class architecture to reflect the collapse

**Context from Research**:
Under reflexive semantics, all four extension axioms become trivially valid:

| Axiom | Trivial Proof |
|-------|---------------|
| DN: `GGφ → Gφ` | Take `r = t` in `∀ s ≥ t, ∀ r ≥ s, φ(r)` |
| DF: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` | `s = t` witnesses `F(Hφ)` since `Hφ(t)` holds |
| SF: `Gφ → Fφ` | T-axiom: `φ(t)` witnesses `Fφ` |
| SP: `Hφ → Pφ` | T-axiom: `φ(t)` witnesses `Pφ` |

**Tasks**:
- [ ] Update `FrameClass` enum documentation to note all axioms are now Base
- [ ] Update `isDenseCompatible` predicate: all axioms return true (or simplify)
- [ ] Update `isDiscreteCompatible` predicate: all axioms return true (or simplify)
- [ ] Update `LogicVariants.lean`: note three-variant structure is now degenerate
- [ ] Consider: Add `-- REFLEXIVE SEMANTICS: DN/DF/SF/SP trivially valid` comments
- [ ] Update completeness theorem architecture if needed (may defer to later task)
- [ ] Run `lake build` on affected files

**Timing**: 1.5 hours (new phase)

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - FrameClass documentation
- `Theories/Bimodal/ProofSystem/LogicVariants.lean` - Degenerate structure note
- Possibly other files using frame class predicates

**Verification**:
- Frame class documentation reflects reflexive semantics reality
- `isDenseCompatible` / `isDiscreteCompatible` simplified or documented

---

### Phase 8: Documentation and Final Verification [NOT STARTED]

**Goal**: Update documentation, resolve conflicts, verify full build

**Tasks**:
- [ ] Update ROAD_MAP.md: confirm reflexive semantics is current (resolve Task 991 inconsistency)
- [ ] Update Truth.lean header docstring to describe reflexive semantics
- [ ] Update CanonicalIrreflexivity.lean docstring to describe antisymmetry approach
- [ ] Update CanonicalIrreflexivityAxiom.lean docstrings (remove T-axiom invalidity claims)
- [ ] Run full `lake build` to verify no regressions
- [ ] Grep for remaining `axiom` declarations to assess final axiom count
- [ ] Update TODO.md frontmatter with new axiom count
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `ROAD_MAP.md` - Resolve documentation conflict
- Various Lean files - Docstring updates
- `specs/TODO.md` - Axiom count

**Verification**:
- Full `lake build` succeeds
- `grep -r "^axiom" Theories/Bimodal/` shows expected remaining axioms only
- Documentation is consistent with implementation

## Task Pipeline After Task 29

Per research consensus (05_team-research.md):

| Task | Action | Rationale |
|------|--------|-----------|
| **Task 26** | Mark ABANDONED | Entirely superseded by Task 29 Phase 5 |
| **Task 18** | Deprioritize | Dense completeness collapses to base; TimelineQuot infra optional |
| **Task 24** | Reduce scope | Only `discrete_Icc_finite_axiom` and possibly `discreteImmediateSucc_covers_axiom` remain |
| **Task 22** | After (low priority) | `DirectMultiFamilyBFMCS` already deployed |
| **Task 997** | After | Resume with reflexive FMCS signatures |

## Testing & Validation

- [ ] Full `lake build` passes after each phase
- [ ] Phase 0: Enumeration report complete with replacement strategies
- [ ] Phase 5: `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results
- [ ] Phase 6: `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results
- [ ] Phase 8: `grep -r "^axiom" Theories/Bimodal/` shows only expected remaining axioms
- [ ] Phase 8: No new `sorry` introduced (verify via `grep -r "sorry" Theories/`)

## Artifacts & Outputs

- `specs/029_switch_to_reflexive_gh_semantics/reports/07_enumeration.md` - Phase 0 output
- Updated `Truth.lean` with reflexive semantics
- Updated `Axioms.lean` with T-axiom constructors
- Updated `FMCSDef.lean` with reflexive coherence
- Proven `canonicalR_reflexive` and `canonicalR_antisymmetric` theorems
- Proven `discreteImmediateSuccSeed_consistent` theorem
- Resolved ROAD_MAP.md documentation conflict
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/01_reflexive-semantics-summary.md`

## Rollback/Contingency

If significant issues arise:

1. Git revert to pre-implementation commit
2. Document blocking issues in errors.json
3. Consider two-pass approach (Option D from research):
   - Pass 1: Change semantics only, keep axiom temporarily
   - Pass 2: Remove axiom after verifying semantic change
4. If NoMaxOrder/NoMinOrder proofs prove intractable:
   - Consider alternative characterization via naming/blocking formula distinctness
   - Escalate to research for alternative proof strategies

The core semantic change (Phase 1) is the foundation; if it causes cascading failures, the Phase 0 enumeration should have identified all affected sites upfront. If Phase 5 takes significantly longer than 5 hours, consider splitting into sub-phases by file.
