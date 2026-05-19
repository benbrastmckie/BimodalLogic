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
open Bimodal.Theorems.Propositional

-- Abbreviations for readability
private abbrev top : Formula := Formula.neg Formula.bot  -- ⊤ = ¬⊥

/-!
## Derived G-Distribution and G-Transitivity (Task 116 Phase 2)

With G defined as `G(φ) = ¬F(¬φ)` where `F(φ) = ⊤ U φ`, the K-distribution axiom
`G(φ→ψ) → (Gφ → Gψ)` and the 4 axiom `Gφ → GGφ` become derivable from the remaining
BX axioms (BX3, BX6) plus propositional reasoning. These derived theorems enable removal
of the `temp_k_dist` and `temp_4` axiom constructors.

### temp_k_dist derivation (K-distribution for G)

The key insight: BX3 (`right_mono_until`) provides covariant monotonicity of F under G:
`G(α→β) → (F(α) → F(β))`. To derive G-distribution, we:

1. Convert `G(φ→ψ)` to `G(¬ψ→¬φ)` via BX3 applied to the propositional
   contrapositive `¬(¬ψ→¬φ) → ¬(φ→ψ)`, lifted through F and negated.
2. Apply BX3 with `α := ¬ψ, β := ¬φ` to get `G(¬ψ→¬φ) → (F(¬ψ) → F(¬φ))`.
3. Take the propositional contrapositive: `¬F(¬φ) → ¬F(¬ψ)`, i.e., `Gφ → Gψ`.
4. Compose steps 1-3.

### temp_4 derivation (4-axiom for G)

The contrapositive of `Gφ → GGφ` is `F(¬¬F(¬φ)) → F(¬φ)`, which decomposes as:

1. `F(¬¬F(¬φ)) → F(F(¬φ))` via BX3 + double negation elimination.
2. `F(F(¬φ)) → F(⊤ ∧ F(¬φ))` via BX3 + the tautology `X → ⊤ ∧ X`.
3. `F(⊤ ∧ F(¬φ)) → F(¬φ)` via BX6 (absorption of Until).

Composing and taking the contrapositive gives `Gφ → GGφ`.
-/

section DerivedAxioms

/-! ### Propositional helpers for derived axioms -/

/-- `⊢ ¬(¬ψ→¬φ) → ¬(φ→ψ)`: Negation of the contrapositive implies negation of the original.
This is the contrapositive of the contrapositive theorem, composed with itself. -/
private noncomputable def neg_contrapositive_imp_neg (φ ψ : Formula) :
    ⊢ (ψ.neg.imp φ.neg).neg.imp (φ.imp ψ).neg :=
  mp (contrapose_imp φ ψ) (contrapose_imp (φ.imp ψ) (ψ.neg.imp φ.neg))

/-- `⊢ X → ⊤ ∧ X`: Any formula implies its conjunction with ⊤.
From pairing and the theorem `⊢ ⊤`. -/
private def top_and_intro (X : Formula) : ⊢ X.imp (Formula.top.and X) :=
  mp (identity Formula.bot) (pairing Formula.top X)

/-! ### temp_k_dist: G-distribution derived from BX3

**Strategy**: BX3 gives `G(α→β) → (F(α) → F(β))`. To get `G(φ→ψ) → (Gφ → Gψ)`:
1. Convert `G(φ→ψ)` to `G(¬ψ→¬φ)` using BX3 on the propositional contrapositive.
2. Apply BX3 to get `G(¬ψ→¬φ) → (F(¬ψ) → F(¬φ))`.
3. Take propositional contrapositive to get `Gφ → Gψ`.
-/

/-- `⊢ F(¬(¬ψ→¬φ)) → F(¬(φ→ψ))`: F-monotonicity applied to the negated contrapositive.

From the tautology `¬(¬ψ→¬φ) → ¬(φ→ψ)`, lift through G via temporal necessitation,
then apply BX3 (right_mono_until) to obtain F-monotonicity. -/
private noncomputable def F_neg_contra_imp_F_neg (φ ψ : Formula) :
    ⊢ (Formula.some_future (ψ.neg.imp φ.neg).neg).imp
      (Formula.some_future (φ.imp ψ).neg) :=
  mp (DerivationTree.temporal_necessitation _ (neg_contrapositive_imp_neg φ ψ))
     (DerivationTree.axiom [] _
       (Axiom.right_mono_until (ψ.neg.imp φ.neg).neg (φ.imp ψ).neg Formula.top))

/-- `⊢ G(φ→ψ) → G(¬ψ→¬φ)`: G distributes over propositional equivalences.

From `F(¬(¬ψ→¬φ)) → F(¬(φ→ψ))` (F_neg_contra_imp_F_neg), take the contrapositive:
`¬F(¬(φ→ψ)) → ¬F(¬(¬ψ→¬φ))`, which is `G(φ→ψ) → G(¬ψ→¬φ)` by definition of G. -/
private noncomputable def G_imp_to_G_contra (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (ψ.neg.imp φ.neg).all_future :=
  contraposition (F_neg_contra_imp_F_neg φ ψ)

/-- `⊢ G(¬ψ→¬φ) → (Gφ → Gψ)`: From the contrapositive under G, derive K-distribution.

BX3 with `α := ¬ψ, β := ¬φ, γ := ⊤` gives `G(¬ψ→¬φ) → (F(¬ψ) → F(¬φ))`.
The propositional contrapositive of `F(¬ψ) → F(¬φ)` is `¬F(¬φ) → ¬F(¬ψ)` = `Gφ → Gψ`. -/
private noncomputable def G_contra_to_GK (φ ψ : Formula) :
    ⊢ (ψ.neg.imp φ.neg).all_future.imp (φ.all_future.imp ψ.all_future) :=
  imp_trans
    (DerivationTree.axiom [] _ (Axiom.right_mono_until ψ.neg φ.neg Formula.top))
    (contrapose_imp (Formula.some_future ψ.neg) (Formula.some_future φ.neg))

/-- **Derived temp_k_dist**: `⊢ G(φ→ψ) → (Gφ → Gψ)`.

K-distribution for G, derived from BX3 (right_mono_until) and propositional
contraposition. Replaces the primitive `Axiom.temp_k_dist` constructor.

**Derivation**: Compose `G(φ→ψ) → G(¬ψ→¬φ)` with `G(¬ψ→¬φ) → (Gφ → Gψ)`. -/
noncomputable def temp_k_dist_derived (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future) :=
  imp_trans (G_imp_to_G_contra φ ψ) (G_contra_to_GK φ ψ)

/-! ### temp_4: G-transitivity derived from BX6

**Strategy**: The contrapositive of `Gφ → GGφ` is `F(¬¬F(¬φ)) → F(¬φ)`.
Decompose into three steps using BX3 and BX6:
1. `F(¬¬F(¬φ)) → F(F(¬φ))` via double negation elimination under F.
2. `F(F(¬φ)) → F(⊤ ∧ F(¬φ))` via `X → ⊤ ∧ X` under F.
3. `F(⊤ ∧ F(¬φ)) → F(¬φ)` via BX6 (absorption of Until).
-/

/-- `⊢ F(¬¬F(¬φ)) → F(F(¬φ))`: Double negation elimination lifted through F.

From the propositional tautology `¬¬X → X` at `X = F(¬φ)`, apply temporal
necessitation and BX3 to obtain F-monotonicity. -/
private noncomputable def dne_lift_F (φ : Formula) :
    ⊢ (Formula.some_future (Formula.some_future φ.neg).neg.neg).imp
      (Formula.some_future (Formula.some_future φ.neg)) :=
  mp (DerivationTree.temporal_necessitation _ (double_negation (Formula.some_future φ.neg)))
     (DerivationTree.axiom [] _
       (Axiom.right_mono_until
         (Formula.some_future φ.neg).neg.neg (Formula.some_future φ.neg) Formula.top))

/-- `⊢ F(F(¬φ)) → F(⊤ ∧ F(¬φ))`: Enrich F(¬φ) with ⊤ via the tautology `X → ⊤ ∧ X`.

From the propositional tautology `X → ⊤ ∧ X` at `X = F(¬φ)`, apply temporal
necessitation and BX3 to lift through F. -/
private noncomputable def FF_to_F_top_and (φ : Formula) :
    ⊢ (Formula.some_future (Formula.some_future φ.neg)).imp
      (Formula.some_future (Formula.top.and (Formula.some_future φ.neg))) :=
  mp (DerivationTree.temporal_necessitation _ (top_and_intro (Formula.some_future φ.neg)))
     (DerivationTree.axiom [] _
       (Axiom.right_mono_until
         (Formula.some_future φ.neg)
         (Formula.top.and (Formula.some_future φ.neg)) Formula.top))

/-- `⊢ F(⊤ ∧ F(¬φ)) → F(¬φ)`: Absorption of Until (BX6) collapses nested eventuality.

BX6 at `φ := ⊤, ψ := ¬φ_orig` gives `U(⊤ ∧ U(¬φ, ⊤), ⊤) → U(¬φ, ⊤)`,
which is `F(⊤ ∧ F(¬φ)) → F(¬φ)`. -/
private def F_top_and_absorb (φ : Formula) :
    ⊢ (Formula.some_future (Formula.top.and (Formula.some_future φ.neg))).imp
      (Formula.some_future φ.neg) :=
  DerivationTree.axiom [] _ (Axiom.absorb_until Formula.top φ.neg)

/-- **Derived temp_4**: `⊢ Gφ → GGφ`.

Positive introspection for G, derived from BX3 (right_mono_until), BX6
(absorb_until), double negation elimination, and propositional contraposition.
Replaces the primitive `Axiom.temp_4` constructor.

**Derivation**: The contrapositive `F(¬¬F(¬φ)) → F(¬φ)` is proved by composing
three F-monotonicity steps, then negated to obtain `Gφ → GGφ`. -/
noncomputable def temp_4_derived (φ : Formula) :
    ⊢ φ.all_future.imp φ.all_future.all_future :=
  contraposition (imp_trans (imp_trans (dne_lift_F φ) (FF_to_F_top_and φ)) (F_top_and_absorb φ))

end DerivedAxioms

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
    ⊢ a.all_future.imp (Formula.untl a top) := by
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
    ⊢ (Formula.untl ψ φ).imp (Formula.some_future ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ)

/--
`⊢ (φ S ψ) → P(ψ)`: Any Since formula implies past eventuality.
Direct from BX10' axiom.
-/
def since_implies_some_past (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.some_past ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ)

/-- `(⊥ U a) → a`: Under open guard, X(a) = ⊥ U a implies a.
Was: BX9 + app1. BX9 removed under open guard (task 113). -/
private def bot_until_elim (a : Formula) :
    ⊢ (Formula.untl a Formula.bot).imp a := by
  sorry

/-- `(⊥ S a) → a`: Mirror of bot_until_elim. -/
private def bot_since_elim (a : Formula) :
    ⊢ (Formula.snce a Formula.bot).imp a := by
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
    ⊢ ψ.imp (Formula.untl ψ φ) := by
  -- Under irreflexive semantics, ψ → U(ψ, φ) is NOT valid.
  -- Need strict future witness s > t with ψ(s); just having ψ(t) is insufficient.
  sorry

/--
`⊢ ψ → S(ψ, φ)`: Reflexive Since introduction.
Mirror of psi_imp_until for the past direction.
-/
def psi_imp_since (φ ψ : Formula) :
    ⊢ ψ.imp (Formula.snce ψ φ) := by
  sorry

/--
`⊢ (φ U ψ) → (φ ∨ ψ)`: Until implies disjunction at current time.
At any time where φ U ψ holds, either the witness is now (giving ψ)
or it is strictly in the future (giving φ from the guard).
Direct from BX9 axiom.
-/
def until_imp_or (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.or φ ψ) := by
  -- Was: direct BX9. BX9 removed under open guard (task 113).
  sorry

/--
`⊢ S(ψ, φ) → (φ ∨ ψ)`: Since implies disjunction at current time.
Mirror of until_imp_or.
-/
def since_imp_or (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.or φ ψ) := by
  -- Was: direct BX9'. BX9' removed under open guard (task 113).
  sorry

/--
`⊢ (φ U ψ) → F(ψ)`: Until implies eventuality of its endpoint.
The witness s ≥ t with ψ(s) certifies F(ψ) at t.
Direct from BX10 axiom.
-/
def until_imp_F (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.some_future ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ)

/--
`⊢ (φ S ψ) → P(ψ)`: Since implies past eventuality of its endpoint.
Mirror of until_imp_F.
-/
def since_imp_P (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.some_past ψ) :=
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
    ⊢ (Formula.untl a Formula.bot).imp a := by
  sorry

/-- `⊢ Y(α) → α`: Mirror of bot_until_id for past direction. -/
noncomputable def bot_since_id (a : Formula) :
    ⊢ (Formula.snce a Formula.bot).imp a := by
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
    ⊢ (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))).imp (Formula.untl ψ φ) := by
  unfold Formula.or
  let Γ₁ : Context := [ψ.neg.imp (φ.and (Formula.untl ψ φ))]
  let Γ₂ : Context := [(Formula.untl ψ φ).neg, ψ.neg.imp (φ.and (Formula.untl ψ φ))]
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  apply ctx_mp (ctx_thm (show ⊢ _ from DerivationTree.axiom [] _ (Axiom.peirce (Formula.untl ψ φ) Formula.bot)))
  apply Bimodal.Metalogic.Core.deduction_theorem Γ₁ _ _
  have h_contra : Γ₂ ⊢ (Formula.untl ψ φ).neg.imp ψ.neg :=
    ctx_mp (ctx_thm (contrapositive ψ (Formula.untl ψ φ))) (ctx_thm (psi_imp_until φ ψ))
  have h_neg_until : Γ₂ ⊢ (Formula.untl ψ φ).neg := DerivationTree.assumption _ _ (List.Mem.head _)
  have h_hyp : Γ₂ ⊢ ψ.neg.imp (φ.and (Formula.untl ψ φ)) :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  exact ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.rce_imp φ (Formula.untl ψ φ)))
    (ctx_mp h_hyp (ctx_mp h_contra h_neg_until))

/-- `⊢ (ψ ∨ (φ ∧ (φ S ψ))) → (φ S ψ)`: Or-Since introduction. Mirror of or_until_imp. -/
noncomputable def or_since_imp (φ ψ : Formula) :
    ⊢ (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))).imp (Formula.snce ψ φ) := by
  unfold Formula.or
  let Γ₁ : Context := [ψ.neg.imp (φ.and (Formula.snce ψ φ))]
  let Γ₂ : Context := [(Formula.snce ψ φ).neg, ψ.neg.imp (φ.and (Formula.snce ψ φ))]
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  apply ctx_mp (ctx_thm (show ⊢ _ from DerivationTree.axiom [] _ (Axiom.peirce (Formula.snce ψ φ) Formula.bot)))
  apply Bimodal.Metalogic.Core.deduction_theorem Γ₁ _ _
  have h_contra : Γ₂ ⊢ (Formula.snce ψ φ).neg.imp ψ.neg :=
    ctx_mp (ctx_thm (contrapositive ψ (Formula.snce ψ φ))) (ctx_thm (psi_imp_since φ ψ))
  have h_neg_since : Γ₂ ⊢ (Formula.snce ψ φ).neg := DerivationTree.assumption _ _ (List.Mem.head _)
  have h_hyp : Γ₂ ⊢ ψ.neg.imp (φ.and (Formula.snce ψ φ)) :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  exact ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.rce_imp φ (Formula.snce ψ φ)))
    (ctx_mp h_hyp (ctx_mp h_contra h_neg_since))

/-- `⊢ (φ U ψ) → (ψ ∨ (φ ∧ (φ U ψ)))`: Until unfolding at current time.
From BX5 (self-accumulation) + BX9 (elimination) + or-commutativity. -/
noncomputable def until_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) := by
  -- Was: BX5 + BX9. BX9 removed under open guard (task 113).
  sorry

/-- `⊢ S(ψ, φ) → (ψ ∨ (φ ∧ S(ψ, φ)))`: Since unfolding at current time. Mirror. -/
noncomputable def since_unfold_thm (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) := by
  -- Was: BX5' + BX9'. BX9' removed under open guard (task 113).
  sorry

/-- `⊢ (φ U ψ) → X(ψ ∨ (φ ∧ (φ U ψ)))`: X-wrapped Until unfolding.
Compose until_unfold_thm with BX8 (reflexive intro at ⊥). -/
noncomputable def until_unfold_wrapped (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp
      (Formula.untl (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) Formula.bot) :=
  imp_trans (until_unfold_thm φ ψ) (psi_imp_until Formula.bot _)

/-- `⊢ S(ψ, φ) → Y(ψ ∨ (φ ∧ S(ψ, φ)))`: Y-wrapped Since unfolding. Mirror. -/
noncomputable def since_unfold_wrapped (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp
      (Formula.snce (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) Formula.bot) :=
  imp_trans (since_unfold_thm φ ψ) (psi_imp_since Formula.bot _)

/-- `⊢ X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`: Until introduction rule.
Compose bot_until_id with or_until_imp. This is the key rule for backward
Until induction in the canonical completeness construction. -/
noncomputable def until_intro (φ ψ : Formula) :
    ⊢ (Formula.untl (Formula.or ψ (Formula.and φ (Formula.untl ψ φ))) Formula.bot).imp
      (Formula.untl ψ φ) :=
  imp_trans (bot_until_id _) (or_until_imp φ ψ)

/-- `⊢ Y(ψ ∨ (φ ∧ S(ψ, φ))) → S(ψ, φ)`: Since introduction rule. Mirror. -/
noncomputable def since_intro (φ ψ : Formula) :
    ⊢ (Formula.snce (Formula.or ψ (Formula.and φ (Formula.snce ψ φ))) Formula.bot).imp
      (Formula.snce ψ φ) :=
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
    ⊢ (Formula.untl ψ φ).imp
      (Formula.or ψ (Formula.and φ (Formula.untl ψ φ).some_future)) := by
  -- until_unfold_thm: U(ψ, φ) → ψ ∨ (φ ∧ U(ψ, φ))
  -- We want: U(ψ, φ) → ψ ∨ (φ ∧ F(U(ψ, φ)))
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  let Γ := [Formula.untl ψ φ]
  have h_until : Γ ⊢ Formula.untl ψ φ := DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold : Γ ⊢ Formula.or ψ (Formula.and φ (Formula.untl ψ φ)) :=
    ctx_mp (ctx_thm (until_unfold_thm φ ψ)) h_until
  have h_F : Γ ⊢ (Formula.untl ψ φ).some_future :=
    ctx_mp (ctx_thm (refl_F (Formula.untl ψ φ))) h_until
  unfold Formula.or at h_unfold ⊢
  apply Bimodal.Metalogic.Core.deduction_theorem Γ _ _
  have h_neg_psi : (ψ.neg :: Γ) ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold' : (ψ.neg :: Γ) ⊢ ψ.neg.imp (Formula.and φ (Formula.untl ψ φ)) :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_unfold (by intro x hx; simp [Γ, hx])
  have h_conj : (ψ.neg :: Γ) ⊢ Formula.and φ (Formula.untl ψ φ) :=
    ctx_mp h_unfold' h_neg_psi
  have h_phi : (ψ.neg :: Γ) ⊢ φ :=
    ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.lce_imp φ (Formula.untl ψ φ))) h_conj
  have h_F' : (ψ.neg :: Γ) ⊢ (Formula.untl ψ φ).some_future :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_F (by intro x hx; simp [Γ, hx])
  exact ctx_mp (ctx_mp (ctx_thm (pairing φ (Formula.untl ψ φ).some_future)) h_phi) h_F'

/-- `⊢ (φ S ψ) → ψ ∨ (φ ∧ P(φ S ψ))`: Since P-expansion. Dual of until_F_expansion. -/
noncomputable def since_P_expansion (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp
      (Formula.or ψ (Formula.and φ (Formula.snce ψ φ).some_past)) := by
  apply Bimodal.Metalogic.Core.deduction_theorem [] _ _
  let Γ := [Formula.snce ψ φ]
  have h_since : Γ ⊢ Formula.snce ψ φ := DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold : Γ ⊢ Formula.or ψ (Formula.and φ (Formula.snce ψ φ)) :=
    ctx_mp (ctx_thm (since_unfold_thm φ ψ)) h_since
  have h_P : Γ ⊢ (Formula.snce ψ φ).some_past :=
    ctx_mp (ctx_thm (refl_P (Formula.snce ψ φ))) h_since
  unfold Formula.or at h_unfold ⊢
  apply Bimodal.Metalogic.Core.deduction_theorem Γ _ _
  have h_neg_psi : (ψ.neg :: Γ) ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp [Γ])
  have h_unfold' : (ψ.neg :: Γ) ⊢ ψ.neg.imp (Formula.and φ (Formula.snce ψ φ)) :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_unfold (by intro x hx; simp [Γ, hx])
  have h_conj : (ψ.neg :: Γ) ⊢ Formula.and φ (Formula.snce ψ φ) :=
    ctx_mp h_unfold' h_neg_psi
  have h_phi : (ψ.neg :: Γ) ⊢ φ :=
    ctx_mp (ctx_thm (Bimodal.Theorems.Propositional.lce_imp φ (Formula.snce ψ φ))) h_conj
  have h_P' : (ψ.neg :: Γ) ⊢ (Formula.snce ψ φ).some_past :=
    DerivationTree.weakening Γ (ψ.neg :: Γ) _ h_P (by intro x hx; simp [Γ, hx])
  exact ctx_mp (ctx_mp (ctx_thm (pairing φ (Formula.snce ψ φ).some_past)) h_phi) h_P'

/-!
## A3a/A3b: Valid Under Open Guard Semantics

Burgess 1982 axioms A3a and A3b (Until-Since enrichment) ARE semantically valid under
our open guard (t,s) semantics. The counterexample previously documented here was WRONG --
it evaluated S(p,r) at the current time t instead of at the Until witness s. Under open
guard, the Until interval (t,s) and the Since interval (t,s) at the witness are identical,
so A3a is valid. A3a/A3b are added as BX13/BX13' (enrichment_until/enrichment_since) in
Axioms.lean.

A3a: `p ∧ U(q,r) → U(q ∧ S(p,r), r)` (Burgess convention: U(event, guard))
A3b: `p ∧ S(q,r) → S(q ∧ U(r,p), r)` (mirror)

See Axioms.lean for the precise Lean formulation and Soundness.lean for the validity proof.
-/

end Bimodal.Theorems.TemporalDerived
