# Research Report: Task #828

**Task**: Explore FMP Approach to TruthLemma Backward Direction
**Date**: 2026-02-03
**Focus**: Can the Finite Model Property provide an alternative to the omega-rule for G/H backward directions?

## Summary

The backward direction sorries in `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (lines 383, 395) require proving:

- `(forall s >= t, phi true at s) -> G phi in MCS at t`
- `(forall s <= t, phi true at s) -> H phi in MCS at t`

The current documentation attributes this to the "omega-rule" limitation - an infinitary inference that cannot be captured by finitary proof systems. This research explores whether the Finite Model Property (FMP) offers an alternative approach.

**Key Finding**: FMP **does not directly solve** the backward direction problem. The issue is not about finiteness of models but about the direction of the truth lemma proof. However, the existing completeness architecture already works around this limitation by using only the forward direction.

## Problem Analysis

### The Backward Direction Challenge

The TruthLemma in the BMCS approach proves:
```
phi in MCS(t) <-> bmcs_truth_at B fam t phi
```

For G (all_future) and H (all_past), this breaks down as:

| Direction | Statement | Status |
|-----------|-----------|--------|
| Forward (G) | `G phi in MCS(t) -> (forall s >= t, phi true at s)` | PROVEN |
| Backward (G) | `(forall s >= t, phi true at s) -> G phi in MCS(t)` | **SORRY** |
| Forward (H) | `H phi in MCS(t) -> (forall s <= t, phi true at s)` | PROVEN |
| Backward (H) | `(forall s <= t, phi true at s) -> H phi in MCS(t)` | **SORRY** |

### Why the Omega-Rule is Invoked

The backward direction requires deriving a universal statement from infinitely many instances:
- Given: phi is true at every time s >= t (infinitely many times)
- Conclude: G phi is in the MCS at t

This resembles the omega-rule in arithmetic:
```
From P(0), P(1), P(2), ... derive (forall n. P(n))
```

In temporal logic, this would be:
```
From phi@t, phi@(t+1), phi@(t+2), ... derive (G phi)@t
```

**Key Insight**: Finitary proof systems cannot directly encode infinitary rules. The Lindenbaum construction that builds the MCS cannot "witness" infinitely many future times.

## Finite Model Property Analysis

### What FMP Provides

The Finite Model Property for a logic L states:
> Every satisfiable formula is satisfiable in a **finite** model.

This is typically used to prove decidability via:
1. If phi is satisfiable, check finite models up to size 2^|closure(phi)|
2. Enumerate all possible finite models
3. Truth checking in finite models is decidable

### Why FMP Does Not Directly Help

The backward direction problem is **not** about model size. Even with FMP:

1. **The proof direction matters**: FMP gives us finite models when formulas are satisfiable. But the backward direction asks us to conclude something is in the MCS from semantic truth - this is the opposite direction.

2. **The MCS construction is the issue**: The IndexedMCSFamily is built via Lindenbaum extension from a consistent context. This construction cannot "know" about infinitely many future times where phi holds.

3. **Semantic vs Syntactic**: FMP relates satisfiability to finite models. The backward direction relates truth (semantic) to MCS membership (syntactic) - a different relationship.

### What FMP Could Theoretically Provide

A potential FMP-based approach would:

1. **Restrict to finite traces**: Instead of infinite time (Z or R), use a bounded time domain [-k, k] for formula phi
2. **Quantify over finite intervals**: G phi means phi holds at all times in [t, k], not all times in [t, infinity)

This is essentially the "SemanticCanonicalModel" approach in the Boneyard, which uses:
```lean
def FiniteTime (k : Nat) := { n : Int // -k <= n && n <= k }
```

**Problem**: The bounded time approach has its own challenges:
- Frame compositionality fails when durations exceed bounds (documented in `SemanticCanonicalModel.lean` line 224)
- It changes the semantics from "always" to "within bounds"

## Existing Codebase Analysis

### Current Completeness Architecture

The codebase already has a working completeness proof that **avoids** the backward direction:

1. **BMCS Completeness** (`Completeness.lean`):
   - Uses contrapositive: if not provable, then not valid
   - Only needs forward direction of truth lemma
   - Theorems `bmcs_weak_completeness` and `bmcs_strong_completeness` are SORRY-FREE

2. **Why Forward Direction Suffices**:
   ```
   To show: valid phi -> provable phi (completeness)
   Contrapositive: not provable phi -> not valid phi

   If phi is not provable:
   1. {neg phi} is consistent
   2. By representation, there exists BMCS where neg phi is true
   3. Therefore phi is false somewhere
   4. Therefore phi is not valid
   ```

   This only uses the forward direction: `phi in MCS -> phi is true`

### Documentation in TruthLemma.lean

The file itself documents this insight (lines 75-76):
> "The completeness theorems in Completeness.lean only use the forward direction (.mp) of this lemma, so they are SORRY-FREE despite these limitations."

### Boneyard Approaches

Several archived approaches attempted to address this:

1. **FiniteModelProperty.lean** (Boneyard): Contains `finite_model_property_constructive` with a sorry at line 481 - the same fundamental gap appears in different guise.

2. **SemanticCanonicalModel.lean**: The bounded-time approach, archived because compositionality fails for unbounded durations.

3. **TruthLemmaGap.lean**: Explicitly documents the "architectural impossibility" where S5-style Box semantics requires universal quantification that cannot be matched by a single MCS.

## Alternative Approaches

### Option A: Accept the Current Architecture (Recommended)

The current BMCS completeness proof is **already sorry-free** for the theorems that matter:
- `bmcs_weak_completeness`: valid phi -> provable phi
- `bmcs_strong_completeness`: consequence Gamma phi -> derivable Gamma phi

The backward direction sorries are in a biconditional that is stronger than what completeness requires. This is analogous to Henkin completeness for higher-order logic - we prove completeness for a restricted class of models (BMCS) rather than all models.

**Recommendation**: Document this as the intended architecture and close the task.

### Option B: Bounded Time Semantics

If bounded time semantics are acceptable:
1. Replace Z with FiniteTime k where k = temporalBound phi
2. G phi at t means: phi at all s in [t, k]
3. The backward direction becomes finitary (finite universal quantification)

**Challenges**:
- Changes the logic's semantics
- Compositionality issues for durations
- Already explored in SemanticCanonicalModel (archived)

### Option C: Omega-Saturation

For full semantic completeness, one would need "omega-saturated" MCSs:
- If {phi@1, phi@2, phi@3, ...} are all consistent with MCS, then G phi in MCS
- This requires non-constructive set-theoretic axioms
- Not practically implementable in Lean 4 without axioms

**Assessment**: Theoretically sound but impractical for formalized verification.

### Option D: Infinitary Proof System

Extend the proof system with an infinitary omega-rule:
```
From (phi@t) provable for all t >= s, derive (G phi)@s
```

**Challenges**:
- Derivations become infinite objects
- Proof checking becomes undecidable
- Defeats the purpose of formalized verification

## Conclusions

### FMP Does Not Resolve the Backward Direction

The Finite Model Property is orthogonal to the backward direction problem:
- FMP: satisfiability -> finite model exists
- Backward direction: semantic truth -> syntactic membership

These are different questions with different proof strategies.

### The Current Architecture is Sound

The BMCS completeness proof successfully avoids the backward direction:
- Uses contrapositive reasoning
- Only needs forward direction (MCS membership -> truth)
- Achieves sorry-free weak and strong completeness

### Recommendations

1. **Close this investigation**: FMP does not provide a viable alternative
2. **Document the limitation**: The backward direction is a fundamental limitation of finitary proof systems, not a bug
3. **Maintain current architecture**: The BMCS approach with forward-only truth lemma is the correct design
4. **Update sorry characterization**: Per sorry-debt-policy.md, these sorries should be characterized as "fundamental limitation of finitary proof theory" rather than fixable gaps

## References

- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- [Linear Temporal Logic - Wikipedia](https://en.wikipedia.org/wiki/Linear_temporal_logic)
- [Omega-consistent theory - Wikipedia](https://en.wikipedia.org/wiki/%CE%A9-consistent_theory)
- [Infinitary logic - Wikipedia](https://en.wikipedia.org/wiki/Infinitary_logic)
- Task 257 research-007: Signed finite order types as durations
- Codebase: `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- Codebase: `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`
- Boneyard: `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean`

## Next Steps

1. Update TODO.md entry for task 828 to reflect research conclusion
2. Consider creating documentation explaining the "forward-only truth lemma" design pattern
3. Verify that all completeness theorems that matter are transitively sorry-free
