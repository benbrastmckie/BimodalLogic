import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Metalogic_v2.Core.Provability
import Bimodal.Metalogic_v2.Soundness.Soundness
import Bimodal.ProofSystem

/-!
# Core Layer Property Tests for Metalogic_v2

Property-based (proof) tests for the Core layer of Metalogic_v2.

## Properties Tested

- Context operations have expected properties
- Derivation tree properties
- SetConsistent properties

## Implementation Notes

These are proof-based property tests (universally quantified examples) rather than
random-testing property tests. This avoids dependency on Generators.lean which has
known issues.

## References

* Metalogic_v2/Core/Basic.lean - Consistency definitions
* Metalogic_v2/Core/Provability.lean - Context operations
* Metalogic_v2/Core/MaximalConsistent.lean - MCS theory
-/

namespace BimodalTest.Metalogic_v2.CorePropertyTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic_v2.Core

/-! ## Context Operation Properties -/

/--
Property: Context.extends is reflexive.

Every context extends itself.
-/
theorem context_extends_refl (Gamma : Context) : Context.extends Gamma Gamma :=
  fun _ h => h

/--
Property: Context.subset is reflexive.

Every context is a subset of itself.
-/
theorem context_subset_refl (Gamma : Context) : Context.subset Gamma Gamma :=
  fun _ h => h

/--
Property: Empty context extends any context.

The empty context extends all contexts trivially (vacuous truth).
-/
theorem empty_extends_any (Gamma : Context) : Context.extends [] Gamma :=
  fun _ h => (List.not_mem_nil h).elim

/--
Property: Context.extends is transitive.

If Delta extends Gamma and Theta extends Delta, then Theta extends Gamma.
-/
theorem context_extends_trans (Gamma Delta Theta : Context)
    (h1 : Context.extends Gamma Delta) (h2 : Context.extends Delta Theta) :
    Context.extends Gamma Theta :=
  fun psi h => h2 psi (h1 psi h)

/--
Property: Context.subset is transitive.

If Gamma1 subset Gamma2 and Gamma2 subset Gamma3, then Gamma1 subset Gamma3.
-/
theorem context_subset_trans (Gamma1 Gamma2 Gamma3 : Context)
    (h1 : Context.subset Gamma1 Gamma2) (h2 : Context.subset Gamma2 Gamma3) :
    Context.subset Gamma1 Gamma3 :=
  fun psi h => h2 psi (h1 psi h)

/--
Property: Context.merge contains first argument.

For any contexts Gamma1 and Gamma2, every element of Gamma1 is in merge Gamma1 Gamma2.
-/
theorem merge_contains_left (Gamma1 Gamma2 : Context) (phi : Formula) :
    phi ∈ Gamma1 → phi ∈ Context.merge Gamma1 Gamma2 := by
  intro h
  unfold Context.merge
  exact List.mem_append_left Gamma2 h

/--
Property: Context.merge contains second argument.

For any contexts Gamma1 and Gamma2, every element of Gamma2 is in merge Gamma1 Gamma2.
-/
theorem merge_contains_right (Gamma1 Gamma2 : Context) (phi : Formula) :
    phi ∈ Gamma2 → phi ∈ Context.merge Gamma1 Gamma2 := by
  intro h
  unfold Context.merge
  exact List.mem_append_right Gamma1 h

/--
Property: Context.merge is associative (up to membership).

Elements in merge (merge A B) C are exactly those in merge A (merge B C).
-/
theorem merge_assoc_mem (A B C : Context) (phi : Formula) :
    phi ∈ Context.merge (Context.merge A B) C ↔
    phi ∈ Context.merge A (Context.merge B C) := by
  unfold Context.merge
  simp only [List.mem_append]
  constructor
  · intro h
    cases h with
    | inl hab =>
      cases hab with
      | inl ha => left; exact ha
      | inr hb => right; left; exact hb
    | inr hc => right; right; exact hc
  · intro h
    cases h with
    | inl ha => left; left; exact ha
    | inr hbc =>
      cases hbc with
      | inl hb => left; right; exact hb
      | inr hc => right; exact hc

/-! ## Derivation Structure Properties -/

/--
Property: Assumption rule creates valid derivation for any context member.
-/
def assumption_valid (phi : Formula) (Gamma : Context) (h : phi ∈ Gamma) :
    DerivationTree Gamma phi :=
  DerivationTree.assumption Gamma phi h

/--
Property: Axiom rule creates valid derivation for any axiom.
-/
def axiom_valid (Gamma : Context) (phi : Formula) (h : Axiom phi) :
    DerivationTree Gamma phi :=
  DerivationTree.axiom Gamma phi h

/--
Property: Weakening preserves derivability.

If Gamma |- phi and Gamma subseteq Delta, then Delta |- phi.
-/
def weakening_preserves (Gamma Delta : Context) (phi : Formula)
    (h_deriv : DerivationTree Gamma phi)
    (h_sub : ∀ psi ∈ Gamma, psi ∈ Delta) :
    DerivationTree Delta phi :=
  DerivationTree.weakening Gamma Delta phi h_deriv h_sub

/-! ## ContextDerivable Properties -/

/--
Property: ContextDerivable is monotonic in context.

If Gamma |- phi and Gamma subseteq Delta, then Delta |- phi.
-/
theorem context_derivable_mono (Gamma Delta : Context) (phi : Formula)
    (h_deriv : ContextDerivable Gamma phi)
    (h_sub : ∀ psi ∈ Gamma, psi ∈ Delta) :
    ContextDerivable Delta phi := by
  obtain ⟨d⟩ := h_deriv
  exact ⟨DerivationTree.weakening Gamma Delta phi d h_sub⟩

/--
Property: ContextDerivable reflects assumption.

If phi in Gamma, then Gamma |- phi.
-/
theorem context_derivable_assumption (Gamma : Context) (phi : Formula) (h : phi ∈ Gamma) :
    ContextDerivable Gamma phi :=
  ⟨DerivationTree.assumption Gamma phi h⟩

/--
Property: ContextDerivable reflects axioms.

If phi is an axiom, then Gamma |- phi for any Gamma.
-/
theorem context_derivable_axiom (Gamma : Context) (phi : Formula) (h : Axiom phi) :
    ContextDerivable Gamma phi :=
  ⟨DerivationTree.axiom Gamma phi h⟩

/-! ## SetConsistent Properties -/

/--
Property: SetConsistent is anti-monotonic in set inclusion.

If S is SetConsistent and T subseteq S, then T is SetConsistent.
-/
theorem set_consistent_anti_mono (S T : Set Formula) (h_cons : SetConsistent S) (h_sub : T ⊆ S) :
    SetConsistent T := by
  intro L hL
  apply h_cons L
  intro phi h_mem
  exact h_sub (hL phi h_mem)

/--
Property: Singleton set is consistent if consistent as singleton list.

{phi} is SetConsistent iff [phi] is Consistent.
-/
theorem singleton_set_consistent_iff (phi : Formula) :
    SetConsistent {phi} ↔ Consistent [phi] := by
  constructor
  · intro h_set
    apply h_set [phi]
    intro psi h_mem
    simp only [List.mem_singleton] at h_mem
    rw [h_mem]
    exact Set.mem_singleton phi
  · intro h_cons
    intro L hL
    by_cases h_emp : L = []
    · rw [h_emp]
      intro ⟨d⟩
      -- Cannot derive bot from empty context - use soundness
      have h_sem := Bimodal.Metalogic_v2.Soundness.soundness [] Formula.bot d
      -- Build a countermodel where bot is false
      have h_bot_true := h_sem Int Bimodal.Semantics.TaskFrame.trivial_frame
          Bimodal.Semantics.TaskModel.all_false Bimodal.Semantics.WorldHistory.trivial 0
          (fun _ h => (List.not_mem_nil h).elim)
      simp only [Bimodal.Semantics.truth_at] at h_bot_true
    · -- L is non-empty, so it contains phi (since all elements are in {phi})
      intro ⟨d⟩
      apply h_cons
      exact ⟨DerivationTree.weakening L [phi] Formula.bot d (fun psi h_psi =>
        List.mem_singleton.mpr (Set.mem_singleton_iff.mp (hL psi h_psi)))⟩

/-! ## UsedFormulas Properties -/

/--
Property: usedFormulas of assumption is singleton.

For an assumption derivation, usedFormulas returns exactly the assumed formula.
-/
theorem used_formulas_assumption (Gamma : Context) (phi : Formula) (h : phi ∈ Gamma) :
    usedFormulas (DerivationTree.assumption Gamma phi h) = [phi] := rfl

/--
Property: usedFormulas of axiom is empty.

For an axiom derivation, usedFormulas returns empty list.
-/
theorem used_formulas_axiom (Gamma : Context) (phi : Formula) (h : Axiom phi) :
    usedFormulas (DerivationTree.axiom Gamma phi h) = [] := rfl

/--
Property: usedFormulas subset is maintained.

All formulas in usedFormulas come from the context.
-/
theorem used_formulas_subset_context (Gamma : Context) (phi : Formula) (d : DerivationTree Gamma phi) :
    ∀ psi ∈ usedFormulas d, psi ∈ Gamma :=
  usedFormulas_subset d

/--
Property: usedFormulas of modus ponens is union.

For modus ponens, usedFormulas is concatenation of the two subderivations.
-/
theorem used_formulas_modus_ponens (Gamma : Context) (phi psi : Formula)
    (d1 : DerivationTree Gamma (phi.imp psi)) (d2 : DerivationTree Gamma phi) :
    usedFormulas (DerivationTree.modus_ponens Gamma phi psi d1 d2) =
    usedFormulas d1 ++ usedFormulas d2 := rfl

/-! ## Chain Consistency Properties -/

/--
Property: Chain union consistency.

Union of a nonempty chain of consistent sets is consistent.
-/
theorem chain_union_consistent (C : Set (Set Formula))
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, SetConsistent S) : SetConsistent (⋃₀ C) :=
  consistent_chain_union hchain hCne hcons

/--
Property: Finite list in chain member.

Any finite list from a chain union is contained in some single chain member.
-/
theorem finite_list_in_member (C : Set (Set Formula))
    (hchain : IsChain (· ⊆ ·) C) (L : List Formula)
    (hL : ∀ phi ∈ L, phi ∈ ⋃₀ C) (hCne : C.Nonempty) :
    ∃ S ∈ C, ∀ phi ∈ L, phi ∈ S :=
  finite_list_in_chain_member hchain L hL hCne

/-! ## Lindenbaum Properties -/

/--
Property: Lindenbaum extension is superset.

The maximal extension from Lindenbaum contains the original set.
-/
theorem lindenbaum_superset (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M := by
  obtain ⟨M, hSM, _⟩ := set_lindenbaum S h
  exact ⟨M, hSM⟩

/--
Property: Lindenbaum extension is maximal.

The extension from Lindenbaum is SetMaximalConsistent.
-/
theorem lindenbaum_maximal (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, SetMaximalConsistent M := by
  obtain ⟨M, _, hmax⟩ := set_lindenbaum S h
  exact ⟨M, hmax⟩

/--
Property: Lindenbaum extension exists with both properties.

Lindenbaum gives an extension that is both a superset and maximal.
-/
theorem lindenbaum_complete (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M :=
  set_lindenbaum S h

end BimodalTest.Metalogic_v2.CorePropertyTest
