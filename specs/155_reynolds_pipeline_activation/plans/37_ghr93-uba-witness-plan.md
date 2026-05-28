# Implementation Plan: Reynolds Pipeline Activation (v37 — GHR93 U(B,A) Witness Resolution)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] — Phases 1-4, 3A, 6A, 6C-1/2/3 complete. Phase 3C restructured: same_side approach abandoned, replaced by char_k threading + U(B,A) witness construction per GHR93 exactly.
- **Effort**: 18-36 hours remaining
- **Dependencies**: Tasks 154, 147-148, 157, 195, 168, 174, 198, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: 44 reports in `specs/155_reynolds_pipeline_activation/reports/`, including `36_char-k-threading-research.md` (new)
- **Artifacts**: plans/37_ghr93-uba-witness-plan.md (this file), plans/36_ghr93-classical-plan.md (superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline (Chapter 12.8). The approach follows GHR93 exactly: backward game theorem -> game composition -> temporal-FO equivalence -> classical characterization of NF existence -> gap elimination -> succ_cofinal.

**v37 correction**: Plan v36's Phase 3C was blocked by the fan problem — the `same_side` lemma (relating a'_big(k) and a_init(k) ordering w.r.t. p_n) is unprovable from available hypotheses (28 failed approaches documented). The resolution follows GHR93 pp. 115-116 exactly: replace the separate forward-game e_n construction with U(B,A) witness extraction. This requires threading `char_k` (from the outer NF-depth induction) as parameters through 5 functions in the backward game call chain, then using the threaded `char_k` to materialize the GHR93 formula B = X_{a_n} and construct U(B,A) = std_untl B sf_top. The U(B,A) truth transfers via tau_r2 at rank r+2, and the M-side witness becomes e_n. The ordering resp_tau(k) < e_n holds BY CONSTRUCTION, eliminating the fan problem entirely.

### Research Integration

- `reports/36_char-k-threading-research.md`: Confirms no circularity in CaseAnalysis.lean -> StaviCompleteness.lean import chain. Identifies 5-function threading path for char_k parameters. Verifies all needed StaviFormula constructors are public. Estimates 350-490 lines of changes. Highest risk: stavi_temporal_truth vs stavi_temporal_truth_mu bridge.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

## Sorry-Free EFGames Infrastructure

| File | Lines | Key Content | GHR93 Reference |
|------|-------|-------------|-----------------|
| Defs.lean | 559 | EF games, extended carriers M_r, `stavi_n_equiv`, `game_depth` | Defs 12.8.8, 12.8.11, 12.8.17 |
| CustomGame.lean | 1690 | G_{n,r} game, `ghr93_duplicator_wins`, `ghr93_winning_condition_perm` | Def 12.8.11 |
| Composition.lean | 626 | `ghr93_strategy_compose` — single-pivot sub-interval composition | Prop 12.8.7 / part of 12.8.18 |
| Decomposition.lean | 315 | `ghr93_game_iff_decomposition` — game <-> decomposition | Lemma 12.8.14 |
| TypeFormulas.lean | 1043 | `rank_type`, `interval_types`, mu-relativized truth, rank embedding | Def 12.8.13 |
| GapDetection.lean | 5057 | Gap detection for Cases III/IV, left/right formula construction | Cases III/IV infrastructure |

## Current Sorry Sites

| File | Line | Definition | Status |
|------|------|-----------|--------|
| StaviCompleteness.lean | 1873 | `nf_2var_from_interval_data` | DEAD CODE — to be removed (Phase 6C-4) |
| StaviCompleteness.lean | 2152 | `nf_exist_sf_guarded_backward` | DEAD CODE — to be removed (Phase 6C-4) |

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
| **Theorem 12.8.15 (backward game)** | **PARTIAL** | CaseAnalysis.lean — sel_pn_ord + winning condition sorries |
| **Prop 12.8.9 (standard EF <-> FO)** | **NOT STARTED** | — |
| **Prop 12.8.16 (temporal rank -> game)** | **NOT STARTED** | — |
| **Prop 12.8.18 (full m-tuple composition)** | **NOT STARTED** | Single-pivot only |
| **Cor 12.8.19 (temporal -> FO equivalence)** | **NOT STARTED** | — |

## Goals & Non-Goals

**Goals**:
- Close all critical-path sorry sites following GHR93 exactly
- Prove the GHR93 classical chain: Theorem 12.8.15 -> Props 12.8.16/18 -> Cor 12.8.19
- Derive `nf_2var_existence_characterizable` classically from Cor 12.8.19
- Prove `succ_cofinal` via gap elimination
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- TruthLemma.lean sorry sites (non-critical-path)
- OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- OrderIso bypass (Track A) — proven infeasible
- Changing d from inf(S_C) to min(selections) — would break Claim 1 infrastructure
- Single-game restructuring of Case II — infeasible (1-round budget deficit)

## Dependency Analysis

| Wave | Phases | Blocked by | Notes |
|------|--------|------------|-------|
| 1 | 1, 2, 3A, 4, 6A, 6C-1/2/3 | — | ALL COMPLETED |
| 2 | 3C | — | Uses char_k IH, no Phase 6C dependency |
| 3 | 3B, 5 | 3C | sel_pn_ord + b_resp from 3C |
| 4 | 6D | — | Independent of backward game completion |
| 5 | 6E | 6D | |
| 6 | 6F | 6E | |
| 7 | 6C-4 | 6F | Classical characterization via Cor 12.8.19 |
| 8 | 6C-5 | 6C-4 | Verification |
| 9 | 7 | 6C-5 | no_gaps_discrete |
| 10 | 8 | 7 | succ_cofinal |
| 11 | 9 | 8 | Final verification |

**Parallel tracks**: Waves 2-3 (backward game) and Waves 4-6 (GHR93 chain) are independent.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| stavi_temporal_truth vs stavi_temporal_truth_mu bridge missing | GHR93 Def 8.4 fact 1 states equivalence at mu-points. Prove if not already formalized (~40-80 lines). |
| Rank r vs depth k mismatch at char_k threading boundary | The completeness proof controls this relationship. Verify r = game_depth(k) at the call site in stavi_completeness_inductive_step. |
| Projecting rank-(r+2) witnesses back to rank r | rank_embed infrastructure in TypeFormulas.lean already handles rank projection. Verify rank_embed_point and related lemmas. |
| Breaking existing sorry-free code in Cases III/IV | Cases III/IV do not use char_k. The new parameters are simply threaded through ghr93_cases_II_III_IV and only consumed in the Case II branch. |
| U(B,A) rank r+2 exceeds tau's depth-r preservation | Use tau at rank r+2 via the h_ih_r2 parameter already added (infrastructure from Cycle 2). |
| Full Prop 12.8.18 (m-tuple) significantly larger than single-pivot | Iterate single-pivot composition; Composition.lean already handles the hard case. |
| Classical characterization in 6C-4 requires connecting Cor 12.8.19 to NF types | NormalForm is Fintype; classical enumeration is well-defined. |

## Implementation Phases

---

### Phase 1: Mechanical Sorry Closure S3 + S5 [COMPLETED]

Closed S3 (`h_cont_transfer_mr`) and S5 (`h_mr_resp_ge_d` gap case) via `game_tuple` simplification and gap proof mirroring. ~345 lines added to ExpressivenessGeneral.lean (now split into Expressiveness/ submodules).

---

### Phase 2: Pigeonhole + K-(negD) Bridge [COMPLETED]

Closed S1/S2 (Claim 1 cluster) using K-(negD) bridge, complement_no_min witnesses. Also closed S4 (multi-round K-(negD)) and S7-right. Key finding: K-(negD) bridge is necessary scaffolding.

---

### Phase 3A: sel_pn_ord Sorry'd Field [COMPLETED]

Added sorry'd `have sel_pn_ord` and `pn_sel_ord` at both Case A and Case B sites in CaseAnalysis.lean. The sorry is at the usage sites — concentrated, ready for Phase 3C closure.

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]

Added `ghr93_rank_down_proj` (233 lines) for position-tracking variant of rank_down. S6 closed directly. S7-right expanded with K-(negD) closure.

---

### Phase 6A: GHR93 Proposition 7 — Strategy Composition [COMPLETED]

`ghr93_strategy_compose` in new Composition.lean (626 lines, sorry-free). Combines Duplicator winning strategies on sub-intervals [x,c] and [c,y] into full interval [x,y]. Includes degenerate sub-interval compatibility hypotheses.

---

### Phase 6B: EFGames-Internal Case Analysis [SUPERSEDED]

Superseded by Phase 6C formula construction approach.

---

### Phase 6C-1: k=0 Base Case [COMPLETED]

Proved `nf_2var_existence_characterizable` for k=0 (~160 lines). At depth 0, atoms+order determine the 2-var NF. Backward direction uses case analysis on AtomKind sig 2, extracting pred/order info from the Until/Since formula.

---

### Phase 6C-2: Interval Guard Formula [COMPLETED]

Defined `interval_guard_sf` (disjunction of all `char_k` formulas — always satisfiable) and `nf_exist_sf_guarded` (replaces `sf_top` with `interval_guard_sf` in Until/Since guard). Also proved `interval_guard_sf_true`.

---

### Phase 6C-3: Forward Direction [COMPLETED]

Proved `nf_exist_sf_guarded_forward` sorry-free. Guard obligation at intermediate points discharged via `nf_characteristic_satisfies` + `char_k_correct` (IH).

---

### Phase 3C: char_k Threading + U(B,A) Witness Construction [IN PROGRESS]

**Goal**: Thread `char_k` from the outer NF-depth induction into the backward game call chain, then use it to construct the GHR93 U(B,A) witness for e_n, eliminating the fan problem and closing sel_pn_ord and b_resp sorries.

**GHR93 construction (pp. 115-116)**: B = X_{a_n} (rank-r type of a_n, materialized as conjunction of matching char_k formulas). phi = std_untl B sf_top (depth r+2). phi holds at a_{n-1} in N (witnessed by a_n). tau_r2 transfers phi to M at resp_tau(n-1). Extract M-side witness as e_n. Result: resp_tau(k) < e_n BY CONSTRUCTION.

**Infrastructure completed** (prior cycles):
- h_ih_r2 parameter added, providing forward-to-backward conversion at rank r+2. Constructed by reverting `r` before induction in `ghr93_forward_to_backward_core`, making `ih_gen` rank-polymorphic.
- Build passes. No regressions.

**Sub-tasks (ordered)**:

- [x] **3C.1: Thread char_k through the call chain** (~50-80 lines) *(deviation: altered — used rank-polymorphic char_k : ∀ (r' : Nat), NormalForm sig r' 1 → StaviFormula instead of fixed-rank, to survive r-revert in ghr93_forward_to_backward_core)*
  - Add `(char_k : NormalForm sig r 1 -> StaviFormula)` and `(char_k_correct : ...)` parameters to:
    - `ghr93_forward_to_backward` (Theorem6.lean:173) — entry point
    - `ghr93_forward_to_backward_core` (Theorem6.lean:31) — threads to inductive step
    - `ghr93_inductive_step` (CaseAnalysis.lean:4321) — threads to cases
    - `ghr93_cases_II_III_IV` (CaseAnalysis.lean:4269) — threads to Case II
    - `ghr93_case_II` (CaseAnalysis.lean:1188) — consumes char_k for U(B,A)
  - Update all callers of `ghr93_forward_to_backward` to supply char_k and char_k_correct from `nf_characterizable_by_stavi`'s IH
  - `lake build` must pass (existing sorries remain, no new ones)

- [x] **3C.2: Verify stavi_temporal_truth bridge** (~0-80 lines) *(completed — stavi_truth_mu_at_point already exists in GapDetection.lean:417, no new code needed)*
  - Check whether `stavi_temporal_truth <-> stavi_temporal_truth_mu` at mu-points is already formalized
  - `char_k_correct` from `nf_characterizable_by_stavi` likely uses `stavi_temporal_truth` (non-mu)
  - The game's formula_agreement uses `stavi_temporal_truth_mu` (mu-relativized)
  - If no bridge exists, prove it: GHR93 Def 8.4 fact 1 states "If t is in M, then M |= A(t) iff M_r |= A^mu(t)"
  - This is the highest-risk sub-task per the research report

- [ ] **3C.3: Materialize B = X_{a_n} as StaviFormula** (~40-80 lines)
  - Given p_n (the point from h_point), determine nf_pn via `nf_exists_unique` on the extended carrier
  - Construct B := char_k nf_pn (using the threaded char_k parameter)
  - Prove: stavi_temporal_truth_mu N atomMap r (extendPoint p_n) B (from char_k_correct + nf_eval at p_n)
  - Prove: stavi_depth B <= r (from char_k properties)

- [ ] **3C.4: Construct phi = std_untl B sf_top and prove truth in N** (~60-100 lines)
  - Reconstruct sf_top locally: `let sf_top' : StaviFormula := .base Formula.top`
  - Define phi := StaviFormula.std_untl B sf_top'
  - Prove stavi_depth phi <= r + 2 (from stavi_depth B <= r)
  - Prove phi holds at rank_embed(a_init(n-1)) in N at rank r+2:
    - a_init(n-1) < extendPoint p_n (from sorted ordering of a_bwd)
    - p_n is a mu-point (IsPoint)
    - N |= B^mu at p_n at rank r (from 3C.3)
    - rank_embed preserves truth for depth <= r
    - sf_top' guard trivially satisfied at all intermediate points
    - Lift to rank r+2 via rank_embed

- [ ] **3C.5: Transfer phi via tau_r2 and extract e_n** (~60-100 lines)
  - Use h_ih_r2 (rank-(r+2) forward-to-backward conversion) to obtain tau_r2 on [d,y']/[c,y]
  - Instantiate tau_r2 with N-selections including rank_embed(a_init(n-1))
  - Get M-responses including resp_r2(n-1) in M_{r+2}
  - Formula agreement at rank r+2: phi holds at rank_embed(a_init(n-1)) in N => phi holds at resp_r2(n-1) in M
  - Since stavi_depth phi <= r+2, the transfer is valid
  - M |= std_untl B sf_top' at resp_r2(n-1) means: exists s > resp_r2(n-1) with mu_holds s and M |= B at s
  - Extract s as the witness; project to rank r if needed
  - Define e_n := projected witness
  - Prove resp_tau(k) < e_n for k <= n-1 from tau ordering + e_n > resp_tau(n-1)

- [ ] **3C.6: Close sel_pn_ord and pn_sel_ord sorry sites** (~20-40 lines)
  - With the new e_n construction, sel_pn_ord becomes:
    - a_init(k) < extendPoint p_n iff resp_tau(k) < e_n
  - This follows from tau ordering preservation (tau_r2 preserves orderings at rank r+2) and the projected orderings matching at rank r
  - Close sorry at Case A site (~line 1585)
  - Close sorry at Case B site (~line 1965)

- [ ] **3C.7: Close b_resp vs p_n sorry sites** (~40-80 lines)
  - Close b_resp sorry at Case B (~line 2180)
  - Close b_resp sorry at Case B (~line 2233)
  - These depend on e_n properties established in 3C.5

- [ ] **3C.8: Build verification** — `lake build` passes with strictly fewer sorries

**Timing**: 4-8 hours

**Depends on**: 3A (COMPLETED)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`, `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Theorem6.lean`

---

### Phase 3B: Structured Proof Tactic Overhaul [IN PROGRESS — 2 goals deferred to 3C]

**Goal**: Close remaining Case B grid dispatch goals using ordering proofs from Phase 3C.

**Status**:
- [x] Case A (S8): Sorry-free, all ~25 grid goals close
- [x] Case B impossible-direction goals (3 of 6): Closed by task 199
- [x] Case B Goal 3 sel(i) vs p_n (both variants): Closed via rename_i + hab_eq + sel_pn_ord
- [ ] Case B Goals 1-2: b_resp vs p_n (deferred to Phase 3C — same fan problem root cause)
- [ ] Remove dead code after Phase 3C resolves remaining goals

**Timing**: 1-2 hours after Phase 3C

**Depends on**: 3C

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 5: Cases III/IV Winning Condition Assembly [PARTIAL]

**Goal**: Close S11 winning condition assembly in Cases III/IV.

**Status**:
- [x] S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`): Closed via parameter approach
- [x] Gap detection infrastructure: Complete (left/right formula, gap_detection_unique)
- [x] Interval bounds (lines ~3328, ~3639): Closed (degenerate boundary + non-degenerate contradiction)
- [ ] Winning condition assembly (line ~4100): ~200 lines, needs sel_pn_ord from Phase 3C

**Timing**: 2-4 hours after Phase 3C

**Depends on**: 3C (sel_pn_ord for grid dispatch)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 6D: Proposition 12.8.16 — Temporal Type -> Game Strategy [NOT STARTED]

**Goal**: If x in M and y in N satisfy the same temporal formulas of rank r+4n+1, then Duplicator has winning strategies for G_{n,r}(M, -inf x; N, -inf y) and G_{n,r}(M, x inf; N, y inf).

**Tasks**:
- [ ] State proposition using `stavi_n_equiv`, `rank_type`, `ghr93_duplicator_wins`
- [ ] Prove base case n=0 (trivial)
- [ ] Prove inductive step: construct response using formula C_0 from GHR93 proof sketch
- [ ] Handle gap case (r-definable gaps as endpoints)
- [ ] Run `lake build`

**Timing**: 2-4 hours

**Depends on**: none (uses only sorry-free EFGames infrastructure)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend StaviCompleteness.lean)

---

### Phase 6E: Full Proposition 12.8.18 — m-Tuple Game Composition [NOT STARTED]

**Goal**: Extend single-pivot `ghr93_strategy_compose` to full m-tuple composition: given winning strategies on all sub-intervals, compose into a winning strategy for G^{n+1}((M, x_bar), (N, y_bar)).

**Tasks**:
- [ ] State full m-tuple composition using EF game types
- [ ] Define partition of Spoiler's choice into sub-intervals
- [ ] Apply single-pivot composition iteratively (induction on m)
- [ ] Prove cross-sub-interval order preservation
- [ ] Connect to `ef_duplicator_wins`
- [ ] Run `lake build`

**Timing**: 3-6 hours

**Depends on**: 6D

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean`

---

### Phase 6F: Corollary 12.8.19 — Temporal -> FO Equivalence [NOT STARTED]

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
- [ ] `#print axioms nf_characterizable_by_stavi` — no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` — no `sorryAx`
- [ ] Verify zero sorry warnings in EFGames/
- [ ] `lake build` passes

**Timing**: 0.5 hours

**Depends on**: 6C-4

---

### Phase 7: Reynolds Theorem 5 — no_gaps_discrete [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in GoodStructures.lean:842). The integer model has no gaps because every NF is characterizable by a StaviFormula (Phase 6C), and StaviFormulas are determined by their truth at integer points.

**Tasks**:
- [ ] Read current state of `no_gaps_discrete`
- [ ] Implement gap elimination argument
- [ ] `#print axioms no_gaps_discrete` — no `sorryAx`
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
- [ ] `#print axioms dd_countermodel_chronicle_discrete` — no `sorryAx`
- [ ] `lake build` passes

**Timing**: 2-4 hours

**Depends on**: 7

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

---

### Phase 9: Final Verification [NOT STARTED]

**Tasks**:
- [ ] `#print axioms bx_completeness` — only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Verify `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)
- [ ] `lake build` — zero errors

**Timing**: 0.5 hours

**Depends on**: 8

---

## Superseded Approaches

The following 28 approaches have been tried and ruled out. Do NOT re-attempt.

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
| 13 | **Restructure big game N-side** | Approach C | Forward game has M selecting — cannot force N-side = a_init. |
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
- **U(B,A) has depth r+2, tau preserves <= r** (report 42b). Use h_ih_r2 for rank r+2 backward game.
- **sf_top guard insufficient for backward direction** (reports 36, 37, 43). Do NOT attempt sf_top-based backward proofs.
- **Approaches 23-26 all circular or insufficient** (report 36). Do NOT re-attempt.
- **Outside-interval issue makes Approach A structurally unusable for k>=1**. Not a difficulty issue — structural impossibility.
- **char_k (IH) suffices for U(B,A) materialization**. Game rank r <= f(k), char_k covers this. Breaks circular dependency.
- **GHR93's backward game (12.8.15) is self-contained**. Does not depend on NF characterization.
- **Correct resolution: Corollary 12.8.19**. Classical disjunction of temporal types consistent with the property.
- **No circularity from CaseAnalysis.lean importing StaviCompleteness.lean** (report 36). Import DAG is unidirectional.
- **All needed StaviFormula constructors are public** (report 36). No need to make private definitions public.
- **same_side lemma is unprovable** (28 approaches tried). U(B,A) witness construction eliminates the need entirely.

## Testing & Validation

- [ ] Phase 3C: char_k threaded through 5 functions, sel_pn_ord + b_resp sorries closed
- [ ] Phase 3B: Case B grid dispatch complete
- [ ] Phase 5: S11 winning condition closed
- [ ] Phase 6D: Prop 12.8.16 sorry-free
- [ ] Phase 6E: Full Prop 12.8.18 sorry-free
- [ ] Phase 6F: Cor 12.8.19 sorry-free
- [ ] Phase 6C-4: `nf_2var_existence_characterizable` sorry closed, dead code removed
- [ ] Phase 6C-5: `#print axioms nf_characterizable_by_stavi` — no `sorryAx`
- [ ] Phase 7: `#print axioms no_gaps_discrete` — no `sorryAx`
- [ ] Phase 8: `succ_cofinal` sorry closed
- [ ] Phase 9: `#print axioms bx_completeness` — only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `EFGames/Composition.lean` — ghr93_strategy_compose (Phase 6A, COMPLETED)
- `EFGames/StaviCompleteness.lean` — NF characterization (Phases 6C-1/2/3 COMPLETED, 6C-4/5 pending)
- `EFGames/` — new files for Props 12.8.16/18, Cor 12.8.19 (Phases 6D/6E/6F)
- `Expressiveness/CaseAnalysis.lean` — Phases 3B, 3C, 5
- `Expressiveness/Theorem6.lean` — Phase 3C (char_k threading)
- `IntegerModel/GoodStructures.lean` — Phase 7
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` — Phase 8

## Rollback/Contingency

**Phase 3C**: If the stavi_temporal_truth vs stavi_temporal_truth_mu bridge proves intractable, investigate whether char_k_correct can be stated directly in mu-relativized form at the `nf_characterizable_by_stavi` call site. If entirely blocked, maintain sorry'd sel_pn_ord from Phase 3A while pursuing the GHR93 chain (Phases 6D-6F) in parallel.

**Phases 6D/6E/6F**: If full GHR93 chain too complex, consider axiomatizing Cor 12.8.19 with clear documentation. All S1-S12 closures remain valuable regardless.

**Phase 8**: If succ_cofinal blocked, recommend Task 129 (Henkin canonical model) as alternative path.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
