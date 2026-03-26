# Teammate C Findings: Cross-Chain Witness Propagation Risk Analysis

## Key Findings

### The Two Primary Sorries (Lines 3892 and 3917)

Both sorries are in `build_restricted_tc_family` in `SuccChainFMCS.lean`, which constructs
a `RestrictedTemporallyCoherentFamily` by packaging the seed with coherence proofs.

**Sorry 1 (Line 3892)**: `Int.negSucc k` case of `forward_F`
- Context: `F(psi)` is in the **backward chain** at negative position `-(k+1)`
- Goal: Find `m > -(k+1)` such that `psi ∈ restricted_succ_chain_fam phi seed m`
- Problem: `restricted_forward_chain_forward_F` only handles the forward chain
- No cross-chain lemma (`restricted_backward_chain_forward_F`) exists or is defined anywhere

**Sorry 2 (Line 3917)**: `Int.ofNat (k+1)` case of `backward_P`
- Context: `P(psi)` is in the **forward chain** at positive position `k+1`
- Goal: Find `m < k+1` such that `psi ∈ restricted_succ_chain_fam phi seed m`
- Problem: `restricted_backward_chain_backward_P` only handles the backward chain
- No cross-chain lemma (`restricted_forward_chain_backward_P`) exists or is defined anywhere

**Critical observation**: The names `restricted_backward_chain_forward_F` and
`restricted_forward_chain_backward_P` appear nowhere in the codebase. These lemmas
have never been stated or proven.

### The `restricted_succ_chain_fam` Structure

```
restricted_succ_chain_fam phi M0 (Int.ofNat k)  = restricted_forward_chain phi M0 k
restricted_succ_chain_fam phi M0 (Int.negSucc k) = restricted_backward_chain phi M0 (k+1)
```

The forward and backward chains are **independent constructions** sharing only `M0` as
the common seed at position 0. There is no built-in mechanism for F-obligations in the
backward chain to be witnessed in the forward chain, or vice versa.

## Risks Identified

### Risk 1: Fundamental Independence of the Two Chains (HIGH)

The forward chain and backward chain are built by independent iterated applications of
`constrained_successor_restricted` and `constrained_predecessor_restricted` respectively.
These two chains share only the seed `M0` at position 0.

When `F(psi) ∈ backward_chain(k+1)`, the backward chain was constructed by adding
predecessors - it has **no structural guarantee** that a forward chain element
contains `psi`. The forward chain was built entirely separately from the
F-obligations in the backward chain.

This is an **architectural risk**: the proof of `forward_F` for backward-chain positions
requires information about `psi` appearing in the forward chain, but the forward chain
construction had no knowledge of what `F`-formulas would appear in the backward chain.

### Risk 2: Missing Lemmas Are Not Trivially Derivable (HIGH)

For `restricted_backward_chain_forward_F` to hold, one would need:
- `F(psi) ∈ backward_chain(n)` implies some forward chain element contains `psi`

But `F(psi) ∈ backward_chain(n)` only tells us something about a world at negative time.
The backward chain was seeded from `constrained_predecessor_seed_restricted`, which uses
`h_content` (H-closure) and `f_step_blocking_formulas_restricted`. Neither of these
guarantees that `psi` itself appears anywhere in the forward direction.

### Risk 3: The Termination Sorry in `restricted_bounded_witness` (MEDIUM)

Both `restricted_bounded_witness` (line 2405) and `restricted_backward_bounded_witness`
(line 3824) use `all_goals sorry` for termination in their `decreasing_by` blocks.
These are the very lemmas that prove F/P witnesses exist in the respective chains.

The forward sorry chain: `build_restricted_tc_family` calls `restricted_forward_chain_forward_F`,
which calls `restricted_forward_chain_iter_F_witness`, which calls `restricted_bounded_witness`,
which has a termination sorry. So the **already-proven cases** also rest on unproven
termination.

### Risk 4: `constrained_predecessor_restricted_g_persistence_reverse` Sorry (MEDIUM)

Line 3360: The G-persistence reverse theorem is sorry'd. This is used in
`constrained_predecessor_restricted_succ`, which establishes the Succ relation for
predecessor elements. If this sorry is not provable, the backward chain's Succ relation
breaks.

The core difficulty is circular: proving `g_content(predecessor) ⊆ u` requires showing
that G-formulas entering via the Lindenbaum extension must be constrained. The comments
in the code explicitly identify this as potentially unprovable without additional
construction constraints.

### Risk 5: `constrained_predecessor_restricted_f_step_forward` Sorry (MEDIUM)

Line 3420: The case where `chi ∉ u` and `F(chi) ∉ u` but `F(chi) ∈ predecessor` is
sorry'd. This is needed for the Succ relation (f_step property). Without it, the
predecessor construction may not satisfy Succ at all.

### Risk 6: Seed Consistency Sorries Block Successor Construction (MEDIUM)

Three sorries block the consistency of the successor seed:
- Line 1435: `neg_not_in_boundary_resolution_set` - declared potentially unprovable
- Line 1480: `augmented_seed_consistent` - depends on line 1435
- Line 1543: `constrained_successor_seed_restricted_consistent` - the main consistency proof

If the successor seed cannot be proven consistent, `constrained_successor_restricted`
(the forward chain step) itself fails.

## Blocker Analysis

### Blocker A: Cross-Chain Witness Problem (FUNDAMENTAL)

**The problem**: At negative positions, F(psi) can appear in the backward chain. The
backward chain is built from `constrained_predecessor_restricted`, which is seeded from
`h_content(M0)` and related backward-looking content. There is no structural reason why
`psi` must appear in any positive-time forward chain element.

**Potential resolution approaches**:

1. **Accept a weakening**: Change the `forward_F` property to only guarantee witnesses
   within the same chain direction (F in backward chain witnesses a "less negative" backward
   chain element). This would require changing the `RestrictedTemporallyCoherentFamily`
   definition and all downstream uses.

2. **Joint construction**: Build the forward and backward chains simultaneously with
   cross-obligations tracked. This is a major architectural change.

3. **Restrict to positive-only**: Argue that F-obligations in backward-chain positions
   are automatically satisfied by the backward chain's own structure (moving toward 0).
   This would mean `psi` appears at backward position -(k+1) + d for some d, which could
   be at position 0 (= forward chain position 0 = backward chain position 0). This is the
   most promising approach - if the backward chain is P-oriented, F-obligations in it may
   propagate forward toward 0 via the existing Succ structure.

4. **Exploit the shared seed at 0**: Since `restricted_forward_chain phi M0 0 = restricted_backward_chain phi M0 0 = M0.world`, F-obligations with small nesting could be witnessed by demonstrating that the backward chain itself approaches M0 from the left, and M0 connects to the forward chain on the right.

**Assessment**: Approach 3/4 combined looks most promising but requires careful analysis.
The backward chain at positions -(k+1) has `F_top ∈ restricted_backward_chain phi M0 k` per
the construction, but `F(psi)` in a backward chain element would need `psi` resolved in a
forward-direction element. The Succ relation `Succ(backward_chain(n), backward_chain(n-1))`
gives `f_content(backward_chain(n)) ⊆ backward_chain(n-1) ∪ f_content(backward_chain(n-1))`.
This means F-obligations propagate toward 0 in the backward direction, and eventually hit
`backward_chain(0) = forward_chain(0)`, from which they enter the forward chain.

### Blocker B: Termination Sorry in `restricted_bounded_witness` (SUPPORTING)

This sorry affects both the F-coherence proof in the forward chain and the P-coherence
proof in the backward chain. Even the cases that appear "resolved" rely on this. The
termination argument requires showing that the depth parameter `d` strictly decreases across
recursive calls in the `d' > 1` branch. This is a well-foundedness argument that `simp_wf`
fails to discharge automatically.

### Blocker C: Predecessor Sorry Chain (SUPPORTING)

The G-persistence reverse sorry (line 3360) and the f_step_forward sorry (line 3420) mean
that `constrained_predecessor_restricted_succ` returns a `sorry`-based proof. The backward
chain's Succ relation is therefore not yet verified.

## Impossibility Analysis

**Is cross-chain witness propagation fundamentally impossible?**

Not necessarily impossible, but it requires a structural argument not yet in place.

The key insight: If `F(psi)` appears in `backward_chain(n)` (at time `-(n+1)`), and
the backward chain satisfies Succ relations, then `f_content(backward_chain(n)) ⊆
backward_chain(n-1) ∪ f_content(backward_chain(n-1))`. This eventually forces `psi` to
appear at `backward_chain(0)` or propagate into F-content. Since
`backward_chain(0) = forward_chain(0)`, this gives `psi ∈ forward_chain(0)` or
`F(psi) ∈ forward_chain(0)`. In the second case, `restricted_forward_chain_forward_F`
then gives a positive witness.

This is a multi-step argument that requires:
1. Inductive application of the Succ f-step property along the backward chain
2. The shared seed at 0 as a bridge
3. Then the forward chain's own F-coherence

**Potential failure mode**: If `psi ∉ deferralClosure(phi)`, then the restricted
construction may not track `psi` at all. But if `F(psi) ∈ backward_chain(n)`, then
`F(psi) ∈ deferralClosure(phi)` (by DRM property), and `psi ∈ deferralClosure(phi)`
follows from the subformula closure structure. So this failure mode may not arise.

## Confidence Level

**Overall confidence in completing the two primary sorries**: MEDIUM

- The sorry at line 3892 (F in backward chain) is **solvable** via the propagation-to-0 argument described above, but it requires the Succ relation sorries (blocker C) to be resolved first.
- The sorry at line 3917 (P in forward chain) is **similar**: P-obligations in the forward chain propagate backward toward 0 via the p-step property, then enter the backward chain at 0, from which `restricted_backward_chain_backward_P` provides the witness.
- The termination sorries (blocker B) are **concerning** because they undermine the chain coherence proofs that the cross-chain resolution depends on.
- The seed consistency sorries (blocker A secondary) require careful analysis of whether `neg_not_in_boundary_resolution_set` is provable or whether the construction needs adjustment.

**Confidence in termination sorry resolution**: LOW - `simp_wf` fails, and the d' > 1 case's recursion pattern is non-obvious.

**Confidence in seed consistency sorry resolution**: MEDIUM - the `neg_not_in_boundary_resolution_set` was explicitly flagged as potentially unprovable, suggesting the boundary_resolution_set definition may need revision.

**Recommended priority order**:
1. Resolve seed consistency (lines 1435, 1480, 1543) - prerequisite for forward chain construction
2. Resolve termination (lines 2405, 3824) - prerequisite for F/P coherence lemmas
3. Resolve G-persistence reverse (line 3360) and f_step_forward (line 3420) - prerequisite for backward chain's Succ property
4. Prove cross-chain bridge using propagation-to-0 argument (lines 3892, 3917)
