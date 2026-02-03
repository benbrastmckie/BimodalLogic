# Implementation Plan: Task #844

- **Task**: 844 - Redesign metalogic to use Pre-Coherent Bundle construction
- **Status**: [BLOCKED] - Mathematical Impossibility Discovered
- **Effort**: 14-18 hours (TERMINATED - approach proven infeasible)
- **Dependencies**: None (replaces current approach)
- **Research Inputs**: specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-001.md, specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Completely redesign the BMCS saturation strategy from sequential witness construction to a product-based Pre-Coherent Bundle approach. The current implementation has 3 irreducible sorries (lines 714, 733, 785 in SaturatedConstruction.lean) stemming from the "Uncontrolled Lindenbaum Problem" - when extending a consistent set to an MCS, Lindenbaum can add arbitrary Box formulas that break box_coherence.

The new approach inverts the construction: instead of building box-coherent families first and trying to add witnesses (which fails), we define a PreCoherent predicate with S-bounded Box formulas and take the product of ALL families satisfying this predicate. Box coherence follows by construction; saturation follows from the product structure.

### Research Integration

From research-001.md and research-003.md:
- Root cause identified: 3 sorries stem from uncontrolled Lindenbaum extension
- Solution: S-bounded restricted Lindenbaum prevents problematic Box additions
- Existing infrastructure: `closureWithNeg` (Finset-based), `restricted_lindenbaum` pattern
- Estimated reuse: ~60% of existing infrastructure

## Goals & Non-Goals

**Goals**:
- Achieve zero sorries in the metalogic saturation construction
- Achieve zero axioms (replace `singleFamily_modal_backward_axiom`)
- Create publication-ready completeness proof
- Maintain compatibility with existing BMCS interface for Truth lemma

**Non-Goals**:
- Modify the temporal coherence structure (orthogonal to modal)
- Change the formula syntax or proof system
- Optimize for performance (correctness first)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| S-bounded Lindenbaum doesn't produce true MCS | High | Low | Prove maximality among S-bounded sets (standard Zorn argument) |
| Pre-coherent families may be empty | High | Low | Start from Gamma's Lindenbaum extension which is pre-coherent by construction |
| Box coherence proof is more subtle than expected | Medium | Medium | May need auxiliary lemmas about S-closure properties; modular design allows debugging |
| Integration with temporal operators breaks | Medium | Low | Temporal coherence is orthogonal; reuse existing `IndexedMCSFamily` proofs |
| Effort exceeds estimates | Low | Medium | Phases are independent; can deliver incremental progress |

## Sorry Characterization

### Pre-existing Sorries

3 sorries in `SaturatedConstruction.lean`:

| Sorry | Line | Root Cause |
|-------|------|------------|
| Sorry 1 | ~714 | BoxContent aggregates across families; need consistency of `{psi} ∪ BoxContent` |
| Sorry 2 | ~733 | BoxContent uses `∃ s` (any time), not specific time `t`; time mismatch |
| Sorry 3 | ~785 | Lindenbaum extension adds uncontrolled Box formulas breaking coherence |

### Expected Resolution

All 3 sorries are resolved by the architectural redesign:
- Sorry 1 & 2: Eliminated because we don't construct witnesses by extending BoxContent
- Sorry 3: Eliminated because S-bounded Lindenbaum CANNOT add problematic Box formulas

### New Sorries

None expected. The product construction avoids the Lindenbaum control problem entirely.

### Remaining Debt

After implementation:
- 0 sorries expected in the metalogic saturation
- 0 axioms (removes `singleFamily_modal_backward_axiom`)
- Completeness theorem will be publication-ready

## Implementation Phases

### Phase 1: SaturationClosure Definition [COMPLETED]

**Goal**: Define the finite set S of formulas that bounds Box contents in pre-coherent families.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean`
- [ ] Define `SaturationClosure` extending `closureWithNeg`:
  ```lean
  /-- Saturation closure: subformula closure extended with negations and box contents.
      This bounds which formulas can appear as Box contents in pre-coherent families. -/
  def SaturationClosure (phi : Formula) : Finset Formula :=
    closureWithNeg phi ∪ (closureWithNeg phi).biUnion (fun psi =>
      match psi with
      | Formula.box chi => {chi, chi.neg}
      | _ => ∅)
  ```
- [ ] Prove `SaturationClosure` is finite (inherits from Finset)
- [ ] Prove `closureWithNeg ⊆ SaturationClosure`
- [ ] Prove `SaturationClosure` is closed under relevant modal operations

**Files to modify**:
- New: `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.PreCoherentBundle` succeeds
- No sorries in SaturationClosure definitions

---

### Phase 2: PreCoherent Predicate [COMPLETED]

**Goal**: Define the PreCoherent predicate for indexed families with S-bounded Box formulas.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Define `SBounded` predicate for sets:
  ```lean
  /-- A set is S-bounded if all Box formulas have contents in S. -/
  def SBounded (M : Set Formula) (S : Set Formula) : Prop :=
    ∀ phi, Formula.box phi ∈ M → phi ∈ S
  ```
- [ ] Define `PreCoherent` predicate for indexed families:
  ```lean
  /-- An indexed family is pre-coherent w.r.t. S if:
      1. Each time point is an MCS
      2. Temporal coherence (G/H satisfied)
      3. All Box formulas have contents in S (S-boundedness) -/
  def PreCoherent (f : D → Set Formula) (S : Set Formula) : Prop :=
    (∀ t, SetMaximalConsistent (f t)) ∧
    (∀ t t' phi, t < t' → Formula.all_future phi ∈ f t → phi ∈ f t') ∧
    (∀ t t' phi, t' < t → Formula.all_past phi ∈ f t → phi ∈ f t') ∧
    (∀ t, SBounded (f t) S)
  ```
- [ ] Prove basic properties:
  - `PreCoherent` implies temporal coherence
  - `PreCoherent` implies each time point is consistent
  - `PreCoherent` is preserved under intersection with closure

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (extend)

**Verification**:
- All PreCoherent lemmas compile without sorry
- Properties align with existing `IndexedMCSFamily` structure

---

### Phase 3: S-Bounded Restricted Lindenbaum [COMPLETED]

**Goal**: Implement Lindenbaum extension that maintains S-boundedness of Box formulas.

**Estimated effort**: 3-4 hours

**Tasks**:
- [ ] Define S-bounded consistency:
  ```lean
  /-- A set is S-bounded consistent if it's consistent and S-bounded. -/
  def SBoundedConsistent (M : Set Formula) (S : Set Formula) : Prop :=
    SetConsistent M ∧ SBounded M S
  ```
- [ ] Define S-bounded MCS:
  ```lean
  /-- Maximal among S-bounded consistent sets. -/
  def SBoundedMCS (M : Set Formula) (S : Set Formula) : Prop :=
    SBoundedConsistent M S ∧
    ∀ phi, phi ∉ M → (Formula.box phi → phi ∈ S) →
      ¬SetConsistent (insert phi M) ∨ ¬SBounded (insert phi M) S
  ```
- [ ] Implement S-bounded Lindenbaum using Zorn:
  ```lean
  /-- Extend an S-bounded consistent set to an S-bounded MCS. -/
  theorem s_bounded_lindenbaum_exists
      (base : Set Formula) (h_cons : SetConsistent base)
      (S : Set Formula) (h_S_finite : S.Finite)
      (h_base_ok : SBounded base S) :
      ∃ M, SBoundedMCS M S ∧ base ⊆ M
  ```
- [ ] Prove S-bounded MCS is SetMaximalConsistent (within S-bounded formulas)
- [ ] Prove negation completeness for S-bounded MCS (for formulas in S)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` (add S-bounded variant)
- Or: `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (if self-contained)

**Verification**:
- `s_bounded_lindenbaum_exists` compiles without sorry
- The key insight: filtering out `Box phi` when `phi ∉ S` preserves consistency

---

### Phase 4: AllPreCoherentFamilies Construction [COMPLETED]

**Goal**: Define the product of all pre-coherent families and prove non-emptiness.

**Estimated effort**: 3-4 hours

**Tasks**:
- [ ] Define `AllPreCoherentFamilies`:
  ```lean
  /-- The set of all pre-coherent indexed families over S. -/
  def AllPreCoherentFamilies (S : Set Formula) : Set (IndexedMCSFamily D) :=
    { f | PreCoherent f.mcs S }
  ```
- [ ] Construct a canonical pre-coherent family from a consistent context:
  ```lean
  /-- Given a consistent context Gamma, construct a pre-coherent family containing it. -/
  noncomputable def constructPreCoherentFamily
      (Gamma : List Formula) (h_cons : ContextConsistent Gamma)
      (S : Set Formula) (h_S_closed : IsSaturationClosure S Gamma) :
      IndexedMCSFamily D
  ```
- [ ] Prove `AllPreCoherentFamilies S` is non-empty for valid S
- [ ] Wrap as `PreCoherentBundle` structure:
  ```lean
  structure PreCoherentBundle (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (phi : Formula) where
    saturation_closure : Finset Formula
    families : Set (IndexedMCSFamily D)
    families_eq : families = AllPreCoherentFamilies (saturation_closure : Set Formula)
    nonempty : families.Nonempty
  ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (extend)

**Verification**:
- Non-emptiness proof compiles without sorry
- The construction builds a valid pre-coherent family

---

### Phase 5: Box Coherence from PreCoherent [BLOCKED - MATHEMATICALLY IMPOSSIBLE]

**Goal**: Prove that the pre-coherent bundle satisfies box_coherence by construction.

**BLOCKING ISSUE**: The goal is mathematically impossible. See implementation summary for proof.

**Estimated effort**: 3-4 hours

**Tasks**:
- [ ] State the main theorem:
  ```lean
  /-- Pre-coherent bundle satisfies box_coherence by construction.
      If Box phi ∈ f.mcs t for f ∈ AllPreCoherentFamilies S, then phi ∈ S,
      so phi is in the domain of all pre-coherent families. -/
  theorem precoherent_bundle_is_box_coherent (S : Set Formula)
      (h_S : IsSaturationClosure S phi) :
      box_coherence_pred (AllPreCoherentFamilies S)
  ```
- [ ] Prove the key lemma: if `phi ∈ S` and `Box phi` is in some pre-coherent family at t, then `phi` must be in all pre-coherent families at t
- [ ] The proof strategy:
  1. Let f, g ∈ AllPreCoherentFamilies S
  2. Suppose Box phi ∈ f.mcs t
  3. By S-boundedness of f: phi ∈ S
  4. By definition of pre-coherent families as MCS: phi or ¬phi in g.mcs t
  5. Prove phi ∈ g.mcs t using consistency argument
- [ ] This may require proving: if phi ∈ S and phi is "forced" at time t (by Box phi being consistent), then all S-bounded MCS at t contain phi

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (extend)

**Verification**:
- `precoherent_bundle_is_box_coherent` compiles without sorry
- This is the CRITICAL theorem that replaces the sorry at line 785

---

### Phase 6: Modal Saturation from Product Structure [BLOCKED]

**Goal**: Prove that the pre-coherent bundle is modally saturated because it includes all witnesses.

**BLOCKED BY**: Phase 5 failure. Saturation could be proven, but is pointless without box-coherence.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] State the saturation theorem:
  ```lean
  /-- Pre-coherent bundle is modally saturated.
      If Diamond psi ∈ f.mcs t for f ∈ AllPreCoherentFamilies S and psi ∈ S,
      then there exists g ∈ AllPreCoherentFamilies S with psi ∈ g.mcs t. -/
  theorem precoherent_bundle_is_saturated (S : Set Formula)
      (h_S : IsSaturationClosure S phi) :
      is_modally_saturated (toPreCoherentBMCS S h_S)
  ```
- [ ] The proof strategy:
  1. Diamond psi ∈ f.mcs t implies psi is consistent (by MCS property)
  2. psi ∈ S (by saturation closure property)
  3. Construct pre-coherent family g with psi at time t using S-bounded Lindenbaum
  4. g ∈ AllPreCoherentFamilies S by construction
  5. Done: g is the witness
- [ ] Connect to existing `diamond_implies_psi_consistent` from ModalSaturation.lean

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (extend)

**Verification**:
- `precoherent_bundle_is_saturated` compiles without sorry
- This replaces sorries at lines 714 and 733

---

### Phase 7: BMCS Interface and Integration [COMPLETED]

**Goal**: Connect the pre-coherent bundle to the existing BMCS interface for the completeness theorem.

**Estimated effort**: 2-3 hours

**Tasks**:
- [ ] Define conversion to BMCS:
  ```lean
  /-- Convert a pre-coherent bundle to a BMCS. -/
  noncomputable def PreCoherentBundle.toBMCS {phi : Formula}
      (B : PreCoherentBundle D phi) : BMCS D where
    families := B.families
    nonempty := B.nonempty
    box_coherence := precoherent_bundle_is_box_coherent B.saturation_closure _
  ```
- [ ] Prove modal_backward for the converted BMCS:
  ```lean
  theorem PreCoherentBundle.modal_backward {phi : Formula}
      (B : PreCoherentBundle D phi) (psi : Formula)
      (h_psi : psi ∈ subformulaClosure phi)
      (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families) (t : D)
      (h_all : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t) :
      Formula.box psi ∈ fam.mcs t
  ```
- [ ] Update `Completeness.lean` to use PreCoherentBundle instead of axiom-based construction
- [ ] Verify Truth lemma still works with the new construction

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` (extend)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` (update)

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- No sorries, no axioms in the completeness proof chain

---

### Phase 8: Cleanup and Verification [BLOCKED]

**Goal**: Remove old sorry-laden code, verify zero sorries and zero axioms, update documentation.

**BLOCKED BY**: Phases 5-6 failures. Cannot achieve zero sorries with this approach.

**Estimated effort**: 1-2 hours

**Tasks**:
- [ ] Move old `SaturatedConstruction.lean` code to Boneyard (preserve for reference)
- [ ] Remove or deprecate `singleFamily_modal_backward_axiom` usage
- [ ] Run verification commands:
  ```bash
  lake build
  grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/
  grep -r "axiom" Theories/Bimodal/Metalogic/Bundle/
  ```
- [ ] Use `#print axioms` on key theorems to verify no axioms
- [ ] Update module docstrings to reflect the new approach
- [ ] Create implementation summary documenting the architectural change

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` (move to Boneyard)
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` (remove axiom usage)
- Various documentation updates

**Verification**:
- `lake build` succeeds with 0 errors
- `grep -c "sorry" Theories/Bimodal/Metalogic/Bundle/*.lean` returns 0
- `#print axioms completeness_theorem` shows only standard Lean axioms (propext, Quot.sound, etc.)

---

## Testing & Validation

- [ ] Each phase builds without errors (`lake build`)
- [ ] No sorries in any new code (`grep sorry`)
- [ ] No new axioms introduced (`#print axioms`)
- [ ] Completeness theorem compiles and type-checks
- [ ] Truth lemma integration verified
- [ ] Modal backward follows from construction, not axiom

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean` - New module with entire construction
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Updated to use PreCoherentBundle
- `Theories/Boneyard/Metalogic/SaturatedConstruction.lean` - Archived old approach
- `specs/844_redesign_metalogic_precoherent_bundle_construction/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the new construction proves infeasible:
1. Boneyard contains full copy of old SaturatedConstruction.lean
2. Construction.lean with axiom remains as fallback
3. Each phase is independent - partial progress is valuable
4. Individual lemmas (e.g., S-bounded Lindenbaum) are useful even without full integration
