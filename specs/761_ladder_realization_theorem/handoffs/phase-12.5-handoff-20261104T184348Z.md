# Phase 12.5 Handoff — The Three Re-Homed Conditions of `Real`

- **Phase**: 12.5, status `[COMPLETED]`
- **Immediate next action**: Phase 12.6, the decision gate on the maximum-certified-set finding
  under the widened `RK`. Its `Depends on` (12.3 and 12.5) is now discharged.

## What landed

`FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (371 → **576 lines**,
MEASURED at close), six new declarations:

- `exists_ladderWalk_of_history` — `ofSlicedStepFinBranch_mem_HF_iff` read at `RladAdm`: every
  history of `ladderFrameAdm` is `fun t => (t + k, g t)` for an offset `k` and a ladder path `g`.
  This is the only place in the module where the frame's construction is unfolded, and it is what
  turns a condition on a history into the actual `Count`/`Drift` step between two of its states.
- `realItem_eq_of_witness` — a member of `Real` IS the item its own witness realizes. The three
  membership conjuncts pin all three components of `realItem`.
- `relK_realItem_succ` — **the edge every relational condition is built from**: consecutive
  points of a ladder history are `relK`-linked. `cohIdle` half by `cohIdle_of_realized`
  (`LadderChain.lean`), `RK` half by `rk_of_count_drift` applied to the step
  `exists_ladderWalk_of_history` exposes.
- `real_certBiInfK`, `real_certFwdK`, `real_certBwdK` — conditions (2), (3) and (4).

Five of `Real`'s six conditions are now landed. Only `certStabK` — condition (5), the one that
consumes the agreement of class-equivalent cells — is outstanding, and it stays Phase 12.2's
together with `real_certAdmK_of_paramsOk` and `real_subset_dmax`. The split Phase 12.1
established is preserved exactly.

The module docstring's predecessor paragraph ("NOT landed, and the reason is one shared
obstruction rather than three") is REPLACED by what is now true, not annotated: the discharge
names `rk_of_count_drift` and the widened `repsCnt` range by figure, and the remaining
"NOT landed here" sentence is about condition (5) alone.

Wiring: three `#guard_msgs` + `#print axioms` pins in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`; three generated inventory blocks;
`typst/generated/status.typ`.

## The decomposition, as landed

All three conditions go through ONE shared edge lemma rather than deriving an `RK` edge three
times. For conditions (3) and (4) the `DischPathK` witness is the member's OWN witnessing history
read along the integers:

| condition | `m` | `f i` | temporal input |
|---|---|---|---|
| `real_certFwdK` | `(s - z).toNat` | `realItem … σ (z + i)` | `untl_mem_tpOf_iff` supplies `s > z` with the eventuality at `s` and the guard on `(z, s)` |
| `real_certBwdK` | `(z - s).toNat` | `realItem … σ (z - i)` | `snce_mem_tpOf_iff`, mirrored |

Membership of every position is `mem_real_realItem`; the consecutive-position relation is
`relK_realItem_succ`; `f 0 = x` is `realItem_eq_of_witness`.

The backward mirror is available although the ladder's STRUCTURAL liveness is forward-only
(`ladder-liveness-forward-only.lean`): what is mirrored here is the realized type's own `since`
equation along a history, not the `Count`-driven decrease.

## Deviations

1. **An import was added.** `LadderRealize.lean` now imports
   `FormalSystem.Metalogic.Decidability.RaySummary.LadderChain`. The phase's task list names
   `untl_mem_tpOf_iff` (`LadderAgree.lean`) as an input and the relation's `cohIdle` half needs
   `cohIdle_of_realized` (`LadderChain.lean`), but the module previously imported only
   `CounterQuotient.lean`, so neither was in scope. The import is cycle-free —
   `LadderChain → LadderPump → LadderAgree → {AnchorLayer, CounterQuotient}`, and only
   `RaySummary.lean` imports `LadderRealize` — and `check-metalogic-cycles.sh`/
   `check-module-invariants.sh` pass. The phase's `Files to modify` did not flag an import change.
2. **The "each proof cites `rk_of_count_drift` by name" grep is not literally met.** The three
   conditions cite it through `relK_realItem_succ`, the one place the `RK` edge is derived.
   Inlining the derivation three times is what the same verification item's "rather than deriving
   an `RK` edge inline" prohibits, so the intent is met and the grep's letter is not.
3. **Three generated-block files, not one**, as in Phase 12.3: the RaySummary README plus
   `FormalSystem/Metalogic/README.md` and the repository `README.md`.

## Gotcha for a successor

The project style linter rejects the `show` tactic used to change a goal up to definitional
equality. The codebase idiom is `change` (see `real_certBoxK`). A term-level
`show X from by …` inside a `rw` is a different construct and is NOT affected.

## Verification evidence

- Guarded scoped builds of `LadderRealize.lean` and of the axiom test: each exit 0 with **0
  warnings**. Full guarded `lake build`: exit 0, `Build completed successfully (2895 jobs)`, zero
  `error:`.
- `#print axioms` on all three conditions: `[propext, Classical.choice, Quot.sound]`, pinned
  under `#guard_msgs` in the axiom test, which passes. No `sorryAx`, no custom axiom, no
  `native_decide`.
- **No proof of this phase consumes the agreement or the schema**: `grep` for
  `cellAt_const_of_kappa_eq`, `CellLEZeroConstOfKappaEq` and `cellLE_zero_const_of_kappa_eq` over
  `LadderRealize.lean` returns three docstring lines only, each naming them as the input of the
  conditions the module does not carry.
- No theorem states `certStabK … (Real …)`, `real_certAdmK_of_paramsOk`, `real_subset_dmax`,
  `Dmax … ⊆ Real …` or `Dmax … = Real …`; the only `Dmax … ⊆ …` occurrence is `LadderCons`'s own
  pre-existing maximality clause. No union argument appears and no theorem claims
  `certAdmK … (Dmax …)`.
- Both fulfilment arms of `real_certBiInfK` are existential, and `Real`'s definition is
  unmodified, so it is not confined to one state's cell.
- `lean-sorry-census.sh FormalSystem Tests`: exit 0, `sorry_count: 0`. Module-scoped vacuous
  grep over `LadderRealize.lean`: 0. Repository-wide vacuous grep: 1, unchanged. `^axiom `
  counts: 10 / 2, unchanged.
- `typst-sync-check.sh`, `readme-lint.sh`, `check-evidence-probes.sh` and
  `check-task-references.sh --quiet`: each exit 0.
- `check-module-invariants.sh`: every group passes except the single pre-existing `C16`
  `unusedArguments` finding at `LadderChain.lean:2136`, "Found 1 error", unchanged in content and
  count and naming none of this phase's declarations.
- The module docstring no longer says the three conditions are NOT landed: the only `NOT landed`
  occurrence is about condition (5).
