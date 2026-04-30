# Wave 1 Partial Handoff — Phases 8a+8b

**Task**: 107 — Burgess chronicle construction
**Session**: sess_1777507213_35f648
**Date**: 2026-04-30
**Plan**: v34 (plans/48_implementation-plan.md)

## Status

Wave 1 (Phases 8a + 8b) is PARTIAL. Key wins achieved, two blockers remain.

## Phase 8a: DCS Maximality Revert — PARTIAL

### Completed
- [x] BurgessR3Maximal definition changed from ClosedUnderDerivation to SetDeductivelyClosed (ChronicleTypes.lean:320)
- [x] Zorn sorry (RRelation.lean:772) ELIMINATED — the inconsistent D case never arises with DCS maximality
- [x] `burgessR3Maximal_extension_exists` compiles sorry-free
- [x] `BurgessR3Maximal_extension_fails` updated to use DCS

### Blocked: g_content_sub_B inconsistent case (2 sorries)
- **PointInsertion.lean:851**: `g_content_sub_B_of_BurgessR3Maximal` inconsistent case
- **PointInsertion.lean:~875**: `h_content_sub_B_of_BurgessR3Maximal` dual

**Root cause**: The plan proposed using G(φ)/F(φ.neg) contradiction, but this requires density:
- G(φ) ∈ A means ¬F(φ.neg) ∈ A
- U(φ.neg, γ) ∈ A (from burgessR3 with φ.neg ∈ B, γ ∈ C)
- To derive F(φ.neg), we need a non-empty open interval (t,s) where the U-guard φ.neg holds
- BX has no density axiom, so F(φ.neg) is NOT derivable from U(φ.neg, γ)
- The contradiction is semantically valid on dense orders but NOT provable in BX

**Options for resolution**:
1. Add a density axiom to BX (changes the proof system)
2. Accept the sorry (well-understood gap, doesn't block semantic completeness for dense models)
3. Find a density-free proof (unknown if possible)
4. Revert to CUD maximality (brings back Zorn sorry at RRelation.lean:772)

**Recommendation**: Option 2 for now. The sorry is well-contained and the density gap is a known limitation of BX for non-dense orders.

## Phase 8b: A7a Axiom — PARTIAL

### Design Change from Plan
The plan called for REPLACING BX7 with A7a. This caused cascading failures:
- `untl_conj_guard` and `snce_conj_guard` in RRelation.lean rely on BX7's fixed-guard structure
- 32+ errors in SoundnessLemmas.lean across 4 copies of axiom swap/local validity proofs
- A7a's fixed-event form cannot derive BX7 without left_mono_until (which weakens guards, opposite direction needed)

### Actual Implementation
Added A7a as a SEPARATE axiom alongside BX7:
- `Axiom.linear_until_a7a` / `Axiom.linear_since_a7a` — new constructors in Axioms.lean
- Substitution cases added (Substitution.lean)
- Soundness proofs added (Soundness.lean) — `linear_until_a7a_valid`, `linear_since_a7a_valid`
- Soundness.lean match arms added for all validity functions (6 sites)
- BX7 (`Axiom.linear_until`) preserved — all existing callers unchanged

### Remaining Work
- SoundnessLemmas.lean: 8 new match arms needed across 4 functions (agent in progress)
  - `axiom_swap_valid` (function 1): DONE
  - `axiom_locally_valid` (function 2): IN PROGRESS (agent)
  - `axiom_swap_valid_general` (function 3): IN PROGRESS (agent)
  - `axiom_locally_valid_general` (function 4): IN PROGRESS (agent)

## Current Sorry Count

| File | Sorries | Notes |
|------|---------|-------|
| PointInsertion.lean | 3 | 2 density-gap (g/h_content_sub_B), 1 lemma_2_7 |
| CounterexampleElimination.lean | 2 | C4/C4' (Phase 9) |
| ChronicleToCountermodel.lean | 2 | FUC/FSC (Phase 10) |
| **Total** | **7** | Down from ~13 before Phase 8a |

## Build Status

Last build: FAILS on SoundnessLemmas.lean (missing match arms) and PointInsertion.lean (2 density sorries use wrong proof term — now cleaned to `sorry`)

## Resume Instructions

1. Wait for SoundnessLemmas agent to complete, or manually add remaining 6 match arms
2. Run `lake build` to verify
3. Commit
4. Proceed to Wave 2: Phase 6 (Lemma 2.7 with A7a) + Phase 9 (C4 via lemma_2_6)
5. Phase 6 should use `Axiom.linear_until_a7a` (the new A7a axiom) for the three-way disjunction

## Key Decisions for Next Session

1. **Phase 6 (Lemma 2.7)**: Uses `Axiom.linear_until_a7a` directly. The fixed-event property means D1+D2 can be eliminated by `neg U(gamma_0, beta_0 AND eta)`. This was the whole motivation for A7a.

2. **Density gap**: Accept 2 sorries in g/h_content_sub_B? Or investigate density axiom? This blocks the sorry-free milestone but NOT the proof structure.

3. **A7a soundness in SoundnessLemmas**: The proof terms follow the same structure as BX7 cases — the simp+truth_at expansion makes the formula structure opaque enough that guard₁/guard₂ positions work identically.
