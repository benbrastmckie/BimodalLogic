# Implementation Plan: Task #595

- **Task**: 595 - Establish durable records home
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: None (downstream: the paper-vocabulary reconciliation and the `docs/` staleness audit both wait on this)
- **Research Inputs**: specs/595_establish_durable_records_home/reports/01_durable-records-home.md
- **Artifacts**: plans/01_durable-records-home.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Move the two durable record families out of the task-management tree: `specs/paper-definitions-of-record.md`
goes to `docs/reference/`, and `specs/decisions/{total-history-validity-decisions,untl-snce-argument-order}.md`
go to `docs/architecture/`, listed in its existing "Specification Documents" table. `docs/decisions/`
is ruled out because `docs/architecture/README.md` already forbids it. Then repoint every live
referrer (Lean docstrings, two scripts, docs, typst comments, `references.bib`, in-library READMEs)
and record the placement rule in the READMEs. The research report missed one thing, and this plan
adds it: **moving into `docs/` puts these files under gates that ignore `specs/`**. The planner
simulated the move in a throwaway worktree (git mv, then a blind path substitution, then
`check-module-invariants.sh --no-build`), and it turned four checks red. The plan clears that
new exposure as its own phase. It does not treat the move as a plain rename.

### Research Integration

Used from the report: the genre split (reference manifest vs. decision record), the ban on
`docs/decisions/`, the two hardcoded script paths (`check-paper-definitions.sh` `RECORD_DEFAULT`,
`check-module-invariants.sh` `C15_RECORD`), the cross-references between the moved files, and
leaving `specs/**` historical mentions alone.

The report under-covered some referrers. Found by re-measuring at plan time (2026-09-16):
`typst/chapters/02-semantics.typ` (7 comments), `typst/chapters/p2-frame-classes.typ`,
`typst/FormalFoundations.typ`, `typst/sync-check-whitelist.txt` (3 comment lines),
`references.bib`, and more comment lines in `scripts/check-module-invariants.sh` (lines 85, 1622)
and `scripts/check-paper-definitions.sh` (lines 3, 9, 145). `docs/theorem-index.md` holds two
**relative markdown links** (`../specs/paper-definitions-of-record.md`). These are C13 links, not
prose, and they need a relative rewrite (`reference/paper-definitions-of-record.md`), not the
repo-root form.

### Measured Gate Exposure (planning-time simulation)

Baseline on `main` (`--no-build`): C13 already FAILs with 9 pre-existing `../../data/` links. These
are unrelated to this task and out of scope. Everything else relevant passes. After the simulated
move and path substitution:

| Check | Result after move | Cause |
|-------|-------------------|-------|
| C12 | FAIL, 5 | Stale slash paths inside the moved records: `FormalSystem/BaseLanguage/Axioms.lean` (x2, paper-defs lines ~104, ~216), `FormalSystem/Semantics/WorldHistory.lean` (paper-defs ~291), `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean` (total-history ~150), `FormalSystem/Metalogic/WeakCanonical/Kamp/Boneyard` (untl-snce ~256) |
| C15 | FAIL, 17 | The record's own prose names paper anchors that have no MANIFEST or KNOWN-ANCHORS row (e.g. `cor:spherical-finite` x14, `app:gluing`, `def:BLplus-` as a prefix fragment). All 17 appear only in `paper-definitions-of-record.md`. None appear in the decision records. |
| C20 tier 2 | FAIL, 17 (`ENFORCE_C20` defaults to 1) | `file.lean:NNN` citations: 12 in `untl-snce-argument-order.md`, 5 in `paper-definitions-of-record.md` |
| C9D | soft, 142 -> 150 | 8 task-number citations in the moved records. Not gated, but they break `no-task-references-in-deliverables.md` once outside `specs/**` |
| C5, C13, C14 | unchanged | none new |

## Goals & Non-Goals

**Goals**:
- Record the decision and its rationale where future record authors will see it
- `git mv` both families to their `docs/` homes, keeping git history
- Zero remaining citations of the old paths outside `specs/**` (grep)
- `check-paper-definitions.sh` behaves as before the move (same exit and output class; skip-neutral if the paper is absent)
- `check-module-invariants.sh` shows no new FAIL compared with the pre-move baseline (C12/C15/C20 green; C13's 9 pre-existing failures unchanged)

**Non-Goals**:
- Rewriting `specs/**` artifacts (reports, plans, reviews, `state.json`, `TODO.md`, `specs/evidence/**` scratch `.lean`) that cite old paths. They are historical and exempt.
- Reshaping the decision records into numbered ADR-template files
- Fixing the pre-existing C13 `../../data/` failures
- Re-pinning or re-hashing any record MANIFEST row, or changing which anchors are pinned. That belongs to the paper-vocabulary reconciliation.
- Reducing C9D's pre-existing 142 count

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A blind `s#specs/decisions/#...#` hits `specs/evidence/**` or other `specs/**` files | M | M | Restrict the substitution file list to non-`specs/` paths, plus the three moved files themselves |
| `docs/theorem-index.md` relative links get the repo-root form and break C13 | M | H | Handle those two links first with the relative form; C13 confirms |
| C15 fix changes resolution semantics for real citers | H | L | Exclude only the record file from C15's cited-anchor walk (it is the resolution source, not a citer). The decision records and every other file stay in scope. Confirm the anchor count returns to 58. |
| Stale path "fixes" in records rewrite history wrongly (a path that was really retired, not moved) | M | M | Per path: if the cited content moved, cite the current path. If it was retired, reword to a non-slash description or add an allowlist entry with a reason in `scripts/markdown-slash-path-allowlist.txt` |
| Converting `file.lean:NNN` to declaration names picks the wrong declaration | M | M | Resolve each citation at the line it pointed to in the record's own git history (or by surrounding prose), using `lean_local_search`/grep to confirm the name exists |
| `check-paper-definitions.sh` output differs because of a pre-existing dangling anchor (`thm:M5-valid` was reported in simulation) | L | M | Capture the pre-move output as a baseline in Phase 1 and compare like with like |
| Concurrent in-flight tasks edit the same Lean files | M | M | Commit the path sweep as one small, purely textual commit per phase. Re-grep just before committing. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are sequential. Each phase changes the paths or content the next one measures.

### Phase 1: Baseline and move [COMPLETED]

**Goal**: Capture pre-move gate baselines, then `git mv` both record families and fix the
references among the three moved files.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh --no-build` on the clean pre-move tree and save the FAIL/PASS/TODO lines to the task dir (e.g. `specs/595_establish_durable_records_home/.baseline-invariants.txt`) *(completed: baseline is 0 FAIL, ALL CHECKS PASSED — plan's assumed 9 pre-existing C13 fails were not present at measurement time)*
- [x] Run `bash scripts/check-paper-definitions.sh` and save its exit code and tail output as a baseline *(completed: exit 1, drift detected, 1 dangling anchor thm:M5-valid — matches plan's note)*
- [x] Re-measure referrers: `grep -rnE "specs/paper-definitions-of-record\.md|specs/decisions/" --exclude-dir=.git --exclude-dir=.lake --exclude-dir=archive . | grep -v '^\./specs/'`, and save the file list *(deviation: altered — grep on `.` does not prefix `./` on this system, so used `grep -v '^specs/'` to achieve the intended exclusion; 74 lines across 33 non-specs/ files)*
- [x] `git mv specs/paper-definitions-of-record.md docs/reference/paper-definitions-of-record.md` *(completed)*
- [x] `git mv specs/decisions/total-history-validity-decisions.md specs/decisions/untl-snce-argument-order.md docs/architecture/`. Then remove the empty `specs/decisions/` directory if nothing else is in it. *(completed)*
- [x] In the three moved files, rewrite `specs/paper-definitions-of-record.md` -> `docs/reference/paper-definitions-of-record.md` and `specs/decisions/` -> `docs/architecture/` (backtick prose, not links) *(completed)*
- [x] Repoint the two scripts' functional paths: `check-paper-definitions.sh` `RECORD_DEFAULT` (line ~39) and `check-module-invariants.sh` `C15_RECORD` (line ~1643). Also repoint their comment mentions (lines 3, 9, 145, and 85, 1622). *(completed)*
- [x] Commit: `task 595 phase 1: move durable records to docs/` *(completed)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch (the move and the script repoint must land together, or C15 and `check-paper-definitions.sh` break at the intermediate state)

**Scope Hypothesis**: 3 moved files, 2 scripts, and 5 comment-line sites in scripts. Confirm with the re-measure grep. Any extra `scripts/` hit joins this phase.

**Files to modify**:
- `specs/paper-definitions-of-record.md` -> `docs/reference/paper-definitions-of-record.md` (move, plus internal cross-refs)
- `specs/decisions/*.md` -> `docs/architecture/*.md` (move, plus internal cross-refs)
- `scripts/check-paper-definitions.sh` - `RECORD_DEFAULT` and comments
- `scripts/check-module-invariants.sh` - `C15_RECORD` and comments

**Verification**:
- `bash scripts/check-paper-definitions.sh` matches the Phase 1 baseline (exit code and output class)
- `grep -n "specs/decisions\|specs/paper-definitions" docs/reference/paper-definitions-of-record.md docs/architecture/*.md scripts/check-paper-definitions.sh scripts/check-module-invariants.sh` returns nothing

---

### Phase 2: Repoint all live referrers [COMPLETED]

**Goal**: Rewrite every non-`specs/` citation of the old paths.

**Tasks**:
- [x] `docs/theorem-index.md`: rewrite both markdown links `(../specs/paper-definitions-of-record.md)` to `(reference/paper-definitions-of-record.md)` and the link text to `docs/reference/paper-definitions-of-record.md` *(completed)*
- [x] `docs/development/MODULE_INVARIANTS.md` (lines ~34, ~97): repoint prose and the section heading *(completed: deviation — landed in a concurrent task's own commit (142dae58b) before this task's phase-2 commit could include it; content correct, attribution shared)*
- [x] Lean docstrings under `FormalSystem/` and `Tests/` (non-Boneyard and Boneyard READMEs alike): replace the literal `specs/paper-definitions-of-record.md` -> `docs/reference/paper-definitions-of-record.md` and `specs/decisions/` -> `docs/architecture/`. These are plain string substitutions in comments and docstrings, never imports. *(completed)*
- [x] In-library READMEs: `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, `FormalSystem/Semantics/Correspondence/README.md`, `FormalSystem/Boneyard/README.md`, `FormalSystem/Boneyard/Kamp/KampWeakCanonical/README.md` *(completed)*
- [x] Typst and bibliography: `typst/chapters/02-semantics.typ`, `typst/chapters/p2-frame-classes.typ`, `typst/FormalFoundations.typ`, `typst/SYNC-MAP.md`, `typst/sync-check-whitelist.txt` (comment lines only), `references.bib` (note field) *(completed)*
- [x] Watch for line-wrap artifacts: a path split across a comment line break escapes grep. Also grep the bare filenames `paper-definitions-of-record` and `untl-snce-argument-order`/`total-history-validity-decisions`, and inspect any hit not preceded by the new directory. *(completed: none found)*
- [x] Re-run the Phase 1 referrer grep and confirm it is empty *(completed: empty)*
- [x] Commit: `task 595 phase 2: repoint record citations` *(completed: deviation — the commit (a8edbfc58) also swept in unrelated concurrent-task changes to FormalSystem/Semantics.lean and FormalSystem/Syntax/Formula.lean (task 596's import reorganization and task 594's #eval-removal), because those files were re-staged by another process between this agent's careful hunk-isolation step and the commit. Content is correct; commit attribution is shared with those concurrent tasks. No history rewrite was attempted, per git-safety rules.)*

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: about 47 citation lines across about 32 non-`specs/` files (planning-time grep: 26 Lean/test lines for paper-defs, 19 for decisions, plus docs/typst/bib/README hits). Confirm with the Phase 1 re-measure. The acceptance bar is an empty grep, not this count.

**Files to modify**:
- `FormalSystem/**/*.lean`, `Tests/BimodalTest/**/*.lean` - docstring path strings
- `FormalSystem/**/README.md` (4 files) - path strings
- `docs/theorem-index.md`, `docs/development/MODULE_INVARIANTS.md`
- `typst/**` (5 files), `references.bib`

**Verification**:
- `grep -rnE "specs/paper-definitions-of-record|specs/decisions/" --exclude-dir=.git --exclude-dir=.lake --exclude-dir=archive . | grep -v '^\./specs/'` returns nothing
- `bash scripts/typst-sync-check.sh` result unchanged from before this phase (it reads the whitelist)
- No `.lean` change outside comments or docstrings (`git diff -U0 -- '*.lean'` shows only comment lines). No `lake build` is needed for comment-only edits.

---

### Phase 3: Clear the new `docs/` gate exposure [NOT STARTED]

**Goal**: Turn C12, C15 and C20 tier 2 green again, and remove the task-number citations that
the move brought into deliverable scope.

**Tasks**:
- [ ] **C15**: in `scripts/check-module-invariants.sh`'s C15 cited-anchor grep (and its failure-location grep), exclude the record file itself, e.g. `--exclude=paper-definitions-of-record.md`. Update the C15 SCOPE comment to say the resolution source is not a citer. Leave the decision records in scope.
- [ ] **C12**: for each of the 5 unresolved slash paths, find where the cited content lives now (e.g. `FormalSystem/BaseLanguage/Axioms.lean` probably maps to `FormalSystem/ProofSystem/Axioms.lean`; confirm by the declaration the surrounding prose names). If it moved, cite the current path. If it was retired (likely `Semantics/WorldHistory.lean`, `WeakCanonical/Kamp/Boneyard`), reword to a declaration or module description, or add an entry with a reason to `scripts/markdown-slash-path-allowlist.txt`.
- [ ] **C20 tier 2**: convert the 17 `file.lean:NNN` citations (12 in `untl-snce-argument-order.md`, 5 in `paper-definitions-of-record.md`) to declaration names, as the gate itself advises. Resolve each line against the file contents at the record's last commit (`git log`/`git show` on the pre-move path) and confirm the name exists in the current tree. Do not add a C20 scope exclusion.
- [ ] **Task-number citations**: rewrite the task-number mentions in the three moved files (C9D delta: 8) to durable anchors (a decision record name, a section heading, a dated finding). Confirm the C9D count returns to the 142 baseline.
- [ ] Do not touch MANIFEST rows or hash values in the record
- [ ] Commit: `task 595 phase 3: clear docs gate exposure for moved records`

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: 5 C12 paths, 17 C15 anchors (all in the record file), 17 C20 citations and 8 C9D mentions, from the planning-time simulation. Confirm by running `check-module-invariants.sh --no-build` at phase start and working from its actual output.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C15 scope exclusion and comment
- `docs/reference/paper-definitions-of-record.md` - stale paths, line citations, task refs (prose only)
- `docs/architecture/total-history-validity-decisions.md`, `docs/architecture/untl-snce-argument-order.md` - same
- `scripts/markdown-slash-path-allowlist.txt` - only if a retired path is kept verbatim

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build`: C12 PASS, C15 PASS (both assertions, anchor count back to 58), C20 tier 1 and tier 2 PASS, C9D count 142, C13 still exactly the 9 pre-existing failures, no other FAIL beyond the Phase 1 baseline
- `bash scripts/check-paper-definitions.sh` still matches the Phase 1 baseline (MANIFEST untouched)

---

### Phase 4: Record the placement decision and final gate [NOT STARTED]

**Goal**: Write down the chosen home and the rule, catalog the moved files, and run the full acceptance gate.

**Tasks**:
- [ ] `docs/reference/README.md`: add a "Records of Record" (or similar) table row for `paper-definitions-of-record.md` (pinned paper-anchor manifest; resolution source for C15 and `check-paper-definitions.sh`)
- [ ] `docs/architecture/README.md`: add rows for both decision records to the "Specification Documents" table (fix the heading text if it becomes "Specification and Decision Documents")
- [ ] `docs/README.md` (or `docs/architecture/README.md`, whichever the implementer judges the natural entry point, with a one-line pointer from the other): add a short **Durable records placement** rule with rationale. `specs/` is the ephemeral task-management tree (renumbered, archived, partly gitignored). A record cited from live code or checked by a script belongs under `docs/`: decision records in `docs/architecture/`, reference manifests in `docs/reference/`. `docs/decisions/` is not used.
- [ ] Follow no-task-references: cite section headings and filenames only
- [ ] Final acceptance run: referrer grep empty; `bash scripts/check-paper-definitions.sh` matches baseline; `bash scripts/check-module-invariants.sh --no-build` has no FAIL beyond the pre-existing C13 nine. Then run the full `bash scripts/check-module-invariants.sh` with build if time allows. The edits are comment-only, so the build-gated checks should not change; if the full run is skipped, record why.
- [ ] Remove the Phase 1 baseline scratch files from the task dir, or leave them in as dotfiles
- [ ] Commit: `task 595 phase 4: record durable records home`

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `docs/reference/README.md`, `docs/architecture/README.md`, `docs/README.md`

**Verification**:
- C13 unchanged (new catalog links resolve)
- C18 still PASS (no duplicated rule prose between the two READMEs; use a pointer, not a copy)
- All acceptance criteria below hold

## Testing & Validation

- [ ] `grep -rnE "specs/paper-definitions-of-record|specs/decisions/" --exclude-dir=.git --exclude-dir=.lake --exclude-dir=archive . | grep -v '^\./specs/'` is empty
- [ ] `bash scripts/check-paper-definitions.sh` exit code and output class match the pre-move baseline (skip-neutral when the paper is absent)
- [ ] `bash scripts/check-module-invariants.sh --no-build`: no FAIL beyond the baseline (C13's 9 pre-existing `../../data/` links); C12, C15 (both), C20 (both tiers) PASS
- [ ] `bash scripts/typst-sync-check.sh` unchanged from baseline
- [ ] `git log --follow docs/reference/paper-definitions-of-record.md` shows pre-move history
- [ ] Placement rule present in the docs README(s)

## Artifacts & Outputs

- `docs/reference/paper-definitions-of-record.md` (moved)
- `docs/architecture/total-history-validity-decisions.md`, `docs/architecture/untl-snce-argument-order.md` (moved)
- Updated `scripts/check-paper-definitions.sh`, `scripts/check-module-invariants.sh`
- Updated catalog and placement rule in `docs/README.md`, `docs/reference/README.md`, `docs/architecture/README.md`
- `specs/595_establish_durable_records_home/summaries/01_durable-records-home-summary.md`

## Rollback/Contingency

Each phase is its own commit. Rolling back a phase means `git revert` of that commit, which is
safe on a clean tree. Phase 1 must never be reverted on its own while Phase 2+ commits exist.
Revert in reverse order. If Phase 3's gate exposure proves unexpectedly large (for example, far
more than the measured C20 citations), stop after Phase 2 at `[PARTIAL]`, with the moved records
and a red gate recorded, rather than weakening C12/C20 scope. For an uncommitted-work rollback,
follow `context/contracts/recovery.md`'s rollback rung for the snapshot invocation.
