/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.Syntax.Formula
import FormalSystem.Theorems.Combinators
import FormalSystem.Automation.LemmaDB

/-!
# Perpetuity Helper Lemmas

This module contains helper lemmas for proving the perpetuity principles (P1-P6).
These helpers include temporal component lemmas and boilerplate reduction utilities.

## Main Helper Categories

1. **Propositional Reasoning**: Imported from `Combinators.lean`
   - impTrans, mp, identity, bCombinator, theoremFlip
   - theoremApp1, theoremApp2
   - pairing, combineImpConj, combineImpConj3
   - notNotIntro (double negation introduction)

2. **Temporal Components**: boxToFuture, boxToPast, boxToPresent

3. **Boilerplate Reduction**: axiomInContext, applyAxiomTo, applyAxiomInContext

## References

* [Combinators.lean](../Combinators.lean) - Propositional reasoning combinators
* [Perpetuity.lean](../Perpetuity.lean) - Parent module (re-exports)
* [Axioms.lean](../../ProofSystem/Axioms.lean) - Axiom schemata
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace FormalSystem.Theorems.Perpetuity

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators  -- Re-export combinators

/-!
## Helper Lemmas: Temporal Components

The perpetuity principle P1 (□φ → △φ) requires deriving each temporal component:
- □φ → Hφ (past): via temporal duality on MF
- □φ → φ (present): via MT axiom
- □φ → Gφ (future): via MF then MT
-/

/--
Box implies future: `⊢ □φ → Gφ`.

Proof:
1. MF axiom: `□φ → □Gφ`
2. MT axiom: `□Gφ → Gφ`
3. Transitivity: `□φ → Gφ`
-/
@[tm_lemma]
def boxToFuture (φ : Formula) : ⊢ φ.box.imp φ.allFuture := by
  have mf : ⊢ φ.box.imp (φ.allFuture.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_future φ) trivial
  have mt : ⊢ φ.allFuture.box.imp φ.allFuture :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ.allFuture) trivial
  exact impTrans mf mt

/--
Box implies past: `⊢ □φ → Hφ`.

Proof via temporal duality:
1. For any ψ, `boxToFuture` gives: `⊢ □ψ → Gψ`
2. Apply to ψ = swap(φ): `⊢ □(swap φ) → G(swap φ)`
3. By temporal duality: `⊢ swap(□(swap φ) → G(swap φ))`
4. swap(□(swap φ) → G(swap φ)) = □(swap(swap φ)) → H(swap(swap φ)) = □φ → Hφ

This clever use of temporal duality avoids needing a separate "modal-past" axiom.
-/
@[tm_lemma]
def boxToPast (φ : Formula) : ⊢ φ.box.imp φ.allPast := by
  have h1 : ⊢ φ.swapTemporal.box.imp φ.swapTemporal.allFuture := boxToFuture φ.swapTemporal
  have h2 : ⊢ (φ.swapTemporal.box.imp φ.swapTemporal.allFuture).swapTemporal :=
    DerivationTree.temporal_duality (φ.swapTemporal.box.imp φ.swapTemporal.allFuture) h1
  simp only [Formula.swap_temporal_all_future,
    Formula.swapTemporal, Formula.swap_temporal_involution] at h2
  exact h2

/--
Box implies present: `⊢ □φ → φ` (MT axiom).
-/
@[tm_lemma]
def boxToPresent (φ : Formula) : ⊢ φ.box.imp φ :=
  DerivationTree.axiom [] _ (Axiom.modal_t φ) trivial

/-!
## Helper Lemmas: Boilerplate Reduction

These lemmas reduce proof verbosity by combining common patterns:
- `axiomInContext`: Axiom application in non-empty contexts
- `applyAxiomTo`: Axiom + modus ponens combination
- `applyAxiomInContext`: Context-aware axiom application with modus ponens

These helpers eliminate 50+ axiom weakening boilerplate patterns and 150+ modus ponens chains
across the perpetuity proofs (identified in Plan 063 research).
-/

/--
Axiom in context: `Γ ⊢ φ` when `Axiom φ`.

This helper eliminates the common weakening boilerplate pattern:
```lean
Derivable.weakening [] Γ φ (Derivable.axiom [] φ h) (List.nil_subset Γ)
```

Instead of writing the above 5-argument weakening call, use:
```lean
axiomInContext Γ φ h
```

**Proof Strategy**: Apply weakening from empty context to Γ using `List.nil_subset`.
-/
def axiomInContext {fc : FrameClass} (Γ : Context) (φ : Formula) (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ fc) : Γ ⊢[fc] φ := by
  exact DerivationTree.weakening [] Γ φ (DerivationTree.axiom [] φ h h_fc) (List.nil_subset Γ)

/--
Apply axiom to argument: `⊢ B` from `Axiom (A → B)` and `⊢ A`.

This helper eliminates the common modus ponens + axiom pattern:
```lean
Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h
```

Instead of writing the above nested modus ponens, use:
```lean
applyAxiomTo axiom_proof h
```

**Proof Strategy**: Apply axiom in empty context, then apply modus ponens.
-/
def applyAxiomTo {fc : FrameClass} {A B : Formula} (axiom_proof : Axiom (A.imp B))
    (h_fc : axiom_proof.minFrameClass ≤ fc) (h : ⊢[fc] A) : ⊢[fc] B := by
  exact DerivationTree.modus_ponens [] A B (DerivationTree.axiom [] (A.imp B) axiom_proof h_fc) h

/--
Apply axiom in context: `Γ ⊢ B` from `Axiom (A → B)` and `Γ ⊢ A`.

This helper combines `axiomInContext` and `modus_ponens` for the common pattern:
```lean
Derivable.modus_ponens Γ A B
  (Derivable.weakening [] Γ (A.imp B)
    (Derivable.axiom [] (A.imp B) axiom_proof)
    (List.nil_subset Γ))
  h
```

Instead of writing the above nested weakening + modus ponens, use:
```lean
applyAxiomInContext Γ axiom_proof h
```

**Proof Strategy**: Use `axiomInContext` to get `Γ ⊢ A → B`, then apply modus ponens with `h`.
-/
def applyAxiomInContext {fc : FrameClass} (Γ : Context) {A B : Formula}
    (axiom_proof : Axiom (A.imp B)) (h_fc : axiom_proof.minFrameClass ≤ fc)
    (h : Γ ⊢[fc] A) : Γ ⊢[fc] B := by
  have hAB : Γ ⊢[fc] A.imp B := axiomInContext Γ (A.imp B) axiom_proof h_fc
  exact DerivationTree.modus_ponens Γ A B hAB h

end FormalSystem.Theorems.Perpetuity
