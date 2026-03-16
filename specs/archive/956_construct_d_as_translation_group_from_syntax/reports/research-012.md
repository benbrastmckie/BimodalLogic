# Research Report: Density Path Rehabilitation, Algebraic Completeness, and Axiom-Free Construction

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-012
**Date**: 2026-03-08
**Session**: sess_1773102000_b3f4d2
**Status**: Findings ready for planning
**Effort**: Medium-high (deep mathematical analysis across multiple topics)
**Dependencies**: research-010, research-011
**Sources/Inputs**: Codebase (TranslationGroup.lean, BidirectionalReachable.lean, Algebraic/), Mathlib lookup, Web research (SEP, nLab, Venema, Wikipedia)
**Artifacts**: This report

---

## 1. Executive Summary

This report corrects a critical error in research-011 and provides a comprehensive analysis of the user's preferred density path, the algebraic approach to completeness, and the possibility of avoiding both discreteness and density axioms.

**Critical Corrections to Research-011**:

1. **Research-011 claimed "the density path (Q) is NOT viable" because "Aut+(Q) does not act freely."** This conflates two distinct constructions. Aut+(Q) indeed does not act freely on Q. But the user does not need D = Aut+(Q). The correct construction is **D = (Q, +)**, the additive group of the rationals, which acts on Q by translation and DOES act freely and transitively. This makes Q a (Q,+)-torsor. The density path is NOT blocked.

2. **Research-011 claimed "Only Z among countable transitive linear orders without endpoints has the property that Aut+(T) acts FREELY and transitively with abelian Aut+(T)."** This is true for the FULL automorphism group Aut+(T), but irrelevant. The JPL paper requires D to be a linearly ordered abelian group acting freely and transitively on T -- it does NOT require D = Aut+(T). Any abelian subgroup of Aut+(T) acting freely and transitively suffices.

**Principal Findings**:

1. **The density path IS viable**: With the density axiom DN, the canonical timeline T is isomorphic to Q. The additive group (Q, +) is a subgroup of Aut+(Q) that acts freely and transitively. Set D = (Q, +). All required properties (linearly ordered abelian group, torsor) follow from Mathlib instances on Q.

2. **The algebraic approach does NOT avoid the choice**: Algebraic completeness (via Boolean algebras with operators / Lindenbaum-Tarski algebras) proves completeness for the LOGIC but does not construct the duration group D. The D construction is a semantic/model-theoretic concern, not a logical completeness concern.

3. **Avoiding both axioms is possible for COMPLETENESS but not for D-CONSTRUCTION**: TM is already complete for all reflexive transitive linear orders (established result). The D-construction requires additional structure (free transitive abelian action) that forces a specific order type.

4. **The parametric approach**: It IS possible to develop theory parametrically over an abstract `OrderedAddCommGroup D` with `AddTorsor D T`, deferring the concrete choice. But any concrete instantiation must choose Z or Q (or a subgroup of R).

5. **Density path vs discreteness path effort comparison**: The density path is approximately 150-250 lines (comparable to discreteness path), with slightly different proof obligations but strong Mathlib support.

**Recommendation**: The density path deserves equal consideration with the discreteness path. Given the user's strong preference for density over discreteness, and the mathematical viability of the density path, the density axiom DN should be the primary path forward.

---

## 2. Correction: Why the Density Path IS Viable

### 2.1 The Error in Research-011

Research-011 Section 7.2-7.3 argued:

> "For T isomorphic to Q: **No.** There are many order-preserving bijections taking a to b. For example, both 'translate by (b-a)' and 'scale by 2 around a then translate' are distinct automorphisms Q -> Q fixing different sets of points. So Aut+(Q) does NOT act freely on Q."

> "Only Z among countable transitive linear orders without endpoints has the property that Aut+(T) acts FREELY and transitively (i.e., is a regular action making T an Aut+(T)-torsor with abelian Aut+(T))."

**The error**: This analysis is correct about Aut+(Q) but draws the wrong conclusion. The JPL paper's requirement is NOT that D = Aut+(T). The requirement is:

> D is a linearly ordered abelian group, and T is an AddTorsor for D.

This means we need SOME abelian group D acting freely and transitively on T. We are free to choose D to be a SUBGROUP of Aut+(T), not the full automorphism group.

### 2.2 The Correct Construction for Q

When T is isomorphic to Q:

- **D = (Q, +)**, the additive group of the rationals
- **Action**: translation, i.e., d +v t = d + t
- **Free**: if d + t = t then d = 0. Trivially free.
- **Transitive**: for any a, b in Q, take d = b - a. Then d + a = b. Trivially transitive.
- **Abelian**: Q is abelian under addition. Trivially abelian.
- **Linearly ordered**: Q has the standard linear order compatible with addition.

The key insight: **(Q, +) IS a subgroup of Aut+(Q)**. Every rational number q defines a translation automorphism t_q : Q -> Q by t_q(x) = x + q. This map q |-> t_q embeds (Q, +) into Aut+(Q) as a subgroup. The image acts freely and transitively. We simply use this subgroup rather than all of Aut+(Q).

### 2.3 Comparison with the Z Case

| Property | D = Z (discrete path) | D = Q (density path) |
|----------|----------------------|---------------------|
| T isomorphic to | Z | Q |
| D = | (Z, +) | (Q, +) |
| D = Aut+(T)? | Yes (Z has no non-translation order-automorphisms) | No (Q has many, e.g., scaling) |
| D subset Aut+(T)? | Yes (proper = full) | Yes (proper subgroup) |
| Free action? | Yes | Yes |
| Transitive action? | Yes | Yes |
| Abelian? | Yes | Yes |
| Linearly ordered? | Yes | Yes |
| Ordered abelian group? | Yes | Yes |
| Torsor? | Yes | Yes |
| Archimedean? | Yes | Yes |
| Divisible? | No | Yes |

Both constructions are equally valid. The choice between them is a modeling decision, not a mathematical limitation.

### 2.4 Why D Does NOT Need to Be All of Aut+(T)

The TranslationGroup.lean module currently defines D = Additive(T ≃o T), i.e., ALL order automorphisms. This is an overcommitment. The JPL paper requires only that D is SOME linearly ordered abelian group with a free transitive action on T. The module header even documents this:

> "**AddCommGroup**: Requires Holder's theorem (freeness + order implies abelian)"

This concern vanishes if we do not insist D = Aut+(T). Instead, we can define D directly as the additive group of the carrier (Z or Q) once we have the isomorphism T ≃o Z or T ≃o Q.

---

## 3. Density Axiom and Canonical Model Construction

### 3.1 The Density Axiom DN

The density axiom is:

> **DN**: Fp -> FFp (if phi holds at some future time, it holds at some future-future time)

Equivalently: Gp -> GGp is already T4 (which TM has). The dual density axiom for the past would be:

> **DN-H**: Pp -> PPp (if phi held at some past time, it held at some past-past time)

**Frame condition**: DN corresponds to density of the strict ordering: for all s < t, there exists u with s < u < t. This is the definition of DenselyOrdered in Mathlib.

**Note**: DN-H is derivable from DN + the existing TM axioms (TA ensures past-future interaction). Alternatively, both can be added independently for symmetry.

### 3.2 Canonical Model with DN

When DN is added to TM, the canonical model construction produces a timeline T where:

1. T has a linear order (from existing TM axioms -- already proven in BidirectionalReachable.lean)
2. T has no maximum or minimum (from existing TM axioms -- NoMaxOrder, NoMinOrder)
3. **T is densely ordered** (from DN -- new)
4. T is countable (canonical model is countable)

By Cantor's theorem (formalized in Mathlib as `Order.iso_of_countable_dense`):

> Any two countable, dense, linear orders without endpoints are order-isomorphic.

Therefore T ≃o Q.

### 3.3 Proving DenselyOrdered from DN

The proof that DN forces density on the canonical model:

**Goal**: If s < t in the canonical timeline, there exists u with s < u < t.

**Proof sketch**:
- s < t in the canonical timeline means s.mcs and t.mcs are MCSes with CanonicalR(s.mcs, t.mcs) and not CanonicalR(t.mcs, s.mcs) (strict ordering from the antisymmetrization)
- From CanonicalR(s, t), there exists phi such that F(phi) is in s.mcs and phi is in t.mcs
- By DN: F(phi) in s.mcs implies FF(phi) in s.mcs
- FF(phi) means F(F(phi)) -- there exists an intermediate time where F(phi) holds
- By canonical_forward_F, there exists an MCS u in the bidirectional fragment with F(phi) in u.mcs
- u is strictly between s and t: CanonicalR(s, u) and CanonicalR(u, t)
- Therefore s < u < t in the canonical timeline

**Formalization effort**: approximately 50-80 lines, building on existing canonical_forward_F infrastructure.

### 3.4 Archimedeanness Is Not Needed (for the Dense Path)

A crucial advantage of the density path: **we do NOT need to prove Archimedeanness**. Cantor's theorem `Order.iso_of_countable_dense` requires:
- LinearOrder -- already have
- Countable -- canonical model is countable
- DenselyOrdered -- from DN
- NoMinOrder, NoMaxOrder -- from existing axioms
- Nonempty -- canonical model is nonempty

It does NOT require Archimedeanness. This eliminates the risk identified in research-011 Section 4.2-4.3 (that DP/DF alone do not force Archimedeanness, needing a separate proof from the construction).

---

## 4. Constructing D = (Q, +) from Syntax

### 4.1 Construction Overview

Given the canonical timeline T with DN axiom:

1. **Prove DenselyOrdered T** from DN (Section 3.3)
2. **Apply Cantor's theorem**: `Order.iso_of_countable_dense` gives `e : T ≃o Q`
3. **Define D := Q** with its standard additive group structure
4. **Define the action**: d +v t = e.symm(d + e(t))
5. **Prove torsor properties**: free and transitive, inherited from Q's self-torsor

### 4.2 Mathlib Infrastructure for Q

Q has extensive Mathlib support:

| Required Property | Mathlib Instance | Module |
|-------------------|-----------------|--------|
| AddCommGroup | `Rat.instAddCommGroup` | Core |
| LinearOrder | `Rat.instLinearOrder` | Core |
| OrderedAddCommGroup | `Rat.instOrderedAddCommGroup` | Core |
| AddTorsor Q Q | `addGroupIsAddTorsor Q` | `Mathlib.Algebra.AddTorsor` |
| DenselyOrdered | (from `LinearOrderedField`) | Core |
| NoMinOrder | (from `LinearOrderedField`) | Core |
| NoMaxOrder | (from `LinearOrderedField`) | Core |
| Countable | `Rat.instCountable` | Core |
| Archimedean | `Rat.instArchimedean` | Core |

**Key Mathlib declaration**: `addGroupIsAddTorsor (G : Type*) [AddGroup G] : AddTorsor G G`

This says every AddGroup is automatically a torsor over itself. Since Q is an AddGroup, Q is automatically an AddTorsor over itself. This gives the torsor structure FOR FREE.

### 4.3 Transferring the Torsor Structure

Once we have `e : T ≃o Q`:

```
-- Q is a torsor over itself
instance : AddTorsor Q Q := addGroupIsAddTorsor Q

-- Transfer to T via the order isomorphism
-- Action: d +v t = e.symm(d + e(t))
-- Subtraction: t₁ -v t₂ = e(t₁) - e(t₂)
```

The transfer of AddTorsor along an equivalence should follow from Mathlib's `Equiv.addTorsor` or similar transport machinery. If not directly available, it is a straightforward construction (approximately 20-30 lines).

### 4.4 Detailed Lean Sketch

```lean
-- Step 1: Prove DenselyOrdered on BidirectionalQuotient (from DN axiom)
instance instDenselyOrderedCanonicalTimeline :
    DenselyOrdered (CanonicalTimeline M₀ h_mcs₀) := by
  constructor
  intro a b hab
  -- Use DN to find intermediate point
  sorry -- ~50-80 lines

-- Step 2: Apply Cantor's theorem
noncomputable def timeline_iso_rat :
    CanonicalTimeline M₀ h_mcs₀ ≃o Q :=
  (Order.iso_of_countable_dense
    (CanonicalTimeline M₀ h_mcs₀) Q).some

-- Step 3: D = Q with its standard structure
abbrev DurationGroup := Q

-- Step 4: Define the action of Q on T
noncomputable def durationAction
    (d : DurationGroup) (t : CanonicalTimeline M₀ h_mcs₀) :
    CanonicalTimeline M₀ h_mcs₀ :=
  timeline_iso_rat.symm (d + timeline_iso_rat t)

-- Step 5: Prove AddTorsor DurationGroup (CanonicalTimeline M₀ h_mcs₀)
-- This follows from addGroupIsAddTorsor Q transported along timeline_iso_rat
```

### 4.5 Effort Estimate for Density Path

| Component | Lines | Difficulty |
|-----------|-------|------------|
| DN axiom addition | 10-15 | Low |
| DN soundness proof | 20-30 | Low-medium |
| DenselyOrdered proof | 50-80 | Medium |
| Cantor isomorphism application | 5-10 | Low |
| Torsor transfer | 20-30 | Low-medium |
| D property verification | 10-20 | Low |
| **Total** | **115-185** | **Medium** |

Compare with discreteness path (from research-011):
- DP/DF axioms + SuccOrder/PredOrder: 100-200 lines
- Archimedeanness proof: 50-100 lines (RISK: may fail)
- **Total**: 150-300 lines, with Archimedeanness risk

The density path is comparable in effort and has LOWER RISK because it does not require the Archimedeanness proof.

---

## 5. Algebraic Approach to Completeness

### 5.1 What IS the Algebraic Approach?

The algebraic approach to modal/temporal logic completeness uses:

1. **Lindenbaum-Tarski algebra**: The quotient of formulas by provable equivalence forms a Boolean algebra
2. **Modal/temporal operators as algebra operators**: G, H, Box become operators on this Boolean algebra satisfying distribution and normality
3. **Stone duality**: Boolean algebras correspond to Stone spaces (compact totally disconnected topological spaces)
4. **Jonsson-Tarski representation**: Boolean algebras with operators correspond to descriptive general frames

The algebraic completeness theorem says: a formula phi is provable in TM if and only if phi = top in the Lindenbaum-Tarski algebra of TM.

### 5.2 Does the Algebraic Approach Avoid Concrete Models?

**Partially.** The algebraic approach proves:

> phi is provable iff phi is valid in all modal algebras iff phi is valid in all descriptive general frames

This avoids constructing a SPECIFIC Kripke model. However:

1. **It does NOT construct D.** The algebraic approach proves completeness for the LOGIC, but the duration group D is a feature of the SPECIFIC SEMANTIC MODEL (the JPL task frame). Algebraic completeness gives validity over abstract algebraic structures, not over task frames with duration groups.

2. **The Jonsson-Tarski representation eventually produces a relational structure.** So the algebraic approach does not truly "avoid" relational semantics -- it defers it via duality.

3. **The D-construction is a REPRESENTATION problem, not a COMPLETENESS problem.** We need to show that the canonical model (which algebraic completeness guarantees exists) can be equipped with a duration group. This is an additional step beyond completeness.

### 5.3 What the Algebraic Approach CAN Do

The algebraic approach could potentially help with:

1. **Avoiding the concrete Z-vs-Q choice for COMPLETENESS**: TM is already complete for all reflexive transitive linear orders. The algebraic approach formalizes this without choosing a specific order type.

2. **Proving the equivalence between algebraic and Kripke semantics**: This could bridge the gap between non-standard and standard validity that is currently an open problem in the codebase (see ROAD_MAP Dead End: "Non-Standard Validity Completeness").

3. **Abstracting over the timeline type**: The algebraic approach works with arbitrary Boolean algebras with operators, which naturally parametrize over different timeline types.

### 5.4 Existing Algebraic Infrastructure

The codebase has a PAUSED algebraic verification path in `Theories/Bimodal/Metalogic/Algebraic/`:

- `LindenbaumQuotient.lean`: Lindenbaum-Tarski quotient algebra defined
- `BooleanStructure.lean`: Boolean algebra structure proven
- `InteriorOperators.lean`: Interior operators for G/H partially implemented
- `UltrafilterMCS.lean`: Ultrafilter-MCS correspondence
- `AlgebraicRepresentation.lean`: Representation theorem (contains sorries)

This infrastructure is promising but incomplete (Phase 6 of Task 700, with sorries).

### 5.5 Conclusion on the Algebraic Approach

**The algebraic approach cannot avoid the D-construction choice.** It can prove completeness parametrically, but constructing D requires choosing a concrete order type for T. The algebraic approach is orthogonal to the density-vs-discreteness question, not a solution to it.

---

## 6. Avoiding Both Axioms: Analysis

### 6.1 What Works Without Either Axiom

**Completeness**: TM (without DN or DP/DF) is already complete for the class of all reflexive transitive linear orders without endpoints. This is the established result from Burgess (1982), Goldblatt (1992).

**The canonical model exists**: The canonical model construction produces SOME reflexive transitive linear order T. The truth lemma holds.

### 6.2 What Fails Without Either Axiom

**The D-construction**: To build D as a linearly ordered abelian group acting freely and transitively on T, we need T to have a specific structure. By Morel's classification (research-011 Section 2), countable transitive linear orders include Z, Q, Z^2, Z^omega, Z^n * Q, etc.

For order types Z^n (n >= 2):
- Aut+(T) is non-abelian (contains wreath products)
- No abelian subgroup acts freely and transitively
- D cannot be constructed as required

**The problem**: Without density or discreteness, the canonical model MIGHT have order type Z^2, in which case D cannot exist. The axiom choice EXCLUDES the problematic order types.

### 6.3 The Parametric Approach

It IS possible to develop theory parametrically:

```lean
variable (D : Type*) [OrderedAddCommGroup D]
variable (T : Type*) [LinearOrder T] [AddTorsor D T]

-- Prove theorems about task frames generically
-- D could be Z, Q, or any ordered abelian group
```

This is the `HomogeneousTimeline` / `RegularTimeline` approach from research-010/011. It defers the choice to the instantiation point. But:

1. Any concrete instantiation MUST choose (D,T) = (Z,Z) or (Q,Q) or some subgroup of (R,R)
2. The completeness theorem needs a concrete model, which needs a concrete D
3. The parametric approach is a software engineering abstraction, not a mathematical solution

### 6.4 Can D Be Constructed as an Abstract Group?

The user asks: "Can D be constructed as an abstract abelian group with a linear order, without specifying whether it is Z or Q?"

**Answer**: In principle, yes. One could define D as the Archimedean closure or divisible hull of whatever group the canonical model naturally produces. But:

1. The canonical model WITHOUT DN or DP/DF does not naturally produce ANY group. It produces a linear order T, and Aut+(T) may be non-abelian.

2. To extract an abelian subgroup of Aut+(T) acting freely and transitively, one needs T to already have a specific structure (homogeneous with abelian translation group).

3. This is circular: we need the structure to define D, but D defines the structure.

**Conclusion**: No, D cannot be constructed from pure syntax without an axiom forcing the timeline structure. The choice between Z and Q (or more generally, between subgroups of R) is mathematically necessary.

---

## 7. Holder's Theorem and Its Implications

### 7.1 Precise Statement

**Holder's Theorem** (1901): A linearly ordered group is Archimedean if and only if it is isomorphic (as an ordered group) to a subgroup of (R, +, <=).

**Corollaries**:
- Every Archimedean linearly ordered group is abelian (commutativity follows from the embedding into R, which is abelian)
- The countable Archimedean linearly ordered groups are precisely the subgroups of (R, +) that are countable

### 7.2 Which Subgroups of R Are Relevant?

The countable subgroups of (R, +) that are also linearly ordered and have no min/max include:
- **Z**: discrete, Archimedean
- **Q**: dense, Archimedean, divisible
- **Z[1/2] = {a/2^n : a in Z, n in N}**: dense, Archimedean, not fully divisible
- Any countable subfield of R
- Any finitely generated subgroup (isomorphic to Z^n but only Z^1 = Z is linearly orderable as a single chain)

For our purposes, the relevant ones are Z and Q, because:
- Z arises from discreteness (DP/DF)
- Q arises from density (DN) plus countability
- Other subgroups of R do not correspond to standard temporal axioms

### 7.3 Holder's Theorem and the Current Construction

The current TranslationGroup.lean defines D = Additive(T ≃o T) and notes that AddCommGroup requires "Holder's theorem (freeness + order implies abelian)."

With the density path (D = Q directly), Holder's theorem is NOT needed:
- D = Q is defined as an abelian group from the start
- Commutativity is a Mathlib instance, not a theorem to prove
- The freeness + ordered action argument is unnecessary because we are not deriving abelianness from the action

Similarly, with the discreteness path (D = Z), Holder's theorem is not needed because Z is trivially abelian.

**Holder's theorem would only be needed if D were defined as Aut+(T) and we needed to prove commutativity from properties of the action.** Since both concrete paths define D directly as Z or Q (not as Aut+(T)), Holder's theorem is bypassed.

### 7.4 Implication: TranslationGroup.lean Needs Redesign

The current design D = Additive(T ≃o T) is an overcommitment that creates unnecessary proof obligations (Holder's theorem, freeness of Aut+(T), etc.). The correct design is:

**For the density path**:
```lean
abbrev DurationGroup := Q
-- All properties are Mathlib instances
```

**For the discreteness path**:
```lean
abbrev DurationGroup := Z
-- All properties are Mathlib instances
```

**For the parametric path**:
```lean
variable (D : Type*) [LinearOrderedAddCommGroup D]
variable (T : Type*) [LinearOrder T] [AddTorsor D T]
```

In all three cases, D is NOT defined as Aut+(T).

---

## 8. Divisibility, Density, and the Density Axiom

### 8.1 Divisibility of Q

Q is a **divisible** abelian group: for every q in Q and every positive integer n, there exists r in Q with n * r = q (namely r = q/n).

Q is also **uniquely divisible**: the r above is unique (since Q is torsion-free).

### 8.2 Does the Density Axiom Imply Divisibility of D?

Not directly. The density axiom DN (Fp -> FFp) forces the timeline T to be densely ordered, which (with countability and no endpoints) gives T ≃o Q. Setting D = Q then gives a divisible group.

But this is a consequence of the CONSTRUCTION (D = Q), not of the AXIOM (DN). The axiom DN says nothing about divisibility per se -- it says "between any two time points there is a third." The divisibility of D follows because:

1. DN forces T to be dense
2. Cantor's theorem gives T ≃o Q
3. D = Q is divisible

### 8.3 Is There a Modal Axiom for Divisibility?

Not in the standard temporal logic language. Divisibility of D says "for every duration d and positive integer n, there exists a duration d' with n * d' = d." This is a property of the duration GROUP, not of the TIMELINE, and is not expressible in the temporal modal language which only talks about time points and temporal relationships.

However, divisibility of D is EQUIVALENT to density of T when D acts freely and transitively on T:
- If D is divisible and acts freely/transitively, then T is dense (between any two points, we can find a point at half the distance)
- If T is dense and D acts freely/transitively, then D is divisible (the midpoint between 0 and d gives d/2)

So in the presence of the torsor structure, DN effectively captures divisibility.

---

## 9. Comparison of Paths: Density vs Discreteness vs Parametric

### 9.1 Density Path (DN, D = Q)

**Axiom added**: DN: Fp -> FFp

**Construction**:
1. Prove DenselyOrdered on canonical timeline (from DN)
2. Apply `Order.iso_of_countable_dense` to get T ≃o Q
3. Set D = Q with standard Mathlib instances
4. Transfer AddTorsor along the isomorphism

**Properties that follow immediately**:
- AddCommGroup Q: Mathlib instance
- LinearOrder Q: Mathlib instance
- OrderedAddCommGroup Q: Mathlib instance
- AddTorsor Q Q: `addGroupIsAddTorsor Q`
- Archimedean Q: Mathlib instance

**Effort**: 115-185 lines
**Risk**: Low (no Archimedeanness proof needed)

**Advantages**:
- User's stated preference
- No Archimedeanness risk
- Cantor's theorem is clean and well-supported in Mathlib
- Q has richer algebraic structure (field, divisible)
- Philosophically natural for continuous/dense time

**Disadvantages**:
- DN is one additional axiom beyond current TM
- Must prove density transfers to the canonical model
- Slightly less intuitive than "time steps" for some applications

### 9.2 Discreteness Path (DP/DF, D = Z)

**Axioms added**: DP: Hp -> p v PHp; DF: Gp -> p v FGp

**Construction**:
1. Prove SuccOrder/PredOrder on canonical timeline (from DP/DF)
2. Prove IsSuccArchimedean (from bidirectional reachability -- RISK)
3. Apply `orderIsoIntOfLinearSuccPredArch` to get T ≃o Z
4. Set D = Z with standard Mathlib instances

**Effort**: 150-300 lines
**Risk**: Medium (Archimedeanness proof may be difficult)

**Advantages**:
- Two axioms but very standard in literature
- Intuitive "time steps" interpretation
- Z has simpler structure

**Disadvantages**:
- Archimedeanness risk (research-011 Section 4.2-4.3)
- Not the user's preference
- Restricts to discrete time

### 9.3 Parametric Path (Abstract D)

**No axioms added** (to TM itself)

**Construction**:
1. Define theory parametrically over `[LinearOrderedAddCommGroup D]` and `[AddTorsor D T]`
2. Prove TaskFrame properties generically
3. Defer concrete instantiation

**Effort**: 50-100 lines (for the parametric development), PLUS the effort of one of the above paths for instantiation

**Advantages**:
- Maximum generality
- Can support both Z and Q (and other subgroups of R)
- Clean separation of concerns

**Disadvantages**:
- Does not produce a concrete completeness theorem until instantiated
- May require refactoring TranslationGroup.lean

### 9.4 Recommended Approach

**Primary**: Density path (DN, D = Q) -- matches user preference, lower risk, comparable effort.

**Secondary**: Develop parametric infrastructure alongside, so that both Z and Q can be instantiated later if desired.

**Deferred**: Discreteness path can be added later as an alternative instantiation of the parametric framework.

---

## 10. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Single-Family BFMCS modal_backward | Low | Not relevant to D-construction |
| CanonicalReachable/CanonicalQuotient Stack | Medium | Bidirectional fragment is correct base for density proof |
| Non-Standard Validity Completeness | Low | Algebraic approach could help bridge gap but is orthogonal |
| Constant Witness Family | Low | Not relevant |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | Compatible: `fmcs : Q -> Set Formula` works with Q-indexed families |
| Algebraic Verification | PAUSED | Could complement: algebraic completeness is independent of D-choice |
| Representation-First | CONCLUDED | Density path integrates with existing representation architecture |

### Key Insight

The "Indexed MCS Family Approach" currently uses `fmcs : D -> Set Formula`. With D = Q, this becomes `fmcs : Q -> Set Formula`, which is a densely-indexed family. This is compatible with the existing FMCS infrastructure -- the indexing type changes from Z to Q, but the coherence conditions (forward_G, backward_H, etc.) remain structurally identical.

---

## 11. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| D != Aut+(T) -- subgroup suffices for torsor | Section 2 | No | extension |
| Density path construction (DN -> Q -> D) | Section 4 | No | new_file |
| Algebraic completeness vs D-construction separation | Section 5 | No | extension |
| Holder's theorem bypassed by direct D definition | Section 7 | No | extension |
| Cantor's theorem for Q identification | Section 3 | No | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `duration-group-construction.md` | `domain/` | D-construction paths (Z, Q, parametric), axiom requirements, Mathlib support | High | No |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `kripke-semantics-overview.md` | Temporal Frame Classes | Density axiom DN, frame condition, relationship to Q | Medium | No |
| `metalogic-concepts.md` | Completeness | Distinction between frame completeness and D-constructibility | Medium | No |

### Summary

- **New files needed**: 1
- **Extensions needed**: 2
- **Tasks to create**: 0
- **High priority gaps**: 1

---

## 12. Decisions

1. **The density path IS viable.** Research-011's claim that it is blocked was based on confusing D = Aut+(T) with D = (Q, +).

2. **D should NOT be defined as Aut+(T).** It should be defined directly as Q (or Z, or parametrically) with Mathlib instances.

3. **The algebraic approach does not avoid the D-construction choice.** It is orthogonal.

4. **Avoiding both axioms is impossible for D-construction** (though TM is already complete for all linear orders without either axiom).

5. **The density path (DN, D = Q) is the recommended primary path**, given the user's preference, lower risk, and comparable effort.

6. **TranslationGroup.lean should be redesigned** to not define D as Aut+(T), instead using a direct definition as Q (or Z, or a parameter).

---

## 13. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| DN axiom conflicts with existing proofs | Low | High | DN is sound for all dense linear frames; verify against all TaskFrame models |
| DenselyOrdered proof from DN is difficult | Low-Medium | Medium | Proof sketch in Section 3.3 is straightforward; builds on existing canonical_forward_F |
| Cantor's theorem application requires additional Mathlib assumptions | Low | Low | `Order.iso_of_countable_dense` requirements are exactly what we prove |
| Torsor transfer along OrderIso is not directly in Mathlib | Medium | Low | Manual construction is ~20-30 lines; straightforward |
| Q-indexed families require changes to FMCS infrastructure | Medium | Medium | Coherence conditions are parametric in index type; mostly notation changes |
| TranslationGroup.lean redesign is significant refactor | Medium | Medium | Can be done incrementally; old module preserved as Boneyard |

---

## 14. Appendix

### Search Queries Used

1. "Holder's theorem ordered abelian groups embedding into reals statement proof"
2. "algebraic semantics modal logic completeness Boolean algebra operators Stone duality avoid concrete models"
3. "temporal logic completeness dense linear order canonical model Q rationals density axiom construction"
4. "divisible ordered abelian group rationals uniquely divisible Archimedean"
5. "ordered group free transitive action linear order torsor abelian subgroup translation"
6. "algebraic completeness modal logic without Kripke frames Lindenbaum Tarski algebra representation theorem"
7. "Venema temporal logic completeness dense order canonical model construction density axiom back-and-forth"
8. "rationals Q affine space over itself additive group torsor translation acts freely transitively"

### Mathlib Lookup Results

1. `Order.iso_of_countable_dense` -- Cantor's theorem: countable dense unbounded linear orders are isomorphic
2. `addGroupIsAddTorsor` -- Every AddGroup G is an AddTorsor G G (KEY for density path)
3. `Equiv.vaddConst` -- v |-> v +v p is a bijection G ≃ P (torsor evaluation at a point)
4. `DenselyOrdered` -- Mathlib typeclass for dense orders
5. `exists_between` -- In a DenselyOrdered type, between any two elements there is a third
6. `Rat.instArchimedean` -- Q is Archimedean (for Holder's theorem context)
7. `orderIsoIntOfLinearSuccPredArch` -- T ≃o Z (for comparison with discrete path)

### Codebase Files Examined

- `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- Current D definition (D = Aut+(T))
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- Canonical timeline construction
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Current axiom system (no DN or DP/DF)
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` -- Algebraic approach (PAUSED)
- `specs/956_construct_d_as_translation_group_from_syntax/reports/research-010.md` -- Prior homogeneity analysis
- `specs/956_construct_d_as_translation_group_from_syntax/reports/research-011.md` -- Prior Morel correction (with error corrected here)

### References

- Holder, O. (1901). "Die Axiome der Quantitat und die Lehre vom Mass." Berichte uber die Verhandlungen der Sachsischen Gesellschaft der Wissenschaften zu Leipzig.
- Morel, A.C. (1965). "A class of relation types isomorphic to the ordinals." Michigan Mathematical Journal.
- Cantor, G. (1895). "Beitrage zur Begrundung der transfiniten Mengenlehre." Mathematische Annalen.
- Venema, Y. "Temporal Logic." Chapter 10 in Handbook of Philosophical Logic.
- Jonsson, B. and Tarski, A. (1951). "Boolean algebras with operators." American Journal of Mathematics.
- Burgess, J.P. (1982). "Axioms for tense logic I." Notre Dame J. Formal Logic.
- Goldblatt, R. (1992). Logics of Time and Computation. CSLI Publications.
- Stanford Encyclopedia of Philosophy. "Temporal Logic." https://plato.stanford.edu/entries/logic-temporal/
- nLab. "Algebraic model for modal logics." https://ncatlab.org/nlab/show/algebraic+model+for+modal+logics
- Mathlib: `Mathlib.Order.CountableDenseLinearOrder`, `Mathlib.Algebra.AddTorsor`, `Mathlib.Algebra.Order.Archimedean`

---

## 15. Artifacts

- **This report**: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-012.md`
- **Key referenced files**:
  - `Theories/Bimodal/Metalogic/Bundle/TranslationGroup.lean` -- Current D construction (needs redesign)
  - `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- Canonical timeline
  - `Theories/Bimodal/ProofSystem/Axioms.lean` -- Axiom system
  - `specs/956_construct_d_as_translation_group_from_syntax/reports/research-011.md` -- Prior report (corrected herein)

---

## 16. Next Steps

1. **Decision**: Accept density path (DN, D = Q) as the primary path forward
2. **Add DN axiom** to Axioms.lean and prove soundness
3. **Prove DenselyOrdered** on BidirectionalQuotient from DN
4. **Apply Cantor's theorem** to get T ≃o Q
5. **Define D = Q** directly (not as Aut+(T)) with Mathlib instances
6. **Transfer AddTorsor** along the order isomorphism
7. **Redesign TranslationGroup.lean** to use direct D definition
8. **Optionally**: develop parametric infrastructure for future Z-instantiation
