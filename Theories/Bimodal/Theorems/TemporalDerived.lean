import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Propositional

/-!
# Temporal Derived Theorems from BX Axioms

This module contains temporal theorems derived from the Burgess-Xu (BX) axiom system
under all-reflexive semantics.

## BX-Derivable Results (sorry-free)

- `G_bot_absurd`: `⊢ G(⊥) → ⊥` (from BX1)
- `H_bot_absurd`: `⊢ H(⊥) → ⊥` (from BX1')
- `G_distribution`: `⊢ G(φ → ψ) → (G(φ) → G(ψ))` (temp_k_dist axiom)
- `G_transitivity`: `⊢ G(φ) → G(G(φ))` (temp_4 axiom)
- `connect_future_thm`: `⊢ φ → G(P(φ))` (BX4 axiom)
- `connect_past_thm`: `⊢ φ → H(F(φ))` (BX4' axiom)
- `density_derivable`: `⊢ G(G(φ)) → G(φ)` (from BX1)

## BX8-BX10 Derived Results (sorry-free)

These theorems use the reflexive Until/Since introduction (BX8/BX8'),
elimination (BX9/BX9'), and eventuality extraction (BX10/BX10') axioms.

- `bot_until_bot_absurd`, `bot_since_bot_absurd`: (⊥ U ⊥) → ⊥, (⊥ S ⊥) → ⊥
- `until_implies_some_future`, `since_implies_some_past`: Direct BX10/BX10'
- `bot_until_elim`, `bot_since_elim`: (⊥ U a) → a, (⊥ S a) → a (private)
- `bot_until_id`, `bot_since_id`: Public versions of the above

## Key BX-Derived Lemmas for Canonical Completeness

- `psi_imp_until`, `psi_imp_since`: Direct BX8/BX8'
- `until_imp_or`, `since_imp_or`: Direct BX9/BX9'
- `until_imp_F`, `since_imp_P`: Direct BX10/BX10'

## References

- Burgess 1982/84: Until-Since temporal logic axiomatization
- Task 83: BX axiom system refactor
-/

namespace Bimodal.Theorems.TemporalDerived

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

-- Abbreviations for readability
private abbrev top : Formula := Formula.neg Formula.bot  -- ⊤ = ¬⊥

/-!
## BX-Derivable Temporal Theorems (sorry-free)

These theorems are directly derivable from the BX axiom system.
-/

/--
`⊢ G(⊥) → ⊥`: G(⊥) is absurd because BX1 gives G(φ) → φ, instantiated at φ = ⊥.
-/
def G_bot_absurd : ⊢ Formula.bot.all_future.imp Formula.bot :=
  DerivationTree.axiom [] _ (Axiom.temp_t_future Formula.bot)

/--
`⊢ H(⊥) → ⊥`: H(⊥) is absurd because BX1' gives H(φ) → φ, instantiated at φ = ⊥.
-/
noncomputable def H_bot_absurd : ⊢ Formula.bot.all_past.imp Formula.bot :=
  DerivationTree.axiom [] _ (Axiom.temp_t_past Formula.bot)

/--
`⊢ G(φ → ψ) → (G(φ) → G(ψ))`: G-distribution. Direct axiom (temp_k_dist).
-/
def G_distribution (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future) :=
  DerivationTree.axiom [] _ (Axiom.temp_k_dist φ ψ)

/--
`⊢ H(φ → ψ) → (H(φ) → H(ψ))`: H-distribution. Derived via temporal duality from G-distribution.
-/
noncomputable def H_distribution (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past) :=
  Bimodal.Theorems.past_k_dist φ ψ

/--
`⊢ G(φ) → G(G(φ))`: G-transitivity. Direct axiom (temp_4).
-/
def G_transitivity (φ : Formula) :
    ⊢ φ.all_future.imp φ.all_future.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_4 φ)

/--
`⊢ H(φ) → H(H(φ))`: H-transitivity. Derived via temporal duality from G-transitivity.
-/
noncomputable def H_transitivity (φ : Formula) :
    ⊢ φ.all_past.imp φ.all_past.all_past := by
  -- Derive by applying temporal duality to G-transitivity of swap_temporal φ
  let ψ := φ.swap_temporal
  have h1 : ⊢ ψ.all_future.imp ψ.all_future.all_future :=
    DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
  have h2 : ⊢ (ψ.all_future.imp ψ.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h1
  simp only [Formula.swap_temporal] at h2
  have h_inv : ψ.swap_temporal = φ := Formula.swap_temporal_involution φ
  rw [h_inv] at h2
  exact h2

/--
`⊢ φ → G(P(φ))`: Temporal connectedness (future). Direct axiom (BX4).
The present is always in the past of the future.
-/
def connect_future_thm (φ : Formula) :
    ⊢ φ.imp (φ.some_past.all_future) :=
  DerivationTree.axiom [] _ (Axiom.connect_future φ)

/--
`⊢ φ → H(F(φ))`: Temporal connectedness (past). Direct axiom (BX4').
The present is always in the future of the past.
-/
def connect_past_thm (φ : Formula) :
    ⊢ φ.imp (φ.some_future.all_past) :=
  DerivationTree.axiom [] _ (Axiom.connect_past φ)

/--
`⊢ G(G(φ)) → G(φ)`: Density (derivable from BX1).
Under reflexive semantics, BX1 gives G(ψ) → ψ for any ψ.
Instantiate ψ = G(φ): G(G(φ)) → G(φ).
-/
def density_derivable (φ : Formula) :
    ⊢ φ.all_future.all_future.imp φ.all_future :=
  DerivationTree.axiom [] _ (Axiom.temp_t_future φ.all_future)

/--
`⊢ H(H(φ)) → H(φ)`: Past density (derivable from BX1').
Instantiate BX1' with ψ = H(φ).
-/
def past_density_derivable (φ : Formula) :
    ⊢ φ.all_past.all_past.imp φ.all_past :=
  DerivationTree.axiom [] _ (Axiom.temp_t_past φ.all_past)

/--
`⊢ G(a) → G(a → a)`: G(a→a) is a theorem, so G(a) → G(a→a) by prop_s.
-/
def G_implies_G_id (a : Formula) :
    ⊢ a.all_future.imp (a.imp a).all_future :=
  mp (DerivationTree.temporal_necessitation _ (identity a))
     (DerivationTree.axiom [] _ (Axiom.prop_s (a.imp a).all_future a.all_future))

/-!
## BX8-BX10 Derived Theorems (sorry-free)

These theorems use the reflexive Until/Since axioms (BX8-BX10).
Under reflexive semantics, X(a) = ⊥ U a ↔ a (witness s = t, guard [t,t) empty).
-/

/--
`⊢ G(a) → ⊤ U a`: From BX1 (G(a) → a) and BX8 (a → ⊤ U a), compose.
-/
def G_implies_topUntil (a : Formula) :
    ⊢ a.all_future.imp (Formula.untl top a) :=
  imp_trans (DerivationTree.axiom [] _ (Axiom.temp_t_future a))
    (DerivationTree.axiom [] _ (Axiom.refl_intro_until top a))

/--
`⊢ (⊥ U ⊥) → ⊥`: X(⊥) is absurd.
From BX9: `(⊥ U ⊥) → (⊥ ∨ ⊥)` where `⊥ ∨ ⊥ = (⊥ → ⊥) → ⊥`.
Then apply identity `⊥ → ⊥` to get ⊥.
-/
def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot :=
  -- BX9 gives (⊥ U ⊥) → (⊥ ∨ ⊥) = (⊥ → ⊥) → ⊥
  -- app1 gives (⊥ → ⊥) → ((⊥ → ⊥) → ⊥) → ⊥
  -- compose: (⊥ U ⊥) → ⊥
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot Formula.bot))
    (mp (identity Formula.bot) theorem_app1)

/--
`⊢ (⊥ S ⊥) → ⊥`: Y(⊥) is absurd. Mirror of bot_until_bot_absurd.
-/
def bot_since_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot Formula.bot))
    (mp (identity Formula.bot) theorem_app1)

/--
`⊢ (φ U ψ) → F(ψ)`: Any Until formula implies eventuality of its second argument.
Direct from BX10 axiom.
-/
def until_implies_some_future (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.some_future ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ)

/--
`⊢ (φ S ψ) → P(ψ)`: Any Since formula implies past eventuality.
Direct from BX10' axiom.
-/
def since_implies_some_past (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.some_past ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ)

/-- `(⊥ U a) → a`: Under reflexive semantics, X(a) = ⊥ U a implies a.
From BX9: `(⊥ U a) → (⊥ ∨ a) = ((⊥→⊥) → a)`, then apply identity. -/
private def bot_until_elim (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

/-- `(⊥ S a) → a`: Mirror of bot_until_elim. -/
private def bot_since_elim (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

/-!
## Key BX-Derived Lemmas for Canonical Completeness

These lemmas are the critical prerequisites for the Until/Since truth lemma
in the BXCanonical completeness proof (Phase 1 of plan v34).
-/

/--
`⊢ ψ → (φ U ψ)`: Reflexive Until introduction.
Under reflexive Until semantics, ψ at current time gives a reflexive witness.
Direct from BX8 axiom.
-/
def psi_imp_until (φ ψ : Formula) :
    ⊢ ψ.imp (Formula.untl φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.refl_intro_until φ ψ)

/--
`⊢ ψ → (φ S ψ)`: Reflexive Since introduction.
Mirror of psi_imp_until for the past direction.
-/
def psi_imp_since (φ ψ : Formula) :
    ⊢ ψ.imp (Formula.snce φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.refl_intro_since φ ψ)

/--
`⊢ (φ U ψ) → (φ ∨ ψ)`: Until implies disjunction at current time.
At any time where φ U ψ holds, either the witness is now (giving ψ)
or it is strictly in the future (giving φ from the guard).
Direct from BX9 axiom.
-/
def until_imp_or (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.or φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_elim φ ψ)

/--
`⊢ (φ S ψ) → (φ ∨ ψ)`: Since implies disjunction at current time.
Mirror of until_imp_or.
-/
def since_imp_or (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.or φ ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_elim φ ψ)

/--
`⊢ (φ U ψ) → F(ψ)`: Until implies eventuality of its endpoint.
The witness s ≥ t with ψ(s) certifies F(ψ) at t.
Direct from BX10 axiom.
-/
def until_imp_F (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.some_future ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ)

/--
`⊢ (φ S ψ) → P(ψ)`: Since implies past eventuality of its endpoint.
Mirror of until_imp_F.
-/
def since_imp_P (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.some_past ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ)

/-!
## Propositional Helpers for Until/Since Derivations
-/

/-- Contrapositive: `⊢ (A → B) → (¬B → ¬A)`.
Derived from b_combinator and theorem_flip. -/
noncomputable def contrapositive (A B : Formula) : ⊢ (A.imp B).imp (B.neg.imp A.neg) :=
  mp b_combinator (theorem_flip (A := (B.imp Formula.bot)) (B := (A.imp B)) (C := (A.imp Formula.bot)))

private noncomputable def ctx_mp {Γ : Context} {A B : Formula}
    (h1 : Γ ⊢ A.imp B) (h2 : Γ ⊢ A) : Γ ⊢ B :=
  DerivationTree.modus_ponens Γ A B h1 h2

private noncomputable def ctx_thm {Γ : Context} {A : Formula}
    (h : ⊢ A) : Γ ⊢ A :=
  DerivationTree.weakening [] Γ A h (List.nil_subset Γ)

/-- Disjunction commutativity: `⊢ (A ∨ B) → (B ∨ A)`.
Since `A ∨ B = ¬A → B`, this is `(¬A → B) → (¬B → A)`, proved by
contraposition of the hypothesis composed with DNE. -/
noncomputable def formula_or_comm (A B : Formula) : ⊢ (A.or B).imp (B.or A) := by
  unfold Formula.or
  apply Bimodal.Metalogic.Core.deduction_theorem [] (A.neg.imp B) (B.neg.imp A)
  apply Bimodal.Metalogic.Core.deduction_theorem [A.neg.imp B] B.neg A
  have h1 : [B.neg, A.neg.imp B] ⊢ A.neg.imp B := DerivationTree.assumption _ _ (by simp)
  have h2 : [B.neg, A.neg.imp B] ⊢ B.neg := DerivationTree.assumption _ _ (by simp)
  have h3 : [B.neg, A.neg.imp B] ⊢ A.neg.neg := ctx_mp (ctx_mp (ctx_thm b_combinator) h2) h1
  exact ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.double_negation A)) h3

/-!
## X/Y Identity (X(α) → α, Y(α) → α)

Under reflexive Until/Since semantics, `X(α) = ⊥ U α` and `Y(α) = ⊥ S α` are
equivalent to `α` in any MCS. These public versions of the private bot_until_elim/bot_since_elim
are needed by downstream modules (SuccRelation, canonical constructions).
-/

/-- `⊢ X(α) → α`: Under reflexive semantics, X(α) = ⊥ U α implies α.
From BX9: `(⊥ U α) → (⊥ ∨ α) = (⊤ → α)`, then apply `⊤ = id ⊥`. -/
noncomputable def bot_until_id (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

/-- `⊢ Y(α) → α`: Mirror of bot_until_id for past direction. -/
noncomputable def bot_since_id (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

/-!
## Until/Since Unfolding and Introduction Theorems

These are the key derived theorems for backward Until/Since in the
canonical completeness construction.
-/

/-- `⊢ (ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`: Or-Until introduction.
The ψ branch uses BX8 (reflexive intro), the conjunction branch uses
right conjunction elimination. Classical case split via Peirce + contrapositive. -/
noncomputable def or_until_imp (φ ψ : Formula) :
    ⊢ (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))).imp (Formula.untl φ ψ) := by
  unfold Formula.or
  let Γ₁ : Context := [ψ.neg.imp (φ.and (Formula.untl φ ψ))]
  let Γ₂ : Context := [(Formula.untl φ ψ).neg, ψ.neg.imp (φ.and (Formula.untl φ ψ))]
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  apply ctx_mp (ctx_thm (show ⊢ _ from DerivationTree.axiom [] _ (Axiom.peirce (Formula.untl φ ψ) Formula.bot)))
  apply Bimodal.Metalogic.Core.deduction_theorem Γ₁ _ _
  have h_contra : Γ₂ ⊢ (Formula.untl φ ψ).neg.imp ψ.neg :=
    ctx_mp (ctx_thm (contrapositive ψ (Formula.untl φ ψ))) (ctx_thm (psi_imp_until φ ψ))
  have h_neg_until : Γ₂ ⊢ (Formula.untl φ ψ).neg := DerivationTree.assumption _ _ (List.Mem.head _)
  have h_hyp : Γ₂ ⊢ ψ.neg.imp (φ.and (Formula.untl φ ψ)) :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  exact ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.rce_imp φ (Formula.untl φ ψ)))
    (ctx_mp h_hyp (ctx_mp h_contra h_neg_until))

/-- `⊢ (ψ ∨ (φ ∧ (φ S ψ))) → (φ S ψ)`: Or-Since introduction. Mirror of or_until_imp. -/
noncomputable def or_since_imp (φ ψ : Formula) :
    ⊢ (Formula.or ψ (Formula.and φ (Formula.snce φ ψ))).imp (Formula.snce φ ψ) := by
  unfold Formula.or
  let Γ₁ : Context := [ψ.neg.imp (φ.and (Formula.snce φ ψ))]
  let Γ₂ : Context := [(Formula.snce φ ψ).neg, ψ.neg.imp (φ.and (Formula.snce φ ψ))]
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  apply ctx_mp (ctx_thm (show ⊢ _ from DerivationTree.axiom [] _ (Axiom.peirce (Formula.snce φ ψ) Formula.bot)))
  apply Bimodal.Metalogic.Core.deduction_theorem Γ₁ _ _
  have h_contra : Γ₂ ⊢ (Formula.snce φ ψ).neg.imp ψ.neg :=
    ctx_mp (ctx_thm (contrapositive ψ (Formula.snce φ ψ))) (ctx_thm (psi_imp_since φ ψ))
  have h_neg_since : Γ₂ ⊢ (Formula.snce φ ψ).neg := DerivationTree.assumption _ _ (List.Mem.head _)
  have h_hyp : Γ₂ ⊢ ψ.neg.imp (φ.and (Formula.snce φ ψ)) :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  exact ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.rce_imp φ (Formula.snce φ ψ)))
    (ctx_mp h_hyp (ctx_mp h_contra h_neg_since))

/-- `⊢ (φ U ψ) → (ψ ∨ (φ ∧ (φ U ψ)))`: Until unfolding at current time.
From BX5 (self-accumulation) + BX9 (elimination) + or-commutativity. -/
noncomputable def until_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))) :=
  imp_trans
    (imp_trans (DerivationTree.axiom [] _ (Axiom.self_accum_until φ ψ))
              (DerivationTree.axiom [] _ (Axiom.until_elim (Formula.and φ (Formula.untl φ ψ)) ψ)))
    (formula_or_comm _ _)

/-- `⊢ (φ S ψ) → (ψ ∨ (φ ∧ (φ S ψ)))`: Since unfolding at current time. Mirror. -/
noncomputable def since_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.or ψ (Formula.and φ (Formula.snce φ ψ))) :=
  imp_trans
    (imp_trans (DerivationTree.axiom [] _ (Axiom.self_accum_since φ ψ))
              (DerivationTree.axiom [] _ (Axiom.since_elim (Formula.and φ (Formula.snce φ ψ)) ψ)))
    (formula_or_comm _ _)

/-- `⊢ (φ U ψ) → X(ψ ∨ (φ ∧ (φ U ψ)))`: X-wrapped Until unfolding.
Compose until_unfold_thm with BX8 (reflexive intro at ⊥). -/
noncomputable def until_unfold_wrapped (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp
      (Formula.untl Formula.bot (Formula.or ψ (Formula.and φ (Formula.untl φ ψ)))) :=
  imp_trans (until_unfold_thm φ ψ) (psi_imp_until Formula.bot _)

/-- `⊢ (φ S ψ) → Y(ψ ∨ (φ ∧ (φ S ψ)))`: Y-wrapped Since unfolding. Mirror. -/
noncomputable def since_unfold_wrapped (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp
      (Formula.snce Formula.bot (Formula.or ψ (Formula.and φ (Formula.snce φ ψ)))) :=
  imp_trans (since_unfold_thm φ ψ) (psi_imp_since Formula.bot _)

/-- `⊢ X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`: Until introduction rule.
Compose bot_until_id with or_until_imp. This is the key rule for backward
Until induction in the canonical completeness construction. -/
noncomputable def until_intro (φ ψ : Formula) :
    ⊢ (Formula.untl Formula.bot (Formula.or ψ (Formula.and φ (Formula.untl φ ψ)))).imp
      (Formula.untl φ ψ) :=
  imp_trans (bot_until_id _) (or_until_imp φ ψ)

/-- `⊢ Y(ψ ∨ (φ ∧ (φ S ψ))) → (φ S ψ)`: Since introduction rule. Mirror. -/
noncomputable def since_intro (φ ψ : Formula) :
    ⊢ (Formula.snce Formula.bot (Formula.or ψ (Formula.and φ (Formula.snce φ ψ)))).imp
      (Formula.snce φ ψ) :=
  imp_trans (bot_since_id _) (or_since_imp φ ψ)

end Bimodal.Theorems.TemporalDerived
