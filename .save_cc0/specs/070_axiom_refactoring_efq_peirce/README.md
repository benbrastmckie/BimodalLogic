# Spec 070: Axiom Refactoring - Replace DNE with EFQ + Peirce's Law

**Status**: Research Complete - Awaiting User Approval  
**Task**: TODO.md Task 43  
**Created**: 2025-12-14  
**Priority**: High (Foundational Change)

## Quick Summary

Replace the `double_negation` axiom (DNE: `¬¬φ → φ`) with two more foundational axioms:
1. **Ex Falso Quodlibet (EFQ)**: `⊥ → φ` - directly characterizes `bot` as absurdity
2. **Peirce's Law**: `((φ → ψ) → φ) → φ` - provides classical reasoning using only implication

**Key Benefit**: Better conceptual modularity while maintaining full derivational equivalence.

## Documents

### Plans
- [001-axiom-refactoring-efq-peirce-plan.md](plans/001-axiom-refactoring-efq-peirce-plan.md) - Complete implementation plan (6 phases, 9-14 hours)

### Reports  
- [001-theoretical-foundations.md](reports/001-theoretical-foundations.md) - Theoretical justification and derivational equivalence proof

### Summaries
- (To be created upon implementation)

## Current Status

**Research Phase**: ✅ Complete  
**Implementation Phase**: ⏸️ Awaiting User Approval

## Key Findings

### Theoretical Soundness ✅
- EFQ + Peirce is **derivationally equivalent** to DNE
- Well-established in logic literature (Mendelson, van Dalen, Prawitz)
- No circular dependencies in derivation

### Implementation Feasibility ✅
- **Low risk**: Fully backwards compatible via derived theorem
- **Moderate effort**: 9-14 hours estimated
- **8 files affected**: Mostly documentation updates

### Benefits ✅
1. **Conceptual clarity**: Separates absurdity characterization (EFQ) from classical logic (Peirce)
2. **Pedagogical value**: Aligns with standard logic textbooks
3. **Future flexibility**: Enables investigation of intuitionistic variants

## Open Questions for User

Before proceeding with implementation, please provide guidance on:

1. **Axiom Naming**: 
   - Proposed: `ex_falso` and `peirce`
   - Alternatives: `efq`, `explosion`, `peirce_law`
   - **Your preference?**

2. **Derived Theorem Naming**:
   - Option A: `double_negation_derived` (makes change explicit)
   - Option B: Keep `double_negation` name (less churn, but theorem not axiom)
   - **Your preference?**

3. **Documentation Depth**:
   - Should we add "Derivable Classical Principles" subsection to Propositional.lean?
   - List DNE, LEM, and other classical theorems derivable from EFQ + Peirce?
   - **Your preference?**

4. **Axiom Ordering**:
   - Proposed: EFQ before Peirce (characterize `bot` first, then add classical logic)
   - **Acceptable?**

5. **Test Coverage**:
   - Option A: Add specific DNE derivation tests
   - Option B: Rely on existing propositional theorem tests
   - **Your preference?**

## Next Steps

Upon user approval:
1. Answer open questions above
2. Execute Phase 1: Add EFQ and Peirce axioms (2-3 hours)
3. Execute Phase 2: Derive DNE theorem (2-3 hours)
4. Execute Phase 3: Remove DNE axiom (1-2 hours)
5. Execute Phase 4: Update documentation (2-3 hours)
6. Execute Phase 5: Verify and test (1-2 hours)
7. Execute Phase 6: Create summary (1 hour)

## Files to be Modified

### Core Implementation (Phase 1-3)
- `Logos/Core/ProofSystem/Axioms.lean` - Add EFQ + Peirce, remove DNE
- `Logos/Core/Metalogic/Soundness.lean` - Add validity proofs, remove DNE case
- `Logos/Core/Theorems/Propositional.lean` - Derive DNE, update theorem proofs
- `Logos/Core/Theorems/Perpetuity/Bridge.lean` - Update dne helper
- `LogosTest/Core/ProofSystem/AxiomsTest.lean` - Update axiom tests

### Documentation (Phase 4)
- `CLAUDE.md` - Update axiom count and list
- `Documentation/UserGuide/ARCHITECTURE.md` - Update axiom specification
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` - Update status
- `TODO.md` - Mark Task 43 complete

## Success Criteria

- ✅ EFQ and Peirce axioms added and proven sound
- ✅ DNE derived as theorem from EFQ + Peirce  
- ✅ All existing proofs compile without changes
- ✅ DNE axiom constructor removed
- ✅ 100% test pass rate maintained
- ✅ Zero lint warnings
- ✅ Documentation comprehensively updated
- ✅ Full backwards compatibility verified

## Risk Assessment

**Overall Risk**: ⚠️ Low-Medium

- **High Risk Items**: None identified
- **Medium Risk**: Complex proofs may need minor adjustments
- **Low Risk**: Documentation drift

**Mitigation**: Incremental phased approach with testing after each phase.

## Contact

For questions or clarifications, refer to:
- Implementation plan: `plans/001-axiom-refactoring-efq-peirce-plan.md`
- Theoretical foundations: `reports/001-theoretical-foundations.md`
