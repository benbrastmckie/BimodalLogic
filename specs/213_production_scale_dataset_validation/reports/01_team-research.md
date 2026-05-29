# Research Report: Task #213 — Production-Scale Dataset Generation Validation

**Task**: 213 — Production-scale dataset generation validation
**Date**: 2026-05-29
**Mode**: Team Research (4 teammates)
**Session**: sess_1780088631_bfd193

---

## Executive Summary

Task 210 successfully fixed the enumeration blowup (complexity 5: 1ms/1,644 formulas; complexity 7: 3ms/51,244 formulas). However, the pipeline is **not production-ready**. Four critical issues remain:

1. **Valid fraction gate unmet**: Combined pipeline produces 4% valid, not the required 15%.
2. **Validity signal is degenerate**: 94% of valid formulas in the medium dataset are trivial `(⊥ → φ)` ex_falso instances — not useful training signal.
3. **Axiom seeds lack temporal operators**: All 8 schemata produce only propositional/modal formulas; no Until/Since coverage.
4. **Full pipeline at 51K scale was never run**: Labeling throughput, memory, and valid fraction at complexity 7 are unmeasured.

The enumeration fix is real and important, but the bottleneck has shifted from formula generation to **signal quality** and **labeling infrastructure**.

---

## Key Findings

### 1. Enumeration Fix Confirmed (Task 210) — HIGH CONFIDENCE

| Metric | Pre-fix | Post-fix | Improvement |
|--------|---------|----------|-------------|
| Complexity 5 time | >1.5 hours | 1ms | >5,400,000x |
| Complexity 5 formulas | 937K raw / 1,440 distinct | 1,644 (levels 1-5) | Clean |
| Complexity 7 time | Infeasible | 3ms | N/A |
| Complexity 7 formulas | N/A | 51,244 (levels 1-7) | New capability |

Exhaustive enumeration at complexity 5-7 is now a solved problem.

### 2. Valid Fraction Gate Failure — CRITICAL

The plan's 15% valid fraction gate was **not met**:

| Test | Valid % | Notes |
|------|---------|-------|
| Task 204 medium (complexity 4) | 25% | Baseline |
| Task 204 deep (complexity 7 random) | 1.6% | Baseline |
| Task 210 axiom-only pool (100 samples) | 60% | 40% timeout |
| Task 210 combined pool (200 samples from front) | 4% | Gate failure |

The benchmark sampled 200 formulas from the **front** of the combined list, which is dominated by exhaustive formulas (appended before axiom seeds). The 500 axiom seeds in a 51K pool represent only ~1% of formulas — insufficient to move the aggregate ratio above 15%.

### 3. Validity Signal Quality Crisis — CRITICAL

Teammate D's direct analysis of `bmlogic-medium.jsonl` reveals:

- **1,208 of 1,284 valid formulas (94%) are `(⊥ → φ)` ex_falso instances**
- Only 76 are genuine non-trivial theorems (modal_t, prop_s instances)
- **All proof heights are 0** — `decideAuto` returns single-axiom derivations
- A model could trivially learn "valid = starts with ⊥" from this data

This is the deeper problem: even if we meet the 15% gate numerically, the validity signal is degenerate. Training on this data would not produce a useful proof search system.

### 4. Axiom Seeds Lack Temporal Operators — HIGH

The `instantiateAxiom` function covers 8 schemata: `prop_s`, `prop_k`, `ex_falso`, `peirce`, `modal_t`, `modal_4`, `modal_b`, `modal_k_dist`. None produce top-level Until or Since formulas. Additionally, `randomSubFormula` generates only `atom`, `imp`, and `box` — no temporal operators in sub-formulas either.

This means:
- No guaranteed-valid temporal formulas from axiom seeding
- `enrichWithDuals` provides zero benefit for axiom seeds (no temporal content to swap)
- The valid fraction improvement from seeding is limited to propositional and modal categories

### 5. CLI Parameter Gap — HIGH

`DatasetExport.lean` constructs `EnumParams` without exposing `validSeedCount` in `CLIArgs` or `parseCLIArgs`. The field uses the struct default (500), which is architecturally present but **operationally inaccessible** for tuning from production run scripts.

### 6. Labeling Throughput Unmeasured — HIGH

The benchmark labeled only 200 formulas (front of combined list). At complexity 7 with fuel=170 tableau steps, estimated per-formula labeling cost is 10-100ms. For 51,244 formulas: **8.5 minutes to 85 minutes** of labeling time — untested.

Additionally:
- `labelBatch` accumulates all `LabeledFormula` objects in memory before export
- `eraseDups` on the 51K combined list is O(n²) — potentially minutes of CPU time
- No wall-clock timeout on `decideAuto` (fuel bounds steps, not time)

### 7. Run Script is Stale — MEDIUM

`scripts/run_dataset_generation.sh` still specifies pre-task-210 workarounds:
- Medium run: `--max-complexity 4` (complexity 5 is now feasible)
- Deep run: `--mode random` (exhaustive at complexity 7 is now feasible)

### 8. Proof Step Extractor Disconnection — MEDIUM

Task 212's `proof_steps.jsonl` provides 2,424 deep derivation records from 36 theorems (heights up to 325). The formula dataset provides shallow, axiom-dominated records (height 0). These complementary signals are not integrated — task 212's proven theorems could feed back as validity seeds to dramatically improve signal quality.

---

## External Best Practices (2025-2026 Literature)

Teammate B's web research validated the pipeline design and identified enhancement opportunities:

### Validated Design Decisions
- **15-30% valid fraction is field-standard** (SATBench, DeepSeek-Prover, TP-as-Judge)
- **Contrastive pair generation** (FormulaMutator, task 206) matches state-of-the-art (DeepSeek-Prover-V2, HTPS)
- **Difficulty metrics** already capture the right signals; the feasibility gate thresholds are well-calibrated

### Key Enhancement Recommendations from Literature
1. **Saturation-based generation** (arXiv:2509.06809): Run Nec/MP closure to fixpoint instead of just 2 rounds — captures more valid consequences
2. **Streaming write**: Essential at 50K+ scale; prevents OOM. Refactor `DatasetExport.lean` to write-per-record (~30min effort)
3. **Parallel labeling via `IO.asTask`**: 3-4x throughput improvement (~2h effort)
4. **Decision time as difficulty proxy**: Formulas taking 10-100ms to decide are most informative for training (STP "barely provable" insight)
5. **New quality metrics**: Axiom schema coverage rate (>50% of 35 schemas), PatternKey uniqueness (>80%), decision time distribution (>30% formulas >5ms)

### Sources
- Saturation-Driven Dataset Generation (arXiv:2509.06809)
- STP Self-Play Theorem Prover (arXiv:2502.00212)
- DeepSeek-Prover / V2 (arXiv:2405.14333, arXiv:2504.21801)
- SATBench (ACL EMNLP 2025)
- Beyond Scale: Diversity Coefficient (arXiv:2306.13840)

---

## Synthesis

### Conflicts Resolved

1. **CLI validSeedCount wiring**: Teammate A initially reported a critical bug (CLI doesn't set validSeedCount), then self-corrected: Lean 4 struct defaults mean the CLI does get 500 seeds. Teammate C correctly noted the parameter defaults to 500 but the CLI offers no flag to tune it. **Resolution**: Axiom seeding IS active at 500 by default, but the CLI needs a `--valid-seed-count` flag for production tuning. The real problem is that 500 seeds in 51K formulas is insufficient — needs ~5,000-10,000 seeds or preferential mixing.

2. **Formula count discrepancy (1,644 vs 1,440)**: Teammate C flagged this. The research predicted 1,440 at exact complexity 5; the implementation produces 1,644 across levels 1-5 cumulative. **Resolution**: No bug — these are different measurements (single level vs cumulative). Not a concern.

### Gaps Identified

1. **No full end-to-end CLI run at complexity 7**: `lake exe dataset_generator -- --max-complexity 7` has never been executed. Wall-clock time is unknown.
2. **No memory profiling**: Peak heap for 51K `LabeledFormula` objects is unknown.
3. **No reproducibility**: `generateValidBatch` uses `IO.rand` (non-deterministic). The dataset is not reproducible without a fixed seed.
4. **Timeout handling unclear**: Formulas labeled `.timeout` enter the dataset — downstream ML handling is undefined.
5. **The `decideOptimized` retry path was never exercised** in benchmarks.

### Recommendations

#### Task Scoping (Teammate D's recommendation, endorsed)

Split task 213 into two concerns:

**Phase A — Regression Validation (4-6 hours)**:
- Run `lake exe dataset_generator` at complexity 5 (exhaustive) and complexity 7 (exhaustive)
- Measure wall-clock time, valid fraction, memory, output integrity
- Update run script with post-task-210 parameters
- Expose `--valid-seed-count` as CLI flag
- Confirm the enumeration fix works in the full pipeline

**Phase B — Signal Quality Enhancement (8-12 hours)**:
- Diagnose and fix the ex_falso dominance (94% of valid formulas)
- Add temporal axiom schemata to `instantiateAxiom` (serial_future, until_F, connect_future)
- Add temporal operators to `randomSubFormula` (untl, snce)
- Integrate task 212's 36 proven theorems as validity seeds
- Run Nec/MP closure to fixpoint (not just 2 rounds)
- Add streaming write to prevent OOM at 50K+
- Target: ex_falso < 50% of valid set, valid fraction > 15%, all 4 operator categories >10%

#### Priority-Ordered Implementation Actions

| Priority | Action | Effort | Impact |
|----------|--------|--------|--------|
| P0 | Run full pipeline at complexity 5 and 7 to measure baselines | 1h | Unblocks all other work |
| P1 | Add `--valid-seed-count` CLI flag | 30min | Enables tuning |
| P1 | Add temporal axiom schemata + temporal sub-formulas | 2h | Fixes operator diversity gap |
| P1 | Add streaming write to DatasetExport.lean | 30min | Prevents OOM at 50K+ |
| P2 | Diagnose and fix ex_falso dominance | 2-4h | Fixes validity signal quality |
| P2 | Integrate task 212 theorem seeds into generateValidBatch | 2h | Enriches valid pool |
| P2 | Run Nec/MP closure to fixpoint | 1h | Increases valid yield |
| P3 | Add parallel labeling via IO.asTask | 2h | 3-4x throughput |
| P3 | Add axiom schema coverage metric | 1h | Better diagnostics |
| P3 | Add decision time distribution metric | 30min | Difficulty calibration |
| P4 | Add in-memory labeling cache | 30min | Dedup optimization |
| P4 | Add dataset version field to metadata | 10min | Reproducibility |

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | Infrastructure Analysis | completed | high | Pipeline architecture mapped; CLI defaults to 500 seeds but no tuning flag |
| B | External Best Practices | completed | high | Saturation-based generation is gold standard; streaming write essential at 50K+ |
| C | Critic (Gaps/Risks) | completed | high | 15% gate unmet; benchmark only tested 200 formulas from front of list; complexity 7 never tested |
| D | Strategic Horizons | completed | high | 94% ex_falso dominance; task 212 disconnected; recommend task split |

---

## References

### Internal Artifacts
- Task 204 summaries: `specs/204_dataset_production_runs/summaries/`
- Task 210 research: `specs/210_enumerator_complexity_blowup/reports/01_enumerator-blowup-research.md`
- Task 210 summary: `specs/210_enumerator_complexity_blowup/summaries/01_enumerator-blowup-summary.md`
- Task 212 summary: `specs/212_implement_proof_step_extractor/summaries/01_implementation-summary.md`
- `data/bmlogic-medium.jsonl` (5,136 records) — analyzed by Teammate D
- `data/bmlogic-deep.jsonl` (53,979 records)
- `data/proof_steps.jsonl` (2,424 records)

### External Sources (Teammate B)
- Saturation-Driven Dataset Generation (arXiv:2509.06809)
- STP Self-Play Theorem Prover (arXiv:2502.00212)
- DeepSeek-Prover (arXiv:2405.14333)
- DeepSeek-Prover-V2 (arXiv:2504.21801)
- SATBench (ACL EMNLP 2025)
- LeanProgress (arXiv:2502.17925)
- HyperTree Proof Search (Gebner et al.)
- Beyond Scale: Diversity Coefficient (arXiv:2306.13840)
