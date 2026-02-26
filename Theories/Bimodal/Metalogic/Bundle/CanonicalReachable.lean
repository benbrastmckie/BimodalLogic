import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.CanonicalEmbedding
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Canonical Reachable Fragment

This module defines the reachable fragment of the canonical frame from a root MCS,
and establishes key structural properties for the canonical quotient completeness proof.

## Overview

Given a root MCS `M₀`, the **future-reachable fragment** consists of all MCSes `M`
such that `CanonicalR M₀ M` (i.e., `GContent(M₀) ⊆ M`). By `canonical_reachable_linear`,
any two elements in this fragment are comparable under CanonicalR, forming a total preorder.

## Main Definitions

- `CanonicalReachable M₀ h_mcs₀` : Subtype of MCSes future-reachable from M₀

## Main Results

- `Nonempty (CanonicalReachable M₀ h_mcs₀)` : The root is in the reachable fragment
- `canonical_reachable_comparable` : Any two elements are CanonicalR-comparable
- `canonical_forward_F_strict` : F(phi) with phi absent gives a distinct successor
- `canonical_backward_P_strict` : P(phi) with phi absent gives a distinct predecessor
- `gcontent_eq_of_mutual_R` : Mutually CanonicalR-related MCSes share the same GContent
- `canonical_F_neg_from_not_G` : neg(G(phi)) in MCS gives F(neg(phi))
- `canonical_F_from_not_G_neg` : G(neg(phi)) absent from MCS gives F(phi)

## References

- Task 922 research-003.md: Analysis of Int embedding approaches
- CanonicalFrame.lean: canonical_forward_F, canonicalR_reflexive, canonicalR_transitive
- CanonicalEmbedding.lean: canonical_reachable_linear
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## The Reachable Fragment Type
-/

/--
A reachable MCS from root M₀: a set of formulas that is MCS and future-accessible from M₀.
-/
structure CanonicalReachable (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) where
  /-- The underlying set of formulas -/
  world : Set Formula
  /-- The world is a maximal consistent set -/
  is_mcs : SetMaximalConsistent world
  /-- The world is future-reachable from M₀ -/
  reachable : CanonicalR M₀ world

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/--
Extensional equality for reachable MCSes: two are equal iff their worlds are equal.
-/
theorem CanonicalReachable.ext {a b : CanonicalReachable M₀ h_mcs₀}
    (h : a.world = b.world) : a = b := by
  cases a; cases b; simp only [mk.injEq]; exact h

/--
The root M₀ is in the reachable fragment (by reflexivity of CanonicalR for MCSes).
-/
def CanonicalReachable.root : CanonicalReachable M₀ h_mcs₀ where
  world := M₀
  is_mcs := h_mcs₀
  reachable := canonicalR_reflexive M₀ h_mcs₀

instance : Nonempty (CanonicalReachable M₀ h_mcs₀) :=
  ⟨CanonicalReachable.root⟩

/-!
## Comparability of Reachable Elements

Any two elements of the reachable fragment are CanonicalR-comparable (from the root).
-/

/--
Any two elements of the future-reachable fragment from M₀ are comparable under CanonicalR.
-/
theorem canonical_reachable_comparable (a b : CanonicalReachable M₀ h_mcs₀) :
    CanonicalR a.world b.world ∨ CanonicalR b.world a.world ∨ a.world = b.world :=
  canonical_reachable_linear M₀ a.world b.world h_mcs₀ a.is_mcs b.is_mcs a.reachable b.reachable

/-!
## GContent Properties for Mutual CanonicalR

When two MCSes are mutually CanonicalR-related, they share the same GContent.
This uses the Temporal 4 axiom (G(phi) → G(G(phi))).
-/

/--
If CanonicalR M₁ M₂ and CanonicalR M₂ M₁, then GContent(M₁) = GContent(M₂).

Proof: By temp_4 (G(phi) → G(G(phi))). If G(phi) ∈ M₁, then G(G(phi)) ∈ M₁ (by temp_4),
so G(phi) ∈ GContent(M₁) ⊆ M₂, giving G(phi) ∈ M₂. Symmetrically in reverse.
-/
theorem gcontent_eq_of_mutual_R (M₁ M₂ : Set Formula)
    (h_mcs₁ : SetMaximalConsistent M₁) (h_mcs₂ : SetMaximalConsistent M₂)
    (h₁₂ : CanonicalR M₁ M₂) (h₂₁ : CanonicalR M₂ M₁) :
    GContent M₁ = GContent M₂ := by
  ext phi
  constructor
  · -- phi ∈ GContent(M₁) means G(phi) ∈ M₁
    -- By temp_4: G(G(phi)) ∈ M₁, so G(phi) ∈ GContent(M₁) ⊆ M₂
    intro h_G_phi_1
    have h_GG := set_mcs_all_future_all_future h_mcs₁ h_G_phi_1
    exact h₁₂ h_GG
  · intro h_G_phi_2
    have h_GG := set_mcs_all_future_all_future h_mcs₂ h_G_phi_2
    exact h₂₁ h_GG

/-!
## Strict Successor and Predecessor Construction

For any MCS M that is NOT temporally forward-saturated (i.e., there exists F(phi) ∈ M
with phi ∉ M), we can construct a strictly distinct future successor.
-/

/--
If F(phi) ∈ M and phi ∉ M, then the canonical_forward_F witness W is distinct from M.

Proof: The witness W is Lindenbaum({phi} ∪ GContent(M)). Since phi ∈ W and phi ∉ M,
we have W ≠ M.
-/
theorem canonical_forward_F_strict (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) (h_not : phi ∉ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ phi ∈ W ∧ W ≠ M := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_forward_F M h_mcs phi h_F
  exact ⟨W, h_W_mcs, h_R, h_phi_W, fun h_eq => h_not (h_eq ▸ h_phi_W)⟩

/--
If P(phi) ∈ M and phi ∉ M, then the canonical_backward_P witness W is distinct from M.
-/
theorem canonical_backward_P_strict (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) (h_not : phi ∉ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR_past M W ∧ phi ∈ W ∧ W ≠ M := by
  obtain ⟨W, h_W_mcs, h_R, h_phi_W⟩ := canonical_backward_P M h_mcs phi h_P
  exact ⟨W, h_W_mcs, h_R, h_phi_W, fun h_eq => h_not (h_eq ▸ h_phi_W)⟩

/-!
## Temporal Duality Helpers for MCS

These lemmas connect the negation of G-formulas to F-formulas in MCS contexts,
using the existing infrastructure from TemporalCoherentConstruction.lean.
-/

/--
If G(phi) ∉ MCS M, then F(neg(phi)) ∈ M.

This combines MCS negation completeness with `neg_all_future_to_some_future_neg`.
-/
theorem canonical_F_neg_from_not_G (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_not_G : Formula.all_future phi ∉ M) :
    Formula.some_future (Formula.neg phi) ∈ M := by
  have h_neg_G : Formula.neg (Formula.all_future phi) ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.all_future phi) with h | h
    · exact absurd h h_not_G
    · exact h
  exact neg_all_future_to_some_future_neg M h_mcs phi h_neg_G

/--
If G(neg(phi)) ∉ MCS M, then F(phi) ∈ M.

This is the key fact: when G(neg(phi)) is not in M, then F(phi) is in M.
Note: F(phi) = neg(G(neg(phi))) by definition.
-/
theorem canonical_F_from_not_G_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_not_G_neg : Formula.all_future (Formula.neg phi) ∉ M) :
    Formula.some_future phi ∈ M := by
  have h_F_eq : Formula.some_future phi = Formula.neg (Formula.all_future (Formula.neg phi)) := rfl
  rw [h_F_eq]
  rcases set_mcs_negation_complete h_mcs (Formula.all_future (Formula.neg phi)) with h | h
  · exact absurd h h_not_G_neg
  · exact h

/--
In any MCS M: either G(phi) ∈ M or F(neg(phi)) ∈ M.

This is the temporal analog of the modal completeness principle.
-/
theorem canonical_G_or_F_neg (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    Formula.all_future phi ∈ M ∨ Formula.some_future (Formula.neg phi) ∈ M := by
  by_cases h : Formula.all_future phi ∈ M
  · exact Or.inl h
  · exact Or.inr (canonical_F_neg_from_not_G M h_mcs phi h)

/-!
## Forward_G Propagation Helpers

Lemmas about how G-formulas propagate through CanonicalR transitions,
and how this interacts with the FMCS forward_G property.
-/

/--
If G(phi) ∈ mcs(t), then phi is at all strictly future times (restated from FMCS).
-/
theorem forward_G_at_future (fam : FMCS Int) (t : Int) (phi : Formula)
    (h_G : Formula.all_future phi ∈ fam.mcs t) :
    ∀ s : Int, t < s → phi ∈ fam.mcs s :=
  fun s h_lt => fam.forward_G t s phi (le_of_lt h_lt) h_G

/--
If phi ∈ mcs(t) and G(phi) ∈ mcs(t), then phi is at all times s > t.
This is the "persistent" case where phi propagates via G.
-/
theorem forward_F_via_G (fam : FMCS Int) (t : Int) (phi : Formula)
    (_h_phi : phi ∈ fam.mcs t) (h_G : Formula.all_future phi ∈ fam.mcs t) :
    ∃ s : Int, t < s ∧ phi ∈ fam.mcs s :=
  ⟨t + 1, by omega, fam.forward_G t (t + 1) phi (by omega) h_G⟩

/-!
## Reachable Fragment Transitivity

If W is reachable from M₀ and W' is a CanonicalR-successor of W, then W' is reachable.
-/

/--
CanonicalR-successors of reachable MCSes are reachable.
-/
def CanonicalReachable.successor (a : CanonicalReachable M₀ h_mcs₀)
    (W : Set Formula) (h_W_mcs : SetMaximalConsistent W) (h_R : CanonicalR a.world W) :
    CanonicalReachable M₀ h_mcs₀ where
  world := W
  is_mcs := h_W_mcs
  reachable := canonicalR_transitive M₀ a.world W h_mcs₀ a.reachable h_R

/-!
## Formula Inconsistency Helpers

Helper lemmas establishing that certain compound formulas cannot be in any MCS.
-/

/--
`phi ∧ neg(phi)` implies `⊥` (derivable).
-/
noncomputable def conj_neg_derives_bot (phi : Formula) :
    [Formula.and phi (Formula.neg phi)] ⊢ Formula.bot := by
  -- and phi (phi.neg) = neg(phi.imp (phi.neg.neg)) = (phi.imp (phi.neg).neg).imp bot
  -- We need to extract phi and neg(phi) from the conjunction
  -- phi.and (phi.neg) = (phi.imp (phi.neg).neg).neg = (phi.imp ((phi.imp bot).imp bot)).imp bot
  -- This is: neg(phi → neg(neg(phi)))
  -- From this we need to derive bot.
  -- By assumption: and(phi, neg(phi)) ∈ context
  have h_conj : [Formula.and phi (Formula.neg phi)] ⊢ Formula.and phi (Formula.neg phi) :=
    DerivationTree.assumption _ _ (by simp)
  -- and(phi, neg(phi)) = neg(phi → neg(neg(phi)))
  -- In propositional logic, phi ∧ neg(phi) → bot is derivable.
  -- phi ∧ neg(phi) = neg(phi.imp (phi.neg.neg))
  -- So our assumption is (phi.imp (phi.neg.neg)).imp bot = neg(phi.imp ((phi.imp bot).imp bot))
  -- Actually Formula.and phi (phi.neg) = (phi.imp (phi.neg).neg).neg
  -- = (phi.imp ((phi.imp bot).imp bot)).imp bot
  -- From this: it's in the context. We need to get phi and neg(phi) separately.
  -- Use the standard derivation: from neg(phi → neg(neg(phi))), derive phi and neg(phi).
  -- Actually, let me use Bimodal.Metalogic.set_mcs_conjunction_elim style reasoning.
  -- But that's for MCS, not for derivation.
  -- We need: [a ∧ b] ⊢ a and [a ∧ b] ⊢ b.
  -- a ∧ b = neg(a → neg(b))
  -- From neg(a → neg(b)), we can derive a:
  --   Suppose neg(a). Then a → neg(b) (by ex falso from a and neg(a)).
  --   But neg(a → neg(b)). Contradiction.
  -- This requires the conjunction elimination derivations.
  -- Let me use a simpler approach: derive bot from conj directly.
  -- neg(phi → neg(neg(phi))):
  -- If phi → neg(neg(phi)) then combined with our assumption neg(phi → neg(neg(phi))) we get bot.
  -- phi → neg(neg(phi)) is derivable (intro double negation).
  -- So: derives (phi.imp (phi.neg.neg)) from empty context (double neg intro).
  have h_dni : [] ⊢ phi.imp (Formula.neg phi).neg := by
    -- phi → neg(neg(phi)) i.e. phi → ((phi → bot) → bot)
    -- This is provable: assume phi and (phi → bot), derive bot by modus ponens.
    -- So phi → ((phi → bot) → bot) i.e. phi → neg(neg(phi)).
    -- Use prop_k and prop_s to build this, or use the Combinators/Propositional theorems.
    -- Actually: phi.neg.neg = (phi.imp bot).imp bot
    -- We want: phi → (phi.imp bot).imp bot
    -- By deduction theorem twice: from [phi, phi.imp bot] derive bot.
    -- Build [phi.imp bot, phi] ⊢ bot via modus ponens
    have h_bot : [phi.imp Formula.bot, phi] ⊢ Formula.bot := by
      have h_phi := DerivationTree.assumption [phi.imp Formula.bot, phi] phi
        (List.mem_cons.mpr (Or.inr (List.mem_cons.mpr (Or.inl rfl))))
      have h_neg := DerivationTree.assumption [phi.imp Formula.bot, phi] (phi.imp Formula.bot)
        (List.mem_cons.mpr (Or.inl rfl))
      exact DerivationTree.modus_ponens _ _ _ h_neg h_phi
    -- Deduction theorem: [phi] ⊢ (phi → bot) → bot
    have h_ded1 := Bimodal.Metalogic.Core.deduction_theorem [phi] (phi.imp Formula.bot) Formula.bot h_bot
    -- Deduction theorem: [] ⊢ phi → ((phi → bot) → bot)
    exact Bimodal.Metalogic.Core.deduction_theorem [] phi ((phi.imp Formula.bot).imp Formula.bot) h_ded1
  -- Weaken h_dni to our context
  have h_dni_ctx : [Formula.and phi (Formula.neg phi)] ⊢ phi.imp (Formula.neg phi).neg :=
    DerivationTree.weakening [] _ _ h_dni (by intro; simp)
  -- Now: Formula.and phi (phi.neg) = (phi.imp (phi.neg).neg).neg
  -- So h_conj : context ⊢ (phi.imp (phi.neg).neg).neg
  -- And h_dni_ctx : context ⊢ phi.imp (phi.neg).neg
  -- Modus ponens of h_conj (which is neg of h_dni_ctx's conclusion) on h_dni_ctx:
  -- h_conj has type (phi.imp (phi.neg).neg).imp bot
  -- h_dni_ctx has type phi.imp (phi.neg).neg
  -- MP gives bot.
  exact DerivationTree.modus_ponens _ _ _ h_conj h_dni_ctx

/--
F(phi ∧ neg(phi)) is not in any MCS.

Since phi ∧ neg(phi) → ⊥ is derivable, G(neg(phi ∧ neg(phi))) is provable
(by temporal necessitation of neg(phi ∧ neg(phi)), which follows from ⊥ → anything applied to
the derivation of ⊥ from phi ∧ neg(phi)).
-/
theorem F_conj_neg_not_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) :
    Formula.some_future (Formula.and phi (Formula.neg phi)) ∉ M := by
  intro h_F
  -- Get witness W with phi ∧ neg(phi) ∈ W
  obtain ⟨W, h_W_mcs, _, h_mem⟩ := canonical_forward_F M h_mcs _ h_F
  -- Extract phi and neg(phi) from the conjunction
  have h_parts := Bimodal.Metalogic.set_mcs_conjunction_elim h_W_mcs h_mem
  -- phi and neg(phi) in the same MCS contradicts consistency
  exact set_consistent_not_both h_W_mcs.1 phi h_parts.1 h_parts.2

end Bimodal.Metalogic.Bundle
