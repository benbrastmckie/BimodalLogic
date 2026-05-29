# Teammate C Findings: Production-Scale Dataset Generation — Gaps, Risks, Blind Spots

**Task**: 213 — Production-scale dataset generation validation
**Teammate**: C (Critic)
**Session**: sess_1780088631_bfd193
**Date**: 2026-05-29
**Artifact**: 01

---

## Key Findings (Critical Gaps)

### 1. The 15% Valid Fraction Gate Was NOT Met — and This Was Buried

The plan's own testing section records this:

```
Valid fraction with axiom seeding exceeds 15% at complexity 5-7
  result: 60% for axiom-only pool, 4% for combined pool with current seed ratio;
  adjustable via validSeedCount parameter
```

The combined pipeline produced **4% valid formulas**, not 15%. The gate checkbox in the plan is unchecked. The summary report inflates this by reporting the axiom-only pool (60%) as the headline — but that pool was tested with only 100 samples and the `decideAuto` call returned 40% **timeout**, meaning the 60% figure reflects only the non-timed-out subset. True valid rate in the axiom pool is somewhere between 36% and 60%, and that pool is not representative of production output because it is a separate pure-axiom pool, not the mixed pipeline.

**Severity**: High. If the task is considered complete at 4%, all downstream tasks relying on a >15% valid fraction will silently receive bad training data.

### 2. Labeling Time for the Full 51,244-Formula Corpus Was Never Measured

Task 210 benchmarked enumeration time:
- Complexity 5 enumeration: 1 ms
- Complexity 7 enumeration: 3 ms

But the benchmark (`EnumBenchmark.lean`) labeled only **100 axiom-seeded formulas** (Test 1) and **200 mixed-pool formulas** (Test 2). It did **not** label the full 51,244-formula complexity-7 corpus.

From `DecisionProcedure.lean`, `decideAuto` uses `recommendedFuel φ = 10 * φ.complexity + 100`. At complexity 7, that is fuel=170. The tableau builder uses this as a step counter. The decision procedure for a single formula can hit both `bounded_search_with_proof` and a full `buildTableau` call before returning `.timeout`. If each formula costs even 10 ms on average, 51,244 formulas = **512 seconds** (8.5 minutes) of labeling time. At 100 ms each, that is **85 minutes**.

No timing data exists for the labeling step at production scale. This is the critical bottleneck that Task 210 entirely deferred.

### 3. The Benchmark Labeled Only 200 Formulas — From the Front of the List

The `benchmarkValidFraction` function in `EnumBenchmark.lean` (lines 77-79) takes formulas via `formulas.take 200`. The `generateFormulas` function places the exhaustive enumeration before the axiom seeds in the combined list (line 950 in `FormulaEnumerator.lean`):

```lean
let combined := (enumerated ++ validSeeds).eraseDups
return combined.take params.maxFormulas
```

The benchmark comment says "take from middle to mix exhaustive + seeds" — but it actually takes from the front, which is almost entirely the exhaustively-enumerated formulas (1,644 at complexity 5, then seeds appended). The axiom-seeded valid formulas are mostly at the end. The benchmark's 200-sample test is therefore dominated by exhaustively-enumerated formulas, which have a ~1.6% valid rate, not the seeded formulas that should boost it to 15%.

**This means the 4% combined-pool result may even be optimistic**: if the test had sampled uniformly from the 51K pool, the valid rate could be lower because the seed ratio (500 seeds / 51,244 formulas = ~1%) is insufficient to move the aggregate rate from 1.6% to 4%, much less to 15%.

### 4. `validSeedCount` Is Set in `EnumParams`, But the Production Executable Does Not Use It

`DatasetExport.lean` (the actual `lake exe dataset_generator` entry point) constructs `EnumParams` at line 461-467 without setting `validSeedCount`:

```lean
let params : EnumParams := {
  maxComplexity := cliArgs.maxComplexity
  maxModalDepth := cliArgs.maxModalDepth
  maxTemporalDepth := cliArgs.maxTemporalDepth
  maxFormulas := cliArgs.maxFormulas
  samplingMode := cliArgs.mode
}
```

Since `validSeedCount` defaults to 500 in `EnumParams`, `generateFormulas` will use 500 seeds. But there is no CLI argument `--valid-seed-count` to tune this. A user running `lake exe dataset_generator -- --max-complexity 7` at production scale gets 500 axiom seeds mixed into ~51,244 exhaustive formulas. That is a 0.97% seed ratio, not the ~15% the gate requires.

Additionally, `CLIArgs` has no `validSeedCount` field, and `parseCLIArgs` has no case for it. The parameter is architecturally present but operationally inaccessible from the CLI.

### 5. `decideAuto` Has No Absolute Wall-Clock Timeout

`labelFormula` calls `decideAuto φ`, which on timeout retries with `decideOptimized`. There is no wall-clock cap. The fuel parameter (`10 * complexity + 100`) bounds tableau expansion steps, not time. If the tableau engine is in a slow branch for a complex formula, there is no guarantee that "fuel exhausted" occurs in any bounded wall-clock time. Some formulas may spin for seconds or minutes.

`recommendedFuel` at complexity 7 = 170. If each tableau step is O(n) where n is the formula size, a timeout formula at complexity 7 could do 170 * 7 = ~1,190 formula-level operations before declaring timeout. The actual wall-clock cost depends on the tableau implementation, which was not profiled.

### 6. Memory Accumulation: 51K `LabeledFormula` Objects All In-Memory at Once

`labelBatch` (DatasetGenerator.lean line 324-334) accumulates all labeled formulas into a Lean `List LabeledFormula` before returning. Each `LabeledFormula` contains:
- The formula itself (up to 7 connectives deep)
- A `ProofTrace` (axioms_used and rules_applied as String lists)
- A `SimpleCountermodel` (true/false atom lists, formula copy)
- A `DifficultyMetrics` struct
- A `PatternKey` struct

For 51,244 formulas, this list is held entirely in memory while `writeDatasetJSONL` streams it out. On a GC-based Lean runtime, this creates significant memory pressure. No peak memory estimate was provided in Task 210.

### 7. The `eraseDups` Call in `generateFormulas` Uses O(n^2) List Equality

`FormulaEnumerator.lean` line 951: `(enumerated ++ validSeeds).eraseDups`. For 51,244 + 500 formulas, `eraseDups` on a `List Formula` requires O(n^2) formula equality checks (standard `List.eraseDups` implementation). Each formula equality check is O(formula size). At 51,744 formulas of average size 4, this is ~2.7 billion operations — potentially minutes of CPU time purely for deduplication.

The claim that "exact-complexity levels are disjoint by construction" applies only to the `enumerated` portion. The `validSeeds` are generated via IO-based random axiom instantiation, which can produce formulas already present in `enumerated`. The deduplication is therefore still necessary and still O(n^2).

### 8. The Benchmark Only Ran at Complexity 5, Not 7

The actual `benchmarkValidFraction` in `EnumBenchmark.lean` (line 103) calls:

```lean
benchmarkValidFraction atoms 5
```

The benchmark title says "complexity 5-7 feasibility gates" and tests enumeration timing at 5, 6, and 7, but the valid fraction test only runs at complexity 5. The valid fraction gate at complexity 7 — the hardest case, where the 1.6% baseline was observed — was never measured in the benchmark.

---

## Assumptions Not Yet Validated

1. **"60% axiom-seeded formulas are valid"**: This was measured on a sample of 100 with 40% timeout. The claim is that axiom-seeded formulas are "valid by construction." But `decideAuto` returning `.timeout` does not mean the formula is valid — the decision procedure may have insufficient fuel for some axiom instances (e.g., `modal_k_dist` with complex sub-formulas). The 40% timeout rate is a data quality problem: these formulas enter the dataset with label `.timeout`, not `.valid`.

2. **"Deduplication within exact-complexity levels is unnecessary"**: This is true for the enumerator alone, but `generateFormulas` mixes `enumerated` with `validSeeds` from random IO, so the combined list still needs deduplication. The deduplication cost at 51K+ scale was not measured.

3. **"The 15% gate is the right target"**: The gate value (15%) appears in the research report and benchmark but no justification is given for why 15% valid fraction (vs. 10% or 20%) is appropriate for the downstream ML training objective. It may be arbitrary.

4. **"Axiom-instantiated formulas are useful training data"**: All 8 axiom schemata used (`prop_s`, `prop_k`, `ex_falso`, `peirce`, `modal_t`, `modal_4`, `modal_b`, `modal_k_dist`) are simple. The sub-formulas are generated by `randomSubFormula` which picks uniformly among `atom`, `imp`, and `box` (no temporal operators). This means valid seeds have zero temporal operator content at the top level. It is unclear whether training on such formulas helps a model learn to prove temporal axioms.

5. **"The decision procedure produces correct labels"**: `decideAuto` at complexity 7 with fuel=170 may incorrectly return `.timeout` for formulas that are valid but require deep tableau expansion. These formulas will be incorrectly excluded from the valid training set. The false-timeout rate was never estimated.

6. **"The formula count 1,644 at complexity 5 vs the predicted 1,440 is not a problem"**: The research predicted exactly 1,440 distinct formulas at complexity 5. The implementation produced 1,644 (levels 1-5 combined). The discrepancy (204 formulas, ~14%) is not explained. It could indicate:
   - The research counted "exact complexity 5 only" while the code produces levels 1 through 5
   - There are actual formula count differences from the research model
   - Some formulas pass `passesFilter` that were excluded from the research estimate

---

## Production-Scale Risk Assessment

| Risk | Likelihood | Impact | Status |
|------|------------|--------|--------|
| Full labeling run times out after hours | High | Critical | Unvalidated |
| Valid fraction remains at 4% despite axiom seeding | High | Critical | Confirmed at small scale |
| OOM crash during 51K `LabeledFormula` list accumulation | Medium | Critical | Not estimated |
| `eraseDups` on 51K formulas takes minutes | Medium | High | Not measured |
| `validSeedCount` CLI parameter missing, cannot tune from command line | High | High | Confirmed bug |
| 40% of axiom seeds land in dataset as `.timeout` label (label noise) | High | Medium | Confirmed in benchmark |
| Decision procedure timeouts produce incorrect labels | Medium | Medium | Not estimated |
| Axiom seeds lack temporal operators (training signal gap) | High | Medium | Code confirmed |

---

## What the Benchmark Didn't Test

1. **Full pipeline at complexity 7**: Enumeration was timed, but enumerate + label + export at the full 51,244-formula scale was never run.

2. **Valid fraction at complexity 7**: The valid fraction gate ran only at complexity 5. Complexity 7 (the target production scale) was skipped.

3. **Labeling throughput**: No per-formula labeling time was reported. The benchmark reports "generation time" (enumeration only) and labels small subsets.

4. **Memory usage**: Peak heap memory during a full complexity-7 pipeline run was never measured.

5. **Export file size**: The JSONL output schema includes formula AST, formula string, countermodel, proof trace, difficulty metrics, and pattern features per record. Estimated JSON overhead per formula is 300-800 bytes. At 51,244 formulas, the JSONL file would be 15-40 MB — not problematic, but not verified.

6. **The `decideOptimized` retry path**: `labelFormula` retries with `decideOptimized` on timeout. This retry path uses IDDFS with depth 20 before calling `decide` again. The benchmark never triggered this path (only 100 axiom-seeded formulas were labeled), so the retry latency is unknown.

7. **Determinism of the random IO paths**: `generateValidBatch` uses `IO.rand` (true random, not seeded). Two runs with the same EnumParams will produce different axiom seeds. This means the dataset is not reproducible without a fixed seed, contradicting the "deterministic sampling" property of the LCG-based path.

8. **Integration between `DatasetExport.lean` (CLI) and `generateFormulas`**: The CLI executable uses `generateFormulas` internally, but the benchmark used `labelBatch` and `generateValidBatch` separately. The end-to-end CLI path (parse args → generateFormulas → labelBatch → writeDatasetJSONL → writeMetadata) has never been exercised as a whole.

---

## Questions That Should Be Asked

1. **Why did the summary mark task 210 as complete when the 15% valid fraction gate was not met?** The plan has an unchecked checkbox for this gate. The summary says "Implemented" but notes the gate failure. Was a conscious decision made to ship at 4%?

2. **What is the expected wall-clock time for `lake exe dataset_generator -- --max-complexity 7`?** This is the production command. Nobody knows the answer.

3. **Is the 15% valid fraction gate an ML requirement or an arbitrary threshold?** If it is an ML requirement, the current pipeline fails it. If it is a rough heuristic, at what rate does training quality degrade?

4. **Can `validSeedCount` be exposed via CLI?** The field exists in `EnumParams` but `CLIArgs` and `parseCLIArgs` in `DatasetExport.lean` do not expose it. This makes the main tuning knob inaccessible to users running production jobs.

5. **What happens to formulas labeled `.timeout` in the training set?** The `DatasetExport.lean` pipeline exports all labels including `.timeout`. A downstream ML system needs to know how to handle this third class.

6. **Are the axiom schemata in `instantiateAxiom` the right ones for TM logic training?** The 8 schemata are classical and S5-modal. None are temporal. A model trained only on these axiom instances may not generalize to temporal reasoning.

7. **Does `randomSubFormula` need to generate temporal operators?** Currently it generates only `atom`, `imp`, and `box`. Adding `untl`/`snce` to the sub-formula generator would produce temporally richer valid seeds.

8. **Has anyone run `lake exe dataset_validator` to completion?** The validator's `runFeasibilityGate` labels the full `smallConfig` formula set (depth 2, size 8, 3 atoms). If the 15% gate fails even at small config, the production run will certainly fail.

9. **What is the 1,644 vs 1,440 formula count discrepancy?** Was 1,440 an estimate for complexity-5-only (not levels 1-5 cumulative), or is there a bug in the formula count?

10. **Does `enrichWithDuals` interact correctly with axiom seeds?** `enrichWithDuals` is applied in `DatasetExport.lean` but not in the benchmark. Temporal duality preserves validity — but axiom seeds generated by `randomSubFormula` contain no temporal operators, so their duals are identical (no 2x boost). The dual path provides zero benefit for the valid seeds.

---

## Confidence Level

**Overall confidence in this gap analysis**: High

The critical findings (1, 3, 4, 8) are directly verifiable from the source code. The valid fraction failure (Finding 1) is documented in the plan itself. The `validSeedCount` CLI gap (Finding 4) is confirmed by reading `DatasetExport.lean`. The benchmark scope limitation (Finding 8) is confirmed by reading `EnumBenchmark.lean` line 103.

Findings 2, 5, 6, 7 (timing, memory, deduplication cost) are estimated from code structure and have medium-high confidence based on standard computational complexity analysis.

The training utility concerns (assumptions 4, 6) are domain-level judgments and have medium confidence.

---

## Summary Assessment

Task 210 fixed the enumeration blowup, which was the stated goal. However, the task declared completion while:
- The 15% valid fraction gate was unchecked (result: 4%)
- Labeling throughput at production scale was never measured
- The CLI executable lacks the tuning parameter needed to meet the valid fraction gate
- The benchmark tested labeling at 200 formulas, not 51,244

Task 213 validation should not simply accept Task 210's outputs and benchmark the same small samples. The validation must run the full pipeline end-to-end — `lake exe dataset_generator -- --max-complexity 7 --output /tmp/bmlogic-c7.jsonl` — and measure wall-clock time, valid fraction, and output file integrity. Until that run completes successfully with valid fraction >= 15%, production-scale dataset generation is not validated.
