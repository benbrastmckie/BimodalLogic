# Implementation Plan: Reynolds Pipeline Activation (v23)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IN PROGRESS]
- **Effort**: 30-50 hours remaining
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED)
- **Research Inputs**: reports/22 (GHR93 Claim 1 extraction), reports/36 (root cause: cont_holds is predicate not formula), reports/38 (pigeonhole boundary inherent)
- **Artifacts**: plans/27_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

---

## CRITICAL DIRECTIVE: FOLLOW GHR93 EXACTLY — NO DEVIATIONS

**NO DEVIATIONS FROM THE PUBLISHED PROOF ARE PERMITTED.** Every deviation from GHR93 has produced weeks of wasted effort fighting artificial edge cases. The pigeonhole approach (Rounds 19-24, ~360 lines) was a deviation from GHR93 Definition 8.8 that produced 6+ rounds of irrecoverable boundary condition failures. The `cont_holds` predicate encoding was a deviation from GHR93's single formula C that forced the pigeonhole in the first place.

**The rule**: If GHR93 defines something as a formula, formalize it as a `StaviFormula`. If GHR93 uses a 5-line proof, the Lean proof should be proportionally short. If an implementation approach creates edge cases that don't exist in GHR93, the approach is WRONG — go back to the paper and implement what it actually says.

**Forbidden**: Encoding formulas as predicates. Pigeonhole extraction to compensate for predicate encodings. "Workarounds" that avoid building the mathematical objects GHR93 defines. Any approach not traceable to a specific page/line in GHR93 or Reynolds.

---

## Overview

Formalize GHR93 Section 8 (expressive completeness of {U,S,U',S'}) + Reynolds gap elimination (Theorem 14) to close `succ_cofinal` and achieve sorry-free `bx_completeness`.

**Critical path**: Phase 1 → 3 → 4 → 5 → 6A → 6B → 8 → 11

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes, no `axiom` declarations.

## Goals & Non-Goals

**Goals**: Sorry-free `bx_completeness` via the full GHR93 + Reynolds pipeline.
**Non-Goals**: Dense completeness (separate path), closing `succ_cofinal` directly, general tactic development.

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| `interval_type_formula` construction (GHR93 Def 8.8) requires NormalForm → StaviFormula translation | Report 39 (pending) will determine exact construction. NormalForm is Fintype; StaviFormula has conj/neg. |
| Rank arithmetic: GHR93 rank r+1 = our stavi_depth r+2 | Already handled. h_fwd_r1 at rank r+2 provides sufficient depth budget. |
| Model surgery (Reynolds Lemma 12) case explosion | Modularize per-case; S dual to U. |

## Implementation Phases

### Phase 1: GHR93 Claim 1 — D-Consistency [IN PROGRESS]

**GHR93 reference**: Section 8, pp.115-117. Definition 8.8, Claim 1.

**GHR93 proof (5 lines)**: Define C = X_{(a_n, y')} as a single rank-r formula (Def 8.8). C' = ¬C ∨ K⁻(¬C) has rank r+1 (our r+2). C'(c) = TRUE (infimum property of c = inf(S_C^M)). Transfer via rank-(r+2) game: C'(d) = TRUE. Analyze: d ≤ d-bar. If d < d-bar: Spoiler picks failure point, contradiction. So d = d-bar.

**Completed work**:
- [x] N-side infimum d = inf(S_C^N), hd_le_an, Case I sites (Tasks 1.1-1.3)
- [x] Cross-structure cont_holds_cross, continuation_set_cross + properties
- [x] c_inf = inf(S_C^M) with membership + cofinal failure
- [x] Suffices restructured to use h_fwd_r1 at rank r+2
- [x] Formula agreement, gap/point, boundary projections via rank_embed
- [x] Direction 2 (d ≤ game response): carrier-point + gap cases, both proved
- [x] IH h_fwd_r1 decoupled (Task 1.7)

**Remaining work**:
- [ ] **Build `interval_type_formula`** per GHR93 Definition 8.8 (~100-200 lines). Pending report 39. This is the SINGLE BLOCKER for Claim 1.
- [ ] **Prove Claim 1 Direction 1** (game response ≤ d) using C' transfer (~80 lines once formula exists).
- [ ] **Remove h_d_unique** + rewire d_consistency_left/right (~-100 lines).
- [ ] **sigma/tau same_order_type** (Task 1.6, ~100 lines with task 195 tactics). Unblocked once Claim 1 closes.
- [ ] **Verification**: `lean_verify d_consistency_left`, `lean_verify ghr93_forward_to_backward`, `lake build`.

**Timing**: 8-15 hours remaining.
**Files**: `ExpressivenessGeneral.lean`

---

### Phase 2: Lemma 9 Gap Detection [COMPLETED]

---

### Phase 3: Cases III/IV + Gap Infimum Wiring (GHR93 Theorem 6) [NOT STARTED]

**GHR93 reference**: Section 8, pp.117-119.

**Tasks**: Close c-gap-case sorry, M-side degenerate sorries, n=0 gap cases, Cases III/IV of Theorem 6. All use Lemma 9 (Phase 2, completed).

**Timing**: 6-10 hours. **Depends on**: Phase 1.

---

### Phase 4: Assembly — Rank-Varying Thm 6, Props 6-7, Corollary 5 [NOT STARTED]

**GHR93 reference**: pp.113-115. Rank-varying Theorem 6, Propositions 6-7, Corollary 5 = `stavi_expressive_completeness`.

**Timing**: 8-14 hours. **Depends on**: Phase 3.

---

### Phase 5: Reynolds Theorem 5 — US Completeness over Prior [NOT STARTED]

Compose `stavi_expressive_completeness` with `flatten_stavi_correct`.

**Timing**: 2-3 hours. **Depends on**: Phase 4.

---

### Phase 6A: Reynolds Gap Elimination Lemmas 6-11 [NOT STARTED]

**Reynolds 1994 reference**: Section 7, Lemmas 6-11. Bad intervals, formula propagation.

**Timing**: 6-8 hours. **Depends on**: Phase 5.

---

### Phase 6B: Reynolds Lemma 12 Surgery + Theorem 14 [NOT STARTED]

Model surgery (14 sub-cases), Lemma 13 contradiction, Theorem 14 assembly.

**Timing**: 6-8 hours. **Depends on**: Phase 6A.

---

### Phase 8: Wire no_gaps_discrete [NOT STARTED]

Replace `no_gaps_discrete` sorry with `gap_elimination_theorem_14` call.

**Timing**: 1-2 hours. **Depends on**: Phase 6B.

---

### Phase 11: Final Verification [NOT STARTED]

Verify `#print axioms bx_completeness` shows no `sorryAx`. Full `lake build`.

**Timing**: 1-2 hours. **Depends on**: Phase 8.

---

## Testing & Validation

- `lake build` passes with zero errors
- `#print axioms bx_completeness` shows only: `propext`, `Classical.choice`, `Quot.sound`
- No `axiom` declarations in `Theories/Bimodal/Metalogic/WeakCanonical/`
- No `sorry` on the critical path

## Artifacts & Outputs

- `ExpressivenessGeneral.lean` — interval_type_formula, inline Claim 1, Cases III/IV, rank-varying Thm 6
- `EFGames.lean` — Lemma 11 backward, stavi_expressive_completeness
- `GapElimination.lean` (NEW) — Reynolds Lemmas 6-14
- `IntegerModel.lean` — no_gaps_discrete wiring

## Rollback/Contingency

If `interval_type_formula` construction proves infeasible due to NormalForm → StaviFormula circularity: research alternative constructions faithful to GHR93 Definition 8.8. No deviation to pigeonhole or predicate-level workarounds permitted.
