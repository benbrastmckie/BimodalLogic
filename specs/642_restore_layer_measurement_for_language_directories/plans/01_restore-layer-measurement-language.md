# Implementation Plan: Task #642

- **Task**: 642 - Restore layer measurement for the language directories
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/642_restore_layer_measurement_for_language_directories/reports/01_restore-layer-measurement-language.md
- **Artifacts**: plans/01_restore-layer-measurement-language.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`FormalSystem/{Plus,Minus,Star}Language/` are absent from `LAYERS` in
`scripts/measure-refactor-partitions.py`, so `layer_of` returns `None` for their 33 modules and
the equality-asserted allowlist in `scripts/check-metalogic-cycles.sh` passes vacuously on an
empty set. This plan gives every file in the three directories a per-file sub-layer keyed on the
directory it occupied before the language-extension merge, makes `layer_of` raise for any
unmatched module under `FormalSystem/`, restores the allowlist to the measured 7 lines, adds a
named syntax-before-semantics assertion, negative-tests every failure direction by hand on the
real files, and brings the seven document groups that record the stale measurement back to the
measured order. Done means: `upward-edges` reports a non-empty measured set for the three
directories, no module under `FormalSystem/` has a `None` layer, the cycle script is green with a
7-line allowlist and still exactly 1 cycle, and each negative test was observed to fail.

### Research Integration

The research report (round 01) is integrated in full. Load-bearing findings:

- **No single per-directory layer is consistent.** Measured: L=0 gives 23 upward lines, L=1 gives
  9, L=2 gives 5, L=3 gives 3. The per-file sub-layer is a measured result, not a preference.
- **Three sub-layers, not two.** `MinusLanguage/Soundness.lean` came from
  `Metalogic/Conservativity/` and imports two `Metalogic` modules; it sits at layer 3.
- **Classification rule: pre-merge origin directory**, read from
  `git show -M --name-status e2b646c84`. 30 files: 13 at layer 0, 16 at layer 1, 1 at layer 3.
  The three sibling aggregators take a declared layer of 1.
- **Prototyped outcome**: exactly 7 upward lines, all
  `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.*`; the
  syntax-imports-semantics set is empty today.
- **Fail-loud needs two levels** (unknown top-level directory; unlisted file inside a language
  directory) and forces rows for `FormalSystem.MainResults` (4) and `FormalSystem.Version` (0),
  the only other `None` modules under `FormalSystem/`.
- **The stale measurement is recorded in seven document groups**, not the two the task names;
  `PUBLICATION_REFACTOR.md` Phase 5 carries a claim ("become ordinary downward edges") that the
  measurement refutes.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch.

## Goals & Non-Goals

**Goals**:
- Record the layering decision (per-file sub-layer, origin-keyed) and its measured reason, in the
  script beside the table and in `ORGANISATION.md` / `docs/ARCHITECTURE.md`.
- Extend `LAYERS` and `layer_of`; make `layer_of` raise a dedicated exception for any module under
  `FormalSystem/` that matches no row, returning `None` only for non-library modules and the bare
  root `FormalSystem`.
- Report stale per-file rows (a row whose file no longer exists) as a failure, so the table cannot
  drift in either direction.
- Re-derive the upward set by running the script and restore `ALLOWLIST` to what it measures.
- Add a third, named assertion: no language-directory syntax module imports a semantics module,
  with a non-vacuity guard.
- Negative-test by hand: allowlist surplus, allowlist shortfall, the new assertion's failure,
  both fail-loud levels, and the stale-row report.
- Update all seven document groups plus the three aggregator docstrings to the measured order and
  remove the blind-spot note.

**Non-Goals**:
- Turning the 7 `AxiomDischarge -> Theorems` lines downward. They are recorded, not excused, and
  relocating them is separate work.
- Changing any layer number of the ten existing `LAYERS` rows.
- Wiring `check-metalogic-cycles.sh` into `check-module-invariants.sh` (deliberately standalone).
- Changing the `--check` Expressiveness gate or the other three measurements.
- Any proof, definition, import or namespace change in a `.lean` file. The only `.lean` edits are
  one docstring paragraph in each of the three language aggregators.

## Decisions

- **Per-file sub-layer over per-directory layer**, on the measured evidence above.
- **Origin directory over content judgement** as the classification rule. A content judgement
  could place `AxiomDischarge` at layer 2 and empty the allowlist by assertion, which is the
  failure this task exists to undo reached by another route.
- **An explicit 30-row table over a filename-prefix heuristic.** The heuristic is right for 29 of
  30 files and would classify a new file silently.
- **The new assertion is kept although assertion B subsumes it.** Under the per-file scheme a
  syntax file importing a semantics file is already a SURPLUS line. The separate assertion exists
  so the failure message names the invariant, and so it survives a future allowlist entry that
  would otherwise absorb such a line.
- **Scope of "semantics module" in the new assertion**: any layer-1 file in any of the three
  language directories, plus anything under `FormalSystem.Semantics`. This is the pre-merge
  invariant ("nothing under the language's syntax directory imports anything from `Semantics/`")
  restated at file level, and it also catches the cross-language case.
- **Aggregator docstrings are included**, against the research report's build-cost caution. Each
  says "no mechanical check enforces it", which this task makes false. The measured rebuild cost
  is small: the reverse closures of the three aggregators are 30, 24 and 18 modules (about 8,500
  lines at most). The three `.lean` aggregators are outside the task's recorded `file_scope`,
  which is descriptive; stage them by explicit path like every other file.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| After `layer_of` is extended but before `ALLOWLIST` is restored, `check-metalogic-cycles.sh` is red (7 surplus) and CI runs it | H | H | Phase 1 is a declared `atomic-batch` over both scripts; nothing is committed until both are green together |
| A raising `layer_of` turns CI red on any new top-level directory or language-directory file | M | M | Intended behaviour. The exception message names the module and the exact table that needs a row; assertion B prints it as a `FAIL` line rather than a traceback |
| Negative-test edits to real `.lean` files are seen by a concurrent `lake build` from another agent in the shared tree (the surplus edit is an import cycle) | M | M | Each test is one shell invocation that saves a copy with `cp -p` to the scratchpad, edits, runs the script, and restores unconditionally; the dirty window is seconds. Confirm with `git diff --quiet -- <path>` afterwards |
| `git checkout -- <path>` is blocked by the destructive-git guard on a dirty tree | L | H | Never used. Reverts are by restoring the saved copy; untracked scratch files are removed with `rm`, never `git clean` |
| The per-file table drifts from the tree | M | L | Missing row raises; surplus row is reported as stale and fails assertion B. Both verified empty in Phase 1 and negative-tested in Phase 3 |
| New prose names a module or path that does not resolve, tripping `check-module-invariants.sh` C5/C12; or cites a task number, tripping C9 and the write-time gate | M | M | Name only real paths; cite durable anchors ("the language-extension merge", "PUBLICATION_REFACTOR.md Phase 5"). Run the harness and `check-task-references.sh` in Phases 4-6 |
| Editing the three language READMEs makes their `Last verified` stamp predate the directory's last commit (`readme-lint.sh` Check 4) | L | H | Bump each stamp to the commit date in the same edit |
| Assertion-order bug: checking `is_sibling_aggregator` before `layer_of` would skip the raise for an aggregator with no row | L | L | Keep `layer_of(src)` evaluated first for every library module in both consumers; Phase 1 verification loops over every module explicitly |
| Shared working tree: sibling tasks have uncommitted edits | M | H | Re-read each file immediately before editing; stage explicit file lists only, never a directory or glob pathspec |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Per-file layer table, fail-loud `layer_of`, restored allowlist [COMPLETED]

**Goal**: Make the three language directories measurable, make an unmatched library module an
error, and bring the allowlist back to the measured set, as one green change across both scripts.

**Tasks**:
- [x] Re-derive the origin table from `git show -M --name-status --format='%h %s' e2b646c84` and
      check it against the live directory listings (do not copy the table from the report). *(completed: 30 renames in e2b646c84 match the 30 live files; 13 at layer 0, 16 at layer 1, 1 at layer 3)*
- [x] In `scripts/measure-refactor-partitions.py`: add `"Version": 0` and `"MainResults": 4` to
      `LAYERS`, and rewrite the comment above it (it currently says a top-level module "has no
      layer and never contributes an edge"). *(completed)*
- [x] Add the per-file table, keyed by language directory then by file leaf (30 rows), and a
      declared aggregator layer of 1 for the three sibling aggregators. Put the decision record in
      the comment above it: per-file over per-directory with the measured L=0/1/2/3 figures,
      origin directory as the rule with the merge commit named, `Soundness` at 3 and why a prefix
      heuristic must not replace the table. *(completed)*
- [x] Add a dedicated exception class and rewrite `layer_of`: return `None` only when the first
      component is not `FormalSystem` or the module is the bare root; otherwise return the matched
      row or raise, with a message naming the module and which table lacks the row (top-level
      `LAYERS` vs. the per-file table for that language directory). A module nested deeper than
      one level inside a language directory has no row and must raise too. *(completed)*
- [x] Add a stale-row function (table rows whose module is not in the graph) and surface its
      result in `measure_upward_edges`' return value and in `print_upward_edges`. *(completed)*
- [x] Keep the `if ls is None: continue` guards; they now fire only for non-library modules.
      Catch the new exception in `main` and exit non-zero with the message on stderr. *(completed)*
- [x] Run `python3 scripts/measure-refactor-partitions.py upward-edges` and restore `ALLOWLIST` in
      `scripts/check-metalogic-cycles.sh` from that output. Expect 7 lines, all
      `FormalSystem.MinusLanguage.AxiomDischarge -> FormalSystem.Theorems.*`. **Any other line is
      a finding: stop, report it in the summary and the handoff, and do not allowlist it.** *(completed: measured exactly 7 lines, all AxiomDischarge -> Theorems; no other line)*
- [x] In assertion B: fail on a non-empty stale-row set, and print an unlayered-module error as a
      `FAIL` line naming the module and table instead of a traceback. Keep `layer_of(src)`
      evaluated before the aggregator exclusion. *(completed)*
- [x] Rewrite the script docstring's "Measured on the tree" `upward-edges` block from fresh output
      and delete its CAVEAT paragraph. Regenerate every figure in that block by running the
      script; type none of them. *(completed: upward-edges block only; the other three blocks' figures were already stale before this task and are untouched (non-goal))*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: The per-file table has 30 rows (Minus 5+4+1, Plus 4+7, Star 4+5), the
complete `None` set under `FormalSystem/` today is those 30 files plus 3 aggregators plus
`MainResults` and `Version`, and the measured upward set is exactly 7 lines. Confirm the first by
comparing the table against `ls FormalSystem/{Minus,Plus,Star}Language/*.lean` and the rename
table; the second by looping `layer_of` over every `FormalSystem.*` module in `ImportGraph()` on
the unmodified script before editing; the third by the `upward-edges` run. A different count is a
finding to report, not a number to adjust.

**Files to modify**:
- `scripts/measure-refactor-partitions.py` - `LAYERS` rows, per-file table, exception,
  `layer_of`, stale-row report, `main` error path, module docstring
- `scripts/check-metalogic-cycles.sh` - `ALLOWLIST`, stale-row and unlayered-module failure
  branches in assertion B (header rewrite is Phase 2)

**Verification**:
- `python3 scripts/measure-refactor-partitions.py upward-edges` reports 7 lines under a
  `MinusLanguage -> Theorems` class and no stale rows.
- A one-off loop over every `FormalSystem.*` module in `ImportGraph()` shows `layer_of` neither
  raises nor returns `None`; `layer_of` returns `None` for `Mathlib.*`, `BimodalTest.*` and the
  root `FormalSystem`.
- `python3 scripts/measure-refactor-partitions.py all`, `--json all` and `--check` all still
  succeed, with the other three measurements unchanged.
- `bash scripts/check-metalogic-cycles.sh` exits 0: exactly 1 cycle, and "upward import set is
  exactly the recorded 7 line(s)".
- One commit containing both scripts, staged by explicit path.

---

### Phase 2: Named syntax-before-semantics assertion and header rewrite [NOT STARTED]

**Goal**: Add the assertion that replaces the directory boundary the merge removed, and make the
script's header describe what the script now does.

**Tasks**:
- [ ] Add assertion C as its own heredoc block (or a clearly separated section of B's), with its
      own status variable feeding the single exit code and its own `PASS`/`FAIL` line. Reuse
      `layer_of` and the per-file table loaded by path; do not add a second copy of the table.
- [ ] Define the two sets from the table: syntax modules are the layer-0 files of the three
      language directories; semantics modules are their layer-1 files plus every module under
      `FormalSystem.Semantics`. A violation is any import line from the first set into the second.
      Aggregators are excluded as sources, as in A and B.
- [ ] Add a non-vacuity guard in the manner of the `--check` degenerate-partition branch: fail if
      either language-directory set is empty, printing both sizes.
- [ ] Print each violation as `SYNTAX->SEMANTICS  src -> tgt`; on failure, name the invariant and
      say what to do (move the declaration to a semantics file, or reclassify the file in the
      per-file table and `ORGANISATION.md` together).
- [ ] Rewrite the header: three assertions behind one exit code; the allowlist holds 7 lines under
      the new path; delete the "allowlist is now EMPTY" passage and the "every import ... is now
      invisible" note; describe the per-file layering, the fail-loud lookup and the stale-row
      failure; update the exit-code paragraph. Update assertion B's shortfall hint, which refers
      to the list having been emptied.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The syntax set has 13 modules, the language-directory semantics set has 16,
and the violation set is empty today. Confirm from the `PASS` line, which must print both sizes.

**Files to modify**:
- `scripts/check-metalogic-cycles.sh` - assertion C, exit-code wiring, header, shortfall hint

**Verification**:
- `bash scripts/check-metalogic-cycles.sh` exits 0 and prints three `PASS` lines; the third
  states the two set sizes.
- `bash -n scripts/check-metalogic-cycles.sh` is clean.
- The header contains no sentence describing an empty allowlist or an unmeasured directory.

---

### Phase 3: Hand negative tests on the real tree [NOT STARTED]

**Goal**: Observe every failure direction through the real scripts on real file edits, and leave
the tree exactly as it was.

**Tasks**:
- [ ] Precondition: Phases 1-2 committed, and `git diff --quiet` holds for every file a test will
      touch. Run each test as one shell invocation: `cp -p` the file to the scratchpad, edit, run
      `bash scripts/check-metalogic-cycles.sh` (capturing output and exit code), restore the copy
      unconditionally, then `git diff --quiet -- <path>`.
- [ ] **Surplus + assertion C**: add `import FormalSystem.PlusLanguage.PlusTruth` to the leading
      import block of `FormalSystem/PlusLanguage/Formula.lean`. Expect a `SURPLUS` line from B, a
      `SYNTAX->SEMANTICS` line and `FAIL` from C, exit 1. (The line is an import cycle in Lean;
      immaterial, since nothing is built while it is in place.)
- [ ] **Shortfall**: delete `import FormalSystem.Theorems.TemporalDerived` from
      `FormalSystem/MinusLanguage/AxiomDischarge.lean`. Expect a `SHORTFALL` line, exit 1, and C
      still passing.
- [ ] **Fail-loud, file level**: create an empty `FormalSystem/PlusLanguage/Scratch.lean`; run
      both scripts; expect the error to name the module and the per-file table. Remove with `rm`.
- [ ] **Fail-loud, directory level**: create `FormalSystem/ScratchDir/Thing.lean`; expect the
      error to name `LAYERS`. Remove with `rm -r`.
- [ ] **Stale row**: add one bogus row to the per-file table; expect the stale-row failure; restore
      the saved copy and confirm `git diff --quiet -- scripts/measure-refactor-partitions.py`.
- [ ] Re-run `bash scripts/check-metalogic-cycles.sh` on the restored tree: exit 0, and
      `git status --short` shows no path from this phase.
- [ ] Record each test's command, the observed output lines and the exit code for the
      implementation summary. If a test does not fail as expected, that is a defect in Phase 1 or
      2: fix it there, then repeat the whole phase.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- None persistently. Temporarily edited and restored: `FormalSystem/PlusLanguage/Formula.lean`,
  `FormalSystem/MinusLanguage/AxiomDischarge.lean`, `scripts/measure-refactor-partitions.py`;
  temporarily created and removed: `FormalSystem/PlusLanguage/Scratch.lean`,
  `FormalSystem/ScratchDir/Thing.lean`.

**Verification**:
- Five observed failures, each with exit code 1 (or the measurement script's non-zero exit) and
  the expected named line.
- `git status --short` lists nothing from this phase; the cycle script is green again.
- The observations are written down for the summary. This phase produces no commit of its own
  unless a defect fix in the scripts was needed.

---

### Phase 4: Core documents to the measured order [NOT STARTED]

**Goal**: Replace every statement of the stale measurement in the repository-level documents with
the measured one, and remove the blind-spot note.

**Tasks**:
- [ ] `ORGANISATION.md`: replace "The measured upward set is now empty" with the 7 measured lines
      under their new path; replace the whole "extension-language directories sit outside this
      table" subsection with the per-file layering, the decision and its measured reason (the
      L=0/1/2/3 figures), the origin rule and the merge commit; add the per-file rows,
      `MainResults` and `Version` to the layer table; state the fail-loud and stale-row
      behaviour; delete "No harness check catches a regression here; this paragraph is the only
      record."
- [ ] `docs/ARCHITECTURE.md`: redraw the "Outside the stack / unmeasured" box in the diagram so
      the three directories appear spanning layers 0, 1 and 3; rewrite "The upward set is empty —
      and what that now hides"; fix the `Syntax/` table row that says the family is "outside the
      layer table". Leave "Verifying this page" (already says 7) and check it is now true.
- [ ] `docs/development/MODULE_INVARIANTS.md`: "two independent assertions" becomes three;
      describe assertion C, the fail-loud lookup and the stale-row failure.
- [ ] `docs/development/PUBLICATION_REFACTOR.md`: correct the measurement-table row "0 since Phase
      5 landed"; correct Phase 5's "become ordinary downward edges" bullet and the sentence that
      says moving `AxiomDischarge.lean` empties the allowlist. State what was measured; keep the
      historical record of what the document once claimed only where that document's own
      convention does so.
- [ ] `scripts/README.md`: the `check-metalogic-cycles.sh` row becomes three assertions; confirm
      "7-line allowlist" is now accurate.
- [ ] `README.md`: the Architecture link text "its two upward edges" matches neither 0 nor 7;
      replace it with wording that does not embed a count, or with the measured one.
- [ ] Grep all six files afterwards for `unmeasured`, `now empty`, `outside this table`,
      `returns None`, `invisible` to confirm no stale statement survives.

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: Six files carry the stale measurement at repository level. Confirm with a
repository-wide grep (excluding `specs/` and `Boneyard/`) for the phrases in the last task; a
seventh hit is in scope for this phase.

**Files to modify**:
- `ORGANISATION.md` - layer table, upward-set paragraph, language-directory subsection
- `docs/ARCHITECTURE.md` - diagram box, upward-set section, `Syntax/` row
- `docs/development/MODULE_INVARIANTS.md` - sibling-scripts section
- `docs/development/PUBLICATION_REFACTOR.md` - measurement row, Phase 5 bullets
- `scripts/README.md` - one table row
- `README.md` - one link description

**Verification**:
- Every count written into a document matches fresh script output.
- `bash .claude/scripts/check-task-references.sh` reports nothing new.
- Diff read-through: every hunk is prose; no code block command was altered except to match the
  scripts' real output.
- C5/C12 path resolution is deferred to Phase 6's harness run (it needs `lake build`).

---

### Phase 5: Language READMEs and aggregator docstrings [NOT STARTED]

**Goal**: Remove "No mechanical check enforces it" from the six places that say it, and file
`Soundness.lean` where the measurement puts it.

**Tasks**:
- [ ] `FormalSystem/MinusLanguage/README.md`, `FormalSystem/PlusLanguage/README.md`,
      `FormalSystem/StarLanguage/README.md`: replace the "No mechanical check enforces it"
      sentence with the check that now does (`scripts/check-metalogic-cycles.sh`, the
      syntax-before-semantics assertion, and the per-file table in
      `scripts/measure-refactor-partitions.py`); note that a new file in the directory needs a
      row. Bump each `Last verified` stamp to the commit date.
- [ ] `FormalSystem/MinusLanguage/README.md`: move `Soundness.lean` out of the semantic-modules
      table into its own metalogic entry (layer 3, by origin and by its two `Metalogic` imports).
      It appears in two tables; fix both consistently.
- [ ] `FormalSystem/MinusLanguage.lean`, `FormalSystem/PlusLanguage.lean`,
      `FormalSystem/StarLanguage.lean`: in the module docstring, replace "no mechanical check
      enforces it" with one sentence naming the script. Docstring text only; no import, no
      declaration, nothing outside the `/-! ... -/` block.
- [ ] `lake build FormalSystem.MinusLanguage FormalSystem.PlusLanguage FormalSystem.StarLanguage`.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: The sentence occurs exactly six times (three READMEs, three aggregators),
and `Soundness.lean` is listed in two tables of the Minus README. Confirm with
`grep -rn -i "no mechanical check" FormalSystem/` and `grep -n "Soundness.lean"
FormalSystem/MinusLanguage/README.md`.

**Files to modify**:
- `FormalSystem/MinusLanguage/README.md` - invariant sentence, `Soundness.lean` placement, stamp
- `FormalSystem/PlusLanguage/README.md` - invariant sentence, stamp
- `FormalSystem/StarLanguage/README.md` - invariant sentence, stamp
- `FormalSystem/MinusLanguage.lean` - one docstring sentence
- `FormalSystem/PlusLanguage.lean` - one docstring sentence
- `FormalSystem/StarLanguage.lean` - one docstring sentence

**Verification**:
- `grep -rn -i "no mechanical check" FormalSystem/` returns nothing.
- `git diff` on the three `.lean` files shows hunks only inside the module docstring.
- The three-module `lake build` exits 0.
- `bash scripts/readme-lint.sh` shows no `STALE DATE` or broken reference for the three READMEs.

---

### Phase 6: Whole-gate re-verification [NOT STARTED]

**Goal**: Run the full gate set on the finished tree and check each acceptance criterion by
command, not by reading.

**Tasks**:
- [ ] `lake build` (the aggregator docstring edits rebuild roughly 30 dependent modules).
- [ ] `bash scripts/check-module-invariants.sh` — in particular C5, C9 and C12 against the new
      prose, and C1.
- [ ] `bash scripts/check-metalogic-cycles.sh` — three `PASS` lines, exactly 1 cycle, 7-line
      allowlist.
- [ ] `python3 scripts/measure-refactor-partitions.py upward-edges` and `--check`.
- [ ] `bash scripts/readme-lint.sh`; `bash .claude/scripts/check-task-references.sh`;
      `python3 scripts/warning-budget.py` if the harness does not already run it.
- [ ] Re-run the no-`None` loop from Phase 1.
- [ ] Write down each acceptance criterion with the command and the observed line that satisfies
      it, for the summary. Fix forward any red gate in the phase that owns the file.

**Timing**: 0.25 hours (plus build time)

**Depends on**: 4, 5

**Verification Tier**: full

**Files to modify**:
- None expected; any fix lands in the owning file from Phases 1-5.

**Verification**:
- Every command above exits 0.
- The four acceptance criteria each have a recorded command and observed output.

## Testing & Validation

- [ ] `python3 scripts/measure-refactor-partitions.py upward-edges` reports a non-empty measured
      set for the three directories (7 lines, `MinusLanguage -> Theorems`) and no stale rows
- [ ] `layer_of` neither raises nor returns `None` for any module under `FormalSystem/`, and
      returns `None` for `Mathlib.*`, `BimodalTest.*` and the root `FormalSystem`
- [ ] `bash scripts/check-metalogic-cycles.sh` is green with a 7-line allowlist, exactly 1 cycle,
      and a third `PASS` line stating non-empty syntax and semantics sets
- [ ] Negative tests observed to fail: surplus, shortfall, syntax-imports-semantics, unlisted
      language-directory file, unknown top-level directory, stale row
- [ ] Tree restored after the negative tests (`git status --short` clean of those paths)
- [ ] `lake build`, `check-module-invariants.sh`, `readme-lint.sh`, `check-task-references.sh`
      all green
- [ ] No document still states an empty upward set or an unmeasured language directory

## Artifacts & Outputs

- `scripts/measure-refactor-partitions.py` - per-file layer table, fail-loud `layer_of`,
  stale-row report, rewritten docstring
- `scripts/check-metalogic-cycles.sh` - restored 7-line allowlist, third assertion, rewritten
  header
- `ORGANISATION.md`, `docs/ARCHITECTURE.md`, `docs/development/MODULE_INVARIANTS.md`,
  `docs/development/PUBLICATION_REFACTOR.md`, `scripts/README.md`, `README.md` - measured order
- `FormalSystem/{Minus,Plus,Star}Language/README.md` and the three aggregator docstrings
- `specs/642_restore_layer_measurement_for_language_directories/summaries/01_restore-layer-measurement-language-summary.md`
  - including the negative-test observations and any line measured beyond the expected 7

## Rollback/Contingency

Every phase lands as its own commit of explicitly staged files, so reverting is `git revert` of
the phase commits in reverse order; no phase changes a proof, an import or a namespace, so a
revert cannot break the build. Phase 1 must be reverted as a unit (both scripts), since either
half alone leaves the cycle script red. Phase 3 leaves nothing to revert by construction; if a
test is interrupted mid-edit, restore the saved `cp -p` copy from the scratchpad, remove any
scratch file with `rm`, and confirm with `git diff --quiet`. Do not discard uncommitted work to
reach a green gate: fix forward. If a genuine rollback of uncommitted work is ever needed, follow
the rollback rung of `.claude/context/contracts/recovery.md` rather than improvising.

If Phase 1 measures a line other than the expected 7, do not allowlist it and do not reclassify a
file to make it disappear. The research prototype measured exactly 7, so this is unexpected; if
it happens, the atomic batch cannot go green honestly. Do not commit a half that turns CI red:
take a durable non-reverting checkpoint (`bash .claude/scripts/git-snapshot.sh 642 --no-revert`),
mark Phase 1 `[BLOCKED]`, and report the exact line in the handoff so the decision — relocate the
import, or record it as a new allowlist entry with its reason — is made explicitly rather than
absorbed.
