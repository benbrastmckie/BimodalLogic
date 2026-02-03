# Implementation Plan: Task #825 (Revised)

- **Task**: 825 - FDSM Multi-History Modal Saturation
- **Status**: [PLANNED]
- **Version**: 002 (revised from 001)
- **Effort**: 8-12 hours (reduced by simplifying approach)
- **Dependencies**: None (builds on existing FDSM infrastructure)
- **Research Inputs**:
  - specs/825_fdsm_multi_history_modal_saturation/reports/research-001.md (Mathlib patterns)
  - specs/825_fdsm_multi_history_modal_saturation/reports/research-002.md (Gap analysis)
  - specs/825_fdsm_multi_history_modal_saturation/reports/research-003.md (Blocker analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**Previous Plan (v001)**: 7 phases focused on completing the abstract `saturation_step` approach. Got stuck because `FDSMHistory` values don't carry MCS information needed for witness construction.

**This Plan (v002)**: 6 phases that:
1. **Archive broken single-history code** to Boneyard/ with explanatory comments
2. **Restructure around MCSTrackedHistory** which tracks MCS origin
3. **Add closure membership infrastructure** to unblock TruthLemma
4. **Simplify saturation** by working directly with tracked histories

**Key Insight from research-003.md**: The single-history model makes `Box psi = psi`, validating invalid principles. It cannot be fixed without multi-history saturation. The abstract saturation on untracked histories is architecturally flawed.

## Overview

The fundamental problem: FDSM completeness requires modal saturation, but the current construction has two broken approaches:
1. **Single-history** (`fdsm_from_closure_mcs`): Makes Box psi = psi (WRONG)
2. **Abstract saturation** (`saturation_step`): Operates on histories without MCS info

This plan:
1. Archives the broken single-history code with documentation
2. Builds modal saturation exclusively via `MCSTrackedHistory`
3. Provides the `DecidableEq` and helper infrastructure needed
4. Produces a semantically correct multi-history FDSM

## Goals & Non-Goals

**Goals**:
- Archive `fdsm_from_closure_mcs` to Boneyard/ with comments explaining why it's broken
- Implement `DecidableEq` for `MCSTrackedHistory` via classical decidability
- Rewrite saturation to operate on `Finset (MCSTrackedHistory phi)`
- Prove modal saturation for MCS-tracked construction
- Update Completeness.lean to use the tracked construction
- Build closure membership helper lemmas

**Non-Goals**:
- Fixing all TruthLemma.lean sorries (follow-on task)
- Keeping the single-history approach as an alternative
- Preserving backward compatibility with broken code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Classical `DecidableEq` causes issues | Medium | Low | Use `Classical.dec` pattern consistently |
| Projection from tracked to untracked histories complex | Medium | Medium | Design clean projection function early |
| Completeness proof needs restructuring | High | Medium | Keep interface minimal; wrap new construction |
| Build errors from archiving | Low | Low | Update all imports before archiving |

## Implementation Phases

### Phase 1: Archive Single-History Construction to Boneyard [NOT STARTED]

**Goal**: Move the broken `fdsm_from_closure_mcs` and related code to `Theories/Boneyard/` with documentation explaining why it trivializes modal operators.

**Why This Matters**: The single-history construction makes `Box psi = psi` for all psi. This:
- Validates `Box psi <-> psi` (WRONG - not a theorem of modal logic)
- Validates `Diamond psi <-> psi` (WRONG)
- Makes the completeness proof semantically unsound
- Predicts theorems where there are none

**Tasks**:
- [ ] Create `Theories/Boneyard/FDSM_SingleHistory/` directory
- [ ] Move `fdsm_from_closure_mcs` definition and related theorems
- [ ] Add detailed header comment explaining:
  ```
  /-!
  # ARCHIVED: Single-History FDSM Construction

  This code was archived because the single-history approach trivializes
  modal operators, making Box psi ≡ psi for all psi.

  ## Why This Is Wrong

  In a single-history model:
  - Box psi means "psi holds at all histories" = "psi holds at the one history" = psi
  - Diamond psi means "psi holds at some history" = "psi holds at the one history" = psi

  This validates invalid principles:
  - ⊢ Box psi ↔ psi (NOT a theorem of modal logic!)
  - ⊢ Diamond psi ↔ psi (NOT a theorem!)

  The completeness proof using this construction "proves" that any formula
  valid in all single-history FDSM models is provable. But single-history
  models satisfy EXTRA principles (Box ↔ id), so this proves nothing useful.

  ## Correct Approach

  See `Bimodal.Metalogic.FDSM.ModalSaturation` for the multi-history
  construction that properly handles modal saturation.
  -/
  ```
- [ ] Update imports in Completeness.lean (remove dependency on archived code)
- [ ] Ensure `lake build` still passes

**Files to modify**:
- Create `Theories/Boneyard/FDSM_SingleHistory/Core.lean`
- Update `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` (remove single-history construction)

**Verification**:
- Archived code compiles in Boneyard/
- Main FDSM module no longer references single-history construction
- `lake build` passes

---

### Phase 2: Implement DecidableEq for MCSTrackedHistory [NOT STARTED]

**Goal**: Add the type class instances needed for `MCSTrackedHistory` to work with `Finset`.

**Tasks**:
- [ ] Add classical `DecidableEq` for `MCSTrackedHistory`:
  ```lean
  noncomputable instance mcsTrackedHistory_decidableEq (phi : Formula) :
      DecidableEq (MCSTrackedHistory phi) :=
    Classical.decEq
  ```
- [ ] Add `Fintype` instance for `MCSTrackedHistory`:
  ```lean
  noncomputable instance mcsTrackedHistory_fintype (phi : Formula) :
      Fintype (MCSTrackedHistory phi) :=
    Fintype.ofFinite _
  ```
- [ ] Prove `MCSTrackedHistory` is finite (follows from FDSMHistory being finite)
- [ ] Add projection function:
  ```lean
  def MCSTrackedHistory.toHistory (th : MCSTrackedHistory phi) : FDSMHistory phi :=
    th.history
  ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Verification**:
- `Finset (MCSTrackedHistory phi)` compiles
- `Finset.univ : Finset (MCSTrackedHistory phi)` exists

---

### Phase 3: Implement MCS-Tracked Saturation Step [NOT STARTED]

**Goal**: Rewrite saturation to operate directly on MCS-tracked histories, eliminating the gap between abstract histories and constructible witnesses.

**Tasks**:
- [ ] Define `tracked_saturation_step`:
  ```lean
  noncomputable def tracked_saturation_step (phi : Formula)
      (hists : Finset (MCSTrackedHistory phi))
      (t : FDSMTime phi) : Finset (MCSTrackedHistory phi) :=
    hists ∪ (Finset.univ.filter (fun th' => TrackedIsWitnessFor phi hists t th'))
  ```
- [ ] Define `TrackedIsWitnessFor` predicate (can access MCS directly!)
- [ ] Prove `tracked_saturation_step_subset`: monotonicity
- [ ] Prove `tracked_saturation_step_nonempty`: preservation
- [ ] Prove `tracked_saturation_step_card_increase`: cardinality grows at non-fixed-point

**Key Advantage**: Unlike the old `IsWitnessFor`, `TrackedIsWitnessFor` can directly:
1. Check if Diamond psi ∈ th.mcs
2. Build witness via `buildMCSTrackedWitness`
3. All information needed is carried in the tracked history

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Verification**:
- All tracked saturation lemmas compile without sorry
- The construction is well-typed on `Finset (MCSTrackedHistory phi)`

---

### Phase 4: Prove Modal Saturation for Tracked Histories [NOT STARTED]

**Goal**: Prove that the fixed point of tracked saturation is modally saturated.

**Tasks**:
- [ ] Define `tracked_saturate_with_fuel`:
  ```lean
  noncomputable def tracked_saturate_with_fuel (phi : Formula)
      (hists : Finset (MCSTrackedHistory phi))
      (t : FDSMTime phi) (fuel : Nat) : Finset (MCSTrackedHistory phi)
  ```
- [ ] Define `tracked_saturated_histories_from`
- [ ] Prove `tracked_fixed_point_is_saturated`:
  ```lean
  theorem tracked_fixed_point_is_saturated (phi : Formula)
      (hists : Finset (MCSTrackedHistory phi))
      (t : FDSMTime phi)
      (h_fixed : tracked_saturation_step phi hists t = hists) :
      ∀ th ∈ hists, ∀ psi (h_clos : psi ∈ closure phi),
        Formula.neg (Formula.box (Formula.neg psi)) ∈ th.mcs →
        ∃ th' ∈ hists, (th'.history.states t).models psi h_clos
  ```
- [ ] The proof now works because we can construct witnesses from MCS info!

**Key Insight**: At a fixed point, if Diamond psi ∈ th.mcs and no witness exists, then `buildMCSTrackedWitness th psi` would add one, contradicting fixed point. But now we CAN construct that witness because th carries its MCS.

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`

**Verification**:
- `tracked_fixed_point_is_saturated` compiles without sorry
- The contrapositive proof successfully constructs witnesses

---

### Phase 5: Build FDSM from Tracked Saturation [NOT STARTED]

**Goal**: Create the complete FDSM construction that:
1. Starts with an MCS-tracked initial history
2. Saturates to get all witnesses
3. Projects to FDSMHistory for the final model

**Tasks**:
- [ ] Define `fdsm_from_tracked_saturation`:
  ```lean
  noncomputable def fdsm_from_tracked_saturation (phi : Formula) (S : Set Formula)
      (h_mcs : ClosureMaximalConsistent phi S) : FiniteDynamicalSystemModel phi where
    histories := (tracked_saturated_histories_from phi
        {mcsTrackedHistory_from_mcs phi (lindenbaum_extension S) ...}
        (BoundedTime.origin _)).image MCSTrackedHistory.toHistory
    nonempty := ...
    modal_saturated := ... -- Uses tracked_fixed_point_is_saturated
    eval_history := ...
    eval_history_mem := ...
  ```
- [ ] Prove `modal_saturated` field using tracked saturation property
- [ ] Prove initial history is in saturated set
- [ ] Update Completeness.lean to use new construction

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean`
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean`

**Verification**:
- New FDSM construction compiles
- `fdsm_completeness_contrapositive` works with new construction
- `lake build` passes with no new sorries in saturation path

---

### Phase 6: Closure Membership Infrastructure [NOT STARTED]

**Goal**: Add helper lemmas for closure membership that unblock TruthLemma.lean sorries.

**Tasks**:
- [ ] Prove `closure_neg_in_closureWithNeg`:
  ```lean
  theorem closure_neg_in_closureWithNeg (phi psi : Formula)
      (h : psi ∈ closure phi) : psi.neg ∈ closureWithNeg phi
  ```
- [ ] Prove `closure_imp_components`:
  ```lean
  theorem closure_imp_components (phi psi chi : Formula)
      (h : Formula.imp psi chi ∈ closure phi) :
      psi ∈ closureWithNeg phi ∧ chi ∈ closureWithNeg phi
  ```
- [ ] Prove `closure_box_inner`:
  ```lean
  theorem closure_box_inner (phi psi : Formula)
      (h : Formula.box psi ∈ closure phi) : psi ∈ closure phi
  ```
- [ ] Prove `mcs_classical_equiv`:
  ```lean
  theorem mcs_classical_equiv (S : Set Formula) (h_mcs : SetMaximalConsistent S)
      (psi chi : Formula) (h_equiv : ⊢ psi.iff chi) (h_in : psi ∈ S) :
      chi ∈ S
  ```
- [ ] Use these to resolve TruthLemma.lean closure bookkeeping sorries

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` (add closure lemmas)
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` (add mcs_classical_equiv)
- `Theories/Bimodal/Metalogic/FDSM/TruthLemma.lean` (use new lemmas)

**Verification**:
- New closure lemmas compile
- TruthLemma.lean sorry count decreases
- `lake build` passes

---

## Preserved Work from v001

The following completed work from v001 is retained:
- Phase 1 (v001): `witness_set_consistent` - COMPLETED
- Phase 2 (v001): `buildWitnessHistory`, `buildWitnessHistory_models_psi` - COMPLETED
- Phase 3 (v001): `saturate_with_fuel` structure - RETAINED (will be renamed to tracked version)
- `MCSTrackedHistory` structure - RETAINED and extended
- `buildMCSTrackedWitness`, `buildMCSTrackedWitness_models` - RETAINED

## Deprecated Work

The following is being archived/removed:
- `saturation_step` on untracked `Finset (FDSMHistory phi)` - cannot construct witnesses
- `fdsm_from_closure_mcs` - trivializes modal operators
- `IsWitnessFor` predicate on untracked histories - unusable without MCS info

## Testing & Validation

- [ ] `lake build Theories/Bimodal/Metalogic/FDSM/` passes
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` shows only expected sorries (termination, at most)
- [ ] Single-history code successfully archived to Boneyard/
- [ ] New FDSM construction produces multiple histories (verifiable by inspection)
- [ ] Completeness proof uses new construction

## Artifacts & Outputs

- `Theories/Boneyard/FDSM_SingleHistory/Core.lean` - Archived broken construction with documentation
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - MCS-tracked saturation
- `Theories/Bimodal/Metalogic/FDSM/Completeness.lean` - Updated to use tracked construction
- `specs/825_fdsm_multi_history_modal_saturation/summaries/implementation-summary-*.md`

## Summary of Changes from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Single-history code | Keep as deprecated | Archive to Boneyard with documentation |
| Saturation base type | `Finset (FDSMHistory phi)` | `Finset (MCSTrackedHistory phi)` |
| DecidableEq | Missing | Added via Classical.decEq |
| MCS tracking | Partial (structure exists) | Full integration |
| Closure infra | Not addressed | New phase added |
| Phase count | 7 | 6 |
| Approach | Fix abstract saturation | Rebuild on tracked histories |
