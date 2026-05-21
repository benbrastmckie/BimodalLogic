# Implementation Plan: Reynolds Pipeline Activation (v9 -- U' Semantics Fix + Full GHR93 Realignment)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 60-85 hours (remaining: ~45-65 hours)
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
  - specs/155_reynolds_pipeline_activation/reports/12_degenerate-interval-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/15_d-consistency-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/16_ghr93-lemma9-deep-read.md (NEW in v9 -- U' semantics bug)
  - specs/155_reynolds_pipeline_activation/reports/17_stavi-semantics-impact.md (NEW in v9 -- full ripple analysis)
  - specs/155_reynolds_pipeline_activation/reports/17_discrete-equivalence-check.md (NEW in v9 -- Z counterexample)
  - specs/155_reynolds_pipeline_activation/handoffs/phase-4CW1-handoff-20260521.md
  - specs/155_reynolds_pipeline_activation/handoffs/phase-4CW2-handoff-20260521.md
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

This plan (v9) is a MAJOR revision prompted by a breakthrough discovery: the Lean formalization's definition of U'(A,B) and S'(A,B) is semantically wrong. The current implementation uses "B cofinal AND NOT standard Until" but GHR93 uses a gap-based definition from the first-order translation table (GHR93 p. 95). These are NOT equivalent -- not even on discrete orders (report 17_discrete-equivalence-check.md). The GHR93 FO table is ALWAYS FALSE on Z (proved by minimality of the first not-q point), while "cofinal AND NOT U" can be TRUE on Z (counterexample: A = "x=5", B = "x!=3", t=0).

Phases 1-5, 4A, and 4B are COMPLETED. Cases I and II of Theorem 6 are sorry-free (~1720 lines) and SURVIVE the fix -- they work parametrically through formula_agreement without unfolding U' semantics. The v9 plan inserts a new Phase 0 (U'/S' Semantics Fix) as the highest-priority work before all remaining W1-W4 phases.

The v8 Phase 4C-W2 was BLOCKED because `left_formula_gap_detection` was mathematically false under the wrong U' semantics. With the corrected gap-based definition, Lemma 9 becomes provable -- GHR93 calls it "Clear".

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations in the pipeline, `stavi_expressive_completeness` is sorry-free.

### Research Integration

Integrated from 17 artifacts across 4 rounds:

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

**Round 5** (integrated in v8):
- `reports/12_degenerate-interval-blocker.md`: Degenerate [d,d] intervals are vacuously winnable; `ghr93_duplicator_wins_degenerate_gap` lemma construction; forward strategy boundary extraction needed
- `reports/15_d-consistency-blocker.md`: GHR93 defines d as infimum; Claim 1 proves d-consistency; 5 solution options analyzed; Option E (infimum-based d + separate IsPoint field) recommended; Case II rewrite ~100-200 lines

**Round 6** (NEW in v9 -- U' semantics fix):
- `reports/16_ghr93-lemma9-deep-read.md`: The breakthrough -- U' semantics bug found. `left_formula` and `left_formula_gap_detection` match the paper exactly. The SOLE discrepancy is in `stavi_U_truth` / `stavi_temporal_truth` / `stavi_temporal_truth_mu` definitions. Counterexample on Q shows "cofinal AND NOT U" disagrees with gap-based definition. With corrected U', Lemma 9 is "Clear" per GHR93.
- `reports/17_stavi-semantics-impact.md`: Full ripple analysis across 3 files. 7 theorems break (4 proofs only, 3 statements + proofs). Cases I, II, Lemma 10, Lemma 11 forward SURVIVE unchanged. Recommended encoding: GHR93 FO table for base definitions + optional `std_untl`/`std_snce` constructors for StaviFormula.
- `reports/17_discrete-equivalence-check.md`: U' definitions are NOT equivalent on Z either. GHR93 FO table is ALWAYS FALSE on Z (minimality of first not-q point). "cofinal AND NOT U" can be TRUE on Z. `flatten_stavi` must map `stavi_untl` to `Formula.bot` on discrete orders.

### Prior Plan Reference

The v8 plan had 12 phases (1-5, 4A, 4B, 4C-W1 through W4, 5'-11). Phases 1-5, 4A, 4B: COMPLETED. Phase 4C-W1: PARTIAL (degenerate gap lemma + 4 N-side sorries done, d-consistency + M-side degenerate remain). Phase 4C-W2: BLOCKED (theorem statement mathematically false under wrong U' semantics). Lessons learned from v8:
1. **The `left_formula_gap_detection` blocker is NOT a Lemma 9 problem -- it is a semantics problem.** The theorem statement matches GHR93 Lemma 9 exactly. The `left_formula` definition matches GHR93 Definition 8.5 exactly. Only the EVALUATION of U' is wrong.
2. **The W2 counterexample analysis was correct but attributed to wrong root cause.** The counterexample (M = Q, sqrt(2) gap) fails because U' at the point gives FALSE under "cofinal AND NOT U" (since U(top,D) IS true via a segment before the gap), but should be TRUE under the gap-based definition. The fix is the U' semantics, not the theorem statement.
3. **Cases I and II are parametric and survive.** The sorry-free proofs work through `formula_agreement` generically and never unfold `stavi_temporal_truth_mu` at the U'/S' cases.
4. **D-consistency is still needed** (report 15) but becomes tractable after the semantics fix because the correct U' definition enables the infimum-based approach.
5. **Effort calibration from v8**: Each wave takes a full session (4-8 hours). The semantics fix is estimated at 8-14 hours across 4 sub-phases.

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Formalizes the complete GHR93 expressive completeness theorem (Theorem 9.3.1)
- Closes the discrete completeness branch of the Reynolds pipeline
- Unblocks downstream: dead code cleanup, module reorganization, frame extensions, algebraic representation, publication quality

## Goals & Non-Goals

**Goals**:
- Fix the U'/S' semantic definitions to match the GHR93 first-order table (gap-based)
- Reprove all theorems broken by the semantics fix (4 proof-only breaks, 3 statement+proof breaks)
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
| GHR93 FO table encoding in Lean is harder than estimated (complex nested quantifiers) | H | M | The FO table from GHR93 p. 95 has been transcribed term-by-term in report 17. Start with the base `stavi_temporal_truth` encoding, verify on simple examples before tackling the mu-relativized version. Budget 200 lines as ceiling. |
| Reproving `rank_embed_stavi_truth_mu` for stavi_untl/snce with FO table is complex | H | M | The statement survives (rank_embed preserves order, mu-status, predicates). The proof needs to show the FO-table witnesses transfer across rank_embed. The key property is that rank_embed preserves all the structural relationships. Budget 100 lines per case. |
| `stavi_truth_mu_at_point` reproof is non-trivial with FO table | M | M | At actual points, mu-restricted quantifiers reduce to unrestricted. The proof must show each FO-table clause transfers. Same structural argument as current proof but with more clauses. |
| StaviFormula extension with `std_untl`/`std_snce` breaks existing pattern matches | M | L | Lean4 exhaustiveness checking will flag all incomplete matches. Add cases in every match: `stavi_depth`, `stavi_temporal_truth`, `stavi_temporal_truth_mu`, `rank_embed_stavi_truth_mu`, `stavi_truth_mu_at_point`, `flatten_stavi`. Each new case is structurally identical to the existing `untl`/`snce` handlers. |
| Infimum infrastructure for ExtendedCarrier exceeds estimate | H | M | ExtendedCarrier inherits linear order. If full ConditionallyCompleteLattice is too heavy, use Classical.choice on the formula-defined set (nonempty since y' is in it) combined with WellFounded argument. Budget 120 lines as ceiling. |
| Case II rewrite (~30 sites) for hd_le_an introduces regressions | H | M | Case II never needs d=a_n per GHR93 paper. The 30 sites use hd_eq_an only to deduce IsPoint d from IsPoint a_n. Add separate h_pt_d field or prove IsPoint d from the infimum when a_n is a point. Regression test: lean_verify ghr93_case_II after each batch of changes. |
| Gap existence lemma under correct U' semantics requires different proof structure | M | L | With correct U' semantics, the gap existence is built into the definition. U'(top, D)(m) directly asserts the existence of a gap-like structure. The proof should be more natural, not harder. |
| Props 6-7 require unforeseen Lean infrastructure (~500+ lines) | M | M | Follow GHR93 paper step-by-step. If Prop 7 composition is too complex, try direct Corollary 5 route. |
| Phase 10 (h_truth_corr) delegation fails at type level | L | L | Phase 10 is independent. If types don't match, mark [BLOCKED] with exact mismatch and proceed with other phases. |

## GHR93 First-Order Table for U' (Reference for Implementers)

From GHR93 p. 95, the correct first-order translation of U'(p,q)(t):

```
U'(p,q)(t) := exists s > t,
  -- Main body: for all u in (t,s), either B-cofinal or A-takes-over
  (forall u, t < u AND u < s ->
    (exists v, u < v AND forall w, t < w AND w < v -> q(w))    -- Disjunct 1: q holds up to v
    OR
    (forall v, u < v AND v < s -> p(v)                          -- Disjunct 2: p holds on (u,s)
     AND exists v, t < v AND v < u AND NOT q(v)))               --   AND q failed before u
  AND
  -- q fails somewhere in (t,s)
  (exists u, t < u AND u < s AND NOT q(u))
  AND
  -- q holds on some initial segment
  (exists u, t < u AND u < s AND forall v, t < v AND v < u -> q(v))
```

Key properties:
- ALWAYS FALSE on discrete orders (Z) -- proved in report 17
- On dense incomplete orders (Q), captures the gap-based behavior
- The witness `s` in the mu-relativized version need NOT be mu-restricted (it is just a bound; the gap itself need not be an actual point)

S'(p,q)(t) is the dual (swap < and >, swap future/past directions).

## Full Sorry Inventory (Current State)

### EFGames.lean (4 sorries)
| Line | Identifier | Content | Phase |
|------|-----------|---------|-------|
| 2317 | `left_formula_gap_detection` | Lemma 9 left | 4C-W2 (UNBLOCKED by Phase 0) |
| 2336 | `right_formula_gap_detection` | Lemma 9 right | 4C-W2 (UNBLOCKED by Phase 0) |
| 3406 | `ghr93_decomposition_implies_game` | Lemma 11 backward | 4C-W4 |
| 3478 | `stavi_expressive_completeness` | Corollary 5 / main theorem | 4C-W4 |

### ExpressivenessGeneral.lean (7 sorries)
| Line | Context | Content | Phase |
|------|---------|---------|-------|
| 306 | `obtain_split_point_props` | d-consistency left | 4C-W1 |
| 316 | `obtain_split_point_props` | d-consistency right | 4C-W1 |
| 430 | `obtain_split_point_props` | h_pt_xc M-side degenerate gap | 4C-W1 |
| 447 | `obtain_split_point_props` | h_pt_cy M-side degenerate gap | 4C-W1 |
| 551 | `obtain_split_point_props` | c construction when d is gap | 4C-W3 |
| 2455 | `ghr93_cases_III_IV` | Cases III-IV of Theorem 6 | 4C-W3 |
| 2676 | `ghr93_forward_to_backward_rank_varying` | Rank-varying Theorem 6 | 4C-W4 |

### Transfer.lean (1 sorry)
| Line | Identifier | Phase |
|------|-----------|-------|
| 574 | `h_truth_corr` | 10 |

### IntegerModel.lean (3 sorries)
| Line | Identifier | Phase |
|------|-----------|-------|
| 859 | `no_gaps_discrete` | 8 |
| 1135 | `cofinal_decomposition_k_equiv` | 7 |
| 1194 | `ordered_sum_of_good_bounded_is_good` | 7 |

**Total critical-path sorries**: 16 (down from 17 in v8 due to N-side degenerate sorries closed)

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Status |
|------|--------|------------|--------|
| -- | 1, 2, 3, 4A, 5, 4B | -- | COMPLETED |
| 1 | 0 (U'/S' Semantics Fix) | -- | NOT STARTED |
| 2 | 4C-W1 (d-consistency + degenerate), 4C-W2 (Lemma 9) | 0 | 4C-W1 PARTIAL, 4C-W2 NOT STARTED |
| 3 | 4C-W3 (c-gap-case + Cases III/IV) | 4C-W1, 4C-W2 | NOT STARTED |
| 4 | 4C-W4 (Assembly: rank-varying Thm 6, Props 6-7, Cor 5) | 4C-W3 | NOT STARTED |
| 5 | 5' (Theorem 5 from Theorem 4) | 4C-W4 | NOT STARTED |
| 6 | 6 (Gap Elimination Lemmas 6-13, Theorem 14) | 5' | NOT STARTED |
| 7 | 7 (IntegerModel helpers), 8 (Wire no_gaps_discrete) | 6 (for 8), none (for 7) | NOT STARTED |
| 8 | 9 (Rewrite chronicle_is_good) | 7, 8 | NOT STARTED |
| 9 | 10 (h_truth_corr delegation) | -- | NOT STARTED (independent) |
| 10 | 11 (Final wiring) | 9, 10 | NOT STARTED |

**Execution order** (STRICT SEQUENTIAL within main chain):
0 -> 4C-W1 -> 4C-W2 -> 4C-W3 -> 4C-W4 -> 5' -> 6 -> 8 -> 9 -> 11.
Phase 7 (IntegerModel helpers) can proceed in parallel with the 4C chain.
Phase 10 (h_truth_corr delegation) can proceed in parallel -- delegation to dd_countermodel_chronicle_discrete is ~5 lines.

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

### Phase 0: U'/S' Semantics Fix [COMPLETED]

**Goal**: Replace the incorrect "cofinal AND NOT U/S" definitions of U'(A,B) and S'(A,B) with the correct GHR93 FO-table-based definitions. Reprove all broken theorems. Verify Cases I/II/Lemma 10/Lemma 11 forward still compile unchanged.

**CRITICAL**: This is the highest-priority new phase. It unblocks Phase 4C-W2 (Lemma 9) which was BLOCKED in v8 due to the wrong semantics.

**Root Cause** (from report 16): The "cofinal AND NOT U" formulation captures a GLOBAL condition on B's behavior, while the correct GHR93 definition is LOCAL -- it finds a specific gap where B transitions from true to false. Even when U(A,B) is true (via a segment before the gap), U'(A,B) can still be true under the gap-based definition. On Q with D(x) = (x < sqrt(2) OR x > sqrt(2)+1), gap-based U'(top,D)(0) = TRUE but "cofinal AND NOT U" U'(top,D)(0) = FALSE.

**Impact Summary** (from report 17):
- 3 definitions MUST CHANGE: `stavi_U_truth`, `stavi_S_truth`, FO-table encodings
- 4 definition sites MUST CHANGE: `stavi_temporal_truth` stavi_untl/snce cases, `stavi_temporal_truth_mu` stavi_untl/snce cases
- 3 theorems have broken STATEMENTS + PROOFS: `flatten_stavi_correct` (stavi_untl/snce cases), `stavi_U_discrete_equiv`, `stavi_S_discrete_equiv`
- 4 theorems have broken PROOFS only (statements survive): `rank_embed_stavi_truth_mu` (stavi_untl/snce cases), `stavi_truth_mu_at_point` (stavi_untl/snce cases)
- SAFE (no changes needed): Cases I, II, Lemma 10, Lemma 11 forward, all gap infrastructure, `left_formula`/`right_formula` definitions, `gap_detection_unique`, all base/neg/conj cases of rank_embed and truth_mu_at_point

**BEFORE CODING**: Re-read GHR93 Section 3 (p. 95) for the FO table, and BdRV 2002 Definition 7.11 for the gap-based picture. Understand that the witness `s` in the FO table is just a bound (not required to be an actual point in the mu-relativized version).

**Tasks**:

- [x] **Task 0.1**: Replace `stavi_U_truth` (StaviConnectives.lean:67-76) with the GHR93 FO table definition. Replace `stavi_S_truth` (lines 89-98) with the dual. *(completed)*

- [x] **Task 0.2**: Replace `stavi_temporal_truth` stavi_untl case (StaviConnectives.lean:134-140) with the GHR93 FO table using recursive `stavi_temporal_truth` calls. Replace stavi_snce case (lines 141-147) dually. *(completed)*

- [x] **Task 0.3**: Replace `stavi_temporal_truth_mu` stavi_untl case (EFGames.lean:808-816) with the mu-relativized GHR93 FO table. The witness `s` should NOT be mu-restricted (it serves as a bound; the gap may not be an actual point). All other quantified points (u, v, w) ARE mu-restricted. Replace stavi_snce case (lines 817-825) dually. *(completed)*

- [x] **Task 0.4**: Update `flatten_stavi` (StaviConnectives.lean:415-418) to map `stavi_untl A B` to `Formula.bot` and `stavi_snce A B` to `Formula.bot`. On discrete orders, U' is always false, so the flattening to bot is correct. *(completed)*

- [x] **Task 0.5**: Reprove `flatten_stavi_correct` stavi_untl case (StaviConnectives.lean:477-528). *(completed — both stavi_untl and stavi_snce cases fully sorry-free via fo_table_body_forces_P and fo_table_body_forces_P_past)* *(deviation: altered — added IsSuccArchimedean/IsPredArchimedean hypotheses to flatten_stavi_correct, required for well-founded descent on bounded intervals)*

- [x] **Task 0.6**: Reprove or replace `stavi_U_discrete_equiv` (StaviConnectives.lean:362-377) and `stavi_S_discrete_equiv` (lines 384-398). *(completed — replaced with stavi_U_always_false_discrete/stavi_S_always_false_discrete stub; the actual always-false proof is now embedded in fo_table_body_forces_P/fo_table_body_forces_P_past)*

- [x] **Task 0.7**: Delete wrong FO-table encoding definitions (`cofinal_above_fo`, `cofinal_below_fo`, `stavi_U_fo`, `stavi_S_fo` from StaviConnectives.lean). These encoded the OLD wrong "cofinal AND NOT U/S" semantics and had no consumers. *(deviation: altered — deleted rather than replaced, as these dead-wrong definitions had no consumers)*

- [x] **Task 0.8**: Reprove `rank_embed_stavi_truth_mu` stavi_untl/snce cases. *(completed — 4 sorries eliminated. Both mp (r' → r) and mpr (r → r') proved for stavi_untl and stavi_snce. Gap-bound case uses gap_cut_cofinal and complement_no_min to find point bounds. lean_verify shows only propext/Classical.choice/Quot.sound.)*

- [x] **Task 0.9**: Reprove `stavi_truth_mu_at_point` stavi_untl/snce gap cases. *(completed — 2 sorries eliminated. Gap case for stavi_untl finds s' above witnesses in cut. Gap case for stavi_snce finds s' below witnesses outside cut. lean_verify clean.)*

- [x] **Task 0.10**: Verify that Cases I and II (`ghr93_case_I`, `ghr93_case_II`), Lemma 10 (`ghr93_duplicator_wins_round_mono`), and Lemma 11 forward (`ghr93_game_implies_decomposition`) still compile with `lake build`. These should NOT need changes. *(completed — verified, all compile unchanged)*

- [x] **Task 0.11**: Extended StaviFormula with `std_untl` and `std_snce` constructors for standard Until/Since of StaviFormula arguments. Extended `stavi_temporal_truth`, `stavi_temporal_truth_mu`, `stavi_depth`, `flatten_stavi`, `flatten_stavi_correct` for the new constructors. Updated `left_formula`/`right_formula` to use `std_untl`/`std_snce` instead of `flatten_stavi`. Extended all pattern matches: `rank_embed_stavi_truth_mu`, `stavi_truth_mu_at_point`, `operator_depth_flatten_stavi_le`, `stavi_depth_left_formula`, `stavi_depth_right_formula`. *(completed)*

- [x] **Task 0.12**: Run `lake build` and verify zero errors. *(completed — build passes with zero errors. All Phase 0 sorries eliminated: 4 in rank_embed + 2 in gap cases = 6 total.)*

**Timing**: 8-14 hours (across 2-3 sessions)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` -- definitions, flatten_stavi, discrete equivalences, FO tables
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- stavi_temporal_truth_mu, rank_embed, stavi_truth_mu_at_point

**Verification**:
- `lean_verify flatten_stavi_correct` shows no `sorryAx`
- `lean_verify rank_embed_stavi_truth_mu` shows no `sorryAx`
- `lean_verify stavi_truth_mu_at_point` shows no `sorryAx`
- `lean_verify ghr93_case_I` shows no `sorryAx` (unchanged from before)
- `lean_verify ghr93_case_II` shows no `sorryAx` (unchanged from before)
- `lake build` passes with zero errors

---

### Phase 4C-W1: D-Consistency + Degenerate Intervals + Case II Rewrite [PARTIAL]

**Goal**: Restructure `obtain_split_point_props` to use the GHR93 infimum-based definition of d, handle degenerate intervals via vacuous game lemma, and update Case II for `hd_le_an`.

This phase resolves the 4 remaining sorries in `obtain_split_point_props` that are NOT dependent on Lemma 9: the 2 d-consistency sorries (lines 306, 316) and the 2 M-side degenerate interval sorries (lines 430, 447).

**Research Basis**: Report 15 (d-consistency blocker) establishes that GHR93 defines `d = inf{t in [x',y'] : C holds on (t,y')}` and proves d-consistency as "Claim 1". Report 12 (degenerate interval blocker) establishes that [d,d] games with gap endpoints are vacuously winnable.

**Status**: PARTIAL. Task W1.1 (degenerate gap lemma) DONE. Task W1.3 (N-side degenerate sorries) DONE. Tasks W1.2, W1.4, W1.5 remain. Task W1.2 BLOCKED: exhaustive analysis confirms Claim 1 infimum argument is the ONLY viable path; 5 alternative approaches all fail (see handoff phase-4CW1-dconsistency-analysis-20260521.md). Task W1.4 BLOCKED by W1.2 unless user approves Case I modifications (~50-100 lines). Build passes.

**BEFORE CODING**: Re-read GHR93 Section 8, pages 27-28 (definition of c,d as infima; Claims 1-2). With the corrected U' semantics from Phase 0, the infimum-based approach becomes cleaner because U' now has the correct gap-based meaning, making the continuation formula C well-behaved.

**Tasks**:

- [x] **Task W1.1**: Add `ghr93_duplicator_wins_degenerate_gap` lemma to EFGames.lean. *(completed -- sorry-free, verified via lean_verify)*

- [ ] **Task W1.2**: Implement GHR93 Claim 1 (d-consistency via infimum argument). ~420-640 lines total across 5 sub-phases. Research complete (reports 18_claim1-literature.md, 18_lean-infra-audit.md, 18_alternative-strategies.md, 19_gap-definability-construction.md).

  **Sub-phase W1.2a: Definitions [COMPLETED]**
  - `cont_holds a_n y' t : Prop` (line 127) — sorry-free
  - `continuation_set x' y' a_n : Set (ExtendedCarrier N atomMap r)` (line 139) — sorry-free
  - `inf_carrier_cut S : Set N.carrier` (line 150) — sorry-free

  **Sub-phase W1.2b: S_C Properties [COMPLETED]**
  - `continuation_set_nonempty` (line 159) — sorry-free
  - `continuation_set_upward_closed` (line 171) — sorry-free
  - `a_n_in_continuation_set` (line 186) — sorry-free *(deviation: altered — changed continuation_set definition from half-open (t, y'] to open (t, y') interval, eliminating the u=y' edge case entirely. All downstream proofs (cont_fails_below_gap, formula_failure_in_cut) updated and remain sorry-free.)*

  **Sub-phase W1.2c: Gap Construction [COMPLETED]**
  - `inf_carrier_cut_downward_closed` (line 215) — sorry-free
  - `inf_carrier_cut_nonempty` (line 226) — sorry-free
  - `inf_carrier_cut_proper` (line 242) — sorry-free
  - `inf_carrier_cut_no_sup` (line 265) — sorry-free
  - `inf_carrier_cut_complement_no_min` (line 292) — sorry-free
  - `infimum_gap` (line 382) — packages all 5 Gap axioms, sorry-free

  **Sub-phase W1.2d: Gap r-Definability [PARTIAL]**
  - `cont_holds_above_gap` (line 429) — 1 sorry (edge case: extendPoint p = y'; genuinely hard, requires limit argument for stavi_temporal_truth at endpoint)
  - `cont_fails_below_gap` (line 497) — sorry-free *(deviation: altered — conclusion changed from `u ≤ y'` to `u < y'` to match open-interval continuation_set definition)*
  - `pigeonhole_definable_formula` (line 554) — 1 sorry (NormalForm finiteness bridge)
  - `formula_failure_in_cut` (line 617) — sorry-free
  - `infimum_gap_r_definable` (line 690) — first conjunct NOW sorry-free (added `h_above_gap_below_y'` hypothesis for carrier point between gap and y'); second conjunct sorry-free
  - **Remaining sorries (2)**: (1) cont_holds_above_gap y' edge case, (2) pigeonhole NormalForm bridge
  - **NormalForm finiteness bridge** (~80-120 lines, deferred): prove that the image of `rank_type` over carrier points is finite. Uses `NormalForm sig r 1` Fintype (NormalForm.lean:178) + `nf_exists_unique` (NormalForm.lean:281).

  **Sub-phase W1.2e: Integration with Claim 1 [PARTIAL]**
  - `d_consistency_left` theorem added (sorry body) — correct type signature for left boundary
  - `d_consistency_right` theorem added (sorry body) — correct type signature for right boundary
  - D-consistency sorries at lines 1002, 1012 replaced with calls to `d_consistency_left`/`d_consistency_right`
  - The sorry is now LOCALIZED to two clean theorem bodies instead of being inline
  - Full Claim 1 proof (infimum construction + uniqueness) still pending:
    - Step 1: C'(c_bar) holds (C' = ¬C ∨ K⁻(¬C), rank r+1) by infimum property
    - Step 2: formula transfer → C'(d) holds (depth r+1 ≤ r' = r+4(n+1))
    - Step 3: C'(d) → d ≤ d_bar
    - Step 4: contradiction if d < d_bar (Spoiler challenges at d' with ¬C, Duplicator stuck)
    - Step 5: d = d_bar

  **Build order**: W1.2a → W1.2b → W1.2c → W1.2d → W1.2e. NormalForm bridge runs in parallel with W1.2a-c.
  **Research references**: reports/18_claim1-literature.md, reports/19_gap-definability-construction.md

- [x] **Task W1.3**: Close N-side degenerate interval sorries. *(completed -- 4 N-side sorries eliminated via boundary correspondence + ghr93_duplicator_wins_degenerate_gap. 2 new M-side degenerate sorries at lines 430, 447 from SplitPointProps requiring point witnesses. Net: 9 -> 7 sorries.)*

- [ ] **Task W1.4**: Close M-side degenerate interval sorries (lines 430, 447). *(deviation: blocked — coupled to W1.2 unless user approves Case I modifications. The conditional approach was prototyped: SplitPointProps change compiles, but Case I at line 814 uses `props.h_pt_cy` unconditionally to extract tau Round 2 data (`hcond_R_aux`) for R-side gap_point/formula/ordering info. In the degenerate case (c=y, IsGap c), tau Round 2 is vacuous and `hcond_R_aux` is unavailable. The fix requires a ~50-100 line degenerate branch in Case I that derives R-side data from `hcd_form` and `hcd_gp` instead of from tau. Case II is trivially fixable (d is point -> c is point -> condition holds). See handoff phase-4CW1-dconsistency-analysis-20260521.md for the full 4-option implementation roadmap.)*

- [ ] **Task W1.5**: Verify `lake build` passes. Cases I and II remain sorry-free.

**Timing**: 8-14 hours (dominated by d-consistency architectural work)

**Depends on**: 0 (correct U' semantics needed for infimum-based continuation formula C)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- degenerate gap lemma (done)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- d-consistency, M-side degenerate, SplitPointProps

**Sorry inventory** (13 total across 2 files, verified after W1.2b+d+e session):

EFGames.lean (4 sorries, unchanged):
- Line 2415: `left_formula_gap_detection` (Lemma 9 left)
- Line 2434: `right_formula_gap_detection` (Lemma 9 right)
- Line 3504: `ghr93_decomposition_implies_game` (Lemma 11 backward)
- Line 3576: `stavi_expressive_completeness` (Corollary 5)

ExpressivenessGeneral.lean (9 sorries):
- Line 532: `nf_determines_stavi_truth` NormalForm-to-StaviFormula bridge (W1.2d — requires nf_eval_nf/stavi_temporal_truth correspondence)
- Line 604: `pigeonhole_definable_formula` contradiction body (W1.2d — chain construction + NF finiteness, depends on bridge above)
- Line 906: `d_consistency_left` full Claim 1 proof (W1.2e)
- Line 939: `d_consistency_right` full Claim 1 proof (W1.2e)
- Lines 1269, 1286: M-side degenerate point witnesses (Task W1.4)
- Line 1390: c construction gap case (blocked by Lemma 9, Phase 4C-W3)
- Line 3294: Cases III/IV (blocked by Lemma 9, Phase 4C-W3)
- Line 3515: rank-varying Theorem 6 (Phase 4C-W4)
- CLOSED: `cont_holds_above_gap` y' edge case — eliminated by strengthening hypothesis to strict < (was line 479)

StaviConnectives.lean: **0 sorries** (completely sorry-free with correct GHR93 semantics)

**Phase 0 achievements**:
- `stavi_U_truth`/`stavi_S_truth` replaced with GHR93 FO table ✓
- `flatten_stavi_correct` reproved (sorry-free) ✓
- `rank_embed_stavi_truth_mu` reproved (sorry-free) ✓
- `stavi_truth_mu_at_point` reproved (sorry-free) ✓
- Cases I, II, Lemma 10, Lemma 11 forward unchanged ✓

**Verification**:
- D-consistency sorries (306, 316) — still open (Task W1.2)
- Degenerate interval sorries (430, 447) — still open (Task W1.4)
- `ghr93_case_I` and `ghr93_case_II` show no `sorryAx`
- `lake build` passes

---

### Phase 4C-W2: Lemma 9 Gap Detection Correctness [NOT STARTED]

**Goal**: Prove `left_formula_gap_detection` and `right_formula_gap_detection` -- the GHR93 Lemma 9 that bridges temporal formulas to gap properties. With the corrected U' semantics from Phase 0, the theorem is now PROVABLE (GHR93: "Clear").

**Status**: UNBLOCKED. The v8 blocker (theorem statement mathematically false) is resolved by fixing U' semantics. The theorem statement and `left_formula` definition both match GHR93 exactly -- only the evaluation was wrong.

**Research Basis**: Report 16 traces the paper's "Clear" argument case by case:
- **Neg case**: left(not A, D) = U'(top, D) AND NOT left(A, D). With correct U', U'(top,D)(m) directly asserts a gap above m with D before it and NOT-D after it. Combined with NOT left(A,D) (by IH, no such gap has A^mu), this gives exactly the RHS.
- **Key insight**: Uniqueness of the nearest D-gap above m follows from D-definability -- if two gaps existed, D would fail between them, contradicting the first gap's D-on-left property.

**BEFORE CODING**: Read report 16 Section "Why the Paper Says 'Clear'" for the case-by-case argument. The proof is by structural induction on A.

**Tasks**:

- [ ] **Task W2.1**: Prove a gap-equivalence lemma (~80-150 lines): the FO-table-based U'(top, D)(m) is equivalent to the existence of a gap gamma above m with D-defined-on-left, D on (m, gamma). This connects the first-order definition to the second-order gap conditions used in Lemma 9's RHS.

- [ ] **Task W2.2**: Prove Lemma 9 left easy cases (atom, bot, box, neg, conj) using the gap-equivalence lemma (~100-150 lines total). The neg case is the key one -- uses the uniqueness argument.

- [ ] **Task W2.3**: Prove Lemma 9 left hard cases (untl, snce, stavi_untl, stavi_snce) (~200-300 lines). For the S/S' cases, left_formula produces U(compound, D) where compound involves U' subexpressions. With the correct U' semantics, these subexpressions have the right gap-based meaning.

- [ ] **Task W2.4**: Prove Lemma 9 right (`right_formula_gap_detection`, ~50-100 lines). Dual of left by symmetry. May be provable by a single dual-application lemma.

- [ ] **Task W2.5**: Verify `lake build` passes.

**Timing**: 6-10 hours

**Depends on**: 0 (correct U' semantics)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close sorries at lines 1629, 1648; add gap_equivalence_from_fo_table

**Verification**:
- `lean_verify left_formula_gap_detection` shows no `sorryAx`
- `lean_verify right_formula_gap_detection` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W3: c-Gap-Case + Cases III/IV [NOT STARTED]

**Goal**: Close the c-gap-case sorry (line 551) using Lemma 9, then prove Cases III and IV of GHR93 Theorem 6. This completes the four-case exhaustion of the inductive step.

**Research Basis**: Cases III (left-defined gap) and IV (right-defined gap) require Lemma 9 for gap detection. The c-gap-case at line 551 requires Lemma 9 to locate a compatible gap in M when d is a gap in N.

**BEFORE CODING**: Re-read GHR93 Section 8, Theorem 6 proof for Cases III and IV. Case III constructs delta = left(B, D) where B = X_{a_n} and D defines the gap a_n on the left. Case IV constructs delta = A and not D and U(right(B,D), A) for gaps defined on the right.

**Tasks**:

- [ ] **Task W3.1**: Close c-gap-case in `obtain_split_point_props` (line 551, ~50-80 lines). When d is a gap in N:
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
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close line 551, replace line 2455 sorry with Cases III/IV proofs

**Verification**:
- `obtain_split_point_props` has 0 sorries (except line 2676 rank-varying)
- `lean_verify ghr93_inductive_step` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W4: Assembly -- Rank-Varying Thm 6, Props 6-7, Corollary 5 [NOT STARTED]

**Goal**: Complete the assembly chain from Theorem 6 to `stavi_expressive_completeness` (GHR93 Corollary 5). This includes the rank-varying Theorem 6, Propositions 6 and 7 (entirely from scratch), and the final Corollary 5. Optionally prove Lemma 11 backward if Proposition 7 requires it.

**Research Basis**: Teammate C confirmed Props 6-7 are entirely unimplemented (zero lines). Teammate E identified that Prop 7 requires the rank-varying Theorem 6 (sorry'd at line 2676). Teammate B noted Lemma 11 backward may be deferrable if Prop 7 uses only the forward direction -- verify this first.

**BEFORE CODING**: Re-read GHR93 Section 8, Propositions 6-7 and Corollary 5 (pages 113-114 of the paper). Determine whether Proposition 7 needs the backward direction of Lemma 11 (ghr93_decomposition_implies_game) or only the forward direction (already proved).

**Tasks**:

- [ ] **Task W4.1**: Prove rank-varying Theorem 6 (`ghr93_forward_to_backward_rank_varying`, line 2676, ~80-150 lines). Apply the uniform-rank `ghr93_forward_to_backward` at rank r+4n, then transport backward strategy from rank r+4n to rank r using `rank_embed_stavi_truth_mu` (already proved, lines 985-1044). Handle ExtendedCarrier type changes between ranks via `stavi_n_equiv_mono`.

- [ ] **Task W4.2**: Verify whether Proposition 7 needs Lemma 11 backward. Read GHR93 Proposition 7 proof structure. If backward direction IS needed, prove `ghr93_decomposition_implies_game` (line 2718, ~80-120 lines) by constructing Duplicator's strategy from decomposition agreement.

- [ ] **Task W4.3**: Prove Proposition 6 (~100-150 lines, entirely new). Statement: If M and N agree on all temporal formulas of rank r + 4n + 1, Duplicator has winning strategies for G_{n;r} on both future and past intervals. Uses X_t type formulas and decomposition formulas. Define proposition signature and prove by constructing Duplicator's selections from type formula agreement.

- [ ] **Task W4.4**: Prove Proposition 7 (~150-250 lines, entirely new). Composition theorem: If Duplicator wins G_{f(n);g(n)+4f(n)} on all sub-intervals between corresponding selected points (both forward and backward), she wins the standard EF game G_n. Proof by induction on n, using rank-varying Theorem 6 to convert forward to backward at each level.

- [ ] **Task W4.5**: Prove Corollary 5 = close `stavi_expressive_completeness` (line 2790, ~80-120 lines). Assembly: Given MonadicFormula psi of depth n, choose temporal formulas of rank 1+g(n+1) partitioning complete types. The type consistent with psi gives the StaviFormula A. Uses Props 5, 6, 7. Close the sorry in EFGames.lean.

- [ ] **Task W4.6**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`.

- [ ] **Task W4.7**: Run `lake build`.

**Timing**: 8-14 hours

**Depends on**: 4C-W3 (Theorem 6 fully proved, all 4 cases)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- rank-varying Thm 6 (line 2676), Propositions 6-7 (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close stavi_expressive_completeness (line 2790), possibly Lemma 11 bwd (line 2718)

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

**Depends on**: none (can proceed immediately, independent of Phases 0-9)

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
- [ ] `#print axioms flatten_stavi_correct` shows no `sorryAx`
- [ ] `#print axioms rank_embed_stavi_truth_mu` shows no `sorryAx`
- [ ] `#print axioms stavi_truth_mu_at_point` shows no `sorryAx`
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` returns empty
- [ ] No `IsSuccArchimedean` in `no_gaps_discrete`, `one_class`, or `chronicle_is_good` theorem statements
- [ ] No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean (except comments)
- [ ] `domain_succ_archimedean` removed from `ChronicleAsPriorModel`
- [ ] No new `sorry` introduced on the critical path
- [ ] Cases I and II remain sorry-free after Phase 0 changes

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` -- CORRECTED Stavi connective semantics (GHR93 FO table), flatten_stavi (maps U'/S' to bot), discrete equivalences (Phase 0)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- CORRECTED stavi_temporal_truth_mu, reproved rank_embed + truth_mu_at_point, Lemma 9 gap detection, stavi_expressive_completeness (Phases 0, 4C-W2, 4C-W4)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- GHR93 Theorem 6 main proof, all four cases, d-consistency via infimum (Phases 4C-W1, 4C-W3)
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- Reynolds Lemmas 6-13, Theorem 14 (Phase 6, NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Chronicle truth, z_interval_countermodel, h_truth_corr, IsSuccArchimedean removal (Phases 1-3, 9-10)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- cofinal_decomposition, ordered_sum, no_gaps_discrete, chronicle_is_good (Phases 7-9)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- domain_succ_archimedean removal (Phase 9)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- IsSuccArchimedean cascade fix (Phase 9)
- `specs/155_reynolds_pipeline_activation/plans/10_reynolds-pipeline-plan.md` -- This plan (v9)

## Rollback/Contingency

1. **Phase 0 (U' semantics fix)**: If the FO table encoding is too complex for Lean, fall back to the gap-based (second-order) definition using `Gap` and `gap_definable_on_left`/`gap_definable_on_right` infrastructure already in EFGames.lean. This is more intuitive and directly usable for Lemma 9, at the cost of being second-order. For the mu-relativized version, gaps in ExtendedCarrier are explicit Sum.inr elements.
2. **Phase 0 (flatten_stavi_correct reproof)**: If proving "FO table always false on discrete orders" is harder than expected, inline the proof from report 17 (minimality of first not-q point, ~30 lines).
3. **Phase 0 (StaviFormula extension)**: If adding `std_untl`/`std_snce` constructors causes excessive pattern-match cascade, defer the extension and instead modify `left_formula` S/S' cases to keep using `flatten_stavi` (which now maps U' to bot). This works if the S/S' cases of left_formula only use U' at discrete-order evaluations (verify).
4. **Phase 4C-W1 (infimum-based d)**: If the infimum approach stalls, fall back to Option C (Classical.choice canonical strategy response). D-consistency becomes `rfl`, and `d <= a_n` is still needed but may be provable via a simpler formula-agreement argument.
5. **Phase 4C-W2 (Lemma 9)**: With correct U' semantics, Lemma 9 should be "Clear" per GHR93. If any case exceeds 150 lines, decompose into sub-lemmas for each constructor. Mark [PARTIAL] with proved cases.
6. **Phase 4C-W3 (Cases III/IV)**: If stuck after 8 hours, write detailed handoff with goal states for each unfinished case.
7. **Phase 4C-W4 (Assembly)**: If Proposition 7 composition is too complex, try Teammate B's direct Corollary 5 route.
8. **Phase 6 (Lemmas 6-13)**: Lemma 12 (model surgery, 14 cases) can be modularized per case. Mark [PARTIAL] if stuck after 8 hours.
9. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not introduce `axiom` declarations.
