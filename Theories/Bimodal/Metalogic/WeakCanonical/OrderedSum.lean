import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum of Monadic Structures

Defines the ordered sum construction for monadic structures over a linearly
ordered index set (Doets 1989 Section 1). The ordered sum is a fundamental
construction in monadic first-order model theory: concatenating structures
in order preserves k-equivalence when the component structures are k-equivalent.

## Key definitions
- `OrderedSum sig I M`: sum of structures M_i over ordered index set I
- `doets_lemma_1_4`: ordered sum preserves k-equivalence
- `doets_lemma_1_5`: type-matching sum preserves k-equivalence
- `finite_structures_k_equiv_to_Z_interval`: any finite discrete structure
  is k-equivalent to a Z-interval

## Status
All theorem proofs are sorried pending the monadic FO satisfaction relation
from Phase 3. The type definitions are non-vacuous.

## References
- Doets 1989, Lemmas 1.4, 1.5: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Lemma 16 (uses Doets 1.4/1.5): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Ordered Sum -/

/--
Ordered sum of monadic structures indexed by a linearly ordered set I.
The carrier is the disjoint union `Sigma i, (M i).carrier`.

The predicate interpretations lift component-wise: a predicate holds at
`⟨i, x⟩` iff it holds at `x` in `M i`.

Note: The lexicographic order (by i then by the order on (M i).carrier)
is needed for the FO satisfaction of bounded quantifiers but is not part
of `MonadicStructure` itself. The ordered sum structure assumes that each
(M i).carrier comes with its own order (from the application context).
-/
def OrderedSum (sig : MonadicSignature) (I : Type) (M : I → MonadicStructure sig) :
    MonadicStructure sig where
  carrier := Sigma fun (i : I) => (M i).carrier
  interp p := fun x => (M x.1).interp p x.2

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

**Status**: Sorried. Requires the full monadic FO satisfaction, k-type
distribution counting, and the same induction technique as Lemma 1.4.

The type signature assumes the stronger form: if the sums are type-matching
(without explicitly requiring component-wise k-equivalence), they are
k-equivalent. This is typically proved via Lemma 1.4 by introducing
intermediate sums that align the type distributions.
-/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    (m : I → MonadicStructure sig) (m' : J → MonadicStructure sig) :
    k_equiv sig k (OrderedSum sig I m) (OrderedSum sig J m') := by
  sorry

/-! ## Finite Structures Are k-Equivalent to Z-Intervals -/

/--
Every finite discrete linear order is k-equivalent to a Z-interval
of the same cardinality. This is the "finite case" of Reynolds Theorem 15:
any finite structure can be compressed into a Z-interval.

More precisely: for any finite structure M (with |carrier| = n), there exists
a Z-interval [a, a+n-1] such that M is k-equivalent to the restriction of
some Z-model to that interval.

This is a corollary of Doets Lemma 1.4: a finite discrete structure is an
ordered sum of singletons, and each singleton is k-equivalent to a Z-singleton
(the same predicate pattern). The ordered sum of Z-singletons is a Z-interval.

**Status**: Sorried. Requires:
1. The Z-model as a monadic structure over ℤ
2. Subinterval restriction for monadic structures
3. Finite decomposition into ordered sum of singletons
4. Doets Lemma 1.4 for component-wise equivalence

The type signature below is a placeholder; the actual statement requires
a Z-model `N` such that `k_equiv sig k M N` where `N.carrier` is isomorphic
to `Set.Icc a (a+n-1)` in ℤ.

For the Reynolds pipeline, this theorem is used to prove `finite_structures_good`
in Phase 5, which in turn feeds into the gap elimination argument.
-/
theorem finite_structures_k_equiv_to_Z_interval (sig : MonadicSignature) (k : Nat)
    (M : MonadicStructure sig) [Fintype M.carrier] :
    ∃ (N : MonadicStructure sig),
      k_equiv sig k M N := by
  sorry

end Bimodal.Metalogic.WeakCanonical
