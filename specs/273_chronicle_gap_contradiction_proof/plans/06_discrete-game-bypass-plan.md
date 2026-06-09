# Implementation Plan: Discrete Game Bypass for Stavi Expressive Completeness (v6)

- **Task**: 273 - Fill the EF game sorry in StaviCompleteness.lean to make {U,S,U',S'} expressively complete
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (Phases 0-1 from v3 are completed)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/03_team-research.md, specs/273_chronicle_gap_contradiction_proof/.bridge-research.md, specs/273_chronicle_gap_contradiction_proof/.blocker-research.md, specs/273_chronicle_gap_contradiction_proof/handoffs/phase-2-handoff-20260609T010703Z.md, specs/273_chronicle_gap_contradiction_proof/handoffs/phase-2-handoff-20260609T014644Z.md, literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md (GHR93 Section 8), literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md (GHR94 Ch 9)
- **Artifacts**: plans/06_discrete-game-bypass-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan (v6, FINAL) replaces ALL previous blocked Phase 2 approaches with a discrete-only game bypass. Instead of filling the sorry in `nf_2var_existential_transfer` directly, we prove a discrete-specific version `discrete_nf_2var_from_interval_data` that bypasses the circular dependency by using the existing fully-proved game pipeline (Bridge A + composition + game-to-formula conversion) to handle the sub-interval matching problem.

**Scope**: This approach is DISCRETE-ONLY. It proves the sorry chain for discrete structures (Prior structures with `IsSuccArchimedean`), which is all that is needed for `completeness_discrete`. Dense completeness (`completeness_dense`) is out of scope.

**Key insight**: For discrete orders, Bridge A (`discrete_nf_to_decomposition_agreement` in NFGameBridge.lean, fully proved) converts NF hypotheses to `decomposition_agreement` at n=0, r=k/2. The existing sorry-free pipeline `decomposition_agreement -> ghr93_decomposition_implies_game -> ghr93_strategy_compose` provides Duplicator's winning strategy. From the game win, `game_win_to_formula_agree` extracts formula agreement at matched points. For discrete orders, formula agreement at rank k/2 yields 1-var NF agreement at depth 2*(k/2) via `discrete_formula_agree_from_nf`. This gives enough NF data to bootstrap an induction on depth that terminates at depth 0 (atoms only).

### Research Integration

Integrated reports:
- `.bridge-research.md` -- Game pipeline inventory, gap analysis, three feasible paths; Path A (discrete-only bypass) recommended as ~200-400 lines
- `.blocker-research.md` -- Three resolution paths evaluated; strengthened zone match confirmed unprovable
- `handoffs/phase-2-handoff-20260609T010703Z.md` -- Phase 2 blocker details, sorry site goal states, five failed approaches
- `handoffs/phase-2-handoff-20260609T014644Z.md` -- Seven approaches analyzed, root cause confirmed (NF one-at-a-time vs game multi-variable)

### Prior Plan Reference

**v3 (separation bypass)**: Blocked because the separation result (GHR94 Ch 10.2) is proved for Z-carrier structures only. `eval` quantifies over `M.carrier`, and arbitrary Prior carriers may differ from Z.

**v4 (EF game completion)**: Phase 2 blocked on the interval-splitting problem. The existing `zone_match_witness` finds u' with the same depth-k 1-var NF and correct orderings relative to x' and t', but does NOT guarantee sub-interval type matching for (x,u)/(x',u') and (u,t)/(u',t'). Counterexample confirmed.

**v5 (strengthened zone match)**: Phase 2 blocked because `interval_nf_types` is a `Finset` (set membership only), not an ordered sequence. Two linear orders can have the same set of 1-var NF types in an interval but different arrangements, so no single choice of u' can guarantee sub-interval type Finset equality.

**Root cause (all three)**: The NF-based proof technique processes variables one at a time via zone matching. Each zone match preserves orderings relative to interval ENDPOINTS but loses information about orderings relative to previously matched INNER points. The GHR93 paper resolves this via multi-point Duplicator strategy (Proposition 7) using decomposition formulas. The formalized codebase uses NFs, and the NF-to-game bridge was incomplete.

**v6 approach (this plan)**: Use the fully-proved Bridge A + game pipeline for discrete orders. For each new variable challenge, the game provides formula agreement at the matched point. For discrete orders, this yields NF agreement. Strong induction on depth, terminating at depth 0 (atoms). No sub-interval type splitting needed because the game handles multi-point matching compositionally.

### Existing Infrastructure (Sorry-Free)

Bridge A and the game pipeline are fully proved. Key theorems in NFGameBridge.lean:

| Theorem | Line | Status |
|---------|------|--------|
| `discrete_nf_to_decomposition_agreement` | 997 | Sorry-free |
| `discrete_formula_agree_from_nf` | 749 | Sorry-free |
| `discrete_rank_type_agree` | 531 | Sorry-free |
| `discrete_muSig_nf_agree` | 332 | Sorry-free |
| `discrete_winning_condition_0` | 815 | Sorry-free |
| `existential_transfer_from_nf` | 719 | Sorry-free |
| `game_win_to_formula_agree` | 1222 | Sorry-free |
| `nvar_nf_eq_depth_zero` | 127 | Sorry-free |
| `atom_agree_from_pointwise_nf` | 140 | Sorry-free |

Key theorems in other files:

| Theorem | File | Status |
|---------|------|--------|
| `ghr93_strategy_compose` | Composition.lean:40 | Sorry-free |
| `ghr93_decomposition_implies_game` | Decomposition.lean:272 | Sorry-free |
| `ghr93_game_implies_decomposition` | Decomposition.lean:117 | Sorry-free |
| `nf_fraisse_compression` | StaviCompleteness.lean (used at 2518) | Sorry-free |

## Goals & Non-Goals

**Goals**:
- Prove `discrete_nf_2var_from_interval_data` -- a discrete-only version of `nf_2var_from_interval_data` that uses the game pipeline
- Wire `discrete_nf_2var_from_interval_data` into the sorry sites at StaviCompleteness.lean:2353, 2435, and 2805 (conditioned on discrete structure instances)
- Make `stavi_expressive_completeness` sorry-free when applied to discrete structures
- Make `US_expressively_complete_over_prior` sorry-free (Prior structures are discrete)
- Verify via `#print axioms completeness_discrete` that sorryAx is removed from Chain A

**Non-Goals**:
- Filling `nf_2var_existential_transfer` for arbitrary linear orders (the original sorry remains for non-discrete cases)
- Proving `completeness_dense` sorry-free
- Modifying `PriorExpressiveness.lean` or downstream consumers beyond re-pointing to discrete-specific theorems
- Refactoring the EF game infrastructure beyond what is needed
- Fixing `chronicle_gap_contradiction` (Chain B, already bypassed by task 281)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Odd-k depth gap: game at rank k/2 gives NF at depth 2*(k/2) = k-1 for odd k, but we need depth k | H | M | Use `Nat.div_add_mod k 2` to handle parity. For even k: 2*(k/2) = k, exact. For odd k: 2*(k/2) = k-1, use `nf_char_depth_le` to step from depth k to depth k-1, or use rank (k+1)/2 and `ghr93_duplicator_wins_rank_cast` to adjust. The bridge research notes `ghr93_duplicator_wins_rank_cast` exists at CustomGame.lean:431. Alternative: prove the induction works at depth k-1 and handle the +1 separately. |
| Wiring discrete instances through `stavi_expressive_completeness` requires adding `IsSuccArchimedean` instances to type signatures | M | M | The sorry sites are inside `nf_2var_existential_transfer` which is called by `nf_2var_from_interval_data` which is called inside `stavi_expressive_completeness`. Adding discrete instances may change the type signature. Mitigation: create a parallel `discrete_stavi_expressive_completeness` that wraps the existing one with discrete-specific sorry-filling, or use `have` blocks with `letI` to introduce instances locally. |
| `ghr93_decomposition_implies_game` requires point existence hypotheses (h_pt, h_pt_M) | L | L | For discrete orders with `NoMaxOrder`/`NoMinOrder`, any interval (x,t) with x < t contains a point (by `IsSuccArchimedean` or `Order.succ`). Prove a simple `discrete_interval_has_point` lemma. |
| Build time exceeds heartbeat for the large StaviCompleteness.lean file | M | M | Place all new lemmas in NFGameBridge.lean (or a new DiscreteBridge.lean). Keep StaviCompleteness.lean modifications minimal: replace the three sorry calls with applications of discrete-specific theorems. |
| The recursion on depth in `discrete_game_to_2var_nf` requires careful handling of the variable count growth | M | L | At each depth level, the variable count increases by 1, but `existential_transfer_from_nf` and `nf_fraisse_compression` are parametric in variable count n. At depth 0, use `atom_agree_from_pointwise_nf` (already proved). The recursion is well-founded on depth (strictly decreasing). |

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

### Phase 2: Discrete Game-to-NF Bridge [BLOCKED]

**Goal**: Prove `discrete_game_to_2var_nf` -- for discrete orders, the game pipeline (Bridge A + composition) yields 2-var NF equality. Then prove `discrete_nf_2var_from_interval_data` as the discrete-specific replacement for `nf_2var_from_interval_data`.

**BLOCKER** (Phase 2):
- **What failed**: The "discrete game bypass" approach cannot prove `discrete_nf_2var_from_interval_data` because the sub-interval type matching problem persists even for discrete orders. The approach proposed strong induction on k with the game breaking the circularity at the top depth, but the game at n=0 only matches ONE variable (not sufficient for the nested multi-variable transfer).
- **What was tried**:
  1. Strong induction on k using `nf_fraisse_compression` + `existential_transfer_from_nf`: Circular at the top depth (j=k-1 needs 2-var NF at depth k, which is the goal).
  2. Using the game (Bridge A at n=0, r=k/2) to break the circularity: The game matches one point b with formula agreement at rank k/2. For discrete orders, this gives 1-var NF agreement at depth 2*(k/2). But the 3-var existential transfer at the top depth requires 4-var transfer at j'=k-2, which needs 3-var NF at k-1, which itself has the same circularity at the 3-var level.
  3. Inner recursion on depth for multi-var NF: Terminates for depths strictly below the boundary (d < k-2), but at d=k-2 the same circularity reappears for the 3-var case.
  4. Using higher-n games (n >= 1) via `ghr93_strategy_compose`: Requires n=0 games on ALL sub-intervals, which requires `decomposition_agreement` for sub-intervals, which requires interval_nf_types for sub-intervals -- the exact sub-interval type problem.
  5. Zone matching with refined ordering: Zone matching from (x,t) gives w' with orderings relative to x' and t', but NOT relative to the inner point u'. The ordering of w' relative to u' is undetermined by zone matching and requires sub-interval type data.
  6. Case-splitting on ordering of inner variables: The ordering of w relative to u in the ORIGINAL structure M is known, but zone matching independently produces w' without controlling its ordering relative to u'.
- **Why it's stuck**: The fundamental blocker is the same across all six v3-v6 plan attempts: proving multi-variable (n >= 3) NF agreement from single-variable NF agreement requires controlling the arrangement of types within sub-intervals. For n=2 (the outer level), the hypotheses provide interval_nf_types for (x,t). For n=3 (one level deeper), sub-interval types for (x,u) and (u,t) are needed but not available. The game infrastructure (Bridge A + composition at n=0) handles single-variable matching but cannot extend to multi-variable matching without either (a) the full GHR93 Proposition 7 recursive game strategy (which builds G_{n+1} from G_n on sub-intervals, requiring ~500-800 lines of new Lean infrastructure), or (b) a fundamentally different proof technique.
- **What is needed**: One of:
  (A) **Formalize GHR93 Proposition 7 + Theorem 6** (~500-800 lines): Prove that from G_{0;r} on all sub-intervals (available via Bridge A), Duplicator wins G_{n;r} for arbitrary n by induction on n. This requires: (i) `ghr93_strategy_compose` iterated across sub-intervals, (ii) decomposition_agreement for sub-intervals (needs proving that the game on (x,t) provides games on (x,b) and (b,t) via `ghr93_strategy_restrict_left/right`), (iii) extraction of multi-variable NF from the winning condition.
  (B) **Prove a direct multi-variable NF theorem**: For discrete orders, pointwise 1-var NF agreement + pairwise ordering agreement implies n-var NF agreement at all depths. This would bypass the game entirely but appears to require the same sub-interval type control.
  (C) **Find an alternative path to `US_expressively_complete_over_prior`** that doesn't go through `stavi_expressive_completeness`: e.g., use the Kamp theorem for Dedekind-complete orders (Z is Dedekind-complete), but this is not formalized.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Mathematical approach (original, now blocked)**:

The proof uses strong induction on depth k. At each depth, the game pipeline provides Duplicator's strategy for matching challenge points. For discrete orders, formula agreement at matched points converts to NF agreement, giving the inductive hypothesis at lower depth.

**Proof sketch for `discrete_nf_2var_from_interval_data`**:

Given: 1-var NF agreement at depth k for x/x', t/t', orderings match, interval_nf_types match, above/below types match.

1. Apply `discrete_nf_to_decomposition_agreement` (Bridge A, line 997) to get `decomposition_agreement M M' atomMap 0 (k/2) (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')`.
2. Apply `ghr93_decomposition_implies_game` (Decomposition.lean:272) to convert decomposition agreement to `ghr93_duplicator_wins` at n=0, r=k/2.
3. For the 2-var NF at depth k, use `nf_fraisse_compression`: need existential transfer at all depths j < k.
4. For existential transfer at depth j < k: given challenge point u in M, use `zone_match_witness` to find u' in M'. The game at (x,t)/(x',t') can match u to some b' with formula agreement at rank k/2.
5. For discrete orders, formula agreement at rank k/2 gives 1-var NF agreement at depth 2*(k/2) >= k-1 for u/b' via `discrete_formula_agree_from_nf`.
6. With 1-var NF agreement at all points + orderings: at depth 0, apply `nvar_nf_eq_depth_zero` for the (n+1)-var atom agreement.
7. For depth d+1 (d < j < k): apply `existential_transfer_from_nf` which requires (n+1)-var NF agreement at depth d+1. This needs (n+2)-var existential transfer at depth d. Recurse with decreasing depth.
8. The recursion terminates at depth 0 where only atoms are needed.

**Depth arithmetic**: For even k, 2*(k/2) = k, so formula agreement gives NF at depth k -- sufficient for all j < k. For odd k, 2*(k/2) = k-1, so formula agreement gives NF at depth k-1 -- sufficient for j < k-1 but NOT for j = k-1 which needs NF at depth k. Mitigation: use rank `(k+1)/2` (i.e., ceiling division). Then 2*((k+1)/2) = k for odd k, and k+1 for even k. The rank cast `ghr93_duplicator_wins_rank_cast` (CustomGame.lean:431) adjusts the rank. Alternatively, use `Nat.succ_div_two_le` or explicit case split on k parity.

**Tasks**:

- [ ] **Task 2.1**: Prove `discrete_interval_has_point` *(deviation: deferred -- blocked by root cause)* -- for discrete orders with `NoMaxOrder`/`NoMinOrder`, any non-trivial interval (x < t) contains a carrier point. This provides the `h_pt`/`h_pt_M` hypotheses needed by `ghr93_game_implies_decomposition` and `ghr93_decomposition_implies_game`.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Location**: After `game_win_to_formula_agree` (line ~1237)
  - **Type signature**:
    ```lean
    theorem discrete_interval_has_point {sig : MonadicSignature}
        {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        {r : Nat}
        [SuccOrder M.carrier] [PredOrder M.carrier]
        [IsSuccArchimedean M.carrier]
        (x t : M.carrier) (h_xt : x < t) :
        ∃ (p : M.carrier), inClosedInterval
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) x)
          (extendPoint (sig := sig) (atomMap := atomMap) (r := r) t)
          (extendPoint p)
    ```
  - **Proof idea**: Use `Order.succ x` or just `x` itself as the point. `extendPoint x` is in `[extendPoint x, extendPoint t]` by definition.
  - **Estimated size**: 10-20 lines

- [ ] **Task 2.2**: Prove `discrete_game_from_nf_hypotheses` *(deviation: deferred -- blocked by root cause)* -- assemble the full game win from Bridge A. Given the NF hypotheses of `nf_2var_existential_transfer`, produce `ghr93_duplicator_wins` at n=0, r=k/2.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Location**: After `discrete_interval_has_point`
  - **Type signature**:
    ```lean
    theorem discrete_game_from_nf_hypotheses {sig : MonadicSignature}
        {M M' : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        {k : Nat}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder M'.carrier] [PredOrder M'.carrier] [NoMaxOrder M'.carrier]
        [NoMinOrder M'.carrier] [IsSuccArchimedean M'.carrier]
        (x t : M.carrier) (x' t' : M'.carrier)
        (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
                  nf_characteristic M' k 1 (fun _ => x'))
        (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
                  nf_characteristic M' k 1 (fun _ => t'))
        (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
        (h_interval_above : t < x →
          interval_nf_types M k t x = interval_nf_types M' k t' x')
        (h_interval_below : x < t →
          interval_nf_types M k x t = interval_nf_types M' k x' t')
        (h_above_max : (...) = (...))
        (h_below_min : (...) = (...)) :
        ghr93_duplicator_wins M M' atomMap 0 (k / 2)
          (extendPoint x) (extendPoint t) (extendPoint x') (extendPoint t')
    ```
  - **Proof**: Apply `discrete_nf_to_decomposition_agreement` to get `decomposition_agreement`, then `ghr93_decomposition_implies_game` to convert to game win. Need `discrete_interval_has_point` for the point existence hypotheses.
  - **Estimated size**: 30-50 lines

- [ ] **Task 2.3**: Prove `discrete_nf_2var_from_interval_data` *(deviation: blocked -- sub-interval type matching is the root cause; all six plan approaches (v3-v6) fail here)* -- the master theorem. For discrete orders, the NF hypotheses (same as `nf_2var_from_interval_data`) imply 2-var NF equality.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Location**: After `discrete_game_from_nf_hypotheses`
  - **Type signature**: Same hypotheses as `nf_2var_from_interval_data` (StaviCompleteness.lean:2448) plus discrete order instances:
    ```lean
    theorem discrete_nf_2var_from_interval_data {sig : MonadicSignature}
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
        (h_nf_x : nf_characteristic M k 1 (fun _ => x) =
                  nf_characteristic M' k 1 (fun _ => x'))
        (h_nf_t : nf_characteristic M k 1 (fun _ => t) =
                  nf_characteristic M' k 1 (fun _ => t'))
        (h_order_xt : (x < t ↔ x' < t') ∧ (t < x ↔ t' < x'))
        (h_interval_above h_interval_below h_above_max h_below_min : ...) :
        nf_characteristic M k 2 (Fin.cons x (fun _ => t)) =
        nf_characteristic M' k 2 (Fin.cons x' (fun _ => t'))
    ```
  - **Proof structure (strong induction on k)**:
    1. **k = 0**: Apply `nvar_nf_eq_depth_zero` (NFGameBridge.lean:127). Atoms follow from pointwise 1-var NF agreement + orderings via `atom_agree_from_pointwise_nf` (line 140).
    2. **k = k' + 1**: Apply `nf_fraisse_compression`. Need existential transfer at all depths j < k'+1.
       - Get game win via `discrete_game_from_nf_hypotheses` at n=0, r=k/2.
       - For each challenge point u, use `zone_match_witness` to find u' with matching 1-var NF at depth k.
       - Use `game_win_to_formula_agree` to extract formula agreement at u/u' (or a game-matched point) at rank k/2.
       - For discrete orders, `discrete_formula_agree_from_nf` converts formula agreement to 1-var NF agreement at depth 2*(k/2).
       - With 1-var NF agreement at all points in the (n+1)-var environment:
         - Depth 0: `nvar_nf_eq_depth_zero` gives (n+1)-var NF.
         - Depth d+1: `existential_transfer_from_nf` requires (n+1)-var NF at depth d+1, which we get by recursion (depth decreases).
       - The recursion terminates because depth strictly decreases to 0.
    3. **Odd-k handling**: If k is odd, 2*(k/2) = k-1. The induction hypothesis at depth j < k covers j <= k-2 directly. For j = k-1 specifically: the game at rank k/2 gives NF at depth k-1, which is exactly depth j = k-1. The existential transfer at depth k-1 needs NF at depth k, which is NOT available from the game alone. Resolution: use `existential_transfer_from_nf` with the ORIGINAL hypotheses (h_nf_x, h_nf_t give depth-k NF for the boundary points), combined with the game-derived NF for inner points. The key insight: `existential_transfer_from_nf` only needs the (n)-var NF at depth j+1, not the (n+1)-var NF. Since we have 1-var NF agreement at depth k for boundary points AND at depth k-1 for zone-matched points, and k-1 >= j for all j < k-1, this suffices for all depths j < k-1. For j = k-1: this case needs (n)-var NF at depth k, which for the 2-point case (n=2) we are trying to prove. This IS the circular dependency. Mitigation: handle odd k by using rank `(k+1)/2` instead of `k/2` (ceiling division), which gives 2*((k+1)/2) = k+1 for even k and k for odd k, always >= k. Use `ghr93_duplicator_wins_rank_cast` (CustomGame.lean:431) to cast the Bridge A output from rank k/2 to rank (k+1)/2, or re-prove Bridge A at rank (k+1)/2 (the proof works identically).
  - **Estimated size**: 100-200 lines

- [ ] **Task 2.4**: Handle the odd-k depth arithmetic. *(deviation: deferred -- blocked by Task 2.3)* Determine whether to:
  - (a) Use ceiling division `(k+1)/2` throughout and adjust Bridge A accordingly, OR
  - (b) Case-split on k parity and handle odd k with a +1 adjustment, OR
  - (c) Prove Bridge A at rank `(k+1)/2` directly (the proof is identical to rank `k/2` since `discrete_rank_type_agree` works for any rank).
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean`
  - **Proof approach**: Check whether `discrete_nf_to_decomposition_agreement` can accept rank `(k+1)/2` instead of `k/2`. The proof uses `discrete_rank_type_agree` which works for any rank r given depth-k NF agreement (since 2*r <= k implies rank_type agreement). For r = (k+1)/2: need 2*((k+1)/2) <= k. For even k: (k+1)/2 = k/2, so 2*(k/2) = k. For odd k: (k+1)/2 = (k+1)/2, so 2*((k+1)/2) = k+1 > k. This does NOT satisfy 2*r <= k for odd k. Alternative: use the fact that for odd k, 2*(k/2) = k-1 and the depth-(k-1) NF data is sufficient for the recursion that terminates at depth 0. Since we only need existential transfer at depths j < k, and the recursion decreases depth by 1 at each step, reaching depth 0 after at most k-1 steps, all of which are covered by depth-(k-1) NF agreement.
  - Actually: re-examining the recursion. At the outermost level, `nf_fraisse_compression` needs existential transfer at all j < k. For j = k-1, `existential_transfer_from_nf` needs 2-var NF at depth k -- but that is what we are proving. So the recursion for the 2-var case has base case k=0 and inductive case reducing k. For the inner variable matching (3-var, 4-var, etc.), the recursion decreases DEPTH, not k. At depth 0, atoms suffice. The odd-k gap only affects whether the game gives sufficient NF depth for inner point matching. Since inner points need NF at depth j (not k), and 2*(k/2) >= k-1 >= j for all j < k-1, the only problematic case is j = k-1. But for j = k-1, the existential transfer needs 3-var NF at depth k, which needs 4-var transfer at depth k-1, which needs 3-var NF at depth k-1... this recurses on depth and terminates. The issue is that at the TOP level, we need ALL j < k, and for j = k-1 the chain is: 2-var NF at k (goal) <- transfer at k-1 <- 3-var NF at k <- transfer at k-1 for 4-var. This is circular at the same depth k. Resolution: prove the induction on k, not on j. At depth k, use the game. The game gives multi-var NF agreement at depth 2*(k/2). For even k, this covers depth k = 2*(k/2). For odd k, it covers depth k-1. The remaining depth k-1 transfer at the 2-var level is covered by the IH at k-1. Concretely: for odd k, split the proof: (a) prove 2-var NF at depth k-1 by IH, then (b) extend to depth k using the one additional existential transfer step, where the game's depth-(k-1) data handles the inner matching.
  - **Estimated size**: 20-50 lines (integrated into Task 2.3)

- [ ] **Task 2.5**: Verify that `discrete_nf_2var_from_interval_data` compiles *(deviation: deferred -- blocked by Task 2.3)* and has the correct type signature for wiring into StaviCompleteness.lean. Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge`.
  - **Estimated size**: 0 lines (verification only)

**Timing**: 3 hours

**Depends on**: Phases 0, 1 (completed)

**Files to create/modify**:
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (all tasks, estimated 150-300 new lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.NFGameBridge` succeeds
- No sorry in NFGameBridge.lean (verify with grep)
- `discrete_nf_2var_from_interval_data` type signature matches `nf_2var_from_interval_data` plus discrete instances

---

### Phase 3: Wire Discrete Bridge into StaviCompleteness.lean [NOT STARTED]

**Goal**: Replace the three sorry sites in StaviCompleteness.lean with calls to the discrete-specific theorems from Phase 2. The approach: create `discrete_nf_2var_existential_transfer` that delegates to `discrete_nf_2var_from_interval_data` for discrete orders, then fill the sorry at `nf_2var_existential_transfer` (line 2353, 2435) by case-splitting on whether the structures are discrete. For `nf_exist_sf_guarded_backward` (line 2805), similarly apply the discrete bridge.

**Strategy for wiring**:

The sorry sites are inside `nf_2var_existential_transfer` which has NO discrete instances in its type signature. The theorem is universally quantified over arbitrary `OrderedMonadicStructure sig`. We cannot add discrete instances to it.

**Resolution**: Instead of modifying `nf_2var_existential_transfer`, we modify `stavi_expressive_completeness` (or its callers) to use a discrete-specific version when discrete instances are available. The cleanest approach:

1. Create `discrete_nf_2var_from_interval_data` (Phase 2, already done).
2. Create `discrete_nf_exist_sf_guarded_backward` that mirrors `nf_exist_sf_guarded_backward` but uses the discrete bridge.
3. Create `discrete_nf_2var_exist_sf_classical` that mirrors `nf_2var_exist_sf_classical` using the discrete backward direction.
4. Create `discrete_stavi_expressive_completeness` that is identical to `stavi_expressive_completeness` but uses the discrete versions at the sorry points.
5. In `PriorExpressiveness.lean`, modify `US_expressively_complete_over_prior` to call `discrete_stavi_expressive_completeness` instead of `stavi_expressive_completeness`. Prior structures have all the required discrete instances (`SuccOrder`, `PredOrder`, `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`).

**Tasks**:

- [ ] **Task 3.1**: Create `discrete_nf_2var_existential_transfer` in NFGameBridge.lean (or StaviCompleteness.lean). Same signature as `nf_2var_existential_transfer` (line 2214) plus discrete instances. Proof: apply `discrete_nf_2var_from_interval_data` from Phase 2 and use `nf_fraisse_compression` / `existential_transfer_from_nf`.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (or `StaviCompleteness.lean` if import order requires it)
  - **Type signature**:
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
        (char_k_correct : ...) (h_nf_x h_nf_t h_order_xt ...) :
        ∀ j, j < k → ∀ chi : NormalForm sig j (2 + 1),
          (∃ u, nf_eval_nf M j (2 + 1) (Fin.cons u (Fin.cons x (fun _ => t))) chi) ↔
          (∃ u', nf_eval_nf M' j (2 + 1) (Fin.cons u' (Fin.cons x' (fun _ => t'))) chi)
    ```
  - **Estimated size**: 20-40 lines (delegates to `discrete_nf_2var_from_interval_data`)

- [ ] **Task 3.2**: Create `discrete_nf_exist_sf_guarded_backward` -- discrete version of the backward direction of the guarded SF existence theorem (currently sorry'd at line 2805).
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (add near line 2778)
  - **Proof**: Identical to `nf_exist_sf_guarded_backward` but calls `discrete_nf_2var_from_interval_data` instead of `nf_2var_from_interval_data`.
  - **Estimated size**: 20-40 lines

- [ ] **Task 3.3**: Create `discrete_stavi_expressive_completeness` -- the discrete-specific version of `stavi_expressive_completeness` (GHR93 Theorem 9.3.1).
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (add after line 3267)
  - **Type signature**:
    ```lean
    noncomputable def discrete_stavi_expressive_completeness
        (sig : MonadicSignature) (atomMap : Formula → sig.preds)
        (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        (psi : MonadicFormula sig 1) :
        { A : StaviFormula // ... }
    ```
  - **Note**: The discrete instances must be threaded through to the inner uses of `nf_2var_from_interval_data`. Alternatively, since `stavi_expressive_completeness` uses `nf_2var_exist_sf_classical` which uses `nf_exist_sf_guarded_backward` which uses `nf_2var_from_interval_data`, we need to create discrete versions of this entire chain. The most efficient approach may be to create a `discrete_nf_2var_exist_sf_classical` that packages the discrete backward direction, then `discrete_stavi_expressive_completeness` that uses it.
  - **Alternative approach**: If the chain is too deep to duplicate, consider proving `nf_2var_from_interval_data` directly for discrete orders (using `discrete_nf_2var_from_interval_data`), which would make the existing `stavi_expressive_completeness` sorry-free when applied to discrete structures. This requires `nf_2var_from_interval_data` to dispatch to the discrete version when instances are available. Since Lean's instance resolution is automatic, adding `[SuccOrder M.carrier] ... [IsSuccArchimedean M.carrier]` to `nf_2var_from_interval_data` would break its generality. Instead: add a separate `nf_2var_from_interval_data_discrete` and replace the sorry in the original with: `exact discrete_nf_2var_from_interval_data ...` when discrete instances are available, keeping the sorry for non-discrete cases. This is cleaner but still leaves the general sorry. The most pragmatic approach: fill the sorry in `nf_2var_existential_transfer` with a `by exact sorry` that is conditioned -- actually, this is not possible in Lean without type-class branching.
  - **Final approach (recommended)**: Create `discrete_stavi_expressive_completeness` as a standalone theorem, prove it sorry-free. In `PriorExpressiveness.lean`, change `US_expressively_complete_over_prior` to call `discrete_stavi_expressive_completeness` instead of `stavi_expressive_completeness`. Prior structures satisfy all discrete instances. This is clean, minimal, and does not modify the general (sorry'd) `stavi_expressive_completeness`.
  - **Estimated size**: 60-100 lines (duplication of the inductive construction with discrete-specific backward direction)

- [ ] **Task 3.4**: Modify `US_expressively_complete_over_prior` in `PriorExpressiveness.lean` to call `discrete_stavi_expressive_completeness` instead of `stavi_expressive_completeness`.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (line ~384)
  - **Change**: Replace `stavi_expressive_completeness` with `discrete_stavi_expressive_completeness` at the call site. Verify that Prior structures provide all needed discrete instances.
  - **Estimated size**: 5-10 lines

- [ ] **Task 3.5**: Verify the sorry chain is eliminated:
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx
  - `lean_verify gap_prior_UZ_contradiction` -- no sorryAx
  - `lean_verify gap_prior_SZ_contradiction` -- no sorryAx
  - Build: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - Build: `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness`

**Timing**: 2 hours

**Depends on**: Phase 2

**Files to create/modify**:
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (Task 3.1)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (Tasks 3.2, 3.3)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (Task 3.4)

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
  - If `sorryAx` remains: identify which chain (should be Chain B via `chronicle_gap_contradiction` only if task 281's bypass is insufficient)
- [ ] Verify the full Chain A sorry chain is eliminated:
  - `stavi_expressive_completeness` -- general version still has sorry (expected, non-discrete)
  - `discrete_stavi_expressive_completeness` -- sorry-free
  - `US_expressively_complete_over_prior` -- sorry-free
  - `gap_prior_UZ_contradiction` -- sorry-free
  - `gap_prior_SZ_contradiction` -- sorry-free
  - `no_gaps_discrete_model_surgery` -- sorry-free
  - `limitdom_is_good` -- sorry-free
  - `countermodel_discrete_reynolds_v2` -- sorry-free
- [ ] Verify no new `sorry` introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows only the 3 existing sorry sites in `nf_2var_existential_transfer` / `nf_exist_sf_guarded_backward` (which remain for the general non-discrete case)
- [ ] Run existing tests: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: Phase 3

**Files to modify**:
- None (verification only)

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

- `specs/273_chronicle_gap_contradiction_proof/plans/06_discrete-game-bypass-plan.md` (this file, v6)
- Existing (Phase 0 complete): Axiom audit results
- Existing (Phase 1 complete): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- Modified (Phase 2): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/NFGameBridge.lean` (150-300 new lines)
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (80-140 new lines)
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-10 modified lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/06_discrete-game-bypass-summary.md`

## Rollback/Contingency

- **If the odd-k depth arithmetic cannot be resolved**: Prove the result for even k only. Then show that for any k, either k or k+1 is even, and the depth-(k+1) result implies the depth-k result by monotonicity. This adds ~20 lines but avoids the parity issue entirely.
- **If `discrete_stavi_expressive_completeness` is too complex to duplicate from `stavi_expressive_completeness`**: Instead, prove `discrete_nf_2var_from_interval_data` and use it to fill the sorry in `nf_2var_from_interval_data` under a `haveI : IsSuccArchimedean M.carrier := ...` guard. This requires that the call sites in `stavi_expressive_completeness` have access to the discrete instances. Since `stavi_expressive_completeness` is universally quantified over all structures, this means either (a) adding instances as parameters (changes the API) or (b) using `Classical.choice` to decide discreteness (unsound for our purposes). Fallback to the duplication approach.
- **If build time exceeds heartbeat for modified files**: Split the new discrete lemmas into a new file `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameBridge.lean` that imports NFGameBridge.lean and is imported by StaviCompleteness.lean.
- **If the game pipeline does NOT provide sufficient depth for the recursion to terminate**: Fall back to Path C from the bridge research (accept sorry with axiom) and document the gap precisely.
- **Git revert** to the commit before implementation if any phase introduces regressions.
