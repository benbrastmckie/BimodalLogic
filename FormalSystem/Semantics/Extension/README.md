# Extension — the Extension Theorem for partial histories

Every partial history extends to a **possible world**. This directory proves that, in the
paper's own decomposition, and closes with the occurrence corollary: every world state occurs
at any prescribed time in some possible world.

The chain is: the constraints a partial history imposes on a new duration form a directed,
nonempty family (`Constraint.lean`); membership in every constraint is the same as membership
in a plain fiber, which yields a one-point extension (`Admissible.lean`); one arbitrary duration
can therefore be added (`Step.lean`); and Zorn's lemma over the extension order produces a
maximal, hence total, element (`Extension.lean`). `Completion.lean` then isolates *what* the
chain consumes at its one axiom-spending step, and `Extension.lean` closes with the
identification: partial histories **are** the restrictions of possible worlds.

`Step.lean` is **the sole site in the development where *Saturation* is eliminated into a
conclusion that does not itself mention *Saturation***. That is narrower than the claim this
README formerly made — `F.saturation` is *applied* at six sites, and the other five (in
`OpenLanguage/OpenReversal.lean`, `Semantics/IntTransfer.lean`,
`Semantics/Frames/TranslationProduct.lean`,
`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` and
`Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`) each take *Saturation* in and give
*Saturation* back out. `Completion.lean` records what that one elimination actually buys:
`PartialHistory.Completion`, a condition **equivalent** to the one-point extension property, so
*Saturation* is sufficient for `thm:extension` but is strictly more than it needs.

**Strictly more, now in the demonstrated sense.** The condition is stated over a bare task
relation as `TaskFrame.Completion` (`../TaskFrame.lean`), beside `Saturation`, `Serial`,
`Compositional` and `Limit`, and the converse `Completion → Saturation` is **false**:
`StateTopology.SeparatingFrame` satisfies *Seriality*, *Compositionality*, *Limit* and
*Completion* and fails *Saturation*.

**That is a sharpness result, not a proposal.** *Completion* is the **derived** condition the
chain consumes — `completion_of_isRegular` obtains it from *Saturation*, and
`extension_of_completion` takes it as an explicit hypothesis, which is where the minimality is
recorded. It is not a candidate for `def:frame`'s fourth constraint: its hypothesis clause is
`def:world-history`'s clause verbatim, and `completion_iff_onePointExtension` makes it equivalent
to "the construction `thm:extension` performs succeeds" — an axiom in the shape of its own
theorem. *Saturation* looks backward instead, to `def:task-relation`, whose fibers and segments
are the relation repackaged as subsets; it says the geometry `⇒` induces on `W` has no gaps.
`def:frame` carries *Saturation*, the manuscript says *Saturation*, and nothing here is pending.

**The nest reduction, and what it settles.** `def:frame`'s *Saturation* is the `⇒`-directed form
`S₁ᵈ` of the Ćmiel–Kuhlmann–Kuhlmann ball-space hierarchy over the ball space of nonempty fibers
and segments. The standard nest condition `S₁` is `TaskFrame.NestSaturation`, its general form
lives in `../../ForMathlib/Order/BallSpace.lean`, and `nestSaturation_of_saturation`
machine-checks the footnote's `S₁ᵈ → S₁`. `Completion.lean` then settles the question the
directedness raises: over any history with **countably many times** — hence over both `ℤ`-time
and `ℚ`-time — `S₁` buys exactly what `S₁ᵈ` buys at `lem:step`
(`sInter_constraints_nonempty_of_countable`, via `HasCofinalNest` and
`hasCofinalNest_of_countable`). **The directedness is therefore not forced.** It is kept because
it is the form the no-gaps reading takes when stated about the geometry rather than about one
construction's index set. The frame-level `S₁ → Saturation` is **not** available and is never
stated: the reduction is a property of `Constraints τ z`, not of the frame.

`PeriodicExtension.lean` is a constructive alternative over `ℤ`-time with a finite carrier,
where Zorn's lemma is more than is needed: a bounded history has two orbits leaving it, and
over a finite carrier both must eventually repeat. `Completion.lean`'s `extension_of_isZTime`
makes the same point from the Zorn side and in full generality — over `def:BX-z`'s ℤ-time
`thm:extension` follows from *Compositionality*, *Seriality* and *Limit* alone, with **no**
*Saturation*, so the axiom earns its place only over dense temporal orders.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Admissible.lean` | 331 | `lem:fibers` (RETIRED paper anchor; resolves against the record's DANGLING entry, not a live `\label`) and `lem:admissible` — rewrites membership in *every* constraint as membership in a plain fiber, turning that into a one-point extension of the partial history. |
| `Completion.lean` | 883 | `PartialHistory.Completion` — the exact condition `lem:step` consumes, proved **equivalent** to the one-point extension property; `extension_of_completion` derives `thm:extension` from *Completion* + *Seriality* + *Limit* with no `[F.IsRegular]` binder at all; `HasNearest` / `extension_of_isZTime` show *Saturation* is redundant over discrete time; and `completion_of_finite_domain` shows the finitary form is free, so the infinitary quantifier is essential. Also the nest reduction: `HasCofinalNest`, `sInter_constraints_nonempty_of_nestSaturation` and `sInter_constraints_nonempty_of_countable`, which settle that the `⇒`-directedness of `def:frame`'s fourth constraint is **not forced** over any carrier this development instantiates. |
| `Constraint.lean` | 535 | `lem:constraint` — the constraints a partial history imposes on a new duration form a *directed* family of *nonempty* sets. That is the whole of the lemma; the admissibility characterization is split out into `Admissible.lean`. |
| `Extension.lean` | 346 | `thm:extension` and `cor:occurrence` — every partial history is extended by some possible world, and every world state occurs at any prescribed time in some possible world. Also the identification `isRestriction_of_isRegular` / `exists_restrict_eq` / `exists_worldHistory_restricting_pair`, and the recorded argument for keeping `def:world-history` primitive. |
| `PeriodicExtension.lean` | 452 | A constructive alternative over `ℤ`-time with a finite carrier: a bounded history's two departing orbits must repeat, giving a periodic total extension without Zorn's lemma. |
| `Step.lean` | 208 | `lem:step` — the Step Lemma: every partial history extends by one arbitrary duration. The join point of the chain, and the sole *Saturation* **elimination** site. |

## Key Results

- `thm:extension` (`Extension.lean`) — the Extension Theorem.
- `cor:occurrence` (`Extension.lean`) — every world state occurs at any prescribed time in some
  possible world.
- `lem:step` (`Step.lean`) — the one-duration extension, and the sole site where *Saturation* is
  eliminated into a non-*Saturation* conclusion.
- `PartialHistory.completion_iff_onePointExtension` (`Completion.lean`) — *Completion* **is** the
  one-point extension property, at any frame satisfying *Seriality* and *Limit*. With
  `completion_of_isRegular` (*Saturation* ⟹ *Completion*, through `step`) this pins down exactly
  what the extension chain costs.
- `PartialHistory.extension_of_completion` (`Completion.lean`) — `thm:extension` from *Completion*
  + *Seriality* + *Limit*, with **no** *Saturation* and **no** *Compositionality*. It elaborates
  with no `[F.IsRegular]` binder, which certifies that the Zorn layer is constraint-free, and it
  is where the minimality is recorded.
- `PartialHistory.sInter_constraints_nonempty_of_countable` (`Completion.lean`) — over any history
  with countably many times, the nest condition `S₁` buys exactly what the `⇒`-directed `S₁ᵈ` buys
  at `lem:step`. **The directedness of `def:frame`'s fourth constraint is not forced**; it is kept
  on the naturalness criterion.
- `PartialHistory.extension_of_isZTime` (`Completion.lean`) — over ℤ-time, `thm:extension` needs no
  *Saturation* at all.
- `PartialHistory.completion_of_finite_domain` (`Completion.lean`) — the **finitary** form of
  *Completion*, from *Compositionality* and *Seriality* over any temporal order, via the
  pointwise `NearestAt` and `nearestAt_of_finite`. With
  `StateTopology.RationalTwoOrigins.not_rel_completion` it shows no condition implied by
  *Compositionality* can be equivalent to *Completion*, so the infinitary quantifier is
  essential.
- `PartialHistory.exists_restrict_eq` and `exists_worldHistory_restricting_pair`
  (`Extension.lean`) — partial histories are exactly the restrictions of possible worlds,
  pointwise and at the extension order. The converse direction,
  `PartialHistory.restrict_isPartialHistory` (`Semantics/PartialHistory.lean`), costs no frame
  constraint at all.
- `FrameOver.reflection_of_limit` (`Semantics/TaskFrame.lean`) — the reflection law costs *Limit*
  alone; every *Limit* consumption in this chain traces back to it.

## Dependencies

- **Imports from**: `FormalSystem.Semantics.TaskFrame`,
  `FormalSystem.Semantics.PartialHistory`, `FormalSystem.Semantics.PartialHistoryOrder`,
  Mathlib's Zorn's lemma
- **Imported by**: `FormalSystem.Semantics` aggregators and the metalogic countermodel
  constructions, which need total histories to evaluate `valid` against

## Related Documentation

- [Semantics README](../README.md)
- [FormalSystem README](../../README.md)

---

**Last verified**: 2026-09-24

---

*Last verified: 2026-09-24*
