# Research Report: Rigidity Counterexample and Correct Torsor Construction

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Focus**: Counterexample to Aut+(T) rigidity; correct conditions for free action; recommended path forward
**Session**: sess_1774100000_rig013
**Domains**: logic, math

## Executive Summary

The rigidity theorem claimed in report 12 -- "if f : T ->o T fixes a point, then f = id" -- is **FALSE** for general countable DLOs without endpoints. The counterexample is elementary and devastating: on Q, the map x -> 2x is an order automorphism fixing 0 but is not the identity. This means D = Aut+(T) is **too large** to act freely on T, and the entire torsor construction based on D = Additive(T ->o T) is unsound as stated.

The correct path forward is the **Cantor transfer approach**: use the isomorphism T ~=o Q (which exists for the dense case) to set D = Q directly, inheriting Q's self-torsor structure. This avoids the rigidity problem entirely and provides all required algebraic structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid, AddTorsor) from Mathlib for free.

---

## 1. The Counterexample: Rigidity Fails for Aut+(Q)

### 1.1 Precise Counterexample

**Claim** (from report 12, Theorem 3.1): If f in Aut+(T) fixes any point t0, then f = id.

**Counterexample**: Let T = Q (rationals with standard order).

Define f : Q -> Q by f(x) = 2x.

- f is order-preserving: x <= y implies 2x <= 2y.
- f is a bijection: inverse is g(x) = x/2.
- f(0) = 0, so f fixes 0.
- f(1) = 2 != 1, so f != id.

Therefore f in Aut+(Q) fixes a point but is not the identity. QED.

### 1.2 The Family of Counterexamples

The problem is far worse than a single counterexample. For any a, b in Q with a != 0 and b arbitrary, the map f(x) = ax + b (with a > 0) is an order automorphism of Q. The affine group Aff+(Q) = { x -> ax + b : a > 0, b in Q } is a subgroup of Aut+(Q), and:

- Translations (a=1): f(x) = x + b. These have no fixed points (for b != 0). They form the "good" subgroup.
- Dilations (a != 1, b != 0): f(x) = ax + b has a unique fixed point x = b/(1-a). These break rigidity.
- Pure scaling (a != 1, b = 0): f(x) = ax fixes 0.

Moreover, Aut+(Q) contains much more than Aff+(Q). It contains all piecewise-linear order-preserving bijections, and even non-constructive ones built via back-and-forth.

### 1.3 Why the Proof in Report 12 Fails

The "proof" in Section 3.2-3.3 of report 12 attempted an orbit-based argument but was never completed correctly. The critical gap was at the "intermediate value" step: the claim that if h(t0) <= t0 and h(t1) > t1 then h has a fixed point between t0 and t1. This is FALSE for order automorphisms of Q in general -- the rationals do not have the completeness property needed for intermediate value arguments.

Specifically: Let h(x) = 2x. Then h(0) = 0 = 0 (fixed), h(1) = 2 > 1. But h(1/2) = 1 > 1/2, h(1/4) = 1/2 > 1/4, etc. The only fixed point is 0 itself.

The orbit argument also fails: the orbit of 1 under f(x) = 2x is {2^n : n in Z}, which is a discrete subset of Q. The fixed point 0 sits below all positive orbit elements but is not "between consecutive orbit elements" in the way the proof sketch required.

### 1.4 Density Does Not Help

Report 12 stated the result as "Theorem (Rigidity for DLO)" but DLO (dense linear order without endpoints) is NOT a sufficient condition. Q is the unique countable DLO without endpoints (up to isomorphism), and rigidity fails for Q. The density property is irrelevant to rigidity.

---

## 2. Correct Characterization of Freeness

### 2.1 When Does a Subgroup of Aut+(T) Act Freely?

**Definition**: A subgroup G <= Aut+(T) acts **freely** on T if for all g in G and t in T: g(t) = t implies g = id.

**Theorem** (Characterization): The following conditions on a subgroup G <= Aut+(T) are equivalent to freeness:

(a) G acts freely (no non-identity element has a fixed point)
(b) G is **fixed-point free**: the only element with any fixed point is the identity
(c) For any g1, g2 in G: if g1(t) = g2(t) for some t, then g1 = g2 (the action is **sharply transitive** on orbits)

**Key point**: This is a property of the SUBGROUP, not of T alone. No property of the linear order T can make all of Aut+(T) act freely, because Aut+(T) always contains non-identity elements with fixed points (assuming T has at least 3 points).

### 2.2 The Translation Subgroup

For T = Q, the translation subgroup Trans(Q) = { x -> x + b : b in Q } is the unique maximal subgroup of Aut+(Q) that:
- Acts freely on Q (no translation has a fixed point, except the identity)
- Acts transitively on Q (for any p, q, the translation x -> x + (q-p) sends p to q)
- Is abelian (translations commute)
- Is order-compatible (b1 < b2 iff x+b1 < x+b2 for all x)

This is exactly the group that makes Q a torsor: AddTorsor Q Q via addition.

### 2.3 Can We Identify the Translation Subgroup Intrinsically?

For a general linear order T (not equipped with an additive structure), there is no canonical way to pick out "the translation subgroup" of Aut+(T). The translation subgroup is determined by the torsor structure, not the other way around.

This is the fundamental circularity in the D = Aut+(T) approach:
- To get a free action, we need to restrict to a subgroup of Aut+(T)
- To identify the right subgroup, we need to already know the torsor structure
- To define the torsor structure, we need the free-acting group

**Conclusion**: D = Aut+(T) is the wrong definition. We cannot extract D from T's order structure alone without additional information.

---

## 3. The Cantor Transfer Approach

### 3.1 Core Idea

Since T ~=o Q (by Cantor's theorem, given that T is a countable DLO without endpoints), we can:
1. Set D = Q (the rational numbers)
2. Transfer Q's self-torsor structure to T via the isomorphism

### 3.2 Construction

Let phi : T ->o Q be the Cantor isomorphism (exists by `Order.iso_of_countable_dense`).

Define the action of D = Q on T:
```
d +v w := phi.symm (d + phi w)
```

Define subtraction:
```
w1 -v w2 := phi w1 - phi w2
```

### 3.3 Properties (All Follow Immediately)

**AddCommGroup Q**: Already in Mathlib (`Rat.addCommGroup`).

**LinearOrder Q**: Already in Mathlib (`Rat.linearOrder`).

**IsOrderedAddMonoid Q**: Already in Mathlib (Q is a `LinearOrderedField`).

**AddTorsor Q T**: Transferred from `addGroupIsAddTorsor Q Q` via phi. The key equations:
- `(w1 -v w2) +v w2 = w1`: Unfolds to phi.symm((phi w1 - phi w2) + phi w2) = phi.symm(phi w1) = w1.
- `(d +v w) -v w = d`: Unfolds to phi(phi.symm(d + phi w)) - phi w = (d + phi w) - phi w = d.

**Freeness**: If d +v w = w, then phi.symm(d + phi w) = w, so d + phi w = phi w, so d = 0. Free action follows from Q's self-torsor.

**Order compatibility**: d1 <= d2 iff d1 +v w <= d2 +v w, since phi is an order isomorphism and addition on Q is order-compatible.

### 3.4 Mathlib Support

The key Mathlib declarations:
- `Rat.addCommGroup : AddCommGroup Q` (from Mathlib.Data.Rat.Defs)
- `Rat.linearOrder : LinearOrder Q` (from Mathlib.Data.Rat.Order)
- `addGroupIsAddTorsor : AddTorsor G G` for any AddGroup G (from Mathlib.Algebra.AddTorsor.Defs)
- `Order.iso_of_countable_dense : Nonempty (alpha ~=o beta)` for countable DLOs (from Mathlib.Order.CountableDenseLinearOrder)

### 3.5 What Needs to Be Built

The transfer itself is not a single Mathlib lemma. We need:

1. **Torsor transfer along OrderIso** (~30 lines): Given phi : T ~=o Q, construct AddTorsor Q T. This defines `+v` and `-v` via phi and verifies the torsor axioms by computation through phi/phi.symm.

2. **TaskFrame assembly** (~20 lines): Package D = Q, the torsor, and the task relation into a TaskFrame Q.

3. **Cantor isomorphism instance** (~20 lines): Assemble the required instances (Countable T, DenselyOrdered T, NoMaxOrder T, NoMinOrder T, Nonempty T) to invoke `Order.iso_of_countable_dense`.

Total new code: approximately 70-100 lines.

### 3.6 Non-Canonicity and Its Impact

**Concern**: The Cantor isomorphism phi is **non-canonical** -- it depends on a choice of enumeration. Different enumerations give different phi's, hence different torsor structures on T.

**Why this is acceptable**: The completeness theorem only requires the EXISTENCE of a countermodel. We need: "there exists D, a TaskFrame, and a model falsifying phi." The specific choice of isomorphism does not matter -- any choice produces a valid countermodel.

**Lean formalization**: The `Order.iso_of_countable_dense` gives `Nonempty (T ~=o Q)`, so we use `Classical.choice` (or `Nonempty.some`) to obtain a specific phi. This is fine for a pure existence proof.

---

## 4. Does the CanonicalTimeline's Extra Structure Help?

### 4.1 The Question

T is constructed from MCSes via BidirectionalFragment + Antisymmetrization. Could this modal/temporal structure provide a canonical identification of a "translation subgroup"?

### 4.2 Analysis

The BidirectionalFragment carries temporal structure from the base logic:
- CanonicalR defines a step-relation between MCSes
- Each MCS carries a complete theory (set of formulas)
- The temporal axioms (seriality, transitivity, linearity) impose structure

However, this structure does **not** provide a canonical group operation on T:
- There is no natural notion of "adding" two equivalence classes of MCSes
- The CanonicalR relation gives successor/predecessor structure (in the discrete case) but no group operation
- The Antisymmetrization quotient destroys any potential additive structure

### 4.3 Could We Define D via CanonicalR Steps?

In the **discrete** case (T ~=o Z), one might try: D = Z, with d acting as "take d successor steps." This is well-defined because:
- succ : T -> T is an order automorphism (from discreteness axioms DF/DB)
- succ^n is the unique order automorphism sending any t to succ^n(t)
- The action is free and transitive by IsSuccArchimedean

This approach works! But it uses T ~=o Z (the discrete Cantor theorem) which is the same strategy as Cantor transfer, just with Z instead of Q.

### 4.4 Conclusion

The extra structure of the CanonicalTimeline does not provide a fundamentally different path. In both the dense and discrete cases, the correct approach is:
1. Establish the appropriate order-theoretic characterization (DLO for dense, succ-archimedean for discrete)
2. Apply the appropriate Cantor/characterization theorem (T ~=o Q or T ~=o Z)
3. Transfer the torsor structure from Q or Z

---

## 5. Impact on Existing Code

### 5.1 What Must Change

**TranslationGroup.lean** (Theories/Bimodal/Boneyard/Task956_IntRat/):
- `TranslationGroup` = `Additive (T ->o T)` is WRONG as D
- All theorems about the action are correct as algebraic identities but irrelevant since D is wrong
- The "deferred" items (Holder's theorem, LinearOrder on D, AddTorsor) were predicated on rigidity which is false

**Report 12** (torsor-construction-full.md):
- Part 3 (Rigidity) is false -- the proof was never completed and the theorem is wrong
- Parts 5-6 (Holder's theorem, LinearOrder on D) depended on rigidity and are moot
- Parts 1-2 (timeline foundation, AddGroup structure) are correct but describe the wrong D
- Part 4 (homogeneity) is correct and still needed -- but it follows from Cantor transfer

### 5.2 What Is Preserved

- **T = BidirectionalQuotient** with LinearOrder, Countable, DenselyOrdered (under +DN), NoMaxOrder, NoMinOrder -- all correct and needed
- **CanonicalFMCS** with forward_F, backward_P -- correct and needed for the model construction
- **BidirectionalReachable** with F/P witness closure -- correct and critical
- The **task relation** concept needs updating: instead of using Aut+(T), use Q-translations via phi

### 5.3 What Is New

A new module replacing TranslationGroup.lean should:
1. Assemble instances for T to invoke Cantor's theorem
2. Obtain phi : T ~=o Q (noncomputably)
3. Define the torsor structure on T via phi
4. Define the task relation as d +v w = w' (using Q-action)
5. Prove TaskFrame properties (which now follow from Q's ordered group structure)

---

## 6. Recommendations

### 6.1 Primary Recommendation: Cantor Transfer with D = Q

**For the dense case** (base logic + DN density axiom):

1. **Set D = Q** (the rational numbers)
2. **Use Cantor isomorphism** phi : T ~=o Q to transfer torsor structure
3. **All algebraic properties** (AddCommGroup, LinearOrder, IsOrderedAddMonoid, AddTorsor) come from Mathlib for free
4. **Estimated effort**: 70-100 lines of new Lean code, mostly boilerplate instances

### 6.2 Secondary Recommendation: Direct Transfer for D = Z

**For the discrete case** (base logic + DF/DB discreteness axioms):

1. **Set D = Z** (the integers)
2. **Use discrete characterization** T ~=o Z via succ-archimedean + no endpoints
3. **Same transfer pattern** as the dense case

### 6.3 Concrete Next Steps

1. **Archive TranslationGroup.lean** to Boneyard (it is mathematically unsound as the definition of D)
2. **Create CantorTransfer.lean**: assemble T's instances, obtain phi, construct AddTorsor Q T
3. **Create CanonicalTaskFrame.lean**: define TaskFrame Q using the transferred torsor
4. **Update the canonical model construction** to use D = Q instead of D = Aut+(T)
5. **Verify forward_F/backward_P** transfer correctly in the new framework

### 6.4 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Cantor isomorphism not in Mathlib | Low | High | `Order.iso_of_countable_dense` exists; verify exact API |
| Instance assembly for T fails | Medium | Medium | May need to prove DenselyOrdered T explicitly from +DN |
| Non-canonicity causes issues | Low | Low | Only need existence; Classical.choice is fine |
| Task relation needs reworking | Certain | Medium | Straightforward: replace Aut+(T) action with Q-action |

---

## 7. Mathematical Context

### 7.1 Why Aut+(Q) Is Not Free: The Fundamental Reason

The group Aut+(Q) is MUCH larger than the translation group. Its elements include:
- Translations: x -> x + b (free, transitive, abelian -- the "good" part)
- Dilations: x -> ax for a > 0 (fixes 0 -- breaks freeness)
- Affine maps: x -> ax + b (fixes b/(1-a) when a != 1)
- Piecewise-linear maps (uncountably many)
- Wild automorphisms (via back-and-forth, non-constructive)

The translation group is the unique **regular** (= free + transitive) abelian subgroup of Aut+(Q), and it is precisely the group that defines Q's torsor structure.

### 7.2 Holder's Theorem -- What It Actually Says

Holder's theorem states: If a group G acts freely and order-preservingly on a linear order T, then G is abelian and order-isomorphic to a subgroup of (R, +).

The theorem's hypothesis is that G acts FREELY. It does NOT say that Aut+(T) acts freely. Holder's theorem applies to the translation subgroup (which does act freely) but not to the full automorphism group.

Report 12 applied Holder's theorem to Aut+(T) as D, which required rigidity (freeness of the full automorphism group). Since rigidity fails, Holder's theorem does not apply to D = Aut+(T). It does apply to the translation subgroup, but identifying that subgroup requires the torsor structure we are trying to construct -- hence the circularity.

### 7.3 Historical Note

The rigidity theorem IS true for a specific class of linear orders: those with **no non-trivial convex automorphism-invariant partition**. For Q, the partition into {negative rationals} U {0} U {positive rationals} is convex and invariant under x -> 2x. This is why rigidity fails.

Rigidity holds for Z (the integers): any order automorphism of Z is a translation (x -> x + n). This is because succ is the unique order automorphism with no fixed point mapping each element to something strictly larger. But this fact relies on discreteness, not on any general DLO property.

---

## References

- Cantor's theorem: Every countable dense linear order without endpoints is order-isomorphic to Q
- Holder's theorem: A group acting freely and order-preservingly on a linear order is abelian
- Mathlib `Order.iso_of_countable_dense`: Cantor isomorphism in Lean 4
- Mathlib `addGroupIsAddTorsor`: Every AddGroup is a torsor over itself
- Mathlib `Rat.addCommGroup`, `Rat.linearOrder`: Algebraic structure on Q
- Report 12 (torsor-construction-full.md): Prior analysis (partially invalidated)
- TranslationGroup.lean: Current D = Aut+(T) definition (to be replaced)

## Context Extension Recommendations

- **Topic**: Torsor transfer along order isomorphisms
- **Gap**: No context file covers the pattern of transferring algebraic structure (AddTorsor, AddAction) along an OrderIso between linear orders
- **Recommendation**: Create `project/math/torsor-theory/torsor-transfer.md` covering this pattern

## Next Steps

1. Update the implementation plan (report 04) to reflect D = Q via Cantor transfer
2. Create CantorTransfer.lean assembling T's instances and constructing the transferred torsor
3. Revise the task relation and TaskFrame construction to use D = Q
4. Run `/plan 1006` to create a revised implementation plan incorporating these findings
