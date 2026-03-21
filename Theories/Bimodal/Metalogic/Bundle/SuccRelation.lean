import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Succ Relation for Discrete Temporal Frames

This module defines the Succ (immediate successor) relation for discrete temporal frames.
Succ(u,v) captures when v is the "next" state after u, requiring both G-persistence
(same as CanonicalR) and F-step (F-obligations resolve or defer).

## Main Definitions

- `Succ u v`: Immediate successor relation combining g_content and f_content conditions

## Main Theorems

- `Succ_implies_CanonicalR`: Succ implies the canonical future relation
- `Succ_implies_h_content_reverse`: g/h duality for Succ pairs
- `single_step_forcing`: Key theorem connecting F-nesting depth to witness distance

## Design

The Succ relation is foundational infrastructure for the discrete track (tasks 10-15).
It captures the notion of an "immediate next step" in a discrete temporal frame where
each F-obligation is either satisfied at the next state or properly deferred.

**Condition (1)**: G-persistence - `g_content u ⊆ v`
  All universal future commitments propagate to the successor.

**Condition (2)**: F-step - `f_content u ⊆ v ∪ f_content v`
  Every existential obligation is either resolved at v (φ ∈ v) or deferred (Fφ ∈ v).

## References

- Task 10 research report: 01_succ-relation-research.md
- Goldblatt 1992, Logics of Time and Computation
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Succ Definition
-/

/--
Immediate successor relation: u sees v as its next state.

**Condition (1)**: G-persistence - all universal future commitments propagate.
This is exactly the CanonicalR relation: `g_content u ⊆ v`.

**Condition (2)**: F-step - existential obligations are resolved or deferred.
For each φ with Fφ ∈ u, either φ ∈ v (resolved) or Fφ ∈ v (deferred).
Formally: `f_content u ⊆ v ∪ f_content v`.
-/
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v

/-!
## Accessor Theorems
-/

/--
G-persistence: Extract the first condition from Succ.
-/
theorem Succ.g_persistence {u v : Set Formula} (h : Succ u v) : g_content u ⊆ v := h.1

/--
F-step: Extract the second condition from Succ.
Every formula in f_content(u) is either in v directly (resolved) or in f_content(v) (deferred).
-/
theorem Succ.f_step {u v : Set Formula} (h : Succ u v) : f_content u ⊆ v ∪ f_content v := h.2

/-!
## Relationship to CanonicalR
-/

/--
Succ implies CanonicalR: The first condition of Succ is exactly CanonicalR.

This is trivial by projection: Succ condition (1) is `g_content u ⊆ v`,
which is the definition of `CanonicalR u v`.
-/
theorem Succ_implies_CanonicalR (u v : Set Formula) (h : Succ u v) :
    CanonicalR u v := h.1

/-!
## g/h Duality for Succ
-/

/--
g/h Duality: If Succ u v, then h_content v ⊆ u.

This follows from the G-persistence condition of Succ (g_content u ⊆ v) via the
existing duality theorem `g_content_subset_implies_h_content_reverse` from WitnessSeed.lean.

The duality uses axiom temp_a: φ → G(P(φ)).
-/
theorem Succ_implies_h_content_reverse
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (h_succ : Succ u v) :
    h_content v ⊆ u :=
  g_content_subset_implies_h_content_reverse u v h_mcs_u h_mcs_v h_succ.1

/-!
## Auxiliary Lemmas for Single-Step Forcing
-/

/--
G(neg phi) in MCS implies F(phi) not in MCS.

Since `F phi = neg(G(neg phi))`, having both `G(neg phi)` and `F(phi)` in M
would mean having both `G(neg phi)` and `neg(G(neg phi))` in M, contradicting consistency.
-/
lemma G_neg_implies_not_F (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula)
    (h_G_neg : Formula.all_future phi.neg ∈ M) :
    Formula.some_future phi ∉ M := by
  -- F(phi) = neg(G(neg phi)) by definition
  intro h_F
  have h_eq : Formula.some_future phi = (Formula.all_future phi.neg).neg := rfl
  rw [h_eq] at h_F
  exact set_consistent_not_both h_mcs.1 (Formula.all_future phi.neg) h_G_neg h_F

/--
neg(FF(phi)) in MCS implies GG(neg(phi)) in MCS.

Proof uses DNE inside G (necessitation of `neg neg A -> A`).
The key is that `neg(F(F(phi)))` simplifies to a form that can be transformed
to `G(G(neg phi))` using provability.

We have:
- F(phi) = neg(G(neg(phi)))  [def some_future]
- neg(F(phi)) = neg(neg(G(neg(phi)))) = G(neg(phi)).neg.neg
- G(neg(phi)).neg.neg -> G(neg(phi)) is provable (DNE)

So neg(FF(phi)) contains a double negation that can be eliminated.
-/
lemma neg_FF_implies_GG_neg_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula)
    (h_neg_FF : (Formula.some_future (Formula.some_future phi)).neg ∈ M) :
    Formula.all_future (Formula.all_future phi.neg) ∈ M := by
  -- neg(FF(phi)) has structure: (phi.neg.all_future.neg).neg.all_future.neg.neg
  -- We want: phi.neg.all_future.all_future
  --
  -- Step 1: Expand neg(F(F(phi)))
  -- F(psi) = psi.neg.all_future.neg, so F(F(phi)) = (phi.neg.all_future.neg).neg.all_future.neg
  -- neg(F(F(phi))) = (phi.neg.all_future.neg).neg.all_future.neg.neg
  --
  -- Step 2: Use the provable implication:
  -- We can derive: G(neg(F(phi))) -> G(G(neg(phi)))
  -- Because neg(F(phi)) = G(neg(phi)).neg.neg, and we have G(x.neg.neg) -> G(x) provable
  --
  -- Let's work out the structure:
  -- Let psi = phi.neg.all_future  (this is G(neg(phi)))
  -- Then F(phi) = psi.neg = G(neg(phi)).neg
  -- So neg(F(phi)) = psi.neg.neg = G(neg(phi)).neg.neg
  -- F(F(phi)) = (psi.neg).neg.all_future.neg = psi.neg.neg.all_future.neg
  -- neg(F(F(phi))) = psi.neg.neg.all_future.neg.neg = G(neg(phi)).neg.neg.all_future.neg.neg
  --
  -- What we have: G(neg(phi)).neg.neg.all_future.neg.neg ∈ M
  -- What we want: G(neg(phi)).all_future ∈ M
  --
  -- Provable implications:
  -- 1. x.neg.neg -> x (DNE)
  -- 2. G(A -> B) -> (G(A) -> G(B)) (K axiom)
  -- 3. A -> G(A) if A is a theorem (necessitation)
  --
  -- From x.neg.neg.all_future.neg.neg, we can derive:
  -- x.neg.neg.all_future (by DNE on the outer neg.neg)
  -- Then from G(x.neg.neg), we need G(x). This requires G_dne: ⊢ G(x.neg.neg) -> G(x)
  --
  -- Let's prove it via the chain:
  -- h_neg_FF : G(neg(phi)).neg.neg.all_future.neg.neg ∈ M
  --
  -- Step A: Apply DNE to get G(neg(phi)).neg.neg.all_future ∈ M
  have h_inner : (phi.neg.all_future.neg).neg.all_future ∈ M := by
    -- The current formula is: G(neg(phi)).neg.neg.all_future.neg.neg
    -- We have: ⊢ x.neg.neg -> x (DNE)
    -- Apply to x = G(neg(phi)).neg.neg.all_future
    have h_dne : [] ⊢ ((phi.neg.all_future.neg).neg.all_future.neg).neg.imp
                      (phi.neg.all_future.neg).neg.all_future :=
      Bimodal.Theorems.Propositional.double_negation _
    exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_dne) h_neg_FF

  -- Step B: Now we have G(G(neg(phi)).neg.neg) ∈ M
  -- Note: (phi.neg.all_future.neg).neg.all_future = G((phi.neg.all_future).neg.neg) = G(G(neg(phi)).neg.neg)
  -- We need G(G(neg(phi))) = phi.neg.all_future.all_future
  --
  -- Use: ⊢ G(x.neg.neg) -> G(x) (G_dne)
  -- This is: ⊢ G(x.neg.neg -> x) (by necessitation of DNE)
  --         then: ⊢ G(x.neg.neg -> x) -> (G(x.neg.neg) -> G(x)) (by K)
  --         so: ⊢ G(x.neg.neg) -> G(x)
  have h_G_dne : [] ⊢ (phi.neg.all_future.neg).neg.all_future.imp (phi.neg.all_future.all_future) := by
    -- Prove: G(G(neg(phi)).neg.neg) -> G(G(neg(phi)))
    -- i.e., G(x.neg.neg) -> G(x) where x = phi.neg.all_future
    have h_dne_inner : [] ⊢ (phi.neg.all_future).neg.neg.imp (phi.neg.all_future) :=
      Bimodal.Theorems.Propositional.double_negation _
    have h_nec : [] ⊢ ((phi.neg.all_future).neg.neg.imp (phi.neg.all_future)).all_future :=
      Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ h_dne_inner
    have h_k : [] ⊢ ((phi.neg.all_future).neg.neg.imp (phi.neg.all_future)).all_future.imp
                    ((phi.neg.all_future).neg.neg.all_future.imp (phi.neg.all_future).all_future) :=
      Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_k_dist _ _)
    exact Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_k h_nec

  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_G_dne) h_inner

/-!
## Single-Step Forcing Theorem
-/

/--
Single-step forcing theorem: The key result connecting F-nesting depth to witness distance.

If `F(phi) ∈ u` and `FF(phi) ∉ u` and `Succ u v`, then `phi ∈ v`.

**Intuition**: When we have `F(phi)` at u but not `FF(phi)`, the F-obligation must be
resolved exactly one step away. Since `v` is the immediate successor of `u`, `phi` must
hold at `v`.

**Proof Outline**:
1. `FF(phi) ∉ u` → `neg(FF(phi)) ∈ u` by negation completeness
2. `neg(FF(phi)) ∈ u` → `GG(neg(phi)) ∈ u` by formula manipulation (neg_FF_implies_GG_neg_in_mcs)
3. `GG(neg(phi)) ∈ u` → `G(neg(phi)) ∈ g_content(u)`
4. `G(neg(phi)) ∈ v` by G-persistence (Succ condition 1)
5. `G(neg(phi)) ∈ v` → `F(phi) ∉ v` by G_neg_implies_not_F
6. By F-step (Succ condition 2): `phi ∈ f_content(u)` implies `phi ∈ v ∨ phi ∈ f_content(v)`
7. Since `F(phi) ∉ v`, we have `phi ∉ f_content(v)`
8. Therefore `phi ∈ v`
-/
theorem single_step_forcing
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ u)
    (h_FF_not : Formula.some_future (Formula.some_future phi) ∉ u)
    (h_succ : Succ u v) :
    phi ∈ v := by
  -- Step 1: FF(phi) ∉ u → neg(FF(phi)) ∈ u by negation completeness
  have h_neg_FF : (Formula.some_future (Formula.some_future phi)).neg ∈ u := by
    cases SetMaximalConsistent.negation_complete h_mcs_u (Formula.some_future (Formula.some_future phi)) with
    | inl h_in => exact absurd h_in h_FF_not
    | inr h_neg => exact h_neg

  -- Step 2: neg(FF(phi)) ∈ u → GG(neg(phi)) ∈ u
  have h_GG_neg : Formula.all_future (Formula.all_future phi.neg) ∈ u :=
    neg_FF_implies_GG_neg_in_mcs u h_mcs_u phi h_neg_FF

  -- Step 3: GG(neg(phi)) ∈ u → G(neg(phi)) ∈ g_content(u)
  have h_G_neg_in_g : Formula.all_future phi.neg ∈ g_content u := h_GG_neg

  -- Step 4: G(neg(phi)) ∈ v by G-persistence
  have h_G_neg_in_v : Formula.all_future phi.neg ∈ v := h_succ.1 h_G_neg_in_g

  -- Step 5: G(neg(phi)) ∈ v → F(phi) ∉ v
  have h_F_not_v : Formula.some_future phi ∉ v :=
    G_neg_implies_not_F v h_mcs_v phi h_G_neg_in_v

  -- Step 6: phi ∈ f_content(u), so by F-step: phi ∈ v ∨ phi ∈ f_content(v)
  have h_phi_in_f_content_u : phi ∈ f_content u := h_F
  have h_union : phi ∈ v ∪ f_content v := h_succ.2 h_phi_in_f_content_u

  -- Step 7-8: Since F(phi) ∉ v, we have phi ∉ f_content(v), so phi ∈ v
  rcases Set.mem_or_mem_of_mem_union h_union with h_in_v | h_in_f_v
  · exact h_in_v
  · -- h_in_f_v : phi ∈ f_content v means F(phi) ∈ v
    -- But we have h_F_not_v : F(phi) ∉ v
    exact absurd h_in_f_v h_F_not_v

end Bimodal.Metalogic.Bundle
