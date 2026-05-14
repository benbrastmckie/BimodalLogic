import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum of Monadic Structures

Defines the ordered sum construction. Full proofs of Doets Lemma 1.4/1.5
are documented sorries (replaced from vacuous `trivial` bodies) for follow-up work.

## Status
Definitions. Theorems are sorried -- Phase 4.
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Ordered Sum -/

/--
Ordered sum of monadic structures indexed by a linearly ordered set I.
Domain = disjoint union, order = lexicographic.

Full definition requires disjoint union (Sigma type) and lexicographic ordering;
stubbed with Unit carrier for now. Phase 4 will provide the proper definition.
-/
def OrderedSum (sig : MonadicSignature) (I : Type) (_M : I → MonadicStructure sig) :
    MonadicStructure sig where
  carrier := Unit

/-! ## Doets Lemma 1.4 -/

/--
Doets Lemma 1.4: k-equivalence preserved by ordered sum.

If for all i, m(i) is k-equivalent to m'(i), then the ordered sums
OrderedSum(I, m) and OrderedSum(I, m') are k-equivalent.

Proof by induction on k (cf. Doets 1989, Section 1). Requires full
k_equiv definition from Phase 3. Phase 4 will provide the proof.
-/
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type)
    (_m _m' : I → MonadicStructure sig)
    (_h_equiv : ∀ i, k_equiv sig k (_m i) (_m' i)) :
    k_equiv sig k (OrderedSum sig I _m) (OrderedSum sig I _m') := by
  sorry

/-! ## Doets Lemma 1.5 (Reynolds Variant) -/

/--
Doets Lemma 1.5 (Reynolds variant for type-matching sums): If the distribution
of k-types in I and J matches (same number of each type, same order-theoretic
adjacency), then the sums are k-equivalent. This is the key lemma for the
very_good_implies_good step in Reynolds Theorem 15.

Phase 4 will provide the proof.
-/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    (_m : I → MonadicStructure sig) (_m' : J → MonadicStructure sig) :
    k_equiv sig k (OrderedSum sig I _m) (OrderedSum sig J _m') := by
  sorry

end Bimodal.Metalogic.WeakCanonical
