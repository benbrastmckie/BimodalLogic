# Phase 4 Blocking Analysis: Irreflexivity Proof Under Strict Semantics

**Task**: 991 - Temporal Algebraic Representation
**Date**: 2026-03-18
**Phase**: 4 (Irreflexivity via temp_a + Linearity)
**Status**: BLOCKED

## Summary

Phase 4 attempted to replace the T-axiom-based irreflexivity proof with a temp_a + linearity proof. This approach was identified in the team research synthesis as the primary path forward. However, detailed implementation analysis reveals that the proof strategy does not close the gap.

## Analysis Performed

### 1. Existing Code Review

- Read `CanonicalIrreflexivity.lean` (~1283 lines) - current naming set proof with one `sorry`
- Read `DirectIrreflexivity.lean` (~315 lines) - systematic analysis of direct proof approaches
- Read `CanonicalIrreflexivityAxiom.lean` - downstream theorem usage

### 2. Proof Strategy Evaluation

**temp_a Closure Lemma** (already proven in DirectIrreflexivity.lean):
- `canonicalR_closure_temp_a`: If `CanonicalR M M` and `phi in M`, then `P(phi) in M`
- This implies `H(neg phi) not-in M` for any `phi in M`

**DirectIrreflexivity.lean Conclusion** (lines 235-250):
> **Path A is impossible.** The direct F proof approach cannot work because:
> 1. Any theorem psi is automatically in M (MCS closure)
> 2. If psi in M then neg(psi) not-in M (MCS consistency)
> 3. So there is NO formula psi with both "derives psi" and "neg(psi) in M"
> 4. The contradiction mechanism REQUIRES comparing M with a DIFFERENT MCS M'

This directly contradicts the temp_a + linearity proof sketch's steps 5-7, which were never rigorously specified.

### 3. Linearity Axiom Analysis

The linearity axiom (`temp_linearity`) has the form:
```
F(phi) AND F(psi) -> F(phi AND psi) OR F(phi AND F(psi)) OR F(F(phi) AND psi)
```

This governs **ordering between F-witnesses**, not the relationship between an MCS and itself. It cannot produce an "infinite regress" contradiction within a single MCS.

### 4. Seriality Fallback Analysis

Moving seriality (`G(phi) -> F(phi)`, `H(phi) -> P(phi)`) to base axioms was considered but also fails:
- Seriality converts `H(neg p) in M'` to `P(neg p) in M'`
- `P(neg p)` = "neg p at some past time" != "neg p now"
- Cannot derive `neg p in M'` to contradict `p in M'`

## Root Cause

**Fundamental Modal Logic Result**: Irreflexivity is NOT modally definable. No formula of modal logic characterizes irreflexive frames. This is why Gabbay invented the IRR inference rule.

Under strict semantics, `{p, H(neg p)}` is semantically consistent (it models "p is true now for the first time ever"). There is no syntactic derivation within standard TM axioms that produces a contradiction.

## Options to Resolve

| Option | Description | Impact | Recommendation |
|--------|-------------|--------|----------------|
| 1. Revert to reflexive | Keep T-axiom | Contradicts Task 991 goals | Not recommended |
| 2. Use IRR explicitly | Gabbay rule with freshness | String atom issues persist | Complex |
| 3. Axiomatize irreflexivity | Make `canonicalR_irreflexive` an axiom | Clean, honest | **Recommended** |
| 4. Bulldozing/product | Semantic post-processing | Additional infrastructure | Possible |

## Recommendation

**Option 3: Accept irreflexivity as axiomatic**

- Change `canonicalR_irreflexive` from a theorem to an axiom declaration
- Document that this is semantically correct under strict semantics
- The canonical model under strict G/H is definitionally irreflexive
- This aligns with standard practice (irreflexivity is a frame condition, not a derivable property)

## Files Affected

- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Convert to axiom
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Update docstring
- `specs/991_temporal_algebraic_representation/plans/02_revised-irreflexive-semantics.md` - Updated with blocking analysis

## Next Steps

1. User decision required: Accept Option 3 (axiom) or pursue alternative?
2. If Option 3 accepted, Phase 4 can be completed in ~30 minutes
3. Phases 5-10 can proceed independently (they don't depend on HOW irreflexivity is established)

## References

- DirectIrreflexivity.lean: Systematic proof that direct approaches fail
- 04_synthesis.md: Team research identifying the problem
- Stanford Encyclopedia (Temporal Logic): Irreflexivity non-definability
- Gabbay (1981): Irreflexivity Lemma introducing IRR rule
