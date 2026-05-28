# Implementation Plan: Research-Aligned Reynolds Pipeline Completion (v45)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IMPLEMENTING]
- **Effort**: 24-38 hours
- **Dependencies**: Tasks 154 (COMPLETED), 168 (COMPLETED), 174 (COMPLETED), 199 (PARTIAL)
- **Research Inputs**: reports/44_team-research.md, reports/44_teammate-a-findings.md, reports/44_teammate-b-findings.md, reports/44_teammate-c-findings.md, reports/44_teammate-d-findings.md, reports/47_xt-complete-usage-analysis.md, reports/47_lean-infrastructure-inventory.md, reports/47_plan-v42-deep-review.md, reports/46_strategic-pivot-report.md, reports/45_semantic-vs-syntactic-B.md, reports/45_ghr93-rewrite-research.md, reports/44_literature-interval-splitting.md, reports/42_plan-literature-alignment.md, reports/40_ghr93-case-ii-step6.md, reports/39_game-depth-restructuring.md
- **Artifacts**: plans/45_research-aligned-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v45 revises plan v44 to reopen Phase 5 for the GHR93-faithful structural rewrite of ghr93_case_II. Plan v44 marked Phase 5 [COMPLETED] based on Task 5.7 (brute-force grid dispatch closure), but Tasks 5.1-5.6 (the actual GHR93 rewrite) were skipped. Task 5.7 added ~740 lines on top of the existing ~1170-line proof -- the opposite of the architectural simplification that GHR93 demands.

Report 45 (ghr93-rewrite-research) provides the concrete implementation specification: a precise deletion map (lines 1257-1439 forward-game e_n + resp_mod, lines 1450-2302 Round 2), a construction map with exact Lean type signatures from CharacteristicFormula.lean, depth budget analysis confirming U(B,A) transfer is viable (depth r+2, delta >= 2), and risk analysis (Until witness containment, n=0 boundary). This plan integrates those findings into Tasks 5.1-5.6 with concrete line references, identifiers, and mitigations.

Key corrections from plan v44:

- **Phase 5 reopened**: Status changed from [COMPLETED] to [IN PROGRESS]. Tasks 5.1-5.6 are the planned GHR93 rewrite; only Task 5.7 (grid dispatch patch) was executed.
- **Tasks 5.1-5.6 updated**: Each task now has exact line ranges, Lean type signatures, CharacteristicFormula.lean identifiers, and risk mitigations drawn from report 45.
- **Task 5.7 preserved**: The same_order_type_of_cases helper survives the rewrite but its ~660-line prerequisite construction per case shrinks dramatically once resp_mod is eliminated.
- **n=0 boundary handling**: Added as explicit sub-task (Task 5.1b) based on report 45 Section 3.4.
- **Until witness containment risk**: Documented with three mitigation strategies (report 45 Section 8.1).

### Research Integration

All team research reports from round 44, plus report 45, are integrated. New findings driving this revision:

- **Report 45 (GHR93 rewrite research)**: Precise deletion map (lines 1257-2302), construction map with CharacteristicFormula.lean identifiers, depth budget confirmation (U(B,A) depth r+2 <= r+delta), n=0 boundary analysis, Until witness containment risk with three mitigation paths. Task 5.7's same_order_type_of_cases helper survives but prerequisites simplify dramatically.

### Prior Plan Reference

Plan v44 correctly structured the 8-phase pipeline but prematurely marked Phase 5 [COMPLETED] when only Task 5.7 (brute-force grid dispatch) was executed. The GHR93 rewrite (Tasks 5.1-5.6) remains the primary goal for architectural quality: replacing ~1170 lines with ~400-600 lines of GHR93-faithful proof. This plan reopens Phase 5 and updates task specifications with report 45 findings.

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
| Until witness containment: untl_extract_witness may produce z outside [x, y] | H | M | Three mitigations from report 45 Section 8.1: (1) use forward game h_fwd_n1 for existence + U(B,A) for formula properties (hybrid approach); (2) prove structural containment argument from tau mapping [d,y'] to [c,y]; (3) worst case: retain forward-game e_n for existence, use U(B,A) only for formula transfer. |
| n=0 boundary: ref_N = d may equal a_bwd(n), breaking U(B,A) witness | M | M | Explicit case split at top of proof (Task 5.1b). When d = a_bwd(n), all selections collapse to d = p_n; respond with all c and e_n = c (trivial proof). |
| GHR93 Case II rewrite: type-level incompatibilities with existing SplitPointProps | M | M | SplitPointProps already supports delta parameter and provides tau/sigma at rank r+delta on rank-embedded positions. The rewrite changes the e_n construction, not the SplitPointProps interface. If interface changes are needed, modify SplitPointProps signatures incrementally. |
| left(B,D)/right(B,D) depth arithmetic for Case IV at ceiling r+4 | M | M | GHR94 p.839 confirms rank(U(delta_IV, A)) = r+4. Track stavi_depth vs GHR93 "rank" distinction carefully (stavi_depth uses +2 for temporal, GHR93 rank uses +1). Verify depth bounds at each step with lean_goal. |
| Transfer.lean rewiring: type-signature incompatibility between game pipeline output and what Completeness.lean expects | M | H | Phase 7 includes explicit type-signature analysis. If incompatible, build an adapter layer (~50-100 lines) that converts game pipeline output to the expected type. |
| unhygienic intro causes unexpected behavior in future Lean versions | L | L | unhygienic is a documented Lean 4 feature. The alternative (manual rcases creating named goals, ~300 lines per grid) is available as fallback. |
| Net code increase instead of reduction after Case II rewrite | L | L | Target: delete ~1045 lines (forward-game e_n, resp_mod, Round 2 dispatch at lines 1257-2302), add ~350-500 lines (U(B,A) construction + simplified Round 2). Track net line count during implementation. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (already COMPLETED) |
| 1 | 3, 4 | -- (already COMPLETED) |
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

**Timing**: 3-5 hours (actual: completed)

**Depends on**: none (Phase 2 completed, this closes its remaining sorries)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` -- close 2 sorries (~190-300 new lines)

**Verification**:
- `#print axioms` on x_t_formula shows no sorryAx
- `#print axioms` on x_interval_formula shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` passes with zero sorry

---

### Phase 4: Tactic Infrastructure (Grid Dispatch Prerequisites) [COMPLETED]

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
- [x] Task 4.1: Add `order_reverse` theorem to EFGameTactics.lean (~25 lines)
  - Derives `(b < a iff b' < a') AND (b = a iff b' = a')` from `(a < b iff a' < b') AND (a = b iff a' = b')` via linear order trichotomy
  - This pattern already exists inline at lines 1818-1830 and 1928-1942; factor it out
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean`
  - **Verification**: `lean_verify` on order_reverse, `lake build`
- [x] Task 4.2: Add `same_order_type_grid_uh` macro to EFGameTactics.lean (~5 lines)
  - `macro "same_order_type_grid_uh" : tactic => \`(tactic| unhygienic (intro i j; simp only [game_tuple]; split_ifs))`
  - This preserves `i` and `j` as accessible names in broadcast subgoals after `<;>`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean`
  - **Verification**: Test with lean_multi_attempt on a sample grid goal
- [ ] Task 4.3: (Optional) Create sel_dispatch helper tactic (~30-50 lines) *(deviation: deferred -- will implement only if Phase 5 leaves >3 grid goals requiring sel dispatch, as noted in the plan)*
  - Encapsulate the common pattern: `by_cases hlt : i.val - 1 < n` followed by simp + ordering lemma application
  - If the Case II rewrite (Phase 5) eliminates most grid goals, this may be unnecessary
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean`
  - **Decision point**: Implement Task 4.3 only if Phase 5 leaves >3 grid goals requiring sel dispatch

**Anti-deviation warnings**:
- Do NOT create a full custom elaboration tactic (over-engineering for this problem)
- Do NOT modify same_order_type_grid (keep it for backward compatibility; add the _uh variant)
- Do NOT use rename_i for variable-length inaccessible lists (does not work; verified by Teammate A)

**Timing**: 2-3 hours (actual: completed)

**Depends on**: none (parallel with Phase 3)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean` -- add ~30-80 lines

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.EFGameTactics` passes
- order_reverse compiles without sorry
- same_order_type_grid_uh preserves i, j accessibility (test with lean_multi_attempt)

---

### Phase 5: GHR93-Faithful Case II Rewrite [IN PROGRESS]

**Status**: Task 5.7 (grid dispatch patch) completed; Tasks 5.1-5.6 (GHR93 rewrite) not yet attempted. This phase is reopened to complete the architectural rewrite.

**Task 5.7 context** (completed work that will be partially superseded):
Task 5.7 created `same_order_type_of_cases` helper in EFGameTactics.lean (line 231) and applied it at 3 grid dispatch sites (Case A line 1640, Case B1 line 1986, Case B2 line 2232). Each usage constructs ~220 lines of prerequisite ordering lemmas via `by_cases hk : k.val < n` splits. Total: ~740 lines added on top of the existing ~1170-line proof. The helper theorem itself survives the rewrite, but the prerequisite construction at each call site will be dramatically simplified once resp_mod is eliminated.

**Goal**: Rewrite ghr93_case_II in CaseAnalysis.lean to follow GHR93 exactly: construct e_n from U(B,A) witness transferred through tau at rank r+delta, prove sel_pn_ord trivially from monotonicity + Until witness, handle Round 2 via A's interval type property. Target: ~400-600 lines replacing the current ~1910-line Case II proof (original ~1170 + Task 5.7's ~740), closing grid dispatch sorries and achieving a net reduction of ~1300-1500 lines.

**Literature to read BEFORE implementing**:
- GHR93 Section 8, Case II (literature/Gabbay_Hodkinson_Reynolds_1993, pp.117-118)
- GHR94 Chapter 12, pp.792-810 (Case II detailed proof)
- Report 45 (GHR93 rewrite research): ALL sections -- definitive deletion/construction map
- Report 40 (GHR93 Case II step 6): ALL sections -- definitive extraction of the argument
- Report 47 (X_t usage analysis): Section 2.4 (Case II formulas), Section 3 (A formula usage in Round 2)
- Report 44 (Teammate B): Sections 2.1-2.3 (divergence analysis), 3.1 (why grid dispatch fails)
- Report 44 (Teammate C): Section 3.1 (resp_mod is artifact of non-GHR93 construction)

**CharacteristicFormula.lean identifiers to use** (all sorry-free, from report 45 Section 2.1):
- `x_t_formula N atomMap r t` : `StaviFormula` -- characteristic formula for rank_type of t
- `x_t_depth` : `stavi_depth (x_t_formula ...) <= r`
- `x_t_correct u` : truth at u iff rank_type u = rank_type t
- `x_t_self` : x_t_formula holds at t itself
- `x_t_implies_agreement` : given X_t holds at u, agreement on all depth-r formulas
- `x_interval_formula N atomMap r t u` : `StaviFormula` -- interval type formula
- `x_interval_depth` : `stavi_depth (x_interval_formula ...) <= r`
- `x_interval_correct w` : truth at w iff exists v with matching rank_type in (t, u)
- `x_interval_self` : interval formula holds for any mu-point in the interval
- `sf_untl B A` : Until formula constructor, `stavi_depth = max(depth B)(depth A) + 2`
- `untl_extract_witness h` : extracts witness from Until truth proof
- `untl_type_holds_at_witness` : given mu_holds t, s < t, proves U(X_t, X_{(s,t)})(s)
- `untl_type_depth` : `stavi_depth(U(X_t, X_{(s,t)})) <= r + 2`
- `formula_transfer_rank_embed` : bridges rank-r and rank-r' truth via rank_embed

**Depth budget** (from report 45 Section 2.2):
- B = x_t_formula: depth <= r
- A = x_interval_formula: depth <= r
- U(B, A) = sf_untl B A: depth = max(r, r) + 2 = r + 2
- tau at rank r+delta (delta >= 2 from hd): formula agreement covers depth <= r+delta >= r+2
- CONCLUSION: U(B,A) is transferable through tau. The existing infrastructure suffices.

**Deletion map** (from report 45 Section 4):
- Lines 1257-1288: Forward-game e_n construction (a_pad_big, h_d_compat_left call) -- REPLACE with U(B,A) witness
- Lines 1289-1345: Forward-game extraction (hform_en_an, hord_cd_en_pn) -- REPLACE with U(B,A) properties
- Lines 1346-1357: p_cy hoisting, tau formula data -- partially reusable
- Lines 1358-1378: tau_left, tau_right via IH -- ELIMINATE (no sub-interval decomposition needed)
- Lines 1380-1391: hpivot_form, hpivot_gp -- ELIMINATE (pivot between p_n/e_n no longer needed)
- Lines 1392-1414: resp_left play, hord_left_sel_pn extraction -- ELIMINATE (use tau_r directly)
- Lines 1415-1439: resp_mod, sel_pn_ord old proof -- ELIMINATE (artifact of forward-game approach)
- Lines 1440-1449: a'_resp definition -- KEEP but simplify (use resp_tau directly, not resp_mod)
- Lines 1450-2302: Round 2 dispatch -- REWRITE with simpler structure

**Construction map** (from report 45 Section 5):
- Step 3-NEW: Construct B, A, prove U(B,A)(ref) in N (~40 lines)
- Step 4-NEW: Transfer U(B,A) through tau at r+delta (~50 lines)
- Step 5-NEW: Extract witness z = e_n, prove properties (~30 lines)
- Step 6-NEW: Build a'_resp and prove interval containment (~20 lines)
- Step 7-NEW: Endpoint data from forward game h_fwd_n1 (~60 lines)
- Step 8-NEW: Round 2 winning condition dispatch (~200-300 lines)

**Tasks**:
- [ ] Task 5.1: Import CharacteristicFormula.lean and construct B, A (~30-50 lines)
  - Add `import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` at line 1
  - After step 1 (line 1247, extracting p_n and defining a_init), add:
    - Define `ref_N : ExtendedCarrier N atomMap r` as `a_bwd (n-1, ...)` when n > 0, or `d` when n = 0
    - Prove `h_ref_N_lt_an : ref_N < a_bwd (n, ...)` -- requires case analysis for degenerate case
    - Define `B := x_t_formula N atomMap r (a_bwd (n, by omega))`
    - Define `A := x_interval_formula N atomMap r ref_N (a_bwd (n, by omega))`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
  - **Insert after**: line 1247 (before current line 1248)

- [ ] Task 5.1b: Handle n=0 boundary and degenerate case d = a_bwd(n) (~20-30 lines)
  - Case split at top of proof body: `if h_degen : d = a_bwd (n, ...)` then all selections equal d = p_n (by h_no_split + h_mono)
  - In degenerate case: respond with all c and e_n = c. Proof is trivial (no U(B,A) needed)
  - In non-degenerate case: proceed with main GHR93 construction (d < a_bwd(n) strict)
  - When n = 0 in non-degenerate case: ref_N = d, need d < a_bwd(0) which follows from h_no_split + h_degen negation
  - **File**: CaseAnalysis.lean
  - **Risk**: Per report 45 Section 3.4, when d = p_n and n=0, U(B,A)(d) fails because the witness z > d = p_n would need p_n > p_n. The degenerate case split eliminates this.

- [ ] Task 5.2: Prove N_r |= U(B, A)(ref_N) (~10-20 lines)
  - Apply `untl_type_holds_at_witness` with witness `a_bwd (n, by omega)` = `extendPoint p_n`
  - Need: `mu_holds (a_bwd (n, by omega))` -- from h_point (a_n is a point, hence mu_holds)
  - Need: `ref_N < a_bwd (n, by omega)` -- from h_ref_N_lt_an (Task 5.1), guaranteed by degenerate case elimination (Task 5.1b)
  - **Concrete signature**: `have h_untl_N : stavi_temporal_truth_mu N atomMap r ref_N (sf_untl B A)`
  - **File**: CaseAnalysis.lean
  - **Insert after**: Task 5.1 additions

- [ ] Task 5.3: Transfer U(B, A) through tau at rank r+delta (~40-60 lines)
  - Keep `tau_r := ghr93_duplicator_wins_rank_down ... props.tau` (line 1252-1254) for resp_tau ordering
  - Play `tau_r` with `a_init` to get `resp_tau` (current line 1255, keep)
  - Define `ref_M : ExtendedCarrier M atomMap r` as `resp_tau (n-1, ...)` when n > 0, or `c` when n = 0
  - For U(B,A) transfer, use `props.tau` at full rank r+delta (NOT tau_r which loses depth budget):
    - Build `a_init_emb : Fin n -> ExtendedCarrier N atomMap (r + delta)` via `rank_embed (by omega : r <= r + delta)`
    - Play `props.tau` with `a_init_emb` to get rank-embedded responses
    - Extract formula agreement at the ref_N/ref_M positions at depth <= r+delta
    - Since `stavi_depth(sf_untl B A) <= r + 2 <= r + delta` (from hd), the transfer works
    - Use `formula_transfer_rank_embed` from CharacteristicFormula.lean to bridge between rank r and rank r+delta
  - Conclude: `have h_untl_M : stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A)`
  - **File**: CaseAnalysis.lean
  - **Key detail**: Must play tau TWICE -- once at rank r (tau_r, for resp_tau ordering) and once at rank r+delta (props.tau, for formula transfer of U(B,A)). Or do everything at rank r+delta and use rank_embed_stavi_truth_mu at the end (cleaner, per report 45 Section 3.3).

- [ ] Task 5.4: Extract witness z = e_n and prove sel_pn_ord (~30-50 lines)
  - Apply `untl_extract_witness` to `h_untl_M` to get `z > ref_M`, `mu_holds z`, `B(z)`, `A on (ref_M, z)`
  - Set `e_n := z` (or `e_n := extendPoint e_n_pt` from mu_holds decomposition)
  - Prove `hform_en_an`: e_n and a_n agree on all rank-r StaviFormulas (from `B(z)` + `x_t_correct`)
  - Prove `sel_pn_ord` (TRIVIAL): for all k < n, `resp_tau k < e_n`
    - Chain: `resp_tau k <= resp_tau(n-1) = ref_M < z = e_n`
    - First inequality: from tau ordering (h_mono on a_init implies resp_tau preserves order, via tau's same_order_type)
    - Second inequality: from Until witness (`z > ref_M`)
  - Prove `he_n_in : inClosedInterval x y e_n` -- requires containment argument (see Until witness containment risk)
  - **File**: CaseAnalysis.lean
  - **Risk**: Until witness z may not be in [x, y]. See Risks & Mitigations. Three paths: (1) structural argument that tau maps [d,y'] to [c,y] so witness must be in range; (2) hybrid approach using forward game for existence; (3) prove first-witness-in-range lemma. Investigate during implementation.

- [ ] Task 5.5: Delete old e_n construction and resp_mod, replace with new code (~-550 to -700 lines net)
  - Delete lines 1257-1288 (a_pad_big, h_d_compat_left call, forward-game e_n)
  - Delete lines 1289-1345 (forward game extraction: hform_en_an, hord_cd_en_pn, etc.)
  - Delete lines 1346-1391 (p_cy hoisting, tau_left, tau_right, pivot data)
  - Delete lines 1392-1439 (resp_left play, resp_mod, sel_pn_ord old proof)
  - Insert new code from Tasks 5.1-5.4 as replacement
  - Simplify a'_resp definition (lines 1440-1449): use resp_tau directly instead of resp_mod
    - New: `let a'_resp : Fin (n + 1) -> ExtendedCarrier M atomMap r := fun i => if h : i.val < n then resp_tau (i.val, h) else e_n`
  - **File**: CaseAnalysis.lean
  - **Net deletion**: ~183 lines of pure deletion (lines 1257-1439) minus ~130-180 lines of new insertions from Tasks 5.1-5.4
  - **Dependencies**: Tasks 5.1-5.4 must be ready as replacements before deleting

- [ ] Task 5.6: Rewrite Round 2 winning condition dispatch (~200-300 lines, replacing ~850 lines)
  - Rewrite lines 1450-2302 (Case A, Case B1, Case B2) with simplified ordering:
  - **Case A (b_sp <= c)**: Use sigma for Round 2 response. Same structure but with resp_tau instead of resp_mod. No resp_mod case splits needed.
  - **Case B (b_sp > c)**: Split on b_sp vs e_n:
    - **B1 (b_sp <= e_n)**: Play tau_r's Round 2 with b_sp. All orderings from tau's winning condition + sel_pn_ord (trivial). No resp_mod case splits needed. For the interval case (ref_M < b_sp < e_n): A holds at b_sp (from h_A_interval). By x_interval_correct, b_sp's rank type matches some mu-point v in (ref_N, a_n). Respond with v.
    - **B2 (b_sp > e_n)**: Use forward game or tau continuation for response. Orderings trivial because resp_tau(k) < e_n < b_sp.
  - For each sub-case, construct prerequisites for `same_order_type_of_cases`:
    - `hord_sel_sel`: from tau ordering (no resp_mod case splits)
    - `hord_x_sel`, `hord_b_sel`, `hord_y_sel`: via pivot_chain_order through d/c
    - The `by_cases hk : k.val < n` splits remain but are simpler (k < n: resp_tau; k = n: e_n; no heq_k / hne_k resp_mod sub-splits)
  - **File**: CaseAnalysis.lean
  - **Key simplification**: Eliminating resp_mod removes the deepest nesting layer from every ordering proof. The ~220-line prerequisite construction per same_order_type_of_cases call shrinks to ~100-120 lines.

- [x] Task 5.7: Close remaining grid dispatch goals using Phase 4 infrastructure (~740 lines, completed)
  - Created `same_order_type_of_cases` helper theorem in EFGameTactics.lean (line 231) that handles the full 16-cell grid dispatch internally
  - Applied it at all 3 grid dispatch sites (Case A, B1, B2) by constructing full sel-index ordering lemmas with by_cases on k.val < n
  - **Status**: Completed. The helper theorem survives the GHR93 rewrite; the ~660 lines of prerequisite construction per case will be dramatically simplified when resp_mod is eliminated (Tasks 5.5-5.6). The helper call sites at lines 1640, 1986, 2232 will be rewritten with simpler prerequisites as part of Task 5.6.

**Anti-deviation warnings**:
- Do NOT construct e_n from the forward game (GHR93 does not use the forward game for e_n in Case II -- reports 40, 44-B, 45 are definitive)
- Do NOT use A = sf_top (provides no information for Round 2 case (b))
- Do NOT use nf_characterizable_by_stavi for B (use x_t_formula from Phase 2)
- Do NOT create tau_r2 or h_ih_r2 workarounds (tau is already at rank r+4 from Phase 1)
- Do NOT skip the n=0 boundary case (Task 5.1b) -- report 45 Section 3.4 shows U(B,A) fails when d = p_n
- Do NOT keep resp_mod -- it is an artifact of the forward-game e_n and should be deleted
- Do NOT use lean_verify for sorry checking -- always use `#print axioms` via lean_run_code
- Do NOT use `same_order_type_grid_uh` via `<;>` for grid dispatch (unhygienic does not propagate; use manual expansion instead)
- Do NOT use `rename_i` inside `first` fallback chains (hard error on count mismatch, not tactic failure)
- Do NOT touch the Cases III/IV sorry at line 3477 -- it belongs to Phase 6

**Timing**: 8-12 hours (revised upward from v44's 6-10 hours to account for Until witness containment risk and n=0 boundary handling)

**Depends on**: Phase 3 (CharacteristicFormula sorries closed), Phase 4 (tactic infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II (~400-600 lines net, replacing current ~1910 lines; massive deletion + new code)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add CharacteristicFormula import if not already present

**Verification**:
- All grid dispatch sorries closed
- `#print axioms` on ghr93_case_II shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes
- Net code reduction: target ~400-600 lines for Case II vs current ~1910 lines

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
  - Use same_order_type_of_cases + order_reverse from Phase 4
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
  - Use the same grid dispatch pattern from Phase 5
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
- [ ] Phase 5: ghr93_case_II zero sorryAx, net code reduction (~400-600 lines from ~1910 lines)
- [ ] Phase 6: ghr93_cases_III_IV zero sorryAx, gap formula proofs complete (not vacuous)
- [ ] Phase 7: countermodel_discrete zero sorryAx
- [ ] Phase 8: bx_completeness zero sorryAx, completeness_discrete zero sorryAx

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/45_research-aligned-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (modified, Phase 3)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean` (modified, Phase 4)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` (NEW, Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (rewritten, Phases 5-6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` (rewired, Phase 7)

## Rollback/Contingency

**If Until witness containment (Task 5.4) proves infeasible**:
- Use hybrid approach: retain forward-game e_n from h_fwd_n1 for EXISTENCE and interval containment, but use U(B,A) for FORMULA PROPERTIES (x_t_correct, x_interval_correct). This still eliminates resp_mod and simplifies ordering proofs dramatically, even if e_n itself comes from the forward game rather than the Until witness.
- Estimated impact: ~50 additional lines vs pure GHR93 approach, but still achieves the architectural simplification goal.

**If Phase 3 (existence sorries) proves infeasible**:
- Fall back to plan v42's approach: use nf_characterizable_by_stavi with sorry propagation
- Import StaviCompleteness.lean into CaseAnalysis.lean
- Accept that bx_completeness will temporarily have sorryAx from the bridge lemma
- Create a separate high-priority task to close the bridge lemma

**If Phase 5 (Case II rewrite) is harder than expected**:
- The tactic infrastructure from Phase 4 (unhygienic intro, order_reverse) and the same_order_type_of_cases helper from Task 5.7 can be applied to the EXISTING proof structure to close the 5 grid dispatch sorries WITHOUT the full rewrite
- This is the "patch instead of rewrite" fallback -- already proven viable by Task 5.7
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
