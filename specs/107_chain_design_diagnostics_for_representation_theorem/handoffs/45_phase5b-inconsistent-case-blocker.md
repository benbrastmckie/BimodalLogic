# Handoff: Phase 5b -- Inconsistent Case Blocker in g_content(A) subset B

## Session
- **Session ID**: sess_1777480968_574cb2
- **Date**: 2026-04-29
- **Agent**: lean-implementation-agent
- **Phase**: 5b (left_mono_until_G + g_content subset B + splitting_seed_consistent)

## Summary

Phase 5b tasks 1-4 (axiom constructors, soundness proofs, match arm updates) are **already completed** from prior sessions. The `left_mono_until_G` and `left_mono_since_H` axioms, their soundness proofs, and all match arms in Substitution.lean and SoundnessLemmas.lean are in the codebase and build clean.

The **blocker** is at `g_content_sub_B_of_BurgessR3Maximal` (PointInsertion.lean line 676): the **inconsistent case** where `{phi} union B` is inconsistent. The consistent case (lines 353-386) is fully proved.

## What Is Done

1. `left_mono_until_G` constructor in Axioms.lean (line 140)
2. `left_mono_since_H` constructor in Axioms.lean (line 146)
3. Soundness of `left_mono_until_G` in Soundness.lean (line 524)
4. Soundness of `left_mono_since_H` in Soundness.lean (line 534)
5. All match arms in SoundnessLemmas.lean (6 locations)
6. All match arms in Substitution.lean (2 locations)
7. `untl_left_mono_G` helper in RRelation.lean (line 1054)
8. `snce_left_mono_H` helper in RRelation.lean (line 1069)
9. `G_weaken_guard_in_mcs` helper in PointInsertion.lean (line 304)
10. `and_imp_curry` helper in PointInsertion.lean (line 286)
11. **Consistent case** of g_content_sub_B_of_BurgessR3Maximal (lines 353-386) -- COMPLETE

## The Inconsistent Case (Line 676)

### Context

```
h_cons : ¬SetConsistent ({φ} ∪ B)
⊢ False
```

Where: `G(φ) ∈ A`, `φ ∉ B`, `BurgessR3Maximal(A, B, C)`, `g_content(A) ⊆ C`.

### Analysis

If `{φ} ∪ B` is inconsistent, then `B ⊢ φ.neg`, so `φ.neg ∈ B` (DCS closure). From `φ.neg ∈ B` and `burgessR3(A, B, C)`: `untl(φ.neg, γ) ∈ A` for all `γ ∈ C`. Combined with `G(φ.neg → ⊥) ∈ A` (from `G(φ) ∈ A` via DNI + TG + temp_k_dist), `left_mono_until_G` gives `untl(⊥, γ) ∈ A` for all `γ ∈ C`.

The formula `untl(⊥, γ)` means: exists s > t such that γ(s) and ⊥ on (t,s). This is:
- **Satisfiable in discrete models** (where (t,s) can be empty for immediate successors)
- **Unsatisfiable in dense models** (where (t,s) is always nonempty)

Since the BX axiom system axiomatizes ALL linear orders (both dense and discrete), `untl(⊥, γ)` is NOT refutable in the axiom system. Therefore the inconsistent case cannot be resolved by deriving `⊥ ∈ A` from `untl(⊥, γ) ∈ A`.

### Approaches Attempted

1. **BX7 linearity**: `untl(⊥, γ₁) ∧ untl(⊥, γ₂)` gives a 3-way disjunction where two disjuncts lead to `untl(⊥, ⊥)` (refutable via BX10 + G(⊤)), but the first disjunct gives `untl(⊥, γ₁∧γ₂)` (no contradiction). MCS A can accept only the first disjunct.

2. **BX13 enrichment**: Enriching the event with Since/Until doesn't produce a refutable formula.

3. **BX14 separation**: Gives useful structure but doesn't resolve the inconsistent case.

4. **Since direction of burgessR3**: `snce(φ.neg, G(φ)) ∈ C` combined with `φ ∈ C` and enrichment gives `snce(φ.neg, G(φ) ∧ untl(φ.neg, φ)) ∈ C`. The event `G(φ) ∧ untl(φ.neg, φ)` is semantically contradictory in dense orders but NOT syntactically refutable.

5. **temp_4 to get G(φ) ∈ C**: From `G(φ) ∈ A`, `temp_4` gives `G(G(φ)) ∈ A`, so `G(φ) ∈ g_content(A) ⊆ C`. Then `G(φ.neg → ⊥) ∈ C`. But this G-information in C acts on C's future, not C's past (where the Since witness lives). No path to contradiction.

6. **Direct seed consistency**: Proving `splitting_seed_consistent` without `g_content(A) ⊆ B` was also explored. The `g_content` elements can be propagated to a future witness (via G + right_mono_until), but `h_content` elements cannot (they're in A at the present time, not provably at future times).

### Root Cause

The theorem `g_content(A) ⊆ B` from `BurgessR3Maximal(A,B,C)` is **semantically true in all models** (MODEL-THEORETICALLY, if A is satisfied at t and B represents the open interval (t, t_C), then G(φ) at t gives φ throughout (t, t_C), so φ ∈ B). However, the **syntactic proof** fails because `BurgessR3Maximal` B is anti-monotone in B (bigger B means stricter constraints), so `BurgessR3Maximal_extension_fails` requires the extension `{φ} ∪ B` to be **consistent**, and proving consistency requires ruling out the case where `φ.neg ∈ B` already, which leads to `untl(⊥, γ) ∈ A` -- a formula that is satisfiable in discrete models.

### Report 45 Gap

Report 45's proof sketch (Section 2) says "DC({φ} ∪ B) is a proper DCS extension of B" without checking whether `{φ} ∪ B` is consistent. The proof only works when `{φ} ∪ B` is consistent. The inconsistent case was not addressed.

## Recommended Next Steps

### Option A: Density axiom approach (recommended)

Add a density axiom to the BX system: `⊢ untl(⊥, γ) → ⊥` (or equivalently `⊢ G(G(φ)) → G(φ)`). This axiom is valid on dense linear orders and makes the inconsistent case trivially contradictory: `untl(⊥, γ) ∈ A` and `⊢ untl(⊥, γ) → ⊥` gives `⊥ ∈ A`, contradiction.

The Burgess chronicle is over Q (dense), so this axiom is sound for the intended use case. However, it changes the axiom system from "all linear orders" to "dense linear orders", which may affect other parts of the completeness proof.

### Option B: Prove {φ}∪B always consistent (investigate further)

There may be a property of `BurgessR3Maximal` that forces `{φ}∪B` to be consistent when `G(φ) ∈ A`. If so, it would involve a non-trivial interaction between the maximality condition and the G-structure of A. This requires deeper mathematical research.

### Option C: Bypass g_content(A) ⊆ B entirely

Prove `splitting_seed_consistent` directly without going through `g_content(A) ⊆ B`. This would require a fundamentally different proof strategy, possibly using BX14 (separation) combined with enrichment to show F(full_seed_conjunction) ∈ A via the Until witness structure. The main obstacle is propagating `h_content(C)` elements to a future witness (they live in A at the present time, not at future times).

### Option D: Semantic completeness shortcut

If the soundness theorem is already established, one could potentially use the CONTRAPOSITIVE: the seed is satisfiable (semantic argument, straightforward), and satisfiable sets are consistent by soundness. This requires the soundness theorem to be fully established at this point in the construction.

## Files With Sorries

| File | Line | Sorry | Status |
|------|------|-------|--------|
| PointInsertion.lean | 676 | `g_content_sub_B inconsistent case` | BLOCKED (this handoff) |
| PointInsertion.lean | 684 | `h_content_sub_B` (dual) | BLOCKED (depends on 676) |
| PointInsertion.lean | 729 | `splitting_seed_consistent` | BLOCKED (depends on 676+684) |

## Recommendation

Run `/revise 107` to update the plan. The research team should investigate Option A (density axiom) or Option D (semantic shortcut) as the most promising paths forward.
