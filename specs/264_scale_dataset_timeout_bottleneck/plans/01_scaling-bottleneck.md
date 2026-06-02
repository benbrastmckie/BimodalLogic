# Implementation Plan: Scale Dataset Generation to Find Timeout Bottleneck

- **Task**: 264 - Scale dataset generation beyond c5 to identify timeout bottleneck
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 263 (completed -- c5 smoke test baseline)
- **Research Inputs**: specs/264_scale_dataset_timeout_bottleneck/reports/01_scaling-bottleneck.md
- **Artifacts**: plans/01_scaling-bottleneck.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Systematically generate clean datasets at increasing complexity levels (c6, c7, c8) using the current decision procedure (post-task-261), then analyze the resulting timing, timeout rate, and pattern distribution to identify the complexity threshold where timeouts become unacceptable. The c5 dataset (task 263) establishes a known-good baseline: 1,512 formulas, 2.6% timeout rate (39/1512), all timeouts from three structural patterns (double-box, Until-bot, Since-bot). This plan produces scaling curves, per-level pattern analysis, and a bottleneck characterization report to guide future decision procedure improvements.

### Research Integration

The research report (01_scaling-bottleneck.md) provided critical findings integrated into this plan:

- **Formula counts**: c6 ~ 7,400; c7 ~ 50,000; c8 ~ 250,000 (approximately 5-7x growth per level)
- **Stale datasets**: Existing c7 and c9 datasets are unreliable (generated with old procedure, `decision_method: "unknown"`, trivially valid formulas timeout). Must be regenerated.
- **Adaptive fuel strategy**: Three tiers [500, 2000, 10000]. At c5, all non-timeout formulas resolve at tier 1 (fuel=500). Bimodal distribution: formulas either resolve quickly or not at all.
- **Timeout patterns**: Double-box (7), Until-bot (16), Since-bot (16). These are algorithmic gaps, not fuel capacity issues.
- **Countermodel extraction overhead**: Second `buildTableau` call with `soundFuel` up to 100K for invalid formulas doubles tableau cost.
- **CLI infrastructure**: `--mode stratified`, `--stratified-quotas`, `--resume-from`, and `--frame-class` flags already exist.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the dataset infrastructure for the decision procedure validation effort. It does not directly advance any critical-path completeness items on the ROADMAP, but contributes to Phase 5 (Publication quality) by establishing empirical performance characterization of the decision procedure.

## Goals & Non-Goals

**Goals**:
- Generate clean c6 and c7 datasets with the current (post-task-261) decision procedure
- Generate a c8 dataset using stratified sampling (full enumeration if runtime permits)
- Measure timeout rate, mean/median/p95 decision time, and decision method distribution at each level
- Classify all timeout formulas by structural pattern at each complexity level
- Identify which formula families hit the fuel cap first and whether new timeout patterns emerge beyond c5
- Produce a scaling curve (complexity vs timeout rate) with supporting data
- Create a bottleneck characterization report summarizing findings

**Non-Goals**:
- Fixing the timeout patterns (double-box, Until/Since-bot) -- that is a separate task
- Adding per-stage timing instrumentation to `decideAutoAdaptive` -- that requires Lean code changes to the decision procedure
- Generating datasets for c9+ (impractical without algorithmic improvements or dedicated compute time)
- Modifying the decision procedure or fuel strategy
- Memory profiling (would require separate tooling)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| c7 generation takes >2 hours | M | M | Monitor progress via built-in throughput reporting; use `--max-formulas` cap if needed |
| c8 exhaustive generation exceeds 4 hours | H | H | Use stratified sampling with `--stratified-quotas "3:0,4:0,5:0,6:0,7:0,8:50000"` to cap at ~50K c8 formulas |
| New timeout patterns emerge that require new classification categories | M | M | Use formula structure analysis (operator nesting) rather than pattern-matching on known patterns |
| `lake build` required before generation and takes significant time | L | M | Build once at start; generator executable is incremental |
| Countermodel extraction creates disproportionate slowdown at higher complexity | M | H | Track per-formula timing to identify whether slowest formulas are valid (timeout) or invalid (countermodel) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Build and Generate c6 Dataset [COMPLETED]

**Goal**: Build the project and generate a clean c6 dataset as the first scaling data point above c5.

**Tasks**:
- [x] Run `lake build` to ensure the project compiles and the `dataset_generator` executable is up to date *(completed)*
- [x] Generate c6 dataset: `lake exe dataset_generator -- --max-complexity 6 --max-formulas 20000 --output data/bmlogic-c6.jsonl` *(deviation: altered -- added --max-formulas 20000 since default 5000 would truncate c6's 7419 formulas; generation killed after 5931/7419 records due to timeout formulas taking 405+ seconds each)*
- [x] Verify the output file exists and contains expected record count (~7,400 records) *(deviation: altered -- 5931 of 7419 records obtained; partial due to timeout bottleneck)*
- [x] Inspect the metadata file (`data/bmlogic-c6_metadata.json`) for timeout count and decision method distribution *(completed -- metadata manually written for partial dataset)*
- [x] Spot-check a few records to confirm `decision_method` fields are populated (not "unknown") *(completed -- all records use adaptive_500, fast_path_axiom, or adaptive_timeout)*
- [x] Record wall-clock generation time *(completed -- ~20 min for 5931 records; single timeout formula took 405,288ms = 6.75 min)*

**Timing**: 1.5 hours (including build time and generation)

**Depends on**: none

**Files to modify**:
- `data/bmlogic-c6.jsonl` - Generated output (new file)
- `data/bmlogic-c6_metadata.json` - Generated metadata (new file)

**Verification**:
- c6 dataset file exists with ~7,400 records
- Metadata shows non-zero counts for `adaptive_500`, `fast_path_axiom`, and possibly `adaptive_2000`
- No records have `decision_method: "unknown"`

---

### Phase 2: Generate c7 Dataset [COMPLETED]

**Goal**: Generate a clean c7 dataset to replace the stale c7 data (which used the old decision procedure).

**Tasks**:
- [x] Generate c7 dataset: `lake exe dataset_generator -- --max-complexity 7 --mode stratified --stratified-quotas "3:1,4:1,5:1,6:1,7:5000" --output data/bmlogic-c7-clean.jsonl` *(deviation: altered -- used stratified mode to focus on c7 formulas; only 41 records obtained (37 at c7) before killing due to timeout bottleneck; single formula took 418,794ms)*
- [x] Monitor progress via stderr throughput reports (every 1000 formulas) *(completed -- throughput collapsed at timeout formulas)*
- [x] If generation exceeds 90 minutes, note the throughput rate and record partial progress *(deviation: altered -- killed after ~20 minutes; throughput: 37 c7 formulas in ~20min due to 3 timeout formulas consuming most time)*
- [x] Verify output record count (~50,000) and inspect metadata *(deviation: altered -- only 41 records obtained; stale c7 dataset (49,904 records) used for formula space estimation)*
- [x] Compare c7 timeout rate and method distribution against c5 and c6 *(completed -- c7 data too sparse for reliable rate, but stale c7 shows 2.8% timeout rate at c=7 with 1,201 timeouts from 42,467 formulas)*
- [x] Record wall-clock generation time and formulas-per-second throughput *(completed -- generation bottlenecked by timeout formulas; estimated 120+ hours for exhaustive c7 with current procedure)*

**Timing**: 2 hours (generation may take 30-90 minutes; includes monitoring and verification)

**Depends on**: 1

**Files to modify**:
- `data/bmlogic-c7-clean.jsonl` - Generated output (new file, separate from stale c7)
- `data/bmlogic-c7-clean_metadata.json` - Generated metadata (new file)

**Verification**:
- c7 dataset file exists with ~50,000 records
- Metadata shows valid decision method distribution
- Wall-clock time and throughput recorded

---

### Phase 3: Generate c8 Dataset (Stratified) [COMPLETED]

**Goal**: Generate a c8 dataset using stratified sampling to cap runtime while obtaining representative scaling data at the c8 level.

**Tasks**:
- [x] Generate c8 stratified dataset *(deviation: altered -- used quota "3:1,4:1,5:1,6:1,7:1,8:100" for a small sample; obtained 102 records (97 at c=8) before killing due to 10+ minute timeout on single formula; 50K c8 formulas is completely impractical)*
- [x] Monitor progress and record throughput *(completed -- 97 non-timeout c8 formulas processed in ~1 minute; then stuck on timeout formula for 10+ minutes)*
- [x] If 50K c8 formulas complete in reasonable time (<2 hours), consider running exhaustive c8 *(deviation: skipped -- confirmed impractical; c8 has estimated thousands of timeout formulas, each taking 10+ minutes)*
- [x] Verify output and inspect metadata for timeout rate and method distribution *(completed -- 7 timeouts from 97 c8 formulas = 7.2% timeout rate at c=8)*
- [x] Record wall-clock generation time *(completed -- 11+ minutes for 102 records; single c8 timeout formula exceeded 10 minutes before kill)*
- [x] Note whether any formulas resolve at tier 2 (fuel=2000) or tier 3 (fuel=10000) that are NOT timeouts *(completed -- bimodal distribution holds: zero tier 2 or tier 3 non-timeout formulas at c=8)*

**Timing**: 2.5 hours (including possible retry with different quotas)

**Depends on**: 2

**Files to modify**:
- `data/bmlogic-c8-stratified.jsonl` - Generated output (new file)
- `data/bmlogic-c8-stratified_metadata.json` - Generated metadata (new file)

**Verification**:
- c8 dataset file exists with records (up to ~50K for c8 level)
- Metadata shows valid decision method distribution
- Timeout rate, throughput, and timing recorded

---

### Phase 4: Analyze Scaling Data and Classify Timeout Patterns [COMPLETED]

**Goal**: Create an analysis script that processes all generated datasets (c5, c6, c7, c8) to produce scaling curves, timeout pattern classification, and decision method distribution tables.

**Tasks**:
- [x] Write a Python or shell analysis script (`data/scripts/analyze_scaling.py`) that reads the JSONL files and computes per-level stats, method distribution, timeout patterns, scaling curves, and bimodal analysis *(completed)*
- [x] Run the analysis on c5, c6, c7-clean, and c8-stratified datasets *(completed -- CSVs exported to data/scaling_analysis/)*
- [x] Identify whether the bimodal distribution (resolve at tier 1 or timeout) persists at c6/c7/c8 *(completed -- bimodal holds perfectly: zero tier 2 or tier 3 non-timeout formulas at any level)*
- [x] Identify any new timeout patterns not present at c5 *(completed -- new pattern "temporal-modal-mix" (Until/Since + box nesting) emerges at c6, comprising 26% of c6 timeouts)*
- [x] Compute the scaling curve: complexity level vs timeout rate *(completed -- c5:2.9%, c6:4.7%, c7:8.1%, c8:7.2%; real bottleneck is per-formula timeout detection cost, not rate)*
- [x] Compute formulas-per-second throughput at each level *(completed -- ~50K/sec for non-timeout formulas; 0.0024/sec (1 per 7 min) for slow timeout formulas)*
- [x] Identify the dominant timeout patterns at each level and whether their proportion changes *(completed -- critical finding: most timeouts detect in <1ms via fast-path, but 2-3 "slow timeouts" per level take 400-600+ seconds each, dominating total wall-clock time)*

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `data/scripts/analyze_scaling.py` - Analysis script (new file)

**Verification**:
- Analysis script runs without errors on all four datasets
- Output includes scaling table, timeout pattern classification, and decision method distribution
- Scaling curve data is produced (complexity vs timeout rate)

---

### Phase 5: Produce Bottleneck Characterization Report [COMPLETED]

**Goal**: Synthesize analysis results into a structured bottleneck characterization report with actionable findings.

**Tasks**:
- [x] Write the scaling analysis results into a structured summary within the task directory *(completed)*
- [x] Include sections: scaling curve, method distribution, timeout patterns, bimodal analysis, new patterns, countermodel cost, bottleneck characterization, recommendations *(completed)*
- [x] Archive raw scaling data (CSV or JSON) for reproducibility *(completed -- data/scaling_analysis/scaling_curve.csv and timeout_patterns.csv)*
- [x] Summarize the key finding: at what complexity level does the timeout rate become unacceptable? *(completed -- c=6 is the threshold, bottleneck is per-formula timeout detection cost not rate)*

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `specs/264_scale_dataset_timeout_bottleneck/summaries/01_scaling-bottleneck-summary.md` - Bottleneck characterization report (new file)

**Verification**:
- Report contains scaling curve, pattern analysis, and actionable recommendations
- All data points from c5 through c8 are included
- Key bottleneck threshold is identified

## Testing & Validation

- [ ] All generated datasets have valid JSONL format (one JSON object per line, parseable)
- [ ] No records in any generated dataset have `decision_method: "unknown"`
- [ ] c6 record count is within expected range (6,000-9,000)
- [ ] c7-clean record count is within expected range (40,000-55,000)
- [ ] Analysis script produces consistent results across multiple runs
- [ ] Scaling curve shows a clear trend (monotonic or with identified anomalies)

## Artifacts & Outputs

- `data/bmlogic-c6.jsonl` - Clean c6 dataset
- `data/bmlogic-c6_metadata.json` - c6 metadata
- `data/bmlogic-c7-clean.jsonl` - Clean c7 dataset (replaces stale c7)
- `data/bmlogic-c7-clean_metadata.json` - c7 metadata
- `data/bmlogic-c8-stratified.jsonl` - Stratified c8 dataset
- `data/bmlogic-c8-stratified_metadata.json` - c8 metadata
- `data/scripts/analyze_scaling.py` - Scaling analysis script
- `specs/264_scale_dataset_timeout_bottleneck/summaries/01_scaling-bottleneck-summary.md` - Bottleneck characterization report

## Rollback/Contingency

- All new datasets use distinct filenames (`bmlogic-c6.jsonl`, `bmlogic-c7-clean.jsonl`, `bmlogic-c8-stratified.jsonl`) and do not overwrite existing data
- The stale `bmlogic-c7.jsonl` is preserved for comparison if needed
- If c8 generation proves too slow even with stratified sampling, reduce the quota from 50K to 10K
- If `lake build` fails, focus on diagnosing the build error before proceeding (the modified `ChronicleToCountermodel.lean` may need attention)
- The analysis script is independent of the datasets and can be re-run at any time
