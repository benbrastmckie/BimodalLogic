# Wave 1 Partial Handoff — Phases 8a+8b

**Task**: 107 — Burgess chronicle construction
**Session**: sess_1777507213_35f648
**Date**: 2026-04-30
**Plan**: v34 (plans/48_implementation-plan.md)

## Status

Wave 1 (Phases 8a + 8b) is PARTIAL. Key wins achieved, two issues remain.

## Phase 8a: DCS Maximality Revert — PARTIAL

### Completed
- [x] BurgessR3Maximal definition changed from ClosedUnderDerivation to SetDeductivelyClosed (ChronicleTypes.lean:320)
- [x] Zorn sorry (RRelation.lean:772) ELIMINATED — the inconsistent D case never arises with DCS maximality
- [x] `burgessR3Maximal_extension_exists` compiles sorry-free
- [x] `BurgessR3Maximal_extension_fails` updated to use DCS

### Blocked: g_content_sub_B inconsistent case (2 sorries)
- **PointInsertion.lean:~850**: `g_content_sub_B_of_BurgessR3Maximal` inconsistent case
- **PointInsertion.lean:~875**: `h_content_sub_B_of_BurgessR3Maximal` dual

**Root cause**: With DCS maximality, the old Set.univ trick (which used CUD) no longer works since Set.univ is not DCS. The G(φ)/F(φ.neg) contradiction approach from the plan does NOT work without density: U(φ.neg, γ) ∧ G(φ) is consistent in models where the open guard interval (t,s) is empty (discrete models). Burgess does NOT assume density.

**Proposed fix (seed refactoring)**: Instead of proving g_content ⊆ B as a general property of BurgessR3Maximal, modify `burgessR3Maximal_from_g_content_sub` to include g_content(A) ∪ h_content(C) in the Zorn seed. Then g_content ⊆ B follows trivially from seed ⊆ B. This requires:
1. Proving g_content(A) ∪ h_content(C) is consistent (g_content alone IS provably consistent via G-distribution in MCS)
2. Proving DC(g_content(A) ∪ h_content(C)) satisfies burgessR3(A, -, C)
3. Restructuring callers to use the enriched construction

This eliminates g_content_sub_B_of_BurgessR3Maximal entirely (no longer needed as a general theorem).

## Phase 8b: A7a Axiom — PARTIAL

### Design Change from Plan
The plan called for REPLACING BX7 with A7a. This caused cascading failures:
- 32+ errors in SoundnessLemmas.lean — the `axiom_swap_valid` and `axiom_locally_valid` functions have 4 copies of the linearity proof that all need restructuring
- `untl_conj_guard`/`snce_conj_guard` in RRelation.lean rely on BX7's fixed-guard structure (dead code, but still compile)

### Actual Implementation
Added A7a as a SEPARATE axiom alongside BX7:
- `Axiom.linear_until_a7a` / `Axiom.linear_since_a7a` — new constructors in Axioms.lean
- Substitution cases added (Substitution.lean)
- Soundness proofs added and verified (Soundness.lean) — `linear_until_a7a_valid`, `linear_since_a7a_valid`
- All Soundness.lean match arms added (6 sites across axiom_valid, valid_dense, valid_discrete, etc.)

### Remaining: SoundnessLemmas.lean (6 missing match arms)
The file has 4 functions that exhaustively match on `Axiom`:
1. `axiom_swap_valid` (line ~766): A7a cases ADDED ✓
2. `axiom_locally_valid` (line ~1396): MISSING linear_until_a7a, linear_since_a7a
3. `axiom_swap_valid_general` (line ~1887): MISSING linear_until_a7a, linear_since_a7a
4. `axiom_locally_valid_general` (line ~2199): MISSING linear_until_a7a, linear_since_a7a

For functions 2 and 4 (direct validity): copy the proof from `axiom_locally_valid` function 1's `linear_until`/`linear_since` cases but with A7a's disjunct structure (D3 guard order swapped: `h_guard₂ r ... h_guard₁ r ...` instead of `h_guard₁ r ... h_guard₂ r ...`).

For functions 1 and 3 (swap validity): copy the swap proof from function 1's `linear_since`/`linear_until` cases but with same D3 guard swap.

**Key insight**: After `simp only [Formula.and, Formula.or, Formula.neg, truth_at]`, the formula encoding makes A7a proof terms nearly identical to BX7 — only the D3 case needs `(h_guard₂ r ...) (h_guard₁ r ...)` instead of `(h_guard₁ r ...) (h_guard₂ r ...)`.

## Build Status

**Build FAILS** on:
- `SoundnessLemmas.lean`: 6 missing `linear_until_a7a`/`linear_since_a7a` match arms
- `PointInsertion.lean`: 2 sorry sites (g_content_sub_B density gap)

Soundness.lean, Axioms.lean, Substitution.lean, RRelation.lean, ChronicleTypes.lean all compile clean.

## Current Sorry Count

| File | Sorries | Notes |
|------|---------|-------|
| PointInsertion.lean | 3 | 2 g/h_content_sub_B (seed refactoring needed), 1 lemma_2_7 |
| CounterexampleElimination.lean | 2 | C4/C4' (Phase 9) |
| ChronicleToCountermodel.lean | 2 | FUC/FSC (Phase 10) |
| **Total** | **7** | Down from ~13 before this session |

## Resume Instructions

1. **Fix SoundnessLemmas.lean**: Add 6 missing match arms (3 functions × 2 cases each). Pattern: find `-- NOTE: until_elim / since_elim match arms removed` after `linear_since` cases, insert A7a cases before. Use `axiom_swap_valid` function 1's A7a cases (already present at ~line 766) as the template.

2. **Run `lake build`** to verify SoundnessLemmas compiles.

3. **Research seed refactoring** for g_content_sub_B: investigate including g_content(A) in the Zorn seed instead of proving g_content ⊆ B from maximality. Key question: is g_content(A) ∪ h_content(C) provably consistent?

4. **Proceed to Wave 2**: Phase 6 (Lemma 2.7 using `Axiom.linear_until_a7a`) and Phase 9 (C4 via lemma_2_6).

## Key Decisions

1. **A7a is additive, not replacing BX7**: Both axioms coexist. A7a is used for Lemma 2.7. BX7 is used for guard conjunction. Both are sound.

2. **g_content_sub_B needs architectural fix, not density**: The correct approach is seed enrichment (include g_content in Zorn seed), not assuming density axioms. Burgess's completeness covers all irreflexive linear orders including discrete.

3. **Plan v34 needs revision**: Phase 8b's "replace BX7" goal should be changed to "add A7a alongside BX7". Phase 8a's g_content approach needs the seed refactoring research.
