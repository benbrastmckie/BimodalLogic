# Research Report: Task #598

**Task**: Remove deprecated helper functions from ContextProvability.lean
**Date**: 2026-01-19
**Focus**: Analyze deprecated helper functions and assess whether they can be safely removed

## Summary

Two deprecated helper functions in `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean` can be safely removed. Both functions are defined but never used anywhere in the codebase. They were deprecated on 2026-01-18 with clear documentation explaining that Strategy C (using `main_provable_iff_valid` directly) supersedes them.

## Findings

### Functions to Remove

#### 1. `semantic_world_validity_implies_provable`

**Location**: Lines 127-133 of ContextProvability.lean

**Type Signature**:
```lean
noncomputable def semantic_world_validity_implies_provable (φ : Formula) :
    (∀ (w : SemanticWorldState φ),
     Bimodal.Metalogic.Completeness.semantic_truth_at_v2 φ w
       (FiniteTime.origin (temporalBound φ)) φ) →
    ⊢ φ
```

**Deprecation Annotation**:
```lean
@[deprecated "Use main_provable_iff_valid directly" (since := "2026-01-18")]
```

**Purpose**: Was a direct application of `semantic_weak_completeness` from FiniteCanonicalModel.lean. Superseded by Strategy C which uses `main_provable_iff_valid` directly.

**Note**: This is a `def` rather than `theorem` because the codomain `⊢ φ` is `Type` (not `Prop`).

#### 2. `semantic_consequence_implies_semantic_world_truth`

**Location**: Lines 149-194 of ContextProvability.lean

**Type Signature**:
```lean
theorem semantic_consequence_implies_semantic_world_truth {φ : Formula} :
    semantic_consequence [] φ →
    ∀ (w : SemanticWorldState φ),
      Bimodal.Metalogic.Completeness.semantic_truth_at_v2 φ w
        (FiniteTime.origin (temporalBound φ)) φ
```

**Deprecation Annotation**:
```lean
@[deprecated "Use representation_theorem_backward_empty directly via Strategy C (main_provable_iff_valid + valid_iff_empty_consequence)" (since := "2026-01-18")]
```

**Purpose**: Was a bridge lemma connecting polymorphic validity to truth in the semantic canonical model. Strategy C bypasses this entirely by going through `valid` as an intermediate step.

### Usage Analysis

**Search Results**:
- `rg "semantic_world_validity_implies_provable|semantic_consequence_implies_semantic_world_truth" --type lean` returns only the definition file
- No qualified references like `Representation.semantic_world_validity` found
- No usages in any importing files:
  - `Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean` - does not use these
  - `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - does not use these
  - `Theories/Bimodal/Metalogic_v2/Representation/RepresentationTheorem.lean` - does not use these
  - `Theories/Bimodal/Metalogic.lean` - imports but does not use these

**Verification**:
- `lean_local_search` confirms these exist only in their definition file
- `lean_diagnostic_messages` shows no errors in the file
- The replacement theorem `representation_theorem_backward_empty` is fully proven and available at line 221

### Why These Were Deprecated

The documentation in the file explains:

1. **Strategy C Adoption**: The completeness proof now uses "Strategy C" which:
   - Converts `semantic_consequence [] φ` to `valid φ` via `valid_iff_empty_consequence`
   - Applies `main_provable_iff_valid` to get `Nonempty (⊢ φ)`
   - Returns as `ContextDerivable [] φ`

2. **Cleaner Proof Path**: Strategy C goes through the `valid` predicate as an intermediate step, avoiding the need for these bridge lemmas.

3. **No Sorry Dependencies**: The new approach is fully proven without sorry placeholders.

### Files That Import ContextProvability

| File | Uses Deprecated Functions |
|------|---------------------------|
| `Metalogic_v2/Completeness/WeakCompleteness.lean` | No - uses `representation_theorem_backward_empty` |
| `Metalogic_v2/Representation/FiniteModelProperty.lean` | No - uses `valid_implies_derivable` |
| `Metalogic_v2/Representation/RepresentationTheorem.lean` | No - uses `Consistent`, `ContextDerivable` |
| `Bimodal/Metalogic.lean` | No - just re-exports |

## Recommendations

1. **Safe to Remove**: Both deprecated functions can be deleted without breaking any code in the codebase.

2. **Implementation Approach**:
   - Delete lines 119-194 (the entire deprecated section including documentation comments)
   - Keep the surrounding code unchanged
   - Run `lake build` to verify no regressions

3. **Preserve Documentation**: The deprecation annotations contain useful historical context about Strategy C. Consider adding a brief comment in the module docstring mentioning the strategy evolution, though this is optional.

4. **No Migration Needed**: Since the functions are unused, no migration or refactoring of dependent code is required.

## References

- Source file: `Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean`
- Replacement theorem: `representation_theorem_backward_empty` (line 221)
- Strategy C documentation: In the docstring of `representation_theorem_backward_empty`
- Related research: `specs/569_analyze_proof_strategy_alternatives/reports/research-002.md`

## Next Steps

1. Run `/plan 598` to create implementation plan for removal
2. Delete the deprecated functions (lines 119-194)
3. Run `lake build` to verify compilation
4. Commit changes with appropriate message
