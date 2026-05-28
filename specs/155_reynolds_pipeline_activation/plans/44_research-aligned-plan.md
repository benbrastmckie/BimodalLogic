# Implementation Plan: Research-Aligned Reynolds Pipeline Completion (v44)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 22-35 hours
- **Dependencies**: Tasks 154 (COMPLETED), 168 (COMPLETED), 174 (COMPLETED), 199 (PARTIAL)
- **Research Inputs**: reports/44_team-research.md, reports/44_teammate-a-findings.md, reports/44_teammate-b-findings.md, reports/44_teammate-c-findings.md, reports/44_teammate-d-findings.md, reports/47_xt-complete-usage-analysis.md, reports/47_lean-infrastructure-inventory.md, reports/47_plan-v42-deep-review.md, reports/46_strategic-pivot-report.md, reports/45_semantic-vs-syntactic-B.md, reports/44_literature-interval-splitting.md, reports/42_plan-literature-alignment.md, reports/40_ghr93-case-ii-step6.md, reports/39_game-depth-restructuring.md
- **Artifacts**: plans/44_research-aligned-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v44 revises plan v43 based on the v44 team research findings (4 teammates: tactic engineering, GHR93 literature, critical gap analysis, strategic assessment). The fundamental insight is that the grid dispatch blocker in CaseAnalysis.lean is a SYMPTOM of architectural divergence from GHR93, not a standalone tactic engineering problem. The correct fix combines: (1) closing CharacteristicFormula existence sorries that gate the U(B,A) approach, (2) building tactic infrastructure (unhygienic intro, order_reverse) as general-purpose tools, (3) a GHR93-faithful Case II rewrite that replaces the forward-game e_n construction with U(B,A) witness extraction, (4) Cases III/IV with real gap formula proofs for the full general result.

Key corrections from plan v43:

- **CharacteristicFormula sorries promoted to Phase 3**: x_t_formula_exists and x_interval_formula_exists are ON the critical path and gate the entire U(B,A) approach. Plan v43 listed them as completed-with-caveats but did not highlight them as blockers.
- **Tactic infrastructure as explicit Phase 4**: The `unhygienic intro` fix and `order_reverse` helper (verified by Teammate A with lean_run_code, HIGH confidence) are prerequisites for both the Case II rewrite and any remaining grid dispatch goals.
- **Case II rewrite reframed as architectural simplification**: The current Case II is ~1170 lines for what GHR93 proves in ~2 pages. The rewrite should REPLACE ~300 lines (forward-game e_n, resp_mod, sel_pn_ord machinery) with ~150-250 lines (U(B,A) construction), producing a net REDUCTION in code.
- **lean_verify MCP tool marked unreliable**: Always use `#print axioms` via lean_run_code for authoritative sorry verification (Teammate D finding).
- **CaseAnalysis.lean not currently on critical path**: Transfer.lean does NOT import Expressiveness/. Phase 7 (Transfer.lean rewiring) is the step that actually activates the Reynolds pipeline.

### Research Integration

All team research reports from round 44 are integrated. Key findings driving the revision:

- **Report 44 (team synthesis)**: Unified picture -- grid dispatch is symptom, GHR93 rewrite is cure. Recommended attack order: CharacteristicFormula -> tactic infra -> Case II rewrite -> Cases III/IV -> Transfer rewiring -> verification.
- **Report 44 (Teammate A, tactic engineering)**: Verified `unhygienic intro` fix preserves variable accessibility through `<;>`. Classified all 8 surviving grid goals. `order_reverse` helper closes reverse-ordering goals (goal 1 at line 1668).
- **Report 44 (Teammate B, GHR93 literature)**: Current Case II constructs e_n via d-compatible forward game (lines 1257-1288), NOT via U(B,A). This creates non-trivial cross-game ordering. GHR93's approach makes sel_pn_ord trivial.
- **Report 44 (Teammate C, gap analysis)**: CaseAnalysis.lean NOT imported by Transfer.lean. CharacteristicFormula existence sorries gate everything. resp_mod is an artifact of non-GHR93 construction. GHR93 rewrite should reduce Case II from ~1170 to ~400-600 lines.
- **Report 44 (Teammate D, strategic assessment)**: completeness_discrete HAS sorryAx (lean_verify gave false negative). Single root sorry: succ_cofinal. Reynolds pipeline IS needed. 43 plan versions represent genuine mathematical difficulty convergence, not scope creep.

### Prior Plan Reference

Plan v43 correctly identified the GHR93 U(B,A) approach with delta=4, independent X_t construction, and full general linear orders. However, it had two structural issues: (1) the CharacteristicFormula existence sorries were not highlighted as Phase 3 blockers, and (2) the grid dispatch was treated as a standalone tactic problem (Task 3.7) rather than as a consequence of the forward-game e_n divergence. This plan restructures the phases to address dependencies correctly.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Close CharacteristicFormula.lean existence sorries (x_t_formula_exists, x_interval_formula_exists)
- Build tactic infrastructure: order_reverse helper, same_order_type_grid_uh macro
- Rewrite Case II using GHR93 U(B,A) with e_n from Until witness, eliminating resp_mod
- Implement left(B,D) and right(B,D) for Cases III/IV gap handling (GHR93 Lemma 9)
- Close all CaseAnalysis.lean sorries (grid dispatch + Cases III/IV assembly)
- Wire Transfer.lean to the game-theoretic pipeline, bypassing succ_cofinal
- Achieve sorry-free bx_completeness (zero sorryAx in #print axioms)

**Non-Goals**:
- Closing the bridge lemma (nf_2var_from_interval_data in StaviCompleteness.lean) -- deferred; NOT on bx_completeness critical path
- Changing game_depth definition (confirmed unnecessary per report 39)
- Changing EFGames core definitions (CustomGame, Decomposition, Composition are sorry-free)
- Dense or mixed completeness variants
- Non-critical TruthLemma sorries (6 sorries in TruthLemma.lean, documented non-critical)
- BXCanonical/Bundle/Algebraic sorry closure (20 sorries in independent subsystems)
- Proving succ_cofinal directly (12+ research rounds concluded this is a genuine gap under strict semantics)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CharacteristicFormula existence sorries harder than estimated | H | M | The rank_type quotient finiteness follows from NormalForm being Fintype + rank_type_separator being sorry-free. If direct proof is infeasible, fall back to nf_characterizable_by_stavi (accepting temporary sorry from StaviCompleteness). |
| GHR93 Case II rewrite: type-level incompatibilities with existing SplitPointProps | M | M | SplitPointProps already supports delta parameter and provides tau/sigma at rank r+4. The rewrite changes the e_n construction, not the SplitPointProps interface. If interface changes are needed, modify SplitPointProps signatures incrementally. |
| left(B,D)/right(B,D) depth arithmetic for Case IV at ceiling r+4 | M | M | GHR94 p.839 confirms rank(U(delta_IV, A)) = r+4. Track stavi_depth vs GHR93 "rank" distinction carefully (stavi_depth uses +2 for temporal, GHR93 rank uses +1). Verify depth bounds at each step with lean_goal. |
| Transfer.lean rewiring: type-signature incompatibility between game pipeline output and what Completeness.lean expects | M | H | Phase 7 includes explicit type-signature analysis. If incompatible, build an adapter layer (~50-100 lines) that converts game pipeline output to the expected type. |
| unhygienic intro causes unexpected behavior in future Lean versions | L | L | unhygienic is a documented Lean 4 feature. The alternative (manual rcases creating named goals, ~300 lines per grid) is available as fallback. |
| Net code increase instead of reduction after Case II rewrite | L | L | Target: delete ~300 lines (forward-game e_n, resp_mod, sel_pn_ord), add ~200-400 lines (U(B,A) construction + simplified Round 2). Track net line count during implementation. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (already COMPLETED) |
| 1 | 3, 4 | -- |
| 2 | 5 | 3, 4 |
| 3 | 6 | 3, 4 |
| 4 | 7 | 5, 6 |
| 5 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Theorem6.lean Rank-Varying IH (delta=4 Foundation) [COMPLETED]

**Goal**: Close the sorry at Theorem6.lean:325, enabling sigma/tau at rank r+4 throughout the proof.

**Status**: Fully completed. Theorem6.lean is sorry-free. Used rank-varying IH with delta=4, h_r1_univ at r'=r+4n+2, added rank_embed_trans and rank_embed_comp_heq helper lemmas, used ghr93_duplicator_wins_rank_cast for dependent type transport.

**Tasks**:
- [x] Task 1.1: Understand the existing `ih_delta4` lambda structure at line 308-316
- [x] Task 1.2: Implement the rank promotion via h_r1_univ at r'=r+4n+2
- [x] Task 1.3: Apply the IH at base rank r+4 with rank-embedded positions
- [x] Task 1.4: Verify backward game at rank r+4 has correct type

**Timing**: 3-5 hours (actual: completed)

**Depends on**: none

**Completed**: 2026-05-28

---

### Phase 2: Independent X_t Construction (Characteristic Formula Machinery) [COMPLETED]

**Goal**: Build the machinery to construct X_t = B = X_{a_n} as a SINGLE StaviFormula of depth at most r for each NormalForm equivalence class, AND build A = X_{(a_{n-1}, a_n)} as the interval type formula. Created CharacteristicFormula.lean (~310 lines) with sorry-free API except 2 existence sorries.

**Status**: Fully completed. Core API is sorry-free: sf_disj, sf_disjList, sf_conjList with depth bounds; rank_type_separator (sorry-free); x_t_formula, x_t_depth, x_t_correct, x_t_self, x_t_implies_agreement; x_interval_formula, x_interval_depth, x_interval_correct, x_interval_self; sf_untl, sf_snce constructors with depth bounds and truth semantics; untl_extract_witness, untl_type_holds_at_witness, untl_type_depth_le_r_plus_4.

Two existence sorries remain: x_t_formula_exists (line 221) and x_interval_formula_exists (line 285), requiring finiteness of rank_type quotient. These are addressed in Phase 3.

**Tasks**:
- [x] Task 2.1: Create CharacteristicFormula.lean in EFGames/ (~310 lines)
- [x] Task 2.2: Define x_t_formula via Classical.choose on x_t_formula_exists
- [x] Task 2.3: Define x_interval_formula via Classical.choose on x_interval_formula_exists
- [x] Task 2.4: Define Until/Since formula constructors sf_untl and sf_snce

**Timing**: 4-6 hours (actual: completed)

**Depends on**: Phase 1

**Completed**: 2026-05-28

---

### Phase 3: Close CharacteristicFormula Existence Sorries [COMPLETED]

**Goal**: Close the two existence sorries in CharacteristicFormula.lean that gate the entire U(B,A) approach. Without these, B and A cannot be constructed for Case II, and left(B,D)/right(B,D) cannot be used for Cases III/IV.

**Literature to read BEFORE implementing**:
- GHR93 Definition 8.8 / GHR94 Definition 12.8.13 (finiteness argument: "up to logical equivalence only finitely many distinct formulae of any rank")
- Report 47 (X_t usage analysis): Section 6 (finiteness argument)
- Report 46 (strategic pivot): Section 2 "Bypass nf_characterizable_by_stavi"
- CharacteristicFormula.lean source (current state with sorry sites)

**The mathematical argument**:

The existence of x_t_formula requires showing: for each extended carrier point t, there exists a StaviFormula A with stavi_depth A <= r such that for all u, truth of A at u iff rank_type u = rank_type t. The key steps:

1. NormalForm sig r 1 is Fintype (already established in codebase)
2. Each rank_type equivalence class corresponds to a subset of NormalForm evaluations
3. rank_type_separator (proved sorry-free in Phase 2): distinct rank_types have separating StaviFormulas of depth <= r
4. The quotient of ExtendedCarrier by rank_type equality has at most |NormalForm sig r 1| classes (finitely many)
5. For each class, take the conjunction of separators against all other classes. This is a finite conjunction of depth-at-most-r StaviFormulas, so it has depth at most r and characterizes the class.

For x_interval_formula_exists: the interval type is the set of rank_types realized in (t, u). Since rank_types are finitely many, the set of realized types is finite. The disjunction sf_disjList of x_t_formulas for each realized type characterizes the interval type.

**Tasks**:
- [x] Task 3.1: Prove rank_type quotient finiteness (~80-120 lines) *(deviation: altered -- used nf_profile on extendedStructureWithMu at depth 2*r instead of rank_type quotient Fintype; proved nf_profile_determines_rank_type as the key bridge)*
  - Show that the image of `rank_type` on ExtendedCarrier is a subset of the power set of depth-at-most-r StaviFormulas
  - Since NormalForm sig r 1 is Fintype, and rank_type is determined by NormalForm evaluation, the number of distinct rank_types is bounded by |NormalForm sig r 1|
  - Use Fintype.ofFinset or Fintype.ofInjective on the rank_type quotient
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean`
- [x] Task 3.2: Close x_t_formula_exists (~60-100 lines)
  - Construct the separating formula as a conjunction of rank_type_separator applications
  - The conjunction has stavi_depth = max of conjuncts, each <= r, so <= r
  - Prove the iff: truth at u iff rank_type u = rank_type t
  - Forward direction: if rank_type u = rank_type t, then u satisfies all the same separators, hence the conjunction
  - Backward direction: if u satisfies the conjunction, then u agrees with t on all separating formulas, hence rank_type u = rank_type t
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (line ~221)
- [x] Task 3.3: Close x_interval_formula_exists (~50-80 lines)
  - The interval type is the set of rank_types realized in (t, u)
  - Since rank_types are finite, enumerate the realized types
  - Build sf_disjList of x_t_formulas for each realized type
  - stavi_depth = max of disjuncts, each <= r, so <= r
  - Prove the iff: truth at w in (t, u) iff rank_type w is realized in the interval
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (line ~285)
- [x] Task 3.4: Verify sorry-free status of CharacteristicFormula.lean (~10 lines)
  - `#print axioms` on x_t_formula, x_interval_formula, and all downstream lemmas
  - Verify no sorryAx remains in the CharacteristicFormula module
  - **Verification command**: `lean_run_code` with `#print axioms Bimodal.Metalogic.WeakCanonical.EFGames.x_t_formula`

**Anti-deviation warnings**:
- Do NOT use nf_characterizable_by_stavi (it has a sorry chain and is NOT on the critical path)
- Do NOT try to prove finiteness by enumerating all StaviFormulas (StaviFormula is not Fintype; enumerate NormalForm instead)
- Do NOT skip the depth bound proof -- it gates tau transfer in Phase 5
- Do NOT modify rank_type_separator (it is already sorry-free)
- Always verify with `#print axioms` via lean_run_code, NEVER with lean_verify (which gave false results per Teammate D)

**Timing**: 3-5 hours

**Depends on**: none (Phase 2 completed, this closes its remaining sorries)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` -- close 2 sorries (~190-300 new lines)

**Verification**:
- `#print axioms` on x_t_formula shows no sorryAx
- `#print axioms` on x_interval_formula shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` passes with zero sorry

---

### Phase 4: Tactic Infrastructure (Grid Dispatch Prerequisites) [NOT STARTED]

**Goal**: Build general-purpose tactic infrastructure that will be used by the Case II rewrite (Phase 5), Cases III/IV (Phase 6), and any remaining grid dispatch goals. This phase can execute in parallel with Phase 3.

**Literature to read BEFORE implementing**:
- Report 44 (Teammate A, tactic engineering): Verified solutions with lean_run_code
- CaseAnalysis.lean lines 1580-1670 (current grid dispatch structure)
- EFGameTactics.lean (current same_order_type_grid macro)

**Research backing (HIGH confidence)**:
- `unhygienic intro` preserves variable accessibility through `<;>` (verified by Teammate A)
- `order_reverse` helper closes reverse-ordering goals (verified by Teammate A)
- Goal classification at line 1668: 8 goals, all analyzable with accessible Fin variables

**Tasks**:
- [ ] Task 4.1: Add `order_reverse` theorem to EFGameTactics.lean (~25 lines)
  - Derives `(b < a iff b' < a') AND (b = a iff b' = a')` from `(a < b iff a' < b') AND (a = b iff a' = b')` via linear order trichotomy
  - This pattern already exists inline at lines 1818-1830 and 1928-1942; factor it out
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean`
  - **Verification**: `lean_verify` on order_reverse, `lake build`
- [ ] Task 4.2: Add `same_order_type_grid_uh` macro to EFGameTactics.lean (~5 lines)
  - `macro "same_order_type_grid_uh" : tactic => \`(tactic| unhygienic (intro i j; simp only [game_tuple]; split_ifs))`
  - This preserves `i` and `j` as accessible names in broadcast subgoals after `<;>`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean`
  - **Verification**: Test with lean_multi_attempt on a sample grid goal
- [ ] Task 4.3: (Optional) Create sel_dispatch helper tactic (~30-50 lines)
  - Encapsulate the common pattern: `by_cases hlt : i.val - 1 < n` followed by simp + ordering lemma application
  - If the Case II rewrite (Phase 5) eliminates most grid goals, this may be unnecessary
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean`
  - **Decision point**: Implement Task 4.3 only if Phase 5 leaves >3 grid goals requiring sel dispatch

**Anti-deviation warnings**:
- Do NOT create a full custom elaboration tactic (over-engineering for this problem)
- Do NOT modify same_order_type_grid (keep it for backward compatibility; add the _uh variant)
- Do NOT use rename_i for variable-length inaccessible lists (does not work; verified by Teammate A)

**Timing**: 2-3 hours

**Depends on**: none (parallel with Phase 3)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean` -- add ~30-80 lines

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.EFGameTactics` passes
- order_reverse compiles without sorry
- same_order_type_grid_uh preserves i, j accessibility (test with lean_multi_attempt)

---

### Phase 5: GHR93-Faithful Case II Rewrite [NOT STARTED]

**Goal**: Rewrite ghr93_case_II in CaseAnalysis.lean to follow GHR93 exactly: construct e_n from U(B,A) witness transferred through tau at rank r+4, prove sel_pn_ord trivially from monotonicity + Until witness, handle Round 2 via A's interval type property. Target: ~400-600 lines replacing the current ~1170-line Case II proof, closing grid dispatch sorries at lines 1668, 1669, 2031, 2032, 2112.

**Literature to read BEFORE implementing**:
- GHR93 Section 8, Case II (literature/Gabbay_Hodkinson_Reynolds_1993, pp.117-118)
- GHR94 Chapter 12, pp.792-810 (Case II detailed proof)
- Report 40 (GHR93 Case II step 6): ALL sections -- definitive extraction of the argument
- Report 47 (X_t usage analysis): Section 2.4 (Case II formulas), Section 3 (A formula usage in Round 2)
- Report 44 (Teammate B): Sections 2.1-2.3 (divergence analysis), 3.1 (why grid dispatch fails)
- Report 44 (Teammate C): Section 3.1 (resp_mod is artifact of non-GHR93 construction)

**The GHR93 Case II proof (from report 40, definitive extraction)**:

Setup: a_n is a point (not a gap) in N_r. Spoiler has selected a_0 < a_1 < ... < a_n in [x', y']. Selections are sorted (from ghr93_inductive_step).

Step 1. Apply tau to a_0, ..., a_{n-1} to get resp_tau(0), ..., resp_tau(n-1). tau preserves order: resp_tau(k) < resp_tau(k+1).

Step 2. Define B = x_t_formula(a_n), A = x_interval_formula(a_{n-1}, a_n). Both are StaviFormulas of depth <= r. When n=0, take a_{n-1} = d_bar (= x' side) and e_{n-1} = c (= x side).

Step 3. N_r |= U(B, A)(a_{n-1}): witness is a_n. B holds at a_n (x_t_correct). A holds on (a_{n-1}, a_n) by definition (every point's type is a disjunct of A).

Step 4. Transfer U(B, A) through tau at rank r+4. tau preserves StaviFormulas of depth <= r+4. stavi_depth(U(B,A)) = max(r, r) + 2 = r+2 <= r+4. Therefore M_r |= U(B, A)(resp_tau(n-1)).

Step 5. Extract witness: exists z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z). Set e_n = z. Use untl_extract_witness from CharacteristicFormula.lean.

Step 6. sel_pn_ord is trivial: for all k < n, resp_tau(k) <= resp_tau(n-1) < z = e_n. First inequality from tau order preservation (h_mono on selections implies h_mono on responses). Second from Until witness definition (z > resp_tau(n-1)).

Step 7. Round 2 verification (5-way case split on Spoiler's challenge b_sp):
- (a) b_sp in (resp_tau(k), resp_tau(k+1)) for k < n-1: tau's winning condition gives the response
- (b) b_sp in (resp_tau(n-1), e_n): A holds at b_sp. By x_interval_correct, b_sp has rank_type matching some v in (a_{n-1}, a_n). Respond with v. Rank-r type agreement follows.
- (c) b_sp = e_n (or rank-r equivalent): B holds at e_n. By x_t_correct, e_n and a_n agree on all rank-r formulas. Respond with a_n.
- (d) b_sp in (e_n, y): use sigma's continuation formula and tau's winning condition for the (a_n, y') sub-interval
- (e) b_sp at endpoints or outside: handled by sigma/tau boundary conditions

**What to delete from CaseAnalysis.lean** (lines ~1240-1550):
- Remove forward-game e_n construction via h_d_compat_left (lines 1257-1288)
- Remove a_pad_big, get_forward_game_result machinery
- Remove resp_mod indirection (line 1418)
- Remove sel_pn_ord proof that uses hord_left_sel_pn (lines 1430-1439)
- Remove tau_left, tau_right sub-game construction
- Keep: ghr93_case_II function signature, SplitPointProps unpacking, initial setup

**What to add** (~200-400 lines):
- B, A construction from CharacteristicFormula.lean imports (~30 lines)
- U(B,A) truth at a_{n-1} proof (~30 lines)
- tau transfer of U(B,A) (~30 lines)
- Until witness extraction, e_n definition (~20 lines)
- Trivial sel_pn_ord from monotonicity (~15 lines)
- Round 2 five-way case split (~150-250 lines)
- Grid dispatch using same_order_type_grid_uh + tactic infra from Phase 4 (~50-100 lines)

**Tasks**:
- [ ] Task 5.1: Import CharacteristicFormula.lean into CaseAnalysis.lean and construct B, A (~30-50 lines)
  - Add import statement
  - Build B = x_t_formula(M, atomMap, r, a_n) within ghr93_case_II
  - Build A = x_interval_formula(M, atomMap, r, a_{n-1}, a_n)
  - Handle n=0 boundary: when n=0, a_{n-1} = props.d_bar, e_{n-1} = props.c
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
- [ ] Task 5.2: Prove N_r |= U(B, A)(a_{n-1}) (~30-40 lines)
  - Witness is a_n: B holds at a_n (by x_t_self), A holds on (a_{n-1}, a_n) (every point's type is realized)
  - Use sf_untl_truth_mu semantics
  - **File**: CaseAnalysis.lean
- [ ] Task 5.3: Transfer U(B, A) through tau at rank r+4 (~30-50 lines)
  - tau.winning_condition gives: for StaviFormulas phi with stavi_depth phi <= r+4, truth at a_{n-1} in N iff truth at resp_tau(n-1) in M
  - stavi_depth(U(B, A)) = max(r, r) + 2 = r+2 <= r+4 (from untl_type_depth_le_r_plus_4)
  - Therefore M_r |= U(B, A)(resp_tau(n-1))
  - **File**: CaseAnalysis.lean
- [ ] Task 5.4: Extract witness z = e_n and prove sel_pn_ord (~30-50 lines)
  - Use untl_extract_witness to get z > resp_tau(n-1) with B(z) and A on (resp_tau(n-1), z)
  - Set e_n = z
  - sel_pn_ord: for k < n, resp_tau(k) <= resp_tau(n-1) < z = e_n
  - First inequality: h_mono on sorted selections implies monotone tau responses
  - Second inequality: from Until witness definition
  - **File**: CaseAnalysis.lean
- [ ] Task 5.5: Delete old e_n construction (~-300 lines net deletion)
  - Remove forward-game e_n construction (lines ~1240-1550)
  - Remove resp_mod, a_pad_big, get_forward_game_result
  - Remove old sel_pn_ord and associated ordering lemmas
  - Keep: function signature, SplitPointProps unpacking, tau/sigma setup, boundary lemmas
  - **File**: CaseAnalysis.lean
- [ ] Task 5.6: Implement Round 2 winning condition (~150-250 lines)
  - 5-way case split on b_sp (Spoiler's challenge point)
  - Case (a): b_sp in tau's sub-interval range -> tau's winning condition provides response
  - Case (b): b_sp in (resp_tau(n-1), e_n) -> A holds at b_sp -> x_interval_correct gives matching point v in (a_{n-1}, a_n) -> respond with v, rank-r type agreement
  - Case (c): b_sp at e_n -> B holds at e_n -> x_t_correct gives rank-r type agreement with a_n -> respond with a_n
  - Case (d): b_sp in (e_n, y) -> sigma's continuation handles this
  - Case (e): endpoints -> sigma/tau boundary conditions
  - **File**: CaseAnalysis.lean
- [ ] Task 5.7: Close remaining grid dispatch goals using Phase 4 infrastructure (~50-100 lines)
  - Apply same_order_type_grid_uh instead of same_order_type_grid
  - Use order_reverse for reverse-ordering goals
  - Apply sel dispatch pattern (by_cases on i.val - 1 < n) for selection-index goals
  - The GHR93 rewrite simplifies the grid because:
    - sel_pn_ord is trivial (no resp_mod case split needed)
    - All response elements come from the same game (tau + Until witness, not two different games)
    - The ordering is monotone by construction
  - **File**: CaseAnalysis.lean

**Anti-deviation warnings**:
- Do NOT construct e_n from the forward game (GHR93 does not use the forward game for e_n in Case II -- reports 40, 44-B are definitive)
- Do NOT use A = sf_top (provides no information for Round 2 case (b))
- Do NOT use nf_characterizable_by_stavi for B (use x_t_formula from Phase 2)
- Do NOT create tau_r2 or h_ih_r2 workarounds (tau is already at rank r+4 from Phase 1)
- Do NOT skip the n=0 boundary case
- Do NOT keep resp_mod -- it is an artifact of the forward-game e_n and should be deleted
- Do NOT use lean_verify for sorry checking -- always use `#print axioms` via lean_run_code

**Timing**: 6-10 hours

**Depends on**: Phase 3 (CharacteristicFormula sorries closed), Phase 4 (tactic infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II (~400-600 lines net, replacing ~1170 lines; significant deletion + new code)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add CharacteristicFormula import if not already present

**Verification**:
- All 5 grid dispatch sorries closed (lines 1668, 1669, 2031, 2032, 2112)
- `#print axioms` on ghr93_case_II shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes
- Net code reduction: target ~400-600 lines for Case II vs current ~1170 lines

---

### Phase 6: Cases III/IV Gap Handling (General Linear Orders) [NOT STARTED]

**Goal**: Implement left(B, D) and right(B, D) per GHR93 Definition 8.5 / Lemma 9, then use them to complete Cases III/IV, closing the sorry at CaseAnalysis.lean:3355. This phase targets the FULL GENERAL RESULT for arbitrary linear orders -- no vacuous discharge, no discrete-only shortcut.

**Literature to read BEFORE implementing**:
- GHR93 Definition 8.5 / GHR94 Definition 12.8.6 (left/right formulas, structural induction on A)
- GHR93 Lemma 9 / GHR94 Lemma 12.8.7 (correctness of left/right)
- GHR93 Section 8, Cases III and IV (pp.118-119)
- GHR94 Chapter 12, pp.812-850 (Cases III/IV detailed proof)
- Report 47 (X_t usage analysis): Sections 2.5-2.6 (Cases III/IV formulas), Section 4 (left/right definitions)

**The mathematical argument**:

Case III (a_n is a gap defined on the left by D of rank <= r):
1. delta_III = left_formula(B, D) where B = x_t_formula(a_n). stavi_depth(delta_III) <= max(r, r) + 2 = r+2.
2. N_r |= U(delta_III, A)(a_{n-1}): By Lemma 9, left(B,D)(t) means there exists a D-left-gap above t with B^mu true at it. a_n IS such a gap.
3. Transfer U(delta_III, A) through tau at rank r+4: stavi_depth = max(r+2, r) + 2 = r+4. EXACTLY at the ceiling.
4. Extract gap witness e_n in M via Lemma 9 correctness. e_n is a gap in M defined on the left by D with the same rank-r type as a_n.
5. Round 2: mirrors Case II structure with gap-formula-aware responses.

Case IV (a_n is a gap NOT defined on the left):
1. a_n must be definable on the right by some D of rank <= r (by GHR93's exhaustive analysis of gap types).
2. delta_IV = sf_conj(A, sf_conj(sf_neg(D), sf_untl(right_formula(B, D), A))). stavi_depth(delta_IV) must be tracked carefully -- target: stavi_depth(delta_IV) <= r+2 so that U(delta_IV, A) has stavi_depth <= r+4.
3. Transfer through tau at rank r+4: MUST verify depth fits.
4. Extract gap witness in M via right_formula correctness.
5. Round 2: similar structure to Case III.

**DEPTH ARITHMETIC WARNING**: Case IV's depth is at the absolute ceiling (r+4). Implementation MUST verify exact stavi_depth bounds at each step using lean_goal. If the stavi_depth convention (max+2 for Until) causes overflow beyond r+4, the GHR93 "rank" (max+1) vs stavi_depth (max+2) distinction must be resolved.

**Tasks**:
- [ ] Task 6.1: Create GapFormulas.lean with left_formula and right_formula (~150-200 lines)
  - Define `left_formula : StaviFormula -> StaviFormula -> StaviFormula` by structural induction on A
  - 6 cases per GHR93 Definition 8.5: atom, negation, conjunction, disjunction, Until, Since
  - Define `right_formula` as the dual (swap U/S and Until/Since)
  - Prove `left_depth_bound : stavi_depth (left_formula A D) <= max (stavi_depth A) (stavi_depth D) + 2`
  - Prove `right_depth_bound` similarly
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` (NEW)
- [ ] Task 6.2: Prove Lemma 9 correctness for left_formula (~100-150 lines)
  - `left_correct`: left(A, D)(m) iff exists gap gamma > m, gamma defined by D on the left, D on (m, gamma), A^mu(gamma)
  - By structural induction on A, matching the 6 cases of left_formula
  - Interface with ExtendedCarrier gap infrastructure (r_definable_gap_left from TypeFormulas.lean)
  - **File**: GapFormulas.lean
- [ ] Task 6.3: Prove Lemma 9 correctness for right_formula (~100-150 lines)
  - `right_correct`: dual of left_correct
  - **File**: GapFormulas.lean
- [ ] Task 6.4: Complete Case III implementation in CaseAnalysis.lean (~100-150 lines)
  - Build delta_III = left_formula(x_t_formula(a_n), D)
  - Show U(delta_III, A) holds at a_{n-1} in N
  - Transfer through tau at rank r+4 (depth verification: r+2+2 = r+4, EXACTLY at ceiling)
  - Extract gap witness e_n in M via Lemma 9
  - Round 2 verification (mirrors Phase 5 Case II pattern)
  - Use same_order_type_grid_uh + order_reverse from Phase 4
  - **File**: CaseAnalysis.lean
- [ ] Task 6.5: Complete Case IV implementation in CaseAnalysis.lean (~100-150 lines)
  - Build delta_IV compound formula
  - Verify stavi_depth(delta_IV) and stavi_depth(U(delta_IV, A)) -- MUST be <= r+4
  - Transfer through tau at rank r+4
  - Extract gap witness e_n in M via right_formula correctness
  - Round 2 verification
  - **File**: CaseAnalysis.lean
- [ ] Task 6.6: Close winning condition assembly sorry at CaseAnalysis.lean:3355 (~50-100 lines)
  - Integrate Cases III/IV into the overall winning condition structure
  - This sorry covers ordering + gap/point agreement + formula agreement
  - Use the same grid dispatch pattern from Phase 5.7
  - **File**: CaseAnalysis.lean

**Anti-deviation warnings**:
- Do NOT simplify Cases III/IV for discrete orders -- the plan targets GENERAL linear orders per user directive
- Do NOT use vacuous discharge -- Cases III/IV MUST have real proofs
- Do NOT skip Lemma 9 correctness (it bridges gap formulas to gap-existence statements)
- Do NOT assume stavi_depth(left(A,D)) = GHR93_rank(left(A,D)) -- track the +2 vs +1 distinction
- Do NOT attempt Cases III/IV without Phase 3's existence sorries being closed

**Timing**: 5-8 hours

**Depends on**: Phase 3 (CharacteristicFormula), Phase 4 (tactic infrastructure)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` -- NEW (~350-500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add import
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- update ghr93_cases_III_IV (~200-350 lines)

**Verification**:
- Sorry at CaseAnalysis.lean:3355 closed
- `#print axioms` on left_formula, right_formula, left_correct, right_correct shows no sorryAx (via lean_run_code)
- `#print axioms` on ghr93_cases_III_IV shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes

---

### Phase 7: Transfer.lean Rewiring and Downstream Sorry Closure [NOT STARTED]

**Goal**: Wire Transfer.lean to use the game-theoretic pipeline (Theorem6 + CaseAnalysis) instead of the chronicle fallback (dd_countermodel_chronicle_discrete). This is the step that actually activates the Reynolds pipeline and eliminates succ_cofinal from the bx_completeness axiom chain. Also close any remaining mechanical sorries exposed by Phases 5-6.

**Literature to read BEFORE implementing**:
- Report 44 (Teammate C): Section 5.1 (Transfer.lean rewiring scope), Section 5.4 (underspecified)
- Report 44 (Teammate D): Section 3 (two paths to sorry-free completeness), Section 5 (impact assessment)
- Transfer.lean source (current delegation at line 489)
- Completeness.lean source (what countermodel_discrete_enriched expects)

**Current architecture** (what must change):
```
completeness_discrete (Completeness.lean:308)
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> dd_countermodel_chronicle_discrete  -- CHRONICLE PIPELINE (has succ_cofinal sorry)
```

**Target architecture** (after rewiring):
```
completeness_discrete (Completeness.lean:308)
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> reynolds_countermodel_discrete  -- GAME PIPELINE (sorry-free after Phases 5-6)
         -> ghr93_forward_to_backward (Theorem6.lean) -- sorry-free (Phase 1)
         -> ghr93_inductive_step (CaseAnalysis.lean) -- sorry-free (Phases 5-6)
```

**Tasks**:
- [ ] Task 7.1: Analyze type-signature compatibility (~1-2 hours, no code changes)
  - Compare: what does dd_countermodel_chronicle_discrete return?
  - Compare: what does countermodel_discrete_enriched expect?
  - Compare: what does the game pipeline (ghr93_forward_to_backward) produce?
  - Identify any type mismatches that need adapter code
  - Key question: does the game pipeline produce a countermodel in the same form (TaskFrame + valuation), or does it need conversion?
  - **File**: Read-only analysis of Transfer.lean, Completeness.lean, Theorem6.lean
- [ ] Task 7.2: Add game pipeline imports to Transfer.lean (~5 lines)
  - Import Expressiveness.Theorem6, Expressiveness.CaseAnalysis, EFGames.CharacteristicFormula
  - Verify no circular import issues
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean`
- [ ] Task 7.3: Implement reynolds_countermodel_discrete (~50-150 lines)
  - Build the countermodel from the game pipeline output
  - If type-signature compatible: direct delegation to ghr93_forward_to_backward + transfer
  - If adapter needed: build adapter layer converting game pipeline output to expected TaskFrame
  - Handle the boundary: game pipeline works on ExtendedCarrier, Completeness expects IntegerModel
  - **File**: Transfer.lean
- [ ] Task 7.4: Rewire countermodel_discrete to use game pipeline (~20-30 lines)
  - Replace dd_countermodel_chronicle_discrete delegation with reynolds_countermodel_discrete
  - Keep the chronicle pipeline as a commented-out alternative for reference
  - **File**: Transfer.lean
- [ ] Task 7.5: Thread h_surj if needed (~30-60 lines)
  - If Phase 3's X_t construction requires h_surj (surjectivity of atomMap), thread it through ghr93_inductive_step -> ghr93_forward_to_backward -> Transfer.lean
  - If Phase 3 uses Classical.choice without h_surj, this task is unnecessary
  - **File**: Transfer.lean, possibly Theorem6.lean and CaseAnalysis.lean
- [ ] Task 7.6: Close any remaining mechanical sorries (~30-50 lines)
  - Grid dispatch residuals not covered by Phase 5.7
  - DConsistencyTransport.lean rank adjustments if needed
  - GapDetection.lean wiring for Cases III/IV
  - **File**: Various WeakCanonical/ files as needed

**Anti-deviation warnings**:
- Do NOT modify Completeness.lean unless absolutely necessary (prefer adapter in Transfer.lean)
- Do NOT close ChronicleToCountermodel.lean sorries (succ_cofinal chain) -- the Reynolds pipeline BYPASSES these, it does not fix them
- Do NOT close GoodStructures.lean:842 (no_gaps_discrete) -- it depends on bridge lemma, not on critical path
- Do NOT bypass Transfer.lean by modifying Completeness.lean directly
- Do NOT introduce new sorries anywhere
- Always verify with `#print axioms` via lean_run_code

**Timing**: 3-5 hours

**Depends on**: Phase 5 (Case II sorry-free), Phase 6 (Cases III/IV sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` -- rewiring (~100-200 lines)
- Possibly: `DConsistencyTransport.lean`, `GapDetection.lean` (mechanical adjustments)

**Verification**:
- Transfer.lean compiles without sorry on the critical path
- `#print axioms` on countermodel_discrete shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical` passes

---

### Phase 8: Final Verification (Sorry-Free bx_completeness) [NOT STARTED]

**Goal**: Full project build, axiom audit, and verification that bx_completeness has zero sorryAx. This is the definition-of-done for task 155.

**Tasks**:
- [ ] Task 8.1: Full lake build
  - `lake build` must pass with zero errors
  - If errors appear, trace and fix
- [ ] Task 8.2: Axiom audit on bx_completeness and completeness_discrete
  - Run via lean_run_code (NOT lean_verify):
    ```
    #print axioms Bimodal.Metalogic.BXCanonical.bx_completeness
    #print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete
    #print axioms Bimodal.Metalogic.BXCanonical.completeness
    ```
  - ALL must show NO sorryAx
  - If sorryAx appears, trace the dependency chain to identify the source
- [ ] Task 8.3: Sorry audit on critical path files
  - `grep -n sorry` on: Theorem6.lean, CaseAnalysis.lean, CharacteristicFormula.lean, GapFormulas.lean, Transfer.lean
  - All sorries must be in non-critical-path code or documented as deferred
  - Critical path files must have ZERO sorry
- [ ] Task 8.4: Document remaining sorries in WeakCanonical/ tree
  - List any sorries that remain with categorization:
    - Critical-path: MUST be zero
    - Non-critical (TruthLemma, StaviCompleteness bridge): documented, deferred
    - Bypassed (ChronicleToCountermodel succ_cofinal): bypassed by Reynolds pipeline
  - Update sorry audit comments in source files if needed

**Timing**: 1-2 hours

**Depends on**: Phase 7

**Files to modify**: None (read-only verification), unless sorries are found

**Verification**:
- `lake build` passes
- `#print axioms bx_completeness` shows no sorryAx
- `#print axioms completeness_discrete` shows no sorryAx
- `#print axioms completeness` shows no sorryAx
- `grep -rn sorry` on critical-path files reports zero hits

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `#print axioms` (via lean_run_code, NOT lean_verify) on all key theorems after each phase
- [ ] Phase 3: CharacteristicFormula.lean zero sorry
- [ ] Phase 4: EFGameTactics.lean compiles, order_reverse and same_order_type_grid_uh work
- [ ] Phase 5: ghr93_case_II zero sorryAx, net code reduction
- [ ] Phase 6: ghr93_cases_III_IV zero sorryAx, gap formula proofs complete (not vacuous)
- [ ] Phase 7: countermodel_discrete zero sorryAx
- [ ] Phase 8: bx_completeness zero sorryAx, completeness_discrete zero sorryAx

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/44_research-aligned-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (modified, Phase 3)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean` (modified, Phase 4)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` (NEW, Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (rewritten, Phases 5-6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` (rewired, Phase 7)

## Rollback/Contingency

**If Phase 3 (existence sorries) proves infeasible**:
- Fall back to plan v42's approach: use nf_characterizable_by_stavi with sorry propagation
- Import StaviCompleteness.lean into CaseAnalysis.lean
- Accept that bx_completeness will temporarily have sorryAx from the bridge lemma
- Create a separate high-priority task to close the bridge lemma

**If Phase 5 (Case II rewrite) is harder than expected**:
- The tactic infrastructure from Phase 4 (unhygienic intro, order_reverse) can be applied to the EXISTING proof structure to close the 5 grid dispatch sorries WITHOUT the full rewrite
- This is the "patch instead of rewrite" fallback: ~150-200 lines of tactic fixes vs ~400-600 line rewrite
- The architectural simplification is deferred but the sorries get closed

**If Phase 6 (Cases III/IV) exceeds 2x time estimate**:
- Close Case II first (Phase 5), achieving sorry-free CaseAnalysis for discrete orders (no gaps on Z)
- Wire Transfer.lean for discrete case only (Phase 7)
- Verify sorry-free completeness_discrete (Cases III/IV vacuous on Z)
- Defer full general linear order support to a follow-up task
- NOTE: This contradicts the user directive for full general result. Only use as emergency fallback with user approval.

**If Phase 7 (Transfer.lean rewiring) has type-signature incompatibilities**:
- Build adapter layer (~50-100 lines) converting game pipeline output to expected form
- If adapter is infeasible, create a parallel entry point in Completeness.lean that uses the game pipeline directly

**If any phase exceeds 2x time estimate**:
- Write handoff document with current state, blockers, and recommended next steps
- Mark phase as [PARTIAL] and return for user review

**Git safety**: All changes are on existing files in the WeakCanonical/ tree plus one new file (GapFormulas.lean). No destructive operations. Rollback via `git checkout` on individual files.
