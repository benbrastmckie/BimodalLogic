# Implementation Summary: Task #892 - Modify henkinStep to Add Negations

**Status**: PARTIAL - Implementation Attempt with New Discoveries
**Date**: 2026-02-17
**Sessions**:
- sess_1771374357_3e4c3a (earlier session - discovered counterexample)
- sess_1771376322_b2285b (current session - implemented modification, found new issue)

## Executive Summary

The current session (sess_1771376322_b2285b) implemented the henkinStep modification per plan v002, which claimed the earlier counterexample was invalid due to the T-axiom. The modification was successfully made, but a **new issue** was discovered: the modification breaks temporal saturation of henkinLimit.

---

## Current Session (sess_1771376322_b2285b) - Implementation Attempt

### Changes Made

1. **henkinStep Modified** - Added negation fallback:
```lean
noncomputable def henkinStep (S : Set Formula) (φ : Formula) : Set Formula :=
  if SetConsistent (S ∪ temporalPackage φ) then
    S ∪ temporalPackage φ
  else if SetConsistent (S ∪ {Formula.neg φ}) then
    S ∪ {Formula.neg φ}
  else
    S
```

2. **Supporting proofs updated**:
   - `henkinStep_consistent` - handles nested if-then-else
   - `henkinChain_mono` - handles new branch structure

3. **maximal_tcs_is_mcs restructured**:
   - Case 1 (neg(φ) ∈ M): PROVEN via `set_consistent_not_both`
   - Case 2 (neg(φ) ∉ M): PARTIAL - still has sorries

### New Issue Discovered

**The henkinStep modification breaks temporal saturation**:
- When `neg(φ)` is added and `neg(φ) = F(ψ)` (i.e., φ = G(neg(ψ)))
- We add F(ψ) without adding its witness ψ
- henkinLimit loses forward saturation property

This creates 2 new sorries in saturation proofs (lines 494, 542) in addition to the 2 remaining sorries in maximal_tcs_is_mcs (lines 709, 727).

### Current Sorry Count: 4

1. Line 494: `henkinLimit_forward_saturated` - F(ψ) = neg(φ) case
2. Line 542: `henkinLimit_backward_saturated` - P(ψ) = neg(φ) case
3. Line 709: `maximal_tcs_is_mcs` - forward saturation, ψ ∉ M and ψ ≠ φ
4. Line 727: `maximal_tcs_is_mcs` - backward saturation, symmetric

### Build Status

`lake build` succeeds with the 4 sorries noted above.

---

## Previous Session Analysis (Preserved Below)

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
