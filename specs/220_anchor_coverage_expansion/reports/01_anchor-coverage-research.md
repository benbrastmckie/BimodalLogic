# Research Report: Anchor Coverage Expansion (14/42 -> 42/42)

- **Task**: 220 - Anchor coverage expansion (14/42 -> 42/42 axiom constructors)
- **Started**: 2026-05-29T12:00:00Z
- **Completed**: 2026-05-29T13:30:00Z
- **Effort**: medium (1-2 weeks)
- **Dependencies**: None
- **Sources/Inputs**:
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- All 42 axiom constructors
  - `Theories/Bimodal/Automation/BenchmarkAnchors.lean` -- Anchor generation code
  - `Theories/Bimodal/Automation/BenchmarkOracle.lean` -- Oracle validator
  - `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` -- Decision procedure
  - `Theories/Bimodal/Automation/ProofSearch/Core.lean` -- `matchAxiom` function
  - `scripts/curate_benchmark.py` -- Curation pipeline
  - `scripts/finalize_benchmark.py` -- Finalization pipeline
  - `data/bmlogic-bench.jsonl` -- Current benchmark (727 records)
  - `data/bmlogic-bench_metadata.json` -- Current metadata
  - Live execution of `lake exe benchmark_anchors`
- **Artifacts**: [specs/220_anchor_coverage_expansion/reports/01_anchor-coverage-research.md]
- **Standards**: status-markers.md, artifact-management.md

## Executive Summary

- The benchmark_anchors executable generates 724 formula instances covering all 42 axiom constructors. The code-level coverage is 42/42 -- no new Lean code is needed for instance generation.
- The decision procedure (`decideAuto`) labels only 118 instances as valid, 543 as invalid, and 63 as timeout. All valid instances come from only 8 axiom constructors (4 propositional + 4 modal).
- The root cause is a semantic mismatch: the tableau-based decision procedure evaluates formulas on general linear orders (including single-point frames without seriality), while 29 temporal axiom constructors require serial/unbounded frames to be valid. The decision procedure correctly finds countermodels on non-serial frames.
- The `matchAxiom` function in `ProofSearch/Core.lean` only pattern-matches 13 of 42 axiom constructors, so `tryAxiomProof` cannot provide proofs for the remaining 29.
- The pipeline also loses the `axiom_name` metadata: the finalize script strips it when constructing output records, so even the 14 constructor names that reach the curation stage disappear from the final benchmark.
- Expanding anchor coverage to 42/42 requires either (a) extending `matchAxiom` to all 42 constructors AND bypassing the tableau's invalid-labeling for axiom instances, or (b) adding a separate proof path that uses `DerivationTree.axiom` directly for known axiom instances.

## Context & Scope

### Task Definition

Expand benchmark anchor coverage from 14/42 to 42/42 axiom constructors, with at least 3 instances each (target: 126+ anchor records vs current 78). The benchmark_anchors executable generates axiom instances and the pipeline labels them via the decision procedure.

### Current State

| Metric | Current | Target |
|--------|---------|--------|
| Axiom constructors with valid instances | 8 | 42 |
| Total anchor records (valid) | 67 | 126+ |
| Total anchor records (invalid) | 11 | 11 (unchanged) |
| Axiom constructors in proof traces | 8 | 42 |
| `matchAxiom` patterns | 13/42 | 42/42 |

### Benchmark Pipeline

```
BenchmarkAnchors.lean    curate_benchmark.py    BenchmarkOracle.lean    finalize_benchmark.py
  (generates 724)   -->   (stratified sample)  -->  (oracle validate)  -->  (final export)
  axiom-instances.jsonl   bench-candidates.jsonl    bench-validated.jsonl   bmlogic-bench.jsonl
```

## Findings

### Finding 1: BenchmarkAnchors Code Already Covers 42/42

The `BenchmarkAnchors.lean` module generates instances for all 42 axiom constructors organized by parameter arity:

| Arity | Constructors | Vocabulary | Instances per constructor | Total |
|-------|-------------|-----------|--------------------------|-------|
| 0 (ground) | 8 | N/A | 1 | 8 |
| 1 | 14 | `substitutionVocab` (8 terms) | 8 | 112 |
| 2 | 10 | `smallVocab` (5 terms) | 25 | 250 |
| 3 | 8 | `tinyVocab` (3 terms) | 27 | 216 |
| 4 | 2 | `tinyVocab` (3 terms) | 81 | 162 |
| **Total** | **42** | | | **748 (724 after dedup)** |

The instance count is sufficient -- every axiom constructor has at least 1 instance, and parameterized axioms have 8-81 instances. No code changes needed here.

### Finding 2: Decision Procedure Labels 34 Axioms as Invalid/Timeout

Running `lake exe benchmark_anchors` produces:

| Category | Count | Axiom constructors |
|----------|-------|-------------------|
| ALL VALID | 8 | ex_falso, prop_k, prop_s, peirce, modal_t, modal_4, modal_k_dist, modal_future |
| ALL INVALID | 24 | All temporal axioms, uniformity, discrete, serial_future/past, etc. |
| ALL TIMEOUT | 5 | modal_b, modal_5_collapse, F_until_equiv, P_since_equiv, discrete_box_necessity |
| INVALID+TIMEOUT | 5 | left_mono_until_G, left_mono_since_H, right_mono_until, right_mono_since |

**Root cause**: The decision procedure's tableau method checks satisfiability of the negated formula on GENERAL linear orders. A single-point frame (no past, no future) is a valid base linear order but lacks seriality. On such frames:
- `serial_future` (T -> F(T)) is false because there is no future point
- `connect_future` (phi -> G(P(phi))) is false because G is vacuously true but P(phi) fails at non-existent future points
- All Until/Since axioms fail because they require future/past witness points
- Uniformity axioms like `discrete_symm_fwd` (U(T,bot) -> S(T,bot)) fail because U(T,bot) itself is false

This is semantically correct: these axioms are valid on serial linear orders, not on all linear orders. The proof system classifies them as "Base" because the derivation system assumes a serial temporal order.

### Finding 3: `matchAxiom` Covers Only 13/42 Constructors

The `matchAxiom` function in `ProofSearch/Core.lean` only has pattern-match branches for:

| Matched (13) | Not Matched (29) |
|--------------|-----------------|
| ex_falso, prop_k, prop_s, peirce | all temporal axioms (22) |
| modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist | modal_future (matched) |
| connect_future | connect_past |
| prior_UZ, prior_SZ | z1, density, dense_indicator |
| modal_future | all uniformity (5) |

Even the 13 matched axioms don't all produce valid labels: `modal_b` and `modal_5_collapse` reach the tableau (which times out) rather than being caught by `tryAxiomProof`, because the proof search `bounded_search_with_proof` fails to find proofs for them within the depth limit.

### Finding 4: Pipeline Strips `axiom_name` Metadata

The `taggedToJsonl` function writes `axiom_name` both as a top-level field and inside the `augmentation` object. This metadata survives through the curation and oracle steps (the oracle passes through already-labeled records unchanged). However, `finalize_benchmark.py` (lines 218-232) constructs new record dicts with an explicit field list that omits `axiom_name`. The metadata file reports `axiom_constructors_present: 14` (computed from input records before stripping), but the final benchmark has zero `axiom_name` fields.

### Finding 5: The "14/42" Figure

The metadata's `axiom_constructors_present: 14` likely represents the number of axiom constructor names that appeared in the curation pipeline's input during the initial benchmark build. The actual count of axiom constructors with valid-and-proving instances in the final benchmark is only 8 (based on proof_trace.axioms_used analysis). The discrepancy between 8 and 14 may reflect constructors that appeared in `axiom_name` fields but whose proof traces didn't reference them (because the proof search found alternative proofs).

### Finding 6: Formula Complexity Distribution

Most temporal axiom instances have high complexity:

| Tier | Complexity | Count | Percentage |
|------|-----------|-------|-----------|
| Easy (<=3) | 1-3 | 3 | 0.4% |
| Medium (4-6) | 4-6 | 22 | 3.0% |
| Hard (7-9) | 7-9 | 52 | 7.2% |
| Very Hard (>=10) | 10+ | 647 | 89.4% |

The overwhelming majority (89%) of axiom instances are in the "very_hard" tier, which means they would disproportionately affect the benchmark's tier distribution if all were included.

## Decisions

1. **No changes to BenchmarkAnchors.lean are needed** for instance generation -- it already covers 42/42.
2. **The core blocker is the decision procedure's semantic evaluation**, not the pipeline.
3. **The solution must bypass the tableau invalidity path** for known axiom instances.

## Recommendations

### Recommendation 1 (Primary): Direct Axiom Proof Path

**Approach**: Modify the `BenchmarkAnchors.lean` labeling step to use `matchAxiom` + `DerivationTree.axiom` directly instead of `labelFormula`/`decideAuto`. Since each `TaggedFormula` already knows its axiom constructor name, the generator can construct proof terms directly without going through the decision procedure.

**Implementation sketch**:
1. Extend `matchAxiom` in `ProofSearch/Core.lean` to cover all 42 axiom constructors (currently only 13)
2. In `BenchmarkAnchors.lean` main function, try `matchAxiom` first for each `TaggedFormula`
3. If `matchAxiom` succeeds and `minFrameClass <= Base`, produce a valid-labeled record with the axiom as proof trace
4. Only fall back to `decideAuto` for instances where `matchAxiom` fails (shouldn't happen for well-formed instances)
5. For non-Base axioms (density, dense_indicator, prior_UZ, prior_SZ, z1), label them with an appropriate note (not expected to be valid on Base)

**Effort**: Medium -- requires extending 29 match patterns in `matchAxiom` and modifying the labeling logic.

**Benefit**: Directly solves the 42/42 coverage problem and produces correct proof traces.

### Recommendation 2: Preserve `axiom_name` Through Pipeline

**Approach**: Fix `finalize_benchmark.py` to include `axiom_name` in the output record construction (line 218-232).

**Implementation sketch**:
```python
# In finalize_benchmark.py, lines 218-232, add:
"axiom_name": r.get("axiom_name"),  # Preserve axiom constructor name
```

**Effort**: Trivial (one line change).

### Recommendation 3: Controlled Instance Selection for Benchmark Balance

**Approach**: To avoid overwhelming the benchmark with 724 axiom instances (89% very_hard tier), select exactly 3 instances per axiom constructor, preferring lower complexity.

**Implementation sketch**:
1. In `BenchmarkAnchors.lean`, after `generateAllInstances`, group by axiom name
2. For each axiom constructor, sort instances by formula complexity (ascending)
3. Select top-3 (lowest complexity) instances per constructor
4. This produces exactly 126 anchor records (42 constructors x 3 instances)
5. The benchmark grows from 727 to ~800-850 records (within the 800-900 target)

**Effort**: Small -- add selection logic in the Lean module.

### Recommendation 4: Tier-Aware Selection for Non-Base Axioms

**Approach**: For the 5 non-Base axiom constructors (density, dense_indicator, prior_UZ, prior_SZ, z1), include instances as anchor-invalid records rather than attempting to prove them valid on the Base frame. This is semantically correct and adds valuable negative examples.

**Implementation sketch**:
1. Tag non-Base axiom instances with `benchmark_category: "anchor-invalid-nonbase"`
2. Include them in the anchor pool but don't expect validity
3. This adds ~15 records (5 constructors x 3 instances) to the anchor-invalid count

**Effort**: Small.

## Risks & Mitigations

### Risk 1: `matchAxiom` Extension Complexity

**Risk**: Adding 29 new pattern-match branches to `matchAxiom` is non-trivial and may introduce matching bugs.

**Mitigation**: Each new branch can be verified by checking that `matchAxiom(axiom_instance_formula)` returns the expected `Axiom` constructor. The `BenchmarkAnchors.lean` instances serve as a test suite.

### Risk 2: Decision Procedure False Invalidity

**Risk**: The decision procedure produces countermodels for valid temporal axioms (on serial frames). If the anchor expansion bypasses the decision procedure for axiom instances, these records will have proof traces from axiom matching rather than the decision procedure.

**Mitigation**: This is acceptable because axiom instances ARE provable by definition -- they are instances of axiom schemata in the proof system. The proof trace `axioms_used: ["serial_future"]` is more informative than a countermodel for a known-valid axiom.

### Risk 3: Benchmark Size Growth

**Risk**: Adding 126 anchor records to 727 could push the benchmark to ~850. The task target is 800-900.

**Mitigation**: Remove some existing anchor-valid records that are redundant (e.g., reduce from 20 peirce instances to 3). Net growth can be controlled to stay within target.

### Risk 4: Regression in Existing Labels

**Risk**: Regenerating the benchmark could change labels for existing records.

**Mitigation**: The finalize script uses deterministic random seeds (RANDOM_SEED = 42205). Existing records should be preserved if the pipeline is re-run. Add a regression test that verifies no existing record label changes.

## Appendix

### A. All 42 Axiom Constructors by Layer

| Layer | Constructor | Params | Frame Class | Current Status |
|-------|-------------|--------|-------------|---------------|
| 1 Propositional | prop_k | 3 | Base | VALID (27 instances) |
| 1 Propositional | prop_s | 2 | Base | VALID (25 instances) |
| 1 Propositional | ex_falso | 1 | Base | VALID (8 instances) |
| 1 Propositional | peirce | 2 | Base | VALID (25 instances) |
| 2 S5 Modal | modal_t | 1 | Base | VALID (8 instances) |
| 2 S5 Modal | modal_4 | 1 | Base | VALID (8 instances) |
| 2 S5 Modal | modal_b | 1 | Base | TIMEOUT (8 instances) |
| 2 S5 Modal | modal_5_collapse | 1 | Base | TIMEOUT (8 instances) |
| 2 S5 Modal | modal_k_dist | 2 | Base | VALID (9 instances) |
| 3 BX Temporal | serial_future | 0 | Base | INVALID (1 instance) |
| 3 BX Temporal | serial_past | 0 | Base | INVALID (1 instance) |
| 3 BX Temporal | left_mono_until_G | 3 | Base | INVALID+TIMEOUT |
| 3 BX Temporal | left_mono_since_H | 3 | Base | INVALID+TIMEOUT |
| 3 BX Temporal | right_mono_until | 3 | Base | INVALID+TIMEOUT |
| 3 BX Temporal | right_mono_since | 3 | Base | INVALID+TIMEOUT |
| 3 BX Temporal | connect_future | 1 | Base | INVALID (8 instances) |
| 3 BX Temporal | connect_past | 1 | Base | INVALID (8 instances) |
| 3 BX Temporal | enrichment_until | 3 | Base | INVALID (27 instances) |
| 3 BX Temporal | enrichment_since | 3 | Base | INVALID (27 instances) |
| 3 BX Temporal | self_accum_until | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | self_accum_since | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | absorb_until | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | absorb_since | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | linear_until | 4 | Base | INVALID (81 instances) |
| 3 BX Temporal | linear_since | 4 | Base | INVALID (81 instances) |
| 3 BX Temporal | until_F | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | since_P | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | temp_linearity | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | temp_linearity_past | 2 | Base | INVALID (25 instances) |
| 3 BX Temporal | F_until_equiv | 1 | Base | TIMEOUT (8 instances) |
| 3 BX Temporal | P_since_equiv | 1 | Base | TIMEOUT (8 instances) |
| 4 Interaction | modal_future | 1 | Base | VALID (8 instances) |
| 5 Uniformity | discrete_symm_fwd | 0 | Base | INVALID (1 instance) |
| 5 Uniformity | discrete_symm_bwd | 0 | Base | INVALID (1 instance) |
| 5 Uniformity | discrete_propagate_fwd | 0 | Base | INVALID (1 instance) |
| 5 Uniformity | discrete_propagate_bwd | 0 | Base | INVALID (1 instance) |
| 5 Uniformity | discrete_box_necessity | 0 | Base | TIMEOUT (1 instance) |
| 6 Prior | prior_UZ | 1 | Discrete | INVALID (8 instances) |
| 6 Prior | prior_SZ | 1 | Discrete | INVALID (8 instances) |
| 7 Z1 | z1 | 1 | Discrete | INVALID (8 instances) |
| 8 Density | density | 1 | Dense | INVALID (8 instances) |
| 8 Density | dense_indicator | 0 | Dense | INVALID (1 instance) |

### B. Pipeline Data Flow

```
BenchmarkAnchors.lean
  |-- generateAllInstances -> 724 TaggedFormula
  |-- labelFormula (decideAuto) for each
  |     |-- tryAxiomProof (matchAxiom) -> matches 13/42 patterns
  |     |-- bounded_search_with_proof -> finds proofs for 8/42
  |     |-- buildTableau -> finds countermodels for temporal/serial axioms
  |     '-- Result: 118 valid, 543 invalid, 63 timeout
  '-- taggedToJsonl writes axiom_name to both top-level and augmentation
        -> axiom-instances.jsonl (724 records)

curate_benchmark.py
  |-- Loads axiom-instances.jsonl
  |-- Step 7: adds ALL valid axiom instances as mandatory anchors
  '-- Outputs bench-candidates.jsonl (preserves axiom_name)

BenchmarkOracle.lean
  |-- Passes through already-labeled records unchanged
  '-- Outputs bench-validated.jsonl (preserves axiom_name)

finalize_benchmark.py
  |-- Step 7: checks axiom_name for coverage tracking -> 14/42
  |-- Lines 218-232: constructs NEW record dict WITHOUT axiom_name
  '-- Outputs bmlogic-bench.jsonl (axiom_name STRIPPED)
```

### C. Key Files for Implementation

| File | Role | Changes Needed |
|------|------|---------------|
| `Theories/Bimodal/Automation/ProofSearch/Core.lean` | `matchAxiom` function | Add 29 missing axiom patterns |
| `Theories/Bimodal/Automation/BenchmarkAnchors.lean` | Instance generation + labeling | Use matchAxiom directly instead of decideAuto for axiom instances; add top-3 selection |
| `scripts/finalize_benchmark.py` | Final export | Preserve axiom_name field in output records |
| `scripts/curate_benchmark.py` | Curation | May need updates to handle new anchor count |
| `data/bmlogic-bench_metadata.json` | Metadata | Regenerated automatically |
