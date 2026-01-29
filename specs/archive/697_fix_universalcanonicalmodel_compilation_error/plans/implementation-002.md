# Implementation Plan: Task #697

**Task**: 697 - Fix UniversalCanonicalModel.lean compilation error
**Version**: 002
**Created**: 2026-01-29
**Language**: lean
**Session**: sess_1769645235_ede07c

## Revision Context

This plan revises implementation-001.md in light of **Task 726 completion** (Move essential MCS lemmas to Core). The fundamental fix strategy remains unchanged: case split on reflexive/strict inequality using `eq_or_lt_of_le`. The required T-axiom lemmas remain in their original locations.

### What Task 726 Changed
- Created `Core/DeductionTheorem.lean` and `Core/MCSProperties.lean`
- Moved 5 essential MCS lemmas from Boneyard to Core
- Updated imports in IndexedMCSFamily.lean and CoherentConstruction.lean

### What Remains Unchanged
- T-axiom closure lemmas (`mcs_closed_temp_t_future`, `mcs_closed_temp_t_past`) still in IndexedMCSFamily.lean:257-296
- TruthLemma.lean errors at lines 412 and 426 (type mismatch between reflexive semantics and strict coherence)
- Solution approach: case split using `eq_or_lt_of_le`

## Overview

Fix the reflexive/irreflexive semantics mismatch in TruthLemma.lean that causes compilation errors. The semantics use `s ≤ t` (reflexive) but the coherence conditions use `s < t` (strict). The fix splits the proof into cases using `eq_or_lt_of_le` and handles the reflexive case (`s = t`) using existing T-axiom closure lemmas.

## Research Summary

From research-001.md and research-002.md:
- **Error locations**: TruthLemma.lean lines 412 and 426
- **Root cause**: Type mismatch between `h_s_lt : s ≤ t` and `backward_H` expecting `s < t`
- **Solution**: Case split on equality vs strict inequality
- **Dependencies available**: `mcs_closed_temp_t_future`, `mcs_closed_temp_t_past` in IndexedMCSFamily.lean:257-296

## Phases

### Phase 1: Fix all_past forward case

**Status**: [COMPLETED]

**Objectives**:
1. Modify TruthLemma.lean lines 407-414 (all_past forward direction)
2. Add case split using `rcases eq_or_lt_of_le`
3. Handle reflexive case with T-axiom closure lemma
4. Keep strict case with existing coherence condition

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - lines 407-414

**Steps**:
1. Read current code at lines 407-414
2. Change comment from `∀ s < t` to `∀ s ≤ t` (matches semantics)
3. Rename `h_s_lt` to `h_s_le` for clarity
4. Add case split: `rcases eq_or_lt_of_le h_s_le with rfl | h_s_lt`
5. For `rfl` case (s = t):
   - Use `mcs_closed_temp_t_past (family.is_mcs t) psi h_mem` to get `psi ∈ family.mcs t`
   - Apply IH: `exact (ih t).mp h_psi_at_t`
6. For `h_s_lt` case (s < t):
   - Keep existing `family.backward_H t s psi h_s_lt h_mem`
   - Apply IH: `exact (ih s).mp h_psi_in_s`

**Target code**:
```lean
| all_past psi ih =>
  constructor
  · -- Forward: H psi ∈ mcs t → ∀ s ≤ t, truth_at s psi
    intro h_mem s h_s_le
    rcases eq_or_lt_of_le h_s_le with rfl | h_s_lt
    · -- Case s = t: Use T-axiom (Hφ → φ)
      have h_psi_at_t : psi ∈ family.mcs t :=
        mcs_closed_temp_t_past (family.is_mcs t) psi h_mem
      exact (ih t).mp h_psi_at_t
    · -- Case s < t: Use backward_H coherence
      have h_psi_in_s : psi ∈ family.mcs s := family.backward_H t s psi h_s_lt h_mem
      exact (ih s).mp h_psi_in_s
```

**Verification**:
- Run `lake build Bimodal.Metalogic.Representation.TruthLemma 2>&1 | grep -E "412|all_past"`
- Confirm no error at line 412

---

### Phase 2: Fix all_future forward case

**Status**: [COMPLETED]

**Objectives**:
1. Modify TruthLemma.lean lines 421-428 (all_future forward direction)
2. Add case split using `rcases eq_or_lt_of_le`
3. Handle reflexive case with T-axiom closure lemma
4. Keep strict case with existing coherence condition

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - lines 421-428

**Steps**:
1. Read current code at lines 421-428
2. Change comment from `∀ s > t` to `∀ s ≥ t` (matches semantics)
3. Rename `h_t_lt` to `h_t_le` for clarity
4. Add case split: `rcases eq_or_lt_of_le h_t_le with rfl | h_t_lt`
5. For `rfl` case (t = s):
   - Use `mcs_closed_temp_t_future (family.is_mcs t) psi h_mem` to get `psi ∈ family.mcs t`
   - Apply IH: `exact (ih t).mp h_psi_at_t`
6. For `h_t_lt` case (t < s):
   - Keep existing `family.forward_G t s psi h_t_lt h_mem`
   - Apply IH: `exact (ih s).mp h_psi_in_s`

**Target code**:
```lean
| all_future psi ih =>
  constructor
  · -- Forward: G psi ∈ mcs t → ∀ s ≥ t, truth_at s psi
    intro h_mem s h_t_le
    rcases eq_or_lt_of_le h_t_le with rfl | h_t_lt
    · -- Case t = s: Use T-axiom (Gφ → φ)
      have h_psi_at_t : psi ∈ family.mcs t :=
        mcs_closed_temp_t_future (family.is_mcs t) psi h_mem
      exact (ih t).mp h_psi_at_t
    · -- Case t < s: Use forward_G coherence
      have h_psi_in_s : psi ∈ family.mcs s := family.forward_G t s psi h_t_lt h_mem
      exact (ih s).mp h_psi_in_s
```

**Verification**:
- Run `lake build Bimodal.Metalogic.Representation.TruthLemma 2>&1 | grep -E "426|all_future"`
- Confirm no error at line 426

---

### Phase 3: Verify full build

**Status**: [COMPLETED]

**Objectives**:
1. Run full build to verify no new errors introduced
2. Confirm UniversalCanonicalModel.lean compiles
3. Document any remaining warnings (sorries are expected in backward cases)

**Steps**:
1. Run `lake build Bimodal.Metalogic.Representation.UniversalCanonicalModel`
2. Verify build succeeds (exit code 0)
3. Check for any unexpected errors in TruthLemma.lean
4. Document expected warnings (backward direction sorries are intentional)

**Verification**:
- `lake build` succeeds for the module
- No type mismatch errors
- Only expected "declaration uses sorry" warnings for backward direction cases

---

## Dependencies

**Required from Mathlib**:
- `eq_or_lt_of_le` from `Mathlib.Order.Basic` (should be available via existing imports)

**Required from project**:
- `mcs_closed_temp_t_future` (IndexedMCSFamily.lean:257)
- `mcs_closed_temp_t_past` (IndexedMCSFamily.lean:280)

**Post-726 imports**:
No additional imports required. Task 726 reorganized Core but the T-axiom lemmas remain in IndexedMCSFamily.lean.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `eq_or_lt_of_le` not in scope | Medium | Check imports, add `import Mathlib.Order.Basic` if needed |
| T-axiom lemma signature mismatch | Medium | Verify with `lean_hover_info` before implementing |
| IH application fails | Low | Check `ih` type in goal state |

## Success Criteria

- [ ] TruthLemma.lean compiles without errors at lines 412 and 426
- [ ] UniversalCanonicalModel.lean compiles successfully
- [ ] Full `lake build` for the module succeeds
- [ ] Only expected warnings (backward direction sorries) remain

## Changes from v001

1. Updated session ID for v002
2. Added revision context section documenting Task 726 impact
3. Confirmed dependencies unchanged (T-axiom lemmas still in IndexedMCSFamily.lean)
4. Updated line numbers based on current codebase state
5. No changes to fix strategy or implementation approach
