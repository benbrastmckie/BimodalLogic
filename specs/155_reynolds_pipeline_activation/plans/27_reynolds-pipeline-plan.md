# Implementation Plan: Reynolds Pipeline Activation (v25)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 15-30 hours remaining (11 of 19 sorries closed)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/22 (GHR93 Claim 1), reports/36 (root cause), reports/38 (case-split), reports/39 (circularity confirmed)
- **Artifacts**: plans/27_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: FOLLOW GHR93 EXACTLY — NO DEVIATIONS

Every deviation from GHR93 has produced weeks of wasted effort. If an implementation creates edge cases absent from GHR93, the approach is wrong. Encode formulas as formulas. No predicate workarounds. Every proof step must trace to a specific page/line in GHR93 or Reynolds.

---

## Overview

Formalize GHR93 Section 8 + Reynolds gap elimination (Theorem 14) to achieve sorry-free `bx_completeness`.

**Critical path**: Phase 1 → 3 → 4 → 5 → 6A → 6B → 8 → 11

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations.

## Goals & Non-Goals

**Goals**: Sorry-free `bx_completeness` via full GHR93 + Reynolds pipeline.
**Non-Goals**: Dense completeness, closing `succ_cofinal` directly, general tactic development.

## Current Sorry Inventory (9 remaining across 3 files; 11 closed this session)

### ExpressivenessGeneral.lean (7 remaining, 9 closed)

| Status | Category | Description | Action |
|--------|----------|-------------|--------|
| ~~CLOSED~~ | Phase 3 | N-side Case 3 gap infimum | Three-way case split with infimum_gap_r_definable |
| ~~CLOSED~~ | Phase 3 | M-side Case 3 gap infimum | Cross infimum_gap_r_definable + three-way case split |
| **OPEN** | **Phase 1** | h_d_unique sorry 1 (line 2835) | **FALSE AS STATED**: depth-r uniqueness is wrong; restructure d_consistency to use Claim 1 game arg at depth r+2 |
| **OPEN** | **Phase 1** | h_d_unique sorry 2 (line 2859) | Same — delete h_d_unique, inline K⁻ argument in d_consistency |
| ~~CLOSED~~ | Phase 3 | h_pt_xc degenerate gap | SplitPointProps disjunctive refactor |
| ~~CLOSED~~ | Phase 3 | h_pt_cy degenerate gap | SplitPointProps disjunctive refactor |
| ~~CLOSED~~ | Phase 3 | Claim 1 Case A, d is gap | Unified proof via h_strict_failure |
| ~~CLOSED~~ | Edge | Claim 1 Case B, q_r2 = y' boundary | Unified proof eliminating Case A/B split |
| ~~CLOSED~~ | Phase 3 | Claim 1 Case B, r2_resp is gap | Unified proof eliminating Case A/B split |
| ~~CLOSED~~ | Regression | h_strict_failure v=c_inf (h_cont_c case) | Case split: contradiction with h_cont_c |
| **OPEN** | **Edge** | ¬cont_holds_cross + boundary r2_resp (line 3759) | r2_resp = rank_embed(y') forces c_inf = y; needs formula materialization or boundary lemma |
| **OPEN** | **Edge** | ¬cont_holds_cross + gap r2_resp (line 3793) | Requires formula materialization (report 39: circular) |
| **OPEN** | **Phase 1** | sigma same_order_type (line 5651) | Blocked on h_d_unique restructure |
| **OPEN** | **Phase 1** | tau same_order_type (lines 5751, 5804) | Blocked on h_d_unique restructure |
| ~~CLOSED~~ | Cleanup | ghr93_winning_condition_symm duplicate | Moved to EFGames.lean |
| **OPEN** | **Phase 4** | ghr93_cases_III_IV (line 6734) | Lemma 9 now proved; needs gap case construction |
| **OPEN** | **Phase 4** | rank-varying theorem (line 6989) | Blocked on rank_embed game transport infrastructure |

### EFGames.lean (1 remaining, 1 closed)

| Status | Description | Action |
|--------|-------------|--------|
| ~~CLOSED~~ | ghr93_decomposition_implies_game (Lemma 11 backward) | Strengthened decomposition_agreement with point-challenge condition per GHR93 Def 8.8 |
| **OPEN** | nf_characterizable_by_stavi (inductive step) | Base case (k=0) proved; inductive step needs GHR93 Theorem 6 + Props 6-7 (~1000-1500 lines) |

### IntegerModel.lean (1 remaining, 2 closed)

| Status | Description | Action |
|--------|-------------|--------|
| ~~CLOSED~~ | ordered_sum_of_good_bounded_is_good | Shift-and-glue OrderIso via cumulativeOffset (Reynolds Lemma 16) |
| ~~CLOSED~~ | cofinal_decomposition_k_equiv | Corrected from closed to half-open intervals per Reynolds; proved via OrderIso + Equiv.toOrderIso |
| **OPEN** | no_gaps_discrete | Blocked on Reynolds Theorem 5 (Phases 5-6B) |

## Implementation Phases

### Phase 1: Cleanup + Same Order Type [IN PROGRESS]

**Status**: Boundary edge and Claim 1 gap cases CLOSED via unified proof. h_d_unique discovered to be mathematically FALSE. Restructuring d_consistency to bypass h_d_unique is in progress.

**CRITICAL DISCOVERY**: `h_d_unique` is **unprovable as stated**. It claims ANY element t' with the same depth-r StaviFormula type as d must equal d. This is mathematically false — two distinct points in a linear order can share the same depth-r type. GHR93 Claim 1 only proves the game RESPONSE equals d at depth r+2 using K⁻(¬D). The depth mismatch (r vs r+2) makes the universal statement unprovable.

**FIX**: Restructure `d_consistency_left/right` to use the Claim 1 game argument directly (K⁻ at depth r+2) instead of going through h_d_unique. Then delete h_d_unique entirely.

**Tasks**:
- [x] **1B. Keep pigeonhole_definable_formula_cross_strict** — used at line 2792 in Case B carrier-point sub-case
- [x] **1C. Boundary edge case** — CLOSED via unified Claim 1 proof (eliminated Case A/B split)
- [ ] **1A. Restructure d_consistency + delete h_d_unique** — IN PROGRESS. Replace h_d_unique parameter in d_consistency_left/right with inline Claim 1 game argument at depth r+2. Then delete h_d_unique (~100 lines, 2 sorries removed).
- [ ] **1D. sigma same_order_type** — Blocked on d_consistency restructure. Needs `(d < p_n ↔ c < e_n)` from game response properties.
- [ ] **1E. tau same_order_type** — Blocked on sigma. Needs sigma instantiation for `(x' < d ↔ x < c)`.
- [ ] **1F. Verification**: `lake build` passes.

**Timing**: 4-8 hours remaining. **Files**: `ExpressivenessGeneral.lean`

---

### Phase 2: Lemma 9 Gap Detection [COMPLETED]

---

### Phase 3: Gap Infimum Wiring + Cases III/IV (GHR93 Theorem 6) [PARTIAL]

**GHR93 reference**: Section 8, pp.117-119.

**Original sorries**: 2013, 2104, 2426, 2443, 2949, 3030 (6 sorries). **4 closed, 1 remaining** (Cases III/IV).

**Tasks**:
- [x] **3A. N-side gap infimum** — CLOSED. Three-way case split: (a) gamma=x' boundary, (b) gamma interior with infimum_gap_r_definable, (c) gamma=y' via complement_no_min contradiction.
- [x] **3B. M-side gap infimum** — CLOSED. Created 4 new cross-structure lemmas (cont_holds_above_gap_cross, cont_fails_below_gap_cross, formula_failure_in_cut_cross, infimum_gap_r_definable_cross). Three-way case split mirroring N-side.
- [x] **3C. Degenerate gap cases** — CLOSED. SplitPointProps refactored to disjunctive form (carrier-point witness OR gap boundary). 3 consumer sites updated.
- [x] **3D. Claim 1 gap sub-cases** — CLOSED. Unified Claim 1 proof via h_strict_failure eliminates Case A/B split entirely. d-gap case proved via carrier-point witnesses between rank_embed(d) and r2_resp.
- [ ] **3E. Cases III/IV** (1 sorry). Blocked on Lemma 9 gap detection infrastructure.

**Timing**: 4-8 hours remaining for 3E. **Depends on**: Phase 1.

---

### Phase 4: Assembly — Rank-Varying Thm 6, Props 6-7, Corollary 5 [IN PROGRESS]

**GHR93 reference**: pp.113-115.

**Progress**:
- [x] **Lemma 11 backward** (ghr93_decomposition_implies_game) — CLOSED in EFGames.lean. Strengthened decomposition_agreement with point-challenge condition per GHR93 Def 8.8.
- [x] **stavi_expressive_completeness assembly** — Sorry-free assembly proof factored through nf_characterizable_by_stavi. Uses NormalForm partition + finite StaviFormula disjunction. Base case (k=0) proved with new infrastructure (sf_conjList, sf_atom_literal, atomKind_to_sf_literal).
- [ ] **nf_characterizable_by_stavi (inductive step)** — 1 sorry in EFGames.lean. Game-theoretic core: construct StaviFormulas encoding NormalForm quantifier structure via U/S connectives. Needs GHR93 Theorem 6 + Propositions 6-7 (~1000-1500 lines).
- [ ] **rank-varying theorem** (1 sorry in ExpressivenessGeneral.lean) — Blocked on rank_embed transport.

**Timing**: 8-14 hours remaining. **Depends on**: Phase 3.

---

### Phase 5: Reynolds Theorem 5 — US Completeness over Prior [NOT STARTED]

Compose `stavi_expressive_completeness` with `flatten_stavi_correct`.

**Timing**: 2-3 hours. **Depends on**: Phase 4.

---

### Phase 6A: Reynolds Gap Elimination Lemmas 6-11 [NOT STARTED]

**Timing**: 6-8 hours. **Depends on**: Phase 5.

---

### Phase 6B: Reynolds Lemma 12 Surgery + Theorem 14 [NOT STARTED]

**Timing**: 6-8 hours. **Depends on**: Phase 6A.

---

### Phase 7-8: IntegerModel.lean + Wire no_gaps_discrete [PARTIAL]

**Progress**:
- [x] **ordered_sum_of_good_bounded_is_good** — CLOSED. Shift-and-glue OrderIso via cumulativeOffset (Reynolds Lemma 16). New helpers: witness_bounded, cumulativeOffset_covers, cumulativeOffset_unique_piece.
- [x] **cofinal_decomposition_k_equiv** — CLOSED. Original statement was FALSE (closed intervals duplicate boundary points). Corrected to half-open intervals per Reynolds. New infrastructure: hoSubinterval, partition_index_unique, hoSubinterval_good_of_very_good.
- [ ] **no_gaps_discrete** — 1 sorry. Blocked on Reynolds Theorem 5 (stavi_expressive_completeness, Phases 5-6B).

**Timing**: 1-2 hours remaining for no_gaps_discrete. **Depends on**: Phase 6B.

---

### Phase 11: Final Verification [NOT STARTED]

**Timing**: 1-2 hours. **Depends on**: Phase 8.

---

## Testing & Validation

- `lake build` passes with zero errors
- `#print axioms bx_completeness` shows only: `propext`, `Classical.choice`, `Quot.sound`
- No `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/`
- No `sorry` on the critical path

## Artifacts & Outputs

- `ExpressivenessGeneral.lean` — inline Claim 1, Cases III/IV, rank-varying Thm 6
- `EFGames.lean` — Lemma 11 backward, stavi_expressive_completeness
- `GapElimination.lean` (NEW) — Reynolds Lemmas 6-14
- `IntegerModel.lean` — no_gaps_discrete wiring

## Rollback/Contingency

Report 39 confirmed full formula materialization (GHR93 Def 8.8) is circular at this stage of the proof. The case-split approach (report 38) faithfully mirrors GHR93's implicit C(c) evaluation. The pigeonhole in Case A extracts a single StaviFormula separator — necessary since the full interval type formula can't be materialized without the theorem being proved.
