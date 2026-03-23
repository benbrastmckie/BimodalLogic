import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.CanonicalIrreflexivity
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Mathlib.Order.Hom.Basic

/-!
# FMCS Domain Transfer

This module provides infrastructure for transferring FMCS temporal coherence properties
from `CanonicalMCS` to any target domain `D` via an embedding/retraction pair.

## Overview

The key insight is that `CanonicalMCS` has sorry-free proofs of `forward_F` and `backward_P`
because every MCS is in the domain by construction. Instead of proving these properties
directly on other domains (which requires complex witness constructions), we transfer
them along an order-embedding/retraction pair.

## Transfer Strategy

Given:
- An order embedding `embed : CanonicalMCS ↪o D` (preserves and reflects order)
- A retraction `retract : D → CanonicalMCS`
- Left inverse: `retract (embed w) = w`
- Monotonicity: `retract` is monotone

We define:
- `transferredFMCS.mcs d := canonicalMCSBFMCS.mcs (retract d)`
- Forward/backward G/H follow from composition
- Forward F/P transfer witnesses via embedding

## Key Properties

The embedding being an `OrderEmbedding` means it preserves AND reflects order:
- `embed w₁ ≤ embed w₂ ↔ w₁ ≤ w₂`

This is crucial for transferring strict inequalities:
- If `w > retract d` in CanonicalMCS, then `embed w > d` in D

## References

- Task 995: FMCS domain transfer lemma
- CanonicalFMCS.lean: Sorry-free forward_F and backward_P proofs
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## FMCSTransfer Structure

The transfer structure captures an embedding/retraction pair between CanonicalMCS
and a target domain D with the compatibility conditions needed for transferring
temporal coherence properties.
-/

/--
FMCSTransfer: An embedding/retraction pair from CanonicalMCS to a target domain D.

The structure encapsulates:
- `embed`: Monotone embedding from CanonicalMCS to D
- `retract`: Retraction from D to CanonicalMCS (left inverse of embed)
- Strict monotonicity in both directions
- Surjectivity: every d equals embed(retract d)

These conditions ensure:
1. MCS assignment via retraction is well-defined
2. Witnesses from CanonicalMCS can be transferred to D via embedding
3. Order relationships are preserved in both directions
4. The embedding covers all of D (surjectivity via retraction)

**Note**: The `embed_retract_eq` constraint effectively requires `embed` to be
surjective, making `retract` a true inverse (not just left inverse). This is
satisfied by chain/timeline constructions where every domain element corresponds
to some MCS in the construction.
-/
structure FMCSTransfer (D : Type*) [Preorder D] where
  /-- Monotone embedding from CanonicalMCS to D -/
  embed : CanonicalMCS →o D
  /-- Retraction from D back to CanonicalMCS -/
  retract : D → CanonicalMCS
  /-- Retraction is left inverse to embedding: retract (embed w) = w -/
  retract_left_inverse : ∀ w : CanonicalMCS, retract (embed w) = w
  /-- Embedding is right inverse to retraction: embed (retract d) = d
      This makes embed surjective and retract a true (two-sided) inverse on the image. -/
  embed_retract_eq : ∀ d : D, embed (retract d) = d
  /-- Retraction strictly preserves order: d₁ < d₂ → retract d₁ < retract d₂ -/
  retract_lt : ∀ d₁ d₂ : D, d₁ < d₂ → retract d₁ < retract d₂
  /-- Embedding strictly preserves order: w₁ < w₂ → embed w₁ < embed w₂ -/
  embed_lt : ∀ w₁ w₂ : CanonicalMCS, w₁ < w₂ → embed w₁ < embed w₂

variable {D : Type*} [Preorder D]

namespace FMCSTransfer

/-!
## Derived Properties

Basic properties derived from the FMCSTransfer axioms.
-/

/--
The embedding preserves the non-strict order (follows from OrderHom).
-/
theorem embed_le (T : FMCSTransfer D) (w₁ w₂ : CanonicalMCS) (h : w₁ ≤ w₂) :
    T.embed w₁ ≤ T.embed w₂ :=
  T.embed.monotone h

/--
Key lemma for forward_F transfer: If retract d < w in CanonicalMCS,
then d < embed w in D.

Proof: Since embed (retract d) = d and embed is strictly monotone,
retract d < w implies d = embed (retract d) < embed w.
-/
theorem embed_witness_gt (T : FMCSTransfer D) (d : D) (w : CanonicalMCS)
    (h_gt : T.retract d < w) : d < T.embed w := by
  have h_embed_lt : T.embed (T.retract d) < T.embed w := T.embed_lt _ _ h_gt
  rw [T.embed_retract_eq] at h_embed_lt
  exact h_embed_lt

/--
Key lemma for backward_P transfer: If w < retract d in CanonicalMCS,
then embed w < d in D.

Proof: Since embed (retract d) = d and embed is strictly monotone,
w < retract d implies embed w < embed (retract d) = d.
-/
theorem embed_witness_lt (T : FMCSTransfer D) (d : D) (w : CanonicalMCS)
    (h_lt : w < T.retract d) : T.embed w < d := by
  have h_embed_lt : T.embed w < T.embed (T.retract d) := T.embed_lt _ _ h_lt
  rw [T.embed_retract_eq] at h_embed_lt
  exact h_embed_lt

end FMCSTransfer

/-!
## Transferred FMCS Definition

Given an FMCSTransfer, we define a FMCS on D by pulling back the MCS assignment
from CanonicalMCS via the retraction function.
-/

/--
The MCS assignment for the transferred FMCS: mcs(d) := canonicalMCS_mcs(retract d).

This assigns to each d : D the MCS associated with its canonical representative.
-/
def transferredMCS (T : FMCSTransfer D) (d : D) : Set Formula :=
  canonicalMCS_mcs (T.retract d)

/--
Each transferred MCS is maximal consistent (inherited from CanonicalMCS).
-/
theorem transferredMCS_is_mcs (T : FMCSTransfer D) (d : D) :
    SetMaximalConsistent (transferredMCS T d) :=
  canonicalMCS_is_mcs (T.retract d)

/--
Forward G coherence for transferred FMCS: G(phi) at d₁ implies phi at d₂ for d₁ < d₂.

Proof: d₁ < d₂ in D implies retract d₁ < retract d₂ in CanonicalMCS (by retract_lt).
Apply canonicalMCS_forward_G to get the result.
-/
theorem transferred_forward_G (T : FMCSTransfer D) (d₁ d₂ : D) (phi : Formula)
    (h_lt : d₁ < d₂) (h_G : Formula.all_future phi ∈ transferredMCS T d₁) :
    phi ∈ transferredMCS T d₂ := by
  unfold transferredMCS at *
  have h_retract_lt : T.retract d₁ < T.retract d₂ := T.retract_lt d₁ d₂ h_lt
  exact canonicalMCS_forward_G (T.retract d₁) (T.retract d₂) phi h_retract_lt h_G

/--
Backward H coherence for transferred FMCS: H(phi) at d₁ implies phi at d₂ for d₂ < d₁.

Proof: d₂ < d₁ in D implies retract d₂ < retract d₁ in CanonicalMCS (by retract_lt).
Apply canonicalMCS_backward_H to get the result.
-/
theorem transferred_backward_H (T : FMCSTransfer D) (d₁ d₂ : D) (phi : Formula)
    (h_lt : d₂ < d₁) (h_H : Formula.all_past phi ∈ transferredMCS T d₁) :
    phi ∈ transferredMCS T d₂ := by
  unfold transferredMCS at *
  have h_retract_lt : T.retract d₂ < T.retract d₁ := T.retract_lt d₂ d₁ h_lt
  exact canonicalMCS_backward_H (T.retract d₁) (T.retract d₂) phi h_retract_lt h_H

/--
The transferred FMCS: a FMCS on D induced by an FMCSTransfer from CanonicalMCS.

This construction assigns MCS via retraction and inherits forward_G/backward_H
coherence from the canonical construction.
-/
noncomputable def transferredFMCS (T : FMCSTransfer D) : FMCS D where
  mcs := transferredMCS T
  is_mcs := transferredMCS_is_mcs T
  forward_G := fun d₁ d₂ phi h_le h_G => by
    rcases eq_or_lt_of_le h_le with rfl | h_lt
    · -- d₁ = d₂: use T-axiom
      exact SetMaximalConsistent.implication_property (transferredMCS_is_mcs T d₁)
        (theorem_in_mcs (transferredMCS_is_mcs T d₁) (.axiom _ _ (.temp_t_future phi))) h_G
    · exact transferred_forward_G T d₁ d₂ phi h_lt h_G
  backward_H := fun d₁ d₂ phi h_le h_H => by
    rcases eq_or_lt_of_le h_le with rfl | h_lt
    · -- d₁ = d₂: use T-axiom
      exact SetMaximalConsistent.implication_property (transferredMCS_is_mcs T d₁)
        (theorem_in_mcs (transferredMCS_is_mcs T d₁) (.axiom _ _ (.temp_t_past phi))) h_H
    · exact transferred_backward_H T d₁ d₂ phi h_lt h_H

/-!
## Forward F and Backward P Transfer (Phase 3-4)

The key payoff: transfer the sorry-free forward_F and backward_P from CanonicalMCS
to the target domain D.
-/

/--
ExistsTask implies strict < in the CanonicalMCS Preorder.

Since the Preorder is defined as `a ≤ b := a = b ∨ ExistsTask a.world b.world`,
having `ExistsTask a.world b.world` gives `a ≤ b`. Combined with irreflexivity
of ExistsTask (which implies a ≠ b), we get `a < b`.
-/
theorem CanonicalMCS.lt_of_canonicalR (a b : CanonicalMCS) (h : ExistsTask a.world b.world) :
    a < b := by
  constructor
  · -- a ≤ b from ExistsTask
    exact CanonicalMCS.le_of_canonicalR a b h
  · -- ¬(b ≤ a): if b ≤ a, then either b = a or ExistsTask b.world a.world
    intro h_le
    rcases h_le with rfl | h_R_ba
    · -- Case b = a: ExistsTask a.world a.world contradicts irreflexivity
      -- Note: after rfl, both a and b refer to the same thing, but b is the name in scope
      exact canonicalR_irreflexive b.world b.is_mcs h
    · -- Case ExistsTask b.world a.world: combined with ExistsTask a.world b.world,
      -- this would give a cycle. We can derive a contradiction from transitivity
      -- and irreflexivity: ExistsTask a b and ExistsTask b a gives ExistsTask a a
      have h_aa := canonicalR_transitive a.world b.world a.world a.is_mcs h h_R_ba
      exact canonicalR_irreflexive a.world a.is_mcs h_aa

/--
Forward F transfer: F(phi) at d implies witness s > d with phi at s.

**Proof Strategy**:
1. F(phi) ∈ transferredMCS T d means F(phi) ∈ canonicalMCS_mcs (T.retract d)
2. By canonical_forward_F, get witness W with ExistsTask (retract d).world W and phi ∈ W
3. Create w : CanonicalMCS from W
4. ExistsTask implies retract d < w strictly (by lt_of_canonicalR)
5. Take s := T.embed w
6. d < s by embed_witness_gt
7. phi ∈ transferredMCS T s = canonicalMCS_mcs (T.retract (T.embed w)) = canonicalMCS_mcs w = W
   by retract_left_inverse
-/
theorem transfer_forward_F (T : FMCSTransfer D) (d : D) (phi : Formula)
    (h_F : Formula.some_future phi ∈ transferredMCS T d) :
    ∃ s : D, d < s ∧ phi ∈ transferredMCS T s := by
  -- Step 1: Unfold to get F(phi) ∈ canonicalMCS_mcs (T.retract d)
  unfold transferredMCS at h_F
  -- Step 2: Apply canonical_forward_F to get witness
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ :=
    canonical_forward_F (T.retract d).world (T.retract d).is_mcs phi h_F
  -- Step 3: Create CanonicalMCS element from W
  let w : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  -- Step 4: ExistsTask implies strict order
  have h_lt_w : T.retract d < w := CanonicalMCS.lt_of_canonicalR (T.retract d) w h_R
  -- Step 5: Define witness s := T.embed w
  use T.embed w
  constructor
  · -- d < T.embed w
    exact T.embed_witness_gt d w h_lt_w
  · -- phi ∈ transferredMCS T (T.embed w)
    unfold transferredMCS
    -- T.retract (T.embed w) = w by retract_left_inverse
    rw [T.retract_left_inverse w]
    -- canonicalMCS_mcs w = w.world = W
    exact h_phi_W

/--
ExistsTask_past implies strict < in the reverse direction.

If ExistsTask_past a.world b.world (meaning h_content(a) ⊆ b), then by the
g_content/h_content duality, we have ExistsTask b.world a.world, which gives b < a.
-/
theorem CanonicalMCS.lt_of_canonicalR_past (a b : CanonicalMCS) (h : ExistsTask_past a.world b.world) :
    b < a := by
  -- ExistsTask_past a b means h_content(a) ⊆ b
  -- By h_content_subset_implies_g_content_reverse, this gives ExistsTask b a
  have h_R : ExistsTask b.world a.world :=
    h_content_subset_implies_g_content_reverse a.world b.world a.is_mcs b.is_mcs h
  exact CanonicalMCS.lt_of_canonicalR b a h_R

/--
Backward P transfer: P(phi) at d implies witness s < d with phi at s.

**Proof Strategy** (symmetric to forward_F):
1. P(phi) ∈ transferredMCS T d means P(phi) ∈ canonicalMCS_mcs (T.retract d)
2. By canonical_backward_P, get witness W with ExistsTask_past (retract d).world W and phi ∈ W
3. Create w : CanonicalMCS from W
4. ExistsTask_past implies w < retract d strictly (by lt_of_canonicalR_past)
5. Take s := T.embed w
6. s < d by embed_witness_lt
7. phi ∈ transferredMCS T s = canonicalMCS_mcs (T.retract (T.embed w)) = canonicalMCS_mcs w = W
   by retract_left_inverse
-/
theorem transfer_backward_P (T : FMCSTransfer D) (d : D) (phi : Formula)
    (h_P : Formula.some_past phi ∈ transferredMCS T d) :
    ∃ s : D, s < d ∧ phi ∈ transferredMCS T s := by
  -- Step 1: Unfold to get P(phi) ∈ canonicalMCS_mcs (T.retract d)
  unfold transferredMCS at h_P
  -- Step 2: Apply canonical_backward_P to get witness
  obtain ⟨W, h_W_mcs, h_R_past, h_phi_W⟩ :=
    canonical_backward_P (T.retract d).world (T.retract d).is_mcs phi h_P
  -- Step 3: Create CanonicalMCS element from W
  let w : CanonicalMCS := { world := W, is_mcs := h_W_mcs }
  -- Step 4: ExistsTask_past implies strict order (w < retract d)
  have h_lt_w : w < T.retract d := CanonicalMCS.lt_of_canonicalR_past (T.retract d) w h_R_past
  -- Step 5: Define witness s := T.embed w
  use T.embed w
  constructor
  · -- T.embed w < d
    exact T.embed_witness_lt d w h_lt_w
  · -- phi ∈ transferredMCS T (T.embed w)
    unfold transferredMCS
    -- T.retract (T.embed w) = w by retract_left_inverse
    rw [T.retract_left_inverse w]
    -- canonicalMCS_mcs w = w.world = W
    exact h_phi_W

/-!
## Main Transfer Theorem (Phase 5)

Package the transfer results into a single theorem that provides a complete
temporally coherent family on D given an FMCSTransfer.
-/

/--
Main FMCS domain transfer theorem: Given an FMCSTransfer from CanonicalMCS to D,
we get a FMCS on D with forward_F and backward_P coherence properties.

This theorem packages all the transfer results together, showing that the
transferred FMCS satisfies the temporal coherence conditions needed for
completeness proofs.

**Components**:
- `fam`: The transferred FMCS on D
- `forward_F`: F(phi) at d implies witness s > d with phi at s
- `backward_P`: P(phi) at d implies witness s < d with phi at s

**Usage**: Instantiate FMCSTransfer for a specific D (e.g., Int, Rat), then
apply this theorem to get the temporal coherence properties automatically.
-/
theorem fmcs_domain_transfer (T : FMCSTransfer D) :
    ∃ (fam : FMCS D),
      (∀ d : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs d →
        ∃ s : D, d < s ∧ φ ∈ fam.mcs s) ∧
      (∀ d : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs d →
        ∃ s : D, s < d ∧ φ ∈ fam.mcs s) :=
  ⟨transferredFMCS T, transfer_forward_F T, transfer_backward_P T⟩

/--
Convenience wrapper: Create a TemporalCoherentFamily from an FMCSTransfer.

This combines the transferred FMCS with the forward_F and backward_P proofs
into a single structure suitable for use in completeness arguments.

Requires [Zero D] for the TemporalCoherentFamily structure.
-/
noncomputable def transferredTemporalCoherentFamily [Zero D] (T : FMCSTransfer D) :
    TemporalCoherentFamily D where
  toFMCS := transferredFMCS T
  forward_F := transfer_forward_F T
  backward_P := transfer_backward_P T

/-!
## Instantiation Infrastructure

To instantiate FMCSTransfer for a specific domain D, you need to provide:

1. **embed : CanonicalMCS →o D** - A monotone map from CanonicalMCS to D
2. **retract : D → CanonicalMCS** - An inverse map from D to CanonicalMCS
3. **retract_left_inverse** - Proof that retract (embed w) = w
4. **embed_retract_eq** - Proof that embed (retract d) = d
5. **retract_lt** - Proof that retract strictly preserves order
6. **embed_lt** - Proof that embed strictly preserves order

### Int Instantiation (requires dovetailing chain)

For D = Int, the chain construction needs to ensure:
- Every integer maps to some MCS in the chain
- The chain includes witnesses for all F/P requirements

This is a separate task (dovetailing enriched chain construction).

### Rat Instantiation (requires Cantor ordering)

For D = Rat, use the TimelineQuot construction:
- Timeline is built with staged saturation including F/P witnesses
- Cantor ordering provides the bijection to Q
- embed/retract come from the OrderIso

This is a separate task (linking TimelineQuot to FMCSTransfer).
-/

end Bimodal.Metalogic.Bundle
