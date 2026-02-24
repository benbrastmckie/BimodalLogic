import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.Construction
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula
import Bimodal.ProofSystem.Axioms

/-!
# Canonical Embedding: Derived Properties for BFMCS Construction

This module provides derived lemmas from the canonical frame (CanonicalFrame.lean)
that support the construction of BFMCS Int for bimodal completeness.

## Key Results

1. **`F_implies_G_P_F`**: If F(psi) in MCS M, then G(P(F(psi))) in M.
   This means P(F(psi)) propagates through GContent seeds to all future MCSes.

2. **`P_implies_H_F_P`**: Symmetric past version.

These lemmas establish that while F-formulas themselves do NOT persist through
GContent seeds (the fundamental blocker for chain approaches), a WEAKER property
P(F(psi)) DOES persist. This weaker property witnesses that F(psi) held at some
past time, which is valuable for linearity-based arguments.

## Connection to Canonical Quotient Approach

The canonical frame (CanonicalFrame.lean) proves forward_F and backward_P
trivially for the abstract canonical model. The challenge is embedding this
into a `BFMCS Int` (indexed by integers, not abstract MCS worlds).

The temp_linearity axiom (Phase 1) ensures the canonical frame's reachable
fragment is linearly ordered. Combined with the derived properties in this
module, a future implementation can:

1. Build a linearly ordered reachable fragment from any root MCS
2. Embed it into Int (using `Order.embedding_from_countable_to_dense` for Q,
   then transferring to Int via the discreteness of the fragment)
3. Construct BFMCS Int with sorry-free forward_F/backward_P

## Technical Analysis: Why Forward_F is Hard for Int Chains

The fundamental challenge (analyzed extensively in research-001.md):

- **F-persistence failure**: F(psi) in M_n does NOT imply F(psi) in M_{n+1}
  when M_{n+1} = Lindenbaum(GContent(M_n)). Lindenbaum can introduce G(neg(psi)).
- **Linearity doesn't fix persistence**: The temp_linearity axiom constrains
  models semantically but does not prevent Lindenbaum from making choices that
  kill F-obligations.
- **GContent propagation**: G(P(F(psi))) DOES propagate (proven below), meaning
  P(F(psi)) persists. But P(F(psi)) only says "F(psi) held in the past", which
  is insufficient for forward_F at the current position.

The correct resolution is the full canonical quotient: build the canonical model
(where forward_F is trivial), prove linearity, and embed into Int. This avoids
the F-persistence problem entirely by not using a chain construction.

## References

- CanonicalFrame.lean: canonical_forward_F, canonical_backward_P (proven)
- Task 922 research-001.md: Canonical Quotient approach
- Goldblatt 1992, *Logics of Time and Computation*
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Temp_a Derived Properties for GContent Propagation

The temp_a axiom (phi -> G(P(phi))) provides key derived properties
that help propagate information through the canonical chain.

While F-formulas don't persist through GContent seeds, their "memory"
P(F(psi)) DOES persist, via temp_a.
-/

/--
If F(psi) ∈ M (MCS), then G(P(F(psi))) ∈ M.

This follows from temp_a: `phi -> G(P(phi))`, instantiated with `F(psi)`.
Since `F(psi) ∈ M` and temp_a gives `⊢ F(psi) -> G(P(F(psi)))`, by MCS closure
`G(P(F(psi))) ∈ M`.

**Significance**: `P(F(psi)) ∈ GContent(M)`, so `P(F(psi))` propagates through
GContent seeds to ALL future MCSes in ANY chain extending M. This means the
"memory" that F(psi) once held persists indefinitely through GContent propagation.
-/
lemma F_implies_G_P_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    Formula.all_future (Formula.some_past (Formula.some_future psi)) ∈ M := by
  -- temp_a instantiated with F(psi): ⊢ F(psi) → G(P(F(psi)))
  -- Note: some_past = sometime_past in the axiom definition
  have h_ta : [] ⊢ (Formula.some_future psi).imp
      (Formula.all_future ((Formula.some_future psi).some_past)) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.some_future psi))
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_F

/--
Corollary: P(F(psi)) ∈ GContent(M) whenever F(psi) ∈ M.

This is a restatement of F_implies_G_P_F in GContent terms.
-/
lemma F_implies_P_F_in_GContent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    (Formula.some_future psi).some_past ∈ GContent M := by
  exact F_implies_G_P_F M h_mcs psi h_F

/--
If P(psi) ∈ M (MCS), then G(P(P(psi))) ∈ M.

This follows from temp_a instantiated with P(psi).
Significance: P(P(psi)) propagates through GContent seeds.
-/
lemma P_implies_G_P_P (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    Formula.all_future ((Formula.some_past psi).some_past) ∈ M := by
  have h_ta : [] ⊢ (Formula.some_past psi).imp
      (Formula.all_future ((Formula.some_past psi).some_past)) :=
    DerivationTree.axiom [] _ (Axiom.temp_a (Formula.some_past psi))
  exact set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_ta) h_P

/-!
## Linearity and CanonicalR Properties

The temp_linearity axiom (`F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)`)
provides key structural properties of the canonical frame.

These lemmas connect the axiom to CanonicalR comparability.
-/

/--
Linearity in MCS: If `F(phi) ∈ M` and `F(psi) ∈ M`, then one of three
disjuncts holds in M:
1. `F(phi ∧ psi) ∈ M` (witnesses coincide)
2. `F(phi ∧ F(psi)) ∈ M` (phi comes first, F(psi) still holds there)
3. `F(F(phi) ∧ psi) ∈ M` (psi comes first, F(phi) still holds there)
-/
lemma mcs_F_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Fphi : Formula.some_future phi ∈ M)
    (h_Fpsi : Formula.some_future psi ∈ M) :
    Formula.some_future (Formula.and phi psi) ∈ M ∨
    Formula.some_future (Formula.and phi (Formula.some_future psi)) ∈ M ∨
    Formula.some_future (Formula.and (Formula.some_future phi) psi) ∈ M := by
  -- From temp_linearity: ⊢ F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)
  have h_lin : [] ⊢ (Formula.and (Formula.some_future phi) (Formula.some_future psi)).imp
      (Formula.or (Formula.some_future (Formula.and phi psi))
        (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
          (Formula.some_future (Formula.and (Formula.some_future phi) psi)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_linearity phi psi)
  -- F(phi) ∧ F(psi) ∈ M
  have h_conj : Formula.and (Formula.some_future phi) (Formula.some_future psi) ∈ M :=
    Bimodal.Metalogic.set_mcs_conjunction_intro h_mcs h_Fphi h_Fpsi
  -- Apply linearity axiom via MCS closure
  have h_disj : Formula.or (Formula.some_future (Formula.and phi psi))
      (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
        (Formula.some_future (Formula.and (Formula.some_future phi) psi))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_lin) h_conj
  -- Decompose the outer disjunction
  rcases Bimodal.Metalogic.set_mcs_disjunction_elim h_mcs h_disj with h1 | h23
  · exact Or.inl h1
  · -- Decompose the inner disjunction
    rcases Bimodal.Metalogic.set_mcs_disjunction_elim h_mcs h23 with h2 | h3
    · exact Or.inr (Or.inl h2)
    · exact Or.inr (Or.inr h3)

end Bimodal.Metalogic.Bundle
