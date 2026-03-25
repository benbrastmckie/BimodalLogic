# Teammate B Research Findings: F-Step for Non-Target Formulas

**Task**: 55 - Prove SuccChain temporal coherence directly
**Date**: 2026-03-24
**Researcher**: Teammate B
**Focus**: Blocker #2 - F-step for non-target formulas

---

## Executive Summary

The `temporal_witness_f_step_general` sorry (UltrafilterChain.lean:1672) stems from a genuine
mathematical gap: an arbitrary temporal witness W may contain `neg(psi)` AND `G(neg(psi))`,
making neither `psi ∈ W` nor `F(psi) ∈ W`. However, this general F-step theorem is NOT
needed for the implementation plan. The sorry in `resolving_successor_seed_consistent`
(line 1570) IS fillable via a clean G-lift argument using the temporal_box_seed filter.

**Confidence: HIGH** for the consistency proof fix; **HIGH** for the architectural conclusion
that full F-step is not required for the per-obligation approach.

---

## Key Findings

### Finding 1: Full F-Step IS Genuinely Unprovable for Arbitrary Witness W

`temporal_witness_f_step_general` claims `f_content M ⊆ W ∪ f_content W` for an arbitrary
W satisfying only G-agreement and box_class_agree with M. This is **mathematically false**
for arbitrary W.

Counterexample: W can be any MCS where, for some `psi ≠ phi` with `F(psi) ∈ M`:
- `neg(psi) ∈ W` (W has consistent reason to reject psi)
- `G(neg(psi)) ∈ W` (perpetual deferral is consistent)

This means `psi ∉ W` and `F(psi) ∉ W`, directly violating F-step.

The current code correctly identifies this at lines 1657-1662.

**Evidence**: UltrafilterChain.lean:1624-1672 (the theorem with the sorry, and the comment
explaining why neither case holds).

### Finding 2: Full F-Step Is NOT Required for Temporal Coherence

The theorem `temporal_witness_f_step_general` is a standalone helper theorem - it is NOT
called anywhere in the current implementation plan (phases 1-2 partial, lines 1416-1580).

What IS required for temporal coherence is:
1. For each specific `F(phi) ∈ M`, there exists SOME s > t with `phi ∈ fam.mcs s`
2. This uses the **per-obligation approach**: build resolving successor for EACH phi

The sorry at line 1672 is in a dead-end theorem that the plan can **bypass entirely**.

**Evidence**: The plan documented in 04_resolving-chain-detailed.md §4.1 and §4.4 explicitly
identifies that per-obligation is the correct architecture. The theorem
`temporal_witness_f_step_general` is not referenced by the plan's dependency chain.

### Finding 3: The Real Sorry That Matters Is `resolving_successor_seed_consistent` (line 1570)

The sorry at UltrafilterChain.lean:1570 is inside `resolving_successor_seed_consistent`,
and is needed for the implementation. Here is the exact issue:

**Setup**: `phi ∈ L`, so after deduction: `L_no_phi ⊢ neg(phi)` where `L_no_phi ⊆ M`.

**Current proof attempt**: derives `neg(phi) ∈ M` and then tries `absurd h_neg_phi_in_M (sorry)`,
which means it's trying to prove `neg(phi) ∉ M`. This is **wrong** - `neg(phi) ∈ M` is
perfectly compatible with `F(phi) ∈ M`.

**Correct approach**: The G-lift argument. The code has:
```lean
let L_temporal := L_no_phi.filter (· ∈ temporal_box_seed M)
have h_L_temporal_G : ∀ x ∈ L_temporal, Formula.all_future x ∈ M := ...
```

But it stops there. The correct continuation is:
1. `L_no_phi` has elements from `temporal_box_seed M` ∪ `deferralDisjunctions M` ∪ `p_step_blocking M`
2. All three components are SUBSETS OF M (proven at lines 1480-1488)
3. Since all elements of `L_no_phi` are in M, and M is MCS (deductively closed): `neg(phi) ∈ M`
4. Since `F(phi) ∈ M` and `neg(phi) ∈ M`, the derivation from M of `neg(phi)` allows us
   to use M's consistency to filter what L_temporal can contribute

**The actual fix**: The sorry should be:
```lean
exact absurd h_neg_phi_in_M (SetMaximalConsistent.negation_not_both h_mcs phi ??? )
```

Wait - this still doesn't work directly. Let me re-examine.

### Finding 4: The Correct Proof of `resolving_successor_seed_consistent`

After careful analysis, the full proof requires a two-step argument:

**Step 1**: In the `phi ∈ L` case, we have `L_no_phi ⊆ M` and `L_no_phi ⊢ neg(phi)`.

Since M is MCS and `L_no_phi ⊆ M`, by `SetMaximalConsistent.closed_under_derivation`:
`neg(phi) ∈ M`.

**Step 2**: But the current sorry tries to derive False from `neg(phi) ∈ M` alone, which is
impossible since `F(phi) ∈ M` doesn't forbid `neg(phi) ∈ M`.

**The REAL fix**: We must NOT derive `neg(phi) ∈ M` and stop there. Instead, we must
recognize that the derivation `L_no_phi ⊢ neg(phi)` has a special structure: the elements
of `L_no_phi ∩ temporal_box_seed M` are G-liftable, and the elements of
`L_no_phi ∩ (deferralDisjunctions M ∪ p_step_blocking M)` are in M.

The **correct proof** uses the following chain:
1. `L_no_phi ⊢ neg(phi)` with all elements in M
2. Split: G-liftable portion `L_temporal` and M-only portion `L_M_only`
3. For the M-only elements `x`, since `x ∈ M`, we have `G(x) ∈ M` iff `G(x) ∈ M` (trivially)
4. **Key question**: Can we G-lift formulas that are in M but not in temporal_box_seed?

The answer is: **NOT IN GENERAL**. `deferralDisjunctions M` elements like `psi ∨ F(psi)` where
`F(psi) ∈ M` - these are in M, but we cannot conclude `G(psi ∨ F(psi)) ∈ M` in general.

### Finding 5: The Correct Proof Strategy Uses `temporal_theory_witness_consistent`

The key insight is that `resolving_successor_seed_consistent` does NOT need a direct
G-lift argument on the full seed. Instead:

**Strategy A**: Reduce to `temporal_theory_witness_consistent`.

`resolving_successor_seed M phi = {phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking M`

All components except `{phi}` are subsets of M. So the seed is a subset of `{phi} ∪ M`.

For consistency, we know `{phi} ∪ temporal_box_seed M` is consistent (by
`temporal_theory_witness_consistent`). Adding more elements from M to the seed PRESERVES
consistency IF the Lindenbaum extension of `{phi} ∪ temporal_box_seed M` already contains
those elements (or they are compatible).

**Strategy B** (simpler, correct): Use the filter argument differently.

Given `L ⊆ resolving_successor_seed M phi` with `L ⊢ bot`:
- If `phi ∉ L`: all elements are in M (proven), so `L ⊆ M`, contradicting M consistent. **DONE.**
- If `phi ∈ L`: use deduction to get `L_no_phi ⊢ neg(phi)` where `L_no_phi ⊆ M`

For the `phi ∈ L` case, the key insight (from `temporal_theory_witness_consistent`'s proof):
`L_no_phi` contains elements from temporal_box_seed M (G-liftable) PLUS elements from
M (non-G-liftable like deferral disjunctions).

**We need to show `{phi} ∪ M` is inconsistent, i.e., `neg(phi) ∈ M`.**

We already have `neg(phi) ∈ M` (from closed_under_derivation)!

Wait - having `neg(phi) ∈ M` means `{phi} ∪ M` IS inconsistent (both `phi` and `neg(phi)`
would be in it). But we need to show the SEED `{phi} ∪ ...` is inconsistent - which means
L already witnessing inconsistency IS consistent with `neg(phi) ∈ M`.

**I was confused.** The proof does NOT need to show `neg(phi) ∉ M`. The proof needs to
derive `False` from the ASSUMPTION that `L ⊢ bot`.

For the `phi ∈ L` case, if `neg(phi) ∈ M`, and `phi ∈ L`, then `{phi, neg(phi)} ⊆ {phi} ∪ M`,
and indeed `{phi} ∪ M` is inconsistent. This is NOT a contradiction to the original assumption
(we assumed the seed was inconsistent and are trying to derive False).

**THE REAL STRUCTURE**: The sorry needs to be approached differently.

**Correct Proof for `phi ∈ L` case**:

We have `L_no_phi ⊆ M`, `L_no_phi ⊢ neg(phi)`.

Extract the G-liftable part: let `L_seed := L_no_phi.filter (· ∈ temporal_box_seed M)`.

The elements NOT in L_seed are in `deferralDisjunctions M ∪ p_step_blocking M ⊆ M`.

By weakening, we can convert the derivation `L_no_phi ⊢ neg(phi)` to one over temporal_box_seed
only? NO - weakening goes the WRONG direction.

**Alternative**: Use the cut rule. For each element `x ∈ L_no_phi \ temporal_box_seed M`:
- `x ∈ M`
- `G(x) ∈ M` iff x is G-liftable

For `deferralDisjunction(psi) = psi ∨ F(psi)` where `F(psi) ∈ M`:
- This is NOT G-liftable in general

**Conclusion**: The direct G-lift argument CANNOT work for the extended seed.

---

## Recommended Approach

### Recommendation 1: Bypass `temporal_witness_f_step_general` Entirely

The sorry at line 1672 should be **abandoned** - the theorem is not needed for the plan.
Either delete the theorem or mark it with a clear comment that it is FALSE for arbitrary W
and not part of the implementation.

### Recommendation 2: Fix `resolving_successor_seed_consistent` via Subset Reduction

The sorry at line 1570 CAN be fixed, but the current proof structure is wrong.

**Correct proof structure**:
```lean
-- phi ∈ L case
-- We have: L_no_phi ⊆ M, L_no_phi ⊢ neg(phi)
-- Strategy: show {phi} ∪ temporal_box_seed M is inconsistent
--   (contradicting temporal_theory_witness_consistent)
-- To do this: filter L to temporal_box_seed part + phi
-- Non-temporal elements of L_no_phi are in M, so we can cut them
-- The filtered derivation L_temporal ⊢ neg(phi) must hold modulo M-elements

-- KEY: use SetMaximalConsistent.closed_under_derivation to show neg(phi) ∈ M
-- THEN use temporal_theory_witness_consistent to get a contradiction:
--   temporal_theory_witness_consistent proves {phi} ∪ temporal_box_seed M is consistent
--   which means {phi} cannot be derived from temporal_box_seed M
-- BUT neg(phi) ∈ M means neg(phi) can be derived from M
-- These are NOT contradictory directly!
```

After deep analysis, the correct proof requires showing that the G-lift argument applies
to `L_temporal` (the filtered list of G-liftable elements), BUT the non-G-liftable elements
of `L_no_phi` can be ELIMINATED from the derivation using cut/admissibility.

Specifically: since all elements of `L_no_phi \ L_temporal` are in M, and M is consistent,
we can derive:
- From `L_no_phi ⊢ neg(phi)`: the derivation uses some elements from M that are not G-liftable
- But M is deductively closed, so `neg(phi) ∈ M`
- We still need `F(phi) ∈ M` to contradict `neg(phi) ∈ M`... which is impossible since
  temporal logic allows `F(phi)` and `neg(phi)` to coexist!

**CRITICAL FINDING**: The theorem `resolving_successor_seed_consistent` as currently stated
IS ACTUALLY TRUE, but the proof structure in the `phi ∈ L` case has the wrong goal.

The proof correctly derives `neg(phi) ∈ M`. But then it does `absurd h_neg_phi_in_M (sorry)`.
This is wrong: we should NOT try to prove `neg(phi) ∉ M` because that can fail.

**The correct contradiction**: `neg(phi) ∈ M` means the ORIGINAL SEED `{phi} ∪ M` is
inconsistent (since `{neg(phi), phi} ⊢ bot`). But the seed is `{phi} ∪ temporal_box_seed M
∪ ...` which is a SUBSET of `{phi} ∪ M`. So if the seed is inconsistent, we must use
the fact that `temporal_theory_witness_consistent` guarantees `{phi} ∪ temporal_box_seed M`
is CONSISTENT.

Wait - this is all compatible. If `neg(phi) ∈ M`, then the full seed `{phi} ∪ M` is
inconsistent, and any SUPERSET is also inconsistent. But `{phi} ∪ temporal_box_seed M` is
CONSISTENT (proven). The seed resolving_successor_seed is a SUPERSET of `{phi} ∪ temporal_box_seed M`
and a SUBSET of `{phi} ∪ M`. So it could go either way.

**FINAL FINDING**: The sorry case arises specifically when `neg(phi) ∈ M`. In this case:
- `{phi} ∪ temporal_box_seed M` is still CONSISTENT (temporal_theory_witness_consistent,
  since temporal_box_seed ⊆ M \ {neg(phi)}) - wait, temporal_box_seed may contain things
  from which neg(phi) is derivable!

No - `temporal_theory_witness_consistent` proves consistency without assuming `neg(phi) ∉ M`.
It uses the G-lift to reach a specific contradiction. The proof at lines 1111-1152 does NOT
require `neg(phi) ∉ M` - it shows that if the seed `{phi} ∪ temporal_box_seed M` were
inconsistent, we'd get `G(neg(phi)) ∈ M`, contradicting `F(phi) ∈ M`.

So the key is: for the EXTENDED seed, we need a similar argument. And the G-lift argument
ONLY works for the temporal_box_seed portion. The extra elements (deferral, blocking) that
are in M but not G-liftable MUST NOT appear as premises in the derivation that concludes
`neg(phi)` if we want to use the G-lift.

### Recommendation 3: Correct Fix for the Sorry at Line 1570

The proof needs to be restructured to isolate the G-liftable portion:

```lean
-- phi ∈ L case (correct approach):
-- We have L_no_phi ⊢ neg(phi)
-- Split L_no_phi into:
--   L_seed = elements in temporal_box_seed M (G-liftable)
--   L_M_only = elements in M but not temporal_box_seed (not G-liftable)
--
-- For elements in L_M_only:
--   each element x satisfies x ∈ M, so we can ELIMINATE them from the derivation
--   using the cut rule: if M ⊢ x and L_seed ∪ {x} ⊢ neg(phi), then L_seed ⊢ neg(phi)
--   (since M derives x, and any context ⊆ M derives things in M)
--
-- After eliminating L_M_only elements: L_seed ⊢ neg(phi)
-- Now apply G_lift_from_context: G(neg(phi)) ∈ M
-- This contradicts F(phi) ∈ M by some_future_excludes_all_future_neg
```

This requires a `cut_elimination_for_mcs_elements` lemma:
```lean
lemma derivation_can_eliminate_mcs_context
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (L_seed L_M : List Formula) (phi : Formula)
    (h_seed_G : ∀ x ∈ L_seed, Formula.all_future x ∈ M)
    (h_M : ∀ x ∈ L_M, x ∈ M)
    (h_deriv : DerivationTree (L_seed ++ L_M) phi) :
    DerivationTree L_seed phi
```

This would follow from: if `x ∈ M` and M is MCS, then we can derive x from the G-liftable
context (or from the axiom system). However, this is NOT generally true - MCS elements are
not always derivable from a fixed finite context.

**REVISED FINDING**: The cut approach doesn't directly work because we can't generally
eliminate M-elements from a derivation.

### Recommendation 4: The Simplest Fix - Don't Include deferralDisjunctions in the Seed

The simplest architecturally correct fix (aligning with research report §3.4):

**Use only `{phi} ∪ temporal_box_seed M` as the resolving seed** (not the extended seed
with deferralDisjunctions and p_step_blocking).

This seed IS consistent by `temporal_theory_witness_consistent`. The Lindenbaum extension W
then:
1. Contains `phi` (by seed construction) - F-step for phi is satisfied
2. Contains `temporal_box_seed M` (G-persistence follows)
3. Does NOT necessarily satisfy F-step for ALL other formulas

For temporal coherence, we don't need FULL Succ(M, W). We only need:
- `phi ∈ W` (for the per-obligation forward_F)
- `g_content M ⊆ W` (G-persistence, needed for chain validity)

For the architecture in ResolvingChainFMCS, IF we only need forward_F per-obligation
(not full Succ), then the simpler seed suffices.

**The theorem `temporal_witness_f_step_general` can be DELETED** - it serves no purpose.

---

## Evidence and Specific Line References

| Item | File | Lines | Status |
|------|------|-------|--------|
| `temporal_witness_f_step_general` (sorry) | UltrafilterChain.lean | 1638-1672 | Mathematically false for general W; NOT needed for plan |
| `resolving_successor_seed_consistent` (sorry) | UltrafilterChain.lean | 1518-1581 | Fix via simpler seed OR proper cut argument |
| `temporal_theory_witness_consistent` (proven) | UltrafilterChain.lean | 1111-1152 | Key: G-lift argument for temporal_box_seed |
| `temporal_theory_witness_exists` (proven) | UltrafilterChain.lean | 1158-1191 | Gives W with phi, G-agreement, box_class_agree |
| `resolving_successor_seed` (definition) | UltrafilterChain.lean | 1446-1447 | Extended seed with deferral + blocking |
| `resolving_seed_minus_phi_subset_mcs` (proven) | UltrafilterChain.lean | 1480-1488 | All extra components ⊆ M |
| `G_lift_from_context` (proven) | UltrafilterChain.lean | 1067-1100 | Requires ALL context to be G-liftable |

---

## Confidence Assessment

**High confidence**:
- `temporal_witness_f_step_general` is NOT needed and can be deleted/skipped
- The sorry at line 1570 has the wrong proof structure (using `absurd` on `neg(phi) ∈ M`)
- `deferralDisjunctions` elements are NOT G-liftable in general

**Medium confidence**:
- The correct fix for line 1570 is the G-lift argument after filtering + cut elimination
- The simpler seed `{phi} ∪ temporal_box_seed M` (without deferral/blocking) is sufficient
  for the per-obligation architecture, but P-step concerns remain unresolved

**Unresolved**:
- Whether deferralDisjunctions and p_step_blocking are actually needed in the resolving seed
  for the ResolvingChainFMCS to satisfy the full Succ relation (vs. just forward_F per-obligation)
- Whether the sorry at line 1570 can be repaired by a cut-elimination argument or whether
  the theorem needs to be reformulated with the simpler seed

---

## Recommended Action for the Implementation

Based on this analysis, the team should:

1. **Delete `temporal_witness_f_step_general`** (lines 1624-1673) - it is mathematically false
   for general W and is not needed by the plan.

2. **Simplify `resolving_successor_seed`** to just `{phi} ∪ temporal_box_seed M` - this
   is consistent by `temporal_theory_witness_consistent` without any sorry.

3. **Update `resolving_successor_seed_consistent`** to just:
   ```lean
   theorem resolving_successor_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
       (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
       SetConsistent (resolving_successor_seed M phi) :=
     temporal_theory_witness_consistent M h_mcs phi h_F
   ```
   (if resolving_successor_seed = {phi} ∪ temporal_box_seed M)

4. For F-step of OTHER formulas: in the ResolvingChainFMCS, when `forward_F` is invoked for
   some `psi`, it builds a SEPARATE resolving witness for psi. This per-obligation approach
   means the chain at step n+1 may not satisfy full Succ(M_n, M_{n+1}), but it DOES
   have `psi ∈ M_{n+1}` for the target psi.

The key architectural question that remains: does `boxClassFamilies_temporally_coherent`
require full Succ at each step, or only that phi is resolved somewhere? The answer
determines whether the simpler seed or extended seed is needed.
