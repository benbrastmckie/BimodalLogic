# Research Report: Phase 2 Completion Strategy for Temporal Symmetry

## Executive Summary

This report analyzes how to complete Phase 2 of the temporal symmetry derivation plan (026), which is stuck on 3 `sorry` cases in `Truth.lean` (lines 589, 668, 690). Based on the comprehensive analysis in research report 027, the recommended solution is **Approach D: Restrict to Derivable Formulas**.

**Key Finding**: The structural induction approach in `truth_swap_of_valid_at_triple` is fundamentally impossible to complete. The proof attempts to derive local truth at a specific triple from global validity, which fails for:
- **Implication**: Truth-level dependencies cannot be analyzed via validity alone
- **Past/Future**: Domain-restricted quantification prevents extracting subformula validity

**Recommended Solution**: Prove temporal duality soundness by induction on **derivations** rather than formulas. This proves exactly what the temporal duality rule requires: if `Derivable [] phi`, then `valid phi.swap`.

## Current State Analysis

### Location of Sorry Cases

```
Logos/Semantics/Truth.lean:
- Line 589: imp case in truth_swap_of_valid_at_triple
- Line 668: past case (subproof for h_psi_valid)
- Line 690: future case (subproof for h_psi_valid)
```

### Why Structural Induction Fails

The helper lemma has type:
```lean
is_valid phi -> truth_at M tau t ht phi.swap_past_future
```

This states: "If phi is valid (true at ALL triples), then phi.swap is true at THIS SPECIFIC triple."

**Implication Case**:
- We have `h_valid : is_valid (psi -> chi)`
- We have `h_swap_psi : truth_at M tau t ht psi.swap`
- We need: `truth_at M tau t ht chi.swap`
- Problem: Cannot derive `truth_at M tau t ht psi` from `truth_at M tau t ht psi.swap`

**Past/Future Cases**:
- We need to prove `is_valid psi` from `is_valid (past psi)` or `is_valid (future psi)`
- This requires finding a time in the domain to instantiate the quantifier
- WorldHistory domains are convex but NOT necessarily unbounded
- Cannot guarantee existence of required reference time

### Mathematical Root Cause

The fundamental issue is a **type mismatch**: we're trying to prove a local property (truth at one triple) from a global property (validity), using formula structure. But formula constructors like `imp`, `past`, `future` create dependencies that don't decompose properly at the validity level.

## Recommended Solution: Approach D

### Description

Prove temporal duality soundness by induction on **derivation structure** rather than formula structure:

```lean
theorem temporal_duality_sound_derivable (phi : Formula) :
  Derivable [] phi -> valid phi.swap_past_future
```

### Why This Works

1. **Matches the rule**: Temporal duality rule only applies to empty-context derivations
2. **Base cases tractable**: Show each axiom's swap is valid
3. **Rule cases tractable**: Show each inference rule preserves swap-validity
4. **Avoids impossible cases**: No need to handle arbitrary valid formulas

### Implementation Approach

**Phase 2A: Axiom Preservation** (4-6 hours)
- Prove each TM axiom remains valid after swap
- Some axioms are self-dual (MT, M4, MB)
- Others transform to valid related formulas (T4, TA, TL, MF, TF)

**Phase 2B: Rule Preservation** (4-6 hours)
- Prove modus_ponens preserves swap-validity
- Prove modal_k preserves swap-validity (box commutes with swap)
- Prove temporal_k preserves swap-validity (future swaps to past)
- temporal_duality case is trivial (double swap is identity)
- weakening and assumption are straightforward

**Phase 2C: Integration** (2-3 hours)
- Remove or mark deprecated the current `truth_swap_of_valid_at_triple` lemma
- Add new `derivable_swap_valid` theorem
- Update `valid_swap_of_valid` to use new approach or document limitation
- Update Soundness.lean temporal_duality case

### Alternative: Semantic Approach with Frame Constraints

The research report also analyzed adding frame constraints (unbounded domains, symmetric task relations). This was rejected because:
- Changes validity semantics (departs from JPL paper)
- Still doesn't solve implication case
- Creates maintenance burden (two validity notions)

## Files to Modify

1. **Truth.lean**: Add new derivation-indexed proof approach
2. **Soundness.lean**: May need updates if proof structure changes
3. **KNOWN_LIMITATIONS.md**: Document that temporal duality is proven for derivable formulas only

## Risk Assessment

**Risk Level**: Low

- We're proving exactly what the temporal duality rule claims
- Approach is mathematically sound and paper-aligned
- Implementation is well-understood (derivation induction is standard)

## Estimated Effort

| Phase | Description | Hours |
|-------|-------------|-------|
| 2A | Axiom preservation proofs | 4-6 |
| 2B | Rule preservation proofs | 4-6 |
| 2C | Integration and cleanup | 2-3 |
| **Total** | | **10-15** |

## Conclusion

The current Phase 2 approach (structural induction on formulas) is fundamentally impossible to complete. The recommended solution is **Approach D**: prove temporal duality soundness by induction on derivations. This:

1. Proves exactly what the temporal duality rule requires
2. Avoids the impossible implication case
3. Is mathematically sound and paper-aligned
4. Has moderate implementation complexity (10-15 hours)

## References

- Primary analysis: `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/027_temporal_duality_sorry_resolution/reports/001-temporal-duality-sorry-resolution.md`
- Current plan: `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/026_temporal_symmetry_derivation/plans/001-temporal-symmetry-derivation-plan.md`
- Code location: `Logos/Semantics/Truth.lean` (lines 491-717)
