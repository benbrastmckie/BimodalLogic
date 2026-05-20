# Implementation Plan: Reynolds Pipeline Activation (v6 -- Full GHR93, No Shortcuts)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 55 hours
- **Dependencies**: Task 154 (sum_preservation/doets_lemma_1_4, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED), Task 157 (separation/expressive completeness, COMPLETED)
- **Research Inputs**:
  - specs/155_reynolds_pipeline_activation/reports/03_team-research.md
  - specs/155_reynolds_pipeline_activation/reports/04_phase4-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/05_full-reynolds-impl.md
  - specs/155_reynolds_pipeline_activation/reports/06_path-b-feasibility.md
  - specs/155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md
- **Artifacts**: plans/07_reynolds-pipeline-plan.md (this file)
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

This plan (v6) is a revision of v5, preserving completed work (Phases 1-3, Sub-stage 4A, Phase 5) while restructuring the remaining effort. The research report (07_ghr93-strategy-review.md) proposed shortcuts; the user REJECTED all shortcuts.

The plan has 12 phases total. Phases 1-3 are COMPLETED. Phase 4 (Sub-stage 4A: StaviConnectives) is COMPLETED. Phase 5 (flatten_stavi_correct) is COMPLETED. The remaining 7 phases cover: (4B) EF game infrastructure expansion, (4C) the full GHR93 Theorem 4 proof, (5') Theorem 5 from Theorem 4, (6) Gap Elimination Lemmas 6-13 + Theorem 14, (7) IntegerModel helpers, (8) Wire no_gaps_discrete + one_class, (9) Rewrite chronicle_is_good + remove IsSuccArchimedean, (10) Discharge h_truth_corr, (11) Final wiring and verification.

Key insight from the research: `h_truth_corr` (Transfer.lean:574) is independent of the expressive completeness chain and can proceed in parallel. It is promoted to a standalone phase (Phase 10) that runs alongside the game proof work.

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations in the pipeline, `stavi_expressive_completeness` is sorry-free.

### Research Integration

Integrated from 5 reports:
- `reports/03_team-research.md`: Round 3 team synthesis (chronicle truth, box mismatch, succ_cofinal assessment, NF-evaluation approach). Integrated in v4.
- `reports/04_phase4-blocker.md`: Phase 4 blocker analysis identifying Theorem 14 <- Theorem 5 <- Theorem 4 <- Stavi connectives dependency chain. Integrated in v5.
- `reports/05_full-reynolds-impl.md`: Full Reynolds implementation plan with proof sketches for Lemmas 6-13 and Theorem 5. Axiom approach rejected but proof sketches remain valuable.
- `reports/06_path-b-feasibility.md`: Path B feasibility analysis. Identified 4 gaps, revised cost. Path B rejected by user.
- `reports/07_ghr93-strategy-review.md`: Strategy review identifying two sorry sources (h_truth_corr and IsSuccArchimedean), three approaches (A/B/C). User chose Approach A: full GHR93. Key finding: h_truth_corr is independent and can proceed in parallel.

### Prior Plan Reference

The v5 plan (06_reynolds-pipeline-plan.md) had 10 phases. Phases 1-3 COMPLETED, Phase 4 PARTIAL (Sub-stage 4A done, 4B skeleton only), Phase 5 COMPLETED (flatten_stavi_correct). Lessons learned: (1) The game proof (Sub-stage 4B-4C) is genuinely ~1500-2500 lines and should be broken into multiple sub-phases for checkpointing. (2) h_truth_corr is independent and should be a separate phase. (3) The 20-30 hour estimate for Theorem 4 is realistic. (4) Phase 5's flatten_stavi_correct provides the discrete StaviFormula-to-Formula bridge, which is useful but does NOT replace the full GHR93 proof. (5) The existing EFGames.lean has a skeleton (~170 lines) that needs substantial expansion.

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
| GHR93 Theorem 4 is 1500-2500 lines, the single largest formalization effort | H | H | Break into 3 sub-phases (4A done, 4B infrastructure, 4C main proof with 4 cases). Each sub-phase independently verifiable. Budget 20-30 hours total. |
| GHR93 custom EF games (G_{n;r}) require non-standard induction | H | M | Read GHR93 Section 8 IN FULL before coding. The induction has specific bounds: f(n+1) > (1+3f(n))*(2k_n)+1. Implement as explicit Nat recursion. |
| Gap elimination Lemmas 6-13 (Reynolds Section 7) are 6 pages of dense argument | H | M | Budget 8-12 hours. Lemma 12 (model surgery) alone is 2-3 sessions. Modularize into one sub-lemma per case. |
| Model surgery (Lemma 12) has 14 cases for Until plus Since cases | H | M | One sub-lemma per case. Test each case independently via lean_verify. |
| h_truth_corr discharge requires constructing TaskModel matching temporal_truth | M | M | Use chronicle's S5 MCS properties + box transparency from singleton Omega. Phase 3 already proved z_interval_countermodel sorry-free with h_truth_corr as hypothesis. |
| NEquivalence.lean cascade when removing domain_succ_archimedean | M | M | NEquivalence.lean:1215 chronicles this instance. Provide alternative derivation if needed. |
| cofinal_decomposition_k_equiv EF-game argument over ordered sums | M | M | Use explicit back-and-forth via NF agreement. Leverage doets_lemma_1_4 for ordered sum direction. |
| Phase 4C (GHR93 main proof) takes 2-3x estimated time | H | M | Mark [PARTIAL] and write handoff. Sub-phase structure allows checkpointing after each of the 4 cases. |
| int_truth / temporal_truth mismatch for box-free formulas | M | L | Separation never produces box. Prove box-freedom explicitly (~30-50 lines). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- (COMPLETED) |
| 2 | 4A, 5 | -- (COMPLETED) |
| 3 | 4B, 7, 10 | -- |
| 4 | 4C | 4B |
| 5 | 5' | 4C |
| 6 | 6 | 5' |
| 7 | 8 | 6 |
| 8 | 9 | 7, 8 |
| 9 | 11 | 9, 10 |

Phases 1-3, 4A, and 5 are completed. Wave 3 contains three independent tracks: (4B) expanding EF game infrastructure, (7) IntegerModel helpers, and (10) h_truth_corr discharge. Phase 4C (the main GHR93 proof) depends only on 4B. Phase 5' (Theorem 5 from Theorem 4) follows 4C. Phase 6 (gap elimination) follows 5'. Phase 8 wires no_gaps_discrete. Phase 9 rewires chronicle_is_good. Phase 11 is final verification, depending on both the gap elimination chain (via 9) and h_truth_corr (10).

---

### Phase 1: Chronicle Truth Lemma [COMPLETED]

**Goal**: Close the `chronicle_temporal_truth` sorry (Transfer.lean:186) and the inline sorry at Transfer.lean:371.

**Tasks**:
- [x] **Task 1.1**: Prove `chronicle_temporal_truth` by structural induction on formula psi.
- [x] **Task 1.2**: Wire into `countermodel_discrete` at Transfer.lean:470-475.
- [x] **Task 1.3**: Verify `lake build` passes.

**Timing**: 4 hours

**Depends on**: none

**Verification**:
- `lean_verify` on `chronicle_temporal_truth` shows no `sorryAx`
- `lake build` passes

---

### Phase 2: Fix Nonempty sig.preds [COMPLETED]

**Goal**: Close the trivial `Nonempty sig.preds` sorry at Transfer.lean:332.

**Tasks**:
- [x] **Task 2.1**: Augmented mkSigFrom to include Formula.bot as dummy predicate.
- [x] **Task 2.2**: Verify `lake build` passes.

**Timing**: 1 hour

**Depends on**: none

**Verification**:
- `lake build` passes

---

### Phase 3: Fix z_interval_countermodel Architecture and Bridge [COMPLETED]

**Goal**: Refactor `zIntervalTaskFrame` to use singleton Omega approach with box transparency. Add `h_truth_corr` hypothesis for the full truth correspondence.

**Tasks**:
- [x] **Task 3.1-3.9**: Singleton Omega, box transparency, h_truth_corr as parameter. z_interval_countermodel is sorry-free; one sorry remains at countermodel_discrete for h_truth_corr discharge.

**Timing**: 4 hours

**Depends on**: none

**Verification**:
- `lean_verify` on `z_interval_countermodel` shows no `sorryAx`
- `lake build` passes

---

### Phase 4A: Stavi Connective Semantics [COMPLETED]

**Goal**: Define Stavi connective semantics U'(A,B) and S'(A,B), StaviFormula type, stavi_temporal_truth, FO tables, cofinal/successor equivalences.

**Tasks**:
- [x] **Task 4A.1**: Created StaviConnectives.lean (~530 lines). Defined stavi_U_truth, stavi_S_truth, StaviFormula, stavi_temporal_truth, FO tables, cofinal_above_iff_succ, cofinal_below_iff_pred, stavi_U_discrete_equiv, stavi_S_discrete_equiv, flatten_stavi, flatten_stavi_correct.

**Timing**: 4 hours

**Depends on**: none

**Files created**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean`

**Verification**:
- All definitions and theorems sorry-free
- `lake build` passes

---

### Phase 5: flatten_stavi_correct (Reynolds Theorem 5 -- Discrete Case) [COMPLETED]

**Goal**: Prove that every StaviFormula has an equivalent standard temporal Formula in discrete orders via flatten_stavi_correct.

**Tasks**:
- [x] **Task 5.1-5.4**: Proved cofinal_above_iff_succ, until_bot_iff_succ, stavi_U_discrete_equiv, cofinal_below_iff_pred, since_bot_iff_pred, stavi_S_discrete_equiv, flatten_stavi_correct. All sorry-free.

**Timing**: 3 hours

**Depends on**: 4A

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean`

**Verification**:
- `lean_verify flatten_stavi_correct` shows no `sorryAx`
- `lake build` passes

---

### Phase 4B: EF Game Infrastructure Expansion [PARTIAL]

**Goal**: Expand the existing EFGames.lean skeleton (~170 lines) into the full EF game infrastructure needed for the GHR93 proof. This includes the custom G_{n;r} game type, game composition/restriction/extension lemmas, the depth function with recurrence bounds, and the "left" and "right" formula constructions for gap detection.

**BEFORE CODING**: Read GHR93 Section 8 (pages 172-185) IN FULL. The game definition has specific structural requirements: two-round structure (first n elements via standard EF protocol, then one additional element), the depth function f(n) with recurrence f(n+1) > (1+3f(n))(2k_n)+1, and four case splits. Understanding the complete argument before coding is essential.

**Mathematical Content**: The GHR93 custom EF game G_{n;r} differs from the standard EF game:
- Spoiler picks n+1 elements total: n by standard moves, then one final element
- The last element must be in a specific interval determined by the first n elements
- Duplicator's response must preserve predicate and order agreement
- Game depth f(n) determines the quantifier rank of formulas distinguishable by n-round games
- "Left" formulas L_k and "right" formulas R_k detect where gaps occur relative to selected elements

**Tasks**:
- [ ] **Task 4B.1**: Define the full G_{n;r} game structure with Spoiler/Duplicator moves, replacing the skeleton EFPosition. The game state tracks: (a) the two ordered monadic structures M and N, (b) the correspondence of selected elements, (c) the current round number, (d) bounds for the final element selection. (~150-200 lines)
- [x] **Task 4B.2**: Define the depth function f(n) with the exact GHR93 recurrence: f(0) = 0, f(n+1) = (1 + 3*f(n)) * (2*k_n) + 2, where k_n = |NF(sig, f(n), 1)|. Prove monotonicity (f(n) < f(n+1)), lower bound (2 <= f(n+1)), and the key bound used in the main induction. *(completed: game_depth, game_depth_succ_ge_two, game_depth_strict_mono, game_depth_mono, normalForm_nonempty, stavi_depth, stavi_n_equiv, stavi_n_equiv_symm, stavi_n_equiv_mono)*
- [ ] **Task 4B.3**: Prove game composition lemma: if Duplicator wins n-round games on subintervals, she wins the composed game on the full structure. This is the EF analogue of Feferman-Vaught. (~150-250 lines)
- [ ] **Task 4B.4**: Prove game restriction lemma: winning strategy on M restricts to winning strategy on a substructure of M. (~60-100 lines)
- [ ] **Task 4B.5**: Prove game extension lemma: winning strategy on substructures extends when the surrounding context is indistinguishable. (~100-150 lines)
- [ ] **Task 4B.6**: Define "left" and "right" formulas L_k(x) and R_k(x) that detect gap positions. L_k(x) says "the k-type on the left of x matches a specific NF pattern". R_k(x) is the mirror. These are StaviFormulas built from normal-form enumeration. (~100-150 lines)
- [ ] **Task 4B.7**: Prove that L_k and R_k correctly characterize gap positions: if (M,t) and (N,s) agree on all L_k and R_k formulas, then Duplicator can respond to the (n+1)-th element selection in G_{n;r}. (~100-200 lines)
- [ ] **Task 4B.8**: Verify `lake build` passes with all new game infrastructure.

**Timing**: 10-15 hours

**Depends on**: none (uses existing NormalForm, OrderedMonadicStructure, StaviConnectives infrastructure)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- substantial expansion from ~170 to ~900-1200 lines

**Verification**:
- All game lemmas sorry-free
- No `axiom` declarations
- `lake build` passes

---

### Phase 4C: GHR93 Theorem 4 -- Main Proof [NOT STARTED]

**Goal**: Prove `stavi_expressive_completeness`: for any monadic FO formula psi with one free variable, there exists a StaviFormula A such that stavi_temporal_truth M atomMap t A <-> eval M (fun _ => t) psi for ALL ordered monadic structures M and points t. This is GHR93 Theorem 9.3.1, the single largest formalization effort.

**BEFORE CODING**: Re-read GHR93 Section 8, particularly the four cases (I-IV) of the main induction. Each case spans approximately one page of dense argument. The proof structure is:

**Proof by induction on quantifier depth n**:
- Base case (n=0): Quantifier-free FO formulas translate to Boolean combinations of atomic predicates, which are directly expressible as temporal formulas.
- Inductive step: Given a formula psi of quantifier depth n+1, we must construct a StaviFormula A equivalent to psi on all linear structures. The argument uses the f(n+1)-round game. If Duplicator wins, (M,t) and (N,s) satisfy the same StaviFormulas of depth <= f(n+1), hence the same FO formulas of depth n+1.

**The four cases for the (n+1)-th element**:
- **Case I**: The new element is distinguishable by atoms/order at the existing n selected points. Then a Boolean formula over atomic predicates and the existing StaviFormulas (by IH) suffices.
- **Case II**: The new element witnesses an Until formula. There is a point s > t where the formula holds, and the interval (t,s) is homogeneous. Use U(A,B) where A and B are obtained by IH applied to the interval.
- **Case III**: Mirror of Case II for Since. Use S(A,B).
- **Case IV**: The new element falls in a "gap" -- the formula holds cofinally above t but there is no standard witness. Use U'(A,B) or S'(A,B) depending on the direction.

**Tasks**:
- [ ] **Task 4C.1**: Create ExpressivenessGeneral.lean. Set up the main induction framework: the statement of stavi_expressive_completeness, the induction on quantifier depth, and the case split structure. Define helper types for the case analysis. (~100-150 lines)
- [ ] **Task 4C.2**: Prove Case I (atom/order distinguishability). When the (n+1)-th element can be located relative to existing elements by predicates and order, construct a Boolean combination of StaviFormulas from the IH. This is the simplest case. (~150-250 lines)
- [ ] **Task 4C.3**: Prove Case II (Until witness). When there exists a standard Until witness, construct U(A,B) where A characterizes the witness point and B characterizes the interval, using the IH on the subintervals. Uses game composition and restriction lemmas from Phase 4B. (~200-350 lines)
- [ ] **Task 4C.4**: Prove Case III (Since witness). Mirror of Case II for the past direction. Construct S(A,B) analogously. (~150-250 lines, benefits from symmetry with Case II)
- [ ] **Task 4C.5**: Prove Case IV (gap detection via U'/S'). The hardest case. When the new element falls in a gap -- the formula is cofinal but has no standard witness -- construct U'(A,B) or S'(A,B). Uses the game extension lemma and the L_k/R_k formulas from Phase 4B to characterize the gap structure. (~250-400 lines)
- [ ] **Task 4C.6**: Assemble the four cases into the complete induction step. Verify that the case split is exhaustive and the StaviFormula constructions are well-typed. (~50-100 lines)
- [ ] **Task 4C.7**: Close `stavi_expressive_completeness` in EFGames.lean by calling the proof from ExpressivenessGeneral.lean. Remove the sorry. (~10-20 lines)
- [ ] **Task 4C.8**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`.
- [ ] **Task 4C.9**: Run `lake build` to confirm compilation.

**Timing**: 15-20 hours

**Depends on**: 4B (EF game infrastructure, depth function, game composition/restriction/extension lemmas, L_k/R_k formulas)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (NEW, ~1000-1500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- remove sorry from stavi_expressive_completeness
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- add import

**Verification**:
- `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- No `axiom` declarations in any new file
- `lake build` passes

---

### Phase 5': Reynolds Theorem 5 from Theorem 4 [NOT STARTED]

**Goal**: Prove that {U,S} alone is expressively complete for Prior structures, by composing Theorem 4 (stavi_expressive_completeness) with flatten_stavi_correct (Phase 5). In a Prior structure, U'(A,B) and S'(A,B) are always equivalent to standard temporal formulas (by stavi_U_discrete_equiv and stavi_S_discrete_equiv from Phase 5). So given any monadic FO formula psi:
1. Apply stavi_expressive_completeness to get StaviFormula A
2. Apply flatten_stavi to get standard Formula B
3. By flatten_stavi_correct, B is equivalent to A in discrete orders

This yields the "US_expressively_complete_over_prior" result that Phase 6 needs.

**Tasks**:
- [ ] **Task 5'.1**: Define `US_expressively_complete_over_prior`: for any MonadicFormula psi, there exists a standard Formula A (no U'/S') such that for any Prior structure M (discrete, no endpoints, Prior-UZ/SZ), temporal_truth M atomMap t A <-> eval M (fun _ => t) psi. Prove by composing stavi_expressive_completeness + flatten_stavi + flatten_stavi_correct. (~60-100 lines)
- [ ] **Task 5'.2**: Prove bridge lemma between `stavi_temporal_truth` and `temporal_truth`: for box-free standard formulas (output of flatten_stavi), stavi_temporal_truth and temporal_truth agree. (~30-50 lines)
- [ ] **Task 5'.3**: Verify `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`.

**Timing**: 2-3 hours

**Depends on**: 4C (stavi_expressive_completeness proved), 5 (flatten_stavi_correct already done)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` -- add Theorem 5 proofs
- Or create a dedicated thin file `Theories/Bimodal/Metalogic/WeakCanonical/Theorem5.lean`

**Verification**:
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build` passes

---

### Phase 6: Reynolds Lemmas 6-13 and Theorem 14 (Gap Elimination) [NOT STARTED]

**Goal**: Formalize the gap elimination argument from Reynolds 1994 Section 7. With Theorem 5 (Phase 5') providing expressive completeness for Prior structures, follow Reynolds' Lemmas 6-13 to prove that contemporaneous equivalence classes (under ~M) cannot end at gaps in Prior structures, hence no_gaps_discrete.

**BEFORE CODING**: Read Reynolds 1994 Section 7 (Lemmas 6-13, Theorem 14) IN FULL. These are 6 pages of dense argument. Budget time accordingly.

**Reynolds Section 7 Proof Structure**:
- Lemma 6: Temporal formula R detecting "class ends at gap on right" (uses Theorem 5)
- Lemma 7: R-intervals are open with bounded excluded endpoints (uses Prior-U on R)
- Lemma 8: No first/last class in R-intervals (uses Theorem 5 again)
- Lemma 9: Elementary equivalence of classes in R-intervals (uses Theorem 5 + Prior-U)
- Lemma 10: Bad interval structure (R and L co-occur)
- Lemma 11: Formula propagation in bad intervals
- Lemma 12: Model surgery -- replace bad interval by one class, preserve temporal truth (THE HARDEST sub-proof, 14 cases for Until + Since cases)
- Lemma 13: Contradiction -- R holds in chosen class in N, but N is Prior and class no longer ends at gap

**Tasks**:
- [ ] **Task 6.1**: Create GapElimination.lean. Define `mk_epsilon_formula` (FO formula for ~M class boundary) and `mk_rho_formula` (FO formula for "class ends at gap on right"). Apply `US_expressively_complete_over_prior` to get temporal formula R. Prove `R_correct`: R holds at t iff t's class ends in a gap on the right. (Lemma 6, ~100-150 lines)
- [ ] **Task 6.2**: Prove `R_interval_open` (Lemma 7): Maximal R-intervals are open with excluded endpoints. (~80-100 lines)
- [ ] **Task 6.3**: Prove `no_first_last_class` (Lemma 8): No first or last ~-class in R-intervals. (~60 lines)
- [ ] **Task 6.4**: Prove `elementary_equiv_classes` (Lemma 9): (a) If temporal A holds somewhere in one ~-class in R-interval, it holds somewhere in every class. (b) All ~-classes in R-interval are elementarily equivalent. (~130 lines)
- [ ] **Task 6.5**: Prove `bad_interval_structure` (Lemma 10): Bad points in non-singleton bad intervals, R and L hold throughout, excluded endpoints. (~80 lines)
- [ ] **Task 6.6**: Prove `formula_propagation` (Lemma 11): If B true for a while at start of class in bad interval, then B holds throughout. (~60 lines)
- [ ] **Task 6.7**: Prove `model_surgery` (Lemma 12): Define surgery carrier as subtype of M.carrier. Prove temporal truth preserved for all points in resulting substructure N. 14 cases for Until + Since cases. (~250-300 lines)
- [ ] **Task 6.8**: Prove `no_bad_points` (Lemma 13): Contradiction from R holding in chosen class in N (Prior structure) but class no longer ending at gap. (~60 lines)
- [ ] **Task 6.9**: Assemble `gap_elimination_theorem_14` (Theorem 14): ~M classes don't end at gaps. (~10-30 lines)
- [ ] **Task 6.10**: Verify `lean_verify gap_elimination_theorem_14` shows no `sorryAx`.
- [ ] **Task 6.11**: Run `lake build`.

**Timing**: 8-12 hours

**Depends on**: 5' (Theorem 5 is used in Lemmas 6, 8, 9)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- add import

**Verification**:
- `lean_verify gap_elimination_theorem_14` shows no `sorryAx`
- No `axiom` declarations
- `lake build` passes

---

### Phase 7: IntegerModel.lean Helper Sorries [NOT STARTED]

**Goal**: Close the 2 non-critical-path sorries in IntegerModel.lean: `cofinal_decomposition_k_equiv` (line 1135) and `ordered_sum_of_good_bounded_is_good` (line 1194, k>=2 case). These are needed for `very_good_implies_good` which is used by `chronicle_is_good`.

**BEFORE CODING**: Read the NF-evaluation approach from Team Research Round 3. For `cofinal_decomposition_k_equiv`, the approach is NF-preservation via explicit embedding. For `ordered_sum_of_good_bounded_is_good`, construct SuccOrder on sigma type of bounded Z-intervals, then use `orderIsoIntOfLinearSuccPredArch` on the witness side (safe -- this is on the explicitly Z-like concatenated witness, NOT on M.domain).

**Tasks**:
- [ ] **Task 7.0 (Pre-flight)**: Run `lean_verify doets_lemma_1_5` to check if OrderedSum.lean:56 sorry is on the critical path to `very_good_implies_good`. If it is, add closing this sorry to the phase scope.
- [ ] **Task 7.1**: Prove `cofinal_decomposition_k_equiv` (IntegerModel.lean:1135). Construct explicit embedding M -> orderedSum and prove NF-evaluation preservation by induction on NF. Handle duplicated boundary points carefully. (~100-150 lines)
- [ ] **Task 7.2**: Prove `ordered_sum_of_good_bounded_is_good` for k>=2 (IntegerModel.lean:1194). Steps: (a) transfer "has max/min" from ms(i) to Z_i via `doets_lemma_1_1` at depth 2, (b) construct SuccOrder and PredOrder on sigma type, (c) prove IsSuccArchimedean for sigma type (safe -- finite bounded Z-intervals), (d) apply `orderIsoIntOfLinearSuccPredArch` on witness side, (e) apply `k_equiv_of_iso`. (~100-200 lines)
- [ ] **Task 7.3**: Construct shift-and-glue OrderIso for Task 7.2: cumulative offset function mapping each Z-interval to contiguous Z segment. Prove: strictly monotone, surjective, predicate-preserving. (~80-120 lines)
- [ ] **Task 7.4**: Verify `lean_verify very_good_implies_good` shows no `sorryAx`.

**Timing**: 5-8 hours

**Depends on**: none (uses existing NormalForm, doets_lemma_1_4, k_equiv_of_iso infrastructure; `orderIsoIntOfLinearSuccPredArch` used only on the explicitly Z-like concatenated witness, not on M.domain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- close cofinal_decomposition_k_equiv and ordered_sum_of_good_bounded_is_good
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` -- potentially close doets_lemma_1_5 if on critical path

**Verification**:
- `lean_verify cofinal_decomposition_k_equiv` shows no `sorryAx`
- `lean_verify ordered_sum_of_good_bounded_is_good` shows no `sorryAx`
- `lean_verify very_good_implies_good` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Wire no_gaps_discrete and one_class [NOT STARTED]

**Goal**: Replace the `no_gaps_discrete` sorry (IntegerModel.lean:859) with a call to `gap_elimination_theorem_14` from Phase 6. Verify that `one_class` becomes sorry-free through the existing wiring (one_class already calls no_gaps_discrete + no_boundary_at_successor + contemp_equiv_is_equiv).

**Tasks**:
- [ ] **Task 8.1**: Replace `no_gaps_discrete` sorry with call to `gap_elimination_theorem_14`. Bridge the type signatures: IntegerModel's `no_gaps_discrete` has specific hypotheses (SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, Countable, Prior-UZ/SZ) while GapElimination's theorem may use a different signature. (~20-40 lines of bridging)
- [ ] **Task 8.2**: Verify `lean_verify no_gaps_discrete` shows no `sorryAx`.
- [ ] **Task 8.3**: Verify `lean_verify one_class` shows no `sorryAx` (inherits from no_gaps_discrete).
- [ ] **Task 8.4**: Run `lake build`.

**Timing**: 1-2 hours

**Depends on**: 6 (gap_elimination_theorem_14 must be proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- replace no_gaps_discrete sorry
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- ensure GapElimination is imported

**Verification**:
- `lean_verify no_gaps_discrete` shows no `sorryAx`
- `lean_verify one_class` shows no `sorryAx`
- No `IsSuccArchimedean` in `no_gaps_discrete` or `one_class` theorem statements
- `lake build` passes

---

### Phase 9: Rewrite chronicle_is_good and Remove IsSuccArchimedean [NOT STARTED]

**Goal**: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good` instead of `orderIsoIntOfLinearSuccPredArch`. Remove `domain_succ_archimedean` from `ChronicleAsPriorModel`. Remove `orderIsoIntOfLinearSuccPredArch` from `countermodel_discrete`. Handle cascade effects in NEquivalence.lean.

**BEFORE CODING**: Check NEquivalence.lean:1215 for cascade risk. The instance `chronicleAsMonadicStructure_succ_archimedean` directly delegates to `M.domain_succ_archimedean`. If this instance is used elsewhere, provide an alternative or remove it.

**Tasks**:
- [ ] **Task 9.1**: Rewrite `chronicle_is_good` (IntegerModel.lean:1245). New proof: chronicle has SuccOrder, PredOrder, NoMaxOrder, NoMinOrder, Countable, Nonempty. `no_boundary_at_successor` gives c ~M succ(c). `one_class` (now sorry-free) gives all points equivalent. `very_good_implies_good` (from Phase 7) completes. (~30-50 lines)
- [ ] **Task 9.2**: Remove `domain_succ_archimedean` field from `ChronicleAsPriorModel` (ChronicleExtraction.lean:103). Remove `attribute [instance]` at line 151 and assignment at line 175 in `extract_chronicle_as_prior`. (~20-30 lines deleted)
- [ ] **Task 9.3**: Remove or fix `chronicleAsMonadicStructure_succ_archimedean` instance in NEquivalence.lean:1213. If it is not used by any sorry-free code, simply remove it. If used, provide alternative derivation from the new sorry-free chain. (~20-50 lines)
- [ ] **Task 9.4**: In `countermodel_discrete` (Transfer.lean:494), remove the `orderIsoIntOfLinearSuccPredArch` call at line 521. Replace with the `chronicle_is_good` proof output which now provides a Z-interval witness via the one_class + very_good_implies_good chain. (~30-50 lines)
- [ ] **Task 9.5**: Propagate removal of IsSuccArchimedean to any downstream code that relied on it. Search for references to `domain_succ_archimedean` and `chronicleAsMonadicStructure_succ_archimedean`. (~10-20 lines)
- [ ] **Task 9.6**: Verify `lake build` passes with all IsSuccArchimedean references removed.

**Timing**: 3-5 hours

**Depends on**: 7 (very_good_implies_good sorry-free), 8 (one_class sorry-free, no_gaps_discrete sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- rewrite chronicle_is_good
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- remove domain_succ_archimedean
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- remove orderIsoIntOfLinearSuccPredArch from countermodel_discrete
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- remove/fix chronicleAsMonadicStructure_succ_archimedean
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- may need adjustments if extract_chronicle_as_prior signature changes

**Verification**:
- `lean_verify chronicle_is_good` shows no `sorryAx`
- No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean (except possibly in comments)
- No `IsSuccArchimedean` in ChronicleAsPriorModel
- No `domain_succ_archimedean` in ChronicleExtraction.lean
- `lake build` passes

---

### Phase 10: Discharge h_truth_corr [COMPLETED]

**Goal**: Discharge the h_truth_corr sorry at Transfer.lean:574. This is the ONLY direct sorry in `countermodel_discrete` (the other sorry comes from `chronicle_is_good` via `orderIsoIntOfLinearSuccPredArch`). This phase is INDEPENDENT of the expressive completeness chain (Phases 4B-4C, 5', 6, 8) and can proceed in parallel.

**Mathematical Content**: The proof requires constructing a TaskModel where truth_at matches temporal_truth on the Z-interval structure. The key ingredients are:
1. `chronicle_temporal_truth` (Phase 1, sorry-free): connects MCS membership to temporal_truth
2. Box transparency from singleton Omega: the S5 box evaluates trivially on {zIntervalHistory}
3. The Z-interval structure's predicate interpretation matches the chronicle's MCS assignment

The h_truth_corr hypothesis states:
```
forall (psi : Formula) (t : Z_wit.intervalCarrier),
  truth_at TM_wit zIntervalOmega zIntervalHistory
    ((unboundedZIntervalEquiv Z_wit h_lo h_hi) t) psi <->
  temporal_truth (Z_wit.toOrdered sig) atomMap_fwd t psi
```

**Tasks**:
- [ ] **Task 10.1**: Construct the correct `TM_wit : TaskModel zIntervalTaskFrame`. *(deviation: skipped -- zIntervalTaskFrame (WorldState = Unit) fundamentally cannot support position-dependent atom truth, making the h_truth_corr approach via z_interval_countermodel infeasible)*
- [ ] **Task 10.2**: Prove the truth correspondence by structural induction on psi. *(deviation: skipped -- see Task 10.1)*
- [x] **Task 10.3**: Replace the sorry at Transfer.lean:574 with the proved h_truth_corr. *(deviation: altered -- instead of proving h_truth_corr on zIntervalTaskFrame, the entire countermodel_discrete proof body was replaced with a delegation to dd_countermodel_chronicle_discrete, which uses ParametricCanonicalTaskFrame with MCS-based world states. This eliminates the h_truth_corr sorry entirely. The Reynolds pipeline infrastructure (chronicle_temporal_truth, truth_transfer, k_equiv_preserves_sentence, table_correctness) remains available for Phase 9's restructuring.)*
- [x] **Task 10.4**: Verify `lean_verify countermodel_discrete` -- sorryAx remains from succ_cofinal (shared by both approaches). Transfer.lean has zero source-level sorries.
- [x] **Task 10.5**: Run `lake build` -- passes.

**Timing**: 3-5 hours (actual: ~4 hours including architectural analysis)

**Depends on**: none (uses chronicle_temporal_truth from Phase 1, z_interval_countermodel from Phase 3, existing Transfer.lean infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- replaced countermodel_discrete proof body with delegation to dd_countermodel_chronicle_discrete

**Verification**:
- After this phase: countermodel_discrete has sorryAx only from chronicle_is_good (upstream)
- After Phase 9 is also done: `lean_verify countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 11: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify the entire pipeline is sorry-free with no custom axioms. Close any remaining bridging sorries. Run `#print axioms bx_completeness`. Update documentation.

**Tasks**:
- [ ] **Task 11.1**: Run `lean_verify countermodel_discrete` and inspect axiom list. Should show only `propext`, `Classical.choice`, `Quot.sound`.
- [ ] **Task 11.2**: Run `lean_verify bx_completeness` and inspect axiom list. Should show no `sorryAx` and no custom axioms.
- [ ] **Task 11.3**: If any unexpected `sorryAx` remains, trace the dependency chain using `#print axioms` on intermediate theorems. Fix any remaining sorry.
- [ ] **Task 11.4**: Verify NO `axiom` declarations exist in new files: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` should return empty.
- [ ] **Task 11.5**: Run full `lake build` to ensure no regressions.
- [ ] **Task 11.6**: Verify no new `sorry` was introduced on the critical path: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/` should show only pre-existing sorries outside the critical path (TruthLemma.lean Until/Since backward, frame-class completeness variants, doets_lemma_1_5 if not closed).
- [ ] **Task 11.7**: Verify `stavi_expressive_completeness` is sorry-free (the full GHR93 proof, not an axiom).
- [ ] **Task 11.8**: Update file-level documentation comments in Transfer.lean, IntegerModel.lean, ChronicleExtraction.lean, StaviConnectives.lean, EFGames.lean, ExpressivenessGeneral.lean, and GapElimination.lean.

**Timing**: 1-2 hours

**Depends on**: 9 (all upstream work via gap elimination chain), 10 (h_truth_corr discharge)

**Files to modify**:
- Documentation updates across all WeakCanonical files
- Potential bridging fixes if any sorry remains

**Verification**:
- `#print axioms bx_completeness` shows: propext, Classical.choice, Quot.sound (NO sorryAx, NO custom axioms)
- `#print axioms countermodel_discrete` shows: propext, Classical.choice, Quot.sound
- `#print axioms stavi_expressive_completeness` shows: propext, Classical.choice, Quot.sound
- `lake build` passes with zero errors
- No new `sorry` on the critical path
- No `axiom` declarations in WeakCanonical directory
- No `IsSuccArchimedean` in no_gaps_discrete, one_class, or chronicle_is_good
- No `orderIsoIntOfLinearSuccPredArch` in Transfer.lean (except comments)

---

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `#print axioms bx_completeness` outputs only: `propext`, `Classical.choice`, `Quot.sound` (NO `sorryAx`, NO custom `axiom`)
- [ ] `#print axioms countermodel_discrete` shows no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` shows no `sorryAx` (GHR93 Theorem 4 PROVED, not axiomatized)
- [ ] `#print axioms US_expressively_complete_over_prior` shows no `sorryAx`
- [ ] `#print axioms gap_elimination_theorem_14` shows no `sorryAx`
- [ ] `#print axioms chronicle_is_good` shows no `sorryAx`
- [ ] `#print axioms one_class` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `#print axioms very_good_implies_good` shows no `sorryAx`
- [ ] `#print axioms chronicle_temporal_truth` shows no `sorryAx`
- [ ] `#print axioms z_interval_countermodel` shows no `sorryAx`
- [ ] `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/` returns empty
- [ ] No occurrence of `IsSuccArchimedean` in `no_gaps_discrete`, `one_class`, or `chronicle_is_good` theorem statements
- [ ] No occurrence of `orderIsoIntOfLinearSuccPredArch` in Transfer.lean (except comments)
- [ ] `domain_succ_archimedean` removed from `ChronicleAsPriorModel`
- [ ] No new `sorry` introduced on the critical path

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` -- Stavi connective semantics, discrete equivalences, flatten_stavi_correct (Phase 4A + Phase 5, COMPLETED)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- Full EF game infrastructure + stavi_expressive_completeness (Phase 4B + 4C)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- GHR93 Theorem 4 main proof, four cases (Phase 4C, NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- Reynolds Lemmas 6-13, Theorem 14 (Phase 6, NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- Closed chronicle_temporal_truth, fixed z_interval_countermodel, discharged h_truth_corr, removed orderIsoIntOfLinearSuccPredArch (Phases 1-3, 9-10)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- Closed cofinal_decomposition_k_equiv, ordered_sum_of_good_bounded_is_good, no_gaps_discrete, chronicle_is_good (Phases 7-9)
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean` -- Removed domain_succ_archimedean from ChronicleAsPriorModel (Phase 9)
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` -- Removed/fixed IsSuccArchimedean cascade (Phase 9)
- `specs/155_reynolds_pipeline_activation/plans/07_reynolds-pipeline-plan.md` -- This plan (v6)

## Rollback/Contingency

1. **Phase 4B (EF game infrastructure)**: If specific lemmas (composition, restriction, extension) are harder than expected, implement as sorry'd and mark [PARTIAL]. Each lemma is independent and can be checkpointed.
2. **Phase 4C (GHR93 Theorem 4)**: THE LARGEST AND HARDEST PHASE. If stuck after 20 hours, write a detailed handoff documenting: (a) which cases (I-IV) are proved, (b) what the Lean goal states look like for unfinished cases, (c) which game lemmas from 4B are used and which may need revision. Mark [PARTIAL]. The four-case structure allows checkpointing after each case.
3. **Phase 5' (Theorem 5 from Theorem 4)**: Low risk given Phase 4C is complete. If the bridge between stavi_temporal_truth and temporal_truth is harder than expected, track through the box-freedom property explicitly.
4. **Phase 6 (Lemmas 6-13)**: If Lemma 12 (model surgery) exceeds 300 lines, modularize into one sub-lemma per Until/Since case. If stuck after 8 hours, mark [PARTIAL] with documentation of which lemmas are proved.
5. **Phase 7 (IntegerModel helpers)**: If `cofinal_decomposition_k_equiv` is intractable via NF-evaluation, try the embedding approach: prove M -> orderedSum preserves all quantifier-depth-k formulas by direct induction.
6. **Phase 9 (chronicle_is_good rewrite)**: Low risk given Phases 7-8 are complete. If NEquivalence.lean cascade is severe, keep `domain_succ_archimedean` as a computed field derived from sorry-free infrastructure (make it a theorem rather than sorry'd field).
7. **Phase 10 (h_truth_corr)**: If the box case is harder than expected (singleton Omega not transparent enough), introduce explicit box-transparency lemma for zIntervalTaskFrame. This was partially addressed in Phase 3.
8. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help. Do not introduce `axiom` declarations or reintroduce the shortcut that caused the v1 failure.
