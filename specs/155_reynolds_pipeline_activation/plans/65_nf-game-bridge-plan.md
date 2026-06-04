# Implementation Plan: Task #155 -- NF-Game Bridge

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (all EF game infrastructure is sorry-free)
- **Research Inputs**: specs/155_reynolds_pipeline_activation/reports/65_post-281-assessment.md
- **Artifacts**: plans/65_nf-game-bridge-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the last sorry root (`nf_2var_existential_transfer` at StaviCompleteness.lean lines 2347/2429) by routing the proof through the sorry-free EF game machinery. The direct NF induction approach has been confirmed to fail (5 sessions). The correct strategy is the NF-Game Bridge documented in NFGameBridge.lean: convert NF hypotheses to `decomposition_agreement` (Bridge A), apply `ghr93_duplicator_wins` (sorry-free), and convert game agreement back to NF-level existential transfer (Bridge B). Once `nf_2var_existential_transfer` is proved, all three sorry sites resolve and `completeness_discrete` becomes sorry-free.

### Research Integration

From report `65_post-281-assessment.md`:
- ONE independent sorry root: `nf_2var_existential_transfer` (lines 2347, 2429)
- Downstream sorry: `nf_exist_sf_guarded_backward` (line 2787) resolves automatically
- Full sorry chain: `nf_2var_existential_transfer` -> `nf_characterizable_by_stavi` -> `stavi_expressive_completeness` -> `US_expressively_complete_over_prior` -> `gap_prior_UZ_contradiction` -> `no_gaps_discrete_model_surgery` -> `limitdom_is_good` -> `countermodel_discrete_reynolds_v2` -> `completeness_discrete`
- Sorry-free infrastructure: `ghr93_duplicator_wins`, `ghr93_strategy_compose`, `decomposition_agreement`, `nf_fraisse_compression`
- Estimated scope: 300-500 lines connecting NF types on M.carrier with rank_type/formula_agreement on ExtendedCarrier

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` by routing through EF game machinery
- Eliminate all `sorryAx` from `completeness_discrete`
- Verify `#print axioms completeness_discrete` shows no `sorryAx`

**Non-Goals**:
- Fixing non-critical-path sorry sites (BXCanonical, Bundle, Algebraic, etc.)
- Refactoring the EF game infrastructure
- Optimizing proof performance or compile times
- Alternative proof strategies (direct NF induction has been ruled out)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bridge A type mismatch: NF types on M.carrier vs rank_type on ExtendedCarrier may not align cleanly | H | M | NFGameBridge.lean already has helper lemmas (nf_agreement_from_nf_char_eq, pred_agree_from_nf_char, nf_char_depth_le) establishing pointwise connections; build on these |
| interval_nf_types (Finset of NormalForm) vs interval_types (Set of Set StaviFormula) conversion is non-trivial | M | M | Use char_k/char_k_correct bidirectional mapping already present in the inductive step of nf_characterizable_by_stavi |
| ExtendedCarrier includes gaps but M.carrier does not; game operates on ExtendedCarrier while NF operates on M.carrier | H | L | The sorry sites only quantify over M.carrier points; use extendPoint embedding and restrict game to actual points |
| Proof exceeds estimated 300-500 lines due to Fin/environment manipulation boilerplate | M | M | Phase 1 builds reusable lemmas to minimize boilerplate in later phases; atom agreement at n vars already proved in NFGameBridge.lean |
| Build breaks in intermediate steps due to sorry removal affecting downstream | L | L | Work in NFGameBridge.lean (separate file) first, only modify StaviCompleteness.lean in final phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Bridge A -- NF Hypotheses to Game Input [BLOCKED]

**Goal**: Build the conversion from `nf_2var_existential_transfer` hypotheses (1-var NF agreement, ordering, interval_nf_types agreement) into `decomposition_agreement` on ExtendedCarrier, suitable as input to `ghr93_duplicator_wins`.

**BLOCKER** (Phase 1):
- **What failed**: Extensive analysis (90+ minutes) proved that ALL direct approaches (strong induction on j, strong induction on k, splitting zone match, combinatorial arguments) fail due to the sub-interval problem. The sub-interval types between matched inner points are NOT determined by the outer interval type data.
- **What was tried**: (1) Strong induction on j with same base, (2) generalized n-point bases with zone matching, (3) induction on k, (4) splitting zone match (proved FALSE via counterexample), (5) nf_fraisse_compression at lower depth (circular)
- **Why it's stuck**: The EF game (ghr93_duplicator_wins) is genuinely necessary. Its compositional strategy (Proposition 7) handles sub-interval splitting that pointwise zone matching cannot. However, bridging NF data on M.carrier to game data on ExtendedCarrier requires `char_k` (StaviFormula characterizations), which is NOT currently a parameter of `nf_2var_existential_transfer`.
- **What is needed**: (1) Add `atomMap`, `char_k`, `char_k_correct` as parameters to `nf_2var_existential_transfer` and `nf_2var_from_interval_data`, (2) propagate through callers (char_k IS available in all calling contexts from the inductive step of `nf_characterizable_by_stavi`), (3) implement Bridge A using char_k to convert NF data to StaviFormula/rank_type data, then to decomposition_agreement, (4) implement Bridge B using game's winning condition + char_k to convert formula_agreement back to NF existential transfer
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Tasks**:
- [ ] Define `nf_to_extended_interval` embedding: given M.carrier endpoints (x, t), construct ExtendedCarrier endpoints suitable for `ghr93_duplicator_wins` *(deviation: deferred -- prerequisite: add char_k parameter first)*
- [ ] Prove `interval_nf_types_to_decomposition`: convert `interval_nf_types M k lo hi = interval_nf_types M' k lo' hi'` to the forward/backward selection matching needed by `decomposition_agreement` *(deviation: deferred -- prerequisite: add char_k parameter first)*
- [ ] Prove `nf_char_to_rank_type_agree`: if `nf_characteristic M k 1 (fun _ => x) = nf_characteristic M' k 1 (fun _ => x')` then `rank_type M atomMap k (extendPoint x) = rank_type N atomMap k (extendPoint x')` (using char_k_correct from the inductive context) *(deviation: deferred -- prerequisite: add char_k parameter first)*
- [ ] Prove `nf_hypotheses_to_decomposition_agreement`: the master theorem combining the above to produce `decomposition_agreement M N atomMap n k (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')` from the hypotheses of `nf_2var_existential_transfer` *(deviation: deferred -- prerequisite: add char_k parameter first)*
- [ ] Verify intermediate lemmas compile: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add Bridge A lemmas (~100-150 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No new sorry sites introduced
- `nf_hypotheses_to_decomposition_agreement` type-checks with correct signature

---

### Phase 2: Bridge B -- Game Agreement to NF Existential Transfer [NOT STARTED]

**Goal**: Convert the Duplicator's winning strategy (from `ghr93_duplicator_wins`) back into the existential transfer statement needed by `nf_2var_existential_transfer`. This is the reverse direction: game agreement implies that for any witness u in M, there exists a matching u' in M' with the same depth-j (n+1)-var NF.

**Tasks**:
- [ ] Prove `game_wins_to_point_matching`: from `ghr93_duplicator_wins`, extract that for any actual point u in [x,t], there exists u' in [x',t'] with matching rank_type and correct ordering relative to x', t'
- [ ] Prove `rank_type_agree_to_nf_agree`: if two actual points have matching rank_type at rank k, then their depth-j 1-var NFs agree for j <= k (reverse of the char_k_correct direction)
- [ ] Prove `game_wins_to_nf_existential_transfer`: the master theorem -- from `ghr93_duplicator_wins` at parameters suitable for 2-var NF, conclude that the existential transfer holds at every depth j < k. This should produce exactly the conclusion type of `nf_2var_existential_transfer`
- [ ] Handle the zone cases (u above max, below min, between x and t, equal to x, equal to t) in the game-to-NF direction
- [ ] Verify: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` -- add Bridge B lemmas (~100-150 lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- `game_wins_to_nf_existential_transfer` has the same conclusion type as `nf_2var_existential_transfer`
- No new sorry sites

---

### Phase 3: Replace Sorries in nf_2var_existential_transfer [NOT STARTED]

**Goal**: Replace the two `sorry` calls in `nf_2var_existential_transfer` (lines 2347 and 2429) with proofs that route through Bridge A -> `ghr93_duplicator_wins` -> Bridge B. Also resolve the downstream sorry in `nf_exist_sf_guarded_backward` (line 2787).

**Tasks**:
- [ ] Replace sorry at line 2347 (forward direction, `j' + 1` case): apply `nf_hypotheses_to_decomposition_agreement` to get `decomposition_agreement`, then `decomposition_to_game` to get `ghr93_duplicator_wins`, then `game_wins_to_nf_existential_transfer` to close the 4-var existential transfer goal
- [ ] Replace sorry at line 2429 (backward direction, `j' + 1` case): symmetric application using reversed hypotheses (M' -> M direction)
- [ ] Verify `nf_exist_sf_guarded_backward` (line 2787) resolves automatically once `nf_2var_existential_transfer` is proved (it depends on `nf_2var_from_interval_data` which calls `nf_2var_existential_transfer`)
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` to confirm all three sorry sites are resolved
- [ ] Check `#print axioms nf_2var_existential_transfer` shows no `sorryAx`

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- replace sorry at lines 2347, 2429 (~30-50 lines each)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds with no errors
- `grep -c "sorry" StaviCompleteness.lean` returns 0 (or only non-critical-path sorry references in comments)
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

- `specs/155_reynolds_pipeline_activation/plans/65_nf-game-bridge-plan.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (extended with Bridge A + Bridge B, ~200-300 additional lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (sorry sites replaced, ~60-100 lines changed)

## Rollback/Contingency

- If Bridge A type alignment proves harder than expected: the conversion between `interval_nf_types` (Finset NormalForm) and `interval_types` (Set (Set StaviFormula)) can be bypassed by working entirely in the NF world and constructing a custom game variant that operates on NormalForm types directly, avoiding ExtendedCarrier entirely. This is a fallback documented in NFGameBridge.lean comments.
- If proof exceeds 500 lines: split NFGameBridge.lean into NFGameBridgeA.lean and NFGameBridgeB.lean to keep files manageable.
- Git revert: all changes are in two files (NFGameBridge.lean, StaviCompleteness.lean). Revert with `git checkout main -- Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`.
