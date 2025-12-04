import Logos.Core.ProofSystem.Derivation
import Logos.Core.ProofSystem.Axioms

/-!
# Modal Logic Proof Examples

This module demonstrates S5 modal logic reasoning in the ProofChecker system,
focusing on the modal operators necessity (`□`) and possibility (`◇`).

## S5 Modal Logic

S5 is characterized by three axioms beyond propositional logic:
- **T** (reflexivity): `□φ → φ` - necessary truths are true
- **4** (transitivity): `□φ → □□φ` - necessary truths are necessarily necessary
- **B** (symmetry): `φ → □◇φ` - truths are necessarily possible

These axioms make the accessibility relation reflexive, transitive, and symmetric,
which is appropriate for metaphysical necessity (truth in all possible worlds).

## Examples Categories

1. **Basic Axiom Usage**: Direct axiom applications
2. **Derived Theorems**: Results provable from the axioms
3. **Modal Distribution**: Using modal K rule
4. **Complex Formulas**: Modal operators on compound formulas

## Notation

- `φ.box` = `□φ` (necessity - true in all possible worlds)
- `φ.diamond` = `◇φ` (possibility - true in some possible world)
- `◇φ` is defined as `¬□¬φ`

## References

* [Axioms.lean](../ProofChecker/ProofSystem/Axioms.lean) - Modal axiom definitions
* [Derivation.lean](../ProofChecker/ProofSystem/Derivation.lean) - Inference rules
* [ARCHITECTURE.md](../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/

namespace Archive.ModalProofs

open Logos.Core.Syntax
open Logos.Core.ProofSystem

/-!
## Axiom T: Reflexivity (`□φ → φ`)

If something is necessarily true (true in all possible worlds),
then it is true in the actual world.
-/

/-- Axiom T on atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p") :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "p"))

/-- Axiom T on implication -/
example (p q : Formula) : ⊢ (p.imp q).box.imp (p.imp q) :=
  Derivable.axiom [] _ (Axiom.modal_t (p.imp q))

/-- Axiom T on nested box: `□□φ → □φ` -/
example (φ : Formula) : ⊢ φ.box.box.imp φ.box :=
  Derivable.axiom [] _ (Axiom.modal_t φ.box)

/-- Axiom T demonstrates that necessity implies truth -/
example : ⊢ (Formula.atom "necessary").box.imp (Formula.atom "necessary") :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "necessary"))

/-!
## Axiom 4: Transitivity (`□φ → □□φ`)

If something is necessary, then it is necessarily necessary.
This expresses that the accessibility relation is transitive.
-/

/-- Axiom 4 on atomic formula -/
example : ⊢ (Formula.atom "p").box.imp (Formula.atom "p").box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "p"))

/-- Axiom 4 on complex formula -/
example (p q : Formula) : ⊢ (p.and q).box.imp (p.and q).box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (p.and q))

/-- Axiom 4 on negation: `□¬φ → □□¬φ` -/
example (φ : Formula) : ⊢ φ.neg.box.imp φ.neg.box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 φ.neg)

/-- Axiom 4 demonstrates positive introspection -/
example : ⊢ (Formula.atom "known").box.imp (Formula.atom "known").box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "known"))

/-!
## Axiom B: Symmetry (`φ → □◇φ`)

If something is true, then it is necessarily possible.
This expresses that the accessibility relation is symmetric.
-/

/-- Axiom B on atomic formula -/
example : ⊢ (Formula.atom "p").imp (Formula.atom "p").diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (Formula.atom "p"))

/-- Axiom B on implication -/
example (p q : Formula) : ⊢ (p.imp q).imp (p.imp q).diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (p.imp q))

/-- Axiom B with explicit diamond definition: `φ → □¬□¬φ` -/
example (φ : Formula) : ⊢ φ.imp φ.diamond.box := by
  -- diamond φ = ¬□¬φ, so this is φ → □(¬□¬φ)
  exact Derivable.axiom [] _ (Axiom.modal_b φ)

/-- Axiom B demonstrates negative introspection -/
example : ⊢ (Formula.atom "actual").imp (Formula.atom "actual").diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (Formula.atom "actual"))

/-!
## Propositional Axioms K and S

The propositional axioms support reasoning within the modal logic.
-/

/-- Propositional K (distribution): `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` -/
example (φ ψ χ : Formula) :
    ⊢ (φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)) :=
  Derivable.axiom [] _ (Axiom.prop_k φ ψ χ)

/-- Propositional K with modal formulas -/
example (φ : Formula) :
    ⊢ (φ.box.imp ((φ.diamond).imp φ)).imp
      ((φ.box.imp φ.diamond).imp (φ.box.imp φ)) :=
  Derivable.axiom [] _ (Axiom.prop_k φ.box φ.diamond φ)

/-- Propositional S (weakening): `φ → (ψ → φ)` -/
example (φ ψ : Formula) : ⊢ φ.imp (ψ.imp φ) :=
  Derivable.axiom [] _ (Axiom.prop_s φ ψ)

/-- Propositional S with modal formulas -/
example (φ ψ : Formula) : ⊢ φ.box.imp (ψ.diamond.imp φ.box) :=
  Derivable.axiom [] _ (Axiom.prop_s φ.box ψ.diamond)

/-!
## Derived Theorems

Using modus ponens and axioms to derive new modal theorems.
-/

/-- Derived: From `□φ` and `□(φ → ψ)`, derive `□ψ` (modal modus ponens pattern) -/
example (φ ψ : Formula) (h1 : ⊢ φ.box) (h2 : ⊢ (φ.imp ψ).box) : ⊢ ψ.box := by
  -- This would require modal K rule and weakening to derive properly
  -- For now, demonstrating the pattern via axioms
  sorry

/-- Combining T and 4: `□φ → φ` and `□φ → □□φ` for iteration -/
example (φ : Formula) : ⊢ φ.box.imp φ.box := by
  -- Trivial identity, but shows combining T and 4
  have h1 := Derivable.axiom [] _ (Axiom.modal_t φ.box)  -- □□φ → □φ
  have h2 := Derivable.axiom [] _ (Axiom.modal_4 φ)      -- □φ → □□φ
  -- Would compose these to get □φ → □φ (identity)
  sorry

/-- S5 characteristic: `◇□φ → φ` (possibility of necessity implies truth) -/
example (φ : Formula) : ⊢ φ.box.diamond.imp φ := by
  -- This is derivable in S5 from T, 4, B
  -- ◇□φ = ¬□¬□φ → φ
  sorry

/-!
## Modal Distribution (Modal K Rule)

The modal K rule allows distributing `□` over derivations.
-/

/-- Using modal K rule: if `□Γ ⊢ φ` then `Γ ⊢ □φ` -/
example (p : Formula) : [p] ⊢ p.box := by
  -- To derive p.box from assumption p, use modal K:
  -- We need [□p] ⊢ p, which follows from assumption
  apply Derivable.modal_k [p] p
  -- Now need to show: [□p] ⊢ p
  -- This follows from modal T axiom and modus ponens
  apply Derivable.modus_ponens [p.box] p.box p
  · exact Derivable.axiom [p.box] _ (Axiom.modal_t p)
  · exact Derivable.assumption [p.box] p.box (by simp)

/-!
## Complex Modal Formulas

Demonstrating modal operators on compound formulas.
-/

/-- Necessity distributes over implication (using modal axioms) -/
example (p q : Formula) : ⊢ (p.box.and (p.imp q).box).imp q.box := by
  -- Would use: □p ∧ □(p → q) → □q
  -- This requires modal K axiom and propositional reasoning
  sorry

/-- Possibility of conjunction example -/
example (p q : Formula) : ⊢ (p.and q).diamond.imp (p.diamond.or q.diamond) := by
  -- ◇(p ∧ q) → (◇p ∨ ◇q) is a valid modal theorem
  sorry

/-- Duality between necessity and possibility -/
example (φ : Formula) : ⊢ φ.box.imp φ.diamond.neg.neg := by
  -- □φ → ¬¬◇φ (using ◇φ = ¬□¬φ)
  -- This is: □φ → ¬¬¬□¬φ
  sorry

/-!
## Modal Tautologies

Examples of formulas that are valid in all S5 models.
-/

/-- Double negation of possibility: `◇φ ↔ ¬□¬φ` (definitional) -/
example (φ : Formula) : φ.diamond = φ.neg.box.neg := rfl

/-- Necessity of tautology: if `⊢ φ` then `⊢ □φ` (necessitation rule pattern) -/
example (φ : Formula) (h : ⊢ φ) : ⊢ φ.box := by
  -- Necessitation rule: from ⊢ φ derive ⊢ □φ
  -- This uses modal K with empty context
  apply Derivable.modal_k [] φ
  exact h

/-!
## Teaching Examples

Clear examples for learning modal logic concepts.
-/

/-- Example: Something necessarily true is true -/
example : ⊢ (Formula.atom "2+2=4").box.imp (Formula.atom "2+2=4") :=
  Derivable.axiom [] _ (Axiom.modal_t (Formula.atom "2+2=4"))

/-- Example: Mathematical truths are necessarily necessary -/
example : ⊢ (Formula.atom "prime_infinity").box.imp (Formula.atom "prime_infinity").box.box :=
  Derivable.axiom [] _ (Axiom.modal_4 (Formula.atom "prime_infinity"))

/-- Example: Actual facts are necessarily possible -/
example : ⊢ (Formula.atom "I_exist").imp (Formula.atom "I_exist").diamond.box :=
  Derivable.axiom [] _ (Axiom.modal_b (Formula.atom "I_exist"))

end Archive.ModalProofs
