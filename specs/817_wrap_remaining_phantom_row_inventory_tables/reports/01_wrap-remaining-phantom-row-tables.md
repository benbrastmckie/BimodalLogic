# Research Report: Task #817

**Task**: 817 - Wrap the remaining count-carrying inventory tables under FormalSystem/ whose blockers are phantom or missing rows
**Started**: 2026-11-12T17:19:23Z
**Completed**: 2026-11-12
**Effort**: ~1 session (6 READMEs, 1 planner-sized implementation)
**Dependencies**: parent task 744 (wrapped the first 23 READMEs; its report named this Tier B bucket)
**Sources/Inputs**: Codebase (`FormalSystem/`, `Boneyard/`), git history, `scripts/check-module-invariants.sh`, parent task 744's report
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- All six scoped READMEs were re-verified against the live tree; every blocker named in the
  dispatch is confirmed exactly as stated, with one additional finding the dispatch did not
  name (see below).
- Five phantom rows (`HenkinDiscreteChain.lean`, `EnrichedClosure.lean`, `Deferral.lean`, and
  the 10 Separation `.lean` rows + 2 subdirectory rows) all resolve to files that were moved to
  `Boneyard/` and never deleted from their README. **Decision for all of them: obsolete, drop**
  — none needs re-homing, because in every case either no live file continues the archived
  work, or (Quasimodel only) a live sibling file's own existing description already covers the
  same territory. `--emit-inventory`'s pinned-row logic drops these automatically; no manual
  deletion is required beyond wrapping.
- **New finding, not named in the dispatch**: `WitnessFamily/README.md`'s lower
  (`Sharing/`-prefixed) table is not merely mis-keyed — it duplicates
  `WitnessFamily/Sharing/README.md`'s own already-wrapped, already-current table, and its nine
  existing descriptions are *stale content*, not just stale counts: they describe the
  pre-refactor shape of `Basic.lean`/`Thread.lean`/`Frame.lean`/`Histories.lean` before the
  `Skeleton.lean` extraction, while `Sharing/README.md`'s table already reflects the
  post-refactor shape. Three live Sharing files (`Skeleton.lean`, `Stability.lean`,
  `Window.lean`) have no row in either the dispatch's framing or the stale duplicate.
  Recommendation: resync the duplicate table's content from `Sharing/README.md` (the
  authoritative, current source) before wrapping, rather than let the generator fill three new
  rows with `<!-- TODO: add description -->` placeholders.
- `FormalSystem/Metalogic/Expressiveness/Separation/README.md`'s one surviving real row
  (`Defs.lean`) is also a content mismatch, not just a phantom-row problem: the live
  `Defs.lean` is a different module (integer-time `IntStructure`/`IntTruth` definitions) than
  the one the existing description names (`N-types, separating formulas`). This needs a
  rewritten description, not merely a refreshed count.
- `FormalSystem/Metalogic/BXCanonical/README.md` is confirmed to need no row-set changes at
  all — its blocker is purely the untested pinned-row path, which this research verifies
  resolves correctly (`../BXCanonical.lean` still exists, 43 lines away from its table's stale
  count).
- No existing description in the six READMEs contains an unescaped `|`, so the
  `split_row`/escaping note in the dispatch does not apply to this batch (it mattered for the
  parent task's `RaySummary/README.md`, not here).

## Context & Scope

Parent task 744 wrapped 23 READMEs under `FormalSystem/` in `<!-- BEGIN GENERATED: inventory -->`
markers and left a Tier B bucket of READMEs whose generated-table shape "fits with a documented
caveat" rather than fitting as-is. Of that bucket, two items were absorbed by task 744 itself
(the two named `RaySummary`/`KTypeSummary` targets) and two more (`Kamp/README.md`,
`Kamp/NfMultiAnchorBridge/README.md`) are a concurrent sibling's territory (task 818, scheduled
this same orchestrate cycle — confirmed via this dispatch's Territory block). The six READMEs
below are everything left in Tier B, each with a row-set mismatch (not a column-set mismatch —
those four are explicitly out of scope, reserved for their own task per the dispatch's
NON-GOALS).

This research re-verifies each named blocker against the current tree (git HEAD, working tree
clean of non-`specs/` changes at research time — confirmed via `git status --porcelain` showing
only `specs/TODO.md`, `specs/events.jsonl`, `specs/state.json`, `.pid`, and an unrelated
`specs/evidence/` directory, none of which this task's `file_scope` touches), decides per
phantom row whether its description is worth re-homing or is simply obsolete, and recommends the
exact `--emit-inventory` marker options the implementer should use for each file. No wrapping,
regeneration, or coverage-demonstration (corrupt-then-restore) work was performed in this
research phase — that is the implementation phase's job, per the general-research-agent
contract. `bash scripts/check-module-invariants.sh --no-build` was run read-only to confirm the
INV check is currently green (it is: `PASS INV every generated inventory block is current,
every hand-maintained one is exhaustive`), confirming the dispatch's claim that these six
unwrapped tables are invisible to the gate today.

## Findings

### 1. `FormalSystem/Metalogic/BXCanonical/Chronicle/README.md`

Live directory: 14 `.lean` files. Current table: 7 rows — 6 real (`ChronicleConstruction.lean`,
`ChronicleToCountermodel.lean`, `ChronicleTypes.lean`, `CounterexampleElimination.lean`,
`PointInsertion.lean`, `RRelation.lean`) plus 1 phantom (`HenkinDiscreteChain.lean`). The 8 live
files with no row: `ChronicleGuardAccumulation.lean`, `ChronicleLimitGapWitness.lean`,
`ChronicleLimitGuardAbove.lean`, `ChronicleLimitGuardWitness.lean`, `ChronicleMonadicBridge.lean`,
`ChronicleRealExtension.lean`, `ChronicleToCountermodelBasic.lean`, `MCSMixedCase.lean` — exactly
matches the dispatch's "8 live files carry no row."

`HenkinDiscreteChain.lean` traces (via `git log --all --diff-filter=A`) to task 202's "6
approaches to sorry-free completeness_discrete" commit, and the file is now archived at
`Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean` (confirmed present, 130 lines, header
`ARCHIVED (Boneyard) — never compiled`, moved there by task 630 phase 6's archive relocation).
None of the 8 un-rowed live files duplicate its "Henkin witness chain" theme (checked each
module's docstring: guard-accumulation invariant, two definable-gap discharges, a real-bundle
transport, a monadic bridge, a basic-block re-export, and a mixed-case elimination — all
distinct topics).

**Decision: obsolete, drop.** The description names infrastructure for an approach that was
tried and shelved; nothing live continues it. Let `--emit-inventory` drop the row (its target no
longer resolves under the directory and the Boneyard copy is a different path).

### 2. `FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md`

Live directory: exactly 5 `.lean` files (`Construction.lean`, `HintikkaPoint.lean`,
`LocusControl.lean`, `Realization.lean`, `SubformulaClosure.lean`), each already carrying a row.
The lone problem is the phantom `EnrichedClosure.lean` row — no missing live files, no
re-ordering needed.

`EnrichedClosure.lean` traces to `Boneyard/BXCanonicalQuasimodel/EnrichedClosure.lean`, archived
2026-06-16 with the stated reason "Dead code — quasimodel enriched closure with no live
downstream consumers." Its docstring describes a Fisher-Ladner style enriched closure
(`enrichedClosure`, `enriched_target_mem`, G/H-negation enrichment). The live sibling
`SubformulaClosure.lean`'s own docstring already states "G/H enrichment for locus-control" and
"Negation pairing" as part of its `SubformulaClosure` definition — i.e. the enrichment concept
the phantom row describes was folded into the live `SubformulaClosure.lean` rather than kept as
a separate file.

**Decision: obsolete, drop.** No re-homing needed — the live `SubformulaClosure.lean` row's
existing description already covers this ground.

### 3. `FormalSystem/Metalogic/Core/RestrictedMCS/README.md`

Live directory: exactly 1 `.lean` file (`Basic.lean`, 368 lines; table states 653, stale and
will be auto-refreshed). The phantom `Deferral.lean` row is the only mismatch.

`Deferral.lean` traces to task 174 phase 4, which split the original `RestrictedMCS.lean` (1414
lines) into `Basic.lean` (~650 lines) and `Deferral.lean` (~760 lines: `DeferralRestrictedMCS`
definitions, negation completeness, closure-under-derivation, the implication property,
`theorem_in_drm`, a `G_neg` lemma). `Deferral.lean` is now archived at
`Boneyard/RestrictedMCSDeferral/Deferral.lean` (moved by the same task 630 phase 6 archive
relocation as above). None of that deferral machinery (grepped `Deferral`/`DeferralRestrictedMCS`
in the live `Basic.lean`) survives in the live file.

**Decision: obsolete, drop.** The deferral machinery was retired wholesale, not merged into
`Basic.lean`; there is no live module to re-home the description onto.

### 4. `FormalSystem/Metalogic/Expressiveness/Separation/README.md`

Live directory: exactly 3 files (`Defs.lean`, `KampTranslation.lean`, `SemanticBridge.lean`, plus
`README.md`) — no subdirectories. Current table: 11 `.lean` rows + 2 subdirectory rows
(`DedekindZ/`, `Hierarchy/`). Confirmed via `find Boneyard/Kamp/KampWeakCanonical/Separation/`:
all 10 phantom `.lean` files (`Distributivity.lean`, `DualEliminations.lean`, `Duality.lean`,
`Eliminations.lean`, `FormulaOps.lean`, `IntHelpers.lean`, `NegationEquiv.lean`,
`NormalForm.lean`, `SeparationThm.lean`, `TemporalClosure.lean`) and both phantom subdirectories
are archived there intact — this was a wholesale relocation of an older separation-theorem
approach (`N`-equivalence over naturals, per the old descriptions) to the Boneyard, superseded by
a new integer-time approach.

**One row the dispatch did not call out as phantom still needs a decision**: `Defs.lean` exists
in both the old table and the live directory, but its *content* changed with the approach swap.
The live `Defs.lean`'s docstring is "Separation Definitions: Integer Temporal Semantics... Core
definitions for the separation theorem over integer time (GHR94 Chapter 10.2)" with key
definitions `IntStructure`, `IntTruth`, `IntEquiv`, `IsPurePast`/`IsPureFuture`/`IsPurePresent`,
`isUFree`/`isSFree`, `isSyntacticallySeparated`, `IsSeparable`, `junctionDepth`/`uDepthUnderS`/
`countUSubformulas`. The table's current description ("Core definitions for the separation
argument: N-types, separating formulas") names the old, now-archived approach's vocabulary.

**Decision: obsolete (10 phantom rows + 2 phantom subdirectory rows), drop — and rewrite
`Defs.lean`'s description** to match its current content (suggested: "Core definitions for the
separation theorem over integer time (GHR94 10.2): `IntStructure`/`IntTruth`/`IntEquiv`,
purity and `U`/`S`-freeness predicates, syntactic separation, and the structural depth
measures"). Two new live files need descriptions, since neither has ever had a row:
- `KampTranslation.lean`: "Infrastructure for {U,S} expressive completeness on Z-structures
  (Kamp's theorem for integer time): formula-list operations and atom-literal construction for
  the Kamp translation. The full translation is blocked on the n-variable Fraisse game
  argument — see the module's own Status section."
- `SemanticBridge.lean`: "Connects `IntStructure`/`IntTruth` (separation framework) with
  `OrderedMonadicStructure`/`TemporalTruth` (completeness framework): `zStructureToInt` and the
  truth/equivalence transport lemmas on the Z-carrier."

These are drafts for the implementer to use or refine, not binding text.

### 5. `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md`

This README has three markdown tables, only two of which this task touches (the dispatch's
"upper table" and "lower table"); the middle one is a 2-column `Module | Role` table with no
numeric column (the `Compression/` section) and is out of scope — it is the same shape as the
parent task's named Tier C bucket item "`WitnessFamily/Compression`" and carries nothing that can
drift.

**Upper table** (`## Modules`, 7 rows: `Closure.lean`, `Basic.lean`, `Predicates.lean`,
`Std.lean`, `Agreement.lean`, `Decide.lean`, `Examples.lean`): matches the 7 live loose `.lean`
files directly under `WitnessFamily/` exactly — no phantom, no missing rows. The dispatch's
"rows=loose-shaped (no subdirectory rows for `Compression/`, `Sharing/`)" is a correct
description of its current shape, not itself a defect: `rows=loose` is a legitimate, deliberate
marker option (subdirectory rollups are handled by the two dedicated nested tables/READMEs
below it), so wrapping this table `dir=.../WitnessFamily rows=loose cols=lines` requires no
row-set change at all, only the `BEGIN`/`END` markers. `Std.lean`'s stated count (120) is stale
against the live 119 and will auto-correct.

**Lower table** (`## Sharing — the branching device`, 9 rows, each keyed
`Sharing/<File>.lean`): the dispatch's framing ("keys rows on `Sharing/`-prefixed paths the
generator would not emit") is correct but incomplete. Confirmed via `row_key()`'s source (strips
only backticks/link syntax, no path normalization) that wrapping this table unchanged with
`dir=.../WitnessFamily/Sharing` would make every one of its 9 existing descriptions orphan (scan
keys are bare `Basic.lean`, not `Sharing/Basic.lean`), dropping all 9 to `<!-- TODO: add
description -->` on first regeneration — the exact "silent drop" failure mode the dispatch's
PROCEDURE warns against, just at table scope rather than row scope.

**Additional finding beyond the dispatch's framing**: `WitnessFamily/Sharing/README.md` (one
level down) already has its own `<!-- BEGIN GENERATED: inventory
dir=FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing -->` block, already wrapped,
already current — its 12 rows' line counts match `wc -l` on every file exactly (verified:
`Agreement.lean` 460, `Basic.lean` 293, `Decide.lean` 622, `Frame.lean` 267, `Fulfil.lean` 1752,
`Histories.lean` 111, `Predicates.lean` 245, `Skeleton.lean` 1644, `Specialize.lean` 465,
`Stability.lean` 174, `Thread.lean` 189, `Window.lean` 720). The top-level duplicate's 9
descriptions are not just stale in *count* but stale in *content*: they describe the pre-
`Skeleton.lean`-extraction shape (e.g. the duplicate's `Sharing/Basic.lean` row: "the decoded
representative map `rep`, and the sharing relation `share`"; the current, correct
`Sharing/README.md` row for the same file: "its `skeleton` projection, and the re-exports of
`rep`, `share`, the equivalence laws and the two periodicities" — a real architectural change,
not just rewording). The 3 live files with no row anywhere in the duplicate (`Skeleton.lean`,
`Stability.lean`, `Window.lean`) already have current, accurate descriptions one directory down.

This confirms parent task 744's own Tier C note calling this table a duplicate of
`Sharing/README.md`'s table was correct, and sharpens it: the duplicate is not merely redundant,
it is actively wrong about three files' content and silent about three others.

### 6. `FormalSystem/Metalogic/BXCanonical/README.md`

Live directory: 8 loose `.lean` files (`CanonicalChain.lean`, `CanonicalModel.lean`,
`Completeness.lean`, `CompletenessDedekind.lean`, `DiscreteCarrierProbe.lean`, `Frame.lean`,
`OrderedSeedConsistency.lean`, `TruthLemma.lean`) + 3 subdirectories (`Chronicle/` — 14 files,
`Filtration/` — 1 file, `Quasimodel/` — 5 files). The current table has exactly these 11 rows
plus one pinned row for the sibling aggregator `../BXCanonical.lean` (43 live lines, outside the
scanned directory but still resolving via `os.path.normpath`), for 12 rows total — matching the
live scan + pinned-row logic byte-for-byte in row *count*. Every numeric cell is stale by a small
margin (expected drift; e.g. `CanonicalModel.lean` 855 vs. live 844), and the subdirectory file
counts baked into the hand-written descriptions ("(14 files)", "(1 file)", "(5 files)") are
already correct and will need no hand-editing.

**Decision: no row-set change needed.** This README needs only wrapping
(`dir=FormalSystem/Metalogic/BXCanonical rows=both cols=lines`) and regeneration; the dispatch's
framing ("fits apart from the pinned row... left out only because the pinned-row path was never
exercised") is confirmed exactly — this research is the exercise, and it resolves correctly: the
pinned-row branch's `os.path.isfile` check on `../BXCanonical.lean` succeeds, so the row survives
with a refreshed count and its hand-written description carried forward verbatim.

## Decisions

1. **Phantom rows: obsolete, drop (no re-homing) — Chronicle `HenkinDiscreteChain.lean`,
   Quasimodel `EnrichedClosure.lean`, RestrictedMCS `Deferral.lean`, and all 10 Separation
   `.lean` rows + 2 Separation subdirectory rows (`DedekindZ/`, `Hierarchy/`).** Every one
   traces to a specific Boneyard archive path (verified via `git log --diff-filter=A` plus a
   direct filesystem check of the archive location), and in no case does a live sibling file
   continue the archived work under a different name (checked Quasimodel's `SubformulaClosure.lean`
   explicitly, since its theme is closest; the other four directories' live files are
   confirmed topically distinct via docstring review). `--emit-inventory`'s pinned-row logic
   (`os.path.isfile` against the *current* scan directory) drops each of these automatically
   on first regeneration; no manual row deletion is required, only the wrap.

2. **Separation's `Defs.lean` description must be rewritten, not merely refreshed.** The file
   name survived an approach swap but the content did not; carrying the old description forward
   verbatim (which `--emit-inventory` would do by default, since the key matches) would ship a
   wrong description under a byte-accurate line count. This is outside the dispatch's named
   "phantom row" framing but is the same class of risk the PROCEDURE exists to catch, so it is
   flagged for explicit implementer action rather than silently carried.

3. **WitnessFamily's lower (Sharing) table: resync from `Sharing/README.md` before wrapping,
   using bare (non-prefixed) keys, then wrap `dir=.../WitnessFamily/Sharing`.** This is the
   dispatch's named remedy ("fits with a documented caveat"), sharpened by this research: do not
   just strip the `Sharing/` prefix from the 9 existing keys — replace their description text
   with `Sharing/README.md`'s current text (the authoritative, already-verified-current source)
   and add rows for `Skeleton.lean`, `Stability.lean`, `Window.lean` using that same source,
   rather than let the generator fill them with `<!-- TODO: add description -->` placeholders.
   The resulting duplication between the two README's tables (both describing the same 12
   files) is accepted as consistent with this codebase's existing convention of a top-level
   summary table alongside a nested directory's own fuller README (the same pattern
   `Compression/` already uses, just without a numeric column there). An alternative — dropping
   the duplicate table's `Lines` column entirely, matching `Compression/`'s 2-column shape and
   taking it out of `--emit-inventory` scope altogether — is a legitimate competing option
   (eliminates the duplication risk at the cost of losing the top-level line-count visibility);
   this report recommends the wrap-and-resync option because the dispatch classifies this table
   as Tier B ("fits with a caveat"), not Tier C ("does not fit the column set"), and the task's
   own framing is about *wrapping* count-carrying tables rather than removing their counts, but
   the alternative is recorded here since it is a real design choice, not a foregone one.

4. **BXCanonical's own README and WitnessFamily's upper table need no row-set change, only
   wrapping.** Confirmed by direct scan-vs-table comparison; the implementer's work here is
   purely mechanical (add markers, run `--emit-inventory`, diff).

## Recommendations

For the planning phase, one phase per README (six phases) plus a seventh demonstrate-coverage
phase is the natural decomposition, matching the dispatch's PROCEDURE and DEMONSTRATE COVERAGE
sections:

1. **Chronicle** — drop `HenkinDiscreteChain.lean` row; wrap
   `dir=FormalSystem/Metalogic/BXCanonical/Chronicle rows=loose cols=lines`; regenerate; the 8
   previously-missing live files will each get a `TODO: add description` placeholder that the
   implementer should fill with a real description (drawn from each file's own docstring, as
   this research did for the other directories) rather than leave as a TODO, since the task's
   PROCEDURE language ("do not let the generator silently drop prose") implies the same care on
   the add side.
2. **Quasimodel** — drop `EnrichedClosure.lean` row; wrap
   `dir=FormalSystem/Metalogic/BXCanonical/Quasimodel rows=loose cols=lines`; regenerate (no
   missing-row placeholders expected — every live file already has a row).
3. **RestrictedMCS** — drop `Deferral.lean` row; wrap
   `dir=FormalSystem/Metalogic/Core/RestrictedMCS rows=loose cols=lines`; regenerate.
4. **Separation** — drop the 10 phantom `.lean` rows and 2 phantom subdirectory rows; rewrite
   `Defs.lean`'s description per Decision 2; add rows (with real descriptions, drafts supplied
   in Finding 4) for `KampTranslation.lean` and `SemanticBridge.lean`; wrap
   `dir=FormalSystem/Metalogic/Expressiveness/Separation rows=both cols=lines` (either `rows=both`
   or `rows=loose` behaves identically today since no live subdirectory remains, but `rows=both`
   keeps the table self-correcting if a subdirectory is ever added back); regenerate.
5. **WitnessFamily, upper table** — wrap `dir=FormalSystem/Metalogic/Decidability/WitnessFamily
   rows=loose cols=lines` with no row-set change; regenerate.
6. **WitnessFamily, lower table** — resync per Decision 3 (re-key, resync descriptions from
   `Sharing/README.md`, add the 3 missing rows), then wrap
   `dir=FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing rows=loose cols=lines`;
   regenerate; diff against `Sharing/README.md`'s own block to confirm the two now agree
   byte-for-byte on every numeric cell (descriptions may still differ in wording, since each
   block carries its own hand-written column independently — that divergence risk is accepted
   per Decision 3, not eliminated by this wrap).
7. **BXCanonical** — wrap `dir=FormalSystem/Metalogic/BXCanonical rows=both cols=lines` with no
   row-set change; regenerate; this is the one case where the entire phase should be
   near-mechanical, since this research already confirmed the pinned-row path resolves cleanly.
8. **Demonstrate coverage** (one sub-step per newly-wrapped block, or one combined step covering
   all six, per the planner's judgment) — corrupt one numeric cell in each of the six files
   (seven generated blocks, since WitnessFamily has two), run
   `bash scripts/check-module-invariants.sh --no-build` and confirm `FAIL INV` names exactly
   that README (and, for WitnessFamily, exactly the block that was corrupted — the two blocks in
   one file should be independently distinguishable in the failure output if both are corrupted
   in sequence, or at minimum the single corrupted one should be named), then restore via
   `--emit-inventory` (never a pathspec checkout, per the shared-worktree discipline this
   dispatch's Territory block requires) and confirm the diff is empty.

Verification method for every phase: a key-sorted before/after diff of the wrapped block's rows
(not a whole-file diff), per the dispatch's own instruction — alphabetical reordering and
`{:,}` thousands-separator formatting are expected regeneration side effects, not defects.

## Risks & Mitigations

- **Risk**: filling the 8 Chronicle placeholder rows (and Separation's 2 new rows) with
  descriptions invites the same judgment-call risk this task exists to avoid — a wrong
  description ships with a byte-accurate count and nothing catches it until a human reads it.
  **Mitigation**: draft descriptions from each file's own module docstring (as this research did
  for Separation's `KampTranslation.lean`/`SemanticBridge.lean`), not from memory or inference,
  and have the implementer state the source line for each in its phase summary.
- **Risk**: the WitnessFamily lower-table resync (Decision 3) is the one step in this batch that
  is not purely mechanical — it requires copying text between two files by hand before the
  generator can safely own the table. A copy-paste error here would plant a second,
  independently-wrong description where there is currently at least an honestly-stale one.
  **Mitigation**: the implementer should diff the resynced table's descriptions against
  `Sharing/README.md`'s block textually (not just confirm the wrap succeeds) before committing.
- **Risk**: two generated blocks in two different files (`WitnessFamily/README.md`'s lower table
  and `WitnessFamily/Sharing/README.md`'s table) now describe the same 12 files from the same
  scanned directory. Nothing in `--emit-inventory` keeps their hand-written description columns
  in sync going forward — a future edit to one will not propagate to the other, and INV will not
  catch the divergence (INV only checks that each block matches its own directory's current file
  set and counts, never cross-block consistency). **Mitigation**: this is accepted, per Decision
  3, as consistent with the existing `Compression/` top-level-summary-plus-nested-README
  convention; it is recorded here, and should be recorded again in the implementation summary,
  so a future reader understands it is an accepted trade-off rather than an undiscovered defect.
- **Risk**: this task's NON-GOALS forbid hand-correcting counts in tables this task does not
  wrap. The four column-set-mismatch READMEs (reserved for their own task) and the `Compression/`
  2-column tables (both the nested `Compression/README.md` and the inline subtable in
  `WitnessFamily/README.md`) must not be touched even opportunistically while this task's
  implementer is already editing `WitnessFamily/README.md` for the other two tables in the same
  file. **Mitigation**: the planner/implementer should scope the WitnessFamily phase's diff
  explicitly to the two named tables (by line range) and verify the `Compression/` section is
  byte-identical before and after.

## Context Extension Recommendations

None. This is a one-off repo-hygiene cleanup task; the generator's own design (marker options,
pinned-row logic, escape-aware `split_row`) is already documented at length in
`scripts/check-module-invariants.sh`'s own header comments, which this research relied on
directly and found sufficient. No gap in `.claude/context/` was identified.

## Appendix

### Search queries / commands used

- `git log --oneline --all --diff-filter=A -- '*/<File>.lean'` and
  `git rev-list --all | xargs -I{} git ls-tree -r {} --name-only | grep -i <File>` — to trace
  each phantom row's file across every historical path (including pre-`Boneyard/` archive
  locations and the `Theories/Bimodal` -> `FormalSystem` rename).
- `find Boneyard -iname <File>.lean` / `ls <archive-dir>` — to confirm current archive location
  and content for each phantom row.
- `wc -l` against every live `.lean` file in each of the six directories (plus `Compression/`
  and `Sharing/` for WitnessFamily) — to independently verify every numeric cell's current
  correct value, cross-checked against the generator's own `line_count`/`{:,}` formatting
  convention.
- `bash scripts/check-module-invariants.sh --no-build` — read-only confirmation that INV is
  currently green (no wrapped block in the tree is stale), supporting the dispatch's claim that
  these six unwrapped tables are invisible to the gate.
- `sed -n '1,Np' <file>.lean | grep -A N "^/-!"` — module docstring extraction for every
  previously-un-rowed or content-mismatched live file, used as the source for every drafted
  description in this report.

### References

- `specs/archive/744_wrap_inventory_tables_generated_markers/reports/01_wrap-inventory-tables-generated-markers.md`
  — parent task's Tier A/B/C classification and Decisions D1-D4, which this task's scope and
  PROCEDURE both derive from.
- `scripts/check-module-invariants.sh` lines ~200-330 (marker-option header comment) and
  ~420-610 (`render_block`, `row_key`, `scan`, `audit_hand_maintained` — the generator's actual
  carry-forward and pinned-row logic this report's decisions depend on).
