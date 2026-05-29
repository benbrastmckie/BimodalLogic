# Research Report: Task 204 -- Production Dataset Generation

**Task**: 204 -- Run production dataset generation (medium and deep runs)
**Status**: Researched
**Session**: sess_1748563200_orch204
**Date**: 2026-05-29

## 1. Current API Surface for Dataset Generation

### Core Pipeline (DatasetExport.lean -- the CLI executable)

The compiled executable `lake exe dataset_generator` is the primary entry point. It uses `EnumParams` (legacy API) internally.

**CLI Arguments** (`CLIArgs` structure):

| Flag | Default | Description |
|------|---------|-------------|
| `--max-complexity N` | 5 | Maximum formula complexity (connective count + 1) |
| `--max-modal-depth N` | 2 | Maximum box nesting depth |
| `--max-temporal-depth N` | 2 | Maximum untl/snce nesting depth |
| `--max-formulas N` | 5000 | Cap on total formulas generated |
| `--output PATH` | `data/bmlogic.jsonl` | Output JSONL file path |
| `--mode MODE` | exhaustive | One of: `exhaustive`, `random`, `hybrid` |
| `--include-duals` | false | Enable temporal dual augmentation (2x boost) |

### Key Functions in Pipeline Order

1. **`generateFormulas(params)`** (FormulaEnumerator.lean) -- Dispatches based on `SamplingMode`:
   - `exhaustive`: `enumerateExhaustive` -- generates all formulas 1..maxComplexity, deduplicates, filters (complexity >= 3, has modal/temporal op), caps at maxFormulas
   - `random`: `sampleRandom` -- IO.rand-based grammar generation, generates 3x candidates then filters
   - `hybrid`: exhaustive up to min(5, maxComplexity) for half the budget, random for the rest

2. **`enrichWithDuals(formulas)`** (FormulaEnumerator.lean) -- Applies `swap_temporal` (exchanges untl<->snce) for free 2x augmentation. Deduplicates after.

3. **`labelBatch(formulas)`** (DatasetGenerator.lean) -- Calls `labelFormula` on each:
   - Runs `decideAuto(phi)` first (fuel = 10 * complexity + 100, searchDepth = 5 + complexity/2)
   - On timeout, retries with `decideOptimized(phi)` (IDDFS at depth 20, then full tableau)
   - Extracts ProofTrace (valid) or SimpleCountermodel (invalid)
   - Computes DifficultyMetrics and PatternKey
   - Reports progress every 100 formulas

4. **`writeDatasetJSONL(path, labeled)`** (DatasetExport.lean) -- Streams JSONL with deterministic split assignment (hash-based 80/10/10 train/val/test)

5. **`writeMetadata(path, metadata)`** -- Companion `_metadata.json` file

### EnumParams (Legacy API used by CLI)

```lean
structure EnumParams where
  maxComplexity : Nat := 5
  maxModalDepth : Nat := 2
  maxTemporalDepth : Nat := 2
  atoms : List Atom := [p, q, r]  -- 3 atoms
  maxFormulas : Nat := 5000
  samplingMode : SamplingMode := .exhaustive
```

### EnumConfig (Newer API used by DatasetExporter/Validator)

```lean
structure EnumConfig where
  maxModalDepth : Nat
  maxTemporalDepth : Nat
  maxSize : Nat  -- corresponds to maxComplexity
  atomPool : List Atom
```

Predefined configs: `smallConfig` (2,2,8,3-atoms), `mediumConfig` (3,3,12,5-atoms).

## 2. Enumeration Modes and Complexity Parameters

### Formula Complexity Definition

`complexity : Formula -> Nat` counts connective nodes + 1 for leaves:
- atom, bot: 1
- imp, untl, snce: 1 + left.complexity + right.complexity
- box: 1 + child.complexity

### Mode Behavior

| Mode | Behavior | Formula Count | Deterministic |
|------|----------|---------------|---------------|
| `exhaustive` | Generate all formulas at each complexity 1..N | Exact (exponential in N) | Yes |
| `random` | IO.rand grammar-based sampling, 3x overgenerate | Approximate (up to maxFormulas) | No (IO.rand) |
| `hybrid` | Exhaustive up to min(5,N) for 50%, random for rest | Mixed | Partial |

### Rejection Filter (`passesFilter`)

Formulas are rejected if:
- `complexity < 3` (trivially small)
- Pure propositional (no box, untl, or snce operators)

### Atom Pool

The CLI uses `defaultAtoms = [p, q, r]` (3 atoms). The newer `EnumConfig` API supports up to 5 atoms (`defaultAtomPool = [p, q, r, s, t]`). The CLI does NOT expose an atom count parameter -- it is hardcoded to 3.

**Potential Issue**: Only 3 atoms may limit diversity for higher complexity formulas. Consider extending the CLI to accept `--atoms N` or switching to the newer API.

### Temporal Dual Augmentation

`enrichWithDuals` applies `swap_temporal` which exchanges `untl <-> snce`. For formulas containing temporal operators, this provides a free second formula. After deduplication, this approximately doubles the temporal-formula count.

## 3. Export Format and File Paths

### JSONL Output Format

Each line is a JSON object:
```json
{
  "id": "bmlogic-00001",
  "split": "train"|"val"|"test",
  "formula_str": "(box p -> p)",
  "formula_ast": {"tag": "imp", "left": {"tag": "box", ...}, ...},
  "frame_class": "Base",
  "label": "valid"|"invalid"|"timeout",
  "proof_trace": {"height": 0, "axioms_used": ["modal_t"], "rules_applied": []} | null,
  "countermodel": {"trueAtoms": [...], "falseAtoms": [...], "formula": {...}} | null,
  "pattern_key": {"modalDepth": 1, "temporalDepth": 0, "impCount": 1, "complexity": 3, "topOperator": "Box"},
  "metrics": {"complexity": 3, "modalDepth": 1, "temporalDepth": 0, "impCount": 1, "atomCount": 1, "decisionTimeMs": 0, "difficultyTier": "easy"},
  "augmentation": null | {"source": "...", "original_formula_str": "..."}
}
```

### Split Assignment

Deterministic hash-based: `hash(formula_str) % 100` maps to train (0-79), val (80-89), test (90-99).

### File Locations

- Output JSONL: `data/bmlogic.jsonl` (default) or as specified by `--output`
- Metadata: `data/bmlogic_metadata.json` (derived from output path, replacing `.jsonl` with `_metadata.json`)
- Gitignore: `data/.gitignore` excludes `*.jsonl` and `*_metadata.json`

### Existing Data

- `data/test.jsonl` -- 50 records, complexity 3, 0% timeout, 36% valid (from task 203 validation)
- `data/.gitignore` -- properly configured

## 4. Feasibility Gate Metrics and Thresholds

### DatasetValidator.lean Feasibility Gate

`evaluateGate(report, minFormulas, hardMinFormulas)` checks:

**Pass Criteria (all must hold)**:
1. Total formulas >= `hardMinFormulas` (default 1000)
2. Provability ratio in [0.15, 0.70]
3. Proof height variance > 2.0
4. At least 3 GoalCategory types each > 10% of dataset
5. Not >80% trivially propositional (Implication + Atom + Bottom)
6. Not >90% same decision (all valid or all invalid)

**Soft Warning** (non-blocking):
- Total formulas < `minFormulas` (default 10000)

### CLI Feasibility Checks (DatasetExport.lean)

The CLI `main` prints simpler checks:
- Timeout rate: target < 20%
- Valid fraction: target >= 30%
- Category diversity: number of GoalCategory types

**Important Discrepancy**: The CLI checks are informational only (print, no fail). The formal `evaluateGate` in DatasetValidator is the authoritative gate but is only invoked through `lake exe dataset_validator`.

### Task 203 Validation Baseline (Complexity 3, 50 formulas)

- Timeout rate: 0% -- PASS
- Valid fraction: 36% -- PASS
- Category diversity: 3 types -- PASS

### Complexity 4 Test Run (200 formulas, this session)

- Timeout rate: 1% -- PASS
- Valid fraction: 18% -- **BELOW 30% TARGET**
- Category diversity: 3 types -- PASS

The valid fraction drops at higher complexity because more complex formulas are more likely to be invalid. This is expected -- temporal/modal formulas without careful construction tend to be non-theorems.

## 5. Existing Production Run Infrastructure

### Lake Executable Targets

```lean
-- lakefile.lean
lean_exe dataset_generator where
  root := `Bimodal.Automation.DatasetExport
  srcDir := "Theories"
  supportInterpreter := true

lean_exe dataset_validator where
  root := `Bimodal.Automation.DatasetValidator
  srcDir := "Theories"
  supportInterpreter := true
```

Both build successfully. Build is cached after first compilation (~3 min full build).

### No Existing Production Run Scripts

There are no shell scripts, Makefiles, or other automation for production runs. The task 203 summary documents CLI usage examples but they were not packaged as executable scripts.

### Task 203 CLI Examples (from summary)

```bash
# Quick test (complexity 3, ~50 formulas)
lake exe dataset_generator -- --max-complexity 3 --max-formulas 50 --output data/test.jsonl

# Fast run (complexity 5, ~5K formulas with temporal duals)
lake exe dataset_generator -- --max-complexity 5 --max-formulas 5000 --output data/bmlogic-fast.jsonl --include-duals

# Deep run (complexity 7, hybrid mode)
lake exe dataset_generator -- --max-complexity 7 --max-formulas 50000 --output data/bmlogic-deep.jsonl --mode hybrid --include-duals
```

## 6. Decision Procedure Performance Characteristics

### Fuel and Timeout Behavior

`decideAuto(phi)` uses:
- `fuel = recommendedFuel(phi) = 10 * phi.complexity + 100`
- `searchDepth = 5 + phi.complexity / 2`

For complexity 5: fuel = 150, depth = 7
For complexity 7: fuel = 170, depth = 8
For complexity 9: fuel = 190, depth = 9

On timeout, `decideOptimized` retries with IDDFS(depth=20) then full `decide(phi)` with default params (fuel=1000, depth=10).

### Performance at Different Complexities

| Complexity | Fuel | Est. Formulas (exhaustive, 3 atoms) | Decision Time | Timeout Risk |
|------------|------|--------------------------------------|---------------|--------------|
| 3 | 130 | ~50 | <1ms each | Negligible |
| 4 | 140 | ~200+ | <1ms each | ~1% |
| 5 | 150 | ~5000+ | 0-10ms each | ~2-5% |
| 7 | 170 | Exponential (needs hybrid) | Variable | ~5-15% |

### Memory Considerations

- `enumerateExhaustive` at complexity 7 generates an exponential number of formulas in memory as `List Formula`, then deduplicates. This can be extremely memory-intensive.
- The `hybrid` mode mitigates this: exhaustive only up to complexity 5, random sampling above.
- `labelBatch` accumulates `List LabeledFormula` in memory before writing. For 50K formulas, this could be significant.

**Critical Risk**: The entire pipeline is batch-based (generate all, then label all, then write all). For 50K formulas, this means holding all formulas + all labeled results in memory simultaneously.

## 7. Recommendations for Production Runs

### Medium Run (Complexity 5, ~5K formulas)

**Recommended Command**:
```bash
lake exe dataset_generator -- \
  --max-complexity 5 \
  --max-modal-depth 3 \
  --max-temporal-depth 3 \
  --max-formulas 5000 \
  --output data/bmlogic-medium.jsonl \
  --include-duals
```

**Rationale**:
- Complexity 5, modal/temporal depth 3 gives a good variety
- `--include-duals` approximately doubles temporal formulas (free augmentation)
- Exhaustive mode (default) is appropriate at complexity 5 -- should enumerate well within the 5K cap
- Estimated runtime: 10-30 minutes (most time in labeling)

**Expected Feasibility**:
- Timeout rate: likely 1-5% (PASS, < 20%)
- Valid fraction: likely 15-25% (may be below 30% target -- see discussion below)
- Category diversity: likely 3-5 types (PASS)

### Deep Run (Complexity 7, ~50K formulas)

**Recommended Command**:
```bash
lake exe dataset_generator -- \
  --max-complexity 7 \
  --max-modal-depth 3 \
  --max-temporal-depth 3 \
  --max-formulas 50000 \
  --output data/bmlogic-deep.jsonl \
  --mode hybrid \
  --include-duals
```

**Rationale**:
- Hybrid mode: exhaustive up to complexity 5 (complete coverage), random for 6-7 (sampling)
- `--include-duals` for augmentation
- Modal/temporal depth 3 keeps the tableau tractable

**Expected Feasibility**:
- Timeout rate: likely 5-15% (PASS if under 20%)
- Valid fraction: likely 10-20% (may fail the >= 30% target)
- Category diversity: likely 4-6 types (PASS)

**Expected Runtime**: 2-12 hours depending on timeout retry behavior. The `decideOptimized` retry on timeouts adds overhead per formula.

### Feasibility Gate Concern: Valid Fraction

The valid fraction target (>= 30%) may be difficult to meet at higher complexity. At complexity 4 (200 formulas), the valid fraction was only 18%. Higher complexity formulas are overwhelmingly invalid because:
1. Random/exhaustive enumeration produces mostly structurally arbitrary formulas
2. Most bimodal logic formulas are NOT theorems
3. Validity requires specific structural patterns (axiom instances, derived theorems)

**Mitigation Options** (for implementation planning):
1. **Accept lower valid fraction**: The feasibility gate in the CLI is informational only (prints, does not abort). The formal `evaluateGate` with `hardMinFormulas` is separate. The provability ratio [0.15, 0.70] range allows down to 15%.
2. **Seed with known valid formulas**: Inject the `knownValidFormulas` list (10 formulas) and generated axiom instances to boost valid count.
3. **Increase modal depth**: Formulas with box operators tend to be more often valid (Modal T, K, 4, B axiom instances). Higher `--max-modal-depth` may increase valid fraction.
4. **Post-hoc enrichment**: After generation, add constructed valid formulas (axiom instances at various atom substitutions) to the dataset.

## 8. Potential Issues and Blockers

### Issue 1: Batch Memory Usage (HIGH for deep run)

The pipeline loads all formulas into a `List Formula`, labels them all into `List LabeledFormula`, then writes. For 50K formulas with proof traces and countermodels, memory usage could be significant (estimated 1-4 GB).

**Mitigation**: Monitor memory during run. If it fails, reduce `--max-formulas` or implement streaming export (write records as they are labeled).

### Issue 2: Valid Fraction Below Target (MEDIUM)

As discussed in Section 7, the valid fraction may fall below the 30% target. The feasibility gate in the formal `evaluateGate` allows 15-70%, so this is a soft concern. The CLI check is informational.

### Issue 3: Non-Determinism of Random Mode (LOW)

When using `--mode random` or `--mode hybrid`, the random portion uses `IO.rand`, making results non-reproducible. The deterministic `sampleFormulas` (LCG-based) from the newer API is not accessible via CLI.

**Mitigation**: For reproducibility, use exhaustive mode where feasible. For deep runs requiring hybrid, document the run parameters but accept non-determinism.

### Issue 4: Atom Pool Limited to 3 (LOW)

The CLI hardcodes 3 atoms (p, q, r). The newer API supports 5 (p, q, r, s, t). More atoms enable more diverse formulas.

**Mitigation**: This is a minor concern. 3 atoms with complexity 5-7 still produces good diversity.

### Issue 5: No Streaming Export (MEDIUM for deep run)

All formulas are held in memory before export. For the deep run, this is the primary scalability concern.

### Issue 6: Dual Augmentation Labels (LOW)

`enrichWithDuals` applies `swap_temporal` before labeling. The dual formulas are labeled independently by the decision procedure. Temporal duality preserves validity for valid formulas, but the dual of an invalid formula may or may not be invalid. This is handled correctly (each formula is labeled independently), but the augmentation metadata does not track which formulas are duals.

## 9. Validation Strategy

### For Each Production Run

1. **Run the generator** with the specified parameters
2. **Check the metadata file** for timeout rate, valid count, invalid count
3. **Run `lake exe dataset_validator`** for formal feasibility gate evaluation
4. **Spot-check JSONL** -- verify well-formed JSON, fields present, proof traces non-empty for valid, countermodels non-empty for invalid
5. **Check PatternKey diversity** -- count distinct GoalCategory types in output
6. **Report feasibility gate results** -- pass/fail with specific metrics

### Validation Commands

```bash
# Quick metadata check
cat data/bmlogic-medium_metadata.json

# Count records by label
grep -c '"valid"' data/bmlogic-medium.jsonl
grep -c '"invalid"' data/bmlogic-medium.jsonl
grep -c '"timeout"' data/bmlogic-medium.jsonl

# Run formal validator (on smallConfig only -- does NOT validate production files)
lake exe dataset_validator
```

**Note**: The `dataset_validator` executable runs its own enumeration + labeling on `smallConfig`. It does NOT validate an existing JSONL file. To validate the production dataset files, a separate validation script or #eval command would be needed.

## 10. Summary of Findings

| Aspect | Status | Notes |
|--------|--------|-------|
| CLI executable | Ready | Builds successfully, tested at complexity 3 and 4 |
| Exhaustive enumeration | Ready | Works up to complexity ~5 |
| Hybrid mode | Ready | Needed for complexity 7 |
| Temporal duals | Ready | `--include-duals` flag |
| JSONL export | Ready | Well-formed output confirmed |
| Metadata export | Ready | Companion `_metadata.json` files |
| Feasibility gate (CLI) | Informational | Prints metrics but does not abort |
| Feasibility gate (formal) | Separate tool | `dataset_validator` runs own test, not on production files |
| Memory scalability | Concern | Batch pipeline holds all data in memory |
| Valid fraction at high complexity | Concern | May fall below 30% target |
| data/ directory | Ready | Exists with .gitignore |
| Production scripts | Missing | No shell scripts; CLI commands documented |

## 11. Recommended Implementation Plan

### Phase 1: Medium Run (30 min active + compute)

1. Build the executable (cached): `lake build dataset_generator`
2. Run medium generation:
   ```bash
   lake exe dataset_generator -- --max-complexity 5 --max-modal-depth 3 --max-temporal-depth 3 --max-formulas 5000 --output data/bmlogic-medium.jsonl --include-duals
   ```
3. Verify output: check metadata, count records by label, spot-check JSONL
4. Evaluate feasibility: timeout rate < 20%, valid fraction >= 15%, 3+ GoalCategory types

### Phase 2: Deep Run (overnight compute)

1. Run deep generation:
   ```bash
   lake exe dataset_generator -- --max-complexity 7 --max-modal-depth 3 --max-temporal-depth 3 --max-formulas 50000 --output data/bmlogic-deep.jsonl --mode hybrid --include-duals
   ```
2. Monitor for memory issues (if OOM, reduce to 25K or 10K)
3. Verify output: same checks as medium
4. Evaluate feasibility: timeout rate < 20%, valid fraction >= 15%

### Phase 3: Documentation and Validation Summary

1. Write summary of both runs with actual metrics
2. Document any deviations from targets
3. File the results for downstream tasks (205 benchmark curation, ML training)
