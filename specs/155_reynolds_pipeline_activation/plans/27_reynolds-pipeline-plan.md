# Implementation Plan: Reynolds Pipeline Activation (v25)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 25-45 hours remaining
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/22 (GHR93 Claim 1), reports/36 (root cause), reports/38 (case-split), reports/39 (circularity confirmed)
- **Artifacts**: plans/27_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: FOLLOW GHR93 EXACTLY — NO DEVIATIONS

Every deviation from GHR93 has produced weeks of wasted effort. If an implementation creates edge cases absent from GHR93, the approach is wrong. Encode formulas as formulas. No predicate workarounds. Every proof step must trace to a specific page/line in GHR93 or Reynolds.

---

## Overview

Formalize GHR93 Section 8 + Reynolds gap elimination (Theorem 14) to achieve sorry-free `bx_completeness`.

**Critical path**: Phase 1 → 3 → 4 → 5 → 6A → 6B → 8 → 11

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations.

## Goals & Non-Goals

**Goals**: Sorry-free `bx_completeness` via full GHR93 + Reynolds pipeline.
**Non-Goals**: Dense completeness, closing `succ_cofinal` directly, general tactic development.

## Current Sorry Inventory (14 total in ExpressivenessGeneral.lean)

| Line | Category | Description | Action |
|------|----------|-------------|--------|
| 2013 | Phase 3 | N-side Case 3 gap infimum | Phase 3: wire infimum_gap_r_definable |
| 2104 | Phase 3 | M-side Case 3 gap infimum | Phase 3: mirror N-side |
| 2307 | **Orphaned** | h_d_unique sorry 1 | **DELETE**: remove h_d_unique entirely |
| 2331 | **Orphaned** | h_d_unique sorry 2 | **DELETE**: remove h_d_unique entirely |
| 2426 | Phase 3 | h_pt_xc degenerate gap | Phase 3: prove unreachable or restructure |
| 2443 | Phase 3 | h_pt_cy degenerate gap | Phase 3: prove unreachable or restructure |
| 2949 | Phase 3 | Claim 1 Case A, d is gap | Phase 3: d-gap case deferred |
| 3026 | Edge | Claim 1 Case B, q_r2 = y' boundary | Close: K⁻ argument or show unreachable |
| 3030 | Phase 3 | Claim 1 Case B, r2_resp is gap | Phase 3: gap handling |
| 4692 | Phase 1 | sigma same_order_type | Close: task 195 tactics |
| 4792 | Phase 1 | tau same_order_type | Close: task 195 tactics |
| 4845 | Phase 1 | tau same_order_type (second) | Close: task 195 tactics |
| 5775 | Phase 4 | ghr93_cases_III_IV | Phase 4: Cases III/IV |
| 6030 | Phase 4 | rank-varying theorem | Phase 4: rank-varying Thm 6 |

Plus 2 sorries in EFGames.lean (Phase 4) and 3 in IntegerModel.lean (Phases 7-8).

## Implementation Phases

### Phase 1: Cleanup + Same Order Type [BLOCKED]

**Status**: GHR93 Claim 1 carrier-point cases COMPLETE. Remaining work is cleanup and Task 1.6.

**BLOCKER** (Phase 1):
- **What failed**: Tasks 1A, 1C, 1D, 1E all depend on GHR93 Claim 1 (h_d_unique) which has 2 sorries (lines 2307, 2331). h_d_unique is NOT orphaned — it is actively used by d_consistency_left (line 1602) and d_consistency_right (line 1724). The plan's claim that "d_consistency now uses inline Claim 1" is incorrect.
- **What was tried**: (1) Verified h_d_unique is still passed to d_consistency_left/right at lines 2332-2337. (2) For 1D (sigma same_order_type, line 4692): inspected the 6 remaining goals after same_order_type_grid — all require `(d < extendPoint p_n ↔ c < e_n)` which requires either h_d_unique or a proof that the forward game's a_N(n) = d (i.e., Claim 1). No block-commented proof exists for sigma. (3) For 1C (boundary edge, line 3026): the case extendPoint q_r2 = y' implies r2_resp = rank_embed(y'), but c_inf = y is consistent with ¬cont_holds_cross at c_inf; the case is NOT unreachable from game bounds. (4) For 1E: also blocked on sigma instantiation for (x' < d ↔ x < c).
- **Why it's stuck**: All tasks share the root dependency on h_d_unique/Claim 1. The inline Claim 1 (lines 2530-2950) proves r2_resp = rank_embed(d) but does NOT prove h_d_unique (t' = d for arbitrary t' with same rank-r type). The 2 sorries in h_d_unique (lines 2307, 2331) require materializing the continuation predicate as a single StaviFormula via pigeonhole + constructing K⁻(¬D) of depth r+2.
- **What is needed**: Complete h_d_unique by proving its 2 sorries. This requires: (a) materializing the cofinal formula failure below d as a single StaviFormula D via pigeonhole, (b) constructing K⁻(¬D) = neg(std_snce(neg(base .bot), D)) of depth r+2, (c) proving K⁻(¬D) separates d from t'. This is the same infrastructure needed for Phase 3 gap cases.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Tasks**:
- [ ] **1A. Delete h_d_unique** (~-150 lines). h_d_unique (lines ~2236-2331) is orphaned — its 2 sorries are unreachable since d_consistency now uses inline Claim 1. Remove h_d_unique, remove it from d_consistency_left/right signatures, remove it from SplitPointProps. This deletes sorries at lines 2307 and 2331. *(deviation: skipped — h_d_unique is NOT orphaned; still used by d_consistency_left/right at lines 1602, 1724, 2332-2337)*
- [x] **1B. Archive or delete pigeonhole_definable_formula_cross_strict** (~161 lines at line ~1212). The strict pigeonhole variant was built for the abandoned K⁻ pipeline. If useful for Phase 3 gap cases, keep. Otherwise delete. The non-strict `pigeonhole_definable_formula_cross` (~180 lines at ~1040) stays — used in Case A of Claim 1. *(deviation: altered — decision is KEEP; it is used at line 2792 in Case B carrier-point sub-case)*
- [ ] **1C. Close boundary edge case** (line 3026, ~20 lines). Claim 1 Case B when q_r2 = y'. Either prove via K⁻ argument or show this case is unreachable from the game's order constraints (r2_resp < rank_embed(y') from game bounds). *(deviation: skipped — case is NOT unreachable from bounds; requires K⁻ argument which depends on Claim 1 infrastructure)*
- [ ] **1D. sigma same_order_type** (line 4692, ~40 lines). Uncomment block-commented proof. Use `same_order_type_grid`, `order_refl`, `extract_order`, `pivot_chain_order'` from task 195. *(deviation: skipped — no block-commented proof exists for sigma case; 6 remaining goals after same_order_type_grid all require (d < p_n ↔ c < e_n) from Claim 1)*
- [ ] **1E. tau same_order_type** (lines 4792, 4845, ~60 lines). Uncomment block-commented proof. Instantiate `props.sigma` with trivial selections to extract `(x' < d ↔ x < c)`. Use task 195 tactics. *(deviation: skipped — blocked on sigma instantiation for (x' < d ↔ x < c); dead code at lines 4850-4948 uses pivot_chain_order which also needs this fact)*
- [ ] **1F. Verification**: `lake build` passes.

**Timing**: 3-5 hours. **Files**: `ExpressivenessGeneral.lean`

---

### Phase 2: Lemma 9 Gap Detection [COMPLETED]

---

### Phase 3: Gap Infimum Wiring + Cases III/IV (GHR93 Theorem 6) [NOT STARTED]

**GHR93 reference**: Section 8, pp.117-119.

**Sorries to close**: 2013, 2104, 2426, 2443, 2949, 3030 (6 sorries, all gap-related).

**Tasks**:
- [ ] **3A. N-side gap infimum** (line 2013). Wire infimum_gap_r_definable for Case 3 of d construction.
- [ ] **3B. M-side gap infimum** (line 2104). Mirror N-side.
- [ ] **3C. Degenerate gap cases** (lines 2426, 2443). Prove h_pt_xc/h_pt_cy unreachable at gaps, or restructure to conditional form.
- [ ] **3D. Claim 1 gap sub-cases** (lines 2949, 3030). Extend Claim 1 to gap d / gap r2_resp using Lemma 9 gap detection.
- [ ] **3E. Cases III/IV** (line 5775). Split into Case III (left-defined gap) and Case IV (right-defined gap). Use Lemma 9.

**Timing**: 6-10 hours. **Depends on**: Phase 1.

---

### Phase 4: Assembly — Rank-Varying Thm 6, Props 6-7, Corollary 5 [NOT STARTED]

**GHR93 reference**: pp.113-115.

**Sorries to close**: 6030 (rank-varying), EFGames.lean sorries (Lemma 11 backward, stavi_expressive_completeness).

**Timing**: 8-14 hours. **Depends on**: Phase 3.

---

### Phase 5: Reynolds Theorem 5 — US Completeness over Prior [NOT STARTED]

Compose `stavi_expressive_completeness` with `flatten_stavi_correct`.

**Timing**: 2-3 hours. **Depends on**: Phase 4.

---

### Phase 6A: Reynolds Gap Elimination Lemmas 6-11 [NOT STARTED]

**Timing**: 6-8 hours. **Depends on**: Phase 5.

---

### Phase 6B: Reynolds Lemma 12 Surgery + Theorem 14 [NOT STARTED]

**Timing**: 6-8 hours. **Depends on**: Phase 6A.

---

### Phase 8: Wire no_gaps_discrete [NOT STARTED]

**Timing**: 1-2 hours. **Depends on**: Phase 6B.

---

### Phase 11: Final Verification [NOT STARTED]

**Timing**: 1-2 hours. **Depends on**: Phase 8.

---

## Testing & Validation

- `lake build` passes with zero errors
- `#print axioms bx_completeness` shows only: `propext`, `Classical.choice`, `Quot.sound`
- No `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/`
- No `sorry` on the critical path

## Artifacts & Outputs

- `ExpressivenessGeneral.lean` — inline Claim 1, Cases III/IV, rank-varying Thm 6
- `EFGames.lean` — Lemma 11 backward, stavi_expressive_completeness
- `GapElimination.lean` (NEW) — Reynolds Lemmas 6-14
- `IntegerModel.lean` — no_gaps_discrete wiring

## Rollback/Contingency

Report 39 confirmed full formula materialization (GHR93 Def 8.8) is circular at this stage of the proof. The case-split approach (report 38) faithfully mirrors GHR93's implicit C(c) evaluation. The pigeonhole in Case A extracts a single StaviFormula separator — necessary since the full interval type formula can't be materialized without the theorem being proved.
