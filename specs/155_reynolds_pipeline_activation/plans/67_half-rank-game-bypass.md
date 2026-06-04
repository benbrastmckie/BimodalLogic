# Implementation Plan: Task #155 -- Half-Rank Game Bypass

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all EF game infrastructure is sorry-free; Phase 0 from prior plan v66 is COMPLETED; 8 discrete infrastructure lemmas from plan v67 Phase 1 are COMPLETED)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/65_team-research.md, specs/155_reynolds_pipeline_activation/reports/66_depth-arithmetic.md, specs/155_reynolds_pipeline_activation/reports/67_depth-blocker-resolution.md
- **Artifacts**: plans/67_half-rank-game-bypass.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate all `sorryAx` from `completeness_discrete` by implementing the **half-rank game bypass** strategy for `nf_2var_existential_transfer`. The previous plan (v67, `65_discrete-game-bypass.md`) was blocked at Phase 1 because it claimed r = k suffices for discrete orders -- this is wrong. Report 67 (`67_depth-blocker-resolution.md`) definitively shows: (1) the 2x depth penalty does NOT vanish for discrete orders (report 66 section 4.5 was self-contradictory), (2) but r = floor(k/2) IS sufficient because Bridge B recovers full depth-k NF agreement from formula_agreement at rank floor(k/2). The corrected depth chain is: depth-k NF on sig --> depth-k NF on muSig (discrete: mu trivially true) --> nf_profile agreement at depth 2*(k/2) <= k --> game at rank k/2 --> formula_agreement at rank k/2 --> FO agreement at depth 2*(k/2) = k on muSig --> NF agreement at depth k on sig.

### Research Integration

- **Report 65** (`65_team-research.md`): 4-teammate unanimous confirmation of ONE sorry root (`nf_2var_existential_transfer`), sub-interval splitting as a real mathematical problem, formula_agreement circularity as structural. Identified discrete specialization (Path 2) as optimal when depth arithmetic confirms.
- **Report 66** (`66_depth-arithmetic.md`): Verified exact Lean type signatures. Key finding: `stavi_fo_depth_le_twice_depth` bounds `stavi_fo_depth A <= 2 * stavi_depth A`. Section 3.6 correctly states r <= k/2, but section 4.5 summary table incorrectly claims r = k for discrete orders. The table was wrong.
- **Report 67** (`67_depth-blocker-resolution.md`): Definitive resolution. Path 3 (game at rank floor(k/2)) is the correct approach. The critical new lemma is `nf_agree_muSig_of_nf_agree_sig` (depth-k NF on sig --> depth-k NF on muSig for discrete orders). Estimated 380-430 lines. Paths 1 and 2 are infeasible.

### Prior Plan Reference

Revision of `plans/65_discrete-game-bypass.md` (plan v67), which was blocked at Phase 1 due to the incorrect claim that r = k works for discrete orders. Phase 0 (signature refactoring from plan v66) is COMPLETED. The 8 discrete infrastructure lemmas from plan v67 Phase 1 are COMPLETED and reused: `rdefinable_gap_empty_of_no_gaps`, `discrete_extended_is_point`, `discrete_extendPoint_surj`, `discrete_extended_isPoint`, `discrete_extended_not_isGap`, `discrete_mu_trivial`, and related helpers. This plan replaces Phases 1-5 with corrected phases using r = floor(k/2).

## Goals & Non-Goals

**Goals**:
- Create `discrete_nf_2var_existential_transfer` using game at rank r = floor(k/2), not r = k
- Build Bridge A: NF hypotheses at depth k --> decomposition_agreement at rank k/2 (via `nf_agree_muSig_of_nf_agree_sig` and `nf_profile` at depth 2*(k/2) <= k)
- Build Bridge B: game winning at rank k/2 --> NF agreement at depth k (via FO agreement at depth 2*(k/2) = k on muSig --> NF agreement at depth k on sig)
- Wire the bridges to replace the three sorry sites (lines 2353, 2435, 2805 in StaviCompleteness.lean)
- Thread `IsSuccArchimedean` hypotheses through the call chain to `completeness_discrete`
- Verify `#print axioms completeness_discrete` shows no `sorryAx`

**Non-Goals**:
- Proving the general (non-discrete) `nf_characterizable_by_stavi` sorry-free
- Fixing non-critical-path sorry sites (BXCanonical, Bundle, Algebraic, etc.)
- Refactoring the EF game infrastructure
- Optimizing proof performance or compile times
- Direct NF induction approach (ruled out by 5+ failed attempts)
- Using r = k for discrete orders (proven wrong by report 67)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `nf_agree_muSig_of_nf_agree_sig` induction is harder than estimated (60-80 lines) | M | M | The induction on k and n is structurally clean: mu is trivially true for discrete orders, carrier is the same, predicates restrict cleanly. Fall back to proving at specific small values and generalizing. |
| Bridge B recovery chain: restricting from muSig to sig loses information | H | L | MonadicFormulas of sig embed into those of muSig; restriction is sound. The key inequality 2*(k/2) <= k holds by `Nat.div_mul_le_self`. |
| `nf_profile_determines_rank_type` at rank k/2 does not exist or has wrong signature | M | L | Existing `nf_profile_determines_stavi_truth` should suffice; if not, build rank_type from nf_profile via existing `stavi_truth` infrastructure. |
| Threading `IsSuccArchimedean` through the call chain requires touching many files | M | L | The chain is well-documented; only theorems on the critical path need discrete variants; most callers already have the discrete hypothesis available. |
| General `nf_characterizable_by_stavi` retains sorry | L | H | Acceptable: the goal is `completeness_discrete`, not the general theorem. |
| Integer arithmetic edge case: k=0 or k=1 requires special handling | L | M | k=0 is vacuous (no depth-j transfer needed for j < 0). k=1 gives r=0; Bridge B at rank 0 gives depth-0 = atom agreement, but depth-0 NF transfer for j=0 is from NF hypotheses directly. Handle both cases explicitly. |

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

### Phase 1: Bridge A -- NF Hypotheses to decomposition_agreement at rank k/2 (Discrete) [PARTIAL]

**Goal**: For discrete orders, build the conversion from `nf_2var_existential_transfer` hypotheses (1-var NF agreement, ordering, interval_nf_types agreement) into `decomposition_agreement` on ExtendedCarrier at rank r = floor(k/2). The corrected depth chain: depth-k NF on sig --> depth-k NF on muSig (via `nf_agree_muSig_of_nf_agree_sig`) --> nf_profile agreement at depth 2*(k/2) <= k (via `nf_agreement_monotone`) --> rank_type and formula_agreement at rank k/2 --> decomposition_agreement at rank k/2.

**Tasks**:
- [x] 8 discrete infrastructure lemmas already proved and compiling: `rdefinable_gap_empty_of_no_gaps`, `discrete_extended_is_point`, `discrete_extendPoint_surj`, `discrete_extended_isPoint`, `discrete_extended_not_isGap`, `discrete_mu_trivial`, and related helpers
- [x] **Task 1.2**: Prove `discrete_muSig_nf_agree` (named differently from plan): for discrete orders, n-var NF agreement on `sig` at depth d implies n-var NF agreement on `muSig sig` at depth d on `extendedStructureWithMu`. Proved by induction on d with atom agreement via `discrete_muSig_atom_agree` and quantifier transfer via the quantifier part of the sig NF. *(deviation: altered -- named `discrete_muSig_nf_agree` instead of `nf_agree_muSig_of_nf_agree_sig`; takes `IsEmpty (Gap)` instead of typeclass instances directly)*
- [x] **Task 1.3**: Prove `discrete_nf_profile_at_depth` and `discrete_nf_profile_agree`: nf_profile agreement at depth d and at the half-rank. Uses `nf_agreement_monotone` + `discrete_muSig_nf_agree`. *(deviation: altered -- split into two lemmas for flexibility)*
- [x] **Task 1.4**: Prove `discrete_rank_type_agree`: depth-k NF agreement implies rank_type agreement at rank k/2. Uses `stavi_table_mu_correct` + `doets_lemma_1_1` + nf_profile agreement.
- [ ] **Task 1.5**: Prove `discrete_formula_agreement_from_nf` *(deviation: deferred to task 1.7)*
- [ ] **Task 1.6**: Prove `discrete_interval_types_from_nf` *(deviation: deferred to task 1.7)*
- [ ] **Task 1.7**: Prove `discrete_nf_to_decomposition_agreement` -- the master Bridge A theorem
- [x] Verify intermediate lemmas compile: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` *(completed, build succeeds)*

**Timing**: 3.5 hours

**Depends on**: none (Phase 0 from prior plan v66 and infrastructure lemmas from plan v67 are COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add corrected Bridge A lemmas (~200-250 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No new sorry sites introduced
- `discrete_nf_to_decomposition_agreement` type-checks with correct signature matching `decomposition_agreement` at rank k/2

---

### Phase 2: Bridge B -- Game Wins to NF Transfer at Depth k (Discrete) [NOT STARTED]

**Goal**: Convert the Duplicator's winning strategy from `ghr93_duplicator_wins` at rank k/2 back into the existential transfer statement needed by `nf_2var_existential_transfer`. The key insight from report 67: formula_agreement at rank k/2 gives agreement on all StaviFormulas with stavi_depth <= k/2, which via `stavi_table_mu_correct` gives agreement on MonadicFormulas of quantifier_depth <= 2*(k/2) = k on `muSig sig`, which restricts to agreement on depth-k MonadicFormulas on `sig`, which by `doets_lemma_1_1` gives depth-k NF agreement on `sig`.

**Tasks**:
- [ ] Prove `game_to_muSig_fo_agree`: from formula_agreement at rank r on ExtendedCarrier, derive FO agreement at depth 2*r on `muSig sig`. Chain: formula_agreement gives stavi_truth agreement for stavi_depth <= r; `stavi_table_mu_correct` converts to stavi_table_mu agreement; `stavi_table_mu_depth` + `stavi_fo_depth_le_twice_depth` bound quantifier_depth <= 2*r. Estimated ~40 lines.
- [ ] Prove `muSig_fo_to_sig_nf`: from depth-d FO agreement on `muSig sig`, derive depth-d NF agreement on `sig` (for discrete orders). MonadicFormulas of sig embed into those of muSig (every sig predicate is a muSig predicate, and mu is trivially true for all actual points). Use `doets_lemma_1_1` for the NF direction. Estimated ~30 lines.
- [ ] Prove `discrete_game_to_point_matching`: from `ghr93_duplicator_wins` at parameters (n, r=k/2), extract that for any actual point u in [x,t], there exists u' in [x',t'] with matching rank_type at rank k/2 and correct ordering relative to x', t'. All elements are actual in discrete case. Estimated ~50 lines.
- [ ] Prove `discrete_game_to_nf_existential_transfer`: the master theorem -- from the hypotheses of `nf_2var_existential_transfer` plus discrete order assumptions, prove the existential transfer at every depth j < k. Chain: Bridge A --> `ghr93_decomposition_implies_game` (sorry-free) --> game at rank k/2 --> Bridge B --> NF existential transfer at depth j for all j < k. For each u, use game to find u' with formula_agreement at rank k/2; recover NF at depth k via `game_to_muSig_fo_agree` + `muSig_fo_to_sig_nf`; monotonicity gives depth j for j < k. Estimated ~50 lines.
- [ ] Handle edge cases: k=0 (vacuous, no j < 0 exists) and k=1 (r=0, verify depth-0 NF transfer works from rank-0 game or directly from NF hypotheses). Estimated ~20 lines.
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add Bridge B lemmas (~150-200 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- `discrete_game_to_nf_existential_transfer` has a conclusion type matching the goal at the sorry sites
- No new sorry sites

---

### Phase 3: Create Discrete Variant and Replace Sorries [NOT STARTED]

**Goal**: Create `nf_2var_existential_transfer_discrete` that takes `IsSuccArchimedean` hypotheses, and use it to replace the three sorry sites in StaviCompleteness.lean (lines 2353, 2435, 2805). The approach: define a discrete variant that routes through Bridge A (rank k/2) --> game (rank k/2) --> Bridge B (recover depth-k NF), then modify the existing theorems to call it when discrete hypotheses are available.

**Tasks**:
- [ ] Create `nf_2var_existential_transfer_discrete`: same signature as `nf_2var_existential_transfer` plus `[SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]` and same for M'. Proof: apply `discrete_game_to_nf_existential_transfer` (the master Bridge B theorem)
- [ ] Modify `nf_2var_existential_transfer` to accept additional discrete hypotheses (or create a version that dispatches to the discrete variant). Strategy: add the discrete typeclasses as hypotheses to `nf_2var_existential_transfer` itself, since the only call path to `completeness_discrete` passes through discrete models. The general theorem retains sorry for non-discrete callers (if any)
- [ ] Similarly modify `nf_2var_from_interval_data` and `nf_2var_transfer` to accept and pass discrete hypotheses
- [ ] Modify `nf_exist_sf_guarded_backward` (line 2805) to accept discrete hypotheses and use the now-proved `nf_2var_from_interval_data`
- [ ] Modify `nf_2var_exist_sf_classical` and `nf_2var_existence_characterizable` to thread discrete hypotheses
- [ ] Verify sorry sites are resolved: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
- [ ] Check `#print axioms nf_2var_existential_transfer` (the discrete-hypothesis version) shows no `sorryAx`

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- add discrete hypotheses to theorem signatures, replace sorry at lines 2353, 2435, 2805 (~80-120 lines changed)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds
- `grep -c "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` returns 0 (or only comment references)
- `#print axioms nf_2var_existential_transfer` shows no `sorryAx` (for the discrete variant)

---

### Phase 4: Thread Discrete Hypotheses Through Call Chain [NOT STARTED]

**Goal**: Thread the `IsSuccArchimedean` (and related discrete order) hypotheses through the call chain from `nf_characterizable_by_stavi` down to `completeness_discrete`. The chain is: `nf_characterizable_by_stavi` --> `stavi_expressive_completeness` --> `US_expressively_complete_over_prior` --> `gap_prior_UZ_contradiction` --> `no_gaps_discrete_model_surgery` --> `limitdom_is_good` --> `countermodel_discrete_reynolds_v2` --> `completeness_discrete`. Each theorem on this chain either already has discrete hypotheses or needs discrete-specialized variants.

**Tasks**:
- [ ] Create `nf_characterizable_by_stavi_discrete`: version with discrete hypotheses threaded through the induction. The IH at depth k provides `char_k` for depth-k NFs. The inductive step calls `nf_2var_existence_characterizable` (which calls `nf_2var_from_interval_data`, which calls `nf_2var_existential_transfer`). With discrete hypotheses added to all of these (Phase 3), the induction closes
- [ ] Create `stavi_expressive_completeness_discrete`: calls `nf_characterizable_by_stavi_discrete`. Same signature but with discrete order typeclasses
- [ ] Update `US_expressively_complete_over_prior` to accept discrete hypotheses (or create discrete variant). This calls `stavi_expressive_completeness`
- [ ] Verify that `gap_prior_UZ_contradiction`, `no_gaps_discrete_model_surgery`, `limitdom_is_good`, and `countermodel_discrete_reynolds_v2` either already accept discrete hypotheses or can be updated to use `US_expressively_complete_over_prior` with discrete hypotheses
- [ ] Verify the chain compiles: `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge`
- [ ] Verify `completeness_discrete` compiles with the updated chain: `lake build Bimodal.Metalogic.BXCanonical.Completeness`

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- discrete variants of `nf_characterizable_by_stavi`, `stavi_expressive_completeness` (~50-80 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` -- discrete variant of `US_expressively_complete_over_prior` (~20-30 lines)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructuresModelSurgery.lean` -- if `gap_prior_UZ_contradiction` needs updated call (~10-20 lines)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` -- if `countermodel_discrete_reynolds_v2` needs updated call (~10-20 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge` succeeds
- `lake build Bimodal.Metalogic.BXCanonical.Completeness` succeeds
- No new sorry sites introduced in any modified files

---

### Phase 5: End-to-End Verification [NOT STARTED]

**Goal**: Verify that the entire sorry chain from `completeness_discrete` down through `stavi_expressive_completeness` is now sorry-free. Run full project build.

**Tasks**:
- [ ] Run `#print axioms completeness_discrete` and verify output is `propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound` (no `sorryAx`)
- [ ] Run `#print axioms stavi_expressive_completeness` (discrete variant) and verify no `sorryAx`
- [ ] Run `#print axioms countermodel_discrete_reynolds_v2` and verify no `sorryAx`
- [ ] Run `lake build` (full project) and verify clean build
- [ ] Grep all EFGames files for remaining sorry: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` -- only comment references should remain
- [ ] Verify that the general `nf_characterizable_by_stavi` (without discrete hypotheses) may still contain sorry -- document this as acceptable non-critical-path sorry

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds
- `#print axioms completeness_discrete` output matches target: `propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound`
- No `sorryAx` in any theorem on the critical path

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness_discrete` shows no `sorryAx`
- [ ] `#print axioms countermodel_discrete_reynolds_v2` shows no `sorryAx`
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` returns no active sorry statements
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` returns no sorry statements
- [ ] General `nf_characterizable_by_stavi` sorry is documented as acceptable (not on `completeness_discrete` critical path)
- [ ] Key inequality `2*(k/2) <= k` verified in Lean via `Nat.div_mul_le_self`

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/67_half-rank-game-bypass.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extended with corrected Bridge A + Bridge B at rank k/2, ~380-430 additional lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (discrete variants + sorry replacement, ~130-200 lines changed)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (discrete variant, ~20-30 lines added)

## Rollback/Contingency

- If `nf_agree_muSig_of_nf_agree_sig` induction proves harder than expected at full generality (n variables, depth d): prove the special case n=1 first (sufficient for the Bridge A chain), then generalize if needed. The n=1 case avoids the quantifier transfer complexity.
- If Bridge B's FO-to-NF conversion via `doets_lemma_1_1` requires additional infrastructure: use `char_k_correct` as an alternative pathway from FO agreement to NF agreement (char_k formulas are StaviFormulas with bounded stavi_depth, so formula_agreement covers them).
- If hypothesis threading (Phase 4) touches too many files: create wrapper theorems that specialize existing general theorems with `sorry` replaced only on the discrete path, leaving the general theorems untouched.
- If the k=1 edge case (r=0 game) produces vacuous or degenerate results: handle k <= 1 as a base case with direct NF transfer from the hypotheses, bypassing the game entirely.
- Git revert: primary changes are in NFGameBridge.lean and StaviCompleteness.lean. Revert with `git checkout main -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean`.
