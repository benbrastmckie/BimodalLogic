# Implementation Summary: Task #937

- **Task**: 937 - Fix red CI workflows on main
- **Status**: [COMPLETED]
- **Started**: 2026-11-18T05:53:04Z
- **Completed**: 2026-11-18T06:45:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_fix-red-ci-workflows.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Both independently red CI workflows on `main` are addressed, across what turned out to be three
independent causes rather than two. `CI / Build and Test` was red for a name ambiguity on
`closureList` and, behind it, for a `lint-style` failure the ambiguity's hard stop was masking;
`API Documentation` was red for an out-of-memory kill during the doc build, not for the
`srcUri.github` misconfiguration the task record named. The C16-roots surfaces that excused the
`closureList` defect are reconciled in the same change that removes it.

## What Changed

- `BimodalTools/CertificateImport.lean` — `closureList` -> `closureListDedup`, now defined through
  the core declaration as `(FormalSystem.Metalogic.Decidability.closureList S).dedup`;
  `mem_closureList` -> `mem_closureListDedup`, proved by
  `simp [closureListDedup, List.mem_dedup, mem_closureList]`. Three internal call sites and four
  docstring mentions retargeted, and the alias waiver recorded in the module docstring. No import
  added: the core module was already in this module's import closure.
- `BimodalTools/README.md` — the `CertificateImport.lean` inventory row: name and recorded line
  count (599 -> 609).
- `Tests/BimodalToolsTest/CertificateImportTest.lean` — both `#guard` heads at lines 146 and 152.
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` — one space deleted before
  `;` on each of lines 383, 390, 413, 420. Four characters, nothing else on those lines.
- `.github/workflows/docs.yml` — a defensive, self-diagnosing 16G swapfile step before the docgen
  step, and one `PREREQUISITES` bullet recording the memory requirement and the misleading
  `srcUri.github` attribution.
- `scripts/c16-roots-unmeasurable.txt` — the `BimodalToolsTest` excuse row removed; the file now
  carries its format header and no rows.
- `docs/development/MODULE_INVARIANTS.md` — the unmeasurable-root paragraph rewritten to state
  that every root is measurable and none is excused, with the mechanism's purpose preserved.
- `FormalSystem/Metalogic/Expressiveness/README.md`,
  `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md` — `Last verified` stamps refreshed
  to 2026-11-18.
- `typst/generated/status.typ` — regenerated (`tools-line-count` 18142 -> 18152).

## Decisions

- **Rename rather than qualify the two call sites.** The rename closes the latent
  `mem_closureList` half of the collision class as well as the live `closureList` half; qualifying
  the two erroring sites would have left the latent one armed. Qualification stayed available as a
  measured fallback and was not needed.
- **No deprecated alias on the rename, waiving the style guide's rename-alias requirement.** An
  alias retaining the bare name in this namespace is visible to every module opening both
  namespaces, and Lean reports a bare reference under two such opens as `Ambiguous term` whether
  the second interpretation is a `def` or an alias — so an alias would reinstate the exact defect.
  `BimodalTools` sits outside `defaultTargets`, every use site is in-repo, and there are no
  external consumers. The waiver and its mechanism are recorded in the module docstring itself.
- **`API Documentation`'s diagnosis corrected in the workflow's own header.** The task record and
  `specs/ROADMAP.md` both name `srcUri.github` configuration. The failure log carries exactly two
  error classes — 13 `resource exhausted (error code: 12, cannot allocate memory)` and one
  `build failed` — with no URI, git-remote, or configuration error, and the Pages fail-fast check
  passing. The `srcUri.github` targets are the cheap `git`-subprocess jobs in flight when memory
  ran out. Recording this in the header is what stops the next reader re-deriving the wrong fix.
- **No parallelism knob added.** Lake 5.0.0 exposes no `--jobs`/`-j`, and the doc build's
  `lake build` lives inside the pinned action's own script, which the workflow cannot pass
  arguments to. An unverified env-var knob on speculation was rejected.
- **The C16-roots clean branch, with the baseline untouched.** `lake exe runLinter
  BimodalToolsTest` reports `-- Linting passed`, so the excuse row goes and no baseline row is
  added. `scripts/c16-roots-baseline.txt` is byte-untouched.

## Plan Deviations

- **Phase 4, `MODULE_INVARIANTS.md` task** — altered, annotated inline on the plan checklist. The
  phase Goal reads "correct the two prose records that assert it is unmeasurable", which was first
  read as including `scripts/check-module-invariants.sh`'s own C16 header block (which carries the
  identical `ONE ROOT IS CURRENTLY UNMEASURABLE, NOT ZERO` assertion).
  `git-commit-scoped.sh`'s V10 containment guard dropped that path: it is outside both the phase's
  Files-to-modify list and the task's declared `file_scope`. The edit was reverted rather than the
  guard overridden, and the reconciling reading is that the two prose records are the excuse row's
  own reason text and the `MODULE_INVARIANTS.md` paragraph — both corrected. The script's header
  assertion is now stale and is carried as a follow-up below.
- **Phase 5, gate set** — two README `Last verified` stamps had to be refreshed that no phase's
  Files-to-modify list named, though both are in the task's declared `file_scope`. See Verification.

## Verification

- Build: Success — full `lake build` exits 0 with 0 `error:` lines over 2991 jobs, and `lake build
  --wfail` over the CI roots exits 0. Verified at every phase end, not only finally.
- Sorry count: 0
- Vacuous count: 1, and it is neither new nor genuinely vacuous.
  `FormalSystem/Examples/TemporalStructures.lean:495`'s `int_domain_universal ... := trivial` is
  byte-identical at pre-task HEAD (`ca101c1c5`), was not touched by this task, and is a true
  statement about a universally-true predicate rather than a placeholder — the regex matches on the
  `trivial` body, not on a `True` goal. Introduced by this task: 0.
- Axiom count: 14, unchanged from the pre-task baseline of 14 (12 under `FormalSystem/` + 2 under
  `Tests/BimodalTest/`). No increase.
- Tests: Passed — `lake test` exits 0.
- Files verified: Yes.

Complete local gate set, all exit 0: `lake build --wfail`; `lake test`; `lake lint`;
`lake build BimodalTools --wfail`; `lake build BimodalToolsTest --wfail`;
`lake build BimodalToolsTest.CertificateImportTest`; `lake exe lint-style`;
`lake exe mk_all --lib FormalSystem --check`; `scripts/check-evidence-probes.sh` (67 wired probes,
and the known `FAIL (untracked: …)` transient the research report documented did not appear);
`scripts/check-module-invariants.sh --no-build`; `scripts/readme-lint.sh FormalSystem
BimodalTools`; `scripts/check-metalogic-cycles.sh`; `scripts/typst-sync-check.sh`.
Plus `python3 scripts/c16_roots_baseline.py` over a fresh 18-root log set: exit 0,
`231 finding(s) across 15 root(s), all at or below baseline`, with no `BimodalToolsTest` INFO
excuse line and no `NEW` or `ABOVE` row.

`readme-lint.sh` failed once mid-phase, with 2 new stale dates at
`FormalSystem/Metalogic/Expressiveness/README.md` and
`.../Expressiveness/SeparationZ/README.md`. Cause: commit `308763088` (this task's Phase 2) is
the only commit touching `Expressiveness/` on 2026-11-18, so the directory's last-commit date
moved past both stamps. Neither README's content went stale — both record `NormalForm.lean` line
counts (514 for the `SeparationZ` file edited, 884 for the unrelated `Expressiveness` one) and the
edit changed no line count. Both stamps were refreshed and the gate re-run to PASS with 0 new
stale dates. Both paths are in the task's declared `file_scope`.

**USER-PENDING, never recorded as met**: the task record's third criterion — both workflows
reporting success on a real run — is the user's to close. `.claude/rules/pr-prohibition.md` bars
this agent from pushing or re-running a workflow. For `API Documentation` specifically, that
pushed run is the ONLY verification of the swap fix that exists: the failure being fixed is a
property of the GitHub runner's memory and is unverifiable on this machine.

## Impacts

- `lake build BimodalToolsTest` and `lake exe runLinter BimodalToolsTest` work for the first time,
  so `BimodalToolsTest` is a measurable C16-roots root rather than an excused one, and the
  repository's own health checks now return readable results instead of a hard stop.
- `lake exe lint-style` is green, so `ci.yml`'s aggregating `Report results` step can reach green
  once the earlier hard stop is gone.
- `mem_closureListDedup` and the core `mem_closureList` are now both reachable unqualified from a
  module opening both namespaces.

## Follow-ups

- `scripts/check-module-invariants.sh`'s C16 header block still asserts `ONE ROOT IS CURRENTLY
  UNMEASURABLE, NOT ZERO` naming `BimodalToolsTest`. That assertion is now false. The path is
  outside this task's declared `file_scope`, so the correction needs its own task or a scope
  amendment. Replacement text: the same "every root is measurable, and none is excused" framing
  `docs/development/MODULE_INVARIANTS.md` now carries, preserving the mechanism's purpose.
- `ci.yml`'s steps 7, 14 and 15 are hard stops that mask the `continue-on-error` checks below
  them — which is why the `lint-style` failure was invisible until the `closureList` ambiguity was
  fixed. Hardening them with `if: ${{ !cancelled() }}` was deliberately out of scope here (the
  task's scope boundary permits touching `.github/workflows/` only as far as the doc-gen4 fix
  requires, which is `docs.yml` alone).
- A one-line scope note for the style guide's rename-alias requirement, so the next rename into a
  namespace that collides under a shared `open` does not re-collide by following the rule.
- `specs/ROADMAP.md` carries the refuted `srcUri.github` characterization of this workflow's
  redness. Correcting it is roadmap maintenance, owned by `/roadmap`.
- If the swap step does not fix the OOM on the pushed run, the documented next remedies in order
  are (a) vendor the doc build so the `lake build` invocation comes under this repository's
  control and can be serialized, then (b) a larger runner, which is a billing and authorization
  decision only the user can make.

## References

- `specs/937_fix_red_ci_workflows_on_main/plans/01_fix-red-ci-workflows.md`
- `specs/937_fix_red_ci_workflows_on_main/reports/01_fix-red-ci-workflows.md`
- `specs/937_fix_red_ci_workflows_on_main/handoffs/` — per-phase handoffs 1 through 4
- `specs/578_fix_api_documentation_ci_integration/plans/01_docgen-ci-fix-path.md` — consulted;
  its `docs.yml` rewrite is intact and unmodified, so it supplies the file's current design
  rationale rather than a fix to restore
