# Research Report: Task 818

**Task**: 818 - Wrap the four directory-rollup inventory tables that need the cols=files-lines column set
**Started**: 2026-11-12T17:00:00Z
**Completed**: 2026-11-12T17:28:00Z
**Effort**: ~1 hour (research + scratch-copy verification)
**Dependencies**: None
**Sources/Inputs**:
- `scripts/check-module-invariants.sh` (`--emit-inventory` generator, read in full, lines 207-603)
- `scripts/lib/live_walk.py` (pure filesystem line/file counting, no build dependency)
- `FormalSystem/Metalogic/Expressiveness/README.md`, `FormalSystem/Metalogic/WeakCanonical/README.md`,
  `FormalSystem/Metalogic/Expressiveness/Kamp/README.md`,
  `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md` (the four scoped files)
- `FormalSystem/Metalogic/README.md` (precedent: already-wrapped `cols=files-lines` rollups for
  the same four directories' own subdirectories, confirming header-naming freedom and option shape)
- `FormalSystem/ForMathlib/README.md` (precedent: `rows=subdirs cols=files-lines link=yes` with a
  4-column `Directory | Files | Lines | Role` header)
- A full scratch-copy execution of `--emit-inventory` / `--emit-inventory --check` against a copy
  of `scripts/` + `FormalSystem/` in the scratchpad directory (never run against the tracked tree)
**Artifacts**:
- This report: `specs/818_wrap_directory_rollup_tables_files_lines_cols/reports/01_wrap-directory-rollup-tables.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- `cols=files-lines` fully covers 2 of the 4 scoped READMEs — `Expressiveness/README.md` and
  `WeakCanonical/README.md` — once their 3-column `File | Lines | Description` header is
  hand-rewritten to 4 columns (`Module | Files | Lines | Description`); the generator never
  rewrites an existing header itself, it carries the first row found inside the block forward
  verbatim, so the header edit is a one-time hand step, not something `--emit-inventory` does.
- Verified end-to-end on a scratch copy (never on the tracked tree): wrapping those two files,
  running `--emit-inventory`, confirming every subdirectory total renders as a real number (no
  `—` placeholder), confirming every hand-written description survives byte-for-byte via a
  key-sorted before/after diff (except the deliberately-stripped `(N files)` parentheticals),
  corrupting one count, confirming `INV FAIL` names exactly that file, and restoring via
  `--emit-inventory` to a byte-identical result.
- The other 2 scoped READMEs — `Kamp/README.md` and `NfMultiAnchorBridge/README.md` — use a
  shape no existing generator option produces: a single **aggregated** `loose modules` row
  summing all loose `.lean` files into one row, alongside per-subdirectory rows. `rows=subdirs`
  silently **drops** that row (confirmed by experiment: no `INV FAIL`, the data just vanishes);
  `rows=both` would explode it into 33-49 individual per-file rows, a structural rewrite, not a
  header/option change. Per the dispatch's NON-GOALS, this is reported rather than worked around
  by extending the generator.
- The `(N files)` parenthetical in 10 subdirectory descriptions (5 in each of the 2 in-scope
  files) duplicates the new machine-owned `Files` column and was in several cases already stale
  relative to the live count; resolved by stripping the parenthetical from the description text
  (not by editing a number — the surrounding prose reads correctly without it).
- The empty leading header cell in the two Kamp-rollup tables (`| | Files | Lines |`) is
  preserved verbatim by the generator regardless of content — `render_block` never inspects or
  validates header cell text, it only carries the existing block's first row forward unchanged.
  This question is moot for this task since those two files are not being wrapped, but the
  mechanism is confirmed for completeness and for any future task that revisits them.

## Context & Scope

Task 818's description names four READMEs, demoted from a prior inventory-wrapping sweep to
report-only because their rows are subdirectory rollups carrying numeric line totals that the
default `cols=lines` column set renders as an em-dash placeholder (destroying the totals). This
research establishes, against the generator's actual code (not from memory), whether
`cols=files-lines` covers each of the four shapes, and what header each wrapped block needs. Per
the dispatch's explicit NON-GOALS, no change to `scripts/check-module-invariants.sh` itself was
in scope, and none was made; all verification ran against a disposable scratch copy under the
session scratchpad directory, never against the tracked working tree. No file under
`FormalSystem/` was modified by this research dispatch.

## Findings

### The generator's header contract (governs all four files)

`render_block()` (`scripts/check-module-invariants.sh:448-517`) takes the **first row-shaped
line found inside the existing `BEGIN GENERATED`/`END GENERATED` block** as the header, and
re-emits it completely unchanged (`header = ln.rstrip()`), with the same treatment for the
separator row. It never derives the header from the `cols=`/`desc=`/`rows=` options, and never
checks that the header's cell count matches the data rows' cell count. Two consequences:
- A table being wrapped for the first time with a column-set change **must** have its header (and
  separator) hand-rewritten to the target column count *before* the first `--emit-inventory`
  run — the generator will not do this, and will not even detect a mismatch if it is skipped.
- A header's cell *content* (including an empty leading cell, as in the two Kamp-rollup tables) is
  never inspected or require to be named — it is pure pass-through text.

### `Expressiveness/README.md` and `WeakCanonical/README.md`: `cols=files-lines` fits directly

Both files' `## Modules` tables already mix loose `.lean` file rows and subdirectory rollup rows
under one 3-column header (`File | Lines | Description`). `scan()`'s `rows=both` (the default)
combined with `cols=files-lines` emits exactly this shape with one extra numeric column: every
loose file gets a literal `1` in the new `Files` column (`scripts/check-module-invariants.sh:426-429`),
and every subdirectory gets its real live file count and line total
(`scripts/check-module-invariants.sh:437-438`) instead of the `cols=lines` default's `"—"`
placeholder (`scripts/check-module-invariants.sh:440`). This was verified by hand-editing a
scratch copy of both files to:
1. Add `<!-- BEGIN GENERATED: inventory dir=<path> cols=files-lines --> ... <!-- END GENERATED -->`
   around the existing table.
2. Rewrite the header/separator from 3 to 4 columns: `| Module | Files | Lines | Description |`
   (chosen over `File | Files | Lines | …` to avoid the `File`/`Files` near-duplicate; `Module`
   already has precedent as a loose-table header in `FormalSystem/Metalogic/README.md`'s
   `BXCanonical` `rows=loose` block).
3. Add a literal `1` files-count cell to each loose-file row (a mechanical placeholder — the
   next `--emit-inventory` run overwrites it anyway, but the header/data column counts must
   already agree before that first run for the table to parse sensibly in the interim and for a
   human reading the diff to see a well-formed table).
4. Strip the `(N files)` parenthetical from each of the 5 subdirectory descriptions (see below).

Running `--emit-inventory` against the scratch copy then rewrote only the numeric cells — no
other `.md` file in the copied `FormalSystem/` tree changed, confirming the wrap is scoped to
exactly the two targeted blocks. A second `--emit-inventory --check` run passed immediately
(idempotent). `--check`'s failure path was also exercised: corrupting `Kamp/`'s line total in
`Expressiveness/README.md` produced `FAIL INV 1 file(s) carry a stale generated inventory
block` naming only `FormalSystem/Metalogic/Expressiveness/README.md` — not
`WeakCanonical/README.md` — and running `--emit-inventory` again restored the file to a
byte-identical match of the pre-corruption state (`diff` empty), with a subsequent `--check`
passing.

A key-sorted before/after comparison (every row's key and trailing description cell, independent
of row order and of the thousands-separator/number changes the generator makes) confirmed: the
set of keys is identical before and after in both files, and the only description text that
changed is the 10 deliberately-stripped `(N files)` parentheticals — every other description,
including ones containing GFM-escaped `\|` sequences, long multi-clause prose, and inline code
spans, is byte-identical.

The regenerated numbers also **corrected** several stale hand-written totals that predate this
task (not destroyed any — every row that had a number before still has one, now a more current
one): e.g. `WeakCanonical/README.md`'s `KTypeSummary/` row read `1 file / 122 lines` by hand but
is live `6 files / 958 lines` — already matching the existing, separately-generated rollup for
the same directory in `FormalSystem/Metalogic/README.md`. This is the intended effect of making
counts machine-owned, not a defect introduced by this task.

### The `(N files)` prose duplication: resolved by removing the parenthetical

Both in-scope tables' subdirectory descriptions carry a `(N files)` (or `(1 file)`) parenthetical
that will duplicate the new machine-owned `Files` column once wrapped — and in two cases
(`Expressiveness/README.md`'s `EFGames/` row: hand said `8 files`, live is `11`; and
`WeakCanonical/README.md`'s `KTypeSummary/` row: hand said `1 file`, live is `6`) the parenthetical
was already stale, which the new column would immediately contradict side-by-side in the same
row. Resolution: strip the parenthetical from the description text; the surrounding prose reads
correctly without it in all 10 cases (verified by reading each resulting sentence). No
alternative (e.g. keeping it and manually syncing it to match the Files column) was pursued,
since that would recreate exactly the dual-source-of-truth problem `--emit-inventory` exists to
eliminate.

### `Kamp/README.md` and `NfMultiAnchorBridge/README.md`: no existing option covers the shape

Both files' tables have an identical 3-column shape (`| | Files | Lines |`, no description
column) with one row that is **not** a per-entity row: a `loose modules` row aggregating *all*
loose `.lean` files in the directory into a single files-count/lines-total pair, followed by one
row per subdirectory (as a markdown link to that subdirectory's own README). Examples: `Kamp/`'s
table has `loose modules | 49 | 26,160` plus two subdirectory rows; `NfMultiAnchorBridge/`'s has
`loose modules | 33 | 28,265` plus one subdirectory row.

No combination of `scan()`'s options produces this aggregate-row shape:
- `rows=subdirs` (with any `cols=`) emits only the subdirectory rows — the `loose modules` row
  has no live-filesystem analogue the generator recognizes, so it is simply absent from the
  scanned set. It is also not a dispatchable "pinned" row (the pinned-row mechanism,
  `scripts/check-module-invariants.sh:486-495`, only preserves a row whose key resolves to an
  actual file path under `directory` — `"loose modules"` does not).
- **Confirmed by direct experiment** on the scratch copy: wrapping `Kamp/README.md`'s table with
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Expressiveness/Kamp rows=subdirs
  cols=files-lines desc=no -->` and running `--emit-inventory` **silently deleted** the `loose
  modules` row — no error, no `INV FAIL`, the 49-file/26,160-line aggregate simply disappeared
  from the regenerated block, replaced by only the (correctly-regenerated) 3 subdirectory rows.
  This is exactly the silent-destruction failure mode the task exists to avoid, just triggered by
  a different missing-coverage gap than the `cols=lines` em-dash case the prior sweep already
  caught.
- `rows=both` (with `cols=files-lines`) does not drop data, but it replaces the one aggregate row
  with one row *per loose file* — 49 rows for `Kamp/README.md`, 33 for `NfMultiAnchorBridge/README.md`
  — which is a wholesale restructuring of a deliberately compact "Structure" overview table into
  a full module listing, not a header/option change.

Per the dispatch's NON-GOALS ("No change to the generator algorithm beyond using an option it
already supports -- if cols=files-lines turns out not to cover these shapes, REPORT that and stop
rather than extending the generator under this task"), this finding is reported rather than
worked around. Both files should remain **unwrapped** (report-only) under this task; a generator
enhancement adding a loose-aggregate row mode (e.g. an `agg=loose` or `rows=loose-total` option)
is a candidate follow-up task, out of scope here.

As an aside (not corrective — these files are out of scope for wrapping), the experiment also
surfaced that `Kamp/README.md`'s current hand-written table is itself stale and incomplete
independent of the column-set question: it is missing a live subdirectory entirely
(`EANegationFixFaithful/`, 5 files / 2,664 live lines, present in the already-generated rollup in
`FormalSystem/Metalogic/README.md` but absent from `Kamp/README.md`'s own table), and its
existing counts for `loose modules` and `NfMultiAnchorBridge/` are several files/lines stale.
This is evidence for why the generator-owned pattern is valuable here, not something this task's
NON-GOALS permit fixing by hand.

### Header-naming freedom, confirmed from precedent

The generator imposes no naming convention on the header's label cell; precedent in this repo
already uses `Directory` (pure-subdirs tables in `ForMathlib/README.md`,
`Metalogic/README.md`'s top-level rollup), `Module` (a pure-loose-files table in
`Metalogic/README.md`'s `BXCanonical` section), `Subdirectory` and even a bespoke phrase
(`Under \`Kamp/\``) in `Metalogic/README.md`'s existing `cols=files-lines` blocks for these same
four directories' own subdirectories. `Module` was chosen for the two mixed loose-plus-subdirs
tables in this task because it is accurate for both row kinds and already has in-repo precedent
for exactly that mixed case.

## Decisions

- Use `cols=files-lines` (default `rows=both`, default `desc=yes`) to wrap
  `FormalSystem/Metalogic/Expressiveness/README.md` and
  `FormalSystem/Metalogic/WeakCanonical/README.md`, with the table header/separator hand-rewritten
  from `| File | Lines | Description |` to `| Module | Files | Lines | Description |` before the
  first `--emit-inventory` run.
- Strip the `(N files)` / `(1 file)` parenthetical from all 10 affected subdirectory descriptions
  (5 per file) rather than keeping and hand-syncing it, since the new `Files` column makes it a
  duplicate and, in 2 of the 10 cases, it was already wrong.
- Do **not** wrap `FormalSystem/Metalogic/Expressiveness/Kamp/README.md` or
  `FormalSystem/Metalogic/Expressiveness/Kamp/NfMultiAnchorBridge/README.md` under this task.
  Neither `rows=subdirs` nor `rows=both` reproduces their aggregated `loose modules` row without
  either silently losing data or restructuring the table far beyond a header/option change; per
  NON-GOALS this is reported rather than worked around by extending the generator.
- The empty leading header cell question for the two Kamp-rollup tables is answered (the
  generator preserves header text verbatim, with no naming requirement) but is moot for this
  task's action, since those two files are not being wrapped.

## Recommendations

1. **Plan phase should scope implementation to exactly 2 files**: `Expressiveness/README.md` and
   `WeakCanonical/README.md`. For each: hand-rewrite the `## Modules` table header/separator to
   4 columns, add the `<!-- BEGIN GENERATED: inventory dir=<path> cols=files-lines -->` /
   `<!-- END GENERATED -->` wrapper around the existing rows, add a literal `1` files-count cell
   to each loose-file row, strip the `(N files)` parenthetical from the 5 subdirectory
   descriptions, then run `bash scripts/check-module-invariants.sh --emit-inventory` for real and
   confirm with `--emit-inventory --check`.
2. **Do not attempt to wrap the two Kamp-rollup READMEs under this task.** If their shape is
   wanted in generated form later, a follow-up task should design and add a new marker option
   (e.g. `agg=loose` summing all loose files into one row) to
   `scripts/check-module-invariants.sh` — explicitly a generator change, out of scope here per
   NON-GOALS.
3. Implementation should re-run the same verification sequence this research performed on the
   scratch copy, but on the real tracked files: wrap, run `--emit-inventory`, diff
   key-sorted before/after to confirm no row lost and no description corrupted beyond the
   intended `(N files)` strips, then do the corrupt/restore demonstration
   (`--emit-inventory --check` should fail naming exactly the file under test; restore via
   `--emit-inventory`, never a pathspec checkout; confirm the restored diff is empty) as the
   dispatch's own VERIFY section requires, this time against the committed repository state.
4. Consider, as an unrelated low-priority follow-up (not part of this task): `Kamp/README.md`'s
   own hand-written "Structure" table is missing the live `EANegationFixFaithful/` subdirectory
   entirely and has stale counts elsewhere — a correctness gap independent of the column-set
   question investigated here.

## Risks & Mitigations

- **Risk**: the literal `1` placeholder files-count cells added to loose-file rows before the
  first `--emit-inventory` run could be mis-typed or omitted for a row, producing a column-count
  mismatch the generator does not itself detect (it never validates header-vs-row cell counts).
  **Mitigation**: the key-sorted before/after diff step (comparing every row by key) catches a
  missing or malformed row as a key-set mismatch; this was exercised successfully on the scratch
  copy for both files.
- **Risk**: stripping the `(N files)` parenthetical could leave a description reading awkwardly
  (e.g. a sentence that grammatically expected the trailing clause). **Mitigation**: each of the
  10 resulting descriptions was read in full after stripping; all read correctly as standalone
  sentences (verified in this research pass; implementation should re-verify after its own edit).
- **Risk**: running `--emit-inventory` against the real tree touches every stale generated block
  in the repository, not just the two files in scope, if any other block happens to be stale at
  implementation time. **Mitigation**: confirmed in this research's scratch-copy run that
  `--emit-inventory` only rewrote the two files whose content was deliberately changed; a
  currently-clean tree's other blocks are unaffected. Implementation should still check
  `git status --porcelain` immediately after running `--emit-inventory` for real and verify the
  changed-file set matches expectations (exactly the two in-scope files, barring a genuinely
  stale block elsewhere already needing a fix) before staging.

## Context Extension Recommendations

None. The existing `scripts/check-module-invariants.sh` header comment (lines 207-270) already
documents every marker option exhaustively and was sufficient to answer every question this
dispatch posed; no project-context gap was identified.

## Appendix

- Search/verification commands used (none destructive to the tracked tree):
  - `grep -n "cols=" scripts/check-module-invariants.sh`
  - `sed -n '200,620p' scripts/check-module-invariants.sh` (full read of the `--emit-inventory`
    generator and its header-comment documentation)
  - `grep -rn "cols=files-lines" FormalSystem --include="*.md"` (precedent discovery)
  - A Python one-off against `scripts/lib/live_walk.py`'s `live_loose_files`/`live_subdirs`/
    `live_files`/`line_count` to compute live figures independently of the generator, confirming
    the generator's own output against a second code path
  - A scratch copy of `scripts/` + `FormalSystem/Metalogic/` under the session scratchpad
    directory, used for every `--emit-inventory` / `--emit-inventory --check` invocation in this
    report — never run against the tracked working tree
- Generator source: `scripts/check-module-invariants.sh:207-603` (marker-option documentation,
  `scan()`, `render_block()`, the `--emit-inventory`/`--check` driver loop)
- Pure-filesystem counting helper: `scripts/lib/live_walk.py`
