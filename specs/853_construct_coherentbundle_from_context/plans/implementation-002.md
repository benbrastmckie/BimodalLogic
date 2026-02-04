# Implementation Plan: Task #853 (v002)

- **Task**: 853 - construct_coherentbundle_from_context
- **Status**: [NOT STARTED]
- **Effort**: 40-60 hours
- **Dependencies**: Tasks #851 (CoherentBundle structure) and #852 (toBMCS) - both COMPLETED
- **Research Inputs**:
  - specs/853_construct_coherentbundle_from_context/reports/research-001.md
  - specs/853_construct_coherentbundle_from_context/reports/research-002.md
  - specs/853_construct_coherentbundle_from_context/reports/research-003.md
  - specs/853_construct_coherentbundle_from_context/reports/research-004.md (primary)
- **Previous Plan**: implementation-001.md (PARTIAL - phases 1,5 completed, 3-4 blocked)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan revises the approach based on research-004.md findings. The original plan hit a fundamental obstacle in Phase 3-4: the multi-family consistency gap prevents proving that `{psi} ∪ UnionBoxContent(B.families)` is consistent for multi-family bundles.

**Key Insight**: We don't need full mutual coherence across all families. Approach B (WeakCoherentBundle) separates "core" families (which maintain mutual coherence) from "witness" families (which only need to contain the core's BoxClosure). This avoids the Lindenbaum control problem entirely.

### Strategy Change Summary

| Aspect | Original (v001) | Revised (v002) |
|--------|-----------------|----------------|
| Bundle type | CoherentBundle (full mutual coherence) | WeakCoherentBundle (core + witness separation) |
| Witness coherence | Must contain UnionBoxContent of ALL families | Only contains BoxClosure of CORE families |
| BMCS type | BMCS (full modal_forward) | WeakBMCS (modal_forward only from eval_family) |
| Obstacle | Lindenbaum adds uncontrolled Box formulas | Avoided - witnesses don't propagate obligations |

### Preserved Work

Phases 1 and 5 from v001 are completed and will be **retained**:
- `initialCoherentBundle` - creates singleton bundle (Phase 1)
- `constructCoherentBundleFromContext` - main entry point (Phase 5)
- `construct_coherent_bmcs` - BMCS conversion (Phase 5)

This work remains valid because singleton bundles ARE WeakCoherentBundles (with `core_families = {base}` and `witness_families = {}`).

## Goals & Non-Goals

**Goals**:
- Define `WeakCoherentBundle` structure with core/witness separation
- Define `BoxClosure` (formulas where Box is in ALL core families)
- Prove `diamond_boxclosure_consistent` for witness construction
- Implement `addWitness` extending bundle with witness family
- Define `WeakBMCS` with relaxed `modal_forward_eval`
- Prove `WeakCoherentBundle.toWeakBMCS` conversion
- Eliminate `saturated_extension_exists` axiom via WeakCoherentBundle saturation
- Integrate with completeness theorem

**Non-Goals**:
- Fixing the original CoherentBundle approach (fundamentally blocked)
- Modifying existing BMCS structure (create parallel WeakBMCS instead)
- Full mutual coherence across witness families (unnecessary)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WeakBMCS insufficient for completeness | High | Low | Verify truth lemma only needs modal_forward from eval_family |
| BoxClosure definition complexity | Medium | Medium | Start simple (singleton core), generalize if needed |
| Zorn chain upper bounds for WeakCoherentBundle | Medium | Low | WeakCoherentBundle has simpler invariants than CoherentBundle |
| Downstream compatibility with existing proofs | Medium | Low | Create adapter lemmas; both BMCS and WeakBMCS can coexist |

## Sorry/Axiom Characterization

### Pre-existing Axioms
- `saturated_extension_exists` in CoherentConstruction.lean:779 (target for elimination)
- `singleFamily_modal_backward_axiom` in Construction.lean:228 (alternative path, unaffected)

### Expected Resolution
- `saturated_extension_exists` → ELIMINATED by WeakCoherentBundle saturation proof

### New Sorries
- None expected. Temporary sorries during development will be documented with line numbers and eliminated before phase completion.

## Implementation Phases

### Phase 1: Define WeakCoherentBundle Structure [NOT STARTED]

**Goal:** Define the `WeakCoherentBundle` structure that separates core and witness families.

**Tasks**:
- [ ] Define `WeakCoherentBundle` structure:
  ```lean
  structure WeakCoherentBundle (D : Type*) [...] where
    core_families : Set (IndexedMCSFamily D)
    witness_families : Set (IndexedMCSFamily D)
    core_nonempty : core_families.Nonempty
    core_disjoint_witness : Disjoint core_families witness_families
    all_constant : ∀ fam ∈ core_families ∪ witness_families, IsConstantFamily fam
    core_mutually_coherent : MutuallyCoherent core_families
    witnesses_contain_core_boxclosure :
      ∀ w ∈ witness_families, ∀ chi,
        (∀ fam ∈ core_families, ∀ t, Formula.box chi ∈ fam.mcs t) →
        ∀ t, chi ∈ w.mcs t
    eval_family : IndexedMCSFamily D
    eval_family_in_core : eval_family ∈ core_families
  ```
- [ ] Define `WeakCoherentBundle.families := core_families ∪ witness_families`
- [ ] Define `BoxClosure (core_families : Set (IndexedMCSFamily D)) : Set Formula`
  - `BoxClosure S := { chi | ∀ fam ∈ S, ∀ t, Formula.box chi ∈ fam.mcs t }`
- [ ] Prove `initialWeakCoherentBundle`: convert `initialCoherentBundle` to `WeakCoherentBundle`
  - `core_families := B.families` (singleton)
  - `witness_families := {}`
  - All properties follow from `CoherentBundle` properties

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` (NEW FILE)

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.WeakCoherentBundle` succeeds
- No sorries in new code

---

### Phase 2: Witness Construction [NOT STARTED]

**Goal:** Prove that witness seeds are consistent and implement witness addition.

**Tasks**:
- [ ] Define `WeakWitnessSeed (B : WeakCoherentBundle D) (psi : Formula) : Set Formula`
  - `WeakWitnessSeed B psi := {psi} ∪ BoxClosure(B.core_families)`
- [ ] Prove `diamond_boxclosure_consistent`:
  ```lean
  theorem diamond_boxclosure_consistent (B : WeakCoherentBundle D)
      (fam : IndexedMCSFamily D) (h_fam : fam ∈ B.core_families)
      (psi : Formula) (t : D) (h_diamond : Formula.neg (Formula.box (Formula.neg psi)) ∈ fam.mcs t) :
      SetConsistent (WeakWitnessSeed B psi)
  ```
  - Key: For singleton core, this reduces to `diamond_boxcontent_consistent_constant`
  - For general core: `BoxClosure(core) ⊆ BoxContent(fam)` where `Diamond psi ∈ fam`
  - Proof: K-distribution argument works because `Box chi ∈ fam.mcs t` for all `chi ∈ BoxClosure(core)`
- [ ] Define `constructWeakWitness`: build witness family from seed
  - Uses `set_lindenbaum` on `WeakWitnessSeed B psi`
  - Creates constant family via `constantWitnessFamily`
- [ ] Prove witness contains required formulas:
  - `psi ∈ witness.mcs t` (from seed)
  - `BoxClosure(B.core_families) ⊆ witness.mcs t` (from seed)
- [ ] Define `addWitness`: extend `WeakCoherentBundle` with new witness family
- [ ] Prove `addWitness` preserves all `WeakCoherentBundle` invariants
  - `core_families` unchanged
  - `witness_families` grows by one
  - `witnesses_contain_core_boxclosure` holds for new witness by construction

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean`

**Verification**:
- `lake build` succeeds
- No sorries
- `addWitness` returns valid `WeakCoherentBundle`

---

### Phase 3: Saturation via Zorn's Lemma [NOT STARTED]

**Goal:** Prove existence of saturated `WeakCoherentBundle` using Zorn's lemma.

**Tasks**:
- [ ] Define `WeakCoherentBundle.isSaturated`:
  ```lean
  def isSaturated (B : WeakCoherentBundle D) : Prop :=
    ∀ fam ∈ B.families, ∀ psi : Formula, ∀ t : D,
      Formula.neg (Formula.box (Formula.neg psi)) ∈ fam.mcs t →
      ∃ fam' ∈ B.families, psi ∈ fam'.mcs t
  ```
- [ ] Define partial order on `WeakCoherentBundle` by family inclusion:
  - `B ≤ B'` iff `B.core_families = B'.core_families ∧ B.witness_families ⊆ B'.witness_families`
  - Note: core families FIXED (only witnesses grow)
- [ ] Prove chain upper bounds:
  ```lean
  theorem weak_coherent_chain_has_upper_bound (C : Set (WeakCoherentBundle D))
      (h_chain : IsChain (· ≤ ·) C) (h_nonempty : C.Nonempty) :
      ∃ ub : WeakCoherentBundle D, ∀ B ∈ C, B ≤ ub
  ```
  - Upper bound: same `core_families`, union of all `witness_families`
  - `witnesses_contain_core_boxclosure`: holds because each witness contains it
- [ ] Apply `zorn_subset_nonempty` to get maximal bundle
- [ ] Prove maximal implies saturated:
  ```lean
  theorem maximal_is_saturated (B : WeakCoherentBundle D)
      (h_max : ∀ B', B ≤ B' → B' ≤ B) :
      B.isSaturated
  ```
  - Contraposition: if not saturated, can add witness via `addWitness`, contradicting maximality
- [ ] Define `saturateWeakCoherentBundle`: returns saturated extension

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean`

**Verification**:
- `lake build` succeeds
- No sorries
- `saturateWeakCoherentBundle` returns `isSaturated` bundle

---

### Phase 4: WeakBMCS Definition and Conversion [NOT STARTED]

**Goal:** Define `WeakBMCS` with relaxed `modal_forward` and prove conversion from `WeakCoherentBundle`.

**Tasks**:
- [ ] Define `WeakBMCS` structure:
  ```lean
  structure WeakBMCS (D : Type*) [...] where
    families : Set (IndexedMCSFamily D)
    nonempty : families.Nonempty
    all_constant : ∀ fam ∈ families, IsConstantFamily fam
    -- Weakened: only FROM eval_family
    modal_forward_eval : ∀ phi : Formula, ∀ t : D,
      Formula.box phi ∈ eval_family.mcs t →
      ∀ fam' ∈ families, phi ∈ fam'.mcs t
    -- Full modal_backward (unchanged)
    modal_backward : ∀ fam ∈ families, ∀ phi : Formula, ∀ t : D,
      (∀ fam' ∈ families, phi ∈ fam'.mcs t) →
      Formula.box phi ∈ fam.mcs t
    eval_family : IndexedMCSFamily D
    eval_family_mem : eval_family ∈ families
  ```
- [ ] Prove `WeakCoherentBundle.toWeakBMCS`:
  ```lean
  theorem toWeakBMCS (B : WeakCoherentBundle D) (h_sat : B.isSaturated) :
      WeakBMCS D
  ```
  - `families := B.families`
  - `modal_forward_eval`: For `Box phi ∈ eval_family.mcs t`:
    - `eval_family ∈ core_families` by `eval_family_in_core`
    - For other core families: by `core_mutually_coherent`
    - For witness families: by `witnesses_contain_core_boxclosure`
  - `modal_backward`: By saturation + contraposition (same as CoherentBundle.toBMCS)
- [ ] Prove `WeakBMCS_truth_lemma` (or verify existing truth lemma generalizes):
  - Box case: `Box phi ∈ eval_family.mcs t ↔ ∀ fam' ∈ families, phi ∈ fam'.mcs t`
  - Forward: by `modal_forward_eval`
  - Backward: by `modal_backward`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WeakBMCS.lean` (NEW FILE)

**Verification**:
- `lake build` succeeds
- No sorries
- Truth lemma proven

---

### Phase 5: Integration and Axiom Elimination [NOT STARTED]

**Goal:** Update main entry point to use `WeakCoherentBundle` and eliminate the axiom.

**Tasks**:
- [ ] Update `constructCoherentBundleFromContext` to return `WeakCoherentBundle`:
  ```lean
  def constructWeakCoherentBundleFromContext (Gamma : List Formula) (D : Type*) [...]
      (h_cons : ListConsistent Gamma) :
      { B : WeakCoherentBundle D // B.isSaturated ∧ ∀ phi ∈ Gamma, ∀ t, phi ∈ B.eval_family.mcs t }
  ```
  - Step 1: Build base MCS via Lindenbaum
  - Step 2: Build initial `WeakCoherentBundle` (singleton core, no witnesses)
  - Step 3: Saturate via `saturateWeakCoherentBundle`
- [ ] Update `construct_coherent_bmcs` to use `WeakBMCS`:
  ```lean
  def construct_weak_bmcs (Gamma : List Formula) (D : Type*) [...]
      (h_cons : ListConsistent Gamma) :
      { B : WeakBMCS D // ∀ phi ∈ Gamma, ∀ t, phi ∈ B.eval_family.mcs t }
  ```
- [ ] Delete or deprecate `saturated_extension_exists` axiom
- [ ] Verify completeness theorem compatibility:
  - Ensure `WeakBMCS` provides necessary properties for semantic evaluation
  - Create adapter if needed: `WeakBMCS.toBMCS` (may require additional hypotheses)
- [ ] Update module docstrings to document the new approach
- [ ] Add integration test: construct WeakBMCS for sample formula, verify saturation

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Update main entry points
- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` - Final integration
- `Theories/Bimodal/Metalogic/Bundle/WeakBMCS.lean` - Completeness integration

**Verification**:
- `lake build` succeeds with no errors
- `saturated_extension_exists` axiom REMOVED
- Grep confirms no sorries in new code
- Completeness theorem still compiles (possibly with new BMCS type)

## Testing & Validation

- [ ] `lake build` succeeds for entire project
- [ ] No new sorries: `grep -rn "sorry" Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` returns empty
- [ ] `saturated_extension_exists` axiom removed: `grep -rn "saturated_extension_exists" Theories/` shows only historical comments
- [ ] `constructWeakCoherentBundleFromContext` type-checks
- [ ] `construct_weak_bmcs` type-checks
- [ ] Context preservation proven without axiom
- [ ] Completeness theorem integration verified

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/WeakBMCS.lean` (NEW)
- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` (UPDATED)
- `specs/853_construct_coherentbundle_from_context/plans/implementation-002.md` (this plan)
- `specs/853_construct_coherentbundle_from_context/summaries/implementation-summary-YYYYMMDD.md` (final)

## Rollback/Contingency

**If WeakBMCS proves insufficient for completeness**:
1. Verify exactly which `modal_forward` uses require non-eval families
2. Consider strengthening `witnesses_contain_core_boxclosure` to full BoxContent
3. As last resort, keep axiom but document the gap precisely

**If Zorn chain upper bounds fail**:
1. Review `witness_families` union construction
2. May need additional invariant on witness construction timestamps
3. Consider finite iteration for bounded formula sets

**If downstream compatibility issues arise**:
1. Create `WeakBMCS.toBMCS` adapter with additional hypotheses
2. Both BMCS and WeakBMCS can coexist for different use cases
3. Document which properties require which structure

## Dependencies Between Phases

```
Phase 1 (WeakCoherentBundle)
    ↓
Phase 2 (Witness Construction)
    ↓
Phase 3 (Saturation via Zorn)
    ↓
Phase 4 (WeakBMCS Conversion)
    ↓
Phase 5 (Integration)
```

All phases are sequential. Phase 1 must complete before Phase 2 can begin, etc.
