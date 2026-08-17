/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Syntax.Atom

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
- `Formula.swapTemporal`: Temporal duality transformation

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
- `allPast`, `allFuture`, `somePast`, `someFuture` are derived via `def` abbreviations
- `always`, `sometimes` are derived from these

## Naming Convention

Follows the `box`/`□` pattern with descriptive function names:
- Universal temporal: `allPast` (H), `allFuture` (G)
- Existential temporal: `somePast` (P), `someFuture` (F)
- Derived: `always` (△), `sometimes` (▽)

Use method syntax: `φ.allPast`, `φ.someFuture`, etc.

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - TM logic specification
* [LEAN Style Guide](../../../docs/development/LEAN_STYLE_GUIDE.md) - Coding conventions
-/

namespace FormalSystem.Syntax

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
- G (allFuture) = ¬F(¬φ) where F(φ) = U(φ, ⊤)
- H (allPast) = ¬P(¬φ) where P(φ) = S(φ, ⊤)
- F (someFuture) = U(φ, ⊤)
- P (somePast) = S(φ, ⊤)

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
  /-- Until, `φ U ψ`. **Argument 1 is the guard, argument 2 is the event.**

      `untlQ φ ψ` holds at `t` iff the *event* `ψ` is witnessed at some strictly later time `s`,
      and the *guard* `φ` holds at every time in the open interval `(t, s)`:
      `∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r)`.

      This is the guard-first order of the paper's `def:BLplus-semantics`, whose `(until)` clause
      reads "M,τ,x ⊨ φ until ψ iff M,τ,z ⊨ ψ for some time z > x where M,τ,y ⊨ φ for all y ∈ D
      with x < y < z" — the existential witness is the *second* argument, the universally
      quantified interval condition the *first*. It agrees with the same definition's derived
      operators `future φ := ⊤ until φ` and `Next φ := ⊥ until φ` (`def:BLplus-defined`). -/
  | untlQ : Formula → Formula → Formula
  /-- Since, `φ S ψ`. **Argument 1 is the guard, argument 2 is the event.**

      `snceQ φ ψ` holds at `t` iff the *event* `ψ` is witnessed at some strictly earlier time `s`,
      and the *guard* `φ` holds at every time in the open interval `(s, t)`:
      `∃ s < t, ψ(s) ∧ ∀ r ∈ (s,t), φ(r)`.

      The past mirror of `untlQ`, and the guard-first order of `def:BLplus-semantics`'s `(since)`
      clause; it agrees with `past φ := ⊤ since φ` and `Previous φ := ⊥ since φ`
      (`def:BLplus-defined`). -/
  | snceQ : Formula → Formula → Formula
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
    Uses `Atom.mkBase` to create a base atom with no fresh index. -/
def atomS (s : String) : Formula := atom (Atom.mkBase s)

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
def someFuture (φ : Formula) : Formula := Formula.untlQ Formula.top φ

/--
Existential past operator (Pφ, "φ was true at some past time").

Derived as: P(φ) = S(φ, ⊤) — "φ occurred, with ⊤ holding since then".
This means: there exists a past time where φ is true.

**DSL Notation**: `P φ` for "Past" / "Previously"
-/
def somePast (φ : Formula) : Formula := Formula.snceQ Formula.top φ

/--
Universal future operator (Gφ, "φ will always be true").

Derived as: G(φ) = ¬F(¬φ) = ¬(U(¬φ, ⊤)) — "it is not the case that ¬φ eventually".
This means: φ holds at all strictly future times.

**DSL Notation**: `G φ` for "Globally" / "Generally"
-/
def allFuture (φ : Formula) : Formula := (someFuture φ.neg).neg

/--
Universal past operator (Hφ, "φ has always been true").

Derived as: H(φ) = ¬P(¬φ) = ¬(S(¬φ, ⊤)) — "it is not the case that ¬φ occurred".
This means: φ holds at all strictly past times.

**DSL Notation**: `H φ` for "Historically"
-/
def allPast (φ : Formula) : Formula := (somePast φ.neg).neg

/--
Reynolds' `K⁺` operator: `K⁺A = ¬U(⊤, ¬A)` — "A holds arbitrarily soon in the future",
i.e. A is true throughout some initial segment of the future, or equivalently there is no
future point at which ¬A holds with ⊤ holding until then.

**Source**: Reynolds 1992, abbreviation table, printed p.168; corroborated by
Gabbay-Hodkinson-Reynolds 1994 §10.3.1, which defines `K⁺q = ¬U(⊤, ¬q)`.

**NAME-COLLISION WARNING.** This is NOT the same operator as `kplusFormula` in
`FormalSystem/Metalogic/WeakCanonical/Kamp/PriorINF.lean`. That one is
`P.neg ∧ ¬(⊤ U P.neg)` — it carries an extra `¬P` conjunct ("P holds arbitrarily soon after
`t`, *but not at `t` itself*"). Reynolds' and GHR's `K⁺` has no such conjunct. Substituting one
for the other silently transcribes a different axiom. `kplusFormula` also lives in `Metalogic/`,
downstream of `ProofSystem/`, so it is not importable from `Axioms.lean` in any case.

Used to state `Axiom.prior_U_gap` and `Axiom.sep`.
-/
def kPlus (φ : Formula) : Formula := (Formula.untlQ φ.neg Formula.top).neg

/--
Reynolds' `K⁻` operator: `K⁻A = ¬S(⊤, ¬A)` — the past dual of `kPlus`, "A held arbitrarily
recently in the past".

**Source**: Reynolds 1992, abbreviation table, printed p.168; GHR 1994 §10.3.1
(`K⁻q = ¬S(⊤, ¬q)`).

Same name-collision caveat as `kPlus`: do not confuse with `Metalogic`'s `kminusFormula`.

Used to state `Axiom.prior_S_gap` and `Axiom.sep`.
-/
def kMinus (φ : Formula) : Formula := (Formula.snceQ φ.neg Formula.top).neg

/--
Structural complexity of a formula (number of connectives + 1).

Useful for well-founded recursion and proof complexity analysis.

Pattern-aware cases for derived temporal operators:
- `F(φ) = U(φ, ⊤)` → treated as overhead 1 (matching box), not 4
- `P(φ) = S(φ, ⊤)` → treated as overhead 1 (matching box), not 4
- `G(φ) = ¬F(¬φ) = (U(¬φ, ⊤) → ⊥)` → treated as overhead 1 (matching box), not 8
- `H(φ) = ¬P(¬φ) = (S(¬φ, ⊤) → ⊥)` → treated as overhead 1 (matching box), not 8

This enables bimodal G/H formulas to appear at c5-c7 instead of c11+.
-/
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  -- always(φ) = H(φ) ∧ φ ∧ G(φ) → 1 + φ.complexity
  -- Expansion: imp (imp (imp (snce (imp φ bot) (imp bot bot)) bot) (imp (imp (imp φ₂ (imp (imp
  -- (untl (imp φ₃ bot) (imp bot bot)) bot) bot)) bot) bot)) bot
  | imp
    (imp (imp (snceQ (imp bot bot) (imp _φ1 bot)) bot)
      (imp (imp (imp _φ2 (imp (imp (untlQ (imp bot bot) (imp _φ3 bot)) bot) bot)) bot) bot)) bot =>
      1 + _φ1.complexity
  -- sometimes(φ) = ¬always(¬φ) → 1 + φ.complexity
  -- Expansion: imp (always(neg φ)) bot
  | imp
    (imp
      (imp (imp (snceQ (imp bot bot) (imp (imp _φ1 bot) bot)) bot)
        (imp
          (imp (imp (imp _φ2 bot) (imp (imp (untlQ (imp bot bot) (imp (imp _φ3 bot) bot)) bot) bot))
            bot) bot)) bot) bot => 1 + _φ1.complexity
  -- weakFuture(φ) = φ ∧ G(φ) → 1 + φ.complexity
  -- Expansion: imp (imp φ (imp (imp (untl (imp φ₂ bot) (imp bot bot)) bot) bot)) bot
  | imp (imp _φ1 (imp (imp (untlQ (imp bot bot) (imp _φ2 bot)) bot) bot)) bot => 1 + _φ1.complexity
  -- weakPast(φ) = φ ∧ H(φ) → 1 + φ.complexity
  -- Expansion: imp (imp φ (imp (imp (snce (imp φ₂ bot) (imp bot bot)) bot) bot)) bot
  | imp (imp _φ1 (imp (imp (snceQ (imp bot bot) (imp _φ2 bot)) bot) bot)) bot => 1 + _φ1.complexity
  -- WU(φ, ψ) = weakUntil φ ψ = (untl φ ψ).or ψ.allFuture → 1 + φ.complexity + ψ.complexity
  | imp (imp (untlQ ψ φ) bot) (imp (untlQ (imp bot bot) (imp _ψ2 bot)) bot) =>
    1 + φ.complexity + ψ.complexity
  -- WS(φ, ψ) = weakSince φ ψ = (snce φ ψ).or ψ.allPast → 1 + φ.complexity + ψ.complexity
  | imp (imp (snceQ ψ φ) bot) (imp (snceQ (imp bot bot) (imp _ψ2 bot)) bot) =>
    1 + φ.complexity + ψ.complexity
  -- diamond(φ) = ¬□¬φ = imp (box (imp φ bot)) bot → 1 + φ.complexity
  | imp (box (imp φ bot)) bot => 1 + φ.complexity
  -- G(φ) = imp (untl (imp φ bot) (imp bot bot)) bot → 1 + φ.complexity
  | imp (untlQ (imp bot bot) (imp φ bot)) bot => 1 + φ.complexity
  -- H(φ) = imp (snce (imp φ bot) (imp bot bot)) bot → 1 + φ.complexity
  | imp (snceQ (imp bot bot) (imp φ bot)) bot => 1 + φ.complexity
  -- R(φ, ψ) = release φ ψ = (untl φ.neg ψ.neg).neg → 1 + φ.complexity + ψ.complexity
  | imp (untlQ (imp ψ bot) (imp φ bot)) bot => 1 + φ.complexity + ψ.complexity
  -- T(φ, ψ) = trigger φ ψ = (snce φ.neg ψ.neg).neg → 1 + φ.complexity + ψ.complexity
  | imp (snceQ (imp ψ bot) (imp φ bot)) bot => 1 + φ.complexity + ψ.complexity
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  -- next(φ) = untl φ bot → 1 + φ.complexity
  | untlQ .bot φ => 1 + φ.complexity
  -- F(φ) = untl φ (imp bot bot) → 1 + φ.complexity
  | untlQ (imp bot bot) φ => 1 + φ.complexity
  -- M(φ, ψ) = strongRelease φ ψ = untl (and ψ φ) ψ → 2 + φ.complexity + ψ.complexity
  | untlQ _ψ2 (imp (imp ψ (imp φ bot)) bot) => 2 + φ.complexity + ψ.complexity
  | untlQ ψ φ => 1 + φ.complexity + ψ.complexity
  -- prev(φ) = snce φ bot → 1 + φ.complexity
  | snceQ .bot φ => 1 + φ.complexity
  -- P(φ) = snce φ (imp bot bot) → 1 + φ.complexity
  | snceQ (imp bot bot) φ => 1 + φ.complexity
  -- ST(φ, ψ) = strongTrigger φ ψ = snce (and ψ φ) ψ → 2 + φ.complexity + ψ.complexity
  | snceQ _ψ2 (imp (imp ψ (imp φ bot)) bot) => 2 + φ.complexity + ψ.complexity
  | snceQ ψ φ => 1 + φ.complexity + ψ.complexity

/-! ### Complexity verification: unary temporal operators -/

private def p_cmplx : Formula := .atom (Atom.mkBase "p")
private def q_cmplx : Formula := .atom (Atom.mkBase "q")

-- F(atom) should be 2 (was 5)
#eval p_cmplx.someFuture.complexity  -- 2

-- P(atom) should be 2 (was 5)
#eval p_cmplx.somePast.complexity  -- 2

-- G(atom) should be 2 (was 9)
#eval p_cmplx.allFuture.complexity  -- 2

-- H(atom) should be 2 (was 9)
#eval p_cmplx.allPast.complexity  -- 2

-- box(G(atom)) should be 3 (was 11)
#eval p_cmplx.allFuture.box.complexity  -- 3

-- Regular untl/snce still work correctly
#eval (Formula.untlQ q_cmplx p_cmplx).complexity  -- 3
#eval (Formula.snceQ q_cmplx p_cmplx).complexity  -- 3

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
    (untlQ a b == untlQ c d) = ((a == c) && (b == d)) := rfl

private theorem beq_snce_eq (a b c d : Formula) :
    (snceQ a b == snceQ c d) = ((a == c) && (b == d)) := rfl

/-- BEq on Formula is reflexive. -/
theorem beq_refl (φ : Formula) : (φ == φ) = true := by
  induction φ with
  | atom p => exact @beq_self_eq_true Atom _ _ p
  | bot => rfl
  | imp a b iha ihb => rw [beq_imp_eq, iha, ihb]; rfl
  | box a ih => rw [beq_box_eq, ih]
  | untlQ a b iha ihb => rw [beq_untl_eq, iha, ihb]; rfl
  | snceQ a b iha ihb => rw [beq_snce_eq, iha, ihb]; rfl

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
    | bot | imp _ _ | box _ | untlQ _ _ | snceQ _ _ => exact nomatch h
  | bot =>
    match ψ with
    | bot => rfl
    | atom _ | imp _ _ | box _ | untlQ _ _ | snceQ _ _ => exact nomatch h
  | imp a b iha ihb =>
    match ψ with
    | imp c d =>
      have heq : (imp a b == imp c d) = ((a == c) && (b == d)) := rfl
      rw [heq] at h; simp only [Bool.and_eq_true] at h
      exact congrArg₂ imp (iha h.1) (ihb h.2)
    | atom _ | bot | box _ | untlQ _ _ | snceQ _ _ => exact nomatch h
  | box a ih =>
    match ψ with
    | box c =>
      have heq : (box a == box c) = (a == c) := rfl
      rw [heq] at h; exact congrArg box (ih h)
    | atom _ | bot | imp _ _ | untlQ _ _ | snceQ _ _ => exact nomatch h
  | untlQ a b iha ihb =>
    match ψ with
    | untlQ c d =>
      have heq : (untlQ a b == untlQ c d) = ((a == c) && (b == d)) := rfl
      rw [heq] at h; simp only [Bool.and_eq_true] at h
      exact congrArg₂ untlQ (iha h.1) (ihb h.2)
    | atom _ | bot | imp _ _ | box _ | snceQ _ _ => exact nomatch h
  | snceQ a b iha ihb =>
    match ψ with
    | snceQ c d =>
      have heq : (snceQ a b == snceQ c d) = ((a == c) && (b == d)) := rfl
      rw [heq] at h; simp only [Bool.and_eq_true] at h
      exact congrArg₂ snceQ (iha h.1) (ihb h.2)
    | atom _ | bot | imp _ _ | box _ | untlQ _ _ => exact nomatch h

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
  | untlQ ψ φ => max φ.modalDepth ψ.modalDepth
  | snceQ ψ φ => max φ.modalDepth ψ.modalDepth

/--
Temporal depth: nesting level of temporal operators (G, F, H, P).

Computes the maximum nesting depth of temporal operators in a formula.
Useful for heuristic scoring in proof search - deeply nested temporal
operators require more temporal K applications.

Examples:
- `temporalDepth (atom "p")` = 0
- `temporalDepth (allFuture (atom "p"))` = 1
- `temporalDepth (allFuture (allFuture (atom "p")))` = 2
- `temporalDepth (imp (allFuture p) (allPast q))` = 1
-/
def temporalDepth : Formula → Nat
  | atom _ => 0
  | bot => 0
  | imp φ ψ => max φ.temporalDepth ψ.temporalDepth
  | box φ => φ.temporalDepth
  | untlQ ψ φ => 1 + max φ.temporalDepth ψ.temporalDepth
  | snceQ ψ φ => 1 + max φ.temporalDepth ψ.temporalDepth

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
  | untlQ ψ φ => φ.countImplications + ψ.countImplications
  | snceQ ψ φ => φ.countImplications + ψ.countImplications

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
def always (φ : Formula) : Formula := φ.allPast.and (φ.and φ.allFuture)

/--
The paper's **CO** formula (Cauchy/completeness-of-order principle), as a *named abbreviation*:

  `CO(φ) := △(Hφ → F(Hφ)) → (Hφ → Gφ)`

**Source**: JPL paper anchor `TMP-CO` (the `\aitem[CO]{TMP-CO}` entry inside `def:TMplus-c`;
displayed key CO), verbatim:
"`\aitem[CO]{TMP-CO} $\always(\Past\varphi \rightarrow \future\Past\varphi) \rightarrow
(\Past\varphi \rightarrow \Future\varphi)$.`"
There CO is listed as the extra axiom distinguishing the complete-order extension of the base
tense logic.

**Operator resolution (important).** The `△` here is the **temporal** triangle
`Formula.always` — i.e. `△ψ = Hψ ∧ ψ ∧ Gψ` (see `Formula.always` immediately above) — and
**not** the modal box `Formula.box`. Writing `□` in its place transcribes a different axiom.
The four constituent operators are `Formula.allPast` (H), `Formula.someFuture` (F),
`Formula.allFuture` (G), and `Formula.always` (△).

**This is an abbreviation, not an `Axiom` constructor.** This repository's official
Dedekind-class axiom basis remains the Reynolds triple `Axiom.prior_U_gap` /
`Axiom.prior_S_gap` / `Axiom.sep`; CO is a *derived* object over that basis. See
`FormalSystem/Theorems/DedekindDerived.lean` (proof-theoretic side) and
`FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean` (`co_valid`, the semantic side).
The converse direction — CO deriving the Reynolds gap axioms — **fails**, and the failure is
machine-checked in `FormalSystem.Metalogic.Independence.CoNotPriorU`; see also the Layer 9
discussion in `FormalSystem/ProofSystem/Axioms.lean`.
-/
def co (φ : Formula) : Formula :=
  (Formula.always (φ.allPast.imp φ.allPast.someFuture)).imp (φ.allPast.imp φ.allFuture)

/-- Next-step operator: X(phi) = U(phi, bot) (Burgess convention: event first, guard second).
    X(phi) at t means phi holds at t+1 (event=phi at immediate successor, guard=bot vacuous). -/
def next (φ : Formula) : Formula := Formula.untlQ Formula.bot φ

/-- Previous-step operator: Y(phi) = S(phi, bot) (Burgess convention: event first, guard second).
    Y(phi) at t means phi holds at t-1 (event=phi at immediate predecessor, guard=bot vacuous). -/
def prev (φ : Formula) : Formula := Formula.snceQ Formula.bot φ

/--
Derived reflexive future operator (G'φ := φ ∧ Gφ, "now and always in the future").

With irreflexive semantics (G uses strict <), this derived operator recovers
the reflexive universal future quantifier: G'φ holds iff φ holds at t AND at
all s > t. This is useful when the reflexive reading is needed.
-/
def weakFuture (φ : Formula) : Formula := φ.and φ.allFuture

/--
Derived reflexive past operator (H'φ := φ ∧ Hφ, "now and always in the past").

With irreflexive semantics (H uses strict <), this derived operator recovers
the reflexive universal past quantifier: H'φ holds iff φ holds at t AND at
all s < t. This is useful when the reflexive reading is needed.
-/
def weakPast (φ : Formula) : Formula := φ.and φ.allPast

/--
Release operator R(φ, ψ) — dual of Until.

Release(φ, ψ) = ¬(¬φ U ¬ψ). In Burgess convention (untl event guard):
`untl φ.neg ψ.neg` = "¬ψ holds until ¬φ becomes true", negating gives release.

Semantically: ψ must hold at all future times until and including when φ first holds
(and if φ never holds, ψ must hold forever).
-/
def release (φ ψ : Formula) : Formula := (Formula.untlQ ψ.neg φ.neg).neg

/--
Weak Until operator W(φ, ψ) — Until without the liveness requirement.

Weak_until(φ, ψ) = (ψ U φ) ∨ G(ψ). In Burgess convention:
`untl φ ψ` = "ψ holds until φ", so weakUntil adds the possibility that
the guard ψ holds forever (the event φ may never occur).
-/
def weakUntil (φ ψ : Formula) : Formula := (Formula.untlQ ψ φ).or ψ.allFuture

/--
Trigger operator T(φ, ψ) — dual of Since (past analog of Release).

Trigger(φ, ψ) = ¬(¬φ S ¬ψ). In Burgess convention (snce event guard):
`snce φ.neg ψ.neg` = "¬ψ held since ¬φ was true", negating gives trigger.
-/
def trigger (φ ψ : Formula) : Formula := (Formula.snceQ ψ.neg φ.neg).neg

/--
Weak Since operator WS(φ, ψ) — Since without the liveness requirement.

Weak_since(φ, ψ) = (ψ S φ) ∨ H(ψ). In Burgess convention:
`snce φ ψ` = "ψ held since φ", so weakSince adds the possibility that
the guard ψ held forever in the past (the event φ may never have occurred).
-/
def weakSince (φ ψ : Formula) : Formula := (Formula.snceQ ψ φ).or ψ.allPast

/-- Strong Release operator M(φ, ψ) — ψ U (ψ ∧ φ). Dual of weak until. -/
def strongRelease (φ ψ : Formula) : Formula := Formula.untlQ ψ (Formula.and ψ φ)

/-- Strong Trigger operator ST(φ, ψ) — ψ S (ψ ∧ φ). Past dual of strong release. -/
def strongTrigger (φ ψ : Formula) : Formula := Formula.snceQ ψ (Formula.and ψ φ)

/-! ### Complexity verification: binary derived operators -/

private def p_cmplx2 : Formula := .atom (Atom.mkBase "p")
private def q_cmplx2 : Formula := .atom (Atom.mkBase "q")

-- R(atom, atom) should be 3 (was 9)
#eval (Formula.release p_cmplx2 q_cmplx2).complexity  -- 3

-- T(atom, atom) should be 3 (was 9)
#eval (Formula.trigger p_cmplx2 q_cmplx2).complexity  -- 3

-- WU(atom, atom) should be 3 (was 8)
#eval (Formula.weakUntil p_cmplx2 q_cmplx2).complexity  -- 3

-- WS(atom, atom) should be 3 (was 8)
#eval (Formula.weakSince p_cmplx2 q_cmplx2).complexity  -- 3

-- M(atom, atom) should be 4
#eval (Formula.strongRelease p_cmplx2 q_cmplx2).complexity  -- 4

-- ST(atom, atom) should be 4
#eval (Formula.strongTrigger p_cmplx2 q_cmplx2).complexity  -- 4

/--
Temporal 'sometimes' operator (▽φ, "at some time" - φ holds at some time).

Following JPL paper §sec:Appendix definition:
  `sometimes φ := past φ ∨ φ ∨ future φ`

This means φ holds at some past time, or at the present time, or at some future time.
This is the "sometime" or existential temporal operator, dual to `always`.

**Paper Reference**: Line 427 defines `▽φ := pφ ∨ φ ∨ fφ`
where p = somePast and f = someFuture (existential duals).

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

/-! ### Complexity verification: modal and compound temporal operators -/

private def p_cmplx3 : Formula := .atom (Atom.mkBase "p")

-- diamond(atom) should be 2 (was 6)
#eval p_cmplx3.diamond.complexity  -- 2

-- always(atom) should be 2 (was 15)
#eval p_cmplx3.always.complexity  -- 2

-- sometimes(atom) should be 2 (was 23)
#eval p_cmplx3.sometimes.complexity  -- 2

-- next(atom) should be 2 (was 3)
#eval p_cmplx3.next.complexity  -- 2

-- prev(atom) should be 2 (was 3)
#eval p_cmplx3.prev.complexity  -- 2

-- weakFuture(atom) should be 2 (was 8)
#eval p_cmplx3.weakFuture.complexity  -- 2

-- weakPast(atom) should be 2 (was 8)
#eval p_cmplx3.weakPast.complexity  -- 2

/--
Swap temporal operators (past ↔ future) in a formula.

This transformation is used in the temporal duality inference rule (TD),
which states that if `⊢ φ` then `⊢ swapTemporal φ`.

The function recursively swaps:
- `allPast φ` ↔ `allFuture φ`
- All other constructors are preserved with recursive application
-/
def swapTemporal : Formula → Formula
  | atom s => atom s
  | bot => bot
  | imp φ ψ => imp φ.swapTemporal ψ.swapTemporal
  | box φ => box φ.swapTemporal
  | untlQ ψ φ => snceQ ψ.swapTemporal φ.swapTemporal
  | snceQ ψ φ => untlQ ψ.swapTemporal φ.swapTemporal


/--
Theorem: swapTemporal is an involution (applying it twice gives identity).

This is essential for the temporal duality rule to be well-behaved.
-/
theorem swap_temporal_involution (φ : Formula) :
  φ.swapTemporal.swapTemporal = φ := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ihp ihq => simp only [swapTemporal, ihp, ihq]
  | box _ ih => simp only [swapTemporal, ih]
  | untlQ _ _ ih2 ih1 => simp only [swapTemporal, ih1, ih2]
  | snceQ _ _ ih2 ih1 => simp only [swapTemporal, ih1, ih2]


/--
Temporal swap distributes over diamond: `swap(◇φ) = ◇(swap φ)`.

Since `diamond φ = φ.neg.box.neg`, and `swapTemporal` recurses through
`imp` and `box` without changing their structure (only swapping allPast/allFuture),
we have:
- `swap(φ.neg.box.neg) = swap(φ.neg).box.neg = (swap φ).neg.box.neg = (swap φ).diamond`

Note: `neg φ = φ.imp bot` and `swapTemporal bot = bot`, so
`swapTemporal (φ.neg) = (swapTemporal φ).neg`.
-/
theorem swap_temporal_diamond (φ : Formula) :
    φ.diamond.swapTemporal = φ.swapTemporal.diamond := by
  simp only [diamond, neg, swapTemporal]

/--
Temporal swap distributes over negation: `swap(¬φ) = ¬(swap φ)`.

Since `neg φ = φ.imp bot` and `swapTemporal bot = bot`:
`swap(φ.imp bot) = (swap φ).imp bot = (swap φ).neg`
-/
theorem swap_temporal_neg (φ : Formula) :
    φ.neg.swapTemporal = φ.swapTemporal.neg := by
  simp only [neg, swapTemporal]

/-- swapTemporal exchanges someFuture and somePast: swap(F(φ)) = P(swap(φ)). -/
@[simp]
theorem swap_temporal_some_future (φ : Formula) :
    (someFuture φ).swapTemporal = somePast φ.swapTemporal := by
  simp only [someFuture, somePast, top, swapTemporal]

/-- swapTemporal exchanges somePast and someFuture: swap(P(φ)) = F(swap(φ)). -/
@[simp]
theorem swap_temporal_some_past (φ : Formula) :
    (somePast φ).swapTemporal = someFuture φ.swapTemporal := by
  simp only [somePast, someFuture, top, swapTemporal]

/-- swapTemporal exchanges allFuture and allPast: swap(G(φ)) = H(swap(φ)). -/
@[simp]
theorem swap_temporal_all_future (φ : Formula) :
    (allFuture φ).swapTemporal = allPast φ.swapTemporal := by
  simp only [allFuture, allPast, someFuture, somePast, neg, top, swapTemporal]

/-- swapTemporal exchanges allPast and allFuture: swap(H(φ)) = G(swap(φ)). -/
@[simp]
theorem swap_temporal_all_past (φ : Formula) :
    (allPast φ).swapTemporal = allFuture φ.swapTemporal := by
  simp only [allPast, allFuture, somePast, someFuture, neg, top, swapTemporal]

/-- swapTemporal distributes over next/prev: swap(X(phi)) = Y(swap(phi)). -/
theorem swap_temporal_next (φ : Formula) :
    φ.next.swapTemporal = φ.swapTemporal.prev := by
  simp [next, prev, swapTemporal]

/-- swapTemporal distributes over prev/next: swap(Y(phi)) = X(swap(phi)). -/
theorem swap_temporal_prev (φ : Formula) :
    φ.prev.swapTemporal = φ.swapTemporal.next := by
  simp [prev, next, swapTemporal]

/-- swapTemporal distributes over strongRelease: swap(M(φ,ψ)) = ST(swap(φ),swap(ψ)). -/
theorem swap_temporal_strong_release (φ ψ : Formula) :
    (Formula.strongRelease φ ψ).swapTemporal = Formula.strongTrigger φ.swapTemporal
      ψ.swapTemporal := by
  simp [strongRelease, strongTrigger, and, swapTemporal, swap_temporal_neg]

/-- swapTemporal distributes over strongTrigger: swap(ST(φ,ψ)) = M(swap(φ),swap(ψ)). -/
theorem swap_temporal_strong_trigger (φ ψ : Formula) :
    (Formula.strongTrigger φ ψ).swapTemporal = Formula.strongRelease φ.swapTemporal
      ψ.swapTemporal := by
  simp [strongRelease, strongTrigger, and, swapTemporal, swap_temporal_neg]

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
    (Formula.untlQ q p).needsPositiveHypotheses = true := rfl

@[simp] lemma needsPositiveHypotheses_snce (p q : Formula) :
    (Formula.snceQ q p).needsPositiveHypotheses = true := rfl

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
  | untlQ ψ φ => φ.atoms ∪ ψ.atoms
  | snceQ ψ φ => φ.atoms ∪ ψ.atoms

/-- swapTemporal preserves atoms: swapping past/future does not change which atoms appear. -/
theorem atoms_swap_temporal (φ : Formula) : φ.swapTemporal.atoms = φ.atoms := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp _ _ ih1 ih2 => simp only [swapTemporal, atoms, ih1, ih2]
  | box _ ih => simp only [swapTemporal, atoms, ih]
  | untlQ _ _ ih2 ih1 => simp only [swapTemporal, atoms, ih1, ih2]
  | snceQ _ _ ih2 ih1 => simp only [swapTemporal, atoms, ih1, ih2]

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
  | untlQ ψ φ => φ.predFormulas ∪ ψ.predFormulas
  | snceQ ψ φ => φ.predFormulas ∪ ψ.predFormulas

end Formula

end FormalSystem.Syntax
