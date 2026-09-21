/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic
import FormalSystem.Semantics
import FormalSystem.Automation

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

* [MainResults.lean](../MainResults.lean) - the headline soundness/completeness metatheory
* [BimodalProofs.lean](BimodalProofs.lean) - perpetuity-principle proof examples
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

end FormalSystem.Examples.Walkthrough
