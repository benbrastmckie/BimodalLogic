# Research Report: Task #107 — Seed Construction for BurgessR3Maximal

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-27
**Mode**: Team Research (4 teammates)
**Session**: sess_1777294743_227c03

## Summary

Four teammates resolved the seed construction blocker. The key insight (from Teammate A): **Burgess never constructs a seed from scratch.** Every R-maximal interval set arises from either (a) Lemma 2.4, where endpoint C is purpose-built so `r(A, beta, C)` holds by construction (beta is the trivial seed), or (b) Lemma 2.6 (splitting), where the existing interval set B is the seed. The general `burgessR3Maximal_exists` theorem is asking for something Burgess never needs — it should be replaced with context-specific constructions.

## Key Findings

### 1. Burgess Never Needs General Seed Construction (A confirmed)

In Burgess's chronicle construction:
- **Lemma 2.4 (C5 endpoint)**: Constructs C so that S(alpha, beta) ∈ C for all alpha ∈ A. This gives burgessR(A, beta, C) AND burgessRSince(C, beta, A) for the seed element beta. Then `deductiveClosure({beta})` is a DCS satisfying burgessR3.
- **Lemma 2.6 (C4 splitting)**: The existing g(x,y) satisfying burgessR3 serves as the starting point. Splitting via burgessR3_absorption gives sub-intervals. No new seed needed.
- **Initial chronicle**: Singleton domain {x}, no adjacent pairs, no g-values needed. First extension via Lemma 2.4 provides the seed.

### 2. Context-Specific Existence Is Sufficient (A, C confirmed)

Replace the general sorry'd `burgessR3Maximal_exists` with:

```lean
-- For C5 elimination: seed from the Until formula's eta
theorem burgessR3Maximal_exists_from_seed
    (A C : Set Formula) (eta : Formula)
    (h_mcs_A : SetMaximalConsistent A) (h_mcs_C : SetMaximalConsistent C)
    (h_burgessR : burgessR A eta C)
    (h_burgessRSince : burgessRSince C eta A) :
    ∃ B, BurgessR3Maximal A B C
```

The seed `deductiveClosure({eta})` satisfies burgessR3 because:
- For beta derived from eta: burgessR(A, beta, C) by `untl_left_mono_thm` (BX2)
- For beta = conjunction of elements from {eta}: burgessR(A, beta, C) by `untl_conj_guard` (BX7)
- These cover all of deductiveClosure({eta})

### 3. Conflict Resolution: D vs B on DCS from Empty Seed

**Teammate D** claimed: Zorn on consistent sets seeded from empty, maximal element is DCS by guard algebra.
**Teammate B** claimed: Empty-set Zorn does NOT produce a DCS because theorems need not satisfy burgessR.

**Resolution**: B is correct for the GENERAL case. The guard algebra (BX7+BX2) preserves burgessR3 under derivation FROM existing elements in the set, but cannot force theorems (derivable from []) into the set. A maximal consistent set satisfying burgessR3 may lack theorems that don't satisfy burgessR. D's claim that "the maximal element is automatically a DCS" is not proven.

**However**: D's approach works IF we have at least one seed element satisfying burgessR3. Then deductiveClosure({seed}) IS a DCS satisfying burgessR3 (by A+C's analysis), and Zorn extension from there gives BurgessR3Maximal. So D and A agree on the solution — they just differ on where the seed comes from.

### 4. F(gamma) → untl(beta, gamma) for Theorem beta (C confirmed)

Via BX12 (F(gamma) → untl(top, gamma)) + BX2 (left_mono with top → beta for theorem beta):
```
F(gamma) → untl(top, gamma) → untl(beta, gamma)  [for theorem beta]
```
This is derivable in BX and the codebase already has `untl_left_mono_thm`. But it requires F(gamma) ∈ A, which is NOT guaranteed for arbitrary A, C.

### 5. The Reflexive vs Strict Gap (D confirmed)

Under Burgess's reflexive semantics: gamma ∈ A → untl(beta, gamma) ∈ A (take s=t, guard vacuous). This makes EVERY formula in A ∩ C a valid seed.

Under the codebase's strict semantics: this fails. The guard interval [t,s) is non-empty (t < s), so beta must hold at t. G(beta) gives beta at all s > t but NOT at t. The `until_guard` axiom (untl(phi,psi) → phi) is STRONGER than Burgess for the guard at t, but doesn't help with seed construction.

**Consequence**: The strict semantics cannot replicate Burgess's "trivial seed" argument. But the context-specific seed from Lemma 2.4 (Finding 1) works in both settings.

## Recommendations

### 1. Delete `burgessR3Maximal_exists` (the general sorry'd theorem)

It asks for something Burgess never needs. Replace with context-specific constructions.

### 2. Prove `burgessR3Maximal_exists_from_seed`

Takes an element eta satisfying `burgessR(A, eta, C)` and `burgessRSince(C, eta, A)`. Constructs `deductiveClosure({eta})` as seed, applies Zorn extension. This is the mathematically correct approach.

### 3. Adapt Lemma 2.4 to Provide the Seed

The codebase's `lemma_2_4` constructs endpoint C from the Until formula `untl(guard, event)`. The `guard` element naturally satisfies `burgessR(A, guard, C)` because C is purpose-built to contain the right Since-reflections. Verify this and thread it through the C5 elimination.

### 4. For C4 Splitting: No New Seed Needed

`burgessR3_absorption` (already sorry-free) handles this. The existing g(x,y) splits into sub-intervals that inherit burgessR3.

### 5. Implementation Order

1. Prove `burgessR3Maximal_exists_from_seed` (new, ~50 lines)
2. Verify Lemma 2.4 produces seed satisfying burgessR(A, eta, C)
3. Thread seed through C5 elimination to produce BurgessR3Maximal g-values
4. C4 splitting via burgessR3_absorption (already done)
5. Delete general `burgessR3Maximal_exists` sorry

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution |
|----------|-------|--------|------------------|
| A | Burgess's seed construction | completed | Burgess never needs general seed; Lemma 2.4 provides eta |
| B | Empty seed + Zorn | completed | Empty Zorn doesn't produce DCS; conditional existence viable |
| C | Validate + G∧F→U | completed | F→untl derivable for theorems; doesn't solve general case; context-specific is right |
| D | Reflexive vs strict | completed | Zorn on consistent sets viable with seed; guard algebra preserves burgessR3 |
