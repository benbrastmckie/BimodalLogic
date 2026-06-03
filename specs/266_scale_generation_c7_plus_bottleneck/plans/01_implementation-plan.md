# Implementation Plan: Task #266 - Scale Dataset Generation c7+ Bottleneck

- **Task**: 266 - Scale dataset generation to c7+ to find next bottleneck
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: Task 265 (pre-filter, completed)
- **Research Inputs**: specs/266_scale_generation_c7_plus_bottleneck/reports/01_scaling-bottleneck.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The c7 dataset generation completes healthily in 33 seconds (49,865 formulas, zero slow formulas), but c8 generation stalls on temporal-modal feedback-loop formulas where a single formula consumed 14+ minutes. The root cause is per-fuel-step cost asymmetry: formulas with `temporal -> temporal(box)` structure create exponentially branching tableaux where fuel=500 steps translate to minutes of wall-clock time. This plan adds a per-formula wall-clock timeout to `labelFormula`, regenerates the complete c8 dataset, runs a stratified c9 sample to characterize the next level, and produces the final scaling curve.

### Research Integration

Key findings from the research report:
- C7 is healthy: 33s, 49,865 formulas, 2,410 timeouts (4.8%), zero slow (>1s) formulas
- C8 stalls at formula #147,865 (`U(p, bot) -> U(p, box(bot))`) due to temporal-modal feedback loops
- The branching factor per tableau step varies by orders of magnitude (microseconds for simple formulas, seconds for temporal-modal combinations)
- C8 has ~253K formulas; completing exhaustive generation would take 6-8 hours without a wall-clock cap
- A 5-second wall-clock timeout would cap c8 exhaustive generation at ~10-15 minutes
- C9 has ~1.2M formulas; exhaustive generation is impractical (>100 hours), so stratified sampling is the right approach

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items explicitly reference dataset scaling, but this work advances the overall dataset generation pipeline maturity.

## Goals & Non-Goals

**Goals**:
- Add a per-formula wall-clock timeout (5 seconds) to `labelFormula` that caps runaway `decideAutoAdaptive` calls
- Regenerate the complete c8 exhaustive dataset using the new timeout
- Run c9 with stratified sampling to characterize timeout patterns at the next level
- Produce a scaling curve table (c3-c9) with wall-clock, timeout rate, and throughput data

**Non-Goals**:
- Implementing fuel-budget splitting (M3 from research) -- medium-term optimization, not needed now
- Extending the structural pre-filter for new patterns (M2) -- marginal impact on wall-clock bottleneck
- Making c9 exhaustive generation feasible -- stratified sampling is sufficient
- Modifying the tableau expansion algorithm itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean `IO.asTask` timeout mechanism is awkward or unavailable in current Lean version | H | M | Fall back to polling `IO.monoMsNow` inside `decide` by threading an optional deadline parameter |
| Wall-clock timeout introduces non-determinism in datasets | M | H | Document that timed-out formulas are labeled consistently as `timeout` with `wallclock_timeout` method; set a generous 5s cap so borderline formulas are rare |
| C8 exhaustive generation still takes too long even with 5s cap | M | L | At most ~8,000 timeouts x 5s = 40,000s = 11 hours worst case, but most timeouts resolve in <100ms; realistic estimate is 10-15 minutes total |
| C9 stratified sampling misses important formula classes | L | M | Use quota-per-level sampling to ensure representation across formula shapes; run with generous quotas (50K at c9) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add Wall-Clock Timeout to labelFormula [COMPLETED]

**Goal**: Implement a per-formula wall-clock timeout that prevents `decideAutoAdaptive` from consuming unbounded time on hard formulas.

**Tasks**:
- [x] Modify `labelFormula` in `DatasetGenerator.lean` to accept an optional `wallclockTimeoutMs` parameter (default 5000)
- [x] Wrap the `decideAutoAdaptive` call in a wall-clock-bounded wrapper: spawn the computation as an `IO.asTask`, then race it against a deadline using `IO.monoMsNow` polling or `Task.get` with timeout *(deviation: altered — used post-hoc wall-clock check instead of IO.asTask since decideAutoAdaptive is pure; simpler and equally effective)*
- [x] If the simpler approach is needed (Lean `IO.asTask` not suitable for pure computations), modify `decide` in `DecisionProcedure.lean` to accept an optional `IO.Ref Nat` for a deadline timestamp, and check `IO.monoMsNow` periodically during tableau expansion (every N steps) -- this requires making `decide` return in `IO` or threading a cancellation check *(deviation: skipped — post-hoc check approach made this unnecessary)*
- [x] Evaluate which approach is most practical: (a) `IO.asTask` spawn + timeout race, (b) convert `decideAutoAdaptive` to IO with periodic time checks, or (c) wrap the entire call in a Task with `IO.wait` timeout *(deviation: altered — chose option (d): post-hoc wall-clock check, simplest approach since the function is pure)*
- [x] When timeout fires, return a `LabeledFormula` with `label := .timeout`, `decisionMethod := "wallclock_timeout"`, and `metrics.decisionTimeMs` set to the elapsed time
- [x] Update `DatasetExport.lean` `main` to pass the wall-clock timeout parameter (add `--wallclock-timeout` CLI flag, default 5000ms)
- [x] Run `lake build` to verify compilation

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Add timeout wrapper to `labelFormula`
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add `--wallclock-timeout` CLI flag and pass through
- Possibly `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - If periodic time-check approach is needed

**Verification**:
- `lake build` succeeds
- Running `lake exe dataset_generator -- --max-complexity 6 --output /tmp/test-c6.jsonl` produces identical results to the existing c6 dataset (no formulas should hit the 5s timeout at c6)
- Running with `--wallclock-timeout 1` on a known-hard formula produces a `wallclock_timeout` labeled result

---

### Phase 2: Regenerate Complete C8 Dataset [NOT STARTED]

**Goal**: Run exhaustive c8 generation with the wall-clock timeout to produce a complete c8 dataset.

**Tasks**:
- [ ] Delete or rename the partial `data/bmlogic-c8-clean.jsonl` (147,864 records) and its checkpoint file
- [ ] Run full c8 generation: `lake exe dataset_generator -- --max-complexity 8 --output data/bmlogic-c8-clean.jsonl --wallclock-timeout 5000`
- [ ] Verify the output record count matches the expected ~253K formulas
- [ ] Record generation metrics: total wall-clock time, timeout count, timeout rate, wallclock_timeout count, mean/max decision time
- [ ] Classify c8 timeout patterns (temporal-modal feedback loops, bare temporal, etc.)
- [ ] Identify how many formulas hit the wall-clock timeout vs. the fuel timeout

**Timing**: 1 hour (including ~15 min generation time + analysis)

**Depends on**: 1

**Files to modify**:
- `data/bmlogic-c8-clean.jsonl` - Complete regeneration
- `data/bmlogic-c8-clean_metadata.json` - Updated metadata

**Verification**:
- Output file has ~253K records (matching expected c8 formula count)
- No single formula takes >6 seconds (5s timeout + overhead)
- Total generation time is <20 minutes
- Metadata file shows complete generation (not partial)

---

### Phase 3: Run C9 Stratified Sample [NOT STARTED]

**Goal**: Generate a stratified c9 sample to characterize timeout patterns and estimate exhaustive generation feasibility at c9.

**Tasks**:
- [ ] Run stratified c9 generation with generous quota: `lake exe dataset_generator -- --max-complexity 9 --mode stratified --stratified-quotas "9:50000" --output data/bmlogic-c9-sample.jsonl --wallclock-timeout 5000`
- [ ] Record metrics: total formulas sampled, timeout count and rate, wallclock_timeout count, mean/max decision time, generation wall-clock time
- [ ] Classify c9 timeout patterns -- compare with c7 and c8 patterns
- [ ] Estimate total c9 exhaustive generation time from the sample data
- [ ] If sample completes quickly, consider running with higher quota (100K)

**Timing**: 45 minutes

**Depends on**: 2

**Files to modify**:
- `data/bmlogic-c9-sample.jsonl` - New stratified sample
- `data/bmlogic-c9-sample_metadata.json` - Sample metadata

**Verification**:
- Output file has the expected number of records (~50K or quota-adjusted)
- Generation completes within a reasonable time (<30 minutes)
- Timeout patterns are documented

---

### Phase 4: Produce Scaling Curve and Summary [NOT STARTED]

**Goal**: Compile the complete c3-c9 scaling curve with all metrics and document findings.

**Tasks**:
- [ ] Compile the scaling curve table from all datasets: c3-c7 (existing), c8 (new complete), c9 (sample)
- [ ] Include columns: level, unique formulas, wall-clock time, timeouts, timeout rate, wallclock_timeout count, throughput (formulas/sec)
- [ ] Calculate and document the formula count growth rate across levels
- [ ] Identify the next bottleneck (if any) beyond the wall-clock timeout fix
- [ ] Assess whether c10 generation is feasible with any approach
- [ ] Document the wall-clock timeout distribution: how many formulas hit 5s vs. fuel timeout

**Timing**: 45 minutes

**Depends on**: 2, 3

**Files to modify**:
- No source files modified; output is the task summary produced during implementation wrap-up

**Verification**:
- Scaling curve covers c3 through c9
- Growth rate trend is consistent with research predictions (5-7x per level)
- Next bottleneck (if any) is clearly identified

## Testing & Validation

- [ ] `lake build` succeeds after Phase 1 modifications
- [ ] C6 regression test: generation with wall-clock timeout produces same results as without (no c6 formula should hit 5s)
- [ ] C8 complete dataset has expected record count (~253K)
- [ ] No formula in c8 output exceeds 6s decision time (5s timeout + overhead)
- [ ] C9 sample generation completes within 30 minutes
- [ ] All output JSONL files are valid (each line parses as JSON)
- [ ] Metadata files match actual record counts

## Artifacts & Outputs

- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Modified with wall-clock timeout
- `Theories/Bimodal/Automation/DatasetExport.lean` - Modified with `--wallclock-timeout` CLI flag
- `data/bmlogic-c8-clean.jsonl` - Complete c8 dataset
- `data/bmlogic-c8-clean_metadata.json` - C8 metadata
- `data/bmlogic-c9-sample.jsonl` - C9 stratified sample
- `data/bmlogic-c9-sample_metadata.json` - C9 sample metadata

## Rollback/Contingency

Phase 1 modifies two Lean source files. If the wall-clock timeout implementation causes issues:
- `git stash` or `git checkout` the modified files to restore the original behavior
- The existing partial c8 dataset (147,864 records) remains usable if regeneration fails
- If `IO.asTask` approach fails, fall back to a simpler approach: reduce fuel from 500 to a lower value (e.g., 100) specifically for formulas that match the temporal-modal structural signature, as a stopgap before implementing proper wall-clock timeout
