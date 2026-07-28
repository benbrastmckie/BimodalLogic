# Phase 4 Summary — Termination (T1, T2, T3): 4.2d Confinement Discharged

- **Task**: 165 — establish_semantic_finite_model_property (tableau decidability, Track A)
- **Phase**: 4 — Termination (WP3: T1, T2, T3) — now `[COMPLETED]`
- **Date**: 2026-07-28i
- **Territory**: `FormalSystem/Metalogic/Decidability/Verified/Termination/TimeTypeBound.lean`

## What was open, and what closed

Entering this dispatch, Phase 4 had exactly one open obligation: **4.2d confinement** — exhibit a
finite emission-closed superset of an arbitrary finite seed. Its stabilisation half had landed
previously, reducing everything to that one statement. It is now discharged, and Phase 4 is
complete.

The headline result:

```
exists_tableauClosed_closureIter_of_seed (seed : Finset Formula) :
    ∃ n, TableauClosed (closureIter n seed)
```

unconditional — no hypothesis, no `sorry`, no stock the caller must invent. T2's counting argument
now runs against a stock the iteration *computes*.

## The refuted route, and the one that worked

The inherited route was "define a measure on which the non-descending emission step descends, take
`M` to be the closure under it". **That route is refuted.** `priorUGap` maps `U(⊤,g) ∧ F(¬g)` to
`U(¬g ∨ K⁺¬g, g)`, which is strictly larger under *every* additive weighting of the constructors
(the difference works out to `i + μ g` for any weight assignment, where `i` is the weight of
`imp`); and any weighting light enough to make it non-increasing — `i = 0` — admits infinitely
many formulas below any bound, so the sublevel sets are not finite. There is no measure to find.

What replaces the measure is an **algebra**. `closureStep` distributes over union
(`closureStep_union`), so `Confining` stocks are closed under union. That single fact makes the
obligation decomposable: a confining stock can be *assembled* from independently-confining pieces
rather than verified in one go. From there:

1. `exists_confining_of_forall` reduces the seed-level obligation to a formula-level one
   (`ConfinesFormula`), with `constCore` as the base case.
2. A six-case structural induction closes the formula-level statement, strengthened to carry each
   subformula's **negation** as well — a strengthening the `□` case forces, because `□ψ` emits
   `Gψ = ¬F(¬ψ)`, whose `priorUZ` trigger `U(¬ψ, ⊤)` mentions `¬ψ`, which is not a subformula of
   `□ψ`.
3. The three Dedekind batches carry the content. Each conclusion drags in six to ten formulas, and
   each of those emits nothing new — for reasons that are decided at the outermost differing
   constructor and are therefore `rfl`.

The growth is real; it is simply **non-recurring**.

## Landed, all sorry-free

**Algebra and computation**: `Confining`, `closureStep_union`, `Confining.union`, `.extend`,
`.extendEmissions`, `closureStep_mono`, `closureIter_mono`, `closureIter_subset_mono`,
`constCore` (= `closureIter 3 ∅`, seven formulas, confining by kernel `decide`),
`constCore_subset_of_confining`, `bot_mem_of_confining`, `top_mem_of_confining`,
`serialFuture_mem_of_confining`, `serialPast_mem_of_confining`, `stableAt`,
`closureStep_closureIter_of_stableAt`, `exists_confining_of_stableAt`.

**Bookkeeping**: `subformulasFinset_atom/_bot/_box/_imp/_untl/_snce/_top/_neg/_or/_kPlus/_kMinus`,
`self_mem_subformulasFinset`, `subformulasFinset_subset_of_mem`, `emissions_atom`, `emissions_bot`,
`emissions_box`, `emissions_imp_of_asAnd_eq_none`, `emissions_imp_of_asAnd`, `emissions_imp_subset`,
`emissions_untl_top/_of_ne`, `emissions_snce_top/_of_ne`, `Carries`, `Carries.mono/.sub/
.subformulas_subset`, `subformulasFinset_neg_subset`, `subformulasFinset_top_subset`.

**The induction**: `SubConfining`, `confinesFormula_of_subConfining`, `subConfining_atom`,
`subConfining_bot`, `subConfining_box`, `subConfining_untl`, `subConfining_snce`,
`exists_confining_gapU`, `exists_confining_gapS`, `exists_confining_sep`,
`exists_confining_conjEmissions`, `subConfining_imp`, `subConfining`, `confinesFormula`,
`exists_confining`, `exists_tableauClosed_closureIter_of_seed`.

## Probe-first: six new committed regression rows

Before any proof was attempted, six adversarial `#guard_msgs in #eval` cascade rows were committed
(constraint 1). They are built so a trigger appears only *after* a round of closure —
`F(U(⊤,g) → ¬F(¬g))` carries no trigger in its subformulas, but `priorUZ` emits
`U(that, ¬that)`, whose second component *is* the `priorUGap` trigger. Nested up to three deep,
with and without a `□` on top, **every row still stabilises at round 4** while only `|C|` grows.
Delay does not compound — which is the executable form of the non-recurrence the proof
establishes. The file's regression corpus is now 12 rows.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green |
| `lake build BimodalTest` | green |
| Sorry census, `FormalSystem/Metalogic/Decidability/` | `sorry_count: 0` |
| New sorries | 0 |
| New axioms | 0 |
| Axioms of `exists_tableauClosed_closureIter_of_seed` | `propext`, `Classical.choice`, `Quot.sound` only |
| New vacuous definitions | 0 |
| `#guard_msgs` rows in `TimeTypeBound.lean` | 12, all passing |

Pre-existing sorries remain only in `FormalSystem/Boneyard/StrictSemanticsLegacy/` (archived
legacy, outside this territory). The pre-existing RED at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` is likewise outside
this territory and untouched.

## Preserved

Every item on the must-not-regress list is untouched: all of `Fuel.lean` (`TrichStock`,
`BranchStock`, `signedUniverse`, `chain_le_stock`, `chain_le_soundFuel'`, `TimeChain`, `NoSplit`,
`bfsClosure`, `WorldWitness`, `worldFuel'`, `soundFuel'` and its lemmas, the budget lemmas), and in
`TimeTypeBound.lean` the whole T2 counting development plus `closureIter_succ`,
`closureIter_subset_succ`, `closureIter_subset_of_closed`, `exists_closureStep_subset`,
`exists_tableauClosed_closureIter`, and `tableauClosed_of_closureStep_subset` — which was **not**
weakened. All seventeen previously-committed `#guard_msgs` rows still pass.

## Next

Phase 5 (Bridge Infrastructure), currently `[IN PROGRESS]`. Read the "ENGINE CONTRACT CHANGE
(2026-07-28b, from sub-phase 2.7c)" note at the head of Phase 5 before consuming
`expandBranchWithFuel`.
