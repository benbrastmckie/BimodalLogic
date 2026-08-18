# Implementation Summary: the fourth termination-measure component, resumed

- **Task**: 436 — fourth_termination_measure_component
- **Plan**: `specs/436_fourth_termination_measure_component/plans/01_self-guard-potential.md`
- **File touched**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` (only)
- **Diff against the pre-resumption base**: +1821 / −3, one source file
- **Status**: full `lake build` green (2458 jobs), sorry-free, axiom-free, additive only

---

## What this dispatch found

The plan's Phase 1 had decided the recommended design **FALSE** and routed the task straight to
Phase 10, leaving Phases 2–9 `[BLOCKED]`. That verdict was a statement about the renaming the
identification arm produced *at the time the gate was built*: arm 3 merged `t₂` into `t₁` whatever
their magnitudes, so at the reuse witness's own trigger `(0, 2)` it produced `rhoSF 2 0`, retiring
the larger numeral.

The spawned blocker task has since reoriented arm 3 to merge `min t₁ t₂` into `max t₁ t₂` (C9
register entry 18), so at that same trigger the arm now produces `rhoSF 0 2` — and **no run
produces `rhoSF 2 0` there any more**. Entry 18 said in its own closing paragraph that entry 17's
refutation "stands as a statement about the unoriented arm" and that whether a measure-side
component is now provable "is a genuinely open follow-on question".

Phase 1R re-ran the gate at the renaming the oriented arm actually hands back. At the oriented gate
the self-guard potential falls **3 → 1** where the original gate measured **3 → 3**. Phase 1's
verdict does not survive the reorientation, and Phases 2–9 were unblocked and executed.

`mintPaysForTimeAt_reuse_false` is untouched and stays true: `MintPaysForTimeAt` ties `σ` to
nothing, so a renaming no run produces still refutes it. Register entry 17 stands as written.

## What landed

**The re-gate (Phase 1R).** `rhoSF_time_eq_of_ne_src` and `selfGuard_column_at_live_time` (the
converses of the two lemmas the FALSE verdict rested on); `SigmaTimeStable` and
`sigmaTimeStable_identifyOriented` — the general reason the oriented arm escapes the σ-hit
obligation, with no membership hypothesis; `gateSigma_not_sigmaTimeStable`; the repaired predicate
`MintPaysForTimeStable`; the oriented gate with all seven hazard conjuncts, all three disjuncts
measured, and `mintPaysForTimeStable_body_at_orientedGate`.

**Structure (Phases 2–3).** `mem_selfGuardRules`, `selfGuardPotential_le_two_mul`, the growth pair,
and the identification pair — `selfGuardPotential_identifyTime` and its oriented instance.
Constraint (F) is discharged with equality-or-better.

**Discharge (Phases 4–5).** `sigma_time_hit_of_sigmaTimeStable` discharges the σ-hit obligation the
register instructed be *carried*: the trigger is a branch formula, confinement puts it in `U`, and
σ-time-stability says σ does not move it off its own time. Then `selfGuardPotential_lt_of_untlNeg`
and `_of_snceNeg`, with `applyRule_untlNeg_active_ord` / `_snceNeg_active_ord` reading the arms'
ordering shapes off the engine.

**The σ invariant (Phase 6).** `SigmaTimeFixed` (time-level, what the arm's relabelling needs) and
`SigmaFixesFrom` (the watermark additive steps consume), with `mintPaysForTimeStable_no_leak`.

**The measure (Phases 7–8).** `BudgetStateAt` and `budgetPotentialAt` with both step lemmas
re-proved; `stepDecreases_budgetPotentialAt` (C6 re-instantiates, as the plan hypothesised);
`mintPathBoundAt` / `mintAwareFuelAt` with the enlargement chain.

**The termini (Phase 9).** The six-link chain restated at `MintPaysForTimeStable`, ending at the two
seed-level termini at `signedUniverse C L`, plus `mintPaysForTimeStable_signedUniverse_empty`.

**The record (Phase 10R).** Register entry 19 and the narrative reconciliation.

## Plan Deviations

- **Phase 4, first task — skipped.** The R2 lemma is *dissolved*, not discharged:
  `selfGuardPotential` does not take a `Branch` and a mint step changes neither `U` nor `σ`, so the
  index set and every column's index are unchanged and the freshly minted time contributes no
  column.
- **Phase 6, no-leak task — altered.** Landed as a three-conjunct theorem rather than a
  confirmation that no hypothesis was added: the repaired predicate needs one
  (`SigmaTimeStable σ b`), because `MintPaysForTimeAt` as stated stays refuted. The hypothesis
  weakens the predicate, holds at the seed, and is preserved at the arm.
- **Phase 7, measure definition — altered.** Two corrections, both findings. The state's budget
  clause is the mint budget **plus** the fourth component, because a self-guarded mint necessarily
  raises `mintTimeBudget` and no weight fixes a failure in the state predicate. And the third
  disjunct is a **pair** — a `selfGuardPotential` drop with a combined-budget non-increase —
  mirroring disjunct 2, because `extensionAllowance` carries a factor of `|U|` per unit of mint
  budget. The weight is `2·(Tmax²+1) + |U|`, not `2·(Tmax²+1)`, for the same reason. A consequence:
  `MintPaysForTimeAt → MintPaysForTimeStable` is unavailable and is not claimed.
- **Phase 7, last task — deferred.** The existing `_at` step-lemma variants are not carried forward
  separately; instead both new step lemmas were stated at the *weaker* `UniverseClosedAt`
  hypothesis, which covers both.
- **Phase 9, classification — Scope Hypothesis corrected.** The parent plan named
  `buildTableauAt_isSome_at_seed` and `..._at_seed_lengthBudget` as the seed-level pair; those still
  quantify `U`. The two that read every number off a concrete `signedUniverse C L` are
  `buildTableauAt_isSome_of_lengthBudget_signedUniverse` and
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`.
- **Phase 9, concrete discharge — altered.** Delivered at `L = ∅`, the boundary
  `mintPaysForTime_empty` already records. A nonempty discharge is blocked by the density
  coordinate, which this plan carries as a named residual by design.
- **Phase 9, closure-condition task — not reached.** No closure condition on `L` is needed at
  `L = ∅`; the question re-opens with the nonempty discharge.

## What remains open

One coordinate: **density**. `densityRule` mints a fresh time and lies outside both
`freshLabelRules` and `selfGuardRules`, so at a `densityRule` step no disjunct moves. It is
`denseRules`-gated, so a discharge restricted to frame classes outside `.Dense` / `.Dedekind` is not
refuted — what it needs is a rule-by-rule census showing every remaining rule either mints no time,
is witness-guarded, or is self-guarded. That census is not attempted here. `gapPotential` — indexed
by `U ×ˢ U`, `denseRules`-gated — remains implemented nowhere and assumed by nothing.

Register entry 19 is the standing record.
