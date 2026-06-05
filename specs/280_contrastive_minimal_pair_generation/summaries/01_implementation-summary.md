# Implementation Summary: Task 280 — Contrastive Minimal Pair Generation

## Overview

Extended `Theories/Bimodal/Automation/FormulaMutator.lean` with a single-occurrence mutation engine and ~10 new mutation rules to generate high-signal contrastive minimal pairs for training. All changes are pure automation-layer `def` extensions with zero proof-system impact.

## Phases Completed

### Phase 1: Single-Occurrence Mutation Engine and MutationType Extension [COMPLETED]

- Added `mutateSingleOccurrence (φ : Formula) (transform : Formula → Option Formula) : List (Formula × Nat)` which applies a transformation at exactly one AST node, returning mutants paired with occurrence indices in DFS order.
- Extended `MutationType` inductive with 15 new single-occurrence constructors carrying `Nat` occurrence indices (e.g., `boxToDiamondAtOccurrence`, `flipImplicationAtOccurrence`).
- Verified `mutateSingleOccurrence (.box (.box p)) trySwapBoxDiamond` returns exactly 2 mutants with indices 0 and 1.

### Phase 2: Specific Mutation Functions [COMPLETED]

Implemented the following `try*` transformers:
- `trySwapBoxDiamond` / `trySwapDiamondBox` — primitive pattern matching for `box` ↔ `diamond`
- `trySwapUntilRelease` / `trySwapReleaseUntil` — `untl` ↔ `release`
- `trySwapFutureGlobally` / `trySwapGloballyFuture` — `some_future` ↔ `all_future`
- `trySwapPastHistorically` / `trySwapHistoricallyPast` — `some_past` ↔ `all_past`
- `trySwapWeakUntilStrongRelease` / `trySwapStrongReleaseWeakUntil` — `weak_until` ↔ `strong_release`
- `trySwapTriggerStrongTrigger` / `trySwapStrongTriggerTrigger` — `trigger` ↔ `strong_trigger`
- `tryFlipImplication` — flips `imp φ ψ` to `imp ψ φ` (guards against `ψ = bot` to avoid negation misidentification)
- `tryRemoveLeftConjunct` / `tryRemoveRightConjunct` — decomposes `and φ ψ` primitive pattern

Extended `MutationType.toString` and `MutationType.toJson` to cover all new constructors.

### Phase 3: Pipeline Integration [COMPLETED]

- Extended `generateMutations` to call `mutateSingleOccurrence` with each `try*` function, producing `List (Formula × MutationType)` for each rule.
- Added `dedupMutations` helper to remove duplicate mutants per rule by formula.
- Upgraded `classifyMutation` to use `DatasetGenerator.labelFormula` (with structural pre-filter, wall-clock timeout, and enriched countermodel extraction) instead of raw `decideAuto`.
- Verified no import cycles and `lake build` passes.

### Phase 4: JSON Export and Batch Execution [COMPLETED]

- Added `MutationType.mutationFamily`, `originalOperator`, and `mutatedOperator` helpers mapping each constructor to semantic categories (e.g., "modal_swap", "temporal_swap", "structural_flip", "conjunct_removal").
- Extended `ContrastivePair.toJson` to include `occurrence_index`, `mutation_family`, `original_operator`, and `mutated_operator` fields.
- Extended `ContrastiveBatchStats` with family-level counts (`modalSwapCount`, `temporalSwapCount`, `derivedSwapCount`, `structuralFlipCount`, `conjunctRemovalCount`).
- Added `writeYieldSummary` to export per-family yield statistics to a JSON summary file.
- Added `runBatchContrastive` to run the full pipeline over a pre-labeled corpus.

### Phase 5: Unit Tests and Yield Validation [COMPLETED]

- Created `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` with 30+ unit tests covering:
  - `mutateSingleOccurrence` engine correctness (occurrence counting, DFS order)
  - Each `try*` transformer returning `none` on non-matching formulas and `some` on matching ones
  - Derived operator round-trips (e.g., `trySwapWeakUntilStrongRelease` on `weak_until p q`)
  - `MutationType` serialization round-trips
  - Deduplication behavior via `generateMutations`
  - `ContrastivePair.toJson` field coverage
- Test module compiles successfully (`lake build BimodalTest.Automation.FormulaMutatorTest`).

## Files Modified / Created

- `Theories/Bimodal/Automation/FormulaMutator.lean` — extended with single-occurrence engine, ~15 new mutation rules, pipeline integration, enriched JSON export, batch execution, and yield statistics
- `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` — new unit test module

## Verification

- `lake build Bimodal` passes with 1686 jobs, zero errors, zero warnings (after suppressing unused variable warnings in pattern matches)
- Zero `sorry` in modified files
- Zero vacuous definitions (`True`/`Unit`/`trivial` placeholders)
- Zero new axioms
- `lake build BimodalTest.Automation.FormulaMutatorTest` passes

## Design Decisions

- **Occurrence indexing**: `mutateSingleOccurrence` assigns sequential indices (0, 1, 2...) to each matching node in DFS preorder. This makes the index stable and deterministic.
- **Deduplication**: Applied per-rule in `generateMutations` using `List.contains` on `Formula`. This preserves position diversity across rules while avoiding redundant classification work.
- **Derived operator pattern matching**: All temporal swap functions match on the primitive expansion patterns (as used in `Formula.complexity` and `hasDerivedTemporal`) rather than calling derived operator wrappers. This ensures structural termination and avoids false negatives on manually-constructed formulas.
- **labelFormula integration**: Replaced the manual `decideAuto` + `decideOptimized` retry logic in `classifyMutation` with a single call to `labelFormula`, which provides the same timeout handling plus structural pre-filters and enriched countermodels.

## Known Limitations / Risks Addressed

- **Risk**: Derived operator pattern matching fragility (W↔M, T↔ST). Mitigated by matching exact primitive expansions with equality checks on shared subformulas (e.g., `ψ1 == ψ2` in weak_until/strong_release swap).
- **Risk**: Conjunct removal on non-`and` formulas. Mitigated by returning `none` when the pattern doesn't match.
- **Risk**: Implication flip misidentifying negations. Mitigated by `ψ != bot` guard in `tryFlipImplication`.
- **Risk**: `labelFormula` timeouts on mutated formulas. Mitigated by keeping the existing 1000ms wall-clock timeout; timeouts are counted in yield stats.

## Session

- **Agent**: lean-implementation-agent
- **Session ID**: sess_1780677343_a4f654
- **Date**: 2026-06-05
