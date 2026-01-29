# Research Report: Task #750

**Task**: Refactor forward Truth Lemma to remove sorries and eliminate backward direction
**Date**: 2026-01-29
**Focus**: Investigate forward Truth Lemma sorries and determine refactoring approach

## Summary

The current TruthLemma.lean uses a mutual induction strategy with 4 sorries. The forward imp case fundamentally requires the backward IH, making it impossible to eliminate sorries without restructuring the proof to use a different approach. Two viable refactoring paths exist: (1) forward-only induction with propositional case analysis, or (2) adopting the semantic truth approach from SemanticCanonicalModel.lean which is already sorry-free for completeness.

## Findings

### Current Architecture

**File**: `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

The Truth Lemma uses mutual induction to prove:
```lean
theorem truth_lemma_mutual (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at (canonical_model D family) (canonical_history_family D family) t phi
```

**Current Sorries (4 total)**:

| Case | Direction | Location | Reason |
|------|-----------|----------|--------|
| `box` | Forward | Line 366 | Architectural: requires truth for ALL histories, not just canonical |
| `box` | Backward | Line 389 | Architectural: psi in MCS does not imply box psi in MCS |
| `all_past` | Backward | Line 416 | Omega-rule: requires deriving H from infinitely many psi instances |
| `all_future` | Backward | Line 438 | Omega-rule: symmetric to all_past case |

### Why the Forward Imp Case Needs Backward IH

The forward imp case (lines 269-278) follows this reasoning:
1. Given `(psi → chi) ∈ mcs t` and need to show `truth_at psi → truth_at chi`
2. **Backward IH on psi**: Convert `truth_at psi` to `psi ∈ mcs t`
3. MCS modus ponens: From `(psi → chi) ∈ mcs t` and `psi ∈ mcs t`, get `chi ∈ mcs t`
4. **Forward IH on chi**: Convert `chi ∈ mcs t` to `truth_at chi`

Without the backward IH in step 2, we cannot use MCS modus ponens closure.

### Alternative Approach 1: Forward-Only with Case Analysis

**Strategy**: Replace backward IH usage with direct propositional reasoning.

For the imp case forward direction:
1. Given `(psi → chi) ∈ mcs t` and `truth_at psi`
2. By MCS negation completeness, either `psi ∈ mcs t` or `psi.neg ∈ mcs t`
3. If `psi ∈ mcs t`: Use MCS modus ponens to get `chi ∈ mcs t`, then forward IH
4. If `psi.neg ∈ mcs t`:
   - Need to derive contradiction from `truth_at psi` and `psi.neg ∈ mcs t`
   - This requires connecting semantic truth back to MCS membership
   - **Problem**: This is exactly the backward direction we're trying to avoid

**Verdict**: The fundamental issue is that propositional case analysis on `psi` vs `psi.neg` membership still requires connecting semantic truth to MCS membership.

### Alternative Approach 2: Adopt SemanticCanonicalModel Approach

**File**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

The FMP infrastructure has a completely different truth lemma:
```lean
theorem semantic_truth_lemma_v2 (phi : Formula) (w : SemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    (SemanticWorldState.toFiniteWorldState w).models psi h_mem ↔
    semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) psi
```

**Key Insight**: This approach works because:
1. World states ARE defined by MCS membership (FiniteWorldState is a ClosureMCS)
2. The `models` predicate is defined by MCS membership
3. No separate "truth_at" predicate needs to be connected to MCS

**Status**: `semantic_weak_completeness` is PROVEN (no sorry) using this approach.

### Dependencies Analysis

**What uses truth_lemma_forward**:

1. `UniversalCanonicalModel.lean`:
   - `representation_theorem` calls `(truth_lemma ℤ family 0 phi).mp`
   - This is the forward direction only

2. `WeakCompleteness.lean`:
   - Uses `representation_theorem`
   - Does NOT directly call truth_lemma

**What would break if backward direction removed**:
- Nothing critical - the representation theorem only uses `.mp` (forward)
- `truth_lemma_backward` is exported but no active code uses it

### The Fundamental Issue

The mutual induction is not an arbitrary choice - it's mathematically necessary because:

1. **Imp forward** genuinely needs backward IH to use MCS modus ponens
2. **Without backward direction**: Cannot connect `truth_at psi` back to `psi ∈ mcs`
3. **No alternative propositional reasoning** avoids this requirement

The only way to avoid backward direction entirely is to use an approach like SemanticCanonicalModel where the world state IS the MCS projection, making the "truth lemma" trivial by construction.

### Comparison: Two Completeness Paths

| Aspect | TruthLemma.lean (Indexed Family) | SemanticCanonicalModel.lean |
|--------|----------------------------------|----------------------------|
| Sorries | 4 (box + temporal backward) | 1 (compositionality frame axiom) |
| Completeness result | representation_theorem (2 sorries) | semantic_weak_completeness (0 sorries) |
| Architecture | Unbounded time domain (D any ordered group) | Bounded time domain [-k, k] |
| World definition | Arbitrary MCS | Closure MCS quotient |
| Modal operators | Problematic (universal history quantification) | Not addressed (closure-bounded) |

## Recommendations

### Option A: Migrate to Semantic Approach (Recommended)

1. Recognize that `semantic_weak_completeness` already provides sorry-free completeness
2. Deprecate the indexed family truth lemma for completeness purposes
3. Keep TruthLemma.lean for theoretical reference but not as primary completeness path
4. Update documentation to clarify the two approaches

**Effort**: Low (documentation changes, no proof work needed)
**Result**: Sorry-free completeness via existing `semantic_weak_completeness`

### Option B: Restructure with Models-Based Definition

1. Redefine canonical world states so that truth IS MCS membership
2. This eliminates the gap between "truth_at" and "MCS membership"
3. Similar to SemanticCanonicalModel but for unbounded time domain

**Effort**: High (significant proof restructuring)
**Result**: Could potentially reduce sorries but box case remains problematic

### Option C: Accept Current Architecture

1. The 4 sorries in TruthLemma.lean are well-documented as architectural limitations
2. They do NOT affect completeness (representation_theorem uses only forward direction)
3. The "sorry-free completeness" goal is already achieved via `semantic_weak_completeness`

**Effort**: None (documentation clarification only)
**Result**: Acknowledge sorry-free path exists in FMP infrastructure

## Critical Insight

**Task 745 Summary stated**: "The 4 sorries in TruthLemma.lean are NOT required for completeness - the representation theorem only uses `truth_lemma_forward` (the `.mp` direction)."

This is accurate but incomplete. The representation_theorem itself has 2 sorries for h_no_G_bot and h_no_H_bot. The truly sorry-free completeness path is `semantic_weak_completeness` in SemanticCanonicalModel.lean.

## References

- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Current mutual induction approach
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Sorry-free alternative
- `specs/745_move_backward_truth_lemma_to_boneyard/summaries/implementation-summary-20260129.md` - Task 745 context

## Next Steps

1. Decide which option to pursue (A recommended for minimal effort, maximum clarity)
2. If Option A: Update CLAUDE.md to document the two completeness paths
3. If Option B: Create detailed implementation plan for models-based restructuring
4. Verify that downstream consumers (WeakCompleteness.lean) can migrate to semantic approach
