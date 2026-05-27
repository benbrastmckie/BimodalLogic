# Implementation Plan: Reynolds Pipeline Activation (v36 — GHR93 Classical Approach)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] — Phases 1-4, 3A, 6A, 6C-1/2/3 complete. Phase 6C-4 (Approach A bridge) superseded. Plan restructured to GHR93 classical approach via Corollary 12.8.19.
- **Effort**: 20-40 hours remaining
- **Dependencies**: Tasks 154, 147-148, 157, 195, 168, 174, 198, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: 43 reports in `specs/155_reynolds_pipeline_activation/reports/`
- **Artifacts**: plans/36_ghr93-classical-plan.md (this file), plans/35_reynolds-pipeline-plan.md (superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline (Chapter 12.8). The approach follows GHR93 exactly: backward game theorem → game composition → temporal-FO equivalence → classical characterization of NF existence → gap elimination → succ_cofinal.

**v36 correction**: Plan v35 had a circular dependency (Phase 3C → Phase 6C → Theorem 12.8.15 → Phase 3C). The resolution: U(B,A) transfer uses `char_k` (IH) directly at rank f(k), NOT `char_{k+1}` / `nf_characterizable_by_stavi`. This mirrors GHR93, where the backward game theorem (12.8.15) is self-contained and does not depend on NF characterization.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

## Sorry-Free EFGames Infrastructure

| File | Lines | Key Content | GHR93 Reference |
|------|-------|-------------|-----------------|
| Defs.lean | 559 | EF games, extended carriers M_r, `stavi_n_equiv`, `game_depth` | Defs 12.8.8, 12.8.11, 12.8.17 |
| CustomGame.lean | 1690 | G_{n,r} game, `ghr93_duplicator_wins`, `ghr93_winning_condition_perm` | Def 12.8.11 |
| Composition.lean | 626 | `ghr93_strategy_compose` — single-pivot sub-interval composition | Prop 12.8.7 / part of 12.8.18 |
| Decomposition.lean | 315 | `ghr93_game_iff_decomposition` — game ↔ decomposition | Lemma 12.8.14 |
| TypeFormulas.lean | 1043 | `rank_type`, `interval_types`, μ-relativized truth, rank embedding | Def 12.8.13 |
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
| Def 12.8.8 (EF games) | ✅ | Defs.lean |
| Def 12.8.11 (G_{n,r} game) | ✅ | CustomGame.lean |
| Def 12.8.13 (rank_type, interval_types) | ✅ | TypeFormulas.lean |
| Lemma 12.8.14 (game ↔ decomposition) | ✅ | Decomposition.lean |
| Def 12.8.17 (game_depth f(n)) | ✅ | Defs.lean |
| Prop 12.8.7-style (single-pivot composition) | ✅ | Composition.lean |
| **Theorem 12.8.15 (backward game)** | **PARTIAL** | CaseAnalysis.lean — sel_pn_ord + winning condition sorries |
| **Prop 12.8.9 (standard EF ↔ FO)** | **❌** | — |
| **Prop 12.8.16 (temporal rank → game)** | **❌** | — |
| **Prop 12.8.18 (full m-tuple composition)** | **❌** | Single-pivot only |
| **Cor 12.8.19 (temporal → FO equivalence)** | **❌** | — |

## Goals & Non-Goals

**Goals**:
- Close all critical-path sorry sites following GHR93 exactly
- Prove the GHR93 classical chain: Theorem 12.8.15 → Props 12.8.16/18 → Cor 12.8.19
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
| U(B,A) rank r+2 exceeds tau's depth-r preservation | Use tau at rank r+4 via h_r1_univ parameter |
| Prop 12.8.9 (standard EF) complex to formalize | May be available in Mathlib; otherwise ~200 lines from first principles |
| Full Prop 12.8.18 (m-tuple) significantly larger than single-pivot | Iterate single-pivot composition; Composition.lean already handles the hard case |
| Classical characterization in 6C-4 requires connecting Cor 12.8.19 to NF types | NormalForm is Fintype; classical enumeration is well-defined |

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

### Phase 3C: U(B,A) Transfer — Replace e_n Construction [BLOCKED]

**Goal**: Replace the d-compatible forward game e_n construction with GHR93's U(B,A) transfer, resolving sel_pn_ord and b_resp vs p_n.

**BLOCKER** (Phase 3C):
- **What failed**: sel_pn_ord requires proving `a_init(k) < p_n ↔ resp_tau(k) < e_n`. The forward game gives `resp_tau(k) < e_n ↔ a'_big(k) < p_n` (where a'_big(k) is the N-response from the d-compatible forward game). But a'_big(k) != a_init(k), and their ordering relative to p_n cannot be determined from rank-r type agreement alone.
- **What was tried**: (1) Pivot chain through d/c -- fails because d ≤ a_init(k) AND d ≤ p_n creates a fan not a chain. (2) Extract from forward game hord_big at positions involving resp_tau vs e_n -- gives ordering iff a'_big not a_init. (3) Use rank-r formula agreement between a'_big(k) and a_init(k) to show same side of p_n -- counterexample: two points with same rank-r type can be on opposite sides of p_n. (4) Get higher-rank tau from h_r1_univ -- h_r1_univ gives FORWARD games; converting to backward requires the IH which is unavailable from CaseAnalysis.lean (circular import). (5) Add h_bwd_full parameter for (n+1)-round backward game -- round budget insufficient (IH at n gives n-round backward; we need (n+1)-round which IS what we're proving).
- **Why it's stuck**: GHR93 uses tau at rank r+4 (not rank r). The higher rank preserves U(B,A) (rank r+1) so the formula transfers through tau and provides the witness. In our formalization: (a) props.tau is at rank r only (constructed from IH at rank r), (b) ghr93_forward_to_backward (which converts forward→backward at ANY rank) is in Theorem6.lean which CaseAnalysis.lean cannot import (circular: Theorem6 imports CaseAnalysis), (c) the round budget (4+3n rounds on full interval → 3+3n after restriction → supports only n-round backward via 1+3n IH) does not support (n+1)-round backward on sub-intervals.
- **What is needed**: One of: (A) Move ghr93_forward_to_backward to a separate file importable by CaseAnalysis.lean, eliminating the circular import -- then h_r1_univ + forward_to_backward at rank r+2 gives the higher-rank tau directly. (B) Add `h_ih_r2` parameter providing forward-to-backward conversion at rank r+2, constructed in Theorem6.lean's inductive_step caller. (C) Restructure the induction to be rank-polymorphic (induct on both n and the rank gap), giving access to higher-rank IH within case analysis.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Key insight**: Uses `char_k` (IH) for formula materialization. At NF depth k+1, the game operates at rank r ≤ f(k) = `game_depth(k)`. The IH provides `char_k` covering this rank. `char_{k+1}` / `nf_characterizable_by_stavi` is NOT needed.

**GHR93 construction (pp. 115-116)**: Define B = X_{a_n} (rank-r type of a_n, materialized as `sf_conjList` of matching `char_k` formulas). Define A = X_{(a_{n-1}, a_n)}. Then U(B,A) holds at a_{n-1} in N, transfers to M via tau, and witnesses e_n > resp_tau(n-1).

**Tasks**:
- [ ] Implement selection sorting via `Tuple.sort` + `ghr93_winning_condition_perm` (~60-80 lines) *(prerequisite done: `import Mathlib.Data.Fin.Tuple.Sort` added to CaseAnalysis.lean; `ghr93_winning_condition_perm` already exists in CustomGame.lean)*
- [ ] Materialize `rank_type` as StaviFormula using `char_k` IH: `sf_conjList [char_k nf | nf matching type]` (~40-80 lines)
- [ ] Construct U(B,A) where B = continuation type, A = target type (~60-100 lines)
- [ ] Handle rank adjustment: U(B,A) has depth r+2, tau preserves depth ≤ r. Reconstruct tau at rank r+4 via h_r1_univ if needed (~40-60 lines) *(prerequisite done: `h_r1_univ` parameter added to `ghr93_case_II` and call site updated in `ghr93_cases_II_III_IV`)*
- [ ] Prove U(B,A) holds at a_init(n-1) in N (~40-60 lines)
- [ ] Transfer U(B,A) truth from N to M via tau formula agreement (~40-60 lines)
- [ ] Extract e_n as U(B,A) witness, prove e_n > resp_tau(n-1) (~40-60 lines)
- [ ] Close sel_pn_ord sorry at Case A and Case B (~20-40 lines)
- [ ] Close b_resp vs p_n sorry at Case B (~20-40 lines)
- [x] Run `lake build` *(build passes with all existing sorries intact; 1668 jobs, no errors)*

**Timing**: 4-8 hours

**Depends on**: 3A (COMPLETED)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

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

### Phase 6D: Proposition 12.8.16 — Temporal Type → Game Strategy [NOT STARTED]

**Goal**: If x ∈ M and y ∈ N satisfy the same temporal formulas of rank r+4n+1, then Duplicator has winning strategies for G_{n,r}(M, -∞ x; N, -∞ y) and G_{n,r}(M, x ∞; N, y ∞).

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

**Goal**: Extend single-pivot `ghr93_strategy_compose` to full m-tuple composition: given winning strategies on all sub-intervals, compose into a winning strategy for G^{n+1}((M, x̄), (N, ȳ)).

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

### Phase 6F: Corollary 12.8.19 — Temporal → FO Equivalence [NOT STARTED]

**Goal**: If x ∈ M and y ∈ N satisfy the same temporal formulas of rank g(n+1)+1, then for all monadic FO formulas φ of QD ≤ n, M ⊨ φ(x) iff N ⊨ φ(y).

**Tasks**:
- [ ] Prove or import Prop 12.8.9 (standard EF ↔ FO agreement)
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
P(t) = "∃x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" is a monadic FO property of QD ≤ k+1. By Cor 12.8.19 (Phase 6F), P is determined by the temporal type at rank g(k+2)+1. The characterizing StaviFormula is the disjunction of NF types consistent with P.

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
| 10 | **Extract sel_pn_ord from hord_big directly** | Approach A | a'_big(k) ≠ a_init(k); same-side-of-d ≠ same-side-of-p_n. |
| 11 | **sel_pn_ord as SplitPointProps field** | Approach B | p_n only defined inside ghr93_case_II, not at construction time. |
| 12 | **Play tau with e_n, pivot through b_tau_en** | Approach D | Fan problem: d ≤ a_init(k) and d ≤ b_tau_en gives no chain. |
| 13 | **Restructure big game N-side** | Approach C | Forward game has M selecting — cannot force N-side = a_init. |
| 14 | **same_order_type_grid with convert/congr** | Phase 3 (5 variants) | Anonymous hypotheses from split_ifs prevent targeted Fin rewrites. |
| 15 | **Unified forward game (Approach E)** | Phase 3A + report 34 | Game play produces new N-side responses ≠ a_init. Counterexample blocks all 6 sub-approaches. |
| 16 | **Two-phase tau construction** | report 34 | Produces b_fwd ≠ e_n and a'_fwd(k) ≠ a_init(k). |
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
| 27 | **Interval guard bridge lemma** | Phase 6C-4 (4 cycles) | `nf_2var_from_interval_data` needs outside-interval hypotheses (`h_above_max`, `h_below_min`) that CANNOT be extracted from Until/Since. Structurally unusable for k≥1. |
| 28 | **Phase 3C depending on Phase 6C** | Plan v35 | Circular: 6C needs 12.8.15, which needs 3C, which needed 6C. Fix: U(B,A) uses char_k IH. |

## Settled Questions

- **Infimum redefinition IS necessary** (reports 29, 35). Do not revisit.
- **Track A (OrderIso bypass) is NOT FEASIBLE**. Do not revisit.
- **Fintype enumeration BLOCKED** by infinite atoms. Do not revisit.
- **Fan ordering is provably false** (task 199 counterexample). Do NOT attempt abstract fan_order lemmas.
- **The M-side fan problem persists even with sorting** (report 41). Only U(B,A) transfer resolves it.
- **d must remain inf(S_C)** (report 41 Section 7). Fix targets e_n construction, not d.
- **Proposition 7 (composition) is required** (report 38). Now complete in Composition.lean.
- **No circular dependency EFGames/ ↔ Expressiveness/** (report 42a). Unidirectional: Expressiveness → EFGames.
- **Formula materialization IS nf_characterizable_by_stavi** (report 42b). No shortcut.
- **Single-game architecture INFEASIBLE** (report 42c). 1-round budget deficit is structural.
- **U(B,A) has depth r+2, tau preserves ≤ r** (report 42b). Use h_r1_univ for rank r+4 tau.
- **sf_top guard insufficient for backward direction** (reports 36, 37, 43). Do NOT attempt sf_top-based backward proofs.
- **Approaches 23-26 all circular or insufficient** (report 36). Do NOT re-attempt.
- **Outside-interval issue makes Approach A structurally unusable for k≥1**. Not a difficulty issue — structural impossibility.
- **char_k (IH) suffices for U(B,A) materialization**. Game rank r ≤ f(k), char_k covers this. Breaks circular dependency.
- **GHR93's backward game (12.8.15) is self-contained**. Does not depend on NF characterization.
- **Correct resolution: Corollary 12.8.19**. Classical disjunction of temporal types consistent with the property.

## Testing & Validation

- [ ] Phase 3C: sel_pn_ord + b_resp sorries closed in CaseAnalysis.lean
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
- `IntegerModel/GoodStructures.lean` — Phase 7
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` — Phase 8

## Rollback/Contingency

**Phase 3C**: If U(B,A) rank adjustment (r+2 vs r) proves difficult, investigate weaker formula at rank r. If entirely blocked, maintain sorry'd sel_pn_ord from Phase 3A.

**Phases 6D/6E/6F**: If full GHR93 chain too complex, consider axiomatizing Cor 12.8.19 with clear documentation. All S1-S12 closures remain valuable regardless.

**Phase 8**: If succ_cofinal blocked, recommend Task 129 (Henkin canonical model) as alternative path.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
