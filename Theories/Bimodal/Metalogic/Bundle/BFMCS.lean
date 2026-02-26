import Bimodal.Metalogic.Bundle.FMCS
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Bundle of Maximal Consistent Sets (BFMCS)

A BFMCS is a bundle of indexed MCS families (FMCS instances) with modal
coherence conditions. This enables a Henkin-style completeness proof where box
quantifies over bundled histories rather than all histories.

## Terminology (Task 928)

- **MCS**: A single maximal consistent set
- **FMCS**: A SINGLE time-indexed family of MCS (Family of MCS)
- **BFMCS**: A BUNDLE (set) of FMCS families with modal coherence

## Key Insight

Completeness is an **existential** statement: If Gamma is consistent, then
there exists a model where Gamma is satisfiable. The BFMCS construction provides
exactly ONE such satisfying model. This is standard practice (cf. Henkin semantics
for higher-order logic) and does NOT weaken the completeness result.

## Modal Coherence

The modal coherence conditions ensure:
- `modal_forward`: Box phi in MCS implies phi in ALL families' MCSes at that time
- `modal_backward`: phi in ALL families' MCSes implies Box phi in each family's MCS

These conditions make the truth lemma's box case provable by restricting
quantification to canonical families in the bundle.

## S5 Properties

From the modal coherence conditions, we derive S5-like properties:
- **Reflexivity**: Box phi implies phi (from modal_forward applied to self)
- **Symmetry**: Implicit (all families see all families equally)
- **Transitivity**: Trivial (one-step accessibility)

## References

- Research report: specs/812_canonical_model_completeness/reports/research-007.md
- Implementation plan: specs/812_canonical_model_completeness/plans/implementation-003.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## BFMCS Structure Definition
-/

variable (D : Type*) [Preorder D]

/--
A Bundle of Maximal Consistent Sets (BFMCS) is a collection of indexed MCS families
with modal coherence conditions that enable a provable truth lemma.

**Type Parameters**:
- `D`: Duration/time type with ordered additive group structure

**Fields**:
- `families`: The collection of indexed MCS families forming the bundle
- `nonempty`: The bundle is non-empty
- `modal_forward`: Box phi in any family's MCS implies phi in ALL families' MCSes
- `modal_backward`: phi in ALL families' MCSes implies Box phi in each family's MCS
- `eval_family`: The distinguished evaluation family
- `eval_family_mem`: The evaluation family is in the bundle

**Key Design Decisions**:
1. The bundle is a SET of families, not a list, allowing arbitrary cardinality
2. Modal coherence is formulated as two separate conditions (forward/backward)
3. A distinguished eval_family tracks where evaluation begins

**Why This Works**:
The truth lemma for Box phi becomes:
  Box phi in fam.mcs t
  iff (by modal coherence) phi in fam'.mcs t for all fam' in bundle
  iff (by IH) bmcs_truth fam' t phi for all fam' in bundle
  iff (by definition) bmcs_truth fam t (Box phi)

This avoids the problematic quantification over ALL possible MCS families.
-/
structure BFMCS where
  /-- The collection of indexed MCS families forming the bundle -/
  families : Set (FMCS D)

  /-- The bundle is non-empty -/
  nonempty : families.Nonempty

  /-- Modal forward coherence: Box phi in any family's MCS implies phi in ALL families' MCSes.

      If we know Box phi at time t in some family, then by the modal semantics,
      phi should hold at all "accessible" families. In the bundle construction,
      accessibility is universal: all families see all families.
  -/
  modal_forward : ∀ fam ∈ families, ∀ φ t, Formula.box φ ∈ fam.mcs t →
    ∀ fam' ∈ families, φ ∈ fam'.mcs t

  /-- Modal backward coherence: phi in ALL families' MCSes implies Box phi in each family's MCS.

      This is the converse: if phi holds at all families at time t, then Box phi
      must be in any family's MCS at time t. This uses MCS maximality.
  -/
  modal_backward : ∀ fam ∈ families, ∀ φ t,
    (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t

  /-- The distinguished evaluation family where we start truth evaluation.

      This is the family containing the original consistent context Gamma.
  -/
  eval_family : FMCS D

  /-- The evaluation family is in the bundle -/
  eval_family_mem : eval_family ∈ families

variable {D : Type*} [Preorder D]

/-!
## S5 Properties from Modal Coherence

The modal coherence conditions immediately imply S5-like properties.
-/

/--
Reflexivity: Box phi in MCS implies phi in MCS (from T axiom closure of MCS).

**Proof Strategy**:
1. By modal_forward, Box phi at fam implies phi at ALL families
2. Since fam itself is in families, phi is in fam

This is the key insight: modal_forward gives us reflexivity "for free"
because the quantification includes the original family.
-/
theorem bmcs_reflexivity (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families)
    (φ : Formula) (t : D) (h : Formula.box φ ∈ fam.mcs t) : φ ∈ fam.mcs t :=
  B.modal_forward fam hfam φ t h fam hfam

/-
Symmetry is implicit: all families in the bundle see each other equally.

In standard S5 semantics, symmetry means: if w R w', then w' R w.
In BFMCS, the accessibility relation between families is universal within the bundle,
so symmetry holds trivially: for any fam, fam' in families, they "see" each other.

We don't need an explicit theorem since the universal quantification in modal_forward
already implies this symmetry.
-/

/--
Transitivity is trivial: Box Box phi implies Box phi.

**Proof Strategy**:
1. By bmcs_reflexivity, Box (Box phi) implies Box phi directly
2. This is because the T axiom (Box phi -> phi) applied to Box phi gives Box phi

Actually, transitivity in S5 says: Box phi -> Box Box phi (4 axiom).
For our purposes, we prove the more useful direction:
If Box (Box phi) in MCS, then Box phi in MCS.
-/
theorem bmcs_transitivity (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families)
    (φ : Formula) (t : D) (h : Formula.box (Formula.box φ) ∈ fam.mcs t) :
    Formula.box φ ∈ fam.mcs t :=
  bmcs_reflexivity B fam hfam (Formula.box φ) t h

/-!
## Basic Accessors
-/

/-- Get the MCS of a family at a specific time -/
def BFMCS.mcs_at (B : BFMCS D) (fam : FMCS D) (t : D) : Set Formula :=
  fam.mcs t

/-- The MCS at any family and time is maximal consistent -/
lemma BFMCS.is_mcs (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    SetMaximalConsistent (fam.mcs t) :=
  fam.is_mcs t

/-- The MCS at any family and time is consistent -/
lemma BFMCS.consistent (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    SetConsistent (fam.mcs t) :=
  (fam.is_mcs t).1

/-!
## Diamond (Possibility) Properties

The diamond operator is the dual of box: Diamond phi = neg (Box (neg phi)).
The modal coherence conditions also determine diamond behavior.
-/

/--
Diamond coherence: neg (Box phi) in MCS implies there exists a family where neg phi is in MCS.

**Proof Strategy**:
Since neg (Box phi) means "not necessarily phi", there must be some family
where phi fails. By BFMCS construction, this family is in the bundle.

Actually, in BFMCS with universal accessibility:
- Diamond phi true means: exists family where phi true
- neg (Box neg phi) true means: not (forall families, neg phi true)
                              = exists family where neg phi false = phi true

For now, we state this as: if neg (Box (neg phi)) in fam.mcs t, then
there exists fam' in families where phi in fam'.mcs t.

This requires careful reasoning with negation completeness of MCS.
-/
theorem bmcs_diamond_witness (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families)
    (φ : Formula) (t : D)
    (h_diamond : Formula.neg (Formula.box (Formula.neg φ)) ∈ fam.mcs t) :
    ∃ fam' ∈ B.families, φ ∈ fam'.mcs t := by
  -- neg (Box neg phi) means: not all families have neg phi
  -- Contrapositively: if all families had neg phi, then Box neg phi would be in fam.mcs
  -- But then neg (Box neg phi) and Box neg phi would both be in the consistent fam.mcs
  -- Contradiction
  by_contra h_no_witness
  push_neg at h_no_witness
  -- So for all fam' in families, phi not in fam'.mcs t
  -- By MCS negation completeness, neg phi in fam'.mcs t for all fam'
  have h_all_neg : ∀ fam' ∈ B.families, Formula.neg φ ∈ fam'.mcs t := by
    intro fam' hfam'
    have h_not_phi := h_no_witness fam' hfam'
    -- By MCS negation completeness
    have h_mcs := fam'.is_mcs t
    rcases set_mcs_negation_complete h_mcs φ with h_phi | h_neg_phi
    · exact absurd h_phi h_not_phi
    · exact h_neg_phi
  -- By modal_backward, Box neg phi in fam.mcs t
  have h_box_neg : Formula.box (Formula.neg φ) ∈ fam.mcs t :=
    B.modal_backward fam hfam (Formula.neg φ) t h_all_neg
  -- But neg (Box neg phi) is also in fam.mcs t, contradicting consistency
  exact set_consistent_not_both (B.consistent fam hfam t) (Formula.box (Formula.neg φ)) h_box_neg h_diamond

/-!
## Useful Derived Lemmas
-/

/--
If phi is in all families at time t, then Box phi is in all families at time t.
-/
lemma BFMCS.box_from_universal (B : BFMCS D) (φ : Formula) (t : D)
    (h : ∀ fam ∈ B.families, φ ∈ fam.mcs t) :
    ∀ fam ∈ B.families, Formula.box φ ∈ fam.mcs t := by
  intro fam hfam
  exact B.modal_backward fam hfam φ t h

/--
If Box phi is in some family at time t, then phi is in all families at time t.
-/
lemma BFMCS.phi_from_box (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families)
    (φ : Formula) (t : D) (h : Formula.box φ ∈ fam.mcs t) :
    ∀ fam' ∈ B.families, φ ∈ fam'.mcs t :=
  B.modal_forward fam hfam φ t h

/--
Box phi in MCS iff phi in all families' MCSes (the key bidirectional lemma).
-/
theorem BFMCS.box_iff_universal (B : BFMCS D) (fam : FMCS D) (hfam : fam ∈ B.families)
    (φ : Formula) (t : D) :
    Formula.box φ ∈ fam.mcs t ↔ ∀ fam' ∈ B.families, φ ∈ fam'.mcs t := by
  constructor
  · exact B.phi_from_box fam hfam φ t
  · exact B.modal_backward fam hfam φ t

end Bimodal.Metalogic.Bundle
