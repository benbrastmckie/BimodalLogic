# Research Report: Scale Dataset Generation to Find Timeout Bottleneck

- **Task**: 264 - Scale dataset generation beyond c5 to identify timeout bottleneck
- **Started**: 2026-06-02
- **Session**: sess_1780421024_7aa538
- **Dependencies**: Task 263 (completed), Task 261 (completed)

---

## Executive Summary

Three datasets already exist: c5 (1,512 records, 2.6% timeout), c7 (49,904 records, 3.0% timeout), and a partial c9 (5,671 records, 11.4% timeout). However, the c7 and c9 datasets were generated with an older version of the decision procedure (all records show `decision_method: "unknown"` and trivially valid formulas like `p -> p` timeout), making their timeout rates unreliable. The clean c5 dataset from task 263 is the only trustworthy baseline.

Formula count grows approximately 7x per complexity level (1,512 at c5, ~50K at c7, ~360K at c8, ~2.6M at c9). The adaptive fuel strategy [500, 2000, 10000] is the timeout mechanism, not `soundFuel`. The 39 c5 timeouts fall into three structural patterns: double-box (7), Until-bot (16), and Since-bot (16). These patterns will scale combinatorially at higher complexity because every atom/subformula variant generates new timeout instances.

The recommended experimental approach is: (1) regenerate c6 and c7 with the current (post-task-261) decision procedure to get clean scaling data, (2) use stratified sampling for c8+ to cap runtime, (3) instrument per-formula timing and per-stage breakdown.

---

## 1. Formula Count Scaling

### 1.1 Observed Counts (from datasets)

| Level | Filtered Formulas | Cumulative | Growth Ratio |
|-------|-------------------|------------|--------------|
| c3    | 41                | 41         | --           |
| c4    | 144               | 185        | 3.5x         |
| c5    | 1,327             | 1,512      | 9.2x         |
| c6    | 5,918             | 7,430      | 4.5x         |
| c7    | 42,467            | 49,897     | 7.2x         |

### 1.2 Computed Exact Counts (3 atoms, modal depth 2, temporal depth 2)

Using the `enumExactHelper` combinatorial structure:

| Level | Exact at Level | Cumulative (filtered) | Growth |
|-------|----------------|----------------------|--------|
| c5    | ~1,440         | ~1,492               | --     |
| c6    | ~5,904         | ~7,396               | --     |
| c7    | ~43,696        | ~49,812              | 6.7x   |
| c8    | ~203,008       | ~252,820             | 5.1x   |
| c9    | ~1,355,136     | ~1,593,620           | 6.3x   |
| c10   | ~6,683,904     | ~8,277,524           | 5.2x   |
| c11   | ~42,678,912    | ~50,784,404          | 6.1x   |
| c12   | ~219,748,608   | ~270,533,012         | 5.3x   |

### 1.3 Implications

- **c8**: ~250K formulas -- feasible for exhaustive enumeration and labeling (~1-2 hours)
- **c9**: ~1.6M formulas -- feasible with stratified sampling, exhaustive may take 5-10 hours
- **c10+**: >8M formulas -- requires stratified sampling with aggressive quotas
- **Enumeration itself** is not the bottleneck (memoized, runs in seconds even at c9)
- **Labeling** (running the decision procedure) dominates wall-clock time

---

## 2. Current Fuel Strategy and Timeout Thresholds

### 2.1 Adaptive Fuel Tiers (`decideAutoAdaptive`)

```
Tier 1: fuel = 500,   label = "adaptive_500"
Tier 2: fuel = 2000,  label = "adaptive_2000"
Tier 3: fuel = 10000, label = "adaptive_10000"
Fallback: label = "adaptive_timeout"
```

This is independent of `soundFuel`. The decision pipeline within each tier:

1. `tryAxiomProof` -- direct axiom pattern matching (O(1) per axiom schema)
2. `buildCompositionalProof` -- recursive compositional builder, depth 10
3. `bounded_search_with_proof` -- IDDFS proof search, depth `5 + complexity/2`
4. `buildTableau` -- full tableau construction at the tier's fuel level

### 2.2 Sound Fuel Bound (Not Used by Adaptive Strategy)

`soundFuel(phi) = min(n * 2^n, 100000)` where n = |subformulaClosure(phi)|.

| Complexity | Typical |subformulaClosure| | soundFuel | Cap Hit? |
|------------|---------|-----|---------|
| 5          | 5       | 160             | No       |
| 7          | 7       | 896             | No       |
| 9          | 9       | 4,608           | No       |
| 11         | 11      | 22,528          | No       |
| 13+        | 13+     | 100,000         | Yes      |

### 2.3 Fuel Division in Splits

```lean
branchFuel = fuel / (max 1 branches.length)
```

Binary splits halve fuel at each level. For a formula requiring depth-d binary branching, effective fuel per leaf is `fuel / 2^d`. This means the 500-tier fails for any formula requiring >9 levels of binary branching, and the 10000-tier fails for >13 levels.

### 2.4 Effective Fuel by Tier

At c5, all 1,410 non-timeout formulas resolved at tier 1 (fuel=500). The 39 timeouts exhausted all three tiers. This suggests a bimodal distribution: formulas either resolve quickly (within ~500 fuel steps) or not at all within 10,000 steps.

---

## 3. Decision Procedure Architecture

### 3.1 Tableau Expansion (`expandBranchWithFuel`)

The core loop in `Saturation.lean`:

```
match fuel with
| 0 => none  -- Out of fuel
| fuel + 1 =>
    findClosure →  if closed: return closed branch
    registerEventualities → track Until/Since obligations
    fulfillEventualities → check if any are witnessed
    findBlockedTime → if blocked: return as saturated open
    expandOnceWithApplied → apply next rule
      .saturated → return open branch
      .extended → recurse with fuel-1
      .split → recurse on each sub-branch with fuel/numBranches
```

### 3.2 Performance-Relevant Hot Paths

1. **`findClosure`**: Scans branch for contradictions. O(n^2) in branch length.
2. **`findUnexpandedWithApplied`**: Scans branch for next unexpanded formula. O(n * r) where r is number of rules.
3. **`findBlockedTime`**: Checks all time indices for subset blocking. O(t * t * n) where t is number of time points and n is branch size.
4. **`registerEventualities` + `fulfillEventualities`**: O(n * e) where e is eventuality count.
5. **`expandOnce`/`expandOnceWithApplied`**: Applies one rule, creating new formulas. O(r * n).
6. **`isSubsetBlocked`**: Compares time types (deduplicated formula sets). O(m * m) where m is time type size.

### 3.3 Countermodel Extraction

For invalid formulas, `extractCountermodelData` in `DatasetGenerator.lean` runs `buildTableau` a second time (separate from the decision procedure call) to extract the enriched countermodel. This doubles the tableau cost for invalid formulas.

```lean
def extractCountermodelData (φ : Formula) :
    Option EnrichedCountermodel × Option SemanticCountermodelSummary :=
  let fuel := soundFuel φ
  match buildTableau φ fuel with ...
```

Note: this uses `soundFuel` (not the adaptive strategy), which can be up to 100,000. For complex formulas, this could be a significant cost even when the formula was decided at tier 1 (fuel=500).

---

## 4. Timeout Pattern Analysis

### 4.1 Clean C5 Timeout Patterns (39 formulas)

| Pattern | Count | Example | Structure |
|---------|-------|---------|-----------|
| Double-box | 7 | `(Box Box bot -> bot)`, `(Box Box p -> p)` | Nested modal operators |
| Until-bot | 16 | `(U(bot, p) -> q)` | Temporal with impossible event |
| Since-bot | 16 | `(S(bot, p) -> q)` | Temporal with impossible event |

All 39 are provably valid formulas. The decision procedure fails to find proofs within 10,000 fuel steps.

### 4.2 Why These Patterns Timeout

**Double-box (`Box Box X -> Y`)**: The negation `F(Box Box X) AND T(NOT Y)` forces the tableau to explore modal accessibility. In S5, `Box Box X` reduces to `Box X`, but the tableau may not efficiently recognize this without a dedicated rule for S5 transitivity closure.

**Until-bot / Since-bot (`U(bot, X) -> Y`)**: `U(bot, X)` means "bot holds until X happens", which is impossible since bot is always false. The formula is vacuously valid. However, the tableau's positive Until rule creates a branching structure:
- Branch 1: Event witnessed (bot at fresh time) -- immediately closes (bot is false)
- Branch 2: Guard continues (re-introduces `T(U(bot, X))` at fresh time) -- creates new time point

This generates an infinite chain of time points. The eventuality-aware blocking should detect this, but either:
- The eventuality for bot is never "fulfilled" (correctly), causing blocking to not fire
- The fuel runs out before blocking recognizes the loop

### 4.3 Scaling of Timeout Patterns

At complexity c, the number of timeout-pattern formulas grows as:
- **Double-box**: 4 (with bot) + 3 (per atom) = 7 at c5. At c(n+2), each box-wrapped subexpression of complexity n generates a double-box pattern. Rough scaling: O(formulas_at(n-2)).
- **Until/Since-bot**: 4*4 = 16 each (4 second args * 4 consequents) at c5. At higher complexity, the second argument and consequent can be any subformula, so scaling is O(formulas_at(n-3)^2).

Expected timeout counts at higher complexity (rough estimates):

| Level | Double-box | Until-bot | Since-bot | Total Timeouts | Total Formulas | Rate |
|-------|-----------|-----------|-----------|----------------|----------------|------|
| c5    | 7         | 16        | 16        | 39             | 1,512          | 2.6% |
| c6    | ~20       | ~60       | ~60       | ~140           | ~7,400         | ~1.9% |
| c7    | ~100      | ~300      | ~300      | ~700           | ~50,000        | ~1.4% |
| c8    | ~500      | ~2,000    | ~2,000    | ~4,500         | ~250,000       | ~1.8% |

The timeout rate may actually decrease if the number of "normal" formulas grows faster than the timeout patterns. But new timeout patterns may emerge at higher complexity (e.g., triple-box, nested Until/Since, mixed patterns).

---

## 5. Available Timing and Metrics Infrastructure

### 5.1 Per-Formula Timing

`labelFormula` in `DatasetGenerator.lean` captures wall-clock timing:
```lean
let startTime <- IO.monoMsNow
let (result, fuelTier) := decideAutoAdaptive phi fc
let endTime <- IO.monoMsNow
let elapsed := endTime - startTime
```

This is stored as `decisionTimeMs` in the `DifficultyMetrics` structure and exported to JSONL.

### 5.2 Available Metrics Per Record

- `decisionTimeMs`: Wall-clock decision time (milliseconds)
- `decision_method`: Which fuel tier resolved (`adaptive_500`, `adaptive_2000`, `adaptive_10000`, `adaptive_timeout`, `fast_path_axiom`)
- `proof_reconstruction_method`: For valid formulas (`axiom_match`, `derived_match`, `compositional`, `proof_search`)
- `complexity`, `modalDepth`, `temporalDepth`: Formula structural metrics
- `interestingness_score`, `interestingness_tier`: Computed interestingness

### 5.3 Missing Instrumentation

There is **no stage-level timing breakdown**. We cannot currently distinguish:
- Time in fast-path axiom matching
- Time in compositional proof building
- Time in proof search (IDDFS)
- Time in tableau construction
- Time in countermodel extraction (second `buildTableau` call)

This is a gap for bottleneck identification. Adding per-stage timing would require modifying `decideAutoAdaptive` to return timing metadata, or adding instrumenting wrappers.

### 5.4 Slow-Formula Warning

Formulas taking >1000ms trigger a stderr warning:
```lean
if labeled.metrics.decisionTimeMs > 1000 then
  IO.eprintln s!"[warn] Slow formula (#{count + 1}): ..."
```

### 5.5 Progress Reporting

The generator reports progress every 1000 formulas with:
- Cumulative count and percentage
- Valid percentage and timeout percentage
- Throughput (formulas/sec)
- ETA estimate

---

## 6. Existing Datasets Beyond C5

### 6.1 C7 Dataset (`data/bmlogic-c7.jsonl`)

- **Records**: 49,904
- **Generated**: 2026-05-29 (before task 261 fixes)
- **Status**: UNRELIABLE -- all records have `decision_method: "unknown"`, and trivially valid formulas (`p -> p`, `Box(bot -> bot)`) timeout
- **Timeout rate**: 3.0% (1,500/49,904) -- but many are false timeouts from the old procedure

### 6.2 C9 Dataset (`data/bmlogic-c9.jsonl`)

- **Records**: 5,671 (incomplete -- only goes to c6)
- **Status**: UNRELIABLE -- same `decision_method: "unknown"` issue
- **Timeout rate**: 11.4% (649/5,671) -- but includes false timeouts
- **Only reaches c6**: Despite being labeled "c9", the data stops at complexity 6

### 6.3 Conclusion

Both the c7 and c9 datasets must be regenerated with the current (post-task-261) decision procedure before any scaling analysis can be performed. The c5 dataset from task 263 is the only clean baseline.

---

## 7. Experimental Approach

### 7.1 Phase 1: Clean C6 and C7 Regeneration

Generate c6 and c7 datasets with the current decision procedure:

```bash
# C6: ~7,400 formulas, estimated 5-10 minutes
lake exe dataset_generator -- \
  --max-complexity 6 \
  --output data/bmlogic-c6-clean.jsonl

# C7: ~50,000 formulas, estimated 30-60 minutes
lake exe dataset_generator -- \
  --max-complexity 7 \
  --output data/bmlogic-c7-clean.jsonl
```

This gives clean timeout rate, timing, and method distribution data at c6 and c7.

### 7.2 Phase 2: C8 with Stratified Sampling

C8 has ~250K formulas. Exhaustive enumeration is feasible but labeling may take 2-4 hours. Use stratified sampling to cap:

```bash
# C8 stratified: cap each level at 50K formulas
lake exe dataset_generator -- \
  --max-complexity 8 \
  --mode stratified \
  --stratified-quotas "3:0,4:0,5:0,6:0,7:0,8:50000" \
  --output data/bmlogic-c8-stratified.jsonl
```

### 7.3 Phase 3: C9+ Targeted Sampling

At c9+ (>1.6M formulas), exhaustive enumeration is impractical. Use targeted sampling of specific formula patterns, especially known timeout patterns:

```bash
# C9 stratified: cap at 100K total
lake exe dataset_generator -- \
  --max-complexity 9 \
  --mode stratified \
  --stratified-quotas "3:0,4:0,5:0,6:0,7:0,8:10000,9:50000" \
  --max-formulas 100000 \
  --output data/bmlogic-c9-sample.jsonl
```

### 7.4 Phase 4: Instrumentation Enhancement

Add per-stage timing to `decideAutoAdaptive` to identify which stage is the bottleneck:
- Modify to return a timing breakdown alongside the result
- Track: axiom_match_time, compositional_time, search_time, tableau_time
- For invalid formulas: track countermodel_extraction_time separately

### 7.5 Analysis Metrics at Each Level

For each complexity level, collect:
1. **Timeout rate**: timeouts / total
2. **Mean decision time**: average `decisionTimeMs`
3. **Median decision time**: p50
4. **P95 decision time**: 95th percentile
5. **Max decision time**: worst case
6. **Timeout pattern distribution**: classify timeout formulas by pattern
7. **Decision method distribution**: how many resolve at each fuel tier
8. **Memory usage**: peak RSS during generation (via `/usr/bin/time -v` or similar)

---

## 8. Risk Assessment

### 8.1 Known Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| C8 exhaustive takes too long | Medium | Use stratified sampling with quotas |
| New timeout patterns emerge at c7+ | High | Classify all timeouts by structural pattern |
| Countermodel extraction doubles cost for invalid formulas | Medium | Profile separately; consider lazy extraction |
| Memory exhaustion at c9+ | Medium | Monitor RSS; use `--max-formulas` cap |
| Enumeration itself blows up at c10+ | Low | Memoization handles this efficiently |
| Build time for the executable | Low | Only needs one `lake build`; incremental thereafter |

### 8.2 Where the Bottleneck Will Be

Based on analysis:

1. **NOT in enumeration**: Memoized formula generation is fast (seconds even at c9)
2. **NOT in soundFuel calculation**: Quick arithmetic
3. **LIKELY in tableau expansion**: The O(fuel * branch_size) cost per formula, multiplied by millions of formulas
4. **LIKELY in countermodel extraction**: The second `buildTableau` call using `soundFuel` (up to 100K) for each invalid formula
5. **DEFINITELY in timeout formulas**: At c5, timeouts have 0ms `decisionTimeMs` because all 3 fuel tiers are exhausted quickly. But at c9+, each timeout formula consumes 3 full tier runs (500 + 2000 + 10000 = 12,500 fuel steps total)

### 8.3 Predicted Scaling Curve

Based on c5 data and structural analysis:

```
Complexity | Timeout Rate | Generation Time | Formula Count
c5         | 2.6%         | ~30s            | 1,512
c6         | 2-4%         | ~5min           | ~7,400
c7         | 3-5%         | ~30-60min       | ~50,000
c8         | 4-8%         | ~2-4hr          | ~250,000
c9         | 5-15%        | ~10-24hr (strat)| ~100K (sampled)
c10+       | 10-30%       | impractical     | ~8M+
```

The timeout rate is expected to increase modestly up to c8-c9 before accelerating. The dominant factor will be new timeout patterns emerging (not just the existing double-box and Until/Since-bot patterns).

---

## 9. Code Architecture Summary

### 9.1 Key Files

| File | Role |
|------|------|
| `Theories/Bimodal/Automation/DatasetExport.lean` | CLI entry point, JSONL streaming, per-record flush |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | `labelFormula`, `decideAutoAdaptive` orchestration |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Memoized formula enumeration |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | `decideAutoAdaptive`, `decide` |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | `buildTableau`, `expandBranchWithFuel`, blocking |
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | `EventualityTracker`, `findBlockedTime`, subset blocking |
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | `expandOnce`, `expandOnceWithApplied`, applied set |
| `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` | Countermodel building |
| `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` | Proof term extraction from closed tableaux |

### 9.2 Generation Pipeline Flow

```
CLI args -> parseCLIArgs
  -> EnumParams
  -> generateFormulas (enumeration with progress)
  -> for each formula:
      labelFormula(phi, fc)
        -> decideAutoAdaptive(phi, fc)
            -> decide(phi, depth, fuel=500, fc) -> if timeout:
            -> decide(phi, depth, fuel=2000, fc) -> if timeout:
            -> decide(phi, depth, fuel=10000, fc) -> if timeout:
            -> return (.timeout, "adaptive_timeout")
        -> computeMetrics(phi, elapsed)
        -> extractCountermodelData(phi)  [if invalid, uses soundFuel up to 100K]
        -> computeInterestingness(phi, ...)
      -> writeRecordJSONL(handle, record)
      -> handle.flush
  -> writeMetadata
```

---

## 10. Recommendations

### 10.1 Immediate Actions (Phase 1 of implementation)

1. **Regenerate c6 and c7 clean datasets** using the current (post-task-261) decision procedure
2. **Record timing data carefully** -- the c5 data shows `decisionTimeMs = 0` for all formulas, which means sub-millisecond precision is lost. Consider adding microsecond timing.

### 10.2 Decision Procedure Improvements (Phase 2)

1. **Fix double-box timeouts**: Add a pre-processing step that simplifies `Box Box X` to `Box X` in S5 (since S5 has Box = Box Box). This is a structural simplification, not a new rule.
2. **Fix Until/Since-bot timeouts**: Add a fast-path that recognizes `U(bot, X)` as vacuously false (and thus any implication from it is valid). Similarly for `S(bot, X)`.
3. **Optimize countermodel extraction**: The second `buildTableau` call with `soundFuel` up to 100K is wasteful. Cache the tableau from the first call, or use the tier fuel level.

### 10.3 Instrumentation (Phase 3)

1. **Add per-stage timing** to `decideAutoAdaptive`
2. **Add microsecond resolution** for fast formulas (use `IO.monoNsNow` if available, or compute elapsed in microseconds)
3. **Track peak fuel consumption** per formula (how much of the fuel budget was actually used)
4. **Track branch count and time point count** at decision completion

### 10.4 Sampling Strategy for C8+ (Phase 4)

1. Use `--mode stratified --stratified-quotas` to cap per-level formula counts
2. Focus sampling on known-timeout patterns for targeted analysis
3. Consider adding a `--timeout-only` mode that filters for likely-timeout formulas
