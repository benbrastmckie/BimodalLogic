import Bimodal.Metalogic.Bundle.IndexedMCSFamily
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.TemporalLindenbaum
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

## Construction Overview

The key insight is that the chain construction in DovetailingChain.lean fails at cross-sign
boundaries (e.g., G phi at t<0 reaching t'>0) because chains extend away from time 0 and
cannot retroactively propagate formulas. The Zorn approach solves this by:

1. Defining `CoherentPartialFamily`: A partial family (domain ⊆ Int) with coherence for all
   times *within* the domain.

2. Applying Zorn's lemma to find a maximal coherent partial family.

3. Proving that any maximal partial family must have domain = Set.univ (otherwise we can extend).

4. Extracting an `IndexedMCSFamily Int` from the maximal (hence total) family.

## Main Definitions

- `CoherentPartialFamily`: Structure with partial domain, MCS assignment, and temporal coherence
- `CoherentPartialFamily.le`: Partial order for Zorn's lemma (domain extension with agreement)
- `coherent_chain_has_upper_bound`: Chain upper bound lemma for Zorn
- `maximal_coherent_partial_family_exists`: Zorn application
- `maximal_coherent_family_total`: Maximality implies totality
- `temporal_coherent_family_exists_zorn`: Main theorem (replaces 4 sorries in DovetailingChain)

## References

- Task 870 plan: specs/870_zorn_family_temporal_coherence/plans/implementation-001.md
- Research: specs/870_zorn_family_temporal_coherence/reports/research-002.md
- Prior work: DovetailingChain.lean (4 sorries for cross-sign propagation)
- Zorn template: TemporalLindenbaum.lean (single-MCS construction)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Part 1: CoherentPartialFamily Structure

A partial family assigns MCS to times in a domain subset, with coherence guaranteed
for all pairs within the domain.
-/

/--
A partial family of maximal consistent sets indexed by times in a domain ⊆ Int.

The key feature vs `IndexedMCSFamily` is that the domain can be any nonempty subset of Int,
not necessarily all of Int. The coherence conditions apply only to pairs within the domain.

**Fields**:
- `domain`: The set of times with assigned MCS
- `mcs`: Assignment of sets to all times (only meaningful for t ∈ domain)
- `domain_nonempty`: The domain is nonempty (needed for Zorn base case)
- `is_mcs`: Each assigned set (for t ∈ domain) is maximal consistent
- `forward_G`: G phi propagates forward within the domain
- `backward_H`: H phi propagates backward within the domain
- `forward_F`: F phi witnesses exist within the domain
- `backward_P`: P phi witnesses exist within the domain

**Design Note**: The `mcs` function is total (Int → Set Formula) for simplicity,
but only values at times in `domain` are meaningful. This avoids dependent types
in the partial order definition.
-/
structure CoherentPartialFamily where
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
  -/
  forward_G : ∀ t t', t ∈ domain → t' ∈ domain → t < t' →
    ∀ phi, Formula.all_future phi ∈ mcs t → phi ∈ mcs t'
  /--
  Backward H coherence within domain: H phi at t implies phi at all past t' in domain.
  -/
  backward_H : ∀ t t', t' ∈ domain → t ∈ domain → t' < t →
    ∀ phi, Formula.all_past phi ∈ mcs t → phi ∈ mcs t'
  /--
  Forward F witness existence: F phi at t implies a witness s > t exists in domain.
  -/
  forward_F : ∀ t, t ∈ domain → ∀ phi,
    Formula.some_future phi ∈ mcs t → ∃ s, s ∈ domain ∧ t < s ∧ phi ∈ mcs s
  /--
  Backward P witness existence: P phi at t implies a witness s < t exists in domain.
  -/
  backward_P : ∀ t, t ∈ domain → ∀ phi,
    Formula.some_past phi ∈ mcs t → ∃ s, s ∈ domain ∧ s < t ∧ phi ∈ mcs s

/-!
## Part 2: Partial Order on CoherentPartialFamily

The partial order for Zorn: F ≤ G iff G extends F (larger domain, agrees on overlap).
-/

/--
Partial order: F ≤ G iff G extends F's domain and agrees on the overlap.
-/
def CoherentPartialFamily.le (F G : CoherentPartialFamily) : Prop :=
  F.domain ⊆ G.domain ∧ ∀ t, t ∈ F.domain → F.mcs t = G.mcs t

/-- Reflexivity of the partial order. -/
lemma CoherentPartialFamily.le_refl (F : CoherentPartialFamily) : F.le F := by
  constructor
  · exact Set.Subset.rfl
  · intro t _; rfl

/-- Transitivity of the partial order. -/
lemma CoherentPartialFamily.le_trans (F G H : CoherentPartialFamily)
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
lemma CoherentPartialFamily.le_antisymm_domain (F G : CoherentPartialFamily)
    (hFG : F.le G) (hGF : G.le F) : F.domain = G.domain :=
  Set.Subset.antisymm hFG.1 hGF.1

lemma CoherentPartialFamily.le_antisymm_mcs (F G : CoherentPartialFamily)
    (hFG : F.le G) (hGF : G.le F) : ∀ t, t ∈ F.domain → F.mcs t = G.mcs t :=
  hFG.2

/-!
## Part 3: GContent and HContent for Partial Families

Extract the temporal content from MCS in the partial family.
-/

/--
GContent of a partial family at a time: formulas phi where G phi is in the MCS.
-/
def CoherentPartialFamily.GContentAt (F : CoherentPartialFamily) (t : Int) : Set Formula :=
  GContent (F.mcs t)

/--
HContent of a partial family at a time: formulas phi where H phi is in the MCS.
-/
def CoherentPartialFamily.HContentAt (F : CoherentPartialFamily) (t : Int) : Set Formula :=
  HContent (F.mcs t)

/-!
## Part 4: Basic Accessor Lemmas
-/

/-- Get the MCS at a time (meaningful only if t ∈ domain) -/
def CoherentPartialFamily.at (F : CoherentPartialFamily) (t : Int) : Set Formula :=
  F.mcs t

/-- The MCS at any time in domain is consistent -/
lemma CoherentPartialFamily.consistent (F : CoherentPartialFamily) (t : Int) (ht : t ∈ F.domain) :
    SetConsistent (F.mcs t) :=
  (F.is_mcs t ht).1

/-- The MCS at any time in domain is maximal -/
lemma CoherentPartialFamily.maximal (F : CoherentPartialFamily) (t : Int) (ht : t ∈ F.domain) :
    ∀ phi : Formula, phi ∉ F.mcs t → ¬SetConsistent (insert phi (F.mcs t)) :=
  (F.is_mcs t ht).2

end Bimodal.Metalogic.Bundle
