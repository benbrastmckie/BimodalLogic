# Implementation Plan: Task #943

- **Task**: 943 - Close three small gitignore and loose-file hygiene gaps at the repository root
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/943_gitignore_and_loose_file_hygiene/reports/01_gitignore-loose-file-hygiene.md
- **Artifacts**: plans/01_gitignore-loose-file-hygiene.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/context/standards/status-markers.md
  - .claude/context/standards/artifact-management.md
  - .claude/context/standards/tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Three independent, small hygiene gaps at the repository root, closed in two phases across exactly
two files: `.gitignore` (gaps A and B) and `ORGANISATION.md` (gap C). No Lean source, no build
configuration, and no script is touched. Definition of done: `latex/build/` and `/.pid` are
explicitly ignored, `Challenge.lean` is documented in `ORGANISATION.md`'s "Everything else"
table, and both named gate scripts are no worse than a baseline captured before the first edit.

### Research Integration

The research report (`reports/01_gitignore-loose-file-hygiene.md`) changes two things about how
this task is executed, and both are carried into the phases below:

1. **Gap (A)'s stated impact does not hold, but its fix stands.** Every file under `latex/build/`
   and `latex/subfiles/build/` is *already* ignored, by `.gitignore` line 3's bare, unanchored
   `build/` rule — not by any `latex/`-scoped rule. Adding an explicit `latex/build/` line is
   therefore a clarity/robustness change (it makes the intent local and survives line 3 ever
   being anchored or narrowed), not the removal of active unignored cruft. The implementation
   must carry this correction into its summary so it is not re-litigated.
2. **Gap (C) has one correct answer, not two options.** `Challenge.lean` is the committed,
   git-pinned output of the agent-system lean extension's `lean-challenge-snapshot.sh` Comparator
   statement-pinning step — a tracked, clean, deliberately-produced trust-boundary artifact whose
   mechanism writes to the project root *by design*. The `sorry` bodies are intentional: the
   module pins statement signatures, not proofs. Relocating it to `Boneyard/` would be a
   substantive error (it is not an abandoned approach, and the move would remove the location the
   next snapshot/Comparator cycle writes to and reads from). The ORGANISATION.md documentation
   option is therefore mandatory, and relocation is out of scope.

### Premise Re-Validation

Per the dispatch's Carried-Figure Discipline trigger, both extracted lines were re-checked
against live state at planning time. Both hold:

| Carried claim | Live check | Result |
|---|---|---|
| `.pid` needs an anchored `/.pid` rule | `git status --porcelain .pid` -> `?? .pid`; `git check-ignore -v .pid` -> no match | **Confirmed** — untracked and matched by no existing rule |
| `Challenge.lean` is root-level, `sorry`-bearing, absent from `lakefile.toml`, absent from ORGANISATION.md's "Everything else" table | `git ls-files Challenge.lean` -> tracked; `grep -c sorry` -> 5; `grep -n Challenge lakefile.toml` -> no match; `ORGANISATION.md:189-199` table has no such row | **Confirmed on every clause** — with the research report's correction that "loose scratch file" mischaracterizes *why* it is there |

Gap (A)'s own premise was also re-checked and remains **refuted**, exactly as the research report
found: `git check-ignore -v latex/build/BimodalReference.aux` reports `.gitignore:3:build/`, and
`git ls-files latex` returns zero tracked files.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:
- `.gitignore` carries an explicit `latex/build/` rule, local to the LaTeX/Typst block.
- `.gitignore` carries an anchored `/.pid` rule.
- `ORGANISATION.md`'s "Everything else" table carries one row for `Challenge.lean` explaining
  what produces it, why its `sorry` bodies are expected, and that it must not be deleted or moved.
- `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh` are no worse than a
  pre-change baseline captured with identical flags.
- No currently-tracked file becomes newly ignored.

**Non-Goals**:
- Relocating, editing, or deleting `Challenge.lean` itself (research-established as incorrect).
- `Boneyard/` (verified deliberate, ADR-backed, gate-enforced — explicitly out of scope).
- The already-ignored `other/`, `research/`, `training/`, `data/` trees.
- Any change to `lakefile.toml`.
- Any change to `ORGANISATION.md`'s **layer** table (a different table, and the one actually
  pinned to `scripts/measure-refactor-partitions.py`'s `LANGUAGE_FILE_LAYERS`).
- Enumerating `latex/` build extensions individually; the single directory rule is the fix.
- Narrowing, anchoring, or otherwise touching `.gitignore` line 3's generic `build/` rule.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The ORGANISATION.md row cites a path absent from a fresh clone. `agent-system/` does not exist in this repository at all, and `.claude/` is gitignored (`.gitignore:106 /.claude`) — so the research report's suggested pointer to `agent-system/extensions/lean/.../challenge-snapshot.md` would be a dead reference in a tracked deliverable, and ORGANISATION.md today cites neither prefix anywhere. | M | H if copied verbatim | Phase 2 names the mechanism by script basename (`lean-challenge-snapshot.sh`) and attributes it to the agent-system lean extension in prose, with no repository-relative path to a gitignored or absent tree. |
| A task-numbered path (e.g. an archived `specs/archive/849_.../challenge/manifest.json`) is cited in the row. `ORGANISATION.md` is outside `specs/**`, so `.claude/rules/no-task-references-in-deliverables.md` forbids this, and `hooks/validate-no-task-references.sh` is a blocking write-time gate. | M | M | Phase 2 forbids any task-numbered path or "task N" phrasing in the row; the mechanism is described by durable anchors only. |
| Record-versioning phrasing ("previously", "no longer", "used to") enters the row. Forbidden outside `specs/**` by `.claude/rules/no-record-versioning-in-deliverables.md`. | L | L | Phase 2's row states the current design only, in the present tense, matching the table's existing row voice. |
| An over-broad `.gitignore` rule silently ignores a tracked file. | H | L | Phase 1 verifies `git ls-files` against both new rules' reach, before and after; `latex/` has zero tracked files and `.pid` is untracked. |
| A sibling task's concurrent edit is swept into this task's commit. Task 941 is dispatched this same cycle with scope `scripts/verify-all.sh`, `CONTRIBUTING.md`, `scripts/README.md`. | M | L | No scope overlap with this task's two files. Still: re-read each file immediately before editing, stage by explicit file list only, never a directory or glob pathspec, and never run `git-snapshot.sh` in its reverting default mode. |
| Gate baselines are compared across different invocation flags, producing a false regression. | M | M | Phase 1 captures both baselines before any edit and records the exact command line used; Phase 2 re-runs byte-identical commands. |

## Decisions

- **(A)**: implement the dispatch's literal fix (`latex/build/` in `.gitignore`) while recording
  that the cruft the finding described is already ignored via the generic `build/` rule. Explicit
  local intent beats an accidental match from a rule whose own comment scopes it to Lean output.
- **(B)**: implement exactly as specified — anchored `/.pid`, so it cannot reach the unrelated
  `specs/.orchestration/*.pid` and `specs/archive/**/untracked-backup-*/*.pid` files.
- **(C)**: document in `ORGANISATION.md`; do **not** relocate to `Boneyard/`. This is a hard
  requirement from the research findings, not a stylistic preference.
- **No coupled generated surface exists for either edit** (checked at planning time, so no
  regeneration step is owed in either phase): `ORGANISATION.md`'s *layer* table is the table
  pinned to `scripts/measure-refactor-partitions.py`'s `LANGUAGE_FILE_LAYERS` and to
  `scripts/check-metalogic-cycles.sh`'s assertions — the "Everything else" table feeds nothing,
  and `scripts/check-module-invariants.sh` never reads `ORGANISATION.md`. On the `.gitignore`
  side, `.claude/scripts/check-runtime-file-tracking.sh` derives its probes from
  `scripts/lib/runtime-file-patterns.sh`, which contains no `pid` member, so neither new rule
  changes that script's verdict.
- **Neither edited file is in `scripts/readme-lint.sh`'s or `check-module-invariants.sh` C12/C13's
  scope** (`readme-lint.sh` defaults to the `FormalSystem/` root; C12/C13 scope is `docs/**/*.md`
  plus `README.md`). The ORGANISATION.md row is therefore a pure documentation change with no
  link-resolution gate interaction — which is *why* the dead-path risk above must be handled by
  authoring discipline rather than left to a gate to catch.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel. Phase 2 is sequenced after Phase 1 so that
the pre-change gate baselines captured in Phase 1 precede every edit in the task, and so the
final phase observes all of the task's work.

---

### Phase 1: Baseline capture and `.gitignore` rules (gaps A and B) [COMPLETED]

**Goal**: Capture pre-change gate baselines, then add the two `.gitignore` rules and prove that
exactly the intended paths moved from untracked to ignored with no tracked file affected.

**Tasks**:
- [x] Capture pre-change baselines into the session scratchpad, recording each run's exit status and the exact command line
      used for each so Phase 2 can re-run them byte-identically:
      `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh`. If the full
      invariants run is too slow to repeat, use its `--no-build` mode — but then use `--no-build`
      in Phase 2 as well, and note the choice in the summary. *(completed: both exit 0; invariants "ALL CHECKS PASSED"; readme-lint "RESULT: PASS", 62 pre-existing stale-date info findings, 0 broken refs; full (non `--no-build`) invocations used)*
- [x] Capture `git status --porcelain --ignored -- latex .pid` and `git ls-files latex` as a
      pre-change reference. *(completed: `latex/` already `!!` via line 3's generic `build/` rule; `git ls-files latex` empty; `.pid` untracked and unignored)*
- [x] Re-read `.gitignore` immediately before editing (sibling task 941 is live on this tree).
- [x] Add `latex/build/` to `.gitignore` directly beneath the existing `latex/**/*.log` /
      `typst/**/*.log` pair (currently lines 44-45), inside that block's own comment scope. Do
      not touch line 3's generic `build/` rule.
- [x] Add an anchored `/.pid` rule in the runtime/temporary region — beside `*.tmp` (line 25) or
      alongside the other anchored root-only entries near `/.claude` (line 106). Pick one; do not
      add it twice. *(completed: placed beside `/.agent-logs` in the anchored root-only block)*
- [x] Verify the new rules bite: `git check-ignore -v .pid` must now report the new `/.pid` line,
      and `git check-ignore -v latex/build/BimodalReference.aux` must report a rule (either the
      new `latex/build/` line or line 3's `build/` — both are correct outcomes; the point is that
      it stays ignored).
- [x] Verify no tracked file was newly ignored: `git ls-files latex` must still return zero, and
      `git ls-files .pid` must return nothing. Confirm `git status --porcelain` no longer lists
      `.pid` as `??`.
- [x] Commit this phase's single file with an explicit file-list pathspec
      (`git add -- .gitignore`), never a directory or glob. *(deviation: altered — verify-touched.sh .gitignore surfaced a pre-existing, unrelated NEW failure in test-verify-deploy-gate-selection.sh case(t), root-caused to this repo's missing agent-system/extensions/ directory, not to the .gitignore content; recorded via issue-record.sh rather than treated as a regression)*

**Timing**: 0.4 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase touches exactly one file (`.gitignore`) and adds exactly two
lines, with no deletion or reflow of existing lines. The implementer confirms this with
`git diff --stat -- .gitignore` (expect `1 file changed, 2 insertions(+)`) and
`git diff -- .gitignore` showing two `+` lines and no `-` lines; if the diff shows otherwise, the
hypothesis is wrong and the extra change must be accounted for before committing.

**Tier Justification**: `bash .claude/scripts/verify-touched.sh .gitignore` is the covering check
— `suite_selection_select`, run once at planning time over this phase's whole `Files to modify`
set, resolves this path to real covering suite basenames, so the narrowed `run-all.sh` pass that
command drives covers this single-file config edit without a full-battery sweep.

**Files to modify**:
- `.gitignore` - add `latex/build/` in the LaTeX/Typst block; add anchored `/.pid` in the
  runtime/temporary region

**Verification**:
- `bash .claude/scripts/verify-touched.sh .gitignore` green.
- `git check-ignore -v .pid` reports the new anchored rule.
- `git ls-files latex` returns zero lines; `git ls-files .pid` returns nothing.
- `git status --porcelain` no longer shows `?? .pid`.
- `git diff --stat -- .gitignore` shows 2 insertions, 0 deletions.

---

### Phase 2: Document `Challenge.lean` in ORGANISATION.md (gap C), and close out [NOT STARTED]

**Goal**: Add one "Everything else" row for `Challenge.lean` that tells a future reader what
produces the file, why its `sorry` bodies are expected, and that it must not be deleted or
relocated — then confirm both named gate scripts are no worse than Phase 1's baseline.

**Tasks**:
- [ ] Re-read `ORGANISATION.md` immediately before editing (sibling task 941 is live on this
      tree). The target table is the one under `## Everything else` (currently lines 189-199) —
      **not** the layer table under `## The library`.
- [ ] Add one row for `Challenge.lean`, placed consistently with the table's existing ordering.
      Its "Holds" cell must state, in the present tense and in the table's existing voice: that
      the file is the committed, git-pinned statement set produced by the agent-system lean
      extension's `lean-challenge-snapshot.sh` Comparator snapshot step; that each snapshot is
      pinned by its own commit, so the working-tree copy is simply the most recent one; that it is
      not a Lake root and is not built; that its `sorry` bodies are intentional because the module
      pins statement signatures rather than proofs; and that it should be left in place rather
      than deleted or moved.
- [ ] Authoring constraints on that row, each a repository rule rather than a preference:
      **no** repository-relative path under `agent-system/` (absent from this repository) or
      `.claude/` (gitignored at `.gitignore:106`) — name the script by basename in backticks
      instead; **no** task-numbered path or "task N" phrasing
      (`.claude/rules/no-task-references-in-deliverables.md`, enforced at write time by
      `hooks/validate-no-task-references.sh`); **no** record-versioning phrasing — "previously",
      "no longer", "used to", "formerly"
      (`.claude/rules/no-record-versioning-in-deliverables.md`).
- [ ] Confirm `Challenge.lean` itself is untouched: `git diff HEAD -- Challenge.lean` must be
      empty, and `git status --porcelain Challenge.lean` must show nothing.
- [ ] Re-run both named gate scripts with command lines byte-identical to Phase 1's baselines:
      `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh`. Check each
      invocation's **exit status** (`echo $?` immediately after, or `&& echo OK || echo FAIL`) in
      addition to diffing its output against the baseline — a baseline diff alone cannot
      distinguish a clean run from a crashed one. No new finding, and no exit-status regression
      relative to baseline.
- [ ] Run the scoped touched-path check over this task's own touched set:
      `bash .claude/scripts/verify-touched.sh .gitignore ORGANISATION.md`.
- [ ] Confirm the final ignore state: `git status --porcelain --ignored` shows `.pid` and the
      `latex/` byproducts as `!!`, and no tracked file is newly ignored.
- [ ] Commit this phase's single file with an explicit file-list pathspec
      (`git add -- ORGANISATION.md`).
- [ ] In the implementation summary, carry forward the research correction for gap (A): the
      `latex/` build byproducts were already ignored via `.gitignore` line 3's generic `build/`
      rule, so the new `latex/build/` line is a clarity and robustness improvement rather than the
      removal of active unignored cruft.

**Timing**: 0.6 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase touches exactly one file (`ORGANISATION.md`) and adds exactly one
table row, with no other row edited and no change to the layer table. The implementer confirms
with `git diff -- ORGANISATION.md` showing a single `+` line within the `## Everything else`
table and no `-` lines; a diff touching the layer table or any existing row means the hypothesis
is wrong and the change must be reverted to the intended single row before committing.

**Files to modify**:
- `ORGANISATION.md` - one new row in the `## Everything else` table for `Challenge.lean`

**Verification**:
- `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh` — each invocation's
  exit status recorded and no worse than Phase 1's baseline exit status, AND its output carrying
  no new finding relative to that baseline, compared under identical invocation flags. Both
  conditions are required; neither substitutes for the other.
- `bash .claude/scripts/verify-touched.sh .gitignore ORGANISATION.md` green — this scoped
  touched-path check, over this task's own two files, is this phase's own in-dispatch obligation
  under `/orchestrate`. The complete gate set
  (`bash .claude/scripts/verify-deploy.sh`) is **explicitly deferred to the orchestration close**,
  where it is owed once per invocation and not forgiven; this phase does not invoke the full
  battery independently. Record that deferral in the phase's own verification notes.
- `git diff HEAD -- Challenge.lean` empty (the file is documented, not modified).
- `git status --porcelain --ignored` shows `.pid` and the `latex/` byproducts as `!!`.
- `git ls-files` confirms no tracked file became newly ignored.

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` — no new finding vs. the pre-change baseline.
- [ ] `bash scripts/readme-lint.sh` — no new finding vs. the pre-change baseline.
- [ ] `bash .claude/scripts/verify-touched.sh .gitignore ORGANISATION.md` — green.
- [ ] `git check-ignore -v .pid` — reports the new anchored `/.pid` rule.
- [ ] `git status --porcelain --ignored` — `.pid` and `latex/` byproducts listed as `!!`.
- [ ] `git ls-files latex` returns zero lines; `git ls-files .pid` returns nothing — no tracked
      file newly ignored.
- [ ] `git diff HEAD -- Challenge.lean` empty.
- [ ] `git diff --stat` for the task shows exactly two files changed: `.gitignore` and
      `ORGANISATION.md`.

## Artifacts & Outputs

- `.gitignore` — two added rules (`latex/build/`, `/.pid`).
- `ORGANISATION.md` — one added row in the `## Everything else` table.
- `specs/943_gitignore_and_loose_file_hygiene/summaries/01_gitignore-loose-file-hygiene-summary.md`
  — implementation summary, carrying the gap (A) impact correction forward.
- Two task-scoped commits, one per phase, per `.claude/rules/git-workflow.md`.

## Rollback/Contingency

Both edits are additive, text-only, and confined to two tracked files, so rollback is per-phase
and does not require a working-tree-discarding operation:

- **Before either commit**: remove the added line(s) by hand (open the file and delete them) and
  confirm with `git diff -- <file>` that the diff is empty. On a shared, concurrently-dispatched
  tree, a hand revert is the practical mechanism — `git checkout -- <path>` is refused by
  `guard-destructive-git.sh` whenever the tree is dirty at all, including from a sibling task's
  legitimate uncommitted work.
- **After a commit**: revert that one commit (`git revert <sha>`), which touches only the single
  file that commit staged.
- **If a genuine working-tree rollback is ever needed**, follow
  `.claude/context/contracts/recovery.md`'s rollback rung for the exact snapshot-then-rollback
  invocation shape, including its out-of-scope override flag. Do not emit a reverting
  `git-snapshot.sh` call as a routine precaution, and never while sibling task 941 has
  uncommitted work on this tree.
- **Worst case**: reverting both commits restores the exact pre-task state. Nothing in this task
  deletes, moves, or regenerates any file.
