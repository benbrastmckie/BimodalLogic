# SeparationZ — Gabbay separation over the integer flow

Gabbay's Separation Theorem for the until/since language over discrete (integer) time: the
route that would discharge the `SeparationOver TaskFrame.IsZTime` hypothesis of
[`OpenFutureElimination.lean`](../OpenFutureElimination.lean).

**Status: the hypothesis is NOT discharged yet.** What is landed is GHR Lemmas 10.2.1 and
10.2.2 in full, Lemma 10.2.3's four single-sign cases, and Lemma 10.2.3's Case 5 — the hard case
in which the same `untl` occurs in both the event and the guard argument of a `snce` and both
occurrences are positive. Cases 6, 7 and 8 reduce to Case 5 and to the single-sign cases in the
source's own acyclic order, and 10.2.4 onwards consume all eight, so Theorem 10.2.9 is not
reached yet. Every `tr` row of `OpenFutureElimination.lean` keeps its `SeparationOver`
hypothesis exactly as before.

`Eliminations.lean`'s module docstring records an obstruction to Cases 5-8. That record describes
a route that re-anchors each hard case semantically — which is not the route the source uses, and
is not the route `ElimHard.lean` takes. `ElimHard.lean`'s own module docstring carries the
correction, together with the two compiled models that refute GHR's printed Case 5 formula.

The development runs over an auxiliary syntax `USForm` whose leaves are abstract natural-number
indices evaluated by a leaf valuation `ℕ → ℤ → Prop`, not over `PlusFormula` directly. The
reason is recorded in `Syntax.lean`'s module docstring: GHR substitute formulas for atoms in
four of their eight lemmas, and uniform substitution does not visibly preserve L⁺ validity over
task frames. Abstracting the leaves makes every such step a reindexing of the leaf valuation.
The seam back to `PlusFormula` is a single interface in `LeafAbstraction.lean`.

**Argument order.** `untl`/`snce` take the guard first and the event second, matching
`PlusFormula.untl`. GHR's `U(A, B)` is this subtree's `untl B A`; every transcription flips.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Syntax.lean` | 394 | `USForm`, `usTruth` over `ℤ`, the derived connectives, the clause lemmas, the time reflection `swap` with `usTruth_swap`, and the `maxLeaf`/`freshLeaf` fresh-index device |
| `LeafAbstraction.lean` | 370 | The one seam to `PlusFormula`: `leaves`, `abstr`, `toPlus`, the roundtrip, truth transfer at `t : ℤ`, `IsUOnly`/`IsSOnly`, purity transfer, and the carrier bridge |
| `Distributivity.lean` | 134 | GHR Lemma 10.2.1: the duality combinator `usTruth_swap_congr` and the four Boolean distributivities (linearity only) |
| `NegationEquiv.lean` | 166 | GHR Lemma 10.2.2: the `ℤ` least-witness device and the four negation equivalences (first discreteness-dependent step) |
| `Eliminations.lean` | 357 | GHR Lemma 10.2.3 Cases 1-4, the `G`-under-`S` elimination, the `IsSeparated` predicate, and the four discharged separatedness theorems |
| `ElimHard.lean` | 461 | GHR Lemma 10.2.3's hard cases — the ones where the same `untl` sits in both arguments of a `snce`. Carries the `ℤ` greatest-witness device, the `case5W`/`case5Core` split, the guard equivalence, Case 5 and its separatedness |

## Key Results

- `usTruth_swap` — the time reflection, which halves every `snce` case downstream
- `usTruth_congr_of_update` — the whole content of GHR's "fresh atom" device
- `toPlus_abstr`, `usTruth_toPlus_iff` — the roundtrip and the truth transfer across the seam
- `pointwise_ztime_of_pointwise_int` — the carrier bridge from `ℤ` to every regular ℤ-time frame
- `usTruth_untl_or_event`, `usTruth_untl_and_guard` and their `snce` mirrors — GHR 10.2.1
- `usTruth_neg_untl`, `usTruth_neg_untl_strong` and their `snce` mirrors — GHR 10.2.2
- `usTruth_case1` … `usTruth_case4` with `isSeparated_case1Rhs` … `isSeparated_case4Rhs` —
  GHR 10.2.3's four single-sign cases, each with its separatedness proved rather than asserted
- `usTruth_case5` with `isSeparated_case5Rhs` — GHR 10.2.3's Case 5, the one hard case proved
  semantically, with GHR's printed formula refuted over `ℤ` and the repair recorded at the
  declaration
- `usTruth_case5_guard_iff` — the guard equivalence the repair needs, the one lemma of this
  subtree with no counterpart in the source

## Not landed

GHR Lemma 10.2.3 Cases 6, 7 and 8, Lemma 10.2.4 and everything downstream of it
(10.2.5-10.2.8, Theorem 10.2.9), hence also the `SeparationOver TaskFrame.IsZTime` discharge and
the computable ZTime translation that would rest on it.

## References

* [GHR] D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations
  and Computational Aspects*, vol. 1, Chapter 10 §10.2 — Lemmas 10.2.1-10.2.8 and
  Theorem 10.2.9 over the integer flow

*Last verified: 2026-11-06*
