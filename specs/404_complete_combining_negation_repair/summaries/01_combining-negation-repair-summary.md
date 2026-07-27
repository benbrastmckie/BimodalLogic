# Implementation Summary: Task #404

**Completed**: 2026-07-27 (partial — Phases 1-2 of 10)
**Duration**: ~1 session

## Overview

Completed Phases 1 and 2 of the 10-phase combining-mark (U+0338) negation repair plan for the
`~/Projects/Literature` corpus. Phase 1 established a current, drift-free residual baseline and
closed the plan's stated safety non-negotiable (post-write word-count + byte-delta verification
with automatic rollback). Phase 2 extended the repair engine's composition map (`≈`, `⊩`) and
added a new no-precomposed-form policy (`≜`, `↣`), clearing all 13 `unmapped_base_char` residuals.
A real, corpus-mutating near-miss was found and fixed during Phase 2's first real-corpus write
(see Decisions/Plan Deviations) — no data was ultimately lost, and the fix materially strengthens
the safety contract for all remaining phases.

## What Changed

- `.claude/scripts/literature-repair-combining.sh` — added post-write verification (word count +
  byte delta, checked against the invocation's own captured pre-edit read, never the potentially
  stale on-disk day-start backup) with automatic rollback; switched from `PRECOMPOSED` to the new
  merged `REPLACEMENTS` (`PRECOMPOSED` + `NO_PRECOMPOSED_FORM`) mapping; added a documented,
  env-var-gated `LITERATURE_REPAIR_TEST_INJECT_CORRUPTION` test-only corruption hook.
- `.claude/scripts/literature_combining_detect.py` — added `≈ → ≉` and `⊩ → ⊮` to `PRECOMPOSED`;
  added a new `NO_PRECOMPOSED_FORM` dict (`≜`, `↣` — no Unicode precomposed negation exists for
  either) and merged `REPLACEMENTS` dict.
- `.claude/scripts/literature-convert.sh` — added 8 new `--self-test` fixtures (2 composition-map
  entries, 2 no-precomposed-form entries, plus idempotence variants); 21/21 fixtures pass.
- `~/Projects/Literature/sources/baier_katoen_2008/Baier_Katoen_2008_part{07,08}.md` — 86
  occurrences repaired (73 reproducing the preceding sweep task's original repairs to these two
  files after a transient over-rollback, plus 13 new `≈ → ≉` fixes); idempotent on re-scan.
- `specs/404_complete_combining_negation_repair/residual-ledger-baseline.json` — current, live
  residual ledger (824 → 819 re-derivation with zero drift in Phase 1; 819 → 806 after Phase 2's
  13-occurrence clearance).
- `specs/404_complete_combining_negation_repair/scripts/retriage.sh` — new reusable category ×
  document × base_char breakdown helper, for Phases 3-7 and 10.
- `specs/404_complete_combining_negation_repair/tooling-backups/*.pre-phase{1,2}` and
  `*.post-phase2` — pre/post snapshots of the three edited `.claude/scripts/` files (git-ignored,
  so these are the only recoverable history for tooling changes).

## Decisions

- Post-write verification's delta baseline AND rollback restoration target must be the invocation's
  own captured pre-edit read, never the on-disk backup — the backup contract intentionally never
  overwrites an existing same-day backup, so a file receiving its second-or-later write of the day
  has a backup that predates the most recent legitimate edit. An initial implementation used the
  backup for both roles; Phase 2's first real-corpus write (baier_katoen_2008, already partially
  repaired earlier the same day by the preceding sweep task) exposed this as unsafe — see Plan
  Deviations.
- Phase 2's "up to 20, not 13" optimistic estimate for composition-map reach resolved to exactly
  13 in this corpus: the 15 `unrecognized_gap` entries for `≈`/`⊩`/`≜`/`↣` do not have the base
  char or precomposed form present in their matched gap text, so they are legitimately gap-window/
  ambiguity failures for Phases 3/7, not composition-map gaps.

## Plan Deviations

- **Rollback-target defect found and fixed mid-Phase-2** (see `progress/phase-2-progress.json`
  deviation entry and the plan's Phase 2 Deviations note for the full incident writeup): the first
  real-corpus `--write` attempt on `baier_katoen_2008` correctly detected a delta mismatch and
  refused/rolled back rather than silently mis-writing, but the rollback itself restored the file
  to the stale on-disk day-start backup rather than this invocation's immediate pre-edit state —
  reverting past a legitimate earlier-same-day repair from the preceding sweep task. No data was
  lost: the engine is deterministic given the same input and current code, so re-running `--write`
  against the (correctly pre-edit) file after fixing the rollback-target logic reproduced the
  earlier repairs plus the new fix in one clean, verified pass. The fix was proven via a new
  scratch multi-session regression test before retrying the real-corpus write.
- **Tooling-backup timing** (Phase 1 only): the plan's Rollback/Contingency section requires
  copying a `.claude/scripts/` file BEFORE editing it, since that directory is git-ignored. Phase
  1's edit to `literature-repair-combining.sh` was made before this snapshot was taken; corrected
  retroactively by reconstructing the exact pre-edit content (from an earlier `Read` in the same
  session) and verifying via diff that it reconstructs the true prior state. All Phase 2+ edits
  snapshotted before editing, as intended.

## Verification

- Build: N/A (bash/Python tooling, no build step)
- Tests: `literature-convert.sh --self-test` — 21/21 fixtures pass
- Corpus-wide idempotence: `--dry-run` across all 60 PDF+markdown directories proposes 0 rewrites
  after Phase 2's write
- Scratch-copy regression tests (outside the real corpus, deleted after use): single-session
  corruption-injection rollback, real-corpus idempotence spot-checks (4 already-repaired
  directories), and a new multi-session stale-backup scenario proving the corrected rollback logic
  preserves an earlier legitimate same-day edit — all passed
- Files verified: Yes (residual ledger reconciled against the 403 baseline with zero drift in
  Phase 1; 819 → 806 with exactly the expected composition-map clearance in Phase 2)

## Notes

**Remaining work (Phases 3-10, not attempted this dispatch)**: widen gap-classification tolerance
for `=`/`∈`/`≺`/`⊆` (Phase 3); compound-base handling for `|=` (Phase 4); PDF-offset → part-file
resolution for `baier_katoen_2008`/`venema_1993` (Phases 5-6, the single largest residual
category at ~460 occurrences); long-tail re-triage (Phase 7); `libkin_2004_ch3_ch7` fidelity
justification — no repair attempted, documented non-goal (Phase 8); chunk regeneration + FTS
rebuild (Phase 9); final `index.json` re-stamp and retrieval verification (Phase 10). See the
handoff document for the precise resume point and critical context.

The rollback-target fix from this dispatch is a durable safety improvement that benefits every
remaining write-phase (3, 4, 6, 7) — future dispatches do not need to re-derive or re-verify it,
only to continue relying on it.
