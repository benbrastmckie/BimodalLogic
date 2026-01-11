# Implementation Plan: Task #179

**Task**: Extend Bimodal benchmarks with derivation, semantics, and CI integration
**Version**: 002
**Created**: 2026-01-11
**Revision of**: implementation-001.md
**Reason**: Improve the plan based on research-001.md findings

## Revision Summary

This revision incorporates research findings to strengthen the implementation approach:

### Key Changes from v001

1. **Added explicit reuse of existing infrastructure** - Research confirmed `timed`, `formatNanos`, `BenchmarkResult` patterns should be imported, not reimplemented
2. **Added correctness validation alongside timing** - Research highlighted formal verification benefit of benchmarks with expected results
3. **Restructured for parallel execution** - Research recommendation to run Phase 1 and 2 in parallel (no dependencies)
4. **Added iteration-based timing** - Research on timing variability mitigation via multiple iterations and median calculation
5. **Simplified CI integration** - Focus on essential regression detection; defer GitHub Actions to future work if not already configured
6. **Added test fixture patterns** - Leverage existing test patterns from `DerivationTest.lean` and `TruthTest.lean`

### Previous Plan Status (v001)
- Phase 1: [NOT STARTED] - Derivation benchmarks
- Phase 2: [NOT STARTED] - Semantic benchmarks
- Phase 3: [NOT STARTED] - Performance targets documentation
- Phase 4: [NOT STARTED] - CI integration

## Overview

Extend the Bimodal benchmarking suite with derivation tree and semantic evaluation benchmarks, leveraging the comprehensive infrastructure already in `ProofSearchBenchmark.lean`. The goal is 3/3 coverage of major computational operations (proof search, derivation, semantics) with automated regression detection.

## Phases

### Phase 1: Derivation Tree Benchmarks

**Status**: [NOT STARTED]
**Estimated effort**: 2.5 hours

**Objectives**:
1. Benchmark derivation tree construction performance
2. Measure modus ponens chains of varying depth
3. Benchmark modal/temporal inference rules
4. Validate correctness alongside timing

**Files to create**:
- `BimodalTest/ProofSystem/DerivationBenchmark.lean` (new)

**Key insight from research**: Reuse `timed` and `formatNanos` from ProofSearchBenchmark via shared import or copy.

**Implementation**:

```lean
import Bimodal.ProofSystem.Derivation
import BimodalTest.Automation.ProofSearchBenchmark  -- Reuse timing utilities

namespace BimodalTest.ProofSystem.Benchmark

open Bimodal.Syntax Bimodal.ProofSystem
open BimodalTest.Automation.Benchmark (timed formatNanos)

/-- Derivation benchmark result with correctness validation. -/
structure DerivationBenchmarkResult where
  name : String
  treeHeight : Nat      -- From Derivation.height
  constructionTimeNs : Nat
  valid : Bool          -- Derivation type-checks (always true if compiles)
  deriving Repr

/-- Run a derivation benchmark with timing. -/
def runDerivationBenchmark {Γ : Context} {φ : Formula}
    (name : String) (derive : Unit → DerivationTree Γ φ)
    (iterations : Nat := 100) : IO DerivationBenchmarkResult := do
  -- Run multiple iterations, take median for stability
  let mut times : Array Nat := #[]
  let mut tree : Option (DerivationTree Γ φ) := none
  for _ in [:iterations] do
    let (result, timeNs) ← timed (pure (derive ()))
    times := times.push timeNs
    tree := some result
  let sortedTimes := times.toList.mergeSort (· ≤ ·)
  let medianTime := sortedTimes.get! (sortedTimes.length / 2)
  let height := match tree with
    | some t => t.height
    | none => 0
  return { name, treeHeight := height, constructionTimeNs := medianTime, valid := true }
```

**Benchmark categories** (based on DerivationTest.lean patterns):

```lean
-- Category 1: Simple derivations (baseline)
def simpleDerivations : List (String × (Unit → DerivationTree _ _)) := [
  ("Axiom (Modal T)", fun _ => DerivationTree.axiom _ (Axiom.modal_t _)),
  ("Axiom (Modal 4)", fun _ => DerivationTree.axiom _ (Axiom.modal_4 _)),
  ("Assumption (single)", fun _ => DerivationTree.assumption [p] p (by simp))
]

-- Category 2: Modus ponens chains (depth scaling)
def mpChainBenchmarks : List (String × Nat) := [
  ("MP depth 1", 1),
  ("MP depth 3", 3),
  ("MP depth 5", 5),
  ("MP depth 10", 10)
]

-- Category 3: Modal/temporal rules
def modalRuleBenchmarks : List (String × (Unit → DerivationTree _ _)) := [
  ("Necessitation (modal)", fun _ => DerivationTree.necessitation _ d),
  ("Necessitation (temporal)", fun _ => DerivationTree.temporal_necessitation _ d),
  ("Temporal duality", fun _ => DerivationTree.temporal_duality _ d)
]

-- Category 4: Weakening with context sizes
def weakeningBenchmarks : List (String × Nat) := [
  ("Weakening (5 formulas)", 5),
  ("Weakening (10 formulas)", 10),
  ("Weakening (20 formulas)", 20)
]
```

**Verification**:
- All benchmark derivations type-check (Lean compiler verifies)
- Timing measurements stable (±20% between runs acceptable)
- `lake build BimodalTest.ProofSystem.DerivationBenchmark` succeeds

---

### Phase 2: Semantic Evaluation Benchmarks

**Status**: [NOT STARTED]
**Estimated effort**: 2 hours

**Note**: Can run in parallel with Phase 1 (no dependencies).

**Objectives**:
1. Benchmark `truth_at` evaluation performance
2. Measure formula complexity scaling
3. Validate expected truth values (soundness check)

**Files to create**:
- `BimodalTest/Semantics/SemanticBenchmark.lean` (new)

**Implementation** (leveraging TruthTest.lean patterns):

```lean
import Bimodal.Semantics.Truth
import Bimodal.Semantics.TaskFrame
import BimodalTest.Automation.ProofSearchBenchmark  -- Reuse timing utilities

namespace BimodalTest.Semantics.Benchmark

open Bimodal.Syntax Bimodal.Semantics
open BimodalTest.Automation.Benchmark (timed formatNanos)

/-- Semantic benchmark with expected result validation. -/
structure SemanticBenchmarkResult where
  name : String
  expectedResult : Bool
  actualResult : Bool
  evaluationTimeNs : Nat
  correct : Bool := (expectedResult == actualResult)
  deriving Repr

/-- Reuse test fixtures from TruthTest. -/
def benchFrame : TaskFrame Int := TaskFrame.trivial_frame
def benchModel : TaskModel benchFrame where
  valuation := fun _ p => p = "p"  -- "p" true, all else false
def benchHistory : WorldHistory benchFrame := WorldHistory.trivial

/-- Run semantic benchmark with timing and validation. -/
def runSemanticBenchmark (name : String) (φ : Formula) (expected : Bool)
    (iterations : Nat := 100) : IO SemanticBenchmarkResult := do
  let mut times : Array Nat := #[]
  let mut result : Bool := false
  for _ in [:iterations] do
    let (r, timeNs) ← timed (pure (decide (truth_at benchModel benchHistory 0 trivial φ)))
    times := times.push timeNs
    result := r
  let sortedTimes := times.toList.mergeSort (· ≤ ·)
  let medianTime := sortedTimes.get! (sortedTimes.length / 2)
  return { name, expectedResult := expected, actualResult := result,
           evaluationTimeNs := medianTime }
```

**Benchmark categories**:

```lean
-- Category 1: Atomic evaluation (baseline)
def atomicBenchmarks : List (String × Formula × Bool) := [
  ("Atom p (true)", Formula.atom "p", true),
  ("Atom q (false)", Formula.atom "q", false),
  ("Bot (false)", Formula.bot, false)
]

-- Category 2: Nested modal formulas (depth scaling)
def modalDepthBenchmarks : List (String × Nat × Bool) := [
  ("Box depth 1", 1, true),   -- □p at trivial frame = true
  ("Box depth 3", 3, true),
  ("Box depth 5", 5, true)
]

-- Category 3: Temporal formulas
def temporalBenchmarks : List (String × Formula × Bool) := [
  ("Gp (all future)", Formula.all_future (Formula.atom "p"), true),
  ("Hp (all past)", Formula.all_past (Formula.atom "p"), true)
]

-- Category 4: Complex formulas (implication chains)
def complexBenchmarks : List (String × Formula × Bool) := [
  ("p → p (true)", (Formula.atom "p").imp (Formula.atom "p"), true),
  ("p → q (false)", (Formula.atom "p").imp (Formula.atom "q"), false),
  ("¬⊥ (true)", Formula.bot.neg, true)
]
```

**Verification**:
- All `correct` fields are `true` (expected matches actual)
- `lake build BimodalTest.Semantics.SemanticBenchmark` succeeds
- Timing scales reasonably with formula depth

---

### Phase 3: Performance Targets Documentation

**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Prerequisite**: Phase 1 and 2 must be complete (needs actual measurements).

**Objectives**:
1. Run all benchmarks to establish baselines
2. Document realistic targets based on measurements
3. Define regression thresholds

**Files to create**:
- `Bimodal/docs/ProjectInfo/PERFORMANCE_TARGETS.md` (new)

**Steps**:

1. **Run all benchmarks and capture output**:
   ```bash
   lake env lean --run BimodalTest/Automation/ProofSearchBenchmark.lean > proof_search_baseline.txt
   lake env lean --run BimodalTest/ProofSystem/DerivationBenchmark.lean > derivation_baseline.txt
   lake env lean --run BimodalTest/Semantics/SemanticBenchmark.lean > semantic_baseline.txt
   ```

2. **Document baselines in PERFORMANCE_TARGETS.md**:

```markdown
# Bimodal Performance Targets

*Last updated: 2026-01-11*
*Baseline system: [describe hardware/Lean version]*

## Proof Search Benchmarks

| Benchmark | Baseline Time | Max Visits | Regression Threshold |
|-----------|---------------|------------|----------------------|
| Modal T axiom | {measured} | {measured} | 2x time OR 50% visits |
| Modal 4 axiom | {measured} | {measured} | 2x time OR 50% visits |
| Complex bimodal | {measured} | {measured} | 2x time OR 50% visits |

## Derivation Construction

| Benchmark | Baseline Time | Tree Height | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Simple axiom | {measured} | {measured} | 2x time |
| MP chain (depth 5) | {measured} | {measured} | 2x time |

## Semantic Evaluation

| Benchmark | Baseline Time | Correctness | Regression Threshold |
|-----------|---------------|-------------|----------------------|
| Atomic eval | {measured} | PASS | 2x time |
| Modal depth 3 | {measured} | PASS | 2x time |

## Regression Policy

A regression is flagged when ANY of these conditions occur:
- Time increases by **>2x** for any benchmark
- Visits increase by **>50%** for proof search
- Any semantic benchmark returns **incorrect result**

## Optimization Recommendations

Based on benchmark analysis:
1. For modal-heavy proofs: configure `modalBase=3`
2. For temporal-heavy proofs: configure `temporalBase=3`
3. For deep proofs: use IDDFS with increased maxDepth
```

**Verification**:
- All baseline values are filled from actual measurements
- Thresholds are documented
- File is valid Markdown

---

### Phase 4: CI Integration (Minimal)

**Status**: [NOT STARTED]
**Estimated effort**: 1.5 hours

**Objectives**:
1. Create benchmark runner script
2. Add JSON output to all benchmarks
3. Create simple regression checker script

**Note**: GitHub Actions workflow is optional (only if `.github/workflows/` exists).

**Files to create/modify**:
- `scripts/run-benchmarks.sh` (new)
- `scripts/check-regression.sh` (new)
- `benchmarks/baseline.json` (new)

**Step 1: Add JSON output to benchmarks**

Add to each benchmark file:

```lean
/-- Convert result to JSON for CI. -/
def resultToJson (r : BenchmarkResult) : String :=
  s!"\{\"name\":\"{r.name}\",\"timeNs\":{r.timeNs},\"visits\":{r.visits}\}"

def allResultsToJson (results : List BenchmarkResult) : String :=
  "[" ++ ",".intercalate (results.map resultToJson) ++ "]"
```

**Step 2: Create benchmark runner**

```bash
#!/bin/bash
# scripts/run-benchmarks.sh
set -e

echo "Running Bimodal benchmarks..."

# Run each benchmark suite
lake env lean --run BimodalTest/Automation/ProofSearchBenchmark.lean 2>/dev/null |
  grep -E '^\{' > /tmp/proof_search.json || true

lake env lean --run BimodalTest/ProofSystem/DerivationBenchmark.lean 2>/dev/null |
  grep -E '^\{' > /tmp/derivation.json || true

lake env lean --run BimodalTest/Semantics/SemanticBenchmark.lean 2>/dev/null |
  grep -E '^\{' > /tmp/semantic.json || true

# Combine results
echo '{"proof_search":' > benchmarks/current.json
cat /tmp/proof_search.json >> benchmarks/current.json
echo ',"derivation":' >> benchmarks/current.json
cat /tmp/derivation.json >> benchmarks/current.json
echo ',"semantic":' >> benchmarks/current.json
cat /tmp/semantic.json >> benchmarks/current.json
echo '}' >> benchmarks/current.json

echo "Benchmarks complete: benchmarks/current.json"
```

**Step 3: Create regression checker**

```bash
#!/bin/bash
# scripts/check-regression.sh
set -e

BASELINE="benchmarks/baseline.json"
CURRENT="benchmarks/current.json"
THRESHOLD=2.0  # 2x slowdown

if [ ! -f "$BASELINE" ]; then
  echo "No baseline found. Saving current as baseline."
  cp "$CURRENT" "$BASELINE"
  exit 0
fi

# Simple check using jq (if available) or grep
# For each benchmark, check if current_time > baseline_time * THRESHOLD

echo "Comparing against baseline..."
# Detailed comparison logic here
# Exit 1 if regression detected, 0 otherwise

echo "No regressions detected."
exit 0
```

**Verification**:
- `./scripts/run-benchmarks.sh` executes without error
- `benchmarks/current.json` is valid JSON
- `./scripts/check-regression.sh` exits 0 on first run

---

## Dependencies

```
Phase 1 ──┬──► Phase 3 ──► Phase 4
Phase 2 ──┘
```

- Phase 1 and Phase 2: **No dependencies** (run in parallel)
- Phase 3: Depends on Phase 1 and 2 (needs measurements)
- Phase 4: Depends on Phase 3 (needs baseline document)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Timing variability | Medium | Multiple iterations with median (implemented) |
| Import from ProofSearchBenchmark fails | Low | Copy `timed`/`formatNanos` if needed |
| Semantic Decidable instance missing | Medium | Use explicit evaluation, not `decide` |
| No jq available for CI | Low | Use grep-based parsing fallback |

## Success Criteria

- [ ] `lake build BimodalTest.ProofSystem.DerivationBenchmark` succeeds
- [ ] `lake build BimodalTest.Semantics.SemanticBenchmark` succeeds
- [ ] All semantic benchmarks report `correct = true`
- [ ] PERFORMANCE_TARGETS.md contains measured baselines
- [ ] `./scripts/run-benchmarks.sh` produces valid JSON
- [ ] `./scripts/check-regression.sh` exits 0 on matching baseline
- [ ] Project builds without errors after all phases

## Effort Summary

| Phase | v001 Estimate | v002 Estimate | Change |
|-------|---------------|---------------|--------|
| Phase 1 | 3 hours | 2.5 hours | -0.5h (reuse patterns) |
| Phase 2 | 2 hours | 2 hours | — |
| Phase 3 | 1 hour | 1 hour | — |
| Phase 4 | 2 hours | 1.5 hours | -0.5h (simplified scope) |
| **Total** | **8 hours** | **7 hours** | **-1h** |
