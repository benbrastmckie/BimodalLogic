import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Canonical Chain: Z-Indexed Chain Through CanonicalMCS

This module constructs a Z-indexed chain of maximal consistent sets (MCSes) through
CanonicalMCS, with CanonicalR ordering between consecutive elements. This is the
foundational data structure for the antisymmetrization approach to sorry-free
completeness (Task 951).

## Overview

A `CanonicalChain` is a function `Int -> CanonicalMCS` together with proofs that
consecutive elements are CanonicalR-related:
- For non-negative n: `CanonicalR chain(n) chain(n+1)` (GContent inclusion forward)
- For negative n: `CanonicalR chain(n) chain(n+1)` (same -- the chain is monotone)

The ordering invariant ensures that `CanonicalR chain(s) chain(t)` for all `s <= t`,
by transitivity of CanonicalR.

## Construction Method

Each chain step is constructed via Lindenbaum extension of a seed:
- `chain(0)` = root MCS (Lindenbaum extension of input context Gamma)
- `chain(n+1)` = Lindenbaum({phi_n} ∪ GContent(chain(n))) for some F-witness formula phi_n
- `chain(-n-1)` = Lindenbaum({psi_n} ∪ HContent(chain(-n))) for some P-witness formula psi_n

The key property: each chain element is a FIXED, independent MCS. Adding new elements
does not modify existing ones. This avoids the GContent-corruption failure mode of the
Int-indexed DovetailingChain approach.

## Key Insight

The ordering between consecutive elements follows from the seed construction:
- `GContent(chain(n)) ⊆ {phi_n} ∪ GContent(chain(n)) ⊆ chain(n+1)` (by Lindenbaum extension)
- For backward: `HContent(chain(-n)) ⊆ {psi_n} ∪ HContent(chain(-n)) ⊆ chain(-n-1)`,
  which gives `CanonicalR chain(-n-1) chain(-n)` by HContent/GContent duality

## References

- Task 951 research-002: Antisymmetrization approach design
- Task 945 research-003/004: Original antisymmetrization analysis
- Goldblatt 1992: Logics of Time and Computation, Chapter 4
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## CanonicalChain Structure

A Z-indexed chain through CanonicalMCS with consecutive-element ordering.
-/

/--
A Z-indexed chain through CanonicalMCS with the CanonicalR ordering invariant.

The chain maps each integer to a CanonicalMCS element, and consecutive elements
are CanonicalR-related (i.e., GContent of the earlier element is included in the
later element).

**Fields**:
- `chain`: The function mapping integers to CanonicalMCS elements
- `ordered`: For all n, `CanonicalR chain(n).world chain(n+1).world`
  (i.e., `GContent(chain(n).world) ⊆ chain(n+1).world`)

The `ordered` property gives us a monotone chain: for s <= t, `CanonicalR chain(s) chain(t)`
follows from transitivity of CanonicalR (proven in CanonicalFrame.lean).
-/
structure CanonicalChain where
  /-- The chain function mapping integers to CanonicalMCS elements -/
  chain : Int → CanonicalMCS
  /-- Consecutive ordering: CanonicalR between adjacent elements -/
  ordered : ∀ n : Int, CanonicalR (chain n).world (chain (n + 1)).world

/-!
## Basic Properties of CanonicalChain
-/

variable (C : CanonicalChain)

/--
The chain is monotone: for s <= t, `CanonicalR chain(s).world chain(t).world`.

This follows from the consecutive ordering property by induction on the
distance t - s, using transitivity of CanonicalR.
-/
theorem CanonicalChain.monotone (s t : Int) (h : s ≤ t) :
    CanonicalR (C.chain s).world (C.chain t).world := by
  -- We prove by induction on the natural number (t - s)
  obtain ⟨d, hd⟩ : ∃ d : Nat, t = s + d := by
    exact ⟨(t - s).toNat, by omega⟩
  subst hd
  induction d with
  | zero => simp; exact canonicalR_reflexive _ (C.chain s).is_mcs
  | succ n ih =>
    have h_le : s ≤ s + ↑n := by omega
    have h_step := C.ordered (s + ↑n)
    have h_eq : s + ↑(n + 1) = s + ↑n + 1 := by omega
    rw [h_eq]
    exact canonicalR_transitive (C.chain s).world (C.chain (s + ↑n)).world
      (C.chain (s + ↑n + 1)).world (C.chain s).is_mcs
      (ih h_le) h_step

/--
Extract the GContent inclusion from monotonicity (forward direction).

If s <= t, then `GContent(chain(s).world) ⊆ chain(t).world`.
This is just the unfolding of `CanonicalR`.
-/
theorem CanonicalChain.GContent_inclusion (s t : Int) (h : s ≤ t) :
    GContent (C.chain s).world ⊆ (C.chain t).world :=
  C.monotone s t h

/--
Extract the HContent inclusion from monotonicity (backward direction).

If s <= t, then `HContent(chain(t).world) ⊆ chain(s).world`.
This follows from `GContent_subset_implies_HContent_reverse`.
-/
theorem CanonicalChain.HContent_inclusion (s t : Int) (h : s ≤ t) :
    HContent (C.chain t).world ⊆ (C.chain s).world :=
  GContent_subset_implies_HContent_reverse (C.chain s).world (C.chain t).world
    (C.chain s).is_mcs (C.chain t).is_mcs (C.monotone s t h)

/-!
## CanonicalChain as FMCS

A CanonicalChain naturally defines an `FMCS Int` where each time point maps to
the chain element's underlying MCS.
-/

/--
Convert a CanonicalChain to an FMCS over Int.

The MCS assignment maps each integer `t` to `chain(t).world`.
Forward G and Backward H coherence follow from the chain's monotonicity.
-/
noncomputable def CanonicalChain.toFMCS : FMCS Int where
  mcs t := (C.chain t).world
  is_mcs t := (C.chain t).is_mcs
  forward_G := fun s t _phi h_le h_G =>
    -- G phi in chain(s).world and s <= t implies phi in chain(t).world
    -- By monotone: GContent(chain(s).world) ⊆ chain(t).world
    -- G phi in chain(s).world means phi in GContent(chain(s).world)
    C.GContent_inclusion s t h_le h_G
  backward_H := fun t s _phi h_le h_H =>
    -- H phi in chain(t).world and s <= t implies phi in chain(s).world
    -- By HContent_inclusion: HContent(chain(t).world) ⊆ chain(s).world
    C.HContent_inclusion s t h_le h_H

/-!
## Constructing a CanonicalChain from a Root MCS

Given a root MCS, we construct a chain by extending forward using GContent seeds
and backward using HContent seeds. Each step witnesses one F-obligation or
P-obligation from the current frontier.

In Phase 1, we construct the simplest possible chain: at each step, the seed
is just GContent (forward) or HContent (backward) without any additional
witness formula. This gives us the basic ordering properties. The dovetailing
enumeration of witness obligations is added in Phase 2.
-/

/--
Construct the forward part of a canonical chain from a root MCS.

`forwardChainStep root n` constructs the chain element at position n (for n >= 0)
by recursively extending via GContent seeds.

The construction:
- `forwardChainStep root 0 = root`
- `forwardChainStep root (n+1) = Lindenbaum(GContent(forwardChainStep root n))`

This is a conservative chain where each step just propagates GContent without
adding additional witness formulas. Witness formulas will be added in Phase 2
via the dovetailing enumeration.
-/
noncomputable def forwardChainStep (root : CanonicalMCS) : Nat → CanonicalMCS
  | 0 => root
  | n + 1 =>
    let prev := forwardChainStep root n
    -- GContent(prev.world) is consistent (as a subset of prev.world via T-axiom)
    have h_cons : SetConsistent (GContent prev.world) := by
      intro finset h_subset ⟨h_deriv⟩
      -- If GContent(M) were inconsistent, then some finite subset derives bot
      -- But GContent(M) ⊆ M (by T-axiom), and M is consistent
      have h_sub_M : GContent prev.world ⊆ prev.world :=
        canonicalR_reflexive prev.world prev.is_mcs
      exact prev.is_mcs.1 finset (fun phi h_mem => h_sub_M (h_subset phi h_mem)) ⟨h_deriv⟩
    let W := lindenbaumMCS_set (GContent prev.world) h_cons
    { world := W, is_mcs := lindenbaumMCS_set_is_mcs (GContent prev.world) h_cons }

/--
Forward chain step preserves CanonicalR: `CanonicalR (step n).world (step (n+1)).world`.
-/
theorem forwardChainStep_ordered (root : CanonicalMCS) (n : Nat) :
    CanonicalR (forwardChainStep root n).world (forwardChainStep root (n + 1)).world := by
  simp only [forwardChainStep]
  -- Need: GContent(prev.world) ⊆ W where W = lindenbaumMCS_set(GContent(prev.world))
  -- This follows from lindenbaumMCS_set_extends
  exact lindenbaumMCS_set_extends (GContent (forwardChainStep root n).world) _

/--
Construct the backward part of a canonical chain from a root MCS.

`backwardChainStep root n` constructs the chain element at position -n (for n >= 0)
by recursively extending via HContent seeds.

The construction:
- `backwardChainStep root 0 = root`
- `backwardChainStep root (n+1) = Lindenbaum(HContent(backwardChainStep root n))`

Note: The direction convention is that `backwardChainStep root n` gives the
chain element at position -(n : Int), extending BACKWARD from the root.
-/
noncomputable def backwardChainStep (root : CanonicalMCS) : Nat → CanonicalMCS
  | 0 => root
  | n + 1 =>
    let prev := backwardChainStep root n
    -- HContent(prev.world) is consistent (as a subset of prev.world via T-axiom for H)
    have h_cons : SetConsistent (HContent prev.world) := by
      intro finset h_subset ⟨h_deriv⟩
      have h_sub_M : HContent prev.world ⊆ prev.world :=
        canonicalR_past_reflexive prev.world prev.is_mcs
      exact prev.is_mcs.1 finset (fun phi h_mem => h_sub_M (h_subset phi h_mem)) ⟨h_deriv⟩
    let W := lindenbaumMCS_set (HContent prev.world) h_cons
    { world := W, is_mcs := lindenbaumMCS_set_is_mcs (HContent prev.world) h_cons }

/--
Backward chain step has HContent inclusion:
`HContent (backwardChainStep root n).world ⊆ (backwardChainStep root (n+1)).world`.
-/
theorem backwardChainStep_HContent_inclusion (root : CanonicalMCS) (n : Nat) :
    HContent (backwardChainStep root n).world ⊆ (backwardChainStep root (n + 1)).world := by
  simp only [backwardChainStep]
  exact lindenbaumMCS_set_extends (HContent (backwardChainStep root n).world) _

/--
Backward chain step preserves CanonicalR in the correct direction:
`CanonicalR (backwardChainStep root (n+1)).world (backwardChainStep root n).world`.

This follows from HContent/GContent duality:
- By construction, `HContent(step n) ⊆ step(n+1)` (from seed inclusion)
- By duality, `GContent(step(n+1)) ⊆ step(n)` (from `HContent_subset_implies_GContent_reverse`)
-/
theorem backwardChainStep_ordered (root : CanonicalMCS) (n : Nat) :
    CanonicalR (backwardChainStep root (n + 1)).world (backwardChainStep root n).world := by
  -- HContent(backwardChainStep root n) ⊆ backwardChainStep root (n+1)
  have h_H_incl := backwardChainStep_HContent_inclusion root n
  -- By duality: GContent(backwardChainStep root (n+1)) ⊆ backwardChainStep root n
  exact HContent_subset_implies_GContent_reverse
    (backwardChainStep root n).world
    (backwardChainStep root (n + 1)).world
    (backwardChainStep root n).is_mcs
    (backwardChainStep root (n + 1)).is_mcs
    h_H_incl

/-!
## Combining Forward and Backward into a Full Chain

Combine the forward and backward chain steps into a single function `Int -> CanonicalMCS`
and prove the consecutive ordering property.
-/

/--
Combine forward and backward chain steps into a full Z-indexed chain.

- For `n >= 0`: use `forwardChainStep root n`
- For `n < 0`: use `backwardChainStep root (-n)` (mapping -1 to step 1, -2 to step 2, etc.)

Note: at position 0, both forward and backward agree (both return root).
-/
noncomputable def buildChainFn (root : CanonicalMCS) (n : Int) : CanonicalMCS :=
  if n ≥ 0 then
    forwardChainStep root n.toNat
  else
    backwardChainStep root (-n).toNat

/--
The chain function at 0 returns the root.
-/
theorem buildChainFn_zero (root : CanonicalMCS) :
    buildChainFn root 0 = root := by
  simp [buildChainFn, forwardChainStep]

/--
The chain function at positive n uses forwardChainStep.
-/
theorem buildChainFn_nonneg (root : CanonicalMCS) (n : Int) (h : n ≥ 0) :
    buildChainFn root n = forwardChainStep root n.toNat := by
  simp [buildChainFn, h]

/--
The chain function at negative n uses backwardChainStep.
-/
theorem buildChainFn_neg (root : CanonicalMCS) (n : Int) (h : n < 0) :
    buildChainFn root n = backwardChainStep root (-n).toNat := by
  simp [buildChainFn, show ¬(n ≥ 0) from by omega]

/--
Key ordering lemma: consecutive elements of the combined chain are CanonicalR-related.

This is the main proof obligation for Phase 1. We need to show that for every n,
`CanonicalR (buildChainFn root n).world (buildChainFn root (n+1)).world`.

The proof splits into three cases:
1. `n >= 0`: Both in forward chain. Use `forwardChainStep_ordered`.
2. `n = -1`: Transition from backward step 1 to forward step 0 (root).
   Use `backwardChainStep_ordered root 0`.
3. `n < -1`: Both in backward chain. Use `backwardChainStep_ordered`.
-/
theorem buildChainFn_ordered (root : CanonicalMCS) (n : Int) :
    CanonicalR (buildChainFn root n).world (buildChainFn root (n + 1)).world := by
  by_cases h0 : n ≥ 0
  · -- Case 1: n >= 0, so n and n+1 are both in forward chain
    have h1 : n + 1 ≥ 0 := by omega
    rw [buildChainFn_nonneg root n h0, buildChainFn_nonneg root (n + 1) h1]
    have : (n + 1).toNat = n.toNat + 1 := by omega
    rw [this]
    exact forwardChainStep_ordered root n.toNat
  · push_neg at h0
    by_cases h1 : n = -1
    · -- Case 2: n = -1, transition from backwardChainStep 1 to root (= forwardChainStep 0)
      subst h1
      show CanonicalR (buildChainFn root (-1)).world (buildChainFn root 0).world
      rw [buildChainFn_neg root (-1) (by omega), buildChainFn_zero root]
      simp
      -- Need: CanonicalR (backwardChainStep root 1).world root.world
      -- This is backwardChainStep_ordered root 0
      exact backwardChainStep_ordered root 0
    · -- Case 3: n < -1, so n and n+1 are both in backward chain
      have hn : n < -1 := by omega
      have hn1 : n + 1 < 0 := by omega
      rw [buildChainFn_neg root n (by omega), buildChainFn_neg root (n + 1) hn1]
      -- Need: CanonicalR (backwardChainStep root (-n).toNat).world
      --                   (backwardChainStep root (-(n+1)).toNat).world
      -- Since n < -1, we have -n >= 2, so (-n).toNat = (-(n+1)).toNat + 1
      have h_eq : (-n).toNat = (-(n + 1)).toNat + 1 := by omega
      rw [h_eq]
      -- Need: CanonicalR (backwardChainStep root ((-(n+1)).toNat + 1)).world
      --                   (backwardChainStep root (-(n+1)).toNat).world
      exact backwardChainStep_ordered root (-(n + 1)).toNat

/--
Build a complete CanonicalChain from a root MCS.

This combines the forward and backward chain step constructions into
a single CanonicalChain structure with the ordering invariant proven.
-/
noncomputable def buildCanonicalChain (root : CanonicalMCS) : CanonicalChain where
  chain := buildChainFn root
  ordered := buildChainFn_ordered root

/--
The built chain preserves the root: `chain(0) = root`.
-/
theorem buildCanonicalChain_root (root : CanonicalMCS) :
    (buildCanonicalChain root).chain 0 = root := by
  simp [buildCanonicalChain, buildChainFn_zero]

/-!
## Chain Ordering Properties (Explicit Forward and Backward)

These lemmas restate the ordering in more familiar forms matching the plan's
`chain_ordered` and `chain_ordered_neg` specifications.
-/

/--
Forward ordering: for all n >= 0, `CanonicalR chain(n) chain(n+1)`.

This is a special case of the general `ordered` property.
-/
theorem CanonicalChain.chain_ordered_forward (n : Nat) :
    CanonicalR (C.chain n).world (C.chain (↑n + 1)).world :=
  C.ordered n

/--
Backward ordering: for all n >= 0, `CanonicalR chain(-n-1) chain(-n)`.

This restates the ordering property in the backward direction.
-/
theorem CanonicalChain.chain_ordered_backward (n : Nat) :
    CanonicalR (C.chain (-(↑n + 1))).world (C.chain (-↑n)).world := by
  have : (-↑n : Int) = -(↑n + 1) + 1 := by omega
  rw [this]
  exact C.ordered (-(↑n + 1))

/-!
## Compatibility with CanonicalFMCS

The CanonicalChain FMCS is compatible with the existing CanonicalMCS infrastructure:
each chain element IS a CanonicalMCS, so the Preorder instance and all existing
lemmas about CanonicalR apply directly.
-/

/--
Each chain element is a CanonicalMCS (trivially, by definition).
-/
theorem CanonicalChain.is_canonicalMCS (n : Int) :
    SetMaximalConsistent (C.chain n).world :=
  (C.chain n).is_mcs

/--
The chain defines a CanonicalMCS-valued preorder-respecting function:
for s <= t, `chain(s) <= chain(t)` in the CanonicalMCS Preorder.
-/
theorem CanonicalChain.preorder_monotone (s t : Int) (h : s ≤ t) :
    (C.chain s) ≤ (C.chain t) :=
  C.monotone s t h

/-!
## Forward F and Backward P from Chain Construction

When the chain is built via `buildCanonicalChain`, the forward_F and backward_P
properties for the resulting FMCS will be proven in Phase 2-4 using the
dovetailing enumeration. For now, we provide the FMCS conversion which satisfies
forward_G and backward_H (the universal temporal coherence conditions).
-/

/--
The FMCS from a built canonical chain preserves the root context.

If `root.world ⊇ contextAsSet Gamma`, then `chain.toFMCS.mcs 0 ⊇ contextAsSet Gamma`.
-/
theorem CanonicalChain.toFMCS_preserves_context
    (root : CanonicalMCS) (Gamma : List Formula)
    (h_extends : contextAsSet Gamma ⊆ root.world) :
    ∀ gamma ∈ Gamma, gamma ∈ (buildCanonicalChain root).toFMCS.mcs 0 := by
  intro gamma h_mem
  have h_root : (buildCanonicalChain root).chain 0 = root := buildCanonicalChain_root root
  show gamma ∈ ((buildCanonicalChain root).chain 0).world
  rw [h_root]
  exact h_extends (by simp [contextAsSet]; exact h_mem)

end Bimodal.Metalogic.Bundle
