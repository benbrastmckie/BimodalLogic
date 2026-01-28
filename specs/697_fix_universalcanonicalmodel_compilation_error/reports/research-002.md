# Research Report: Task #697 - Post-681 Evaluation

**Task**: 697 - Fix UniversalCanonicalModel.lean compilation error
**Date**: 2026-01-28
**Focus**: Evaluate remaining work after Task 681 implementation-006.md completion
**Session**: sess_1769643884_2a79d8

## Executive Summary

After reviewing the implementation of Task 681 (implementation-006.md), **Task 697 still has actionable work that should be completed**. The build is still failing with compilation errors.

### Current Status

```
lake build Bimodal.Metalogic.Representation.UniversalCanonicalModel 2>&1 | grep error
```
Output:
```
error: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:413:72: Application type mismatch
error: Theories/Bimodal/Metalogic/Representation/TruthLemma.lean:427:71: Application type mismatch
error: build failed
```

### Key Finding

**Task 681 addressed documentation and Boneyard organization but did NOT fix the compilation errors.** The reflexive/irreflexive mismatch identified in research-001.md is still present and blocking the build.

## What Task 681 Did

Task 681 (implementation-006.md) focused on:
1. Moving non-essential sorries to Boneyard with documentation
2. Adding "NOT REQUIRED FOR COMPLETENESS" comments
3. Creating Boneyard/Metalogic_v3 directory structure
4. Updating README documentation

**What 681 did NOT do**: Fix the type mismatch in TruthLemma.lean lines 413 and 427.

## What Remains for Task 697

### The Problem (Still Present)

At TruthLemma.lean:413:
```lean
have h_psi_in_s : psi ∈ family.mcs s := family.backward_H t s psi h_s_lt h_mem
```
- `h_s_lt` has type `s ≤ t` (from semantic definition: `∀ s, s ≤ t → truth_at s psi`)
- `family.backward_H` expects `s < t` (strict inequality)

At TruthLemma.lean:427:
```lean
have h_psi_in_s : psi ∈ family.mcs s := family.forward_G t s psi h_t_lt h_mem
```
- `h_t_lt` has type `t ≤ s` (from semantic definition: `∀ s, t ≤ s → truth_at s psi`)
- `family.forward_G` expects `t < s` (strict inequality)

### The Fix (From research-001.md)

Split the proof into cases using `eq_or_lt_of_le`:

**For `all_past` forward (line 410-415)**:
```lean
| all_past psi ih =>
  constructor
  · -- Forward: H psi ∈ mcs t → ∀ s ≤ t, truth_at s psi
    intro h_mem s h_s_le
    rcases eq_or_lt_of_le h_s_le with rfl | h_s_lt
    · -- Case s = t: Use T-axiom
      have h_psi_at_t : psi ∈ family.mcs t :=
        mcs_closed_temp_t_past (family.is_mcs t) psi h_mem
      exact (ih t).mp h_psi_at_t
    · -- Case s < t: Use backward_H coherence
      have h_psi_in_s : psi ∈ family.mcs s := family.backward_H t s psi h_s_lt h_mem
      exact (ih s).mp h_psi_in_s
```

**For `all_future` forward (line 424-429)**:
```lean
| all_future psi ih =>
  constructor
  · -- Forward: G psi ∈ mcs t → ∀ s ≥ t, truth_at s psi
    intro h_mem s h_t_le
    rcases eq_or_lt_of_le h_t_le with rfl | h_t_lt
    · -- Case t = s: Use T-axiom
      have h_psi_at_t : psi ∈ family.mcs t :=
        mcs_closed_temp_t_future (family.is_mcs t) psi h_mem
      exact (ih t).mp h_psi_at_t
    · -- Case t < s: Use forward_G coherence
      have h_psi_in_s : psi ∈ family.mcs s := family.forward_G t s psi h_t_lt h_mem
      exact (ih s).mp h_psi_in_s
```

### Dependencies

The T-axiom closure lemmas already exist in IndexedMCSFamily.lean:257-296:
- `mcs_closed_temp_t_future`: `Gφ ∈ Gamma ∧ SetMaximalConsistent Gamma → φ ∈ Gamma`
- `mcs_closed_temp_t_past`: `Hφ ∈ Gamma ∧ SetMaximalConsistent Gamma → φ ∈ Gamma`

The `eq_or_lt_of_le` lemma is from Mathlib.Order.Basic.

## Recommendation

**Task 697 should be PLANNED and IMPLEMENTED, not abandoned.**

The fix is straightforward:
1. Modify TruthLemma.lean lines 410-415 and 424-429
2. Add case split using `eq_or_lt_of_le`
3. Use existing T-axiom closure lemmas for reflexive case
4. Keep coherence conditions for strict case
5. Verify build passes

**Estimated effort**: 1-2 hours (simple code modification, verification)

## Alternative: Abandon with Documented Gaps

If the project accepts having sorries in TruthLemma forward direction, the fix could be replaced with:
```lean
| all_past psi ih =>
  constructor
  · -- Forward: H psi ∈ mcs t → ∀ s ≤ t, truth_at s psi
    intro h_mem s h_s_le
    -- Type mismatch between reflexive semantics (s ≤ t) and strict coherence (s < t)
    -- Would need case split on s = t vs s < t, using T-axiom for reflexive case
    sorry
```

**However, this would break the completeness theorem chain**, since `truth_lemma_forward` is used by `representation_theorem` (UniversalCanonicalModel.lean:87).

## Conclusion

**Task 697 has real, actionable work remaining** that was not addressed by Task 681. The compilation errors are blocking the full completeness proof chain. The fix is well-understood and involves minimal code changes.

**Recommendation**: Mark Task 697 as ready for planning/implementation, not abandonment.

## References

- TruthLemma.lean lines 408-435 (current code with errors)
- IndexedMCSFamily.lean lines 257-296 (T-axiom closure lemmas)
- research-001.md (detailed analysis of the type mismatch)
- implementation-006.md (Task 681's scope - documentation only)
