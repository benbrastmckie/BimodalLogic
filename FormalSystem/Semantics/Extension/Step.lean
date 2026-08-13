/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Extension.Admissible

/-!
# `lem:step`: the Step Lemma — the sole *Spherical* application site

This module lands the Step Lemma: every partial history extends by one arbitrary duration. It is
the join point of the whole extension chain, and it is **the only place in the development where
the *Spherical* axiom is consumed**.

The proof is a composition, not a re-derivation. Each of its three inputs is already proved:

- `lem:constraint` (`PartialHistory.constraint`, `Extension.Constraint`) supplies the two
  hypotheses *Spherical* demands of a family: the constraints imposed on `z` form a **directed**
  family, and every member is **nonempty**. Membership in the fiber-or-segment classes is
  `PartialHistory.isFiber_or_isSegment_of_mem_Constraints`.
- *Spherical* (`TaskFrame.Spherical`, `FrameAxioms`) turns that family into a common member
  `u ∈ ⋂₀ Constraints τ z`.
- `lem:admissible` (`PartialHistory.admissible`, `Extension.Admissible`) turns "belongs to every
  constraint" into the task-respect condition on the one-point extension, which
  `PartialHistory.adjoin` then realizes as an actual `PartialHistory` extending `τ` with `z` in
  its domain.

## The sole *Spherical* application site

*Spherical* is applied **here and nowhere else**. `lem:constraint` explicitly does not consume it
(it is what *supplies* this site its directed-family-of-nonempty-sets hypothesis), and
`lem:admissible` explicitly does not consume it either. A `grep` for `Spherical` across
`FormalSystem/` should therefore find exactly one consuming proof — the proof of `step` below.

### The frame-axiom-field invariant, discharged

`step` once took *Spherical* as an explicit hypothesis binder `hSph`, against the day the
`TaskFrame` structure would carry the axioms as fields. **That day has come, and the invariant
held.** `TaskFrame.spherical` is definitionally `TaskFrame.Spherical TaskRel`,
`TaskFrame.serial` definitionally `TaskFrame.Serial TaskRel`, and `TaskFrame.interpolates` —
the `→` projection of the biconditional `comp` field — definitionally
`TaskFrame.Interpolates TaskRel`. `step` now applies `F.spherical` **directly**, with zero
restatement and no hypothesis binder in sight.

That is the acceptance test, and it is now permanent rather than pending: the fields are not
inert decoration that could drift from the predicates, because this proof consumes
`F.spherical` at the sole application site the paper names. A field whose statement differed
would make this file stop typechecking.

## Paper Specification Reference

Anchors are `\label` keys into `specs/paper-definitions-of-record.md`, which — not the paper
source — is the citation source of record.

- `lem:step` (verbatim): "Every partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any
  duration $z \in D$."
- `lem:step`'s closing remark (verbatim, load bearing for the discrete case): "When the family has
  a $\subseteq$-least member, that member already contains a candidate and \textit{Spherical} is
  not needed."
- `lem:constraint` (verbatim): "For any partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the constraints imposed on
  $z$ form a directed family of nonempty sets."
- `lem:admissible` (verbatim): "For any partial history $\tau : X \to W$ over a frame
  $\F = \tuple{W, \D, \Rightarrow}$ and duration $z \in D \setminus X$, the function
  $\tau \cup \set{\tuple{z, u}}$ is a partial history on $X \cup \set{z}$ just in case $u$ belongs
  to every member of the constraints imposed on $z$."
- `def:frame#Spherical` (verbatim): "$\bigcap \mathcal{S} \neq \emptyset$ for any directed family
  $\mathcal{S}$ of nonempty fibers and segments."

## The `z ∈ D` versus `z ∈ D \ X` asymmetry

`lem:step` is stated for **any** duration `z ∈ D`, with no `z ∉ X` proviso — unlike
`def:constraints`, `lem:fibers`, and `lem:admissible`, which are all stated over `z ∈ D \ X`.
That is not an oversight in the paper and it is not smoothed over here: the `z ∈ dom τ` case is
handled separately and trivially, by taking `σ := τ` (which already has `z` in its domain and
extends itself). Only the `z ∉ dom τ` branch reaches `lem:admissible`, whose `hz` proviso is
genuinely load bearing.
-/

namespace FormalSystem.Semantics

namespace PartialHistory

open TaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/--
`lem:step`: the Step Lemma. Every partial history extends by one arbitrary duration.

Recorded source (`lem:step`, verbatim): "Every partial history $\tau : X \to W$ over a frame
$\F = \tuple{W, \D, \Rightarrow}$ extends to a partial history on $X \cup \set{z}$ for any duration
$z \in D$."

Closing remark of the recorded source (verbatim, load bearing for the discrete case): "When the
family has a $\subseteq$-least member, that member already contains a candidate and
\textit{Spherical} is not needed." That remark is recorded, not exploited: the proof below takes
the general route through *Spherical*, which is what the paper's own proof does, and which is what
makes this the axiom's sole application site. A discrete-duration specialization that picks the
`⊆`-least constraint directly would discharge `hSph` without the axiom; nothing here depends on
that route existing.

**Proof recipe, exactly as recorded**: `lem:constraint` gives the directed family of nonempty
fibers and segments, *Spherical* provides a common member, and `lem:admissible` certifies the
extension.

**This is the sole *Spherical* application site.** `F.spherical` — the structure field itself —
is consumed in the proof body below. It is not decoration: a field whose statement differed from
`TaskFrame.Spherical TaskRel` would make this proof fail to elaborate. See this module's
docstring for the frame-axiom-field invariant that discharges.

The frame axioms are taken from the structure's own fields — `F.spherical` here, and
`F.serial` / `F.interpolates` / `F.limit` through `constraint` and `admissible` — so this
theorem quantifies over a frame alone, with no axiom hypotheses. *Limit* reaches
`lem:admissible` the same way, where it is needed for `lem:nullity` at `z` itself.
-/
theorem step (F : TaskFrame D) (τ : PartialHistory F) (z : D) :
    ∃ σ : PartialHistory F, Extends σ τ ∧ σ.domain z := by
  by_cases hz : τ.domain z
  · -- `z` is already a domain time: `τ` itself is the extension, no axiom needed.
    exact ⟨τ, ⟨fun _ ht => ht, fun _ _ => rfl⟩, hz⟩
  · -- `z ∈ D \ X`: the paper's route, through the constraints.
    obtain ⟨hdir, hne⟩ := constraint τ z
    -- *Spherical*, applied to the family `lem:constraint` just certified.
    obtain ⟨u, hu⟩ := F.spherical (Constraints τ z) hdir fun c hc =>
      ⟨isFiber_or_isSegment_of_mem_Constraints hc, hne c hc⟩
    -- `lem:admissible` converts membership in every constraint into task-respect.
    have hadm : AdjoinRespects τ z u :=
      (admissible τ hz u).mpr fun c hc => Set.mem_sInter.mp hu c hc
    exact ⟨adjoin τ z u hadm, adjoin_extends τ z u hadm, adjoin_domain_self τ z u hadm⟩

end PartialHistory

end FormalSystem.Semantics
