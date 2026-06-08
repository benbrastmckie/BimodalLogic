# Implementation Plan: Task #284

- **Task**: 284 - Reduce c5 timeouts via hybrid proof-pool labeling and extended structural prefilter
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Tasks 265, 274, 277, 278, 279 (all completed)
- **Research Inputs**: specs/284_timeout_reduction_c5_hybrid_prefilter/reports/01_timeout_analysis_and_strategy.md
- **Artifacts**: plans/01_hybrid-prefilter-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Post-task-278 c5 dataset regeneration produces 1,156 timeouts (19.2%) out of 6,031 formulas. These timeouts are distributed across many formula shapes -- primarily implication-rooted formulas with nested Until/Since at temporal depth 2 -- and cannot be eliminated by lowering the timeout alone. This plan implements two complementary strategies: (1) wire the existing proof-pool hybrid labeling mode from task 279 into the dataset export pipeline so that valid formulas are caught by O(1) pool lookup before invoking the tableau, and (2) extend the structural prefilter with new temporal implication patterns (U(atom,X) -> U(Y,Z) and analogues) that dominate the timeout population. Together these should reduce the timeout count from ~1,156 to under 500 without modifying the decision procedure.

### Research Integration

Key findings from the research report (01_timeout_analysis_and_strategy.md):
- 1,156 timeouts (19.2%) at c5, 90% implication-shaped, 72% containing U/S, 93% at temporal depth 2
- Existing prefilter handles 94/103 valid formulas (91%); only 9 valid formulas escape to the decision procedure
- The dominant timeout shape is `U(atom, X) -> U(Y, Z)` (~800 formulas)
- Strategy C (proof-pool hybrid) and Strategy D (extended prefilter) are recommended
- Strategy E (tableau memoization) is deferred to task 289

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Wire proof-pool hybrid labeling into the dataset export pipeline (DatasetExport.lean)
- Extend the structural prefilter with temporal implication patterns that catch timeout-dominant shapes
- Reduce c5 timeout count from 1,156 to under 500 (target: 50% reduction or better)
- Preserve zero false-positive guarantee (no misclassification of invalid formulas as valid)
- Maintain full backward compatibility (default behavior unchanged without explicit flags)

**Non-Goals**:
- Modifying the core tableau decision procedure (DecisionProcedure.lean) -- deferred to task 289
- Achieving zero timeouts (some formulas are genuinely hard for the current prover)
- Extending to complexity levels beyond c5 (though improvements will generalize)
- Formal proof that new prefilter patterns are sound (structural arguments sufficient for O(n) syntactic checks)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Proof pool hits few timeout formulas | M | M | Pool is O(1) lookup; measure hit rate before and after; hybrid mode falls through to tableau for misses |
| New prefilter patterns produce false positives | H | L | Validate patterns on full c5 corpus before enabling; run before/after regression check on valid/invalid label distribution |
| Pool generation is too slow for CI | L | L | Pool generation is a one-time cost; cache the pool to a file for reuse |
| labelBatch does not propagate mode/pool | M | M | Phase 1 wires mode and pool through all call paths; integration tests verify |
| Build regressions from new imports | L | L | Incremental lake build after each phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Wire Proof-Pool Hybrid Mode into DatasetExport Pipeline [COMPLETED]

**Goal**: Enable the existing `GenerationMode.hybrid` code path to be invoked from the dataset export CLI, so that formulas are checked against a pre-generated proof pool before falling through to the tableau.

**Tasks**:
- [x] Add `--generation-mode` CLI flag to `DatasetExport.lean` accepting `exhaustive|proofFirst|hybrid` (default: `exhaustive`)
- [x] Add `--pool-depth` CLI flag to `DatasetExport.lean` (default: 2) controlling proof pool generation depth
- [x] Add `--pool-seeds` CLI flag to `DatasetExport.lean` (default: 10000) controlling number of pool seeds
- [x] When `--generation-mode hybrid` or `proofFirst` is specified, call `generateProofPool` from `ForwardProofGenerator.lean` with the configured depth and seed count at pipeline startup *(deviation: altered -- used `forwardGenerate` directly instead of a separate `generateProofPool` wrapper, since forwardGenerate already implements the full pool generation algorithm)*
- [x] Pass the generated `ProofPool` and `GenerationMode` through to `labelFormula` calls in the per-formula labeling loop (lines ~1085 and ~1135 in DatasetExport.lean)
- [x] Update `labelBatch` in `DatasetGenerator.lean` to accept optional `mode : GenerationMode` and `proofFirstPool : Option (ProofPool .Base)` parameters, propagating them to each `labelFormula` call
- [x] Add `generation_mode` field to the JSONL output metadata (per-record or header) so downstream consumers know which mode produced the labels
- [x] Add 3 `#eval` smoke tests: one verifying pool generation returns a non-empty pool, one verifying `labelFormula` with `.hybrid` mode and a pool hits a known valid formula, one verifying fallthrough to tableau for an unknown formula

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add CLI flags and pool generation at startup
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Extend `labelBatch` signature to accept mode and pool

**Verification**:
- `lake build` passes with no new errors
- `#eval` smoke tests confirm pool generation, hybrid hit, and fallthrough behavior
- Running with `--generation-mode exhaustive` produces identical output to the current default

---

### Phase 2: Extend Structural Prefilter with Temporal Implication Patterns [COMPLETED]

**Goal**: Add new structural prefilter rules that catch the dominant timeout pattern class (`U(atom, X) -> U(Y, Z)` and analogues) identified by the research report. These are O(n) syntactic checks that short-circuit the decision procedure for formulas matching known-valid or known-invalid shapes.

**Tasks**:
- [x] Analyze the `U(atom, X) -> U(Y, Z)` pattern formally: determine if all instances are valid, all invalid, or mixed. Use small `#eval` tests with `decideAutoAdaptive` on representative instances (e.g., `U(p, q) -> U(r, s)`, `U(p, q) -> U(p, q)`) to classify *(result: MIXED -- identity valid, different atoms invalid, U(X,Y)->F(Y) valid)*
- [ ] If the pattern is always valid: add `structural_temporal_implication_valid` rule to `structuralPrefilterWithAxiom` in `DatasetGenerator.lean` *(deviation: skipped -- pattern is mixed, not always valid)*
- [ ] If the pattern is always invalid: add `structural_temporal_implication_invalid` rule *(deviation: skipped -- pattern is mixed, not always invalid)*
- [x] If the pattern is mixed: identify the valid subset (e.g., `U(p, X) -> U(p, Y)` where the event is shared) and add rules for the provably-decidable subset only *(added structural_identity, structural_until_implies_future, structural_since_implies_past)*
- [x] Repeat analysis for `S(atom, X) -> S(Y, Z)` (Since variant) and add corresponding rules *(same mixed pattern; added structural_since_implies_past)*
- [x] Add subsumption rule: `U(X, Y) -> U(X, Y)` is trivially valid (identity), catch this directly *(added structural_identity check at top of structuralPrefilterWithAxiom)*
- [x] Add temporal reflexivity: `F(X) -> F(X)`, `G(X) -> G(X)`, `P(X) -> P(X)`, `H(X) -> H(X)` as prefilter shortcuts *(all caught by structural_identity since a == b; verified with tests)*
- [x] Add box-temporal interaction: `box(G(X)) -> G(X)` and `box(H(X)) -> H(X)` as valid (S5 reflexivity + temporal unfolding) *(deviation: skipped -- already caught by isSubsumptionPattern as structural_subsumption_modal_t)*
- [x] Add 8+ `#eval` tests for new patterns with expected results (true/false/none) *(added 8 tests: 3 positive hits, 5 negative/existing)*
- [ ] Run `structuralPrefilterWithAxiom` over the full c5 formula list (via `#eval` on a representative batch) and count new hits vs baseline *(deviation: deferred to Phase 3 integration where full c5 corpus is run)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Add new pattern rules to `structuralPrefilterWithAxiom`

**Verification**:
- `lake build` passes
- All new `#eval` tests return expected results
- Zero false positives: no formula currently labeled `invalid` is now labeled `valid` by the new rules
- New prefilter hit count on c5 > 50 (measurable improvement over baseline 94)

---

### Phase 3: Integration and c5 Regeneration [NOT STARTED]

**Goal**: Combine both strategies (hybrid pool + extended prefilter), regenerate the c5 dataset, and measure the combined timeout reduction.

**Tasks**:
- [ ] Generate a proof pool at depth 2 with 10,000 seeds over atoms {p, q, r} and verify pool size
- [ ] Run full c5 dataset generation with `--generation-mode hybrid` and measure: new timeout count, pool hit rate, prefilter hit count, total time
- [ ] Run full c5 dataset generation with `--generation-mode exhaustive` (baseline) to verify the extended prefilter alone produces improvement
- [ ] Compare results:
  - Baseline timeout count (should be ~1,156)
  - Extended prefilter only: new timeout count and prefilter hit count
  - Hybrid mode: new timeout count, pool hit count, prefilter hit count
- [ ] Verify no label regressions: every formula that was `valid` before is still `valid`, every formula that was `invalid` before is still `invalid`
- [ ] Record decision method distribution (fast_path_axiom, structural_prefilter, proof_pool_hit, adaptive_500, wallclock_timeout) in a comparison table
- [ ] If timeout reduction is < 20%, investigate: are the timeout formulas genuinely hard (mixed validity in the dominant pattern class), or did the pool miss them?

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to modify**:
- No new files; this phase uses the CLI built in Phase 1 with the prefilter from Phase 2

**Verification**:
- Timeout count is measurably lower than baseline 1,156
- Zero label regressions (valid stays valid, invalid stays invalid)
- Decision method distribution shows proof_pool_hit and structural_prefilter contributions
- `lake build` passes

---

### Phase 4: Documentation and Test Cleanup [NOT STARTED]

**Goal**: Add inline documentation, update module headers, and ensure all new code is tested.

**Tasks**:
- [ ] Add docstrings to all new CLI flags in `DatasetExport.lean`
- [ ] Add docstrings to new prefilter patterns in `DatasetGenerator.lean` explaining the structural reasoning
- [ ] Update the module header comment in `DatasetGenerator.lean` to mention the extended prefilter patterns
- [ ] Verify all `#eval` tests from Phases 1 and 2 are retained and pass
- [ ] Run `lake build` as final verification
- [ ] Record the final timeout count and pool/prefilter hit rates as comments in `DatasetGenerator.lean` for future reference

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Docstrings and comments
- `Theories/Bimodal/Automation/DatasetExport.lean` - Docstrings

**Verification**:
- `lake build` passes with zero errors
- All `#eval` tests pass
- Module headers are accurate

## Testing & Validation

- [ ] `lake build` passes after each phase with zero new errors
- [ ] All existing `#eval` tests in `DatasetGenerator.lean` continue to pass
- [ ] New `#eval` smoke tests for proof pool generation, hybrid mode dispatch, and prefilter patterns all pass
- [ ] c5 regeneration with hybrid mode produces strictly fewer timeouts than baseline
- [ ] No label regressions: cross-check that valid/invalid labels are preserved for all non-timeout formulas
- [ ] Decision method distribution includes new categories (proof_pool_hit if applicable)

## Artifacts & Outputs

- `specs/284_timeout_reduction_c5_hybrid_prefilter/plans/01_hybrid-prefilter-plan.md` (this file)
- `specs/284_timeout_reduction_c5_hybrid_prefilter/summaries/01_hybrid-prefilter-summary.md` (on completion)
- Modified files: `DatasetGenerator.lean`, `DatasetExport.lean`

## Rollback/Contingency

All changes are additive: new CLI flags default to existing behavior (`--generation-mode exhaustive`), and new prefilter patterns only add new match arms to the existing `structuralPrefilterWithAxiom` function. To revert:

1. Remove new match arms from `structuralPrefilterWithAxiom` (Phase 2 changes)
2. Remove `--generation-mode`, `--pool-depth`, `--pool-seeds` flags from `DatasetExport.lean` (Phase 1 changes)
3. Revert `labelBatch` signature to original (Phase 1 changes)
4. `lake build` to verify clean revert

No changes to the core decision procedure, axiom definitions, or proof system.
