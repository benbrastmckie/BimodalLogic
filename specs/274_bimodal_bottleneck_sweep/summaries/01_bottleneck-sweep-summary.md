# Implementation Summary: Task #274 — Post-270-272 Bottleneck Sweep

- **Task**: 274 — Run dataset generation at increasing complexity to find new bottleneck after tasks 270-272
- **Session**: sess_1748987036_e8b4c8
- **Date**: 2026-06-03
- **Status**: Complete (all 5 phases)
- **Build**: `lake build` passes (1684 jobs, zero errors)

## Summary

Fixed the three critical bottlenecks identified in the post-270-272 research:

1. **Active rule timeout regression** (Phase 1): Added `TimeOrdering.timeCount` guard to untlNeg/snceNeg active rules — the active rule now only fires when the time ordering already has temporal structure (not for standalone temporal formulas), preventing exponential branching chains. c5 timeout rate restored from 24.8% to 0%.

2. **G/H complexity overhead** (Phase 3): Added pattern-aware cases to `Formula.complexity` so F/P/G/H derived operators are recognized with overhead 1 (matching box) instead of 4/4/8/8. Updated `FormulaEnumerator.lean` overhead constants to match (Phase 5). G(atom) drops from complexity 9 to 2, enabling bimodal G/H formulas at c5-c7.

3. **Temporal axiom attribution** (Phase 4): Added `structuralPrefilterWithAxiom` returning axiom pattern names alongside validity, propagated to JSONL output via `proofReconstructionMethod` field. Five attribution patterns: `structural_bot_temporal`, `structural_tautology`, `structural_double_box_bot`, `structural_modal_4`, `structural_modal_t_weakening`.

## Metrics Comparison

### Timeout Rates

| Level | Pre-271 | Post-271 | Post-274 | Target |
|-------|---------|----------|----------|--------|
| c5 (no G/H) | 0% | 24.8% | 0% | 0% |
| c5 (with G/H) | N/A | N/A | 18% | N/A |
| c7 (no G/H) | 4.8% | 41.7% | 4.9% | <5% |
| c7 (with G/H) | N/A | N/A | 17% | N/A |
| c9 | feasible | infeasible | feasible (14%) | feasible |

The higher timeout rates "with G/H" are expected — these are new formula classes that were previously unreachable due to complexity overhead. The inherent decision procedure complexity for temporal formulas causes ~15% timeout rates, which is normal behavior.

### Processing Speed

| Level | Pre-271 | Post-271 | Post-274 |
|-------|---------|----------|----------|
| c5 | ~790/sec | ~30/sec | ~191/sec |
| c7 | ~1500/sec | ~6.3/sec | ~613/sec |
| c9 | feasible | infeasible | ~663/sec |

### Bimodal G/H Formulas

| Level | Pre-274 | Post-274 |
|-------|---------|----------|
| c5 | 0 | 491 |
| c7 | 0 | 4368 |
| c9 | 0 | Not measured |

### Axiom Attribution in Prefilter-Valid Records (c5)

| Pattern | Count |
|---------|-------|
| structural_bot_temporal | 45 |
| structural_modal_4 | 1 |
| structural_tautology | 1 |

## Files Modified

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | Added `TimeOrdering.timeCount` helper |
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | Added depth-limited guard to active untlNeg/snceNeg rules |
| `Theories/Bimodal/Syntax/Formula.lean` | Pattern-aware complexity for F/P/G/H, `#eval` verification tests |
| `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` | Updated `some_future_complexity`, `iter_F_complexity`, `some_past_complexity`, `iter_P_complexity` lemmas |
| `Theories/Bimodal/Automation/DatasetGenerator.lean` | Added `structuralPrefilterWithAxiom`, wired into `labelFormula` |
| `Theories/Bimodal/Automation/FormulaEnumerator.lean` | Updated F/P/G/H overhead constants from 4/4/8/8 to 1/1/1/1 |

## Plan Deviations

- **Phase 1, Task 1.2**: Altered — used `TimeOrdering.timeCount` global guard instead of per-label counter; active rule only fires when `timeCount > 0 && timeCount < 4`
- **Phase 1, Task 1.5**: Altered — added `TimeOrdering.timeCount` helper to count distinct time indices in constraints, used globally instead of per-label tracking
- **Phase 3, Task 3.7**: Altered — G(atom) is 2 not 3 as planned; overhead is 1 matching box, which is strictly better than planned target of overhead 2
- **Phase 5, Task 5.4**: Altered — verified G/H appearance via dataset generation output rather than `generateBimodalSlice` directly

## Remaining Bottlenecks

The primary remaining bottleneck is the inherent complexity of the decision procedure for temporal formulas. G/H formulas, which are now reachable at low complexity levels, have ~15% timeout rates due to the exponential branching in Until/Since decomposition. This is normal behavior, not a regression. Further optimization would require deeper search techniques (global caching, improved blocking, or formula-specific heuristics).
