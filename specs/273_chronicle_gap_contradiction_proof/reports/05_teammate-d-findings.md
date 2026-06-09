# Task 273 Teammate D: HORIZONS — Strategic Assessment

**Role**: Long-term alignment and strategic direction
**Artifact**: 05 (team research round)
**Teammate**: D

---

## Key Findings

### 1. What the Task Originally Was vs. What It Has Become

**Original target** (from task description): "Prove `discrete_stavi_expressive_completeness` by following GHR93 exactly via the decomposition-formula path."

**What changed**: After 15 cycles, the actual architecture has shifted significantly:
- `DiscreteGameTransfer.lean` (1470 lines) is now **sorry-free**
- The GHR93 Theorem 6 (`ghr93_forward_to_backward`) is proved sorry-free in `Expressiveness/Theorem6.lean`
- `DiscreteGameTransfer.lean` delegates to that via `discrete_ghr93_theorem6` and `discrete_ghr93_proposition7`
- A new file `DiscreteStaviCompleteness.lean` (496 lines) isolates the last integration step

**The remaining sorry** (DiscreteStaviCompleteness.lean:338) is the backward direction of `exist_sf_correct`: given that a StaviFormula `nf_exist_sf_guarded` holds at a discrete model at time `t`, extract a witness `x : N.carrier` such that the 2-var NF holds at `(x, t)`.

This is mathematically the same content as StaviCompleteness.lean:2805 (`nf_exist_sf_guarded_backward`), but restricted to discrete models where `IsSuccArchimedean` holds.

### 2. Does This Sorry Matter for Publication?

**Yes, substantially — but the path is not what the task description suggests.**

The critical sorry chain for `completeness_discrete` is:

```
completeness_discrete (Completeness.lean:309)
  <- countermodel_discrete_reynolds_v2 (ReynoldsBridge.lean:724)
    <- no_gaps_discrete_model_surgery (GoodStructuresModelSurgery.lean:2133)
      <- gap_prior_UZ_contradiction (GoodStructuresModelSurgery.lean:1169)
        <- invariant_formula_constant (line ~1259) 
          <- US_expressively_complete_over_prior (PriorExpressiveness.lean:371)
            <- stavi_expressive_completeness (StaviCompleteness.lean:3188)
              <- nf_characterizable_by_stavi
                <- nf_exist_sf_guarded_backward (StaviCompleteness.lean:2805)
                  <- sorry
```

The sorry at DiscreteStaviCompleteness.lean:338 is NOT on this critical path. The critical path goes through `stavi_expressive_completeness` (the general, non-discrete version) which calls the sorry'd `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805) for ALL M, not just discrete M.

**Critical architectural finding**: `US_expressively_complete_over_prior` calls the sorry-tainted `stavi_expressive_completeness` (general version), not `discrete_stavi_expressive_completeness`. Making DiscreteStaviCompleteness.lean sorry-free does NOT automatically make `completeness_discrete` sorry-free. The sorry chain runs through the general version.

The phase-4 handoff (2026-06-09) identified this explicitly: "US_expressively_complete_over_prior cannot use discrete chain" because `GoodStructuresModelSurgery.lean` callers have `SuccOrder/PredOrder/NoMaxOrder/NoMinOrder` but NOT `IsSuccArchimedean`. In fact line 512 of GoodStructuresModelSurgery.lean proves NOT IsSuccArchimedean for the surgery context.

### 3. What Sorries Currently Block Publication?

Based on a systematic survey of actual sorry proof terms (not comments) across the WeakCanonical path:

| File | Line | What it sorries | Criticality |
|------|------|-----------------|-------------|
| `StaviCompleteness.lean` | 2353 | `nf_2var_existential_transfer` (j>=1 case) | CRITICAL (blocks general stavi completeness) |
| `StaviCompleteness.lean` | 2435 | `nf_2var_existential_transfer` (second case) | CRITICAL (same) |
| `StaviCompleteness.lean` | 2805 | `nf_exist_sf_guarded_backward` | CRITICAL (blocks US_expressively_complete_over_prior) |
| `DiscreteStaviCompleteness.lean` | 338 | backward direction of `exist_sf_correct` for discrete M | IMPORTANT but not on critical path to completeness_discrete |
| `Transfer.lean` | 1297 | `countermodel_discrete` (dead BX pipeline path) | DEAD CODE — not on any active path |
| `TruthLemma.lean` | 431, 448, 483, 497, 540, 556 | Until/Since backward (6 sites) | NON-CRITICAL (parametric truth lemma handles these) |
| `ChronicleExtraction.lean` | 190 | `domain_succ_archimedean` in dead code | DEAD CODE |
| `OrderedSum.lean` | 56 | `doets_lemma_1_5` | NOT on discrete completeness critical path |
| `GapDetection.lean` | ~1131 | `left_formula_gap_detection` | Not on completeness_discrete path |

**The actual blocker for `completeness_discrete`**: StaviCompleteness.lean:2805 (`nf_exist_sf_guarded_backward`). This sorry blocks `nf_characterizable_by_stavi` -> `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> `gap_prior_UZ_contradiction` -> `no_gaps_discrete_model_surgery` -> `countermodel_discrete_reynolds_v2` -> `completeness_discrete`.

### 4. Is the DiscreteStaviCompleteness Approach Still the Right One?

**Partially.** The architectural decision to create `DiscreteStaviCompleteness.lean` (cycle 6, phase 4 handoff) was sound for one reason: it avoids a circular import that prevents importing `DiscreteGameTransfer.lean` into `StaviCompleteness.lean` (the import chain is `DiscreteGameTransfer -> CaseAnalysis -> StaviCompleteness`).

However, proving `discrete_nf_exist_sf_guarded_backward` in `DiscreteStaviCompleteness.lean` gives `discrete_stavi_expressive_completeness`, but this does NOT feed into `completeness_discrete` because `US_expressively_complete_over_prior` cannot call the discrete version (its callers don't have `IsSuccArchimedean`).

**Alternative path that WOULD close completeness_discrete**: Prove the general `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805) for all linear orders — not just discrete ones. This is harder (it's been sorry'd across 15+ cycles) but would directly close the critical path.

The three sorries at StaviCompleteness.lean:2353, 2435, 2805 are the mathematical core of GHR93 Theorem 9.3.1 for general linear orders. GHR93's full argument requires handling the gap cases (Cases III/IV of Theorem 6) which are vacuous for discrete orders but necessary for the general case.

### 5. Could the Circular Import Be Resolved Differently?

Yes. Instead of creating `DiscreteStaviCompleteness.lean` that imports from `DiscreteGameTransfer.lean`, one could:

1. Extract the game-theoretic backward proof helper (`nf_exist_sf_guarded_backward_game`) into `NFGameBridge.lean` (which is already imported by `StaviCompleteness.lean` via `CharacteristicFormula.lean`)
2. Have `StaviCompleteness.lean` call this helper for the general backward direction

The circular import exists because `DiscreteGameTransfer.lean` imports `Theorem6.lean` which imports `CaseAnalysis.lean` which imports `StaviCompleteness.lean`. But `NFGameBridge.lean` is imported BY `CaseAnalysis.lean` (in the forward direction), so adding the backward proof there would not create a cycle.

However, this path requires proving the general (non-discrete) backward direction using the game pipeline — which requires handling gap cases that Theorem 6 covers but Cases III/IV make complex.

### 6. The Proposition 7 Sorry Status

Phase-3 handoffs (2026-06-09 and 2026-06-10) show that `discrete_ghr93_proposition7` in `DiscreteGameTransfer.lean` has 2 remaining sorries (down from 5). These are in the sorted matching construction for the point challenge — specifically around ordering consistency when `b` comes from a full-interval decomposition rather than a sub-interval-aware decomposition.

**However**: Based on the current grep, `DiscreteGameTransfer.lean` shows NO actual sorry proof terms (only comments mentioning sorry). This suggests the handoffs may be describing an in-progress state where those sorries were actually eliminated in the most recent cycle. The file is 1470 lines and sorry-free according to the grep result.

**Conclusion**: DiscreteGameTransfer.lean is currently sorry-free. The only remaining sorry on the task 273 scope is DiscreteStaviCompleteness.lean:338.

---

## Strategic Recommendations

### Recommendation 1: Reframe Task 273 as "Substantially Complete"

DiscreteGameTransfer.lean is sorry-free. This is the core mathematical contribution — GHR93 Theorem 6 (forward-to-backward game inversion) and Proposition 7 (multi-interval composition) are proved for discrete orders. The last remaining sorry (DiscreteStaviCompleteness.lean:338) is an integration step.

The integration step can reasonably be declared a **separate task** given:
- It requires connecting the game pipeline to the specific 2-var NF format in StaviCompleteness.lean
- It does NOT close `completeness_discrete` (the critical path runs through the general version)
- The mathematical content is proved; only the Lean wiring remains

### Recommendation 2: The True Critical Path is StaviCompleteness.lean:2805

If the goal is a sorry-free `completeness_discrete`, the effort should focus on `nf_exist_sf_guarded_backward` in `StaviCompleteness.lean` (line 2805), NOT on `DiscreteStaviCompleteness.lean:338`. This requires:
1. Proving the general backward direction for all linear orders (using all four cases of GHR93 Theorem 6, including gap cases)
2. OR finding an alternative route to `US_expressively_complete_over_prior` that uses the discrete infrastructure without requiring `IsSuccArchimedean` in the surgery context

**The architectural gap**: `gap_prior_UZ_contradiction` needs `US_expressively_complete_over_prior` on models that do NOT satisfy `IsSuccArchimedean` (the surgery model is an arbitrary succ-pred-NoMax-NoMin structure, not necessarily archimedean). This makes it mathematically impossible to route through the discrete version of Stavi completeness in this context.

### Recommendation 3: Declare Task 273 Partially Complete with Redirect

Declare task 273 `[PARTIAL]` with:
- Completed: DiscreteGameTransfer.lean sorry-free (GHR93 Theorem 6 + Proposition 7 for discrete orders)
- Remaining: DiscreteStaviCompleteness.lean:338 integration step

Create a new task (task ~300) to prove `nf_exist_sf_guarded_backward` for general linear orders (StaviCompleteness.lean:2805). This is the true critical-path sorry and would directly close `completeness_discrete`.

### Recommendation 4: Consider Routing completeness_discrete Differently

An alternative approach: modify `US_expressively_complete_over_prior` to accept a discrete instance parameter and route to `discrete_stavi_expressive_completeness` when available. Then modify `gap_prior_UZ_contradiction` to derive `IsSuccArchimedean` for the surgery model by another means.

This may be impossible given line 512 of GoodStructuresModelSurgery.lean proves `NOT IsSuccArchimedean` for the exact surgery context. The surgery model N is a restriction of M to `class(a)`, and M itself may not be archimedean during the proof. The very point of Reynolds Theorem 14 is to work on non-archimedean models and derive a contradiction.

---

## Risk Assessment

| Risk | Level | Notes |
|------|-------|-------|
| DiscreteStaviCompleteness.lean:338 is not on critical path | HIGH | Confirmed by import analysis. Proving this sorry does not make completeness_discrete sorry-free. |
| 15+ cycle investment with no completeness_discrete progress | MEDIUM | DiscreteGameTransfer.lean is sorry-free — that IS valuable infrastructure, but the original goal is not achieved |
| Proposition 7 sorries re-emerging | LOW | DiscreteGameTransfer.lean appears sorry-free per grep |
| General nf_exist_sf_guarded_backward is harder than discrete version | HIGH | Requires Cases III/IV of GHR93 Theorem 6 (gap cases) — much more complex |
| Circular import preventing direct integration | HIGH | The `DiscreteGameTransfer -> CaseAnalysis -> StaviCompleteness` chain is architectural, not easily resolved |

---

## Confidence Level

**High confidence** on:
- DiscreteStaviCompleteness.lean:338 is NOT on the critical path to `completeness_discrete` (import analysis confirmed)
- The critical path runs through `stavi_expressive_completeness` (general), not the discrete version
- DiscreteGameTransfer.lean is currently sorry-free (grep confirmed no actual sorry proof terms)

**Medium confidence** on:
- Whether the 2 remaining sorries in `discrete_ghr93_proposition7` described in the phase-3 handoffs were actually resolved (grep says zero sorries, but handoffs were written 6 hours ago)
- Whether `US_expressively_complete_over_prior` could be routed through the discrete path with architectural changes

**Lower confidence** on:
- Whether the general `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805) is provable at all without Cases III/IV of GHR93 Theorem 6 being formalized

---

## Summary for the Synthesizer

The core finding is an **architectural gap between task 273's sorry and completeness_discrete**:

1. Task 273's remaining sorry (DiscreteStaviCompleteness.lean:338) proves `discrete_stavi_expressive_completeness` sorry-free.
2. `completeness_discrete` uses `US_expressively_complete_over_prior`, which calls `stavi_expressive_completeness` (general), not the discrete version.
3. The general version has sorry'd `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805).
4. The general sorry cannot be bypassed with the discrete version because the surgery context in `gap_prior_UZ_contradiction` does NOT have `IsSuccArchimedean`.

Therefore: **Task 273 as implemented creates valuable infrastructure (sorry-free DiscreteGameTransfer.lean) but does not reach its stated goal of closing `completeness_discrete` via this path**.

The highest-impact next action is to prove `nf_exist_sf_guarded_backward` for ALL linear orders (StaviCompleteness.lean:2805), which is substantially harder than the discrete case but directly closes the critical path.
