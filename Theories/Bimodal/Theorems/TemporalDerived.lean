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

## Discrete-Only Results (sorry, require X/Y extension)

Under reflexive semantics, X(a) = ⊥ U a holds at t iff a(t) (witness s = t,
guard [t,t) is empty). So X(a) ↔ a semantically, making G(a) → X(a) trivially
equivalent to G(a) → a (BX1). The theorems below are retained for backward
compatibility but are marked as discrete-only extensions.

- `G_implies_X`, `H_implies_Y`: Discrete-only (require strict semantics for meaning)
- `X_bot_absurd`, `Y_bot_absurd`: Discrete-only
- `YX_identity`, `XY_identity`: Discrete-only
- `YG_implies_self`, `XH_implies_self`: Discrete-only

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
## Discrete-Only Theorems (sorry)

These theorems require X(a) = ⊥ U a to behave as "next" (discrete semantics).
Under reflexive semantics, X(a) ↔ a, so these are trivially equivalent to
simpler statements. They are retained for backward compatibility with
downstream code that references them, and marked sorry pending discrete
extension axioms.
-/

/--
`⊢ G(a) → ⊤ U a`: Under reflexive semantics, ⊤ U a at t requires ∃ s ≥ t with a(s).
From G(a) → a (BX1), we get a(t), but the syntactic derivation of `a → ⊤ U a`
requires a reflexive Until introduction principle not in the current BX axiom set.
-/
def G_implies_topUntil (a : Formula) :
    ⊢ a.all_future.imp (Formula.untl top a) := by
  sorry -- Requires reflexive Until introduction (discrete extension)

/--
`⊢ G(a) → X(a)` where X(a) = ⊥ U a.
Under reflexive semantics X(a) ↔ a, so this is equivalent to BX1: G(a) → a.
The syntactic derivation requires `a → ⊥ U a` (reflexive introduction).
-/
def G_implies_X (a : Formula) : ⊢ a.all_future.imp (X a) := by
  sorry -- Requires reflexive Until introduction (discrete extension)

/--
`⊢ H(a) → Y(a)` where Y(a) = ⊥ S a. Mirror of G_implies_X.
-/
noncomputable def H_implies_Y (a : Formula) : ⊢ a.all_past.imp (Y a) := by
  sorry -- Requires reflexive Since introduction (discrete extension)

/--
`⊢ (⊥ U ⊥) → ⊥`: X(⊥) is absurd. Discrete-only.
-/
noncomputable def X_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot := by
  sorry -- Discrete-only

/--
`⊢ (⊥ S ⊥) → ⊥`: Y(⊥) is absurd. Discrete-only.
-/
noncomputable def Y_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot := by
  sorry -- Discrete-only

/--
`⊢ (φ U ψ) → F(ψ)`: Any Until formula implies eventuality of its second argument.
Under reflexive semantics, the witness s certifies F(ψ).
Requires reflexive F introduction.
-/
noncomputable def until_implies_some_future (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.some_future ψ) := by
  sorry -- Requires reflexive F introduction (discrete extension)

/--
`⊢ (φ S ψ) → P(ψ)`: Any Since formula implies past eventuality.
Mirror of until_implies_some_future.
-/
noncomputable def since_implies_some_past (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.some_past ψ) := by
  sorry -- Requires reflexive P introduction (discrete extension)

/-- Y(X(φ)) → φ: Previous of Next is identity. Discrete-only. -/
noncomputable def YX_identity (a : Formula) :
    ⊢ (Formula.snce Formula.bot (Formula.untl Formula.bot a)).imp a :=
  sorry -- Discrete-only (requires yx_identity axiom)

/-- X(Y(φ)) → φ: Next of Previous is identity. Discrete-only. -/
noncomputable def XY_identity (a : Formula) :
    ⊢ (Formula.untl Formula.bot (Formula.snce Formula.bot a)).imp a :=
  sorry -- Discrete-only (requires xy_identity axiom)

/-- Y-necessitation: if ⊢ φ then ⊢ Y(φ). Discrete-only (depends on H_implies_Y). -/
private noncomputable def y_nec' {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.snce Formula.bot φ) := by
  have h_H : DerivationTree [] φ.all_past :=
    Bimodal.Theorems.past_necessitation _ h
  exact DerivationTree.modus_ponens [] _ _ (H_implies_Y φ) h_H

/-- X-necessitation: if ⊢ φ then ⊢ X(φ). Discrete-only (depends on G_implies_X). -/
private noncomputable def x_nec' {φ : Formula} (h : DerivationTree [] φ) :
    DerivationTree [] (Formula.untl Formula.bot φ) := by
  have h_G : DerivationTree [] φ.all_future :=
    DerivationTree.temporal_necessitation _ h
  exact DerivationTree.modus_ponens [] _ _ (G_implies_X φ) h_G

/-- Y(G(φ)) → φ: Discrete-only (depends on YX_identity). -/
noncomputable def YG_implies_self (a : Formula) :
    ⊢ (Formula.snce Formula.bot a.all_future).imp a := by
  sorry -- Discrete-only (depends on y_k_dist, YX_identity)

/-- X(H(φ)) → φ: Discrete-only (depends on XY_identity). -/
noncomputable def XH_implies_self (a : Formula) :
    ⊢ (Formula.untl Formula.bot a.all_past).imp a := by
  sorry -- Discrete-only (depends on x_k_dist, XY_identity)

end Bimodal.Theorems.TemporalDerived
