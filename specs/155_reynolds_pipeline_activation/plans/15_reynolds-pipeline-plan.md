# Implementation Plan: Reynolds Pipeline Activation (v10 -- muSig Blocker Resolution)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 55-80 hours (remaining: ~35-55 hours)
- **Dependencies**: Task 154 (sum_preservation/doets_lemma_1_4, COMPLETED), Tasks 147-148 (table_correctness, COMPLETED), Task 157 (separation/expressive completeness, COMPLETED)
- **Research Inputs**:
  - specs/155_reynolds_pipeline_activation/reports/03_team-research.md
  - specs/155_reynolds_pipeline_activation/reports/04_phase4-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/05_full-reynolds-impl.md
  - specs/155_reynolds_pipeline_activation/reports/06_path-b-feasibility.md
  - specs/155_reynolds_pipeline_activation/reports/07_ghr93-strategy-review.md
  - specs/155_reynolds_pipeline_activation/reports/10_team-research.md (Round 4)
  - specs/155_reynolds_pipeline_activation/reports/12_degenerate-interval-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/15_d-consistency-blocker.md
  - specs/155_reynolds_pipeline_activation/reports/16_ghr93-lemma9-deep-read.md
  - specs/155_reynolds_pipeline_activation/reports/17_stavi-semantics-impact.md
  - specs/155_reynolds_pipeline_activation/reports/17_discrete-equivalence-check.md
  - specs/155_reynolds_pipeline_activation/reports/18_claim1-literature.md
  - specs/155_reynolds_pipeline_activation/reports/18_lean-infra-audit.md
  - specs/155_reynolds_pipeline_activation/reports/18_alternative-strategies.md
  - specs/155_reynolds_pipeline_activation/reports/19_gap-definability-construction.md
  - specs/155_reynolds_pipeline_activation/reports/20_nf-bridge-research.md
  - specs/155_reynolds_pipeline_activation/reports/20_lean-pigeonhole-patterns.md
  - specs/155_reynolds_pipeline_activation/reports/21_muSig-blocker-resolution.md (NEW in v10)
- **Artifacts**: plans/15_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: FULL GHR93, NO SHORTCUTS

**The user explicitly requires the FULL game-theoretic proof of GHR93 Theorem 9.3.1.** No discrete-only transfer, no bypass via succ_cofinal, no axiom declarations. The plan formalizes the complete EF game argument proving {U,S,U',S'} is expressively complete over ALL linear temporal structures.

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

This plan (v10) integrates the muSig blocker resolution from report 21 and updates the sorry inventory to reflect current codebase state. The key new finding is a `not_not_and_not` helper lemma that bridges the FO encoding's `not (not A and not B)` disjunction representation to Lean's native `Or` type, unblocking the `stavi_table_mu_correct` stavi_untl/snce cases.

Phases 1-5, 4A, 4B, and 0 are COMPLETED. Phase 4C-W1 is PARTIAL with sub-phases W1.1, W1.2a-c, W1.3, W1.2d (both first conjunct and pigeonhole), and W1.muSig all completed. The muSig infrastructure is fully sorry-free (9/9 closed) and `pigeonhole_definable_formula` is closed (required new `stavi_fo_depth_le_twice_depth` bridge lemma + NF at depth `2*r`). Remaining W1 sub-phases: d-consistency (W1.2e, 2 sorries), M-side degenerate (W1.4, 2 sorries). The plan maintains the same dependency chain as v9.

Definition of done: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations in the pipeline, `stavi_expressive_completeness` is sorry-free.

### Research Integration

Report 21 (muSig blocker resolution) provides the critical insight:
- The FO encoding uses `not (not disj1 and not disj2)` for disjunction, but after `simp only [not_and, Classical.not_not]` this becomes an implication (`not disj1 -> disj2`), not an `Or`
- A local `not_not_and_not` helper converts `not (not P and not Q)` to `P or Q`, bridging FO encoding to semantic `Or`
- Two-level conversion strategy: outer level uses `not_and` for implication, inner disjunction level uses `not_not_and_not` for `Or`
- Estimated ~130 lines per case (stavi_untl + stavi_snce = ~260 total)

### Prior Plan Reference

The v9 plan had 12 phases. Phases 1-5, 4A, 4B, 0: COMPLETED. Phase 4C-W1: PARTIAL. Lessons learned:
1. The U' semantics fix (Phase 0) was the critical breakthrough -- all 12 tasks completed sorry-free
2. The muSig infrastructure was mostly tractable (7/9 closed in one session) but the stavi_untl/snce cases required a specific propositional bridging strategy
3. D-consistency (Claim 1) continues to be the architecturally hardest piece -- infimum-based approach validated but full proof still pending
4. Effort calibration: each wave takes 4-8 hours per session

### Roadmap Alignment

- Advances "sorry-free `bx_completeness`" (primary critical path item)
- Eliminates circular dependency through `succ_cofinal` (task 129)
- Formalizes the complete GHR93 expressive completeness theorem (Theorem 9.3.1)

## Goals & Non-Goals

**Goals**:
- ~~Close the 2 remaining muSig sorries (`stavi_table_mu_correct` stavi_untl/snce)~~ **DONE** (FO encoding bug fix)
- ~~Close the pigeonhole_definable_formula sorry~~ **DONE** (recursive chain + Fintype pigeonhole at depth 2*r)
- Complete d-consistency (GHR93 Claim 1) via infimum argument
- Close M-side degenerate interval sorries (lines 1304, 1321)
- Prove GHR93 Lemma 9 (gap detection correctness)
- Prove Cases III/IV of GHR93 Theorem 6
- Complete the assembly chain: rank-varying Thm 6, Props 6-7, Corollary 5
- Prove Reynolds Theorem 5, Lemmas 6-13, Theorem 14 (gap elimination)
- Wire into Transfer.lean for sorry-free `bx_completeness`

**Non-Goals**:
- Dense completeness (separate path, unaffected)
- Closing `succ_cofinal` (task 129) -- we bypass it via gap elimination
- Frame-class completeness variants (Completeness.lean:254,279,288)
- Optimizing existing sorry-free infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `not_not_and_not` helper does not fully resolve Fin.cons reduction at depth 3+ | M | L | Report 21 confirms Fin.cons reduces definitionally at Fin.mk indices (verified by rfl tests). The helper only addresses the Or-vs-implication mismatch, which is the actual blocker. If Fin.cons terms persist, use `conv` with `erw` to rewrite individually. |
| D-consistency (Claim 1) infimum argument exceeds estimate | H | M | The gap construction sub-phases (W1.2a-c) are complete and sorry-free. The remaining work is the formula transfer (Step 2) and uniqueness argument (Steps 3-5). If stuck, fall back to Option C (Classical.choice canonical strategy). |
| Lemma 9 gap detection proof more complex than "Clear" | M | L | With correct U' semantics (Phase 0 done), the theorem statement is mathematically correct. The neg case is the hard one -- requires gap uniqueness from D-definability. Budget 150 lines per case. |
| Props 6-7 require unforeseen infrastructure | M | M | Follow GHR93 step-by-step. If Prop 7 composition too complex, try direct Corollary 5 route. |
| Phase 10 (h_truth_corr delegation) type mismatch | L | L | Independent phase. If types don't match, mark [BLOCKED] and proceed. |

## Full Sorry Inventory (Current State)

### EFGames.lean (4 sorries, down from 6)
| Line | Identifier | Phase | Status |
|------|-----------|-------|--------|
| 2432 | `left_formula_gap_detection` | 4C-W2 | open |
| 2451 | `right_formula_gap_detection` | 4C-W2 | open |
| 3521 | `ghr93_decomposition_implies_game` | 4C-W4 | open |
| ~~4188~~ | ~~`stavi_table_mu_correct` stavi_untl case~~ | ~~4C-W1 (muSig)~~ | **CLOSED** (FO encoding bug fix) |
| ~~4191~~ | ~~`stavi_table_mu_correct` stavi_snce case~~ | ~~4C-W1 (muSig)~~ | **CLOSED** (FO encoding bug fix) |
| 4823 | `stavi_expressive_completeness` | 4C-W4 | open (line shifted from 4529→4809→4823) |

### ExpressivenessGeneral.lean (7 sorries, down from 8)
| Line | Identifier | Phase | Status |
|------|-----------|-------|--------|
| ~~639~~ | ~~`pigeonhole_definable_formula` chain body~~ | ~~4C-W1 (depends on muSig)~~ | **CLOSED** (pigeonhole proof via recursive chain + Fintype contradiction) |
| 1103 | `d_consistency_left` | 4C-W1 (Claim 1) | **BLOCKED** (needs claim1_d_consistency infra) |
| 1136 | `d_consistency_right` | 4C-W1 (Claim 1) | **BLOCKED** (needs claim1_d_consistency infra) |
| 1466 | M-side degenerate `h_pt_xc` | 4C-W1 | LATENT (unreachable until W3 gap case) |
| 1483 | M-side degenerate `h_pt_cy` | 4C-W1 | LATENT (unreachable until W3 gap case) |
| 1587 | c construction gap case | 4C-W3 | open |
| 3491 | `ghr93_cases_III_IV` | 4C-W3 | open |
| 3712 | `ghr93_forward_to_backward_rank_varying` | 4C-W4 | open |

### IntegerModel.lean (3 sorries)
| Line | Identifier | Phase |
|------|-----------|-------|
| 859 | `no_gaps_discrete` | 8 |
| 1135 | `cofinal_decomposition_k_equiv` | 7 |
| 1194 | `ordered_sum_of_good_bounded_is_good` | 7 |

### Transfer.lean (1 sorry)
| Line | Identifier | Phase |
|------|-----------|-------|
| 574 | `h_truth_corr` | 10 |

**Total critical-path sorries**: 15 (down from 18; 3 closed: 2 muSig + 1 pigeonhole)

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Status |
|------|--------|------------|--------|
| -- | 1, 2, 3, 4A, 5, 4B, 0 | -- | COMPLETED |
| 1 | 4C-W1 | 0 | PARTIAL |
| 2 | 4C-W2 | 0 | NOT STARTED |
| 3 | 4C-W3 | 4C-W1, 4C-W2 | NOT STARTED |
| 4 | 4C-W4 | 4C-W3 | NOT STARTED |
| 5 | 5' | 4C-W4 | NOT STARTED |
| 6 | 6 | 5' | NOT STARTED |
| 7 | 7, 8 | 6 (for 8), none (for 7) | NOT STARTED |
| 8 | 9 | 7, 8 | NOT STARTED |
| 9 | 10 | -- | NOT STARTED (independent) |
| 10 | 11 | 9, 10 | NOT STARTED |

Phases within the same wave can execute in parallel.

**Execution order** (STRICT SEQUENTIAL within main chain):
4C-W1 -> 4C-W2 -> 4C-W3 -> 4C-W4 -> 5' -> 6 -> 8 -> 9 -> 11.
Phase 7 (IntegerModel helpers) can proceed in parallel with the 4C chain.
Phase 10 (h_truth_corr delegation) can proceed in parallel.

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

### Phase 3: Fix z_interval_countermodel Architecture [COMPLETED]

**Goal**: Refactor `zIntervalTaskFrame` to use singleton Omega approach with box transparency.

**Tasks**:
- [x] Singleton Omega, box transparency, h_truth_corr as parameter

**Timing**: 4 hours

**Depends on**: none

---

### Phase 4A: Stavi Connective Semantics [COMPLETED]

**Goal**: Define Stavi connective semantics, StaviFormula type, stavi_temporal_truth, FO tables.

**Tasks**:
- [x] Created StaviConnectives.lean (~530 lines). All sorry-free.

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

### Phase 4B: GHR93 Infrastructure [COMPLETED]

**Goal**: Build the complete GHR93 Section 8 infrastructure (7 tasks).

**Tasks**:
- [x] All 7 tasks completed. Gap/M_r/ExtendedCarrier, mu/A^mu, left/right_formula, G_{n;r}, decomposition agreement, Lemma 10, Lemma 11 forward.

**Timing**: 12-18 hours

**Depends on**: none

---

### Phase 0: U'/S' Semantics Fix [COMPLETED]

**Goal**: Replace incorrect "cofinal AND NOT U/S" definitions with correct GHR93 FO-table-based definitions. Reprove all broken theorems.

**Tasks**:
- [x] Tasks 0.1-0.12 all completed. 6 sorries eliminated. StaviFormula extended with std_untl/std_snce. Build passes.

**Timing**: 8-14 hours

**Depends on**: none

---

### Phase 4C-W1: muSig + D-Consistency + Degenerate Intervals [PARTIAL]

**Goal**: Close the muSig infrastructure sorries, complete the pigeonhole argument, restructure `obtain_split_point_props` with infimum-based d, handle degenerate intervals via vacuous game lemma, close M-side degenerate sorries.

**Status**: PARTIAL. Completed: Task W1.1 (degenerate gap lemma), W1.2a-c (definitions, S_C properties, gap construction -- all sorry-free), W1.2d (both `cont_holds_above_gap` and `pigeonhole_definable_formula` sorry-free), W1.3 (N-side degenerate sorries), W1.muSig (9/9 sorries closed via FO encoding bug fix), `nf_determines_stavi_truth` and `nf_determines_stavi_truth_depth` sorry-free.

**Remaining work** (4 sorries in this phase; muSig + pigeonhole now closed):

**Sub-phase W1.muSig: Close stavi_table_mu_correct stavi_untl/snce [COMPLETED]**

The 2 muSig sorries were closed. The root cause was a sign error in the FO encoding (`stavi_untl_fo` and `stavi_snce_fo`): an extra `MonadicFormula.not` wrapper around the disjunction conjunction `(¬D1 ∧ ¬D2)` caused the FO body to encode `guard → ¬(D1 ∨ D2)` instead of `guard → D1 ∨ D2`. After fixing the FO encoding (removing the spurious `not`), the proof strategy uses:

- `not_and_or.mp` + `Classical.not_not.mp` to convert `¬(¬D1_fo ∧ ¬D2_fo)` to `D1_fo ∨ D2_fo` (forward)
- Direct contradiction via `fun ⟨hnd1, hnd2⟩ => hbody u ⟨guard, hnd1, hnd2⟩` (backward)
- Lift lemmas (1-4) bridge eval terms to semantic equivalents at each quantifier depth
- All Fin.cons terms handled via definitional equality (no simp [Fin.cons, Fin.cases] needed)

**Tasks**:

- [x] **Task W1.muSig.1**: Define `not_not_and_not` helper lemma in EFGames.lean (3 lines) *(deviation: skipped -- not needed; the fix was a sign error in stavi_untl_fo/stavi_snce_fo, not a propositional bridging issue)*
- [x] **Task W1.muSig.2**: Close `stavi_table_mu_correct` stavi_untl case *(deviation: altered -- fixed FO encoding bug in stavi_untl_fo, then proved via not_and_or + Classical.not_not + lift lemmas)*
- [x] **Task W1.muSig.3**: Close `stavi_table_mu_correct` stavi_snce case *(deviation: altered -- same FO encoding fix in stavi_snce_fo, dual proof)*
- [x] **Task W1.muSig.4**: Verify `lean_verify stavi_table_mu_correct` shows no `sorryAx`. Confirmed: axioms = [propext, Classical.choice, Quot.sound].

**Sub-phase W1.2d-remainder: Pigeonhole [COMPLETED]**

Closed `pigeonhole_definable_formula` sorry. Key insight: `stavi_fo_depth` can exceed `stavi_depth` by up to a factor of 2 (stavi operators add +4 fo depth vs +2 depth), so the NF bridge requires depth `2*r` instead of `r`. Proved `stavi_fo_depth_le_twice_depth` in EFGames.lean, created `nf_determines_stavi_truth_depth` variant using NF at depth `2*r`, then built a monotone chain of failure points via `Classical.indefiniteDescription` with `Nat.rec` and applied `Fintype.exists_ne_map_eq_of_card_lt` for the pigeonhole contradiction.

- [x] **Task W1.2d.1**: Close `pigeonhole_definable_formula` (line ~681) *(deviation: altered -- used NormalForm at depth 2*r instead of r, added stavi_fo_depth_le_twice_depth helper lemma and nf_determines_stavi_truth_depth bridge variant)*

**Sub-phase W1.2e-remainder: D-Consistency Claim 1 [BLOCKED]**

**BLOCKER** (Sub-phase W1.2e):
- **What failed**: `d_consistency_left` (line 1103) and `d_consistency_right` (line 1136) cannot be proved from their current hypotheses.
- **What was tried**: (1) Direct proof from formula_agreement + same_order_type in winning condition; (2) Round 2 challenge-based contradiction; (3) Boundary correspondence argument.
- **Why it's stuck**: The theorem asks: for ALL winning plays with c at position n, the N-side response at position n equals d. But `ghr93_duplicator_wins` is existential (non-deterministic) -- different invocations can choose different responses. The GHR93 Claim 1 argument uses a rank-(r+1) formula C' to force uniqueness, but the winning condition only provides rank-r formula agreement. Without the infimum characterization of d, uniqueness is unprovable.
- **What is needed**: Implement `claim1_d_consistency` per report 18 (alternative-strategies.md), Option I. This requires: (a) defining the "achievable responses" set; (b) proving all achievable responses have the same rank-r type; (c) proving all achievable responses are equal (the hard step -- requires gap/infimum structure argument, ~50-100 lines); (d) proving d is achievable (from the existing construction where d = a_bwd(n)). Total ~130-170 lines in EFGames.lean. Key open question: whether the "Phase C uniqueness for points" argument works without a strict infimum. See report 18, Section 3, Phase C for details.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

- [ ] **Task W1.2e.1**: Prove `d_consistency_left` (line 1103) via GHR93 Claim 1 infimum argument *(deviation: blocked -- d-consistency unprovable from current hypotheses without claim1_d_consistency infrastructure)*
- [ ] **Task W1.2e.2**: Prove `d_consistency_right` (line 1136) -- dual *(deviation: blocked -- same as W1.2e.1)*

**Sub-phase W1.4: M-side Degenerate Sorries [BLOCKED]**

**BLOCKER** (Sub-phase W1.4):
- **What failed**: Lines 1466 and 1483 ask for `∃ p, inClosedInterval x c (extendPoint p)` when x = c and c is a gap. No such point exists.
- **What was tried**: Analysis of whether the case is contradictory (it is not -- genuinely reachable when d is a gap and x' = d). Analysis of whether making h_pt_xc/h_pt_cy conditional is safe (it is, but requires 5+ downstream usage site updates with careful case analysis in Case I).
- **Why it's stuck**: (1) These sorries are LATENT -- currently unreachable because the gap case of `h_exists` (line 1587, Phase 4C-W3) is itself sorry'd. The code path only fires when d is a gap AND the c construction for gaps is implemented. (2) The fix requires restructuring `SplitPointProps` to make `h_pt_xc`/`h_pt_cy` conditional (`x < c → ∃ p, ...`), then updating 5 downstream sites. Each site needs proof that `x < c` (or `c < y`) holds in its specific branch. In Case I, this follows from the split hypothesis + boundary correspondence. In Case II, c is always a point (so the witness exists trivially). (3) This is a prerequisite for Phase 4C-W3 gap case but NOT independently closable now.
- **What is needed**: Change `SplitPointProps.h_pt_xc` to `x < c → ∃ p, inClosedInterval x c (extendPoint p)` (and similarly `h_pt_cy`). Then update all 5 usage sites with appropriate guards. Estimated ~30-50 lines of changes. Should be done TOGETHER with Phase 4C-W3 (gap case of h_exists) to avoid wasted work.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

- [ ] **Task W1.4.1**: Close M-side degenerate `h_pt_xc` (line 1466) and `h_pt_cy` (line 1483) *(deviation: blocked -- latent sorries unreachable until Phase 4C-W3 gap case is implemented; fix requires SplitPointProps restructuring best done together with W3)*

- [ ] **Task W1.5**: Verify `lake build` passes. Cases I and II remain sorry-free.

**Timing**: 6-10 hours (muSig ~3h, pigeonhole ~2h, d-consistency ~3-4h, M-side degenerate ~2h)

**Depends on**: 0 (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close stavi_table_mu_correct stavi_untl/snce (lines 4188, 4191)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- pigeonhole (line 639), d-consistency (lines 941, 974), M-side degenerate (lines 1304, 1321)

**Verification**:
- [x] `lean_verify stavi_table_mu_correct` shows no `sorryAx` (verified 2026-05-21)
- [ ] `lean_verify pigeonhole_definable_formula` shows no `sorryAx`
- [ ] D-consistency sorries closed
- [ ] M-side degenerate sorries closed
- [ ] `ghr93_case_I` and `ghr93_case_II` show no `sorryAx`
- [ ] `lake build` passes

---

### Phase 4C-W2: Lemma 9 Gap Detection Correctness [NOT STARTED]

**Goal**: Prove `left_formula_gap_detection` (line 2432) and `right_formula_gap_detection` (line 2451) -- GHR93 Lemma 9 bridging temporal formulas to gap properties.

**Status**: UNBLOCKED by Phase 0 (correct U' semantics). GHR93 calls this "Clear".

**Tasks**:

- [ ] **Task W2.1**: Prove gap-equivalence lemma (~80-150 lines): FO-table-based U'(top, D)(m) iff existence of gap gamma above m with D-defined-on-left.
- [ ] **Task W2.2**: Prove Lemma 9 left easy cases (atom, bot, box, neg, conj) using gap-equivalence (~100-150 lines).
- [ ] **Task W2.3**: Prove Lemma 9 left hard cases (untl, snce, stavi_untl, stavi_snce) (~200-300 lines).
- [ ] **Task W2.4**: Prove Lemma 9 right (`right_formula_gap_detection`) -- dual (~50-100 lines).
- [ ] **Task W2.5**: Verify `lake build` passes.

**Timing**: 6-10 hours

**Depends on**: 0 (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close sorries at lines 2432, 2451

**Verification**:
- `lean_verify left_formula_gap_detection` shows no `sorryAx`
- `lean_verify right_formula_gap_detection` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W3: c-Gap-Case + Cases III/IV [NOT STARTED]

**Goal**: Close the c-gap-case sorry (line 1425) using Lemma 9, then prove Cases III and IV of GHR93 Theorem 6 (line 3329).

**Tasks**:

- [ ] **Task W3.1**: Close c-gap-case in `obtain_split_point_props` (line 1425, ~50-80 lines). Use Lemma 9 to transfer gap detection from N to M.
- [ ] **Task W3.2**: Split `ghr93_cases_III_IV` into Case III (left-defined gap, ~120-180 lines) and Case IV (~120-180 lines).
- [ ] **Task W3.3**: Verify `ghr93_inductive_step` assembly compiles.
- [ ] **Task W3.4**: Verify `lake build` passes.

**Timing**: 6-10 hours

**Depends on**: 4C-W1 (SplitPointProps restructured), 4C-W2 (Lemma 9 proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- close lines 1425, 3329

**Verification**:
- `obtain_split_point_props` has 0 sorries
- `lean_verify ghr93_inductive_step` shows no `sorryAx`
- `lake build` passes

---

### Phase 4C-W4: Assembly -- Rank-Varying Thm 6, Props 6-7, Corollary 5 [NOT STARTED]

**Goal**: Complete the assembly chain from Theorem 6 to `stavi_expressive_completeness` (GHR93 Corollary 5).

**Tasks**:

- [ ] **Task W4.1**: Prove rank-varying Theorem 6 (`ghr93_forward_to_backward_rank_varying`, line 3550, ~80-150 lines).
- [ ] **Task W4.2**: Determine whether Proposition 7 needs Lemma 11 backward. If yes, prove `ghr93_decomposition_implies_game` (line 3521, ~80-120 lines).
- [ ] **Task W4.3**: Prove Proposition 6 (~100-150 lines, entirely new).
- [ ] **Task W4.4**: Prove Proposition 7 (~150-250 lines, entirely new).
- [ ] **Task W4.5**: Prove Corollary 5 = close `stavi_expressive_completeness` (line 4529, ~80-120 lines).
- [ ] **Task W4.6**: Verify `lean_verify stavi_expressive_completeness` shows no `sorryAx`.
- [ ] **Task W4.7**: Run `lake build`.

**Timing**: 8-14 hours

**Depends on**: 4C-W3 (Theorem 6 fully proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- rank-varying Thm 6 (line 3550), Props 6-7 (new)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- close stavi_expressive_completeness (line 4529), possibly Lemma 11 backward (line 3521)

**Verification**:
- `lean_verify stavi_expressive_completeness` shows no `sorryAx`
- `lean_verify ghr93_forward_to_backward_rank_varying` shows no `sorryAx`
- `lake build` passes

---

### Phase 5': Reynolds Theorem 5 from Theorem 4 [NOT STARTED]

**Goal**: Prove {U,S} alone is expressively complete for Prior structures by composing Theorem 4 with flatten_stavi_correct.

**Tasks**:
- [ ] **Task 5'.1**: Define and prove `US_expressively_complete_over_prior` (~60-100 lines).
- [ ] **Task 5'.2**: Prove bridge lemma between `stavi_temporal_truth` and `temporal_truth` (~30-50 lines).
- [ ] **Task 5'.3**: Verify `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`.

**Timing**: 2-3 hours

**Depends on**: 4C-W4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` or new `Theorem5.lean`

**Verification**:
- `lean_verify US_expressively_complete_over_prior` shows no `sorryAx`
- `lake build` passes

---

### Phase 6: Reynolds Lemmas 6-13 and Theorem 14 (Gap Elimination) [NOT STARTED]

**Goal**: Formalize the gap elimination argument from Reynolds 1994 Section 7.

**Tasks**:
- [ ] **Task 6.1**: Create GapElimination.lean. Lemma 6 (~100-150 lines).
- [ ] **Task 6.2**: Lemma 7 (R_interval_open, ~80-100 lines).
- [ ] **Task 6.3**: Lemma 8 (no_first_last_class, ~60 lines).
- [ ] **Task 6.4**: Lemma 9-Reynolds (elementary_equiv_classes, ~130 lines).
- [ ] **Task 6.5**: Lemma 10 (bad_interval_structure, ~80 lines).
- [ ] **Task 6.6**: Lemma 11 (formula_propagation, ~60 lines).
- [ ] **Task 6.7**: Lemma 12 (model_surgery, ~250-300 lines -- 14 cases).
- [ ] **Task 6.8**: Lemma 13 (no_bad_points, ~60 lines).
- [ ] **Task 6.9**: Theorem 14 assembly (~10-30 lines).
- [ ] **Task 6.10**: Verify `lean_verify gap_elimination_theorem_14` shows no `sorryAx`.
- [ ] **Task 6.11**: Run `lake build`.

**Timing**: 8-12 hours

**Depends on**: 5'

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical.lean` -- add import

**Verification**:
- `lean_verify gap_elimination_theorem_14` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: IntegerModel.lean Helper Sorries [NOT STARTED]

**Goal**: Close `cofinal_decomposition_k_equiv` (line 1135) and `ordered_sum_of_good_bounded_is_good` (line 1194).

**Tasks**:
- [ ] **Task 7.1**: Prove `cofinal_decomposition_k_equiv` (~100-150 lines).
- [ ] **Task 7.2**: Prove `ordered_sum_of_good_bounded_is_good` for k>=2 (~100-200 lines).
- [ ] **Task 7.3**: Construct shift-and-glue OrderIso (~80-120 lines).
- [ ] **Task 7.4**: Verify `lean_verify very_good_implies_good` shows no `sorryAx`.

**Timing**: 5-8 hours

**Depends on**: none (can proceed in parallel with 4C chain)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

**Verification**:
- `lean_verify cofinal_decomposition_k_equiv` shows no `sorryAx`
- `lean_verify ordered_sum_of_good_bounded_is_good` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Wire no_gaps_discrete and one_class [NOT STARTED]

**Goal**: Replace `no_gaps_discrete` sorry (IntegerModel.lean:859) with call to `gap_elimination_theorem_14`.

**Tasks**:
- [ ] **Task 8.1**: Replace sorry with `gap_elimination_theorem_14` call (~20-40 lines).
- [ ] **Task 8.2**: Verify `lean_verify no_gaps_discrete` shows no `sorryAx`.
- [ ] **Task 8.3**: Run `lake build`.

**Timing**: 1-2 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`

**Verification**:
- `lean_verify no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Rewrite chronicle_is_good and Remove IsSuccArchimedean [NOT STARTED]

**Goal**: Rewrite `chronicle_is_good` to use `one_class` + `very_good_implies_good`. Remove `domain_succ_archimedean` from `ChronicleAsPriorModel`.

**Tasks**:
- [ ] **Task 9.1**: Rewrite `chronicle_is_good` (~30-50 lines).
- [ ] **Task 9.2**: Remove `domain_succ_archimedean` from `ChronicleAsPriorModel` (~20-30 lines deleted).
- [ ] **Task 9.3**: Fix cascade in NEquivalence.lean (~20-50 lines).
- [ ] **Task 9.4**: Remove `orderIsoIntOfLinearSuccPredArch` from `countermodel_discrete` (~30-50 lines).
- [ ] **Task 9.5**: Propagate removal to downstream code (~10-20 lines).
- [ ] **Task 9.6**: Verify `lake build` passes.

**Timing**: 3-5 hours

**Depends on**: 7, 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/ChronicleExtraction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`

**Verification**:
- `lean_verify chronicle_is_good` shows no `sorryAx`
- No `IsSuccArchimedean` in ChronicleAsPriorModel
- `lake build` passes

---

### Phase 10: Discharge h_truth_corr [NOT STARTED]

**Goal**: Eliminate the h_truth_corr sorry at Transfer.lean:574 by delegating `countermodel_discrete` to `dd_countermodel_chronicle_discrete`.

**Tasks**:
- [ ] **Task 10.1**: Replace `countermodel_discrete` proof body with delegation (~5 lines).
- [ ] **Task 10.2**: Remove unused infrastructure from Transfer.lean (~50 lines removed).
- [ ] **Task 10.3**: Verify `lean_verify countermodel_discrete` -- sorryAx from `succ_cofinal` only.
- [ ] **Task 10.4**: Verify `lake build` passes.

**Timing**: 1-2 hours

**Depends on**: none (independent)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean`

**Verification**:
- Transfer.lean:574 sorry eliminated
- `lake build` passes

---

### Phase 11: Final Wiring and Verification [NOT STARTED]

**Goal**: Verify entire pipeline is sorry-free with no custom axioms.

**Tasks**:
- [ ] **Task 11.1**: Run `lean_verify countermodel_discrete` -- should show only propext, Classical.choice, Quot.sound.
- [ ] **Task 11.2**: Run `lean_verify bx_completeness`.
- [ ] **Task 11.3**: Trace and fix any unexpected `sorryAx`.
- [ ] **Task 11.4**: Verify no `axiom` declarations: `grep -rn "^axiom" Theories/Bimodal/Metalogic/WeakCanonical/`.
- [ ] **Task 11.5**: Run full `lake build`.
- [ ] **Task 11.6**: Update file-level documentation.

**Timing**: 1-2 hours

**Depends on**: 9, 10

**Verification**:
- `#print axioms bx_completeness` shows: propext, Classical.choice, Quot.sound (NO sorryAx)
- `#print axioms stavi_expressive_completeness` shows: propext, Classical.choice, Quot.sound
- `lake build` passes with zero errors
- No `axiom` declarations in WeakCanonical directory

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

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean` -- Corrected Stavi semantics (DONE)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- stavi_table_mu_correct (muSig fix), Lemma 9, stavi_expressive_completeness
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` -- d-consistency, Cases III/IV, rank-varying Thm 6, Props 6-7
- `Theories/Bimodal/Metalogic/WeakCanonical/GapElimination.lean` -- Reynolds Lemmas 6-13, Theorem 14 (NEW)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` -- h_truth_corr, IsSuccArchimedean removal
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel.lean` -- cofinal_decomposition, no_gaps_discrete, chronicle_is_good
- `specs/155_reynolds_pipeline_activation/plans/15_reynolds-pipeline-plan.md` -- This plan (v10)

## Rollback/Contingency

1. **muSig (stavi_table_mu_correct)**: If `not_not_and_not` helper still doesn't close the proof, try Alternative B from report 21: define `not_not_and_not` as `@[simp]` lemma so it integrates with `simp only [not_and, Classical.not_not, not_not_and_not]`. If Fin.cons terms persist at depth 3+, use `conv` with `erw` pattern from handoff phase-muSig2.
2. **D-consistency (Claim 1)**: If infimum approach stalls, fall back to Option C (Classical.choice canonical strategy). D-consistency becomes `rfl`.
3. **Lemma 9**: With correct U' semantics, should be "Clear" per GHR93. If any case exceeds 150 lines, decompose into sub-lemmas. Mark [PARTIAL] with proved cases.
4. **Props 6-7**: If Prop 7 composition too complex, try direct Corollary 5 route.
5. **Gap elimination (Lemma 12)**: 14 cases can be modularized per case. Mark [PARTIAL] if stuck after 8 hours.
6. **NEVER fall back to axioms or IsSuccArchimedean**: If stuck, mark [BLOCKED] and request help.
