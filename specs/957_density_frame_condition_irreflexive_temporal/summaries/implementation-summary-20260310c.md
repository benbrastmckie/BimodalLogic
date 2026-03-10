# Implementation Summary: Task #957 (IRR Approach v3)

**Task**: density_frame_condition_irreflexive_temporal
**Status**: [IN PROGRESS]
**Started**: 2026-03-10
**Language**: lean
**Plan**: implementation-003.md (IRR rule approach)

## Phase Log

### Phase 1: Formula.atoms Function [COMPLETED]

**Session**: 2026-03-10, sess_1773185499_957imp
**Duration**: ~10 minutes

**Changes Made**:
- Added `Formula.atoms : Formula -> Finset String` function computing the set of propositional atoms in a formula
- Added `atoms_swap_temporal` lemma proving `phi.swap_temporal.atoms = phi.atoms`

**Files Modified**:
- `Theories/Bimodal/Syntax/Formula.lean` - added atoms function and swap_temporal preservation lemma (~25 lines)

**Verification**:
- Lake build: Success
- Sorries: 0 -> 0 (no new sorries)

### Phase 2: DerivationTree.irr Constructor + Downstream Updates [COMPLETED]

**Session**: 2026-03-10, sess_1773185499_957imp
**Duration**: ~15 minutes

**Changes Made**:
- Added `irr` constructor to `DerivationTree` for the Gabbay IRR (Irreflexivity) rule
- Added `height` case for IRR
- Added `usedFormulas` case for IRR in MaximalConsistent.lean
- Added `usedFormulas_subset` case for IRR
- Added IRR cases to `deduction_with_mem` in DeductionTheorem.lean

**Files Modified**:
- `Theories/Bimodal/ProofSystem/Derivation.lean` - IRR constructor + height case (~20 lines)
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - usedFormulas + usedFormulas_subset (~8 lines)
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - IRR case in deduction_with_mem (~5 lines)

**Verification**:
- Lake build: Success (full build passes)
- Sorries: 0 -> 0 (no new sorries)

### Phase 3: Truth Independence Lemma [COMPLETED]

**Session**: 2026-03-10, sess_1773185499_957imp
**Duration**: ~15 minutes

**Changes Made**:
- Created `Theories/Bimodal/Metalogic/IRRSoundness.lean`
- Proved `truth_independent_of_valuation_change`: if two models agree on all atoms in phi, then phi has the same truth value under both models
- Proof by structural induction on phi (6 cases: atom, bot, imp, box, all_past, all_future)

**Files Created**:
- `Theories/Bimodal/Metalogic/IRRSoundness.lean` - truth independence lemma (~80 lines)

**Verification**:
- Lake build: Success
- Sorries: 0 -> 0 (no new sorries)

## Cumulative Statistics

- Phases completed: 3/5
- Total sorries introduced: 0
- Total sorries removed: 0
- Build status: Passing
