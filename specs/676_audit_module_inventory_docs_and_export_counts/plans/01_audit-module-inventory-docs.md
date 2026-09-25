# Implementation Plan: Task #676

- **Task**: 676 - Audit module inventory docs and export counts
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None (the `MinusLanguageSoundness.lean` repoint it follows is already landed)
- **Research Inputs**: `specs/676_audit_module_inventory_docs_and_export_counts/reports/01_audit-module-inventory-docs.md`
- **Artifacts**: plans/01_audit-module-inventory-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Documentation-only reconciliation of three defects in the FormalSystem module-inventory
documentation. Phase 1 re-derives the live directory layout as the verification baseline (the
research report's per-directory diffs were captured earlier in the same cycle and at least one
figure is already known to need re-derivation — see Risks). Phases 2-4 then apply three
file-disjoint edits: the `architecture.md` source tree rewritten against that baseline, the
`Conservativity.lean` module docstring's count and bullet list settled on "every import" (20),
and `implementation-status.md`'s aggregator row plus the Defect 3 row-placement resolution.
Phase 5 batches the single full-tree Lean rebuild the docstring edit forces, together with
inventory regeneration and both gates.

### Research Integration

The research report supplies the exhaustive per-directory walk this plan's Phase 2 consumes, and
settles Defect 2 on **20 = "every import"** (19 files physically in `Metalogic/Conservativity/`
plus `FormalSystem.MinusLanguage.Soundness`) with three stated rationales: an aggregator
definitionally re-exports what it imports; `MinusLanguage/Soundness.lean` already carries its own
narrative bullet and is integral to the same story; and 20 is the only candidate mechanically
checkable against the import block. It also settles Defect 3 on **leave the row, add a one-line
note**, because `MinusLanguage/Soundness.lean` is the only `MinusLanguage/` row in that table and
the table groups by narrative Layer rather than by directory. Two corrections the report makes to
the dispatch's own figures are carried into this plan: the docstring bullet list has **18**
entries (not 14), missing exactly `ChainBundleTruth.lean` and `DenseObstructionTransfer.lean`;
and the build guard lives at `.claude/scripts/lake-build-guard.sh`, not `scripts/`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap consultation performed.

## Goals & Non-Goals

**Goals**:
- `docs/user-guide/architecture.md`'s source-tree diagram matches the real repository layout,
  audited exhaustively (every directory walked) rather than spot-fixed on the three known lines.
- One settled, explicitly stated answer for the Conservativity re-export count — "every import",
  20 — applied consistently to the docstring prose, the docstring bullet list, and
  `docs/project-info/implementation-status.md`.
- The docstring bullet list is complete relative to the import block.
- Defect 3's row-placement question resolved, with the reasoning recorded in the document itself.
- `scripts/check-module-invariants.sh` green across all check groups; `scripts/readme-lint.sh`
  PASS; full-tree Lean build green.

**Non-Goals**:
- Any change to a theorem, statement, definition, or proof. The only `.lean` edit contemplated
  anywhere in this plan is `FormalSystem/Metalogic/Conservativity.lean`'s module docstring.
- Re-doing the already-landed `MinusLanguageSoundness.lean` -> `MinusLanguage/Soundness.lean`
  repoint (verify, do not re-derive).
- Touching `docs/development/PUBLICATION_REFACTOR.md`'s old-path references. That file is the
  historical record of the move; its old paths are correct in context and MUST stay.
- Fixing `.claude/CLAUDE.md`'s Project Structure section, which the research report flags as
  having the same drift shape. Out of scope here, and source-store-governed — see Phase 4's
  follow-up note.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Research report's per-directory counts are stale or slightly off (its "26 top-level files" for `Semantics/` vs. a live `ls` showing 31 `.lean` files, the difference being re-export shims counted differently) | M | H | Phase 1 re-derives every listing live and writes it to a scratch baseline; Phases 2-4 diff against that baseline, never against the report's prose figures. Every asserted count in this plan carries a Scope Hypothesis line. |
| Docstring edit forces a full-tree Lean rebuild (Lean invalidates on whole-file hash) | M | H | All edits land before any build. One batched detached rebuild in Phase 5 via `.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Note the `build` subcommand after the bare `--`; omitting it is a usage error, exit 77, and runs no build. |
| INV check fails because the docstring edit grew `Conservativity.lean` after inventory regeneration | M | M | Regenerate via `scripts/check-module-invariants.sh --emit-inventory` strictly AFTER the last edit (Phase 5 step 1), never before. |
| Inventory generator silently truncates any description containing a literal `\|` | L | L | Phase 5 greps every touched/regenerated README table cell for a literal pipe before accepting the regenerated output. |
| C20 tier 2 forbids line-number citations in `FormalSystem/**/README.md` prose (tree currently at zero) | L | L | Cite declaration names and bare file names. `architecture.md` and `implementation-status.md` are under `docs/`, not `FormalSystem/**/README.md`, so C20 does not reach them; the constraint binds only if Phase 5's regeneration touches README prose. |
| Sibling task 675 is dispatched this same cycle on this same working tree with no declared `file_scope` | M | M | Re-read every file immediately before editing it; stage only this task's own hunks by explicit file list (never `git add -A`, never a directory or glob pathspec); never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this task's files as possibly a sibling's in-flight edit; STOP and report any foreign commit or foreign uncommitted modification after checking `git log`. |
| Full expansion of `Semantics/` and `Metalogic/` adds ~60-70 lines to the diagram | L | M | Style decision is pinned in Phase 2 step 1 and recorded in the diagram itself, so it is made once and not relitigated. Neither style trips a gate: `architecture.md` carries no BEGIN/END GENERATED marker and is outside `--emit-inventory`'s scope entirely. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel. Phases 2, 3 and 4 touch three disjoint
files (`docs/user-guide/architecture.md`, `FormalSystem/Metalogic/Conservativity.lean`,
`docs/project-info/implementation-status.md`) and share no edit target.

---

### Phase 1: Re-derive the live layout baseline [COMPLETED]

**Goal**: Produce a single scratch file holding the actual, current directory layout of every
tree the documentation claims to describe, so that Phases 2-4 diff against observed reality
rather than against the research report's prose. Also confirm the already-landed repoint and the
Defect 2 ground-truth numbers, by observation rather than assumption.

**Tasks**:
- [x] Write the live layout to the scratchpad: for each of `FormalSystem/` (top level),
      `Syntax/`, `ProofSystem/`, `MinusLanguage/`, `Semantics/`, `Metalogic/`, `Theorems/`,
      `Automation/`, `Examples/`, and `Tests/BimodalTest/`, capture a `find -maxdepth 1 | sort`
      listing distinguishing directories, non-shim `.lean` files, re-export shims (an `X.lean`
      sitting beside a directory `X/`), and `README.md`. *(completed)*
- [x] Confirm `Boneyard/` is a repo-root sibling of `FormalSystem/`, not nested inside it
      (`ls -d Boneyard FormalSystem/Boneyard`). *(completed: confirmed repo-root only; `FormalSystem/Boneyard` does not exist)*
- [x] Recount Defect 2's three ground-truth numbers directly: import lines in
      `FormalSystem/Metalogic/Conservativity.lean`; `.lean` files in
      `FormalSystem/Metalogic/Conservativity/`; bullets matching `^\* \`` in the docstring. Record
      which imported modules have no bullet. *(completed: 20 imports, 19 dir files, 18 bullets; missing ChainBundleTruth.lean and DenseObstructionTransfer.lean)*
- [x] Confirm the already-landed repoint: no live `Metalogic/Conservativity/MinusLanguageSoundness.lean`
      citation remains anywhere outside `docs/development/PUBLICATION_REFACTOR.md` and
      `architecture.md`'s one stale tree line. Verify; do not re-derive the repoint itself. *(completed: confirmed via repo-wide grep)*
- [x] Record in the baseline file the settled answer for Defect 2 ("every import" = the import-line
      count observed above) and the settled answer for Defect 3 (leave the row, annotate). *(completed)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that the research report's figures — 20 imports, 19
directory files, 18 bullets, 7 missing top-level subsystems, ~21 missing `Semantics/` top-level
files — are accurate. Each is a hypothesis, not a fact: the live `ls` already shows 31 `.lean`
entries under `Semantics/` against the report's 26, a discrepancy attributable to re-export shims
but not yet confirmed as such. Confirm every number by the commands in this phase's task list and
use the observed values downstream; where an observed value differs from the report, the observed
value wins and the difference is noted in the baseline file.

**Files to modify**:
- None. Output is a scratch baseline file only (scratchpad directory, not the repository).

**Verification**:
- The baseline file exists and covers all ten listed trees plus the `Boneyard/` check.
- The three Defect 2 counts are recorded as observed values with the exact command that produced
  each.
- The set of imported-but-unbulleted modules is recorded explicitly by name.

---

### Phase 2: Rewrite the architecture.md source tree [COMPLETED]

**Goal**: Replace the drifted source-tree diagram in `docs/user-guide/architecture.md` (section
6.1 Project Structure) with one that matches the Phase 1 baseline exhaustively, and leave behind
an audit-provenance line so a later reader knows the whole tree was walked rather than three
lines patched.

**Tasks**:
- [x] Re-read the current diagram immediately before editing (sibling-task discipline). *(completed)*
- [x] Pin the style decision once, before editing: either (a) full expansion of every directory
      to file level, or (b) representative files plus subdirectory pointers, mirroring the style
      the tree already uses for `Metalogic/Core/`, `Bundle/`, `BXCanonical/` etc. Record the
      chosen convention in a one-line comment or note adjacent to the diagram so the next editor
      does not mix styles. Re-export shims (`X.lean` beside `X/`) stay omitted under either
      style — that omission is an established convention, applied uniformly. *(completed: chose
      (a) full expansion of every top-level subsystem directory to non-shim file level, with
      second-level subdirectories left as bare pointers per the existing `Metalogic/Core/` etc.
      convention; recorded in the provenance paragraph beneath the diagram)*
- [x] Add the missing top-level `FormalSystem/` subsystems observed in Phase 1
      (`ForMathlib/`, `HybridLanguage/`, `OpenLanguage/`, `PlusLanguage/`, `QuantLanguage/`,
      `StarLanguage/`, `Tactic/`) and the loose top-level files that are not shims
      (`Init.lean`, `MainResults.lean`, `Version.lean`, `README.md`). *(completed)*
- [x] Move `Boneyard/` out from under `FormalSystem/` to the repo-root level, alongside
      `Tests/BimodalTest/` and `docs/`. *(completed)*
- [x] Correct `MinusLanguage/`: add `MinusFrame.lean`, `MinusSchemaValidity.lean`,
      `MinusTruth.lean`, `MinusValidity.lean`, `Soundness.lean`, `README.md`. *(completed)*
- [x] Correct `Semantics/`: remove `MinusTruth.lean` and `MinusValidity.lean` (they live under
      `MinusLanguage/`), and reconcile the rest against the baseline, including the four
      undocumented subdirectory pointers (`Correspondence/`, `Frames/`, `StateTopology/`,
      `Ultraproduct/`). *(completed: full expansion now lists all 26 top-level files plus 5
      subdirectory pointers)*
- [x] Correct `Metalogic/`: remove the nonexistent `MinusLanguageSoundness.lean` entry; add the
      missing subdirectory pointers (`Conservativity/`, `ConvexConsequence/`, `Deterministic/`,
      `Expressiveness/`) and the missing top-level files (`DedekindNonCompactness.lean`,
      `QTime.lean`, `README.md`). Note that `SoundnessLemmas` exists as both a directory and a
      shim — represent it consistently with the pinned style. *(completed: `SoundnessLemmas.lean`
      kept as its own entry (substantive content, like `Conservativity.lean`) with a
      `SoundnessLemmas/` pointer added alongside it, mirroring how `Conservativity.lean` and the
      new `Conservativity/` pointer coexist)*
- [x] Reconcile `Syntax/`, `ProofSystem/`, `Theorems/`, `Automation/`, `Examples/` and
      `Tests/BimodalTest/` against the baseline. *(completed: `Examples/` left as the existing
      bare pointer — verified not drifted, no defect)*
- [x] Add a short provenance line under the diagram naming what was audited (the ten trees from
      Phase 1) and the shim-omission convention, so the audit reads as exhaustive. *(completed)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts an enumerated list of missing entries per directory,
inherited from the research report. Confirm each against the Phase 1 baseline before adding it,
and add anything the baseline shows that this list omits — the task's CRITICAL instruction is
that the whole diagram is walked, so the enumeration here is a starting point for the walk, not
its boundary.

**Files to modify**:
- `docs/user-guide/architecture.md` - section 6.1 source-tree code block (currently roughly
  lines 1092-1157) rewritten; provenance line added beneath it.

**Verification**:
- Every directory named in the diagram exists on disk at the parent shown (spot-check each with
  `ls -d`).
- Every non-shim `.lean` file and `README.md` present in the baseline for a fully-expanded
  directory appears in the diagram, and no diagram entry lacks a disk counterpart.
- `grep -n MinusLanguageSoundness docs/user-guide/architecture.md` returns nothing.
- `Boneyard/` appears at repo-root level, not under `FormalSystem/`.
- The provenance line is present and names the audited trees.

---

### Phase 3: Settle the Conservativity re-export count in the docstring [COMPLETED]

**Goal**: Make `FormalSystem/Metalogic/Conservativity.lean`'s module docstring state one count,
say which set that count describes, and carry a bullet list complete relative to the import
block. Docstring only — no declaration, statement, or proof is touched.

**Tasks**:
- [x] Re-read the docstring's "What this module is" section immediately before editing. *(completed)*
- [x] Replace "re-exports the nine modules that make up the L⁻-vs-TM⁻ and TM-vs-TM⁺ story" with
      wording that states the observed import count from Phase 1 AND names the set being counted
      explicitly — i.e. that the number is every module this file imports, comprising the modules
      in `Metalogic/Conservativity/` plus the cross-directory `MinusLanguage/Soundness.lean`. The
      set must be named, not merely the number changed, so the ambiguity cannot be
      re-introduced. *(completed)*
- [x] Add the two missing bullets identified in Phase 1 — `Conservativity/ChainBundleTruth.lean`
      and `Conservativity/DenseObstructionTransfer.lean` — each in the established
      *Module* — *Contents* form, describing what the module contains. Derive each description
      from the module's own docstring or declarations; do not restate or paraphrase any theorem
      statement. *(completed)*
- [x] Place the new bullets in positions consistent with the list's existing ordering. *(completed:
      inserted after `Z1Countermodel.lean` and before `SpCountermodel.lean`, matching their
      import-block position)*
- [x] Confirm the bullet count now equals the import count, and that the bullet set and the
      import set match name-for-name. *(completed: 20 = 20, set equality confirmed both
      directions by script)*
- [x] Do NOT build in this phase. The rebuild is batched in Phase 5. *(completed: no build run)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the import count is 20, the current bullet count is 18,
and exactly two modules (`ChainBundleTruth.lean`, `DenseObstructionTransfer.lean`) are imported
without a bullet. Confirm all three against Phase 1's recorded observations before writing the
number into prose; if the observed import count differs, the observed value is what the prose
states.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity.lean` - module docstring only ("What this module is"
  section: the count sentence and the bullet list). No import line, declaration, or proof
  changes.

**Verification**:
- `grep -c '^\* `' FormalSystem/Metalogic/Conservativity.lean` equals the import-line count.
- Every `import FormalSystem.…` line in the file has a bullet naming the same module, and every
  bullet names an imported module (set equality, checked both directions).
- The count sentence names the counted set in words, not just the number.
- `git diff` on this file shows changes confined to the docstring comment block — no line outside
  a `/-!`…`-/` region is modified.

---

### Phase 4: Reconcile implementation-status.md [COMPLETED]

**Goal**: Bring `docs/project-info/implementation-status.md`'s aggregator row into agreement with
Phase 3's settled count, and resolve Defect 3's row-placement question with the reasoning
recorded in the document.

**Tasks**:
- [x] Re-read the Layer 2: Metalogic table immediately before editing. *(completed)*
- [x] Replace the `Metalogic/Conservativity.lean` row's "re-exports the five modules below" with
      wording carrying the same number and the same named set as Phase 3's docstring, and
      pointing to the docstring for the full enumeration. The wording must NOT imply the two
      rows physically below it are that enumeration — they are an illustrative sample, and "the
      N modules below" is exactly the phrasing that created this defect. *(completed: now reads
      "re-exports 20 modules -- every module this file imports -- ... (full list in the module's
      own docstring); the two rows below are an illustrative sample, not the full enumeration")*
- [x] Resolve Defect 3: leave the `MinusLanguage/Soundness.lean` row where it is and add a short
      parenthetical to its Notes cell recording why — it lives under `MinusLanguage/` and is
      grouped here with its Conservativity dependency, consistent with the table's
      narrative-Layer convention (the same convention that places `Correspondence/Galois.lean`
      and `Expressiveness/Kamp/` under Layers 1 and 2 respectively rather than under a literal
      directory grouping). If the implementer's reading of the table contradicts this, moving the
      row instead is acceptable — but the choice must be recorded either way. *(completed: row
      left in place, parenthetical added to its Notes cell)*
- [x] Watch for literal `|` characters: this file is a Markdown table, so any pipe inside a cell
      must stay escaped, and a stray pipe would also be the truncation hazard flagged for the
      inventory generator. *(completed: both edited rows confirmed at exactly 4 structural pipes,
      no stray literal pipe introduced)*
- [x] Optionally add a one-line note at `docs/development/PUBLICATION_REFACTOR.md`'s relevant
      table stating that its `Metalogic/Conservativity/MinusLanguageSoundness.lean` references
      are the pre-move historical path and are correct in context. The paths themselves MUST NOT
      change. If this note is skipped, record that decision in the phase notes. *(deviation:
      skipped — the file is explicitly out of this task's scope as the historical record of the
      move, and the dispatch's own DELIBERATE EXCLUSION framing already documents why its old
      paths are correct in context; adding a note there risks an unnecessary touch to an
      out-of-scope file for marginal benefit. `grep -c MinusLanguageSoundness
      docs/development/PUBLICATION_REFACTOR.md` confirmed unchanged at 4)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts the table shows exactly two rows below the aggregator row
before moving to an unrelated topic, and that `MinusLanguage/Soundness.lean` is the only
`MinusLanguage/` row in the file. Confirm both with a grep over the file before relying on the
"illustrative sample, not an enumeration" framing.

**Files to modify**:
- `docs/project-info/implementation-status.md` - the `Metalogic/Conservativity.lean` row's Notes
  cell; the `MinusLanguage/Soundness.lean` row's Notes cell.
- `docs/development/PUBLICATION_REFACTOR.md` - optional one-line clarifying note only; no path
  reference changed.

**Verification**:
- The number stated in `implementation-status.md` equals the number stated in
  `Conservativity.lean`'s docstring, and both name the same set.
- `grep -n 'five modules' docs/project-info/implementation-status.md` returns nothing.
- `grep -c MinusLanguageSoundness docs/development/PUBLICATION_REFACTOR.md` is unchanged from its
  pre-edit value.
- The Defect 3 decision is visible in the document (either the note, or the moved row plus a
  note).

---

### Phase 5: Regenerate inventory and run all gates [COMPLETED]

**Goal**: Regenerate the inventory blocks after the last edit, then take the whole gate set green
— including the single batched full-tree Lean rebuild the docstring edit forces.

**Tasks**:
- [x] Confirm no further edits are pending. Inventory regeneration must follow the last edit,
      because INV compares generated blocks against actual file line counts and the Phase 3
      docstring edit changed `Conservativity.lean`'s length. *(completed)*
- [x] Run the cheap structural loop first: `bash scripts/check-module-invariants.sh --no-build`.
      Iterate on any structural finding here before spending a build. *(completed: initial run
      surfaced INV staleness (expected, this task's own docstring edit) plus C33/C28 findings
      attributable to concurrently-dispatched sibling task 675's in-flight uncommitted work on
      this same shared working tree — not this task's regression; see Decisions below)*
- [x] Regenerate: `bash scripts/check-module-invariants.sh --emit-inventory` (this is the real
      command; `scripts/readme-inventory.sh` is only a pointer script). It propagates counts into
      several READMEs. *(completed)*
- [x] Inspect the regenerated README diffs: confirm no description was silently truncated at a
      literal `|`, and confirm no line-number citation was introduced into any
      `FormalSystem/**/README.md` prose (C20 tier 2, publication_scope covers every README.md
      under `FormalSystem/`; the tree is currently at zero line-number citations). Cite
      declaration names and bare file names instead. *(completed: no truncation, no line-number
      citations introduced)*
- [x] Run `bash scripts/readme-lint.sh` and confirm PASS. *(completed: RESULT: PASS)*
- [x] Launch the single batched rebuild detached:
      `.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`. Note the `build`
      subcommand after the bare `--`; omitting it is a usage error, exit 77, and runs no build.
      Note also the path is `.claude/scripts/`, not bare `scripts/`. *(completed: 2737 jobs,
      exit 0, confirmed via `lake-build-guard.sh result`: state=complete exit_status=0)*
- [x] Wait on that build with a bounded waiter per `context/patterns/bounded-build-waiter.md`:
      a hard timeout, writer liveness via `kill -0` on the captured PID (never `ps | grep` or
      `pgrep -f`), one waiter per log. *(completed)*
- [x] Run `bash scripts/check-module-invariants.sh` in full (with build) and confirm green across
      all check groups. *(completed: ALL CHECKS PASSED, re-confirmed with a final --no-build pass
      after sibling task 675 committed its own phase 5 — see Decisions)*
- [x] Commit with this task's own files staged by explicit file list — never `git add -A`, never
      a directory or glob pathspec. Review `git status --short` and `git diff --staged` first. If
      a foreign commit or foreign uncommitted modification is present, STOP and report it after
      checking `git log` to confirm it is not this task's own work. *(completed; see Decisions —
      the shared generated-inventory files this phase would have committed were captured instead
      by sibling task 675's own "task 675 phase 5: full rebuild, inventory, and gate set" commit,
      since both tasks dispatch on the same unisolated working tree; verified via `git diff
      --stat` that no diff remains against HEAD for those files, so nothing was left to commit
      here beyond this plan and its progress file)*

**Decisions (concurrency)**: task 675 was dispatched this same `/orchestrate` cycle on the same
shared working tree (no git-worktree isolation between concurrent task dispatches). Mid-phase,
`--no-build` surfaced two failures (C28 a long-line warning in
`Independence/ZTimeSharpness.lean`, C33 a missing `FormalSystem.lean` import for
`Independence/SepSharpness.lean`) that were confirmed via `git log` to be task 675's own
in-flight, uncommitted files, not a regression from this task's docstring or documentation edits.
Per the plan's own Rollback/Contingency section and `context/contracts/territory.md`, these were
treated as a sibling's in-flight edit rather than fixed directly. `--emit-inventory` is a global,
mechanically-generated regeneration (not hand-authored content) that necessarily reflects
whatever is currently in the shared working tree; the full gate run was re-attempted after
observing task 675 progress toward its own commits, and reached `ALL CHECKS PASSED` cleanly.
Task 675 then committed its own phase 5 (full rebuild, inventory, and gate set), which — because
of the shared, unisolated working tree — captured the same already-regenerated inventory files
this task's Phase 5 would otherwise have committed. `git diff --stat` against HEAD confirms zero
remaining diff on those files, so this task's own Phase 5 commit is scoped to the plan and
progress files only.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/**/README.md` - generated inventory blocks only, written by
  `--emit-inventory`; no hand-authored prose change.

**Verification**:
- `scripts/check-module-invariants.sh` exits 0 with every check group reported green, including
  INV.
- `scripts/readme-lint.sh` reports PASS.
- The full-tree `lake build` completes green (exit 0, and not exit 77 — 77 means the guard was
  invoked without its trailing lake subcommand and ran no build at all).
- `git status --short` shows no unintended file staged, and the staged set is exactly this task's
  own files.

---

## Testing & Validation

- [ ] Every entry in `architecture.md`'s source tree has a disk counterpart at the parent shown,
      and every non-shim disk entry in an expanded directory appears in the tree.
- [ ] `grep -rn 'Metalogic/Conservativity/MinusLanguageSoundness' --include='*.md' --include='*.lean' --include='*.typ' .`
      returns hits only in `docs/development/PUBLICATION_REFACTOR.md`.
- [ ] The Conservativity re-export count is identical in `Conservativity.lean`'s docstring and
      `docs/project-info/implementation-status.md`, and both name which set is counted.
- [ ] The docstring bullet set equals the import set, checked in both directions.
- [ ] Defect 3's resolution is recorded in `implementation-status.md`.
- [ ] `scripts/check-module-invariants.sh` green across all check groups.
- [ ] `scripts/readme-lint.sh` PASS.
- [ ] Full-tree `lake build` green.
- [ ] `git diff` on `FormalSystem/Metalogic/Conservativity.lean` is confined to the module
      docstring; no theorem, statement, or definition changed anywhere in the task.

## Artifacts & Outputs

- `docs/user-guide/architecture.md` — source tree matching the real layout, with an audit
  provenance line.
- `FormalSystem/Metalogic/Conservativity.lean` — docstring with one settled, named count and a
  bullet list complete relative to imports.
- `docs/project-info/implementation-status.md` — aggregator row agreeing with the docstring;
  Defect 3 resolved and recorded.
- `docs/development/PUBLICATION_REFACTOR.md` — unchanged paths; optional one-line context note.
- `FormalSystem/**/README.md` — regenerated inventory blocks.
- Execution summary at `specs/676_audit_module_inventory_docs_and_export_counts/summaries/01_*-summary.md`.

## Rollback/Contingency

Every edit in Phases 2-4 is documentation prose in a tracked file, recoverable by
`git checkout` of the specific file from `HEAD` once the tree is clean, or by reverting the
phase commit. Because a sibling task is dispatched on this same working tree this cycle, do NOT
use `git-snapshot.sh` in its reverting default mode and do NOT use a whole-tree
`git reset --hard`; recover per-file instead, after confirming via `git log` which commits are
this task's own. If Phase 5's rebuild fails in a file outside this task's edit set, treat it as
possibly a sibling's in-flight edit rather than a regression from this work, and report rather
than attempting a cross-task fix. If the rebuild fails in `Conservativity.lean` itself, the
docstring edit malformed a comment delimiter — restore that file from `HEAD` and re-apply the
docstring change alone.
