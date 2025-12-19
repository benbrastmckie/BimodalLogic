import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula
import Logos.Core.Theorems.Combinators

/-!
# Perpetuity Helper Lemmas

This module contains helper lemmas for proving the perpetuity principles (P1-P6).
These helpers include temporal component lemmas and boilerplate reduction utilities.

## Main Helper Categories

1. **Propositional Reasoning**: Imported from `Combinators.lean`
   - imp_trans, mp, identity, b_combinator, theorem_flip
   - theorem_app1, theorem_app2
   - pairing, combine_imp_conj, combine_imp_conj_3
   - dni (double negation introduction)

2. **Temporal Components**: box_to_future, box_to_past, box_to_present

3. **Boilerplate Reduction**: axiom_in_context, apply_axiom_to, apply_axiom_in_context

## References

* [Combinators.lean](../Combinators.lean) - Propositional reasoning combinators
* [Perpetuity.lean](../Perpetuity.lean) - Parent module (re-exports)
* [Axioms.lean](../../ProofSystem/Axioms.lean) - Axiom schemata
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
-/

namespace Logos.Core.Theorems.Perpetuity

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Combinators  -- Re-export combinators

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
def box_to_future (φ : Formula) : ⊢ φ.box.imp φ.all_future := by
  have mf : ⊢ φ.box.imp (φ.all_future.box) := DerivationTree.axiom [] _ (Axiom.modal_future φ)
  have mt : ⊢ φ.all_future.box.imp φ.all_future := DerivationTree.axiom [] _ (Axiom.modal_t φ.all_future)
  exact imp_trans mf mt

/--
Box implies past: `⊢ □φ → Hφ`.

Proof via temporal duality:
1. For any ψ, `box_to_future` gives: `⊢ □ψ → Gψ`
2. Apply to ψ = swap(φ): `⊢ □(swap φ) → G(swap φ)`
3. By temporal duality: `⊢ swap(□(swap φ) → G(swap φ))`
4. swap(□(swap φ) → G(swap φ)) = □(swap(swap φ)) → H(swap(swap φ)) = □φ → Hφ

This clever use of temporal duality avoids needing a separate "modal-past" axiom.
-/
def box_to_past (φ : Formula) : ⊢ φ.box.imp φ.all_past := by
  have h1 : ⊢ φ.swap_temporal.box.imp φ.swap_temporal.all_future := box_to_future φ.swap_temporal
  have h2 : ⊢ (φ.swap_temporal.box.imp φ.swap_temporal.all_future).swap_temporal :=
    DerivationTree.temporal_duality (φ.swap_temporal.box.imp φ.swap_temporal.all_future) h1
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h2
  exact h2

/--
Box implies present: `⊢ □φ → φ` (MT axiom).
-/
def box_to_present (φ : Formula) : ⊢ φ.box.imp φ := DerivationTree.axiom [] _ (Axiom.modal_t φ)

/-!
## Helper Lemmas: Boilerplate Reduction

These lemmas reduce proof verbosity by combining common patterns:
- `axiom_in_context`: Axiom application in non-empty contexts
- `apply_axiom_to`: Axiom + modus ponens combination
- `apply_axiom_in_context`: Context-aware axiom application with modus ponens

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
axiom_in_context Γ φ h
```

**Proof Strategy**: Apply weakening from empty context to Γ using `List.nil_subset`.
-/
def axiom_in_context (Γ : Context) (φ : Formula) (h : Axiom φ) : Γ ⊢ φ := by
  exact DerivationTree.weakening [] Γ φ (DerivationTree.axiom [] φ h) (List.nil_subset Γ)

/--
Apply axiom to argument: `⊢ B` from `Axiom (A → B)` and `⊢ A`.

This helper eliminates the common modus ponens + axiom pattern:
```lean
Derivable.modus_ponens [] A B (Derivable.axiom [] (A.imp B) axiom_proof) h
```

Instead of writing the above nested modus ponens, use:
```lean
apply_axiom_to axiom_proof h
```

**Proof Strategy**: Apply axiom in empty context, then apply modus ponens.
-/
def apply_axiom_to {A B : Formula} (axiom_proof : Axiom (A.imp B)) (h : ⊢ A) : ⊢ B := by
  exact DerivationTree.modus_ponens [] A B (DerivationTree.axiom [] (A.imp B) axiom_proof) h

/--
Apply axiom in context: `Γ ⊢ B` from `Axiom (A → B)` and `Γ ⊢ A`.

This helper combines `axiom_in_context` and `modus_ponens` for the common pattern:
```lean
Derivable.modus_ponens Γ A B
  (Derivable.weakening [] Γ (A.imp B)
    (Derivable.axiom [] (A.imp B) axiom_proof)
    (List.nil_subset Γ))
  h
```

Instead of writing the above nested weakening + modus ponens, use:
```lean
apply_axiom_in_context Γ axiom_proof h
```

**Proof Strategy**: Use `axiom_in_context` to get `Γ ⊢ A → B`, then apply modus ponens with `h`.
-/
def apply_axiom_in_context (Γ : Context) {A B : Formula}
    (axiom_proof : Axiom (A.imp B)) (h : Γ ⊢ A) : Γ ⊢ B := by
  have hAB : Γ ⊢ A.imp B := axiom_in_context Γ (A.imp B) axiom_proof
  exact DerivationTree.modus_ponens Γ A B hAB h

end Logos.Core.Theorems.Perpetuity
