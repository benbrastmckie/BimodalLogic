# GHR93 Strategy Review: Phase 4 Blocker and Plan Revision

**Task**: 155 (Reynolds Pipeline Activation)
**Focus**: Is the full GHR93 Theorem 4 proof needed? Dependency chain analysis, alternative strategies.
**Session**: sess_1779302773_0a17f1
**Date**: 2026-05-20

---

## 0. Executive Summary

The plan (v5) calls for a full formalization of GHR93 Theorem 9.3.1 (stavi_expressive_completeness) at an estimated 20-30 hours. After tracing the exact dependency chain and auditing the codebase, the research finds:

1. **The full GHR93 Theorem 4 proof is NOT needed for the Reynolds pipeline.** The discrete-only case suffices, and the codebase already has `flatten_stavi_correct` (sorry-free) which provides the discrete equivalence.

2. **The critical path to sorry-free `bx_completeness` has exactly TWO sorry sources**, not the five-sorry chain the plan implies:
   - `h_truth_corr` (Transfer.lean:574) -- direct sorry
   - `IsSuccArchimedean` on chronicle domain (via `limitDomSubtype_isSuccArchimedean -> succ_cofinal`, task 129)

3. **`no_gaps_discrete` is NOT on the current critical path.** The existing `chronicle_is_good` uses `orderIsoIntOfLinearSuccPredArch` directly, not the `one_class + very_good_implies_good` chain. The plan's goal of removing `orderIsoIntOfLinearSuccPredArch` creates the need for `no_gaps_discrete`.

4. **Two alternative strategies** can close the pipeline at substantially lower cost than the plan's current Phase 4 (20-30 hours). Both avoid the full GHR93 game-theoretic proof.

---

## 1. Current State Summary

### Sorry-Free Components

| Component | File | Verified |
|-----------|------|----------|
| `chronicle_is_good` | IntegerModel.lean:1245 | No sorryAx (uses orderIsoIntOfLinearSuccPredArch) |
| `flatten_stavi_correct` | StaviConnectives.lean:459 | No sorryAx |
| `stavi_U_discrete_equiv` | StaviConnectives.lean:362 | No sorryAx |
| `stavi_S_discrete_equiv` | StaviConnectives.lean:384 | No sorryAx |
| `cofinal_above_iff_succ` | StaviConnectives.lean:263 | No sorryAx |
| `cofinal_below_iff_pred` | StaviConnectives.lean:287 | No sorryAx |
| `contemp_equiv_is_equiv` | IntegerModel.lean:710 | No sorryAx |
| `no_boundary_at_successor` | IntegerModel.lean:866 | No sorryAx |
| `chronicle_temporal_truth` | Transfer.lean (Phase 1) | No sorryAx |
| `table_correctness` | Table.lean:244 | No sorryAx |
| `US_expressively_complete_over_Z` | ExpressiveCompleteness.lean:2121 | No sorryAx |
| `doets_lemma_1_1` | NormalForm.lean:433 | No sorryAx |
| `doets_lemma_1_4` | OrderedSum.lean:34 | No sorryAx |
| `k_equiv_of_iso` | IntegerModel.lean:101 | No sorryAx |
| `truth_transfer` | Transfer.lean:122 | No sorryAx |

### Sorry'd Components (Critical Path)

| Component | File:Line | Source of Sorry | Impact |
|-----------|-----------|-----------------|--------|
| `countermodel_discrete` | Transfer.lean:574 | Direct sorry (`h_truth_corr`) | CRITICAL -- the only direct sorry on the bx_completeness path |
| `extract_chronicle_as_prior` | ChronicleExtraction.lean:175 | `limitDomSubtype_isSuccArchimedean` -> `succ_cofinal` (task 129) | CRITICAL -- provides `IsSuccArchimedean` needed by `orderIsoIntOfLinearSuccPredArch` |

### Sorry'd Components (NOT on Current Critical Path)

| Component | File:Line | Status | Notes |
|-----------|-----------|--------|-------|
| `stavi_expressive_completeness` | EFGames.lean:173 | Sorry'd | Not called by anything |
| `no_gaps_discrete` | IntegerModel.lean:859 | Sorry'd | Only called by `one_class`, which is not on critical path |
| `one_class` | IntegerModel.lean:900 | Inherits sorry from `no_gaps_discrete` | Not called by anything on critical path |
| `cofinal_decomposition_k_equiv` | IntegerModel.lean:1135 | Sorry'd | Only used by `very_good_implies_good` |
| `ordered_sum_of_good_bounded_is_good` | IntegerModel.lean:1194 | Sorry'd | Only used by `very_good_implies_good` |
| `very_good_implies_good` | IntegerModel.lean:1210 | Inherits sorry | Not called by anything on critical path |
| `doets_lemma_1_5` | OrderedSum.lean:56 | Sorry'd | Not on discrete critical path |
| TruthLemma.lean Until/Since backward | TruthLemma.lean:431,448,483,497,540,556 | Sorry'd | Not on critical path (parametric truth lemma bypasses) |

### EFGames.lean Content

The file contains approximately 170 lines:
- `EFPosition` structure (game state)
- `ef_duplicator_wins` predicate
- `game_depth` function with recursion
- `game_depth_succ_ge_two` basic bound
- `stavi_expressive_completeness` -- sorry'd, not called anywhere

The sorry'd `stavi_expressive_completeness` has signature:
```lean
noncomputable def stavi_expressive_completeness
    (sig : MonadicSignature) (atomMap : Formula -> sig.preds)
    (psi : MonadicFormula sig 1) :
    { A : StaviFormula //
      forall (M : OrderedMonadicStructure sig) (t : M.carrier),
        stavi_temporal_truth M atomMap t A <->
        eval M (fun _ => t) psi }
```

This returns a `StaviFormula` (not a standard `Formula`). The `flatten_stavi_correct` theorem converts StaviFormula to Formula in discrete orders. So the full chain for discrete expressive completeness would be:
```
psi (MonadicFormula) -> stavi_expressive_completeness -> StaviFormula A
                     -> flatten_stavi A -> Formula B
                     -> flatten_stavi_correct: B equivalent to A in discrete orders
```

---

## 2. Dependency Chain Analysis

### What `countermodel_discrete` Actually Needs

The critical path to `bx_completeness` runs through:

```
bx_completeness (Completeness.lean:134)
  -> countermodel_discrete (Transfer.lean:494)
    -> extract_chronicle_as_prior (ChronicleExtraction.lean)  [sorry: succ_cofinal]
    -> orderIsoIntOfLinearSuccPredArch [needs IsSuccArchimedean]
    -> h_truth_corr (Transfer.lean:574)  [direct sorry]
```

### What the Plan WANTS the Critical Path to Be

The plan (v5) envisions replacing `orderIsoIntOfLinearSuccPredArch` with:

```
countermodel_discrete
  -> extract_chronicle_as_prior (WITHOUT domain_succ_archimedean)
  -> chronicle_is_good (via one_class + very_good_implies_good)
    -> one_class
      -> no_gaps_discrete  [needs expressive completeness]
        -> gap_elimination_theorem_14  [Lemmas 6-13]
          -> temporal formula R  [needs Theorem 5]
            -> stavi_expressive_completeness  [GHR93 Theorem 4]
    -> very_good_implies_good
      -> cofinal_decomposition_k_equiv  [sorry'd]
      -> ordered_sum_of_good_bounded_is_good  [sorry'd]
  -> h_truth_corr [direct sorry]
```

### What the Plan's Phases Actually Need from Phase 4

Tracing dependencies for each downstream phase:

**Phase 6 (Gap Elimination, Lemmas 6-13)**: Needs a way to convert a monadic FO formula (the gap-detection formula rho) to an equivalent temporal formula. The plan says this needs Theorem 5, which needs Theorem 4 (`stavi_expressive_completeness`). BUT: Phase 5 already proved `flatten_stavi_correct` which converts any StaviFormula to a standard temporal formula in discrete orders. So if `stavi_expressive_completeness` is proved, Phase 6 can compose: psi -> stavi_expressive_completeness -> StaviFormula -> flatten_stavi -> Formula.

**Phase 7 (IntegerModel helpers)**: INDEPENDENT of Phase 4. Needs `cofinal_decomposition_k_equiv` and `ordered_sum_of_good_bounded_is_good` -- these are sorry'd but have nothing to do with Stavi/GHR93.

**Phase 8 (Wire no_gaps_discrete)**: Needs `gap_elimination_theorem_14` from Phase 6. Transitively needs Phase 4.

**Phase 9 (Rewrite chronicle_is_good)**: Needs `one_class` (Phase 8) and `very_good_implies_good` (Phase 7). Does NOT directly need Phase 4.

**Phase 10 (Final verification)**: Needs everything.

### The Minimal Theorem Needed

For the downstream pipeline, what is actually needed is a function:

```lean
-- For any monadic FO formula of bounded depth, there exists an equivalent
-- temporal formula on discrete Prior structures
discrete_expressiveness_transfer (sig : MonadicSignature)
    (psi : MonadicFormula sig 1) :
    exists (A : Formula),
      forall (M : OrderedMonadicStructure sig)
        [SuccOrder M.carrier] [PredOrder M.carrier]
        [NoMaxOrder M.carrier] [NoMinOrder M.carrier]
        (atomMap : Formula -> sig.preds)
        (t : M.carrier),
          eval M (fun _ => t) psi <-> temporal_truth M atomMap t A
```

This is WEAKER than `stavi_expressive_completeness` (which works for ALL linear orders). This discrete-only version is all that Lemma 6 (and hence Lemmas 7-13, Theorem 14) needs.

---

## 3. GHR93 Strategy Assessment

### Is the Full Proof Needed?

**NO.** The full GHR93 Theorem 9.3.1 proves {U,S,U',S'} expressiveness for ALL linear orders (discrete, dense, mixed). The Reynolds pipeline only needs discrete orders.

The codebase already has:
1. `US_expressively_complete_over_Z`: {U,S} expressiveness for Z-structures (carrier = Z)
2. `flatten_stavi_correct`: StaviFormula -> Formula equivalence in discrete orders

What is missing is the bridge: extending Z-expressiveness to arbitrary discrete orders.

### Three Possible Approaches

**Approach A: Full GHR93 (Plan v5 Phase 4 as written)**
- Prove `stavi_expressive_completeness` via game-theoretic argument
- Compose with `flatten_stavi_correct` for discrete case
- Effort: 20-30 hours (the plan's estimate)
- Yields: General result for ALL linear orders (far more than needed)

**Approach B: Discrete Expressiveness Transfer (Path B from report 06)**
- Use NF realization to show every pointed k-type in a discrete order is realizable in Z
- Transfer Z-expressiveness to arbitrary discrete orders via `doets_lemma_1_1`
- Effort: 8-15 hours
- Yields: Discrete-only result (exactly what is needed)
- Dependencies: `cofinal_decomposition_k_equiv` and `ordered_sum_of_good_bounded_is_good` (also needed for Phase 7)

**Approach C: Direct Discrete Argument (NEW)**
- Observe that the chronicle is ALREADY known to be order-isomorphic to Z (that is what `orderIsoIntOfLinearSuccPredArch` provides, modulo the sorry in `succ_cofinal`)
- Instead of removing `orderIsoIntOfLinearSuccPredArch` from the pipeline, CLOSE `succ_cofinal` (task 129)
- This would make the existing `chronicle_is_good` and `countermodel_discrete` sorry-free (except for `h_truth_corr`)
- Effort: Depends on task 129 difficulty; plus `h_truth_corr` (Phase 9 Task 9.5)
- Yields: The pipeline works as-is, just with the sorry filled

### Assessment of Each Approach

**Approach A** is mathematically valuable but massive overkill. The GHR93 game proof is a standalone research contribution. The Reynolds pipeline does not need it.

**Approach B** is the most principled approach that stays within the plan's spirit (avoid `IsSuccArchimedean` dependency). It requires closing `cofinal_decomposition_k_equiv` and `ordered_sum_of_good_bounded_is_good`, which are needed anyway for `very_good_implies_good`. The main new work is the `int_truth / temporal_truth` bridge and the pointed NF realization.

**Approach C** sidesteps the entire `no_gaps_discrete` -> `one_class` -> `very_good_implies_good` chain. The plan explicitly forbids this ("NEVER use `orderIsoIntOfLinearSuccPredArch`"), but the mathematical justification for the ban was that `succ_cofinal` (task 129) was assumed unprovable. If task 129 CAN be closed, Approach C is by far the cheapest path.

---

## 4. Alternative Strategies: Concrete Proposals

### Proposal 1: Simplified Phase 4 via Discrete Transfer (Approach B)

Replace the 20-30 hour GHR93 proof with a targeted discrete expressiveness transfer.

**Step 1**: Prove `discrete_expressiveness_transfer` (~150-250 lines total):
- Use `US_expressively_complete_over_Z` to get temporal formula A equivalent to psi on Z
- Prove A is box-free (track through separation machinery, ~40-60 lines)
- Prove `int_truth <-> temporal_truth` for box-free formulas (~30-50 lines)
- Prove pointed NF realization: for (M, t) with M discrete no-endpoints, find (Z, s) with same pointed k-type. Use depth-bumping trick via `truth_transfer` (~50-80 lines)
- Assemble the transfer chain (~30 lines)

**Step 2**: Prove Reynolds Lemmas 6-13 and Theorem 14 (~200-300 lines):
- Use `discrete_expressiveness_transfer` wherever Reynolds uses Theorem 5
- The argument simplifies in discrete orders (K+ is always false, intervals have successor/predecessor structure)

**Step 3**: Close `cofinal_decomposition_k_equiv` and `ordered_sum_of_good_bounded_is_good` (~200-400 lines):
- These are needed for `very_good_implies_good` regardless of approach
- The NF-preservation argument for cofinal decomposition
- The shift-and-glue construction for ordered sums of bounded Z-intervals

**Step 4**: Wire up Phases 8-10 as in the plan.

**Total effort**: 12-20 hours (vs 20-30 for full GHR93)

**Risk**: The `int_truth / temporal_truth` bridge (the box-freedom proof) is the main uncertainty. Report 06 rated this as LOW-MEDIUM risk.

### Proposal 2: Bypass No-Gaps Entirely (Approach C)

If task 129 (`succ_cofinal`) can be closed, the entire `no_gaps_discrete -> one_class -> very_good_implies_good` chain becomes unnecessary for the pipeline.

**Step 1**: Close `succ_cofinal` (task 129) -- effort unknown, needs separate assessment

**Step 2**: Close `h_truth_corr` (Transfer.lean:574, ~40-80 lines):
- Construct TaskModel where `truth_at` matches `temporal_truth`
- Use `chronicle_temporal_truth` (Phase 1, sorry-free) + S5 single-class + box transparency from singleton Omega
- This is Phase 9 Task 9.5 in the current plan

**Total effort**: Depends entirely on task 129. If task 129 is tractable (say 4-8 hours), this is the cheapest path by far (total 6-12 hours). If task 129 is fundamentally blocked, this approach is unavailable.

**Risk**: High if task 129 is genuinely hard. The plan says "NEVER use orderIsoIntOfLinearSuccPredArch" based on the assessment that `succ_cofinal` is unprovable. This assessment should be re-examined.

### Proposal 3: Hybrid -- Close h_truth_corr First, Then Reynolds

Regardless of which approach is taken for `no_gaps_discrete`, `h_truth_corr` at Transfer.lean:574 needs to be closed. This is independent work that can proceed immediately.

**Step 1**: Close `h_truth_corr` (~40-80 lines, immediate)
**Step 2**: Then decide between Proposal 1 or 2 for the `IsSuccArchimedean` sorry

---

## 5. Revised Phase Recommendations

### What Should Change in the Plan

1. **Phase 4 should be dramatically reduced in scope.** Replace the 20-30 hour GHR93 game proof with either:
   - (a) The discrete expressiveness transfer (Proposal 1, ~6-10 hours for the transfer lemma itself), OR
   - (b) Dropping Phase 4 entirely if task 129 can be closed (Proposal 2)

2. **Phase 5 is already DONE.** `flatten_stavi_correct` is sorry-free. No changes needed.

3. **Phase 6 (Gap Elimination) should use `discrete_expressiveness_transfer` instead of `stavi_expressive_completeness`.** The Reynolds Lemmas 6-13 argument works identically -- the only change is the source of expressive completeness.

4. **Phase 7 (IntegerModel helpers) is independent** and can proceed in parallel. However, it is ONLY needed if the plan retains the `one_class + very_good_implies_good` route. Under Proposal 2 (Approach C), Phase 7 is not on the critical path.

5. **Phase 9 Task 9.5 (h_truth_corr) should be promoted to an early phase.** It is the ONLY direct sorry in `countermodel_discrete` and is independent of all other work.

6. **The `stavi_expressive_completeness` sorry in EFGames.lean can be LEFT sorry'd.** It is not called by anything. It was created as a placeholder for the full GHR93 proof, which is no longer needed. It can remain as a future work item.

### Recommended Phase Structure (Revised)

| Phase | Content | Effort | Dependencies | Status |
|-------|---------|--------|--------------|--------|
| 1-3 | (Already completed) | -- | -- | COMPLETED |
| 4A | Stavi connectives | -- | -- | COMPLETED |
| NEW-A | Close `h_truth_corr` (Transfer.lean:574) | 3-5 hours | None | NOT STARTED |
| NEW-B | Discrete expressiveness transfer | 6-10 hours | None | NOT STARTED |
| 6 | Gap Elimination (Lemmas 6-13, Theorem 14) | 8-12 hours | NEW-B | NOT STARTED |
| 7 | IntegerModel helpers (cofinal_decomp, ordered_sum_good) | 5-8 hours | None | NOT STARTED |
| 8 | Wire no_gaps_discrete + one_class | 1-2 hours | 6, 7 | NOT STARTED |
| 9 | Rewrite chronicle_is_good, remove IsSuccArchimedean | 3-5 hours | 7, 8 | NOT STARTED |
| 10 | Final verification | 1-2 hours | 9, NEW-A | NOT STARTED |

**Total revised effort**: 27-44 hours (vs 55-65 in v5 plan)
**Critical path**: NEW-A -> NEW-B -> 6 -> 8 -> 9 -> 10 (or NEW-A -> 7 in parallel)

### Alternative: If Task 129 Is Closable

| Phase | Content | Effort | Dependencies |
|-------|---------|--------|--------------|
| 1-3, 4A, 5 | (Already completed) | -- | -- |
| NEW-A | Close `h_truth_corr` | 3-5 hours | None |
| NEW-C | Close `succ_cofinal` (task 129) | 4-8 hours (estimate) | None |
| 10 | Final verification | 1-2 hours | NEW-A, NEW-C |

**Total effort**: 8-15 hours. Phases 4B-9 become unnecessary.

---

## 6. Effort Estimates

### Discrete Expressiveness Transfer (Proposal 1)

| Component | Lines | Hours | Confidence |
|-----------|-------|-------|-----------|
| Box-freedom of separation output | 40-60 | 1-2 | HIGH |
| int_truth / temporal_truth bridge for box-free formulas | 30-50 | 1-2 | HIGH |
| Pointed NF realization (depth-bumping) | 50-80 | 2-3 | MEDIUM |
| Transfer lemma assembly | 30-50 | 1-2 | HIGH |
| **Subtotal (discrete transfer)** | **150-240** | **5-9** | |
| Reynolds Lemmas 6-13 + Theorem 14 | 200-300 | 8-12 | MEDIUM-LOW |
| cofinal_decomposition_k_equiv | 100-200 | 3-5 | MEDIUM |
| ordered_sum_of_good_bounded_is_good | 100-200 | 3-5 | MEDIUM |
| h_truth_corr (Transfer.lean:574) | 40-80 | 2-4 | MEDIUM |
| Rewrite chronicle_is_good + remove IsSuccArchimedean | 40-80 | 2-3 | MEDIUM |
| Wire no_gaps_discrete + one_class | 20-40 | 1-2 | HIGH |
| Final verification | -- | 1-2 | HIGH |
| **GRAND TOTAL** | **650-1170** | **25-42** | |

### Full GHR93 Approach (Plan v5 Phase 4 as written)

| Component | Lines | Hours | Confidence |
|-----------|-------|-------|-----------|
| EF game infrastructure (Sub-stage 4B) | 800-1200 | 10-15 | LOW |
| Main Theorem 4 proof (Sub-stage 4C) | 1000-1500 | 10-15 | LOW |
| Reynolds Lemmas 6-13 + Theorem 14 | 200-300 | 8-12 | MEDIUM-LOW |
| Remaining phases (7-10) | same as above | 12-19 | MEDIUM |
| **GRAND TOTAL** | **2200-3300** | **40-61** | |

### Task 129 Bypass (Proposal 2)

| Component | Lines | Hours | Confidence |
|-----------|-------|-------|-----------|
| Close succ_cofinal | unknown | 4-8 (?) | UNKNOWN |
| h_truth_corr | 40-80 | 2-4 | MEDIUM |
| Final verification | -- | 1-2 | HIGH |
| **GRAND TOTAL** | **40-80+** | **7-14** | **HIGHLY UNCERTAIN** |

---

## 7. Key Observations

### Observation 1: stavi_expressive_completeness Is Disconnected

The sorry'd `stavi_expressive_completeness` in EFGames.lean is not called by any other code. It was placed there as a target for the full GHR93 proof. The downstream pipeline does not reference it. The plan's Phase 6 says it needs "Theorem 5" (`US_expressively_complete_over_prior`), but this theorem does not exist in the codebase either -- it would need to be built from `stavi_expressive_completeness` + `flatten_stavi_correct`.

This means the plan has a gap: even if `stavi_expressive_completeness` were proved, there is no existing wiring from it to `no_gaps_discrete`. The wiring would need to be built as part of Phase 6.

### Observation 2: The Two Sorry Sources Are Independent

The `h_truth_corr` sorry (Transfer.lean:574) and the `IsSuccArchimedean` sorry (via `succ_cofinal`) are completely independent. Closing either one partially improves the pipeline. Closing `h_truth_corr` first is recommended because:
- It is smaller (~40-80 lines)
- It does not depend on any other sorry
- It makes progress regardless of which approach is taken for the `IsSuccArchimedean` issue

### Observation 3: The Plan's "NEVER use orderIsoIntOfLinearSuccPredArch" Constraint Drives Most Complexity

The ban on `orderIsoIntOfLinearSuccPredArch` is what creates the need for the entire `no_gaps_discrete -> one_class -> very_good_implies_good -> cofinal_decomposition_k_equiv + ordered_sum_of_good_bounded_is_good` chain. Without this ban, `chronicle_is_good` already works (modulo `succ_cofinal`).

The ban was imposed because `succ_cofinal` (task 129) was assessed as unprovable. If this assessment is wrong, the ban should be reconsidered.

### Observation 4: Phase 5 Result Enables a Simplified Phase 6

`flatten_stavi_correct` proves that in discrete orders, every StaviFormula has an equivalent standard temporal Formula. This means that IF `stavi_expressive_completeness` were proved (even as an oracle/axiom), Phase 6 could immediately get the temporal formula R it needs by composing:

```
rho(x) [monadic FO] -> stavi_expressive_completeness -> StaviFormula
                      -> flatten_stavi -> Formula R
                      -> flatten_stavi_correct: R equivalent to rho in discrete orders
```

This composition is well-typed and would take approximately 10-20 lines of wiring.

### Observation 5: The int_truth/temporal_truth Gap Is Real but Bridgeable

Report 06 identified that `int_truth` treats `.box` as `True` while `temporal_truth` treats it as a predicate lookup. The separation machinery never produces box-containing formulas, so the gap is bridgeable by proving box-freedom. This is approximately 40-60 lines of tracking through the separation construction, plus 30 lines for the correspondence theorem on box-free formulas.

---

## 8. Recommendation

**Primary recommendation**: Adopt Proposal 1 (Discrete Expressiveness Transfer) as the revised approach for Phase 4. This replaces the 20-30 hour GHR93 game proof with a 6-10 hour transfer argument that is sufficient for the pipeline.

**Secondary recommendation**: Close `h_truth_corr` (Transfer.lean:574) as the first action item, since it is independent and on the critical path.

**Tertiary recommendation**: Separately assess the feasibility of closing `succ_cofinal` (task 129). If feasible, Proposal 2 (bypass) would dramatically reduce the remaining work.

The `stavi_expressive_completeness` sorry in EFGames.lean should remain sorry'd. It is a standalone mathematical result (valuable in its own right) that can be pursued as a separate, non-blocking task.
