# Implementation Plan: Reynolds Pipeline Activation (v39 -- Depth-Gap Resolution)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phases 1-4, 3A, 6A, 6C-1/2/3 complete. Phase 3C-Sort complete. Phase 3C-UBA blocked by depth-agreement gap discovered in research report 38. This revision restructures 3C-UBA into 3C-EQ (equality case, unblocked) + 3C-STRICT (strict case, requires new approach).
- **Effort**: 18-36 hours remaining
- **Dependencies**: Tasks 154, 147-148, 157, 195, 168, 174, 198, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: 46 reports in `specs/155_reynolds_pipeline_activation/reports/`, including `38_equality-case-research.md` (new, depth-gap analysis)
- **Artifacts**: plans/39_depth-gap-resolution-plan.md (this file), plans/38_sorting-uba-plan.md (superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan revises v38 to address the fundamental depth-agreement gap discovered in Phase 3C-UBA. The gap: GHR93 uses B = X_{alpha_n} (full rank-r type formula, depth r) transferred through rank-(r+4) tau, while the Lean code's tau is only rank-r and `char_k` gives depth ~2k_nf formulas where k_nf << r. The U(B,A) witness extracted via `char_k` has only k_nf-depth agreement with p_n, but the winning condition requires rank-r agreement.

The revision splits the blocked Phase 3C-UBA into two sub-phases:
- **Phase 3C-EQ**: Handle the equality case (a_init(k) = p_n). Unblocked, ~20-40 lines. Uses modified response function.
- **Phase 3C-STRICT**: Handle the strict case (a_init(k) < p_n). Requires resolving the depth-agreement gap.

For Phase 3C-STRICT, the plan pursues Proposition 12.8.18 strategy composition (Path C from research), which avoids sel_pn_ord entirely and is the mathematically cleanest resolution. This is consistent with GHR93's own approach -- the backward game theorem (12.8.15) uses composition to assemble sub-interval strategies, and the current single-pivot composition (Phase 6A) was always intended as a stepping stone to full m-tuple composition. The strict case's sel_pn_ord problem is precisely the kind of cross-interval ordering issue that composition resolves by construction.

**Key decision rationale**: Path B (increase game ranks to match GHR93) would be the most literally faithful to GHR93's proof, but at ~1000+ lines of cascading changes with high risk. Path C (strategy composition via Prop 12.8.18) is still GHR93-faithful -- it is the proof technique GHR93 itself uses at the macro level -- while being achievable within the existing rank infrastructure. Path D (k_nf-to-r bridge) is speculative and may be mathematically invalid. Path A (degenerate elimination + bridging) has medium risk and still needs a bridging argument that may not exist.

### Research Integration

- `reports/36_char-k-threading-research.md`: Confirms no circularity in CaseAnalysis.lean -> StaviCompleteness.lean import chain. Identifies 5-function threading path for char_k parameters. Verifies all needed StaviFormula constructors are public.
- `reports/37_sorting-approach-research.md`: Confirms sorting + U(B,A) together are necessary and sufficient. Regular tau (rank-r) suffices. No changes needed to SplitPointProps, obtain_split_point_props, Theorem6.lean, or CustomGame.lean. Identifies equality case risk (Monotone gives <=, not <) and witness extraction risk (std_untl semantics in extended carrier).
- `reports/38_equality-case-research.md`: Discovers fundamental depth-agreement gap between GHR93 and Lean code. GHR93's forward game rank is r+4(n+1) vs Lean's r; tau rank is r+4 vs r; B depth is r vs k_nf. Identifies four resolution paths: degenerate elimination (A), increase ranks (B), strategy composition (C), k_nf-to-r bridge (D). Confirms equality case is solvable via modified response function (~20-40 lines).

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

## Sorry-Free EFGames Infrastructure

| File | Lines | Key Content | GHR93 Reference |
|------|-------|-------------|-----------------|
| Defs.lean | 559 | EF games, extended carriers M_r, `stavi_n_equiv`, `game_depth` | Defs 12.8.8, 12.8.11, 12.8.17 |
| CustomGame.lean | 1690 | G_{n,r} game, `ghr93_duplicator_wins`, `ghr93_winning_condition_perm` | Def 12.8.11 |
| Composition.lean | 626 | `ghr93_strategy_compose` -- single-pivot sub-interval composition | Prop 12.8.7 / part of 12.8.18 |
| Decomposition.lean | 315 | `ghr93_game_iff_decomposition` -- game <-> decomposition | Lemma 12.8.14 |
| TypeFormulas.lean | 1043 | `rank_type`, `interval_types`, mu-relativized truth, rank embedding | Def 12.8.13 |
| GapDetection.lean | 5057 | Gap detection for Cases III/IV, left/right formula construction | Cases III/IV infrastructure |

## Current Sorry Sites

| File | Line | Definition | Status |
|------|------|-----------|--------|
| StaviCompleteness.lean | 1873 | `nf_2var_from_interval_data` | DEAD CODE -- to be removed (Phase 6C-4) |
| StaviCompleteness.lean | 2152 | `nf_exist_sf_guarded_backward` | DEAD CODE -- to be removed (Phase 6C-4) |

The actual target: `nf_2var_existence_characterizable` (succ k' case), which the dead code was supposed to close.

## GHR93 Formalization Status

| GHR93 Result | Status | Location |
|---|---|---|
| Def 12.8.8 (EF games) | DONE | Defs.lean |
| Def 12.8.11 (G_{n,r} game) | DONE | CustomGame.lean |
| Def 12.8.13 (rank_type, interval_types) | DONE | TypeFormulas.lean |
| Lemma 12.8.14 (game <-> decomposition) | DONE | Decomposition.lean |
| Def 12.8.17 (game_depth f(n)) | DONE | Defs.lean |
| Prop 12.8.7-style (single-pivot composition) | DONE | Composition.lean |
| **Theorem 12.8.15 (backward game)** | **PARTIAL** | CaseAnalysis.lean -- sel_pn_ord + winning condition sorries |
| **Prop 12.8.9 (standard EF <-> FO)** | **NOT STARTED** | -- |
| **Prop 12.8.16 (temporal rank -> game)** | **NOT STARTED** | -- |
| **Prop 12.8.18 (full m-tuple composition)** | **NOT STARTED** | Single-pivot only |
| **Cor 12.8.19 (temporal -> FO equivalence)** | **NOT STARTED** | -- |

## Goals & Non-Goals

**Goals**:
- Close all critical-path sorry sites following GHR93 exactly
- Handle the equality case (a_init(k) = p_n) via modified response function
- Resolve the strict case via strategy composition (Prop 12.8.18), eliminating sel_pn_ord entirely
- Prove the GHR93 classical chain: Theorem 12.8.15 -> Props 12.8.16/18 -> Cor 12.8.19
- Derive `nf_2var_existence_characterizable` classically from Cor 12.8.19
- Prove `succ_cofinal` via gap elimination
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- TruthLemma.lean sorry sites (non-critical-path)
- OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- OrderIso bypass (Track A) -- proven infeasible
- Changing d from inf(S_C) to min(selections) -- would break Claim 1 infrastructure
- Single-game restructuring of Case II -- infeasible (1-round budget deficit)
- Increasing game ranks to match GHR93 exactly (Path B -- too large, ~1000+ lines cascading changes)
- k_nf-to-r agreement bridge (Path D -- speculative, may be mathematically invalid)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Equality case: `Tuple.monotone_sort` gives `<=` not `<`, so a_init(k) = p_n is possible | Handle explicitly in Phase 3C-EQ: when a_init(k) = p_n, respond with e_n. Winning condition holds because both satisfy B = char_k(nf_pn). sel_pn_ord becomes False <-> False. |
| Strict case: depth-agreement gap prevents U(B,A) witness from having rank-r agreement | Resolved by using strategy composition (Phase 3C-STRICT). Composition assembles sub-interval strategies without requiring cross-interval ordering proofs. sel_pn_ord is eliminated entirely. |
| Full Prop 12.8.18 (m-tuple composition) is significantly larger than single-pivot | Iterate single-pivot composition (already proved in Composition.lean); induction on m. The hard case (cross-pivot degenerate intervals) is already handled. Estimate: 3-6 hours. |
| Restructuring Case II to use composition changes the proof architecture | The composition approach replaces the monolithic response function with composed sub-interval strategies. This is a cleaner architecture that better matches GHR93's actual proof structure. Existing Cases III/IV infrastructure is unaffected. |
| `std_untl` witness extraction in extended carrier may involve gaps | Extract the existential witness z from `stavi_temporal_truth_mu` for `std_untl`. If z is a gap, use the fact that `std_untl B sf_top` requires B(z) -- and B = char_k(nf_pn) characterizes a point type, so z must be a point. |
| Removing old forward-game e_n construction may break downstream code | Phase 3C-STRICT replaces the architecture. Keep old code until composition is verified. |
| stavi_temporal_truth vs stavi_temporal_truth_mu bridge | `stavi_truth_mu_at_point` already exists in GapDetection.lean:417. No new code needed. |
| Breaking existing sorry-free code in Cases III/IV | Cases III/IV do not use char_k. The composition approach for Case II is isolated from Cases III/IV. |
| Classical characterization in 6C-4 requires connecting Cor 12.8.19 to NF types | NormalForm is Fintype; classical enumeration is well-defined. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Notes |
|------|--------|------------|-------|
| 1 | 1, 2, 3A, 4, 6A, 6C-1/2/3 | -- | ALL COMPLETED |
| 2 | 3C-Sort | -- | COMPLETED |
| 3 | 3C-EQ | 3C-Sort | Equality case, low risk, ~20-40 lines |
| 4 | 6D | -- | Independent of backward game; can run parallel with 3C-EQ |
| 5 | 6E | 6D | Full m-tuple composition |
| 6 | 3C-STRICT | 6E | Uses composition to bypass sel_pn_ord |
| 7 | 3B | 3C-EQ, 3C-STRICT | Grid dispatch cleanup |
| 8 | 5 | 3C-STRICT | Cases III/IV winning condition |
| 9 | 6F | 6E | Corollary 12.8.19 |
| 10 | 6C-4 | 6F | Classical characterization |
| 11 | 6C-5 | 6C-4 | Verification |
| 12 | 7 | 6C-5 | no_gaps_discrete |
| 13 | 8 | 7 | succ_cofinal |
| 14 | 9 | 8 | Final verification |

Phases within the same wave can execute in parallel. Waves 3-4 (equality case + Prop 12.8.16) are independent parallel tracks. Wave 5 (m-tuple composition) enables both Wave 6 (strict case) and Wave 9 (Cor 12.8.19).

---

### Phase 1: Mechanical Sorry Closure S3 + S5 [COMPLETED]

Closed S3 (`h_cont_transfer_mr`) and S5 (`h_mr_resp_ge_d` gap case) via `game_tuple` simplification and gap proof mirroring. ~345 lines added to ExpressivenessGeneral.lean (now split into Expressiveness/ submodules).

---

### Phase 2: Pigeonhole + K-(negD) Bridge [COMPLETED]

Closed S1/S2 (Claim 1 cluster) using K-(negD) bridge, complement_no_min witnesses. Also closed S4 (multi-round K-(negD)) and S7-right. Key finding: K-(negD) bridge is necessary scaffolding.

---

### Phase 3A: sel_pn_ord Sorry'd Field [COMPLETED]

Added sorry'd `have sel_pn_ord` and `pn_sel_ord` at both Case A and Case B sites in CaseAnalysis.lean. The sorry is at the usage sites -- concentrated, ready for closure.

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]

Added `ghr93_rank_down_proj` (233 lines) for position-tracking variant of rank_down. S6 closed directly. S7-right expanded with K-(negD) closure.

---

### Phase 6A: GHR93 Proposition 7 -- Strategy Composition [COMPLETED]

`ghr93_strategy_compose` in new Composition.lean (626 lines, sorry-free). Combines Duplicator winning strategies on sub-intervals [x,c] and [c,y] into full interval [x,y]. Includes degenerate sub-interval compatibility hypotheses.

---

### Phase 6B: EFGames-Internal Case Analysis [SUPERSEDED]

Superseded by Phase 6C formula construction approach.

---

### Phase 6C-1: k=0 Base Case [COMPLETED]

Proved `nf_2var_existence_characterizable` for k=0 (~160 lines). At depth 0, atoms+order determine the 2-var NF. Backward direction uses case analysis on AtomKind sig 2, extracting pred/order info from the Until/Since formula.

---

### Phase 6C-2: Interval Guard Formula [COMPLETED]

Defined `interval_guard_sf` (disjunction of all `char_k` formulas -- always satisfiable) and `nf_exist_sf_guarded` (replaces `sf_top` with `interval_guard_sf` in Until/Since guard). Also proved `interval_guard_sf_true`.

---

### Phase 6C-3: Forward Direction [COMPLETED]

Proved `nf_exist_sf_guarded_forward` sorry-free. Guard obligation at intermediate points discharged via `nf_characteristic_satisfies` + `char_k_correct` (IH).

---

### Phase 3C-Sort: Sorting Preprocessing Wrapper [COMPLETED]

Added sorting preprocessing at `ghr93_inductive_step` level. `Tuple.sort` + `Tuple.monotone_sort` provide sorted selections where a_bwd(n) is the maximum element. `ghr93_winning_condition_perm` transfers winning condition back to unsorted. `h_mono : Monotone a_bwd` threaded to `ghr93_case_II`.

---

### Phase 3C-EQ: Equality Case Response Modification [COMPLETED]

**Goal**: Handle the case where a_init(k) = extendPoint p_n (Spoiler picked a duplicate of the split point). This is a well-defined sub-problem unblocked by the depth-agreement gap.

**GHR93 context**: GHR93 assumes strictly increasing selections (x' < alpha_0 < ... < alpha_n < y'). The Lean game definition allows non-injective selections. When a_init(k) = p_n, the sel_pn_ord biconditional `a_init(k) < p_n <-> resp(k) < e_n` becomes `False <-> (resp(k) < e_n)`, which requires resp(k) >= e_n. The fix: respond with e_n itself when a_init(k) = p_n.

**Tasks**:

- [x] **3C-EQ.1: Case split on a_init(k) vs p_n** *(deviation: altered -- defined `resp_mod` with `if a_init k = extendPoint p_n then e_n else resp_tau k`, plus lifted all tau ordering facts to resp_mod with case-split proofs. ~80 lines instead of 10-15.)*
- [x] **3C-EQ.2: Close sel_pn_ord for equality case** *(completed -- `sel_pn_ord` equality case trivial: `(False ↔ False) ∧ (True ↔ True)`. Strict case sorry'd for Phase 3C-STRICT.)*
- [x] **3C-EQ.3: Winning condition for equality case** *(completed -- gap_point_agreement and formula_agreement both handle equality case via hform_en_an and point/gap properties of e_n.)*
- [x] **3C-EQ.4: Build verification** -- `lake build` passes, equality-case sorry closed in both Case A and Case B. 8 new Phase 3C-STRICT sorries (mixed ordering cases + strict same_side) replace 2 universal same_side sorries.

**Timing**: 1-2 hours

**Depends on**: 3C-Sort (COMPLETED)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 3C-STRICT: Strict Case via Strategy Composition [IN PROGRESS]

**Goal**: Resolve the strict case (a_init(k) < p_n for all k < n, from sorting + injectivity or from equality case handled separately) by restructuring Case II to use full m-tuple strategy composition from Phase 6E. This eliminates sel_pn_ord entirely for the strict case.

**The depth-agreement gap (why U(B,A) alone fails)**:
GHR93 uses B = X_{alpha_n} with depth r, transferred through rank-(r+4) tau. The Lean code's char_k gives depth ~2k_nf << r. The U(B,A) witness z satisfies char_k(nf_pn) (k_nf-depth agreement) but NOT full rank-r agreement needed by the winning condition. No bridging argument exists within the current rank infrastructure.

**Resolution via composition**: Instead of constructing a single response function that requires cross-interval ordering proofs (sel_pn_ord), decompose Case II into sub-interval games and compose their strategies using Prop 12.8.18 (Phase 6E). The composition theorem guarantees the composed strategy is winning without requiring explicit ordering between responses in different sub-intervals.

**GHR93 alignment**: This IS how GHR93 proves the backward game theorem. GHR93 Theorem 12.8.15 uses composition at the top level: given winning strategies for sub-intervals determined by the split point, compose them into a winning strategy for the full interval. The current Lean code attempted a shortcut (direct response function with cross-interval ordering) that does not work at the Lean code's rank bounds.

**Tasks**:

- [x] **3C-STRICT.1: Restructure Case II game decomposition** *(deviation: altered -- constructed sub-interval backward games via ih + h_r1_univ + rank_down + round_mono, composed with ghr93_strategy_compose. Used tau_left responses directly rather than full composition restructuring. ~80 lines.)*
  - **File**: CaseAnalysis.lean, `ghr93_case_II`
  - Instead of constructing a monolithic response function:
    1. Split the interval [x', y'] at the split point c and at p_n
    2. For each sub-interval, obtain a winning strategy from existing infrastructure:
       - [x', d]: sigma's strategy (forward game, already available)
       - [d, c] or [d, p_n]: tau's strategy (backward game, already available)
       - [p_n, y']: need to construct (from tau + e_n properties)
    3. Apply Prop 12.8.18 (Phase 6E) to compose sub-interval strategies
  - The composed strategy automatically handles ordering between sub-intervals

- [ ] **3C-STRICT.2: Construct sub-interval strategy for [p_n, y']** (~40-80 lines)
  - The N-side interval [p_n, y'] has p_n as its left endpoint
  - Use the U(B,A) witness to place e_n > p_n on the M-side
  - The sub-interval strategy on [e_n, y'] follows from the forward game infrastructure
  - Even though the U(B,A) witness only has k_nf-depth agreement with p_n, the sub-interval strategy only needs agreement at the interval's rank, which composition handles

- [ ] **3C-STRICT.3: Wire composition into winning condition** (~40-60 lines)
  - Apply `ghr93_strategy_compose` (Phase 6A) or its m-tuple generalization (Phase 6E)
  - The composed winning condition follows from the composition theorem's guarantees
  - No sel_pn_ord needed: the composition theorem handles cross-interval ordering internally
  - Remove or comment out the sel_pn_ord sorry sites (they become dead code)

- [ ] **3C-STRICT.4: Delete dead sel_pn_ord infrastructure** (~negative 50-100 lines)
  - Remove the sorry'd sel_pn_ord and pn_sel_ord fields
  - Remove the b_resp sorry sites that depended on sel_pn_ord
  - Keep the forward-game e_n construction if needed by other cases
  - Clean up any dead code from the old monolithic response function

- [ ] **3C-STRICT.5: Build verification** -- `lake build` passes, sel_pn_ord + b_resp sorries eliminated

**Timing**: 4-8 hours

**Depends on**: 6E (Prop 12.8.18 m-tuple composition)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 3B: Structured Proof Tactic Overhaul [IN PROGRESS -- 2 goals deferred to 3C-STRICT]

**Goal**: Close remaining Case B grid dispatch goals using ordering proofs from Phase 3C.

**Status**:
- [x] Case A (S8): Sorry-free, all ~25 grid goals close
- [x] Case B impossible-direction goals (3 of 6): Closed by task 199
- [x] Case B Goal 3 sel(i) vs p_n (both variants): Closed via rename_i + hab_eq + sel_pn_ord
- [ ] Case B Goals 1-2: b_resp vs p_n (deferred to Phase 3C -- same root cause)
- [ ] Remove dead code after Phase 3C resolves remaining goals

**Note**: With the composition approach (Phase 3C-STRICT), the b_resp goals may be eliminated entirely rather than proved. The grid dispatch may simplify significantly.

**Timing**: 1-2 hours after Phases 3C-EQ and 3C-STRICT

**Depends on**: 3C-EQ, 3C-STRICT

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 5: Cases III/IV Winning Condition Assembly [PARTIAL]

**Goal**: Close S11 winning condition assembly in Cases III/IV.

**Status**:
- [x] S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`): Closed via parameter approach
- [x] Gap detection infrastructure: Complete (left/right formula, gap_detection_unique)
- [x] Interval bounds (lines ~3328, ~3639): Closed (degenerate boundary + non-degenerate contradiction)
- [ ] Winning condition assembly (line ~4100): ~200 lines, needs resolution from Phase 3C

**Note**: With the composition approach, Cases III/IV may benefit from the same composition infrastructure. The winning condition assembly may use sub-interval composition rather than direct sel_pn_ord.

**Timing**: 2-4 hours after Phase 3C-STRICT

**Depends on**: 3C-STRICT (composition infrastructure)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 6D: Proposition 12.8.16 -- Temporal Type -> Game Strategy [NOT STARTED]

**Goal**: If x in M and y in N satisfy the same temporal formulas of rank r+4n+1, then Duplicator has winning strategies for G_{n,r}(M, -inf x; N, -inf y) and G_{n,r}(M, x inf; N, y inf).

**Tasks**:
- [ ] State proposition using `stavi_n_equiv`, `rank_type`, `ghr93_duplicator_wins`
- [ ] Prove base case n=0 (trivial)
- [ ] Prove inductive step: construct response using formula C_0 from GHR93 proof sketch
- [ ] Handle gap case (r-definable gaps as endpoints)
- [ ] Run `lake build`

**Timing**: 2-4 hours

**Depends on**: none (uses only sorry-free EFGames infrastructure)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend existing)

---

### Phase 6E: Full Proposition 12.8.18 -- m-Tuple Game Composition [NOT STARTED]

**Goal**: Extend single-pivot `ghr93_strategy_compose` to full m-tuple composition: given winning strategies on all sub-intervals, compose into a winning strategy for G^{n+1}((M, x_bar), (N, y_bar)).

**Critical for depth-gap resolution**: This phase is now on the critical path. Phase 3C-STRICT depends on this for the strict case resolution. The composition theorem must support:
1. Arbitrary number of pivot points (not just single-pivot)
2. Composition of strategies with different rank parameters on sub-intervals
3. Automatic handling of cross-interval ordering (eliminates sel_pn_ord)

**Tasks**:
- [ ] State full m-tuple composition using EF game types
- [ ] Define partition of Spoiler's choice into sub-intervals
- [ ] Apply single-pivot composition iteratively (induction on m)
- [ ] Prove cross-sub-interval order preservation (this is the key property that eliminates sel_pn_ord)
- [ ] Connect to `ef_duplicator_wins`
- [ ] Prove that composed strategy inherits winning condition from sub-interval strategies
- [ ] Run `lake build`

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
- [ ] Run `lake build`

**Timing**: 2-4 hours

**Depends on**: 6E

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend existing)

---

### Phase 6C-4: Classical Characterization via Cor 12.8.19 [BLOCKED on 6F]

**Goal**: Close `nf_2var_existence_characterizable` (succ k' case) using the GHR93 classical argument. Remove dead code from the failed Approach A (interval guard bridge).

**Dead code to remove** (~150 lines):
- `interval_nf_types` (line 1835)
- `nf_2var_from_interval_data` (line 1853, sorry'd bridge lemma)
- `nf_2var_transfer` (line 1877)
- `nf_exist_sf_guarded_backward` (line 2125, sorry'd)
- `nf_2var_exist_sf_classical` (line 2157)

**Keep**: `interval_guard_sf`, `interval_guard_sf_true`, `nf_exist_sf_guarded`, `nf_exist_sf_guarded_forward`

**Classical argument**:
P(t) = "exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" is a monadic FO property of QD <= k+1. By Cor 12.8.19 (Phase 6F), P is determined by the temporal type at rank g(k+2)+1. The characterizing StaviFormula is the disjunction of NF types consistent with P.

**Tasks**:
- [ ] Remove dead code listed above
- [ ] Implement classical characterization using Cor 12.8.19
- [ ] Close `nf_2var_existence_characterizable` sorry
- [ ] Run `lake build`

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

**Goal**: Close S14 (`no_gaps_discrete` in GoodStructures.lean:842). The integer model has no gaps because every NF is characterizable by a StaviFormula (Phase 6C), and StaviFormulas are determined by their truth at integer points.

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

**Goal**: Prove `succ_cofinal` (ChronicleToCountermodel.lean:1885). Also close sub-proof sorries at lines 1285, 1441, 1508.

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

**Timing**: 0.5 hours

**Depends on**: 8

---

## Superseded Approaches

The following 29 approaches have been tried and ruled out. Do NOT re-attempt.

| # | Approach | Where Tried | Why It Failed |
|---|----------|-------------|---------------|
| 1 | **Track A: OrderIso bypass** | Phase A1 (v28) | `chronicle_is_good` requires `ChronicleAsPriorModel` which fills `domain_succ_archimedean := limitDomSubtype_isSuccArchimedean` using `succ_cofinal`. Every path from Burgess chronicle to countermodel on Int goes through `IsSuccArchimedean`. No bypass exists. |
| 2 | **Approach A: Fintype StaviFormula enumeration** | Phase B2 (v28) | `StaviFormula` has `Formula` atoms (infinite type). `Fintype { A : StaviFormula // stavi_depth A <= r }` is not constructible. |
| 3 | **Approach B: NormalForm -> StaviFormula inversion** | reports 38-39 | CIRCULAR: converting NF back to StaviFormula IS the expressive completeness theorem being proved. |
| 4 | **h_d_unique (uniqueness from rank-r type)** | Lines 2755-2859 | MATHEMATICALLY FALSE: K-(negD) has depth r+2, two points can share rank-r type but differ at r+2. |
| 5 | **h_fwd_n1_d at (n+1) rounds** | Phase 3 sessions | game_tuple dite reduction blocked by Fin arithmetic. The (1+3n+1)-round d-compat approach avoids this entirely. |
| 6 | **d = a_bwd(n) with rank-(r+1)** | Several sessions | d_consistency literally false when d is not d-bar. |
| 7 | **Gap equivalence lemma** | report 37 | FALSE in general: adjacent points and gaps disagree on atoms. |
| 8 | **pivot_chain_order without c <= e_n** | Multiple sessions | Requires c <= e_n as input, which is exactly what needs proving. |
| 9 | **Deriving sel-vs-p_n ordering from existing games** | Phase 3 impl v2 | 5 approaches tried, all fail. Fork geometry, not chain. Counterexample: d=0, b_en=1, p_n=2, y'=3. |
| 10 | **Extract sel_pn_ord from hord_big directly** | Approach A | a'_big(k) != a_init(k); same-side-of-d != same-side-of-p_n. |
| 11 | **sel_pn_ord as SplitPointProps field** | Approach B | p_n only defined inside ghr93_case_II, not at construction time. |
| 12 | **Play tau with e_n, pivot through b_tau_en** | Approach D | Fan problem: d <= a_init(k) and d <= b_tau_en gives no chain. |
| 13 | **Restructure big game N-side** | Approach C | Forward game has M selecting -- cannot force N-side = a_init. |
| 14 | **same_order_type_grid with convert/congr** | Phase 3 (5 variants) | Anonymous hypotheses from split_ifs prevent targeted Fin rewrites. |
| 15 | **Unified forward game (Approach E)** | Phase 3A + report 34 | Game play produces new N-side responses != a_init. Counterexample blocks all 6 sub-approaches. |
| 16 | **Two-phase tau construction** | report 34 | Produces b_fwd != e_n and a'_fwd(k) != a_init(k). |
| 17 | **fan_order abstract lemma** | Task 199 | PROVABLY FALSE: counterexample p=0, a=1, b=2, q=0, a'=2, b'=1. |
| 18 | **grid_order_tac macro** | Task 199 | Blocked by fan_order invalidity. |
| 19 | **Sorting + Lemma 10 alone** | Report 41 | Sorting resolves N-side only. M-side fan persists. |
| 20 | **Changing d from inf(S_C)** | Report 41 | Breaks continuation set + Claim 1 infrastructure. |
| 21 | **Direct formula without nf_characterizable_by_stavi** | Report 42b | Building interval type formulas AS StaviFormulas IS nf_characterizable_by_stavi. No shortcut. |
| 22 | **Single-game architecture for Case II** | Report 42c | All 6 variants infeasible. 1-round budget deficit is structural. |
| 23 | **nf_exist_sf backward with sf_top (k>0)** | Phase 6C | sf_top allows any intermediate type. 2-var NF at k>0 needs 3-var realizability info. |
| 24 | **"Good NF" disjunction** | Phase 6C | P has QD k+1, char_k gives only depth-k. Two depth-k-equivalent points can disagree on P. |
| 25 | **NF finiteness + definability** | Phase 6C | CIRCULAR: showing P is NF-invariant IS expressive completeness. |
| 26 | **Reduction to stavi_expressive_completeness** | Phase 6C | CIRCULAR: stavi_expressive_completeness depends on nf_characterizable_by_stavi at depth k+1. |
| 27 | **Interval guard bridge lemma** | Phase 6C-4 (4 cycles) | `nf_2var_from_interval_data` needs outside-interval hypotheses (`h_above_max`, `h_below_min`) that CANNOT be extracted from Until/Since. Structurally unusable for k>=1. |
| 28 | **Phase 3C depending on Phase 6C** | Plan v35 | Circular: 6C needs 12.8.15, which needs 3C, which needed 6C. Fix: U(B,A) uses char_k IH. |
| 29 | **U(B,A) with char_k for rank-r agreement** | Plan v38 Phase 3C-UBA | DEPTH-AGREEMENT GAP: char_k gives depth ~2k_nf, witness z has k_nf-depth agreement but NOT rank-r agreement. tau (rank-r) can transfer U(char_k, sf_top) but the extracted witness only matches at depth k_nf << r. Winning condition requires rank-r. No bridging exists at current rank bounds. |

## Settled Questions

- **Infimum redefinition IS necessary** (reports 29, 35). Do not revisit.
- **Track A (OrderIso bypass) is NOT FEASIBLE**. Do not revisit.
- **Fintype enumeration BLOCKED** by infinite atoms. Do not revisit.
- **Fan ordering is provably false** (task 199 counterexample). Do NOT attempt abstract fan_order lemmas.
- **The M-side fan problem persists even with sorting** (report 41). Only U(B,A) transfer resolves it.
- **d must remain inf(S_C)** (report 41 Section 7). Fix targets e_n construction, not d.
- **Proposition 7 (composition) is required** (report 38). Now complete in Composition.lean.
- **No circular dependency EFGames/ <-> Expressiveness/** (report 42a). Unidirectional: Expressiveness -> EFGames.
- **Formula materialization IS nf_characterizable_by_stavi** (report 42b). No shortcut.
- **Single-game architecture INFEASIBLE** (report 42c). 1-round budget deficit is structural.
- **sf_top guard insufficient for backward direction** (reports 36, 37, 43). Do NOT attempt sf_top-based backward proofs.
- **Approaches 23-26 all circular or insufficient** (report 36). Do NOT re-attempt.
- **Outside-interval issue makes Approach A structurally unusable for k>=1**. Not a difficulty issue -- structural impossibility.
- **char_k (IH) suffices for U(B,A) materialization**. Game rank r <= f(k), char_k covers this. Breaks circular dependency.
- **GHR93's backward game (12.8.15) is self-contained**. Does not depend on NF characterization.
- **Correct resolution: Corollary 12.8.19**. Classical disjunction of temporal types consistent with the property.
- **No circularity from CaseAnalysis.lean importing StaviCompleteness.lean** (report 36). Import DAG is unidirectional.
- **All needed StaviFormula constructors are public** (report 36). No need to make private definitions public.
- **same_side lemma is unprovable** (28 approaches tried). U(B,A) witness construction eliminates the need entirely.
- **Sorting ALONE does not fix the problem** (report 37). Current code constructs e_n from forward game, not U(B,A). Both sorting AND U(B,A) are required.
- **Regular tau (rank-r) suffices for U(B,A) transfer** (report 37). stavi_depth(std_untl B sf_top) <= r from char_k_depth. No need for tau_r2.
- **No changes needed to SplitPointProps, obtain_split_point_props, Theorem6.lean, or CustomGame.lean** (report 37).
- **DEPTH-AGREEMENT GAP is fundamental** (report 38). GHR93's rank r+4(n+1) forward game vs Lean's rank r. char_k gives depth ~2k_nf, not r. U(B,A) witness has only k_nf-depth agreement. No bridging exists.
- **Strategy composition (Prop 12.8.18) resolves the depth gap** (report 38 Path C). Composition assembles sub-interval strategies without cross-interval ordering proofs. This IS GHR93's approach at the macro level.

## Testing & Validation

- [ ] Phase 3C-EQ: equality case (a_init(k) = p_n) handled, sel_pn_ord holds for equality branch
- [ ] Phase 3C-STRICT: strict case resolved via composition, sel_pn_ord + b_resp eliminated
- [ ] Phase 3B: Case B grid dispatch complete
- [ ] Phase 5: S11 winning condition closed
- [ ] Phase 6D: Prop 12.8.16 sorry-free
- [ ] Phase 6E: Full Prop 12.8.18 sorry-free
- [ ] Phase 6F: Cor 12.8.19 sorry-free
- [ ] Phase 6C-4: `nf_2var_existence_characterizable` sorry closed, dead code removed
- [ ] Phase 6C-5: `#print axioms nf_characterizable_by_stavi` -- no `sorryAx`
- [ ] Phase 7: `#print axioms no_gaps_discrete` -- no `sorryAx`
- [ ] Phase 8: `succ_cofinal` sorry closed
- [ ] Phase 9: `#print axioms bx_completeness` -- only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `EFGames/Composition.lean` -- ghr93_strategy_compose (Phase 6A, COMPLETED)
- `EFGames/StaviCompleteness.lean` -- NF characterization (Phases 6C-1/2/3 COMPLETED, 6C-4/5 pending)
- `EFGames/` -- new files for Props 12.8.16/18, Cor 12.8.19 (Phases 6D/6E/6F)
- `Expressiveness/CaseAnalysis.lean` -- Phases 3C-EQ, 3C-STRICT, 3B, 5
- `Expressiveness/Theorem6.lean` -- Phase 3C (char_k threading, COMPLETED)
- `IntegerModel/GoodStructures.lean` -- Phase 7
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Phase 8

## Rollback/Contingency

**Phase 3C-EQ**: Low risk, well-understood. If the modified response function creates unexpected type-checking issues, implement as a wrapper lemma that case-splits before calling ghr93_case_II.

**Phase 3C-STRICT (composition approach)**: If full m-tuple composition (Phase 6E) proves too complex to apply directly to Case II:
- Fallback 1: Use a 2-pivot composition (split at c and p_n) rather than full m-tuple. This may be simpler and still sufficient for Case II.
- Fallback 2: Revisit Path B (increase game ranks). Although large (~1000+ lines), this is the most literally faithful to GHR93 and would resolve the depth gap definitively.
- Fallback 3: Investigate whether k_nf-depth agreement plus interval containment can be leveraged via a restricted form of expressive completeness at depth k_nf.

**Phases 6D/6E/6F**: If full GHR93 chain too complex, consider axiomatizing Cor 12.8.19 with clear documentation. All sorry closures in other phases remain valuable regardless.

**Phase 8**: If succ_cofinal blocked, recommend Task 129 (Henkin canonical model) as alternative path.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
