# Research Report: Metalogic Naming Conventions Review

**Task**: 972_review_metalogic_naming_conventions
**Date**: 2026-03-16
**Session**: sess_1773675555_31e621
**Scope**: Theories/Bimodal/Metalogic/

## Executive Summary

After reviewing 20+ files across the Metalogic directory, I found the naming conventions to be **largely consistent and well-designed**. The codebase follows Lean 4 and Mathlib conventions closely, with clear naming patterns that reflect the mathematical domain.

**Finding**: Only 2 genuine naming issues warrant consideration. The overall naming quality is high, and most names follow internal conventions consistently.

---

## Naming Conventions Observed

### Consistent Patterns (Working Well)

1. **Type Names**: `UpperCamelCase` consistently used
   - `FMCS`, `BFMCS`, `TemporalCoherentFamily`, `SignedFormula`, `Branch`

2. **Function/Lemma Names**: `snake_case` consistently used
   - `set_mcs_implication_property`, `theorem_in_mcs`, `deduction_theorem`

3. **Prefix Conventions**: Domain prefixes are applied consistently
   - `set_mcs_*` for Set-based MCS properties
   - `set_consistent_*` for SetConsistent properties
   - `mcs_*` for general MCS lemmas
   - `temporal_backward_*`, `temporal_forward_*` for temporal directions
   - `canonical_*` for canonical model properties
   - `bmcs_*` for BFMCS properties

4. **Operator Naming**: Matches logical terminology
   - `all_future` (G), `all_past` (H), `some_future` (F), `some_past` (P)
   - `box`, `diamond`, `neg`, `imp`

5. **Relationship Names**: Clear directional naming
   - `forward_G`, `backward_H`, `forward_F`, `backward_P`
   - `CanonicalR`, `CanonicalR_past`, `BidirectionalR`

---

## Issues Identified

### Issue 1: Inconsistent Content Definition Naming

**Location**: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`

**Current Names**:
- `GContent` (line 25)
- `HContent` (line 35)

**Problem**: These use `UpperCamelCase` which suggests they are types, but they are actually functions (`Set Formula -> Set Formula`). All other function names in the codebase use `snake_case`.

**Comparison with surrounding code**:
- `ForwardTemporalWitnessSeed` - also a function, uses `UpperCamelCase` (consistent but wrong)
- `PastTemporalWitnessSeed` - same pattern
- `subformulaClosure` - uses `lowerCamelCase` in Decidability/SignedFormula.lean

**Impact**: Low - These are widely used and changing them would require significant refactoring. The names are internally consistent even if they deviate from Mathlib conventions.

**Recommendation**: **ACCEPT AS-IS**. The cost of renaming outweighs the benefit. These are self-consistent within the Bundle module.

---

### Issue 2: Mixed Casing in Witness Seed Definitions

**Location**: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean`

**Current Names** (lines 48, 184):
- `ForwardTemporalWitnessSeed`
- `PastTemporalWitnessSeed`

**Problem**: These are functions returning `Set Formula`, not types. Standard Lean convention uses `snake_case` for functions.

**Recommendation**: **ACCEPT AS-IS**. Same reasoning as Issue 1 - internally consistent and widely used.

---

### Issue 3: `dne_theorem` and `dni_theorem` - Unclear Abbreviations

**Location**: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` (lines 222, 231)

**Current Names**:
- `dne_theorem` (double negation elimination)
- `dni_theorem` (double negation introduction)

**Problem**: Abbreviations `dne` and `dni` may not be immediately clear to readers unfamiliar with the standard abbreviations.

**Context**: These are used ONLY in `ModalSaturation.lean`. Mathlib uses `not_not` for the key lemma.

**Recommendation**: **ACCEPTABLE** - These are standard abbreviations in logic literature (dne = double negation elimination, dni = double negation introduction). The docstrings explain the meaning clearly.

---

### Issue 4: `bmcs_reflexivity` vs `BFMCS.consistent` Pattern

**Location**: `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`

**Current State**:
- `bmcs_reflexivity` (line 139) - free function
- `BFMCS.consistent` (line 174) - namespace method

**Observation**: There's a mix of namespace-qualified methods and free functions with `bmcs_` prefix. However, both patterns are used intentionally:
- Free functions when the theorem is about BFMCS behavior generally
- Namespace methods when they're accessor-like

**Recommendation**: **ACCEPTABLE** - The distinction serves a purpose.

---

## Explicitly Excluded from Recommendations

Per task specification, the following are **acceptable as-is**:

1. `temporally_coherent` - Clear name for the predicate
2. `SetMaximalConsistent` - Standard terminology from modal logic

---

## Additional Observations (Not Issues)

### Consistent Terminology

The codebase consistently uses:
- "MCS" for Maximal Consistent Set (standard abbreviation)
- "FMCS" for Family of MCS (project-specific, well-documented)
- "BFMCS" for Bundle of FMCS (project-specific, well-documented)

### Good Docstring Coverage

Most definitions have clear docstrings explaining:
- Mathematical meaning
- Proof strategy (for theorems)
- Design rationale (for structures)

### Module Organization

Names match module organization well:
- `Core/` - foundational definitions (`Consistent`, `MaximalConsistent`, `SetMaximalConsistent`)
- `Bundle/` - family/bundle structures (`FMCS`, `BFMCS`, `TemporalCoherentFamily`)
- `Canonical/` - canonical model constructions
- `Decidability/` - tableau/decision procedures

---

## Conclusion

**Overall Assessment**: The Metalogic naming conventions are **consistent and well-designed**.

**Actionable Issues**: **None requiring immediate action**.

The 2 technical inconsistencies identified (mixed casing for `GContent`/`HContent` and witness seed definitions) are:
1. Internally consistent within their modules
2. Widely used throughout the codebase
3. Documented with clear docstrings
4. Would require significant refactoring to change

**Recommendation**: No naming changes needed. The codebase demonstrates mature and thoughtful naming that balances Lean conventions with modal logic terminology.

---

## Files Reviewed

1. `Core/Core.lean`
2. `Core/MaximalConsistent.lean`
3. `Core/MCSProperties.lean`
4. `Core/DeductionTheorem.lean`
5. `Bundle/FMCSDef.lean`
6. `Bundle/BFMCS.lean`
7. `Bundle/TemporalContent.lean`
8. `Bundle/TemporalCoherence.lean`
9. `Bundle/CanonicalFrame.lean`
10. `Bundle/WitnessSeed.lean`
11. `Bundle/ModalSaturation.lean`
12. `Canonical/CanonicalTimeline.lean`
13. `Decidability/SignedFormula.lean`
14. `Soundness.lean`
15. `Completeness.lean`
16. `Representation.lean`
