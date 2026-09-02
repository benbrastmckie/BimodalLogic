/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.BiLasso.BoxOracle
import FormalSystem.Metalogic.Decidability.BiLasso.Examples

/-!
# `check` — the Shipped Decision Procedure

Everything below this point is assembly. `SatAtState` names the predicate being decided, `check`
decides it, `check_correct` is the two-way bridge, and `instDecidableSatAtState` is the instance
that bridge licenses.

## What is decided, and what is not

`check P w φ` decides satisfiability of `φ` **at the state `w` of the presented ℤ-frame `P`**. It
does *not* decide the logic: nothing here quantifies over frames. A presentation is a finite
adjacency matrix together with a valuation; `check` answers a question about that one structure.

### Stated the other way: this layer performs no part of the finite-model step

Its *input* is already a presentation — see `exists_annot_of_truth`
(`BiLasso/Extraction.lean`), which takes a `WorldHistory P.toTaskFrame` and compresses it. The
whole layer is a **model checker for one given finite graph**: it compresses histories *within* a
presentation. Producing the presentation in the first place, from an arbitrary countermodel, is a
different theorem that lives nowhere in this directory. Any account of the decidability of
`ValidDiscrete` that treats this layer as covering the finite-model half is mistaken about what
`exists_annot_of_truth` quantifies over.

### The single remaining obligation, in the shape that assembles

With this layer in hand, decidability of `ValidDiscrete φ` reduces to exactly one hypothesis:

> `fmp` : `∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃ w : Fin P.card, SatAtState P w ψ.neg`,
> for some computable `cands : Formula → List IntPresentation`.

Given `fmp`, `(∀ P ∈ cands φ, ∀ w, check P w φ.neg = false) ↔ ValidDiscrete φ` follows, and
`decidable_of_iff` reads a `Decidable (ValidDiscrete φ)` off it — the outer quantifier by
`List.decidableBAll`, the inner by `Fintype.decidableForallFintype`, the body by `decEq`. Both
halves have been compiled sorry-free and are retained under
`specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/`. Two things follow that
are worth recording, because both were assumed otherwise before being measured:

- **`check_correct` is the final step, not the far side of a transfer.** No bridge theorem, no
  transfer lemma, no enumeration over `Atom`, and no `Fin n`-from-`Finite` extraction appears
  anywhere in the assembly.
- **The converse direction is free.** A countermodel presented over ℤ refutes `ValidDiscrete`
  directly, because ℤ instantiates that definition's whole binder bundle with no instance work;
  the proof is five lines.

`fmp` itself is not routine — its crux is box-faithfulness, `box` truth being a global constant of
its own model (`Truth.box_const`), so the source model's and the target presentation's box facts
need not agree.

### `check` computes, but it is not choice-free

These are two different claims and they are easy to conflate. `instDecidableSatAtState` **reduces**
— the `#guard`s below are kernel-evaluated proof of it — and it carries no `Classical.dec` in the
data. Its measured axiom set is nonetheless `[propext, Classical.choice, Quot.sound]`, as is
`check_correct`'s: `Classical.choice` sits in the proofs *about* the data, never in the data, which
is exactly why computability survives it.

Nor can that be repaired. `wlem_of_saturation`
(`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`) derives weak excluded middle from
`Saturation R` at the finite carrier `Bool` over `D = ℤ`, from `[propext, Quot.sound]` alone. So
**no** finite-carrier frame with an arbitrarily shaped relation can be choice-free, on any route.
The cost is already paid by `IntPresentation.toTaskFrame` and is not a new one — but it does mean
no plan should promise a choice-free decidability result.

## Why `check` ranges over a position

`check` asks whether *some* position `i` of *some* enumerated annotated bi-lasso carries `φ` over
the state `w`, rather than asking about position `0` alone. That is forced, not stylistic.

A `BiLasso`'s origin is pinned: it decodes `back` repeated strictly left of `0`, `mid` on
`[0, |mid|)`, and `fwd` repeated at or past `|mid|`, with no left prefix. So the two-sided
pigeonhole that compresses a satisfying history puts the point of interest wherever the compressed
mid segment lands it. Anchoring at `0` would demand a recurrence of the *type* at the point of
interest, and
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase10-origin-anchoring-obstruction.lean`
exhibits a total history for which no such recurrence exists — machine-checked, sorry-free, and
retained as a permanent regression guard against re-anchoring this definition.

**Nothing is weakened.** `SatAtState` is existential in the time in either shape, because the
hypothesis the small-model theorem starts from is truth at an arbitrary time. Anchoring at `0` was
only ever a normalisation, and the pinned origin is exactly what makes that normalisation
unavailable.

Shifting the *history* does not rescue anchoring, even though
`Semantics.TimeShift.time_shift_preserves_truth` moves truth along a shift: the enumeration ranges
over lassos, not histories, and the shift of an annotation's history is not the decoding of any
enumerated lasso.

## Why the existential is not compositional, and why that is fine

`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase12-check-not-compositional.lean`
refutes a compositional reading of the `imp` case. It does not touch `check`, because the `∃ A`
and the `∃ i` sit **outside** any recursion on `φ`: `check` never decomposes `φ`; it enumerates
structures and reads a label. The recursion that does exist is `boxOracle`'s, and that one is on
`modalDepth`, not on the syntax tree of the formula being decided.

## Cost

No efficiency is claimed anywhere in this layer. `bound P φ` is
`max ((2k+1)·P.card·2^k) (2·P.card·2^k)` with `k = subformulaClosureCard φ`, and `boundedAnnots`
enumerates every triple of segment lists up to that length together with every labelling of them.
That is astronomically large for any interesting input; `checkAt` below exposes the bound so that
smoke tests can exercise the identical code path at a length that finishes. Correctness, not
speed, is the deliverable.

## Main Definitions

- `SatAtState` — the specification: `φ` holds at some time of some total history passing through
  `w`
- `checkAt` — the decision procedure at an explicit enumeration length
- `check` — `checkAt` at `bound P φ`

## Main Results

- `check_correct` — `check P w φ = true ↔ SatAtState P w φ`
- `instDecidableSatAtState` — the `Decidable` instance, with no `Classical.dec`
- `check_bot_false` / `check_top_true` — `check` discriminates

The final section carries `#guard`s witnessing that the procedure actually reduces, and records
the measured behaviour of `check` at its own bound.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {P : IntPresentation} {φ : Formula}

/-! ## The specification -/

/--
**The predicate `check` decides**: `φ` holds at some time of some total world history of the
presented frame, at which that history is in state `w`.

Stated as its own definition rather than left implicit in `check_correct`, so that a reader can
see exactly what is being claimed without reconstructing it from a biconditional.

Note the existential over the time. It is there in *either* shape of `check` — it is the
specification, not an artefact of the windowed enumeration.
-/
def SatAtState (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Prop :=
  ∃ (τ : WorldHistory P.toTaskFrame) (hτ : τ.IsTotal) (t : ℤ),
    τ.states t (hτ t) = w ∧ TruthAt P.toModel τ t φ

/-! ## The procedure -/

/--
The decision procedure at an explicit enumeration length.

`check` is this at `bound P φ`. The length is exposed because `bound P φ` is enormous even on
two-state presentations, and a smoke test that never finishes demonstrates nothing; `checkAt` at a
small length exercises exactly the same code path — the same enumeration, the same decidability
instances, the same box oracle — and finishes.
-/
def checkAt (P : IntPresentation) (w : Fin P.card) (φ : Formula) (n : ℕ) : Bool :=
  decide (∃ A ∈ boundedAnnots P φ (boxOracle P) n,
    ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A),
      A.lasso.unroll i = w ∧ φ ∈ A.label i)

/--
**The decision procedure.**

`bound` is read off `Extraction.lean` and the window bounds off `Decide.lean`; neither arithmetic
is restated here. See the module docstring for why the position is quantified.
-/
def check (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Bool :=
  decide (∃ A ∈ boundedAnnots P φ (boxOracle P) (bound P φ),
    ∃ i ∈ Finset.Ico (cohWindowLo A) (cohWindowHi A),
      A.lasso.unroll i = w ∧ φ ∈ A.label i)

/-- `check` is `checkAt` at the derived bound — definitionally. -/
theorem check_eq_checkAt (P : IntPresentation) (w : Fin P.card) (φ : Formula) :
    check P w φ = checkAt P w φ (bound P φ) := rfl

/-! ## Correctness -/

/--
**`check` decides `SatAtState`.**

- `←` is the small-model theorem `exists_annot_of_truth`, at the concrete oracle `boxOracle P`
  whose soundness is `boxOracle_sound`.
- `→` is the landed truth lemma `truth_along_annot_at` at the found position `i`, with
  `boundedAnnots_sound` supplying the `LocalCoherent` and `Fulfilling` hypotheses it needs and
  `Annot.hist_states` identifying the decoded history's state with the lasso's.
-/
theorem check_correct (P : IntPresentation) (w : Fin P.card) (φ : Formula) :
    check P w φ = true ↔ SatAtState P w φ := by
  rw [check, decide_eq_true_iff]
  constructor
  · rintro ⟨A, hA, i, -, hst, hlab⟩
    obtain ⟨hloc, hful, -, -, -⟩ := boundedAnnots_sound hA
    refine ⟨A.hist, A.hist_isTotal, i, ?_, ?_⟩
    · rw [A.hist_states i (A.hist_isTotal i)]
      exact hst
    · exact (truth_along_annot_at (boxOracle_sound P) A hloc hful i φ
        (self_mem_subformulaClosure φ)).mpr hlab
  · rintro ⟨τ, hτ, t, hst, htr⟩
    obtain ⟨A, hA, i, hi, hunroll, hlab⟩ :=
      exists_annot_of_truth (boxOracle_sound P) τ hτ t htr
    exact ⟨A, hA, i, hi, by rw [hunroll, hst], hlab⟩

/--
**The `Decidable` instance.**

Routed through `check_correct`, so the instance *computes*: no `Classical.dec` anywhere on the
path, and no `open Classical` under `BiLasso/`.
-/
instance instDecidableSatAtState (P : IntPresentation) (w : Fin P.card) (φ : Formula) :
    Decidable (SatAtState P w φ) :=
  decidable_of_iff (check P w φ = true) (check_correct P w φ)

/-! ## `check` discriminates

A decision procedure that answered `true` unconditionally would satisfy every theorem above whose
statement is an implication into `SatAtState`, so the two facts below are load-bearing rather than
decorative: `check` returns `false` on an unsatisfiable input and `true` on a satisfiable one.

They are stated as **theorems**, discharged through `check_correct`, rather than as `#eval`
comparisons. That is deliberate and is stronger: `bound P φ` is large enough that an `#eval` of
`check` itself does not finish in practice on any non-degenerate presentation (see the module
docstring on cost), whereas a proof of the same two facts is exact and free. Computability is
witnessed separately, by `check` elaborating without the `noncomputable` keyword and by the
`#guard`s of `checkAt` in the worked section below. -/

/-- **`check` is not constantly `true`**: `⊥` is satisfied nowhere, and `check` says so. -/
theorem check_bot_false (P : IntPresentation) (w : Fin P.card) :
    check P w Formula.bot = false := by
  rcases Bool.eq_false_or_eq_true (check P w Formula.bot) with h | h
  · obtain ⟨τ, hτ, t, -, htr⟩ := (check_correct P w Formula.bot).mp h
    exact absurd htr Truth.bot_false
  · exact h

/-- **`check` is not constantly `false`**: `⊤` holds along the alternating path of
`flipPresentation`, whose origin is state `0`, and `check` says so. -/
theorem check_top_true :
    check flipPresentation 0 (Formula.imp Formula.bot Formula.bot) = true := by
  refine (check_correct _ _ _).mpr ⟨flipBiLasso.toHF.val, flipBiLasso.toHF.property, 0, ?_, ?_⟩
  · show flipBiLasso.unroll 0 = 0
    decide
  · rw [Truth.imp_iff]
    exact fun h => h

/-! ## Worked evaluations: the procedure runs

The theorems above are exact but they are *proofs*, and a proof would still go through if some
`noncomputable` dependency had leaked in from the extraction and left `check` unable to reduce.
The `#guard`s below close that gap: they are discharged by kernel evaluation of `checkAt`, so
they fail the build unless the whole path — the bounded enumeration, the `LocalCoherent` and
`Fulfilling` decidability instances, the window `Finset.Ico`, and `boxOracle`'s stratified
recursion — actually computes.

`loopPresentation` is the one-state total loop, so its bi-lassos are the constant paths and the
only freedom is the window length. Three formulas are evaluated rather than two, because two
would not distinguish the two ways of being `false`:

| formula   | result  | why                                                          |
|-----------|---------|--------------------------------------------------------------|
| `⊥`       | `false` | unsatisfiable outright                                        |
| `atom pA` | `true`  | `loopPresentation.val` holds `pA` at its only state           |
| `atom qA` | `false` | `qA` is a *different* atom, false at every state              |

The `atom qA` row is the load-bearing one. A `check` that special-cased `⊥` — or that returned
`false` whenever the enumeration came up empty for an uninteresting reason — would still pass the
first two rows. The third fails unless the label is genuinely read.

### On evaluating `check` itself

These use `checkAt` at `n = 1`, not `check`, and the reason is measured rather than assumed.
`check` *does* reduce at its real bound: on `loopPresentation`, where `bound` is `6`,
`#eval check loopPresentation 0 Formula.bot` returns `false` and
`#eval check loopPresentation 0 (Formula.atom pA)` returns `true`. Both were run and both
terminated — so no `noncomputable` dependency has leaked in, which is the fact the plan's
`#eval` gate exists to establish.

They are not *retained* as `#eval`s here because each takes roughly two minutes, and leaving them
in would add about four minutes to every compile of this module for evidence the `#guard`s and
`check_bot_false` already carry. `check_bot_false` is in fact strictly stronger than the negative
`#eval`: it is proved for *every* presentation and *every* state, not just this one. -/

section SmokeTests

open BiLassoExamples

#guard !checkAt loopPresentation 0 Formula.bot 1
#guard checkAt loopPresentation 0 (Formula.atom pA) 1
#guard !checkAt loopPresentation 0 (Formula.atom qA) 1

end SmokeTests

end FormalSystem.Metalogic.Decidability
