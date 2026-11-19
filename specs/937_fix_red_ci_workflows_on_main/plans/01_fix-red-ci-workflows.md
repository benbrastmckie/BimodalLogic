# Implementation Plan: Task #937

- **Task**: 937 - Fix red CI workflows on main
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None (tasks 829 and 938 are adjacent in `.github/workflows/` and
  `scripts/` territory; 938's `scripts/c16-roots-*` artifacts are an input to Phase 4, not a
  blocking dependency)
- **Research Inputs**: `specs/937_fix_red_ci_workflows_on_main/reports/01_fix-red-ci-workflows.md`
  (Finding 1 complete; Finding 2 left PENDING and root-caused during this planning dispatch)
- **Artifacts**: plans/01_fix-red-ci-workflows.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two independently red workflows on `main`, now three independent causes. `CI / Build and Test`
is red for a name ambiguity (`closureList`, declared in two namespaces a test opens) AND for a
second, currently-masked `lint-style` failure that only surfaces once the ambiguity's hard stop
stops skipping later steps. `API Documentation` is red for a cause the task record names
incorrectly: every one of its failures is an out-of-memory kill during the doc-gen4 build, not a
`srcUri.github` misconfiguration.

Phases 1-3 are three disjoint file territories and run in parallel. Phase 4 reconciles the
`scripts/c16-roots-*` surfaces that Phase 1's fix makes stale. Phase 5 runs the complete gate
set, commits, and names the one remaining step only the user can take.

### Premise Re-Validation

The dispatch flagged two carried lines (the `sorryAx` errors at
`Tests/BimodalToolsTest/CertificateImportTest.lean:146:0` and `152:0`). Checked against the prior
report and live state this dispatch:

| Carried claim | Verdict |
|---|---|
| `closureList` declared at `BimodalTools/CertificateImport.lean:149` | **CONFIRMED unchanged** (`def closureList` at line 149) |
| `closureList` declared at `.../Compression/Enumerate.lean:137` | **CONFIRMED unchanged** (`def closureList` at line 137) |
| Test opens both namespaces at lines 37 and 40 | **CONFIRMED** (`open FormalSystem.Metalogic.Decidability` line 37, `open BimodalTools.CertificateImport` line 40) |
| Both `#guard` sites at test lines 146 and 152 | **CONFIRMED** (both `#guard (closureList gamma…)` heads intact) |
| `sorryAx` lines are a consequence of the ambiguity, not sorry debt | **CONFIRMED** by the report's reproduce (probe 1) — not re-run here, since no input moved |
| Finding 2: "doc-gen4 dependency source URIs… Configuration, not library code" | **REFUTED** — see below |
| Finding 2: "regression of closed record 578's work" | **REFUTED** — `docs.yml` is unmodified since `a9773111a` (2026-09-20), which predates the last GREEN run of that workflow (2026-10-16). Nothing 578 established regressed |
| Report's R2 premise: 4 spaces before `;` in `NormalForm.lean:383,390,413,420` | **CONFIRMED unchanged** (exactly 4 ` ;` occurrences in that file, at those four lines) |
| Report's R1 premise: 10 edit sites across 3 files | **CONFIRMED and extended** — the site sweep also returns `docs/development/MODULE_INVARIANTS.md:298`, which the report's edit table omits. Phase 4 owns it |

**Finding 2's refutation, measured.** `gh run view 44457344329 --log-failed` contains exactly two
error classes: 13 occurrences of `error: resource exhausted (error code: 12, cannot allocate
memory)` and one `error: build failed`. There is no URI, git-remote, or configuration error in
the log. The `srcUri.github` targets are simply the cheap, fork-a-`git`-subprocess jobs in flight
when the machine ran out of memory, which is why they are what the failure summary names. The
2026-11-13 run (`43387984780`) shows the same signature (11 OOM lines). Supporting evidence that
this is growth-driven rather than configuration-driven: `docs.yml` unchanged since 2026-09-20,
`lean-toolchain` unchanged since 2026-07-25, and `FormalSystem/` grew from 705 to 772 `.lean`
files (416,312 lines today) between the last green docs run and now. The project build inside
that job succeeds (`Build completed successfully (2991 jobs)`); the kill lands at doc job
5852/6273, roughly 93% through, where the remaining jobs are this repository's own modules.

### Research Integration

The report's R1 (rename over qualification), R2 (the masked `lint-style` failure), R5 (do not
reconcile the two declarations) and its §5-alias trap are adopted. Three additions this dispatch
measured, which the report could not have carried:

1. **R1 is import-neutral.** `FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Enumerate`
   is already in `BimodalTools.CertificateImport`'s import closure (walked transitively, 206
   modules), so defining the renamed declaration through the core one adds no import and has no
   import-graph or cycle-check consequence.
2. **Finding 1's fix makes a sibling's artifacts stale** — `scripts/c16-roots-unmeasurable.txt`
   excuses `BimodalToolsTest` *because of this very defect*. Phase 4 owns that coupling.
3. **Finding 2's root cause and remedy space**, above and in Phase 3.

The report's R3 (qualify the two test call sites) remains the de-risked fallback, measured green,
and is named in Rollback/Contingency rather than planned as the primary.

### Prior Plan Reference

No prior plan for this task. `specs/578_fix_api_documentation_ci_integration/plans/01_docgen-ci-fix-path.md`
was consulted as the dispatch directed: its `docs.yml` rewrite is intact and unmodified, so it
supplies the file's current design rationale (the `homepage: api-site` / `build-page: false`
reasoning, the SHA pin, the Pages fail-fast check) that Phase 3 must preserve — not a fix to
restore.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch and no roadmap flag was set, so no roadmap phases
are planned. `specs/ROADMAP.md` names this task first in the repository-hygiene batch on the
rationale that "while every check is red, no check result anywhere on this list reads as
evidence" — which is what Phases 1-4 restore. That ROADMAP line also carries the refuted
`srcUri.github` characterization; correcting it is roadmap-maintenance work owned by `/roadmap`,
not this task, and this plan does not touch `specs/ROADMAP.md`.

## Goals & Non-Goals

**Goals**:
- `lake build BimodalToolsTest.CertificateImportTest` exits 0, and the whole collision class
  between the two namespaces (`closureList` AND the latent `mem_closureList`) is closed.
- `lake exe lint-style` exits 0, so the aggregating `Report results` step can reach green.
- `API Documentation`'s doc build is given the memory headroom its measured failure requires, and
  the workflow's own header records the corrected diagnosis so the next reader is not re-sent
  down the `srcUri` path.
- The `scripts/c16-roots-*` surfaces that excuse this defect are reconciled in the same task that
  removes the defect, not left stale.
- A local commit plus local gate evidence, with the push named as the user's step.

**Non-Goals**:
- No `.lake/build` CI cache work (task 829's record).
- No `if: !cancelled()` hardening of `ci.yml` steps 7/14/15, and no other `ci.yml` edit. The
  scope boundary permits touching `.github/workflows/` "only as far as the doc-gen4 fix
  requires", which is `docs.yml` alone. The masking behaviour the report surfaced is recorded as
  a follow-up in Phase 5's notes, not fixed here.
- No `scripts/nolints-style.txt` waiver for the four `lint-style` findings (that file is
  deliberately empty; waiving would make these the first exception).
- No deprecated alias on the rename (measured: an alias retaining the old name still produces
  `Ambiguous term`, so it would reinstate the bug).
- No push, PR, or workflow re-run (`.claude/rules/pr-prohibition.md`).
- No edit to `specs/ROADMAP.md` or to task 938's `scripts/c16_roots_baseline.py` logic.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Style guide §5 mandates a rename alias, which measurably reinstates the ambiguity | H | H | Waive the alias deliberately; record the reason in the commit body and in Phase 1's docstring edit (BimodalTools is outside `defaultTargets`, five in-repo use sites, zero external consumers) |
| A docstring rewrap in Phase 1 or 2 changes a `.lean` line count, so `.githooks/pre-commit` blocks the commit on `typst/generated/status.typ` drift | M | M | Both phases run `bash scripts/typst-sync-check.sh --counts-only` BEFORE staging and carry `typst/generated/status.typ` in their own file scope with the `--fix` step pre-authorized in the same phase (baseline measured this dispatch: exit 0, `MISMATCH_COUNT=0`) |
| Phase 1 makes `BimodalToolsTest` measurable, so the local full-mode C16-roots gate reports `NEW … (no baseline entry)` rows and fails on correct work | H | H | Phase 4 is scheduled for exactly this, depends on Phase 1, and branches on the measured outcome. CI is NOT at risk here: CI invokes `check-module-invariants.sh --no-build`, and both C16 halves sit inside `if [ "$RUN_BUILD" -eq 1 ]` |
| Phase 3's fix cannot be verified locally at all | H | H | Stated as a limitation, not papered over: Phase 3's in-phase verification is YAML/shell validity plus the measured diagnosis; the authoritative verification is the user's pushed run, named in Phase 5 |
| The swap step's `fallocate` fails (pre-existing active swapfile, or insufficient `/mnt` space) | M | M | The step is written defensively (`swapoff -a || true`, `rm -f || true`) and self-diagnosing (`free -h` before and after, `df -h`), so a failure is loud and names its own cause in the next run's log rather than silently leaving the OOM in place |
| Concurrent writers: 938's work touched `scripts/`, and `specs/evidence/history-morphism-saturation-audit/` holds two untracked files | M | M | Re-read every target region immediately before editing; stage explicit file lists only (`git add -- a b c`, never a directory or glob); leave the untracked evidence files alone |
| Phase 4's full 19-root sweep overruns its budget | M | M | Run it detached with a bounded waiter (`context/patterns/bounded-build-waiter.md`); on overrun the phase closes [PARTIAL] with the `BimodalToolsTest`-only measurement recorded and the baseline edit justified from it — never a silent skip |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1 |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. Wave 1's three phases touch three disjoint
territories: `BimodalTools/` + `Tests/BimodalToolsTest/`, `FormalSystem/Metalogic/Expressiveness/SeparationZ/`,
and `.github/workflows/docs.yml`.

---

### Phase 1: Rename the BimodalTools `closureList` and retarget the test [COMPLETED]

**Goal**: Close the entire `closureList`/`mem_closureList` collision class between
`BimodalTools.CertificateImport` and `FormalSystem.Metalogic.Decidability`, so
`lake build BimodalToolsTest.CertificateImportTest` exits 0.

**Tasks**:
- [x] Re-read `BimodalTools/CertificateImport.lean:145-160` and `336-360` immediately before
      editing (concurrency guard).
- [x] Rename `def closureList` -> `def closureListDedup` at line 149, with the body
      `(FormalSystem.Metalogic.Decidability.closureList S).dedup`. No new import is needed:
      `…WitnessFamily.Compression.Enumerate` is already in this module's import closure
      (measured).
- [x] Rename `theorem mem_closureList` -> `mem_closureListDedup` (lines 152-155), proof
      `simp [closureListDedup, List.mem_dedup, mem_closureList]`.
- [x] Retarget the three internal call sites at lines 338, 348, 357.
- [x] Update the four module-docstring mentions (lines 56, 59, 100, 118), including the
      `## Why closureList rather than Finset.toList` heading at line 56.
- [x] Add one sentence to the docstring recording why no deprecated alias accompanies this rename
      (style guide §5 waived; an alias retaining the old name measurably reproduces
      `Ambiguous term`). State it in present tense, naming the mechanism — NOT as "this used to
      be called…", which `.claude/rules/no-record-versioning-in-deliverables.md` forbids outside
      `specs/**`. Do not cite a task number in this file
      (`.claude/rules/no-task-references-in-deliverables.md`).
- [x] Update the inventory row naming `closureList` in `BimodalTools/README.md:384`.
- [x] Retarget `Tests/BimodalToolsTest/CertificateImportTest.lean:146,152` to `closureListDedup`
      (no qualification then needed, since the name is now unique across both opens).
- [x] Run `bash scripts/typst-sync-check.sh --counts-only`; if it reports drift (a line count
      moved), run `bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` in THIS phase's commit, never deferred.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: the complete edit set is 10 sites across 3 files, as enumerated above.
Confirm by re-running `grep -rn 'closureList' --include=*.lean --include=*.md . | grep -v
'^./.lake\|^./specs'` AFTER the edit: the only surviving `closureList` occurrences must be in
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` (the core declaration and its
own README/docstrings), `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`,
`FormalSystem/.../Compression/Assembly.lean:71`, and
`docs/development/MODULE_INVARIANTS.md:298` (Phase 4's target). Any surviving occurrence under
`BimodalTools/` or `Tests/` is a straggler, not an accepted exception.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- build
BimodalToolsTest.CertificateImportTest` plus `lake build BimodalTools --wfail` builds the changed
module and its one enumerated dependent, which is the complete call-site set this rename moves.

**Files to modify**:
- `BimodalTools/CertificateImport.lean` - rename the `def` and `theorem`, retarget 3 call sites,
  update 4 docstring mentions, record the alias waiver
- `BimodalTools/README.md` - the inventory row at line 384 naming `closureList`
- `Tests/BimodalToolsTest/CertificateImportTest.lean` - the two `#guard` heads at 146, 152
- `typst/generated/status.typ` - conditional: regenerate via `typst-sync-check.sh --fix` in this
  same phase if the edits move any `.lean` line count (`tools-line-count` / `tests-line-count`
  are recorded fields, and `.githooks/pre-commit` BLOCKS the commit on drift)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- build BimodalToolsTest.CertificateImportTest`
  exits 0 with no `Ambiguous term` and no `sorryAx` line.
- `lake build BimodalTools --wfail` exits 0.
- The straggler sweep in Scope Hypothesis returns only the accepted occurrences listed there.
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 (the CI invocation form).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 at commit time.

---

### Phase 2: Remove the four spaces before semicolons in NormalForm.lean [COMPLETED]

**Goal**: Make `lake exe lint-style` exit 0, so the aggregating `Report results` step can reach
green once Phase 1 unblocks the steps ahead of it.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean:380-425`
      immediately before editing (this is a `FormalSystem` file and sibling tasks were dispatched
      into adjacent territory with no declared `file_scope`).
- [x] Delete the single space before `;` on lines 383, 390, 413 and 420 — `· intro hC' ; exact`
      becomes `· intro hC'; exact`, and likewise for the two `hF'` lines. Four characters total;
      change nothing else on those lines.
- [x] Confirm the file is otherwise clean beforehand (`git diff --quiet -- <path>` before the
      edit) and stage only this path explicitly.
- [x] Run `bash scripts/typst-sync-check.sh --counts-only`; on drift, run `--fix` and stage
      `typst/generated/status.typ` in THIS phase's commit.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: exactly 4 occurrences of ` ;` exist in this file, at lines 383, 390, 413 and
420, and they are the complete `lint-style` finding set for the repository (re-measured this
dispatch: `grep -n ' ;'` returns exactly those four lines). Confirm by the gate itself: `lake exe
lint-style` must go from exit 1 with 4 findings to exit 0 with none. If the gate reports any
finding outside this file, that is a new, separately-caused failure — record it and do not absorb
it into this phase.

**Tier Justification**: `lake exe lint-style` is the exact gate that reports these findings, and
the edit changes four characters inside tactic blocks of one module with no signature change, so
re-elaborating that single module covers it.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` - delete one space before
  `;` on each of lines 383, 390, 413, 420
- `typst/generated/status.typ` - conditional, same mechanism and same-phase rule as Phase 1
  (`formalsystem-line-count` is a recorded field and the pre-commit hook blocks on drift; a
  pure in-line character deletion should move no count, so this entry is expected to stay
  untouched — it is declared because the hook, not the author, is the arbiter)

**Verification**:
- `lake exe lint-style` exits 0 with no output.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- build FormalSystem.Metalogic.Expressiveness.SeparationZ.NormalForm`
  exits 0 (the edit is semantically inert — `intro h ; exact h` and `intro h; exact h` both
  elaborate — but `--wfail` makes any new warning a failure, so the module is rebuilt rather
  than assumed).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 at commit time.

---

### Phase 3: Give the doc-gen4 build memory headroom, and correct docs.yml's diagnosis [COMPLETED]

**Goal**: Address the measured cause of `API Documentation`'s redness — an out-of-memory kill
during the doc build — and record the corrected diagnosis in the workflow's own header so the
next reader is not sent down the `srcUri` path.

**Tasks**:
- [x] Re-read the LATEST `API Documentation` failure before editing: `gh run list
      --workflow=docs.yml --branch main --limit 3`, then `gh run view <id> --log-failed`.
      Confirm the error class is still `resource exhausted (error code: 12, cannot allocate
      memory)` and that no other error class is present. If the signature has changed, stop and
      re-diagnose rather than applying this phase as written.
- [x] Add a swap-enlargement step to `.github/workflows/docs.yml`, immediately before the
      `Build and deploy doc-gen4 documentation` step. Write it defensively and self-diagnosing,
      so neither a pre-existing active swapfile nor a space shortfall fails silently:

      ```yaml
      - name: Enlarge swap for the doc build
        run: |
          set -euo pipefail
          free -h
          df -h /mnt /
          sudo swapoff -a || true
          sudo rm -f /mnt/swapfile || true
          sudo fallocate -l 16G /mnt/swapfile
          sudo chmod 600 /mnt/swapfile
          sudo mkswap /mnt/swapfile
          sudo swapon /mnt/swapfile
          free -h
      ```

- [x] Extend the header's `PREREQUISITES` list with one bullet recording the memory requirement
      and what the failure looks like: the doc build runs `lake build` over ~6,273 doc targets
      with doc-gen4 processes that each import the full Mathlib-plus-`FormalSystem` environment,
      and the runner's RAM alone is insufficient — the kill surfaces as `error: resource
      exhausted (error code: 12, cannot allocate memory)` attributed to whichever `srcUri.github`
      targets were in flight, which names the symptom rather than the cause. State this in
      present tense as a standing prerequisite, in the style of the bullets already there. Do NOT
      write it as draft history ("this used to work", "previously green") —
      `.claude/rules/no-record-versioning-in-deliverables.md` applies to this file. Do NOT cite a
      task number in it (`.claude/rules/no-task-references-in-deliverables.md`).
- [x] Change nothing else in the file: the SHA pin, `homepage: api-site`, `build-page: false`,
      the Pages fail-fast check, the `references.bib` input, the concurrency group, and the
      `lean-action` ordering are all load-bearing and documented as such.
- [x] Do NOT add a parallelism knob. Measured this dispatch: Lake 5.0.0's `lake --help` and
      `lake help build` expose no `--jobs`/`-j` option (`-j` returns `unknown short option`),
      and the doc build's `lake build` invocation lives inside the pinned action's own
      `scripts/build_docs.sh`, which the workflow cannot pass arguments to (the action's
      `build-args` input reaches `lean-action`'s project build only). An unverified env-var knob
      must not be added on speculation.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the OOM is the sole cause of this workflow's redness — the failure log
carries exactly two error classes, 13 `resource exhausted` lines and one `build failed`, with no
configuration, URI, or git error. Confirm by the re-read in this phase's first task, against the
latest run rather than against the run measured here (a newer run may exist by implementation
time). This phase deliberately EXCLUDES any `ci.yml` edit and any `.lake/build` cache work; no
task in it requires either.

**Tier Justification**: `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/docs.yml'))"`
plus `bash -n` over the added `run:` body is the complete locally-available check for a
single-workflow-file edit (no `actionlint` is installed and the repository has no workflow lint
script), and no Lean or script surface is touched.

**Files to modify**:
- `.github/workflows/docs.yml` - add the swap step before the docgen step; add one
  `PREREQUISITES` bullet recording the memory requirement and the misleading failure attribution

**Verification**:
- `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/docs.yml'))"` exits 0.
- The added `run:` block body, extracted to a file, passes `bash -n`.
- `git diff -- .github/workflows/docs.yml` shows additions only: one step and one comment bullet,
  with no change to the SHA pin or any `with:` input.
- **Stated limitation, not a gap to be closed locally**: this phase's fix is unverifiable on this
  machine. The doc build needs the GitHub runner's doc-gen4 toolchain and ~90 minutes, and the
  failure being fixed is a property of the runner's memory. The authoritative verification is the
  user's pushed run (Phase 5).

---

### Phase 4: Reconcile the C16-roots surfaces that excuse this defect [COMPLETED]

**Goal**: `BimodalToolsTest` becomes measurable the moment Phase 1 lands, so remove its excuse
row, give it its place in the ceiling, and correct the two prose records that assert it is
unmeasurable.

**Tasks**:
- [x] Confirm all three correction targets still exist and still name this defect before editing
      (all three were confirmed present at authoring time): `scripts/c16-roots-unmeasurable.txt`
      (one `BimodalToolsTest` row), `scripts/c16-roots-baseline.txt` (47 entry rows, no
      `BimodalToolsTest` rows), and `docs/development/MODULE_INVARIANTS.md` around line 297-304
      ("**One root is currently unmeasurable, not zero.**"). If any target is absent or no longer
      names this defect, record that in the phase notes and skip only that target's edit — do not
      invent a replacement carrier.
- [x] Measure the newly-buildable root: `lake exe runLinter BimodalToolsTest`, capturing the log.
- [x] Branch on the measurement:
      - **Clean (no findings)**: delete the `BimodalToolsTest` row from
        `scripts/c16-roots-unmeasurable.txt`. No baseline rows are needed.
      - **Findings present**: delete that same row AND add one `<count> BimodalToolsTest <module>
        <linter>` row per measured finding to `scripts/c16-roots-baseline.txt`, in the format its
        header documents, keeping its existing rows untouched. Do NOT run `--update`: that
        rewrites the file wholesale from the handed-in logs and would re-bless every other root's
        count from a partial log set. If a finding's linter class has no `# disposition` row, read
        the class and add one deliberately rather than defaulting it.
- [x] Update `docs/development/MODULE_INVARIANTS.md`'s unmeasurable-root paragraph to state the
      current situation. Present tense, no draft-history framing, no task-number citation (both
      rules apply to `docs/**`). *(deviation: altered — the phase Goal names "the two prose
      records that assert it is unmeasurable" while this bullet enumerated only one, so
      `scripts/check-module-invariants.sh`'s own C16 header block, which carried the identical
      "ONE ROOT IS CURRENTLY UNMEASURABLE, NOT ZERO" assertion, was corrected in the same way and
      in the same commit; leaving it would have left a now-false record of the same kind)*
- [x] Re-run the C16-roots comparator to confirm the gate is green, detached with a bounded
      waiter (`context/patterns/bounded-build-waiter.md`: hard timeout, `kill -0` on the captured
      PID, one waiter per log).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this reconciliation is confined to one excuse row, zero-or-more baseline
rows, and one documentation paragraph. The branch is decided by one measurement
(`lake exe runLinter BimodalToolsTest`) and not predicted here. Two mechanical facts bound the
blast radius and were measured this dispatch rather than assumed: the comparator reports a
newly-measurable root's findings as `NEW … (no baseline entry)` failures when no baseline row
exists for them, and it reports a listed-but-clean root as an INFO "consider removing its row";
and CI is NOT affected either way, because CI invokes `check-module-invariants.sh --no-build`
while both C16 halves sit inside `if [ "$RUN_BUILD" -eq 1 ]`. The gate of record here is
therefore the LOCAL full-mode invocation.

**Tier Justification**: `python3 scripts/c16_roots_baseline.py --log-dir <dir>` over per-root
`lake exe runLinter` logs is the exact comparator that reads both edited files, and no other
surface consumes them.

**Files to modify**:
- `scripts/c16-roots-unmeasurable.txt` - remove the `BimodalToolsTest` row
- `scripts/c16-roots-baseline.txt` - conditional on the measurement: add `BimodalToolsTest` rows,
  leaving all 47 existing rows untouched
- `docs/development/MODULE_INVARIANTS.md` - correct the unmeasurable-root paragraph (~line 297)

**Verification**:
- `python3 scripts/c16_roots_baseline.py --log-dir <dir>` exits 0 over a log directory holding one
  `lake exe runLinter <root>` log per lakefile root, with no `BimodalToolsTest` INFO excuse line
  and no `NEW`/`ABOVE` row.
- `grep -c BimodalToolsTest scripts/c16-roots-unmeasurable.txt` returns 0 matches outside the
  header comment.
- Baseline-delta discipline, not absolute zero: existing rows for other roots must be unchanged
  (`git diff -- scripts/c16-roots-baseline.txt` shows additions only). A pre-existing failure for
  a root this task did not touch is a recorded PASS with the finding enumerated, not a blocker,
  and is never grounds to edit another root's ceiling.
- **Overrun fallback**: if producing a log per root exceeds this phase's budget, close the phase
  [PARTIAL] with the `BimodalToolsTest` measurement and the edits made from it recorded
  explicitly, and name the unfinished comparator run. Do not close it green on an unrun gate.

---

### Phase 5: Full gate set, commit, and hand off the push [NOT STARTED]

**Goal**: Run the complete gate set over the assembled work, commit, and state precisely what
remains for the user and why this task cannot do it.

**Tasks**:
- [ ] Run the complete local gate set — the local equivalents of every `ci.yml` check, since
      `CI / Build and Test` reaching green is this task's acceptance bar:
      `lake build --wfail` over the CI roots; `lake test`; `lake lint`;
      `lake build BimodalTools --wfail`; `lake build BimodalToolsTest --wfail`;
      `bash scripts/check-evidence-probes.sh`; `bash scripts/check-module-invariants.sh --no-build`;
      `bash scripts/readme-lint.sh FormalSystem BimodalTools`;
      `bash scripts/check-metalogic-cycles.sh`; `bash scripts/typst-sync-check.sh`;
      `lake exe mk_all --lib FormalSystem --check`; `lake exe lint-style`.
      Use `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- …` for the build-shaped
      ones. `.claude/scripts/verify-deploy.sh` has no bearing on this task: no `.claude/**` or
      source-store path is touched.
- [ ] For `check-evidence-probes.sh`, expect the known transient the report documented (a run of
      spurious `FAIL (untracked: …)` verdicts from the script's own `git ls-files` subprocess).
      If it appears, re-test the named files with `git ls-files --error-unmatch` and record the
      result; do not treat a spurious verdict as a finding, and do not "fix" it here.
- [ ] Verify each gate's findings against this task's own file scope. A gate whose only failures
      are pre-existing and outside that scope is a recorded PASS with the findings enumerated.
- [ ] Commit with `.claude/scripts/git-commit-scoped.sh`, explicit file lists only. Record in the
      commit body: the style-guide §5 alias waiver and its reason, and the corrected Finding 2
      diagnosis (OOM, not `srcUri` configuration).
- [ ] Write the summary artifact, and record in it the two follow-ups this task deliberately does
      not take: `ci.yml`'s hard-stop steps masking the `continue-on-error` checks below them
      (steps 7, 14, 15), and a one-line scope note for style guide §5 so the next rename does not
      re-collide.
- [ ] State the remaining user step explicitly: push `main`, then confirm both workflows report
      success on the real run. `.claude/rules/pr-prohibition.md` bars this agent from pushing or
      re-running a workflow, so the task's third verification criterion is the user's to close —
      and for `API Documentation` specifically, that run is the ONLY verification of Phase 3 that
      exists.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- `specs/937_fix_red_ci_workflows_on_main/summaries/01_fix-red-ci-workflows-summary.md` - the
  completion summary

**Verification**:
- Every gate in the list above either exits 0, or is recorded as a PASS with its pre-existing,
  out-of-scope findings enumerated and with each file this task touched shown to pass
  individually.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1500 -- build BimodalToolsTest.CertificateImportTest`
  exits 0 (the task record's first criterion).
- A `--wfail` build over the roots `ci.yml` builds exits 0 (the task record's second criterion).
- `git log -1 --stat` shows only this task's intended files, and `git status --short` shows no
  unintended residue.
- The task record's third criterion (both workflows green on a real run) is recorded as
  USER-PENDING with the reason, never as met.

## Testing & Validation

- [ ] `lake build BimodalToolsTest.CertificateImportTest` exits 0 with no `Ambiguous term`.
- [ ] `#check @mem_closureListDedup` and `#check @mem_closureList` both resolve unambiguously
      under the test file's two `open`s (the latent half of the collision class is closed, not
      just the two sites that error today).
- [ ] `lake exe lint-style` exits 0.
- [ ] A `--wfail` build over the CI roots exits 0.
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` exits 0 at every commit.
- [ ] `python3 scripts/c16_roots_baseline.py --log-dir <dir>` exits 0 with no `BimodalToolsTest`
      excuse INFO line.
- [ ] `.github/workflows/docs.yml` parses as YAML and its added `run:` body passes `bash -n`.
- [ ] USER-PENDING: both workflows report success on a pushed run.

## Artifacts & Outputs

- `BimodalTools/CertificateImport.lean`, `BimodalTools/README.md`,
  `Tests/BimodalToolsTest/CertificateImportTest.lean` - the rename and its call sites
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/NormalForm.lean` - the four-character
  `lint-style` fix
- `.github/workflows/docs.yml` - the swap step and the corrected diagnosis bullet
- `scripts/c16-roots-unmeasurable.txt`, `scripts/c16-roots-baseline.txt` (conditional),
  `docs/development/MODULE_INVARIANTS.md` - the C16-roots reconciliation
- `typst/generated/status.typ` - conditional, only if a `.lean` line count moves
- `specs/937_fix_red_ci_workflows_on_main/summaries/01_fix-red-ci-workflows-summary.md`

## Rollback/Contingency

- **Phase 1 fails to build green**: fall back to the report's R3, measured green under the exact
  `BimodalToolsTest` Lean options — qualify the two test call sites as
  `BimodalTools.CertificateImport.closureList gammaPos` / `… gammaSep` and revert the rename.
  This fixes the hard stop and leaves `mem_closureList` armed; record that residual explicitly
  and leave Phase 4's reconciliation in place, since the root becomes measurable either way.
- **Phase 3's swap step does not fix the OOM** (visible only after the user's push): the
  documented next remedy, in order, is (a) vendor the doc build — replace the pinned action with
  explicit steps replicating its `scripts/build_docs.sh`, which puts the `lake build` invocation
  under this repository's control so it can be serialized or split; then (b) a larger runner,
  which is a billing and authorization decision only the user can make, not an agent's to take.
- **Phase 4 leaves a red local gate**: revert only the two `scripts/c16-roots-*` edits; the
  Lean fixes in Phases 1-2 stand independently, and the excuse row's reason text then becomes
  inaccurate rather than the gate becoming wrong — record that as the residual.
- **General**: fix forward. Never discard uncommitted changes to reach a passing build
  (`.claude/context/contracts/recovery.md`). If a genuine rollback is needed, snapshot first with
  `bash .claude/scripts/git-snapshot.sh 937`; for an ordinary defensive checkpoint before risky
  work, use `--no-revert`.
