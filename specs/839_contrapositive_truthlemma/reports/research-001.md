# Research Report: Task #839

**Task**: Contrapositive Approach to TruthLemma Backward Direction
**Date**: 2026-02-03
**Focus**: Can proving the contrapositive + bounded temporal depth resolve the G/H backward sorries?

## Summary

The user proposes using the contrapositive of the backward direction:
- **Original**: `(forall s >= t, phi true at s) -> G phi in MCS at t`
- **Contrapositive**: `G phi not-in MCS at t -> exists s >= t, phi false at s`

Combined with the observation that formulas have finite "temporal depth" (they can only "look" finitely far into the future), the question is whether this approach is viable.

**Key Finding**: The contrapositive approach is **sound mathematically** but **does not resolve the proof engineering challenge**. The core obstacle is that while we can derive the negation `not-G phi = F(not-phi)` is in the MCS, we cannot extract a **concrete witness time** from MCS membership. The MCS tells us "some time exists" but doesn't tell us which one.

## Analysis

### Question 1: Is the Contrapositive Actually Easier?

**The Semantic Level**: At the semantic level, the contrapositive is classically equivalent:
```
(forall s >= t, phi@s) -> G phi in MCS@t
  <==>
G phi not-in MCS@t -> not (forall s >= t, phi@s)
  <==>
G phi not-in MCS@t -> exists s >= t, not phi@s
```

**What Negation Completeness Gives Us**:
From `set_mcs_negation_complete` (MCSProperties.lean:174-227):
```
G phi not-in MCS@t -> (G phi).neg in MCS@t
```

Now, `(G phi).neg = (G phi) -> bot = ¬(G phi)`.

In temporal logic, `¬G phi` is semantically equivalent to `F(¬phi)` where F = "some future time":
```lean
def some_future (phi : Formula) : Formula := phi.neg.all_future.neg  -- ¬G¬phi
```

So `¬(G phi) = ¬(G phi)` which is `F(¬phi)` by duality... but wait:
- `¬G phi = ¬(all_future phi)`
- `F psi = some_future psi = ¬(all_future (¬psi)) = ¬G(¬psi)`

So `¬G phi ≠ F(¬phi)` directly. We have:
- `¬G phi = ¬(forall s>t. phi@s)` = "not always phi in future"
- `F(¬phi) = ¬G(¬¬phi) = ¬G(phi)` (using double negation elimination)

**Actually, they ARE equivalent classically**: `¬G phi ↔ F(¬phi)` via:
```
¬(forall s>t. phi@s) ↔ exists s>t. ¬phi@s
```

### The Witness Extraction Problem

Here's where the contrapositive approach **fails to help**:

Even if we know `(G phi).neg in MCS@t`, which semantically means "there exists some s >= t where phi fails", we cannot extract **which** s from the MCS.

The MCS is a set of formulas (a syntactic object). It contains `¬G phi`, which asserts existence, but:
1. The MCS has no distinguished "witness" for existential claims
2. The truth lemma relates MCS membership to truth at a **specific** time/family
3. We need to exhibit a concrete `s` where `phi` is false

**Concretely**: The IndexedMCSFamily gives us `fam.mcs t : Set Formula` at each time t. If `¬G phi in fam.mcs t`, this tells us that at semantic time t, the formula "not always phi in future" is true. But there's no syntactic mechanism to extract the witness time.

### Question 2: Temporal Depth and Bounded Models

**What is Temporal Depth?**

From `Formula.lean:256-262`:
```lean
def temporalDepth : Formula → Nat
  | atom _ => 0
  | bot => 0
  | imp φ ψ => max φ.temporalDepth ψ.temporalDepth
  | box φ => φ.temporalDepth
  | all_past φ => 1 + φ.temporalDepth
  | all_future φ => 1 + φ.temporalDepth
```

This counts the maximum nesting of temporal operators (G, H).

**Bounded Satisfiability Property**:
For a formula phi with `temporalDepth phi = k`, any satisfying model only needs to "look" k steps into the future/past from the evaluation point.

The codebase already uses this in `FiniteWorldState.lean:63`:
```lean
def temporalBound (phi : Formula) : Nat := phi.temporalDepth
```

And builds finite models over `BoundedTime k = Fin (2*k+1)`.

**Does This Help?**

In principle, if we could show:
1. Formula phi has temporal depth k
2. Therefore, truth of G phi at time t only depends on times in [t, t+k]
3. So we only need finitely many witnesses

But this doesn't help the backward direction because:
1. The BMCS construction uses **arbitrary** time domain D (Int in practice)
2. The time domain is not bounded by temporalDepth
3. Even if it were, we'd need omega-saturation for the finite interval

### Question 3: Why Bounded Time Domains Don't Work

The Boneyard contains several attempts at bounded time domains:
- `SemanticCanonicalModel.lean` - uses `FiniteTime k`
- `FiniteCanonicalModel.lean` - uses `BoundedTime k`

These fail for the backward direction because:

1. **Compositionality breaks**: Duration composition `d + e` can exceed bounds (documented in SemanticCanonicalModel line 224)

2. **The semantics change**: With bounded time, G phi at t means "phi at all s in [t, bound]", not "phi at all s > t". This is a different logic.

3. **The fundamental issue persists**: Even with finite time, the backward direction requires deriving "phi holds at k specific times" from "phi true at all those times". This is still a "finite omega-rule" which is not derivable.

## Why the Existing Architecture Works

The completeness theorems in `Completeness.lean` are **SORRY-FREE** because they only use the **forward** direction of the truth lemma:

```
Completeness proof (contrapositive):
1. Assume phi is not provable
2. Then {neg phi} is consistent (not_derivable_implies_neg_consistent)
3. By bmcs_representation: exists BMCS where neg phi is true
4. By truth lemma FORWARD (.mp): neg phi in MCS -> neg phi true
5. Therefore phi is not valid (it's false in this model)
```

The forward direction (`.mp`) is:
```
phi in MCS@t -> bmcs_truth_at B fam t phi
```

This is proven for ALL cases including G and H (lines 376-379, 389-392 in TruthLemma.lean).

## Technical Deep Dive: Why Backward G/H Requires Omega-Saturation

The backward direction at line 382-383 requires proving:
```lean
intro _h_all
sorry
```

Where `_h_all : forall s >= t, bmcs_truth_at B fam s phi`.

To conclude `G phi in fam.mcs t`, we would need the MCS to "know" that phi holds at infinitely many future times. But:

1. **MCS is built via Lindenbaum extension**: Start with consistent set, extend to maximal using Zorn's lemma
2. **Extension is "blind" to semantics**: Each formula is added based on preserving consistency, not on semantic truth
3. **No oracle for future times**: The extension process at time t cannot inspect what's true at times s > t

This is the **omega-rule limitation**: Finitary proof systems cannot derive universal statements from infinitely many instances.

## Recommendations

### Option A: Accept Current Architecture (RECOMMENDED)

The completeness theorems that matter are SORRY-FREE:
- `bmcs_weak_completeness`
- `bmcs_strong_completeness`
- `bmcs_representation`

The backward direction sorries are in a **biconditional** (`iff`) that is stronger than completeness needs. This is analogous to Henkin completeness for higher-order logic.

**Action**: Document this as the intended design pattern.

### Option B: Prove Weaker Temporal Iff

If we really want an iff for temporal operators, consider:
```lean
theorem mcs_G_iff_truth_forward_only :
    G phi in fam.mcs t -> (forall s >= t, bmcs_truth_at B fam s phi)
```

This is what we have, and it's sufficient.

### Option C: Change the Time Domain (NOT Recommended)

Use bounded time domain [-k, k] where k = temporalDepth phi. This:
- Changes the logic's semantics
- Has compositionality issues
- Is already explored and rejected (in Boneyard)

### Option D: Infinitary Proof System (NOT Recommended)

Add omega-rule to the proof system. This:
- Makes proofs infinite objects
- Destroys decidability
- Defeats formalization purpose

## Conclusion

**The contrapositive approach does not resolve the backward direction problem.**

While mathematically equivalent, the contrapositive still requires extracting a witness time from MCS membership, which is not possible. The MCS tells us "some time exists" syntactically but provides no mechanism to identify which time.

The user's intuition about temporal depth and bounded models is **correct for semantic purposes** (this is why FMP works), but it doesn't translate to the **proof-theoretic** backward direction. The gap is between:
- **Semantics**: Knowing phi is true at finitely many specific times
- **Proof theory**: Having phi-membership at those times lead to G-phi membership

The current architecture, which avoids the backward direction by using only the forward direction for completeness proofs, is the correct design.

## References

- TruthLemma.lean lines 380-383, 393-395 - the sorry locations
- Completeness.lean - sorry-free completeness theorems
- MCSProperties.lean:174-227 - set_mcs_negation_complete
- Formula.lean:256-262 - temporalDepth definition
- FiniteWorldState.lean:63 - temporalBound = temporalDepth
- Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean - documented architectural impossibility
- Task 828 research - FMP approach conclusion

## Next Steps

1. Update task 839 to reflect this research conclusion
2. Consider updating TruthLemma.lean documentation to explain the contrapositive perspective
3. Verify that the sorry characterization follows sorry-debt-policy.md (technical debt, fundamental limitation)
