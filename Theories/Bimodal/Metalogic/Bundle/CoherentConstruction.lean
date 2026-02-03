import Bimodal.Metalogic.Bundle.BMCS
import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.ModalSaturation
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

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

- `BoxContent`: Set of formulas whose boxes appear in a family
- `WitnessSeed`: The seed for constructing coherent witnesses
- `diamond_boxcontent_consistent_constant`: Core viability lemma for constant families
- `CoherentWitness`: A witness family with built-in coherence proof
- `constructCoherentWitness`: Construct a coherent witness for Diamond formulas
- `CoherentBundle`: A bundle of coherent witnesses satisfying BMCS requirements
- `CoherentBundle.toBMCS`: Conversion to BMCS for TruthLemma compatibility

## References

- Research report: specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-002.md
- Implementation plan: specs/844_redesign_metalogic_precoherent_bundle_construction/plans/implementation-002.md
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
    -- Box chi ∈ fam.mcs s = M
    -- fam.mcs t = M, so Box chi ∈ fam.mcs t
    rw [hM s] at h_box_s
    rw [← hM t] at h_box_s
    exact h_box_s
  · intro h_box_t
    exact ⟨t, h_box_t⟩

/--
The underlying MCS of a constant family is maximal consistent.
-/
lemma constant_family_underlying_mcs (fam : IndexedMCSFamily D)
    (h_const : IsConstantFamily fam) : ∃ M h_mcs, fam = constantIndexedMCSFamily M h_mcs := by
  rcases h_const with ⟨M, hM⟩
  have h_mcs : SetMaximalConsistent M := by
    have h := fam.is_mcs 0
    rw [hM 0] at h
    exact h
  -- The family structure matches constantIndexedMCSFamily
  -- but proving equality requires extensionality on the structure
  -- For now, we just use the existence of M and its MCS property
  sorry -- This is a structural lemma that we don't strictly need

/--
**Core Viability Lemma for Constant Families**:

If Diamond psi ∈ base.mcs t for a constant family base,
then {psi} ∪ BoxContent(base) is set-consistent.

**Proof Strategy**:
Since base is constant, BoxContent = BoxContentAt t.
We can then use the standard modal consistency argument at time t.

**Key Insight**: For constant families, all Box formulas appearing at any time
also appear at time t, so the K-distribution argument works at time t.
-/
theorem diamond_boxcontent_consistent_constant (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily fam) (psi : Formula) (t : D)
    (h_diamond : diamondFormula psi ∈ base.mcs t) :
    SetConsistent (WitnessSeed base psi) := by
  -- Use the existing diamond_implies_psi_consistent for the {psi} part
  -- and show BoxContent doesn't introduce inconsistency
  intro L hL_sub ⟨d⟩

  -- L ⊆ WitnessSeed = {psi} ∪ BoxContent
  -- L derives bot
  -- We need a contradiction

  -- For a constant family, all elements of BoxContent are in base.mcs t
  -- (via T-axiom applied to Box chi)

  rcases h_const with ⟨M, hM⟩

  -- base.mcs t = M, and diamondFormula psi ∈ M
  have h_diamond_M : diamondFormula psi ∈ M := by rwa [← hM t]

  -- All formulas in WitnessSeed are either psi or come from BoxContent
  -- For BoxContent elements, Box chi ∈ M (some time), so Box chi ∈ M (since M is same at all times)
  -- By T-axiom, chi ∈ M

  -- Partition L into psi-part and BoxContent-part
  by_cases h_psi_in : psi ∈ L
  · -- Case: psi ∈ L
    -- Reorder to put psi first
    let L_filt := L.filter (fun y => decide (y ≠ psi))
    have h_perm := cons_filter_neq_perm h_psi_in
    have d_reord : DerivationTree (psi :: L_filt) Formula.bot :=
      derivation_exchange d (fun x => (h_perm x).symm)

    -- Deduction theorem: L_filt ⊢ neg psi
    have d_neg : L_filt ⊢ Formula.neg psi :=
      deduction_theorem L_filt psi Formula.bot d_reord

    -- All elements of L_filt are in BoxContent (and hence in M via T-axiom)
    have h_filt_in_M : ∀ chi ∈ L_filt, chi ∈ M := by
      intro chi h_mem
      have h_and := List.mem_filter.mp h_mem
      have h_in_L := h_and.1
      have h_ne : chi ≠ psi := by simp only [decide_eq_true_eq] at h_and; exact h_and.2
      have h_in_seed := hL_sub chi h_in_L
      simp only [WitnessSeed, Set.mem_union, Set.mem_singleton_iff] at h_in_seed
      rcases h_in_seed with h_eq | h_box
      · exact absurd h_eq h_ne
      · -- chi ∈ BoxContent, so ∃ s, Box chi ∈ base.mcs s = M
        rcases h_box with ⟨s, h_box_s⟩
        rw [hM s] at h_box_s
        -- Box chi ∈ M, by T-axiom chi ∈ M
        have h_T := DerivationTree.axiom [] ((Formula.box chi).imp chi) (Axiom.modal_t chi)
        exact set_mcs_implication_property (by rw [← hM t]; exact base.is_mcs t)
          (theorem_in_mcs (by rw [← hM t]; exact base.is_mcs t) h_T) h_box_s

    -- L_filt ⊢ neg psi, and L_filt ⊆ M (consistent MCS)
    -- By closure: neg psi ∈ M
    have h_neg_psi_M : Formula.neg psi ∈ M :=
      set_mcs_closed_under_derivation (by rw [← hM t]; exact base.is_mcs t) L_filt h_filt_in_M d_neg

    -- We have neg psi ∈ M
    -- Need to derive Box(neg psi) ∈ M to contradict Diamond psi

    -- This is the tricky part. neg psi ∈ M doesn't directly give Box(neg psi) ∈ M.
    -- We need the K-distribution argument on the FULL derivation.

    -- Actually, let's use a different approach.
    -- We have L_filt ⊢ neg psi where L_filt ⊆ BoxContent.
    -- For each chi ∈ L_filt, Box chi ∈ M.
    -- The theorem: Box chi_1 -> ... -> Box chi_n -> Box(neg psi) follows from
    -- chi_1, ..., chi_n |- neg psi via K-distribution.

    -- This theorem is in M. And all Box chi_i are in M.
    -- So Box(neg psi) ∈ M by modus ponens.

    -- But Diamond psi = neg(Box(neg psi)) ∈ M too.
    -- Contradiction with M being consistent.

    -- The K-distribution argument requires building the theorem chain.
    -- Let me use the existing box_dne_theorem infrastructure.

    -- Alternative: use that if [chi_1, ..., chi_n] ⊢ neg psi, then we can derive
    -- a contradiction at M because all chi_i ∈ M and neg psi ∈ M would follow.
    -- But wait, that just gives neg psi ∈ M, not Box(neg psi) ∈ M.

    -- The issue is that even with the K-distribution theorem, we need to
    -- apply modus ponens with Box chi_i ∈ M, not chi_i ∈ M.

    -- For L_filt elements from BoxContent, we have Box chi ∈ M.
    -- So we CAN do the K-distribution argument!

    -- Build: [] ⊢ Box chi_1 -> ... -> Box chi_n -> Box(neg psi)
    -- from: [] ⊢ chi_1 -> ... -> chi_n -> neg psi (via deduction chain)

    -- Then all Box chi_i ∈ M, and the theorem is in M.
    -- By repeated modus ponens: Box(neg psi) ∈ M.

    -- This contradicts Diamond psi = neg(Box(neg psi)) ∈ M.

    -- The implementation is complex. For now, use sorry with clear documentation.
    -- The proof sketch is complete; full formalization requires the K-chain helper.

    sorry

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

    -- L ⊆ M and L ⊢ bot contradicts M being consistent
    exact (by rw [← hM t]; exact base.is_mcs t).1 L h_L_in_M ⟨d⟩

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
    (h_diamond : diamondFormula psi ∈ base.mcs t) : CoherentWitness base := by
  -- WitnessSeed is consistent
  have h_seed_cons := diamond_boxcontent_consistent_constant base h_const psi t h_diamond

  -- Extend to MCS
  have ⟨W, h_extends, h_W_mcs⟩ := set_lindenbaum (WitnessSeed base psi) h_seed_cons

  -- Build constant family
  let witness_fam := constantWitnessFamily W h_W_mcs (D := D)

  exact {
    family := witness_fam
    witnessed := psi
    contains_witnessed := fun s => by
      simp only [constantWitnessFamily_mcs_eq]
      exact h_extends (psi_mem_WitnessSeed base psi)
    contains_boxcontent := fun chi h_chi s => by
      simp only [constantWitnessFamily_mcs_eq]
      exact h_extends (BoxContent_subset_WitnessSeed base psi h_chi)
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
## Phase 4: CoherentBundle Structure

A CoherentBundle collects the base family and all its coherent witnesses.
-/

/--
A coherent bundle is a base family together with coherent witnesses for all
Diamond formulas in the base.

The key property is that all families in the bundle are mutually coherent
for Box formulas: if Box phi is in any family, then phi is in all families.
-/
structure CoherentBundle (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- The base family -/
  base : IndexedMCSFamily D
  /-- Proof that base is a constant family -/
  base_constant : IsConstantFamily base
  /-- The set of witness families -/
  witnesses : Set (CoherentWitness base)
  /-- Saturation: every Diamond in base has a witness -/
  saturated : ∀ psi t, diamondFormula psi ∈ base.mcs t →
    ∃ w ∈ witnesses, psi ∈ w.family.mcs t

/--
All families in a CoherentBundle (as a set of IndexedMCSFamily).
-/
def CoherentBundle.allFamilies (B : CoherentBundle D) : Set (IndexedMCSFamily D) :=
  {B.base} ∪ {w.family | w ∈ B.witnesses}

/--
The base family is in allFamilies.
-/
lemma CoherentBundle.base_in_allFamilies (B : CoherentBundle D) :
    B.base ∈ B.allFamilies :=
  Set.mem_union_left _ (Set.mem_singleton B.base)

/--
Witness families are in allFamilies.
-/
lemma CoherentBundle.witness_in_allFamilies (B : CoherentBundle D)
    (w : CoherentWitness B.base) (hw : w ∈ B.witnesses) :
    w.family ∈ B.allFamilies :=
  Set.mem_union_right _ ⟨w, hw, rfl⟩

/--
allFamilies is nonempty (contains at least the base).
-/
lemma CoherentBundle.allFamilies_nonempty (B : CoherentBundle D) :
    B.allFamilies.Nonempty :=
  ⟨B.base, B.base_in_allFamilies⟩

/-!
## Phase 5: Box Coherence and Modal Saturation

The key properties that make CoherentBundle satisfy the BMCS interface.
-/

/--
Box-forward coherence: if Box phi is in base.mcs t, then phi is in all families' MCS at t.

This follows from:
- phi ∈ base.mcs t (by T-axiom)
- phi ∈ witness.mcs t (by coherent witness construction)
-/
theorem CoherentBundle.box_forward (B : CoherentBundle D)
    (phi : Formula) (t : D) (h_box : Formula.box phi ∈ B.base.mcs t) :
    ∀ fam ∈ B.allFamilies, phi ∈ fam.mcs t := by
  intro fam h_fam
  rcases Set.mem_union.mp h_fam with h_base | h_witness
  · -- fam = B.base
    have h_eq := Set.mem_singleton_iff.mp h_base
    rw [h_eq]
    -- By T-axiom: Box phi -> phi
    have h_T := DerivationTree.axiom [] ((Formula.box phi).imp phi) (Axiom.modal_t phi)
    exact set_mcs_implication_property (B.base.is_mcs t) (theorem_in_mcs (B.base.is_mcs t) h_T) h_box
  · -- fam = w.family for some w ∈ witnesses
    rcases h_witness with ⟨w, hw, h_eq⟩
    rw [h_eq]
    -- By coherent witness: phi ∈ BoxContent base implies phi ∈ w.family.mcs t
    exact w.contains_boxcontent phi ⟨t, h_box⟩ t

/--
Modal saturation: every Diamond phi in base has a witness family where phi holds.
-/
theorem CoherentBundle.modal_saturated (B : CoherentBundle D)
    (phi : Formula) (t : D) (h_diamond : diamondFormula phi ∈ B.base.mcs t) :
    ∃ fam ∈ B.allFamilies, phi ∈ fam.mcs t := by
  rcases B.saturated phi t h_diamond with ⟨w, hw, h_phi⟩
  exact ⟨w.family, B.witness_in_allFamilies w hw, h_phi⟩

/-!
## Phase 5: Convert CoherentBundle to BMCS

The BMCS interface requires:
- modal_forward: Box phi in any family implies phi in all families
- modal_backward: phi in all families implies Box phi in each family

For CoherentBundle:
- modal_forward follows from box_forward (T-axiom + witness coherence)
- modal_backward follows from saturation via contraposition
-/

/--
Convert a CoherentBundle to a BMCS.

The modal_backward proof uses the contrapositive argument from saturation:
if phi is in all families but Box phi is not in base.mcs t, then
Diamond(neg phi) is in base.mcs t, so there's a witness with neg phi,
contradicting phi being in all families.
-/
noncomputable def CoherentBundle.toBMCS (B : CoherentBundle D) : BMCS D where
  families := B.allFamilies
  nonempty := B.allFamilies_nonempty
  modal_forward := fun fam hfam phi t h_box fam' hfam' => by
    -- Box phi in fam.mcs t, need phi in fam'.mcs t
    -- First, show Box phi in base.mcs t (if fam ≠ base, use witness coherence backward)
    rcases Set.mem_union.mp hfam with h_base | h_witness
    · -- fam = base
      have h_eq := Set.mem_singleton_iff.mp h_base
      rw [h_eq] at h_box
      exact B.box_forward phi t h_box fam' hfam'
    · -- fam = w.family for some witness w
      -- This case is subtle: Box phi in witness doesn't directly give Box phi in base
      -- But phi ∈ all families by T-axiom from Box phi in witness
      rcases h_witness with ⟨w, hw, h_eq⟩
      rw [h_eq] at h_box
      -- T-axiom: phi ∈ w.family.mcs t
      have h_T := DerivationTree.axiom [] ((Formula.box phi).imp phi) (Axiom.modal_t phi)
      have h_phi_w : phi ∈ w.family.mcs t :=
        set_mcs_implication_property (w.family.is_mcs t) (theorem_in_mcs (w.family.is_mcs t) h_T) h_box

      -- For fam' ∈ allFamilies:
      rcases Set.mem_union.mp hfam' with h_base' | h_witness'
      · -- fam' = base: need phi ∈ base.mcs t
        -- This is the hard case. We have phi ∈ w.family.mcs t but need phi ∈ base.mcs t.
        -- The witness construction ensures w contains BoxContent(base),
        -- but not that base contains everything in w.

        -- Actually, for modal_forward, we only need one direction.
        -- The issue is: Box phi in WITNESS doesn't imply Box phi in BASE.

        -- The BMCS modal_forward says: Box phi in SOME family implies phi in ALL families.
        -- But this requires Box phi to propagate from witness to base... which it doesn't!

        -- This is a design issue. In the standard construction, all families are symmetric.
        -- In CoherentBundle, base is special: witnesses are coherent WITH base,
        -- but not the other way around.

        -- SOLUTION: Strengthen allFamilies to only use families that are mutually coherent.
        -- OR: Add Box formulas from witnesses back to base (but base is fixed).
        -- OR: Accept that modal_forward only holds from base, not from witnesses.

        -- Actually, looking at the BMCS usage in TruthLemma:
        -- modal_forward is used when Box phi ∈ fam.mcs t (the eval_family).
        -- eval_family is base. So we only need modal_forward FROM base.

        -- For now, use sorry and document the limitation.
        -- The construction works if we never have Box formulas in witnesses
        -- that aren't also in base (which is the case since witnesses are built
        -- from base's WitnessSeed).

        -- Actually, wait. Witnesses are built from WitnessSeed = {psi} ∪ BoxContent(base).
        -- The Lindenbaum extension might add Box formulas not in base.
        -- Those Box formulas' contents might not be in base.

        -- This is a genuine gap in the CoherentBundle design.
        -- The fix: use mutual coherence between all families.
        -- For now, sorry this case.

        sorry

      · -- fam' = w'.family for some witness w'
        -- Need phi ∈ w'.family.mcs t
        -- We have Box phi ∈ w.family.mcs t (from fam = w.family)

        -- Same issue: Box phi in one witness doesn't propagate to other witnesses.
        -- Witnesses are coherent with base, not with each other directly.

        sorry

  modal_backward := fun fam hfam phi t h_all => by
    -- phi is in ALL families at t, need Box phi in fam.mcs t
    -- By contradiction: if Box phi ∉ fam.mcs t, then neg(Box phi) = Diamond(neg phi) ∈ fam.mcs t

    rcases Set.mem_union.mp hfam with h_base | h_witness
    · -- fam = base: use saturation contrapositive
      have h_eq := Set.mem_singleton_iff.mp h_base
      rw [h_eq]

      by_contra h_not_box
      -- neg(Box phi) ∈ base.mcs t by MCS negation completeness
      have h_mcs := B.base.is_mcs t
      have h_neg_box : Formula.neg (Formula.box phi) ∈ B.base.mcs t := by
        rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h_yes | h_no
        · exact absurd h_yes h_not_box
        · exact h_no

      -- From box_dne_theorem: neg(Box phi) implies Diamond(neg phi)
      have h_box_dne := box_dne_theorem phi
      have h_diamond_neg : diamondFormula (Formula.neg phi) ∈ B.base.mcs t :=
        mcs_contrapositive h_mcs h_box_dne h_neg_box

      -- By saturation: exists witness with neg phi
      rcases B.modal_saturated (Formula.neg phi) t h_diamond_neg with ⟨fam', hfam', h_neg_phi⟩

      -- But phi is in ALL families including fam'
      have h_phi := h_all fam' hfam'

      -- neg phi and phi both in fam'.mcs t contradicts consistency
      rcases Set.mem_union.mp hfam' with h_base' | h_witness'
      · have h_eq' := Set.mem_singleton_iff.mp h_base'
        rw [h_eq'] at h_neg_phi h_phi
        exact set_consistent_not_both (B.base.is_mcs t).1 phi h_phi h_neg_phi
      · rcases h_witness' with ⟨w', hw', h_eq'⟩
        rw [h_eq'] at h_neg_phi h_phi
        exact set_consistent_not_both (w'.family.is_mcs t).1 phi h_phi h_neg_phi

    · -- fam = w.family for some witness
      -- Same argument but need to track through witness families
      rcases h_witness with ⟨w, hw, h_eq⟩
      rw [h_eq]

      by_contra h_not_box
      have h_mcs := w.family.is_mcs t
      have h_neg_box : Formula.neg (Formula.box phi) ∈ w.family.mcs t := by
        rcases set_mcs_negation_complete h_mcs (Formula.box phi) with h_yes | h_no
        · exact absurd h_yes h_not_box
        · exact h_no

      have h_box_dne := box_dne_theorem phi
      have h_diamond_neg : diamondFormula (Formula.neg phi) ∈ w.family.mcs t :=
        mcs_contrapositive h_mcs h_box_dne h_neg_box

      -- Now we need a witness for Diamond(neg phi) in w.family.
      -- But saturation is defined on BASE, not on witnesses!

      -- This is another gap: witnesses might have Diamonds not satisfied in the bundle.

      -- For a full construction, witnesses would need to be recursively saturated.
      -- This requires a Zorn's lemma argument (like SaturatedConstruction).

      sorry

  eval_family := B.base
  eval_family_mem := B.base_in_allFamilies

/-!
## Phase 6: Construct CoherentBundle from Consistent Context

The main entry point for completeness: given a consistent context Gamma,
construct a CoherentBundle where Gamma is in the base family.
-/

/--
Construct a CoherentBundle from a consistent context.

This builds:
1. Base family via Lindenbaum + constantIndexedMCSFamily
2. Witnesses for all Diamond formulas in base (may be done lazily/non-constructively)
-/
noncomputable def constructCoherentBundle (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    CoherentBundle D := by
  -- Build base family
  let M := lindenbaumMCS Gamma h_cons
  let h_mcs := lindenbaumMCS_is_mcs Gamma h_cons
  let base := constantIndexedMCSFamily M h_mcs (D := D)

  -- base is constant
  have h_const : IsConstantFamily base := ⟨M, fun _ => rfl⟩

  -- For witnesses, we need to non-constructively provide witnesses for all Diamonds
  -- This uses choice/classical logic similar to SaturatedConstruction

  -- The witness set: for each Diamond psi in base.mcs t (some t), include a witness
  -- This is potentially infinite, so we use a non-constructive definition

  let witness_set : Set (CoherentWitness base) :=
    {w | ∃ psi t, diamondFormula psi ∈ base.mcs t ∧
         w = constructCoherentWitness base h_const psi t ‹diamondFormula psi ∈ base.mcs t›}

  exact {
    base := base
    base_constant := h_const
    witnesses := witness_set
    saturated := fun psi t h_diamond => by
      -- Witness exists in witness_set by construction
      have h_w := constructCoherentWitness base h_const psi t h_diamond
      use h_w
      constructor
      · -- h_w ∈ witness_set
        exact ⟨psi, t, h_diamond, rfl⟩
      · -- psi ∈ h_w.family.mcs t
        exact h_w.contains_witnessed t
  }

/--
The constructed CoherentBundle contains the original context at time 0.
-/
theorem constructCoherentBundle_contains_context (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∀ g ∈ Gamma, g ∈ (constructCoherentBundle Gamma h_cons (D := D)).base.mcs 0 := by
  intro g hg
  -- base.mcs 0 = M = lindenbaumMCS Gamma h_cons
  -- lindenbaumMCS extends Gamma
  show g ∈ lindenbaumMCS Gamma h_cons
  exact lindenbaumMCS_extends Gamma h_cons (by simp [contextAsSet]; exact hg)

/-!
## Summary

This module implements the Coherent Witness Chain construction with the following status:

### Completed (No Sorry):
- Phase 1: BoxContent, WitnessSeed, CoherentWitness definitions
- Phase 4: CoherentBundle structure
- Phase 5: box_forward (partial - from base only)
- Phase 5: modal_saturated
- Phase 6: constructCoherentBundle, context preservation

### With Sorry (Documented Gaps):
1. `diamond_boxcontent_consistent_constant` - Case 1 (psi ∈ L)
   - Requires K-distribution chain formalization
   - Proof sketch is complete; implementation is complex

2. `CoherentBundle.toBMCS.modal_forward` - Cases from witnesses
   - Witnesses may have Box formulas not in base
   - Requires mutual coherence (not just one-directional)

3. `CoherentBundle.toBMCS.modal_backward` - Case for witnesses
   - Witnesses may have Diamonds not satisfied
   - Requires recursive saturation (Zorn's lemma)

4. `constant_family_underlying_mcs` - Structural equality
   - Not strictly needed; can be worked around

### Relationship to singleFamily_modal_backward_axiom:

The CoherentBundle construction provides an alternative to the axiom-based approach
in Construction.lean. The axiom captures the metatheoretic fact that a properly
saturated canonical model exists. This construction makes that explicit.

However, the full formalization requires additional infrastructure:
- K-distribution chain theorem
- Mutual coherence between families
- Recursive saturation via Zorn's lemma

These are implemented in SaturatedConstruction.lean but have their own sorries.
A complete axiom-free construction would need all these pieces to be sorry-free.

### Recommended Approach:

For practical completeness proofs, the axiom-based `construct_bmcs` remains valid.
The `singleFamily_modal_backward_axiom` is mathematically justified by the
existence of the saturated canonical model in modal logic metatheory.

This CoherentConstruction module documents the path to eliminating that axiom
and identifies the remaining technical gaps.
-/

end Bimodal.Metalogic.Bundle
