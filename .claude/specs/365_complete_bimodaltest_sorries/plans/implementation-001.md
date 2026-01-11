# Implementation Plan: Task #365

**Task**: Complete BimodalTest sorries
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

This task resolves 5 sorry placeholders across 3 BimodalTest files, plus fixes ModalS4.lean compilation issues to enable uncommenting ModalS4Test.lean tests. The research identified that some sorries require full proofs, some are logically impossible tests needing redesign, and some require infrastructure that doesn't yet exist. The approach prioritizes quick wins, then moderate-effort proofs, leaving documentation-only tests clearly marked.

## Phases

### Phase 1: Fix ModalS4.lean Compilation and Uncomment Tests

**Status**: [COMPLETED]

**Objectives**:
1. Add `noncomputable` markers to fix compilation errors in ModalS4.lean
2. Uncomment ModalS4Test.lean tests to enable type checking

**Files to modify**:
- `Bimodal/Theorems/ModalS4.lean` - Add noncomputable markers
- `BimodalTest/Theorems/ModalS4Test.lean` - Uncomment test examples

**Steps**:
1. Read ModalS4.lean and identify the two definitions causing compilation errors:
   - `s4_diamond_box_conj` depends on noncomputable `rce_imp`
   - `s5_diamond_conj_diamond` depends on noncomputable `lce_imp`
2. Add `noncomputable` keyword to these definitions
3. Run `lean_diagnostic_messages` to verify no remaining errors
4. Uncomment all test examples in ModalS4Test.lean (lines 32-64)
5. Run `lean_diagnostic_messages` on ModalS4Test.lean to verify tests pass

**Verification**:
- `lake build Bimodal.Theorems.ModalS4` succeeds
- `lake build BimodalTest.Theorems.ModalS4Test` succeeds
- No sorry placeholders in ModalS4.lean or ModalS4Test.lean

---

### Phase 2: Resolve Impossible Test in PerpetuityTest.lean

**Status**: [IN PROGRESS]

**Objectives**:
1. Convert the impossible test at line 69-76 to a parametric form with hypotheses
2. Maintain documentation explaining why the original test was logically unsound

**Files to modify**:
- `BimodalTest/Theorems/PerpetuityTest.lean` - lines 63-76

**Steps**:
1. Read the current test at line 69:
   ```lean
   example : ⊢ ((Formula.atom "p").and (Formula.atom "q")).box := by
     sorry
   ```
2. This attempts to derive `□(p ∧ q)` from empty context - impossible without premises
3. Replace with parametric example demonstrating `box_conj_intro`:
   ```lean
   /--
   Test box_conj_intro with concrete formulas.

   **Note**: Cannot derive `□p` or `□q` from empty context without additional assumptions.
   The parametric form below correctly demonstrates the helper's behavior.
   -/
   example (hp : ⊢ (Formula.atom "p").box) (hq : ⊢ (Formula.atom "q").box) :
       ⊢ ((Formula.atom "p").and (Formula.atom "q")).box :=
     box_conj_intro hp hq
   ```
4. Run `lean_diagnostic_messages` to verify no errors

**Verification**:
- No sorry in PerpetuityTest.lean
- The test now type-checks and demonstrates the intended behavior
- Documentation explains the change

---

### Phase 3: Implement PropositionalTest.lean Proof (Line 193)

**Status**: [NOT STARTED]

**Objectives**:
1. Complete the proof that `[p ∧ q] ⊢ p ∨ r` using available combinators

**Files to modify**:
- `BimodalTest/Theorems/PropositionalTest.lean` - lines 185-193

**Steps**:
1. Analyze the goal: derive `p ∨ r` from context `[p ∧ q]`
2. Use existing theorems:
   - `lce p q` gives `[p ∧ q] ⊢ p`
   - Need to compose with `ldi` which gives `[p] ⊢ p ∨ r`
3. Search for helpers using `lean_local_search` for cut/transitivity lemmas
4. If no direct helper exists, use deduction theorem approach:
   - Check for `ldi_imp : ⊢ p → (p ∨ r)` or similar
   - Compose using `DerivationTree.modus_ponens` in context
5. Implement the proof using available infrastructure:
   ```lean
   example : [(Formula.atom "p").and (Formula.atom "q")] ⊢
             (Formula.atom "p").or (Formula.atom "r") := by
     -- Strategy: lce gives p, then apply ldi_imp or construct disjunction
     have h_p := lce (Formula.atom "p") (Formula.atom "q")
     -- Use ldi_imp if available, otherwise construct via modus_ponens
     <implementation based on available helpers>
   ```
6. If proof requires infrastructure that doesn't exist, update documentation to explain what's needed and mark as pending infrastructure

**Verification**:
- Either: No sorry in PropositionalTest.lean for this example
- Or: Clear documentation explaining what infrastructure is needed

---

### Phase 4: Mark CompletenessTest.lean Consistency Tests as Infrastructure-Pending

**Status**: [NOT STARTED]

**Objectives**:
1. Update documentation for consistency tests (lines 46-83) to clearly explain infrastructure requirements
2. Implement the one test that is possible: inconsistency of `[p, ¬p]` (line 77-83)

**Files to modify**:
- `BimodalTest/Metalogic/CompletenessTest.lean` - lines 39-83

**Steps**:
1. For lines 46-51 (`Consistent []`) and lines 60-65 (`Consistent [p]`):
   - These require proving non-derivability, which needs completeness meta-theory
   - Update documentation to be clearer about why these are infrastructure-pending
   - Keep sorry with clear explanation

2. For lines 77-83 (`¬Consistent [p, ¬p]`):
   - This should be implementable - we need to CONSTRUCT a derivation of ⊥
   - The proof outline:
     a. Assume `h : Consistent [p, ¬p]` (i.e., `¬(Derivable [p, ¬p] ⊥)`)
     b. Construct `d : [p, ¬p] ⊢ ⊥`:
        - Get `p` from context via assumption
        - Get `¬p` from context via assumption
        - Apply modus ponens: `¬p` is `p → ⊥`, so MP gives `⊥`
     c. Apply `h d` to get contradiction
   - Search for assumption/lookup lemmas using `lean_local_search`
   - Implement the proof

3. Run `lean_diagnostic_messages` to verify

**Verification**:
- Line 83 sorry is removed (inconsistency proof completed)
- Lines 51 and 65 sorries remain with improved documentation
- Clear explanation of why consistency proofs need completeness infrastructure

---

### Phase 5: Final Verification and Build

**Status**: [NOT STARTED]

**Objectives**:
1. Verify all changes compile
2. Run full build to check for regressions
3. Update sorry count documentation if needed

**Files to modify**:
- None (verification only)

**Steps**:
1. Run `lake build` for the full project
2. Run `lean_diagnostic_messages` on all modified files:
   - ModalS4.lean
   - ModalS4Test.lean
   - PerpetuityTest.lean
   - PropositionalTest.lean
   - CompletenessTest.lean
3. Count remaining sorries and compare to initial (5 → expected 2-3)
4. Document final state in task summary

**Verification**:
- Full build succeeds
- No new errors introduced
- Sorry count reduced from 5 to 2-3 (consistency proofs remain pending)

---

## Dependencies

- None - all required infrastructure exists in Bimodal/

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| PropositionalTest proof requires missing infrastructure | Medium | Medium | Document as infrastructure-pending instead of blocking |
| Inconsistency proof harder than expected | Low | Low | Research alternative proof strategies using available axioms |
| ModalS4 noncomputable fix causes cascade | Low | Low | The fix is local; test thoroughly before proceeding |

## Success Criteria

- [ ] ModalS4.lean compiles without errors
- [ ] ModalS4Test.lean tests uncommented and passing
- [ ] PerpetuityTest.lean has no sorry (impossible test converted)
- [ ] PropositionalTest.lean sorry resolved or clearly documented
- [ ] CompletenessTest.lean inconsistency proof completed (line 83)
- [ ] Full `lake build` succeeds
- [ ] Total sorries reduced from 5 to 2-3 maximum

## Rollback Plan

Each phase is independent. If a phase fails:
1. Revert changes for that phase only
2. Document why the approach failed
3. Mark that specific test as needs-further-research
4. Proceed with remaining phases
