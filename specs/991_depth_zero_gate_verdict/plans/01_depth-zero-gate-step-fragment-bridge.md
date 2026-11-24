# Implementation Plan: Task #991

- **Task**: 991 - Depth-0 gate verdict: enter the step-fragment bridge and land `CellLEZeroConstOfKappaEq` restricted to `StepFrag`
- **Status**: [IMPLEMENTING]
- **Effort**: 9.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/991_depth_zero_gate_verdict/reports/01_depth-zero-gate-verdict.md`
- **Artifacts**: plans/01_depth-zero-gate-step-fragment-bridge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research dispatch measured that neither of the gate's two filed lifting events is deliverable
and that the recorded crux (`ForwardSlackWitnessed` satisfiability) cannot decide the gate. The
settled route is the step-fragment bridge: discharge the four numeric hypotheses of
`Zrel_of_kappa_eq` from `ParamsOk`, so that the landed engine
`cellAt_const_of_kappa_eq_stepFrag` yields `CellLEZeroConstOfKappaEq` restricted to `StepFrag φ`
as a `sorryAx`-free theorem under its own name, leaving the reserved name
`cellLE_zero_const_of_kappa_eq` claimed by nothing.

Two of the four hypotheses are threshold inequalities that nothing in the tree supplies; one is
one token short of what `(K4)` gives; one is already satisfied. The plan therefore runs
threshold-feasibility first (a go/no-go, before any library edit), then lands the two threshold
discharges, then repairs `(K4)`'s forward conjunct together with every landed record that repair
falsifies, then promotes the bridge and lands the schema, then reconciles the CI-gated wired
probes and generated surfaces, and finally re-sites the gate's crux in-source on the measured
residue.

### Research Integration

Five findings from the report are load-bearing and are not re-derived here:

- **F8** fixes the deficit exactly: `2 * dBack φ ≤ B` is satisfied by `paramsOkK4`'s
  `2 * dBack φ + 1 ≤ B`; `2 * dFwd φ + 2 ≤ B` is ONE SHORT of `paramsOkK4`'s
  `2 * dFwd φ + 1 ≤ B` (measured at `Bof` itself by the draft probe's
  `paramsOkK4_one_short_of_Zrel_forward_arm`); `2 * (dBack φ + dFwd φ) ≤ Tc` and `≤ Tn` are owed
  by `LadderStepFrag.lean`'s own module docstring, point 3.
- **F7** rules out the refutation direction at depth `0`: every compiled separating family
  (`thetaC`, `sigC b`, `mixC a k`, `dblC j`) is `diaF`- or `.stab`-rooted and so fails the schema's
  stab-free hypothesis. No refutation phase is planned, and none may be substituted for the
  positive route.
- **F6** records that the stale clause in `forwardSlackWitnessed_iff_next_region_cnt_le`'s
  docstring is corrected in one direction by `cellAt_subset_of_window_raise`; Phase 6 repairs it.
- **F9** names the residue the gate should be re-sited on: stab-free formulas carrying an
  UNBOUNDED `U`/`S` jump. Phase 6 records it in-source.
- The report's first Risk — that the `(K4)` repair collides with landed declarations and that a
  plan "must name this collision as a phase, not discover it mid-proof" — is discharged by Phase 3,
  whose collision set was enumerated at authoring time (see that phase's Scope Hypothesis).

Four facts this plan establishes beyond the report, each read directly from the tree at authoring
time, so the implementer does not re-derive them:

1. **No new module and no new import are needed for the deliverable.** `LadderAgree` IS in
   `LadderStepFrag`'s import closure, via `LadderStepFrag -> LadderRealize -> LadderChain ->
   LadderPump -> LadderAgree`. `CellLEZeroConstOfKappaEq` and `kappa_eq_components`
   (`LadderAgree.lean:902`) are therefore already visible in `LadderStepFrag.lean`, which also
   already consumes `ParamsOk` (`Mrel.threshold_le_Tc`, `objHalfK1_of_paramsOk`). No
   `check-metalogic-cycles.sh` allowlist extension and no `lake exe mk_all` run are in scope.
2. **The engine's conclusion is token-for-token the schema's body.**
   `cellAt_const_of_kappa_eq_stepFrag`'s conclusion is the diagonal
   `cellAt M φ ((z, x)) z = cellAt M φ ((z, y)) z`, which is exactly
   `CellLEZeroConstOfKappaEq`'s own conclusion; the def's "world state is diagonal" caveat is a
   caveat about the FILED `cellAt_const_of_kappa_eq`, not about this schema. No time-component
   transport (`cellAt_const_of_kappa_eq_stepFrag_at_time`) is needed.
3. **`CellLEZeroConstOfKappaEq`'s section carries `[Fintype Q] [Nonempty Q]`**
   (`LadderAgree.lean:3312`), so `1 <= Fintype.card Q` is available to the threshold discharge
   without a local `Nonempty` construction.
4. **The threshold route is `(K3)`, not `(K2)`.** `paramsOkK3`'s second conjunct is
   `2 * tShort Q φ + tIdle pend + 2 <= Tc` with `tShort Q φ = Fintype.card (ProdState Q φ)`, and
   `card_prodState` (`LadderChain.lean:178`) reads that as `Fintype.card Q * 2 ^
   (plusSubformulaClosure φ).card`. `paramsOkK3`'s first conjunct `Tc + 2 * ell0 <= Tn + 1` carries
   the same bound to `Tn`. `(K2)`'s margin arm is NOT used: it is `0` when `Fintype.card Q = 0` and
   buys nothing the `(K3)` arm does not.

### Prior Plan Reference

No prior plan exists for this task. The gate's rest-state record
(`specs/761_ladder_realization_theorem/plans/13_depth-zero-gate-rest-state.md`, 30 of 41 phases
closed with zero enterable) was read by the research dispatch and is the reason this task exists;
no phase of it is copied here. Its calibration lesson is taken: a phase whose entry condition is
an unmeasured parameter inequality is not enterable, which is why Phase 1 measures before any
library edit is made.

### Roadmap Alignment

`roadmap_flag` is not set on this dispatch, so no roadmap-review or roadmap-regenerate phase is
planned. Roadmap context was read read-only: `specs/ROADMAP.md` Stage 0 Batch 1 records this task
as the owner of the depth-`0` gate, and milestone M7's ladder band (task 761, `[PARTIAL]`) is
parked on its verdict. `specs/ROADMAP.md` carries a `do not edit` generator banner and is rendered
from `specs/state.json`; the crux re-siting named by the settled route is therefore recorded by
Phase 6 as an in-source change plus a follow-up for `/roadmap`, which owns the
`roadmap_milestones`/`roadmap_context` entries the file renders from. This plan writes no roadmap
entry.

## Goals & Non-Goals

**Goals**:

- `dBack_add_dFwd_le_closure_card` -- the pure-syntax bound of the two exactness depths by the
  closure's cardinality, the one new mathematical content the threshold discharge needs.
- `paramsOk_two_depth_sum_le_Tc`, `paramsOk_two_depth_sum_le_Tn` -- the two owed threshold
  inequalities, discharged from `ParamsOk` at generic parameters.
- `Zrel_of_kappa_eq` -- the counter-class-to-`Zrel` bridge, promoted verbatim from the wired
  step-fragment probe into the library.
- `cellLE_zero_const_of_kappa_eq_stepFrag` -- the deliverable: `CellLEZeroConstOfKappaEq`
  restricted to `StepFrag φ`, `sorryAx`-free, under its own name.

**Non-Goals**:

- The reserved name `cellLE_zero_const_of_kappa_eq` stays claimed by nothing. No declaration this
  plan lands carries it, and Phase 6 verifies its absence by an exact-name sweep.
- No work on `ForwardSlackWitnessed`, in either its per-path or its existential-over-paths form.
  F2/F4/F5 measure that a full discharge of that crux would leave the gate where it is; re-entering
  it is forbidden by this plan, not merely deprioritized.
- No new separating family and no refutation attempt at depth `0` (F7).
- The residue -- stab-free formulas carrying an unbounded `U`/`S` jump -- is NAMED and re-sited,
  not attacked. No `Srel`/`Mrel` path-forth and no row-link discharge is in scope.
- No edit to `specs/ROADMAP.md` or to `specs/state.json`'s roadmap entries.
- No restatement of the ladder realization theorem's own plan record (task 761); that is its own
  task, unparked by this verdict.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `dBack φ + dFwd φ <= (plusSubformulaClosure φ).card` is harder than it looks: the `snce`/`untl` cases need `snce α β ∉ subformulas α ∪ subformulas β`, and `Subformulas.lean` carries no size/no-self-containment lemma | H | M | Phase 1 is a task-local compiled probe with no library edit; its named fallback decomposition is the two disjoint filters (`snce`-rooted and `untl`-rooted closure members). A genuine failure there is `[BLOCKED]` BEFORE any `(K4)` edit, which is why Phase 1 precedes Phase 3 |
| The `(K4)` repair FALSIFIES two landed library theorems and one test `example` (not merely breaks their proofs): `ParamsOk ... thetaC ... 3` becomes false because `2 * dFwd thetaC + 2 = 4 > 3` | H | H (certain) | Phase 3 is a single `atomic-batch`: the repair and the restatement of every record it falsifies land in one commit. The restatement route is the frozen-pre-repair-copy pattern this tree already used for the FIRST `(K4)` repair (`paramsOkK4Pre`/`ParamsOkPre` in `ladder-cell-obligation-refutation.lean`, with `not_paramsOkK4_two` as the companion rejection record) |
| A wired evidence probe rots on the `(K4)`/`Bof` change. `check-evidence-probes.sh` is CI-gated and governed by a no-weakening rule; `Bof` is read 27 times in `ladder-cell-agreement-refutation.lean`, 9 in `ladder-chain-object-clip-refutation.lean`, 8 in `ladder-cell-obligation-refutation.lean` | M | M | Phase 5 owns probe reconciliation as named work, repairing citations under the no-weakening rule only -- never restating or deleting an obstruction to make it pass. `repaired_clip_refuted` is stated at the STRONGER `BRep = 2*(dBack+dFwd)+2` and so is unaffected in direction by this weaker repair |
| `typst/generated/status.typ`'s `formalsystem-line-count`, `tests-line-count`, `axiom-count` and `sorry-total` all move, and `.githooks/pre-commit` BLOCKS the commit of the phase that moved them | M | H (certain) | Every Lean-touching phase carries `typst/generated/status.typ` in its own file list and runs `bash scripts/typst-sync-check.sh --fix` in the same phase, never deferred to Phase 5 (gate-collision Condition 1: this surface cannot wait) |
| `LadderStepFrag.lean` sits at 1695 lines against `set_option linter.style.longFile 1700`; the linter's accepted set is `{candidate - 100, candidate}` for `candidate = max(1500, (lines / 100) * 100 + 200)`, so ANY addition of 5 or more lines invalidates the declared `1700` | M | H (certain) | Phase 4 owns the incremental re-tightening to its own final `candidate` as named phase work (gate-collision Condition 7), computed from the file's post-edit line count rather than guessed |
| A pinned Challenge signature whose hypothesis the proof does not read trips the batch `unusedArguments` env-linter, and `lake exe runLinter --update` would rewrite the whole ledger | L | L | `step`/`lab`/`Tn`/`B` all appear in the `hp : ParamsOk ...` binder's TYPE in both threshold lemmas, so no finding is expected. If one fires anyway, the pre-authorized remedy is a hand-inserted four-line row in `scripts/nolints.json` next to an existing exemption of the same shape -- never `runLinter --update`, never a `set_option` for this category (gate-collision Condition 10) |
| CI builds with `--wfail`, so any linter WARNING is a failure | M | M | No `show`-for-definitional-equality is used in any new proof; the promoted `Zrel_of_kappa_eq` body's existing `show` lines are goal-statement annotations, which is the sanctioned use. Treat warning and error as identical when judging a phase green (Condition 8) |
| `check-module-invariants.sh` C15 requires a `Paper:` line on every theorem-index-registered declaration, and C26 forbids a non-trailing underscore in a live `def`/`abbrev` name | L | M | Phase 3's and Phase 4's new `def`s (`paramsOkK4Pre`, `ParamsOkPre`) are lowerCamelCase/UpperCamelCase with no interior underscore, matching `paramsOkK4`'s own shape; every new theorem that earns a `docs/theorem-index.md` row gets a `Paper:` line in the same phase that adds the row |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

The chain is genuinely linear: Phase 2 may not land a library lemma Phase 1 has not shown
provable; Phase 3's repair is only worth making once the thresholds are in hand; Phase 4's proof
consumes Phase 3's repaired `(K4)`; Phase 5 reconciles surfaces only Phases 2-4 can have moved;
Phase 6 records a residue only Phase 4 can have delimited. No two phases may be run in parallel,
and Phases 2, 3 and 4 additionally share file territory (`CounterQuotient.lean`,
`LadderStepFrag.lean`, `typst/generated/status.typ`).

---

### Phase 1: Threshold feasibility -- the go/no-go, before any library edit [COMPLETED]

**Goal**: Establish by compilation, in a task-local probe that no library target imports, that
`2 * (dBack φ + dFwd φ) <= Tc` and `2 * (dBack φ + dFwd φ) <= Tn` follow from `ParamsOk` at
generic parameters. A negative answer here ends the route before `(K4)` is touched.

**Tasks**:

- [x] Create `specs/991_depth_zero_gate_verdict/probe-draft/threshold-depth-sum.lean`, importing
      `FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag` and opening the same
      namespaces as the existing draft probe `probe-draft/ordinary-window-regime.lean`.
- [x] Prove the pure-syntax bound `dBack φ + dFwd φ <= (plusSubformulaClosure φ).card` by
      structural induction on `φ`. The named decomposition, to be followed rather than re-derived:
      bound `dBack` and `dFwd` SEPARATELY by the cardinalities of two DISJOINT filters of the
      closure -- the `snce`-rooted members and the `untl`-rooted members -- then sum, using that a
      `snce`-rooted formula and an `untl`-rooted formula are never equal.
- [x] In the `snce α β` and `untl α β` cases the `+ 1` needs `snce α β ∉ subformulas α ∪
      subformulas β`. `FormalSystem/PlusLanguage/Subformulas.lean` carries `self_mem_subformulas`,
      the eight constructor-membership lemmas and `subformulas_trans`, but NO size or
      no-self-containment lemma; prove the missing step as a local helper in the probe
      (`sizeOf`-monotonicity along `subformulas`, by induction, closed by `simp` + `omega`).
- [x] Chain to the threshold: with `q : Q` giving `1 <= Fintype.card Q`, derive
      `dBack φ + dFwd φ <= Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card` via `k <= 2 ^ k`
      (`Nat.lt_two_pow_self`) and `Nat.le_mul_of_pos_left`, then rewrite by `card_prodState` to
      reach `tShort Q φ` and consume `paramsOkK3`'s second conjunct
      `2 * tShort Q φ + tIdle pend + 2 <= Tc`.
- [x] Derive the `Tn` form from `paramsOkK3`'s first conjunct `Tc + 2 * ell0 Q φ <= Tn + 1`
      together with `1 <= tIdle pend` (`tIdle` is a card plus one), which leaves the needed slack
      of two above `2 * tShort`.
- [x] Add `#print axioms` lines for every declaration in the probe and confirm no `sorryAx`.
- [ ] If the pure-syntax bound genuinely cannot be proved as written: mark this phase `[BLOCKED]`, *(not triggered: the bound compiled)*
      record what was tried and the goal state reached, and STOP. Do not substitute a
      fixpoint-parameter-only (`Tcof`/`Tnof`) discharge -- it reduces to the same inequality
      through `Tcof`'s own `max` arm and buys nothing -- and do not weaken the schema's parameter
      quantification.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: the phase writes one task-local `.lean` file under `specs/` that no Lake
target root reaches, so
`bash .claude/scripts/lake-build-guard.sh build --timeout 540 -- env lean <probe>` at exit `0`
plus its own `#print axioms` lines is the complete covering check for everything the phase changed.

**Scope Hypothesis**: the two threshold inequalities are provable from `ParamsOk` through
`paramsOkK3`'s two conjuncts and a new depth-vs-closure-card bound. This is a hypothesis, not a
fact -- the research did not compile it and recorded that `Tcof` is a `max` of several arms with
nothing obviously dominating a depth sum. The implementer confirms it by compiling the probe to
exit `0` with no `sorryAx`, and on failure returns `[BLOCKED]` per the last task above rather than
proceeding to Phase 2.

**Files to modify**:

- `specs/991_depth_zero_gate_verdict/probe-draft/threshold-depth-sum.lean` - new task-local probe
  carrying the depth bound, the two threshold discharges and their `#print axioms` lines.

**Verification**:

- The probe compiles at exit `0` through `lake-build-guard.sh`, with no `sorry` and no
  `native_decide` in the file.
- Every `#print axioms` line reports a profile free of `sorryAx`.
- Before committing: `bash scripts/typst-sync-check.sh --counts-only` is run because the staged set
  touches a `.lean` path; if it reports drift, `--fix` is run and
  `typst/generated/status.typ` is staged with the probe.

---

### Phase 2: Land the two threshold discharges in the library [COMPLETED]

**Goal**: Move Phase 1's compiled content into the library at its correct sites, so that `ParamsOk`
supplies `hTc` and `hTn` of `cellAt_const_of_kappa_eq_stepFrag` for every consumer, not only inside
a probe.

**Tasks**:

- [x] Add `dBack_add_dFwd_le_closure_card` (and whatever helper lemmas Phase 1 proved it needs) to
      `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`, immediately after
      `dFwd`'s definition -- the site where both depths and `plusSubformulaClosure` are already in
      scope and where no new import is required.
- [x] Add `paramsOk_two_depth_sum_le_Tc` and `paramsOk_two_depth_sum_le_Tn` to
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`, in the section that
      already consumes `ParamsOk` (alongside `Mrel.threshold_le_Tc` and `objHalfK1_of_paramsOk`).
      They are sited there, not in `CounterQuotient.lean`, because `card_prodState` lives in
      `LadderChain.lean`, which `CounterQuotient.lean` does not import.
- [x] Give each new declaration a docstring in the module's voice, stating what it buys and which
      `ParamsOk` conjunct it consumes. If a declaration earns a `docs/theorem-index.md` row, add the
      `Paper:` line in this phase (C15).
- [x] Recompute `LadderStepFrag.lean`'s `longFile` baseline if this phase's additions take it to *(done: 1753 lines post-edit, baseline 1700 -> 1800)*
      1700 lines or more: `candidate = max(1500, (lines / 100) * 100 + 200)` from the POST-edit line
      count, and the declared value must be `candidate` or `candidate - 100`.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` in the
      same commit as the Lean edits.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: the edits are purely additive lemmas introducing no signature change to any
existing declaration, so
`lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
is the covering check -- it recompiles every module above `CounterQuotient.lean` in the aggregate's
closure, which is the whole set of consumers an additive lemma can reach.

**Scope Hypothesis**: exactly two library files carry new content in this phase
(`CounterQuotient.lean`, `LadderStepFrag.lean`) plus the one generated surface. The implementer
confirms by `git status --short` before committing; a third Lean file appearing means a helper was
sited elsewhere than planned and is recorded as a deviation rather than committed silently.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - add
  `dBack_add_dFwd_le_closure_card` and its helpers after `dFwd`; 1305 lines today, so the 1500-line
  `longFile` default is not reached by this phase.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` - add
  `paramsOk_two_depth_sum_le_Tc` and `_le_Tn`; re-tighten `set_option linter.style.longFile` if the
  file reaches 1700 lines.
- `typst/generated/status.typ` - regenerate `formalsystem-line-count` and the axiom/sorry counts
  this phase moves (gate-collision Condition 1, surface (b), which is commit-blocking and may not
  be deferred).

**Verification**:

- `lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
  at exit `0`.
- `lean_verify` (or `#print axioms`) on each of the three new declarations shows no `sorryAx`.
- `bash scripts/typst-sync-check.sh --counts-only` reports no drift after `--fix`.
- Each touched file passes `bash scripts/check-module-invariants.sh` individually; any finding that
  names only a file outside this phase's list is a recorded pre-existing baseline finding, not a
  blocker (gate-collision Condition 4).

---

### Phase 3: Repair `(K4)`'s forward conjunct and restate every record it falsifies [COMPLETED]

**Goal**: Change `paramsOkK4`'s forward conjunct from `2 * dFwd φ + 1 <= B` to
`2 * dFwd φ + 2 <= B` and `Bof`'s middle arm to match, and land -- in the SAME commit -- the
restatement of the two library theorems and the one test `example` that the repair makes false,
plus the companion record that the repaired `(K4)` rejects the previously-refuting clip.

**Tasks**:

- [x] In `CounterQuotient.lean`, repair `paramsOkK4` to
      `2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 2 ≤ B ∧ 2 ≤ B` and `Bof` to
      `max (2 * dBack φ + 1) (max (2 * dFwd φ + 2) 2)`. Update both docstrings to state the forward
      arm's new value and WHY it is `+ 2`: `LadderStepFrag.lean`'s module docstring point 2 derives
      `G⁻ = 2b + 2` as the solution of the one-step closure conditions, so the asymmetry is forced
      on the `Zrel` side and `(K4)` is the side that was short.
- [x] Repair `paramsOk_params`'s three `(K4)` arms *(deviation: altered -- no textual change was needed; the three arms are generic `le_max_*` terms that read `Bof`'s repaired middle arm automatically, confirmed by the unscoped build)* (they are `le_max_*` terms; the middle arm now
      reads the `+ 2` value from `Bof`'s own middle arm).
- [x] Add the frozen pre-repair copies to `CounterQuotient.lean`, next to the repaired predicates *(deviation: altered -- `paramsOkPre_params` is stated at the fourth output written OUT as the pre-repair `Bof` body `max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)` rather than at `Bof`, which after the repair is a different value and would not discharge the two restated theorems' written clip)*:
      `paramsOkK4Pre φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`, `ParamsOkPre` as
      `ParamsOk` with `(K4)` replaced by it, and `paramsOkPre_params` discharging it at the
      fixpoint's own four outputs. Docstring each as a FROZEN record of the pre-repair conjunct,
      naming the precedent: `ladder-cell-obligation-refutation.lean`'s `paramsOkK4Pre`/`ParamsOkPre`
      froze the previous `(K4)` the same way when `dFwd` was first added.
- [x] In `LadderRealize.lean`, restate `exists_kappa_collision_cellAt_ne_at_K4_clip` as
      `exists_kappa_collision_cellAt_ne_at_K4_clip_pre`: the written clip
      `max (2 * dBack phi + 1) (max (2 * dFwd phi + 1) 2)` is UNCHANGED and the proof body is
      unchanged except that the `ParamsOk` conjunct becomes `ParamsOkPre` and its discharge becomes
      `paramsOkPre_params`. Do not change the clip to the repaired value: at the repaired clip `4`,
      `kappa_collision_theta` is pinned at clip `3` and the separation is not established there.
- [x] Restate `exists_paramsOk_real_not_certAdmK` the same way, as
      `exists_paramsOkPre_real_not_certAdmK`.
- [x] Add, inside or under `open K4ClipWitness in`, the companion rejection record
      `not_paramsOkK4_thetaC_clip : ¬ paramsOkK4 thetaC 3` -- the exact analogue of
      `ladder-cell-obligation-refutation.lean`'s `not_paramsOkK4_two`, recording that the repaired
      `(K4)` rejects the clip at which the refutation was read.
- [x] Update both restated theorems' docstrings so that neither still claims its clip is "the least
      clip `paramsOkK4` admits and the value `Bof` outputs" -- after the repair it is neither.
      State instead that it is the least clip the PRE-REPAIR `(K4)` admitted, cite
      `not_paramsOkK4_thetaC_clip`, and cross-reference the wired probe's `repaired_clip_refuted`
      (stated at the strictly stronger `BRep = 2 * (dBack + dFwd) + 2`, with the `diaF`-rooted
      `dblC j`) as the record that a clip repair does not rescue the general agreement -- as a path
      citation, not a proof term.
- [x] Update `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: the "THE RESTRICTION CHECK"
      `example` restates the same existential and must follow the restatement, and the
      `#guard_msgs`-wrapped `#print axioms` block naming `exists_paramsOk_real_not_certAdmK` must
      follow the rename.
- [x] Update the `docs/theorem-index.md` rows that name the renamed theorems and quote the clip
      wording (rows at lines 282, 279 and 281 name `exists_kappa_collision_cellAt_ne_at_K4_clip`;
      the prose at lines 286 and 302 names it again).
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Tier Justification**: `paramsOkK4` and `Bof` are definitions every `ParamsOk` consumer in the tree
reads, and the repair changes the TRUTH VALUE of two landed theorems rather than only their proofs,
so the covering check is the unscoped
`lake-build-guard.sh build --timeout 1800 -- build` plus the `Tests` target -- no module-scoped
build reaches the test file's `#guard_msgs` prints.

**Scope Hypothesis**: the repair's falsification set is exactly three declarations --
`exists_kappa_collision_cellAt_ne_at_K4_clip` (`LadderRealize.lean:2135`),
`exists_paramsOk_real_not_certAdmK` (`LadderRealize.lean:2256`) and the "THE RESTRICTION CHECK"
`example` (`KTypeSummaryAxiomTest.lean:3662`) -- all three identified by their shared discharge
`paramsOk_params stepC pendC labC thetaC` against a written clip of `3`, at which the repaired
forward conjunct demands `4`. The implementer CONFIRMS this by the unscoped build: any further
declaration that goes red is appended to this batch rather than worked around, and is recorded. The
batch is declared atomic because the tree is legitimately RED between the repair and the
restatement; no intermediate per-file state of this phase is committable on its own.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - repair `paramsOkK4` and
  `Bof`; repair `paramsOk_params`'s `(K4)` arms; add `paramsOkK4Pre`, `ParamsOkPre`,
  `paramsOkPre_params`. *(deviation: altered -- the frozen copies plus the two repaired docstrings
  take the file to 1548 lines, over the package-wide 1500 `longFile` default, so a
  `set_option linter.style.longFile 1600` baseline was added in the module's voice; the
  gate-collision Condition 7 remedy, same mechanism `LadderStepFrag.lean` already carries.)*
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - restate the two refutation
  theorems against the frozen copy; add `not_paramsOkK4_thetaC_clip`; update both docstrings.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - follow the restatement in the
  restriction-check `example` and the `#guard_msgs` axiom print.
- `docs/theorem-index.md` - update the rows and prose naming the renamed theorems and the clip
  wording.
- `typst/generated/status.typ` - regenerate; this phase moves `formalsystem-line-count` AND
  `tests-line-count`.

**Verification**:

- `lake-build-guard.sh build --timeout 1800 -- build` at exit `0` (unscoped: the repair reaches
  every `ParamsOk` consumer).
- The `Tests` target builds and every `#guard_msgs` block in `KTypeSummaryAxiomTest.lean` matches.
- `not_paramsOkK4_thetaC_clip` compiles and is `sorryAx`-free, and
  `paramsOkPre_params` discharges the frozen copy at the fixpoint's four outputs.
- An exact-name sweep confirms the two pre-repair theorem names no longer appear as declarations
  anywhere under `FormalSystem/` or `Tests/` while their `_pre`-suffixed restatements do. Use exact
  names, never a `^theorem exists_kappa_collision` prefix anchor -- the evidence tree deliberately
  retains sibling names (gate-collision Condition 3).
- `bash scripts/typst-sync-check.sh --counts-only` reports no drift.

---

### Phase 4: Promote the bridge and land the `StepFrag`-restricted schema [NOT STARTED]

**Goal**: Land `Zrel_of_kappa_eq` in the library and, from it, `cellLE_zero_const_of_kappa_eq_stepFrag`
-- `CellLEZeroConstOfKappaEq` restricted to `StepFrag φ`, `sorryAx`-free, under its own name.

**Tasks**:

- [ ] Promote `Zrel_of_kappa_eq` from
      `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean:731` into
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`, VERBATIM in statement
      and body -- its `kappa_eq_components` call resolves against `LadderAgree.lean:902`, which is in
      this module's import closure. Keep the `omit` of the unused instances if the target section
      carries them.
- [ ] Add `cellAt_const_of_kappa_eq_stepFrag` to the same module, promoted verbatim from the probe
      at `:754`, as the composition of `cellAt_eq_of_Zrel` (already landed at `LadderStepFrag.lean:1005`)
      with `Zrel_of_kappa_eq`.
- [ ] Land `cellLE_zero_const_of_kappa_eq_stepFrag` in the same module: `intro` the schema's
      `ParamsOk` and stab-free hypotheses (the stab-free one is UNUSED -- `StepFrag` leaves `⊡`
      unrestricted -- so bind it as `_`), then `intro` the counter data and apply
      `cellAt_const_of_kappa_eq_stepFrag` with `hTc`/`hTn` from Phase 2's two discharges, `hBa` from
      `paramsOkK4`'s backward conjunct and `hBb` from Phase 3's repaired forward conjunct.
- [ ] The declaration MUST be the full schema, not a restatement of its body: its conclusion is
      `CellLEZeroConstOfKappaEq step pend fwd bwd lab φ Tc Tn P B`, with `StepFrag φ` as the single
      added hypothesis. Do not add a regime, threshold, displacement-shape, room or forward-slack
      hypothesis; do not specialise `Tc`/`Tn`/`P`/`B` to the fixpoint's outputs. Any of those is the
      statement-fidelity defect `plan-compliance.md` forbids -- escalate as `[BLOCKED]` instead.
- [ ] Give it a docstring in the module's voice that states exactly what it is and is NOT: it
      discharges the reserved schema on the step fragment (`⊡` and `□` unrestricted, `untl`/`snce`
      admitted only at guard `⊥`), it leaves the reserved name `cellLE_zero_const_of_kappa_eq`
      claimed by nothing, and the residue is stab-free formulas carrying an unbounded `U`/`S` jump.
      Include its `Paper:` line (C15).
- [ ] Re-tighten `set_option linter.style.longFile` in `LadderStepFrag.lean` to this phase's own
      `candidate = max(1500, (lines / 100) * 100 + 200)` computed from the POST-edit line count,
      accepting only `candidate` or `candidate - 100` (gate-collision Condition 7). An early bump to
      a larger eventual value is itself a new warning, and under `--wfail` a failure.
- [ ] Add the `docs/theorem-index.md` row for the deliverable, stating in the row's own "What it is
      not" idiom that the filed `cellLE_zero_const_of_kappa_eq` remains carried by no declaration.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: every edit is additive and confined to one module near the top of the import
DAG -- only `RaySummary.lean` and `KTypeSummaryAxiomTest.lean` import `LadderStepFrag` -- so
`lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
plus `lean_verify` on the three new declarations covers the full reach of what changed.

**Scope Hypothesis**: the deliverable needs no new import, no new module and no time-component
transport, because `LadderAgree` is already in `LadderStepFrag`'s import closure (via `LadderPump`)
and the engine's conclusion is already the schema's diagonal shape. The implementer confirms the
first half with a `#check CellLEZeroConstOfKappaEq` in the module before writing the proof, and the
second by the proof closing without a `cellAt_ladder_eq_of_worldTime` step. If either fails, the
fallback is a new module importing both `LadderAgree` and `LadderStepFrag`, which additionally owes
`lake exe mk_all --lib FormalSystem` (C33), a module-inventory regeneration and a
`check-metalogic-cycles.sh` allowlist check -- recorded as a deviation, not absorbed silently.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` - add `Zrel_of_kappa_eq`,
  `cellAt_const_of_kappa_eq_stepFrag` and `cellLE_zero_const_of_kappa_eq_stepFrag`; re-tighten the
  `longFile` baseline.
- `docs/theorem-index.md` - add the deliverable's row with its `Paper:`-backed docstring.
- `typst/generated/status.typ` - regenerate.

**Verification**:

- `lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary`
  at exit `0`.
- `lean_verify FormalSystem.Metalogic.Decidability.RaySummary.cellLE_zero_const_of_kappa_eq_stepFrag`
  reports an axiom profile free of `sorryAx` (and free of `Lean.ofReduceBool`/`native_decide`).
- The landed signature matches this plan's `## Lean Challenge Statements` block token for token for
  all five pinned identifiers.
- An EXACT-name sweep over `FormalSystem/` and `Tests/` for `cellLE_zero_const_of_kappa_eq` as a
  declaration name returns nothing: the reserved name stays unclaimed. The sweep uses the exact
  name, not a prefix anchor, which would capture the new `_stepFrag` sibling (Condition 3).
- `bash scripts/typst-sync-check.sh --counts-only` reports no drift.

---

### Phase 5: Reconcile the wired probes and the generated surfaces [NOT STARTED]

**Goal**: Bring every CI-gated surface the preceding phases moved back to green -- the wired
evidence probes above all -- repairing citations only, never an obstruction's content.

**Tasks**:

- [ ] Run `bash scripts/check-evidence-probes.sh` and read its label on each failing line: only
      `FAIL (does not compile)` is rot attributable to this task's edits.
- [ ] Repair each rotted citation under the script's no-weakening rule: adjust the probe's reading
      of `paramsOkK4`/`Bof` to the repaired definition, and never delete, restate or weaken an
      obstruction to make a probe pass. Where a probe's claim genuinely depends on the pre-repair
      conjunct, re-point it at `ParamsOkPre`/`paramsOkK4Pre` -- the frozen copies Phase 3 landed
      exist for exactly this.
- [ ] Confirm the direction of the three probe claims most exposed to the repair, and record each
      verdict: `ladder-cell-obligation-refutation.lean`'s `not_paramsOkK4_two` (still true -- the
      repair only strengthens the predicate it negates); `ladder-cell-agreement-refutation.lean`'s
      `repaired_clip_refuted` (unaffected in direction -- stated at the strictly stronger
      `BRep = 2 * (dBack + dFwd) + 2`); `ladder-chain-object-clip-refutation.lean`'s `unfold
      paramsOkK4` site (a syntactic unfold, so re-check the arithmetic that follows it).
- [ ] Run `bash scripts/check-module-invariants.sh` and reconcile its findings for the touched
      files: the module-inventory blocks in `README.md` and `FormalSystem/Metalogic/README.md` via
      `--emit-inventory` (gate-collision Condition 1, surface (a), which may legitimately land
      here), plus any C2/C14 axiom-baseline movement caused by the new declarations.
- [ ] Run `bash scripts/typst-sync-check.sh` in full (not `--counts-only`) and reconcile Check 2.
- [ ] Record each finding that is pre-existing and names only files outside this task's scope as an
      enumerated baseline finding with the evidence that every touched file passes individually. Do
      NOT edit an out-of-scope file to force a repo-wide count to zero (gate-collision Condition 4).
- [ ] If an `unusedArguments` finding appears from the batch env-linter, hand-insert the single
      four-line exemption row into `scripts/nolints.json` next to an existing row of the same shape.
      Do not run `lake exe runLinter --update` (gate-collision Condition 10).

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Tier Justification**: the surfaces this phase reconciles are repository-wide and CI-gated -- the
wired evidence probes under `specs/evidence/`, which no Lake target root reaches and no
module-scoped build compiles, plus the generated inventory blocks and `typst/generated/status.typ`
-- so no cheaper tier reaches any of them.

**Scope Hypothesis**: the probe files most likely to rot are
`ladder-cell-obligation-refutation.lean`, `ladder-cell-agreement-refutation.lean`,
`ladder-chain-object-clip-refutation.lean` and `ladder-step-fragment-gap-depth.lean` -- the four
wired probes whose `Bof`/`paramsOkK4` reference counts are highest (8, 27, 9 and 5). This is a
hypothesis from a reference-count sweep, not a compile result: the implementer confirms it by
running `check-evidence-probes.sh` and treats the script's own per-line labels as authoritative
over this list.

**Files to modify**:

- `specs/evidence/seam-gluing-ray-product/*.lean` - repair rotted citations only, in whichever
  wired probes the script reports; no obstruction's content changes.
- `README.md`, `FormalSystem/Metalogic/README.md` - regenerated module-inventory blocks, if
  `--emit-inventory --check` reports them stale.
- `typst/generated/status.typ` - final reconciliation of every tracked count.
- `scripts/nolints.json` - conditional: one hand-inserted exemption row, only if an
  `unusedArguments` finding actually fires.

**Verification**:

- `bash scripts/check-evidence-probes.sh` at exit `0`, or every remaining failing line carries a
  label other than `FAIL (does not compile)` and is recorded with its label.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no stale block.
- `bash scripts/typst-sync-check.sh` passes Check 2.
- `lake-build-guard.sh build --timeout 1800 -- build` at exit `0`, and the `Tests` target builds.

---

### Phase 6: Re-site the gate's crux in-source and record the residue [NOT STARTED]

**Goal**: Replace the forward-slack crux wording where this repository states it, record the
measured residue as the gate's remaining core, correct the one stale in-source clause the research
identified, and close the task.

**Tasks**:

- [ ] Repair the stale clause in `forwardSlackWitnessed_iff_next_region_cnt_le`'s docstring
      (`LadderCell.lean`, the "What this does NOT buy, and must not be read as" block above the
      theorem at `:1046`): the ordinary window regime `c <= n + 1` IS addressed in the UPWARD
      countdown direction by `cellAt_subset_of_window_raise` (`LadderWindow.lean:1690`); what is
      genuinely unaddressed is the DOWNWARD direction there (no `window_raise_rev` exists anywhere
      in the tree) and the non-register-held collisions.
- [ ] Record the re-sited crux in `LadderAgree.lean`'s `CellLEZeroConstOfKappaEq` docstring and in
      `LadderStepFrag.lean`'s module docstring: the reserved schema is now discharged on
      `StepFrag φ` (`cellLE_zero_const_of_kappa_eq_stepFrag`), the refutation direction has no
      depth-`0` candidate because every compiled separating family is `diaF`- or `.stab`-rooted and
      so fails the stab-free hypothesis, and the open residue is stab-free formulas carrying an
      UNBOUNDED `U`/`S` jump. State the forward-slack question's standing: one of four
      hypothesis-deficit families, and not the gate.
- [ ] Record the two owed follow-ups in the task's summary rather than acting on either: (a) the
      `specs/ROADMAP.md` Stage 0 crux wording, which `/roadmap` owns through the
      `roadmap_milestones`/`roadmap_context` entries the file is generated from -- this plan writes
      no roadmap entry; (b) the two context-extension recommendations the research made (`diaF` is
      the `⊡`-dual, and the schema-hypothesis-deficit table as a first artifact), which belong to a
      `/meta` task against the agent system's source store, not to this repository's library.
- [ ] Promote `specs/991_depth_zero_gate_verdict/probe-draft/threshold-depth-sum.lean` and
      `probe-draft/ordinary-window-regime.lean` to `specs/evidence/` and add them to
      `check-evidence-probes.sh`'s `WIRED` array ONLY if their content is not already subsumed by
      the landed library lemmas. The threshold probe IS subsumed by Phase 2 and should be dropped
      rather than wired; the ordinary-window probe records an obstruction (the `kappa`-segregated
      halves) that no landed declaration carries and should be wired. State the verdict either way.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` if any
      `.lean` path is staged by this phase.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: of the two task-local draft probes, exactly one earns promotion and wiring --
`ordinary-window-regime.lean`, whose `kappa_ne_of_regime_cross` and
`ordinary_window_collision_nonvacuous` record an obstruction (the two `kappa`-segregated collision
halves, only one of which the landed schemas reach) that no library declaration carries -- while
`threshold-depth-sum.lean` is subsumed by Phase 2's landed lemmas and is dropped rather than wired.
The implementer confirms the subsumption half by checking that each of that probe's declarations has
a landed library counterpart, and records the opposite verdict if one does not.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` - repair the stale
  three-restriction clause in `forwardSlackWitnessed_iff_next_region_cnt_le`'s docstring.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - record the re-sited crux and
  the residue in `CellLEZeroConstOfKappaEq`'s docstring.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` - record the same in the
  module docstring, beside the existing points 2 and 3.
- `specs/evidence/forward-slack-pin-cascade/ordinary-window-regime.lean` - conditional: the promoted
  ordinary-window probe, if the phase's verdict is to wire it.
- `scripts/check-evidence-probes.sh` - conditional: the `WIRED` entry for that probe, with its
  one-line "what it holds in place" comment.
- `typst/generated/status.typ` - regenerate if any `.lean` path is staged.

**Verification**:

- Every file this phase touches passes `bash scripts/check-module-invariants.sh` individually, and
  `bash scripts/check-evidence-probes.sh` is green for any newly wired entry.
- `lake-build-guard.sh build --timeout 1800 -- build` at exit `0` (docstring-only Lean edits still
  move line counts and must compile).
- `bash scripts/typst-sync-check.sh --counts-only` reports no drift.
- Under `/orchestrate`, this phase's own in-dispatch obligation is the SCOPED touched-path check
  above plus an explicit deferral of the complete gate battery to the orchestration close (Move 4),
  which owes it once per invocation; this phase does not invoke the full battery independently as
  its own criterion. A standalone, non-orchestrated run of this phase has no close to defer to and
  runs the complete gate set directly.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderStepFrag

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem dBack_add_dFwd_le_closure_card (φ : PlusFormula) :
    dBack φ + dFwd φ ≤ (plusSubformulaClosure φ).card := sorry

theorem paramsOk_two_depth_sum_le_Tc {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ) (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 * (dBack φ + dFwd φ) ≤ Tc := sorry

theorem paramsOk_two_depth_sum_le_Tn {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (Tc Tn P B : ℕ) (hp : ParamsOk step pend lab φ Tc Tn P B) :
    2 * (dBack φ + dFwd φ) ≤ Tn := sorry

theorem Zrel_of_kappa_eq {Q : Type} {pend : Q → Bool} (a b Tc Tn P B : ℕ)
    (hTc : 2 * (a + b) ≤ Tc) (hTn : 2 * (a + b) ≤ Tn)
    (hBa : 2 * a ≤ B) (hBb : 2 * b + 2 ≤ B) (q : Q) (c n c' n' : ℕ)
    (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) :
    Zrel a b (⟨(q, c, n), h⟩ : LadderState Q pend) ⟨(q, c', n'), h'⟩ := sorry

theorem cellLE_zero_const_of_kappa_eq_stepFrag {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (hφ : StepFrag φ) (Tc Tn P B : ℕ) :
    CellLEZeroConstOfKappaEq step pend fwd bwd lab φ Tc Tn P B := sorry
```

Three declarations this plan also lands are deliberately absent from this block, because their
signatures reference objects that do not exist in the tree yet (`ParamsOkPre`, `paramsOkK4Pre`) or
are `private` to their module (`thetaC`), so no block naming them can type-check standalone against
the current tree. Their statements are pinned instead by Phase 3's task list, which fixes each one
token for token: `paramsOkPre_params`, `exists_kappa_collision_cellAt_ne_at_K4_clip_pre`,
`exists_paramsOkPre_real_not_certAdmK` and `not_paramsOkK4_thetaC_clip`. The repaired bodies of
`paramsOkK4` and `Bof` are pinned the same way, in Phase 3's first task.

## Testing & Validation

- [ ] `lake-build-guard.sh build --timeout 1800 -- build` at exit `0` on the full project, after
      Phase 5.
- [ ] The `Tests` target builds, and every `#guard_msgs` block in
      `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` matches its recorded output.
- [ ] `lean_verify` on all five pinned identifiers reports axiom profiles free of `sorryAx`,
      `Lean.ofReduceBool` and `Lean.trustCompiler`.
- [ ] `bash scripts/check-evidence-probes.sh` reports no `FAIL (does not compile)` line.
- [ ] `bash scripts/check-module-invariants.sh` findings are either absent or recorded as
      pre-existing with the evidence that every touched file passes individually.
- [ ] `bash scripts/typst-sync-check.sh` passes Check 2 and the inventory-block check.
- [ ] An exact-name sweep over `FormalSystem/` and `Tests/` finds no declaration named
      `cellLE_zero_const_of_kappa_eq`.
- [ ] The landed signature of each of the five pinned identifiers matches the Challenge block token
      for token (`lean-challenge-snapshot.sh --check`, whose verdict is ADVISORY: a drift finding is
      a signal to investigate, never on its own grounds to fail the task).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - repaired `(K4)` and `Bof`;
  the frozen pre-repair copies; the depth-vs-closure-card bound.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` - the two threshold
  discharges, the promoted bridge, and `cellLE_zero_const_of_kappa_eq_stepFrag`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - the two restated refutation
  records and the companion clip-rejection record.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean`,
  `.../LadderAgree.lean` - corrected and re-sited docstrings.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - the restriction check following the
  restatement.
- `docs/theorem-index.md`, `typst/generated/status.typ`, `README.md`,
  `FormalSystem/Metalogic/README.md` - the generated and indexed surfaces this work moves.
- `specs/991_depth_zero_gate_verdict/probe-draft/threshold-depth-sum.lean` - the Phase 1 go/no-go
  probe.
- `specs/991_depth_zero_gate_verdict/summaries/01_depth-zero-gate-step-fragment-bridge-summary.md` -
  the completion summary, carrying the two recorded follow-ups (the roadmap crux re-siting for
  `/roadmap`, and the context-extension recommendations for `/meta`).

## Rollback/Contingency

The plan's own sequencing is the primary contingency: Phase 1 is a task-local probe that touches no
library file, so a negative threshold verdict costs nothing and leaves `(K4)` untouched. Phases 2
and 4 are purely additive and revert by removing the added declarations. Phase 3 is the only phase
that changes an existing definition, and it is declared `atomic-batch` precisely so that its commit
is all-or-nothing: either the repair and every restatement it forces land together, or neither
does.

If Phase 3 or a later phase must be reverted after it has been committed, the route is a genuine
rollback: take a snapshot first with the explicit-task-number form
`bash .claude/scripts/git-snapshot.sh 991` (see `context/contracts/recovery.md`'s rollback rung for
the invocation shape and its out-of-scope override flag), then revert. Do NOT emit that default,
reverting form as a routine start-of-phase checkpoint; for an ordinary defensive checkpoint before
risky work inside a phase, use `bash .claude/scripts/git-snapshot.sh 991 --no-revert`, which is
durable without reverting the working tree.

If the route is abandoned mid-way, the honest resting state is whatever phases landed plus a
`[PARTIAL]` plan and a summary recording which of the four hypothesis deficits remain. The reserved
name `cellLE_zero_const_of_kappa_eq` stays claimed by nothing in every outcome, including every
partial one -- that invariant is not contingent on the plan completing.
