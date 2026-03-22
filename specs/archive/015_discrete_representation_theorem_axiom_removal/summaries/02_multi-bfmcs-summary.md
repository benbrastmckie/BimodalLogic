# Implementation Summary: Task 15 (Multi-BFMCS Approach)

**Task**: 15 - discrete_representation_theorem_axiom_removal
**Plan Version**: v2 (Multi-Family BFMCS)
**Status**: PARTIAL (modal_backward sorry eliminated; domain transfer gap remains)
**Date**: 2026-03-21

---

## Executive Summary

Task 15 successfully eliminated the impossible `modal_backward` sorry from the discrete
representation theorem infrastructure. The singleton BFMCS approach in `SuccChainBFMCS.lean`
was deprecated and replaced with a multi-family modally saturated construction using
MCS-level saturation from `closedFlags_union_modally_saturated`.

**Key Achievement**: `discreteMCS_modal_backward` is proven **sorry-free** using the
saturation-based contraposition argument. This theorem provides the modal backward
property at the MCS level without requiring the impossible `φ → □φ` axiom.

---

## Phase Completion Summary

| Phase | Name | Status | Notes |
|-------|------|--------|-------|
| 1 | Deprecate Singleton Artifacts | COMPLETED | SuccChainBFMCS.lean deprecated, DiscreteInstantiation decoupled |
| 2 | Multi-Family BFMCS Infrastructure | COMPLETED | Saturation theorems documented, infrastructure re-exported |
| 3 | Witness Family Temporal Coherence | COMPLETED | MCS-level proof eliminates need for family-level construction |
| 4 | Wire to DiscreteInstantiation | PARTIAL | Modal part done; Int domain transfer has F/P dovetailing gap |
| 5 | Documentation and Cleanup | COMPLETED | Summary created, docstrings updated |

---

## Key Artifacts Created/Modified

### Created
- `Theories/Bimodal/Metalogic/Bundle/ModallyCoherentBFMCS.lean` (new)
  - `discreteClosedMCS M0` - Set of all MCS in closedFlags M0
  - `discreteClosedMCS_modally_saturated` - Modal saturation property
  - `discreteMCS_modal_forward` - T-axiom based modal forward
  - `discreteMCS_modal_backward` - **Sorry-free** modal backward via saturation

### Modified
- `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean`
  - Added DEPRECATED banner explaining impossibility
  - Corrected misleading "trivial modal coherence" comments

- `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean`
  - Removed SuccChainBFMCS import
  - Commented out `discrete_representation_unconditional`
  - Updated summary documentation

- `specs/ROAD_MAP.md`
  - Added dead end entry: "Singleton BFMCS for Discrete Representation"

---

## Technical Details

### Why Singleton BFMCS Failed

The singleton BFMCS `modal_backward` required proving:
```
φ ∈ MCS → □φ ∈ MCS
```

This is the **converse of the T-axiom**, which does NOT hold in TM logic for contingent
formulas. An MCS can contain `φ` without containing `□φ`.

**Counterexample**: `{◇p, ¬p, φ}` extends to an MCS where `φ` holds but `□φ` does not.

### How Multi-Family Saturation Works

For a modally saturated set of MCS, `modal_backward` is provable by contraposition:

1. Assume `□φ` not in `M.world` for some M in closed set
2. Then `¬□φ = ◇(¬φ)` is in `M.world` (MCS negation completeness)
3. By modal saturation, exists W in closed set with `¬φ` in `W.world`
4. But `φ` is in ALL W by hypothesis → **contradiction**

This argument requires saturation at the MCS level (which `closedFlags_union_modally_saturated`
provides) but does NOT require different BFMCS families with different `mcs` functions.

### Axiom Verification

```
discreteMCS_modal_backward:
  axioms: [propext, Classical.choice, Quot.sound, ...]
  NO sorryAx!

SingletonBFMCS (deprecated):
  axioms: [..., sorryAx, ...]  <- Still has sorry (expected)
```

---

## Remaining Work

### Domain Transfer Gap (Phase 4)

The `discrete_representation_conditional` theorem requires `BFMCS Int`, but our
construction uses `CanonicalMCS` domain. Full integration requires either:

1. **Option A**: Generalize parametric framework to accept `D = CanonicalMCS`
2. **Option B**: Implement domain transfer via FMCSTransfer with Int retract

Both options face the **F/P dovetailing gap**: the basic Int chain construction
in `IntBFMCS.lean` has sorries for `forward_F` and `backward_P` that require
a dovetailing construction to resolve.

**This is a separate challenge from modal_backward** and represents existing
semantic debt, not new debt introduced by Task 15.

### Recommendation

The modal_backward sorry elimination is complete. The remaining domain transfer
work should be tracked as a separate follow-up task focused on:
- F/P dovetailing chain construction for Int domain
- Integration with AlgebraicBaseCompleteness.lean

---

## Build Verification

```
lake build  # Passes with no errors
discreteMCS_modal_backward  # Verified sorry-free via lean_verify
```

---

## References

- Plan: `specs/015_discrete_representation_theorem_axiom_removal/plans/02_multi-bfmcs-plan.md`
- Research: `specs/015_discrete_representation_theorem_axiom_removal/reports/03_team-research-synthesis.md`
- ROAD_MAP dead end: "Singleton BFMCS for Discrete Representation"
