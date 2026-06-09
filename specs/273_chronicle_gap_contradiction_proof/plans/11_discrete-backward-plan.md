# Implementation Plan: Discrete Backward Direction via Game Pipeline (v11)

- **Task**: 273 - Eliminate sorryAx from `completeness_discrete` via discrete backward direction proof
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (Phases 0-3 from v10 completed; game pipeline sorry-free)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/07_sorry-chain-verification.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_game-pipeline-research.md
- **Artifacts**: plans/11_discrete-backward-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan (v11) addresses the sole remaining sorry blocking `completeness_discrete`: the backward direction at DiscreteStaviCompleteness.lean:338 (`discrete_nf_characterizable_by_stavi`). Research report 07 confirmed there is exactly ONE sorry chain: `completeness_discrete` -> `US_expressively_complete_over_prior` -> `stavi_expressive_completeness` -> `nf_exist_sf_guarded_backward`. Report 08 verified that the entire discrete game pipeline (`discrete_nf_to_decomposition_agreement`, `ghr93_decomposition_implies_game`, `discrete_ghr93_proposition7`, `nf_fraisse_compression`) is sorry-free. The plan closes the sorry at line 338 by proving `discrete_nf_exist_sf_guarded_backward` using this pipeline, then wires `discrete_stavi_expressive_completeness` into `US_expressively_complete_over_prior` at PriorExpressiveness.lean:384, making `completeness_discrete` sorry-free. Done is: `lean_verify completeness_discrete` shows no `sorryAx`.

### Research Integration

Reports integrated:
- `07_sorry-chain-verification.md`: Confirmed single sorry chain, identified `nf_exist_sf_guarded_backward` as root sorry, verified `chronicle_gap_contradiction` is NOT on the critical path
- `08_game-pipeline-research.md`: Verified all discrete pipeline components sorry-free, identified two approaches (A: direct induction via zone_match_witness, B: full game pipeline), provided type signatures and effort estimates for missing components

### Prior Plan Reference

Plan v10 (`10_uniform-rank-reformulation-plan.md`) completed Phases 0-3 (axiom audit, SemanticBridge, Theorem 6 reformulation, Proposition 7) and was BLOCKED at Phase 4 (bridging game wins to the leaf sorry). Key lessons from v10:
- Phases 0-3 are validated and complete -- do not repeat
- The `h_r1_univ` threading complexity was the Phase 4 blocker
- `discrete_ghr93_proposition7` is now sorry-free (Phase 3 success)
- DiscreteStaviCompleteness.lean already has the scaffolding (forward direction sorry-free, sorry only at line 338 backward direction)

This plan does NOT copy v10 Phase 4 tasks verbatim. Instead it restructures the approach based on Report 08's analysis, using a hybrid approach that constructs `discrete_bridge_hyps_to_univ_decomp` plus the game pipeline to close the sorry.

### Roadmap Alignment

- "Sorry-free `completeness_discrete`" -- this task directly advances the critical path
- "EF-game expressiveness infrastructure" -- this plan completes the final connection from game wins to NF equality for the backward direction

## Goals & Non-Goals

**Goals**:
- Close the sorry at DiscreteStaviCompleteness.lean:338 (backward direction of `discrete_nf_characterizable_by_stavi`)
- Make `discrete_stavi_expressive_completeness` sorry-free
- Wire `discrete_stavi_expressive_completeness` into `US_expressively_complete_over_prior` (PriorExpressiveness.lean:384)
- Achieve sorry-free `completeness_discrete` end-to-end

**Non-Goals**:
- Proving the general (non-discrete) `nf_exist_sf_guarded_backward` at StaviCompleteness.lean:2805
- Filling dead-code sorry sites at StaviCompleteness.lean:2353/2435 (`nf_2var_existential_transfer`)
- Implementing Cases III/IV of general Theorem 6 (CaseAnalysis.lean)
- Modifying `stavi_expressive_completeness` (general version retains sorry)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula extraction from `h_sf` is more complex than estimated due to `nf_exist_sf_guarded` encoding | M | M | The formula is built from `nf_exist_sf_guarded` which encodes ordering + atom agreement + interval guard. Case analysis on `nf_order_0_1 sub_nf` (3 cases: Until/Since/equal) is well-structured. |
| Reference model construction: finding M_ref where `sub_nf` is realized | M | L | `nf_characteristic_satisfies` provides forward direction; use `Classical.choice` on realizability. Every NormalForm is realizable by the Henkin construction already in the codebase. |
| Interval type heredity for sub-intervals in discrete orders | H | M | In discrete orders, `(a, t) subset (x, t)` when `x <= a <= t`, so interval NF types are a subset. Equality of types follows from `zone_match_witness` applied to sub-intervals. Factor the proof into a standalone heredity lemma. |
| `h_r1_univ` construction from decomposition agreement | H | M | Use `discrete_nf_to_decomposition_agreement` at rank `r+2` directly. For discrete orders, all elements are carrier points, so rank lifting is trivial. Fallback: construct from `stavi_truth_mu_at_point` rank-independence. |
| Type mismatches between `ExtendedCarrier` ranks in pipeline composition | M | M | `discrete_rank_embed_eq_drc` (sorry-free) handles rank conversion. Use `rw`/`conv` for type-level plumbing. |
| Prior structures satisfy discrete typeclass instances | L | L | Prior structures have SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, IsSuccArchimedean by construction. These instances should be available or trivially provable. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential because each phase builds on the prior one.

---

### Phase 1: Formula Extraction and Reference Model [NOT STARTED]

**Goal**: Extract the structural data (witness x, ordering, interval guard, NF types) from the formula truth hypothesis `h_sf`, and construct a reference model M_ref realizing `sub_nf`.

**Tasks**:
- [ ] **Task 1.1**: Prove `discrete_extract_formula_witness` -- given `h_sf : stavi_temporal_truth N atomMap t (nf_exist_sf_guarded ...)`, extract witness `x`, its 1-var NF agreement, ordering relative to t, and interval guard data. Case-split on `nf_order_0_1 sub_nf` (Until: `t < x`, Since: `x < t`, equal: `x = t`).
  - **File**: `DiscreteStaviCompleteness.lean`
  - **Estimated size**: 100-150 lines

- [ ] **Task 1.2**: Prove `nf_realizable` or find existing infrastructure -- for any `sub_nf : NormalForm sig k 2`, there exist a model M_ref and points (x_ref, t_ref) such that `nf_eval_nf M_ref k 2 (Fin.cons x_ref (fun _ => t_ref)) sub_nf`. Use `Classical.choice` on the constructive content already present in the NF framework (every NF is the characteristic of some configuration).
  - **File**: `DiscreteStaviCompleteness.lean` or `StaviCompleteness.lean`
  - **Estimated size**: 50-100 lines

- [ ] **Task 1.3**: Verify formula extraction compiles and the extracted data matches the types needed by the bridge hypotheses in Phase 2.
  - `lean_goal` at the sorry site after extraction to confirm goal shape

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean` -- add formula extraction lemma

**Verification**:
- `lean_goal` confirms extracted witness and structural data are well-typed
- No new sorries introduced

---

### Phase 2: Bridge Hypothesis Assembly and Heredity [NOT STARTED]

**Goal**: Assemble the bridge hypotheses (1-var NF agreement, ordering, interval type equality, above-max/below-min types) between the concrete model N and the reference model M_ref, and prove the discrete interval type heredity lemma needed by `discrete_bridge_hyps_to_univ_decomp`.

**Tasks**:
- [ ] **Task 2.1**: Prove `discrete_interval_type_hereditary` -- in discrete orders, if (x, t) has interval NF types T, and a is between x and t, then the interval types of (a, t) are a subset of T (and equality holds via zone_match_witness matching).
  - **File**: `DiscreteStaviCompleteness.lean`
  - **Estimated size**: 80-120 lines

- [ ] **Task 2.2**: Prove `discrete_bridge_hyps_assembly` -- from the formula-extracted data (Task 1.1) and reference model (Task 1.2), construct the full set of bridge hypotheses: `h_nf_x` (1-var NF at x matches x_ref), `h_nf_t` (1-var NF at t matches t_ref), `h_order_xt` (ordering agreement), `h_interval_types` (interval type equality between N and M_ref), `h_above_max`/`h_below_min`.
  - **File**: `DiscreteStaviCompleteness.lean`
  - **Estimated size**: 100-150 lines

- [ ] **Task 2.3**: Prove `discrete_bridge_hyps_to_univ_decomp` -- from NF bridge hypotheses at (x,t)/(x_ref,t_ref), construct `discrete_universal_decomp` for all sub-intervals. Uses Task 2.1 heredity to show bridge hypotheses pass down to sub-intervals.
  - **File**: `DiscreteStaviCompleteness.lean`
  - **Estimated size**: 150-200 lines

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean` -- add bridge hypothesis lemmas

**Verification**:
- `lean_goal` confirms `discrete_universal_decomp` is constructible from bridge hypotheses
- `lean_verify discrete_bridge_hyps_to_univ_decomp` shows no sorry (once complete)

---

### Phase 3: Close the Sorry via Game Pipeline [NOT STARTED]

**Goal**: Complete the backward direction proof at line 338 by composing: formula extraction (Phase 1) -> bridge hypotheses (Phase 2) -> decomposition agreement -> game wins -> NF equality via `nf_fraisse_compression`.

**Tasks**:
- [ ] **Task 3.1**: Prove `discrete_h_r1_univ_from_decomposition` -- construct the `h_r1_univ` hypothesis needed by `discrete_ghr93_theorem6` from decomposition agreement. For discrete orders, decomposition at rank r implies decomposition at rank r+2 because all elements are carrier points.
  - **File**: `DiscreteStaviCompleteness.lean`
  - **Estimated size**: 40-80 lines

- [ ] **Task 3.2**: Complete the sorry at line 338 by assembling the full pipeline:
  1. Extract witness x and structural data from h_sf (Task 1.1)
  2. Construct reference model M_ref realizing sub_nf (Task 1.2)
  3. Assemble bridge hypotheses (Task 2.2)
  4. Apply `discrete_nf_to_decomposition_agreement` to get decomposition agreement
  5. Apply `ghr93_decomposition_implies_game` to get forward game wins
  6. Construct h_r1_univ (Task 3.1)
  7. Apply `discrete_ghr93_proposition7` to get standard EF game wins at sufficient rounds
  8. Apply `nf_fraisse_compression` to get 2-var NF equality
  9. Conclude `sub_nf` is the 2-var NF of (x, t), proving the existential
  - **File**: `DiscreteStaviCompleteness.lean` (replace sorry at line 338)
  - **Estimated size**: 80-120 lines

- [ ] **Task 3.3**: Verify `discrete_nf_characterizable_by_stavi` is sorry-free
  - `lean_verify discrete_nf_characterizable_by_stavi` -- no sorryAx

- [ ] **Task 3.4**: Verify `discrete_stavi_expressive_completeness` is sorry-free
  - `lean_verify discrete_stavi_expressive_completeness` -- no sorryAx

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean` -- replace sorry at line 338 with full proof

**Verification**:
- `lean_verify discrete_nf_characterizable_by_stavi` -- no sorryAx
- `lean_verify discrete_stavi_expressive_completeness` -- no sorryAx
- Zero sorry sites in DiscreteStaviCompleteness.lean

---

### Phase 4: Wire Discrete Chain and Full Verification [NOT STARTED]

**Goal**: Replace `stavi_expressive_completeness` with `discrete_stavi_expressive_completeness` in `US_expressively_complete_over_prior`, then verify `completeness_discrete` is sorry-free end-to-end.

**Tasks**:
- [ ] **Task 4.1**: Modify `US_expressively_complete_over_prior` (PriorExpressiveness.lean:384) to call `discrete_stavi_expressive_completeness` instead of `stavi_expressive_completeness`. Prior structures satisfy all 5 discrete typeclass instances (SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, IsSuccArchimedean). Add import of DiscreteStaviCompleteness if not already present.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean`
  - **Estimated size**: 5-15 lines changed

- [ ] **Task 4.2**: Verify the full sorry chain is eliminated:
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx
  - `lean_verify gap_prior_UZ_contradiction` -- no sorryAx
  - `lean_verify no_gaps_discrete_model_surgery` -- no sorryAx
  - `lean_verify completeness_discrete` -- no sorryAx (or sorryAx only through non-273 chains)

- [ ] **Task 4.3**: Full build verification:
  - `lake build` passes without errors
  - `lake build BimodalTest` passes
  - No import cycles introduced
  - `grep -rn "sorry" DiscreteStaviCompleteness.lean` returns zero hits
  - `stavi_expressive_completeness` (general) retains sorry (expected, non-goal)

- [ ] **Task 4.4**: Verify no regressions in files that import PriorExpressiveness:
  - GoodStructuresModelSurgery.lean compiles
  - ReynoldsBridge.lean compiles
  - Completeness.lean compiles

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- change line 384 to use `discrete_stavi_expressive_completeness`

**Verification**:
- `lean_verify completeness_discrete` -- no sorryAx (primary success criterion)
- `lake build` passes
- No new sorry introduced anywhere

---

## Testing & Validation

- [ ] `lean_verify discrete_nf_characterizable_by_stavi` -- no sorryAx
- [ ] `lean_verify discrete_stavi_expressive_completeness` -- no sorryAx
- [ ] `lean_verify US_expressively_complete_over_prior` -- no sorryAx
- [ ] `lean_verify gap_prior_UZ_contradiction` -- no sorryAx
- [ ] `lean_verify completeness_discrete` -- no sorryAx
- [ ] `lake build` passes without errors
- [ ] `lake build BimodalTest` passes
- [ ] No import cycles
- [ ] Zero sorry sites in DiscreteStaviCompleteness.lean
- [ ] GoodStructuresModelSurgery.lean compiles unchanged
- [ ] `stavi_expressive_completeness` (general) retains sorry (expected)

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/07_discrete-backward-plan.md` (this file, v11)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteStaviCompleteness.lean` (300-600 new lines replacing 1 sorry)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 lines changed at line 384)
- `specs/273_chronicle_gap_contradiction_proof/summaries/07_discrete-backward-summary.md`

## Rollback/Contingency

- **If `discrete_bridge_hyps_to_univ_decomp` proves too complex**: Fall back to Report 08's "Alternative" approach -- prove `discrete_nf_2var_existential_transfer` directly by strong induction on j using `zone_match_witness` at each level. This avoids the full game pipeline and `discrete_universal_decomp` entirely, at cost of ~300-500 lines of different proof structure.

- **If reference model construction (Task 1.2) lacks infrastructure**: Construct a canonical discrete model explicitly (integers with predicate assignment matching sub_nf). This is more work (~100-150 lines) but self-contained.

- **If `h_r1_univ` construction (Task 3.1) fails due to rank lifting**: Use `stavi_truth_mu_at_point` rank-independence for discrete orders to construct forward games at arbitrary ranks from games at the base rank.

- **If Prior structure typeclass instances are not available**: Prove the 5 instances (SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, IsSuccArchimedean) for Prior structures directly. These should follow from the definition of Prior structures as discrete linear orders without endpoints.

- **Git revert** to current commit (`b9ad4fa85`) if any phase introduces regressions.
