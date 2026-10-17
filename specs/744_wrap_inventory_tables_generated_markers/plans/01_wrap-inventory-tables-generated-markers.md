# Implementation Plan: Task #744

- **Task**: 744 - Wrap the RaySummary and KTypeSummary inventory tables in BEGIN GENERATED markers so their module line counts cannot drift again
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/744_wrap_inventory_tables_generated_markers/reports/01_wrap-inventory-tables-generated-markers.md
- **Artifacts**: plans/01_wrap-inventory-tables-generated-markers.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

The two named READMEs carry hand-maintained inventory tables that `check-module-invariants.sh`'s
INV check cannot see, because INV only inspects `<!-- BEGIN GENERATED: inventory ... -->` blocks
and `<!-- INVENTORY: hand-maintained -->` registrations. The fix is opt-in: wrap each table in the
markers and let the existing `--emit-inventory` writer own every column except the hand-written
trailing description. Research verified on scratch copies that this preserves KTypeSummary's six
descriptions byte-for-byte but truncates three RaySummary descriptions at GFM-escaped `\|`
pipes, because `split_row` splits on every raw `|`. The settled decision (`.decisions.json`,
Option B) is a one-line escape-aware split in the generator, so that change lands first and the
wrap follows. A sweep then wraps the other unwrapped tables whose column set fits the default
`| File | Lines | Description |` shape and reports the rest, and a deliberate-corruption check
demonstrates that INV now names every newly wrapped README when a count drifts.

Regeneration is targeted throughout: a bare `--emit-inventory` rewrites every stale block in the
tree, and three whole-tree rollup READMEs (`README.md`, `FormalSystem/README.md`,
`FormalSystem/Metalogic/README.md`) are INV-red at HEAD and belong to concurrent sibling task
812's declared `file_scope`. Every phase that runs the writer follows the targeted-regeneration
procedure in Phase 2 and never stages those three files.

### Research Integration

- Generator behaviour (report §1): marker grammar, `render_block`'s description carry-over keyed
  by file name, silent drop of rows whose file no longer exists, alphabetical re-ordering,
  `{:,}` thousands separators. The plan accepts order and number-format changes (report D2).
- Scratch-copy simulation (report §3): KTypeSummary 6/6 preserved; RaySummary 13/16 preserved
  as-is, 16/16 with `re.split(r"(?<!\\)\|", body)` in `split_row`. Phase 1 lands that change.
- Tree sweep (report §4): 24 Tier-A candidates, 8 Tier-B, Tier-C report-only. Phases 4-5 wrap
  Tier A minus two files this plan demotes (see Phase 4's Scope Hypothesis); Tier B and C are
  reported in the summary, never hand-corrected (report D5, task NON-GOALS).
- Territory hazard (report §7, D3): the whole-tree writer would edit sibling 812's three rollup
  files. Phase 2 defines the targeted-regeneration procedure every later phase reuses.
- Task 731 (report §5) is complete and discovers generated blocks at run time; nothing to edit.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted (no `roadmap_path` in the dispatch context).

## Goals & Non-Goals

**Goals**:
- Both named tables are generated blocks whose counts INV checks on every CI run.
- Every existing hand-written description in a wrapped table survives byte-for-byte, including
  the three RaySummary cells containing `\|`.
- Every other unwrapped inventory table under `FormalSystem/` whose shape fits the default
  column set is wrapped the same way; the rest are reported with the reason they were left.
- INV is demonstrated, not assumed, to fail on a corrupted count in each newly wrapped block.
- No file outside this task's territory is modified or staged.

**Non-Goals**:
- No change to the generator's column set, row algorithm, sort options, or output format beyond
  the single escape-aware `split_row` line (the settled deviation from the record's NON-GOAL).
- No change to any `.lean` source.
- No hand-correction of counts in any table this task leaves unwrapped; those are reported.
- No wrapping of a table with phantom rows (rows naming files that no longer exist) or with a
  shape the default column set cannot render without information loss — those are Tier B and
  go to the report.
- No edit to the three whole-tree rollup READMEs in sibling 812's `file_scope`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A description is silently truncated or dropped on regeneration (`\|` cells, phantom rows, `len(cells) < ncols` rows) | H | M | Phase 1 lands the escape-aware split before any wrap; every wrap phase runs the key-wise before/after description diff from Phase 2 and refuses to commit a block with any non-identical description |
| Bare `--emit-inventory` rewrites sibling 812's three stale rollup READMEs | H | H | Targeted-regeneration procedure (Phase 2): precondition check that the three files are clean, `--no-revert` snapshot, writer, then pathspec restore of exactly those three; explicit-path staging only; stop and report if any of them is foreign-modified |
| INV exit code is red for reasons outside this task while 812's files remain stale | M | H | Coverage evidence is the FAIL output's named-file list, never the exit code; the summary states this explicitly |
| Report line numbers shift under concurrent commits | L | M | Locate every table by its `| File | Lines | Description |` header line, re-read each file immediately before editing |
| Alphabetical re-ordering reads as a regression in a layering-ordered table | L | M | Accepted per report D2; descriptions carry their own layer labels (`B1`, `Step 1′`, `Requirement (C)`); note in summary |
| A Tier-A table turns out to have a phantom row, a `\|` cell, or numeric subdir totals on re-check | M | M | Phases 4-5 re-run the fit check per table before wrapping and demote any failing table to the report rather than forcing it |
| Newly wrapped blocks make sibling `.lean` edits in those directories turn INV red | M | M | Intended end state; the summary lists every newly generated surface so later dispatches know to regenerate |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are serialized: every phase after 2 runs the whole-tree writer, and two writer runs on the
same working tree cannot be interleaved with the foreign-file restore step without racing. No
two phases execute in parallel.

### Phase 1: Escape-aware cell splitting in the generator [COMPLETED]

**Goal**: Make `split_row` in `scripts/check-module-invariants.sh` treat a GFM-escaped `\|` as
cell content rather than a cell boundary, so a wrapped table's hand-written descriptions survive
regeneration regardless of inline Lean notation.

**Tasks**:
- [x] Re-read `scripts/check-module-invariants.sh` around `def split_row` (report cites lines
  331-338; locate by the `def split_row(line):` anchor). Replace `body.split("|")` with
  `re.split(r"(?<!\\)\|", body)`; `re` is already imported at the top of the heredoc. Change no
  other line of the generator. *(completed)*
- [x] In the `--emit-inventory` header comment, extend the sentence beginning "The trailing
  column is HAND-WRITTEN and survives regeneration" with one clause stating that a
  GFM-escaped `\|` inside a cell is preserved (it is not a cell boundary). No task numbers. *(completed)*
- [x] In `docs/reference/readme-standard.md`'s "Generating the table" paragraph, add one
  sentence: an inline `|` in a description must be written `\|`, and the generator preserves
  it. No task numbers. *(completed)*
- [x] Verify the change does not alter any existing block: run
  `bash scripts/check-module-invariants.sh --emit-inventory --check` before and after the edit
  and confirm the two outputs name the same stale files (expected: exactly the three rollup
  READMEs, or fewer if sibling 812 has regenerated them by then) — no block that was current
  becomes stale and no new file appears in the list. *(completed: PASS INV before and after — stale list empty both times, sibling 812 had already regenerated the rollup READMEs)*
- [x] Verify the escape case directly: on a scratch copy of
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` under the session scratchpad,
  extract the 16 description cells with the new `split_row` (a three-line Python snippet
  importing nothing from the tree) and confirm the three cells for `HitComplete.lean`,
  `AnchorLayer.lean`, `LadderModel.lean` contain their `\|` fragments intact. *(completed: 16 rows, three `\|` cells whole)*
- [x] Commit `scripts/check-module-invariants.sh` and `docs/reference/readme-standard.md` by
  explicit path. *(completed: phase-closing commit via git-commit-phase.sh)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check`
before/after the edit, with identical stale-file lists, exercises the only modified function
across every existing generated block in the tree; the script belongs to this consumer repo and
maps to no agent-system suite (`__FULL_SWEEP__`), so the covering check is the gate script
itself.

**Files to modify**:
- `scripts/check-module-invariants.sh` - one-line `split_row` change plus a one-clause header
  comment note
- `docs/reference/readme-standard.md` - one sentence in "Generating the table"

**Verification**:
- `grep -n 're.split(r"(?<!\\\\)\\|", body)' scripts/check-module-invariants.sh` finds exactly
  one line; `grep -c 'body.split("|")'` finds zero
- `--emit-inventory --check` stale-file list unchanged by the edit
- Scratch extraction shows all three `\|` descriptions whole

---

### Phase 2: Wrap RaySummary and KTypeSummary with targeted regeneration [NOT STARTED]

**Goal**: Convert the two named tables into generated blocks, regenerate them without touching
any file outside this task's territory, and prove every description survived byte-for-byte.

**Tasks**:
- [ ] Record the pre-wrap state. Write a small scratchpad script `desc-snapshot.py` that, given
  a README path and the `| File | Lines | Description |` header line, emits one line per row as
  `key<TAB>description` using the Phase 1 escape-aware split and `row_key` semantics (strip
  backticks and link labels). Run it on both READMEs and save the output; expect 16 rows for
  RaySummary and 6 for KTypeSummary (re-derived at plan time from the current files).
- [ ] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/README.md`. Insert
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Decidability/RaySummary -->` on
  the line immediately above the `| File | Lines | Description |` header under "What it holds"
  and `<!-- END GENERATED -->` on the line immediately after the last `.lean` row
  (`LadderModel.lean`). The Requirements table further down (its own `\|` cell included) must
  stay outside the markers.
- [ ] Re-read `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md`. Insert
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical/KTypeSummary -->`
  above the `| File | Lines | Description |` header under "Modules" and `<!-- END GENERATED -->`
  after the `KTypeFin.lean` row. Default options suffice for both (no subdirectories).
- [ ] Targeted regeneration procedure (reused verbatim by Phases 4-6):
  1. Precondition: `git status --porcelain -- README.md FormalSystem/README.md FormalSystem/Metalogic/README.md`
     is empty. If it is not, STOP: a sibling has an in-flight edit; check `git log` to confirm
     it is not this task's own, report it, and fall back to the out-of-tree method (extract the
     generator's Python heredoc verbatim into the scratchpad, override only the
     `for target in markdown_targets():` loop with an explicit path list, run it from the repo
     root so `dir=` resolves). Never discard a foreign modification.
  2. `bash .claude/scripts/git-snapshot.sh --no-revert 744` (durable checkpoint, tree untouched).
  3. `bash scripts/check-module-invariants.sh --emit-inventory` (the writer). It rewrites this
     task's blocks and, while they remain stale, the three rollup READMEs.
  4. `git checkout -- README.md FormalSystem/README.md FormalSystem/Metalogic/README.md`
     restores exactly those three files to HEAD (pathspec form, permitted after the snapshot;
     the only content discarded is the writer's own output from step 3, by the step 1
     precondition). Confirm with `git status --porcelain` that the only modified non-`specs/`
     paths are this task's own.
- [ ] Post-wrap diff: re-run `desc-snapshot.py` on both READMEs and `diff` against the saved
  pre-wrap output after sorting both by key. Required result: zero differences (16 + 6
  descriptions byte-identical). Then `git diff -- <the two READMEs>` and confirm every other
  changed hunk is one of: the two marker lines, a refreshed count (expected on `AnchorLayer`,
  `Profile`, `Periodic`; re-derive with `wc -l` rather than trusting this list), a thousands
  separator (`1,627`, `1,004`), or a row moved by alphabetical ordering. Any other change is a
  stop condition.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check`: neither README appears
  in the stale-file list.
- [ ] Commit the two READMEs by explicit path: `git add -- FormalSystem/Metalogic/Decidability/RaySummary/README.md FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check` plus
the key-wise description diff cover the two edited READMEs completely (markdown with no compile
surface; the only machine consumer of the edit is the generator itself), and
`bash .claude/scripts/verify-deploy.sh --only-gate 4` (task-reference lint) covers the
deploy-consumer markdown path per plan-format.md's sub-case (c).

**Scope Hypothesis**: RaySummary's table has 16 rows and 4 lines containing `\|` in the whole
file (3 in the inventory table, 1 in the Requirements table), KTypeSummary's has 6 rows, and
exactly three RaySummary counts are stale (`AnchorLayer` 406→418, `Profile` 578→581, `Periodic`
1624→1627) — row counts re-derived at plan time by `grep`; the stale-count triple is
CARRIED-UNVERIFIED from report §2 and is confirmed by the `git diff` review above.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - two marker lines; generator
  rewrites the 16 machine-owned columns
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - two marker lines; generator
  rewrites the 6 machine-owned columns

**Verification**:
- Key-sorted description diff is empty for both files
- `--emit-inventory --check` output does not name either README
- `git status --porcelain` shows no modified path in sibling 812's `file_scope`
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` passes on the diff

---

### Phase 3: Demonstrate INV coverage on the two named blocks [NOT STARTED]

**Goal**: Show, rather than assume, that a drifted count inside each newly wrapped block now
turns INV red naming that README (scope item 4 for the two named targets; the sweep blocks get
the same treatment in Phase 6).

**Tasks**:
- [ ] Write a scratchpad script `corrupt-check.sh <README> <module.lean>` that: `sed -i`
  replaces the Lines cell on the named module's row with `1`, runs
  `bash scripts/check-module-invariants.sh --emit-inventory --check 2>&1 | tee` into the
  scratchpad, asserts the output contains the README's path, then runs the Phase 2 targeted
  regeneration procedure to restore the file and asserts a second `--check` no longer names it.
  The README's `git diff` must be empty at the end.
- [ ] Run it on `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (`Trace.lean`) and
  `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` (`Family.lean`). Save both FAIL
  outputs for the summary.
- [ ] State in the saved evidence that the exit code was 1 regardless while sibling 812's three
  rollup READMEs remain stale, and that the named-file list is the evidence.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: The phase leaves no persistent change (every corruption is reverted and
`git diff` on both READMEs is empty), so the covering check is the two captured `--check`
outputs plus the empty diff; nothing else in the tree is touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - transiently corrupted and
  restored; net diff empty
- `FormalSystem/Metalogic/WeakCanonical/KTypeSummary/README.md` - transiently corrupted and
  restored; net diff empty

**Verification**:
- Two captured FAIL outputs each name the corrupted README
- Two captured post-restore `--check` outputs name neither README
- `git diff -- <both READMEs>` empty; no commit from this phase

---

### Phase 4: Wrap the fitting Tier-A tables under Metalogic/Expressiveness, BXCanonical/Filtration, and WeakCanonical [NOT STARTED]

**Goal**: Extend generated-block coverage to the first half of the sweep's clean-fit tables,
with the same byte-for-byte description guarantee as Phase 2.

**Tasks**:
- [ ] Re-derive the fit check per candidate before wrapping. A table is wrapped only if all of:
  header is `| File | Lines | Description |` (or `| Module | Lines | Role |` — the header line is
  kept verbatim); every first-column entry names a live `.lean` file in `dir=` or a live
  subdirectory with `—` (not a number) in its Lines cell; no row names a file that no longer
  exists (phantom); no cell contains `\|` (safe after Phase 1, but note it). A table failing any
  check is demoted to the Phase 6 report with the failing check named — never forced.
- [ ] Candidates (carried from report §4 Tier A; confirm each): `Metalogic/Expressiveness/EFGames/README.md`,
  `Metalogic/Expressiveness/GameTransfer/README.md`,
  `Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/SharedWitness/README.md`,
  `Metalogic/Expressiveness/Kamp/EANegationFix/README.md`,
  `Metalogic/Expressiveness/Kamp/EANegationFixFaithful/README.md`,
  `Metalogic/BXCanonical/Filtration/README.md`,
  `Metalogic/WeakCanonical/DenseModelSurgery/README.md`,
  `Metalogic/WeakCanonical/IntegerModel/README.md` (3 live files have no row — the generator
  adds `<!-- TODO: add description -->` rows; write a one-phrase description for each from the
  module's header doc-comment before committing),
  `Metalogic/WeakCanonical/RealModel/README.md`,
  `Metalogic/WeakCanonical/GroupModel/README.md`.
- [ ] For each: `desc-snapshot.py` pre-wrap; insert the two marker lines with
  `dir=FormalSystem/<path>`; after all files in this phase are wrapped, run the Phase 2
  targeted regeneration procedure ONCE; `desc-snapshot.py` post-wrap and key-sorted diff per
  file (zero differences, except the new TODO rows, which must then be filled); review
  `git diff` per file for the allowed hunk classes only.
- [ ] `--emit-inventory --check`: none of this phase's READMEs is named.
- [ ] Commit by explicit path list (every wrapped README in this phase; nothing else).

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check` plus
the per-file key-wise description diff cover every edited README (markdown, no compile surface),
and `bash .claude/scripts/verify-deploy.sh --only-gate 4` covers the deploy-consumer markdown
path per plan-format.md's sub-case (c); no `.lean` or script file changes.

**Scope Hypothesis**: Ten READMEs in this phase fit as-is and `IntegerModel` gains exactly three
TODO rows — CARRIED-UNVERIFIED from report §4 Tier A; confirm with the fit check above. Two
files the report lists in Tier A, `Metalogic/Expressiveness/README.md` and
`Metalogic/WeakCanonical/README.md`, are demoted to the Phase 6 report at plan time: re-derived
reads show their subdirectory rows carry numeric line totals (`EFGames/` 11,800, `RealModel/`
6,789) that `cols=lines` renders as `—`, and `cols=files-lines` would need a four-column header
rewrite plus re-authoring of the "(N files)" phrases — a shape change outside this task.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/EFGames/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/Expressiveness/GameTransfer/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/SharedWitness/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFix/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/Expressiveness/Kamp/EANegationFixFaithful/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/BXCanonical/Filtration/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/README.md` - marker lines; generated columns; three new descriptions
- `FormalSystem/Metalogic/WeakCanonical/RealModel/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/WeakCanonical/GroupModel/README.md` - marker lines; generated columns

**Verification**:
- Key-sorted description diff empty per file (TODO rows filled before commit; zero
  `<!-- TODO: add description -->` strings remain in any committed block)
- `--emit-inventory --check` names none of this phase's files
- `git status --porcelain` shows no modified path in sibling 812's `file_scope`
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` passes

---

### Phase 5: Wrap the fitting Tier-A tables under Decidability, Theorems, Automation, Semantics, Syntax, and ProofSystem [NOT STARTED]

**Goal**: Complete Tier-A coverage with the second half of the sweep's clean-fit tables.

**Tasks**:
- [ ] Apply the Phase 4 fit check to each candidate (carried from report §4 Tier A; confirm):
  `Metalogic/Decidability/WitnessFamily/Sharing/README.md` (2 live files have no row —
  describe them), `Metalogic/Decidability/Verified/Termination/README.md` (the generator adds a
  `MintBound/` subdirectory row with `—` — describe it in one phrase),
  `Metalogic/Decidability/Verified/Bridge/README.md`, `Metalogic/Decidability/BiLasso/README.md`,
  `Metalogic/Decidability/Propositional/README.md`, `Theorems/Propositional/README.md`,
  `Automation/ProofSearch/README.md`, `Semantics/Correspondence/README.md`,
  `Semantics/Extension/README.md`, `Syntax/SubformulaClosure/README.md`, `ProofSystem/README.md`.
  Demote any failing table to the Phase 6 report with the failing check named.
- [ ] For each: `desc-snapshot.py` pre-wrap; insert marker lines; one targeted regeneration run
  (Phase 2 procedure) after all are wrapped; post-wrap key-sorted diff per file; fill every
  TODO row; `git diff` hunk-class review.
- [ ] `--emit-inventory --check`: none of this phase's READMEs is named.
- [ ] Commit by explicit path list.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: Same covering check as Phase 4 — `bash scripts/check-module-invariants.sh --emit-inventory --check`
plus the per-file key-wise description diff, and `bash .claude/scripts/verify-deploy.sh --only-gate 4`
for the deploy-consumer markdown path; no `.lean` or script file changes.

**Scope Hypothesis**: Eleven READMEs fit as-is, `Sharing` gains two TODO rows and `Termination`
one `MintBound/` row — CARRIED-UNVERIFIED from report §4 Tier A; confirm with the fit check.
`Metalogic/Decidability/WitnessFamily/README.md` is NOT in this phase: its lower table keys rows
on `Sharing/`-prefixed paths the generator would not emit and its upper table needs `rows=loose`
(report Tier B/C); both go to the report.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - marker lines; generated columns; two new descriptions
- `FormalSystem/Metalogic/Decidability/Verified/Termination/README.md` - marker lines; generated columns; one subdirectory description
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - marker lines; generated columns
- `FormalSystem/Metalogic/Decidability/Propositional/README.md` - marker lines; generated columns
- `FormalSystem/Theorems/Propositional/README.md` - marker lines; generated columns
- `FormalSystem/Automation/ProofSearch/README.md` - marker lines; generated columns
- `FormalSystem/Semantics/Correspondence/README.md` - marker lines; generated columns
- `FormalSystem/Semantics/Extension/README.md` - marker lines; generated columns
- `FormalSystem/Syntax/SubformulaClosure/README.md` - marker lines; generated columns
- `FormalSystem/ProofSystem/README.md` - marker lines; generated columns

**Verification**:
- Key-sorted description diff empty per file; zero TODO placeholders in committed blocks
- `--emit-inventory --check` names none of this phase's files
- `git status --porcelain` shows no modified path in sibling 812's `file_scope`
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` passes

---

### Phase 6: Coverage demonstration on the sweep blocks, sweep report, and full gate [NOT STARTED]

**Goal**: Close scope item 4 for every block this task wrapped, deliver the sweep report, and
run the complete gate set.

**Tasks**:
- [ ] Run `corrupt-check.sh` (Phase 3) against every README wrapped in Phases 4-5, one module
  per file, capturing each FAIL line and the post-restore `--check` line. `git diff` on all of
  them must be empty afterwards.
- [ ] Enumerate every generated block this task added (`git log --name-only` over this task's
  commits, cross-checked with `grep -rln "BEGIN GENERATED: inventory" FormalSystem/`) and list
  them in the summary as new generated surfaces that any later `.lean` edit in those
  directories now forces to regenerate.
- [ ] Write the sweep report into the implementation summary: wrapped (this task), Tier B left
  unwrapped with the specific blocker per file (phantom rows in `BXCanonical/Chronicle`,
  `BXCanonical/Quasimodel`, `Core/RestrictedMCS`; numeric subdirectory totals in
  `Expressiveness/README.md` and `WeakCanonical/README.md`; option-requiring shapes in
  `WitnessFamily/README.md`, `Kamp/README.md`, `Kamp/NfMultiAnchorBridge/README.md`; moved
  layout in `Expressiveness/Separation/README.md`; the pinned-row `BXCanonical/README.md` which
  the simulation showed survives and is a candidate for a follow-up), and Tier C report-only
  (`FMP` declaration counts, `MintBound` four columns, two-column count-free tables, non-inventory
  status tables). State explicitly that stale counts in unwrapped tables were left as found.
- [ ] Record follow-ups in the summary (not implemented here): wrapping the Tier-B tables once
  their blockers are resolved; a `sort=existing` generator option only if alphabetization proves
  costly; the self-guarding note that the wrapped RaySummary block now fails INV if `split_row`
  ever regresses on `\|`.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh` and
  `bash scripts/check-module-invariants.sh --no-build`. For the latter, INV's exit status may be
  red solely on sibling 812's three rollup READMEs if they are still stale; the acceptance
  criterion is that INV's named-file list contains none of this task's files and no other check
  regressed relative to a run at the task's starting commit.
- [ ] Write the implementation summary; commit by explicit path.

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: The Tier B and Tier C file lists named above are CARRIED-UNVERIFIED from
report §4; confirm each entry against the tree (`grep -rLn "BEGIN GENERATED: inventory"` over
`FormalSystem/**/README.md` crossed with the per-table fit check) before the summary asserts it,
and reclassify any table whose blocker has since been resolved by a sibling.

**Files to modify**:
- `specs/744_wrap_inventory_tables_generated_markers/summaries/01_wrap-inventory-tables-generated-markers-summary.md` - sweep report, coverage evidence, new generated surfaces, follow-ups
- Phases 4-5 READMEs - transiently corrupted and restored; net diff empty

**Verification**:
- One captured FAIL line per newly wrapped README, each naming that file; one post-restore line
  per file not naming it; `git diff` empty on all
- `bash .claude/scripts/verify-deploy.sh` passes
- `bash scripts/check-module-invariants.sh --no-build`: no check other than INV changes status
  relative to the starting commit, and INV names no file this task touched
- Summary contains the three-tier sweep report and the generated-surface list

## Testing & Validation

- [ ] Phase 1: `--emit-inventory --check` stale-file list identical before and after the
  `split_row` edit; scratch extraction of RaySummary descriptions shows all `\|` cells whole
- [ ] Every wrap phase: key-sorted description diff empty per file; no TODO placeholder left in a
  committed block; `--check` names none of the phase's files
- [ ] Every writer run: `git status --porcelain` shows no modification to `README.md`,
  `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`
- [ ] Scope item 4: captured FAIL output naming each newly wrapped README on a corrupted count,
  and a clean `--check` line after restoration
- [ ] Final: `bash .claude/scripts/verify-deploy.sh` green; `check-module-invariants.sh --no-build`
  shows no regression attributable to this task

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` with escape-aware `split_row` and a header-comment note
- `docs/reference/readme-standard.md` with the `\|` sentence
- Generated blocks in the two named READMEs and in every Tier-A README that passed the fit check
- Implementation summary carrying the three-tier sweep report, the coverage evidence, and the
  list of new generated surfaces
- Scratchpad tools (`desc-snapshot.py`, `corrupt-check.sh`) — not committed

## Rollback/Contingency

Every phase commits by explicit path, so a phase can be reverted with `git revert` of its own
commits without touching sibling work. If a wrap phase's description diff is non-empty for a
file, do not commit that file: remove its two marker lines, re-run the targeted regeneration
(the generator then ignores it), and demote it to the report. If the Phase 2 precondition fails
(a foreign modification on one of the three rollup READMEs), use the out-of-tree extracted-Python
method described there and never run the in-tree writer until the precondition holds again. If
Phase 1's `split_row` change alters any existing block's `--check` status, revert that single line
and stop: the premise that no existing block contains `\|` would be false and needs re-research
before wrapping RaySummary.
