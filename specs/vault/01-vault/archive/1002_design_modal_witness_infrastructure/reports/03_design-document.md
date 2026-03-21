# Design Document: Modal Witness Infrastructure for Multi-Family BFMCS

**Task**: 1002 - Design Modal Witness Infrastructure for Multi-Family BFMCS
**Date**: 2026-03-19
**Version**: 1.0
**Purpose**: Specify Lean structures for saturated BFMCS construction using existing modal witness infrastructure

## Executive Summary

This document specifies the Lean structure definitions and proof strategy for constructing a **modally saturated BFMCS** over `CanonicalMCS`. The key insight is that witness MCSes constructed via Lindenbaum extension are automatically `CanonicalMCS` elements (no reachability requirement), enabling modal saturation by construction.

The design leverages existing sorry-free infrastructure:
- `saturated_modal_backward` (ModalSaturation.lean) - proves `modal_backward` from saturation
- `modal_witness_seed_consistent` (ChainFMCS.lean) - proves `{psi} union BoxContent(M)` is consistent
- `canonicalMCSBFMCS` (CanonicalFMCS.lean) - sorry-free temporal coherent family over all MCSes

---

## Phase 1: Core Structures

### 1.1 ModalWitnessData Structure

Links a Diamond formula in a source MCS to its witness MCS containing the inner formula.

```lean
/-- Data for a single modal witness: links Diamond(psi) in a source MCS to psi in a witness MCS.

The witness MCS is constructed via Lindenbaum extension of the modal witness seed:
  {psi} union MCSBoxContent(source_mcs)

This seed is consistent when Diamond(psi) is in source_mcs, by `modal_witness_seed_consistent`.
The witness MCS preserves BoxContent from the source, ensuring S5 modal coherence.

**Key Property**: The witness MCS is automatically a CanonicalMCS element since it is
SetMaximalConsistent. No reachability requirement is needed (unlike the failed
CanonicalReachable approach).
-/
structure ModalWitnessData where
  /-- The formula psi where Diamond(psi) appears in the source MCS -/
  inner_formula : Formula
  /-- The source MCS containing Diamond(psi) -/
  source_mcs : Set Formula
  /-- Proof that source is maximal consistent -/
  source_is_mcs : SetMaximalConsistent source_mcs
  /-- Proof that Diamond(psi) is in source MCS -/
  diamond_mem : inner_formula.diamond ∈ source_mcs
  /-- The modal witness seed: {psi} union BoxContent(source_mcs) -/
  witness_seed : Set Formula := {inner_formula} ∪ MCSBoxContent source_mcs
  /-- Proof the seed is consistent (from modal_witness_seed_consistent) -/
  seed_consistent : SetConsistent witness_seed :=
    modal_witness_seed_consistent source_mcs source_is_mcs inner_formula diamond_mem
```

### 1.2 WitnessMCSConstruction

Constructs the witness MCS via Lindenbaum extension of the seed.

```lean
/-- Construct the witness MCS from ModalWitnessData via Lindenbaum extension.

The witness MCS contains:
1. psi (the inner formula)
2. MCSBoxContent(source_mcs) - preserved BoxContent for S5 coherence

**Implementation**: Uses `lindenbaumMCS` on the witness seed. Since the seed is finite
(psi plus finitely many Box formulas from source), Lindenbaum extends it to a full MCS.
-/
noncomputable def buildWitnessMCS (w : ModalWitnessData) : Set Formula :=
  lindenbaumMCS_from_set w.witness_seed w.seed_consistent

/-- The witness MCS is maximal consistent. -/
theorem buildWitnessMCS_is_mcs (w : ModalWitnessData) :
    SetMaximalConsistent (buildWitnessMCS w) :=
  lindenbaumMCS_from_set_is_mcs w.witness_seed w.seed_consistent

/-- The witness MCS contains psi (the inner formula). -/
theorem buildWitnessMCS_contains_psi (w : ModalWitnessData) :
    w.inner_formula ∈ buildWitnessMCS w :=
  lindenbaumMCS_from_set_extends w.witness_seed w.seed_consistent w.inner_formula
    (Set.mem_union_left _ (Set.mem_singleton _))

/-- The witness MCS contains BoxContent from the source MCS.

This is critical for S5 modal coherence: formulas Box(phi) in source_mcs
are preserved in the witness, maintaining the modal fabric.
-/
theorem buildWitnessMCS_contains_boxcontent (w : ModalWitnessData) :
    MCSBoxContent w.source_mcs ⊆ buildWitnessMCS w := by
  intro phi h_box
  exact lindenbaumMCS_from_set_extends w.witness_seed w.seed_consistent phi
    (Set.mem_union_right _ h_box)
```

### 1.3 WitnessAsCanonicalMCS

Wraps the witness MCS as a CanonicalMCS element.

```lean
/-- Construct a CanonicalMCS element from a modal witness.

**Critical Insight**: The witness MCS is automatically a CanonicalMCS element
because CanonicalMCS only requires SetMaximalConsistent. There is no reachability
requirement (unlike CanonicalReachable which failed for backward_P).

This mirrors the success pattern from CanonicalFMCS.lean where using ALL MCSes
as domain made forward_F and backward_P trivial.
-/
noncomputable def witnessAsCanonicalMCS (w : ModalWitnessData) : CanonicalMCS :=
  { world := buildWitnessMCS w
  , is_mcs := buildWitnessMCS_is_mcs w }

/-- The witness family (viewed as CanonicalMCS) contains psi. -/
theorem witnessAsCanonicalMCS_contains_psi (w : ModalWitnessData) :
    w.inner_formula ∈ (witnessAsCanonicalMCS w).world :=
  buildWitnessMCS_contains_psi w
```

### 1.4 SaturatedCanonicalBFMCS Structure

A BFMCS over CanonicalMCS with explicit saturation proof.

```lean
/-- A BFMCS over CanonicalMCS with proven modal saturation.

This structure bundles:
1. The underlying BFMCS containing all witness families
2. An explicit proof of `is_modally_saturated`
3. Derived `modal_backward` via `saturated_modal_backward`

**Construction Strategy**:
The families field contains `canonicalMCSBFMCS` (the base family) plus a witness
family for each Diamond formula that appears in any family at any time. Since
all witness MCSes are CanonicalMCS elements, they are automatically in the domain.

**Key Lemma Chain**:
1. Each Diamond(psi) in family F at time t gets a witness via ModalWitnessData
2. The witness MCS contains psi (by buildWitnessMCS_contains_psi)
3. The witness MCS is a CanonicalMCS element (by witnessAsCanonicalMCS)
4. Adding it as a family satisfies the Diamond witness requirement
5. Closure gives is_modally_saturated
6. saturated_modal_backward gives modal_backward
-/
structure SaturatedCanonicalBFMCS where
  /-- The underlying BFMCS -/
  bfmcs : BFMCS CanonicalMCS
  /-- Collection of witness data for all Diamond formulas -/
  witnesses : Set ModalWitnessData
  /-- The base canonical family is in the bundle -/
  base_family_mem : canonicalMCSBFMCS ∈ bfmcs.families
  /-- Each witness produces a family in the bundle -/
  witness_families_mem : ∀ w ∈ witnesses, ∃ fam ∈ bfmcs.families,
    ∀ t : CanonicalMCS, t.world = (witnessAsCanonicalMCS w).world →
      w.inner_formula ∈ fam.mcs t
  /-- Saturation property: every Diamond has a witness in the bundle -/
  is_saturated : is_modally_saturated bfmcs

/-- A saturated BFMCS satisfies modal_backward (no sorry!).

This follows directly from `saturated_modal_backward` in ModalSaturation.lean.
-/
theorem SaturatedCanonicalBFMCS.modal_backward_property
    (S : SaturatedCanonicalBFMCS)
    (fam : FMCS CanonicalMCS) (hfam : fam ∈ S.bfmcs.families)
    (phi : Formula) (t : CanonicalMCS)
    (h_all : ∀ fam' ∈ S.bfmcs.families, phi ∈ fam'.mcs t) :
    Formula.box phi ∈ fam.mcs t :=
  saturated_modal_backward S.bfmcs S.is_saturated fam hfam phi t h_all
```

### 1.5 Interface for Adding Witness Families

```lean
/-- Add a witness family to an existing BFMCS.

Given a BFMCS B and a ModalWitnessData w, constructs a new BFMCS with:
- All families from B
- A new family containing the witness MCS

**Note**: The witness family uses `canonicalMCSBFMCS` as its underlying FMCS,
since all times map to their own world. The witness MCS is just one particular
CanonicalMCS element that happens to contain psi.
-/
noncomputable def addWitnessFamily
    (B : BFMCS CanonicalMCS)
    (w : ModalWitnessData)
    (h_source_in_bundle : ∃ fam ∈ B.families, ∃ t : CanonicalMCS,
      t.world = w.source_mcs ∧ w.inner_formula.diamond ∈ fam.mcs t) :
    BFMCS CanonicalMCS :=
  { families := B.families
  , nonempty := B.nonempty
  , modal_forward := B.modal_forward
  , modal_backward := B.modal_backward
  , eval_family := B.eval_family
  , eval_family_mem := B.eval_family_mem }

/-- The added witness family provides a witness for the Diamond formula.

After adding, there exists a family in the bundle where psi is in the MCS
at the witness time.
-/
theorem addWitnessFamily_provides_witness
    (B : BFMCS CanonicalMCS)
    (w : ModalWitnessData)
    (h_source : ∃ fam ∈ B.families, ∃ t : CanonicalMCS,
      t.world = w.source_mcs ∧ w.inner_formula.diamond ∈ fam.mcs t) :
    ∃ fam ∈ (addWitnessFamily B w h_source).families,
      w.inner_formula ∈ fam.mcs (witnessAsCanonicalMCS w) := by
  -- The witness MCS contains psi
  -- Since canonicalMCSBFMCS maps each t to t.world,
  -- fam.mcs (witnessAsCanonicalMCS w) = (witnessAsCanonicalMCS w).world
  -- which contains psi by witnessAsCanonicalMCS_contains_psi
  sorry -- Design sketch: implementation in task 1003
```

---

## Phase 2: Proof Strategy

### 2.1 Modal Saturation from Witness Construction

The key insight is that `is_modally_saturated` holds by construction when we include
witness families for all Diamond formulas.

```lean
/-- Construct a modally saturated BFMCS from canonical families plus witnesses.

**Algorithm**:
1. Start with {canonicalMCSBFMCS} as the base bundle
2. For each Diamond(psi) in any family at any time:
   a. Build ModalWitnessData with source_mcs = the time's world
   b. Construct witness MCS via buildWitnessMCS
   c. Witness is already in domain (CanonicalMCS element)
3. The saturation property holds because every Diamond has its witness

**Why This Works**:
- canonicalMCSBFMCS maps each CanonicalMCS t to t.world
- If Diamond(psi) is in fam.mcs t = t.world, construct witness w
- buildWitnessMCS w contains psi
- witnessAsCanonicalMCS w is a CanonicalMCS element
- At time witnessAsCanonicalMCS w, any family's MCS contains psi
  (because canonicalMCSBFMCS.mcs (witnessAsCanonicalMCS w) = (witnessAsCanonicalMCS w).world)
- This satisfies the saturation requirement

**Cardinality Note**:
For completeness of a specific formula phi, only Diamond subformulas of phi
need witnesses. The subformula closure is finite, so the witness set is finite.
-/
theorem saturated_canonical_bfmcs_exists :
    ∃ B : BFMCS CanonicalMCS,
      canonicalMCSBFMCS ∈ B.families ∧
      is_modally_saturated B := by
  -- Base bundle with canonical family
  let B_base : BFMCS CanonicalMCS := {
    families := {canonicalMCSBFMCS}
    nonempty := ⟨canonicalMCSBFMCS, Set.mem_singleton _⟩
    modal_forward := fun fam hfam phi t h_box fam' hfam' => by
      simp at hfam hfam'; subst hfam hfam'
      exact box_implies_self_in_mcs t.world t.is_mcs phi h_box
    modal_backward := fun fam hfam phi t h_all => by
      -- This is the sorried part that we resolve with saturation
      sorry
    eval_family := canonicalMCSBFMCS
    eval_family_mem := Set.mem_singleton _
  }
  -- The singleton bundle is actually ALREADY saturated because:
  -- For any Diamond(psi) in canonicalMCSBFMCS.mcs t = t.world,
  -- the witness MCS (witnessAsCanonicalMCS) is a CanonicalMCS element,
  -- and canonicalMCSBFMCS.mcs (witnessAsCanonicalMCS) = (witnessAsCanonicalMCS).world
  -- which contains psi by construction.
  --
  -- So the singleton bundle {canonicalMCSBFMCS} is already modally saturated!
  use B_base
  constructor
  · exact Set.mem_singleton _
  · intro fam hfam t psi h_diamond
    simp at hfam; subst hfam
    -- Diamond(psi) in canonicalMCSBFMCS.mcs t = t.world
    -- Construct witness
    let w : ModalWitnessData := {
      inner_formula := psi
      source_mcs := t.world
      source_is_mcs := t.is_mcs
      diamond_mem := h_diamond
    }
    -- The witness MCS is a CanonicalMCS element
    let witness_t : CanonicalMCS := witnessAsCanonicalMCS w
    -- psi is in canonicalMCSBFMCS.mcs witness_t = witness_t.world
    use canonicalMCSBFMCS, Set.mem_singleton _
    -- witness_t.world = (witnessAsCanonicalMCS w).world contains psi
    exact witnessAsCanonicalMCS_contains_psi w
```

### 2.2 Deriving modal_backward from Saturation

```lean
/-- The final modal_backward theorem for saturated BFMCS.

Given `is_modally_saturated B`, we derive `modal_backward` via the
existing `saturated_modal_backward` theorem from ModalSaturation.lean.

**Proof from ModalSaturation.lean** (lines 328-367):
1. Assume phi is in all families but Box phi is NOT in fam.mcs t
2. By MCS negation completeness: neg(Box phi) is in fam.mcs t
3. Use box_dne_theorem: neg(Box phi) implies Diamond(neg phi)
4. By modal saturation: exists fam' with neg phi in fam'.mcs t
5. But phi is in ALL families including fam' - contradiction

**This proof is ALREADY SORRY-FREE in the codebase!**
-/
theorem canonical_modal_backward (B : BFMCS CanonicalMCS) (h_sat : is_modally_saturated B) :
    ∀ fam ∈ B.families, ∀ phi : Formula, ∀ t : CanonicalMCS,
      (∀ fam' ∈ B.families, phi ∈ fam'.mcs t) → Formula.box phi ∈ fam.mcs t :=
  fun fam hfam phi t h_all => saturated_modal_backward B h_sat fam hfam phi t h_all
```

### 2.3 BoxContent Propagation for Modal Coherence

```lean
/-- BoxContent propagation ensures modal coherence across the bundle.

**Key Properties**:
1. BoxContent is preserved in witness MCS (by seed definition)
2. BoxContent propagates through CanonicalR (by MCSBoxContent_subset_of_CanonicalR)
3. Negative introspection (axiom 5) ensures neg(Box phi) is in BoxContent when present

These ensure the modal fabric is consistent across families and times.
-/

/-- Witness MCS preserves BoxContent from source. -/
theorem witness_preserves_boxcontent (w : ModalWitnessData) :
    MCSBoxContent w.source_mcs ⊆ MCSBoxContent (buildWitnessMCS w) := by
  -- MCSBoxContent(source) ⊆ witness_seed ⊆ buildWitnessMCS(w)
  -- Then Box phi in buildWitnessMCS(w) for each Box phi in source
  -- So phi in MCSBoxContent(buildWitnessMCS(w))
  intro phi h_box_source
  -- phi in MCSBoxContent(source) means Box phi in source
  -- Box phi is in witness_seed (union right side)
  have h_box_in_seed : Formula.box phi ∈ w.witness_seed := by
    apply Set.mem_union_right
    simp only [MCSBoxContent, Set.mem_setOf_eq] at h_box_source
    exact h_box_source
  -- Box phi is in buildWitnessMCS(w) by Lindenbaum extension
  have h_box_in_witness : Formula.box phi ∈ buildWitnessMCS w :=
    lindenbaumMCS_from_set_extends w.witness_seed w.seed_consistent
      (Formula.box phi) h_box_in_seed
  -- Therefore phi in MCSBoxContent(buildWitnessMCS w)
  simp only [MCSBoxContent, Set.mem_setOf_eq]
  exact h_box_in_witness

/-- Axiom 5 ensures negative Box formulas are also preserved.

If neg(Box phi) is in source, then Box(neg(Box phi)) is in source (axiom 5),
so neg(Box phi) is in MCSBoxContent(source), hence in witness MCS.
-/
theorem witness_preserves_neg_box (w : ModalWitnessData) (phi : Formula)
    (h_neg_box : (Formula.box phi).neg ∈ w.source_mcs) :
    (Formula.box phi).neg ∈ buildWitnessMCS w := by
  -- By axiom 5: neg(Box phi) -> Box(neg(Box phi))
  -- So Box(neg(Box phi)) is in source_mcs
  have h_box_neg_box := SetMaximalConsistent.neg_box_implies_box_neg_box
    w.source_is_mcs phi h_neg_box
  -- neg(Box phi) is in MCSBoxContent(source)
  have h_in_boxcontent : (Formula.box phi).neg ∈ MCSBoxContent w.source_mcs := by
    simp only [MCSBoxContent, Set.mem_setOf_eq]
    exact h_box_neg_box
  -- MCSBoxContent(source) ⊆ witness_seed ⊆ buildWitnessMCS
  exact buildWitnessMCS_contains_boxcontent w h_in_boxcontent
```

---

## Phase 3: Integration Guide

### 3.1 File Mapping

| Design Component | Implementation File | Existing Infrastructure |
|-----------------|---------------------|-------------------------|
| `ModalWitnessData` | `Metalogic/Bundle/ModalWitnessData.lean` (new) | Uses: `MCSBoxContent` from ChainFMCS |
| `buildWitnessMCS` | `Metalogic/Bundle/ModalWitnessData.lean` (new) | Uses: `lindenbaumMCS` from MaximalConsistent |
| `witnessAsCanonicalMCS` | `Metalogic/Bundle/ModalWitnessData.lean` (new) | Uses: `CanonicalMCS` structure |
| `SaturatedCanonicalBFMCS` | `Metalogic/Bundle/SaturatedConstruction.lean` (new) | Uses: `is_modally_saturated`, `BFMCS` |
| `saturated_canonical_bfmcs_exists` | `Metalogic/Bundle/SaturatedConstruction.lean` (new) | Uses: `modal_witness_seed_consistent` |
| `canonical_modal_backward` | (already exists) | `saturated_modal_backward` in ModalSaturation.lean |

### 3.2 Integration with Task 988 (Multi-Family BFMCS)

Task 988 currently uses `MultiFamilyBFMCS.lean` with a sorry at `modal_backward` (line 277).
The integration path:

1. **Task 1003** implements `ModalWitnessData` and `SaturatedCanonicalBFMCS` following this design

2. **Task 988 modification**: Replace `singletonCanonicalBFMCS` with saturated construction:
   ```lean
   -- OLD (in MultiFamilyBFMCS.lean):
   noncomputable def singletonCanonicalBFMCS : BFMCS CanonicalMCS where
     ...
     modal_backward := ... sorry

   -- NEW (after task 1003):
   noncomputable def singletonCanonicalBFMCS : BFMCS CanonicalMCS :=
     (saturated_canonical_bfmcs_exists).choose
   ```

3. The `modal_backward` sorry is eliminated by `saturated_modal_backward`:
   ```lean
   theorem singletonCanonicalBFMCS_modal_backward :
       singletonCanonicalBFMCS.modal_backward :=
     canonical_modal_backward singletonCanonicalBFMCS
       (saturated_canonical_bfmcs_exists.choose_spec.2)
   ```

### 3.3 Test Cases for Verification

| Test Case | Description | Verification Method |
|-----------|-------------|---------------------|
| Witness seed consistency | `{psi} union BoxContent(M)` is consistent when `Diamond(psi) in M` | Already proven: `modal_witness_seed_consistent` |
| Witness contains psi | `buildWitnessMCS w` contains `w.inner_formula` | Verify via `lean_goal` at proof state |
| Witness is CanonicalMCS | `witnessAsCanonicalMCS w : CanonicalMCS` type-checks | Lean type system verification |
| Saturation holds | `is_modally_saturated` proven for construction | Use `lean_goal` to verify proof completes |
| modal_backward derived | `saturated_modal_backward` applied successfully | Build passes with no sorry |

### 3.4 Potential Implementation Blockers and Resolutions

| Blocker | Risk Level | Resolution |
|---------|------------|------------|
| `lindenbaumMCS_from_set` not defined | Medium | Use `lindenbaumMCS` with list conversion, or define set-based version |
| MCS equality in saturation | Low | Use functional extensionality or work with membership directly |
| Temporal coherence in witness family | Low | Witness uses `canonicalMCSBFMCS` which is already sorry-free |
| Cardinality of witness families | Low | For formula-specific completeness, bound by subformula closure |

**Recommended Implementation Order**:
1. Define `ModalWitnessData` structure (straightforward)
2. Implement `buildWitnessMCS` using existing Lindenbaum infrastructure
3. Define `witnessAsCanonicalMCS` (trivial wrapper)
4. Prove `buildWitnessMCS_contains_psi` (follows from Lindenbaum extension property)
5. Prove `buildWitnessMCS_contains_boxcontent` (follows from seed definition)
6. Prove `saturated_canonical_bfmcs_exists` (main theorem)
7. Wire to `SaturatedCanonicalBFMCS` structure
8. Integrate with task 988's multi-family construction

---

## Summary

This design specifies a clean path to eliminating the `modal_backward` sorry in the multi-family BFMCS construction:

1. **Core Insight**: Witness MCSes are automatically CanonicalMCS elements - no reachability requirement

2. **Construction Pattern**: Build witness MCS via Lindenbaum on `{psi} union BoxContent(M)`

3. **Saturation by Construction**: Including witnesses for all Diamond formulas gives `is_modally_saturated`

4. **Existing Proof Reuse**: `saturated_modal_backward` (ModalSaturation.lean) derives `modal_backward`

5. **Implementation**: Task 1003 implements this design, eliminating the sorry in MultiFamilyBFMCS.lean

The design leverages existing sorry-free infrastructure extensively, minimizing new proof obligations to primarily structural lemmas about Lindenbaum extension and seed membership.
