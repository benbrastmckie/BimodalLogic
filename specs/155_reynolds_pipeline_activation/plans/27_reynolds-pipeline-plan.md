# Implementation Plan: Reynolds Pipeline Activation (v17)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 44-72 hours (revised from 40-65; Phase 1 restructured with M-side infimum construction)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**:
  - reports/22-26 (original research, see v11 for summaries)
  - reports/27_d-consistency-blocker.md (rank mismatch root cause, rank embedding approach)
  - reports/28_phase7-ordered-sum.md (Phase 7 orphaned -- very_good_implies_good unused)
  - reports/29_d-consistency-architecture.md (infimum redefinition IS necessary, not wasted)
  - reports/30_critical-path-wiring.md (critical path analysis -- superseded by reports 31-32)
  - reports/31_succ-cofinal-analysis.md (root sorry analysis, OrderIso bypass fails)
  - reports/32_burgess-omega-chain.md (omega-chain CAN produce gaps; full Reynolds pipeline needed)
  - reports/33_omega-chain-internals.md (Prior-UZ argument fails in discrete case -- vacuous guard)
  - reports/34_boneyard-candidates.md (Tier 1 archival: ~430 lines genuinely orphaned)
  - reports/35_phase1-blocker-prior-art.md (DEFINITIVE: report 29 correct, handoff-b wrong; both infimum + rank embedding needed)
  - reports/18_task17-blocker-resolution.md (Task 1.7 resolution: decouple round count from n, universal h_r1_univ keeps rank r+1 out of IH; Option B infeasible, Option E incorrect)
  - reports/22_claim1-case2-literature.md (GHR93 Claim 1 and Case II verbatim extraction with Lean identifier mappings; predicate-level Claim 1 proof, U(B,A) transfer for Case II, 5-case round-2 winning condition)
  - reports/23_tactic-needs-beyond-195.md (per-sorry tactic analysis: only same_order_type benefits from task 195; other 7 sorries need manual proofs)
  - reports/27_post-195-assessment.md (task 195 tactics DIRECTLY resolve sigma/tau same_order_type blockers; replace simp_all with delta game_tuple; split_ifs; updated sorry inventory with line numbers)
  - **reports/27_team-research.md** (Round 15: team research synthesis from 4 teammates -- root cause of h_d_unique blocker, convergent resolution strategy, infrastructure inventory)
  - handoffs/phase-1-handoff-20260522T160731Z.md (sorry inventory, Task 1.2/1.3 confirmed complete, 5 proposed solutions for Task 1.7)
  - handoffs/phase-1-handoff-20260522T210000Z.md (Round 8: same_order_type proof architecture verified via multi_attempt, simp_all compilation blocker identified)
  - handoffs/phase-1-handoff-20260522T220000Z.md (Round 9: simp_all rewrite analysis, sigma sorry fallback found, tau needs sigma instantiation for (x' < d iff x < c))
  - handoffs/phase-1-handoff-20260522T234500Z.md (Round 14: hd_in_SC + h_cofinal_failure_below_d proved, pigeonhole precondition blocker identified)
  - **handoffs/phase-1-handoff-20260523T010000Z.md** (Round 16: DEFINITIVE -- h_d_unique as stated is too strong for generic elements; GHR93 Claim 1 requires c = inf(S_C^M); M-side infimum construction needed)
- **Artifacts**: plans/27_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [23_tactic-needs-beyond-195.md, 27_post-195-assessment.md, 28_claim1-formula-materialization.md, 29_lean-infra-h-d-unique.md, 27_team-research.md, phase-1-handoff-20260523T010000Z.md]

---

## CRITICAL DIRECTIVE: FULL GHR93 + REYNOLDS, NO SHORTCUTS

The plan formalizes the complete GHR93 game-theoretic proof of expressive completeness of {U,S,U',S'} over ALL linear temporal structures, then uses Reynolds gap elimination to show {U,S} suffices for Prior structures and close `succ_cofinal`. No `axiom` declarations, no shortcuts.

**Key finding (report 32)**: The omega-chain construction CAN produce gaps (Z+Z models). `succ_cofinal` cannot be closed from temporal axioms or construction internals alone (Prior-UZ guard is vacuous in discrete case, report 33). The FULL Reynolds gap elimination (Theorem 14) is the only viable path. The EFGames/ExpressivenessGeneral infrastructure IS the Reynolds pipeline.

**Phase 1 resolution (report 35 + Round 16 handoff)**: Report 29 is correct; handoff-b is wrong. BOTH infimum redefinition AND rank embedding are needed. The current code sets d = x' (placeholder, not the actual infimum). With d = d-bar (the true infimum), Claim 1 at rank r+2 (Lean depth) proves d_consistency. Case II must construct e_n as a fresh point via U(B,A) transfer. All required infrastructure (rank_embed, infimum_gap, h_fwd_r1 propagation) is already sorry-free.

**v17 CRITICAL CORRECTION (Round 16 handoff)**: h_d_unique as currently formulated is UNPROVABLE for generic elements. GHR93 Claim 1 only proves uniqueness for game responses, not arbitrary elements. The proof requires c = inf(S_C^M) (the M-side infimum), not just rank-r agreement from a 1-round game play. The fix: (1) construct M-side continuation set S_C^M and c = inf(S_C^M), (2) remove h_d_unique as standalone lemma, (3) inline the Claim 1 argument directly in d_consistency_left/right using both infima (c = inf(S_C^M), d = inf(S_C^N)) and the rank-(r+2) game for formula transfer.

**Rank arithmetic fix (reports 28-29, Round 13)**: GHR93's "rank r+1" maps to Lean `stavi_depth` r+2, because `stavi_depth(.std_snce A B) = max(depth A, depth B) + 2`. The h_fwd_r1 parameter has been bumped from r+1 to r+2 across 6 signatures (Round 13, committed). Case 2 of infimum construction proved unreachable. The K^-(not-D) formula (depth <= r+2) is the bridge for the inline Claim 1 argument.

**Task 195 completion (v14)**: Task 195 created `EFGameTactics.lean` with `simp_game_tuple`, `same_order_type_grid`, `order_refl`, `extract_order`, `pivot_chain_order'`/`pivot_chain_order_rev'`, `gap_point_agreement_of_cases`, and `formula_agreement_of_cases`. It also moved `game_tuple_*_eq` and `pivot_chain_order`/`pivot_chain_order_rev` from ExpressivenessGeneral.lean to EFGames.lean as public declarations. These tactics directly resolve the compilation blocker for Phase 1 Task 1.6 same_order_type (sigma and tau).

---

## Overview (v17)

This plan (v17) revises v16 based on Round 16 implementation analysis (handoff-20260523T010000Z). The core finding: h_d_unique as stated is TOO STRONG for generic elements. GHR93 Claim 1 only proves that the game response equals the infimum, not that ANY element with rank-r agreement equals the infimum. The proof fundamentally requires c = inf(S_C^M), not just an existential witness with rank-r agreement from a 1-round game.

**Why h_d_unique fails**: The statement says for ANY t' in [x', y'] with rank-r formula agreement with d, same gap/point and boundary status, t' = d. This cannot be proved because: (1) ht'_form only gives rank-r agreement but K^-(not-D) needs rank-(r+2), (2) h_fwd_r1 gives M-to-N agreement at rank r+2 but not N-to-N, (3) h_fwd and h_fwd_r1 are independent game instances with no relation between their responses, (4) no mechanism exists in the game API for N-to-N agreement between two N-points.

**Why GHR93's proof works**: In GHR93, d (game response) and d-bar (infimum) are connected via the SAME game instance. The game at rank r+1 (our r+2) places c (M-side infimum) against d in round 1. Formula agreement at rank r+1 transfers K^-(not-C') from c to d. C'(c) = TRUE from M-side infimum analysis. So C'(d) = TRUE constrains d to equal d-bar. The key: c is constructed as inf(S_C^M), not as a generic game response.

**v17 restructuring**: Remove h_d_unique as standalone lemma. Construct M-side continuation set S_C^M and c = inf(S_C^M). Prove infimum correspondence (rank-r agreement between c and d via the game). Inline the full GHR93 Claim 1 argument in d_consistency_left/right using both infima and K^-(not-D) transfer.

The critical path remains:

```
Phase 1 (M-side infimum + inline Claim 1 + same_order_type sigma/tau)
  -> Phase 3 (Cases III/IV) -> Phase 4 (Assembly + Corollary 5)
    -> Phase 5 (Reynolds Thm 5) -> Phases 6A-6B (gap elimination)
      -> succ_cofinal -> bx_completeness
```

Phase 1 status: h_fwd_r1 rank bumped from r+1 to r+2 (Round 13). d in S_C and h_cofinal_failure_below_d proved (Round 14). h_d_unique has 2 remaining sorries but is NOW KNOWN TO BE UNPROVABLE as formulated. Restructuring required: remove h_d_unique, construct M-side infimum, inline Claim 1 argument. Sigma SOT has 18/25 grid goals closed. Tau SOT not yet attempted. Once the inline Claim 1 closes d_consistency, both SOT proofs unblock via c<=e_n. Phases 2, 10 are COMPLETE. Phases 7-9 remain OFF the critical path.

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes with zero errors, no `axiom` declarations in the pipeline.

### Research Integration

Reports 23 and 27 (integrated in v14) provide the post-task-195 assessment:

- **Report 23**: Systematic per-sorry tactic analysis. Confirms task 195 tactics are the right and sufficient tactic investment. The remaining 7 sorries (excluding 2 same_order_type) are each unique mathematical arguments that cannot be profitably automated. Only marginal additional tactic (`point_witness_interval`) saves lines but blocks nothing.
- **Report 27**: Post-task-195 blocker assessment. Confirms lines 3059 (sigma) and 3263 (tau) same_order_type are DIRECTLY RESOLVED by replacing `simp_all` with `delta game_tuple; split_ifs` (controlled normalization via `simp_game_tuple`). Provides recommended proof strategies for both sigma and tau cases. Notes that tau case needs sigma instantiation for `(x' < d iff x < c)` ordering link.

Integrated in v15:
- **Report 28**: GHR93 Claim 1 formula materialization. Critical finding: `stavi_depth(.std_snce A B) = max(depth A, depth B) + 2`, so K^-(not-D) has Lean depth r+2 (not r+1 as GHR93 rank suggests). Fix: bump h_fwd_r1 to rank r+2. Proof path: pigeonhole formula D + K^-(not-D) construction + game transfer.
- **Report 29**: Lean infrastructure inventory. Both sorry goals are `False`. Existing infrastructure: `pigeonhole_definable_formula`, `infimum_gap_r_definable`, `rank_embed_stavi_truth_mu`, `stavi_table_mu_correct`. Missing: K^- combinator, finite type conjunction, predicate-to-formula bridge. Recommends standalone `ghr93_claim1_uniqueness` lemma (150-250 lines).

Integrated in v16:
- **Report 27_team-research.md**: 4-teammate convergent resolution of h_d_unique blocker. Key findings: (1) pigeonhole approach is a detour from GHR93 Claim 1, (2) h_d_unique IS provable as stated using h_fwd_r1 internally, (3) all infrastructure exists (StaviFormula.neg, .std_snce, rank_embed_stavi_truth_mu, formula_agreement), (4) GHR93+Reynolds pipeline confirmed as the only viable path, (5) sorry count is 16 (not 15). Revised effort: 40-65 hours.

Integrated in v17:
- **Handoff phase-1-handoff-20260523T010000Z.md**: DEFINITIVE Round 16 analysis. After 3+ hours of exhaustive proof attempts, h_d_unique as stated is confirmed UNPROVABLE for generic elements. The v16 team research was WRONG about h_d_unique being provable (the h_fwd_r1 game gives M-to-N agreement, not N-to-N). GHR93 Claim 1 fundamentally requires c = inf(S_C^M). The fix: construct M-side continuation set, define c = inf(S_C^M), remove h_d_unique, inline Claim 1 in d_consistency_left/right. Net +80-180 lines, significant restructuring. All required infrastructure (pigeonhole, rank_embed, stavi_truth_mu) is sorry-free.

Prior integration (v13-v14):
- **Report 35**: Resolves Phase 1 d-consistency blocker. Report 29 correct, handoff-b wrong. Both infimum redefinition and rank embedding needed.
- **Report 18**: Resolves Task 1.7 IH h_fwd_r1 recursive rank tower via decoupled round count + universal h_r1_univ.

### Prior Plan Reference

v16 was accurate on all phases except Phase 1 Task 1.4 h_d_unique, where the team research (v16) incorrectly claimed h_d_unique was provable as stated. Round 16 implementation analysis DEFINITIVELY shows h_d_unique is too strong for generic elements. v17 replaces the standalone h_d_unique approach with M-side infimum construction + inline Claim 1. Sorry count remains 16 but the 2 h_d_unique sorries will be REPLACED (not closed) by the restructured inline proof. Effort estimates adjusted upward. Phases 2-11 structure unchanged from v16.

### Session Progress (v12 -> v13 -> rounds 1-14 -> Round 15 research -> Round 16-19 implementation)

| Item | Status | Round | Lines |
|------|--------|-------|-------|
| Phase 2: Lemma 9 gap detection | COMPLETE | pre-v13 | ~4700 new |
| Phase 10: Transfer.lean | COMPLETE | pre-v13 | -86 net |
| Phase 1: d redefined as infimum (architecture) | COMPLETE | pre-v13 | ~50 new |
| Phase 1: rank r+1 parameter propagated | COMPLETE | pre-v13 | ~40 new |
| Phase 1: Task 1.2 (hd_le_an) | COMPLETE | pre-v13 | 0 (already done) |
| Phase 1: Task 1.3 (Case I sites) | COMPLETE | pre-v13 | 0 (already correct) |
| Phase 1: Task 1.7 (IH h_fwd_r1 decoupled) | COMPLETE | Round 2 | +83, -39 |
| Phase 1: Task 1.1 (infimum 3-way case split) | COMPLETE | Round 4 | ~140 new, -2 sorries |
| Phase 1: Task 1.5 (d_consistency interior via h_d_unique) | COMPLETE | Round 6 | ~100 new |
| Phase 1: Task 1.6 e_n construction + sigma/tau split | COMPLETE | Round 5 | ~60 new |
| Phase 1: Task 1.6 gp_agreement (sigma + tau) | COMPLETE | Round 7 | ~80 new |
| Phase 1: Task 1.6 formula_agreement (sigma + tau) | COMPLETE | Round 7 | ~80 new |
| Phase 1: Task 1.6 sigma SOT grid (18/25 goals) | PARTIAL | Round 10 | ~60 new, 7 goals need c<=e_n from Claim 1 |
| Phase 1: h_fwd_r1 rank bump r+1 -> r+2 | COMPLETE | Round 13 | 6 signatures + 2 derivations |
| Phase 1: Case 2 infimum proved unreachable | COMPLETE | Round 13 | d in S_C contradicts hp_not_in |
| Phase 1: d in S_C lemma | COMPLETE | Round 14 | hd_in_SC |
| Phase 1: h_cofinal_failure_below_d | COMPLETE | Round 14 | failure mu-point in (s, d] |
| Round 16: h_d_unique UNPROVABLE | COMPLETE | Round 16 | definitively confirmed by 5 agents |
| Step 1.4a: cont_holds_cross + continuation_set_cross | COMPLETE | Round 18 | +55 lines, sorry-free |
| Step 1.4b: c_inf = inf(S_C^M) | COMPLETE | Round 18 | +90 lines, Case 3 sorry'd |
| Step 1.4c: c_inf ∈ S_C^M + cofinal failure | COMPLETE | Round 18 | +30 lines, sorry-free |
| Step 1.4d: pigeonhole_definable_formula_cross | COMPLETE | Round 19 | +180 lines, sorry-free |
| Step 1.4e: Suffices restructured to h_fwd_r1 | COMPLETE | Round 19 | +130/-117 lines |
| Step 1.4f: Gap/point + boundary projection | COMPLETE | Round 19 | +45 lines, sorry-free |
| Step 1.4g: Direction 2 carrier-point case | COMPLETE | Round 19 | +60 lines (h_cont_transfer), sorry-free |
| Step 1.4g: Formula agreement hform_cd | COMPLETE | Round 19 | sorry-free via rank_embed projection |
| Step 1.4h-i OLD: Pigeonhole-based K⁻ pipeline | ABANDONED | Round 19-21 | Root cause (report 36): cont_holds is predicate not formula |
| Root cause analysis (report 36) | COMPLETE | Round 22 | GHR93 C is single formula; our cont_holds is predicate |
| Claim 1 boundary cases (c_inf=x, c_inf=y) | COMPLETE | Round 22 | Proved via game order agreement, no K⁻ needed |
| Gap equivalence research | FALSE | Round 23 | Atoms distinguish points from gaps; lemma fails at base case |
| Key insight: d always carrier point | COMPLETE | Round 23 | Case 3 (gap) is sorry'd Phase 3; Cases 1+2 give d = extendPoint p |
| Claim 1 interior cases (2 sorries: ~2577, ~2732) | UNBLOCKED | Round 23 | K⁻(¬D_M) with vacuous Since witness s=rank_embed(d) works on live paths |
| Phase 1: Task 1.6 same_order_type (sigma + tau) | BLOCKED on 1.4 | Round 10 | 7 sigma + all tau goals |
| Task 195: EF game tactics | COMPLETE | -- | +208 lines |
| Phase 3: c-gap-case (n>=1) | DONE | pre-v13 | ~40 new |
| Rank embedding infrastructure | CONFIRMED | pre-v13 | 0 (already sorry-free) |

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates `succ_cofinal` via Reynolds gap elimination (not task 129 Henkin approach)
- Formalizes the complete GHR93 Theorem 3 + Reynolds Theorem 14

## Goals & Non-Goals

**Goals**:
- Construct M-side continuation set S_C^M and c = inf(S_C^M), mirroring d = inf(S_C^N)
- Remove h_d_unique as standalone lemma
- Inline GHR93 Claim 1 argument in d_consistency_left/right using both infima + K^-(not-D) + rank-(r+2) game
- Close same_order_type sigma (line 3059) and tau (line 3263) using task 195 EFGameTactics -- uncomment and fix block-commented proofs
- Close d_consistency_left/right via inline Claim 1 (replaces previous h_d_unique dependency)
- Complete Lemma 9 left/right gap detection (EFGames.lean: remaining sub-sorries)
- Close M-side degenerate sorries (ExpressivenessGeneral.lean) together with c-gap-case
- Prove Cases III/IV of GHR93 Theorem 6 (ExpressivenessGeneral.lean)
- Complete assembly chain: rank-varying Thm 6, Props 6-7, Corollary 5
- Prove Reynolds Theorem 5 (US expressively complete over Prior)
- Formalize Reynolds Lemmas 6-14 (gap elimination)
- Close IntegerModel sorries and wire `no_gaps_discrete`
- Discharge `h_truth_corr` in Transfer.lean
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Dense completeness (separate path, unaffected)
- Closing `succ_cofinal` directly (bypassed via gap elimination)
- Frame-class completeness variants (Completeness.lean:254, 279, 288)
- Optimizing existing sorry-free infrastructure
- General-purpose tactic development (task 195 delivered the needed tactics)
- Preserving h_d_unique as standalone lemma (DEFINITIVELY abandoned)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| M-side continuation set definition diverges from N-side | H | L | Mirror N-side definition exactly. S_C^M = { t in [x, y] : cont_holds_M(a_n_M, y, t) }. The game ensures structural correspondence between M and N. |
| M-side infimum construction hits different case split than N-side | M | M | The 3-way case split (carrier-point min, carrier-point GLB, no carrier-point GLB) applies symmetrically to M. Case 2 should be unreachable for same reason (inf in S_C contradicts hp_not_in). If M-side has additional complications from different carrier structure, fall back to game-based construction. |
| Rank-r agreement between c=inf(S_C^M) and d=inf(S_C^N) hard to establish | H | M | Use the game at rank r: Spoiler picks c in M, Duplicator responds with some d' in N. Show d' = d by infimum properties. Both are infima of structurally isomorphic continuation sets; the game ensures continuation predicates transfer. If direct approach fails, use h_fwd with specific challenges to establish agreement formula-by-formula. |
| K^-(not-D) Since semantics lemma missing for inline proof | M | M | Round 15 research confirmed `stavi_temporal_truth_mu` for `std_snce` exists at EFGames.lean:877. Need to verify Since(T,D) false at d / true at game response. If direct lemma missing, prove from `stavi_temporal_truth_mu` definition (~20-30 lines). |
| Circularity in c-d agreement when c is constructed as infimum | M | L | No circularity: c is constructed from M-side data alone (S_C^M definition + infimum in M). d is constructed from N-side data alone. Agreement is then PROVED using the game, not assumed. |
| d_consistency_left/right restructuring invalidates Task 1.5 work | M | H | Task 1.5 currently routes d_consistency interior through h_d_unique. The restructuring replaces this routing with inline argument. Task 1.5's ~100 lines of framework (extracting formula/gp/boundary agreement from winning condition) will need adaptation but the pattern is preserved. Budget 30-50 lines for rewiring. |
| Same_order_type sigma (Task 1.6): still needs c<=e_n after restructuring | M | L | The inline Claim 1 proof in d_consistency_left/right establishes that the game response in [x', y'] that agrees with d at rank r is constrained to equal d. This gives c<=e_n through the same mechanism as h_d_unique did. The SOT proofs are structurally unchanged. |
| Same_order_type block-commented proofs: sorry fallbacks inside closers | M | CONFIRMED | Round 9 handoff: sigma proof line 3162 has `\| sorry)` as last alternative. After switching to `simp only [game_tuple]; split_ifs` (task 195 approach), this sorry should become unnecessary. If goals remain, use `extract_order` macro to close them. |
| Cases III/IV gap detection formula rank bounds don't match codebase | M | M | Follow GHR93 exactly: Case III uses left(B,D) with rank r+2, Case IV uses right(B,D) with rank r+3. Verify rank bounds with `stavi_depth` computation before proceeding. |
| Proposition 7 composition too complex (decomposition formula counting) | M | M | GHR93 Proposition 7 proof is explicit (p.26-27). If composition stalls, try direct Corollary 5 route via formula enumeration. |
| Model surgery (Lemma 12) case explosion exceeds budget | M | L | Report 26 estimates 350-450 lines. Modularize into per-case helpers; S cases are perfectly dual to U cases (use a shared template with direction parameter). |

## Full Sorry Inventory (Current -- after 14 implementation rounds + task 195 completion)

### ExpressivenessGeneral.lean (11 sorries -- unchanged from v16)
| Line | Context | Phase | v17 Status |
|------|---------|-------|------------|
| ~1614 | Case 3 infimum gap construction | 3 | Needs infimum_gap precondition assembly |
| ~1759 | `h_d_unique` interior case (t'<=d direction) | 1 | **WILL BE REMOVED** -- h_d_unique deleted, replaced by inline Claim 1 |
| ~1796 | `h_d_unique` interior case (d<=t', u<=d subcase) | 1 | **WILL BE REMOVED** -- h_d_unique deleted, replaced by inline Claim 1 |
| ~1804 | `h_pt_xc` degenerate gap | 1/3 | Possibly unreachable; may need SplitPointProps weakening |
| ~1821 | `h_pt_cy` degenerate gap | 1/3 | Same |
| ~1919 | n=0 gap case c construction | 1/3 | Needs dedicated n=0 argument |
| ~2055 | n=0 gap case (additional sorry) | 1/3 | Missed in v15; identified by Round 15 research |
| ~3177 | Case II sigma same_order_type (7 remaining grid goals) | 1 | BLOCKED on inline Claim 1 (needs c<=e_n) |
| ~3263 | Case II tau same_order_type | 1 | BLOCKED on inline Claim 1 (needs c<=e_n + sigma instantiation) |
| ~4246 | `ghr93_cases_III_IV` | 3 | Cases III/IV of Theorem 6 |
| ~4501 | `ghr93_forward_to_backward_rank_varying` | 4 | Rank-varying theorem |

### EFGames.lean (2 sorries, unchanged)
| Line | Identifier | Phase |
|------|-----------|-------|
| ~7688 | `ghr93_decomposition_implies_game` | 4 |
| ~8990 | `stavi_expressive_completeness` | 4 |

### IntegerModel.lean (3 sorries, unchanged)
| Line | Identifier | Phase |
|------|-----------|-------|
| 859 | `no_gaps_discrete` | 8 |
| 1135 | `cofinal_decomposition_k_equiv` | 7 |
| 1194 | `ordered_sum_of_good_bounded_is_good` | 7 |

**Total: 16 sorries** (11 ExpressivenessGeneral + 2 EFGames + 3 IntegerModel)

**v17 sorry trajectory**: The 2 h_d_unique sorries (lines ~1759, ~1796) will be DELETED when h_d_unique is removed. The inline Claim 1 proof in d_consistency_left/right may introduce 0-2 temporary sorries during development, but the target is net -2 sorries from Phase 1 restructuring (the h_d_unique sorries vanish, and the inline proof closes without new sorries). The d_consistency_left/right interior cases currently route through h_d_unique (Task 1.5, completed Round 6) and will need rewiring to the inline argument.

**Phase 1 progress (after 16 rounds)**: h_fwd_r1 rank bumped from r+1 to r+2 (Round 13). d in S_C and h_cofinal_failure_below_d proved (Round 14). h_d_unique DEFINITIVELY UNPROVABLE as stated (Round 16). Restructuring required: M-side infimum + inline Claim 1. Sigma SOT 18/25 goals closed (7 blocked on Claim 1 output); tau SOT not attempted.

## Implementation Phases (v17 -- Round 16 Restructuring Integrated)

**Critical path**: Phase 1 -> 3 -> 4 -> 5 -> 6A -> 6B -> succ_cofinal wiring -> bx_completeness

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2, 10 | -- (COMPLETE) |
| 2 | 1 | -- |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6A | 5 |
| 7 | 6B | 6A |
| 8 | 8 | 6B |
| 9 | 11 | 8 |
| -- | 7, 9 | DEPRIORITIZED (off critical path) |

Phases within the same wave can execute in parallel.

---

### Phase 1: D-Consistency via M-Side Infimum + Inline Claim 1 + Case II Restructure (GHR93 Claim 1) [IN PROGRESS]

**Goal**: Close the d-consistency interior sorries by (a) constructing the M-side continuation set S_C^M and c = inf(S_C^M), (b) removing h_d_unique and inlining the GHR93 Claim 1 argument directly in d_consistency_left/right using both infima + K^-(not-D) + rank-(r+2) game, (c) closing same_order_type sigma/tau using task 195 EFGameTactics, and (d) closing the IH h_fwd_r1 sorry via decoupled round count + universal h_r1.

**Root cause (definitively resolved by report 35 + Round 16 handoff)**: GHR93 Claim 1 proves that the game response to c (M-side infimum) equals d-bar (N-side infimum). The current code sets d = x' (placeholder), making d_consistency unprovable. With d = d-bar, Claim 1 gives d_consistency directly. HOWEVER, h_d_unique as a standalone lemma is unprovable because it applies to GENERIC elements, not game responses. The fix is to construct c = inf(S_C^M) and inline the Claim 1 argument where the game is in scope.

**v17 architectural change (v18 corrected)**: Remove h_d_unique (lines ~1741-1845). Replace with:
1. Cross-structure M-side continuation set S_C^M using N-side anchor a_bwd(n). NO M-side backward selections needed — GHR93 defines C = X_{(alpha_n, y')} from N and evaluates in M.
2. `cont_holds_M(u)` = ∀ A ≤ r, (A holds on (a_bwd(n), y') in N) → A(u in M). Same formulas, different structure.
3. S_C^M = { t ∈ [x, y] : ∀ mu u in M, t < u < y → cont_holds_M(u) }. c = inf(S_C^M).
4. c↔d rank-r agreement from formula transfer: cont_holds_M at mu above c gives A(mu in M) for each continuation A. The game transfers this to N-side truth at corresponding points.
5. Inline GHR93 Claim 1 in d_consistency_left/right using the two-direction argument below.

**Why this works (GHR93 Claim 1 structure, per report 22 Steps 2.2-2.3)**:

**Direction 1: d ≤ t (infimum ≤ game response, GHR93 Step 2.3)**:
Assume t < d for contradiction. Then t ∉ S_C^N (since S_C^N = {s ≥ d}). So ∃ mu u with t < u ≤ d, ¬cont_holds_N(u). Extract formula A ≤ r with A on (a_bwd(n), y') in N but ¬A(u in N). Play the rank-r game's Round 2: Spoiler picks carrier point p_u from N. Duplicator responds with b from M. Formula agreement: ¬A(u) → ¬A(extendPoint(b) in M). Order: u > t ↔ extendPoint(b) > c, so extendPoint(b) > c. But c = inf(S_C^M) and extendPoint(b) > c, so extendPoint(b) ∈ S_C^M (upward-closed), giving cont_holds_M(extendPoint(b)). Since A is a continuation formula: A(extendPoint(b) in M) = TRUE. Contradiction with ¬A(extendPoint(b) in M).

**Direction 2: t ≤ d (game response ≤ infimum, GHR93 Step 2.2)**:
Assume t > d for contradiction. This direction requires C' = ¬C ∨ K⁻(¬C) as a rank-(r+2) formula for game transfer. C is the continuation predicate. Since StaviFormula lacks conjunction, materialize C' via the pigeonhole: extract D (single formula, depth ≤ r) from M-side pigeonhole failing cofinally below c. Construct K⁻(¬D) = neg(std_snce(base(.bot.imp.bot), D)) of depth ≤ r+2. K⁻(¬D)(c in M) = TRUE (D fails cofinally below c from pigeonhole). Transfer via h_fwd_r1 (rank r+2 game): K⁻(¬D)(rank_embed(c)) ↔ K⁻(¬D)(t_r2). So K⁻(¬D)(t_r2) = TRUE in N at rank r+2. Analyze: K⁻(¬D)(t_r2) = TRUE means Since(⊤, D)(t_r2) = FALSE, i.e., D fails cofinally below t_r2. But t_r2 corresponds to a point ≥ d in N (from Direction 1 applied at rank r+2). Since d ∈ S_C^N: D holds at all mu-points in (d, y'). If t_r2 > rank_embed(d): Since(⊤, D)(t_r2) = TRUE with witness rank_embed(d). Contradiction. So t_r2 ≤ rank_embed(d). Combined with t_r2 ≥ rank_embed(d) (from Direction 1 at rank r+2): t_r2 = rank_embed(d). The rank-(r+2) winning condition with response rank_embed(d) projects to rank-r winning condition with response d via rank_embed_stavi_truth_mu (formula), rank_embed_le (order), and carrier-point invariance (Round 2).

**IMPORTANT: Direction 2 uses a SEPARATE D from M-side pigeonhole, not N-side.** D_M fails cofinally below c in M but may not equal the N-side D_N. This is fine — we only need K⁻(¬D_M)(c) = TRUE for the game transfer. The N-side analysis uses d ∈ S_C^N (D_M as a continuation formula holds above d in N) to show Since(⊤, D_M) is TRUE at points above d.

**CAUTION on Direction 2 projection**: h_fwd and h_fwd_r1 are independent game instances (confirmed by game API research). The rank-(r+2) response t_r2 ≠ rank_embed(t) in general. The proof shows t_r2 = rank_embed(d), then constructs a rank-r winning condition from the rank-(r+2) one. This works because: (a) formula agreement at r+2 implies agreement at r via rank_embed_stavi_truth_mu, (b) order is preserved by rank_embed_le, (c) Round 2 uses carrier points which are rank-independent. The rank-r game response t is then shown to equal d because the constructed rank-r winning condition with response d satisfies the same existential as t — and d_consistency_left only needs EXISTENCE of a response equal to d, not that t specifically equals d.

**Tasks**:
- [x] **Task 1.1**: Construct actual infimum at `obtain_split_point_props` (~100-150 lines). *(deviation: altered -- Fixed buggy 2-way case split with correct 3-way split: (1) carrier-point minimum d=extendPoint p (unchanged), (2) carrier-point GLB p not in S_C d=extendPoint p (new, fully proved using gap no_sup axiom), (3) no carrier-point GLB (sorry'd, deferred to Phase 3 c-gap-case which wires infimum_gap_r_definable). Net -2 sorries: removed 3 buggy sorries, added 1 clean sorry for Case 3.)*
- [x] **Task 1.2**: Change `SplitPointProps` from `hd_eq_an` to `hd_le_an` if not already done (~10-20 lines). *(completed -- already done in prior session; line 1298 has `hd_le_an`)*
- [x] **Task 1.3**: Fix Case I sites (~20-40 lines, 2 sites). *(completed -- all live hd_eq_an references are in the OLD CASE II PROOF block comment; Case I uses hd_le_an correctly)*
- [ ] **Task 1.4**: Formula materialization + inline Claim 1 (v20: ROOT CAUSE FIX per report 36).
  **ROOT CAUSE (report 36)**: GHR93's C = X_{(a_n, y')} is a SINGLE formula (Definition 8.8: finite disjunction of point-type conjunctions). Our cont_holds is a second-order predicate. This deviation forced the pigeonhole (~360 lines) and all carrier-point/gap edge cases. FIX: materialize C as a StaviFormula, then Claim 1 follows GHR93 verbatim.
  **Prior infrastructure (retained)**: Steps 1.4a-g are PRESERVED — cross-structure definitions, c_inf = inf(S_C^M), suffices restructured to h_fwd_r1. These remain correct and useful. The formula materialization REPLACES steps 1.4h-i (the pigeonhole-based K⁻ pipeline that was blocked).
  - [x] **Step 1.4a-c**: Cross-structure definitions + c_inf construction (~175 lines). *(completed, sorry-free except Case 3 gap)*
  - [x] **Step 1.4d**: Cross-structure pigeonhole (~180 lines). *(completed, sorry-free — may become unnecessary for Claim 1 but useful for infimum_gap_r_definable)*
  - [x] **Step 1.4e-g**: Suffices restructured + projections + Direction 2 carrier-point (~235 lines). *(completed, Direction 2 carrier-point sorry-free, formula agreement sorry-free)*
  - [ ] **Step 1.4h**: Close 2 interior sorries (lines ~2577, ~2732) via K⁻(¬D_M) with vacuous Since witness. *(deviation: altered -- Sorry 2 (Direction 2 gap case, line ~2732) CLOSED via Dedekind cut complement argument (170 lines). Sorry 1 (Direction 1 interior, line ~2580) remains: pigeonhole h_cofinal_failure precondition fails when c_inf is carrier point with cont_holds_cross at c_inf.)*
  
    **KEY INSIGHT (Round 23)**: On ALL non-sorry'd paths, d = extendPoint p (carrier point). Case 3 of the d construction (d is gap) is sorry'd for Phase 3. Therefore rank_embed(d) is ALWAYS a mu-point on live paths. This resolves the adjacent-gap blocker.
    
    **Path A (gap equivalence) RULED OUT**: Report 37 proves the lemma FALSE — atoms distinguish points from gaps.
    
    **Path B (formula materialization) NOT NEEDED**: Since d is always a carrier point, the K⁻(¬D_M) argument works with the VACUOUS Since witness:
    1. Pigeonhole → D_M (depth ≤ r, cofinal failure below c_inf in M)
    2. neg(Since(⊤, D_M))(c_inf in M) = TRUE (cofinal D_M-failure below c_inf)
    3. Transfer via h_fwd_r1: neg(Since(⊤, D_M))(r2_resp in N at r+2) = TRUE
    4. Since(⊤, D_M)(r2_resp) with witness s = rank_embed(d):
       - rank_embed(d) < r2_resp ✓ (from hypothesis)
       - mu_holds(rank_embed(d)) ✓ (d is carrier point on live paths)
       - ⊤(rank_embed(d)) = TRUE ✓ (tautology at carrier points)
       - ∀ mu u ∈ (rank_embed(d), r2_resp), D_M(u) = vacuously TRUE ✓ (no mu-points in interval when r2_resp is adjacent gap; if mu-points exist, D_M holds from cont_holds above d)
    5. Contradiction: Since = TRUE but neg(Since) = TRUE
    
    **Sorry 2 (Direction 2 gap case, r2_resp < rank_embed(d))**: When d is a carrier point, rank_embed(d) is a mu-point ABOVE r2_resp. h_cont_transfer can use rank_embed(d) as the mu-point for the cont_holds transfer. OR: since d is a carrier point, the carrier-point case of Direction 2 already covers it — the gap case only arises when r2_resp is a gap, but d being a carrier point means rank_embed(d) is available for contradiction.
  - [ ] **Step 1.4k**: Remove h_d_unique + rewire (~-100 lines). Delete h_d_unique, remove from d_consistency_left/right signatures. h_d_unique's 2 sorries become orphaned.
  - [ ] **Step 1.4l**: d_consistency_right (mirror of left). Share infrastructure with left variant.
- [x] **Task 1.5**: Close `d_consistency_left` and `d_consistency_right` interior sorries (~20-40 lines). *(deviation: altered -- Round 6 resolved via h_d_unique parameter. Interior cases now extract formula/gp/boundary agreement from winning condition and apply h_d_unique. ~50 lines added per theorem. WILL NEED REWIRING in Task 1.4k to use inline Claim 1 instead of h_d_unique.)*
- [ ] **Task 1.6**: Restructure Case II winning condition assembly. *(Round 5 implemented e_n construction via forward game + sigma/tau split. Round 6 decomposed 2 monolithic sorries into 6 targeted: same_order_type, gap_point_agreement, formula_agreement x sigma/tau. Round 7 closed 4 of 6 (gap_point + formula for both sub-cases). Remaining: 2 same_order_type sorries NOW UNBLOCKED by task 195.)*
  - [x] e_n construction via forward game round 2 (h_fwd_n1 + p_n challenge) -- Round 5
  - [x] sigma/tau case split on b_sp <= c vs b_sp > c -- Round 5
  - [x] sigma gap_point_agreement -- Round 7 (5-way index split + tau auxiliary)
  - [x] sigma formula_agreement -- Round 7
  - [x] tau gap_point_agreement -- Round 7
  - [x] tau formula_agreement -- Round 7
  - [ ] **sigma same_order_type** (line ~3059) -- PARTIALLY CLOSED (Round 10: 18/25 goals via task 195 tactics, 7 remaining need c<=e_n from inline Claim 1). Implementation steps for remaining 7 goals:
    1. Uncomment the block-commented proof at lines 3060-3162
    2. Replace `delta game_tuple; split_ifs <;> simp_all <;>` with `same_order_type_grid <;>` (or equivalently `intro i j; simp only [game_tuple]; split_ifs <;>`)
    3. Use `order_refl` to close 3 diagonal goals (x-x, b-b, y-y)
    4. Use `extract_order` and `pivot_chain_order'` for cross-boundary cells
    5. The sigma case has `hord_sig` available -- extract `sig_x_b`, `sig_b_d`, `sig_x_d` from it via `simp_game_tuple`
    6. Remove the `| sorry)` fallback at line 3162 -- all goals should close with task 195 tactics
    7. Keep `hab_n` (the a_bwd(n) = extendPoint p_n fact) available -- it is NOT consumed by the new approach (no `simp_all`)
  - [ ] **tau same_order_type** (line ~3263) -- UNBLOCKED by task 195. Implementation steps:
    1. Uncomment the block-commented proof at lines 3264-3419
    2. FIRST: instantiate `props.sigma` with trivial selections (e.g., all d) to obtain a sigma winning condition, then extract `(x' < d iff x < c)` at positions (0, n+2). This is the same technique as lines ~3174-3185.
    3. Replace `delta game_tuple; split_ifs <;> simp_all <;>` with `same_order_type_grid <;>`
    4. Use `order_refl` for diagonal goals
    5. Use `extract_order` and `pivot_chain_order'` for cross-boundary cells, using both the extracted sigma ordering and `hord_tau` orderings
    6. Remove sorry fallbacks
- [x] **Task 1.7**: Close IH h_fwd_r1 sorry at line ~3836. *(deviation: altered -- Created ghr93_forward_to_backward_core with decoupled rounds_r1 and h_r1_univ universal over endpoints; changed ghr93_forward_to_backward API to take h_r1_univ; 83 lines added, 39 removed; used h_enough : 1+3n <= rounds_r1 instead of report 18's 4+3n constraint)*
- [ ] **Task 1.8**: Verify `lean_verify d_consistency_left` and `lean_verify d_consistency_right` show no `sorryAx`. Verify `lake build` passes.

**Timing**: 14-22 hours (revised up from 10-18; M-side infimum construction adds ~150-200 lines, inline Claim 1 adds ~200-300 lines, rewiring adds ~30-50 lines, h_d_unique removal saves ~100 lines; net +280-450 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- M-side continuation set, c=inf(S_C^M), inline Claim 1 in d_consistency, remove h_d_unique, same_order_type sigma/tau fix, pigeonhole_definable_formula_below_d/c

**Verification**:
- `lean_verify d_consistency_left` shows no `sorryAx`
- `lean_verify d_consistency_right` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward` shows no `sorryAx`
- `lake build` passes

---

### Phase 2: Lemma 9 Gap Detection Correctness [COMPLETED]

**Goal**: Close all remaining sub-sorries in `left_formula_gap_detection` and `right_formula_gap_detection` (EFGames.lean), completing GHR93 Lemma 9.

**Status**: COMPLETE. All gap detection theorems proved. `std_untl_gap_detection` and `std_snce_gap_detection` deleted (provably false). Affected cases proved directly using compound decomposition.

**Timing**: 30+ hours (actual)

**Depends on**: none

---

### Phase 3: c-Gap-Case + M-Side Degenerate + Cases III/IV (GHR93 Theorem 6) [NOT STARTED]

**Goal**: Close the c-gap-case sorry (line ~1614), the M-side degenerate sorries (lines ~1804, ~1821), the n=0 gap cases (lines ~1919, ~2055), and prove Cases III and IV of GHR93 Theorem 6 (line ~4246).

**GHR93 Reference**: Section 8, Theorem 6 proof, Cases III and IV (pp.117-119).
- **Case III**: alpha_n is a gap defined on the left by D. Use left(B,D) as the detection formula. Apply Lemma 9 left to find gap e_n in (t,d)_r.
- **Case IV**: alpha_n is a gap NOT left-defined. Use right(B,D) as the detection formula. Apply Lemma 9 right to find gap e_n in (t,u).

**Sub-tasks for c-gap-case (line ~1614)**: When d is a gap in `obtain_split_point_props`, use Lemma 9 to transfer gap detection from N-side to M-side. The gap gamma in N has a defining formula D; apply `left_formula_gap_detection` or `right_formula_gap_detection` to find the corresponding c in M_r. **v17 note**: This now applies to BOTH the N-side (d) and M-side (c) infimum constructions. If c is also a gap, the same Lemma 9 mechanism transfers.

**Sub-tasks for M-side degenerate (lines ~1804, ~1821)**: Either prove these cases are unreachable (degenerate interval at a gap contains no points, contradiction with some other hypothesis) or restructure `SplitPointProps` to make `h_pt_xc`/`h_pt_cy` conditional: `x < c -> exists p, inClosedInterval x c (extendPoint p)`. Update 5 downstream usage sites with appropriate guards.

**Sub-tasks for n=0 gap cases (lines ~1919, ~2055)**: When n=0, the backward game has 0 rounds and cannot find c via the standard mechanism. Use Lemma 9 gap detection to transfer the gap from N to M.

**Tasks**:
- [ ] **Task 3.1**: Investigate whether degenerate gap cases (lines ~1804, ~1821) are unreachable. If so, prove by contradiction. If not, restructure `SplitPointProps.h_pt_xc` to conditional form `x < c -> exists p, ...` and `SplitPointProps.h_pt_cy` similarly (~15-20 lines changed in the structure).
- [ ] **Task 3.2**: If conditional restructure needed: update 5 downstream usage sites of h_pt_xc/h_pt_cy with appropriate `x < c` / `c < y` proofs (~30-50 lines). Case I: follows from split hypothesis + boundary correspondence. Case II: c is a point (prove witness trivially).
- [ ] **Task 3.3**: Close c construction gap case (line ~1614, ~50-80 lines). Use `left_formula_gap_detection` or `right_formula_gap_detection` to find c in M_r when d is a gap. Apply the defining formula D and the D-between condition to invoke Lemma 9.
- [ ] **Task 3.4**: Close n=0 gap cases (lines ~1919, ~2055, ~60-100 lines). Apply Lemma 9 gap detection to transfer gap from N to M in the degenerate n=0 case.
- [ ] **Task 3.5**: Split `ghr93_cases_III_IV` (line ~4246) into `ghr93_case_III` and `ghr93_case_IV` (~20 lines dispatch).
- [ ] **Task 3.6**: Prove `ghr93_case_III` -- left-defined gap (~120-180 lines). Steps:
  - Extract D from left-definability of alpha_n
  - Define B = X_{alpha_n}, delta = left(B, D) (rank r+2)
  - Show Nr |= U(delta, A)(alpha_{n-1}) with alpha_n as witness
  - Define d', g' in N, d, g in M similarly
  - Derive sub-interval strategy via Claim 2 pattern
  - Apply Lemma 9 left (`left_formula_gap_detection`) to get gap e_n in (t,d)_r
  - Verify winning condition using task 195 tactics (`same_order_type_grid`, `order_refl`, `extract_order`)
- [ ] **Task 3.7**: Prove `ghr93_case_IV` -- gap not left-defined (~120-180 lines). Steps:
  - Extract D from right-definability; verify NOT left-definable
  - Define B = X_{alpha_n}, delta = A /\ not-D /\ U(right(B,D), A) (rank r+3)
  - Apply `right_formula_gap_detection` to get gap e_n in (t,u)
  - Verify winning condition using task 195 tactics
- [ ] **Task 3.8**: Verify `ghr93_inductive_step` assembly compiles. Run `lake build`.

**Timing**: 6-10 hours

**Depends on**: 1 (d-consistency for SplitPointProps), 2 (Lemma 9 for Cases III/IV and c-gap-case)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close lines ~1614, ~1804, ~1821, ~1919, ~2055, ~4246
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- possible helper lemmas

**Verification**:
- `lean_verify obtain_split_point_props` shows no `sorryAx`
- `lean_verify ghr93_inductive_step` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward` shows no `sorryAx`
- `lake build` passes

---

### Phase 4: Assembly Chain -- Rank-Varying Thm 6, Lemma 11 Backward, Props 6-7, Corollary 5 [NOT STARTED]

**Goal**: Complete the assembly chain from uniform-rank Theorem 6 through to `stavi_expressive_completeness` (GHR93 Corollary 5, EFGames.lean:~8990).

**GHR93 Reference**:
- Theorem 6 rank-varying: (*)_n with forward rank r+4n, backward rank r (p.113)
- Proposition 6: Formula agreement at rank r+4n+1 implies half-line game wins (p.113-114)
- Proposition 7: Composition of interval strategies into full EF game (p.114-115, Definition 8.9)
- Corollary 5: From Propositions 5, 6, 7 (p.115)

**Tasks**:
- [ ] **Task 4.1**: Prove `ghr93_forward_to_backward_rank_varying` (line ~4501, ~80-150 lines).
  - Apply uniform-rank Theorem 6 at rank r+4n
  - Use `ghr93_duplicator_wins_round_mono` (Lemma 10) to restrict to rank r
  - Need `rank_embed` properties: M_r subset of M_{r+4n}, monotone, preserves gap/point
- [ ] **Task 4.2**: Prove `ghr93_decomposition_implies_game` -- Lemma 11 backward (line ~7688, ~80-120 lines).
  - From decomposition agreement, construct Duplicator's winning strategy for G_{n;r}
  - Round 1: decomposition formula witnesses ARE the strategy
  - Round 2: point-matching clause (b) responds to point challenges
- [ ] **Task 4.3**: Prove Proposition 6 (entirely new, ~100-150 lines).
  - Statement: formula agreement at rank r+4n+1 implies half-line game wins
  - Define C_i chain (Definition 8.8), rank(C_0) <= r+4n+1
  - Extract matching points from C_i chain for gap cases
- [ ] **Task 4.4**: Prove Proposition 7 (entirely new, ~150-250 lines).
  - Composition of interval strategies into full EF game with growth functions f, g
  - Proof by induction on n using Lemma 10, Lemma 11 backward, Theorem 6 rank-varying
- [ ] **Task 4.5**: Prove Corollary 5 = close `stavi_expressive_completeness` (line ~8990, ~80-120 lines).
  - Compose Propositions 5, 6, 7
  - Expressive completeness: partition temporal types, each consistent with phi implies phi
- [ ] **Task 4.6**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`. Run `lake build`.

**Timing**: 8-14 hours

**Depends on**: 3 (Theorem 6 fully proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- rank-varying Thm 6, Props 6-7
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Lemma 11 backward, Corollary 5

**Verification**:
- `lean_verify ghr93_forward_to_backward_rank_varying` shows no `sorryAx`
- `lean_verify ghr93_decomposition_implies_game` shows no `sorryAx`
- `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- `lake build` passes

---

### Phase 5: Reynolds Theorem 5 -- US Expressive Completeness over Prior Structures [NOT STARTED]

**Goal**: Prove that {U,S} alone is expressively complete for Prior structures, by composing Corollary 5 (Stavi expressive completeness) with `flatten_stavi_correct`.

**Tasks**:
- [ ] **Task 5.1**: Define `US_expressively_complete_over_prior` theorem (~60-100 lines).
  - From `stavi_expressive_completeness`, get Stavi formula B equivalent to phi
  - From `flatten_stavi_correct` with Prior-U/Prior-S hypotheses, get US formula A equivalent to B
  - Compose
- [ ] **Task 5.2**: Prove bridge lemma between `stavi_temporal_truth` and `temporal_truth` (~30-50 lines).
- [ ] **Task 5.3**: Verify `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`. Run `lake build`.

**Timing**: 2-3 hours

**Depends on**: 4 (Corollary 5 = stavi_expressive_completeness)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or new `Theorem5.lean`

**Verification**:
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build` passes

---

### Phase 6A: Reynolds Gap Elimination Lemmas 6-11 + Infrastructure [NOT STARTED]

**Goal**: Formalize Reynolds 1994 Section 7, Lemmas 6-11 and supporting infrastructure. This establishes the structural theory of "bad intervals" in Prior structures.

**Tasks**:
- [ ] **Task 6A.1**: Create `GapElimination.lean`. Define infrastructure (~100-150 lines): `IsPriorStructure` predicate, rho formula encoding, maximal_interval predicate, bad_point/bad_interval definitions.
- [ ] **Task 6A.2**: Prove Lemma 6 -- R exists (~100-150 lines). Apply `US_expressively_complete_over_prior` to rho(x).
- [ ] **Task 6A.3**: Prove Lemma 7 -- R-interval openness (~80-120 lines).
- [ ] **Task 6A.4**: Prove Lemma 8 -- no first/last class (~60-80 lines).
- [ ] **Task 6A.5**: Prove Lemma 9-Reynolds -- elementary equivalence of classes (~150-200 lines).
- [ ] **Task 6A.6**: Prove Lemma 10 -- bad interval structure (~80-100 lines).
- [ ] **Task 6A.7**: Prove Lemma 11-Reynolds -- formula propagation (~60-80 lines).
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

**Tasks**:
- [ ] **Task 6B.1**: Define model surgery construction N = M restricted to Q- union I union Q+ (~80-100 lines).
- [ ] **Task 6B.2**: Prove Lemma 12 forward direction for U(A,B) (~120-150 lines, 7 sub-cases).
- [ ] **Task 6B.3**: Prove Lemma 12 backward direction for U(A,B) (~100-130 lines, 6 sub-cases).
- [ ] **Task 6B.4**: Prove Lemma 12 for S(A,B) (~30-50 lines, dual of U).
- [ ] **Task 6B.5**: Prove Lemma 12 for U'(A,B) and S'(A,B) (~60-100 lines).
- [ ] **Task 6B.6**: Prove Lemma 12 base cases (atoms, boolean) (~20-30 lines).
- [ ] **Task 6B.7**: Prove Lemma 13 -- no bad points (~60-80 lines). Contradiction from R holding in I in N.
- [ ] **Task 6B.8**: Prove Theorem 14 assembly (~10-30 lines).
- [ ] **Task 6B.9**: Verify `lean_verify gap_elimination_theorem_14` shows no `sorryAx`. Run `lake build`.

**Timing**: 6-8 hours

**Depends on**: 6A (Lemmas 6-11)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- continue from Phase 6A

**Verification**:
- `lean_verify gap_elimination_theorem_14` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: IntegerModel.lean Helper Sorries [DEPRIORITIZED]

**Goal**: Close `cofinal_decomposition_k_equiv` (line 1135) and `ordered_sum_of_good_bounded_is_good` (line 1194).

**OFF CRITICAL PATH** (report 28): `very_good_implies_good` is orphaned infrastructure -- never used on the path to sorry-free `bx_completeness`. `chronicle_is_good` is already sorry-free via direct OrderIso.

**Tasks**: DEFERRED -- focus on Phases 1-6B (critical path).

**Timing**: 4-6 hours

**Depends on**: none

---

### Phase 8: Wire no_gaps_discrete [NOT STARTED]

**Goal**: Replace `no_gaps_discrete` sorry (IntegerModel.lean:859) with call to `gap_elimination_theorem_14`.

**Tasks**:
- [ ] **Task 8.1**: Replace `no_gaps_discrete` sorry with `gap_elimination_theorem_14` call (~20-40 lines).
- [ ] **Task 8.2**: Verify `lean_verify no_gaps_discrete` shows no `sorryAx`. Run `lake build`.

**Timing**: 1-2 hours

**Depends on**: 6B (gap_elimination_theorem_14)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

**Verification**:
- `lean_verify no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Rewrite chronicle_is_good and Remove IsSuccArchimedean [DEPRIORITIZED]

**Goal**: Rewrite `chronicle_is_good` to use gap-elimination-based argument. Remove `IsSuccArchimedean` dependency.

**OFF CRITICAL PATH**: `chronicle_is_good` is already sorry-free via direct OrderIso. This phase is only needed if the OrderIso approach proves insufficient downstream.

**Tasks**: DEFERRED.

**Timing**: 3-5 hours

**Depends on**: 7, 8

---

### Phase 10: Discharge h_truth_corr [COMPLETED]

**Goal**: Eliminate the h_truth_corr sorry at Transfer.lean by delegating `countermodel_discrete` to `dd_countermodel_chronicle_discrete`.

**Status**: COMPLETE. Transfer.lean sorry eliminated, -86 lines net.

**Timing**: 2 hours (actual)

**Depends on**: none

---

### Phase 11: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify entire pipeline is sorry-free with no custom axioms.

**Tasks**:
- [ ] **Task 11.1**: Run `lean_verify countermodel_discrete` -- should show only propext, Classical.choice, Quot.sound.
- [ ] **Task 11.2**: Run `lean_verify bx_completeness` -- should show only propext, Classical.choice, Quot.sound.
- [ ] **Task 11.3**: Run `lean_verify stavi_expressive_completeness` -- same.
- [ ] **Task 11.4**: Trace and fix any unexpected `sorryAx`.
- [ ] **Task 11.5**: Verify no `axiom` declarations: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/`.
- [ ] **Task 11.6**: Run full `lake build`. Confirm zero errors.
- [ ] **Task 11.7**: Update file-level documentation.

**Timing**: 1-2 hours

**Depends on**: 8

**Files to modify**:
- Potentially any file in `Theories/Bimodal/Metalogic/WeakCanonical/` for stray sorry cleanup

**Verification**:
- `#print axioms bx_completeness` shows: propext, Classical.choice, Quot.sound (NO sorryAx)
- `#print axioms stavi_expressive_completeness` shows: propext, Classical.choice, Quot.sound
- `#print axioms US_expressively_complete_over_prior` shows: propext, Classical.choice, Quot.sound
- `#print axioms gap_elimination_theorem_14` shows: propext, Classical.choice, Quot.sound
- `lake build` passes with zero errors
- No `axiom` declarations in WeakCanonical directory
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ | grep -v "^.*--.*sorry"` returns empty

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound`
- [ ] `#print axioms countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` shows no `sorryAx`
- [ ] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `#print axioms gap_elimination_theorem_14` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` returns empty
- [ ] No `IsSuccArchimedean` in theorem statements on critical path
- [ ] No new `sorry` introduced on the critical path

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Lemma 9 (COMPLETE), Lemma 11 backward, stavi_expressive_completeness, game_tuple_*_eq lemmas (moved from ExpressivenessGeneral), pivot_chain_order/rev (moved)
- `Theories/Bimodal/Automation/EFGameTactics.lean` -- Task 195 output: simp_game_tuple, same_order_type_grid, order_refl, extract_order, pivot_chain_order'/rev', gap_point_agreement_of_cases, formula_agreement_of_cases
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- M-side continuation set S_C^M, c=inf(S_C^M), inline Claim 1 in d_consistency, h_d_unique REMOVED, Case II restructure, M-side degenerate, c-gap-case, Cases III/IV, rank-varying Thm 6, Props 6-7
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW) -- Reynolds Lemmas 6-13, Theorem 14
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or `Theorem5.lean` -- Reynolds Theorem 5
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- no_gaps_discrete
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- h_truth_corr (COMPLETE)
- `specs/155_reynolds_pipeline_activation/plans/27_reynolds-pipeline-plan.md` -- This plan (v17)

## Rollback/Contingency

1. **M-side infimum construction (Task 1.4c)**: If the M-side 3-way case split diverges from N-side due to different carrier structure, try a game-based approach: play the game with c as Spoiler's challenge, get d' as response, show d' = d by infimum uniqueness. This avoids constructing c as an explicit infimum. Alternatively, if the M-side continuation set has different structural properties, introduce a helper lemma that maps N-side case analysis to M-side via the game's order-preserving property.
2. **Rank-r agreement c-d (Task 1.4 overall)**: If establishing rank-r agreement between c=inf(S_C^M) and d=inf(S_C^N) is difficult via direct game argument, try: (a) show continuation predicates are rank-r definable (they are -- from pigeonhole_definable_formula), (b) show infima of rank-r-definable sets must agree if the game at rank r relates M and N, (c) use rank_embed_stavi_truth_mu for the transfer. This is the "infimum correspondence lemma" approach from the task context's Finding 4.
3. **K^-(not-D) Since semantics (Tasks 1.4f-g)**: If direct Since semantics lemmas are missing, prove from `stavi_temporal_truth_mu` definition. The key facts are: Since(T,D)(d) requires exists s < d with D(s) and T on (s,d), and D fails cofinally below d (from pigeonhole). These are combinable in ~20-30 lines.
4. **d_consistency rewiring (Task 1.4k)**: If Task 1.5's ~100 lines of framework are tightly coupled to h_d_unique's specific output format, consider a compatibility wrapper: define a local `h_d_unique_inline` that has the same type as h_d_unique but is proved inline using the Claim 1 argument. This preserves all downstream code. Cost: ~10 extra lines but zero refactoring risk.
5. **Same_order_type sigma (Task 1.6)**: If `same_order_type_grid` approach still leaves unresolved goals after uncommenting: use `extract_order` macro for individual cell extraction, or fall back to fully manual `intro i j; delta game_tuple; split_ifs` with per-cell closers (verbose but reliable, ~200 lines).
6. **Same_order_type tau (Task 1.6)**: If sigma instantiation for `(x' < d iff x < c)` is hard to extract: try using the forward game ordering `hord_fwd` at positions (0, n+1) which relates x to a_M(n) and x' to a_N(n). Since a_M(n)=c by construction, this gives `(x' < a_N(n) iff x < c)`. Then separately show `a_N(n) = d` or use a weaker ordering relationship.
7. **Cases III/IV (Phase 3)**: If the case-specific construction exceeds budget, implement Case III first (simpler: left-defined gap, rank r+2) and leave Case IV for a follow-up. Task 195 tactics assist the winning condition assembly.
8. **Assembly (Phase 4)**: If Prop 7 composition is too complex, try direct Corollary 5 route via formula type enumeration.
9. **Gap elimination (Phases 6A-6B)**: Lemma 12's 14 cases can be individually modularized. S cases are perfectly dual to U cases.
10. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck on any phase, mark [BLOCKED] and request additional research. The critical directive prohibits shortcuts.
