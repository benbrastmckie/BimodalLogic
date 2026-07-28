# Summary: Phase 4.3b — T3 branch invariant and the unbranched step bound

- **Task**: 165 — establish_semantic_finite_model_property
- **Status**: TBD
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Phase**: 4 (Termination, WP3) — sub-phase 4.3b
- **Plan**: plans/01_tableau-decidability-two-track.md
- **Status on exit**: Phase 4 remains `[PARTIAL]`
- **Date**: 2026-07-28d

## What was executed

Single-phase dispatch on 4.3b, resuming where the previous dispatch stopped. All work is in
`FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`; nothing else was edited.

### Landed (sorry-free)

| Group | Declarations |
|-------|--------------|
| Trichotomy obligation | `TrichStock`, `trichClosed_of_trichStock` |
| Branch invariant | `BranchStock` |
| Pick extraction | `findApplicableRule_applyRule_eq`, `findApplicableSerialRule_applyRule_eq`, `findApplicableLinearityRule_applyRule_eq`, `pick_result_mem` |
| T1 iterated | `expandOnceUnblocked_extended_mem`, `expandOnceUnblocked_extended_stock` |
| Universe | `signedUniverse`, `mem_signedUniverse`, `card_signedUniverse_le`, `branch_card_le` |
| Step bound | `ExtendStep`, `card_lt_of_extendStep`, `chain_card_le`, `branchStock_chain`, `chain_le_card_universe`, `chain_le_stock`, `chain_le_soundFuel'` |

`chain_le_stock` is the headline: an unbranched run out of a stock-confined branch takes at most
`2 · |C| · |L|` steps. `chain_le_soundFuel'` evaluates that at the T2 label figure `2 ^ (2·|C|)`
and lands on `soundFuel'` itself, so the fuel figure defined in 4.3a is earned rather than merely
stated — in the unbranched dimension.

## Three findings that change the plan

1. **`buildTableau_isSome` is false as written.** `buildTableau` calls `expandBranchWithFuel` at
   the default `maxBranches := 50000` (`Saturation.lean:590`) and that function returns `none` on
   `branchesUsed >= maxBranches` (`:594`) at any fuel; `buildTableau`'s own last arm returns `none`
   on a still-unsaturated branch after the post-blocking pass (`:950`). Neither is fuel exhaustion.
   The statement must quantify over the branch budget. Recorded as the 4.3b blocker in the plan and
   re-scheduled as 4.3c.
2. **The earlier trichotomy-preservation note was too optimistic.** `TrichClosed` is *anti*-monotone
   in the branch, so it cannot be transported along a step at all. The reason given for optimism
   (`orderTrichotomy` emits only positive disjuncts) is true but insufficient: `negPos` fired on a
   branch formula `¬F(A ∧ B)` places a negated `F(A ∧ B)` on the branch, and `TableauClosed`
   supplies neither of the other two disjuncts. The invariant is therefore re-established at each
   step from a stock-side hypothesis `TrichStock C`. It is a hypothesis, never a field and never a
   sorry; as a `TableauClosed` field it would still make the structure unsatisfiable.
3. **The label dimension needs a run-level chain invariant.** `blocking_fires_of_card_lt` requires
   its counted times to be totally ordered by `ancestorTimes`; `timeLinearity` is what makes them
   so, but nothing yet ties the two together. This is the largest remaining piece of T3.

## Verification

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability` | green (1054 jobs) |
| `lake build BimodalTest` | green (1949 jobs) |
| `lean-sorry-census.sh` on `Verified/` | `sorry_count: 0` |
| Vacuous definitions | 0 |
| New axioms | 0 (`#print axioms chain_le_soundFuel'` = `propext, Classical.choice, Quot.sound`) |
| Conformance corpus | verdict-neutral (no `#guard_msgs` movement) |

`lake build` (full) still has the pre-existing RED at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`, which belongs to a
different tree, does not import `Decidability/`, and was neither touched nor affected here.

## Plan deviations

- **4.3b altered**: the named deliverable `buildTableau_isSome` was not landed. Raised as a blocker
  in the plan (per `.claude/rules/plan-compliance.md`) rather than silently annotated, because the
  statement is refuted by source inspection rather than merely hard.
- **4.2d not attempted**: correctly scoped out — the continuation context directs taking it only if
  budget remains after 4.3b, and 4.3b did not complete.
