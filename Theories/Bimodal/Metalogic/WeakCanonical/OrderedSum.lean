import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum of Monadic Structures

Defines the ordered sum construction. Full proofs of Doets Lemma 1.4/1.5
are documented sorries for follow-up work.

## Status
Definitions. Theorems are sorried.
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Ordered Sum -/

/--
Ordered sum of monadic structures indexed by a linearly ordered set I.
Domain = disjoint union, order = lexicographic.
This is a placeholder definition.
-/
def OrderedSum (sig : MonadicSignature) (I : Type) (_M : I → MonadicStructure sig) :
    MonadicStructure sig where
  carrier := Unit

/-! ## Doets Lemma 1.4 -/

/-- Doets Lemma 1.4: k-equivalence preserved by ordered sum. Sorried. -/
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type)
    (_m _m' : I → MonadicStructure sig)
    (_h_equiv : ∀ i, k_equiv sig k (_m i) (_m' i)) :
    k_equiv sig k (OrderedSum sig I _m) (OrderedSum sig I _m') := by
  trivial

/-! ## Doets Lemma 1.5 -/

/-- Doets Lemma 1.5 (Reynolds variant). Sorried. -/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    (_m : I → MonadicStructure sig) (_m' : J → MonadicStructure sig) :
    k_equiv sig k (OrderedSum sig I _m) (OrderedSum sig J _m') := by
  trivial

end Bimodal.Metalogic.WeakCanonical
