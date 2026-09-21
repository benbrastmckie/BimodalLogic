/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic
import FormalSystem.Semantics
-- Specific Automation modules rather than the aggregator -- see the note in
-- `Examples/BimodalProofs.lean`. This file runs `modal_search`, `modal_t` and the native
-- `search` entry point.
import FormalSystem.Automation.Tactics.UserTactics
import FormalSystem.Automation.Tactics.Commands
import FormalSystem.Automation.ProofSearch.Core
import FormalSystem.Automation.ProofSearch.Strategies

/-!
# A Worked Walkthrough of TM

TM is the bimodal logic of tense and modality: it adds the S5 necessity operator `□` to the
linear tense operators of Prior's logic, and evaluates formulas at a *history* (a way the world
might run) together with a *time* along it. This file is one page for a reader who knows modal
logic but has never opened this repository, and who wants to see the machinery run rather than
read about it.

Everything here is stated at two concrete formulas, and every declaration is named, so the
kernel's own `#print axioms` audit can address it. The audits themselves live beside the test
suite, in `Tests/BimodalTest/WalkthroughAxioms.lean`, where they are *asserted* rather than
merely printed: a drift in any declaration's axiom set fails the build.

## How to read this page

Six legs, in order:

1. **A derivation, by hand and by machine.** A `DerivationTree` built constructor by
   constructor, and the same theorem found by the proof-search tactic.
2. **Soundness, outward.** The tree becomes semantic validity.
3. **Completeness, back.** Validity becomes derivability again — though not, as it turns out,
   the same tree.
4. **The decision procedure.** A tableau computes a verdict on the same formula, and a soundness
   bridge turns that verdict into the same validity leg 2 reached by a different road.
5. **Frame-class sensitivity.** One formula derivable over dense time and refuted over integer
   time, with a countermodel concrete enough to picture.
6. **A negative result.** Strong completeness *fails* at integer time — a theorem, not a gap.

## The axiom contract

Every declaration below is sorry-free and rests on nothing beyond Lean's own classical
foundation. The companion test file pins each one's axiom set exactly, so this page cannot
silently acquire a new dependency.

## References

* `FormalSystem/MainResults.lean` — the headline soundness/completeness metatheory
* `FormalSystem/Examples/BimodalProofs.lean` — perpetuity-principle proof examples
-/

namespace FormalSystem.Examples.Walkthrough

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic
open FormalSystem.Metalogic.Decidability
open FormalSystem.Automation

/-!
## Two formulas

The whole walkthrough runs on a single propositional atom, written `p`.
-/

/-- The atom the walkthrough is stated at, written `p` throughout the prose. -/
def pAtom : Atom := Atom.mkBase "p"

/-- The atomic formula `p`. -/
def pF : Formula := Formula.atom pAtom

/-- The modal-T instance `□p → p`: whatever is necessary is the case. -/
def tFml : Formula := pF.box.imp pF

/-!
## 1. A derivation, by hand and by machine

The first thing to know about this library is that a derivation is a *tree*, not a truth value.
The notation `⊢ φ` abbreviates `DerivationTree FrameClass.Base [] φ` — a derivation of `φ` from
the empty context over the weakest frame class — and it lives in `Type`, not `Prop`. That is why
the declarations in this section are `def`s rather than `theorem`s: each one *is* a tree, and
Lean will happily show you its constructors. The `Prop`-valued shadow, for when only the
existence of a tree matters, is `Derivable fc Γ φ`, which is by definition
`Nonempty (DerivationTree fc Γ φ)`. Keeping those two apart is the single most useful
orientation for reading the rest of this page.

`DerivationTree` has seven constructors. The one used here is `axiom`, which takes a context, a
formula, an axiom instance, and — the interesting argument — a proof that the axiom is *licensed
by the frame class at hand*: `h_fc : h.minFrameClass ≤ fc`. Every axiom schema records the
weakest frame class over which it is valid, and the constructor will not fire without a proof
that the ambient class is at least that strong. Modal T is valid everywhere, so its
`minFrameClass` is the bottom class and the side condition is settled by `decide`. Leg 5 below
turns on an axiom for which it is not.
-/

/-- `□p → p`, derived by hand: a single application of the modal-T axiom schema. -/
def tByHand : ⊢ tFml := DerivationTree.axiom [] _ (Axiom.modal_t pF) (by decide)

/--
`□(□p → p)`, a two-node tree: necessitation applied to the modal-T leaf.

This is here so the reader sees a derivation with structure rather than a single leaf. The
`necessitation` constructor takes a derivation of `φ` from the *empty* context and returns a
derivation of `□φ` — the empty-context restriction is what keeps the rule from proving
`φ → □φ`.
-/
def boxedT : ⊢ tFml.box := DerivationTree.necessitation _ tByHand

/--
`□p → p` again, this time found by the proof-search automation rather than written out.

`modal_search` searches the constructor space for a tree; the result is an ordinary
`DerivationTree` term, indistinguishable in kind from `tByHand` above. Automation here
*produces* proofs, it does not stand in for them.
-/
def tByAuto : ⊢ tFml := by modal_search

/-!
## 2. Soundness, outward

Soundness is the direction that turns syntax into semantics. `soundness_validIn` takes a
derivation tree from the empty context over a frame class and returns validity over that same
class — `ValidIn fc φ`, meaning `φ` is true at every time of every history of every model
whose frame satisfies the class. At the bottom class this is written `⊨ φ`.

Nothing about the tree matters to the statement except that it exists and reaches `tFml`; the
proof works by recursion over the constructors, showing each one preserves truth. The
frame-class gate on the `axiom` constructor is exactly what makes that recursion go through:
an axiom can only appear in a tree over a class where it is semantically valid.
-/

/-- Soundness carries the hand-built tree out to semantic validity: `⊨ □p → p`. -/
theorem tValid : ⊨ tFml := soundness_validIn tByHand

/-!
## 3. Completeness, back

Completeness runs the other way. `completeness_base` witnesses
`WeakCompleteness FrameClass.Base`, which unfolds to
`∀ ψ, ValidIn FrameClass.Base ψ → Derivable FrameClass.Base [] ψ`: every validity is derivable.
Applied to the validity just obtained, it returns the formula to the proof system.

Notice what the round trip does *not* do. Soundness consumed a `DerivationTree` — a piece of
data. Completeness returns a `Derivable`, which is `Nonempty (DerivationTree …)` — the bare
assertion that some tree exists, with no tree inside it to inspect. Going out and coming back
therefore loses the derivation. This is not an oversight in how the statement was phrased: the
completeness proof builds its derivation by a non-constructive canonical-model argument, and
`Nonempty` is an honest record of what that argument delivers. A reader wanting a tree for a
valid formula should reach for the decision procedure in the next section, which does return
one.
-/

/-- Completeness carries the validity back to derivability — though not back to a tree. -/
theorem tDerivable : Derivable FrameClass.Base [] tFml := completeness_base tFml tValid

/-!
The class-generic `soundness_validIn` used above is the empty-context form. The library also
exposes a configuration-level `soundness`, which takes a frame, a model, a history and a time
and hands back the truth of the formula *at that point*, for a reader who wants to watch truth
evaluated somewhere concrete rather than quantified away; see `Metalogic/Soundness.lean`.
-/

/-!
## 4. The decision procedure

TM is decidable, and the library ships the procedure that decides it: a tableau search wrapped
in `isValid φ fc : Bool`, which is by definition `(decide φ (fc := fc)).isValid`. The underlying
`decide` returns a `DecisionResult`, a four-way verdict whose `valid` constructor *carries an
actual `⊢ φ` derivation tree* — which is why the previous section could point here for the tree
that completeness does not hand back.

The statement below is settled by `decide`, and that is the whole point: there is no tactic
cleverness in the proof term, only the kernel running the tableau on this formula and observing
that it comes back `true`. The computation is the proof.
-/

-- Do not replace `by decide` here with `native_decide`. `native_decide` delegates the
-- computation to compiled code and injects `Lean.ofReduceBool` into the axiom set, which would
-- break the axiom contract this file is audited against. If a formula is ever too large for
-- `by decide`, shrink the formula.
/-- The tableau procedure returns a valid verdict on `□p → p`, by kernel computation. -/
theorem tIsValid : isValid tFml = true := by decide

/--
The verdict, converted into semantic validity by the procedure's soundness bridge.

`isValid_sound` is the thin entry point over `sound_of_isValid`, which is where the work
happens: it case-splits the `DecisionResult` and, in the `valid` case, feeds the carried
derivation tree to soundness.
-/
theorem tValidViaTableau : ⊨ tFml := isValid_sound tFml FrameClass.Base tIsValid

/-!
`tValidViaTableau` and `tValid` are the same statement reached by two unrelated roads: one by a
derivation written out by hand, one by a search the kernel ran. That they agree is reassuring
but not accidental — soundness is what licenses both.

One direction only, though. `isValid φ = true` implies validity; `isValid φ = false` does **not**
in general imply that `φ` is invalid. A `false` can also mean the search ran out of fuel or
failed to extract a proof from a closed tableau, and the correctness file states the sound
direction alone for exactly that reason. Read a `true` as a theorem and a `false` as *no verdict
yet*.
-/

/-!
## 5. Frame-class sensitivity

Everything so far happened over `FrameClass.Base`, the weakest class, where time is constrained
only by what the task semantics itself demands. TM is really a family of logics indexed by how
much structure time is assumed to have, and the interesting phenomena live in the gaps between
those classes. This section exhibits one formula that separates them.

The formula is the density instance `GGp → Gp`: *if `p` holds at every time after every time
after now, then `p` holds at every time after now*. Over densely ordered time this is valid —
between now and any later point there is always an intermediate point, so any future time can
be reached in two steps. Over discretely ordered time it is not: the instant immediately after
now has no such intermediate, and the antecedent simply skips it.
-/

/-- The density instance `GGp → Gp`. -/
def ggFml : Formula := pF.allFuture.allFuture.imp pF.allFuture

/--
`GGp → Gp`, derived over the class of dense frames.

The side condition is `le_refl _` rather than `decide`: `Axiom.density`'s minimum frame class
*is* `Dense`, so the gate is discharged by reflexivity of the frame-class order.
-/
def ggAtDense : DerivationTree FrameClass.Dense [] ggFml :=
  DerivationTree.axiom [] _ (Axiom.density pF) (le_refl _)

/-!
This is where the frame-class gate on the `axiom` constructor earns its keep. `Axiom.density`
records `Dense` as its minimum class, so `ggAtDense` type-checks at `Dense` and the very same
constructor call is *not type-correct* at `Base` or at `ZTime` — there is no proof of
`Dense ≤ Base` to supply, because there is none to be had. Frame-class sensitivity in this
library is a typing phenomenon, not a convention the proofs agree to respect.

That the axiom is unavailable at `Base` does not by itself show the formula is underivable
there; some other derivation might reach it. Ruling that out is semantics' job, and the
standard move is to exhibit a model.

### One countermodel, two conclusions

Take time to be the integers, and let `p` be true everywhere except at the single instant `1` —
a blip. Standing at `0`, is `GGp` true? Take any time `s` after `0` and any time `r` after `s`;
since both steps are strictly forward over the integers, `r` is at least `2`, so `r` is not the
blip and `p` holds there. So `GGp` holds at `0`. Is `Gp` true at `0`? No: `1` is after `0` and
`p` fails there. The implication is false at `0`, so `GGp → Gp` is not valid on this frame.

The frame carrying this is `permissiveFrame` over `ℤ` — the frame that imposes no constraint
beyond the ambient temporal order, so that any assignment of truth values along a history is
realized. That matters twice over: because it is unconstrained it is a `Base` frame, and because
its order is the integers it is also an integer-time frame. One countermodel therefore refutes
the formula at both classes.
-/

/-- The integers, viewed as a temporal order. -/
abbrev Dz : TemporalOrder := TemporalOrder.of ℤ

/-- The integer carrier has a successor structure. -/
noncomputable instance instSuccDz : SuccOrder Dz.carrier := inferInstanceAs (SuccOrder ℤ)

/-- The integer carrier has no last moment. -/
instance instNoMaxDz : NoMaxOrder Dz.carrier := inferInstanceAs (NoMaxOrder ℤ)

/-- The blip assignment: `p` is true at every integer instant except `1`. -/
noncomputable def blipF : Dz.carrier → Bool := fun t => decide (t ≠ (1 : ℤ))

/--
The permissive frame over the integers, on which the blip assignment is realized.

An `abbrev` rather than a `def` so that `TaskFrame.isZTime_of_instances` can see through it to
the underlying instances.
-/
noncomputable abbrev blipFrame : TaskFrame :=
  (permissiveFrame Dz instSuccDz instNoMaxDz).toTaskFrame

/--
Two strictly forward steps from `0` land past `1`.

Stated over plain `ℤ` on purpose, and applied to the carrier-typed goal by `exact`: `omega`
silently ignores `<`/`≤` hypotheses whose type is `Dz.carrier` rather than `ℤ`, even under a
type ascription, and then reports the goal as unprovable. Isolating the arithmetic here and
letting definitional equality transport it across is what makes the step go through.
-/
theorem gapStep (s r : ℤ) (hs : 0 < s) (hr : s < r) : r ≠ 1 := by omega

/-- The blip frame is an integer-time frame. -/
theorem blipFrame_isZTime : blipFrame.IsZTime := TaskFrame.isZTime_of_instances _

/-- The blip frame refutes `GGp → Gp`: the antecedent holds at `0` and the consequent fails. -/
theorem blipRefutes : ¬ blipFrame.ValidOn ggFml := by
  intro h
  -- `GGp` holds at `0`: two strictly forward steps overshoot the blip.
  have hgg : TruthAt (permissiveModel Dz instSuccDz instNoMaxDz)
      (permissiveHist Dz instSuccDz instNoMaxDz blipF) ((0 : ℤ) : Dz.carrier)
      pF.allFuture.allFuture := by
    rw [Truth.future_iff]
    intro s hs
    rw [Truth.future_iff]
    intro r hr
    refine (permissive_realizes Dz instSuccDz instNoMaxDz blipF pAtom r).mpr ?_
    simp only [blipF, decide_eq_true_eq]
    exact gapStep s r hs hr
  -- So the assumed validity forces `Gp` at `0` -- but `p` fails at the blip, one step on.
  have hg := h (permissiveModel Dz instSuccDz instNoMaxDz)
      (permissiveHist Dz instSuccDz instNoMaxDz blipF) ((0 : ℤ) : Dz.carrier) hgg
  rw [Truth.future_iff] at hg
  have hbad := (permissive_realizes Dz instSuccDz instNoMaxDz blipF pAtom ((1 : ℤ) : Dz.carrier)).mp
    (hg ((1 : ℤ) : Dz.carrier) (by norm_num))
  simp only [blipF, decide_eq_true_eq] at hbad
  exact hbad rfl

/-- `GGp → Gp` is not valid over the base class: the blip frame is a base frame. -/
theorem notValidGg : ¬ Valid ggFml := fun h => blipRefutes (h _ trivial)

/-- `GGp → Gp` is not valid over integer time either: the blip frame is an integer-time frame. -/
theorem notValidZTimeGg : ¬ ValidZTime ggFml := fun h => blipRefutes (h _ blipFrame_isZTime)

/-!
Note how little separates those two. `notValidGg` discharges the base-class membership
condition with `trivial`, because the base class constrains nothing; `notValidZTimeGg`
discharges the integer-time condition with `blipFrame_isZTime`. Same frame, same refutation,
two different certificates that it belongs to the class in question.

Now soundness runs backwards. If the formula were derivable over a class it would be valid over
that class; it is not valid, so it is not derivable. This is the standard use of soundness —
not to certify theorems, but to refute would-be ones — and it is why an underivability claim in
this library is always cashed out as a model.
-/

/-- Hence `GGp → Gp` is not derivable over the base class. -/
theorem ggNotBase : ¬ Derivable FrameClass.Base [] ggFml :=
  fun ⟨d⟩ => notValidGg (soundness_validIn d)

/-- Hence `GGp → Gp` is not derivable over integer time either. -/
theorem ggNotZTime : ¬ Derivable FrameClass.ZTime [] ggFml :=
  fun ⟨d⟩ => notValidZTimeGg (soundness_validIn d)

/-!
## 6. A negative result: strong completeness fails over integer time

Leg 3 obtained *weak* completeness: every valid formula is derivable from no assumptions. The
strong form asks for more — that every semantic consequence of a possibly infinite set of
assumptions be derivable from it — and over integer time it is false. Not open, not unproven:
refuted, and the refutation is a theorem of this library.
-/

/--
Strong completeness fails over integer time.

A result in its own right, not a gap in the development.
-/
theorem zTimeStrongCompletenessFails : ¬ StrongCompletenessZTime := notStrongCompletenessZTime

/-!
The witness is a family saying "`p` happens at some point in the future, but not after one
step, nor after two, nor after three, …" — a single `F`-claim together with the negation of
every finite iteration of the next-step operator. Over the integers any
*finite* part of that family is satisfiable: only finitely many instants are ruled out, and
there is always a later one left over to host `p`. The family as a whole is not, because integer
time is Archimedean-discrete and every future instant is reached in finitely many steps. So
compactness fails over this class, and strong completeness falls with it — a derivation is a
finite object and can only ever consult finitely many of its assumptions.

Worth being precise about the scope of the failure. Weak completeness still holds over integer
time; it is the infinite-context form that does not. The gap between the two is exactly the
gap between finite and infinite assumption sets, which is what compactness measures.

## Where to go next

- `FormalSystem/MainResults.lean` collects the headline metatheory — soundness,
  the weak completeness results at each frame class, and the strong-completeness results and
  refutations — each with its own axiom audit.
- `FormalSystem/Examples/BimodalProofs.lean` works the proof system harder, deriving the
  perpetuity principles that link `□` to the tense operators.
- `FormalSystem/Examples/TemporalStructures.lean` builds more of the concrete temporal
  orders that the countermodel in leg 5 drew on.
-/

end FormalSystem.Examples.Walkthrough
