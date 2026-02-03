# Research Report: Task #828

**Task**: Explore FMP Approach to TruthLemma Backward Direction
**Date**: 2026-02-03
**Focus**: Can the Finite Model Property provide an alternative to the omega-rule for G/H backward directions?

## Summary

The backward direction sorries in `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` (lines 383, 395) require proving:

- `(forall s >= t, phi true at s) -> G phi in MCS at t`
- `(forall s <= t, phi true at s) -> H phi in MCS at t`

The current documentation attributes this to the "omega-rule" limitation - an infinitary inference that cannot be captured by finitary proof systems. This research explores whether the Finite Model Property (FMP) or contrapositive reasoning offers an alternative approach.

**Key Finding**: FMP **does not directly solve** the backward direction problem. The fundamental issue is not about infinity or finiteness, but about the **direction of reasoning**: going from semantic truth (at specific times) to syntactic membership (in an MCS constructed independently of those times). Neither FMP, bounded time domains, nor contrapositive reasoning can bridge this gap. However, the existing completeness architecture already works around this limitation by using only the forward direction.

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

### Why the Contrapositive Doesn't Help

A natural question: could proving the contrapositive be easier?
```
Contrapositive: G phi ∉ MCS at t  →  ∃ s ≥ t, phi false at s
```

By MCS maximality, `G phi ∉ MCS` means `¬G φ ∈ MCS`, which is semantically equivalent to `F(¬φ)` ("eventually not-φ"). However, this doesn't resolve the fundamental gap:

**The Witness Extraction Problem**: Even though `F(¬φ) ∈ MCS` tells us *semantically* that some future time fails φ, we cannot extract a **concrete witness time** from MCS membership. The MCS construction is purely syntactic - it knows "some time exists" but not *which specific time*.

This is the core issue: the Lindenbaum construction builds the MCS by extending a consistent set *syntactically*, without access to which concrete times would eventually satisfy or refute formulas. The contrapositive restates the problem but doesn't bypass this fundamental gap.

## Finite Model Property Analysis

### Temporal Depth and the Finiteness Red Herring

An important clarification: **the issue is not fundamentally about infinity**.

Every formula has finite **temporal depth** (defined in `Formula.lean:256-262`) - the maximum nesting of G/H operators. A formula can only "look" finitely many steps into the future or past. The codebase already tracks this via `temporalBound phi = temporalDepth phi`.

However, even with bounded depth, we still face the same gap:
1. We have semantic truth at (finitely many relevant) times
2. We need syntactic membership in an MCS
3. **The MCS was constructed without knowing which times would be relevant**

The problem isn't that there are infinitely many times to check. The problem is the **direction of reasoning**: going from semantic facts (truth at specific times) to syntactic facts (MCS membership), when the MCS was built independently of those semantic facts.

This is a "finite omega-rule" problem: even if we only needed to check finitely many times (say, k times based on temporal depth), we still can't derive `G phi in MCS` from k individual facts `phi@t1, phi@t2, ..., phi@tk` using finitary proof rules.

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

2. **The MCS construction is the issue**: The IndexedMCSFamily is built via Lindenbaum extension from a consistent context. This construction cannot "know" about which future times where phi holds - whether finitely or infinitely many.

3. **Semantic vs Syntactic**: FMP relates satisfiability to finite models. The backward direction relates truth (semantic) to MCS membership (syntactic) - a different relationship.

As discussed above regarding temporal depth: even if we restrict to finite time domains based on formula depth, this doesn't solve the directionality problem. The MCS construction is independent of which specific times will matter semantically.

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
- FMP: satisfiability → finite model exists
- Backward direction: semantic truth → syntactic membership

These are different questions with different proof strategies.

### The Core Issue: Direction of Reasoning, Not Infinity

The fundamental obstacle is **not** about infinity but about **directionality**:

1. **What we have**: Semantic truth of φ at specific times (whether finitely or infinitely many)
2. **What we need**: Syntactic membership of `G φ` in an MCS
3. **The gap**: The MCS was constructed via Lindenbaum extension, independently of which times semantically satisfy φ

Even with:
- Finite temporal depth (formulas can only "look" finitely far ahead)
- Bounded time domains (restricting to finitely many times total)
- Contrapositive reasoning (trying to extract witness times from MCS membership)

We still cannot bridge from semantic facts to syntactic facts in the backward direction. The MCS construction is blind to semantic satisfiability at specific times.

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
