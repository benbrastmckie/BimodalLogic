# Implementation Plan: Task #638

- **Task**: 638 - Post-publication size splits and the Lean module system
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: Task 637 (completed)
- **Research Inputs**: specs/638_post_publication_size_splits_and_module_system/reports/01_size-splits-module-system.md
- **Artifacts**: plans/01_size-splits-module-system.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Two Lean files exceed 4,500 lines. Research found, and confirmed by scratch elaboration, that
`EFGames/GapDetection.lean` has three real dependency seams (four import-acyclic declaration
families) and that `GameTransfer/SplitPoint.lean` has exactly one (the `SplitPointProps` structure,
which `CaseAnalysis.lean` alone consumes). This plan moves declarations verbatim into a flat
four-module layout for gap detection and a one-module extraction for the split-point structure,
re-points three consumer imports, regenerates the root, and records the Lean module-system
evaluation as durable prose rather than code. Definition of done: no fully-qualified declaration
name changes, no proof text changes, no new `sorry` or axiom, full build and full harness green.

### Research Integration

Integrated from report 01 (all findings verified against the live tree during planning: line
counts 5,094 / 4,906, import lines, seam openers at L361 / L773 / L2879, the contiguous
`set_option maxHeartbeats 800000 in` + reason comment + docstring at SplitPoint L130-135):

- R1 flat four-module layout for GapDetection, keeping `GapDetection.lean` as the definitions
  module so the module name, the Boneyard import, and both `private` mangled names survive.
- R2 extract `SplitPointProps`; leave `obtain_split_point_props` whole. Cutting inside the
  4,774-line proof is a proof refactor, excluded by `ORGANISATION.md` "Module size".
- R3 aggregator closure: three import lines added to `FormalSystem/Metalogic/Expressiveness.lean`.
- R4 documentation in the same change, including the stale "sorry'd pending" docstring sentence.
- R5 `file_scope` is still narrower than the change. Planning confirmed the research postflight
  did NOT widen it (`--file-scope-add` is research-postflight-only), so Phase 1 does it.
- R6 module system: not adopted here; the evaluation is delivered as prose.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied with this dispatch. The task is item "Phase 9 (optional,
post-publication acceptable)" and brief I of `docs/development/PUBLICATION_REFACTOR.md`.

## Goals & Non-Goals

**Goals**:
- Split the gap-detection file into its four import-acyclic declaration families, flat, under the
  existing directory and the existing namespace.
- Extract the split-point property structure into its own module so its sole structural consumer
  no longer waits on the two-minute proof.
- Keep every fully-qualified declaration name, every proof text, and every axiom set unchanged,
  and show it with before/after evidence.
- Keep the generated root byte-identical to generator output and the whole harness green.
- Record the module-system evaluation durably: the empirical constraints, the cost inventory, and
  the recommended programme order.

**Non-Goals**:
- Decomposing any single proof (the split-point theorem, either Lemma 9 proof) into lemmas.
- Adopting the module system anywhere: no module keyword, no public import, no expose attribute.
- Creating a subdirectory, a new aggregator, or a new README.
- Deleting the unused private helper in the gap-detection file, or any other cleanup.
- Retiring a long-file baseline for its own sake.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cut lands mid-docstring or mid-section because line numbers drifted | H | L | Phase 1 re-derives every cut from declaration names and `/-!` openers, never from the report's numbers; Phase 2/3 run a mechanical verbatim-move diff before building |
| `WeakCanonical/Transfer.lean` loses `obtain_split_point_props` (it reaches it only through `CaseAnalysis`) | H | H if forgotten | The new import is an explicit Phase 3 task and Transfer is the Phase 3 build target |
| Hand-edited `FormalSystem.lean` fails the byte-for-byte root check | M | M | Always regenerate with `lake exe mk_all --lib FormalSystem`; never edit by hand |
| Lint warnings never measured (scratch runs lacked the package linter set) | M | M | Real guarded builds in Phases 2, 3, 6; new paths have no warning-budget row, so the target is zero warnings |
| `linter.style.longFile` baseline too loose or too tight on the three long files | L | H | Let the linter's own message dictate N; convention observed is (floor(lines/100)+2)*100 |
| Foreground `lake build` livelock on the 125 s proof plus its downstream | H | M | Every build is detached and guarded per `.claude/context/project/lean4/operations/long-builds.md`; completion notification awaited before closing a phase |
| Downstream rebuild paid more than once | L | M | Phase 2 verifies only up to `CustomGame`; the long chain is rebuilt once, in Phase 3; all docstring edits to moved files happen inside Phase 2's batch |
| `file_scope` widening collides with a sibling task | L | L | Planning checked: no non-terminal task names the added Lean paths; task 177's `docs/` prefix overlaps the added `docs/development/` paths but is `not_started` behind five unmet dependencies |
| Module-system scope creep | M | L | Any `module` keyword fails at line 1 on this toolchain unless the whole chain below is converted (research Probe 1); Phase 5 is prose only |

**Decision (planner): R2 is taken.** The research called it the weaker split and left it to the
planner. It satisfies the dependency-seam rule as written, costs one small file and two import
lines, and removes a 125 s proof from `CaseAnalysis.lean`'s critical path. `SplitPoint.lean` stays
over 4,500 lines and `ORGANISATION.md` will say why.

**Decision (planner): the evaluation gets its own document**, `docs/development/MODULE_SYSTEM_EVALUATION.md`,
rather than only a pointer. A report under `specs/` is archived with the task; the three empirical
probes and the list of harness scripts that parse `import` lines are exactly what the eventual
programme needs first and are recorded nowhere else. `PUBLICATION_REFACTOR.md` reserves an ADR for
the case where the module system is ADOPTED, so no ADR is written here.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 5 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel. Phases 2 and 5 touch disjoint files (Lean
sources vs. `docs/development/`); Phase 5 runs no build.

### Phase 1: Preflight — scope, seams, before-state evidence [COMPLETED]

**Goal**: Make the change safe to start: the recorded scope covers every file the change touches,
the cut points are re-derived from the live files, and the "no name changes" baseline exists.

**Tasks**:
- [x] Confirm both target files are unmodified relative to `HEAD` and still 5,094 / 4,906 lines; if
  not, re-derive everything below from the live content.
- [x] Union-add the missing paths to task 638's `file_scope` in `specs/state.json` through
  `bash .claude/scripts/state-write.sh` (additions only, `+=` then `unique`; never a wholesale
  array assignment; never touch another task's entry). Paths to add:
  `FormalSystem/Metalogic/Expressiveness/EFGames/MuRelativizedTruth.lean`,
  `.../EFGames/GapDetectionLeft.lean`, `.../EFGames/GapDetectionRight.lean`,
  `.../EFGames/CustomGame.lean`, `.../GameTransfer/SplitPointProps.lean`,
  `.../GameTransfer/CaseAnalysis.lean`, `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`,
  `FormalSystem/Metalogic/Expressiveness.lean`, `docs/development/MODULE_SYSTEM_EVALUATION.md`,
  `docs/development/README.md`, `docs/development/PUBLICATION_REFACTOR.md`.
- [x] Re-derive the three GapDetection cut points and the one SplitPoint cut point by declaration
  name and `/-!` section opener, and record them (with the first and last line of text of each
  block) in `specs/638_post_publication_size_splits_and_module_system/evidence/cut-points.md`.
  Expected: F-mu opens at the `/-! ### Mu-Relativized Truth at Actual Points` header; F-left at
  `/-! ### Gap Uniqueness for Lemma 9`; F-right at `/-! ### GHR93 Lemma 9 (Gap detection
  correctness, right direction)`; the SplitPoint cut falls between the end of
  `structure SplitPointProps` and the `set_option maxHeartbeats 800000 in` line.
- [x] Capture the before-state: a scratch Lean file (session scratchpad, not the tree) importing
  `...EFGames.GapDetection` and `...GameTransfer.SplitPoint` that runs `#print axioms` on each
  public declaration of the two files, executed with `lake env lean`. Save the output as
  `evidence/names-axioms-before.txt` in the task directory. If the `.olean` files are stale, build
  the two modules first with the guarded, detached invocation.
- [x] Save pristine copies of both files to the scratchpad (`git show HEAD:<path>`) for the
  verbatim-move diff in Phases 2 and 3.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: 17 public declarations are affected (15 public in `GapDetection.lean`,
plus `SplitPointProps` and `obtain_split_point_props`), and 2 private ones
(`operator_depth_flatten_stavi_le`, `stavi_depth_left_formula_base`) that stay in
`GapDetection.lean`. Confirm by scanning declaration keywords in both files; the before-state file
must list exactly the public set found, whatever its size.

**Files to modify**:
- `specs/state.json` - `file_scope` additions for task 638 only
- `specs/638_post_publication_size_splits_and_module_system/evidence/cut-points.md` - new
- `specs/638_post_publication_size_splits_and_module_system/evidence/names-axioms-before.txt` - new

**Verification**:
- `jq` shows all eleven added paths present in task 638's `file_scope`, all eight prior entries
  still present, and no other task entry changed (`git diff -- specs/state.json` read-through).
- `names-axioms-before.txt` has one axiom report per public declaration and no error lines.

---

### Phase 2: Split `GapDetection.lean` into its four families [COMPLETED]

**Goal**: Four flat modules under `EFGames/`, declarations moved verbatim, `CustomGame.lean`
importing only what it uses, the root regenerated.

**Tasks**:
- [x] Start from a clean tree (`git status --porcelain` empty apart from unrelated `specs/` state).
  If the batch has to be paused while red (interruption, context pressure), do not commit it:
  checkpoint with `bash .claude/scripts/git-snapshot.sh --no-revert 638` and record the reference
  in the handoff.
- [x] Create `EFGames/MuRelativizedTruth.lean` (F-mu: `extendPoint_lt_iff`,
  `temporal_truth_mu_at_point`, `stavi_truth_mu_at_point`), importing `...EFGames.TypeFormulas`.
- [x] Create `EFGames/GapDetectionLeft.lean` (F-left: `gap_detection_unique`,
  `stavi_untl_gap_detection`, `left_formula_gap_detection`), importing `...EFGames.GapDetection`
  and `...EFGames.MuRelativizedTruth`.
- [x] Create `EFGames/GapDetectionRight.lean` (F-right: `stavi_snce_gap_detection`,
  `gap_detection_unique_right`, `right_formula_gap_detection`), same two imports.
- [x] Reduce `EFGames/GapDetection.lean` to F-defs (the four formula definitions, both private
  helpers, the two rank-bound theorems); rewrite its module docstring to describe the
  definitions module and point at the three siblings; remove its `set_option
  linter.style.longFile` line (it drops to roughly 370 lines).
- [x] Every new file: the 5-line copyright header copied from the source, then imports, then a
  `/-! # Title` module docstring, then (long files only) the longFile option, then
  `namespace FormalSystem.Metalogic.Expressiveness`, `open FormalSystem.Syntax`, the block, and
  the matching `end`. No `section`, `variable`, or attribute is needed (research side-effect scan).
- [x] Run the verbatim-move check BEFORE any docstring edit: concatenate, in the order defs, mu,
  left, right, the text between `open FormalSystem.Syntax` and the closing `end` of each of the
  four files, and `diff -B` it against the same region of the pristine copy. The diff must be
  empty.
- [x] Only then fix the stale sentence in `left_formula_gap_detection`'s docstring ("This is
  sorry'd pending the full game-theoretic proof in Phase 4C"): the file contains no `sorry`.
  Replace it with a true statement of what the theorem proves; no task numbers, no phase labels.
- [x] `EFGames/CustomGame.lean` line 7: re-point the import from `...EFGames.GapDetection` to
  `...EFGames.MuRelativizedTruth`. `ContinuationSets.lean` needs no edit.
- [x] Set `set_option linter.style.longFile N` directly after the module docstring of
  `GapDetectionLeft.lean` and `GapDetectionRight.lean`, with N taken from the linter's message.
- [x] Regenerate the root: `lake exe mk_all --lib FormalSystem`. Do not hand-edit.
- [x] Build, detached and guarded, scoped to the five modules:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Metalogic.Expressiveness.EFGames.GapDetectionLeft FormalSystem.Metalogic.Expressiveness.EFGames.GapDetectionRight FormalSystem.Metalogic.Expressiveness.EFGames.CustomGame`
  under `Bash(run_in_background: true)`; wait for the completion notification. *(deviation: altered — the guard requires the lake subcommand after `--`, so the invocation run was `... --timeout 1800 -- build <modules>`; the shape as written exits 77 before building anything)*
- [x] Commit the batch once green.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: The batch is exactly six files (three new, `GapDetection.lean`,
`CustomGame.lean`, `FormalSystem.lean`). Confirm with `git status --short` before staging; any
seventh path means a consumer was missed and must be explained, not staged silently. Expected
sizes (hypotheses): defs ~370, mu ~440, left ~2,130, right ~2,240 lines.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetection.lean` - reduced to F-defs
- `FormalSystem/Metalogic/Expressiveness/EFGames/MuRelativizedTruth.lean` - new
- `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetectionLeft.lean` - new
- `FormalSystem/Metalogic/Expressiveness/EFGames/GapDetectionRight.lean` - new
- `FormalSystem/Metalogic/Expressiveness/EFGames/CustomGame.lean` - one import line
- `FormalSystem.lean` - regenerated

**Verification**:
- Verbatim-move `diff -B` is empty (run before the docstring fix).
- Scoped build exits 0 with zero errors and zero warnings attributed to the four EFGames files.
- `lake exe mk_all --lib FormalSystem --check` passes.
- `grep -c sorry` on the four files is 0; `Boneyard/StaviDiscretePath/NFGameBridge.lean`'s import
  of `...EFGames.GapDetection` still names an existing module.

---

### Phase 3: Extract `SplitPointProps`; close the aggregator [COMPLETED]

**Goal**: `CaseAnalysis.lean` depends on the structure only; the theorem stays whole with its
scoped heartbeat option; `import FormalSystem.Metalogic.Expressiveness` still means the whole
development.

**Tasks**:
- [x] Start from a clean tree (`git status --porcelain` empty apart from unrelated `specs/` state).
  If the batch has to be paused while red (interruption, context pressure), do not commit it:
  checkpoint with `bash .claude/scripts/git-snapshot.sh --no-revert 638` and record the reference
  in the handoff.
- [x] Create `GameTransfer/SplitPointProps.lean`: copyright header, import of
  `...GameTransfer.DConsistencyTransport`, module docstring, namespace, `open`, the
  `/-! ## GHR93 Theorem 6: Inductive Step Infrastructure` section docstring and
  `structure SplitPointProps`, `end`.
- [x] Reduce `GameTransfer/SplitPoint.lean` to the theorem: import becomes
  `...GameTransfer.SplitPointProps`; module docstring updated; the `set_option maxHeartbeats
  800000 in` line, the three-line `--` reason comment, the docstring and
  `theorem obtain_split_point_props` stay contiguous and byte-identical; retighten the
  `linter.style.longFile` baseline from the linter's message (expected 4900 or 5000).
- [x] Verbatim-move check: structure block + theorem block, concatenated, `diff -B` against the
  pristine copy's body. Must be empty.
- [x] `GameTransfer/CaseAnalysis.lean` line 7: re-point from `...GameTransfer.SplitPoint` to
  `...GameTransfer.SplitPointProps`.
- [x] `WeakCanonical/Transfer.lean`: add `import FormalSystem.Metalogic.Expressiveness.GameTransfer.SplitPoint`
  in sorted position among its imports. Without it the build breaks.
- [x] `FormalSystem/Metalogic/Expressiveness.lean`: add three import lines —
  `...EFGames.GapDetectionLeft`, `...EFGames.GapDetectionRight`, `...GameTransfer.SplitPoint` —
  following the file's existing ordering convention, and update its docstring if it enumerates
  what it covers.
- [x] Regenerate the root: `lake exe mk_all --lib FormalSystem`.
- [x] Build, detached and guarded:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Metalogic.WeakCanonical.Transfer FormalSystem.Metalogic.Expressiveness`
  under `Bash(run_in_background: true)`. This pays the long downstream rebuild once (the chain
  `CustomGame -> ... -> DConsistencyTransport -> SplitPoint` plus `Transfer`). Use only the passive
  progress checks of `long-builds.md` while waiting; wait for the completion notification. *(deviation: altered — invoked as `... -- build <modules>`, the lake subcommand being required after `--`; aggregator docstring left unchanged because it enumerates topics, not files)*
- [x] Commit the batch once green.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: The batch is exactly six files (`SplitPointProps.lean` new, `SplitPoint.lean`,
`CaseAnalysis.lean`, `Transfer.lean`, `Expressiveness.lean`, `FormalSystem.lean`), and
`Transfer.lean` is the only consumer of the theorem outside `SplitPoint.lean`. Confirm the second
claim with `grep -rlw obtain_split_point_props FormalSystem Tests BimodalTools` (prose mentions in
`CustomGame.lean` do not count) before editing.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPointProps.lean` - new
- `FormalSystem/Metalogic/Expressiveness/GameTransfer/SplitPoint.lean` - theorem only
- `FormalSystem/Metalogic/Expressiveness/GameTransfer/CaseAnalysis.lean` - one import line
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` - one added import
- `FormalSystem/Metalogic/Expressiveness.lean` - three added imports
- `FormalSystem.lean` - regenerated

**Verification**:
- Verbatim-move `diff -B` is empty.
- Build exits 0, zero errors, zero warnings attributed to the touched files.
- The scoped heartbeat option still immediately precedes its reason comment and the theorem.
- `Boneyard/SorriedDeclExcisions/Ghr93ForwardToBackwardChain.lean`'s import of
  `...GameTransfer.SplitPoint` still names an existing module.

---

### Phase 4: Directory and policy documentation [NOT STARTED]

**Goal**: Every prose surface that names the two files tells the truth about the new layout.

**Tasks**:
- [ ] `EFGames/README.md`: add rows for the three new modules; correct the `GapDetection.lean`
  row (lines, description); repair the rows research found stale (the archived
  `NFGameBridge.lean` row; `StaviCompleteness.lean` listed at 3,252 against an actual 1,665);
  re-derive every line count in the table with `wc -l` rather than trusting any number here;
  adjust "Key Results" attribution; bump `Last verified`.
- [ ] `GameTransfer/README.md`: add the `SplitPointProps.lean` row, new line counts, "Key Results"
  attribution (structure vs. theorem); bump `Last verified`.
- [ ] `ORGANISATION.md` "Module size": `GapDetection.lean` leaves the over-4,500 list, with one
  sentence naming the seams that were found; `SplitPoint.lean` stays, with its new line count and
  the reason (one proof; its one seam, the property structure, has been taken).
- [ ] `FormalSystem/README.md` and the root `README.md`: edit only if they name either file or a
  line count that changed; otherwise leave untouched and record that in the summary.
- [ ] All new prose: real paths only, no task numbers, no phase labels of any refactor programme
  used as if they were durable anchors.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: Only `ORGANISATION.md` and the two directory READMEs name the split files
in live prose (planning grep over `README.md`, `FormalSystem/README.md`, `ORGANISATION.md`,
`docs/`). Re-run `grep -rn 'GapDetection\|SplitPoint' --include='*.md' . ` excluding `specs/`,
`.claude/`, `.lake/` and `Boneyard/` at implementation time and treat any further hit as in
scope.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/EFGames/README.md` - module table, key results, date
- `FormalSystem/Metalogic/Expressiveness/GameTransfer/README.md` - module table, key results, date
- `ORGANISATION.md` - "Module size" paragraph
- `FormalSystem/README.md`, `README.md` - only if a hit is found

**Verification**:
- `bash scripts/readme-lint.sh` passes.
- Every path and module name written resolves on disk.
- Diff read-through: all hunks are prose.

---

### Phase 5: Module-system evaluation record [COMPLETED]

**Goal**: The evaluation the task asks for exists as a durable document a future programme can
start from, with the verdict "not now; its own programme; decision record first".

**Tasks**:
- [x] Write `docs/development/MODULE_SYSTEM_EVALUATION.md` from report 01's "External Resources"
  and R6, restated as verified facts about the pinned toolchain, with sections: verdict; what was
  tested and how (the three probes, reproducible command shape); upstream adoption counts at the
  pinned Mathlib tag; the two binding constraints (a `module` cannot import a non-`module`, so
  adoption is bottom-up from `FormalSystem/Init.lean` and cannot be piloted mid-DAG; public
  `rfl`/`decide`-style theorems need `@[expose]`, so blanket `@[expose] public section` is the
  only mechanical route); local cost inventory (file counts, `private` declarations, meta-code
  files, the scripts that parse `import` lines textually, the root-generator check); reasons to
  defer; reasons it is eventually worth doing; recommended programme order (decision record,
  then parsers with fixtures while the tree is still plain, then bottom-up conversion, then
  `mk_all --module` and the root check, then narrowing exposure).
- [x] Re-verify each count before writing it (they are a snapshot): re-run the greps from the
  report's appendix; state the date and the toolchain beside the numbers. *(deviation: altered — re-derived values differ from the report in three places and the re-derived ones were written: `private` is 765 under `FormalSystem/` (994 across all three trees) not 768; Mathlib exposure/meta counts are 4,941 / 2,699 / 531; the import-parser list drops `typst-status-counts.sh` and `test-move-modules.py`, which only emit or fixture plain imports, and adds `measure-refactor-partitions.py` and `reanchor-lean-citations.py`. All three probes were re-run and reproduced.)*
- [x] `docs/development/README.md`: add the index row.
- [x] `docs/development/PUBLICATION_REFACTOR.md`: in convention-map row 3a and the Phase 9
  bullet, add a pointer to the new document. Change nothing else there in this phase.
- [x] No Lean file is touched. No task numbers in the document.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: The report's counts (504 / 65 / 27 Lean files; 768 `private` declarations;
14 meta-code files; five import-parsing scripts plus `move-modules.py`; 8,199 of 8,268 Mathlib
files converted) are hypotheses as of the research date. Re-run each count; write the re-derived
value.

**Files to modify**:
- `docs/development/MODULE_SYSTEM_EVALUATION.md` - new
- `docs/development/README.md` - one index row
- `docs/development/PUBLICATION_REFACTOR.md` - two pointers

**Verification**:
- Links and paths in the new document resolve; `bash scripts/readme-lint.sh` passes.
- `grep -rn '^module$' FormalSystem Tests BimodalTools` is empty (nothing was adopted).

---

### Phase 6: Final gate and acceptance evidence [NOT STARTED]

**Goal**: Direct evidence for both acceptance clauses: no fully-qualified name changes; harness
green.

**Tasks**:
- [ ] Full build, detached and guarded:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --` (default targets) under
  `Bash(run_in_background: true)`; wait for the completion notification. Zero errors; no new
  warnings on any touched path.
- [ ] `lake exe mk_all --lib FormalSystem --check`.
- [ ] `bash scripts/check-module-invariants.sh` in full mode, so the build-dependent checks
  (axiom baselines, import resolution, every-module-reaches-Init) run, not only the static ones.
- [ ] `bash scripts/readme-lint.sh`.
- [ ] After-state evidence: the Phase 1 scratch file with its imports changed to
  `...EFGames.GapDetectionLeft`, `...EFGames.GapDetectionRight`, `...GameTransfer.SplitPoint`, run
  with `lake env lean`; save as `evidence/names-axioms-after.txt`;
  `diff evidence/names-axioms-before.txt evidence/names-axioms-after.txt` must be empty.
- [ ] Confirm the two private helpers still live in `GapDetection.lean` (so their mangled names
  are unchanged).
- [ ] If `PUBLICATION_REFACTOR.md` carries a status line for its Phase 9, update it to say the
  splits landed and the module-system evaluation is recorded; if it carries none, add none.
- [ ] Fix forward on any red check; re-run the failing check, then the whole gate.

**Timing**: 1 hour

**Depends on**: 4, 5

**Verification Tier**: full

**Files to modify**:
- `specs/638_post_publication_size_splits_and_module_system/evidence/names-axioms-after.txt` - new
- `docs/development/PUBLICATION_REFACTOR.md` - Phase 9 status line, only if one exists
- any file a red check names (fix forward, within `file_scope`)

**Verification**:
- All four commands exit 0.
- The before/after diff is empty.
- `git grep -n sorry` over the six touched Lean sources under `Expressiveness/` shows no new hit.

## Lean Challenge Statements

This plan commits to **no new and no changed Lean theorem statements**. Every declaration is moved
verbatim between modules inside one unchanged namespace; the `Goals` bullets name no Lean
identifiers, so the challenge identifier set is empty by construction and matches. The acceptance
evidence for statement stability is Phase 6's before/after `#print axioms` diff, not a challenge
module.

## Testing & Validation

- [ ] Verbatim-move `diff -B` empty for both splits (Phases 2, 3)
- [ ] Guarded full `lake build` exits 0; zero new warnings on touched paths
- [ ] `lake exe mk_all --lib FormalSystem --check` passes
- [ ] `bash scripts/check-module-invariants.sh` (full mode) passes
- [ ] `bash scripts/readme-lint.sh` passes
- [ ] `names-axioms-before.txt` and `names-axioms-after.txt` are identical
- [ ] No `sorry`, no new axiom, no `module` keyword introduced
- [ ] Both Boneyard imports (`EFGames.GapDetection`, `GameTransfer.SplitPoint`) still resolve

## Artifacts & Outputs

- `FormalSystem/Metalogic/Expressiveness/EFGames/{GapDetection,MuRelativizedTruth,GapDetectionLeft,GapDetectionRight}.lean`
- `FormalSystem/Metalogic/Expressiveness/GameTransfer/{SplitPointProps,SplitPoint}.lean`
- Import edits: `EFGames/CustomGame.lean`, `GameTransfer/CaseAnalysis.lean`,
  `WeakCanonical/Transfer.lean`, `FormalSystem/Metalogic/Expressiveness.lean`; regenerated `FormalSystem.lean`
- `docs/development/MODULE_SYSTEM_EVALUATION.md`; updated `docs/development/README.md`,
  `docs/development/PUBLICATION_REFACTOR.md`, `ORGANISATION.md`, two directory READMEs
- `specs/638_post_publication_size_splits_and_module_system/evidence/` (cut points, before/after)
- `specs/638_post_publication_size_splits_and_module_system/summaries/01_size-splits-module-system-summary.md`

## Rollback/Contingency

Each phase lands as its own commit (Phases 2 and 3 as one atomic batch each), so a landed phase is
undone with `git revert <sha>`; Phase 3 must be reverted before Phase 2. Reverting restores the
old files byte-for-byte because no declaration was edited, only moved.

For a red, uncommitted mid-batch state, follow the recovery ladder in
`.claude/context/contracts/recovery.md` in order: fix forward first (the usual causes are a
missed import, a cut one line off, or a hand-touched root). Only if a genuine rollback is
unavoidable, use that file's rung (c), snapshot-then-smallest-scope-rollback, with the invocation
shape and out-of-scope override it specifies. A `--no-revert` checkpoint taken while pausing a red
batch in Phase 2 or 3 is a durable restore point and does not itself revert anything.

If R2 proves troublesome (for example an unexpected consumer of the theorem), Phase 3 may land
with the aggregator closure for the GapDetection modules only and `SplitPoint.lean` left
untouched; `ORGANISATION.md` then records that a seam exists and was not taken. That outcome
still meets the acceptance criteria.
