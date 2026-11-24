# Phase 4 handoff

- **Immediate next action**: Phase 5 — `specs/evidence/proof-mode-cost-baseline/cost-probe.lean` (52 acceptance mirrors + the `lintro` and `lrewrite` ladders + simplifier and views rows) and its `README.md`.
- **State**: Phases 1–4 COMPLETED and committed. Full `lake build` green; `lake build BimodalLib BimodalLibTest --wfail` exit 0; all 16 `#guard_msgs` rows in `Tests/BimodalLibTest/DiagnosticsTest.lean` pass; `typst-sync-check --counts-only` MISMATCH_COUNT=0; `readme-lint` unchanged at the baseline's 4 pre-existing findings; `check-copyright-headers --strict` 0 missing; `library-index --no-build --check` current.
- **Scope hypothesis resolved**: the plan guessed four `throwError` paths. The real count is **eight**, each pinned one-for-one. The emitters' arguments are read positionally from the syntax node and the keyword atoms are non-reserved (`&" stage "`), both forced by Lean parser behaviour rather than style.
- **Corroboration of the research report**: `term_size` for `lstart; lapply; lexact` measured 99 — exactly the report's Measurement 4 figure. A closed instance of the same script measures `derivation_size` 3 / `derivation_height` 1, and the report's own `height = 1` for that script agrees.
- **Emitter invocation shape** (needed by Phases 5 and 7):
  `#reprove_record <decl> stage "reprove" outcome "closed_by_rules" failure "none" tactics "a,b,c" escape 0 in <declaration>`
  `#compare_record <script> <reference> kind "hand" lengths <n> <m>`
  Stamps: `lake env lean -Ddiagnostics.commit=<sha> -Ddiagnostics.date=<date> -Ddiagnostics.command=<cmd> [-Ddiagnostics.zeroTimings=true]`.
