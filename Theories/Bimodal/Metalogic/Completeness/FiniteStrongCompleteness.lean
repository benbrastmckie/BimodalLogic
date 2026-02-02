import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Theorems.Propositional

/-!
# Finite-Premise Strong Completeness for TM Bimodal Logic

This module proves the strong completeness theorem for TM bimodal logic
with finite premise sets (contexts represented as `List Formula`):

`semantic_consequence Gamma phi -> ContextDerivable Gamma phi`

## Overview

Strong completeness follows from weak completeness via the deduction theorem.
Given Gamma |= phi:
1. Build impChain Gamma phi = (psi1 -> (psi2 -> ... -> (psin -> phi)...))
2. Show |= impChain Gamma phi
3. By weak completeness, |- impChain Gamma phi
4. By repeated modus ponens with assumptions, Gamma |- phi

## Main Results

- `impChain`: Build implication chain from context
- `impChain_semantics`: Semantic equivalence of impChain
- `finite_strong_completeness`: `Gamma |= phi -> ContextDerivable Gamma phi`
- `context_provable_iff_entails`: Bidirectional equivalence

## References

- Weak completeness: `Bimodal.Metalogic.FMP.semantic_weak_completeness`
- Deduction theorem: `Bimodal.Metalogic.Core.DeductionTheorem`
- Modal Logic, Blackburn et al., Chapter 4
-/

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.FMP
open Bimodal.Theorems.Propositional

/-!
## Context Derivability and Consistency

Definitions moved here from archived WeakCompleteness.lean.
-/

/--
Context-based derivability: phi is derivable from context Gamma.

This is the propositional version of `DerivationTree Gamma phi`, asserting existence
of a derivation tree without committing to a specific proof.
-/
def ContextDerivable (Gamma : Context) (phi : Formula) : Prop :=
  Nonempty (DerivationTree Gamma phi)

/--
A context is consistent if it does not derive bot.
-/
def Consistent (Gamma : Context) : Prop :=
  not Nonempty (DerivationTree Gamma Formula.bot)

/--
Soundness for context derivability: If Gamma |- phi, then Gamma |= phi.
-/
theorem soundness (Gamma : Context) (phi : Formula) :
    (DerivationTree Gamma phi) -> semantic_consequence Gamma phi :=
  Bimodal.Metalogic.soundness Gamma phi

/-!
## Weak Completeness (Bridge to FMP)

Weak completeness via the FMP semantic canonical model.
-/

/--
If a formula is not derivable from empty context, then its negation is consistent.
-/
theorem not_derivable_implies_neg_consistent {phi : Formula} :
    not ContextDerivable [] phi -> Consistent [phi.neg] := by
  intro h_not_deriv
  intro ⟨d_bot⟩
  apply h_not_deriv
  have d_neg_neg : DerivationTree [] (Formula.neg phi).neg :=
    deduction_theorem [] phi.neg Formula.bot d_bot
  have dne : ⊢ phi.neg.neg.imp phi := double_negation phi
  have d_phi : DerivationTree [] phi :=
    DerivationTree.modus_ponens [] phi.neg.neg phi
      (DerivationTree.weakening [] [] (phi.neg.neg.imp phi) dne (List.nil_subset []))
      d_neg_neg
  exact ⟨d_phi⟩

/--
Weak completeness: valid formulas are provable.

**Statement**: `valid phi -> ContextDerivable [] phi`

This uses the FMP-based semantic_weak_completeness via contrapositive.
-/
theorem weak_completeness (phi : Formula) :
    valid phi -> ContextDerivable [] phi := by
  -- Use contrapositive: not (ContextDerivable [] phi) -> not (valid phi)
  intro h_valid
  by_contra h_not_deriv
  -- If phi is not derivable, then {neg phi} is consistent
  have h_neg_cons := not_derivable_implies_neg_consistent h_not_deriv
  -- By FMP, neg phi is satisfiable (since it's consistent)
  -- This means there exists a semantic world state where neg phi is true
  -- which contradicts validity of phi
  -- The FMP semantic_weak_completeness gives us |- phi from semantic validity
  -- We need to show: if valid phi, then ContextDerivable [] phi
  -- The FMP approach proves this via the semantic canonical model
  -- Here we use the fact that FMP constructs a countermodel for non-provable formulas
  have h_deriv := Bimodal.Metalogic.FMP.semantic_completeness phi
  exact ⟨h_deriv h_valid⟩

/-!
## Implication Chain Construction

The key helper for strong completeness: convert a context and conclusion
into a single implication formula.
-/

/--
Build implication chain from context to formula.

Given Gamma = [psi1, ..., psin] and phi, builds the formula psi1 -> (psi2 -> ... -> (psin -> phi)...).

This transforms a semantic consequence Gamma |= phi into a validity statement
|= impChain Gamma phi, allowing us to apply weak completeness.
-/
def impChain (Gamma : Context) (phi : Formula) : Formula :=
  match Gamma with
  | [] => phi
  | psi :: Gamma' => Formula.imp psi (impChain Gamma' phi)

/--
impChain is semantically equivalent to "if all of Gamma hold, then phi holds".

This lemma shows that `truth_at M tau t (impChain Gamma phi)` holds iff
`(forall psi in Gamma, truth_at M tau t psi) -> truth_at M tau t phi`.
-/
lemma impChain_semantics {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} {M : TaskModel F} {tau : WorldHistory F} {t : D}
    (Gamma : Context) (phi : Formula) :
    truth_at M tau t (impChain Gamma phi) <-> ((forall psi in Gamma, truth_at M tau t psi) -> truth_at M tau t phi) := by
  induction Gamma with
  | nil =>
    simp only [impChain, List.not_mem_nil, false_implies, forall_const, implies_true]
  | cons psi Gamma' ih =>
    simp only [impChain, truth_at, ih, List.mem_cons]
    constructor
    · intro h h_all
      have h_psi : truth_at M tau t psi := h_all psi (Or.inl rfl)
      have h_Gamma' : forall chi in Gamma', truth_at M tau t chi := fun chi hchi => h_all chi (Or.inr hchi)
      exact h h_psi h_Gamma'
    · intro h h_psi h_Gamma'
      apply h
      intro chi hchi
      rcases hchi with rfl | hchi'
      · exact h_psi
      · exact h_Gamma' chi hchi'

/--
If Gamma |= phi, then |= impChain Gamma phi.

The proof uses impChain_semantics to show that the semantic content of impChain Gamma phi
matches exactly the definition of semantic consequence.
-/
lemma entails_imp_chain (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> valid (impChain Gamma phi) := by
  intro h_entails D _ _ _ F M tau t
  rw [impChain_semantics]
  intro h_all
  exact h_entails D F M tau t h_all

/-!
## Derivation Chain Unfolding

Given a derivation of impChain Gamma phi, unfold it to derive phi from Gamma.
-/

/--
Given a derivation of impChain Gamma phi from context Delta, derive phi from context (Gamma ++ Delta).

This uses the fact that elements of Gamma are available as assumptions in Gamma ++ Delta,
so we can apply modus ponens repeatedly to unfold the implication chain.
-/
def imp_chain_unfold (Gamma Delta : Context) (phi : Formula) :
    DerivationTree Delta (impChain Gamma phi) -> DerivationTree (Gamma ++ Delta) phi := by
  intro d
  induction Gamma generalizing Delta with
  | nil =>
    simp only [List.nil_append]
    exact d
  | cons psi Gamma' ih =>
    simp only [impChain, List.cons_append] at d ⊢
    have d_weak : DerivationTree (psi :: (Gamma' ++ Delta)) (Formula.imp psi (impChain Gamma' phi)) :=
      DerivationTree.weakening Delta (psi :: (Gamma' ++ Delta)) _ d (by
        intro x hx
        simp [hx])
    have d_assump : DerivationTree (psi :: (Gamma' ++ Delta)) psi :=
      DerivationTree.assumption (psi :: (Gamma' ++ Delta)) psi (by simp)
    have d_chain : DerivationTree (psi :: (Gamma' ++ Delta)) (impChain Gamma' phi) :=
      DerivationTree.modus_ponens (psi :: (Gamma' ++ Delta)) psi (impChain Gamma' phi) d_weak d_assump
    have d_from_ih : DerivationTree (Gamma' ++ (psi :: (Gamma' ++ Delta))) phi := ih (psi :: (Gamma' ++ Delta)) d_chain
    exact DerivationTree.weakening (Gamma' ++ (psi :: (Gamma' ++ Delta))) (psi :: (Gamma' ++ Delta)) phi d_from_ih (by
      intro x hx
      simp at hx ⊢
      rcases hx with h | h
      · right; left; exact h
      · exact h)

/--
If |- impChain Gamma phi, then Gamma |- phi.

Uses imp_chain_unfold to unfold the implication chain with Delta = [].
-/
lemma imp_chain_to_context (Gamma : Context) (phi : Formula) :
    ContextDerivable [] (impChain Gamma phi) -> ContextDerivable Gamma phi := by
  intro ⟨d⟩
  have d' := imp_chain_unfold Gamma [] phi d
  simp only [List.append_nil] at d'
  exact ⟨d'⟩

/-!
## Strong Completeness Theorem
-/

/--
**Finite-Premise Strong Completeness**: Semantic consequence implies syntactic derivability.

**Statement**: `Gamma |= phi -> ContextDerivable Gamma phi`

Equivalently: `(forall F M tau t, (forall psi in Gamma, truth_at M tau t psi) -> truth_at M tau t phi) -> Nonempty (Gamma |- phi)`

**Proof Strategy**:
This follows from weak completeness via the deduction theorem. Given Gamma |= phi:
1. If Gamma is empty, this is weak completeness
2. If Gamma = [psi1, ..., psin], then |= (psi1 -> ... -> psin -> phi)
3. By weak completeness, |- (psi1 -> ... -> psin -> phi)
4. By repeated modus ponens with assumptions, Gamma |- phi
-/
theorem finite_strong_completeness (Gamma : Context) (phi : Formula) :
    semantic_consequence Gamma phi -> ContextDerivable Gamma phi := by
  intro h_entails
  have h_valid := entails_imp_chain Gamma phi h_entails
  have h_deriv := weak_completeness (impChain Gamma phi) h_valid
  exact imp_chain_to_context Gamma phi h_deriv

/--
Context provability equivalence: derivability and semantic consequence are equivalent.

**Statement**: `ContextDerivable Gamma phi <-> Gamma |= phi`
-/
theorem context_provable_iff_entails (Gamma : Context) (phi : Formula) :
    ContextDerivable Gamma phi <-> semantic_consequence Gamma phi := by
  constructor
  · intro ⟨d⟩
    exact soundness Gamma phi d
  · exact finite_strong_completeness Gamma phi

end Bimodal.Metalogic.Completeness
