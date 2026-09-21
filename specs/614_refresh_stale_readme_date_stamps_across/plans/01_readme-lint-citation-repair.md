# Implementation Plan: Refresh README date stamps, repair archive links, re-point typst citations

- **Task**: 614 - Refresh stale README date stamps across FormalSystem, repair archive links, re-point typst citations
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: None remaining (task 634's XLanguage merge has landed; verified — the five pre-merge XLanguage README paths no longer exist)
- **Research Inputs**: specs/614_refresh_stale_readme_date_stamps_across/reports/01_readme-stamps-lint-repair.md
- **Artifacts**: plans/01_readme-lint-citation-repair.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Two documentation lints are red in CI and one is advisory-noisy. `scripts/readme-lint.sh
FormalSystem BimodalTools` exits 1 on 21 broken archive links (relative paths left short when the
archive moved from `FormalSystem/Boneyard/` to the repository root) and additionally reports 53
READMEs with a stale or missing date stamp. `scripts/typst-sync-check.sh` exits 1 with
`TOTAL_VIOLATIONS=9`, all citations of `docs/training/PIPELINE.md` in
`typst/chapters/p4-dataset-pipeline.typ`. This plan repairs all three in four edit phases plus a
whole-gate re-verification phase, and touches no Lean source, no proof obligation and nothing
under `Boneyard/`.

Definition of done: `readme-lint.sh FormalSystem BimodalTools` exits 0 with zero BROKEN lines and
zero stale/missing stamps; `typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` both locally
and inside a clean `git archive HEAD` export; both typst documents compile; `git status` shows
nothing modified under `Boneyard/`.

### Research Integration

Every count and correction below was re-derived at HEAD by the research report and independently
re-confirmed during planning (`readme-lint.sh FormalSystem BimodalTools` -> 51 STALE + 2 MISSING +
21 BROKEN; `typst-sync-check.sh` -> `TOTAL_VIOLATIONS=9`). Four research findings shape the phase
structure directly:

1. **CI uses two roots.** A bare `readme-lint.sh` silently omits `BimodalTools/README.md`, which
   is stale. Every verification step in this plan uses `readme-lint.sh FormalSystem BimodalTools`.
2. **The stamp check is self-referential.** Check 4 compares the stamp against
   `git log -1 --format=%cs -- "$dir"`, which includes the whole subtree. Committing any README
   edit re-dates that directory and all its ancestors, so the link-repair commit must land
   *before* the stamp sweep, and the stamp value must equal the stamp commit's own calendar date.
   A pre-commit lint run proves nothing.
3. **A straight typst re-point leaves CI red.** `/training/` is gitignored (`.gitignore:91`,
   deliberate); `git ls-files training/` returns zero files. `typst-sync-check.sh` resolves by
   filesystem existence, never by git, so `training/PIPELINE.md` passes on a developer's disk and
   fails on a clean checkout. The surviving citations must be whitelisted, not merely re-pointed.
4. **A clean export exposes a 10th violation.** `` `lakefile.lean` `` in
   `typst/chapters/ax-lean-appendix.typ:191` (a deliberate negative reference — the repo has no
   `lakefile.lean`) passes locally only via `.lake/packages/mathlib/lakefile.lean`. It needs a
   whitelist entry or the acceptance criterion cannot be met on CI.

Explicitly **out of scope** per the research report: the 89 ungated `NOT LISTED` Check 2 findings
(a separate README-inventory drift, 78 of them under `Metalogic/Expressiveness/Kamp/`).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md context was provided in this dispatch; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 with `Broken file references: 0`.
- Zero `STALE DATE` and zero `MISSING DATE` findings from the same invocation, measured *after*
  the final commit.
- `scripts/typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` in the working tree **and** in a
  fresh `git archive HEAD` export.
- `typst compile --root .. typst/BimodalReference.typ` and `... typst/FormalFoundations.typ` both
  exit 0.
- `scripts/check-module-invariants.sh` remains exit 0.
- Nothing under `Boneyard/` is modified.

**Non-Goals**:
- The 89 `NOT LISTED` Check 2 findings (ungated, pre-existing, separate drift).
- Any change to `scripts/readme-lint.sh`, `scripts/typst-sync-check.sh`, or any other script.
  Sibling tasks 643 and 644 own `scripts/`; this task edits no script.
- Un-ignoring `/training/` or tracking it (option B of the research report's user decision,
  declined).
- Any Lean source edit, proof, or `lake build` change.
- Rewriting bare-prose `Boneyard/...` mentions that are not markdown links — Check 3 extracts
  `[text](path)` spans only, and those prose mentions are already correct relative to the
  repository root.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stamp sweep commits after midnight, re-staling every stamp it just wrote | H | M | Stamp with the stamp commit's own calendar date; Phase 5 re-runs the lint *after* the last commit and restamps any file that drifted. If the sweep spans a date boundary, restamp the whole set to the later date in one follow-up commit. |
| The six READMEs already stamped `2026-09-21` but *not* in the 53 go stale if the work lands on a later day | M | M | Named explicitly in Phase 5's Scope Hypothesis: `Metalogic/Expressiveness/{README,GameTransfer/README}.md`, `Metalogic/WeakCanonical/README.md`, `{Plus,Minus,Star}Language/README.md`. Phase 5's post-commit lint run catches them; restamp to the commit date if flagged. |
| A mass `sed` corrupts one of the four irregular stamp line shapes | H | M | Four distinct shapes and 11 double-stamp files are enumerated per phase below. Edit per file with `Edit`, never a tree-wide `sed`; `git diff` review before each commit. |
| Bumping `Metalogic/Bundle/README.md`'s first match falsifies a dated historical fact | M | H (if unguarded) | That line records the 2026-09-02 retirement of the canonical-frame half, not a verification stamp. Reword it out of stamp shape (drop the `*Last updated:` prefix) rather than bumping its date; the real stamp below it then becomes the lint's first match. |
| A local `typst-sync-check.sh` pass hides a CI failure (`training/`, `lakefile.lean`) | H | H (if unguarded) | The gating verification for Phase 2 is the check run inside a fresh `git archive HEAD \| tar -x` export, not the working tree. Both checks must pass. |
| The `lakefile.lean` whitelist entry is an exact-match global that would also suppress a future genuine `lakefile.lean` citation elsewhere in `typst/` | L | L | Accepted, and documented in the whitelist comment block. This matches the existing `data/` precedent in the same file. The repository has no `lakefile.lean`, so any future citation of it would be a negative reference too. |
| A concurrent sibling (637, 643, 644) edits a file mid-sweep | M | L | No declared scope overlap: siblings own `scripts/`, `docs/development/`, `ORGANISATION.md`, `CLAUDE.md`, `FormalSystem/FormalSystem.lean` and `specs/`; this task owns `FormalSystem/**/README.md`, `BimodalTools/README.md`, `typst/chapters/*.typ` and `typst/sync-check-whitelist.txt`. Still re-read every file immediately before editing, and stage explicit file lists — never a directory or glob pathspec. |
| Task 637 declares `specs/` at directory granularity, overlapping this task's own artifact writes | L | M | Confined to `specs/614_*/`; stage only this task's own paths at postflight. |
| De-citing four footnotes edits published reference-manual prose | M | H (by design) | Settled decision (option A, relayed in the dispatch's Prior Decisions). Record in the implementation summary that the content's canonical home is the chapter itself, citing `training/PIPELINE.md:10` and `:676` as the decision record. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel. Phases 1 and 2 touch disjoint file sets
(READMEs vs. typst). Phases 3 and 4 touch disjoint file sets (non-Metalogic vs. Metalogic) but
both must follow Phase 1, because Phase 1's commit re-dates the directories they stamp.

---

### Phase 1: Archive link depth repair [NOT STARTED]

**Goal**: `readme-lint.sh FormalSystem BimodalTools` reports `Broken file references: 0`, turning
CI's README-health step from FAIL to PASS. This is the only phase that affects the lint's exit
code.

**Tasks**:
- [ ] Re-derive the BROKEN list: `bash scripts/readme-lint.sh FormalSystem BimodalTools 2>&1 | grep BROKEN`. Work from that output, not from this plan's table.
- [ ] Apply the `../`-depth corrections below, one `Edit` per link occurrence. Every corrected target was verified to exist on disk during research.
- [ ] Before committing, verify each corrected link resolves: for each `file -> newlink`, `[ -e "$(dirname file)/newlink" ]`.
- [ ] Re-run `bash scripts/readme-lint.sh FormalSystem BimodalTools`; confirm `Broken file references:   0` and `RESULT: PASS`.
- [ ] Stage the 11 files by explicit list and commit `task 614 phase 1: repair archive link depth`.

Corrections (11 files, 21 occurrences):

| File | Occurrences | Old target | New target |
|------|---|-----|-----|
| `FormalSystem/README.md` | 4 | `Boneyard/README.md` | `../Boneyard/README.md` |
| `FormalSystem/Automation/README.md` | 1 | `../Boneyard/RetiredTactics/README.md` | `../../Boneyard/RetiredTactics/README.md` |
| `FormalSystem/Automation/Tactics/README.md` | 1 | `../../Boneyard/RetiredTactics/README.md` | `../../../Boneyard/RetiredTactics/README.md` |
| `FormalSystem/Metalogic/README.md` | 1 | `../Boneyard/README.md` | `../../Boneyard/README.md` |
| `FormalSystem/Metalogic/README.md` | 1 | `../Boneyard/Kamp/README.md` | `../../Boneyard/Kamp/README.md` |
| `FormalSystem/Metalogic/Bundle/README.md` | 1 | `../../Boneyard/BundleDeadHalf/README.md` | `../../../Boneyard/BundleDeadHalf/README.md` |
| `FormalSystem/Metalogic/Core/README.md` | 2 | `../../Boneyard/RestrictedMCSBoundedness/README.md` | `../../../Boneyard/RestrictedMCSBoundedness/README.md` |
| `FormalSystem/Metalogic/WeakCanonical/README.md` | 1 | `../../Boneyard/README.md` | `../../../Boneyard/README.md` |
| `FormalSystem/Metalogic/WeakCanonical/README.md` | 1 | `../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` |
| `FormalSystem/Metalogic/Expressiveness/EFGames/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` | `../../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` |
| `FormalSystem/Metalogic/Expressiveness/GameTransfer/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` | `../../../../Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` | 2 | `../../../Boneyard/Kamp/KampWeakCanonical/README.md` | `../../../../Boneyard/Kamp/KampWeakCanonical/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` | 1 | `../../../Boneyard/Kamp/README.md` | `../../../../Boneyard/Kamp/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` | 1 | `../../../Boneyard/README.md` | `../../../../Boneyard/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Separation/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md` | `../../../../Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md` |
| `FormalSystem/Metalogic/Expressiveness/Separation/README.md` | 1 | `../../../Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md` | `../../../../Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md` |

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local — markdown link edits confined to 11 README files with zero compile
surface; the in-phase gate is a lint run over exactly the tree those files live in
(`readme-lint.sh FormalSystem BimodalTools`), plus a per-link `[ -e ]` existence probe.

**Commit Mode**: atomic-batch — the phase's acceptance criterion (`Broken file references: 0`) is
unreachable from any proper subset of the 21 corrections, so intermediate per-file states are
expected red and are not committed. This batch is declared here, at plan time, and must not be
widened at implementation time.

**Scope Hypothesis**: 21 broken references across 11 files, each fixable by adding one or two
`../` segments, with no link needing retargeting or deletion. Confirm at implementation time by
re-running `readme-lint.sh FormalSystem BimodalTools | grep BROKEN` and diffing the file set
against the table above; a count other than 21, or a target that does not exist after the
correction, means a sibling task has moved something and the table must be re-derived rather than
applied.

**Files to modify**:
- The 11 READMEs enumerated in the table above — relative-link path segments only; no other content.

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem BimodalTools` prints `Broken file references:   0` and `RESULT: PASS`, exit 0.
- `git status --short` lists exactly the 11 expected files and nothing under `Boneyard/`.

---

### Phase 2: Typst citation repair [NOT STARTED]

**Goal**: `typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` both in the working tree and in
a clean `git archive HEAD` export, with no knowingly-false citation left in the reference manual.

Resolution follows the settled decision relayed in the dispatch (option A): re-point the four
citations that still have a live anchor, de-cite the four that are orphaned, and whitelist the
surviving `training/PIPELINE.md` spans plus `lakefile.lean`.

**Tasks**:
- [ ] Re-derive the violation list: `bash scripts/typst-sync-check.sh 2>&1 | grep VIOLATION`.
- [ ] Re-verify each proposed new line range against the live `training/PIPELINE.md` (701 lines) before writing it — quote the target line and confirm it says what the citing sentence claims.
- [ ] **Re-point the four live citations** in `typst/chapters/p4-dataset-pipeline.typ`:
  - [ ] Bare `docs/training/PIPELINE.md` -> `training/PIPELINE.md` (lines 4 (the comment), 22, 35, 113; line 35's "Module Reference section" anchor is at `:54`).
  - [ ] Line 70, `:14` -> `training/PIPELINE.md:576` (verbatim artifact-only sentence).
  - [ ] Line 70, `:612` -> `training/PIPELINE.md:578-592` (`### Sync Mechanism` + code block).
  - [ ] Line 61, `:428-437` -> `training/PIPELINE.md:391-403` (`## Executable Targets` + `[[lean_exe]]` block).
  - [ ] Line 30, `:42-44` -> `training/PIPELINE.md:230` ("Implemented, tested ... Targeted for Tier 2 integration").
- [ ] **De-cite the four orphaned footnotes** — the quoted sentences are the chapter's own canonical prose (see `training/PIPELINE.md:10` and `:676`, which record that this content was deliberately consolidated into the chapter):
  - [ ] Line 28 (policy network, `:24-31`) — drop the quotation marks and the footnote pointer; state the sentence in the chapter's own voice.
  - [ ] Line 29 (value network, `:33-40`) — same.
  - [ ] Line 100 (Priority 1 recommendation, `:744-762`) — same.
  - [ ] Line 93 (Tier-1 gate table caption, `:687-740`) — re-point to `training/PIPELINE.md:651-676` for the surviving configuration + conformance material, and state in the caption that the gate table itself is the chapter's own.
- [ ] **Add a whitelist block** to `typst/sync-check-whitelist.txt` with a comment header in the style of the existing `data/` entry, explaining that `training/` is deliberately gitignored and absent from any checkout. One exact-match entry per surviving backtick span (the bare `training/PIPELINE.md` plus each `training/PIPELINE.md:NNN[-NNN]` form actually present after the re-point).
- [ ] Add one further whitelist entry, `lakefile.lean`, under its own comment noting it is the deliberate negative reference at `typst/chapters/ax-lean-appendix.typ:191` (the repo has no `lakefile.lean`; it resolves locally only via `.lake/packages/mathlib/`).
- [ ] Confirm `bash scripts/typst-sync-check.sh` prints `TOTAL_VIOLATIONS=0`, exit 0.
- [ ] Confirm `typst compile --root .. typst/BimodalReference.typ` and `typst compile --root .. typst/FormalFoundations.typ` both exit 0.
- [ ] Commit `task 614 phase 2: re-point and de-cite typst pipeline citations`.
- [ ] **After committing**, run the clean-export gate: `git archive HEAD | tar -x -C <scratch>` then `(cd <scratch> && bash scripts/typst-sync-check.sh)` — must print `TOTAL_VIOLATIONS=0`.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local — edits confined to two `.typ` files and one plain-text whitelist,
with no exported symbol or cross-module surface; the in-phase gate builds exactly the two
documents that contain them plus the one check that reads the whitelist.

**Commit Mode**: atomic-batch — the chapter re-points and the whitelist block are one objective:
re-pointing alone moves the violations from `docs/training/...` to `training/...` without
clearing them on a clean checkout, so intermediate per-file states are expected red. Declared at
plan time; must not be widened at implementation time.

**Scope Hypothesis**: 9 violations locally and 10 in a clean export, all in two files; 4 citations
have live anchors needing new line numbers, 4 are orphaned, and 1 (`lakefile.lean`) is a
whitelist-only negative reference. Confirm at implementation time by re-running the check in both
environments and by reading each proposed target line range in `training/PIPELINE.md` before
writing it. A line range that does not say what the citing sentence claims means the citation is
orphaned, not merely misdirected, and moves to the de-cite list.

**Files to modify**:
- `typst/chapters/p4-dataset-pipeline.typ` - re-point 5 live citation spans (incl. the line-4 comment), de-cite 4 orphaned footnotes/captions.
- `typst/sync-check-whitelist.txt` - add one commented block for the surviving `training/PIPELINE.md` spans and one for `lakefile.lean`.
- `typst/chapters/ax-lean-appendix.typ` - **no edit expected**; the `lakefile.lean` reference is correct prose and is resolved by the whitelist entry. Listed only so a reviewer knows it was considered.

**Verification**:
- `bash scripts/typst-sync-check.sh` -> `TOTAL_VIOLATIONS=0`, exit 0.
- Same check inside a fresh `git archive HEAD` export -> `TOTAL_VIOLATIONS=0`, exit 0. **This is the gating run**; a working-tree pass alone does not close this phase.
- Both `typst compile` invocations exit 0.
- No footnote in `p4-dataset-pipeline.typ` cites a `PIPELINE.md` line range that does not contain the quoted material.

---

### Phase 3: Date stamps, non-Metalogic (19 files) [NOT STARTED]

**Goal**: Every README outside `FormalSystem/Metalogic/` that the lint flags carries a stamp equal
to this phase's commit date.

**The stamping rule for Phases 3 and 4**: rewrite the date to the calendar date the commit will
land on (`date +%F` at commit time). The lint predicate is strict (`STAMP_DATE < COMMIT_DATE`), so
a stamp equal to the commit date is green and a stamp one day earlier is not.

**Tasks**:
- [ ] Re-derive the list: `bash scripts/readme-lint.sh FormalSystem BimodalTools 2>&1 | grep -E 'STALE DATE|MISSING DATE' | grep -v 'FormalSystem/Metalogic/'`.
- [ ] For each file, locate the **first** line matching `last verified|last updated` (case-insensitive) — that is the only line the lint reads — and rewrite its date. Preserve the line's existing shape; four shapes occur across the full 53:
  - `*Last verified: YYYY-MM-DD*` (the 40-file majority)
  - `**Last verified**: YYYY-MM-DD`
  - `*Last verified: YYYY-MM-DD — <trailing prose>*`
  - `*Last updated: YYYY-MM-DD (<parenthetical>)*`
- [ ] Two files in this set carry a **second** `last verified|last updated` line that the lint does not read; update it to the same date so the file does not contradict itself: `FormalSystem/Semantics/Correspondence/README.md`, `FormalSystem/Semantics/Extension/README.md`.
- [ ] `git diff` review: confirm every hunk changes only a date string.
- [ ] Commit `task 614 phase 3: refresh non-Metalogic README date stamps`.
- [ ] **After committing**, re-run the lint and confirm none of these 19 files is still flagged.

Files (19): `BimodalTools/README.md`; `FormalSystem/README.md`; `FormalSystem/Automation/README.md`;
`FormalSystem/Automation/ProofSearch/README.md`; `FormalSystem/Automation/Tactics/README.md`;
`FormalSystem/Examples/README.md`; `FormalSystem/ForMathlib/README.md`;
`FormalSystem/ForMathlib/Order/README.md`; `FormalSystem/ProofSystem/README.md`;
`FormalSystem/Semantics/README.md`; `FormalSystem/Semantics/Correspondence/README.md`;
`FormalSystem/Semantics/Extension/README.md`; `FormalSystem/Semantics/Frames/README.md`;
`FormalSystem/Semantics/Ultraproduct/README.md`; `FormalSystem/Syntax/README.md`;
`FormalSystem/Syntax/SubformulaClosure/README.md`; `FormalSystem/Theorems/README.md`;
`FormalSystem/Theorems/Perpetuity/README.md`; `FormalSystem/Theorems/Propositional/README.md`.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose — every changed hunk is a date string inside a markdown stamp line,
with zero compile or elaboration surface. The diff read-through confirms this directly; the
post-commit lint run is the phase's acceptance evidence.

**Commit Mode**: atomic-batch — the acceptance criterion (zero flagged files in this set) is only
measurable once all 19 land in one commit, and a per-file commit sequence would re-date the same
ancestor directories 19 times for no recovery value. Declared at plan time; must not be widened.

**Scope Hypothesis**: 19 files outside `FormalSystem/Metalogic/`, all `STALE DATE` (no `MISSING
DATE` in this set), of which 2 carry a second stamp line. Confirm at implementation time by
re-running the lint and grepping each file for a second `last verified|last updated` match before
editing; a file with an unexpected second match must have both lines updated.

**Files to modify**:
- The 19 READMEs listed above - the first `last verified|last updated` date, plus the second such line in the 2 double-stamp files.

**Verification**:
- After the commit, `bash scripts/readme-lint.sh FormalSystem BimodalTools` flags none of these 19.
- `git diff HEAD~1` shows only date-string changes, no prose or link changes.

---

### Phase 4: Date stamps, Metalogic subtree (34 files) [NOT STARTED]

**Goal**: Every README under `FormalSystem/Metalogic/` that the lint flags carries a stamp equal
to this phase's commit date, including the two files that have no stamp line at all.

**Tasks**:
- [ ] Re-derive the list: `bash scripts/readme-lint.sh FormalSystem BimodalTools 2>&1 | grep -E 'STALE DATE|MISSING DATE' | grep 'FormalSystem/Metalogic/'`.
- [ ] Rewrite the first `last verified|last updated` date in each of the 32 `STALE DATE` files, preserving each line's existing shape (see Phase 3's four-shape list).
- [ ] Keep the **second** stamp line consistent in the 9 double-stamp files in this set:
  `Metalogic/Algebraic/README.md`, `Metalogic/Bundle/README.md`,
  `Metalogic/Decidability/Verified/Bridge/README.md`,
  `Metalogic/Decidability/Verified/Termination/README.md`,
  `Metalogic/Expressiveness/Kamp/EANegationFixFaithful/README.md`,
  `Metalogic/Independence/README.md`, `Metalogic/WeakCanonical/DenseModelSurgery/README.md`,
  `Metalogic/WeakCanonical/GroupModel/README.md`, `Metalogic/WeakCanonical/RealModel/README.md`.
- [ ] **Special case — `FormalSystem/Metalogic/Bundle/README.md`**: its *first* `last updated`
  match is a historical event record ("retirement of the canonical-frame half to
  `Boneyard/BundleDeadHalf/`", dated 2026-09-02), not a verification stamp. Do **not** bump its
  date — that would falsify a dated fact. Reword the line out of stamp shape instead (e.g.
  `*The canonical-frame half was retired to ` + backtick + `Boneyard/BundleDeadHalf/` + backtick +
  ` on 2026-09-02.*`), so the real stamp further down becomes the lint's first match, then bump
  that real stamp. Verify by re-running the lint and confirming the reported "stamped" value is
  the real stamp's date, not 2026-09-02.
- [ ] **Add a stamp to the two `MISSING DATE` files**, matching the 40-file majority shape: a
  trailing `*Last verified: YYYY-MM-DD*` line after a `---` rule at end of file.
  - [ ] `FormalSystem/Metalogic/Conservativity/Star/README.md`
  - [ ] `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md`
- [ ] `git diff` review: confirm every hunk changes only a date string, except the two appended
  stamp lines and the one `Bundle/README.md` rewording.
- [ ] Commit `task 614 phase 4: refresh Metalogic README date stamps`.
- [ ] **After committing**, re-run the lint and confirm none of these 34 files is still flagged.

Files (34): the `FormalSystem/Metalogic/**` entries of the lint's `STALE DATE`/`MISSING DATE`
output — `Algebraic`, `Bundle`, `BXCanonical` (+ `Chronicle`, `Filtration`, `Quasimodel`),
`Conservativity` (+ `Plus`, `Star`), `Core` (+ `RestrictedMCS`), `Decidability` (+ `BiLasso`,
`FMP`, `Propositional`, `Verified`, `Verified/Bridge`, `Verified/Termination`,
`Verified/Termination/MintBound`), `Deterministic`, `Expressiveness/EFGames`,
`Expressiveness/Kamp` (+ `EANegationFix`, `EANegationFixFaithful`, `NfMultiAnchorBridge`,
`NfMultiAnchorBridge/SharedWitness`), `Expressiveness/Separation`, `Independence`,
`Metalogic/README.md`, `SoundnessLemmas`, and `WeakCanonical/{DenseModelSurgery, GroupModel,
IntegerModel, RealModel}`.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: prose — date-string edits, two appended stamp lines, and one prose
rewording, all inside markdown with zero compile surface. The `Bundle/README.md` rewording is the
one hunk that changes prose rather than a date, and the diff read-through must confirm it does not
alter the recorded 2026-09-02 fact.

**Commit Mode**: atomic-batch — same rationale as Phase 3: the acceptance criterion is only
measurable once all 34 land. Declared at plan time; must not be widened.

**Scope Hypothesis**: 34 files under `FormalSystem/Metalogic/` — 32 `STALE DATE` and 2 `MISSING
DATE` — of which 9 carry a second stamp line and 1 (`Bundle/README.md`) has a non-stamp first
match. Confirm at implementation time by re-running the lint and, for every file in the set,
grepping for all `last verified|last updated` matches before editing; an unexpected second match,
or a first match that is a historical record rather than a stamp, gets the `Bundle/README.md`
treatment rather than a date bump.

**Files to modify**:
- The 34 READMEs above - first stamp date; second stamp date in the 9 double-stamp files; a new trailing stamp line in the 2 `MISSING DATE` files; one prose rewording in `Metalogic/Bundle/README.md`.

**Verification**:
- After the commit, `bash scripts/readme-lint.sh FormalSystem BimodalTools` flags none of these 34.
- The lint's reported "stamped" value for `Metalogic/Bundle/README.md` is the real stamp's date, not 2026-09-02.
- `git diff HEAD~1` shows date-only changes plus exactly two appended stamp lines and one rewording.

---

### Phase 5: Whole-gate re-verification [NOT STARTED]

**Goal**: Confirm the revised acceptance criteria hold simultaneously, measured after the last
commit, in both the working tree and a clean export — and repair any stamp that drifted because
the sweep crossed a date boundary.

**Tasks**:
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` -> exit 0, `Broken file references:   0`, zero `STALE DATE`, zero `MISSING DATE`, `RESULT: PASS`.
- [ ] If any README is still flagged stale, restamp it to the current date and commit `task 614 phase 5: restamp READMEs re-staled by commit date`; then re-run until clean. Expect this only if the sweep crossed midnight.
- [ ] `bash scripts/typst-sync-check.sh` -> exit 0, `TOTAL_VIOLATIONS=0`.
- [ ] `git archive HEAD | tar -x -C <scratch>` then `(cd <scratch> && bash scripts/typst-sync-check.sh)` -> exit 0, `TOTAL_VIOLATIONS=0`.
- [ ] `(cd <scratch> && bash scripts/readme-lint.sh FormalSystem BimodalTools)` -> exit 0 (clean-export parity for the README lint too).
- [ ] `typst compile --root .. typst/BimodalReference.typ` -> exit 0.
- [ ] `typst compile --root .. typst/FormalFoundations.typ` -> exit 0.
- [ ] `bash scripts/check-module-invariants.sh` -> exit 0 (regression guard; C13 scans `docs/` and the root `README.md` only and should be unaffected).
- [ ] `git status --porcelain -- Boneyard/` -> empty.
- [ ] `git log --stat` review of the task's commits: confirm no file outside the declared scope was staged.

**Timing**: 0.5 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full — this phase is the complete gate set for the task; nothing is
deferred past it.

**Scope Hypothesis**: the six READMEs already stamped `2026-09-21` and *not* in the 53
(`FormalSystem/Metalogic/Expressiveness/README.md`,
`FormalSystem/Metalogic/Expressiveness/GameTransfer/README.md`,
`FormalSystem/Metalogic/WeakCanonical/README.md`, and
`FormalSystem/{Plus,Minus,Star}Language/README.md`) stay green, and
`FormalSystem/Tactic/README.md` (stamped 2026-09-20, a leaf this task never touches) stays green.
This holds only if every commit lands on 2026-09-21. Confirm by the post-commit lint run; if the
sweep crossed a date boundary, restamp whatever it flags — including these seven — in the
follow-up commit above.

**Files to modify**:
- None expected. Any file the final lint flags is restamped in a follow-up commit.

**Verification**:
- Every command above exits 0 with the stated output. The clean-export runs are gating, not advisory.

## Lean Challenge Statements

No Lean declarations are in scope. This task edits only markdown READMEs, two `.typ` chapters and
one plain-text whitelist; it introduces, changes and proves no Lean theorem, so this section
declares no identifiers (matching the empty Lean-identifier set under **Goals** above). No
`lake build` is required at any phase.

## Testing & Validation

- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 with `Broken file references:   0` and `RESULT: PASS`.
- [ ] The same invocation reports zero `STALE DATE` and zero `MISSING DATE`, measured **after** the final commit.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` in the working tree.
- [ ] The same check exits 0 with `TOTAL_VIOLATIONS=0` inside a fresh `git archive HEAD` export.
- [ ] `typst compile --root .. typst/BimodalReference.typ` exits 0.
- [ ] `typst compile --root .. typst/FormalFoundations.typ` exits 0.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (unchanged from its pre-task green state).
- [ ] `git status --porcelain -- Boneyard/` is empty.
- [ ] No file under `scripts/`, `docs/development/`, `ORGANISATION.md` or `CLAUDE.md` is modified (sibling territory).
- [ ] Every re-pointed `training/PIPELINE.md` line range was read and confirmed to contain the material the citing sentence claims.

## Artifacts & Outputs

- `specs/614_refresh_stale_readme_date_stamps_across/plans/01_readme-lint-citation-repair.md` (this file)
- `specs/614_refresh_stale_readme_date_stamps_across/summaries/01_readme-lint-citation-repair-summary.md` (at implementation completion)
- 11 READMEs with corrected archive links (Phase 1)
- 53 READMEs with refreshed or newly added date stamps (Phases 3-4)
- `typst/chapters/p4-dataset-pipeline.typ` with 5 re-pointed and 4 de-cited references (Phase 2)
- `typst/sync-check-whitelist.txt` with two new commented entry blocks (Phase 2)
- Four to five commits, one per phase (plus an optional Phase 5 restamp commit)

## Rollback/Contingency

Each phase is a single, self-contained commit touching only documentation and prose, so rollback
is `git revert <phase-commit-sha>` — no working-tree discard is needed and none should be used.
Reverting any one phase leaves the others valid: Phase 2 is independent of the README work
entirely, and reverting Phase 1 only restores the pre-existing broken links (CI returns to its
current red state, no worse).

If a phase must be abandoned mid-edit with uncommitted changes present, take a durable,
non-reverting checkpoint first — `bash .claude/scripts/git-snapshot.sh 614 --no-revert` — and
record the resume point in the phase's task checklist. Do **not** use the default (reverting)
snapshot mode here: nothing in this task warrants discarding working-tree state, and a genuine
whole-tree rollback is not a scenario these phases create. See
`context/contracts/recovery.md`'s rollback rung if one ever does.

Contingency for the date-boundary hazard: if the sweep crosses midnight and the lint re-flags
files after the final commit, the remedy is always forward — restamp to the new current date and
commit again (Phase 5's follow-up step). Never revert the stamp work to "fix" staleness.
