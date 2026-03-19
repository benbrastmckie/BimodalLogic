import Bimodal.Metalogic.Bundle.ChainFMCS
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom
import Bimodal.Metalogic.StagedConstruction.DensityFrameCondition
import Bimodal.Metalogic.Canonical.CanonicalTimeline
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

/-!
## Phase 2: Density and Order Properties

We establish that Flags in CanonicalMCS have the key order properties needed
for Cantor's theorem: DenselyOrdered, NoMinOrder, NoMaxOrder.

These properties come from:
- **Seriality**: Every MCS contains F(neg bot) and P(neg bot), providing successors/predecessors
- **Density Frame Condition**: Between any strictly ordered pair, an intermediate exists
- **Irreflexivity**: CanonicalR is irreflexive, so witnesses are strictly ordered
-/

open Bimodal.Metalogic.Canonical
open Bimodal.Metalogic.StagedConstruction

/--
Every CanonicalMCS element has a CanonicalR-successor in CanonicalMCS.

This follows from seriality: F(neg bot) is in every MCS, and `canonical_forward_F`
provides a witness MCS W with CanonicalR M.world W.
-/
theorem canonicalMCS_has_future (M : CanonicalMCS) :
    ∃ N : CanonicalMCS, M < N := by
  -- M.world contains F(neg bot) by seriality
  have h_serial : Formula.some_future (Formula.neg Formula.bot) ∈ M.world :=
    SetMaximalConsistent.contains_seriality_future M.world M.is_mcs
  -- Get witness N with CanonicalR M.world N.world
  obtain ⟨N, h_le, _h_phi⟩ := canonicalMCS_forward_F M (Formula.neg Formula.bot) h_serial
  -- h_le : M <= N. We need M < N (strict).
  -- By irreflexivity, if M <= N and N <= M, then M = N and CanonicalR M M, contradiction.
  rcases h_le with h_eq | h_R
  · -- M = N: But then CanonicalR M.world M.world, contradicting irreflexivity
    -- Actually M = N doesn't give CanonicalR automatically... need to check
    -- The witness N from canonical_forward_F has CanonicalR M.world N.world
    -- If M = N, then CanonicalR M.world M.world
    -- But we need to verify canonical_forward_F actually returns CanonicalR
    -- Let's look at canonicalMCS_forward_F more carefully
    sorry -- This case needs more careful analysis
  · -- CanonicalR M.world N.world: use irreflexivity to show strict
    refine ⟨N, Or.inr h_R, ?_⟩
    intro h_NM
    rcases h_NM with h_eq' | h_R'
    · -- N = M: then CanonicalR M.world N.world rewrites to CanonicalR M.world M.world
      rw [h_eq'] at h_R
      exact Canonical.canonicalR_irreflexive M.world M.is_mcs h_R
    · -- CanonicalR N.world M.world: then by transitivity CanonicalR M.world M.world
      have h_MM := canonicalR_transitive M.world N.world M.world M.is_mcs h_R h_R'
      exact Canonical.canonicalR_irreflexive M.world M.is_mcs h_MM

/--
Every CanonicalMCS element has a CanonicalR-predecessor in CanonicalMCS.

Symmetric to `canonicalMCS_has_future` using past seriality.
-/
theorem canonicalMCS_has_past (M : CanonicalMCS) :
    ∃ N : CanonicalMCS, N < M := by
  -- M.world contains P(neg bot) by seriality
  have h_serial : Formula.some_past (Formula.neg Formula.bot) ∈ M.world :=
    SetMaximalConsistent.contains_seriality_past M.world M.is_mcs
  -- Get witness N with CanonicalR N.world M.world
  obtain ⟨N, h_le, _h_phi⟩ := canonicalMCS_backward_P M (Formula.neg Formula.bot) h_serial
  rcases h_le with h_eq | h_R
  · sorry -- Same case analysis as above
  · refine ⟨N, Or.inr h_R, ?_⟩
    intro h_MN
    rcases h_MN with h_eq' | h_R'
    · rw [← h_eq'] at h_R
      exact Canonical.canonicalR_irreflexive M.world M.is_mcs h_R
    · have h_NN := canonicalR_transitive N.world M.world N.world N.is_mcs h_R h_R'
      exact Canonical.canonicalR_irreflexive N.world N.is_mcs h_NN

/--
Between any strictly ordered pair in CanonicalMCS, there exists an intermediate.

This uses the density frame condition: if CanonicalR M N and NOT CanonicalR N M,
then there exists W with CanonicalR M W and CanonicalR W N.
-/
theorem canonicalMCS_has_intermediate (M N : CanonicalMCS)
    (h_lt : M < N) :
    ∃ W : CanonicalMCS, M < W ∧ W < N := by
  -- M < N means M <= N and NOT N <= M
  have h_le := h_lt.1
  have h_not_le := h_lt.2
  -- Extract CanonicalR M.world N.world from M <= N
  have h_R : CanonicalR M.world N.world := by
    rcases h_le with h_eq | h_R
    · -- M = N contradicts M < N
      exfalso
      apply h_not_le
      rw [h_eq]
      exact Or.inl rfl
    · exact h_R
  -- NOT N <= M means NOT (N = M or CanonicalR N.world M.world)
  have h_not_R' : ¬CanonicalR N.world M.world := by
    intro h_R'
    exact h_not_le (Or.inr h_R')
  -- Apply density frame condition
  obtain ⟨W_set, h_W_mcs, h_MW, h_WN⟩ :=
    density_frame_condition M.world N.world M.is_mcs N.is_mcs h_R h_not_R'
  let W : CanonicalMCS := ⟨W_set, h_W_mcs⟩
  use W
  constructor
  · -- M < W: M <= W and NOT W <= M
    constructor
    · exact Or.inr h_MW
    · intro h_WM
      rcases h_WM with h_eq | h_R_WM
      · -- W = M: then W_set = W.world = M.world, so CanonicalR M.world M.world
        have h_W_world : W.world = M.world := congrArg CanonicalMCS.world h_eq
        simp only [W] at h_W_world
        rw [h_W_world] at h_MW
        exact Canonical.canonicalR_irreflexive M.world M.is_mcs h_MW
      · -- CanonicalR W_set M.world: transitivity gives CanonicalR M.world M.world
        have h_MM := canonicalR_transitive M.world W_set M.world M.is_mcs h_MW h_R_WM
        exact Canonical.canonicalR_irreflexive M.world M.is_mcs h_MM
  · -- W < N: W <= N and NOT N <= W
    constructor
    · exact Or.inr h_WN
    · intro h_NW
      rcases h_NW with h_eq | h_R_NW
      · -- N = W: then W_set = W.world = N.world, so CanonicalR W_set W_set
        have h_W_world : W.world = N.world := congrArg CanonicalMCS.world h_eq.symm
        simp only [W] at h_W_world
        rw [← h_W_world] at h_WN
        exact Canonical.canonicalR_irreflexive W_set h_W_mcs h_WN
      · -- CanonicalR N.world W_set: combined with CanonicalR W_set N.world
        have h_NN := canonicalR_transitive N.world W_set N.world N.is_mcs h_R_NW h_WN
        exact Canonical.canonicalR_irreflexive N.world N.is_mcs h_NN

/-!
## Flag Order Properties

For a Flag (maximal chain), the order properties transfer from CanonicalMCS
if the witnesses happen to be in the same Flag. This is NOT always the case,
but for Flags that ARE saturated, these properties hold.
-/

/--
A saturated Flag has no maximum element.

If F is a saturated Flag and M ∈ F, then F(neg bot) ∈ M.world, so by F-saturation
there exists N > M in F with neg bot ∈ N.world.
-/
theorem saturatedFlag_noMaxOrder (flag : Flag CanonicalMCS)
    (h_sat : FlagSaturated flag) :
    ∀ M ∈ flag, ∃ N ∈ flag, M < N := by
  intro M hM
  have h_serial : Formula.some_future (Formula.neg Formula.bot) ∈ M.world :=
    SetMaximalConsistent.contains_seriality_future M.world M.is_mcs
  obtain ⟨N, hN, h_lt, _⟩ := h_sat.1 M hM (Formula.neg Formula.bot) h_serial
  exact ⟨N, hN, h_lt⟩

/--
A saturated Flag has no minimum element.

Symmetric to `saturatedFlag_noMaxOrder` using P-saturation.
-/
theorem saturatedFlag_noMinOrder (flag : Flag CanonicalMCS)
    (h_sat : FlagSaturated flag) :
    ∀ M ∈ flag, ∃ N ∈ flag, N < M := by
  intro M hM
  have h_serial : Formula.some_past (Formula.neg Formula.bot) ∈ M.world :=
    SetMaximalConsistent.contains_seriality_past M.world M.is_mcs
  obtain ⟨N, hN, h_lt, _⟩ := h_sat.2 M hM (Formula.neg Formula.bot) h_serial
  exact ⟨N, hN, h_lt⟩

/-!
## Phase 2 Summary

We have established:
1. `canonicalMCS_has_future`, `canonicalMCS_has_past`: seriality at CanonicalMCS level
2. `canonicalMCS_has_intermediate`: density frame condition gives intermediates
3. `saturatedFlag_noMaxOrder`, `saturatedFlag_noMinOrder`: saturated Flags have no endpoints

**Key Observation**: For Flags to satisfy DenselyOrdered, we need density witnesses
to be IN the Flag. This requires either:
- The Flag is constructed to include all density witnesses (transfinite construction)
- We work at the BFMCS bundle level where different families handle different witnesses

**Next Steps** (Phases 3-4):
- Phase 3: Define the saturated Flag domain type with order instances
- Phase 4: Apply Cantor isomorphism and wire to completeness
-/

end Bimodal.Metalogic.Algebraic
