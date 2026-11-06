# SeparationZ — Gabbay separation over the integer flow

Gabbay's Separation Theorem for the until/since language over discrete (integer) time: the
route that would discharge the `SeparationOver TaskFrame.IsZTime` hypothesis of
[`OpenFutureElimination.lean`](../OpenFutureElimination.lean).

**Status: the hypothesis is NOT discharged yet.** What is landed is GHR Lemmas 10.2.1 and
10.2.2 in full and **all eight cases of Lemma 10.2.3** — the four single-sign cases in
`Eliminations.lean` and the four hard cases, where the same `untl` occurs in both the event and
the guard argument of a `snce`, in `ElimHard.lean`. Lemma 10.2.4 onwards still consume them, so
Theorem 10.2.9 is not reached yet, and every `tr` row of `OpenFutureElimination.lean` keeps its
`SeparationOver` hypothesis exactly as before.

`Eliminations.lean`'s module docstring records an obstruction to Cases 5-8. That record describes
a route that re-anchors each hard case semantically — which is not the route the source uses, and
is not the route `ElimHard.lean` takes. `ElimHard.lean`'s own module docstring carries the
correction: the landed reduction DAG, the two compiled models that refute GHR's printed Case 5
formula, and the model that refutes GHR's claim that Case 8's third disjunct is redundant.

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
| `NegationEquiv.lean` | 212 | GHR Lemma 10.2.2: the `ℤ` least-witness device, the four negation equivalences (first discreteness-dependent step), and the generic negated-since distribution identity Case 8 consumes |
| `Eliminations.lean` | 508 | GHR Lemma 10.2.3 Cases 1-4, the `G`-under-`S` elimination, the `IsSeparated` predicate, the four discharged separatedness theorems, and the printed-form siblings of Cases 2 and 3 |
| `ElimHard.lean` | 1089 | GHR Lemma 10.2.3's four hard cases — the ones where the same `untl` sits in both arguments of a `snce`. Carries the `ℤ` greatest-witness device, the `case5W`/`case5Core` split, the guard equivalence, Cases 5-8 and their separatedness, the printed-form siblings of Cases 8, 7 and 6, plus the landed reduction DAG |
| `NormalForm.lean` | 514 | GHR Lemma 10.2.4: the `IsUTyped` precondition with its relationship to `IsSeparated`, the `untl`-literal normal form `substU` with the event and guard splits, the nine right-hand-side typedness witnesses, and `sepSnce` with its equivalence and both discharged halves of the conclusion |
| `Hierarchy.lean` | 169 | GHR Lemma 10.2.5's input hypothesis `IsUSingleType` — the single `untl` type with nesting unconstrained — with its four Boolean closure lemmas, the one-way implication from `IsUTyped`, and the two witnesses that prove the strictness at `S(⊥, U(A,B))` |

## Key Results

- `usTruth_swap` — the time reflection, which halves every `snce` case downstream
- `usTruth_congr_of_update` — the whole content of GHR's "fresh atom" device
- `toPlus_abstr`, `usTruth_toPlus_iff` — the roundtrip and the truth transfer across the seam
- `pointwise_ztime_of_pointwise_int` — the carrier bridge from `ℤ` to every regular ℤ-time frame
- `usTruth_untl_or_event`, `usTruth_untl_and_guard` and their `snce` mirrors — GHR 10.2.1
- `usTruth_neg_untl`, `usTruth_neg_untl_strong` and their `snce` mirrors — GHR 10.2.2
- `usTruth_case1` … `usTruth_case4` with `isSeparated_case1Rhs` … `isSeparated_case4Rhs` —
  GHR 10.2.3's four single-sign cases, each with its separatedness proved rather than asserted
- `usTruth_case5` … `usTruth_case8` with `isSeparated_case5Rhs` … `isSeparated_case8Rhs` —
  GHR 10.2.3's four hard cases, completing all eight. Case 5 is the only one proved
  semantically; Cases 8, 7 and 6 are reductions to earlier cases in the source's own acyclic
  order, tabulated in `ElimHard.lean`'s docstring
- `usTruth_case5_guard_iff` — the guard equivalence Case 5's repair needs, the one lemma of this
  subtree with no counterpart in the source
- `usTruth_neg_snce_distrib` — GHR's generic negated-since distribution identity, the hinge of
  Case 8's reduction
- `IsUTyped` with `isSeparated_of_isUTyped` — GHR 10.2.4's actual precondition, strictly weaker
  than `IsSeparated`, and the two extra hypotheses the implication needs
- `usTruth_case2_printed`, `usTruth_case3_printed`, `usTruth_case8_printed`,
  `usTruth_case7_printed`, `usTruth_case6_printed` — the five cases GHR's printed Case 2 reaches,
  restated at right-hand sides whose only `untl` occurrence is `untl B A`, each with its own
  `isSeparated_*Printed` witness
- `usTruth_sepSnce` with `isSeparated_sepSnce` and `isUTyped_sepSnce` — GHR Lemma 10.2.4's
  equivalence and both halves of its conclusion, each a proved witness
- `IsUSingleType` with `isUSingleType_of_isUTyped` — GHR 10.2.5's actual precondition, one
  `untl` type with nesting unconstrained, and the one-way implication from 10.2.4's. The
  converse is refuted, not merely disclaimed: `not_isUTyped_snce_untl` and
  `isUSingleType_snce_untl` exhibit the gap at `S(⊥, U(A,B))`

## Not landed

GHR Lemmas 10.2.5-10.2.8 and Theorem 10.2.9, hence also the
`SeparationOver TaskFrame.IsZTime` discharge and the computable ZTime translation that would rest
on it. All of Lemma 10.2.3 is landed, and so is Lemma 10.2.4's equivalence and separatedness.
Lemma 10.2.5's *input hypothesis* is landed as `Hierarchy.lean`'s `IsUSingleType`; the lemma
itself — the `sepU` construction over it — is not.

Both halves of Lemma 10.2.4's conclusion are landed: `isSeparated_sepSnce` for separatedness
and `isUTyped_sepSnce` for the single `untl` type, so a downstream induction counting `untl`
**types** is well-posed over this layer. `NormalForm.lean`'s module docstring records which of
the two available Case 2 routes `sepSnce` consumes and why: `case2Rhs` composes `case1Rhs` at
transformed parameters together with `allFuture`, and so mentions two `untl` types beside
`untl B A`, while `case2RhsPrinted` performs GHR's own third step — the fold of
`G¬A ∨ U(¬A∧¬B,¬A)` back to `¬U(A,B)` by Lemma 10.2.2 in reverse — and mentions `untl B A`
alone. Both are retained; `sepSnce` routes through the printed-form siblings.

## References

* [GHR] D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations
  and Computational Aspects*, vol. 1, Chapter 10 §10.2 — Lemmas 10.2.1-10.2.8 and
  Theorem 10.2.9 over the integer flow

*Last verified: 2026-11-06*
