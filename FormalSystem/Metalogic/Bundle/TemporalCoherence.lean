/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.BFMCS
import FormalSystem.Metalogic.Core.MaximalConsistent
import FormalSystem.Metalogic.Core.MCSProperties
import FormalSystem.Syntax.Formula
import FormalSystem.Syntax.SubformulaClosure.TemporalFormulas
import FormalSystem.Theorems.GeneralizedNecessitation
import FormalSystem.Theorems.ModalDerived

/-!
# Temporal Coherence Core

This module contains the restricted temporal and Until/Since coherence predicates consumed by
the re-hosted bundle-flow truth lemma, the backward lemmas proven from them, and the
`BFMCS.CanonicalCoherence` bundle that packages the three the truth lemma actually needs.

## Main Definitions

- `BFMCS.RestrictedTemporallyCoherent`: forward_F/backward_P restricted to `deferralClosure(root)`
- `BFMCS.RestrictedForwardUntilSinceCoherent` / `RestrictedBackwardUntilSinceCoherent`: Until/Since
  coherence restricted to `subformulaClosure(root)`, consumed by the truth lemma
- `BFMCS.ForwardUntilSinceCoherent` / `BackwardUntilSinceCoherent`: their unrestricted forms,
  consumed directly by `BXCanonical/Chronicle/ChronicleMonadicBridge.lean`
- `BFMCS.CanonicalCoherence`: bundles the three restricted predicates the truth lemma needs
- `restricted_temporal_backward_G` / `_H` (and their `_strict` variants): backward G/H proved by
  contraposition from restricted forward_F/backward_P

## Key Insight

The backward lemmas are proven by contraposition:
1. Assume G(phi) not in fam.mcs t
2. By MCS maximality: neg(G(phi)) in fam.mcs t
3. By temporal duality: F(neg phi) in fam.mcs t
4. By restricted forward_F: exists s > t with neg(phi) in fam.mcs s
5. But by hypothesis: phi in fam.mcs s -- contradiction

## References

- Used by BXCanonical/CanonicalModel.lean and BXCanonical/Chronicle/
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.Metalogic.Core
open FormalSystem.ProofSystem
open FormalSystem.Theorems.ModalDerived

variable {fc : FrameClass} {D : Type} [Preorder D] [Zero D]

/-!
## Temporal Duality Infrastructure

These lemmas establish the transformation from neg(G phi) to F(neg phi) in MCS context,
enabling the contraposition argument for temporal backward proofs.
-/

/--
Transform neg(G phi) membership to F(neg phi) membership in an MCS.

Since F(neg phi) = neg(G(neg(neg phi))), we use gDneTheorem contrapositively:
  neg(G phi) in MCS -> neg(G(neg neg phi)) in MCS = F(neg phi) in MCS
-/
lemma neg_all_future_to_some_future_neg (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (phi : Formula) (h_neg_G : Formula.neg (Formula.allFuture phi) ∈ M) :
    Formula.someFuture (Formula.neg phi) ∈ M := by
  have h_eq : Formula.neg (Formula.allFuture phi) =
              Formula.neg (Formula.neg (Formula.someFuture (Formula.neg phi))) := rfl
  rw [h_eq] at h_neg_G
  have h_dne : DerivationTree fc [] ((Formula.neg
      (Formula.neg (Formula.someFuture (Formula.neg phi)))).imp
                     (Formula.someFuture (Formula.neg phi))) :=
    (dneTheorem (Formula.someFuture (Formula.neg phi))).lift (by cases fc <;> trivial)
  exact SetMaximalConsistent.mp_of_theorem h_mcs h_dne h_neg_G

/--
Transform neg(H phi) membership to P(neg phi) membership in an MCS.

Since P(neg phi) = neg(H(neg(neg phi))), we use hDneTheorem contrapositively.
Past analog of neg_all_future_to_some_future_neg.
-/
lemma neg_all_past_to_some_past_neg (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M)
    (phi : Formula) (h_neg_H : Formula.neg (Formula.allPast phi) ∈ M) :
    Formula.somePast (Formula.neg phi) ∈ M := by
  have h_eq : Formula.neg (Formula.allPast phi) =
              Formula.neg (Formula.neg (Formula.somePast (Formula.neg phi))) := rfl
  rw [h_eq] at h_neg_H
  have h_dne : DerivationTree fc [] ((Formula.neg
      (Formula.neg (Formula.somePast (Formula.neg phi)))).imp
                     (Formula.somePast (Formula.neg phi))) :=
    (dneTheorem (Formula.somePast (Formula.neg phi))).lift (by cases fc <;> trivial)
  exact SetMaximalConsistent.mp_of_theorem h_mcs h_dne h_neg_H

/--
Double negation elimination in MCS: if neg(neg phi) in MCS, then phi in MCS.

Uses dneTheorem and MCS closure under derivation.
-/
lemma SetMaximalConsistent.double_neg_elim {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M)
    (phi : Formula) (h_neg_neg : Formula.neg (Formula.neg phi) ∈ M) : phi ∈ M := by
  have h_dne : DerivationTree fc [] ((Formula.neg (Formula.neg phi)).imp phi) :=
    (dneTheorem phi).lift (by cases fc <;> trivial)
  have h_thm_in_M : (Formula.neg (Formula.neg phi)).imp phi ∈ M := theorem_in_mcs h_mcs h_dne
  exact SetMaximalConsistent.implication_property h_mcs h_thm_in_M h_neg_neg

/-!
## Restricted Temporal Coherence

Restricted temporal coherence only requires forward_F and backward_P for formulas
within `deferralClosure(root)`. This weaker condition suffices for the truth lemma
when evaluating formulas in `subformulaClosure(root)`, because the G/H backward
cases only invoke forward_F/backward_P on `neg(psi)` where `psi` is a subformula
of root, and `neg(psi) ∈ closureWithNeg(root) ⊆ deferralClosure(root)`.

### Key Insight

Quantifying forward_F/backward_P over ALL formulas (as an unrestricted `TemporallyCoherent`
predicate would) requires bounding F-nesting depth, which is unbounded in full MCS chains. The
restricted variant only quantifies over `deferralClosure(root)`, where F-nesting IS bounded (by
`maxFDepthInClosure`), making the coherence proof achievable via the BXCanonical chain
construction's bounded subformula closure.
-/

/--
Restricted temporal coherence for a BFMCS: all families have forward_F and backward_P
properties for formulas within `deferralClosure(root)` only.

This is the key weakening that makes canonical completeness provable. The truth lemma
for evaluating `root` only needs temporal coherence for formulas in `deferralClosure(root)`.
-/
def BFMCS.RestrictedTemporallyCoherent (B : BFMCS (fc := fc) D) (root : Formula) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.someFuture φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.somePast φ ∈ fam.mcs t → ∃ s : D, s < t ∧ φ ∈ fam.mcs s)

omit [Zero D] in
/--
Restricted temporal backward G: If phi in fam.mcs s for all s ≥ t, then G(phi) in fam.mcs t.

This only requires forward_F for `neg(phi)`, which must be in `deferralClosure(root)` (supplied
as a hypothesis).

The proof is by contraposition:
1. Assume G(phi) not in fam.mcs t
2. By MCS maximality: neg(G(phi)) in fam.mcs t
3. By temporal duality: F(neg phi) in fam.mcs t
4. By restricted forward_F (using h_neg_phi_dc): exists s ≥ t with neg(phi) in fam.mcs s
5. Contradiction with phi in fam.mcs s
-/
theorem restricted_temporal_backward_G
    (fam : FMCS (fc := fc) D) (root : Formula)
    (h_forward_F : ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.someFuture φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula)
    (h_neg_phi_dc : Formula.neg φ ∈ deferralClosure root)
    (h_all : ∀ s : D, t ≤ s → φ ∈ fam.mcs s) :
    Formula.allFuture φ ∈ fam.mcs t := by
  by_contra h_not_G
  have h_mcs := fam.is_mcs t
  have h_neg_G : Formula.neg (Formula.allFuture φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.allFuture φ) with h_G | h_neg
    · exact absurd h_G h_not_G
    · exact h_neg
  have h_F_neg : Formula.someFuture (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_future_to_some_future_neg (fam.mcs t) h_mcs φ h_neg_G
  obtain ⟨s, h_le, h_neg_phi_s⟩ := h_forward_F t (Formula.neg φ) h_neg_phi_dc h_F_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

omit [Zero D] in
/--
Restricted temporal backward H: If phi in fam.mcs s for all s ≤ t, then H(phi) in fam.mcs t.

Symmetric to `restricted_temporal_backward_G`, using restricted backward_P.
-/
theorem restricted_temporal_backward_H
    (fam : FMCS (fc := fc) D) (root : Formula)
    (h_backward_P : ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.somePast φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula)
    (h_neg_phi_dc : Formula.neg φ ∈ deferralClosure root)
    (h_all : ∀ s : D, s ≤ t → φ ∈ fam.mcs s) :
    Formula.allPast φ ∈ fam.mcs t := by
  by_contra h_not_H
  have h_mcs := fam.is_mcs t
  have h_neg_H : Formula.neg (Formula.allPast φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.allPast φ) with h_H | h_neg
    · exact absurd h_H h_not_H
    · exact h_neg
  have h_P_neg : Formula.somePast (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_past_to_some_past_neg (fam.mcs t) h_mcs φ h_neg_H
  obtain ⟨s, h_le, h_neg_phi_s⟩ := h_backward_P t (Formula.neg φ) h_neg_phi_dc h_P_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_le
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

omit [Zero D] in
/--
Strict version of restricted_temporal_backward_G for strict temporal semantics.
If phi in fam.mcs s for all s > t (strict), then G(phi) in fam.mcs t.

Uses: If not G(phi), then F(neg phi), and forward_F gives witness s > t with neg(phi) in fam.mcs s.
But phi in fam.mcs s (from h_all), contradiction.
-/
theorem restricted_temporal_backward_G_strict
    (fam : FMCS (fc := fc) D) (root : Formula)
    (h_forward_F : ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.someFuture φ ∈ fam.mcs t → ∃ s : D, t < s ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula)
    (h_neg_phi_dc : Formula.neg φ ∈ deferralClosure root)
    (h_all : ∀ s : D, t < s → φ ∈ fam.mcs s) :
    Formula.allFuture φ ∈ fam.mcs t := by
  by_contra h_not_G
  have h_mcs := fam.is_mcs t
  have h_neg_G : Formula.neg (Formula.allFuture φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.allFuture φ) with h_G | h_neg
    · exact absurd h_G h_not_G
    · exact h_neg
  have h_F_neg : Formula.someFuture (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_future_to_some_future_neg (fam.mcs t) h_mcs φ h_neg_G
  obtain ⟨s, h_lt, h_neg_phi_s⟩ := h_forward_F t (Formula.neg φ) h_neg_phi_dc h_F_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_lt
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

omit [Zero D] in
/--
Strict version of restricted_temporal_backward_H for strict temporal semantics.
If phi in fam.mcs s for all s < t (strict), then H(phi) in fam.mcs t.
-/
theorem restricted_temporal_backward_H_strict
    (fam : FMCS (fc := fc) D) (root : Formula)
    (h_backward_P : ∀ t : D, ∀ φ : Formula, φ ∈ deferralClosure root →
      Formula.somePast φ ∈ fam.mcs t → ∃ s : D, s < t ∧ φ ∈ fam.mcs s)
    (t : D) (φ : Formula)
    (h_neg_phi_dc : Formula.neg φ ∈ deferralClosure root)
    (h_all : ∀ s : D, s < t → φ ∈ fam.mcs s) :
    Formula.allPast φ ∈ fam.mcs t := by
  by_contra h_not_H
  have h_mcs := fam.is_mcs t
  have h_neg_H : Formula.neg (Formula.allPast φ) ∈ fam.mcs t := by
    rcases SetMaximalConsistent.negation_complete h_mcs (Formula.allPast φ) with h_H | h_neg
    · exact absurd h_H h_not_H
    · exact h_neg
  have h_P_neg : Formula.somePast (Formula.neg φ) ∈ fam.mcs t :=
    neg_all_past_to_some_past_neg (fam.mcs t) h_mcs φ h_neg_H
  obtain ⟨s, h_lt, h_neg_phi_s⟩ := h_backward_P t (Formula.neg φ) h_neg_phi_dc h_P_neg
  have h_phi_s : φ ∈ fam.mcs s := h_all s h_lt
  exact set_consistent_not_both (fam.is_mcs s).1 φ h_phi_s h_neg_phi_s

/-!
## Until/Since Coherence

Until/Since coherence captures the semantic content of Until/Since operators
at the MCS level. The truth lemma for Until/Since requires that the FMCS
satisfy this coherence: if (φ U ψ) is in an MCS at time t, there must exist
a witness time s > t where ψ is in the MCS at s AND φ is in the MCS at all
intermediate times. Similarly for Since in the past direction.

This is a stronger condition than mere temporal coherence (forward_F/backward_P),
which only provides existential witnesses without the guard condition on
intermediate times.

### Why This Is Needed

The Until truth lemma needs to convert MCS membership of (φ U ψ) into a
semantic witness: ∃ s > t, truth(ψ, s) ∧ ∀ r ∈ (t,s), truth(φ, r).
The induction hypotheses convert between MCS membership and truth for the
subformulas φ and ψ, but the truth lemma needs the MCS-level witness with
the guard condition to apply the IH.

For discrete D (e.g., Int), this was provable from the deterministic chain
structure (bot-Until/bot-Since content, archived to Boneyard). For generic D,
it must be assumed as a coherence condition.

### Backward Direction

The backward direction (truth → MCS) also requires coherence: given a semantic
witness for Until (∃ s > t with truth(ψ,s) and truth(φ,r) for r ∈ (t,s)),
the IH converts to MCS membership, but we need (φ U ψ) ∈ fam.mcs t.
This requires the `until_intro` axiom which works through bot-Until operators,
needing chain structure. For generic D, we assume this directly.
-/

/-!
## Split Until/Since Coherence

`BackwardUntilSinceCoherent` (conjuncts 2 and 4: given a witness, derive Until/Since membership)
and `ForwardUntilSinceCoherent` (conjuncts 1 and 3: given Until/Since membership, produce a
witness) are kept as separate, unrestricted predicates because
`BXCanonical/Chronicle/ChronicleMonadicBridge.lean` consumes both directly, independent of any
`root`-relative restriction.
-/

/--
Backward Until/Since coherence: given a witness pattern (ψ at some s, φ on the guard interval),
derive the Until/Since formula membership at the target time.
-/
def BFMCS.BackwardUntilSinceCoherent (B : BFMCS (fc := fc) D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      (∃ s : D, t < s ∧ φ ∈ fam.mcs s ∧ ∀ r : D, t < r → r < s → ψ ∈ fam.mcs r) →
      Formula.untl ψ φ ∈ fam.mcs t) ∧
    (∀ t : D, ∀ φ ψ : Formula,
      (∃ s : D, s < t ∧ φ ∈ fam.mcs s ∧ ∀ r : D, s < r → r < t → ψ ∈ fam.mcs r) →
      Formula.snce ψ φ ∈ fam.mcs t)

/--
Forward Until/Since coherence: given Until/Since formula membership, produce a witness time
with the guard condition on intermediate times.
-/
def BFMCS.ForwardUntilSinceCoherent (B : BFMCS (fc := fc) D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl ψ φ ∈ fam.mcs t →
      ∃ s : D, t < s ∧ φ ∈ fam.mcs s ∧ ∀ r : D, t < r → r < s → ψ ∈ fam.mcs r) ∧
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.snce ψ φ ∈ fam.mcs t →
      ∃ s : D, s < t ∧ φ ∈ fam.mcs s ∧ ∀ r : D, s < r → r < t → ψ ∈ fam.mcs r)

/--
Restricted forward Until/Since coherence: conjuncts 1 and 3 of the unrestricted predicate,
but quantifying only over Until/Since formulas in `subformulaClosure(root)`.

This weakening is sufficient for the truth lemma, which only needs coherence for
formulas that appear as subformulas of the root formula being evaluated.
-/
def BFMCS.RestrictedForwardUntilSinceCoherent (B : BFMCS (fc := fc) D) (root : Formula) :
    Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl ψ φ ∈ FormalSystem.Syntax.subformulaClosure root →
      Formula.untl ψ φ ∈ fam.mcs t →
      ∃ s : D, t < s ∧ φ ∈ fam.mcs s ∧ ∀ r : D, t < r → r < s → ψ ∈ fam.mcs r) ∧
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.snce ψ φ ∈ FormalSystem.Syntax.subformulaClosure root →
      Formula.snce ψ φ ∈ fam.mcs t →
      ∃ s : D, s < t ∧ φ ∈ fam.mcs s ∧ ∀ r : D, s < r → r < t → ψ ∈ fam.mcs r)

/--
Restricted backward Until/Since coherence: conjuncts 2 and 4 of the unrestricted predicate,
but quantifying only over Until/Since formulas in `subformulaClosure(root)`.

This weakening is sufficient for the truth lemma, which only needs coherence for
formulas that appear as subformulas of the root formula being evaluated.
-/
def BFMCS.RestrictedBackwardUntilSinceCoherent (B : BFMCS (fc := fc) D) (root : Formula) :
    Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.untl ψ φ ∈ FormalSystem.Syntax.subformulaClosure root →
      (∃ s : D, t < s ∧ φ ∈ fam.mcs s ∧ ∀ r : D, t < r → r < s → ψ ∈ fam.mcs r) →
      Formula.untl ψ φ ∈ fam.mcs t) ∧
    (∀ t : D, ∀ φ ψ : Formula,
      Formula.snce ψ φ ∈ FormalSystem.Syntax.subformulaClosure root →
      (∃ s : D, s < t ∧ φ ∈ fam.mcs s ∧ ∀ r : D, s < r → r < t → ψ ∈ fam.mcs r) →
      Formula.snce ψ φ ∈ fam.mcs t)

/-!
## Canonical Coherence Bundle

Bundles the three restricted coherence predicates the re-hosted truth lemma
(`bundleFlow_truth_lemma`, `Algebraic/FlowFrame.lean`) actually consumes into a single
hypothesis, so the truth lemma binds no unused argument.
-/

/--
The three restricted coherence hypotheses the bundle-flow truth lemma needs, bundled into
one `Prop`-valued structure: restricted temporal coherence (forward_F / backward_P), and
restricted forward/backward Until-Since coherence.
-/
structure BFMCS.CanonicalCoherence (B : BFMCS (fc := fc) D) (root : Formula) : Prop where
  temporal : B.RestrictedTemporallyCoherent root
  untilSince_fwd : B.RestrictedForwardUntilSinceCoherent root
  untilSince_bwd : B.RestrictedBackwardUntilSinceCoherent root

end FormalSystem.Metalogic.Bundle
