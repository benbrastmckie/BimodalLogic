# Implementation Plan: Task #723

- **Task**: 723 - Ground the pinned:C14 claim on the three witness-family decidability rows of docs/theorem-index.md
- **Status**: [NOT STARTED]
- **Effort**: 1.25 hours
- **Dependencies**: Task 706 (declared `file_scope` collision on `scripts/check-module-invariants.sh` -- run in a cycle disjoint from 705/706)
- **Research Inputs**: specs/723_pin_witness_family_decidability_rows_c14_baseline/reports/01_c14-witness-family-pin.md
- **Artifacts**: plans/01_c14-witness-family-pin.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`docs/theorem-index.md` rows 151-153 carry a `pcq pinned:C14` cell for three witness-family
decidability declarations, but `scripts/check-module-invariants.sh` never names those three in the
C14 axiom-baseline pair -- the only hits are an unrelated C23 shadowing allowlist entry. Research
confirmed the gap is real and that the baseline route (not the row-correction alternative) is
correct: a live `#print axioms` probe returns exactly `[propext, Classical.choice, Quot.sound]` for
all three, matching what the rows already claim, and the `Decidability` namespace is already inside
C14's scope via the pre-existing `sound_of_isValid` entry. The fix appends three lines to each of
the two exact-string-equality heredocs (`C14_BASELINE` and `C14LEAN`), in identical order, plus a
non-task-referencing pointer comment for the as-yet-unlanded fourth declaration, and is validated
by a full `bash scripts/check-module-invariants.sh` run.

### Research Integration

Key findings carried into this plan:
- **Gap confirmed** (not a false alarm): the dispatch's own grep hits only `SHADOW_PAIR_ALLOW` at
  `scripts/check-module-invariants.sh:3465-3470` (C23, name-collision hygiene), never a C14
  `#print axioms` line or baseline entry.
- **Axiom values verified live**: all three declarations return exactly
  `[propext, Classical.choice, Quot.sound]` under `lake env lean` with the script's own
  line-rejoin `sed` filter applied, so the baseline text is known verbatim and needs no
  rediscovery.
- **C14 is exact string equality and a HARD STOP on mismatch** (script lines 2452, 2456-2457):
  appending to only one heredoc, or in a different relative order between the two, breaks the
  check rather than silently passing.
- **Insertion point**: end of both heredocs, after the `Independence.z1_validIn_iff_ztime` line
  (`C14_BASELINE` content ends line 2242 before the `C14BASE` terminator on 2243; `C14LEAN`
  content ends line 2446 before its terminator on 2447). No existing entry is reordered or
  weakened.
- **Fourth declaration has not landed**: `grep -rn --include='*.lean' 'Decidable (Derivable'
  FormalSystem/` returns zero declaration hits, so the fold-in is a pointer comment naming the
  declaration by its Lean signature, never by task number
  (`.claude/rules/no-task-references-in-deliverables.md` governs both touched files).
- **Downstream consumers are dynamic**: C21 (line 4166) and C36 (lines 6677-6696) parse the
  heredoc text at run time, so a 3-line baseline growth breaks neither. Only a descriptive,
  non-enforced count in the C21 comment block ("105 between them", line 4144) goes stale.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context, so no roadmap consultation
was performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Make the `pinned:C14` cell on `docs/theorem-index.md` rows 151-153 TRUE by adding the three
  declarations to the C14 baseline pair in `scripts/check-module-invariants.sh`.
- Keep `bash scripts/check-module-invariants.sh` passing on a full (`RUN_BUILD=1`) run, with C14
  green and C21/C23/C36 unregressed.
- Leave a durable, task-number-free pointer so the pending fourth declaration
  (`Decidable (Derivable FrameClass.ZTime [] φ)`) is a one-block copy to pin once it lands.

**Non-Goals**:
- No Lean source changes of any kind (hard constraint from the dispatch).
- No weakening, removal, reordering, or rewriting of any existing C14 baseline entry.
- No new `pinned:` cell on any `docs/theorem-index.md` row whose pin has not been verified to run
  -- in particular, no row and no baseline entry for the unlanded fourth declaration.
- No content change to the three affected `docs/theorem-index.md` rows: they already state the
  correct value, and the row-correction alternative outcome does not apply.
- Not pursuing the research report's suggested `context/project/lean4/patterns/c14-baseline-pin.md`
  context file (out of scope for this task).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Three lines land in only one heredoc, or in differing relative order | H | M | Phase 2 edits both heredocs as a single declared `atomic-batch` objective and diffs the two blocks side-by-side before any check run; the exact line text for both is fixed verbatim below |
| A `#`-prefixed comment is inserted INSIDE the `C14_BASELINE` heredoc | H | M | The heredoc body is compared verbatim against `lake env lean` output, so any literal line inside it breaks equality. The pointer comment goes in the shell comment block ABOVE line 2044 (`read -r -d '' C14_BASELINE <<'C14BASE'`), never inside either heredoc |
| Second edit applied at stale line numbers after the first insertion shifts them | M | H | Editing `C14_BASELINE` first shifts `C14LEAN`'s terminator from 2447 to 2450. Phase 2 anchors both edits on the unique text `Independence.z1_validIn_iff_ztime` rather than on line numbers |
| `--no-build` run mistaken for sufficient verification | M | M | `--no-build` skips the `#print axioms` half of C14 entirely (line 2464). Phase 2's gate is the full default-`RUN_BUILD=1` run; a `--no-build` run is acceptable only for Phase 3's comment-only edit |
| Concurrent writer on `scripts/check-module-invariants.sh` (task 706 `file_scope`) | H | L | Dispatch already schedules this away from 705/706; Phase 1 re-checks `git status --short scripts/check-module-invariants.sh` for foreign modifications before editing |
| Stale `.olean` cache yields misleading axiom output | M | L | The authoritative gate is the full `check-module-invariants.sh`, which runs `lake build` itself under C1, rather than a bare `lake env lean` probe |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel; this plan is strictly serial.

### Phase 1: Re-verify the gap and fix the anchors [NOT STARTED]

**Goal**: Independently re-confirm, against the live tree at implementation time, that the three
declarations are absent from the C14 pair and that the research report's insertion anchors still
hold -- or, if the re-verification shows the pin does run under a name both the grep and the review
missed, close the task with that finding instead of editing.

**Tasks**:
- [ ] Re-run the dispatch's exact grep:
      `grep -nE 'Compression\.|decidableValidZTime|validZTime_iff_noCertifiedCandidate|exists_witnessFamily_of_not_validZTime' scripts/check-module-invariants.sh`
- [ ] Confirm every hit is the C23 `SHADOW_PAIR_ALLOW` block and that no `#print axioms` line or
      baseline entry names any of the three.
- [ ] If and only if a real C14 pin is found under another name: STOP the edit path, record the
      false-alarm finding as the deliverable, and skip Phases 2-3 (the dispatch declares this a
      legitimate outcome, not a failure).
- [ ] Confirm `grep -n "C14BASE\|C14LEAN" scripts/check-module-invariants.sh` still reports the
      heredoc openers/terminators, and that the last content line of each block is the
      `Independence.z1_validIn_iff_ztime` entry / `#print axioms` directive.
- [ ] Run `git status --short scripts/check-module-invariants.sh docs/theorem-index.md` and confirm
      neither file carries a foreign in-flight modification (task 706 `file_scope` collision).

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that (a) the three names appear in
`scripts/check-module-invariants.sh` only inside the C23 `SHADOW_PAIR_ALLOW` block near lines
3465-3470, and (b) both heredocs still end with the `Independence.z1_validIn_iff_ztime` entry
(`C14_BASELINE` content line 2242, terminator 2243; `C14LEAN` content line 2446, terminator 2447).
Confirm by re-running the two greps above and reading the reported line ranges; if the line numbers
have shifted, use the `Independence.z1_validIn_iff_ztime` text as the anchor and record the new
numbers rather than trusting these.

**Files to modify**:
- None (read-only verification phase)

**Verification**:
- The grep output is reproduced in the phase notes, showing only C23 allowlist hits.
- Both heredoc anchors are located and their current line numbers recorded.
- `git status --short` shows no foreign edits to either target file.

---

### Phase 2: Append the three C14 baseline entries to both heredocs [NOT STARTED]

**Goal**: Add the three declarations to the C14 baseline pair, in identical order in both heredocs,
plus the pointer comment for the pending fourth declaration, and prove the result green with a full
`check-module-invariants.sh` run.

**Tasks**:
- [ ] Append to `C14_BASELINE`, immediately after the `Independence.z1_validIn_iff_ztime` line and
      before the `C14BASE` terminator, in exactly this order:
      - `'FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime' depends on axioms: [propext, Classical.choice, Quot.sound]`
      - `'FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate' depends on axioms: [propext, Classical.choice, Quot.sound]`
      - `'FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime' depends on axioms: [propext, Classical.choice, Quot.sound]`
- [ ] Append to `C14LEAN`, immediately after the matching `#print axioms
      FormalSystem.Metalogic.Independence.z1_validIn_iff_ztime` directive and before the `C14LEAN`
      terminator, in the identical order:
      - `#print axioms FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_validZTime`
      - `#print axioms FormalSystem.Metalogic.Decidability.validZTime_iff_noCertifiedCandidate`
      - `#print axioms FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime`
- [ ] Add the pointer comment as a new paragraph in the shell comment block ABOVE the
      `read -r -d '' C14_BASELINE <<'C14BASE'` line (currently line 2044) -- NOT inside either
      heredoc. It names the witness-family trailing block, states that a fourth sibling
      declaration, `Decidable (Derivable FrameClass.ZTime [] φ)` (the Z-time derivability corollary
      of `Compression.decidableValidZTime`), is expected to join this block once it lands in
      `FormalSystem/`, and that pinning it is a copy of this block's shape. No task number appears
      in the comment.
- [ ] Diff the two appended blocks against each other and confirm declaration order matches
      line-for-line (`git diff scripts/check-module-invariants.sh`).
- [ ] Run the authoritative gate: `bash scripts/check-module-invariants.sh` (default
      `RUN_BUILD=1`; do NOT substitute `--no-build`).
- [ ] Confirm C14 reports `pass` and that C21, C23 and C36 are unregressed in the same run output.
- [ ] Commit the single-file edit once green.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts exactly six new content lines (three per heredoc) plus one
comment paragraph, in one file, with zero existing lines modified. Confirm with
`git diff --stat scripts/check-module-invariants.sh` (expect one file, +~10/-0) and by reading
`git diff` to verify no existing baseline line appears on a `-` side.

**Files to modify**:
- `scripts/check-module-invariants.sh` - three lines appended to the `C14_BASELINE` heredoc, three
  matching `#print axioms` directives appended to the `C14LEAN` heredoc in the same order, and one
  pointer-comment paragraph added to the shell comment block above the `C14_BASELINE` opener.

**Verification**:
- `bash scripts/check-module-invariants.sh` (full, `RUN_BUILD=1`) exits 0 with C14 `pass`.
- The C14 note output includes all three new declarations.
- `git diff` shows additions only; no existing baseline entry is removed, reordered, or altered.
- Both appended blocks list the three declarations in the identical order.
- No `.lean` file appears in `git status --short`.

---

### Phase 3: Reconcile the adjacent descriptive count and confirm the doc rows [NOT STARTED]

**Goal**: Update the now-stale descriptive count in the C21 comment block that sits adjacent to
this task's diff, and confirm the three `docs/theorem-index.md` rows need no change.

**Tasks**:
- [ ] Re-read the C21 comment block near line 4144 ("C2 pins four declarations ... and C14 pins the
      rest, 105 between them") and recompute the true total from the current heredoc, e.g.
      `sed -n '/<<.C14BASE./,/^C14BASE$/p' scripts/check-module-invariants.sh | grep -c 'depends on axioms'`
      plus C2's four.
- [ ] Update that single descriptive number to the recomputed value. This comment is descriptive
      and non-enforced; the edit is cosmetic hygiene, not an acceptance criterion.
- [ ] Re-read `docs/theorem-index.md` lines 151-153 and confirm each row's `pcq pinned:C14` cell now
      states exactly what the check verifies -- therefore no row edit is required. Record that the
      alternative (row-correction) outcome was evaluated and rejected on the live evidence.
- [ ] Re-run `bash scripts/check-module-invariants.sh --no-build` as a cheap sanity pass over the
      comment-only edit (sufficient here because this phase touches no heredoc content and no Lean
      surface).
- [ ] Commit.

**Timing**: 0.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the baseline count stated in the C21 comment is stale by
exactly three and that `docs/theorem-index.md` needs zero edits. Confirm the first by the
`grep -c 'depends on axioms'` recount above rather than by adding 3 to the written number; confirm
the second by reading rows 151-153 against the legend at line 18.

**Files to modify**:
- `scripts/check-module-invariants.sh` - one descriptive count inside an existing comment block.
- `docs/theorem-index.md` - expected to be UNCHANGED; read-only confirmation only.

**Verification**:
- `git diff scripts/check-module-invariants.sh` for this phase shows a single comment-line change.
- `git status --short docs/theorem-index.md` is empty (no edit was needed).
- `bash scripts/check-module-invariants.sh --no-build` exits 0.

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` (full, `RUN_BUILD=1`) exits 0 after Phase 2.
- [ ] C14 reports `pass` and its note output names all three new declarations.
- [ ] C21, C23 and C36 report `pass` in the same run (dynamic heredoc parsers unaffected by the
      3-line growth).
- [ ] `grep -nE 'exists_witnessFamily_of_not_validZTime|validZTime_iff_noCertifiedCandidate|Compression\.decidableValidZTime' scripts/check-module-invariants.sh`
      now hits both a `C14_BASELINE` line and a `#print axioms` directive for each name, not just
      the C23 allowlist.
- [ ] `git status --short` shows no modified `*.lean` file (hard constraint: no Lean source change).
- [ ] `git diff` across the task shows no existing baseline entry removed, weakened, or reordered.
- [ ] No task number appears in either touched file (`.claude/rules/no-task-references-in-deliverables.md`).
- [ ] No new `pinned:` cell was added to any `docs/theorem-index.md` row, and no baseline entry
      exists for the unlanded fourth declaration.

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` - three new `C14_BASELINE` entries, three matching `C14LEAN`
  directives, one pointer comment for the pending fourth declaration, one refreshed descriptive
  count.
- `docs/theorem-index.md` - unchanged; its rows 151-153 `pinned:C14` claim becomes true by virtue
  of the script edit.
- Implementation summary recording: the confirmed gap, the baseline route chosen over
  row-correction and why, and the pending fourth declaration left as a pointer.

## Rollback/Contingency

- The entire change is additive and confined to one shell script, so reverting is
  `git revert <sha>` on the Phase 2 (and, if taken, Phase 3) commit; no Lean rebuild semantics
  change and no generated artifact depends on it.
- If the full `check-module-invariants.sh` run fails at C14 after Phase 2, the cause is almost
  certainly an order or count mismatch between the two heredocs, not a genuine axiom divergence:
  compare the failing `C14_OUT` diff against `C14_BASELINE` line-for-line and fix the appended
  block's order. Do NOT "fix" a mismatch by editing an existing baseline entry or by relaxing the
  check -- that is explicitly forbidden by the dispatch's hard constraints.
- If a genuine axiom divergence appears (any of the three reporting something other than
  `[propext, Classical.choice, Quot.sound]`), stop and report: the correct response is then the
  dispatch's alternative outcome -- qualify or drop the `pinned:C14` cells on rows 151-153 with the
  measured values recorded -- not a forced baseline entry.
- If Phase 1's re-verification shows the pin already runs, no edit is made at all and the false-alarm
  finding is the deliverable; nothing to roll back.
