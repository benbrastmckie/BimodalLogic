import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Mathlib.Order.Zorn
import Mathlib.Order.Preorder.Chain

/-!
# Saturated Maximal Chains for Dense Algebraic Completeness

This module defines the "saturated chain" approach to dense algebraic completeness.
Instead of proving forward_F/backward_P termination in a pre-built timeline (which has
a recursive depth problem when density index j > 0), we use Zorn's lemma to construct
a maximal chain that contains F/P witnesses by construction.

## Overview

A chain in CanonicalMCS is **F-saturated** if for every element w with F(phi) in w.world,
there exists a successor v > w in the chain with phi in v.world. Similarly for P-saturation.

The key insight is that:
1. The empty chain is trivially saturated
2. If every chain of saturated chains has a saturated upper bound (the union),
   then Zorn gives a maximal saturated chain
3. The maximal saturated chain containing any root MCS forms a suitable domain

## Key Definitions

- `ChainFSaturated`: A chain C is F-saturated if F-witnesses exist within C
- `ChainPSaturated`: A chain C is P-saturated if P-witnesses exist within C
- `ChainSaturated`: A chain is saturated if it is both F and P saturated
- `SaturatedFlag`: A Flag (maximal chain) that is saturated

## References

- Task 988 research synthesis (13_dense-completeness-synthesis.md)
- ChainFMCS.lean: chainFMCS_forward_F_in_CanonicalMCS (witnesses exist in CanonicalMCS)
- Mathlib `Order.Zorn`: Zorn's lemma for partial orders
- Mathlib `Flag`: Maximal chains in preorders
-/

namespace Bimodal.Metalogic.Algebraic

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.ProofSystem

/-!
## Chain Saturation Predicates

We define saturation predicates for chains (sets) of CanonicalMCS elements.
These capture when F/P witnesses are contained within the chain itself.
-/

/--
A chain C of CanonicalMCS elements is **F-saturated** if:
for every w in C with F(phi) in w.world, there exists v > w in C with phi in v.world.

This ensures forward-F witnesses are present in the chain, not just in CanonicalMCS.
-/
def ChainFSaturated (C : Set CanonicalMCS) : Prop :=
  ∀ w ∈ C, ∀ phi : Formula,
    Formula.some_future phi ∈ w.world →
    ∃ v ∈ C, w < v ∧ phi ∈ v.world

/--
A chain C of CanonicalMCS elements is **P-saturated** if:
for every w in C with P(phi) in w.world, there exists v < w in C with phi in v.world.

This ensures backward-P witnesses are present in the chain, not just in CanonicalMCS.
-/
def ChainPSaturated (C : Set CanonicalMCS) : Prop :=
  ∀ w ∈ C, ∀ phi : Formula,
    Formula.some_past phi ∈ w.world →
    ∃ v ∈ C, v < w ∧ phi ∈ v.world

/--
A chain C is **saturated** if it is both F-saturated and P-saturated.
-/
def ChainSaturated (C : Set CanonicalMCS) : Prop :=
  ChainFSaturated C ∧ ChainPSaturated C

/-!
## Enriched Chains: Adding Witnesses to a Chain

The key construction for Zorn's lemma: given a chain C with an F-obligation at w,
we can "enrich" C by adding the Lindenbaum witness for that obligation.

The witness from `canonical_forward_F` satisfies:
- It has CanonicalR w.world witness.world, so w < witness in the preorder
- It contains phi

If C is a chain (totally ordered), we need the witness to be comparable with all
elements of C for the enriched set to remain a chain.
-/

/--
Adding a single F-witness to a chain that is already total on the existing elements.

Given:
- C is a chain (pairwise comparable)
- w ∈ C with F(phi) ∈ w.world
- witness is the Lindenbaum MCS with CanonicalR w.world witness.world and phi ∈ witness.world

The enriched chain C' = C ∪ {witness} is a chain if witness is comparable with all of C.
This holds when all elements of C are comparable to w (since witness > w and C is a chain).

For maximal chains (Flags), all elements are already comparable.
-/
theorem chain_add_witness_preserves_chain (C : Set CanonicalMCS)
    (h_chain : IsChain (· ≤ ·) C)
    (w : CanonicalMCS) (hw : w ∈ C)
    (witness : CanonicalMCS)
    (h_w_lt_witness : w < witness)
    (h_witness_comparable : ∀ v ∈ C, v ≤ witness ∨ witness ≤ v) :
    IsChain (· ≤ ·) (insert witness C) := by
  intro a ha b hb hab
  simp only [Set.mem_insert_iff] at ha hb
  rcases ha with rfl | ha <;> rcases hb with rfl | hb
  · -- a = witness, b = witness: trivial
    exact absurd rfl hab
  · -- a = witness, b ∈ C
    exact (h_witness_comparable b hb).symm
  · -- a ∈ C, b = witness
    exact h_witness_comparable a ha
  · -- a ∈ C, b ∈ C
    exact h_chain ha hb hab

/-!
## Saturation is Preserved by Directed Unions

For Zorn's lemma, we need to show that a chain (in the subset order) of saturated
chains has an upper bound. The natural upper bound is the union.
-/

/--
F-saturation is preserved by unions of chains (in the subset order) of F-saturated sets.

If every set S in a chain (ordered by ⊆) is F-saturated, then ⋃S is F-saturated.
The key: if w ∈ ⋃S has F(phi) ∈ w.world, then w ∈ some S in the chain,
so the witness v ∈ S ⊆ ⋃S.
-/
theorem ChainFSaturated_sUnion (Cs : Set (Set CanonicalMCS))
    (h_chain : IsChain (· ⊆ ·) Cs)
    (h_sat : ∀ C ∈ Cs, ChainFSaturated C) :
    ChainFSaturated (⋃₀ Cs) := by
  intro w hw phi h_F
  simp only [Set.mem_sUnion] at hw
  obtain ⟨C, hC_mem, hw_C⟩ := hw
  -- w ∈ C, C is F-saturated
  obtain ⟨v, hv_C, h_lt, h_phi⟩ := h_sat C hC_mem w hw_C phi h_F
  exact ⟨v, Set.mem_sUnion.mpr ⟨C, hC_mem, hv_C⟩, h_lt, h_phi⟩

/--
P-saturation is preserved by unions of chains (in the subset order) of P-saturated sets.
-/
theorem ChainPSaturated_sUnion (Cs : Set (Set CanonicalMCS))
    (h_chain : IsChain (· ⊆ ·) Cs)
    (h_sat : ∀ C ∈ Cs, ChainPSaturated C) :
    ChainPSaturated (⋃₀ Cs) := by
  intro w hw phi h_P
  simp only [Set.mem_sUnion] at hw
  obtain ⟨C, hC_mem, hw_C⟩ := hw
  obtain ⟨v, hv_C, h_lt, h_phi⟩ := h_sat C hC_mem w hw_C phi h_P
  exact ⟨v, Set.mem_sUnion.mpr ⟨C, hC_mem, hv_C⟩, h_lt, h_phi⟩

/--
Saturation is preserved by unions of chains of saturated sets.
-/
theorem ChainSaturated_sUnion (Cs : Set (Set CanonicalMCS))
    (h_chain : IsChain (· ⊆ ·) Cs)
    (h_sat : ∀ C ∈ Cs, ChainSaturated C) :
    ChainSaturated (⋃₀ Cs) := by
  constructor
  · exact ChainFSaturated_sUnion Cs h_chain (fun C hC => (h_sat C hC).1)
  · exact ChainPSaturated_sUnion Cs h_chain (fun C hC => (h_sat C hC).2)

/-!
## Singleton Chain Saturation

A singleton chain {M} is saturated iff M has no F or P obligations.
In general, MCSs do have F/P obligations (via seriality), so singleton chains
are typically NOT saturated. However, the empty chain IS trivially saturated.
-/

/--
The empty chain is trivially saturated.
-/
theorem ChainSaturated_empty : ChainSaturated ∅ := by
  constructor
  · intro w hw; exact absurd hw (Set.not_mem_empty w)
  · intro w hw; exact absurd hw (Set.not_mem_empty w)

/-!
## Enrichment: Building Saturated Chains Incrementally

The core idea: start with a chain C containing the root MCS M₀.
For each F/P obligation in C that lacks a witness in C, add the witness.
This process can be iterated transfinitely to obtain a saturated chain.

However, we take a simpler approach using Zorn: we consider ALL saturated chains
containing the root M₀ and use Zorn to get a maximal one. The maximal chain
automatically includes all necessary witnesses (or it wouldn't be maximal).
-/

/--
The type of chains containing a given root MCS.
-/
def ChainsContaining (M₀ : CanonicalMCS) : Set (Set CanonicalMCS) :=
  { C | M₀ ∈ C ∧ IsChain (· ≤ ·) C }

/--
The type of saturated chains containing a given root MCS.
-/
def SaturatedChainsContaining (M₀ : CanonicalMCS) : Set (Set CanonicalMCS) :=
  { C | M₀ ∈ C ∧ IsChain (· ≤ ·) C ∧ ChainSaturated C }

/-!
## The Key Obstacle: Witnesses May Not Form Chains

The main technical obstacle is that the witness from `canonical_forward_F` is
constructed via Lindenbaum's lemma and is NOT guaranteed to be comparable with
all elements of an existing chain. This means adding witnesses may break the
chain property.

**Resolution**: Instead of adding witnesses one at a time, we use a different
characterization. A maximal Flag (from Mathlib) containing the root M₀ may NOT
be saturated. However, we can characterize saturation differently:

A chain C is saturated iff it contains enough witnesses. For maximal chains (Flags),
this can be analyzed via the structure of CanonicalMCS.

**Alternative approach**: Work with the BFMCS bundle level where witnesses from
different chains are allowed. This is noted in ChainFMCS.lean: "The witness s
may NOT be in the same flag/chain -- this is expected and handled at the BFMCS
bundle level."
-/

/--
A Flag (maximal chain in CanonicalMCS) is saturated if the chain it represents
is saturated under our definition.
-/
def FlagSaturated (flag : Flag CanonicalMCS) : Prop :=
  ChainSaturated (flag : Set CanonicalMCS)

/--
Every element of CanonicalMCS is in some Flag.

This is from Mathlib's `Flag.exists_mem`, which applies Zorn's lemma.
-/
theorem exists_flag_containing (M : CanonicalMCS) :
    ∃ flag : Flag CanonicalMCS, M ∈ flag :=
  Flag.exists_mem M

/-!
## Saturation Analysis for Flags

For a Flag (maximal chain) containing M₀, saturation requires that F/P witnesses
exist within the same flag. Since Lindenbaum witnesses may not be in the flag,
we need a different approach.

**Key insight**: The `chainFMCS_forward_F_in_CanonicalMCS` theorem shows that
F-witnesses exist in CanonicalMCS. For them to be in the same Flag, the witness
must be ≤-comparable with ALL flag elements. Since Flags are maximal chains,
a witness w is in the flag iff it's comparable with all flag elements.

**When is a Lindenbaum witness comparable?**
The witness W for F(phi) at M satisfies `CanonicalR M.world W`, so M < {W}.
For W to be in the same flag as M, we need W comparable with all other flag elements.

This is NOT automatically true. Different F-obligations may require witnesses
that are mutually incomparable. This is why the BFMCS bundle approach (multiple
families) is necessary for full completeness.

For Phase 1, we establish the saturation predicate and note this limitation.
Phases 2-4 will address how to work within this constraint.
-/

/--
Within a Flag, F-witnesses exist in CanonicalMCS (but may not be in the Flag).

This wraps `chainFMCS_forward_F_in_CanonicalMCS` in our terminology.
-/
theorem flag_forward_F_witness_exists (flag : Flag CanonicalMCS)
    (w : CanonicalMCS) (hw : w ∈ flag) (phi : Formula)
    (h_F : Formula.some_future phi ∈ w.world) :
    ∃ s : CanonicalMCS, w ≤ s ∧ phi ∈ s.world := by
  -- Use canonicalMCS_forward_F which gives a witness in CanonicalMCS
  -- Note: canonicalMCS_mcs w = w.world by definition
  obtain ⟨s, h_le, h_phi⟩ := canonicalMCS_forward_F w phi h_F
  exact ⟨s, h_le, h_phi⟩

/--
Within a Flag, P-witnesses exist in CanonicalMCS (but may not be in the Flag).

This wraps `chainFMCS_backward_P_in_CanonicalMCS` in our terminology.
-/
theorem flag_backward_P_witness_exists (flag : Flag CanonicalMCS)
    (w : CanonicalMCS) (hw : w ∈ flag) (phi : Formula)
    (h_P : Formula.some_past phi ∈ w.world) :
    ∃ s : CanonicalMCS, s ≤ w ∧ phi ∈ s.world := by
  -- Use canonicalMCS_backward_P which gives a witness in CanonicalMCS
  -- Note: canonicalMCS_mcs w = w.world by definition
  obtain ⟨s, h_le, h_phi⟩ := canonicalMCS_backward_P w phi h_P
  exact ⟨s, h_le, h_phi⟩

/-!
## Phase 1 Summary

We have established:
1. `ChainFSaturated`, `ChainPSaturated`, `ChainSaturated` predicates
2. Saturation is preserved by unions: `ChainSaturated_sUnion`
3. Empty chain is saturated: `ChainSaturated_empty`
4. F/P witnesses exist in CanonicalMCS: `flag_forward_F_witness_exists`, etc.

The key insight is that for a Flag to be saturated, the Lindenbaum witnesses
must happen to lie within the same Flag. This is NOT guaranteed in general.

**Path forward** (Phases 2-4):
- Phase 2: Prove density properties (DenselyOrdered, NoMinOrder, NoMaxOrder) for
  Flags using the DN axiom and seriality
- Phase 3: Apply Cantor isomorphism to suitable Flags, build BFMCS
- Phase 4: Wire to completeness, handling the witness-in-flag issue via BFMCS bundle

**Alternative**: If saturation cannot be guaranteed within a single Flag, the
multi-family BFMCS approach handles this by having separate families for each
Diamond witness (as noted in ChainFMCS.lean comments).
-/

end Bimodal.Metalogic.Algebraic
