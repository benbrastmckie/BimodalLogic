# Implementation Summary: Task #594

- **Task**: 594 - Relocate in-library smoke tests
- **Status**: [COMPLETED]
- **Started**: 2026-09-16T09:52:00-07:00
- **Completed**: 2026-09-16T11:45:00-07:00
- **Effort**: ~2 hours wall clock (8 phases; most of it serialized builds behind concurrent sessions)
- **Dependencies**: None upstream. Downstream: the zero-occurrence declaration triage (C17 census) can now run
- **Artifacts**: plans/01_relocate-smoke-tests.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Every live test-shaped debug directive in the library was moved to `Tests/BimodalTest/`, and each
bare `#eval` became an asserting `#guard` or a throwing `IO` test that pins the value it actually
produced. A new comment-aware harness check, C27, enforces the split with an exact-count allowlist.
It started at 365 live directive lines in 22 files and was lowered phase by phase to the single
permanent entry `FormalSystem/MainResults.lean 54`. The 19 `#print axioms` directives in Metalogic
files were replaced by the C14 axiom baseline.

## What Changed

- `scripts/check-module-invariants.sh`: added C27 after C26, with `ENFORCE_C27=1` and header lines for C26 (which had been missing) and C27. Also listed both companion allowlists, appended 7 captured lines to both C14 heredocs, and rewrote the stale "Exactly five in-file directives remain" comment.
- `scripts/lib/lean_debug_artifacts.py` (new): a comment/string/char-literal masker with a 22-fixture self-test. C27 runs the self-test before it trusts any count.
- `scripts/debug-artifact-allowlist.txt` (new): the admission bar, the format, and one reasoned entry (MainResults 54).
- `scripts/module-invariants-manifest.txt`: added `BimodalTest.Metalogic.Decidability.BiLassoSuccessorTest`.
- `docs/development/MODULE_INVARIANTS.md`: C27 table row and a companion-file section. `docs/development/TESTING_STANDARDS.md`: new "What May Stay in the Library" subsection.
- New test modules:
  - `Tests/BimodalTest/Automation/DatasetGeneratorTest.lean`: 108 `#guard` plus 8 throwing IO tests.
  - `Tests/BimodalTest/Metalogic/Decidability/SaturationTest.lean`: 48 `#guard` pinning exact verdict strings, plus 11 `#guard_msgs`.
  - `Tests/BimodalTest/Metalogic/Decidability/Verified/TerminationProbes.lean` and `BridgeProbes.lean`.
  - `Tests/BimodalTest/Metalogic/Decidability/BiLassoTest.lean`.
  - `Tests/BimodalTest/Metalogic/Decidability/BiLassoSuccessorTest.lean`: listed in the manifest, not in the aggregator.
  - `Tests/BimodalTest/Syntax/LanguageDerivationTest.lean`.
- Extended test modules:
  - `FormulaTest.lean`: 20 complexity guards.
  - `NormalizationTest.lean`: the unfold checks and examples, fold guards (pinning the observed `or` fold to `imp (neg p) q`), serialization guards, and enumerator counts.
  - `TacticsTest.lean`: the `modal_search` CommandsTests section.
  - `DerivationTest.lean` and `PropDecideTest.lean`.
- 30 library files had their probes removed and replaced with one-line pointers:
  - Syntax/Formula, Normalization, FormulaEnumerator, DatasetGenerator and Saturation.
  - Verified Termination (TimeTypeBound, Fuel, PostBlocking, Measure, Register prose) and Bridge (BranchOrder, Embed, IntGaps).
  - BiLasso Successor and Examples.
  - The 7 class-B Metalogic files.
  - Commands, Derivable, the three `*Language/Derivation.lean` files, PropForm and Decidable.
- `Tests/BimodalTest.lean` imports the 6 aggregator-wired new modules. Test READMEs list them, and `--emit-inventory` refreshed 3 generated line-count blocks.

## Decisions

- C27 landed first, seeded with the tree's own counts, and each relocation phase deleted its own entries. No intermediate commit was unguarded.
- Counts are per line after masking. A directive after an `in` combinator (`#guard_msgs in #eval`) is matched, and `#check_failure` is not.
- Saturation's `return "PASS ..."` rows were pinned to their exact captured string rather than a Bool. A row that switches between two PASS arms, or turns into an INFO arm, now fails.
- Every expected value came from a `lake env lean` capture of the source, taken before the source was cut. Where a row was already cut, the capture ran on the HEAD copy. No value was taken from a comment.

## Plan Deviations

- **Task 1.2** altered: the masker lives in the shared helper `scripts/lib/lean_debug_artifacts.py`. The allowlist parser also fails any entry that has no reason line.
- **Task 2.3** altered: Normalization's UnfoldTests, FoldTests, RoundTripTests and SerializationTests sections moved as whole units. Phase 7's Normalization example move was therefore done in Phase 2. Unfold lemma names are fully qualified in the test because `FormalSystem.Syntax` exports lemmas with the same names.
- **Task 4.2** altered: rows became `#guard (Id.run do ...) == "<captured verdict>"` rather than bare Bool conditions.
- **Task 5.4** altered: the Successor rows went to a separate `BiLassoSuccessorTest.lean` that is listed in the manifest. `BiLasso.Successor` is deliberately outside the build graph, and wiring it into the aggregator would have tripped C6.
- **Task 6.5** altered: the green state was first verified with a guarded full build plus a verbatim run of C14's `.lean` half (113 = 113). The full harness then ran in Phase 8.
- **Task 6.6** skipped: the fallback allowlisting was not needed.
- **Task 7.4** altered: 8 language-derivation smoke examples, not the estimated 9.

## Verification

- Build: Success. Guarded `lake build`: 2660 jobs, green. Guarded `lake build BimodalTest`: 2718 jobs, green.
- Full harness: `bash scripts/check-module-invariants.sh` passed with exit 0 (ALL CHECKS PASSED). C1, C2, C3, C6 (15 manifest modules compile), both halves of C14, C20, C21, C25, C25N, C26 and C27 all passed.
- C27 negative tests on a scratch copy of the tree: an unlisted file, a count mismatch, a stale entry and a missing reason line each FAIL with exit 1.
- Perturbation spot checks: changing one expected value fails elaboration in NormalizationTest, FormulaTest, DatasetGeneratorTest (one `#guard` and one IO test) and SaturationTest.
- Sorry count: 0 (C3 structural inventory is zero; Boneyard excluded)
- Vacuous count: 0 introduced. The one grep hit, `int_domain_universal` in `Examples/TemporalStructures.lean`, predates this task.
- Axiom count: unchanged (no `axiom` added)
- Final census: the raw line-anchored grep finds 88 lines. 54 are live, all in MainResults and all allowlisted. The other 34 are in comments.
- Tests: Passed
- Files verified: Yes

## Impacts

- A bare `lake build` no longer runs these probes; `lake build BimodalTest`, which harness C1 runs, does. Library prose that promised "fails the build" now names the test module.
- C17 occurrences are preserved: the `#check @x_unfold` rows moved rather than being deleted. The zero-occurrence declaration triage can now run on a stable census.
- New debug output in `FormalSystem/` fails C27 unless an allowlist entry with a reason is added.

## Follow-ups

- Concurrent sessions for tasks 591, 595 and 596 were editing the same working tree during this run. Scoped commits stage whole files, so three commits here also swept in other tasks' uncommitted changes:
  - Two one-line docstring hunks in `Tests/BimodalTest.lean` (phases 3 and 4).
  - Task 591's C25N block in `scripts/check-module-invariants.sh` (phase 6).
  - The content is intact in the tree, but those changes appear under this task's commit messages.
- The generic `sorry` census script also reports Boneyard sorries (archived, out of scope).

## References

- specs/594_relocate_in_library_smoke_tests/plans/01_relocate-smoke-tests.md
- specs/594_relocate_in_library_smoke_tests/reports/01_relocate-smoke-tests.md
- docs/development/MODULE_INVARIANTS.md (C27 row and companion section)
- docs/development/TESTING_STANDARDS.md ("What May Stay in the Library")
