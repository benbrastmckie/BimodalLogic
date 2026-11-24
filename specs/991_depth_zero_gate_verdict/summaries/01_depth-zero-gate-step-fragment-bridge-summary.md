# Implementation Summary: Task #991

- **Task**: 991 - Depth-0 gate verdict: enter the step-fragment bridge and land `CellLEZeroConstOfKappaEq` restricted to `StepFrag`
- **Status**: [COMPLETED]
- **Started**: 2026-11-24T16:24:43Z
- **Completed**: 2026-11-24T17:57:42Z
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_depth-zero-gate-step-fragment-bridge.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All six phases of the step-fragment-bridge plan closed. The deliverable
`cellLE_zero_const_of_kappa_eq_stepFrag` is landed `sorryAx`-free: the reserved depth-`0` schema
`CellLEZeroConstOfKappaEq` holds for every formula of `StepFrag φ`, from `ParamsOk` itself and at
generic parameters, with `StepFrag φ` as the single added hypothesis. The reserved name
`cellLE_zero_const_of_kappa_eq` stays carried by no declaration. Getting there required the two
owed threshold inequalities to be discharged from `(K3)`, `(K4)`'s forward conjunct to be repaired
from `2 * dFwd φ + 1 ≤ B` to `2 * dFwd φ + 2 ≤ B`, and every landed record that repair falsifies to
be restated against a newly frozen `ParamsOkPre`.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` —
  - The pure-syntax layer the threshold discharge needed, after `dFwd`: `plusFsize`,
    `plusFsize_le_of_mem_subformulas` (the size monotonicity `Subformulas.lean` does not carry),
    `closure_subset_of_mem_subformulas`, `not_mem_closure_of_plusFsize_lt`, `isSnceRoot`,
    `isUntlRoot`, `card_rootFilter_mono`, `card_rootFilter_succ`, `dBack_le_card_snceRoot`,
    `dFwd_le_card_untlRoot`, and the headline `dBack_add_dFwd_le_closure_card`
    (`dBack φ + dFwd φ ≤ (plusSubformulaClosure φ).card`); plus `one_le_tIdle` after `tIdle`.
  - `(K4)`'s forward conjunct repaired to `2 * dFwd φ + 2 ≤ B` and `Bof`'s middle arm to
    `2 * dFwd φ + 2`, both docstrings stating WHY the asymmetry is forced rather than conservative
    (`LadderStepFrag.lean`'s module docstring point 2 derives `G⁻ = 2b + 2` from the one-step
    closure conditions, so the asymmetry lives on the `Zrel` side and `(K4)` was the short side).
    `paramsOk_params`'s three `(K4)` arms needed no textual change: they are generic `le_max_*`
    terms that read `Bof`'s repaired middle arm automatically.
  - The frozen pre-repair record: `paramsOkK4Pre`, `ParamsOkPre`, `paramsOkPre_params`.
  - `set_option linter.style.longFile 1600` added (the file reaches 1548 lines).
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` —
  - `section DepthThreshold`: `dBack_add_dFwd_le_tShort`, `paramsOk_two_depth_sum_le_Tc`,
    `paramsOk_two_depth_sum_le_Tn`.
  - `Zrel_of_kappa_eq` and `cellAt_const_of_kappa_eq_stepFrag`, promoted from the wired probe
    `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean`.
  - `section StepFragSchema`: **`cellLE_zero_const_of_kappa_eq_stepFrag`**, the deliverable.
  - Module docstring: point 3 changed from `OWED, NOT DISCHARGED` to `DISCHARGED`, point 2's
    asymmetry claim corrected (`paramsOkK4`'s clip now carries it), and a new section recording
    where the reserved schema stands and what the residue is.
  - `longFile` baseline re-tightened 1700 -> 1900 across two phases.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` —
  `exists_kappa_collision_cellAt_ne_at_K4_clip` -> `..._pre` and `exists_paramsOk_real_not_certAdmK`
  -> `exists_paramsOkPre_real_not_certAdmK`, both against `ParamsOkPre` with their written clips
  UNCHANGED; `not_paramsOkK4_thetaC_clip : ¬ paramsOkK4 thetaC 3` added as the companion rejection
  record; both docstrings restated; `longFile` 4800 -> 4900 and three docstring rewraps under the
  100-character limit.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` —
  `CellLEZeroConstOfKappaEq`'s docstring now records the discharge, the absence of any depth-`0`
  refutation candidate, the open residue, and the forward-slack question's standing.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` —
  the stale clause in `forwardSlackWitnessed_iff_next_region_cnt_le`'s "What this does NOT buy"
  block repaired: the ordinary window regime IS addressed in the upward countdown direction by
  `cellAt_subset_of_window_raise`; what is unaddressed is the downward direction (no
  `window_raise_rev` exists anywhere in the tree) and the non-register-held collisions.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — the restriction-check `example` and
  two `#guard_msgs`-wrapped `#print axioms` blocks follow the restatement.
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean`,
  `ladder-step-fragment-gap-depth.lean` — probe-local `BofPre` + `paramsOkPre_BofPre`;
  `RefutationTargetC`, `CountMoveTargetC`, `cellAt_const_of_kappa_eq_schema_refuted`,
  `no_fibre_equation_over_kappa`, `no_transferSys_links_collisions`, `mixC_refutes`, `B0` and
  `sigC_refutes` re-pointed at `ParamsOkPre` at the frozen clip; the repaired `Bof` readings
  recorded alongside (`Bof_thetaC = 4`, `Bof_mixC = 2k+6`, `Bof_sigC = 2b+2`).
- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean`,
  `ladder-chain-object-clip-refutation.lean` — numeric citation repairs only
  (`Bof_chiD` 9 -> 10; `Bof_chainC` 7 -> 8 and the clip floor `max (E chainC) 7` -> `8`).
- `specs/evidence/forward-slack-pin-cascade/ordinary-window-regime.lean` — promoted from
  `probe-draft/` and WIRED in `scripts/check-evidence-probes.sh`; its
  `paramsOkK4_one_short_of_Zrel_forward_arm` restated as
  `paramsOkK4Pre_one_short_of_Zrel_forward_arm` against the frozen conjunct, beside a new
  `paramsOkK4_delivers_Zrel_forward_arm` recording that the deficit is CLOSED.
- `specs/991_depth_zero_gate_verdict/probe-draft/threshold-depth-sum.lean` — created as the Phase 1
  go/no-go probe. Subsumed by Phase 2's landed lemmas and therefore DROPPED rather than wired.
- `docs/theorem-index.md` — the deliverable's row added; the rows and prose naming the renamed
  theorems updated, with the clip wording repaired.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `typst/generated/status.typ` — the
  generated surfaces this work moved.

## Decisions

- **The threshold route is `(K3)` alone.** `dBack φ + dFwd φ` is bounded by the closure's
  cardinality through two DISJOINT root-filters — `dBack` counts `snce`-rooted closure members,
  `dFwd` counts `untl`-rooted ones, and no member is both — then carried to `tShort Q φ` by
  `k ≤ 2 ^ k`, `1 ≤ Fintype.card Q` and `card_prodState`. `(K3)`'s second conjunct finishes the
  `Tc` form; its ordering carries that to `Tn` with `tIdle pend + 2 ≥ 3` of slack paying for the
  `+ 1` the ordering gives away. `(K2)`'s margin arm is not used.
- **A local `plusFsize` rather than `sizeOf`.** `sizeOf`'s `atom` arm reads `Atom`'s own size,
  which makes the no-self-containment arithmetic opaque; a function whose arms are written in place
  keeps every step `omega`-closable.
- **The `(K4)` repair is frozen, not papered over.** The repair makes two landed theorems and one
  test `example` FALSE rather than merely unproved, so `paramsOkK4Pre`/`ParamsOkPre` were landed as
  a library-level frozen record (the precedent being this tree's own `Probe836A.paramsOkK4Pre`,
  which froze the previous `(K4)` when `dFwd` was first added) and every falsified record restated
  against it with its written clip unchanged. No obstruction was deleted, weakened or retired.
- **No refutation attempt at depth `0`.** Every separating family compiled anywhere in the tree
  (`thetaC`, `sigC b`, `mixC a k`, `dblC j`) is `diaF`- or `.stab`-rooted and so fails the schema's
  own stab-free hypothesis, so the refutation direction has no candidate. This is recorded
  in-source rather than re-derived.
- **The gate's crux is re-sited on the residue**: stab-free formulas carrying an UNBOUNDED `U`/`S`
  jump — a guard other than `⊥` under an `untl` or a `snce`. The forward-slack question is recorded
  in-source as ONE of four independent hypothesis deficits and explicitly not this gate.

## Plan Deviations

- **Phase 3** altered: `paramsOk_params`'s three `(K4)` arms needed no textual change (generic
  `le_max_*` terms).
- **Phase 3** altered: `paramsOkPre_params` is stated with its fourth argument written out as the
  pre-repair `Bof` BODY, not at `Bof`. The plan's two instructions were incompatible as written —
  after the repair `Bof thetaC = 4` while the restatements' written clip is `3`, so a
  `paramsOkPre_params` stated at `Bof` could not discharge either restatement.
- **Phase 3** altered: the frozen copies plus the two repaired docstrings take
  `CounterQuotient.lean` to 1548 lines, over the package-wide 1500 `longFile` default, so a
  `set_option linter.style.longFile 1600` baseline was added. The plan's Files-to-modify note had
  estimated the file would stay under 1500.
- **Phase 4** altered: `Zrel_of_kappa_eq` was promoted verbatim EXCEPT that its three
  goal-restating `show` lines became `change`. The plan's Risk row asserted those `show` lines are
  the sanctioned use; `linter.style.show` flagged all three (they restate `Zrel`'s clauses with the
  two `LadderState` projections reduced, which is a definitional change), and CI builds `--wfail`.
  No other token of statement or body changed.
- **Phase 4** additionally needed `LadderRealize.lean`'s `longFile` baseline raised 4800 -> 4900
  and three docstring rewraps under the 100-character line limit — both consequences of Phase 3's
  rename to the longer `_pre` names, invisible until a module rebuild.
- **Phase 5** altered: FOUR probes rotted, not the two the first run reported. Two were pure
  numeric citation repairs; two needed the frozen-copy re-pointing the plan pre-authorised.
- **Phase 6** altered on promotion: the draft's `paramsOkK4_one_short_of_Zrel_forward_arm` is
  FALSIFIED by this task's own `(K4)` repair, so it was restated against the frozen conjunct beside
  a new theorem recording that the deficit is closed. The superseded draft copy was deleted so no
  ungated duplicate could rot.

## Verification

- Build: **Success** — `lake-build-guard.sh build --timeout 1800 -- build` exit `0` (3018 jobs) and
  `-- build BimodalTest` exit `0` (3097 jobs), both with ZERO `error:` lines and ZERO warning lines
  (CI builds `--wfail`, so a warning is a failure).
- Sorry count: **0** (`lean-sorry-census.sh` over all twelve resolved source roots).
- Vacuous count: **0 introduced by this task.** A repo-wide sweep reports 2 matches, both
  pre-existing and in files this task never touched — `FormalSystem/Semantics/PointTransport.lean`'s
  `AnyPoint` (landed 2026-11-23 in PR #11) and `FormalSystem/Examples/TemporalStructures.lean`'s
  `int_domain_universal` (landed 2026-10-14). Both are present at `HEAD~6`, verified by
  `git show`.
- Axiom count: **14, unchanged.** `git grep -c "^axiom "` reports 14 at `HEAD~6` and 14 at `HEAD`.
- `lean_verify` / `#print axioms` on all five pinned identifiers plus the four new/restated
  `LadderRealize` declarations: every profile is a subset of `[propext, Classical.choice,
  Quot.sound]`. No `sorryAx`, no `Lean.ofReduceBool`, no `native_decide`.
- Reserved-name sweep: an EXACT declaration-form sweep over `FormalSystem/` and `Tests/` finds no
  declaration named `cellLE_zero_const_of_kappa_eq`. It stays unclaimed.
- `bash scripts/check-evidence-probes.sh`: `PASS  all 68 wired probe(s) compile` (one pre-existing
  `SKIP (deferred: frame-class uniformity work)`, untouched).
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: no stale block.
- `bash scripts/typst-sync-check.sh --fix`: PASS on status.typ, the module map and the machine
  appendix.
- Plan compliance: `lean-plan-compliance-check.sh` reports `COMPLIANCE_CHECK: passed` — all five
  pinned Challenge identifiers found.
- `lean-challenge-snapshot.sh --check` (ADVISORY ONLY): reports the known false-ambiguity defect on
  four of the five pinned names, because each resolves to both the probe copy and the new library
  copy under the same bare name. It reports no signature drift; it could not compare. `#check` on
  each landed declaration confirms the signatures match the plan's Challenge block token for token.
- Tests: Passed (`BimodalTest` builds; every `#guard_msgs` block in `KTypeSummaryAxiomTest.lean`
  matches).
- Files verified: Yes.
- **Batch gate deferral**: this dispatch is one `implement`-phase dispatch inside a multi-task
  `/orchestrate` batch. The complete gate set was NOT independently run; it is deferred to the
  single batch-stage sweep at the end of the invocation, attributed back by `modified_files`. The
  scoped discharge used instead is the UNMAPPABLE-CRITERION route: the phases' own declared
  criteria name `check-evidence-probes.sh`, `check-module-invariants.sh` and `typst-sync-check.sh`,
  which no `verify-deploy.sh --only-gate N` expresses (gates 8-23 cover the agent system's own
  deployed shell tree, not this Lean library), and `verify-touched.sh` derives touched paths from
  the whole working tree, which under the concurrent sibling dispatch active in this invocation
  selects a large battery of agent-system shell suites unrelated to this task. Each named check was
  run DIRECTLY instead.
- **Pre-existing out-of-scope baseline finding, recorded not repaired** (gate-collision
  Condition 4): `check-module-invariants.sh`'s `FAIL C16` over the other lakefile roots reports 5
  NEW entries, all in `BimodalLibTest.DiagnosticsTest` and four `BimodalTools` modules this task
  never touches. Every file this task touched passes individually.

## Impacts

- **The depth-`0` gate's verdict is delivered, in the positive direction on the step fragment.**
  `specs/ROADMAP.md` Stage 0's one unchecked blocking item has an owner's answer: the schema holds
  on `StepFrag φ` and the residue is named. Milestone M7's ladder band and the ten NOT STARTED
  plus three BLOCKED phases of the ladder realization theorem can be restated against this verdict.
- `ParamsOk` now supplies all four numeric hypotheses of `cellAt_const_of_kappa_eq_stepFrag` for
  every consumer, so the step-fragment agreement is usable at generic parameters rather than only
  inside a probe.
- `(K4)` and the derived relation `Zrel` now ask for the same forward gap. Any future consumer
  needing `2 * dFwd φ + 2 ≤ B` gets it from `ParamsOk` directly.
- Two refutation records moved from `ParamsOk` to `ParamsOkPre`. A reader of
  `exists_kappa_collision_cellAt_ne_at_K4_clip_pre` must now note that the live `(K4)` rejects its
  clip — `not_paramsOkK4_thetaC_clip` records exactly that, and the docstrings say so.
- Measured side finding: the repair buys back exactly the two smallest members of the `mixC`
  separating family (`k = 1`, `k = 2`) and nothing beyond, since the separated gap `3k + 4` now
  exceeds the clip `2k + 6` by `k - 2` where it exceeded `2k + 5` by `k - 1`. The unbounded excess
  is intact, so no constant added to the larger exactness depth repairs `(K4)`.

## Follow-ups

- **`/roadmap`**: `specs/ROADMAP.md` Stage 0's crux wording still names the forward-slack question.
  It should be re-sited on the measured residue — stab-free formulas carrying an unbounded `U`/`S`
  jump. This plan wrote no roadmap entry: `ROADMAP.md` carries a `do not edit` generator banner and
  is rendered from `specs/state.json`'s `roadmap_milestones`/`roadmap_context` entries, which
  `/roadmap` owns.
- **`/meta`**: the research dispatch's two context-extension recommendations belong to the agent
  system's source store, not this repository's library — (a) that `diaF` is the `⊡`-dual and is what
  every compiled separating family reads the gap with, and (b) a schema-hypothesis-deficit table as
  a first-class artifact kind.
- **The ladder realization theorem's own plan record** is restated against this verdict by its own
  task; that restatement is a `/revise`, not a dispatch, and is out of scope here.
- The residue itself — stab-free formulas with an unbounded `U`/`S` jump — is NAMED and re-sited,
  not attacked. No `Srel`/`Mrel` path-forth and no row-link discharge was in scope.

## References

- `specs/991_depth_zero_gate_verdict/plans/01_depth-zero-gate-step-fragment-bridge.md`
- `specs/991_depth_zero_gate_verdict/reports/01_depth-zero-gate-verdict.md`
- `specs/991_depth_zero_gate_verdict/probe-draft/threshold-depth-sum.lean`
- `specs/991_depth_zero_gate_verdict/handoffs/` (six per-phase handoffs)
- `specs/evidence/seam-gluing-ray-product/ladder-step-fragment-gap-depth.lean` (the measurement
  that forced the `(K4)` repair)
- `specs/evidence/forward-slack-pin-cascade/ordinary-window-regime.lean` (newly wired)
- `specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean` (the deliverable)
