# S5 Modal Coherence Analysis for BFMCS

**Task**: 28 - Correct W=D conflation in BFMCS domain architecture
**Date**: 2026-03-21
**Session**: sess_1774131422_702923
**Focus**: Deep analysis of S5 modal coherence properties and sorry provability

## Executive Summary

**Critical Finding**: The documentation in `DirectMultiFamilyBFMCS.lean` incorrectly claims "TM logic has T and 4 axioms but NOT the 5-axiom." In fact, **TM logic DOES include the full S5 axiom system**, including `modal_5_collapse: Diamond(Box phi) -> Box phi` as a base axiom.

However, the 3 sorries remain unprovable because the S5 axioms alone do not give cross-MCS modal transfer at the object level. The sorries require a semantic property (modal accessibility between MCS) that is not derivable from syntactic S5 axioms applied within individual MCS.

## 1. S5 Axiom Inventory in TM Logic

### Confirmed S5 Axioms (Axioms.lean lines 94-580)

| Axiom | Name | Formula | Status |
|-------|------|---------|--------|
| T | `modal_t` | `Box phi -> phi` | Base axiom |
| 4 | `modal_4` | `Box phi -> Box(Box phi)` | Base axiom |
| B | `modal_b` | `phi -> Box(Diamond phi)` | Base axiom |
| 5 | `modal_5_collapse` | `Diamond(Box phi) -> Box phi` | Base axiom |
| K | `modal_k_dist` | `Box(phi -> psi) -> (Box phi -> Box psi)` | Base axiom |

**Conclusion**: TM logic is a full S5 modal logic. The assertion in DirectMultiFamilyBFMCS that TM "lacks the 5-axiom" is **incorrect**.

### Soundness Verification (Soundness.lean lines 135-145)

```lean
/-- Modal 5 Collapse axiom is valid: Diamond(Box phi) -> Box phi. -/
theorem modal_5_collapse_valid (phi : Formula) : valid (phi.box.diamond.imp phi.box)
```

The axiom is proven sound for task semantics.

## 2. Why the Sorries Remain Unprovable Despite S5

### The Gap: Object-Level vs Semantic Properties

The S5 axioms are **object-level** (syntactic) properties within each MCS:
- `modal_t`: If `Box phi in M`, then `phi in M` (same MCS)
- `modal_4`: If `Box phi in M`, then `Box(Box phi) in M` (same MCS)
- `modal_5_collapse`: If `Diamond(Box phi) in M`, then `Box phi in M` (same MCS)

The BFMCS `modal_forward` requires a **semantic cross-MCS** property:
- If `Box phi in M`, then `phi in M'` (different MCS)

### Why S5 Axioms Don't Give Cross-MCS Transfer

Consider two different MCS: M (where Box phi holds) and M' (target).

**Attempt using 5-collapse**:
1. Have: `Box phi in M`
2. Want: `phi in M'`
3. 5-collapse gives: `Diamond(Box phi) in M' -> Box phi in M'`
4. But we don't have `Diamond(Box phi) in M'` - this requires modal accessibility from M' to M

**The fundamental gap**: Object-level axioms operate WITHIN a single MCS. Cross-MCS transfer requires:
- Either a semantic accessibility relation between MCS
- Or a saturation property that witnesses Diamond formulas across the family

### Modal Saturation Is the Solution

The proven approach (in `ModalSaturation.lean` and `ModallyCoherentBFMCS.lean`) is:

```lean
/-- A BFMCS is modally saturated if every Diamond formula in any family's MCS
    has a witness family where the inner formula holds. -/
def is_modally_saturated (B : BFMCS D) : Prop :=
  forall fam in B.families, forall t, forall psi,
    Diamond psi in fam.mcs t -> exists fam' in B.families, psi in fam'.mcs t
```

With modal saturation, `modal_backward` is provable by contraposition:
1. Assume phi in ALL families at t, but Box phi not in some fam.mcs t
2. By MCS negation: Diamond(neg phi) in fam.mcs t
3. By saturation: exists fam' with neg phi in fam'.mcs t
4. But phi in ALL families, including fam' - contradiction

**But**: The saturation property itself must be proven for the specific BFMCS construction.

## 3. Analysis of Each Sorry

### Sorry 1: modal_forward at t=0 (line 299)

```lean
-- Case: t = 0, different families (w != w')
-- Have: Box phi in w.world (one member of discreteClosedMCS)
-- Need: phi in w'.world (different member of discreteClosedMCS)
sorry
```

**Why unprovable**: Even with S5, `Box phi in w` only gives `phi in w` (T-axiom). The transfer to `phi in w'` requires either:
- w' is modally accessible from w (semantic relation)
- All MCS in discreteClosedMCS share the same modal content (saturation)

**Potential fix**: The `discreteClosedMCS` is modally saturated (`closedFlags_union_modally_saturated`), but this gives Diamond witnesses, not universal Box transfer.

### Sorry 2: modal_forward at t!=0 (line 302)

```lean
-- Case: t != 0
-- Different chains may be completely disjoint
sorry
```

**Why unprovable**: At t!=0, chain positions `intChainMCS w.world w.is_mcs t` may not be in `discreteClosedMCS`. Without closed-set membership, we cannot apply saturation arguments.

**Fundamental blocker**: Lindenbaum chains don't preserve closed-set membership.

### Sorry 3: modal_backward at t!=0 (line 412)

```lean
-- Case: t != 0
-- Chain positions may not be in the closed set
sorry
```

**Why unprovable**: Same issue as Sorry 2. The saturation argument requires coverage of the closed set, which only holds at t=0.

## 4. Documentation Error Analysis

### Incorrect Claims in DirectMultiFamilyBFMCS.lean

**Lines 24-26** (INCORRECT):
```
**Root Cause**: TM logic has T and 4 axioms but NOT the 5-axiom (Euclidean property).
BFMCS `modal_forward` requires: `Box phi in fam.mcs t -> phi in fam'.mcs t` for ALL families.
This is S5 universal accessibility - mathematically unprovable in T4 logic.
```

**Correct statement**: TM logic DOES have the 5-axiom (`modal_5_collapse`). However, the S5 axioms operate within individual MCS. Cross-MCS transfer requires modal saturation at the BFMCS level, not just S5 axioms within MCS.

### Recommended Documentation Fix

Replace lines 24-26 with:

```
**Root Cause**: The BFMCS `modal_forward` condition requires cross-MCS transfer:
  Box phi in fam.mcs t -> phi in fam'.mcs t (for ALL families)
This is a SEMANTIC property requiring modal accessibility between MCS.

TM logic includes full S5 axioms (T, 4, B, 5-collapse), but these operate
WITHIN individual MCS. The 5-collapse axiom (Diamond(Box phi) -> Box phi)
gives internal modal collapse, not cross-MCS transfer.

Cross-MCS transfer requires MODAL SATURATION: every Diamond formula in any
family must have a witness in some other family. At t=0, discreteClosedMCS
provides this via closedFlags_union_modally_saturated. At t!=0, chain
positions may leave the closed set, breaking saturation.
```

## 5. Alternative Approaches

### Approach A: Single-Family Bypass (Recommended)

The Succ-chain infrastructure bypasses BFMCS entirely:
- Single FMCS family (no cross-family coherence needed)
- Direct TaskFrame instantiation via CanonicalTask
- Infrastructure already exists (Tasks 10-14)

**Remaining work**: Wire SuccChainTaskFrame to DiscreteInstantiation.

### Approach B: Shared-MCS Construction

If all families share the same MCS at each time t, cross-family transfer is trivial:
```
fam.mcs t = fam'.mcs t = shared_mcs t
```

**Challenge**: Requires coverage at ALL times, not just t=0.

### Approach C: Weaker BFMCS Requirements

Reformulate BFMCS with weaker modal coherence that doesn't require cross-family transfer:
```lean
-- Weaker: Box distributes over family conjunction
modal_coherent : forall phi t,
  Box phi in (intersection of all fam.mcs t) <->
  (forall fam in families, Box phi in fam.mcs t)
```

**Status**: Not explored. May require semantic changes.

## 6. Recommendations

### For Task 28

1. **Update documentation** to correctly describe the S5 status and the true reason for unprovability
2. **Mark sorries as architecturally blocked**, not "missing S5 axiom"
3. **Recommend Succ-chain bypass** as the primary path for discrete completeness

### For Discrete Completeness

1. **Complete SuccChainTaskFrame.lean** (already exists, verify completeness)
2. **Wire to DiscreteInstantiation** via WorldHistory from SuccChainWorldHistory
3. **Document BFMCS as deprecated** for discrete completeness path

### For Long-term Architecture

1. **Consider removing BFMCS entirely** for discrete case if Succ-chain path works
2. **Retain BFMCS for dense case** (quotient construction) if needed
3. **Document the W vs D distinction** clearly in architecture docs

## 7. File References

| File | Key Content | Status |
|------|-------------|--------|
| `Axioms.lean:157` | `modal_5_collapse` axiom definition | Confirmed S5 |
| `Soundness.lean:136` | `modal_5_collapse_valid` theorem | Proven sound |
| `DirectMultiFamilyBFMCS.lean:24-26` | Incorrect S5 claim | Needs update |
| `ModalSaturation.lean:73-75` | `is_modally_saturated` definition | Correct approach |
| `ModallyCoherentBFMCS.lean:229-273` | `discreteMCS_modal_backward` | Working at t=0 |
| `SuccChainTaskFrame.lean` | TaskFrame Int instantiation | Bypass path |

## 8. Conclusion

The 3 sorries in DirectMultiFamilyBFMCS are unprovable not because TM lacks the 5-axiom (it has it), but because:

1. S5 axioms operate WITHIN individual MCS, not across MCS
2. Cross-MCS transfer requires modal saturation at the BFMCS level
3. Modal saturation holds at t=0 (via discreteClosedMCS) but not at t!=0
4. Chain positions at t!=0 may leave the closed set, breaking saturation

The correct path for discrete completeness is the **Succ-chain bypass**, which uses a single FMCS family and avoids cross-family modal coherence requirements entirely.
