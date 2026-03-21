# Research Report: Task #616

**Task**: Fix semantic_task_rel_compositionality finite model limitation
**Date**: 2026-01-19
**Focus**: Understanding and resolving the sorry in `semantic_task_rel_compositionality` at SemanticCanonicalModel.lean:236

## Summary

The sorry in `semantic_task_rel_compositionality` is a **mathematically unavoidable limitation** of the finite model construction, not a proof gap that can be closed. The theorem as currently stated is false for unbounded integer durations in a finite time domain. However, this limitation is **acceptable** because the completeness proof does not depend on this lemma.

## Findings

### 1. The Problem: Unbounded Duration Sums in Finite Time Domain

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean:226-236`

**Goal state at line 236**:
```lean
phi : Formula
w u v : SemanticWorldState phi
d1 d2 : Int
h_wu : semantic_task_rel phi w d1 u
h_uv : semantic_task_rel phi u d2 v
-- Goal: semantic_task_rel phi w (d1 + d2) v
```

**The semantic_task_rel definition** (lines 168-173):
```lean
def semantic_task_rel (phi : Formula) (w : SemanticWorldState phi) (d : Int)
    (v : SemanticWorldState phi) : Prop :=
  exists (h : FiniteHistory phi) (t1 t2 : FiniteTime (temporalBound phi)),
    SemanticWorldState.ofHistoryTime h t1 = w and
    SemanticWorldState.ofHistoryTime h t2 = v and
    FiniteTime.toInt (temporalBound phi) t2 - FiniteTime.toInt (temporalBound phi) t1 = d
```

**Why the theorem is false**:
- The finite time domain is bounded: `FiniteTime k` represents integers in `[-k, k]` where `k = temporalBound phi`
- From two times in `[-k, k]`, the maximum difference is `2k` (from `-k` to `k`)
- Thus `d1` and `d2` can each range from `-2k` to `+2k`
- However, `d1 + d2` can range from `-4k` to `+4k`
- For `d1 + d2` outside `[-2k, 2k]`, no witness times exist in the finite domain

**Concrete counterexample** (from old Metalogic documentation):
- Let `k = 1` (temporal bound)
- `d1 = 2` witnessed by `t1 = -1, t1' = 1`
- `d2 = 2` witnessed by `t2 = -1, t2' = 1`
- `d1 + d2 = 4` requires witness times with difference 4, but max difference in `[-1, 1]` is 2

### 2. Impact Assessment: Acceptable Limitation

**Why this sorry is acceptable**:

1. **Completeness proof independence**: The `semantic_weak_completeness` theorem (lines 619-683) is **fully proven without sorry** and does not call `semantic_task_rel_compositionality`. The completeness core works via:
   - Contrapositive construction of countermodel
   - Direct evaluation of `semantic_truth_at_v2` at constructed world states
   - No reliance on compositionality of the task relation

2. **Frame existence suffices**: The `SemanticCanonicalFrame` is only used to instantiate the validity quantifier. The actual truth evaluation uses `FiniteWorldState.models` which doesn't require compositionality.

3. **Practical evaluation bounds**: During formula evaluation, durations that actually arise are bounded by `temporalDepth phi`, so problematic cases don't occur in practice.

4. **Documented in old Metalogic**: The same limitation exists in `FiniteCanonicalModel.lean` (line 1936) with the same analysis.

### 3. Analysis of Three Proposed Solutions

**Option 1: Add a boundedness hypothesis**
```lean
theorem semantic_task_rel_compositionality_bounded (phi : Formula)
    (w u v : SemanticWorldState phi) (d1 d2 : Int)
    (h_wu : semantic_task_rel phi w d1 u)
    (h_uv : semantic_task_rel phi u d2 v)
    (h_bounds : |d1 + d2| <= 2 * temporalBound phi) :
    semantic_task_rel phi w (d1 + d2) v
```

**Verdict**: Technically correct and provable, but changes the theorem statement. This is documented in the old Metalogic as `compositionality_bounded` (lines 1884-1929). Requires constructing witness times via arithmetic.

**Option 2: Change the task relation definition to be closed under composition**
- Make `semantic_task_rel` the transitive closure of the witnessable relation
- Or use an existential definition that doesn't require specific witness times

**Verdict**: Would require significant refactoring. The current definition is intentional - it directly connects to finite model semantics. Changing it could break the truth lemma.

**Option 3: Use a different frame construction**
- Use unbounded time (losing finite model property)
- Or use a cyclic/modular time structure

**Verdict**: Would fundamentally change the Metalogic_v2 architecture. Not recommended as the current design works for completeness.

### 4. Relationship to Other Sorries

**Related sorries in Metalogic_v2**:

| Location | Theorem | Issue | Status |
|----------|---------|-------|--------|
| SemanticCanonicalModel.lean:236 | `semantic_task_rel_compositionality` | Unbounded duration sums | **This task** |
| SemanticCanonicalModel.lean:513 | `semantic_truth_implies_truth_at` | Formula induction bridge | Deprecated approach |
| SemanticCanonicalModel.lean:709 | `main_weak_completeness_v2` | Truth bridge | Deprecated approach |
| FiniteWorldState.lean:343 | `closure_mcs_implies_locally_consistent` | Temporal axioms | See Task 617 |
| Closure.lean:484 | `closure_mcs_neg_complete` | Double negation escape | See Task 615 |

**Key observation**: The deprecated `main_weak_completeness_v2` approach required compositionality via the truth bridge. The current `semantic_weak_completeness` approach bypasses this entirely.

### 5. Mathlib Theorems (Not Applicable)

Searched for relevant Mathlib theorems but none apply because:
- The issue is not arithmetic (omega can handle time bounds)
- The issue is existential witness construction in a bounded domain
- This is a fundamental limitation of the finite model design, not a proof technique gap

### 6. Documentation Quality

The existing docstring (lines 194-224) is **comprehensive and accurate**:
- Explains the mathematical impossibility
- Documents why it's acceptable for completeness
- Lists alternative approaches
- References the old Metalogic location

## Recommendations

### Recommended Approach: Document and Accept

**Do not attempt to prove this theorem as stated** - it is mathematically false.

**Actions to take**:

1. **Keep the current sorry** with its comprehensive documentation
2. **Add a comment** noting that `semantic_weak_completeness` is the recommended completeness path
3. **Optionally implement** `semantic_task_rel_compositionality_bounded` as a useful variant

### Alternative Implementation (Optional)

If a provable variant is desired for other purposes:

```lean
/-- Bounded compositionality: provable when result fits in time domain -/
theorem semantic_task_rel_compositionality_bounded (phi : Formula)
    (w u v : SemanticWorldState phi) (d1 d2 : Int)
    (h_wu : semantic_task_rel phi w d1 u)
    (h_uv : semantic_task_rel phi u d2 v)
    (h_bounds : exists (t t' : FiniteTime (temporalBound phi)),
        FiniteTime.toInt (temporalBound phi) t' - FiniteTime.toInt (temporalBound phi) t = d1 + d2) :
    semantic_task_rel phi w (d1 + d2) v := by
  -- Extract witnesses from h_wu and h_uv
  -- Use h_bounds to construct new witness times
  -- Apply definition of semantic_task_rel
  sorry -- Implementable with time arithmetic
```

## References

- SemanticCanonicalModel.lean lines 168-236 (current implementation)
- SemanticCanonicalModel.lean lines 619-683 (`semantic_weak_completeness` - sorry-free)
- FiniteCanonicalModel.lean lines 1884-1943 (old Metalogic bounded variant)
- Metalogic_v2/README.md (architecture documentation)

## Next Steps

1. No implementation changes needed - the sorry is acceptable
2. If desired, implement the bounded variant as a utility lemma
3. Focus attention on Tasks 615 and 617 which have more tractable sorries
4. The `/plan` command should not be run for this task as no implementation is recommended
