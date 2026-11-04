# Implementation Summary: Task #849

- **Task**: 849 - Discharge or regime-restrict the named hypothesis HasForwardSlack, then land the exact-shift iterated deletion the cell-level downward inclusion still needs
- **Status**: [COMPLETED]
- **Started**: 2026-11-04T00:36:00Z
- **Completed**: 2026-11-04T01:14:00Z
- **Effort**: ~40 minutes wall clock (8 phases, 9 commits)
- **Dependencies**: None at the `state.json` level; consumes the five declarations landed by `specs/844_reanchored_deletion_half_depth_zero_cell/` unedited
- **Artifacts**: plans/01_forward-slack-exact-shift.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Piece 1 is settled by route (b): the regime `HasForwardSlack` is kept as a path-level hypothesis
and equipped with an entry lemma from a finite witness, monotonicity, transport across a
deletion, and vacuity, and a two-state witness in the library shows it NECESSARY (the compiled
climbing-register path refutes the unconditional claim) and INHABITED at every amount (the
parametric plateau). Piece 2 is landed as the exact-shift theorem by overshoot-then-up (delete
sampled blocks at the original block's spacing until at least `m · (P + 1)` positions are gone,
then raise by the overshoot with the register-held iterated duplication of the original block),
and its consumer, the downward cell inclusion stated on the witnessing path. All seven pinned
Challenge statements landed with headers matching character-for-character; the reserved name
`cellLE_zero_const_of_kappa_eq` remains claimed by nothing.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` (959 → 1,780 lines; `set_option linter.style.longFile 1800` baseline added after the module docstring):
  - `section Budget`: `budget_mul_succ_le_Tc` (pinned) — `b · (b + 1) ≤ Tc` from `(K2)` alone.
  - new `section Spacing` after `section Bridge`: `exists_typeBlock_of_spacing` (pinned) — the spaced type pigeonhole.
  - `section AssemblyFin`: new `exists_ladderPath_through_iterSpliced_nxt_of_pend_past` (register-held iterated duplication of a GIVEN block, `[Finite Q]` binder); the regime-A assembly `exists_ladderPath_through_shifted_of_pend_past` is now its corollary with its statement untouched (before/after header diff empty; the test module's `#guard_msgs` axiom pin still passes).
  - new `section Slack` after `section DelNxt`: `hasForwardSlack_mono`, `hasForwardSlack_of_next_region_cnt_le`, `hasForwardSlack_del` (all pinned), `hasForwardSlack_of_idle_above`.
  - new `namespace ClimbWitness`: `stepT`, `pendT`, `climbRaw`, `climbRaw_adm`, `climb`, `climb_isLadderPath`, `climb_pend_past`, `climb_gap`, `climb_not_hasForwardSlack`, headline `hasForwardSlack_refuted_unconditional`; `plateauRaw`, `plateauRaw_adm`, `plateau`, `plateau_isLadderPath`, `plateau_pend_past`, `plateau_nxt`, `plateau_cnt_zero`, `plateau_gap`, `hasForwardSlack_plateau`, headline `exists_hasForwardSlack_inhabitant (L : ℕ)` (parametric; the literal-`C` fallback was not needed).
  - new `section DelNxtIter` after `section DelNxtFin`: `exists_deleted_ladderPath_step_of_pend_past` (one step), `exists_deleted_ladderPath_overshoot_of_pend_past` (the loop, `R ≤ t < R + b`), `exists_ladderPath_through_deleted_exact_of_pend_past` (pinned; countdown lowered by exactly `m · (P + 1)`, register and realized type held), `mem_cellAt_of_shift_of_hasForwardSlack` (pinned; the downward cell inclusion on the witnessing path).
  - Docstrings: module header, `Assembly` section, `DelNxtFin` section, the single-block assembly, `cellAt_subset_of_shift_of_pend_past`.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` — one docstring sentence (the downward inclusion's state); no proof edited.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — `LadderChain.lean` row (count re-derived, full description, honest closing), `LadderPump.lean` row (exposure sentence), the depth-`0` status paragraph, the closing of the `(K1)` paragraph.
- `typst/generated/status.typ` — regenerated at every phase by `scripts/typst-sync-check.sh --fix`.

## Decisions

- Pinned headers were stated with their explicit `{Q : Type} …` binders exactly as the Challenge writes them (shadowing section variables), so the drift check compares like with like.
- The given-block lemma takes `[Finite Q]` rather than the section's `[Fintype Q]` (with `Fintype.ofFinite` inside the proof), on the `unusedFintypeInType` linter's instruction; its hypothesis list is otherwise the plan's.
- Every `omega` side-condition on the budget product is proved with the product as one atom (a local `generalize`, or named facts `b·l ≤ b·b`, `b·(b+1) = b·b + b`, `t·l ≤ R·l + b·l`); this is what made Phases 5-7 close on their first builds.
- The two-state witness lives in the library module per the task's placement rule; no lint rejected it, so the pre-authorized relocation branch was not taken.
- The file's length is baselined, not split, per `docs/development/LEAN_STYLE_GUIDE.md` ("Long files are baselined, not split").

## Plan Deviations

- **Phase 4** altered: the given-block lemma's binder is `[Finite Q]` (lint-driven), recorded in the phase note; statement of the refactored theorem untouched.
- **Phase 6** altered: the file crossed the 1,500-line `longFile` limit (the plan's per-phase estimates sum past it, and its rollback note says the file "stays well under 1500"); applied the repository-sanctioned `set_option linter.style.longFile N` baseline (1700 in Phase 6, re-tightened to 1800 in Phase 7). No statement or decomposition changed.
- **Phase 8** altered: `lean-challenge-snapshot.sh --check 849 .` exits 71 rather than 0 — five pinned names resolve to two declarations because the research prototype `prototype/helpers-compiled.lean` under `specs/` carries same-named copies and the checker scans the whole tree with no scope flag. Drift was verified independently (whitespace-normalized header diff of all seven pinned declarations against `Challenge.lean`: MATCH 7/7); the prototype was not edited.

## Verification

- Build: Success — unscoped guarded `lake build` exit 0 at every phase end and at the final gate (2895 jobs, 0 errors, 0 warnings); after the `LadderAgree.lean` docstring edit the whole RaySummary chain rebuilt and every `.olean` is newer than its source.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: 0 introduced (the single repository-wide hit, `Examples/TemporalStructures.lean:495`, is present at the baseline commit `4b8fea371` in a file this task never touched)
- Axiom count: 14 (unchanged from baseline)
- Tests: Passed — `verify-deploy.sh` PASS (15 checks, 0 failures); `scripts/typst-sync-check.sh` exit 0 (4/4); the test module's `#guard_msgs` axiom pins on the refactored regime-A assembly and its corollary still pass inside the full build
- `lean_verify` on all 14 landed names: a subset of `[propext, Classical.choice, Quot.sound]`, no sorry (`hasForwardSlack_of_idle_above` uses no axioms)
- Pinned headers: MATCH 7/7 against `Challenge.lean`; `lean-challenge-snapshot.sh --check` exit 71 (advisory; see Plan Deviations)
- `grep -rn "task 8" FormalSystem/ typst/`: empty; `cellLE_zero_const_of_kappa_eq`: docstrings/README prose only
- Files verified: Yes

## Impacts

- The downward direction of the cell-level agreement is now landed at the cell level on the witnessing path under the forward-slack regime; consumers have the regime's entry lemma (a finite witness), its transport, and both halves of the "necessary and satisfiable" pair as library facts.
- The regime-A assembly is a corollary of a reusable given-block raise, available to any construction that must raise a path that has since been shortened.
- The spaced pigeonhole and the room bound are available for any sampling-at-spacing argument inside a region.

## Follow-ups

- The up-first ordering with the clean hypotheses `HasForwardSlack g z (m · (P + 1)) n` and `n + 2 ≤ c` needs copy-boundary types the landed iteration does not expose (a non-goal here).
- A compiled proof that no finite deletion-derivative of the tight (doubling) chain lifts remains argued, not compiled.
- `lean-challenge-snapshot.sh --check` could take a source-root scope (or exclude `specs/`) so research prototypes do not make pinned names ambiguous.

## References

- `specs/849_forward_slack_discharge_and_exact_shift_iteration/plans/01_forward-slack-exact-shift.md`
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/reports/01_forward-slack-exact-shift.md`
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/prototype/helpers-compiled.lean`, `prototype/climb-witness.lean`
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/challenge/manifest.json`, `Challenge.lean`
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/handoffs/phase-{1..8}-handoff-*.md`
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/issues.jsonl`
