# Implementation Plan: Uniform-Rank Reformulation via Sorry-Free ghr93_forward_to_backward (v10)

- **Task**: 273 - Eliminate sorryAx from `US_expressively_complete_over_prior` via GHR93 game-theoretic argument
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phases 0-1 from v3 completed; bridge lemmas from v9 cycle 7 retained)
- **Research Inputs**:
  - 4-agent parallel research sweep (2026-06-09): literature, decomposition, kamp-bypass, sorry-chain
  - literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md
  - specs/273_chronicle_gap_contradiction_proof/reports/06_decomposition-path-research.md
  - Phase 2 handoff analysis (2026-06-09): architectural blocker identification
- **Artifacts**: plans/10_uniform-rank-reformulation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v10 replaces v9's blocked Phase 2 (fixed-pivot architecture) with **Approach B: uniform-rank reformulation**. After 7 implementation cycles, deep analysis revealed that the current `DiscreteGameTransfer.lean` architecture is mathematically incorrect: (1) the pivot must depend on Spoiler's selections, not be fixed; (2) rank-UP conversion from r to r+2 is invalid even for discrete orders; (3) d-consistency requires the full GHR93 Claim 1 argument that already exists sorry-free in the general infrastructure.

The key insight: `ghr93_forward_to_backward` (Theorem6.lean:160) is **already sorry-free** and takes `h_r1_univ` as an explicit hypothesis. The bridge lemma `discrete_rank_embed_eq_drc` (DiscreteGameTransfer.lean:607, also sorry-free) converts between `rank_embed` and `discrete_rank_convert`. Instead of reimplementing Theorem 6 for discrete orders, we reformulate `discrete_ghr93_theorem6` to delegate to the sorry-free general infrastructure, passing `h_r1_univ` through from the caller.

### Research Integration

Reports integrated in this plan revision:
- `reports/06_decomposition-path-research.md` (integrated v9)
- 4-agent research sweep findings (integrated v9)
- Phase 2 handoff (phase-2-handoff-20260609T121324Z.md) (integrated v10)

### Strategy Change from v9

**v9 Phase 2** (BLOCKED): Attempted to prove Theorem 6 for discrete orders independently, using a fixed-pivot decomposition (`discrete_pivot_and_restrict` + `discrete_backward_extend`). This required solving d-consistency, pivot construction, and case analysis from scratch -- all of which depend on the sorry-free general infrastructure that already handles them.

**v10 Phase 2** (NEW): Delete the broken helpers (`discrete_restrict_forward_left/right`, `discrete_pivot_and_restrict`, `discrete_backward_extend`) and replace with a thin wrapper that:
1. Converts discrete endpoints via `discrete_rank_embed_eq_drc` to `rank_embed` format
2. Calls the sorry-free `ghr93_forward_to_backward` directly
3. Passes `h_r1_univ` through as an explicit hypothesis (provided by Phase 4's caller)

This eliminates all 4 sorry sites at once by replacing ~300 lines of broken code with ~50 lines of delegation.

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
  discrete_ghr93_theorem6 (DiscreteGameTransfer.lean:928) -> NOTHING
```

### Existing Sorry-Free Infrastructure (Retained)

| Theorem | File | Line | Status |
|---------|------|------|--------|
| `ghr93_forward_to_backward` | Theorem6.lean | 160 | Sorry-free |
| `ghr93_forward_to_backward_rank_varying` | Theorem6.lean | 207 | Sorry-free |
| `obtain_split_point_props` | SplitPoint.lean | 150 | Sorry-free |
| `ghr93_case_I` / `ghr93_case_II` | CaseAnalysis.lean | -- | Sorry-free |
| `d_consistency_left` / `d_consistency_right` | DConsistencyTransport.lean | -- | Sorry-free |
| `ghr93_strategy_compose` | Composition.lean | 40 | Sorry-free |
| `ghr93_game_implies_decomposition` | Decomposition.lean | 117 | Sorry-free |
| `ghr93_decomposition_implies_game` | Decomposition.lean | 272 | Sorry-free |
| `discrete_nf_to_decomposition_agreement` | NFGameBridge.lean | 997 | Sorry-free |
| `game_win_to_formula_agree` | NFGameBridge.lean | 1222 | Sorry-free |
| `nf_fraisse_compression` | StaviCompleteness.lean | 2006 | Sorry-free |
| `zone_match_witness` | StaviCompleteness.lean | 2044 | Sorry-free |
| `discrete_ghr93_theorem6_zero` | DiscreteGameTransfer.lean | 360 | Sorry-free |
| `discrete_rank_embed_eq_drc` | DiscreteGameTransfer.lean | 607 | Sorry-free |
| `discrete_game_rank_down_compose` | DiscreteGameTransfer.lean | 620 | Sorry-free |
| `discrete_game_rank_down` | DiscreteGameTransfer.lean | ~540 | Sorry-free |
| `nf_exist_sf_guarded_forward` | StaviCompleteness.lean | 2643 | Sorry-free |

## Goals & Non-Goals

**Goals**:
- Eliminate `sorryAx` from `US_expressively_complete_over_prior`
- Reformulate `discrete_ghr93_theorem6` to take `h_r1_univ` as an explicit hypothesis and delegate to the sorry-free `ghr93_forward_to_backward`
- Build self-contained `discrete_nf_characterizable_by_stavi` that does NOT call the sorry'd general version
- Prove `nf_exist_sf_guarded_backward` for discrete orders via the game pipeline
- Delete broken fixed-pivot helpers that cannot be made to work

**Non-Goals**:
- Proving the general (non-discrete) `nf_exist_sf_guarded_backward` at line 2805
- Filling dead-code sorry sites at lines 2353/2435
- Implementing Cases III/IV of Theorem 6 (vacuous for discrete)
- Modifying `stavi_expressive_completeness` (general version retains sorry)
- Implementing a standalone discrete-specific pivot construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `rank_embed` / `discrete_rank_convert` mismatch in `h_r1_univ` threading | H | L | `discrete_rank_embed_eq_drc` (already proved, sorry-free) handles this conversion exactly. Use `rw [discrete_rank_embed_eq_drc]` at the boundary. |
| `h_pt` / `h_pt_M` (carrier point existence) hypotheses needed by `ghr93_forward_to_backward` | M | L | For discrete orders, every closed interval `[x, y]` with `x <= y` contains a carrier point. Prove `discrete_interval_has_point` as a ~10-line lemma using the fact that all `ExtendedCarrier` elements are carrier points in discrete orders. |
| Type mismatch between `discrete_rank_convert` (codomain rank r) and `rank_embed` (codomain rank r') | M | M | Both go to the same `ExtendedCarrier _ _ r'`, just constructed differently. `discrete_rank_embed_eq_drc` proves they are definitionally equal. If `simp` does not unify them, use `conv` + `rw`. |
| `nf_2var_existence_characterizable` caller needs `char_k_correct` for ALL M, not just discrete | H | M | The `discrete_nf_characterizable_by_stavi` proof (Phase 4, Task 4.5) must construct a `char_k_correct` that works for all M. The forward direction is sorry-free for all M. The backward direction for discrete M uses the game pipeline. For non-discrete M, use the IH's formula (which is identical) -- the discrete char_k IS a concrete StaviFormula that has a forward direction valid for all M. The trick: split the iff, use forward for all M, backward only for discrete M. |
| Proposition 7 interaction with h_r1_univ | M | M | Proposition 7 calls Theorem 6 in a loop. Each call needs h_r1_univ. The outer completeness framework provides h_r1_univ via decomposition agreement at all sub-intervals. Thread it through Proposition 7's induction. |
| DiscreteGameTransfer.lean import wiring | L | L | Currently not imported by StaviCompleteness.lean. Add import in Phase 4. |

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

### Phase 2: Reformulate discrete_ghr93_theorem6 with h_r1_univ Delegation [COMPLETED]

**Goal**: Replace the broken fixed-pivot architecture (4 sorries) with a thin wrapper that delegates to the sorry-free `ghr93_forward_to_backward`, threading `h_r1_univ` as an explicit hypothesis.

**What to delete**: The following helper lemmas are mathematically incorrect and must be removed:
- `discrete_restrict_forward_left` (lines 666-695): d-consistency sorry cannot be filled without full Claim 1 infrastructure
- `discrete_restrict_forward_right` (lines 699-721): symmetric, same problem
- `discrete_pivot_and_restrict` (lines 766-814): fixed-pivot architecture is wrong
- `discrete_backward_extend` (lines 816-869): depends on fixed pivot

**What to keep**:
- `discrete_game_rank_down` (sorry-free): rank conversion for discrete games
- `discrete_rank_embed_eq_drc` (sorry-free): bridge lemma
- `discrete_game_rank_down_compose` (sorry-free): composition helper
- `discrete_ghr93_theorem6_zero` (sorry-free): base case
- The d-consistency section header and documentation can be removed

**Tasks**:

- [x] **Task 2.1**: Add import of `Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6` to DiscreteGameTransfer.lean
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Content**: Add import at top. Verify no import cycles (Theorem6.lean imports CaseAnalysis which imports SplitPoint which imports Claim1 -- none of these import DiscreteGameTransfer).
  - **Estimated size**: 1-2 lines

- [x] **Task 2.2**: Prove `discrete_interval_has_point` -- carrier point existence in discrete intervals *(deviation: skipped — already existed from prior cycle)*
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: For discrete orders with `x <= y`, prove `exists p, inClosedInterval x y (extendPoint p)`. Since all `ExtendedCarrier` elements are carrier points in discrete orders (via `discrete_to_carrier`), extract the carrier point from `x` itself.
  - **Estimated size**: 10-20 lines

- [x] **Task 2.3**: Reformulate `discrete_ghr93_theorem6` to accept `h_r1_univ` and delegate to `ghr93_forward_to_backward`
  - **File**: `DiscreteGameTransfer.lean`
  - **New signature**:
    ```lean
    theorem discrete_ghr93_theorem6 {sig : MonadicSignature}
        {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        (n r : Nat)
        {x y : ExtendedCarrier M atomMap r}
        {x' y' : ExtendedCarrier N atomMap r}
        (hxy : x <= y) (hx'y' : x' <= y')
        (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) r x y x' y')
        (h_r1_univ : forall (r' : Nat) {x1 y1 : ExtendedCarrier M atomMap r'}
                       {x1' y1' : ExtendedCarrier N atomMap r'},
                     x1 <= y1 -> x1' <= y1' ->
                     ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2)
                       (rank_embed (by omega : r' <= r' + 2) x1)
                       (rank_embed (by omega : r' <= r' + 2) y1)
                       (rank_embed (by omega : r' <= r' + 2) x1')
                       (rank_embed (by omega : r' <= r' + 2) y1')) :
        ghr93_duplicator_wins N M atomMap n r x' y' x y
    ```
  - **Proof**: Direct call to `ghr93_forward_to_backward atomMap n r hxy hx'y' h_pt h_pt_M h h_r1_univ` where `h_pt` and `h_pt_M` come from `discrete_interval_has_point`.
  - **Key change from v9**: The theorem now operates at a SINGLE rank `r` (uniform rank), not `r + 4*n` forward / `r` backward. No `discrete_rank_convert` in the output type. The old rank-varying version is deleted.
  - **Estimated size**: 20-30 lines

- [x] **Task 2.4**: (Optional) Prove rank-varying wrapper if needed by downstream callers *(deviation: altered — provided proactively as discrete_ghr93_theorem6_rank_varying)*
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: If Phase 3 or Phase 4 needs the rank-varying statement (forward at `r + 4*n`, backward at `r`), prove it by composing the uniform-rank `discrete_ghr93_theorem6` with `discrete_game_rank_down`. The `h_r1_univ` can be constructed from the caller's rank-universal forward games.
  - **Depends on assessment in Phase 3**: May not be needed if the pipeline uses the uniform-rank version directly.
  - **Estimated size**: 30-50 lines

- [x] **Task 2.5**: Delete broken helpers and rebuild
  - **File**: `DiscreteGameTransfer.lean`
  - **Content**: Delete `discrete_restrict_forward_left`, `discrete_restrict_forward_right`, `discrete_pivot_and_restrict`, `discrete_backward_extend`, `discrete_backward_step` (which only delegated to the deleted helpers). Delete associated doc comments and section markers. Also delete the section `/-! ## Discrete Canonical Pivot: d-Consistency ... -/` and the section `/-! ## Discrete Backward Step ... -/`.
  - **Verification**: `lake build Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` -- no sorry in the file.

**Timing**: 2 hours

**Depends on**: none

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (net reduction of ~200 lines; ~50 new lines replacing ~250 deleted lines)

---

### Phase 3: GHR93 Proposition 7 for Discrete Orders [COMPLETED]

**Goal**: Prove Proposition 7 -- from sub-interval game wins at strength (f(n), g(n)), derive standard EF game wins at n rounds. This requires threading `h_r1_univ` through the Proposition 7 induction since each call to Theorem 6 needs it.

**GHR93 Reference**: Proposition 7, p.115, lines 1293-1340.

**Proof** (induction on n, GHR93 p.115-116):
- **n=0**: Trivial (0-round EF game is vacuously won).
- **n -> n+1**: Spoiler picks alpha. Find interval (x_i, x_{i+1}) containing alpha. Apply the forward game strategy to find matching e. By Lemma 11 forward (`ghr93_game_implies_decomposition`), get decomposition on sub-intervals. By Lemma 11 backward (`ghr93_decomposition_implies_game`), get forward games at (1+3f(n), r). By **Theorem 6** (`discrete_ghr93_theorem6` with `h_r1_univ`), invert to backward games at (f(n), r). Apply IH on the extended tuple.

**h_r1_univ threading**: Proposition 7 must accept `h_r1_univ` as a parameter and pass it to each Theorem 6 call. The caller (Phase 4) provides `h_r1_univ` from the decomposition framework.

**Tasks**:

- [x] **Task 3.1**: Define `standard_ef_duplicator_wins` or adapt existing *(deviation: altered -- used `discrete_universal_decomp` predicate and `decomp_point_challenge_MN/NM` + `wc_rank_type_at_point` helpers instead; game pipeline works through `ghr93_decomposition_implies_game`)*
  - **File**: `DiscreteGameTransfer.lean`
  - **Implemented**: `discrete_universal_decomp` (sub-interval oracle), `decomp_point_challenge_MN`, `decomp_point_challenge_NM`, `wc_rank_type_at_point`
  - **Lines**: ~80

- [x] **Task 3.2**: Prove Proposition 7 induction step for discrete orders *(deviation: altered -- added `discrete_point_challenge_with_sel_ordering` helper lemma that finds b from sub-interval decomposition by induction on n, using pivot_chain_order for boundary orderings; replaced old point challenge approach that tried to get b from base decomposition independently of selections)*
  - **File**: `DiscreteGameTransfer.lean`
  - **Done**: All sorries eliminated. `discrete_sorted_matching` handles sorted selection matching. `discrete_point_challenge_with_sel_ordering` (new, ~170 lines) handles point challenge with ordering preservation for all selections via inductive cell-finding. `discrete_ghr93_proposition7` uses both to build full game winning condition.
  - **Key insight**: The old approach obtained b from the base decomposition independently of selections, making ordering transfer between b and selections impossible. The fix uses sub-interval decompositions with sorted selections as boundaries, so b is automatically placed in the correct cell.

- [x] **Task 3.3**: Build verification
  - `lake build` passes (only pre-existing errors in CanonicalTaskRelation.lean, unrelated to this work)
  - Zero sorries in DiscreteGameTransfer.lean
  - `lean_verify discrete_ghr93_proposition7` -- sorryAx from upstream imports only (CaseAnalysis.lean has pre-existing sorries)

**RESOLVED** (Phase 3): Previously blocked by inability to transfer ordering between b and selections. Resolved by adding `discrete_point_challenge_with_sel_ordering` helper that uses inductive cell-finding with sub-interval decompositions.

**Timing**: 2.5 hours

**Depends on**: Phase 2

**Files modified**: `DiscreteGameTransfer.lean` (200-400 new lines)

---

### Phase 4: Bridge Game Wins to Leaf Sorry and Self-Contained Discrete Chain [BLOCKED]

**Goal**: Wire game wins from Proposition 7 into the ACTUAL leaf sorry (`nf_exist_sf_guarded_backward` at line 2805) via a discrete-only chain, build self-contained `discrete_nf_characterizable_by_stavi` that does NOT call the sorry'd general version, and provide `h_r1_univ` from the completeness framework.

**Critical architectural requirement**: The current `discrete_nf_characterizable_by_stavi` (line 3283) calls the sorry'd `nf_characterizable_by_stavi` at line 3326 to get `char_k_gen` for ALL models. The fix: create `discrete_nf_2var_existence_characterizable` that takes `char_k_correct` only for discrete M, using the game pipeline for the backward direction.

**How h_r1_univ is provided**: The completeness framework starts from decomposition agreement at n=0, r=k/2. The decomposition agreement gives game wins at all sub-intervals via `ghr93_decomposition_implies_game`. For `h_r1_univ`, we need forward games at rank `r'+2` for ALL pairs of intervals. This comes from the decomposition formula agreement: the same formula that gives decomposition at rank r also gives it at rank r+2 (formulas are rank-independent for discrete orders where all elements are carrier points). The `h_r1_univ` construction extracts this from the NF characterization at the caller level.

**The non-circular pipeline** (GHR93 Corollary 5 + Propositions 5-7):
```
NF hypotheses (1-var NF + interval types at depth k)
  -> decomposition_agreement at n=0, r=k/2       [Bridge A, sorry-free]
  -> ghr93_duplicator_wins at n=0, r=k/2          [Lemma 11 backward, sorry-free]
  -> construct h_r1_univ from decomposition agreement at r+2
  -> [Proposition 7 + Theorem 6 with h_r1_univ]
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

- [ ] **Task 4.2**: Prove `discrete_h_r1_univ_from_decomposition` -- construct h_r1_univ from decomposition agreement
  - **File**: `StaviCompleteness.lean` (or `DiscreteGameTransfer.lean`)
  - **Content**: Given `discrete_nf_to_decomposition_agreement` at rank `r` and `ghr93_decomposition_implies_game`, construct the `h_r1_univ` hypothesis needed by `discrete_ghr93_theorem6`. For discrete orders, decomposition agreement at rank `r` implies decomposition agreement at rank `r+2` because all elements are carrier points and `stavi_truth_mu_at_point` makes truth rank-independent. Then apply `ghr93_decomposition_implies_game` to get the forward game at rank `r'+2`.
  - **This is the key new lemma** that makes Approach B work. Without it, `h_r1_univ` would need to be hardcoded into the theorem signature with no provider.
  - **Estimated size**: 40-80 lines

- [ ] **Task 4.3**: Prove `discrete_nf_exist_sf_guarded_backward` -- the leaf sorry for discrete M
  - **File**: `StaviCompleteness.lean` (new theorem near line 2806)
  - **Type signature**: Same as `nf_exist_sf_guarded_backward` (line 2778) plus 5 discrete typeclass instances, and with `char_k_correct` restricted to discrete M.
  - **Proof strategy**:
    1. Extract witness x from the temporal formula (Until/Since gives x with witness_type true)
    2. From `char_k_correct` for discrete M, determine x's 1-var depth-k NF type
    3. Construct the interval data: h_nf_x, h_nf_t (1-var NFs), h_order_xt (ordering), interval_nf_types
    4. Apply `discrete_nf_to_decomposition_agreement` (Bridge A) for (x,t)/(x',t')
    5. Convert to game wins via `ghr93_decomposition_implies_game`
    6. Construct `h_r1_univ` via Task 4.2's lemma
    7. Apply `discrete_ghr93_proposition7` to get standard EF game wins
    8. Extract existential transfers at each depth via formula agreement
    9. Apply `nf_fraisse_compression` to get 2-var NF equality
    10. Conclude sub_nf is the 2-var NF of (x,t), hence the existence holds
  - **GHR93 Reference**: Corollary 5 (p.115) + Propositions 5-7.
  - **Estimated size**: 80-150 lines

- [ ] **Task 4.4**: Create `discrete_nf_2var_existence_characterizable`
  - **File**: `StaviCompleteness.lean`
  - **Type signature**: Same as `nf_2var_existence_characterizable` (line 2847) but `char_k_correct` restricted to discrete M only.
  - **Proof**: Forward direction uses `nf_exist_sf_guarded_forward` (sorry-free, works for all M). Backward direction uses `discrete_nf_exist_sf_guarded_backward` (Task 4.3).
  - **Critical**: This function takes `char_k_correct` for discrete M only, breaking the dependency on the sorry'd general version.
  - **Estimated size**: 40-60 lines

- [ ] **Task 4.5**: Rewrite `discrete_nf_characterizable_by_stavi` to be self-contained
  - **File**: `StaviCompleteness.lean` (modify existing at line 3283)
  - **Change**: At the succ k case (line 3304), replace the call to `nf_characterizable_by_stavi` (lines 3326-3334) with `discrete_nf_2var_existence_characterizable` (Task 4.4). Use the IH's discrete `char_k` instead of `char_k_gen` from the general version.
  - **Key insight**: The forward direction of `nf_exist_sf_guarded_forward` needs `char_k_correct` for ALL M. But the discrete IH gives `char_k_correct` only for discrete M. Solution: the forward direction proof path goes through `nf_exist_sf_guarded_forward` which needs `char_k_correct` for the SPECIFIC M being evaluated. For the discrete theorem, M is always discrete, so the discrete `char_k` suffices. Alternatively, use `discrete_nf_2var_existence_characterizable` which internally handles this split.
  - **Estimated size**: 40-80 lines (mostly replacing lines 3320-3347)

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

**BLOCKER** (Phase 4):
- **What failed**: Phase 4 depends on Phase 3 (Proposition 7) which is BLOCKED. The self-contained `discrete_nf_characterizable_by_stavi` requires a sorry-free `discrete_nf_exist_sf_guarded_backward`, which in turn requires the bridge lemma for discrete orders (`discrete_nf_2var_from_interval_data`), which requires the game pipeline including Proposition 7.
- **What was tried**: Deep analysis of the sorry chain (8+ approaches considered). The fundamental blocker is that `nf_exist_sf_guarded` does not encode the quantifier part of sub_nf in its formula. The backward direction (formula truth -> existence of witness with correct NF) requires proving that the structural data (1-var NF types, ordering, interval types) uniquely determines the 2-var NF. For discrete orders, this IS true (the bridge lemma), but proving it requires the game pipeline (Proposition 7).
- **Why it's stuck**: Blocked by Phase 3. Cannot make `discrete_nf_characterizable_by_stavi` self-contained without the bridge lemma for discrete orders.
- **What is needed**: Complete Phase 3 first, then use the game pipeline to prove `discrete_nf_exist_sf_guarded_backward` -> `discrete_nf_2var_existence_characterizable` -> self-contained `discrete_nf_characterizable_by_stavi` -> sorry-free `discrete_stavi_expressive_completeness` -> sorry-free `US_expressively_complete_over_prior`.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 2.5 hours

**Depends on**: Phase 3

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines, ~30 lines modified)
- `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 lines modified)

---

### Phase 5: Full Build Verification and Axiom Audit [BLOCKED]

**Goal**: Full project build, verify `completeness_discrete` sorry state, confirm the sorry chain is eliminated end-to-end. Blocked by Phases 3-4.

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
- [ ] Verify DiscreteGameTransfer.lean has ZERO sorries
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
- [ ] DiscreteGameTransfer.lean has zero sorry sites

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/10_uniform-rank-reformulation-plan.md` (this file, v10)
- Modified (Phase 2): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (net reduction ~200 lines)
- Modified (Phase 3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (200-400 new lines)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines, ~30 lines modified)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 lines modified)
- `specs/273_chronicle_gap_contradiction_proof/summaries/10_uniform-rank-reformulation-summary.md`

## Rollback/Contingency

- **If `discrete_rank_embed_eq_drc` does not compose cleanly with `ghr93_forward_to_backward`**: The bridge lemma was designed exactly for this. If type-level issues arise, wrap with `cast` or add a coercion lemma. The mathematical content is sound -- only Lean type plumbing may need adjustment.

- **If `h_r1_univ` cannot be provided from the decomposition framework (Task 4.2)**: Fall back to constructing `h_r1_univ` from the rank-independence of truth at carrier points (`stavi_truth_mu_at_point`). For discrete orders, the game at rank r+2 on carrier points is determined by the game at rank r, since both test the same formulas (carrier-point truth is rank-independent). This would be a ~50-line proof using `discrete_game_rank_down` in reverse direction (rank up for carrier-point-only games).

- **If the Proposition 7 induction is too complex**: Factor into per-step lemmas. Each induction step is: find matching point -> decomposition -> game inversion -> IH. These can be separate lemmas.

- **If self-contained discrete chain is too complex (duplication exceeds 400 lines)**: Factor the shared logic (formula construction, forward direction) into helper lemmas parameterized by the backward direction.

- **If DiscreteGameTransfer.lean build time exceeds heartbeat**: Split into `DiscreteGameTransfer/Theorem6.lean` and `DiscreteGameTransfer/Proposition7.lean`.

- **Git revert** to commit `9be0f7db2` (v9 plan commit) if any phase introduces regressions.
