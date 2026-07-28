# Phase 4 — Termination (WP3): T1 design, infrastructure, and the first ten rule cases

- **Task**: 165 — establish_semantic_finite_model_property
- **Phase**: 4 (Termination: T1, T2, T3) — **[PARTIAL]**
- **Plan**: `plans/01_tableau-decidability-two-track.md`
- **Date**: 2026-07-28

## What landed

`FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` (new, ~600
lines), plus one additive lemma in `Tableau.lean` and one import line in the aggregator.

- `RuleResult.emitted` — every signed formula a rule result places on some successor branch.
  `.branchingOrdered` contributes each arm's *entire* branch, not a delta, because
  `timeLinearity` replaces the branch rather than extending it. That makes the theorem's
  conclusion the branch-level statement the fuel loop (4.3) will want.
- `TableauClosed C` — the closure conditions, ten fields, each consumed by exactly one rule.
- Eight `as*?` inversion lemmas in `iff` form, fourteen one-step component-extraction lemmas on
  `TableauClosed`, `mem_filterMap_guarded`, `identifyTime_formula_mem`.
- `Tableau.mem_boxDiamondPersistence` — `boxDiamondPersistence` is `private` and appears in six
  rules' output, so this is the one fact the new module cannot reach from outside. `Prop`-valued
  and additive; nothing the engine computes changes.
- T1 for ten rules: `andPos`, `andNeg`, `orPos`, `orNeg`, `impPos`, `impNeg`, `negPos`, `negNeg`,
  `boxTemporal`, `denseIndicatorClosure`.

## Two design corrections, both forced by source inspection

**`closureWithNeg` is also too small.** The plan's constraint 7 is right that plain
`subformulaClosure` fails because `priorUZ` emits `U(φ, ¬φ)`, but `closureWithNeg φ` contains
`¬φ` and still not `U(φ, ¬φ)` — and `U(φ, ¬φ)` is what the rule actually emits. Seven rules emit
formulas outside `closureWithNeg`: `boxTemporal` (`Gψ`/`Hψ` from `□ψ`), `serialityRule`
(`F⊤`/`P⊤` from no trigger at all), `priorUZ`, `priorSZ`, `priorUGap`, `priorSGap`, `sepRule`,
plus `orderTrichotomy`. T1 is therefore stated against an abstract predicate whose field list
*is* that census; the concrete finite closure with a cardinality is T2's job. The separation is
not cosmetic — it means the concrete construction can be retuned without touching any rule case.

**`orderTrichotomy` is analytic, and that is what keeps the closure finite.** The rule emits the
three `temp_linearity` disjuncts on an operand pair, which naively is a quadratic closure over
`C × C` that iterates `F(F(x ∧ y) ∧ y')` without bound. Its restriction 3 fires only when the
branch already carries the negation of one of the three at the common predecessor, so the `trich`
field is an "all three or none" condition on a pair already present. Recorded so that a later
phase does not re-derive the unbounded reading and conclude T1 is false.

Three rules suspected of needing their own field provably do not. `z1Rule`'s emitted `G inner`
*is* a subformula of its trigger under the `untl` encoding of `G`; `densityRule` emits only
subformulas; `timeLinearity` emits no formulas at all.

## The blocker, measured

`earlyoom` SIGTERMs `lean` at **19.2 GiB** VmRSS. `unfold applyRule` inlines a 900-line,
36-constructor match into the hypothesis, and every live goal holds a copy, so cost scales with
(goals alive) × (breadth of the closing tactic). A bare `simp`/`simp_all` inside a `first`
alternative is retried on every open goal, which is where the memory goes.

| Shape | Result |
|-------|--------|
| One theorem, `cases rule` over 32 rules, broad `simp_all` | heartbeat exhaustion at 4M, then OOM |
| `local macro` applied per `case`, 30-alternative `first` chain | OOM at 19 GiB on `boxNeg` alone, then on `andPos` alone |
| One rule per declaration, `simp_all only` with the case's own lemmas, `first` chain ≤ 7 | **~4 s per rule, no OOM** |

The failure presents as a timeout and is not one: the process dies with no error output. The
module records both rules of thumb that follow, and the handoff repeats them, so the next
dispatch does not re-diagnose this.

## Verification

- `lake build` green (1906 jobs); `lake build BimodalTest` green (1947 jobs).
- `lean-sorry-census.sh` on `FormalSystem/Metalogic/Decidability/`: `sorry_count: 0`.
- Vacuous definitions introduced: 0. New axioms: 0.
- Conformance corpus verdict-neutral — no `#guard_msgs` movement.

## Remaining

`4.1c` (26 rule cases), `4.2` (T2 pigeonhole), `4.3` (T3 justified fuel). Two of the 26 —
`serialityRule` and `timeLinearity` — are one closer line from green with their residual goals
already characterised. The rest are grouped by propagation shape in
`.orchestrator-handoff.json`, each with the verified pipeline that discharges it.
