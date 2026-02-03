import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation

/-!
# Coherent Witness Chain Construction

This module implements the Coherent Witness Chain construction for eliminating
`singleFamily_modal_backward_axiom` from Construction.lean.

## Background

The previous Pre-Coherent Bundle approach (implementation-001.md) failed because
it relied on a false claim: that S-boundedness (an intra-family property) could
enforce box-coherence (an inter-family property). These properties are orthogonal.

## Key Insight

**Any "product of all families satisfying local property P" approach will fail**
because local properties cannot force global agreement. The bundle construction
must BUILD agreement into the construction process.

## Approach: Coherent Witness Chain

The Coherent Witness Chain approach constructs witnesses that are coherent BY DESIGN:

1. Define `BoxContent(fam)` = set of all chi where Box chi appears in fam.mcs at any time
2. Define `WitnessSeed(base, psi)` = {psi} ∪ BoxContent(base)
3. Prove `diamond_boxcontent_consistent`: If Diamond psi ∈ base.mcs t, then WitnessSeed is consistent
4. Build witnesses from WitnessSeed via Lindenbaum - coherence follows from seed inclusion

## Important Note: Constant Families

The key theorem `diamond_boxcontent_consistent` is proven for **constant families**
(where `fam.mcs t = fam.mcs s` for all t, s). This is exactly what we have in practice:
the base family is always constructed via `constantIndexedMCSFamily`.

For non-constant families, BoxContent (spanning all times) may include formulas
whose boxes exist at different times, making the time-coherence argument fail.

## Main Results

### Phase 1-3: CoherentWitness (Task 844)
- `BoxContent`: Set of formulas whose boxes appear in a family
- `WitnessSeed`: The seed for constructing coherent witnesses
- `diamond_boxcontent_consistent_constant`: Core viability lemma for constant families
- `CoherentWitness`: A witness family with built-in coherence proof
- `constructCoherentWitness`: Construct a coherent witness for Diamond formulas

### Phase 4-7: CoherentBundle (Task 851)
- `UnionBoxContent`: Union of BoxContent across all families in a set
- `MutuallyCoherent`: Predicate ensuring all families contain entire UnionBoxContent
- `CoherentBundle`: Structure collecting mutually coherent constant families
- `CoherentBundle.isSaturated`: Saturation predicate for BMCS construction
- `CoherentBundle.toBMCS`: Convert saturated bundle to BMCS (no sorries!)
- Basic lemmas: `chi_in_all_families`, `families_box_coherent`, `member_contains_union_boxcontent`

## CoherentBundle Approach

The CoherentBundle structure provides an axiom-free path to BMCS construction:

1. **Constant families**: All families in a CoherentBundle are constant (time-independent MCS)
2. **Mutual coherence**: Every family contains the UnionBoxContent from ALL families
3. **Saturation**: Every neg(Box phi) formula has a witness family containing neg phi
4. **BMCS conversion**: Saturated CoherentBundle converts to BMCS with proven modal_forward/backward

The key insight is that constant-family witnesses avoid the Lindenbaum control problem
(where Lindenbaum extension might add uncontrolled Box formulas) because their BoxContent
is time-independent.

## References

- Research report: specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-002.md
- Implementation plan: specs/844_redesign_metalogic_precoherent_bundle_construction/plans/implementation-002.md
- CoherentBundle research: specs/851_define_coherentbundle_structure/reports/research-001.md
- CoherentBundle plan: specs/851_define_coherentbundle_structure/plans/implementation-001.md
- Failed approach: Bimodal.Metalogic.Bundle.PreCoherentBundle
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Phase 1: BoxContent and WitnessSeed Definitions
-/

/--
BoxContent of a family: the set of all formulas chi where Box chi appears
in the family's MCS at any time.

This captures "what the family believes is necessary". For a witness to be
coherent with this family, the witness must contain all of BoxContent.
-/
def BoxContent (fam : IndexedMCSFamily D) : Set Formula :=
  {chi | ∃ t : D, Formula.box chi ∈ fam.mcs t}

/--
BoxContent at a specific time: the set of all chi where Box chi is in fam.mcs t.

This is a time-restricted version used for some proofs.
-/
def BoxContentAt (fam : IndexedMCSFamily D) (t : D) : Set Formula :=
  {chi | Formula.box chi ∈ fam.mcs t}

/--
BoxContentAt is a subset of BoxContent.
-/
lemma BoxContentAt_subset_BoxContent (fam : IndexedMCSFamily D) (t : D) :
    BoxContentAt fam t ⊆ BoxContent fam := by
  intro chi h_at
  exact ⟨t, h_at⟩

/--
If Box chi is in the family's MCS at time t, then chi is in BoxContent.
-/
lemma box_mem_implies_boxcontent (fam : IndexedMCSFamily D) (chi : Formula) (t : D)
    (h : Formula.box chi ∈ fam.mcs t) : chi ∈ BoxContent fam :=
  ⟨t, h⟩

/--
WitnessSeed for constructing a coherent witness for Diamond psi.

The seed is {psi} ∪ BoxContent(base). This ensures:
1. The witness contains psi (witnessing the Diamond)
2. The witness contains all chi where Box chi is in base (ensuring coherence)
-/
def WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) : Set Formula :=
  {psi} ∪ BoxContent base

/--
psi is in its own WitnessSeed.
-/
lemma psi_mem_WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) :
    psi ∈ WitnessSeed base psi :=
  Set.mem_union_left _ (Set.mem_singleton psi)

/--
BoxContent is a subset of WitnessSeed.
-/
lemma BoxContent_subset_WitnessSeed (base : IndexedMCSFamily D) (psi : Formula) :
    BoxContent base ⊆ WitnessSeed base psi :=
  Set.subset_union_right

/--
If Box chi is in base.mcs at any time, then chi is in WitnessSeed.
-/
lemma box_in_base_implies_WitnessSeed (base : IndexedMCSFamily D) (psi chi : Formula) (t : D)
    (h : Formula.box chi ∈ base.mcs t) : chi ∈ WitnessSeed base psi :=
  BoxContent_subset_WitnessSeed base psi (box_mem_implies_boxcontent base chi t h)

/-!
## Phase 1: CoherentWitness Structure

A CoherentWitness bundles a witness family with proofs that:
1. It contains the witnessed formula psi
2. It contains all of BoxContent (ensuring coherence with base)
-/

/--
A coherent witness for a Diamond psi formula.

This structure captures a witness family that:
- Contains psi (witnessing Diamond psi)
- Contains BoxContent(base) at all times (ensuring coherence with base)

The coherence property is crucial: it ensures that when we build a bundle
from a base and its witnesses, box-coherence holds BY CONSTRUCTION.
-/
structure CoherentWitness (base : IndexedMCSFamily D) where
  /-- The witness family -/
  family : IndexedMCSFamily D
  /-- The formula being witnessed (inner formula of Diamond) -/
  witnessed : Formula
  /-- The witness contains the witnessed formula at all times -/
  contains_witnessed : ∀ t : D, witnessed ∈ family.mcs t
  /-- The witness contains all of BoxContent(base) at all times -/
  contains_boxcontent : ∀ chi, chi ∈ BoxContent base → ∀ t : D, chi ∈ family.mcs t

/--
A CoherentWitness's family contains chi at time t if Box chi is in base at any time s.

This is the key coherence property that makes box-coherence work.
-/
lemma CoherentWitness.coherent_with_base (base : IndexedMCSFamily D)
    (w : CoherentWitness base) (chi : Formula) (s t : D)
    (h_box : Formula.box chi ∈ base.mcs s) : chi ∈ w.family.mcs t :=
  w.contains_boxcontent chi ⟨s, h_box⟩ t

/-!
## Phase 2: The diamond_boxcontent_consistent Lemma for Constant Families

For a constant family (where `fam.mcs t = fam.mcs s` for all t, s), we have
`BoxContent fam = BoxContentAt fam t` for any t. This simplifies the consistency proof.
-/

/--
A family is constant if its MCS is the same at all times.
-/
def IsConstantFamily (fam : IndexedMCSFamily D) : Prop :=
  ∃ M : Set Formula, ∀ t : D, fam.mcs t = M

/--
For a constant family, BoxContent equals BoxContentAt for any time.
-/
lemma constant_family_BoxContent_eq (fam : IndexedMCSFamily D)
    (h_const : IsConstantFamily fam) (t : D) :
    BoxContent fam = BoxContentAt fam t := by
  rcases h_const with ⟨M, hM⟩
  ext chi
  constructor
  · intro ⟨s, h_box_s⟩
    rw [hM s] at h_box_s
    rw [← hM t] at h_box_s
    exact h_box_s
  · intro h_box_t
    exact ⟨t, h_box_t⟩

/--
**Core Viability Lemma for Constant Families**:

If Diamond psi ∈ base.mcs t for a constant family base,
then {psi} ∪ BoxContent(base) is set-consistent.

**Proof Strategy**:
Since base is constant, BoxContent = BoxContentAt t.
We can then use the standard modal consistency argument at time t.

**Key Insight**: For constant families, all Box formulas appearing at any time
also appear at time t, so the K-distribution argument works at time t.

**Technical Gap**: The full proof requires K-distribution chain formalization.
The proof sketch is complete; see research-002.md for details.
-/
theorem diamond_boxcontent_consistent_constant (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) (psi : Formula) (t : D)
    (h_diamond : diamondFormula psi ∈ base.mcs t) :
    SetConsistent (WitnessSeed base psi) := by
  intro L hL_sub ⟨d⟩

  rcases h_const with ⟨M, hM⟩

  -- Partition L into psi-part and BoxContent-part
  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    have h_filt_in_M : ∀ chi ∈ L_filt, chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [WitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_box
      · exact absurd h_eq h_ne
      · rcases h_box with ⟨s, h_box_s⟩
        rw [hM s] at h_box_s
        have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
        exact set_mcs_implication_property (by rw [← hM t]; exact base.is_mcs t)
          (theorem_in_mcs (by rw [← hM t]; exact base.is_mcs t) h_T) h_box_s

    -- Step 1: Prove that Box chi ∈ M for each chi ∈ L_filt
    -- (We already used T-axiom to get chi ∈ M, but we also have the original Box chi ∈ M)
    have h_box_filt_in_M : ∀ chi ∈ L_filt, Formula.box chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [WitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_box
      · exact absurd h_eq h_ne
      · rcases h_box with ⟨s, h_box_s⟩
        rw [hM s] at h_box_s
        exact h_box_s

    -- Step 2: Apply generalized_modal_k to transform L_filt ⊢ neg psi
    --         into Box(L_filt) ⊢ Box(neg psi)
    have d_box_neg : (Context.map Formula.box L_filt) ⊢ Formula.box (Formula.neg psi) :=
      Bimodal.Theorems.generalized_modal_k L_filt (Formula.neg psi) d_neg

    -- Step 3: All formulas in Box(L_filt) are in M
    have h_box_context_in_M : ∀ phi ∈ Context.map Formula.box L_filt, phi ∈ M := by
      intro phi h_mem
      rw [Context.mem_map_iff] at h_mem
      rcases h_mem with ⟨chi, h_chi_in, h_eq⟩
      rw [← h_eq]
      exact h_box_filt_in_M chi h_chi_in

    -- Step 4: By MCS closure under derivation, Box(neg psi) ∈ M
    have h_mcs : SetMaximalConsistent M := by rw [← hM t]; exact base.is_mcs t
    have h_box_neg_in_M : Formula.box (Formula.neg psi) ∈ M :=
      set_mcs_closed_under_derivation h_mcs (Context.map Formula.box L_filt)
        h_box_context_in_M d_box_neg

    -- Step 5: Contradiction - Diamond psi = neg(Box(neg psi)) is also in M
    have h_diamond_eq : diamondFormula psi = Formula.neg (Formula.box (Formula.neg psi)) := rfl
    rw [hM t] at h_diamond
    rw [h_diamond_eq] at h_diamond
    exact set_consistent_not_both h_mcs.1 (Formula.box (Formula.neg psi)) h_box_neg_in_M h_diamond

  · -- Case: psi ∉ L, so L ⊆ BoxContent
    have h_L_in_M : ∀ chi ∈ L, chi ∈ M := by
      intro chi h_mem
      have h_in_seed := hL_sub chi h_mem
      simp only [WitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_box
      · exact absurd h_eq (fun h => h_psi_in (h ▸ h_mem))
      · rcases h_box with ⟨s, h_box_s⟩
        rw [hM s] at h_box_s
        have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
        exact set_mcs_implication_property (by rw [← hM t]; exact base.is_mcs t)
          (theorem_in_mcs (by rw [← hM t]; exact base.is_mcs t) h_T) h_box_s

    have h_mcs : SetMaximalConsistent M := by rw [← hM t]; exact base.is_mcs t
    exact h_mcs.1 L h_L_in_M ⟨d⟩

/-!
## Phase 3: Construct Coherent Witness Families

Given that WitnessSeed is consistent (for constant families), we can extend it
to an MCS via Lindenbaum and build a constant witness family.
-/

/--
Construct a coherent witness for Diamond psi from a constant base family.

This combines:
1. WitnessSeed consistency (from diamond_boxcontent_consistent_constant)
2. Lindenbaum extension to MCS
3. Constant family construction
-/
noncomputable def constructCoherentWitness (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) (psi : Formula) (t : D)
    (h_diamond : diamondFormula psi ∈ base.mcs t) : CoherentWitness base :=
  let h_seed_cons := diamond_boxcontent_consistent_constant base h_const psi t h_diamond
  let lindenbaum_result := set_lindenbaum (WitnessSeed base psi) h_seed_cons
  let W := Classical.choose lindenbaum_result
  let h_spec := Classical.choose_spec lindenbaum_result
  let h_extends := h_spec.1
  let h_W_mcs := h_spec.2
  let witness_fam := constantWitnessFamily W h_W_mcs (D := D)
  {
    family := witness_fam
    witnessed := psi
    contains_witnessed := fun s => h_extends (psi_mem_WitnessSeed base psi)
    contains_boxcontent := fun chi h_chi s => h_extends (BoxContent_subset_WitnessSeed base psi h_chi)
  }

/--
The constructed witness contains psi at all times.
-/
lemma constructCoherentWitness_contains_psi (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) (psi : Formula) (t s : D)
    (h_diamond : diamondFormula psi ∈ base.mcs t) :
    psi ∈ (constructCoherentWitness base h_const psi t h_diamond).family.mcs s :=
  (constructCoherentWitness base h_const psi t h_diamond).contains_witnessed s

/--
The constructed witness is coherent with the base family.
-/
lemma constructCoherentWitness_coherent (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) (psi chi : Formula) (t s r : D)
    (h_diamond : diamondFormula psi ∈ base.mcs t)
    (h_box : Formula.box chi ∈ base.mcs s) :
    chi ∈ (constructCoherentWitness base h_const psi t h_diamond).family.mcs r :=
  (constructCoherentWitness base h_const psi t h_diamond).contains_boxcontent chi ⟨s, h_box⟩ r

/-!
## Phase 4: UnionBoxContent and MutuallyCoherent Definitions

UnionBoxContent collects the BoxContent from ALL families in a set.
MutuallyCoherent ensures every family contains the entire UnionBoxContent.
-/

/--
UnionBoxContent of a family set: the set of all formulas chi where Box chi appears
in any family's MCS at any time.

This generalizes BoxContent from a single family to a set of families.
For a CoherentBundle, every family must contain this entire set.
-/
def UnionBoxContent (families : Set (IndexedMCSFamily D)) : Set Formula :=
  {chi | ∃ fam ∈ families, chi ∈ BoxContent fam}

/--
BoxContent of a single family is a subset of UnionBoxContent.
-/
lemma BoxContent_subset_UnionBoxContent (families : Set (IndexedMCSFamily D))
    (fam : IndexedMCSFamily D) (h_mem : fam ∈ families) :
    BoxContent fam ⊆ UnionBoxContent families := by
  intro chi h_chi
  exact ⟨fam, h_mem, h_chi⟩

/--
UnionBoxContent is monotone: adding families only increases the union.
-/
lemma UnionBoxContent_monotone (families1 families2 : Set (IndexedMCSFamily D))
    (h_sub : families1 ⊆ families2) :
    UnionBoxContent families1 ⊆ UnionBoxContent families2 := by
  intro chi ⟨fam, h_fam_mem, h_chi⟩
  exact ⟨fam, h_sub h_fam_mem, h_chi⟩

/--
MutuallyCoherent predicate: all families contain the entire UnionBoxContent at all times.

This is the key invariant for CoherentBundle. It ensures that box-coherence holds
between ALL families, not just between a witness and its base.
-/
def MutuallyCoherent (families : Set (IndexedMCSFamily D)) : Prop :=
  ∀ fam ∈ families, ∀ chi ∈ UnionBoxContent families, ∀ t : D, chi ∈ fam.mcs t

/--
A singleton set containing a constant family is trivially mutually coherent.

This is because the UnionBoxContent equals BoxContent of that single family,
and by the T-axiom, every chi in BoxContent is in the family's MCS.
-/
lemma MutuallyCoherent_singleton (fam : IndexedMCSFamily D) (h_const : IsConstantFamily fam) :
    MutuallyCoherent ({fam} : Set (IndexedMCSFamily D)) := by
  intro fam' h_fam'_mem chi h_chi_in_union t
  -- fam' must be fam
  simp only [Set.mem_singleton_iff] at h_fam'_mem
  rw [h_fam'_mem]
  -- chi is in UnionBoxContent {fam} = BoxContent fam
  rcases h_chi_in_union with ⟨fam'', h_fam''_mem, h_chi_in_box⟩
  simp only [Set.mem_singleton_iff] at h_fam''_mem
  rw [h_fam''_mem] at h_chi_in_box
  -- h_chi_in_box : chi ∈ BoxContent fam, i.e., ∃ s, Box chi ∈ fam.mcs s
  rcases h_chi_in_box with ⟨s, h_box_s⟩
  -- Since fam is constant, fam.mcs t = fam.mcs s
  rcases h_const with ⟨M, hM⟩
  rw [hM s] at h_box_s
  rw [hM t]
  -- Apply T-axiom: Box chi → chi
  have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
  exact set_mcs_implication_property (by rw [← hM t]; exact fam.is_mcs t)
    (theorem_in_mcs (by rw [← hM t]; exact fam.is_mcs t) h_T) h_box_s

/-!
## Phase 5: CoherentBundle Structure Definition

A CoherentBundle is a collection of constant IndexedMCSFamilies that are mutually coherent.
This structure is the key to eliminating `singleFamily_modal_backward_axiom`.
-/

/--
CoherentBundle: A collection of mutually coherent constant families.

A CoherentBundle satisfies:
1. All families are constant (time-independent MCS)
2. The collection is nonempty
3. There is a designated evaluation family
4. All families are mutually coherent (share BoxContent)

This structure enables axiom-free BMCS construction when combined with saturation.
-/
structure CoherentBundle (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- The set of families in the bundle -/
  families : Set (IndexedMCSFamily D)
  /-- All families are constant (time-independent) -/
  all_constant : ∀ fam ∈ families, IsConstantFamily fam
  /-- The bundle is nonempty -/
  nonempty : families.Nonempty
  /-- The designated evaluation family -/
  eval_family : IndexedMCSFamily D
  /-- The evaluation family is in the bundle -/
  eval_family_mem : eval_family ∈ families
  /-- All families contain UnionBoxContent at all times -/
  mutually_coherent : MutuallyCoherent families

/--
A CoherentBundle is saturated if for every formula phi and every family fam,
if neg(Box phi) is in fam.mcs t, then there exists a family containing neg phi.

This is the natural saturation property matching the modal_backward requirement.
The formulation uses neg(Box phi) directly rather than Diamond form to avoid
syntactic mismatch issues (since Diamond psi = psi.neg.box.neg != phi.box.neg).
-/
def CoherentBundle.isSaturated (B : CoherentBundle D) : Prop :=
  ∀ phi : Formula, ∀ fam ∈ B.families, ∀ t : D,
    Formula.neg (Formula.box phi) ∈ fam.mcs t →
    ∃ fam' ∈ B.families, Formula.neg phi ∈ fam'.mcs t

/--
The evaluation family of a CoherentBundle is constant.
-/
lemma CoherentBundle.eval_family_constant (B : CoherentBundle D) :
    IsConstantFamily B.eval_family :=
  B.all_constant B.eval_family B.eval_family_mem

/-!
## Phase 6: Basic CoherentBundle Properties
-/

/--
If Box chi is in any family at any time, then chi is in all families at all times.

This is the key coherence property that follows from MutuallyCoherent.
-/
lemma CoherentBundle.chi_in_all_families (B : CoherentBundle D)
    (chi : Formula) (fam : IndexedMCSFamily D) (h_fam : fam ∈ B.families)
    (s : D) (h_box : Formula.box chi ∈ fam.mcs s)
    (fam' : IndexedMCSFamily D) (h_fam' : fam' ∈ B.families) (t : D) :
    chi ∈ fam'.mcs t := by
  -- chi is in UnionBoxContent B.families
  have h_chi_in_union : chi ∈ UnionBoxContent B.families := by
    exact ⟨fam, h_fam, ⟨s, h_box⟩⟩
  -- By mutual coherence, chi is in fam'.mcs t
  exact B.mutually_coherent fam' h_fam' chi h_chi_in_union t

/--
For constant families, BoxContent is determined by the MCS at any single time.

Since all families in a CoherentBundle are constant, their BoxContent is well-defined
and independent of time.
-/
lemma CoherentBundle.box_content_at_any_time (B : CoherentBundle D)
    (fam : IndexedMCSFamily D) (h_fam : fam ∈ B.families)
    (t s : D) : BoxContentAt fam t = BoxContentAt fam s := by
  rcases B.all_constant fam h_fam with ⟨M, hM⟩
  ext chi
  simp only [BoxContentAt, Set.mem_setOf_eq]
  rw [hM t, hM s]

/--
Box formulas propagate correctly: if Box chi is in any family at any time,
then Box chi is NOT necessarily in other families (that's forward direction).
However, chi IS in all families due to mutual coherence.
-/
lemma CoherentBundle.families_box_coherent (B : CoherentBundle D)
    (chi : Formula) (fam : IndexedMCSFamily D) (h_fam : fam ∈ B.families)
    (t : D) (h_box : Formula.box chi ∈ fam.mcs t) :
    ∀ fam' ∈ B.families, ∀ s : D, chi ∈ fam'.mcs s :=
  fun fam' h_fam' s => B.chi_in_all_families chi fam h_fam t h_box fam' h_fam' s

/--
Every family in a CoherentBundle contains the entire UnionBoxContent at all times.

This is an immediate consequence of MutuallyCoherent.
-/
lemma CoherentBundle.member_contains_union_boxcontent (B : CoherentBundle D)
    (fam : IndexedMCSFamily D) (h_fam : fam ∈ B.families) (t : D) :
    UnionBoxContent B.families ⊆ fam.mcs t := by
  intro chi h_chi
  exact B.mutually_coherent fam h_fam chi h_chi t

/-!
## Phase 7: CoherentBundle to BMCS Conversion
-/

/--
Convert a saturated CoherentBundle to a BMCS.

**Preconditions**:
- B is a CoherentBundle (mutually coherent constant families)
- B is saturated (every Diamond has a witness)

**Result**:
A BMCS where:
- modal_forward: Follows from mutual coherence + T-axiom
- modal_backward: Follows from saturation via contraposition
-/
noncomputable def CoherentBundle.toBMCS (B : CoherentBundle D)
    (h_sat : B.isSaturated) : BMCS D where
  families := B.families
  nonempty := B.nonempty
  modal_forward := by
    -- Box phi in fam.mcs t implies phi in all fam'.mcs t
    -- This follows from mutual coherence: chi_in_all_families
    intro fam h_fam phi t h_box fam' h_fam'
    exact B.chi_in_all_families phi fam h_fam t h_box fam' h_fam' t
  modal_backward := by
    -- If phi in all fam'.mcs t, then Box phi in fam.mcs t
    -- Prove by contraposition using the new saturation definition:
    -- saturation: neg(Box psi) in fam.mcs t => exists fam' with neg psi in fam'.mcs t
    -- If Box phi not in fam.mcs t, then neg(Box phi) in fam.mcs t (by MCS completeness)
    -- By saturation with psi = phi, exists fam' with neg phi in fam'.mcs t
    -- But h_all says phi in fam'.mcs t, contradiction
    intro fam h_fam phi t h_all
    -- Suppose Box phi not in fam.mcs t
    by_contra h_not_box
    -- By MCS negation completeness, neg (Box phi) in fam.mcs t
    have h_mcs := fam.is_mcs t
    have h_neg_box : Formula.neg (Formula.box phi) ∈ fam.mcs t := by
      rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h_box | h_neg
      · exact absurd h_box h_not_box
      · exact h_neg
    -- By saturation (with the new definition), there exists fam' with neg phi in fam'.mcs t
    rcases h_sat phi fam h_fam t h_neg_box with ⟨fam', h_fam', h_neg_phi⟩
    -- But h_all says phi in fam'.mcs t
    have h_phi := h_all fam' h_fam'
    -- Contradiction: fam'.mcs t contains both phi and neg phi
    exact set_consistent_not_both (fam'.is_mcs t).1 phi h_phi h_neg_phi
  eval_family := B.eval_family
  eval_family_mem := B.eval_family_mem

/--
The toBMCS conversion preserves the evaluation family.
-/
lemma CoherentBundle.toBMCS_eval_family (B : CoherentBundle D) (h_sat : B.isSaturated) :
    (B.toBMCS h_sat).eval_family = B.eval_family := rfl

/--
The toBMCS conversion preserves the family set.
-/
lemma CoherentBundle.toBMCS_families (B : CoherentBundle D) (h_sat : B.isSaturated) :
    (B.toBMCS h_sat).families = B.families := rfl

/-!
## Relationship to singleFamily_modal_backward_axiom

The axiom-based approach in Construction.lean remains valid for practical use.
The axiom captures the metatheoretic fact that a properly saturated canonical model exists.

This CoherentConstruction module provides:
1. The correct approach (building coherence into construction)
2. The key structures (BoxContent, WitnessSeed, CoherentWitness)
3. The core viability lemma (diamond_boxcontent_consistent_constant) - COMPLETE
4. CoherentBundle with mutual coherence - COMPLETE
5. Saturation predicate for full BMCS construction - COMPLETE
6. toBMCS conversion with saturation hypothesis - COMPLETE

The path to axiom elimination is clear; the remaining work is constructing
a saturated CoherentBundle via Zorn's lemma or iterative construction.
-/

/-!
## Summary of Sorry Status

### Sorries in This Module:
- **None** (as of 2026-02-03)

### Completed (Task 844: CoherentWitness):
- `diamond_boxcontent_consistent_constant` - K-distribution chain proof completed using
  `generalized_modal_k` from GeneralizedNecessitation.lean combined with
  `set_mcs_closed_under_derivation` from MCSProperties.lean.

### Completed (Task 851: CoherentBundle):
- `UnionBoxContent` - Multi-family BoxContent aggregation
- `MutuallyCoherent` - Inter-family coherence predicate
- `MutuallyCoherent_singleton` - Singleton coherence proof using T-axiom
- `CoherentBundle` structure with all required fields
- `CoherentBundle.isSaturated` - Saturation predicate
- `CoherentBundle.toBMCS` - **FULL PROOF** (no sorries!) converting saturated bundle to BMCS
- Basic properties: `chi_in_all_families`, `families_box_coherent`, `member_contains_union_boxcontent`

### Key Proof Strategies:

**CoherentWitness (Case 1: psi ∈ L)**:
1. From `L_filt ⊢ neg psi`, extract that for each `chi ∈ L_filt`, `Box chi ∈ M` (from WitnessSeed membership)
2. Apply `generalized_modal_k` to transform `L_filt ⊢ neg psi` into `Box(L_filt) ⊢ Box(neg psi)`
3. All formulas in Box(L_filt) are in M (via Context.mem_map_iff)
4. By `set_mcs_closed_under_derivation`, conclude `Box(neg psi) ∈ M`
5. Contradiction: Diamond psi = neg(Box(neg psi)) ∈ M and Box(neg psi) ∈ M

**CoherentBundle.toBMCS**:
- `modal_forward`: Follows from mutual coherence via `chi_in_all_families`
- `modal_backward`: Proof by contraposition using MCS completeness and saturation:
  1. Assume Box phi not in fam.mcs t
  2. By MCS completeness, neg(Box phi) in fam.mcs t
  3. By saturation, exists fam' with neg phi in fam'.mcs t
  4. But universal hypothesis says phi in fam'.mcs t
  5. Contradiction (MCS consistency)

### Related Sorries in SaturatedConstruction.lean:
- Lines 714, 733, 785: BoxContent preservation issues
- Different scope (requires recursive saturation with Zorn's lemma)
- These sorries are in a different code path (general approach, not constant-family approach)

### Remaining Axiom (in Construction.lean, not this module):
- `singleFamily_modal_backward_axiom` in Construction.lean
- Justified by canonical model metatheory
- Eliminable once a saturated CoherentBundle can be constructed

### Remaining Work for Full Axiom Elimination:
1. Implement iterative or Zorn-based saturation for CoherentBundle
2. Prove that saturation preserves mutual coherence
3. Use `CoherentBundle.toBMCS` to get axiom-free BMCS

### Net Effect:
This implementation provides the COMPLETE infrastructure for axiom-free BMCS construction.
The `toBMCS` conversion is fully proven. The only remaining step is constructing a
saturated CoherentBundle from an initial context, which is a Zorn's lemma application
building on the existing `diamond_boxcontent_consistent_constant` theorem.
-/

end Bimodal.Metalogic.Bundle
