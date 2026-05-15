/-!
# Archived: Vacuous k-Equivalence Proofs

These theorems were removed from `Metalogic/WeakCanonical/OrderedSum.lean` because
they prove only reflexivity (`⟨M, rfl⟩`) rather than genuine Z-interval equivalence.

The theorem names are misleading:
- `finite_structures_k_equiv_to_Z_interval` claims to show k-equiv to a Z-interval,
  but the witness is just `M` itself (reflexivity).
- `finite_structures_k_equiv_for_all_k` trivially wraps the above.

A genuine version would need to show that the k-type of any finite structure is
realizable by a Z-interval structure (Doets 1989, Theorem 1.1).

Archived from Task 139 cleanup, 2026-05-15.
-/

/-
-- Original code:

theorem finite_structures_k_equiv_to_Z_interval (sig : MonadicSignature) (k : Nat)
    (M : OrderedMonadicStructure sig) [Fintype M.carrier] :
    ∃ (N : OrderedMonadicStructure sig),
      k_equiv sig k M N := by
  exact ⟨M, rfl⟩

theorem finite_structures_k_equiv_for_all_k (sig : MonadicSignature)
    (M : OrderedMonadicStructure sig) [Fintype M.carrier] :
    ∀ (k : Nat), ∃ (N : OrderedMonadicStructure sig), k_equiv sig k M N := by
  intro k; exact finite_structures_k_equiv_to_Z_interval sig k M
-/
