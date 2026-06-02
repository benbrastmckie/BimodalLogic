# Research Report: Smoke-Test Dataset Generation at C5

- **Task**: 263 - Smoke-test dataset generation at complexity 5
- **Started**: 2026-06-02T10:00:00Z
- **Session**: sess_1780419548_f5b792
- **Effort**: light (2-4 hours)
- **Dependencies**: Task 261 (completed)
- **Artifacts**: specs/263_smoke_test_c5_dataset_generation/reports/01_smoke-test-c5.md

## Executive Summary

A c5 dataset already exists at `data/bmlogic-c5.jsonl` (generated after task 261 fixes). It contains 1,512 records produced by exhaustive enumeration at max complexity 5 on Base frame class. Analysis of this dataset confirms that the task 261 fixes (fuel bounding, per-record flush, eventuality-aware blocking) are working correctly for c5 complexity. The previously-problematic formula `(box(bot) -> box(r))` now resolves correctly as valid. However, 39 formulas (2.6%) still time out, and these fall into two known patterns that represent remaining algorithmic gaps rather than stalling.

---

## 1. Dataset Generation Infrastructure

### 1.1 Code Location

The dataset generation pipeline consists of these files:

| File | Role |
|------|------|
| `Theories/Bimodal/Automation/DatasetExport.lean` | CLI entry point (`main`), JSONL streaming, argument parsing |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | `labelFormula`, proof trace extraction, metrics computation |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Formula enumeration (exhaustive, random, hybrid, stratified) |
| `Theories/Bimodal/Automation/DataExport.lean` | JSON serialization primitives (`toJson`, `prettyPrint`, `toSExpr`) |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | `decideAutoAdaptive`, `decide`, `soundFuel` |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | `buildTableau`, `expandBranchWithFuel`, blocking logic |

### 1.2 How to Run at C5

The dataset generator is a Lake executable:

```bash
lake exe dataset_generator -- --max-complexity 5 --output data/bmlogic-c5.jsonl
```

Full CLI options:
- `--max-complexity N` (default: 5)
- `--max-modal-depth N` (default: 2)
- `--max-temporal-depth N` (default: 2)
- `--max-formulas N` (default: 5000)
- `--valid-seed-count N` (default: 500)
- `--output PATH` (default: `data/bmlogic.jsonl`)
- `--mode MODE` (exhaustive|random|hybrid|stratified)
- `--include-duals` (add temporal dual augmentation)
- `--frame-class CLASS` (Base|Dense|Discrete, default: Base)
- `--resume-from N` (skip first N formulas for checkpoint resume)

The lakefile defines the executable at line 38:
```lean
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
```

### 1.3 Existing C5 Dataset

A c5 dataset was already generated and exists at:
- **Data file**: `data/bmlogic-c5.jsonl` (3.3 MB, 1,512 records)
- **Metadata**: `data/bmlogic-c5_metadata.json`
- **Generated**: 2026-06-02 (after task 261 fixes)

---

## 2. Decision Procedure and Fuel Parameters

### 2.1 Decision Pipeline

`labelFormula` in `DatasetGenerator.lean` calls `decideAutoAdaptive` which uses an escalating fuel strategy:

```
Tier 1: fuel=500,   label="adaptive_500"
Tier 2: fuel=2000,  label="adaptive_2000"
Tier 3: fuel=10000, label="adaptive_10000"
Fallback: label="adaptive_timeout"
```

Within each tier, `decide` runs this pipeline:
1. **Fast path**: `tryAxiomProof` -- direct axiom instance matching
2. **Compositional fast path**: `buildCompositionalProof` -- box-valid patterns (task 261)
3. **Proof search**: `bounded_search_with_proof` at depth `5 + complexity/2`
4. **Tableau**: `buildTableau` at the tier's fuel level with `FrameClass` parameter

### 2.2 Fuel Bounding (Task 261)

Task 261 introduced three fuel-related fixes:

1. **Adaptive fuel tiers**: Instead of using `soundFuel` (which can reach 100,000), the adaptive strategy caps at 10,000 across three tiers.

2. **Fuel division in splits**: In `expandBranchWithFuel`, when a branching rule fires, fuel is divided among sub-branches: `branchFuel = fuel / max(1, branches.length)`. This bounds total work to O(fuel) instead of O(2^fuel).

3. **Sound fuel bound**: `soundFuel(phi) = min(n * 2^n, 100000)` where n = |subformulaClosure(phi)|.

### 2.3 Compositional Proof Fast Path

Added in task 261 v1, `buildCompositionalProof` handles box-valid formulas like `box(X -> X)`, `(box(bot) -> Y)`, and similar patterns via necessitation without needing the full tableau.

---

## 3. Per-Record Flush

### 3.1 Implementation

In `DatasetExport.lean` at line 911, after each JSONL record is written:

```lean
writeRecordJSONL handle record
-- Task 261 v3: flush after each record to prevent data loss on crash/kill
handle.flush
```

This ensures that if the process is killed mid-generation, all completed records are on disk. Previously, buffered I/O could lose the last batch of records on crash.

### 3.2 Slow-Formula Warning

Also from task 261, any formula taking >1000ms triggers a stderr warning:
```lean
if labeled.metrics.decisionTimeMs > 1000 then
  IO.eprintln s!"[warn] Slow formula (#{count + 1}): ..."
```

---

## 4. Eventuality-Aware Blocking

### 4.1 Problem

Until/Since formulas like `U(bot, X) -> Y` previously caused infinite loops: the `untlPos` rule branches into event-witness (bot at fresh time, immediately closes) vs guard-continue (re-introduces `T(U(bot, X))` at a fresh time). Without blocking, this creates an unbounded chain of time points.

### 4.2 Solution

Task 261 v3 added eventuality-aware blocking in `expandBranchWithFuel` (Saturation.lean lines 99-131, 157-165):

1. **EventualityTracker**: Registers pending Until/Since obligations and tracks fulfillment
2. **registerEventualities**: Scans the branch for Until/Since formulas, registering their event components
3. **fulfillEventualities**: Checks if pending eventualities are witnessed at reachable times
4. **findBlockedTime**: Now accepts an `EventualityTracker` parameter; blocking only fires when `allEventualitiesFulfilledOrDuplicated` confirms all pending eventualities are safe

### 4.3 Current Status

Despite this fix, Until/Since patterns `U(bot, X) -> Y` and `S(bot, X) -> Y` still produce timeouts at c5 (32 of 39 timeouts). These are all provably valid formulas. The eventuality-aware blocking may need further refinement, or the fuel caps (10,000 max) are too low for these particular patterns.

---

## 5. Analysis of the Existing C5 Dataset

### 5.1 Overall Statistics

| Metric | Value |
|--------|-------|
| Total records | 1,512 |
| Valid | 99 (6.5%) |
| Invalid | 1,374 (90.9%) |
| Timeout | 39 (2.6%) |
| Frame class | Base |
| Sampling mode | exhaustive |
| Max complexity | 5 |

### 5.2 Decision Method Distribution

| Method | Count |
|--------|-------|
| `adaptive_500` | 1,410 |
| `fast_path_axiom` | 63 |
| `adaptive_timeout` | 39 |

All non-timeout formulas resolved at the first fuel tier (500), indicating c5 formulas are computationally easy for the decision procedure. The 63 `fast_path_axiom` formulas were caught by `tryAxiomProof` without needing the tableau at all.

### 5.3 JSONL Field Population

All 22 expected JSONL fields are present in every record. The field null/populated pattern is correct:

- **Valid records (99)**: `proof_trace`, `rule_profile`, `proof_reconstruction_method` are populated; `countermodel`, `enriched_countermodel`, `semantic_countermodel` are null (correct)
- **Invalid records (1,374)**: `countermodel`, `countermodel_consistent`, `enriched_countermodel`, `semantic_countermodel` are populated; `proof_trace`, `rule_profile` are null (correct)
- **Timeout records (39)**: All proof/countermodel fields are null (correct -- no result to report)
- **All records**: `decision_method`, `metrics`, `pattern_key`, `formula_str`, `formula_ast`, etc. are always populated
- **`augmentation`**: Always null (correct -- no dual augmentation was used)

No null metrics detected in any record. All metrics fields (`complexity`, `modalDepth`, `temporalDepth`, `impCount`, `atomCount`, `decisionTimeMs`, `difficultyTier`) are populated for every record.

### 5.4 Previously-Problematic Formula: (box(bot) -> box(r))

The task description mentions that formulas like `(box(bot) -> box(r))` previously timed out. In the current c5 dataset:

| Formula | ID | Label | Method |
|---------|-----|-------|--------|
| `(□⊥ → □r)` | bmlogic-00888 | **valid** | adaptive_500 |
| `(□⊥ → r)` | bmlogic-00136 | **valid** | adaptive_500 |
| `(□⊥ → ⊥)` | bmlogic-00133 | **valid** | fast_path_axiom |
| `(□⊥ → p)` | bmlogic-00134 | **valid** | adaptive_500 |
| `(□⊥ → q)` | bmlogic-00135 | **valid** | adaptive_500 |
| `(□⊥ → □p)` | bmlogic-00886 | **valid** | adaptive_500 |
| `(□⊥ → □q)` | bmlogic-00887 | **valid** | adaptive_500 |
| `(□⊥ → □⊥)` | bmlogic-00885 | **valid** | adaptive_500 |

All `box(bot) -> X` patterns resolve correctly as valid. The fix is working.

### 5.5 Remaining Timeout Analysis

The 39 timeout formulas fall into two distinct patterns:

**Pattern 1: Double-box formulas (7 timeouts)**
- `(□□⊥ → X)`: 4 formulas
- `(□□X → X)`: 3 formulas (for X in {p, q, r})

These are provably valid formulas. `□□⊥` implies `□⊥` (by modal S4: `□phi -> □□phi` reversed via transitivity in S5), and `□⊥ -> X` is valid. For `(□□X -> X)`, this is the S4 axiom composed with T: `□□X -> □X -> X`.

**Pattern 2: Until/Since with bot event (32 timeouts)**
- `U(⊥, X) → Y`: 16 formulas
- `S(⊥, X) → Y`: 16 formulas

These are all vacuously valid because `U(⊥, X)` requires `⊥` to eventually hold, which is impossible. The eventuality-aware blocking should handle these but apparently does not terminate within 10,000 fuel steps.

### 5.6 No Stalling Observed

The generation completed successfully with all 1,512 records written. The metadata file confirms the generation finished. No stalling was observed -- all 39 timeouts were labeled as `adaptive_timeout` and the pipeline continued past them.

---

## 6. Base Frame Class

### 6.1 Definition

`FrameClass` is an inductive type with three constructors:
- `.Base` -- standard TM bimodal logic frames (S5 modal + linear temporal)
- `.Dense` -- adds density axioms (no immediate successor)
- `.Discrete` -- adds discreteness axioms (has immediate successor)

### 6.2 Frame Class in Dataset

The c5 dataset uses `Base` exclusively. The `--frame-class` CLI flag (task 261 v3) allows selecting Dense or Discrete for separate generation runs.

---

## 7. Concrete Smoke Test Plan

Based on the analysis, a practical smoke test for c5 should verify the following:

### 7.1 Generation Completes Without Stalling

Run:
```bash
time lake exe dataset_generator -- --max-complexity 5 --output data/test-c5-smoke.jsonl
```

**Expected**: Completes in under 5 minutes. No process hang. Output file has 1,500+ records.

### 7.2 JSONL Well-Formedness

For each line in the output:
- Parse as JSON (no parse errors)
- All 22 standard fields present
- No null metrics (`complexity`, `modalDepth`, `temporalDepth`, `impCount`, `atomCount`, `decisionTimeMs`, `difficultyTier` all non-null)
- `decision_method` is always a string (never null)
- Valid records have non-null `proof_trace` and `rule_profile`
- Invalid records have non-null `countermodel` and `countermodel_consistent`

### 7.3 Timeout Rate

**Target**: < 5% timeout rate (current: 2.6%)

### 7.4 Key Formula Regression

These formulas should resolve correctly (not timeout):
- `(□⊥ → □r)` should be `valid`
- `(□⊥ → r)` should be `valid`
- `(□⊥ → ⊥)` should be `valid`
- `□(p → p)` should be `valid`
- `□(⊥ → p)` should be `valid`
- `(p → p)` should be `valid`
- `p` should be `invalid`
- `⊥` should be `invalid`

### 7.5 Per-Record Flush Verification

Kill the generator mid-run (e.g., after 5 seconds) and verify:
- The partial output file is valid JSONL (every line parses as JSON)
- No truncated last line
- Record count matches the number of complete lines

### 7.6 Metadata File Verification

Check `data/test-c5-smoke_metadata.json`:
- `total_records` matches `wc -l` of the JSONL file
- `valid_count + invalid_count + timeout_count == total_records`
- `frame_class` is `"Base"`
- `max_complexity` is `5`

### 7.7 Python-Side Validation Script

```python
import json
import sys

def validate_c5(path):
    total = valid = invalid = timeout = 0
    null_metrics = 0
    parse_errors = 0
    
    with open(path) as f:
        for i, line in enumerate(f, 1):
            try:
                r = json.loads(line)
            except json.JSONDecodeError:
                parse_errors += 1
                continue
            
            total += 1
            label = r.get('label')
            if label == 'valid': valid += 1
            elif label == 'invalid': invalid += 1
            elif label == 'timeout': timeout += 1
            
            # Check metrics non-null
            m = r.get('metrics', {})
            for field in ['complexity', 'modalDepth', 'temporalDepth', 'impCount', 
                          'atomCount', 'decisionTimeMs', 'difficultyTier']:
                if m.get(field) is None:
                    null_metrics += 1
            
            # Check decision_method non-null
            if r.get('decision_method') is None:
                null_metrics += 1
    
    timeout_rate = timeout * 100 / total if total > 0 else 0
    print(f"Total: {total}")
    print(f"Valid: {valid} ({valid*100/total:.1f}%)")
    print(f"Invalid: {invalid}")
    print(f"Timeout: {timeout} ({timeout_rate:.1f}%)")
    print(f"Parse errors: {parse_errors}")
    print(f"Null metric fields: {null_metrics}")
    print(f"PASS" if parse_errors == 0 and null_metrics == 0 and timeout_rate < 5 else "FAIL")

validate_c5(sys.argv[1])
```

---

## 8. Key Files Summary

| File | Purpose |
|------|---------|
| `lakefile.lean` (line 38) | Defines `dataset_generator` executable |
| `Theories/Bimodal/Automation/DatasetExport.lean` | CLI entry point, JSONL streaming, per-record flush |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | `labelFormula`, proof trace, countermodel extraction |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Formula enumeration at given complexity |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | `decideAutoAdaptive` (3-tier fuel) |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | Tableau expansion, blocking, eventuality tracking |
| `Theories/Bimodal/Automation/DatasetValidator.lean` | Conformance tests, diversity metrics |
| `data/bmlogic-c5.jsonl` | Existing c5 dataset (1,512 records) |
| `data/bmlogic-c5_metadata.json` | Dataset metadata |

---

## 9. Recommendations

### 9.1 The Existing C5 Dataset Is Already a Smoke Test

The existing `data/bmlogic-c5.jsonl` demonstrates that the pipeline works end-to-end at c5:
- No stalling (generation completed)
- JSONL well-formed (all fields populated)
- Key formulas resolved correctly (`(□⊥ → □r)` is valid)
- Timeout rate is 2.6% (below the 5% target)

### 9.2 Remaining Issues (Not Blocking)

1. **39 timeout formulas**: All are provably valid but exhaust 10,000 fuel. Two patterns:
   - Double-box: `(□□X → Y)` -- needs compositional proof extension for nested boxes
   - Until/Since with bot: `U(⊥, X) → Y` -- eventuality-aware blocking needs refinement
   
2. **Valid fraction is low (6.5%)**: Most formulas at c5 are invalid. The `--valid-seed-count` option adds axiom-seeded valid formulas but these were not used in this generation.

3. **augmentation field always null**: Temporal duals were not included (`--include-duals` not passed).

### 9.3 Implementation Plan for Smoke Test Task

Since the existing c5 dataset already demonstrates correctness, the implementation task should:

1. **Re-run generation** with `lake exe dataset_generator -- --max-complexity 5 --output data/test-c5-smoke.jsonl` to confirm reproducibility
2. **Validate JSONL** with the Python script above
3. **Check key regression formulas** against expected labels
4. **Verify no stalling** (wall-clock time < 5 minutes)
5. **Optionally**: Run with `--frame-class Dense` and `--frame-class Discrete` to verify frame class support
