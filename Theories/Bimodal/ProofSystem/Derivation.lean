import Bimodal.Syntax.Formula
import Bimodal.Syntax.Context
import Bimodal.ProofSystem.Axioms

/-!
# Derivation - Proof System for TM Logic

This module defines derivation trees for bimodal logic TM,
representing syntactic provability from a context of assumptions.

## Main Definitions

- `DerivationTree`: Inductive type `Γ ⊢ φ` representing a derivation tree for φ from context Γ
- `DerivationTree.height`: Computable height function for derivation trees
- Notation `⊢ φ` for derivability from empty context (theorem)
- Notation `Γ ⊢ φ` for derivability from context Γ

## Inference Rules

The derivation tree includes 7 inference rules:

1. **axiom**: Any axiom schema instance is derivable
2. **assumption**: Formulas in context are derivable
3. **modus_ponens**: If `Γ ⊢ φ → ψ` and `Γ ⊢ φ` then `Γ ⊢ ψ`
4. **necessitation**: If `⊢ φ` then `⊢ □φ` (standard modal necessitation)
5. **temporal_necessitation**: If `⊢ φ` then `⊢ Fφ` (standard temporal necessitation)
6. **temporal_duality**: If `⊢ φ` then `⊢ swap_past_future φ`
7. **weakening**: If `Γ ⊢ φ` and `Γ ⊆ Δ` then `Δ ⊢ φ`

## Implementation Notes

- `DerivationTree` is a `Type` (not a `Prop`), enabling pattern matching and computable functions
- Height function is computable via pattern matching (not axiomatized)
- Height properties are proven as theorems (not axioms)
- Necessitation rules only apply to theorems (empty context)
- Temporal duality only applies to theorems (empty context)
- Weakening allows adding unused assumptions
- K distribution is handled by axioms (`modal_k_dist`, `temp_k_dist`)

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - Proof system specification
* [Axioms.lean](./Axioms.lean) - Axiom schemata definitions
-/

namespace Bimodal.ProofSystem

open Bimodal.Syntax

/--
Derivation tree for bimodal logic TM.

`DerivationTree Γ φ` (written `Γ ⊢ φ`) represents a derivation tree showing
that formula `φ` is derivable from the context of assumptions `Γ` using the TM proof system.

The derivation tree is defined inductively with 7 inference rules covering:
- Axiom usage and assumptions
- Modus ponens (implication elimination)
- Modal and temporal necessitation (from theorems to necessary theorems)
- Temporal duality (swapping past/future)
- Weakening (adding unused assumptions)

## Implementation Notes

Since `DerivationTree` is a `Type` (not a `Prop`), we can pattern match on it
to produce data. This enables computable functions like `height` and supports
well-founded recursion in metalogical proofs.
-/
inductive DerivationTree : Context → Formula → Type where
  /--
  Axiom rule: Any axiom schema instance is derivable from any context.

  If `Axiom φ` holds (φ matches an axiom schema), then `Γ ⊢ φ`.
  -/
  | axiom (Γ : Context) (φ : Formula) (h : Axiom φ) : DerivationTree Γ φ

  /--
  Assumption rule: Formulas in the context are derivable.

  If `φ ∈ Γ`, then `Γ ⊢ φ`.
  -/
  | assumption (Γ : Context) (φ : Formula) (h : φ ∈ Γ) : DerivationTree Γ φ

  /--
  Modus ponens: Implication elimination.

  If `Γ ⊢ φ → ψ` and `Γ ⊢ φ`, then `Γ ⊢ ψ`.
  -/
  | modus_ponens (Γ : Context) (φ ψ : Formula)
      (d1 : DerivationTree Γ (φ.imp ψ))
      (d2 : DerivationTree Γ φ) : DerivationTree Γ ψ

  /--
  Necessitation rule: From theorems, derive necessary theorems.

  If `⊢ φ` (derivable from empty context), then `⊢ □φ`.

  This is the standard necessitation rule of modal logic. It only applies
  to theorems (proofs from no assumptions), not to derivations from contexts.

  This rule expresses: if φ is a theorem (provable without assumptions),
  then it is necessarily true (□φ is also a theorem).

  **Note**: The generalized rule `Γ ⊢ φ` ⟹ `□Γ ⊢ □φ` is derivable from
  this rule plus K distribution (`modal_k_dist`) and the deduction theorem.
  See `Bimodal.Theorems.GeneralizedNecessitation` for the derivation.
  -/
  | necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.box φ)

  /--
  Temporal necessitation rule: From theorems, derive future-necessary theorems.

  If `⊢ φ` (derivable from empty context), then `⊢ Fφ`.

  This is the temporal analog of modal necessitation. It only applies
  to theorems (proofs from no assumptions), not to derivations from contexts.

  This rule expresses: if φ is a theorem (provable without assumptions),
  then it will always be true (Fφ is also a theorem).

  **Note**: The generalized rule `Γ ⊢ φ` ⟹ `FΓ ⊢ Fφ` is derivable from
  this rule plus temporal K distribution (`temp_k_dist`) and the deduction theorem.
  See `Bimodal.Theorems.GeneralizedNecessitation` for the derivation.
  -/
  | temporal_necessitation (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] (Formula.all_future φ)

  /--
  Temporal duality rule: Swapping past and future in theorems.

  If `⊢ φ` (derivable from empty context), then `⊢ swap_past_future φ`.

  This rule only applies to theorems (proofs from no assumptions).
  -/
  | temporal_duality (φ : Formula)
      (d : DerivationTree [] φ) : DerivationTree [] φ.swap_past_future

  /--
  Weakening rule: Adding unused assumptions.

  If `Γ ⊢ φ` and `Γ ⊆ Δ`, then `Δ ⊢ φ`.

  This allows adding extra assumptions that don't affect the derivation.
  -/
  | weakening (Γ Δ : Context) (φ : Formula)
      (d : DerivationTree Γ φ)
      (h : Γ ⊆ Δ) : DerivationTree Δ φ
  deriving Repr

namespace DerivationTree

/-! ## Derivation Height Measure -/

/--
Computable height function via pattern matching.

The height is defined as the maximum depth of the derivation tree:
- Base cases (axiom, assumption): height 0
- Unary rules (necessitation, temporal_necessitation, temporal_duality, weakening):
  height of subderivation + 1
- Binary rules (modus_ponens): max of both subderivations + 1

This measure is used for well-founded recursion in the deduction theorem proof.

## Implementation Notes

Since `DerivationTree` is a `Type` (not a `Prop`), we can pattern match on it
to produce data. The height function is computable and can be evaluated.

## Usage

The height measure is primarily used in `Bimodal.Metalogic.DeductionTheorem`
for proving termination of the deduction theorem via well-founded recursion.
-/
def height {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Nat
  | .axiom _ _ _ => 0
  | .assumption _ _ _ => 0
  | .modus_ponens _ _ _ d1 d2 => 1 + max d1.height d2.height
  | .necessitation _ d => 1 + d.height
  | .temporal_necessitation _ d => 1 + d.height
  | .temporal_duality _ d => 1 + d.height
  | .weakening _ _ _ d _ => 1 + d.height

/-! ## Height Properties -/

/--
Weakening increases height by exactly 1.
-/
theorem weakening_height_succ {Γ' Δ : Context} {φ : Formula}
    (d : DerivationTree Γ' φ) (h : Γ' ⊆ Δ) :
    (weakening Γ' Δ φ d h).height = d.height + 1 := by
  simp [height]
  omega

/--
Subderivations in weakening have strictly smaller height.

This is the key lemma for proving termination of well-founded recursion
in the deduction theorem.
-/
theorem subderiv_height_lt {Γ' Δ : Context} {φ : Formula}
    (d : DerivationTree Γ' φ) (h : Γ' ⊆ Δ) :
    d.height < (weakening Γ' Δ φ d h).height := by
  simp [height]

/--
Modus ponens height is strictly greater than the left subderivation.
-/
theorem mp_height_gt_left {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d1.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/--
Modus ponens height is strictly greater than the right subderivation.
-/
theorem mp_height_gt_right {Γ : Context} {φ ψ : Formula}
    (d1 : DerivationTree Γ (φ.imp ψ)) (d2 : DerivationTree Γ φ) :
    d2.height < (modus_ponens Γ φ ψ d1 d2).height := by
  simp [height]
  omega

/--
Necessitation increases height by exactly 1.
-/
theorem necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (necessitation φ d).height = d.height + 1 := by
  simp [height]
  omega

/--
Temporal necessitation increases height by exactly 1.
-/
theorem temporal_necessitation_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_necessitation φ d).height = d.height + 1 := by
  simp [height]
  omega

/--
Temporal duality increases height by exactly 1.
-/
theorem temporal_duality_height_succ {φ : Formula}
    (d : DerivationTree [] φ) :
    (temporal_duality φ d).height = d.height + 1 := by
  simp [height]
  omega

/-! ## Frame Class Compatibility Predicates

These predicates characterize which derivations are valid on which frame classes.
A derivation is dense-compatible if it only uses axioms valid on densely ordered frames
(i.e., avoids discreteness_forward).
-/

/--
A derivation is dense-compatible if it only uses axioms valid on densely ordered frames.

This excludes `discreteness_forward` which requires SuccOrder (a discrete frame property).
All other axioms including seriality are dense-compatible because DenselyOrdered + Nontrivial
implies NoMaxOrder/NoMinOrder which suffices for seriality axioms.
-/
def isDenseCompatible {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Prop
  | .axiom _ _ h => h.isDenseCompatible
  | .assumption _ _ _ => True
  | .modus_ponens _ _ _ d1 d2 => d1.isDenseCompatible ∧ d2.isDenseCompatible
  | .necessitation _ d => d.isDenseCompatible
  | .temporal_necessitation _ d => d.isDenseCompatible
  | .temporal_duality _ d => d.isDenseCompatible
  | .weakening _ _ _ d _ => d.isDenseCompatible

/--
A derivation is discrete-compatible if it only uses axioms valid on discrete frames.

This excludes `density` which requires DenselyOrdered (a dense frame property).
All other axioms including seriality are discrete-compatible because SuccOrder/PredOrder
+ Nontrivial provides the NoMaxOrder/NoMinOrder needed for seriality.
-/
def isDiscreteCompatible {Γ : Context} {φ : Formula} : DerivationTree Γ φ → Prop
  | .axiom _ _ h => h.isDiscreteCompatible
  | .assumption _ _ _ => True
  | .modus_ponens _ _ _ d1 d2 => d1.isDiscreteCompatible ∧ d2.isDiscreteCompatible
  | .necessitation _ d => d.isDiscreteCompatible
  | .temporal_necessitation _ d => d.isDiscreteCompatible
  | .temporal_duality _ d => d.isDiscreteCompatible
  | .weakening _ _ _ d _ => d.isDiscreteCompatible

end DerivationTree

/--
Notation `Γ ⊢ φ` for derivability from context Γ.
-/
notation:50 Γ " ⊢ " φ => DerivationTree Γ φ

/--
Notation `⊢ φ` for derivability from empty context (theorem).
-/
notation:50 "⊢ " φ => DerivationTree [] φ

/-!
## Example Derivations

Demonstrating basic usage of the proof system.
-/

/--
Example: Modal T axiom is a theorem.

`⊢ □p → p` for any propositional variable p.
-/
example (p : Atom) : ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply DerivationTree.axiom
  apply Axiom.modal_t

/--
Example: Modus ponens from assumptions.

If we assume both `p → q` and `p`, we can derive `q`.
-/
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply DerivationTree.modus_ponens (φ := p)
  · apply DerivationTree.assumption
    simp
  · apply DerivationTree.assumption
    simp

/--
Example: Modal 4 axiom is a theorem.

`⊢ □φ → □□φ` for any formula φ.
-/
example (φ : Formula) : ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) := by
  apply DerivationTree.axiom
  apply Axiom.modal_4

/--
Example: Weakening allows adding assumptions.

If we can derive `□p → p` from empty context,
we can also derive it with extra assumptions.
-/
example (p : Atom) (ψ : Formula) : [ψ] ⊢ (Formula.box (Formula.atom p)).imp (Formula.atom p) := by
  apply DerivationTree.weakening (Γ := [])
  · apply DerivationTree.axiom
    apply Axiom.modal_t
  · intro _ h
    exact False.elim (List.not_mem_nil h)

end Bimodal.ProofSystem
