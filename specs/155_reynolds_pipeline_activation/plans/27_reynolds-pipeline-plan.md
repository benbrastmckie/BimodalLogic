# Implementation Plan: Reynolds Pipeline Activation (v25)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 20-40 hours remaining (12 sorries remain from original 19; 11 closed, 4 added by restructuring)
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

## Current Sorry Inventory (12 remaining across 3 files)

### ExpressivenessGeneral.lean (10 remaining)

| Line | Blocker | Description | Effort |
|------|---------|-------------|--------|
| 2835 | Formula materialization | h_d_unique sorry 1 — predicate-level cont_holds can't be materialized as formula without circularity | Fundamental |
| 2859 | Formula materialization | h_d_unique sorry 2 — same circularity | Fundamental |
| 3759 | Formula materialization | ¬cont_holds_cross boundary (r2_resp = rank_embed(y')) | Fundamental |
| 3793 | Formula materialization | ¬cont_holds_cross gap r2_resp | Fundamental |
| 5651 | h_d_unique | sigma same_order_type — needs game response = d | Gated |
| 5751 | h_d_unique | tau same_order_type (1) — needs sigma instantiation | Gated |
| 5804 | h_d_unique | tau same_order_type (2) — needs sigma instantiation | Gated |
| 6734 | Signature threading | Cases III/IV — needs h_fwd_r1 threaded through signatures + 500-1000 lines | 12-22 hrs |
| 6999 | GHR93 Lemma 10 | rank-varying (rank downward transport 1) — needs K+/K- gap characterization | 300-500 lines |
| 7145 | GHR93 Lemma 10 | rank-varying (rank downward transport 2) — same blocker | Same |

### EFGames.lean (1 remaining)

| Line | Blocker | Description | Effort |
|------|---------|-------------|--------|
| 9433 | GHR93 Thm 6 + Props 6-7 | nf_characterizable_by_stavi inductive step (base case k=0 proved) | 1000-1500 lines |

### IntegerModel.lean (1 remaining)

| Line | Blocker | Description | Effort |
|------|---------|-------------|--------|
| 863 | Phases 5-6B | no_gaps_discrete — gated on Reynolds Theorem 5 | Gated |

### Blocker Dependency Graph

```
Formula materialization (FUNDAMENTAL — report 29 confirmed, report 39 circularity)
  └─ h_d_unique ×2 (lines 2835, 2859)
  └─ ¬cont_holds_cross edges ×2 (lines 3759, 3793)
  └─ same_order_type ×3 (lines 5651, 5751, 5804) [gated on h_d_unique]

GHR93 Lemma 10 (rank downward transport — 300-500 lines)
  └─ rank-varying ×2 (lines 6999, 7145)

Signature threading + Cases III/IV proof (12-22 hours)
  └─ ghr93_cases_III_IV (line 6734)

GHR93 Theorem 6 + Props 6-7 (1000-1500 lines)
  └─ nf_characterizable_by_stavi (EFGames line 9433)
  └─ no_gaps_discrete (IntModel line 863) [gated on nf_characterizable]
```

### Session Progress (closed sorries)

| # | Description | Method |
|---|-------------|--------|
| 1 | SplitPointProps h_pt_xc degenerate gap | Disjunctive refactor |
| 2 | SplitPointProps h_pt_cy degenerate gap | Disjunctive refactor |
| 3 | N-side Case 3 gap infimum | Three-way case split with infimum_gap_r_definable |
| 4 | M-side Case 3 gap infimum | Cross infimum_gap_r_definable |
| 5 | Claim 1 Case A, d is gap | Unified proof via h_strict_failure |
| 6 | Claim 1 Case B, q_r2 = y' boundary | Unified proof eliminating Case A/B split |
| 7 | Claim 1 Case B, r2_resp is gap | Unified proof eliminating Case A/B split |
| 8 | ghr93_decomposition_implies_game (EFGames) | Strengthened decomposition_agreement per GHR93 Def 8.8 |
| 9 | ordered_sum_of_good_bounded_is_good (IntModel) | Shift-and-glue OrderIso (Reynolds Lemma 16) |
| 10 | cofinal_decomposition_k_equiv (IntModel) | Corrected to half-open intervals per Reynolds |
| 11 | h_strict_failure v=c_inf regression | Case split on h_cont_c |

## Implementation Phases

### Phase 1: Cleanup + Same Order Type [IN PROGRESS]

**Status**: Boundary edge and Claim 1 gap cases CLOSED via unified proof. h_d_unique discovered to be mathematically FALSE. Restructuring d_consistency to bypass h_d_unique is in progress.

**CRITICAL DISCOVERY 1**: `h_d_unique` is **unprovable as stated**. It claims ANY element t' with the same depth-r StaviFormula type as d must equal d. This is mathematically false — two distinct points in a linear order can share the same depth-r type. GHR93 Claim 1 only proves the game RESPONSE equals d at depth r+2 using K⁻(¬D). The depth mismatch (r vs r+2) makes the universal statement unprovable.

**CRITICAL DISCOVERY 2 (report 29)**: The root blocker for h_d_unique + 4 other sorries is **predicate-vs-formula circularity**. GHR93 uses C = X_{(a_n,y')} as a SINGLE concrete temporal formula. The Lean code uses a universally-quantified Prop (`cont_holds_cross`), which cannot be materialized as a single formula without enumerating all rank-r formulas — requiring the very expressive completeness result being proved.

**RESEARCH FINDINGS** (3 parallel agents analyzed literature):
- GHR93 (report 28): Proof is valid for ALL linear orders; operates on M_r; no density assumption
- Reynolds 1994 (report 28): K⁻ is vacuously false on discrete carrier points; Reynolds uses syntactic elimination, not games, for integer time
- Handbook (report 28): GHR94 Ch 10 proves integer completeness via Reynolds eliminations — no games, no K⁻. K⁻ only appears in Ch 12's general linear time proof where gaps exist.

**FIX OPTIONS**: (a) Break circularity by restructuring the induction to make formula C available at the right point; (b) Switch to Reynolds syntactic elimination for the integer-time case; (c) Restructure d_consistency to inline the K⁻ argument with a concrete formula extracted from the game state.

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
- [ ] **3E. Cases III/IV** (1 sorry). *(deviation: blocked — rank mismatch, see blocker below)*

**BLOCKER** (Phase 3, Task 3E):
- **What failed**: `ghr93_cases_III_IV` (line 6734) cannot be closed with current theorem signature.
- **What was tried**: Analysis of GHR93 Cases III/IV proof structure vs formalization infrastructure. GHR93 uses tau at rank r+4 to transfer U(delta, A) formulas of rank ~r+3. The formalization's `SplitPointProps.tau` is at rank r only. All creative rank-r-only approaches (forward game inversion, type matching, direct gap construction) fail because the backward game inversion problem requires higher-rank formula transfer.
- **Why it's stuck**: The formalization decouples ranks (IH at rank r, forward game at rank r+2 as side parameter). GHR93's induction hypothesis provides backward games at rank r+4, enabling Cases III/IV formula transfer. The formalization's backward games are at rank r, which is insufficient for the gap detection formula `left_formula A D` (depth ~r+4) or its composition `U(delta, A)` (depth ~r+3). The rank r+2 forward game `h_fwd_r1` is available in `ghr93_inductive_step` but is NOT threaded to `ghr93_cases_III_IV`.
- **What is needed**: (1) Thread `h_fwd_r1` through `ghr93_cases_II_III_IV` to `ghr93_cases_III_IV`. (2) Within Cases III/IV, use `h_fwd_r1` to derive rank r+2 backward games on sub-intervals (via `ghr93_forward_to_backward_core` at rank r+2, or a direct argument). (3) Use the higher-rank backward game to transfer the gap detection formula `U(delta, A)` from `a_{n-1}` to `e_{n-1}`. (4) Apply Lemma 9 to find matching gap `e_n`. (5) Verify winning condition (same_order_type, gap_point_agreement, formula_agreement). Estimated 500-1000 lines.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: Blocked pending signature refactoring + rank r+2 backward game derivation. Estimated 8-16 hours.

---

### Phase 4: Assembly — Rank-Varying Thm 6, Props 6-7, Corollary 5 [IN PROGRESS]

**GHR93 reference**: pp.113-115.

**Progress**:
- [x] **Lemma 11 backward** (ghr93_decomposition_implies_game) — CLOSED in EFGames.lean. Strengthened decomposition_agreement with point-challenge condition per GHR93 Def 8.8.
- [x] **stavi_expressive_completeness assembly** — Sorry-free assembly proof factored through nf_characterizable_by_stavi. Uses NormalForm partition + finite StaviFormula disjunction. Base case (k=0) proved with new infrastructure (sf_conjList, sf_atom_literal, atomKind_to_sf_literal).
- [ ] **nf_characterizable_by_stavi (inductive step)** — 1 sorry in EFGames.lean. Game-theoretic core: construct StaviFormulas encoding NormalForm quantifier structure via U/S connectives. Needs GHR93 Theorem 6 + Propositions 6-7 (~1000-1500 lines).
- [ ] **rank-varying theorem** (2 sorries in ExpressivenessGeneral.lean, lines 6999/7145) — Base case (n=0) proved sorry-free. Inductive case structured but both sorries blocked on GHR93 Lemma 10 (rank downward transport). Needs K+/K- gap characterization formula D' (~300-500 lines).

**Timing**: 12-20 hours remaining. **Depends on**: Phase 3 + Lemma 10 infrastructure.

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
