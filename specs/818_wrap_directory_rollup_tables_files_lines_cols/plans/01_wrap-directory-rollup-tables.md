# Implementation Plan: Task #818

- **Task**: 818 - Wrap the four directory-rollup inventory tables that need the cols=files-lines column set
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: `specs/818_wrap_directory_rollup_tables_files_lines_cols/reports/01_wrap-directory-rollup-tables.md`
- **Artifacts**: plans/01_wrap-directory-rollup-tables.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Wrap two of the four scoped `## Modules` tables — `FormalSystem/Metalogic/Expressiveness/README.md`
and `FormalSystem/Metalogic/WeakCanonical/README.md` — in `<!-- BEGIN GENERATED: inventory
dir=<path> cols=files-lines -->` markers, converting their hand-maintained 3-column
`File | Lines | Description` tables into 4-column `Module | Files | Lines | Description` blocks
owned by `scripts/check-module-invariants.sh --emit-inventory`. The remaining two scoped files
(`Kamp/README.md` and `NfMultiAnchorBridge/README.md`) are **not** wrapped: research established
that their aggregated `loose modules` row has no analogue under any existing marker option, and
the dispatch's NON-GOALS forbid extending the generator to cover it. Each wrapped file is
verified by a key-sorted before/after diff and a corrupt/restore coverage demonstration before
its commit.

### Research Integration

The research report establishes the three load-bearing facts this plan builds on, each
independently re-confirmed against the live generator during planning:

- `render_block()` carries the existing block's first row-shaped line forward as the header
  **verbatim** and never derives it from `cols=`, so the 3→4 column header rewrite is a one-time
  hand step (`scripts/check-module-invariants.sh:463-479`).
- `cols=files-lines` emits a literal `1` for each loose file and the real live file count plus
  line total for each subdirectory, replacing the `cols=lines` default's `"—"` placeholder
  (`scripts/check-module-invariants.sh:422-444`).
- Neither `rows=subdirs` (which silently drops the `loose modules` row) nor `rows=both` (which
  explodes it into 49 and 33 per-file rows respectively) reproduces the two Kamp tables' shape.

**One correction to the research's recommended procedure, found and reproduced during planning.**
Research recommendation 1 says to add a literal `1` files-count cell "to each loose-file row"
before the first `--emit-inventory` run. That is incomplete and, as written, destructive.
`render_block()` carries a description forward only when the existing row already has at least
`ncols` cells:

```
descriptions[key] = cells[-1].strip() if len(cells) >= ncols else TODO_DESC
```

With `cols=files-lines` and the default `desc=yes`, `ncols` is 4. Every un-padded 3-cell row —
**including every subdirectory row**, which the research text does not mention padding — therefore
has its description replaced by `<!-- TODO: add description -->`. Reproduced on a scratch copy:
wrapping `Expressiveness/README.md` with markers and no row padding regenerated all 15 rows with
correct numbers and **all 15 descriptions replaced by the TODO placeholder**. This plan's Phase 1
and Phase 2 therefore pad *every* data row, loose and subdirectory alike, to 4 cells before the
first generator run, and the corrected procedure was itself verified end-to-end on a scratch copy
(all descriptions preserved, `(N files)` stripped, idempotent `--emit-inventory --check` pass).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no roadmap consultation was performed.

### Premise Re-Validation (Carried-Figure Discipline)

The dispatch's `## Description` carries measured figures flagged for re-validation. Checked
against live state during planning:

| Carried claim | Live state | Verdict |
|---|---|---|
| `EFGames/ 11,800` | hand-written cell reads 11,800; live is 11 files / 11,886 lines | **Stale by design.** The hand number is what is written today; regeneration corrects it. |
| `GameTransfer/ 9,507` | hand 9,507; live 5 files / 9,518 | Stale, same sense |
| `Kamp/ 77,714` | hand 77,714; live 115 files / 77,732 (prose says "116 files") | Stale, same sense |
| `Separation/ 926` | hand 926; live 3 files / 930 | Stale, same sense |
| `WeakCanonical/README.md` — "five subdirectory rows with numeric totals" | Confirmed: `DenseModelSurgery/`, `GroupModel/`, `IntegerModel/`, `KTypeSummary/`, `RealModel/` | Accurate |
| `Kamp/README.md` is a `\| \| Files \| Lines \|` rollup with an empty leading header cell | Confirmed verbatim at `Kamp/README.md:28` and `NfMultiAnchorBridge/README.md:9` | Accurate |
| `split_row` is escape-aware | Confirmed: `re.split(r"(?<!\\)\|", body)` at `scripts/check-module-invariants.sh:334` | Accurate |

**Two corrections to the description's premises, both material:**

1. **The description under-enumerates `Expressiveness/README.md`'s subdirectory rows.** It names
   four (`EFGames/`, `GameTransfer/`, `Kamp/`, `Separation/`); the table has **five** — `SeparationZ/`
   (hand 6,875; live 13 files / 6,902) is also a subdirectory rollup row carrying a numeric total
   and is equally in scope for preservation.
2. **"Every numeric total must survive" means no row loses its number, not that the digits are
   frozen.** Every one of the ten subdirectory totals across the two files is stale relative to
   live counts; making them machine-owned is the point of the task, so regeneration *changes* all
   of them. The invariant this plan verifies is that every row that had a number before has a real
   number after (never an em-dash, never a dropped row), not digit-for-digit equality.

Baseline confirmed clean at plan time: `bash scripts/check-module-invariants.sh --emit-inventory
--check` → `PASS INV every generated inventory block is current, every hand-maintained one is
exhaustive`. Live key sets for both in-scope directories match their tables' existing row keys
exactly, so no row will be dropped and no `TODO` placeholder introduced by a missing description.

## Goals & Non-Goals

**Goals**:
- Wrap `FormalSystem/Metalogic/Expressiveness/README.md`'s `## Modules` table in a
  `cols=files-lines` generated-inventory block, with a 4-column `Module | Files | Lines | Description`
  header, every subdirectory total rendered as a real number, and every hand-written description
  preserved byte-for-byte except the deliberately stripped `(N files)` parentheticals.
- Do the same for `FormalSystem/Metalogic/WeakCanonical/README.md`.
- Resolve the `(N files)` prose/column duplication deliberately: strip the parenthetical from all
  10 affected subdirectory descriptions (5 per file).
- Demonstrate coverage per newly wrapped block: corrupt one count, confirm `INV FAIL` names
  exactly that README, restore via `--emit-inventory`, confirm the diff is empty.
- Record the blocking finding for the two Kamp rollup tables in the task summary.

**Non-Goals**:
- Any change to `scripts/check-module-invariants.sh`. If a shape is not covered by an existing
  marker option, it is reported, not worked around (dispatch NON-GOALS).
- Wrapping `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` or
  `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md`.
- Registering either Kamp table as `<!-- INVENTORY: hand-maintained (dir=...) -->`. This is an
  existing generator feature and so is not barred by the NON-GOALS, but it would turn the INV gate
  **red**: `audit_hand_maintained()` requires a registered table to have a row for every live file
  and subdirectory and no row for anything else, and both Kamp tables violate that (the
  `loose modules` row resolves to nothing live, and `Kamp/README.md` is additionally missing the
  live `EANegationFixFaithful/` subdirectory). Explicitly out of scope so no implementer reaches
  for it as a consolation prize.
- Any Lean source change.
- Hand-correcting counts in any table this task does not wrap, including `Kamp/README.md`'s
  known-stale and incomplete Structure table.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A data row left at 3 cells loses its description to `TODO_DESC` | H | M | Pad **every** data row (loose *and* subdirectory) to 4 cells before the first generator run; the key-sorted before/after description diff in each phase's verification catches any row that slipped |
| `--emit-inventory` is repo-wide with no path filter, and sibling task 817 is wrapping other READMEs on this same working tree this cycle | H | M | Run `git status --porcelain` immediately before and after each generator run; stage only this task's own two files by explicit path; if a third file changed, do **not** stage it — check `git log`, confirm it is a sibling's territory, and report rather than reverting it |
| Header/row cell-count mismatch goes undetected (the generator never validates it) | M | M | Rewrite the header *and* separator to 4 columns in the same edit as the row padding; the post-run read-through confirms a well-formed 4-column table |
| Stripping `(N files)` leaves a description reading awkwardly | L | L | Read each of the 10 resulting descriptions in full after stripping; `SeparationZ/` and `KTypeSummary/` have long multi-clause descriptions where the parenthetical sits at the very end, so the strip is clean |
| `suite_selection_select` returns 17 agent-system suites for a path named `README.md` | L | H (already observed) | This is stratum-(b) basename grep noise, not real coverage — no `.claude` test suite exercises `FormalSystem/**` READMEs. The honest covering check for these edits is the repo's own INV gate, named in each phase's Tier Justification; do not mistake the 17-suite list for a cheaper `--only` narrowing |
| The two Kamp READMEs are silently left in an ambiguous state | M | L | Phase 3 records the blocking finding and its reason explicitly in the task summary, where the record is durable and permitted to cite the task |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. Phases 1 and 2 edit disjoint files but both
invoke the repo-wide `--emit-inventory` writer, so they are deliberately serialized to keep each
run's changed-file set attributable to exactly one phase.

---

### Phase 1: Wrap Expressiveness/README.md [COMPLETED]

**Goal**: `FormalSystem/Metalogic/Expressiveness/README.md`'s `## Modules` table becomes a
generator-owned `cols=files-lines` block with all 15 descriptions intact and all 5 subdirectory
totals rendered as real numbers.

**Tasks**:
- [x] Re-read the file immediately before editing (sibling tasks are live on this tree this cycle). *(completed)*
- [x] Capture a pre-edit key-sorted snapshot of the table: for each data row, `row_key(cell[0])`
      paired with the trailing description cell, sorted by key, written to a scratchpad file. *(completed)*
- [x] Rewrite the header (line 19) to `| Module | Files | Lines | Description |` and the separator
      (line 20) to a 4-column separator. *(completed)*
- [x] Pad **every** data row to 4 cells: insert a files-count cell between the name cell and the
      lines cell. Loose-file rows get `1`; subdirectory rows get any placeholder integer (the
      generator overwrites it on the next run — what matters is that the cell exists, so the row
      reaches 4 cells and its description is carried forward rather than replaced by `TODO_DESC`). *(completed)*
- [x] Strip the trailing `(N files)` / `(1 file)` parenthetical from all 5 subdirectory
      descriptions (`EFGames/`, `GameTransfer/`, `Kamp/`, `Separation/`, `SeparationZ/`), then read
      each resulting description in full to confirm it stands as a sentence. *(completed)*
- [x] Insert `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Expressiveness cols=files-lines -->`
      immediately above the header and `<!-- END GENERATED -->` immediately below the last data row. *(completed)*
- [x] Record `git status --porcelain` output, then run `bash scripts/check-module-invariants.sh --emit-inventory`. *(completed: exactly 1 file rewritten, sibling task 817's Chronicle/README.md edit observed concurrently and left untouched)*
- [x] Record `git status --porcelain` again and confirm exactly one file changed. *(completed)*
- [x] Run `bash scripts/check-module-invariants.sh --emit-inventory --check` and confirm `PASS INV`
      (idempotence). *(completed)*
- [x] Corrupt/restore demonstration: change one numeric cell in the regenerated block, run
      `--emit-inventory --check`, confirm it reports `FAIL INV` naming exactly
      `FormalSystem/Metalogic/Expressiveness/README.md` and no other file; restore by running
      `bash scripts/check-module-invariants.sh --emit-inventory` (never a pathspec checkout —
      `git checkout -- <path>` is a blocked destructive form on a dirty tree); confirm
      `git diff` against the post-regeneration state is empty. *(completed: FAIL INV named exactly this file, restore via writer produced empty diff)*
- [x] Update the file's `*Last verified:*` line to today's date. *(completed: 2026-11-12)*
- [x] Commit, staging only `FormalSystem/Metalogic/Expressiveness/README.md` by explicit path. *(completed)*

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check` is the
repository's own gate for generated inventory blocks and is the specific check that covers this
edit class; `suite_selection_select` over this phase's path returns only basename-grep matches on
the literal string `README.md`, none of which exercise `FormalSystem/**`.

**Scope Hypothesis**: Exactly one tracked file changes in this phase
(`FormalSystem/Metalogic/Expressiveness/README.md`), because the INV baseline was clean at plan
time and `--emit-inventory` only rewrites blocks whose content differs. Confirm by diffing
`git status --porcelain` before and immediately after the generator run; if a second file appears,
stop and determine whether it is a sibling task's in-flight edit before staging anything.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/README.md` - header/separator rewritten to 4 columns, every data row padded to 4 cells, `(N files)` stripped from 5 subdirectory descriptions, table wrapped in BEGIN/END GENERATED markers, counts regenerated, `Last verified` date updated

**Verification**:
- The regenerated block's header reads `| Module | Files | Lines | Description |`.
- All 5 subdirectory rows carry two real integers (a file count and a comma-formatted line total);
  no row renders `—`.
- The key-sorted before/after comparison shows an identical key set (15 keys) and identical
  description text for every key, except the 5 rows whose `(N files)` parenthetical was removed.
- No `<!-- TODO: add description -->` string appears anywhere in the file.
- `--emit-inventory --check` passes immediately after the generator run.
- The corrupt/restore cycle behaves as specified above, ending with an empty diff.

---

### Phase 2: Wrap WeakCanonical/README.md [COMPLETED]

**Goal**: `FormalSystem/Metalogic/WeakCanonical/README.md`'s `## Modules` table becomes a
generator-owned `cols=files-lines` block with all 16 descriptions intact and all 5 subdirectory
totals rendered as real numbers.

**Tasks**:
- [x] Re-read the file immediately before editing. *(completed)*
- [x] Capture the pre-edit key-sorted key/description snapshot as in Phase 1. *(completed)*
- [x] Rewrite header (line 19) and separator (line 20) to 4 columns, matching Phase 1's chosen
      labels exactly (`Module | Files | Lines | Description`). *(completed)*
- [x] Pad **every** data row to 4 cells — 11 loose-file rows get `1`, 5 subdirectory rows get a
      placeholder integer. *(completed)*
- [x] Strip the trailing `(N files)` / `(1 file)` parenthetical from all 5 subdirectory
      descriptions (`DenseModelSurgery/`, `GroupModel/`, `IntegerModel/`, `KTypeSummary/`,
      `RealModel/`), then read each resulting description in full. *(completed)*
- [x] Insert `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical cols=files-lines -->`
      and `<!-- END GENERATED -->` around the table. *(completed)*
- [x] Record `git status --porcelain`, run `bash scripts/check-module-invariants.sh --emit-inventory`,
      record it again, confirm exactly one new file changed relative to the Phase 1 commit. *(completed: exactly 1 file rewritten; `KTypeSummary/` jumped from hand-written 1 file/122 lines to live 6 files/958 lines as the Scope Hypothesis predicted)*
- [x] Run `--emit-inventory --check` and confirm `PASS INV`. *(completed)*
- [x] Corrupt/restore demonstration scoped to this block, as in Phase 1, confirming `FAIL INV`
      names exactly `FormalSystem/Metalogic/WeakCanonical/README.md` and **not**
      `FormalSystem/Metalogic/Expressiveness/README.md` (this is the evidence that the two blocks
      are independently covered). *(completed: FAIL INV named exactly this file only)*
- [x] Update the file's `*Last verified:*` line to today's date. *(completed: 2026-11-12)*
- [x] Commit, staging only `FormalSystem/Metalogic/WeakCanonical/README.md` by explicit path. *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: `bash scripts/check-module-invariants.sh --emit-inventory --check` covers
this edit class exactly as in Phase 1, and the corrupt/restore step additionally demonstrates that
the gate discriminates this block from Phase 1's.

**Scope Hypothesis**: Exactly one additional tracked file changes in this phase
(`FormalSystem/Metalogic/WeakCanonical/README.md`); `KTypeSummary/` is expected to jump from the
hand-written `1 file / 122 lines` to the live `6 files / 958 lines`, which is the largest single
regeneration delta in either file and is a correction, not a loss. Confirm with the before/after
`git status --porcelain` comparison and the key-sorted description diff.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/README.md` - header/separator rewritten to 4 columns, every data row padded to 4 cells, `(N files)` stripped from 5 subdirectory descriptions, table wrapped in BEGIN/END GENERATED markers, counts regenerated, `Last verified` date updated

**Verification**:
- Header reads `| Module | Files | Lines | Description |`.
- All 5 subdirectory rows carry two real integers; no row renders `—`.
- Key-sorted before/after shows an identical 16-key set and identical description text except the
  5 stripped parentheticals.
- No `<!-- TODO: add description -->` appears in the file.
- `--emit-inventory --check` passes.
- The corrupt/restore cycle names exactly this file and ends with an empty diff.

---

### Phase 3: Record the Kamp blocking finding and run the full gate [COMPLETED]

**Goal**: The two unwrapped Kamp rollup tables are recorded as a deliberate, reasoned exclusion
rather than an oversight, and the complete gate set is observed green over both wrapped files.

**Tasks**:
- [x] Confirm both `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` and
      `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md` are unmodified
      by this task (`git diff` against the task's base commit shows nothing for either path). *(completed: `git diff 9e617b50c..HEAD` empty for both paths)*
- [x] Write the task summary at
      `specs/818_wrap_directory_rollup_tables_files_lines_cols/summaries/01_wrap-directory-rollup-tables-summary.md`,
      recording: the two files wrapped and their verified outcomes; the two files deliberately not
      wrapped, with the `loose modules` aggregate-row reason and the `rows=subdirs` silent-drop /
      `rows=both` 49-and-33-row-explosion evidence; the explicit decision not to register either as
      hand-maintained and why that would turn the gate red; and the follow-up candidates (a generator
      option summing loose files into one aggregate row; `Kamp/README.md`'s missing
      `EANegationFixFaithful/` subdirectory and stale counts). *(completed)*
- [x] Run `bash .claude/scripts/verify-deploy.sh` and confirm green, or record any pre-existing
      failure as pre-existing by checking it against the task's base commit. *(deviation: altered — per this dispatch's Batch Gate Deferral directive, the full `verify-deploy.sh` gate was deferred to the once-per-batch run at the end of this `/orchestrate` invocation rather than run independently here; neither `run-all.sh --only SUITE` nor `verify-deploy.sh --only-gate N` maps to this edit class, so the two checks that actually cover it — `check-module-invariants.sh --emit-inventory --check` and `readme-lint.sh` — were run directly instead, per the directive's UNMAPPABLE CRITERION path, and both are green)*
- [x] Run `bash scripts/readme-lint.sh FormalSystem` and confirm no new broken reference or
      missing-README finding is attributable to this task's two files. *(completed: overall RESULT: PASS, 0 broken file references; neither wrapped file appears in the STALE/MISSING DATE findings)*
- [x] Commit the summary, staging only the summary path. *(completed)*

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `specs/818_wrap_directory_rollup_tables_files_lines_cols/summaries/01_wrap-directory-rollup-tables-summary.md` - new task summary recording both wrapped outcomes and the Kamp exclusion with its reasoning

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` runs to completion green (or every failure is shown to
  predate this task's base commit).
- `bash scripts/check-module-invariants.sh --emit-inventory --check` → `PASS INV`.
- `bash scripts/readme-lint.sh FormalSystem` reports nothing new for either wrapped file.
- `git diff <base>..HEAD --name-only` lists exactly three paths: the two wrapped READMEs and the
  summary (plus this plan and the research report from earlier dispatches).
- The summary explicitly names both unwrapped Kamp files and the reason each is excluded.

---

## Testing & Validation

- [ ] Both wrapped blocks regenerate idempotently: a second `--emit-inventory` run immediately
      after the first changes nothing.
- [ ] Zero `<!-- TODO: add description -->` occurrences across both wrapped files.
- [ ] Every one of the 10 subdirectory rows across both files carries a real file count and a real
      line total; `grep -c '—'` inside either generated block returns 0.
- [ ] Key-sorted before/after description comparison passes for both files, with the only
      differences being the 10 stripped `(N files)` parentheticals.
- [ ] The corrupt/restore demonstration was performed independently for each of the two newly
      wrapped blocks, and in each case `FAIL INV` named exactly the file under test.
- [ ] Neither Kamp README was modified.
- [ ] `bash .claude/scripts/verify-deploy.sh` green.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Expressiveness/README.md` — generator-owned `cols=files-lines` inventory block
- `FormalSystem/Metalogic/WeakCanonical/README.md` — generator-owned `cols=files-lines` inventory block
- `specs/818_wrap_directory_rollup_tables_files_lines_cols/summaries/01_wrap-directory-rollup-tables-summary.md` — completion summary including the Kamp exclusion record
- Three commits, one per phase, each staging only its own phase's files by explicit path

## Rollback/Contingency

Each phase commits exactly one file, so reverting a phase is a single `git revert` of that
commit followed by `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm
the tree returns to `PASS INV`. Within an in-progress phase, the restore path is always
`bash scripts/check-module-invariants.sh --emit-inventory` (the writer), never a pathspec
checkout — `git checkout -- <path>` and `git restore <path>` are blocked destructive forms on a
dirty tree, and the writer restores a generated block to its canonical content by construction.

If Phase 1's generator run changes a file outside this task's scope, do not revert it and do not
stage it: sibling tasks are live on this working tree this cycle. Check `git log` to confirm the
change is not this task's own, report it, and proceed only with this task's own hunks.

If a wrapped block turns out to lose a description or a numeric total in a way the padding
procedure does not fix, stop and report rather than hand-correcting the regenerated cells — a
hand correction inside a generated block is reverted by the next `--emit-inventory` run and
recreates exactly the dual-source-of-truth problem this task exists to remove.
