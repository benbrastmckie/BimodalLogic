# Implementation Summary: Task #971

- **Task**: 971 - Theorem library: layout and registry
- **Status**: [COMPLETED]
- **Started**: 2026-11-23T22:55:34Z
- **Completed**: 2026-11-24T00:10:00Z
- **Effort**: about 1.25 hours of wall time against a 13-hour estimate
- **Dependencies**: None
- **Artifacts**: plans/01_library-layout-registry.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The Lake library `BimodalLib` now exists beside `BimodalTools`, outside `defaultTargets`, with
the five parts of milestone M18: fragment computation for `Formula` and `PlusFormula`, a
registry of 190 kernel-checked rows for the closed derivations under `FormalSystem/Theorems/`
with a check that fails on an unregistered one, a pairing command, conjecture registration with
nine seeds, and a generated index. All eight plan phases are complete and committed, one commit
per phase. No file under `FormalSystem/` was changed.

## Needs review: three files left uncommitted

The phase 7 commit dropped three paths because they are outside the task's declared
`file_scope`. They are on disk, uncommitted, and were not committed by any other route:

- `BimodalLib/Registry/README.md` (new). `scripts/readme-lint.sh` requires a README beside every
  directory holding `.lean` files; `file_scope` names `BimodalLib/Registry/Complete.lean` but not
  the directory. Without this file at HEAD, `readme-lint.sh BimodalLib` reports one missing
  README.
- `scripts/README.md`. Rows for `library-index.sh` in the script table and the lock table, and
  "nine checks" changed to ten.
- `scripts/check-copyright-headers.sh`. One comment naming the roots CI passes.

The decision owed is whether to add these three paths to the task's scope and commit them, or
to discard the two `scripts/` edits and site the README differently.

## What Changed

- `lakefile.toml` — `lean_lib` entries `BimodalLib` and `BimodalLibTest`; `defaultTargets` unchanged
- `BimodalLib.lean` — hand-maintained root
- `BimodalLib/Fragment.lean` — `Family`, `Fragment`, `Profile` (ordered by inclusion), `profileF`, `profileP`, `Profile.fragment`, `SubstClass`; theorems `profileP_ofFormula`, `fragmentP_ofFormula`
- `BimodalLib/Registry.lean` — `TheoremEntry`, `register_theorem X` and `register_theorem X (dual := Y)`
- `BimodalLib/Registry/Complete.lean` — `assert_registry_complete [P excluding Q]`
- `BimodalLib/Theorems/{Boolean,ModalBoolean,ModalTemporalBoolean}/Base.lean`, `BimodalLib/Theorems/TemporalBoolean/{Base,Dense,ZTime,RTime}.lean` — 190 registration lines, 25 with a declared dual
- `BimodalLib/Theorems/Complete.lean` — runs the check over the root `FormalSystem`
- `BimodalLib/Pairing.lean` — `ReproofEntry`, `reprove X as Y := t`
- `BimodalLib/Conjecture.lean`, `BimodalLib/Conservativity.lean` — `Conjecture`, `ConjectureStatus`; `within`, `withinP`, `DerivableIn`, `DerivableInP`, `ConservativeEdge`
- `BimodalLib/Conjectures/Conservativity.lean` (8 seeds), `BimodalLib/Conjectures/ModalBoolean/Collapse.lean` (1 seed)
- `BimodalLib/Index.lean` — `polarityF`, `library_index [to "path"]`; `BimodalLib/INDEX.md` generated
- `scripts/library-index.sh` — the named command; `--check`, `--no-build`; takes the shared `.lake` lock
- `Tests/BimodalLibTest.lean`, `Tests/BimodalLibTest/{FragmentTest,RegistryCheckTest,PairingTest,IndexTest}.lean`, `Tests/BimodalLibTest/Fixtures/UnregisteredDerivation.lean`
- `.github/workflows/ci.yml` — `Compile BimodalLib`, `Compile BimodalLibTest`, and the index check as the tenth aggregated check; `BimodalLib` added to the copyright and README roots
- `scripts/check-module-invariants.sh` — B3 covers `BimodalLib`; `LIB_ROOTS` has six roots; B2, C3, C7, C15, C16, C19, C20, C25, C26, C27, C29 to C32 scan `BimodalLib/`
- `scripts/verify-all.sh`, `scripts/check-phantom-citations.sh` — check 10; known names
- `typst/generated/status.typ` — `tests-file-count` 92 to 98, `tests-line-count` regenerated, stamp
- `docs/reference/bimodal-lib.md` (new), `ORGANISATION.md`, `docs/ARCHITECTURE.md`, `docs/development/{MODULE_ORGANIZATION,CI_CD_PROCESS,MODULE_INVARIANTS}.md`, `BimodalLib/README.md` and seven directory READMEs, `Tests/README.md`, `Tests/BimodalLibTest/README.md`
- `records/theorem-library.md` — layout, registry, pairing and conjecture definition cut to pointers; `records/proof-mode.md` — M18 marked implemented

## Decisions

- No user decision was raised on `defaultTargets`: `records/theorem-library.md` already decided it, and the description's request predates that text.
- Rows are definitions built from the type of the registered declaration; there is no attribute and no environment extension.
- `reprove` elaborates the term against the type of `X` itself with error recovery off. A `def` with an elaboration error is still added with a `sorry` body, and the pairing row would then have cited it.
- The index reads rows by reduction and reification in `MetaM`, so the library has no `unsafe` code.
- The index check is an aggregated CI check (`id`, `continue-on-error`, a `report` line), as `docs/development/CI_CD_PROCESS.md` requires of a check step; the two compile steps are hard stops.
- A declared dual is checked for a row by `assert_registry_complete`, not at registration, so two laws can name each other.

## Plan Deviations

- **Phase 2, row type** altered: `TheoremEntry` also carries `substClass`, which the description requires.
- **Phase 3, generation** altered: lines were generated from a live scan with the library's own `scanDerivations` and `mkTheoremEntry`, not from `probes/census.tsv`.
- **Phase 4, pairing** altered: direct elaboration instead of a `def ... : type_of% @X` macro; the syntax node is `reproveAs` because Lean core has a `reprove` command.
- **Phase 5, extended-language edge** altered: stated in the first form, over `withinP`; nine conjectures in all.
- **Phase 6, index** altered: no evaluation; `G` and `H` inside an `always` are not counted again; `Tests/BimodalLibTest/IndexTest.lean` added.
- **Phase 7, CI and scans** altered: index check wired as check 10 in CI and `verify-all.sh`; every `FormalSystem + BimodalTools` scan widened except C8; eight directory READMEs added.
- **Phase 8, docs** altered: the full description is the new `docs/reference/bimodal-lib.md`.

## Verification

- Build: Success. `lake build` (3011 jobs), `lake build BimodalLib --wfail` (3029 jobs) and `lake build BimodalLibTest --wfail` (716 jobs) all exit 0 through the build guard, after the last `.lean` edit
- Sorry count: 0
- Vacuous count: 2, both under `FormalSystem/` and present before the task (`AnyPoint` in `Semantics/PointTransport.lean`, `int_domain_universal` in `Examples/TemporalStructures.lean`); none under `BimodalLib/` or `Tests/BimodalLibTest/`
- Axiom count: 14 lines matching `^axiom ` across the source roots, the same 14 as at the pre-task commit; none under `BimodalLib/`
- Tests: Passed. The registration check fails on the fixture and passes once it is registered; `reprove` accepts a second proof of `perpetuity1` and rejects a drifted one; `lake exe runLinter BimodalLib` passes
- Registration counts on the live tree: 190 closed (190 registered), 85 context-form, 56 rules; per file 39, 25, 29, 81, 14, 1, 1, as hypothesized
- Negative checks run by hand and reverted: one registration line commented out fails `BimodalLib.Theorems.Complete` naming the declaration; a scratch `import BimodalLib.Fragment` under `FormalSystem/` fails B3; a hand edit to `INDEX.md` fails `library-index.sh --check`
- `scripts/check-module-invariants.sh --no-build`: fails on C12 and C20, as it did before the task; C6 went from FAIL to PASS during phase 7
- `scripts/verify-all.sh`: 3 of 10 checks fail (module-invariants, readme-lint, paper-definitions), the same three as at the baseline taken before phase 7's edits; the new check 10 passes
- Scoped gate: `bash .claude/scripts/verify-touched.sh` reported ten failing suites, all under `.claude/scripts/tests/` and none naming a file of this task: the eight standing missing-`agent-system/` fixture suites, plus `test-lint-dead-command-recommendations.sh` and `test-deploy-baseline-lib.sh`. The last two were not re-run at the pre-task commit, so their being pre-existing is inferred from their content, not measured. The complete gate set was deferred to the batch stage and not run here
- Plan compliance check: skipped by the script (no identifier in the Goals bullets)
- Files verified: Yes

## Impacts

- `proof_mode_reprove_perpetuity` can enter its scripts with `reprove X as Y := t` against the registered Perpetuity rows.
- A closed derivation added under `FormalSystem/Theorems/` now fails `lake build BimodalLib` in CI until it has a `register_theorem` line and the index is regenerated.
- `scripts/verify-all.sh` and the CI `Report results` step expect ten checks.

## Follow-ups

- Resolve the three uncommitted files above.
- `records/milestones.md` still names `theorem_library_layout_and_registry` as open work; it is outside this task's `file_scope` and was not edited. `docs/README.md` and `docs/reference/README.md` do not yet link `docs/reference/bimodal-lib.md`, for the same reason.
- Few duals are declared: 26 of the 37 rows with `□`, 36 of 38 with `G`, 36 of 38 with `H` and 21 of 29 with `always` have none. The listing in `BimodalLib/INDEX.md` is the work list.

## References

- `specs/971_theorem_library_layout_and_registry/plans/01_library-layout-registry.md`
- `specs/971_theorem_library_layout_and_registry/reports/01_library-layout-registry.md`
- `docs/reference/bimodal-lib.md`, `records/theorem-library.md`, `records/proof-mode.md`
