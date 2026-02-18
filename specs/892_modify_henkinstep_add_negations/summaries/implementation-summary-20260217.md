# Implementation Summary: Task #892 - Modify henkinStep to Add Negations

**Status**: BLOCKED - Mathematical Impossibility Discovered
**Date**: 2026-02-17
**Session**: sess_1771374357_3e4c3a

## Executive Summary

Implementation of task 892 was blocked during Phase 1 analysis when a fundamental mathematical flaw was discovered in the target theorem `maximal_tcs_is_mcs`. The theorem claims that a set maximal in TemporalConsistentSupersets (TCS) is a SetMaximalConsistent (MCS). This claim is **false**.

## Discovery

### The Theorem Under Investigation

```lean
lemma maximal_tcs_is_mcs (base : Set Formula)
    (M : Set Formula)
    (h_in_tcs : M ∈ TemporalConsistentSupersets base)
    (h_max : ∀ T ∈ TemporalConsistentSupersets base, M ⊆ T → T ⊆ M) :
    SetMaximalConsistent M
```

### Counterexample

Let `base = {neg(psi)}` where `psi` is an atomic formula.

1. **Henkin construction adds G(psi)**: The temporal package of `G(psi)` is just `{G(psi)}` (no temporal witnesses for G-formulas). The set `{neg(psi), G(psi)}` is consistent because:
   - `neg(psi)` says "psi is false NOW"
   - `G(psi)` says "psi is true at ALL FUTURE times"
   - These are compatible: psi false now, psi true in all futures

2. **F(psi) cannot enter via normal means**:
   - `temporalPackage(F(psi)) = {F(psi), psi}`
   - `S ∪ {F(psi), psi}` is inconsistent (psi and neg(psi))
   - `S ∪ {neg(F(psi))}` is also inconsistent (since `G(psi) → F(psi)` is a theorem)

3. **M maximal in TCS**: Let `M ⊇ {neg(psi), G(psi)}` be maximal in TCS. Then `F(psi) ∉ M` (would break saturation or consistency).

4. **M is NOT maximal consistent**:
   - `M ∪ {F(psi)} = {neg(psi), G(psi), F(psi), ...}` is CONSISTENT
   - Semantic model: psi false at time 0, psi true at times 1, 2, 3, ...
   - This satisfies neg(psi) (false now), G(psi) (true always future), F(psi) (true sometime future)

Therefore, M is maximal in TCS but `insert F(psi) M` is consistent, violating the MCS condition.

## Why the Proposed Fix Cannot Work

The task proposed modifying `henkinStep` to add `neg(phi)` when rejecting packages. This would ensure "negation completeness" where every formula or its negation is in the limit.

However, the counterexample shows a case where:
1. Package `{F(psi), psi}` is inconsistent with S (due to neg(psi))
2. Negation `neg(F(psi))` is ALSO inconsistent with S (due to G(psi) implying F(psi))
3. Neither option can be consistently added

Even with a fallback to add just `{F(psi)}`:
- F(psi) would enter the limit
- psi would NOT be in the limit (its package inconsistent, its negation already present)
- The limit would have F(psi) without psi, breaking temporal saturation

**Core Insight**: Temporal saturation and maximal consistency are CONFLICTING requirements in certain scenarios. The set `{neg(psi), G(psi)}` is temporally saturated (vacuously, since no F-formulas present) but adding F(psi) for completeness requires adding psi (for saturation), which conflicts with neg(psi).

## Impact on Related Tasks

- **Task 888 Phase 3**: This task depends on maximal_tcs_is_mcs being provable. Since the theorem is false, task 888's approach needs revision.
- **temporalLindenbaumMCS**: The main theorem claiming existence of temporally saturated MCS is compromised.

## Recommendations

### Option 1: Strengthen Hypotheses
Add a hypothesis to `maximal_tcs_is_mcs` ruling out the counterexample. For example, require `base` to be "temporally coherent" - if `G(psi) ∈ base` closure, then `psi ∈ base` closure (or similar).

### Option 2: Alternative Construction
Use a different construction that simultaneously ensures:
- Temporal saturation
- Negation completeness (hence MCS)

This likely requires a more sophisticated enumeration that considers formula interactions.

### Option 3: Weaken Main Theorem
Modify `temporalLindenbaumMCS` to claim only temporal saturation, not MCS. The MCS property might require additional axioms or a different approach.

### Option 4: Restrict Domain
Prove the theorem only for specific base sets where the conflict cannot arise. Document the restriction clearly.

## Files Examined

- `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean` - Main file with henkinStep and maximal_tcs_is_mcs
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS definitions and properties
- `Theories/Bimodal/Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` - SetConsistent, SetMaximalConsistent definitions
- `Theories/Bimodal/Theorems/Propositional.lean` - double_negation and related theorems

## Technical Details

### Relevant Definitions

```lean
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)

def TemporalConsistentSupersets (S : Set Formula) : Set (Set Formula) :=
  {T | S ⊆ T ∧ SetConsistent T ∧ TemporalForwardSaturated T ∧ TemporalBackwardSaturated T}

def TemporalForwardSaturated (S : Set Formula) : Prop :=
  ∀ ψ, Formula.some_future ψ ∈ S → ψ ∈ S
```

### Key Temporal Logic Facts Used
- `G(psi) → F(psi)` is a valid theorem (always-future implies sometime-future)
- `F(psi) = neg(G(neg(psi)))` (definitional)
- `neg(psi)` at now is compatible with `G(psi)` (about future)
