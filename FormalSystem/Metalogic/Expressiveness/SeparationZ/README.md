# SeparationZ — Gabbay separation over the integer flow

Gabbay's Separation Theorem for the until/since language over discrete (integer) time: the
route that would discharge the `SeparationOver TaskFrame.IsZTime` hypothesis of
[`OpenFutureElimination.lean`](../OpenFutureElimination.lean).

**Status: the hypothesis is NOT discharged yet.** What is landed is GHR Lemmas 10.2.1
through 10.2.7 in full — including **all eight cases of Lemma 10.2.3**, the four single-sign
cases in `Eliminations.lean` and the four hard cases, where the same `untl` occurs in both the
event and the guard argument of a `snce`, in `ElimHard.lean`. Lemma 10.2.8 and Theorem 10.2.9
are not reached yet, so every `tr` row of `OpenFutureElimination.lean` keeps its
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
| `Hierarchy.lean` | 1000 | GHR Lemmas 10.2.5 and 10.2.6: 10.2.5's input hypothesis `IsUSingleType` — the single `untl` type with nesting unconstrained — with the four Boolean closure lemmas, the one-way implication from `IsUTyped` and the two witnesses proving the strictness at `S(⊥, U(A,B))`; the structural recursion `sepU` with all three of 10.2.5's conclusions; then the `U`-type measure `uTypes`/`uTypeCount`, the abstraction and reindexing device (`mapU`, `mapS`, `substLeaf`, `abstrFn`, `unabstrFn`), the three separately named strict-decrease obligations, and 10.2.6's `sepMulti` with all three of its conclusions |
| `UNesting.lean` | 858 | GHR Lemma 10.2.7: the hypothesis predicate `NoSnceUnderUntl` with its `Bool`-valued decision procedure, the `U`-within-`U` nesting measure `untlDepth` with its equation lemmas, the two base-case bridges to 10.2.6's `HasPureUTypes`, GHR's inner types `innerTypes` with the licensing bound `untlDepth_lt_of_mem_innerTypes` proved rather than asserted, the two-level abstraction `abstrArgs` as `mapU` at a `mapU`, the three separately named strict-decrease obligations, and `sep7` with both of 10.2.7's conclusions |

## Key Results

- `usTruth_swap` — the time reflection, which halves every `snce` case downstream
- `usTruth_congr_of_update` — the whole content of GHR's "fresh atom" device
- `toPlus_abstr`, `usTruth_toPlus_iff` — the roundtrip and the truth transfer across the seam
- `pointwise_ztime_of_pointwise_int` — the carrier bridge from `ℤ` to every regular ℤ-time frame
- `usTruth_untl_or_event`, `usTruth_untl_and_guard` and their `snce` mirrors — GHR 10.2.1
- `usTruth_neg_untl`, `usTruth_neg_untl_strong` and their `snce` mirrors — GHR 10.2.2
- `sepU` with `usTruth_sepU`, `isSeparated_sepU` and `isUTyped_sepU` — GHR 10.2.5 in full
- `uTypes`, `uTypeCount` — the `U`-type measure, read off the formula rather than supplied as
  parameters, with `uTypes_nodup` making it count each type once
- `uTypes_mapU_abstr`, `uTypes_sepU`, `uTypeCount_snce_substLeaf_le` — GHR 10.2.6's strict
  decrease as three separately named obligations: the abstraction drops the abstracted types,
  separation does not raise the count (a citation of `isUTyped_sepU`, never of
  `isUTyped_sepSnce`), and the reindexed constituents are bounded by the pre-abstraction count
  less one
- `sepMulti` with `usTruth_sepMulti`, `isSeparated_sepMulti` and `uTypes_sepMulti` — GHR 10.2.6
  in full, over `HasPureUTypes` as its precondition
- `NoSnceUnderUntl` with `noSnceUnderUntlB` and `noSnceUnderUntlB_iff` — GHR 10.2.7's hypothesis
  "contains no `S` nested within a `U`" as a decidable structural predicate, not a prose side
  condition
- `untlDepth` — the `U`-within-`U` nesting depth, GHR's "maximum depth of nesting of Us beneath an
  S". Independent of `uTypeCount`: that measure counts maximal `untl` types and says nothing about
  nesting, and neither bounds the other
- `untlDepth_le_one_of_hasPureUTypes`, `hasPureUTypes_of_untlDepth_le_one` — the two bridges
  between the measure and 10.2.6's hypothesis, which together are 10.2.7's base case, so that the
  budget's base case is `sepMulti` exactly as GHR's `n = 1` case is 10.2.6
- `untlDepth_lt_of_mem_innerTypes` — GHR's licensing sentence ("the level of nesting of U in
  `U(Aᵢ, Bᵢ)` must be strictly greater than that in its subformula `U(Xᵢⱼ, Yᵢⱼ)`") proved rather
  than asserted; the source states it without proof
- `untlDepth_mapU_abstrArgs_le_one`, `untlDepth_sepMulti_le_one`, `untlDepth_snce_substLeaf_le` —
  GHR 10.2.7's strict decrease as three separately named obligations: abstraction drops the depth
  to at most one, separation does not raise it (proved from `hasPureUTypes_sepMulti`, **not** from
  `uTypes_sepMulti`, which bounds types and not nesting), and the reindexed constituents are
  bounded by the pre-abstraction depth less one. It is the third, not the first, that licenses the
  recursive call
- `sep7` with `usTruth_sep7` and `isSeparated_sep7` — GHR 10.2.7 in full, over `NoSnceUnderUntl`
  as its precondition. A plain `def`: the budget `sep7Fuel` appears in neither conclusion
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

GHR Lemma 10.2.8 and Theorem 10.2.9, hence also the
`SeparationOver TaskFrame.IsZTime` discharge and the computable ZTime translation that would rest
on it. All of Lemma 10.2.3 is landed, and so are Lemma 10.2.4's equivalence and separatedness.
Lemma 10.2.5 is landed in full: its input hypothesis `IsUSingleType` and the `sepU` construction
over it, with the equivalence, the separatedness and the single-`untl`-type clause. GHR's own
induction on the maximum nested-`S` depth above a `U(A,B)` is deliberately not formalized —
`sepU` is a plain structural recursion, because the two halves of Lemma 10.2.4 chain at every
`snce` node and so the depth never has to be measured.

Lemma 10.2.6 is landed in full: `uTypes`/`uTypeCount` as the measure, `sepMulti` as the
construction, and the equivalence, separatedness and type-preservation as its three conclusions.
Its strict decrease is carried by three separately named results and no one of them stands in for
another. Two formalization choices are recorded at the declarations: the measure is read off the
formula rather than threaded through as a parameter list, and the recursion carries the count as
an explicit budget because a direct well-founded recursion on `uTypeCount` cannot state its
decrease goal — the recursive call is fired by `mapS` at constituents that are not subterms of
the definition's argument. `sepMulti` is a plain `def` and `#eval`s.

Lemma 10.2.7 is landed in full: `NoSnceUnderUntl` as its decidable hypothesis, `untlDepth` as the
`U`-within-`U` nesting measure, and `sep7` as the construction, with the equivalence and the
separatedness as its two conclusions. GHR's induction on the nesting depth is rendered by the same
explicit-budget idiom 10.2.6 uses, and for the same reason: the recursive call is fired by `mapS`
at the separated form's `snce` constituents, which are neither subterms of the definition's
argument nor in scope at elaboration time, so no `decreasing_by` goal can be stated. The base case
is `sepMulti` rather than the identity — at nesting depth one a formula satisfies 10.2.6's
hypothesis but is in general not itself separated, since its maximal `untl`s may sit under `snce`
nodes. The abstraction reuses `mapU`, `mapS`, `substLeaf`, `abstrFn` and `unabstrFn` verbatim; no
second substitution operator exists in this subtree. Three of `Hierarchy.lean`'s reindexing lemmas
do not transfer, because their hypothesis is `IsPureType` of every abstracted member and an inner
type need not be pure; `isSeparated_unabstrFn_of_isUOnly`, `mapS_unabstrFn_of_untl` and
`untlDepth_unabstrFn_le` are their analogues with the purity replaced by what this layer has.

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
