/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Step
import FormalSystem.Semantics.PartialHistoryOrder
import FormalSystem.Semantics.PartialHistory

/-!
# `thm:extension` and `cor:occurrence` — closing the extension chain

This module closes the chain the preceding extension modules build: every partial history is
extended by some **possible world**, and every world state occurs at any prescribed time in
some possible world.

The chain, in order, is

`def:constraints` → `lem:constraint` → `lem:fibers` (RETIRED anchor; see below) → `lem:admissible`
→ `lem:step` (the sole
*Saturation* application site) → `thm:extension` (Zorn) → `cor:occurrence`.

## Paper Specification Reference

Anchors are `\label` keys into `docs/reference/paper-definitions-of-record.md`, which — not the paper
source — is the citation source of record.

- `thm:extension` (verbatim): "Every partial history $\tau : X \to W$ over a task frame
  $\F = \tuple{W, \D, \Rightarrow}$ is extended by some possible world $\sigma \in H_{\F}$."
  Its footnote (verbatim): "The proof appeals to Zorn's lemma, and so the derivation of
  \textit{Occurrence} from \textit{Seriality} and \textit{Saturation} in
  \textbf{\ref{cor:occurrence}} is a theorem of ZFC, in contrast with the derivation of the zero
  loops in \textbf{\ref{lem:nullity}} and the derivation of \textit{Saturation} for finite $W$ in
  \textbf{\ref{cor:saturation-finite}}, both of which are choice-free."
  The footnote **no longer says "and hence to the axiom of choice"**; the paper restructured it to
  say the derivation is a theorem of ZFC, and widened the choice-free contrast class to include
  `cor:saturation-finite`. The earlier wording must not be reintroduced.
- `cor:occurrence` (verbatim): "For any task frame $\F = \tuple{W, \D, \Rightarrow}$, world state
  $w \in W$, and time $x \in D$, there is a possible world $\tau \in H_{\F}$ where
  $\tau(x) = w$, and so $H_{\F} \neq \emptyset$."

## What `thm:extension` consumes — Zorn plus `lem:step`, and nothing else

`extension` below is proved from exactly two inputs:

1. `PartialHistory.exists_maximal_extension` (the extension order's Zorn instance), and
2. `PartialHistory.step` (`lem:step`).

*Saturation* is **not** threaded into `extension`'s proof directly: it reaches `step` — which
remains its sole application site — as the projection `F.saturation` off the frame, taken by `step`
itself. Nothing in this module applies *Saturation*, *Seriality*, *Interpolation*, or *Limit* to
anything; all four are `FrameOver` fields rather than hypothesis binders, so what this module
passes along is the frame `F`, never the axioms.

The maximal-to-total direction is isolated as `isTotal_of_isMax`, the converse companion to
`PartialHistoryOrder`'s `isMax_of_total`. That companion is exactly where `lem:step` is spent:
maximality plus the ability to extend by one arbitrary duration forces the domain to be all of
`D`. A total partial history *is* a world history, so the maximal partial history is an `F.HF`
element as it stands: the subtype pair `⟨μ, htot⟩`, with no promotion step and no convexity
argument.

## What the finite-carrier *Saturation* discharge costs, by contrast

`TaskFrame.saturation_of_finite` (`cor:saturation-finite`) is the only discharge route for an
**arbitrary** relation on a finite carrier; the other helpers — `saturation_of_subsingleton`,
`saturation_of_permissive`, `saturation_of_eq` — each constrain the relation's shape instead. Its
cost profile is the mirror image of `extension`'s. It costs **no Zorn**: it does not route through
`PartialHistory.exists_maximal_extension`, which is exactly what `thm:extension` above spends. It
does unavoidably cost `Classical.choice`.

"Unavoidably" is a proved obstruction rather than a guess: weak excluded middle is derivable from
*Saturation* at the finite carrier `Bool` over `D = Int`, so a `Classical.choice`-free proof of that
route would prove WLEM in Lean's intuitionistic core, where it is not derivable. That derivation is
on the record as `wlem_of_saturation` in
`Tests/BimodalTest/Semantics/SaturationFiniteAxiomTest.lean`.

## `cor:occurrence` is landed in **frame-intrinsic** form

`occurrence` below quantifies over a frame alone, with no axiom hypotheses — which is what the
paper's own statement literally reads as. It once carried the axioms as explicit hypotheses,
gated on the frame-axiom-field refactor recorded in `Step.lean`; that refactor has landed.
`FrameOver` carries *Compositionality* (biconditional), *Seriality*, *Limit*, and *Saturation* as
structure data, each stated by citation of the bare-relation predicate rather than restated, so
threading them through this chain is now a projection rather than a hypothesis — with zero
restatement, exactly as the hypothesis-form discipline was designed to guarantee.

The one argument the paper's ambient convention supplies silently is the world state, and the
structure now carries it too: `FrameOver.worldNonempty` is a `Nonempty WorldState` field. `hF_nonempty`
nonetheless continues to take `w` explicitly — **by choice, not by necessity** — so that a caller
already holding a state passes it rather than discarding it, while a caller holding none passes
`F.worldNonempty.some`.

## The one-point partial history, and what is *not* in this chain

`cor:occurrence`'s proof extends the one-point partial history `{⟨x, w⟩}` directly via
`thm:extension`. That one-point history is `PartialHistory.point` below; its `respects_task`
obligation reduces to `TaskRel w 0 w`, discharged by the derived `FrameOver.nullity_identity`.

The paper's **former** translation argument — which derived occurrence at an arbitrary time by
time-shifting a history witnessed at one time — is **gone from this chain and must not be
reintroduced**. The anchors that carried it (`thm:occurrence`, `app:nonempty`) no longer exist;
the paper merged them into the single, strictly stronger `cor:occurrence`, in which the time `x`
is universally given rather than existentially witnessed. Time-shift machinery survives
separately (`PartialHistory.timeShift`, `TaskFrame.HF.timeShift`) but
plays no role here.

## Main Definitions

- `PartialHistory.point` — the one-point partial history `{⟨x, w⟩}`

## Main Results

- `PartialHistory.isTotal_of_isMax` — maximal implies total (the converse of `isMax_of_total`)
- `PartialHistory.extension` — `thm:extension`
- `PartialHistory.occurrence` — `cor:occurrence`, frame-intrinsic form
-/

namespace FormalSystem.Semantics

namespace PartialHistory

open TaskFrame

/-! ## Maximal implies total — where `lem:step` is spent -/

/--
A **maximal** partial history is total: the converse companion to
`PartialHistoryOrder`'s `isMax_of_total`.

This direction is *not* provable from the extension order alone — it is exactly where `lem:step`
is spent. If some time `z` were missing from a maximal `τ`'s domain, `step` would produce a `σ`
extending `τ` with `z` in its domain; maximality then forces `τ` to extend `σ` in turn, putting
`z` back in `τ`'s domain — a contradiction.

The four axioms are **`FrameOver` fields that `step` projects off `F` for itself**, not hypotheses
this theorem takes and forwards. Nothing here applies any of them; in particular this is not a
second *Saturation* application site.
-/
theorem isTotal_of_isMax (F : TaskFrame) {τ : PartialHistory F} (hmax : IsMax τ) :
    τ.IsTotal := by
  intro z
  obtain ⟨σ, hext, hσz⟩ := step F τ z
  -- `hext : Extends σ τ` is `τ ≤ σ`; maximality turns it around into `σ ≤ τ`.
  exact (le_def.mp (hmax (le_def.mpr hext))).subset z hσz

/-! ## `thm:extension` -/

/--
`thm:extension`: every partial history is extended by some possible world.

Recorded source (`thm:extension`, verbatim): "Every partial history $\tau : X \to W$ over a task
frame $\F = \tuple{W, \D, \Rightarrow}$ is extended by some possible world
$\sigma \in H_{\F}$."

Recorded footnote of the source (verbatim): "The proof appeals to Zorn's lemma, and so the
derivation of \textit{Occurrence} from \textit{Seriality} and \textit{Saturation} in
\textbf{\ref{cor:occurrence}} is a theorem of ZFC, in contrast with the derivation of the zero
loops in \textbf{\ref{lem:nullity}} and the derivation of \textit{Saturation} for finite $W$ in
\textbf{\ref{cor:saturation-finite}}, both of which are choice-free."

**Proof recipe, exactly as recorded**: Zorn's lemma over the extension order
(`exists_maximal_extension`) produces a maximal extension; `lem:step` forces that maximal partial
history to be total (`isTotal_of_isMax`); a total partial history is a world history, so totality
is exactly its `H_F` membership. (The appendix's route through convex histories needs no step
here: a total domain is trivially convex, `PartialHistory.IsTotal.isConvex`.)

**These two are the whole proof.** *Saturation* is not threaded in directly — `step`, which remains
its sole application site, reads it off the frame as `F.saturation`.
-/
theorem extension (F : TaskFrame) (τ : PartialHistory F) :
    ∃ σ : F.HF, Extends σ.val τ := by
  obtain ⟨μ, hle, hmax⟩ := exists_maximal_extension τ
  have htot : μ.IsTotal := isTotal_of_isMax F hmax
  exact ⟨⟨μ, htot⟩, le_def.mp hle⟩

/-! ## `cor:occurrence`, frame-intrinsic form -/

/--
The **one-point** partial history `{⟨x, w⟩}`: the state `w` at the single time `x`.

Its `respects_task` obligation is only ever the zero-duration instance `TaskRel w 0 w`, since both
times in any instance are `x`; that is discharged by `FrameOver.nullity_identity`.

This is the history `cor:occurrence` extends via `thm:extension`. The paper's former translation
argument, which reached an arbitrary time by time-shifting, is not used and must not be
reintroduced — see this module's docstring.
-/
def point (F : TaskFrame) (w : F.WorldState) (x : F.Duration) : PartialHistory F where
  domain := fun t => t = x
  nonempty_domain := ⟨x, rfl⟩
  states := fun _ _ => w
  respects_task := by
    intro s t hs ht
    subst hs
    subst ht
    simpa [sub_self] using (F.nullity_identity w w).mpr rfl

@[simp]
theorem point_states (F : TaskFrame) (w : F.WorldState) (x : F.Duration) (t : F.Duration)
    (ht : (point F w x).domain t) : (point F w x).states t ht = w := rfl

/--
`cor:occurrence`, in **frame-intrinsic form**: every world state occurs at any prescribed time in some
possible world.

Recorded source (`cor:occurrence`, verbatim): "For any task frame
$\F = \tuple{W, \D, \Rightarrow}$, world state $w \in W$, and time $x \in D$, there is a possible
world $\tau \in H_{\F}$ where $\tau(x) = w$, and so $H_{\F} \neq \emptyset$."

**Proof recipe, exactly as recorded**: extend the one-point partial history `{⟨x, w⟩}` directly
via `thm:extension`. The extension agrees with the one-point history at `x`, which is the claim.

**Frame-intrinsic.** The statement quantifies over a frame with no axiom hypotheses, which is
how the recorded source literally reads; the axioms reach `step` as the frame's own fields. See
this module's docstring.
-/
theorem occurrence (F : TaskFrame) (w : F.WorldState) (x : F.Duration) :
    ∃ τ : F.HF, τ.val.states x (τ.property x) = w := by
  obtain ⟨τ, hext⟩ := extension F (point F w x)
  exact ⟨τ, hext.agree x rfl⟩

/--
`cor:occurrence`'s closing clause: `H_F` is nonempty.

Recorded source (`cor:occurrence`, verbatim, closing clause): "…and so
$H_{\F} \neq \emptyset$." This needs a world state to start from. The paper's ambient convention
supplies one silently, and the frame now supplies one too — `FrameOver.worldNonempty` is a field — so
the explicit argument `w` is retained here **by choice, not by necessity**: a caller already
holding a state passes it, and a caller holding none passes `F.worldNonempty.some`.
`Semantics/Validity.lean`'s `hF_nonempty_of_frameAxioms` is the second case, and reads literally
`PartialHistory.hF_nonempty F F.worldNonempty.some`.
-/
theorem hF_nonempty (F : TaskFrame) (w : F.WorldState) : Nonempty F.HF :=
  let ⟨τ, _⟩ := occurrence F w 0
  ⟨τ⟩

end PartialHistory

end FormalSystem.Semantics
