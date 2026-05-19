import Bimodal.Syntax.Atom

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

- Atoms are represented as `Atom` (structured type with base string and optional fresh index)
- This enables freshness: for any finite set of atoms, there exists an atom not in the set
- Bot (⊥) is primitive; negation is derived via implication
- Box (□) is primitive; diamond (◇) is derived via De Morgan duality
- `untl` and `snce` are primitive temporal operators
- `all_past`, `all_future`, `some_past`, `some_future` are derived via `def` abbreviations
- `always`, `sometimes` are derived from these

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

/--
Formula type for bimodal logic TM.

A formula is built from 6 primitive constructors:
- Propositional atoms (strings)
- Bottom (⊥, falsum)
- Implication (→)
- Modal necessity (□)
- Until (U, "ψ holds until φ")
- Since (S, "ψ has held since φ")

All other connectives and operators are derived from these primitives:
- G (all_future) = ¬F(¬φ) where F(φ) = U(φ, ⊤)
- H (all_past) = ¬P(¬φ) where P(φ) = S(φ, ⊤)
- F (some_future) = U(φ, ⊤)
- P (some_past) = S(φ, ⊤)

**Reference**: Burgess 1982 §1.1 — G, H, F, P defined in terms of U and S.
-/
inductive Formula : Type where
  /-- Propositional atom (variable) -/
  | atom : Atom → Formula
  /-- Bottom (⊥, falsum, contradiction) -/
  | bot : Formula
  /-- Implication (φ → ψ) -/
  | imp : Formula → Formula → Formula
  /-- Modal necessity (□φ, "necessarily φ") -/
  | box : Formula → Formula
  /-- Until U(φ, ψ) — Burgess convention: φ = event (eventually true), ψ = guard (holds in between).
      "ψ holds until φ becomes true": ∃ s > t, φ(s) ∧ ∀ r ∈ (t,s), ψ(r). -/
  | untl : Formula → Formula → Formula
  /-- Since S(φ, ψ) — Burgess convention: φ = event (was true), ψ = guard (held in between).
      "ψ has held since φ was true": ∃ s < t, φ(s) ∧ ∀ r ∈ (s,t), ψ(r). -/
  | snce : Formula → Formula → Formula
  deriving Repr, DecidableEq, BEq, Hashable, Countable

/-!
### Infinite and Denumerable Instances

Formula is infinite (via injection from Atom) and denumerable (countable + infinite).
These instances enable enumeration of all formulas for the dovetailed chain construction.
-/

/-- Formula.atom is injective. -/
theorem Formula.atom_injective : Function.Injective Formula.atom := by
  intro a b h
  injection h

/-- Formula is infinite since Atom is infinite and Formula.atom is injective. -/
instance : Infinite Formula := Infinite.of_injective Formula.atom Formula.atom_injective

/-- Formula is denumerable (countable + infinite = bijection with Nat). -/
noncomputable instance : Denumerable Formula := Classical.choice (nonempty_denumerable Formula)

namespace Formula

/-- Create an atom formula from a string (backward compatibility helper).
    Uses `Atom.mk_base` to create a base atom with no fresh index. -/
def atom_s (s : String) : Formula := atom (Atom.mk_base s)

/-- Top (⊤, verum, tautology): ⊥ → ⊥ -/
def top : Formula := Formula.bot.imp Formula.bot

/-- Negation (¬φ) as derived operator: φ → ⊥ -/
def neg (φ : Formula) : Formula := φ.imp bot

/--
Existential future operator (Fφ, "φ will be true at some future time").

Derived as: F(φ) = U(φ, ⊤) — "φ eventually, with ⊤ holding until then".
This means: there exists a future time where φ is true.

**DSL Notation**: `F φ` for "Future" / "Finally"
-/
def some_future (φ : Formula) : Formula := Formula.untl φ Formula.top

/--
Existential past operator (Pφ, "φ was true at some past time").

Derived as: P(φ) = S(φ, ⊤) — "φ occurred, with ⊤ holding since then".
This means: there exists a past time where φ is true.

**DSL Notation**: `P φ` for "Past" / "Previously"
-/
def some_past (φ : Formula) : Formula := Formula.snce φ Formula.top

/--
Universal future operator (Gφ, "φ will always be true").

Derived as: G(φ) = ¬F(¬φ) = ¬(U(¬φ, ⊤)) — "it is not the case that ¬φ eventually".
This means: φ holds at all strictly future times.

**DSL Notation**: `G φ` for "Globally" / "Generally"
-/
def all_future (φ : Formula) : Formula := (some_future φ.neg).neg

/--
Universal past operator (Hφ, "φ has always been true").

Derived as: H(φ) = ¬P(¬φ) = ¬(S(¬φ, ⊤)) — "it is not the case that ¬φ occurred".
This means: φ holds at all strictly past times.

**DSL Notation**: `H φ` for "Historically"
-/
def all_past (φ : Formula) : Formula := (some_past φ.neg).neg

/--
Structural complexity of a formula (number of connectives + 1).

Useful for well-founded recursion and proof complexity analysis.
-/
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  | untl φ ψ => 1 + φ.complexity + ψ.complexity
  | snce φ ψ => 1 + φ.complexity + ψ.complexity

/-!
### BEq Reflexivity

The derived BEq instance for Formula compares structurally. We prove
that it's reflexive to enable `beq_self_eq_true` for Formula and types
containing Formula (like SignedFormula).
-/

/-- Helper lemmas for derived BEq definitional equalities. -/
private theorem beq_imp_eq (a b c d : Formula) :
    (imp a b == imp c d) = ((a == c) && (b == d)) := rfl

private theorem beq_box_eq (a b : Formula) :
    (box a == box b) = (a == b) := rfl

private theorem beq_untl_eq (a b c d : Formula) :
    (untl a b == untl c d) = ((a == c) && (b == d)) := rfl

private theorem beq_snce_eq (a b c d : Formula) :
    (snce a b == snce c d) = ((a == c) && (b == d)) := rfl

/-- BEq on Formula is reflexive. -/
theorem beq_refl (φ : Formula) : (φ == φ) = true := by
  induction φ with
  | atom p => exact @beq_self_eq_true Atom _ _ p
  | bot => native_decide
  | imp a b iha ihb => rw [beq_imp_eq, iha, ihb]; rfl
  | box a ih => rw [beq_box_eq, ih]
  | untl a b iha ihb => rw [beq_untl_eq, iha, ihb]; rfl
  | snce a b iha ihb => rw [beq_snce_eq, iha, ihb]; rfl

instance : ReflBEq Formula where
  rfl := beq_refl _

/-- BEq on Formula is injective: if `φ == ψ = true` then `φ = ψ`. -/
theorem eq_of_beq {φ ψ : Formula} (h : (φ == ψ) = true) : φ = ψ := by
  induction φ generalizing ψ with
  | atom p =>
    match ψ with
    | atom q =>
      have heq : (atom p == atom q) = (p == q) := rfl
      rw [heq] at h; exact congrArg atom (beq_iff_eq.mp h)
    | bot | imp _ _ | box _ | untl _ _ | snce _ _ => exact nomatch h
  | bot =>
    match ψ with
    | bot => rfl
    | atom _ | imp _ _ | box _ | untl _ _ | snce _ _ => exact nomatch h
  | imp a b iha ihb =>
    match ψ with
    | imp c d =>
      have heq : (imp a b == imp c d) = ((a == c) && (b == d)) := rfl
      rw [heq] at h; simp only [Bool.and_eq_true] at h
      exact congrArg₂ imp (iha h.1) (ihb h.2)
    | atom _ | bot | box _ | untl _ _ | snce _ _ => exact nomatch h
  | box a ih =>
    match ψ with
    | box c =>
      have heq : (box a == box c) = (a == c) := rfl
      rw [heq] at h; exact congrArg box (ih h)
    | atom _ | bot | imp _ _ | untl _ _ | snce _ _ => exact nomatch h
  | untl a b iha ihb =>
    match ψ with
    | untl c d =>
      have heq : (untl a b == untl c d) = ((a == c) && (b == d)) := rfl
      rw [heq] at h; simp only [Bool.and_eq_true] at h
      exact congrArg₂ untl (iha h.1) (ihb h.2)
    | atom _ | bot | imp _ _ | box _ | snce _ _ => exact nomatch h
  | snce a b iha ihb =>
    match ψ with
    | snce c d =>
      have heq : (snce a b == snce c d) = ((a == c) && (b == d)) := rfl
      rw [heq] at h; simp only [Bool.and_eq_true] at h
      exact congrArg₂ snce (iha h.1) (ihb h.2)
    | atom _ | bot | imp _ _ | box _ | untl _ _ => exact nomatch h

instance : LawfulBEq Formula where
  eq_of_beq := eq_of_beq
  rfl := beq_refl _

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
  | untl φ ψ => max φ.modalDepth ψ.modalDepth
  | snce φ ψ => max φ.modalDepth ψ.modalDepth

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
  | untl φ ψ => 1 + max φ.temporalDepth ψ.temporalDepth
  | snce φ ψ => 1 + max φ.temporalDepth ψ.temporalDepth

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
  | untl φ ψ => φ.countImplications + ψ.countImplications
  | snce φ ψ => φ.countImplications + ψ.countImplications

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

/-- Next-step operator: X(phi) = U(phi, bot) (Burgess convention: event first, guard second).
    X(phi) at t means phi holds at t+1 (event=phi at immediate successor, guard=bot vacuous). -/
def next (φ : Formula) : Formula := Formula.untl φ Formula.bot

/-- Previous-step operator: Y(phi) = S(phi, bot) (Burgess convention: event first, guard second).
    Y(phi) at t means phi holds at t-1 (event=phi at immediate predecessor, guard=bot vacuous). -/
def prev (φ : Formula) : Formula := Formula.snce φ Formula.bot

/--
Derived reflexive future operator (G'φ := φ ∧ Gφ, "now and always in the future").

With irreflexive semantics (G uses strict <), this derived operator recovers
the reflexive universal future quantifier: G'φ holds iff φ holds at t AND at
all s > t. This is useful when the reflexive reading is needed.
-/
def weak_future (φ : Formula) : Formula := φ.and φ.all_future

/--
Derived reflexive past operator (H'φ := φ ∧ Hφ, "now and always in the past").

With irreflexive semantics (H uses strict <), this derived operator recovers
the reflexive universal past quantifier: H'φ holds iff φ holds at t AND at
all s < t. This is useful when the reflexive reading is needed.
-/
def weak_past (φ : Formula) : Formula := φ.and φ.all_past

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
  | untl φ ψ => snce φ.swap_temporal ψ.swap_temporal
  | snce φ ψ => untl φ.swap_temporal ψ.swap_temporal


/--
Theorem: swap_temporal is an involution (applying it twice gives identity).

This is essential for the temporal duality rule to be well-behaved.
-/
theorem swap_temporal_involution (φ : Formula) :
  φ.swap_temporal.swap_temporal = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp only [swap_temporal, ihp, ihq]
  | box _ ih => simp only [swap_temporal, ih]
  | untl _ _ ih1 ih2 => simp only [swap_temporal, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [swap_temporal, ih1, ih2]


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

/-- swap_temporal exchanges some_future and some_past: swap(F(φ)) = P(swap(φ)). -/
@[simp]
theorem swap_temporal_some_future (φ : Formula) :
    (some_future φ).swap_temporal = some_past φ.swap_temporal := by
  simp only [some_future, some_past, top, swap_temporal]

/-- swap_temporal exchanges some_past and some_future: swap(P(φ)) = F(swap(φ)). -/
@[simp]
theorem swap_temporal_some_past (φ : Formula) :
    (some_past φ).swap_temporal = some_future φ.swap_temporal := by
  simp only [some_past, some_future, top, swap_temporal]

/-- swap_temporal exchanges all_future and all_past: swap(G(φ)) = H(swap(φ)). -/
@[simp]
theorem swap_temporal_all_future (φ : Formula) :
    (all_future φ).swap_temporal = all_past φ.swap_temporal := by
  simp only [all_future, all_past, some_future, some_past, neg, top, swap_temporal]

/-- swap_temporal exchanges all_past and all_future: swap(H(φ)) = G(swap(φ)). -/
@[simp]
theorem swap_temporal_all_past (φ : Formula) :
    (all_past φ).swap_temporal = all_future φ.swap_temporal := by
  simp only [all_past, all_future, some_past, some_future, neg, top, swap_temporal]

/-- swap_temporal distributes over next/prev: swap(X(phi)) = Y(swap(phi)). -/
theorem swap_temporal_next (φ : Formula) :
    φ.next.swap_temporal = φ.swap_temporal.prev := by
  simp [next, prev, swap_temporal]

/-- swap_temporal distributes over prev/next: swap(Y(phi)) = X(swap(phi)). -/
theorem swap_temporal_prev (φ : Formula) :
    φ.prev.swap_temporal = φ.swap_temporal.next := by
  simp [prev, next, swap_temporal]

/--
Formula requires the single-family/single-time hypotheses in buildSeedAux.
All non-imp formulas need these for propagation. Imp formulas (including
neg-Box, neg-G, neg-H, and generic imp) don't need them because they only
recurse into other imp formulas which also don't need them.
-/
def needsPositiveHypotheses : Formula → Bool
  | Formula.imp _ _ => false  -- All imp cases
  | _ => true  -- atom, bot, box, G, H, until, since

@[simp] lemma needsPositiveHypotheses_atom (s : Atom) :
    (Formula.atom s).needsPositiveHypotheses = true := rfl

@[simp] lemma needsPositiveHypotheses_bot :
    Formula.bot.needsPositiveHypotheses = true := rfl

@[simp] lemma needsPositiveHypotheses_box (psi : Formula) :
    (Formula.box psi).needsPositiveHypotheses = true := rfl

@[simp] lemma needsPositiveHypotheses_untl (p q : Formula) :
    (Formula.untl p q).needsPositiveHypotheses = true := rfl

@[simp] lemma needsPositiveHypotheses_snce (p q : Formula) :
    (Formula.snce p q).needsPositiveHypotheses = true := rfl

@[simp] lemma needsPositiveHypotheses_imp (p q : Formula) :
    (Formula.imp p q).needsPositiveHypotheses = false := rfl

/-!
### Propositional Atoms

The set of propositional atoms (variable names) occurring in a formula.
Used for freshness conditions in the IRR (Irreflexivity) rule.
-/

/-- The set of propositional atoms appearing in a formula. -/
def atoms : Formula → Finset Atom
  | atom s => {s}
  | bot => ∅
  | imp φ ψ => φ.atoms ∪ ψ.atoms
  | box φ => φ.atoms
  | untl φ ψ => φ.atoms ∪ ψ.atoms
  | snce φ ψ => φ.atoms ∪ ψ.atoms

/-- swap_temporal preserves atoms: swapping past/future does not change which atoms appear. -/
theorem atoms_swap_temporal (φ : Formula) : φ.swap_temporal.atoms = φ.atoms := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [swap_temporal, atoms, ih1, ih2]
  | box _ ih => simp only [swap_temporal, atoms, ih]
  | untl _ _ ih1 ih2 => simp only [swap_temporal, atoms, ih1, ih2]
  | snce _ _ ih1 ih2 => simp only [swap_temporal, atoms, ih1, ih2]

/-!
### Predicate Formulas (for Standard Translation)

The set of subformulas that become predicate symbols in the Reynolds standard
translation: atoms (as `Formula.atom a`) and box-subformulas (as `Formula.box φ`).
-/

/-- The set of formulas treated as predicate symbols in the monadic FO translation:
    atoms `Formula.atom a` and box-subformulas `Formula.box φ`. -/
def predFormulas : Formula → Finset Formula
  | atom a => {atom a}
  | bot => ∅
  | imp φ ψ => φ.predFormulas ∪ ψ.predFormulas
  | box φ => {box φ} ∪ φ.predFormulas
  | untl φ ψ => φ.predFormulas ∪ ψ.predFormulas
  | snce φ ψ => φ.predFormulas ∪ ψ.predFormulas

end Formula

end Bimodal.Syntax
