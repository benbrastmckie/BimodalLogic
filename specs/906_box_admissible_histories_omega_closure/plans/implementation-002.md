# Implementation Plan: Task #906 (Revised)

- **Task**: 906 - Box Admissible Histories Omega Closure
- **Version**: 002 (revised based on research-001.md findings)
- **Status**: [NOT STARTED]
- **Effort**: 9 hours (revised up from 8)
- **Dependencies**: None
- **Research Inputs**:
  - specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-004.md
  - specs/906_box_admissible_histories_omega_closure/reports/research-001.md (plan review)
- **Type**: lean
- **Lean Intent**: true

## Overview

Modify the semantic framework so that Box quantifies over a designated set of admissible histories (Omega), matching the JPL paper's specification. This implements **Choice B**: non-constant families with time-indexed truth lemma (`fam.mcs t` at time `t`).

### Key Design Decisions (from research-001.md)

1. **Validity uses Set.univ**: `valid` and `semantic_consequence` use `Omega = Set.univ` (unchanged signatures). Only `truth_at` and `satisfiable` gain explicit Omega parameter.

2. **canonicalOmega is NOT shift-closed**: Defined as `{ sigma | exists fam hfam, sigma = canonicalHistory B fam hfam }` without shift-closure. Shift-closure is only needed for soundness (which uses Set.univ, trivially shift-closed).

3. **Remove all constant-family infrastructure**: No more `IsConstantFamilyBMCS`, `getConstantBMCS`, or `h_const` parameters. Use `construct_saturated_bmcs_int` directly.

4. **Truth lemma anchor**: The atom case with time-varying states (`states t` wraps `fam.mcs t`) is the design anchor. All other cases follow.

## Goals & Non-Goals

**Goals**:
- Add Omega parameter to `truth_at` (Box case quantifies over sigma in Omega)
- Update `satisfiable` to existentially quantify over Omega
- Keep `valid`/`semantic_consequence` using `Set.univ` (no signature change)
- Define `ShiftClosed` predicate and prove `Set.univ` is shift-closed
- Update `time_shift_preserves_truth` with Omega + ShiftClosed hypothesis
- Update soundness proofs with Set.univ Omega (MF/TF use trivial shift-closure)
- Remove constant-family infrastructure from Representation.lean
- Redefine canonical history to use time-varying states (`fam.mcs t` at time `t`)
- Define `canonicalOmega` as set of (unshifted) canonical histories
- Fix truth lemma Box forward case (line 229 sorry)

**Non-Goals**:
- Changing the proof system (Axiom, DerivationTree)
- Modifying formula syntax
- Rewriting temporal operator semantics (only Box changes)
- Adding shift-closure to canonicalOmega (not needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large scope of type signature changes | High | High | Phase incrementally; commit after each phase |
| SoundnessLemmas.lean has 35+ theorems | High | Certain | Budget extra time; mechanical changes |
| Time-varying states change atom case | Medium | Low | Atom case is actually simpler with new design |
| Downstream modules may break | Medium | High | Build frequently; fix compilation errors before next phase |

## Sorry Characterization

### Pre-existing Sorries (Target)
- Line 229 in Representation.lean: Box forward case of truth lemma
- Line 95 in Representation.lean: `constant_family_bmcs_exists_int`

### Expected Resolution
- Box forward case: **FIXED** - with unshifted canonicalOmega, sigma = canonicalHistory, IH applies directly
- `constant_family_bmcs_exists_int`: **REMOVED** - entire constant-family infrastructure deleted

### New Sorries
- None expected

### Remaining Debt
- DovetailingChain sorries (forward_F, backward_P) - out of scope, unrelated to Omega

## Implementation Phases

### Phase 1: Core Semantic Change (Truth.lean) [NOT STARTED]

- **Dependencies:** None
- **Goal:** Add Omega to truth_at, update time-shift infrastructure

**Tasks**:
- [ ] Add `Omega : Set (WorldHistory F)` parameter to `truth_at`
- [ ] Modify Box case: `forall sigma, sigma in Omega -> truth_at M Omega sigma t phi`
- [ ] Thread Omega through all other cases (no behavior change)
- [ ] Define `ShiftClosed` predicate:
  ```lean
  def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
    forall sigma delta, sigma in Omega -> time_shift sigma delta in Omega
  ```
- [ ] Prove `Set.univ_shift_closed : ShiftClosed (Set.univ : Set (WorldHistory F))`
- [ ] Update `time_shift_preserves_truth` with Omega + `(h_sc : ShiftClosed Omega)` hypothesis
- [ ] Update `exists_shifted_history` similarly
- [ ] Update `truth_double_shift_cancel` and `truth_history_eq` with Omega
- [ ] Update all lemmas in TimeShift section

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean`

**Verification**:
- File compiles without errors
- `truth_at` signature includes Omega parameter
- `time_shift_preserves_truth` requires ShiftClosed

---

### Phase 2: Update Validity Definitions (Validity.lean) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Wrap truth_at calls with Set.univ, add Omega to satisfiable

**Tasks**:
- [ ] Update `valid`: `forall ... tau t, truth_at M Set.univ tau t phi`
- [ ] Update `semantic_consequence`: same pattern with Set.univ
- [ ] Update `satisfiable` with existential Omega:
  ```lean
  def satisfiable (D : Type*) [...] (Gamma : Context) : Prop :=
    exists (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
      (tau : WorldHistory F) (_ : tau in Omega) (t : D),
      forall phi, phi in Gamma -> truth_at M Omega tau t phi
  ```
- [ ] Update `satisfiable_abs` and `formula_satisfiable` similarly
- [ ] Update all validity lemmas (`valid_iff_empty_consequence`, `consequence_monotone`, etc.)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean`

**Verification**:
- File compiles
- `valid` uses Set.univ (no Omega in signature)
- `satisfiable` has Omega existentially

---

### Phase 3: Update Soundness (Soundness.lean + SoundnessLemmas.lean) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Thread Omega = Set.univ through all soundness proofs

**Note**: SoundnessLemmas.lean has ~35 theorems (not 10 as previously estimated). Most changes are mechanical.

**Tasks**:
- [ ] In SoundnessLemmas.lean:
  - [ ] Update local `is_valid` to use `truth_at M Set.univ tau t phi`
  - [ ] Update all `swap_axiom_*_valid` theorems (8 total)
  - [ ] Update all `*_preserves_swap_valid` theorems (5 total)
  - [ ] Update `axiom_swap_valid` master theorem
  - [ ] Update all `axiom_*_valid` private theorems (17 total)
  - [ ] Update `axiom_locally_valid` master theorem
  - [ ] Update `derivable_implies_valid_and_swap_valid`
  - [ ] For MF/TF proofs: `time_shift_preserves_truth` needs ShiftClosed; discharge with `Set.univ_shift_closed`
- [ ] In Soundness.lean:
  - [ ] Thread Omega = Set.univ through axiom validity lemmas
  - [ ] Update `modal_future_valid` and `temp_future_valid` with ShiftClosed discharge
  - [ ] Update main `soundness` theorem

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- `Theories/Bimodal/Metalogic/Soundness.lean`

**Verification**:
- Both files compile
- All axiom validity lemmas proven
- Soundness theorem proven
- MF/TF use Set.univ_shift_closed

---

### Phase 4: Canonical Model Reconstruction (Representation.lean) [NOT STARTED]

- **Dependencies:** Phases 1-3
- **Goal:** Implement Choice B canonical model, fix truth lemma

**Tasks**:

**4a. Remove constant-family infrastructure:**
- [ ] Remove `IsConstantFamilyBMCS` definition
- [ ] Remove `constant_family_bmcs_exists_int` sorry and its 5 accessor theorems
- [ ] Remove `getConstantBMCS` and its 4 property theorems
- [ ] Remove all uses of `h_const` parameter

**4b. Generalize CanonicalWorldState:**
- [ ] Redefine `CanonicalWorldState` to allow any MCS at any time:
  ```lean
  abbrev CanonicalWorldState (B : BMCS Int) :=
    { S : Set Formula // SetMaximalConsistent S }
  ```
- [ ] Define `mkCanonicalWorldStateAtTime B fam hfam t` producing world state from `fam.mcs t`

**4c. Redefine canonical history with time-varying states:**
- [ ] Update `canonicalHistory` to use: `states t _ := mkCanonicalWorldStateAtTime B fam hfam t`

**4d. Define canonicalOmega (without shift-closure):**
- [ ] Define:
  ```lean
  def canonicalOmega (B : BMCS Int) : Set (WorldHistory (canonicalFrame B)) :=
    { sigma | exists fam (hfam : fam in B.families), sigma = canonicalHistory B fam hfam }
  ```

**4e. Restate and reprove truth lemma:**
- [ ] Remove `h_const` parameter from `canonical_truth_lemma_all`
- [ ] Change LHS from `fam.mcs 0` to `fam.mcs t`:
  ```lean
  phi in fam.mcs t <-> truth_at (canonicalModel B) (canonicalOmega B) (canonicalHistory B fam hfam) t phi
  ```
- [ ] Atom case: trivial (states t gives fam.mcs t, valuation checks membership)
- [ ] Box forward: By modal_forward, psi in fam'.mcs t for all fam'. By IH, truth_at for all canonical histories. Since canonicalOmega = set of canonical histories (unshifted), done.
- [ ] Box backward: symmetric using modal_backward
- [ ] Temporal cases: Use IH at different times (no h_const needed since we're already using fam.mcs t)

**4f. Update completeness theorems:**
- [ ] Replace `getConstantBMCS` calls with `construct_saturated_bmcs_int`
- [ ] Update `standard_representation` with `canonicalOmega`
- [ ] Update `standard_context_representation`
- [ ] Update `standard_weak_completeness`
- [ ] Update `standard_strong_completeness`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean`

**Verification**:
- File compiles without sorries in Box forward case (line 229)
- `constant_family_bmcs_exists_int` sorry removed entirely
- All completeness theorems compile

---

### Phase 5: Downstream Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Fix any remaining compilation errors in downstream files

**Tasks**:
- [ ] Update `FMP/SemanticCanonicalModel.lean` (truth_at calls gain Set.univ)
- [ ] Update any other files importing Semantics that break
- [ ] Run `lake build` to verify full compilation
- [ ] Verify no new sorries introduced

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/FMP/SemanticCanonicalModel.lean` (likely)
- Other files as needed

**Verification**:
- `lake build` succeeds
- No new sorries
- Sorry count reduced by at least 2

---

## Testing & Validation

- [ ] `lake build` succeeds for all modified files
- [ ] No new sorries introduced
- [ ] Box forward case sorry in truth lemma eliminated (line 229)
- [ ] `constant_family_bmcs_exists_int` sorry removed
- [ ] Soundness theorem proven
- [ ] Completeness theorems preserved
- [ ] MF/TF axioms valid with Set.univ (trivially shift-closed)

## Artifacts & Outputs

- `specs/906_box_admissible_histories_omega_closure/plans/implementation-002.md` - This plan
- Modified files:
  - `Theories/Bimodal/Semantics/Truth.lean`
  - `Theories/Bimodal/Semantics/Validity.lean`
  - `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
  - `Theories/Bimodal/Metalogic/Soundness.lean`
  - `Theories/Bimodal/Metalogic/Representation.lean`
  - `Theories/Bimodal/FMP/SemanticCanonicalModel.lean` (likely)

## Key Insight: Why Shift-Closure Is Not Needed for canonicalOmega

The research uncovered a critical simplification: shift-closure is only required for **soundness**, which operates at the validity level with `Omega = Set.univ`. Since `Set.univ` is trivially shift-closed, MF/TF soundness proofs work.

For **completeness**, we use `canonicalOmega` which does NOT need to be shift-closed. The Box forward case works because:
1. `sigma in canonicalOmega` implies `sigma = canonicalHistory B fam' hfam'` for some family
2. `modal_forward` gives `psi in fam'.mcs t`
3. IH directly gives `truth_at ... sigma t psi`

No time-shifting is needed in the completeness direction. This dramatically simplifies the entire construction.

## Rollback/Contingency

If implementation reveals fundamental issues:
1. Git revert to pre-implementation state
2. Re-examine whether shift-closure is actually needed for canonicalOmega
3. Consult research-001.md Section "Critical Technical Details" for the detailed proof sketch

---

*Revised from implementation-001.md incorporating findings from research-001.md*
