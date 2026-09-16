# Research Report: Task #594

**Task**: 594 - Relocate in-library smoke tests
**Started**: 2026-09-16T16:44:30Z
**Completed**: 2026-09-16T16:49:40Z
**Effort**: 6-10 hours implementation (5-6 phases; mostly mechanical once the classification below is adopted)
**Dependencies**: None upstream. Downstream: the zero-occurrence declaration triage (C17 census) must run after this task
**Sources/Inputs**: - Codebase: `FormalSystem/**/*.lean` (Boneyard excluded), `Tests/BimodalTest/**`, `Tests/BimodalTest.lean`, `lakefile.lean`
- Harness: `scripts/check-module-invariants.sh` (C1, C2, C14, C17, C20, C26), `scripts/nolint-attribute-allowlist.txt`, `docs/development/MODULE_INVARIANTS.md`, `docs/development/TESTING_STANDARDS.md`
- cslib reference: `~/Projects/cslib/scripts/pre-pr-check.sh` (debug-artifact check, step 2)
- Measurement: a comment-aware Python scanner (nested `/- -/` and `--` masking), plus `lake env lean` runs of 6 affected files to capture actual `#eval` output and elaboration time
- No Mathlib search tools needed (this is a relocation task; no new lemmas required)
**Artifacts**: - specs/594_relocate_in_library_smoke_tests/reports/01_relocate-smoke-tests.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Re-measured census matches the task description** (404 line-anchored `#check`/`#eval`/`#print` lines, 29 files; 389 column-0 `example`s outside `FormalSystem/Examples/`), but **39 of the 404 sit inside doc comments** (usage code blocks in 9 files). The live figure is **365 directives in 22 files**. There are zero `dbg_trace`/`#reduce`.
- The 365 live directives fall into four classes: **(A)** `MainResults.lean` audit page, 54, keep. **(B)** `#print axioms` in 7 Metalogic files, 19. 12 already duplicate C2/C14 baselines and 7 are unpinned. **(C)** `#guard_msgs in #eval` probes, 56: they already assert, so they are test-shaped and move verbatim. **(D)** bare `#eval`/`#check`, 236: test-shaped but **assert nothing**, so they move and become `#guard`s.
- **Every class-D `#eval` was run** (`lake env lean`). No `FAIL` output anywhere. One comment/behaviour drift turned up: `Normalization.lean`'s "foldFormula on or" row says `-- should show or_ ...`, but it actually prints `imp (neg p) q`. That is the risk of non-asserting `#eval`s, so the relocated `#guard`s must pin the observed behaviour, not the comment.
- **All functions under test are public.** The `private` names involved are only local fixtures (`pTest`, `probeFGp`, `chainBranch`, `dualCheck`, `stabilisesAt`, ...) and move with their rows. One exception: `branchingWitnessArity` (Measure.lean) is used by the in-library theorem `branchingWitness_splits`, so it stays. Its arity `#eval` is subsumed by that `decide` theorem and can be deleted.
- **Recommended invariant**: new **C27**, a comment-aware textual scan of live `FormalSystem/` for `^\s*(#check|#eval|#print|#reduce|dbg_trace)\b` (plus `dbgTrace`). It uses a per-file **exact-count** allowlist `scripts/debug-artifact-allowlist.txt` (format `path count # reason`), enforced from its first run (`ENFORCE_C27=1`). After relocation the only entry is `FormalSystem/MainResults.lean 54`.
- **Recommended handling of class B**: pin the 7 unpinned declarations in the C14 baseline pair, then delete all 19 in-file directives. This follows the harness's own precedent (the C14 comment block already records moving in-file `#print axioms` into the baseline as "a stronger guarantee"). The alternative is to allowlist the files.

## Context & Scope

The task: relocate test-shaped debug directives out of the live library, keep `MainResults.lean`, and add a debug-artifact invariant with an allowlist. Acceptance names only `#check`/`#eval`/`#print`. The 389 `example`s are in the description's census, but no invariant covers them. `example` is not a debug artifact in cslib's check. The recommendation for examples below is therefore scoped conservatively.

Constraints found:
- `lake build` (C1 half 1) builds only `FormalSystem`. C1 half 2 also runs `lake build BimodalTest`, so relocated probes still fail the **harness** gate on drift, but no longer fail a bare `lake build`. Several probe sections say they exist "so a silent change fails the build". Their prose must be updated to say the test suite instead.
- A new test module must be imported by `Tests/BimodalTest.lean` or listed in `scripts/module-invariants-manifest.txt`. The aggregator docstring says the harness fails on a module absent from both.
- C17 counts every occurrence, including `#check @foo`, across `FormalSystem/` and `Tests/`. Moving a row into `Tests/` keeps its occurrences. Deleting it removes them. See Decisions.
- C20 tier 1 gates `file.lean:NNN` citations that go out of range or land on a blank line. Relocation shifts line numbers in Saturation.lean (5 inbound citations, e.g. `Saturation.lean:360-364` in Fuel.lean) and BranchOrder.lean (2). Syntax/Formula.lean may also be affected: 27 `Formula.lean:NNN` citations exist tree-wide, some pointing at other `Formula.lean` files. The removed Saturation probes are all below line 1250, so the `:360`/`:646`/`:675` citations are unaffected. C20 must still be re-run.

## Findings

### Codebase Patterns

**Census (live = outside comments; Boneyard excluded)**

| File | Live lines | Kind | Class |
|------|-----------:|------|-------|
| Automation/DatasetGenerator.lean | 116 | bare `#eval` (108 pure prefilter rows, lines 974-1245; 8 `IO Unit` "[test] PASS/FAIL" smoke tests, lines 2022-2269) | D |
| Metalogic/Decidability/Saturation.lean | 59 | 48 bare `#eval do ... return "PASS/FAIL ..."`; 11 `#guard_msgs` (ArmSettlingProbes, BudgetedTableauProbes) | D + C |
| MainResults.lean | 54 | 27 `#check` + 27 `#print axioms` | A (keep) |
| Automation/Normalization.lean | 42 | 17 `#check @*_unfold`; 25 bare `#eval` (FoldTests, SerializationTests, round-trip census) | D |
| Syntax/Formula.lean | 20 | bare `#eval ... .complexity -- N` (3 blocks, `private` fixtures `pCmplx*`) | D |
| Verified/Termination/TimeTypeBound.lean | 12 | `#guard_msgs` Stabilisation probes | C |
| Verified/Termination/Fuel.lean | 11 | `#guard_msgs` WorldProbes, DualityProbes, SplitFuelProbes | C |
| Verified/Termination/MintBound/PostBlocking.lean | 7 | `#guard_msgs` PostBlockingRunProbe | C |
| Verified/Bridge/BranchOrder.lean | 7 | `#guard_msgs` regression Probes | C |
| Automation/FormulaEnumerator.lean | 6 | bare `#eval` counts/membership (+2 in-library `#guard`) | D |
| Decidability/BiLasso/Examples.lean | 4 | bare `#eval` enumeration counts | D |
| Decidability/BiLasso/Successor.lean | 4 | `#guard_msgs` Computation | C |
| Verified/Termination/MintBound/Measure.lean | 2 | `#guard_msgs` BranchingNonVacuity | C |
| Verified/Bridge/Embed.lean, IntGaps.lean | 1 + 1 | identical `#guard_msgs` row `(List.finRange 4).map (finOrderEmbInt 4)` | C |
| Metalogic/Deterministic/Completeness.lean | 5 | `#print axioms` (unpinned) | B |
| Metalogic/BXCanonical/Completeness.lean | 5 | `#print axioms` (all 4 names pinned by C2; `completeness` printed twice) | B |
| Metalogic/BXCanonical/CompletenessDedekind.lean | 4 | `#print axioms` (2 pinned by C14; `real_lub_of_bddAbove`, `dedekind_box_dense_mem` unpinned) | B |
| Metalogic/Compactness.lean | 2 | `#print axioms` (pinned by C14) | B |
| Metalogic/StrongCompleteness.lean, DiscreteNonCompactness.lean, DedekindNonCompactness.lean | 1 each | `#print axioms` (pinned by C14) | B |
| **Total** | **365** | | |

Totals by class: A = 54, B = 19, C = 56, D = 236.

**Commented (documentation-shaped, stay; 39 lines)**: usage code blocks in module or declaration docstrings. The files are `Automation/Tactics/UserTactics.lean` 12, `Theorems.lean` 6, `Deterministic/Completeness.lean` 5 (stale: a "re-checkable by uncommenting" copy of the live block directly below it), `Semantics/PlusDeterminism.lean` 4, `Semantics.lean` 3, `Metalogic/Decidability.lean` 3, `Independence/DeterminismUndefinable.lean` 3, `BXCanonical/Completeness.lean` 2, and `FormalSystem.lean` 1.

**Observed `#eval` output (via `lake env lean`, all exit 0)**:
- Syntax/Formula.lean: 20 values, all equal to their trailing `-- N` comment (2,2,2,2,3,3,3 / 3,3,3,3,4,4 / 2 x7). Elaboration takes 4 s.
- FormulaEnumerator.lean: `7852`, `75914`, `45111`, `true` x3. Takes 7 s.
- BiLasso/Examples.lean: `6`, `2`, `36`, `1872`. Takes 17 s, most of it the `n = 2` annotated enumeration, which the docstring already flags as about 10 s.
- Saturation.lean: 47 `"PASS ..."` strings plus one `"INFO E5: G(p) -> p is invalid (strict reading)"`, no FAIL. Takes 3 s.
- DatasetGenerator.lean: 21 pure rows, which the report checked against their comments, plus 8 IO tests printing `[test] PASS` with no FAIL. Takes 4 s.
- Normalization.lean: the 17 `#check`s print signatures. Of the fold rows, all match their comments except **`foldFormula` on `or`**, which prints `imp (neg (atom p)) (atom q)` although the comment says `or_ (atom ...) (atom ...)`. The round-trip census prints `"Round-trip test: ALL PASS (21 formulas tested)"`. Takes 2 s.

**Visibility**: none of the target modules uses the Lean `module` system, so plain `import` gives tests access to all public declarations. Every function under test is a public `def`: `witnessPresent`, `allocateFuelProportionally`, `closureStep`, `subformulasFinset`, `saturateBlocked`, `findUnexpandedUnblockedWith`, `blockedTimes`, `armTracker`, `branchOrderValid`, `timeOrderTotal`, `finOrderEmbInt`, `succOf`, `boundedBiLassos`, `boundedAnnots`, `enumExactHelper`, `buildTableau*`, `structural*Prefilter*`, `labelFormula`, `foldFormula*`, `toEnrichedJson`, and the others. `EnrichedFormula` derives `BEq`, so `#guard f.foldFormula == ...` works. `SimpleCountermodel` derives only `Repr`, so compare its projected fields instead.

**Importability**: every target module is already imported by some test (for example `C5SmokeTest` imports DatasetGenerator, and `TraceCertificateTest` imports Saturation). None defines `main`, so the aggregator's "environment already contains 'main'" hazard does not apply.

**Cross-references that must be updated on move**:
- `Verified/Termination/MintBound/Register.lean:815` and `:828` cite `postBlockingRunProbe`'s `#guard_msgs` rows and "`branchingWitness`'s non-vacuity `#eval` in section C7".
- The C14 comment in `scripts/check-module-invariants.sh` (about line 1350) says "Exactly five in-file directives remain". It is already stale (19 remain) and must be rewritten.
- `DiscreteNonCompactness.lean:305` and `DedekindNonCompactness.lean:507` docstrings each say their `#print axioms` is "the only in-file directive this module keeps".
- Probe-section docstrings that promise "fails the build": `BranchOrder.lean` Regression probes, `Embed.lean`/`IntGaps.lean` Sanity checks, `Fuel.lean` probes, `TimeTypeBound.lean` Stabilisation probes.
- The harness header lists C1-C25 plus C9D but **omits C26**, although C26 is implemented (about line 2994) and documented in `MODULE_INVARIANTS.md`. Fix this while adding C27.

### External Resources

- cslib `pre-pr-check.sh` step 2 uses `grep -rnE '^[[:space:]]*(#check|#eval|dbg_trace)\b'`. That is line-anchored and **not** comment-aware, and it does not include `#print`. A comment-aware C27 is therefore slightly looser than cslib on docstring code blocks and stricter in adding `#print`/`#reduce`. When code is ported to cslib, a docstring usage block starting with `#check` would still trip cslib's grep. Note this in C27's header.
- `docs/development/TESTING_STANDARDS.md` already prescribes `#guard <Bool>` as the unit-test idiom, which supports converting class D to `#guard`.

### Recommendations

Target test modules (new files marked *new*; each must be added to `Tests/BimodalTest.lean`):

| Source | Destination | Conversion |
|--------|-------------|------------|
| Syntax/Formula.lean (20) | `Syntax/FormulaTest.lean` | `#guard (Formula.release p q).complexity == 3` etc. (values verified) |
| Automation/Normalization.lean (17 `#check`, 25 `#eval`) | `Automation/NormalizationTest.lean` | `#check @x_unfold` becomes `example` uses or stays as `#check` in Tests (Tests are out of C27 scope); fold rows become `#guard ... == EnrichedFormula...`, pinning **observed** `or` behaviour and fixing the stale comment; JSON/SExpr/pretty rows become `#guard ... == "..."` |
| Automation/DatasetGenerator.lean (108 pure) | *new* `Automation/DatasetGeneratorTest.lean` | `#guard isUnsatBotTemporal (...) == true`, `#guard structuralPrefilterWithAxiom (...) == some (true, "...")` |
| Automation/DatasetGenerator.lean (8 IO) | same file | `#eval show IO Unit from do ... unless ok do throw (IO.userError "...")`; a thrown error fails elaboration, so the test actually asserts. Keep them in one `section` so they can later go to a benchmark module if too slow |
| Automation/FormulaEnumerator.lean (6 `#eval` + 2 `#guard`) | *new* `Automation/FormulaEnumeratorTest.lean` (or `NormalizationTest`, which already imports FormulaEnumerator) | `#guard (enumExactHelper defaultAtoms 2 2 4 {}).1.size == 7852`, and similarly for 75914 and 45111 |
| Decidability/Saturation.lean (48 bare + 11 guarded) | *new* `Metalogic/Decidability/SaturationTest.lean` | bare `return "PASS/FAIL"` blocks become `#guard` over the `Bool` condition; guarded rows move verbatim with fixtures `probeFGp`/`probeNGFp`/`probeUpq`/`armProbe`/`armDisagreement` |
| Verified/Termination/{TimeTypeBound,Fuel}.lean, MintBound/PostBlocking.lean | *new* `Metalogic/Decidability/Verified/TerminationProbes.lean` (or one file per source) | verbatim `#guard_msgs in #eval` plus their private fixtures (`stabilisesAt`, `probeAtom`, `probeGapBody`, `dualCheck`, `postBlockingRunProbe`) |
| MintBound/Measure.lean (2) | same as above | delete the `branchingWitnessArity` `#eval` (subsumed by `theorem branchingWitness_splits ... := by decide`); move the `expandBranchWithFuel branchingWitness 500` row (`branchingWitness` is public) |
| Verified/Bridge/{BranchOrder,Embed,IntGaps}.lean | *new* `Metalogic/Decidability/Verified/BridgeProbes.lean` | verbatim; merge the duplicated `finOrderEmbInt 4` row into one |
| BiLasso/{Successor,Examples}.lean (4 + 4) | *new* `Metalogic/Decidability/BiLassoTest.lean` | Successor rows verbatim; Examples counts become `#guard ... .length == 6/2/36/1872`. Moving the in-library `#guard decide` rows (Examples 4, Check 3) is optional because `#guard` is not a C27 target |
| Class B (19) | C14 baseline pair | append the 7 unpinned names to both C14 heredocs (`C14BASE` and `C14LEAN`, same order), then delete all 19 in-file directives and rewrite the prose that referenced them |
| Class A (54) | stays | allowlisted |

The first `lake build BimodalTest` after moving rows verbatim (`#guard_msgs` classes) re-verifies them automatically. Class-D conversions should be checked by `lake build BimodalTest`, run detached and guarded per `long-builds.md`.

**C27 specification (sketch)**:
- Scope: live `FormalSystem/**/*.lean`, using the same Boneyard-pruning walk as C26. It reads source text only, so it runs under `--no-build`.
- Match: `^\s*(#check|#eval|#print|#reduce)\b` and `\bdbg_trace\b|\bdbgTrace\b`, after masking nested block comments, docstrings and line comments.
- Allowlist: `scripts/debug-artifact-allowlist.txt`, one entry per file as `<path> <exact live count>`, each preceded by a `#` reason comment. Use the same admission-bar preamble style as `nolint-attribute-allowlist.txt`. Fail on an unlisted file, fail on a count mismatch in either direction, and report stale entries (so the file cannot rot).
- Initial content, if class B goes to C14: `FormalSystem/MainResults.lean 54`, with the reason "intentional axiom-audit page; C21 asserts every name is pinned by C2/C14".
- Wiring: `ENFORCE_C27=${ENFORCE_C27:-1}`, a header line, a companion-file line in the header, and a row in `docs/development/MODULE_INVARIANTS.md`'s check table.

**Examples (389 raw / 366 live)**: no gate requires moving them. For scope control, relocate only the sections that are explicitly test-labelled, about 110 examples:
- `Automation/Tactics/Commands.lean` (72 live `modal_search` "Test N" examples) goes to `Automation/TacticsTest.lean`. Delete its three `example : True := trivial` placeholders.
- `Automation/Normalization.lean` UnfoldTests and RoundTripTests (26) go to `NormalizationTest.lean`.
- `ProofSystem/Derivable.lean` "Aesop and Simp Test Examples" (5) go to `ProofSystem/DerivationTest.lean`.
- The "Smoke tests" blocks in `Syntax/{Star,Minus,Plus}Language/Derivation.lean` (9) go to a new Syntax test module.
- The Propositional `PropForm.lean`/`Decidable.lean` "Smoke Tests" (5) go to `Metalogic/PropDecideTest.lean`.

Keep the remaining examples in place. They are documentation or regression pins stated beside their definitions: `rfl` pins, carrier gates, "Regression guards for the design premise", acceptance checks, worked instances, shape certificates and non-vacuity witnesses. They are not debug artifacts, and moving them would separate a design invariant from the definition it guards. A sorry-free path exists for every move: nothing here involves new proofs.

## Decisions

- The live count (365) is the working number, not 404. Commented usage blocks are documentation-shaped and survive untouched. C27 is comment-aware so they need no allowlist entries.
- `#guard_msgs in #eval` rows count as test-shaped. They move verbatim to preserve exact pinned output.
- Bare `#eval`s become asserting `#guard`s (or throwing `IO` tests) on relocation. A verbatim move would carry non-asserting output into the test suite.
- Relocated `#check @x_unfold` rows go to `NormalizationTest.lean` instead of being deleted. This keeps C17 occurrences stable during this task, so the later zero-occurrence triage decides on a clean census.
- No task numbers go in any new module docstring (C9). Note that the existing `NormalizationTest.lean` docstring already says "(Task 287)" under `Tests/`, which C9 does not scan.

## Risks & Mitigations

- **Build-failure guarantee weakens to a test-suite guarantee.** A bare `lake build` no longer catches probe drift. Mitigation: C1 already runs `lake build BimodalTest`. Update the probe prose to name the test module, and name the relocation target in a one-line pointer where the section used to be, if the owners want the breadcrumb.
- **C14 baseline edits need a build to verify** (the C14 `.lean` half is skipped under `--no-build`). Mitigation: capture the 7 new baseline lines from a real `#print axioms` run against built oleans, and never hand-type them. If this is judged out of scope, allowlist the 7 class-B files with exact counts instead. That is still a valid C27 end state.
- **C20 line-shift breakage** in Saturation.lean and BranchOrder.lean citations. Mitigation: run `bash scripts/check-module-invariants.sh --no-build` after each file's excision, and repoint any `file.lean:NNN` to a declaration name, which is also what C20 tier 2 prefers.
- **Test-suite runtime** grows by the moved enumerations: FormulaEnumerator c5 about 7 s and BiLasso `n = 2` annotations about 15 s. Mitigation: acceptable at the current suite size. If not, place the two slowest rows in a manifest-listed, aggregator-excluded module the way `DerivationBenchmark.lean` is.
- **`#guard` on the `IO` smoke tests** is impossible (they are `IO`). Mitigation: use throwing `#eval show IO Unit` in Tests, which C27 does not scan.
- **Comment-masking false negatives in C27**: a naive masker can mis-track string or char-literal state (observed once during this research). Mitigation: C27 cross-checks its live count against the raw line-anchored grep minus the masked lines, and ships with a self-test fixture, as B0 does for the Boneyard filter.
- **Private-fixture name clashes** when several sources merge into one test module (for example `p`/`q` in Saturation versus `pTest`). Mitigation: one `namespace BimodalTest.<Area>.<Module>Test` per source section, matching the existing `NormalizationTest` convention.

## Tactic Survey Results

- Not applicable (no tactic survey performed): the task needs no new proofs. The equivalent verification step was running `lake env lean` on the 6 files with bare `#eval`s to capture the actual values the new `#guard`s must pin (see Findings).

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| Capture observed `#eval` values for `#guard` conversion | `lake env lean <file>` | success (6/6 exit 0, no FAIL output) | 2-17 s per file |

## Context Extension Recommendations

- **Topic**: in-library test/probe placement policy
- **Gap**: `docs/development/TESTING_STANDARDS.md` prescribes `#guard` in tests but never says where probes may live. Four different in-library conventions exist today (bare `#eval`, `#guard_msgs`, `#guard`, `example` pins).
- **Recommendation**: add a short "What may stay in the library" subsection (documentation pins and design-premise regression `example`s may stay; executable probes go to `Tests/`) and cross-reference C27.

## Appendix

- Scanner: line-anchored regex plus nested block-comment masking, over `FormalSystem/` with Boneyard excluded and `FormalSystem/Examples/` excluded for the `example` census.
- The raw grep reproduces the task's figures exactly (404 and 389). The comment-aware scan gives 365 live directives plus 39 commented (365 + 39 = 404), and 366 live examples plus 23 commented. The prototype scanner misclassified one live `#guard` (FormulaEnumerator.lean, second of the two `#guard` rows) as commented. The likely cause is string or char-literal state leaking across lines, so C27's masker needs a fixture test covering `"..."` strings, `'"'` char literals and nested `/- /- -/ -/` before it is trusted.
- The harness's C2 flagship set and the C14 `C14BASE` heredoc were compared against the 19 class-B names. Pinned: 12. Unpinned: `real_lub_of_bddAbove`, `dedekind_box_dense_mem`, `detCompletenessBase`, `detCompletenessDense`, `detCompletenessZTime`, `detCompletenessRTime`, `logicDeterministicEqDeterminedValid`.
