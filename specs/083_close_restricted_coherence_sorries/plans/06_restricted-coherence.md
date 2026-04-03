# Implementation Plan: Task #83 (v6)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 24-30 hours
- **Dependencies**: None
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/06_until-since-enrichment.md, specs/083_close_restricted_coherence_sorries/reports/05_team-research.md
- **Artifacts**: plans/06_restricted-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries (`succ_chain_restricted_forward_F` at UltrafilterChain.lean:3762 and `succ_chain_restricted_backward_P` at UltrafilterChain.lean:3772) by enriching the TM formula language with binary Until (U) and Since (S) operators. This is the standard Burgess-Xu approach (1982/1988) to temporal completeness. The U-Induction axiom is the key new content that prevents perpetual deferral of F-obligations, which 5 rounds of research have confirmed is impossible to resolve within the current axiom system. The approach requires extending Formula with 2 new constructors, adding 10 new axioms, updating ~20 files, and restructuring the chain construction to use dovetailed fair scheduling.

### Research Integration

From report 06 (Until/Since enrichment):
- **Axiomatization**: Burgess-Xu system with 4 Until axioms (UU, UI, UIND, U-Linearity), 4 Since axioms (mirror), 2 connectedness axioms. Net +4 axioms after removing derivable seriality/linearity.
- **Semantics**: Reflexive Until/Since matching existing reflexive G/H. F(phi) = top U phi, P(phi) = top S phi.
- **Completeness strategy**: Canonical frame (already sorry-free) + dovetailed path extraction with fair scheduling of Until/Since obligations.
- **File inventory**: ~20 files modified, ~3500 new lines, ~82% survival of existing code.
- **Critical insight**: U-Induction axiom constrains MCS to be inconsistent with perpetual deferral, which F alone cannot do.

From report 05 (team research):
- Perpetual deferral IS semantically consistent in current TM (confirmed impossible to close with existing axioms).
- Two-phase construction (canonical frame + path extraction) is the standard approach from the literature.
- G-wrapping blocker is fundamental for all enriched-seed approaches.

From plan v4 (prior attempt):
- DRM bounded-witness approach was blocked because bounded_witness requires MCS chains and DRM-to-MCS bridging is non-trivial.
- All chain-based approaches within current axiom system are dead ends.

## Goals & Non-Goals

**Goals**:
- Add Until (U) and Since (S) binary connectives to Formula type
- Add 10 new axiom schemata (Burgess-Xu axiomatization)
- Prove soundness of all new axioms
- Restructure chain construction with dovetailed fair scheduling
- Close BOTH sorries (`succ_chain_restricted_forward_F`, `succ_chain_restricted_backward_P`)
- Sorry-free `completeness_over_Int` and `discrete_completeness_fc`
- Clean `lake build` after every phase

**Non-Goals**:
- Closing `bfmcs_from_mcs_temporally_coherent` (the unrestricted version)
- Closing `dense_completeness` (requires density, orthogonal to this work)
- Until/Since support in FMP/decidability infrastructure (defer to separate task)
- Until/Since support in Examples/ or Automation/ (defer to separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula constructor addition causes massive cascade of broken pattern matches | H | H | Lean 4 flags incomplete matches as errors. Fix mechanically phase by phase, keeping `lake build` passing after each phase. |
| U-Induction soundness proof is complex | M | M | Well-established mathematics (Burgess 1982). The semantic argument is a straightforward induction on the witness position. |
| Dovetailed chain construction correctness is subtle | H | M | DovetailedChain.lean already exists (605 lines, 0 sorries) with fair scheduling infrastructure. Extend rather than rebuild. |
| SubformulaClosure changes break RestrictedMCS and DeferralClosure | M | M | Phase 2 focuses entirely on closure updates. Verify finiteness theorems still hold. |
| Succ relation U-step addition breaks existing successor existence proofs | M | M | U-step subsumes F-step when F = top U. Provide compatibility lemma showing old F-step follows from new U-step. |
| Truth lemma new cases for Until/Since are non-trivial | M | L | Forward direction uses U-Unfolding and dovetailed chain. Backward uses U-Introduction on subformulas. Standard inductive arguments. |

## Implementation Phases

### Phase 1: Formula Type Extension [COMPLETED]

**Goal**: Add `until` and `since` constructors to Formula, update all pattern-matching functions, achieve clean `lake build`.

**Tasks**:
- [ ] Add `| until : Formula -> Formula -> Formula` and `| since : Formula -> Formula -> Formula` to `Formula` inductive type in `Theories/Bimodal/Syntax/Formula.lean`
- [ ] Update `complexity` with cases: `| until phi psi => 1 + complexity phi + complexity psi` (and since)
- [ ] Update `modalDepth`, `temporalDepth`, `countImplications` with new cases
- [ ] Update `swap_temporal`: swap `until` and `since` (swap phi/psi recursively)
- [ ] Update `beq_refl`, `eq_of_beq` if they have manual cases (check if `deriving` handles it)
- [ ] Update `atoms` function with new cases
- [ ] Update `needsPositiveHypotheses` with new cases
- [ ] Redefine `some_future` as `(Formula.neg Formula.bot).until phi` and `some_past` as `(Formula.neg Formula.bot).since phi` (or add equivalence theorems)
- [ ] Update `Theories/Bimodal/Syntax/Subformulas.lean`: add until/since cases to `subformulas`
- [ ] Update `Theories/Bimodal/ProofSystem/Substitution.lean`: add until/since cases
- [ ] Update `Theories/Bimodal/ProofSystem/Derivation.lean`: update `temporal_duality` to swap until/since
- [ ] Fix ALL broken pattern matches across the codebase (Lean 4 will report them)
- [ ] Run `lake build` until clean

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` -- new constructors, updated functions
- `Theories/Bimodal/Syntax/Subformulas.lean` -- new cases
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- new cases
- `Theories/Bimodal/ProofSystem/Derivation.lean` -- temporal duality
- Various files with Formula pattern matches (identified by `lake build` errors)

**Verification**:
- `lake build` passes with zero errors
- `swap_temporal_involution` still holds
- Existing tests still pass

**Risks**:
- Many files will have broken pattern matches. This is mechanical but time-consuming.

---

### Phase 2: SubformulaClosure and DeferralClosure Extension [COMPLETED]

**Goal**: Update subformula closure, deferral closure, and restricted MCS infrastructure for Until/Since formulas. Achieve clean `lake build`.

**Tasks**:
- [ ] Update `subformulaClosure` in `Theories/Bimodal/Syntax/SubformulaClosure.lean`:
  - For `until phi psi`: include phi, psi, and `until phi psi` in closure
  - For `since phi psi`: include phi, psi, and `since phi psi` in closure
- [ ] Update `closureWithNeg` correspondingly
- [ ] Update `deferralClosure` to include Until/Since deferral formulas:
  - For `until phi psi` in closure: add phi, psi, `until phi psi`
  - Ensure `deferralDisjunctionSet` handles Until/Since deferral patterns
- [ ] Update all finiteness theorems for the extended closures
- [ ] Update membership theorems (e.g., `mem_subformulaClosure_self`, `subformulaClosure_subset`)
- [ ] Update `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` if DeferralRestrictedMCS references deferralClosure structure
- [ ] Run `lake build` until clean

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- closure definitions and theorems
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` -- if affected

**Verification**:
- `lake build` passes
- `deferralClosure_finite` still holds
- `subformulaClosure_finite` still holds

**Risks**:
- Finiteness proofs may need reworking for the larger closures.

---

### Phase 3: Axioms and Proof System [COMPLETED]

**Goal**: Add the 10 new Until/Since axiom schemata to the proof system. Achieve clean `lake build`.

**Tasks**:
- [ ] Add new axiom constructors to `Theories/Bimodal/ProofSystem/Axioms.lean`:
  - `until_unfold (phi psi : Formula)` -- `phi U psi -> psi or (phi and G(phi U psi))`
  - `until_intro (phi psi : Formula)` -- `psi or (phi and G(phi U psi)) -> phi U psi`
  - `until_induction (phi psi chi : Formula)` -- `G(psi -> chi) and G(phi and chi -> G(chi)) -> (phi U psi -> chi)`
  - `until_linearity (phi psi phi' psi' : Formula)` -- linearity for Until
  - `since_unfold (phi psi : Formula)` -- mirror of until_unfold
  - `since_intro (phi psi : Formula)` -- mirror of until_intro
  - `since_induction (phi psi chi : Formula)` -- mirror of until_induction
  - `since_linearity (phi psi phi' psi' : Formula)` -- mirror of until_linearity
  - `until_connectedness (phi psi chi : Formula)` -- `phi and (chi U psi) -> chi U (psi and (chi S phi))`
  - `since_connectedness (phi psi chi : Formula)` -- mirror
- [ ] Update `FrameClass` classification for new axioms (all are `discrete` frame class)
- [ ] Update `frameClass`, `isDenseCompatible`, `isDiscreteCompatible`, `isBase` functions
- [ ] Optionally mark `seriality_future`, `seriality_past` as derivable (keep for backward compatibility but note they follow from Until/Since)
- [ ] Update `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` if it references linearity axiom form
- [ ] Run `lake build` until clean

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- new axiom constructors
- `Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- possible updates

**Verification**:
- `lake build` passes
- All axiom constructors have correct types
- Frame class assignments are consistent

**Risks**:
- Getting the axiom formulas exactly right in Lean syntax. Write out on paper first.

---

### Phase 4: Semantics Extension [PARTIAL]

**Goal**: Add Until/Since evaluation to the truth definition. Prove soundness of all 10 new axioms.

**Tasks**:
- [ ] Add Until/Since cases to `truth_at` in `Theories/Bimodal/Semantics/Truth.lean`:
  ```lean
  | Formula.until phi psi => ∃ s : D, t ≤ s ∧ truth_at M Omega tau s psi ∧
      ∀ r : D, t ≤ r → r ≤ s → truth_at M Omega tau r phi
  | Formula.since phi psi => ∃ s : D, s ≤ t ∧ truth_at M Omega tau s psi ∧
      ∀ r : D, s ≤ r → r ≤ t → truth_at M Omega tau r phi
  ```
- [ ] Update `time_shift_preserves_truth` with Until/Since cases
- [ ] Update `truth_double_shift_cancel` with new cases
- [ ] Prove `F_equiv_top_until`: `truth_at ... t (some_future psi) <-> truth_at ... t (top.until psi)` (if F is redefined) or prove it as a derived lemma
- [ ] Add soundness proofs in `Theories/Bimodal/Metalogic/Soundness.lean`:
  - `until_unfold_sound`: validity of U-Unfolding
  - `until_intro_sound`: validity of U-Introduction
  - `until_induction_sound`: validity of U-Induction (most complex -- induction on witness position)
  - `until_linearity_sound`: validity of U-Linearity (uses linear order properties)
  - Mirror proofs for Since (4 more)
  - `until_connectedness_sound`, `since_connectedness_sound`: validity of connectedness
- [ ] Update `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`:
  - Add swap validity lemmas for Until/Since axioms
  - Update temporal duality lemmas
- [ ] Run `lake build` until clean

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` -- truth evaluation
- `Theories/Bimodal/Metalogic/Soundness.lean` -- soundness proofs
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- duality lemmas

**Verification**:
- `lake build` passes
- `lean_verify` on all new soundness theorems shows no sorry
- Existing soundness theorems still hold

**Risks**:
- U-Induction soundness is the most complex proof. Requires induction on the difference between witness position and current time.

---

### Phase 5: Temporal Content and Succ Relation [NOT STARTED]

**Goal**: Add u_content/s_content to TemporalContent, extend the Succ relation with U-step, update successor existence proofs.

**Tasks**:
- [ ] Add `u_content` to `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`:
  ```lean
  def u_content (M : Set Formula) : Set (Formula × Formula) :=
    { (phi, psi) | Formula.until phi psi ∈ M }
  def s_content (M : Set Formula) : Set (Formula × Formula) :=
    { (phi, psi) | Formula.since phi psi ∈ M }
  ```
- [ ] Add U-step to Succ relation in `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`:
  ```lean
  -- For all (phi U psi) in u: either psi in v, or (phi in v and (phi U psi) in v)
  u_step : ∀ phi psi, Formula.until phi psi ∈ u →
    psi ∈ v ∨ (phi ∈ v ∧ Formula.until phi psi ∈ v)
  ```
- [ ] Prove compatibility: old `f_step` follows from `u_step` when F = top U
  - `u_step_implies_f_step`: if u_step holds for all (phi U psi), then f_step holds (since F(psi) = top U psi)
- [ ] Add S-step symmetric condition for backward Succ
- [ ] Update `single_step_forcing` and `single_step_forcing_past` with new cases in `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- [ ] Update successor existence in `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`:
  - `successor_from_seed` must produce a successor satisfying u_step
  - The seed enrichment includes deferral disjunctions for Until formulas: for each `(phi U psi) in M`, add `(psi or (phi and (phi U psi)))` to the seed
- [ ] Update `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` for Until/Since witness seeds
- [ ] Add `canonical_forward_U` and `canonical_backward_S` to `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- [ ] Run `lake build` until clean

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- u_content, s_content
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- u_step, s_step, single_step_forcing
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- successor existence
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- witness seeds
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` -- canonical witnesses

**Verification**:
- `lake build` passes
- `lean_verify` on `successor_from_seed` shows no sorry
- Compatibility lemma `u_step_implies_f_step` is sorry-free

**Risks**:
- The u_step addition to Succ may require refactoring proofs that destructure Succ.

---

### Phase 6: Dovetailed Chain Construction [NOT STARTED]

**Goal**: Extend the existing `DovetailedChain.lean` (605 lines, 0 sorries) to incorporate Until/Since fair scheduling, proving forward_U and forward_F for the dovetailed chain.

**Tasks**:
- [ ] Review existing `DovetailedChain.lean` infrastructure (already has fair scheduling via `Nat.unpair`)
- [ ] Extend the dovetailing to schedule Until/Since obligation resolution:
  - At each step n, `Nat.unpair n = (i, j)` targets formula `Denumerable.ofNat Formula j` at chain position i
  - When the targeted formula is `(phi U psi)` in the current MCS: choose successor as `canonical_forward_U` witness
  - Otherwise: use default Succ successor
- [ ] Prove `dovetailed_forward_U`: for all `(phi U psi)` in `dovetailed_fam(t)`, there exists `s >= t` with `psi` in `dovetailed_fam(s)` and `phi` in `dovetailed_fam(r)` for all `r` in `[t,s]`
  - Uses: fair scheduling ensures each Until obligation is processed infinitely often
  - Uses: U-Induction in the MCS ensures the obligation cannot be perpetually deferred
  - Uses: canonical_forward_U provides witnesses at each processing step
- [ ] Prove `dovetailed_forward_F`: specialization of `dovetailed_forward_U` with phi = top
  - `some_future psi in dovetailed_fam(t) -> exists s >= t, psi in dovetailed_fam(s)`
- [ ] Prove symmetric `dovetailed_backward_S` and `dovetailed_backward_P`
- [ ] Update `dovetailed_fmcs` to include the new coherence properties
- [ ] Run `lake build` until clean

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- extend dovetailing
- Possibly `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` -- if coherence definitions need Until/Since

**Verification**:
- `lake build` passes
- `lean_verify` on `dovetailed_forward_F` shows no sorry
- `lean_verify` on `dovetailed_backward_P` shows no sorry

**Risks**:
- The perpetual-deferral-killing argument using U-Induction is the mathematical crux. The proof must show that an MCS containing `F(psi)` at all times `>= t` and `neg(psi)` at all times `>= t` is inconsistent under the enriched axioms. This follows from U-Induction but the formal instantiation needs care.

---

### Phase 7: Completeness Rewiring [NOT STARTED]

**Goal**: Wire the dovetailed chain into the completeness path, close BOTH sorries, achieve sorry-free `completeness_over_Int`.

**Tasks**:
- [ ] Prove `succ_chain_restricted_forward_F` using the dovetailed chain:
  - Option A: Replace `succ_chain_fam` with `dovetailed_fam` in the completeness path
  - Option B: Prove `succ_chain_restricted_forward_F` by constructing a dovetailed chain that agrees with `succ_chain_fam` on deferralClosure formulas
  - Option C: Bypass `succ_chain_restricted_forward_F` entirely by rewiring `bfmcs_restricted_temporally_coherent` to use `dovetailed_fam` directly
- [ ] Prove `succ_chain_restricted_backward_P` symmetrically
- [ ] Update `bfmcs_restricted_temporally_coherent` in `Theories/Bimodal/FrameConditions/Completeness.lean` to use the dovetailed chain path
- [ ] Update `completeness_over_Int` to use `bfmcs_restricted_temporally_coherent` (may already be wired)
- [ ] Update `discrete_completeness_fc` in `Theories/Bimodal/FrameConditions/Completeness.lean`
- [ ] Update truth lemma cases in `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`:
  - Add Until case (forward: uses dovetailed chain guarantee; backward: uses U-Introduction)
  - Add Since case (symmetric)
- [ ] Update `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` if it has Until/Since gaps
- [ ] Annotate original sorry locations as RESOLVED with reference to the dovetailed chain
- [ ] Run `lake build` -- zero errors
- [ ] Verify sorry count: only pre-existing non-completeness sorries remain

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- close both sorries (or bypass)
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- rewire completeness path
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- Until/Since truth lemma cases
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` -- if affected

**Verification**:
- `lake build` passes with zero errors
- `lean_verify` on `completeness_over_Int` shows no sorry
- `lean_verify` on `discrete_completeness_fc` shows no sorry
- The two original sorry locations are closed
- grep `sorry` in Completeness.lean returns only `bfmcs_from_mcs_temporally_coherent` and `dense_completeness_fc`

**Risks**:
- The rewiring may require a different bundle construction if the dovetailed chain does not fit the existing `boxClassFamilies` pattern. In that case, build `dovetailedBoxClassFamilies` as an alternative bundle.

## Testing & Validation

- [ ] `lake build` passes with zero errors after every phase
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.completeness_over_Int` shows no sorry
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.discrete_completeness_fc` shows no sorry
- [ ] `lean_verify` on all 10 new soundness theorems shows no sorry
- [ ] `lean_verify` on `dovetailed_forward_F` shows no sorry
- [ ] grep `sorry` in `UltrafilterChain.lean` returns only pre-existing non-target sorries (if any)
- [ ] grep `sorry` in `Completeness.lean` returns only `bfmcs_from_mcs_temporally_coherent` and `dense_completeness_fc`
- [ ] `swap_temporal_involution` still holds after Formula extension

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/06_restricted-coherence.md` (this file)
- Modified: `Theories/Bimodal/Syntax/Formula.lean` (phase 1)
- Modified: `Theories/Bimodal/Syntax/Subformulas.lean` (phase 1)
- Modified: `Theories/Bimodal/Syntax/SubformulaClosure.lean` (phase 2)
- Modified: `Theories/Bimodal/ProofSystem/Axioms.lean` (phase 3)
- Modified: `Theories/Bimodal/ProofSystem/Derivation.lean` (phase 1)
- Modified: `Theories/Bimodal/ProofSystem/Substitution.lean` (phase 1)
- Modified: `Theories/Bimodal/Semantics/Truth.lean` (phase 4)
- Modified: `Theories/Bimodal/Metalogic/Soundness.lean` (phase 4)
- Modified: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (phase 4)
- Modified: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` (phase 5)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` (phase 5)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (phase 5)
- Modified: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (phase 5)
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (phase 5)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` (phase 6)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (phase 7)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean` (phase 7)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` (phase 7)
- `specs/083_close_restricted_coherence_sorries/summaries/06_restricted-coherence-summary.md` (after implementation)

## Rollback/Contingency

**If Phase 1 cascade is too large**: Create a feature branch `task-83-until-since` and work there. Merge only when all phases complete.

**If U-Induction soundness (Phase 4) is harder than expected**: The semantic argument is well-established. If the Lean formalization is difficult, use a helper lemma `until_induction_semantic` that proves the property at the semantic level first, then lift to validity.

**If dovetailed chain (Phase 6) construction cannot prove forward_F**: Fall back to the canonical frame path extraction approach (Tier 1 from report 05). Build Z-indexed paths through the canonical frame using `canonical_forward_F` witnesses directly. This avoids the dovetailing but requires proving that the extracted path forms a valid FMCS.

**If completeness rewiring (Phase 7) requires too much refactoring**: Build a parallel completeness theorem `completeness_over_Int_v2` that uses the dovetailed chain directly, then deprecate the old path.

**Full rollback**: `git revert` all v6 commits. Original sorries remain. DovetailedChain.lean foundation preserved.
