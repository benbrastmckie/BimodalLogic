# Implementation Plan: Move tool and Boneyard relocation

- **Task**: 630 - Move tool and Boneyard relocation
- **Status**: [IMPLEMENTING]
- **Effort**: 11 hours
- **Dependencies**: None blocking. No edge to task 631 in either direction (ADR-010 decision 4 disclaims dependence on the frozen-LaTeX retirement, and `latex/` carries no `Boneyard` reference). Tasks 632 and 633 depend on this one.
- **Research Inputs**: specs/630_move_tool_and_boneyard_relocation/reports/01_move-tool-boneyard-relocation.md
- **Artifacts**: plans/01_move-tool-boneyard-relocation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two deliverables, in order: a general module-relocation tool (`scripts/move-modules.py`) that
rewrites imports, dotted and slash citations, namespace/`open`/FQN occurrences, the C2/C14 axiom
baselines and `MainResults.lean`, re-bases relative links in moved markdown, performs the `git mv`,
and closes by running the invariant harness; then its first production use, relocating
`FormalSystem/Boneyard/` to a root-level `Boneyard/` with module names `Boneyard.*`. The move is
mechanically a change of module *name* only — nothing under the archive is ever compiled, every
archived file carries `#exit`, and no declaration, proof or axiom baseline is touched. Done when
`lake build` and `lake build BimodalTest` exit 0, `check-module-invariants.sh` is green with its
C11 denominator intact, no `.olean` exists under `Boneyard/`, the archive README's counts
regenerate from the new location, and ADR-010 is Accepted.

### Research Integration

The report's measured baseline is the plan's contract, and three of its findings shape the phase
structure directly:

- **The bare-`Boneyard/` class must not be rewritten.** 77 files outside the archive (plus 37
  inside) cite it as `Boneyard/Foo/Bar.lean` with no `FormalSystem/` prefix. These are relative to
  `FormalSystem/` today and become *correct repo-root paths* after the move. Every rewrite rule is
  therefore anchored on the full old prefix, never the bare token; a rule of the shape
  `s|Boneyard/|…|` would corrupt 114 files. Phase 4 exists to assert a zero touch-count for this
  class before anything moves.
- **The gate widening cannot land before the move.** The report's C12/C5 simulation was run
  *post-move*. Widening `slash_re` to admit `Boneyard` while the archive still sits under
  `FormalSystem/` pulls bare `Boneyard/…` citations into C12 scope where they do **not** yet
  resolve — turning the harness red pre-move. This is why Phase 6 is a single atomic batch rather
  than a widening phase followed by a move phase.
- **Relative links must be re-based by resolve-map-recompute, not by `../`-counting.** Of 83 links
  in the archive's 56 markdown files, 76 resolve unchanged, 3 need one `../` dropped, and 2 need a
  `FormalSystem/` segment *inserted*. A `../`-counting heuristic gets those last 2 wrong, and they
  lie outside C13's scope, so no gate would catch the breakage.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` supplied with this dispatch; no ROADMAP.md consulted. The programme-level
sequencing this task serves is recorded in `docs/development/PUBLICATION_REFACTOR.md` Phase 2.

## Goals & Non-Goals

**Goals**:
- `scripts/move-modules.py`: a reusable module-relocation tool with prefix-matched module mapping,
  optional namespace mapping, seven separately-counted rewrite classes, a dry-run mode, and a
  closing harness run.
- Relocate `FormalSystem/Boneyard/` to `Boneyard/`, module names `FormalSystem.Boneyard.*` to
  `Boneyard.*`, in one scripted commit preserving `git mv` provenance.
- Re-root B0 and C11, widen C12/C5/C11's patterns, and add the two invariants ADR-010 names (B1,
  B2).
- Accept ADR-010; update ADR-009's status pointer; correct the stale prose figures in both records.

**Non-Goals**:
- Retiring `latex/` (task 631's Phase 1).
- The `BimodalTools` split (programme Phase 3) and `lake exe mk_all --check` adoption (Phase 8).
  This task only makes the latter *adoptable*.
- Any change to `scripts/lib/live_walk.py`, which filters on the directory *name* and is correct
  before and after the move without edit (ADR-005's rule, ADR-010 decision 5).
- Any proof, declaration, axiom baseline, or `sorry` change. There are none in scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A rewrite rule keyed on the bare token `Boneyard` | H — 114 files corrupted, 76 live docstring paths silently wrong | M | Anchor every rule on the full `FormalSystem/Boneyard` / `FormalSystem.Boneyard` prefix; Phase 4 asserts a zero touch-count for bare-form occurrences before any mutation |
| C11's import regex not widened to admit `Boneyard` | H — C11 prints PASS on a shrunken denominator; the archive rots unobserved | M | Phase 7 asserts the post-move C11 line still reads 539 import lines in 169 files, 8 waived. Anything less is a gate failure even though the check prints PASS |
| C12/C5 widened *before* the move | H — harness red pre-move; bare `Boneyard/…` paths do not resolve until the archive is at the root | M | Widening is inside Phase 6's atomic batch, never a separate earlier commit. Recorded explicitly in Phase 6's tasks |
| C12/C5 not widened at all | H — 46 citations silently leave gate scope with a green board | M | Same batch; Phase 7 re-counts C12 and C5 scope post-move |
| `archive_dir_count()` left rooted at `FormalSystem` | M — archive README regenerates "Archive directories in the repository" as 0, `INV --check` goes red | M | Re-root at `.` with `.lake`/`.git` exclusions (harness site 5); Phase 7 re-runs `--emit-inventory` and diffs |
| Relative links re-based by `../`-counting | M — 2 archive READMEs get silently broken links, outside C13 scope | M | Resolve-map-recompute algorithm (Phase 3); Phase 7 hand-checks the 5 known non-trivial links |
| `git mv` of 225 files performed as delete+add | M — provenance lost, ADR-009 obligation 2 weakened | L | Single `git mv` of the directory; Phase 7 verifies with `git log --follow` on one archived file |
| Stale prose figures shipped alongside an accepted ADR | M — an accepted record disagreeing with the tree it describes | H (already true today) | Phase 8 corrects both records against the measured tree: ADR-009's 168/536/7 and "49 recorded C11 waivers" against actual 169/539/8 and 8 waiver entries; ADR-010's 538/169/48/43 against actual 539/169/47 live `.lean` citers/43 non-specs markdown citers |
| Concurrent sibling dispatch (task 626) on the same working tree | M — foreign edits mistaken for this task's regressions | M | Per the dispatch territory note: re-read every file immediately before editing; stage only this task's own hunks; never `git add` a directory or glob; never run `git-snapshot.sh` in its reverting default mode. Task 626's declared scope (`FormalSystem/**/PlusLanguage/**`, `StarLanguage/README.md`, `docs/reference/paper-definitions-of-record.md`) is disjoint from this task's, but `docs/` and the tree are shared |
| `scripts/move-modules.py` trips C9 (zero task-number citations under `scripts/`) | L — new file fails a gate on its first commit | L | The repo-wide `no-task-references-in-deliverables` rule applies: cite durable anchors (ADR numbers, filenames), never a task number, anywhere in the new script or its `scripts/README.md` row |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 5 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

Phases within the same wave can execute in parallel. Phases 1 and 5 touch disjoint files
(`scripts/move-modules.py` versus `scripts/check-module-invariants.sh` +
`docs/development/MODULE_INVARIANTS.md`) and are genuinely parallelizable; Phases 2 and 3 both
edit the new script and are therefore strictly sequential.

---

### Phase 1: Move tool — CLI, mapping, and rewrite classes 1-3 [COMPLETED]

**Completion note**: census re-measured against the current tree and matches the report exactly —
41 external citer files (20 `docs/`, 12 `FormalSystem/`, 6 `scripts/`, 2 `typst/`, 1 root), 178
archived `import FormalSystem.Boneyard.*` lines in 88 files, 77 external + 37 internal bare-form
citer files. The tool's class counts (178 / 9 / 134) were confirmed against an independent
standalone census, not just self-reported.

**Goal**: `scripts/move-modules.py` exists, parses its maps, derives the path mapping, and
implements the three citation-rewrite classes that do the bulk of the work, with per-class counts.

**Tasks**:
- [ ] Create `scripts/move-modules.py` with argument parsing: `--module-map FILE`,
      `--namespace-map FILE` (optional), `--dry-run`, `--no-verify`.
- [ ] Parse module-map lines of the form `old.module -> new.module`; match entries as **module
      prefixes**, longest first, so `FormalSystem.Boneyard -> Boneyard` is one auditable line.
- [ ] Derive the path map from the module map (`FormalSystem/Boneyard` -> `Boneyard`) rather than
      accepting it as a second input, so the two cannot drift.
- [ ] Implement class 1 — `import` lines in `FormalSystem/**`, `Tests/**` and the archive, anchored
      `^import <old>(\.…)?$`.
- [ ] Implement class 2 — dotted occurrences elsewhere: `\bFormalSystem\.Boneyard\b` -> `Boneyard`,
      across `.lean` docstrings, markdown, `.typ`, and `scripts/` (`.sh`, `.py`, `.txt`).
- [ ] Implement class 3 — slash paths: `\bFormalSystem/Boneyard\b` -> `Boneyard`, same scope plus
      `.github/workflows/`. **Anchored on the full old prefix, never the bare token.**
- [ ] Implement the exclusion set: `specs/**`, `.git/`, `.lake/`, `build/`.
- [ ] Emit per-class counts in the dry-run report — per class, not a flat file list.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the report's census asserts 41 tracked non-archive files carrying
`FormalSystem/Boneyard` or `FormalSystem.Boneyard` (20 `docs/`, 12 `FormalSystem/`, 6 `scripts/`,
2 `typst/`, 1 root), and 178 archived `import FormalSystem.Boneyard.*` lines across 88 files.
Confirm at implementation time by re-running the report's Appendix grep commands against the
current tree before trusting the number; a sibling dispatch may have changed `docs/` since the
census was taken. Treat any divergence as a fact to re-measure, not a defect to suppress.

**Files to modify**:
- `scripts/move-modules.py` - new file; CLI, map parsing, path derivation, classes 1-3, exclusions,
  dry-run counting.

**Verification**:
- `python3 scripts/move-modules.py --module-map <map> --dry-run` runs clean and reports non-zero
  counts for classes 1-3.
- The class-3 count excludes every bare `Boneyard/…` occurrence (spot-check two known bare-form
  files from the report's census).

---

### Phase 2: Move tool — namespace, axiom-baseline, and `git mv` classes [COMPLETED]

**Completion note**: classes 4 and 5 report zero-touch for the archive mapping, as predicted. Both
were exercised for real against two throwaway synthetic namespace maps rather than left as unrun
code: `FormalSystem.Metalogic.BXCanonical -> …BXC` drives class 4 to 297 occurrences in 79 files
and class 5 to the harness's 8 `AXIOM_BASELINE` lines; `FormalSystem.Metalogic.soundness -> …` drives
class 5 to 2 occurrences across *both* of its sites, proving the `MainResults.lean` `#print axioms`
site is live rather than dead code. A dry run leaves `git status` untouched.

**Goal**: The remaining non-link rewrite classes plus the tree move and the closing harness
invocation.

**Tasks**:
- [ ] Implement class 4 — `namespace` / `open` / FQN occurrences, driven by `--namespace-map`.
      A no-op for this mapping (no live declaration changes namespace).
- [ ] Implement class 5 — the C2 and C14 axiom baselines in `scripts/check-module-invariants.sh`
      and every `#print axioms` line in `FormalSystem/MainResults.lean`. Also a no-op for this
      mapping. Implement it anyway: programme Phase 3 and ADR-011's extraction depend on it, and a
      class that is never exercised is a class that is never correct.
- [ ] Implement class 6 — `git mv <old-path> <new-path>` for the tree itself, as a **single** `git
      mv` of the directory, never a delete-and-add.
- [ ] Implement the closing step: `bash scripts/check-module-invariants.sh --no-build`, exit code
      propagated; suppressed by `--no-verify` for composing several maps.
- [ ] Ensure `--dry-run` performs no `git mv` and no harness run, and still reports what classes 4
      and 5 would touch (zero, for this mapping).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `scripts/move-modules.py` - classes 4-6, closing harness invocation, `--no-verify`.

**Verification**:
- A dry run reports classes 4 and 5 as zero-touch for the archive mapping, and non-zero for a
  throwaway synthetic namespace map (exercising class 4's code path at least once).
- The `git mv` path is reachable only outside `--dry-run`.

---

### Phase 3: Move tool — relative-link re-basing and the script inventory row [COMPLETED]

**Completion note**: the dry-run link breakdown reproduces the report's partition exactly — 83
scanned, 76 unchanged, 5 re-based, 2 skipped as non-paths. Both `FormalSystem/`-insertion cases
(`Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` and
`Kamp/KampWeakCanonical/Separation/Hierarchy/README.md`, each pointing at a live
`Metalogic/WeakCanonical/…` README) land in the re-based set with the segment correctly inserted,
which is precisely what a `../`-counting heuristic would have got wrong.

**Goal**: Class 7, the subtlest rewrite, implemented by the correct algorithm; the new script is
registered in the directory's inventory.

**Tasks**:
- [ ] Implement class 7 by **resolve-map-recompute**: for every relative link in a file the mapping
      moves, resolve the target against the *old* directory to a repo-relative path, apply the path
      mapping to that repo-relative path, then recompute the relative path from the *new* directory.
- [ ] Do **not** implement a `../`-counting heuristic. It gets the two `FormalSystem/`-insertion
      cases wrong, and those links lie outside C13's `docs/` + `README.md` scope, so no gate would
      catch the error.
- [ ] Handle the markdown-link regex's known false positives (`](a)`-shaped non-links) without
      rewriting them.
- [ ] Finalize the dry-run report shape: one line per class with a count, plus the link-re-basing
      breakdown (unchanged / re-based).
- [ ] Add a `scripts/README.md` row for `move-modules.py`, matching the table's existing one-line
      description style. Cite durable anchors only — no task numbers anywhere in the script or the
      row (C9 scans `scripts/`; the repo-wide no-task-references rule applies).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: the report simulated 83 markdown links across the archive's 56 `.md` files,
partitioning them 76 unchanged / 3 drop one `../` / 2 insert `FormalSystem/` / 2 regex false
positives. Confirm by running this phase's own dry run and comparing its link breakdown against
that partition before proceeding to Phase 4; a mismatch means either the algorithm or the census
is wrong and must be resolved, not averaged.

**Files to modify**:
- `scripts/move-modules.py` - class 7, dry-run report shape.
- `scripts/README.md` - one inventory row for the new script.

**Verification**:
- Dry-run link breakdown matches the 76 / 3 / 2 partition (2 false positives excluded).
- The 2 known `FormalSystem/`-insertion cases (`Boneyard/Kamp/…/Hierarchy/README.md` pointing at
  `…/Metalogic/…`) appear in the re-based set, not the unchanged set.

---

### Phase 4: Full dry run against the measured census — no mutation [COMPLETED]

**Completion note — re-measured census (the carried figures for Phase 7)**: every one of the
report's hypotheses reproduced against the current tree with no divergence. Harness `--no-build`
exit 0, zero FAIL. 1 `Boneyard` directory (`./FormalSystem/Boneyard`). 169 archived `.lean`, 56
archived `.md`, 225 tracked files, 169/169 carrying `#exit`. 0 live importers, 0 `.olean`. C11:
**539 import lines across 169 files, 8 waived**. 41 external citer files (20 `docs/`, 12
`FormalSystem/`, 6 `scripts/`, 2 `typst/`, 1 root). 178 archived `import FormalSystem.Boneyard.*`
lines in 88 files. 9 generated inventory markers naming `dir=FormalSystem/Boneyard…`. 77 external
+ 37 internal bare-form citer files.

Dry-run per-class counts: 178 / 9 / 134 / 0 / 0, one subtree move, 5 links re-based of 83 scanned,
153 files changed. **Bare-form touch count is exactly 0** (241 occurrences before, 241 after, in
114 files). `git status` showed no change attributable to this phase. Dry-run output recorded for
Phase 7's diff.

**Goal**: Prove the tool reproduces the research's measured census exactly, before a single file
moves. This is the gate that catches the bare-token trap.

**Tasks**:
- [ ] Write the module map file: the single line `FormalSystem.Boneyard -> Boneyard`. No namespace
      map.
- [ ] Re-measure the baseline from the report's Appendix commands against the *current* tree
      (harness `--no-build` green; 1 `Boneyard` directory; 169 archived `.lean`; 225 tracked files;
      169 `#exit`; 0 live importers; 0 `.olean`; C11 reporting 539 lines / 169 files / 8 waived).
- [ ] Run the full dry run and compare every per-class count against the re-measured census.
- [ ] **Assert a zero touch-count for every bare-form `Boneyard/…` occurrence.** This is the single
      most likely way to get the move wrong; it gets its own explicit assertion, not an inference
      from a passing total.
- [ ] Record the dry-run output verbatim so Phase 7 can diff the realized move against it.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the whole report census (41 external citer files; 178
archived import lines in 88 files; 539/169/8 C11 figures; 9 generated inventory markers carrying
`dir=FormalSystem/Boneyard…`). Every one of these is a hypothesis measured at research time on a
shared working tree with a concurrent sibling dispatch. Confirm each by re-running its command in
this phase before the move; carry forward the *re-measured* numbers, not the recorded ones, if
they differ, and state the difference in the phase's completion note.

**Files to modify**:
- None (read-only dry run). A module-map file may be written to the scratchpad rather than the
  repository, since it is a one-line input, not a deliverable.

**Verification**:
- Dry run exits 0 and every per-class count matches the re-measured census.
- Bare-form touch count is exactly 0.
- `git status --porcelain` shows no change attributable to this phase.

---

### Phase 5: Add invariants B1 and B2 [COMPLETED]

**Completion note**: B1 and B2 sit beside B0 and both report PASS. The full gate set (build tier
included) ran green before this phase closed: 44 checks, zero FAIL, `ALL CHECKS PASSED`, exit 0,
with `C1 lake build`, `C1 lake build BimodalTest` and `C11 539/169/8` all green on the pre-move
tree. The first attempt at this run was killed by a system-wide low-memory reap while a sibling
dispatch held a concurrent full build; the re-run against the warm cache completed normally. That
kill was an environment event, not a gate result — no verdict was captured from it and none was
inferred.

**Goal**: The two invariants ADR-010 names, added while they are green on *both* sides of the move,
so the atomic move batch carries less.

**Tasks**:
- [ ] Add **B1** — `Boneyard` appears nowhere in `lakefile.toml` and nowhere in the root aggregator
      `FormalSystem.lean`. Both are cheap greps; verified absent from both today.
- [ ] Add **B2** — no live `.lean` under `FormalSystem/` or `Tests/` carries `import Boneyard.*`.
      Verified zero today (for the `FormalSystem.Boneyard.*` form) and zero after the move.
- [ ] Place both next to B0 in `scripts/check-module-invariants.sh`.
- [ ] Add B1 and B2 headers to the script's check list in the file header comment block.
- [ ] Add B1 and B2 rows to `docs/development/MODULE_INVARIANTS.md`'s table. Leave B0's and C11's
      existing descriptions alone — they correctly describe the pre-move location and are updated
      in Phase 8.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Files to modify**:
- `scripts/check-module-invariants.sh` - B1 and B2 check blocks beside B0; two header check-list
  lines.
- `docs/development/MODULE_INVARIANTS.md` - two table rows.

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with B1 and B2 both reporting PASS.
- The full gate set runs green before this phase closes.

---

### Phase 6: The move — tool run, harness re-rooting, and gate widening in one commit [NOT STARTED]

**Goal**: Relocate the archive and bring every gate with it, atomically. Intermediate per-file
states are expected red: the harness cannot be green between the widening and the move.

**Tasks**:
- [ ] Take a durable, non-reverting checkpoint before starting:
      `bash .claude/scripts/git-snapshot.sh 630 --no-revert`. This is a checkpoint, not a rollback;
      do **not** use the reverting default form here.
- [ ] Re-read every file immediately before editing it (concurrent sibling dispatch on this tree).
- [ ] Run `scripts/move-modules.py` for real with the single-line module map: all seven classes plus
      the `git mv`.
- [ ] Harness hand edit 1 — **B0 search**: replace `find FormalSystem -type d -name Boneyard` with a
      search from `.` excluding `./.lake/*` and `./.git/*`; assert exactly 1 **and** that it is
      `./Boneyard`.
- [ ] Harness hand edit 2 — **B0 load-bearing half**: invert it. Assert `find Boneyard -name
      '*.lean'` is non-zero **and** that the `FormalSystem/` walk now finds zero archived files
      (`ALL_LEAN == LIVE_LEAN`).
- [ ] Harness hand edit 3 — **C11 archive root**: root the scan at `Boneyard/` instead of walking
      `FormalSystem` for directories named `Boneyard`. Same waiver file, same resolution rule.
- [ ] Harness hand edit 4 — **C17 archive occurrence scan**: `os.walk(os.path.join("FormalSystem",
      "Boneyard"))` becomes `os.walk("Boneyard")`.
- [ ] Harness hand edit 5 — **`archive_dir_count()`**: re-root its default from `"FormalSystem"` to
      `"."` with the same `.lake`/`.git` exclusions. Without this the archive README's "Archive
      directories in the repository" row regenerates as 0 and `INV --check` goes red.
- [ ] Harness hand edit 6a — **C12 `slash_re`**: add `Boneyard` to the alternation
      (`FormalSystem|Tests|Logos|Bimodal`). Simulated post-move: all 40 previously-gated occurrences
      resolve, plus 2 already-present bare ones, 0 new failures.
- [ ] Harness hand edit 6b — **C5 `mod_re`**: add `Boneyard` to the alternation
      (`FormalSystem|BimodalTest`). C5's `resolves()` already maps a leading non-`BimodalTest`
      component to the repo root, so `Boneyard.X` -> `./Boneyard/X` needs no further change.
- [ ] Harness hand edit 6c — **C11's import regex**: give C11 its own regex admitting `Boneyard`.
      **Leave C4's `imp_re` alone** — a live file importing `Boneyard.*` is B2's failure, not a C4
      resolution question.
- [ ] Hand-edit `README.md`'s tree diagram: it shows `Boneyard/` nested under `FormalSystem/` and
      needs a structural edit, not a string substitution. The tool will not get this right.
- [ ] Stage only this task's own hunks — an explicit file list, never `git add -A`, never a
      directory or glob pathspec.
- [ ] Commit the whole batch as one commit.

**Timing**: 2 hours

**Depends on**: 4, 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts exactly six harness hand-edit sites plus one `README.md`
structural edit. The six were located by the research at named anchors (B0 search, B0 load-bearing
half, C11 archive roots, C17 archive walk, `archive_dir_count`, and the C12/C5 patterns). Confirm
the set is complete at implementation time by grepping the harness for every remaining
`FormalSystem.*Boneyard` and bare `Boneyard` occurrence *after* the tool run and before committing;
a seventh site found there is a real finding, not an overrun.

**Files to modify**:
- `FormalSystem/Boneyard/**` -> `Boneyard/**` - 225 tracked files, one `git mv`.
- `scripts/check-module-invariants.sh` - six hand edits (B0 x2, C11 root, C17 walk,
  `archive_dir_count`, C12/C5/C11 patterns).
- 41 tracked citer files across `docs/`, `FormalSystem/`, `scripts/`, `typst/`, `ORGANISATION.md` -
  tool-rewritten.
- `README.md` - tree diagram, hand edit.

**Verification**:
- The tool's closing `bash scripts/check-module-invariants.sh --no-build` exits 0.
- `git status` shows renames (R), not delete+add pairs, for the archive.
- No bare-form `Boneyard/…` citation changed: `git diff` over the 77 known bare-form citer files is
  empty.

---

### Phase 7: Post-move regeneration, denominator assertions, and acceptance criteria [NOT STARTED]

**Goal**: Prove the move landed correctly rather than merely quietly — including the gate that
prints PASS while having lost scope.

**Tasks**:
- [ ] Re-run `--emit-inventory` and re-check `INV`. The 9 generated inventory markers (the archive
      README twice, plus 7 subtree READMEs) must regenerate from the new location. This is ADR-009
      obligation 1 and the dispatch's "archive README's counts regenerate" acceptance clause.
- [ ] **Assert the C11 denominator**: the post-move C11 line must still read 539 import lines across
      169 files, 8 waived. Anything less is the signature of an un-widened import regex and is a
      gate failure even though C11 prints PASS.
- [ ] Confirm "Archive directories in the repository" regenerates non-zero (not 0), proving harness
      edit 5 took.
- [ ] Hand-check the 5 known non-trivial re-based links (3 that drop a `../`, 2 that insert
      `FormalSystem/`) resolve on disk.
- [ ] Verify provenance: `git log --follow` on one archived file crosses the rename.
- [ ] Run the acceptance set: `lake build` exits 0; `lake build BimodalTest` exits 0;
      `bash scripts/check-module-invariants.sh` green; `find .lake -path '*Boneyard*' -name
      '*.olean'` returns nothing; exactly one `Boneyard` directory repo-wide and it is `./Boneyard`.
- [ ] Re-count C12 and C5 scope to confirm the 46 previously-gated citations are still in scope
      post-move, not silently dropped.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: the 539/169/8 C11 triple and the 46-citation C12+C5 figure are both
research-time measurements. Re-measure both against the pre-move tree in Phase 4 and carry those
numbers here; assert the *carried* numbers, so a legitimate pre-move change by a sibling dispatch
is not mistaken for this task's regression.

**Files to modify**:
- `Boneyard/README.md` and 7 subtree `README.md` files - regenerated inventory blocks only.

**Verification**:
- Every acceptance criterion above passes.
- The realized diff's per-class file counts match Phase 4's recorded dry-run output.

---

### Phase 8: Accept ADR-010, update ADR-009, and correct the stale prose [NOT STARTED]

**Goal**: The architectural record matches the tree it describes.

**Tasks**:
- [ ] Change ADR-010's status from **Proposed** to **Accepted**, with the acceptance date.
- [ ] Update ADR-009's status pointer: ADR-010 says ADR-009 "stays Accepted until this record is",
      so ADR-009's location clause and its retired LaTeX rationale bullet now point at ADR-010.
- [ ] Correct ADR-009's stale figures against the measured tree: it says "168 archived files",
      "536 archived import lines", "7 waived" and "49 recorded C11 waivers"; the tree has **169**,
      **539**, **8**, and the waiver file holds **8 entries**.
- [ ] Correct ADR-010's stale figures: it says "538 archived imports", "169 modules", "48 live
      docstrings", "43 markdown files"; measured are **539**, **169**, **47** live `.lean` citers,
      **43** non-specs markdown citers.
- [ ] Update ADR-010's Related link to the archive README, which the move relocated.
- [ ] Update `docs/development/MODULE_INVARIANTS.md`'s B0 and C11 descriptions to the new scan
      roots (they described the pre-move location correctly until now).
- [ ] Mark the corresponding `docs/development/PUBLICATION_REFACTOR.md` Phase 2 item as performed.
- [ ] Clean up `.github/workflows/ci.yml`'s now-no-op `check-copyright-headers.sh --strict
      --exclude '*/Boneyard/*' FormalSystem` invocation — the archive has left the scanned root
      entirely, so the `--exclude` no longer excludes anything.

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: prose

**Scope Hypothesis**: seven specific stale figures are asserted across the two ADRs (169/539/8/8
for ADR-009; 539/169/47/43 for ADR-010). Confirm each against the tree at implementation time
before editing — these are the exact figures the ADRs got wrong once already, and copying a
second-hand number into an *accepted* record repeats the defect this phase exists to fix.

**Files to modify**:
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` - status, figures, Related link.
- `docs/architecture/ADR-009-Boneyard-Retention.md` - status pointer, four stale figures.
- `docs/development/MODULE_INVARIANTS.md` - B0 and C11 descriptions.
- `docs/development/PUBLICATION_REFACTOR.md` - Phase 2 item.
- `.github/workflows/ci.yml` - drop the no-op `--exclude`.

**Verification**:
- Every changed hunk lies inside prose or a workflow argument list; no compile or elaboration
  surface is touched (`.github/workflows/ci.yml` is the one non-prose file and its change is a
  removed CLI flag, re-verified by a full harness run).
- `bash scripts/check-module-invariants.sh` stays green (C12/C13 gate the ADR and docs paths).

## Lean Challenge Statements

This plan's `task_type` is `lean4`, so this section is present by format. It is **deliberately
empty**: the task commits to no theorem, no declaration and no proof. Nothing under the archive is
compiled, the move changes module *names* only, and no `#print axioms` baseline changes. The
`- **Goals**:` bullets above name no Lean identifiers, so the identifier sets on both sides of the
format's cross-validation requirement are equal (both empty), as required.

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 at the end of Phases 5, 6 and 7.
- [ ] `bash scripts/check-module-invariants.sh` (full, with build) exits 0 at the end of Phase 7.
- [ ] `lake build` exits 0.
- [ ] `lake build BimodalTest` exits 0.
- [ ] `find . -type d -name Boneyard -not -path './.git/*' -not -path './.lake/*'` returns exactly
      `./Boneyard`.
- [ ] `find .lake -path '*Boneyard*' -name '*.olean'` returns nothing.
- [ ] C11 reports 539 import lines across 169 files, 8 waived (the carried, re-measured figures).
- [ ] `--emit-inventory` regenerates and `INV --check` passes, with a non-zero archive-directory
      count.
- [ ] `git log --follow` on one archived file crosses the rename.
- [ ] Zero task-number citations in `scripts/move-modules.py` and its `scripts/README.md` row (C9).

## Artifacts & Outputs

- `scripts/move-modules.py` - the reusable module-relocation tool.
- `scripts/README.md` - one new inventory row.
- `Boneyard/**` - 225 relocated tracked files (was `FormalSystem/Boneyard/**`).
- `scripts/check-module-invariants.sh` - B1, B2, six re-rooting/widening edits.
- 41 rewritten citer files plus `README.md`'s tree diagram.
- `docs/architecture/ADR-010-…` (Accepted), `docs/architecture/ADR-009-…`,
  `docs/development/MODULE_INVARIANTS.md`, `docs/development/PUBLICATION_REFACTOR.md`,
  `.github/workflows/ci.yml`.
- `specs/630_move_tool_and_boneyard_relocation/summaries/01_move-tool-boneyard-relocation-summary.md`

## Rollback/Contingency

Phases 1-5 are ordinary incremental commits and revert individually with `git revert`.

Phase 6 is the only phase whose failure warrants a working-tree rollback, because it is a single
atomic batch spanning a 225-file `git mv`. Its first task takes a durable, non-reverting checkpoint
(`git-snapshot.sh 630 --no-revert`) precisely so that a mid-batch failure has somewhere to return
to. If the batch must genuinely be unwound, follow `context/contracts/recovery.md`'s rollback
rung for the exact snapshot-then-rollback invocation shape, including its out-of-scope override
flag for the whole-tree case — a `git mv` of a directory plus six harness edits will not sit inside
a narrow declared `file_scope`. Do not improvise a `git reset --hard`; the guard hook will block it
on a dirty tree, and correctly so.

Because the move is a change of module name only, with nothing under the archive compiled and every
archived file carrying `#exit`, a failed rollback cannot leave the *build* broken — it can only
leave citations half-rewritten. The recovery signal for that state is the harness: run
`bash scripts/check-module-invariants.sh --no-build` and read C11's denominator, not just its
PASS/FAIL.

Concurrent-dispatch caveat: a foreign uncommitted modification or a foreign commit observed at any
point is a STOP-and-report condition, after checking `git log` to confirm the work is not this
task's own — never a thing to revert past.
