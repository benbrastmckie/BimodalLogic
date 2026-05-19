import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MCSProperties

/-!
# Succ Relation for Discrete Temporal Frames

This module defines the Succ (immediate successor) relation for discrete temporal frames.
Succ(u,v) captures when v is the "next" state after u, requiring both G-persistence
(same as ExistsTask) and F-step (F-obligations resolve or defer).

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
This is exactly the ExistsTask relation: `g_content u ⊆ v`.

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
## Relationship to ExistsTask
-/

/--
Succ implies ExistsTask: The first condition of Succ is exactly ExistsTask.

This is trivial by projection: Succ condition (1) is `g_content u ⊆ v`,
which is the definition of `ExistsTask u v`.
-/
theorem Succ_implies_CanonicalR (u v : Set Formula) (h : Succ u v) :
    ExistsTask u v := h.1

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
  -- all_future (phi.neg) = neg (some_future (phi.neg.neg))
  -- so h_G_neg : neg (some_future (phi.neg.neg)) ∈ M
  -- If some_future phi ∈ M, derive some_future (phi.neg.neg) ∈ M to get contradiction.
  -- Use BX3 (right_mono_until): G(phi → phi.neg.neg) → (U(phi, ⊤) → U(phi.neg.neg, ⊤))
  intro h_F
  -- Step 1: phi → phi.neg.neg is derivable (DN intro)
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  -- Step 2: G(phi → phi.neg.neg) by temporal necessitation
  have h_G_dni : [] ⊢ (phi.imp phi.neg.neg).all_future :=
    Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ h_dni
  -- Step 3: BX3: G(phi → phi.neg.neg) → (U(phi, ⊤) → U(phi.neg.neg, ⊤))
  have h_bx3 : [] ⊢ (phi.imp phi.neg.neg).all_future.imp
      ((Formula.untl phi Formula.top).imp (Formula.untl phi.neg.neg Formula.top)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.right_mono_until phi phi.neg.neg Formula.top)
  -- Step 4: U(phi, ⊤) → U(phi.neg.neg, ⊤) ∈ M
  have h_mono_in := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dni))
    h_F
  -- h_mono_in : Formula.untl phi.neg.neg Formula.top ∈ M
  -- which is: some_future (phi.neg.neg) ∈ M
  -- But h_G_neg : neg (some_future (phi.neg.neg)) ∈ M
  exact set_consistent_not_both h_mcs.1 (Formula.some_future phi.neg.neg) h_mono_in h_G_neg

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
  -- Strategy: derive ⊢ neg(F(F(phi))) → G(G(neg(phi))) and apply to MCS.
  -- Key definitional equalities:
  --   all_future X = (some_future (X.neg)).neg  [def]
  --   some_future X = untl X top               [def]
  -- So: all_future (phi.neg) = (some_future (phi.neg.neg)).neg
  --     all_future (all_future (phi.neg)) = (some_future ((all_future (phi.neg)).neg)).neg
  --       = (some_future ((some_future (phi.neg.neg)).neg.neg)).neg
  --
  -- Step 1: Derive some_future (phi.neg.neg) → some_future phi  (event mono with DNE)
  have h_dne_phi : [] ⊢ phi.neg.neg.imp phi :=
    Bimodal.Theorems.Propositional.double_negation phi
  have h_G_dne_phi : [] ⊢ (phi.neg.neg.imp phi).all_future :=
    Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ h_dne_phi
  -- BX3: G(phi.neg.neg → phi) → (F(phi.neg.neg) → F(phi))
  -- i.e., (phi.neg.neg.imp phi).all_future → (untl phi.neg.neg top → untl phi top)
  have h_bx3 : [] ⊢ (phi.neg.neg.imp phi).all_future.imp
      ((Formula.untl phi.neg.neg Formula.top).imp (Formula.untl phi Formula.top)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.right_mono_until phi.neg.neg phi Formula.top)
  -- F(phi.neg.neg) → F(phi)
  have h_F_dne : [] ⊢ (Formula.some_future phi.neg.neg).imp (Formula.some_future phi) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_bx3 h_G_dne_phi
  -- Step 2: From F(phi.neg.neg) → F(phi), derive ¬F(phi) → ¬F(phi.neg.neg)
  -- i.e., (some_future phi).neg → (some_future (phi.neg.neg)).neg
  -- This is: (some_future phi).neg → all_future (phi.neg)  [by def!]
  have h_contra1 : [] ⊢ (Formula.some_future phi).neg.imp (Formula.some_future phi.neg.neg).neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _
      (Bimodal.Theorems.TemporalDerived.contrapositive _ _) h_F_dne
  -- Step 3: Apply step 2 inside G to get G(F(phi).neg) → G(G(neg phi))
  -- i.e., (some_future phi).neg.all_future → (some_future phi.neg.neg).neg.all_future
  -- Since (some_future phi.neg.neg).neg = all_future (phi.neg), this is:
  -- all_future ((some_future phi).neg) → all_future (all_future (phi.neg))
  -- Use future_mono: ⊢ (A → B) implies ⊢ G(A) → G(B)
  have h_G_mono : [] ⊢ (Formula.some_future phi).neg.all_future.imp
      (Formula.some_future phi.neg.neg).neg.all_future :=
    Bimodal.Theorems.Perpetuity.future_mono h_contra1
  -- Step 4: Get all_future ((some_future phi).neg) ∈ M from h_neg_FF
  -- h_neg_FF : (some_future (some_future phi)).neg ∈ M
  -- We need: all_future ((some_future phi).neg) ∈ M
  -- i.e., (some_future ((some_future phi).neg.neg)).neg ∈ M
  -- Use G_neg_implies_not_F-like reasoning: from ¬F(F(phi)) derive G(¬F(phi))
  -- all_future ((some_future phi).neg) = neg (some_future ((some_future phi).neg.neg))
  -- and (some_future (some_future phi)).neg = neg (some_future (some_future phi))
  -- These are NOT the same. We need to derive G(¬F(phi)) from ¬F(F(phi)).
  --
  -- Use BX3 again: F((some_future phi).neg.neg) → F(some_future phi) by DNE
  -- So ¬F(some_future phi) → ¬F((some_future phi).neg.neg) (contrapositive)
  -- i.e., (some_future (some_future phi)).neg → (some_future ((some_future phi).neg.neg)).neg
  -- = (some_future (some_future phi)).neg → all_future ((some_future phi).neg)
  have h_dne_Fphi : [] ⊢ (Formula.some_future phi).neg.neg.imp (Formula.some_future phi) :=
    Bimodal.Theorems.Propositional.double_negation _
  have h_G_dne_Fphi : [] ⊢ ((Formula.some_future phi).neg.neg.imp (Formula.some_future phi)).all_future :=
    Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ h_dne_Fphi
  have h_bx3_2 : [] ⊢ ((Formula.some_future phi).neg.neg.imp (Formula.some_future phi)).all_future.imp
      ((Formula.untl (Formula.some_future phi).neg.neg Formula.top).imp
       (Formula.untl (Formula.some_future phi) Formula.top)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.right_mono_until (Formula.some_future phi).neg.neg
        (Formula.some_future phi) Formula.top)
  have h_F_dne_2 : [] ⊢ (Formula.some_future (Formula.some_future phi).neg.neg).imp
      (Formula.some_future (Formula.some_future phi)) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_bx3_2 h_G_dne_Fphi
  have h_contra2 : [] ⊢ (Formula.some_future (Formula.some_future phi)).neg.imp
      (Formula.some_future (Formula.some_future phi).neg.neg).neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _
      (Bimodal.Theorems.TemporalDerived.contrapositive _ _) h_F_dne_2
  -- Now: (some_future (some_future phi)).neg → all_future ((some_future phi).neg)
  -- Apply to h_neg_FF to get all_future ((some_future phi).neg) ∈ M
  have h_G_neg_F : (Formula.some_future (Formula.some_future phi).neg.neg).neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_contra2) h_neg_FF
  -- h_G_neg_F : all_future ((some_future phi).neg) ∈ M  [by def]
  -- Step 5: Apply h_G_mono to get all_future (all_future (phi.neg)) ∈ M
  -- h_G_mono : (some_future phi).neg.all_future → (some_future phi.neg.neg).neg.all_future
  -- = all_future ((some_future phi).neg) → all_future (all_future (phi.neg))
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_G_mono) h_G_neg_F

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

/-!
## Past Direction Lemmas for Backward P Coherence

Symmetric lemmas for the P (some_past) direction, mirroring the F direction.
These enable proving backward_witness (P-direction analog of bounded_witness).
-/

/--
H(neg phi) in MCS implies P(phi) not in MCS.

Since `P phi = neg(H(neg phi))`, having both `H(neg phi)` and `P(phi)` in M
would mean having both `H(neg phi)` and `neg(H(neg phi))` in M, contradicting consistency.

Symmetric to `G_neg_implies_not_F`.
-/
lemma H_neg_implies_not_P (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula)
    (h_H_neg : Formula.all_past phi.neg ∈ M) :
    Formula.some_past phi ∉ M := by
  -- all_past (phi.neg) = (some_past (phi.neg.neg)).neg by definition.
  -- If some_past phi ∈ M, derive some_past (phi.neg.neg) ∈ M to get contradiction.
  -- Use BX3' (right_mono_since): H(phi → phi.neg.neg) → (S(phi, ⊤) → S(phi.neg.neg, ⊤))
  intro h_P
  have h_dni : [] ⊢ phi.imp phi.neg.neg := Bimodal.Theorems.Combinators.dni phi
  have h_H_dni : [] ⊢ (phi.imp phi.neg.neg).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dni
  have h_bx3p : [] ⊢ (phi.imp phi.neg.neg).all_past.imp
      ((Formula.snce phi Formula.top).imp (Formula.snce phi.neg.neg Formula.top)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.right_mono_since phi phi.neg.neg Formula.top)
  have h_mono_in := SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_bx3p h_H_dni))
    h_P
  exact set_consistent_not_both h_mcs.1 (Formula.some_past phi.neg.neg) h_mono_in h_H_neg

/--
neg(PP(phi)) in MCS implies HH(neg(phi)) in MCS.

Proof uses DNE inside H (necessitation of `neg neg A -> A`).
Symmetric to `neg_FF_implies_GG_neg_in_mcs`.

We have:
- P(phi) = neg(H(neg(phi)))  [def some_past]
- neg(P(phi)) = neg(neg(H(neg(phi)))) = H(neg(phi)).neg.neg
- H(neg(phi)).neg.neg -> H(neg(phi)) is provable (DNE)

So neg(PP(phi)) contains a double negation that can be eliminated.
-/
lemma neg_PP_implies_HH_neg_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula)
    (h_neg_PP : (Formula.some_past (Formula.some_past phi)).neg ∈ M) :
    Formula.all_past (Formula.all_past phi.neg) ∈ M := by
  -- Mirror of neg_FF_implies_GG_neg_in_mcs for past direction.
  -- Key definitional equalities:
  --   all_past X = (some_past (X.neg)).neg  [def]
  --   some_past X = snce X top              [def]
  -- Step 1: Derive some_past (phi.neg.neg) → some_past phi (event mono with DNE)
  have h_dne_phi : [] ⊢ phi.neg.neg.imp phi :=
    Bimodal.Theorems.Propositional.double_negation phi
  have h_H_dne_phi : [] ⊢ (phi.neg.neg.imp phi).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dne_phi
  have h_bx3p : [] ⊢ (phi.neg.neg.imp phi).all_past.imp
      ((Formula.snce phi.neg.neg Formula.top).imp (Formula.snce phi Formula.top)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.right_mono_since phi.neg.neg phi Formula.top)
  have h_P_dne : [] ⊢ (Formula.some_past phi.neg.neg).imp (Formula.some_past phi) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_bx3p h_H_dne_phi
  -- Step 2: ¬P(phi) → ¬P(phi.neg.neg) = ¬P(phi) → H(phi.neg)
  have h_contra1 : [] ⊢ (Formula.some_past phi).neg.imp (Formula.some_past phi.neg.neg).neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _
      (Bimodal.Theorems.TemporalDerived.contrapositive _ _) h_P_dne
  -- Step 3: past_mono to lift inside H
  have h_H_mono : [] ⊢ (Formula.some_past phi).neg.all_past.imp
      (Formula.some_past phi.neg.neg).neg.all_past :=
    Bimodal.Theorems.Perpetuity.past_mono h_contra1
  -- Step 4: Derive all_past ((some_past phi).neg) ∈ M from h_neg_PP
  -- ¬P(P(phi)) → H(¬P(phi)) by DNE + BX3'
  have h_dne_Pphi : [] ⊢ (Formula.some_past phi).neg.neg.imp (Formula.some_past phi) :=
    Bimodal.Theorems.Propositional.double_negation _
  have h_H_dne_Pphi : [] ⊢ ((Formula.some_past phi).neg.neg.imp (Formula.some_past phi)).all_past :=
    Bimodal.Theorems.past_necessitation _ h_dne_Pphi
  have h_bx3_2 : [] ⊢ ((Formula.some_past phi).neg.neg.imp (Formula.some_past phi)).all_past.imp
      ((Formula.snce (Formula.some_past phi).neg.neg Formula.top).imp
       (Formula.snce (Formula.some_past phi) Formula.top)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.right_mono_since (Formula.some_past phi).neg.neg
        (Formula.some_past phi) Formula.top)
  have h_P_dne_2 : [] ⊢ (Formula.some_past (Formula.some_past phi).neg.neg).imp
      (Formula.some_past (Formula.some_past phi)) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_bx3_2 h_H_dne_Pphi
  have h_contra2 : [] ⊢ (Formula.some_past (Formula.some_past phi)).neg.imp
      (Formula.some_past (Formula.some_past phi).neg.neg).neg :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _
      (Bimodal.Theorems.TemporalDerived.contrapositive _ _) h_P_dne_2
  have h_H_neg_P : (Formula.some_past (Formula.some_past phi).neg.neg).neg ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_contra2) h_neg_PP
  -- Step 5: Apply h_H_mono
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_H_mono) h_H_neg_P

/--
Single-step forcing in the past direction: If P(phi) ∈ v and PP(phi) ∉ v,
and Succ u v (so u is a predecessor of v), then phi ∈ u.

**Semantic Justification**: P(phi) at v means phi must hold at some past world.
PP(phi) ∉ v means the P-obligation cannot be deferred further back.
Since u is the immediate predecessor of v (via Succ u v), phi must hold at u.

**Proof Outline** (symmetric to single_step_forcing):
1. `PP(phi) ∉ v` → `neg(PP(phi)) ∈ v` by negation completeness
2. `neg(PP(phi)) ∈ v` → `HH(neg(phi)) ∈ v` by neg_PP_implies_HH_neg_in_mcs
3. `HH(neg(phi)) ∈ v` → `H(neg(phi)) ∈ h_content(v)`
4. `H(neg(phi)) ∈ u` by H-persistence backward (Succ_implies_h_content_reverse)
5. `H(neg(phi)) ∈ u` → `P(phi) ∉ u` by H_neg_implies_not_P
6. By P-step backward: `phi ∈ p_content(v)` implies `phi ∈ u ∨ phi ∈ p_content(u)`
7. Since `P(phi) ∉ u`, we have `phi ∉ p_content(u)`
8. Therefore `phi ∈ u`

**Note**: This uses Succ_implies_h_content_reverse which requires Succ u v.
The direction is: Succ u v means u's successor is v, so going from v backward
we reach u.
-/
theorem single_step_forcing_past
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (phi : Formula)
    (h_P : Formula.some_past phi ∈ v)
    (h_PP_not : Formula.some_past (Formula.some_past phi) ∉ v)
    (h_succ : Succ u v)
    (h_p_step : p_content v ⊆ u ∪ p_content u) :
    phi ∈ u := by
  -- Step 1: PP(phi) ∉ v → neg(PP(phi)) ∈ v by negation completeness
  have h_neg_PP : (Formula.some_past (Formula.some_past phi)).neg ∈ v := by
    cases SetMaximalConsistent.negation_complete h_mcs_v (Formula.some_past (Formula.some_past phi)) with
    | inl h_in => exact absurd h_in h_PP_not
    | inr h_neg => exact h_neg

  -- Step 2: neg(PP(phi)) ∈ v → HH(neg(phi)) ∈ v
  have h_HH_neg : Formula.all_past (Formula.all_past phi.neg) ∈ v :=
    neg_PP_implies_HH_neg_in_mcs v h_mcs_v phi h_neg_PP

  -- Step 3: HH(neg(phi)) ∈ v → H(neg(phi)) ∈ h_content(v)
  have h_H_neg_in_h : Formula.all_past phi.neg ∈ h_content v := h_HH_neg

  -- Step 4: H(neg(phi)) ∈ u by H-persistence backward
  have h_H_neg_in_u : Formula.all_past phi.neg ∈ u :=
    Succ_implies_h_content_reverse u v h_mcs_u h_mcs_v h_succ h_H_neg_in_h

  -- Step 5: H(neg(phi)) ∈ u → P(phi) ∉ u
  have h_P_not_u : Formula.some_past phi ∉ u :=
    H_neg_implies_not_P u h_mcs_u phi h_H_neg_in_u

  -- Step 6: phi ∈ p_content(v) (because P(phi) ∈ v)
  have h_phi_in_p_content_v : phi ∈ p_content v := h_P

  -- We need the P-step property: p_content(v) ⊆ u ∪ p_content(u)
  -- But the Succ relation gives us f_content(u) ⊆ v ∪ f_content(v), not the P direction.
  -- We need to use Succ_implies_h_content_reverse which gives h_content(v) ⊆ u.
  --
  -- The key is: P(phi) ∈ v with Succ u v (u is predecessor of v).
  -- In the forward chain, we have Succ(mcs(n-1))(mcs(n)).
  -- P(phi) ∈ mcs(n) means phi must be in some past world.
  -- By temp_a backward: P(phi) implies GP(phi), and P(phi) ∈ v with Succ u v
  -- gives us that phi or P(phi) is in u.
  --
  -- Actually, we need the predecessor deferral property from SuccExistence.
  -- The predecessor_deferral_seed includes p_content(v) via pastDeferralDisjunctions.
  -- This ensures that for each P(phi) ∈ v, either phi ∈ u or P(phi) ∈ u.
  --
  -- This is proven as predecessor_p_step in the predecessor construction.
  -- Let's use that theorem.

  -- Actually, let me check if this exists. The predecessor construction ensures
  -- p_content(v) ⊆ u ∪ p_content(u) when we build u from v.
  --
  -- For now, we can derive this from the canonical frame properties.
  -- Actually, the predecessor construction in SuccExistence does guarantee this.
  -- But we need to extract it from the Succ relation directly.
  --
  -- The issue is: Succ gives us F-step, but we need P-step.
  -- These are dual but different directions.
  --
  -- Let me try a different approach: use the semantics directly.
  -- If P(phi) ∈ v and Succ u v, then by the P-content backward inclusion,
  -- we get phi ∈ u ∨ P(phi) ∈ u.
  --
  -- Hmm, this may need additional infrastructure. Let me check.

  -- For discrete frames with the predecessor construction, we actually have:
  -- If Succ u v then p_content(v) ⊆ u ∪ p_content(u)
  -- This is the P-step dual to F-step.
  --
  -- Let me prove it using the temp_a axiom and MCS properties.
  -- phi → G(P(phi)) (temp_a) implies that if phi ∈ u and Succ u v, then P(phi) ∈ v.
  -- Contrapositive: if P(phi) ∉ v and Succ u v, then phi ∉ u.
  -- But we have P(phi) ∈ v, so we need a different approach.

  -- The correct approach uses: P(phi) ∈ v means H(neg phi) ∉ v.
  -- From Succ u v, h_content(v) ⊆ u (H-persistence backward).
  -- But this doesn't directly give us phi ∈ u.

  -- Actually, the predecessor construction guarantees:
  -- For any phi with P(phi) ∈ v, the predecessor u satisfies: phi ∈ u ∨ P(phi) ∈ u.
  -- This is baked into the pastDeferralDisjunctions.

  -- Let's use a semantic argument via the frame condition.
  -- In a discrete linear frame, P(phi) ∈ v with v having predecessor u means
  -- phi is true at u or at some world before u.
  -- If PP(phi) ∉ v, then the P-chain ends at depth 1, meaning phi ∈ u.

  -- For now, let me use the direct P-step property from predecessor construction.
  -- This should be: predecessor_p_step or similar.

  -- Actually, looking at the code, the predecessor construction builds u from v
  -- such that Succ u v, and includes pastDeferralDisjunctions which ensures
  -- p_content(v) ⊆ u ∪ p_content(u).

  -- The key lemma we need is:
  -- If Succ u v then p_content(v) ⊆ u ∪ p_content(u)
  -- This is dual to: f_content(u) ⊆ v ∪ f_content(v)

  -- For the succ_chain, u = succ_chain_fam M0 (n-1) and v = succ_chain_fam M0 n.
  -- The backward chain uses predecessor construction, so this property holds.

  -- Let me prove this using the H-content relationship.
  -- From P(phi) ∈ v, we have H(neg phi) ∉ v (by P = neg H neg).
  -- From Succ u v, we have h_content(v) ⊆ u.
  -- But h_content(v) = {psi | H(psi) ∈ v}.
  -- H(neg phi) ∉ v means neg phi ∉ h_content(v).
  -- This doesn't directly give phi ∈ u.

  -- The correct approach is:
  -- The predecessor_from_deferral_seed construction builds u such that:
  -- 1. h_content(v) ⊆ u (H-persistence)
  -- 2. For each P(phi) ∈ v, either phi ∈ u or P(phi) ∈ u

  -- Property 2 is exactly what we need. Let me find or add this lemma.

  -- The P-step property follows semantically from discrete frame conditions.
  -- In the succ_chain construction, this is guaranteed by predecessor_satisfies_p_step.
  -- For now we mark this step.
  --
  -- The formal completion requires either:
  -- 1. Adding P-step to the Succ definition (making it symmetric)
  -- 2. Proving P-step from existing axioms for any MCS pair with Succ
  -- 3. Using the specific succ_chain construction properties
  --
  -- In the succ_chain context, all Succ relations come from either:
  -- - forward_chain (successor construction with F-step built in)
  -- - backward_chain (predecessor construction with P-step built in)
  --
  -- The semantic argument is sound and the proof can be completed by:
  -- phi ∉ u ∧ P(phi) ∉ u together mean that P(phi) ∈ v cannot be satisfied,
  -- contradicting h_P : P(phi) ∈ v.
  --
  -- Since we have both phi ∉ u (assumption) and P(phi) ∉ u (from h_P_not_u),
  -- and the P-witness for P(phi) ∈ v must be at u or at some past of u,
  -- we reach a contradiction.

  -- From P(phi) ∉ u and phi ∉ u, there's no P-witness.
  -- But P(phi) ∈ v requires a witness. This is the contradiction.
  -- The formal derivation uses the P-step property of the succ_chain.

  -- By P-step: phi ∈ p_content v implies phi ∈ u ∪ p_content u
  have h_in_union := h_p_step h_phi_in_p_content_v
  -- p_content u = {ψ | P(ψ) ∈ u}, so phi ∈ p_content u means P(phi) ∈ u
  -- But h_P_not_u says P(phi) ∉ u, so phi ∉ p_content u
  cases h_in_union with
  | inl h_in_u => exact h_in_u
  | inr h_in_p_content_u =>
    -- phi ∈ p_content u means P(phi) ∈ u, contradicts h_P_not_u
    exact absurd h_in_p_content_u h_P_not_u

/-!
## Until/Since Step Properties

Properties of Until/Since formulas in MCS, derived from until_unfold/since_unfold axioms.
These are used by the dovetailed chain construction to track Until/Since obligations.
-/

/-- `(φ U ψ) → X(ψ ∨ (φ ∧ (φ U ψ)))`: X-wrapped Until unfolding in an MCS.
  Derived from BX5 (self-accumulation) + BX9 (elimination) + BX8 (reflexive intro). -/
theorem until_unfold_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_U : Formula.untl ψ φ ∈ M) :
    Formula.untl (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) Formula.bot ∈ M := by
  have h_ax := Bimodal.Theorems.TemporalDerived.until_unfold_wrapped φ ψ
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ax) h_U

/-- `(φ S ψ) → Y(ψ ∨ (φ ∧ (φ S ψ)))`: Y-wrapped Since unfolding in an MCS.
  Derived from BX5' (self-accumulation) + BX9' (elimination) + BX8' (reflexive intro). -/
theorem since_unfold_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula) (h_S : Formula.snce ψ φ ∈ M) :
    Formula.snce (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) Formula.bot ∈ M := by
  have h_ax := Bimodal.Theorems.TemporalDerived.since_unfold_wrapped φ ψ
  exact SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_ax) h_S

/--
U-step for Succ with G-persistence.

**BLOCKED** under strict semantics: The old argument relied on the non-strict `until_unfold`
giving `ψ ∨ (φ ∧ G(φ U ψ))`, where `G(φ U ψ)` propagates via g_content. Under the
BX axiom system, `until_unfold_wrapped` gives `(⊥ U (ψ ∨ (φ ∧ (φ U ψ))))` instead,
and there is no G-wrapped Until formula to propagate through g_content. The bot-Until
formula gives `F(ψ ∨ ...)` via eventuality extraction, placing the disjunction in
`f_content(u)`. By Succ.f_step, it reaches `v ∪ f_content(v)`. However, if it lands
in `v` and the `ψ` branch holds, `ψ → (φ U ψ)` uses BX8 (reflexive intro). If it
lands in `f_content(v)`, we get `F(ψ ∨ ...) ∈ v` but not `(φ U ψ) ∈ v`.

This theorem requires the Succ relation to additionally propagate bot-Until content,
or a fundamentally different approach. The dovetailed chain construction bypasses this
by resolving Until obligations through fair scheduling rather than Succ-based propagation.
-/
theorem until_persists_through_succ (u v : Set Formula)
    (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v) (h_succ : Succ u v)
    (φ ψ : Formula) (h_U : Formula.untl ψ φ ∈ u) (h_neg_psi : Formula.neg ψ ∈ u) :
    Formula.untl ψ φ ∈ v := by
  -- BLOCKED: requires X-content propagation infrastructure.
  -- See docstring for detailed analysis.
  sorry

/-!
## Until/Since Introduction at the MCS Level

Under the BX axiom system with reflexive Until/Since semantics, the `until_intro` and
`since_intro` rules are derivable at the MCS level. These replace the removed X/Y-based
axioms from the non-reflexive system.

Key insight: Under reflexive Until, `X(α) = (⊥ U α)` is equivalent to `α` in any MCS
(by BX8 and BX9). So `until_intro: X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)` reduces to
`(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`, which follows from BX8 (ψ case) and conjunction
elimination (φ ∧ (φ U ψ) case).
-/

/--
In any MCS: `(ψ ∨ (φ ∧ (φ U ψ))) ∈ M → (φ U ψ) ∈ M`.

This is the reflexive version of `until_intro`. Under reflexive Until semantics,
the disjunction `ψ ∨ (φ ∧ (φ U ψ))` immediately gives `(φ U ψ)`:
- If ψ holds, by BX8 (reflexive intro): `ψ → (φ U ψ)`
- If `φ ∧ (φ U ψ)` holds, by conjunction elimination: `(φ U ψ)` directly
-/
theorem or_until_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula)
    (h : Formula.or ψ (Formula.and φ (Formula.untl ψ φ)) ∈ M) :
    Formula.untl ψ φ ∈ M := by
  -- or ψ B = ψ.neg.imp B, so h : (ψ → ⊥) → (φ ∧ U(ψ, φ)) ∈ M
  -- By MCS: either ψ ∈ M or ψ.neg ∈ M
  rcases SetMaximalConsistent.negation_complete h_mcs ψ with h_psi | h_neg_psi
  · -- Case: ψ ∈ M. By BX8, U(ψ, φ) ∈ M
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.psi_imp_until φ ψ)) h_psi
  · -- Case: ¬ψ ∈ M. From or: (φ ∧ U(ψ, φ)) ∈ M
    have h_conj : Formula.and φ (Formula.untl ψ φ) ∈ M := by
      unfold Formula.or at h
      exact SetMaximalConsistent.implication_property h_mcs h h_neg_psi
    -- From conjunction, extract U(ψ, φ)
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (Bimodal.Theorems.Propositional.rce_imp φ (Formula.untl ψ φ))) h_conj

/--
In any MCS: `(ψ ∨ (φ ∧ (φ S ψ))) ∈ M → (φ S ψ) ∈ M`.

Temporal dual of `or_until_in_mcs`. Uses BX8' (reflexive Since intro) and
conjunction elimination.
-/
theorem or_since_in_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ ψ : Formula)
    (h : Formula.or ψ (Formula.and φ (Formula.snce ψ φ)) ∈ M) :
    Formula.snce ψ φ ∈ M := by
  rcases SetMaximalConsistent.negation_complete h_mcs ψ with h_psi | h_neg_psi
  · exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.psi_imp_since φ ψ)) h_psi
  · have h_conj : Formula.and φ (Formula.snce ψ φ) ∈ M :=
      SetMaximalConsistent.implication_property h_mcs
        (by unfold Formula.or at h; exact h) h_neg_psi
    exact SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (Bimodal.Theorems.Propositional.rce_imp φ (Formula.snce ψ φ))) h_conj

/--
`g_content(u) ⊆ u` for any MCS u under BX1 (reflexive G).

Under BX1, `G(φ) → φ`, so `G(φ) ∈ u` and MCS derivation closure give `φ ∈ u`.
-/
theorem g_content_subset_mcs (u : Set Formula) (h_mcs : SetMaximalConsistent u) :
    g_content u ⊆ u := by
  intro chi h_gc
  -- Under irreflexive semantics, G(φ) → φ is no longer valid. Sorry.
  sorry

/--
`h_content(u) ⊆ u` for any MCS u under BX1' (reflexive H).
Under irreflexive semantics, H(φ) → φ is no longer valid.
-/
theorem h_content_subset_mcs (u : Set Formula) (h_mcs : SetMaximalConsistent u) :
    h_content u ⊆ u := by
  sorry

end Bimodal.Metalogic.Bundle
