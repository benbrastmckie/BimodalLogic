# Implementation Summary: Task #733

- **Task**: 733 - Probe the backward-dual stability summary on a backward-NONDETERMINISTIC mirror fixture (E1's hard test)
- **Status**: [COMPLETED]
- **Started**: 2026-10-09T07:33:00Z
- **Completed**: 2026-10-09T07:51:25Z
- **Effort**: ~1 hour
- **Dependencies**: 739 (completed)
- **Artifacts**: plans/01_backward-dual-mirror-fixture.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed the mirror-fixture probe `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`
(namespace `Probe733Mirror`) and wired it into `scripts/check-evidence-probes.sh`. On Probe710's
step graph with every arrow reversed -- forward deterministic, **backward branching factor exactly
2 at every spine state `aft (k+1)`** -- the backward stability operator `⊡(P p)` at a seam state is
exactly "every backward root path from that state meets the `p`-set", decided by backward
reachability alone and state-dependently (True at `aft`, False at `x` and `bef`). The result is
**POSITIVE**: the two-factor ray presentation is not falsified at the backward factor where the
finite-width refutation inhabits, and E1's "hard test is a mirror fixture, filed as a follow-up"
note is discharged. No negative finding occurred, so no C9-style register entry was written.

## What Changed

- `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` -- Created (new
  probe, 656 lines). Body lifted byte-identically from the research prototype; collection-style
  header added. Key declarations: `bwdList_aft_succ_length` (branching factor 2, by `rfl`),
  `two_preds_aft`, `two_bwd_paths` (two distinct backward root paths from `aft (m+1)`,
  axiom-free), `bwd_reaches_x` (every backward root path from `aft m` meets an `x` state at
  `0 < n ≤ m+1`, both branches of `step_inv_aft` closed by induction), `allBwdPathsMeet_iff`,
  `stabPast_iff_aft`, `pastStab_iff_allBwdPathsMeet`, `past_stab_at_aft`, `not_past_stab_at_x`,
  `not_past_stab_at_bef`, `decide_past_stab`, `decidable_past_stab`.
- `scripts/check-evidence-probes.sh` -- One `WIRED` entry and one comment-table row directly after
  the E1 entries; pointer-only amendment of the E1 row's final clause ("filed as a follow-up and
  discharged by the mirror-fixture entry below"). E1's `.lean` file is byte-identical to HEAD.

## Decisions

- Lifted the prototype verbatim (no proof edits), as the plan requires; the choice-free
  `bwd_reaches_x` (explicit `Nat.*` lemmas, no `omega`) stays at `[propext]`.
- Re-verified the plan's claim that `hist_canon` routes through `FrameOver.mem_HF_iff_adjacent`
  against the source before writing it into the header's axiom-record paragraph.
- Took the plan's optional E1 table-row pointer amendment (comment only; the row's wording matched
  the research read).
- The header carries the "honest limit" (finite backward branching gives the König-shaped uniform
  bound `n ≤ m+1`; computability under infinite backward branching is a device-selection question
  held by `device-selection-probe.lean`) and a "What this does NOT do" paragraph mirroring E1's.

## Plan Deviations

- None (implementation followed plan). Testing & Validation item "`lean-challenge-snapshot.sh
  --check` where available" fell to its stated fallback: no `challenge/manifest.json` exists for
  this task, so a manual signature diff of all 16 Challenge-pinned declarations was run instead
  (all match).

## Verification

- Build: Success -- `lake-build-guard.sh build --timeout 1800 -- build`: guard exit 0,
  `Build completed successfully (2837 jobs)`, 0 `error:` lines, 0 `warning:` lines. The probe
  itself lives outside the Lake build graph; its covering check is
  `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`: exit 0,
  0 errors, 0 warnings, run after each of Phases 1, 2, 3.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots; `grep -c sorry` on the
  probe: 0)
- Vacuous count: 0 in files touched by this task. (The repo-wide grep reports one pre-existing hit,
  `FormalSystem/Examples/TemporalStructures.lean:495` `int_domain_universal ... := trivial`,
  present identically at the pre-task commit `0c0ab607e`; not touched by this task.)
- Axiom count: 15 before, 15 after (no `axiom` declarations introduced; probe adds 0)
- Axiom record (printed == header, verbatim): `two_bwd_paths` no axioms; `bwd_reaches_x`
  `[propext]`; `allBwdPathsMeet_iff` `[propext, Quot.sound]`; `stabPast_iff_aft`,
  `pastStab_iff_allBwdPathsMeet`, `decide_past_stab` `[propext, Classical.choice, Quot.sound]`.
- Evidence gate: `bash scripts/check-evidence-probes.sh` -- PASS 25/25 before the edit, PASS 26/26
  after, exit 0, PASS line for `seam-gluing-ray-product/backward-dual-mirror-fixture`.
- `bash .claude/scripts/verify-deploy.sh`: PASS (14 checks, 0 failures).
- Plan compliance spot-check: all 15 Goals-named declarations found; no replacement targets.
- Tests: N/A (no test-suite change; the evidence gate is the test)
- Files verified: Yes

## Impacts

- The backward dual of the finite-graph `⊡` summary is now proved at a genuinely branching backward
  factor, so the two-factor ray-product presentation no longer rests on a forward factor plus a
  degenerate (singleton) backward one. E1's follow-up note is dischargeable by pointer.
- Task 725 appears subsumable by E1 per the research report; that is a task-management call for
  the orchestrator/user, not acted on here.

## Follow-ups

- None required by this task. The residue the header names -- finite computability of "all
  backward paths meet" under infinite backward branching -- belongs to device selection
  (`device-selection-probe.lean`), not to a further fixture.

## References

- Plan: specs/733_backward_dual_mirror_fixture_branching_probe/plans/01_backward-dual-mirror-fixture.md
- Research: specs/733_backward_dual_mirror_fixture_branching_probe/reports/01_backward-dual-mirror-fixture.md
- Prototype: specs/733_backward_dual_mirror_fixture_branching_probe/prototype/backward-dual-mirror-fixture.proto.lean
- E1 probe: specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean
- Commits: 5604c4df4 (phase 1), 343fb473c (phase 2), 233505e27 (phase 3)
