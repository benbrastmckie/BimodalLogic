# Phase 1 Handoff — task 380 (2026-07-24)

## Immediate Next Action (Phase 2)

1. `bash .claude/scripts/git-snapshot.sh` (mandatory before `--apply`).
2. `python3 specs/380_sweep_stale_task_number_pointers_from_lean_sources/scripts/rewrite_task_refs.py --apply Theories`
3. Verify `git diff --stat` file set ⊆ the 130-file dry-run set; diff must match
   `worklists/phase2-autodrop.diff` exactly; run `--check-diff --base HEAD`; gates:
   `lake build` EXIT 0, census 906/820/26, recount = **959** (1,549 − 590; see counts.md
   arithmetic — NOT 1,549 − 469).

## Current State

- Phase 1 [COMPLETED]; phases 2-8 not started. Zero modifications under `Theories/`.
- Script `scripts/rewrite_task_refs.py` (modes: --count/--dry-run/--apply/--worklist/
  --check-diff), `scripts/protected-decls.txt` (4 decls by name), worklists complete:
  `baseline.md`, `counts.md`, `dryrun-report.txt`, `phase2-autodrop.diff`,
  `handedit-phase{3..7}.md` (162/173/222/144/266 entries).
- Build EXIT 0 (1789 jobs, 1 pre-existing warning), census 906/820/26, recount 1,549/192
  — all reconciled with the research inventory.

## Key Decisions (this phase)

- Comment-span assertion never *writes* outside comments; non-comment matches (6 string
  literals) are excluded from auto-drop and worklisted with a NON-COMMENT marker (plan
  Rollback/Contingency provision — phase boundaries unchanged).
- Sorry-line rule enforced absolutely: 14 sweep-matching sorry-lines are DEFERRED (report
  estimated ~0). **Recount floor after phases 2-7 is 14** unless the orchestrator makes a
  supervised decision on prose-only sorry mentions. Do not resolve unilaterally.
- EANegation.lean has no sorry-adjacent decl (its 1 sorry is docstring prose) — protection
  note recorded in protected-decls.txt instead of a decl name.
- `--check-diff` compares comment-stripped, whitespace-normalized, blank-line-filtered
  code (raw comparison was falsified by a unit test: comment padding differs by length).

## Sorry Inventory

Empty — no Lean proof edits in this phase; census invariant 906/820/26 untouched.
(The 14 deferred sorry-PROSE lines above are sweep-scope bookkeeping, not proof sorries.)
