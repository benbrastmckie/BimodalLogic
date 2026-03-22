# Implementation Progress: Task 25 Phase 1

**Date**: 2026-03-22
**Session**: sess_1774213006_ce2d6c
**Status**: PARTIAL - 3 sorries remaining

## What Was Done

### 1. Added Fresh G-Atom Infrastructure to CanonicalIrreflexivity.lean

Location: After `canonicalR_past_reflexive`, before the deprecated axiom section (around line 1225).

Added three theorems:
- `exists_strict_fresh_atom` - Find suitable fresh atom
- `fresh_Gp_seed_consistent` - Prove seed consistency
- `existsTask_strict_fresh_atom` - Main theorem (complete except for dependencies)

### 2. Structure is Complete

The overall proof structure compiles:
- `existsTask_strict_fresh_atom` correctly uses the other two lemmas
- `fresh_Gp_seed_consistent` has the correct signature and structure
- `exists_strict_fresh_atom` has the correct signature

### 3. Build Status

`lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` succeeds with warnings about sorries.

## Remaining Sorries (3)

### Sorry 1: Line 1283 in `exists_strict_fresh_atom`
**Context**: Case when `q ∈ M`
**Issue**: Need to derive contradiction or find a different atom

```lean
  by_cases hq : Formula.atom q ∈ M
  · -- Case: q ∈ M
    sorry
```

**Analysis**: If q ∈ M, the hypothesis `h_no_such` doesn't directly apply (it requires ¬q ∈ M first). Need to either:
- Show this case cannot happen for fresh atoms, or
- Use a different proof strategy

### Sorry 2: Line 1294 in `exists_strict_fresh_atom`
**Context**: Case when `¬q ∈ M`, but we showed `G(¬q) ∈ M` (always false)
**Issue**: Need to find an atom that's NOT always false

```lean
  · -- Case: q ∉ M, so by maximality ¬q ∈ M
    have h_neg_q : Formula.neg (Formula.atom q) ∈ M := ...
    have h_G_neg_q : Formula.all_future (Formula.neg (Formula.atom q)) ∈ M := h_no_such q h_neg_q
    -- This q is "always false" - need to find one that's not
    sorry
```

**Analysis**: The hypothesis `h_no_such : ∀ q, ¬q ∈ M → G(¬q) ∈ M` says every "currently false" atom is "always false". We need to show this leads to contradiction.

Possible approaches:
1. Use infinitely many atoms - can't all be "always false"
2. Use semantic argument about Lindenbaum extension
3. Use substitution/freshness argument

### Sorry 3: Line 1405 in `fresh_Gp_seed_consistent`
**Context**: Case when `G(q) ∈ L` in the seed consistency proof
**Issue**: The IRR-style argument doesn't directly apply

```lean
  · -- Case: G(q) ∈ L
    -- ... established L' ⊢ F(¬q) and derived F(¬q) ∈ M
    -- This means ¬G(q) ∈ M, i.e., G(q) ∉ M
    -- But G(q) was in the seed, not in M - no contradiction
    sorry
```

**Analysis**: The current proof derives that G(q) ∉ M, but this doesn't contradict the seed being consistent. The approach needs revision.

Possible approaches:
1. Use IRR rule: From (p ∧ H(¬p)) → φ with p ∉ φ.atoms, derive φ
2. Use a different seed marker
3. Show the derivation L ⊢ ⊥ with G(q) ∈ L can be transformed

## Recommended Next Steps

### Option A: Fix the Mathematical Gaps

1. For `exists_strict_fresh_atom`:
   - Prove that if h_no_such holds for ALL atoms, we get a contradiction
   - Key insight: Use that there are infinitely many atoms but only finitely many can be "always true" or "always false" in a canonical model

2. For `fresh_Gp_seed_consistent`:
   - Reconsider the seed: Maybe use `g_content(M) ∪ {G(q), ¬q}` to force ¬q in the witness
   - Or use a different argument structure

### Option B: Simplify the Approach

Instead of proving per-witness strictness in full generality, prove it for the SPECIFIC witnesses produced by the staged construction. Those witnesses have additional structure that might make strictness provable.

### Option C: Accept Axiom Temporarily

If the mathematical gaps are too deep, consider:
1. Declaring `exists_strict_fresh_atom` as an axiom with clear documentation
2. This is semantically correct (provable in the metalanguage) even if syntactically complex
3. Less harmful than the current `canonicalR_irreflexive_axiom` which is actually FALSE

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (lines 1225-1450 added)

## Files to Check

Before continuing:
1. Verify the proof structure is sound by reading lines 1225-1470
2. Check if there are existing lemmas about atom decidability in MCS
3. Look at how the staged construction processes fresh atoms
