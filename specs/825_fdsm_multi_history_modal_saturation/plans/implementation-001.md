# Implementation Plan: Task #825

- **Task**: 825 - FDSM Multi-History Modal Saturation
- **Status**: [PARTIAL]
- **Effort**: 12-16 hours
- **Dependencies**: None (builds on existing FDSM infrastructure)
- **Research Inputs**:
  - specs/825_fdsm_multi_history_modal_saturation/reports/research-001.md (Mathlib termination patterns)
  - specs/825_fdsm_multi_history_modal_saturation/reports/research-002.md (Gap analysis of task 816)
  - specs/816_bmcs_temporal_modal_coherence_strengthening/plans/implementation-003.md (Original Phase 4 specification)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan completes Phase 4 from implementation-003.md for task 816. The current single-history construction in Completeness.lean trivializes modal operators (Box phi = phi), which validates invalid modal principles as warned in research-013.md. This implementation replaces `fdsm_from_closure_mcs` with a proper multi-history saturated construction that ensures Diamond formulas have witness histories.

**Critical Problem (from research-002.md)**: The current FDSM uses a single-history construction where `Box psi = psi` for all psi. This collapses the modal dimension entirely, making the completeness proof semantically unsound. Every phase of this plan is essential; nothing can be deferred or skipped.

### Research Integration

From research-001.md (Mathlib patterns):
- Use fuel-based saturation with `maxHistories = 2^closureSize phi` bound
- Leverage `Finset.card_lt_card` for termination: strict subset implies cardinality increase
- Use `Finset.strongInduction` for well-founded recursion if needed

From research-002.md (Gap analysis):
- Phase 4 was entirely skipped in task 816
- `witness_set_consistent` has 2 sorries (lines 190, 212) that must be resolved
- `modal_backward_from_saturation` has sorry (line 280) that depends on saturation
- TruthLemma.lean has 13+ sorries that will resolve once saturation is complete

## Goals & Non-Goals

**Goals**:
- Implement `saturation_step` - one round of adding witness histories
- Implement `saturated_histories` - fixed-point construction via fuel
- Prove termination using 2^closureSize cardinality bound
- Prove `modal_saturated` property at fixed point
- Derive `modal_backward_from_saturation` via contrapositive
- Complete `witness_set_consistent` proof
- Update Completeness.lean to use multi-history construction
- Eliminate all sorries in the saturation path

**Non-Goals**:
- Fixing TruthLemma.lean sorries (follow-on task, depends on this work)
- Optimizing the construction for performance
- Changing the temporal saturation approach (already works with bounded time)
- Removing the single-history construction (keep as reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `witness_set_consistent` proof too complex | High | Medium | Break into smaller lemmas; use K axiom + necessitation explicitly |
| Termination proof requires noncomputable constructions | Medium | Low | Use Decidable instances on Finset; fuel-based approach is computable |
| Closure membership tracking pervasive | High | High | Create dedicated helper lemmas upfront; track through types |
| Multi-history construction breaks existing TruthLemma | Medium | Medium | Keep changes minimal; ensure interface compatibility |

> **WARNING**: Every phase in this plan is critical. The single-history construction is semantically broken. Do not defer any phase or mark any phase complete with sorries. Each sorry left behind perpetuates the modal trivialization bug.

## Implementation Phases

### Phase 1: Complete `witness_set_consistent` Proof [COMPLETED]

**Goal**: Prove that the witness set {psi} U {chi | Box chi in M} is consistent when M is an MCS containing Diamond psi. This is the foundational lemma for modal saturation.

**Tasks**:
- [ ] Read ModalSaturation.lean lines 121-212 to understand current state
- [ ] Implement K axiom distribution helper: `box_distribute_finite : Box (chi_1 -> ... -> chi_n -> psi) -> Box chi_1 -> ... -> Box chi_n -> Box psi`
- [ ] Implement necessitation on finite context: `necessitate_context : Gamma |- psi -> map Box Gamma |- Box psi`
- [ ] Complete Case 1 (line 192-212): L doesn't contain psi, derive Box bot contradiction
- [ ] Complete Case 2 (line 139-190): L contains psi, derive Box(neg psi) contradicting Diamond psi
- [ ] Verify `witness_set_consistent` compiles with no sorry

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` (lines 121-212)

**Verification**:
- Run `lake build Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`
- `grep -n "sorry" Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` shows no sorry in lines 121-212
- Use `lean_goal` at key positions to verify proof state

> **WARNING**: Do not mark this phase complete if any sorry remains in `witness_set_consistent`. This lemma is the foundation of modal saturation. A sorry here propagates to all downstream proofs.

---

### Phase 2: Implement Saturation Infrastructure [NOT STARTED]

**Goal**: Build the helper functions needed for the saturation fixed-point construction.

**Tasks**:
- [ ] Implement `unsatisfiedDiamonds`: Find diamond formulas in a history without witnesses
  ```lean
  def unsatisfiedDiamonds (phi : Formula) (hists : Finset (FDSMHistory phi))
      (h : FDSMHistory phi) (t : FDSMTime phi) : Finset Formula
  ```
- [ ] Implement `buildWitnessHistory`: Construct a witness history from a witness set
  ```lean
  noncomputable def buildWitnessHistory (phi : Formula) (h : FDSMHistory phi)
      (t : FDSMTime phi) (psi : Formula)
      (h_diamond : (Formula.neg (Formula.box (Formula.neg psi))) in (h.states t).toSet) :
      FDSMHistory phi
  ```
- [ ] Prove `buildWitnessHistory_satisfies_psi`: The built history contains psi at time t
- [ ] Prove `buildWitnessHistory_valid`: The built history satisfies temporal coherence constraints
- [ ] Implement `saturation_step`: One round of adding all missing witnesses
  ```lean
  def saturation_step (phi : Formula) (hists : Finset (FDSMHistory phi))
      (t : FDSMTime phi) : Finset (FDSMHistory phi)
  ```

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` (lines 287-330, extend)

**Verification**:
- All new definitions compile without sorry
- `buildWitnessHistory` produces valid FDSMHistory (temporal coherence)
- `saturation_step` is monotone (hists subseteq saturation_step hists)

> **WARNING**: `buildWitnessHistory` must produce a history that actually contains psi. Do not use placeholder constructions. Verify with `lean_goal` that the witness property holds.

---

### Phase 3: Implement Fixed-Point Construction with Termination [NOT STARTED]

**Goal**: Implement the saturation fixed-point that iterates until no more witnesses are needed, and prove it terminates.

**Tasks**:
- [ ] Implement `saturate_with_fuel`: Fuel-based iteration
  ```lean
  def saturate_with_fuel (phi : Formula) (hists : Finset (FDSMHistory phi))
      (t : FDSMTime phi) (fuel : Nat) : Finset (FDSMHistory phi) :=
    match fuel with
    | 0 => hists
    | fuel + 1 =>
        let hists' := saturation_step phi hists t
        if hists' = hists then hists
        else saturate_with_fuel phi hists' t fuel
  ```
- [ ] Implement `saturated_histories`: Entry point with maxHistories fuel
  ```lean
  noncomputable def saturated_histories (phi : Formula) (h_cons : SetConsistent {phi})
      (t : FDSMTime phi) : Finset (FDSMHistory phi)
  ```
- [ ] Prove `saturation_step_monotone`: `hists subseteq saturation_step hists`
- [ ] Prove `saturation_step_card_increase`: If not fixed point, card increases by at least 1
- [ ] Prove `saturation_terminates`: Fixed point reached in at most maxHistories steps
  ```lean
  theorem saturation_terminates (phi : Formula) (hists : Finset (FDSMHistory phi))
      (h_sub : hists.card <= maxHistories phi) :
      exists n <= maxHistories phi - hists.card,
        saturation_step^[n] hists = saturation_step^[n+1] hists
  ```

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Verification**:
- `saturated_histories` compiles and terminates (no stack overflow)
- Termination proof uses `maxHistories = 2^closureSize phi` bound
- `lean_goal` confirms proof state at termination lemma

> **WARNING**: The termination proof is essential for the fixed-point to be valid. Do not use `sorry` or `decreasing_by sorry`. If termination is difficult, use explicit fuel with a decreasing measure on `maxHistories - hists.card`.

---

### Phase 4: Prove Modal Saturation Property [NOT STARTED]

**Goal**: Prove that the fixed point of saturation has the modal_saturated property required by FDSM.

**Tasks**:
- [ ] Define `is_modally_saturated` predicate on Finset (FDSMHistory phi)
  ```lean
  def is_modally_saturated (phi : Formula) (hists : Finset (FDSMHistory phi))
      (t : FDSMTime phi) : Prop :=
    forall h in hists, forall psi in closure phi,
      (Formula.neg (Formula.box (Formula.neg psi))) in (h.states t).toSet ->
      exists h' in hists, psi in (h'.states t).toSet
  ```
- [ ] Prove `fixed_point_is_saturated`:
  ```lean
  theorem fixed_point_is_saturated (phi : Formula) (hists : Finset (FDSMHistory phi))
      (t : FDSMTime phi)
      (h_fixed : saturation_step phi hists t = hists) :
      is_modally_saturated phi hists t
  ```
- [ ] Prove `saturated_histories_saturated`:
  ```lean
  theorem saturated_histories_saturated (phi : Formula) (h_cons : SetConsistent {phi})
      (t : FDSMTime phi) :
      is_modally_saturated phi (saturated_histories phi h_cons t) t
  ```

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Verification**:
- `fixed_point_is_saturated` compiles without sorry
- The proof is by contrapositive: if not saturated, saturation_step would add witnesses
- `lean_goal` confirms proof structure at key steps

> **WARNING**: The fixed point property is the key bridge between construction and semantics. Without it, `modal_backward` cannot be derived. Verify each step carefully.

---

### Phase 5: Derive modal_backward from Saturation [PARTIAL]

**Goal**: Prove `modal_backward_from_saturation` using the saturation property via contrapositive.

**Tasks**:
- [ ] Complete `modal_backward_from_saturation` (currently has sorry at line 280)
- [ ] The proof structure is:
  1. Contrapositive: assume Box psi not in h.states t
  2. By MCS negation completeness: (Box psi).neg in h.states t
  3. This is Diamond (neg psi) after unfolding
  4. By modal saturation: exists h' where (neg psi) holds
  5. But h_all says psi holds in ALL histories
  6. Contradiction: psi and neg psi in same history h'
- [ ] Prove auxiliary lemma `box_neg_iff_diamond`:
  ```lean
  theorem box_neg_iff_diamond (psi : Formula) :
      (Formula.box psi).neg = Formula.neg (Formula.box (Formula.neg (Formula.neg psi)))
  ```
- [ ] Handle closure membership tracking for Box psi

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` (line 269-280)

**Verification**:
- `modal_backward_from_saturation` compiles without sorry
- The proof uses `is_modally_saturated` or the model's `modal_saturated` field
- Test with `lean_goal` that the contrapositive structure works

> **WARNING**: This is the critical theorem that fixes the modal trivialization bug. The single-history construction has Box psi = psi, which is wrong. This proof must use the multi-history saturation to work correctly.

---

### Phase 6: Update Completeness.lean to Use Multi-History Construction [NOT STARTED]

**Goal**: Replace the single-history `fdsm_from_closure_mcs` with a multi-history construction using `saturated_histories`.

**Tasks**:
- [ ] Create `fdsm_from_saturated_histories`:
  ```lean
  noncomputable def fdsm_from_saturated_histories (phi : Formula) (S : Set Formula)
      (h_mcs : ClosureMaximalConsistent phi S) : FiniteDynamicalSystemModel phi where
    histories := saturated_histories phi (closure_mcs_consistent h_mcs) (BoundedTime.origin _)
    nonempty := ... -- Initial history exists
    modal_saturated := saturated_histories_saturated ...
    eval_history := initial_history_from_mcs phi S h_mcs
    eval_history_mem := ...
  ```
- [ ] Prove `initial_history_in_saturated`: The initial history from MCS is in saturated_histories
- [ ] Update `fdsm_completeness_contrapositive` to use `fdsm_from_saturated_histories`
- [ ] Verify `fdsm_internal_completeness` still holds with new construction
- [ ] Keep `fdsm_from_closure_mcs` as a deprecated reference (add comment)

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean`

**Verification**:
- New construction compiles without sorry
- Completeness theorem (`fdsm_internal_completeness`) still compiles
- The `modal_saturated` field now uses proper saturation, not trivial single-history

> **WARNING**: This phase changes the core construction. Test thoroughly that existing theorems still hold. The interface should remain compatible with TruthLemma.lean.

---

### Phase 7: Verification and Sorry Audit [NOT STARTED]

**Goal**: Verify all sorries are eliminated and the construction is mathematically sound.

**Tasks**:
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/FDSM/` and list remaining sorries
- [ ] Categorize sorries:
  - Eliminated by this task (should be 0 after phases 1-6)
  - Pre-existing in TruthLemma.lean (out of scope, follow-on task)
  - Pre-existing in Core.lean (out of scope, follow-on task)
- [ ] Verify `lake build Theories/Bimodal/Metalogic/FDSM/` succeeds
- [ ] Document any sorries that remain with justification
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to modify**:
- `specs/825_fdsm_multi_history_modal_saturation/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- All sorries in ModalSaturation.lean are eliminated
- All sorries in Completeness.lean (related to modal_saturated) are eliminated
- Build succeeds with no errors

> **WARNING**: Do not mark the task complete if sorries remain in the saturation path. The goal is zero sorries in the new multi-history construction. Pre-existing sorries in TruthLemma.lean are acceptable as they are out of scope.

---

## Testing & Validation

- [ ] `lake build Theories/Bimodal/Metalogic/FDSM/` passes with no errors
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` returns no matches
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/FDSM/Completeness.lean` shows only pre-existing sorries in non-modal-saturation code
- [ ] New `fdsm_from_saturated_histories` construction produces FDSM with multiple histories
- [ ] `modal_backward_from_saturation` is proven without sorry
- [ ] `witness_set_consistent` is proven without sorry
- [ ] Completeness theorem still type-checks and proves

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Updated with complete Phase 4 implementation
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Updated to use multi-history construction
- `specs/825_fdsm_multi_history_modal_saturation/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If the multi-history construction proves too complex:

1. **Preserve existing code**: Keep `fdsm_from_closure_mcs` as the current implementation
2. **Document the limitation**: Note that single-history trivializes modal semantics
3. **Create follow-on task**: Break remaining work into smaller sub-tasks
4. **Partial progress**: Commit phases that complete successfully (each phase is independently valuable)

**Critical Path Analysis**: Phases 1-5 are the essential mathematical work. Phase 6 integrates with Completeness.lean. Phase 7 is verification. If blocked on any phase, commit partial progress and document the blocking issue.

## Mathematical Summary

### Why Multi-History Saturation is Essential

| Aspect | Single-History (Current) | Multi-History (This Plan) |
|--------|-------------------------|---------------------------|
| Box semantics | Box psi = psi (trivial) | Box psi = psi at ALL histories |
| Diamond semantics | Diamond psi = psi (trivial) | Diamond psi = psi at SOME history |
| Valid principles | Validates Box psi <-> psi (WRONG) | Correct modal logic |
| Saturation | Trivially satisfied | Requires explicit witness construction |

### Key Theorems in Dependency Order

```
witness_set_consistent (Phase 1)
    |
    v
buildWitnessHistory (Phase 2)
    |
    v
saturation_step (Phase 2)
    |
    v
saturate_with_fuel / saturated_histories (Phase 3)
    |
    +---> saturation_terminates (Phase 3)
    |
    +---> fixed_point_is_saturated (Phase 4)
              |
              v
         modal_backward_from_saturation (Phase 5)
              |
              v
         fdsm_from_saturated_histories (Phase 6)
              |
              v
         fdsm_internal_completeness (Phase 6)
```

### Termination Bound Justification

- Each FDSMHistory is a function from FDSMTime (finite) to FDSMWorldState (finite)
- At most `2^closureSize phi` distinct world states
- Therefore at most `2^closureSize phi` distinct constant histories
- Saturation step either adds at least one new history or is at fixed point
- Termination in at most `2^closureSize phi` steps
