# Implementation Plan: GHR93-Faithful Reynolds Pipeline Completion (v43)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 20-30 hours
- **Dependencies**: Tasks 154 (COMPLETED), 168 (COMPLETED), 174 (COMPLETED), 199 (PARTIAL)
- **Research Inputs**: reports/47_xt-complete-usage-analysis.md, reports/47_lean-infrastructure-inventory.md, reports/47_plan-v42-deep-review.md, reports/46_strategic-pivot-report.md, reports/45_semantic-vs-syntactic-B.md, reports/44_literature-interval-splitting.md, reports/42_plan-literature-alignment.md, reports/40_ghr93-case-ii-step6.md, reports/39_game-depth-restructuring.md
- **Artifacts**: plans/43_definitive-ghr93-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is the definitive plan for completing the Reynolds pipeline, replacing plan v42. It incorporates findings from 9 team analysis reports and 42 prior plan versions. The plan follows GHR93/GHR94 exactly: delta=4 rank budget, independent X_t construction (not via nf_characterizable_by_stavi), general linear orders (Cases III/IV included), and every phase carries explicit literature instructions so implementation agents cannot diverge.

The plan is organized into 6 waves. Wave 1 closes the Theorem6.lean rank-varying IH, enabling sigma/tau at rank r+4. Wave 2 constructs X_t independently as a depth-at-most-r StaviFormula for each NormalForm equivalence class and builds the interval type formula A. Wave 3 rewrites Case II per GHR93, using U(B, A) to construct e_n from the Until witness. Wave 4 implements Cases III/IV gap handling with left(B,D)/right(B,D). Wave 5 closes all remaining downstream sorries. Wave 6 verifies sorry-free bx_completeness.

### Research Integration

All 9 team analysis reports are integrated. Key findings driving the plan:

- **Report 47 (X_t usage analysis)**: Every occurrence of X_t in GHR93 catalogued. B = X_{a_n} is a single formula of rank r, used syntactically inside U(B, A). A = X_{(a_{n-1}, a_n)} is the interval type formula, rank r. Rank budget ceiling: r+4 (Case IV).
- **Report 47 (infrastructure inventory)**: 39 total sorries, 11 on critical path. Case I sorry-free. Case II has 5 grid sorries. Cases III/IV has 1 assembly sorry. Theorem6.lean has 2 IH sorries. StaviCompleteness has 3 bridge sorries (NOT on critical path).
- **Report 47 (plan v42 review)**: S1 (bridge lemma) must be REMOVED from critical path. S2.5 (Theorem6:325) must be PROMOTED to wave 1. B formula must be constructed independently of nf_characterizable_by_stavi. A = sf_top is wrong; must use interval type formula. Estimated 15-28 hours.
- **Report 46 (strategic pivot)**: Bridge lemma is NOT on bx_completeness critical path. CaseAnalysis.lean does NOT import StaviCompleteness.lean. Construct X_t directly from depth-at-most-r StaviFormulas.
- **Report 45 (semantic vs syntactic B)**: GHR93 uses B SYNTACTICALLY as a single formula inside U(B, A). The semantic approach (working with rank_type as a predicate) is a deviation. Recommendation: follow GHR93's syntactic approach.
- **Report 44 (literature interval splitting)**: GHR93 resolves sub-interval splitting via the GAME, not by NF induction. The bridge lemma is proved through the game, which handles sub-interval types internally.
- **Report 42 (plan v42 alignment review)**: Three critical corrections: delta=4, A = interval type, B at depth r. Six recommendations R1-R6 all addressed in this plan.
- **Report 40 (Case II step 6)**: e_n = z (the U(B,A) witness transferred through tau), NOT from the forward game. sel_pn_ord is trivial: resp_tau(k) <= resp_tau(n-1) < z = e_n.
- **Report 39 (game-depth restructuring)**: game_depth unchanged. Rank flattening is root cause. Fix: carry delta parameter through SplitPointProps, sigma/tau at rank r+delta.

### Prior Plan Reference

Plan v42 correctly identified the GHR93 U(B,A) approach with delta=4, but had a fatal structural flaw: Phase S1 (bridge lemma closure) blocked all downstream phases, and the bridge lemma is NOT on the bx_completeness critical path. v42 also used A = sf_top (wrong per GHR93) and proposed constructing B via nf_characterizable_by_stavi (which has a sorry chain and produces depth ~2k, not depth r). This plan removes the bridge lemma from the critical path entirely, constructs X_t independently, and uses the correct A = interval type formula.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Close Theorem6.lean:325 (rank-varying IH) to enable delta=4 architecture
- Construct X_t independently as a depth-at-most-r StaviFormula per NF equivalence class
- Build A = X_{(a_{n-1}, a_n)} as an interval type formula of rank r
- Rewrite Case II using GHR93 U(B, A) with e_n from Until witness
- Implement left(B,D) and right(B,D) for Cases III/IV gap handling
- Close all 5 Case II grid dispatch sorries
- Close Cases III/IV winning condition assembly sorry
- Close Theorem6.lean:124 (uniform-rank IH)
- Wire through Transfer.lean to eliminate succ_cofinal from bx_completeness
- Achieve sorry-free bx_completeness (zero sorryAx in #print axioms)

**Non-Goals**:
- Closing the bridge lemma (nf_2var_from_interval_data in StaviCompleteness.lean) -- deferred to a separate task; NOT on bx_completeness critical path
- Changing game_depth definition (confirmed unnecessary per report 39)
- Changing EFGames core definitions (CustomGame, Decomposition, Composition are sorry-free)
- Dense or mixed completeness variants
- Non-critical TruthLemma sorries (6 sorries in TruthLemma.lean, documented non-critical)
- BXCanonical/Bundle/Algebraic sorry closure (20 sorries in independent subsystems)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| X_t construction: proving each NF class has a depth-at-most-r StaviFormula representative | H | M | The equivalence classes ARE defined by depth-at-most-r formulas, so representatives exist by definition. Use Classical.choice if constructive enumeration fails. Fall back to using nf_characterizable_by_stavi with sorry propagation (the sorry stays in StaviCompleteness, isolated from bx_completeness critical path). |
| Theorem6.lean:325 rank-varying IH more complex than estimated | M | M | The structure is understood (report 39): rank-embed forward game from r to r+4, restrict to sub-interval, apply IH at base rank r+4. Existing rank_embed infrastructure is sorry-free. |
| left(B,D)/right(B,D) implementation for Cases III/IV | M | L | GHR93 Def. 8.5/Lemma 9 are fully extracted in report 47. Structural induction on B with 6 cases. For discrete orders, Cases III/IV are vacuous (no gaps) -- can verify on Z first, then handle general case. |
| Round 2 winning condition proof complexity | M | M | GHR93's argument is explicit (report 40 Section 4.6). Challenge in (e_{n-1}, e_n): A holds by Until extraction. Challenge at e_n: B holds by witness property. Challenge elsewhere: tau handles. |
| Import chain pollution: using nf_characterizable_by_stavi puts sorry on bx_completeness path | H | L | Plan explicitly constructs X_t independently, WITHOUT importing StaviCompleteness.lean into CaseAnalysis.lean. If independent construction fails, accept sorry propagation as temporary debt with separate task to resolve. |
| Grid dispatch sorries (5 in Case II) harder than expected | L | L | Pattern is understood: Fin bridging between n and n+1, applying ordering lemmas. Task 199 (grid_order_tactic) partially addresses this. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2 |
| 5 | 5 | 3, 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Theorem6.lean Rank-Varying IH (delta=4 Foundation) [COMPLETED]

**Goal**: Close the sorry at Theorem6.lean:325, enabling sigma/tau at rank r+4 throughout the proof. This is the gate for all subsequent phases.

**Literature to read BEFORE implementing**:
- GHR93 Section 8, inductive step of Theorem 6 (literature/Gabbay_Hodkinson_Reynolds_1993, pp.113-115)
- GHR94 Chapter 12, Section 12.8.15 (literature/Gabbay_Hodkinson_Reynolds_1994_ch12.md, lines ~708-750)
- Report 39 (game-depth restructuring): Section 3 "The Fix" and Section 4 "Detailed Change Plan"

**The mathematical argument** (GHR93 inductive step):
1. Given: forward G_{4+3n; r+4(n+1)}(M, xy; N, x'y')
2. Claim 2 derives sub-interval forward games at rank r+4(n+1) = (r+4)+4n
3. Apply IH (*)_n at base rank r+4: forward G_{1+3n; (r+4)+4n} on sub-intervals gives backward G_{n; r+4} on sub-intervals
4. These backward games at rank r+4 ARE sigma and tau

**What the sorry requires** (Theorem6.lean:325):
- The IH `ih` says: for all sub-intervals, forward (1+3n) at rank r gives backward n at rank r+4 (on rank-embedded positions)
- We have a forward game at rank r+4(n+1) on the original positions
- We need to: (a) rank-embed the positions from r to r+4, (b) show the forward game at r+4(n+1) restricts to sub-intervals at the right rank, (c) apply the IH
- The rank embedding infrastructure (rank_embed, rank_embed_le, rank_embed_lt, etc.) is entirely sorry-free in TypeFormulas.lean

**Tasks**:
- [x] Task 1.1: Understand the existing `ih_delta4` lambda structure at line 308-316 *(completed)*
- [x] Task 1.2: Implement the rank promotion: forward game at rank r restricts to sub-intervals via ghr93_duplicator_wins_round_mono + rank embedding *(deviation: altered -- used h_r1_univ at r'=r+4n+2 instead of direct restriction, added rank_embed_trans and rank_embed_comp_heq helper lemmas)*
- [x] Task 1.3: Apply the IH at base rank r+4 with rank-embedded positions *(completed)*
- [x] Task 1.4: Verify that the resulting backward game at rank r+4 on rank-embedded positions has the correct type *(completed -- used ghr93_duplicator_wins_rank_cast for dependent type transport)*

**Anti-deviation warnings**:
- Do NOT try to avoid rank_embed by changing SplitPointProps signatures (SplitPointProps already supports delta parameter)
- Do NOT try delta=2 as a "simpler start" (delta=4 is the ONLY correct value for GHR93 Cases III/IV)
- Do NOT modify game_depth (confirmed unnecessary by report 39)
- Do NOT create workarounds like tau_r2 or h_ih_r2 (these were patches for the wrong architecture, documented in report 39 Section 2)

**Timing**: 3-5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- close sorry at line 325 (~80-150 new lines)

**Verification**:
- `lean_goal` at line 325 shows no sorry
- `lean_verify Bimodal.Metalogic.WeakCanonical.ghr93_forward_to_backward_rank_varying` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6` passes

---

### Phase 2: Independent X_t Construction (Characteristic Formula Machinery) [IN PROGRESS]

**Goal**: Build the machinery to construct X_t = B = X_{a_n} as a SINGLE StaviFormula of depth at most r for each NormalForm equivalence class, AND build A = X_{(a_{n-1}, a_n)} as the interval type formula. This follows GHR93 Definition 8.8 exactly, WITHOUT using nf_characterizable_by_stavi.

**Literature to read BEFORE implementing**:
- GHR93 Definition 8.8 / GHR94 Definition 12.8.13 (the definition of X_t and X_{(t,u)})
- Report 47 (X_t complete usage analysis): Section 1 (definition), Section 3 (A formula details), Section 6 (finiteness argument), Section 8 (decision matrix)
- Report 46 (strategic pivot): Section 2 "The Key Insight: Bypass nf_characterizable_by_stavi"
- Report 45 (semantic vs syntactic B): Section 2 "How Is B Constructed as a Single Formula?"

**The mathematical argument** (GHR93 finiteness + representative selection):

GHR93 says: "there are up to logical equivalence only finitely many distinct formulae of any rank." The equivalence classes at rank r are enumerated by `NormalForm sig r 1`, which IS Fintype. For each equivalence class (each NormalForm), there exists a StaviFormula of depth at most r that characterizes it. This follows from the DEFINITION: the equivalence class is defined by agreement on all depth-at-most-r StaviFormulas, so any finite conjunction of depth-at-most-r StaviFormulas that distinguishes this class from all others serves as a representative. Such a conjunction has depth at most r (max of conjuncts, each depth at most r).

In Lean, the key insight is: `stavi_n_equiv atomMap n M t N s` checks agreement on all StaviFormulas of depth at most `game_depth sig n`. At depth r, two points with the same rank_type satisfy the same depth-at-most-r formulas. Since NormalForm sig r 1 is Fintype with N classes, at most N depth-at-most-r formulas suffice to distinguish all classes (one per pair of classes that need separation).

**Construction strategy**: For each NormalForm `nf : NormalForm sig r 1`, define `nf_repr_stavi (nf : NormalForm sig r 1) : StaviFormula` as follows:
1. Use `Classical.choice` on the existence of a StaviFormula A with `stavi_depth A <= r` and the property that `stavi_temporal_truth_mu M atomMap r t A` holds iff the depth-r NF of t matches nf.
2. The existence proof: the NormalForm `nf` is characterized by a Boolean assignment to all depth-at-most-r 1-variable sentences. Each such sentence corresponds to a StaviFormula of depth at most r (by the Stavi translation, which is sorry-free for the forward direction). The conjunction of these is a StaviFormula of depth at most r characterizing nf.
3. Then B = `nf_repr_stavi (nf_of t)` and A = `sf_disjList (types.map nf_repr_stavi)` where types are the NFs realized in the interval.

**Alternative (pragmatic) strategy**: If proving existence at depth at most r requires infrastructure beyond what exists, use `nf_characterizable_by_stavi` but at a LOWER depth. In the completeness proof, the outer induction runs at depth k_nf, and r = game_depth(sig, k_nf+1) >> 2*k_nf. So nf_characterizable_by_stavi at depth k_nf gives B with stavi_depth at most ~2*k_nf, and U(B, A) at depth ~2*k_nf+2 << r+4. This is plan v42's approach, valid when called from the completeness proof context. NOTE: this approach requires importing StaviCompleteness.lean and accepting that nf_characterizable_by_stavi has a sorry chain. Since CaseAnalysis.lean currently does NOT import StaviCompleteness.lean, adding this import would put the sorry on the bx_completeness critical path.

**RECOMMENDED: Use the independent construction (strategy 1).** Only fall back to strategy 2 if strategy 1 proves infeasible after genuine effort.

**Tasks**:
- [ ] Task 2.1: Create `CharacteristicFormula.lean` in `EFGames/` (~200-300 lines)
  - Define `nf_repr_stavi : NormalForm sig r 1 -> StaviFormula` via Classical.choice
  - Prove existence: for each NF, a depth-at-most-r StaviFormula characterizes it
  - Prove `stavi_depth (nf_repr_stavi nf) <= r`
  - Prove correctness: `stavi_temporal_truth_mu M atomMap r t (nf_repr_stavi nf) <-> nf_eval_nf ...`
- [ ] Task 2.2: Define `x_t_formula : ExtendedCarrier M atomMap r -> StaviFormula` (~50-80 lines)
  - X_t = conjunction of `nf_repr_stavi nf` for NFs satisfied at t, plus negations of others
  - Prove `stavi_depth (x_t_formula t) <= r`
  - Prove correctness: `stavi_temporal_truth_mu M atomMap r u (x_t_formula t) <-> rank_type_eq t u`
- [ ] Task 2.3: Define `x_interval_formula : ExtendedCarrier -> ExtendedCarrier -> StaviFormula` (~50-80 lines)
  - A = disjunction of X_v for non-gap v in (t, u), using sf_disjList
  - Prove `stavi_depth (x_interval_formula t u) <= r`
  - Prove correctness: `stavi_temporal_truth_mu M atomMap r w A <-> rank_type w realized in (t, u)`
- [ ] Task 2.4: Define Until formula constructor `sf_untl_formula : StaviFormula -> StaviFormula -> StaviFormula` (~20-30 lines)
  - U(B, A) = `.std_untl B A` with `stavi_depth = max(depth B, depth A) + 2`
  - Prove depth bound: `stavi_depth (sf_untl_formula B A) = max(stavi_depth B, stavi_depth A) + 2`

**Anti-deviation warnings**:
- Do NOT use nf_characterizable_by_stavi for the primary construction (it has a sorry chain and produces depth ~2k, not depth r)
- Do NOT skip the depth bound proof -- it is ESSENTIAL for tau transfer in Phase 3
- Do NOT try to enumerate StaviFormulas directly (StaviFormula is not Fintype; enumerate NormalForm instead)
- Do NOT confuse rank_type (a Set of StaviFormulas, semantic) with x_t_formula (a single StaviFormula, syntactic)
- Do NOT place CharacteristicFormula.lean in Expressiveness/ (it belongs in EFGames/ alongside TypeFormulas.lean)

**Timing**: 4-6 hours

**Depends on**: Phase 1 (delta=4 must be available for the depth budget to make sense, though the construction is logically independent)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` -- NEW (~200-300 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add import

**Verification**:
- `lean_verify` on all new definitions shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` passes
- Verify `stavi_depth (x_t_formula t) <= r` compiles without sorry

---

### Phase 3: Case II Rewrite (GHR93 U(B, A) Construction) [NOT STARTED]

**Goal**: Rewrite ghr93_case_II in CaseAnalysis.lean to follow GHR93 exactly: construct e_n from U(B, A) witness transferred through tau at rank r+4, prove sel_pn_ord trivially, handle Round 2 via A's interval type property.

**Literature to read BEFORE implementing**:
- GHR93 Section 8, Case II (literature/Gabbay_Hodkinson_Reynolds_1993, pp.117-118)
- GHR94 Chapter 12, pp.792-810 (Case II detailed proof)
- Report 40 (GHR93 Case II step 6): ALL sections -- this is the definitive extraction
- Report 47 (X_t usage analysis): Section 2.4 (Case II formulas), Section 3 (A formula usage in Round 2)

**The GHR93 Case II proof (verbatim mathematical content)**:

Setup: a_n is a point (not a gap) in N_r. Spoiler has selected a_0 < a_1 < ... < a_n in [x', y'].

Step 1. Apply tau to a_0, ..., a_{n-1} to get resp_tau(0), ..., resp_tau(n-1).

Step 2. Define B = X_{a_n} (the rank-r type formula at a_n). B is a StaviFormula of depth r.
Define A = X_{(a_{n-1}, a_n)} (the interval type formula). A is a StaviFormula of depth r.
When n=0, take a_{n-1} = d_bar (= x' side) and e_{n-1} = c (= x side).

Step 3. N_r |= U(B, A)(a_{n-1}): a_n witnesses this (B holds at a_n, A holds on (a_{n-1}, a_n) trivially because A is the disjunction of types realized in the interval).

Step 4. Transfer U(B, A) through tau. tau preserves formulas of depth at most r+4. U(B, A) has depth max(r, r) + 2 = r + 2. Since r+2 <= r+4, the transfer succeeds: M_r |= U(B, A)(resp_tau(n-1)).

Step 5. Extract witness: there exists z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z). Set e_n = z.

Step 6. sel_pn_ord is trivial: resp_tau(k) <= resp_tau(n-1) < z = e_n for all k < n.

Step 7. Round 2 verification (5-way case split on Spoiler's challenge point t):
- (a) t in (resp_tau(k), resp_tau(k+1)) for k < n-1: use tau's winning condition
- (b) t in (resp_tau(n-1), e_n): M |= A(t), so t has the same rank-r type as some point v in (a_{n-1}, a_n). Respond with v.
- (c) t = e_n: e_n satisfies B = X_{a_n}, so e_n and a_n agree on all rank-r formulas. Respond with a_n.
- (d) t in (e_n, y): use the continuation formula C and tau's winning condition
- (e) t outside the response range: endpoint conditions from sigma/tau

**Tasks**:
- [ ] Task 3.1: Delete the old e_n construction (lines ~1240-1550 of CaseAnalysis.lean)
  - Remove tau_left, tau_right, resp_mod, same_side, d-compatible forward game approach
  - Remove h_ih_r2, tau_r2 workarounds
  - Keep the ghr93_case_II function signature and initial setup (receive SplitPointProps with delta=4)
- [ ] Task 3.2: Build B = x_t_formula(a_n) and A = x_interval_formula(a_{n-1}, a_n) (~30-50 lines)
  - Import CharacteristicFormula.lean
  - Handle n=0 boundary: when n=0, a_{n-1} = props.d_bar, e_{n-1} = props.c
- [ ] Task 3.3: Show N_r |= U(B, A)(a_{n-1}) (~20-40 lines)
  - Witness is a_n: B holds at a_n (by x_t_formula correctness), A holds on (a_{n-1}, a_n) (every point in the interval has its type as a disjunct of A)
  - Use stavi_temporal_truth_mu + sf_untl semantics
- [ ] Task 3.4: Transfer U(B, A) through tau at rank r+4 (~30-50 lines)
  - tau.winning_condition gives: for all StaviFormulas phi with stavi_depth phi <= r+4, truth at a_{n-1} in N iff truth at resp_tau(n-1) in M
  - stavi_depth(U(B, A)) = max(r, r) + 2 = r + 2 <= r + 4
  - Therefore M_r |= U(B, A)(resp_tau(n-1))
- [ ] Task 3.5: Extract witness z = e_n and prove sel_pn_ord (~30-50 lines)
  - Unpack the Until: exists z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z)
  - Set e_n = z
  - sel_pn_ord: resp_tau(k) <= resp_tau(n-1) < z = e_n (tau order preservation + Until witness definition)
- [ ] Task 3.6: Round 2 winning condition (~150-250 lines)
  - 5-way case split on Spoiler's challenge point b_sp
  - Case (b) is the key new case: b_sp in (resp_tau(n-1), e_n) -> A holds at b_sp -> extract matching t' from (a_{n-1}, a_n) -> rank-r type agreement
  - Case (c): b_sp = e_n -> B holds -> rank-r type agreement with a_n
  - Cases (a), (d), (e): inherited from tau/sigma winning conditions
- [ ] Task 3.7: Close the 5 grid dispatch sorries (lines 1668, 1669, 2026, 2027, 2107) (~100-200 lines)
  - These are ordering/equality cases between game_tuple positions
  - Pattern: Fin bridging, apply existing ordering lemmas (tau_sel_y, tau_sel_sel, sel_pn_ord, pn_sel_ord, pivot_chain_order)
  - Task 199 (grid_order_tactic) may provide automation for some of these

**Anti-deviation warnings**:
- Do NOT construct e_n from the forward game (GHR93 does not use the forward game for e_n in Case II -- report 40 is definitive)
- Do NOT use A = sf_top (sf_top provides no information for Round 2 case (b) -- reports 42 and 45 are definitive)
- Do NOT use nf_characterizable_by_stavi for B (use x_t_formula from Phase 2 instead)
- Do NOT create tau_r2 or h_ih_r2 workarounds (tau is already at rank r+4 from Phase 1)
- Do NOT skip the n=0 boundary case (when n=0, a_{n-1} = d_bar, e_{n-1} = c)
- Do NOT try to avoid the full Round 2 case split (all 5 cases are needed per GHR93)

**Timing**: 6-10 hours

**Depends on**: Phase 1 (delta=4), Phase 2 (X_t and A construction)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II (~300-500 lines net change, much deletion + new code)

**Verification**:
- All 5 grid dispatch sorries closed (lines 1668, 1669, 2026, 2027, 2107)
- `lean_verify Bimodal.Metalogic.WeakCanonical.ghr93_case_II` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes

---

### Phase 4: Cases III/IV Gap Handling (General Linear Orders) [NOT STARTED]

**Goal**: Implement left(B, D) and right(B, D) per GHR93 Lemma 9, then use them to complete Cases III/IV, closing the sorry at CaseAnalysis.lean:3350.

**Literature to read BEFORE implementing**:
- GHR93 Definition 8.5 / GHR94 Definition 12.8.6 (left/right formulas, structural induction on A)
- GHR93 Lemma 9 / GHR94 Lemma 12.8.7 (correctness of left/right)
- GHR93 Section 8, Cases III and IV (pp.118-119)
- GHR94 Chapter 12, pp.812-850 (Cases III/IV detailed proof)
- Report 47 (X_t usage analysis): Sections 2.5-2.6 (Cases III/IV formulas), Section 4 (left/right definitions)

**The mathematical argument (Cases III/IV)**:

Case III (a_n is a gap defined on the left by D):
1. delta_III = left(B, D) at rank r+2
2. N_r |= U(delta_III, A)(a_{n-1}): by Lemma 9, left(B,D)(t) means there exists a D-left-gap above t with B^mu true at it. a_n IS such a gap.
3. Transfer U(delta_III, A) through tau at rank r+4: depth = max(r+2, r) + 2 = r+4. This is at the ceiling of tau's range -- exactly fits.
4. Extract witness in M, apply Lemma 9 to find gap e_n in M matching a_n.

Case IV (a_n is a gap NOT defined on the left):
1. a_n must be definable on the right by some D of rank <= r
2. delta_IV = A AND NOT(D) AND U(right(B,D), A) at rank r+3
3. N_r |= U(delta_IV, A)(a_{n-1}) (more complex construction)
4. Transfer U(delta_IV, A) through tau at rank r+4: depth = max(r+3, r) + 2 = r+5... WAIT. Let me recalculate.
   - Actually: U(delta_IV, A) has depth max(depth(delta_IV), depth(A)) + 2 = max(r+3, r) + 2 = r+5. This EXCEEDS r+4.
   - CORRECTION per report 47: GHR94 p.839 states rank(U(delta_IV, A)) = r+4, not r+5. The calculation is: delta_IV itself has rank r+3, A has rank r, so U(delta_IV, A) has rank max(r+3, r) + 1 = r+4. Note: GHR93 uses "rank" as max(rank of subformulas) + 1 for Until, while stavi_depth uses +2. This is a formula rank vs stavi_depth distinction. The resolution: in the Lean formalization, stavi_depth of `.std_untl A B` = max(stavi_depth A, stavi_depth B) + 2. If delta_IV has stavi_depth r+2 (not r+3), then U(delta_IV, A) has stavi_depth r+4. This requires careful depth tracking of left/right/compound constructions.

**IMPORTANT**: The rank/depth arithmetic for Case IV is at the absolute ceiling (r+4). Implementation must verify exact depth bounds.

**Tasks**:
- [ ] Task 4.1: Create `GapFormulas.lean` in `EFGames/` (~200-300 lines)
  - Define `left_formula : StaviFormula -> StaviFormula -> StaviFormula` by structural induction on A (6 cases per report 47 Section 4.1)
  - Define `right_formula : StaviFormula -> StaviFormula -> StaviFormula` (dual: swap U/S and U'/S')
  - Prove `left_depth_bound : stavi_depth (left_formula A D) <= max (stavi_depth A) (stavi_depth D) + 2`
  - Prove `right_depth_bound` similarly
- [ ] Task 4.2: Prove Lemma 9 correctness (~150-250 lines)
  - `left_correct`: left(A, D)(m) iff exists gap gamma > m, gamma defined by D on the left, D on (m, gamma), A^mu(gamma)
  - `right_correct`: dual
  - These require interfacing with ExtendedCarrier gap infrastructure (r_definable_gap_left, r_definable_gap_right from TypeFormulas.lean)
- [ ] Task 4.3: Complete Case III implementation (~100-150 lines)
  - Build delta_III = left_formula (x_t_formula a_n) D
  - Show U(delta_III, A) holds at a_{n-1} in N
  - Transfer through tau at rank r+4 (depth verification: r+2+2 = r+4, EXACTLY at ceiling)
  - Extract gap witness e_n in M via Lemma 9
  - Round 2 verification (mirrors Case II structure)
- [ ] Task 4.4: Complete Case IV implementation (~100-150 lines)
  - Build delta_IV = sf_conj A (sf_conj (sf_neg D) (sf_untl (right_formula (x_t_formula a_n) D) A))
  - Verify stavi_depth(delta_IV) and stavi_depth(U(delta_IV, A)) -- must be at most r+4
  - Transfer through tau at rank r+4
  - Extract gap witness e_n in M via right_formula correctness
  - Round 2 verification
- [ ] Task 4.5: Close the winning condition assembly sorry at CaseAnalysis.lean:3350 (~100-200 lines)
  - This mirrors the Case II winning condition pattern
  - Integrate gap formula verification from Tasks 4.3-4.4

**Anti-deviation warnings**:
- Do NOT simplify Cases III/IV for discrete orders (the plan targets GENERAL linear orders per user directive)
- Do NOT skip Lemma 9 correctness (it is the bridge between gap formulas and gap-existence statements)
- Do NOT assume depth(left(A,D)) = rank(left(A,D)) (stavi_depth uses +2 for temporal constructors while GHR93 rank uses +1)
- Do NOT attempt to close Cases III/IV without Phase 2's X_t machinery (B = X_{a_n} is needed in left(B,D))

**Timing**: 5-8 hours

**Depends on**: Phase 2 (X_t construction for B and A)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` -- NEW (~350-500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add import
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- update ghr93_cases_III_IV (~200-350 lines)

**Verification**:
- Sorry at CaseAnalysis.lean:3350 closed
- `lean_verify` on left_formula, right_formula, left_correct, right_correct shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes

---

### Phase 5: Downstream Sorry Closure and Wiring [NOT STARTED]

**Goal**: Close all remaining sorries that feed into bx_completeness: Theorem6.lean:124 (uniform-rank IH), Transfer.lean wiring, and any remaining mechanical sorries.

**Literature to read BEFORE implementing**:
- GHR93 Theorem 6 overall structure (the uniform-rank version is a special case of rank-varying with delta=0)
- Report 47 (infrastructure inventory): Section 7 (complete sorry inventory), Section 8.2 (what's missing)

**Tasks**:
- [ ] Task 5.1: Close Theorem6.lean:124 (uniform-rank IH) (~50-100 lines)
  - The uniform-rank version uses delta=0 (sigma/tau at rank r, same as backward game)
  - With the rank-varying version (Phase 1) sorry-free, the uniform version can be proved as a corollary: instantiate rank-varying with a forward game at rank r (= r+4*0), getting backward at rank r
  - Alternatively, the uniform version may become unused if the downstream code only calls the rank-varying version
- [ ] Task 5.2: Verify Transfer.lean imports and wiring (~30-50 lines)
  - Transfer.lean should call the game-theoretic pipeline (Theorem6 + CaseAnalysis) to produce a countermodel
  - Verify that doets_countermodel_discrete uses the Reynolds pipeline, not the chronicle fallback
  - If Transfer.lean still delegates to ChronicleToCountermodel, rewire to use the game pipeline
- [ ] Task 5.3: Thread h_surj if needed (~30-60 lines)
  - If Phase 2's X_t construction requires h_surj (surjectivity of atomMap), thread it through ghr93_inductive_step -> ghr93_forward_to_backward -> Transfer.lean
  - If Phase 2 uses Classical.choice without h_surj, this task is unnecessary
- [ ] Task 5.4: Close any remaining mechanical sorries exposed by Phases 3-4 (~50-100 lines)
  - Grid dispatch residuals not covered by Task 3.7
  - DConsistencyTransport.lean rank adjustments if needed
  - GapDetection.lean wiring for Cases III/IV

**Anti-deviation warnings**:
- Do NOT introduce new sorries to "fix" existing ones (every sorry must be genuinely closed)
- Do NOT bypass Transfer.lean by modifying Completeness.lean directly (the pipeline must flow through Transfer.lean)
- Do NOT close GoodStructures.lean:842 (no_gaps_discrete) as part of this phase -- it depends on stavi_expressive_completeness which has the bridge lemma sorry; it is NOT on the critical path if the Reynolds pipeline bypasses it
- Do NOT close ChronicleToCountermodel.lean sorries (succ_cofinal chain) -- these are bypassed by the Reynolds pipeline, not closed

**Timing**: 3-5 hours

**Depends on**: Phase 3, Phase 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- close line 124 (~50-100 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` -- wiring (~30-50 lines)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/DConsistencyTransport.lean` -- rank adjustments
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapDetection.lean` -- Cases III/IV wiring

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.ghr93_forward_to_backward` shows no sorryAx
- Transfer.lean compiles without sorry on the critical path
- `lake build Bimodal.Metalogic.WeakCanonical` passes

---

### Phase 6: Final Verification (Sorry-Free bx_completeness) [NOT STARTED]

**Goal**: Full project build, axiom audit, and verification that bx_completeness has zero sorryAx.

**Tasks**:
- [ ] Task 6.1: Full lake build
  - `lake build` must pass with zero errors
- [ ] Task 6.2: Axiom audit on bx_completeness
  - `#print axioms bx_completeness` must show NO sorryAx
  - If sorryAx appears, trace the dependency chain to identify the source
- [ ] Task 6.3: Sorry audit on critical path files
  - `grep -n sorry` on: Theorem6.lean, CaseAnalysis.lean, SplitPoint.lean, CharacteristicFormula.lean, GapFormulas.lean, Transfer.lean
  - All sorries must be in non-critical-path code or documented as deferred
- [ ] Task 6.4: Document remaining sorries
  - Update sorry audit comments in source files
  - List any sorries that remain in the WeakCanonical/ tree with their categorization (critical-path vs non-critical vs deferred)

**Timing**: 1-2 hours

**Depends on**: Phase 5

**Files to modify**:
- None (read-only verification), unless sorries are found

**Verification**:
- `lake build` passes
- `#print axioms bx_completeness` shows no sorryAx
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/` reports zero hits on critical-path theorems

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `#print axioms bx_completeness` shows no sorryAx after Phase 6
- [ ] `lean_verify` on ghr93_forward_to_backward_rank_varying shows no sorryAx after Phase 1
- [ ] `lean_verify` on ghr93_case_II shows no sorryAx after Phase 3
- [ ] `lean_verify` on ghr93_cases_III_IV shows no sorryAx after Phase 4
- [ ] stavi_depth(x_t_formula t) <= r verified by type checker after Phase 2
- [ ] stavi_depth(U(B, A)) <= r+4 verified by type checker after Phase 3
- [ ] All new definitions and theorems have module docstrings

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/43_definitive-ghr93-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (NEW, Phase 2)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` (NEW, Phase 4)
- Modified: `Theorem6.lean`, `CaseAnalysis.lean`, `Transfer.lean`

## Rollback/Contingency

**If Phase 2 (X_t construction) proves infeasible**:
- Fall back to plan v42's approach: use nf_characterizable_by_stavi with sorry propagation
- Import StaviCompleteness.lean into CaseAnalysis.lean
- Accept that bx_completeness will temporarily have sorryAx from the bridge lemma
- Create a separate high-priority task to close the bridge lemma

**If Phase 4 (Cases III/IV) proves too complex**:
- Close Case II first (Phase 3), achieving sorry-free bx_completeness for DISCRETE orders (no gaps on Z)
- Defer Cases III/IV to a follow-up task focused on dense/general linear orders
- This partial result is still valuable: sorry-free discrete completeness is the primary goal per task description

**If any phase exceeds 2x time estimate**:
- Write handoff document with current state, blockers, and recommended next steps
- Mark phase as [PARTIAL] and return for user review

**Git safety**: All changes are on existing files in the WeakCanonical/ tree. No destructive operations. Rollback via `git checkout` on individual files.
