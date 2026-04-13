# Research Report: Backward Until/Since Sorries in Frame.lean

**Task**: 102 - Implement quotient filtration / close sorries
**Date**: 2026-04-12
**Session**: sess_1776056563_9f800a
**Focus**: Analysis of `bx_until_backward` and `bx_since_backward` provability

## Current Sorry Signatures

### bx_until_backward (Frame.lean:650-656)

```lean
noncomputable def bx_until_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_φw : φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas := by
  sorry
```

### bx_since_backward (Frame.lean:688-694)

```lean
noncomputable def bx_since_backward
    (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_vw : bx_le v w) (h_ψv : ψ ∈ v.formulas)
    (h_φw : φ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.snce φ ψ ∈ w.formulas := by
  sorry
```

These are the last 2 sorries in Frame.lean. The forward eventuality resolution
sorries (`bx_until_eventuality_resolution`, `bx_since_eventuality_resolution`)
were already closed in earlier rounds.

## Finding: The Statements Are Unsound (Unprovable)

### Semantic Counterexample

The statement `bx_until_backward` asserts:

> Given `phi in w`, `psi in v`, `bx_le w v`, `psi not in w`,
> derive `phi U psi in w`.

This is **not semantically valid**. Consider a linear temporal model with
three time points t=0, t=1, t=2:

- w at t=0: phi holds, psi does not hold
- u at t=1: phi does NOT hold
- v at t=2: psi holds

Here: phi in w, psi in v, w <= v, psi not in w. But `phi U psi` at w
requires phi to hold at ALL points in [w, v) = {0, 1}. Since phi fails
at t=1, `phi U psi` does NOT hold at w.

The hypothesis only provides `phi in w` (phi at the starting point), but
`phi U psi` semantically requires phi at all intermediate points in the
half-open interval [w, v).

### Why This Cannot Be Fixed By Proof Strategy Alone

No combination of BX axioms can derive `phi U psi in w` from these
hypotheses because the statement is not a theorem of any sound temporal
logic:

1. **BX8 (refl intro)**: `psi -> phi U psi` -- but psi is at v, not w.
2. **BX12 + left mono**: Would need `G(phi) in w`, not just `phi in w`.
3. **Contradiction via enriched seed**: Assuming `neg(phi U psi) in w`:
   - We can derive `F(psi) in w` from `bx_le w v` and `psi in v`
   - We can derive `(top U psi) in w` from BX12
   - But `neg(phi U psi)` and `(top U psi)` are NOT contradictory
   - `neg(phi U psi)` says "there is no witness with phi-guard", while
     `top U psi` says "there is a witness with vacuous guard" -- both can
     coexist when phi fails at an intermediate point.

### Root Cause (Confirmed from Round 5)

The backward direction requires the **full interval guard**:
```
forall u, bx_le w u -> bx_le u v -> phi in u
```

But the round 5 research established that this universal quantification
over all BXPoints in the bx_le interval is ALSO unprovable, because
bx_le admits "junk points" from unrelated Lindenbaum extensions.

The weakening from universal guard to `phi in w` was an attempt to make
the signatures easier, but it made them semantically unsound.

## Analysis of Proposed Approaches

### Approach 1: BX9 Direct Application

**Verdict**: Does not apply.

BX9 says `(phi U psi) -> (phi or psi)`. This is the elimination rule,
not the introduction rule. The contrapositive `(neg phi and neg psi) ->
neg(phi U psi)` goes the wrong direction. No BX axiom provides a direct
introduction rule for `phi U psi` from membership facts at different points.

### Approach 2: Contradiction via enriched_seed_consistent_until

**Verdict**: Insufficient.

The enriched seed `{neg(phi U psi)} union g_content(w) union h_content(v)`
is consistent (proved in Realization.lean:197). Extending to an MCS gives
a world u with:
- `neg(phi U psi) in u`
- `bx_le w u` (from g_content(w) subset u)
- `h_content(v) subset u`

But we cannot derive a contradiction from this. The enriched seed
consistency is used for constructing witnesses, not for discharging goals.

### Approach 3: enriched_seed_consistent_until Bridge

**Verdict**: Wrong direction.

`enriched_seed_consistent_until` proves that the seed containing
`neg(phi U psi)` is consistent. For our purposes, we need the OPPOSITE:
that assuming `neg(phi U psi)` leads to inconsistency. The existing lemma
supports world construction, not contradiction.

### Approach 4: BX4 (Connectedness) + BX12 (F-Until Bridge)

**Verdict**: Closes part of the gap but not all.

From the hypotheses we can derive:
1. `F(psi) in w` (via F_from_witness, already proved)
2. `(top U psi) in w` (from BX12: F(psi) -> top U psi)

But converting `top U psi` to `phi U psi` requires `G(phi) in w` for
BX2 (left monotonicity), which we don't have. Having `phi in w` alone
is insufficient.

### Approach 5: MCS Negation Completeness

**Verdict**: Insufficient without a valid derivation path.

By negation completeness: either `phi U psi in w` or `neg(phi U psi) in w`.
Assuming `neg(phi U psi) in w`, we derived:
- `neg psi in w` (from BX8 contrapositive)
- `F(psi) in w` (from witness existence)
- `(top U psi) in w` (from BX12)

None of these contradict `neg(phi U psi) in w`, because `neg(phi U psi)`
is compatible with `F(psi)` -- the psi-witness exists but phi fails on
the guard interval.

## Recommended Strategy

### Assessment: The Current Sorry Signatures Must Be Changed

**Confidence**: HIGH (95%)

The current `bx_until_backward` and `bx_since_backward` signatures are
semantically unsound and therefore unprovable. No proof strategy can close
them as written.

### Option 1: Bypass Frame.lean Entirely (Recommended)

**Confidence**: 70%
**Effort**: Medium (chain truth lemma restructure)

The truth lemma for Until does not need to go through `bx_until_backward`
at all. Instead, reformulate the Until backward direction at the truth
lemma level using a chain-based construction:

1. The canonical model embeds BXPoints into a TaskModel
2. In the TaskModel, worlds are organized along world histories (chains)
3. Along a chain, the deterministic backward induction works (using
   `until_intro` and the chain successor relation)
4. The truth lemma for Until at a BXPoint w uses the chain containing w

This approach is already sketched in the DeterministicFMCS.lean boneyard
code. The key insight: the truth lemma only needs to work for points that
appear in world histories, not for arbitrary BXPoints.

### Option 2: Mark the Sorries as Architecturally Dead Code

**Confidence**: 90%
**Effort**: Low (documentation + deletion)

If the completeness proof is restructured to bypass Frame.lean (Option 1),
then `bx_until_backward` and `bx_since_backward` become dead code. They
can be:
1. Documented as having unsound signatures
2. Deleted (along with all delegation bridges in CanonicalChain.lean,
   Realization.lean, LocusControl.lean, TruthLemma.lean)
3. Replaced by chain-level truth lemma functions

### Option 3: Delete and Replace with Correct Signatures

**Confidence**: 50%
**Effort**: High

Replace with signatures that are semantically correct AND provable:
```lean
noncomputable def bx_until_backward_chain
    (chain : Nat -> BXPoint) (n m : Nat) (h_nm : n < m)
    (phi psi : Formula)
    (h_chain_ordered : forall i, bx_le (chain i) (chain (i+1)))
    (h_psi : psi in (chain m).formulas)
    (h_phi : forall k, n <= k -> k < m -> phi in (chain k).formulas) :
    Formula.untl phi psi in (chain n).formulas
```

This is provable by induction on `m - n` using the pattern from
DeterministicFMCS.lean's `backward_until_chain`, adapted to work with
`bx_le` chains instead of the deterministic successor relation.

However, this requires restructuring the truth lemma callers and the
completeness proof to work with chain-indexed points.

## Mathlib Lemmas That Could Help

None directly applicable. The issue is not a missing Mathlib fact but a
fundamental architecture mismatch between the bx_le ordering (which
admits uncontrollable intermediate points) and the Until guard condition
(which requires control over all intermediate points).

## Summary

| Aspect | Finding |
|--------|---------|
| Provability of current signatures | **UNPROVABLE** (semantically unsound) |
| Root cause | Missing interval guard: `phi in w` is weaker than `forall u in [w,v), phi in u` |
| Round 5 weakening | Made signatures even more wrong (from hard-but-correct to impossible) |
| Recommended path | Bypass Frame.lean; restructure truth lemma to use chain-level proof |
| Confidence | 95% that current signatures cannot be closed |
| Impact | TruthLemma.lean callers, CanonicalChain.lean, Realization.lean, LocusControl.lean need restructuring |

## Files Referenced

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` (lines 646-694): Current sorry locations
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` (lines 298-337): Callers
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` (lines 164-188): Delegation bridges
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/Realization.lean` (lines 197-294): Enriched seed consistency
- `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/LocusControl.lean`: Primed delegation variants
- `Theories/Bimodal/ProofSystem/Axioms.lean` (lines 120-274): BX axiom system
- `Theories/Bimodal/Theorems/TemporalDerived.lean` (lines 401-413): until_intro/since_intro
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` (lines 340-396): Working chain-based backward induction
- `Theories/Bimodal/Metalogic/BXCanonical/Filtration/DefectChain.lean`: Defect counting infrastructure
