# Implementation Plan: Task #155 -- Discrete Game Bypass

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all EF game infrastructure is sorry-free; Phase 0 completed in prior plan)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/65_team-research.md, specs/155_reynolds_pipeline_activation/reports/66_depth-arithmetic.md
- **Artifacts**: plans/65_discrete-game-bypass.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Eliminate all `sorryAx` from `completeness_discrete` by implementing the **discrete game bypass** strategy for `nf_2var_existential_transfer`. The previous plan (v66) was blocked at Phase 1 by a fundamental circularity: `formula_agreement` on ExtendedCarrier requires agreement on ALL StaviFormulas of bounded depth, but building that from NF agreement IS the `stavi_expressive_completeness` theorem being proved. Two rounds of research (team research report 65 and depth arithmetic report 66) confirmed that for **discrete orders** (IsSuccArchimedean), `discrete_no_gaps` eliminates all gaps from ExtendedCarrier, making mu trivially true and allowing formula_agreement at rank k (no 2x depth penalty). This plan creates discrete-specialized Bridge A and Bridge B lemmas in NFGameBridge.lean, then threads the `IsSuccArchimedean` hypothesis through the call chain from `nf_2var_existential_transfer` down to `completeness_discrete`.

### Research Integration

- **Report 65** (`65_team-research.md`): 4-teammate unanimous confirmation of ONE sorry root (`nf_2var_existential_transfer`), sub-interval splitting as a real mathematical problem, formula_agreement circularity as structural. Identified discrete specialization (Path 2) as optimal when depth arithmetic confirms.
- **Report 66** (`66_depth-arithmetic.md`): Verified exact Lean type signatures. Key finding: for discrete orders, `discrete_no_gaps` eliminates all gaps, mu is trivially true, and formula_agreement at rank k is directly achievable from depth-k NFs without the 2x depth penalty that blocks the general case. Confirmed r = k suffices (exceeds k-1 needed).

### Prior Plan Reference

Revision of `plans/66_nf-game-bridge-revised.md`, which was blocked at Phase 1 due to formula_agreement circularity. Phase 0 (signature refactoring) from that plan is COMPLETED and preserved. This plan replaces Phases 1-4 with discrete-specialized phases that avoid the circularity entirely.

## Goals & Non-Goals

**Goals**:
- Create `nf_2var_existential_transfer_discrete` that takes `IsSuccArchimedean` hypotheses
- Build Bridge A (NF hypotheses to decomposition_agreement at rank k for discrete orders)
- Build Bridge B (game winning condition to NF agreement for discrete orders)
- Wire the bridges to replace the three sorry sites (lines 2353, 2435, 2805)
- Thread `IsSuccArchimedean` hypotheses through the call chain to `completeness_discrete`
- Verify `#print axioms completeness_discrete` shows no `sorryAx`

**Non-Goals**:
- Proving the general (non-discrete) `nf_characterizable_by_stavi` sorry-free (may retain sorry for non-discrete orders)
- Fixing non-critical-path sorry sites (BXCanonical, Bundle, Algebraic, etc.)
- Refactoring the EF game infrastructure
- Optimizing proof performance or compile times
- Direct NF induction approach (ruled out by 5+ failed attempts)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `discrete_no_gaps` requires typeclass instances not available in calling contexts | H | M | Verify all callers on the `completeness_discrete` path have access to `IsSuccArchimedean` instances; `completeness_discrete` already works with discrete (Z-based) models |
| Building decomposition_agreement from NF hypotheses on discrete ExtendedCarrier requires nf_profile agreement across two different structures M and M' | H | M | For discrete orders, ExtendedCarrier = M.carrier (no gaps), so nf_profile reduces to nf_characteristic on the mu-extended structure where mu is trivially true; this should be a direct consequence of the NF agreement hypotheses |
| rank_type on ExtendedCarrier vs nf_characteristic on M.carrier type mismatch in Bridge A | M | M | In discrete case, extendPoint is essentially the identity; use `discrete_no_gaps` to coerce between carrier types; the `stavi_truth_mu_at_point` lemma connects mu-truth to standard truth |
| Threading `IsSuccArchimedean` through the call chain requires touching many files | M | L | The chain is well-documented; only theorems on the critical path need discrete variants; most callers already have the discrete hypothesis available |
| General `nf_characterizable_by_stavi` retains sorry | L | H | Acceptable: the goal is `completeness_discrete`, not the general theorem; the general case requires the 2x depth analysis or a different approach |
| Proof exceeds estimated line count | M | M | Phase 0 infrastructure already in place; NFGameBridge.lean has helper lemmas; split into sub-files if needed |

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

### Phase 1: Bridge A -- NF Hypotheses to decomposition_agreement (Discrete) [NOT STARTED]

**Goal**: For discrete orders, build the conversion from `nf_2var_existential_transfer` hypotheses (1-var NF agreement, ordering, interval_nf_types agreement) into `decomposition_agreement` on ExtendedCarrier at rank k, suitable as input to `ghr93_decomposition_implies_game`. The key insight: `discrete_no_gaps` means ExtendedCarrier = M.carrier, mu is trivially true everywhere, and formula_agreement at rank k follows directly from depth-k NF agreement without the 2x depth penalty.

**Tasks**:
- [ ] Prove `discrete_extended_carrier_equiv`: for a discrete order (IsSuccArchimedean), `ExtendedCarrier M atomMap r` is equivalent to `M.carrier` via `extendPoint` (using `discrete_no_gaps` to show `IsEmpty (Gap M.carrier)`, hence no gap elements exist in ExtendedCarrier)
- [ ] Prove `discrete_mu_trivial`: for a discrete order, `mu_holds M atomMap r (extendPoint x)` is trivially true for all actual points x (since mu distinguishes gaps from points, and there are no gaps)
- [ ] Prove `discrete_nf_profile_from_nf_char`: if `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` and both M.carrier, M'.carrier are discrete, then `nf_profile (extendPoint x) = nf_profile (extendPoint x')` at depth 2*k on the mu-extended structures (since mu is trivially true, the extra mu predicate adds no information, and the quantifier domain is just M.carrier)
- [ ] Prove `discrete_rank_type_from_nf_char`: same NF characteristic at depth k implies same rank_type at rank k (follows from `discrete_nf_profile_from_nf_char` and `nf_profile_determines_rank_type`)
- [ ] Prove `discrete_formula_agreement_from_nf`: if points have matching depth-k 1-var NFs in discrete structures, then formula_agreement at rank k holds for those points on ExtendedCarrier
- [ ] Prove `discrete_interval_types_from_nf`: convert `interval_nf_types M k lo hi = interval_nf_types M' k lo' hi'` to `interval_types M atomMap k (extendPoint lo) (extendPoint hi) = interval_types N atomMap k (extendPoint lo') (extendPoint hi')` using the discrete NF-to-rank_type conversion
- [ ] Prove `discrete_nf_to_decomposition_agreement`: the master theorem combining the above to produce `decomposition_agreement M N atomMap n k (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')` from the hypotheses of `nf_2var_existential_transfer` plus discrete order assumptions
- [ ] Verify intermediate lemmas compile: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2.5 hours

**Depends on**: none (Phase 0 from prior plan v66 is COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add discrete Bridge A lemmas (~200-250 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No new sorry sites introduced
- `discrete_nf_to_decomposition_agreement` type-checks with correct signature matching `decomposition_agreement`

---

### Phase 2: Bridge B -- Game Wins to NF Transfer (Discrete) [NOT STARTED]

**Goal**: Convert the Duplicator's winning strategy (from `ghr93_duplicator_wins` via `ghr93_decomposition_implies_game`, both already sorry-free) back into the existential transfer statement needed by `nf_2var_existential_transfer`. For discrete orders, the game at rank k gives formula_agreement at rank k, which via `char_k_correct` converts back to NF agreement at depth k.

**Tasks**:
- [ ] Prove `discrete_game_to_point_matching`: from `ghr93_duplicator_wins` at parameters (n=1, r=k), extract that for any actual point u in [x,t], there exists u' in [x',t'] with (a) matching rank_type at rank k, (b) correct ordering relative to x', t'. Strategy: instantiate the game with Spoiler placing extendPoint(u); Duplicator responds; use point challenge to get matching actual point (all elements are actual in discrete case)
- [ ] Prove `discrete_rank_type_to_nf_agree`: if two actual points in discrete orders have the same rank_type at rank k, then they have the same depth-k 1-var NF. Strategy: rank_type at rank k means agreement on all StaviFormulas with stavi_depth <= k; use `char_k_correct` -- for each NF nf_k, `char_k nf_k` is a StaviFormula; if stavi_depth(char_k nf_k) <= k, then rank_type agreement transfers it; `char_k_correct` converts back to NF agreement. The stavi_depth of char_k images needs verification -- if not bounded by k, use the nf_profile pathway instead (nf_profile determines NF characteristic for discrete structures)
- [ ] Prove `discrete_game_to_nf_existential_transfer`: the master theorem -- from the hypotheses of `nf_2var_existential_transfer` plus discrete order assumptions, prove the existential transfer at every depth j < k. Chain: Bridge A -> `ghr93_decomposition_implies_game` (sorry-free) -> game -> Bridge B -> existential witness with matching NF
- [ ] Handle the depth-0 base case separately (atoms only, no quantifier transfer needed -- already handled in existing code at line 2329)
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add discrete Bridge B lemmas (~150-200 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- `discrete_game_to_nf_existential_transfer` has a conclusion type matching the goal at the sorry sites
- No new sorry sites

---

### Phase 3: Create Discrete Variant and Replace Sorries [NOT STARTED]

**Goal**: Create `nf_2var_existential_transfer_discrete` that takes `IsSuccArchimedean` hypotheses, and use it to replace the three sorry sites in StaviCompleteness.lean (lines 2353, 2435, 2805). The approach: define a discrete variant that routes through Bridge A -> game -> Bridge B, then modify the existing theorems to call it when discrete hypotheses are available.

**Tasks**:
- [ ] Create `nf_2var_existential_transfer_discrete`: same signature as `nf_2var_existential_transfer` plus `[SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier] [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]` and same for M'. Proof: apply `discrete_game_to_nf_existential_transfer` (the master Bridge B theorem)
- [ ] Modify `nf_2var_existential_transfer` to accept additional optional discrete hypotheses (or create a version that dispatches to the discrete variant). Strategy: add the discrete typeclasses as hypotheses to `nf_2var_existential_transfer` itself, since the only call path to `completeness_discrete` passes through discrete models. The general theorem retains sorry for non-discrete callers (if any)
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

**Goal**: Thread the `IsSuccArchimedean` (and related discrete order) hypotheses through the call chain from `nf_characterizable_by_stavi` down to `completeness_discrete`. The chain is: `nf_characterizable_by_stavi` -> `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> `gap_prior_UZ_contradiction` -> `no_gaps_discrete_model_surgery` -> `limitdom_is_good` -> `countermodel_discrete_reynolds_v2` -> `completeness_discrete`. Each theorem on this chain either already has discrete hypotheses or needs discrete-specialized variants.

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

**Timing**: 0.5 hours

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

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/65_discrete-game-bypass.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extended with discrete Bridge A + Bridge B, ~350-450 additional lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (discrete variants + sorry replacement, ~130-200 lines changed)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (discrete variant, ~20-30 lines added)

## Rollback/Contingency

- If discrete Bridge A (Phase 1) type alignment proves harder than expected: the `discrete_no_gaps` lemma is proven and `extendPoint` embedding is well-understood. The main risk is the nf_profile cross-structure comparison; fallback is to prove it at a lower rank (r = floor(k/2)) which may still suffice for some depths j < k.
- If Bridge B's rank_type-to-NF conversion fails because `stavi_depth(char_k nf_k) > k`: use the nf_profile pathway instead -- nf_profile at depth 2*k determines NF characteristic at depth k on the discrete carrier, and nf_profile agreement follows from discrete Bridge A.
- If hypothesis threading (Phase 4) touches too many files: create wrapper theorems that specialize existing general theorems with `sorry` replaced only on the discrete path, leaving the general theorems untouched. This isolates changes to a few files.
- If the general `nf_characterizable_by_stavi` is needed sorry-free (unexpected): Path 1 (mutual induction at rank k-1) from team research report 65 is a documented fallback that avoids discrete specialization.
- Git revert: primary changes are in NFGameBridge.lean and StaviCompleteness.lean. Revert with `git checkout main -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean`.
