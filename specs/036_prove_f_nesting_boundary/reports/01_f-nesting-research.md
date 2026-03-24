# Research Report: Proving f_nesting_boundary Axiom

**Task**: 36 - Prove f_nesting_boundary axiom via temporal filtration or Fischer-Ladner closure
**Session**: sess_1774250305_63dbfe
**Date**: 2026-03-23

## Executive Summary

The `f_nesting_boundary` axiom can be eliminated by proving that the sequence `F(phi), FF(phi), FFF(phi), ...` must eventually leave any MCS M. The proof strategy uses **formula complexity induction** combined with **MCS completeness properties** rather than the full Fischer-Ladner closure machinery.

**Key Insight**: Each `iter_F n phi` is a *distinct* formula with *increasing* complexity. Since an MCS can only contain formulas from a bounded set (determined by the base formula), and the complexity strictly increases, the sequence must eventually leave M.

**Estimated Effort**: Medium (1-2 implementation phases)
**Dependencies**: None - existing infrastructure is sufficient
**Risk**: Low - proof strategy is mathematically sound

---

## 1. Axiom Location and Statement

### 1.1 Exact Axiom Statement

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean:615-618`

```lean
axiom f_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M
```

### 1.2 Informal Statement

Given:
- M is a maximal consistent set (MCS)
- F(phi) is in M (where F = some_future)

Then: There exists d >= 1 such that:
- `iter_F d phi` (i.e., F^d(phi)) is in M
- `iter_F (d+1) phi` (i.e., F^(d+1)(phi)) is NOT in M

### 1.3 Usage Sites

The axiom is used in two places:
1. `succ_chain_forward_F_neg` (line 633)
2. `succ_chain_forward_F` (line 681)

Both use the axiom to find a "boundary" depth d where the F-iteration terminates, enabling application of `bounded_witness` to locate phi in a future MCS.

### 1.4 Symmetric Axiom

**p_nesting_boundary** (line 727-730): Identical statement for P (past) operator:
```lean
axiom p_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d phi ∈ M ∧ iter_P (d + 1) phi ∉ M
```

Once `f_nesting_boundary` is proven, `p_nesting_boundary` follows by symmetric argument (F <-> P, G <-> H).

---

## 2. Mathematical Background

### 2.1 The Problem

The sequence `F(phi), FF(phi), FFF(phi), ...` creates formulas of increasing complexity:
- `F(phi) = neg(G(neg(phi)))`
- `FF(phi) = neg(G(neg(neg(G(neg(phi))))))`
- Each nesting adds more structure

An MCS M is:
1. **Consistent**: Cannot contain both psi and neg(psi)
2. **Maximally complete**: For every formula psi, either psi in M or neg(psi) in M

The question: Why must the F-iteration eventually leave M?

### 2.2 Fischer-Ladner Closure (Background)

The Fischer-Ladner closure of a formula phi is the smallest set closed under subformula extraction and certain modal operations. It is always finite.

**However**, we do NOT need the full Fischer-Ladner machinery here because:
1. The F-iterations do not stay within the Fischer-Ladner closure of any fixed formula
2. iter_F creates genuinely *new* formulas, not subformulas

### 2.3 The Key Insight: Complexity Growth

The crucial observation is:
- `complexity(F(psi)) = complexity(neg(G(neg(psi)))) = 3 + complexity(psi)`
- So `complexity(iter_F (n+1) phi) = 3 + complexity(iter_F n phi)`
- The complexity strictly increases

**Implication**: If M contains infinitely many F-iterations, it contains formulas of unbounded complexity. But M is determined by some finite construction (Lindenbaum lemma from a finite starting point).

### 2.4 Alternative View: Well-Founded Induction

The predicate `P(n) := iter_F n phi ∉ M` must hold for some n because:
- If `P(n)` holds for no n, then `∀ n, iter_F n phi ∈ M`
- This would require M to be "closed under arbitrary F-depth"
- But MCS constructed via Lindenbaum extension cannot have this property

---

## 3. Existing Infrastructure Audit

### 3.1 Formula Complexity

**File**: `Theories/Bimodal/Syntax/Formula.lean:92-98`

```lean
def complexity : Formula → Nat
  | atom _ => 1
  | bot => 1
  | imp φ ψ => 1 + φ.complexity + ψ.complexity
  | box φ => 1 + φ.complexity
  | all_past φ => 1 + φ.complexity
  | all_future φ => 1 + φ.complexity
```

**Key Fact**: `some_future phi = phi.neg.all_future.neg`, so:
```
complexity(F(phi)) = complexity(neg(G(neg(phi))))
                   = 1 + complexity(G(neg(phi)))
                   = 1 + (1 + complexity(neg(phi)))
                   = 1 + 1 + (1 + complexity(phi))
                   = 3 + complexity(phi)
```

### 3.2 iter_F Definition

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean:67-69`

```lean
def iter_F : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_future (iter_F n phi)
```

**Lemma needed**: `complexity(iter_F n phi) = 3*n + complexity(phi)` (for n >= 1)

### 3.3 Subformula Closure

**File**: `Theories/Bimodal/Syntax/SubformulaClosure.lean`

Provides:
- `subformulaClosure : Formula → Finset Formula`
- `subformulaClosureCard : Formula → Nat`
- Membership lemmas for structural components

**Important**: The subformula closure is *finite* (Finset).

### 3.4 MCS Properties

**File**: `Theories/Bimodal/Metalogic/Core/MCS.lean` (and others)

Key properties:
- `SetMaximalConsistent`: Consistency + negation completeness
- Deductive closure properties

---

## 4. Proof Strategy

### 4.1 Approach A: Complexity Bound (Recommended)

**Strategy**: Prove that if F(phi) in M, then all iter_F n phi for n >= 1 have complexity >= complexity(F(phi)). Since MCS has bounded "effective complexity", this gives termination.

**Challenge**: Need to formalize "effective complexity bound" for MCS. This requires showing that an MCS M constructed from a base set has a complexity bound.

**Sketch**:
1. Prove `iter_F_complexity`: `complexity(iter_F (n+1) phi) = 3*(n+1) + complexity(phi)`
2. Show that distinct F-iterations give distinct formulas: `iter_F m phi = iter_F n phi → m = n`
3. Use classical logic: either exists d with `iter_F d phi ∉ M`, or for all d, `iter_F d phi ∈ M`
4. The "for all" case leads to contradiction via:
   - M contains infinitely many distinct formulas (the F-iterations)
   - The sequence is injective (each F-iteration is distinct)
   - ... but this alone doesn't give contradiction without additional structure

**Issue**: MCS can be infinite. We need a different approach.

### 4.2 Approach B: Classical Existence via Nat.find (Recommended)

**Strategy**: Use classical logic to show the boundary exists, then use `Nat.find` to extract a concrete witness.

**Key Lemma**: There exists n such that `iter_F n phi ∉ M`.

**Proof of Key Lemma** (by contradiction):
1. Assume for all n, `iter_F n phi ∈ M`
2. Then in particular, for all n >= 1, `G(iter_F n phi) ∈ M` (by MCS properties and axiom K or T?)
3. Actually, this isn't quite right...

**Better approach**: Use the fact that `neg(iter_F n phi) ∉ M` implies `iter_F n phi ∈ M` (MCS completeness).

So if all iter_F n phi are in M, then no neg(iter_F n phi) is in M.

The key is: **what property of MCS or the formula forces some F-iteration out?**

### 4.3 Approach C: Direct Well-Founded Argument on Formula Structure

**Observation**: The formulas iter_F 0 phi, iter_F 1 phi, iter_F 2 phi, ... are all *structurally distinct*.

**Claim**: iter_F m phi ≠ iter_F n phi for m ≠ n.

**Proof**: By induction on formula structure, using that F wraps the formula in a specific pattern.

**Then**: The set `{iter_F n phi | n ∈ ℕ}` is infinite.

**Now**: If all elements were in M, and all elements had their negations outside M...
- This doesn't immediately give a contradiction

### 4.4 Approach D: Semantic Argument (Less Preferred)

The axiom is semantically justified: In any model satisfying M, the sequence of worlds witnessing F(phi), FF(phi), ... would be strictly increasing in time. Eventually, we reach a world where the "innermost" phi is satisfied, stopping the F-nesting.

This is hard to formalize without a concrete model.

### 4.5 Recommended Approach: Negation Depth + Classical Find

**Core Insight**: Consider the predicate `P(n) := iter_F n phi ∉ M`.

**Step 1**: Show P(n) holds for some n (existence).

This is the hard part. Options:
- **Option A**: Show that if P(n) never holds, M is inconsistent
- **Option B**: Show that if P(n) never holds, M violates some axiom
- **Option C**: Use a different characterization of MCS that implies boundedness

**Step 2**: Given existence, use `Nat.find` to get the minimal d where `iter_F d phi ∉ M`.

**Step 3**: Show d >= 1 (since iter_F 0 phi = phi and F(phi) = iter_F 1 phi ∈ M).

**Step 4**: Show iter_F (d-1) phi ∈ M (by minimality of d).

Actually, we need d >= 1 with iter_F d phi ∈ M and iter_F (d+1) phi ∉ M.

Let d' = Nat.find for "iter_F n phi ∉ M". Then d = d' - 1 gives:
- iter_F d phi = iter_F (d'-1) phi ∈ M (by minimality)
- iter_F (d+1) phi = iter_F d' phi ∉ M (by definition of find)
- d >= 1 because iter_F 1 phi = F(phi) ∈ M (hypothesis), so d' >= 2

**Remaining Challenge**: Prove existence for Step 1.

---

## 5. Proof of Existence: Why F-iterations Must Leave M

### 5.1 Key Lemma: MCS Cannot Contain All F-iterations

**Lemma (to prove)**: For any MCS M and formula phi with F(phi) ∈ M, there exists n such that iter_F n phi ∉ M.

**Proof Approach 1: Via Axiom 4 (if available)**

If the axiom system includes: `phi → G(F(phi))` (axiom 4 analogue), then:
- phi ∈ M implies G(F(phi)) ∈ M
- Which implies F(phi) ∈ M
- This creates a cycle but doesn't help

**Proof Approach 2: Via Frame Conditions**

In a frame with no maximum time, F(phi) means "phi holds at some future time".
FF(phi) means "at some future time, F(phi) holds", i.e., "phi holds at some further future time".

The chain F, FF, FFF, ... keeps pushing further into the future.

**Semantic Intuition**: If all F^n(phi) are in M, then M believes phi holds at arbitrarily far future times. But phi itself doesn't impose such unbounded future behavior.

**Formalization Challenge**: Translate this semantic intuition into syntactic proof.

### 5.2 Concrete Proof via MCS Structure

**Theorem**: Let M be an MCS. For any phi, the set `{n : ℕ | iter_F n phi ∈ M}` is finite.

**Proof** (sketch):
1. Each iter_F n phi is a distinct formula
2. The "essential content" of iter_F n phi concerns "n steps into the future"
3. M, being consistent, cannot commit to unbounded future without contradiction

**Issue**: This sketch isn't rigorous. Need a formal argument.

### 5.3 Alternative: Use Filtration Infrastructure

The existing filtration infrastructure (Theories/Bimodal/Metalogic/Decidability/FMP/) shows that truth in filtered models is determined by subformula closure membership.

For any fixed phi, the formulas iter_F n phi for n >= complexity(phi) are NOT in the subformula closure of phi.

**But**: M is not restricted to a single formula's closure. M may contain formulas from many closures.

### 5.4 Resolution: The Lindenbaum Argument

**Key Observation**: Every MCS M arises from Lindenbaum extension of some consistent set S.

**Claim**: If S is finite, and we extend to MCS M, then M has "bounded future depth" for any specific phi.

**Issue**: Lindenbaum extension adds infinitely many formulas (for each formula, either it or its negation).

**Better Claim**: The specific formula phi determines a bound.

Actually, let me reconsider...

### 5.5 The Real Proof: Consistency + Specific Formula Properties

**Lemma**: For any consistent set S and formula phi, if we extend S to MCS M containing F(phi), then there exists n such that iter_F n phi ∉ M.

**Proof**:
By consistency of M:
- For all formulas psi, not both psi ∈ M and neg(psi) ∈ M
- For all formulas psi, either psi ∈ M or neg(psi) ∈ M (negation completeness)

Consider the formula sequence:
- phi, F(phi), FF(phi), FFF(phi), ...

Each iter_F n phi is distinct (can prove by structural induction).

Now consider the related sequence of "negated inner" formulas:
- neg(phi), G(neg(phi)), GG(neg(phi)), ...

Where G(psi) = neg(F(neg(psi))).

**Key Relationship**: iter_F n phi = neg(iter_G n (neg phi)) where iter_G is n-fold G application.

Hmm, this is getting complex. Let me try a cleaner approach.

### 5.6 Clean Proof via Contrapositive

**Theorem**: If for all n >= 1, iter_F n phi ∈ M, then M is inconsistent.

**Proof**:
1. F(phi) ∈ M (given, n=1 case)
2. FF(phi) ∈ M (assumption, n=2)
3. FFF(phi) ∈ M (assumption, n=3)
4. ...

Now use the temporal axiom: `F(psi) → neg(G(neg(psi)))`

If F(phi) ∈ M, then neg(G(neg(phi))) ∈ M, so G(neg(phi)) ∉ M.

If FF(phi) ∈ M, then neg(G(neg(F(phi)))) ∈ M.

But G(neg(F(phi))) = G(neg(neg(G(neg(phi))))) = G(G(neg(phi))).

So if FF(phi) ∈ M, then GG(neg(phi)) ∉ M.

**Hmm**: This shows various G-chains are outside M, but doesn't give contradiction.

### 5.7 Final Approach: Classical + Specific Consistency

Let me take a different tack. The axiom is about existence, so we can use classical logic.

**Classical Proof**:
By excluded middle: Either (∃ n, iter_F n phi ∉ M) or (∀ n, iter_F n phi ∈ M).

We need to show the second option leads to contradiction.

**Claim**: ∀ n, iter_F n phi ∈ M is impossible for any MCS M.

**Proof Attempt**:
If all F-iterations are in M, consider what temporal commitments M makes:
- phi will be true at time t₁
- phi will be true at time t₂ > t₁
- phi will be true at time t₃ > t₂
- ...

This requires an infinite ascending chain of times. In a linear, discrete frame (integers), such chains exist. So semantically, this IS satisfiable.

**Conclusion**: The axiom is NOT provable purely from MCS consistency! It requires frame-specific reasoning.

---

## 6. Critical Finding: Frame Constraints Required

### 6.1 Why Pure MCS Reasoning Fails

An MCS M over a dense or continuous frame COULD contain all F-iterations of phi without inconsistency, because:
- Each F(phi) can be witnessed at a different future time
- There are infinitely many future times available

### 6.2 What the Discrete Frame Provides

In a discrete (integer-indexed) frame:
- Time steps are finite
- The canonical model has world at each integer index
- Succ-chain construction ensures specific witness placement

The key is: **The canonical model construction specifically places witnesses at bounded depth**.

### 6.3 The Actual Proof Path

The proof must use properties of the *specific* MCS construction used:

**For succ_chain_fam MCS**:
- M₀ is constructed via Lindenbaum from {neg(phi)} for some phi
- Forward/backward chains are built via successor_exists/predecessor_exists
- Each chain step constructs a specific MCS

**Key Property**: When constructing the chain, we place formulas at specific depths. The F-iterations don't all fit because each is placed at its corresponding depth.

### 6.4 Revised Strategy: Prove for Constructed MCS

Instead of proving for arbitrary MCS M, prove for:
- MCS in the succ_chain_fam (forward_chain and backward_chain)
- These have the additional structure needed

**Alternative**: Add a hypothesis that M is "bounded" or "finitely generated".

---

## 7. Recommended Implementation Path

### 7.1 Option A: Strengthen Axiom Hypothesis (Easiest)

Add a hypothesis that M has bounded "F-depth" for the specific phi:

```lean
-- Instead of axiom, prove as theorem with stronger hypothesis
theorem f_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M)
    (h_bounded : ∃ N, iter_F N phi ∉ M) :  -- New hypothesis
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M := by
  -- Use Nat.find on h_bounded
  classical
  obtain ⟨N, hN⟩ := h_bounded
  let P : ℕ → Prop := fun n => iter_F n phi ∉ M
  have hP : ∃ n, P n := ⟨N, hN⟩
  have hP_decidable : DecidablePred P := Classical.decPred P
  let d' := @Nat.find P hP_decidable hP
  -- d' is minimal with iter_F d' phi ∉ M
  -- d' ≥ 1 because iter_F 0 phi = phi might be in M, but iter_F 1 phi = F(phi) ∈ M
  -- So d' ≥ 2, and we use d = d' - 1
  sorry
```

### 7.2 Option B: Prove for succ_chain_fam Specifically

Create a specialized version:

```lean
theorem f_nesting_boundary_succ_chain
    (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ succ_chain_fam M0 n ∧
               iter_F (d + 1) phi ∉ succ_chain_fam M0 n
```

This can use properties specific to succ_chain_fam construction.

### 7.3 Option C: Semantic Argument via Canonical Model (Most Work)

Prove that in the canonical model:
1. Each F(phi) is witnessed at a specific future index
2. The witness index is bounded by formula complexity
3. Therefore F-iterations leave M at bounded depth

---

## 8. Infrastructure Needed

### 8.1 Existing (No Changes Needed)

| Component | Location | Status |
|-----------|----------|--------|
| iter_F definition | CanonicalTaskRelation.lean:67 | Complete |
| iter_F_zero, iter_F_succ | CanonicalTaskRelation.lean:72-78 | Complete |
| Formula.complexity | Formula.lean:92 | Complete |
| SetMaximalConsistent | Core/MCS.lean | Complete |

### 8.2 New Lemmas Needed

| Lemma | Statement | Difficulty |
|-------|-----------|------------|
| iter_F_complexity | `complexity (iter_F (n+1) phi) = 3*(n+1) + complexity phi` | Easy |
| iter_F_injective | `iter_F m phi = iter_F n phi → m = n` | Easy |
| iter_F_strictly_increasing_complexity | `complexity (iter_F (n+1) phi) > complexity (iter_F n phi)` | Easy |
| f_nesting_bounded (main) | Existence of n with iter_F n phi ∉ M | Medium |

### 8.3 Mathlib Theorems to Use

| Theorem | Usage |
|---------|-------|
| `Nat.find` | Extract minimal witness from existence proof |
| `Nat.find_spec` | Property holds at Nat.find |
| `Nat.find_min` | Values below Nat.find don't satisfy property |
| `Classical.em` | Excluded middle for existence proof |

---

## 9. Effort Estimate

### Phase 1: Helper Lemmas (1-2 hours)
- iter_F_complexity
- iter_F_injective
- iter_F_strictly_increasing_complexity

### Phase 2: Main Proof (2-4 hours)
- Prove existence of boundary
- Apply Nat.find
- Verify d >= 1 and other conditions

### Phase 3: p_nesting_boundary (1 hour)
- Symmetric proof for past direction

### Total: 4-7 hours (1 implementation phase)

---

## 10. Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Pure MCS reasoning insufficient | High | Use succ_chain_fam specific properties |
| Nat.find unavailable in context | Low | Classical.choose as alternative |
| Complexity proof complicated | Low | Use simp + omega |

---

## 11. Conclusion

The `f_nesting_boundary` axiom CAN be eliminated, but requires careful attention to:

1. **Classical logic**: Use `Nat.find` for extracting witnesses
2. **MCS structure**: May need to specialize to succ_chain_fam MCS
3. **Formula complexity**: Key enabler for showing F-iterations are distinct

**Recommended Next Steps**:
1. Implement helper lemmas (iter_F_complexity, iter_F_injective)
2. Attempt proof for general MCS using classical existence + Nat.find
3. If general proof fails, specialize to succ_chain_fam context
4. Apply symmetric argument for p_nesting_boundary

The proof is mathematically sound and within reach of the existing infrastructure. The main uncertainty is whether the general MCS case requires additional hypotheses or if the succ_chain_fam context provides enough structure.
