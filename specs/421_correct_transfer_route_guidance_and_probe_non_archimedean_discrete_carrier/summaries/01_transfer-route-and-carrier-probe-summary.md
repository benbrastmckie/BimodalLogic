# Implementation Summary: Correct transfer route guidance and probe non-Archimedean discrete carrier

- **Task**: 421
- **Plan**: `plans/01_transfer-route-and-carrier-probe.md`
- **Research**: `reports/01_transfer-route-and-discrete-carrier.md`
- **Type**: lean4
- **Phases**: 5 of 5 completed

## What Was Done

Two independent, comment-and-probe-only deliverables on the Base weak terminus. No proof
obligation was added, discharged, or relocated; the `sorry` in `WeakCanonical.countermodel_discrete`
is byte-identical to its pre-task state.

### (a) Refuted-route guidance — `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`

**Phase 1.** The three-line route-guidance comment in the body of `countermodel_discrete`
("Two candidate routes: (i) a Base-MCS → Discrete-MCS transfer lemma …, or (ii) a Henkin-style
…") was replaced by the research-verified refutation text. It records that route (i) is REFUTED
and must not be re-attempted, with the `ℤ ×ₗ ℤ` witness spelled out (`p` true exactly at points
`≥ (1,0)`; `nextTop` holds everywhere so `□ nextTop` holds; `G(Gp → p)` and `FGp` hold at `(0,0)`
but `Gp` fails there via `(0,1)`; hence `Axiom.z1 p` is false at `(0,0)`, and since `z1` is
Discrete-only the set extends by Lindenbaum to a Base-MCS that is Discrete-inconsistent). It then
points at route (ii) — the discrete canonical model over a non-Archimedean carrier — and at the
new probe module.

The four `-- SORRY: open obligation …` lines above the block and the `sorry` below it were not
touched.

**Phase 2** (discretionary; executed per the plan's recommendation). The enclosing section
docstring said a Base-MCS "is not automatically Discrete-consistent", which understates what the
Phase 1 refutation establishes. It now reads "provably need not be Discrete-consistent — see the
refutation of route (i) in the body of `countermodel_discrete` below."

### (b) Carrier probe — `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean`

**Phase 3.** New module carrying the standard copyright header, a module docstring in the voice
of the `ℝ` `CarrierProbe` in `CompletenessDedekind.lean`, and the research-verified body: eight
anonymous `example`s at `D := ℚ ×ₗ ℤ` — four `inferInstance` probes for the `FrameClass.Base`
binders (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial`), then
`bundleFlowFrame`, `bundleFlowModel`, the flow-line history space, and the load-bearing
`bundleFlow_completeness_from_neg_membership` applied end-to-end.

Imports are exactly the two the research drop-one tested: `FormalSystem.Metalogic.Algebraic.FlowFrame`
and `Mathlib.Algebra.Order.Monoid.Prod`. The latter is the non-obvious one — without it
`IsOrderedAddMonoid (ℚ ×ₗ ℤ)` fails to synthesize, since that Mathlib module is in no other
`FormalSystem` module's import closure. `Mathlib.Algebra.Order.Group.Int`,
`Mathlib.Algebra.Order.Ring.Rat`, and `open scoped Prod` were correctly omitted.

**Phase 4.** `FormalSystem/Metalogic/BXCanonical.lean` now imports the probe (adjacent to the
`CompletenessDedekind` import) and carries a matching `## Architecture` entry, so the module is
reachable from the graph and invariant C6 is unaffected.

## Verification (Phase 5 gate, recorded)

**Full `lake build`**: green — `Build completed successfully (2462 jobs)`, exit 0. This is a real
whole-tree build, not a single-module build, so it covers the residual risk of the
`Prod` / `Prod.Lex` ordered-monoid instances entering the main closure via the aggregator.

**`bash scripts/check-module-invariants.sh`**: `ALL CHECKS PASSED`, exit 0.

| Check | Result |
|---|---|
| C1 | `lake build` exits 0; `lake build BimodalTest` exits 0 |
| C2 | all four flagship axiom sets match baseline (see below) |
| C3 | sole structural sorry is in `theorem countermodel_discrete` (`Transfer.lean`) |
| C4 | all 1388 import lines resolve |
| C5 | all module-shaped paths in 1659 markdown files resolve |
| C6 | all 37 unreachable live modules manifested; all 35 still compile in isolation |
| C7 | 451 live .lean (397 FormalSystem / 53 Tests); 414 reachable, 37 unreachable |
| C8 | every subdirectory has exactly one sibling aggregator |
| C9/C10/C11 | pass |

**C2 axiom sets** — unchanged from the research baseline:
- `completeness` -> `[propext, sorryAx, Classical.choice, Quot.sound]`
- `completeness_dense` / `completeness_discrete` / `countermodel_dense` -> each
  `[propext, Classical.choice, Quot.sound]`

No new `sorryAx` anywhere. Zero `axiom` declarations in any touched file.

**Live non-Boneyard sorry count = 1**, at `Transfer.lean:1102` (the line moved from `:1084`
purely because the replacement comment is longer; the `sorry` token itself is byte-identical —
the cumulative diff contains no `+`/`-` line matching `sorry`).

**Greps**: `Two candidate routes: (i) a Base-MCS` -> 0 hits;
`not automatically Discrete-consistent` -> 0 hits; `U(⊥,⊤)` -> 0 hits in both touched files.

### C7 delta vs the plan's Scope Hypothesis — reconciled, not waved through

The plan predicted 449 live / 395 FormalSystem / 412 reachable / 37 unreachable. Actual is
**451 / 397 / 414 / 37** — two higher than predicted on the first three counts.

This is baseline drift from concurrent work, not a wiring fault. `git log --diff-filter=A`
shows exactly three `.lean` files added under `FormalSystem/` since the research baseline:

- `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` (this task)
- `FormalSystem/Semantics/ShiftSet.lean` (task 424, landed concurrently)
- `FormalSystem/Metalogic/SetConsequence.lean` (task 423, landed concurrently)

So 394 -> 397 and 411 -> 414 are each +1 from this task and +2 from the other two tasks, exactly
accounting for the discrepancy. The load-bearing number is **unreachable, which held at 37**:
had the aggregator wiring failed, the probe would have been unreachable (38) and C6 would have
failed it as unmanifested. The module is also absent from
`scripts/module-invariants-manifest.txt`, confirming it is reached from the graph.

### Instance-diamond / slowdown watch

No new elaboration slowdown or instance diamond attributable to the `Prod` / `Prod.Lex`
ordered-monoid instances was observed. The full build completed normally at 2462 jobs and every
warning in the log originates in pre-existing files.

## Plan Deviations

- Phase 3: two non-doc `/-! ### … -/` section comments were added inside the probe body for
  readability. They attach to no declaration and cannot affect elaboration; the eight `example`s
  themselves are the research text verbatim. *(deviation: altered — cosmetic only)*
- No other deviations. Phase 2, marked discretionary in the plan, was executed per the plan's
  explicit recommendation.

## Acceptance-Criterion Notes

- The task's `#print axioms` criterion is **vacuously satisfied**: the probe uses `example`
  exclusively and therefore creates no named constants to inspect. Per the plan's Non-Goals and
  the research §1 finding, no named theorem was invented to make the criterion non-vacuous —
  doing so would diverge from the mirrored `CarrierProbe` pattern the task asked for.
