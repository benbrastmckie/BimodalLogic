# Implementation Plan: Task #697

**Task**: 697 - Fix UniversalCanonicalModel.lean compilation error
**Version**: 001
**Created**: 2026-01-28
**Language**: lean
**Session**: sess_1769644214_00ef06

## Overview

Fix the reflexive/irreflexive semantics mismatch in TruthLemma.lean that causes compilation errors. The semantics use `s ≤ t` (reflexive) but the coherence conditions use `s < t` (strict). The fix splits the proof into cases using `eq_or_lt_of_le` and handles the reflexive case (`s = t`) using existing T-axiom closure lemmas.

## Research Summary

From research-001.md and research-002.md:
- **Error locations**: TruthLemma.lean lines 413 and 427
- **Root cause**: Type mismatch between `h_s_lt : s ≤ t` and `backward_H` expecting `s < t`
- **Solution**: Case split on equality vs strict inequality
- **Dependencies available**: `mcs_closed_temp_t_future`, `mcs_closed_temp_t_past` in IndexedMCSFamily.lean:257-296

## Phases

### Phase 1: Fix all_past forward case

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Modify TruthLemma.lean lines 408-415 (all_past forward direction)
2. Add case split using `rcases eq_or_lt_of_le`
3. Handle reflexive case with T-axiom closure lemma
4. Keep strict case with existing coherence condition

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - lines 408-415

**Steps**:
1. Read current code at lines 408-415
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
- Run `lake build Bimodal.Metalogic.Representation.TruthLemma 2>&1 | grep -E "413|all_past"`
- Confirm no error at line 413

---

### Phase 2: Fix all_future forward case

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Modify TruthLemma.lean lines 422-429 (all_future forward direction)
2. Add case split using `rcases eq_or_lt_of_le`
3. Handle reflexive case with T-axiom closure lemma
4. Keep strict case with existing coherence condition

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - lines 422-429

**Steps**:
1. Read current code at lines 422-429
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
- Run `lake build Bimodal.Metalogic.Representation.TruthLemma 2>&1 | grep -E "427|all_future"`
- Confirm no error at line 427

---

### Phase 3: Verify full build

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

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

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `eq_or_lt_of_le` not in scope | Medium | Check imports, add `import Mathlib.Order.Basic` if needed |
| T-axiom lemma signature mismatch | Medium | Verify with `lean_hover_info` before implementing |
| IH application fails | Low | Check `ih` type in goal state |

## Success Criteria

- [ ] TruthLemma.lean compiles without errors at lines 413 and 427
- [ ] UniversalCanonicalModel.lean compiles successfully
- [ ] Full `lake build` for the module succeeds
- [ ] Only expected warnings (backward direction sorries) remain

## Estimated Total Effort

1.25 hours (75 minutes)
- Phase 1: 30 minutes
- Phase 2: 30 minutes
- Phase 3: 15 minutes
