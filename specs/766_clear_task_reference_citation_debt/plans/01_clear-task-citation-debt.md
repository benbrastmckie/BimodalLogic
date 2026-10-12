# Implementation Plan: Task #766

- **Task**: 766 - Clear the repo-wide task-number citation debt that fails check-task-references.sh
- **Status**: [IMPLEMENTING]
- **Effort**: 5.25 hours
- **Dependencies**: None
- **Research Inputs**: None (planned directly from the task description; the full lint inventory
  was re-derived at plan-authoring time -- see Scope Hypothesis lines)
- **Artifacts**: plans/01_clear-task-citation-debt.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

`bash .claude/scripts/check-task-references.sh` exits 1 on 198 unexempted task-number citations
that predate every recent dispatch, making the unscoped gate useless as a regression signal. The
debt is concentrated and highly templated: 87 occurrences in `Boneyard/` (archival tombstone
READMEs plus retired `.lean` module comments), 110 in `Tests/` (overwhelmingly one repeated
quarantine-note comment template), and 1 in `scripts/check-module-invariants.sh`. Every
occurrence is resolved by the preferred sanctioned route -- excise the ephemeral citation, keep
or name a durable anchor -- with the `task-ref-ok` marker held in reserve for occurrences the
taxonomy in `.claude/context/standards/task-reference-exemptions.md` actually licenses. Work is
partitioned by file territory into four editing phases plus a final full-sweep phase.

### Research Integration

No research report exists for this round, and none was requested. The Stage 1.5 opening
assessment found the task description already carries the defect, the measured evidence, the
sanctioned routes, and the acceptance bar; the remaining unknowns (exact per-file distribution,
rewrite templates, build surface of the touched trees) were all resolvable by direct `Read`,
`Grep`, and a single lint invocation inside this dispatch, and were resolved. Findings that
shaped the phase decomposition:

- **Total re-derived**: `bash .claude/scripts/check-task-references.sh` -> exit 1,
  `198 occurrence(s)`, matching the description's figure.
- **Distribution** (by path field of the lint's own finding lines): `Boneyard/**/README.md`
  66 occurrences across 24 files; `Boneyard/**/*.lean` 21 across 9 files; `Tests/**` 110 across
  19 files; `scripts/check-module-invariants.sh` 1.
- **Templated majority**: 74 of the 198 are the single token `Task 365`, almost all inside two
  literal comment templates (`-- (Task 365) quarantined: ...` and
  `-- NOTE (Task 365): quarantined - ...`). These are bulk-rewritable.
- **No domain false positives**: every distinct matched token (enumerated via the shared
  library's `TASK_PATTERN` over the lint output) is a tracker citation. Despite this project's
  domain vocabulary ("task frame", "TaskRel", "TaskModel"), no finding is a semantic reference
  that would lose meaning when the number is excised.
- **Build surface**: `lakefile.toml` declares `FormalSystem`, `BimodalTest` (srcDir `Tests`),
  `BimodalTools`, and `BimodalToolsTest`. `Boneyard/` appears nowhere in `lakefile.toml` and is
  not a library root -- its `.lean` files are git-tracked but never compiled, so Boneyard edits
  carry no build surface. `Tests/BimodalTest/**` and `Tests/BimodalToolsTest/**` do compile.
- **No source-store/deploy-boundary collision**: zero findings under `.claude/**`.
  `scripts/check-module-invariants.sh` exists only at repo root (no `.claude/scripts/` twin), so
  it is repo-owned and editable in place.
- **This repo is a deploy consumer** (no `agent-system/` directory). `verify-deploy.sh`'s gate 4
  -- the task-reference lint gate -- therefore `[SKIP]`s here by its own
  `[ ! -d "$TARGET/agent-system/extensions" ]` guard. The authoritative acceptance check is the
  direct `check-task-references.sh` run named in the task description, not gate 4.
- **Write-time hook mechanics**: `.claude/hooks/validate-no-task-references.sh` scans only
  `tool_input.content` / `tool_input.new_string`, not the resulting whole file. An `Edit` whose
  replacement text is citation-free therefore passes even while the rest of the file still
  carries other citations, so incremental per-occurrence fixing is viable. A full-file `Write`
  of a partially-cleaned file would be blocked; `Bash`-driven `sed` is not matched by the hook
  at all.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; ROADMAP.md was not consulted and must not be
modified by this task.

## Goals & Non-Goals

**Goals**:
- `bash .claude/scripts/check-task-references.sh` exits 0 with `PASS: 0 unexempted
  task-reference occurrences`.
- Every occurrence resolved by one of the two sanctioned routes, with durable anchors strongly
  preferred over markers.
- `lake build`, `lake build BimodalTest`, and `lake build BimodalToolsTest` stay green: no edit
  crosses out of a comment, docstring, or prose region.
- Every surviving sentence still says what it said before, minus the ephemeral identifier.

**Non-Goals**:
- Do not modify `check-task-references.sh`, `scripts/lib/task-reference-patterns.sh`,
  `hooks/validate-no-task-references.sh`, or `context/standards/task-reference-exemptions.md`.
  Making the gate pass by weakening the gate, broadening a pattern, adding a path exemption, or
  inventing a new exemption category is out of scope and prohibited.
- Do not add an "archival provenance" or "tombstone" exemption category. The taxonomy's seven
  categories are closed for this task; `Boneyard/` tombstone READMEs are deliverables.
- No restructuring, re-proving, un-quarantining, or re-enabling of any test or Boneyard module.
  No behavioral change of any kind.
- No ROADMAP.md edits.
- Do not clear task-number citations under `specs/**` -- that tree is the taxonomy's category 1
  path-level exemption and is correctly out of the lint's scope.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A rewrite drops load-bearing meaning along with the citation (e.g. a reference list entry whose only content was the task number) | M | M | Minimal-excision principle: delete the identifier, keep the surrounding words verbatim. Where an entry's whole content was the identifier, fold its description into the nearest durable anchor (a date, a filename, a named refactor) rather than deleting the line silently. Re-read each changed hunk in `git diff` before committing. |
| A `sed` on the bulk comment templates crosses a Lean comment boundary or mangles a `/-- -/` / `/-! -/` delimiter, breaking elaboration | H | L | Anchor every `sed` pattern on the full literal template including its leading `-- ` comment marker; never match a bare `(Task NNN)` fragment. Confirm with `lake build BimodalTest` (Phases 3-4) and a `git diff` read-through (all phases). |
| The write-time hook blocks an `Edit` because the replacement hunk still contains a *neighbouring* citation | L | M | Keep each `Edit`'s `new_string` citation-free (fix one occurrence per edit), or use `Bash`/`sed`, which the hook's `Write\|Edit` matcher does not see. Never work around a block by adding a marker that the taxonomy does not license. |
| Rewriting introduces record-versioning language ("no longer", "previously", "formerly", "superseded") that `rules/no-record-versioning-in-deliverables.md` forbids outside `specs/**` | M | M | Minimal excision again: do not re-narrate, do not add temporal framing that is not already in the sentence. Removing a parenthetical is the whole edit. |
| The marker route is used as an escape hatch for occurrences the taxonomy does not cover, so the gate passes while the debt persists | H | L | Every `task-ref-ok` marker added by this task MUST carry a trailing reason naming a numbered category from `task-reference-exemptions.md`. The final phase audits the full marker delta (`git diff` grepped for `task-ref-ok`) and rejects any marker whose named category does not actually fit. Prediction: at most one marker is needed repo-wide (see Phase 5). |
| Lake lock contention or redundant rebuilds if the two Tests phases run concurrently | L | M | Phase 4 depends on Phase 3: both edit modules inside the `BimodalTest` library and discharge their tier with the same `lake build BimodalTest`, so they are serialized rather than waved in parallel despite disjoint file lists. |
| 24 Boneyard READMEs plus 19 Tests files is a large touched set; an interrupted phase leaves a half-cleaned tree | M | L | One commit per green sub-step (default `per-substep` commit mode) gives per-file revert points. A defensive `bash .claude/scripts/git-snapshot.sh 766 --no-revert` checkpoint before Phase 1 gives a durable pre-task anchor without reverting the tree. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1 (for 2), 3 (for 4) |
| 3 | 5 | 2, 4 |

Phases within the same wave can execute in parallel. Phases 1 and 3 touch strictly disjoint
file territory (`Boneyard/**/README.md` vs `Tests/BimodalTest/{Syntax,Semantics,ProofSystem,Property}/**`)
and have disjoint verification surfaces (no build vs. `lake build BimodalTest`).

### Rewrite Vocabulary (applies to every editing phase)

Implementers MUST use this shared vocabulary rather than inventing a per-occurrence rewrite. The
left side is the observed shape; the right side is the durable-anchor replacement.

| Observed shape | Replacement |
|----------------|-------------|
| `-- (Task 365) quarantined: X` | `-- Quarantined: X` |
| `-- NOTE (Task 365): quarantined - X` | `-- NOTE: quarantined - X` |
| `## Heading (Task N)` / `### Heading (Task N Phase P)` | `## Heading` / `### Heading` (drop the parenthetical entirely) |
| `### Filename.lean (task N)` | `### Filename.lean` (the filename already IS the durable anchor) |
| `Archived: Task N (YYYY-MM-DD)` | `Archived: YYYY-MM-DD` |
| `**Archived**: YYYY-MM-DD (task N)` | `**Archived**: YYYY-MM-DD` |
| `**Archived**: Task N (completeness cleanup)` | `**Archived**: completeness cleanup` (no date available; keep the named reason) |
| `## Task Cross-References` / `## References` sections listing `- Task N: description` | Retitle to `## Change History`; keep each `- description` without its identifier. An entry whose only content was the identifier (`- Task 130: This archival`) folds into the header's `Archived:` date instead of becoming a contentless bullet. |
| `See task N for the refactoring history.` | Name the anchor the reader can actually open, e.g. ``See `ProofSystem/Axioms.lean`'s open-guard axioms and the "Why Archived" section above.`` |
| `removed in Task 44` / `removed ... under task 113` | `removed` / `removed by the open-guard refactor that retired BX1/BX1'` -- name the change, not the tracker row |
| `last verified before task 131 (module reorg)` | `last verified before the module reorganization` |
| `(task 155, plan v52)` / `(tasks 154-155)` | drop the parenthetical; keep the surrounding claim verbatim |
| `## Phase 2 Task #58` | `## Phase 2` (or the descriptive heading the body already supplies) |
| `"task 42"` quoted as an illustrative forbidden form | `"task {N}"` -- the placeholder form, taxonomy category 5, which `TASK_PATTERN` structurally cannot match, so no marker is needed |

**Marker discipline**: a `task-ref-ok` marker is admissible only where one of the seven numbered
categories in `.claude/context/standards/task-reference-exemptions.md` genuinely applies, and
every marker added by this task MUST carry a trailing reason naming its category. If an
occurrence seems to need a marker but no category fits, the correct move is a durable-anchor
rewrite, not a bare marker.

---

### Phase 1: Clear Boneyard archival READMEs [COMPLETED]

**Goal**: Zero unexempted citations in `Boneyard/**/README.md`, with each tombstone's archival
provenance restated against durable anchors (dates, filenames, named refactors).

**Tasks**:
- [x] Take a defensive checkpoint: `bash .claude/scripts/git-snapshot.sh 766 --no-revert`. *(completed)*
- [x] Re-derive the scope: `bash .claude/scripts/check-task-references.sh Boneyard` and filter
      its finding lines to `README.md` paths. Record the observed count and file list; reconcile
      against the hypothesis below before editing. *(completed: confirmed 66 occurrences across 24 files, matching hypothesis exactly)*
- [x] For each README, apply the Rewrite Vocabulary above. The recurring shapes are the
      `Archived:` header line, the `## Task Cross-References` / `## References` trailing section,
      and inline `under task N` / `by task N` attributions in the "Why Archived" prose. *(completed: all 24 files)*
- [x] For the three `Boneyard/Kamp/KampWeakCanonical/**/README.md` files carrying the identical
      `last verified before task 131 (module reorg)` note, apply one consistent rewrite. *(completed: rewritten to "last verified before the module reorganization")*
- [x] Read `git diff` for every changed file; confirm each hunk is a citation excision and
      introduces no record-versioning language. *(completed)*
- [x] Commit per green sub-step. *(completed: two commits, 9 files then 15 files)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 66 occurrences across 24 files under `Boneyard/**/README.md`. This figure
was re-derived at plan-authoring time by running `bash .claude/scripts/check-task-references.sh`
and counting the path field of its finding lines (not carried unverified from the task
description, whose 198 total this agrees with). Confirm at implementation time by re-running the
scoped lint before editing; if the count or file list differs, reconcile and report the delta
rather than silently proceeding.

**Tier Justification**: Every edit is confined to markdown prose in files with no compile,
elaboration, or executable surface at all (`Boneyard/` is absent from `lakefile.toml`), so the
`prose` row's diff read-through plus `bash .claude/scripts/check-task-references.sh Boneyard` is
the cheapest check that covers the full blast radius.

**Files to modify**:
- `Boneyard/BX1DependentCode/README.md` - archival header, "Why Archived" prose, cross-reference section
- `Boneyard/BXPipelineDeadCode/README.md` - per-file `### Filename.lean (task N)` headings and body attributions
- `Boneyard/BXPipelineGapAnalysis/README.md` - archival attribution and a `no_gaps_discrete` provenance note
- `Boneyard/ChainCompleteness/README.md` - archival header
- `Boneyard/ClosedGuardLegacy/README.md` - archival header, "Relationship to Active Code" anchor, references section
- `Boneyard/DeadCanonicalModel/README.md` - archival header and references section
- `Boneyard/DefectDirectedChain/README.md` - archival header and references section
- `Boneyard/DenseChronicle/README.md` - archival header and references section
- `Boneyard/DiscreteXY/README.md` - archival header and references section
- `Boneyard/FiltrationOrdering/README.md` - archival header and references section
- `Boneyard/Kamp/KampWeakCanonical/ExpressiveCompleteness/README.md` - stale-verification note
- `Boneyard/Kamp/KampWeakCanonical/Separation/DedekindZ/README.md` - stale-verification note
- `Boneyard/Kamp/KampWeakCanonical/Separation/Hierarchy/README.md` - stale-verification note
- `Boneyard/Kamp/VecEADecomposition/README.md` - archival header and sorry-provenance prose
- `Boneyard/MergedBracketQuarantine/README.md` - quarantine/retirement narrative and import-edge note
- `Boneyard/NonBurgessSeed/README.md` - archival attributions
- `Boneyard/OpenGuardInvalid/README.md` - archival attributions
- `Boneyard/RoundRobinChain/README.md` - archival attributions
- `Boneyard/ScheduleBasedBFMCS/README.md` - archival attributions
- `Boneyard/StageInductionGapAnalysis/README.md` - archival attribution naming the source module
- `Boneyard/XuLemma321Legacy/README.md` - archival attributions
- `Boneyard/TAxiomDependentCode/README.md` - archival attributions
- `Boneyard/UltrafilterDeadCode/README.md` - cleanup attribution naming `UltrafilterChain.lean`
- `Boneyard/UltrafilterFrame/README.md` - archival attributions

**Verification**:
- `bash .claude/scripts/check-task-references.sh Boneyard` reports no finding whose path ends in
  `README.md` (remaining `.lean` findings are Phase 2's).
- `git diff --stat` touches only `Boneyard/**/README.md`.
- Diff read-through confirms every hunk is inside markdown prose and introduces no
  record-versioning language and no unlicensed `task-ref-ok` marker.

---

### Phase 2: Clear Boneyard retired-module comments [COMPLETED]

**Goal**: Zero unexempted citations anywhere under `Boneyard/`, closing the subtree.

**Tasks**:
- [x] Re-derive the scope: `bash .claude/scripts/check-task-references.sh Boneyard`; the
      remaining findings should all be `.lean` paths. Record and reconcile the count. *(completed: confirmed 21 occurrences across 9 files, matching hypothesis exactly)*
- [x] Apply the Rewrite Vocabulary to each `.lean` comment, docstring, and `/-! -/` section
      heading. The dominant shapes here are `Task #N` section headings
      (`## Known Limitations (Task #55)`, `## Gap Analysis (Task #58)`) and inline
      issue-attribution prose (`the issue identified in Task #69`). *(completed: all 9 files)*
- [x] Where an attribution carries real content (`the Task #69 F-persistence counterexample`),
      keep the content and name the durable anchor already present in the same passage
      (`f_preserving_seed_consistent` in `UltrafilterChain.lean`); where it carries none, drop it. *(completed)*
- [x] Read `git diff` for every changed file; confirm each hunk stays inside a `--`, `/- -/`,
      `/-- -/`, or `/-! -/` region and that no comment delimiter was altered. *(completed)*
- [x] Commit per green sub-step. *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 21 occurrences across 9 files under `Boneyard/**/*.lean`
(`StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` 6,
`StrictSemanticsLegacy/FrameConditions/Completeness.lean` 4,
`StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` 3,
`StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` 2,
`StrictSemanticsLegacy/Algebraic/RestrictedTruthLemma.lean` 2, plus one each in
`Kamp/KampWeakCanonical/NfMultiAnchorBridgeRetired/Lemma32Reduction.lean`,
`Kamp/KampWeakCanonical/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`,
`DeadConvergenceProof/succ_cofinal_convergence.lean`, and
`DeadChronicleGapElimination/ChronicleGapChainExcision.lean`). Re-derived at plan-authoring time
from the same lint run as Phase 1. Confirm by re-running the scoped lint before editing.

**Tier Justification**: `Boneyard/` is declared in no `[[lean_lib]]` root and is not in
`defaultTargets`, so these files are never elaborated by any build -- there is literally no
compile surface for a cheaper-than-`prose` tier to miss, and the `prose` row's diff read-through
plus `bash .claude/scripts/check-task-references.sh Boneyard` covers the whole edit.

**Files to modify**:
- `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` - six `Task #N` section headings and gap-attribution prose
- `Boneyard/StrictSemanticsLegacy/FrameConditions/Completeness.lean` - four `Task #N` status/section headings
- `Boneyard/StrictSemanticsLegacy/Algebraic/DovetailedChain.lean` - three F-persistence issue attributions
- `Boneyard/StrictSemanticsLegacy/Bundle/CanonicalConstruction.lean` - two `Task #58` section headings
- `Boneyard/StrictSemanticsLegacy/Algebraic/RestrictedTruthLemma.lean` - `Phase 2 Task #58` heading and body sentence
- `Boneyard/Kamp/KampWeakCanonical/NfMultiAnchorBridgeRetired/Lemma32Reduction.lean` - module-docstring attribution
- `Boneyard/Kamp/KampWeakCanonical/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean` - declaration docstring parenthetical
- `Boneyard/DeadConvergenceProof/succ_cofinal_convergence.lean` - inline pipeline attribution
- `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean` - sorry-free provenance parenthetical

**Verification**:
- `bash .claude/scripts/check-task-references.sh Boneyard` exits 0 with
  `0 occurrence(s)` -- the whole subtree is closed by this phase.
- `git diff --stat` touches only `Boneyard/**/*.lean`.
- Diff read-through confirms no comment delimiter was altered and no unlicensed marker was added.

---

### Phase 3: Clear Tests/BimodalTest property-suite comments [IN PROGRESS]

**Goal**: Zero unexempted citations under `Tests/BimodalTest/{Syntax,Semantics,ProofSystem,Property}`,
with `lake build BimodalTest` still green.

**Tasks**:
- [ ] Re-derive the scope with one scoped lint run per subtree:
      `for d in Syntax Semantics ProofSystem Property; do bash .claude/scripts/check-task-references.sh Tests/BimodalTest/$d; done`.
      Record and reconcile the counts.
- [ ] Bulk-rewrite the two dominant comment templates with anchored `sed` patterns that include
      the leading `-- ` comment marker:
      `-- (Task 365) quarantined:` -> `-- Quarantined:` and
      `-- NOTE (Task 365): quarantined` -> `-- NOTE: quarantined`.
      Use `Bash`/`sed` rather than a whole-file `Write` (the write-time hook scans `content` and
      would block a full-file rewrite of a still-partially-cited file).
- [ ] Hand-fix the residual non-template occurrences: `## API Grift/Drift Notes (Task 365)` and
      `## TaskModel Generators (QUARANTINED - Task 365)` headings in `Property/Generators.lean`,
      the `Task 116` / `Task 276` definition-provenance comments in `Syntax/FormulaTest.lean`,
      and the `compositionality` replacement note in `Semantics/SemanticPropertyTest.lean`.
- [ ] Read `git diff` for every changed file; confirm every hunk is inside a comment or
      docstring region and that no `/-! -/` or `/-- -/` delimiter moved.
- [ ] Run `lake build BimodalTest` and confirm green.
- [ ] Commit per green sub-step.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 65 occurrences across 6 files --
`Syntax/FormulaPropertyTest.lean` 38, `Syntax/FormulaTest.lean` 5,
`Semantics/SemanticPropertyTest.lean` 10, `ProofSystem/DerivationPropertyTest.lean` 7,
`ProofSystem/AxiomsTest.lean` 2, `Property/Generators.lean` 3. Re-derived at plan-authoring time
from the same lint run as Phase 1. Confirm by re-running the four scoped lints before editing;
report any delta rather than proceeding silently.

**Tier Justification**: Each edit is confined to a comment or docstring inside a single
`BimodalTest` module with no change to any exported signature, and `lake build BimodalTest` is
the `local` row's "build of that module" discharged for all six at once -- it is the cheapest
check that would catch the one real hazard here, a `sed` crossing a Lean doc-comment delimiter.

**Files to modify**:
- `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` - 38 quarantine-note comment headers (two templates)
- `Tests/BimodalTest/Syntax/FormulaTest.lean` - definition-provenance comments and one section heading
- `Tests/BimodalTest/Semantics/SemanticPropertyTest.lean` - quarantine notes plus one API-replacement note
- `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` - quarantine notes
- `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` - derived-theorem note and one quarantine note
- `Tests/BimodalTest/Property/Generators.lean` - two section headings and one body note

**Verification**:
- Each of `bash .claude/scripts/check-task-references.sh Tests/BimodalTest/Syntax`,
  `.../Semantics`, `.../ProofSystem`, `.../Property` exits 0.
- `lake build BimodalTest` exits 0 with no new error or warning.
- `git diff --stat` touches only the six files above.
- Diff read-through confirms comment-region containment and no unlicensed marker.

---

### Phase 4: Clear Tests automation, integration, and tools-test comments [NOT STARTED]

**Goal**: Zero unexempted citations anywhere under `Tests/`, with `lake build BimodalTest` and
`lake build BimodalToolsTest` both green.

**Tasks**:
- [ ] Re-derive the scope: `bash .claude/scripts/check-task-references.sh Tests` -- the
      remaining findings should all be under `Automation/`, `Theorems/`, `Integration/`, or
      `Tests/BimodalToolsTest/`. Record and reconcile.
- [ ] Apply the same two anchored `sed` templates for the residual `Task 365` quarantine notes
      (concentrated in `Integration/AutomationProofSystemTest.lean`).
- [ ] Hand-fix the varied prose, which is denser here than in Phase 3: module-docstring test
      inventories in `Automation/TacticsTest.lean` (`- Task 315 modal_search tests`,
      `**Phase 10 Tests (111-134)**: Task 315 tactic tests`), `(Task 319 Phase N)` section
      headings in `Automation/{EdgeCaseTest,ProofSearchBenchmark,ProofSearchTest,TacticsTest}.lean`,
      `blocked by task 315` references in `Automation/ProofSearchTest.lean` (replace with the
      named blocker -- proof-term construction -- rather than the tracker row), the
      `Task N` acceptance-criterion comments in `Automation/WeakeningSearchTest.lean`, the
      `(Task NN)` section headings in `Theorems/ModalS5Test.lean`, and the single
      `before the task 261 fixes` note in `Tests/BimodalToolsTest/C5SmokeTest.lean`.
- [ ] Preserve the `**Phase 10 Tests (111-134)**` style test-index ranges: those are test
      numbers, not task numbers, and are not what `TASK_PATTERN` matches -- only the adjacent
      `Task NNN` token is excised.
- [ ] Read `git diff` for every changed file; confirm comment-region containment.
- [ ] Run `lake build BimodalTest` and `lake build BimodalToolsTest`; confirm both green.
- [ ] Commit per green sub-step.

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 45 occurrences across 13 files -- `Tests/BimodalTest/Automation` 29 across
8 files, `Tests/BimodalTest/Integration` 12 across 3 files,
`Tests/BimodalTest/Theorems/ModalS5Test.lean` 3, `Tests/BimodalToolsTest/C5SmokeTest.lean` 1.
Re-derived at plan-authoring time from the same lint run as Phase 1. Confirm by re-running
`check-task-references.sh Tests` before editing and subtracting Phase 3's already-cleared
subtrees.

**Tier Justification**: Same edit class as Phase 3 -- comments and docstrings inside single
modules, no exported signature touched -- discharged by `lake build BimodalTest` plus
`lake build BimodalToolsTest`, the two library builds that between them elaborate every file in
this phase's list; the only reason this is a separate phase from 3 is that both discharge their
tier with the same `BimodalTest` build and must not contend for the lake lock.

**Files to modify**:
- `Tests/BimodalTest/Automation/TacticsTest.lean` - docstring test inventory, two `Task 365` notes, three section headings
- `Tests/BimodalTest/Automation/ProofSearchBenchmark.lean` - six `(Task N)` section headings and runner comments
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` - two section headings and two `blocked by task 315` notes
- `Tests/BimodalTest/Automation/WeakeningSearchTest.lean` - title heading and four acceptance-criterion comments
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` - two section headings
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` - title heading
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - title heading
- `Tests/BimodalTest/Automation/TacticsTest_Simple.lean` - one quarantine note
- `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean` - eight quarantine notes
- `Tests/BimodalTest/Integration/TemporalIntegrationTest.lean` - three quarantine notes
- `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` - one quarantine note
- `Tests/BimodalTest/Theorems/ModalS5Test.lean` - three `(Task NN)` section headings
- `Tests/BimodalToolsTest/C5SmokeTest.lean` - one historical-fix attribution

**Verification**:
- `bash .claude/scripts/check-task-references.sh Tests` exits 0 with `0 occurrence(s)` -- the
  whole `Tests/` tree is closed by this phase.
- `lake build BimodalTest` and `lake build BimodalToolsTest` both exit 0 with no new error or
  warning.
- `git diff --stat` touches only the thirteen files above.
- Diff read-through confirms comment-region containment, that test-index ranges were preserved,
  and that no unlicensed marker was added.

---

### Phase 5: Close the last occurrence and verify the full gate set [NOT STARTED]

**Goal**: `bash .claude/scripts/check-task-references.sh` exits 0 repo-wide, the complete gate
set is green, and the marker delta introduced by this task is audited.

**Tasks**:
- [ ] Fix the single `scripts/check-module-invariants.sh` occurrence (line ~1722): the comment
      quotes `"task 42"` as an illustrative forbidden form. Replace it with the placeholder
      `"task {N}"` -- taxonomy category 5, which `TASK_PATTERN` structurally cannot match, so no
      marker is required and none should be added. Note that this script deliberately excludes
      its own path from its *own* C-check self-match, which is unrelated to and does not exempt
      it from `check-task-references.sh`.
- [ ] Run the full unscoped lint: `bash .claude/scripts/check-task-references.sh`. Require exit 0
      and `PASS: 0 unexempted task-reference occurrences`.
- [ ] Audit the marker delta: `git diff main -- . | grep -n 'task-ref-ok'`. For every marker this
      task added, confirm it names a numbered category from
      `.claude/context/standards/task-reference-exemptions.md` and that the category genuinely
      applies. Replace any marker that fails this audit with a durable-anchor rewrite and re-run
      the lint. Expected delta: zero markers.
- [ ] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh`. Record which gates
      `[SKIP]` and why -- gate 4 (the task-reference lint gate) is expected to `[SKIP]` because
      this repo is a deploy consumer with no `agent-system/extensions` directory, which is why
      the direct lint invocation above is the authoritative acceptance check rather than gate 4.
- [ ] Run the Lean build set: `lake build`, `lake build BimodalTest`,
      `lake build BimodalToolsTest`. Require all three green.
- [ ] Confirm no file under `specs/**`, `.claude/**`, or ROADMAP.md was modified by this task.
- [ ] Commit.

**Timing**: 0.5 hours

**Depends on**: 2, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: 1 occurrence in `scripts/check-module-invariants.sh`, and 198 total
occurrences cleared across all five phases (66 + 21 + 65 + 45 + 1). Both figures were re-derived
at plan-authoring time from `bash .claude/scripts/check-task-references.sh`. Confirm at
implementation time by the full unscoped lint run in this phase's task list, which is the
acceptance criterion itself; a residual nonzero count means an earlier phase's scope hypothesis
was wrong and must be reconciled, not papered over with markers.

**Files to modify**:
- `scripts/check-module-invariants.sh` - convert the quoted illustrative `"task 42"` to the `"task {N}"` placeholder form

**Verification**:
- `bash .claude/scripts/check-task-references.sh` exits 0 with
  `PASS: 0 unexempted task-reference occurrences` -- the task's stated acceptance bar.
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the complete gate set, gates 1-22; gate 4's
  `[SKIP]` on this deploy-consumer tree recorded explicitly, with the direct lint run above
  standing as its substitute evidence).
- `lake build`, `lake build BimodalTest`, `lake build BimodalToolsTest` all exit 0.
- `git diff --stat main` shows changes confined to `Boneyard/**`, `Tests/**`, and
  `scripts/check-module-invariants.sh` -- no `.claude/**`, no `specs/**` deliverable, no
  `ROADMAP.md`.
- The marker-delta audit records zero unlicensed `task-ref-ok` markers.

---

## Testing & Validation

- [ ] `bash .claude/scripts/check-task-references.sh` exits 0 with
      `PASS: 0 unexempted task-reference occurrences`.
- [ ] `bash .claude/scripts/check-task-references.sh Boneyard` exits 0.
- [ ] `bash .claude/scripts/check-task-references.sh Tests` exits 0.
- [ ] `bash .claude/scripts/check-task-references.sh scripts` exits 0.
- [ ] `lake build` exits 0 (`FormalSystem`, the default target, untouched but confirmed).
- [ ] `lake build BimodalTest` exits 0 with no new error or warning.
- [ ] `lake build BimodalToolsTest` exits 0 with no new error or warning.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0, with each `[SKIP]` accounted for.
- [ ] Zero `task-ref-ok` markers added without a named, genuinely-applicable taxonomy category.
- [ ] No edit to `check-task-references.sh`, `scripts/lib/task-reference-patterns.sh`,
      `hooks/validate-no-task-references.sh`, or `task-reference-exemptions.md`.
- [ ] No behavioral change: no test un-quarantined, no proof altered, no declaration renamed.

## Artifacts & Outputs

- Cleaned `Boneyard/**/README.md` (24 files) and `Boneyard/**/*.lean` (9 files).
- Cleaned `Tests/BimodalTest/**` (18 files) and `Tests/BimodalToolsTest/C5SmokeTest.lean`.
- Cleaned `scripts/check-module-invariants.sh` (1 line).
- One commit per green sub-step, five phase-closing commits.
- `specs/766_clear_task_reference_citation_debt/summaries/01_*-summary.md` at implementation
  completion, recording the final lint exit code and the marker delta.

## Rollback/Contingency

- A defensive `bash .claude/scripts/git-snapshot.sh 766 --no-revert` checkpoint is taken at the
  start of Phase 1, giving a durable pre-task anchor without reverting the working tree.
- Commit-per-green-sub-step means any single file's rewrite can be reverted with
  `git revert <sha>` or `git checkout <sha>^ -- <path>` without disturbing the rest.
- If a `lake build BimodalTest` failure appears after a bulk `sed`, fix forward: the failure can
  only be a mangled comment delimiter, so re-read the diff for the offending file and restore the
  delimiter. Never discard uncommitted work to reach a green build
  (see `context/contracts/recovery.md`).
- If an occurrence genuinely resists both sanctioned routes -- no durable anchor exists and no
  taxonomy category applies -- stop and record it as a blocker rather than widening the taxonomy
  or editing the lint. That is a `user_decision`-adjacent gap about whether the taxonomy needs an
  eighth category, and it belongs to the user, not to this task.
