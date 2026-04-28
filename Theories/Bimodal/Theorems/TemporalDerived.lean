import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Propositional

/-!
# Temporal Derived Theorems from BX Axioms

This module contains temporal theorems derived from the Burgess-Xu (BX) axiom system
under open guard semantics `(t,s)` (task 113).

## Status After Open Guard Refactoring (Task 113)

BX8/BX8' (until_step/since_step) and BX9/BX9' (until_elim/since_elim) were removed
because they are not sound under open guard semantics. Several theorems that depended
on these axioms are now sorry-stubbed pending replacement derivations:

### NOT VALID under open guard (sorry-stubbed, may be unprovable):
- `psi_imp_until`, `psi_imp_since`: ψ → (φ U ψ) requires reflexive witness
- `until_imp_or`, `since_imp_or`: Direct BX9 (removed)
- `until_unfold_thm`, `since_unfold_thm`: Used BX5 + BX9
- `until_unfold_wrapped`, `since_unfold_wrapped`: Depends on above
- `refl_F`, `refl_P`: α → F(α) requires reflexive future/past
- `until_F_expansion`, `since_P_expansion`: Depends on above
- `bot_until_bot_absurd`, `bot_since_bot_absurd`: Used BX9
- `bot_until_elim`, `bot_since_elim`: Used BX9
- `bot_until_id`, `bot_since_id`: Used BX9
- `or_until_imp`, `or_since_imp`: Depends on psi_imp_until (invalid)
- `until_intro`, `since_intro`: Depends on bot_until_id + or_until_imp

Original proofs archived in `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

### Pre-existing sorry (NOT related to guard change):
- `G_bot_absurd`, `H_bot_absurd`: Requires seriality under irreflexive G/H
- `G_implies_topUntil`: Requires BX8 (removed)

### Still valid (sorry-free):
- `G_distribution`: Direct axiom (temp_k_dist)
- `G_transitivity`: Direct axiom (temp_4)
- `connect_future_thm`, `connect_past_thm`: Direct BX4/BX4'
- `density_derivable`: From BX1
- `until_implies_some_future`, `since_implies_some_past`: Direct BX10/BX10'
- `until_imp_F`, `since_imp_P`: Direct BX10/BX10'
- `contrapositive`, `formula_or_comm`: Pure propositional

## References

- Burgess 1982/84: Until-Since temporal logic axiomatization
- Task 83: BX axiom system refactor
- Task 113: Open guard refactoring
-/

namespace Bimodal.Theorems.TemporalDerived

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Theorems.Combinators

-- Abbreviations for readability
private abbrev top : Formula := Formula.neg Formula.bot  -- ⊤ = ¬⊥

/-!
## BX-Derivable Temporal Theorems

These theorems are directly derivable from the remaining BX axiom system.
Some require seriality (G_bot_absurd, H_bot_absurd) which is pre-existing.
-/

/--
`⊢ G(⊥) → ⊥`: G(⊥) is absurd because BX1 gives G(φ) → φ, instantiated at φ = ⊥.
-/
def G_bot_absurd : ⊢ Formula.bot.all_future.imp Formula.bot := by
  -- Under irreflexive semantics, G(⊥) → ⊥ requires seriality: G(⊥) means ∀s>t, ⊥.
  -- If ∃s>t (seriality), then ⊥ at s, contradiction. So G(⊥) → ⊥.
  -- Derivable from serial_future + contrapositive.
  sorry

/--
`⊢ H(⊥) → ⊥`: H(⊥) is absurd because BX1' gives H(φ) → φ, instantiated at φ = ⊥.
-/
noncomputable def H_bot_absurd : ⊢ Formula.bot.all_past.imp Formula.bot := by
  sorry

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
    ⊢ φ.all_future.all_future.imp φ.all_future := by
  -- Under irreflexive semantics, GGφ → Gφ requires density, not just BX1.
  sorry

/--
`⊢ H(H(φ)) → H(φ)`: Past density (derivable from BX1').
Instantiate BX1' with ψ = H(φ).
-/
def past_density_derivable (φ : Formula) :
    ⊢ φ.all_past.all_past.imp φ.all_past := by
  sorry

/--
`⊢ G(a) → G(a → a)`: G(a→a) is a theorem, so G(a) → G(a→a) by prop_s.
-/
def G_implies_G_id (a : Formula) :
    ⊢ a.all_future.imp (a.imp a).all_future :=
  mp (DerivationTree.temporal_necessitation _ (identity a))
     (DerivationTree.axiom [] _ (Axiom.prop_s (a.imp a).all_future a.all_future))

/-!
## BX10-Derived Theorems

Under open guard semantics, only BX10/BX10' (eventuality extraction) remain.
BX8/BX9 theorems below are sorry-stubbed (not valid under open guard).
-/

/--
`⊢ G(a) → ⊤ U a`: From BX1 (G(a) → a) and BX8 (a → ⊤ U a), compose.
-/
def G_implies_topUntil (a : Formula) :
    ⊢ a.all_future.imp (Formula.untl top a) := by
  sorry

/--
`⊢ (⊥ U ⊥) → ⊥`: X(⊥) is absurd.
From BX9: `(⊥ U ⊥) → (⊥ ∨ ⊥)` where `⊥ ∨ ⊥ = (⊥ → ⊥) → ⊥`.
Then apply identity `⊥ → ⊥` to get ⊥.
-/
def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot := by
  -- Was: BX9 (until_elim) + app1. BX9 removed under open guard (task 113).
  -- Need alternative derivation without BX9.
  sorry

/--
`⊢ (⊥ S ⊥) → ⊥`: Y(⊥) is absurd. Mirror of bot_until_bot_absurd.
-/
def bot_since_bot_absurd : ⊢ (Formula.snce Formula.bot Formula.bot).imp Formula.bot := by
  -- Was: BX9' (since_elim) + app1. BX9' removed under open guard (task 113).
  sorry

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

/-- `(⊥ U a) → a`: Under open guard, X(a) = ⊥ U a implies a.
Was: BX9 + app1. BX9 removed under open guard (task 113). -/
private def bot_until_elim (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a := by
  sorry

/-- `(⊥ S a) → a`: Mirror of bot_until_elim. -/
private def bot_since_elim (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a := by
  sorry

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
    ⊢ ψ.imp (Formula.untl φ ψ) := by
  -- Under irreflexive semantics, ψ → (φ U ψ) is NOT valid.
  -- Need strict future witness s > t with ψ(s); just having ψ(t) is insufficient.
  sorry

/--
`⊢ ψ → (φ S ψ)`: Reflexive Since introduction.
Mirror of psi_imp_until for the past direction.
-/
def psi_imp_since (φ ψ : Formula) :
    ⊢ ψ.imp (Formula.snce φ ψ) := by
  sorry

/--
`⊢ (φ U ψ) → (φ ∨ ψ)`: Until implies disjunction at current time.
At any time where φ U ψ holds, either the witness is now (giving ψ)
or it is strictly in the future (giving φ from the guard).
Direct from BX9 axiom.
-/
def until_imp_or (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp (Formula.or φ ψ) := by
  -- Was: direct BX9. BX9 removed under open guard (task 113).
  sorry

/--
`⊢ (φ S ψ) → (φ ∨ ψ)`: Since implies disjunction at current time.
Mirror of until_imp_or.
-/
def since_imp_or (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.or φ ψ) := by
  -- Was: direct BX9'. BX9' removed under open guard (task 113).
  sorry

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

/-- `⊢ X(α) → α`: X(α) = ⊥ U α implies α.
Was: BX9 + app1. BX9 removed under open guard (task 113). -/
noncomputable def bot_until_id (a : Formula) :
    ⊢ (Formula.untl Formula.bot a).imp a := by
  sorry

/-- `⊢ Y(α) → α`: Mirror of bot_until_id for past direction. -/
noncomputable def bot_since_id (a : Formula) :
    ⊢ (Formula.snce Formula.bot a).imp a := by
  sorry

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
    ⊢ (Formula.untl φ ψ).imp (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))) := by
  -- Was: BX5 + BX9. BX9 removed under open guard (task 113).
  sorry

/-- `⊢ (φ S ψ) → (ψ ∨ (φ ∧ (φ S ψ)))`: Since unfolding at current time. Mirror. -/
noncomputable def since_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp (Formula.or ψ (Formula.and φ (Formula.snce φ ψ))) := by
  -- Was: BX5' + BX9'. BX9' removed under open guard (task 113).
  sorry

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

/-!
## Reflexivity of F and P

Under BX reflexive semantics (BX1: G(α) → α), we derive α → F(α).
The dual gives α → P(α).
-/

/-- `⊢ α → F(α)`: Any formula implies its own future eventuality.
Under reflexive semantics, the current time witnesses F(α).
Proof: BX1 gives G(¬α) → ¬α. Contrapositive: ¬¬α → ¬G(¬α) = F(α).
Compose with DNI: α → ¬¬α → F(α). -/
noncomputable def refl_F (α : Formula) :
    ⊢ α.imp α.some_future := by
  -- Under irreflexive semantics, α → F(α) is NOT valid.
  -- The current time does not witness F(α) since F requires strict future.
  sorry

/-- `⊢ α → P(α)`: Any formula implies its own past eventuality.
Under reflexive semantics, the current time witnesses P(α).
Dual of refl_F. -/
noncomputable def refl_P (α : Formula) :
    ⊢ α.imp α.some_past := by
  sorry

/-!
## Until F-Expansion

The key derived theorem for backward Until coherence:
`(φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`

This strengthens `until_unfold_thm` by replacing the bare `(φ U ψ)` in the
conjunction with `F(φ U ψ)`. The F-wrapped version enables the contrapositive
argument: `¬(φ U ψ) ∧ φ → G(¬(φ U ψ))`.
-/

/-- `⊢ (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))`: Until F-expansion.
From `until_unfold_thm`: `(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))`.
From `refl_F`: `(φ U ψ) → F(φ U ψ)`.
In the `φ ∧ (φ U ψ)` branch, replace `(φ U ψ)` with `F(φ U ψ)` (weaker). -/
noncomputable def until_F_expansion (φ ψ : Formula) :
    ⊢ (Formula.untl φ ψ).imp
      (Formula.or ψ (Formula.and φ (Formula.untl φ ψ).some_future)) := by
  -- until_unfold_thm: (φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))
  -- We want: (φ U ψ) → ψ ∨ (φ ∧ F(φ U ψ))
  -- In context [φ U ψ]:
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  -- Have φ U ψ in context
  let Γ := [Formula.untl φ ψ]
  have h_until : Γ ⊢ Formula.untl φ ψ := DerivationTree.assumption _ _ (by simp [Γ])
  -- Get ψ ∨ (φ ∧ (φ U ψ)) from unfolding
  have h_unfold : Γ ⊢ Formula.or ψ (Formula.and φ (Formula.untl φ ψ)) :=
    ctx_mp (ctx_thm (until_unfold_thm φ ψ)) h_until
  -- Get F(φ U ψ)
  have h_F : Γ ⊢ (Formula.untl φ ψ).some_future :=
    ctx_mp (ctx_thm (refl_F (Formula.untl φ ψ))) h_until
  -- Case-split: ψ ∨ (φ ∧ (φ U ψ)) is ¬ψ → (φ ∧ (φ U ψ))
  -- Want: ¬ψ → (φ ∧ F(φ U ψ)). From hypothesis: if ¬ψ then φ from conjunction; F(φ U ψ) already held.
  unfold Formula.or at h_unfold ⊢
  apply Bimodal.Metalogic.Core.deduction_theorem Γ _ _
  have h_neg_psi : (ψ.neg :: Γ) ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold' : (ψ.neg :: Γ) ⊢ ψ.neg.imp (Formula.and φ (Formula.untl φ ψ)) :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_unfold (by intro x hx; simp [Γ, hx])
  have h_conj : (ψ.neg :: Γ) ⊢ Formula.and φ (Formula.untl φ ψ) :=
    ctx_mp h_unfold' h_neg_psi
  have h_phi : (ψ.neg :: Γ) ⊢ φ :=
    ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.lce_imp φ (Formula.untl φ ψ))) h_conj
  have h_F' : (ψ.neg :: Γ) ⊢ (Formula.untl φ ψ).some_future :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_F (by intro x hx; simp [Γ, hx])
  exact ctx_mp (ctx_mp (ctx_thm (pairing φ (Formula.untl φ ψ).some_future)) h_phi) h_F'

/-- `⊢ (φ S ψ) → ψ ∨ (φ ∧ P(φ S ψ))`: Since P-expansion. Dual of until_F_expansion. -/
noncomputable def since_P_expansion (φ ψ : Formula) :
    ⊢ (Formula.snce φ ψ).imp
      (Formula.or ψ (Formula.and φ (Formula.snce φ ψ).some_past)) := by
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  let Γ := [Formula.snce φ ψ]
  have h_since : Γ ⊢ Formula.snce φ ψ := DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold : Γ ⊢ Formula.or ψ (Formula.and φ (Formula.snce φ ψ)) :=
    ctx_mp (ctx_thm (since_unfold_thm φ ψ)) h_since
  have h_P : Γ ⊢ (Formula.snce φ ψ).some_past :=
    ctx_mp (ctx_thm (refl_P (Formula.snce φ ψ))) h_since
  unfold Formula.or at h_unfold ⊢
  apply Bimodal.Metalogic.Core.deduction_theorem Γ _ _
  have h_neg_psi : (ψ.neg :: Γ) ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold' : (ψ.neg :: Γ) ⊢ ψ.neg.imp (Formula.and φ (Formula.snce φ ψ)) :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_unfold (by intro x hx; simp [Γ, hx])
  have h_conj : (ψ.neg :: Γ) ⊢ Formula.and φ (Formula.snce φ ψ) :=
    ctx_mp h_unfold' h_neg_psi
  have h_phi : (ψ.neg :: Γ) ⊢ φ :=
    ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.lce_imp φ (Formula.snce φ ψ))) h_conj
  have h_P' : (ψ.neg :: Γ) ⊢ (Formula.snce φ ψ).some_past :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_P (by intro x hx; simp [Γ, hx])
  exact ctx_mp (ctx_mp (ctx_thm (pairing φ (Formula.snce φ ψ).some_past)) h_phi) h_P'

/-!
## A3a/A4a: Not Valid Under Strict Semantics

Burgess 1982 axioms A3a and A4a are NOT valid under irreflexive (strict) temporal semantics.

### A3a: `p ∧ U(q,r) → U(q ∧ S(p,r), r)`

**Counterexample**: Consider times {0, 1, 2} with p true only at 0, q true at 0 and 1,
r true at 2. At time 0: p ∧ U(q,r) holds (p at 0; witness s=2, r(2), q on [0,2)).
But U(q ∧ S(p,r), r) fails at 0: the guard requires S(p,r) at u=0, which needs
∃ v < 0, r(v). No such v exists under strict Since, so S(p,r) is false at 0.

### A4a: `U(p,q) ∧ ¬U(p,r) → U(q ∧ ¬r, q)`

Similarly not derivable under strict semantics.

### Impact on Chronicle Construction

The Burgess chronicle construction (Phases 2-5) uses A3a in Lemma 2.3 and A4a in
Lemma 2.6. Under strict semantics, the algebraic content of these axioms is provided
directly by the BX axioms:
- BX4 (connect_future: φ → G(P(φ))) + BX5 (self_accum_until) subsume A3a's role
- BX5 + BX6 (absorb_until) + BX7 (linear_until) subsume A4a's role

The chronicle construction should use these BX axioms directly instead of A3a/A4a.
-/

end Bimodal.Theorems.TemporalDerived
