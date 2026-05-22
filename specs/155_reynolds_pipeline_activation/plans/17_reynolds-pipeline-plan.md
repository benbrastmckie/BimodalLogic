# Implementation Plan: Reynolds Pipeline Activation (v14)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IMPLEMENTING]
- **Effort**: 38-58 hours (revised down from 44-66; Phase 1 same_order_type unblocked by task 195, -4h estimated)
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
  - handoffs/phase-1-handoff-20260522T160731Z.md (sorry inventory, Task 1.2/1.3 confirmed complete, 5 proposed solutions for Task 1.7)
  - handoffs/phase-1-handoff-20260522T210000Z.md (Round 8: same_order_type proof architecture verified via multi_attempt, simp_all compilation blocker identified)
  - handoffs/phase-1-handoff-20260522T220000Z.md (Round 9: simp_all rewrite analysis, sigma sorry fallback found, tau needs sigma instantiation for (x' < d iff x < c))
- **Artifacts**: plans/17_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [23_tactic-needs-beyond-195.md, 27_post-195-assessment.md]

---

## CRITICAL DIRECTIVE: FULL GHR93 + REYNOLDS, NO SHORTCUTS

The plan formalizes the complete GHR93 game-theoretic proof of expressive completeness of {U,S,U',S'} over ALL linear temporal structures, then uses Reynolds gap elimination to show {U,S} suffices for Prior structures and close `succ_cofinal`. No `axiom` declarations, no shortcuts.

**Key finding (report 32)**: The omega-chain construction CAN produce gaps (Z+Z models). `succ_cofinal` cannot be closed from temporal axioms or construction internals alone (Prior-UZ guard is vacuous in discrete case, report 33). The FULL Reynolds gap elimination (Theorem 14) is the only viable path. The EFGames/ExpressivenessGeneral infrastructure IS the Reynolds pipeline.

**Phase 1 resolution (report 35)**: Report 29 is correct; handoff-b is wrong. BOTH infimum redefinition AND rank embedding are needed. The current code sets d = x' (placeholder, not the actual infimum). With d = d-bar (the true infimum), Claim 1 at rank r+1 proves d_consistency. Case II must be restructured to construct e_n fresh via U(B,A) transfer. All required infrastructure (rank_embed, infimum_gap, h_fwd_r1 propagation) is already sorry-free.

**Task 195 completion (v14)**: Task 195 created `EFGameTactics.lean` with `simp_game_tuple`, `same_order_type_grid`, `order_refl`, `extract_order`, `pivot_chain_order'`/`pivot_chain_order_rev'`, `gap_point_agreement_of_cases`, and `formula_agreement_of_cases`. It also moved `game_tuple_*_eq` and `pivot_chain_order`/`pivot_chain_order_rev` from ExpressivenessGeneral.lean to EFGames.lean as public declarations. These tactics directly resolve the compilation blocker for Phase 1 Task 1.6 same_order_type (sigma and tau).

---

## Overview (v14)

This plan (v14) revises v13 based on the completion of task 195 (EF game automation tactics). The key change: the 2 same_order_type sorries at lines 3059 and 3263, which were BLOCKED since Round 8, are now UNBLOCKED. Task 195's `same_order_type_grid` macro provides `intro i j; simp only [game_tuple]; split_ifs` (avoiding the `simp_all` hypothesis-rewriting that caused the compilation blocker), and the `order_refl`/`extract_order` macros assist with grid cell closing. The block-commented proofs at lines 3060-3162 (sigma) and 3264-3419 (tau) contain verified-correct proof architecture that must be uncommented and fixed to use the new tactics.

The critical path remains:

```
Phase 1 (d-consistency: same_order_type fix + h_d_unique)
  -> Phase 3 (Cases III/IV) -> Phase 4 (Assembly + Corollary 5)
    -> Phase 5 (Reynolds Thm 5) -> Phases 6A-6B (gap elimination)
      -> succ_cofinal -> bx_completeness
```

Phase 1 is now in its final stretch: 3 sorries remain (same_order_type sigma/tau now UNBLOCKED, h_d_unique). Phases 2, 10 are COMPLETE. Phases 7-9 remain OFF the critical path.

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes with zero errors, no `axiom` declarations in the pipeline.

### Research Integration

Reports 23 and 27 (integrated in v14) provide the post-task-195 assessment:

- **Report 23**: Systematic per-sorry tactic analysis. Confirms task 195 tactics are the right and sufficient tactic investment. The remaining 7 sorries (excluding 2 same_order_type) are each unique mathematical arguments that cannot be profitably automated. Only marginal additional tactic (`point_witness_interval`) saves lines but blocks nothing.
- **Report 27**: Post-task-195 blocker assessment. Confirms lines 3059 (sigma) and 3263 (tau) same_order_type are DIRECTLY RESOLVED by replacing `simp_all` with `delta game_tuple; split_ifs` (controlled normalization via `simp_game_tuple`). Provides recommended proof strategies for both sigma and tau cases. Notes that tau case needs sigma instantiation for `(x' < d iff x < c)` ordering link.

Prior integration (v13):
- **Report 35**: Resolves Phase 1 d-consistency blocker. Report 29 correct, handoff-b wrong. Both infimum redefinition and rank embedding needed.
- **Report 18**: Resolves Task 1.7 IH h_fwd_r1 recursive rank tower via decoupled round count + universal h_r1_univ.

### Prior Plan Reference

v13 was accurate on all phases and overall pipeline architecture. Its Phase 1 Task 1.6 same_order_type was BLOCKED by the `game_tuple` noncomputable/`simp_all` compilation issue. v14 unblocks it by incorporating task 195's EFGameTactics. Line numbers updated from v13 estimates to report 27's verified locations. Effort revised down by ~6 hours reflecting the unblocking.

### Session Progress (v12 -> v13 -> implementation rounds 1-9 -> task 195 completion)

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
| Phase 1: Task 1.4 h_d_unique parameter refactor | PARTIAL | Round 6 | refactored, 1 sorry |
| Phase 1: Task 1.6 same_order_type (sigma + tau) | UNBLOCKED | Round 8-9 + task 195 | block-commented proofs verified, task 195 tactics available |
| Task 195: EF game tactics (assists 155) | COMPLETE | -- | +208 lines (EFGameTactics.lean), lemma moves to EFGames.lean |
| Phase 3: c-gap-case (n>=1) | DONE | pre-v13 | ~40 new |
| Rank embedding infrastructure | CONFIRMED | pre-v13 | 0 (already sorry-free) |

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates `succ_cofinal` via Reynolds gap elimination (not task 129 Henkin approach)
- Formalizes the complete GHR93 Theorem 3 + Reynolds Theorem 14

## Goals & Non-Goals

**Goals**:
- Close same_order_type sigma (line 3059) and tau (line 3263) using task 195 EFGameTactics -- uncomment and fix block-commented proofs
- Prove GHR93 Claim 1 -- close h_d_unique sorry at line 1709
- Close d_consistency_left/right via Claim 1 (already structurally complete, depends on h_d_unique)
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

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Case II same_order_type: tau sub-case needs sigma instantiation for `(x' < d iff x < c)` | M | M | Report 27: instantiate `props.sigma` with trivial selections (all d) to get sigma winning condition, extract ordering at positions (0, n+2). Same technique used at lines ~3174-3185 for sigma sub-case. The sigma case itself uses `hord_sig` directly. |
| same_order_type block-commented proofs: sorry fallbacks inside closers | M | CONFIRMED | Round 9 handoff: sigma proof line 3162 has `\| sorry)` as last alternative. After switching to `simp only [game_tuple]; split_ifs` (task 195 approach), this sorry should become unnecessary. If goals remain, use `extract_order` macro to close them. |
| h_d_unique (Claim 1): predicate-level proof vs formula materialization | M | M | Report 22 provides predicate-level GHR93 Claim 1 proof. h_d_unique at calling site has hd_glb, hd_is_inf, h_mono_left_r1 in scope. May need rank r+1 game argument or ExtendedCarrier extensionality. |
| Infimum construction Case 3: infimum_gap precondition assembly | M | L | Case 1 (point minimum) and Case 2 (carrier-point GLB) done. Case 3 (no GLB, use infimum_gap) needs h_not_point_glb + h_above preconditions. Deferred to Phase 3 c-gap-case. |
| Cases III/IV gap detection formula rank bounds don't match codebase | M | M | Follow GHR93 exactly: Case III uses left(B,D) with rank r+2, Case IV uses right(B,D) with rank r+3. Verify rank bounds with `stavi_depth` computation before proceeding. |
| Proposition 7 composition too complex (decomposition formula counting) | M | M | GHR93 Proposition 7 proof is explicit (p.26-27). If composition stalls, try direct Corollary 5 route via formula enumeration. |
| Model surgery (Lemma 12) case explosion exceeds budget | M | L | Report 26 estimates 350-450 lines. Modularize into per-case helpers; S cases are perfectly dual to U cases (use a shared template with direction parameter). |

## Full Sorry Inventory (Current -- after 9 implementation rounds + task 195 completion)

### ExpressivenessGeneral.lean (9 sorries)
| Line | Context | Phase | Status |
|------|---------|-------|--------|
| ~1614 | Case 3 infimum gap construction | 3 | Needs infimum_gap precondition assembly |
| ~1709 | `h_d_unique` (Claim 1 obligation) | 1 | Refactored in Round 6; 1 sorry at calling site |
| ~1804 | `h_pt_xc` degenerate gap | 1/3 | Possibly unreachable; may need SplitPointProps weakening |
| ~1821 | `h_pt_cy` degenerate gap | 1/3 | Same |
| ~1919 | n=0 gap case c construction | 1/3 | Needs dedicated n=0 argument |
| ~3059 | Case II sigma same_order_type | 1 | UNBLOCKED by task 195 tactics |
| ~3263 | Case II tau same_order_type | 1 | UNBLOCKED by task 195 tactics |
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

**Phase 1 progress**: Started with 9 sorry sites in scope (4 original + 5 introduced during restructuring). Closed 6, introduced h_d_unique refactor. 5 remain in Phase 1 scope: h_d_unique (1 sorry), same_order_type sigma/tau (2 sorries, now UNBLOCKED), degenerate gap points (2 sorries, possibly unreachable). Of these, same_order_type sigma/tau are the immediate next action.

## Implementation Phases (v14 -- Task 195 Tactics Available)

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

### Phase 1: D-Consistency via Infimum + Claim 1 + Case II Restructure (GHR93 Claim 1) [IN PROGRESS]

**Goal**: Close the d-consistency interior sorries by (a) constructing the actual infimum of continuation_set, (b) proving GHR93 Claim 1 at rank r+1, (c) closing same_order_type sigma/tau using task 195 EFGameTactics, and (d) closing the IH h_fwd_r1 sorry via decoupled round count + universal h_r1.

**Root cause (definitively resolved by report 35)**: GHR93 Claim 1 proves that any winning response to c equals d-bar (the infimum of the N-side continuation set). The current code sets d = x' (placeholder), making d_consistency unprovable. With d = d-bar, Claim 1 gives d_consistency directly. Rank embedding infrastructure is already sorry-free. Case II must construct e_n as a fresh point via U(B,A) transfer, not as d-bar or a_bwd(n).

**Task 1.6 same_order_type resolution (report 27 + task 195)**: The compilation blocker was `simp_all` rewriting hypotheses (particularly `hp_n : a_bwd n = extendPoint p_n`) in file context but not in multi_attempt isolation. Task 195's `same_order_type_grid` macro provides the fix: `intro i j; simp only [game_tuple]; split_ifs` which produces 25 clean goals without hypothesis destruction. The `order_refl` macro closes 3 diagonal goals. The `extract_order` macro and `pivot_chain_order'` handle cross-boundary cells. The block-commented proofs at lines 3060-3162 (sigma) and 3264-3419 (tau) contain the verified proof architecture.

**Tasks**:
- [x] **Task 1.1**: Construct actual infimum at `obtain_split_point_props` (~100-150 lines). *(deviation: altered -- Fixed buggy 2-way case split with correct 3-way split: (1) carrier-point minimum d=extendPoint p (unchanged), (2) carrier-point GLB p not in S_C d=extendPoint p (new, fully proved using gap no_sup axiom), (3) no carrier-point GLB (sorry'd, deferred to Phase 3 c-gap-case which wires infimum_gap_r_definable). Net -2 sorries: removed 3 buggy sorries, added 1 clean sorry for Case 3.)*
- [x] **Task 1.2**: Change `SplitPointProps` from `hd_eq_an` to `hd_le_an` if not already done (~10-20 lines). *(completed -- already done in prior session; line 1298 has `hd_le_an`)*
- [x] **Task 1.3**: Fix Case I sites (~20-40 lines, 2 sites). *(completed -- all live hd_eq_an references are in the OLD CASE II PROOF block comment; Case I uses hd_le_an correctly)*
- [ ] **Task 1.4**: Prove GHR93 Claim 1 -- 1 sorry remains at h_d_unique calling site (line ~1709). *(Round 6 refactored: added h_d_unique parameter to d_consistency_left/right, eliminating 2 interior sorries and replacing with 1 targeted sorry at obtain_split_point_props where hd_glb, hd_is_inf, h_mono_left_r1 are all in scope.)* The proof is a predicate-level argument (no need to materialize C' as a StaviFormula):
  - **Step 1 (d <= d-bar)**: Use h_fwd_r1 to play rank-(r+1) game including c. Winning condition gives rank-(r+1) formula agreement between c and response d. Since c = inf(S_C) in M, cont_holds fails below c (use `cont_fails_below_gap`) and holds above c (use `cont_holds_above_gap`). By formula transfer at rank r+1, the same semantic pattern holds at d in N. If d > d-bar, d is in S_C(N), so cont_holds holds throughout (d, y'), contradicting the transferred "fails cofinally below" property. So d <= d-bar.
  - **Step 2 (d-bar <= d by contradiction)**: Assume d < d-bar. Then d is not in S_C(N), so there exists a witness u in (d, y') where cont_holds fails. Spoiler challenges with u in round 2. Duplicator must respond with b in (c, y) in M. But c = inf(S_C(M)) means cont_holds holds on (c, y), so M |= cont_holds(b), contradicting formula transfer of not-cont_holds.
  - **Step 3**: d <= d-bar and d-bar <= d implies d = d-bar.
  - **Key infrastructure**: `cont_holds_above_gap`, `cont_fails_below_gap`, `h_fwd_r1` (already parameter), `continuation_set_upward_closed`
- [x] **Task 1.5**: Close `d_consistency_left` and `d_consistency_right` interior sorries (~20-40 lines). *(deviation: altered -- Round 6 resolved via h_d_unique parameter. Interior cases now extract formula/gp/boundary agreement from winning condition and apply h_d_unique. ~50 lines added per theorem. Depends on Task 1.4 for h_d_unique proof.)* Apply Claim 1 extract (h_d_unique) to the forward strategy's response. With h_d_unique proved, d_consistency_left/right have zero interior sorries.
- [ ] **Task 1.6**: Restructure Case II winning condition assembly. *(Round 5 implemented e_n construction via forward game + sigma/tau split. Round 6 decomposed 2 monolithic sorries into 6 targeted: same_order_type, gap_point_agreement, formula_agreement x sigma/tau. Round 7 closed 4 of 6 (gap_point + formula for both sub-cases). Remaining: 2 same_order_type sorries NOW UNBLOCKED by task 195.)*
  - [x] e_n construction via forward game round 2 (h_fwd_n1 + p_n challenge) -- Round 5
  - [x] sigma/tau case split on b_sp <= c vs b_sp > c -- Round 5
  - [x] sigma gap_point_agreement -- Round 7 (5-way index split + tau auxiliary)
  - [x] sigma formula_agreement -- Round 7
  - [x] tau gap_point_agreement -- Round 7
  - [x] tau formula_agreement -- Round 7
  - [ ] **sigma same_order_type** (line ~3059) -- UNBLOCKED by task 195. Implementation steps:
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

**Timing**: 8-12 hours (revised down from 12-18; same_order_type unblocked saves ~4h, Task 1.7 already done)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- same_order_type sigma/tau fix, h_d_unique Claim 1 proof

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

**Goal**: Close the c-gap-case sorry (line ~1614), the M-side degenerate sorries (lines ~1804, ~1821), the n=0 gap case (line ~1919), and prove Cases III and IV of GHR93 Theorem 6 (line ~4246).

**GHR93 Reference**: Section 8, Theorem 6 proof, Cases III and IV (pp.117-119).
- **Case III**: alpha_n is a gap defined on the left by D. Use left(B,D) as the detection formula. Apply Lemma 9 left to find gap e_n in (t,d)_r.
- **Case IV**: alpha_n is a gap NOT left-defined. Use right(B,D) as the detection formula. Apply Lemma 9 right to find gap e_n in (t,u).

**Sub-tasks for c-gap-case (line ~1614)**: When d is a gap in `obtain_split_point_props`, use Lemma 9 to transfer gap detection from N-side to M-side. The gap gamma in N has a defining formula D; apply `left_formula_gap_detection` or `right_formula_gap_detection` to find the corresponding c in M_r.

**Sub-tasks for M-side degenerate (lines ~1804, ~1821)**: Either prove these cases are unreachable (degenerate interval at a gap contains no points, contradiction with some other hypothesis) or restructure `SplitPointProps` to make `h_pt_xc`/`h_pt_cy` conditional: `x < c -> exists p, inClosedInterval x c (extendPoint p)`. Update 5 downstream usage sites with appropriate guards.

**Sub-tasks for n=0 gap case (line ~1919)**: When n=0, the backward game has 0 rounds and cannot find c via the standard mechanism. Use Lemma 9 gap detection to transfer the gap from N to M.

**Tasks**:
- [ ] **Task 3.1**: Investigate whether degenerate gap cases (lines ~1804, ~1821) are unreachable. If so, prove by contradiction. If not, restructure `SplitPointProps.h_pt_xc` to conditional form `x < c -> exists p, ...` and `SplitPointProps.h_pt_cy` similarly (~15-20 lines changed in the structure).
- [ ] **Task 3.2**: If conditional restructure needed: update 5 downstream usage sites of h_pt_xc/h_pt_cy with appropriate `x < c` / `c < y` proofs (~30-50 lines). Case I: follows from split hypothesis + boundary correspondence. Case II: c is a point (prove witness trivially).
- [ ] **Task 3.3**: Close c construction gap case (line ~1614, ~50-80 lines). Use `left_formula_gap_detection` or `right_formula_gap_detection` to find c in M_r when d is a gap. Apply the defining formula D and the D-between condition to invoke Lemma 9.
- [ ] **Task 3.4**: Close n=0 gap case (line ~1919, ~60-100 lines). Apply Lemma 9 gap detection to transfer gap from N to M in the degenerate n=0 case.
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
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close lines ~1614, ~1804, ~1821, ~1919, ~4246
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
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- infimum construction, Claim 1, d-consistency, Case II restructure, M-side degenerate, c-gap-case, Cases III/IV, rank-varying Thm 6, Props 6-7
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW) -- Reynolds Lemmas 6-13, Theorem 14
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or `Theorem5.lean` -- Reynolds Theorem 5
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- no_gaps_discrete
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- h_truth_corr (COMPLETE)
- `specs/155_reynolds_pipeline_activation/plans/17_reynolds-pipeline-plan.md` -- This plan (v14)

## Rollback/Contingency

1. **Same_order_type sigma (Task 1.6)**: If `same_order_type_grid` approach still leaves unresolved goals after uncommenting: use `extract_order` macro for individual cell extraction, or fall back to fully manual `intro i j; delta game_tuple; split_ifs` with per-cell closers (verbose but reliable, ~200 lines).
2. **Same_order_type tau (Task 1.6)**: If sigma instantiation for `(x' < d iff x < c)` is hard to extract: try using the forward game ordering `hord_fwd` at positions (0, n+1) which relates x to a_M(n) and x' to a_N(n). Since a_M(n)=c by construction, this gives `(x' < a_N(n) iff x < c)`. Then separately show `a_N(n) = d` or use a weaker ordering relationship.
3. **h_d_unique (Task 1.4)**: If the predicate-level Claim 1 argument is too complex: try the ExtendedCarrier extensionality approach -- two elements with identical formula type, gap/point status, and boundary position in a finite-rank structure must be equal. This may require proving that rank-r formulas separate points in the extended carrier.
4. **Cases III/IV (Phase 3)**: If the case-specific construction exceeds budget, implement Case III first (simpler: left-defined gap, rank r+2) and leave Case IV for a follow-up. Task 195 tactics assist the winning condition assembly.
5. **Assembly (Phase 4)**: If Prop 7 composition is too complex, try direct Corollary 5 route via formula type enumeration.
6. **Gap elimination (Phases 6A-6B)**: Lemma 12's 14 cases can be individually modularized. S cases are perfectly dual to U cases.
7. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck on any phase, mark [BLOCKED] and request additional research. The critical directive prohibits shortcuts.
