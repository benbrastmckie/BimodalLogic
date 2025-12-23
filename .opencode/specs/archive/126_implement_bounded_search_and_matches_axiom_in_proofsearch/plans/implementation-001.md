# Implementation Plan: Implement bounded search and matches axiom in ProofSearch

- **Task**: 126 - Implement bounded search and matches axiom in ProofSearch
- **Status**: [COMPLETED]
- **Started**: 2025-12-22T12:00:00Z
- **Completed/Blocked/Abandoned**: 2025-12-22T20:00:00Z
- **Effort**: 6-10 hours (initial request 3h; expanded for schema coverage)
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/reports/research-001.md
- **Artifacts**: .opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md; Logos/Core/Automation/ProofSearch.lean; LogosTest/Core/Automation/ProofSearchTest.lean
- **Standards**: .opencode/context/common/standards/plan.md; .opencode/context/common/system/status-markers.md; .opencode/context/common/system/artifact-management.md; .opencode/context/common/standards/tasks.md

## Overview
Implement a terminating bounded proof search driver and exact axiom matching in `Logos/Core/Automation/ProofSearch.lean`, replacing stubs while threading caches and visit limits. Ensure schema checks cover all 14 axioms with negative coverage and integrate depth/visit guards to avoid timeouts. Preserve API stability while enabling search runs to complete reliably.

## Goals & Non-Goals
- **Goals**: Implement bounded search with depth/visit enforcement; implement precise `matches_axiom` across all schemas; integrate cache/visited handling into search entrypoints; land targeted Lean tests for matching, termination, and cache reuse.
- **Non-Goals**: Redesign axiom schemas or heuristics beyond correctness; change public interfaces outside ProofSearch; optimize performance beyond ensuring termination and correctness.

## Risks & Mitigations
- False positives/negatives in axiom matching → Implement schema-specific structural checks in deterministic order and add negative tests per schema.
- Non-termination or visit leaks → Increment visits on entry, enforce depth/visit cutoffs, and track visited `(Γ, φ)` pairs.
- Cache misuse or missed reuse → Cache successes/failures keyed by context and goal with tests for reuse.
- Performance regressions from expensive branches → Order checks cheap-to-expensive (axiom, assumption, cache, MP, modal/temporal) and reuse implication index helpers.

## Implementation Phases
### Phase 1: Schema review & helpers [COMPLETED 2025-12-22T20:00:00Z]
- **Goal:** Capture exact axiom shapes and helper destructors for structural matching.
- **Tasks:**
  - [ ] Extract 14 schemas from `Axioms.lean`, including derived operator forms.
  - [ ] Define local helpers for implications, box/future contexts, and derived operators.
- **Timing:** 1 hour

### Phase 2: Implement matches_axiom [COMPLETED 2025-12-22T20:00:00Z]
- **Goal:** Encode schema-accurate matching for all axioms without stubs.
- **Tasks:**
  - [ ] Implement structural checks for each schema in specificity order.
  - [ ] Remove fallback branches; ensure no permissive matches.
  - [ ] Add unit-style checks for positives and negatives where feasible.
- **Timing:** 2 hours

### Phase 3: Implement bounded_search with limits [COMPLETED 2025-12-22T20:00:00Z]
- **Goal:** Enforce depth/visit limits with cache/visited threading in search.
- **Tasks:**
  - [ ] Thread `(depth, visits, visitLimit, cache, visited)` through recursion.
  - [ ] Guard zero/limit cutoffs before branching; update visits on entry.
  - [ ] Order search: axiom → assumption → cache → MP → modal/temporal branches.
- **Timing:** 2 hours

### Phase 4: Integrate entrypoints and heuristics [COMPLETED 2025-12-22T20:00:00Z]
- **Goal:** Align public search entrypoints and scoring with bounded search and matching.
- **Tasks:**
  - [ ] Expose visitLimit in `search_with_cache` and ensure cache stores successes/failures.
  - [ ] Align `heuristic_score` with corrected `matches_axiom` behavior.
  - [ ] Verify API compatibility for existing callers.
- **Timing:** 1 hour

### Phase 5: Testing & validation [COMPLETED 2025-12-22T20:00:00Z]
- **Goal:** Validate matching accuracy, termination, and cache reuse.
- **Tasks:**
  - [ ] Add/extend `ProofSearchTest` with positive/negative schema cases and bounded search scenarios (depth/visit cutoff, MP chain, modal/temporal K, cache reuse).
  - [ ] Run `lake build` and targeted `LogosTest/Core/Automation` tests.
- **Timing:** 2 hours

## Testing & Validation
- [ ] Unit: schema-specific `matches_axiom` positives/negatives; cache/visited guard behavior.
- [ ] Integration: bounded search over contexts (MP chain, modal K, temporal K) with depth and visit cutoffs plus cache reuse.
- [ ] Acceptance: bounded search enforces limits and terminates; `matches_axiom` only accepts valid schema instances; targeted Automation tests pass.

## Artifacts & Outputs
- .opencode/specs/126_implement_bounded_search_and_matches_axiom_in_proofsearch/plans/implementation-001.md
- Logos/Core/Automation/ProofSearch.lean
- LogosTest/Core/Automation/ProofSearchTest.lean

## Rollback/Contingency
- If bounded search integration regresses callers, revert to prior `ProofSearch.lean` and disable new entrypoint changes while preserving tests for future reattempt.
