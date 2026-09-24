/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Admissible

/-!
# `lem:step`: the Step Lemma — the sole *Saturation* elimination site

This module lands the Step Lemma: every partial history extends by one arbitrary duration. It is
the join point of the whole extension chain, and it is **the only place in the development where
the *Saturation* axiom is eliminated** — the only place it is spent on a conclusion that does not
itself mention it. The five other sites that apply `F.saturation` take it in and give it back
out; they are enumerated below.

The proof is a composition, not a re-derivation. Each of its three inputs is already proved:

- `lem:constraint` (`PartialHistory.constraint`, `Extension.Constraint`) supplies the two
  hypotheses *Saturation* demands of a family: the constraints imposed on `z` form a **directed**
  family, and every member is **nonempty**. Membership in the fiber-or-segment classes is
  `PartialHistory.isFiber_or_isSegment_of_mem_Constraints`.
- *Saturation* (`TaskFrame.Saturation`, `FrameAxioms`) turns that family into a common member
  `u ∈ ⋂₀ Constraints τ z`.
- `lem:admissible` (`PartialHistory.admissible`, `Extension.Admissible`) turns "belongs to every
  constraint" into the task-respect condition on the one-point extension, which
  `PartialHistory.adjoin` then realizes as an actual `PartialHistory` extending `τ` with `z` in
  its domain.

## The sole *Saturation* **elimination** site

`step` is the sole site in the development where *Saturation* is **eliminated into a
non-*Saturation* conclusion**. `lem:constraint` does not consume it (it is what *supplies* this
site its directed-family-of-nonempty-sets hypothesis), and `lem:admissible` does not consume it
either.

**This is not the claim that `F.saturation` occurs once.** An earlier version of this docstring
predicted that a `grep` for `Saturation` across `FormalSystem/` would turn up a single consuming
proof; that prediction is false as measured. `F.saturation` is *applied* at six sites in proof
bodies, and the five that are not `step` each take
*Saturation* in and give *Saturation* back out — they are transports and restatements, not
eliminations:

- `FormalSystem/OpenLanguage/OpenReversal.lean` (`FrameOver.rev_isRegular`) — *Saturation* of a
  frame's reversal, from *Saturation* of the frame;
- `FormalSystem/Semantics/IntTransfer.lean` (`FrameOver.map`) — *Saturation* transported along an
  order isomorphism of durations;
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` (`FrameOver.translationProduct`) —
  *Saturation* of a product, from *Saturation* of a factor;
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`
  (`regionFrame_saturation`) and
  `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
  (`zTaskFrameV2_saturation`) — the constructed frames' own *Saturation* facts, read off frames
  that already carry it.

`FormalSystem/Semantics/TaskFrame.lean`'s occurrences are the accessor definitions and their
`example` acceptance tests, not applications at all.

**The correction has been propagated.** Every unattributed, tree-level sentence in the extension
chain that once called `step` *Saturation*'s sole **application** site now says **elimination**
site — this module's own title and `:158`, and `Extension/Extension.lean`'s chain diagram, its
"what `thm:extension` consumes" section, `isTotal_of_isMax` and `extension`. Sentences that
*attribute* the phrase to the paper ("the sole application site **the paper names**", here and in
`Extension/Constraint.lean` and `Extension/Admissible.lean`) are correct as they stand and are
deliberately left unchanged. The three transports that build a derived frame's `saturation` field
out of `F.saturation` — `IntTransfer.lean`'s `FrameOver.map`, `OpenReversal.lean`'s
`FrameOver.rev_isRegular` and `Frames/TranslationProduct.lean`'s `FrameOver.translationProduct` —
are the confirmed non-`step` application sites that make the distinction load bearing; the
remaining two listed above read *Saturation* off frames that already carry it.

## What `step` actually consumes: *Completion*

`Extension/Completion.lean` isolates the condition this site needs and shows it is **equivalent**
to the one-point extension property `step` concludes: `PartialHistory.Completion`. *Saturation*
enters only to establish it (`completion_of_isRegular`, which routes through this very proof), and
once *Completion* is assumed, `thm:extension` follows from *Seriality* and *Limit* with no
*Saturation* and no *Compositionality* (`extension_of_completion`). Over `def:BX-z`'s ℤ-time,
*Saturation* is redundant outright (`extension_of_isZTime`), which is this lemma's own closing
remark made precise.

**And *Completion* is *strictly* weaker than what this site assumes.** The relative strength of
the two conditions is settled, not open: `StateTopology.SeparatingFrame.srel_completion` together
with `StateTopology.SeparatingFrame.not_srel_saturation` exhibits a relation satisfying
*Seriality*, *Compositionality*, *Limit* and *Completion* and failing *Saturation*, so
`Completion → Saturation` is **false**.

Read correctly, that measures **the exact strength the axiom is spent at**, and the minimality it
measures is recorded where minimality belongs: in `extension_of_completion`'s hypotheses, which
take *Completion* explicitly and elaborate with no `[F.IsRegular]` binder at all. It is **not** a
case for migrating *Completion* into `def:frame`. *Completion*'s hypothesis clause is
`def:world-history`'s clause verbatim and `completion_iff_onePointExtension` makes it equivalent
to "the construction `thm:extension` performs succeeds"; *Saturation* instead says the geometry
`⇒` induces on `W` — whose balls are the fibers and segments of `def:task-relation` — has no
gaps. Tight hypotheses belong in theorems; natural closure conditions belong in definitions. See
`Extension/Completion.lean`'s "Why *Completion* is a derived condition" for the full comparison.

### The frame-axiom-field invariant, discharged

`step` once took *Saturation* as an explicit hypothesis binder `hSph`, against the day the
the frame structure would carry the axioms as fields. **That day has come, and the invariant
held.** `FrameOver.saturation` is definitionally `TaskFrame.Saturation TaskRel`,
`FrameOver.serial` definitionally `TaskFrame.Serial TaskRel`, and `FrameOver.interpolates` —
the `→` projection of the biconditional `comp` field — definitionally
`TaskFrame.Interpolates TaskRel`. `step` now applies `F.saturation` **directly**, with zero
restatement and no hypothesis binder in sight.

That is the acceptance test, and it is now permanent rather than pending: the fields are not
inert decoration that could drift from the predicates, because this proof consumes
`F.saturation` at the sole application site the paper names. A field whose statement differed
would make this file stop typechecking.

## Paper specification, transcribed

Anchors are `\label` keys into `docs/reference/paper-definitions-of-record.md`, which — not the
paper source — is the citation source of record.

- `lem:step` (verbatim): "Every partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any
  duration $z \in D$."
- `lem:step`'s closing remark (verbatim, load bearing for the discrete case): "When the family has
  a $\subseteq$-least member, that member already contains a candidate and \textit{Saturation} is
  not needed."
- `lem:constraint` (verbatim): "For any partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the constraints imposed on
  $z$ form a directed family of nonempty sets."
- `lem:admissible` (verbatim): "For any partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the function
  $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs
  to every member of the constraints imposed on $z$."
- `def:frame#Saturation` (verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for any directed family
  $\mathcal{S}$ of nonempty fibers and segments."

## The `z ∈ D` versus `z ∈ D \ X` asymmetry

`lem:step` is stated for **any** duration `z ∈ D`, with no `z ∉ X` proviso — unlike
`def:constraints`, `lem:fibers` (a RETIRED paper anchor — the paper removed `\label{lem:fibers}`;
the citation resolves against the record's DANGLING entry), and `lem:admissible`, which are all
stated over `z ∈ D \ X`.
That is not an oversight in the paper and it is not smoothed over here: the `z ∈ dom τ` case is
handled separately and trivially, by taking `σ := τ` (which already has `z` in its domain and
extends itself). Only the `z ∉ dom τ` branch reaches `lem:admissible`, whose `hz` proviso is
genuinely load bearing.

## References

* JPL paper `lem:step` — the one-point extension step
* JPL paper `lem:constraint` — the constraints form a directed family of nonempty sets
* JPL paper `lem:admissible` — when adjoining a point yields a partial history
* JPL paper `def:frame` — the four frame axioms

-/

namespace FormalSystem.Semantics

namespace PartialHistory

open TaskFrame

/--
`lem:step`: the Step Lemma. Every partial history extends by one arbitrary duration.

Recorded source (`lem:step`, verbatim): "Every partial history $\tau : X \to W$ over a frame
$\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any duration
$z \in D$."

Closing remark of the recorded source (verbatim, load bearing for the discrete case): "When the
family has a $\subseteq$-least member, that member already contains a candidate and
\textit{Saturation} is not needed." That remark is recorded, not exploited: the proof below takes
the general route through *Saturation*, which is what the paper's own proof does, and which is what
makes this the axiom's sole elimination site. A discrete-duration specialization that picks the
`⊆`-least constraint directly would discharge `hSph` without the axiom; nothing here depends on
that route existing.

**Proof recipe, exactly as recorded**: `lem:constraint` gives the directed family of nonempty
fibers and segments, *Saturation* provides a common member, and `lem:admissible` certifies the
extension.

**This is the sole *Saturation* elimination site.** `F.saturation` — the structure field itself —
is consumed in the proof body below, and this is the only place in the development where it is
spent on a conclusion that does not itself mention *Saturation*. It is not decoration: a field
whose statement differed from `TaskFrame.Saturation TaskRel` would make this proof fail to
elaborate. See this module's
docstring for the frame-axiom-field invariant that discharges.

The frame axioms are taken from the structure's own fields — `F.saturation` here, and
`F.serial` / `F.interpolates` / `F.limit` through `constraint` and `admissible` — so this
theorem quantifies over a frame alone, with no axiom hypotheses. *Limit* reaches
`lem:admissible` the same way, where it is needed for `lem:nullity` at `z` itself.
-/
theorem step (F : TaskFrame) [F.IsRegular] (τ : PartialHistory F) (z : F.Duration) :
    ∃ σ : PartialHistory F, Extends σ τ ∧ σ.domain z := by
  by_cases hz : τ.domain z
  · -- `z` is already a domain time: `τ` itself is the extension, no axiom needed.
    exact ⟨τ, ⟨fun _ ht => ht, fun _ _ => rfl⟩, hz⟩
  · -- `z ∈ D \ X`: the paper's route, through the constraints.
    obtain ⟨hdir, hne⟩ := constraint τ z
    -- *Saturation*, applied to the family `lem:constraint` just certified.
    obtain ⟨u, hu⟩ := F.saturation (Constraints τ z) hdir fun c hc =>
      ⟨isFiber_or_isSegment_of_mem_Constraints hc, hne c hc⟩
    -- `lem:admissible` converts membership in every constraint into task-respect.
    have hadm : AdjoinRespects τ z u :=
      (admissible τ hz u).mpr fun c hc => Set.mem_sInter.mp hu c hc
    exact ⟨adjoin τ z u hadm, adjoin_extends τ z u hadm, adjoin_domain_self τ z u hadm⟩

end PartialHistory

end FormalSystem.Semantics
