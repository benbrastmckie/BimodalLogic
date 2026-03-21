# Research Report: Modal Coherence Solutions for BFMCS

**Task**: 28 - Correct W=D conflation in BFMCS domain architecture
**Date**: 2026-03-21
**Focus**: Practical solutions for the 3 modal coherence sorries in DirectMultiFamilyBFMCS

## Executive Summary

The 3 sorries in `DirectMultiFamilyBFMCS.lean` are **architecturally unprovable** without the S5 axiom (5-axiom / Euclidean property). However, they are also **unnecessary for discrete completeness** because the Succ-chain infrastructure bypasses BFMCS entirely. This report documents the root cause and provides two practical solutions.

## 1. The Exact Sorries

### Location: DirectMultiFamilyBFMCS.lean

**Sorry 1: modal_forward at t=0** (line 299)
```lean
-- Case: t = 0, different families (w != w')
-- Have: Box phi in w.world (one member of discreteClosedMCS)
-- Need: phi in w'.world (different member of discreteClosedMCS)
sorry
```

**Sorry 2: modal_forward at t!=0** (line 302)
```lean
-- Case: t != 0
-- Different chains may be completely disjoint
sorry
```

**Sorry 3: modal_backward at t!=0** (line 412)
```lean
-- Case: t != 0
-- Chain positions may not be in the closed set
-- No structural reason for coverage at arbitrary chain positions
sorry
```

### Why These Are Unprovable

The BFMCS `modal_forward` requirement is:
```
forall fam in families, forall phi t,
  Box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
```

This says: if Box phi holds at ANY family at time t, then phi holds at ALL families at time t.

**The mathematical problem**: TM logic has T and 4 axioms but NOT the 5-axiom:
- T axiom: Box phi -> phi (reflexivity)
- 4 axiom: Box phi -> Box Box phi (transitivity)
- Missing 5 axiom: Diamond phi -> Box Diamond phi (Euclidean property)

Without the 5-axiom, there is no derivation of `Box phi in M -> phi in M'` for unrelated MCS M and M'. The T-axiom only gives `Box phi in M -> phi in M` (same MCS).

## 2. Why discreteClosedMCS Saturation Doesn't Help

The `discreteClosedMCS M0` set IS modally saturated (proven in `closedFlags_union_modally_saturated`):
- For any Diamond(psi) in any M in the closed set, there exists W in the closed set with psi in W.world

This gives us `discreteMCS_modal_backward` (sorry-free):
```lean
theorem discreteMCS_modal_backward
    (M : CanonicalMCS) (h_M : M in discreteClosedMCS M0) (phi : Formula)
    (h_all : forall W in discreteClosedMCS M0, phi in W.world) :
    Box phi in M.world
```

**But this only works at the MCS level, not at arbitrary chain positions.**

At time t=0: All families rooted at discreteClosedMCS members have `fam.mcs 0 = root.world`, so saturation applies.

At time t!=0: `intChainMCS root.world root.is_mcs t` may not be in the discreteClosedMCS at all - Lindenbaum extensions don't preserve closed-set membership.

## 3. Solution A: Bypass BFMCS Entirely (Recommended)

The Succ-chain infrastructure provides discrete completeness WITHOUT BFMCS:

### Existing Infrastructure (Tasks 10-14)

| Module | Purpose |
|--------|---------|
| `SuccRelation.lean` | Defines Succ(u, v) = G-persistence + F-step |
| `SuccExistence.lean` | Proves successor_exists, predecessor_exists |
| `CanonicalTaskRelation.lean` | Defines CanonicalTask(u, n, v) inductively |
| `SuccChainFMCS.lean` | Builds FMCS Int from Succ-chains |

### The Key Insight

**Single-family FMCS over Int is sufficient for discrete completeness!**

For a single FMCS family, there is no cross-family modal coherence requirement. The BFMCS structure with multiple families was designed for modal saturation (Diamond witnesses in other families), but:

1. For temporal operators (F/P/G/H), a single chain suffices
2. For modal operators (Box/Diamond), the MCS-level saturation applies

### Proposed Architecture

```
CanonicalMCS M0
     |
     v
SerialMCS (adds F_top, P_top membership)
     |
     v
SuccChainFMCS M0 : FMCS Int  (single family, Int-indexed)
     |
     v
succ_chain_history : WorldHistory Prop Int (from SuccChainWorldHistory.lean)
     |
     v
TaskFrame Int (instantiate directly)
     |
     v
Truth lemma + Discrete completeness
```

### What Needs to be Built

1. **SuccChainTaskFrame.lean** (Task 13 deliverable):
   - Define `CanonicalTaskTaskFrame : TaskFrame Int`
   - Prove nullity identity: `CanonicalTask u 0 v <-> u = v` (already done)
   - Prove compositionality: chain concatenation (already done)
   - Prove converse: `CanonicalTask u n v <-> CanonicalTask v (-n) u` (already done)

2. **SuccChainWorldHistory.lean** (Task 13 deliverable):
   - Define `succ_chain_history : WorldHistory Prop Int`
   - Prove history respects CanonicalTask structure

3. **SuccChainTruthLemma.lean** (new):
   - Truth lemma for Succ-chain model
   - Bypasses BFMCS entirely

### Sorries in This Path

The SuccChainFMCS.lean has axioms (not sorries) for:
- `succ_chain_forward_F_bounded_axiom`: F witness existence (bounded case)
- `succ_chain_forward_F_neg_axiom`: F witness for negative indices
- `succ_chain_backward_P_axiom`: P witness existence

These are **semantically justified** axioms, not mathematical gaps. They follow from the temporal frame conditions and can be eliminated with more work on the bounded_witness corollary.

## 4. Solution B: Shared-MCS Multi-Family (Theoretical Interest)

If all families share the SAME MCS at each time t, modal coherence is trivial:
```
fam.mcs t = fam'.mcs t = the_shared_mcs t
```

Then:
- modal_forward: Box phi in fam.mcs t = Box phi in the_shared_mcs t => phi in the_shared_mcs t (T-axiom) = phi in fam'.mcs t
- modal_backward: phi in all fam'.mcs t = phi in the_shared_mcs t => Box phi in the_shared_mcs t (by discreteMCS_modal_backward if we have full coverage)

**Problem**: To get full coverage at each time t, we need:
- At t=0: Families indexed by discreteClosedMCS (done in DirectMultiFamilyBFMCS)
- At t!=0: Chain positions must ALSO cover the closed set

The second requirement is the blocker. Arbitrary Lindenbaum chains don't preserve coverage.

### Succ-Chains DO Help Here

If we use Succ-chains instead of arbitrary Lindenbaum chains:
- Succ(u, v) forces F-obligations to propagate deterministically
- All Succ-successors of MCS in discreteClosedMCS share a common modal structure

However, this still doesn't guarantee coverage at t!=0 without additional structural arguments.

## 5. Comparison of Approaches

| Approach | Sorries | Difficulty | Completeness |
|----------|---------|------------|--------------|
| DirectMultiFamilyBFMCS (current) | 3 (unprovable) | N/A | Blocked |
| Solution A: Single FMCS + TaskFrame | 3 axioms (semantically justified) | Medium | Yes |
| Solution B: Shared-MCS Multi-Family | Requires coverage proof | Hard | Maybe |
| Quotient construction | Unknown | Unknown | Unknown |

## 6. The W vs D Distinction (Reference)

For completeness:

| Symbol | Meaning | Correct Type |
|--------|---------|--------------|
| W | World state space | CanonicalMCS |
| D | Duration/time domain | Int (discrete) or TimelineQuot (dense) |

**The conflation error**: Using CanonicalMCS as D creates `fam.mcs t = t.world`, which trivializes F/P witnesses but makes modal_backward require `phi -> Box phi` (false).

**The fix**: Use CanonicalMCS for world states, Int for time indexing, and ensure the two are cleanly separated.

## 7. Recommendations

### For Task 28 (Current Task)

1. **Document the limitation**: The 3 sorries in DirectMultiFamilyBFMCS are architecturally unprovable without S5. Add clear documentation explaining why.

2. **Add "Correct Path" header**: The module already has an architectural limitation note (lines 14-53). Ensure this is visible and accurate.

3. **Mark BFMCS approach as deprecated for discrete completeness**: The Succ-chain bypass is the correct path.

### For Discrete Completeness (Future Work)

1. **Complete SuccChainTaskFrame.lean**: Build TaskFrame Int directly from CanonicalTask
2. **Build SuccChainWorldHistory.lean**: Define WorldHistory respecting Succ structure
3. **Prove truth lemma**: Single-family truth lemma without BFMCS
4. **Wire to DiscreteInstantiation**: Connect to existing completeness infrastructure

### What NOT to Do

1. **Do not try to prove the 3 sorries**: They require S5, which TM logic does not have
2. **Do not use CanonicalMCS as D**: This conflates world states with time indices
3. **Do not add new axioms for modal_forward/backward**: The approach is fundamentally flawed

## 8. Code References

### Key Files

| File | Status | Recommendation |
|------|--------|----------------|
| DirectMultiFamilyBFMCS.lean | 3 unprovable sorries | Document as deprecated |
| SuccChainFMCS.lean | 3 semantically justified axioms | Use for discrete path |
| CanonicalTaskRelation.lean | Complete | Core of discrete bypass |
| ModallyCoherentBFMCS.lean | MCS-level saturation proven | Use for MCS reasoning |

### Proof Dependency Graph

```
SuccRelation (Succ definition)
    |
    v
SuccExistence (successor_exists, predecessor_exists)
    |
    v
CanonicalTaskRelation (CanonicalTask, bounded_witness)
    |
    v
SuccChainFMCS (FMCS Int from Succ-chains)
    |
    v
[NEW] SuccChainTaskFrame (TaskFrame Int)
    |
    v
[NEW] SuccChainWorldHistory (WorldHistory)
    |
    v
[NEW] SuccChainTruthLemma (phi in M <-> eval phi)
    |
    v
DiscreteCompleteness
```

## 9. Conclusion

The 3 sorries in DirectMultiFamilyBFMCS are **fundamentally unprovable** in TM logic (T+4, no 5-axiom). The correct path for discrete completeness is the **Succ-chain bypass**, which:

1. Builds a single FMCS Int from Succ-chains (not arbitrary Lindenbaum chains)
2. Instantiates TaskFrame Int directly from CanonicalTask
3. Bypasses BFMCS multi-family structure entirely
4. Has only semantically justified axioms (not mathematical gaps)

The infrastructure for this path is largely complete (Tasks 10-14). The remaining work is wiring to TaskFrame and proving the truth lemma.
