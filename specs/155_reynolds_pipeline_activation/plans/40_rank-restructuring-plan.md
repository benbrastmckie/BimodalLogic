# Implementation Plan: Reynolds Pipeline -- GHR93 Rank Restructuring (v40)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 20-35 hours
- **Dependencies**: Tasks 154, 147-148, 157, 195, 168, 174, 198, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: `reports/39_game-depth-restructuring.md` (definitive), plus 46 prior reports
- **Artifacts**: plans/40_rank-restructuring-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan replaces ALL previous approaches (v35-v39) with the mathematically correct GHR93 rank restructuring. The root cause of the depth-agreement gap, the sel_pn_ord blocker, and the same_side failures is a single architectural error: the Lean code flattens sigma/tau to rank r instead of keeping them at rank r+4 as GHR93 requires. With tau at rank r+4, the full rank-r type formula B = X_{a_n} (depth r) can be transferred via U(B, sf_top) (depth r+1 <= r+4), giving a witness with full rank-r agreement. This eliminates the need for char_k, tau_r2, h_ih_r2, resp_mod, tau_left, and all same_side workarounds accumulated over 10+ orchestration cycles.

The fix is localized to 5 files in dependency order: SplitPoint -> Theorem6 -> CaseAnalysis -> DConsistencyTransport -> GapDetection. Game definitions (Defs.lean, CustomGame.lean), Composition.lean, and Decomposition.lean are unchanged. The downstream phases (6D-6F, 6C-4/5, 7, 8, 9) from v39 remain structurally identical but are simplified because the backward game (Theorem 12.8.15) becomes self-contained once sigma/tau are at the correct rank.

### Research Integration

- `reports/39_game-depth-restructuring.md` (definitive): `game_depth` does NOT need to change. The problem is rank flattening in `ghr93_forward_to_backward`. Fix: add delta parameter to SplitPointProps so sigma/tau live at rank r+delta; construct with delta=4 from IH at rank r+4. Positions at rank r are embedded via rank_embed. Estimated 750-1400 lines of changes across 5 files.
- `reports/38_equality-case-research.md`: Depth-agreement gap analysis confirming the rank mismatch is fundamental.
- `reports/37_sorting-approach-research.md`: Sorting wrapper (Phase 3C-Sort) remains necessary; GHR93 assumes sorted selections.

### What This Plan REPLACES

All previous workarounds become unnecessary and are deleted:
- **char_k, char_k_correct, char_k_depth** parameters in ghr93_forward_to_backward_core, ghr93_forward_to_backward, ghr93_forward_to_backward_rank_varying, ghr93_case_II -- DELETE (use full rank-r type formula via tau at r+4 instead)
- **tau_r2 construction** (CaseAnalysis.lean:1467) -- DELETE (tau already at r+4)
- **h_ih_r2 parameter** (CaseAnalysis.lean:1209-1214) -- DELETE (IH already at r+4)
- **resp_mod** (CaseAnalysis.lean:1554) -- DELETE or simplify (with full rank-r agreement, the equality case may become trivial)
- **resp_left, tau_left** (CaseAnalysis.lean:1488) -- DELETE (sub-interval composition workaround)
- **same_side lemma attempts** (28 approaches tried) -- all eliminated
- **sel_pn_ord workaround infrastructure** -- eliminated by direct ordering from tau at r+4
- **Sorting wrapper** at ghr93_inductive_step (Phase 3C-Sort) -- KEPT (GHR93 assumes sorted)

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

## Completed Phases (Preserved)

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Mechanical Sorry Closure S3 + S5 | COMPLETED |
| 2 | Pigeonhole + K-(negD) Bridge | COMPLETED |
| 3A | sel_pn_ord Sorry'd Field | COMPLETED (will be deleted in R3) |
| 4 | Position-Tracking Fix S6 + S7 | COMPLETED |
| 6A | GHR93 Prop 7 -- Strategy Composition | COMPLETED |
| 6C-1 | k=0 Base Case | COMPLETED |
| 6C-2 | Interval Guard Formula | COMPLETED |
| 6C-3 | Forward Direction | COMPLETED |
| 3C-Sort | Sorting Preprocessing Wrapper | COMPLETED |
| 3C-EQ | Equality Case Response Modification | COMPLETED (will be simplified in R3) |

## Goals & Non-Goals

**Goals**:
- Restructure SplitPointProps so sigma/tau live at rank r+delta (default delta=4)
- Restructure ghr93_forward_to_backward_core to carry rank offset through induction
- Rewrite Case II using full rank-r type formula transfer via tau at r+4
- Delete all workaround infrastructure (char_k, tau_r2, h_ih_r2, resp_mod, tau_left, same_side)
- Close all critical-path sorry sites
- Achieve sorry-free bx_completeness

**Non-Goals**:
- Changing game_depth (not needed per research)
- Changing game definitions in Defs.lean or CustomGame.lean
- Changing Composition.lean or Decomposition.lean
- TruthLemma.lean sorry sites (non-critical-path)
- Dense or mixed completeness variants

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| rank_embed cascading through all position arguments in SplitPointProps | High | Use rank_embed consistently; create helper lemmas for game_tuple at different ranks |
| obtain_split_point_props reconstruction is complex (~4657 lines file) | High | Preserve the infimum construction; only change the IH application and sigma/tau construction at the end |
| Cases III/IV need (r+4)+2 = r+6 games for gap detection | Medium | h_r1_univ already provides arbitrary r'+2 games; instantiate at r'=r+4 to get r+6 |
| Winning condition at rank r+4 vs rank r needs projection | Medium | Use ghr93_duplicator_wins_rank_down for final assembly |
| CaseAnalysis.lean is 4701 lines; restructuring Case II touches many lines | High | Phased approach: first restructure SplitPoint/Theorem6, then rewrite Case II fresh |
| Sorting wrapper (3C-Sort) may need adjustment for new rank | Low | Sorting operates on a_bwd at rank r before embedding; should be unaffected |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | R1 | -- |
| 2 | R2 | R1 |
| 3 | R3 | R2 |
| 4 | R4 | R3 |
| 5 | R5 | R3 |
| 6 | 6D | -- |
| 7 | 6E | 6D |
| 8 | 6F | 6E |
| 9 | 6C-4 | 6F |
| 10 | 6C-5 | 6C-4 |
| 11 | 7 | 6C-5 |
| 12 | 8 | 7 |
| 13 | 9 | R5, 8 |

Phases within the same wave can execute in parallel. Wave 1-5 (rank restructuring) is the critical path and independent of Wave 6-10 (EFGames classical chain). Wave 6 (Prop 12.8.16) can start immediately in parallel with Wave 1.

---

### Phase R1: SplitPointProps Restructuring [COMPLETED]

**Goal**: Add a `delta` parameter to `SplitPointProps` so that sigma/tau live at rank `r + delta` on rank-embedded positions, matching GHR93's rank structure. Update `obtain_split_point_props` to construct with `delta = 4`.

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` (4657 lines)

**Tasks**:

- [x] **R1.1: Add delta parameter to SplitPointProps** (~50-80 lines changed) *(completed)*
  - Add `(delta : Nat := 0)` parameter to the `SplitPointProps` structure (line 44)
  - Change `sigma` field (line 89) from:
    ```lean
    sigma : ghr93_duplicator_wins N M atomMap n r x' d x c
    ```
    to:
    ```lean
    sigma : ghr93_duplicator_wins N M atomMap n (r + delta)
      (rank_embed (by omega : r ≤ r + delta) x')
      (rank_embed (by omega : r ≤ r + delta) d)
      (rank_embed (by omega : r ≤ r + delta) x)
      (rank_embed (by omega : r ≤ r + delta) c)
    ```
  - Change `tau` field (line 92) similarly:
    ```lean
    tau : ghr93_duplicator_wins N M atomMap n (r + delta)
      (rank_embed (by omega : r ≤ r + delta) d)
      (rank_embed (by omega : r ≤ r + delta) y')
      (rank_embed (by omega : r ≤ r + delta) c)
      (rank_embed (by omega : r ≤ r + delta) y)
    ```
  - Keep all other fields unchanged (they remain at rank r)
  - Verification: SplitPoint.lean compiles with the new structure definition

- [ ] **R1.2: Add rank_embed helper lemmas** (~30-60 lines) *(deviation: skipped -- existing rank_embed infrastructure (rank_embed_le, rank_embed_lt, rank_embed_isPoint, rank_embed_stavi_truth_mu, rank_embed_inClosedInterval) was sufficient; no new helper lemmas needed)*
  - `rank_embed_game_tuple`: relate game_tuple at rank r to game_tuple at rank r+delta
  - `rank_embed_inClosedInterval_iff`: inClosedInterval commutes with rank_embed
  - `rank_embed_winning_condition`: winning condition transfers through rank_embed
  - These may already partially exist (check TypeFormulas.lean for rank_embed infrastructure)
  - Verification: helper lemmas compile

- [x] **R1.3: Update obtain_split_point_props** (~100-200 lines changed) *(deviation: altered -- h_fwd_r1 parameter kept (needed for c-d correspondence K-(negD) argument, independent of sigma/tau rank); degenerate gap cases inlined directly instead of calling ghr93_duplicator_wins_degenerate_gap to avoid formula-agreement depth mismatch)*
  - Change the IH parameter to produce backward games at rank `r + 4` (not `r`):
    ```lean
    (ih : ∀ {x₀ y₀ : ExtendedCarrier M atomMap r}
            {x₀' y₀' : ExtendedCarrier N atomMap r},
          x₀ ≤ y₀ → x₀' ≤ y₀' →
          (∃ p, inClosedInterval x₀' y₀' (extendPoint p)) →
          ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x₀ y₀ x₀' y₀' →
          ghr93_duplicator_wins N M atomMap n (r + 4)
            (rank_embed ... x₀') (rank_embed ... y₀')
            (rank_embed ... x₀) (rank_embed ... y₀))
    ```
  - The forward game input `h_fwd` at rank `r` with `4 + 3 * n` rounds is consumed:
    - Restrict forward strategy to sub-intervals [x,c]/[x',d] and [c,y]/[d,y']
    - Use round_mono to reduce to `1 + 3 * n` rounds on each sub-interval
    - Apply `ih` on each sub-interval to get backward games at rank `r + 4`
    - These backward games become sigma (at rank r+4) and tau (at rank r+4)
  - Construct `SplitPointProps n x y x' y' c d a_bwd` with `delta := 4`
  - The existing infimum construction (lines 163-440) is PRESERVED unchanged
  - Only the IH application section (after infimum construction) changes
  - Remove `h_fwd_r1` parameter (rank r+2 forward game) -- no longer needed
  - Verification: obtain_split_point_props compiles with new signature

- [x] **R1.4: Update h_d_compat_left and h_fwd_n1 fields** (~20-40 lines) *(completed -- these fields remain at rank r, unchanged; verified they compile with the new structure)*
  - These fields remain at rank r (they use the original forward game, not sigma/tau)
  - Verify they compile unchanged after the structure change
  - If any field needs rank adjustment, add rank_embed wrappers

- [x] **R1.5: Build verification** *(completed -- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.SplitPoint` passes; `lean_verify` shows no sorryAx; downstream CaseAnalysis.lean breaks at 5 call sites as expected)*
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.SplitPoint`
  - Fix any downstream compilation errors

**Timing**: 3-5 hours

**Depends on**: none

---

### Phase R2: Theorem6 Induction Restructuring [COMPLETED]

**Goal**: Restructure `ghr93_forward_to_backward_core` to carry the rank offset through the induction, so each step peels off 4 from delta. Update `ghr93_forward_to_backward` and `ghr93_forward_to_backward_rank_varying` to remove char_k parameters and use the new delta-carrying core.

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` (369 lines)

**Tasks**:

- [x] **R2.1: Restructure ghr93_forward_to_backward_core** *(deviation: altered -- delta is an explicit parameter but the core's succ-case IH for delta>0 requires rank promotion (forward at r -> backward at r+delta) which is sorry'd; delta=0 case has a sorry for the rank_embed identity transport that Phase R3 will resolve)*
  - Remove parameters: `k_nf`, `char_k`, `char_k_correct`, `char_k_depth` *(completed)*
  - Add parameter: `delta : Nat` (rank offset for sigma/tau) -- passed through to `ghr93_inductive_step` *(completed)*
  - `h_enough` no longer reverted (doesn't depend on r); intro order is `r x y x' y' hxy hx'y'...`
  - `h_ih_r2` construction removed *(completed)*
  - Core calls `ghr93_inductive_step atomMap n r 0` with sorry'd IH *(completed)*
  - Verification: core theorem compiles *(completed)*

- [x] **R2.2: Update ghr93_forward_to_backward** *(completed)*
  - Remove parameters: `k_nf`, `char_k`, `char_k_correct`, `char_k_depth` *(completed)*
  - Call `ghr93_forward_to_backward_core` with `delta := 0` *(completed -- h_enough passed directly)*
  - Verification: theorem compiles *(completed)*

- [x] **R2.3: Update ghr93_forward_to_backward_rank_varying** *(deviation: altered -- succ case calls ghr93_inductive_step with delta=4 directly instead of going through core; IH construction sorry'd because rank promotion (forward at r -> backward at r+4) requires the ambient high-rank game restricted to sub-intervals, to be completed in Phase R3)*
  - Remove parameters: `k_nf`, `char_k`, `char_k_correct`, `char_k_depth` *(completed)*
  - Succ case: calls `ghr93_inductive_step atomMap n r 4` with sorry'd IH *(completed)*
  - Still uses `ghr93_duplicator_wins_rank_down` for h_fwd at rank r *(deviation: kept rank_down for h_fwd because ghr93_inductive_step needs h_fwd at rank r; the delta=4 carries the rank offset through sigma/tau instead)*
  - Verification: rank-varying theorem compiles *(completed)*

- [x] **R2.4: Build verification** *(completed)*
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6` passes *(completed)*
  - CaseAnalysis.lean updated minimally to compile with new signatures: `delta` added to SplitPointProps, ghr93_case_I, ghr93_case_II, ghr93_cases_III_IV, ghr93_cases_II_III_IV, ghr93_inductive_step; props.sigma/tau uses sorry'd for rank projection; ghr93_case_II body sorry'd *(expected breakage for Phase R3)*

**Timing**: 2-4 hours

**Depends on**: R1

---

### Phase R3: CaseAnalysis Rewrite -- GHR93 Case II with tau at r+4 [NOT STARTED]

**Goal**: Rewrite `ghr93_case_II` to use the full rank-r type formula B = X_{a_n} transferred through tau at rank r+4. Delete all workaround infrastructure. Close all sorry sites in Case II (currently 8 sorries at lines 2146, 2148, 2200, 2201, 2423, 2476). Also close the Cases III/IV sorry at line 4542.

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (4701 lines)

**Tasks**:

- [ ] **R3.1: Update ghr93_case_II signature** (~20-30 lines)
  - Remove parameters: `h_ih_r2`, `char_k`, `char_k_correct`, `char_k_depth`
  - The `props : SplitPointProps n x y x' y' c d a_bwd` now has `delta = 4` by default
  - `props.tau` is now at rank `r + 4` on rank-embedded positions
  - `ih` parameter remains at rank `r` (the IH for sub-intervals within the backward game)
  - Verification: signature compiles (proofs will be sorry'd initially)

- [ ] **R3.2: Rewrite Case II core -- e_n construction and B transfer** (~150-250 lines)
  - The GHR93 Case II proof structure with tau at r+4:
    1. **B = X_{a_n}**: the full rank-r type formula for the point a_n = a_bwd(n)
       - `rank_type` already exists in TypeFormulas.lean
       - B has `stavi_depth B <= r`
    2. **phi = U(B, sf_top)**: Until formula, depth r+1
       - `std_untl` already exists in TypeFormulas.lean
       - `stavi_depth phi <= r + 1 <= r + 4` (fits within tau's rank)
    3. **Transfer via tau at r+4**: tau at rank r+4 preserves formulas of depth <= r+4
       - `stavi_temporal_truth_mu N atomMap (r+4) (rank_embed d) phi`
       - implies `stavi_temporal_truth_mu M atomMap (r+4) (rank_embed c) phi`
       - which gives a witness z in M with B(z) and z > c (from U semantics)
    4. **e_n = z**: the witness point has full rank-r agreement with a_n
       - B(z) means z has the same rank-r type as a_n
       - This gives `stavi_n_equiv` between e_n and a_n at rank r
  - Key difference from current code: e_n is now constructed from the full rank-r type formula, not from char_k at depth k_nf. This means:
    - sel_pn_ord holds DIRECTLY from the rank-r type agreement
    - No need for resp_mod (modified response function)
    - No need for tau_left (sub-interval backward game)
    - The winning condition follows from the full rank-r agreement between e_n and a_n
  - Verification: e_n construction compiles, sorry count reduces

- [ ] **R3.3: Close sel_pn_ord from rank-r type agreement** (~40-80 lines)
  - With e_n having full rank-r agreement with a_n:
    - For any formula A with stavi_depth A <= r: A(e_n) iff A(a_n)
    - In particular, for any position comparison: e_n and a_n are on the same side of every rank-r-definable boundary
    - sel_pn_ord becomes: `a_init(k) < a_n iff resp(k) < e_n` -- which follows from same_order_type of the tau game combined with rank-r agreement
  - The sel_pn_ord for the STRICT case (a_init(k) < a_n, since selections are sorted and a_n is the maximum) follows directly from tau's winning condition
  - The EQUALITY case (a_init(k) = a_n) follows from: if a_init(k) = a_n and resp(k) from tau, then tau preserves the rank-r type, so resp(k) has the same rank-r type as e_n, hence resp(k) = e_n (or can be set to e_n)
  - Verification: sel_pn_ord proved, the 4 sorry sites at lines 2146/2148/2200/2201 close

- [ ] **R3.4: Close b_resp ordering goals (Case B sorry sites)** (~40-60 lines)
  - The sorry at line 2423 (b_resp vs p_n / p_n vs b_resp in Case B grid dispatch)
  - The sorry at line 2476 (Case B main sorry)
  - With tau at r+4 and e_n having full rank-r agreement:
    - b_resp comes from the tau game's point challenge
    - tau's winning condition gives: `d < b_resp iff c < b_sp` (and =)
    - The orderings between b_resp and a_init(k) / p_n follow from:
      - b_resp is in [d, y'] (from tau)
      - b_sp is in [c, y] (from the point challenge)
      - tau preserves all orderings at rank r+4 >= r
  - Verification: Case B sorry sites close

- [ ] **R3.5: Close Cases III/IV winning condition** (~100-200 lines)
  - The sorry at line 4542 (Cases III/IV winning condition assembly)
  - Cases III/IV: a_bwd(n) is a gap (not a point)
  - The gap detection infrastructure is complete (GapDetection.lean, 5057 lines)
  - With tau at r+4, the gap detection formulas (depth <= r+4) can be transferred
  - The winning condition assembly mirrors Case II but with a gap at position n+1
  - The existing dead code comments at lines 4510-4541 describe the exact construction
  - Verification: Cases III/IV sorry closes

- [ ] **R3.6: Delete workaround infrastructure** (~negative 200-400 lines)
  - Delete `tau_r2` construction (around line 1437-1474)
  - Delete `resp_mod` definition and all related `hresp_mod_eq`, `hresp_mod_ne`, `hresp_mod_in` (lines 1554-1575)
  - Delete `tau_left` and `tau_right` sub-interval games (around line 1488-1522)
  - Delete `resp_left` and related extractions (around line 1525-1550)
  - Simplify or remove equality case handling that was needed for resp_mod
  - Clean up dead code blocks (lines 2424-2478)
  - Verification: no dead code remains, build passes

- [ ] **R3.7: Update ghr93_inductive_step and Case I** (~30-60 lines)
  - `ghr93_inductive_step` (which dispatches to Cases I, II, III/IV) needs signature update
  - Remove `h_ih_r2`, `char_k`, `char_k_correct`, `char_k_depth` parameters
  - Case I (`ghr93_case_I`): uses sigma and tau directly
    - With sigma/tau at rank r+4 on rank-embedded positions, Case I needs to:
      - Play sigma/tau with rank-embedded selections
      - Project responses back to rank r via rank projection
    - Alternative: Case I may use `ghr93_duplicator_wins_rank_down` to get sigma/tau at rank r when needed
  - Case I is already sorry-free except for one deferred index mapping sorry at line 427
  - Verification: ghr93_inductive_step compiles

- [ ] **R3.8: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis`
  - Sorry count should drop from 9 to 1 (the Case I index mapping sorry at line 427) or 0

**Timing**: 6-10 hours

**Depends on**: R2

---

### Phase R4: Downstream Rank Adjustments [NOT STARTED]

**Goal**: Update DConsistencyTransport.lean and GapDetection.lean if their interfaces changed due to the SplitPointProps restructuring.

**Files**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean` (742 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean` (5057 lines)

**Tasks**:

- [ ] **R4.1: Update DConsistencyTransport.lean** (~20-50 lines)
  - DConsistencyTransport uses the forward strategy and sigma/tau for d-consistency proofs
  - With sigma/tau at rank r+4, the d-consistency transport may need rank_embed wrappers
  - Check if h_d_compat_left (which remains at rank r) is the primary interface -- if so, no changes needed
  - The interior case sorries (lines 54-55, 149) may be closable now that sigma/tau have full rank
  - Verification: DConsistencyTransport.lean compiles

- [ ] **R4.2: Update GapDetection.lean if needed** (~20-50 lines)
  - GapDetection uses h_r1_univ for rank (r+2)+2 = r+4 games in Cases III/IV
  - With tau at r+4, gap detection may benefit from direct tau usage instead of h_r1_univ
  - Check if the gap detection interface changes -- it may not (gap detection constructs its own games)
  - The single mention of sorry in GapDetection.lean (line 1128) is a comment, not an actual sorry
  - Verification: GapDetection.lean compiles

- [ ] **R4.3: Build verification**
  - `lake build` for the full Expressiveness/ and EFGames/ modules

**Timing**: 1-2 hours

**Depends on**: R3

---

### Phase R5: Full Build Verification and Sorry Audit [NOT STARTED]

**Goal**: Verify the rank restructuring is complete, audit remaining sorries, confirm the backward game theorem (12.8.15) is self-contained.

**Tasks**:

- [ ] **R5.1: Full lake build**
  - `lake build` passes with zero errors

- [ ] **R5.2: Sorry audit in restructured files**
  - `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/` -- should show only the Case I index mapping sorry (line 427 of CaseAnalysis.lean) and any legitimate sorry sites in SplitPoint.lean (infimum construction sorries)
  - `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- should show only the dead code sorries (to be removed in Phase 6C-4)
  - Document exact sorry count and locations

- [ ] **R5.3: Verify no char_k remnants**
  - `grep -rn 'char_k\|tau_r2\|h_ih_r2\|resp_mod\|tau_left\|resp_left' Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/` -- should return empty
  - Confirm all workaround code has been deleted

- [ ] **R5.4: Verify backward game theorem is self-contained**
  - `#print axioms ghr93_forward_to_backward_rank_varying` -- should show no sorryAx
  - If it does, trace and document the remaining sorry chain

**Timing**: 0.5-1 hour

**Depends on**: R3, R4

---

### Phase 6D: Proposition 12.8.16 -- Temporal Type -> Game Strategy [NOT STARTED]

**Goal**: If x in M and y in N satisfy the same temporal formulas of rank r+4n+1, then Duplicator wins G_{n,r} on the corresponding intervals.

**Tasks**:

- [ ] State proposition using `stavi_n_equiv`, `rank_type`, `ghr93_duplicator_wins`
- [ ] Prove base case n=0 (trivial)
- [ ] Prove inductive step: construct response using formula C_0 from GHR93 proof sketch
- [ ] Handle gap case (r-definable gaps as endpoints)
- [ ] `lake build`

**Timing**: 2-4 hours

**Depends on**: none (uses only sorry-free EFGames infrastructure)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend existing)

---

### Phase 6E: Full Proposition 12.8.18 -- m-Tuple Game Composition [NOT STARTED]

**Goal**: Extend single-pivot `ghr93_strategy_compose` to full m-tuple composition.

**Tasks**:

- [ ] State full m-tuple composition using EF game types
- [ ] Define partition of Spoiler's choice into sub-intervals
- [ ] Apply single-pivot composition iteratively (induction on m)
- [ ] Prove cross-sub-interval order preservation
- [ ] Connect to `ef_duplicator_wins`
- [ ] `lake build`

**Timing**: 3-6 hours

**Depends on**: 6D

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean`

---

### Phase 6F: Corollary 12.8.19 -- Temporal -> FO Equivalence [NOT STARTED]

**Goal**: If x in M and y in N satisfy the same temporal formulas of rank g(n+1)+1, then for all monadic FO formulas phi of QD <= n, M |= phi(x) iff N |= phi(y).

**Tasks**:

- [ ] Prove or import Prop 12.8.9 (standard EF <-> FO agreement)
- [ ] Combine 12.8.9 + 12.8.16 (Phase 6D) + 12.8.18 (Phase 6E) into Cor 12.8.19
- [ ] State in terms of `stavi_n_equiv` and `nf_eval_nf` for StaviCompleteness integration
- [ ] `lake build`

**Timing**: 2-4 hours

**Depends on**: 6E

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend existing)

---

### Phase 6C-4: Classical Characterization via Cor 12.8.19 [NOT STARTED]

**Goal**: Close `nf_2var_existence_characterizable` (succ k' case) using the GHR93 classical argument. Remove dead code.

**Dead code to remove** (~150 lines):
- `interval_nf_types` (StaviCompleteness.lean line 1835)
- `nf_2var_from_interval_data` (line 1853, sorry'd bridge lemma)
- `nf_2var_transfer` (line 1877)
- `nf_exist_sf_guarded_backward` (line 2125, sorry'd)
- `nf_2var_exist_sf_classical` (line 2157)

**Tasks**:

- [ ] Remove dead code listed above
- [ ] Implement classical characterization using Cor 12.8.19
- [ ] Close `nf_2var_existence_characterizable` sorry
- [ ] `lake build`

**Timing**: 2-4 hours

**Depends on**: 6F (Corollary 12.8.19)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

---

### Phase 6C-5: Verify EFGames Build [NOT STARTED]

**Tasks**:

- [ ] `#print axioms nf_characterizable_by_stavi` -- no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` -- no `sorryAx`
- [ ] Verify zero sorry warnings in EFGames/
- [ ] `lake build` passes

**Timing**: 0.5 hours

**Depends on**: 6C-4

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete [NOT STARTED]

**Goal**: Close `no_gaps_discrete` in `GoodStructures.lean:842`.

**Tasks**:

- [ ] Read current state of `no_gaps_discrete`
- [ ] Implement gap elimination argument
- [ ] `#print axioms no_gaps_discrete` -- no `sorryAx`
- [ ] `lake build` passes

**Timing**: 2-4 hours

**Depends on**: 6C-5

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`

---

### Phase 8: Close succ_cofinal via Gap Elimination [NOT STARTED]

**Goal**: Prove `succ_cofinal` (`ChronicleToCountermodel.lean:1508`). Also close sub-proof sorries at lines 1285, 1441.

**Tasks**:

- [ ] Close sub-proof sorry at line 1285 (boundary case)
- [ ] Close sub-proof sorry at line 1441 (below-min case)
- [ ] Close sorry at line 1508 (`limit_dom_points_are_succ_iterates`)
- [ ] Wire `no_gaps_discrete` to prove `IsSuccArchimedean` for `LimitDomSubtype`
- [ ] `#print axioms dd_countermodel_chronicle_discrete` -- no `sorryAx`
- [ ] `lake build` passes

**Timing**: 2-4 hours

**Depends on**: 7

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

---

### Phase 9: Final Verification [NOT STARTED]

**Tasks**:

- [ ] `#print axioms bx_completeness` -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Verify `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)
- [ ] `lake build` -- zero errors
- [ ] Sorry count assessment across entire codebase

**Timing**: 0.5 hours

**Depends on**: R5, 8

---

## Superseded Approaches

The following 29 approaches have been tried and ruled out. Do NOT re-attempt.

| # | Approach | Why It Failed |
|---|----------|---------------|
| 1 | Track A: OrderIso bypass | `chronicle_is_good` requires `succ_cofinal`. No bypass exists. |
| 2 | Approach A: Fintype StaviFormula enumeration | `StaviFormula` has infinite atoms. |
| 3 | Approach B: NormalForm -> StaviFormula inversion | CIRCULAR. |
| 4 | h_d_unique (uniqueness from rank-r type) | MATHEMATICALLY FALSE at depth r+2. |
| 5-13 | Various game restructuring approaches | See v39 plan for details. |
| 14-22 | Various same_order_type approaches | See v39 plan for details. |
| 23-26 | Various sf_top/NF approaches for backward direction | All circular or insufficient. |
| 27 | Interval guard bridge lemma | Outside-interval hypotheses structurally unavailable. |
| 28 | Phase 3C depending on Phase 6C | Circular dependency. |
| 29 | U(B,A) with char_k for rank-r agreement | DEPTH-AGREEMENT GAP: char_k gives depth ~2k_nf, not rank-r. This is the root cause fixed by this plan. |

## Settled Questions

All settled questions from v39 remain valid, plus:

- **The rank flattening is the root cause of ALL workaround needs** (report 39). Fixing it eliminates char_k, tau_r2, h_ih_r2, resp_mod, tau_left, same_side, and sel_pn_ord issues.
- **game_depth does NOT need to change** (report 39). Only the induction infrastructure in Theorem6.lean and SplitPoint.lean needs restructuring.
- **delta=4 suffices for SplitPointProps** (report 39). GHR93 peels off exactly 4 per induction step.
- **Positions stay at rank r; sigma/tau play at rank r+4 on rank-embedded positions** (report 39). rank_embed bridges the gap.

## Testing & Validation

- [ ] Phase R1: SplitPointProps compiles with delta parameter
- [ ] Phase R2: Theorem6 compiles without char_k parameters
- [ ] Phase R3: CaseAnalysis sorry count drops from 9 to 0-1
- [ ] Phase R4: DConsistencyTransport and GapDetection compile
- [ ] Phase R5: Full build, sorry audit, no workaround remnants
- [ ] Phase 6D: Prop 12.8.16 sorry-free
- [ ] Phase 6E: Full Prop 12.8.18 sorry-free
- [ ] Phase 6F: Cor 12.8.19 sorry-free
- [ ] Phase 6C-4: `nf_2var_existence_characterizable` sorry closed
- [ ] Phase 6C-5: `#print axioms nf_characterizable_by_stavi` -- no `sorryAx`
- [ ] Phase 7: `#print axioms no_gaps_discrete` -- no `sorryAx`
- [ ] Phase 8: `succ_cofinal` sorry closed
- [ ] Phase 9: `#print axioms bx_completeness` -- only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `Expressiveness/SplitPoint.lean` -- SplitPointProps with delta parameter (Phase R1)
- `Expressiveness/Theorem6.lean` -- delta-carrying induction (Phase R2)
- `Expressiveness/CaseAnalysis.lean` -- Clean Case II with tau at r+4, workarounds deleted (Phase R3)
- `Expressiveness/DConsistencyTransport.lean` -- rank adjustments if needed (Phase R4)
- `EFGames/GapDetection.lean` -- rank adjustments if needed (Phase R4)
- `EFGames/Composition.lean` -- ghr93_strategy_compose (Phase 6A, COMPLETED)
- `EFGames/StaviCompleteness.lean` -- NF characterization (Phases 6C-4/5)
- `EFGames/` -- new files for Props 12.8.16/18, Cor 12.8.19 (Phases 6D/6E/6F)
- `IntegerModel/GoodStructures.lean` -- Phase 7
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Phase 8

## Rollback/Contingency

**Phases R1-R3 (rank restructuring)**: If the delta parameter introduces too many rank_embed cascading issues in SplitPoint.lean's 4657 lines:
- Fallback: use the "minimal rank bump" approach from research report Section 6 -- keep current architecture but add delta=4 ONLY to sigma/tau fields, without restructuring the induction. This is simpler but less mathematically clean.
- Second fallback: axiomatize sigma/tau at rank r+4 as a sorry'd bridge lemma, prove everything downstream, then close the bridge lemma later.

**Phase R3 (CaseAnalysis rewrite)**: If rewriting Case II is too invasive:
- Fallback: keep the existing resp_mod/tau_left infrastructure but wire tau at r+4 through it. This preserves more existing code but is less clean.
- Keep old code on a git branch for reference.

**Phases 6D/6E/6F**: If full GHR93 chain too complex, axiomatize Cor 12.8.19 with documentation.

**Phase 8**: If succ_cofinal blocked, Task 129 (Henkin canonical model) is an alternative path.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
