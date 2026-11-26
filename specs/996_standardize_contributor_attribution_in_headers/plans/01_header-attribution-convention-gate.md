# Implementation Plan: Task #996

- **Task**: 996 - Standardize contributor attribution in Lean copyright headers, and backfill the files already edited without it
- **Status**: [COMPLETED]
- **Effort**: 8.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/996_standardize_contributor_attribution_in_headers/reports/01_contributor-attribution-headers.md
- **Artifacts**: plans/01_header-attribution-convention-gate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round prototyped and measured every mechanism this task needs, so the work is
largely transcription under a decided set of conventions rather than design. The plan records the
convention and its attribution threshold in tracked prose, adds `.mailmap` plus a new
`scripts/check-header-attribution.sh` gate (identity-folded, exclusion-aware, candidate-reporting,
baseline-waivable), backfills the headers the threshold selects, wires the gate as the eleventh
check in both `verify-all.sh` and `ci.yml`, and implements the repo-local Route A agent rule with
its reach stated honestly. It closes by recording exactly what the claim "attribution is correct
across this repository" excludes.

### Carried-Figure Re-Validation

Checked against the research report and against live state. Results stated even where they only
confirm:

| Carried figure (from the description) | Live / research verdict |
|---|---|
| "980 files carry `Authors: Benjamin Brast-McKie`, 54 carry `Authors: Tanner Duve`" | **CORRECTED.** Live: **953** Benjamin, 54 Tanner, **1007** headed `.lean` files total (FormalSystem 810, Tests 115, BimodalTools 44, BimodalLib 38). Research had already corrected 980 -> 953 and ~1034 -> 1007; re-measured here and confirmed. |
| "ZERO files carry a joint `Authors:` line" | **CONFIRMED live.** Zero line-4 `Authors:` strings contain a comma, across all four roots. |
| "24 of the 54 Tanner-headed files already carry commits by someone else" | **NOT re-derived here.** Research re-derived 24 forward + 6 reverse = 30 candidates via its prototype. The plan mandates live re-derivation in Phase 4 and Phase 5 rather than carrying either count; see each phase's Scope Hypothesis. |
| "`check-copyright-headers.sh` validates `^Authors: [^ ].*[^.]$` on line 4, comma-terminated continuation lines, closure by line 12" | **CONFIRMED live** at `scripts/check-copyright-headers.sh:110` (line-4 regex) and `:116` (`case "$ln" in Authors:*\|*,) ;; *) ok=0 ;; esac`). |
| "the checker validates the multi-line continuation form the convention needs" | **MEASURED FALSE by research.** The `case` arm requires a trailing comma on *every* continuation line including the last; Mathlib's real form omits it and was measured to produce `exit 1`. Phase 2 relaxes exactly that arm. |
| "`git log --format=%an` per file" as the derivation | **MEASURED FALSE by research.** `%an` is mailmap-blind on git 2.54.0 and `--use-mailmap` was measured not to rescue it; only `%aN`/`%aE` honor `.mailmap`. Carried on research's measurement, not re-measured here (no `.mailmap` exists in the tree yet to measure against). Phase 4 re-measures it with the `%an` control once `.mailmap` lands. |
| "six distinct identity rows for three parties; `Claude` authored 46 commits" | Carried on research's `git shortlog -sne` measurement. Confirmed independently: `.mailmap` does **not** exist in the tree today, so no folding is in place. |
| "`CITATION.cff` names only `Brast-McKie, Benjamin`" | **CONFIRMED live.** Its top-level `authors:` list has exactly that one entry. Note the file also carries a *separate* `references:` paper-author list; the top-level list is the **software's** authors, which is the list under question. |
| "`.syncprotect` already protects `context/repo/project-overview.md`" | **CONFIRMED live.** That is the file's one non-comment entry. |
| "anything under `Boneyard/` is already excluded by the checker's `*/Boneyard/*` glob" | **CORRECTED.** `Boneyard/` is a **top-level** directory, outside all four scanned roots; zero `.lean` files match `*/Boneyard/*` under `FormalSystem Tests BimodalTools BimodalLib`. `ci.yml:188` says the same in its own comment ("the archive left FormalSystem/ entirely ... no longer excludes anything"). Consequence: the new gate needs **no** `--exclude` argument, and the dispatch's framing of Boneyard as an active exclusion is stale. |
| "both `verify-all.sh` and `ci.yml` carry `expected=10` with an out-of-sync assertion" | **CONFIRMED live.** `scripts/verify-all.sh:34` and `.github/workflows/ci.yml:350`, with exactly 10 `report` lines in each. |
| "`scripts/readme-date-baseline.txt` is the waiver precedent" | **CONFIRMED live.** 83 rows, format comment documents `<class> <path> <stamp>` and the un-grandfathering property. |

### Research Integration

Every design question this plan would otherwise have to settle was settled by measurement in the
research round, and the plan adopts those results rather than re-opening them:

- **Convention**: single-line `Authors: Tanner Duve, Benjamin Brast-McKie`, `Copyright (c)` line
  untouched. Measured green against both gates on the live tree.
- **Derivation**: one `git log --no-merges --format='%aN' --name-only` pass. Measured at 0.8 s
  over 1007 files, 977 clean / 30 candidates / 0 false positives. A per-file loop was measured
  at >120 s and is not viable.
- **Identity map**: `.mailmap` for the rename folding *and* a checker-side exclusion set for
  `Claude`. Both, because a mailmap has no "drop" form by construction.
- **Waiver**: modelled on `scripts/readme-date-baseline.txt`, not Mathlib's `nolints.json`,
  because the former already implements the stamp-based un-grandfathering the "gate on unreviewed
  candidates" contract needs.
- **Barrel roots**: the import-only-diff rule clears 3 of 4; `FormalSystem/Automation.lean`
  carries a measured 1-line non-import docstring edit and goes to the waiver path. The
  description's "the body is an import list" grounds are measured false (27 / 73 / 79 / 297
  non-import body lines) and must not be reproduced.
- **Reverse pair**: both `RaySummary/` files come from one Tanner commit (`640c44a6`) propagating
  a single rename `Zrel_of_kappa_eq` -> `Zrel.of_kappa_eq`. Below the threshold; waived with
  grounds.
- **Written record**: re-derived at **50** non-`.lean` files (not ~30), **zero** carrying a
  copyright header. The "not an attribution surface" answer stands; the count must be corrected.
- **Route A**: the three deploy-survival preconditions are verified; the reach is measured as
  untracked and working-copy-only (`/.claude` is gitignored at `.gitignore:107`).

### Findings Beyond the Research Report

Two collisions surfaced during plan authoring that the report does not name:

1. **`verify-all.sh` needs a FOURTH edit, not three.** Besides the new invocation, the new
   `report` line, and `expected=11`, the script carries a prose line near its top reading
   "separate hard stops above the **ten** checks below." A plan counting three edits per file
   leaves that sentence wrong. `ci.yml` genuinely needs three (step + `report` line + `expected`).
2. **Route A is a deliberate exception to an auto-applied project rule, and the rule's own
   Exceptions list does not cover it.** `.claude/rules/source-store-deploy-boundary.md` is a
   *target-path* rule forbidding
   hand-authored writes under `.claude/**`, and its narrative's Exceptions list names only
   `specs/**` writes and the deploy process itself. Writing
   `.claude/rules/authorship-attribution.md` therefore violates it on a strict reading and will
   fire the advisory `validate-meta-write.sh` PostToolUse hook (non-blocking, guidance-injecting).
   The grounds for taking the exception anyway are that the rule's *stated hazard* — "silently
   wiped by the next regeneration" — is mechanically neutralized here by the `.syncprotect` entry,
   which research verified against the copy engine's additive-only behavior, `--wipe`'s
   restore-protected-paths step, and `find_orphans`' `protected_paths` exemption. Phase 7 records
   this reasoning in the rule file itself, and orders the `.syncprotect` entry *before* the rule
   file so the file is never momentarily unprotected.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap flag is set; no roadmap
consultation was performed.

## Goals & Non-Goals

**Goals**:
- Record the joint-`Authors:` convention and an explicit attribution **threshold** in tracked
  prose (`docs/development/LEAN_STYLE_GUIDE.md`, pointed to from `CONTRIBUTING.md`).
- Relax `check-copyright-headers.sh`'s continuation-line predicate so Mathlib's real multi-line
  form is accepted, keeping every other constraint.
- Add `.mailmap` as the identity map, and a checker-side exclusion set for `Claude`.
- Add `scripts/check-header-attribution.sh`: a candidate-reporting, baseline-waivable gate with
  the same `--strict` / bucket-list / `--exclude` CLI shape as its sibling.
- Backfill the headers the threshold selects, re-deriving the file list live.
- Wire the new gate as the eleventh check in both `verify-all.sh` and `ci.yml`.
- Implement Route A with its untracked, working-copy-only reach stated in the rule's own text.
- Record a decision on the written-record surfaces and on `CITATION.cff`, and record exactly what
  the "attribution is correct" claim excludes.

**Non-Goals**:
- Route B (a rule under the lean extension's `source_dir`). Out of this task's edit scope by the
  task-siting rule; recorded as a follow-up recommendation in Phase 8, not implemented.
- Editing the 953 clean Benjamin-headed files, beyond the two `RaySummary/` candidates.
- Adding `Tests/` to the CI copyright step (a separate, one-word change with its own denominator
  consequences).
- Regenerating the deployed `.claude/` tree. The dispatch reports the `core` extension as stale;
  this plan does **not** schedule a redeploy, and therefore makes no whole-tree claim.
- Attribution on surfaces that carry no copyright header (`docs/`, `records/`, `README`s). The
  position is recorded; no file is edited.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `%an` -> `%aN` one-character detail is lost in transcription | H | M | Phase 4 runs the `%an` control alongside the real derivation and requires the difference to be demonstrated, not assumed; the script's header comment states the measured false-positive consequence in its own voice |
| The eleventh-gate wiring turns CI red for bookkeeping | H | M | Phase 6 treats all four `verify-all.sh` edits and all three `ci.yml` edits as one atomic change, and runs `bash scripts/verify-all.sh` locally before the phase closes |
| The relaxed continuation predicate loosens the gate more than intended | M | M | Phase 2 relaxes exactly one `case` arm and carries explicit **negative** controls (a trailing-period form and an unclosed block must still fail), not only the positive one |
| A filename-only waiver becomes a permanent blindfold | M | M | Baseline rows are keyed `<path> <identity> <stamp>` with the stamp being the file's current line-4 `Authors:` string, so any later header change un-grandfathers the row |
| `.mailmap` silently changes other tooling's output | M | L | Phase 3 states its criterion as a delta against the pre-phase `verify-all.sh` baseline, not an absolute pass |
| Route A is later believed to be repo-wide | M | M | Phase 7 verifies the gitignore status with `git check-ignore` as a phase criterion and writes the reach limit into the rule file's own text; Phase 8 repeats it in the exclusion list |
| A header edit unexpectedly moves `.lean` line counts and the pre-commit hook blocks the phase | M | L | Phase 5 confirms zero net line delta via `git diff --numstat` as a named criterion, and pre-authorizes the `typst-sync-check.sh --fix` remedy in that same phase if it is nonzero |
| `CITATION.cff` is changed without the owner's consent, or left with no recorded decision at all | H | M | Phase 8 carries a stated default (no change, position recorded) and the question is raised as a non-blocking `user_decision`, so either outcome is a recorded decision |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4, 7 | 3 (for 4), 1 (for 7) |
| 3 | 5 | 1, 2, 4 |
| 4 | 6 | 4, 5 |
| 5 | 8 | 1, 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Record the Convention and Its Threshold [COMPLETED]

**Goal**: The convention and the attribution threshold exist in tracked prose, in the file that
already owns header and docstring requirements, with a pointer from the contribution checklist.

**Tasks**:
- [ ] Add a subsection to `docs/development/LEAN_STYLE_GUIDE.md` §4 "Documentation Requirements"
      (the section begins at line 322) titled for copyright-header authorship. It states:
  - [ ] The form: leave `Copyright (c) YEAR HOLDER. All rights reserved.` untouched; append to
        `Authors:`, comma-separated, **single line** preferred
        (`Authors: Tanner Duve, Benjamin Brast-McKie`); the multi-line continuation form is
        available once a single line grows unwieldy (accepted as of Phase 2).
  - [ ] The **threshold**, stated as two lists. *Earns* an `Authors:` entry: a change that adds,
        removes, or alters a declaration, a proof, a definition, or the substance of a docstring.
        *Does not earn* one: an import-list edit, a mechanical rename or naming-convention
        propagation, a lint or whitespace repair, a typo fix, or a generated-file regeneration.
  - [ ] A pointer to `scripts/check-header-attribution.sh` as the mechanical backstop and to
        `scripts/header-attribution-baseline.txt` as the waiver path, worded so the waiver reads
        as the §10 Lint-Suppression idiom (scoped, never blanket, reason recorded at the site).
- [ ] Extend `CONTRIBUTING.md` §2's existing Style bullet (line 42-43, "every file has a module
      docstring and a copyright header") with one clause on the `Authors:` line and a pointer to
      the style-guide subsection. Extend the sentence; do not add a section.
- [ ] Wrap both edits to the surrounding files' existing line width.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: §4 "Documentation Requirements" begins at `LEAN_STYLE_GUIDE.md:322` and the
Style bullet at `CONTRIBUTING.md:42-43` (both verified live at plan-authoring time). Locate both
anchors by their heading and bullet text rather than by line number — Phase 8 amends the same §4
subsection, so any line number cited here is stale the moment either edit lands.

**Tier Justification**: `readme-lint.sh`'s roots are `FormalSystem BimodalTools BimodalLib`, so
neither `CONTRIBUTING.md` nor `docs/development/LEAN_STYLE_GUIDE.md` is read by any gate in the
check set; the edit is markdown-only and moves no `.lean` line count.

**Files to modify**:
- `docs/development/LEAN_STYLE_GUIDE.md` - new §4 subsection: form, threshold, backstop pointer
- `CONTRIBUTING.md` - §2 Style bullet extended with one clause and a pointer

**Verification**:
- [ ] The threshold's two lists are both present and the "does not earn" list names all six
      excluded classes.
- [ ] `grep -n 'check-header-attribution' docs/development/LEAN_STYLE_GUIDE.md CONTRIBUTING.md`
      shows the pointer resolves to the script path Phase 4 will create.
- [ ] No line in either diff exceeds the file's existing width.

---

### Phase 2: Relax the Continuation-Line Predicate [COMPLETED]

**Goal**: `check-copyright-headers.sh` accepts Mathlib's real multi-line `Authors:` form without
accepting anything else it rejects today.

**Tasks**:
- [ ] Read `scripts/check-copyright-headers.sh`'s header comment in full before touching the
      predicate, as the dispatch directs (it explains the `isInLibraryRoot` blind spots and the
      `grep -cxF` anchoring lesson).
- [ ] Change the arm at line 116 (`case "$ln" in Authors:*|*,) ;; *) ok=0 ;; esac`) so a
      continuation line inside the `Authors:` block need not end in a comma when it is the final
      continuation line. Keep: the line-4 regex at line 110, closure-by-line-12
      (`[ "$closed" = 1 ]` at line 119), the no-trailing-period rule, and the duplicate-block and
      missing-header checks ahead of it.
- [ ] Extend the script's header comment with a short note recording why the arm was relaxed —
      that the previous form was stricter than Mathlib's own `authorsLineChecks` in a direction
      Mathlib does not go, and blocked the multi-line form a third contributor needs.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the predicate's three load-bearing lines are asserted at
`scripts/check-copyright-headers.sh:110` (line-4 regex), `:116` (the continuation `case` arm) and
`:119` (closure assertion), verified live at plan-authoring time. Confirm by `grep -n` on the
construct rather than by line number before editing.

**Tier Justification**: the relaxed predicate has exactly one consumer, `check-copyright-headers.sh`
itself, which this phase invokes directly over all four roots plus scratch positive and negative
controls.

**Files to modify**:
- `scripts/check-copyright-headers.sh` - the continuation-line `case` arm, plus a header-comment
  note recording the reason

**Verification**:
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib`
      exits 0, with the conforming count equal to the denominator it reports (re-derive the
      number live; do not assert a literal 892).
- [ ] `bash scripts/check-copyright-headers.sh --strict Tests` exits 0.
- [ ] Positive control, on a scratch copy outside the tree: Mathlib's real form
      (`Authors: A,` / `  B`, final line with **no** comma) now passes.
- [ ] Negative controls, same scratch copy, each must still **fail**: (a) a line-4 `Authors:` line
      ending in a period; (b) a header block not closed by line 12; (c) a continuation line that
      is neither `Authors:`-prefixed nor comma-terminated nor the final line of the block.

---

### Phase 3: Add `.mailmap` as the Identity Map [COMPLETED]

**Goal**: `git log --format='%aN'` folds the six identity rows to three display names, two of
which match the header strings verbatim, with no lookup code anywhere.

**Tasks**:
- [ ] Run `git shortlog -sne HEAD` and record the live identity rows; do not assume the six rows
      the research report enumerates are still exactly current.
- [ ] Create `.mailmap` at the repository root folding every `benbrastmckie` email and the
      `Benjamin Brast-McKie <64314593+...>` row onto one canonical identity
      `Benjamin Brast-McKie <benjamin@logos-labs.ai>`. Include the fourth, cosmetic row for
      `git shortlog` hygiene even though `--no-merges` means the checker never sees it.
- [ ] Add a comment block at the top of `.mailmap` recording what it is for (header-attribution
      identity folding plus shortlog hygiene) and that it is read automatically by every later
      `git log`/`git shortlog` with no config.
- [ ] Capture `bash scripts/verify-all.sh` output **before** creating the file, to use as the
      delta baseline below.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `.mailmap`'s only in-repo consumer is git itself and, through it,
`readme-lint.sh`'s date derivation, which this phase re-runs as a pre/post baseline delta.

**Files to modify**:
- `.mailmap` - new file: identity-folding rows plus a purpose comment

**Verification**:
- [ ] `git shortlog -sne HEAD` folds to exactly three parties.
- [ ] `git log --no-merges --format='%aN' | sort -u` yields exactly
      `Benjamin Brast-McKie`, `Claude`, `Tanner Duve`.
- [ ] Control recorded: `git log --no-merges --format='%an' | sort -u` still yields the unfolded
      names, demonstrating the `%an`/`%aN` difference live rather than carrying it from research.
- [ ] `bash scripts/verify-all.sh` shows **no new FAIL** relative to the baseline captured in the
      first task (a delta, not an absolute pass — the repo-wide baseline is a moving quantity).

---

### Phase 4: The Attribution Check Script and Its Baseline [COMPLETED]

**Goal**: A new gate exists that reports attribution **candidates**, folds identities via
`.mailmap`, excludes non-contributor identities, applies the import-only-diff pre-filter, and
gates its exit status on candidates absent from a stamped baseline.

**Tasks**:
- [ ] Create `scripts/check-header-attribution.sh` with the **same CLI shape** as its sibling:
      `[--strict] [--exclude GLOB | --exclude=GLOB]... [ROOT ...]`, `ROOTS=("FormalSystem")`
      default with the hazard documented in the header comment, bucket lists written to
      `$OUTDIR` (default `mktemp -d`, path echoed), `set -uo pipefail`.
- [ ] Derivation: ONE `git log --no-merges --format='<sentinel>%x09%aN' --name-only` pass over the
      roots' `*.lean` paths. Use **`%aN`, never `%an`**. State in the header comment, in the
      voice the sibling script uses for its `grep -cxF` lesson, that `%an` is mailmap-blind on
      git 2.54.0, that `--use-mailmap` does not rescue it, and that getting it wrong flags
      essentially every headed file.
- [ ] Exclusion set: a checker-side constant containing `Claude`. Record beside it: that
      `.mailmap` has no "drop" form so this cannot live there; the trailer survey grounds (every
      distinct `Co-Authored-By` value is a Claude model variant or `OpenCode`, none naming a human
      third party); and the **stated limit** that a future human co-author added only by trailer
      would be missed, because `%aN` does not surface trailers.
- [ ] Import-only-diff pre-filter: a committer whose entire `+/-` footprint on a file, across all
      that committer's commits on it, consists of `import` lines does not earn attribution. Prefer
      this rule over any enumerated filename list.
- [ ] Waiver: read `scripts/header-attribution-baseline.txt`, rows `<path> <waived-identity>
      <stamp>` where `<stamp>` is the file's line-4 `Authors:` string at review time. A row
      grandfathers a candidate only while the stamp matches exactly, so any later header change
      un-grandfathers it. Model the format comment on `scripts/readme-date-baseline.txt`'s.
- [ ] Output wording: every finding is a **candidate**, never a verdict. The script's own header
      comment states the precision limit — `%aN` cannot distinguish a merger from an editor, so
      the per-file threshold judgment settles each candidate.
- [ ] Exit status: under `--strict`, exit 1 **only** on candidates absent from the baseline; a
      reviewed-and-waived candidate must not keep the gate red. Without `--strict`, report and
      exit 0.
- [ ] Create `scripts/header-attribution-baseline.txt` with its format comment and, for now, zero
      rows (Phase 5 adds the reviewed rows).
- [ ] Do **not** pass an `--exclude '*/Boneyard/*'` default: `Boneyard/` is a top-level directory
      outside all four roots and matches nothing under them.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: the script is not yet wired into `verify-all.sh` or `ci.yml` (Phase 6 does
that), so its only consumer in this phase is its own direct invocation over all four roots.

**Scope Hypothesis**: research's prototype measured **30** candidates (24 forward + 6 reverse) out
of 1007 headed files with zero false positives. Treat both the 30 and the 1007 as hypotheses: the
implementer runs the finished script over all four roots and records the **live** candidate list
and denominator, then compares against research's enumerated 30 and explains any difference. The
count moves as commits land; do not hard-code it anywhere in the script or its criteria.

**Files to modify**:
- `scripts/check-header-attribution.sh` - new gate script
- `scripts/header-attribution-baseline.txt` - new waiver baseline, format comment, zero rows

**Verification**:
- [ ] `bash scripts/check-header-attribution.sh FormalSystem Tests BimodalTools BimodalLib`
      reports a candidate list; record it verbatim as the live-derived set.
- [ ] The clean count plus the candidate count equals the live headed-file denominator, and every
      file in the clean set is genuinely clean — spot-check at least five, including one
      Tanner-headed file with no second committer.
- [ ] Zero false positives: no file whose line-4 `Authors:` already names every non-excluded
      committer appears as a candidate.
- [ ] `--strict` over all four roots exits **1** at this point. That is the correct, expected
      state pre-backfill, not a failure of the phase.
- [ ] A control run with `%an` substituted for `%aN` flags dramatically more files, demonstrating
      the difference on this tree.
- [ ] The import-only pre-filter clears at least the three barrel roots research measured at zero
      non-import lines (`FormalSystem/Semantics.lean`, `FormalSystem/Theorems.lean`,
      `Tests/BimodalTest.lean`); `FormalSystem/Automation.lean` is expected to survive it.
- [ ] Runtime is seconds, not minutes (research measured 0.8 s); if a per-file `git log` loop
      crept in, this criterion catches it.

---

### Phase 5: Backfill the Selected Headers and Record the Waivers [COMPLETED]

**Goal**: Every live candidate is resolved — either backfilled with a joint `Authors:` line or
recorded as a reviewed baseline row with its grounds — and both header gates are green.

**Tasks**:
- [ ] Re-derive the candidate list live with Phase 4's script. Do **not** operate from the
      research report's enumerated 30 or the description's 24.
- [ ] For each forward candidate (header `Authors: Tanner Duve`, missing `Benjamin Brast-McKie`):
      judge it against Phase 1's threshold individually, then rewrite line 4 in place to the
      single-line joint form `Authors: Tanner Duve, Benjamin Brast-McKie`. No blind `sed` over the
      whole set; each file is judged.
- [ ] Reverse pair: judge `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` and
      `.../LadderStepFrag.lean` against the threshold. Research's measured grounds — one Tanner
      commit `640c44a6` whose whole footprint is those two files at 1 and 8 lines, propagating the
      single rename `Zrel_of_kappa_eq` -> `Zrel.of_kappa_eq` through one signature and several
      docstrings — place both in the mechanical-naming-fix class the threshold excludes. Confirm
      that measurement live (`git show --format='' --numstat 640c44a6 -- <both files>`), then
      waive both as baseline rows with that reason recorded.
- [ ] Barrel roots: confirm the import-only pre-filter cleared three of the four, and add
      `FormalSystem/Automation.lean` as one reviewed baseline row whose recorded reason is its
      measured single non-import line (a docstring reference added in the same commit as the
      import). Do **not** record the exclusion as "the body is an import list" — that is measured
      false (27 / 73 / 79 / 297 non-import body lines across the four roots).
- [ ] Write every waiver row into `scripts/header-attribution-baseline.txt` in the
      `<path> <identity> <stamp>` form, with the per-row reason as a preceding comment line.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 4

**Verification Tier**: interface

**Tier Justification**: the header space these edits touch is read by two independent gates —
`check-copyright-headers.sh`'s shell predicate and Mathlib's `linter.style.header` under
`lake build --wfail` — so a single-script check cannot cover the edit.

**Scope Hypothesis**: the backfill is asserted to be a pure same-line substitution with **zero**
net `.lean` line delta, which is why no generated surface is declared as modified below. Confirm
with `git diff --numstat -- '*.lean'`: every touched file must show equal additions and deletions.
If any net delta is nonzero, the `.githooks/pre-commit` hook will block this phase's commit on
`typst/generated/status.typ` drift, and the implementer runs
`lake build && bash scripts/typst-sync-check.sh --fix && git add typst/generated/status.typ`
**within this phase** before committing. The candidate count itself is also a hypothesis — see
Phase 4's.

**Files to modify**:
- The `.lean` files under `FormalSystem/` and `Tests/` that the live candidate list and the
  threshold select (research enumerated 24 forward candidates; re-derived here) - line 4 rewritten
  to the single-line joint `Authors:` form
- `scripts/header-attribution-baseline.txt` - reviewed waiver rows for the two `RaySummary/` files
  and `FormalSystem/Automation.lean`, each with its grounds
- `typst/generated/status.typ` - **conditional**: declared only against the Scope Hypothesis above
  failing. Not expected to change, because a same-line substitution moves no line count; carried
  in scope so the hook's remedy is pre-authorized in this phase rather than deferred

**Verification**:
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib`
      exits 0, and `--strict Tests` exits 0.
- [ ] `bash scripts/check-header-attribution.sh --strict FormalSystem Tests BimodalTools BimodalLib`
      exits **0**: zero unreviewed candidates.
- [ ] Every joint `Authors:` line is a single line and contains no trailing period.
- [ ] `lake build` is green (this is the Mathlib `linter.style.header` check; CI builds with
      `--wfail`, so a warning here is a failure).
- [ ] `git diff --numstat -- '*.lean'` shows equal additions and deletions on every touched file.
- [ ] Each baseline row's recorded reason names a measurement, not a category label.

---

### Phase 6: Wire the Eleventh Gate [COMPLETED]

**Goal**: The new check runs in both the local verification script and CI, with both `expected=N`
assertions in sync and the script catalogued.

**Tasks**:
- [ ] Capture `bash scripts/verify-all.sh` output as the pre-phase baseline before editing.
- [ ] `scripts/verify-all.sh` — **four** edits, treated as one atomic change:
  - [ ] a new numbered check block invoking
        `bash scripts/check-header-attribution.sh --strict FormalSystem BimodalTools BimodalLib`,
        matching the existing blocks' `rc=0; ... || rc=$?` shape and carrying the
        `ci.yml step:` cross-reference comment the sibling blocks carry;
  - [ ] a new `report "check-header-attribution.sh --strict" "$rc"` line;
  - [ ] `expected=10` -> `expected=11` at line 34;
  - [ ] the prose line near the top reading "hard stops above the **ten** checks below" updated to
        eleven. (This fourth edit is the one a three-edit count misses.)
- [ ] `.github/workflows/ci.yml` — three edits, same atomic change:
  - [ ] a new step placed beside the copyright-headers step (line 182), with its own `id:`,
        `continue-on-error: true`, `if: ${{ !cancelled() }}`, `set -euo pipefail`, and the
        `::group::` echo wrapper the sibling steps use; name the roots explicitly and carry the
        same comment the sibling steps carry about the `ROOTS=("FormalSystem")` default;
  - [ ] a new `report` line in the "Report results" step, column-aligned with its siblings;
  - [ ] `expected=10` -> `expected=11` at line 350.
- [ ] `scripts/README.md`: one row for `check-header-attribution.sh` in the script table beside
      `check-copyright-headers.sh` (line 16), and one row for
      `header-attribution-baseline.txt` in the companion-data table beside
      `readme-date-baseline.txt` (line ~184).

**Timing**: 1 hour

**Depends on**: 4, 5

**Verification Tier**: interface

**Scope Hypothesis**: both files are asserted to carry `expected=10` with exactly 10 `report`
lines each (`scripts/verify-all.sh:34`, `.github/workflows/ci.yml:350`, and the copyright step at
`ci.yml:182`) — all verified live at plan-authoring time. Re-confirm each with `grep -n` before
editing: inserting the new CI step shifts every later line number in `ci.yml`, so the `expected=`
line must be found by pattern, never by the number quoted here. If either file's `expected` value
is already not 10, a concurrent change landed and the new value is the one to bump.

**Tier Justification**: the `expected=N` assertion is duplicated across `scripts/verify-all.sh`
and `.github/workflows/ci.yml` and fails independently in either on a count mismatch, so both
files' assertions must be exercised in the same check.

**Files to modify**:
- `scripts/verify-all.sh` - new check block, new `report` line, `expected=11`, "ten" -> "eleven"
- `.github/workflows/ci.yml` - new step with `id:`, new `report` line, `expected=11`
- `scripts/README.md` - one script-table row, one data-file-table row

**Verification**:
- [ ] `bash scripts/verify-all.sh` reports exactly 11 check outcomes with **no** "reported N
      check outcomes but expected M" error, and no new FAIL relative to the baseline captured in
      the first task (a delta against the baseline, not an absolute pass).
- [ ] `grep -c '^          report ' .github/workflows/ci.yml` equals 11 and
      `grep -n 'expected=' .github/workflows/ci.yml` shows `expected=11`.
- [ ] `python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/ci.yml'))"` parses
      cleanly, and the new step's `id:` matches the identifier its `report` line interpolates.
- [ ] Both new `scripts/README.md` rows render as valid table rows with the same column count as
      their neighbours.

---

### Phase 7: Route A — The Repo-Local Agent Rule [COMPLETED]

**Goal**: The convention reaches an agent's context mid-dispatch in this working copy, protected
from regeneration, with its reach and its boundary-rule exception both stated in its own text.

**Tasks**:
- [ ] **First**, add `rules/authorship-attribution.md` to `.syncprotect` (paths there are relative
      to the sync base directory, so no `.claude/` prefix), beside the existing
      `context/repo/project-overview.md` entry and with a comment giving the grounds. Doing this
      before creating the rule file means the file is never momentarily unprotected.
- [ ] Create `.claude/rules/authorship-attribution.md` with YAML frontmatter
      `paths: "**/*.lean"` — the same glob `.claude/rules/lean4.md` already carries, confirmed by
      reading that file rather than assumed. Content:
  - [ ] the convention and the threshold, pointing at
        `docs/development/LEAN_STYLE_GUIDE.md` §4 as the tracked source of truth rather than
        restating it at length;
  - [ ] the single-line joint form, with an example;
  - [ ] a pointer to `scripts/check-header-attribution.sh` and the baseline waiver path;
  - [ ] an explicit **reach** statement: `/.claude` is gitignored in this repository, so this file
        is untracked and reaches agent dispatches in this working copy only — not a clone, not
        CI, not a collaborator. The convention's durable homes are the style guide and the gate.
  - [ ] an explicit **exception** note recording why hand-authoring under `.claude/**` is
        warranted here against `.claude/rules/source-store-deploy-boundary.md`: that rule's stated
        hazard is a silent wipe on regeneration, and the `.syncprotect` entry neutralizes it
        mechanically — the copy engine is additive-only and deletes nothing, `--wipe` restores
        `.syncprotect`-listed paths, and `find_orphans` exempts them from both presence and hash
        checks. Note that the advisory `validate-meta-write.sh` PostToolUse hook will fire on this
        write; that is expected, not a failure.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: neither file is read by any gate in the check set — `/.claude` is
gitignored and `.syncprotect` is consumed only by the deploy engine — so this phase's own
`check-ignore` probe and frontmatter comparison are its complete coverage.

**Files to modify**:
- `.syncprotect` - one new entry `rules/authorship-attribution.md` with grounds comment
- `.claude/rules/authorship-attribution.md` - new repo-local rule, `paths: "**/*.lean"`.
  **Three advisory signals are expected on this entry and are not defects**: (i)
  `validate-artifact.sh` warns that a `.claude/**` path "is never a legitimate file_scope member"
  and suggests the `__WHOLE_TREE__` sentinel — **do not** substitute that sentinel, which would
  falsely claim a whole-deployed-tree regeneration this phase does not perform and would
  needlessly serialize this task against any task that does; (ii) the advisory
  `validate-meta-write.sh` PostToolUse hook fires on the write; (iii) the write is a deliberate,
  grounds-recorded exception to `source-store-deploy-boundary.md`, per the task above. Taken
  together these are four independent signals that the system discourages this route; the
  durable route is Route B, recorded as a follow-up in Phase 8, and Route A is a stopgap that
  buys mid-dispatch agent-context reach in this working copy only

**Verification**:
- [ ] `git check-ignore -v .claude/rules/authorship-attribution.md` returns the `/.claude`
      gitignore line, confirming the untracked reach the rule file claims (verified, not assumed).
- [ ] `grep -n 'rules/authorship-attribution.md' .syncprotect` matches, and the entry carries no
      `.claude/` prefix.
- [ ] The new file's `paths:` frontmatter value is byte-identical to `.claude/rules/lean4.md`'s.
- [ ] Both the reach statement and the boundary-exception note are present in the file's text.

---

### Phase 8: Record the Residual Claim and Run the Gate Set [COMPLETED]

**Goal**: Every open position carries a recorded decision, the "attribution is correct" claim is
either true or accompanied by its exclusion list, and the touched surfaces are green.

**Tasks**:
- [ ] Amend Phase 1's style-guide subsection with a short **scope** paragraph recording, as
      decisions rather than caveats:
  - [ ] **The written-record surfaces are not an attribution surface this repository tracks.**
        Grounds: they carry no copyright header by convention, so there is no `Authors:` line to
        repair, and git history is their record. Re-derive the count live
        (`git log --no-merges --author='Tanner Duve' --name-only`, non-`.lean` paths) and record
        the live number plus the measured fact that none of them carries a header. Research
        re-derived **50**, correcting the description's ~30; record the live figure, not either
        carried one. Note the two independent narrowings: `specs/**` is the unmaintained
        development record per `CONTRIBUTING.md` §3, and `typst/generated/status.typ` is
        generated.
  - [ ] **The barrel-root exclusion**, recorded as reasoned: the import-only-diff rule, with
        `FormalSystem/Automation.lean`'s measured one-line residue handled by a baseline row —
        and explicitly **not** the measured-false "the body is an import list" grounds.
  - [ ] **The precision limit**: the gate reports candidates, never verdicts, because `%aN`
        cannot distinguish a merger from a material editor; the threshold settles each one.
  - [ ] **The exclusion list** behind any claim that attribution is correct repository-wide:
        (i) headerless surfaces per the decision above; (ii) `CITATION.cff` per the decision
        below; (iii) Route A's untracked, working-copy-only reach; (iv) co-authors contributed
        only by `Co-Authored-By` trailer, which `%aN` does not surface; (v) `Boneyard/` and
        generated files.
- [ ] **`CITATION.cff`**: apply the user's answer if one was given. Absent an answer, apply the
      stated default — leave the `authors:` list unchanged and record, in the same style-guide
      paragraph, that the top-level `authors:` list names the authors of the **software** as a
      published work (distinct from the `references:` paper-author list), that whether a
      substantial code contributor belongs there carries citation-tooling and academic-credit
      consequences outside the repository, and that it is therefore the repository owner's call
      rather than a threshold question. This is a recorded decision either way; flagged as a
      non-blocking `user_decision` on `.return-meta.json`.
- [ ] Record the **Route B follow-up** as a recommendation in the summary: a rule under the lean
      extension's `source_dir` stating the generic, name-free principle, filed as its own task in
      the repository whose filesystem holds that `source_dir`. Do not edit across the boundary
      from here.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Scope Hypothesis**: the headerless non-`.lean` surface is asserted at **50** files, none
carrying a copyright header (research's re-derivation, correcting the description's ~30). This is
a hypothesis, not a figure to transcribe: the implementer re-derives it live and records the live
number, together with the measured header-absence check, in the style-guide paragraph. The
`CITATION.cff` top-level `authors:` list is asserted to hold exactly one entry
(`Brast-McKie, Benjamin`), verified live at plan-authoring time; re-read the file before any edit.

**Files to modify**:
- `docs/development/LEAN_STYLE_GUIDE.md` - scope paragraph: the four recorded decisions and the
  exclusion list
- `CITATION.cff` - **conditional**: edited only if the user's answer is to add a contributor;
  unchanged under the stated default

**Verification**:
- [ ] Scoped touched-path check: `bash scripts/check-copyright-headers.sh --strict FormalSystem
      BimodalTools BimodalLib` and `--strict Tests` both exit 0;
      `bash scripts/check-header-attribution.sh --strict FormalSystem Tests BimodalTools
      BimodalLib` exits 0; `bash scripts/verify-all.sh` reports 11 outcomes with no out-of-sync
      error and no new FAIL relative to the pre-task baseline; `lake build` green.
- [ ] Every item in the "DONE WHEN" list has a locatable home: the convention and threshold in
      §4; the gate wired in both files; the backfill green under both header gates; the identity
      map present with its exclusion set; the gate exiting on unreviewed candidates only; both
      `RaySummary/` judgments and the barrel-root exclusion recorded with grounds; the
      written-record and `CITATION.cff` decisions recorded.
- [ ] Under `/orchestrate`, the complete gate battery is **deferred to the orchestration close**
      (Move 4) rather than invoked independently as this phase's own criterion. A standalone,
      non-orchestrated run of this phase instead runs the complete set directly.

#### Scoped Discharge Record (batch-gate deferral)

This dispatch ran under a multi-task `/orchestrate` batch, so the `full` tier above was
discharged against the dispatch's sanctioned narrowing, `bash .claude/scripts/verify-touched.sh`
(no arguments). The complete gate set was **deferred to the batch stage, not independently run**.

What the scoped run reported: 197 touched paths resolved; the selected-suite phase ran 142 suites
(117 passed, 15 failed - 2 expected, 13 new), the OWED fallback phase 95 suites (84 passed, 1
failed). Every failing suite is an agent-system deploy/routing/orchestrate test, and this
dispatch's own context declared the deployed `core` extension STALE relative to the source store.
Two failures name that divergence in their own assertion text (`test-routing-resolution.sh`:
`lean4` resolving to `general-research-agent` instead of `lean-research-agent`;
`test-source-store-path-lib.sh`: a repo-root path classified `SOURCE_STORE core`), and
`test-deploy-baseline-lib.sh`'s single failure is a gate-1 warm-cache control. None of them reads
a file this task changed.

Falsifiable counter-check, recorded rather than asserted: every suite that DOES read this task's
touched surfaces passed - `test-script-inventory.sh` (the new `scripts/README.md` rows),
`test-deploy-orphans.sh` (the `.syncprotect` protected-path behaviour),
`test-check-task-references.sh`, `test-check-record-versioning.sh`,
`test-lint-scoped-commit-boundary.sh`, `test-deploy-propagation.sh`, `test-git-commit-scoped.sh`.
`test-manifest-scripts-sync.sh` SKIPPED.

Independently of the narrowing, the task's own gates were run directly and are green:
`check-copyright-headers.sh --strict` over both root sets (exit 0, 892/892 and 115/115),
`check-header-attribution.sh --strict` over all four roots (exit 0, 997 clean / 10 waived / 0
unreviewed), `scripts/verify-all.sh` reporting 11 outcomes with no out-of-sync error and no new
FAIL against the pre-task baseline, and `lake build` plus `lake build BimodalTest` both green
(0 errors, 0 warnings).

---

## Testing & Validation

- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem BimodalTools BimodalLib`
      exits 0 with the live denominator fully conforming.
- [ ] `bash scripts/check-copyright-headers.sh --strict Tests` exits 0.
- [ ] `bash scripts/check-header-attribution.sh --strict FormalSystem Tests BimodalTools BimodalLib`
      exits 0 with zero unreviewed candidates and zero false positives.
- [ ] Negative controls from Phase 2 still fail (trailing period; unclosed block; a continuation
      line that is neither the final line nor comma-terminated).
- [ ] `bash scripts/verify-all.sh` reports 11 outcomes, no out-of-sync error, no new FAIL against
      the pre-task baseline.
- [ ] `lake build` green (Mathlib `linter.style.header` under the CI `--wfail` posture).
- [ ] `git diff --numstat -- '*.lean'` shows zero net line delta across the backfill.
- [ ] `git check-ignore -v .claude/rules/authorship-attribution.md` confirms the rule file's
      stated reach.

## Artifacts & Outputs

- `docs/development/LEAN_STYLE_GUIDE.md` §4 subsection: convention, threshold, scope paragraph,
  exclusion list
- `CONTRIBUTING.md` §2 Style bullet, extended with a pointer
- `scripts/check-copyright-headers.sh` with the relaxed continuation arm and its reason recorded
- `.mailmap`
- `scripts/check-header-attribution.sh` (new eleventh gate)
- `scripts/header-attribution-baseline.txt` (new, with reviewed waiver rows)
- Backfilled `Authors:` lines on the `.lean` files the threshold selects
- `scripts/verify-all.sh`, `.github/workflows/ci.yml`, `scripts/README.md` wiring
- `.syncprotect` entry and `.claude/rules/authorship-attribution.md` (Route A)
- `CITATION.cff`, conditionally, per the recorded decision
- Recorded follow-up: a Route B task, to be filed in the repository holding the lean extension's
  `source_dir`

## Rollback/Contingency

The work is additive and file-local, with no state migration and no Lean proof obligation, so
rollback is per-phase rather than wholesale.

- Phases 1, 7, 8 are prose/config: revert the named files.
- Phase 2: restore the single `case` arm. The pre-relaxation predicate was green on the live tree,
  so reverting it cannot turn the gate red; the backfill uses the single-line form and does not
  depend on the relaxation.
- Phase 3: delete `.mailmap`. Nothing else reads it except the new gate, which fails loudly rather
  than silently without it.
- Phase 4: delete the two new `scripts/` files. Nothing references them until Phase 6 wires them.
- Phase 5: the header edits are one-line substitutions; `git checkout` of the listed `.lean` paths
  restores them. Before any destructive revert on a dirty tree, run
  `bash .claude/scripts/git-snapshot.sh 996` first.
- Phase 6 is the highest-risk rollback because a half-reverted wiring trips the `expected=N`
  assertion in either file. Revert all four `verify-all.sh` edits and all three `ci.yml` edits
  together, then confirm with `bash scripts/verify-all.sh` reporting 10 outcomes cleanly.
