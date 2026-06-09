# Implementation Plan: GHR93 Game Inversion for Discrete Orders (v9)

- **Task**: 273 - Eliminate sorryAx from `US_expressively_complete_over_prior` via GHR93 game-theoretic argument
- **Status**: [NOT STARTED]
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

1. **Wrong sorry target**: Plans v3-v8 targeted lines 2353/2435 (`nf_2var_existential_transfer`), which are **dead code** — they feed only `nf_2var_transfer` which is unused. The actual leaf sorry is at **line 2805** (`nf_exist_sf_guarded_backward`), which cascades to all 7 downstream theorems.

2. **Isolated game file**: `DiscreteGameTransfer.lean` is **not imported** by any file. Completing Theorem 6 there (line 630) without wiring it into StaviCompleteness.lean has no effect on the sorry chain.

3. **General char_k leak**: `discrete_nf_characterizable_by_stavi` (line 3326) calls the sorry'd general `nf_characterizable_by_stavi` for `char_k_gen`, inheriting sorryAx. The fix requires a self-contained discrete chain.

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
  discrete_ghr93_theorem6 (DiscreteGameTransfer.lean:630) -> NOTHING
```

### Strategy (GHR93-Faithful)

Follow GHR93 Chapter 9 exactly:

1. **Theorem 6** (pp.114-119): Game inversion for discrete orders — Claims 1-2 canonical pivot, Cases I-II only
2. **Proposition 7** (p.115): Strategy composition — sub-interval game wins to standard EF game wins
3. **Bridge**: Game wins at sufficient rounds → existential transfer at each depth → `nf_fraisse_compression` → 2-var NF equality → `discrete_nf_exist_sf_guarded_backward`
4. **Wiring**: Self-contained `discrete_nf_characterizable_by_stavi` → `discrete_stavi_expressive_completeness` → `US_expressively_complete_over_prior`

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
| `discrete_formula_agree_from_nf` | NFGameBridge.lean | 749 | NF → formula |
| `nf_fraisse_compression` | StaviCompleteness.lean | 2006 | Fraisse |
| `zone_match_witness` | StaviCompleteness.lean | 2044 | Zone matching |
| `discrete_ghr93_theorem6_zero` | DiscreteGameTransfer.lean | 286 | Thm 6 base |
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
| Theorem 6 Claims 1-2 formalization complexity | H | M | For discrete orders: c is always a carrier point (no gaps), infimum is realized. Claim 1 uses formula C of rank r+1. Claim 2 uses `ghr93_strategy_restrict_left/right` (already sorry-free). Estimated 100-150 lines. |
| Case II U(B,A) transfer | H | M | The formula U(B,A) has rank r+1. The backward strategy tau preserves rank-(r+4) formulas. Since r+1 ≤ r+4, formula agreement gives the transfer. `stavi_temporal_truth_mu` semantics handle Until evaluation. |
| Self-contained discrete char_k chain | M | M | Create `discrete_nf_2var_existence_characterizable` taking `char_k_correct` for discrete M only. The formula construction is identical; only the backward correctness proof differs. ~80-120 lines of duplication with discrete type constraints. |
| DiscreteGameTransfer.lean import wiring | M | L | Currently not imported. Add `import Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` to StaviCompleteness.lean. Verify no import cycles. |
| Rank/depth alignment across Theorem 6 → Proposition 7 → Bridge | M | M | Verify explicitly: Theorem 6 converts (1+3n, r+4n) forward to (n, r) backward. Proposition 7 needs game wins at (f(n), g(n)). Bridge starts from decomposition at n=0, r=k/2. Test alignment in Phase 2 Task 2.1. |

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

**Goal**: Complete the sorry at DiscreteGameTransfer.lean:630 — the inductive step of Theorem 6 for discrete orders. While this file is currently isolated, Phase 4 will import it into StaviCompleteness.lean.

**GHR93 Reference**: Theorem 6, pp.114-119. Claims 1-2 at p.116 (lines 1392-1421 in OCR). Cases I-II at pp.117-118 (lines 1435-1504).

**Proof Architecture** (inductive step, n → n+1):

Given: forward game G_{4+3n; r+4(n+1)}(M, xy; N, x'y'). Spoiler in the backward game picks α_0 < ... < α_n from [x', y'] in N.

1. **Canonical pivot** (Claim 1): Define formulas A = X_{(α_{n-1}, α_n)} (rank-r interval type), C = X_{α_n} ∧ ¬U(¬A, ⊤) (rank r+1). Define c = inf{t ∈ [x,y] : C holds on (t,y)}. For discrete orders, c is a carrier point. Claim 1: in any play where Spoiler includes c, Duplicator's response is always d-bar (unique).

2. **Sub-interval forward games** (Claim 2): From G_{4+3n; R}(M, xy; N, x'y'), extract G_{1+3n; R}(M, xc; N, x' d-bar) and G_{1+3n; R}(M, cy; N, d-bar y'). Uses round monotonicity + Claim 1.

3. **Apply IH**: (1+3n, R) = (1+3n, (r+4)+4n), so IH gives backward games G_{n; r+4}(N, x' d-bar; M, xc) and G_{n; r+4}(N, d-bar y'; M, cy).

4. **Case I** (α_0 < d-bar): Both sub-intervals contain ≤ n alpha-points. Compose backward sub-interval strategies via `ghr93_strategy_compose`.

5. **Case II** (all α_i in (d-bar, y'), α_n is a point): Define B = X_{α_n}, b = sup{t ∈ (x,y) : M ⊨ B(t)}. Use backward strategy τ for G_{n; r+4}(N, d-bar b'; M, c b) for α_0,...,α_{n-1}. Find e_n via **U(B,A) transfer at e_{n-1}**: τ preserves rank-(r+4) formulas, U(B,A) has rank r+1 ≤ r+4, so M ⊨ U(B,A)(e_{n-1}). The Until witness z > e_{n-1} with M ⊨ B(z) gives e_n = z matching α_n's rank-r type.

**Tasks**:

- [ ] **Task 2.1**: Define canonical pivot and formulas A, C, B for discrete orders
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Content**: Define `discrete_canonical_pivot` as the minimum point from which C holds everywhere rightward. For discrete orders, this is a carrier point (no gaps). Define the formulas semantically (as predicates on ExtendedCarrier, not syntactic StaviFormula).
  - **GHR93 Reference**: p.116, lines 1374-1391.
  - **Estimated size**: 40-60 lines

- [ ] **Task 2.2**: Prove Claim 1 (canonical response uniqueness) for discrete orders
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: In any play where Spoiler includes c, Duplicator's response is d-bar. Proof: formula C holds on (c,y) in M. The winning condition transfers rank-(r+1) formulas. If d ≠ d-bar (d < d-bar), Spoiler challenges to derive contradiction.
  - **GHR93 Reference**: Claim 1, p.116, lines 1392-1403.
  - **Estimated size**: 50-80 lines

- [ ] **Task 2.3**: Prove Claim 2 (sub-interval forward games) for discrete orders
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: From G_{4+3n; R}(M, xy; N, x'y'), extract sub-interval forward games at (1+3n, R). Uses `ghr93_duplicator_wins_round_mono` (pad c into selection), Claim 1 (response to c is d-bar), and `ghr93_strategy_restrict_left/right` (restrict to sub-interval).
  - **GHR93 Reference**: Claim 2, p.116, lines 1404-1421.
  - **Existing infrastructure**: `ghr93_strategy_restrict_left` (CustomGame.lean:1241), `ghr93_strategy_restrict_right` (CustomGame.lean:1470), `ghr93_duplicator_wins_round_mono` (CustomGame.lean:441).
  - **Estimated size**: 60-100 lines

- [ ] **Task 2.4**: Prove Case I (split at pivot) for discrete orders
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: α_0 < d-bar. Both sub-intervals contain ≤ n alpha-points. Apply IH to get backward sub-interval games at (n, r+4). Compose via `ghr93_strategy_compose`.
  - **GHR93 Reference**: Case I, p.117, lines 1435-1442.
  - **Existing infrastructure**: `ghr93_strategy_compose` (Composition.lean:40).
  - **Estimated size**: 80-120 lines

- [ ] **Task 2.5**: Prove Case II (all right of pivot, U(B,A) transfer) for discrete orders
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: All α_i in (d-bar, y'). Define B = X_{α_n}, b = sup B-points. Use τ for α_0,...,α_{n-1}. Find e_n via U(B,A) witness at e_{n-1}. Key: τ preserves rank-(r+4) formulas and U(B,A) has rank r+1.
  - **GHR93 Reference**: Case II, pp.117-118, lines 1443-1504.
  - **Critical insight**: e_n found via Until semantics, NOT via forward game Round 2. This guarantees e_n > e_{n-1}.
  - **Estimated size**: 100-150 lines

- [ ] **Task 2.6**: Assemble `discrete_ghr93_theorem6` inductive step
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: Replace the sorry at line 630 with case split on (α_0 < d-bar) → Case I, else → Case II. Combine Tasks 2.1-2.5.
  - **Verification**: `lean_verify discrete_ghr93_theorem6` shows no sorryAx. `lake build Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` succeeds.
  - **Estimated size**: 30-50 lines (assembly)

**Timing**: 4 hours

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (400-600 new lines replacing the sorry at line 630)

---

### Phase 3: GHR93 Proposition 7 for Discrete Orders [NOT STARTED]

**Goal**: Prove Proposition 7 — from sub-interval game wins at strength (f(n), g(n)), derive standard EF game wins at n rounds. This is the composition theorem that converts sub-interval games into a full back-and-forth.

**GHR93 Reference**: Proposition 7, p.115, lines 1293-1340.

**Proof** (induction on n, GHR93 p.115-116):
- **n=0**: Trivial.
- **n → n+1**: Spoiler picks α. Find interval (x_i, x_{i+1}) containing α. Apply the f(n+1)-game to find matching e. By Lemma 11 forward (`ghr93_game_implies_decomposition`), get decomposition on sub-intervals (x_i, α) and (α, x_{i+1}). By Lemma 11 backward (`ghr93_decomposition_implies_game`), get forward games at (1+3f(n), r). By **Theorem 6** (`discrete_ghr93_theorem6`), invert to backward games at (f(n), g(n)). Apply IH on the extended tuple.

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
  - `lean_verify discrete_ghr93_proposition7` — no sorryAx

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
  → decomposition_agreement at n=0, r=k/2       [Bridge A, sorry-free]
  → ghr93_duplicator_wins at n=0, r=k/2          [Lemma 11 backward, sorry-free]
  → [Proposition 7 + Theorem 6]
  → Standard EF game wins at sufficient rounds
  → Existential transfers at each depth j < k     [game_win_to_formula_agree + zone_match]
  → nf_fraisse_compression                        [sorry-free]
  → 2-var NF equality at depth k
  → discrete_nf_exist_sf_guarded_backward         [THE LEAF SORRY — RESOLVED]
```

**Tasks**:

- [ ] **Task 4.1**: Add import of DiscreteGameTransfer to StaviCompleteness.lean
  - **File**: `StaviCompleteness.lean`
  - **Content**: Add `import Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` at top.
  - **Estimated size**: 1 line

- [ ] **Task 4.2**: Prove `discrete_nf_exist_sf_guarded_backward` — the leaf sorry
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

    Wait — this proof structure is wrong. The backward direction needs to show that IF the formula holds THEN there exists x with the NF. The formula is `nf_exist_sf_guarded atomMap h_surj k char_k parent_atoms sub_nf`. From the formula being true, we get a witness x. We need to show `nf_eval_nf M k (1+1) (Fin.cons x (fun _ => t)) sub_nf`.

    The correct approach:
    1. From the formula, extract witness x (from Until/Since semantics)
    2. x satisfies some `char_k nf_x` (from the disjunction in witness_type)
    3. From `char_k_correct`, x has 1-var NF nf_x (for discrete M)
    4. From nf_x, derive atom compatibility with sub_nf at variable 0
    5. For depth 0 (k=0): atom agreement suffices — directly show sub_nf matches
    6. For depth k+1: need existential transfer. Use the game pipeline:
       a. The 1-var NFs at x and t, ordering, and interval types (from the Until/Since guard) provide the Bridge A hypotheses
       b. Apply the game pipeline to get 2-var NF equality
       c. This gives `nf_characteristic M k 2 (x,t) = sub_nf_char` for a specific NF
       d. Since the formula was built from sub_nf, the matching shows nf_eval_nf holds

    Actually, this is still subtle. The backward direction of the existence formula needs to show that the formula truth implies the NF existence. The formula was constructed to detect exactly this NF. The bridge lemma (`nf_2var_from_interval_data`) is what connects the interval data to the 2-var NF.

    The discrete version proves the bridge lemma for discrete M using the game pipeline instead of direct NF induction.
  - **GHR93 Reference**: Corollary 5 (p.115) + Propositions 5-7.
  - **Estimated size**: 80-150 lines

- [ ] **Task 4.3**: Prove `discrete_nf_2var_from_interval_data`
  - **File**: `StaviCompleteness.lean` (after Task 4.2)
  - **Type signature**: Same as `nf_2var_from_interval_data` (line 2448) plus discrete instances.
  - **Proof**: Uses the game pipeline (Bridge A → game wins → Proposition 7 → formula agreement → nf_fraisse_compression) instead of calling `nf_2var_existential_transfer`.
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
  - **Key insight**: The formula `char_k` from the discrete IH works for all discrete M. The existence formula built from this discrete `char_k` is a concrete StaviFormula — the same syntax tree. The forward direction works for ALL M (sorry-free). The backward direction is proved for discrete M using the game pipeline.
  - **Estimated size**: 40-80 lines (mostly replacing lines 3326-3347)

- [ ] **Task 4.6**: Verify `discrete_stavi_expressive_completeness` becomes sorry-free
  - **File**: `StaviCompleteness.lean` (existing at line 3423)
  - **Change**: Should become sorry-free automatically once `discrete_nf_characterizable_by_stavi` is self-contained.
  - `lean_verify discrete_stavi_expressive_completeness` — no sorryAx

- [ ] **Task 4.7**: Modify `US_expressively_complete_over_prior` to use discrete chain
  - **File**: `PriorExpressiveness.lean` (line 371)
  - **Change**: Replace call to `stavi_expressive_completeness` (line 384) with `discrete_stavi_expressive_completeness`. Prior structures satisfy all 5 discrete instances.
  - **Estimated size**: 5-15 lines

- [ ] **Task 4.8**: Build verification
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness`
  - `lean_verify US_expressively_complete_over_prior` — no sorryAx
  - `lean_verify discrete_stavi_expressive_completeness` — no sorryAx
  - `lean_verify discrete_nf_characterizable_by_stavi` — no sorryAx

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
  - `discrete_nf_characterizable_by_stavi` — no sorryAx
  - `discrete_stavi_expressive_completeness` — no sorryAx
  - `US_expressively_complete_over_prior` — no sorryAx
  - `gap_prior_UZ_contradiction` — no sorryAx
  - `gap_prior_SZ_contradiction` — no sorryAx
  - `no_gaps_discrete_model_surgery` — no sorryAx
  - `completeness_discrete` — either no sorryAx or only through Chain B
- [ ] Verify no new sorry introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows only the 3 existing sorry sites in the general (non-discrete) `nf_2var_existential_transfer` / `nf_exist_sf_guarded_backward`
- [ ] Run existing tests: `lake build BimodalTest`
- [ ] `stavi_expressive_completeness` (general) retains sorry (expected)

**Timing**: 1 hour

**Depends on**: Phase 4

**Files modified**: None (verification only)

---

## Testing & Validation

- [ ] `lake build` completes without errors
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_ghr93_theorem6` — no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_ghr93_proposition7` — no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_nf_characterizable_by_stavi` — no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.discrete_stavi_expressive_completeness` — no sorryAx
- [ ] `lean_verify Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` — no sorryAx
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes
- [ ] `Tests/BimodalTest/` tests pass
- [ ] No import cycles
- [ ] No new sorry in EFGames/ directory beyond existing general versions

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/09_ghr93-game-inversion-plan.md` (this file, v9)
- Modified (Phase 2-3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (600-1000 new lines)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines, ~30 lines modified)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 lines modified)
- `specs/273_chronicle_gap_contradiction_proof/summaries/09_ghr93-game-inversion-summary.md`

## Rollback/Contingency

- **If Claim 1 formalization fails** (the infimum construction is subtle): For discrete orders, c = min{t ∈ [x,y] : ∀u ∈ (t,y), C(u)}. This is a finite search in a bounded discrete interval. Use Finset.min or Well-Founded recursion on the interval size.

- **If Case II U(B,A) transfer fails** (formula rank mismatch): Verify that `stavi_temporal_truth_mu` evaluates Until at rank r, and the backward strategy τ preserves formulas at rank r+4 ≥ r+1. If the rank parameters don't line up, adjust the game_rank/game_depth definitions.

- **If self-contained discrete chain is too complex** (duplication exceeds 400 lines): Factor the shared logic (formula construction, forward direction) into helper lemmas parameterized by the backward direction.

- **If DiscreteGameTransfer.lean build time exceeds heartbeat**: Split into `DiscreteGameTransfer/Theorem6.lean` and `DiscreteGameTransfer/Proposition7.lean`.

- **Git revert** to the commit before implementation if any phase introduces regressions.
