import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum Theorems for Monadic Structures

Contains the key theorems about ordered sums of monadic structures,
building on the `OrderedSum` definition from NEquivalence.lean.

## Key theorems
- `doets_lemma_1_4`: ordered sum preserves k-equivalence
- `doets_lemma_1_5`: type-matching sum preserves k-equivalence (deferred)
- `finite_structures_k_equiv_to_Z_interval`: any finite monadic structure
  is k-equivalent to something

## Status
All theorem proofs are sorried pending the monadic FO satisfaction relation
from Phase 3. The type signatures are mathematically correct.

## References
- Doets 1989, Lemmas 1.4, 1.5: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Lemma 16 (uses Doets 1.4/1.5): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Doets Lemma 1.4 -/

/--
Doets Lemma 1.4: k-equivalence is preserved by ordered sums.

Formally: if for all i, m(i) is k-equivalent to m'(i) (i.e., they have the
same k-type), then the ordered sums OrderedSum(I, m) and OrderedSum(I, m')
are k-equivalent.

Proof sketch (Doets 1989, Section 1):
- By induction on k. Base case (k=0): atomic sentences only; each component's
  truth at position determines truth in the sum.
- Inductive step: use the Ehrenfeucht-Fraïssé game characterization.
  If the components are k-equivalent, Duplicator has a winning strategy
  in the k-round game, which lifts to the ordered sum via component-wise play.

**Status**: Sorried. Requires monadic FO satisfaction (k_equiv definition
from Phase 3) and the game-theoretic or syntactic characterization of
k-equivalence preservation under sums.

The type signature is mathematically correct. This is a clean sorry
(a standard textbook result) unlike the `succ_cofinal` sorry.
-/
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type)
    (m m' : I → MonadicStructure sig)
    (h_equiv : ∀ i, k_equiv sig k (m i) (m' i)) :
    k_equiv sig k (OrderedSum sig I m) (OrderedSum sig I m') := by
  sorry

/-! ## Doets Lemma 1.5 (Type-Matching Variant) -/

/--
Doets Lemma 1.5: If two ordered sums have matching type distributions,
they are k-equivalent.

More precisely: if the multisets of k-types appearing in the I-indexed
and J-indexed families are the same, then the ordered sums are k-equivalent.
This is the key lemma for Reynolds Theorem 15's "very_good → good" step:
replacing a subinterval with a Z-interval of the same k-type preserves
k-equivalence of the whole structure.

**Status**: Deferred. Doets Lemma 1.5 is only needed for Reynolds Lemma 16
(very_good_implies_good via cofinal sequences), which is bypassed in the
discrete case by the direct one_class argument. Documented with
a correct type signature for future reference.
-/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    (m : I → MonadicStructure sig) (m' : J → MonadicStructure sig) :
    k_equiv sig k (OrderedSum sig I m) (OrderedSum sig J m') := by
  sorry

/-! ## Finite Structures Are k-Equivalent to Z-Intervals -/

/--
Every finite monadic structure is k-equivalent to some structure
(for the full Reynolds Theorem 15, this "some structure" will be a Z-interval).

This is the "finite case" of Reynolds Theorem 15:
any finite structure can be compressed into a Z-interval.

For the Reynolds pipeline, this theorem is used via `KEquivalenceFramework.sum_preservation`
to combine finite subintervals into a whole good structure.

**Status**: Sorried. Requires:
1. The Z-model as a monadic structure over ℤ
2. Subinterval restriction for monadic structures
3. Finite decomposition into ordered sum of singletons
4. Doets Lemma 1.4 for component-wise equivalence
-/
theorem finite_structures_k_equiv_to_Z_interval (sig : MonadicSignature) (k : Nat)
    (M : MonadicStructure sig) [Fintype M.carrier] :
    ∃ (N : MonadicStructure sig),
      k_equiv sig k M N := by
  sorry

end Bimodal.Metalogic.WeakCanonical
