/-!
# Formula - Syntax for Bimodal Logic TM

This module defines the core syntax for the bimodal logic TM (Tense and Modality),
combining S5 modal logic with linear temporal logic.

## Main Definitions

- `Formula`: Inductive type representing TM formulas with 6 constructors
- `Formula.complexity`: Structural complexity measure for formulas
- `Formula.neg`, `Formula.and`, `Formula.or`: Derived Boolean operators
- `Formula.diamond`: Derived modal possibility operator
- `Formula.always`, `Formula.sometimes`: Derived temporal operators
- `Formula.swap_past_future`: Temporal duality transformation

## Main Results

- `DecidableEq Formula`: Formulas have decidable equality
- `swap_past_future_involution`: Swapping past/future twice gives identity

## Implementation Notes

- Atoms are represented as strings for simplicity (user responsibility to ensure validity)
- Bot (⊥) is primitive; negation is derived via implication
- Box (□) is primitive; diamond (◇) is derived via De Morgan duality
- Future is primitive; past/always/sometimes are derived or primitive as needed

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - TM logic specification
* [LEAN Style Guide](../../../docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
-/

namespace Logos.Syntax

/--
Formula type for bimodal logic TM.

A formula is built from:
- Propositional atoms (strings)
- Bottom (⊥, falsum)
- Implication (→)
- Modal necessity (□)
- Temporal past (P, "for all past times")
- Temporal future (F, "for all future times")

All other connectives and operators are derived from these primitives.
-/
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula
  deriving Repr, DecidableEq

namespace Formula

/--
Structural complexity of a formula (number of connectives + 1).

Useful for well-founded recursion and proof complexity analysis.
-/
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  | past φ => 1 + φ.complexity
  | future φ => 1 + φ.complexity

/--
Negation (¬φ) as derived operator: φ → ⊥
-/
def neg (φ : Formula) : Formula := φ.imp bot

/--
Conjunction (φ ∧ ψ) as derived operator: ¬(φ → ¬ψ)
-/
def and (φ ψ : Formula) : Formula := (φ.imp ψ.neg).neg

/--
Disjunction (φ ∨ ψ) as derived operator: ¬φ → ψ
-/
def or (φ ψ : Formula) : Formula := φ.neg.imp ψ

/--
Modal diamond/possibility (◇φ) as derived operator: ¬□¬φ
-/
def diamond (φ : Formula) : Formula := φ.neg.box.neg

/--
Temporal 'always' operator (△φ, "eternal truth" - φ holds at all times).

Following JPL paper §sec:Appendix definition:
  `always φ := Past φ ∧ φ ∧ Future φ`

This means φ holds at all past times, at the present time, and at all future times.
This is the "eternal truth" or "omnitemporality" operator.

**Paper Reference**: Line 427 defines `△φ := Pφ ∧ φ ∧ Fφ`

Note: The paper uses this definition for the TL axiom `△φ → F(Pφ)` which
is trivially valid: if φ holds at ALL times, then at any future time z,
φ holds at all times w < z (since "all times" includes all such w).
-/
def always (φ : Formula) : Formula := φ.past.and (φ.and φ.future)

/--
Temporal 'sometimes' operator (▽φ, "at some time" - φ holds at some time).

Following JPL paper §sec:Appendix definition:
  `sometimes φ := past φ ∨ φ ∨ future φ`

This means φ holds at some past time, or at the present time, or at some future time.
This is the "sometime" or existential temporal operator, dual to `always`.

**Paper Reference**: Line 427 defines `▽φ := pφ ∨ φ ∨ fφ`
where p = sometime_past and f = sometime_future (existential duals).

Equivalently, `sometimes φ = ¬(always ¬φ)` by De Morgan's laws.
-/
def sometimes (φ : Formula) : Formula := φ.neg.always.neg

/-- Notation for temporal 'always' operator using upward triangle.
    Represents universal temporal quantification: φ holds at all future times.
    Unicode: U+25B3 WHITE UP-POINTING TRIANGLE
-/
prefix:80 "△" => Formula.always

/-- Notation for temporal 'sometimes' operator using downward triangle.
    Represents existential temporal quantification: φ holds at some future time.
    Defined as dual: ¬△¬φ
    Unicode: U+25BD WHITE DOWN-POINTING TRIANGLE
-/
prefix:80 "▽" => Formula.sometimes

/--
Temporal 'sometime in the past' operator (Pφ in classical notation).

Derived as: ¬H¬φ = ¬(past (¬φ)) (not for-all-past not φ).
This means: there exists a past time where φ is true.

Note: H (always in past) is our `past`, and P (sometime past) is this operator.
-/
def sometime_past (φ : Formula) : Formula := φ.neg.past.neg

/--
Temporal 'sometime in the future' operator.

This is the same as `sometimes`.
-/
def sometime_future (φ : Formula) : Formula := φ.sometimes

/--
Swap past and future operators in a formula.

This transformation is used in the temporal duality inference rule (TD),
which states that if `⊢ φ` then `⊢ swap_past_future φ`.

The function recursively swaps:
- `past φ` ↔ `future φ`
- All other constructors are preserved with recursive application
-/
def swap_past_future : Formula → Formula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swap_past_future ψ.swap_past_future
  | box φ => box φ.swap_past_future
  | past φ => future φ.swap_past_future
  | future φ => past φ.swap_past_future

/--
Theorem: swap_past_future is an involution (applying it twice gives identity).

This is essential for the temporal duality rule to be well-behaved.
-/
theorem swap_past_future_involution (φ : Formula) :
  φ.swap_past_future.swap_past_future = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp [swap_past_future, ihp, ihq]
  | box _ ih => simp [swap_past_future, ih]
  | past _ ih => simp [swap_past_future, ih]
  | future _ ih => simp [swap_past_future, ih]

end Formula

end Logos.Syntax
