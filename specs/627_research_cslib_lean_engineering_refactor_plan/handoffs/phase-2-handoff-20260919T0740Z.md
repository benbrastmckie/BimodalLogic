# Phase 2 Handoff: Programme document

- **Task**: 627
- **Phases closed**: 1, 3, 2 of 4 (in that order)
- **Session**: sess_1789799001_60286d
- **Next action**: Phase 4 — full gate (`lake build`, `lake build BimodalTest`, full harness
  with build, `check-metalogic-cycles.sh` = 1), count cross-check, summary, final metadata and
  orchestrator handoff.

## State

- New: `docs/development/PUBLICATION_REFACTOR.md` (nine sections; 23-row convention map;
  target layout; lakefile shape; namespace map; templates; measurements with discrepancies;
  Phases 0-9 with `[CITE]`, acceptance and ADR per phase, 6 split into 6.1/6.2; dependency
  order and publication gate with `specs/` untracking moved to the gate; nine paste-ready
  follow-ups A-I).
- Edited: `docs/development/README.md` (index row); `docs/development/MODULE_INVARIANTS.md`
  (backticked mention became a link).
- `scripts/markdown-slash-path-allowlist.txt` untouched (still empty).
- `bash scripts/check-module-invariants.sh --no-build` exit 0; `readme-lint.sh` PASS.
- Library tree still untouched by this task.

## Phase 4 reminders

- Both builds through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- ...`
  under `Bash(run_in_background: true)`; wait for the completion notification.
- Counts in `PUBLICATION_REFACTOR.md` Section 6 and ADR-011 were written from the script's
  output at commit `315881d31`'s tree; re-run `all --json` and diff before the summary.
- Summary path: `specs/627_research_cslib_lean_engineering_refactor_plan/summaries/01_cslib-refactor-plan-summary.md`.
- `user_decision` (non-blocking): `specs/` disposition at the publication gate.
