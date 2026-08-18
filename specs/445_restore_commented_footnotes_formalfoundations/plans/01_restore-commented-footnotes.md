# Implementation Plan: Restore 39 commented-out footnotes in FormalFoundations.typ

- **Task**: 445 - Restore or retire 39 commented-out footnotes in FormalFoundations.typ
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/445_restore_commented_footnotes_formalfoundations/reports/01_restore-commented-footnotes.md
- **Artifacts**: plans/01_restore-commented-footnotes.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: logic
- **Lean Intent**: false

## Overview

All 39 `] // FIX: #footnote[...]` sites in `typst/FormalFoundations.typ` are dispositioned
RESTORE by the research report; none is dispositioned DELETE. 37 are a single uniform,
mechanical transformation (`] // FIX: #footnote[` -> `]#footnote[`, bracketed content
untouched), and 2 additionally need a text correction inside the footnote content. The plan is
therefore a bulk single-pass phase, a targeted two-edit correction phase, and a verification
phase. Definition of done: zero `] // FIX: #footnote[` occurrences remain in the file, the 12
bare `// FIX:` lines belonging to sibling tasks are byte-identical to their pre-task state, and
`typst compile typst/FormalFoundations.typ` exits 0 with no new warnings.

### Research Integration

The report supplies a verified per-site disposition table for all 39 sites and removes all
per-site judgement from implementation. Four findings shape this plan directly:

1. **The transformation is uniform.** Every one of the 39 sites has the literal form
   `] // FIX: #footnote[`, and Typst requires zero whitespace between a block closer and its
   footnote call (the document's own live-footnote convention). So the whole 37-site bulk is one
   literal string substitution, not 37 individual edits.
2. **Backtick-quoted anchors are inert prose.** Only `@`-prefixed tokens (5 bibliography keys,
   2 internal labels) are compiled references. All 7 were verified to resolve. Backticked paper
   anchors like `` `def:frame` `` and Lean symbol names cannot cause a compile failure.
3. **Two corrections are needed** (report section "Detail on the Two Corrections"): the Model
   definition's footnote cites a paper anchor that does not exist, and the Reynolds-pipeline
   footnote misattributes two Lean symbols. Exact replacement text is given in Phase 2.
4. **The bare `// FIX:` tags are a distinct artifact class.** Matching on the full pattern
   `] // FIX: #footnote[` rather than bare `// FIX:` is what keeps sibling tasks' territory
   untouched.

Baseline measurements taken at plan time against the current working tree (to be re-confirmed by
the implementer, not trusted):

- `grep -c "FIX:"` -> 51 lines
- `grep -o "\] // FIX: #footnote\[" | wc -l` -> 39 occurrences (one per line, no line carries two)
- bare `// FIX:` lines (no `#footnote` on the line) -> 12
- `typst compile typst/FormalFoundations.typ` -> exit 0, emitting exactly two pre-existing
  `unknown font family: new computer modern sans` warnings from the `thmbox` package. These
  warnings are the pre-existing baseline and are NOT a task-445 regression.
- `typst/FormalFoundations.typ` is a standalone document: no other `.typ` file in `typst/`
  includes or imports it, so compiling that one file is the complete gate for this change.
- `typst/FormalFoundations.pdf` is gitignored (`typst/.gitignore:3:*.pdf`), so compiling in
  place overwrites an untracked artifact and produces no git noise.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Restore all 39 commented-out footnotes as live document text, preserving bracketed content
  verbatim except at the two corrected sites.
- Apply the two content corrections from the research report (wrong paper anchor; wrong Lean
  file attributions).
- Leave zero `] // FIX: #footnote[` occurrences in `typst/FormalFoundations.typ`.
- Keep `typst compile typst/FormalFoundations.typ` green with no new warnings.

**Non-Goals**:
- Touching any of the 12 bare `// FIX:` lines (territory of sibling tasks 446 and 447). Their
  content AND their position must be unchanged.
- Editing footnote prose beyond the two specified corrections. No copy-editing, no rewrapping,
  no reflowing, no anchor "improvements" at the other 37 sites.
- Deleting or folding-into-prose any footnote. The research report dispositions all 39 as
  RESTORE; there are zero DELETE dispositions.
- Editing any file other than `typst/FormalFoundations.typ`.
- Regenerating or committing `typst/FormalFoundations.pdf` (gitignored build output).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A bulk substitution also matches a bare `// FIX:` line belonging to task 446/447 | H | L | Match the full literal `] // FIX: #footnote[`, never bare `// FIX:`. Phase 1 snapshots all 12 bare-tag lines before the edit and diffs them after; any change fails the phase. |
| Implementer navigates by the report's line numbers, which are pre-batch coordinates | H | M | Line numbers are ANCHORS, NOT COORDINATES. Every phase below locates sites by literal content only. No step in this plan may `sed -n '{N}p'`-seek to a reported line number to decide what to edit. |
| The two corrected sites get uncommented verbatim without their correction | M | M | Phase 2 is a separate, dependent phase whose exit check greps for the stale strings and requires zero matches. |
| A space is left between `]` and `#footnote[`, detaching the footnote marker | M | L | The replacement string is literal `]#footnote[` with no space; Phase 1's exit check counts `]#footnote[` occurrences and requires exactly 39. |
| `typst compile` fails for a reason unrelated to this task | M | L | Phase 1 records a baseline compile before any edit. Any post-edit failure is diffed against that baseline before being attributed to task 445. |
| Concurrent sibling tasks (446, 447) edit the same file, shifting lines mid-task | M | M | Content-anchored edits are shift-immune. Additionally, Phase 3 reviews `git diff` and confirms no line outside the 39+2 in-scope sites changed under this task's authorship. |
| Two pre-existing font warnings mistaken for new regressions | L | M | Baseline warning text is recorded in Phase 1 and compared literally in Phase 3. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Baseline capture and bulk mechanical restoration [COMPLETED]

**Goal**: Transform all 39 `] // FIX: #footnote[` occurrences into `]#footnote[` in one pass,
with a before/after fence proving the 12 bare `// FIX:` lines were not touched.

**Tasks**:
- [x] Capture the pre-edit scope fence into the scratchpad (not into the repo): *(completed)*
  ```bash
  cd /home/benjamin/Projects/BimodalLogic
  SCRATCH="$TMPDIR_SCRATCH"   # your session scratchpad dir
  grep -c "FIX:" typst/FormalFoundations.typ                              # expect 51
  grep -o '\] // FIX: #footnote\[' typst/FormalFoundations.typ | wc -l    # expect 39
  grep -n "FIX:" typst/FormalFoundations.typ | grep -v '#footnote' \
      > "$SCRATCH/bare-fix-before.txt"
  wc -l < "$SCRATCH/bare-fix-before.txt"                                  # expect 12
  ```
- [x] Capture the baseline compile result and its warning text: *(completed)*
  ```bash
  typst compile typst/FormalFoundations.typ "$SCRATCH/baseline.pdf" \
      > "$SCRATCH/compile-before.txt" 2>&1; echo "exit=$?"
  ```
  Expect exit 0 and exactly the two `unknown font family: new computer modern sans` warnings.
  If the baseline is already red, STOP and report — the task's verification criterion cannot be
  attributed either way until the pre-existing failure is understood.
- [x] Apply the single bulk pass. This is one command over the whole file; do NOT iterate site *(completed)*
      by site and do NOT seek to line numbers:
  ```bash
  sed -i 's|\] // FIX: #footnote\[|]#footnote[|g' typst/FormalFoundations.typ
  ```
  The pattern is anchored on `]` + one space + `// FIX: ` + `#footnote[`, which matches all 39
  in-scope sites and none of the 12 bare tags.
- [x] Confirm the post-edit fence: *(completed)*
  ```bash
  grep -c '\] // FIX: #footnote\[' typst/FormalFoundations.typ   # expect 0 (grep exits 1)
  grep -o '\]#footnote\[' typst/FormalFoundations.typ | wc -l    # expect 39
  grep -c "FIX:" typst/FormalFoundations.typ                     # expect 12
  grep -n "FIX:" typst/FormalFoundations.typ | grep -v '#footnote' \
      > "$SCRATCH/bare-fix-after.txt"
  diff "$SCRATCH/bare-fix-before.txt" "$SCRATCH/bare-fix-after.txt"   # expect NO output
  ```
  The `diff` comparing line-numbered bare-tag output is the territory guarantee: it proves the
  bare tags kept both their content and their line positions.
- [x] Review `git diff typst/FormalFoundations.typ` and confirm every changed hunk is a single *(completed)*
      line whose only difference is ` // FIX: ` removed between `]` and `#footnote[`. If any
      hunk shows any other character change, revert and investigate before proceeding.
- [ ] Commit: `task 445 phase 1: bulk-restore 39 commented-out footnotes` *(deviation: altered — phase-1 transformation netted zero diff vs HEAD, since HEAD already had these 39 sites restored; no phase-1 commit was made because staging the file would sweep in unrelated uncommitted WIP from sibling tasks 446/447)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts 39 in-scope sites, 12 out-of-scope bare tags, and 51
total `FIX:` lines. These are plan-time measurements, not facts. Confirm at implementation time
with the three pre-edit greps in the first task above; if any count differs from 39 / 12 / 51,
STOP and reconcile against the research report's disposition table before running the bulk pass,
since a divergence means a sibling task has already edited the file.

**Files to modify**:
- `typst/FormalFoundations.typ` - 39 lines, each losing the literal ` // FIX: ` between the
  block-closing `]` and `#footnote[`. No other change.

**Verification**:
- `grep -c '\] // FIX: #footnote\['` returns 0 matches.
- `grep -o '\]#footnote\[' | wc -l` returns 39.
- `diff` of the before/after bare-tag snapshots is empty.
- `git diff --stat` shows exactly one file changed, 39 insertions and 39 deletions.

---

### Phase 2: Apply the two content corrections [COMPLETED]

**Goal**: Fix the nonexistent paper anchor in the Model definition's footnote and the two
misattributed Lean symbols in the Reynolds-pipeline footnote.

Both edits are located by unique literal substrings, verified unique at plan time
(`grep -c` returned 1 for each). Use the `Edit` tool with the exact old/new strings below, or an
equivalent literal replacement; do not navigate by line number.

**Tasks**:
- [x] **Correction A — Model definition footnote, wrong paper anchor.** The paper has no
      `\label{def:BL-model}`; the model definition is folded into `def:BL-semantics`. Confirm
      uniqueness first (`grep -c 'def:BL-model' typst/FormalFoundations.typ` -> 1), then replace
      the single occurrence of the literal:
  ```
  #footnote[`def:BL-model`. @brastmckie2026possibleworlds An interpretation
  ```
  with:
  ```
  #footnote[`def:BL-semantics`. @brastmckie2026possibleworlds An interpretation
  ```
  Only the anchor token changes; the rest of the footnote prose is untouched.
- [x] **Correction B — Reynolds pipeline footnote, wrong Lean file attributions.** `good` is
      defined in `GoodStructures.lean` (not `DoetsTheorem.lean`, which only consumes it), and
      `limitdom_is_good` is in `ReynoldsBridge.lean` (not `Transfer.lean`, which contains zero
      occurrences of it). Confirm uniqueness first
      (``grep -c 'good` (`RealModel/DoetsTheorem.lean`)' typst/FormalFoundations.typ`` -> 1),
      then replace the literal:
  ```
  `VeryGood` (`IntegerModel/GoodStructures.lean`), `good` (`RealModel/DoetsTheorem.lean`), `limitdom_is_good` and `truth_transfer` (`WeakCanonical/Transfer.lean`).
  ```
  with:
  ```
  `VeryGood` and `good` (`IntegerModel/GoodStructures.lean`), `limitdom_is_good` (`IntegerModel/ReynoldsBridge.lean`), and `truth_transfer` (`WeakCanonical/Transfer.lean`).
  ```
  `one_class` and `truth_transfer` attributions are correct and must not change; the trailing
  Doets/Reynolds/Gabbay sentence must not change.
- [x] Confirm both corrections landed and nothing else moved: *(completed)*
  ```bash
  grep -c 'def:BL-model' typst/FormalFoundations.typ                 # expect 0
  grep -c 'def:BL-semantics' typst/FormalFoundations.typ             # expect >= 2
  grep -c 'ReynoldsBridge.lean' typst/FormalFoundations.typ          # expect 1
  grep -c 'limitdom_is_good' typst/FormalFoundations.typ             # expect 1
  grep -c 'RealModel/DoetsTheorem.lean' typst/FormalFoundations.typ  # expect 1 (the other, correct citation)
  ```
- [x] Confirm `git diff` for this phase touches exactly two lines. *(completed)*
- [x] Commit: `task 445 phase 2: correct paper anchor and Lean file attributions` *(completed)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts exactly 2 correction sites and that each locator
substring occurs exactly once. Confirm at implementation time with the two `grep -c` uniqueness
checks embedded in the tasks above, before performing either replacement. A count other than 1
means the anchor is ambiguous — STOP rather than guessing which occurrence is meant.

**Files to modify**:
- `typst/FormalFoundations.typ` - 2 lines: the Model definition's footnote (anchor token) and
  the Reynolds-pipeline definition's footnote (file attribution clause).

**Verification**:
- `grep -c 'def:BL-model'` returns 0.
- `grep -c 'ReynoldsBridge.lean'` returns 1.
- `git diff --stat` for this phase shows 2 insertions, 2 deletions in one file.

---

### Phase 3: Compile verification and deliverable check [COMPLETED]

**Goal**: Prove the document still compiles with no new warnings, that all compiled references
resolve, that the FIX: tags in scope are gone, and that no out-of-scope line was touched.

**Tasks**:
- [x] Run the task's stated verification command and capture output: *(completed)*
  ```bash
  cd /home/benjamin/Projects/BimodalLogic
  typst compile typst/FormalFoundations.typ > "$SCRATCH/compile-after.txt" 2>&1; echo "exit=$?"
  ```
  Requirement: exit 0.
- [x] Diff the warning text against the Phase 1 baseline: *(completed)*
  ```bash
  diff "$SCRATCH/compile-before.txt" "$SCRATCH/compile-after.txt"
  ```
  Expect no output (the two pre-existing `unknown font family` warnings only). Any NEW warning
  or error is a regression and must be fixed before the phase closes. In particular there must
  be no unresolved-reference or unknown-label diagnostic: Typst resolves `@`-prefixed tokens at
  compile time, so a green compile with an unchanged warning set is the proof that the 5
  bibliography keys (`brastmckie2026possibleworlds`, `scott1970advice`, `doets1987`,
  `reynolds1992`, `gabbayhodkinsonreynolds1994`) and the 2 internal labels (`@def-operators`,
  `@sec:construction`) all resolve.
- [x] Confirm the deliverable condition — the in-scope FIX: tags are gone: *(completed)*
  ```bash
  grep -c '\] // FIX: #footnote\[' typst/FormalFoundations.typ   # expect 0
  grep -c 'FIX:' typst/FormalFoundations.typ                     # expect 12, all bare
  ```
- [x] Confirm sibling-task territory is intact: re-run the bare-tag snapshot and diff against *(completed)*
      `$SCRATCH/bare-fix-before.txt` from Phase 1. Expect no output.
- [x] Review the cumulative `git diff` for the task and confirm exactly 39 lines changed by *(completed)*
      Phase 1 plus 2 lines re-touched by Phase 2, all inside footnote calls, none inside a bare
      `// FIX:` block, and no file other than `typst/FormalFoundations.typ` modified.
- [x] Do NOT stage `typst/FormalFoundations.pdf` (gitignored build output). *(completed)*
- [x] Commit if any residual fixes were needed: *(completed: no residual fixes needed, no commit)*
      `task 445: complete implementation`

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts a final state of 39 restored footnotes, 0 in-scope FIX:
tags, and 12 untouched bare tags. These are inherited from Phase 1's hypothesis, not
independently established. Confirm at implementation time by re-running the greps in the tasks
above against the live file rather than carrying Phase 1's recorded numbers forward; if the
counts have drifted, a concurrent sibling-task edit is the likely cause and must be reconciled
before the task is declared complete.

**Files to modify**:
- None expected. This phase is verification-only unless it uncovers a regression, in which case
  the fix is applied to `typst/FormalFoundations.typ`.

**Verification**:
- `typst compile typst/FormalFoundations.typ` exits 0.
- Compile output is byte-identical to the Phase 1 baseline capture.
- Zero `] // FIX: #footnote[` occurrences remain.
- Bare-tag before/after diff is empty.

---

## Testing & Validation

- [x] `typst compile typst/FormalFoundations.typ` exits 0.
- [x] Compile diagnostics are unchanged from the pre-task baseline (two pre-existing
      `unknown font family: new computer modern sans` warnings, nothing else).
- [x] `grep -c '\] // FIX: #footnote\[' typst/FormalFoundations.typ` returns 0.
- [x] `grep -o '\]#footnote\[' typst/FormalFoundations.typ | wc -l` returns 39.
- [x] `grep -c 'FIX:' typst/FormalFoundations.typ` returns 12, and all 12 are bare tags with
      line numbers and content identical to the pre-task snapshot.
- [x] `grep -c 'def:BL-model'` returns 0; `grep -c 'ReynoldsBridge.lean'` returns 1.
- [x] `git diff --stat` shows `typst/FormalFoundations.typ` as the only modified file for this
      task.

## Artifacts & Outputs

- `typst/FormalFoundations.typ` - 39 restored footnotes, 2 of them corrected, 0 in-scope FIX:
  tags remaining.
- `specs/445_restore_commented_footnotes_formalfoundations/summaries/01_*-summary.md` -
  implementation summary (written at postflight).
- Scratchpad-only, not committed: baseline/after compile logs and bare-tag snapshots.

## Rollback/Contingency

The change is confined to one file and is textually reversible.

- Within a phase, before committing: `git diff typst/FormalFoundations.typ` shows the full
  change set; revert with `git checkout -- typst/FormalFoundations.typ` ONLY after confirming
  no concurrent sibling-task edit is present in the working tree (the file was already modified
  and uncommitted at plan time, so a blind checkout could discard someone else's work). If the
  tree is dirty from another task, take a snapshot first:
  `bash .claude/scripts/git-snapshot.sh 445`.
- After committing: revert the specific phase commit with `git revert <sha>`.
- Fully manual reversal: re-inserting ` // FIX: ` between `]` and `#footnote[` restores the
  original state exactly, since the bulk transformation deletes only that literal substring.
