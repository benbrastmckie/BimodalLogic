# Implementation Plan: Task #359

**Task**: Complete temporal_duality soundness case
**Version**: 001
**Created**: 2026-01-10
**Language**: lean

## Overview

Complete the `temporal_duality` case in `derivable_implies_swap_valid` (SoundnessLemmas.lean:687) by restructuring to prove both soundness and swap validity simultaneously via mutual induction. This eliminates the circular dependency that prevented completion.

**Core Strategy**: Replace the separate proofs of soundness and swap validity with a single combined theorem `derivable_implies_valid_and_swap_valid` that proves both properties together. In the temporal_duality case, the IH provides `is_valid T ψ' ∧ is_valid T ψ'.swap`, so we can use IH.1 to complete the goal `is_valid T ψ'.swap.swap = is_valid T ψ'`.

## Phases

### Phase 1: Add Combined Theorem

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add the new combined theorem `derivable_implies_valid_and_swap_valid` in SoundnessLemmas.lean
2. Prove all cases including temporal_duality (which now completes via IH.1)
3. Keep existing `derivable_implies_swap_valid` temporarily for backward compatibility

**Files to modify**:
- `Bimodal/Metalogic/SoundnessLemmas.lean` - Add new combined theorem before the existing one

**Steps**:
1. Add the combined theorem signature:
   ```lean
   theorem derivable_implies_valid_and_swap_valid :
       ∀ {φ : Formula}, DerivationTree [] φ →
         (is_valid T φ ∧ is_valid T φ.swap_past_future)
   ```

2. Implement each case of the derivation induction:
   - `axiom`: Use `axiom_valid` and `axiom_swap_valid`
   - `assumption`: Contradiction from `List.not_mem_nil`
   - `modus_ponens`: Use IH.1 for validity, IH.2 with `mp_preserves_swap_valid` for swap
   - `necessitation`: Use IH.1 for validity, `modal_k_preserves_swap_valid` for swap
   - `temporal_necessitation`: Use IH.1 for validity, `temporal_k_preserves_swap_valid` for swap
   - `temporal_duality`: IH.2 for validity of swap, IH.1 + involution for swap of swap
   - `weakening`: Derive Γ' = [] from subset, apply IH

3. Add a helper lemma `axiom_valid` if not already present (check Soundness.lean)

**Verification**:
- Theorem compiles without sorry
- All cases complete with no unsolved goals
- Run `lake build Bimodal.Metalogic.SoundnessLemmas`

---

### Phase 2: Derive Individual Theorems

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Derive `derivable_implies_swap_valid` from the combined theorem
2. Add `soundness_from_empty` as a standalone theorem for empty context soundness

**Files to modify**:
- `Bimodal/Metalogic/SoundnessLemmas.lean` - Replace sorry-containing theorem with derived version

**Steps**:
1. Replace the current `derivable_implies_swap_valid` (with sorry) with:
   ```lean
   theorem derivable_implies_swap_valid :
       ∀ {φ : Formula}, DerivationTree [] φ → is_valid T φ.swap_past_future :=
     fun h => (derivable_implies_valid_and_swap_valid h).2
   ```

2. Add convenience theorem for soundness from empty context:
   ```lean
   theorem soundness_from_empty :
       ∀ {φ : Formula}, DerivationTree [] φ → is_valid T φ :=
     fun h => (derivable_implies_valid_and_swap_valid h).1
   ```

3. Remove the sorry and related comments about circular dependency

**Verification**:
- No sorries in SoundnessLemmas.lean
- Both derived theorems type-check
- Run `lake build Bimodal.Metalogic.SoundnessLemmas`

---

### Phase 3: Verify Soundness.lean Compatibility

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify Soundness.lean still compiles (it uses `derivable_implies_swap_valid`)
2. Optionally simplify Soundness.lean to use the new combined theorem

**Files to modify**:
- `Bimodal/Metalogic/Soundness.lean` - Verify and potentially simplify

**Steps**:
1. Build Soundness.lean to verify backward compatibility:
   ```bash
   lake build Bimodal.Metalogic.Soundness
   ```

2. If beneficial, update the temporal_duality case in soundness to use the combined theorem directly:
   - The existing code at lines 643-669 uses `derivable_implies_swap_valid`
   - This should continue to work since we're keeping the theorem signature

3. Check if any documentation comments need updating

**Verification**:
- `lake build Bimodal.Metalogic.Soundness` succeeds
- No new warnings introduced
- Run full build: `lake build`

---

### Phase 4: Full Build and Cleanup

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Run full project build to verify no regressions
2. Clean up any obsolete comments or documentation
3. Update module docstrings if needed

**Files to modify**:
- `Bimodal/Metalogic/SoundnessLemmas.lean` - Final cleanup
- `Bimodal/Metalogic/Soundness.lean` - Update docstrings if needed

**Steps**:
1. Run full build:
   ```bash
   lake build
   ```

2. Check for any sorry warnings:
   ```bash
   lake build 2>&1 | grep -i sorry
   ```

3. Update the docstring at the top of SoundnessLemmas.lean to reflect:
   - The combined theorem approach
   - That temporal_duality is now fully proven
   - Remove references to circular dependency workarounds

4. Update Soundness.lean docstring (lines 39-49) to mark all cases as complete:
   - Currently says "7/7 soundness cases" - verify this is still accurate
   - Remove any references to sorry or incomplete proofs

**Verification**:
- Full `lake build` succeeds with no errors
- No sorry warnings in output
- Grep for `sorry` in both files shows no remaining instances
- Run tests if available

## Dependencies

- None - this task is self-contained within the Metalogic module

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missing helper lemma (axiom_valid) | Medium | Low | May need to add from Soundness.lean or prove locally |
| IH structure doesn't match expected pattern | Medium | Low | Adjust generalization (Γ = [] constraint) as needed |
| Existing code depends on sorry behavior | Low | Very Low | Unlikely since sorry means incomplete code |
| Build time regression | Low | Low | Combined theorem adds minimal overhead |

## Success Criteria

- [x] No sorries remain in SoundnessLemmas.lean
- [x] No sorries remain in Soundness.lean
- [x] `lake build` completes successfully (core Metalogic module)
- [x] `derivable_implies_swap_valid` and `soundness_from_empty` both compile
- [x] Module docstrings accurately reflect completed state
- [x] Temporal duality soundness is fully proven

## Rollback Plan

If implementation fails:
1. Revert changes with `git checkout -- Bimodal/Metalogic/SoundnessLemmas.lean`
2. The sorry was documented and acceptable as a known limitation
3. Create a follow-up task with findings from the failed attempt
