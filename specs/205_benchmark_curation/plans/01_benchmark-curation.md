# Implementation Plan: BMLogic-Bench Benchmark Curation

- **Task**: 205 - Curate stratified evaluation benchmark (BMLogic-Bench)
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: Task 204 (production dataset generation -- completed)
- **Research Inputs**: specs/205_benchmark_curation/reports/01_benchmark-curation.md
- **Artifacts**: plans/01_benchmark-curation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build BMLogic-Bench, a stratified evaluation benchmark of 500-1K formulas for decidable bimodal logic TM. The production dataset (59K records, 3.7% valid) is heavily imbalanced and dominated by trivial ex_falso instances (93% of valid formulas), so direct sampling is insufficient. The pipeline has four stages: (1) generate concrete axiom instances in Lean for all 42 BX schemata to produce substantive valid formulas, (2) build a Python curation script that loads production data, generates near-miss mutations, and performs stratified sampling, (3) validate all benchmark labels via the Lean decision procedure oracle, and (4) export the final benchmark with metadata. The definition of done is a `data/bmlogic-bench.jsonl` file containing 500-1K formulas with ~50/50 valid/invalid balance, correct tier distribution (easy 20%, medium 40%, hard 30%, very hard 10%), all 42 axiom anchor instances, and zero label errors.

### Research Integration

Key findings from the research report (01_benchmark-curation.md):
- Production data has only 2,172 valid formulas, 93% trivially ex_falso. Non-trivial valid count is ~146.
- Easy tier has zero valid formulas in production data; very_hard tier has only 14.
- All production valid formulas have proof height 0 (single axiom application).
- Axiom instance generation with varied substitutions can yield ~500-2,000 valid formulas.
- Near-miss mutation (single-operator changes to valid formulas) produces hard negatives.
- The oracle (`decideOptimized`) handles bounded-complexity formulas reliably.
- Frame class is Base throughout; 5 uniformity axioms are valid on Base, but dense/discrete axioms are not.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Generate concrete formula instances for all 42 BX axiom schemata as known-valid anchors
- Build a Python curation script for pool construction, near-miss mutation, and stratified sampling
- Produce a benchmark with ~50/50 valid/invalid balance and tier distribution matching targets
- Validate every benchmark formula's ground-truth label via the decision procedure oracle
- Export `data/bmlogic-bench.jsonl` and `data/bmlogic-bench_metadata.json`

**Non-Goals**:
- Modifying the decision procedure or axiom system
- Adding new frame classes (Dense, Discrete) to the benchmark
- Building multi-step proof formulas (proof height > 0) -- these would require a separate generation strategy
- Creating a leaderboard or evaluation harness for ML models
- Modifying the existing production datasets

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Insufficient valid formulas after axiom enrichment | H | M | Increase substitution vocabulary beyond atoms (use box(p), F(p), U(p,q)); mine derived theorems from Theorems/ directory |
| Easy tier has zero valid formulas | M | H | Adjust easy tier to 15% or generate very simple axiom instances (ex_falso(p) has complexity 3); relax complexity boundary if needed |
| Oracle timeouts on enriched formulas | M | L | Use `decideOptimized` with generous fuel; exclude persistent timeouts and replace from pool |
| Near-miss mutations all trivially invalid | M | L | Verify via oracle; ensure structural closeness by limiting mutation depth to 1 |
| Lean compilation time for BenchmarkAnchors module | M | M | Limit substitution vocabulary size; generate lazily; use IO-based generation rather than term-mode |
| Python-Lean integration failures | M | L | Use subprocess calls with JSONL stdin/stdout protocol; test interface early |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Lean Axiom Instance Generator [COMPLETED]

**Goal**: Create a Lean module that generates concrete formula instances of all 42 BX axiom schemata with varied substitutions, labels them via the decision procedure, and exports them as JSONL.

**Tasks**:
- [ ] Create `Theories/Bimodal/Automation/BenchmarkAnchors.lean` module
- [ ] Define substitution vocabulary: atoms (p, q, r), box(p), neg(p), F(p), all_future(p), U(p,q), S(p,q) -- approximately 8 base terms
- [ ] Implement `generateAxiomInstances` function that instantiates each of the 42 `Axiom` constructors with combinations from the substitution vocabulary
- [ ] For ground axioms (11 constructors), produce the single fixed formula
- [ ] For parameterized axioms: 1-param with 8 subs = ~96, 2-param with 8x8 sampled = ~200, 3-param with 8x8x8 sampled = ~200, 4-param sampled = ~100
- [ ] Label each generated formula via `labelFormula` from `DatasetGenerator.lean`
- [ ] Verify all axiom instances are decided `.valid` (fail loudly if any are not)
- [ ] Export generated instances as JSONL records matching the production schema (id, formula_str, formula_ast, label, metrics, etc.)
- [ ] Register `benchmark_anchors` as a `lean_exe` in `lakefile.lean`
- [ ] Run `lake exe benchmark_anchors -- --output data/axiom-instances.jsonl` and verify output

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/BenchmarkAnchors.lean` (new) -- axiom instance generator
- `lakefile.lean` -- add `benchmark_anchors` executable
- `data/axiom-instances.jsonl` (new output) -- generated axiom instances

**Verification**:
- `lake build BenchmarkAnchors` compiles without errors
- `lake exe benchmark_anchors` produces JSONL output
- All generated formulas have label "valid"
- Output covers all 42 axiom constructors (check distinct axiom coverage)
- Instance count is in the range 400-700

---

### Phase 2: Python Curation Script [COMPLETED]

**Goal**: Build the Python curation pipeline that loads production data, loads axiom instances, generates near-miss mutations, constructs valid and invalid pools, and performs stratified sampling.

**Tasks**:
- [ ] Create `scripts/curate_benchmark.py` with the following components:
- [ ] **Pool loader**: Read `data/bmlogic-medium.jsonl`, `data/bmlogic-deep.jsonl`, and `data/axiom-instances.jsonl`; filter timeouts; deduplicate by `formula_str`; separate into valid and invalid pools
- [ ] **Near-miss mutation engine**: Implement 8 mutation operators on formula ASTs (swap_args, swap_op, negate, drop_box, add_box, atom_swap, bot_inject, weaken_guard)
- [ ] **Mutation generator**: For each non-ex_falso valid formula, apply all 8 mutations; collect candidate near-miss formulas; deduplicate
- [ ] **Difficulty tier assignment**: Use existing `difficultyTier` from records, or compute from `complexity` field for generated formulas
- [ ] **Stratified sampler**: Sample from valid and invalid pools per tier quotas (easy 20%, medium 40%, hard 30%, very_hard 10%), targeting ~50/50 balance
- [ ] **Anchor inclusion**: Ensure all 42 axiom instances appear in the benchmark (assigned to appropriate tiers based on complexity)
- [ ] **Known-invalid anchors**: Include the 20 known-invalid formulas from DatasetValidator.lean (hardcode or extract from JSONL)
- [ ] **Near-miss inclusion**: Include near-miss mutations as labeled candidates (label TBD by oracle in Phase 3)
- [ ] **Output writer**: Write candidate benchmark as `data/bmlogic-bench-candidates.jsonl` with `label` field set to production label for known formulas or "unlabeled" for mutations
- [ ] **Statistics reporter**: Print pool sizes, tier distribution, valid/invalid counts, anchor coverage

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `scripts/curate_benchmark.py` (new) -- main curation script
- `data/bmlogic-bench-candidates.jsonl` (new output) -- candidate benchmark before oracle validation

**Verification**:
- Script runs without errors: `python scripts/curate_benchmark.py`
- Candidate file contains 600-1200 entries (oversample to allow for oracle filtering)
- All 42 axiom anchor instances are present
- Near-miss mutations are generated (count > 100)
- Tier distribution is approximately correct before oracle validation

---

### Phase 3: Oracle Validation [COMPLETED]

**Goal**: Run the Lean decision procedure on every candidate benchmark formula to confirm or assign ground-truth labels, then filter out timeouts and mismatches.

**Tasks**:
- [ ] Create `scripts/validate_benchmark.py` -- orchestrator that feeds candidate formulas to the Lean oracle
- [ ] Extend or create a Lean oracle executable that reads formula strings from a JSONL file and outputs labeled results (reuse `dataset_generator` infrastructure or create `benchmark_oracle` executable)
- [ ] If creating new executable: register in `lakefile.lean`, implement stdin/file-based formula input, output label + proof_trace/countermodel
- [ ] Run oracle on all candidate benchmark entries from `data/bmlogic-bench-candidates.jsonl`
- [ ] For entries with existing production labels: verify oracle agrees (flag mismatches as errors)
- [ ] For near-miss mutations and new axiom instances: assign oracle label as ground truth
- [ ] Filter out any formulas where oracle returns timeout
- [ ] Write validated results to `data/bmlogic-bench-validated.jsonl`
- [ ] Report: total validated, label distribution, timeouts removed, mismatches found

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `scripts/validate_benchmark.py` (new) -- oracle validation orchestrator
- `Theories/Bimodal/Automation/BenchmarkOracle.lean` (new, if needed) -- formula oracle executable
- `lakefile.lean` (if adding new executable)
- `data/bmlogic-bench-validated.jsonl` (new output) -- oracle-validated benchmark

**Verification**:
- Oracle processes all candidates without crashes
- Zero label mismatches between oracle and existing production labels
- Timeout count is < 5% of candidates (discard those)
- All valid entries have proof_trace; all invalid entries have countermodel
- Validated file has at least 500 entries

---

### Phase 4: Final Export and Metadata [NOT STARTED]

**Goal**: Perform final stratified selection from the validated pool to produce the benchmark at target size and distribution, then write the benchmark file with comprehensive metadata.

**Tasks**:
- [ ] Create `scripts/finalize_benchmark.py` (or add final stage to `curate_benchmark.py`)
- [ ] Load `data/bmlogic-bench-validated.jsonl`
- [ ] Perform final stratified sampling to hit exact targets:
  - Easy: 15-20% (adjust based on valid availability)
  - Medium: 40%
  - Hard: 30-35%
  - Very hard: 10%
  - Valid/Invalid: ~50/50 within each tier
- [ ] Assign sequential benchmark IDs: `bmlogic-bench-00001`, `bmlogic-bench-00002`, ...
- [ ] Tag each entry with benchmark metadata: `benchmark_category` (anchor-valid, anchor-invalid, near-miss, sampled-valid, sampled-invalid), `source` (production, axiom-generated, mutation)
- [ ] Write `data/bmlogic-bench.jsonl` with final benchmark entries
- [ ] Write `data/bmlogic-bench_metadata.json` with:
  - Total count, valid/invalid counts
  - Tier distribution breakdown
  - Anchor coverage (all 42 axiom instances present)
  - Near-miss count and invalid rate
  - Source distribution (production vs generated vs mutation)
  - Schema version and generation date
- [ ] Verify file integrity: all entries parse as valid JSON, all required fields present

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `scripts/finalize_benchmark.py` (new) -- final selection and export
- `data/bmlogic-bench.jsonl` (new) -- final benchmark
- `data/bmlogic-bench_metadata.json` (new) -- benchmark metadata and statistics

**Verification**:
- `data/bmlogic-bench.jsonl` contains 500-1000 entries
- Valid/invalid split is within 45-55% range
- All 42 axiom instances are present (check by axiom name or formula match)
- Tier distribution matches targets within 5% tolerance
- All entries have non-null proof_trace or countermodel
- Metadata file matches actual benchmark statistics

---

### Phase 5: Integration Test and Documentation [NOT STARTED]

**Goal**: Verify the complete benchmark end-to-end: reload and validate all entries, confirm the benchmark is usable as a held-out evaluation set, and document the benchmark design.

**Tasks**:
- [ ] Create `scripts/verify_benchmark.py` -- independent verification script
- [ ] Reload `data/bmlogic-bench.jsonl` and verify:
  - All entries parse correctly
  - No duplicate formula_str entries
  - All IDs are sequential and unique
  - Tier distribution matches metadata
  - Valid/invalid counts match metadata
- [ ] Cross-check: no benchmark formulas appear in the production training split (check against production data hash-based split assignments)
- [ ] Run decision procedure on a random sample of 50 benchmark entries to spot-check label correctness
- [ ] Verify axiom anchor completeness: all 42 BX axiom constructors have at least one instance
- [ ] Print final benchmark summary report to stdout

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `scripts/verify_benchmark.py` (new) -- verification script

**Verification**:
- Verification script passes all checks
- No training-set contamination detected
- Random oracle spot-check confirms 100% label accuracy
- Final summary report shows all targets met

## Testing & Validation

- [ ] `lake build` succeeds with new BenchmarkAnchors module
- [ ] `lake exe benchmark_anchors` produces valid JSONL with all 42 axiom constructor coverage
- [ ] Python curation script runs end-to-end without errors
- [ ] Oracle validation confirms zero label mismatches with production data
- [ ] Final benchmark has 500-1000 formulas with ~50/50 valid/invalid balance
- [ ] Tier distribution: easy ~15-20%, medium ~40%, hard ~30-35%, very_hard ~10%
- [ ] All 42 BX axiom instances present as known-valid anchors
- [ ] No benchmark formulas leak into training split
- [ ] Independent verification script passes all checks

## Artifacts & Outputs

- `Theories/Bimodal/Automation/BenchmarkAnchors.lean` -- axiom instance generator module
- `scripts/curate_benchmark.py` -- Python curation pipeline
- `scripts/validate_benchmark.py` -- Oracle validation orchestrator
- `scripts/finalize_benchmark.py` -- Final export and metadata
- `scripts/verify_benchmark.py` -- Independent verification
- `data/axiom-instances.jsonl` -- Generated axiom instances
- `data/bmlogic-bench.jsonl` -- Final BMLogic-Bench benchmark
- `data/bmlogic-bench_metadata.json` -- Benchmark metadata and statistics

## Rollback/Contingency

All new files are additive (no existing files are modified beyond `lakefile.lean`). Rollback:
- Remove new Lean module: `rm Theories/Bimodal/Automation/BenchmarkAnchors.lean`
- Revert lakefile changes: `git checkout lakefile.lean`
- Remove generated data: `rm data/axiom-instances.jsonl data/bmlogic-bench*.jsonl data/bmlogic-bench_metadata.json`
- Remove scripts: `rm scripts/curate_benchmark.py scripts/validate_benchmark.py scripts/finalize_benchmark.py scripts/verify_benchmark.py`

If valid formula enrichment is insufficient (< 250 valid formulas after axiom generation):
- Expand substitution vocabulary to include compound formulas (box(neg(p)), U(p,F(q)), etc.)
- Mine derived theorems from `Theories/Bimodal/Theorems/` directory
- Relax valid/invalid balance target to 40/60
- Reduce benchmark size to 500 (needing ~250 valid)
