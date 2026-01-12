import Mathlib.Tactic.DeriveCountable
import Mathlib.Data.Countable.Basic
import Mathlib.Logic.Equiv.List

/-!
# Formula - Syntax for Bimodal Logic TM

This module defines the core syntax for the bimodal logic TM (Tense and Modality),
combining S5 modal logic with linear temporal logic.

## Main Definitions

- `Formula`: Inductive type representing TM formulas with 6 constructors
- `Formula.complexity`: Structural complexity measure for formulas
- `Formula.neg`, `Formula.and`, `Formula.or`: Derived Boolean operators
- `Formula.diamond`: Derived modal possibility operator
- `Formula.always`, `Formula.sometimes`: Derived universal/existential temporal operators
- `Formula.swap_temporal`: Temporal duality transformation

## Main Results

- `DecidableEq Formula`: Formulas have decidable equality
- `Countable Formula`: Formulas are countable (for completeness proofs)
- `swap_temporal_involution`: Swapping temporal operators twice gives identity

## Implementation Notes

- Atoms are represented as strings for simplicity (user responsibility to ensure validity)
- Bot (⊥) is primitive; negation is derived via implication
- Box (□) is primitive; diamond (◇) is derived via De Morgan duality
- `all_past` and `all_future` are primitive temporal operators
- `always`, `sometimes` are derived from primitives

## Naming Convention

Follows the `box`/`□` pattern with descriptive function names:
- Universal temporal: `all_past` (H), `all_future` (G)
- Existential temporal: `some_past` (P), `some_future` (F)
- Derived: `always` (△), `sometimes` (▽)

Use method syntax: `φ.all_past`, `φ.some_future`, etc.

## References

* [ARCHITECTURE.md](../../../docs/ARCHITECTURE.md) - TM logic specification
* [LEAN Style Guide](../../../docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
-/

namespace Bimodal.Syntax

/-!
## Countability Prerequisites

We need `Countable Char` and `Countable String` instances before Formula can derive Countable.
-/

/-- Char is countable via injection into Nat. -/
instance : Countable Char := by
  have h : Function.Injective Char.toNat := by
    intro c1 c2 heq
    rw [← Char.ofNat_toNat c1, ← Char.ofNat_toNat c2, heq]
  exact Function.Injective.countable h

/-- String is countable via injection into List Char. -/
instance : Countable String := by
  have h : Function.Injective String.toList := fun _ _ => String.toList_injective
  exact Function.Injective.countable h

/--
Formula type for bimodal logic TM.

A formula is built from:
- Propositional atoms (strings)
- Bottom (⊥, falsum)
- Implication (→)
- Modal necessity (□)
- Universal past (H, "for all past times")
- Universal future (G, "for all future times")

All other connectives and operators are derived from these primitives.

**Naming Convention**: Follows the `box`/`□` pattern with descriptive function
names (`all_past`, `all_future`) and concise DSL notation (`H`, `G`).
-/
inductive Formula : Type where
  /-- Propositional atom (variable) -/
  | atom : String → Formula
  /-- Bottom (⊥, falsum, contradiction) -/
  | bot : Formula
  /-- Implication (φ → ψ) -/
  | imp : Formula → Formula → Formula
  /-- Modal necessity (□φ, "necessarily φ") -/
  | box : Formula → Formula
  /-- Universal past (Hφ, "φ has always been true") -/
  | all_past : Formula → Formula
  /-- Universal future (Gφ, "φ will always be true") -/
  | all_future : Formula → Formula
  deriving Repr, DecidableEq, BEq, Hashable, Countable

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
  | all_past φ => 1 + φ.complexity
  | all_future φ => 1 + φ.complexity

/--
Modal depth: nesting level of modal operators (□, ◇).

Computes the maximum nesting depth of box operators in a formula.
Useful for heuristic scoring in proof search - deeply nested modalities
require more modal K applications.

Examples:
- `modalDepth (atom "p")` = 0
- `modalDepth (box (atom "p"))` = 1
- `modalDepth (box (box (atom "p")))` = 2
- `modalDepth (imp (box p) (box q))` = 1
-/
def modalDepth : Formula → Nat
  | atom _ => 0
  | bot => 0
  | imp φ ψ => max φ.modalDepth ψ.modalDepth
  | box φ => 1 + φ.modalDepth
  | all_past φ => φ.modalDepth
  | all_future φ => φ.modalDepth

/--
Temporal depth: nesting level of temporal operators (G, F, H, P).

Computes the maximum nesting depth of temporal operators in a formula.
Useful for heuristic scoring in proof search - deeply nested temporal
operators require more temporal K applications.

Examples:
- `temporalDepth (atom "p")` = 0
- `temporalDepth (all_future (atom "p"))` = 1
- `temporalDepth (all_future (all_future (atom "p")))` = 2
- `temporalDepth (imp (all_future p) (all_past q))` = 1
-/
def temporalDepth : Formula → Nat
  | atom _ => 0
  | bot => 0
  | imp φ ψ => max φ.temporalDepth ψ.temporalDepth
  | box φ => φ.temporalDepth
  | all_past φ => 1 + φ.temporalDepth
  | all_future φ => 1 + φ.temporalDepth

/--
Count implication operators in a formula.

Counts the number of → operators in a formula.
Useful for heuristic scoring - more implications mean more modus ponens opportunities.

Examples:
- `countImplications (atom "p")` = 0
- `countImplications (imp p q)` = 1
- `countImplications (imp (imp p q) r)` = 2
- `countImplications (imp p (imp q r))` = 2
-/
def countImplications : Formula → Nat
  | atom _ => 0
  | bot => 0
  | imp φ ψ => 1 + φ.countImplications + ψ.countImplications
  | box φ => φ.countImplications
  | all_past φ => φ.countImplications
  | all_future φ => φ.countImplications

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
  `always φ := H φ ∧ φ ∧ G φ`

This means φ holds at all past times, at the present time, and at all future times.
This is the "eternal truth" or "omnitemporality" operator.

**Paper Reference**: Line 427 defines `△φ := Hφ ∧ φ ∧ Gφ`

Note: The paper uses this definition for the TL axiom `△φ → G(Hφ)` which
is trivially valid: if φ holds at ALL times, then at any future time z,
φ holds at all times w < z (since "all times" includes all such w).
-/
def always (φ : Formula) : Formula := φ.all_past.and (φ.and φ.all_future)

/--
Temporal 'sometimes' operator (▽φ, "at some time" - φ holds at some time).

Following JPL paper §sec:Appendix definition:
  `sometimes φ := past φ ∨ φ ∨ future φ`

This means φ holds at some past time, or at the present time, or at some future time.
This is the "sometime" or existential temporal operator, dual to `always`.

**Paper Reference**: Line 427 defines `▽φ := pφ ∨ φ ∨ fφ`
where p = some_past and f = some_future (existential duals).

Equivalently, `sometimes φ = ¬(always ¬φ)` by De Morgan's laws.
-/
def sometimes (φ : Formula) : Formula := φ.neg.always.neg

/-- Notation for temporal 'always' operator using upward triangle.
    Represents universal temporal quantification: φ holds at all times (past, present, future).
    Defined as: H φ ∧ φ ∧ G φ
    Unicode: U+25B3 WHITE UP-POINTING TRIANGLE
-/
prefix:80 "△" => Formula.always

/-- Notation for temporal 'sometimes' operator using downward triangle.
    Represents existential temporal quantification: φ holds at some time (past, present, or future).
    Defined as dual: ¬△¬φ (equivalently, P φ ∨ φ ∨ F φ)
    Unicode: U+25BD WHITE DOWN-POINTING TRIANGLE
-/
prefix:80 "▽" => Formula.sometimes

/--
Existential past operator (Pφ, "φ was true at some past time").

Derived as: ¬H¬φ = ¬(all_past (¬φ)) (not for-all-past not φ).
This means: there exists a past time where φ is true.

**DSL Notation**: `P φ` for "Past" / "Previously"

Note: H (always in past) is our `all_past`, and P (sometime past) is this operator.
-/
def some_past (φ : Formula) : Formula := φ.neg.all_past.neg

/--
Existential future operator (Fφ, "φ will be true at some future time").

Derived as: ¬G¬φ = ¬(all_future (¬φ)) (not for-all-future not φ).
This means: there exists a future time where φ is true.

**DSL Notation**: `F φ` for "Future" / "Finally"

Note: G (always in future) is our `all_future`, and F (sometime future) is this operator.
-/
def some_future (φ : Formula) : Formula := φ.neg.all_future.neg


/-- Alias for backward compatibility during refactoring.
    Use `some_past` instead.
-/
abbrev sometime_past := some_past

/-- Alias for backward compatibility during refactoring.
    Use `some_future` instead.
-/
abbrev sometime_future := some_future

/--
Swap temporal operators (past ↔ future) in a formula.

This transformation is used in the temporal duality inference rule (TD),
which states that if `⊢ φ` then `⊢ swap_temporal φ`.

The function recursively swaps:
- `all_past φ` ↔ `all_future φ`
- All other constructors are preserved with recursive application
-/
def swap_temporal : Formula → Formula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swap_temporal ψ.swap_temporal
  | box φ => box φ.swap_temporal
  | all_past φ => all_future φ.swap_temporal
  | all_future φ => all_past φ.swap_temporal

/-- Alias for backward compatibility during refactoring. -/
abbrev swap_past_future := swap_temporal

/--
Theorem: swap_temporal is an involution (applying it twice gives identity).

This is essential for the temporal duality rule to be well-behaved.
-/
theorem swap_temporal_involution (φ : Formula) :
  φ.swap_temporal.swap_temporal = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp [swap_temporal, ihp, ihq]
  | box _ ih => simp [swap_temporal, ih]
  | all_past _ ih => simp [swap_temporal, ih]
  | all_future _ ih => simp [swap_temporal, ih]

/-- Alias for backward compatibility. -/
@[simp]
theorem swap_past_future_involution (φ : Formula) :
  φ.swap_past_future.swap_past_future = φ := swap_temporal_involution φ

/--
Temporal swap distributes over diamond: `swap(◇φ) = ◇(swap φ)`.

Since `diamond φ = φ.neg.box.neg`, and `swap_temporal` recurses through
`imp` and `box` without changing their structure (only swapping all_past/all_future),
we have:
- `swap(φ.neg.box.neg) = swap(φ.neg).box.neg = (swap φ).neg.box.neg = (swap φ).diamond`

Note: `neg φ = φ.imp bot` and `swap_temporal bot = bot`, so
`swap_temporal (φ.neg) = (swap_temporal φ).neg`.
-/
theorem swap_temporal_diamond (φ : Formula) :
    φ.diamond.swap_temporal = φ.swap_temporal.diamond := by
  simp only [diamond, neg, swap_temporal]

/--
Temporal swap distributes over negation: `swap(¬φ) = ¬(swap φ)`.

Since `neg φ = φ.imp bot` and `swap_temporal bot = bot`:
`swap(φ.imp bot) = (swap φ).imp bot = (swap φ).neg`
-/
theorem swap_temporal_neg (φ : Formula) :
    φ.neg.swap_temporal = φ.swap_temporal.neg := by
  simp only [neg, swap_temporal]

end Formula

end Bimodal.Syntax
