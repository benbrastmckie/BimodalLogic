# Task 43: Axiom Refactoring - READY FOR IMPLEMENTATION

**Status**: ✅ All Planning Complete - Ready to Execute  
**Date**: 2025-12-14  
**Estimated Effort**: 10-15 hours

## User Decisions (All Finalized) ✅

1. **Axiom naming**: `ex_falso` and `peirce` ✅
2. **Derived theorem naming**: Keep `double_negation` (backwards compatible) ✅  
3. **Documentation depth**: YES - Add "Derivable Classical Principles" subsection ✅
4. **Axiom ordering**: YES - EFQ before Peirce ✅
5. **Test coverage**: Specific DNE derivation tests (6 minimum) ✅

## Implementation Phases

### ✅ Phase 0: Research and Planning (COMPLETE)
- Theoretical foundations documented
- Implementation plan created
- User decisions obtained
- No blockers identified

### 🔲 Phase 1: Add New Axioms (2-3 hours)
- Add `ex_falso` axiom constructor
- Add `peirce` axiom constructor  
- Prove soundness for both
- Add axiom tests
- **Deliverable**: Build passes with 14 axioms (13 old + 2 new - 0 removed)

### 🔲 Phase 2: Derive DNE and Add Documentation Section (3-4 hours)
- Add `efq_axiom` and `peirce_axiom` wrappers
- Add "Derivable Classical Principles" section to Propositional.lean
- Derive `double_negation` theorem (7 steps from EFQ + Peirce)
- Update all 20+ uses of `Axiom.double_negation` to use `double_negation` theorem
- Update `dne` helper in Bridge.lean
- **Deliverable**: DNE fully derived, all proofs updated

### 🔲 Phase 3: Remove DNE Axiom (1-2 hours)
- Remove `double_negation` axiom constructor
- Remove `double_negation_valid` soundness proof
- Update axiom tests (remove DNE tests, add note)
- Add 6 DNE derivation tests
- **Deliverable**: Clean build with 14 axioms (EFQ, Peirce, no DNE)

### 🔲 Phase 4: Update Documentation (2-3 hours)
- Update CLAUDE.md (axiom count, list)
- Update ARCHITECTURE.md (axiom specification)
- Update IMPLEMENTATION_STATUS.md (status tracking)
- Update module docstrings
- Mark TODO.md Task 43 complete
- **Deliverable**: All documentation synchronized

### 🔲 Phase 5: Verification and Testing (1-2 hours)
- Clean build from scratch
- Run full test suite (100% pass rate required)
- Run lint (zero warnings required)
- Manual verification checklist
- **Deliverable**: Verified working implementation

### 🔲 Phase 6: Create Summary (1 hour)
- Implementation summary document
- Update spec README
- Note any issues/deviations
- Record actual effort
- **Deliverable**: Complete documentation trail

## Success Criteria (All Required)

- [x] User decisions obtained
- [ ] EFQ and Peirce axioms added and proven sound
- [ ] DNE derived as theorem from EFQ + Peirce (7 steps)
- [ ] All existing proofs compile without breaking changes
- [ ] DNE axiom constructor removed
- [ ] All tests pass (100% pass rate)
- [ ] Zero lint warnings
- [ ] "Derivable Classical Principles" section added
- [ ] 6+ DNE derivation tests added
- [ ] Documentation comprehensively updated (4 files minimum)
- [ ] Full backwards compatibility verified

## Files to Modify (12 total)

### Core Implementation (8 files)
1. `Logos/Core/ProofSystem/Axioms.lean`
2. `Logos/Core/Metalogic/Soundness.lean`
3. `Logos/Core/Theorems/Propositional.lean`
4. `Logos/Core/Theorems/Perpetuity/Principles.lean`
5. `Logos/Core/Theorems/Perpetuity/Bridge.lean`
6. `LogosTest/Core/ProofSystem/AxiomsTest.lean`
7. `LogosTest/Core/Theorems/PropositionalTest.lean`
8. (No changes to ModalS5.lean - uses via helper theorems)

### Documentation (4 files)
9. `CLAUDE.md`
10. `Documentation/UserGuide/ARCHITECTURE.md`
11. `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
12. `TODO.md`

## Risk Assessment

**Overall Risk**: 🟢 LOW

- ✅ No high-risk items
- ✅ No circular dependencies (b_combinator verified)
- ✅ Backwards compatible (derived theorem maintains interface)
- ✅ Incremental phases with testing gates
- ✅ Clear rollback path (git history)

## What to Do Next

When ready to implement:

1. **Read the full plan**: `plans/001-axiom-refactoring-efq-peirce-plan.md`
2. **Start with Phase 1**: Add axioms (don't remove anything yet)
3. **Test after each phase**: Ensure build + tests pass
4. **Follow the order**: Don't skip phases (dependencies exist)
5. **Document issues**: Note any deviations in summary

## Quick Reference

- **Full Plan**: `plans/001-axiom-refactoring-efq-peirce-plan.md` (detailed steps)
- **Theory**: `reports/001-theoretical-foundations.md` (derivation proof)
- **Status**: `README.md` (overview and links)

## Emergency Rollback

If implementation fails:
```bash
git log --oneline  # Find commit before changes
git revert <commit-hash>  # Or git reset --hard <commit-hash>
lake clean
lake build
```

---

**Ready to proceed?** The plan is comprehensive, risks are mitigated, and all decisions are finalized. Implementation can begin when you're ready! 🚀
