# Implementation Plan: Anchor Coverage Expansion (14/42 to 42/42)

- **Task**: 220 - Anchor coverage expansion (14/42 -> 42/42 axiom constructors)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: specs/220_anchor_coverage_expansion/reports/01_anchor-coverage-research.md
- **Artifacts**: plans/01_anchor-coverage-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The benchmark_anchors executable already generates 724 formula instances covering all 42 BX axiom constructors, but only 8 constructors produce valid-labeled instances because the tableau-based decision procedure (`decideAuto`) evaluates on general linear orders (including non-serial frames) where temporal axioms are semantically invalid. The `matchAxiom` function in `ProofSearch/Core.lean` covers only 13 of 42 axiom patterns, and the finalize script strips the `axiom_name` field from output records. This plan extends `matchAxiom` to all 42 constructors, modifies the anchor labeling to use direct axiom proofs instead of the tableau decision procedure, adds top-3-per-constructor selection for benchmark balance, and preserves `axiom_name` through the pipeline. Done when `lake exe benchmark_anchors` produces 126+ anchor records covering 42/42 constructors, the finalize script retains `axiom_name`, and no existing benchmark record labels regress.

### Research Integration

Key findings from `01_anchor-coverage-research.md`:
- All 42 constructors already have instance generation code (Finding 1)
- Decision procedure correctly finds countermodels on non-serial frames for temporal axioms (Finding 2)
- `matchAxiom` has 13 patterns; 29 are missing (Finding 3)
- `finalize_benchmark.py` lines 218-232 construct output dicts without `axiom_name` (Finding 4)
- Recommended approach: extend `matchAxiom`, bypass `decideAuto` for axiom instances, select top-3 by complexity (Recommendations 1-3)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This plan advances the benchmark infrastructure supporting BX completeness verification. The ROADMAP.md does not have a specific checkbox for anchor coverage, but it supports the overall verification audit (Phase 5) and benchmark quality goals.

## Goals & Non-Goals

**Goals**:
- Extend `matchAxiom` to pattern-match all 42 axiom constructors
- Label axiom instances via direct axiom proof (`DerivationTree.axiom`) instead of `decideAuto`
- Select top-3 lowest-complexity instances per constructor (126 anchor records)
- Preserve `axiom_name` field through finalize pipeline
- No regression in existing benchmark record labels

**Non-Goals**:
- Modifying the decision procedure itself (the tableau is correct for its purpose)
- Changing non-anchor records in the benchmark
- Proving soundness of new axiom patterns (they are instances of defined axiom schemata)
- Changing the `curate_benchmark.py` script beyond what is needed for anchor count

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `matchAxiom` pattern-matching bugs for complex temporal axioms | H | M | Each new branch verified by running `lake exe benchmark_anchors` and checking match count per constructor |
| Benchmark size exceeds 900 target | M | L | Top-3 selection controls to exactly 126 anchors; reduce existing redundant anchors if needed |
| Regression in existing benchmark labels | H | L | Use deterministic seed (RANDOM_SEED = 42205); compare pre/post benchmark for label changes |
| `enrichment_until`/`enrichment_since` formula structure is complex to pattern-match | M | M | Research report provides exact formula structures from `BenchmarkAnchors.lean` for reference |
| Non-Base axiom instances (density, prior_UZ, etc.) labeled incorrectly | M | L | Tag non-Base axioms as `anchor-invalid-nonbase` with frame class annotation |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Extend matchAxiom to All 42 Constructors [COMPLETED]

**Goal**: Add the 29 missing pattern-match branches to `matchAxiom` in `ProofSearch/Core.lean` so it recognizes all 42 axiom constructor formulas.

**Tasks**:
- [x] Add ground axiom patterns (0-param): `serial_future`, `serial_past`, `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity`, `dense_indicator` *(completed)*
- [x] Add 1-param temporal patterns: `connect_past`, `F_until_equiv`, `P_since_equiv`, `z1`, `density` *(completed)*
- [x] Add 2-param temporal patterns: `self_accum_until`, `self_accum_since`, `absorb_until`, `absorb_since`, `until_F`, `since_P`, `temp_linearity`, `temp_linearity_past` *(completed)*
- [x] Add 3-param temporal patterns: `left_mono_until_G`, `left_mono_since_H`, `right_mono_until`, `right_mono_since`, `enrichment_until`, `enrichment_since` *(completed)*
- [x] Add 4-param patterns: `linear_until`, `linear_since` *(completed)*
- [x] Verify with `lake build Bimodal.Automation.ProofSearch.Core` that all patterns compile *(completed)*
- [x] **Bonus**: Fixed 5 broken existing patterns (`modal_b`, `modal_5_collapse`, `connect_future`, `prior_UZ`, `prior_SZ`) that used inconsistent half-expanded formula forms *(deviation: altered -- existing patterns were buggy, fixed as part of extension)*
- [x] **Bonus**: Refactored `matches_axiom` to delegate to `matchAxiom` for consistency *(deviation: altered -- eliminated duplicated pattern logic)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch/Core.lean` - Add 29 match branches to `matchAxiom` (approx lines 396-517), expanding the `<|>` chain with patterns derived from the formula structures in `BenchmarkAnchors.lean` and `Axioms.lean`

**Verification**:
- `lake build Bimodal.Automation.ProofSearch.Core` succeeds without errors
- Each new branch returns the correct `Axiom` constructor for the corresponding formula pattern

**Implementation Notes**:

The formula patterns must match the concrete AST structures. Key formula abbreviations to handle:
- `Formula.some_future φ = (φ.neg.all_future).neg` = `.imp (.all_future (.imp φ .bot)) .bot`
- `Formula.some_past φ = (φ.neg.all_past).neg` = `.imp (.all_past (.imp φ .bot)) .bot`
- `Formula.diamond φ = (φ.neg.box).neg` = `.imp (.box (.imp φ .bot)) .bot`
- `Formula.neg φ = φ.imp .bot`
- `Formula.top = .bot.imp .bot`
- `Formula.and φ ψ` = `(φ.imp (ψ.imp .bot)).imp .bot` (negation of implication chain)
- `Formula.or φ ψ` = `φ.neg.imp ψ` = `(.imp φ .bot).imp ψ`
- `Formula.untl φ ψ` = `.untl φ ψ` (primitive)
- `Formula.snce φ ψ` = `.snce φ ψ` (primitive)

For ground axioms without parameters (e.g., `serial_future`), add a direct match on the fixed formula structure before the `.imp lhs rhs` case, or within a special top-level match case.

---

### Phase 2: Modify BenchmarkAnchors Labeling to Use Direct Axiom Proofs [NOT STARTED]

**Goal**: Change the `BenchmarkAnchors.lean` main function to use `matchAxiom` for axiom instances instead of `decideAuto`, and add top-3 per-constructor selection to produce exactly 126 anchor records.

**Tasks**:
- [ ] Add a function `labelViaAxiomMatch` that takes a `TaggedFormula`, calls `matchAxiom` on its formula, and produces a `LabeledFormula` with label `.valid` and proof trace referencing the matched axiom constructor (for Base-class axioms) or label `.invalid` with a note (for non-Base axioms like density/prior_UZ/z1)
- [ ] Modify the `main` function to try `labelViaAxiomMatch` first for each `TaggedFormula`, falling back to `labelFormula`/`decideAuto` only when `matchAxiom` returns `none`
- [ ] Add a `selectTopInstances` function that groups instances by `axiomName`, sorts each group by `formula.complexity` ascending, and takes the top 3 per constructor
- [ ] Integrate `selectTopInstances` into the main pipeline after `generateAllInstances` and before labeling, reducing the pool from 724 to 126 instances
- [ ] Handle frame class correctly: Base axioms (37 constructors) get label `.valid`; Discrete-only axioms (prior_UZ, prior_SZ, z1) and Dense-only axioms (density, dense_indicator) get a distinct category label
- [ ] Verify with `lake build Bimodal.Automation.BenchmarkAnchors` that all changes compile

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/BenchmarkAnchors.lean` - Add `labelViaAxiomMatch`, `selectTopInstances` functions; modify `main` labeling loop and pipeline flow

**Verification**:
- `lake build Bimodal.Automation.BenchmarkAnchors` succeeds
- Running `lake exe benchmark_anchors` produces exactly 126 records (42 constructors x 3 instances)
- All 37 Base axiom constructors produce valid-labeled instances
- Non-Base axiom constructors produce appropriately categorized records
- Output JSONL contains `axiom_name` for all records

---

### Phase 3: Preserve axiom_name in Finalize Pipeline [NOT STARTED]

**Goal**: Fix `finalize_benchmark.py` to include `axiom_name` in output records and update `curate_benchmark.py` if needed for the new anchor count.

**Tasks**:
- [ ] Add `"axiom_name": r.get("axiom_name")` to the final record dict construction in `finalize_benchmark.py` (line 218-232)
- [ ] Also preserve the `augmentation` field (or at least the `axiom_name` within it) so downstream tools can access the axiom constructor metadata
- [ ] Review `curate_benchmark.py` to ensure it handles the increased number of valid anchor records (126 vs 78) without issues in the stratified sampling step
- [ ] If curate script has a cap on anchor-valid records, adjust it to accommodate 126
- [ ] Add `axiom_constructors_present` verification to the metadata generation to confirm 42/42

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `scripts/finalize_benchmark.py` - Add `axiom_name` to output record dict (lines 218-232); verify metadata generation
- `scripts/curate_benchmark.py` - Review and adjust anchor handling if needed for 126 records

**Verification**:
- Running the full pipeline (`lake exe benchmark_anchors` -> `curate_benchmark.py` -> `finalize_benchmark.py`) produces a benchmark with `axiom_name` fields present in axiom-sourced records
- Metadata reports `axiom_constructors_present: 42`
- No existing record labels change (regression check)

---

### Phase 4: Regenerate Benchmark and Validate [NOT STARTED]

**Goal**: Run the full benchmark pipeline end-to-end, verify 42/42 coverage, validate no regressions, and update metadata.

**Tasks**:
- [ ] Save a copy of the current `data/bmlogic-bench.jsonl` for regression comparison
- [ ] Run `lake exe benchmark_anchors` to generate the new anchor instances
- [ ] Run `python scripts/curate_benchmark.py` to curate the benchmark with new anchors
- [ ] Run `lake exe benchmark_oracle` to validate (if applicable for new anchor records)
- [ ] Run `python scripts/finalize_benchmark.py` to produce final benchmark
- [ ] Verify the final benchmark has 42/42 `axiom_name` coverage via metadata
- [ ] Verify total benchmark size is within 800-900 records
- [ ] Perform regression check: compare existing record labels between old and new benchmark (no label should have changed for records that existed before)
- [ ] Verify `axiom_name` is present in all axiom-sourced records in the final output
- [ ] Run `lake build` to verify no Lean build regressions

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `data/bmlogic-bench.jsonl` - Regenerated by pipeline
- `data/bmlogic-bench_metadata.json` - Regenerated by pipeline
- `data/axiom-instances.jsonl` - Regenerated by `benchmark_anchors`

**Verification**:
- `data/bmlogic-bench_metadata.json` shows `axiom_constructors_present: 42`, `axiom_constructors_total: 42`
- Total benchmark size is between 800-900 records
- Zero regression in existing record labels
- `lake build` succeeds with no errors

---

## Testing & Validation

- [ ] `lake build` succeeds without errors after all changes
- [ ] `lake exe benchmark_anchors` produces 126 anchor records covering 42/42 axiom constructors
- [ ] Each of the 42 axiom constructor names appears at least 3 times in the output
- [ ] All 37 Base-class axiom instances are labeled valid with proof traces
- [ ] Non-Base axiom instances (5 constructors) are labeled with appropriate frame class annotation
- [ ] `finalize_benchmark.py` output retains `axiom_name` field for axiom-sourced records
- [ ] Benchmark metadata reports `axiom_constructors_present: 42`
- [ ] Total benchmark size is within 800-900 records
- [ ] No existing benchmark record labels have changed (regression test)

## Artifacts & Outputs

- `specs/220_anchor_coverage_expansion/plans/01_anchor-coverage-plan.md` (this plan)
- Modified `Theories/Bimodal/Automation/ProofSearch/Core.lean` (29 new `matchAxiom` branches)
- Modified `Theories/Bimodal/Automation/BenchmarkAnchors.lean` (direct axiom labeling + top-3 selection)
- Modified `scripts/finalize_benchmark.py` (`axiom_name` preservation)
- Regenerated `data/bmlogic-bench.jsonl` (800-900 records, 42/42 coverage)
- Regenerated `data/bmlogic-bench_metadata.json` (updated statistics)

## Rollback/Contingency

All changes are in version-controlled files. If the implementation fails:
1. Revert `ProofSearch/Core.lean`, `BenchmarkAnchors.lean`, and `finalize_benchmark.py` via `git checkout`
2. Restore `data/bmlogic-bench.jsonl` and metadata from the pre-expansion backup
3. If only `matchAxiom` extension succeeds but labeling changes cause regressions, the `matchAxiom` improvements can be kept independently (they improve proof search generally) while reverting the `BenchmarkAnchors` labeling changes
