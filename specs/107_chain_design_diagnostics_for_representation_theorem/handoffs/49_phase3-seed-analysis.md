# Phase 3 Handoff: Seed Consistency Analysis

## Status: Phase 3 [IN PROGRESS] — Analysis Complete, Implementation Blocked

## Core Problem

The sorry sites at lines 850 and 875 of PointInsertion.lean are in `g_content_sub_B_of_BurgessR3Maximal` and `h_content_sub_B_of_BurgessR3Maximal`. These are used by `splitting_seed_consistent` to prove `{beta.neg} ∪ g_content(A) ∪ h_content(C)` is consistent.

## Key Finding: g_content_sub_B is UNPROVABLE in BX

**The inconsistent case** (G(phi) in A, phi.neg in B, {phi} union B inconsistent) is **genuinely unprovable** in the BX axiom system without a density axiom. Here is the proof:

1. From G(phi) in A and phi.neg in B with burgessR3(A, B, C):
   - BX2 (left_mono_until_G) with G(phi) strengthens guard of untl(phi.neg, gamma) to get untl(phi AND phi.neg, gamma) = untl(bot, gamma) in A
   - So untl(bot, gamma) in A for all gamma in C

2. From untl(bot, gamma) in A, for ANY formula r:
   - If not-untl(r, gamma) in A: BX14 gives untl(bot, bot AND not-r) in A, then F(bot AND not-r) in A via BX10
   - But bot AND not-r derives bot, so G(neg(bot AND not-r)) is a theorem in A
   - F(bot AND not-r) = neg G(neg(bot AND not-r)), contradiction
   - So untl(r, gamma) in A for ALL r

3. This gives burgessR3(A, D, C) for ANY DCS D.

4. If B is NOT MCS: proper DCS extensions exist, contradicting BurgessR3Maximal maximality. Contradiction.

5. **If B IS MCS**: no proper DCS extensions exist (MCS has no consistent proper extensions). Maximality is vacuously true. No contradiction is derivable.

6. On discrete linear orders, untl(bot, gamma) is satisfiable (the guard interval (t,s) can be empty when s is t's immediate successor). So A containing untl(bot, gamma) is consistent.

**Conclusion**: When B is MCS and the inconsistent case arises, the BX axiom system cannot derive a contradiction. The property holds semantically on dense orders but is syntactically unprovable in BX.

## Approach That Works (Non-MCS Case)

For the NON-MCS case of B (which we showed IS contradictory):

```
theorem g_content_sub_B_of_BurgessR3Maximal_non_mcs:
  B is not MCS → g_content(A) ⊆ B
```

This is provable because:
- Inconsistent case leads to untl(bot, gamma) in A
- untl(bot, gamma) gives burgessR3(A, D, C) for any DCS D
- B not MCS → proper DCS extension exists → contradicts maximality

## What's Needed for lemma_2_6_splitting

The `lemma_2_6_splitting` output requires:
1. BurgessR3Maximal(A, B', D) — needs g_content(A) ⊆ D
2. BurgessR3Maximal(D, B'', C) — needs g_content(D) ⊆ C, equivalently h_content(C) ⊆ D
3. D MCS with beta.neg in D

Requirements (1) and (2) together need the seed `{beta.neg} ∪ g_content(A) ∪ h_content(C)` to be consistent.

## Why the Combined Seed Consistency Is Hard

I proved:
- F(beta.neg) in A (from BX14 applied to maximality failure with DC({beta} ∪ B))
- P(beta.neg) in C (from BX14' applied to the Since-direction failure)

These give:
- `{beta.neg} ∪ g_content(A)` is consistent (forward_temporal_witness_seed_consistent)
- `{beta.neg} ∪ h_content(C)` is consistent (past_temporal_witness_seed_consistent)

But the COMBINED seed `{beta.neg} ∪ g_content(A) ∪ h_content(C)` has a hard "mixed" case:

When L = {delta.neg, phi_1, ..., phi_m, psi_1, ..., psi_n} derives bot (with phi_i in g_content(A), psi_j in h_content(C)):
- generalized temporal K on the g_content part gives G-formulas in A
- generalized past K on the h_content part gives H-formulas in C
- But these are "orthogonal" — G is about the future, H is about the past
- Neither F(delta.neg) in A nor P(delta.neg) in C helps bridge this gap
- The g_content elements are future-universal truths of A; the h_content elements are past-universal truths of C
- There's no BX axiom that directly connects future-universal and past-universal content across different MCSs

## Proposed Approaches (Ordered by Feasibility)

### Approach 1: MCS Case Split

Since g_content_sub_B is provable when B is NOT MCS, split:

1. **B not MCS case**: Prove g_content_sub_B directly (the non-MCS argument works).
2. **B is MCS case**: If B is MCS, then B is negation-complete. For any beta not in B: beta.neg in B. Since B subset D (any extension), beta.neg in D. Also g_content(A) subset B (proven in non-MCS case... wait, B IS MCS here so we need it for MCS B too).

Actually, if B is MCS: for any phi, either phi in B or phi.neg in B. If phi in g_content(A) and phi not in B: phi.neg in B (MCS). This IS the inconsistent case. And as shown, this is unprovable for MCS B.

So this approach fails for MCS B.

### Approach 2: Burgess D0 Seed (Plan's Approach)

The Burgess D0 seed is: `B ∪ {beta.neg} ∪ {snce(beta', alpha) : beta' in B, alpha in A} ∪ {untl(beta', gamma) : beta' in B, gamma in C}`.

This avoids g_content(A) in the seed entirely. Instead, it includes B plus specific S/U formulas. The consistency proof uses the BX5+BX14+BX13 chain.

**Problems**:
- Convention mismatch in the plan (BX5 enriches guard, not event)
- The consistency proof constructs a specific Until formula in A whose event subsumes all seed components
- After Lindenbaum: B subset D (from seed), beta.neg in D (from seed)
- For g_content(A) subset D: NOT guaranteed (B in seed doesn't imply g_content(A) subset D)
- For h_content(C) subset D: NOT guaranteed either
- The S/U formulas in the seed establish burgessR3(A, -, D) and burgessR3(D, -, C) DIRECTLY without g_content

This approach requires establishing BurgessR3Maximal WITHOUT using burgessR3Maximal_from_g_content_sub. This is a major refactor.

### Approach 3: Weaken the Output

Since no callers exist for `lemma_2_6_splitting`, change its output to not include g_content conditions:

```
∃ B' D B'', BurgessR3Maximal A B' D ∧
  BurgessR3Maximal D B'' C ∧
  SetMaximalConsistent D ∧ β.neg ∈ D
```

For BurgessR3Maximal(A, B', D): use {beta.neg} ∪ g_content(A) seed (consistent from F(beta.neg) in A). Then burgessR3Maximal_from_g_content_sub.

For BurgessR3Maximal(D, B'', C): this STILL needs g_content(D) subset C. Without h_content(C) in the seed, this is not available.

Alternative: establish burgessR3(D, S, C) directly for some S, using the U-formulas in D from the seed. But D from Lindenbaum may not contain the right Until formulas.

### Approach 4: Add Density Axiom

Add a density axiom to BX that makes untl(bot, gamma) inconsistent. This would make the inconsistent case contradictory and allow g_content_sub_B to go through.

A density axiom like: `untl(phi, psi) → untl(phi, phi AND psi)` (for all phi, psi). Under open guard, this says: if the guard holds on (t,s), then at the witness s, both the guard and event hold. This requires the guard interval to be non-empty, which is density.

**Risk**: This changes the axiom system and may invalidate soundness for discrete orders.

### Approach 5: Direct D Construction (bypassing Lindenbaum)

Instead of Lindenbaum extending a seed, construct D directly as a specific MCS by choosing formulas carefully to satisfy all conditions. This would require a custom MCS construction that ensures both g_content(A) subset D and h_content(C) subset D.

This is essentially what the Burgess D0 proof does, but the consistency proof is the hard part.

## Recommended Next Step

**Approach 2 (Burgess D0 Seed)** is the plan's intended approach and the correct mathematical strategy. The implementation requires:

1. Define the Burgess D0 seed (B ∪ {beta.neg} ∪ S-formulas ∪ U-formulas)
2. Prove D0 consistent using the BX5+BX14+BX13 chain
3. Establish burgessR3(A, some_S, D) and burgessR3(D, some_S', C) DIRECTLY from the seed contents
4. Use burgessR3Maximal_extension_exists (NOT burgessR3Maximal_from_g_content_sub)

The consistency proof (step 2) requires showing that any finite subset of D0 is consistent. The argument constructs an Until formula in A whose event subsumes all components of the finite subset, then uses Lemma 2.2 (MCS consistency) to conclude.

**Estimated effort**: 8-10 hours (significantly more than the plan's 5 hours due to convention issues and the complexity of the BX chain proof).

## Key Axioms Needed

- BX5 (self_accum_until): `Axiom.self_accum_until φ ψ` — untl(phi, psi) → untl(phi AND untl(phi,psi), psi)
- BX14 (separation_until): `Axiom.separation_until p q r` — untl(q, p) AND not-untl(r, p) → untl(q, q AND not-r)
- BX14' (separation_since): `Axiom.separation_since p q r` — snce(q, p) AND not-snce(r, p) → snce(q, q AND not-r)
- BX13 (enrichment_until): `Axiom.enrichment_until φ ψ p` — p AND untl(phi, psi) → untl(phi, psi AND snce(phi, p))
- BX13' (enrichment_since): `Axiom.enrichment_since φ ψ p` — p AND snce(phi, psi) → snce(phi, psi AND untl(phi, p))
- BX3 (right_mono_until): G(psi → chi) → untl(phi, psi) → untl(phi, chi)
- BX10 (until_F): untl(phi, psi) → F(psi)
- BX10' (since_P): snce(phi, psi) → P(psi)

## Files

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — lines 824-907 (sorry sites and seed consistency)
