# Research Report: Extension Lattice Analysis for Strict Temporal Semantics

**Task**: 991 - Temporal Algebraic Representation
**Date**: 2026-03-18
**Focus**: Structure the temporal logic hierarchy as Base -> +Seriality -> +Density OR +Discreteness

---

## Executive Summary

This report analyzes the correct lattice structure of frame classes for temporal logic with strict (irreflexive) semantics. The key findings are:

1. **The base logic Kt.Lin (strict)** is over arbitrary strict linear orders, which may have endpoints
2. **Seriality is the natural first extension** - it eliminates endpoints, giving unbounded frames
3. **Density and discreteness are incompatible second-level extensions** of seriality
4. **The extension lattice is a Y** with Kt.Lin at bottom, Kt.Lin.Ser in the middle, and Kt.Lin.Dn.Ser and Kt.Lin.Disc.Ser as incomparable tops (under the containment order of frame classes)

---

## 1. The Base Logic: Kt.Lin (Strict Semantics)

### 1.1 Frame Class

The base logic Kt.Lin characterizes **strict linear orders** (D, <) where:
- < is **irreflexive**: not (t < t)
- < is **transitive**: t < s and s < u implies t < u
- < is **trichotomous**: for all t, s: either t < s, or t = s, or s < t

**No seriality constraint**: D may have a maximum element (no future) or minimum element (no past).

### 1.2 Semantics

With strict semantics:
- `G(phi)` at t means: for all s > t, phi holds at s
- `H(phi)` at t means: for all s < t, phi holds at s

**Vacuous truth at endpoints**: If t is maximal, then G(phi) is vacuously true at t for any phi.

### 1.3 Base Axioms

The axioms of Kt.Lin (base tense logic over strict linear orders):

| Axiom | Name | Frame Correspondence |
|-------|------|---------------------|
| G(phi -> psi) -> (G(phi) -> G(psi)) | K-G | Functional normality |
| H(phi -> psi) -> (H(phi) -> H(psi)) | K-H | Functional normality |
| G(phi) -> G(G(phi)) | 4-G | Transitivity of < |
| H(phi) -> H(H(phi)) | 4-H | Transitivity of < |
| phi -> G(P(phi)) | TA1 | < and > are converse |
| phi -> H(F(phi)) | TA2 | < and > are converse |
| F(phi) & F(psi) -> F(phi & psi) v F(phi & F(psi)) v F(F(phi) & psi) | Lin-F | Forward linearity |
| P(phi) & P(psi) -> P(phi & psi) v P(phi & P(psi)) v P(P(phi) & psi) | Lin-P | Backward linearity |

**Note**: The T-axiom `G(phi) -> phi` is NOT in the base - it characterizes reflexivity, which contradicts strict semantics.

### 1.4 What Kt.Lin Does NOT Guarantee

- **No seriality**: G(phi) -> F(phi) is NOT valid (endpoints exist)
- **No density**: G(G(phi)) -> G(phi) is NOT valid (discrete gaps allowed)
- **No discreteness**: X operator not even defined in the language

---

## 2. Seriality as the First Extension

### 2.1 The Seriality Axioms

| Axiom | Name | Frame Correspondence |
|-------|------|---------------------|
| G(phi) -> F(phi) | Ser-F | No maximum element (NoMaxOrder) |
| H(phi) -> P(phi) | Ser-P | No minimum element (NoMinOrder) |

**Mathlib formalization**: These correspond to `NoMaxOrder` and `NoMinOrder` type classes:
```lean
class NoMaxOrder (alpha : Type) [LT alpha] : Prop where
  exists_gt : forall a, exists b, a < b

class NoMinOrder (alpha : Type) [LT alpha] : Prop where
  exists_lt : forall a, exists b, b < a
```

### 2.2 Why Seriality is the Natural First Extension

**Mathematical argument**: Seriality eliminates the degenerate case of vacuous truth at endpoints. Without seriality:
- At a maximum element t: G(phi) is trivially true for any phi
- This makes G behave like a "trivial modality" at endpoints
- The tense axioms TA1/TA2 still guarantee phi -> G(P(phi)), but P(phi) can be vacuously false

**Semantic motivation**: The intended interpretation of temporal logic is reasoning about "all future times" and "all past times." Endpoints are semantically anomalous - they represent "the end of time," which is not the typical use case.

**Standard practice**: The logic Kt (minimal tense logic) typically assumes unbounded time in the literature (Prior, Burgess, Goldblatt).

### 2.3 The Logic Kt.Lin.Ser

**Frame class**: Strict linear orders without endpoints (unbounded in both directions).
**Axioms**: Kt.Lin + Ser-F + Ser-P

**Examples**:
- (Z, <) - the integers
- (Q, <) - the rationals
- (R, <) - the reals
- Any interval (-inf, +inf) in a linear order

### 2.4 Seriality vs. Reflexivity

**Critical distinction**: Seriality (G(phi) -> F(phi)) is NOT the same as the T-axiom (G(phi) -> phi).

| Property | Axiom | Frame Condition |
|----------|-------|-----------------|
| Seriality | G(phi) -> F(phi) | NoMaxOrder |
| Reflexivity | G(phi) -> phi | Reflexive accessibility |

With strict semantics, reflexivity is impossible by definition. Seriality provides a weaker guarantee: if phi holds at all strictly future times, then there exists at least one strictly future time where phi holds.

---

## 3. Density as a Second-Level Extension

### 3.1 The Density Axiom

| Axiom | Name | Frame Correspondence |
|-------|------|---------------------|
| G(G(phi)) -> G(phi) | Dn | DenselyOrdered |

**Mathlib formalization**: `DenselyOrdered` type class:
```lean
class DenselyOrdered (alpha : Type) [LT alpha] : Prop where
  dense : forall a1 a2, a1 < a2 -> exists a, a1 < a & a < a2
```

### 3.2 Why Density Requires Strict Semantics

**With strict semantics**: G(G(phi)) -> G(phi) is a non-trivial axiom that characterizes density.

*Proof that density makes this valid*: Suppose G(G(phi)) at t. For any s > t, we need phi at s. By density, there exists u with t < u < s. Since G(G(phi)) at t, we have G(phi) at u. Since s > u, we have phi at s.

*Proof that non-density falsifies this*: In a discrete order like Z, take phi = "x = 2". At t = 0: G(G(phi)) holds (at all s > 1, we have s >= 2). But G(phi) fails at 0 because at s = 1, phi fails (1 != 2).

**With reflexive semantics**: G is idempotent (G(G(phi)) = G(phi)), so density cannot be characterized this way.

### 3.3 The Logic Kt.Lin.Dn.Ser

**Frame class**: Dense strict linear orders without endpoints.
**Axioms**: Kt.Lin.Ser + Dn

**Canonical model**: (Q, <) - the rationals with standard ordering.

**Completeness**: Kt.Lin.Dn.Ser is complete with respect to (Q, <).

---

## 4. Discreteness as an Alternative Second-Level Extension

### 4.1 Why Discreteness Requires New Operators

**Goldblatt's theorem**: Discreteness is not definable in {G, H} alone. No formula in basic tense logic can distinguish discrete from dense orders.

*Proof sketch*: There exists a bounded morphism from (Q, <) to (Z, <) that preserves all {G, H}-formulas.

**Solution**: Add the Next (X) and Previous (Y) operators.

### 4.2 The Next/Previous Operators

| Operator | Semantics at t |
|----------|---------------|
| X(phi) | phi at the immediate successor of t |
| Y(phi) | phi at the immediate predecessor of t |

**Mathlib formalization**: `SuccOrder` and `PredOrder` type classes:
```lean
class SuccOrder (alpha : Type) [Preorder alpha] where
  succ : alpha -> alpha
  le_succ : forall a, a <= succ a
  max_of_succ_le : forall a, succ a <= a -> IsMax a
  succ_le_of_lt : forall a b, a < b -> succ a <= b
  lt_succ_of_not_isMax : forall a, not (IsMax a) -> a < succ a

class PredOrder (alpha : Type) [Preorder alpha] where
  pred : alpha -> alpha
  -- dual axioms
```

### 4.3 Discreteness Axioms

| Axiom | Name | Frame Correspondence |
|-------|------|---------------------|
| X(top) = top | X-T | Successor exists |
| neg X neg phi = X phi | X-func | Successor is unique |
| Y(top) = top | Y-T | Predecessor exists |
| neg Y neg phi = Y phi | Y-func | Predecessor is unique |
| phi -> X(Y(phi)) | XY | X and Y are inverse |
| phi -> Y(X(phi)) | YX | Y and X are inverse |
| G(phi) <-> X(phi & G(phi)) | Disc-G | Discrete induction (future) |
| H(phi) <-> Y(phi & H(phi)) | Disc-H | Discrete induction (past) |

### 4.4 The Logic Kt.Lin.Disc.Ser

**Frame class**: Discrete strict linear orders without endpoints (isomorphic to Z).
**Axioms**: Kt.Lin.Ser + X axioms + discrete induction

**Note**: The discrete induction axiom is NOT Sahlqvist, requiring special completeness arguments.

---

## 5. Incompatibility of Density and Discreteness

### 5.1 Logical Incompatibility

**Theorem**: Density and discreteness are inconsistent for orders with at least two points.

*Proof*: Suppose (D, <) is both dense and discrete with |D| >= 2. Take any t in D with a successor succ(t). By discreteness, there is no element between t and succ(t). But by density, there exists u with t < u < succ(t). Contradiction.

### 5.2 Frame Class Containment

Let C denote frame classes:
- C_base = strict linear orders (possibly with endpoints)
- C_ser = strict linear orders without endpoints
- C_dn = dense strict linear orders
- C_disc = discrete strict linear orders

**Containment relations**:
- C_ser ⊂ C_base (proper subset - seriality eliminates endpoints)
- C_dn ⊂ C_ser (proper subset - density is additional constraint)
- C_disc ⊂ C_ser (proper subset - discreteness is additional constraint)
- C_dn ∩ C_disc = empty (incompatible for |D| >= 2)

### 5.3 The Extension Lattice (by Frame Class Containment)

```
             C_base (largest)
                |
            C_ser (serial, unbounded)
           /         \
     C_dn              C_disc
   (dense)           (discrete)
        \             /
         \           /
           (empty)
```

**Note**: Under frame class containment (⊇ ordering), larger classes are lower. But the logic extension lattice (by axiom strength) is the **dual**:

```
Logic Extension Lattice (by axiom strength, ⊇ on validities):

           (inconsistent)
           /            \
   Kt.Lin.Dn.Ser    Kt.Lin.Disc.Ser
           \            /
            Kt.Lin.Ser
                |
            Kt.Lin (base)
```

---

## 6. Complete Enumeration of Natural Subsystems

### 6.1 The Seven Natural Frame Classes

| # | Frame Class | Defining Properties | Example |
|---|-------------|---------------------|---------|
| 1 | C_base | Strict linear | Finite chain [0, n] |
| 2 | C_ser | + No endpoints | Z, Q, R |
| 3 | C_dn | + Density | Q, R |
| 4 | C_dn_ser | Dense + No endpoints | (Q, <), (-inf, inf) in R |
| 5 | C_disc | Discrete | Z, N with end |
| 6 | C_disc_ser | Discrete + No endpoints | (Z, <) |
| 7 | C_wf | Discrete + Well-founded | (N, <) |

**Note**: C_dn automatically satisfies seriality in both directions for infinite orders, but not for finite dense orders (which don't exist with |D| >= 2). So C_dn and C_dn_ser coincide for practical purposes.

### 6.2 The Lattice of Frame Classes (Under ⊇)

```
                    C_base
                      |
                   C_ser
                  /     \
             C_dn        C_disc
                          |
                      C_disc_ser
                          |
                        C_wf
```

**Explanation**:
- C_base ⊇ C_ser: Unbounded orders are special cases of all orders
- C_ser ⊇ C_dn: Dense orders are unbounded (for |D| >= 2)
- C_ser ⊇ C_disc: Discrete orders can be unbounded (Z) or bounded (N)
- C_disc ⊇ C_disc_ser: Unbounded discrete orders are special
- C_disc_ser ⊇ C_wf: Well-founded discrete unbounded = N-like (one endpoint)

Wait, this needs correction. C_wf (well-founded) has a minimum element (like N), so it's NOT a subclass of C_disc_ser (which requires no endpoints). Let me revise:

### 6.3 Corrected Lattice

```
                    C_base
                   /      \
              C_ser        C_disc_bounded
             /    \              |
        C_dn      C_disc_ser    C_wf
```

Where:
- C_disc_bounded = discrete orders, possibly with endpoints
- C_disc_ser = discrete orders, no endpoints (Z-like)
- C_wf = well-founded discrete orders (N-like, has minimum)

**The corrected picture**: Discreteness can be combined with:
- Two endpoints (finite chains)
- One endpoint (N-like or reverse-N-like)
- No endpoints (Z-like)

---

## 7. Representation Theorems for Each Subsystem

### 7.1 Overview Table

| Logic | Frame Class | Canonical? | Representation Theorem |
|-------|-------------|------------|------------------------|
| Kt.Lin | Strict linear | Yes (Sahlqvist) | Every Kt.Lin algebra embeds in complex algebra of strict linear order |
| Kt.Lin.Ser | Unbounded strict linear | Yes | Same, plus NoMaxOrder/NoMinOrder |
| Kt.Lin.Dn.Ser | Dense unbounded | Yes | Complete w.r.t. (Q, <) |
| Kt.Lin.Disc.Ser | Z-like | Special | Non-canonical (induction axiom), but completeness holds |
| Kt.Lin.Disc.WF | N-like | No | Requires bulldozing; still has representation |

### 7.2 The Sahlqvist Property

**Sahlqvist axioms** automatically yield:
1. Canonicity (valid in canonical frame)
2. Completeness (logic = theory of frame class)
3. Representation theorem (algebraic version)

**Sahlqvist axioms in our hierarchy**:
- All base Kt.Lin axioms: Yes
- Seriality axioms (G(phi) -> F(phi)): Yes (antecedent is boxed atom)
- Density axiom (G(G(phi)) -> G(phi)): Yes (nested boxes)
- Discrete induction (G(phi) <-> X(phi & G(phi))): **NO** (biconditional with conjunction under X)

### 7.3 The Discrete Case: Non-Canonical but Complete

The discrete induction axiom is not Sahlqvist, so:
- The canonical frame may not satisfy discreteness
- Standard canonical model argument doesn't directly apply

**Alternative approaches**:
1. **Segerberg's method**: Direct construction of discrete canonical model
2. **Filtration + discretization**: Filter canonical model, then discretize
3. **Algebraic approach**: Use representation via Stone duality for discrete BAOs

**Result**: Kt.Lin.Disc.Ser is still complete w.r.t. (Z, <), but via non-standard proof.

### 7.4 Well-Founded Case: Bulldozing

For N-like frames with Lob's axiom G(G(phi) -> phi) -> G(phi):
- Not canonical (Lob axiom falsified in canonical frame)
- **Bulldozing technique** (Blackburn-de Rijke-Venema): Transform canonical frame to satisfy well-foundedness while preserving theory
- Result: Representation theorem still holds

---

## 8. Interaction with Modal Operators (Box, Stability)

### 8.1 The Full STSAS Picture

Adding the modal operators Box and Stab to the temporal base:

| Extension Dimension | Operators Affected | Independent? |
|---------------------|-------------------|--------------|
| Seriality | G, H | Yes |
| Density | G, H | Yes |
| Discreteness | G, H, X, Y | Yes |
| Shift-closure | Box, G, H | Yes |
| Determinism | Stab, G, H | Yes |

**Key insight**: Temporal extensions (seriality, density, discreteness) operate on (D, <) independently of modal extensions (shift-closure, determinism) which operate on Omega.

### 8.2 The Product Structure

The full extension lattice is approximately:

(Temporal extensions) × (Modal extensions)

Where:
- Temporal: Base < Ser < {Dn, Disc}
- Modal: Base < ShiftClosed < {FwdDet, BwdDet, FullDet}

This gives 3 × 4 = 12 core combinations, each with a representation theorem if the components have representation theorems.

---

## 9. Summary and Recommendations

### 9.1 The Canonical Hierarchy

```
1. Kt.Lin (base)
   - Strict linear orders, possibly bounded
   - All Sahlqvist, automatic representation

2. Kt.Lin.Ser (+seriality)
   - Unbounded strict linear orders
   - Sahlqvist extension, automatic

3a. Kt.Lin.Dn.Ser (+density)
    - Dense unbounded (Q-like, R-like)
    - Sahlqvist, complete w.r.t. (Q, <)

3b. Kt.Lin.Disc.Ser (+discreteness)
    - Discrete unbounded (Z-like)
    - Non-Sahlqvist but complete w.r.t. (Z, <)

4. Kt.Lin.Disc.WF (well-founded discrete)
   - N-like
   - Non-canonical, requires bulldozing
```

### 9.2 Answers to Research Questions

1. **Extension Lattice Structure**: Yes, the structure is Base -> +Seriality -> (+Density OR +Discreteness). Seriality is the natural first extension.

2. **Seriality as First Extension**: Confirmed. The base logic without seriality allows endpoints where temporal operators are vacuously satisfied.

3. **Density vs Discreteness**: Truly incompatible for orders with 2+ elements. They cannot coexist.

4. **Natural Subsystems**: Seven natural subsystems identified, with clear containment relationships.

5. **Representation Theorems**: All subsystems have representation theorems. Sahlqvist subsystems (base, seriality, density) get automatic representation. Non-Sahlqvist subsystems (discreteness, well-foundedness) require special arguments but still have representation.

### 9.3 Implications for Task 991

The irreflexivity proof issue identified in 04_synthesis.md can be addressed by:

1. **Adding seriality to base**: The current TM logic implicitly assumes seriality (via the temp_a axiom structure). Making this explicit would allow cleaner irreflexivity proof.

2. **Using linearity + temp_a**: The alternative proof strategy identified by Teammate B exploits the interaction of linearity and temp_a to derive irreflexivity without T-axiom.

3. **Frame class clarity**: The base TM logic corresponds to Kt.Lin.Ser (unbounded linear time), not bare Kt.Lin (which allows endpoints).

---

## References

1. Prior, A.N. (1967). *Past, Present and Future*. Oxford University Press.
2. Burgess, J.P. (1979). "Logic and Time." *Journal of Symbolic Logic* 44(4).
3. Burgess, J.P. (1982). "Axioms for Tense Logic I & II." *Notre Dame Journal of Formal Logic* 23(4) and 24(4).
4. Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
5. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects*. Oxford University Press.
6. Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
7. Segerberg, K. (1970). "Modal logics with linear alternative relations." *Theoria* 36(3).
8. Mathlib4 documentation: Order.SuccPred.Basic, Order.Max, Order.Basic (DenselyOrdered).

---

## Appendix: Mathlib Type Classes for Frame Properties

```lean
-- Seriality (no endpoints)
class NoMaxOrder (alpha : Type) [LT alpha] : Prop
class NoMinOrder (alpha : Type) [LT alpha] : Prop

-- Density
class DenselyOrdered (alpha : Type) [LT alpha] : Prop

-- Discreteness (successor/predecessor structure)
class SuccOrder (alpha : Type) [Preorder alpha]
class PredOrder (alpha : Type) [Preorder alpha]

-- Well-foundedness
def WellFounded (r : alpha -> alpha -> Prop) : Prop

-- Linear order (trichotomy)
class LinearOrder (alpha : Type) extends PartialOrder alpha
```

These type classes can be combined to specify frame conditions:
- `[LinearOrder D] [NoMaxOrder D] [NoMinOrder D]` = unbounded linear
- `[LinearOrder D] [DenselyOrdered D]` = dense linear
- `[LinearOrder D] [SuccOrder D] [PredOrder D]` = discrete linear
