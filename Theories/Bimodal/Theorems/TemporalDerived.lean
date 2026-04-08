import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation

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

- `G_implies_X`, `H_implies_Y`: From BX1 + BX8/BX8'
- `X_bot_absurd`, `Y_bot_absurd`: From BX9/BX9' + propositional logic
- `until_implies_some_future`, `since_implies_some_past`: Direct BX10/BX10'
- `YX_identity`, `XY_identity`: From BX9/BX9' + propositional logic
- `YG_implies_self`, `XH_implies_self`: From BX9/BX9' + BX1/BX1'

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
private abbrev X (a : Formula) : Formula := Formula.untl Formula.bot a  -- X(a) = ⊥ U a
private abbrev Y (a : Formula) : Formula := Formula.snce Formula.bot a  -- Y(a) = ⊥ S a

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

/--
`⊢ G(a) → G((⊤ ∧ X(a)) → a)`: From prop_s and temp_k_dist.
-/
def G_implies_G_step (a : Formula) :
    ⊢ a.all_future.imp
      ((Formula.and top (X a)).imp a).all_future := by
  have h_weak : ⊢ a.imp ((Formula.and top (X a)).imp a) :=
    DerivationTree.axiom [] _ (Axiom.prop_s a (Formula.and top (X a)))
  have h_nec : ⊢ (a.imp ((Formula.and top (X a)).imp a)).all_future :=
    DerivationTree.temporal_necessitation _ h_weak
  have h_k : ⊢ (a.imp ((Formula.and top (X a)).imp a)).all_future.imp
    (a.all_future.imp ((Formula.and top (X a)).imp a).all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist a ((Formula.and top (X a)).imp a))
  exact DerivationTree.modus_ponens [] _ _ h_k h_nec

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
`⊢ G(a) → X(a)` where X(a) = ⊥ U a.
From BX1 (G(a) → a) and BX8 (a → ⊥ U a), compose.
-/
def G_implies_X (a : Formula) : ⊢ a.all_future.imp (X a) :=
  imp_trans (DerivationTree.axiom [] _ (Axiom.temp_t_future a))
    (DerivationTree.axiom [] _ (Axiom.refl_intro_until Formula.bot a))

/--
`⊢ H(a) → Y(a)` where Y(a) = ⊥ S a. Mirror of G_implies_X.
From BX1' (H(a) → a) and BX8' (a → ⊥ S a), compose.
-/
def H_implies_Y (a : Formula) : ⊢ a.all_past.imp (Y a) :=
  imp_trans (DerivationTree.axiom [] _ (Axiom.temp_t_past a))
    (DerivationTree.axiom [] _ (Axiom.refl_intro_since Formula.bot a))

/--
`⊢ (⊥ U ⊥) → ⊥`: X(⊥) is absurd.
From BX9: `(⊥ U ⊥) → (⊥ ∨ ⊥)` where `⊥ ∨ ⊥ = (⊥ → ⊥) → ⊥`.
Then apply identity `⊥ → ⊥` to get ⊥.
-/
def X_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot :=
  -- BX9 gives (⊥ U ⊥) → (⊥ ∨ ⊥) = (⊥ → ⊥) → ⊥
  -- app1 gives (⊥ → ⊥) → ((⊥ → ⊥) → ⊥) → ⊥
  -- compose: (⊥ U ⊥) → ⊥
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot Formula.bot))
    (mp (identity Formula.bot) theorem_app1)

/--
`⊢ (⊥ S ⊥) → ⊥`: Y(⊥) is absurd. Mirror of X_bot_absurd.
-/
def Y_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot :=
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
private def X_elim (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.until_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

/-- `(⊥ S a) → a`: Mirror of X_elim. -/
private def Y_elim (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.since_elim Formula.bot a))
    (mp (identity Formula.bot) (@theorem_app1 (Formula.bot.imp Formula.bot) a))

/-- Y(X(φ)) → φ: Previous of Next is identity.
Compose Y_elim with X_elim. -/
def YX_identity (a : Formula) :
    ⊢ (Formula.snce Formula.bot (Formula.untl Formula.bot a)).imp a :=
  imp_trans (Y_elim (Formula.untl Formula.bot a)) (X_elim a)

/-- X(Y(φ)) → φ: Next of Previous is identity.
Compose X_elim with Y_elim. -/
def XY_identity (a : Formula) :
    ⊢ (Formula.untl Formula.bot (Formula.snce Formula.bot a)).imp a :=
  imp_trans (X_elim (Formula.snce Formula.bot a)) (Y_elim a)

/-- Y-necessitation: if ⊢ φ then ⊢ Y(φ). -/
private noncomputable def y_nec' {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.snce Formula.bot φ) := by
  have h_H : DerivationTree [] φ.all_past :=
    Bimodal.Theorems.past_necessitation _ h
  exact DerivationTree.modus_ponens [] _ _ (H_implies_Y φ) h_H

/-- X-necessitation: if ⊢ φ then ⊢ X(φ). -/
private def x_nec' {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.untl Formula.bot φ) := by
  have h_G : DerivationTree [] φ.all_future :=
    DerivationTree.temporal_necessitation _ h
  exact DerivationTree.modus_ponens [] _ _ (G_implies_X φ) h_G

/-- Y(G(φ)) → φ: Compose Y_elim with BX1. -/
def YG_implies_self (a : Formula) :
    ⊢ (Formula.snce Formula.bot a.all_future).imp a :=
  imp_trans (Y_elim a.all_future) (DerivationTree.axiom [] _ (Axiom.temp_t_future a))

/-- X(H(φ)) → φ: Compose X_elim with BX1'. -/
def XH_implies_self (a : Formula) :
    ⊢ (Formula.untl Formula.bot a.all_past).imp a :=
  imp_trans (X_elim a.all_past) (DerivationTree.axiom [] _ (Axiom.temp_t_past a))

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

end Bimodal.Theorems.TemporalDerived
