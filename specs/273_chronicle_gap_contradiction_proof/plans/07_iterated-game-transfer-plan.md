# Implementation Plan: Iterated Game Transfer for Stavi Expressive Completeness (v7)

- **Task**: 273 - Fill the EF game sorry in StaviCompleteness.lean to make {U,S,U',S'} expressively complete
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (Phases 0-1 from v3 are completed)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/05_proposition7-research.md, specs/273_chronicle_gap_contradiction_proof/reports/03_team-research.md, specs/273_chronicle_gap_contradiction_proof/.bridge-research.md, specs/273_chronicle_gap_contradiction_proof/.blocker-research.md, specs/273_chronicle_gap_contradiction_proof/handoffs/phase-2-handoff-20260609T010703Z.md, specs/273_chronicle_gap_contradiction_proof/handoffs/phase-2-handoff-20260609T014644Z.md
- **Artifacts**: plans/07_iterated-game-transfer-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan (v7) replaces the BLOCKED v6 Phase 2 with a new approach based on the Proposition 7 research report (05_proposition7-research.md). The research identified that the v3-v6 approaches all failed for the same root cause: multi-variable NF transfer requires controlling sub-interval type arrangements, which cannot be done by zone-matching one variable at a time. The resolution is two new theorems (~300-450 lines total):

1. **`discrete_game_subinterval_restrict`**: Given a G_{0;r} game win on (x,t)/(x',t') and a matched pair (u,u'), derive G_{0;r} games on the sub-intervals (x,u)/(x',u') and (u,t)/(u',t').
2. **`discrete_iterated_game_transfer`**: By induction on depth j, use the game oracle to match each new variable, then use sub-interval restriction to recurse at lower depth.

This approach avoids the full Proposition 7 + Theorem 6 machinery (~500-800 lines) by exploiting discrete-order simplifications: no gaps (Cases III/IV vacuous), and the n=0 game suffices via iterated application.

### Research Integration

Integrated reports:
- `reports/05_proposition7-research.md` (NEW) -- Complete GHR93 Proposition 7 analysis, existing infrastructure inventory, simplified discrete path (Section 5.4), dependency diagram, risk assessment including rank-depth conversion
- `.bridge-research.md` -- Game pipeline inventory, gap analysis, three feasible paths
- `.blocker-research.md` -- Three resolution paths evaluated; strengthened zone match confirmed unprovable
- `handoffs/phase-2-handoff-20260609T010703Z.md` -- Phase 2 blocker details, sorry site goal states, five failed approaches
- `handoffs/phase-2-handoff-20260609T014644Z.md` -- Seven approaches analyzed, root cause confirmed

### Prior Plan Reference

**v3 (separation bypass)**: Blocked because the separation result (GHR94 Ch 10.2) is proved for Z-carrier structures only. `eval` quantifies over `M.carrier`, and arbitrary Prior carriers may differ from Z.

**v4 (EF game completion)**: Phase 2 blocked on the interval-splitting problem. `zone_match_witness` finds u' with the same depth-k 1-var NF and correct orderings relative to x' and t', but does NOT guarantee sub-interval type matching for (x,u)/(x',u') and (u,t)/(u',t').

**v5 (strengthened zone match)**: Phase 2 blocked because `interval_nf_types` is a `Finset`, not an ordered sequence. Two linear orders can have the same set of 1-var NF types but different arrangements.

**v6 (discrete game bypass)**: Phase 2 blocked because the game at n=0 only matches ONE variable. The nested multi-variable transfer at depth j' needs sub-interval games on sub-intervals created by inner variable matching. The v6 approach attempted strong induction on k but the circularity at the top depth (j=k-1 needing 2-var NF at depth k, which IS the goal) was never resolved. Six specific sub-approaches failed (documented in v6 Phase 2 BLOCKER section).

**Root cause (all four)**: NF-based proof processes variables one at a time via zone matching. Each zone match preserves orderings relative to interval ENDPOINTS but loses information about orderings relative to previously matched INNER points. The game-based approach resolves this by providing a point-matching oracle that preserves all combinatorial structure simultaneously, plus sub-interval restriction to derive game strategies on newly created sub-intervals.

### Existing Infrastructure (Sorry-Free)

**NFGameBridge.lean**:

| Theorem | Line | Purpose |
|---------|------|---------|
| `nvar_nf_eq_depth_zero` | 127 | Depth-0 n-var NF from atom agreement |
| `atom_agree_from_pointwise_nf` | 140 | n-var atom agree from pointwise 1-var NF + orderings |
| `discrete_muSig_nf_agree` | 332 | sig NF agree -> muSig NF agree (discrete) |
| `discrete_nf_profile_agree` | 503 | depth-k NF agree -> nf_profile agree |
| `discrete_rank_type_agree` | 531 | depth-k NF agree -> rank_type agree at k/2 |
| `discrete_formula_agree_from_nf` | 749 | depth-k NF agree -> StaviFormula agree at k/2 |
| `existential_transfer_from_nf` | 719 | n-var NF agree at d+1 -> (n+1)-var existential transfer at d |
| `discrete_winning_condition_0` | 815 | 3-element winning condition from pairwise NF + orderings |
| `discrete_nf_to_decomposition_agreement` | 997 | **Bridge A**: NF hypotheses -> decomp agreement at n=0, r=k/2 |
| `game_win_to_formula_agree` | 1222 | Extract formula agreement from winning condition |

**CustomGame.lean**:

| Theorem | Line | Purpose |
|---------|------|---------|
| `ghr93_duplicator_wins` (def) | 285 | Duplicator winning strategy definition |
| `ghr93_duplicator_wins_round_mono` | 441 | n' <= n -> game at n implies n' |
| `ghr93_strategy_restrict_left` | 1241 | Restrict (n+1)-game to left sub-interval |
| `ghr93_strategy_restrict_right` | 1470 | Restrict (n+1)-game to right sub-interval |

**Composition.lean**:

| Theorem | Line | Purpose |
|---------|------|---------|
| `ghr93_strategy_compose` | 40 | Compose left + right sub-interval games at same (n,r) |

**Decomposition.lean**:

| Theorem | Line | Purpose |
|---------|------|---------|
| `ghr93_decomposition_implies_game` | 272 | Decomposition agreement -> game win |
| `ghr93_game_implies_decomposition` | 117 | Game win -> decomposition agreement |

## Goals & Non-Goals

**Goals**:
- Prove `discrete_game_subinterval_restrict` -- derive sub-interval G_{0;r} games from full-interval game + matched split point
- Prove `discrete_iterated_game_transfer` -- depth-induction proving existential transfer using game oracle + sub-interval restriction
- Wire into the sorry sites at StaviCompleteness.lean:2353, 2435, 2805 via discrete-specific wrapper theorems
- Make `US_expressively_complete_over_prior` sorry-free (Prior structures are discrete)
- Verify via `#print axioms completeness_discrete` that sorryAx is removed from Chain A

**Non-Goals**:
- Filling `nf_2var_existential_transfer` for arbitrary linear orders (the original sorry remains for non-discrete cases)
- Proving `completeness_dense` sorry-free
- Full GHR93 Proposition 7 + Theorem 6 for general orders (~500-800 lines, unnecessary for discrete)
- Modifying `PriorExpressiveness.lean` or downstream consumers beyond re-pointing to discrete-specific theorems
- Refactoring the EF game infrastructure beyond what is needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sub-interval restriction requires (n+1)-game but we only have n=0 game | H | M | The restriction theorems (`ghr93_strategy_restrict_left/right`) take an (n+1)-game and produce an n-game on sub-intervals. We have a 0-game. Approach: promote the 0-game to a 1-game by using the matched point u as the single "padded" element (a_pad = [u]). Then restrict_left gives 0-game on (x,u), restrict_right gives 0-game on (u,t). Detailed implementation in Phase 2 Task 2.1. |
| Odd-k parity: rank k/2 gives NF at depth 2*(k/2) = k-1 for odd k | M | M | Bridge A produces decomposition_agreement at r=k/2. For even k: 2*(k/2)=k, covers all depths j<k. For odd k: 2*(k/2)=k-1, covers depths j<k-1 but NOT j=k-1. Resolution: the induction is on depth j (decreasing). At j=k-1 for odd k, the game-matched point has NF agreement at depth k-1 (not k). But `existential_transfer_from_nf` at depth j needs NF at depth j+1=k. We have depth-k NF for boundary points (h_nf_x, h_nf_t) from the hypotheses. For inner matched points, use the hypothesis that k is the outer depth. If needed, use `nf_char_depth_le` to drop from depth k to k-1 for inner variables, and the boundary variables already have depth k. The critical observation: the sorry targets existential transfer at j<k, and the boundary point NFs at depth k suffice for the outer induction. Inner variable matching only needs depth k-1, which k/2 rank always provides. |
| `ghr93_strategy_restrict_left/right` d-consistency hypothesis | M | L | These restrict theorems require a `h_d_consistent` argument: an (n+1)-game strategy where the last element is fixed to the split point. This is exactly what the 0-game gives when promoted to a 1-game with u as the fixed element. The d-consistency is satisfied because the 0-game strategy, when asked with a_pad = [extendPoint u], responds with some a'_full where a'_full[0] = extendPoint u' (by the winning condition's same_order_type at the matched position). Need to verify the h_d_consistent witness construction carefully. |
| Discrete instances propagation through game infrastructure | L | L | `discrete_no_gaps` (Defs.lean:532) ensures ExtendedCarrier = M.carrier for discrete orders. Existing bridge lemmas handle the conversion. All new theorems will carry the 10 discrete instances explicitly. |
| Build time for modified files | M | M | Place all new lemmas in NFGameBridge.lean (or new DiscreteGameTransfer.lean). Keep StaviCompleteness.lean modifications minimal: only replace sorry calls with applications of discrete theorems. |

### Critical Risk Detail: The Promotion from 0-Game to 1-Game

The existing `ghr93_strategy_restrict_left` has signature:
```
ghr93_strategy_restrict_left
  (hxc : x <= c) (hcy : c <= y) (hx'd : x' <= d) (hdy' : d <= y')
  (hcd_type : formula_agreement at c/d)
  (hcd_gp : point/gap agreement at c/d)
  (h_d_consistent : (n+1)-game strategy with last element fixed to c/d)
  (h_pt : point exists in [x',y'])
  : ghr93_duplicator_wins M N atomMap n r x c x' d
```

For our use case: n=0, so we need a 1-game strategy with last element fixed to c. We have a 0-game on (x,y)/(x',y'). To promote:

1. From `ghr93_duplicator_wins M N atomMap 0 r x y x' y'`, instantiate with the empty selection (a = Fin.elim0) to get the round-2 matching.
2. Construct a 1-game: when Spoiler picks a_pad = [c], Duplicator responds with a'_full = [d]. The winning condition at n=1 requires same_order_type for the tuple (x, c, b, y)/(x', d, b', y'), formula_agreement at b/b', and gap/point agreement. The 0-game already provides the round-2 response for arbitrary b' in [x',y'], so the 1-game promotion gives the round-2 for b' in [x',d] (a sub-range).
3. The h_d_consistent hypothesis is then satisfied by this constructed 1-game.

This promotion is the main technical content of `discrete_game_subinterval_restrict` (~100-150 lines).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |

Phase 0 (axiom audit) and Phase 1 (SemanticBridge) from v3 are already [COMPLETED].

---

### Phase 0: Axiom Audit and Sorry State Verification [COMPLETED]

(From v3 plan -- already completed.)

- **Completed**: 2026-06-08

---

### Phase 1: SemanticBridge Infrastructure [COMPLETED]

(From v3 plan -- already completed.)

- **Completed**: 2026-06-08

---

### Phase 2: Sub-Interval Game Restriction and Iterated Transfer [NOT STARTED]

**Goal**: Prove two new theorems in NFGameBridge.lean: (1) `discrete_game_subinterval_restrict` derives sub-interval G_{0;r} games from a full-interval game plus a matched split point, and (2) `discrete_iterated_game_transfer` proves existential NF transfer at arbitrary depth j<k by induction on j, using the game oracle for witness matching and sub-interval restriction for recursive sub-problems.

**Tasks**:

- [ ] **Task 2.1**: Prove `discrete_game_subinterval_restrict`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Location**: After `game_win_to_formula_agree` (line ~1237), before `end` namespace
  - **Exact type signature**:
    ```lean
    theorem discrete_game_subinterval_restrict {sig : MonadicSignature}
        {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        {r : Nat}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        {x y : ExtendedCarrier M atomMap r}
        {x' y' : ExtendedCarrier N atomMap r}
        (h_game : ghr93_duplicator_wins M N atomMap 0 r x y x' y')
        (u : M.carrier) (u' : N.carrier)
        (h_xu : extendPoint (sig := sig) (atomMap := atomMap) (r := r) x ≤
                extendPoint (sig := sig) (atomMap := atomMap) (r := r) u)
        (h_uy : extendPoint (sig := sig) (atomMap := atomMap) (r := r) u ≤
                extendPoint (sig := sig) (atomMap := atomMap) (r := r) y)
        (h_x'u' : extendPoint (sig := sig) (atomMap := atomMap) (r := r) x' ≤
                  extendPoint (sig := sig) (atomMap := atomMap) (r := r) u')
        (h_u'y' : extendPoint (sig := sig) (atomMap := atomMap) (r := r) u' ≤
                  extendPoint (sig := sig) (atomMap := atomMap) (r := r) y')
        (h_formula : ∀ (A : StaviFormula), stavi_depth A ≤ r →
          (stavi_temporal_truth_mu M atomMap r
            (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) A ↔
           stavi_temporal_truth_mu N atomMap r
            (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u') A))
        (h_gp : (IsPoint (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) ↔
                 IsPoint (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u')) ∧
                (IsGap (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u) ↔
                 IsGap (extendPoint (sig := sig) (atomMap := atomMap) (r := r) u')))
        (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p)) :
        ghr93_duplicator_wins M N atomMap 0 r x (extendPoint u) x' (extendPoint u') ∧
        ghr93_duplicator_wins M N atomMap 0 r (extendPoint u) y (extendPoint u') y'
    ```
  - **Proof strategy** (step by step):
    1. Promote the 0-game `h_game` to a 1-game with `u` as the fixed element. Construct `h_d_consistent` for `ghr93_strategy_restrict_left`: when Spoiler picks `a_pad = fun _ => extendPoint u`, Duplicator's response from the 0-game (applied to empty selection) gives the round-2 matching. Set `a'_full = fun _ => extendPoint u'`.
    2. Verify the winning condition at n=1: `same_order_type` for the 4-tuple `(x, extendPoint u, b, y)/(x', extendPoint u', b', y')` follows from the 0-game's winning condition for `(x, b, y)/(x', b', y')` plus the ordering of u relative to x, y (given by h_xu, h_uy) and u' relative to x', y'.
    3. Apply `ghr93_strategy_restrict_left` with n=0 to get `ghr93_duplicator_wins M N atomMap 0 r x (extendPoint u) x' (extendPoint u')`.
    4. Apply `ghr93_strategy_restrict_right` with n=0 to get `ghr93_duplicator_wins M N atomMap 0 r (extendPoint u) y (extendPoint u') y'`.
    5. Return the conjunction.
  - **Existing lemmas called**: `ghr93_strategy_restrict_left` (CustomGame.lean:1241), `ghr93_strategy_restrict_right` (CustomGame.lean:1470), `ghr93_duplicator_wins` (definition, CustomGame.lean:285)
  - **Estimated size**: 100-150 lines
  - **Acceptance criteria**: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds, `lean_verify` shows no sorryAx

- [ ] **Task 2.2**: Prove `discrete_iterated_game_transfer`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Location**: After `discrete_game_subinterval_restrict`
  - **Exact type signature**:
    ```lean
    theorem discrete_iterated_game_transfer {sig : MonadicSignature}
        {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        {k : Nat}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
        [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
        (x t : M.carrier) (x' t' : M'.carrier)
        (h_game : ghr93_duplicator_wins M M' atomMap 0 (k / 2)
          (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t'))
        (h_game_bwd : ghr93_duplicator_wins M' M atomMap 0 (k / 2)
          (extendPoint x') (extendPoint t') (extendPoint x) (extendPoint t))
        (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
                  nf_characteristic M' k 1 (fun _ => x'))
        (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
                  nf_characteristic M' k 1 (fun _ => t'))
        (h_order_xt : ∀ i j : Fin 2,
          (Fin.cons x (fun _ => t) i < Fin.cons x (fun _ => t) j ↔
           Fin.cons x' (fun _ => t') i < Fin.cons x' (fun _ => t') j))
        (h_pt : ∃ (p : M'.carrier),
          inClosedInterval (extendPoint x') (extendPoint t') (extendPoint p))
        (h_pt_M : ∃ (p : M.carrier),
          inClosedInterval (extendPoint x) (extendPoint t) (extendPoint p)) :
        ∀ j, j < k →
          ∀ chi : NormalForm sig j (2 + 1),
            (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
            (∃ u', nf_eval_nf M' j (2 + 1)
              (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi)
    ```
  - **Induction structure**: Strong induction on `j` (strictly decreasing depth). The measure is `j`. Base case: `j = 0`. Inductive case: `j = d + 1`, assuming the result for all `j' < d + 1`.
  - **Proof strategy** (step by step):
    1. **Base case (j = 0)**: At depth 0, `nf_eval_nf` is purely atomic. Use `zone_match_witness` to find u' from u (or vice versa). With pointwise 1-var NF agreement at all 3 points (x/x', t/t', u/u') plus orderings, apply `atom_agree_from_pointwise_nf` (NFGameBridge.lean:140) to get 3-var atom agreement. Then `nvar_nf_eq_depth_zero` (NFGameBridge.lean:127) gives depth-0 3-var NF equality. Extract the existential transfer.
    2. **Inductive case (j = d + 1, d + 1 < k)**: Forward direction (exists u => exists u'):
       a. Given u in M, use the game oracle: instantiate `h_game` with empty selection (a = Fin.elim0). Spoiler challenges with u' in [x',t']. The game responds with b in M such that `ghr93_winning_condition` holds. Extract from the winning condition: formula agreement at rank k/2 between b and u' via `game_win_to_formula_agree` (NFGameBridge.lean:1222).
       b. BUT we need the FORWARD direction: given u in M, find u' in M'. The 0-game `h_game` gives: for all b' in [x',t'], exists b in [x,t] with winning condition. We need the REVERSE: given u in [x,t], find u' in [x',t']. Use `h_game_bwd`: the backward game. Instantiate with empty selection, Spoiler challenges with u in [x,t]. Game responds with u' in [x',t'] with winning condition. Extract formula agreement at rank k/2 via `game_win_to_formula_agree`.
       c. For discrete orders, formula agreement at rank k/2 implies 1-var NF agreement at depth 2*(k/2) via `discrete_formula_agree_from_nf` (NFGameBridge.lean:749). Since 2*(k/2) >= k-1, we get NF agreement at depth k-1 (and depth k for even k).
       d. With 1-var NF agreement at u/u' at depth >= k-1, plus h_nf_x, h_nf_t, plus orderings from the game winning condition, we have:
          - Atom agreement at 3 vars (u,x,t)/(u',x',t'): via `atom_agree_from_pointwise_nf`.
          - Depth-0 3-var NF: via `nvar_nf_eq_depth_zero`.
          - For the quantifier part at depth d+1: need 4-var existential transfer at depth d. Apply `existential_transfer_from_nf` (NFGameBridge.lean:719) which needs 3-var NF agreement at depth d+1. Get 3-var NF agreement at depth d+1 by: atoms (proved above) + quantifier transfer at depth d (induction hypothesis with IH at d < d+1).
       e. For the IH application at depth d: need game strategies on sub-intervals containing (u,x)/(u',x') and (u,t)/(u',t'). Apply `discrete_game_subinterval_restrict` (from Task 2.1) using u/u' as the split point to get G_{0;k/2} on both sub-intervals. Then recurse with the IH.
       f. Backward direction: symmetric, using `h_game` for the forward game to find u from u'.
  - **Key sub-lemma needed** (may be proved inline or as a separate `have`):
    - `discrete_3var_nf_from_game`: Given game-matched (u,u') with formula agreement, plus h_nf_x, h_nf_t, prove 3-var NF agreement at (u,x,t)/(u',x',t') at depth d+1, using the IH at depth d for the 4-var existential transfer. This is the inductive core.
  - **Existing lemmas called**: `zone_match_witness` (StaviCompleteness.lean:2044), `atom_agree_from_pointwise_nf` (NFGameBridge.lean:140), `nvar_nf_eq_depth_zero` (NFGameBridge.lean:127), `existential_transfer_from_nf` (NFGameBridge.lean:719), `game_win_to_formula_agree` (NFGameBridge.lean:1222), `discrete_formula_agree_from_nf` (NFGameBridge.lean:749), `discrete_game_subinterval_restrict` (from Task 2.1), `nf_char_depth_le` (NFGameBridge.lean:104)
  - **Estimated size**: 150-200 lines
  - **Acceptance criteria**: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds, `lean_verify` shows no sorryAx

- [ ] **Task 2.3**: Handle the rank-depth conversion factor
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Location**: Inside `discrete_iterated_game_transfer` proof (integrated into Task 2.2)
  - **Issue**: Bridge A gives decomposition_agreement at r=k/2. `game_win_to_formula_agree` extracts formula agreement at rank r=k/2. `discrete_formula_agree_from_nf` converts back to NF agreement at depth 2*(k/2). For even k: 2*(k/2) = k, sufficient for all j < k. For odd k: 2*(k/2) = k-1, sufficient for j < k-1 but NOT for j = k-1.
  - **Resolution strategy**: The induction on j handles this naturally. At j = d+1 < k, the IH gives the result at d. The atom agreement at 3 vars is always available (NF at depth k-1 suffices for atoms). The quantifier transfer at depth d needs 3-var NF at depth d+1. For d+1 < k-1 (equivalently d < k-2): depth-(k-1) NF from the game-matched point suffices via `nf_char_depth_le`. For d+1 = k-1 (equivalently d = k-2, j = k-1): this is the top depth. At j = k-1, `existential_transfer_from_nf` needs 3-var NF at depth k. But the boundary points x/x', t/t' have depth-k NF (from h_nf_x, h_nf_t), and the inner matched point u/u' has depth (k-1) NF. The 3-var NF at depth k from a 2-var environment (x,t) at depth k is available from the hypotheses (it IS the thing we are ultimately proving, but at the 2-var level, not 3-var). For the 3-var level, we actually need the 4-var transfer at depth k-2, which is covered by the IH (since k-2 < k-1 = j). So the recursion works: j=k-1 -> needs 3-var NF at k -> needs 4-var transfer at k-2 -> IH at j'=k-2 < k-1.
  - **Concrete approach**: Use `nf_char_depth_le` (NFGameBridge.lean:104) to step from depth-(k-1) NF to depth-j NF wherever j <= k-1. For the j=k-1 case, the quantifier part at depth d=k-2 is handled by the IH. The atoms at depth k-1 are handled by the game-derived NF. No separate parity case split is needed.
  - **Estimated size**: 0 additional lines (integrated into Task 2.2 proof)

- [ ] **Task 2.4**: Build verification for Phase 2
  - Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`
  - Verify no sorry in new theorems: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - Verify type signatures match expected inputs/outputs

**Timing**: 3 hours

**Depends on**: Phases 0, 1 (completed)

**Files to create/modify**:
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (250-350 new lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No sorry in NFGameBridge.lean new theorems
- `discrete_game_subinterval_restrict` and `discrete_iterated_game_transfer` type signatures verified

---

### Phase 3: Wire Discrete Bridge into StaviCompleteness.lean [NOT STARTED]

**Goal**: Replace the three sorry sites in StaviCompleteness.lean with calls to the discrete-specific theorems from Phase 2. Create a discrete-specific completeness chain: `discrete_nf_2var_existential_transfer` -> `discrete_nf_2var_from_interval_data` -> `discrete_stavi_expressive_completeness`. Modify `US_expressively_complete_over_prior` to use the discrete chain.

**Wiring strategy**:

The sorry sites are inside `nf_2var_existential_transfer` (line 2214) which has NO discrete instances. We cannot add instances to it. Instead:

1. Create `discrete_nf_2var_existential_transfer` that wraps `discrete_iterated_game_transfer` with the NF-to-game conversion (Bridge A).
2. Create `discrete_nf_2var_from_interval_data` that calls (1) via `nf_fraisse_compression`.
3. Create `discrete_nf_exist_sf_guarded_backward` that mirrors the sorry'd version using (2).
4. Create `discrete_nf_2var_exist_sf_classical` using (3).
5. Create `discrete_stavi_expressive_completeness` using (4) instead of the sorry'd versions.
6. In `PriorExpressiveness.lean`, change `US_expressively_complete_over_prior` to call `discrete_stavi_expressive_completeness`.

**Tasks**:

- [ ] **Task 3.1**: Prove `discrete_nf_2var_existential_transfer`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after `nf_2var_existential_transfer`, around line 2440)
  - **Exact type signature**: Same as `nf_2var_existential_transfer` (line 2214) plus 10 discrete instances:
    ```lean
    theorem discrete_nf_2var_existential_transfer {sig : MonadicSignature}
        {M M' : OrderedMonadicStructure sig}
        (atomMap : Formula → sig.preds)
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
        [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
        (k : Nat) (x t : M.carrier) (x' t' : M'.carrier)
        (char_k : NormalForm sig k 1 → StaviFormula)
        (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
            (N : OrderedMonadicStructure sig) (t : N.carrier),
            stavi_temporal_truth N atomMap t (char_k nf_k) ↔
            nf_eval_nf N k 1 (fun _ => t) nf_k)
        (h_nf_x h_nf_t h_order_xt h_interval_above h_interval_below
         h_above_max h_below_min : <same as nf_2var_existential_transfer>) :
        ∀ j, j < k →
          ∀ chi : NormalForm sig j (2 + 1),
            (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
            (∃ u', nf_eval_nf M' j (2 + 1)
              (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi)
    ```
  - **Proof strategy**:
    1. Apply `discrete_nf_to_decomposition_agreement` (NFGameBridge.lean:997) to get `decomposition_agreement` at n=0, r=k/2.
    2. Apply `ghr93_decomposition_implies_game` (Decomposition.lean:272) to convert to `ghr93_duplicator_wins M M' atomMap 0 (k/2) (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')`.
    3. Similarly get the backward game (`ghr93_duplicator_wins M' M ...`) by applying Bridge A with swapped hypotheses and then `ghr93_decomposition_implies_game`.
    4. Construct the ordering hypothesis `h_order_xt_fin` from `h_order_xt`.
    5. Construct point-existence hypotheses from discrete order instances.
    6. Apply `discrete_iterated_game_transfer` (from Phase 2).
  - **Existing lemmas called**: `discrete_nf_to_decomposition_agreement` (NFGameBridge.lean:997), `ghr93_decomposition_implies_game` (Decomposition.lean:272), `discrete_iterated_game_transfer` (Phase 2)
  - **Estimated size**: 30-50 lines

- [ ] **Task 3.2**: Prove `discrete_nf_2var_from_interval_data`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after `discrete_nf_2var_existential_transfer`)
  - **Type signature**: Same as `nf_2var_from_interval_data` (line 2448) plus discrete instances.
  - **Proof**: Identical to `nf_2var_from_interval_data` but calls `discrete_nf_2var_existential_transfer` instead of `nf_2var_existential_transfer`. Copy the non-sorry'd parts of `nf_2var_from_interval_data` and replace the sorry calls.
  - **Estimated size**: 20-40 lines (mostly delegation)

- [ ] **Task 3.3**: Prove `discrete_nf_exist_sf_guarded_backward`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after `discrete_nf_2var_from_interval_data`)
  - **Type signature**: Same as `nf_exist_sf_guarded_backward` (line 2778) plus discrete instances.
  - **Proof**: Mirror the structure of `nf_exist_sf_guarded_backward` (the sorry'd version), replacing `nf_2var_from_interval_data` with `discrete_nf_2var_from_interval_data`.
  - **Estimated size**: 20-40 lines

- [ ] **Task 3.4**: Prove `discrete_nf_2var_exist_sf_classical`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after `discrete_nf_exist_sf_guarded_backward`)
  - **Type signature**: Same as `nf_2var_exist_sf_classical` (line 2810) plus discrete instances.
  - **Proof**: Mirror `nf_2var_exist_sf_classical`, using `discrete_nf_exist_sf_guarded_backward` for the backward direction.
  - **Estimated size**: 20-30 lines

- [ ] **Task 3.5**: Prove `discrete_stavi_expressive_completeness`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after `stavi_expressive_completeness`, near end of file around line 3270)
  - **Type signature**:
    ```lean
    noncomputable def discrete_stavi_expressive_completeness
        (sig : MonadicSignature) (atomMap : Formula → sig.preds)
        (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
        {M : OrderedMonadicStructure sig}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        (psi : MonadicFormula sig 1) :
        { A : StaviFormula // ∀ (N : OrderedMonadicStructure sig)
          [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
          [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
          (t : N.carrier),
          stavi_temporal_truth N atomMap t A ↔
          Bimodal.Semantics.MonadicFormula.satisfies N t psi }
    ```
  - **Proof**: Copy the inductive construction from `stavi_expressive_completeness`, replacing the sorry-dependent calls (`nf_2var_exist_sf_classical`) with `discrete_nf_2var_exist_sf_classical`. The induction structure on k (depth of NF) is identical. Only the internal calls to the bridge lemma chain differ.
  - **Note**: If the duplication is prohibitively large (>200 lines), an alternative is to prove that for discrete structures, `nf_2var_from_interval_data` follows from `discrete_nf_2var_from_interval_data` (i.e., fill the sorry under discrete instance availability). This would make the existing `stavi_expressive_completeness` sorry-free when applied to discrete structures. However, this requires `Classical.choice` branching on instance availability, which is not sound. The duplication approach is cleaner.
  - **Estimated size**: 60-100 lines

- [ ] **Task 3.6**: Modify `US_expressively_complete_over_prior` in PriorExpressiveness.lean
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean`
  - **Change**: Replace the call to `stavi_expressive_completeness` with `discrete_stavi_expressive_completeness`. Prior structures satisfy all 5 discrete instances (`SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `IsSuccArchimedean`) -- verify this by checking the instances on `Prior.carrier` (which is `Int`).
  - **Estimated size**: 5-10 lines

- [ ] **Task 3.7**: Verify sorry chain eliminated
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx
  - `lean_verify gap_prior_UZ_contradiction` -- no sorryAx
  - `lean_verify gap_prior_SZ_contradiction` -- no sorryAx
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness`

**Timing**: 2 hours

**Depends on**: Phase 2

**Files to create/modify**:
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (150-260 new lines)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-10 modified lines)

**Verification**:
- `US_expressively_complete_over_prior` has no sorryAx
- `gap_prior_UZ_contradiction` has no sorryAx
- `gap_prior_SZ_contradiction` has no sorryAx
- `lake build` succeeds for the modified modules

---

### Phase 4: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Run full project build, verify `completeness_discrete` sorry state, and confirm Chain A is eliminated end-to-end.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Run `#print axioms completeness_discrete` and compare against Phase 0 baseline:
  - If `sorryAx` is gone: Chain A is fully eliminated, task is complete
  - If `sorryAx` remains: identify which chain (should be Chain B only, already bypassed by task 281)
- [ ] Verify the full Chain A sorry chain is eliminated:
  - `stavi_expressive_completeness` -- general version still has sorry (expected, non-discrete)
  - `discrete_stavi_expressive_completeness` -- sorry-free
  - `US_expressively_complete_over_prior` -- sorry-free
  - `gap_prior_UZ_contradiction` -- sorry-free
  - `gap_prior_SZ_contradiction` -- sorry-free
  - `no_gaps_discrete_model_surgery` -- sorry-free
  - `limitdom_is_good` -- sorry-free
  - `countermodel_discrete_reynolds_v2` -- sorry-free
- [ ] Verify no new `sorry` introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows only the 3 existing sorry sites in the general (non-discrete) `nf_2var_existential_transfer` / `nf_exist_sf_guarded_backward`
- [ ] Run existing tests: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: Phase 3

**Files to modify**: None (verification only)

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` result documented
- `grep` finds only the expected sorry sites (general non-discrete versions)
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors for the full project
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.discrete_stavi_expressive_completeness` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.gap_prior_UZ_contradiction` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` -- either no `sorryAx` or only through Chain B (documented)
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes
- [ ] The general `stavi_expressive_completeness` retains its sorry (expected, not on discrete path)
- [ ] No new `sorry` introduced in `EFGames/` directory beyond existing ones
- [ ] No import cycles (verified by successful `lake build`)
- [ ] Existing `Tests/BimodalTest/` tests pass

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/07_iterated-game-transfer-plan.md` (this file, v7)
- Existing (Phase 0 complete): Axiom audit results
- Existing (Phase 1 complete): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- Modified (Phase 2): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (250-350 new lines)
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (150-260 new lines)
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-10 modified lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/07_iterated-game-transfer-summary.md`

## Rollback/Contingency

- **If the 0-game to 1-game promotion fails** (the winning condition at n=1 cannot be constructed from the n=0 game because `ghr93_strategy_restrict_left` requires stronger d-consistency than what the promoted game provides): Fall back to proving a DIRECT sub-interval restriction theorem `discrete_game_restrict_direct` that does not go through the restrict_left/right infrastructure. Instead, directly construct the sub-interval 0-game from the full-interval 0-game by observing that any b' in [x',u'] is also in [x',t'], so the full-interval game response works for the sub-interval. This is simpler (~50-80 lines) but needs to verify that the response b falls in [x,u] when b' is in [x',u'], which follows from the ordering preservation in the winning condition.
- **If the induction on j does not terminate cleanly** (the IH application requires game strategies on sub-intervals that themselves need sub-sub-interval games, leading to infinite regression): The regression terminates because depth strictly decreases (j -> d -> ... -> 0), and at depth 0 no game is needed (pure atoms). Each recursion step uses `discrete_game_subinterval_restrict` to produce games on smaller intervals, and the depth decreases by at least 1. The total number of recursion steps is bounded by j, which is bounded by k.
- **If `discrete_stavi_expressive_completeness` duplication is too large**: Instead of duplicating the full inductive construction, prove that the discrete versions of the sorry-chain lemmas have exactly the same type signature as the sorry'd versions (plus discrete instances), then use `letI` inside `stavi_expressive_completeness` to introduce discrete instances and dispatch to the discrete versions. This requires the caller to provide discrete instances, which `US_expressively_complete_over_prior` can do since Prior structures are discrete.
- **If build time exceeds heartbeat**: Place new discrete lemmas in a new file `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` that imports NFGameBridge.lean and is imported by StaviCompleteness.lean.
- **Git revert** to the commit before implementation if any phase introduces regressions.
