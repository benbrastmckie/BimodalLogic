# Research Report: Task #829

**Task**: Remove Metalogic Backwards-Compatible Aliases
**Date**: 2026-02-03
**Focus**: Identify all backwards-compatible aliases in Bimodal/Metalogic/ that should be removed for a clean codebase

## Summary

Task 818 added a backwards-compatible alias `semantic_weak_completeness := @fmp_weak_completeness` to ease transition after renaming the main theorem. This research confirms that no active code depends on this alias from the FMP namespace, and identifies one additional alias (`double_negation_elim`) that could be removed but is lower priority.

## Findings

### Primary Alias: semantic_weak_completeness

**Location**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean:448`

```lean
/--
Backwards compatibility alias for `fmp_weak_completeness`.

Use `fmp_weak_completeness` for new code.
-/
noncomputable abbrev semantic_weak_completeness := @fmp_weak_completeness
```

**Dependency Analysis**:

1. **No Active Code Dependencies**: Searching for `semantic_weak_completeness` across the Theories/ directory shows:
   - **27 files mention** the name
   - **0 active imports** of `FMP.semantic_weak_completeness` outside of documentation

2. **All References Are**:
   - Documentation (README.md, .typ files, docstrings)
   - Boneyard code (deprecated Metalogic_v2 has its own `semantic_weak_completeness`)
   - Demo.lean (uses the OLD Metalogic_v2 version from Boneyard, not the FMP alias)

3. **Key Finding**: The `Demo.lean` file imports from `Bimodal.Boneyard.Metalogic_v2.Representation.SemanticCanonicalModel`, which has a DIFFERENT `semantic_weak_completeness` - this is not the FMP alias being removed.

**Safe to Remove**: YES - The FMP alias is purely for hypothetical future consumers that never materialized.

### Secondary Alias: double_negation_elim

**Location**: `Theories/Bimodal/Metalogic/Bundle/Completeness.lean:194`

```lean
/--
Helper: Classical double negation elimination in the proof system.

`|- not not phi -> phi`

NOTE: This is now just an alias for `Bimodal.Theorems.Propositional.double_negation`.
The duplicate definition with `sorry` has been removed.
-/
abbrev double_negation_elim (phi : Formula) : DerivationTree [] (phi.neg.neg.imp phi) :=
  Bimodal.Theorems.Propositional.double_negation phi
```

**Dependency Analysis**:
- Only used internally within `Bundle/Completeness.lean`
- Provides local convenience within the module
- Lower priority than `semantic_weak_completeness`

**Recommendation**: Could be removed but lower impact. Keep focus on `semantic_weak_completeness` for this task.

### Other Abbrevs (Not Aliases)

The following `abbrev` definitions in Metalogic/ are NOT backwards-compatibility aliases - they are legitimate type abbreviations:

| Abbrev | Location | Purpose |
|--------|----------|---------|
| `BoundedTime` | FMP/BoundedTime.lean:64 | Type alias for `Fin (2 * k + 1)` |
| `HistoryTimePair` | FMP/SemanticCanonicalModel.lean:86 | Type alias for pair |
| `Branch` | Decidability/SignedFormula.lean:176 | Type alias for `List SignedFormula` |
| `AlgWorld` | Algebraic/AlgebraicRepresentation.lean:43 | Type alias for `Ultrafilter LindenbaumAlg` |

These should NOT be removed - they improve readability.

## Impact Assessment

### Removing semantic_weak_completeness

**Impact**: MINIMAL

| Category | Impact |
|----------|--------|
| Build | None - no code uses it |
| API stability | None - no external consumers |
| Documentation | Minor updates needed to 4-5 files |

**Documentation to Update**:
1. `FMP/SemanticCanonicalModel.lean` - Remove docstrings mentioning the alias
2. `FMP/README.md` - Remove "also available as..." note
3. `Metalogic/Metalogic.lean` - Remove alias mention from comments
4. `Metalogic/README.md` - Update if it mentions the alias

### Files to Modify

| File | Change |
|------|--------|
| `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` | Remove alias definition (lines 443-448) and update docstrings |
| `Theories/Bimodal/Metalogic/FMP/README.md` | Remove backwards compatibility note (line 33) |
| `Theories/Bimodal/Metalogic/Metalogic.lean` | Remove alias mention (line 114) |

## Recommendations

1. **Remove `semantic_weak_completeness` alias** - Primary objective, safe to do immediately
2. **Update documentation** - Remove all mentions of "backwards compatibility" and the alias
3. **Skip `double_negation_elim`** - Lower priority, can be addressed in a future cleanup task if desired
4. **Preserve type abbreviations** - BoundedTime, HistoryTimePair, Branch, AlgWorld are not aliases and provide value

## Implementation Approach

The implementation is straightforward:

1. Remove the `abbrev semantic_weak_completeness := @fmp_weak_completeness` line
2. Remove the docstring above it
3. Update module header docstrings to remove alias mentions
4. Update README files to remove backwards compatibility notes
5. Run `lake build` to verify no breakage

## References

- Task 818 implementation summary: `specs/818_refactor_bimodal_metalogic_modules/summaries/implementation-summary-20260203.md`
- FMP SemanticCanonicalModel: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`

## Next Steps

Proceed to implementation plan creation. The changes are minimal and well-defined:
- 1 alias definition to remove
- 3-4 documentation strings to update
- Estimated effort: 30 minutes
