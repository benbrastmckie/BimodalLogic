# Research Report: c5 Timeout Reduction Strategy

**Date**: 2026-06-07
**Task**: #284 — Reduce c5 timeouts via hybrid proof-pool labeling and extended structural prefilter
**Dependencies**: Tasks 265, 274, 277, 278, 279
**Status**: PLANNED

---

## Executive Summary

Post-task-278 c5 dataset regeneration produced **1,156 timeouts (19.2%)** out of 6,031 formulas. This is within the structural plateau identified in task 264 but still represents ~1,150 formulas whose logical validity is unknown. Unlike previous bottlenecks (c6 "slow timeouts" eliminated by task 265), these c5 timeouts are **distributed across many formula shapes**, not concentrated in a few catastrophic cases. They cannot be resolved by lowering timeout alone; they require either (a) avoiding the decision procedure for provably valid/invalid formulas, or (b) fixing the decision procedure's root cause.

This report documents the timeout profile, evaluates five candidate strategies, and recommends a concrete implementation plan.

---

## 1. Timeout Profile

### Overall counts
| Label | Count | % |
|-------|-------|---|
| valid | 103 | 1.7% |
| invalid | 4,772 | 79.1% |
| **timeout** | **1,156** | **19.2%** |
| **Total** | **6,031** | **100%** |

### Prefilter coverage
- Prefilter matched **94 of 103 valid formulas** (~91%)
- Only **9 valid formulas** fell through to the decision procedure
- **0 invalid formulas** were mis-labeled by the prefilter (no false positives)

### Timeout characteristics
| Feature | Distribution | Notes |
|---------|------------|-------|
| Top operator | 90% implication, 10% box | Implication-shaped timeouts dominate |
| Contains U (untl) | 72% | Nested Until is the primary temporal pattern |
| Contains S (snce) | 72% | Same as Until (often paired) |
| Temporal depth = 2 | 93% | All timeouts involve nested temporal operators |
| Contains atoms | 86% | Unlike task 265's bot-temporal pattern |
| Modal depth = 0 | 56% | Many are purely temporal, no modal operators |
| Complexity = 5 | 80% | Bulk at the target complexity level |

### Dominant structural class
The **majority of timeouts** match this shape:

```
U(atom, X) → U(Y, Z)     or     S(atom, X) → S(Y, Z)
```

This is the same pattern class identified by task 267 as dominating c8 timeouts. At c5 it appears in ~800 formulas. The antecedent is **not** trivially unsatisfiable (the event is an atom, not `⊥`), and the consequent is **not** obviously valid.

---

## 2. Strategy Evaluation

### Strategy A: Lower wall-clock timeout
- **Effect**: Reduces wall-clock generation time but does **not** reduce timeout count
- **Verdict**: ❌ Not viable — we need fewer timeouts, not faster timeout discovery

### Strategy B: Skip timeout records from training data
- **Effect**: Excludes ~1,156 records from ML datasets
- **Verdict**: ❌ Not viable — the user explicitly requested "without skipping formulas without reason"
- **Note**: Task 267 recommended this for ML training, but it does not solve the labeling problem

### Strategy C: Proof-pool hybrid labeling (Task 279 infrastructure)
- **Mechanism**: Pre-generate a proof pool via `proof_first_generator`, then use `.hybrid` mode in `labelFormula` to check the pool before invoking the tableau
- **Expected impact**: Unknown — many timeout formulas may be theorems derivable by forward-chaining from axioms
- **Pros**: Uses existing infrastructure; O(1) pool lookup; no changes to decision procedure
- **Cons**: Only catches **valid** formulas; invalid formulas still need tableau; pool must be large enough
- **Verdict**: ✅ **Recommended as Phase 1** — quick to test, low risk

### Strategy D: Extend structural prefilter with new pattern classes
- **Mechanism**: Add prefilter rules for `U(atom, X) → U(Y, Z)` and related shapes
- **Expected impact**: High if a structural decidability rule exists; zero if none exists
- **Pros**: O(n) syntactic check; applies to all complexity levels; no fuel cost
- **Cons**: Requires formal proof that the pattern is always valid/invalid; risk of false positives
- **Verdict**: ✅ **Recommended as Phase 2** — requires research, but highest long-term payoff

### Strategy E: Add memoization/caching to tableau prover
- **Mechanism**: Cache `expandBranchWithFuel` results keyed by `(SignedFormula, FrameClass, Fuel)`
- **Expected impact**: Unknown but potentially large — eliminates redundant sub-branch expansion
- **Pros**: Root-cause fix; benefits all complexity levels; no risk of false positives
- **Cons**: Architectural change to core decision procedure; requires careful correctness testing
- **Verdict**: ✅ **Recommended as Phase 3** — highest effort, highest reward

---

## 3. Recommended Implementation Plan

### Phase 1: Proof-Pool Hybrid Mode (1 day)
1. Generate proof pool at depth 2 with 10,000 seeds over atoms {p, q, r}
2. Modify `DatasetExport.lean` to load pool and pass to `labelFormula` in `.hybrid` mode
3. Regenerate c5 and measure:
   - New timeout count
   - Time saved vs baseline
   - Pool hit rate

### Phase 2: Prefilter Pattern Research (2–3 days)
1. Formal analysis: Is `U(atom, X) → U(Y, Z)` always valid, always invalid, or mixed?
2. If always valid: add `structural_temporal_equiv` rule to prefilter
3. If always invalid: add `structural_temporal_conflict` rule
4. If mixed: document and skip (no prefilter rule possible)
5. Repeat for `S(atom, X) → S(Y, Z)` and nested box-temporal variants

### Phase 3: Tableau Memoization (3–5 days)
1. Design cache structure for `expandBranchWithFuel`
2. Implement keyed memoization with `HashMap`
3. Verify no memory leaks at c7 scale
4. Benchmark c5/c6/c7 timeout reduction

---

## 4. Key Questions for Phase 2 Research

1. Does `U(p, X) → U(Y, Z)` admit a structural simplification rule in BX temporal logic?
2. What is the interaction between `□` and nested `U/S` in the tableau expansion? Does the modal context constrain the temporal branch enough to make the formula decidable by inspection?
3. Are the 56% of timeouts with modal depth = 0 (purely temporal) actually theorems of pure linear temporal logic, decidable by a simpler procedure?

---

## 5. Reference Data

- **c5 dataset**: `data/bmlogic-c5.jsonl` (regenerated 2026-06-07)
- **Task 265 prefilter analysis**: `specs/265_single_tier_fuel_and_timeout_prefilter/reports/01_fuel-strategy-prefilter.md`
- **Task 267 c9 optimization research**: `specs/267_dataset_pipeline_c9_optimization/reports/01_team-research.md`
- **Task 278 prefilter expansion plan**: `specs/278_structural_prefilter_expansion/plans/01_structural-prefilter-expansion.md`
- **Task 279 proof-first generator**: `Theories/Bimodal/Automation/ForwardProofGenerator.lean`
- **Decision procedure**: `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean`

---

## 6. Decision Method Distribution (c5)

| Method | Count | % of total |
|--------|-------|------------|
| fast_path_axiom | 5 | 0.1% |
| structural_prefilter | 94 | 1.6% |
| adaptive_timeout | 1,156 | 19.2% |
| adaptive_500 | 4,776 | 79.2% |

The prefilter already handles ~91% of valid formulas. The opportunity is to expand coverage to formulas currently in the `adaptive_timeout` bucket.
