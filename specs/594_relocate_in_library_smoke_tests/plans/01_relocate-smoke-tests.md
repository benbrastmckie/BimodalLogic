# Implementation Plan: Task #594

- **Task**: 594 - Relocate in-library smoke tests
- **Status**: [COMPLETED]
- **Effort**: 11 hours
- **Dependencies**: None upstream. Downstream: the zero-occurrence declaration triage (C17 census) must run after this task lands
- **Research Inputs**: specs/594_relocate_in_library_smoke_tests/reports/01_relocate-smoke-tests.md
- **Artifacts**: plans/01_relocate-smoke-tests.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The live library carries 404 line-anchored `#check`/`#eval`/`#print` lines (re-measured at plan
time: 404 across 29 files, matching the task description). Research showed 39 of them sit inside
doc comments, leaving 365 live directives in 22 files, split into four classes: A (MainResults
audit page, 54, keep), B (`#print axioms` in 7 Metalogic files, 19), C (`#guard_msgs in #eval`
probes, 56, move verbatim), D (bare `#eval`/`#check`, 236, move and convert to asserting `#guard`s).
This plan adds a comment-aware debug-artifact invariant (C27) with an exact-count allowlist
FIRST, seeded with the current live counts, then ratchets each allowlist entry to zero as its file's
directives are relocated, so the gate is enforced from day one and every phase proves its own
progress. Done means: `lake build` and `lake build BimodalTest` green, the full harness green, and the
allowlist reduced to `FormalSystem/MainResults.lean 54` with a recorded reason.

### Research Integration

Report 01 is adopted essentially whole: the class A-D census and per-file destinations, the
observed `#eval` values that the new `#guard`s must pin (including the `foldFormula`-on-`or`
comment drift: it prints `imp (neg (atom p)) (atom q)`, so pin that), the C27 specification
(comment-aware masking, exact per-file counts, stale-entry detection, `ENFORCE_C27=1`), the
C14-baseline handling of class B, the cross-reference repairs (Register.lean `:815`/`:828`, the stale
"Exactly five in-file directives" C14 comment, the two NonCompactness docstrings, probe prose that
promises "fails the build"), the missing C26 harness-header line, and the scoped relocation of
~117 explicitly test-labelled `example`s.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

### Decisions

- **Gate first, ratchet down.** C27 lands in Phase 1 with an allowlist that records every file's
  current live count. Each relocation phase lowers or deletes its own entries. This reverses the
  research sketch's ordering (the invariant was described last), but it means no intermediate
  commit is ever unguarded, and a count mismatch shows the scope drift at once.
- **Class B goes to the C14 baseline** (the research recommendation, following the harness's own
  recorded precedent). The 7 unpinned names are captured from a real `#print axioms` run against
  built oleans and never typed by hand. **Fallback** (not a user decision): if the C14 `.lean` half
  cannot be regenerated cleanly inside the phase budget, keep the 19 directives and allowlist the
  7 files with exact counts and reason "axiom audit beside the theorem; pending C14 migration". The
  task's acceptance ("all allowlisted with a reason") holds either way.
- **`#check @x_unfold` rows move to Tests rather than being deleted**, so the C17 census stays
  stable. The downstream zero-occurrence triage then decides on a clean census.
- **Examples**: only the explicitly test-labelled sections move (Commands.lean "Test N" block,
  Normalization UnfoldTests/RoundTripTests, Derivable.lean "Aesop and Simp Test Examples", the three
  `Syntax/*Language/Derivation.lean` "Smoke tests", Propositional `PropForm`/`Decidable` "Smoke
  Tests"). Design-premise pins, `rfl` pins, carrier gates, and non-vacuity witnesses stay beside
  their definitions. C27 does not scan `example`.
- **Commented usage blocks (39 lines) stay untouched.** They are documentation-shaped, and the
  comment-aware C27 needs no allowlist entries for them. The one stale "re-checkable by
  uncommenting" copy in `Deterministic/Completeness.lean` is removed in Phase 6, together with the
  live block it duplicates.

## Goals & Non-Goals

**Goals**:
- Every live in-library debug directive outside the audit page is relocated to the test suite or migrated to the C14 axiom baseline.
- Every relocated bare evaluation becomes an asserting guard (or a throwing IO test) that pins the observed value.
- A comment-aware debug-artifact invariant (C27) with an exact-count, reason-annotated allowlist is enforced and documented in the harness header and the module-invariants doc.
- Test-labelled example sections are moved into their matching test modules.
- The library build, the test-suite build, and the full harness are all green at completion.

**Non-Goals**:
- Changing the audit page (MainResults.lean) in any way.
- Moving documentation-shaped examples, design-premise regression pins, or commented usage blocks.
- Removing zero-occurrence declarations (the downstream C17 triage owns that).
- Adding any new theorem, lemma, or definition to the library.
- Making cslib's non-comment-aware grep pass on docstring usage blocks (noted in C27's header only).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C27 comment masker mis-tracks string/char-literal state (the research prototype misclassified one live `#guard`) | H | M | Ship C27 with a fixture self-test covering `"..."` strings containing `/-` and `--`, `'"'` char literals, nested `/- /- -/ -/`, and docstring code blocks. Cross-check the masked count against the raw grep minus masked lines |
| A converted `#guard` pins a comment value instead of the observed value | M | M | Re-run `lake env lean <file>` on the source BEFORE excision, save the output to the scratchpad, and derive every `#guard` RHS from that capture. Never derive it from the trailing comment |
| Build-failure guarantee weakens to a test-suite guarantee | M | H | C1 already runs `lake build BimodalTest`. Rewrite the probe prose to name the test module, and leave a one-line pointer where each probe section was |
| C20 citation line-shift (Saturation.lean 5 inbound, BranchOrder.lean 2, possibly Syntax/Formula.lean) | M | M | Run the harness `--no-build` after each file's excision. Repoint any broken `file.lean:NNN` to a declaration name |
| C14 baseline edit wrong or hand-typed | H | L | Capture the lines from `#print axioms` output on built oleans. Keep the C14BASE and C14LEAN heredocs in the same order. If this fails, fall back to allowlisting (see Decisions) |
| Private-fixture name clashes when merging several sources into one test module | L | M | Use one `namespace BimodalTest.<Area>.<Module>Test` (or a section) per source file |
| New test module not wired, so the harness fails "absent from both" | M | L | Add every new module to `Tests/BimodalTest.lean` in the same commit that creates it |
| Test-suite runtime growth (FormulaEnumerator ~7 s, BiLasso n=2 ~15 s) | L | M | Acceptable at the current suite size. If it is not, move the two slowest rows to a manifest-listed, aggregator-excluded module following the `DerivationBenchmark.lean` precedent |
| Concurrent `lake build`s exhaust memory or livelock under the foreground cap | M | M | Every build is detached and routed through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- <args>` per `long-builds.md`. Parallel-wave phases serialize their builds through the guard's lock |
| Task-number citations in new module docstrings | L | L | Use none. Cite filenames and section headings only |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5 | 1 |
| 3 | 6, 7 | 6: 1; 7: 2 |
| 4 | 8 | 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel. Wave-2 phases touch disjoint library files.
Their shared edits are distinct lines in `Tests/BimodalTest.lean` and
`scripts/debug-artifact-allowlist.txt`. Their builds serialize through the build guard. An
executor running serially should simply take phases in numeric order.

### Phase 1: C27 debug-artifact invariant with seeded allowlist [COMPLETED]

**Goal**: Land an enforced, comment-aware C27 whose allowlist records the current live count of every affected file, so later phases ratchet it down.

**Tasks**:
- [x] Write `scripts/debug-artifact-allowlist.txt`: an admission-bar preamble in the style of `scripts/nolint-attribute-allowlist.txt`, the format `<path> <exact live count>`, and a `#` reason line before each entry. Seed one entry per file with live directives: MainResults with the reason "intentional axiom-audit page; C21 asserts every name is pinned by C2/C14", and every other file with the reason "pending relocation to Tests/BimodalTest".
- [x] Implement C27 in `scripts/check-module-invariants.sh` *(deviation: altered — the masker and its fixtures live in the new shared helper `scripts/lib/lean_debug_artifacts.py`, imported by C27, rather than inline; the allowlist parser also fails an entry with no reason line)*, after C26, reusing C26's Boneyard-pruning walk and running under `--no-build`. It masks nested block comments, docstrings, line comments, string literals and char literals, then matches `^\s*(#check|#eval|#print|#reduce)\b`, `#guard_msgs in #eval` on the same line, and `\bdbg_trace\b|\bdbgTrace\b`. It fails on an unlisted file, fails on a count mismatch in either direction, and fails on a stale entry (a listed file with count 0 or no longer present).
- [x] Add a masker fixture self-test (like B0's filter self-test) covering strings holding `/-` and `--`, `'"'`, nested comments, and a docstring whose code block starts with `#check`.
- [x] Add `ENFORCE_C27=${ENFORCE_C27:-1}` and the C27 header block. Add the **missing C26 header line** and a companion-file mention of the allowlist. Note in the header that cslib's `pre-pr-check.sh` grep is not comment-aware.
- [x] Add a C27 row to `docs/development/MODULE_INVARIANTS.md`'s check table.
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C27 passes on the seeded allowlist. Temporarily add a stray `#eval` to a scratch copy to confirm it fails, then revert. *(completed on a scratch copy of the tree: unlisted file, count mismatch, stale entry and missing reason line all FAIL with exit 1; first-run census 365 lines / 22 files matches research exactly, 404 raw - 39 masked)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 22 files carry live directives, totalling 365 (research's comment-aware scan). Confirm by comparing C27's own first-run per-file counts with the raw grep (404 lines / 29 files) minus the masked lines. If they disagree, trust C27's fixture-tested masker, record the discrepancy in the phase notes, and seed the allowlist from C27's output.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C27 implementation, header (C26 + C27), enforce flag
- `scripts/debug-artifact-allowlist.txt` - new allowlist
- `docs/development/MODULE_INVARIANTS.md` - C27 row

**Verification**:
- Harness `--no-build` exits 0 with C27 PASS; the fixture self-test passes; a deliberately injected directive makes C27 fail.

---

### Phase 2: Relocate Syntax/Formula, Normalization, FormulaEnumerator probes [COMPLETED]

**Goal**: Move the Syntax and Normalization-area class-D directives (plus Normalization's `#check @*_unfold` block) into Tests as asserting guards.

**Tasks**:
- [x] Capture baseline output: run `lake env lean` on `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Automation/Normalization.lean` and `FormalSystem/Automation/FormulaEnumerator.lean`, saving the output to the scratchpad.
- [x] Syntax/Formula.lean (20): append `#guard (...).complexity == N` rows to `Tests/BimodalTest/Syntax/FormulaTest.lean`, recreating the `private` `pCmplx*` fixtures in a test namespace. Delete the source rows and their fixtures (after confirming no other library use).
- [x] Normalization.lean (17 `#check @x_unfold`, 25 `#eval`): move the `#check`s verbatim into `Tests/BimodalTest/Automation/NormalizationTest.lean`. Convert the fold rows to `#guard ... == EnrichedFormula...`, pinning the **observed** `or` output, and turn the JSON/SExpr/pretty rows into `#guard ... == "..."`. Turn the round-trip census into a `#guard` over its Bool result. *(deviation: altered — the whole UnfoldTests, FoldTests (including its 9 existing `#guard`s), RoundTripTests and SerializationTests sections moved as units, so Phase 7's Normalization example move was done here; the 17 `#check`s and unfold-lemma references are fully qualified in the test because `FormalSystem.Syntax` exports same-named `*_unfold` lemmas)*
- [x] FormulaEnumerator.lean (6 `#eval`, plus the 2 in-library `#guard`s, optional): add them to `NormalizationTest.lean`, which already imports FormulaEnumerator, as `#guard (enumExactHelper defaultAtoms 2 2 4 {}).1.size == 7852` and similar for 75914, 45111 and the three `true`s.
- [x] Update each source's section docstring to a one-line pointer to the test module. Ratchet the three allowlist entries to 0 by deleting them.
- [x] Build the library modules and the test modules through the guard, then run the harness `--no-build` (C20, C27).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: 88 live directives (20 + 42 + 6). Confirm with C27's per-file counts before editing. Removed private fixtures have no other library users; confirm with grep before deleting.

**Files to modify**:
- `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Automation/Normalization.lean`, `FormalSystem/Automation/FormulaEnumerator.lean` - remove probes
- `Tests/BimodalTest/Syntax/FormulaTest.lean`, `Tests/BimodalTest/Automation/NormalizationTest.lean` - add guards
- `scripts/debug-artifact-allowlist.txt` - delete three entries

**Verification**:
- `lake build FormalSystem.Syntax.Formula FormalSystem.Automation.Normalization FormalSystem.Automation.FormulaEnumerator` and `lake build BimodalTest.Syntax.FormulaTest BimodalTest.Automation.NormalizationTest` are green (guarded, detached). The harness `--no-build` passes.

---

### Phase 3: Relocate DatasetGenerator probes [COMPLETED]

**Goal**: Move the 116 DatasetGenerator directives into a new asserting test module.

**Tasks**:
- [x] Capture `lake env lean FormalSystem/Automation/DatasetGenerator.lean` output to the scratchpad.
- [x] Create `Tests/BimodalTest/Automation/DatasetGeneratorTest.lean` (module docstring, no task numbers). Convert the 108 pure prefilter rows (lines ~974-1245) to `#guard` using the captured values, for example `#guard structuralPrefilterWithAxiom (...) == some (true, "...")`. `SimpleCountermodel` derives only `Repr`, so compare its projected fields. *(completed: 107 single-value rows generated from captured `#eval` output, 8 list/option rows written against the fixtures, 1 `constructTrivialCountermodel` row pinning projected lengths; perturbing one `#guard` and one IO test each failed elaboration)*
- [x] Convert the 8 `IO Unit` "[test] PASS/FAIL" smoke tests (lines ~2022-2269) to `#eval show IO Unit from do ... unless ok do throw (IO.userError "...")` in one `section`.
- [x] Delete the source rows. Leave a one-line pointer in each source section. Wire the new module into `Tests/BimodalTest.lean`. Delete the allowlist entry.
- [x] Build the library module and the new test module through the guard, then run the harness `--no-build`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: 116 directives = 108 pure + 8 IO, at the line ranges above. Confirm by grep before editing, and confirm no row depends on a `private` library helper that would need to become public (research found all functions under test public).

**Files to modify**:
- `FormalSystem/Automation/DatasetGenerator.lean` - remove probes
- `Tests/BimodalTest/Automation/DatasetGeneratorTest.lean` - new
- `Tests/BimodalTest.lean` - import
- `scripts/debug-artifact-allowlist.txt` - delete entry

**Verification**:
- Library module and `BimodalTest.Automation.DatasetGeneratorTest` build green. Injecting a deliberately wrong expected value into one `#guard` and one IO test (scratch edit, reverted) fails elaboration. The harness `--no-build` passes.

---

### Phase 4: Relocate Saturation probes [COMPLETED]

**Goal**: Move Saturation.lean's 48 bare PASS/FAIL evals and 11 guarded probes into a new test module.

**Tasks**:
- [x] Capture `lake env lean FormalSystem/Metalogic/Decidability/Saturation.lean` output (47 PASS + 1 INFO E5).
- [x] Create `Tests/BimodalTest/Metalogic/Decidability/SaturationTest.lean`. Convert each `#eval do ... return "PASS/FAIL ..."` into a `#guard` over its underlying Bool condition. *(deviation: altered — each row became `#guard (Id.run do ...) == "<captured verdict>"`, pinning the exact verdict string rather than a bare Bool, so a row switching between two PASS arms, or from PASS to an INFO arm, also fails; the 11 `#guard_msgs` rows and their fixtures moved verbatim)* The E5 INFO row becomes a `#guard` pinning the invalidity result. Move the 11 `#guard_msgs` rows (ArmSettlingProbes, BudgetedTableauProbes) verbatim with their fixtures (`probeFGp`, `probeNGFp`, `probeUpq`, `armProbe`, `armDisagreement`), one namespace per source section.
- [x] Delete the source rows and fixtures. Rewrite the probe prose to point at the test module. Wire the import. Delete the allowlist entry.
- [x] Run the harness `--no-build` and repair any C20 break from the 5 inbound Saturation citations (for example `Saturation.lean:360-364` in Fuel.lean) by repointing to declaration names. *(no break: C20 tier 1 passes; the one in-file prose pointer at the resolveOpenArm docstring was rewritten on the same line so the `Saturation.lean:661-664` citation in Fuel.lean still lands)*
- [x] Build the library module and the test module through the guard.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: 59 directives (48 bare + 11 guarded), all probes below line 1250, so the `:360`/`:646`/`:675` citations are unaffected. Confirm with C27 counts and C20 output.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Saturation.lean` - remove probes
- `Tests/BimodalTest/Metalogic/Decidability/SaturationTest.lean` - new
- `Tests/BimodalTest.lean` - import
- `scripts/debug-artifact-allowlist.txt` - delete entry
- any file carrying a broken `Saturation.lean:NNN` citation - repoint

**Verification**:
- Library module and `BimodalTest.Metalogic.Decidability.SaturationTest` build green. Harness `--no-build` (C20, C27) passes.

---

### Phase 5: Relocate Verified Termination/Bridge and BiLasso probes [COMPLETED]

**Goal**: Move the remaining class-C probe blocks and the BiLasso evals into test modules.

**Tasks**:
- [x] Create `Tests/BimodalTest/Metalogic/Decidability/Verified/TerminationProbes.lean`. Move the `#guard_msgs in #eval` rows verbatim from `Termination/TimeTypeBound.lean` (12), `Termination/Fuel.lean` (11) and `Termination/MintBound/PostBlocking.lean` (7) with their private fixtures (`stabilisesAt`, `probeAtom`, `probeGapBody`, `dualCheck`, `postBlockingRunProbe`), one namespace per source.
- [x] `MintBound/Measure.lean` (2): delete the `branchingWitnessArity` `#eval` (it is subsumed by `theorem branchingWitness_splits ... := by decide`, and `branchingWitnessArity` stays in the library). Move the `expandBranchWithFuel branchingWitness 500` row to TerminationProbes. *(the `WorldProbes` section keeps its theorem `worldWitness_self` in the library; only its 3 `#guard_msgs` rows moved)*
- [x] Create `Tests/BimodalTest/Metalogic/Decidability/Verified/BridgeProbes.lean`. Move `Bridge/BranchOrder.lean` (7) verbatim, and merge the duplicate `finOrderEmbInt 4` row from `Embed.lean` and `IntGaps.lean` into one row.
- [x] Create `Tests/BimodalTest/Metalogic/Decidability/BiLassoTest.lean`. Move the `BiLasso/Successor.lean` rows (4) verbatim. *(deviation: altered — `Successor` is listed as unreachable in `scripts/module-invariants-manifest.txt`, so importing it from an aggregator-wired module would pull the effective-periodic-extension cluster into the build graph and trip C6; its 4 rows went to a separate `BiLassoSuccessorTest.lean`, kept out of the aggregator and listed in the manifest so C6 compile-checks it)* Convert the `BiLasso/Examples.lean` counts (4) to `#guard ... .length == 6 / 2 / 36 / 1872` from captured output.
- [x] Update the cross-references: `Verified/Termination/MintBound/Register.lean:815` and `:828` (cite the test module and declaration names), and the probe-section prose that promises "fails the build" in BranchOrder/Embed/IntGaps/Fuel/TimeTypeBound.
- [x] Wire the three imports and delete the nine allowlist entries. Run the harness `--no-build` and repair C20 breaks (BranchOrder has 2 inbound citations).
- [x] Build the affected library modules and the three test modules through the guard.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: 49 directives across 9 files (12+11+7+2+7+1+1+4+4). Every fixture named above is private and used only by its probes. Confirm both by grep before moving; a fixture with a library user stays and is referenced from the test.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/{TimeTypeBound,Fuel}.lean`, `.../MintBound/{PostBlocking,Measure,Register}.lean` - remove probes / fix citations
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/{BranchOrder,Embed,IntGaps}.lean` - remove probes
- `FormalSystem/Metalogic/Decidability/BiLasso/{Successor,Examples}.lean` - remove probes
- three new test modules; `Tests/BimodalTest.lean`; `scripts/debug-artifact-allowlist.txt`

**Verification**:
- All touched library modules and the three new test modules build green. Verbatim `#guard_msgs` rows re-verify on the first build. Harness `--no-build` passes.

---

### Phase 6: Migrate class-B axiom prints to the C14 baseline [COMPLETED]

**Goal**: Pin the 7 unpinned axiom sets in C14 and remove all 19 in-file `#print axioms` directives from the 7 Metalogic files.

**Tasks**:
- [x] Ensure oleans for the 7 files are built (guarded). Run `#print axioms` for the 7 unpinned names (`real_lub_of_bddAbove`, `dedekind_box_dense_mem`, `detCompletenessBase`, `detCompletenessDense`, `detCompletenessZTime`, `detCompletenessRTime`, `logicDeterministicEqDeterminedValid`) via a scratch file with `lake env lean`, and capture the output verbatim, using fully qualified names.
- [x] Append the captured lines in matching order to both the `C14BASE` and `C14LEAN` heredocs in `scripts/check-module-invariants.sh`.
- [x] Delete the 19 live directives from `Deterministic/Completeness.lean` (and its stale commented duplicate copy), `BXCanonical/Completeness.lean`, `BXCanonical/CompletenessDedekind.lean`, `Compactness.lean`, `StrongCompleteness.lean`, `DiscreteNonCompactness.lean` and `DedekindNonCompactness.lean`.
- [x] Rewrite the prose: the C14 "Exactly five in-file directives remain" comment (say none remain outside MainResults), `DiscreteNonCompactness.lean:305` and `DedekindNonCompactness.lean:507` docstrings.
- [x] Delete the seven allowlist entries, leaving only MainResults. Run the full harness (not `--no-build`) so that C14's `.lean` half, C2 and C21 actually execute. *(deviation: altered — verified here by a guarded full `lake build` (2660 jobs, green) and by running C14's `.lean` half verbatim against both heredocs (113 = 113 lines, exact match); the full harness run is Phase 8's final gate)*
- [ ] **Fallback** if the C14 capture or comparison cannot be made green in budget: revert the directive deletions, keep the 7 files allowlisted with exact counts and the reason "axiom audit beside the theorem; pending C14 migration", and record this in the phase notes. *(deviation: skipped — not needed; the migration went green)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: 19 live directives (5+5+4+2+1+1+1); 12 already pinned by C2/C14 and 7 unpinned (list above). Confirm by grepping each name against both baselines before editing.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C14 heredocs and comment
- 7 Metalogic files listed above - remove directives and fix prose
- `scripts/debug-artifact-allowlist.txt` - reduce to MainResults

**Verification**:
- The full harness run passes C2, C14 (both halves), C21 and C27, and the allowlist contains only `FormalSystem/MainResults.lean 54` (or the documented fallback set).

---

### Phase 7: Relocate test-labelled example sections [COMPLETED]

**Goal**: Move explicitly test-labelled `example` blocks out of library modules into their matching test modules.

**Tasks**:
- [x] `Automation/Tactics/Commands.lean`: move the 72 live `modal_search` "Test N" examples to `Tests/BimodalTest/Automation/TacticsTest.lean`, and delete its three `example : True := trivial` placeholders. *(the whole tests tail from "Phase 1.1 Tests" moved as one `CommandsTests` section, including its `noncomputable example`s and the commented-out disabled tests, which stay as comments)*
- [x] `Automation/Normalization.lean`: move the UnfoldTests and RoundTripTests (26) to `NormalizationTest.lean`. *(completed early in Phase 2)*
- [x] `ProofSystem/Derivable.lean`: move "Aesop and Simp Test Examples" (5) to `Tests/BimodalTest/ProofSystem/DerivationTest.lean`.
- [x] `Syntax/{Star,Minus,Plus}Language/Derivation.lean`: move the "Smoke tests" blocks (9) to a new `Tests/BimodalTest/Syntax/LanguageDerivationTest.lean`, wired into the aggregator. *(measured 8, not 9: 3 TM⋆ + 3 TM⁻ + 2 TM⁺)*
- [x] Propositional `PropForm.lean`/`Decidable.lean`: move the "Smoke Tests" (5) to `Tests/BimodalTest/Metalogic/PropDecideTest.lean`.
- [x] Check that each moved example still elaborates with the test module's imports and `open`s (tactic-scoped syntax may need `open ... in`). Leave everything else, which is documentation or design-premise pins.
- [x] Build the touched library modules and test modules (guarded), then run the harness `--no-build` (C17 and C20 reported).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: about 117 examples across 8 library files (72+3+26+5+9+5 with placeholders counted separately). Confirm each section's live count by grep before moving. If a section is not clearly test-labelled in the source, leave it and note why.

**Files to modify**:
- the 8 library files above - remove test sections
- `Tests/BimodalTest/Automation/{TacticsTest,NormalizationTest}.lean`, `Tests/BimodalTest/ProofSystem/DerivationTest.lean`, `Tests/BimodalTest/Metalogic/PropDecideTest.lean` - add examples
- `Tests/BimodalTest/Syntax/LanguageDerivationTest.lean` - new; `Tests/BimodalTest.lean` - import

**Verification**:
- All touched modules build green. Harness `--no-build` passes.

---

### Phase 8: Testing standards note and final full gate [COMPLETED]

**Goal**: Document the placement policy and confirm every acceptance criterion on the complete gate set.

**Tasks**:
- [x] Add a "What may stay in the library" subsection to `docs/development/TESTING_STANDARDS.md`: documentation pins and design-premise regression `example`s may stay, and executable probes go to `Tests/`. Cross-reference C27 and the allowlist.
- [x] Update any Tests README listings (`Tests/BimodalTest/Automation/README.md`, `Syntax/README.md`, a Metalogic README if present) for the new modules. *(no Metalogic test README exists; the new Metalogic modules were listed in `Tests/BimodalTest/README.md` instead. `--emit-inventory` also refreshed the three generated line-count blocks the relocations made stale)*
- [x] Run a detached, guarded `lake build`, then `lake build BimodalTest`, then the full `bash scripts/check-module-invariants.sh`, all green.
- [x] Confirm the final census: C27 reports only the MainResults entry (or the documented Phase 6 fallback set), and a raw grep of live directives minus commented usage blocks equals the allowlist total. *(raw line-anchored grep 88 = 54 live (allowlist total) + 34 in comments; the 5 stale commented duplicates in Deterministic/Completeness.lean were removed)*
- [x] Run `bash .claude/scripts/check-task-references.sh` (or the repo's equivalent) over the new files, and confirm no task-number citations. *(the repo-equivalent gate is harness C9, which passed; the `.claude` script scans agent-system trees only and also passed)*

**Timing**: 1 hour

**Depends on**: 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Files to modify**:
- `docs/development/TESTING_STANDARDS.md` - placement subsection
- test-suite README files - module listings

**Verification**:
- The acceptance bar holds: `lake build` green, test suite green, C27 passes and is documented in the harness header, and every remaining in-library `#check`/`#eval`/`#print` line is allowlisted with a reason.

## Lean Challenge Statements

None. This plan introduces no new theorem or definition: it relocates probes, converts non-asserting evaluations to guards, and edits a harness baseline. The identifier set named under **Goals** is correspondingly empty.

## Testing & Validation

- [x] `lake build` (detached, guarded) green
- [x] `lake build BimodalTest` (detached, guarded) green, including all new and extended test modules
- [x] Full `bash scripts/check-module-invariants.sh` green, including C1, C2, C14 (both halves), C17 (reported), C20, C21 and C27
- [x] C27 fixture self-test passes, and an injected stray `#eval` in a scratch copy makes C27 fail
- [x] Each converted `#guard` fails when its expected value is deliberately perturbed (spot-check one per new module)
- [x] `scripts/debug-artifact-allowlist.txt` reduced to MainResults (or the documented fallback), every entry with a reason line

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` (C27, C26/C27 header lines, C14 baseline extension)
- `scripts/debug-artifact-allowlist.txt` (new)
- `docs/development/MODULE_INVARIANTS.md`, `docs/development/TESTING_STANDARDS.md`
- New test modules: `Tests/BimodalTest/Automation/DatasetGeneratorTest.lean`, `Tests/BimodalTest/Metalogic/Decidability/SaturationTest.lean`, `Tests/BimodalTest/Metalogic/Decidability/Verified/{TerminationProbes,BridgeProbes}.lean`, `Tests/BimodalTest/Metalogic/Decidability/BiLassoTest.lean`, `Tests/BimodalTest/Syntax/LanguageDerivationTest.lean`
- Extended test modules: `FormulaTest.lean`, `NormalizationTest.lean`, `TacticsTest.lean`, `DerivationTest.lean`, `PropDecideTest.lean`
- About 30 library files with probes removed
- `specs/594_relocate_in_library_smoke_tests/summaries/01_relocate-smoke-tests-summary.md`

## Rollback/Contingency

Each phase commits independently on green, so a failed phase can be reverted with `git revert` of
its own commits without touching the others. The seeded allowlist makes a partial state valid: if a
relocation phase cannot finish, restore that file's directives and its allowlist entry, and C27
stays green. Phase 6 has an explicit in-phase fallback: allowlist the 7 class-B files. If a genuine
working-tree rollback of uncommitted work is ever needed, follow `context/contracts/recovery.md`'s
rollback rung for the snapshot invocation. Do not take routine precautionary snapshots.
