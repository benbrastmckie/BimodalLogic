# Implementation Summary: Task #909

- **Task**: 909 - Construct the register-LOWERING deletion that would drop the equal-register hypothesis `n = n'` from `cellLE_zero_const_of_kappa_eq_of_forwardSlack` on branch 2 of the collision case split
- **Status**: [COMPLETED]
- **Started**: 2026-11-10T13:48:36Z
- **Completed**: 2026-11-10T15:05:00Z
- **Effort**: ~1h15m (plan estimate: 7h)
- **Dependencies**: None
- **Artifacts**: plans/01_register-lowering-deletion-common-shift.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The register-LOWERING exact-shift deletion is landed, and spent on exactly what the plan
scheduled it for: the COMMON-SHIFT sub-regime's DOWNWARD cell inclusion, and hence a branch-2
depth-`0` cell-EQUALITY schema that carries NO equal-register hypothesis. All five pinned
Challenge statements compile at their pinned signatures, each on the first build attempt. The
reserved name `cellLE_zero_const_of_kappa_eq` is still declared by nothing, and the saturated-gap
residue (branch 3) is untouched in both directions, as the task's SCOPE paragraph requires.

One substantive deviation is recorded loudly below and in the plan file: Phase 1's specified
internal proof spine is not implementable against the landed overshoot loop, and the pinned
statement was landed by a different, shorter internal route instead. The pinned SIGNATURE is
unchanged; the decomposition is not the plan's.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — new
  `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`: the up-first exact-shift
  deletion with the TARGET REGISTER freed. The countdown at `z` is still lowered by exactly
  `m · (P + 1)` and the object state and realized stab-free type are still held, but the register
  is delivered at a prescribed `n₀ ≤ nxtAt g z` under forward slack at `m · (P + 1) + k` where
  `n₀ + k = nxtAt g z`. At `k = 0` it is the landed held-register theorem, hypothesis for
  hypothesis. The module's `set_option linter.style.longFile` baseline was raised `2300 → 2500`
  (the module is now 2385 lines).
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — four new declarations and an
  amended module docstring:
  - `mem_cellAt_of_common_shift_of_hasForwardSlack_exact`: the downward cell membership ON THE
    WITNESSING PATH for the common shift, the deletion above at `n₀ := n`, `k := m · (P + 1)`;
  - `cellAt_subset_of_common_shift_of_pend_past_rev`: the same inclusion at the STATE level under
    `ForwardSlackWitnessed` of the higher pair at the doubled amount;
  - `CellLEZeroConstOfKappaEqCommonShiftForwardSlack`: the branch-2 depth-`0` schema, with the
    common-shift displacement in place of the equal-register hypothesis;
  - `cellLE_zero_const_of_kappa_eq_commonShift_of_forwardSlack`: that schema is a theorem at every
    tuple `ParamsOk` admits, as cell EQUALITY by `Set.Subset.antisymm`.
  - The module docstring now reads "three parts", with a FORWARD-SLACK DOWNWARD HALF section
    naming both downward/upward pairs and both depth-`0` schemas, and keeping the reserved-name
    sentence intact.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the "two routes left open"
  paragraph is replaced by a "register-lowering deletion: LANDED" paragraph plus a "route left
  open" paragraph naming only the `(K1)` AMENDMENT; the `LadderCell.lean` and `LadderChain.lean`
  Description cells carry the new declarations.
- `README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks (counts only).
- `typst/generated/status.typ` — regenerated line counts, once per Lean-touching phase.

### The construction, since it is not the plan's

The lowering is performed BEFORE the surgery, not inside it. The countdown of a ladder path is
read off its object walk (`cntAt_sub_of_pend`, `cntAt_eq_zero_of_idle`) but the REGISTER is not,
so `exists_ladderPath_of_walk_nxt_at` re-lifts `g`'s OWN walk and countdown at the anchor `n₀`.
Its single pin clause is exactly `anchor_clause_of_first_region_start` at deleted length `0` —
one inequality at the first region start above `z`'s region — which is where the `k` of the
lowering is spent, and which `HasForwardSlack g z (m · (P + 1) + k) (nxtAt g z)` supplies at `n₀`
because the two statements differ by exactly that `k`. `HasForwardSlack` then transfers to the
re-lift unchanged, because a region start's countdown is the register's value at the idle position
before it (`cntAt_eq_nxtAt_of_idle_pend`), so the regime depends on the walk and the countdown
alone. The landed held-register exact-shift theorem applies to the re-lift verbatim, and its
realized type returns to `g` through `tpOf_stabFree_eq_of_objAt_eq` on the shared walk.

## Decisions

- **The register-lowering assembly landed in `LadderChain.lean`**, as the plan decided, one file
  beyond the task's declared `file_scope`. No territory conflict: the only concurrent sibling
  (task 895, research phase) declares `AuxiliaryAtoms.lean`, `NamingRules.lean`, `Metalogic.lean`
  and `docs/theorem-index.md`.
- **It is placed AFTER the landed up-first theorem, not before it**, because the implemented route
  consumes that theorem; placing it before would be a forward reference.
- **The landed up-first proof was NOT retired to the `k = 0` instance** — that would be circular
  under the implemented route. Phase 2 closed `[COMPLETED WITH EXCLUSIONS]` with a
  `#### Reasoned Exclusions` record. The duplication Phase 2 existed to remove was never incurred:
  the reduction route added ~70 lines sharing no proof text with the landed spine, rather than the
  ~140-line near-duplicate the plan anticipated.
- **The room hypothesis is bundled into each direction's witnessing clause**, as the plan decided,
  because `m` is existentially bound by the displacement hypothesis.

## Plan Deviations

- **Phase 1, the internal proof spine** — altered, and this is the one deviation that matters.
  The plan specified building the new theorem as a copy of the landed up-first spine with the
  final `exists_deleted_ladderPath_of_pend_past_nxt` anchor lowered to `n₀`, threading the extra
  `k` through the overshoot loop's slack bookkeeping. **That is not implementable against the
  landed loop.** `exists_deleted_ladderPath_overshoot_of_pend_past` pins its slack amount to the
  shape `R * l + budget * l` at register `nxtAt g z`, in hypothesis and conclusion alike, so its
  output is `HasForwardSlack g₂ z (r * l) (nxtAt g z)` regardless of what the input carried and
  the extra `k` is destroyed. It cannot be recovered afterwards: slack transport is exact in both
  directions (`hasForwardSlack_del`, `hasForwardSlack_raise`), monotonicity in the amount and in
  the register both run the wrong way, and `k` folds into the loop's amount shape only when
  `l ∣ k`, which an arbitrary `k` does not satisfy. The two compliant alternatives were a
  ~90-line amount-general duplicate of the loop plus a ~140-line duplicate of the spine, or the
  re-lift reduction described above; the latter was taken. Per `plan-compliance.md` this is a
  decomposition deviation on a `.lean` file, raised here rather than annotated silently: statement
  fidelity is intact (the pinned signature is landed byte-for-byte, and the plan's `##
  Lean Challenge Statements` section is what that rule makes contractual), but the plan's
  specified helper routing is not followed.
- **Phase 1, declaration placement** — altered: after, not before, the landed theorem (see
  Decisions).
- **Phase 1, the `k`-threading task** — skipped: the arithmetic was confirmed and REFUTES the
  step, as above.
- **Phase 1, Scope Hypothesis** — partially refuted. Declaration count confirmed (exactly one new
  declaration; no existing declaration's signature or body touched). "Only additions" refuted by
  one line: the module's `longFile` baseline.
- **Phase 2, the whole phase** — `[COMPLETED WITH EXCLUSIONS]`, the plan's own stated fallback,
  taken for a different reason than anticipated (circularity, not binder mismatch). Two
  `#### Reasoned Exclusions` rows recorded in the plan.
- **Phase 2, `typst-sync-check.sh --fix`** — skipped: the phase makes no Lean change, so no line
  counts moved.
- **Phase 2, `lean-challenge-snapshot.sh --check`** — not run: no Challenge snapshot exists for
  this task (`specs/909_.../challenge/` is absent; the snapshot is created at plan time and this
  task's plan round did not create one). Recorded as absent rather than as a pass or a drift. Its
  verdict is advisory in any case.
- **Phase 5, the `intro` pattern** — altered: `-` is `rintro` syntax, not `intro` syntax; the
  collision hypothesis is discarded with `intro`'s `_`, which likewise creates no named local and
  draws no unused-variable finding. Each direction's clause supplies the room bound AND the
  witnessing as a conjunction, so each branch destructures it into both before
  `Set.Subset.antisymm`.
- **Phase 5, the module-docstring wording** — altered: "three parts", not "three halves".

## Verification

- Build: Success. Full-project guarded `lake build`, exit 0, 2970 jobs, zero `error:` lines. Run
  at the end of every phase, not only at the end.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; empty inventory).
- Vacuous count: 0 attributable to this task. The single-line vacuous grep returns one
  pre-existing hit, `FormalSystem/Examples/TemporalStructures.lean:495`'s
  `int_domain_universal ... := trivial`, present at this task's base commit `903830817` and last
  touched 2026-10-14. It is not a vacuity defect: `intTimeHistory.domain t` reduces to `True` by
  definition, so `trivial` is the honest proof.
- Axiom count: 14, byte-identical to the count at base commit `903830817`. No increase.
- `lean_verify` on all five new declarations: `[propext, Classical.choice, Quot.sound]`,
  `trust: standard`, no non-standard axiom, no `sorryAx`.
- `bash scripts/check-module-invariants.sh`: exit 0, every constraint C1-C37 PASS, including C1
  (build), C2/C14 (recorded axiom baselines), C16 (env-linter batch, no un-nolisted finding),
  C34a/C34b (marker honesty), the inventory check and the doc-count checks. No new
  `scripts/nolints.json` row was needed.
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: exit 0.
- `bash scripts/typst-sync-check.sh` (full): PASS, all 4 checks green. `--counts-only` green
  before every Lean-touching commit.
- Reserved name: `grep -rn "cellLE_zero_const_of_kappa_eq\b" FormalSystem/` returns 10 hits,
  every one inside a docstring or a README paragraph. Declared by nothing.
- Tests: N/A — this repository's Lean-tree gate is `check-module-invariants.sh` (C1 runs the
  build), and no separate Lean test suite covers these modules.
- Files verified: Yes.
- **Scoped verification tier, per this dispatch's Batch Gate Deferral directive.** Phase 5's
  declared `**Verification Tier**: full` was discharged against a SCOPED tier: the complete gate
  set was not independently run here and runs once for the whole batch at the end of the
  invocation, attributed back by `modified_files`. The narrowing invocation actually covering this
  phase's files is the Lean-tree gate above. `verify-deploy.sh` and `tests/run-all.sh` were
  deliberately not run: every file this task touched is Lean source, a `FormalSystem`/root README,
  a generated Typst status file or a `specs/` artifact — none lives under `.claude/**` or
  `agent-system/**`, so no gate or suite in either harness can produce a finding attributable to
  this task. The dispatch context's recorded deploy staleness (core, lean, literature, memory,
  typst) is pre-existing and was NOT remedied here; no file under `.claude/**` was hand-patched.

## Impacts

- The common-shift sub-regime of a `kappa`-collision is now closed in BOTH directions at the cell
  level, under the forward-slack witnessing of the higher pair at the doubled amount. Branch 2 of
  `kappa_collision_regimes` therefore carries a depth-`0` cell-EQUALITY schema with no
  equal-register restriction, where before only the equal-register slice had one.
- A consumer of the branch-2 schema must supply more than the equal-register one asks: the room
  bound `n + (m · (P + 1) + m · (P + 1)) ≤ c` and the witnessing at the DOUBLED amount
  `m · (P + 1) + m · (P + 1)`, not at `m · (P + 1)`. Neither is implied by the pending-forever
  gap, and the room bound is vacuous at `m = 0` where the gap is not.
- `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past` is available to any later
  consumer needing a prescribed register at the compared position, not only to the common shift.
  Its price is one anchor inequality's worth of extra forward slack per unit of lowering.
- `HasForwardSlack`'s necessity is untouched: nothing here weakens it, states a state-level
  per-path regime, or bears on `ClimbWitness.hasForwardSlack_refuted_unconditional`.
- The reserved schema `CellLEZeroConstOfKappaEq` is still neither proved nor refuted, and the new
  schema — strictly stronger in hypotheses — bears on its truth value in neither direction.

## Follow-ups

- The SATURATED-GAP RESIDUE (branch 3 of `kappa_collision_regimes`) is untouched and is owned by a
  sibling follow-up, as this task's SCOPE paragraph states. On that branch the register must move
  by an amount the countdown does not match, and no amount of forward slack addresses it; the
  compiled record is `kappa_collision_two_regimes_refuted_of_pend_gap`.
- The `(K1)` AMENDMENT route is still open and is now the only route the `RaySummary/README.md`
  record names as open.
- `exists_deleted_ladderPath_overshoot_of_pend_past`'s slack amount could be generalized from the
  pinned `R * l + budget * l` to a free `L` with `R * l + budget * l ≤ L` (the step lemma
  `exists_deleted_ladderPath_step_of_pend_past` already has the free-`L` shape). That would make
  the plan's originally specified Phase 1 spine implementable, and would let the landed up-first
  theorem be retired to a `k = 0` instance after all. It is NOT needed for anything landed here,
  and would cost a fresh induction rather than a reduction — recorded as an option, not a debt.
- No Challenge snapshot exists for this task, so `lean-challenge-snapshot.sh --check` has no
  baseline to compare the five landed signatures against. A future round wanting that mechanical
  check would need the snapshot created at plan time.

## References

- `specs/909_register_lowering_deletion_drop_equal_register/plans/01_register-lowering-deletion-common-shift.md`
  — the plan, with per-phase status markers, inline deviation annotations, Phase 2's
  `#### Reasoned Exclusions` record and Phase 5's verification outcome.
- `specs/909_register_lowering_deletion_drop_equal_register/issues.jsonl` — the issue/win log for
  this dispatch, including the plan-divergence entry for Phase 1's spine.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the durable record: the
  register-lowering route is landed for branch 2 and still does not reach the saturated residue.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`,
  `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — the five new declarations.
