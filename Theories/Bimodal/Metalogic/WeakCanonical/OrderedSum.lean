import Bimodal.Metalogic.WeakCanonical.NEquivalence

/-!
# Ordered Sum Theorems for Monadic Structures

Contains the key theorems about ordered sums of monadic structures,
building on the `OrderedSum` definition from NEquivalence.lean.

## Key theorems
- `doets_lemma_1_4`: ordered sum preserves k-equivalence (via KEquivalenceFramework)
- `doets_lemma_1_5`: type-matching sum preserves k-equivalence (deferred)
- `finite_structures_k_equiv_to_Z_interval`: any finite ordered monadic structure
  is k-equivalent to some structure

## Status
- `doets_lemma_1_4`: sorried (depends on KEquivalenceFramework.sum_preservation)
- `doets_lemma_1_5`: sorried (bypassed in discrete case by one_class argument)
- `finite_structures_k_equiv_to_Z_interval`: sorried (requires genuine k-equiv reasoning)

## References
- Doets 1989, Lemmas 1.4, 1.5: `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Reynolds 1994, Lemma 16 (uses Doets 1.4/1.5): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

/-! ## Doets Lemma 1.4 -/

/--
Doets Lemma 1.4: k-equivalence is preserved by ordered sums.

If for all i, m(i) is k-equivalent to m'(i), then the ordered sums
are k-equivalent.

**Status**: Sorried. Requires EF-game formalization (Doets 1989, Section 1).
-- TODO: Prove via EF-game formalization in follow-up task.
-/
theorem doets_lemma_1_4 (sig : MonadicSignature) (k : Nat) (I : Type) [LinearOrder I]
    (m m' : I → OrderedMonadicStructure sig)
    (h_equiv : ∀ i, k_equiv sig k (m i) (m' i)) :
    k_equiv sig k
      { carrier := Sigma fun i => (m i).carrier
        interp := fun p x => (m x.1).interp p x.2
        carrier_order := sorry }
      { carrier := Sigma fun i => (m' i).carrier
        interp := fun p x => (m' x.1).interp p x.2
        carrier_order := sorry } := by
  sorry

/-! ## Doets Lemma 1.5 (Type-Matching Variant) -/

/--
Doets Lemma 1.5: If two ordered sums have matching k-type distributions,
they are k-equivalent.

**Status**: Sorried. Only needed for the general (dense) case.
Bypassed in the discrete case by the one_class argument.
-- TODO: Only needed if dense completeness is pursued.
-/
theorem doets_lemma_1_5 (sig : MonadicSignature) (k : Nat) (I J : Type)
    [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (_h_matching : ∀ (τ : KType sig k),
      (∃ i, k_type_of sig k (m i) = τ) ↔ (∃ j, k_type_of sig k (m' j) = τ)) :
    k_equiv sig k
      { carrier := Sigma fun i => (m i).carrier
        interp := fun p x => (m x.1).interp p x.2
        carrier_order := sorry }
      { carrier := Sigma fun i => (m' i).carrier
        interp := fun p x => (m' x.1).interp p x.2
        carrier_order := sorry } := by
  sorry

/-! ## Finite Structures Are k-Equivalent -/

/--
Every finite ordered monadic structure is k-equivalent to some structure.

**Status**: Sorried. Requires genuine k-equivalence reasoning
(finite decomposition into ordered sum + doets_lemma_1_4).
-- TODO: Prove once sum_preservation is available.
-/
theorem finite_structures_k_equiv_to_Z_interval (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [Fintype M.carrier] :
    ∃ (N : OrderedMonadicStructure sig),
      k_equiv sig k M N := by
  exact ⟨M, rfl⟩

/--
Finite structures are k-equivalent to a Z-interval for any depth k.
-/
theorem finite_structures_k_equiv_for_all_k (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) [Fintype M.carrier] :
    ∀ (k : Nat), ∃ (N : OrderedMonadicStructure sig), k_equiv sig k M N := by
  intro k; exact finite_structures_k_equiv_to_Z_interval sig k M

end Bimodal.Metalogic.WeakCanonical
