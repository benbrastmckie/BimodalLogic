import Logos.Foundation.Frame
import Mathlib.Data.Set.Lattice

/-!
# Bilateral Propositions for Exact Truthmaker Semantics

This module defines bilateral propositions, the fundamental semantic objects
in exact truthmaker semantics. Each proposition is a pair of sets: verifiers
(states that make the proposition true) and falsifiers (states that make it false).

## Paper Specification Reference

**Bilateral Propositions (RECURSIVE_SEMANTICS.md)**:
A bilateral proposition consists of:
- A set of verifiers (states that make it true)
- A set of falsifiers (states that make it false)

These are independent: a state can verify, falsify, both, or neither.

## Main Definitions

- `BilateralProp`: Structure with verifier and falsifier sets
- `neg`: Negation (swap verifiers and falsifiers)
- `product`: Conjunction-like operation (⊗)
- `sum`: Disjunction-like operation (⊕)
- `top`: Verum proposition
- `bot`: Falsum proposition

## Implementation Notes

Operations on bilateral propositions follow the bilattice structure:
- Negation exchanges the ⊑ and ≤ orderings
- Product is the meet with respect to ⊑ (essence ordering)
- Sum is the join with respect to ≤ (ground ordering)
-/

namespace Logos.Foundation

/--
Bilateral proposition in exact truthmaker semantics.

A bilateral proposition associates each state with whether it verifies
or falsifies the proposition. Unlike classical propositions where every
state either makes it true or false (but not both), bilateral propositions
allow for states that:
- Verify but don't falsify (positive truthmakers)
- Falsify but don't verify (negative truthmakers)
- Both verify and falsify (overdetermined)
- Neither verify nor falsify (underdetermined)

**Paper Alignment**: Matches RECURSIVE_SEMANTICS.md bilateral propositions.
-/
structure BilateralProp (S : Type*) where
  /-- States that verify (make true) the proposition -/
  verifiers : Set S
  /-- States that falsify (make false) the proposition -/
  falsifiers : Set S

namespace BilateralProp

variable {S : Type*} [CompleteLattice S]

/--
Negation of a bilateral proposition: swap verifiers and falsifiers.

The semantic dual of a proposition. States that verified now falsify,
and states that falsified now verify.

**Semantic clause**: M, σ, s ⊩⁺ ¬A iff M, σ, s ⊩⁻ A
-/
def neg (p : BilateralProp S) : BilateralProp S where
  verifiers := p.falsifiers
  falsifiers := p.verifiers

/--
Negation is involutive: ¬¬p = p
-/
@[simp]
theorem neg_neg (p : BilateralProp S) : p.neg.neg = p := rfl

/--
Propositional product (conjunction ⊗): fusion of verifiers, union of falsifiers.

For conjunction, a state verifies A ∧ B if it is the fusion of a verifier
for A and a verifier for B. A state falsifies A ∧ B if it falsifies A,
falsifies B, or is the fusion of falsifiers for both.

**Semantic clause**: M, σ, s ⊩⁺ A ∧ B iff s = t ⊔ u for some t, u where
                     M, σ, t ⊩⁺ A and M, σ, u ⊩⁺ B

Note: This definition uses set-theoretic union for falsifiers and
"pairwise fusion" for verifiers.
-/
def product (p q : BilateralProp S) : BilateralProp S where
  verifiers := { s | ∃ t ∈ p.verifiers, ∃ u ∈ q.verifiers, s = t ⊔ u }
  falsifiers := p.falsifiers ∪ q.falsifiers ∪
                { s | ∃ t ∈ p.falsifiers, ∃ u ∈ q.falsifiers, s = t ⊔ u }

/--
Propositional sum (disjunction ⊕): union of verifiers, fusion of falsifiers.

For disjunction, a state verifies A ∨ B if it verifies A, verifies B,
or is the fusion of verifiers for both. A state falsifies A ∨ B if it
is the fusion of a falsifier for A and a falsifier for B.

**Semantic clause**: M, σ, s ⊩⁺ A ∨ B iff M, σ, s ⊩⁺ A, or M, σ, s ⊩⁺ B,
                     or s = t ⊔ u for some t, u where M, σ, t ⊩⁺ A and M, σ, u ⊩⁺ B

Note: This is dual to product.
-/
def sum (p q : BilateralProp S) : BilateralProp S where
  verifiers := p.verifiers ∪ q.verifiers ∪
               { s | ∃ t ∈ p.verifiers, ∃ u ∈ q.verifiers, s = t ⊔ u }
  falsifiers := { s | ∃ t ∈ p.falsifiers, ∃ u ∈ q.falsifiers, s = t ⊔ u }

/--
Verum (⊤): every state verifies, only full state falsifies.

**Semantic clause**: M, σ, s ⊩⁺ ⊤ for all s ∈ S
                     M, σ, s ⊩⁻ ⊤ iff s = ■ (full state)
-/
def top : BilateralProp S where
  verifiers := Set.univ
  falsifiers := {⊤}

/--
Falsum (⊥): no state verifies, only null state falsifies.

**Semantic clause**: M, σ, s ⊮⁺ ⊥ for all s
                     M, σ, s ⊩⁻ ⊥ iff s = □ (null state)
-/
def bot : BilateralProp S where
  verifiers := ∅
  falsifiers := {⊥}

/--
Propositional identity: propositions are identical iff they have
the same verifiers and the same falsifiers.
-/
def equiv (p q : BilateralProp S) : Prop :=
  p.verifiers = q.verifiers ∧ p.falsifiers = q.falsifiers

/--
Equivalence is reflexive.
-/
theorem equiv_refl (p : BilateralProp S) : p.equiv p :=
  ⟨rfl, rfl⟩

/--
Equivalence is symmetric.
-/
theorem equiv_symm {p q : BilateralProp S} : p.equiv q → q.equiv p := by
  intro ⟨hv, hf⟩
  exact ⟨hv.symm, hf.symm⟩

/--
Equivalence is transitive.
-/
theorem equiv_trans {p q r : BilateralProp S} :
    p.equiv q → q.equiv r → p.equiv r := by
  intro ⟨hv1, hf1⟩ ⟨hv2, hf2⟩
  exact ⟨hv1.trans hv2, hf1.trans hf2⟩

section DeMorgan

/--
De Morgan for negation and product: ¬(p ⊗ q) ≈ ¬p ⊕ ¬q
(equality of verifiers and falsifiers)
-/
theorem neg_product_eq_sum_neg (p q : BilateralProp S) :
    (p.product q).neg.equiv (p.neg.sum q.neg) := by
  simp only [neg, product, sum]
  constructor
  · -- verifiers equality
    rfl
  · -- falsifiers equality
    rfl

/--
De Morgan for negation and sum: ¬(p ⊕ q) ≈ ¬p ⊗ ¬q
-/
theorem neg_sum_eq_product_neg (p q : BilateralProp S) :
    (p.sum q).neg.equiv (p.neg.product q.neg) := by
  simp only [neg, product, sum]
  constructor <;> rfl

end DeMorgan

section Ordering

/--
Essence ordering (⊑): p ⊑ q iff p's verifiers are contained in q's verifiers.

This captures "A is essential to B" - every way of verifying A is also
a way of verifying B.
-/
def essence (p q : BilateralProp S) : Prop :=
  p.verifiers ⊆ q.verifiers

/--
Ground ordering (≤): p ≤ q iff q's falsifiers are contained in p's falsifiers.

This captures "A grounds B" - every way of falsifying B is also a way
of falsifying A.
-/
def ground (p q : BilateralProp S) : Prop :=
  q.falsifiers ⊆ p.falsifiers

/--
Negation exchanges essence and ground orderings:
p ⊑ q iff ¬q ≤ ¬p
-/
theorem essence_iff_neg_ground {p q : BilateralProp S} :
    p.essence q ↔ q.neg.ground p.neg := by
  simp only [essence, ground, neg]

end Ordering

end BilateralProp

end Logos.Foundation
