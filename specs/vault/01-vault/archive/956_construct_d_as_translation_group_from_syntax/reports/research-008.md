# Research Report: JPL Paper Appendix Analysis for Homogeneity

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-008
**Date**: 2026-03-07
**Session**: sess_1773093600_a8b9c0
**Status**: Findings ready for planning

---

## 1. Executive Summary

This report analyzes `app:auto_existence` and `lem:history-time-shift-preservation` from the JPL paper to determine whether they provide insights for establishing homogeneity of the canonical timeline T when constructing D as a totally ordered abelian group from pure syntax.

**Principal Finding**: The paper's time-shift lemmas use the group structure of D (given as Z or Q) to define translations `ā(z) = z + Δ`. These are automorphisms of D acting on **itself**, not automorphisms of a separate timeline T. The paper never faces the homogeneity problem because D is a primitive parameter, not derived from T.

**Key Insight for Task 956**: The paper's approach suggests a **reversal of perspective**:
- Instead of: construct T (MCS timeline) → define D = Aut+(T) → prove D is homogeneous
- Consider: construct D directly from syntactic properties → prove D acts on T

However, the second approach requires identifying what group D emerges from syntax without assuming density or discreteness. This remains an open mathematical question for general temporal logics.

**Recommendation**: The path forward requires choosing one of:
1. **Prove homogeneity directly** via back-and-forth using witness existence lemmas
2. **Add discrete/dense axiom** which forces D ≅ Z or D ≅ Q respectively
3. **Use axiomatic abstraction** (HomogeneousTimeline typeclass) to proceed conditionally

---

## 2. Analysis of Paper Results

### 2.1 Definition: Time-Shift Histories (def:time-shift-histories, line 1877)

The paper defines when two histories τ and σ are **time-shifted from y to x**:

> τ ≈ᵧˣ σ iff there exists an order automorphism ā : D → D where:
> - y = ā(x)
> - dom(σ) = ā⁻¹(dom(τ))
> - σ(z) = τ(ā(z)) for all z ∈ dom(σ)

**Critical observation**: The automorphism ā is on **D itself**, not on a separate timeline. When D = Z, every automorphism of Z (as an ordered additive group) is a translation `z ↦ z + n` for some n ∈ Z.

### 2.2 Lemma: Auto Existence (app:auto_existence, line 1884)

**Statement**: For any history τ and times x, y ∈ D, there exists a history σ where τ ≈ᵧˣ σ is witnessed by the automorphism ā(z) = z - x + y.

**Proof sketch (from paper)**:
1. Define σ by σ(z) := τ(z + (y - x)) for z ∈ dom(σ) := {z : z + (y - x) ∈ dom(τ)}
2. The witness ā(z) = z + (y - x) is clearly an order automorphism of D
3. σ is well-defined because τ is defined on ā(dom(σ))
4. σ respects the task relation because τ does (duration differences are preserved under translation)

**Key insight**: This lemma **uses** the group structure of D. The translation `z ↦ z + Δ` is always an automorphism of any ordered abelian group D acting on itself. The lemma does NOT construct automorphisms of a separate space.

### 2.3 Lemma: History-Time-Shift-Preservation (line 1918)

**Statement**: M, τ, y ⊨ φ if and only if M, σ, x ⊨ φ whenever τ ≈ᵧˣ σ is witnessed by ā(z) = z - x + y.

**Proof structure** (implemented in `Truth.lean:344`):
- Induction on formula complexity
- **Atom case**: States match because σ(x) = τ(y) by construction
- **Implication case**: Direct IH application
- **Box case**: Requires `ShiftClosed(Ω)` - all shifts of histories in Ω remain in Ω
- **Past/Future cases**: Times shift together with the history

**Implementation in codebase**: `time_shift_preserves_truth` at `Truth.lean:344` formalizes this lemma exactly.

---

## 3. Why These Lemmas Don't Directly Solve Homogeneity

### 3.1 The Architectural Difference

**Paper's Architecture**:
```
D (given: Z or Q) → Histories τ : D → W → Truth definition → Completeness
```

**Task 956's Architecture**:
```
MCSes → T (timeline order) → D = Aut+(T) → ??? → TaskFrame D → Completeness
```

The paper's lemmas assume D is already available with its group structure. They prove properties ABOUT histories indexed by D, not properties that CONSTRUCT D.

### 3.2 Why Homogeneity is Harder for Aut+(T)

For D = Aut+(T) (order automorphisms of T), homogeneity means:

> ∀ a, b ∈ T, ∃ f ∈ Aut+(T), f(a) = b

This is equivalent to saying T is **order-homogeneous** (every order automorphism of a finite subset extends to a global automorphism).

**The paper doesn't face this** because:
1. D is Z or Q, both of which act transitively on themselves by translation
2. Histories are functions D → W, so "moving between times" uses D's group operation
3. No need to construct automorphisms of T because T = D

### 3.3 The Z + Q + Z Counterexample

Research-006 correctly identified that general linear orders are NOT homogeneous. Consider:
- T = Z ∪ Q ∪ Z (integers, then rationals, then integers again)
- This is a countable linear order without endpoints
- But there's no automorphism mapping a point in the first Z to a point in Q

**For the canonical timeline**, the question is: does the MCS construction produce a homogeneous order?

The temporal axioms (TK, T4, TA, TL) ensure:
- Linear order (proven)
- No endpoints (infinite in both directions via existence lemmas)
- Connectivity

But they do NOT ensure homogeneity without additional axioms.

---

## 4. Potential Paths Forward Using Paper Insights

### 4.1 Path A: Prove Homogeneity via Witness Existence

**Idea**: Use `canonical_forward_F` and `canonical_backward_P` to construct automorphisms.

**Sketch**:
1. Given a, b ∈ T (equivalence classes of MCSes [M_a] and [M_b])
2. Build a partial automorphism mapping [M_a] → [M_b]
3. Extend using witness existence: for each [M] reachable from [M_a], use `canonical_forward_F` to find corresponding witnesses from [M_b]
4. Show this extends to a full order automorphism

**Difficulty**: The extension step requires showing that witnesses "match up" in a way that preserves order. This is essentially a back-and-forth argument, but without density or discreteness, it's unclear whether witnesses always exist in the right positions.

**Inspiration from app:auto_existence**: The paper's proof works because translation in D is automatic. For T, we need to show that "temporal translation" (shifting along the MCS chain) is also automatic.

### 4.2 Path B: The "Induced Action" Approach

**Observation**: If we think of D as acting on histories rather than on T directly, then `app:auto_existence` shows that D acts on the space of histories.

**Idea**:
1. Define D not as Aut+(T), but as the group of "history shifts"
2. A history shift by Δ maps τ to τ[Δ] where τ[Δ](z) = τ(z + Δ)
3. The group of history shifts is isomorphic to D (the time domain)

**Problem**: This requires D to be given first. We're trying to construct D, so this is circular.

**Potential resolution**: Define D as the free abelian group generated by "temporal steps" in T, with relations from the linear order. This gives a group structure, but proving it's totally ordered requires more work.

### 4.3 Path C: Use Temporal Axiom Uniformity

**Observation from research-006 Section 2.3**:

> Temporal axioms are schemata applying uniformly to all formulas. This ensures the *theory* at each point is structurally similar.

**Expanded idea**: Every MCS in the bidirectional fragment satisfies the same axiom schemata. This means:
- For any F-formula Fφ in MCS M, there exists a forward witness M' with φ ∈ M'
- For any P-formula Pφ in MCS M, there exists a backward witness M'' with φ ∈ M''

The existence lemmas (`canonical_forward_F`, `canonical_backward_P`) are **uniform** - they work the same way for every MCS.

**Homogeneity conjecture**: If we can show that the witness existence lemmas produce "parallel" chains from any starting point, then moving between chains gives an automorphism.

**Formalization challenge**: Making "parallel chains" precise requires comparing infinite objects (entire histories), which is technically complex.

### 4.4 Path D: Axiomatic Abstraction (HomogeneousTimeline)

**This is research-006's Option D**, which remains viable:

1. Define `HomogeneousTimeline T` typeclass with freeness and transitivity assumptions
2. Prove TaskFrame D assuming HomogeneousTimeline T
3. Complete completeness proof conditionally
4. Create follow-up tasks to discharge HomogeneousTimeline for:
   - Discrete temporal logic (D ≅ Z trivially)
   - Dense temporal logic (D ≅ Q, use back-and-forth)
   - Base TM logic (requires new ideas from this report)

**Advantage**: Progress on completeness without solving the hardest mathematical problem immediately.

---

## 5. The Key Mathematical Question

The fundamental question for constructing D from syntax is:

> **What is the automorphism group of the canonical timeline T?**

For specific temporal logics:
- **Discrete (TM + DP + DF)**: T ≅ Z, so Aut+(T) ≅ Z
- **Dense (TM + DN)**: T ≅ Q, so Aut+(T) ≅ Q (by back-and-forth)
- **Base TM (no density/discreteness)**: T is... what?

The temporal axioms of base TM do not determine whether T is discrete, dense, or neither. This is reflected in the semantic framework: TM is complete over **all** totally ordered abelian groups, not just Z or Q.

**Implication**: For base TM, D might not be uniquely determined by the syntax. The canonical model could use any totally ordered abelian group, with Z being the simplest choice.

---

## 6. What app:auto_existence Tells Us About D

The most useful insight from `app:auto_existence`:

> **D acts on itself by translation, and this action is always free and transitive.**

For any ordered abelian group D:
- **Free**: If d + x = x for some x, then d = 0 (by cancellation)
- **Transitive**: Given any x, y ∈ D, the element d = y - x satisfies d + x = y

This means **D is automatically a homogeneous space when acting on itself**.

**The problem with D = Aut+(T)**: D acts on T, not on itself. For D to have the required properties, T must be homogeneous so that:
1. The action is transitive (homogeneity)
2. The action is free (rigidity)
3. The order on D pulled back from T via an origin is total

---

## 7. Recommendations

### 7.1 Primary Recommendation: Prove Homogeneity for Discrete Case First

1. Add discreteness axioms (DP, DF) to the temporal logic
2. Prove BidirectionalQuotient has SuccOrder structure
3. Use `orderIsoIntOfLinearSuccPredArch` to get T ≅ Z
4. Then D = Aut+(T) ≅ Z, and homogeneity is trivial

This follows the paper's approach (D = Z for base TM, D = Q for TM^d) while keeping D "constructed from syntax" in the sense that the isomorphism to Z is derived, not assumed.

### 7.2 Secondary Recommendation: Axiomatic Abstraction

Continue with Option D from research-006:
1. Define `HomogeneousTimeline` typeclass
2. Prove completeness conditionally
3. Discharge for discrete and dense cases later

### 7.3 Research Direction: Back-and-Forth for General T

If a truly general D is desired (neither Z nor Q), investigate:
1. Prove T is countable (from countability of Formula)
2. Formulate "extension property" using witness existence lemmas
3. Attempt back-and-forth construction without density/discreteness

This is the mathematically novel path but also the riskiest.

---

## 8. Summary of Findings

| Question | Answer |
|----------|--------|
| Does `app:auto_existence` help with homogeneity? | Indirectly - it shows D acts transitively on itself, but T ≠ D in our construction |
| Does `lem:history-time-shift-preservation` help? | No - it's about truth preservation, not about constructing D |
| Why doesn't the paper face the homogeneity problem? | D is given as Z or Q, both of which act transitively on themselves |
| Can we construct D ≠ Z ≠ Q from syntax? | Unclear - depends on what temporal axioms determine about T's structure |
| Best path forward? | Discreteness axioms (easiest), axiomatic abstraction (cleanest), or back-and-forth (hardest) |

---

## 9. Connection to Existing Implementation

The `TranslationGroup.lean` file correctly defines D = Additive(T ≃o T) and proves:
- AddGroup structure ✓
- Nullity and compositionality ✓
- Action injectivity and order-preservation ✓

The blockers (AddCommGroup, LinearOrder on D, AddTorsor) all depend on:
1. **Freeness** (rigidity): If f(a) = a for some f ∈ D and a ∈ T, then f = id
2. **Homogeneity** (transitivity): ∀ a, b ∈ T, ∃ f ∈ D, f(a) = b

Neither `app:auto_existence` nor `lem:history-time-shift-preservation` provides these. They assume D is already available with a transitive action on itself.

---

## 10. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-008.md`
- **Referenced files**:
  - `WorldHistory.lean:236` - time_shift construction
  - `Truth.lean:344` - time_shift_preserves_truth
  - `TranslationGroup.lean` - current D construction
  - research-006.md - blocker analysis
  - research-007.md - JPL paper D=Z finding

---

## 11. Next Steps

1. **Decision point**: Choose between discreteness axioms, axiomatic abstraction, or back-and-forth
2. **If discreteness**: Formulate DP/DF axioms and prove SuccOrder on BidirectionalQuotient
3. **If abstraction**: Define HomogeneousTimeline and complete conditional TaskFrame
4. **If back-and-forth**: Prove countability of T and formulate extension property precisely
