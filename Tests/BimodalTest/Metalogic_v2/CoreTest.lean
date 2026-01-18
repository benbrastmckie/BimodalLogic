import Bimodal.Metalogic_v2.Core.MaximalConsistent
import Bimodal.Metalogic_v2.Core.DeductionTheorem
import Bimodal.Metalogic_v2.Core.Provability
import Bimodal.ProofSystem
import Bimodal.Theorems.Propositional

/-!
# Core Layer Tests for Metalogic_v2

Example-based tests for the Core layer of Metalogic_v2, including:
- Consistency definitions and properties
- Maximal consistent set theory
- Lindenbaum's lemma
- Deduction theorem applications

## Test Organization

- **Consistency Tests**: Test basic consistency definitions
- **Provability Tests**: Test derivability and ContextDerivable
- **Deduction Theorem Tests**: Test deduction theorem applications
- **Maximal Consistent Set Tests**: Test MCS properties

## References

* Metalogic_v2/Core/Basic.lean - Consistency definitions
* Metalogic_v2/Core/MaximalConsistent.lean - MCS theory and Lindenbaum
* Metalogic_v2/Core/DeductionTheorem.lean - Deduction theorem
-/

namespace BimodalTest.Metalogic_v2.CoreTest

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic_v2.Core
open Bimodal.Theorems.Propositional

/-!
## Consistency Tests

Test the definition of consistent contexts.
-/

/--
Test: Context with contradiction is inconsistent.

Example: `[p, neg p]` is inconsistent because we can derive bottom.

Proof: Use `ecq` (Ex Contradictione Quodlibet) which gives `[A, neg A] |- B`.
With B = bottom, we get a derivation of bottom from the contradictory context.
-/
example (p : Formula) : ¬Consistent [p, Formula.neg p] := by
  unfold Consistent
  intro h
  apply h
  exact ⟨ecq p Formula.bot⟩

/--
Test: Context with two contradictory implications is inconsistent.

Example: `[p.imp q, p, q.neg]` derives bottom.
-/
example (p q : Formula) : ¬Consistent [p.imp q, p, Formula.neg q] := by
  unfold Consistent
  intro h
  apply h
  -- From [p.imp q, p, q.neg] we can derive bottom:
  -- 1. p.imp q is in context (assumption)
  -- 2. p is in context (assumption)
  -- 3. By modus ponens, q
  -- 4. q.neg is in context
  -- 5. By modus ponens on q.neg (= q.imp bot) and q, we get bot
  have h_imp : [p.imp q, p, Formula.neg q] ⊢ (p.imp q) :=
    DerivationTree.assumption _ _ (List.Mem.head _)
  have h_p : [p.imp q, p, Formula.neg q] ⊢ p :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.head _))
  have h_q : [p.imp q, p, Formula.neg q] ⊢ q :=
    DerivationTree.modus_ponens _ _ _ h_imp h_p
  have h_neg_q : [p.imp q, p, Formula.neg q] ⊢ (Formula.neg q) :=
    DerivationTree.assumption _ _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))
  have h_bot : [p.imp q, p, Formula.neg q] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ _ _ h_neg_q h_q
  exact ⟨h_bot⟩

/-!
## Provability and Derivability Tests

Test type signatures and basic derivability.
-/

/--
Test: ContextDerivable is defined correctly.

Verification: `ContextDerivable Gamma phi` is equivalent to `Nonempty (DerivationTree Gamma phi)`
-/
example (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi = Nonempty (DerivationTree Gamma phi) := rfl

/--
Test: Assumption rule creates valid derivation.
-/
example (phi : Formula) : [phi] ⊢ phi :=
  DerivationTree.assumption [phi] phi (List.Mem.head _)

/--
Test: Multiple assumptions can be accessed.
-/
example (phi psi : Formula) : [phi, psi] ⊢ psi :=
  DerivationTree.assumption [phi, psi] psi (List.Mem.tail _ (List.Mem.head _))

/--
Test: Weakening preserves derivability.
-/
example (phi psi : Formula) (h : [phi] ⊢ psi) : [phi, Formula.atom "extra"] ⊢ psi :=
  DerivationTree.weakening [phi] [phi, Formula.atom "extra"] psi h
    (fun x hm => by
      simp only [List.mem_cons] at hm ⊢
      cases hm with
      | inl heq => left; exact heq
      | inr hn => exact (List.not_mem_nil hn).elim)

/-!
## Deduction Theorem Tests

Test applications of the deduction theorem.
-/

/--
Test: Deduction theorem type signature.

Statement: `(phi :: Gamma) |- psi -> Gamma |- phi -> psi`
-/
noncomputable example (Gamma : Context) (phi psi : Formula) :
    DerivationTree (phi :: Gamma) psi → DerivationTree Gamma (phi.imp psi) :=
  deduction_theorem Gamma phi psi

/--
Test: Deduction theorem application - identity.

From `[phi] |- phi` we get `[] |- phi -> phi`.
-/
noncomputable example (phi : Formula) : [] ⊢ (phi.imp phi) := by
  have h : [phi] ⊢ phi := DerivationTree.assumption [phi] phi (List.Mem.head _)
  exact deduction_theorem [] phi phi h

/--
Test: Deduction theorem application - nested implication.

From `[phi, psi] |- psi` we get `[phi] |- psi -> psi` then `[] |- phi -> (psi -> psi)`.
-/
noncomputable example (phi psi : Formula) : [] ⊢ (phi.imp (psi.imp psi)) := by
  have h1 : [psi, phi] ⊢ psi := DerivationTree.assumption [psi, phi] psi (List.Mem.head _)
  have h2 : [phi] ⊢ (psi.imp psi) := deduction_theorem [phi] psi psi h1
  exact deduction_theorem [] phi (psi.imp psi) h2

/-!
## Maximal Consistent Set Tests

Test properties of maximal consistent sets.
-/

/--
Test: Maximal consistent sets are deductively closed.

Property: `MaximalConsistent Gamma -> (Gamma |- phi -> phi in Gamma)`

Verification: Type signature of `maximal_consistent_closed` is correct.
-/
example (Gamma : Context) (phi : Formula) :
    MaximalConsistent Gamma → DerivationTree Gamma phi → phi ∈ Gamma :=
  maximal_consistent_closed Gamma phi

/--
Test: Maximal consistent sets are negation complete.

Property: `MaximalConsistent Gamma -> (phi notin Gamma -> neg phi in Gamma)`

Verification: Type signature of `maximal_negation_complete` is correct.
-/
example (Gamma : Context) (phi : Formula) :
    MaximalConsistent Gamma → phi ∉ Gamma → Formula.neg phi ∈ Gamma :=
  maximal_negation_complete Gamma phi

/-!
## Set-Based Consistency Tests

Test set-based consistency definitions.
-/

/--
Test: SetConsistent definition.

A set S is set-consistent if every finite subset (as a list) is consistent.
-/
example (S : Set Formula) :
    SetConsistent S = (∀ L : List Formula, (∀ phi ∈ L, phi ∈ S) → Consistent L) := rfl

/--
Test: SetMaximalConsistent definition.

A set is set-maximally consistent if it's set-consistent and cannot be extended.
-/
example (S : Set Formula) :
    SetMaximalConsistent S =
    (SetConsistent S ∧ ∀ phi : Formula, phi ∉ S → ¬SetConsistent (insert phi S)) := rfl

/-!
## Lindenbaum's Lemma Tests

Test the statement of Lindenbaum's lemma.
-/

/--
Test: Lindenbaum's lemma type signature.

Statement: Every consistent set extends to maximal consistent set.

Verification: `set_lindenbaum` has correct type.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M ∧ SetMaximalConsistent M :=
  set_lindenbaum S h

/--
Test: Lindenbaum extension contains original set.

Property: If M extends S via Lindenbaum, then S subseteq M.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, S ⊆ M := by
  obtain ⟨M, hSM, _⟩ := set_lindenbaum S h
  exact ⟨M, hSM⟩

/--
Test: Lindenbaum extension is maximal.

Property: If M extends S via Lindenbaum, then M is SetMaximalConsistent.
-/
example (S : Set Formula) (h : SetConsistent S) :
    ∃ M : Set Formula, SetMaximalConsistent M := by
  obtain ⟨M, _, hmax⟩ := set_lindenbaum S h
  exact ⟨M, hmax⟩

/-!
## Helper Lemma Tests

Test helper lemmas from MaximalConsistent.lean.
-/

/--
Test: UsedFormulas extracts formulas from context.

Property: All formulas used in a derivation come from the context.
-/
example (Gamma : Context) (phi : Formula) (d : DerivationTree Gamma phi) :
    ∀ psi ∈ usedFormulas d, psi ∈ Gamma :=
  usedFormulas_subset d

/--
Test: Derivation uses finite context.

Property: Any derivation uses only finitely many context formulas.
-/
example (Gamma : Context) (phi : Formula) (d : DerivationTree Gamma phi) :
    ∃ L : List Formula, (∀ psi ∈ L, psi ∈ Gamma) ∧ (L ⊆ Gamma) :=
  derivation_uses_finite_context d

/--
Test: Inconsistent context derives bottom.

Property: If Gamma is not consistent, then bottom is derivable from Gamma.
-/
example (Gamma : Context) (h : ¬Consistent Gamma) :
    Nonempty (DerivationTree Gamma Formula.bot) :=
  inconsistent_derives_bot h

/--
Test: Chain union consistency.

Property: Union of a nonempty chain of consistent sets is consistent.
-/
example (C : Set (Set Formula))
    (hchain : IsChain (· ⊆ ·) C) (hCne : C.Nonempty)
    (hcons : ∀ S ∈ C, SetConsistent S) : SetConsistent (⋃₀ C) :=
  consistent_chain_union hchain hCne hcons

end BimodalTest.Metalogic_v2.CoreTest
