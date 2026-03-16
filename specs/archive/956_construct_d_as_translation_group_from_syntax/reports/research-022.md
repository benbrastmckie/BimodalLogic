# Research Report: Homogeneous Automorphism Subgroups vs K-Relational Strategy

**Task**: 956 - Construct D as translation group from syntax
**Date**: 2026-03-09
**Session**: sess_1741536000_r956hom
**Run**: 022

---

## Summary

The user asks whether restricting Aut+(T) to "homogeneous" automorphisms (or some other appropriate subset) can circumvent the obstacles identified in research-021, and how this compares to the K-Relational strategy. This report analyzes the mathematical meaning of "homogeneous automorphisms," identifies natural subgroups of Aut+(T), and provides a head-to-head comparison.

**Principal finding**: Restricting Aut+(T) to a translation subgroup (fixed-point-free automorphisms) does make freeness hold by definition, but proving that this subgroup is large enough (acts transitively on T) is mathematically equivalent to proving homogeneity -- which is exactly the hardest deferred item. The restriction does not dissolve the obstacle; it merely relocates it. The K-Relational strategy remains the clearest path forward because it replaces the "prove homogeneity of Aut+(T)" requirement with the "prove density + countability of the MCS order" requirement, which is a strictly easier problem with better Mathlib support.

---

## 1. What Does "Homogeneous Automorphism" Mean?

### 1.1 Standard Definitions in Order Theory

The term "homogeneous" in order theory has a precise meaning that differs from the colloquial reading:

**Definition (Homogeneous linear order)**: A linear order (T, <) is **homogeneous** (or **ultrahomogeneous**) if every order-isomorphism between finite subsets of T extends to an order-automorphism of T.

This is a property of the ORDER T, not of individual automorphisms. There is no standard notion of a "homogeneous automorphism" as an individual element. The automorphism GROUP can act homogeneously (transitively on ordered n-tuples), but individual automorphisms are not classified as "homogeneous" or "non-homogeneous."

**Example**: (Q, <) is homogeneous -- this is exactly the content of Cantor's back-and-forth argument. Every order-preserving bijection between finite subsets of Q extends to an order-automorphism of Q.

**Mathlib formalization**: `FirstOrder.Language.IsUltrahomogeneous M` in `Mathlib.ModelTheory.Fraisse` captures this concept for first-order structures. For linear orders specifically, `FirstOrder.Language.isFraisseLimit_of_countable_nonempty_dlo` establishes that any countable dense linear order without endpoints is a Fraisse limit (and hence ultrahomogeneous).

### 1.2 Related Concepts That Might Be Intended

If the question is about restricting to automorphisms with special properties, there are several natural candidates:

| Candidate Subgroup | Definition | Acts Freely? | Standard Name |
|---|---|---|---|
| **Translations** | sigma(x) != x for all x (or sigma = id) | Yes, by definition | Translation subgroup / fixed-point-free subgroup |
| **Bounded automorphisms** | sup |sigma(x) - x| < infinity | Depends on structure | Bounded displacement group |
| **Archimedean automorphisms** | For all 0 < d1, d2, exists n with d1 <= n*d2 | N/A (property of the group, not individual elements) | Archimedean subgroup |
| **Inner automorphisms** | Conjugation by a fixed element | N/A for abelian groups | Inner automorphism group |

The most natural candidate for the user's question is the **translation subgroup**: automorphisms with no fixed points.

---

## 2. The Translation Subgroup of Aut+(T)

### 2.1 Definition

Define the **translation subgroup** Trans(T) as:

```
Trans(T) = { sigma in Aut+(T) | sigma(x) > x for all x, OR sigma(x) < x for all x, OR sigma = id }
```

Equivalently: the set of order automorphisms of T that are fixed-point-free (plus the identity).

### 2.2 Properties of Trans(T)

**Positive**: Trans(T) acts freely on T by definition. If sigma in Trans(T) and sigma(x) = x, then sigma = id.

**Question 1: Is Trans(T) a subgroup?**

Yes. If sigma, tau are both positive translations (sigma(x) > x and tau(x) > x for all x), then:
- (sigma . tau)(x) = sigma(tau(x)) > sigma(x) > x, so sigma . tau is a positive translation.
- sigma^{-1}(x) < x for all x (since sigma(y) > y for all y, setting y = sigma^{-1}(x) gives x = sigma(sigma^{-1}(x)) > sigma^{-1}(x)).

The composition of a positive translation with a negative translation requires more care, but in general Trans(T) is a subgroup of Aut+(T) when T has no fixed points for non-identity elements.

**Question 2: Is Trans(T) = Aut+(T)?**

No, not in general. As research-021 (Teammate A, Section 2) established, the full automorphism group of a general linear order can contain non-identity elements with fixed points. The example f(x) = x for x <= 0, f(x) = 2x for x > 0 is in Aut+(Q) but not in Trans(Q).

**Question 3: Is Trans(T) nonempty beyond the identity?**

This is the critical question. For Trans(T) to be useful as D, we need it to contain enough elements to act transitively on T. Specifically, for any a < b in T, we need sigma in Trans(T) with sigma(a) = b.

### 2.3 The Transitivity Obstacle

For Trans(T) to act transitively on T (i.e., for the action to be homogeneous), we need:

> For all a, b in T, there exists sigma in Trans(T) such that sigma(a) = b.

This is precisely the **AddTorsor** requirement from TranslationGroup.lean, which was identified as the "hardest deferred item" in every prior research report.

**Why this is hard**: The elements of T are equivalence classes of MCSes under the Antisymmetrization quotient. Constructing an order automorphism that maps one equivalence class to another requires showing that the temporal structure around any point "looks the same" -- i.e., that T is order-homogeneous. For BidirectionalQuotient built via Lindenbaum extensions from an arbitrary root M0, there is no syntactic reason to expect this.

**The entanglement**: Research-021 (Teammate A, Section 8) cites the measurement theory result of Krantz-Luce-Suppes-Tversky (1971):

> Freeness + Homogeneity (of the group action) are TOGETHER equivalent to the group being isomorphic to an Archimedean ordered group.

This means freeness and homogeneity are mathematically entangled. Getting freeness "for free" by restricting to Trans(T) does not help with homogeneity. In fact, the only way to verify that Trans(T) is large enough is to prove homogeneity -- which is the very obstacle we wanted to avoid.

### 2.4 Verdict on the Restriction Approach

**Restricting to Trans(T) solves the wrong problem.** The difficulty was never that Aut+(T) is "too large" in the sense of containing bad elements. The difficulty is that we need Aut+(T) (or any subgroup thereof) to be "large enough" to act transitively on T. Restricting to a SUBGROUP makes the transitivity problem strictly HARDER, not easier.

Concretely:
- **Before restriction**: Need to show Aut+(T) acts transitively on T (hard).
- **After restriction**: Need to show Trans(T) acts transitively on T (harder, since Trans(T) is a subset of Aut+(T)).

The restriction does buy freeness, which gives a linear order on D via eval-at-origin. But this gain is negated by the increased difficulty of transitivity.

---

## 3. Other Restriction Strategies

### 3.1 Restricting to Syntactically-Definable Automorphisms

One could restrict to automorphisms that are "definable" from the syntax -- e.g., automorphisms constructed by composing specific canonical_forward_F and canonical_backward_P steps.

**Problem**: These compositions produce elements of Aut+(T) only if they respect the quotient structure. A sequence of F-steps and P-steps produces a path through MCSes, but the resulting map on the quotient T must be an order automorphism. Verifying this requires the same structural properties of T (density, homogeneity) that we are trying to avoid.

### 3.2 Restricting to a Fixed-Origin Stabilizer

One could consider Aut+(T, o) = { sigma in Aut+(T) | sigma(o) = o } for a fixed origin o. But this is the OPPOSITE of what we want -- we need automorphisms that MOVE points, not fix them.

### 3.3 Using the Regular Representation

If T already has a group structure (from some other source), then the regular representation G -> Aut+(G) via left multiplication embeds G as a subgroup of Aut+(G) that acts freely and transitively. This is the content of Mathlib's `addGroupIsAddTorsor`: every AddGroup G is an AddTorsor over itself.

**But this requires T to already have a group structure** -- which is exactly what we are trying to construct.

---

## 4. The K-Relational Strategy in Detail

### 4.1 Overview

The K-Relational strategy from research-020/021 bypasses the automorphism group entirely:

1. **Phase K1**: Prove completeness for relational frames (W, R) without TaskFrame.
2. **Phase K2**: Prove that the canonical relational model (MCSes, CanonicalR) is a countable dense linear order without endpoints (under TM+DN).
3. **Phase K3**: Apply Cantor's theorem (`Order.iso_of_countable_dense`) to get an order isomorphism with Q.
4. **Phase K4**: Transfer Q's algebraic structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid) to the canonical model via the isomorphism.
5. **Phase K5**: Build TaskFrame with D = Q (discovered, not imported) and the transferred structure.

### 4.2 Why K-Relational Avoids the Automorphism Obstacles

| Obstacle | TranslationGroup/Restriction | K-Relational |
|---|---|---|
| **Freeness** | Must prove or restrict to Trans(T) | Not needed (Q acts freely on itself by Mathlib's `addGroupIsAddTorsor`) |
| **Homogeneity** | Must prove Trans(T) acts transitively on T | Not needed (Q acts transitively on itself by addition) |
| **Holder's theorem** | Must prove Archimedean property + formalize Holder | Not needed (Q is already `AddCommGroup` in Mathlib) |
| **LinearOrder on D** | Must construct from eval-at-origin injectivity | Given by Q's `LinearOrder` in Mathlib |
| **IsOrderedAddMonoid on D** | Must construct from above | Given by `Rat.instIsOrderedAddMonoid` in Mathlib |
| **Density of T** | Must prove DenselyOrdered on BidirectionalQuotient (4 sorries) | Must prove DenselyOrdered on the MCS order (similar difficulty, but potentially easier at MCS level) |
| **Countability of T** | Proven FALSE for BidirectionalQuotient (research-018) | Must prove for restricted fragment or alternative construction |

### 4.3 What K-Relational Still Requires

The K-Relational strategy is not free of obstacles. It requires:

1. **Density at the MCS level**: Proving that between any two CanonicalR-related MCSes with strictly different G-content, there exists an intermediate MCS. This faces a variant of the "Lindenbaum collapse" issue, but at the preorder level (not quotient level), which may be tractable.

2. **Countability of the canonical model**: The BidirectionalQuotient was proven uncountable (research-018). A RESTRICTED construction (e.g., specific Lindenbaum witnesses only, or a countable sub-fragment) is needed. Alternatively, work with a first-order definable fragment.

3. **No endpoints**: Proving NoMinOrder and NoMaxOrder for the canonical model. This should follow from the axioms (given any MCS, F(bot -> bot) gives a future witness, P(bot -> bot) gives a past witness).

4. **Relational frame semantics**: The current codebase uses TaskFrame semantics. A relational frame satisfaction relation must be defined and shown equivalent for the formulas of TM. This is medium-effort refactoring.

5. **Transfer of structure**: The order isomorphism with Q gives an algebraic structure on the canonical model. Verifying that this structure satisfies TaskFrame requirements (compositionality, nullity) is straightforward but requires careful bookkeeping.

### 4.4 Mathlib Infrastructure for K-Relational

| Requirement | Mathlib Support | Reference |
|---|---|---|
| Cantor's theorem | `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` |
| Q is AddCommGroup | `Rat.addCommGroup` | Core Mathlib |
| Q is LinearOrder | `Rat.instLinearOrder` | Core Mathlib |
| Q is OrderedAddCommGroup | `Rat.instOrderedAddCommGroup` | `Mathlib.Algebra.Order.Ring.Rat` |
| Q is IsOrderedAddMonoid | `Rat.instIsOrderedAddMonoid` | `Mathlib.Algebra.Order.Ring.Rat` |
| Q is DenselyOrdered | `Rat.instDenselyOrdered` | Core Mathlib |
| Q is Countable | `Rat.instCountable` | Core Mathlib |
| Q is NoMinOrder | `Rat.instNoMinOrder` | Core Mathlib |
| Q is NoMaxOrder | `Rat.instNoMaxOrder` | Core Mathlib |
| Q is AddTorsor over itself | `addGroupIsAddTorsor` | `Mathlib.Algebra.AddTorsor.Defs` |
| Fraisse limit / ultrahomogeneity | `isFraisseLimit_of_countable_nonempty_dlo` | `Mathlib.ModelTheory.Order` |
| OrderIso.addRight (left translation is OrderIso) | `OrderIso.addRight` | `Mathlib.Algebra.Order.Group.OrderIso` |

All core algebraic infrastructure for Q is in Mathlib. The K-Relational strategy leverages this infrastructure rather than building it from scratch.

---

## 5. Head-to-Head Comparison

### 5.1 Restrict Aut+(T) to Trans(T) vs K-Relational

| Criterion | Trans(T) Restriction | K-Relational |
|---|---|---|
| **Philosophical purity** | HIGH (D is automorphisms of a syntactic structure) | MEDIUM-HIGH (Q is "discovered" via Cantor characterization of syntactic structure) |
| **Freeness** | Solved by definition | Solved by Mathlib (Q acts freely on itself) |
| **Commutativity** | Still requires Holder's theorem on Trans(T) | Inherited from Q |
| **Homogeneity** | HARD: must prove Trans(T) acts transitively | Trivial: Q acts transitively on itself |
| **Density** | 4 sorries in DenseQuotient.lean | Similar difficulty but at MCS level |
| **Countability** | Proven FALSE for BidirectionalQuotient | Must be established for restricted fragment |
| **Mathlib support** | LOW (no Holder, no ordered Aut+ infrastructure) | HIGH (full Q infrastructure) |
| **New code needed** | ~500+ lines (Holder's theorem, Archimedean property, Trans(T) subgroup proofs) | ~200-300 lines (relational semantics, density at MCS level, Cantor application) |
| **Risk of blocking** | HIGH (multiple independent hard steps) | MEDIUM (density is the main risk) |

### 5.2 Key Differentiator

The critical difference is the **number of independent hard steps**:

**Trans(T) restriction** requires solving ALL of:
1. Prove Archimedean property of Trans(T) [HARD, no Mathlib support]
2. Formalize Holder's theorem: Archimedean ordered group is abelian [HARD, ~200 lines, not in Mathlib]
3. Prove Trans(T) acts transitively on T (homogeneity) [VERY HARD, the hardest deferred item]
4. Prove DenselyOrdered on T [HARD, 4 existing sorries]
5. Prove Countable on T or restricted variant [HARD, proven false for current definition]

**K-Relational** requires solving:
1. Define relational frame semantics [MEDIUM, ~100 lines of refactoring]
2. Prove density of canonical MCS order under DN [HARD, similar to current density blocker but at MCS level]
3. Prove countability of a restricted MCS fragment [MEDIUM, straightforward with restricted witnesses]
4. Apply Cantor's theorem [EASY, one-line application of `Order.iso_of_countable_dense`]
5. Transfer algebraic structure from Q [MEDIUM, bookkeeping]

K-Relational has ONE hard step (density at MCS level). Trans(T) restriction has THREE independent hard steps (Archimedean, Holder, homogeneity) PLUS the same density blocker.

---

## 6. Can the Approaches Be Combined?

### 6.1 Hybrid: Restrict to Automorphisms of Q After Cantor Isomorphism

One could:
1. First establish the Cantor isomorphism T ~ Q (K-Relational phase K3)
2. Then observe that Trans(Q) = { x -> x + q | q in Q } is exactly the additive group of Q
3. Conclude D = Q as a group, with the action by translation

This is NOT a "combination" -- it IS the K-Relational strategy. The automorphism group analysis becomes trivial once we know T ~ Q, because Q's automorphism group is well-understood and its translation subgroup is exactly Q itself.

### 6.2 The Philosophical Insight

For Q (and for any homogeneous linear order), the translation subgroup Trans(Q) is ISOMORPHIC to Q itself via the evaluation-at-origin map:

```
eval_0 : Trans(Q) -> Q
eval_0(sigma) = sigma(0)
```

This map is:
- Injective (since sigma in Trans(Q) is determined by sigma(0): if sigma(0) = tau(0) and both are translations, then sigma = tau, because a fixed-point-free order automorphism of Q is determined by its value at any single point)
- Surjective (for any q in Q, the translation x -> x + q is in Trans(Q) and maps 0 to q)
- A group homomorphism (eval_0(sigma . tau) = (sigma . tau)(0) = sigma(tau(0)) = sigma(0) + tau(0) = eval_0(sigma) + eval_0(tau))

So the "homogeneous automorphism" approach and the "Q discovered via Cantor" approach converge to the SAME object. The question is which route to that object has fewer obstacles.

---

## 7. Recommendations

### 7.1 Do NOT pursue the Trans(T) restriction independently

The restriction adds no mathematical power. It solves freeness (which was the easiest of the deferred items) while leaving homogeneity and Holder's theorem (the hardest items) untouched. The effort-to-progress ratio is unfavorable.

### 7.2 Pursue K-Relational as the primary strategy

K-Relational has the fewest independent hard steps, the best Mathlib support, and a clear philosophical narrative (Q is discovered, not imported). The main blocker (density at MCS level) is shared with ALL approaches.

### 7.3 If K-Relational is blocked on density

If the density proof at MCS level proves intractable:

**Option 1**: Prove completeness for base TM first (no density needed), then show that adding DN FORCES the canonical model to be dense as a separate theorem. This decomposes the problem.

**Option 2**: Use the Fraisse limit approach. Mathlib has `isFraisseLimit_of_countable_nonempty_dlo`: any countable dense linear order without endpoints is a Fraisse limit of finite linear orders. If we can show the canonical model is a Fraisse limit (by showing it has the right age and is ultrahomogeneous), density follows.

**Option 3**: Mark the density proof as [BLOCKED] and prove everything else, leaving density as the single remaining sorry. This is preferable to having multiple sorries spread across Holder's theorem, Archimedean property, and homogeneity.

### 7.4 The philosophical response to the user's question

The user's intuition about "homogeneous automorphisms" is mathematically sound -- the translation subgroup is the RIGHT mathematical object. But showing it has the right properties FROM SYNTAX requires first establishing that T is homogeneous (i.e., Q-like). The K-Relational strategy achieves this by proving T ~ Q via Cantor's theorem, at which point Trans(T) ~ Trans(Q) ~ Q, and the circle closes.

In other words: **the answer to "what if we restrict to homogeneous automorphisms?" IS the K-Relational strategy**, because establishing that the restriction is well-behaved requires exactly the same work as the Cantor characterization.

---

## 8. Evidence

### Codebase References

| File | Relevance |
|---|---|
| `TranslationGroup.lean` | Current D = Additive(T ≃o T), AddGroup proven, deferred items listed |
| `BidirectionalReachable.lean` | T = BidirectionalQuotient with LinearOrder (888 lines, sorry-free) |
| `DenseQuotient.lean` | 4 sorries for DenselyOrdered on BidirectionalQuotient |
| `TaskFrame.lean` | TaskFrame requires AddCommGroup + LinearOrder + IsOrderedAddMonoid |
| `Representation.lean` | Current canonical model uses D = Int, task_rel = True |

### Mathlib References

| Declaration | Module | Relevance |
|---|---|---|
| `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` | Cantor's theorem for K-Relational |
| `addGroupIsAddTorsor` | `Mathlib.Algebra.AddTorsor.Defs` | Q is a torsor over itself |
| `Rat.instOrderedAddCommGroup` | `Mathlib.Algebra.Order.Ring.Rat` | Q has all required algebraic instances |
| `OrderIso.addRight` | `Mathlib.Algebra.Order.Group.OrderIso` | Translation by group element is OrderIso |
| `IsUltrahomogeneous` | `Mathlib.ModelTheory.Fraisse` | Ultrahomogeneity concept |
| `isFraisseLimit_of_countable_nonempty_dlo` | `Mathlib.ModelTheory.Order` | Countable DLO without endpoints is Fraisse limit |
| `IsFraisseLimit.nonempty_equiv` | `Mathlib.ModelTheory.Fraisse` | Fraisse limits are unique up to isomorphism |

### External Mathematical References

| Source | Content |
|---|---|
| Krantz-Luce-Suppes-Tversky (1971) | Freeness + homogeneity <-> Archimedean ordered group |
| Cantor (1895) | Countable dense linear order without endpoints is unique up to isomorphism |
| Holder (1901) | Archimedean ordered groups are abelian and embed in R |
| Goldblatt (1992) Ch. 6 | Canonical model for tense logic: (MCSes, CanonicalR) without separate D |

---

## 9. Confidence Assessment

**HIGH** for the main conclusions:

- The analysis that Trans(T) restriction does not bypass homogeneity is a mathematical deduction, not a heuristic.
- The Mathlib infrastructure assessment is verified via tool queries.
- The convergence of the "homogeneous automorphism" approach and K-Relational is a mathematical equivalence.
- The obstacle count comparison (3 hard steps vs 1 hard step) is concrete and verifiable from the codebase.

**MEDIUM** for the feasibility of density at MCS level (the K-Relational hard step). This has not been attempted yet and faces a variant of the Lindenbaum collapse issue. However, working at the preorder level (before quotient) provides more flexibility.
