# Research Report: BMLogic-Bench Benchmark Curation

**Task**: 205 -- Curate stratified evaluation benchmark (BMLogic-Bench)
**Session**: sess_1780086634_1d476d
**Date**: 2026-05-29

## Executive Summary

This report analyzes the existing dataset infrastructure and production data to design BMLogic-Bench, a stratified evaluation benchmark for decidable bimodal logic. The key challenge is severe class imbalance: only 3.7% of the 59K combined production records are valid (theorems), with the remaining 96.3% invalid or timed out. Achieving the target 50/50 valid/invalid balance requires significant enrichment of the valid pool through axiom instance generation and formula mutation. The report recommends a Python-based curation pipeline operating on the existing JSONL files, with Lean-side oracle validation of all ground-truth labels.

## 1. Production Dataset Analysis

### 1.1 Available Data

Two production JSONL files from task 204:

| Dataset | Records | Valid | Invalid | Timeout | Valid% |
|---------|---------|-------|---------|---------|--------|
| `data/bmlogic-medium.jsonl` | 5,136 | 1,284 | 3,686 | 166 | 25.0% |
| `data/bmlogic-deep.jsonl` | 53,979 | 888 | 51,730 | 1,361 | 1.6% |
| **Combined** | **59,115** | **2,172** | **55,416** | **1,527** | **3.7%** |

### 1.2 Record Schema

Each JSONL record contains:
- `id`: Unique identifier (e.g., "bmlogic-00001")
- `split`: train/val/test (deterministic hash-based)
- `formula_str`: Human-readable formula string
- `formula_ast`: JSON AST representation (recursive tagged tree)
- `frame_class`: "Base" (all production data uses Base)
- `label`: "valid" / "invalid" / "timeout"
- `proof_trace`: `{height, axioms_used, rules_applied}` or null
- `countermodel`: `{trueAtoms, falseAtoms, formula}` or null
- `pattern_key`: `{modalDepth, temporalDepth, impCount, complexity, topOperator}`
- `metrics`: `{complexity, modalDepth, temporalDepth, impCount, atomCount, decisionTimeMs, difficultyTier}`
- `augmentation`: null (no augmented records in production data)

### 1.3 Difficulty Tier Distribution (Non-Timeout)

| Tier | Valid | Invalid | Total | Valid% |
|------|-------|---------|-------|--------|
| easy (complexity <= 3) | 0 | 72 | 72 | 0.0% |
| medium (complexity 4-6) | 365 | 7,840 | 8,205 | 4.4% |
| hard (complexity 7-9) | 1,793 | 44,897 | 46,690 | 3.8% |
| very_hard (complexity >= 10) | 14 | 2,607 | 2,621 | 0.5% |

### 1.4 Valid Formula Analysis

Of 2,172 valid formulas:
- **2,026 (93.3%)** are ex_falso instances: formulas of the form `(bot -> phi)` (trivially valid)
- **125 (5.8%)** are prop_s instances: formulas of the form `p -> (psi -> p)` (weakening)
- **17 (0.8%)** are modal_t instances: `box(phi) -> phi`
- **4 (0.2%)** are modal_4 instances: `box(phi) -> box(box(phi))`

All valid formulas have proof height 0 (single axiom application, no inference rules). This means the production dataset contains only trivially provable formulas -- no formulas requiring multi-step proofs or involving temporal axioms.

### 1.5 Top Operator Distribution

| Top Operator | Count |
|--------------|-------|
| Implication | 19,550 |
| Until | 14,542 |
| Since | 14,542 |
| Box | 10,481 |

## 2. BX Axiom System Analysis

### 2.1 All 42 Axiom Constructors

The axiom system is organized into 8 layers:

**Layer 1 -- Propositional (4)**: prop_k, prop_s, ex_falso, peirce

**Layer 2 -- S5 Modal (5)**: modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist

**Layer 3 -- BX Temporal (20)**: serial_future, serial_past, left_mono_until_G, left_mono_since_H, right_mono_until, right_mono_since, connect_future, connect_past, enrichment_until, enrichment_since, self_accum_until, self_accum_since, absorb_until, absorb_since, linear_until, linear_since, until_F, since_P, temp_linearity, temp_linearity_past, F_until_equiv, P_since_equiv

**Layer 4 -- Modal-Temporal Interaction (1)**: modal_future

**Layer 5 -- Uniformity (5)**: discrete_symm_fwd, discrete_symm_bwd, discrete_propagate_fwd, discrete_propagate_bwd, discrete_box_necessity

**Layer 6 -- Prior (2)**: prior_UZ, prior_SZ

**Layer 7 -- Z1 (1)**: z1

**Layer 8 -- Density (2)**: density, dense_indicator

### 2.2 Axiom Parameterization

Axioms fall into three categories by parameter count:

- **Ground axioms (11)**: serial_future, serial_past, discrete_symm_fwd, discrete_symm_bwd, discrete_propagate_fwd, discrete_propagate_bwd, discrete_box_necessity, dense_indicator -- these produce exactly one formula each.
- **1-parameter schema (12)**: ex_falso, modal_t, modal_4, modal_b, modal_5_collapse, connect_future, connect_past, modal_future, prior_UZ, prior_SZ, z1, density, F_until_equiv, P_since_equiv
- **2-parameter schema (8)**: prop_s, peirce, self_accum_until, self_accum_since, absorb_until, absorb_since, until_F, since_P, temp_linearity, temp_linearity_past
- **3-parameter schema (11)**: prop_k, modal_k_dist, left_mono_until_G, left_mono_since_H, right_mono_until, right_mono_since, enrichment_until, enrichment_since
- **4-parameter schema (2)**: linear_until, linear_since

For known-valid anchors, we need specific formula instances of each schema. The ground axioms give us 11 formulas directly. For parameterized axioms, instantiating with atoms p, q, r gives us concrete valid formulas.

### 2.3 Existing Anchor Lists

`DatasetValidator.lean` already defines:
- `knownValidFormulas`: 10 concrete axiom instances (prop_k, prop_s, ex_falso, peirce, modal_t, modal_4, modal_k_dist, modal_future, plus duplicates)
- `knownInvalidFormulas`: 20 known non-theorems (bare atoms, unsatisfiable formulas, non-tautological implications)

These can be expanded significantly for the benchmark.

## 3. Decision Procedure Oracle

### 3.1 Architecture

The decision procedure in `Metalogic/Decidability/` provides:

- `DecisionResult`: Sum type of `.valid proof`, `.invalid countermodel`, or `.timeout`
- `decideAuto`: Automatic fuel-based decision (primary)
- `decideOptimized`: IDDFS + full tableau fallback (retry for timeouts)
- `labelFormula`: IO wrapper that measures wall-clock time and computes metrics

### 3.2 Validation Capability

The oracle can validate any formula's ground-truth label:
- Valid formulas produce a `DerivationTree` proof term
- Invalid formulas produce a `SimpleCountermodel`
- Timeout means insufficient fuel (could be valid or invalid)

For benchmark validation, all 500-1K entries must have definitive valid/invalid labels -- no timeouts allowed. This requires either using formulas already labeled (from the production data) or running the decision procedure with sufficient fuel.

### 3.3 Frame Class Consideration

The production data uses `FrameClass.Base` only. The axiom system includes Dense-only (2 axioms) and Discrete-only (3 axioms + 5 uniformity). A complete benchmark should note that all formulas are evaluated under Base semantics, meaning:
- All 37 base axioms are valid
- Dense axioms (density, dense_indicator) are NOT required to be valid under Base
- Discrete axioms (prior_UZ, prior_SZ, z1) are NOT required to be valid under Base

However, the 5 uniformity axioms (discrete_symm_fwd, etc.) are actually valid on all ordered abelian groups -- their frame class in the code is Base.

## 4. Benchmark Design: BMLogic-Bench

### 4.1 Target Specification

| Parameter | Target |
|-----------|--------|
| Total size | 500-1,000 formulas |
| Valid/Invalid split | ~50/50 |
| Difficulty: easy | 20% |
| Difficulty: medium | 40% |
| Difficulty: hard | 30% |
| Difficulty: very_hard | 10% |
| Known-valid anchors | All 42 BX axiom instances |
| Known-invalid anchors | 20+ non-theorems |
| Near-miss formulas | Single-operator mutations of valid formulas |

### 4.2 The Valid Formula Shortage Problem

**Critical Issue**: The production dataset contains only 2,172 valid formulas, and most (93%) are trivial ex_falso instances. To achieve 50/50 balance in a 1,000-formula benchmark requires ~500 valid formulas.

Available valid formulas by substantive content:
- Ex falso (bot -> phi): 2,026 -- trivially valid, low difficulty
- Prop_s (weakening): 125 -- trivially valid
- Modal_t (box phi -> phi): 17 -- simple modal
- Modal_4 (box phi -> box box phi): 4 -- simple modal
- **Total non-trivial valid**: ~146

**This is insufficient for a balanced benchmark.** Enrichment strategies are required.

### 4.3 Valid Formula Enrichment Strategies

#### Strategy A: Axiom Instance Generation (Lean-side)

Generate concrete instances of all 42 axiom schemata by substituting atoms and small formulas:
- For each schema, instantiate with p, q, r, box(p), F(p), U(p,q), etc.
- Ground axioms yield 11 fixed formulas
- 1-param schemata with 5 substitutions = 60 formulas
- 2-param with 5x5 = 200 formulas
- 3-param with 5x5x5 = 1,375 formulas (sample subset)
- 4-param with 5^4 = 625 formulas (sample subset)

Estimated yield: ~500-2,000 valid formulas with guaranteed correctness. This requires a new Lean module that generates `Formula` values from the `Axiom` constructors.

#### Strategy B: Near-Miss Mutation (Python-side)

For each valid formula in the production data:
1. Parse the `formula_ast` JSON
2. Apply single-operator mutations:
   - Replace `imp` with `untl` or `snce`
   - Replace `box` with negation of box
   - Swap left/right children of binary operators
   - Replace an atom with `bot` or a different atom
3. Label the mutated formula via the Lean oracle
4. Most mutations of valid formulas should produce invalid formulas (near-misses)
5. Some mutations may produce other valid formulas

This generates hard negatives that test whether a model understands the fine structure of validity.

#### Strategy C: Derived Theorem Mining

The `Theorems/` directory contains derived theorems:
- `Perpetuity.lean`: Bridge principles, helpers, derived temporal facts
- `ModalS5.lean`: S5-specific derived theorems
- `ModalS4.lean`: S4 sub-logic facts
- `Combinators.lean`: Combinator-style derived facts
- `TemporalDerived.lean`: Derived temporal axioms (temp_k_dist, temp_4)
- `Propositional/`: Core, Connectives, Reasoning

These provide additional known-valid formulas with non-trivial proof structure.

### 4.4 Recommended Approach: Hybrid Pipeline

Given the constraints, the benchmark curation should use a **Python-based curation pipeline** with **Lean-side oracle validation**:

**Phase 1: Pool Construction (Python)**
1. Load both production JSONL files
2. Filter out timeouts
3. Deduplicate by `formula_str`
4. Separate into valid and invalid pools

**Phase 2: Valid Formula Enrichment (Lean + Python)**
1. Create `BenchmarkAnchors.lean` module that generates all 42 axiom instances with small substitutions
2. Run `lake exe benchmark_anchors` to produce `data/axiom-instances.jsonl`
3. Generate near-miss mutations in Python from valid formulas
4. Label mutations via `lake exe dataset_generator` or a new oracle executable
5. Merge all valid formulas into enriched valid pool

**Phase 3: Stratified Sampling (Python)**
1. Assign difficulty tiers using the existing `difficultyTier` classification
2. Sample from valid and invalid pools per tier quotas:
   - Easy (20%): 100 valid + 100 invalid
   - Medium (40%): 200 valid + 200 invalid
   - Hard (30%): 150 valid + 150 invalid
   - Very Hard (10%): 50 valid + 50 invalid
3. Include all 42 axiom anchor instances (in appropriate tiers)
4. Include 20+ known-invalid anchors
5. Include near-miss mutations

**Phase 4: Validation (Lean)**
1. Run the decision procedure on every benchmark formula
2. Verify all labels are correct (no timeouts)
3. Verify countermodels exist for all invalid formulas
4. Verify proof traces exist for all valid formulas

**Phase 5: Export**
1. Write `data/bmlogic-bench.jsonl` with same schema as production data
2. Write `data/bmlogic-bench_metadata.json` with benchmark statistics
3. Include benchmark manifest with tier/anchor/near-miss annotations

### 4.5 Implementation Language Decision

**Recommendation: Python for curation, Lean for enrichment and validation.**

Rationale:
- The production data is already in JSONL format, which Python handles natively
- Stratified sampling, mutation, and statistical analysis are straightforward in Python
- The decision procedure oracle and axiom instance generation must run in Lean
- A pure-Lean approach would require building JSONL parsing, statistical sampling, and mutation logic from scratch with no benefit

The Lean components needed:
1. **BenchmarkAnchors.lean**: Module that generates axiom instances and exports them
2. **Oracle executable**: A thin wrapper around `labelFormula` that reads formula strings from stdin and outputs labels (or extend the existing `dataset_generator`)

The Python components needed:
1. **Curation script** (`scripts/curate_benchmark.py`): Stratified sampling, near-miss mutation, pool construction
2. **Validation orchestrator**: Calls the Lean oracle on all benchmark entries

## 5. Near-Miss Formula Design

### 5.1 Mutation Operators

For a formula AST node, define these single-step mutations:

| Mutation | Description | Example |
|----------|-------------|---------|
| `swap_args` | Swap children of binary operator | `imp(p,q)` -> `imp(q,p)` |
| `swap_op` | Replace operator with related one | `untl(p,q)` -> `snce(p,q)` |
| `negate` | Negate a subformula | `box(p)` -> `box(neg(p))` |
| `drop_box` | Remove a box operator | `box(p)` -> `p` |
| `add_box` | Add a box operator | `p` -> `box(p)` |
| `atom_swap` | Replace one atom with another | `p` -> `q` |
| `bot_inject` | Replace a subformula with bot | `p` -> `bot` |
| `weaken_guard` | Change temporal guard | `untl(p,q)` -> `untl(p,bot)` |

### 5.2 Expected Near-Miss Yield

Starting from ~146 non-trivial valid formulas, with ~8 mutations each:
- ~1,168 candidate near-miss formulas
- Expected ~85-95% invalid (near-misses)
- Expected ~5-15% still valid (structural redundancy)

After oracle validation, this gives ~1,000-1,100 near-miss formulas, of which ~950-1,050 are hard negatives.

## 6. Difficulty Tier Calibration

### 6.1 Current Tier Boundaries

From `DatasetGenerator.lean`:
```
easy:      complexity <= 3
medium:    complexity 4-6
hard:      complexity 7-9
very_hard: complexity >= 10
```

### 6.2 Tier Availability in Production Data

| Tier | Non-Timeout Records | Valid | Invalid |
|------|---------------------|-------|---------|
| easy | 72 | 0 | 72 |
| medium | 8,205 | 365 | 7,840 |
| hard | 46,690 | 1,793 | 44,897 |
| very_hard | 2,621 | 14 | 2,607 |

**Problem**: The easy tier has zero valid formulas, and very_hard has only 14. Both tiers need enrichment.

### 6.3 Enrichment Plan Per Tier

**Easy tier** (target: 200 formulas, 100 valid + 100 invalid):
- Valid: Generate from simple axiom instances (complexity <= 3). Ground axioms have complexity 3-7, so only the simplest ones qualify. Prop axiom instances with single atoms qualify: `ex_falso(p)` has complexity 3, `prop_s(p,q)` has complexity 5 (medium). Need to generate axiom instances at complexity <= 3 specifically, or adjust the easy tier definition.
- Invalid: 72 available, need 28 more. Generate by mutating simple valid formulas.

**Medium tier** (target: 400 formulas):
- Valid: 365 available, sufficient. Sample ~200.
- Invalid: 7,840 available, ample. Sample ~200.

**Hard tier** (target: 300 formulas):
- Valid: 1,793 available but mostly ex_falso. After filtering ex_falso, ~50 non-trivial valid. Need enrichment from axiom instances at complexity 7-9.
- Invalid: 44,897 available. Sample ~150 with diversity.

**Very_hard tier** (target: 100 formulas):
- Valid: Only 14 available. Need significant enrichment from complex axiom instances.
- Invalid: 2,607 available. Sample ~50.

### 6.4 Recommended Tier Adjustment

Given the severe shortage of valid formulas at the extremes, consider adjusting the tier targets:

| Tier | Adjusted Target | Valid | Invalid |
|------|----------------|-------|---------|
| easy | 15% (150) | 75 | 75 |
| medium | 40% (400) | 200 | 200 |
| hard | 35% (350) | 175 | 175 |
| very_hard | 10% (100) | 50 | 50 |

This gives a 1,000-formula benchmark with exact 50/50 balance.

## 7. Key Findings and Recommendations

### 7.1 Findings

1. **The production dataset is heavily imbalanced** (3.7% valid) and valid formulas are almost entirely trivial (93% are ex_falso instances). The benchmark CANNOT be built from production data alone.

2. **Axiom instance generation is essential** for producing substantive valid formulas. A new Lean module `BenchmarkAnchors.lean` should generate instances of all 42 axiom schemata with varied substitutions.

3. **Near-miss mutation is the key innovation** for BMLogic-Bench. Single-operator mutations of valid formulas create hard negatives that test structural understanding of validity.

4. **Oracle validation is mandatory** for all benchmark entries. The existing `DecisionProcedure` with `decideOptimized` (IDDFS + full tableau) should handle all benchmark formulas since they are bounded complexity.

5. **The easy tier needs special attention** since the production data has zero valid formulas at complexity <= 3. Ground axioms and very simple schema instances must fill this gap.

6. **All proof traces in the production data have height 0** (single axiom application), indicating the decision procedure finds only shallow proofs. Multi-step proofs would require higher complexity or more complex formula patterns.

### 7.2 Recommended Implementation Plan

**Phase 1**: Create `BenchmarkAnchors.lean` -- Generate axiom instances with atom substitutions, export as JSONL
**Phase 2**: Create `scripts/curate_benchmark.py` -- Pool construction, stratified sampling, near-miss mutation
**Phase 3**: Create oracle validation wrapper -- Validate all benchmark labels via decision procedure
**Phase 4**: Export and document -- Write `data/bmlogic-bench.jsonl` with metadata and manifest
**Phase 5**: Integration test -- Verify benchmark loads correctly, all labels are correct, tier distribution matches targets

### 7.3 Code Locations

| Component | Location |
|-----------|----------|
| Dataset records | `Theories/Bimodal/Automation/DatasetExport.lean` |
| Decision procedure | `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` |
| Formula enumeration | `Theories/Bimodal/Automation/FormulaEnumerator.lean` |
| Dataset generator | `Theories/Bimodal/Automation/DatasetGenerator.lean` |
| Existing anchors | `Theories/Bimodal/Automation/DatasetValidator.lean` |
| Axiom definitions | `Theories/Bimodal/ProofSystem/Axioms.lean` |
| Formula syntax | `Theories/Bimodal/Syntax/Formula.lean` |
| Production data | `data/bmlogic-medium.jsonl`, `data/bmlogic-deep.jsonl` |
| Generation script | `scripts/run_dataset_generation.sh` |
| Lakefile executables | `lakefile.lean` (dataset_generator, dataset_validator) |

### 7.4 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Insufficient valid formulas after enrichment | Medium | High | Increase axiom substitution vocabulary; add derived theorem formulas |
| Oracle timeout on complex formulas | Low | Medium | Use `decideOptimized` with generous fuel; exclude persistent timeouts |
| Near-miss mutations all trivially invalid | Low | Medium | Design mutations that are structurally close; verify with oracle |
| Easy tier empty for valid | High | Medium | Adjust tier boundaries or generate very simple axiom instances |
| Duplicate formulas across tiers | Low | Low | Deduplicate by formula_str before final export |
