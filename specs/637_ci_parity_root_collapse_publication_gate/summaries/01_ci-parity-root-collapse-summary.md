# Implementation Summary: Task #637

- **Task**: 637 - CI parity, root collapse and publication gate
- **Status**: [COMPLETED]
- **Started**: 2026-09-21T16:01:48Z
- **Completed**: 2026-09-21T17:58:00Z
- **Effort**: about 2 hours wall clock, most of it four background rebuilds and two full linter sweeps
- **Dependencies**: 636 (complete)
- **Artifacts**: plans/01_ci-parity-root-collapse.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 8 of the publication-refactor programme, all ten plan phases closed. The two-level library
root is collapsed into one `mk_all`-generated `FormalSystem.lean`; the C6 unreachable-module
manifest is empty; CI gained `mk_all --check`, the text-based style linters and `--wfail` on the
tooling; a tag-triggered release workflow exists; and the publication gate is recorded as
satisfied, with three items handed to the maintainer. No theorem statement changed and no proof
was touched: every Lean edit is a header, a docstring, a blank line, an import, or a module split.

All three acceptance criteria hold: `lake exe mk_all --lib FormalSystem --check` exits 0; the C6
manifest has zero live entries; the release workflow's dry-run passes in the half that can be run
locally (see "Maintainer handoff" for the half that cannot).

## What Changed

- `FormalSystem.lean` — now the byte-for-byte output of `lake exe mk_all --lib FormalSystem`: 504
  import lines, no header, no docstring. `FormalSystem/FormalSystem.lean` — deleted (absorbed).
- `FormalSystem/Version.lean` — new; `def version : String := "1.0.0"`, agreeing with `CITATION.cff`.
- 21 `FormalSystem` files — latent `linter.style.header` debt cleared *before* the collapse: 13
  module docstrings moved directly after the imports (line-count-preserving), `OrderIsoReal.lean`'s
  pre-import comment promoted to a module docstring, two files given the docstring they lacked,
  and the broad `import Lean` deleted from five files.
- `BimodalTools/ContrastiveGenerator.lean`, `BimodalTools/ProofFirstGenerator.lean` — new library
  modules split out of their `*Main` roots, which are now thin `main`s. `BimodalTools.lean` imports
  both (15 non-`Main` modules).
- `Tests/BimodalTest.lean`, `Tests/BimodalToolsTest.lean` — five previously unreachable test
  modules wired in; `DerivationBenchmark.lean` lost its one top-level `#eval`.
- `scripts/module-invariants-manifest.txt` — 14 live entries to 0; comment blocks kept as history.
- `scripts/check-module-invariants.sh` — new enforced check **C33** (generated root is
  byte-current; build-free python mirror of the generator); B3 scans the one surviving root; C8's
  dead self-named allowlist entry removed; C16's recorded table re-measured; C28's decision block
  and stale "floor is 7" note rewritten.
- `.github/workflows/ci.yml` — `mk_all --lib FormalSystem --check` step; `lake exe lint-style`
  step; `--wfail` on the two tooling build steps. `.github/workflows/release.yml` — new.
- `lakefile.toml` — `weak.linter.unicodeLinter = false` with the measured reason.
- 26 `FormalSystem` files — 79 empty lines inside commands deleted (see Decisions); 32 citer files
  — 158 `file.lean:NNN` citations re-anchored by `reanchor-lean-citations.py --exact`.
- `ORGANISATION.md` — module-size policy, eight-row namespace-exception index, corrected `specs/`
  row. `CHANGELOG.md` — new, with the `1.0.0` entry. Docs updated: `CI_CD_PROCESS.md`,
  `MODULE_INVARIANTS.md`, `LEAN_STYLE_GUIDE.md`, `VERSIONING.md`, `PUBLICATION_REFACTOR.md`,
  `DIRECTORY_README_STANDARD.md`, `TESTING_STANDARDS.md`, `BENCHMARKING_GUIDE.md`, and the affected READMEs.
- `scripts/check-copyright-headers.sh` — `WHY THIS EXISTS` block corrected; script kept.

## Decisions

- **The header-linter debt was measured by re-elaboration, never by a warm build.** Confirmed on
  the untouched tree: `lake build --wfail` green while the scratch-CWD probe fired on
  `ConcatPin.lean`. Two full sweeps (503 files against a would-be root, 504 against the real one)
  reported zero findings. Phase 7 then supplied stronger evidence for free: the `lakefile.toml`
  option change invalidated every trace, forcing a genuine re-elaboration of all 504 modules with
  the linter live, and it reported no header finding.
- **`check-copyright-headers.sh` is kept.** The task asked whether `linter.style.header` under
  `--wfail` makes it redundant. For the 504 `FormalSystem` modules, yes, and the linter is
  stronger. For the 12 `BimodalTools/*Main.lean` roots and everything under `Tests/`, the linter
  structurally cannot run. The script's stated premise (a `srcDir` the lakefile never set) was
  wrong and is corrected.
- **C33 is a scanner, and `mk_all --check` is also a CI step.** The scanner runs under CI's
  `--no-build` pass; the real generator runs as its own step so a Mathlib bump that changes
  `mk_all`'s output is caught by the tool rather than by a drifted mirror.
- **`--wfail` adopted on both tooling steps**, on a real `--wfail` build of both roots, not on the
  trace scan alone. `ENFORCE_C16_ROOTS` stays 0.
- **All eight namespace exceptions kept, none renamed**; indexed in `ORGANISATION.md`.
- **`CHANGELOG.md` created** rather than `VERSIONING.md`'s nine references corrected away: the
  release workflow reads its notes from it.

## Plan Deviations

- **Phase 2 / Phase 3** altered: the nine manifest entries made reachable by the collapse were
  deleted inside Phase 2's atomic batch, not in Phase 3. C6's build-free half fails the moment an
  entry names a reachable module, so deferring them would have committed a red gate.
- **Phase 2** altered: C12 fails on `PUBLICATION_REFACTOR.md`'s three historical mentions of the
  absorbed path, which the plan said to leave. They were left, and the path was added to
  `scripts/markdown-slash-path-allowlist.txt` on that file's own cited-as-history precedent. A
  fifth free prose reference the plan's grep missed (`FormalSystem/Semantics.lean`) was rewritten.
- **Phase 4** altered: `ProofFirstTests`' import of `ProofFirstGeneratorMain` is **not**
  vestigial — Test 12 calls `_root_.main`. The root was split like the contrastive one
  (`runProofFirstGenerator` in a new library module), which keeps the CLI smoke test.
- **Phase 4** altered: `DerivationBenchmark.lean` had one top-level `#eval`, not five.
- **Phase 5** altered: the CI step added runs `lake exe mk_all --lib FormalSystem --check`, not a
  second copy of the scanner, which the existing `--no-build` step already runs.
- **Phase 6** altered: C16 re-measured at **196 findings across 13 of 16 non-`FormalSystem`
  roots** (not 170), `BimodalTest` at 80 (not 67). Neither is new debt: the Phase 4 split made 13
  more findings countable under `BimodalTools` (1 to 14), and three newly wired tests made 13
  countable under `BimodalTest`.
- **Phase 7** altered: `lint-style --fix` was whitespace-only but not harmless. 79 stripped lines
  sat inside commands and became truly empty, which `linter.style.emptyLine` flags — a red
  `--wfail` build. The lines were deleted and citations re-anchored.
- **Phase 7** altered: **`lint-style-action` itself was not wired; `lake exe lint-style` was.** See
  the next section.
- **Phase 9** altered: two of the three docstrings already had the section under a nonstandard
  heading, renamed in place. `ORGANISATION.md` also gained a one-line `BimodalTools/` row.

## Decision for the user: `lint-style-action` versus its linting core

The task names `lint-style-action`. Measured, the action's `check` mode cannot go green here: it
runs `credfeto/action-no-ignored-files`, which fails on any tracked path that
`git check-ignore -v --no-index` prints, and it prints 37 — 32 matches of the two `.gitignore`
negation patterns that keep `specs/**/.orchestrator-handoff.json` and `.return-meta.json` tracked
(`-v` prints negated matches too), and 5 force-tracked files under `specs/archive/`. `specs/` is
tracked and published by recorded user decision. The action also wipes the workspace, rebuilds
`lint-style` without the Mathlib cache, and publishes no tags (SHA pin only).

What was wired instead: `lake exe lint-style` as a direct step reusing the warm cache, plus the
action's two other `check`-mode guards (no executable-bit Lean file, no case-colliding tracked
paths), both green. The alternative — restructuring `.gitignore` and untracking the archive
files so the action can run — touches the `specs/` policy and is the user's call. Recorded as a
non-blocking `user_decision`.

## Verification

- Build: Success — `lake build --wfail` (2663 jobs), run through the build guard, at the final
  Lean state; also `lake build BimodalTools BimodalToolsTest --wfail` and `lake test`.
- Sorry count: 0 (`FormalSystem/`, `BimodalTools/`)
- Vacuous count: 0. The prescribed grep returns one pre-existing hit,
  `Examples/TemporalStructures.lean:483`, a genuine theorem whose proof is `trivial`; untouched.
- Axiom count: 14 `^axiom ` lines before and after (no `axiom` declaration added).
- Tests: Passed (`lake test`, `lake lint`).
- Gates, all exit 0: `check-module-invariants.sh` in full mode (C6 empty, C25 13/13, C28 0
  warnings, C33 pass) and `--no-build`; `mk_all --lib FormalSystem --check`; `lint-style`;
  `checkInitImports`; copyright headers; `readme-lint`; evidence probes; metalogic cycles;
  `typst-sync-check`; `check-paper-definitions`.
- C33 negative tests, both directions: stray module and hand-edited root each gave `FAIL C33` with
  script exit 1, agreeing with `mk_all --check`; both restored to `PASS`.
- CI step bodies, extracted from the committed YAML: `mk_all`, both tooling builds, `lint-style`.
- Plan compliance check: skipped — the plan is `Lean Intent: false` and its Goals name no Lean
  identifier; the heuristic would report workflow and check IDs as missing theorems.
- Files verified: Yes

## Maintainer handoff

None of these was done; agents do not push, tag or release.

1. Create and push the `v1.0.0` tag (`docs/development/VERSIONING.md` has the procedure).
2. Run `.github/workflows/release.yml` once via `workflow_dispatch` with `publish` off and confirm
   it is green. **This is the unverified half of the "release workflow dry-run passes"
   criterion.** Locally certified: the YAML parses, all three action pins resolve, and the
   version-resolution and release-notes bodies behave against the real files. Not certified: `${{ }}`
   expressions, the `if:` condition, the lean-action step, the publish step, token permissions.
3. Confirm `CITATION.cff`'s `date-released` (`2026-09-07`) and the same date in `CHANGELOG.md`'s
   `[1.0.0]` heading at tag time; add the `doi` when minted.
4. The two new CI steps compile and link `mk_all` and `lint-style` on a cold runner; local timings
   exclude that. The `CI_CD_PROCESS.md` budget rows say so and await an Actions-measured figure.

The publication-gate untracking needed no action: `CLAUDE.md`, `.claude-extensions.json` and
`.syncprotect` were already untracked and gitignored (commit `6ac3b3844`), `.gitattributes` has
never existed, and `specs/` remains tracked.

## Impacts

- No `FormalSystem` module can be unreachable from `lake build` while the generated root is
  current, and C33 fails when it is not. Adding, moving or deleting a module now requires
  `lake exe mk_all --lib FormalSystem`.
- Every `FormalSystem` module is under `linter.style.header` in CI: a module docstring that is not
  the first command after the imports, or a broad import, fails the build.
- Tooling compiler warnings fail CI. Trailing whitespace fails CI.
- A test must never import an executable root; split the root instead (three precedents exist).
- C16's reported total rose 170 to 196 with no new debt; read the recorded explanation before
  treating it as a regression.

## Follow-ups

- `Tests/` (65 files) is not in CI's `check-copyright-headers.sh --strict` invocation and the
  header linter cannot reach it. `--strict Tests` is clean today; adding it is a one-word change.
- The C16 burndown (196 findings, 80 in `BimodalTest`) and the two size splits remain out of scope.
- `docs/development/CI_CD_PROCESS.md` still recommends `lake lint -- --fix` in two places;
  `runLinter` has no `--fix`. Pre-existing; left alone.
- Context-extension note for `context/project/lean4/tools/` (authored in the source store, not
  here): `isInLibraryRoot`'s direct-import gate and the trace-replay blind spot; the
  `srcDir`-versus-directory asymmetry in `mk_all`; `lint-style --fix` exposing `emptyLine`
  findings; `lint-style-action`'s no-ignored-files guard and `check-ignore -v` negations.
- The declared `file_scope` (9 entries) covered a small fraction of this footprint. Two generated
  README inventories in task 614's declared territory were re-emitted (numeric cells only) and
  three root-collapse passages in them rewritten, each time with the file clean beforehand.
  Observed throughout and left untouched: uncommitted foreign edits in
  `typst/chapters/p4-dataset-pipeline.typ` and `typst/sync-check-whitelist.txt`.

## References

- `specs/637_ci_parity_root_collapse_publication_gate/plans/01_ci-parity-root-collapse.md`
- `specs/637_ci_parity_root_collapse_publication_gate/reports/01_ci-parity-root-collapse.md`
- `docs/development/PUBLICATION_REFACTOR.md` (Phase 8 entry and gate status)
- `docs/development/MODULE_INVARIANTS.md` (C33 row and negative-test record)
- Commits `234578e7e` through `cd4c22fff`, plus the closing commit
