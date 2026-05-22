# Implementation Plan: Reynolds Pipeline Activation (v11)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 40-60 hours
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED)
- **Research Inputs**:
  - reports/22_d-consistency-implementation.md (d-consistency via direct uniqueness + Round 2 challenges)
  - reports/23_lemma9-correct-proof.md (Lemma 9 correct -- prior "counterexample" invalid; needs stavi_untl_gap_detection + structural induction)
  - reports/24_lemma9-xmu-gap-evaluation.md (GHR93 uses standard mu-semantics at gaps; complement-point approach correct; FO-table shift transfer lemma)
  - reports/25_cases-III-IV-assembly.md (D-consistency NOT needed for Cases III/IV; assembly chain: Thm 6 rank-varying -> Prop 6 -> Lemma 11 backward -> Prop 7 -> Corollary 5)
  - reports/26_reynolds-gap-elimination.md (1070-1470 lines; split into 6A/6B; depends on Phase 5')
- **Artifacts**: plans/16_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: FULL GHR93, NO SHORTCUTS

The plan formalizes the complete GHR93 game-theoretic proof of expressive completeness of {U,S,U',S'} over ALL linear temporal structures, then uses Reynolds gap elimination to show {U,S} suffices for Prior structures. Every sorry must be closed by following GHR93 step-by-step. No `axiom` declarations, no `IsSuccArchimedean`, no shortcuts.

---

## Overview

This plan (v11) integrates findings from research reports 22-26 and provides a complete phase-by-phase path from the current sorry inventory to sorry-free `bx_completeness`. The plan covers 15 remaining sorry sites across 4 files, organized into 11 phases totaling 40-60 hours. Phases 1-3 address the GHR93 Section 8 core (d-consistency, Lemma 9, Cases III/IV), Phase 4 completes the assembly chain (rank-varying Thm 6, Props 6-7, Corollary 5), Phase 5 bridges to Reynolds Theorem 5, Phases 6A-6B handle gap elimination (Lemmas 6-14), Phases 7-8 close IntegerModel helpers and wire `no_gaps_discrete`, Phase 9 removes `IsSuccArchimedean`, Phase 10 discharges `h_truth_corr`, and Phase 11 runs final verification.

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes with zero errors, no `axiom` declarations in the pipeline.

### Research Integration

- **Report 22** (d-consistency): Direct uniqueness proof via Round 2 point challenges. When d is a point, play Round 2 with p_d; trichotomy gives d = t. When d is a gap, formula agreement forces same cut. Estimated 110-200 lines. Does NOT require infimum architecture change.
- **Report 23** (Lemma 9): Theorem statement IS correct (prior counterexample was invalid -- confused U' with simplified "cofinal AND NOT U"). Proof by structural induction on A, with core helper `stavi_untl_gap_detection` providing X at complement points. Forward direction for stavi_untl case is already closed. Estimated 620-880 total lines.
- **Report 24** (X^mu gap evaluation): GHR93 evaluates A^mu(gamma) at gaps using standard mu-relativized semantics. The X^mu(gamma) problem is a proof architecture issue: `stavi_untl_gap_detection` provides X at complement points, not X^mu(gamma). The fix is an "FO-table shift" transfer lemma for the backward direction.
- **Report 25** (Cases III/IV + assembly): D-consistency is NOT directly needed by Cases III/IV (they use sigma/tau from SplitPointProps). Assembly chain: Thm 6 -> rank-varying Thm 6 -> Prop 6 -> Prop 7 (needs Lemma 11 backward) -> Corollary 5. Total ~1200-2000 lines for Cases III/IV + assembly.
- **Report 26** (gap elimination): Reynolds Lemmas 6-14 estimated at 1070-1470 lines. Split into 6A (Lemmas 6-11, infrastructure) and 6B (Lemma 12 surgery + 13 + 14). Blocked on Phase 5' (US expressive completeness over Prior).

### Prior Plan Reference

The v10 plan had 11 phases (1-5, 4A, 4B, 0, 4C-W1 through 4C-W4, 5' through 11). Phases 1-5, 4A, 4B, 0: COMPLETED. Phase 4C-W1: PARTIAL (muSig + pigeonhole closed; d-consistency weakened to existential; M-side degenerate blocked/latent). Phase 4C-W2: IN PROGRESS (stavi_untl_gap_detection closed; stavi_untl/std_untl forward directions closed; backward directions and snce variants still sorry'd). Key lessons: (1) U' semantics fix was the critical breakthrough; (2) FO encoding bugs can masquerade as mathematical blockers; (3) effort per wave is 4-8 hours.

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Formalizes the complete GHR93 Theorem 3 (expressive completeness of {U,S,U',S'})

## Goals & Non-Goals

**Goals**:
- Close d-consistency interior sorries (ExpressivenessGeneral.lean:1157, 1235) via direct uniqueness argument
- Complete Lemma 9 left/right gap detection (EFGames.lean: 11 sub-sorries)
- Close M-side degenerate sorries (ExpressivenessGeneral.lean:1547, 1564) together with c-gap-case
- Prove Cases III/IV of GHR93 Theorem 6 (ExpressivenessGeneral.lean:3572)
- Complete assembly chain: rank-varying Thm 6, Props 6-7, Corollary 5
- Prove Reynolds Theorem 5 (US expressively complete over Prior)
- Formalize Reynolds Lemmas 6-14 (gap elimination)
- Close IntegerModel sorries and wire `no_gaps_discrete`
- Rewrite `chronicle_is_good`, remove `IsSuccArchimedean`
- Discharge `h_truth_corr` in Transfer.lean
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Dense completeness (separate path, unaffected)
- Closing `succ_cofinal` directly (bypassed via gap elimination)
- Frame-class completeness variants (Completeness.lean:254, 279, 288)
- Optimizing existing sorry-free infrastructure
- Proof automation or tactic development

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| D-consistency gap case: formula-to-cut bridge lemma fails | H | L | Report 22 provides fallback: play Round 2 with any carrier point to establish ordering; if two gaps have same ordering with all points, they are equal by cut extensionality. Budget 40 extra lines for the bridge. |
| Lemma 9 backward direction (FO-table shift) exceeds estimate | H | M | Report 24 identifies the exact transfer: FO witnesses at complement point u0 extend backward to gamma because mu-points in (gamma, s) include all complement points. Budget 200 lines for the backward helper. |
| Cases III/IV gap detection formula rank bounds don't match codebase | M | M | Follow GHR93 exactly: Case III uses left(B,D) with rank r+2, Case IV uses right(B,D) with rank r+3. Verify rank bounds with `stavi_depth` computation before proceeding. |
| Proposition 7 composition too complex (decomposition formula counting) | M | M | GHR93 Proposition 7 proof is explicit (p.26-27). If composition stalls, try direct Corollary 5 route via formula enumeration. |
| Model surgery (Lemma 12) case explosion exceeds budget | M | L | Report 26 estimates 350-450 lines. Modularize into per-case helpers; S cases are perfectly dual to U cases (use a shared template with direction parameter). |
| Phase 5' bridge between Stavi expressive completeness and US completeness encounters unexpected gap | L | L | flatten_stavi_correct (Phase 5, COMPLETED) already proves Stavi formulas equivalent to US formulas on discrete structures. Need only show this extends to Prior structures via the Prior-U/Prior-S axioms. |

## Full Sorry Inventory (15 Remaining Sites)

### EFGames.lean (13 sorry sites)
| Line | Identifier | GHR93 Reference | Phase |
|------|-----------|-----------------|-------|
| 2682 | `std_untl_gap_detection` body | Lemma 9 helper (std Until variant) | 2 |
| 2759 | `left_formula_gap_detection` base.imp case | Lemma 9, base imp | 2 |
| 2763 | `left_formula_gap_detection` base.untl case | Lemma 9, base untl | 2 |
| 2767 | `left_formula_gap_detection` base.snce case | Lemma 9, base snce | 2 |
| 3032 | `left_formula_gap_detection` stavi_untl backward | Lemma 9, U'(A,B) backward | 2 |
| 3036 | `left_formula_gap_detection` stavi_snce case | Lemma 9, S'(A,B) case | 2 |
| 3083 | `left_formula_gap_detection` std_untl backward | Lemma 9, U(A,B) backward | 2 |
| 3087 | `left_formula_gap_detection` std_snce case | Lemma 9, S(A,B) case | 2 |
| 3109 | `stavi_snce_gap_detection` | Lemma 9 helper (Stavi Since variant) | 2 |
| 3124 | `std_snce_gap_detection` | Lemma 9 helper (std Since variant) | 2 |
| 3137 | `right_formula_gap_detection` | Lemma 9 right direction | 2 |
| 4198 | `ghr93_decomposition_implies_game` | Lemma 11 backward | 4 |
| 5500 | `stavi_expressive_completeness` | Corollary 5 | 4 |

### ExpressivenessGeneral.lean (7 sorry sites)
| Line | Identifier | GHR93 Reference | Phase |
|------|-----------|-----------------|-------|
| 1157 | `d_consistency_left` interior | Claim 1 (d = d-bar) | 1 |
| 1235 | `d_consistency_right` interior | Claim 1 (symmetric) | 1 |
| 1547 | `h_pt_xc` degenerate gap | SplitPointProps restructuring | 3 |
| 1564 | `h_pt_cy` degenerate gap | SplitPointProps restructuring | 3 |
| 1668 | c construction gap case | Lemma 9 application | 3 |
| 3572 | `ghr93_cases_III_IV` | Theorem 6 Cases III/IV | 3 |
| 3793 | `ghr93_forward_to_backward_rank_varying` | Theorem 6 rank-varying | 4 |

### IntegerModel.lean (3 sorry sites)
| Line | Identifier | Phase |
|------|-----------|-------|
| 859 | `no_gaps_discrete` | 8 |
| 1135 | `cofinal_decomposition_k_equiv` | 7 |
| 1194 | `ordered_sum_of_good_bounded_is_good` | 7 |

### Transfer.lean (1 sorry site)
| Line | Identifier | Phase |
|------|-----------|-------|
| 574 | `h_truth_corr` | 10 |

**Total**: 24 sorry instances across 15 distinct theorems/locations.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6A | 5 |
| 6 | 6B, 7 | 6A (for 6B), -- (for 7) |
| 7 | 8 | 6B, 7 |
| 8 | 9 | 7, 8 |
| 9 | 10 | -- |
| 10 | 11 | 9, 10 |

Phases within the same wave can execute in parallel.

---

### Phase 1: D-Consistency (GHR93 Claim 1) [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The interior case of d_consistency_left/right requires showing that the forward strategy's response t = a'_full(n) equals d. The current formulation sets d = a_bwd(n) (Spoiler's backward pick) and requires EXHIBITING a response with d at position n.
- **What was tried**: (1) Proving t = d directly from formula agreement + gap/point agreement + boundary correspondence -- fails because two distinct elements CAN have the same rank-r type. (2) Constructing a'_new by substituting d for t at position n -- requires showing d and t have the same ordering relative to ALL game tuple elements, which needs formula-determines-ordering infrastructure not yet in the codebase. (3) Using Round 2 with specific challenges (p_d, p_t) to extract ordering constraints -- yields equalities like `t = d ↔ c = extendPoint b` but doesn't directly force equality.
- **Why it's stuck**: The root cause is a formalization design issue: GHR93 defines d as the INFIMUM of all valid responses (then proves any response equals d), but the current code defines d = a_bwd(n) (Spoiler's backward pick). This disconnect means d_consistency_left/right as currently stated may require either (a) an infimum construction, (b) formula-determines-ordering infrastructure showing that same rank_type + same boundary position implies equality in ExtendedCarrier, or (c) restructuring obtain_split_point_props to define d from the forward strategy instead of from a_bwd.
- **What is needed**: Either (a) add infrastructure proving that two elements of ExtendedCarrier with the same rank_type, same gap/point status, and same boundary relationships must be equal (possible for gaps via cut equality; harder for points), or (b) refactor obtain_split_point_props to define d as the forward strategy's canonical response at the boundary position, then adjust the 30+ downstream uses of hd_eq_an in Cases I-IV.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Goal**: Close the 2 interior case sorries in `d_consistency_left` (line 1157) and `d_consistency_right` (line 1235) using the direct uniqueness argument from report 22.

**GHR93 Reference**: Section 8, Theorem 6 proof, Claim 1 (p.116). "Consider a play of the game G_{m;r'}(M, xy; N, x'y') ... Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). Then d = d-bar."

**Strategy** (from report 22): The theorem has been weakened to existential form: need to EXHIBIT a'_full with bounds + winning + a'_full(n) = d. The direct uniqueness proof works by case-splitting on whether d is a point or gap:
- **Boundary cases** (d = x' or d = y'): Already proved (boundary correspondence forces equality).
- **Interior gap case**: Two gaps with identical formula truth for all depth-r formulas must have identical cuts (gap extensionality). Need bridge lemma connecting formula truth to cut equality (~30-40 lines).
- **Interior point case**: Play Round 2 with p_d (the carrier point that IS d). From the winning condition, extract ordering constraint: `c < extendPoint b ↔ t < extendPoint p_d`. By trichotomy on p_d vs p_t (the carrier point of t), derive p_d = p_t, hence d = t (~30-40 lines).

**Tasks**:
- [ ] **Task 1.1**: Define `d_consistency_point_case` helper lemma (~30-40 lines). Uses h_pt to play Round 2 with p_d. Extracts same_order_type from winning condition at index n+1 vs n+2. Derives p_d = p_t by linear order trichotomy.
- [ ] **Task 1.2**: Define `d_consistency_gap_case` helper lemma (~30-40 lines). When d and t are both gaps with same formula-type and boundary position, show their cuts are equal via: for any carrier point p, `p in d.cut iff p in t.cut` follows from formula agreement (ordering relative to p is characterizable by rank-r formulas).
- [ ] **Task 1.3**: Close `d_consistency_left` interior sorry (line 1157, ~40-60 lines). Intro a_pad, extract t = a'_full(n) from winning condition, case-split on IsPoint d vs IsGap d, apply point_case or gap_case helper.
- [ ] **Task 1.4**: Close `d_consistency_right` interior sorry (line 1235, ~10-20 lines). Symmetric to left; c at position 0 instead of n.
- [ ] **Task 1.5**: Verify `lake build` passes. Verify `lean_verify d_consistency_left` shows no `sorryAx`.

**Timing**: 2-4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close lines 1157, 1235

**Verification**:
- `lean_verify d_consistency_left` shows no `sorryAx`
- `lean_verify d_consistency_right` shows no `sorryAx`
- `lake build` passes

---

### Phase 2: Lemma 9 Gap Detection Correctness [IN PROGRESS]

**Goal**: Close all 11 remaining sub-sorries in `left_formula_gap_detection` and `right_formula_gap_detection` (EFGames.lean), completing GHR93 Lemma 9.

**GHR93 Reference**: Section 8, Lemma 9 (p.111). "Let A, D be temporal formulas with D of rank at most r. Let m in M_r. Then left(A,D)^mu(m) iff exists gap gamma with conditions. PROOF. Clear."

**Current state**: `stavi_untl_gap_detection` is sorry-free. `stavi_untl` and `std_untl` forward directions are closed. The following remain sorry'd: `std_untl_gap_detection` body, base.imp/untl/snce cases, stavi_untl/snce backward directions, std_untl/snce backward directions, stavi_snce_gap_detection, std_snce_gap_detection, right_formula_gap_detection.

**Strategy** (from reports 23, 24):
1. **FO-table shift lemma** (new, ~80-120 lines): If U'(A,B)^mu(gamma) holds at a gap, then U'(A,B) holds at complement points near gamma. The mu-FO-table witnesses at gamma (quantifying over mu-points) restrict to standard FO-table witnesses at complement points. This is the key missing backward direction piece.
2. **Backward directions**: Given gap gamma with A^mu(gamma), need left_formula(A,D)(m). For stavi_untl case A = U'(A0,B0): from U'(A0,B0)^mu(gamma), extract B0 at complement points via condition (3), extract U'(A0,B0) at complement points via FO-table shift. Combine to get (B0 AND U'(A0,B0)) at complement points. Feed to `stavi_untl_gap_detection.mpr` to get U'(B0 AND U'(A0,B0), D)(m).
3. **snce/since variants**: Dual of untl variants. `stavi_snce_gap_detection` and `std_snce_gap_detection` mirror the untl helpers with S'/S in place of U'/U and "below" in place of "above". `right_formula_gap_detection` is dual of `left_formula_gap_detection` with appropriate direction swap.
4. **base cases**: base.imp expands to neg/conj pattern. base.untl and base.snce reduce to the corresponding temporal case patterns.

**Tasks**:
- [ ] **Task 2.1**: Prove `stavi_untl_mu_at_gap_gives_complement_truth` -- the FO-table shift lemma (~80-120 lines). From U'(A,B)^mu(gamma), extract FO witnesses at gamma, restrict to complement points above gamma, produce standard FO table at each complement point.
- [ ] **Task 2.2**: Close `left_formula_gap_detection` stavi_untl backward (line 3032, ~60-80 lines). Use FO-table shift to get U'(A0,B0) at complement points. Extract B0 from condition (3). Combine and apply `stavi_untl_gap_detection.mpr`.
- [ ] **Task 2.3**: Close `left_formula_gap_detection` std_untl backward (line 3083, ~60-80 lines). Same pattern as stavi_untl backward, adapted for standard Until.
- [ ] **Task 2.4**: Prove `std_untl_gap_detection` body (line 2682, ~120-160 lines). Analogous to `stavi_untl_gap_detection` but for standard Until U(X,D). Forward: construct gap from U(X,D)(m). Backward: construct U(X,D)(m) from gap conditions.
- [ ] **Task 2.5**: Prove `stavi_snce_gap_detection` (line 3109, ~100-140 lines). Dual of `stavi_untl_gap_detection` with S' in place of U', "below" in place of "above", cut complement in place of cut.
- [ ] **Task 2.6**: Prove `std_snce_gap_detection` (line 3124, ~100-140 lines). Dual of `std_untl_gap_detection`.
- [ ] **Task 2.7**: Close `left_formula_gap_detection` stavi_snce case (line 3036, ~60-80 lines). Uses `stavi_snce_gap_detection` + FO-table shift (since direction).
- [ ] **Task 2.8**: Close `left_formula_gap_detection` std_snce case (line 3087, ~60-80 lines). Uses `std_snce_gap_detection` + FO-table shift.
- [x] **Task 2.9**: Close `left_formula_gap_detection` base cases -- imp (line 2759, ~40-60 lines), untl (line 2763, ~20-30 lines), snce (line 2767, ~20-30 lines). base.imp expands to neg/conj; base.untl/snce reduce to temporal case patterns. *(deviation: altered -- base.imp closed via gap_detection_unique + IH, base.untl closed via stavi_untl_gap_detection bridge, base.snce still sorry'd pending std_untl_gap_detection)*
- [ ] **Task 2.10**: Prove `right_formula_gap_detection` (line 3137, ~200-300 lines). Dual of left_formula_gap_detection with S'/S in place of U'/U, snce_gap_detection in place of untl_gap_detection, right(A,D) in place of left(A,D). May share infrastructure via direction parameter or manual duplication.
- [ ] **Task 2.11**: Verify `lean_verify left_formula_gap_detection` and `lean_verify right_formula_gap_detection` show no `sorryAx`. Verify `lake build` passes.

**Timing**: 8-12 hours

**Depends on**: none (can proceed in parallel with Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close 11 sorry sites (lines 2682, 2759, 2763, 2767, 3032, 3036, 3083, 3087, 3109, 3124, 3137)

**Verification**:
- `lean_verify left_formula_gap_detection` shows no `sorryAx`
- `lean_verify right_formula_gap_detection` shows no `sorryAx`
- `lean_verify stavi_snce_gap_detection` shows no `sorryAx`
- `lean_verify std_untl_gap_detection` shows no `sorryAx`
- `lake build` passes

---

### Phase 3: c-Gap-Case + M-Side Degenerate + Cases III/IV (GHR93 Theorem 6) [NOT STARTED]

**Goal**: Close the c-gap-case sorry (line 1668), the M-side degenerate sorries (lines 1547, 1564), and prove Cases III and IV of GHR93 Theorem 6 (line 3572).

**GHR93 Reference**: Section 8, Theorem 6 proof, Cases III and IV (pp.117-119).
- **Case III**: alpha_n is a gap defined on the left by D. Use left(B,D) as the detection formula. Apply Lemma 9 left to find gap e_n in (t,d)_r.
- **Case IV**: alpha_n is a gap NOT left-defined. Use right(B,D) as the detection formula. Apply Lemma 9 right to find gap e_n in (t,u).

**Sub-tasks for c-gap-case (line 1668)**: When d is a gap in `obtain_split_point_props`, use Lemma 9 to transfer gap detection from N-side to M-side. The gap gamma in N has a defining formula D; apply `left_formula_gap_detection` or `right_formula_gap_detection` to find the corresponding c in M_r.

**Sub-tasks for M-side degenerate (lines 1547, 1564)**: Restructure `SplitPointProps` to make `h_pt_xc`/`h_pt_cy` conditional: `x < c -> exists p, inClosedInterval x c (extendPoint p)`. Update 5 downstream usage sites with appropriate guards. In Case I, `x < c` follows from the split hypothesis. In Case II, c is always a point (witness exists trivially).

**Tasks**:
- [ ] **Task 3.1**: Restructure `SplitPointProps.h_pt_xc` to conditional form `x < c -> exists p, ...` and `SplitPointProps.h_pt_cy` similarly (~15-20 lines changed in the structure).
- [ ] **Task 3.2**: Update 5 downstream usage sites of h_pt_xc/h_pt_cy with appropriate `x < c` / `c < y` proofs (~30-50 lines). Case I: follows from split hypothesis + boundary correspondence. Case II: c is a point (prove witness trivially).
- [ ] **Task 3.3**: Close c construction gap case (line 1668, ~50-80 lines). Use `left_formula_gap_detection` or `right_formula_gap_detection` to find c in M_r when d is a gap. Apply the defining formula D and the D-between condition to invoke Lemma 9.
- [ ] **Task 3.4**: Close M-side degenerate h_pt_xc (line 1547) and h_pt_cy (line 1564). These become provable once conditional form is in place (the sorry'd case x = c with c a gap is now guarded by `x < c` precondition).
- [ ] **Task 3.5**: Split `ghr93_cases_III_IV` (line 3572) into `ghr93_case_III` and `ghr93_case_IV` (~20 lines dispatch).
- [ ] **Task 3.6**: Prove `ghr93_case_III` -- left-defined gap (~120-180 lines). Steps:
  - Extract D from left-definability of alpha_n
  - Define B = X_{alpha_n}, delta = left(B, D) (rank r+2)
  - Show Nr |= U(delta, A)(alpha_{n-1}) with alpha_n as witness
  - Define d' = sup{t : N |= not-D(t)}, g' = sup{t < d' : N |= delta(t)}
  - Define d, g in M_r similarly
  - Derive sub-interval strategy via Claim 2 pattern (add c,g,d to Spoiler's choices)
  - Apply (**)_n to get backward strategy on (c,g) vs (d,g')
  - Use tau to get e_0,...,e_{n-1}; verify U(delta,A)(e_{n-1})
  - Find t < g with M |= delta(t) and A on (e_{n-1}, t]
  - Apply `left_formula_gap_detection` to get gap e_n in (t,d)_r
  - Verify winning condition (both satisfy B, hence same rank-r formulas)
- [ ] **Task 3.7**: Prove `ghr93_case_IV` -- gap not left-defined (~120-180 lines). Steps:
  - Extract D from right-definability; verify NOT left-definable
  - Define B = X_{alpha_n}, delta = A /\ not-D /\ U(right(B,D), A) (rank r+3)
  - Find witnesses t' < alpha_n < u' with delta(t') and right(B,D)(u')
  - Define d', g' as in Case III
  - Derive sub-interval strategies, apply (**)_n
  - Get e_0,...,e_{n-1} via tau; find t < g with delta(t), then u > t with right(B,D)(u)
  - Apply `right_formula_gap_detection` to get gap e_n in (t,u)
  - Verify winning condition
- [ ] **Task 3.8**: Verify `ghr93_inductive_step` assembly compiles. Verify `lean_verify ghr93_forward_to_backward` shows no `sorryAx`. Run `lake build`.

**Timing**: 6-10 hours

**Depends on**: 1 (d-consistency for SplitPointProps), 2 (Lemma 9 for Cases III/IV and c-gap-case)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close lines 1547, 1564, 1668, 3572
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- possible helper lemmas

**Verification**:
- `lean_verify obtain_split_point_props` shows no `sorryAx`
- `lean_verify ghr93_inductive_step` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward` shows no `sorryAx`
- `lake build` passes

---

### Phase 4: Assembly Chain -- Rank-Varying Thm 6, Lemma 11 Backward, Props 6-7, Corollary 5 [NOT STARTED]

**Goal**: Complete the assembly chain from uniform-rank Theorem 6 through to `stavi_expressive_completeness` (GHR93 Corollary 5, EFGames.lean:5500).

**GHR93 Reference**:
- Theorem 6 rank-varying: (*)_n with forward rank r+4n, backward rank r (p.113)
- Proposition 6: Formula agreement at rank r+4n+1 implies half-line game wins (p.113-114)
- Proposition 7: Composition of interval strategies into full EF game (p.114-115, Definition 8.9)
- Corollary 5: From Propositions 5, 6, 7 (p.115)

**Tasks**:
- [ ] **Task 4.1**: Prove `ghr93_forward_to_backward_rank_varying` (line 3793, ~80-150 lines).
  - Apply uniform-rank Theorem 6 at rank r+4n
  - Use `ghr93_duplicator_wins_round_mono` (Lemma 10) to show rank r+4n strategy restricts to rank r
  - Key subtlety: backward game at rank r+4n gives formula agreement at rank r+4n; rank-r agreement follows trivially (rank-r formulas are a subset)
  - Need `rank_embed` properties: M_r subset of M_{r+4n}, monotone, preserves gap/point
- [ ] **Task 4.2**: Prove `ghr93_decomposition_implies_game` -- Lemma 11 backward (line 4198, ~80-120 lines).
  - From decomposition agreement (all n;r-decomposition formulas agree), construct Duplicator's winning strategy for G_{n;r}
  - Round 1: use decomposition formula to find matching elements (the existential witnesses in the decomposition formula ARE the strategy)
  - Round 2: use the point-matching clause (clause (b) of decomposition formula) to respond to point challenges
- [ ] **Task 4.3**: Prove Proposition 6 (entirely new, ~100-150 lines).
  - Statement: if x and y satisfy same temporal formulas of rank r+4n+1, then Duplicator wins G_{n;r}(M, -inf x; N, -inf y) and G_{n;r}(M, x inf; N, y inf)
  - Proof: define C_i chain (Definition 8.8 style) with C_n = X_{alpha_n} /\ not-U(not-X_{(alpha_n, T)}, T), C_i = X_{alpha_i} /\ U(C_{i+1}, X_{(alpha_i, alpha_{i+1})})
  - Rank bound: rank(C_0) <= r + 4n + 1 (worst case with gap selections adding +3 per selection)
  - From formula agreement, N |= C_0(y); Duplicator extracts matching points from the C_i chain
  - When alpha_i are gaps: use left(X_{alpha_i}, D) or right(X_{alpha_i}, D) with Lemma 9
- [ ] **Task 4.4**: Prove Proposition 7 (entirely new, ~150-250 lines).
  - Statement: with growth functions f, g satisfying f(0)=g(0)=0, f(n+1) > (1+3f(n)) * (2k_n) + 1, g(n+1) > g(n) + 4f(n), if Duplicator wins G_{f(n+1);g(n+1)} on each sub-interval (both directions), then she wins G_n((M,x),(N,y))
  - Proof by induction on n. Inductive step:
    1. If V chooses alpha = x_i, respond with y_i (use IH + Lemma 10)
    2. Otherwise x_i < alpha < x_{i+1}; list decomposition formulas phi_1,...,phi_j (true at (x_i, alpha)) and psi_1,...,psi_k (true at (alpha, x_{i+1}))
    3. Choose witnesses + alpha, apply forward strategy, let e be response to alpha
    4. By Lemma 11 backward: Duplicator wins G_{1+3f(n);r}(M, x_i alpha; N, y_i e) and G_{1+3f(n);r}(M, alpha x_{i+1}; N, e y_{i+1})
    5. By Theorem 6 rank-varying: backward games at rank g(n)
    6. By IH: G_n((M, x+alpha), (N, y+e))
- [ ] **Task 4.5**: Prove Corollary 5 = close `stavi_expressive_completeness` (line 5500, ~80-120 lines).
  - Compose Propositions 5, 6, 7
  - Proposition 6 gives half-line game strategies from formula agreement at rank g(n+1)+1
  - Proposition 7 composes these into full EF game win G_n
  - Proposition 5 converts game win to first-order equivalence at depth n
  - Expressive completeness: partition temporal types at rank 1+g(n+1), each consistent with phi implies phi (by Corollary 5 result), so phi equivalent to disjunction of types
- [ ] **Task 4.6**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`. Run `lake build`.

**Timing**: 8-14 hours

**Depends on**: 3 (Theorem 6 fully proved, enabling rank-varying derivation)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- rank-varying Thm 6 (line 3793), Props 6-7 (new theorems)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Lemma 11 backward (line 4198), Corollary 5 (line 5500)

**Verification**:
- `lean_verify ghr93_forward_to_backward_rank_varying` shows no `sorryAx`
- `lean_verify ghr93_decomposition_implies_game` shows no `sorryAx`
- `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- `lake build` passes

---

### Phase 5: Reynolds Theorem 5 -- US Expressive Completeness over Prior Structures [NOT STARTED]

**Goal**: Prove that {U,S} alone is expressively complete for Prior structures, by composing Corollary 5 (Stavi expressive completeness) with `flatten_stavi_correct` (which shows Stavi formulas reduce to US formulas on Prior structures).

**GHR93/Reynolds Reference**: Reynolds 1994, Theorem 5. "US is expressively complete over Prior structures." This follows from: (1) Corollary 5 gives {U,S,U',S'} expressively complete over all linear orders; (2) on Prior structures, U' and S' are definable in terms of U and S (because Prior-U/Prior-S axioms eliminate the gap-detecting power of Stavi connectives; equivalently, `flatten_stavi_correct` shows each Stavi formula has a US equivalent in Prior contexts).

**Tasks**:
- [ ] **Task 5.1**: Define `US_expressively_complete_over_prior` theorem (~60-100 lines).
  - Statement: for any monadic formula phi(x), there exists a temporal formula A (using only U, S) such that for all Prior structures M and all t in M, M |= phi(t) iff M |= A(t)
  - Proof: from `stavi_expressive_completeness`, get Stavi formula B equivalent to phi. From `flatten_stavi_correct` with Prior-U/Prior-S hypotheses, get US formula A equivalent to B. Compose.
- [ ] **Task 5.2**: Prove bridge lemma between `stavi_temporal_truth` and `temporal_truth` (~30-50 lines). Show that `flatten_stavi` maps Stavi formula evaluation to standard temporal evaluation.
- [ ] **Task 5.3**: Verify `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`. Run `lake build`.

**Timing**: 2-3 hours

**Depends on**: 4 (Corollary 5 = stavi_expressive_completeness)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or new `Theorem5.lean` -- new theorem

**Verification**:
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build` passes

---

### Phase 6A: Reynolds Gap Elimination Lemmas 6-11 + Infrastructure [NOT STARTED]

**Goal**: Formalize Reynolds 1994 Section 7, Lemmas 6-11 and supporting infrastructure. This establishes the structural theory of "bad intervals" (where equivalence classes end at gaps) in Prior structures.

**Reynolds Reference**: Reynolds 1994, Section 7, Lemmas 6-11 (pp.124-129).

**Infrastructure needed**:
- `IsPriorStructure` predicate or bundled hypothesis pattern
- The rho formula: "x's ~-class ends in a gap on the right" encoded as `MonadicFormula sig 1`
- "Maximal interval" characterization as a predicate on sets
- Prior-structure preservation under convex restriction

**Tasks**:
- [ ] **Task 6A.1**: Create `GapElimination.lean`. Define infrastructure (~100-150 lines): `IsPriorStructure` predicate (or parameter pattern), rho formula encoding, maximal_interval predicate, bad_point/bad_interval definitions.
- [ ] **Task 6A.2**: Prove Lemma 6 -- R exists (~100-150 lines). Apply `US_expressively_complete_over_prior` to rho(x) to obtain temporal formula R true exactly at points whose class ends in a gap on the right. Dually L.
- [ ] **Task 6A.3**: Prove Lemma 7 -- R-interval openness (~80-120 lines). Maximal R-intervals are open. If bounded, endpoints are actual points (not gaps). Proof uses Prior-U applied to R: if R doesn't hold forever after t, then either last R-point (impossible given rho structure) or first not-R-point (the excluded endpoint).
- [ ] **Task 6A.4**: Prove Lemma 8 -- no first/last class (~60-80 lines). In any maximal R-interval, there is no first or last ~-class. Uses Theorem 5 (expressive completeness) to characterize "being in a first/last class" as temporal, then Prior-U gives contradiction.
- [ ] **Task 6A.5**: Prove Lemma 9-Reynolds -- elementary equivalence of classes (~150-200 lines). Two-part proof: (1) If A holds somewhere in one class but not another, find temporal formula B true throughout one class up to gap, false after -- contradicts Prior-U. (2) For any monadic sentence phi, relativize to get phi_restricted, use (1) to transfer between classes.
- [ ] **Task 6A.6**: Prove Lemma 10 -- bad interval structure (~80-100 lines). Show both R and L hold throughout any bad interval. Uses Lemma 9: if not-L holds in one class, the preceding class doesn't end at a gap, contradicting R.
- [ ] **Task 6A.7**: Prove Lemma 11-Reynolds -- formula propagation (~60-80 lines). If B holds "for a while" at the start of a class in a bad interval, it holds throughout the bad interval. If B holds anywhere, it holds arbitrarily close to each end of each class.
- [ ] **Task 6A.8**: Verify all Lemmas 6-11 compile. Run `lake build`.

**Timing**: 6-8 hours

**Depends on**: 5 (US_expressively_complete_over_prior for Lemma 6)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- add import

**Verification**:
- Each lemma individually verified with `lean_verify`
- `lake build` passes

---

### Phase 6B: Reynolds Gap Elimination Lemma 12 Surgery + Lemma 13 + Theorem 14 [NOT STARTED]

**Goal**: Formalize the model surgery argument (Lemma 12), derive the contradiction (Lemma 13), and assemble Theorem 14 (gap elimination).

**Reynolds Reference**: Reynolds 1994, Section 7, Lemmas 12-13, Theorem 14 (pp.129-133).

**Lemma 12 (model surgery)**: Let Q- precede the bad interval, Q+ follow it, Q0 be the bad interval, I any one ~-class in Q0. Let N = M restricted to Q- union I union Q+. Then for all temporal formulas A and all t in N: M |= A(t) iff N |= A(t). Proof by induction on formula; 7 forward cases + 6 backward cases for U (and dual for S = 13 sub-cases for S, but S is truly dual).

**Tasks**:
- [ ] **Task 6B.1**: Define model surgery construction N = M restricted to Q- union I union Q+ (~80-100 lines). Define the subtype, prove it inherits LinearOrder, construct `OrderedMonadicStructure` on it, show predicate interpretations transfer. Use convex restriction pattern.
- [ ] **Task 6B.2**: Prove Lemma 12 forward direction for U(A,B) (~120-150 lines). 7 sub-cases by position of t and witness s:
  1. t < s in Q-: IH
  2. t in Q-, s in Q0: A somewhere in Q0 so in I (Lemma 9). B into Q0 so everywhere (Lemma 11). IH.
  3. t in Q-, s in Q+: B throughout I in both M and N.
  4. t < s in I: IH
  5. t in I, s later in Q0: Lemma 9 gives A near end of I. B throughout I.
  6. t in I, s in Q+: B throughout I.
  7. t < s in Q+: IH
- [ ] **Task 6B.3**: Prove Lemma 12 backward direction for U(A,B) (~100-130 lines). 6 sub-cases:
  1. t < s in Q-: IH
  2. t in Q-, s in I: B to end of Q-. B at start of I in N so in M. Lemma 9 gives B throughout Q0.
  3. t in Q-, s in Q+: B throughout I in N so M. Lemma 9 gives B throughout Q0.
  4. t < s in I: IH
  5. t in I, s in Q+: B throughout I.
  6. t < s in Q+: IH
- [ ] **Task 6B.4**: Prove Lemma 12 for S(A,B) (~30-50 lines). Invoke duality with U direction or duplicate with past/future swapped.
- [ ] **Task 6B.5**: Prove Lemma 12 for U'(A,B) and S'(A,B) (~60-100 lines). Similar case structure but adapted for Stavi connective semantics (gap-detecting behavior interacts with surgery).
- [ ] **Task 6B.6**: Prove Lemma 12 base cases (atoms, boolean) (~20-30 lines). Atoms: interpretation transfers directly by construction. Boolean: from IH.
- [ ] **Task 6B.7**: Prove Lemma 13 -- no bad points (~60-80 lines). Contradiction:
  1. R holds in I in N (by Lemma 12, temporal truth preserved)
  2. N is a Prior structure (any Prior-U counterexample in N is also one in M)
  3. R holds at a point iff its class ends in a gap (definition of R via rho)
  4. But I as a class in N: Q+ is non-empty (Lemma 7), begins with point q; not-R holds at q in M hence in N; so q is not in I's class in N; the class ends at q's boundary
  5. R cannot have held -- contradiction
- [ ] **Task 6B.8**: Prove Theorem 14 assembly (~10-30 lines). Direct from Lemma 13: no bad points means no class ends at a gap.
- [ ] **Task 6B.9**: Verify `lean_verify gap_elimination_theorem_14` shows no `sorryAx`. Run `lake build`.

**Timing**: 6-8 hours

**Depends on**: 6A (Lemmas 6-11)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- continue from Phase 6A

**Verification**:
- `lean_verify gap_elimination_theorem_14` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: IntegerModel.lean Helper Sorries [NOT STARTED]

**Goal**: Close `cofinal_decomposition_k_equiv` (line 1135) and `ordered_sum_of_good_bounded_is_good` (line 1194).

**Tasks**:
- [ ] **Task 7.1**: Prove `cofinal_decomposition_k_equiv` (~100-150 lines). Show that if M and N are k-equivalent and both have cofinal decomposition property, then their cofinal decompositions are also k-equivalent. Uses induction on the decomposition structure and the existing `NEquivalence` infrastructure.
- [ ] **Task 7.2**: Prove `ordered_sum_of_good_bounded_is_good` for k >= 2 (~100-200 lines). Show that an ordered sum of "good" structures indexed by a bounded linear order is itself good. Uses the shift-and-glue technique: construct an OrderIso from the ordered sum to Z by concatenating the individual OrderIsos from each summand.
- [ ] **Task 7.3**: Construct shift-and-glue OrderIso helper (~80-120 lines). Technical lemma: if each summand is order-isomorphic to an interval of Z, and the index set is finite, then the concatenation is order-isomorphic to a larger interval of Z.
- [ ] **Task 7.4**: Verify `lean_verify very_good_implies_good` shows no `sorryAx`. Run `lake build`.

**Timing**: 4-6 hours

**Depends on**: none (can proceed in parallel with the GHR93 chain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

**Verification**:
- `lean_verify cofinal_decomposition_k_equiv` shows no `sorryAx`
- `lean_verify ordered_sum_of_good_bounded_is_good` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Wire no_gaps_discrete [NOT STARTED]

**Goal**: Replace `no_gaps_discrete` sorry (IntegerModel.lean:859) with call to `gap_elimination_theorem_14`.

**Reynolds wiring**: Theorem 14 says "~-classes of a contemporaneous equivalence relation on a Prior structure do not end at gaps." In the discrete context (SuccOrder + PredOrder), "class ending at a gap" is equivalent to having NO boundary at a successor pair. So Theorem 14 implies: if a and b are in different classes, walking from a toward b crosses a class boundary at some successor pair (c, succ(c)), giving c ~M a but succ(c) NOT ~M a.

**Tasks**:
- [ ] **Task 8.1**: Replace `no_gaps_discrete` sorry with `gap_elimination_theorem_14` call (~20-40 lines).
  - Apply Theorem 14 to get "no gap boundaries"
  - Use discreteness (SuccOrder) to turn "boundary exists" into "boundary at successor pair"
  - Return the existential witness c
- [ ] **Task 8.2**: Verify `lean_verify no_gaps_discrete` shows no `sorryAx`. Run `lake build`.

**Timing**: 1-2 hours

**Depends on**: 6B (gap_elimination_theorem_14), 7 (IntegerModel helpers)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

**Verification**:
- `lean_verify no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Rewrite chronicle_is_good and Remove IsSuccArchimedean [NOT STARTED]

**Goal**: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good` (now sorry-free after Phases 7-8). Remove `domain_succ_archimedean` from `ChronicleAsPriorModel` and all downstream uses of `IsSuccArchimedean`.

**Tasks**:
- [ ] **Task 9.1**: Rewrite `chronicle_is_good` proof (~30-50 lines). Replace the current proof (which relies on `succ_cofinal` via IsSuccArchimedean) with: apply `one_class` (using `no_gaps_discrete` to show each equivalence class is a single interval), then `very_good_implies_good` (using the IntegerModel helpers).
- [ ] **Task 9.2**: Remove `domain_succ_archimedean` field from `ChronicleAsPriorModel` structure (~20-30 lines deleted). This field currently provides `IsSuccArchimedean` which is no longer needed.
- [ ] **Task 9.3**: Fix cascade in NEquivalence.lean (~20-50 lines). Any downstream uses of `domain_succ_archimedean` must be replaced with the gap-elimination-based argument.
- [ ] **Task 9.4**: Remove `orderIsoIntOfLinearSuccPredArch` usage from `countermodel_discrete` (~30-50 lines). Replace with the new `chronicle_is_good` proof path.
- [ ] **Task 9.5**: Propagate removal to downstream code (~10-20 lines). Search for remaining `IsSuccArchimedean` references and eliminate.
- [ ] **Task 9.6**: Verify no `IsSuccArchimedean` in ChronicleAsPriorModel or critical path. Verify `lake build` passes.

**Timing**: 3-5 hours

**Depends on**: 7 (IntegerModel helpers), 8 (no_gaps_discrete)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

**Verification**:
- `lean_verify chronicle_is_good` shows no `sorryAx`
- `grep -rn "IsSuccArchimedean" Theories/Bimodal/Metalogic/WeakCanonical/` returns empty (or only non-critical uses)
- `lake build` passes

---

### Phase 10: Discharge h_truth_corr [NOT STARTED]

**Goal**: Eliminate the h_truth_corr sorry at Transfer.lean:574 by delegating `countermodel_discrete` to `dd_countermodel_chronicle_discrete`.

**Tasks**:
- [ ] **Task 10.1**: Replace `countermodel_discrete` proof body with delegation to `dd_countermodel_chronicle_discrete` (~5-10 lines). The key is matching the type signatures between the two theorem statements.
- [ ] **Task 10.2**: Remove unused infrastructure from Transfer.lean (~50 lines removed). Clean up any helper definitions that are no longer needed after the delegation.
- [ ] **Task 10.3**: Verify `lean_verify countermodel_discrete` shows no `sorryAx`. Run `lake build`.

**Timing**: 1-2 hours

**Depends on**: none (independent of main chain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`

**Verification**:
- Transfer.lean:574 sorry eliminated
- `lean_verify countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 11: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify entire pipeline is sorry-free with no custom axioms.

**Tasks**:
- [ ] **Task 11.1**: Run `lean_verify countermodel_discrete` -- should show only propext, Classical.choice, Quot.sound.
- [ ] **Task 11.2**: Run `lean_verify bx_completeness` -- should show only propext, Classical.choice, Quot.sound.
- [ ] **Task 11.3**: Run `lean_verify stavi_expressive_completeness` -- should show only propext, Classical.choice, Quot.sound.
- [ ] **Task 11.4**: Trace and fix any unexpected `sorryAx`. If any sorry remains, identify the source and close it.
- [ ] **Task 11.5**: Verify no `axiom` declarations: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/`.
- [ ] **Task 11.6**: Run full `lake build`. Confirm zero errors.
- [ ] **Task 11.7**: Update file-level documentation: add module docstrings for GapElimination.lean and any new files.

**Timing**: 1-2 hours

**Depends on**: 9, 10

**Files to modify**:
- Potentially any file in `Theories/Bimodal/Metalogic/WeakCanonical/` for stray sorry cleanup

**Verification**:
- `#print axioms bx_completeness` shows: propext, Classical.choice, Quot.sound (NO sorryAx)
- `#print axioms stavi_expressive_completeness` shows: propext, Classical.choice, Quot.sound
- `#print axioms US_expressively_complete_over_prior` shows: propext, Classical.choice, Quot.sound
- `#print axioms gap_elimination_theorem_14` shows: propext, Classical.choice, Quot.sound
- `#print axioms chronicle_is_good` shows: propext, Classical.choice, Quot.sound
- `lake build` passes with zero errors
- No `axiom` declarations in WeakCanonical directory
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ | grep -v "^.*--.*sorry"` returns empty (no remaining sorry outside comments)

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound`
- [ ] `#print axioms countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` shows no `sorryAx`
- [ ] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `#print axioms gap_elimination_theorem_14` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `#print axioms stavi_table_mu_correct` shows no `sorryAx`
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` returns empty
- [ ] No `IsSuccArchimedean` in theorem statements on critical path
- [ ] No new `sorry` introduced on the critical path
- [ ] All sorry sites from inventory (24 instances across 15 theorems) are closed

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Lemma 9 (left + right), stavi_snce/std_snce gap detection, Lemma 11 backward, stavi_expressive_completeness
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- d-consistency, M-side degenerate, c-gap-case, Cases III/IV, rank-varying Thm 6, Props 6-7
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW) -- Reynolds Lemmas 6-13, Theorem 14
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or `Theorem5.lean` -- Reynolds Theorem 5
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- cofinal_decomposition, ordered_sum, no_gaps_discrete, chronicle_is_good
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- h_truth_corr, IsSuccArchimedean removal
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- IsSuccArchimedean removal
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- cascade fixes
- `specs/155_reynolds_pipeline_activation/plans/16_reynolds-pipeline-plan.md` -- This plan (v11)

## Rollback/Contingency

1. **D-consistency (Phase 1)**: If the direct uniqueness proof's gap case fails (formula-to-cut bridge), fall back to the full infimum route from report 22 Section 8 (~300 lines with SplitPointProps changes). If that also stalls, use Option C (Classical.choice canonical strategy) as described in report 18.
2. **Lemma 9 (Phase 2)**: If any case exceeds 200 lines, decompose into sub-lemmas and mark [PARTIAL] with proved cases. The forward directions are already closed for stavi_untl/std_untl; prioritize backward directions and snce variants.
3. **Cases III/IV (Phase 3)**: If the case-specific construction exceeds budget, implement Case III first (simpler: left-defined gap, rank r+2) and leave Case IV for a follow-up. Case III alone unblocks a significant portion of the assembly.
4. **Assembly (Phase 4)**: If Prop 7 composition is too complex, try direct Corollary 5 route via formula type enumeration (bypassing Prop 7). If Prop 6 encounters unexpected issues with gap selections, implement the point-only version first.
5. **Gap elimination (Phases 6A-6B)**: Lemma 12's 14 cases can be individually modularized. Mark [PARTIAL] if stuck after 8 hours on surgery cases. S cases are perfectly dual to U (invoke symmetry lemma or duplicate with direction swap).
6. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck on any phase, mark [BLOCKED] and request additional research. The critical directive prohibits shortcuts.
