# Implementation Plan: Refresh README date stamps, repair archive links, re-point typst citations

- **Task**: 614 - Refresh stale README date stamps across FormalSystem, repair archive links, re-point typst citations
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None remaining (task 634's XLanguage merge has landed; verified — the five pre-merge XLanguage README paths no longer exist)
- **Research Inputs**: specs/614_refresh_stale_readme_date_stamps_across/reports/01_readme-stamps-lint-repair.md
- **Artifacts**: plans/01_readme-lint-citation-repair.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **Plan Version**: 2 (revised in place, round 01; see "Prior Plan Reference")
- **Reports Integrated**: 01_readme-stamps-lint-repair.md

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

Reports integrated: `reports/01_readme-stamps-lint-repair.md` (the only report; no report is newer
than plan version 1).

Every count below was re-derived at HEAD by the research report, re-confirmed when version 1 was
written, and re-confirmed a third time for this revision (HEAD `ad0750d0c`, 2026-09-21:
`readme-lint.sh FormalSystem BimodalTools` -> 51 STALE + 2 MISSING + 21 BROKEN, 34 of the 53 under
`FormalSystem/Metalogic/`; `typst-sync-check.sh` -> `TOTAL_VIOLATIONS=9`). Four research findings
shape the phase structure directly:

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

Version 1 of this file (same path, committed in `b7d428737`) had all five phases `[NOT STARTED]`;
no implementation work exists, so nothing is preserved as completed. This revision keeps the
five-phase structure, the wave table and every file list, and corrects or adds the following, each
found by checking version 1's claims against the live tree:

| # | Phase | Change from version 1 | Evidence |
|---|-------|-----------------------|----------|
| R1 | 2 | The lakefile citation range is `:389-403`, not `:391-403`. | `training/PIPELINE.md:389` is the `## Executable Targets` heading the citation's gloss names; `:391` is the prose line beneath it. |
| R2 | 2 | The footnote on `.typ` line 70 also cites `README.md:183-184`, which is false and which version 1 did not mention. It must be dropped. | `README.md:183-184` is the strong-completeness paragraph. `grep -n -i 'artifact-only\|never calls Lean' README.md` returns nothing; the only BimodalHarness mention is `README.md:389`, which does not carry the quoted wording. The lint cannot see this: it strips the `:183-184` suffix and `README.md` exists. |
| R3 | 2 | The quotation on `.typ` line 70 is verbatim for its first sentence only. | `training/PIPELINE.md:576` ends at "…never calls Lean at runtime." The second quoted sentence ("Instead, it reads JSONL files exported by …") occurs nowhere in `training/PIPELINE.md` or `README.md`. |
| R4 | 2 | The footnote on `.typ` line 30, which this task already rewrites, states "211 lines per `BimodalTools/README.md`". | `wc -l BimodalTools/EnrichedCountermodel.lean` -> 223, and `BimodalTools/README.md:46` says 223. |
| R5 | 2 | Each re-pointed line range is paired with its section heading, and the whitelist entries are enumerated. | Whitelisted spans are skipped before any resolution (`scripts/typst-sync-check.sh:136`), and the target file is untracked, so no gate will ever re-verify these line numbers. A heading name survives line drift; the chapter already cites this way at lines 35 and 100. |
| R6 | 3, 4 | The double-stamp files are characterised exactly: which line the lint reads, and that all ten non-`Bundle` second lines are genuine stamps. | Per-file `grep -n` output, tabulated in Phase 4. |
| R7 | 5 | `check-module-invariants.sh` runs as `--no-build`, with an attribution rule for sibling-owned failures. | The script's default mode runs `lake build` (C1); this task has no Lean surface, and task 643 is editing that same script concurrently. |
| R8 | 5 | New cross-task handoff item: `docs/development/REFERENCE_NORMAL_FORM.md` §5 records "21" and "9 violations" as baselines that "must stay unchanged". This task makes both 0. | `docs/development/REFERENCE_NORMAL_FORM.md:159-160`; task 643's plan asserts the same two baselines as a verification step. That file is task 643's declared territory, so this task reports the delta and does not edit it. |
| R9 | Risks | Documented limit of the "zero stale stamps" criterion on CI. | `.github/workflows/ci.yml:21` uses `actions/checkout@v5` with no `fetch-depth`, i.e. depth 1, so on CI every directory's `git log -1` date is the HEAD commit's date. |

### Roadmap Alignment

No ROADMAP.md context was provided in this dispatch; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 with `Broken file references: 0`.
- Zero `STALE DATE` and zero `MISSING DATE` findings from the same invocation, measured *after*
  the final commit, on the local full clone.
- `scripts/typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` in the working tree **and** in a
  fresh `git archive HEAD` export.
- `typst compile --root .. typst/BimodalReference.typ` and `... typst/FormalFoundations.typ` both
  exit 0.
- `scripts/check-module-invariants.sh --no-build` shows no failure attributable to this task's
  files.
- Every line-anchored citation left in a footnote this task rewrites says what the citing sentence
  claims — including the non-`PIPELINE.md` anchors in those same footnotes (R2, R4).
- Nothing under `Boneyard/` is modified.

**Non-Goals**:
- The 89 `NOT LISTED` Check 2 findings (ungated, pre-existing, separate drift).
- Any change to `scripts/readme-lint.sh`, `scripts/typst-sync-check.sh`, or any other script.
  Sibling tasks 643 and 644 own `scripts/`; this task edits no script.
- Any edit to `docs/development/REFERENCE_NORMAL_FORM.md` (task 643's territory) — its two
  now-stale baseline rows are reported, not fixed here (R8).
- The three `docs/training/` mentions in `docs/development/PUBLICATION_REFACTOR.md` (lines 114,
  306, 549). They are historical narrative about moving that directory, not citations of it.
- Un-ignoring `/training/` or tracking it (option B of the research report's user decision,
  declined).
- Collapsing the eleven duplicate stamp lines into one per file. Both lines are kept and kept
  consistent; removing one is an editorial change beyond a stamp refresh.
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
| Bumping `Metalogic/Bundle/README.md`'s first match falsifies a dated historical fact | M | H (if unguarded) | Line 229 records the 2026-09-02 retirement of the canonical-frame half, not a verification stamp. Reword it out of stamp shape (drop the `*Last updated:` prefix) rather than bumping its date; the real stamp at line 233 then becomes the lint's first match. |
| A local `typst-sync-check.sh` pass hides a CI failure (`training/`, `lakefile.lean`) | H | H (if unguarded) | The gating verification for Phase 2 is the check run inside a fresh `git archive HEAD \| tar -x` export, not the working tree. Both checks must pass. |
| A green sync check hides a false line anchor. The check strips `:NNN` suffixes and only tests that the file exists, and whitelisted spans are skipped outright — so neither `README.md:183-184` (R2) nor any `training/PIPELINE.md:NNN` span is ever content-verified by a gate | H | H (already occurred: R2, R4) | Phase 2 requires reading the target lines of **every** line-anchored span in each rewritten footnote, not only the `PIPELINE.md` ones, and pairing each surviving range with its section heading so the citation outlives line drift in an untracked file. |
| The `lakefile.lean` whitelist entry is an exact-match global that would also suppress a future genuine `lakefile.lean` citation elsewhere in `typst/` | L | L | Accepted, and documented in the whitelist comment block. The repository has no `lakefile.lean`, so any future citation of it would be a negative reference too. |
| Task 643 (implementing concurrently) verifies that the `readme-lint.sh` = 21 and `typst-sync-check.sh` = 9 baselines are *unchanged*; this task moves both to 0 mid-flight, so 643's check will observe a delta it did not cause | M | H | Not a defect in either task, and not this task's file to edit. Phase 5 records the delta in the implementation summary and the orchestrator handoff, naming `docs/development/REFERENCE_NORMAL_FORM.md:159-160` as the two rows to update. Commit messages for Phases 1 and 2 state the baseline change explicitly so 643's agent can attribute it from `git log`. |
| Task 643 is editing `scripts/check-module-invariants.sh` in the same working tree, so that script may be mid-edit or newly red (C31, C32, a third C20 assertion) when Phase 5 runs it | M | M | Run `--no-build` only. A failure on a check ID this task cannot influence, or in a file outside this task's scope, is reported as a possible sibling in-flight edit per the dispatch's territory rule (4) and (5) — never "fixed" here. |
| A concurrent sibling (637, 643, 644) edits a file mid-sweep | M | L | No declared scope overlap: siblings own `scripts/`, `docs/development/`, `ORGANISATION.md`, `CLAUDE.md`, `FormalSystem/FormalSystem.lean` and `specs/`; this task owns `FormalSystem/**/README.md`, `BimodalTools/README.md`, `typst/chapters/*.typ` and `typst/sync-check-whitelist.txt`. Still re-read every file immediately before editing, and stage explicit file lists — never a directory or glob pathspec. |
| Task 637 declares `specs/` at directory granularity, overlapping this task's own artifact writes | L | M | Confined to `specs/614_*/`; stage only this task's own paths at postflight. |
| "Zero stale stamps" cannot hold on CI for longer than a day: CI checks out at depth 1, so every directory's `git log -1` date is HEAD's date, and the first commit on a later day makes every README read as stale there | L | H (by construction) | Documented limitation, no action. Check 4 is advisory and never affects the exit code; the criterion is measured on the local full clone (Goals). Changing the lint or CI's fetch depth is out of scope and in sibling territory. Record it in the implementation summary so a later reader does not mistake CI's Check 4 output for a regression of this sweep. |
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
- [ ] Stage the 11 files by explicit list and commit `task 614 phase 1: repair archive link depth`. State in the commit body that the `readme-lint.sh` broken-reference count moves 21 -> 0 (see the task-643 risk row).

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
a clean `git archive HEAD` export, with no knowingly-false citation left in any footnote this
phase rewrites.

Resolution follows the settled decision relayed in the dispatch (option A): re-point the four
citations that still have a live anchor, de-cite the four that are orphaned, and whitelist the
surviving `training/PIPELINE.md` spans plus `lakefile.lean`.

**The verification rule for this phase**: a green sync check proves only that a *file* exists. It
strips every `:NNN` suffix before resolving, and it skips whitelisted spans entirely. So for every
footnote edited below, read the target lines of **each** line-anchored span in it — the
`PIPELINE.md` ones and any other — and confirm they say what the citing sentence claims. R2 and R4
are both anchors the lint passes and the text falsifies.

**Tasks**:
- [ ] Re-derive the violation list: `bash scripts/typst-sync-check.sh 2>&1 | grep VIOLATION`.
- [ ] Re-derive every line-anchored span in the chapter: `grep -n -o -E '`[^`]+:[0-9]+(-[0-9]+)?`' typst/chapters/p4-dataset-pipeline.typ`. Expect the nine `docs/training/PIPELINE.md` forms plus `README.md:183-184`.
- [ ] Re-verify each proposed new line range against the live `training/PIPELINE.md` (701 lines) before writing it — quote the target line and confirm it says what the citing sentence claims.
- [ ] **Re-point the live citations** in `typst/chapters/p4-dataset-pipeline.typ`, pairing each range with its section heading in the footnote text (the chapter's own existing style at lines 35 and 100):
  - [ ] Bare `docs/training/PIPELINE.md` -> `training/PIPELINE.md` (lines 4 (the non-backticked comment), 22, 35, 113; line 35's "Module Reference section" anchor is the `## Module Reference` heading at `:54`, and that footnote already cites by heading, so it needs the path change only).
  - [ ] Line 61, `:428-437` -> `training/PIPELINE.md:389-403`, "Executable Targets" (heading at `:389`, prose at `:391`, the two `[[lean_exe]]` blocks through the closing fence at `:403`).
  - [ ] Line 30, `:42-44` -> `training/PIPELINE.md:230` ("Implemented, tested, and producing correct JSON output … Targeted for Tier 2 integration"). Name the enclosing section heading; find it by reading upward from `:230`.
  - [ ] Line 30, same footnote: correct "211 lines per `BimodalTools/README.md`" to 223. Confirm first with `wc -l BimodalTools/EnrichedCountermodel.lean` and `BimodalTools/README.md:46`; if the two disagree at implementation time, cite the `wc -l` figure and drop the "per `BimodalTools/README.md`" attribution.
  - [ ] Line 70 — three edits to one sentence and its footnote:
    - [ ] `:14` -> `training/PIPELINE.md:576`, and `:612` -> `training/PIPELINE.md:578-592`, "Sync Mechanism" (heading at `:578`, code block closing at `:592`).
    - [ ] **Drop `README.md:183-184`** and the "near-identical wording in both places" clause. `README.md` carries no such sentence anywhere; `README.md:389` mentions BimodalHarness but not this wording, so it is not a substitute anchor. The footnote cites `training/PIPELINE.md` only.
    - [ ] **Close the quotation after "…never calls Lean at runtime."** That is where `training/PIPELINE.md:576` ends. State the following sentence ("it reads JSONL files exported by `lake exe dataset_generator` …") in the chapter's own voice, outside the quotation marks — the same treatment option A gives the orphaned footnotes. The Sync Mechanism citation supports it.
- [ ] **De-cite the four orphaned footnotes** — the quoted sentences are the chapter's own canonical prose (see `training/PIPELINE.md:10` and `:676`, which record that this content was deliberately consolidated into the chapter):
  - [ ] Line 28 (policy network, `:24-31`) — drop the quotation marks and the footnote pointer; state the sentence in the chapter's own voice.
  - [ ] Line 29 (value network, `:33-40`) — same.
  - [ ] Line 100 (Priority 1 recommendation, `:744-762`) — same.
  - [ ] Line 93 (Tier-1 gate table caption, `:687-740`) — re-point to `training/PIPELINE.md:651-676`, "Feasibility Gate Results (Tier 1)" (heading at `:651`; `:676` is the line that delegates the table to the chapter), for the surviving configuration + conformance material, and state in the caption that the gate table itself is the chapter's own.
- [ ] **Add a whitelist block** to `typst/sync-check-whitelist.txt` with a comment header in the style of the existing entries, explaining that `training/` is deliberately gitignored and absent from any checkout, and that these spans are therefore never resolved by the check. One exact-match entry per surviving backtick span. Derive the list from the edited chapter, not from this plan: `grep -o -E '`training/PIPELINE\.md[^`]*`' typst/chapters/p4-dataset-pipeline.typ | sort -u`. Expected, if the edits above are applied as written, six entries:
  - `training/PIPELINE.md`
  - `training/PIPELINE.md:230`
  - `training/PIPELINE.md:389-403`
  - `training/PIPELINE.md:576`
  - `training/PIPELINE.md:578-592`
  - `training/PIPELINE.md:651-676`
- [ ] Add one further whitelist entry, `lakefile.lean`, under its own comment noting it is the deliberate negative reference at `typst/chapters/ax-lean-appendix.typ:191` (the repo has no `lakefile.lean`; it resolves locally only via `.lake/packages/mathlib/`). The existing `thm:BLplus-NextPrevious` block is the precedent for a negative-resolution entry.
- [ ] Confirm `bash scripts/typst-sync-check.sh` prints `TOTAL_VIOLATIONS=0`, exit 0, and that Checks 2, 2b and 3 still report 0.
- [ ] Confirm `typst compile --root .. typst/BimodalReference.typ` and `typst compile --root .. typst/FormalFoundations.typ` both exit 0.
- [ ] Commit `task 614 phase 2: re-point and de-cite typst pipeline citations`. State in the commit body that `typst-sync-check.sh` Check 1 moves 9 -> 0 (see the task-643 risk row).
- [ ] **After committing**, run the clean-export gate: `git archive HEAD | tar -x -C <scratch>` then `(cd <scratch> && bash scripts/typst-sync-check.sh)` — must print `TOTAL_VIOLATIONS=0`. Use a scratch directory outside any git work tree.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local — edits confined to one `.typ` chapter and one plain-text whitelist,
with no exported symbol or cross-module surface; the in-phase gate builds exactly the two
documents that contain the chapter plus the one check that reads the whitelist.

**Commit Mode**: atomic-batch — the chapter re-points and the whitelist block are one objective:
re-pointing alone moves the violations from `docs/training/...` to `training/...` without
clearing them on a clean checkout, so intermediate per-file states are expected red. Declared at
plan time; must not be widened at implementation time.

**Scope Hypothesis**: 9 violations locally and 10 in a clean export, all in two files; 4 citations
have live anchors needing new line numbers, 4 are orphaned, and 1 (`lakefile.lean`) is a
whitelist-only negative reference. Within the rewritten footnotes, exactly two further anchors are
false despite passing the lint: `README.md:183-184` (line 70) and the "211 lines" count (line 30).
The surviving whitelist set is six `training/PIPELINE.md` spans plus `lakefile.lean`. Confirm at
implementation time by re-running the check in both environments, by the two `grep` derivations in
the task list, and by reading each proposed target line range before writing it. A line range that
does not say what the citing sentence claims means the citation is orphaned, not merely
misdirected, and moves to the de-cite list; a whitelist count other than six means an edit
diverged from this plan and the list must follow the chapter, not the plan.

**Files to modify**:
- `typst/chapters/p4-dataset-pipeline.typ` - re-point 5 live citation spans (incl. the line-4 comment); de-cite 4 orphaned footnotes/captions; on line 70 drop the false `README.md:183-184` anchor and shorten the quotation to its verbatim sentence; on line 30 correct the line count.
- `typst/sync-check-whitelist.txt` - add one commented block for the surviving `training/PIPELINE.md` spans and one for `lakefile.lean`.
- `typst/chapters/ax-lean-appendix.typ` - **no edit expected**; the `lakefile.lean` reference is correct prose and is resolved by the whitelist entry. Listed only so a reviewer knows it was considered.

**Verification**:
- `bash scripts/typst-sync-check.sh` -> `TOTAL_VIOLATIONS=0`, exit 0.
- Same check inside a fresh `git archive HEAD` export -> `TOTAL_VIOLATIONS=0`, exit 0. **This is the gating run**; a working-tree pass alone does not close this phase.
- Both `typst compile` invocations exit 0.
- `grep -c 'docs/training' typst/chapters/p4-dataset-pipeline.typ` -> 0, and `grep -c 'README.md:183' typst/chapters/p4-dataset-pipeline.typ` -> 0.
- Every whitelist entry added has a matching backtick span in the chapter (no dead whitelist line), and every `training/PIPELINE.md…` span in the chapter has a whitelist entry.
- No footnote in `p4-dataset-pipeline.typ` cites a line range — in any file — that does not contain the quoted or paraphrased material, and no quotation mark encloses a sentence absent from its cited source.

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
- [ ] Two files in this set carry a **second** stamp line that the lint does not read; update it to the same date so the file does not contradict itself. In both, the lint reads the bold line and the italic line sits four lines below it:
  - `FormalSystem/Semantics/Correspondence/README.md` — `:76` `**Last verified**: 2026-09-02` (read by the lint), `:80` `*Last verified: 2026-09-07*`.
  - `FormalSystem/Semantics/Extension/README.md` — `:51` `**Last verified**: 2026-09-07` (read by the lint), `:55` `*Last verified: 2026-09-07*`.
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
editing; a file with an unexpected second match must have both lines updated. (Checked for this
revision: no README outside the 53 carries a second stamp line.)

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
- [ ] Keep the **second** stamp line consistent in the 9 double-stamp files in this set. All eight non-`Bundle` second lines are genuine stamps — bare dates with no event text — so both lines take the commit date. Line numbers as of this revision (re-`grep` before editing; Phase 1 does not shift them, but a sibling commit might):

  | File (under `FormalSystem/Metalogic/`) | Line the lint reads | Second line |
  |------|------|------|
  | `Algebraic/README.md` | `:317` `*Last verified: 2026-09-07*` | `:319` `*Last updated: 2026-09-03*` |
  | `Bundle/README.md` | `:229` — **historical record, see special case** | `:233` `*Last verified: 2026-09-07*` |
  | `Decidability/Verified/Bridge/README.md` | `:61` `**Last verified**: 2026-09-07` | `:65` `*Last verified: 2026-09-07*` |
  | `Decidability/Verified/Termination/README.md` | `:60` `**Last verified**: 2026-08-25` | `:64` `*Last verified: 2026-09-07*` |
  | `Expressiveness/Kamp/EANegationFixFaithful/README.md` | `:45` `**Last verified**: 2026-08-25` | `:49` `*Last verified: 2026-09-07*` |
  | `Independence/README.md` | `:152` `**Last verified**: 2026-09-08` | `:156` `*Last verified: 2026-09-08*` |
  | `WeakCanonical/DenseModelSurgery/README.md` | `:52` `**Last verified**: 2026-08-25` | `:56` `*Last verified: 2026-09-07*` |
  | `WeakCanonical/GroupModel/README.md` | `:48` `**Last verified**: 2026-08-25` | `:52` `*Last verified: 2026-09-07*` |
  | `WeakCanonical/RealModel/README.md` | `:49` `**Last verified**: 2026-08-25` | `:53` `*Last verified: 2026-09-07*` |

  Five of these show the hazard directly: an earlier sweep bumped only the trailing italic line to
  2026-09-07 while the lint went on reading the bold `2026-08-25` line above it. Updating only one
  of the two lines here would reproduce that.
- [ ] **Special case — `FormalSystem/Metalogic/Bundle/README.md`**: its *first* `last updated`
  match (`:229`) is a historical event record ("retirement of the canonical-frame half to
  `Boneyard/BundleDeadHalf/`", dated 2026-09-02), not a verification stamp. Do **not** bump its
  date — that would falsify a dated fact. Reword the line out of stamp shape instead (e.g.
  `*The canonical-frame half was retired to ` + backtick + `Boneyard/BundleDeadHalf/` + backtick +
  ` on 2026-09-02.*`), so the real stamp at `:233` becomes the lint's first match, then bump
  that real stamp. The reworded line must contain neither `last verified` nor `last updated` in
  any case. Verify by re-running the lint and confirming the reported "stamped" value is the real
  stamp's date, not 2026-09-02.
- [ ] **Add a stamp to the two `MISSING DATE` files**, matching the 40-file majority shape: a
  trailing `*Last verified: YYYY-MM-DD*` line after a `---` rule at end of file.
  - [ ] `FormalSystem/Metalogic/Conservativity/Star/README.md`
  - [ ] `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/README.md`
- [ ] `git diff` review: confirm every hunk changes only a date string, except the two appended
  stamp lines and the one `Bundle/README.md` rewording. Confirm no added line carries a task
  number (`check-module-invariants.sh` C9 scans `FormalSystem/` for them).
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
commit, in both the working tree and a clean export — repair any stamp that drifted because the
sweep crossed a date boundary — and hand off the one cross-task consequence this task creates.

**Tasks**:
- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` -> exit 0, `Broken file references:   0`, zero `STALE DATE`, zero `MISSING DATE`, `RESULT: PASS`.
- [ ] If any README is still flagged stale, restamp it to the current date and commit `task 614 phase 5: restamp READMEs re-staled by commit date`; then re-run until clean. Expect this only if the sweep crossed midnight, or if a sibling committed under `FormalSystem/` on a later date.
- [ ] `bash scripts/typst-sync-check.sh` -> exit 0, `TOTAL_VIOLATIONS=0`.
- [ ] `git archive HEAD | tar -x -C <scratch>` then `(cd <scratch> && bash scripts/typst-sync-check.sh)` -> exit 0, `TOTAL_VIOLATIONS=0`. The scratch directory must sit outside any git work tree.
- [ ] `(cd <scratch> && bash scripts/readme-lint.sh FormalSystem BimodalTools)` -> exit 0 with `Broken file references:   0`. This run gives clean-export parity for Check 3 only: with no `.git`, `git log` returns nothing and Check 4 silently skips every file, so its stamp output there is not evidence either way.
- [ ] `typst compile --root .. typst/BimodalReference.typ` -> exit 0.
- [ ] `typst compile --root .. typst/FormalFoundations.typ` -> exit 0.
- [ ] `bash scripts/check-module-invariants.sh --no-build` (the fast structural pass; this task has no Lean surface, so C1's `lake build` adds nothing and would contend with sibling builds). Expected: no failure in a check that reads this task's files — C9 (no task numbers under `FormalSystem/`) is the one that could be tripped by an added README line. C12/C13 scan `docs/` and the root `README.md` only and cannot be affected.
  - [ ] If it fails on a check this task cannot influence (a new C31/C32, a C20 assertion, anything reading `.lean` or `docs/`), do **not** fix it: task 643 is editing this script in the same tree. Check `git log -3 -- scripts/check-module-invariants.sh` and `git status --short scripts/`, then report it per the dispatch's territory rules (4) and (5).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` -> zero byte changes (confirms no README edit landed inside a generated inventory block).
- [ ] `git status --porcelain -- Boneyard/` -> empty.
- [ ] `git log --stat` review of the task's commits: confirm no file outside the declared scope was staged.
- [ ] **Cross-task handoff (R8)** — record in the implementation summary *and* in the orchestrator handoff JSON, without editing the file:
  - `docs/development/REFERENCE_NORMAL_FORM.md:159-160` (§5 "Recorded baselines") lists `readme-lint.sh` broken references = 21 and `typst-sync-check.sh` Check 1 = 9 violations, both "unchanged". After this task they are 0 and 0, and the accurate direction is "must stay 0".
  - Task 643's plan verifies those two baselines as unchanged; if its verification runs after this task's Phase 1 or Phase 2 commit it will observe 0. Name the two commit SHAs so the delta is attributable.
  - That file is in task 643's declared `file_scope`, so the row update belongs to task 643 or to a follow-up — not to this task.
- [ ] Record in the implementation summary the CI depth-1 limitation on Check 4 (see the Risks table), so CI's advisory stamp output is not later misread as a regression of this sweep.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full — this phase is the complete gate set for the task; nothing is
deferred past it. ("Full" here means every gate the acceptance criteria name. It deliberately
excludes `lake build`, which no edit in this task can affect.)

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
- `docs/development/REFERENCE_NORMAL_FORM.md` is explicitly **not** modified (sibling territory).

**Verification**:
- Every command above exits 0 with the stated output, subject to the sibling-attribution rule for `check-module-invariants.sh`. The clean-export runs are gating, not advisory.
- The implementation summary and the handoff JSON both carry the R8 baseline-delta note.

## Lean Challenge Statements

No Lean declarations are in scope. This task edits only markdown READMEs, one `.typ` chapter and
one plain-text whitelist; it introduces, changes and proves no Lean theorem, so this section
declares no identifiers (matching the empty Lean-identifier set under **Goals** above). No
`lake build` is required at any phase.

## Testing & Validation

- [ ] `bash scripts/readme-lint.sh FormalSystem BimodalTools` exits 0 with `Broken file references:   0` and `RESULT: PASS`.
- [ ] The same invocation reports zero `STALE DATE` and zero `MISSING DATE`, measured **after** the final commit on the local full clone.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 with `TOTAL_VIOLATIONS=0` in the working tree.
- [ ] The same check exits 0 with `TOTAL_VIOLATIONS=0` inside a fresh `git archive HEAD` export.
- [ ] `typst compile --root .. typst/BimodalReference.typ` exits 0.
- [ ] `typst compile --root .. typst/FormalFoundations.typ` exits 0.
- [ ] `bash scripts/check-module-invariants.sh --no-build` shows no failure attributable to this task's files; `--emit-inventory --check` reports zero byte changes.
- [ ] `git status --porcelain -- Boneyard/` is empty.
- [ ] No file under `scripts/`, `docs/development/`, `ORGANISATION.md` or `CLAUDE.md` is modified (sibling territory).
- [ ] Every re-pointed `training/PIPELINE.md` line range was read and confirmed to contain the material the citing sentence claims, and is paired with its section heading.
- [ ] `typst/chapters/p4-dataset-pipeline.typ` contains no `docs/training` string and no `README.md:183-184` anchor; no quotation in it encloses a sentence absent from its cited source.
- [ ] The whitelist's `training/PIPELINE.md` entries and the chapter's `training/PIPELINE.md` spans are the same set.

## Artifacts & Outputs

- `specs/614_refresh_stale_readme_date_stamps_across/plans/01_readme-lint-citation-repair.md` (this file)
- `specs/614_refresh_stale_readme_date_stamps_across/summaries/01_readme-lint-citation-repair-summary.md` (at implementation completion), carrying the R8 baseline-delta note and the CI depth-1 note
- 11 READMEs with corrected archive links (Phase 1)
- 53 READMEs with refreshed or newly added date stamps (Phases 3-4)
- `typst/chapters/p4-dataset-pipeline.typ` with 5 re-pointed and 4 de-cited references, one false `README.md` anchor removed, one quotation shortened to its verbatim sentence, one line count corrected (Phase 2)
- `typst/sync-check-whitelist.txt` with two new commented entry blocks — six `training/PIPELINE.md` spans and `lakefile.lean` (Phase 2)
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
