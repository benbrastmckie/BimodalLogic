# Monoidal Categories

> **Scope**: Monoidal categories serving as the enriching category for V-enriched categories. Covers tensor products, unit objects, coherence, and symmetry.
> **Current as of**: 2026-02-24

## Purpose

This context file provides monoidal category theory as the foundational structure for enriched category theory. A V-enriched category requires V to be monoidal; this file details that structure.

### When to Load

Load this context when:
- Understanding the enrichment base for V-categories
- Working with tensor products and coherence conditions
- Connecting monoidal posets to categorical enrichment
- Understanding symmetric/braided monoidal structures

---

## Quick Reference

### Monoidal Category Data

| Component | Notation | Role |
|-----------|----------|------|
| Tensor product | $\otimes : \mathcal{C} \times \mathcal{C} \to \mathcal{C}$ | Bifunctor combining objects |
| Unit object | $I$ | Identity for tensor |
| Associator | $\alpha : (A \otimes B) \otimes C \to A \otimes (B \otimes C)$ | Natural isomorphism |
| Left unitor | $\lambda : I \otimes A \to A$ | Natural isomorphism |
| Right unitor | $\rho : A \otimes I \to A$ | Natural isomorphism |

### Standard Examples

| Category | Tensor $\otimes$ | Unit $I$ | Symmetric? |
|----------|-----------------|----------|------------|
| **Set** | Cartesian product $\times$ | Singleton $\{*\}$ | Yes |
| **Vect**$_k$ | Tensor product $\otimes_k$ | Base field $k$ | Yes |
| **Ab** | Tensor product $\otimes_{\mathbb{Z}}$ | $\mathbb{Z}$ | Yes |
| **Cat** | Product $\times$ | Terminal category **1** | Yes |
| **$([0,\infty], \geq)$** | Addition $+$ | $0$ | Yes |
| **End(C)** | Composition | Identity functor | No (general) |

---

## Definition: Monoidal Category

A **monoidal category** $(\mathcal{C}, \otimes, I, \alpha, \lambda, \rho)$ consists of:

1. **Category** $\mathcal{C}$
2. **Tensor product**: A bifunctor $\otimes : \mathcal{C} \times \mathcal{C} \to \mathcal{C}$
3. **Unit object**: An object $I \in \mathcal{C}$
4. **Associator**: A natural isomorphism
   $$\alpha_{A,B,C} : (A \otimes B) \otimes C \xrightarrow{\sim} A \otimes (B \otimes C)$$
5. **Left unitor**: A natural isomorphism
   $$\lambda_A : I \otimes A \xrightarrow{\sim} A$$
6. **Right unitor**: A natural isomorphism
   $$\rho_A : A \otimes I \xrightarrow{\sim} A$$

### Coherence Conditions

**Pentagon axiom**: For all objects $A, B, C, D$, the following diagram commutes:

```
        ((A ot B) ot C) ot D
              /         \
      alpha   /           \   alpha ot id
            v               v
 (A ot (B ot C)) ot D    (A ot B) ot (C ot D)
            |                     |
    alpha   |                     | alpha
            v                     v
A ot ((B ot C) ot D)  ---->  A ot (B ot (C ot D))
               id ot alpha
```

**Triangle axiom**: For all objects $A, B$, the following diagram commutes:

```
    (A ot I) ot B  ---alpha--->  A ot (I ot B)
            \                      /
       rho ot id                id ot lambda
              \                  /
               v                v
                    A ot B
```

### Mac Lane's Coherence Theorem

**Theorem**: In any monoidal category, all diagrams built from the associator and unitors that "should commute" do commute. More precisely, any two parallel compositions of structural isomorphisms are equal.

**Practical import**: You can parenthesize and insert/remove units freely, as long as you track the natural isomorphisms.

---

## Strict Monoidal Categories

A monoidal category is **strict** if:
- $\alpha$, $\lambda$, $\rho$ are all identities
- $(A \otimes B) \otimes C = A \otimes (B \otimes C)$ (equality, not isomorphism)
- $I \otimes A = A = A \otimes I$

**Strictification theorem**: Every monoidal category is monoidally equivalent to a strict one.

---

## Symmetric and Braided Monoidal Categories

### Braided Monoidal Category

A **braiding** on a monoidal category is a natural isomorphism:
$$\sigma_{A,B} : A \otimes B \xrightarrow{\sim} B \otimes A$$

satisfying **hexagon axioms** that ensure coherence with the associator.

**Hexagon axioms**:

```
  A ot (B ot C) --sigma--> (B ot C) ot A --alpha--> B ot (C ot A)
        ^                                               |
  alpha |                                               | id ot sigma
        |                                               v
 (A ot B) ot C                                    B ot (A ot C)
        |                                               ^
 sigma ot id                                       alpha|
        v                                               |
  (B ot A) ot C --alpha--> B ot (A ot C) --------> B ot (A ot C)
```

(And a similar diagram with inverses.)

### Symmetric Monoidal Category

A braided monoidal category is **symmetric** if:
$$\sigma_{B,A} \circ \sigma_{A,B} = \text{id}_{A \otimes B}$$

That is, the braiding is self-inverse.

**Examples**:
- **Set**, **Vect**, **Ab** with standard tensor products are symmetric
- The category of graded vector spaces with Koszul signs is symmetric
- Braid groups give examples of non-symmetric braidings

---

## Closed Monoidal Categories

A monoidal category is **(left) closed** if for each object $B$, the functor $- \otimes B : \mathcal{C} \to \mathcal{C}$ has a right adjoint $[B, -]$:
$$\text{Hom}(A \otimes B, C) \cong \text{Hom}(A, [B, C])$$

The object $[B, C]$ is called the **internal hom** from $B$ to $C$.

### Examples

| Category | Internal Hom $[B, C]$ | Adjunction |
|----------|---------------------|------------|
| **Set** | Function set $C^B$ | Currying |
| **Vect**$_k$ | Linear maps $\text{Hom}_k(B, C)$ | Tensor-hom |
| **Cat** | Functor category $[B, C]$ | Product-functor |
| **$([0,\infty], \geq, +, 0)$** | Truncated subtraction | $a + b \leq c \Leftrightarrow a \leq c - b$ |

### Cartesian Closed Categories

A category is **Cartesian closed** if:
- It has finite products (including terminal object)
- The product is the monoidal structure
- It is closed (has exponential objects $B^A$)

**Examples**: **Set**, toposes, typed lambda calculi.

---

## Connection to Enriched Categories

For a monoidal category $(\mathcal{V}, \otimes, I)$, a **V-enriched category** uses:
- $\otimes$ for composition of hom-objects
- $I$ for identity morphisms
- Associator and unitors for category axioms

See `enriched-categories.md` for the full definition.

### Monoidal Poset Case

When $\mathcal{V}$ is a monoidal poset $(Q, \leq, \otimes, k)$:
- Hom-objects are elements of $Q$
- Composition is monotone multiplication
- Unit axioms use $k$

See `../order-theory/monoidal-posets.md` for details.

---

## Mathlib Support

### Key Imports

```lean
import Mathlib.CategoryTheory.Monoidal.Category    -- Monoidal category definition
import Mathlib.CategoryTheory.Monoidal.Braided     -- Braided/symmetric structure
import Mathlib.CategoryTheory.Closed.Monoidal      -- Closed monoidal categories
import Mathlib.CategoryTheory.Monoidal.Coherence   -- Coherence results
```

### Core Types

| Mathlib Type | Mathematical Concept |
|--------------|---------------------|
| `MonoidalCategory C` | Monoidal category typeclass |
| `BraidedCategory C` | Braided monoidal category |
| `SymmetricCategory C` | Symmetric monoidal category |
| `MonoidalClosed C` | Closed monoidal category |
| `tensorObj X Y` | $X \otimes Y$ |
| `tensorUnit` | Unit object $I$ |
| `associator` | Associator natural isomorphism |
| `leftUnitor`, `rightUnitor` | Unitors |
| `braiding` | Braiding natural isomorphism |

### Example Code

```lean
import Mathlib.CategoryTheory.Monoidal.Category

-- Access monoidal structure
variable {C : Type*} [Category C] [MonoidalCategory C]
variable (X Y Z : C)

-- Tensor product
#check (X ⊗ Y : C)

-- Unit object
#check (𝟙_ C : C)

-- Associator
#check (α_ X Y Z : (X ⊗ Y) ⊗ Z ≅ X ⊗ (Y ⊗ Z))

-- Left unitor
#check (λ_ X : 𝟙_ C ⊗ X ≅ X)

-- Right unitor
#check (ρ_ X : X ⊗ 𝟙_ C ≅ X)
```

---

## See Also

- **basics.md** - Category fundamentals (categories, functors, natural transformations)
- **enriched-categories.md** - V-enriched categories using monoidal structure
- **../order-theory/monoidal-posets.md** - Special case: monoidal posets for Q-enrichment
- **lawvere-metric-spaces.md** - Cost quantale as monoidal category

---

## References

1. **Mac Lane, S. (1998)** - *Categories for the Working Mathematician*. Ch. VII (Monoidal Categories). Springer.
2. **Kelly, G.M. (1982)** - *Basic Concepts of Enriched Category Theory*. LMS Lecture Notes 64.
3. **Joyal, A. and Street, R. (1993)** - "Braided Tensor Categories". *Advances in Mathematics* 102.
4. **nLab**: [monoidal category](https://ncatlab.org/nlab/show/monoidal+category), [symmetric monoidal category](https://ncatlab.org/nlab/show/symmetric+monoidal+category), [closed monoidal category](https://ncatlab.org/nlab/show/closed+monoidal+category)
5. **Mathlib documentation**: `Mathlib.CategoryTheory.Monoidal`
