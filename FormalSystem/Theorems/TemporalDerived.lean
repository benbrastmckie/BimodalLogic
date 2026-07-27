/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.Propositional.Connectives
import FormalSystem.Automation.LemmaDB

/-!
# Temporal Derived Theorems from BX Axioms

This module contains temporal theorems derived from the Burgess-Xu (BX) axiom system
under open guard semantics `(t,s)`.

## Theorem Inventory (30 total: 8 original + 2 propositional + 20 new)

### Original Temporal Theorems (8)
- `gDistribution`, `hDistribution`: K-distribution (noncomputable, from BX3)
- `gTransitivity`, `hTransitivity`: 4-axiom (noncomputable, from BX3+BX6)
- `connectFutureThm`, `connectPastThm`: Direct BX4/BX4' (computable)
- `gImpliesGId`: Propositional (computable)
- `untilImpliesSomeFuture`, `sinceImpliesSomePast`: Direct BX10/BX10' (computable)
- `untilImpF`, `sinceImpP`: Direct BX10/BX10' (computable, duplicates of above)

### Category B: Temporal Monotonicity (4 computable + 2 noncomputable aliases)
- `fMono`: `G(φ→ψ) → (Fφ → Fψ)` -- BX3 with χ:=⊤
- `pMono`: `H(φ→ψ) → (Pφ → Pψ)` -- BX3' with χ:=⊤
- `gMono`: Alias for `gDistribution` (noncomputable)
- `hMono`: Alias for `hDistribution` (noncomputable)

### Category E: Until/Since Structural (4 computable)
- `untilMonoGuard`: `G(φ→χ) → (ψ U φ → ψ U χ)` -- BX2G
- `sinceMonoGuard`: `H(φ→χ) → (ψ S φ → ψ S χ)` -- BX2H
- `untilMonoEvent`: `G(φ→ψ) → (φ U χ → ψ U χ)` -- BX3
- `sinceMonoEvent`: `H(φ→ψ) → (φ S χ → ψ S χ)` -- BX3'

### Category C: Temporal Duality and Contraposition (4: 2 computable, 2 noncomputable)
- `fNegG`: `F(¬φ) → ¬(Gφ)` -- DNI (computable)
- `pNegH`: `P(¬φ) → ¬(Hφ)` -- DNI (computable)
- `gContrapose`: `G(φ→ψ) → G(¬ψ→¬φ)` -- gDistribution (noncomputable)
- `hContrapose`: `H(φ→ψ) → H(¬ψ→¬φ)` -- hDistribution (noncomputable)

### Category A: G/H Distribution Variants (4 noncomputable)
- `gAndIntro`: `Gφ → Gψ → G(φ∧ψ)` -- pairing + gDistribution
- `hAndIntro`: `Hφ → Hψ → H(φ∧ψ)` -- pairing + hDistribution
- `gImpTrans`: `G(φ→ψ) → G(ψ→χ) → G(φ→χ)` -- bCombinator + gDistribution
- `hImpTrans`: `H(φ→ψ) → H(ψ→χ) → H(φ→χ)` -- bCombinator + hDistribution

### Category D: Future-Past Interaction Chains (4 noncomputable)
- `connectFutureG`: `Gφ → G(G(Pφ))` -- connect_future + gDistribution
- `connectPastH`: `Hφ → H(H(Fφ))` -- connect_past + hDistribution
- `connectFutureChain`: `φ → G(H(F(Pφ)))` -- deep chain
- `connectPastChain`: `φ → H(G(P(Fφ)))` -- deep chain

### Propositional Helpers (2 noncomputable)
- `contrapositive`: `(A→B) → (¬B→¬A)`
- `formulaOrComm`: `(A∨B) → (B∨A)`

### Computability Summary
- **Computable** (8 unique, suitable for ProofStepExport): fMono, pMono,
  untilMonoGuard, sinceMonoGuard, untilMonoEvent, sinceMonoEvent, fNegG, pNegH
- **Noncomputable** (12): gDistribution, hDistribution, gTransitivity, hTransitivity,
  gMono, hMono, gAndIntro, hAndIntro, gImpTrans, hImpTrans,
  gContrapose, hContrapose, connectFutureG, connectPastH,
  connectFutureChain, connectPastChain

## Status After Open Guard Refactoring

BX8/BX8' (until_step/since_step) and BX9/BX9' (until_elim/since_elim) were removed
because they are not sound under open guard semantics.

### Removed

27 definitions not valid under open guard semantics have been archived to
`Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean`. See that file
for the complete list, type signatures, and original proof attempts. Closed-guard
originals remain in `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`.

## References

- Burgess 1982/84: Until-Since temporal logic axiomatization
- Archive of 27 sorry-tainted definitions
-/

namespace FormalSystem.Theorems.TemporalDerived

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Propositional

-- Abbreviations for readability

/-!
## Derived G-Distribution and G-Transitivity

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
  mp (contraposeImp φ ψ) (contraposeImp (φ.imp ψ) (ψ.neg.imp φ.neg))

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
    ⊢ (Formula.someFuture (ψ.neg.imp φ.neg).neg).imp
      (Formula.someFuture (φ.imp ψ).neg) :=
  mp (DerivationTree.temporal_necessitation _ (neg_contrapositive_imp_neg φ ψ))
     (DerivationTree.axiom [] _
       (Axiom.right_mono_until (ψ.neg.imp φ.neg).neg (φ.imp ψ).neg Formula.top) trivial)

/-- `⊢ G(φ→ψ) → G(¬ψ→¬φ)`: G distributes over propositional equivalences.

From `F(¬(¬ψ→¬φ)) → F(¬(φ→ψ))` (F_neg_contra_imp_F_neg), take the contrapositive:
`¬F(¬(φ→ψ)) → ¬F(¬(¬ψ→¬φ))`, which is `G(φ→ψ) → G(¬ψ→¬φ)` by definition of G. -/
private noncomputable def G_imp_to_G_contra (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (ψ.neg.imp φ.neg).allFuture :=
  contraposition (F_neg_contra_imp_F_neg φ ψ)

/-- `⊢ G(¬ψ→¬φ) → (Gφ → Gψ)`: From the contrapositive under G, derive K-distribution.

BX3 with `α := ¬ψ, β := ¬φ, γ := ⊤` gives `G(¬ψ→¬φ) → (F(¬ψ) → F(¬φ))`.
The propositional contrapositive of `F(¬ψ) → F(¬φ)` is `¬F(¬φ) → ¬F(¬ψ)` = `Gφ → Gψ`. -/
private noncomputable def G_contra_to_GK (φ ψ : Formula) :
    ⊢ (ψ.neg.imp φ.neg).allFuture.imp (φ.allFuture.imp ψ.allFuture) :=
  impTrans
    (DerivationTree.axiom [] _ (Axiom.right_mono_until ψ.neg φ.neg Formula.top) trivial)
    (contraposeImp (Formula.someFuture ψ.neg) (Formula.someFuture φ.neg))

/-- **Derived temp_k_dist**: `⊢ G(φ→ψ) → (Gφ → Gψ)`.

K-distribution for G, derived from BX3 (right_mono_until) and propositional
contraposition. Replaces the primitive `Axiom.temp_k_dist` constructor.

**Derivation**: Compose `G(φ→ψ) → G(¬ψ→¬φ)` with `G(¬ψ→¬φ) → (Gφ → Gψ)`. -/
@[tmLemma]
noncomputable def temporalKDistDerived (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture) :=
  impTrans (G_imp_to_G_contra φ ψ) (G_contra_to_GK φ ψ)

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
    ⊢ (Formula.someFuture (Formula.someFuture φ.neg).neg.neg).imp
      (Formula.someFuture (Formula.someFuture φ.neg)) :=
  mp (DerivationTree.temporal_necessitation _ (doubleNegation (Formula.someFuture φ.neg)))
     (DerivationTree.axiom [] _
       (Axiom.right_mono_until
         (Formula.someFuture φ.neg).neg.neg (Formula.someFuture φ.neg) Formula.top) trivial)

/-- `⊢ F(F(¬φ)) → F(⊤ ∧ F(¬φ))`: Enrich F(¬φ) with ⊤ via the tautology `X → ⊤ ∧ X`.

From the propositional tautology `X → ⊤ ∧ X` at `X = F(¬φ)`, apply temporal
necessitation and BX3 to lift through F. -/
private noncomputable def FF_to_F_top_and (φ : Formula) :
    ⊢ (Formula.someFuture (Formula.someFuture φ.neg)).imp
      (Formula.someFuture (Formula.top.and (Formula.someFuture φ.neg))) :=
  mp (DerivationTree.temporal_necessitation _ (top_and_intro (Formula.someFuture φ.neg)))
     (DerivationTree.axiom [] _
       (Axiom.right_mono_until
         (Formula.someFuture φ.neg)
         (Formula.top.and (Formula.someFuture φ.neg)) Formula.top) trivial)

/-- `⊢ F(⊤ ∧ F(¬φ)) → F(¬φ)`: Absorption of Until (BX6) collapses nested eventuality.

BX6 at `φ := ⊤, ψ := ¬φ_orig` gives `U(⊤ ∧ U(¬φ, ⊤), ⊤) → U(¬φ, ⊤)`,
which is `F(⊤ ∧ F(¬φ)) → F(¬φ)`. -/
private def F_top_and_absorb (φ : Formula) :
    ⊢ (Formula.someFuture (Formula.top.and (Formula.someFuture φ.neg))).imp
      (Formula.someFuture φ.neg) :=
  DerivationTree.axiom [] _ (Axiom.absorb_until Formula.top φ.neg) trivial

/-- **Derived temp_4**: `⊢ Gφ → GGφ`.

Positive introspection for G, derived from BX3 (right_mono_until), BX6
(absorb_until), double negation elimination, and propositional contraposition.
Replaces the primitive `Axiom.temp_4` constructor.

**Derivation**: The contrapositive `F(¬¬F(¬φ)) → F(¬φ)` is proved by composing
three F-monotonicity steps, then negated to obtain `Gφ → GGφ`. -/
@[tmLemma]
noncomputable def temporal4Derived (φ : Formula) :
    ⊢ φ.allFuture.imp φ.allFuture.allFuture :=
  contraposition (impTrans (impTrans (dne_lift_F φ) (FF_to_F_top_and φ)) (F_top_and_absorb φ))

end DerivedAxioms

/-!
## BX-Derivable Temporal Theorems

These theorems are directly derivable from the remaining BX axiom system.
All definitions below are sorry-free.
-/

/--
`⊢ G(φ → ψ) → (G(φ) → G(ψ))`: G-distribution. Derived from BX3 (right_mono_until).
-/
noncomputable def gDistribution (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture) :=
  temporalKDistDerived φ ψ

/--
`⊢ H(φ → ψ) → (H(φ) → H(ψ))`: H-distribution. Derived via temporal duality from G-distribution.
-/
@[tmLemma]
noncomputable def hDistribution (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allPast.imp (φ.allPast.imp ψ.allPast) :=
  FormalSystem.Theorems.pastKDist φ ψ

/--
`⊢ G(φ) → G(G(φ))`: G-transitivity. Derived from BX3 + BX6.
-/
noncomputable def gTransitivity (φ : Formula) :
    ⊢ φ.allFuture.imp φ.allFuture.allFuture :=
  temporal4Derived φ

/--
`⊢ H(φ) → H(H(φ))`: H-transitivity. Derived via temporal duality from G-transitivity.
-/
@[tmLemma]
noncomputable def hTransitivity (φ : Formula) :
    ⊢ φ.allPast.imp φ.allPast.allPast := by
  -- Derive by applying temporal duality to G-transitivity of swapTemporal φ
  let ψ := φ.swapTemporal
  have h1 : ⊢ ψ.allFuture.imp ψ.allFuture.allFuture :=
    temporal4Derived ψ
  have h2 : ⊢ (ψ.allFuture.imp ψ.allFuture.allFuture).swapTemporal :=
    DerivationTree.temporal_duality _ h1
  simp only [Formula.swap_temporal_all_future, Formula.swapTemporal] at h2
  have h_inv : ψ.swapTemporal = φ := Formula.swap_temporal_involution φ
  rw [h_inv] at h2
  exact h2

/--
`⊢ φ → G(P(φ))`: Temporal connectedness (future). Direct axiom (BX4).
The present is always in the past of the future.
-/
def connectFutureThm (φ : Formula) :
    ⊢ φ.imp (φ.somePast.allFuture) :=
  DerivationTree.axiom [] _ (Axiom.connect_future φ) trivial

/--
`⊢ φ → H(F(φ))`: Temporal connectedness (past). Direct axiom (BX4').
The present is always in the future of the past.
-/
def connectPastThm (φ : Formula) :
    ⊢ φ.imp (φ.someFuture.allPast) :=
  DerivationTree.axiom [] _ (Axiom.connect_past φ) trivial

/--
`⊢ G(a) → G(a → a)`: G(a→a) is a theorem, so G(a) → G(a→a) by prop_s.
-/
def gImpliesGId (a : Formula) :
    ⊢ a.allFuture.imp (a.imp a).allFuture :=
  mp (DerivationTree.temporal_necessitation _ (identity a))
     (DerivationTree.axiom [] _ (Axiom.prop_s (a.imp a).allFuture a.allFuture) trivial)

/-!
## BX10-Derived Theorems

Under open guard semantics, BX10/BX10' (eventuality extraction) provide
the basic Until/Since eventuality lemmas.
-/

/--
`⊢ (φ U ψ) → F(ψ)`: Any Until formula implies eventuality of its second argument.
Direct from BX10 axiom.
-/
def untilImpliesSomeFuture (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.someFuture ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ) trivial

/--
`⊢ (φ S ψ) → P(ψ)`: Any Since formula implies past eventuality.
Direct from BX10' axiom.
-/
def sinceImpliesSomePast (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.somePast ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ) trivial

/--
`⊢ (φ U ψ) → F(ψ)`: Until implies eventuality of its endpoint.
The witness s ≥ t with ψ(s) certifies F(ψ) at t.
Direct from BX10 axiom.
-/
def untilImpF (φ ψ : Formula) :
    ⊢ (Formula.untl ψ φ).imp (Formula.someFuture ψ) :=
  DerivationTree.axiom [] _ (Axiom.until_F φ ψ) trivial

/--
`⊢ (φ S ψ) → P(ψ)`: Since implies past eventuality of its endpoint.
Mirror of untilImpF.
-/
def sinceImpP (φ ψ : Formula) :
    ⊢ (Formula.snce ψ φ).imp (Formula.somePast ψ) :=
  DerivationTree.axiom [] _ (Axiom.since_P φ ψ) trivial

/-!
## Propositional Helpers for Until/Since Derivations
-/

/-- Contrapositive: `⊢ (A → B) → (¬B → ¬A)`.
Derived from bCombinator and theoremFlip. -/
@[tmLemma]
noncomputable def contrapositive (A B : Formula) : ⊢ (A.imp B).imp (B.neg.imp A.neg) :=
  mp bCombinator
    (theoremFlip (A := (B.imp Formula.bot)) (B := (A.imp B)) (C := (A.imp Formula.bot)))

private noncomputable def ctx_mp {Γ : Context} {A B : Formula}
    (h1 : Γ ⊢ A.imp B) (h2 : Γ ⊢ A) : Γ ⊢ B :=
  DerivationTree.modus_ponens Γ A B h1 h2

private noncomputable def ctx_thm {Γ : Context} {A : Formula}
    (h : ⊢ A) : Γ ⊢ A :=
  DerivationTree.weakening [] Γ A h (List.nil_subset Γ)

/-- Disjunction commutativity: `⊢ (A ∨ B) → (B ∨ A)`.
Since `A ∨ B = ¬A → B`, this is `(¬A → B) → (¬B → A)`, proved by
contraposition of the hypothesis composed with DNE. -/
@[tmLemma]
noncomputable def formulaOrComm (A B : Formula) : ⊢ (A.or B).imp (B.or A) := by
  unfold Formula.or
  apply FormalSystem.Metalogic.Core.deductionTheorem [] (A.neg.imp B) (B.neg.imp A)
  apply FormalSystem.Metalogic.Core.deductionTheorem [A.neg.imp B] B.neg A
  have h1 : [B.neg, A.neg.imp B] ⊢ A.neg.imp B := DerivationTree.assumption _ _ (by simp)
  have h2 : [B.neg, A.neg.imp B] ⊢ B.neg := DerivationTree.assumption _ _ (by simp)
  have h3 : [B.neg, A.neg.imp B] ⊢ A.neg.neg := ctx_mp (ctx_mp (ctx_thm bCombinator) h2) h1
  exact ctx_mp (ctx_thm (FormalSystem.Theorems.Propositional.doubleNegation A)) h3

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
def fMono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (φ.someFuture.imp ψ.someFuture) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ Formula.top) trivial

/--
`⊢ H(φ → ψ) → (P(φ) → P(ψ))`: P is monotone under H-guarded implication.

Direct from BX3' (right_mono_since) with χ := ⊤:
`H(φ → ψ) → (snce(φ, ⊤) → snce(ψ, ⊤))` = `H(φ → ψ) → (P(φ) → P(ψ))`.
-/
def pMono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allPast.imp (φ.somePast.imp ψ.somePast) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_since φ ψ Formula.top) trivial

/--
`⊢ G(φ → ψ) → (G(φ) → G(ψ))`: G is monotone (alias for gDistribution).

This is `gDistribution` under a discoverable name. Noncomputable because
it depends on the derived `temporalKDistDerived`.
-/
noncomputable abbrev gMono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture) :=
  gDistribution φ ψ

/--
`⊢ H(φ → ψ) → (H(φ) → H(ψ))`: H is monotone (alias for hDistribution).

This is `hDistribution` under a discoverable name. Noncomputable because
it depends on the derived `pastKDist`.
-/
noncomputable abbrev hMono (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allPast.imp (φ.allPast.imp ψ.allPast) :=
  hDistribution φ ψ

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
def untilMonoGuard (φ χ ψ : Formula) :
    ⊢ (φ.imp χ).allFuture.imp ((Formula.untl ψ φ).imp (Formula.untl ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.left_mono_until_G φ χ ψ) trivial

/--
`⊢ H(φ → χ) → ((ψ S φ) → (ψ S χ))`: Guard monotonicity of Since under H.

Direct from BX2H (left_mono_since_H).
-/
def sinceMonoGuard (φ χ ψ : Formula) :
    ⊢ (φ.imp χ).allPast.imp ((Formula.snce ψ φ).imp (Formula.snce ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.left_mono_since_H φ χ ψ) trivial

/--
`⊢ G(φ → ψ) → ((φ U χ) → (ψ U χ))`: Event monotonicity of Until under G.

Direct from BX3 (right_mono_until).
-/
def untilMonoEvent (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp ((Formula.untl φ χ).imp (Formula.untl ψ χ)) :=
  DerivationTree.axiom [] _ (Axiom.right_mono_until φ ψ χ) trivial

/--
`⊢ H(φ → ψ) → ((φ S χ) → (ψ S χ))`: Event monotonicity of Since under H.

Direct from BX3' (right_mono_since).
-/
def sinceMonoEvent (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).allPast.imp ((Formula.snce φ χ).imp (Formula.snce ψ χ)) :=
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
def fNegG (φ : Formula) :
    ⊢ (φ.neg.someFuture).imp φ.allFuture.neg :=
  notNotIntro (φ.neg.someFuture)

/--
`⊢ P(¬φ) → ¬(H(φ))`: If ¬φ was once true, then φ was not always true.

Since `H(φ) = ¬P(¬φ)`, we have `¬(H(φ)) = ¬¬P(¬φ)`.
Thus `P(¬φ) → ¬(H(φ))` is `P(¬φ) → ¬¬(P(¬φ))`, which is DNI at `P(¬φ)`.
-/
def pNegH (φ : Formula) :
    ⊢ (φ.neg.somePast).imp φ.allPast.neg :=
  notNotIntro (φ.neg.somePast)

end TemporalDuality

/-!
## Category A: G/H Distribution Variants (4 noncomputable theorems)

These distribute G/H over connectives. Each replaces multiple primitive steps.
All depend on `gDistribution` / `hDistribution` and are therefore noncomputable.
-/

section DistributionVariants

/--
`⊢ G(φ) → G(ψ) → G(φ ∧ ψ)`: G distributes into conjunction introduction.

From `pairing φ ψ : ⊢ φ → ψ → φ ∧ ψ`, temporal necessitate to get
`G(φ → ψ → φ ∧ ψ)`, then apply gDistribution twice:
- First: `G φ → G(ψ → φ ∧ ψ)`
- Second: `G(ψ → φ ∧ ψ) → (G ψ → G(φ ∧ ψ))`
-/
noncomputable def gAndIntro (φ ψ : Formula) :
    ⊢ φ.allFuture.imp (ψ.allFuture.imp (φ.and ψ).allFuture) :=
  let g_pair := DerivationTree.temporal_necessitation _ (pairing φ ψ)
  let step1 := mp g_pair (gDistribution φ (ψ.imp (φ.and ψ)))
  impTrans step1 (gDistribution ψ (φ.and ψ))

/--
`⊢ H(φ) → H(ψ) → H(φ ∧ ψ)`: H distributes into conjunction introduction.

Mirror of `gAndIntro` using `hDistribution` and `pastNecessitation`.
-/
noncomputable def hAndIntro (φ ψ : Formula) :
    ⊢ φ.allPast.imp (ψ.allPast.imp (φ.and ψ).allPast) :=
  let h_pair := FormalSystem.Theorems.pastNecessitation _ (pairing φ ψ)
  let step1 := mp h_pair (hDistribution φ (ψ.imp (φ.and ψ)))
  impTrans step1 (hDistribution ψ (φ.and ψ))

/--
`⊢ G(φ → ψ) → G(ψ → χ) → G(φ → χ)`: G distributes over implication transitivity.

From `bCombinator : ⊢ (ψ → χ) → (φ → ψ) → (φ → χ)`, temporal necessitate to get
`G((ψ → χ) → (φ → ψ) → (φ → χ))`, then apply gDistribution twice:
- First: `G(ψ → χ) → G((φ → ψ) → (φ → χ))`
- Second: `G((φ → ψ) → (φ → χ)) → (G(φ → ψ) → G(φ → χ))`
Then flip the argument order with `theoremFlip`-style composition.
-/
noncomputable def gImpTrans (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp ((ψ.imp χ).allFuture.imp (φ.imp χ).allFuture) :=
  let g_b :=
    DerivationTree.temporal_necessitation _ (@bCombinator .Base (A := φ) (B := ψ) (C := χ))
  let step1 := mp g_b (gDistribution (ψ.imp χ) ((φ.imp ψ).imp (φ.imp χ)))
  let step2 := impTrans step1 (gDistribution (φ.imp ψ) (φ.imp χ))
  -- step2 : G(ψ → χ) → G(φ → ψ) → G(φ → χ)
  -- Need: G(φ → ψ) → G(ψ → χ) → G(φ → χ)
  mp step2 (@theoremFlip .Base
    (A := (ψ.imp χ).allFuture)
    (B := (φ.imp ψ).allFuture)
    (C := (φ.imp χ).allFuture))

/--
`⊢ H(φ → ψ) → H(ψ → χ) → H(φ → χ)`: H distributes over implication transitivity.

Mirror of `gImpTrans` using `hDistribution` and `pastNecessitation`.
-/
noncomputable def hImpTrans (φ ψ χ : Formula) :
    ⊢ (φ.imp ψ).allPast.imp ((ψ.imp χ).allPast.imp (φ.imp χ).allPast) :=
  let h_b := FormalSystem.Theorems.pastNecessitation _ (@bCombinator .Base (A := φ) (B := ψ) (C := χ))
  let step1 := mp h_b (hDistribution (ψ.imp χ) ((φ.imp ψ).imp (φ.imp χ)))
  let step2 := impTrans step1 (hDistribution (φ.imp ψ) (φ.imp χ))
  mp step2 (@theoremFlip .Base
    (A := (ψ.imp χ).allPast)
    (B := (φ.imp ψ).allPast)
    (C := (φ.imp χ).allPast))

end DistributionVariants

/-!
## Category C1-C2: Temporal Contraposition (2 noncomputable theorems)

Contraposition lifted through temporal operators.
-/

section TemporalContraposition

/--
`⊢ G(φ → ψ) → G(¬ψ → ¬φ)`: Contraposition under G.

From `contraposeImp φ ψ : ⊢ (φ → ψ) → (¬ψ → ¬φ)`, temporal necessitate to get
`G((φ → ψ) → (¬ψ → ¬φ))`, then apply gDistribution.
-/
noncomputable def gContrapose (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allFuture.imp (ψ.neg.imp φ.neg).allFuture :=
  let g_cp := DerivationTree.temporal_necessitation _ (contraposeImp φ ψ)
  mp g_cp (gDistribution (φ.imp ψ) (ψ.neg.imp φ.neg))

/--
`⊢ H(φ → ψ) → H(¬ψ → ¬φ)`: Contraposition under H.

From `contraposeImp φ ψ : ⊢ (φ → ψ) → (¬ψ → ¬φ)`, past necessitate to get
`H((φ → ψ) → (¬ψ → ¬φ))`, then apply hDistribution.
-/
noncomputable def hContrapose (φ ψ : Formula) :
    ⊢ (φ.imp ψ).allPast.imp (ψ.neg.imp φ.neg).allPast :=
  let h_cp := FormalSystem.Theorems.pastNecessitation _ (contraposeImp φ ψ)
  mp h_cp (hDistribution (φ.imp ψ) (ψ.neg.imp φ.neg))

end TemporalContraposition

/-!
## Category D: Future-Past Interaction Chains (4 noncomputable theorems)

These connect future and past operators by chaining BX4/BX4' (temporal
connectedness) with G/H-distribution and temporal necessitation.
-/

section FuturePastChains

/--
`⊢ G(φ) → G(G(P(φ)))`: If φ always holds in the future, then G(P(φ)) always
holds in the future — φ's future permanence propagates through past reflection.

From `connect_future φ : ⊢ φ → G(P φ)`, temporal necessitate to get
`G(φ → G(P φ))`, then apply gDistribution: `G φ → G(G(P φ))`.
-/
noncomputable def connectFutureG (φ : Formula) :
    ⊢ φ.allFuture.imp (φ.somePast.allFuture).allFuture :=
  let g_cf := DerivationTree.temporal_necessitation _ (connectFutureThm φ)
  mp g_cf (gDistribution φ (φ.somePast.allFuture))

/--
`⊢ H(φ) → H(H(F(φ)))`: If φ always held in the past, then H(F(φ)) always
held in the past — φ's past permanence propagates through future reflection.

From `connect_past φ : ⊢ φ → H(F φ)`, past necessitate to get
`H(φ → H(F φ))`, then apply hDistribution: `H φ → H(H(F φ))`.
-/
noncomputable def connectPastH (φ : Formula) :
    ⊢ φ.allPast.imp (φ.someFuture.allPast).allPast :=
  let h_cp := FormalSystem.Theorems.pastNecessitation _ (connectPastThm φ)
  mp h_cp (hDistribution φ (φ.someFuture.allPast))

/--
`⊢ φ → G(H(F(P(φ))))`: Deep temporal chain combining future and past connectedness.

Compose `connect_future φ : φ → G(P φ)` with
`connect_past (P φ) : P φ → H(F(P φ))` lifted through G:
1. Temporal necessitate `P φ → H(F(P φ))` to get `G(P φ → H(F(P φ)))`
2. gDistribution: `G(P φ) → G(H(F(P φ)))`
3. impTrans with connect_future: `φ → G(H(F(P φ)))`
-/
noncomputable def connectFutureChain (φ : Formula) :
    ⊢ φ.imp ((φ.somePast.someFuture.allPast).allFuture) :=
  let step1 := DerivationTree.temporal_necessitation _ (connectPastThm φ.somePast)
  let step2 := mp step1 (gDistribution φ.somePast (φ.somePast.someFuture.allPast))
  impTrans (connectFutureThm φ) step2

/--
`⊢ φ → H(G(P(F(φ))))`: Deep temporal chain combining past and future connectedness.

Compose `connect_past φ : φ → H(F φ)` with
`connect_future (F φ) : F φ → G(P(F φ))` lifted through H:
1. Past necessitate `F φ → G(P(F φ))` to get `H(F φ → G(P(F φ)))`
2. hDistribution: `H(F φ) → H(G(P(F φ)))`
3. impTrans with connect_past: `φ → H(G(P(F φ)))`
-/
noncomputable def connectPastChain (φ : Formula) :
    ⊢ φ.imp ((φ.someFuture.somePast.allFuture).allPast) :=
  let step1 := FormalSystem.Theorems.pastNecessitation _ (connectFutureThm φ.someFuture)
  let step2 := mp step1 (hDistribution φ.someFuture (φ.someFuture.somePast.allFuture))
  impTrans (connectPastThm φ) step2

end FuturePastChains

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

/-!
## Tier 1: Conjunction Elimination Lemmas

These lemmas extract components from the compound temporal operators `always`,
`weakFuture`, and `weakPast`, which are defined as conjunctions. They are
needed by the proof system to handle formulas containing these derived operators.
-/

section ConjunctionElimination

/--
`⊢ always(φ) → φ`: Extract the present-tense component from always.

Since `always φ = Hφ ∧ (φ ∧ Gφ)`, we extract the right conjunct `φ ∧ Gφ`
and then extract the left conjunct `φ`.
-/
noncomputable def alwaysToPresent (φ : Formula) :
    ⊢ φ.always.imp φ :=
  impTrans (rceImp φ.allPast (φ.and φ.allFuture)) (lceImp φ φ.allFuture)

/--
`⊢ φ → sometimes(φ)`: If φ holds now, then φ holds at some time.

Since `sometimes φ = ¬(always(¬φ))`, we prove the contrapositive:
`always(¬φ) → ¬φ` and then take the contrapositive to get `¬¬φ → ¬(always(¬φ))`,
composed with DNI to get `φ → sometimes(φ)`.
-/
noncomputable def presentToSometimes (φ : Formula) :
    ⊢ φ.imp φ.sometimes := by
  -- sometimes φ = (φ.neg.always).neg
  -- Need: φ → ¬(always(¬φ))
  -- From alwaysToPresent: always(¬φ) → ¬φ
  -- Contrapositive: ¬¬φ → ¬(always(¬φ))
  -- Then compose with DNI: φ → ¬¬φ
  exact impTrans (notNotIntro φ) (contraposition (alwaysToPresent φ.neg))

/--
`⊢ weakFuture(φ) → φ`: Extract the present-tense component from weakFuture.

Since `weakFuture φ = φ ∧ Gφ`, this is just left conjunction elimination.
-/
noncomputable def weakFutureLeft (φ : Formula) :
    ⊢ φ.weakFuture.imp φ :=
  lceImp φ φ.allFuture

/--
`⊢ weakFuture(φ) → Gφ`: Extract the future component from weakFuture.

Since `weakFuture φ = φ ∧ Gφ`, this is just right conjunction elimination.
-/
noncomputable def weakFutureRight (φ : Formula) :
    ⊢ φ.weakFuture.imp φ.allFuture :=
  rceImp φ φ.allFuture

/--
`⊢ weakPast(φ) → φ`: Extract the present-tense component from weakPast.

Since `weakPast φ = φ ∧ Hφ`, this is just left conjunction elimination.
-/
noncomputable def weakPastLeft (φ : Formula) :
    ⊢ φ.weakPast.imp φ :=
  lceImp φ φ.allPast

/--
`⊢ weakPast(φ) → Hφ`: Extract the past component from weakPast.

Since `weakPast φ = φ ∧ Hφ`, this is just right conjunction elimination.
-/
noncomputable def weakPastRight (φ : Formula) :
    ⊢ φ.weakPast.imp φ.allPast :=
  rceImp φ φ.allPast

/--
`⊢ always(φ) → Gφ`: Extract the future component from always.

Since `always φ = Hφ ∧ (φ ∧ Gφ)`, extract the right conjunct `φ ∧ Gφ`
and then extract the right conjunct `Gφ`.
-/
noncomputable def alwaysImpAllFuture (φ : Formula) :
    ⊢ φ.always.imp φ.allFuture :=
  impTrans (rceImp φ.allPast (φ.and φ.allFuture)) (rceImp φ φ.allFuture)

/--
`⊢ always(φ) → Hφ`: Extract the past component from always.

Since `always φ = Hφ ∧ (φ ∧ Gφ)`, this is just left conjunction elimination.
-/
noncomputable def alwaysImpAllPast (φ : Formula) :
    ⊢ φ.always.imp φ.allPast :=
  lceImp φ.allPast (φ.and φ.allFuture)

end ConjunctionElimination

end FormalSystem.Theorems.TemporalDerived
