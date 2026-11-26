# Implementation Plan: Task #987

- **Task**: 987 - Temporal rules follow-ups: fold names and progress tests
- **Status**: [COMPLETED]
- **Effort**: 10 hours
- **Dependencies**: None blocking. Adjacent and separate: `connective_signature_layer_shared_primitives` (owns the siting of the TM syntax `PlusLanguage/TemporalViews.lean` declares under the TM-plus directory, untouched here); `proof_mode_until_since_intro_unfold_induction` builds on the same modules and runs AFTER this record.
- **Research Inputs**: `specs/987_temporal_rules_followups_fold_names_and_progress_tests/reports/01_temporal-rules-followups.md`
- **Artifacts**: plans/01_temporal-rules-followups.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Seven follow-ups owed after the compositional-temporal-rules contribution merged, all confirmed
live on the merged tree: the expand/contract rename of the one-step Until and Since identifiers,
`lprogress` coverage plus a negative test for every reachable `throwError` path the contribution
added, the instance-synthesis reordering in `applyDerivationProof` with its ordering contract
stated in the doc comment, a narrowed `integerTimeGate` catch, three wrong module descriptions,
and a status stamp whose commit does not reproduce its own counts. The work is mechanical but
wide: 55 identifier occurrences across two Lean modules, 26 reachable-unpinned `throwError`
sites, 14 empty cells in the `lprogress` coverage matrix. Done means `lake build` and `lake test`
green, no identifier carrying the old fold/unfold vocabulary inside the three `ProofMode`
namespaces, `lprogress` covered for its other forms and for the past direction and TM⁺, a
`#guard_msgs` test for every reachable added `throwError` path (with an in-source note on each
provably unreachable arm), a positive regression test that fails against the pre-fix instance
ordering, each README description naming what its module now contains, and a status stamp whose
own commit reproduces the recorded counts.

### Research Integration

The research report established the merged-tree baseline and verified both non-mechanical items
by compiled probe before recommending them. Three findings reshape the work and are carried as
plan decisions, not options:

- **The rename must not be a tree-wide sed.** `untilFold` and `sinceFold` also name an unrelated
  Rabinovich bounded-fix construction under `FormalSystem/Metalogic/Expressiveness/Kamp/`
  (re-measured at plan authoring time: 46 occurrences across three files there, against 55 inside
  the two `ProofMode` modules). Every edit is confined to the `ProofMode` namespaces.
- **Item (3)'s regression test is a positive example, not a message pin.** The measured pre-fix
  failure is `lapply could not synthesize the required instance FrameTag ?m.3`, whose `?m.3` is an
  unstable metavariable index. A positive example fails loudly against the pre-fix ordering
  (measured by compiled probe) and pins no text.
- **Item (5) narrows on `"incompatible concrete frame classes"` via `(s.splitOn pat).length > 1`.**
  `String.containsSubstr` is outside this module's import closure (measured). The narrowing was
  compiled and the existing pinned `integer-time reasoning requires FrameClass.ZTime ≤
  FrameClass.Dense` message matched byte-for-byte.

### Premise Re-Validation (dispatch Carried-Figure Discipline)

Every trigger-class claim in the dispatch description was checked against the report and against
live state at plan authoring time. Results, stated even where they only confirm:

- **The merged tree is still the baseline; nothing can be dropped as already done.** `a7be7db65`
  is an ancestor of `HEAD` (`c58c61c11`) and `git log a7be7db65..HEAD` over
  `FormalSystem/Automation/ProofMode/`, `FormalSystem/Theorems/ProofMode/` and
  `Tests/BimodalTest/Automation/` is empty. Re-measured; confirms the report.
- **Item (1)'s footprint is exactly two Lean files**, 29 occurrences in
  `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean` and 26 in
  `FormalSystem/Automation/ProofMode/TemporalZTime.lean`. All ten proposed new identifiers are
  unused tree-wide. Re-measured; confirms the report.
- **Item (2)'s `lprogress` coverage is 2 of 16 cells**, at `ProofModeTest.lean:102`
  (`using [...]`, future TM) and `ProofModeTemporalBooleanProgressTest.lean:21` (`cases`, future
  TM). Re-measured; confirms the report's correction to the description's "exactly one example".
- **Item (2)'s `throwError` arithmetic is CORRECTED.** 36 added sites is right, and the 5 already
  pinned are right, but the report's "24 reachable unpinned" does not reconcile with its own
  29-site enumeration, and that enumeration includes sites the contribution did not add. Measured
  per-file added counts (`git diff a7be7db65^..a7be7db65`, added lines containing `throwError`):
  Basic 2, Carrying 4, Discrete 2, Meta 1, Modal 4, Temporal 13, TemporalBoolean 9, TemporalZTime
  1 = **36**. Classifying those 36 by exact message text against the test tree gives **5 pinned,
  5 structurally unreachable, 26 reachable and unpinned** — arithmetic that closes. The
  unreachable class is 5, not 7: the report's `Discrete.lean:118` and `Modal.lean:110` entries are
  pre-existing or reachable, and only three `unregistered … rule {rule}` guards plus two
  `` expected `guard`/`event` ``/`` expected `future`/`past` `` fallback arms in `Temporal.lean`
  were added by the contribution. The per-phase inventory below uses the corrected figures.
- **Item (3)'s anchors hold.** The instance-synthesis loop sits at `Basic.lean:79-85`, before
  `adaptProof` (L86) and before the conclusion `isDefEq` (L93-94) and `goal.assign` (L95).
  Re-read live; confirms the report.
- **Item (4)'s docstring is unchanged.** `Basic.lean:57-59` still says only "Only holes created
  since `firstNewIndex` become new goals", and the sole in-tree caller `applyProof` (L111-116)
  reads `mvarCounter` before `elaborateProof`. Re-read live.
- **Item (5)'s bare catch is live.** `Temporal.lean:111-119`, `catch _ => throwError "integer-time
  reasoning requires …"`. Re-read live.
- **Item (6)'s three rows are live.** `Carrying.lean | 91 | <!-- TODO: add description -->`,
  `Discrete.lean | 129 | Next/Previous scopes and invariance with explicit ZTime certificates`,
  `Temporal.lean | 476 | … eventuality composition, progress, and Until/Since mapping`. Read live
  in `FormalSystem/Automation/ProofMode/README.md`; the `TemporalZTime.lean` row already reads
  "Adjacent Until and Since expansion and contraction", which independently corroborates item
  (1)'s target vocabulary.
- **Item (7)'s premise is CORRECTED, as the report found, and the correction is re-derived
  independently here.** The stamp commit `0c14ccb0e` does contain all the contribution's files
  (808 `.lean` files under `FormalSystem/` at that commit, the recorded figure). Summing
  `git cat-file blob` line counts over every `FormalSystem/**.lean` path yields **422468 at
  `0c14ccb0e`** against the recorded **422474**, which the live working tree reproduces exactly —
  the same +6 the report measured, by a different method (blob sum rather than a detached
  worktree running the generator). Every other recorded scalar matches at both points.
- **`readme-lint.sh` is already red, with 7 new stale rows**, re-measured by differencing the live
  `STALE DATE` findings against `scripts/readme-date-baseline.txt`:
  `FormalSystem/Automation/ProofMode`, `FormalSystem/Theorems/ProofMode`,
  `FormalSystem/Theorems/ProofMode/TemporalComposition`, `FormalSystem/Tactic`,
  `FormalSystem/Metalogic/Conservativity/Star`, `FormalSystem/Metalogic/Expressiveness`,
  `FormalSystem/Metalogic/WeakCanonical`. The first three are in territory and are bumped here;
  the other four are untouched and stay red.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap flag was set, so roadmap
consultation is skipped and this plan carries no roadmap-review or roadmap-regeneration phase.

## Goals & Non-Goals

- **Goals**:
  - Rename the eight one-step Until/Since derivation `def`s and their TM⁺ mirrors from the
    fold/unfold vocabulary to the expand/contract vocabulary `records/proof-mode-architecture.md`
    settles, repointing the six identifiers and four rule keys in the automation module with them.
  - Cover the three uncovered `lprogress` forms, the past direction and TM⁺, filling 14 of the
    16 cells in the coverage matrix.
  - Pin, with `#guard_msgs`, every one of the 26 reachable-unpinned `throwError` paths the
    contribution added, and record an in-source note on each of the 5 provably unreachable arms.
  - Move `applyDerivationProof`'s instance-synthesis loop after the conclusion unification, with a
    positive regression test whose class type mentions a rule parameter.
  - State `applyDerivationProof`'s `firstNewIndex`-before-elaboration ordering requirement in its
    doc comment.
  - Narrow `integerTimeGate`'s catch to the frame-class failure, appending the original message
    otherwise, so the real cause reaches the user and both pinned messages survive.
  - Correct the three wrong module descriptions in
    `FormalSystem/Automation/ProofMode/README.md`.
  - Regenerate `typst/generated/status.typ` last, so its stamp commit's tree reproduces its own
    counts.

- **Non-Goals**:
  - The siting of the TM syntax `PlusLanguage/TemporalViews.lean` declares under the TM-plus
    directory — `connective_signature_layer_shared_primitives`' territory.
  - Any rename under `FormalSystem/Metalogic/Expressiveness/Kamp/`. `untilFold`,
    `sinceFold` and their `*Anchored` siblings there name Rabinovich's bounded fix, a different
    namespace over a different type, and must be left exactly as they are.
  - A `#guard_msgs` test for the 5 structurally unreachable arms. A literal reading of "every
    `throwError` path" is unsatisfiable for an arm the parser forbids or whose argument only the
    elaborator can supply; those get an in-source note instead.
  - Any new Lean module. Every test lands in an existing test module, so no
    `lake exe mk_all --lib FormalSystem` re-run and no library-root change is owed.
  - Prose in `records/proof-mode-architecture.md` that still uses the old words. The DONE WHEN
    speaks of identifiers; the record's own "Open decisions" section already states the settled
    vocabulary.
  - Bumping the `*Last verified:*` stamp of any README outside this task's territory, including
    the three already-grandfathered parents (`FormalSystem`, `FormalSystem/Automation`,
    `FormalSystem/Theorems`) — refreshing a grandfathered row permanently un-grandfathers it for
    no gate benefit.
  - Any new theorem. See `## Lean Challenge Statements` and `## Decisions`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A tree-wide `untilFold`/`sinceFold` rename breaks `Metalogic/Expressiveness/Kamp/` | H | H if sed is used | Phase 1 edits only the two named files and closes by re-counting the Kamp occurrences (46 expected, unchanged); word-boundary matching already distinguishes `sinceFold` from `sinceFoldAnchored` |
| The pre-commit hook refuses a phase commit because `typst/generated/status.typ` drifted | H | H if unscheduled | Every phase that stages a `.lean` file runs `typst-sync-check.sh --counts-only` and, on drift, `--fix` plus a stage of `status.typ`, in that same phase — it is the commit-blocking surface and cannot be deferred |
| `typst-sync-check.sh --fix` is mistaken for a stamp fix | H | M | `--fix` regenerates ONLY on a Check 2 count mismatch and prints "Nothing to fix" otherwise, so it will NOT refresh a stale stamp whose counts already match. Phase 8 runs the bare `scripts/typst-status-counts.sh` write path instead |
| Rewrapping for the 100-column linter stales the generated `Lines` column of two inventories | M | M | Each `.lean`-touching phase runs `check-module-invariants.sh --emit-inventory` (write mode) then `--emit-inventory --check` |
| Item (5)'s narrowing breaks the two pinned `integer-time reasoning` tests | M | L | Measured not to: the `Dense` case reaches the frame-class branch the narrowing matches. Phase 3 re-runs both pinning test modules anyway |
| Item (3)'s move changes which error surfaces first on an unrelated failure | M | M | The loop lands after the "the applied rule produced an incompatible judgment" check, so that message now wins when both apply. Measured: the existing parameterless `ReviewInstance` pin is unaffected |
| A `#guard_msgs` pin embeds a metavariable index (`?m.N`) and goes stale on an unrelated edit | M | M | No phase pins a message containing `?m.`; item (3)'s regression test is a positive example instead. Every pin is of a message whose interpolations are context-determined, and a phase that must fix a context length to stabilise the text does so explicitly |
| A reachable-looking `throwError` turns out not to be triggerable from user syntax | M | M | Record it in-source as unreachable with the reason, the same treatment the 5 known arms get, and name it in the phase's completion notes rather than leaving a silent gap |
| `readme-lint.sh` is already red, so a post-task run reads as a regression | M | M | 7 new stale rows at baseline, enumerated above. Phase 8 expects exactly 4 afterwards and names which 4 |
| 26 negative tests is a large mechanical surface that could swamp one phase | M | H if unpartitioned | Partitioned by source module across phases 2, 3, 5, 6 and 7, each with its own enumerated site list |
| Concurrent sibling 993 on the same working tree | L | L | Its declared scope is `.claude-extensions.json` only, which no path here touches. Re-read each file immediately before editing anyway, and stage explicit file lists only |
| Under `--wfail` any linter warning is a CI failure, including `unusedVariables` | M | L | Each phase's own guarded build must be diagnostic-free, not merely exit 0 |

## Decisions

- **Zero Lean goals, declared explicitly.** This task proves no new theorem: the eight renamed
  declarations are existing `def`s whose signatures do not change, and the new test material is
  `example`s and `#guard_msgs` blocks, not named results. Pinning transcribed copies of eight
  unchanged signatures in a `## Lean Challenge Statements` block would create a second,
  drift-prone source of truth for statements the tree already fixes, and would hold the
  implementer to a transcription rather than to the real declaration. The rename is protected
  instead by exact-name greps in Phase 1's verification criteria, in both directions.
- **Item (6) travels with Phase 1.** The three wrong description cells sit inside the same
  generated inventory block of the same README whose `Lines` column Phase 1 regenerates. The
  description column survives regeneration, so hand-edit and regeneration compose in either
  order; doing both in one phase avoids two passes over one file.
- **Item (4) travels with item (3).** Both edit the same declaration — one its body, one its doc
  comment. Splitting them would mean two passes over `applyDerivationProof` and two separate
  commit-blocking regenerations for one function.
- **`status.typ` is regenerated twice over, for two different reasons.** Each `.lean`-touching
  phase regenerates it to keep the counts current, because `.githooks/pre-commit` blocks any
  commit staging a `.lean` path while Check 2 reports drift. Phase 8 regenerates it a final time,
  alone, via the bare `scripts/typst-status-counts.sh` write path, because the stamp is read from
  `git rev-parse --short HEAD` at generation time: only a regeneration taken AFTER the last
  `.lean` commit, and committed without any `.lean` path beside it, leaves a stamp whose own tree
  reproduces the recorded figures. The research report's "regenerate last, in its own commit" is
  therefore necessary but not sufficient on its own — the intermediate regenerations are owed too,
  and `--fix` alone cannot discharge Phase 8 because it is conditional on a count mismatch.
- **Item (2)'s DONE WHEN is read as "every reachable `throwError` path".** Five of the 36 added
  sites are fallback arms the parser cannot reach or `unregistered … rule {rule}` guards whose
  argument no user can supply. A `#guard_msgs` test for them would need a synthetic harness that
  tests nothing about the tactics; an in-source note naming the arm as unreachable from parsed
  syntax records the gap honestly instead.
- **Three README stamps are bumped, in Phase 8, not earlier.** `FormalSystem/Automation/ProofMode`,
  `FormalSystem/Theorems/ProofMode` and `FormalSystem/Theorems/ProofMode/TemporalComposition` are
  already live stale and absent from `scripts/readme-date-baseline.txt`, so bumping them is
  mandatory work rather than hygiene, and bumping after the last `.lean` commit avoids
  re-staling a stamp an intermediate phase would have invalidated. `plan-file-scope-harvest.sh`
  additionally appends the ancestor-chain READMEs (`FormalSystem/README.md`,
  `FormalSystem/Automation/README.md`, `FormalSystem/Theorems/README.md`) to this task's
  `file_scope` unconditionally, because any `.lean` edit can stale a generated block in them.
  Their presence there admits a regeneration of those blocks; it is not licence to touch their
  stamps, and neither `FormalSystem/README.md`'s top-level file rows nor
  `FormalSystem/Automation/README.md`'s `—` subdirectory rows move under this task's edits.
  `typst/generated/automation-module-map.typ` and `machine-appendix.{jsonl,typ}` are NOT coupled
  surfaces here: the first covers only `Automation/{Tactics,ProofSearch}/*.lean` plus
  `SuccessPatterns.lean`, and the second only `ProofSystem/{Axioms,Derivation}.lean` — measured
  at plan authoring time by reading each generator's own declared glob scope.
- **Verification criteria name this repository's own Lean gates directly, not a shell-suite
  subset.** Measured at plan authoring time by `suite_selection_select`, run once over this
  plan's whole touched set: every `FormalSystem/**.lean` and `Tests/**.lean` path returns
  `__FULL_SWEEP__`, every `*.md` path returns the same generic 20-suite agent-system markdown set
  (record-versioning lint, task-reference lint, artifact validators), and
  `typst/generated/status.typ` returns `test-plan-file-scope-harvest.sh` and
  `test-validate-artifact.sh`. None of the mapped suites has any bearing on Lean content, so each
  phase's covering check is the repository-specific gate named in its own Tier Justification —
  the unmappable-criterion case, not a suite-list claim and not a sentinel claim.
- **This plan is fully sequential.** Phases could not run in parallel even where their source
  edits are disjoint: every `.lean`-touching phase stages the same `typst/generated/status.typ`
  and the same regenerated inventory blocks, and phases 4 and 5 edit the same test module.

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
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. This plan has one phase per wave for the
reason recorded in `## Decisions`: the shared commit-blocking generated surface serialises every
phase that stages a `.lean` file, and phases 4 and 5 share a test module.

### Phase 1: Expand/Contract Rename and the Three Module Descriptions [COMPLETED]

**Goal**: No identifier inside the three `ProofMode` namespaces carries the fold/unfold
vocabulary; the Kamp bounded-fix occurrences are untouched; and
`FormalSystem/Automation/ProofMode/README.md`'s `Carrying.lean`, `Temporal.lean` and
`Discrete.lean` rows each describe what that module now contains.

**Tasks**:
- [ ] Re-read both files immediately before editing (concurrent sibling 993 is live on this tree)
      and record the starting counts: `grep -c -wE 'untilFoldRule|sinceFoldRule|untilUnfoldRule|sinceUnfoldRule|untilFold|sinceFold|untilUnfoldCases|sinceUnfoldCases' FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean` and the same for the six automation identifiers plus four rule keys in `FormalSystem/Automation/ProofMode/TemporalZTime.lean`.
- [ ] In `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean`, rename the eight `def`s in BOTH namespaces (`FormalSystem.Theorems.ProofMode` and the `FormalSystem.PlusLanguage.ProofMode` mirror): `untilFoldRule`→`untilContractRule`, `sinceFoldRule`→`sinceContractRule`, `untilUnfoldRule`→`untilExpandRule`, `sinceUnfoldRule`→`sinceExpandRule`, `untilFold`→`untilContract`, `sinceFold`→`sinceContract`, `untilUnfoldCases`→`untilExpandCases`, `sinceUnfoldCases`→`sinceExpandCases`. Keep all signatures and bodies byte-identical apart from the names.
- [ ] Repoint the internal uses in the same file (each `*Rule` is consumed by its matching wrapper; `sinceContractRule` and `sinceExpandRule` reach their Until counterparts through `reflectThm`).
- [ ] Update that file's section heading `/-! ## One-step fold and unfold -/` to the expand/contract wording, and the mirrored `/-! ### Fold and unfold -/` heading, and the four docstrings beginning "Unfold".
- [ ] In `FormalSystem/Automation/ProofMode/TemporalZTime.lean`, rename `binaryFold`→`binaryContract` and `binaryUnfold`→`binaryExpand` (both `private def`s), and the four `syntax (name := …)` nodes `luntilFold`→`luntilContract`, `luntilUnfold`→`luntilExpand`, `lsinceFold`→`lsinceContract`, `lsinceUnfold`→`lsinceExpand`. The user-facing keyword strings (`"luntil" … &"contract"`, `&"expand"`) are already correct and MUST NOT change.
- [ ] Move the four backtick-quoted rule keys in `oneStepRule` in lockstep with the Theorems-file names: `` `untilFold ``→`` `untilContract ``, `` `sinceFold ``→`` `sinceContract ``, `` `untilUnfoldCases ``→`` `untilExpandCases ``, `` `sinceUnfoldCases ``→`` `sinceExpandCases ``, together with the ``` `` ```-quoted fully-qualified names on each match arm and the two call sites in `binaryContract`/`binaryExpand`.
- [ ] Update the two "Unfold …" docstrings on the `luntilExpand`/`lsinceExpand` syntax nodes.
- [ ] Add a one-line note at `oneStepRule`'s `| _ => throwError "unregistered one-step temporal rule {rule}"` arm recording that the arm is unreachable from parsed syntax, because `rule` is supplied by the elaborator and never by user syntax. This is one of the 5 arms item (2) owes a note rather than a test for.
- [ ] Hand-edit the three description cells in `FormalSystem/Automation/ProofMode/README.md`'s generated inventory block, inside the `BEGIN GENERATED` fences (the description column is carried across verbatim by the generator, so a hand edit survives): replace `Carrying.lean`'s `<!-- TODO: add description -->` with a description of the carrying table (`CarryRule`, `carryRules`, `carryRule?`, `carriedFacts`; one rule per source-operator/target-scope pair, shared by the scope tactics' `keeping` clause); drop "progress" from `Temporal.lean`'s row, which now holds future/past scopes, eventuality composition and advance, the integer-time gate, Until/Since mapping and monotonicity, and whole-judgment time reflection; and restate `Discrete.lean`'s row as Next/Previous scopes, invariance and `linduction`, with the ZTime certificate reused-or-decided rather than always explicit.
- [ ] Guarded scoped build, diagnostic-free rather than merely exit 0 (CI builds with `--wfail`): `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Theorems.ProofMode.TemporalComposition.TemporalZTime FormalSystem.Automation.ProofMode.TemporalZTime FormalSystem.Automation.ProofMode`.
- [ ] Build the enumerated test dependents: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest.Automation.ProofModeTemporalZTimeTest BimodalTest.Automation.ProofModeTest`.
- [ ] Regenerate the inventory surface and confirm: `bash scripts/check-module-invariants.sh --emit-inventory`, then `bash scripts/check-module-invariants.sh --emit-inventory --check`. Stage whatever it rewrote, checking `git status --short` and recording any file beyond those declared below.
- [ ] Regenerate the commit-blocking surface: `bash scripts/typst-sync-check.sh --counts-only`; on drift run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ`. If `--fix` reports an unbuilt library, run the unscoped guarded build and retry. If `--counts-only` reports no drift, the rename moved no line count — record that rather than forcing a regeneration.

**Timing**: 90 minutes

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Tier Justification**: The edit renames identifiers whose call sites span the two Lean files
below, so the cheapest covering check is the guarded scoped build of both modules plus their
enumerated direct dependents (the `FormalSystem.Automation.ProofMode` aggregator and the two
pinning test modules) together with `bash scripts/check-module-invariants.sh --emit-inventory
--check` and `bash scripts/typst-sync-check.sh --counts-only` — the unmappable-criterion case
recorded under `## Decisions`, where the authoring-time selector measurement is stated: no shell
suite reaches Lean elaboration, so the repository's own gates are the covering check.

**Scope Hypothesis**: 29 occurrences of the eight old names in the Theorems file and 26 in the
automation file (55 total), against 46 occurrences of `untilFold`/`sinceFold` and their
`*Anchored` siblings under `FormalSystem/Metalogic/Expressiveness/Kamp/` that must remain
untouched; all ten proposed new identifiers currently unused tree-wide; and the three README
description cells in the state quoted in the task list. These figures are carried from
`reports/01_temporal-rules-followups.md` and were re-derived at plan authoring time by
word-boundary grep and by reading the README block live. Deliberately excluded: every Kamp
occurrence, and the user-facing `contract`/`expand` keyword strings, neither of which any task in
this phase touches. Confirm by re-running the counts in the first task before editing; if a count
has moved, record the new figure and proceed from it rather than from this hypothesis.

**Files to modify**:
- `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean` - eight `def`s renamed in both namespaces, internal uses repointed, headings and docstrings reworded
- `FormalSystem/Automation/ProofMode/TemporalZTime.lean` - two `private def`s and four `syntax` node names renamed, four rule keys and their quoted qualified names moved in lockstep, unreachable-arm note added
- `FormalSystem/Automation/ProofMode/README.md` - three hand-written description cells corrected; regenerated `Lines` column
- `FormalSystem/Theorems/ProofMode/TemporalComposition/README.md` - regenerated `Lines` column
- `README.md` - regenerated `dir=FormalSystem rows=totals` block (coupled, non-blocking INV surface)
- `typst/generated/status.typ` - regenerated counts (coupled, commit-blocking surface)

**Verification**:
- `grep -rnwE 'untilFoldRule|sinceFoldRule|untilUnfoldRule|sinceUnfoldRule|untilFold|sinceFold|untilUnfoldCases|sinceUnfoldCases|binaryFold|binaryUnfold|luntilFold|luntilUnfold|lsinceFold|lsinceUnfold' FormalSystem/Automation/ProofMode/ FormalSystem/Theorems/ProofMode/` returns nothing.
- Each of the ten new exact names (`untilContractRule`, `sinceContractRule`, `untilExpandRule`, `sinceExpandRule`, `untilContract`, `sinceContract`, `untilExpandCases`, `sinceExpandCases`, `binaryContract`, `binaryExpand`) is found by a word-boundary grep in the expected file, and `luntilContract`, `luntilExpand`, `lsinceContract`, `lsinceExpand` in the automation module.
- `grep -rcwE 'untilFold|sinceFold|untilFoldAnchored|sinceFoldAnchored' FormalSystem/Metalogic/Expressiveness/Kamp/` still totals 46 across the same three files — the Kamp construction is unchanged.
- The guarded scoped build of the two modules, the aggregator and the two test modules exits 0 with no diagnostics.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- The three README rows read as described, and the `TemporalZTime.lean` row is unchanged.

---

### Phase 2: Instance-Synthesis Ordering and Its Doc-Comment Contract [COMPLETED WITH EXCLUSIONS]

**Goal**: `applyDerivationProof` synthesises instance arguments only after the conclusion has been
unified against the goal, a positive regression test fails against the pre-fix ordering, the doc
comment states the `firstNewIndex` ordering requirement, and the "incompatible judgment" message
is pinned.

**Tasks**:
- [ ] Re-read `FormalSystem/Automation/ProofMode/Basic.lean` immediately before editing.
- [ ] Move the instance-synthesis loop (`for i in [:parameters.size] do … isInstImplicit …`, currently L79-85) so it sits immediately AFTER the `unless ← isDefEq (← inferType proof) (← goal.getType) do throwError "the applied rule produced an incompatible judgment"` block and BEFORE `goal.assign proof`. Keep the `message` diagnostic and the `Term.synthesizeInstMVarCore` call verbatim.
- [ ] Extend `applyDerivationProof`'s doc comment to state the ordering requirement: `firstNewIndex` MUST be snapshotted from `(← getMCtx).mvarCounter` BEFORE the proof term is elaborated, because the filter at the goal-partitioning loop drops every metavariable whose index is below it — a counter read after elaboration filters out the rule's own parameter metavariables, so they never become goals and the surrounding by-block fails later with an opaque placeholder-synthesis error. Name `applyProof` as the in-tree caller that reads it in the required order.
- [ ] Add the positive regression test to `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean`, beside the existing `ReviewInstance` pin: a class parameterised by the rule's `FrameClass` (the one parameter a rule's conclusion type always mentions and the implication-chain loop never assigns), an instance for `FrameClass.ZTime`, a rule carrying it as an instance-implicit binder, and an `example` closing a `⊢[FrameClass.ZTime]` goal through `lapply`. Write it as a positive example, never a `#guard_msgs` pin: the pre-fix message embeds `?m.3`.
- [ ] Record, in a comment on that test, that it fails against the pre-fix ordering with "lapply could not synthesize the required instance", so a future reader knows what it guards.
- [x] Add a `#guard_msgs` pin for `Basic.lean`'s other added `throwError`, "the applied rule produced an incompatible judgment" — the one reachable-unpinned site in this module. If no trigger can be constructed from user syntax, record the reason in-source at the arm instead and name it in the completion notes. *(deviation: altered — no trigger constructible from user syntax; recorded in-source at the arm in `Basic.lean` and in `ProofModeTemporalTest.lean`, per the task's own fallback clause. See `#### Reasoned Exclusions` below.)*
- [ ] Confirm the existing parameterless `ReviewInstance` pin still matches byte-for-byte after the move.
- [ ] Guarded scoped build of `FormalSystem.Automation.ProofMode.Basic`, the `FormalSystem.Automation.ProofMode` aggregator and `BimodalTest.Automation.ProofModeTemporalTest`, diagnostic-free.
- [ ] Regenerate the inventory surface (`--emit-inventory`, then `--emit-inventory --check`) and the commit-blocking surface (`--counts-only`, then `--fix` on drift), staging what each rewrote.

**Timing**: 75 minutes

**Depends on**: 1

**Verification Tier**: full

**Tier Justification**: `applyDerivationProof` is the shared application elaborator behind every
`lapply` in the tree and the reorder changes which of two errors surfaces first on any failing
application, a cross-cutting elaboration surface no single-module or one-hop dependent build
covers; the in-dispatch discharge is the unscoped guarded `lake build` plus `lake test` — the
unmappable-criterion case recorded under `## Decisions`, since no shell suite reaches Lean
elaboration behaviour.

**Scope Hypothesis**: one instance-synthesis loop at `Basic.lean:79-85`, one doc comment at
`Basic.lean:57-59`, one conclusion-unification anchor at `Basic.lean:93-94`, and exactly one
reachable-unpinned added `throwError` in this module. Carried from
`reports/01_temporal-rules-followups.md` and re-derived at plan authoring time by reading
`Basic.lean:50-120` live and by classifying the module's two added `throwError` lines against the
test tree. Confirm by re-reading the function before editing; if the loop has moved, locate it by
its `isInstImplicit` guard rather than by line number.

**Files to modify**:
- `FormalSystem/Automation/ProofMode/Basic.lean` - instance loop relocated after the conclusion unification; doc comment states the `firstNewIndex` ordering requirement
- `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean` - `FrameClass`-parameterised instance regression example; `#guard_msgs` pin for the incompatible-judgment message
- `FormalSystem/Automation/ProofMode/README.md` - regenerated `Lines` column
- `README.md` - regenerated `dir=FormalSystem rows=totals` block
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `#guard_msgs` pin for `Basic.lean`'s "the applied rule produced an incompatible judgment" | No trigger is constructible from user syntax. The arm is a defensive invariant check: once the implication chain has matched the conclusion against `judgment.formula` and `adaptProof` has aligned frame class, object language and context, the proof's type and the goal's type agree by construction. Recorded in-source at the arm and in the test module instead. | The nearest candidate trigger -- a rule `⊢[FrameClass.ZTime] φ.imp φ` applied at goal `⊢[FrameClass.Base] A.imp A`, whose conclusion formula matches but whose frame class does not -- is rejected one step earlier by `adaptProof`. Measured build output: `error: ... different frame classes; supply an explicitly lifted derivation`, against a `#guard_msgs` docstring pinning the incompatible-judgment text. |

#### Completion Notes

- Positive regression example added at `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean`
  (`FrameTag` / `requiresFrameTag`). Verified by hand that it FAILS against the pre-fix ordering:
  reinstating the loop before `adaptProof` and rebuilding the module yields
  `lapply could not synthesize the required instance FrameTag ?fc`. The file was restored
  byte-identically afterwards (`diff -q` against a saved copy).
- The measured pre-fix message names `?fc`, not `?m.N` as the plan's Research Integration section
  anticipated. Either way it names an unassigned metavariable, so the plan's decision to write a
  positive example rather than a message pin stands; the in-source comment records the measured
  text. `grep -rn '?m\.' Tests/BimodalTest/Automation/` now returns nothing.
- Batch-gate deferral: this phase's declared `full` tier was discharged by running its own named
  checks directly -- unscoped guarded `lake build` (3027 jobs, exit 0, zero `error:`/`warning:`)
  and guarded `lake test` (3109 jobs, exit 0, zero error lines). The complete repository gate set
  (`verify-all.sh` / `verify-deploy.sh`) was NOT independently run here; it is deferred to the
  batch stage at the close of this `/orchestrate` invocation, per the dispatch's Batch Gate
  Deferral directive.

**Verification**:
- The new positive example compiles; reverting the loop to its pre-fix position makes it fail with "could not synthesize the required instance" (check this once, by hand, and restore).
- The existing `ReviewInstance` `#guard_msgs` block still matches.
- No pinned message anywhere in the test tree contains `?m.`.
- `applyDerivationProof`'s doc comment names the before-elaboration requirement and `applyProof`.
- Unscoped guarded `lake build` and `lake test` both green, with no diagnostics.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only` both exit 0.

---

### Phase 3: Narrow the integerTimeGate Catch and Pin Its Siblings [COMPLETED]

**Goal**: `integerTimeGate` rethrows the frame-class message only for the frame-class failure and
appends the original message otherwise, both existing pins still match, and the gate's sibling
`throwError` is pinned.

**Tasks**:
- [x] Re-read `FormalSystem/Automation/ProofMode/Temporal.lean` around `integerTimeGate` immediately before editing.
- [x] Replace the bare `catch _ =>` with the narrowed form: bind the error, take `(← error.toMessageData.toString)`, and branch on `(original.splitOn "incompatible concrete frame classes").length > 1` — rethrow `"integer-time reasoning requires FrameClass.ZTime ≤ {judgment.frame}"` alone on a match, and that message followed by a newline and the original on anything else.
- [x] Do NOT use `String.containsSubstr`: it is outside this module's import closure (measured) and would need a new Batteries import. `splitOn` compiles as-is.
- [x] Add a `#guard_msgs` pin to `Tests/BimodalTest/Automation/ProofModeTemporalZTimeTest.lean` for the gate's sibling added `throwError`, "the frame class of the goal is undetermined", reached by invoking a ZTime-gated tactic on a goal whose frame class is a metavariable. *(deviation: altered — the pin carries a second `---` message, the `case frame` unsolved-goals report, because leaving the pair's frame component open is exactly what keeps the frame class a metavariable; assigning it would silence the guard under test)*
- [x] If a non-frame-class failure can be triggered through the gate (a `Decidable`-synthesis failure or similar), add a second pin showing the appended original message. If no such trigger can be constructed, record that in-source at the catch and in the completion notes, rather than leaving the pass-through branch silently untested.
- [x] Confirm the two existing pins — `ProofModeCarryingTest.lean`'s and `ProofModeTemporalZTimeTest.lean`'s `integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense` — still match byte-for-byte, and that the admissible `FrameClass.ZTime` case still resolves the gate.
- [x] Guarded scoped build of `FormalSystem.Automation.ProofMode.Temporal` plus its enumerated direct dependents `FormalSystem.Automation.ProofMode.Discrete` and `FormalSystem.Automation.ProofMode.TemporalZTime` (both call `integerTimeGate`), then of the two pinning test modules `BimodalTest.Automation.ProofModeTemporalZTimeTest` and `BimodalTest.Automation.ProofModeCarryingTest`.
- [x] Regenerate the inventory surface and the commit-blocking surface as in Phase 1, staging what each rewrote.

**Timing**: 60 minutes

**Depends on**: 2

**Verification Tier**: interface

**Tier Justification**: `integerTimeGate`'s failure message is consumed by two other automation
modules and pinned in two test modules, so the cheapest covering check is the guarded scoped
build of `Temporal.lean` plus those enumerated direct dependents and the two pinning test modules
— the unmappable-criterion case recorded under `## Decisions`, since no shell suite applies to
Lean content and the repository's own build is the honest check.

**Scope Hypothesis**: `resolveRuleParameters` can raise exactly three things for this gate's
single `#[gate]` parameter — the undetermined-parameters message (unreachable here, because the
gate already rejects an undetermined frame class one line earlier), the "incompatible concrete
frame classes" frame-class failure, and the rethrown original from the `mkDecide`/`whnf` catch —
and exactly one sibling added `throwError` in this function is unpinned. Carried from
`reports/01_temporal-rules-followups.md`, whose narrowing was verified there by compiled probe
with the pin matching; re-derived here by reading `integerTimeGate` live and by classifying the
module's added `throwError` lines against the test tree. Deliberately excluded: the other seven
reachable-unpinned `Temporal.lean` sites, which Phase 6 owns and which no task here touches.
Confirm by reading `resolveRuleParameters` before editing.

**Files to modify**:
- `FormalSystem/Automation/ProofMode/Temporal.lean` - narrowed catch preserving the pinned text and surfacing the original cause
- `Tests/BimodalTest/Automation/ProofModeTemporalZTimeTest.lean` - pin for the undetermined-frame-class message, and the pass-through pin if constructible
- `FormalSystem/Automation/ProofMode/README.md` - regenerated `Lines` column
- `README.md` - regenerated `dir=FormalSystem rows=totals` block
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

**Verification**:
- Both existing `integer-time reasoning requires FrameClass.ZTime ≤ FrameClass.Dense` pins match unchanged.
- The new undetermined-frame-class pin matches.
- The admissible `FrameClass.ZTime` path still discharges the gate (an existing ZTime example still compiles).
- `grep -n 'containsSubstr' FormalSystem/Automation/ProofMode/Temporal.lean` returns nothing.
- The guarded scoped build of the module, its two dependents and the two test modules exits 0 with no diagnostics.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only` both exit 0.

#### Completion Notes

- The append (pass-through) branch is **not pinned, by construction**: no trigger for it is
  reachable from user syntax. The undetermined-frame-class guard one line above closes the gate
  type before `resolveRuleParameters` sees it; `FrameClass` has exactly four constructors and
  `Decidable (FrameClass.ZTime ≤ ·)` synthesizes at all four (verified by compiled probe:
  `infer_instance` succeeds for `Base`, `Dense`, `ZTime`, `RTime`), so `mkDecide`/`whnf` cannot
  fail here; and a `maxRecDepth` or interrupt is not constructible in a test. Recorded in-source
  at the catch, per this phase's own task list.
- The frame-class match target is `"incompatible concrete frame classes"`, a prefix of
  `resolveRuleParameters`' actual `"incompatible concrete frame classes in rewrite rule"`
  (`Rewriting.lean:327`) — re-read live, confirming this phase's Scope Hypothesis.
- **Batch gate deferral**: the full gate set was NOT independently run for this phase. The
  `interface` tier was discharged by the guarded scoped build of `Temporal.lean`, its two
  enumerated dependents (`Discrete`, `TemporalZTime`) and the two pinning test modules
  (`ProofModeTemporalZTimeTest`, `ProofModeCarryingTest`): exit 0, 746 jobs, zero `error:` and
  zero `warning:` lines. A full guarded `lake build` also ran green (exit 0, 3027 jobs, zero
  `error:`/`warning:`) as the phase-end full-build gate. `check-module-invariants.sh
  --emit-inventory --check` and `typst-sync-check.sh --counts-only` both exit 0 after
  regeneration. The complete gate set is deferred to the batch stage at the end of this
  /orchestrate invocation.


---

### Phase 4: lprogress Coverage Matrix [COMPLETED]

**Goal**: All four `lprogress` forms are exercised in the future and past directions at both TM
and TM⁺, filling the 14 empty cells without duplicating the two already covered.

**Tasks**:
- [x] Re-read `Tests/BimodalTest/Automation/ProofModeTemporalBooleanProgressTest.lean` and `Tests/BimodalTest/Automation/ProofModeTest.lean:102` immediately before editing, and confirm the two covered cells are still the `using [...]` future-TM and `cases` future-TM ones.
- [x] Add the past-TM cells for all four forms (`using [h₁, h₂]`, `cases`, `consequence using h`, `trans using h`), driving them through the existing `pastLeadsToTrans`, `pastProgressTrans`, `pastProgressConsequence` and past `progressCases` mirrors in `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalBoolean.lean` and `FormalSystem/Theorems/ProofMode/Temporal.lean`. No new pure rule is needed — every rule the empty cells require already exists.
- [x] Add the future-TM cells for `consequence using` and `trans using`.
- [x] Add all four TM⁺ future cells and all four TM⁺ past cells, writing the goals in the `PlusDerivationTree fc [...] …` shape `ProofModeCarryingTest.lean` already uses, so the `FormalSystem.PlusLanguage.ProofMode` mirrors are the rules actually exercised.
- [x] Do NOT re-add a `lprogress using [...]` future-TM example or a `lprogress cases` future-TM example; both already exist.
- [x] Guarded scoped build of `BimodalTest.Automation.ProofModeTemporalBooleanProgressTest`, diagnostic-free.
- [x] Run `bash scripts/typst-sync-check.sh --counts-only` and, on drift, `--fix` plus a stage of `typst/generated/status.typ` — the added test lines move `tests-line-count`, and the hook blocks any commit staging a `.lean` path while that surface has drifted.

**Timing**: 90 minutes

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: The edit adds examples to one test module and changes no library code or
signature, so the guarded scoped build of
`BimodalTest.Automation.ProofModeTemporalBooleanProgressTest` (a module with no dependents) plus
`bash scripts/typst-sync-check.sh --counts-only` for the one commit-blocking surface the added
lines move is the cheapest check covering the whole edit — the unmappable-criterion case recorded
under `## Decisions`, since no shell suite covers Lean test content.

**Scope Hypothesis**: 14 of the 16 cells in the four-form × {future TM, past TM, future TM⁺, past
TM⁺} matrix are empty, with `ProofModeTest.lean:102` and
`ProofModeTemporalBooleanProgressTest.lean:21` holding the only two filled ones, and every rule
the empty cells need already exists in-tree. Carried from
`reports/01_temporal-rules-followups.md` and re-derived at plan authoring time by grepping every
`lprogress` call site outside the declaring module (exactly two) and reading the four `syntax`
declarations live. Deliberately excluded: any new pure rule in `FormalSystem/Theorems/`, and any
new test module — no task here adds either. Confirm by re-running the call-site grep before
editing; if a third call site has appeared, do not duplicate its cell.

**Files to modify**:
- `Tests/BimodalTest/Automation/ProofModeTemporalBooleanProgressTest.lean` - 14 new examples covering the empty cells
- `typst/generated/status.typ` - regenerated `tests-line-count` (commit-blocking surface)

**Verification**:
- The guarded scoped build of the test module exits 0 with no diagnostics.
- Each of the four forms appears at least once in each of the four direction/language combinations, and the two pre-existing cells are unduplicated.
- `grep -c 'lprogress' Tests/BimodalTest/Automation/ProofModeTemporalBooleanProgressTest.lean` reports 15 (the original `cases` example plus 14 new).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

#### Completion Notes

- Call-site grep re-run before editing: exactly two pre-existing sites,
  `ProofModeTest.lean:102` (`using [·, ·]`, future TM) and
  `ProofModeTemporalBooleanProgressTest.lean:21` (`cases`, future TM). No third site had
  appeared, so the Scope Hypothesis's 14 empty cells stand.
- The module was rewritten around the matrix, with a `/-! ## Direction, Language -/` section per
  quadrant. The future-TM `using [·, ·]` cell is left to `ProofModeTest.lean` and is NOT
  duplicated here; the pre-existing future-TM `cases` example is retained verbatim. All 16 cells
  are therefore covered across the two files, with 15 `lprogress` lines in this module.
- `variable` gained `D : Formula` and `P Q R S : PlusFormula`, and the module now opens
  `FormalSystem.PlusLanguage` — the `consequence using` cells need four distinct formulas
  (source-strengthening and target-weakening premises are separate), and the TM⁺ quadrants need
  `PlusDerivationTree`.
- No new pure rule was needed, as the plan predicted: every cell routes through an existing
  `FormalSystem.Theorems.ProofMode` declaration or its `FormalSystem.PlusLanguage.ProofMode`
  mirror, selected by `judgment.language.ruleName`.
- **Batch gate deferral**: the full gate set was NOT independently run for this phase. The
  `local` tier was discharged by the guarded scoped build of
  `BimodalTest.Automation.ProofModeTemporalBooleanProgressTest` (exit 0, 745 jobs, zero `error:`
  and zero `warning:`, `.olean` freshly rewritten) plus `typst-sync-check.sh --counts-only`
  (exit 0 after `--fix` moved `tests-line-count` 32126 → 32242). A full guarded `lake build`
  also ran green (exit 0, 3027 jobs, zero `error:`/`warning:`) as the phase-end full-build gate,
  and `check-module-invariants.sh --emit-inventory --check` exits 0. The complete gate set is
  deferred to the batch stage at the end of this /orchestrate invocation.


---

### Phase 5: Negative Tests for TemporalBoolean's Eight Reachable throwError Paths [COMPLETED]

**Goal**: Each of the eight reachable-unpinned `throwError` paths the contribution added to
`TemporalBoolean.lean` carries a `#guard_msgs` test, and its one unreachable arm carries an
in-source note.

**Tasks**:
- [x] Re-read `FormalSystem/Automation/ProofMode/TemporalBoolean.lean` and the progress test module immediately before editing.
- [x] Add a `#guard_msgs` test for each of these eight messages, in the progress test module: "lprogress requires exactly two progress guarantees"; "lprogress expected a future- or past-scoped progress goal"; "expected a leads-to statement G(φ → Fψ), φ → Fψ, or a past mirror"; "lprogress cases expects a persistent G/H leads-to goal"; "lprogress cases expects a disjunctive source"; "the supplied guarantee has a different leads-to form than the goal"; "the supplied first step has a different leads-to form than the goal"; "the supplied first step has a different source than the goal".
- [x] Add a one-line note at the `| _ => throwError "unregistered strict leads-to rule {rule}"` arm recording that it is unreachable from parsed syntax because `rule` is elaborator-supplied.
- [x] For any of the eight that proves not to be triggerable from user syntax, record the reason in-source at the arm and name it in the completion notes rather than leaving a silent gap.
- [x] Guarded scoped build of `FormalSystem.Automation.ProofMode.TemporalBoolean` and `BimodalTest.Automation.ProofModeTemporalBooleanProgressTest`, diagnostic-free.
- [x] Regenerate the inventory surface (the added comment moves `TemporalBoolean.lean`'s `Lines` value) and the commit-blocking surface, staging what each rewrote.

**Timing**: 75 minutes

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: The only library edit is a one-line comment with no elaboration surface,
so the guarded scoped build of `FormalSystem.Automation.ProofMode.TemporalBoolean` and its one
test module, plus `bash scripts/check-module-invariants.sh --emit-inventory --check` and
`bash scripts/typst-sync-check.sh --counts-only` for the two generated surfaces the added lines
move, is the cheapest check covering the edit — the unmappable-criterion case recorded under
`## Decisions`, since no shell suite covers either Lean path.

**Scope Hypothesis**: nine `throwError` lines were added to this module, eight reachable and
unpinned and one an elaborator-internal `unregistered strict leads-to rule` guard. Re-derived at
plan authoring time, correcting the research report's own per-site enumeration: the per-file added
count comes from `git diff a7be7db65^..a7be7db65` filtered to added `throwError` lines, and the
pinned/unpinned split from grepping each exact message text against `Tests/`. Deliberately
excluded: `Temporal.lean`'s sites, which phases 3 and 6 own, and which no task here touches.
Confirm by re-running the per-file diff count before writing the tests; if it is not nine, work
from the measured list.

**Files to modify**:
- `Tests/BimodalTest/Automation/ProofModeTemporalBooleanProgressTest.lean` - eight `#guard_msgs` negative tests
- `FormalSystem/Automation/ProofMode/TemporalBoolean.lean` - unreachable-arm note
- `FormalSystem/Automation/ProofMode/README.md` - regenerated `Lines` column
- `README.md` - regenerated `dir=FormalSystem rows=totals` block
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

**Verification**:
- Eight `#guard_msgs` blocks pin the eight messages above, or any that could not be triggered is recorded in-source with its reason and named in the completion notes.
- No new pin contains `?m.`.
- The guarded scoped build of the module and its test module exits 0 with no diagnostics.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only` both exit 0.

#### Completion Notes

- Scope Hypothesis confirmed by re-running the measurement:
  `git diff a7be7db65^..a7be7db65 -- FormalSystem/Automation/ProofMode/TemporalBoolean.lean`
  yields exactly **9** added `throwError` lines, and the module carries exactly those 9 sites
  today (lines 34, 40, 53, 78, 93, 95, 110, 131, 133).
- **All eight reachable sites are pinned** — none proved untriggerable, so no reachable site
  needed an in-source reason. The triggers, in module order: `using [hAB]` (wrong arity);
  `using [hA, hA]` on a bare atom goal (neither `G`- nor `H`-headed); `cases` on a bare atom goal
  (no leads-to shape); `cases` on the current-form `(A ∨ B) → F C` (non-persistent);
  `cases` on `G(A → F C)` (non-disjunctive source); `consequence using` a current-form
  guarantee against a persistent goal; `trans using` the same; and `trans using` a same-form step
  whose source differs. Every pin matched on the first compiled attempt.
- The one unreachable arm, `| _ => throwError "unregistered strict leads-to rule {rule}"`, now
  carries a three-line in-source note: `rule` is elaborator-supplied, never user-supplied, and
  every value this module's elaborators pass is matched above.
- No pin contains `?m.`.
- **Batch gate deferral**: the full gate set was NOT independently run for this phase. The
  `local` tier was discharged by the guarded scoped build of
  `FormalSystem.Automation.ProofMode.TemporalBoolean` and
  `BimodalTest.Automation.ProofModeTemporalBooleanProgressTest` (exit 0, 745 jobs, zero `error:`
  and zero `warning:`), plus `check-module-invariants.sh --emit-inventory --check` (exit 0 after
  `--emit-inventory`) and `typst-sync-check.sh --counts-only` (exit 0 after `--fix`). A full
  guarded `lake build` also ran green (exit 0, 3027 jobs, zero `error:`/`warning:`) as the
  phase-end full-build gate. The complete gate set is deferred to the batch stage at the end of
  this /orchestrate invocation.


---

### Phase 6: Negative Tests for Temporal.lean's Remaining Seven Paths [COMPLETED]

**Goal**: Each of the seven reachable-unpinned `throwError` paths the contribution added to
`Temporal.lean` outside the integer-time gate carries a `#guard_msgs` test, and its three
unreachable arms carry in-source notes.

**Tasks**:
- [x] Re-read `FormalSystem/Automation/ProofMode/Temporal.lean` and `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean` immediately before editing.
- [x] Add a `#guard_msgs` test for each of these seven messages, in the temporal test module: "expected an event name and {n} scoped assumption names …" (fix the context length explicitly so the interpolated count is stable); "{what} expects a Since formula" / "an Until formula" (one test per branch if both are reachable, otherwise one with the reason recorded for the other); "missing reflected formula view {target}"; "reflected view does not match the native reflection rule"; "reflected fact has unresolved parameters; supply its arguments explicitly"; "different object languages; supply an explicit derivation embedding"; "the reflected derivation does not prove the current conclusion".
- [x] Add one-line unreachability notes at the three remaining arms: `| _ => throwError "unregistered temporal composition rule {rule}"` (elaborator-supplied `rule`), `` | _ => throwError "expected `guard` or `event`" `` and `` | _ => throwError "expected `future` or `past`" `` (fallback arms of `&"guard"`/`&"event"` and `&"future"`/`&"past"` keyword matches the parser already rejects anything else for). *(deviation: altered — only ONE of the three, `unregistered temporal composition rule`, is actually unreachable; see the measured premise correction in the completion notes below)*
- [x] For any of the seven that proves not to be triggerable from user syntax, record the reason in-source and name it in the completion notes.
- [x] Guarded scoped build of `FormalSystem.Automation.ProofMode.Temporal`, its two dependents `Discrete` and `TemporalZTime`, and `BimodalTest.Automation.ProofModeTemporalTest`, diagnostic-free.
- [x] Regenerate the inventory and commit-blocking surfaces, staging what each rewrote.

**Timing**: 75 minutes

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: The library edits are three one-line comments with no elaboration
surface, so the guarded scoped build of `FormalSystem.Automation.ProofMode.Temporal` and
`BimodalTest.Automation.ProofModeTemporalTest`, plus `bash scripts/check-module-invariants.sh
--emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only`, is the cheapest
check covering the edit — the unmappable-criterion case recorded under `## Decisions`.

**Scope Hypothesis**: thirteen `throwError` lines were added to this module — two already pinned
(the integer-time message and "ltime_reflect using expects a native derivation"), one pinned in
Phase 3 (the undetermined frame class), three structurally unreachable, and seven reachable and
unpinned, which this phase owns. Re-derived at plan authoring time from the per-file added-line
diff and an exact-message grep against `Tests/`, correcting the research report's enumeration,
which mixed pre-existing sites into its reachable list. Deliberately excluded: the integer-time
gate's own catch and its sibling pin, both of which Phase 3 owns and no task here edits. Confirm
by re-running the per-file diff count before writing the tests.

**Files to modify**:
- `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean` - seven `#guard_msgs` negative tests
- `FormalSystem/Automation/ProofMode/Temporal.lean` - three unreachable-arm notes
- `FormalSystem/Automation/ProofMode/README.md` - regenerated `Lines` column
- `README.md` - regenerated `dir=FormalSystem rows=totals` block
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)

**Verification**:
- Seven `#guard_msgs` blocks pin the seven messages above, or any untriggerable one is recorded in-source with its reason and named in the completion notes.
- The three unreachable arms each carry a note naming why no test is constructible.
- No new pin contains `?m.`, and the interpolated-count message's test fixes its context length explicitly.
- The guarded scoped build of the module, its dependents and the test module exits 0 with no diagnostics.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only` both exit 0.

#### Completion Notes

- Scope Hypothesis confirmed by re-running the measurement:
  `git diff a7be7db65^..a7be7db65 -- FormalSystem/Automation/ProofMode/Temporal.lean` yields
  exactly **13** added `throwError` lines, and all 13 messages are present in the module today.
- **PREMISE CORRECTION, measured, in BOTH directions.** The plan's reachable/unreachable split
  was wrong on four of the thirteen sites, and the correction was made by compiled probe rather
  than by reading:
  - `expected \`guard\` or \`event\`` and `expected \`future\` or \`past\`` were classed
    unreachable on the premise that they are fallback arms of `&"guard"`/`&"event"` and
    `&"future"`/`&"past"` keyword parsers. They are not: `luntil`/`lsince` and
    `ltemporal_intro` declare that position as `ppSpace colGt ident`, so the parser admits ANY
    identifier and both arms are reachable. `luntil banana using hMap` and
    `ltemporal_intro sideways keeping [h]` reach them. Both are now **pinned**, which serves this
    record's own DONE WHEN criterion ("every `throwError` path the contribution added has a
    `#guard_msgs` test") better than the false note the plan asked for would have.
  - `missing reflected formula view {target}` and
    `reflected view does not match the native reflection rule` were listed among the seven
    reachable. Both are structurally unreachable and now carry in-source notes, under the
    phase's own "record the reason in-source" clause. For the first: every one of `viewPairs`'
    eight targets is registered by `register_lview` for BOTH `Formula` and `PlusFormula`
    (enumerated from the `register_lview` call sites), so `viewHead?` cannot return `none` for a
    pair whose source just matched. For the second: probed across the three structurally
    distinct reflection classes — a registered view (`inclusiveUntil`), a second view family
    (`weakUntil`), and a registered-but-unmirrored head falling through to the `reflectTime` wrap
    (`before`) — and all three reflected defeq, so the syntactic mirror never disagrees with
    the native rule.
- Net result: **eight** `#guard_msgs` pins in `ProofModeTemporalTest.lean` (the plan's seven
  minus the two found unreachable, with `{what} expects a Since/an Until formula` pinned in both
  branches, plus the two found reachable), and **three** in-source unreachability notes
  (`unregistered temporal composition rule`, plus the two above).
- The interpolated-count message's test fixes the guarantee count at one via its context, so
  `expected an event name and 1 scoped assumption names (using, then keeping)` is stable.
- No pin contains `?m.`.
- A nearby pre-existing pin, `selected guarantee must have the matching G scope`, comes from
  `Modal.lean:90`'s `operatorSymbol`-interpolated message, NOT from `Temporal.lean:158`'s
  `selected guarantee must have the matching universal time scope`. Checked so that
  `Temporal.lean:158` was not mistaken for already-pinned; it is a pre-existing site this record
  does not own.
- **Batch gate deferral**: the full gate set was NOT independently run for this phase. The
  `local` tier was discharged by the guarded scoped build of
  `FormalSystem.Automation.ProofMode.Temporal`, its two dependents `Discrete` and
  `TemporalZTime`, and `BimodalTest.Automation.ProofModeTemporalTest` (exit 0, zero `error:` and
  zero `warning:`), plus `check-module-invariants.sh --emit-inventory --check` (exit 0) and
  `typst-sync-check.sh --counts-only` (exit 0 after `--fix`). A full guarded `lake build` also
  ran green (exit 0, 3027 jobs, zero `error:`/`warning:`) as the phase-end full-build gate. The
  complete gate set is deferred to the batch stage at the end of this /orchestrate invocation.


---

### Phase 7: Negative Tests for the Modal, Meta, Carrying and Discrete Paths [COMPLETED WITH EXCLUSIONS]

**Goal**: Each of the nine remaining reachable-unpinned `throwError` paths — three in
`Modal.lean`, one in `Meta.lean`, three in `Carrying.lean`, two in `Discrete.lean` — carries a
`#guard_msgs` test, completing item (2)'s coverage.

**Tasks**:
- [x] Re-read the three test modules below immediately before editing.
- [x] `Modal.lean`, in `Tests/BimodalTest/Automation/ProofModeTest.lean`: pin "expected a native derivation", "the goal does not have the requested universal modality", and "expected {n} body hypothesis names in the supplied guarantee order" (fixing the example's context length explicitly, since the message interpolates `formulas.size`). *(deviation: altered — the first of the three, "expected a native derivation", is unreachable and is recorded instead; the other two are pinned)*
- [ ] `Meta.lean`, in the same module: pin its one added "expected a native derivation". Note in a comment that the text coincides with `Modal.lean`'s and that the two tests exercise different tactics, so neither is redundant. *(deviation: skipped — `Meta.lean`'s site is unreachable; recorded with its measured reason instead of pinned, so there is no second test for the comment to distinguish)*
- [x] `Carrying.lean`, in `Tests/BimodalTest/Automation/ProofModeCarryingTest.lean`: pin "`keeping` needs a determined formula; supply its arguments explicitly", "no carrying rule enters the {target} scope", and "carrying {source} facts into the {target} scope …". The module's fourth added `throwError`, "`keeping` carries only …", is already pinned in three variants and needs no new test. *(deviation: altered — only the first of the three, "`keeping` needs a determined formula", is reachable and pinned; the other two are unreachable and recorded)*
- [x] `Discrete.lean`, in `Tests/BimodalTest/Automation/ProofModeTest.lean`: pin "induction requires the matching universal temporal goal" and "backward induction does not prove the current conclusion", both reached through `linduction`. *(deviation: altered — only the first is reachable; the second is unreachable and recorded)*
- [x] For any site that proves not to be triggerable from user syntax, record the reason in-source and name it in the completion notes.
- [x] Guarded scoped build of `BimodalTest.Automation.ProofModeTest` and `BimodalTest.Automation.ProofModeCarryingTest`, diagnostic-free.
- [x] Run `bash scripts/typst-sync-check.sh --counts-only` and, on drift, `--fix` plus a stage of `typst/generated/status.typ`.

**Timing**: 75 minutes

**Depends on**: 6

**Verification Tier**: local

**Tier Justification**: The edit is confined to test modules with no library change and no
dependents, so the guarded scoped build of the two test modules plus
`bash scripts/typst-sync-check.sh --counts-only` for the one commit-blocking surface the added
lines move is the cheapest check covering it — the unmappable-criterion case recorded under
`## Decisions`.

**Scope Hypothesis**: nine reachable-unpinned added `throwError` sites remain after phases 2, 3,
5 and 6 — Modal 3, Meta 1, Carrying 3, Discrete 2 — which closes item (2)'s arithmetic at 5
pinned + 5 unreachable + 26 reachable-unpinned = 36 added sites. Re-derived at plan authoring
time from the per-file added-line diff and an exact-message grep against `Tests/`. Deliberately
excluded: any library-source edit — this phase adds no in-source note, because all five
unreachable arms are claimed by phases 1, 5 and 6, and no task here edits a `FormalSystem/` file.
Confirm by re-running the exact-message grep for each of the nine before writing its test; a site
that has since been pinned by an earlier phase needs no second test.

**Files to modify**:
- `Tests/BimodalTest/Automation/ProofModeTest.lean` - six `#guard_msgs` negative tests (Modal, Meta, Discrete)
- `Tests/BimodalTest/Automation/ProofModeCarryingTest.lean` - three `#guard_msgs` negative tests
- `typst/generated/status.typ` - regenerated `tests-line-count` (commit-blocking surface)

**Verification**:
- Nine `#guard_msgs` blocks pin the nine messages above, or any untriggerable one is recorded in-source with its reason and named in the completion notes.
- Every one of the 36 added `throwError` sites is now either pinned, pre-pinned, or carries an in-source unreachability note — checked by walking the measured 36-site list, not by re-running the pattern that produced it.
- The guarded scoped build of the two test modules exits 0 with no diagnostics.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `Modal.lean`'s added "expected a native derivation" | Unreachable from user syntax: every proof reaching `scopedGuarantees`' guarantee loop has already passed `adaptProof`, whose own "expected a native derivation, not a semantic fact or a validity proof" fires first; the `using`-less path builds proofs with `assumptionProof`, which cannot yield a non-derivation. | Compiled probe: `lmodal_intro necessity using [True.intro]` on a `□`-headed goal reports adaptProof's message, not this one. |
| `Meta.lean`'s added "expected a native derivation" (`proofJudgment`) | Unreachable: all ten in-tree `proofJudgment` call sites pass either an `adaptProof` result or a term built by `mkAppM` from a checked rule. `TemporalZTime.lean:55`, the one site taking a user term, applies `adaptProof` first. | Call-site enumeration (`grep -rn proofJudgment FormalSystem/Automation/ProofMode/`) plus reading `binaryExpand`. |
| `Carrying.lean`'s "no carrying rule enters the {target} scope" | Unreachable: the arm fires only when NO `carryRules` row has the requested target. The three `carriedFacts` call sites pass `next`/`prev` (`Discrete.lean:51`) or `allFuture`/`allPast` (`Temporal.lean:155,207`), and all four are row targets. | Call-site enumeration plus the `carryRules` target set `{allFuture, next, allPast, prev}`. |
| `Carrying.lean`'s "carrying {source} facts into the {target} scope requires FrameClass.ZTime ≤ …" | Unreachable: fires only when a framed row matches with no certificate. The two framed rows target `next`/`prev`, reached only from `lstep`, which always passes `some frame`. | `carryRules` framed flags plus `Discrete.lean:51`'s `(some frame)` argument. |
| `Discrete.lean`'s "backward induction does not prove the current conclusion" | Unreachable: the rule is applied to the goal's own `args[0]`, context and frame, so its type agrees with the goal's by construction. | Compiled probe: `linduction past` on a `G`-headed goal reports "induction requires the matching universal temporal goal" one step earlier, not this message. |

Each exclusion's reason is recorded in the test module where its pin would have gone
(`ProofModeTest.lean` for Modal/Meta/Discrete, `ProofModeCarryingTest.lean` for Carrying),
under this phase's own "record the reason in-source" clause and inside its own declared file
list — the phase's Scope Hypothesis explicitly excludes any `FormalSystem/` edit, and the four
library modules are outside this record's declared `file_scope`. Siting the five notes in the
library source instead is a reasonable follow-up when territory allows.

#### Completion Notes

- Scope Hypothesis re-measured and confirmed on the arithmetic: per-file added `throwError`
  counts are Basic 2, Carrying 4, Discrete 2, Meta 1, Modal 4, Temporal 13, TemporalBoolean 9,
  TemporalZTime 1 = **36**.
- **PREMISE CORRECTION**: of the nine sites this phase inherited as reachable-unpinned, only
  **four** are reachable (pinned here), and **five** are unreachable (recorded above). The
  measurement was by compiled probe, not by reading. The record's item-(2) arithmetic therefore
  closes differently than the plan projected: 36 added sites = **5 pre-pinned** + **21 pinned by
  this record** (Phase 3: 1, Phase 5: 8, Phase 6: 8, Phase 7: 4) + **10 carrying an
  unreachability record** (Basic 1, TemporalZTime 1, TemporalBoolean 1, Temporal 3, Modal 1,
  Meta 1, Carrying 2) = 36.
- **36-site audit** (the phase's second verification criterion, walked site by site rather than
  by re-running the pattern that produced the list):
  - `Basic.lean` (2): the `lapply` instance diagnostic — pre-pinned by the `ReviewInstance`
    test; "the applied rule produced an incompatible judgment" — in-source note (Phase 2).
  - `Carrying.lean` (4): determined-formula — pinned (Phase 7); no-carrying-rule — recorded;
    "`keeping` carries only …" — pre-pinned in three variants; framed-certificate — recorded.
  - `Discrete.lean` (2): induction-goal — pinned (Phase 7); backward-induction — recorded.
  - `Meta.lean` (1): "expected a native derivation" — recorded.
  - `Modal.lean` (4): "expected a native derivation" — recorded; matching-scope — pre-pinned
    (`ProofModeTemporalTest.lean:119`); universal-modality — pinned; body-hypothesis-names —
    pinned.
  - `Temporal.lean` (13): unregistered-rule, missing-view, view-mismatch — in-source notes
    (Phase 6); undetermined-frame-class — pinned (Phase 3); integer-time — pre-pinned twice;
    the remaining seven — pinned (Phase 6), with the Since/Until message pinned in both branches
    and the two `ident`-position fallback arms pinned after the Phase 6 premise correction.
  - `TemporalBoolean.lean` (9): unregistered-rule — in-source note (Phase 5); the other eight —
    pinned (Phase 5).
  - `TemporalZTime.lean` (1): unregistered-rule — in-source note (Phase 1).
- **Batch gate deferral**: the full gate set was NOT independently run for this phase. The
  `local` tier was discharged by the guarded scoped build of `BimodalTest.Automation.ProofModeTest`
  and `BimodalTest.Automation.ProofModeCarryingTest` (exit 0, zero `error:`/`warning:`) plus
  `typst-sync-check.sh --counts-only` (exit 0 after `--fix`). A full guarded `lake build` also
  ran green (exit 0, 3027 jobs, zero `error:`/`warning:`) as the phase-end full-build gate, and
  `check-module-invariants.sh --emit-inventory --check` exits 0. The complete gate set is
  deferred to the batch stage at the end of this /orchestrate invocation.


---

### Phase 8: Status Stamp, README Stamps and Closing Gates [COMPLETED]

**Goal**: `typst/generated/status.typ`'s stamp commit is a commit whose own tree reproduces every
recorded figure; the three in-territory README stamps are current; and the repository's gate
battery is green or its findings are accounted for as pre-existing.

**Tasks**:
- [x] Confirm every `.lean` change from phases 1-7 is committed and the working tree holds no uncommitted `.lean` path: `git status --short -- '*.lean'` is empty. This is the precondition for the stamp; a later `.lean` edit invalidates it and requires re-running this phase's regeneration.
- [x] Run the unscoped guarded build so the write path can read the built library: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
- [x] Regenerate the stamp with the bare write path, NOT `--fix`: `bash scripts/typst-status-counts.sh`. `typst-sync-check.sh --fix` regenerates only on a Check 2 count mismatch and prints "Nothing to fix" otherwise, so it cannot refresh a stale stamp whose counts already match the working tree.
- [x] Confirm the new `stamp-commit` equals the short SHA of the last `.lean` commit (`git rev-parse --short HEAD`).
- [x] Bump the `*Last verified:*` stamp to today's date in `FormalSystem/Automation/ProofMode/README.md`, `FormalSystem/Theorems/ProofMode/README.md` and `FormalSystem/Theorems/ProofMode/TemporalComposition/README.md`. Leave every other README's stamp alone, including the three already-grandfathered parents.
- [x] Commit `typst/generated/status.typ` and the three READMEs together, with no `.lean` path staged — the pre-commit hook is then a fast no-op and the stamp survives the commit.
- [x] Verify the stamp reproduces its counts, the only check that sees this: `git worktree add --detach <scratch> <new-stamp-commit>`, then `bash <scratch>/scripts/typst-status-counts.sh --json` (the `--json` path reads no `.lake` and takes no lock), and compare every scalar against the committed `status.typ`. Remove the worktree afterwards.
- [x] Run `lake test` through the guard and confirm zero `error` lines in the log.
- [x] Run `bash scripts/verify-all.sh` and account for each finding: `readme-lint.sh` is expected to report 4 new stale rows (`FormalSystem/Tactic`, `FormalSystem/Metalogic/Conservativity/Star`, `FormalSystem/Metalogic/Expressiveness`, `FormalSystem/Metalogic/WeakCanonical`), down from 7 at baseline, all four in directories this task does not touch. Any other failure is this task's own. *(deviation: altered — the dispatch's Batch Gate Deferral directive forbids an additional full sweep, so this was discharged as `verify-touched.sh` (127 touched paths; 84 passed, 1 failed, 10 skipped) plus `scripts/readme-lint.sh` run directly under the UNMAPPABLE CRITERION carve-out, the narrowed battery reaching no readme-lint suite. The four predicted stale rows matched exactly; the one failing suite is unattributable. See Completion Notes below.)*
- [x] Record, in the phase's completion notes, the touched-path scoped check this dispatch ran and the explicit deferral of the complete gate set to the orchestration close.

#### Completion Notes

**Scoped discharge and the deferral of the complete gate set.** This phase declares
`**Verification Tier**: full`, and that field is unchanged. The dispatch carried a Batch Gate
Deferral directive: this task is one `implement` dispatch inside a multi-task /orchestrate batch,
so the complete gate set is deferred to the batch stage at the end of the invocation and is
attributed back to this task by its own `modified_files`. The full set was DEFERRED, not
independently run, and not forgiven.

What ran in-dispatch, in place of `scripts/verify-all.sh`:

- `bash .claude/scripts/verify-touched.sh` (no arguments, deriving its own touched paths): 127
  touched paths resolved; **84 passed, 1 failed, 10 skipped, 95 total**. The 10 skips are the
  standing, task-independent baseline for this checkout — the suites that require a local
  `agent-system/extensions/` source store, which this repository resolves externally through
  `.claude-extensions.json`.
- `bash scripts/readme-lint.sh`, run directly under the directive's UNMAPPABLE CRITERION
  carve-out. The narrowed battery mapped none of the 127 touched paths to a readme-lint suite
  even though three `README.md` files sit in this task's own commits, and `readme-lint.sh`
  exposes no path-scoping flag, so it necessarily ran unscoped.

**The one failing suite is not this task's.** `.claude/scripts/tests/test-deploy-baseline-lib.sh`
fails one control assertion (`a genuinely matching warm-cache entry was expected to skip gate 1
but did not`), 29 of its 30 assertions passing. Per-touched-file evidence that it is
unattributable: `.claude/` is gitignored in full (`.gitignore:107`), so that suite file is
untracked and byte-identical before and after all eight of this task's commits; none of those
eight commits touches any `.claude/`, `scripts/`, or `lib/` path at all; and the failing
assertion exercises `verify-deploy.sh`'s gate-cache warm-skip behaviour against a synthetic
`/tmp` scratch target that shares no input with any path in this task's file scope. The last
commit to touch that machinery predates this task.

**readme-lint's new rows are exactly the predicted four.** Live `STALE DATE` findings differenced
against `scripts/readme-date-baseline.txt` give 65 live against 63 baseline rows, and the new
rows are `FormalSystem/Metalogic/Conservativity/Star/README.md`,
`FormalSystem/Metalogic/Expressiveness/README.md`,
`FormalSystem/Metalogic/WeakCanonical/README.md` and `FormalSystem/Tactic/README.md` — the
phase's predicted set, member for member, with **zero in-territory rows**, which is the positive
confirmation that the three in-territory stamp bumps landed. None of the four directories is
touched by any of this task's commits. `readme-lint.sh` therefore exits 1, as the Scope
Hypothesis anticipated; the hypothesis to confirm was the SHAPE, and the shape holds.

**Gate results.**

- Unscoped guarded `lake build`: exit 0, 3027 jobs, zero `error:` lines over both captured
  streams. `.olean` artifacts verified newer than source for all five library modules this task
  changed.
- Guarded `lake test` (`lake-build-guard.sh build --timeout 1800 -- test`): exit 0, zero `error`
  lines in the log.
- Stamp reproduction, the DONE WHEN clause with no mechanical gate: a detached worktree at the
  recorded stamp commit `3d141e284`, then `scripts/typst-status-counts.sh --json`, reproduced
  EVERY scalar recorded in `typst/generated/status.typ` — `formalsystem-line-count` 422525
  included, closing the +6 delta the Scope Hypothesis predicted would need resolving. Worktree
  removed afterwards.
- `stamp-commit` `3d141e284` is phase 7's commit, which touches no path this phase committed
  (this phase committed `typst/generated/status.typ` and three `README.md` files only), and it
  remains the last `.lean` commit on the branch.
- Sorry census 0; axiom count unchanged at 14 (14 at the pre-task base, zero `axiom` lines added
  by any task-987 commit, none anywhere in this task's territory). The vacuous-definition grep
  reports 2 hits, both pre-existing in files this task never touched
  (`FormalSystem/Semantics/PointTransport.lean:215`,
  `FormalSystem/Examples/TemporalStructures.lean:495`) and both false positives of the
  single-line pattern against deliberate total-relation content.
- Lean plan compliance spot-check: `skipped`, as expected — this plan declares
  `<!-- lean-challenge-statements:none -->` and has no named theorem deliverable.

**Concurrency observation.** Sibling task 993 landed its own close commit `5988d4dc9` while this
dispatch was running, moving HEAD off `572f668f3`. Confirmed via `git log` to be the declared
concurrent sibling under the same session id, touching only its own `specs/` paths plus
`specs/TODO.md` and `specs/state.json` — no `.lean` path and no task-987 path — so the stamp's
last-`.lean`-commit invariant was unaffected.

**Not independently re-derived.** The 46 Kamp bounded-fix `Fold`/`Unfold` occurrences that
Phase 1's criteria pin were verified by Phase 1 and are not re-measured here; the headline
retirement condition was re-confirmed, with no occurrence of the old one-step Until/Since
vocabulary remaining anywhere under `FormalSystem/Automation/ProofMode/` or
`FormalSystem/Theorems/ProofMode/`, and no `?m.` in any `Tests/BimodalTest/Automation/` pin.


**Timing**: 60 minutes

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: the stamp commit `0c14ccb0e` reproduces every recorded figure except
`formalsystem-line-count`, which is 422468 at that commit against the recorded 422474 — a +6
delta owed to three later commits unrelated to this contribution — and `readme-lint.sh` reports 7
new stale rows at baseline, of which 3 are in territory. Carried from
`reports/01_temporal-rules-followups.md` and independently re-derived at plan authoring time by
summing `git cat-file blob` line counts over every `FormalSystem/**.lean` path at both commits,
and by differencing the live `STALE DATE` findings against `scripts/readme-date-baseline.txt`.
Both figures will have moved by the time this phase runs, because phases 1-7 change Lean line
counts; the hypothesis to confirm is the SHAPE (stamp commit's tree reproduces every figure
afterwards; exactly the four out-of-territory rows remain stale), not either number.

**Files to modify**:
- `typst/generated/status.typ` - final regeneration, stamp naming the last `.lean` commit
- `FormalSystem/Automation/ProofMode/README.md` - `*Last verified:*` stamp bumped
- `FormalSystem/Theorems/ProofMode/README.md` - `*Last verified:*` stamp bumped
- `FormalSystem/Theorems/ProofMode/TemporalComposition/README.md` - `*Last verified:*` stamp bumped

**Verification**:
- `git worktree add --detach` at the recorded `stamp-commit`, then `bash <scratch>/scripts/typst-status-counts.sh --json`, yields every scalar recorded in `typst/generated/status.typ`, `formalsystem-line-count` included. This is the DONE WHEN clause with no mechanical gate: `typst-sync-check.sh` Check 2 excludes the stamp fields and compares against the working tree, so it reports no mismatch either way.
- `stamp-commit` is the short SHA of a commit that touches no path this phase committed.
- Unscoped guarded `lake build` green with no diagnostics; `lake test` green with zero `error` lines.
- `bash scripts/verify-all.sh` reports `readme-lint.sh` with exactly the four named out-of-territory stale rows and no in-territory row, and every other check green or its finding enumerated as pre-existing and outside this task's file scope with per-touched-file evidence attached.
- The in-dispatch obligation is recorded as the scoped touched-path check plus the explicit deferral of the complete gate set to the orchestration close (`context/contracts/batch-gate-stage.md`); this phase does not run an independent full-battery sweep as its own criterion.

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

This task has no theorem deliverable. The eight renamed declarations are existing `def`s whose
signatures are unchanged by the rename, and the new test material is `example`s and `#guard_msgs`
blocks rather than named results, so there is no statement for this section to pin that the tree
does not already fix. The rationale is recorded under `## Decisions`, and the rename is protected
by the exact-name greps in Phase 1's verification criteria instead.

## Testing & Validation

- [x] No identifier inside `FormalSystem/Automation/ProofMode/` or *(verified this dispatch: zero occurrences of the old one-step Until/Since vocabulary under either directory. The 46 Kamp bounded-fix occurrences were verified by Phase 1 and are NOT re-derived here.)*
      `FormalSystem/Theorems/ProofMode/` carries `Fold`/`Unfold` in a one-step Until or Since
      name, and the 46 Kamp bounded-fix occurrences are unchanged.
- [x] `lprogress` is exercised in all four forms across future TM, past TM, future TM⁺ and past
      TM⁺, with the two pre-existing cells unduplicated.
- [x] Every one of the 36 `throwError` sites the contribution added is pinned by a `#guard_msgs` *(attested by Phases 5, 6 and 7, not re-walked this dispatch; Phase 7's `#### Reasoned Exclusions` records the five unreachable arms with per-arm evidence.)*
      test, already pinned before this task, or carries an in-source note saying why no test is
      constructible — verified by walking the measured site list, not by re-running the pattern
      that produced it.
- [x] No `#guard_msgs` pin anywhere in `Tests/BimodalTest/Automation/` contains `?m.`.
- [x] The instance-ordering regression example compiles under the fixed ordering and fails under *(attested by Phase 2's `#### Completion Notes`: hand-verified to fail pre-fix with `lapply could not synthesize the required instance FrameTag ?fc`, file restored byte-identically afterwards. Confirmed this dispatch only that it compiles under the fixed ordering, via the green full build.)*
      the pre-fix ordering, checked once by hand.
- [x] `applyDerivationProof`'s doc comment states that `firstNewIndex` is snapshotted before
      elaboration.
- [x] Both pre-existing `integer-time reasoning` pins still match after the catch is narrowed, and
      a non-frame-class failure reaches the user with its original message appended (or the
      absence of a constructible trigger is recorded in-source).
- [x] The three `FormalSystem/Automation/ProofMode/README.md` descriptions name what their
      modules now contain.
- [x] `typst/generated/status.typ`'s stamp commit reproduces every recorded figure, verified by
      detached worktree.
- [x] Unscoped guarded `lake build` and `lake test` green; `bash scripts/verify-all.sh` green or
      its findings accounted for as pre-existing and outside this task's file scope.

## Artifacts & Outputs

- `FormalSystem/Theorems/ProofMode/TemporalComposition/TemporalZTime.lean` -- eight `def`s renamed
  to the expand/contract vocabulary in both the TM and TM⁺ namespaces, headings and docstrings
  reworded
- `FormalSystem/Automation/ProofMode/TemporalZTime.lean` -- two `private def`s and four `syntax`
  node names renamed, four rule keys moved in lockstep, one unreachable-arm note
- `FormalSystem/Automation/ProofMode/Basic.lean` -- instance-synthesis loop relocated after the
  conclusion unification; `firstNewIndex` ordering requirement stated in the doc comment
- `FormalSystem/Automation/ProofMode/Temporal.lean` -- narrowed `integerTimeGate` catch; three
  unreachable-arm notes
- `FormalSystem/Automation/ProofMode/TemporalBoolean.lean` -- one unreachable-arm note
- `FormalSystem/Automation/ProofMode/README.md` -- three corrected description cells; regenerated
  `Lines` column; bumped `*Last verified:*` stamp
- `FormalSystem/Theorems/ProofMode/README.md` -- bumped `*Last verified:*` stamp
- `FormalSystem/Theorems/ProofMode/TemporalComposition/README.md` -- regenerated `Lines` column;
  bumped `*Last verified:*` stamp
- `Tests/BimodalTest/Automation/ProofModeTemporalBooleanProgressTest.lean` -- 14 coverage examples
  and 8 negative tests
- `Tests/BimodalTest/Automation/ProofModeTemporalTest.lean` -- the instance-ordering regression
  example, the incompatible-judgment pin and 7 negative tests
- `Tests/BimodalTest/Automation/ProofModeTemporalZTimeTest.lean` -- the undetermined-frame-class
  pin and, if constructible, the pass-through pin
- `Tests/BimodalTest/Automation/ProofModeTest.lean` -- 6 negative tests (Modal, Meta, Discrete)
- `Tests/BimodalTest/Automation/ProofModeCarryingTest.lean` -- 3 negative tests
- `README.md` -- regenerated `dir=FormalSystem rows=totals` block
- `typst/generated/status.typ` -- regenerated counts, with a final stamp naming the last `.lean`
  commit
- `specs/987_temporal_rules_followups_fold_names_and_progress_tests/summaries/01_temporal-rules-followups-summary.md`

## Rollback/Contingency

Every phase lands its own commit carrying its own regenerated generated surfaces, so reverting a
phase is `git revert` of that commit, which restores the source edit and the matching counts
together. Phase 1 is the one phase whose intermediate per-file states are expected red (renaming
the Theorems file breaks the automation file until it is repointed), which is why it declares
`Commit Mode: atomic-batch`; a revert of its single commit restores both files at once.

If a working tree must be discarded mid-phase, that is a genuine rollback, not a routine
checkpoint: take the snapshot first using the invocation shape
`context/contracts/recovery.md`'s rollback rung gives (task number explicit, with its
out-of-scope override flag only where the discard genuinely reaches outside this task's declared
file scope), then run the discard. For an ordinary defensive checkpoint before a risky edit --
Phase 1's lockstep rename and Phase 2's elaborator reorder are the plausible places -- use
`bash .claude/scripts/git-snapshot.sh 987 --no-revert`, which is durable without reverting the
working tree. A concurrent sibling is live on this tree, so never use the reverting default mode.

Contingency branches, by phase:

- **Phase 1**, if a renamed identifier collides with something the grep missed: stop, record the
  collision, and rename only within the three `ProofMode` namespaces. Never widen the edit into
  `FormalSystem/Metalogic/Expressiveness/Kamp/` to resolve it.
- **Phase 2**, if the relocated loop changes the existing `ReviewInstance` pin's text: the pin is
  the contribution's own test and the measured evidence says it is unaffected, so a change there
  means the move was not byte-identical. Restore and re-apply, rather than editing the pin.
- **Phase 3**, if no non-frame-class trigger can be constructed for the pass-through branch: that
  is a recorded in-source note plus a completion-note entry, not a blocker, and not grounds to
  leave the catch bare.
- **Phases 5-7**, if a site counted as reachable turns out not to be triggerable from parsed
  syntax: record it in-source with the reason, exactly as the five known unreachable arms are
  handled, and close the phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions`
  record naming each such site, its message and the evidence. A silent gap is the one outcome
  item (2) forbids.
- **Phase 8**, if the detached-worktree check shows the stamp still not reproducing its counts:
  the usual cause is an uncommitted or later `.lean` change. Commit or revert it, re-run the bare
  `scripts/typst-status-counts.sh`, and re-verify. Do not edit `status.typ` by hand.
- **Phase 8**, if a `verify-all.sh` check is red only for pre-existing, untouched-file reasons:
  that is a recorded PASS for the phase, with the findings enumerated by name and per-touched-file
  evidence attached. It is not a blocker, and it is not grounds to edit an out-of-scope file to
  force a repo-wide count to zero.
