# Implementation Plan: Update LaTeX to use dependent-type conventions for Lean consistency

**Task**: 503 - Update LaTeX to use dependent-type conventions for Lean consistency  
**Session**: ses_1768457639_qizk  
**Language**: markdown  
**Effort**: 4 hours  
**Complexity**: Medium  
**Priority**: Medium  
**Version**: 001  
**Created**: 2026-01-15T06:15:00Z  

## Overview

### Problem Statement
Current LaTeX documentation uses set-theoretic formulations that misalign with Lean's dependent-type implementation. Key issues include representing verifier functions as sets rather than function types, using classical set notation instead of dependent product types, and inconsistent notation between LaTeX and Lean code.

### Scope
Update LaTeX files in Theories/Logos/latex/subfiles/ to use dependent-type theory conventions that align with Lean 4 definitions. Primary focus on converting function type notation from classical `Sⁿ → S` to dependent `(Fin n → S) → S` throughout key files.

### Constraints
- Must maintain mathematical correctness
- Must preserve LaTeX compilation
- Must align with Lean 4 implementation exactly
- Must maintain consistency across all files

### Definition of Done
- All function type notation updated to dependent-type conventions
- All tuple notation replaced with indexed families using lambda notation  
- LaTeX files compile successfully
- Notation matches Lean implementation exactly
- Research findings fully implemented

### Research Integration
This plan integrates findings from 1 research report(s):

**Integrated Reports**:
- **research-001.md** (2025-01-14): Dependent-Type Conventions for LaTeX-Lean Consistency
  - Key Finding: LaTeX uses set-theoretic formulations `Sⁿ → S` while Lean uses dependent `(Fin n → S) → S`
  - Key Finding: Tuple notation `(t₁, ..., tₙ)` should be replaced with indexed families using lambda notation
  - Recommendation: Use `\mathtt{Fin}` for finite type matching Lean exactly
  - Recommendation: Update function symbol interpretations, predicate interpretations, and verification clauses

## Goals and Non-Goals

### Goals
1. Replace classical set notation `Sⁿ → S` with dependent `(Fin n → S) → S` throughout
2. Update predicate interpretation definitions to use proper dependent-type representations  
3. Replace tuple notation `(t₁, ..., tₙ)` with indexed families using lambda notation
4. Update function symbol interpretations
5. Update atomic verification clauses
6. Ensure LaTeX compilation works with new notation

### Non-Goals
1. Changing mathematical semantics (only notation changes)
2. Modifying Lean implementation (only LaTeX updates)
3. Adding new mathematical concepts (notation only)
4. Changing document structure or organization

## Risks and Mitigations

### Risk 1: Reader unfamiliarity with dependent-type notation
**Mitigation**: Include brief explanations when introducing new notation, maintain mathematical clarity

### Risk 2: LaTeX compilation errors from complex notation
**Mitigation**: Test compilation after each major change, use proper LaTeX syntax for dependent types

### Risk 3: Breaking existing cross-references
**Mitigation**: Verify all `\leansrc{}` references remain valid, update any broken references

### Risk 4: Incomplete updates leaving mixed notation
**Mitigation**: Systematic file-by-file approach with validation checkpoints

## Implementation Phases

### Phase 1: Foundation - Update Core Constitutive Definitions
**Status**: [NOT STARTED]  
**Effort**: 1.5 hours  
**Files**: 01-ConstitutiveFoundation.tex  

**Steps**:
1. Update function symbol interpretation notation (Line 71):
   - Replace `\interp{f} : \statespace^n \to \statespace` 
   - With `\interp{f} : (\mathtt{Fin}\;n \to \statespace) \to \statespace`
2. Update predicate interpretation definitions (Lines 72-76):
   - Replace `\statespace^n \to \statespace` in verifier/falsifier function descriptions
   - Use proper dependent-type notation with `\mathtt{Fin}`
3. Update constant notation:
   - Ensure constants use nullary function type: `(\mathtt{Fin}\;0 \to \statespace) \to \statespace`
4. Test LaTeX compilation for updated definitions

**Validation**: LaTeX compiles successfully, dependent-type notation appears correctly

---

### Phase 2: Semantic Integration - Update Verification Clauses  
**Status**: [NOT STARTED]  
**Effort**: 1.5 hours  
**Files**: 01-ConstitutiveFoundation.tex, 03-ExplanatoryExtension-Semantics.tex  

**Steps**:
1. Update term extension definitions (Lines 109-111):
   - Replace function application notation `f(t₁, ..., tₙ)` 
   - With indexed family notation `f (\lambda i : \mathtt{Fin}\;n, t_i)`
2. Update atomic verification clauses (Lines 128-131):
   - Replace tuple notation in verification conditions
   - Use lambda notation for indexed families
3. Update verification condition in 03-ExplanatoryExtension-Semantics.tex:
   - Apply same dependent-type conversion for semantic verification
4. Ensure consistency between both files

**Validation**: Verification clauses use dependent-type notation, LaTeX compiles without errors

---

### Phase 3: Extended Updates - Address Secondary Files
**Status**: [NOT STARTED]  
**Effort**: 1 hour  
**Files**: 02-ExplanatoryExtension-Syntax.tex, 04-ExplanatoryExtension-Axioms.tex  

**Steps**:
1. Scan secondary files for similar patterns:
   - Function type notation `Sⁿ → S`
   - Tuple notation `(t₁, ..., tₙ)`
   - Verification condition patterns
2. Update any found instances using same dependent-type conventions
3. Ensure notation consistency across all files
4. Test complete LaTeX compilation

**Validation**: All files use consistent dependent-type notation

---

### Phase 4: Validation and Documentation
**Status**: [NOT STARTED]  
**Effort**: 0.5 hours  
**Files**: All updated LaTeX files  

**Steps**:
1. Compile complete LaTeX project:
   - Run full compilation sequence
   - Check for any LaTeX errors or warnings
2. Cross-reference validation:
   - Verify all `\leansrc{}` references still work
   - Check against Lean implementation for exact matches
3. Documentation review:
   - Add brief notation explanations where needed
   - Ensure mathematical clarity is maintained
4. Final validation checklist:
   - All `Sⁿ → S` replaced with `(Fin n → S) → S`
   - All tuple notation replaced with indexed families
   - LaTeX compiles successfully
   - Notation matches Lean implementation exactly

**Validation**: Complete LaTeX compilation succeeds, all notation updated correctly

---

## Testing and Validation

### Compilation Testing
- Compile after each phase to catch errors early
- Use standard LaTeX compilation sequence
- Verify no new warnings or errors introduced

### Consistency Testing  
- Cross-reference with Lean implementation files
- Verify exact notation matches
- Check all `\leansrc{}` references remain valid

### Mathematical Validation
- Ensure no semantic changes introduced
- Verify mathematical correctness maintained  
- Check that notation improves rather than obscures meaning

## Artifacts and Outputs

### Primary Artifacts
1. Updated `01-ConstitutiveFoundation.tex` with dependent-type notation
2. Updated `03-ExplanatoryExtension-Semantics.tex` with dependent-type verification clauses  
3. Updated secondary files (if needed)

### Validation Artifacts
1. LaTeX compilation output confirming successful compilation
2. Cross-reference documentation showing Lean-LaTeX alignment
3. Validation checklist confirming all updates completed

## Rollback/Contingency

### If LaTeX Compilation Fails
1. Identify problematic notation syntax
2. Revert to working version for specific section
3. Adjust notation to be LaTeX-compatible while maintaining dependent-type semantics
4. Re-test compilation

### If Cross-Reference Issues Found
1. Document inconsistencies found
2. Adjust LaTeX notation to better match Lean implementation
3. Update `\leansrc{}` references if needed
4. Re-validate alignment

## Success Metrics

### Primary Metrics
- 100% of function type notation updated to dependent-type conventions
- 0 LaTeX compilation errors
- All tuple notation replaced with indexed families
- Exact alignment with Lean 4 implementation

### Secondary Metrics  
- Mathematical clarity maintained or improved
- No semantic changes introduced
- Reader comprehension supported by notation explanations

## Next Steps

1. Execute Phase 1 to update core constitutive definitions
2. Validate compilation after each phase
3. Review and approve notation changes
4. Complete remaining phases sequentially
5. Perform final validation and documentation review