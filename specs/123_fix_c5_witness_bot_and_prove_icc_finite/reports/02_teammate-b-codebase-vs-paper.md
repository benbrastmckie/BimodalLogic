# Teammate B: Codebase vs Burgess 1982 Comparison

**Task**: 123 — Compare ProofChecker's omega chain against Burgess's paper
**Date**: 2026-05-11

## CRITICAL FINDING: The Construction is Faithful — The Bug is Downstream

The ProofChecker's omega chain construction **faithfully implements Burgess 1982**. The infinite midpoint chain for U(⊤,⊥) is NOT a bug in the construction — Burgess's construction ALSO produces this chain. The construction is correct. The problem is in the ProofChecker's DOWNSTREAM architecture, which tries to build a ℤ-isomorphism that Burgess never needed.

## Detailed Comparison

### 1. C5 Elimination (Burgess 2.10 vs Code)

**Burgess 2.10**: For U(ξ, η) ∈ f(x), case n = m+1 (x' = dom-successor):
- Condition (i): both η ∧ U(ξ,η) ∈ f(x') AND η ∈ g(x,x') → recurse at x'
- Condition (ii): both ξ ∈ f(x') AND η ∈ g(x,x') → counterexample already resolved (impossible under the h_no_wit hypothesis)
- Neither (i) nor (ii): apply Lemma 2.7 or 2.8, split at (x, x') with midpoint z = (x+x')/2

**Code** (CounterexampleElimination.lean, line 858):
```lean
by_cases h_cond_i : Formula.and ξ (Formula.untl η ξ) ∈ χ.f x' ∧ ξ ∈ χ.g pt x'
```

Mapping: code ξ = Burgess η (guard), code η = Burgess ξ (event).
Code's condition (i): `guard ∧ U(event, guard) ∈ f(x') ∧ guard ∈ g(pt, x')` — MATCHES Burgess exactly.

**Verdict: FAITHFUL.** The code implements Burgess's Lemma 2.10 correctly.

### 2. Splitting (Burgess 2.7 vs Code)

**Burgess 2.7**: Given R(A, B, C) and U(ξ,η) ∈ A and η ∉ B, produces B', D, B'' with:
- R(A, B', D), R(D, B'', C)
- B = B' ∩ D ∩ B''
- η ∈ B', ξ ∈ D

**Code** (PointInsertion.lean, `lemma_2_7`): Produces B', D, B'' with:
- BurgessR3Maximal(f(pt), B', D), BurgessR3Maximal(D, B'', f(x'))
- g(pt,x') ⊆ B' ∩ D ∩ B'' (weaker than equality but sufficient)
- ξ ∈ B' (guard in left side), η ∈ D (event in midpoint MCS)

**Verdict: FAITHFUL.** The code correctly implements the splitting. B'' is constructed via Zorn extension of a consistent seed, so B'' is consistent → ⊥ ∉ B''. This matches Burgess.

### 3. Chronicle Conditions

| Condition | Burgess | Code | Match? |
|-----------|---------|------|--------|
| C0 | f maps to MCS | `Chronicle.c0` | ✓ |
| C0' | dom f is finite | `dom : Finset Rat` | ✓ |
| C1 | g maps to DCS | `Chronicle.c1` (CUD) | ✓ |
| C2 | r(f(x), g(x,y), f(y)) | `Chronicle.c2` | ✓ |
| C2' | R (maximal) for adjacent | `Chronicle.c2'` (BurgessR3Maximal) | ✓ |
| C3 | g(x,z) = g(x,y) ∩ f(y) ∩ g(y,z) | `Chronicle.c3` | ✓ |
| C4a | ¬U counterexample | `Chronicle.c4` | ✓ |
| C5a | U witness with η ∈ g(x,y) | `Chronicle.c5` | **DIFFERENT** |

### 4. C5 Definition — The Subtle Difference

**Burgess C5a** (paper, section 2.8):
> ∃ y ∈ dom f, x < y ∧ ξ ∈ f(y) ∧ **η ∈ g(x,y)**

**Code C5** (ChronicleTypes.lean, line 469-475):
> ∃ y ∈ dom, x < y ∧ δ ∈ f(y) ∧ **∀ z ∈ dom, x < z < y → γ ∈ f(z) ∧ U(δ,γ) ∈ f(z)**

The code's C5 checks intermediate **f-values**, not the **g-value**. By C3 (g(x,y) ⊆ f(z) for intermediate z), Burgess's `η ∈ g(x,y)` implies the code's condition. But the code's condition is **STRICTLY WEAKER** — it doesn't require η ∈ g(x,y), only η ∈ f(z) for each z.

However, the `EliminationResult.c5_forward_witness` (line 571-576) DOES use g-values:
```
∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b
```

So the elimination result provides the STRONGER Burgess condition, while the chronicle-level C5 uses the weaker f-value condition. Both are correct; the stronger result feeds into the weaker requirement.

**This difference is not a bug.** The stronger version is provided by the elimination, and the weaker version is what the truth lemma needs.

### 5. The Truth Lemma (Burgess 2.11 vs Code)

**Burgess 2.11**: For α = U(β, γ):
- If U(β,γ) ∈ f(x): C5a gives y with γ ∈ f(y) and β ∈ g(x,y). C3 gives β ∈ f(z) for intermediate z. Done.
- If ¬U(β,γ) ∈ f(x): C4a gives counterexample z. Done.

The truth lemma works DIRECTLY on (X, <) where X = limit_dom ⊂ ℚ. Burgess never needs X ≅ ℤ. He just needs X to be a linear order with the correct valuation.

**The truth lemma is independent of whether bounded intervals are finite.**

### 6. The Root Cause: NOT in the Construction

The ProofChecker's architecture deviates from Burgess at the COUNTERMODEL level:

**Burgess**: Constructs valuation V on (X, <) where X ⊂ ℚ. The model IS (X, <, V). Done.

**ProofChecker**: Needs a TaskFrame on a type D with AddCommGroup. The construction gives limit_dom ⊂ ℚ, but ℚ is not closed under the needed group operations for ShiftClosed. So the ProofChecker:
1. Tries to show limit_dom ≃o ℤ (requires IsSuccArchimedean — FAILS due to infinite chains)
2. Transports FMCS to ℤ
3. Builds TaskFrame on ℤ with AddCommGroup

The infinite midpoint chain is NOT a bug in the construction. It's a consequence of the construction working EXACTLY as Burgess intended. The "routine exercise" for discreteness means: add the discrete axioms, and the truth lemma still works on (X, <) — which is a DISCRETE linear order (U(⊤,⊥) holds everywhere), but NOT necessarily isomorphic to ℤ.

### 7. What Burgess's "Routine Exercise" Actually Means

For the discrete case with axioms G'⊥ ∧ H'⊥:
1. The MCS A₀ includes G'⊥ = U(⊤,⊥) and H'⊥ = S(⊤,⊥)
2. The omega chain builds (X, <) with the truth lemma V(α) = {x : α ∈ f(x)}
3. Every x ∈ X has U(⊤,⊥) ∈ f(x), so x ∈ V(U(⊤,⊥)), meaning x has an immediate successor in X
4. Similarly from H'⊥, x has an immediate predecessor
5. (X, <) is discrete (every element has immediate successor/predecessor)
6. The truth lemma gives (X, <, V) as a model of α₀ over a DISCRETE linear order
7. This proves α₀ is satisfiable over discrete orders — completeness for discreteness

Burgess NEVER needs (X, <) ≅ (ℤ, <). He just needs it to be discrete, which it is (by the truth lemma on U(⊤,⊥)). The infinite midpoint chains make X have order type ω·η (ω copies for each "structural" gap, densely ordered), but this is still discrete because each element has immediate successor/predecessor.

### 8. Implications for the Fix

**The construction does NOT need fixing.** The issue is in the downstream architecture:
- The ProofChecker needs AddCommGroup D for TaskFrame/ShiftClosed
- This requires D ≅ ℤ (or at least an abelian group)
- The current approach: limit_dom → IsSuccArchimedean → ℤ-iso
- This fails because IsSuccArchimedean is false for limit_dom

**The real question is**: Can the countermodel be built on (X, <) = limit_dom directly, without needing AddCommGroup? Or can the architecture be modified to not require AddCommGroup for the discrete case?

**Alternatively**: Can the construction be modified to produce a limit_dom that IS isomorphic to ℤ? This would require preventing the infinite midpoint chains, which means deviating from Burgess's construction for the ξ=⊥ case.

## Summary

| Aspect | Matches Burgess? | Bug? |
|--------|-----------------|------|
| C5 elimination (Lemma 2.10) | Yes | No |
| Splitting (Lemma 2.7) | Yes | No |
| Chronicle conditions C0-C4 | Yes | No |
| C5 definition | Weaker (f-values not g-values) | No (sufficient) |
| Truth lemma approach | Yes | No |
| Infinite midpoint chains | Yes (Burgess has them too) | No (by design) |
| ℤ-isomorphism attempt | **NO** (Burgess never does this) | **YES — architectural mismatch** |

The fix should be at the ARCHITECTURAL level (how the countermodel is built), not at the CONSTRUCTION level (the omega chain).
