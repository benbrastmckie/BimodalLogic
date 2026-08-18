# Implementation Plan: Task #452

- **Task**: 452 - correct_roadmap_sorry_inventory_and_bxcanonical_status
- **Status**: [IMPLEMENTING]
- **Effort**: 4.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/reports/01_roadmap-sorry-bxcanonical-correction.md
- **Artifacts**: plans/01_roadmap-sorry-bxcanonical-correction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

`specs/ROADMAP.md` asserts, in several independently-drifted places, that the live tree carries
23 (or 19, or 17) sorries and that `FormalSystem/Metalogic/BXCanonical/` is abandoned dead code.
Both claims are inverted: `scripts/check-module-invariants.sh` check C3 verifies **exactly one**
structural sorry in the whole non-Boneyard tree (`countermodel_discrete`, in
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`), and check C2 baselines four flagship
theorems that all live in the `BXCanonical` namespace. This plan corrects every prose section of
ROADMAP.md that asserts a sorry count, a dead-code verdict, or a module status contradicted by a
named check, leaves the Paper Alignment Programme and the 111-row status tables untouched, and
records the deliverable-(c) sweep result including the sections that needed no edit.

Definition of done: no sorry-count, dead-code, or module-status claim remains in ROADMAP.md that
is not either (i) reproducible from a named `check-module-invariants.sh` check, or (ii) explicitly
and unmistakably marked historical. No `.lean` file is touched; nothing is archived; no sorry is
closed, moved, or reclassified.

### Research Integration

The research report (`reports/01_roadmap-sorry-bxcanonical-correction.md`) supplies the ground
truth this plan is built on and is treated as authoritative for the following, all re-run live at
implementation time in Phase 1:

- **C3 (2026-08-18, at `11ad049b8`)**: exactly one structural sorry, `countermodel_discrete` in
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`. C3 asserts this **by enclosing
  declaration name, never by line number** — the line has already drifted `:1277` -> `:1242` ->
  `:1068` across prior ROADMAP.md edits while the declaration stayed constant. Every reference this
  plan writes cites the declaration and the check, never a line number.
- **C2**: `BXCanonical.completeness`, `.completeness_dense`, `.completeness_discrete`, and
  `.Chronicle.countermodel_dense` all match the recorded axiom baseline; the latter three are
  `[propext, Classical.choice, Quot.sound]`-clean, and `completeness`'s lone `sorryAx` traces to
  the same single C3 sorry via `WeakCanonical.countermodel_discrete` — not to anything inside
  BXCanonical.
- **Architecture**: `FormalSystem/Metalogic.lean`'s own module docstring calls `BXCanonical/`
  "the wired entry point"; `FormalSystem/Metalogic/StrongCompleteness.lean` imports
  `FormalSystem.Metalogic.BXCanonical.CompletenessDedekind` directly; `Chronicle/` is a
  **subdirectory of** `BXCanonical/`, not a rival path.
- **Occurrence catalog**: the false "BXCanonical dead code, ~17 sorries" claim appears at four
  sites (ROADMAP.md ~19-23, ~296, ~598-599, ~624-630), two of them inside the `## Overview`
  section the file's own preamble declares current. Correcting only the line-624 section named in
  the task description would leave the same false claim standing in the authoritative part of the
  document.
- **Explicit no-edit list**: `## Dead Ends (Archived)` (self-labeled historical), the `## Overview`
  block at line 271 that is already labeled `**Sorry summary (HISTORICAL ...)**`, and
  `## Paper Alignment Programme` (re-issued 2026-08-10, and out of scope per the task).

**Two corrections to the research report, both verified during planning:**

1. **The task's stated verification mechanism does not cover the file being edited.** C5 walks the
   repository with `specs` in its excluded-directory list (`dirs[:] = [d for d in dirs if d not in
   (".git", ".lake", "specs", "Boneyard", "build", "__pycache__")]`), so `specs/ROADMAP.md` is
   **not** scanned by C5 at all — and C5 only matches dotted `FormalSystem.X.Y` module names, never
   slash-shaped paths like `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`. C5 will therefore
   pass identically before and after every edit in this plan and cannot serve as evidence that the
   references introduced here resolve. Phase 1 stands up a bespoke resolution check for ROADMAP.md
   in its place; C5 is still run every phase, as a no-regression guard on the rest of the repo.
2. **The 2026-07-27 sorry-count table is not covered by the HISTORICAL label.** The research report
   records the table at ROADMAP.md:302-308 as "already correctly labeled HISTORICAL — no edit
   needed". It is not. The `**Sorry summary (HISTORICAL — ...)**` label at line 271 governs the
   discrete-branch bullet lists that follow it; a *new*, unlabeled block opens at line 296 with
   `**Sorry summary (dead code)**: ~17 sorries ...`, and the 19-sorry table at 298-306 sits under
   that block, not under the historical one. It is in scope for Phase 2.

**Two additional defects found during planning, not in the research catalog** (both in
`## Other Open Items`, both directly checkable, both in scope for Phase 6):

- `### Examples / Pedagogical (~57 sorries)` — `FormalSystem/Examples/` contains **zero**
  occurrences of the token `sorry` in any form, and none of the five files it names
  (`Demo.lean`, `ModalProofs.lean`, `ModalProofStrategies.lean`, `TemporalProofs.lean`) exists;
  the directory holds `BimodalProofs.lean`, `TemporalStructures.lean`, and `README.md`. This is
  the same defect class as the Sorry Inventory and would independently contradict C3, which scans
  all of `FormalSystem/` outside the Boneyards and finds exactly one hit.
- `### Boneyard (~14 sorries)` — the same C3 sorry-shape grep run against `FormalSystem/Boneyard`
  returns **104**, not ~14.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` is the artifact this task edits, not a plan input; no roadmap-review or
roadmap-update phases apply (`roadmap_flag` was not set). The task advances ROADMAP.md's own
accuracy as a navigational document for the completeness programme. The 111-row status tables —
the surface `roadmap-integration.sh` matches against — are explicitly out of scope and are not
touched by any phase.

## Goals & Non-Goals

**Goals**:

- Rewrite `## Sorry Inventory` against C3's live output: one entry, cited by enclosing declaration,
  with `scripts/check-module-invariants.sh` check C3 named as the generator of record so the
  section cannot silently rot again (deliverable a).
- Correct **all four** occurrences of the "BXCanonical is dead code / ~17 sorries" claim, including
  the two inside `## Overview`, retaining the abandonment record only under headings that cannot be
  mistaken for current status (deliverable b).
- Correct the `## Module Import Graph` tree and its `~5,795 lines / 16 files / 19 sorries` closing
  line, and the `### Completeness Theorem` paragraph that routes through the Boneyard-only
  `RootScopedChain.lean`, since both duplicate and technically justify the numbers deliverable (a)
  removes.
- Correct the four rows of `## Legacy Code Inventory` that list currently-live files as archived.
- Correct the three sorry-count claims in `## Other Open Items` that C2/C3 contradict.
- Mark the remaining stale sections (`## Recommended Priority Order`, `## Task Cross-Reference`)
  unmistakably stale without rewriting them, and record the complete sweep, including no-edit
  findings, in the implementation summary (deliverable c).
- Leave a verification trail: every retained or introduced file/module reference resolves in the
  live tree, checked mechanically.

**Non-Goals**:

- No `.lean` edits of any kind.
- No closing, moving, reclassifying, or renumbering of any actual sorry.
- No archival of `BXCanonical` or any other module to `Boneyard/`.
- No edits to `## Paper Alignment Programme` or to the 111-row status tables.
- No edits to `specs/state.json` or `specs/TODO.md` task statuses — in particular, task 109's
  recorded status is **not** touched, even where ROADMAP.md prose about it is corrected.
- No rewrite of `## Recommended Priority Order` / `## Task Cross-Reference` content; these get a
  staleness banner only and a spawn recommendation (see Phase 7 and Phase 8).
- No new permanent scripts; the ROADMAP reference check is an ad-hoc command documented in this
  plan, not a checked-in file.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The task's named verification (C5) silently does not cover `specs/ROADMAP.md`, giving false assurance that introduced references resolve | H | H (confirmed, not hypothetical) | Phase 1 stands up the bespoke ROADMAP-scoped resolution check; every editing phase runs it on its own changed hunks; C5 still runs as a whole-repo no-regression guard |
| Line numbers in this plan and in the research report drift as earlier phases land, so a later phase edits the wrong region | H | H | Standing rule below: every phase re-locates its target by a quoted content anchor via `grep -n`, never by a line number carried from this document |
| Over-correction of sections that are already correctly labeled historical (`## Dead Ends (Archived)`, the line-271 `HISTORICAL` block) | M | M | Phases name their targets exclusively; Phase 8 diffs the full change set against the explicit no-edit list and fails the gate on any hunk outside a phase's declared region |
| Scope creep into `## Recommended Priority Order` / `## Task Cross-Reference`, whose real fix crosses into `state.json` task-status territory | M | M | Phase 7 is banner-only by contract; Phase 8 emits a follow-up task recommendation instead of absorbing the work |
| A rewritten section re-introduces a bare `RootScopedChain.lean` reference that reads as live | M | M | Any retained reference to that file is written as a full `FormalSystem/Boneyard/.../RootScopedChain.lean` path or as explicitly-past prose; Phase 8 greps for bare occurrences |
| A new claim is written that no check can reproduce | M | L | Every count or status claim introduced must name the check (C2/C3/C6/C7) or the live-tree command that produced it; Phase 8 audits the introduced text for unsourced claims |
| The one live sorry moves file or declaration between planning and implementation | L | L | Phase 1 re-runs C3 and uses its live output verbatim rather than this document's transcription |

## Implementation Phases

**Standing rules for every editing phase** (2-8):

1. **Locate by content, not by line.** Every phase begins with `grep -n` on a quoted anchor string
   to find its target region in the current file. The line numbers in this plan are as of
   `11ad049b8` and are informational only; they shift as soon as any earlier phase lands.
2. **Cite the check, never a line number**, for any sorry or axiom claim — C3's own implementation
   comment states this rule ("Never assert a line number") and the enclosing-declaration name is
   the stable anchor.
3. **Every claim names its source.** A count, status, or dead/live verdict introduced by an edit
   must be traceable to a named check (C2, C3, C6, C7) or to a live-tree command reproduced in the
   summary. If neither exists, the claim does not go in.
4. **Date and attribute rewritten blocks.** Follow the `## Overview` section's existing
   self-superseding convention: a rewritten block carries its own date and, where it replaces a
   prior claim, explicitly marks that prior claim superseded rather than deleting the history
   silently.
5. **Run the phase gate before committing**: the ROADMAP reference check from Phase 1 over the
   changed hunks, plus `bash scripts/check-module-invariants.sh --no-build` for C4/C5/C8/C9/C10
   no-regression.

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
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
every phase edits regions of the single file `specs/ROADMAP.md`, and each landed edit shifts the
line numbering of everything below it. Do not parallelize these phases across agents even under
`--team`.

---

### Phase 1: Capture live ground truth and stand up the ROADMAP reference check [COMPLETED]

**Goal**: Produce the verified factual basis every later phase writes from, and replace the
task's inapplicable C5 verification with one that actually covers `specs/ROADMAP.md`.

**Tasks**:

- [x] Run `bash scripts/check-module-invariants.sh` (full, with build) and capture verbatim: the
      C2 four-theorem axiom lines, the C3 PASS line **and** its `enclosing declaration:` note, the
      C5 line, and the C6/C7 lines. Record the `git rev-parse --short HEAD` these were taken at.
- [x] If C3 does not report exactly one sorry in `countermodel_discrete`, **stop and re-scope**:
      the ground truth this whole plan writes from has changed. Record the actual output and mark
      the phase `[BLOCKED]` rather than proceeding on a stale premise.
- [x] Record the live BXCanonical inventory:
      `find FormalSystem/Metalogic/BXCanonical -maxdepth 1 -name '*.lean' | sort` and
      `find FormalSystem/Metalogic/BXCanonical -mindepth 1 -maxdepth 1 -type d | sort`.
- [x] Record `grep -n "BXCanonical" FormalSystem/Metalogic/StrongCompleteness.lean` and the
      `BXCanonical`/`WeakCanonical` lines of `FormalSystem/Metalogic.lean`'s module docstring — the
      in-tree evidence that BXCanonical is the wired entry point.
- [x] Confirm the four BXCanonical-dead-code occurrences and their current line numbers:
      `grep -n "17 sorries\|dead code\|DEAD CODE" specs/ROADMAP.md`.
- [x] Confirm the Sorry Inventory anchors: `grep -n "23 sorry\|Sorry Inventory\|RootScopedChain\|19 sorries" specs/ROADMAP.md`.
- [x] Define and record the **ROADMAP reference check** used by every later phase (ad-hoc, not a
      checked-in script) — extract every `FormalSystem/...` slash path and every dotted
      `FormalSystem.X.Y` module name from the changed hunks and assert each resolves to a real file
      or directory, e.g.:
      `git diff -U0 -- specs/ROADMAP.md | grep '^+' | grep -oE '(FormalSystem|Tests)(/[A-Za-z0-9_]+)+\.lean' | sort -u | while read -r p; do [ -e "$p" ] || echo "UNRESOLVED: $p"; done`
      plus the dotted-name equivalent. Record the exact command text in the phase notes so later
      phases and the summary run the identical check.
- [x] Confirm both defects found at planning time still hold:
      `grep -rc 'sorry' FormalSystem/Examples` (expect zero matches) and the C3 sorry-shape grep
      against `FormalSystem/Boneyard` (expect ~104, not ~14).

**Timing**: 30 minutes

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts (i) exactly one live structural sorry in
`countermodel_discrete`, (ii) four BXCanonical-dead-code occurrences in ROADMAP.md, (iii) seven
top-level `.lean` files under `BXCanonical/` plus the `Chronicle/`, `Quasimodel/`, `Filtration/`
subdirectories, and (iv) zero sorries in `FormalSystem/Examples/` against ~104 in
`FormalSystem/Boneyard/`. All four are hypotheses inherited from research or from planning-time
spot checks; this phase's entire purpose is to confirm them against the live tree at
implementation time. Any that fails to confirm invalidates the phase that depends on it — record
the discrepancy and re-scope that phase rather than writing the plan's number.

**Files to modify**: none (read-only capture phase).

**Verification**:

- Full `check-module-invariants.sh` run captured, with C2/C3 output quoted verbatim.
- The ROADMAP reference check command is recorded and produces no output (clean baseline) when run
  against an empty diff.
- Every hypothesis above is explicitly marked confirmed or refuted in the phase notes.

---

### Phase 2: Correct all four BXCanonical dead-code claims [COMPLETED]

**Goal**: Remove the false "BXCanonical is dead code with ~17 sorries" verdict from every place it
appears, so that no reader of any part of the document is told the flagship module is abandoned.
This is deliverable (b), widened from the single section the task description names to the full
occurrence set the research found.

**Tasks**:

- [x] **Occurrence 1 — `## Overview` "Completeness architecture" paragraph** (anchor: `is the primary and only`, ~19-23). Replace with the current three-route architecture stated by
      `FormalSystem/Metalogic.lean`'s docstring: `BXCanonical/` is the wired entry point;
      `Chronicle/` is a subdirectory of it serving the dense branch; `WeakCanonical/` (Kamp-Reynolds)
      serves the discrete branch; `BXCanonical/CompletenessDedekind.lean` serves the Dedekind/real-line
      route with no case split. Cite C2's four-theorem baseline.
- [x] **Occurrence 2 — `## Overview` "Sorry summary (dead code)" block** (anchor:
      `**Sorry summary (dead code)**`, ~296). This block and the 19-sorry table immediately under it
      (`| **Total BXCanonical** | **19** | 7 files | |`) are **not** covered by the `HISTORICAL`
      label at ~271, which governs the earlier discrete-branch bullet lists. Either relabel this
      block explicitly historical in the same style as the ~271 label, or replace it with the C3
      one-sorry statement. Also correct the trailing paragraph asserting the 5 critical-path
      `RootScopedChain.lean` sorries at lines 1065/1092/1099/1107/1114 "block `dd_countermodel`".
- [x] **Occurrence 3 — `## Active Metalogic Paths` intro** (anchor: `is the sole active`, ~597-599).
      Same correction as occurrence 1, stated for the section it introduces.
- [x] **Occurrence 4 — `### BXCanonical Path (DEAD CODE — Task 109 Abandoned)`** (anchor:
      `BXCanonical Path (DEAD CODE`, ~624-630). Rewrite the heading so it cannot read as current
      status. Retain the task-109 abandonment record only under an unmistakably historical heading
      (e.g. `### Historical: the task-109 BXCanonical abandonment (2026-05-10, superseded)`), and
      state the current status alongside it: BXCanonical is the live, wired entry point; the
      subsequently-added `CompletenessDedekind.lean` and `Completeness.lean` routes are what the
      2026-05-10 assessment did not anticipate.
- [x] Verify no fifth occurrence was introduced or missed: re-run the occurrence grep from Phase 1
      and confirm every remaining hit is inside an explicitly historical block.

**Timing**: 60 minutes

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: Asserts exactly four occurrences of the dead-code claim. Confirm at
implementation time with the Phase 1 occurrence grep **after** the edits as well as before — if a
fifth site surfaces, correct it in this phase rather than deferring it, and record the count
correction.

**Files to modify**:

- `specs/ROADMAP.md` — four regions: the `## Overview` completeness-architecture paragraph, the
  `## Overview` `Sorry summary (dead code)` block and its table, the `## Active Metalogic Paths`
  intro paragraph, and the `### BXCanonical Path (DEAD CODE ...)` subsection.

**Verification**:

- `grep -n "dead code\|DEAD CODE\|~17 sorries" specs/ROADMAP.md` returns only hits inside blocks
  explicitly marked historical.
- Every introduced claim about BXCanonical's status names C2 or the `Metalogic.lean` docstring.
- ROADMAP reference check clean over the changed hunks; `check-module-invariants.sh --no-build`
  shows no new failures versus the Phase 1 baseline.

---

### Phase 3: Rewrite the Sorry Inventory section against C3 [COMPLETED]

**Goal**: Replace the 23-sorry inventory and its two tables of dead file:line rows with the single
live entry C3 verifies, plus a pointer naming C3 as the generator of record. This is deliverable
(a).

**Tasks**:

- [x] Locate the section (anchor: `## Sorry Inventory`, ~881) and its four subsections:
      `### Critical Path (5 sorries in RootScopedChain.lean)`,
      `### Irreflexive-Consequence (18 sorries across 6 files)`,
      `### Irreflexive Semantics Strategy (Plan v48, 2026-04-19)`,
      `### Closed Sorries (Tasks 90+92+98+102)`.
- [x] Replace the opening claim `The BXCanonical module has **23 sorry proofs** in three
      categories.` with the C3-verified state: exactly one structural sorry in the live
      (non-Boneyard) tree, `countermodel_discrete` in
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, owned by the Base weak-completeness
      terminus. State the enclosing declaration, **not** a line number, and say why (C3 asserts by
      content because the line drifts).
- [x] Add the generator-of-record pointer: `scripts/check-module-invariants.sh` check C3 is what
      produces this inventory; regenerate rather than hand-edit. Note C3's scope precisely — the
      four structural sorry shapes it greps for, across `FormalSystem/` with both Boneyards
      excluded — so a future reader knows what the count does and does not include.
- [x] Delete the `### Critical Path (5 sorries in RootScopedChain.lean)` table, or convert it to an
      explicitly historical record. Its five rows point at
      `FormalSystem/Boneyard/DefectDirectedChain/RootScopedChain.lean` and
      `FormalSystem/Boneyard/ScheduleBasedBFMCS/RootScopedChain.lean`; if any row is retained, its
      path must be written in full including the `Boneyard/` segment so it cannot read as live.
- [x] Apply the same treatment to `### Irreflexive-Consequence (18 sorries across 6 files)`. Note
      the section's own internal inconsistency as part of the record if retaining it: the table
      sums to 14 while both the heading and the `## Overview` table say 18.
- [x] Leave `### Irreflexive Semantics Strategy` and `### Closed Sorries` in place as historical
      technical exposition, but check their closing claims (e.g. `Frame.lean has **1 sorry**`)
      against C3 and relabel any that assert current state.
- [x] Add the C2 axiom-baseline statement for the four flagship theorems, so the section answers
      "what is provably clean" as well as "what is open".

**Timing**: 60 minutes

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: Asserts the section spans four subsections whose tables total 5 + 18 rows,
and that no live file:line row survives the rewrite. Confirm by enumerating the section's `###`
headings and its table rows before editing, and by grepping the rewritten section for any
`.lean:` line-number reference afterward.

**Files to modify**:

- `specs/ROADMAP.md` — the `## Sorry Inventory` section in full.

**Verification**:

- `grep -n "23 sorry" specs/ROADMAP.md` returns nothing outside an explicitly historical context.
- No `RootScopedChain.lean` reference in the section lacks a `Boneyard/` path segment or
  past-tense framing.
- No `file.lean:NNN` line-number citation for the live sorry anywhere in the section.
- Section names `scripts/check-module-invariants.sh` check C3 as the generator of record.
- ROADMAP reference check clean; `check-module-invariants.sh --no-build` no new failures.

---

### Phase 4: Correct the Module Import Graph and Completeness Theorem delegation [COMPLETED]

**Goal**: Remove the second, technically-detailed justification for the numbers Phase 3 deleted.
The import graph shows `RootScopedChain.lean (1,487 lines, 5 sorries)` as a live import of
`Completeness.lean` and closes with `~5,795 lines across 16 files, 19 sorries`; the
`### Completeness Theorem` subsection routes step 4 of the proof through `dd_countermodel` in
that same Boneyard-only file.

**Tasks**:

- [x] Locate the graph (anchor: `### Module Import Graph`, ~631-711). Rebuild or retire it against
      the live inventory captured in Phase 1. If rebuilding, derive the file list from
      `find FormalSystem/Metalogic/BXCanonical` rather than editing the existing tree in place; if
      retiring, replace with a short pointer to `FormalSystem/Metalogic.lean`'s docstring and
      `FormalSystem/Metalogic/BXCanonical/BXCanonical.lean` as the in-tree source of truth, marked
      with the reason the hand-maintained graph was retired.
- [x] Remove or correct the closing line
      `**Total BXCanonical module: ~5,795 lines across 16 files, 19 sorries ...**`. Any replacement
      count must come from a command reproduced in the summary (C7's live inventory line, or an
      explicit `find`/`wc -l`), not from arithmetic on the old tree.
- [x] Correct the trailing `Legacy files (...) are still built via top-level aggregation in
      Metalogic.lean` paragraph — `FormalSystem/Metalogic.lean` now aggregates only `Soundness`,
      `Decidability`, `BXCanonical`, and `WeakCanonical`; verify against the live file before
      writing the replacement. *(deviation: altered — the live file actually has 6 top-level
      imports (Soundness, StrongCompleteness, Decidability, Independence, BXCanonical,
      WeakCanonical), not the 4 hypothesized here; wrote the verified 6-import list)*
- [x] Locate `### Completeness Theorem` (anchor: `Step 4 is handled by`, ~784-788) and correct the
      claim that `Completeness.lean` calls `dd_countermodel` in `RootScopedChain.lean`. Replace
      with the current route per `Completeness.lean`'s own docstring, or, if establishing that
      requires reading beyond a docstring, mark the step explicitly as a historical description of
      the 2026-04 pipeline and point at `Metalogic.lean`'s docstring for the current one. Do not
      guess the current call chain.
- [x] Sanity-check the remaining subsections of `## Canonical Model Construction (BXCanonical)`
      (`### BXPoint`, `### Canonical Temporal Ordering`, `### Canonical Modal Equivalence`,
      `### Key Infrastructure Lemmas`, `### Truth Lemma`) — these carry `Frame.lean:46-53`-style
      line citations. Do not re-verify each line range (out of scope); do add a dated note that the
      line citations in this section are as of 2026-04 and may have drifted, so a reader does not
      treat them as current.

**Timing**: 45 minutes

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: Asserts the live `BXCanonical/` top level holds 7 `.lean` files plus the
`Chronicle/`, `Quasimodel/`, and `Filtration/` subdirectories, against the graph's claimed 16
files. Confirm with the Phase 1 `find` output at implementation time; if the live count differs,
use the live count and record the correction.

**Files to modify**:

- `specs/ROADMAP.md` — `### Module Import Graph`, its closing total line and trailing legacy-files
  paragraph, and the `### Completeness Theorem` closing paragraph.

**Verification**:

- No surviving line in the section claims a sorry count for `BXCanonical` that C3 contradicts.
- Every `.lean` path in the rewritten graph resolves in the live tree (ROADMAP reference check).
- Any retained `RootScopedChain` reference carries its `Boneyard/` path or past-tense framing.
- `check-module-invariants.sh --no-build` no new failures.

---

### Phase 5: Correct the Legacy Code Inventory [NOT STARTED]

**Goal**: Four of the eight rows list files as archived to `Boneyard/StrictSemanticsLegacy/` that
are live in the tree today. This is a direct, cheap, checkable module-status defect of exactly the
class deliverable (c) asks to sweep for.

**Tasks**:

- [ ] Locate the section (anchor: `## Legacy Code Inventory`, ~963) and its 8-row table.
- [ ] Re-verify each row's file at implementation time with `find`/`test -f` against both the live
      path and the `FormalSystem/Boneyard/StrictSemanticsLegacy/` path. Planning-time result:
      genuinely archived — `Algebraic/UltrafilterChain.lean`, `Algebraic/DovetailedChain.lean`,
      `Bundle/SuccChainFMCS.lean` (all three present under `Boneyard/StrictSemanticsLegacy/`),
      and `FrameConditions/Completeness.lean` (absent from the live tree). Still live —
      `FormalSystem/Metalogic/Algebraic/LindenbaumQuotient.lean`,
      `FormalSystem/Metalogic/Algebraic/InteriorOperators.lean`,
      `FormalSystem/Metalogic/Bundle/SuccRelation.lean`,
      `FormalSystem/Metalogic/Bundle/CanonicalFrame.lean`.
- [ ] Correct the four wrong rows: split the table, or add a status column distinguishing archived
      from live-but-unreachable. Do not delete the live files' rows outright — their
      "not imported by BXCanonical" status is separately informative.
- [ ] Cross-reference C6 for the two live-but-unreachable `Algebraic` modules. Note in the summary
      (not necessarily in ROADMAP.md) that C6 flags `Algebraic.LindenbaumQuotient` and
      `Algebraic.InteriorOperators` as unreachable-but-live modules absent from
      `scripts/module-invariants-manifest.txt`. **Do not fix the C6 finding** — it is a manifest
      change outside this task's ROADMAP.md-only charter; surface it for the follow-up task
      instead.
- [ ] Leave the section's `**Verification**:` grep block intact if it still returns nothing; re-run
      it to confirm.

**Timing**: 30 minutes

**Depends on**: 4

**Verification Tier**: prose

**Scope Hypothesis**: Asserts exactly 4 of the 8 table rows are wrong. Confirm by running the
existence check over all 8 rows at implementation time before editing any of them; if the split is
not 4/4, use the live result.

**Files to modify**:

- `specs/ROADMAP.md` — the `## Legacy Code Inventory` table and its surrounding claim that task 94
  archived all listed files.

**Verification**:

- Every path in the corrected table resolves at the location the row claims for it (live path for
  live rows, `Boneyard/` path for archived rows) — checked mechanically, all 8 rows.
- The section's own verification grep still returns nothing.
- `check-module-invariants.sh --no-build` no new failures.

---

### Phase 6: Correct the Other Open Items sorry counts [NOT STARTED]

**Goal**: Three claims in this section assert sorry counts that C2 and C3 contradict. Two of the
three were found during planning and are not in the research catalog.

**Tasks**:

- [ ] `### Dense Completeness (task 68, 1 sorry)` (anchor, ~1441): C2 shows
      `BXCanonical.completeness_dense` carries `[propext, Classical.choice, Quot.sound]` — no
      `sorryAx`. Correct the heading's `1 sorry` and the `dense_completeness_fc needs a separate
      proof` body, or mark the entry resolved with its date. If `dense_completeness_fc` still
      exists as a distinct unproved statement, say so explicitly and cite what shows it; do not
      silently equate it with `completeness_dense`.
- [ ] `### Examples / Pedagogical (~57 sorries)` (anchor, ~1464): `FormalSystem/Examples/` contains
      zero occurrences of `sorry` in any form, and none of the four named files (`Demo.lean`,
      `ModalProofs.lean`, `ModalProofStrategies.lean`, `TemporalProofs.lean`) exists — the
      directory holds `BimodalProofs.lean`, `TemporalStructures.lean`, `README.md`. Correct both
      the count and the file list, or retire the entry. Re-verify with
      `grep -rn 'sorry' FormalSystem/Examples` and `ls FormalSystem/Examples` before writing.
- [ ] `### Boneyard (~14 sorries)` (anchor, ~1470): the C3 sorry-shape grep against
      `FormalSystem/Boneyard` returns ~104. Correct the figure, and state the command that produces
      it so it is reproducible; note that C3 deliberately excludes both Boneyards from its
      assertion, so this number is informational and is not a check-asserted invariant.
- [ ] Leave `### FMP Truth Preservation` and `### Soundness (sorry-free)` alone unless the
      re-verification above shows them contradicted — both were consistent with C3 at planning time
      (zero live sorries in either).

**Timing**: 30 minutes

**Depends on**: 5

**Verification Tier**: prose

**Scope Hypothesis**: Asserts exactly three defective entries in this section (Dense Completeness,
Examples, Boneyard) and two clean ones (FMP, Soundness). Confirm by running the sorry-shape grep
per named directory/file at implementation time; the Examples figure (0 vs ~57) and the Boneyard
figure (~104 vs ~14) in particular must be re-derived, not copied from this plan.

**Files to modify**:

- `specs/ROADMAP.md` — `### Dense Completeness`, `### Examples / Pedagogical`, `### Boneyard`
  entries under `## Other Open Items`.

**Verification**:

- Each corrected count is accompanied by the command that reproduces it.
- No file named in the Examples entry fails to exist.
- `check-module-invariants.sh --no-build` no new failures.

---

### Phase 7: Stale-mark remaining sections and assemble the sweep record [NOT STARTED]

**Goal**: Close out the sweep: mark the sections this task deliberately does not rewrite so they
cannot be read as current, and assemble the full sweep finding — including the sections that
needed no edit — for the summary.

**Tasks**:

- [ ] `## Recommended Priority Order` (anchor, ~1681) and its `### Critical Path: Single Sorry
      Chain` subsection: add a dated staleness banner at the section head stating that the section
      predates the current architecture, naming the specific defect (it asserts
      `nf_nvar_exist_all_depths` in `KampPrior.lean` as the sole blocking sorry, which
      `KampPrior.lean`'s own comments record as since closed; C3's live answer is
      `countermodel_discrete`), and pointing to the `## Overview` current-state block and to
      `## Sorry Inventory` as rewritten by Phase 3. **Banner only — do not rewrite the section's
      content**, and do not touch its per-task recommendations.
- [ ] `### Sorry Cleanup: Zero Sorries for Publication` item 6 (anchor: `Relocate Chronicle`):
      flag inline that this recommendation was inverted by what actually happened — Chronicle
      stayed inside `BXCanonical/` and `BXCanonical` became the flagship. A one-line inline note is
      in scope; rewriting the item list is not.
- [ ] `## Task Cross-Reference` (anchor, ~1740): add the same dated staleness banner above the
      table, noting specifically that the task-109 row's `Close 23 BXCanonical sorries` description
      is the same defect corrected elsewhere in this pass. **Do not edit the table rows** and do not
      touch task 109's recorded status in `specs/state.json` — that crosses out of this task's
      ROADMAP.md-only charter and belongs to the follow-up task.
- [ ] `### Current Strategy: Chronicle Construction (Task 107)` inside `## Dead Ends (Archived)`
      (anchor, ~1380): the parent section is already self-labeled historical, so this needs no
      edit; confirm the parent label is intact and record the finding as no-edit-needed.
- [ ] Assemble the sweep record for the summary: every section examined, its verdict
      (corrected / banner-only / no edit needed), and the evidence. Explicitly include the no-edit
      findings the task asks for — `## Dead Ends (Archived)`, the `## Overview` line-271 HISTORICAL
      block, `## Paper Alignment Programme`, `### FMP Truth Preservation`, `### Soundness`, and the
      111-row status tables.

**Timing**: 30 minutes

**Depends on**: 6

**Verification Tier**: prose

**Scope Hypothesis**: Asserts the banner-only set is exactly `## Recommended Priority Order`
(plus its two flagged sub-items) and `## Task Cross-Reference`. If the pass surfaces a further
section asserting a check-contradicted claim, banner it here and record the addition rather than
silently expanding a rewrite.

**Files to modify**:

- `specs/ROADMAP.md` — staleness banners at `## Recommended Priority Order` and
  `## Task Cross-Reference`; one inline note at the `Relocate Chronicle` item.

**Verification**:

- Banners are dated and name the specific defect, not just "may be stale".
- No content line inside the bannered sections is modified (confirm with `git diff` — the only
  additions in those regions are the banner and the single inline note).
- `specs/state.json` and `specs/TODO.md` are unmodified by this phase.

---

### Phase 8: Final verification, summary, and follow-up recommendation [NOT STARTED]

**Goal**: Prove the whole change set satisfies the task's verification contract, write the summary
carrying the deliverable-(c) sweep, and hand off the deliberately-excluded scope.

**Tasks**:

- [ ] Run the full `bash scripts/check-module-invariants.sh` and diff every check's result against
      the Phase 1 baseline. C1-C10 must be no worse than baseline. Note in the summary that C5's
      PASS is **not** evidence about ROADMAP.md, since C5 excludes `specs/`.
- [ ] Run the ROADMAP reference check over the **entire** cumulative diff
      (`git diff -- specs/ROADMAP.md`), not just the last phase's hunks. Every `FormalSystem/...`
      path and every dotted `FormalSystem.X.Y` name introduced must resolve. Zero unresolved.
- [ ] Audit for unsourced claims: grep the diff's added lines for sorry counts, axiom claims, and
      dead/live verdicts, and confirm each names its check (C2/C3/C6/C7) or a reproduced command.
- [ ] Audit for bare dead-file references:
      `grep -n "RootScopedChain" specs/ROADMAP.md` — every hit must carry a `Boneyard/` path
      segment or unmistakably past-tense framing.
- [ ] Audit the no-edit list: confirm `git diff -- specs/ROADMAP.md` contains **no** hunk touching
      `## Paper Alignment Programme`, the 111-row status tables, `## Dead Ends (Archived)` (beyond
      the Phase 7 confirmation, which should be a no-op), or the line-271 HISTORICAL block.
- [ ] Confirm the non-goals held: `git status --short` shows no `.lean` file modified, nothing
      moved into or out of `Boneyard/`, and no change to `specs/state.json` task statuses.
- [ ] Write `summaries/01_roadmap-sorry-bxcanonical-correction-summary.md` carrying: the C2/C3
      baseline verbatim, the per-section sweep table from Phase 7 (corrected / banner-only / no
      edit needed, with evidence), the two research-report corrections recorded in this plan's
      Research Integration section, the two planning-time-discovered defects (Examples, Boneyard),
      and the C5-does-not-cover-specs finding.
- [ ] Record the follow-up recommendation: a separate task covering `## Recommended Priority Order`
      and `## Task Cross-Reference` (which cross into `specs/state.json` task-status territory —
      notably whether task 109's recorded status is still correct), plus the C6 manifest finding for
      `Algebraic.LindenbaumQuotient` / `Algebraic.InteriorOperators`. Recommend it in the summary
      and in the return metadata's `next_steps`; **do not create the task from this phase**.
- [ ] Optional, recommended in the summary rather than executed here: a short context note
      recording ROADMAP.md's `self-superseding Current-state block` convention so future
      large-section rewrites follow it from the start. This is a `.claude/` change and belongs in
      `agent-system/extensions/**`, outside this task's charter.

**Timing**: 40 minutes

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:

- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/summaries/01_roadmap-sorry-bxcanonical-correction-summary.md` (new)

**Verification**:

- Full check harness at or above the Phase 1 baseline on every check.
- Zero unresolved references over the cumulative ROADMAP.md diff.
- Zero unsourced sorry-count/axiom/status claims in the added lines.
- Zero `.lean` modifications; zero `Boneyard/` moves; zero task-status changes.
- Summary written and carries the complete sweep record including no-edit findings.

---

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` (full) — every check at or above the Phase 1
      baseline. C3 still reports exactly one structural sorry in `countermodel_discrete`; C2 still
      matches the four-theorem baseline.
- [ ] ROADMAP reference check over the cumulative `specs/ROADMAP.md` diff — zero unresolved
      `FormalSystem/...` paths and zero unresolved dotted `FormalSystem.X.Y` module names.
- [ ] `grep -n "23 sorry\|~17 sorries\|19 sorries\|DEAD CODE" specs/ROADMAP.md` — every surviving
      hit sits inside an explicitly historical, dated block.
- [ ] `grep -n "RootScopedChain" specs/ROADMAP.md` — every hit carries a `Boneyard/` path segment
      or past-tense framing.
- [ ] `git diff --stat` — only `specs/ROADMAP.md` plus this task's own `specs/452_.../` artifacts
      changed. No `.lean` file, no `specs/state.json` status field, no `specs/TODO.md`.
- [ ] `git diff -- specs/ROADMAP.md` contains no hunk inside `## Paper Alignment Programme`, the
      111-row status tables, or the line-271 HISTORICAL block.
- [ ] Every count or status claim added to ROADMAP.md names the check or command that reproduces
      it.

## Artifacts & Outputs

- `specs/ROADMAP.md` — corrected `## Overview` architecture and sorry-summary blocks,
  `## Active Metalogic Paths` intro, the former `### BXCanonical Path (DEAD CODE ...)` subsection,
  `### Module Import Graph`, `### Completeness Theorem` closing paragraph, `## Sorry Inventory`,
  `## Legacy Code Inventory`, three `## Other Open Items` entries; staleness banners on
  `## Recommended Priority Order` and `## Task Cross-Reference`.
- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/summaries/01_roadmap-sorry-bxcanonical-correction-summary.md`
  — implementation summary carrying the deliverable-(c) sweep record, the C2/C3 verbatim baseline,
  and the follow-up recommendation.
- `specs/452_correct_roadmap_sorry_inventory_and_bxcanonical_status/plans/01_roadmap-sorry-bxcanonical-correction.md`
  — this file.

## Rollback/Contingency

All changes are confined to `specs/ROADMAP.md` and this task's own artifact directory; nothing is
compiled, imported, or executed from them, so no rollback can break the build. Each phase commits
separately per the commit-per-green-substep mandate, so a single defective phase can be reverted
with `git revert <sha>` without disturbing the phases around it. If Phase 1 finds that C3 no longer
reports `countermodel_discrete` as the sole sorry, stop: the plan's ground truth has moved, and the
correct action is to re-scope (mark `[BLOCKED]`, record the live output, and re-plan) rather than
to write a second generation of numbers that a future reader will have to correct again.
