# Implementation Summary: Task #836

- **Task**: 836 - Ladder type-preserving cell-agreement construction: wire the compiled refutation of `CellLEZeroConstOfKappaEq`, repair `(K4)` with the forward exactness depth, and land the certificate-free type-preserving pump layer the repaired obligation consumes
- **Status**: [BLOCKED]
- **Started**: 2026-11-03T02:33:00Z
- **Completed**: 2026-11-03T05:30:00Z
- **Effort**: one dispatch, eleven phases (ten closed, Phase 10 `[BLOCKED]` on the Phase 3 gate's FAIL branch)
- **Dependencies**: None at the `state.json` level; task 761 is the consumer
- **Artifacts**: plans/01_obligation-repair-and-pump-layer.md, prototype/tight-chain-regime-b.lean, handoffs/phase-{1..10}-handoff-*.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The obligation this task was opened to construct is false as filed, and the record now carries
that fact: the forty-seventh wired probe refutes `CellLEZeroConstOfKappaEq` at the periodicity
fixpoint's own outputs with the gap clip bounded by the backward exactness depth alone, `(K4)` is
repaired to bound the clip by both exactness depths, and the certificate-free type-preserving pump
layer — deletion admissibility, both type lemmas, the forward window, the type pigeonhole, the
iterated duplication, the realized-chain bridge and the one-directional regime-A assembly with its
upward cell inclusion — is landed and pinned. Seven of the plan's eight Lean Challenge Statements
are theorems. The eighth, `cellLE_zero_const_of_kappa_eq`, is NOT: the Phase 3 decision gate
refuted the spanning-block device in both directions by compiled objects, so Phase 10 closed
`[BLOCKED]` per the plan and the reserved name stays claimed by nothing.

## What Changed

- `specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean` — new, the forty-seventh wired probe (550 lines): `Probe836A.cellLEZeroConstOfKappaEqPre_refuted` and `exists_refuting_cell_collision` against the frozen `ParamsOkPre` (the one-depth `(K4)`), plus the two positive facts about the repair, `not_paramsOkK4_two` and `kappa_D_dissolves` (`Bof chiD = 9`). Standard axiom profile on all eight printed theorems.
- `scripts/check-evidence-probes.sh` — the probe's `WIRED` table block and array entry; the gate reports `PASS  all 47 wired probe(s) compile`.
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` — `dFwd` (the `U`-nesting depth), `paramsOkK4 φ B := 2 * dBack φ + 1 ≤ B ∧ 2 * dFwd φ + 1 ≤ B ∧ 2 ≤ B`, `Bof := max (2 * dBack φ + 1) (max (2 * dFwd φ + 1) 2)`, `paramsOk_params` re-proved (standard axioms), header and docstrings stating the two-depth design.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — docstrings only (module header, the "does NOT hold" bullet, the Rigid-section docstring, the obligation section and the schema's docstring) now state the refutation, its mechanism, and the frozen-predicate anchoring; 2,296 lines, no theorem or definition added.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` — new (1,485 lines, certificate-free under `LadderAgree.lean`'s grep, imports `LadderAgree` alone): `delIdx` (= `spliceEmb` by `rfl`), `delObj`/`delCnt` with the three `Count` readings and `delCnt_sub_of_mem_region`, the Goal `exists_deleted_ladderPath_of_pend_past`; `endpoint_iff_of_tpOf_eq`, four splice clause lemmas, `plusTruthAt_iff_spliceIdx_of_tpOf_eq_of_stabPinned`, the Goal `tpOf_eq_spliceIdx_of_tpOf_eq`; four deletion clause lemmas, `plusTruthAt_iff_delIdx_of_tpOf_eq_of_stabPinned`, the Goal `tpOf_eq_delIdx_of_tpOf_eq` (HWZ 2000 Lemma 17 over `ℤ`); the Goal `nxtAt_le_cntAt_add_of_next_region`; `exists_typeBlock_of_budget_le_cnt_within` and the Goal `exists_typeBlock_of_budget_le_cnt`; `exists_iterSpliced_ladderPath_of_pend_past`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — new (612 lines, reads the LOCAL half of the certificate layer only; its grep forbids every certificate-SET object): `card_prodState`, `budget_le_cascadeBound`, `budget_le_Tc`; `untl_mem_tpOf_succ_iff`, `snce_mem_tpOf_succ_iff`; `realizedCl`, `locCoh_of_realized`, `untlLink_of_realized`, `snceLink_of_realized`, `cohIdle_of_realized`; `blockWalk`, `blockWalk_cohIdle`, `blockWalk_satCl`; the Goal `realized_typeBlock_mem_prodCycleLens` and `typeBlock_length_dvd_of_paramsOk`; `exists_ladderPath_of_walk_nxt`, `isLadderPath_shift`, the Goal `exists_ladderPath_through_shifted_of_pend_past`, and `cellAt_subset_of_shift_of_pend_past`.
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean` (by `mk_all`) — the two new modules imported.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — the (W) prose amended; five new (W) blocks pinning `delIdx`, `delCnt_sub_of_mem_region`, `exists_deleted_ladderPath_of_pend_past`, both type lemmas, the forward window, the pigeonhole, the bridge and its corollary, the assembly and its corollary (every pin matches).
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — inventory rows with descriptions for the two new modules; the (W) subsection "What the cell reads of the register" pairing the two windows, naming `kappa`'s gap coordinate, the forty-seventh probe, and the obligation's status.
- `specs/836_…/prototype/tight-chain-regime-b.lean` — the Phase 3 gate prototype (575 lines, not wired): the tight doubling chain (`tightChain_isLadderPath`, `tightChain_pin`, `tightChain_slack_zero`, `tightChain_pins`), `SpanningBlockBwd`/`SpanningBlockFwd`, and their refutations.
- `scripts/nolints.json` — four `unusedArguments` rows for hypotheses the plan's pinned signatures carry but the proofs do not read (`hl` on both type lemmas, `hσ` on the pigeonhole, `hno` on the bridge). This file is outside the task's declared `file_scope`, so it is left in the working tree and proposed through `proposed_file_scope` rather than committed by this dispatch.
- Generated records regenerated as the line counts moved: the three README inventory blocks, `typst/generated/status.typ`.

## Decisions

- The `(K4)` repair proceeds on the recorded decision (Option A, `.decisions.json`): factor `2` on the forward depth as the conservative mirror of the backward bound; the refuting `X`-chain family of depth `B + 2` has `dFwd = B + 3`, so `Bof` exceeds every clip it defeats.
- Wire first, repair second, re-anchor in the repair phase: the probe is a theorem about the named, frozen `ParamsOkPre`, so no commit left the evidence gate red.
- The Phase 3 gate is reported as a refutation of the DEVICE, not of the obligation: both refuting objects have a pin-free side on which the register is rebuildable without a spanning block, so the schema under `ParamsOk` is neither proved nor refuted there.
- The regime-A assembly is one-directional (upward shift, register held) as the plan pinned; the downward inclusion is not claimed.
- Hypotheses pinned by the Lean Challenge Statements but not read by the proofs are kept token-for-token and silenced with scoped, reasoned `set_option`s plus `nolints.json` rows — never dropped, never restated.

## Plan Deviations

- **Phase 1** altered: three further `LadderAgree.lean` docstrings (module header, the "does NOT hold" bullet, the Rigid-section docstring) that became false once the probe was wired were amended in the same docstring-only pass; `LadderAgree.lean` is 2,296 lines, outside the plan's ±25 band and under `longFile 2400`. The three README inventory blocks and `status.typ` were regenerated (count-only).
- **Phase 2** altered: the Phase 1 `LadderAgree.lean` wording ("(K4) as it reads bounds `B` by `dBack` alone") was re-touched to name the frozen `ParamsOkPre`.
- **Phase 3** altered: the past-extension attempt on the chain was not pursued past the register analysis, because the spanning block it would duplicate is the refuted object; the verdict's evidence is two compiled refutations rather than a derivation.
- **Phase 4**: none (the module docstring describes the forbidden objects instead of naming them, so the certificate-freedom grep does not hit itself).
- **Phase 5** altered: the two index-map helpers are inlined into the four named clause lemmas.
- **Phase 6** altered: the Scope Hypothesis's split into `LadderPumpType.lean` was taken at 1,239 lines and reverted in the same phase — the contingency file is outside the task's declared `file_scope`, so no commit route in an implement dispatch can carry it; `LadderPump.lean` stays one module (1,485 lines after Phase 7, under the package `longFile` 1,500, no baseline raised). Committed as the `6.1` sub-step.
- **Phase 7** altered: the countdown bookkeeping is one induction (`exists_iterSpliced_ladderPath_of_pend_past`) carrying everything Phase 9 needs; the pigeonhole is landed twice (`_within` records the block's position; the pinned Goal is derived from it).
- **Phase 10** skipped (PASS branch) / closed `[BLOCKED]` (FAIL branch), per the Phase 3 verdict.
- **Phase 11** altered: `lean-challenge-snapshot.sh --check 836 .` reports no manifest (the snapshot was never taken at plan time), so the advisory signature check could not run; the eight pinned signatures were compared by hand against the plan's block (identifier set, binder order, instance binders `[Fintype Q] [Nonempty Q]`, explicit `step`/`pend`).

## Verification

- Build: Success — `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exit 0 (2,894 jobs, zero warnings); `… -- build BimodalTest` exit 0 (2,958 jobs); every touched module's `.olean` newer than its source.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; see the final metadata).
- Vacuous count: 0.
- Axiom count: 0 new (`^axiom` grep over the resolved source roots unchanged; every landed Goal at `[propext, Classical.choice, Quot.sound]` or a subset, pinned in `KTypeSummaryAxiomTest.lean`).
- Tests: Passed — `bash scripts/check-evidence-probes.sh`: `PASS  all 47 wired probe(s) compile`; `bash scripts/check-module-invariants.sh`: ALL CHECKS PASSED at every phase close (the final run's verdict is recorded in the metadata); `bash scripts/typst-sync-check.sh`: PASS (all 4 checks); `bash .claude/scripts/verify-deploy.sh`: exit 0; `lean-challenge-snapshot.sh --check`: advisory, no manifest.
- Files verified: Yes (`check-task-references.sh --quiet` clean on every non-`specs/**` file touched; no record-versioning language in the edited docstrings).
- Reserved name: `grep -rn 'cellLE_zero_const_of_kappa_eq' FormalSystem/ Tests/` returns only the two docstring lines of `LadderAgree.lean`.

## Impacts

- For task 761's reviser: Phase 11.6's gate (`cellLE_zero_const_of_kappa_eq` landed, `sorryAx`-free) is NOT satisfied and cannot be satisfied by this layer alone; the obligation it inducts from is refuted at the one-depth `(K4)` and open at the two-depth one. Plan 08's Non-Goal "no strengthening of `ParamsOk`" is superseded by the recorded decision: `(K4)` now carries the forward exactness depth. The pinned-letter case at depth `≥ 1` needs the pumped block's length `≡ 0 (mod P + 1)` at countdown `≥ Tc`, which `typeBlock_length_dvd_of_paramsOk` now supplies at depth `0`.
- Every consumer of `ParamsOk` sees a strictly stronger `(K4)`; both older wired probes pass `Bof` through `paramsOk_params` and still compile.
- The pump layer is reusable by any successor construction: duplication and deletion of a type-respecting block preserve the realized stab-free type at every position, and a block's length divides `P + 1`.
- `scripts/nolints.json` carries four uncommitted rows (`proposed_file_scope`); until they are committed, `check-module-invariants.sh`'s C16 passes only against the working tree.

## Follow-ups

- Commit `scripts/nolints.json` once `file_scope` admits it (proposed via `proposed_file_scope`).
- A successor task for the open core (see the Phase 10 blocker): a `(K2)`-level pigeonhole over region starts exploiting the pin-free side, or a `/revise` of the obligation's statement.
- The context note the research recommended for `.claude/context/project/lean4/domain/ladder-counter-observables.md` (the two windows and the two-depth `(K4)`) is relayed to the source store's owner; this task does not edit deployed `.claude/**` files.
- A plan contingency that names a NEW file must list it under "Files to modify", or the dispatch cannot commit it (recorded in `issues.jsonl`).

## References

- specs/836_ladder_type_preserving_cell_agreement_construction/plans/01_obligation-repair-and-pump-layer.md
- specs/836_ladder_type_preserving_cell_agreement_construction/reports/01_type-preserving-cell-agreement-construction.md
- specs/836_ladder_type_preserving_cell_agreement_construction/prototype/tight-chain-regime-b.lean
- specs/836_ladder_type_preserving_cell_agreement_construction/handoffs/ (phase-1 through phase-10)
- specs/836_ladder_type_preserving_cell_agreement_construction/issues.jsonl
- specs/evidence/seam-gluing-ray-product/ladder-cell-obligation-refutation.lean
- Commits: 11f342c01 (phase 1), 6612ae009 (2), fb99cfa0f (3), 6fca88fc5 (4), 5cbb0330d (5), 26b6895f0 and 54ba68cc4 (6, 6.1), 8ec2fc04b (7), 086f01acf (8), 265c957b2 (9), f88de40a9 (10)
