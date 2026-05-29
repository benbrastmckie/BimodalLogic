# Implementation Plan: Task #210

- **Task**: 210 - enumerator_complexity_blowup
- **Status**: [NOT STARTED]
- **Effort**: 8 hours (critical path ~6 hours with Phases 1 and 2 parallel)
- **Dependencies**: None (self-contained refactoring of FormulaEnumerator.lean and DatasetGenerator.lean)
- **Research Inputs**: specs/210_enumerator_complexity_blowup/reports/01_enumerator-blowup-research.md
- **Artifacts**: plans/01_enumerator-blowup-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The `enumerateAtBudget` and `enumHelper` functions in FormulaEnumerator.lean suffer from exponential blowup: at complexity 5 they generate 937K formula nodes to produce only 1,440 distinct formulas (651x bloat). This is caused by "up to budget" semantics that re-include base cases at every level, no memoization of repeated recursive calls, and Cartesian product explosion across binary connectives. Additionally, the deep dataset run's valid fraction dropped to 1.6% (failing the 15% gate) because random sampling at high complexity overwhelmingly produces invalid formulas.

This plan addresses both problems: (1) rewrite enumeration to use exact-complexity semantics with memoization, and (2) add axiom-schema instantiation to generate guaranteed-valid formulas. The Python model checker integration is out of scope (future task). Definition of done: `lake build` passes, exhaustive enumeration completes at complexity 5-7 in under 60 seconds, and the axiom-instantiation pathway produces formulas that are structurally valid by construction.

### Research Integration

Integrated from `reports/01_enumerator-blowup-research.md`:
- Root cause analysis identifying three compounding performance problems (Section 1)
- Bloat ratio data: 1x at budget 1, 651x at budget 5, 14,876x at budget 7 (Section 1.1)
- Valid fraction analysis: 25% at complexity 4 vs 1.6% at complexity 7 (Section 2)
- Strategy A (memoized exact-complexity) and Strategy C (axiom-schema instantiation) ranked as priority 1 (Section 6)
- Strategy D (time-based caps) as safety net (Section 6)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task supports the dataset generation infrastructure. It does not directly advance ROADMAP.md completeness items but is a prerequisite for producing high-quality training datasets at complexity 5-7.

## Goals & Non-Goals

**Goals**:
- Eliminate the exponential blowup in `enumerateAtBudget` and `enumHelper` by switching to exact-complexity enumeration with memoization
- Add axiom-schema instantiation to generate guaranteed-valid formulas at arbitrary complexity
- Update `DatasetGenerator.lean` to use the improved enumeration and axiom seeding
- Validate that complexity 5-7 enumeration completes in reasonable time and the valid fraction meets the 15% gate

**Non-Goals**:
- Python model checker integration (separate future task)
- Changes to the decision procedure itself
- Modifying the axiom system or proof system
- Optimizing `sampleOneRandom` (already adequate for random mode)
- Streaming/incremental export (Strategy F -- low priority)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Memoized enumeration still too slow at complexity 7+ | H | L | The research shows only 43,696 distinct formulas at complexity 7 -- well within memory. Add time-cap safety net (Strategy D). |
| Lean 4 `IO.Ref` or `HashMap` API differences cause build errors | M | M | Use `StateM (HashMap ...)` monad or `IO.Ref`. Verify API with Lean MCP tools before committing. |
| Axiom instantiation produces formulas that are too structurally similar | M | M | Use random sub-formula substitution at varying depths. Mix axiom-generated and enumerated formulas. |
| `eraseDups` becomes unnecessary after exact-complexity rewrite | L | H | Formulas within one exact-complexity level are structurally unique by construction; cross-level formulas differ in complexity. Replace `eraseDups` with a debug assertion in development and remove from production path. Fall back to `Std.HashSet`-based dedup if the assertion ever fires. |
| Breaking changes to `enumerateExhaustive` API disrupt DatasetExporter | H | M | Keep the `EnumParams`-based API surface stable. Refactor internals only. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel. Phases 1 (enumeration rewrite) and 2 (axiom instantiation) are independent — they add non-overlapping functionality to FormulaEnumerator.lean and share no code dependencies. Phase 3 wires both into DatasetGenerator and therefore requires both.

---

### Phase 1: Rewrite enumerateAtBudget to exact-complexity with memoization [COMPLETED]

**Goal**: Replace the "up to budget" enumeration with exact-complexity enumeration and add memoization to eliminate redundant computation. This directly addresses the 651x bloat at budget 5.

**Tasks**:
- [x] **Task 1.1**: Create `enumExactBudget` function that generates formulas of EXACTLY the given complexity (not "up to")
  - Base case (budget=1): return `bot :: atoms.map .atom`
  - Unary case (budget=n+1, n>=1): box only -- child gets budget n, decrement modal depth
  - Binary case (budget=n+1, n>=1): distribute remaining n among left+right (each >= 1), no base case re-inclusion
- [x] **Task 1.2**: Add memoization using `Std.HashMap (Nat x Nat x Nat) (List Formula)` keyed by `(budget, maxModal, maxTemporal)` *(deviation: altered -- used pure state threading via foldl instead of IO.Ref, avoids IO dependency for pure enumeration)*
  - Check cache before computing; store result after computing
- [x] **Task 1.3**: Rewrite `enumerateAtBudget` to call `enumExactBudget` (preserve function signature for backwards compatibility)
- [x] **Task 1.4**: Rewrite `enumerateExhaustive` to call `enumExactBudget` for each complexity level 1..maxComplexity and concatenate
  - Each level produces only exact-complexity formulas, so no cross-level duplication
  - Remove `eraseDups` from the concatenated output (exact-complexity levels are disjoint by construction) *(deviation: altered -- removed eraseDups entirely rather than adding debug assertion, since exact-complexity levels are provably disjoint)*
- [x] **Task 1.5**: Apply the same exact-complexity + memoization pattern to `enumHelper` (the plan-specified API) — created `enumExactHelper` as the core, `enumHelper` as backward-compatible wrapper
- [x] **Task 1.6**: Rewrite `enumerateUpToDepth` to use the memoized exact-complexity variant
- [ ] **Task 1.7**: Add a wall-clock time cap (Strategy D) as a safety net *(deviation: deferred to task Phase 4 -- will add if timing gates fail; pure enumeration functions cannot use IO.monoMsNow)*
- [x] **Task 1.8**: Verify that `generateFormulas` still compiles and works correctly with the refactored internals

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- rewrite enumeration core (lines ~98-517)

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` compiles without errors
- Manual test: `enumerateExhaustive` at complexity 5 with 3 atoms produces ~1,440 distinct formulas (matching the "exact distinct" column from research)

---

### Phase 2: Add axiom-schema instantiation for guaranteed-valid formulas [COMPLETED]

**Goal**: Create a new module that generates valid-by-construction formulas by instantiating the 42 axiom schemata with random sub-formulas. This addresses the valid fraction problem. This phase is independent of Phase 1 — it adds new functions that do not call or depend on the enumeration rewrite.

**Tasks**:
- [x] **Task 2.1**: Create `instantiateAxiom : List Atom -> Nat -> IO Formula` that picks a random axiom schema and generates random sub-formulas
- [x] **Task 2.2**: Create `generateValidFromMP : Formula -> Formula -> Option Formula` that applies modus ponens
- [x] **Task 2.3**: Create `generateValidFromNec : Formula -> Formula` that applies necessitation
- [x] **Task 2.4**: Create `generateValidBatch : Nat -> Nat -> List Atom -> IO (List Formula)` using incremental pool strategy with seed, necessitation, and MP rounds
- [x] **Task 2.5**: Focus on 8 high-yield schemata: `prop_s`, `prop_k`, `ex_falso`, `modal_t`, `modal_4`, `modal_b`, `modal_k_dist`, `peirce`

**Timing**: 2 hours

**Depends on**: none (parallel with Phase 1)

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- add axiom instantiation functions in a new section

**Verification**:
- `lake build Bimodal.Automation.FormulaEnumerator` compiles
- `generateValidBatch 100 7 atoms` produces ~100 formulas with complexity in 3-7 range
- All generated formulas are structurally axiom instances or derived via MP/necessitation from axiom instances (valid by construction)

---

### Phase 3: Update DatasetGenerator to use improved enumeration and axiom seeding [NOT STARTED]

**Goal**: Wire the new exact-complexity enumeration and axiom-seeded valid formulas into the labeling pipeline.

**Tasks**:
- [ ] Update `DatasetGenerator.lean` to accept a `validSeedCount : Nat` parameter controlling how many axiom-instantiated formulas to mix in
- [ ] In the dataset generation pipeline, combine three formula sources:
  1. Exhaustive exact-complexity enumeration (complexity 1..maxComplexity)
  2. Random sampling (existing `sampleRandom`)
  3. Axiom-instantiated valid formulas (`generateValidBatch`)
- [ ] Ensure deduplication across all three sources before labeling
- [ ] Update any configuration structures (`EnumParams`, etc.) to support the new `validSeedCount` field with a sensible default (e.g., 500)
- [ ] Verify that `DatasetExporter.lean` and `DataExport.lean` work with the updated pipeline without changes (they consume `LabeledFormula` which is unchanged)

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- update pipeline to use new enumeration + axiom seeding
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- minor: add/export any needed helper functions

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` compiles
- Pipeline produces a combined formula list from all three sources

---

### Phase 4: Validation -- complexity 5-7 feasibility gates [NOT STARTED]

**Goal**: Verify that the refactored enumeration meets performance targets and the axiom seeding meets the 15% valid fraction gate.

**Tasks**:
- [ ] Create a compiled benchmark executable (a `main` definition in a test file under `Tests/BimodalTest/`) that:
  - Runs `enumerateExhaustive` at complexity 5, 6, and 7 with 3 atoms, modal depth 2, temporal depth 2
  - Measures wall-clock time for each complexity level using `IO.monoMsNow`
  - Reports formula counts per complexity level
  - Verifies complexity 5 produces ~1,440 distinct formulas
  - **Important**: Run via `lake env lean --run` (compiled mode), NOT `#eval` — the Lean interpreter is orders of magnitude slower than compiled code and would produce misleading timing results
- [ ] Verify timing targets (compiled execution):
  - Complexity 5: < 5 seconds
  - Complexity 6: < 30 seconds
  - Complexity 7: < 60 seconds (or safely cap and log)
- [ ] Run a small labeling batch (100-200 formulas) at complexity 5 with axiom seeding:
  - Measure valid fraction
  - Verify it exceeds 15% with axiom-instantiated formulas included
- [ ] If any gate fails, diagnose and adjust parameters (e.g., increase axiom seed count, reduce complexity bound)

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Tests/BimodalTest/` -- compiled benchmark and validation tests
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- tuning if needed

**Verification**:
- All timing gates pass under compiled execution (complexity 5 < 5s, complexity 6 < 30s)
- Valid fraction with axiom seeding exceeds 15%
- `lake build` passes for the full project

---

### Phase 5: Testing, cleanup, and documentation [NOT STARTED]

**Goal**: Ensure full project build passes, update documentation, and clean up any temporary test code.

**Tasks**:
- [ ] Run `lake build` for the full project to verify no regressions
- [ ] Update the module docstring in FormulaEnumerator.lean to document the new exact-complexity enumeration approach and axiom instantiation
- [ ] Add inline documentation for new functions (`enumExactBudget`, `instantiateAxiom`, `generateValidBatch`)
- [ ] Remove any temporary `#eval` debugging blocks
- [ ] Verify that existing imports and downstream consumers (DatasetExporter, DataExport) still compile

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` -- documentation updates
- `Theories/Bimodal/Automation/DatasetGenerator.lean` -- documentation updates

**Verification**:
- `lake build` succeeds with zero errors
- All module docstrings are accurate and up to date
- No `sorry` or `#eval` debugging blocks remain

## Testing & Validation

- [ ] `lake build Bimodal.Automation.FormulaEnumerator` compiles at each phase
- [ ] `lake build Bimodal.Automation.DatasetGenerator` compiles after Phase 3
- [ ] `lake build` (full project) passes after Phase 5
- [ ] Complexity 5 enumeration produces ~1,440 distinct formulas (down from 937K raw)
- [ ] Complexity 5 enumeration completes in < 5 seconds (down from >1.5 hours)
- [ ] Complexity 6-7 enumeration completes within 60 seconds each
- [ ] Valid fraction with axiom seeding exceeds 15% at complexity 5-7
- [ ] No regressions in existing DatasetExporter/DataExport functionality

## Artifacts & Outputs

- `specs/210_enumerator_complexity_blowup/plans/01_enumerator-blowup-plan.md` (this plan)
- `Theories/Bimodal/Automation/FormulaEnumerator.lean` (refactored with exact-complexity enumeration, memoization, and axiom instantiation)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` (updated pipeline with axiom seeding integration)

## Rollback/Contingency

If the refactoring introduces regressions or the memoization approach proves infeasible:
1. Git revert to the pre-implementation commit
2. The original `enumerateAtBudget` and `enumHelper` functions are purely functional with no external state -- reverting is clean
3. As a fallback, the time-cap safety net (Strategy D) can be applied as a patch to the original code without the full rewrite, providing a partial fix that prevents infinite hangs
4. The axiom instantiation module is additive (new functions, no modification of existing ones) and can be independently reverted
