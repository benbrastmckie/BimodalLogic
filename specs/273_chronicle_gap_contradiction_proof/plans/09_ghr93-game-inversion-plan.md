# Implementation Plan: GHR93 Game Inversion for Discrete Orders (v9, revised)

- **Task**: 273 - Eliminate sorryAx from `US_expressively_complete_over_prior` via GHR93 game-theoretic argument
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None (Phases 0-1 from v3 completed; base case of Theorem 6 proved)
- **Research Inputs**:
  - 4-agent parallel research sweep (2026-06-09): literature, decomposition, kamp-bypass, sorry-chain
  - literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md
  - specs/273_chronicle_gap_contradiction_proof/reports/06_decomposition-path-research.md
- **Artifacts**: plans/09_ghr93-game-inversion-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v9 replaces v8 based on findings from a 4-agent parallel research sweep that revealed three critical errors in all prior plans (v3-v8):

1. **Wrong sorry target**: Plans v3-v8 targeted lines 2353/2435 (`nf_2var_existential_transfer`), which are **dead code** -- they feed only `nf_2var_transfer` which is unused. The actual leaf sorry is at **line 2805** (`nf_exist_sf_guarded_backward`), which cascades to all 7 downstream theorems.

2. **Isolated game file**: `DiscreteGameTransfer.lean` is **not imported** by any file. Completing Theorem 6 there without wiring it into StaviCompleteness.lean has no effect on the sorry chain.

3. **General char_k leak**: `discrete_nf_characterizable_by_stavi` (line 3326) calls the sorry'd general `nf_characterizable_by_stavi` for `char_k_gen`, inheriting sorryAx. The fix requires a self-contained discrete chain.

### Research Integration

Reports integrated in this plan revision:
- `reports/06_decomposition-path-research.md` (integrated v9)
- 4-agent research sweep findings (integrated v9)

### Sorry Dependency DAG (Verified by lean_verify)

```
nf_exist_sf_guarded_backward (line 2805)     <-- LEAF SORRY (THE target)
  |
nf_2var_exist_sf_classical
  |
nf_2var_existence_characterizable (k >= 1)
  |
nf_characterizable_by_stavi (succ k)
  |--- stavi_expressive_completeness -> US_expressively_complete_over_prior (sorryAx)
  |--- discrete_nf_characterizable_by_stavi (via char_k_gen at line 3326) -> discrete_stavi_expressive_completeness (sorryAx)

DEAD CODE (does NOT affect any downstream theorem):
  nf_2var_existential_transfer (lines 2353, 2435) -> nf_2var_from_interval_data -> nf_2var_transfer -> NOTHING

ISOLATED FILE (not imported by anything):
  discrete_ghr93_theorem6 (DiscreteGameTransfer.lean:881) -> NOTHING
```

### Strategy (GHR93-Faithful)

Follow GHR93 Chapter 9 exactly:

1. **Theorem 6** (pp.114-119): Game inversion for discrete orders -- Claims 1-2 canonical pivot, Cases I-II only
2. **Proposition 7** (p.115): Strategy composition -- sub-interval game wins to standard EF game wins
3. **Bridge**: Game wins at sufficient rounds -> existential transfer at each depth -> `nf_fraisse_compression` -> 2-var NF equality -> `discrete_nf_exist_sf_guarded_backward`
4. **Wiring**: Self-contained `discrete_nf_characterizable_by_stavi` -> `discrete_stavi_expressive_completeness` -> `US_expressively_complete_over_prior`

### Key Mathematical Insight (from Literature Agent, GHR93 p.117-118)

Case II of Theorem 6's inductive step: when all alpha-points lie in (d-bar, y'), find e_n as a **witness of U(B,A) at e_{n-1}** (not via forward game Round 2). This guarantees e_n > e_{n-1} by Until semantics. Previous plans (v3-v8) failed because they tried Round 2, which does not guarantee ordering.

### Existing Sorry-Free Infrastructure

| Theorem | File | Line | GHR93 Ref |
|---------|------|------|-----------|
| `ghr93_strategy_compose` | Composition.lean | 40 | Prop 7 one-step |
| `ghr93_strategy_restrict_left` | CustomGame.lean | 1241 | Claim 2 sub-interval |
| `ghr93_strategy_restrict_right` | CustomGame.lean | 1470 | Claim 2 sub-interval |
| `ghr93_duplicator_wins_round_mono` | CustomGame.lean | 441 | Lemma 10 |
| `ghr93_game_implies_decomposition` | Decomposition.lean | 117 | Lemma 11 fwd |
| `ghr93_decomposition_implies_game` | Decomposition.lean | 272 | Lemma 11 bwd |
| `discrete_nf_to_decomposition_agreement` | NFGameBridge.lean | 997 | Bridge A (n=0) |
| `game_win_to_formula_agree` | NFGameBridge.lean | 1222 | Bridge B |
| `discrete_formula_agree_from_nf` | NFGameBridge.lean | 749 | NF -> formula |
| `nf_fraisse_compression` | StaviCompleteness.lean | 2006 | Fraisse |
| `zone_match_witness` | StaviCompleteness.lean | 2044 | Zone matching |
| `discrete_ghr93_theorem6_zero` | DiscreteGameTransfer.lean | 360 | Thm 6 base |
| `nf_exist_sf_guarded_forward` | StaviCompleteness.lean | 2643 | Fwd direction |

### Prior Plan Reference

Plans v3-v8 all failed for the same root cause: they processed variables one-at-a-time via zone matching, losing sub-interval structure. The game approach resolves this by absorbing variable counts into game rounds. **Additionally**, all prior plans targeted the wrong sorry sites (dead code at lines 2353/2435 or the isolated file at line 630).

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `US_expressively_complete_over_prior`
- Prove `nf_exist_sf_guarded_backward` for discrete orders (the leaf sorry at line 2805)
- Build self-contained `discrete_nf_characterizable_by_stavi` that does NOT call the sorry'd general version
- Follow GHR93 Chapter 9 exactly: Theorem 6 Claims 1-2, Proposition 7, Corollary 5

**Non-Goals**:
- Proving the general (non-discrete) `nf_exist_sf_guarded_backward` at line 2805
- Filling dead-code sorry sites at lines 2353/2435
- Implementing Cases III/IV of Theorem 6 (vacuous for discrete)
- Modifying `stavi_expressive_completeness` (general version retains sorry)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Canonical pivot formalization complexity (`discrete_pivot_and_restrict`) | H | M | For discrete orders: c is always a carrier point (no gaps), infimum is realized. Claim 1 uses formula C of rank r+1. Claim 2 uses `ghr93_strategy_restrict_left/right` (already sorry-free). Estimated 200-300 lines. |
| Case II U(B,A) transfer (`discrete_backward_extend`) | H | M | The formula U(B,A) has rank r+1. The backward strategy tau preserves rank-(r+4) formulas. Since r+1 <= r+4, formula agreement gives the transfer. `stavi_temporal_truth_mu` semantics handle Until evaluation. |
| Self-contained discrete char_k chain | M | M | Create `discrete_nf_2var_existence_characterizable` taking `char_k_correct` for discrete M only. The formula construction is identical; only the backward correctness proof differs. ~80-120 lines of duplication with discrete type constraints. |
| DiscreteGameTransfer.lean import wiring | M | L | Currently not imported. Add `import Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` to StaviCompleteness.lean. Verify no import cycles. |
| Rank/depth alignment across Theorem 6 -> Proposition 7 -> Bridge | M | M | Verify explicitly: Theorem 6 converts (1+3n, r+4n) forward to (n, r) backward. Proposition 7 needs game wins at (f(n), g(n)). Bridge starts from decomposition at n=0, r=k/2. Test alignment in Phase 2 Task 2.1. |
| `discrete_game_rank_down` depth bound sorry (line 598) | L | L | Requires showing `stavi_depth A <= r'` from usage context. May need to add a depth-bound hypothesis or use carrier-point truth independence directly. Estimated 5-15 lines. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

Phase 0 (axiom audit) and Phase 1 (SemanticBridge) from v3 are already [COMPLETED].

---

### Phase 0: Axiom Audit and Sorry State Verification [COMPLETED]

(From v3 plan.)

---

### Phase 1: SemanticBridge Infrastructure [COMPLETED]

(From v3 plan.)

---

### Phase 2: GHR93 Theorem 6 Inductive Step for Discrete Orders [IN PROGRESS]

**Goal**: Eliminate all 5 sorries in DiscreteGameTransfer.lean to complete the inductive step of Theorem 6 for discrete orders.

**Implementation History** (Cycles 1-5):
- **Cycle 1**: Changed induction to generalize over r. Applied IH at r+4 with rank casting. Established h_bwd_n (n-round backward game on full interval at rank r+4).
- **Cycle 2**: Explored direct construction (h_bwd_n + h_fwd_1); discovered cross-term order consistency requires the canonical pivot. Factored inductive step into `discrete_backward_step` helper.
- **Cycle 3**: Explored Options A (canonical pivot), B (direct h_bwd_n + h_fwd_1), C (rank lifting). Confirmed only Option A (canonical pivot) is mathematically correct.
- **Cycle 4**: Added discrete rank-transfer helpers (discrete_rank_convert_compose, discrete_inClosedInterval_rank_transfer, etc.). Attempted direct approach with h_bwd_n for n elements + forward game for (n+1)-th. Successfully constructed response array, Round 2 response, gap_point_agreement. FAILED on same_order_type: cross-term order consistency between independent strategies cannot be established. This conclusively proved the canonical pivot is mathematically necessary.
- **Cycle 5**: Decomposed the inductive step into well-typed helper lemmas. Created `discrete_game_rank_down` (rank conversion for discrete games, 1 sorry at depth bound), `discrete_restrict_forward_left` / `discrete_restrict_forward_right` (Claims 1-2, 1 sorry each for d-consistency), `discrete_pivot_and_restrict` (full pivot construction, 1 sorry), and `discrete_backward_extend` (Cases I-II, 1 sorry). Main theorem `discrete_backward_step` now delegates to these helpers (sorry-free assembly). File grew from ~710 to 950 lines. Eliminated 2 sorries (discrete_backward_step and discrete_ghr93_theorem6 are now sorry-free in their own logic, delegating to the helper lemmas).

### Sorry Inventory (5 remaining)

| # | Lemma | Line | Sorry Description | GHR93 Ref | Difficulty | Est. Lines |
|---|-------|------|-------------------|-----------|------------|------------|
| S1 | `discrete_game_rank_down` | 598 | Depth bound: show `stavi_depth A <= r'` for formula agreement transfer across ranks. Needs either a depth hypothesis or direct carrier-point truth independence argument. | N/A (infrastructure) | Low | 5-15 |
| S2 | `discrete_restrict_forward_left` | 654 | GHR93 Claim 1 (d-consistency) for left sub-interval: for any padded selection ending with c, the winning strategy's response to c is d. | Claim 1, p.116 | Medium | 40-80 |
| S3 | `discrete_restrict_forward_right` | 680 | GHR93 Claim 1 (d-consistency) for right sub-interval: symmetric to S2. | Claim 1, p.116 | Medium | 40-80 |
| S4 | `discrete_pivot_and_restrict` | 775 | Full canonical pivot construction: define formulas A, C; define pivot c/d; prove formula agreement; apply restrict_left/right; apply IH; convert ranks. This is the most technically demanding sorry. | Claims 1-2, pp.116-117 | High | 200-300 |
| S5 | `discrete_backward_extend` | 822 | Cases I-II: distribute Spoiler's n+1 selections across sub-intervals, apply n-round sub-strategies, handle Case II via Until transfer. | Cases I-II, pp.117-118 | High | 150-250 |

**GHR93 Reference**: Theorem 6, pp.114-119. Claims 1-2 at p.116 (lines 1392-1421 in OCR). Cases I-II at pp.117-118 (lines 1435-1504).

**Tasks** (mapped to remaining sorries):

- [ ] **Task 2.1**: Fill sorry S1 in `discrete_game_rank_down` (line 598)
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **What to write**: The sorry is inside a `show stavi_depth A <= r'` obligation within the formula_agreement transfer. In all current use sites, ranks are equal after arithmetic (r = r'). For the general case, carrier-point truth independence (`stavi_truth_mu_at_point`) means formula agreement holds regardless of depth bound. Either add a depth-bound hypothesis to `discrete_game_rank_down` or restructure the formula agreement proof to use `discrete_rank_convert_formula` directly instead of going through `hform` with a depth constraint.
  - **Estimated size**: 5-15 lines
  - **Depends on**: nothing

- [ ] **Task 2.2**: Fill sorry S4 in `discrete_pivot_and_restrict` (line 775)
  - **File**: `DiscreteGameTransfer.lean`
  - **What to write**: This is the core canonical pivot construction. Must:
    1. Define the pivot semantically: given the forward game h_fwd at (4+3n, R) where R = r+4*(n+1), choose pivot c in M and d in N via the forward game's response at 0 rounds (or via the GHR93 formula C = X_{alpha_n} AND NOT-U(NOT-A, TOP) construction)
    2. Prove formula agreement between c and d at rank r (follows from forward game's winning condition + rank conversion)
    3. Prove ordering: X <= C <= Y, X' <= D <= Y'
    4. Apply `discrete_restrict_forward_left/right` with d-consistency hypothesis to get sub-interval forward games at (1+3n, R)
    5. Apply IH to convert forward sub-games to backward sub-games at (n, r+4)
    6. Apply `discrete_game_rank_down` to convert from rank r+4 to rank r
    7. Return the pivot and sub-interval backward games
  - **GHR93 Reference**: Claims 1-2, pp.116-117
  - **Estimated size**: 200-300 lines

- [ ] **Task 2.3**: Fill sorry S2 in `discrete_restrict_forward_left` (line 654)
  - **File**: `DiscreteGameTransfer.lean`
  - **What to write**: Prove d-consistency for the left sub-interval. For any selection of (1+3n) elements from [x, c] padded with c at the end, apply h_fwd (the forward game at (4+3n) rounds) with the padded selection (repeat c for the extra rounds). The winning condition's formula agreement at rank R ensures the response to c must be d. Specifically: c and d agree on all rank-R formulas (from `hcd_type`), so in the forward game play where Spoiler includes c, the response must agree with c on rank-R formulas, which forces it to be d by the formula agreement hypothesis.
  - **GHR93 Reference**: Claim 1, p.116
  - **Existing infrastructure**: `ghr93_duplicator_wins_round_mono` (CustomGame.lean:441), `hcd_type` hypothesis already in scope
  - **Estimated size**: 40-80 lines

- [ ] **Task 2.4**: Fill sorry S3 in `discrete_restrict_forward_right` (line 680)
  - **File**: `DiscreteGameTransfer.lean`
  - **What to write**: Symmetric to Task 2.3 for the right sub-interval [c, y] / [d, y']. The proof structure mirrors `discrete_restrict_forward_left` with left/right swapped.
  - **GHR93 Reference**: Claim 1, p.116
  - **Estimated size**: 40-80 lines

- [ ] **Task 2.5**: Fill sorry S5 in `discrete_backward_extend` (line 822)
  - **File**: `DiscreteGameTransfer.lean`
  - **What to write**: Implement the Cases I-II argument:
    1. Receive Spoiler's n+1 selections alpha_0 < ... < alpha_n from [X', Y'] in N
    2. Count how many are <= D (call this k) vs > D (call this n+1-k)
    3. **Case I** (k >= 1, some alpha <= D): Both sub-intervals have <= n points. Distribute selections to left/right groups, pad each to n elements, apply h_left/h_right n-round sub-strategies, extract actual responses, merge into (n+1)-element response array. Compose via `ghr93_strategy_compose`.
    4. **Case II** (k = 0, all alpha > D): All n+1 points in (D, Y']. Use h_right for alpha_0,...,alpha_{n-1} (n points). For alpha_n, find e_n via Until transfer: h_right preserves rank-(r+4) formulas, U(B,A) has rank r+1 <= r+4, so M satisfies U(B,A)(e_{n-1}). The Until witness z > e_{n-1} with M satisfies B(z) gives e_n = z matching alpha_n's rank-r type.
    5. For Round 2: dispatch to left/right sub-strategy based on whether the challenge point is in [X, C] or [C, Y].
    6. Verify winning condition (order, gap/point, formula agreement) by combining sub-game conditions with pivot agreement.
  - **GHR93 Reference**: Cases I-II, pp.117-118
  - **Estimated size**: 150-250 lines

- [x] **Task 2.6**: Assemble `discrete_backward_step` and `discrete_ghr93_theorem6` *(completed in cycle 5 -- both lemmas delegate to the helper lemmas above and contain no sorry of their own)*

**Timing**: 4 hours remaining

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (estimated 435-725 new lines replacing the 5 sorries)

---

### Phase 3: GHR93 Proposition 7 for Discrete Orders [NOT STARTED]

**Goal**: Prove Proposition 7 -- from sub-interval game wins at strength (f(n), g(n)), derive standard EF game wins at n rounds. This is the composition theorem that converts sub-interval games into a full back-and-forth.

**GHR93 Reference**: Proposition 7, p.115, lines 1293-1340.

**Proof** (induction on n, GHR93 p.115-116):
- **n=0**: Trivial.
- **n -> n+1**: Spoiler picks alpha. Find interval (x_i, x_{i+1}) containing alpha. Apply the f(n+1)-game to find matching e. By Lemma 11 forward (`ghr93_game_implies_decomposition`), get decomposition on sub-intervals (x_i, alpha) and (alpha, x_{i+1}). By Lemma 11 backward (`ghr93_decomposition_implies_game`), get forward games at (1+3f(n), r). By **Theorem 6** (`discrete_ghr93_theorem6`), invert to backward games at (f(n), g(n)). Apply IH on the extended tuple.

**Tasks**:

- [ ] **Task 3.1**: Define `standard_ef_duplicator_wins` or adapt existing
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: The standard EF game for n rounds on matched tuples. Check if `ef_duplicator_wins` (Defs.lean:67) suffices or needs adapting.
  - **Estimated size**: 10-30 lines

- [ ] **Task 3.2**: Prove Proposition 7 induction step for discrete orders
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: Full induction on n using Theorem 6, Lemma 11 both directions, and strategy composition.
  - **GHR93 Reference**: pp.115-116, lines 1293-1340.
  - **Existing infrastructure**: `ghr93_game_implies_decomposition` (Decomposition.lean:117), `ghr93_decomposition_implies_game` (Decomposition.lean:272), `discrete_ghr93_theorem6` (Phase 2).
  - **Estimated size**: 200-350 lines

- [ ] **Task 3.3**: Build verification
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer`
  - `lean_verify discrete_ghr93_proposition7` -- no sorryAx

**Timing**: 2.5 hours

**Depends on**: Phase 2

**Files modified**: `DiscreteGameTransfer.lean` (200-400 new lines)

---

### Phase 4: Bridge Game Wins to Leaf Sorry and Self-Contained Discrete Chain [NOT STARTED]

**Goal**: Wire game wins from Proposition 7 into the ACTUAL leaf sorry (`nf_exist_sf_guarded_backward` at line 2805) via a discrete-only chain, and build a self-contained `discrete_nf_characterizable_by_stavi` that does NOT call the sorry'd general version.

**Critical architectural requirement**: The current `discrete_nf_characterizable_by_stavi` (line 3283) calls the sorry'd `nf_characterizable_by_stavi` at line 3326 to get `char_k_gen` for ALL models. The fix: create `discrete_nf_2var_existence_characterizable` that takes `char_k_correct` only for discrete M, using the game pipeline for the backward direction. This breaks the dependency on the general sorry.

**The non-circular pipeline** (GHR93 Corollary 5 + Propositions 5-7):
```
NF hypotheses (1-var NF + interval types at depth k)
  -> decomposition_agreement at n=0, r=k/2       [Bridge A, sorry-free]
  -> ghr93_duplicator_wins at n=0, r=k/2          [Lemma 11 backward, sorry-free]
  -> [Proposition 7 + Theorem 6]
  -> Standard EF game wins at sufficient rounds
  -> Existential transfers at each depth j < k     [game_win_to_formula_agree + zone_match]
  -> nf_fraisse_compression                        [sorry-free]
  -> 2-var NF equality at depth k
  -> discrete_nf_exist_sf_guarded_backward         [THE LEAF SORRY -- RESOLVED]
```

**Tasks**:

- [ ] **Task 4.1**: Add import of DiscreteGameTransfer to StaviCompleteness.lean
  - **File**: `StaviCompleteness.lean`
  - **Content**: Add `import Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` at top.
  - **Estimated size**: 1 line

- [ ] **Task 4.2**: Prove `discrete_nf_exist_sf_guarded_backward` -- the leaf sorry
  - **File**: `StaviCompleteness.lean` (new theorem near line 2806)
  - **Type signature**: Same as `nf_exist_sf_guarded_backward` (line 2778) plus 5 discrete typeclass instances, and with `char_k_correct` restricted to discrete M.
  - **Proof strategy**:
    1. Extract witness x from the temporal formula (Until/Since gives x with witness_type true)
    2. From `char_k_correct` for discrete M, determine x's 1-var depth-k NF type
    3. Construct the interval data: h_nf_x, h_nf_t (1-var NFs), h_order_xt (ordering), interval_nf_types
    4. Apply `discrete_nf_to_decomposition_agreement` (Bridge A) for (x,t)/(x',t')
    5. Convert to game wins via `ghr93_decomposition_implies_game`
    6. Apply `discrete_ghr93_proposition7` to get standard EF game wins
    7. Extract existential transfers at each depth via formula agreement
    8. Apply `nf_fraisse_compression` to get 2-var NF equality
    9. Conclude sub_nf is the 2-var NF of (x,t), hence the existence holds
  - **GHR93 Reference**: Corollary 5 (p.115) + Propositions 5-7.
  - **Estimated size**: 80-150 lines

- [ ] **Task 4.3**: Prove `discrete_nf_2var_from_interval_data`
  - **File**: `StaviCompleteness.lean` (after Task 4.2)
  - **Type signature**: Same as `nf_2var_from_interval_data` (line 2448) plus discrete instances.
  - **Proof**: Uses the game pipeline (Bridge A -> game wins -> Proposition 7 -> formula agreement -> nf_fraisse_compression) instead of calling `nf_2var_existential_transfer`.
  - **Estimated size**: 60-100 lines

- [ ] **Task 4.4**: Create `discrete_nf_2var_existence_characterizable`
  - **File**: `StaviCompleteness.lean`
  - **Type signature**: Same as `nf_2var_existence_characterizable` (line 2847) but `char_k_correct` restricted to discrete M only.
  - **Proof**: Forward direction uses `nf_exist_sf_guarded_forward` (sorry-free, works for all M). Backward direction uses `discrete_nf_exist_sf_guarded_backward` (Task 4.2).
  - **Critical**: This function takes `char_k_correct` for discrete M only, breaking the dependency on the sorry'd general version.
  - **Estimated size**: 40-60 lines

- [ ] **Task 4.5**: Rewrite `discrete_nf_characterizable_by_stavi` to be self-contained
  - **File**: `StaviCompleteness.lean` (modify existing at line 3283)
  - **Change**: At the succ k case (line 3304), replace the call to `nf_characterizable_by_stavi` (line 3326-3334) with the IH from `discrete_nf_characterizable_by_stavi` itself. Use `discrete_nf_2var_existence_characterizable` (Task 4.4) instead of `nf_2var_existence_characterizable`.
  - **Key insight**: The formula `char_k` from the discrete IH works for all discrete M. The existence formula built from this discrete `char_k` is a concrete StaviFormula -- the same syntax tree. The forward direction works for ALL M (sorry-free). The backward direction is proved for discrete M using the game pipeline.
  - **Estimated size**: 40-80 lines (mostly replacing lines 3326-3347)

- [ ] **Task 4.6**: Verify `discrete_stavi_expressive_completeness` becomes sorry-free
  - **File**: `StaviCompleteness.lean` (existing at line 3423)
  - **Change**: Should become sorry-free automatically once `discrete_nf_characterizable_by_stavi` is self-contained.
  - `lean_verify discrete_stavi_expressive_completeness` -- no sorryAx

- [ ] **Task 4.7**: Modify `US_expressively_complete_over_prior` to use discrete chain
  - **File**: `PriorExpressiveness.lean` (line 371)
  - **Change**: Replace call to `stavi_expressive_completeness` (line 384) with `discrete_stavi_expressive_completeness`. Prior structures satisfy all 5 discrete instances.
  - **Estimated size**: 5-15 lines

- [ ] **Task 4.8**: Build verification
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness`
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx
  - `lean_verify discrete_stavi_expressive_completeness` -- no sorryAx
  - `lean_verify discrete_nf_characterizable_by_stavi` -- no sorryAx

**Timing**: 2.5 hours

**Depends on**: Phase 3

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines, ~30 lines modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 lines modified)

---

### Phase 5: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Full project build, verify `completeness_discrete` sorry state, confirm the sorry chain is eliminated end-to-end.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Verify the full sorry chain is eliminated:
  - `discrete_nf_characterizable_by_stavi` -- no sorryAx
  - `discrete_stavi_expressive_completeness` -- no sorryAx
  - `US_expressively_complete_over_prior` -- no sorryAx
  - `gap_prior_UZ_contradiction` -- no sorryAx
  - `gap_prior_SZ_contradiction` -- no sorryAx
  - `no_gaps_discrete_model_surgery` -- no sorryAx
  - `completeness_discrete` -- either no sorryAx or only through Chain B
- [ ] Verify no new sorry introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows only the 3 existing sorry sites in the general (non-discrete) `nf_2var_existential_transfer` / `nf_exist_sf_guarded_backward`
- [ ] Run existing tests: `lake build BimodalTest`
- [ ] `stavi_expressive_completeness` (general) retains sorry (expected)

**Timing**: 1 hour

**Depends on**: Phase 4

**Files modified**: None (verification only)

---

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_ghr93_theorem6` -- no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_ghr93_proposition7` -- no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_nf_characterizable_by_stavi` -- no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_stavi_expressive_completeness` -- no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` -- no sorryAx
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes
- [ ] `Tests/BimodalTest/` tests pass
- [ ] No import cycles
- [ ] No new sorry in EFGames/ directory beyond existing general versions

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/09_ghr93-game-inversion-plan.md` (this file, v9 revised)
- Modified (Phase 2-3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (600-1000 new lines)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines, ~30 lines modified)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 lines modified)
- `specs/273_chronicle_gap_contradiction_proof/summaries/09_ghr93-game-inversion-summary.md`

## Rollback/Contingency

- **If Claim 1 formalization fails** (the infimum construction is subtle): For discrete orders, c = min{t in [x,y] : for all u in (t,y), C(u)}. This is a finite search in a bounded discrete interval. Use Finset.min or Well-Founded recursion on the interval size.

- **If Case II U(B,A) transfer fails** (formula rank mismatch): Verify that `stavi_temporal_truth_mu` evaluates Until at rank r, and the backward strategy tau preserves formulas at rank r+4 >= r+1. If the rank parameters don't line up, adjust the game_rank/game_depth definitions.

- **If self-contained discrete chain is too complex** (duplication exceeds 400 lines): Factor the shared logic (formula construction, forward direction) into helper lemmas parameterized by the backward direction.

- **If DiscreteGameTransfer.lean build time exceeds heartbeat**: Split into `DiscreteGameTransfer/Theorem6.lean` and `DiscreteGameTransfer/Proposition7.lean`.

- **Git revert** to the commit before implementation if any phase introduces regressions.
