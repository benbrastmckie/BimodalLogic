# Implementation Plan: Reynolds Pipeline Activation (v7 -- Revised from Team Research Round 4)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 50-70 hours (remaining: ~40-60 hours)
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

This plan (v7) revises v6 based on team research round 4 (5 teammates: Primary, Alternatives, Critic, Horizons, Literature). Phases 1-5, 4A, and 4B are COMPLETED. Phase 4C (GHR93 Theorem 6 main proof) is IN PROGRESS with Cases I and II sorry-free (~1720 lines). The revision restructures Phase 4C based on research findings: the d-consistency sorries (lines 297, 307) are unprovable as stated and require architectural restructuring; a `flatten_stavi_correct_mu` bridge lemma is the critical prerequisite for Lemma 9; the sub-interval point witnesses are provable via Gap structure's `no_sup` property; and Propositions 6-7 are entirely unimplemented (~350-520 lines from scratch). Phase 10 (h_truth_corr) was REVERTED and is BLOCKED -- Transfer.lean:574 still has sorry. The full critical-path sorry count is 17 (13 in Phase 4C + 1 in Transfer.lean + 3 in IntegerModel.lean).

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations in the pipeline, `stavi_expressive_completeness` is sorry-free.

### Research Integration

Integrated from 10 reports across 2 rounds:

**Round 3** (integrated in v4-v6):
- `reports/03_team-research.md`: Chronicle truth, box mismatch, succ_cofinal assessment, NF-evaluation approach
- `reports/04_phase4-blocker.md`: Phase 4 blocker identifying Thm 14 <- Thm 5 <- Thm 4 <- Stavi connectives chain
- `reports/05_full-reynolds-impl.md`: Full Reynolds implementation with proof sketches for Lemmas 6-13
- `reports/06_path-b-feasibility.md`: Path B feasibility (rejected by user)
- `reports/07_ghr93-strategy-review.md`: Strategy review with h_truth_corr independence finding

**Round 4** (new in v7):
- `reports/10_team-research.md`: Synthesis -- d-consistency unprovable, flatten_stavi_correct_mu is key prerequisite, Phase 10 reverted, 17 total critical-path sorries, wave-based ordering
- `reports/10_teammate-a-findings.md`: Detailed sorry inventory with dependency ordering, mu-elimination insight, tractability assessment for Groups A-C
- `reports/10_teammate-b-findings.md`: D-consistency restructuring proposal (Alternative A), flatten_stavi_correct_mu specification, gap witness approach via no_sup
- `reports/10_teammate-c-findings.md`: Phase 10 revert discovery via git history, full 17-sorry critical-path count, d-consistency unprovability proof, Props 6-7 entirely unimplemented
- `reports/10_teammate-e-findings.md`: Literature alignment verification (faithful with necessary Lean adaptations), Reynolds/GHR93 "Lemma 9" naming collision, rank-varying Theorem 6 analysis

### Prior Plan Reference

The v6 plan (07_reynolds-pipeline-plan.md) had 12 phases. Phases 1-5, 4A, 4B: COMPLETED. Phase 4C: IN PROGRESS (Cases I, II proved; 13 sorries remain). Phase 10: BLOCKED (reverted). Lessons learned from v6:
1. **D-consistency architecture is flawed**: Setting `d = a_bwd(n)` makes d-consistency unprovable for non-deterministic strategies. Must restructure to define `d` from the strategy's canonical response (5 teammates converged on this).
2. **flatten_stavi_correct_mu bridge lemma is essential**: The paper's "Clear" for Lemma 9 conceals the gap between flatten_stavi (discrete) and stavi_temporal_truth_mu (mu-relativized on M_r). All 5 teammates identified this independently.
3. **Phase 10 was attempted and reverted**: The `zIntervalTaskFrame` uses `WorldState = Unit` which fundamentally cannot support position-dependent atom truth. The handoff checkboxes are inaccurate.
4. **Props 6-7 are from-scratch**: Zero lines of code exist. The prior plan correctly marked these TODO but underestimated the gap.
5. **Effort calibration**: Cases I and II took ~1720 lines and multiple sessions each. Cases III-IV will be comparable (~230-350 lines but depends on Lemma 9 at ~200-350 lines).

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
| D-consistency restructuring breaks Cases I/II proofs | H | M | Cases I/II use `hd_eq_an` (equality); restructuring changes this to `hd_le_an` (inequality). Verify Case I/II proofs only use the `≤` direction before restructuring. Write regression tests via lean_verify after. |
| flatten_stavi_correct_mu bridge lemma has unexpected type-level issues | H | M | The induction mirrors existing flatten_stavi_correct. If stavi_untl/snce cases fail, fall back to case-by-case bridge lemmas rather than a single universal one. |
| Lemma 9 S/S' cases are harder than estimated (>350 lines) | H | M | Develop easy cases first (atom, bot, box, neg, conj, untl, stavi_untl: ~70 lines). Then attack S/S' with bridge lemma in hand. Mark [PARTIAL] if stuck after 8 hours. |
| Props 6-7 require unforeseen Lean infrastructure (~500+ lines) | M | M | Follow GHR93 paper step-by-step. If Prop 7 composition is too complex, try direct Corollary 5 route (Teammate B's alternative). |
| Phase 10 (h_truth_corr) remains permanently BLOCKED | H | M | Phase 10 is independent of Phases 4C-9. If the architectural issue cannot be resolved, explore alternative: restructure countermodel_discrete to not use z_interval_countermodel at all, using the Reynolds pipeline's k-equivalence directly. |
| Gap elimination Lemmas 6-13 (Reynolds Section 7) exceed 12 hours | M | M | Lemma 12 (model surgery, 14 cases) is the hardest. Budget 2-3 sessions. Modularize into one sub-lemma per case. Mark [PARTIAL] with documentation. |
| Rank-varying Theorem 6 requires cross-rank coercion infrastructure | M | M | Budget 80-150 lines (not the "30-50" from prior estimates). rank_embed already preserves stavi_truth_mu. If ExtendedCarrier type-level issues arise, prove rank contraction via stavi_n_equiv_mono. |
| NEquivalence.lean cascade when removing domain_succ_archimedean | M | M | Check NEquivalence.lean:1213 for instance usage. If used by sorry-free code, provide alternative derivation rather than removing. |

## Full Sorry Inventory (17 Critical-Path Sorries)

### Phase 4C Sorries (13 across 2 files)

**EFGames.lean** (4 sorries):
| Line | Identifier | Content | Difficulty | Blocks |
|------|-----------|---------|------------|--------|
| 1423 | `left_formula_gap_detection` | Lemma 9 left (gap detection correctness) | Hard (200+ lines) | Cases III/IV, line 446 |
| 1442 | `right_formula_gap_detection` | Lemma 9 right (dual) | Medium (50+ lines after left) | Cases III/IV |
| 2423 | `ghr93_decomposition_implies_game` | Lemma 11 backward direction | Medium (80-120 lines) | Prop 7 (verify if needed) |
| 2495 | `stavi_expressive_completeness` | Corollary 5 / main theorem | Medium (80-120 lines) | Final assembly |

**ExpressivenessGeneral.lean** (9 sorries):
| Line | Context | Content | Difficulty | Blocks |
|------|---------|---------|------------|--------|
| 297 | `obtain_split_point_props` | d-consistency left | UNPROVABLE as stated | sigma/tau derivation |
| 307 | `obtain_split_point_props` | d-consistency right | UNPROVABLE as stated | sigma/tau derivation |
| 336 | `obtain_split_point_props` | h_pt_left gap case | Medium (20-40 lines) | sigma |
| 345 | `obtain_split_point_props` | h_pt_right gap case | Medium (20-40 lines) | tau |
| 351 | `obtain_split_point_props` | h_pt_xc_w gap case | Medium (20-40 lines) | SplitPointProps |
| 356 | `obtain_split_point_props` | h_pt_cy_w gap case | Medium (20-40 lines) | SplitPointProps |
| 446 | `obtain_split_point_props` | c construction gap case | Hard (50-80 lines, needs Lemma 9) | sigma/tau |
| 2350 | `ghr93_cases_III_IV` | Cases III-IV of Theorem 6 | Very Hard (230-350 lines) | main theorem |
| 2571 | `ghr93_forward_to_backward_rank_varying` | Rank-varying Theorem 6 | Medium (80-150 lines) | Prop 7 |

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
| 1 | 4C-W1 (Infrastructure fixes) | -- | NOT STARTED |
| 2 | 4C-W2 (Lemma 9 left + right) | 4C-W1 | NOT STARTED |
| 3 | 4C-W3 (c-gap-case + Cases III/IV) | 4C-W2 | NOT STARTED |
| 4 | 4C-W4 (Assembly: rank-varying Thm 6, Props 6-7, Cor 5) | 4C-W3 | NOT STARTED |
| 5 | 5' (Theorem 5 from Theorem 4) | 4C-W4 | NOT STARTED |
| 6 | 6 (Gap Elimination Lemmas 6-13, Theorem 14) | 5' | NOT STARTED |
| 7 | 7 (IntegerModel helpers), 8 (Wire no_gaps_discrete) | 6 (for 8), none (for 7) | NOT STARTED |
| 8 | 9 (Rewrite chronicle_is_good) | 7, 8 | NOT STARTED |
| 9 | 10 (h_truth_corr delegation) | -- | NOT STARTED (unblocked) |
| 10 | 11 (Final wiring) | 9, 10 | NOT STARTED |

**Execution order** (STRICT SEQUENTIAL within main chain):
4C-W1 -> 4C-W2 -> 4C-W3 -> 4C-W4 -> 5' -> 6 -> 8 -> 9 -> 11.
Phase 7 (IntegerModel helpers) can proceed in parallel with the 4C chain.
Phase 10 (h_truth_corr delegation) can proceed in parallel — delegation to dd_countermodel_chronicle_discrete is ~5 lines and carries same succ_cofinal sorry as current code.
Lemma 11 backward (EFGames.lean:2423) can proceed in parallel with any wave — verify first whether Proposition 7 actually needs it.

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

### Phase 4C-W1: Infrastructure Fixes [PARTIAL]

**Goal**: Resolve infrastructure sorries in `obtain_split_point_props` and prepare for Lemma 9.

**Implementation Findings** (from W1 implementation session):
1. **W1.1 d-consistency**: BLOCKED. The hypotheses are genuinely unprovable for non-deterministic strategies. The proposed inequality fix breaks Case II at ~30 locations (Case II requires full equality `d = a_bwd(n)`). Requires deeper restructuring: either (a) define `d` FROM the strategy's canonical response via `Classical.choice`, (b) eliminate d-consistency from strategy restriction entirely, or (c) handle degenerate x'=d case before constructing sigma.
2. **W1.2 point witnesses**: PARTIAL. Non-degenerate cases proved (gap with strict endpoint). Degenerate cases (endpoint = split point, both gaps) reveal `[d,d]` interval is unwinnable. Added `point_between_strict_gaps` and `gap_splits_interval_points` helpers.
3. **W1.3 bridge lemma**: FALSE. `flatten_stavi_correct_mu` is false for non-discrete orders because `U^mu(B,bot)` requires a "next mu-point" which doesn't exist in dense carriers. **Lemma 9 does NOT need this bridge** — proceed by direct structural analysis of left_formula/right_formula.

**Tasks**:

- [ ] **Task W1.1**: Restructure d-consistency (BLOCKED — requires deeper architectural work). Three approaches: (a) `Classical.choice` on strategy to make response deterministic, (b) parameterize restriction differently, (c) dispatch degenerate x'=d before sigma construction.
- [x] **Task W1.2**: Close sub-interval point witnesses — non-degenerate cases proved. Degenerate endpoint=gap sorries remain (structural issue: sigma game on [d,d] is unwinnable).
- [x] **Task W1.3**: ~~Develop flatten_stavi_correct_mu~~ CANCELLED — theorem is false for non-discrete orders. Lemma 9 proceeds by direct structural analysis instead.
- [x] **Task W1.4**: `lake build` passes.

**Timing**: 4-6 hours (actual: ~4 hours, partial completion)

**Depends on**: none

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- restructured point witnesses, added h_pt_M parameter
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- added point_between_strict_gaps, gap_splits_interval_points

**Verification**:
- `ghr93_case_I` and `ghr93_case_II` remain sorry-free (regression check passed)
- `lake build` passes

---

### Phase 4C-W2: Lemma 9 Gap Detection Correctness [IN PROGRESS]

**Goal**: Prove `left_formula_gap_detection` and `right_formula_gap_detection` -- the GHR93 Lemma 9 that bridges temporal formulas to gap properties. This is the single biggest blocker for the entire Phase 4C completion.

**Research Basis**: All 5 teammates identified this as the central bottleneck. The paper says "PROOF. Clear." but the Lean encoding requires substantial case analysis, especially for the S/S' cases via flatten_stavi.

**CRITICAL UPDATE**: The `flatten_stavi_correct_mu` bridge lemma (originally planned as W1.3) is **FALSE for non-discrete orders** — `U^mu(B,bot)` requires a "next mu-point" which doesn't exist in dense carriers. Lemma 9 must proceed by **direct structural analysis** of left_formula/right_formula definitions, case-by-case, without a universal bridge lemma.

**BEFORE CODING**: Re-read GHR93 Section 8, Definition 8.5 and Lemma 9. The proof is by structural induction on A. The easy cases (atom, bot, box, neg, conj) are genuinely clear. The Until/U'/Since/S' cases require careful unfolding of temporal semantics and gap definability. For the S/S' cases, directly analyze the `flatten_stavi` encoding in the specific left_formula output — do NOT attempt a universal bridge lemma.

**Tasks**:

- [ ] **Task W2.0**: Build infrastructure for Lemma 9. *(deviation: altered -- added as prerequisite task not in original plan. Proved `extendPoint_lt_iff`, `temporal_truth_mu_at_point`, `stavi_truth_mu_at_point`, `gap_detection_unique`. Also added `hD : stavi_depth D <= r` hypothesis to both theorem signatures.)*
- [ ] **Task W2.1**: Prove Lemma 9 left easy cases (~70 lines). Structural induction on A with cases:
  - `.base .atom _`: both sides false (left_formula = bot) *(completed)*
  - `.base .bot`: both sides false *(completed)*
  - `.base .box _`: both sides false (box = bot at gaps) *(completed)*
  - `.neg A`: IH + negation, using `U'(top, D) and not left(A,D)` *(needs gap existence lemma)*
  - `.conj A B`: IH + conjunction *(needs gap existence lemma)*
  - `.stavi_untl A B`: unfold U'^mu definition, `U'(B and U'(A,B), D)` *(needs gap existence lemma)*
- [ ] **Task W2.1.5**: Prove gap existence lemma: `U'(top, D)(m) <-> exists gap gamma > m, gap_def_left D, D_between`. This is the CRITICAL prerequisite for all non-trivial cases. *(deviation: added -- not in original plan, discovered during implementation as essential infrastructure)*
- [ ] **Task W2.2**: Prove Lemma 9 left hard cases (~200-300 lines). The S/S' cases use flatten_stavi. Proceed by direct analysis of the specific flatten_stavi output for each case (NOT via a universal bridge lemma):
  - `.base (.untl phi psi)`: `U'(B and U(A,B), D)` -- unfold U'^mu, analyze standard Until within mu-restricted context
  - `.base (.snce phi psi)`: left_formula produces `.base (.untl (flatten_stavi compound) (flatten_stavi D))` — directly analyze what `temporal_truth_mu` of this specific Until means at actual points, show it detects a gap defined on the left
  - `.stavi_snce A B`: similar to `.base (.snce)` — direct case analysis of the flatten_stavi output
  Each case requires showing the temporal formula at actual point m detects a gap gamma > m defined by D on the left, with D holding in (m, gamma) and A^mu(gamma) holding.
- [ ] **Task W2.3**: Prove Lemma 9 right (`right_formula_gap_detection`, ~50 lines after left). Dual of left by swapping U<->S, U'<->S', future<->past.
- [ ] **Task W2.4**: Verify `lake build` passes.

**Timing**: 8-14 hours (increased estimate — no bridge lemma shortcut)

**Depends on**: none (W1.3 bridge lemma is cancelled; Lemma 9 proceeds independently)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close sorries at lines 1423, 1442

**Verification**:
- `lean_verify left_formula_gap_detection` shows no `sorryAx`
- `lean_verify right_formula_gap_detection` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W3: c-Gap-Case + Cases III/IV [NOT STARTED]

**Goal**: Close the c-gap-case sorry (line 446) using Lemma 9, then prove Cases III and IV of GHR93 Theorem 6. This completes the four-case exhaustion of the inductive step.

**Research Basis**: Cases III (left-defined gap) and IV (right-defined gap) require Lemma 9 for gap detection. The c-gap-case at line 446 also requires Lemma 9 to locate a compatible gap in M when d is a gap in N.

**BEFORE CODING**: Re-read GHR93 Section 8, Theorem 6 proof for Cases III and IV. Case III constructs delta = left(B, D) where B = X_{a_n} and D defines the gap a_n on the left. Case IV constructs delta = A and not D and U(right(B,D), A) for gaps defined on the right.

**Tasks**:

- [ ] **Task W3.1**: Close c-gap-case in `obtain_split_point_props` (line 446, ~50-80 lines). When d is a gap in N, use Lemma 9 (left_formula_gap_detection) to find a compatible gap c in M with matching rank_type. Apply the forward game's formula agreement to transfer the gap detection from N to M.
- [ ] **Task W3.2**: Split `ghr93_cases_III_IV` into `ghr93_case_III` and `ghr93_case_IV`. Case III (a_n is left-defined gap, ~120-180 lines): Construct B = X_{a_n}, delta = left(B,D). Use tau for a_0,...,a_{n-1}. Apply Lemma 9 left to find t < gamma with delta(t) and A on (e_{n-1}, t). Find matching gap e_n via formula agreement.
- [ ] **Task W3.3**: Prove Case IV (a_n is gap, not left-defined, ~120-180 lines): Construct B = X_{a_n}, delta = A and not D and U(right(B,D), A). Use tau for earlier points. Apply Lemma 9 right with right(B,D) to find matching gap via right-definability.
- [ ] **Task W3.4**: Verify that `ghr93_inductive_step` assembly still compiles with the split Cases III/IV.
- [ ] **Task W3.5**: Verify `lake build` passes.

**Timing**: 6-10 hours

**Depends on**: 4C-W2 (Lemma 9 proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close line 446, replace line 2350 sorry with Cases III/IV proofs

**Verification**:
- `obtain_split_point_props` has 0 sorries
- `lean_verify ghr93_inductive_step` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W4: Assembly -- Rank-Varying Thm 6, Props 6-7, Corollary 5 [NOT STARTED]

**Goal**: Complete the assembly chain from Theorem 6 to `stavi_expressive_completeness` (GHR93 Corollary 5). This includes the rank-varying Theorem 6, Propositions 6 and 7 (entirely from scratch), and the final Corollary 5. Optionally prove Lemma 11 backward if Proposition 7 requires it.

**Research Basis**: Teammate C confirmed Props 6-7 are entirely unimplemented (zero lines). Teammate E identified that Prop 7 requires the rank-varying Theorem 6 (sorry'd at line 2571). Teammate B noted Lemma 11 backward may be deferrable if Prop 7 uses only the forward direction -- verify this first.

**BEFORE CODING**: Re-read GHR93 Section 8, Propositions 6-7 and Corollary 5 (pages 113-114 of the paper). Determine whether Proposition 7 needs the backward direction of Lemma 11 (ghr93_decomposition_implies_game) or only the forward direction (already proved).

**Tasks**:

- [ ] **Task W4.1**: Prove rank-varying Theorem 6 (`ghr93_forward_to_backward_rank_varying`, line 2571, ~80-150 lines). Apply the uniform-rank `ghr93_forward_to_backward` at rank r+4n, then transport backward strategy from rank r+4n to rank r using `rank_embed_stavi_truth_mu` (already proved, lines 985-1044). Handle ExtendedCarrier type changes between ranks via `stavi_n_equiv_mono`.
- [ ] **Task W4.2**: Verify whether Proposition 7 needs Lemma 11 backward. Read GHR93 Proposition 7 proof structure. If backward direction IS needed, prove `ghr93_decomposition_implies_game` (line 2423, ~80-120 lines) by constructing Duplicator's strategy from decomposition agreement.
- [ ] **Task W4.3**: Prove Proposition 6 (~100-150 lines, entirely new). Statement: If M and N agree on all temporal formulas of rank r + 4n + 1, Duplicator has winning strategies for G_{n;r} on both future and past intervals. Uses X_t type formulas and decomposition formulas. Define proposition signature and prove by constructing Duplicator's selections from type formula agreement.
- [ ] **Task W4.4**: Prove Proposition 7 (~150-250 lines, entirely new). Composition theorem: If Duplicator wins G_{f(n);g(n)+4f(n)} on all sub-intervals between corresponding selected points (both forward and backward), she wins the standard EF game G_n. Proof by induction on n, using rank-varying Theorem 6 to convert forward to backward at each level.
- [ ] **Task W4.5**: Prove Corollary 5 = close `stavi_expressive_completeness` (line 2495, ~80-120 lines). Assembly: Given MonadicFormula psi of depth n, choose temporal formulas of rank 1+g(n+1) partitioning complete types. The type consistent with psi gives the StaviFormula A. Uses Props 5, 6, 7. Close the sorry in EFGames.lean.
- [ ] **Task W4.6**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`.
- [ ] **Task W4.7**: Run `lake build`.

**Timing**: 8-14 hours

**Depends on**: 4C-W3 (Theorem 6 fully proved, all 4 cases)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- rank-varying Thm 6 (line 2571), Propositions 6-7 (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close stavi_expressive_completeness (line 2495), possibly Lemma 11 bwd (line 2423)

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

**Status update**: UNBLOCKED by research report 11_phase10-blocker-research.md. The prior revert was premature — the current `countermodel_discrete` ALREADY carries `succ_cofinal` sorry through `orderIsoIntOfLinearSuccPredArch` at line 521. Delegation to `dd_countermodel_chronicle_discrete` is **strictly better**: it eliminates h_truth_corr while retaining the same `succ_cofinal` dependency (1 sorry source instead of 2). After Phases 6-9 complete, gap elimination makes `chronicle_is_good` sorry-free, which makes both paths sorry-free.

**Research Basis**: Report 11 (Phase 10 blocker research) confirmed:
1. `zIntervalTaskFrame` with `WorldState = Unit` fundamentally cannot support position-dependent atom truth
2. `dd_countermodel_chronicle_discrete` uses `ParametricCanonicalTaskFrame` with MCS-based world states — architecturally correct
3. Both paths carry `succ_cofinal` sorry via `chronicle_is_good` — delegation adds no new sorries
4. Type signatures match exactly; all imports already present

**Tasks**:
- [ ] **Task 10.1**: Replace `countermodel_discrete` proof body with delegation to `dd_countermodel_chronicle_discrete` (~5 lines replacing ~80 lines)
- [ ] **Task 10.2**: Remove unused `zIntervalTaskFrame`, `zIntervalOmega`, `zIntervalHistory`, `h_truth_corr` infrastructure from Transfer.lean (cleanup, ~50 lines removed)
- [ ] **Task 10.3**: Verify `lean_verify countermodel_discrete` — sorryAx from `succ_cofinal` only (same as current)
- [ ] **Task 10.4**: Verify `lake build` passes

**Timing**: 1-2 hours

**Depends on**: none (can proceed immediately, independent of Phases 4C-9)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` — replace countermodel_discrete body

**Verification**:
- Transfer.lean:574 sorry eliminated
- `lean_verify countermodel_discrete` — sorryAx only from `succ_cofinal` (same as current)
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
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Full EF game infrastructure + stavi_expressive_completeness + flatten_stavi_correct_mu bridge lemma (Phases 4B + 4C)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- GHR93 Theorem 6 main proof, four cases (Phase 4C)
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- Reynolds Lemmas 6-13, Theorem 14 (Phase 6, NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Chronicle truth, z_interval_countermodel, h_truth_corr, IsSuccArchimedean removal (Phases 1-3, 9-10)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- cofinal_decomposition, ordered_sum, no_gaps_discrete, chronicle_is_good (Phases 7-9)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- domain_succ_archimedean removal (Phase 9)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- IsSuccArchimedean cascade fix (Phase 9)
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- This plan (v7)

## Rollback/Contingency

1. **Phase 4C-W1 (d-consistency restructuring)**: If changing `hd_eq_an` to `hd_le_an` breaks Cases I/II, revert and instead add ConditionallyCompleteLattice on ExtendedCarrier (expensive: ~200-300 lines, but mathematically correct per GHR93's infimum approach).
2. **Phase 4C-W2 (Lemma 9)**: If flatten_stavi_correct_mu bridge lemma fails, try per-constructor bridge lemmas (one for each StaviFormula constructor) rather than a universal lemma. If S/S' cases exceed 300 lines, mark [PARTIAL] with documentation of proved cases.
3. **Phase 4C-W3 (Cases III/IV)**: If stuck after 8 hours, write detailed handoff with goal states for each unfinished case. The four-case structure allows checkpointing.
4. **Phase 4C-W4 (Assembly)**: If Proposition 7 composition is too complex, try Teammate B's direct Corollary 5 route. If Lemma 11 backward is needed but intractable, mark [PARTIAL].
5. **Phase 6 (Lemmas 6-13)**: Lemma 12 (model surgery, 14 cases) can be modularized per case. Mark [PARTIAL] if stuck after 8 hours.
6. **Phase 10 (h_truth_corr)**: BLOCKED. Do not attempt without architectural design. If permanently blocked, explore option (b): restructure countermodel_discrete to bypass z_interval_countermodel entirely.
7. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not introduce `axiom` declarations.
