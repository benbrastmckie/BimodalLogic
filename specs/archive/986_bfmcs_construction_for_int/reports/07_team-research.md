# Research Report: Task #986 — Team Research Synthesis

**Task**: 986 - bfmcs_construction_for_int
**Date**: 2026-03-17
**Mode**: Team Research (2 teammates)
**Session**: sess_1773785524_aedf5c

---

## Executive Summary

**Both teammates independently confirm**: The D=Int BFMCS F/P sorries cannot be filled. The linearization obstruction is structural (not a proof gap). Task 986 as stated should be marked BLOCKED or ABANDONED.

**Critical insight for task 987**: Completeness does NOT require D=Int. Since `valid phi` quantifies over ALL D, any D with `AddCommGroup + LinearOrder + IsOrderedAddMonoid` suffices for the countermodel. The sorry-free `temporal_coherent_family_exists_CanonicalMCS` construction can serve as the foundation for a different completeness path.

---

## Key Findings

### From Teammate A (Status Analysis)

- **IntBFMCS.lean has exactly 2 sorries**: `intFMCS_forward_F` (line 563) and `intFMCS_backward_P` (line 574)
- **G/H coherence is FULLY PROVEN**: All chain infrastructure (`intChain_forward_G`, `intChain_backward_H`, etc.) is sorry-free
- **The linearization obstruction is structural**: F/P witnesses form an infinitely branching tree that cannot embed in Int-chain (one successor per node)
- **Six prior research iterations** (research-001 through research-006) progressively deepened this conclusion with no refutation
- **AlgebraicBaseCompleteness.lean** has 2 dependent sorries (`singleFamilyBFMCS`, `construct_bfmcs_from_mcs`) that flow through IntBFMCS
- **ROAD_MAP.md explicitly marks D=Int as FORBIDDEN** dead end

### From Teammate B (Alternative Paths)

- **`valid phi` quantifies over ALL D**: Completeness only needs ONE countermodel in ONE D — not specifically Int
- **CanonicalMCS has `Preorder` but NOT `AddCommGroup`**: Cannot be used directly as D parameter to TaskFrame
- **`temporal_coherent_family_exists_CanonicalMCS` IS sorry-free**: Works because CanonicalMCS contains ALL MCSs by construction (no linearization needed)
- **The `≤` vs `<` mismatch**: The CanonicalMCS construction proves `≤` but `BFMCS.temporally_coherent` needs strict `<`
- **Upgrade possible**: Since `CanonicalR` is irreflexive, `≤` can be strengthened to `<` with a small proof fix

---

## Completion Status (Task 986)

| Component | Status | Details |
|-----------|--------|---------|
| G/H chain infrastructure | **COMPLETE** | All 12+ theorems sorry-free |
| `intFMCS_forward_F` | **BLOCKED** | Linearization obstruction (structural) |
| `intFMCS_backward_P` | **BLOCKED** | Symmetric obstruction |
| Task 986 overall | **CANNOT COMPLETE** | Mathematical impossibility, not proof gap |

---

## Conflicts and Resolutions

### Conflict: None
Both teammates reach identical conclusions from independent angles (status analysis vs. mathematical path analysis).

### Points of Strong Agreement

1. D=Int F/P sorries are unfillable (structural obstruction)
2. Completeness does not require D=Int
3. CanonicalMCS sorry-free construction is the foundation for the correct path
4. Multi-family modal saturation (not single-family) is needed
5. Task 987 should restructure to avoid IntBFMCS dependency

---

## Recommended Path Forward

### For Task 986

**Mark as BLOCKED or ABANDONED.**

Update IntBFMCS.lean documentation to note:
- The 2 sorries are architectural placeholders (linearization obstruction)
- Cannot be filled within the D=Int framework
- Task 986 completion is NOT required for task 987

### For Task 987 (Algebraic Base Completeness)

**Restructure the completeness proof:**

1. **Strengthen `temporal_coherent_family_exists_CanonicalMCS`** to use strict `<` (achievable because CanonicalR is irreflexive)

2. **Build `BFMCS CanonicalMCS`** via multi-family modal saturation from `ModalSaturation.lean` (avoids single-family `modal_backward` sorry)

3. **Create CanonicalMCS-specific truth lemma** — either:
   - Generalize existing truth lemma to `D : Preorder`, or
   - Build dedicated truth lemma for CanonicalMCS-indexed FMCS

4. **Connect to `valid phi`** — Since validity quantifies over all D, provide the countermodel using an auxiliary construction that bridges CanonicalMCS to some `AddCommGroup D`

### Alternative: Direct Truth Lemma Path

Skip the parametric infrastructure entirely:
- Use `CanonicalConstruction.lean`'s non-parametric truth lemma
- Build proof directly against CanonicalMCS-based model
- The completeness argument becomes: "there exists a model falsifying phi" without requiring parametric D

---

## Impact Assessment

### On Task 987

**Current state**: Task 987 has sorries in `construct_bfmcs_from_mcs (D := Int)` which flow through IntBFMCS sorries.

**Fix**: Change `algebraic_base_completeness` to use CanonicalMCS path:
- Replace `construct_bfmcs_from_mcs (D := Int)` with CanonicalMCS-based construction
- Use `temporal_coherent_family_exists_CanonicalMCS` (strengthened to strict `<`)
- Apply CanonicalMCS-specific truth lemma

**Work estimate**: Medium (truth lemma + modal saturation wiring) — substantially less than the impossible D=Int dovetailing

### On Project Roadmap

- Task 986 (D=Int BFMCS) should be marked BLOCKED
- Task 987 can proceed via CanonicalMCS path
- Dense/discrete completeness (future tasks) may use different D specializations

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Status Analysis | completed | High |
| B | Alternative Paths | completed | High |

---

## Next Steps

1. **Update task 986 status** to BLOCKED with linearization obstruction documented
2. **Create new task** (or update task 987 plan) for CanonicalMCS-based completeness path
3. **Strengthen `temporal_coherent_family_exists_CanonicalMCS`** to use strict `<`
4. **Wire multi-family modal saturation** for BFMCS CanonicalMCS
5. **Prove CanonicalMCS truth lemma** or generalize existing
6. **Complete algebraic_base_completeness** using the new path

---

## References

### Files Analyzed

| File | Key Content |
|------|-------------|
| `IntBFMCS.lean` | 2 sorries at lines 563, 574; G/H complete |
| `CanonicalFMCS.lean` | Sorry-free `temporal_coherent_family_exists_CanonicalMCS` |
| `AlgebraicBaseCompleteness.lean` | 2 sorries blocking completeness |
| `ParametricRepresentation.lean` | D-parametric conditional theorem |
| `research-006.md` | Prior research confirming obstruction |
| Task 990 synthesis | D-parametric architecture recommendation |

### Prior Research

- research-001 through research-006: Progressive confirmation of linearization obstruction
- Task 990 synthesis: D should be parametric, NOT constructed from syntax
