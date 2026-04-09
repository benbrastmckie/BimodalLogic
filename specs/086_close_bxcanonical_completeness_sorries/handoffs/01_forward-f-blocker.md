# Handoff: Forward-F Blocker in usf_completeness

**Task**: 86 -- Close BXCanonical completeness sorries
**Session**: sess_1775715334_7579f6
**Date**: 2026-04-09
**Agent**: lean-implementation-agent

## Status

- Phase 1 (box_preserved_along_bx_le): COMPLETED, sorry-free
- Phases 2-5: BLOCKED by forward_F property
- No new sorries introduced, no regressions

## Completed Work

### Phase 1: Box Preservation (Frame.lean)

Three new lemmas added to `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`:

1. **`neg_box_to_box_neg_box`**: S5 negative introspection derivation tree
   - `[] |- (box phi).neg -> box((box phi).neg)`
   - Uses modal_5_collapse + contraposition + double negation

2. **`box_preserved_along_bx_le`**: Box formulas preserved both directions along bx_le
   - Forward: temp_future + bx_G_forward
   - Backward: contrapositive via neg_box_to_box_neg_box + temp_future + bx_G_forward + modal_t

3. **`bx_modal_equiv_of_bx_le`**: Modal equivalence holds for bx_le-related points
   - Immediate corollary of box_preserved_along_bx_le

### Phase 1 Corollary (CanonicalEmbedding.lean)

4. **`modal_omega_eq_of_bx_le`**: modal_omega is invariant along bx_le chains
   - Uses bx_modal_equiv_of_bx_le + existing modal_omega_eq_of_equiv

All four lemmas are sorry-free and build successfully.

## Blocker Analysis: Forward-F on Chains

### The Problem

The sorry at `usf_completeness` imp Case B requires a bidirectional truth lemma
for USF formulas. The G backward direction of the truth lemma requires
`forward_F` on the chain:

```
forward_F: F(psi) in chain(t) -> exists s > t, psi in chain(s)
```

### Why Simple Chains Fail

The plan proposed a dovetail chain using `Encodable.decode n` to check formula n
at step n+1. Extensive analysis revealed this DOES NOT satisfy forward_F:

1. **Scheduling gap**: Formula phi's encoding k might be < step t. At step k+1,
   the chain checked phi and took a backward witness. But at step t (later),
   G(neg phi) might have entered the chain through a different witness, killing
   F(phi) permanently.

2. **G-completeness failure**: The property "G(alpha) not-in chain(s) implies
   exists r > s, alpha not-in chain(r)" is FALSE for simple enumeration chains
   because:
   - G(alpha) might enter at step s+1 via a witness for a different formula
   - Once G(alpha) enters, alpha is in all subsequent chain points (by BX1)
   - No later step checks alpha again (each formula checked exactly once)

3. **Fair scheduling (Nat.unpair) insufficient**: Even with fair scheduling,
   the gap between consecutive checks of alpha might be larger than the interval
   before G(neg alpha) enters the chain.

### Root Cause

The fundamental issue: resolving one F-obligation (by taking a G-backward witness)
can KILL other pending F-obligations by introducing new G-formulas. This is because
`bx_G_backward` uses Classical.choice and Lindenbaum extension, which may add
arbitrary G-formulas to the witness MCS.

### G-contrapositive is NOT a theorem

The plan claimed: "if alpha in chain(r) for all r >= s, then G(alpha) in chain(s)".
This is FALSE. Having alpha at all chain points only means alpha is at countably
many BXPoints. G_iff_mcs requires alpha at ALL BXPoints above chain(s),
including uncountably many non-chain-point BXPoints.

The CORRECT approach is the contrapositive via forward_F:
- Assume G(alpha) not-in chain(s)
- Then F(neg alpha) in chain(s) (temporal duality)
- By forward_F: exists r > s, neg alpha in chain(r)
- But we assumed alpha in chain(r) for all r > s. Contradiction.

This approach requires forward_F, which is the blocker.

## Viable Paths Forward

### Path 1: Combined F-Seed Extension (Recommended)

At each chain step, instead of resolving ONE F-obligation, extend using a combined
seed that preserves ALL pending F-obligations:

```
seed = {psi_1, ..., psi_k} union g_content(M) union box_content(M)
```

where F(psi_i) in M for each i. Need to prove this seed is consistent. The
standard proof uses compactness + temporal duality: any inconsistent finite
subset leads to a contradiction with M being an MCS.

This is the standard technique from Goldblatt 1992 / Burgess 1984.

**Difficulty**: Medium. Requires proving the combined seed consistency lemma,
which is a non-trivial MCS argument involving temporal duality and generalized
temporal K.

### Path 2: Restricted Completeness

Use `RestrictedMCS` from `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean`
to work within the finite subformula closure of the target formula. Forward_F
is provable for finite closures because nesting is bounded.

**Difficulty**: High. The existing `SuccChainFMCS.lean` has ~10 sorries in the
restricted chain infrastructure. Would need to fix those first.

### Path 3: Algebraic / Bundle Approach

Use the existing `ParametricTruthLemma` with a `TemporalCoherentFamily`.
Build the family using the algebraic ultrafilter chain from
`Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`.

**Difficulty**: High. The algebraic path has its own sorries and complex
dependencies. May require significant infrastructure work.

### Path 4: Zorn's Lemma Chain

Use Zorn's lemma to find a maximal chain satisfying forward_G and backward_H.
On a maximal chain, forward_F holds by maximality (if F(psi) in chain(t) and
psi not in any chain(r) for r > t, the chain can be extended, contradicting
maximality).

**Difficulty**: Medium-High. Requires formulating the appropriate partial order
on chains and proving the chain condition for Zorn.

## Key Existing Infrastructure

- `G_iff_mcs` (TruthLemma.lean): G(phi) in w iff forall v >= w, phi in v -- SORRY-FREE
- `H_iff_mcs` (TruthLemma.lean): H(phi) in w iff forall v <= w, phi in v -- SORRY-FREE
- `box_iff_mcs` (TruthLemma.lean): box(phi) in w iff forall v ~ w, phi in v -- SORRY-FREE
- `bx_forward_witness` (Frame.lean): F(psi) in w -> exists v >= w, psi in v -- SORRY-FREE
- `bx_backward_witness` (Frame.lean): P(psi) in w -> exists v <= w, psi in v -- SORRY-FREE
- `temporal_backward_G_with_fwd_F` (TemporalCoherence.lean): forward_F + all-future -> G -- SORRY-FREE
- `box_preserved_along_bx_le` (Frame.lean): box preserved both directions -- SORRY-FREE (NEW)
- `bx_modal_equiv_of_bx_le` (Frame.lean): bx_le implies modal equiv -- SORRY-FREE (NEW)
- `modal_omega_eq_of_bx_le` (CanonicalEmbedding.lean): modal_omega invariant -- SORRY-FREE (NEW)

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean`: Added 3 lemmas (Phase 1)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean`: Added modal_omega_eq_of_bx_le

## Recommendation

Path 1 (Combined F-Seed Extension) is the most direct and requires the least
new infrastructure. The key lemma to prove is:

```lean
theorem combined_F_seed_consistent (w : BXPoint)
    (L : List Formula) (hL : forall psi in L, Formula.some_future psi in w.formulas) :
    SetConsistent (L.toFinset union g_content w.formulas)
```

Once this is proved, the chain can be built by resolving ALL F-obligations at
each step, and forward_F follows immediately.
