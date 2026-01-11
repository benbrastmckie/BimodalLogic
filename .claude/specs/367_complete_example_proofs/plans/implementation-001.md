# Implementation Plan: Task #367

**Task**: Complete example proofs
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Complete the 24 sorry placeholders in Bimodal/Examples/ files using a prioritized approach: complete ~12 high-value proofs that demonstrate key techniques, and mark the remaining ~12 as explicit exercises with hints for users. This balances pedagogical value with implementation effort.

## Phases

### Phase 1: Complete Trivial Proofs (Category A)

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Complete the 3 trivial sorries using `identity` and `imp_trans`
2. Verify all proofs compile without errors

**Files to modify**:
- `Bimodal/Examples/ModalProofs.lean` - Line 155-160: `φ.box.imp φ.box`
- `Bimodal/Examples/TemporalProofs.lean` - Line 155-158: `all_future.imp all_future`
- `Bimodal/Examples/TemporalProofs.lean` - Line 222-228: T4 chain with `imp_trans`

**Steps**:
1. Open `ModalProofs.lean` and replace sorry at line 160 with `identity φ.box`
2. Open `TemporalProofs.lean` and replace sorry at line 158 with `identity (Formula.atom "p").all_future`
3. Replace sorry at line 228 with `imp_trans h1 h2`
4. Run `lake build Bimodal.Examples.ModalProofs Bimodal.Examples.TemporalProofs` to verify

**Verification**:
- `lean_diagnostic_messages` shows no errors in modified files
- All `example` declarations compile successfully

---

### Phase 2: Complete Generalized Necessitation Proofs (Category B - Select)

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Complete 4 of the 6 Category B proofs using `generalized_modal_k` and `generalized_temporal_k`
2. Mark 2 as exercises

**Files to modify**:
- `Bimodal/Examples/ModalProofStrategies.lean` - Lines 215-229, 396-412
- `Bimodal/Examples/ModalProofs.lean` - Line 174-179
- `Bimodal/Examples/TemporalProofs.lean` - Lines 168-171, 181-183

**Steps**:
1. **ModalProofStrategies.lean:215-229** - Modal modus ponens:
   - Use `generalized_modal_k` to derive `□ψ` from derivation `[φ, φ → ψ] ⊢ ψ`
   - Chain with weakening to eliminate boxed context
2. **ModalProofStrategies.lean:396-412** - Weakening under necessity:
   - Derive `[φ] ⊢ ψ → φ` from prop_s
   - Apply `generalized_modal_k` to get `[□φ] ⊢ □(ψ → φ)`
   - Use deduction theorem to get `⊢ □φ → □(ψ → φ)`
3. **ModalProofs.lean:174-179** - Mark as EXERCISE with hint about `generalized_modal_k`
4. **TemporalProofs.lean:168-171** - Mark as EXERCISE with hint about `generalized_temporal_k`
5. **TemporalProofs.lean:181-183** - Similar to above, mark as EXERCISE

**Verification**:
- Completed proofs compile without errors
- Exercises have clear hints in comments

---

### Phase 3: Complete Modal Distribution Proofs (Category C - Select)

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Complete 2 of the 4 Category C proofs using modal K distribution
2. Mark 2 as advanced exercises

**Files to modify**:
- `Bimodal/Examples/ModalProofStrategies.lean` - Lines 159-176, 237-243
- `Bimodal/Examples/ModalProofs.lean` - Lines 188-191

**Steps**:
1. **ModalProofStrategies.lean:159-176** - `□φ → ◇φ`:
   - Use `imp_trans h3 (box_to_present φ)` pattern
   - Or mark as exercise if proof becomes too complex
2. **ModalProofs.lean:188-191** - `□p ∧ □(p → q) → □q`:
   - Use `Axiom.modal_k_dist` with conjunction elimination
   - Apply modus ponens pattern
3. **ModalProofStrategies.lean:237-243** - Curried modal MP: Mark as EXERCISE
4. **ModalProofStrategies.lean:421-427** - Distribution: Mark as EXERCISE

**Verification**:
- Completed proofs compile without errors
- Modal K axiom applications are pedagogically clear

---

### Phase 4: Mark Remaining as Exercises (Categories D & E)

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Add EXERCISE markers and hints to remaining 11 sorries
2. Ensure hints reference appropriate proof techniques

**Files to modify**:
- `Bimodal/Examples/ModalProofStrategies.lean` - Lines 187-192, 282-288, 314-320
- `Bimodal/Examples/ModalProofs.lean` - Lines 148-152, 162-166, 194-196, 199-202
- `Bimodal/Examples/TemporalProofStrategies.lean` - Lines 332-344, 405-413, 424-428, 479-489, 534-541

**Steps**:
1. For each sorry, add structured comment:
   ```lean
   -- EXERCISE: Complete this proof
   -- Technique: [specific technique from research]
   -- Hint: Use [specific lemma/helper]
   sorry
   ```
2. Group hints by category:
   - Category D: Reference `contraposition`, `diamond_4`, `modal_5`
   - Category E: Reference `perpetuity_*`, `future_k_dist`, `past_k_dist`
3. Update file-level documentation to note exercise sections

**Verification**:
- All exercise markers are consistent in format
- Hints are accurate and reference available lemmas

---

### Phase 5: Documentation and Verification

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update file-level documentation to explain exercise structure
2. Verify all files compile without errors
3. Ensure sorry count is documented

**Files to modify**:
- `Bimodal/Examples/ModalProofs.lean` - Module docstring
- `Bimodal/Examples/ModalProofStrategies.lean` - Module docstring
- `Bimodal/Examples/TemporalProofs.lean` - Module docstring
- `Bimodal/Examples/TemporalProofStrategies.lean` - Module docstring

**Steps**:
1. Add "Exercises" section to each module docstring
2. List which examples are exercises vs completed
3. Run full build: `lake build Bimodal`
4. Verify sorry count matches expected (~12 remaining)

**Verification**:
- `lake build Bimodal` succeeds
- `grep -r "sorry" Bimodal/Examples/` returns ~12 results
- Documentation accurately reflects exercise status

## Dependencies

- Existing `Bimodal.Theorems.Combinators` module (imp_trans, identity)
- Existing `Bimodal.Theorems.GeneralizedNecessitation` module
- Existing `Bimodal.Theorems.Perpetuity` module

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Some proofs harder than expected | Med | Med | Mark as exercise instead of forcing completion |
| Generalized necessitation noncomputable | Low | Low | Use `noncomputable` keyword if needed |
| Import cycle issues | Med | Low | Check imports before adding new dependencies |

## Success Criteria

- [ ] Phase 1: 3 trivial proofs completed
- [ ] Phase 2: 2-4 generalized necessitation proofs completed, rest marked as exercises
- [ ] Phase 3: 2 modal distribution proofs completed, rest marked as exercises
- [ ] Phase 4: All remaining sorries have EXERCISE markers with hints
- [ ] Phase 5: All files compile, documentation updated
- [ ] Final sorry count: ~12 (marked as exercises)
- [ ] `lake build Bimodal` succeeds with no errors

## Rollback Plan

If implementation causes issues:
1. Revert to commit before implementation started
2. All changes are additive (completing sorries, adding comments)
3. No breaking changes to public API expected
