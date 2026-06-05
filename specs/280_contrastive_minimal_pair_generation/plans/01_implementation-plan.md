# Implementation Plan: Task 280 — Contrastive Minimal Pair Generation

- **Task**: 280 - Contrastive Minimal Pair Generation
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: Task 275 (completed), Task 276 (completed)
- **Research Inputs**: specs/280_contrastive_minimal_pair_generation/reports/01_research.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Extend the existing `FormulaMutator.lean` module with a single-occurrence mutation engine and ~10 new mutation rules to generate high-signal contrastive minimal pairs for training. The work builds on the Task 206 mutation framework (which applies global mutations) by adding fine-grained, single-structural-change mutations that target exactly one operator occurrence in a formula. The resulting pipeline applies mutations to the c5/c7 labeled corpus, re-labels mutants via `labelFormula` (with wall-clock timeouts and pre-filters), and exports valid contrastive pairs to JSONL with per-mutation-type metadata.

### Research Integration

The research report (01_research.md) identified that `FormulaMutator.lean` already implements a global mutation framework (`MutationType`, `ContrastivePair`, `generateMutations`, JSONL export) but lacks single-occurrence mutations. Key gaps: (1) `weakenBoxToDiamond` replaces ALL `box` with `diamond` — need single-occurrence; (2) missing temporal operator swaps (U↔R, F↔G, W↔M, T↔ST); (3) no conjunct removal; (4) no implication direction flip; (5) `classifyMutation` calls raw `decideAuto` instead of the richer `labelFormula` pipeline. The recommended approach is to extend the existing module with a generic `mutateSingleOccurrence` engine, add new `MutationType` constructors, implement specific swap/remove/flip functions, upgrade the pipeline integration, and export enriched JSONL.

### Prior Plan Reference

No prior plan. The research report itself contains a detailed three-phase implementation sketch (Phase 1: single-occurrence engine, Phase 2: pipeline integration, Phase 3: export and testing) which is adopted and refined here.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define a single-occurrence mutation engine (`mutateSingleOccurrence`) that applies a transformation at exactly one AST node
- Add ~10 new mutation rules targeting one structural change: □↔◇, U↔R, F↔G, H↔P, W↔M, T↔ST, implication flip, left/right conjunct removal
- Extend `MutationType` with constructors carrying occurrence indices for traceability
- Integrate new mutations into `generateMutations` and upgrade `classifyMutation` to use `labelFormula` (with wall-clock timeouts, pre-filters, enriched countermodels)
- Enrich `ContrastivePair` JSON export with `occurrence_index`, `mutation_family`, `original_operator`, `mutated_operator`
- Add batch execution over the c5/c7 labeled corpus and compute per-mutation-type yield rates
- Write unit tests verifying each mutation produces exactly one structural change, deduplicates correctly, and serializes accurately

**Non-Goals**:
- New axioms or proof-system changes (zero-debt compliance)
- Parallel execution infrastructure (reuse existing thread pool from `DatasetExport.lean`)
- New decision procedure development (reuse existing `decideAuto` / `labelFormula`)
- New formula enumeration (reuse c5/c7 corpus from Tasks 275/276)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Single-occurrence engine produces duplicate mutants (e.g., symmetric swaps on same node) | Medium | Medium | Use `List.eraseDups` (BEq on Formula) after generating all single-occurrence mutants for a given rule |
| `labelFormula` timeouts on mutated formulas cause low yield | Medium | Medium | Keep 1s wall-clock timeout; count timeouts separately in yield stats; skip mutants whose complexity < 3 |
| Derived operator pattern matching at primitive level is fragile (e.g., `and` = double-imp) | High | Low | Match on derived-operator wrappers where possible; add unit tests for each pattern; fall back to no-match (safe) |
| Conjunct removal on non-`and` formulas produces unexpected AST | Medium | Low | Only apply `tryRemoveLeftConjunct` / `tryRemoveRightConjunct` when the node matches the `and` expansion pattern; return `none` otherwise |
| Implication flip misidentifies negations (`neg φ = imp φ bot`) | Medium | Low | Guard `tryFlipImplication` with `ψ != bot` so it only flips genuine implications, not negations |
| Lean build failures due to import cycles between Mutator and Generator | Low | Medium | Mutator already imports `DatasetGenerator`; verify import graph after adding `labelFormula` usage |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential due to wave ordering.

### Phase 1: Single-Occurrence Mutation Engine and MutationType Extension [COMPLETED]

**Goal**: Establish the generic engine and extend the type system so all subsequent mutations are traceable.

**Tasks**:
- [ ] Add `mutateSingleOccurrence` generic function: takes a `Formula` and a `Formula → Option Formula` transformer, returns `List (Formula × Nat)` of mutated formulas paired with occurrence indices
- [ ] Implement via structural recursion with an occurrence counter, preserving unmutated siblings at each step
- [ ] Extend `MutationType` inductive with new constructors: `boxToDiamondAtOccurrence`, `diamondToBoxAtOccurrence`, `untilToReleaseAtOccurrence`, `releaseToUntilAtOccurrence`, `futureToGloballyAtOccurrence`, `globallyToFutureAtOccurrence`, `pastToHistoricallyAtOccurrence`, `historicallyToPastAtOccurrence`, `weakUntilToStrongReleaseAtOccurrence`, `strongReleaseToWeakUntilAtOccurrence`, `triggerToStrongTriggerAtOccurrence`, `strongTriggerToTriggerAtOccurrence`, `flipImplicationAtOccurrence`, `removeLeftConjunctAtOccurrence`, `removeRightConjunctAtOccurrence`
- [ ] Derive `Repr` and `BEq` for the extended `MutationType`

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` — add engine and new constructors (~80 lines)

**Verification**:
- `lake build` compiles with no errors or warnings
- `mutateSingleOccurrence` on a simple `box (box atom)` returns exactly two mutants with occurrence indices 0 and 1

---

### Phase 2: Implement Specific Mutation Functions [COMPLETED]

**Goal**: Implement the ~10 mutation rule transformers that operate on a single AST node.

**Tasks**:
- [ ] `trySwapBoxDiamond` / `trySwapDiamondBox`: match `box φ` ↔ `diamond φ` (and vice versa) at primitive level
- [ ] `trySwapUntilRelease` / `trySwapReleaseUntil`: match `untl φ ψ` ↔ `release φ ψ` using primitive expansion patterns (reference `FormulaEnumerator.lean` pattern matching for `release`)
- [ ] `trySwapFutureGlobally` / `trySwapGloballyFuture`: match `some_future φ` ↔ `all_future φ` via derived operator recognition (reference `matchAllFuture` / `matchAllPast` helpers)
- [ ] `trySwapPastHistorically` / `trySwapHistoricallyPast`: same for past operators
- [ ] `trySwapWeakUntilStrongRelease` / `trySwapStrongReleaseWeakUntil`: match `weak_until` ↔ `strong_release` via `hasDerivedTemporal` patterns from Task 276
- [ ] `trySwapTriggerStrongTrigger` / `trySwapStrongTriggerTrigger`: match `trigger` ↔ `strong_trigger`
- [ ] `tryFlipImplication`: match `imp φ ψ` where `ψ != bot`, return `imp ψ φ`; return `none` otherwise
- [ ] `tryRemoveLeftConjunct` / `tryRemoveRightConjunct`: match `and φ ψ` expansion, return the right/left conjunct respectively; return `none` if not an `and` pattern
- [ ] Add `MutationType.toString` / `toJson` / `detailJson` cases for all new constructors

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` — add specific mutation functions (~200 lines)

**Verification**:
- Each `try*` function returns `none` on non-matching formulas
- Each `try*` function returns exactly one mutated formula on matching formulas
- `MutationType.toString` covers all new constructors without missing cases

---

### Phase 3: Pipeline Integration [COMPLETED]

**Goal**: Wire the new mutations into the existing generation/classification pipeline and upgrade decision-procedure integration.

**Tasks**:
- [ ] Extend `generateMutations` to call `mutateSingleOccurrence` with each new `try*` function, producing `List (Formula × MutationType)` for each rule
- [ ] Upgrade `classifyMutation` to call `DatasetGenerator.labelFormula` (with the existing wall-clock timeout, pre-filter, and interestingness pipeline) instead of raw `decideAuto`
- [ ] Ensure `generateContrastivePairs` filters out duplicate mutants (using `List.eraseDups` on the mutated formula) before classification
- [ ] Ensure `filterContrastive` retains the existing complexity gate (mutated complexity ≥ 3) and timeout exclusion
- [ ] Verify that imports remain valid (no cycles) after `labelFormula` usage

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` — `generateMutations`, `classifyMutation`, `generateContrastivePairs`, `filterContrastive` (~80 lines)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — verify `labelFormula` is exported/imported correctly (~5 lines if needed)

**Verification**:
- `lake build` compiles with no errors
- `generateMutations` on a sample valid formula returns a non-empty list that includes new mutation types
- `classifyMutation` timeout behavior is unchanged (no raw `decideAuto` calls remain)

---

### Phase 4: JSON Export and Batch Execution [COMPLETED]

**Goal**: Enrich exported JSONL with per-mutation metadata and run the batch pipeline over the c5/c7 corpus.

**Tasks**:
- [ ] Extend `ContrastivePair.toJson` to include new fields: `occurrence_index`, `mutation_family` (e.g., "modal_swap", "temporal_swap", "structural_flip", "conjunct_removal"), `original_operator`, `mutated_operator`
- [ ] Add `MutationType.mutationFamily` helper that maps each constructor to its family string
- [ ] Add `MutationType.originalOperator` and `mutatedOperator` helpers
- [ ] Verify `writeContrastiveJSONL` serializes the new fields correctly
- [ ] Add `computeContrastiveStats` function that breaks down yield rate per `mutationFamily` and per `MutationType`
- [ ] Implement a `runBatchContrastive` function that takes the c5/c7 labeled corpus, generates contrastive pairs, and writes the JSONL output file
- [ ] Export per-mutation-type yield statistics to a separate JSON summary file

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaMutator.lean` — `ContrastivePair.toJson`, `computeContrastiveStats`, `runBatchContrastive` (~70 lines)
- `Theories/Bimodal/Automation/DataExport.lean` — if shared JSON helpers need extension (~10 lines)

**Verification**:
- JSONL output file contains the new fields (`occurrence_index`, `mutation_family`, etc.) for every contrastive pair
- `computeContrastiveStats` on a synthetic test set produces correct counts per mutation family
- Batch execution completes without unhandled exceptions

---

### Phase 5: Unit Tests and Yield Validation [COMPLETED]

**Goal**: Verify correctness of each mutation rule, deduplication, and yield measurement.

**Tasks**:
- [ ] Create `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` with unit tests for:
  - `mutateSingleOccurrence` on a `box (box atom)` produces exactly 2 mutants with correct indices
  - `trySwapBoxDiamond` returns `none` on `atom` and returns a mutant on `box atom`
  - `tryFlipImplication` returns `none` on `neg φ` (which is `imp φ bot`) and flips genuine implications
  - `tryRemoveLeftConjunct` / `tryRemoveRightConjunct` correctly identify and decompose `and` patterns
  - Each new `MutationType` constructor round-trips through `toString` / `toJson`
  - Deduplication: `generateMutations` on a symmetric formula does not produce duplicate mutants for the same rule
  - `ContrastivePair.toJson` includes all required fields and valid JSON
- [ ] Run `lake build` on the test suite
- [ ] Run the batch pipeline on a small sample of the c5/c7 corpus (e.g., 20 formulas) and manually inspect the JSONL output and yield summary
- [ ] Compare yield rates per mutation family against the research predictions (high-yield: □↔◇, imp-flip, conjunct-removal; medium-yield: temporal swaps)

**Timing**: 1.5 hours

**Depends on**: 4

**Files to create/modify**:
- `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` — new file (~150 lines)
- `Tests/BimodalTest/Main.lean` — register the new test module if required

**Verification**:
- All unit tests pass (`lake build` and test executable succeeds)
- Sample batch produces non-empty JSONL with correct metadata fields
- Yield statistics JSON is well-formed and non-negative

## Testing & Validation

- [ ] `lake build` compiles the main library with zero errors and zero warnings (no `sorry`)
- [ ] Unit tests for `mutateSingleOccurrence`, each `try*` function, and `MutationType` serialization pass
- [ ] Integration test: a known valid formula (e.g., `□p → p`) generates at least one contrastive pair where the mutated label differs from the original
- [ ] JSONL output validates against a JSON schema check (manual or scripted)
- [ ] Yield rate summary is generated and written to disk
- [ ] No new axioms introduced; no changes to `Syntax/Formula.lean`, `ProofSystem/`, or `Semantics/`

## Artifacts & Outputs

- `Theories/Bimodal/Automation/FormulaMutator.lean` — extended with single-occurrence engine, new mutation rules, pipeline integration, and batch execution
- `Theories/Bimodal/Automation/DataExport.lean` — potentially extended with shared JSON helpers
- `Theories/Bimodal/Automation/DatasetGenerator.lean` — minor import/export adjustments for `labelFormula`
- `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` — new unit test module
- `specs/280_contrastive_minimal_pair_generation/plans/01_implementation-plan.md` — this plan
- `specs/280_contrastive_minimal_pair_generation/.return-meta.json` — planning metadata
- Data outputs (generated at runtime, not versioned):
  - `contrastive_pairs.jsonl` — JSONL file with enriched contrastive pairs
  - `contrastive_yield_stats.json` — per-mutation-type yield summary

## Rollback/Contingency

- If the single-occurrence engine proves too complex or fragile, fall back to extending the existing global mutators with per-occurrence wrappers (less efficient but still correct)
- If `labelFormula` integration causes import cycles, revert `classifyMutation` to raw `decideAuto` but add the wall-clock timeout wrapper inline
- If derived-operator pattern matching for `W↔M` or `T↔ST` is too brittle, skip those two mutation families and deliver the remaining 8 rules (still satisfying the "~10 mutation rules" target with margin)
- If build times or timeout rates are too high, add a complexity cap (only mutate formulas with complexity ≤ 12) and skip mutants that exceed it
- All changes are additive; reverting involves deleting the new `MutationType` constructors and mutation functions, leaving the original Task 206 infrastructure intact
