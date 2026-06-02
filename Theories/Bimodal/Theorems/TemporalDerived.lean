import Bimodal.ProofSystem.Derivation
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.GeneralizedNecessitation
import Bimodal.Theorems.Propositional.Connectives

/-!
# Temporal Derived Theorems from BX Axioms

This module contains temporal theorems derived from the Burgess-Xu (BX) axiom system
under open guard semantics `(t,s)` (task 113).

## Status After Open Guard Refactoring (Task 113)

BX8/BX8' (until_step/since_step) and BX9/BX9' (until_elim/since_elim) were removed
because they are not sound under open guard semantics.

### Removed (Task 173)

27 definitions not valid under open guard semantics have been archived to
`Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean`. See that file
for the complete list, type signatures, and original proof attempts. Closed-guard
originals remain in `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

Definitions removed (19 direct sorry stubs + 8 transitive dependents):
- BX9-dependent: bot_until_bot_absurd, bot_since_bot_absurd, bot_until_elim,
  bot_since_elim, until_imp_or, since_imp_or, bot_until_id, bot_since_id,
  until_unfold_thm, since_unfold_thm
- BX8-dependent: psi_imp_until, psi_imp_since, G_implies_topUntil
- Reflexive order: refl_F, refl_P
- Seriality: G_bot_absurd, H_bot_absurd
- Density: density_derivable, past_density_derivable
- Transitive dependents: or_until_imp, or_since_imp, until_unfold_wrapped,
  since_unfold_wrapped, until_intro, since_intro, until_F_expansion,
  since_P_expansion

### Sorry-free (remaining in this file):
- `G_distribution`: Derived from BX3 (temp_k_dist_derived)
- `G_transitivity`: Derived from BX3 + BX6 (temp_4_derived)
- `connect_future_thm`, `connect_past_thm`: Direct BX4/BX4'
- `G_implies_G_id`: Propositional
- `until_implies_some_future`, `since_implies_some_past`: Direct BX10/BX10'
- `until_imp_F`, `since_imp_P`: Direct BX10/BX10'
- `contrapositive`, `formula_or_comm`: Pure propositional

## References

- Burgess 1982/84: Until-Since temporal logic axiomatization
- Task 83: BX axiom system refactor
- Task 113: Open guard refactoring
- Task 173: Archive of 27 sorry-tainted definitions
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
       (Axiom.right_mono_until (ψ.neg.imp φ.neg).neg (φ.imp ψ).neg Formula.top) trivial)

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
    (DerivationTree.axiom [] _ (Axiom.right_mono_until ψ.neg φ.neg Formula.top) trivial)
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
         (Formula.some_future φ.neg).neg.neg (Formula.some_future φ.neg) Formula.top) trivial)

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
         (Formula.top.and (Formula.some_future φ.neg)) Formula.top) trivial)

/-- `⊢ F(⊤ ∧ F(¬φ)) → F(¬φ)`: Absorption of Until (BX6) collapses nested eventuality.

BX6 at `φ := ⊤, ψ := ¬φ_orig` gives `U(⊤ ∧ U(¬φ, ⊤), ⊤) → U(¬φ, ⊤)`,
which is `F(⊤ ∧ F(¬φ)) → F(¬φ)`. -/
private def F_top_and_absorb (φ : Formula) :
    ⊢ (Formula.some_future (Formula.top.and (Formula.some_future φ.neg))).imp
      (Formula.some_future φ.neg) :=
  DerivationTree.axiom [] _ (Axiom.absorb_until Formula.top φ.neg) trivial

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
All definitions below are sorry-free.
-/

/--
`⊢ G(φ → ψ) → (G(φ) → G(ψ))`: G-distribution. Derived from BX3 (right_mono_until).
-/
noncomputable def G_distribution (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future) :=
  temp_k_dist_derived φ ψ

/--
`⊢ H(φ → ψ) → (H(φ) → H(ψ))`: H-distribution. Derived via temporal duality from G-distribution.
-/
noncomputable def H_distribution (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past) :=
  Bimodal.Theorems.past_k_dist φ ψ

/--
`⊢ G(φ) → G(G(φ))`: G-transitivity. Derived from BX3 + BX6.
-/
noncomputable def G_transitivity (φ : Formula) :
    ⊢ φ.all_future.imp φ.all_future.all_future :=
  temp_4_derived φ

/--
`⊢ H(φ) → H(H(φ))`: H-transitivity. Derived via temporal duality from G-transitivity.
-/
noncomputable def H_transitivity (φ : Formula) :
    ⊢ φ.all_past.imp φ.all_past.all_past := by
  -- Derive by applying temporal duality to G-transitivity of swap_temporal φ
  let ψ := φ.swap_temporal
  have h1 : ⊢ ψ.all_future.imp ψ.all_future.all_future :=
    temp_4_derived ψ
  have h2 : ⊢ (ψ.all_future.imp ψ.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h1
  simp only [Formula.swap_temporal_all_future, Formula.swap_temporal] at h2
  have h_inv : ψ.swap_temporal = φ := Formula.swap_temporal_involution φ
  rw [h_inv] at h2
  exact h2

/--
`⊢ φ → G(P(φ))`: Temporal connectedness (future). Direct axiom (BX4).
The present is always in the past of the future.
-/
def connect_future_thm (φ : Formula) :
    ⊢ φ.imp (φ.some_past.all_future) :=
  DerivationTree.axiom [] _ (Axiom.connect_future φ) trivial

/--
`⊢ φ → H(F(φ))`: Temporal connectedness (past). Direct axiom (BX4').
The present is always in the future of the past.
-/
def connect_past_thm (φ : Formula) :
    ⊢ φ.imp (φ.some_future.all_past) :=
  DerivationTree.axiom [] _ (Axiom.connect_past φ) trivial

/--
`⊢ G(a) → G(a → a)`: G(a→a) is a theorem, so G(a) → G(a→a) by prop_s.
-/
def G_implies_G_id (a : Formula) :
    ⊢ a.all_future.imp (a.imp a).all_future :=
  mp (DerivationTree.temporal_necessitation _ (identity a))
     (DerivationTree.axiom [] _ (Axiom.prop_s (a.imp a).all_future a.all_future) trivial)

/-!
## BX10-Derived Theorems

Under open guard semantics, BX10/BX10' (eventuality extraction) provide
the basic Until/Since eventuality lemmas.
-/

/--
`⊢ (φ U ψ) → F(ψ)`: Any Until formula implies eventuality of its second argument.
Direct from BX10 axiom.
-/
def until_implies_some_future (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.some_future ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ) trivial

/--
`⊢ (φ S ψ) → P(ψ)`: Any Since formula implies past eventuality.
Direct from BX10' axiom.
-/
def since_implies_some_past (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.some_past ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ) trivial

/--
`⊢ (φ U ψ) → F(ψ)`: Until implies eventuality of its endpoint.
The witness s ≥ t with ψ(s) certifies F(ψ) at t.
Direct from BX10 axiom.
-/
def until_imp_F (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.some_future ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ) trivial

/--
`⊢ (φ S ψ) → P(ψ)`: Since implies past eventuality of its endpoint.
Mirror of until_imp_F.
-/
def since_imp_P (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.some_past ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ) trivial

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
## Category B: Temporal Monotonicity (4 computable theorems)

Monotonicity lemmas for F, P operators as single-step derived rules.
Each wraps a single BX axiom instantiation with a named, reusable pattern.
-/

section TemporalMonotonicity

/--
`⊢ G(φ → ψ) → (F(φ) → F(ψ))`: F is monotone under G-guarded implication.

Direct from BX3 (right_mono_until) with χ := ⊤:
`G(φ → ψ) → (untl(φ, ⊤) → untl(ψ, ⊤))` = `G(φ → ψ) → (F(φ) → F(ψ))`.
-/
def F_mono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (φ.some_future.imp ψ.some_future) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ Formula.top) trivial

/--
`⊢ H(φ → ψ) → (P(φ) → P(ψ))`: P is monotone under H-guarded implication.

Direct from BX3' (right_mono_since) with χ := ⊤:
`H(φ → ψ) → (snce(φ, ⊤) → snce(ψ, ⊤))` = `H(φ → ψ) → (P(φ) → P(ψ))`.
-/
def P_mono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp (φ.some_past.imp ψ.some_past) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_since φ ψ Formula.top) trivial

/--
`⊢ G(φ → ψ) → (G(φ) → G(ψ))`: G is monotone (alias for G_distribution).

This is `G_distribution` under a discoverable name. Noncomputable because
it depends on the derived `temp_k_dist_derived`.
-/
noncomputable abbrev G_mono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future) :=
  G_distribution φ ψ

/--
`⊢ H(φ → ψ) → (H(φ) → H(ψ))`: H is monotone (alias for H_distribution).

This is `H_distribution` under a discoverable name. Noncomputable because
it depends on the derived `past_k_dist`.
-/
noncomputable abbrev H_mono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp (φ.all_past.imp ψ.all_past) :=
  H_distribution φ ψ

end TemporalMonotonicity

/-!
## Category E: Until/Since Structural Lemmas (4 computable theorems)

Monotonicity wrappers for Until/Since guard and event positions.
Each is a single BX axiom instantiation providing a named, reusable pattern.
-/

section UntilSinceStructural

/--
`⊢ G(φ → χ) → ((ψ U φ) → (ψ U χ))`: Guard monotonicity of Until under G.

Direct from BX2G (left_mono_until_G).
-/
def until_mono_guard (φ χ ψ : Formula) :
    ⊢ (φ.imp χ).all_future.imp ((Formula.untl ψ φ).imp (Formula.untl ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.left_mono_until_G φ χ ψ) trivial

/--
`⊢ H(φ → χ) → ((ψ S φ) → (ψ S χ))`: Guard monotonicity of Since under H.

Direct from BX2H (left_mono_since_H).
-/
def since_mono_guard (φ χ ψ : Formula) :
    ⊢ (φ.imp χ).all_past.imp ((Formula.snce ψ φ).imp (Formula.snce ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.left_mono_since_H φ χ ψ) trivial

/--
`⊢ G(φ → ψ) → ((φ U χ) → (ψ U χ))`: Event monotonicity of Until under G.

Direct from BX3 (right_mono_until).
-/
def until_mono_event (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp ((Formula.untl φ χ).imp (Formula.untl ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ χ) trivial

/--
`⊢ H(φ → ψ) → ((φ S χ) → (ψ S χ))`: Event monotonicity of Since under H.

Direct from BX3' (right_mono_since).
-/
def since_mono_event (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp ((Formula.snce φ χ).imp (Formula.snce ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_since φ ψ χ) trivial

end UntilSinceStructural

/-!
## Category C3-C4: Temporal Duality Lemmas (2 computable theorems)

These express the relationship between F/G and P/H duality via double negation.
-/

section TemporalDuality

/--
`⊢ F(¬φ) → ¬(G(φ))`: If ¬φ is eventually true, then φ is not always true.

Since `G(φ) = ¬F(¬φ)`, we have `¬(G(φ)) = ¬¬F(¬φ)`.
Thus `F(¬φ) → ¬(G(φ))` is `F(¬φ) → ¬¬(F(¬φ))`, which is DNI at `F(¬φ)`.
-/
def F_neg_G (φ : Formula) :
    ⊢ (φ.neg.some_future).imp φ.all_future.neg :=
  dni (φ.neg.some_future)

/--
`⊢ P(¬φ) → ¬(H(φ))`: If ¬φ was once true, then φ was not always true.

Since `H(φ) = ¬P(¬φ)`, we have `¬(H(φ)) = ¬¬P(¬φ)`.
Thus `P(¬φ) → ¬(H(φ))` is `P(¬φ) → ¬¬(P(¬φ))`, which is DNI at `P(¬φ)`.
-/
def P_neg_H (φ : Formula) :
    ⊢ (φ.neg.some_past).imp φ.all_past.neg :=
  dni (φ.neg.some_past)

end TemporalDuality

/-!
## Category A: G/H Distribution Variants (4 noncomputable theorems)

These distribute G/H over connectives. Each replaces multiple primitive steps.
All depend on `G_distribution` / `H_distribution` and are therefore noncomputable.
-/

section DistributionVariants

/--
`⊢ G(φ) → G(ψ) → G(φ ∧ ψ)`: G distributes into conjunction introduction.

From `pairing φ ψ : ⊢ φ → ψ → φ ∧ ψ`, temporal necessitate to get
`G(φ → ψ → φ ∧ ψ)`, then apply G_distribution twice:
- First: `G φ → G(ψ → φ ∧ ψ)`
- Second: `G(ψ → φ ∧ ψ) → (G ψ → G(φ ∧ ψ))`
-/
noncomputable def G_and_intro (φ ψ : Formula) :
    ⊢ φ.all_future.imp (ψ.all_future.imp (φ.and ψ).all_future) :=
  let g_pair := DerivationTree.temporal_necessitation _ (pairing φ ψ)
  let step1 := mp g_pair (G_distribution φ (ψ.imp (φ.and ψ)))
  imp_trans step1 (G_distribution ψ (φ.and ψ))

/--
`⊢ H(φ) → H(ψ) → H(φ ∧ ψ)`: H distributes into conjunction introduction.

Mirror of `G_and_intro` using `H_distribution` and `past_necessitation`.
-/
noncomputable def H_and_intro (φ ψ : Formula) :
    ⊢ φ.all_past.imp (ψ.all_past.imp (φ.and ψ).all_past) :=
  let h_pair := Bimodal.Theorems.past_necessitation _ (pairing φ ψ)
  let step1 := mp h_pair (H_distribution φ (ψ.imp (φ.and ψ)))
  imp_trans step1 (H_distribution ψ (φ.and ψ))

/--
`⊢ G(φ → ψ) → G(ψ → χ) → G(φ → χ)`: G distributes over implication transitivity.

From `b_combinator : ⊢ (ψ → χ) → (φ → ψ) → (φ → χ)`, temporal necessitate to get
`G((ψ → χ) → (φ → ψ) → (φ → χ))`, then apply G_distribution twice:
- First: `G(ψ → χ) → G((φ → ψ) → (φ → χ))`
- Second: `G((φ → ψ) → (φ → χ)) → (G(φ → ψ) → G(φ → χ))`
Then flip the argument order with `theorem_flip`-style composition.
-/
noncomputable def G_imp_trans (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp ((ψ.imp χ).all_future.imp (φ.imp χ).all_future) :=
  let g_b := DerivationTree.temporal_necessitation _ (@b_combinator .Base (A := φ) (B := ψ) (C := χ))
  let step1 := mp g_b (G_distribution (ψ.imp χ) ((φ.imp ψ).imp (φ.imp χ)))
  let step2 := imp_trans step1 (G_distribution (φ.imp ψ) (φ.imp χ))
  -- step2 : G(ψ → χ) → G(φ → ψ) → G(φ → χ)
  -- Need: G(φ → ψ) → G(ψ → χ) → G(φ → χ)
  mp step2 (@theorem_flip .Base
    (A := (ψ.imp χ).all_future)
    (B := (φ.imp ψ).all_future)
    (C := (φ.imp χ).all_future))

/--
`⊢ H(φ → ψ) → H(ψ → χ) → H(φ → χ)`: H distributes over implication transitivity.

Mirror of `G_imp_trans` using `H_distribution` and `past_necessitation`.
-/
noncomputable def H_imp_trans (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp ((ψ.imp χ).all_past.imp (φ.imp χ).all_past) :=
  let h_b := Bimodal.Theorems.past_necessitation _ (@b_combinator .Base (A := φ) (B := ψ) (C := χ))
  let step1 := mp h_b (H_distribution (ψ.imp χ) ((φ.imp ψ).imp (φ.imp χ)))
  let step2 := imp_trans step1 (H_distribution (φ.imp ψ) (φ.imp χ))
  mp step2 (@theorem_flip .Base
    (A := (ψ.imp χ).all_past)
    (B := (φ.imp ψ).all_past)
    (C := (φ.imp χ).all_past))

end DistributionVariants

/-!
## Category C1-C2: Temporal Contraposition (2 noncomputable theorems)

Contraposition lifted through temporal operators.
-/

section TemporalContraposition

/--
`⊢ G(φ → ψ) → G(¬ψ → ¬φ)`: Contraposition under G.

From `contrapose_imp φ ψ : ⊢ (φ → ψ) → (¬ψ → ¬φ)`, temporal necessitate to get
`G((φ → ψ) → (¬ψ → ¬φ))`, then apply G_distribution.
-/
noncomputable def G_contrapose (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_future.imp (ψ.neg.imp φ.neg).all_future :=
  let g_cp := DerivationTree.temporal_necessitation _ (contrapose_imp φ ψ)
  mp g_cp (G_distribution (φ.imp ψ) (ψ.neg.imp φ.neg))

/--
`⊢ H(φ → ψ) → H(¬ψ → ¬φ)`: Contraposition under H.

From `contrapose_imp φ ψ : ⊢ (φ → ψ) → (¬ψ → ¬φ)`, past necessitate to get
`H((φ → ψ) → (¬ψ → ¬φ))`, then apply H_distribution.
-/
noncomputable def H_contrapose (φ ψ : Formula) :
    ⊢ (φ.imp ψ).all_past.imp (ψ.neg.imp φ.neg).all_past :=
  let h_cp := Bimodal.Theorems.past_necessitation _ (contrapose_imp φ ψ)
  mp h_cp (H_distribution (φ.imp ψ) (ψ.neg.imp φ.neg))

end TemporalContraposition

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
