# Implementation Plan: Task #817

- **Task**: 817 - Wrap the remaining count-carrying inventory tables under FormalSystem/ whose blockers are phantom or missing rows
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours
- **Dependencies**: None (parent task 744 completed; sibling task 818 owns a disjoint README set)
- **Research Inputs**: specs/817_wrap_remaining_phantom_row_inventory_tables/reports/01_wrap-remaining-phantom-row-tables.md
- **Artifacts**: plans/01_wrap-phantom-row-inventory-tables.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Six READMEs under `FormalSystem/` carry count-bearing inventory tables that are invisible to the
`INV` check in `scripts/check-module-invariants.sh`, because that check fails only on a stale
*wrapped* block and never sees an unwrapped table. Each is brought under the gate by wrapping it
in `<!-- BEGIN GENERATED: inventory ... -->` / `<!-- END GENERATED -->` markers and regenerating
via `bash scripts/check-module-invariants.sh --emit-inventory`. The row-set mismatches that kept
them out of the earlier sweep (phantom rows naming archived files, missing rows for live files,
`Sharing/`-prefixed keys the generator would not emit) are resolved per row before wrapping, so
no hand-written prose is silently dropped by the generator. The final phase demonstrates — rather
than assumes — that each newly wrapped block is now covered, by corrupting one count per block,
confirming `FAIL INV` names exactly that README, and restoring through the writer.

### Research Integration

The research report re-verified all six blockers against the live tree and settled every per-row
decision, so no decision work remains for the implementation:

- **All phantom rows are obsolete — drop, no re-homing.** Each traces to a file moved into
  `Boneyard/` (not deleted), and in no case does a live sibling continue the archived work
  (`Quasimodel/SubformulaClosure.lean` already covers `EnrichedClosure.lean`'s territory, so even
  that near-miss needs no re-homing). The generator's pinned-row logic drops them automatically
  on first regeneration — `os.path.isfile` is resolved against the *current* scan directory, and
  the `Boneyard/` copy is a different path — so no manual row deletion is required beyond the
  wrap.
- **Two findings beyond the dispatch's framing**, both carried into phases below:
  `Separation/Defs.lean`'s surviving row is a *content* mismatch (the live module is the
  integer-time `IntStructure`/`IntTruth` approach; the row describes the archived `N`-types
  approach), and `WitnessFamily/README.md`'s lower table is a stale duplicate of
  `WitnessFamily/Sharing/README.md`'s already-wrapped, already-current block — stale in content,
  not merely in counts.
- **No existing description in these six files contains an unescaped `|`**, so the
  `split_row` escaping hazard does not apply to the *carried* text. It still applies to any
  description newly drafted in Phase 1, 3 or 5.

### Premise Re-Validation (Carried-Figure Discipline)

Three trigger-class lines in the dispatch description were checked against live state and the
prior artifact, per report-format.md's Carried-Figure Discipline:

1. **"INV was green throughout because it fails only on a STALE WRAPPED BLOCK"** — confirmed
   live. `bash scripts/check-module-invariants.sh --no-build` run at planning time prints
   `PASS INV every generated inventory block is current, every hand-maintained one is exhaustive`
   and `ALL CHECKS PASSED`, while all six scoped READMEs remain unwrapped (`grep -c 'BEGIN
   GENERATED'` returns `0` for each). The prior-sweep figures ("23 READMEs", "29 of roughly 33")
   are the parent task's own measurements and were deliberately not re-derived; what was measured
   instead is that 52 READMEs under `FormalSystem/` now carry a generated block and that the six
   named here are not among them. The conclusion the description draws from those figures is
   therefore intact, independent of the exact prior counts.
2. **"BXCanonical/README.md fits apart from the pinned row `../BXCanonical.lean`, which the
   generator keeps with refreshed numbers"** — confirmed, with one refinement.
   `FormalSystem/Metalogic/BXCanonical.lean` exists and is 43 lines; the table's pinned row
   already states 43, so that cell is *current*, not stale, and regeneration will carry it
   unchanged. The eight loose rows are the stale ones (measured: 119/855/432/607/94/728/261/312
   in the table against live 116/844/503/620/96/719/258/294). The row *count* matches the live
   scan exactly (8 loose + 3 subdirectory + 1 pinned = 12).
3. **"corrupt one count, confirm INV FAIL names exactly that README, restore via the writer"** —
   this is a procedure instruction, not a measurement, and its feasibility is confirmed: the
   generator's own header documents `--emit-inventory` as the in-place rewriter and
   `--emit-inventory --check` as the byte-level verifier, and INV reports findings per file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch's delegation context; no roadmap phases are
included.

## Goals & Non-Goals

**Goals**:
- Bring seven inventory blocks across six READMEs under the `INV` gate by wrapping and
  regenerating them.
- Resolve every row-set mismatch (phantom rows, missing rows, mis-keyed rows) *before* wrapping,
  so no hand-written description is dropped and no live file is left with a
  `<!-- TODO: add description -->` placeholder.
- Demonstrate coverage per block by corrupt-then-restore, not by assertion.

**Non-Goals**:
- No change to the generator's column set or algorithm (`scripts/check-module-invariants.sh` is
  read, never edited).
- No Lean source changes. No `.lean` file is staged by any phase, which is why
  `.githooks/pre-commit`'s count-freshness gate is a structural no-op here (verified: it exits 0
  unless `git diff --cached --name-only --diff-filter=ACMRD -- '*.lean'` is non-empty).
- No hand-correction of counts in any table this task does not wrap — including the four
  column-set-mismatch READMEs reserved for their own task, and both `Compression/` 2-column
  tables. Such tables are *reported* in the final phase so the recurrence stays visible.
- No change to `WitnessFamily/Sharing/README.md`'s own already-wrapped block; it is read as the
  authoritative source for Phase 5, never edited.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A newly drafted description ships wrong under a byte-accurate count (8 Chronicle rows, 2 Separation rows, 1 Separation rewrite) | M | M | Draft every description from the file's own module docstring, never from memory; record the source file and line in the phase's commit body |
| `--emit-inventory` is a tree-wide writer: it rewrites *every* registered block, including a concurrent sibling's in-flight file | H | L | After every writer run, `git status --short` must show only this phase's own README modified; a foreign modification means STOP and report (territory discipline), never restore by hand |
| Phase 5's resync is a by-hand copy between two files before the generator owns the table | M | M | Diff the resynced descriptions textually against `Sharing/README.md`'s block before committing, not merely confirm the wrap succeeded |
| Two blocks (`WitnessFamily/README.md` lower, `Sharing/README.md`) describe the same 12 files; nothing keeps their hand-written columns in sync and INV never checks cross-block consistency | L | H | Accepted per the research's Decision 3, consistent with the existing `Compression/` top-level-summary convention; recorded again in the implementation summary so a future reader sees an accepted trade-off, not an undiscovered defect |
| A drafted description containing an inline `|` silently splits a cell | M | L | `split_row` is escape-aware: write `\|` in any new description; grep each new row for an unescaped `|` before regenerating |
| A drafted description trips a sibling check in the same gate (C5 dotted module paths must resolve; C9 forbids task-number citations under `FormalSystem/`) | M | L | Phase verification runs the whole `--no-build` gate, not INV alone, so C5/C9/C12/C13 are observed on every phase |

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
| 7 | 7 | 6 |

The chain is strictly serial by necessity, not by convention: `--emit-inventory` rewrites every
registered block in the tree on each invocation, so two phases cannot safely run concurrently on
this shared working tree. Phases 4 and 5 additionally edit the same file.

**Shared per-phase procedure** (applies to Phases 1-6; stated once rather than repeated):

1. Re-read the target README immediately before editing (a sibling may have changed it).
2. Apply the phase's row-set edits by hand (drop phantom rows, re-key, add rows, rewrite
   descriptions), leaving the table otherwise untouched.
3. Capture the pre-regeneration key/description pairs for the block:
   `awk '/^\| /' <README> | sed -n 's/^| *\([^|]*\) *|.*| *\(.*\) *|$/\1\t\2/p' | sort > /tmp/<name>.before`
   (adapt the field selection to the table's column count; the point is a key-sorted
   key-to-description mapping, not the exact one-liner).
4. Insert the `BEGIN GENERATED` / `END GENERATED` markers around the table with the phase's
   stated options.
5. Run `bash scripts/check-module-invariants.sh --emit-inventory`.
6. Capture the same mapping as `.after` and `diff` the two: every surviving key's description
   must be byte-identical. Alphabetical row reordering and `{:,}` thousands separators are
   expected regeneration effects and are *not* diffed as a whole-file diff.
7. Run `bash scripts/check-module-invariants.sh --no-build` and confirm `PASS INV` plus no new
   failure in C5/C9/C12/C13.
8. `git status --short`; confirm only this phase's README is modified; commit with an explicit
   file list (never `git add -A`, a directory, or a glob).

---

### Phase 1: Chronicle — drop one phantom row, wrap, and describe eight un-rowed live files [COMPLETED]

**Goal**: `FormalSystem/Metalogic/BXCanonical/Chronicle/README.md`'s table covers all 14 live
`.lean` files and is under the `INV` gate.

**Tasks**:
- [x] Delete the `HenkinDiscreteChain.lean` row (decision: obsolete — archived at
      `Boneyard/BXPipelineGapAnalysis/HenkinDiscreteChain.lean`, no live module continues it). *(completed)*
- [x] Draft a description for each of the 8 live files with no row —
      `ChronicleGuardAccumulation.lean`, `ChronicleLimitGapWitness.lean`,
      `ChronicleLimitGuardAbove.lean`, `ChronicleLimitGuardWitness.lean`,
      `ChronicleMonadicBridge.lean`, `ChronicleRealExtension.lean`,
      `ChronicleToCountermodelBasic.lean`, `MCSMixedCase.lean` — each taken from that file's own
      module docstring, and add it as a row. Record the source file and line for each in the
      commit body. Do not leave any `<!-- TODO: add description -->` placeholder standing.
      *(completed: each drawn from the file's own `/-! -/` module docstring, lines 10-28
      ChronicleGuardAccumulation, 12-23 ChronicleLimitGapWitness, 12-20 ChronicleLimitGuardAbove,
      12-20 ChronicleLimitGuardWitness, 18-27 ChronicleMonadicBridge, 11-18 ChronicleRealExtension,
      19-28 ChronicleToCountermodelBasic, 10-19 MCSMixedCase)*
- [x] Escape any inline `|` in a drafted description as `\|`; cite no task number (C9 covers
      `FormalSystem/`). *(completed: no drafted description contained an inline `|` or a task
      number; C9 confirmed PASS)*
- [x] Wrap with
      `<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/BXCanonical/Chronicle rows=loose cols=lines -->`
      and run the writer; apply the shared procedure's steps 3-8. *(completed)*

**Timing**: 1.0 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: The edit is confined to one markdown file with zero compile surface, and
`bash scripts/check-module-invariants.sh --no-build` is the specific check that covers it — it
runs INV (the block's own gate) plus C5, C9, C12 and C13 over this exact file in one pass.

**Scope Hypothesis**: 1 row dropped, 8 rows added, 14 rows in the regenerated block. Confirm with
`ls FormalSystem/Metalogic/BXCanonical/Chronicle/*.lean | wc -l` (expect 14) against the
post-regeneration row count; a mismatch means the live set moved since planning and the row list
must be re-derived from the directory, not from this plan.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Chronicle/README.md` - drop phantom row, add 8 rows, wrap
  and regenerate

**Verification**:
- Key-sorted before/after diff shows the 6 pre-existing real rows' descriptions byte-identical
  and the phantom row absent.
- No `TODO: add description` string remains in the file.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV` and no new C5/C9
  finding.
- `git status --short` lists only this README.

---

### Phase 2: Quasimodel and RestrictedMCS — two single-phantom-row wraps [COMPLETED]

**Goal**: Both READMEs are wrapped with no row additions; the two phantom rows are gone.

**Tasks**:
- [x] `FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md`: delete the
      `EnrichedClosure.lean` row (obsolete; the live `SubformulaClosure.lean` row's existing
      description already covers the G/H-enrichment territory). Wrap with
      `dir=FormalSystem/Metalogic/BXCanonical/Quasimodel rows=loose cols=lines`. *(completed)*
- [x] `FormalSystem/Metalogic/Core/RestrictedMCS/README.md`: delete the `Deferral.lean` row
      (obsolete; the deferral machinery was retired wholesale to
      `Boneyard/RestrictedMCSDeferral/Deferral.lean`, not merged into `Basic.lean`). Wrap with
      `dir=FormalSystem/Metalogic/Core/RestrictedMCS rows=loose cols=lines`. *(completed)*
- [x] Run the writer once after both edits and apply the shared procedure's steps 3-8 to each
      file. *(completed: both files regenerated to 5 and 1 rows respectively; key-sorted
      before/after diff empty for both)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Tier Justification**: Both edits are markdown-only with zero compile surface, and
`bash scripts/check-module-invariants.sh --no-build` covers both files' blocks in the same INV
pass that is the point of the wrap.

**Scope Hypothesis**: Quasimodel regenerates to exactly 5 rows and RestrictedMCS to exactly 1.
Confirm with `ls <dir>/*.lean | wc -l` for each (expect 5 and 1) before accepting the regenerated
block. `RestrictedMCS/Basic.lean`'s stated 653 is expected to refresh to its live count (368 at
planning time).

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md` - drop phantom row, wrap, regenerate
- `FormalSystem/Metalogic/Core/RestrictedMCS/README.md` - drop phantom row, wrap, regenerate

**Verification**:
- Key-sorted before/after diff: every surviving description byte-identical in both files; only
  numeric cells changed.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV`.
- `git status --short` lists only these two READMEs.

---

### Phase 3: Separation — drop twelve phantom rows, rewrite one description, add two rows [COMPLETED]

**Goal**: `FormalSystem/Metalogic/Expressiveness/Separation/README.md` describes the directory's
current three-file integer-time layout and is under the gate.

**Tasks**:
- [x] Delete the 10 phantom `.lean` rows (`Distributivity.lean`, `DualEliminations.lean`,
      `Duality.lean`, `Eliminations.lean`, `FormulaOps.lean`, `IntHelpers.lean`,
      `NegationEquiv.lean`, `NormalForm.lean`, `SeparationThm.lean`, `TemporalClosure.lean`) and
      the 2 phantom subdirectory rows (`DedekindZ/`, `Hierarchy/`) — all archived under
      `Boneyard/Kamp/KampWeakCanonical/Separation/` in a wholesale relocation of the superseded
      `N`-equivalence approach. *(completed)*
- [x] Rewrite `Defs.lean`'s description to match the live module (integer-time
      `IntStructure`/`IntTruth`/`IntEquiv`, the purity and `U`/`S`-freeness predicates, syntactic
      separation, and the structural depth measures), verified against the file's own docstring.
      Carrying the existing text forward would ship a wrong description under a byte-accurate
      count, because the generator matches on the key and the key survived the approach swap.
      *(completed: new description verified against `Defs.lean` lines 10-28's module docstring)*
- [x] Add rows for `KampTranslation.lean` and `SemanticBridge.lean`, each drafted from its own
      module docstring (the research supplies drafts; refine against the live docstring rather
      than pasting unverified). *(completed: drafted from each file's own `/-! -/` docstring,
      lines 10-30 KampTranslation, lines 9-23 SemanticBridge)*
- [x] Wrap with
      `dir=FormalSystem/Metalogic/Expressiveness/Separation rows=both cols=lines`
      (`rows=both` behaves identically to `rows=loose` today since no live subdirectory remains,
      and keeps the table self-correcting if one is added back), run the writer, apply the shared
      procedure's steps 3-8. *(completed: regenerated block has exactly 3 rows; before/after diff
      shows the 12 dropped keys and the 3 surviving/new descriptions as intended)*

**Timing**: 1.0 hours

**Depends on**: 2

**Verification Tier**: prose

**Tier Justification**: Markdown-only edit with zero compile surface, covered by
`bash scripts/check-module-invariants.sh --no-build`, whose C5 pass additionally checks that any
module-shaped path named in the three rewritten/added descriptions resolves.

**Scope Hypothesis**: 12 rows dropped, 2 rows added, 3 rows in the regenerated block. Confirm
with `ls FormalSystem/Metalogic/Expressiveness/Separation/` (expect `Defs.lean`,
`KampTranslation.lean`, `SemanticBridge.lean`, `README.md`, no subdirectories) before accepting
the regenerated block.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/Separation/README.md` - drop 12 phantom rows, rewrite the
  surviving Defs.lean description, add 2 rows, wrap and regenerate

**Verification**:
- Key-sorted before/after diff shows exactly three keys surviving, with `Defs.lean`'s description
  changed deliberately (the one intended description change in the phase) and the two new rows
  carrying real text, not placeholders.
- No `TODO: add description` string remains.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV` and `PASS C5`.
- `git status --short` lists only this README.

---

### Phase 4: WitnessFamily upper table — wrap with no row-set change [COMPLETED]

**Goal**: The `## Modules` table in
`FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` is under the gate.

**Tasks**:
- [x] Confirm the 7 existing rows still match the 7 live loose `.lean` files directly under
      `WitnessFamily/` (no phantom, no missing). *(completed: `ls *.lean | wc -l` = 7, matching
      Closure/Basic/Predicates/Std/Agreement/Decide/Examples)*
- [x] Wrap *only* that table with
      `dir=FormalSystem/Metalogic/Decidability/WitnessFamily rows=loose cols=lines`. `rows=loose`
      is deliberate, not a workaround: the two subdirectories are covered by their own tables
      below, so no subdirectory rows belong in this block. *(completed)*
- [x] Run the writer; `Std.lean`'s stated 120 is expected to refresh to its live count.
      *(completed)*
- [x] Confirm the `Compression/` 2-column section and the lower `Sharing/` table are byte-
      identical before and after this phase (they are out of this phase's scope, and
      `Compression/` is out of the task's scope entirely). *(completed: both sections diffed
      byte-identical before/after)*

**Timing**: 0.25 hours

**Depends on**: 3

**Verification Tier**: prose

**Tier Justification**: A marker-insertion-only markdown edit with zero compile surface, covered
by `bash scripts/check-module-invariants.sh --no-build`'s INV pass over this new block.

**Scope Hypothesis**: 0 rows added or dropped; 7 rows in the regenerated block. Confirm with
`ls FormalSystem/Metalogic/Decidability/WitnessFamily/*.lean | wc -l` (expect 7).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - wrap the `## Modules` table and
  regenerate

**Verification**:
- Key-sorted before/after diff: all 7 descriptions byte-identical; only numeric cells changed.
- A diff of the file restricted to the `Compression/` section and the `Sharing/` table shows no
  change.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV`.
- `git status --short` lists only this README.

---

### Phase 5: WitnessFamily lower table — resync from Sharing/README.md, re-key, add three rows, wrap [COMPLETED]

**Goal**: The `### Sharing/` table keys rows the way the generator emits them, carries current
descriptions, covers all 12 live `Sharing/` files, and is under the gate.

**Tasks**:
- [x] Read `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`'s existing
      generated block — it is already wrapped and already current — and treat it as the
      authoritative description source for this phase. *(completed)*
- [x] Replace the 9 existing rows' keys with bare, non-prefixed keys (`Basic.lean`, not
      `Sharing/Basic.lean`): `row_key()` strips only backticks and link syntax and performs no
      path normalization, so a `Sharing/`-prefixed key would orphan every description and the
      generator would drop all 9 to placeholders on first regeneration. *(completed)*
- [x] Replace the 9 descriptions' *text* with `Sharing/README.md`'s current text. The existing
      text is stale in content, not only in counts: it describes the pre-`Skeleton.lean`-
      extraction shape of `Basic.lean`, `Thread.lean`, `Frame.lean` and `Histories.lean`.
      *(completed)*
- [x] Add rows for the 3 live files with no row anywhere in this table — `Skeleton.lean`,
      `Stability.lean`, `Window.lean` — using `Sharing/README.md`'s existing descriptions, rather
      than letting the generator fill them with placeholders. *(completed)*
- [x] Escape any inline `|` carried across as `\|`. *(completed: none of the 12 resynced
      descriptions contains an inline `|`)*
- [x] Wrap with
      `dir=FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing rows=loose cols=lines`, run
      the writer, apply the shared procedure's steps 3-8. *(completed: writer reported "no
      generated inventory block needed a rewrite" since the pasted numeric cells were already
      current)*
- [x] Textually diff the 12 resynced descriptions against `Sharing/README.md`'s block (a
      copy-paste error here would plant a second independently-wrong description where there is
      currently an honestly-stale one). Record in the phase commit body that the resulting
      duplication between the two blocks is an accepted trade-off: INV checks each block against
      its own directory, never cross-block consistency. *(completed: diff of the 12 resynced
      key/description pairs against Sharing/README.md's own block is empty — byte-identical.
      The resulting duplication between `WitnessFamily/README.md`'s lower table and
      `Sharing/README.md`'s block is an accepted trade-off per the research's Decision 3: INV
      checks each generated block against its own directory's live files and never performs
      cross-block consistency checking, so nothing keeps the two copies in sync going forward —
      this mirrors the existing `Compression/` top-level-summary convention already accepted
      elsewhere in this tree.)*

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: prose

**Tier Justification**: Markdown-only edit with zero compile surface, covered by
`bash scripts/check-module-invariants.sh --no-build`, which runs INV over both this new block and
the `Sharing/README.md` block it was resynced from in the same pass.

**Scope Hypothesis**: 9 rows re-keyed and re-described, 3 rows added, 12 rows in the regenerated
block. Confirm with `ls FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/*.lean | wc -l`
(expect 12) and against `Sharing/README.md`'s own block's row count before accepting.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - re-key and resync the lower
  Sharing table, add 3 rows, wrap and regenerate

**Verification**:
- The regenerated block has 12 rows, no `TODO: add description` placeholder, and every numeric
  cell equal to the corresponding cell in `Sharing/README.md`'s block.
- `Sharing/README.md` itself is unmodified (`git status --short` lists only
  `WitnessFamily/README.md`).
- The `Compression/` section and the upper `## Modules` block are unchanged by this phase.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV`.

---

### Phase 6: BXCanonical — wrap the pinned-row table [COMPLETED]

**Goal**: `FormalSystem/Metalogic/BXCanonical/README.md` is under the gate, with the pinned
sibling-aggregator row surviving regeneration intact.

**Tasks**:
- [x] Make no row-set change: the table's 12 rows (8 loose + 3 subdirectory + 1 pinned
      `../BXCanonical.lean`) already match the live scan plus the pinned-row logic. *(completed:
      confirmed via `ls *.lean | wc -l` = 8 plus Chronicle=14, Filtration=1, Quasimodel=5)*
- [x] Wrap with `dir=FormalSystem/Metalogic/BXCanonical rows=both cols=lines` and run the writer.
      *(completed)*
- [x] Confirm the pinned row survived with its hand-written description carried verbatim — this
      is the specific path the earlier sweep never exercised, and it is the reason this README was
      deferred to this task. *(completed: `../BXCanonical.lean` row survived with its description
      byte-identical and its count unchanged at 43 — it was already current)*
- [x] Confirm the three subdirectory rows' embedded hand-written file counts ("(14 files)",
      "(1 file)", "(5 files)") still match the live directories (they did at planning time); these
      stay hand-written and ungated after the wrap, so note that residual in the phase commit
      body. Correct one only if it is actually wrong — these rows are inside a table this task
      wraps, so a correction here is in scope, unlike a table the task does not touch.
      *(completed: all three counts verified live-correct, no correction needed)*
- [x] Expect the subdirectory rows' `—` Lines cells to be replaced by real numbers under
      `cols=lines`; verify this is what the writer produced rather than assuming it.
      *(verified and the plan's expectation here was wrong, not the implementation: per
      `scripts/check-module-invariants.sh`'s `inventory_rows()`, a subdirectory row's Lines cell
      is driven by the `cols` option, not `rows` — `cols=files-lines` computes
      `[file_count, total_lines]`; any other `cols` value (including this phase's `cols=lines`)
      always emits a literal `["—"]` for a subdirectory row, with no numeric substitution. The
      regenerated block's three subdirectory rows correctly still read `—` for Lines; this is
      the same convention used by every other already-wrapped `rows=both cols=lines` README in
      the tree and is why the four column-set-mismatch READMEs needing real subdirectory numbers
      are reserved for `cols=files-lines` in their own task.)*

**Timing**: 0.5 hours

**Depends on**: 5

**Verification Tier**: prose

**Tier Justification**: Marker-insertion-only markdown edit with zero compile surface, covered by
`bash scripts/check-module-invariants.sh --no-build`'s INV pass, which is also the check that
would catch a dropped pinned row.

**Scope Hypothesis**: 0 rows added or dropped; 12 rows in the regenerated block, including
`../BXCanonical.lean`. Confirm with
`ls FormalSystem/Metalogic/BXCanonical/*.lean | wc -l` (expect 8) plus 3 subdirectories plus the
pinned row; if the pinned row is absent from the regenerated block, STOP — that is a generator
behavior this plan's premise (and the research's verification) says should not happen, and it
must be reported rather than worked around.

**Files to modify**:
- `FormalSystem/Metalogic/BXCanonical/README.md` - wrap and regenerate

**Verification**:
- Key-sorted before/after diff: all 12 descriptions byte-identical, including the pinned row's.
- The pinned row's `43` is unchanged (it is already current); the 8 loose rows' counts refresh to
  their live values.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS INV`.
- `git status --short` lists only this README.

---

### Phase 7: Demonstrate coverage for every new block, run the full gate, and report untouched stale tables [COMPLETED]

**Goal**: Each of the seven newly wrapped blocks is shown — not assumed — to be covered by the
`INV` gate, and the repository's full gate set is green.

**Tasks**:
- [x] For each newly wrapped block in turn (Chronicle, Quasimodel, RestrictedMCS, Separation,
      WitnessFamily upper, WitnessFamily lower, BXCanonical): corrupt exactly one numeric cell
      inside the block; run `bash scripts/check-module-invariants.sh --no-build`; confirm the
      output is `FAIL INV` and names exactly that README (and, for `WitnessFamily/README.md`,
      that the corrupted block is distinguishable from the other block in the same file — corrupt
      them one at a time, not together); restore with
      `bash scripts/check-module-invariants.sh --emit-inventory`; confirm `git diff` for that file
      is empty. Never restore with a pathspec checkout — the shared-worktree discipline in this
      dispatch's Territory block forbids it. *(completed: all 7 cycles pass, see summary for the
      per-cell evidence table)*
- [x] Record the seven corrupt/restore results in the implementation summary as evidence, with
      the exact cell corrupted and the exact failure line observed for each. *(completed)*
- [x] Run the full gate: `bash scripts/check-module-invariants.sh` (no `--no-build`, so its build
      pass runs). Because the build may take many minutes, run it detached with a hard timeout
      and poll per `context/patterns/bounded-build-waiter.md` (captured PID, `kill -0` liveness,
      one waiter per log) rather than a foreground call. *(completed: detached run finished with
      `ALL CHECKS PASSED`, zero `FAIL` lines, `lake build` and `lake build BimodalTest` both
      exit 0)*
- [x] Run `bash scripts/check-module-invariants.sh --emit-inventory --check` and confirm it exits
      0 (no registered block would change a byte). *(completed: exit 0, `PASS INV`)*
- [x] Report, without fixing, every other count-carrying inventory table under `FormalSystem/`
      that is still unwrapped or stale — in particular the four column-set-mismatch READMEs
      reserved for their own task and the `Compression/` 2-column tables. Listing them keeps the
      recurrence visible, per the task's NON-GOALS. *(completed, see summary; one finding beyond
      the dispatch's framing: two additional unwrapped tables not reserved by any known task were
      found — `Decidability/Verified/Termination/MintBound/README.md` (4-column `Module | Lines
      | Decls | Role`, a column-set mismatch like the four reserved ones) and
      `Expressiveness/SeparationZ/README.md` (a clean 3-column table whose 13 rows match the 13
      live files exactly — trivially wrappable, simply never wrapped, no blocker at all))*
- [x] Note in the summary that `.githooks/pre-commit`'s count-freshness gate never fired for this
      task, because no phase staged a `.lean` path, and that `typst/generated/status.typ` is
      therefore untouched and uncoupled to this work (verified: `scripts/typst-sync-check.sh`
      contains no inventory-block logic). *(completed: verified no `.lean` path was staged by any
      phase and `typst/generated/status.typ` carries no diff across this task's 6 phase commits)*

**Timing**: 1.25 hours

**Depends on**: 6

**Verification Tier**: full

**Scope Hypothesis**: seven newly wrapped blocks across six READMEs (WitnessFamily/README.md carries two). Confirm with `grep -rc 'BEGIN GENERATED: inventory' <the six READMEs>` summing to 7 before starting the corrupt/restore cycles; a different total means an earlier phase did not land as planned and must be re-checked rather than worked around here.

**Files to modify**:
- No file is modified by this phase in its final state: each corruption is restored through the
  writer and verified to leave an empty diff. (`FormalSystem/**/README.md` files are touched
  transiently by the corrupt/restore cycle.)

**Verification**:
- Seven corrupt/restore cycles each produced a `FAIL INV` naming exactly the expected README and
  an empty `git diff` after restoration.
- `bash scripts/check-module-invariants.sh` (full run, including its build pass) reports
  `ALL CHECKS PASSED`, with `PASS INV` among them. This is the complete gate set for this
  repository's inventory surface; `verify-deploy.sh` is not applicable, since no phase touches
  `.claude/**` or the `agent-system/extensions` source store.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `git status --short` shows no modified file outside `specs/` at phase end.

**Batch Gate Deferral discharge note**: this dispatch's Batch Gate Deferral directive asks a
narrowing invocation (`run-all.sh --only SUITE` or `verify-deploy.sh --only-gate N`) to cover
this phase's full-tier verification wherever one of those tools can express it. Neither can:
`check-module-invariants.sh` has no matching suite basename for `--only` and no matching gate
number for `--only-gate` — it is this repository's own domain-specific Lean/markdown invariant
gate, unrelated to the `.claude/` deploy/test surface either narrowing tool covers. Per the
directive's own UNMAPPABLE CRITERION clause, the named check was run directly instead (exactly
as this phase's own Verification already specifies) and that direct run is the scoped discharge
recorded here.

## Testing & Validation

- [x] All seven blocks carry `<!-- BEGIN GENERATED: inventory ... -->` / `<!-- END GENERATED -->`
      markers with the options this plan names.
- [x] No `<!-- TODO: add description -->` placeholder exists in any of the six READMEs.
- [x] Every surviving hand-written description is byte-identical across its phase's regeneration,
      verified by key-sorted diff, except the three deliberate description changes in Phase 3 and
      the twelve deliberate resyncs in Phase 5.
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [x] `bash scripts/check-module-invariants.sh` (full) reports `ALL CHECKS PASSED`.
- [x] Each of the seven blocks demonstrably fails `INV` when one of its counts is corrupted.
- [x] No `.lean` file was modified or staged by any phase.

## Artifacts & Outputs

- Six modified READMEs under `FormalSystem/` carrying seven generated inventory blocks.
- One commit per phase, each staging only that phase's README(s) by explicit file list.
- An implementation summary recording: the per-row obsolete/re-home decisions as executed, the
  docstring source for every newly drafted description, the seven corrupt/restore coverage
  results, the accepted `WitnessFamily`/`Sharing` duplication trade-off, and the list of
  still-stale tables deliberately left untouched.

## Rollback/Contingency

- Before the first phase, take a non-reverting defensive checkpoint:
  `bash .claude/scripts/git-snapshot.sh 817 --no-revert`. Do not use the default reverting form —
  this is a shared working tree with concurrent siblings.
- To undo a phase's regeneration mid-phase, remove the `BEGIN GENERATED`/`END GENERATED` markers
  by hand and restore the table text from the phase's `.before` capture. Never use
  `git checkout -- <path>` or `git restore <path>`: a pathspec discard on this shared tree can
  take a sibling's work with it, and the destructive-git guard blocks it on a dirty tree anyway.
- If a writer run modifies a file outside this task's scope, STOP: check `git log` to confirm the
  change is not this task's own, leave the file alone, and report it rather than reverting or
  committing it.
- Each phase is independently committed, so a failed later phase leaves earlier wraps intact and
  gated; the task can resume at the failed phase without redoing prior work.
