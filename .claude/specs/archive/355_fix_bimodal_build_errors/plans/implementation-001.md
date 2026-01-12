# Implementation Plan: Task #355

**Task**: Fix all Lean build errors for the Bimodal/ theory
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Fix ~150 build errors in Bimodal/Examples/ files by:
1. Replacing `Derivable.*` with `DerivationTree.*`
2. Adding missing `open` statements for Combinators
3. Fixing `Derivable.modal_k` patterns
4. Adding `noncomputable` markers where needed

## Phases

### Phase 1: Replace Derivable with DerivationTree

**Status**: [NOT STARTED]

**Objectives**:
1. Replace all `Derivable.axiom` with `DerivationTree.axiom`
2. Replace all `Derivable.modus_ponens` with `DerivationTree.modus_ponens`
3. Replace all `Derivable.temporal_duality` with `DerivationTree.temporal_duality`
4. Replace all `Derivable.assumption` with `DerivationTree.assumption`

**Files to modify**:
- `Bimodal/Examples/ModalProofStrategies.lean`
- `Bimodal/Examples/ModalProofs.lean`
- `Bimodal/Examples/TemporalProofStrategies.lean`
- `Bimodal/Examples/TemporalProofs.lean`
- `Bimodal/Examples/BimodalProofStrategies.lean`
- `Bimodal/Examples/BimodalProofs.lean`

**Steps**:
1. Global replace `Derivable.axiom` → `DerivationTree.axiom`
2. Global replace `Derivable.modus_ponens` → `DerivationTree.modus_ponens`
3. Global replace `Derivable.temporal_duality` → `DerivationTree.temporal_duality`
4. Global replace `Derivable.assumption` → `DerivationTree.assumption`

**Verification**:
- Grep for remaining `Derivable.` references

---

### Phase 2: Add Missing Open Statements

**Status**: [NOT STARTED]

**Objectives**:
1. Add `open Bimodal.Theorems.Combinators` to files using `imp_trans`, `identity`, etc.

**Files to modify**:
- All files in `Bimodal/Examples/` that use helper lemmas

**Steps**:
1. Add `open Bimodal.Theorems.Combinators` after existing opens
2. Check if `Bimodal.Theorems.Perpetuity` is already opened

**Verification**:
- Grep for `imp_trans`, `identity` errors after fix

---

### Phase 3: Fix modal_k Pattern

**Status**: [NOT STARTED]

**Objectives**:
1. Replace `Derivable.modal_k` with appropriate pattern using `DerivationTree.necessitation` and axiom

**Files to modify**:
- Files containing `Derivable.modal_k`

**Steps**:
1. Identify modal_k usage patterns
2. Replace with correct construction using necessitation + axiom

**Verification**:
- No remaining `modal_k` errors

---

### Phase 4: Add Noncomputable Markers

**Status**: [NOT STARTED]

**Objectives**:
1. Add `noncomputable` to definitions depending on noncomputable perpetuity theorems

**Files to modify**:
- Files using perpetuity theorems (perpetuity_5, perpetuity_6, etc.)

**Steps**:
1. Run build to identify noncomputable errors
2. Add `noncomputable` keyword to affected definitions

**Verification**:
- No noncomputable errors

---

### Phase 5: Final Verification

**Status**: [NOT STARTED]

**Objectives**:
1. Clean build of Bimodal library

**Steps**:
1. Run `lake build Bimodal`
2. Verify zero errors

**Verification**:
- `lake build Bimodal` succeeds

---

## Dependencies

- Task 352 (rename_logos_core_to_bimodal) - completed
- Task 353 (move_logostest_core_to_bimodaltest) - completed

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Some errors may cascade | Medium | Fix in dependency order |
| ProofSearch API changes | Low | Comment out if needed |

## Success Criteria

- [ ] All Derivable.* replaced with DerivationTree.*
- [ ] All missing identifier errors resolved
- [ ] All noncomputable errors resolved
- [ ] `lake build Bimodal` succeeds with zero errors
