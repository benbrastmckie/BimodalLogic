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
*Completion* and fails *Saturation*. `Completion.lean` records the verdict and the two pieces of
follow-up it deliberately does not do (the manuscript pass, and the `FrameOver.IsRegular` field
swap).

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
| `Completion.lean` | 543 | `PartialHistory.Completion` — the exact condition `lem:step` consumes, proved **equivalent** to the one-point extension property; `extension_of_completion` derives `thm:extension` from *Completion* + *Seriality* + *Limit* with no `[F.IsRegular]` binder at all; `HasNearest` / `extension_of_isZTime` show *Saturation* is redundant over discrete time; and `completion_of_finite_domain` shows the finitary form is free, so the infinitary quantifier is essential. |
| `Constraint.lean` | 443 | `lem:constraint` — the constraints a partial history imposes on a new duration form a *directed* family of *nonempty* sets. That is the whole of the lemma; the admissibility characterization is split out into `Admissible.lean`. |
| `Extension.lean` | 339 | `thm:extension` and `cor:occurrence` — every partial history is extended by some possible world, and every world state occurs at any prescribed time in some possible world. Also the identification `isRestriction_of_isRegular` / `exists_restrict_eq` / `exists_worldHistory_restricting_pair`, and the recorded argument for keeping `def:world-history` primitive. |
| `PeriodicExtension.lean` | 452 | A constructive alternative over `ℤ`-time with a finite carrier: a bounded history's two departing orbits must repeat, giving a periodic total extension without Zorn's lemma. |
| `Step.lean` | 185 | `lem:step` — the Step Lemma: every partial history extends by one arbitrary duration. The join point of the chain, and the sole *Saturation* **elimination** site. |

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
  with no `[F.IsRegular]` binder, which certifies that the Zorn layer is constraint-free.
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

**Last verified**: 2026-09-23

---

*Last verified: 2026-09-23*
