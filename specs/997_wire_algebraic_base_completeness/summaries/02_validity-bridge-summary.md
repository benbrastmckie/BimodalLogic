# Implementation Summary: Task #997

**Completed**: 2026-03-19
**Duration**: ~2 hours
**Status**: PARTIAL - Bridge gap remains

## Overview

This task attempted to wire the algebraic base completeness theorem using the
FlagBFMCS infrastructure. The goal was to connect FlagBFMCS `satisfies_at` to
the canonical `valid` predicate, enabling `valid phi -> Derivable [] phi` using
the sorry-free FlagBFMCS completeness infrastructure.

## Changes Made

### New Files Created

1. **`Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean`**
   - Created validity bridge module connecting FlagBFMCS to standard validity
   - Defined `FlagBFMCS.to_world_state`: Embeds FlagBFMCS positions into ParametricCanonicalWorldState
   - Stated `algebraic_base_completeness_flagbfmcs` theorem (with documented sorry)
   - Documented the architectural gap between FlagBFMCS and TaskFrame semantics

### Files NOT Modified

The following files were NOT changed:
- `AlgebraicBaseCompleteness.lean` - Existing proof structure preserved
- `IntFMCSTransfer.lean` - Existing sorries remain
- `IntBFMCS.lean` - Existing sorries remain

## Results

### What Was Achieved

1. **Bridge module created**: `FlagBFMCSValidityBridge.lean` compiles successfully
2. **Embedding defined**: FlagBFMCS positions map to ParametricCanonicalWorldState
3. **Architecture documented**: Clear explanation of the gap between FlagBFMCS and validity

### What Was NOT Achieved

1. **Sorry not eliminated**: The bridge theorem has a sorry for the FlagBFMCS-to-TaskFrame connection
2. **AlgebraicBaseCompleteness not updated**: Existing sorries remain unchanged
3. **Full proof not completed**: The mathematical gap requires additional infrastructure

## Analysis: Why the Gap Exists

### Type-Theoretic Obstacle

The `valid` definition requires:
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...
```

FlagBFMCS uses `CanonicalMCS` which has:
- `Preorder CanonicalMCS` (via g_content inclusion)
- NO `Zero`, `Add`, `Neg` (no group structure)

Therefore, FlagBFMCS cannot directly instantiate `TaskFrame CanonicalMCS`.

### The Bridge Problem

To connect FlagBFMCS satisfaction to validity, we need one of:

1. **Direct embedding**: Define `FlagBFMCS.toTaskFrame_Int : FlagBFMCS -> TaskFrame Int`
   - Requires mapping CanonicalMCS (uncountable) to Int (countable)
   - Loses information unless using order-embedding tricks

2. **Mediated embedding**: Use BFMCS Int as intermediate
   - This is what `IntFMCSTransfer` does
   - Has sorries at `modal_backward`, `forward_F`, `backward_P`

3. **Alternative validity**: Define validity over FlagBFMCS directly
   - Would require showing equivalence to standard `valid`
   - Same complexity as option 1

### Current Sorry Inventory

| File | Sorry Location | Nature |
|------|----------------|--------|
| FlagBFMCSValidityBridge.lean | `algebraic_base_completeness_flagbfmcs` | Bridge gap |
| IntFMCSTransfer.lean | `singleFamilyBFMCS_Int.modal_backward` | Modal saturation |
| IntBFMCS.lean | `intFMCS_forward_F`, `intFMCS_backward_P` | F/P witnesses |
| AlgebraicBaseCompleteness.lean | `singleFamilyBFMCS`, `construct_bfmcs_from_mcs` | Deprecated |

## Recommendations

### Short-Term

1. **Document current state**: Both approaches (FlagBFMCS and Int-based) have sorries
2. **Keep both paths**: FlagBFMCS is sorry-free for internal completeness
3. **Accept gap**: The validity bridge is a known limitation

### Medium-Term (Task 1004 related)

1. **Dovetailing chain**: Resolve F/P sorries in IntBFMCS via proper dovetailing
2. **Modal saturation**: Use FlagBFMCS's modally_saturated to fix singleFamilyBFMCS_Int

### Long-Term

1. **Unify approaches**: Either prove bridge or accept two completeness theorems
2. **Consider: Is validity connection necessary?** FlagBFMCS completeness is sufficient for many purposes

## Technical Notes

### Key Insight

Both truth lemmas reduce to MCS membership:
- FlagBFMCS: `satisfies_at ... phi <-> phi in (chainFMCS F).mcs x`
- Parametric: `phi in fam.mcs t <-> truth_at ... (parametric_to_history fam) t phi`

The bridge would follow if we could show correspondence of the structures.

### Why FlagBFMCS is Valuable

FlagBFMCS has PROVEN:
- `modally_saturated` (via closedFlags_closed_under_witnesses)
- `temporally_complete` (when using allFlagsBFMCS with Set.univ)
- Full truth lemma (`satisfies_at_iff_mem`)

This is MORE than what IntBFMCS provides (which has sorries).

## Files

- **Created**: `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean`
- **Plan**: `specs/997_wire_algebraic_base_completeness/plans/02_validity-bridge-plan.md`
- **Summary**: `specs/997_wire_algebraic_base_completeness/summaries/02_validity-bridge-summary.md`

## Verification

- [x] `lake build` succeeds
- [x] New module compiles without errors
- [x] One sorry in bridge theorem (documented)
- [x] No new axioms introduced
