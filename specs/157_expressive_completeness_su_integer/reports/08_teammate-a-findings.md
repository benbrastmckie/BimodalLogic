# Teammate A Findings: Code Audit of Task 157

**Date**: 2026-05-18
**Focus**: Exact code state of separation theorem formalization
**Confidence**: High (based on full file reads and grep verification)

## Key Findings

### 1. DedekindZ.lean (1763 lines) — Cases 5-8 Separability

**Status**: Cases 5, 6, 8 are mostly proved; Case 7 uses `all_separable` axiom; Case 6 has 2 sorry.

| Case | Theorem | Status | Dependencies |
|------|---------|--------|--------------|
| 5 | `case5_separable_Z` (L1108) | **PROVED** non-circularly | `case3_equiv_Z_general`, `elim_case_1_gen`, `snce_combined_U_separable` |
| 5gen | `case5_separable_Z_gen` (L1023) | **PROVED** non-circularly | Same as above, drops S-free on a,q |
| 6 | `case6_separable_Z` (L1628) | **2 sorry** at L1617, L1625 | Branch B's D3 disjunct (U-branch and ¬U-branch) incomplete |
| 7 | `case7_separable_Z` (L1649) | **`all_separable _`** at L1659 | Fully circular — delegates to axiom |
| 8 | `case8_separable_Z` (L1740) | **PROVED** non-circularly | `case8_equiv_Z`, `elim_case_2_gen`, `case5_separable_Z` |

**Sorry details (Case 6)**:
- **L1617**: `sorry -- D3 U-branch: needs d21-style sigma_B equiv + U-reduction. See handoff.`
- **L1625**: `sorry -- D3 ¬U-branch: needs triple event-split. See handoff.`

Both sorry are in `case6_branchB_separable` (L1420), specifically in the D3 disjunct of the case3_rhs decomposition. The D1 and D2 disjuncts are fully proved. The blocking issue is constructing an explicit separated equivalent of `S(alpha_B, Q_Z)` that satisfies `untl_under_bool_only`, then proving the congruence when U holds at event points.

**Case 7** at L1659 simply returns `all_separable _`, meaning it relies entirely on the 9 axioms in SeparationThm.lean. No partial proof exists.

**Key infrastructure proved non-circularly**:
- Q_Z definition and properties (L111-218)
- Q_lemma_Z_fwd (L120-148) and Q_lemma_Z_bwd (L154-203) — the core semantic Q-lemma
- case3_equiv_Z_general (L480) — the three-disjunct Case 3 equivalence for arbitrary events
- replace_untl_with_top/bot infrastructure (L551-827) — U-replacement in boolean positions
- snce_combined_U_separable (L1002) and snce_combined_notU_separable (L851) — key helpers
- d21_sep and d21_sep_equiv (L875-995) — explicit separated equivalent construction
- case1_psi_uf_part and case1_psi_reduces_when_U (L1376-1414) — U/U' contradiction reduction
- untl_neguntl_contradictory (L1133) — U(A,B) and U(¬A∧¬B, ¬A) cannot coexist
- neg_untl_event_equiv (L1152) — ¬U ↔ G(¬A) ∨ U' decomposition
- snce_Ufree_event_qU_guard_separable (L1175) — Branch A of Case 6

### 2. SeparationThm.lean (285 lines) — 9 Axioms

All 9 axioms are in this file, listed with exact line numbers:

| # | Line | Axiom | Type |
|---|------|-------|------|
| 1 | 90 | `all_past_separable` | `is_separable` temporal closure |
| 2 | 94 | `all_future_separable` | `is_separable` temporal closure |
| 3 | 98 | `untl_separable` | `is_separable` temporal closure |
| 4 | 102 | `snce_separable` | `is_separable` temporal closure |
| 5 | 223 | `all_past_properly_separable` | `is_properly_separable` temporal closure |
| 6 | 228 | `all_future_properly_separable` | `is_properly_separable` temporal closure |
| 7 | 233 | `untl_properly_separable` | `is_properly_separable` temporal closure |
| 8 | 239 | `snce_properly_separable` | `is_properly_separable` temporal closure |
| 9 | 281 | `proper_separation_preserves_atoms` | Atom preservation |

`all_separable` (L125) is a theorem proved by structural induction, calling axioms 1-4 for temporal cases. `all_properly_separable` (L248) similarly calls axioms 5-8.

Corollary theorems at L143-206 (`single_S_with_U`, `single_U_separable`, `multi_U_separable`, `no_S_within_U_separable`, `junction_depth_separable`, `separation_theorem_int`) all trivially delegate to `all_separable`.

### 3. Hierarchy.lean (1055 lines) — Junction-Depth Infrastructure

**Status**: Infrastructure complete; no hierarchy theorem proved.

**What exists (all sorry-free, but using `all_separable` in one place)**:
- `has_single_U_type` / `has_single_S_type` predicates (L39-100)
- `single_U_type_separable` — proved via `all_separable` (structural induction with temporal closure axioms), NOT a non-circular proof (L298-330)
- `abstract_untl` (L375) — replaces U(A,B) with atom p
- `abstract_snce` (L527) — replaces S(A,B) with atom p
- Both abstraction functions preserve key properties:
  - `abstract_untl_preserves_S_free` (L443)
  - `abstract_untl_preserves_separated` (L819)
  - `abstract_snce_jd_le` (L937) — does not increase junction_depth
  - `abstract_snce_inside_untl_jd_lt` (L1038) — strict decrease for junction_depth when S is inside U-arg
  - Various jdU decrease lemmas (L981-1031)
- `multi_U_formula_separable` (L858) — delegates to `all_separable` directly

**What is MISSING** (the actual hierarchy):
- `no_S_nested_in_U_separable` — not started (this is Lemma 10.2.7)
- `junction_depth_separable_aux` — not started (this is Lemma 10.2.8)
- `all_formulas_separable` — not started (the theorem that replaces `all_separable`)

The infrastructure (abstraction functions + junction_depth lemmas) is ready, but no inductive argument has been attempted.

### 4. Eliminations.lean (698 lines) — Cases 1-4

**Status**: FULLY PROVED, sorry-free, no axiom dependencies.

Key theorems:
- `elim_case_1_gen` — S(a∧U(A,B), q) separable (U-free a, q; S-free A, B)
- `elim_case_2_gen` — S(a∧¬U(A,B), q) separable
- `elim_case_3_gen` — S(a, q∨U(A,B)) separable (U-free, S-free a, q)
- `elim_case_4_gen` — S(a, q∨¬U(A,B)) separable
- `case1_psi` (made public) + `case1_psi_properties` — explicit separated equivalent

### 5. NormalForm.lean (455 lines) — Lemma 10.2.4 Wiring

**Status**: Sorry-free. Wires Cases 5-8 to DedekindZ.lean.

- `case5_separable` (L156) → `case5_separable_Z` ✓
- `case6_separable` (L166) → `case6_separable_Z` (inherits 2 sorry)
- `case7_separable` (L177) → `case7_separable_Z` (inherits `all_separable`)
- `case8_separable` (L188) → `case8_separable_Z` ✓
- `lemma_10_2_4` (L397) — the full 8-case decomposition of S(C,F) with single U-type

### 6. TemporalClosure.lean (813 lines) — expand_temporal

**Status**: Sorry-free. Defines `expand_temporal` which replaces `all_past`/`all_future` with S/U equivalents, and proves:
- `expand_temporal_equiv` — semantic equivalence
- `has_no_allpast_allfuture` — expanded formula has no all_past/all_future

### 7. DualEliminations.lean — Dead Code

Has 8 sorry (all 8 dual elimination cases). Confirmed dead code — not imported by any active file in the main proof chain.

### 8. ExpressiveCompleteness.lean

**Status**: Sorry-free. The main theorem `US_expressively_complete_over_Z` compiles without sorry.

## Summary: What Remains

### Blockers (in priority order)

1. **Case 6 D3 sorry (2 sorry)** — `case6_branchB_separable` L1617, L1625 in DedekindZ.lean
   - The D3 disjunct of Branch B requires ~180 LOC of explicit sigma_B equiv + congruence
   - Approach described in code comments: build d21-style equiv, use U/U' reduction

2. **Case 7 (`all_separable` bootstrap)** — `case7_separable_Z` L1659 in DedekindZ.lean
   - Completely unproved. The handoff notes recommend: neg_until_equiv → two U-types → hierarchy
   - Cannot be proved without either the hierarchy theorem or a direct two-U-type argument

3. **Hierarchy theorem** (Lemmas 10.2.5-10.2.8) — not started in Hierarchy.lean
   - Infrastructure is ready (abstract_untl, abstract_snce, jd decrease lemmas)
   - The inductive argument hasn't been attempted
   - Phase 6B Analysis handoff (phase-6B-analysis-20260518.md) documents 7 failed approaches
   - Root cause: the compose-back step after abstraction requires `snce_separable` axiom

4. **9 axioms in SeparationThm.lean** — cannot be eliminated without the hierarchy

### Dependency Chain

```
Case 6 D3 sorry → Case 6 → NormalForm.case6_separable
Case 7 all_separable → Case 7 → NormalForm.case7_separable
                                       ↓
                              lemma_10_2_4 (Lemma 10.2.4)
                                       ↓
                              hierarchy theorem (Lemmas 10.2.5-10.2.8)
                                       ↓
                              all_formulas_separable
                                       ↓
                              Replace 9 axioms in SeparationThm.lean
```

### Non-Blocking Issues

- DualEliminations.lean has 8 sorry (dead code, not imported)
- Hierarchy.lean `multi_U_formula_separable` uses `all_separable` (will be replaced by hierarchy)

## Recommended Approach

### Priority 1: Fix Case 6 D3 sorry (2 sorry → 0 sorry)

The code comments at L1616 describe the approach: build sigma_B explicitly (analogous to `d21_sep` from Case 5), prove it satisfies `untl_under_bool_only`, then use `snce_combined_U_separable` / `snce_combined_notU_separable`. Estimated ~150 LOC.

### Priority 2: Prove Case 7 directly

The phase-2-3-handoff recommends the hierarchy approach, but a direct approach may work:
- neg_until_equiv decomposes ¬U as G(¬A) ∨ U'
- Guard becomes q ∨ G(¬A) ∨ U'
- Use case3_equiv_Z_general to handle U' in guard
- Event-split + snce_combined_U_separable for each sub-case
- Key challenge: two U-types (U and U') in the same formula

### Priority 3: Hierarchy theorem

The phase-6B-analysis handoff documents that all 7 approaches tried have failed due to the circularity in the compose-back step. The recommended approach is a "Generalized Case 1" that accepts separable events (not just U-free), but this hasn't been attempted.

## Evidence Summary

| File | Lines | Sorry | Axiom Uses | `all_separable` Uses |
|------|-------|-------|------------|---------------------|
| DedekindZ.lean | 1763 | 2 (L1617, L1625) | 0 (direct) | 1 (L1659, Case 7) |
| SeparationThm.lean | 285 | 0 | 9 axiom declarations | — |
| Hierarchy.lean | 1055 | 0 | 0 (direct) | 1 (L860) |
| Eliminations.lean | 698 | 0 | 0 | 0 |
| NormalForm.lean | 455 | 0 | 0 | 0 (delegates to DedekindZ) |
| TemporalClosure.lean | 813 | 0 | 0 | 0 |
| Defs.lean | 343 | 0 | 0 | 0 |
| DualEliminations.lean | ~150 | 8 | 0 | 0 (dead code) |
| **Total** | **5412+** | **2 sorry** | **9 axioms** | **2 uses** |
