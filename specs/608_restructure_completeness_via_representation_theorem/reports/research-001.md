# Research Report: Task #608

**Task**: 608 - Restructure Completeness via Representation Theorem
**Date**: 2026-01-19
**Session**: sess_1768838897_223d2d
**Focus**: Understanding the reorganization strategy and determining how to proceed given limitations encountered

## Summary

This research analyzes the Metalogic_v2 architecture and the limitations documented in task 470's implementation summary to determine the best path forward for using the representation theorem as the foundation for completeness. The core finding is that **the representation theorem approach is correctly structured but has a truth bridge gap** that prevents direct connection between finite model truth and general validity. Two viable resolution strategies exist: (1) adopt the `semantic_weak_completeness` pattern from the old Metalogic (proven, avoids the bridge), or (2) complete the truth bridge lemma via structural formula induction.

## Context & Scope

### What Was Researched

1. **Metalogic_v2/README.md**: The representation-first architecture design
2. **Task 470 Summary**: Limitations encountered in computational optimization
3. **Current codebase state**: 5 remaining sorries in Metalogic_v2
4. **Old Metalogic approach**: `semantic_weak_completeness` in FiniteCanonicalModel.lean

### Architecture Overview

The Metalogic_v2 follows a representation-first architecture:

```
Application Layer (Completeness, Applications)
          |
          v
       FMP.lean (central hub)
          |
          v
   Representation Layer
   - CanonicalModel.lean
   - TruthLemma.lean
   - RepresentationTheorem.lean
   - ContextProvability.lean
   - FiniteModelProperty.lean
   - SemanticCanonicalModel.lean (sorries here)
          |
          v
       Core Layer
   - MaximalConsistent.lean
   - DeductionTheorem.lean
   - Provability.lean
```

## Findings

### Current State of Sorries

| File | Line | Theorem | Issue |
|------|------|---------|-------|
| Closure.lean | 484 | `closure_mcs_neg_complete` | Double-negation escape |
| SemanticCanonicalModel.lean | 236 | `semantic_task_rel_compositionality` | History gluing |
| SemanticCanonicalModel.lean | 489 | `semantic_truth_implies_truth_at` | Formula induction |
| SemanticCanonicalModel.lean | 656 | `main_weak_completeness_v2` | Truth bridge dependency |
| FiniteWorldState.lean | 343 | `closure_mcs_implies_locally_consistent` | Temporal axioms |

### The Core Problem: Truth Bridge Gap

The completeness proof requires connecting two notions of truth:

1. **`truth_at M tau t phi`** (general): Quantifies over ALL integers and ALL WorldHistories
2. **`w.models phi h_mem`** (finite): Evaluates truth in a finite world state

The bridge lemma `semantic_truth_implies_truth_at` at line 479 of SemanticCanonicalModel.lean has a sorry because:

- **Box case**: `truth_at` quantifies over uncountably many WorldHistories
- **Temporal cases**: `truth_at` quantifies over ALL integers, not just [-k, k]

### The Old Metalogic Solution (Proven)

The old Metalogic in `FiniteCanonicalModel.lean` has a **fully proven** `semantic_weak_completeness` theorem (lines 3644-3713) that avoids the truth bridge:

```lean
def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (FiniteTime.origin) phi) ->
    |- phi
```

**Key insight**: This uses `semantic_truth_at_v2` which is defined internally to the finite model:
```lean
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi) (t : FiniteTime) (psi : Formula) : Prop :=
  exists h_mem : psi in closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem
```

This approach works because:
1. It defines truth directly on `SemanticWorldState`/`FiniteTime` (internal)
2. It proves completeness via contrapositive without going through general `truth_at`
3. The bridge to `valid` becomes a separate concern (and can use the proven result)

### Compositionality Limitation (Task 470 Finding)

The `semantic_task_rel_compositionality` sorry at line 236 is documented as a **known limitation**:

- Finite time domain `[-k, k]` means durations `d1, d2 in [-2k, 2k]`
- Composition `d1 + d2` can reach `[-4k, 4k]`, outside representable range
- **However**: This is acceptable because completeness doesn't directly use this lemma

### Representation Theorem Structure (Correct)

The `RepresentationTheorem.lean` is **fully proven** and provides:
- `representation_theorem`: Consistent context -> satisfiable in canonical world
- `strong_representation_theorem`: Non-derivability -> joint satisfiability
- `completeness_corollary`: valid -> derivable

These work with `CanonicalWorldState` (full MCS) and `canonicalTruthAt` (simple membership).

### ContextProvability (Fully Proven)

The `ContextProvability.lean` achieves completeness via:
```lean
theorem representation_theorem_backward_empty {phi : Formula} :
    semantic_consequence [] phi -> ContextDerivable [] phi := by
  intro h_sem
  have h_valid : valid phi := (Validity.valid_iff_empty_consequence phi).mpr h_sem
  have h_prov : Nonempty (|- phi) := (main_provable_iff_valid_v2 phi).mpr h_valid
  exact h_prov
```

This works because `main_provable_iff_valid_v2` (the theorem with the sorry) provides the `valid -> Nonempty (|- phi)` direction.

## Decisions

### Key Architectural Decision

The Metalogic_v2 correctly identifies the representation theorem as foundational. The issue is not architectural but implementational: the truth bridge between finite and general semantics.

### Recommended Resolution Strategy

**Strategy A (Recommended): Adopt `semantic_weak_completeness` pattern**

Port the proven `semantic_weak_completeness` from old Metalogic:
1. It's already proven (no new sorries needed for core result)
2. It avoids the troublesome truth bridge
3. The existing infrastructure in Metalogic_v2 already has the pieces:
   - `SemanticWorldState` (exists)
   - `semantic_task_rel` (exists, compositionality sorry acceptable)
   - `worldStateFromClosureMCS` (exists)
   - `finite_history_from_state` (exists)

**Strategy B (Alternative): Complete the truth bridge**

Prove `semantic_truth_implies_truth_at` via structural induction:
- Atom: Straightforward - valuation check
- Bot: Trivial - both false
- Imp: IH on subformulas
- Box: Requires showing finite model T-axiom suffices for all histories
- Temporal: Requires showing behavior outside [-k, k] matches finite evaluation

This is harder and less certain to succeed.

## Recommendations

### Priority 1: Port `semantic_weak_completeness`

1. Copy the proven theorem from `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` lines 3644-3713
2. Adapt it to use Metalogic_v2 naming conventions and imports
3. This gives a **fully proven** completeness result with no new sorries

### Priority 2: Clean Up Remaining Sorries

After porting, address remaining sorries:
1. **`closure_mcs_neg_complete`**: Edge case with double-negation escaping closureWithNeg
2. **`closure_mcs_implies_locally_consistent`**: Temporal axiom verification
3. **Compositionality**: Document as acceptable limitation (doesn't affect completeness)

### Priority 3: Deprecate Truth Bridge Approach

Mark `semantic_truth_implies_truth_at` and `main_weak_completeness_v2` as deprecated:
- They represent an alternative approach that requires more work
- The `semantic_weak_completeness` approach is cleaner and proven

### Implementation Plan Outline

**Phase 1**: Port `semantic_weak_completeness` from old Metalogic
- Extract the theorem and supporting lemmas
- Adapt to Metalogic_v2 infrastructure
- Verify with `lake build`

**Phase 2**: Update `main_provable_iff_valid_v2` to use ported theorem
- Replace the sorry-dependent path
- Route through `semantic_weak_completeness`

**Phase 3**: Update documentation
- Update README.md to reflect sorry changes
- Mark deprecated approaches
- Document the architectural decision

**Phase 4**: Clean up edge cases
- Address `closure_mcs_neg_complete` if tractable
- Address `closure_mcs_implies_locally_consistent` if tractable
- Accept compositionality limitation

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Port may introduce new issues | Medium | Test each step with `lake build` |
| `semantic_weak_completeness` dependencies may conflict | Low | Old Metalogic uses similar infrastructure |
| Compositionality sorry affects downstream | Low | Documented as acceptable; not used in completeness |
| Edge case sorries may be unfixable | Medium | Document as known limitations; they don't block main result |

## References

- `Theories/Bimodal/Metalogic_v2/README.md`: Architecture documentation
- `specs/470_finite_model_computational_optimization/summaries/implementation-summary-20260118.md`: Task 470 findings
- `Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`: Proven `semantic_weak_completeness` (lines 3644-3713)
- `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean`: Current implementation with sorries

## Next Steps

1. Create implementation plan (`/plan 608`) that follows the port strategy
2. Start with Phase 1: Port `semantic_weak_completeness`
3. Verify each phase compiles before proceeding
