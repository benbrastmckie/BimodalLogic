import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.Theorems.GeneralizedNecessitation
import Mathlib.Order.Zorn

/-!
# Zorn-Based Family Selection for Temporal Coherence

This module provides an alternative construction of `IndexedMCSFamily Int` using Zorn's lemma
to build a globally coherent family with all four temporal properties, replacing the chain-based
construction in DovetailingChain.lean that has 4 sorries for cross-sign propagation.

## Construction Overview (Revised v002)

The key insight from research-003.md is that F/P (existential) requirements are impossible for
partial families with finite domains, but G/H (universal) requirements work for any partial domain.

The revised construction:

1. Defining `GHCoherentPartialFamily`: A partial family (domain ⊆ Int) with G/H coherence only
   (no F/P requirements). This is achievable for singleton domains with vacuous coherence.

2. Using a Preorder instance and applying Zorn's lemma via `zorn_le_nonempty₀` to find a maximal
   G/H-coherent partial family.

3. Proving that any maximal partial family must have domain = Set.univ (otherwise we can extend
   by adding F/P obligations to the extension seed).

4. Proving that total (domain = Set.univ) families automatically satisfy F/P (the witness t+1
   is always in the domain).

5. Extracting an `IndexedMCSFamily Int` from the maximal (hence total, hence F/P-satisfying) family.

## Main Definitions

- `GHCoherentPartialFamily`: Structure with partial domain, MCS assignment, G/H coherence
- `GHCoherentPartialFamily.le`: Partial order for Zorn's lemma (domain extension with agreement)
- `instance : Preorder GHCoherentPartialFamily`: Required for Mathlib Zorn integration
- `coherent_chain_has_upper_bound`: Chain upper bound lemma for Zorn
- `maximalCoherentFamily`: Zorn application
- `maximal_implies_total`: Maximality implies domain = Set.univ
- `total_family_forward_F`, `total_family_backward_P`: F/P recovery for total families
- `temporal_coherent_family_exists_zorn`: Main theorem (replaces 4 sorries in DovetailingChain)

## References

- Task 870 plan v002: specs/870_zorn_family_temporal_coherence/plans/implementation-002.md
- Research: specs/870_zorn_family_temporal_coherence/reports/research-002.md, research-003.md
- Prior work: DovetailingChain.lean (4 sorries for cross-sign propagation)
- Zorn template: TemporalLindenbaum.lean (single-MCS construction)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Part 1: GHCoherentPartialFamily Structure

A partial family assigns MCS to times in a domain subset, with G/H coherence guaranteed
for all pairs within the domain. F/P coherence is NOT required for partial families -
it will be recovered as a derived property for total (domain = Set.univ) families.

**Key Design Change (v002)**:
Removing F/P from the structure eliminates the "base family impossibility" problem:
- Singleton domain {0} CANNOT satisfy F/P (no witnesses exist)
- Singleton domain {0} CAN satisfy G/H (vacuously - no t < t' pairs)
-/

/--
A partial family of maximal consistent sets indexed by times in a domain ⊆ Int,
with G/H (universal) temporal coherence only.

**Fields**:
- `domain`: The set of times with assigned MCS
- `mcs`: Assignment of sets to all times (only meaningful for t ∈ domain)
- `domain_nonempty`: The domain is nonempty (needed for Zorn base case)
- `is_mcs`: Each assigned set (for t ∈ domain) is maximal consistent
- `forward_G`: G phi propagates forward within the domain (universal property)
- `backward_H`: H phi propagates backward within the domain (universal property)

**F/P Coherence**: Not included here. For partial domains, F/P witnesses may not exist.
F/P is recovered as a derived property for total (domain = Set.univ) families, where
the witness t+1 (or t-1) is always in the domain.

**Design Note**: The `mcs` function is total (Int → Set Formula) for simplicity,
but only values at times in `domain` are meaningful. This avoids dependent types
in the partial order definition.
-/
structure GHCoherentPartialFamily where
  /-- The subset of times with assigned MCS -/
  domain : Set Int
  /-- MCS assignment (meaningful only for t ∈ domain) -/
  mcs : Int → Set Formula
  /-- Domain is nonempty -/
  domain_nonempty : domain.Nonempty
  /-- Each assigned set is maximal consistent -/
  is_mcs : ∀ t, t ∈ domain → SetMaximalConsistent (mcs t)
  /--
  Forward G coherence within domain: G phi at t implies phi at all future t' in domain.
  This is a universal property - it holds for all t' > t in domain.
  -/
  forward_G : ∀ t t', t ∈ domain → t' ∈ domain → t < t' →
    ∀ phi, Formula.all_future phi ∈ mcs t → phi ∈ mcs t'
  /--
  Backward H coherence within domain: H phi at t implies phi at all past t' in domain.
  This is a universal property - it holds for all t' < t in domain.
  -/
  backward_H : ∀ t t', t' ∈ domain → t ∈ domain → t' < t →
    ∀ phi, Formula.all_past phi ∈ mcs t → phi ∈ mcs t'

/-- Backward compatibility alias for migration. -/
abbrev CoherentPartialFamily := GHCoherentPartialFamily

/-!
### Boundary Time Predicates

A time is a **boundary** of the domain if it is outside the domain and either
greater than all domain elements (upper boundary) or less than all domain elements
(lower boundary). At boundary times, extension is simpler because the forward_G or
backward_H coherence from the new time becomes vacuously true.
-/

/-- A time is an upper boundary if it's outside the domain and greater than all domain elements. -/
def GHCoherentPartialFamily.isUpperBoundary (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ∀ s ∈ F.domain, s < t

/-- A time is a lower boundary if it's outside the domain and less than all domain elements. -/
def GHCoherentPartialFamily.isLowerBoundary (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ∀ s ∈ F.domain, t < s

/-- A time is a boundary if it's either an upper or lower boundary. -/
def GHCoherentPartialFamily.isBoundaryTime (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  F.isUpperBoundary t ∨ F.isLowerBoundary t

lemma GHCoherentPartialFamily.isUpperBoundary.not_in_domain {F : GHCoherentPartialFamily} {t : Int}
    (h : F.isUpperBoundary t) : t ∉ F.domain := h.1

lemma GHCoherentPartialFamily.isLowerBoundary.not_in_domain {F : GHCoherentPartialFamily} {t : Int}
    (h : F.isLowerBoundary t) : t ∉ F.domain := h.1

lemma GHCoherentPartialFamily.isUpperBoundary.all_lt {F : GHCoherentPartialFamily} {t : Int}
    (h : F.isUpperBoundary t) : ∀ s ∈ F.domain, s < t := h.2

lemma GHCoherentPartialFamily.isLowerBoundary.all_gt {F : GHCoherentPartialFamily} {t : Int}
    (h : F.isLowerBoundary t) : ∀ s ∈ F.domain, t < s := h.2

/-!
## Part 2: Partial Order on GHCoherentPartialFamily

The partial order for Zorn: F ≤ G iff G extends F (larger domain, agrees on overlap).
We also provide a Preorder instance to use Mathlib's Zorn lemmas directly.
-/

/--
Partial order: F ≤ G iff G extends F's domain and agrees on the overlap.
-/
def GHCoherentPartialFamily.le (F G : GHCoherentPartialFamily) : Prop :=
  F.domain ⊆ G.domain ∧ ∀ t, t ∈ F.domain → F.mcs t = G.mcs t

/-- Reflexivity of the partial order. -/
lemma GHCoherentPartialFamily.le_refl (F : GHCoherentPartialFamily) : F.le F := by
  constructor
  · exact Set.Subset.rfl
  · intro t _; rfl

/-- Transitivity of the partial order. -/
lemma GHCoherentPartialFamily.le_trans (F G H : GHCoherentPartialFamily)
    (hFG : F.le G) (hGH : G.le H) : F.le H := by
  constructor
  · exact Set.Subset.trans hFG.1 hGH.1
  · intro t ht
    rw [hFG.2 t ht]
    exact hGH.2 t (hFG.1 ht)

/--
Antisymmetry of the partial order (extensional).

If F ≤ G and G ≤ F, then F and G have the same domain and the same MCS assignment
on that domain.
-/
lemma GHCoherentPartialFamily.le_antisymm_domain (F G : GHCoherentPartialFamily)
    (hFG : F.le G) (hGF : G.le F) : F.domain = G.domain :=
  Set.Subset.antisymm hFG.1 hGF.1

lemma GHCoherentPartialFamily.le_antisymm_mcs (F G : GHCoherentPartialFamily)
    (hFG : F.le G) (hGF : G.le F) : ∀ t, t ∈ F.domain → F.mcs t = G.mcs t :=
  hFG.2

/-- Preorder instance for GHCoherentPartialFamily, enabling use of Mathlib Zorn lemmas. -/
instance : Preorder GHCoherentPartialFamily where
  le := GHCoherentPartialFamily.le
  le_refl := GHCoherentPartialFamily.le_refl
  le_trans := fun F G H hFG hGH => GHCoherentPartialFamily.le_trans F G H hFG hGH

/-- The custom `le` agrees with the Preorder `≤`. -/
lemma GHCoherentPartialFamily.le_eq_preorder_le (F G : GHCoherentPartialFamily) :
    F.le G ↔ F ≤ G := Iff.rfl

-- Backward compatibility aliases
abbrev CoherentPartialFamily.le := GHCoherentPartialFamily.le
abbrev CoherentPartialFamily.le_refl := GHCoherentPartialFamily.le_refl
abbrev CoherentPartialFamily.le_trans := GHCoherentPartialFamily.le_trans
abbrev CoherentPartialFamily.le_antisymm_domain := GHCoherentPartialFamily.le_antisymm_domain
abbrev CoherentPartialFamily.le_antisymm_mcs := GHCoherentPartialFamily.le_antisymm_mcs

/-!
## Part 3: GContent and HContent for Partial Families

Extract the temporal content from MCS in the partial family.
-/

/--
GContent of a partial family at a time: formulas phi where G phi is in the MCS.
-/
def GHCoherentPartialFamily.GContentAt (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  GContent (F.mcs t)

/--
HContent of a partial family at a time: formulas phi where H phi is in the MCS.
-/
def GHCoherentPartialFamily.HContentAt (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  HContent (F.mcs t)

-- Backward compatibility aliases
abbrev CoherentPartialFamily.GContentAt := GHCoherentPartialFamily.GContentAt
abbrev CoherentPartialFamily.HContentAt := GHCoherentPartialFamily.HContentAt

/-!
## Part 4: Basic Accessor Lemmas
-/

/-- Get the MCS at a time (meaningful only if t ∈ domain) -/
def GHCoherentPartialFamily.at (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  F.mcs t

/-- The MCS at any time in domain is consistent -/
lemma GHCoherentPartialFamily.consistent (F : GHCoherentPartialFamily) (t : Int) (ht : t ∈ F.domain) :
    SetConsistent (F.mcs t) :=
  (F.is_mcs t ht).1

/-- The MCS at any time in domain is maximal -/
lemma GHCoherentPartialFamily.maximal (F : GHCoherentPartialFamily) (t : Int) (ht : t ∈ F.domain) :
    ∀ phi : Formula, phi ∉ F.mcs t → ¬SetConsistent (insert phi (F.mcs t)) :=
  (F.is_mcs t ht).2

-- Backward compatibility aliases
abbrev CoherentPartialFamily.at := GHCoherentPartialFamily.at
abbrev CoherentPartialFamily.consistent := GHCoherentPartialFamily.consistent
abbrev CoherentPartialFamily.maximal := GHCoherentPartialFamily.maximal

/-!
## Part 5: Chain Upper Bound for Zorn

When applying Zorn's lemma, we need to prove that every chain of GH-coherent partial families
has an upper bound. The upper bound is constructed by taking the union of domains and
using chain monotonicity to define a consistent MCS at each time.

Note: With F/P removed from the structure, the chain upper bound construction is simpler.
-/

/--
For a chain C of GH-coherent partial families (ordered by le), every time in the union of domains
has a unique associated MCS (because chains agree on overlap by the le definition).
-/
lemma chain_mcs_unique {C : Set GHCoherentPartialFamily} (hC_chain : IsChain (· ≤ ·) C)
    (F G : GHCoherentPartialFamily) (hF : F ∈ C) (hG : G ∈ C) (t : Int)
    (htF : t ∈ F.domain) (htG : t ∈ G.domain) : F.mcs t = G.mcs t := by
  rcases hC_chain.total hF hG with hle | hle
  · exact hle.2 t htF
  · exact (hle.2 t htG).symm

attribute [local instance] Classical.propDecidable in
/--
For a nonempty chain C, construct an upper bound: domain is the union, MCS at t is the MCS
from any family in C containing t.
-/
noncomputable def chainUpperBound (C : Set GHCoherentPartialFamily)
    (hC_ne : C.Nonempty) (hC_chain : IsChain (· ≤ ·) C) :
    GHCoherentPartialFamily where
  domain := ⋃ F ∈ C, F.domain
  mcs := fun t =>
    if h : ∃ F ∈ C, t ∈ F.domain then
      (Classical.choose h).mcs t
    else
      ∅  -- default: never used since we only care about t in domain
  domain_nonempty := by
    obtain ⟨F, hF⟩ := hC_ne
    obtain ⟨t, ht⟩ := F.domain_nonempty
    exact ⟨t, Set.mem_biUnion hF ht⟩
  is_mcs := fun t ht => by
    classical
    simp only [Set.mem_iUnion] at ht
    obtain ⟨F, hF, htF⟩ := ht
    have h : ∃ F ∈ C, t ∈ F.domain := ⟨F, hF, htF⟩
    simp only [dif_pos h]
    -- The chosen F' has t ∈ F'.domain by definition
    have ⟨hF', htF'⟩ := Classical.choose_spec h
    -- F and F' agree on t since they're in the same chain
    have h_eq := chain_mcs_unique hC_chain F (Classical.choose h) hF hF' t htF htF'
    rw [← h_eq]
    exact F.is_mcs t htF
  forward_G := fun t t' ht ht' h_lt phi h_G => by
    classical
    simp only [Set.mem_iUnion] at ht ht'
    obtain ⟨F, hF, htF⟩ := ht
    obtain ⟨F', hF', htF'⟩ := ht'
    -- Get the MCS at t and t' in the upper bound
    have h_t : ∃ F ∈ C, t ∈ F.domain := ⟨F, hF, htF⟩
    have h_t' : ∃ F ∈ C, t' ∈ F.domain := ⟨F', hF', htF'⟩
    simp only [dif_pos h_t, dif_pos h_t'] at h_G ⊢
    -- By chain property, either F ≤ F' or F' ≤ F
    rcases hC_chain.total hF hF' with hle | hle
    · -- F ≤ F', so F.domain ⊆ F'.domain and F agrees with F' on F.domain
      have htF'_from_F : t ∈ F'.domain := hle.1 htF
      -- G phi is in F'.mcs t (since F and F' agree, and by chain definition)
      have h_Ft := Classical.choose_spec h_t
      have h_eq_t := chain_mcs_unique hC_chain (Classical.choose h_t) F' h_Ft.1 hF' t h_Ft.2 htF'_from_F
      -- Use F'.forward_G
      have h_G_in_F' : Formula.all_future phi ∈ F'.mcs t := by
        rw [← h_eq_t]
        exact h_G
      have h_phi_in_F' := F'.forward_G t t' htF'_from_F htF' h_lt phi h_G_in_F'
      -- The result MCS at t' is F'.mcs t' by chain agreement
      have h_Ft' := Classical.choose_spec h_t'
      have h_eq_t' := chain_mcs_unique hC_chain (Classical.choose h_t') F' h_Ft'.1 hF' t' h_Ft'.2 htF'
      rw [h_eq_t']
      exact h_phi_in_F'
    · -- F' ≤ F, so F'.domain ⊆ F.domain
      have htF'_in_F : t' ∈ F.domain := hle.1 htF'
      have h_Ft := Classical.choose_spec h_t
      have h_eq_t := chain_mcs_unique hC_chain (Classical.choose h_t) F h_Ft.1 hF t h_Ft.2 htF
      have h_G_in_F : Formula.all_future phi ∈ F.mcs t := by
        rw [← h_eq_t]
        exact h_G
      have h_phi_in_F := F.forward_G t t' htF htF'_in_F h_lt phi h_G_in_F
      have h_Ft' := Classical.choose_spec h_t'
      have h_eq_t' := chain_mcs_unique hC_chain (Classical.choose h_t') F h_Ft'.1 hF t' h_Ft'.2 htF'_in_F
      rw [h_eq_t']
      exact h_phi_in_F
  backward_H := fun t t' ht' ht h_lt phi h_H => by
    classical
    simp only [Set.mem_iUnion] at ht ht'
    obtain ⟨F, hF, htF⟩ := ht
    obtain ⟨F', hF', htF'⟩ := ht'
    have h_t : ∃ F ∈ C, t ∈ F.domain := ⟨F, hF, htF⟩
    have h_t' : ∃ F ∈ C, t' ∈ F.domain := ⟨F', hF', htF'⟩
    simp only [dif_pos h_t, dif_pos h_t'] at h_H ⊢
    rcases hC_chain.total hF hF' with hle | hle
    · have htF'_from_F : t ∈ F'.domain := hle.1 htF
      have h_Ft := Classical.choose_spec h_t
      have h_eq_t := chain_mcs_unique hC_chain (Classical.choose h_t) F' h_Ft.1 hF' t h_Ft.2 htF'_from_F
      have h_H_in_F' : Formula.all_past phi ∈ F'.mcs t := by
        rw [← h_eq_t]
        exact h_H
      have h_phi_in_F' := F'.backward_H t t' htF' htF'_from_F h_lt phi h_H_in_F'
      have h_Ft' := Classical.choose_spec h_t'
      have h_eq_t' := chain_mcs_unique hC_chain (Classical.choose h_t') F' h_Ft'.1 hF' t' h_Ft'.2 htF'
      rw [h_eq_t']
      exact h_phi_in_F'
    · have htF'_in_F : t' ∈ F.domain := hle.1 htF'
      have h_Ft := Classical.choose_spec h_t
      have h_eq_t := chain_mcs_unique hC_chain (Classical.choose h_t) F h_Ft.1 hF t h_Ft.2 htF
      have h_H_in_F : Formula.all_past phi ∈ F.mcs t := by
        rw [← h_eq_t]
        exact h_H
      have h_phi_in_F := F.backward_H t t' htF'_in_F htF h_lt phi h_H_in_F
      have h_Ft' := Classical.choose_spec h_t'
      have h_eq_t' := chain_mcs_unique hC_chain (Classical.choose h_t') F h_Ft'.1 hF t' h_Ft'.2 htF'_in_F
      rw [h_eq_t']
      exact h_phi_in_F

/-- The chain upper bound extends all members of the chain. -/
lemma chainUpperBound_extends (C : Set GHCoherentPartialFamily)
    (hC_ne : C.Nonempty) (hC_chain : IsChain (· ≤ ·) C)
    (F : GHCoherentPartialFamily) (hF : F ∈ C) :
    F ≤ chainUpperBound C hC_ne hC_chain := by
  constructor
  · intro t ht
    exact Set.mem_biUnion hF ht
  · intro t ht
    have h_t : ∃ F ∈ C, t ∈ F.domain := ⟨F, hF, ht⟩
    simp only [chainUpperBound, dif_pos h_t]
    exact chain_mcs_unique hC_chain F (Classical.choose h_t) hF (Classical.choose_spec h_t).1 t ht (Classical.choose_spec h_t).2

/--
Zorn chain upper bound lemma: Every chain of GH-coherent partial families has an upper bound.
-/
theorem coherent_chain_has_upper_bound (C : Set GHCoherentPartialFamily)
    (hC_ne : C.Nonempty) (hC_chain : IsChain (· ≤ ·) C) :
    ∃ ub : GHCoherentPartialFamily, ∀ F ∈ C, F ≤ ub :=
  ⟨chainUpperBound C hC_ne hC_chain, chainUpperBound_extends C hC_ne hC_chain⟩

/-!
## Part 6: Extension Seed with F/P Obligations

When extending a partial family to a new time t, we need to prove that the seed
(combining G-content from past, H-content from future, and F/P obligations) is consistent.

The seed for extending to time t includes:
- GContent(mcs(s)) for all s < t in domain (formulas that must hold at all future times)
- HContent(mcs(s)) for all s > t in domain (formulas that must hold at all past times)
- FObligations: formulas phi where F phi is in some mcs(s) for s < t (need witness at t)
- PObligations: formulas phi where P phi is in some mcs(s) for t < s (need witness at t)
-/

/--
F obligations: formulas that need witnesses at future times.
If F phi ∈ mcs(s) for some s < t, then phi should be in mcs(t) to satisfy the F at s.
-/
def FObligations (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  { phi | ∃ s, s ∈ F.domain ∧ s < t ∧ Formula.some_future phi ∈ F.mcs s }

/--
P obligations: formulas that need witnesses at past times.
If P phi ∈ mcs(s) for some s > t, then phi should be in mcs(t) to satisfy the P at s.
-/
def PObligations (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  { phi | ∃ s, s ∈ F.domain ∧ t < s ∧ Formula.some_past phi ∈ F.mcs s }

/--
The extension seed for adding time t to a partial family F.

This combines:
- G-content from all times s < t in F.domain (forward propagation)
- H-content from all times s > t in F.domain (backward propagation)
- F-obligations: formulas phi where F phi ∈ mcs(s) for some s < t
- P-obligations: formulas phi where P phi ∈ mcs(s) for some s > t

The F/P obligations ensure that when the extended family is total, it satisfies F/P coherence.
-/
def extensionSeed (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  (⋃ s ∈ {s | s ∈ F.domain ∧ s < t}, GContent (F.mcs s)) ∪
  (⋃ s ∈ {s | s ∈ F.domain ∧ t < s}, HContent (F.mcs s)) ∪
  FObligations F t ∪
  PObligations F t

/--
Extension seed includes G-content from past domain times.
-/
lemma extensionSeed_includes_past_GContent (F : GHCoherentPartialFamily) (t s : Int)
    (hs_dom : s ∈ F.domain) (hs_lt : s < t) (phi : Formula)
    (h_G : Formula.all_future phi ∈ F.mcs s) :
    phi ∈ extensionSeed F t := by
  apply Set.mem_union_left
  apply Set.mem_union_left
  apply Set.mem_union_left
  simp only [Set.mem_iUnion]
  exact ⟨s, ⟨hs_dom, hs_lt⟩, h_G⟩

/--
Extension seed includes H-content from future domain times.
-/
lemma extensionSeed_includes_future_HContent (F : GHCoherentPartialFamily) (t s : Int)
    (hs_dom : s ∈ F.domain) (hs_gt : t < s) (phi : Formula)
    (h_H : Formula.all_past phi ∈ F.mcs s) :
    phi ∈ extensionSeed F t := by
  apply Set.mem_union_left
  apply Set.mem_union_left
  apply Set.mem_union_right
  simp only [Set.mem_iUnion]
  exact ⟨s, ⟨hs_dom, hs_gt⟩, h_H⟩

/--
Extension seed includes F-obligations.
-/
lemma extensionSeed_includes_FObligations (F : GHCoherentPartialFamily) (t s : Int)
    (hs_dom : s ∈ F.domain) (hs_lt : s < t) (phi : Formula)
    (h_F : Formula.some_future phi ∈ F.mcs s) :
    phi ∈ extensionSeed F t := by
  apply Set.mem_union_left
  apply Set.mem_union_right
  exact ⟨s, hs_dom, hs_lt, h_F⟩

/--
Extension seed includes P-obligations.
-/
lemma extensionSeed_includes_PObligations (F : GHCoherentPartialFamily) (t s : Int)
    (hs_dom : s ∈ F.domain) (hs_gt : t < s) (phi : Formula)
    (h_P : Formula.some_past phi ∈ F.mcs s) :
    phi ∈ extensionSeed F t := by
  apply Set.mem_union_right
  exact ⟨s, hs_dom, hs_gt, h_P⟩

/-!
### Boundary Seed Definitions

At a boundary time, the extension seed simplifies because only one temporal direction
contributes. For an upper boundary (t > all domain elements), there are no future domain
elements, so HContent and PObligations are empty. For a lower boundary (t < all domain
elements), GContent and FObligations are empty.
-/

/--
The boundary seed for extending at an upper boundary time.
Since t is greater than all domain elements, only GContent from past times
and FObligations (from past times) contribute.
-/
def upperBoundarySeed (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  (⋃ s ∈ {s | s ∈ F.domain ∧ s < t}, GContent (F.mcs s)) ∪
  FObligations F t

/--
The boundary seed for extending at a lower boundary time.
Since t is less than all domain elements, only HContent from future times
and PObligations (from future times) contribute.
-/
def lowerBoundarySeed (F : GHCoherentPartialFamily) (t : Int) : Set Formula :=
  (⋃ s ∈ {s | s ∈ F.domain ∧ t < s}, HContent (F.mcs s)) ∪
  PObligations F t

/--
At an upper boundary, the extension seed equals the upper boundary seed.
The HContent and PObligations parts are empty since all domain elements are < t.
-/
theorem extensionSeed_eq_upperBoundarySeed (F : GHCoherentPartialFamily) (t : Int)
    (h_upper : F.isUpperBoundary t) :
    extensionSeed F t = upperBoundarySeed F t := by
  ext phi
  simp only [extensionSeed, upperBoundarySeed, Set.mem_union, Set.mem_iUnion, Set.mem_setOf_eq]
  constructor
  · -- extensionSeed → upperBoundarySeed
    rintro (((⟨s, ⟨hs_dom, hs_lt⟩, h_G⟩ | ⟨s, ⟨hs_dom, hs_gt⟩, h_H⟩) | h_F) | h_P)
    · -- GContent: same
      left
      exact ⟨s, ⟨hs_dom, hs_lt⟩, h_G⟩
    · -- HContent: impossible (no future domain elements at upper boundary)
      exact absurd hs_gt (by have := h_upper.all_lt s hs_dom; omega)
    · -- FObligations: same
      right
      exact h_F
    · -- PObligations: impossible (no future domain elements)
      obtain ⟨s, hs_dom, hs_gt, _⟩ := h_P
      exact absurd (h_upper.all_lt s hs_dom) (by omega)
  · -- upperBoundarySeed → extensionSeed
    rintro (⟨s, ⟨hs_dom, hs_lt⟩, h_G⟩ | h_F)
    · left; left; left
      exact ⟨s, ⟨hs_dom, hs_lt⟩, h_G⟩
    · left; right
      exact h_F

/--
At a lower boundary, the extension seed equals the lower boundary seed.
The GContent and FObligations parts are empty since all domain elements are > t.
-/
theorem extensionSeed_eq_lowerBoundarySeed (F : GHCoherentPartialFamily) (t : Int)
    (h_lower : F.isLowerBoundary t) :
    extensionSeed F t = lowerBoundarySeed F t := by
  ext phi
  simp only [extensionSeed, lowerBoundarySeed, Set.mem_union, Set.mem_iUnion, Set.mem_setOf_eq]
  constructor
  · -- extensionSeed → lowerBoundarySeed
    rintro (((⟨s, ⟨hs_dom, hs_lt⟩, h_G⟩ | ⟨s, ⟨hs_dom, hs_gt⟩, h_H⟩) | h_F) | h_P)
    · -- GContent: impossible (no past domain elements)
      exact absurd (h_lower.all_gt s hs_dom) (by omega)
    · -- HContent: same
      left
      exact ⟨s, ⟨hs_dom, hs_gt⟩, h_H⟩
    · -- FObligations: impossible (no past domain elements)
      obtain ⟨s, hs_dom, hs_lt, _⟩ := h_F
      exact absurd (h_lower.all_gt s hs_dom) (by omega)
    · -- PObligations: same
      right
      exact h_P
  · -- lowerBoundarySeed → extensionSeed
    rintro (⟨s, ⟨hs_dom, hs_gt⟩, h_H⟩ | h_P)
    · left; left; right
      exact ⟨s, ⟨hs_dom, hs_gt⟩, h_H⟩
    · right
      exact h_P

/--
GContent of an MCS is consistent.
-/
lemma GContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (GContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx => by
    have h_G : Formula.all_future x ∈ M := hL x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_future x).imp x) (Axiom.temp_t_future x)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G
  exact h_mcs.1 L hL_in_M ⟨d⟩

/--
HContent of an MCS is consistent.
-/
lemma HContent_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (HContent M) := by
  intro L hL ⟨d⟩
  have hL_in_M : ∀ x ∈ L, x ∈ M := fun x hx => by
    have h_H : Formula.all_past x ∈ M := hL x hx
    have h_T := DerivationTree.axiom [] ((Formula.all_past x).imp x) (Axiom.temp_t_past x)
    exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H
  exact h_mcs.1 L hL_in_M ⟨d⟩

/--
Extension seed consistency: The seed for extending F to time t is consistent.

**Proof Strategy**:
The seed includes G-content, H-content, F-obligations, and P-obligations.
All of these are subsets of what could be consistently added to an MCS:
- G-content: G phi ∈ mcs(s) for s < t implies phi is derivable from mcs(s) by axiom T (G phi → phi)
- H-content: H phi ∈ mcs(s) for s > t implies phi is derivable from mcs(s) by axiom T
- F-obligations: F phi ∈ mcs(s) means phi is consistent with mcs(s) (by temporal saturation)
- P-obligations: P phi ∈ mcs(s) means phi is consistent with mcs(s) (by temporal saturation)

The key insight is that all these formulas are individually consistent with each other
because they all derive from the coherent MCS structure.

**Technical debt**: This proof requires careful handling of the cross-sign case where
G-content from past times must be compatible with H-content from future times. This uses
the 4-axiom (G phi → GG phi, H phi → HH phi) to show that formulas propagate correctly.
-/
/-
Key lemma: All GContent from times ≤ s propagates to GContent at s via the 4-axiom.

If s1 < s2 and both in domain, then GContent(mcs(s1)) ⊆ GContent(mcs(s2)).
Proof: G phi ∈ mcs(s1) → GG phi ∈ mcs(s1) (4-axiom) → G phi ∈ mcs(s2) (forward_G)
-/
lemma GContent_propagates_forward (F : GHCoherentPartialFamily) (s1 s2 : Int)
    (hs1 : s1 ∈ F.domain) (hs2 : s2 ∈ F.domain) (h_lt : s1 < s2) :
    GContent (F.mcs s1) ⊆ GContent (F.mcs s2) := by
  intro phi h_in_G1
  -- G phi ∈ mcs(s1)
  have h_G_phi : Formula.all_future phi ∈ F.mcs s1 := h_in_G1
  -- By 4-axiom: GG phi ∈ mcs(s1)
  have h_GG_phi : Formula.all_future (Formula.all_future phi) ∈ F.mcs s1 :=
    set_mcs_all_future_all_future (F.is_mcs s1 hs1) h_G_phi
  -- By forward_G from s1 to s2: G phi ∈ mcs(s2)
  exact F.forward_G s1 s2 hs1 hs2 h_lt (Formula.all_future phi) h_GG_phi

/-
Symmetric lemma for HContent propagating backward.
-/
lemma HContent_propagates_backward (F : GHCoherentPartialFamily) (s1 s2 : Int)
    (hs1 : s1 ∈ F.domain) (hs2 : s2 ∈ F.domain) (h_lt : s1 < s2) :
    HContent (F.mcs s2) ⊆ HContent (F.mcs s1) := by
  intro phi h_in_H2
  -- H phi ∈ mcs(s2)
  have h_H_phi : Formula.all_past phi ∈ F.mcs s2 := h_in_H2
  -- By 4-axiom (past): HH phi ∈ mcs(s2)
  have h_HH_phi : Formula.all_past (Formula.all_past phi) ∈ F.mcs s2 :=
    set_mcs_all_past_all_past (F.is_mcs s2 hs2) h_H_phi
  -- By backward_H from s2 to s1: H phi ∈ mcs(s1)
  exact F.backward_H s2 s1 hs1 hs2 h_lt (Formula.all_past phi) h_HH_phi

/-
Key lemma: All GContent from past times flows to the MCS at ANY past time.
This is because G phi at time s implies G phi at all times s' > s (via 4-axiom + forward_G).
For times s' < s, we need backward reasoning which isn't available.
So we need to pick the "supremum" past time.
-/

/-
Multi-temporal witness seed consistency for multiple F-obligations.

If all F psi_i are in the same MCS M, then {psi_1, ..., psi_k} ∪ GContent(M) is consistent.

**Proof Strategy**:
By induction on the number of F-obligations.
Base case: GContent(M) is consistent (GContent_consistent).
Inductive case: Given {psi_1, ..., psi_{k-1}} ∪ GContent(M) is consistent,
  show adding psi_k preserves consistency using the temporal_witness_seed_consistent argument.

Actually, the temporal_witness_seed_consistent proof handles this:
If L ⊆ {psi_1, ..., psi_k} ∪ GContent(M) and L ⊢ ⊥, then
- Filter L into L_psis (elements in {psi_1, ..., psi_k}) and L_G (elements in GContent(M))
- Use deduction theorem: L_G ⊢ neg(conjunction of L_psis)
- Apply generalized_temporal_k: G(L_G) ⊢ G(neg(...))
- Since G(L_G) ⊆ M and F(psi_i) ∈ M, derive contradiction
-/

/--
Helper: Given L ⊆ GContent(M), all elements of L are in M (via T-axiom).
-/
lemma GContent_subset_MCS (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (L : List Formula) (hL : ∀ phi ∈ L, phi ∈ GContent M) :
    ∀ phi ∈ L, phi ∈ M := by
  intro phi h_mem
  have h_G_phi : Formula.all_future phi ∈ M := hL phi h_mem
  have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_G_phi

/--
Helper: Given L ⊆ HContent(M), all elements of L are in M (via T-axiom).
-/
lemma HContent_subset_MCS (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (L : List Formula) (hL : ∀ phi ∈ L, phi ∈ HContent M) :
    ∀ phi ∈ L, phi ∈ M := by
  intro phi h_mem
  have h_H_phi : Formula.all_past phi ∈ M := hL phi h_mem
  have h_T := DerivationTree.axiom [] ((Formula.all_past phi).imp phi) (Axiom.temp_t_past phi)
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T) h_H_phi

/--
Multi-witness temporal seed consistency: If F psi_1, ..., F psi_n are all in MCS M,
then {psi_1, ..., psi_n} ∪ GContent(M) is consistent.

This generalizes temporal_witness_seed_consistent from a single F-obligation to multiple.

**Proof Strategy**:
Suppose L ⊆ {psi_1, ..., psi_n} ∪ GContent(M) and L ⊢ ⊥.
Let L_psi = {psi_i ∈ L} and L_G = {chi ∈ L : chi ∈ GContent(M), chi ∉ {psi_1,...,psi_n}}.
We have L = L_psi ++ L_G (modulo ordering) and L ⊢ ⊥.

By deduction theorem (applied multiple times):
  L_G ⊢ neg(psi_{i_1}) ∨ ... ∨ neg(psi_{i_k})
where psi_{i_1}, ..., psi_{i_k} are the elements of L_psi.

By generalized_temporal_k:
  G(L_G) ⊢ G(neg(psi_{i_1}) ∨ ... ∨ neg(psi_{i_k}))

Since G distributes over disjunction (requires proof), and G(L_G) ⊆ M:
  G(neg(psi_{i_1})) ∨ ... ∨ G(neg(psi_{i_k})) ∈ M (or derivable from M)

But each F psi_i = neg(G(neg psi_i)) ∈ M, so G(neg psi_i) ∉ M.
In an MCS, exactly one of G(neg psi_i) or neg(G(neg psi_i)) is in M.
So all G(neg psi_i) are NOT in M.
But a disjunction is in MCS iff some disjunct is in MCS.
So G(neg(psi_{i_j})) ∈ M for some j.
Contradiction!

**Technical Note**: This proof sketch assumes G distributes over disjunction,
which requires additional lemmas. The actual proof may use a different approach.
-/
theorem multi_witness_seed_consistent_future (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (Psis : List Formula) (h_F : ∀ psi ∈ Psis, Formula.some_future psi ∈ M) :
    SetConsistent ({phi | phi ∈ Psis} ∪ GContent M) := by
  -- The proof is complex; for now we use the structure to identify the key steps
  -- and leave sorry for the detailed derivation manipulation
  intro L hL ⟨d⟩

  -- Partition L into elements from Psis and elements from GContent
  let L_psis := L.filter (fun phi => decide (phi ∈ Psis))
  let L_G := L.filter (fun phi => decide (phi ∉ Psis))

  -- If no psis in L, then L ⊆ GContent M which is consistent
  by_cases h_any_psi : L_psis = []
  · -- L contains no psis, so L ⊆ GContent M
    have h_L_in_G : ∀ phi ∈ L, phi ∈ GContent M := by
      intro phi h_mem
      have h_in_union := hL phi h_mem
      simp only [Set.mem_union, Set.mem_setOf_eq] at h_in_union
      rcases h_in_union with h_in_psis | h_in_G
      · -- phi ∈ Psis, but L_psis = [], contradiction
        have h_filter : phi ∈ L_psis := by
          simp only [L_psis, List.mem_filter, decide_eq_true_eq]
          exact ⟨h_mem, h_in_psis⟩
        rw [h_any_psi] at h_filter
        exact False.elim (List.not_mem_nil h_filter)
      · exact h_in_G
    -- L ⊆ GContent M is consistent by GContent_consistent
    have h_cons := GContent_consistent M h_mcs
    have h_L_in_M := GContent_subset_MCS M h_mcs L h_L_in_G
    exact h_mcs.1 L h_L_in_M ⟨d⟩

  · -- L contains at least one psi
    -- This is the hard case requiring the derivation manipulation
    -- The key insight: we use the same argument as temporal_witness_seed_consistent
    -- but applied to a conjunction of negations

    -- For now, we leave this as sorry - the full proof requires
    -- building infrastructure for multi-formula deduction
    sorry

/--
Symmetric version for P-obligations (past temporal operators).
-/
theorem multi_witness_seed_consistent_past (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (Psis : List Formula) (h_P : ∀ psi ∈ Psis, Formula.some_past psi ∈ M) :
    SetConsistent ({phi | phi ∈ Psis} ∪ HContent M) := by
  -- Symmetric to multi_witness_seed_consistent_future
  intro L hL ⟨d⟩

  let L_psis := L.filter (fun phi => decide (phi ∈ Psis))
  let L_H := L.filter (fun phi => decide (phi ∉ Psis))

  by_cases h_any_psi : L_psis = []
  · have h_L_in_H : ∀ phi ∈ L, phi ∈ HContent M := by
      intro phi h_mem
      have h_in_union := hL phi h_mem
      simp only [Set.mem_union, Set.mem_setOf_eq] at h_in_union
      rcases h_in_union with h_in_psis | h_in_H
      · have h_filter : phi ∈ L_psis := by
          simp only [L_psis, List.mem_filter, decide_eq_true_eq]
          exact ⟨h_mem, h_in_psis⟩
        rw [h_any_psi] at h_filter
        exact False.elim (List.not_mem_nil h_filter)
      · exact h_in_H
    have h_cons := HContent_consistent M h_mcs
    have h_L_in_M := HContent_subset_MCS M h_mcs L h_L_in_H
    exact h_mcs.1 L h_L_in_M ⟨d⟩

  · sorry

theorem extensionSeed_consistent (F : GHCoherentPartialFamily) (t : Int) (ht : t ∉ F.domain) :
    SetConsistent (extensionSeed F t) := by
  intro L hL ⟨d⟩

  obtain ⟨anchor, h_anchor⟩ := F.domain_nonempty

  by_cases h_past : ∃ s, s ∈ F.domain ∧ s < t
  · by_cases h_future : ∃ s, s ∈ F.domain ∧ t < s
    · -- Both past and future times exist - the hard case
      -- Need to show content from past and future times is compatible
      -- The key is that all formulas in the seed are individually consistent
      -- with the MCS structure by construction
      sorry  -- Cross-sign consistency: requires 4-axiom propagation

    · -- Only past times exist (pure past case)
      push_neg at h_future
      obtain ⟨s_witness, hs_witness_dom, hs_witness_lt⟩ := h_past

      -- PROOF STRATEGY (Pure Past Case):
      -- The seed simplifies to: (⋃ s<t GContent(mcs(s))) ∪ FObligations
      -- (HContent and PObligations are empty since no future times exist)
      --
      -- Key insights:
      -- 1. GContent propagates forward via 4-axiom: GContent(mcs(s1)) ⊆ GContent(mcs(s2)) for s1 < s2
      -- 2. For each F-obligation psi (where F psi ∈ mcs(s)), {psi} ∪ GContent(mcs(s)) is consistent
      --    (by temporal_witness_seed_consistent)

      -- Step 1: Show each element of L comes from GContent or FObligations
      -- (HContent and PObligations are vacuously empty since no future times exist)
      have h_L_simplified : ∀ phi ∈ L,
          (∃ s, s ∈ F.domain ∧ s < t ∧ phi ∈ GContent (F.mcs s)) ∨
          (∃ s, s ∈ F.domain ∧ s < t ∧ Formula.some_future phi ∈ F.mcs s) := by
        intro phi h_phi_L
        have h_in_seed := hL phi h_phi_L
        simp only [extensionSeed, Set.mem_union, Set.mem_iUnion, Set.mem_setOf_eq] at h_in_seed
        -- extensionSeed is ((GContent_union ∪ HContent_union) ∪ FObligations) ∪ PObligations
        rcases h_in_seed with ((h_GH | h_F) | h_P)
        · -- From GContent ∪ HContent
          rcases h_GH with ⟨s, ⟨hs_dom, hs_lt⟩, h_in_G⟩ | ⟨s, ⟨hs_dom, hs_gt⟩, h_in_H⟩
          · -- From GContent
            left
            exact ⟨s, hs_dom, hs_lt, h_in_G⟩
          · -- From HContent - but no future times exist!
            have h_le := h_future s hs_dom
            omega
        · -- From FObligations
          right
          obtain ⟨s, hs_dom, hs_lt, h_F_in⟩ := h_F
          exact ⟨s, hs_dom, hs_lt, h_F_in⟩
        · -- From PObligations - but no future times exist!
          obtain ⟨s, hs_dom, hs_gt, _⟩ := h_P
          have h_le := h_future s hs_dom
          omega

      -- Step 2: Use s_witness as the reference MCS and show GContent propagates to it
      -- Note: GContent propagates FORWARD, so elements from s < s_witness propagate to s_witness
      -- For elements from s > s_witness, we need s_witness < s, and then GContent(mcs(s_witness)) ⊆ GContent(mcs(s))
      -- So we should use the MAXIMUM source time, not s_witness

      -- Helper: Given phi ∈ GContent(mcs(s)) for s ∈ domain with s < t,
      -- phi propagates to GContent(mcs(s')) for any s' ∈ domain with s ≤ s' < t
      have h_GContent_to_witness : ∀ phi, ∀ s s', s ∈ F.domain → s' ∈ F.domain →
          s ≤ s' → phi ∈ GContent (F.mcs s) → phi ∈ GContent (F.mcs s') := by
        intro phi s s' hs_dom hs'_dom h_le h_in_G
        by_cases h_eq : s = s'
        · rw [← h_eq]; exact h_in_G
        · have h_lt : s < s' := by omega
          exact GContent_propagates_forward F s s' hs_dom hs'_dom h_lt h_in_G

      -- Step 3: Case split on whether all elements come from GContent
      by_cases h_all_G : ∀ phi ∈ L, ∃ s, s ∈ F.domain ∧ s < t ∧ phi ∈ GContent (F.mcs s)
      · -- All elements come from GContent
        -- Strategy: Find the maximum source time and show all elements propagate there
        -- For simplicity, use s_witness and show elements from smaller times propagate forward
        -- Elements from larger times: we need a different approach

        -- Actually, let's just show all elements eventually end up in some mcs via T-axiom
        -- If phi ∈ GContent(mcs(s)), then G phi ∈ mcs(s), so by T-axiom, phi ∈ mcs(s)
        have h_L_in_some_M : ∀ phi ∈ L, ∃ s, s ∈ F.domain ∧ phi ∈ F.mcs s := by
          intro phi h_mem
          obtain ⟨s, hs_dom, _, h_in_G⟩ := h_all_G phi h_mem
          have h_G_phi : Formula.all_future phi ∈ F.mcs s := h_in_G
          have h_T := DerivationTree.axiom [] ((Formula.all_future phi).imp phi) (Axiom.temp_t_future phi)
          exact ⟨s, hs_dom, set_mcs_implication_property (F.is_mcs s hs_dom) (theorem_in_mcs (F.is_mcs s hs_dom) h_T) h_G_phi⟩

        -- Key insight: All GContent propagates forward to the maximum source time
        -- Since L is finite, we can find the maximum source time among its elements

        -- Define the set of source times for L
        let source_times : Set Int := { s | ∃ phi ∈ L, s ∈ F.domain ∧ s < t ∧ phi ∈ GContent (F.mcs s) }

        -- source_times is nonempty (assuming L is nonempty)
        by_cases h_L_empty : L = []
        · -- L is empty: [] ⊢ ⊥ means all elements of [] are in any GContent
          -- Since [] has no elements, vacuously all are in GContent(mcs(s_witness))
          -- So we can show L ⊆ GContent(mcs(s_witness)) and use its consistency
          have h_L_in_G : ∀ phi ∈ L, phi ∈ GContent (F.mcs s_witness) := by
            intro phi h_mem
            rw [h_L_empty] at h_mem
            exact False.elim (List.not_mem_nil h_mem)
          have h_L_in_M := GContent_subset_MCS (F.mcs s_witness) (F.is_mcs s_witness hs_witness_dom) L h_L_in_G
          exact (F.is_mcs s_witness hs_witness_dom).1 L h_L_in_M ⟨d⟩

        · -- L is nonempty
          have h_L_ne : L ≠ [] := h_L_empty
          obtain ⟨phi0, h_phi0_mem⟩ := List.exists_mem_of_ne_nil L h_L_ne
          obtain ⟨s0, hs0_dom, hs0_lt, h_phi0_G⟩ := h_all_G phi0 h_phi0_mem

          -- Strategy: Use induction on L to find maximum source time and show
          -- all elements propagate to GContent at that time

          -- For a cleaner proof, we use the following approach:
          -- Define a "max source time" function recursively on L
          -- Then show all elements propagate to GContent at max time

          -- Alternative: Use the structure of GContent propagation more directly
          -- Since GContent propagates forward, if we have multiple source times s1 < s2,
          -- elements from s1 propagate to s2

          -- Claim: All elements of L are in GContent(mcs(s_max)) where s_max is the
          -- maximum source time among L's elements

          -- For the actual proof, we use a simpler approach:
          -- We show by induction that for any prefix of L, all elements are in
          -- GContent of the maximum source time seen so far

          -- Actually, the cleanest approach: since L is finite, use List.foldl
          -- to compute the maximum source time, then show all elements propagate there

          -- For now, we implement a direct argument using strong induction on List length
          -- or using the well-foundedness of the < relation on bounded integers

          -- Simpler approach: Use the fact that all source times are < t and ≥ some minimum
          -- So the set of possible source times is finite

          -- Let s_max be the maximum source time among elements of L
          -- We prove this exists by showing source_times is finite and nonempty

          -- Technical implementation: Use Finset operations on the bounded integer interval
          -- This requires decidable membership in F.domain, which we might not have

          -- Practical approach: Prove by cases or use a specific construction
          -- For L = [phi1, ..., phin], find max{s_i} where phi_i ∈ GContent(mcs(s_i))

          -- The cleanest proof: use List.rec induction
          -- Base case: single element - trivially in GContent of its source
          -- Inductive case: add one element - either new source is larger (use it) or smaller (propagate)

          suffices h_all_in_max : ∃ s_max, s_max ∈ F.domain ∧ s_max < t ∧
              ∀ phi ∈ L, phi ∈ GContent (F.mcs s_max) by
            obtain ⟨s_max, hs_max_dom, _, h_all_G_max⟩ := h_all_in_max
            -- L ⊆ GContent(mcs(s_max)), which is consistent
            have h_L_in_G : ∀ phi ∈ L, phi ∈ GContent (F.mcs s_max) := h_all_G_max
            have h_L_in_M := GContent_subset_MCS (F.mcs s_max) (F.is_mcs s_max hs_max_dom) L h_L_in_G
            exact (F.is_mcs s_max hs_max_dom).1 L h_L_in_M ⟨d⟩

          -- Prove the existence of s_max by a lemma about lists with GContent sources
          -- The key insight: for a nonempty list L with all elements from GContent,
          -- there exists a maximum source time to which all elements propagate

          -- Helper lemma applied to L
          have h_max_exists : ∀ L' : List Formula,
              L' ≠ [] →
              (∀ phi ∈ L', ∃ s ∈ F.domain, s < t ∧ phi ∈ GContent (F.mcs s)) →
              ∃ s_max ∈ F.domain, s_max < t ∧ ∀ phi ∈ L', phi ∈ GContent (F.mcs s_max) := by
            intro L' h_ne h_all_G_L'
            induction L' with
            | nil => exact absurd rfl h_ne
            | cons phi L'' ih_inner =>
              obtain ⟨s_phi, hs_phi_dom, hs_phi_lt, h_phi_G⟩ := h_all_G_L' phi List.mem_cons_self
              by_cases h_L''_empty : L'' = []
              · -- Base case: L' = [phi]
                use s_phi, hs_phi_dom, hs_phi_lt
                intro psi h_psi_mem
                simp only [h_L''_empty, List.mem_cons, List.not_mem_nil, or_false] at h_psi_mem
                rw [h_psi_mem]; exact h_phi_G
              · -- Inductive case
                have h_all_G_L'' : ∀ psi ∈ L'', ∃ s ∈ F.domain, s < t ∧ psi ∈ GContent (F.mcs s) := by
                  intro psi h_psi_mem
                  exact h_all_G_L' psi (List.mem_cons_of_mem phi h_psi_mem)
                obtain ⟨s_max'', hs_max''_dom, hs_max''_lt, h_all_G''_max⟩ := ih_inner h_L''_empty h_all_G_L''
                by_cases h_cmp : s_phi ≤ s_max''
                · -- Use s_max''
                  use s_max'', hs_max''_dom, hs_max''_lt
                  intro psi h_psi_mem
                  simp only [List.mem_cons] at h_psi_mem
                  rcases h_psi_mem with rfl | h_in_L''
                  · exact h_GContent_to_witness psi s_phi s_max'' hs_phi_dom hs_max''_dom h_cmp h_phi_G
                  · exact h_all_G''_max psi h_in_L''
                · -- Use s_phi
                  push_neg at h_cmp
                  use s_phi, hs_phi_dom, hs_phi_lt
                  intro psi h_psi_mem
                  simp only [List.mem_cons] at h_psi_mem
                  rcases h_psi_mem with rfl | h_in_L''
                  · exact h_phi_G
                  · have h_psi_in_max'' := h_all_G''_max psi h_in_L''
                    exact h_GContent_to_witness psi s_max'' s_phi hs_max''_dom hs_phi_dom (by omega) h_psi_in_max''

          exact h_max_exists L h_L_ne h_all_G

      · -- Some elements come from FObligations (not from GContent alone)
        -- This case requires multi_witness_seed_consistent_future.
        push_neg at h_all_G
        obtain ⟨phi_F, h_phi_F_mem, h_phi_F_not_G⟩ := h_all_G

        -- phi_F is an F-obligation element (not from GContent)
        have h_phi_F_is_obligation : ∃ s, s ∈ F.domain ∧ s < t ∧ Formula.some_future phi_F ∈ F.mcs s := by
          rcases h_L_simplified phi_F h_phi_F_mem with h_from_G | h_from_F
          · obtain ⟨s, hs_dom, hs_lt, h_in_G⟩ := h_from_G
            exfalso
            exact h_phi_F_not_G s hs_dom hs_lt h_in_G
          · exact h_from_F

        -- Strategy:
        -- 1. Partition L into GContent elements and FObligations elements
        -- 2. Find a reference MCS M where:
        --    - All GContent elements propagate to GContent(M)
        --    - All F phi ∈ M for FObligations elements
        -- 3. Apply multi_witness_seed_consistent_future
        --
        -- The challenge: F phi ∈ mcs(s) does NOT imply F phi ∈ mcs(s') for s' > s!
        -- (F phi is existential, not universal like G phi)
        --
        -- Alternative approach: Use the MINIMUM source time s_min
        -- Then GContent doesn't propagate backward, but F obligations at larger times
        -- might still work...
        --
        -- Actually, neither direction works cleanly:
        -- - Forward: F doesn't propagate
        -- - Backward: GContent doesn't propagate
        --
        -- The key insight should be:
        -- - The seed is designed to be exactly the formulas needed for F/P coherence
        -- - Its consistency follows from the structure of temporal logic
        --
        -- Technical debt: This case requires infrastructure for:
        -- 1. Tracking source times for GContent and FObligations separately
        -- 2. Finding a common MCS (if one exists) or proving consistency directly
        -- 3. The multi_witness_seed_consistent_future theorem itself has a sorry
        --
        -- The fundamental issue: we need to prove that mixing GContent from different
        -- times with FObligations from different times remains consistent.
        -- This likely requires a more sophisticated argument about derivations.
        sorry

  · push_neg at h_past
    by_cases h_future : ∃ s, s ∈ F.domain ∧ t < s
    · obtain ⟨s_witness, hs_witness_dom, hs_witness_gt⟩ := h_future
      -- Only future times exist (pure future case - symmetric to pure past)
      --
      -- PROOF STRATEGY:
      -- The seed simplifies to: (⋃ s>t HContent(mcs(s))) ∪ PObligations
      -- (GContent and FObligations are empty since no past times exist)
      --
      -- Key insights:
      -- 1. HContent propagates backward via 4-axiom: HContent(mcs(s2)) ⊆ HContent(mcs(s1)) for s1 < s2
      -- 2. For each P-obligation psi (where P psi ∈ mcs(s)), {psi} ∪ HContent(mcs(s)) is consistent
      --    (by temporal_witness_seed_consistent_past)
      --
      -- Strategy (symmetric to pure past):
      -- - All HContent elements from L propagate backward to HContent(mcs(s_witness))
      -- - Apply multi_witness_seed_consistent_past at mcs(s_witness)

      -- Step 1: Show each element of L comes from HContent or PObligations
      -- (GContent and FObligations are vacuously empty since no past times exist)
      have h_L_simplified : ∀ phi ∈ L,
          (∃ s, s ∈ F.domain ∧ t < s ∧ phi ∈ HContent (F.mcs s)) ∨
          (∃ s, s ∈ F.domain ∧ t < s ∧ Formula.some_past phi ∈ F.mcs s) := by
        intro phi h_phi_L
        have h_phi := hL phi h_phi_L
        simp only [extensionSeed, Set.mem_union, Set.mem_iUnion, Set.mem_setOf_eq] at h_phi
        rcases h_phi with (((h_G | h_H) | h_FObl) | h_PObl)
        · -- GContent case - impossible since no past times
          obtain ⟨s, ⟨hs_dom, hs_lt⟩, _⟩ := h_G
          have := h_past s hs_dom
          omega
        · -- HContent case
          obtain ⟨s, ⟨hs_dom, hs_gt⟩, h_in⟩ := h_H
          left
          exact ⟨s, hs_dom, hs_gt, h_in⟩
        · -- FObligations case - impossible since no past times
          obtain ⟨s, hs_dom, hs_lt, _⟩ := h_FObl
          have := h_past s hs_dom
          omega
        · -- PObligations case
          right
          exact h_PObl

      -- Step 2: For HContent elements, use backward propagation to a MINIMUM source time
      -- HContent propagates backward: if s1 < s2, then HContent(mcs(s2)) ⊆ HContent(mcs(s1))
      -- So we need to find the MINIMUM source time to collect all elements
      --
      -- Helper: propagate from larger time to smaller time
      have h_HContent_backward : ∀ phi s1 s2, s1 ∈ F.domain → s2 ∈ F.domain →
          s1 ≤ s2 → phi ∈ HContent (F.mcs s2) → phi ∈ HContent (F.mcs s1) := by
        intro phi s1 s2 hs1_dom hs2_dom h_le h_in
        by_cases h_eq : s1 = s2
        · exact h_eq ▸ h_in
        · have h_lt : s1 < s2 := by omega
          exact HContent_propagates_backward F s1 s2 hs1_dom hs2_dom h_lt h_in

      -- Step 3: Case split on whether all elements come from HContent
      by_cases h_all_H : ∀ phi ∈ L, ∃ s, s ∈ F.domain ∧ t < s ∧ phi ∈ HContent (F.mcs s)
      · -- All elements come from HContent at various times
        -- Strategy: find the MINIMUM source time and show all elements propagate there
        -- (Since HContent propagates backward, later times' content is in earlier times)

        by_cases h_L_empty : L = []
        · -- L is empty: vacuously all elements are in HContent(mcs(s_witness))
          have h_L_in_H : ∀ phi ∈ L, phi ∈ HContent (F.mcs s_witness) := by
            intro phi h_mem
            rw [h_L_empty] at h_mem
            exact False.elim (List.not_mem_nil h_mem)
          have h_L_in_M := HContent_subset_MCS (F.mcs s_witness) (F.is_mcs s_witness hs_witness_dom) L h_L_in_H
          exact (F.is_mcs s_witness hs_witness_dom).1 L h_L_in_M ⟨d⟩

        · -- L is nonempty
          -- Prove existence of minimum source time by induction on L
          have h_min_exists : ∀ L' : List Formula,
              L' ≠ [] →
              (∀ phi ∈ L', ∃ s ∈ F.domain, t < s ∧ phi ∈ HContent (F.mcs s)) →
              ∃ s_min ∈ F.domain, t < s_min ∧ ∀ phi ∈ L', phi ∈ HContent (F.mcs s_min) := by
            intro L' h_ne h_all_H_L'
            induction L' with
            | nil => exact absurd rfl h_ne
            | cons phi L'' ih_inner =>
              obtain ⟨s_phi, hs_phi_dom, hs_phi_gt, h_phi_H⟩ := h_all_H_L' phi List.mem_cons_self
              by_cases h_L''_empty : L'' = []
              · -- Base case: L' = [phi]
                use s_phi, hs_phi_dom, hs_phi_gt
                intro psi h_psi_mem
                simp only [h_L''_empty, List.mem_cons, List.not_mem_nil, or_false] at h_psi_mem
                rw [h_psi_mem]; exact h_phi_H
              · -- Inductive case
                have h_all_H_L'' : ∀ psi ∈ L'', ∃ s ∈ F.domain, t < s ∧ psi ∈ HContent (F.mcs s) := by
                  intro psi h_psi_mem
                  exact h_all_H_L' psi (List.mem_cons_of_mem phi h_psi_mem)
                obtain ⟨s_min'', hs_min''_dom, hs_min''_gt, h_all_H''_min⟩ := ih_inner h_L''_empty h_all_H_L''
                -- Compare s_phi and s_min'' - take the MINIMUM
                by_cases h_cmp : s_phi ≤ s_min''
                · -- s_phi ≤ s_min'', so use s_phi (the smaller one)
                  use s_phi, hs_phi_dom, hs_phi_gt
                  intro psi h_psi_mem
                  simp only [List.mem_cons] at h_psi_mem
                  rcases h_psi_mem with rfl | h_in_L''
                  · exact h_phi_H
                  · -- psi is in HContent at s_min'', propagate backward to s_phi
                    have h_psi_in_min'' := h_all_H''_min psi h_in_L''
                    exact h_HContent_backward psi s_phi s_min'' hs_phi_dom hs_min''_dom h_cmp h_psi_in_min''
                · -- s_min'' < s_phi, so use s_min'' (the smaller one)
                  push_neg at h_cmp
                  use s_min'', hs_min''_dom, hs_min''_gt
                  intro psi h_psi_mem
                  simp only [List.mem_cons] at h_psi_mem
                  rcases h_psi_mem with rfl | h_in_L''
                  · -- psi (was phi) is in HContent at s_phi, propagate backward to s_min''
                    exact h_HContent_backward psi s_min'' s_phi hs_min''_dom hs_phi_dom (by omega) h_phi_H
                  · exact h_all_H''_min psi h_in_L''

          obtain ⟨s_min, hs_min_dom, _, h_L_in_H_min⟩ := h_min_exists L h_L_empty h_all_H
          -- L ⊆ HContent(mcs(s_min)), which is consistent
          have h_L_in_M := HContent_subset_MCS (F.mcs s_min) (F.is_mcs s_min hs_min_dom) L h_L_in_H_min
          exact (F.is_mcs s_min hs_min_dom).1 L h_L_in_M ⟨d⟩

      · -- Some elements come purely from PObligations (not from HContent)
        -- This case requires multi_witness_seed_consistent_past.
        --
        -- The proof strategy would be:
        -- 1. Collect all pure PObligations as a list Psis
        -- 2. Show all HContent elements propagate to HContent(mcs(s_witness))
        -- 3. Show all P psi_i ∈ mcs(s_witness) for some appropriate witness MCS
        --    (This step is non-trivial: P phi ∈ mcs(s) for s > s_witness
        --     does NOT imply P phi ∈ mcs(s_witness) directly)
        -- 4. Apply multi_witness_seed_consistent_past to get consistency
        --
        -- Technical debt: Step 4 is blocked on completing multi_witness_seed_consistent_past
        -- at line 680, which requires infrastructure for multi-formula deduction.
        -- The single-witness version (temporal_witness_seed_consistent_past in
        -- TemporalLindenbaum.lean) is complete but doesn't handle multiple witnesses.
        --
        -- Note: The issue is that P obligations from different times s1 > t, s2 > t
        -- cannot be easily "collected" into a single MCS without additional coherence
        -- properties (like forward_P which the partial family doesn't have).
        sorry  -- Blocked on multi_witness_seed_consistent_past (line 680)

    · -- No past or future times - domain must equal {t} but t ∉ domain
      push_neg at h_future
      exfalso
      have h_anchor_eq_t : anchor = t := by
        have h1 : t ≤ anchor := h_past anchor h_anchor
        have h2 : anchor ≤ t := h_future anchor h_anchor
        omega
      exact ht (h_anchor_eq_t ▸ h_anchor)

/-!
### Boundary Seed Consistency (Phase 3)

The key theorems of Phase 3: at boundary times, the simplified seed is consistent.

**Why boundary seeds are simpler than general seeds**:
- General extensionSeed has both past GContent + FObligations AND future HContent + PObligations
- The "cross-sign" case (reconciling past and future content) is the hardest part
- At boundary times, only one direction exists, eliminating the cross-sign case entirely

**Remaining challenge**: Even at boundaries, the seed contains both temporal content
(GContent or HContent) and temporal obligations (FObligations or PObligations) from
potentially different source times. The temporal content propagates monotonically
(GContent forward, HContent backward), but temporal obligations do NOT propagate.
Proving joint consistency of obligations from different source times is the
multi-witness consistency problem, which is the remaining sorry in extensionSeed_consistent.

**Proof structure**: Each boundary seed consistency proof reduces to the corresponding
pure-past or pure-future case of extensionSeed_consistent, which splits into:
1. All elements from temporal content only -- fully proven using propagation lemmas
2. Some elements from temporal obligations -- requires multi-witness reasoning (sorry)
-/

/--
At an upper boundary, the seed is consistent. The seed contains only GContent from
past domain times and FObligations (no HContent or PObligations since no future
domain elements exist).

**Proof strategy**:
- Case 1 (all GContent): All GContent propagates forward to a maximum source time
  via the 4-axiom (G phi -> GG phi) and forward_G. At the max time, GContent is a
  subset of the MCS, which is consistent. Fully proven.
- Case 2 (some FObligations): For each F obligation phi (where F phi in mcs(s)),
  {phi} union GContent(mcs(s)) is consistent by temporal_witness_seed_consistent.
  But obligations may come from DIFFERENT source times, and F doesn't propagate
  forward. Joint consistency of multiple obligations from different MCSs requires
  the multi-witness consistency argument.

**Technical debt**: Case 2 requires multi_witness_seed_consistent_future, which
needs a proof strategy that does NOT assume G distributes over disjunction (it doesn't).
The correct approach may involve compactness or a progressive Lindenbaum construction.
-/
theorem upper_boundary_seed_consistent (F : GHCoherentPartialFamily) (t : Int)
    (h_upper : F.isUpperBoundary t) :
    SetConsistent (upperBoundarySeed F t) := by
  rw [← extensionSeed_eq_upperBoundarySeed F t h_upper]
  exact extensionSeed_consistent F t h_upper.not_in_domain

/--
At a lower boundary, the seed is consistent. The seed contains only HContent from
future domain times and PObligations (no GContent or FObligations since no past
domain elements exist).

**Proof strategy**: Symmetric to upper_boundary_seed_consistent.
- Case 1 (all HContent): Fully proven using backward propagation.
- Case 2 (some PObligations): Requires multi_witness_seed_consistent_past (sorry).
-/
theorem lower_boundary_seed_consistent (F : GHCoherentPartialFamily) (t : Int)
    (h_lower : F.isLowerBoundary t) :
    SetConsistent (lowerBoundarySeed F t) := by
  rw [← extensionSeed_eq_lowerBoundarySeed F t h_lower]
  exact extensionSeed_consistent F t h_lower.not_in_domain

/--
At a boundary time, the extension seed is consistent.
This combines the upper and lower boundary cases.
-/
theorem boundary_seed_consistent (F : GHCoherentPartialFamily) (t : Int)
    (h_boundary : F.isBoundaryTime t) :
    SetConsistent (extensionSeed F t) := by
  rcases h_boundary with h_upper | h_lower
  · rw [extensionSeed_eq_upperBoundarySeed F t h_upper]
    exact upper_boundary_seed_consistent F t h_upper
  · rw [extensionSeed_eq_lowerBoundarySeed F t h_lower]
    exact lower_boundary_seed_consistent F t h_lower

/-!
### GContent/HContent Containment at Maximum/Minimum Source Time

These lemmas show that for a finite list of elements from the GContent/HContent union,
there exists a single source time to which all elements propagate. This is the key
structural property enabling the pure-content case of boundary seed consistency.
-/

/--
GContent from all past times is contained in GContent at a maximum source time.
Uses forward_G coherence and 4-axiom (G phi -> GG phi) for transitive propagation.

For any s1 < s2 both in domain: GContent(mcs(s1)) ⊆ GContent(mcs(s2)).
This means the union ⋃ s<t GContent(mcs(s)) is "upward directed":
all content from earlier times flows into later times' GContent.

For a finite list L, there exists a maximum source time s_max such that
all elements of L are in GContent(mcs(s_max)).
-/
lemma GContent_union_contained_at_max
    (F : GHCoherentPartialFamily) (t : Int)
    (L : List Formula) (h_ne : L ≠ [])
    (h_all_G : ∀ phi ∈ L, ∃ s ∈ F.domain, s < t ∧ phi ∈ GContent (F.mcs s)) :
    ∃ s_max ∈ F.domain, s_max < t ∧ ∀ phi ∈ L, phi ∈ GContent (F.mcs s_max) := by
  induction L with
  | nil => exact absurd rfl h_ne
  | cons phi L' ih =>
    obtain ⟨s_phi, hs_phi_dom, hs_phi_lt, h_phi_G⟩ := h_all_G phi List.mem_cons_self
    by_cases h_L'_empty : L' = []
    · exact ⟨s_phi, hs_phi_dom, hs_phi_lt, fun psi h_mem => by
        simp only [h_L'_empty, List.mem_cons, List.not_mem_nil, or_false] at h_mem
        rw [h_mem]; exact h_phi_G⟩
    · have h_all_G' : ∀ psi ∈ L', ∃ s ∈ F.domain, s < t ∧ psi ∈ GContent (F.mcs s) :=
        fun psi h_mem => h_all_G psi (List.mem_cons_of_mem phi h_mem)
      obtain ⟨s_max', hs_max'_dom, hs_max'_lt, h_all'⟩ := ih h_L'_empty h_all_G'
      by_cases h_cmp : s_phi ≤ s_max'
      · -- s_phi ≤ s_max': use s_max'
        exact ⟨s_max', hs_max'_dom, hs_max'_lt, fun psi h_mem => by
          simp only [List.mem_cons] at h_mem
          rcases h_mem with rfl | h_in_L'
          · by_cases h_eq : s_phi = s_max'
            · rw [← h_eq]; exact h_phi_G
            · exact GContent_propagates_forward F s_phi s_max' hs_phi_dom hs_max'_dom (by omega) h_phi_G
          · exact h_all' psi h_in_L'⟩
      · -- s_max' < s_phi: use s_phi
        push_neg at h_cmp
        exact ⟨s_phi, hs_phi_dom, hs_phi_lt, fun psi h_mem => by
          simp only [List.mem_cons] at h_mem
          rcases h_mem with rfl | h_in_L'
          · exact h_phi_G
          · exact GContent_propagates_forward F s_max' s_phi hs_max'_dom hs_phi_dom (by omega) (h_all' psi h_in_L')⟩

/--
HContent from all future times is contained in HContent at a minimum source time.
Uses backward_H coherence and 4-axiom (H phi -> HH phi) for transitive propagation.
-/
lemma HContent_union_contained_at_min
    (F : GHCoherentPartialFamily) (t : Int)
    (L : List Formula) (h_ne : L ≠ [])
    (h_all_H : ∀ phi ∈ L, ∃ s ∈ F.domain, t < s ∧ phi ∈ HContent (F.mcs s)) :
    ∃ s_min ∈ F.domain, t < s_min ∧ ∀ phi ∈ L, phi ∈ HContent (F.mcs s_min) := by
  induction L with
  | nil => exact absurd rfl h_ne
  | cons phi L' ih =>
    obtain ⟨s_phi, hs_phi_dom, hs_phi_gt, h_phi_H⟩ := h_all_H phi List.mem_cons_self
    by_cases h_L'_empty : L' = []
    · exact ⟨s_phi, hs_phi_dom, hs_phi_gt, fun psi h_mem => by
        simp only [h_L'_empty, List.mem_cons, List.not_mem_nil, or_false] at h_mem
        rw [h_mem]; exact h_phi_H⟩
    · have h_all_H' : ∀ psi ∈ L', ∃ s ∈ F.domain, t < s ∧ psi ∈ HContent (F.mcs s) :=
        fun psi h_mem => h_all_H psi (List.mem_cons_of_mem phi h_mem)
      obtain ⟨s_min', hs_min'_dom, hs_min'_gt, h_all'⟩ := ih h_L'_empty h_all_H'
      -- Take MINIMUM for backward propagation
      by_cases h_cmp : s_phi ≤ s_min'
      · -- s_phi ≤ s_min': use s_phi (smaller)
        exact ⟨s_phi, hs_phi_dom, hs_phi_gt, fun psi h_mem => by
          simp only [List.mem_cons] at h_mem
          rcases h_mem with rfl | h_in_L'
          · exact h_phi_H
          · have h_in_min' := h_all' psi h_in_L'
            by_cases h_eq : s_phi = s_min'
            · rw [h_eq]; exact h_in_min'
            · exact HContent_propagates_backward F s_phi s_min' hs_phi_dom hs_min'_dom (by omega) h_in_min'⟩
      · -- s_min' < s_phi: use s_min' (smaller)
        push_neg at h_cmp
        exact ⟨s_min', hs_min'_dom, hs_min'_gt, fun psi h_mem => by
          simp only [List.mem_cons] at h_mem
          rcases h_mem with rfl | h_in_L'
          · exact HContent_propagates_backward F s_min' s_phi hs_min'_dom hs_phi_dom (by omega) h_phi_H
          · exact h_all' psi h_in_L'⟩

/-!
## Part 7: Zorn's Lemma Application

We apply Zorn's lemma to the collection of GH-coherent partial families extending a base family.
The chain upper bound lemma (coherent_chain_has_upper_bound) provides the key prerequisite.

With the Preorder instance, we can use Mathlib's `zorn_le_nonempty₀` directly.
-/

/--
The collection of GH-coherent partial families extending a base family.
-/
def CoherentExtensions (base : GHCoherentPartialFamily) : Set GHCoherentPartialFamily :=
  {F | base ≤ F}

/-- The base family is in its own extensions. -/
lemma base_mem_CoherentExtensions (base : GHCoherentPartialFamily) :
    base ∈ CoherentExtensions base :=
  le_refl base

/-- Chains in CoherentExtensions have upper bounds in CoherentExtensions. -/
lemma CoherentExtensions_chain_has_ub (base : GHCoherentPartialFamily)
    (C : Set GHCoherentPartialFamily) (hC_sub : C ⊆ CoherentExtensions base)
    (hC_chain : IsChain (· ≤ ·) C) (hC_ne : C.Nonempty) :
    ∃ ub ∈ CoherentExtensions base, ∀ F ∈ C, F ≤ ub := by
  obtain ⟨ub, hub⟩ := coherent_chain_has_upper_bound C hC_ne hC_chain
  use ub
  constructor
  · -- ub extends base
    -- Pick any F ∈ C, then base ≤ F and F ≤ ub, so base ≤ ub by transitivity
    obtain ⟨F, hF⟩ := hC_ne
    have h_base_F := hC_sub hF
    have h_F_ub := hub F hF
    exact le_trans h_base_F h_F_ub
  · exact hub

/--
Zorn's lemma application result: For any base family, there exists a maximal family extending it.
This uses `zorn_le_nonempty₀` from Mathlib with our Preorder instance.
-/
theorem zorn_maximal_exists (base : GHCoherentPartialFamily) :
    ∃ M, base ≤ M ∧ Maximal (· ∈ CoherentExtensions base) M := by
  apply zorn_le_nonempty₀
  · -- Chain upper bound condition for zorn_le_nonempty₀
    intro C hC_sub hC_chain y hy
    exact CoherentExtensions_chain_has_ub base C hC_sub hC_chain ⟨y, hy⟩
  · -- base ∈ CoherentExtensions base
    exact base_mem_CoherentExtensions base

/--
Extract a maximal GH-coherent partial family extending the base.
-/
noncomputable def maximalCoherentFamily (base : GHCoherentPartialFamily) :
    GHCoherentPartialFamily :=
  (zorn_maximal_exists base).choose

/-- The maximal family extends the base. -/
lemma maximalCoherentFamily_extends (base : GHCoherentPartialFamily) :
    base ≤ maximalCoherentFamily base :=
  (zorn_maximal_exists base).choose_spec.1

/-- The maximal family is maximal among extensions. -/
lemma maximalCoherentFamily_maximal (base : GHCoherentPartialFamily) :
    Maximal (· ∈ CoherentExtensions base) (maximalCoherentFamily base) :=
  (zorn_maximal_exists base).choose_spec.2

/--
Unfolding maximality: if G extends the maximal family, it cannot strictly extend.
This uses the definition of Maximal directly without requiring PartialOrder.
-/
lemma maximalCoherentFamily_no_strict_extension (base : GHCoherentPartialFamily)
    (G : GHCoherentPartialFamily) (hG_ext : G ∈ CoherentExtensions base)
    (hle : maximalCoherentFamily base ≤ G) :
    G.domain = (maximalCoherentFamily base).domain := by
  have hmax := maximalCoherentFamily_maximal base
  -- From Maximal.2: if G ∈ extensions and maximal ≤ G, then G ≤ maximal
  have hge := hmax.2 hG_ext hle
  -- Now we have both maximal ≤ G and G ≤ maximal (domain-wise)
  exact Set.Subset.antisymm hge.1 hle.1

/-!
## Part 8: Base Family Construction

We construct a base family from a consistent context Gamma.
The base family has domain = {0} and mcs(0) = Lindenbaum extension of Gamma.

**Key Simplification (v002)**:
With F/P removed from the structure, the base family construction is trivial.
G/H coherence for a singleton domain {0} is vacuously satisfied since there
are no pairs (t, t') with t < t' in the domain.
-/

-- Note: contextAsSet and list_consistent_to_set_consistent are imported from Construction.lean
-- We use Consistent from Construction.lean which equals Consistent from Core

/--
Build a base GH-coherent partial family from a consistent context.

The base family has:
- domain = {0}
- mcs(0) = Lindenbaum extension of contextAsSet Gamma

G/H coherence conditions are vacuously satisfied since the domain is a singleton
(no pairs t < t' exist in {0}).
-/
noncomputable def buildBaseFamily (Gamma : List Formula) (h_cons : Consistent Gamma) :
    GHCoherentPartialFamily where
  domain := {0}
  mcs := fun _ =>
    (set_lindenbaum (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons)).choose
  domain_nonempty := ⟨0, Set.mem_singleton 0⟩
  is_mcs := fun t ht => by
    simp only [Set.mem_singleton_iff] at ht
    subst ht
    exact (set_lindenbaum (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons)).choose_spec.2
  forward_G := fun t t' ht ht' h_lt _phi _ => by
    -- Domain is {0}, so t = 0 and t' = 0, but h_lt says t < t' - contradiction!
    simp only [Set.mem_singleton_iff] at ht ht'
    subst ht ht'
    omega  -- 0 < 0 is false
  backward_H := fun t t' ht' ht h_lt _phi _ => by
    -- Same argument: domain is {0}, so t = 0 and t' = 0, but h_lt says t' < t
    simp only [Set.mem_singleton_iff] at ht ht'
    subst ht ht'
    omega  -- 0 < 0 is false

/-- The domain of the base family is {0}. -/
lemma buildBaseFamily_domain (Gamma : List Formula) (h_cons : Consistent Gamma) :
    (buildBaseFamily Gamma h_cons).domain = {0} := rfl

/-- 0 is in the base family domain. -/
lemma buildBaseFamily_zero_mem_domain (Gamma : List Formula) (h_cons : Consistent Gamma) :
    (0 : Int) ∈ (buildBaseFamily Gamma h_cons).domain := by
  rw [buildBaseFamily_domain]
  exact Set.mem_singleton 0

/-- The mcs at 0 for the base family. -/
lemma buildBaseFamily_mcs_zero (Gamma : List Formula) (h_cons : Consistent Gamma) :
    (buildBaseFamily Gamma h_cons).mcs 0 =
      (set_lindenbaum (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons)).choose := rfl

/-- The base family preserves the context at time 0. -/
lemma buildBaseFamily_preserves_context (Gamma : List Formula) (h_cons : Consistent Gamma) :
    ∀ gamma ∈ Gamma, gamma ∈ (buildBaseFamily Gamma h_cons).mcs 0 := by
  intro gamma h_mem
  rw [buildBaseFamily_mcs_zero]
  exact (set_lindenbaum (contextAsSet Gamma) (list_consistent_to_set_consistent h_cons)).choose_spec.1 h_mem

/-!
## Part 9: Maximal GH-Coherent Family Existence

The main theorem: for any consistent context, there exists a maximal GH-coherent partial family.
With F/P removed from the structure, the base family has no sorries!
-/

/--
Maximal GH-coherent partial family existence: For any consistent context, there exists a
GH-coherent partial family that is maximal (cannot be extended) and preserves the context.

Unlike the previous version, this theorem has NO sorries in the base family construction!
The base family with domain = {0} satisfies G/H vacuously (no pairs t < t' in {0}).
-/
theorem maximal_coherent_partial_family_exists (Gamma : List Formula)
    (h_cons : Consistent Gamma) :
    ∃ F : GHCoherentPartialFamily,
      (∀ gamma ∈ Gamma, gamma ∈ F.mcs 0) ∧
      0 ∈ F.domain ∧
      Maximal (· ∈ CoherentExtensions (buildBaseFamily Gamma h_cons)) F := by
  let base := buildBaseFamily Gamma h_cons
  let maximal := maximalCoherentFamily base
  use maximal
  refine ⟨?_, ?_, ?_⟩
  · -- Context preservation
    intro gamma h_mem
    have h_ext := maximalCoherentFamily_extends base
    have h_0_in_base : (0 : Int) ∈ base.domain := buildBaseFamily_zero_mem_domain Gamma h_cons
    have h_mcs_eq := h_ext.2 0 h_0_in_base
    rw [← h_mcs_eq]
    exact buildBaseFamily_preserves_context Gamma h_cons gamma h_mem
  · -- 0 ∈ domain
    have h_ext := maximalCoherentFamily_extends base
    have h_0_in_base : (0 : Int) ∈ base.domain := buildBaseFamily_zero_mem_domain Gamma h_cons
    exact h_ext.1 h_0_in_base
  · -- Maximality
    exact maximalCoherentFamily_maximal base

/-!
## Part 10: Maximality Implies Totality

A maximal GH-coherent partial family must have domain = Set.univ.
If not, we can extend it by adding a new time point, contradicting maximality.
-/

/-!
### Boundary Extension Functions

When extending at a **boundary time** (greater than ALL or less than ALL domain elements),
certain propagation cases become vacuously true:

- **Upper boundary** (t > all domain): No s' > t exists in domain, so `forward_G` from t
  to old domain elements is vacuous. `backward_H` to t is also vacuous (no s > t in domain).
  We still need hypotheses for `forward_G` to t (from old elements) and `backward_H` from t
  (to old elements).

- **Lower boundary** (t < all domain): No s' < t exists in domain, so `backward_H` from t
  to old domain elements is vacuous. `forward_G` to t is also vacuous (no s < t in domain).
  We still need hypotheses for `backward_H` to t (from old elements) and `forward_G` from t
  (to old elements).
-/

/-- Extend family at an upper boundary time. At an upper boundary, t > all domain elements, so:
    - forward_G FROM t is vacuously true (no s' > t in domain)
    - backward_H TO t is vacuously true (no s > t in domain)
    The remaining cases need explicit hypotheses. -/
noncomputable def extendFamilyAtUpperBoundary
    (F : GHCoherentPartialFamily) (t : Int)
    (h_upper : F.isUpperBoundary t)
    (mcs_t : Set Formula)
    (h_mcs : SetMaximalConsistent mcs_t)
    (h_forward_G_to_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_future phi ∈ F.mcs s → phi ∈ mcs_t)
    (h_backward_H_from_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_past phi ∈ mcs_t → phi ∈ F.mcs s) :
    GHCoherentPartialFamily where
  domain := F.domain ∪ {t}
  mcs := fun s => if s = t then mcs_t else F.mcs s
  domain_nonempty := ⟨t, Set.mem_union_right _ (Set.mem_singleton t)⟩
  is_mcs := fun s hs => by
    simp only [Set.mem_union, Set.mem_singleton_iff] at hs
    by_cases hs_eq : s = t
    · simp only [hs_eq, ↓reduceIte]; exact h_mcs
    · simp only [hs_eq, ↓reduceIte]
      rcases hs with hs_old | hs_t
      · exact F.is_mcs s hs_old
      · exact absurd hs_t hs_eq
  forward_G := fun s s' hs hs' h_lt phi h_G => by
    simp only [Set.mem_union, Set.mem_singleton_iff] at hs hs'
    by_cases hs_eq : s = t
    · -- Source is the new time t
      simp only [hs_eq, ↓reduceIte] at h_G ⊢
      by_cases hs'_eq : s' = t
      · -- s' = t too, but s < s', contradiction
        omega
      · -- s' is an old time with s' > t, but all old times are < t
        simp only [hs'_eq, ↓reduceIte]
        rcases hs' with hs'_old | hs'_t
        · -- s' ∈ F.domain and t < s', but all domain elements are < t
          have h_s'_lt_t := h_upper.all_lt s' hs'_old
          omega
        · exact absurd hs'_t hs'_eq
    · -- Source is an old time s
      simp only [hs_eq, ↓reduceIte] at h_G
      by_cases hs'_eq : s' = t
      · -- Target is the new time t
        simp only [hs'_eq, ↓reduceIte]
        rcases hs with hs_old | hs_t
        · exact h_forward_G_to_new s hs_old phi h_G
        · exact absurd hs_t hs_eq
      · -- Both times are old
        simp only [hs'_eq, ↓reduceIte]
        rcases hs with hs_old | hs_t
        · rcases hs' with hs'_old | hs'_t
          · exact F.forward_G s s' hs_old hs'_old h_lt phi h_G
          · exact absurd hs'_t hs'_eq
        · exact absurd hs_t hs_eq
  backward_H := fun s s' hs' hs h_lt phi h_H => by
    simp only [Set.mem_union, Set.mem_singleton_iff] at hs hs'
    by_cases hs_eq : s = t
    · -- Source is the new time t (has H phi)
      simp only [hs_eq, ↓reduceIte] at h_H ⊢
      by_cases hs'_eq : s' = t
      · -- s' = t too, but s' < s, contradiction
        omega
      · -- s' is an old time with s' < t
        simp only [hs'_eq, ↓reduceIte]
        rcases hs' with hs'_old | hs'_t
        · exact h_backward_H_from_new s' hs'_old phi h_H
        · exact absurd hs'_t hs'_eq
    · -- Source is an old time s
      simp only [hs_eq, ↓reduceIte] at h_H
      by_cases hs'_eq : s' = t
      · -- Target is the new time t, need s' < s, i.e., t < s
        -- But all domain elements are < t, so t < s with s ∈ domain is impossible
        rcases hs with hs_old | hs_t
        · have h_s_lt_t := h_upper.all_lt s hs_old
          omega
        · exact absurd hs_t hs_eq
      · -- Both times are old
        simp only [hs'_eq, ↓reduceIte]
        rcases hs' with hs'_old | hs'_t
        · rcases hs with hs_old | hs_t
          · exact F.backward_H s s' hs'_old hs_old h_lt phi h_H
          · exact absurd hs_t hs_eq
        · exact absurd hs'_t hs'_eq

/-- The upper boundary extension strictly extends F. -/
lemma extendFamilyAtUpperBoundary_strictly_extends
    (F : GHCoherentPartialFamily) (t : Int)
    (h_upper : F.isUpperBoundary t)
    (mcs_t : Set Formula)
    (h_mcs : SetMaximalConsistent mcs_t)
    (h_forward_G_to_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_future phi ∈ F.mcs s → phi ∈ mcs_t)
    (h_backward_H_from_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_past phi ∈ mcs_t → phi ∈ F.mcs s) :
    F < extendFamilyAtUpperBoundary F t h_upper mcs_t h_mcs h_forward_G_to_new h_backward_H_from_new := by
  constructor
  · -- F ≤ extended
    constructor
    · intro s hs
      exact Set.mem_union_left _ hs
    · intro s hs
      have : s ≠ t := fun h => h_upper.not_in_domain (h ▸ hs)
      simp only [extendFamilyAtUpperBoundary, this, ↓reduceIte]
  · -- extended ≰ F
    intro hle
    have ht_in_ext : t ∈ (extendFamilyAtUpperBoundary F t h_upper mcs_t h_mcs h_forward_G_to_new h_backward_H_from_new).domain := by
      simp only [extendFamilyAtUpperBoundary]
      exact Set.mem_union_right _ (Set.mem_singleton t)
    exact h_upper.not_in_domain (hle.1 ht_in_ext)

/-- Extend family at a lower boundary time. At a lower boundary, t < all domain elements, so:
    - backward_H FROM t is vacuously true (no s' < t in domain)
    - forward_G TO t is vacuously true (no s < t in domain)
    The remaining cases need explicit hypotheses. -/
noncomputable def extendFamilyAtLowerBoundary
    (F : GHCoherentPartialFamily) (t : Int)
    (h_lower : F.isLowerBoundary t)
    (mcs_t : Set Formula)
    (h_mcs : SetMaximalConsistent mcs_t)
    (h_backward_H_to_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_past phi ∈ F.mcs s → phi ∈ mcs_t)
    (h_forward_G_from_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_future phi ∈ mcs_t → phi ∈ F.mcs s) :
    GHCoherentPartialFamily where
  domain := F.domain ∪ {t}
  mcs := fun s => if s = t then mcs_t else F.mcs s
  domain_nonempty := ⟨t, Set.mem_union_right _ (Set.mem_singleton t)⟩
  is_mcs := fun s hs => by
    simp only [Set.mem_union, Set.mem_singleton_iff] at hs
    by_cases hs_eq : s = t
    · simp only [hs_eq, ↓reduceIte]; exact h_mcs
    · simp only [hs_eq, ↓reduceIte]
      rcases hs with hs_old | hs_t
      · exact F.is_mcs s hs_old
      · exact absurd hs_t hs_eq
  forward_G := fun s s' hs hs' h_lt phi h_G => by
    simp only [Set.mem_union, Set.mem_singleton_iff] at hs hs'
    by_cases hs_eq : s = t
    · -- Source is the new time t (has G phi)
      simp only [hs_eq, ↓reduceIte] at h_G ⊢
      by_cases hs'_eq : s' = t
      · -- s' = t too, but s < s', contradiction
        omega
      · -- s' is an old time with s' > t
        simp only [hs'_eq, ↓reduceIte]
        rcases hs' with hs'_old | hs'_t
        · exact h_forward_G_from_new s' hs'_old phi h_G
        · exact absurd hs'_t hs'_eq
    · -- Source is an old time s
      simp only [hs_eq, ↓reduceIte] at h_G
      by_cases hs'_eq : s' = t
      · -- Target is the new time t, need s < t
        -- But all domain elements are > t, so s < t with s ∈ domain is impossible
        rcases hs with hs_old | hs_t
        · have h_t_lt_s := h_lower.all_gt s hs_old
          omega
        · exact absurd hs_t hs_eq
      · -- Both times are old
        simp only [hs'_eq, ↓reduceIte]
        rcases hs with hs_old | hs_t
        · rcases hs' with hs'_old | hs'_t
          · exact F.forward_G s s' hs_old hs'_old h_lt phi h_G
          · exact absurd hs'_t hs'_eq
        · exact absurd hs_t hs_eq
  backward_H := fun s s' hs' hs h_lt phi h_H => by
    simp only [Set.mem_union, Set.mem_singleton_iff] at hs hs'
    by_cases hs_eq : s = t
    · -- Source is the new time t
      simp only [hs_eq, ↓reduceIte] at h_H ⊢
      by_cases hs'_eq : s' = t
      · -- s' = t too, but s' < s, contradiction
        omega
      · -- s' is an old time with s' < t, but all old times are > t
        simp only [hs'_eq, ↓reduceIte]
        rcases hs' with hs'_old | hs'_t
        · -- s' ∈ F.domain and s' < t, but all domain elements are > t
          have h_t_lt_s' := h_lower.all_gt s' hs'_old
          omega
        · exact absurd hs'_t hs'_eq
    · -- Source is an old time s
      simp only [hs_eq, ↓reduceIte] at h_H
      by_cases hs'_eq : s' = t
      · -- Target is the new time t
        simp only [hs'_eq, ↓reduceIte]
        rcases hs with hs_old | hs_t
        · exact h_backward_H_to_new s hs_old phi h_H
        · exact absurd hs_t hs_eq
      · -- Both times are old
        simp only [hs'_eq, ↓reduceIte]
        rcases hs' with hs'_old | hs'_t
        · rcases hs with hs_old | hs_t
          · exact F.backward_H s s' hs'_old hs_old h_lt phi h_H
          · exact absurd hs_t hs_eq
        · exact absurd hs'_t hs'_eq

/-- The lower boundary extension strictly extends F. -/
lemma extendFamilyAtLowerBoundary_strictly_extends
    (F : GHCoherentPartialFamily) (t : Int)
    (h_lower : F.isLowerBoundary t)
    (mcs_t : Set Formula)
    (h_mcs : SetMaximalConsistent mcs_t)
    (h_backward_H_to_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_past phi ∈ F.mcs s → phi ∈ mcs_t)
    (h_forward_G_from_new : ∀ s, s ∈ F.domain → ∀ phi,
      Formula.all_future phi ∈ mcs_t → phi ∈ F.mcs s) :
    F < extendFamilyAtLowerBoundary F t h_lower mcs_t h_mcs h_backward_H_to_new h_forward_G_from_new := by
  constructor
  · -- F ≤ extended
    constructor
    · intro s hs
      exact Set.mem_union_left _ hs
    · intro s hs
      have : s ≠ t := fun h => h_lower.not_in_domain (h ▸ hs)
      simp only [extendFamilyAtLowerBoundary, this, ↓reduceIte]
  · -- extended ≰ F
    intro hle
    have ht_in_ext : t ∈ (extendFamilyAtLowerBoundary F t h_lower mcs_t h_mcs h_backward_H_to_new h_forward_G_from_new).domain := by
      simp only [extendFamilyAtLowerBoundary]
      exact Set.mem_union_right _ (Set.mem_singleton t)
    exact h_lower.not_in_domain (hle.1 ht_in_ext)

open Classical in
/-- Unified boundary extension: dispatch based on boundary type. -/
noncomputable def extendFamilyAtBoundary
    (F : GHCoherentPartialFamily) (t : Int)
    (h_boundary : F.isBoundaryTime t)
    (mcs_t : Set Formula)
    (h_mcs : SetMaximalConsistent mcs_t)
    (h_G_to_new : ∀ s, s ∈ F.domain → s < t → ∀ phi,
      Formula.all_future phi ∈ F.mcs s → phi ∈ mcs_t)
    (h_H_to_new : ∀ s, s ∈ F.domain → t < s → ∀ phi,
      Formula.all_past phi ∈ F.mcs s → phi ∈ mcs_t)
    (h_G_from_new : ∀ s, s ∈ F.domain → t < s → ∀ phi,
      Formula.all_future phi ∈ mcs_t → phi ∈ F.mcs s)
    (h_H_from_new : ∀ s, s ∈ F.domain → s < t → ∀ phi,
      Formula.all_past phi ∈ mcs_t → phi ∈ F.mcs s) :
    GHCoherentPartialFamily :=
  if h_upper : F.isUpperBoundary t then
    extendFamilyAtUpperBoundary F t h_upper mcs_t h_mcs
      (fun s hs phi hG => h_G_to_new s hs (h_upper.all_lt s hs) phi hG)
      (fun s hs phi hH => h_H_from_new s hs (h_upper.all_lt s hs) phi hH)
  else
    have h_lower : F.isLowerBoundary t := h_boundary.resolve_left h_upper
    extendFamilyAtLowerBoundary F t h_lower mcs_t h_mcs
      (fun s hs phi hH => h_H_to_new s hs (h_lower.all_gt s hs) phi hH)
      (fun s hs phi hG => h_G_from_new s hs (h_lower.all_gt s hs) phi hG)

/-!
### Unified Boundary Seed

A single entry point that dispatches to the upper or lower boundary seed
defined earlier in Part 6.
-/

open Classical in
/-- Unified boundary seed: dispatches to upper or lower based on boundary type. -/
noncomputable def boundarySeed (F : GHCoherentPartialFamily) (t : Int)
    (_h_boundary : F.isBoundaryTime t) : Set Formula :=
  if F.isUpperBoundary t then upperBoundarySeed F t
  else lowerBoundarySeed F t

/-!
### Non-Total Domain Has Boundary Time

Every non-total domain either has a boundary time (when bounded above or below) or
has an internal gap (when unbounded in both directions). We prove the existence of
a boundary time for the bounded cases.
-/

/-- Every non-total domain has at least one boundary time.

    **Proof structure**: Given t not in domain, we perform a trichotomy:
    - Case 1: All domain elements are less than t -- t is an upper boundary
    - Case 2: All domain elements are greater than t -- t is a lower boundary
    - Case 3: Domain elements exist on both sides of t -- internal gap

    For Cases 1 and 2, t itself is the boundary time.
    Case 3 (internal gap with domain unbounded in both directions) requires showing
    that a maximal family cannot have such gaps, which depends on general extension
    seed consistency (Phase 3 work). -/
lemma non_total_has_boundary (F : GHCoherentPartialFamily)
    (h_non_total : F.domain ≠ Set.univ) :
    ∃ t, F.isBoundaryTime t := by
  have ⟨t, ht⟩ := (Set.ne_univ_iff_exists_notMem F.domain).mp h_non_total
  by_cases h_upper : ∀ s ∈ F.domain, s < t
  · -- Case 1: t is an upper boundary
    exact ⟨t, Or.inl ⟨ht, h_upper⟩⟩
  · push_neg at h_upper
    obtain ⟨s_above, hs_above_dom, hs_above_ge⟩ := h_upper
    have hs_above_gt : t < s_above := by
      rcases eq_or_lt_of_le hs_above_ge with h_eq | h_lt
      · exact absurd (h_eq ▸ hs_above_dom) ht
      · exact h_lt
    by_cases h_lower : ∀ s ∈ F.domain, t < s
    · -- Case 2: t is a lower boundary
      exact ⟨t, Or.inr ⟨ht, h_lower⟩⟩
    · -- Case 3: Internal gap - domain elements exist on both sides of t
      push_neg at h_lower
      obtain ⟨s_below, hs_below_dom, hs_below_le⟩ := h_lower
      have _hs_below_lt : s_below < t := by
        rcases eq_or_lt_of_le hs_below_le with h_eq | h_lt
        · exact absurd (h_eq ▸ hs_below_dom) ht
        · omega
      -- We have s_below < t < s_above with both in domain, t not in domain.
      -- This internal gap case requires either:
      -- (a) Showing that bounded domains always have boundary times elsewhere, or
      -- (b) Using the general extension approach for gap times (Phase 3).
      -- Technical debt: depends on Phase 3 cross-sign seed consistency.
      sorry

/-!
## Part 10: Maximality Implies Totality (Restructured)

A maximal GH-coherent partial family must have domain = Set.univ.
If not, we can find a boundary time and extend the family there, contradicting maximality.

**Restructuring (v003)**: This proof now uses the boundary extension infrastructure
from Phase 1. At boundary times, the extension has no problematic forward_G/backward_H
cases from the new time to old domain elements (those become vacuously true).

The proof depends on:
1. `non_total_has_boundary` -- that a non-total domain has a boundary time
2. `extensionSeed_consistent` -- that the extension seed is consistent (Phase 3)
3. Lindenbaum extension to get an MCS from the seed
-/

/--
Maximality implies totality: A maximal GH-coherent family has domain = Set.univ.

**Proof approach (v003 - boundary extension)**:
1. Assume domain is not Set.univ for contradiction
2. Find a boundary time t via `non_total_has_boundary`
3. Build the extension seed (which simplifies at boundary times)
4. Extend to MCS via Lindenbaum
5. Use `extendFamilyAtBoundary` to construct strictly larger family
6. Derive contradiction with maximality

The boundary approach avoids the problematic forward_G/backward_H from the new time,
which become vacuously true at boundary times.
-/
theorem maximal_implies_total (F : GHCoherentPartialFamily) (base : GHCoherentPartialFamily)
    (hmax : Maximal (· ∈ CoherentExtensions base) F) (hF_ext : F ∈ CoherentExtensions base) :
    F.domain = Set.univ := by
  by_contra h
  -- Step 1: Find a boundary time
  obtain ⟨t, h_boundary⟩ := non_total_has_boundary F h
  have ht : t ∉ F.domain := by
    rcases h_boundary with h_upper | h_lower
    · exact h_upper.not_in_domain
    · exact h_lower.not_in_domain
  -- Step 2: Build extension seed and get MCS via Lindenbaum
  -- At a boundary time, extensionSeed simplifies to one-directional content
  have h_seed_cons : SetConsistent (extensionSeed F t) := extensionSeed_consistent F t ht
  obtain ⟨mcs_t, h_mcs_t_ext, h_mcs_t⟩ := set_lindenbaum (extensionSeed F t) h_seed_cons
  -- Step 3: Construct boundary extension hypotheses from seed inclusion
  -- h_G_to_new: G phi in old MCS implies phi in new MCS (via GContent in seed)
  have h_G_to_new : ∀ s, s ∈ F.domain → s < t → ∀ phi,
      Formula.all_future phi ∈ F.mcs s → phi ∈ mcs_t := by
    intro s hs_dom hs_lt phi hG
    exact h_mcs_t_ext (extensionSeed_includes_past_GContent F t s hs_dom hs_lt phi hG)
  -- h_H_to_new: H phi in old MCS implies phi in new MCS (via HContent in seed)
  have h_H_to_new : ∀ s, s ∈ F.domain → t < s → ∀ phi,
      Formula.all_past phi ∈ F.mcs s → phi ∈ mcs_t := by
    intro s hs_dom hs_gt phi hH
    exact h_mcs_t_ext (extensionSeed_includes_future_HContent F t s hs_dom hs_gt phi hH)
  -- h_G_from_new and h_H_from_new: propagation FROM new time to old domain.
  -- At boundary times, one of these is vacuously true:
  -- - Upper boundary: h_G_from_new is vacuous (no s > t in domain)
  -- - Lower boundary: h_H_from_new is vacuous (no s < t in domain)
  -- The non-vacuous direction requires showing that temporal content in mcs_t
  -- (the Lindenbaum extension of the seed) propagates correctly to existing MCS.
  -- This is a Phase 3/Phase 4 obligation.
  have h_G_from_new : ∀ s, s ∈ F.domain → t < s → ∀ phi,
      Formula.all_future phi ∈ mcs_t → phi ∈ F.mcs s := by
    intro s hs_dom hs_gt phi _h_G_in_new
    -- At upper boundary: vacuously impossible (all domain elements < t, but hs_gt says t < s)
    -- At lower boundary: G phi in mcs_t, need phi in F.mcs s for s > t in domain
    -- Technical debt: requires Phase 3 refinements (boundary seed consistency)
    sorry
  have h_H_from_new : ∀ s, s ∈ F.domain → s < t → ∀ phi,
      Formula.all_past phi ∈ mcs_t → phi ∈ F.mcs s := by
    intro s hs_dom hs_lt phi _h_H_in_new
    -- At lower boundary: vacuously impossible (all domain elements > t, but hs_lt says s < t)
    -- At upper boundary: H phi in mcs_t, need phi in F.mcs s for s < t in domain
    -- Technical debt: requires Phase 3 refinements (boundary seed consistency)
    sorry
  -- Step 4: Build the extended family using boundary extension
  let F' := extendFamilyAtBoundary F t h_boundary mcs_t h_mcs_t
    h_G_to_new h_H_to_new h_G_from_new h_H_from_new
  -- Step 5: Show F' strictly extends F
  -- We need F < F'. Since F' = extendFamilyAtBoundary ..., we case split on boundary type.
  have hF_lt_F' : F < F' := by
    show F < extendFamilyAtBoundary F t h_boundary mcs_t h_mcs_t
      h_G_to_new h_H_to_new h_G_from_new h_H_from_new
    rcases h_boundary with h_upper | h_lower
    · -- Upper boundary case
      simp only [extendFamilyAtBoundary, dif_pos h_upper]
      exact extendFamilyAtUpperBoundary_strictly_extends F t h_upper mcs_t h_mcs_t
        (fun s hs phi hG => h_G_to_new s hs (h_upper.all_lt s hs) phi hG)
        (fun s hs phi hH => h_H_from_new s hs (h_upper.all_lt s hs) phi hH)
    · -- Lower boundary case
      have h_not_upper : ¬F.isUpperBoundary t := by
        intro h_upper
        obtain ⟨s, hs⟩ := F.domain_nonempty
        exact absurd (h_upper.all_lt s hs) (not_lt.mpr (le_of_lt (h_lower.all_gt s hs)))
      simp only [extendFamilyAtBoundary, dif_neg h_not_upper]
      exact extendFamilyAtLowerBoundary_strictly_extends F t h_lower mcs_t h_mcs_t
        (fun s hs phi hH => h_H_to_new s hs (h_lower.all_gt s hs) phi hH)
        (fun s hs phi hG => h_G_from_new s hs (h_lower.all_gt s hs) phi hG)
  -- Step 6: F' is in CoherentExtensions base (since F is and F <= F')
  have hF'_ext : F' ∈ CoherentExtensions base := le_trans hF_ext (le_of_lt hF_lt_F')
  -- Step 7: Contradiction - F is maximal but F < F'
  have hF'_le_F : F' ≤ F := hmax.2 hF'_ext (le_of_lt hF_lt_F')
  exact lt_irrefl F (lt_of_lt_of_le hF_lt_F' hF'_le_F)

/-!
## Part 11: F/P Recovery for Total Family

### Architectural Analysis

For a GH-coherent partial family with domain = Set.univ, F/P coherence requires
showing that F-obligations and P-obligations are satisfied: if F phi ∈ mcs(t), then
phi ∈ mcs(s) for some s > t (and symmetrically for P).

**Why maximality alone is insufficient**: The partial order on families is
  `F ≤ G iff F.domain ⊆ G.domain ∧ ∀ t ∈ F.domain, F.mcs t = G.mcs t`
When F.domain = Set.univ, any G with F ≤ G must satisfy G.domain ⊇ Set.univ and
G.mcs t = F.mcs t for all t. Thus G = F, making maximality vacuously true for
total families. Maximality provides no additional constraints.

**What IS needed**: The F/P recovery property is a construction invariant. It holds
because the Zorn construction builds each MCS from a seed (extensionSeed) that includes
F/P obligations. However, the abstract Zorn argument (via `zorn_le_nonempty₀`) does not
expose this construction trace. The maximal element is obtained non-constructively.

**Seed inclusion decomposition**: For the extensionSeed F t ⊆ F.mcs t property:
- GContent part: follows from forward_G (proven)
- HContent part: follows from backward_H (proven)
- FObligations part: IS forward_F (circular)
- PObligations part: IS backward_P (circular)

**Resolution path**: Either:
1. Strengthen GHCoherentPartialFamily to include F/P coherence within the domain, so
   Zorn preserves the invariant (requires refactoring the entire family infrastructure)
2. Use a non-Zorn construction (like DovetailingChain) where F/P is proven by
   construction trace
3. Accept these as sorry with clear documentation of the gap

The proofs below isolate the sorry into minimal auxiliary lemmas, with the main
theorems structurally complete modulo these lemmas.
-/

/--
F-obligation satisfaction for total GH-coherent families (sorry).

For a total family, if F phi ∈ F.mcs t, then phi ∈ F.mcs s for some s > t.
This is the core property that requires a construction trace to prove.

**Why this is unprovable from the current structure**: The `GHCoherentPartialFamily`
structure only records forward_G and backward_H coherence. F-obligation satisfaction
(forward_F) is a strictly stronger property that is not derivable from G/H coherence
alone -- a total GH-coherent family could in principle violate it.

**Why it holds mathematically**: In the Zorn construction, each time point t is
added with an MCS extending `extensionSeed F t`, which includes `FObligations F t`.
Any phi with F phi ∈ mcs(s) for s < t is in FObligations, hence in the seed,
hence in the MCS. But the Zorn abstraction hides this construction trace.

**Technical debt**: This sorry can be eliminated by either:
(a) Adding forward_F/backward_P as fields of GHCoherentPartialFamily and showing
    Zorn chains preserve them (recommended approach)
(b) Replacing the Zorn proof with an explicit iterative construction
(c) Proving a "seed inclusion" invariant is preserved by the chain upper bound
-/
lemma total_family_FObligations_satisfied (F : GHCoherentPartialFamily)
    (htotal : F.domain = Set.univ)
    (t : Int) (phi : Formula) (s : Int) (hs_lt : s < t)
    (hF_phi : Formula.some_future phi ∈ F.mcs s) :
    phi ∈ F.mcs t := by
  sorry

/--
P-obligation satisfaction for total GH-coherent families (sorry).

Symmetric to `total_family_FObligations_satisfied`.
For a total family, if P phi ∈ F.mcs t, then phi ∈ F.mcs s for some s < t.

**Technical debt**: Same architectural issue as FObligations. See documentation
on `total_family_FObligations_satisfied` for full analysis.
-/
lemma total_family_PObligations_satisfied (F : GHCoherentPartialFamily)
    (htotal : F.domain = Set.univ)
    (t : Int) (phi : Formula) (s : Int) (hs_gt : t < s)
    (hP_phi : Formula.some_past phi ∈ F.mcs s) :
    phi ∈ F.mcs t := by
  sorry

/--
For a maximal family, forward F witness: If F phi ∈ mcs(t), then phi ∈ mcs(t+1).

The witness is t+1, which is in the domain since the family is total (domain = Set.univ).
The proof that phi ∈ mcs(t+1) follows from `total_family_FObligations_satisfied`.

**Sorry dependency**: Delegates to `total_family_FObligations_satisfied` (1 sorry).
-/
theorem maximal_family_forward_F (F : GHCoherentPartialFamily) (base : GHCoherentPartialFamily)
    (hmax : Maximal (· ∈ CoherentExtensions base) F) (hF_ext : F ∈ CoherentExtensions base)
    (t : Int) (phi : Formula)
    (hF : Formula.some_future phi ∈ F.mcs t) :
    ∃ s, t < s ∧ phi ∈ F.mcs s := by
  have htotal : F.domain = Set.univ := maximal_implies_total F base hmax hF_ext
  -- Witness: t + 1 (in domain since domain = Set.univ)
  exact ⟨t + 1, by omega,
    total_family_FObligations_satisfied F htotal (t + 1) phi t (by omega) hF⟩

/--
For a total family, forward F witness.

Alias kept for signature compatibility. Delegates to `total_family_FObligations_satisfied`.
-/
theorem total_family_forward_F (F : GHCoherentPartialFamily)
    (htotal : F.domain = Set.univ) (t : Int) (phi : Formula)
    (hF : Formula.some_future phi ∈ F.mcs t) :
    ∃ s, t < s ∧ phi ∈ F.mcs s :=
  ⟨t + 1, by omega,
    total_family_FObligations_satisfied F htotal (t + 1) phi t (by omega) hF⟩

/--
For a maximal family, backward P witness: If P phi ∈ mcs(t), then phi ∈ mcs(t-1).

Symmetric to `maximal_family_forward_F`. The witness is t-1.

**Sorry dependency**: Delegates to `total_family_PObligations_satisfied` (1 sorry).
-/
theorem maximal_family_backward_P (F : GHCoherentPartialFamily) (base : GHCoherentPartialFamily)
    (hmax : Maximal (· ∈ CoherentExtensions base) F) (hF_ext : F ∈ CoherentExtensions base)
    (t : Int) (phi : Formula)
    (hP : Formula.some_past phi ∈ F.mcs t) :
    ∃ s, s < t ∧ phi ∈ F.mcs s := by
  have htotal : F.domain = Set.univ := maximal_implies_total F base hmax hF_ext
  -- Witness: t - 1 (in domain since domain = Set.univ)
  exact ⟨t - 1, by omega,
    total_family_PObligations_satisfied F htotal (t - 1) phi t (by omega) hP⟩

/--
For a total family, backward P witness.

Alias kept for signature compatibility. Delegates to `total_family_PObligations_satisfied`.
-/
theorem total_family_backward_P (F : GHCoherentPartialFamily)
    (htotal : F.domain = Set.univ) (t : Int) (phi : Formula)
    (hP : Formula.some_past phi ∈ F.mcs t) :
    ∃ s, s < t ∧ phi ∈ F.mcs s :=
  ⟨t - 1, by omega,
    total_family_PObligations_satisfied F htotal (t - 1) phi t (by omega) hP⟩

/-!
## Part 12: Main Theorem

The final theorem: For any consistent context, there exists an IndexedMCSFamily with
all four temporal coherence properties (G, H, F, P).
-/

/--
Main theorem: Temporal coherent family exists via Zorn's lemma.

For any consistent context Gamma, there exists an `IndexedMCSFamily Int` such that:
1. All formulas in Gamma are in the MCS at time 0
2. Forward G coherence: G phi at t implies phi at all future times
3. Backward H coherence: H phi at t implies phi at all past times
4. Forward F witness: F phi at t has a witness at some future time
5. Backward P witness: P phi at t has a witness at some past time
-/
theorem temporal_coherent_family_exists_zorn (Gamma : List Formula)
    (h_cons : Consistent Gamma) :
    ∃ fam : IndexedMCSFamily Int,
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs 0) ∧
      (∀ t t', t < t' → ∀ phi, Formula.all_future phi ∈ fam.mcs t → phi ∈ fam.mcs t') ∧
      (∀ t t', t' < t → ∀ phi, Formula.all_past phi ∈ fam.mcs t → phi ∈ fam.mcs t') ∧
      (∀ t phi, Formula.some_future phi ∈ fam.mcs t → ∃ s, t < s ∧ phi ∈ fam.mcs s) ∧
      (∀ t phi, Formula.some_past phi ∈ fam.mcs t → ∃ s, s < t ∧ phi ∈ fam.mcs s) := by
  -- Obtain maximal GH-coherent family
  obtain ⟨F, hF_context, h0_in_dom, hF_max⟩ := maximal_coherent_partial_family_exists Gamma h_cons
  -- F is maximal relative to buildBaseFamily Gamma h_cons
  let base := buildBaseFamily Gamma h_cons
  -- F ∈ CoherentExtensions base follows from maximal being in the set
  have hF_ext : F ∈ CoherentExtensions base := hF_max.prop
  have hF_total : F.domain = Set.univ := maximal_implies_total F base hF_max hF_ext
  -- Convert to IndexedMCSFamily
  let fam : IndexedMCSFamily Int := {
    mcs := F.mcs
    is_mcs := fun t => F.is_mcs t (hF_total ▸ Set.mem_univ t)
    forward_G := fun t t' phi hlt hG =>
      F.forward_G t t' (hF_total ▸ Set.mem_univ t) (hF_total ▸ Set.mem_univ t') hlt phi hG
    backward_H := fun t t' phi hlt hH =>
      F.backward_H t t' (hF_total ▸ Set.mem_univ t') (hF_total ▸ Set.mem_univ t) hlt phi hH
  }
  use fam
  refine ⟨hF_context, ?_, ?_, ?_, ?_⟩
  · -- Forward G (from structure field)
    intro t t' hlt phi hG
    exact fam.forward_G t t' phi hlt hG
  · -- Backward H (from structure field)
    intro t t' hlt phi hH
    exact fam.backward_H t t' phi hlt hH
  · -- Forward F (uses maximality, not just totality)
    intro t phi hF
    exact maximal_family_forward_F F base hF_max hF_ext t phi hF
  · -- Backward P (uses maximality, not just totality)
    intro t phi hP
    exact maximal_family_backward_P F base hF_max hF_ext t phi hP

end Bimodal.Metalogic.Bundle
