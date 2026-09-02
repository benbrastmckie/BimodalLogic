# Extension — the Extension Theorem for partial world histories

Every partial world history extends to a **total** one. This directory proves that, in the
paper's own decomposition, and closes with the occurrence corollary: every world state occurs
at any prescribed time in some total world history.

The chain is: the constraints a partial history imposes on a new duration form a directed,
nonempty family (`Constraint.lean`); membership in every constraint is the same as membership
in a plain fiber, which yields a one-point extension (`Admissible.lean`); one arbitrary duration
can therefore be added (`Step.lean`); and Zorn's lemma over the extension order produces a
maximal, hence total, element (`Extension.lean`).

`Step.lean` is **the only place in the development where the Saturation axiom is consumed**.

`PeriodicExtension.lean` is a constructive alternative over `ℤ`-time with a finite carrier,
where Zorn's lemma is more than is needed: a bounded history has two orbits leaving it, and
over a finite carrier both must eventually repeat.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Admissible.lean` | 312 | `lem:fibers` (RETIRED paper anchor; resolves against the record's DANGLING entry, not a live `\label`) and `lem:admissible` — rewrites membership in *every* constraint as membership in a plain fiber, turning that into a one-point extension of the partial history. |
| `Constraint.lean` | 398 | `lem:constraint` — the constraints a partial history imposes on a new duration form a *directed* family of *nonempty* sets. That is the whole of the lemma; the admissibility characterization is split out into `Admissible.lean`. |
| `Extension.lean` | 272 | `thm:extension` and `cor:occurrence` — every partial history is extended by some total world history, and every world state occurs at any prescribed time in some total world history. |
| `PeriodicExtension.lean` | 444 | A constructive alternative over `ℤ`-time with a finite carrier: a bounded history's two departing orbits must repeat, giving a periodic total extension without Zorn's lemma. |
| `Step.lean` | 136 | `lem:step` — the Step Lemma: every partial history extends by one arbitrary duration. The join point of the chain, and the sole *Saturation* application site. |

## Key Results

- `thm:extension` (`Extension.lean`) — the Extension Theorem.
- `cor:occurrence` (`Extension.lean`) — every world state occurs at any prescribed time in some
  total world history.
- `lem:step` (`Step.lean`) — the one-duration extension, and the only consumer of *Saturation*.

## Dependencies

- **Imports from**: `FormalSystem.Semantics.TaskFrame`,
  `FormalSystem.Semantics.WorldHistory`, `FormalSystem.Semantics.PartialHistory`,
  Mathlib's Zorn's lemma
- **Imported by**: `FormalSystem.Semantics` aggregators and the metalogic countermodel
  constructions, which need total histories to evaluate `valid` against

## Related Documentation

- [Semantics README](../README.md)
- [FormalSystem README](../../README.md)

---

**Last verified**: 2026-08-25
