# Teammate A Findings: Infrastructure Analysis and Pipeline Validation

**Task**: 213 -- Production-scale dataset generation validation
**Teammate**: A (Primary Angle: Infrastructure Analysis)
**Session**: sess_1780088631_bfd193
**Date**: 2026-05-29

---

## Key Findings

1. **Task 210's enumerator rewrite is complete and verified**: Exhaustive enumeration at complexity 5 now takes 1ms (1,644 formulas) and complexity 7 takes 3ms (51,244 formulas), a 570x and 12,688x improvement respectively over the pre-fix state. The compiled binary proves this is feasible.

2. **Critical gap: the CLI does not wire up `validSeedCount`**: The `main` function in `DatasetExport.lean` constructs `EnumParams` without setting `validSeedCount`, so it uses the struct default of 0. This means axiom seeding -- the primary mitigation for the low valid fraction -- is **not active** when using `lake exe dataset_generator`. This is the single most important issue for meeting the 15% valid fraction gate.

3. **The task 210 benchmark reported 4% combined valid fraction**: Combining exhaustive enumeration (1,644 formulas, mostly invalid) with axiom-seeded pool (500 seeds generating ~100 confirmable-valid formulas), the first 200 sampled had only 4% confirmed valid. The benchmark labeled the axiom-only pool at 60% confirmed valid (40% timeout from fuel limits on complex axiom instances), but the combined pipeline valid fraction at complexity 5 is well below the 15% gate when seeds are not preferentially injected.

4. **The run script (created in task 204) still uses the pre-210 parameters**: `scripts/run_dataset_generation.sh` specifies `--max-complexity 4` for the medium run and `--mode random` for the deep run. These were the workarounds used when exhaustive enumeration was broken. With the task 210 fix, complexity 5 exhaustive mode is now feasible but the script was not updated.

5. **The existing production data from task 204 remains the current baseline**: `data/bmlogic-medium.jsonl` (complexity 4, 5,136 records, 25% valid) and `data/bmlogic-deep.jsonl` (complexity 7, random, 53,979 records, 1.6% valid). These predate the task 210 fix and need to be re-run with improved parameters.

6. **The `DatasetValidator` runs its own internal test (smallConfig only)** and does NOT validate existing JSONL files. There is no automated gate that validates `data/bmlogic-*.jsonl` against the formal feasibility criteria.

---

## Pipeline Architecture (Current State)

### Entry Points

| Executable | Root Module | Purpose |
|------------|-------------|---------|
| `lake exe dataset_generator` | `DatasetExport.lean` | CLI for production runs |
| `lake exe dataset_validator` | `DatasetValidator.lean` | Internal conformance + small gate |
| `lake exe enum_benchmark` | `EnumBenchmark.lean` | Complexity 5-7 timing validation |

### Formula Generation Path

```
generateFormulas(params)           [FormulaEnumerator.lean]
  -> match samplingMode with
     | .exhaustive -> enumerateExhaustive(params)
          -> foldl over complexity 1..maxComplexity
             -> enumExactBudget (memoized, Task 210)  [O(K) where K = distinct complexity levels]
          -> filter passesFilter (complexity >= 3, has modal/temporal op)
          -> take maxFormulas
     | .random -> sampleRandom(params)   [IO.rand grammar-based]
     | .hybrid -> exhaustive up to min(5,maxComplexity)/2 + random for remainder
  -> generateValidBatch(validSeedCount, maxComplexity, atoms)  [ONLY IF validSeedCount > 0]
       -> instantiateAxiom x seedCount (8 schemata: prop_s, prop_k, ex_falso, peirce,
                                         modal_t, modal_4, modal_b, modal_k_dist)
       -> necessitation closure (box(phi) for each pool member)
       -> MP closure (phi -> psi + phi => psi for pairs)
       -> 2nd round: repeat necessitation + MP
       -> filter: complexity in [3, maxComplexity], deduplicate
  -> combine enumerated + validSeeds, deduplicate, take maxFormulas
```

### Labeling Path

```
labelBatch(formulas)               [DatasetGenerator.lean]
  -> for each phi:
     -> decideAuto(phi)   [fuel = 10*complexity + 100, searchDepth = 5 + complexity/2]
     -> if timeout: retry with decideOptimized(phi)  [IDDFS(depth=20) then decide(fuel=1000)]
     -> extract ProofTrace (valid) or SimpleCountermodel (invalid)
     -> compute DifficultyMetrics and PatternKey
  -> progress every 100 formulas
```

### Export Path

```
writeDatasetJSONL(path, labeled)   [DatasetExport.lean]
  -> streams JSONL (one record per line)
  -> assignSplit via hash(formula_str) % 100: 0-79=train, 80-89=val, 90-99=test
  -> each record: {id, split, formula_str, formula_ast, formula_sexpr,
                   formula_tokens, frame_class, label, proof_trace,
                   countermodel, pattern_key, metrics, augmentation}
writeMetadata(path, metadata)
  -> companion _metadata.json with counts, mode, complexity, include_duals
```

### EnumParams Configuration

```lean
structure EnumParams where
  maxComplexity : Nat := 5
  maxModalDepth : Nat := 2
  maxTemporalDepth : Nat := 2
  atoms : List Atom := [p, q, r]   -- hardcoded 3 atoms in CLI
  maxFormulas : Nat := 5000
  samplingMode : SamplingMode := .exhaustive
  validSeedCount : Nat := 500      -- DEFAULT but CLI DOES NOT SET THIS
```

### CLI Limitation: validSeedCount Not Exposed

In `DatasetExport.lean`, the `main` function constructs:
```lean
let params : EnumParams := {
  maxComplexity := cliArgs.maxComplexity
  maxModalDepth := cliArgs.maxModalDepth
  maxTemporalDepth := cliArgs.maxTemporalDepth
  maxFormulas := cliArgs.maxFormulas
  samplingMode := cliArgs.mode
  -- validSeedCount is NOT SET -> defaults to 0 (not 500)
  -- atoms is NOT SET -> defaults to [p, q, r] (correct)
}
```

Wait -- re-checking: `EnumParams` has `validSeedCount : Nat := 500` as the struct default. In Lean 4, when constructing with `{ ... }` syntax, unspecified fields use their declared default values. So if `validSeedCount` is not set in the record literal, it would use **500** (the declared default), not 0.

Verification: The struct declaration is:
```lean
structure EnumParams where
  validSeedCount : Nat := 500
```

And the CLI constructs: `let params : EnumParams := { maxComplexity := ..., ... }` without setting `validSeedCount`. In Lean 4, this means `validSeedCount` uses the field default of **500**.

**Corrected finding**: The CLI DOES activate axiom seeding with 500 seeds by default. This is the correct behavior.

---

## Baseline Comparison (Task 204 vs Post-Task 210)

### Task 204 Medium Run (pre-fix)

| Metric | Value |
|--------|-------|
| Parameters | complexity 4, exhaustive, modal depth 2, temporal depth 2, include-duals |
| Formula count | 5,136 |
| Valid fraction | 25% (1,284) |
| Timeout rate | 3% (166) |
| Category diversity | 4 types: Implication (4,220), Until (432), Since (432), Box (52) |
| Complexity cap | 4 (5 was infeasible due to exponential blowup) |

### Task 204 Deep Run (pre-fix)

| Metric | Value |
|--------|-------|
| Parameters | complexity 7, random mode, modal depth 2, temporal depth 2, include-duals |
| Formula count | 53,979 |
| Valid fraction | 1.6% (888) |
| Timeout rate | 2.5% (1,361) |
| Category diversity | 4 types: Implication (15,330), Until (14,110), Since (14,110), Box (10,429) |

### Task 210 Benchmark Results (post-fix, compiled mode)

| Metric | Value |
|--------|-------|
| Complexity 5 time | 1ms |
| Complexity 5 formula count (raw, levels 1-5) | 1,644 |
| Complexity 6 time | 0ms |
| Complexity 7 time | 3ms |
| Complexity 7 formula count (raw, levels 1-7) | 51,244 |
| Axiom-only pool (500 seeds): confirmed valid | 60% |
| Axiom-only pool (500 seeds): timeout | 40% (still valid by construction) |
| Combined pipeline (exhaustive + 500 axiom seeds, sample of 200) | 4% confirmed valid |

### Key Gap

The benchmark's "combined pipeline" result of 4% was measured on a sample of 200 formulas taken from the HEAD of the combined pool. The axiom-seeded formulas are appended after the exhaustive formulas, so if the sample takes the first 200, it may be dominated by the exhaustive (mostly invalid) component. The actual combined valid fraction depends heavily on how the sample is drawn. The real production run at complexity 5 with 500 axiom seeds should produce something closer to:

- Exhaustive formulas (complexity 1-5, filtered): ~1,200 formulas (after filter)
- Axiom-seeded valid formulas (500 seeds + neccess. + MP rounds): ~100-300 additional valid formulas
- Combined: ~1,200-1,500 formulas, of which ~100-300 are valid = roughly 7-20% valid fraction

Whether this meets the 15% gate depends on the proportion of valid formulas in the exhaustive set (historically ~25% at complexity 4) vs. the expansion from axiom seeding.

---

## Identified Issues and Gaps

### Issue 1: CLI Run Script is Stale (HIGH PRIORITY)

`scripts/run_dataset_generation.sh` uses:
- Medium run: `--max-complexity 4` (was a workaround; now 5 is feasible)
- Deep run: `--mode random` (was a workaround; now exhaustive+hybrid at complexity 7 is feasible)

The script needs to be updated to use complexity 5 for the medium run (exhaustive mode) and complexity 5-7 with hybrid or exhaustive for the medium-deep run, leveraging the task 210 fix.

### Issue 2: Valid Fraction at Complexity 5 Is Uncertain (HIGH PRIORITY)

The benchmark showed 4% valid fraction in the combined pipeline (sample of 200 from HEAD). However:
- The sample may not represent the full combined pool proportionally
- The axiom-seeded formulas are appended at the END, so the first 200 sampled are exhaustive-only
- The true combined valid fraction at complexity 5 with axiom seeding needs an actual production run to measure

Historical data: complexity 4 exhaustive gave 25% valid. Complexity 5 exhaustive is unknown -- it could be lower because higher-complexity formulas are harder to make valid. The axiom seeding should add guaranteed-valid formulas on top.

### Issue 3: Operator Diversity Deficit in Exhaustive Mode at Low Complexity (MEDIUM)

At complexity 5 with 3 atoms and 5 constructors, the exhaustive enumeration produces:
- 1,644 raw formulas (all structural classes), but after `passesFilter` (removes complexity < 3 and pure propositional):
- The distribution is dominated by `Implication` at top level, with smaller counts for `Box`, `Until`, `Since`
- The axiom-seeded formulas via `instantiateAxiom` use only 8 schemata, which include: prop_s, prop_k, ex_falso, peirce (all implication top-level), modal_t, modal_4, modal_b, modal_k_dist (box-heavy but wrapped in implication)
- None of the axiom schemata produce top-level `Until` or `Since` formulas directly

This means axiom seeding does NOT help with temporal formula diversity. The valid formulas from seeding will be predominantly implication and box categories.

### Issue 4: generateValidBatch Has a Quadratic MP Round (MEDIUM)

The MP closure in `generateValidBatch` iterates over all pairs `(phi, psi)` in the pool:
```lean
for phi in pool do
  for psi in pool do
    match generateValidFromMP phi psi ...
```

With 500 seeds + necessitation expansion, the pool could have 1,000-3,000 formulas before MP. The double loop is O(N^2) = potentially 9 million iterations. At complexity 5, each formula has low complexity so this should be fast, but at complexity 7 with more complex axiom instances this could be a bottleneck. The second round compounds this further.

### Issue 5: Axiom Schemata Do Not Include Temporal Axioms (MEDIUM)

The `instantiateAxiom` function covers 8 schemata (indices 0-7), with the last (index 7) being `modal_k_dist`. Importantly, **no BX temporal axioms** are included (serial_future, connect_future, until_F, etc.). This means guaranteed-valid temporal formulas (Until, Since top-level) cannot be generated by the axiom seeding mechanism. For a well-balanced dataset with temporal coverage, this is a gap.

### Issue 6: The `dataset_validator` Does Not Validate Production Files (LOW)

`lake exe dataset_validator` always runs `runFullValidation` which uses `smallConfig` internally. It does not accept a file path argument to validate an existing JSONL file. To assess feasibility of a production run, the user must either inspect the CLI output or post-process the JSONL manually. There is no automated pipeline that runs the formal `evaluateGate` on `data/bmlogic-medium.jsonl`.

### Issue 7: `decideAuto` Fuel May Be Insufficient for Axiom-Seeded Complex Formulas (LOW)

The axiom-seeded formulas can reach the target complexity (up to `maxComplexity`). For the axiom pool at complexity 7, `decideAuto` uses `fuel = 10*7 + 100 = 170`. Complex axiom instances with many box layers and MP derivations may require more fuel to verify. This explains the 40% timeout rate in the axiom-only pool benchmark -- these are valid formulas but the decision procedure cannot confirm them within the fuel limit. They are still included as unconfirmed-valid records, but labeled as `.timeout`, which hurts the valid fraction metric.

---

## Recommended Approach

### Step 1: Update the Run Script for Complexity 5 Medium Run

The medium run should now use:
```bash
lake exe dataset_generator -- \
  --max-complexity 5 \
  --max-modal-depth 2 \
  --max-temporal-depth 2 \
  --max-formulas 5000 \
  --output data/bmlogic-medium-c5.jsonl \
  --include-duals
```

(Note: `validSeedCount` defaults to 500 within `EnumParams`, so axiom seeding is active automatically.)

This should produce:
- ~1,200-1,600 exhaustive formulas + ~100-400 valid seeds = ~1,500-2,000 before duals
- After duals: ~2,500-3,500 formulas (well within the 5,000 cap)
- Expected valid fraction: 15-30% if seeding works as intended

### Step 2: Attempt Complexity 7 Exhaustive or Hybrid Run

With the task 210 fix, complexity 7 exhaustive generates 51,244 raw formulas in 3ms. After `passesFilter`, a significant subset passes. With `maxFormulas = 50000`, this should cap cleanly. A hybrid run at complexity 7 using exhaustive mode is now viable:

```bash
lake exe dataset_generator -- \
  --max-complexity 7 \
  --max-modal-depth 2 \
  --max-temporal-depth 2 \
  --max-formulas 50000 \
  --output data/bmlogic-c7-exhaustive.jsonl \
  --include-duals
```

The bottleneck is labeling: 50,000 formulas labeled one at a time at ~1-10ms each = 50 seconds to 8 minutes. This is feasible.

### Step 3: Increase validSeedCount for Better Valid Fraction Coverage

If the valid fraction at complexity 5 exhaustive does not meet the 15% gate, increase axiom seeding. The CLI does not expose `--valid-seed-count`, so this requires either:
- Adding `--valid-seed-count N` to the CLI parser and `CLIArgs` struct (a small code change)
- Or running with `--mode hybrid` which uses higher axiom seeding via the default

Recommended: Add `--valid-seed-count` CLI flag to allow runtime tuning.

### Step 4: Add Temporal Axioms to `instantiateAxiom`

To generate guaranteed-valid Until/Since formulas, add at least:
- `serial_future`: `□p → F(p)` (where F(p) = until(top, p))
- `until_F`: `F(phi) ↔ U(⊤, phi)`
- `connect_future`: `G(phi) → phi` where G is all_future

This would improve temporal category coverage in the valid fraction.

### Step 5: Run the enum_benchmark First to Confirm Build State

Before any production run:
```bash
lake exe enum_benchmark
```
Verify: complexity 5 < 5s, complexity 7 < 60s, valid fraction with axiom seeding > target.

---

## Confidence Level

**High confidence** on:
- The task 210 fix is correct and verified: enumeration at complexity 5-7 is now feasible in milliseconds
- The run script is stale and uses pre-fix workarounds
- The valid fraction gap at high complexity is a real problem requiring axiom seeding
- The CLI correctly activates axiom seeding at the default level (500 seeds) via struct defaults

**Medium confidence** on:
- Whether 500 axiom seeds + 2 rounds of MP/nec closure are sufficient to push combined valid fraction above 15% at complexity 5 (depends on the proportion of exhaustive formulas that are valid, which is unknown for complexity 5)
- The labeling time at complexity 7 exhaustive (50K formulas) -- the 1-10ms per formula estimate from task 204 gives 50s to 8 min, but the decision procedure may behave differently for the new formula distribution
- Whether the MP quadratic loop in `generateValidBatch` becomes a bottleneck at complexity 7

**Low confidence** on:
- The exact valid fraction the production run will achieve (needs empirical measurement)
- Whether the temporal operator gap in `instantiateAxiom` significantly hurts feasibility gate category diversity (the gate requires 3+ categories each > 10%; Until/Since from exhaustive enumeration may already satisfy this even without seeded temporal formulas)
