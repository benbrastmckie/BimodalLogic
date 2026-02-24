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

/-!
## Canonical Existence Lemma (Reverse Direction)

If phi is in an R-successor of M, then F(phi) must be in M.
This is the canonical model analog of the modal existence lemma.
-/

/--
Canonical existence lemma: if CanonicalR M M' and phi in M', then F(phi) in M.

**Proof by contraposition**: if F(phi) not in M, then G(neg phi) in M (by MCS
completeness and the fact that neg(F(phi)) = G(neg phi) up to double negation).
Then neg phi in M' (by CanonicalR propagation). But phi in M' -- contradiction.
-/
lemma canonical_F_of_mem_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_future phi ∈ M := by
  -- By contradiction: suppose F(phi) ∉ M
  by_contra h_not_F
  -- Then neg(F(phi)) ∈ M by MCS completeness
  have h_neg_F : Formula.neg (Formula.some_future phi) ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.some_future phi) with h | h
    · exact absurd h h_not_F
    · exact h
  -- neg(F(phi)) = neg(neg(G(neg(phi)))) since F(phi) = neg(G(neg(phi)))
  -- So G(neg(phi)) ∈ M (by double negation elimination in MCS)
  -- F(phi) = some_future phi = (phi.neg.all_future).neg
  -- neg(F(phi)) = neg((phi.neg.all_future).neg) = phi.neg.all_future (up to double neg)
  -- Actually: neg(some_future phi) = neg(neg(all_future(neg phi))) which is
  -- just all_future(neg phi) after MCS double negation elimination.
  have h_neg_F_eq : Formula.neg (Formula.some_future phi) =
    Formula.neg (Formula.neg (Formula.all_future (Formula.neg phi))) := rfl
  rw [h_neg_F_eq] at h_neg_F
  have h_G_neg : Formula.all_future (Formula.neg phi) ∈ M :=
    Bimodal.Metalogic.Bundle.mcs_double_neg_elim h_mcs _ h_neg_F
  -- By CanonicalR M M': neg(phi) ∈ M' (since all_future(neg phi) ∈ M means neg phi ∈ GContent M ⊆ M')
  have h_neg_phi : Formula.neg phi ∈ M' := h_R h_G_neg
  -- Contradiction: phi and neg(phi) both in M'
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi

/--
Canonical existence lemma (past version): if CanonicalR_past M M' and phi in M',
then P(phi) in M.
-/
lemma canonical_P_of_mem_past_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR_past M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_past phi ∈ M := by
  by_contra h_not_P
  have h_neg_P : Formula.neg (Formula.some_past phi) ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.some_past phi) with h | h
    · exact absurd h h_not_P
    · exact h
  have h_neg_P_eq : Formula.neg (Formula.some_past phi) =
    Formula.neg (Formula.neg (Formula.all_past (Formula.neg phi))) := rfl
  rw [h_neg_P_eq] at h_neg_P
  have h_H_neg : Formula.all_past (Formula.neg phi) ∈ M :=
    Bimodal.Metalogic.Bundle.mcs_double_neg_elim h_mcs _ h_neg_P
  have h_neg_phi : Formula.neg phi ∈ M' := h_R h_H_neg
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi

/-!
## Linearity of the Canonical Frame

The temp_linearity axiom ensures that the canonical frame's reachable fragment
is linearly ordered. This is the key structural property needed for embedding
into Int.
-/

/--
Linearity of CanonicalR on R-successors of a common root.

If M sees both M1 and M2 (CanonicalR M M1 and CanonicalR M M2), then
M1 and M2 are comparable: either CanonicalR M1 M2 or CanonicalR M2 M1 or M1 = M2.

**Status**: Sorry-backed. This is the key remaining blocker for the Canonical Quotient approach.

**Proof Approach (partially verified)**:
Given NOT CanonicalR M1 M2, witnessed by alpha (G(alpha) in M1, alpha not in M2):
1. For phi with G(phi) in M2 and G(phi) not in M: F(G(alpha)) and F(G(phi)) are in M.
2. Apply temp_linearity to G(alpha) and G(phi). All three cases produce witness W with
   both G(alpha) and G(phi) at W (Cases 2,3 reduce to Case 1 via temp_4 propagation).
3. At W: G(alpha AND phi) holds (by K-distribution on G). By canonical_F_of_mem_successor,
   F(G(alpha AND phi)) in M.
4. F(G(alpha AND phi)) and F(neg phi) in M. Apply temp_linearity to G(alpha AND phi) and neg phi.
   - Case 1 (F(G(alpha AND phi) AND neg phi)): G(alpha AND phi) gives phi by T-axiom,
     contradicting neg phi at same world. IMPOSSIBLE.
   - Case 2 (F(G(alpha AND phi) AND F(neg phi))): G(alpha AND phi) propagates to the
     witness for F(neg phi), giving phi there. But neg phi is also there. IMPOSSIBLE.
   - Case 3 (F(F(G(alpha AND phi)) AND neg phi)): neg phi at W2, G(alpha AND phi) at
     later W3. This case is NOT directly impossible and requires a secondary argument
     (possibly repeated linearity applications or a frame correspondence argument).

**Blocker Analysis**: Case 3 of the secondary linearity application produces a configuration
where neg phi is at an earlier time than the start of "alpha AND phi always." The standard
textbook proof of canonical frame linearity likely uses a frame correspondence argument
(showing that if the linearity axiom is valid on a frame, the frame must be linear) rather
than the syntactic approach attempted here. Formalizing the frame correspondence argument
requires proving that the linearity axiom CHARACTERIZES linear frames, which is a separate
theorem involving arbitrary valuations.

**References**:
- Goldblatt 1992, Logics of Time and Computation (canonical frame linearity)
- Blackburn, de Rijke, Venema 2001, Modal Logic (frame correspondence)
- Task 922 research-001.md (Approach A: Canonical Quotient)
-/
theorem canonical_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M M1) (h_R2 : CanonicalR M M2) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  sorry

end Bimodal.Metalogic.Bundle
