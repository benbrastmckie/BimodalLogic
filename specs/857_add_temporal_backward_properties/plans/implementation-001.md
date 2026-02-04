# Implementation Plan: Task #857 - Zero-Axiom Temporal Backward Properties

- **Task**: 857 - Add temporal_backward_G and temporal_backward_H properties to IndexedMCSFamily
- **Status**: [IMPLEMENTING]
- **Effort**: 40-55 hours
- **Dependencies**: Task 856 (EvalCoherent pattern reference)
- **Research Inputs**: specs/857_add_temporal_backward_properties/reports/research-004.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan implements a zero-axiom path for temporal backward properties in TruthLemma.lean. The current sorries at lines 387 and 400 cannot be proven with constant IndexedMCSFamily because "phi at all times" collapses to "phi in M" which does not imply "G phi in M". The solution requires time-varying MCS construction with temporal saturation, where F formulas have witness times.

### Research Integration

Integrated from research-004.md:
- **Key insight**: Temporal backward needs witness TIMES, not witness FAMILIES (unlike modal backward)
- **Construction pattern**: TemporalCoherentFamily with forward_F/backward_P properties
- **Proof strategy**: Contraposition via MCS maximality, using temporal duality
- **Critical theorem**: F-witness seed consistency (analogous to diamond_boxcontent_consistent)

## Goals & Non-Goals

**Goals**:
- Eliminate sorries at TruthLemma.lean lines 387 and 400
- Achieve zero axioms in the temporal backward proofs
- Build reusable infrastructure for temporal saturation
- Follow task 856's proven patterns where applicable

**Non-Goals**:
- Unifying modal and temporal saturation (future work)
- Optimizing for performance
- Modifying existing axiom-based code paths (preserved for reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Temporal duality not provable | High | Low | Definitional: some_future = neg(all_future(neg phi)) |
| F-witness seed inconsistent | High | Medium | Careful K-distribution chain proof, following 856 pattern |
| Time domain constraints | Medium | Low | Linear order suffices; verify exists s > t |
| Interaction with modal saturation | Medium | Low | Operate on different dimensions; should compose cleanly |
| Proof complexity exceeds estimate | Medium | Medium | Break into smaller lemmas; checkpoint progress frequently |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in TruthLemma.lean:
  - Line 387: `temporal_backward_G` - all_future (G) backward direction
  - Line 400: `temporal_backward_H` - all_past (H) backward direction

### Expected Resolution
- Phase 4 proves temporal_backward_G from forward_F property
- Phase 4 proves temporal_backward_H from backward_P property (symmetric)
- Phase 5 integrates into TruthLemma.lean, eliminating both sorries

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in temporal backward proofs
- TruthLemma completeness proof becomes fully structural
- No new axiom dependencies introduced

## Axiom Characterization

### Pre-existing Axioms
- None directly in scope. This task addresses sorries, not axioms.
- Reference: `singleFamily_modal_backward_axiom` in Construction.lean (different concern)

### Expected Resolution
- Zero-axiom target: all proofs use structural construction and MCS properties
- No axioms used or introduced

### New Axioms
- NEVER. The user constraint explicitly prohibits ANY axioms or sorries in the final result.

### Remaining Debt
After this implementation:
- 0 axioms in temporal saturation module
- Publication-ready without axiom disclosure

## Implementation Phases

### Phase 1: Temporal Duality Infrastructure [IN PROGRESS]

**Goal**: Establish lemmas for transforming negated temporal operators in MCS context.

**Tasks**:
- [ ] Prove `neg_all_future_eq_some_future_neg`: If neg(G phi) in MCS, then F(neg phi) in MCS
- [ ] Prove `neg_all_past_eq_some_past_neg`: If neg(H phi) in MCS, then P(neg phi) in MCS
- [ ] Verify these follow from definitions: `some_future phi = neg(all_future(neg phi))`
- [ ] Create helper lemma for double negation in MCS: neg(neg phi) in MCS iff phi in MCS
- [ ] Document how MCS maximality enables the duality transform

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - add temporal duality lemmas

**Verification**:
- `lake build` passes
- All new lemmas compile without sorry

---

### Phase 2: GContent and TemporalWitnessSeed Definitions [NOT STARTED]

**Goal**: Define the temporal analog of BoxContent for G formulas.

**Tasks**:
- [ ] Define `GContent (fam : IndexedMCSFamily D)` = {chi | exists t, G chi in fam.mcs t}
- [ ] Define `GContentAt (fam : IndexedMCSFamily D) (t : D)` = {chi | G chi in fam.mcs t}
- [ ] Prove `GContentAt_subset_GContent`: At-specific is subset of spanning
- [ ] Define `TemporalWitnessSeed (base : IndexedMCSFamily D) (phi : Formula) (t : D)` = {phi} union GContent(base)
- [ ] Prove `phi_mem_TemporalWitnessSeed`: phi is in its own seed
- [ ] Prove `GContent_subset_TemporalWitnessSeed`: GContent included in seed
- [ ] For constant families: prove `constant_family_GContent_eq_GContentAt`

**Timing**: 4-6 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (new file)

**Verification**:
- New file compiles with `lake build`
- Definitions mirror task 856's BoxContent/WitnessSeed structure

---

### Phase 3: F-Witness Seed Consistency [NOT STARTED]

**Goal**: Prove that if F phi in base.mcs t for a constant family, then {phi} union GContent(base) is consistent.

**Tasks**:
- [ ] State theorem `temporal_witness_seed_consistent_constant`:
  ```lean
  theorem temporal_witness_seed_consistent_constant (base : IndexedMCSFamily D)
      (h_const : IsConstantFamily base) (phi : Formula) (t : D)
      (h_F : Formula.some_future phi in base.mcs t) :
      SetConsistent (TemporalWitnessSeed base phi t)
  ```
- [ ] Prove by contradiction assuming inconsistency
- [ ] Use finite subset property: exists finite L subset seed deriving bot
- [ ] Apply temporal K-distribution chain argument
- [ ] Show F(phi and bigwedge GContent) derivable from base
- [ ] Derive contradiction with MCS consistency
- [ ] Create supporting lemmas for temporal K-distribution as needed

**Timing**: 12-18 hours (critical path)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification**:
- Core theorem compiles without sorry
- Proof follows established modal K-distribution pattern from task 856

---

### Phase 4: TemporalCoherentFamily Structure and Backward Lemmas [NOT STARTED]

**Goal**: Define structure with forward_F/backward_P and prove temporal_backward_G/H.

**Tasks**:
- [ ] Define `TemporalCoherentFamily` structure:
  ```lean
  structure TemporalCoherentFamily (D : Type*) [...] where
    fam : IndexedMCSFamily D
    forward_F : forall t phi, Formula.some_future phi in fam.mcs t ->
                exists s, t < s and phi in fam.mcs s
    backward_P : forall t phi, Formula.some_past phi in fam.mcs t ->
                 exists s, s < t and phi in fam.mcs s
  ```
- [ ] Prove `temporal_backward_G`:
  ```lean
  lemma temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (phi : Formula)
      (h_all : forall s, t <= s -> phi in fam.fam.mcs s) :
      Formula.all_future phi in fam.fam.mcs t
  ```
  - By contraposition: assume G phi not in MCS
  - By MCS maximality: neg(G phi) in MCS
  - By temporal duality (Phase 1): F(neg phi) in MCS
  - By forward_F: exists s > t with neg phi in MCS at s
  - But phi in MCS at s (by h_all), contradiction
- [ ] Prove `temporal_backward_H` symmetrically using backward_P
- [ ] Construct `TemporalCoherentFamily` instance from consistent context (non-constructive via Choice)

**Timing**: 8-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

**Verification**:
- Structure compiles
- Both backward lemmas proven without sorry
- No axioms used

---

### Phase 5: Integration with TruthLemma [NOT STARTED]

**Goal**: Eliminate the sorries in TruthLemma.lean using the new infrastructure.

**Tasks**:
- [ ] Update BMCS structure or create temporal-aware variant that uses TemporalCoherentFamily
- [ ] Modify TruthLemma.lean line 387:
  - Replace sorry with call to temporal_backward_G
  - Ensure fam is TemporalCoherentFamily or has equivalent property
- [ ] Modify TruthLemma.lean line 400:
  - Replace sorry with call to temporal_backward_H
- [ ] Verify full truth lemma compiles without sorry
- [ ] Run `lake build` on entire Bimodal module
- [ ] Verify no new axioms introduced with `grep -r "axiom" Theories/Bimodal/`

**Timing**: 6-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - remove sorries
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - update to use temporal saturation
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - possibly extend structure

**Verification**:
- `lake build` passes
- `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns no matches
- `grep "^axiom" Theories/Bimodal/Metalogic/Bundle/*.lean` returns no new axioms

---

### Phase 6: Documentation and Cleanup [NOT STARTED]

**Goal**: Document the construction and ensure code quality.

**Tasks**:
- [ ] Add module docstring to TemporalCoherentConstruction.lean explaining approach
- [ ] Document relationship to task 856's EvalCoherent pattern
- [ ] Add inline comments for complex proof steps
- [ ] Verify all theorems have meaningful names following Lean conventions
- [ ] Create implementation summary

**Timing**: 2-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - documentation
- `specs/857_add_temporal_backward_properties/summaries/implementation-summary-YYYYMMDD.md` - summary

**Verification**:
- Code review for clarity
- Documentation complete

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` returns empty
- [ ] `grep "^axiom" Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` returns empty
- [ ] Run existing tests if any exist for Bimodal module
- [ ] Manual review of temporal_backward_G and temporal_backward_H proofs for correctness

## Artifacts & Outputs

- `specs/857_add_temporal_backward_properties/plans/implementation-001.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (new file)
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (modified - sorries removed)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (modified - temporal duality lemmas)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (modified - temporal integration)
- `specs/857_add_temporal_backward_properties/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation encounters insurmountable issues:
1. Preserve all partial progress in TemporalCoherentConstruction.lean
2. Document blocking issue in error report
3. Keep existing axiom-based code path unchanged as fallback
4. Consider alternative approaches:
   - Combined modal-temporal saturation construction
   - Weaker form of temporal coherence
5. If Phase 3 (seed consistency) fails, re-evaluate mathematical approach before continuing

**Git strategy**: Commit after each phase completion with `task 857 phase N: {name}` format. This enables rollback to any phase if needed.
