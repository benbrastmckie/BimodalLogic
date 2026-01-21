import Bimodal.Metalogic.Representation.CanonicalHistory
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Bimodal.Semantics.Truth

/-!
# Truth Lemma for Indexed MCS Family Canonical Model

This module proves the truth lemma connecting MCS membership to semantic truth
in the canonical model constructed from an indexed MCS family.

## Overview

**Main Theorem**: For an indexed MCS family and canonical history,
```
phi in family.mcs t <-> truth_at (canonical_model family) (canonical_history family) t phi
```

This is the key bridge between syntactic (MCS membership) and semantic (truth) notions.

## Proof Strategy

The proof proceeds by structural induction on formulas:
- **Atom**: Valuation is defined so that atom p in mcs t iff valuation says true
- **Bot**: MCS is consistent, so bot not in mcs; semantically, bot is false
- **Imp**: Uses MCS deductive closure and negation completeness
- **Box**: Universal quantification over histories requires careful handling
- **G (all_future)**: Uses family coherence conditions
  - Forward: G phi in mcs(t) -> by forward_G, phi in mcs(t') for t' > t -> IH
  - Backward: Contrapositive + MCS negation completeness
- **H (all_past)**: Symmetric to G case

## Key Insight

The family coherence conditions (forward_G, backward_H, etc.) directly correspond
to the semantic quantification in truth_at for temporal operators. This is why
the indexed family approach avoids the T-axiom requirement.

## References

- Research report: specs/654_.../reports/research-004.md
- Implementation plan: specs/654_.../plans/implementation-004.md
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic_v2.Core
open Bimodal.Semantics

variable (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Canonical Model Definition

The canonical model uses MCS membership to define valuation.
-/

/--
The canonical task model from an indexed MCS family.

**Valuation**: An atom p is true at world w iff (Formula.atom p) is in w's MCS.

This definition ensures the truth lemma's base case (atoms) is trivially true.
-/
def canonical_model (family : IndexedMCSFamily D) :
    TaskModel (UniversalCanonicalFrame D) where
  valuation := fun w p => Formula.atom p ∈ w.mcs

/-!
## Helper Lemmas

These lemmas support the truth lemma proof.
-/

/--
The canonical history has full domain.
-/
lemma canonical_history_family_domain (family : IndexedMCSFamily D) (t : D) :
    (canonical_history_family D family).domain t :=
  trivial

/--
The world state at time t has the family's MCS at t.
-/
lemma canonical_world_mcs (family : IndexedMCSFamily D) (t : D)
    (ht : (canonical_history_family D family).domain t) :
    ((canonical_history_family D family).states t ht).mcs = family.mcs t :=
  rfl

/-!
## Truth Lemma

The main theorem connecting MCS membership to semantic truth.
-/

/--
Truth lemma (forward direction): MCS membership implies truth.

If phi is in the MCS at time t, then phi is true at the canonical model.
-/
theorem truth_lemma_forward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t → truth_at (canonical_model D family) (canonical_history_family D family) t phi := by
  induction phi generalizing t with
  | atom p =>
    intro h_mem
    -- phi = Formula.atom p
    -- Need: truth_at M tau t (atom p)
    -- Which is: exists ht, valuation (tau.states t ht) p
    -- valuation is defined as: (atom p) in w.mcs
    -- And tau.states t ht has mcs = family.mcs t
    simp only [truth_at, canonical_model]
    have ht : (canonical_history_family D family).domain t := trivial
    use ht
    -- Show: (Formula.atom p) in ((canonical_history_family D family).states t ht).mcs
    rw [canonical_world_mcs D family t ht]
    exact h_mem

  | bot =>
    intro h_mem
    -- phi = bot, but bot cannot be in a consistent MCS
    -- This gives a contradiction
    simp only [truth_at]
    have h_cons : SetConsistent (family.mcs t) := (family.is_mcs t).1
    -- SetConsistent means no finite subset derives bot
    -- If bot in family.mcs t, then [bot] subset and [bot] derives bot trivially
    unfold SetConsistent at h_cons
    have h_bot_cons : Consistent [Formula.bot] := h_cons [Formula.bot] (by simp [h_mem])
    -- But [bot] is inconsistent - bot derives bot
    exfalso
    apply h_bot_cons
    constructor
    exact Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)

  | imp psi chi ih_psi ih_chi =>
    intro h_mem
    -- phi = psi -> chi
    -- Need: truth_at psi -> truth_at chi
    simp only [truth_at]
    intro h_psi_true
    -- Apply IH for chi direction
    -- This requires showing chi in mcs t
    -- If (psi -> chi) in mcs t and psi in mcs t, then chi in mcs t by modus ponens closure
    sorry -- Requires proving backward direction first, or modus ponens closure lemma

  | box psi ih =>
    intro h_mem
    -- phi = box psi
    -- Need: forall sigma : WorldHistory, truth_at sigma t psi
    simp only [truth_at]
    intro sigma
    -- Box universally quantifies over ALL histories
    -- This is the hardest case - requires showing psi true on arbitrary histories
    -- The canonical model construction ensures box formulas work correctly
    sorry -- Complex case requiring additional lemmas about histories

  | all_past psi ih =>
    intro h_mem
    -- phi = H psi (all_past psi)
    -- Need: forall s < t, truth_at s psi
    simp only [truth_at]
    intro s h_s_lt
    -- By backward_H: H psi in mcs t and s < t implies psi in mcs s
    have h_psi_in_s : psi ∈ family.mcs s := family.backward_H t s psi h_s_lt h_mem
    -- Apply IH
    exact ih s h_psi_in_s

  | all_future psi ih =>
    intro h_mem
    -- phi = G psi (all_future psi)
    -- Need: forall s > t, truth_at s psi
    simp only [truth_at]
    intro s h_t_lt
    -- By forward_G: G psi in mcs t and t < s implies psi in mcs s
    have h_psi_in_s : psi ∈ family.mcs s := family.forward_G t s psi h_t_lt h_mem
    -- Apply IH
    exact ih s h_psi_in_s

/--
Truth lemma (backward direction): Truth implies MCS membership.

If phi is true at the canonical model at time t, then phi is in the MCS at t.

**Note**: This direction is harder and requires MCS negation completeness.
-/
theorem truth_lemma_backward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    truth_at (canonical_model D family) (canonical_history_family D family) t phi → phi ∈ family.mcs t := by
  induction phi generalizing t with
  | atom p =>
    intro h_true
    -- phi = Formula.atom p
    -- h_true: exists ht, valuation (tau.states t ht) p
    -- valuation defined as (atom p) in w.mcs
    simp only [truth_at, canonical_model] at h_true
    obtain ⟨ht, h_val⟩ := h_true
    rw [canonical_world_mcs D family t ht] at h_val
    exact h_val

  | bot =>
    intro h_true
    -- phi = bot, but truth_at bot is False
    simp only [truth_at] at h_true

  | imp psi chi ih_psi ih_chi =>
    intro h_true
    -- phi = psi -> chi
    -- h_true: truth_at psi -> truth_at chi
    -- Need: (psi -> chi) in mcs t
    -- By MCS negation completeness: either (psi -> chi) in mcs t, or neg(psi -> chi) in mcs t
    -- If neg(psi -> chi) in mcs t, derive contradiction
    sorry -- Requires negation completeness and contradiction argument

  | box psi ih =>
    intro h_true
    -- phi = box psi
    -- h_true: forall sigma, truth_at sigma t psi
    -- Need: box psi in mcs t
    -- Requires argument about all histories
    sorry -- Complex case

  | all_past psi ih =>
    intro h_true
    -- phi = H psi
    -- h_true: forall s < t, truth_at s psi
    -- Need: H psi in mcs t
    -- By contrapositive: if not(H psi) in mcs t, then some_future (neg psi) in mcs t
    -- Then exists s < t with neg psi in mcs s, contradiction with h_true
    sorry -- Requires negation completeness

  | all_future psi ih =>
    intro h_true
    -- phi = G psi
    -- h_true: forall s > t, truth_at s psi
    -- Need: G psi in mcs t
    -- By contrapositive: if not(G psi) in mcs t, then some_past (neg psi) in mcs t
    -- Then exists s > t with neg psi in mcs s, contradiction with h_true
    sorry -- Requires negation completeness

/--
Truth lemma: MCS membership iff semantic truth.

**Main Theorem**: For an indexed MCS family,
```
phi in family.mcs t <-> truth_at (canonical_model family) (canonical_history family) t phi
```
-/
theorem truth_lemma (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at (canonical_model D family) (canonical_history_family D family) t phi :=
  ⟨truth_lemma_forward D family t phi, truth_lemma_backward D family t phi⟩

end Bimodal.Metalogic.Representation
