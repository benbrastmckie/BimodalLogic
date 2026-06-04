# Implementation Plan: Task #155 -- NF-Game Bridge (Revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: None (all EF game infrastructure is sorry-free)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/65_post-281-assessment.md, specs/155_reynolds_pipeline_activation/handoffs/phase-1-handoff-20260604.md
- **Artifacts**: plans/66_nf-game-bridge-revised.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the last sorry root (`nf_2var_existential_transfer` at StaviCompleteness.lean lines 2347/2429) by routing the proof through the sorry-free EF game machinery. This is a revision of plan 65, which was blocked during Phase 1 implementation because all five direct approaches failed due to the sub-interval splitting problem. The root cause: `nf_2var_existential_transfer` lacks the `char_k` parameter needed to connect NF data to the EF game infrastructure. This revised plan adds a new Phase 0 to refactor the theorem signatures, unblocking the bridge construction.

### Research Integration

From report `65_post-281-assessment.md`:
- ONE independent sorry root: `nf_2var_existential_transfer` (lines 2347, 2429)
- Downstream sorry: `nf_exist_sf_guarded_backward` (line 2787) resolves automatically
- Full sorry chain: `nf_2var_existential_transfer` -> `nf_characterizable_by_stavi` -> `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> `gap_prior_UZ_contradiction` -> `no_gaps_discrete_model_surgery` -> `limitdom_is_good` -> `countermodel_discrete_reynolds_v2` -> `completeness_discrete`
- Sorry-free infrastructure: `ghr93_duplicator_wins`, `ghr93_strategy_compose`, `decomposition_agreement`, `nf_fraisse_compression`

From handoff `phase-1-handoff-20260604.md`:
- All direct NF induction approaches fail (strong induction on j, on k, splitting zone match, nf_fraisse_compression at lower depth)
- The sub-interval splitting problem is fundamental: zone-matched inner points do NOT preserve sub-interval types
- `char_k` IS available in ALL calling contexts (from `nf_characterizable_by_stavi` IH at depth k+1)
- Adding `atomMap`, `char_k`, `char_k_correct` as parameters breaks no circularity
- Bridge A (NF to decomposition_agreement) becomes straightforward with char_k
- Bridge B (game winning condition to NF transfer) uses char_k_correct in reverse

### Prior Plan Reference

Revision of `plans/65_nf-game-bridge-plan.md`, which was blocked at Phase 1 due to missing `char_k` parameter.

## Goals & Non-Goals

**Goals**:
- Add `atomMap`, `char_k`, `char_k_correct` parameters to `nf_2var_existential_transfer` and `nf_2var_from_interval_data`
- Prove `nf_2var_existential_transfer` by routing through EF game machinery
- Eliminate all `sorryAx` from `completeness_discrete`
- Verify `#print axioms completeness_discrete` shows no `sorryAx`

**Non-Goals**:
- Fixing non-critical-path sorry sites (BXCanonical, Bundle, Algebraic, etc.)
- Refactoring the EF game infrastructure
- Optimizing proof performance or compile times
- Alternative proof strategies (direct NF induction has been ruled out by 5 failed attempts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Signature change breaks downstream callers in unexpected ways | M | L | All callers already have char_k in scope (verified in handoff analysis); propagation is mechanical |
| rank_type on ExtendedCarrier vs nf_characteristic on M.carrier type mismatch in Bridge A | H | M | char_k_correct provides the bidirectional bridge: nf_eval_nf <-> stavi_temporal_truth; rank_type is defined via stavi_temporal_truth_mu, and stavi_truth_mu_at_point connects mu-truth to standard truth at actual points |
| decomposition_agreement requires ExtendedCarrier endpoints but nf_2var_existential_transfer works on M.carrier | M | M | Use extendPoint embedding for actual points; the game infrastructure already handles this via IsPoint/mu_holds predicates |
| Converting interval_nf_types (Finset NormalForm) to interval_types (Set (Set StaviFormula)) is non-trivial | H | M | char_k maps each NormalForm to a StaviFormula; rank_type at extendPoint(u) collects all StaviFormulas true at u; char_k_correct ensures nf_eval_nf <-> membership in rank_type; build the conversion pointwise |
| Proof exceeds estimated line count due to Fin/environment manipulation boilerplate | M | M | Phase 0 builds reusable infrastructure; NFGameBridge.lean already has helper lemmas to minimize boilerplate |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 0: Signature Refactoring -- Add char_k Parameters [COMPLETED]

**Goal**: Add `atomMap`, `char_k`, and `char_k_correct` as parameters to `nf_2var_existential_transfer` and `nf_2var_from_interval_data`, and propagate the changes through all callers. This unblocks the game-theoretic proof strategy by making the NF-to-StaviFormula bridge available inside the sorry sites.

**Tasks**:
- [ ] Add parameters `(atomMap : Formula -> sig.preds)`, `(char_k : NormalForm sig k 1 -> StaviFormula)`, and `(char_k_correct : forall (nf_k : NormalForm sig k 1) (N : OrderedMonadicStructure sig) (t : N.carrier), stavi_temporal_truth N atomMap t (char_k nf_k) <-> nf_eval_nf N k 1 (fun _ => t) nf_k)` to `nf_2var_existential_transfer` (line 2214)
- [ ] Add the same three parameters to `nf_2var_from_interval_data` (line 2442)
- [ ] Update the call to `nf_2var_existential_transfer` inside `nf_2var_from_interval_data` (line 2507) to pass the new parameters
- [ ] Update `nf_2var_transfer` (line 2512) to accept and pass the new parameters
- [ ] Update the call chain from `nf_exist_sf_guarded_backward` (line 2760) -- this already has `atomMap`, `char_k`, `char_k_correct` in scope as function parameters
- [ ] Update `nf_2var_exist_sf_classical` (line 2792) if it calls `nf_2var_from_interval_data` -- it already has `char_k` and `char_k_correct` in scope
- [ ] Update `nf_2var_existence_characterizable` (line 2829) -- already has `char_k` and `char_k_correct` in scope from its own parameters
- [ ] Verify build succeeds: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` (sorries still present but no new errors)
- [ ] Verify build succeeds: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` (imports StaviCompleteness)

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- signature changes and caller updates (~30-50 lines modified)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds with only the existing sorry warnings
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No new sorry sites introduced
- All callers of `nf_2var_existential_transfer` and `nf_2var_from_interval_data` pass the new parameters correctly

---

### Phase 1: Bridge A -- NF Hypotheses to decomposition_agreement [NOT STARTED]

**Goal**: Build the conversion from `nf_2var_existential_transfer` hypotheses (1-var NF agreement, ordering, interval_nf_types agreement) into `decomposition_agreement` on ExtendedCarrier, suitable as input to `ghr93_decomposition_implies_game`. With `char_k` now available (from Phase 0), the NF-to-StaviFormula conversion is direct.

**Tasks**:
- [ ] Prove `nf_char_to_rank_type_eq`: if `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` then `rank_type M atomMap k (extendPoint x) = rank_type N atomMap k (extendPoint x')`. Strategy: rank_type is a set of StaviFormulas with depth <= k true at the point; use `char_k_correct` to show NF agreement implies agreement on all char_k images, then use the fact that char_k formulas span all depth-k NFs to get agreement on all StaviFormulas of depth <= k. Use `stavi_truth_mu_at_point` to connect mu-truth to standard truth.
- [ ] Prove `interval_nf_types_to_interval_types`: convert `interval_nf_types M k lo hi = interval_nf_types M' k lo' hi'` to `interval_types M atomMap k (extendPoint lo) (extendPoint hi) = interval_types N atomMap k (extendPoint lo') (extendPoint hi')`. Strategy: interval_nf_types collects realized NormalForms; interval_types collects realized rank_types; char_k provides the bijective correspondence; show that a type tau in interval_types corresponds to a unique NF via char_k_correct.
- [ ] Prove `nf_hypotheses_to_decomposition_agreement`: the master theorem combining the above to produce `decomposition_agreement M N atomMap n k (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')` from the hypotheses of `nf_2var_existential_transfer`. This requires: (a) boundary rank_type agreement from `nf_char_to_rank_type_eq`, (b) interval type agreement from `interval_nf_types_to_interval_types`, (c) forward/backward selection matching from (b) using the selection lemma structure of decomposition_agreement, (d) point challenge from zone matching + rank_type agreement.
- [ ] Verify intermediate lemmas compile: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2.5 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add Bridge A lemmas (~150-200 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No new sorry sites introduced
- `nf_hypotheses_to_decomposition_agreement` type-checks with correct signature matching `decomposition_agreement`

---

### Phase 2: Bridge B -- Game Agreement to NF Existential Transfer [NOT STARTED]

**Goal**: Convert the Duplicator's winning strategy (from `ghr93_duplicator_wins` via `ghr93_decomposition_implies_game`) back into the existential transfer statement needed by `nf_2var_existential_transfer`. This is the reverse direction: game agreement implies that for any witness u in M, there exists a matching u' in M' with the same depth-j (n+1)-var NF.

**Tasks**:
- [ ] Prove `game_wins_to_point_matching`: from `ghr93_duplicator_wins` at parameters (n=1, r=k), extract that for any actual point u in [x,t], there exists u' in [x',t'] with (a) matching rank_type at rank k, (b) correct ordering relative to x', t', and (c) formula_agreement at all positions. Strategy: instantiate the game with a = (fun _ => extendPoint u) as Spoiler's single selection; Duplicator responds with a'; use the point challenge round to get the matching actual point.
- [ ] Prove `formula_agree_to_nf_agree`: if two actual points have formula_agreement at rank k (i.e., agree on all StaviFormulas of depth <= k), then their depth-j 1-var NFs agree for j <= k. Strategy: use `char_k_correct` in reverse -- for each NF nf_j of depth j <= k, `char_k` (applied after nf_agreement_monotone) gives a StaviFormula; formula_agreement transfers it; `char_k_correct` converts back.
- [ ] Prove `game_wins_to_nf_existential_transfer`: the master theorem -- from `ghr93_duplicator_wins` at parameters suitable for 2-var NF, conclude that the existential transfer holds at every depth j < k. Specifically: given the hypotheses of `nf_2var_existential_transfer` plus `char_k`/`char_k_correct`, and given any witness u in M satisfying nf_eval_nf at depth j, produce u' in M' satisfying the same NF. Strategy: (a) apply `game_wins_to_point_matching` to get u' with formula_agreement, (b) use `formula_agree_to_nf_agree` to get 1-var NF agreement at depth k, (c) derive ordering agreement from game's order_type preservation, (d) combine atoms + quantifier transfer: atoms from pointwise agreement; for quantifier at depth j-1, recurse via the game at the 3-point configuration (u,x,t)/(u',x',t'), which has decomposition_agreement inherited from the winning condition.
- [ ] Handle the depth-0 base case separately (atoms only, no quantifier transfer needed)
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add Bridge B lemmas (~100-150 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- `game_wins_to_nf_existential_transfer` has a conclusion type matching the goal at the sorry sites in `nf_2var_existential_transfer`
- No new sorry sites

---

### Phase 3: Replace Sorries in nf_2var_existential_transfer [NOT STARTED]

**Goal**: Replace the two `sorry` calls in `nf_2var_existential_transfer` (lines 2347 and 2429) with proofs that route through Bridge A -> `ghr93_decomposition_implies_game` -> Bridge B. Also verify the downstream sorry in `nf_exist_sf_guarded_backward` (line 2787) resolves.

**Tasks**:
- [ ] Replace sorry at line 2347 (forward direction, `j' + 1` case): the goal is 4-var existential transfer at depth j' for (u,x,t)/(u',x',t'). Apply `nf_hypotheses_to_decomposition_agreement` (Bridge A) to the 3-point configuration (u,x,t)/(u',x',t') to get `decomposition_agreement`, apply `ghr93_decomposition_implies_game` to get `ghr93_duplicator_wins`, then apply `game_wins_to_nf_existential_transfer` (Bridge B) to close the goal.
- [ ] Replace sorry at line 2429 (backward direction, `j' + 1` case): symmetric application using the reversed hypotheses (M' -> M direction). The backward direction already constructs u from zone matching; apply the same bridge sequence with structures swapped.
- [ ] Replace sorry at line 2787 (`nf_exist_sf_guarded_backward`): this sorry exists because `nf_2var_from_interval_data` was sorry'd. Now that `nf_2var_from_interval_data` calls `nf_2var_existential_transfer` (which will be proved), implement the backward direction using the bridge lemma. Extract witness x from the temporal formula, determine x's 1-var depth-k NF via char_k_correct, extract interval type data from the interval guard, and apply `nf_2var_transfer` (which uses `nf_2var_from_interval_data`) to conclude.
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` to confirm all three sorry sites are resolved
- [ ] Check `#print axioms nf_2var_existential_transfer` shows no `sorryAx`

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- replace sorry at lines 2347, 2429, 2787 (~30-50 lines each replacement)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds with no errors
- `grep -c "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` returns 0 (or only comment references)
- `#print axioms nf_2var_existential_transfer` shows no `sorryAx`
- `#print axioms nf_2var_from_interval_data` shows no `sorryAx`

---

### Phase 4: End-to-End Verification [NOT STARTED]

**Goal**: Verify that the entire sorry chain from `completeness_discrete` down through `stavi_expressive_completeness` is now sorry-free. Run full project build.

**Tasks**:
- [ ] Run `#print axioms completeness_discrete` and verify output is `propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound` (no `sorryAx`)
- [ ] Run `#print axioms stavi_expressive_completeness` and verify no `sorryAx`
- [ ] Run `#print axioms countermodel_discrete_reynolds_v2` and verify no `sorryAx`
- [ ] Run `lake build` (full project) and verify clean build
- [ ] Grep all EFGames files for remaining sorry: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` -- only comment references should remain

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds
- `#print axioms completeness_discrete` output matches target: `propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`
- No `sorryAx` in any theorem on the critical path

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_reynolds_v2` shows no `sorryAx`
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` returns no active sorry statements
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` returns no sorry statements

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/66_nf-game-bridge-revised.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extended with Bridge A + Bridge B, ~250-350 additional lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (signature refactoring + sorry sites replaced, ~100-150 lines changed)

## Rollback/Contingency

- If the signature refactoring (Phase 0) introduces unexpected downstream failures: the change is purely additive (new parameters), so revert the single file with `git checkout main -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`.
- If Bridge A type alignment proves harder than expected: fall back to building a custom game variant that operates on NormalForm types directly, bypassing the ExtendedCarrier conversion entirely. This approach is documented in NFGameBridge.lean comments.
- If Bridge B's quantifier transfer at the 3-point configuration requires deeper recursion: use well-founded recursion on `(k - j, n)` where n is the variable count, since each game round reduces depth by 1.
- If proof exceeds 500 lines: split NFGameBridge.lean into NFGameBridgeA.lean and NFGameBridgeB.lean to keep files manageable.
- Git revert: all changes are in two files (NFGameBridge.lean, StaviCompleteness.lean). Revert with `git checkout main -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`.
