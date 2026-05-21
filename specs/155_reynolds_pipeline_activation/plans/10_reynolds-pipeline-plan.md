# Implementation Plan: Reynolds Pipeline Activation (v8 -- Revised from Research Reports 12, 15 + W2 Implementation Session)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 55-75 hours (remaining: ~40-60 hours)
- **Dependencies**: Task 154 (sum_preservation/doets_lemma_1_4, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED), Task 157 (separation/expressive completeness, COMPLETED)
- **Research Inputs**:
  - specs/155_reynolds_pipeline_activation/reports/03_team-research.md
  - specs/155_reynolds_pipeline_activation/reports/04_phase4-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/05_full-reynolds-impl.md
  - specs/155_reynolds_pipeline_activation/reports/06_path-b-feasibility.md
  - specs/155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md
  - specs/155_reynolds_pipeline_activation/reports/10_team-research.md (Round 4)
  - specs/155_reynolds_pipeline_activation/reports/10_teammate-a-findings.md
  - specs/155_reynolds_pipeline_activation/reports/10_teammate-b-findings.md
  - specs/155_reynolds_pipeline_activation/reports/10_teammate-c-findings.md
  - specs/155_reynolds_pipeline_activation/reports/10_teammate-e-findings.md
  - specs/155_reynolds_pipeline_activation/reports/12_degenerate-interval-blocker.md (NEW in v8)
  - specs/155_reynolds_pipeline_activation/reports/15_d-consistency-blocker.md (NEW in v8)
  - specs/155_reynolds_pipeline_activation/handoffs/phase-4CW1-handoff-20260521.md (NEW in v8)
  - specs/155_reynolds_pipeline_activation/handoffs/phase-4CW2-handoff-20260521.md (NEW in v8)
- **Artifacts**: plans/10_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: FULL GHR93, NO SHORTCUTS

**The user explicitly requires the FULL game-theoretic proof of GHR93 Theorem 9.3.1.** No discrete-only transfer (Approach B), no bypass via succ_cofinal (Approach C), no axiom declarations. The plan formalizes the complete EF game argument proving {U,S,U',S'} is expressively complete over ALL linear temporal structures.

Agents MUST:
1. **READ the GHR93 paper (Chapter 9, Section 8)** before attempting the game proof
2. **Follow the paper step-by-step** -- the four cases (I-IV) must follow GHR93
3. **NEVER add `IsSuccArchimedean` as a hypothesis** -- Reynolds does not use it
4. **NEVER use `orderIsoIntOfLinearSuccPredArch`** on the chronicle domain
5. **NEVER use `axiom` declarations** -- everything must be proved
6. **NEVER use shortcuts or discrete-only arguments** for Theorem 4
7. **If stuck, re-read the literature** -- the answer is in the paper

---

## Overview

This plan (v8) revises v7 based on three new research findings and one implementation session. Phases 1-5, 4A, and 4B are COMPLETED. Phase 4C (GHR93 Theorem 6 main proof) is IN PROGRESS with Cases I and II sorry-free (~1720 lines). Phase 4C-W1 is PARTIAL (degenerate cases and d-consistency remain). Phase 4C-W2 is PARTIAL (4 infrastructure lemmas proved; gap existence lemma identified as core blocker).

The v8 revision restructures Phase 4C-W1 to address two critical discoveries:
1. **D-consistency uses infimum, not a_bwd(n)**: GHR93 defines `d = inf{t in [x',y'] : C holds on (t,y')}` and PROVES d-consistency as Claim 1 (report 15). The current `d = a_bwd(n)` definition makes d-consistency unprovable. Fixing this requires redefining d, proving Claim 1, and rewriting ~30 locations in Case II.
2. **Degenerate intervals are vacuously winnable**: When d=x' (both gaps), the [d,d] game is vacuously won because Spoiler cannot produce an actual point. A `ghr93_duplicator_wins_degenerate_gap` lemma (~20 lines) dispatches this before IH application (report 12).
3. **Gap existence lemma is the Lemma 9 core blocker**: All non-trivial Lemma 9 cases depend on a single gap existence lemma connecting `U'^mu(top, D)(m)` at actual points to the existence of r-definable D-definable-on-left gaps (W2 handoff). Estimated at 150-250 lines.

The full critical-path sorry count is 17 (13 in Phase 4C + 1 in Transfer.lean + 3 in IntegerModel.lean).

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations in the pipeline, `stavi_expressive_completeness` is sorry-free.

### Research Integration

Integrated from 14 artifacts across 3 rounds:

**Round 3** (integrated in v4-v6):
- `reports/03_team-research.md`: Chronicle truth, box mismatch, succ_cofinal assessment, NF-evaluation approach
- `reports/04_phase4-blocker.md`: Phase 4 blocker identifying Thm 14 <- Thm 5 <- Thm 4 <- Stavi connectives chain
- `reports/05_full-reynolds-impl.md`: Full Reynolds implementation with proof sketches for Lemmas 6-13
- `reports/06_path-b-feasibility.md`: Path B feasibility (rejected by user)
- `reports/07_ghr93-strategy-review.md`: Strategy review with h_truth_corr independence finding

**Round 4** (integrated in v7):
- `reports/10_team-research.md`: Synthesis -- d-consistency unprovable, flatten_stavi_correct_mu is key prerequisite, Phase 10 reverted, 17 total critical-path sorries, wave-based ordering
- `reports/10_teammate-a-findings.md`: Detailed sorry inventory with dependency ordering, mu-elimination insight, tractability assessment for Groups A-C
- `reports/10_teammate-b-findings.md`: D-consistency restructuring proposal (Alternative A), flatten_stavi_correct_mu specification, gap witness approach via no_sup
- `reports/10_teammate-c-findings.md`: Phase 10 revert discovery via git history, full 17-sorry critical-path count, d-consistency unprovability proof, Props 6-7 entirely unimplemented
- `reports/10_teammate-e-findings.md`: Literature alignment verification (faithful with necessary Lean adaptations), Reynolds/GHR93 "Lemma 9" naming collision, rank-varying Theorem 6 analysis

**Round 5** (NEW in v8):
- `reports/12_degenerate-interval-blocker.md`: Degenerate [d,d] intervals are vacuously winnable; `ghr93_duplicator_wins_degenerate_gap` lemma construction; forward strategy boundary extraction needed
- `reports/15_d-consistency-blocker.md`: GHR93 defines d as infimum; Claim 1 proves d-consistency; 5 solution options analyzed; Option E (infimum-based d + separate IsPoint field) recommended; Case II rewrite ~100-200 lines
- `handoffs/phase-4CW1-handoff-20260521.md`: W1.1 d-consistency BLOCKED, W1.2 degenerate cases remain, W1.3 bridge lemma FALSE for non-discrete orders
- `handoffs/phase-4CW2-handoff-20260521.md`: 4 infrastructure lemmas proved (extendPoint_lt_iff, temporal_truth_mu_at_point, stavi_truth_mu_at_point, gap_detection_unique); theorem signatures corrected (hD added); base cases proved; gap existence lemma is sole remaining blocker

### Prior Plan Reference

The v7 plan had 12 phases (1-5, 4A, 4B, 4C-W1 through W4, 5'-11). Phases 1-5, 4A, 4B: COMPLETED. Phase 4C-W1: PARTIAL (degenerate sorries + d-consistency). Phase 4C-W2: PARTIAL (infrastructure only). Lessons learned from v7:
1. **D-consistency architecture is flawed**: v7 proposed inequality fix (hd_eq_an -> hd_le_an). Report 15 confirms this is the RIGHT direction but insufficient -- d must be redefined from infimum, and Claim 1 must be proved. Case II needs ~30 sites rewritten but the paper NEVER uses d=a_n (only d<=a_n).
2. **flatten_stavi_correct_mu bridge lemma is FALSE**: v7 planned this as W1.3; confirmed false in W1 session. Lemma 9 proceeds by direct structural analysis.
3. **Gap existence lemma was not in v7**: Discovered during W2 session as the single biggest blocker. All non-trivial Lemma 9 cases depend on it.
4. **Infrastructure lemmas from W2 should not be re-planned**: extendPoint_lt_iff, temporal_truth_mu_at_point, stavi_truth_mu_at_point, gap_detection_unique are already proved.
5. **Effort calibration**: W1 (4 hours) and W2 (partial) confirm that each wave takes a full session. Case II rewrite for d-consistency will be a standalone effort.

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Formalizes the complete GHR93 expressive completeness theorem (Theorem 9.3.1)
- Closes the discrete completeness branch of the Reynolds pipeline
- Unblocks downstream: dead code cleanup, module reorganization, frame extensions, algebraic representation, publication quality

## Goals & Non-Goals

**Goals**:
- Prove GHR93 Theorem 4 (Theorem 9.3.1): {U,S,U',S'} is expressively complete for ALL linear temporal structures -- the FULL game-theoretic proof
- Prove Theorem 5 (Reynolds): {U,S} expressively complete for Prior structures, derived from Theorem 4
- Prove Reynolds Lemmas 6-13 (gap elimination machinery)
- Prove Theorem 14: no_gaps_discrete (without IsSuccArchimedean)
- Close cofinal_decomposition_k_equiv and ordered_sum_of_good_bounded_is_good
- Rewrite chronicle_is_good to use one_class + very_good_implies_good
- Remove domain_succ_archimedean from ChronicleAsPriorModel
- Discharge h_truth_corr in countermodel_discrete (Transfer.lean:574)
- Achieve `#print axioms bx_completeness` with no `sorryAx` and no custom `axiom`

**Non-Goals**:
- Dense completeness (separate path, unaffected)
- Closing `succ_cofinal` (task 129) -- we bypass it entirely via gap elimination
- Frame-class completeness variants (Completeness.lean:254,279,288)
- Optimizing existing sorry-free infrastructure
- `countermodel_discrete_enriched` (Completeness.lean:225, separate wrapper)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Infimum infrastructure for ExtendedCarrier exceeds estimate | H | M | ExtendedCarrier inherits linear order. If full ConditionallyCompleteLattice is too heavy, use Classical.choice on the formula-defined set (which is nonempty, y' is in it) combined with WellFounded argument for the infimum. Budget 120 lines as ceiling. |
| Case II rewrite (~30 sites) for hd_le_an introduces regressions | H | M | Case II never needs d=a_n per GHR93 paper. The 30 sites use hd_eq_an only to deduce IsPoint d from IsPoint a_n. Add separate h_pt_d field or prove IsPoint d from the infimum when a_n is a point. Regression test: lean_verify ghr93_case_II after each batch of changes. |
| Gap existence lemma (150-250 lines) is harder than estimated | H | M | Start with backward direction (gap -> U') which is simpler. If forward direction stalls, decompose into sub-lemmas: (a) cut construction, (b) downward-closedness, (c) D-definability, (d) D-between. Mark [PARTIAL] with proved direction. |
| Lemma 9 S/S' cases require >300 lines via direct analysis | H | M | Develop easy cases first (neg, conj, stavi_untl). S/S' cases use specific flatten_stavi outputs -- analyze each one individually. If one S/S' case exceeds 150 lines, mark [PARTIAL]. |
| Props 6-7 require unforeseen Lean infrastructure (~500+ lines) | M | M | Follow GHR93 paper step-by-step. If Prop 7 composition is too complex, try direct Corollary 5 route. |
| Phase 10 (h_truth_corr) delegation fails at type level | L | L | Phase 10 is independent. If types don't match, mark [BLOCKED] with exact mismatch and proceed with other phases. |
| Gap elimination Lemmas 6-13 (Reynolds Section 7) exceed 12 hours | M | M | Lemma 12 (model surgery, 14 cases) is the hardest. Budget 2-3 sessions. Modularize into one sub-lemma per case. |
| Rank-varying Theorem 6 requires cross-rank coercion infrastructure | M | M | Budget 80-150 lines. rank_embed already preserves stavi_truth_mu. If ExtendedCarrier type-level issues arise, prove rank contraction via stavi_n_equiv_mono. |

## Full Sorry Inventory (17 Critical-Path Sorries)

### Phase 4C Sorries (13 across 2 files)

**EFGames.lean** (4 sorries):
| Line | Identifier | Content | Difficulty | Blocks |
|------|-----------|---------|------------|--------|
| 1629 | `left_formula_gap_detection` | Lemma 9 left (gap detection correctness) | Hard (200+ lines) | Cases III/IV, line 496 |
| 1648 | `right_formula_gap_detection` | Lemma 9 right (dual) | Medium (50+ lines after left) | Cases III/IV |
| 2677 | `ghr93_decomposition_implies_game` | Lemma 11 backward direction | Medium (80-120 lines) | Prop 7 (verify if needed) |
| 2749 | `stavi_expressive_completeness` | Corollary 5 / main theorem | Medium (80-120 lines) | Final assembly |

**ExpressivenessGeneral.lean** (9 sorries):
| Line | Context | Content | Difficulty | Blocks |
|------|---------|---------|------------|--------|
| 298 | `obtain_split_point_props` | d-consistency left | UNPROVABLE as stated; requires infimum redesign | sigma/tau derivation |
| 308 | `obtain_split_point_props` | d-consistency right | UNPROVABLE as stated; requires infimum redesign | sigma/tau derivation |
| 347 | `obtain_split_point_props` | h_pt_left degenerate gap | Easy (~20 lines; vacuous game) | sigma |
| 367 | `obtain_split_point_props` | h_pt_right degenerate gap | Easy (~20 lines; vacuous game) | tau |
| 387 | `obtain_split_point_props` | h_pt_xc_w degenerate gap | Easy (~20 lines; vacuous game) | SplitPointProps |
| 404 | `obtain_split_point_props` | h_pt_cy_w degenerate gap | Easy (~20 lines; vacuous game) | SplitPointProps |
| 496 | `obtain_split_point_props` | c construction when d is gap | Hard (50-80 lines, needs Lemma 9) | sigma/tau |
| 2400 | `ghr93_cases_III_IV` | Cases III-IV of Theorem 6 | Very Hard (230-350 lines) | main theorem |
| 2621 | `ghr93_forward_to_backward_rank_varying` | Rank-varying Theorem 6 | Medium (80-150 lines) | Prop 7 |

### Other Critical-Path Sorries (4 across 2 files)

| File | Line | Identifier | Phase | Status |
|------|------|-----------|-------|--------|
| Transfer.lean | 574 | `h_truth_corr` | 10 | UNBLOCKED (delegate to dd_countermodel_chronicle_discrete) |
| IntegerModel.lean | 859 | `no_gaps_discrete` | 8 | Awaits Phase 6 |
| IntegerModel.lean | 1135 | `cofinal_decomposition_k_equiv` | 7 | NOT STARTED |
| IntegerModel.lean | 1194 | `ordered_sum_of_good_bounded_is_good` | 7 | NOT STARTED |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Status |
|------|--------|------------|--------|
| -- | 1, 2, 3, 4A, 5, 4B | -- | COMPLETED |
| 1 | 4C-W1 (d-consistency + degenerate intervals) | -- | IN PROGRESS |
| 2 | 4C-W2 (Lemma 9: gap existence + all cases) | 4C-W1 (for c-gap-case integration) | IN PROGRESS |
| 3 | 4C-W3 (c-gap-case + Cases III/IV) | 4C-W2 | NOT STARTED |
| 4 | 4C-W4 (Assembly: rank-varying Thm 6, Props 6-7, Cor 5) | 4C-W3 | NOT STARTED |
| 5 | 5' (Theorem 5 from Theorem 4) | 4C-W4 | NOT STARTED |
| 6 | 6 (Gap Elimination Lemmas 6-13, Theorem 14) | 5' | NOT STARTED |
| 7 | 7 (IntegerModel helpers), 8 (Wire no_gaps_discrete) | 6 (for 8), none (for 7) | NOT STARTED |
| 8 | 9 (Rewrite chronicle_is_good) | 7, 8 | NOT STARTED |
| 9 | 10 (h_truth_corr delegation) | -- | NOT STARTED (independent) |
| 10 | 11 (Final wiring) | 9, 10 | NOT STARTED |

**Execution order** (STRICT SEQUENTIAL within main chain):
4C-W1 -> 4C-W2 -> 4C-W3 -> 4C-W4 -> 5' -> 6 -> 8 -> 9 -> 11.
Phase 7 (IntegerModel helpers) can proceed in parallel with the 4C chain.
Phase 10 (h_truth_corr delegation) can proceed in parallel -- delegation to dd_countermodel_chronicle_discrete is ~5 lines.
Lemma 11 backward (EFGames.lean:2677) can proceed in parallel -- verify first whether Proposition 7 actually needs it.

---

### Phase 1: Chronicle Truth Lemma [COMPLETED]

**Goal**: Close the `chronicle_temporal_truth` sorry (Transfer.lean:186) and the inline sorry at Transfer.lean:371.

**Tasks**:
- [x] Prove `chronicle_temporal_truth` by structural induction on formula psi
- [x] Wire into `countermodel_discrete` at Transfer.lean:470-475
- [x] Verify `lake build` passes

**Timing**: 4 hours

**Depends on**: none

---

### Phase 2: Fix Nonempty sig.preds [COMPLETED]

**Goal**: Close the trivial `Nonempty sig.preds` sorry at Transfer.lean:332.

**Tasks**:
- [x] Augmented mkSigFrom to include Formula.bot as dummy predicate
- [x] Verify `lake build` passes

**Timing**: 1 hour

**Depends on**: none

---

### Phase 3: Fix z_interval_countermodel Architecture and Bridge [COMPLETED]

**Goal**: Refactor `zIntervalTaskFrame` to use singleton Omega approach with box transparency. Add `h_truth_corr` hypothesis for the full truth correspondence.

**Tasks**:
- [x] Singleton Omega, box transparency, h_truth_corr as parameter. z_interval_countermodel sorry-free; one sorry remains at countermodel_discrete for h_truth_corr discharge.

**Timing**: 4 hours

**Depends on**: none

---

### Phase 4A: Stavi Connective Semantics [COMPLETED]

**Goal**: Define Stavi connective semantics U'(A,B) and S'(A,B), StaviFormula type, stavi_temporal_truth, FO tables, cofinal/successor equivalences.

**Tasks**:
- [x] Created StaviConnectives.lean (~530 lines). All definitions and theorems sorry-free.

**Timing**: 4 hours

**Depends on**: none

---

### Phase 5: flatten_stavi_correct (Discrete Case) [COMPLETED]

**Goal**: Prove flatten_stavi_correct for discrete orders.

**Tasks**:
- [x] All equivalences proved sorry-free.

**Timing**: 3 hours

**Depends on**: 4A

---

### Phase 4B: GHR93 Infrastructure -- Definitions and Lemmas [COMPLETED]

**Goal**: Build the complete GHR93 Section 8 infrastructure (Tasks 4B.1-4B.7).

**Tasks**:
- [x] All 7 tasks completed. Gap/M_r/ExtendedCarrier, mu/A^mu, left/right_formula, G_{n;r}, decomposition agreement, Lemma 10 round monotonicity, Lemma 11 forward. Build passes.

**Timing**: 12-18 hours

**Depends on**: none

---

### Phase 4C-W1: Infimum-Based D + Degenerate Intervals + Case II Rewrite [IN PROGRESS]

**Goal**: Restructure `obtain_split_point_props` to use the GHR93 infimum-based definition of d, handle degenerate intervals via vacuous game lemma, and update Case II for `hd_le_an`.

This phase resolves 6 of the 9 sorries in ExpressivenessGeneral.lean: the 2 d-consistency sorries (lines 298, 308) and the 4 degenerate interval sorries (lines 347, 367, 387, 404).

**Research Basis**: Report 15 (d-consistency blocker) establishes that GHR93 defines `d = inf{t in [x',y'] : C holds on (t,y')}` and proves d-consistency as "Claim 1". Report 12 (degenerate interval blocker) establishes that [d,d] games with gap endpoints are vacuously winnable.

**BEFORE CODING**: Re-read GHR93 Section 8, pages 27-28 (definition of c,d as infima; Claims 1-2). Understand that c and d are semantic properties of the structures, defined BEFORE any game is played. The paper then proves that any winning strategy's response to c must equal d.

**Implementation Strategy (REVISED after W1 v2 session)**: The inequality approach (hd_le_an) was attempted and REJECTED — changing `hd_eq_an` to inequality breaks Case II at 28 locations, and the inequality cannot be recovered to equality from the available hypotheses. The correct approach is to **prove d-consistency directly via GHR93 Claim 1**, keeping `hd_eq_an` as equality. This preserves all existing Case I and Case II code.

GHR93 Claim 1 states: for any winning strategy response, the response at the boundary position must equal d (the infimum). The proof uses formula_agreement from the winning condition — since all rank-r formulas agree between c and any response, and formula C uniquely characterizes d's position (as the infimum of the C-satisfying set), the response must equal d. This is ~150-200 lines of new proof work.

**Revised approach**:
1. Keep `d = a_bwd(n)` and `hd_eq_an` unchanged
2. Prove Claim 1: define continuation formula C from the backward selections; show any winning response at the boundary must satisfy C; derive d-consistency from C-uniqueness
3. Degenerate intervals: once d-consistency is proved, the degenerate case follows (d-consistency gives `a'_full(n) = d`, so if `x' = d` then `x = c` follows from formula correspondence)

**Tasks**:

- [x] **Task W1.1**: Add `ghr93_duplicator_wins_degenerate_gap` lemma to EFGames.lean. *(completed — sorry-free, verified via lean_verify)*

- [ ] **Task W1.2**: Prove GHR93 Claim 1 (~150-200 lines). Define continuation formula C from the backward game's selections. Show: for any winning play where M-side has c at position n, the N-side response at position n satisfies formula C, and C uniquely characterizes d = a_bwd(n). This gives d-consistency: `a'_full(n) = d`. Add as a helper theorem in ExpressivenessGeneral.lean. Eliminates 2 d-consistency sorries (lines 303, 313).

- [ ] **Task W1.3**: Close degenerate interval sorries (~40-60 lines). With d-consistency proved (Task W1.2), derive `x = c` when `x' = d` from same_order_type. Apply `ghr93_duplicator_wins_degenerate_gap` for the degenerate sub-game. Eliminates 4 sorries (lines 352, 372, 392, 409).

- [ ] **Task W1.4**: Verify `lake build` passes. Cases I and II remain sorry-free (no changes to their code).

**Timing**: 6-10 hours (dominated by Claim 1 proof)

**Depends on**: none

**Timing**: 6-10 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add ghr93_duplicator_wins_degenerate_gap
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- restructure SplitPointProps, obtain_split_point_props, Case I, Case II

**Verification**:
- Lines 298, 308 (d-consistency) sorry-free
- Lines 347, 367, 387, 404 (degenerate intervals) sorry-free
- `lean_verify ghr93_case_I` shows no `sorryAx`
- `lean_verify ghr93_case_II` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W2: Lemma 9 Gap Detection Correctness [IN PROGRESS]

**Goal**: Prove `left_formula_gap_detection` and `right_formula_gap_detection` -- the GHR93 Lemma 9 that bridges temporal formulas to gap properties.

**Status**: Infrastructure complete. 4 lemmas proved in W2 session: `extendPoint_lt_iff`, `temporal_truth_mu_at_point`, `stavi_truth_mu_at_point`, `gap_detection_unique`. Theorem signatures corrected with `hD : stavi_depth D <= r`. Base cases (atom, bot, box) proved. The gap existence lemma is the sole remaining blocker.

**Research Basis**: W2 handoff identifies the gap existence lemma as the critical prerequisite for ALL non-trivial cases. The lemma connects `U'^mu(top, D)(m)` at an actual point m to the existence of an r-definable gap gamma > m that is D-definable on the left with D holding between m and gamma.

**BEFORE CODING**: Re-read GHR93 Section 8, Definition 8.5 and Lemma 9. The proof is by structural induction on A. Use `stavi_truth_mu_at_point` (already proved) to convert between mu-relativized and standard evaluation at actual points.

**Tasks**:

- [x] **Task W2.0**: Infrastructure lemmas (completed in W2 session):
  - `extendPoint_lt_iff` (strict order preservation for point embedding)
  - `temporal_truth_mu_at_point` (mu-truth at actual points = standard truth)
  - `stavi_truth_mu_at_point` (same for StaviFormula)
  - `gap_detection_unique` (at most one gap per D per point m satisfying conditions)
  - Theorem signature fix: added `hD : stavi_depth D <= r` to both gap detection theorems

- [x] **Task W2.base**: Base cases proved (atom, bot, box): both sides reduce to False at gaps.

- [ ] **Task W2.1**: Prove the gap existence lemma (~150-250 lines). This is the CRITICAL prerequisite.

  **Statement** (to be added in EFGames.lean):
  ```
  theorem gap_existence_from_stavi_untl_top
      (D : StaviFormula) (hD : stavi_depth D <= r) (m : M.carrier)
      (h : stavi_temporal_truth_mu M atomMap r (extendPoint m) (.stavi_untl .base_top D)) :
      exists (gamma : RDefinableGap M atomMap r),
        extendPoint m < Sum.inr gamma /\
        gap_definable_on_left M atomMap gamma.val D /\
        (forall u : M.carrier, m < u -> u in gamma.val.cut ->
          stavi_temporal_truth_mu M atomMap r (extendPoint u) D) /\
        m in gamma.val.cut
  ```

  **Proof strategy**:
  - **Forward** (U'(top, D)(m) -> gap exists): Unfold stavi_temporal_truth_mu at extendPoint m. U'(top, D) means "D is cofinal above m among mu-points, and there is no mu-point above m where top holds with D continuous between". Since top always holds, this means "D is cofinal but not continuously holding". Construct the Dedekind cut {x | D holds continuously from m to x}. Show this cut defines a gap. Show it is D-definable on the left.
  - **Backward** (gap exists -> U'(top, D)(m)): Given gamma with the conditions, show D is cofinal above m (because D holds between m and gamma, and gamma.cut is nonempty). Show the "continuous D" condition fails at gamma. Use `stavi_truth_mu_at_point` to convert.
  - **Key construction**: The Dedekind cut is `{x in M | forall u, m < u -> u < x -> D holds at u}`. Need to show: (a) nonempty (m is in it), (b) proper (not all of M, since D cofinal but not continuous implies a break), (c) downward-closed, (d) no supremum in M (gap property), (e) complement has no minimum, (f) D-definable on left.

- [ ] **Task W2.2**: Prove Lemma 9 left easy cases using gap existence (~100 lines total):
  - `.neg A`: Use IH for A. gap_existence gives gamma. At gamma, A^mu does NOT hold (by IH reversed), so (.neg A)^mu holds. Gap is same (D-definable, D-between).
  - `.conj A B`: Use IH for both A and B. gap_existence gives gamma. Both A^mu and B^mu hold at gamma. Gap is same.
  - `.stavi_untl A B`: left_formula is `U'(B /\ U'(A,B), D)`. Unfold, use gap_existence with the compound formula.

- [ ] **Task W2.3**: Prove Lemma 9 left hard cases (~200-300 lines):
  - `.base (.untl phi psi)`: left_formula produces `U'(psi_stavi /\ U(phi_stavi, psi_stavi), D)`. Direct analysis of U'^mu with the specific Until formula. Use `temporal_truth_mu_at_point` to work at actual points.
  - `.base (.snce phi psi)`: left_formula uses flatten_stavi, producing a `.base (.untl ...)` wrapped form. Analyze what `temporal_truth_mu` of this specific Until means at actual points. Show it detects a gap defined on the left with the correct properties.
  - `.stavi_snce A B`: Similar to `.base (.snce)` -- direct case analysis of the flatten_stavi output.
  Each S/S' case requires showing the temporal formula at actual point m detects a gap gamma > m defined by D on the left, with D holding in (m, gamma) and A^mu(gamma) holding.

- [ ] **Task W2.4**: Prove Lemma 9 right (`right_formula_gap_detection`, ~50 lines). Dual of left by swapping U<->S, U'<->S', future<->past. Much of the structure mirrors left_formula_gap_detection with direction reversed.

- [ ] **Task W2.5**: Verify `lake build` passes.

**Timing**: 8-14 hours

**Depends on**: 4C-W1 is NOT a strict dependency for Lemma 9 itself (Lemma 9 is about gap detection in a single structure, independent of the strategy restriction). However, the c-gap-case integration (line 496) needs both W1 and W2.

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close sorries at lines 1629, 1648; add gap_existence_from_stavi_untl_top

**Verification**:
- `lean_verify left_formula_gap_detection` shows no `sorryAx`
- `lean_verify right_formula_gap_detection` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W3: c-Gap-Case + Cases III/IV [NOT STARTED]

**Goal**: Close the c-gap-case sorry (line 496) using Lemma 9, then prove Cases III and IV of GHR93 Theorem 6. This completes the four-case exhaustion of the inductive step.

**Research Basis**: Cases III (left-defined gap) and IV (right-defined gap) require Lemma 9 for gap detection. The c-gap-case at line 496 requires Lemma 9 to locate a compatible gap in M when d is a gap in N.

**BEFORE CODING**: Re-read GHR93 Section 8, Theorem 6 proof for Cases III and IV. Case III constructs delta = left(B, D) where B = X_{a_n} and D defines the gap a_n on the left. Case IV constructs delta = A and not D and U(right(B,D), A) for gaps defined on the right.

**Tasks**:

- [ ] **Task W3.1**: Close c-gap-case in `obtain_split_point_props` (line 496, ~50-80 lines). When d is a gap in N:
  1. d is an r-definable gap, so it has a defining formula D with stavi_depth D <= r.
  2. For each formula A with stavi_depth A <= r, left_formula(A, D) or right_formula(A, D) evaluated at actual points in M detects compatible gaps.
  3. Use the forward strategy's formula agreement to transfer gap detection from N to M.
  4. This gives c as a gap in M with matching rank_type and formula agreement.

- [ ] **Task W3.2**: Split `ghr93_cases_III_IV` into `ghr93_case_III` and `ghr93_case_IV`. Case III (a_n is left-defined gap, ~120-180 lines): Construct B = X_{a_n}, delta = left(B,D). Use tau for a_0,...,a_{n-1}. Apply Lemma 9 left to find t < gamma with delta(t) and A on (e_{n-1}, t). Find matching gap e_n via formula agreement.

- [ ] **Task W3.3**: Prove Case IV (a_n is gap, not left-defined, ~120-180 lines): Construct B = X_{a_n}, delta = A and not D and U(right(B,D), A). Use tau for earlier points. Apply Lemma 9 right with right(B,D) to find matching gap via right-definability.

- [ ] **Task W3.4**: Verify that `ghr93_inductive_step` assembly still compiles with the split Cases III/IV.

- [ ] **Task W3.5**: Verify `lake build` passes.

**Timing**: 6-10 hours

**Depends on**: 4C-W1 (SplitPointProps restructured), 4C-W2 (Lemma 9 proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close line 496, replace line 2400 sorry with Cases III/IV proofs

**Verification**:
- `obtain_split_point_props` has 0 sorries
- `lean_verify ghr93_inductive_step` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W4: Assembly -- Rank-Varying Thm 6, Props 6-7, Corollary 5 [NOT STARTED]

**Goal**: Complete the assembly chain from Theorem 6 to `stavi_expressive_completeness` (GHR93 Corollary 5). This includes the rank-varying Theorem 6, Propositions 6 and 7 (entirely from scratch), and the final Corollary 5. Optionally prove Lemma 11 backward if Proposition 7 requires it.

**Research Basis**: Teammate C confirmed Props 6-7 are entirely unimplemented (zero lines). Teammate E identified that Prop 7 requires the rank-varying Theorem 6 (sorry'd at line 2621). Teammate B noted Lemma 11 backward may be deferrable if Prop 7 uses only the forward direction -- verify this first.

**BEFORE CODING**: Re-read GHR93 Section 8, Propositions 6-7 and Corollary 5 (pages 113-114 of the paper). Determine whether Proposition 7 needs the backward direction of Lemma 11 (ghr93_decomposition_implies_game) or only the forward direction (already proved).

**Tasks**:

- [ ] **Task W4.1**: Prove rank-varying Theorem 6 (`ghr93_forward_to_backward_rank_varying`, line 2621, ~80-150 lines). Apply the uniform-rank `ghr93_forward_to_backward` at rank r+4n, then transport backward strategy from rank r+4n to rank r using `rank_embed_stavi_truth_mu` (already proved, lines 985-1044). Handle ExtendedCarrier type changes between ranks via `stavi_n_equiv_mono`.

- [ ] **Task W4.2**: Verify whether Proposition 7 needs Lemma 11 backward. Read GHR93 Proposition 7 proof structure. If backward direction IS needed, prove `ghr93_decomposition_implies_game` (line 2677, ~80-120 lines) by constructing Duplicator's strategy from decomposition agreement.

- [ ] **Task W4.3**: Prove Proposition 6 (~100-150 lines, entirely new). Statement: If M and N agree on all temporal formulas of rank r + 4n + 1, Duplicator has winning strategies for G_{n;r} on both future and past intervals. Uses X_t type formulas and decomposition formulas. Define proposition signature and prove by constructing Duplicator's selections from type formula agreement.

- [ ] **Task W4.4**: Prove Proposition 7 (~150-250 lines, entirely new). Composition theorem: If Duplicator wins G_{f(n);g(n)+4f(n)} on all sub-intervals between corresponding selected points (both forward and backward), she wins the standard EF game G_n. Proof by induction on n, using rank-varying Theorem 6 to convert forward to backward at each level.

- [ ] **Task W4.5**: Prove Corollary 5 = close `stavi_expressive_completeness` (line 2749, ~80-120 lines). Assembly: Given MonadicFormula psi of depth n, choose temporal formulas of rank 1+g(n+1) partitioning complete types. The type consistent with psi gives the StaviFormula A. Uses Props 5, 6, 7. Close the sorry in EFGames.lean.

- [ ] **Task W4.6**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`.

- [ ] **Task W4.7**: Run `lake build`.

**Timing**: 8-14 hours

**Depends on**: 4C-W3 (Theorem 6 fully proved, all 4 cases)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- rank-varying Thm 6 (line 2621), Propositions 6-7 (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close stavi_expressive_completeness (line 2749), possibly Lemma 11 bwd (line 2677)

**Verification**:
- `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward_rank_varying` shows no `sorryAx`
- No `axiom` declarations in any file
- `lake build` passes

---

### Phase 5': Reynolds Theorem 5 from Theorem 4 [NOT STARTED]

**Goal**: Prove that {U,S} alone is expressively complete for Prior structures, by composing Theorem 4 (stavi_expressive_completeness) with flatten_stavi_correct (Phase 5).

**Tasks**:
- [ ] **Task 5'.1**: Define and prove `US_expressively_complete_over_prior` (~60-100 lines). For any MonadicFormula psi, compose stavi_expressive_completeness + flatten_stavi + flatten_stavi_correct.
- [ ] **Task 5'.2**: Prove bridge lemma between `stavi_temporal_truth` and `temporal_truth` for box-free standard formulas (~30-50 lines).
- [ ] **Task 5'.3**: Verify `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`.

**Timing**: 2-3 hours

**Depends on**: 4C-W4 (stavi_expressive_completeness proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or new `Theorem5.lean`

**Verification**:
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build` passes

---

### Phase 6: Reynolds Lemmas 6-13 and Theorem 14 (Gap Elimination) [NOT STARTED]

**Goal**: Formalize the gap elimination argument from Reynolds 1994 Section 7.

**BEFORE CODING**: Read Reynolds 1994 Section 7 (Lemmas 6-13, Theorem 14) IN FULL. NOTE: "Reynolds Lemma 9" (gap elimination, Section 7) and "GHR93 Lemma 9" (gap detection, Section 8) are completely different theorems -- do not confuse them.

**Tasks**:
- [ ] **Task 6.1**: Create GapElimination.lean. Define mk_epsilon_formula and mk_rho_formula. Apply US_expressively_complete_over_prior to get temporal formula R. Prove R_correct. (Lemma 6, ~100-150 lines)
- [ ] **Task 6.2**: Prove R_interval_open (Lemma 7, ~80-100 lines)
- [ ] **Task 6.3**: Prove no_first_last_class (Lemma 8, ~60 lines)
- [ ] **Task 6.4**: Prove elementary_equiv_classes (Lemma 9-Reynolds, ~130 lines)
- [ ] **Task 6.5**: Prove bad_interval_structure (Lemma 10, ~80 lines)
- [ ] **Task 6.6**: Prove formula_propagation (Lemma 11, ~60 lines)
- [ ] **Task 6.7**: Prove model_surgery (Lemma 12, ~250-300 lines -- 14 cases for Until + Since)
- [ ] **Task 6.8**: Prove no_bad_points (Lemma 13, ~60 lines)
- [ ] **Task 6.9**: Assemble gap_elimination_theorem_14 (Theorem 14, ~10-30 lines)
- [ ] **Task 6.10**: Verify `lean_verify gap_elimination_theorem_14` shows no `sorryAx`
- [ ] **Task 6.11**: Run `lake build`

**Timing**: 8-12 hours

**Depends on**: 5' (Theorem 5 used in Lemmas 6, 8, 9-Reynolds)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- add import

**Verification**:
- `lean_verify gap_elimination_theorem_14` shows no `sorryAx`
- No `axiom` declarations
- `lake build` passes

---

### Phase 7: IntegerModel.lean Helper Sorries [NOT STARTED]

**Goal**: Close the 2 non-critical-path sorries in IntegerModel.lean: `cofinal_decomposition_k_equiv` (line 1135) and `ordered_sum_of_good_bounded_is_good` (line 1194, k>=2 case).

**Tasks**:
- [ ] **Task 7.0**: Pre-flight: Run `lean_verify doets_lemma_1_5` to check if OrderedSum.lean:56 sorry is on the critical path.
- [ ] **Task 7.1**: Prove `cofinal_decomposition_k_equiv` (~100-150 lines). Explicit embedding M -> orderedSum with NF-evaluation preservation.
- [ ] **Task 7.2**: Prove `ordered_sum_of_good_bounded_is_good` for k>=2 (~100-200 lines). Transfer, construct SuccOrder/PredOrder on sigma type, apply `orderIsoIntOfLinearSuccPredArch` on witness side (safe -- Z-like concatenated witness, NOT M.domain).
- [ ] **Task 7.3**: Construct shift-and-glue OrderIso (~80-120 lines).
- [ ] **Task 7.4**: Verify `lean_verify very_good_implies_good` shows no `sorryAx`.

**Timing**: 5-8 hours

**Depends on**: none (can proceed in parallel with 4C chain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- potentially close doets_lemma_1_5

**Verification**:
- `lean_verify cofinal_decomposition_k_equiv` shows no `sorryAx`
- `lean_verify ordered_sum_of_good_bounded_is_good` shows no `sorryAx`
- `lean_verify very_good_implies_good` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Wire no_gaps_discrete and one_class [NOT STARTED]

**Goal**: Replace the `no_gaps_discrete` sorry (IntegerModel.lean:859) with a call to `gap_elimination_theorem_14` from Phase 6.

**Tasks**:
- [ ] **Task 8.1**: Replace `no_gaps_discrete` sorry with call to `gap_elimination_theorem_14` (~20-40 lines bridging).
- [ ] **Task 8.2**: Verify `lean_verify no_gaps_discrete` shows no `sorryAx`.
- [ ] **Task 8.3**: Verify `lean_verify one_class` shows no `sorryAx`.
- [ ] **Task 8.4**: Run `lake build`.

**Timing**: 1-2 hours

**Depends on**: 6 (gap_elimination_theorem_14 must be proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- ensure GapElimination is imported

**Verification**:
- `lean_verify no_gaps_discrete` shows no `sorryAx`
- `lean_verify one_class` shows no `sorryAx`
- No `IsSuccArchimedean` in theorem statements
- `lake build` passes

---

### Phase 9: Rewrite chronicle_is_good and Remove IsSuccArchimedean [NOT STARTED]

**Goal**: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good`. Remove `domain_succ_archimedean` from `ChronicleAsPriorModel`. Handle cascade in NEquivalence.lean.

**Tasks**:
- [ ] **Task 9.1**: Rewrite `chronicle_is_good` (IntegerModel.lean:1245, ~30-50 lines)
- [ ] **Task 9.2**: Remove `domain_succ_archimedean` from `ChronicleAsPriorModel` (ChronicleExtraction.lean:103, ~20-30 lines deleted)
- [ ] **Task 9.3**: Remove or fix `chronicleAsMonadicStructure_succ_archimedean` in NEquivalence.lean:1213 (~20-50 lines)
- [ ] **Task 9.4**: In `countermodel_discrete` (Transfer.lean:494), remove `orderIsoIntOfLinearSuccPredArch` call (~30-50 lines)
- [ ] **Task 9.5**: Propagate removal to downstream code (~10-20 lines)
- [ ] **Task 9.6**: Verify `lake build` passes

**Timing**: 3-5 hours

**Depends on**: 7 (very_good_implies_good sorry-free), 8 (one_class sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- possible adjustments

**Verification**:
- `lean_verify chronicle_is_good` shows no `sorryAx`
- No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean (except comments)
- No `IsSuccArchimedean` in ChronicleAsPriorModel
- `lake build` passes

---

### Phase 10: Discharge h_truth_corr [NOT STARTED]

**Goal**: Eliminate the h_truth_corr sorry at Transfer.lean:574 by delegating `countermodel_discrete` to `dd_countermodel_chronicle_discrete`.

**Status update**: UNBLOCKED by research report 11_phase10-blocker-research.md. The prior revert was premature -- the current `countermodel_discrete` ALREADY carries `succ_cofinal` sorry through `orderIsoIntOfLinearSuccPredArch` at line 521. Delegation to `dd_countermodel_chronicle_discrete` is **strictly better**: it eliminates h_truth_corr while retaining the same `succ_cofinal` dependency (1 sorry source instead of 2). After Phases 6-9 complete, gap elimination makes `chronicle_is_good` sorry-free, which makes both paths sorry-free.

**Tasks**:
- [ ] **Task 10.1**: Replace `countermodel_discrete` proof body with delegation to `dd_countermodel_chronicle_discrete` (~5 lines replacing ~80 lines)
- [ ] **Task 10.2**: Remove unused `zIntervalTaskFrame`, `zIntervalOmega`, `zIntervalHistory`, `h_truth_corr` infrastructure from Transfer.lean (cleanup, ~50 lines removed)
- [ ] **Task 10.3**: Verify `lean_verify countermodel_discrete` -- sorryAx from `succ_cofinal` only (same as current)
- [ ] **Task 10.4**: Verify `lake build` passes

**Timing**: 1-2 hours

**Depends on**: none (can proceed immediately, independent of Phases 4C-9)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- replace countermodel_discrete body

**Verification**:
- Transfer.lean:574 sorry eliminated
- `lean_verify countermodel_discrete` -- sorryAx only from `succ_cofinal` (same as current)
- No new sorry introduced
- `lake build` passes

---

### Phase 11: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify the entire pipeline is sorry-free with no custom axioms. Close any remaining bridging sorries.

**Tasks**:
- [ ] **Task 11.1**: Run `lean_verify countermodel_discrete` and inspect axiom list. Should show only `propext`, `Classical.choice`, `Quot.sound`.
- [ ] **Task 11.2**: Run `lean_verify bx_completeness` and inspect axiom list.
- [ ] **Task 11.3**: Trace and fix any unexpected `sorryAx`.
- [ ] **Task 11.4**: Verify no `axiom` declarations: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` should return empty.
- [ ] **Task 11.5**: Run full `lake build`.
- [ ] **Task 11.6**: Verify no new `sorry` on critical path.
- [ ] **Task 11.7**: Verify `stavi_expressive_completeness` is sorry-free (GHR93 proof, not axiom).
- [ ] **Task 11.8**: Update file-level documentation.

**Timing**: 1-2 hours

**Depends on**: 9 (all upstream work), 10 (h_truth_corr discharge)

**Verification**:
- `#print axioms bx_completeness` shows: propext, Classical.choice, Quot.sound (NO sorryAx, NO custom axioms)
- `#print axioms stavi_expressive_completeness` shows: propext, Classical.choice, Quot.sound
- `lake build` passes with zero errors
- No `axiom` declarations in WeakCanonical directory
- No `IsSuccArchimedean` in no_gaps_discrete, one_class, or chronicle_is_good
- No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound`
- [ ] `#print axioms countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` shows no `sorryAx`
- [ ] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `#print axioms gap_elimination_theorem_14` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms very_good_implies_good` shows no `sorryAx`
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` returns empty
- [ ] No `IsSuccArchimedean` in `no_gaps_discrete`, `one_class`, or `chronicle_is_good` theorem statements
- [ ] No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean (except comments)
- [ ] `domain_succ_archimedean` removed from `ChronicleAsPriorModel`
- [ ] No new `sorry` introduced on the critical path

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` -- Stavi connective semantics, discrete equivalences, flatten_stavi_correct (Phases 4A + 5, COMPLETED)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Full EF game infrastructure + stavi_expressive_completeness + Lemma 9 gap detection (Phases 4B + 4C)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- GHR93 Theorem 6 main proof, four cases (Phase 4C)
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- Reynolds Lemmas 6-13, Theorem 14 (Phase 6, NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Chronicle truth, z_interval_countermodel, h_truth_corr, IsSuccArchimedean removal (Phases 1-3, 9-10)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- cofinal_decomposition, ordered_sum, no_gaps_discrete, chronicle_is_good (Phases 7-9)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- domain_succ_archimedean removal (Phase 9)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- IsSuccArchimedean cascade fix (Phase 9)
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- This plan (v8)

## Rollback/Contingency

1. **Phase 4C-W1 (infimum-based d)**: If the infimum approach stalls, fall back to Option C (Classical.choice canonical strategy response). D-consistency becomes `rfl`, and `d <= a_n` is still needed but may be provable via a simpler formula-agreement argument. If Case II rewrite exceeds 200 lines, try the case split approach: `d = a_bwd(n)` (old proof works) vs `d < a_bwd(n)` (new argument needed for a smaller set of proof obligations).
2. **Phase 4C-W1 (degenerate intervals)**: If establishing c=x when d=x' proves difficult from the forward strategy, weaken SplitPointProps to make sigma optional when x'=d (disjunctive field: either sigma exists, or interval is degenerate with boundary agreement).
3. **Phase 4C-W2 (gap existence lemma)**: If the full gap existence lemma exceeds 250 lines, prove the forward and backward directions separately. The backward direction (gap -> U') is simpler and unblocks some Lemma 9 cases. Mark [PARTIAL] with the proved direction.
4. **Phase 4C-W2 (Lemma 9 S/S' cases)**: If direct analysis of flatten_stavi output exceeds 200 lines per case, try per-constructor bridge lemmas for the specific S/S' patterns (not a universal bridge, which is false, but targeted ones for the specific flatten_stavi outputs appearing in left_formula).
5. **Phase 4C-W3 (Cases III/IV)**: If stuck after 8 hours, write detailed handoff with goal states for each unfinished case. The four-case structure allows checkpointing.
6. **Phase 4C-W4 (Assembly)**: If Proposition 7 composition is too complex, try Teammate B's direct Corollary 5 route. If Lemma 11 backward is needed but intractable, mark [PARTIAL].
7. **Phase 6 (Lemmas 6-13)**: Lemma 12 (model surgery, 14 cases) can be modularized per case. Mark [PARTIAL] if stuck after 8 hours.
8. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not introduce `axiom` declarations.
