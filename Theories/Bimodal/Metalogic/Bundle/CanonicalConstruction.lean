import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction
import Bimodal.Metalogic.Bundle.TruthLemma
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Syntax.Formula

/-!
# Canonical Construction: Direct TruthLemma at TaskFrame Level

This module defines the canonical TaskFrame, TaskModel, world-histories, and Omega
for the direct TruthLemma connecting MCS membership to standard `truth_at` evaluation.

## Key Insight (research-006)

The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally
identical to `truth_at` when canonical definitions are chosen correctly. Therefore
we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate.

## Definitions

- `CanonicalWorldState`: Subtype of MCS (maximal consistent sets)
- `CanonicalTaskFrame`: TaskFrame Int with semantically meaningful task_rel
- `CanonicalTaskModel`: TaskModel with valuation = MCS membership
- `to_history`: Convert FMCS to WorldHistory
- `CanonicalOmega`: Set of world-histories from bundle families

## Task Relation Design

The canonical task relation is forward-only with identity at zero:

- **d > 0**: `CanonicalR M N` (GContent M ⊆ N — forward temporal accessibility)
- **d = 0**: `M = N` (zero displacement = same world-state)
- **d < 0**: `False` (negative durations unreachable by `respects_task`)

### Key Design Principle

WorldState and D are fundamentally different types. WorldStates (MCS pairs) form
a vast unstructured space of possible truth-configurations. D (Int) carries the
group structure (addition, ordering). Histories pull totally ordered trajectories
through the space of worlds — the total order lives in D, not in WorldState.

Since `respects_task` only evaluates task_rel at `d = t - s ≥ 0` (because `s ≤ t`),
negative durations are never tested. Making d < 0 → False eliminates all mixed-sign
compositionality without loss.

Making d = 0 → (M = N) rather than vacuous True gives compositionality the
information it needs to chain through d = 0 intermediates (by substitution),
while avoiding the T-axiom obstruction (we never need GContent M ⊆ M).

### Compositionality (no sorry)

Since d < 0 → False, any compositionality premise with x < 0 or y < 0 is
vacuously true. Only non-negative cases remain:
- x = 0, y = 0: transitivity of equality
- x = 0, y > 0: substitute M = U
- x > 0, y = 0: substitute U = V
- x > 0, y > 0: `canonicalR_transitive` (uses temp_4: G(φ) → G(G(φ)))

### Relationship to DurationTransfer

The fully algebraic task relation (w + d = w', with WorldState = D) is constructed
separately in `DurationTransfer.canonicalTaskFrame`. That construction achieves
compositionality via `add_assoc` on the group structure, but conflates WorldState
with D. The canonical construction here keeps WorldState = MCS (the semantically
natural choice) while achieving the same sorry-free compositionality.

## Main Result

```
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

## References

- Task 945: Design canonical model construction for TruthLemma
- research-005.md: Step-by-step construction, D=Z
- research-006.md: Direct TruthLemma, bmcs_truth_at redundancy
-/

namespace Bimodal.Metalogic.Bundle.Canonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Semantics

/-!
## Phase 1: Canonical Structures
-/

/--
Canonical world state: a maximal consistent set packaged as a subtype.

This is the WorldState of the canonical TaskFrame.
-/
def CanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

/--
Canonical task relation: forward-only with identity at zero.

The task relation captures temporal coherence between MCSs along trajectories:
- **d > 0**: `CanonicalR M N` (GContent M ⊆ N) — N is a forward-accessible world from M
- **d = 0**: `M = N` — zero displacement means same world-state
- **d < 0**: `False` — negative durations are unreachable by `respects_task`

**Design rationale**: WorldState and D are fundamentally different types.
WorldStates (MCS pairs) form a vast unstructured space. D (Int) carries the
group structure. Histories pull totally ordered trajectories through the space
of worlds — the total order lives in D, not in WorldState.

Since `respects_task` only evaluates `task_rel` at `d = t - s ≥ 0` (because
`s ≤ t`), negative durations are never tested. Making d < 0 → False is
vacuously safe and eliminates all mixed-sign compositionality complexity.

Making d = 0 → (M = N) rather than vacuous True is the key insight: zero
time means no change. This avoids the T-axiom obstruction (we never need
GContent M ⊆ M) while giving compositionality the information it needs to
chain through d = 0 intermediates.

**WorldHistory restriction**: A valid history must satisfy: for s < t,
`CanonicalR (states s) (states t)`. This eliminates histories that make
arbitrary jumps between unrelated MCSs — only CanonicalR-coherent
trajectories qualify.
-/
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then False
  else M = N  -- d = 0

/--
Nullity: `canonical_task_rel M 0 M` holds because d = 0 reduces to M = M.
-/
theorem canonical_task_rel_nullity (M : CanonicalWorldState) :
    canonical_task_rel M 0 M := by
  simp [canonical_task_rel]

/--
Compositionality: `task_rel M x U → task_rel U y V → task_rel M (x+y) V`.

Since `d < 0 → False`, any premise with x < 0 or y < 0 is False, making the
implication vacuously true. Only the cases x ≥ 0, y ≥ 0 remain:
- x = 0, y = 0: M = U ∧ U = V → M = V (transitivity of equality)
- x = 0, y > 0: M = U, substitute → CanonicalR M V
- x > 0, y = 0: U = V, substitute → CanonicalR M V
- x > 0, y > 0: chain via `canonicalR_transitive` (uses temp_4: G(φ) → G(G(φ)))
-/
theorem canonical_task_rel_compositionality
    (M U V : CanonicalWorldState) (x y : Int)
    (h1 : canonical_task_rel M x U) (h2 : canonical_task_rel U y V) :
    canonical_task_rel M (x + y) V := by
  unfold canonical_task_rel at *
  -- Eliminate impossible cases where x < 0 or y < 0
  by_cases hx_neg : x < 0
  · simp [show ¬(x > 0) from by omega, hx_neg] at h1
  by_cases hy_neg : y < 0
  · simp [show ¬(y > 0) from by omega, hy_neg] at h2
  -- Now x ≥ 0 and y ≥ 0, so x + y ≥ 0
  have hx_nn : ¬(x < 0) := hx_neg
  have hy_nn : ¬(y < 0) := hy_neg
  have hsum_nn : ¬(x + y < 0) := by omega
  by_cases hx_pos : x > 0
  · -- x > 0: h1 gives CanonicalR M.val U.val
    simp [hx_pos, show ¬(x < 0) from by omega] at h1
    by_cases hy_pos : y > 0
    · -- x > 0, y > 0: h2 gives CanonicalR U.val V.val, x + y > 0
      simp [hy_pos, show ¬(y < 0) from by omega] at h2
      simp [show x + y > 0 from by omega, hsum_nn]
      exact canonicalR_transitive M.val U.val V.val M.property h1 h2
    · -- x > 0, y = 0: h2 gives U = V
      have hy_eq : y = 0 := by omega
      subst hy_eq
      simp [show ¬(0 > (0 : Int)) from by omega, show ¬(0 < (0 : Int)) from by omega] at h2
      subst h2  -- U = V
      simp [show x + 0 > 0 from by omega, hsum_nn]
      exact h1
  · -- x = 0: h1 gives M = U
    have hx_eq : x = 0 := by omega
    subst hx_eq
    simp [show ¬(0 > (0 : Int)) from by omega, show ¬(0 < (0 : Int)) from by omega] at h1
    subst h1  -- M = U
    simp [show (0 : Int) + y = y from by omega] at h2 ⊢
    exact h2

/--
The canonical task frame for the direct TruthLemma.

- **WorldState** = `CanonicalWorldState` (MCS pairs) — the space of possible worlds
- **D** = `Int` — the group of temporal displacements
- **task_rel** = `canonical_task_rel` — forward-only with identity at zero

The group structure lives in D (addition, ordering), NOT in WorldState.
Histories are trajectories through the unstructured space of MCSs, with the
total order on D inducing sequential ordering on each trajectory. The task_rel
constrains these trajectories to follow CanonicalR-chains in the forward direction.

Nullity: d = 0 reduces to M = M (reflexivity of equality).
Compositionality: only non-negative cases matter (negative premises are False).
Non-negative compositionality follows from CanonicalR transitivity and substitution.
No sorry dependencies.
-/
def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  compositionality := fun M U V x y h1 h2 =>
    canonical_task_rel_compositionality M U V x y h1 h2

/--
The canonical task model: valuation is MCS membership.

An atom p is true at world-state M iff `atom p in M.val`.
-/
def CanonicalTaskModel : TaskModel CanonicalTaskFrame where
  valuation := fun M p => Formula.atom p ∈ M.val

/--
Convert an FMCS to a WorldHistory in the canonical TaskFrame.

- domain: full (every integer time is in the domain)
- states: the MCS at time t IS the world-state
- respects_task: proved using forward_G from the FMCS structure

Key property: domain = fun _ => True eliminates all domain-related complexity.

**respects_task proof**: For s ≤ t in Int, the duration d = t - s ≥ 0.
- If d > 0 (i.e., s < t): need CanonicalR (mcs s) (mcs t), which is forward_G.
- If d = 0 (i.e., s = t): need ⟨mcs s, ...⟩ = ⟨mcs t, ...⟩, which holds since s = t.
- d < 0 is impossible since s ≤ t implies t - s ≥ 0.
-/
def to_history (fam : FMCS Int) : WorldHistory CanonicalTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := fun s t _ _ hst => by
    -- Need: canonical_task_rel ⟨fam.mcs s, ...⟩ (t - s) ⟨fam.mcs t, ...⟩
    unfold canonical_task_rel
    by_cases h_pos : t - s > 0
    · -- t - s > 0: need CanonicalR (fam.mcs s) (fam.mcs t)
      simp [h_pos, show ¬(t - s < 0) from by omega]
      intro phi h_G_phi
      exact fam.forward_G s t phi (by omega) h_G_phi
    · -- t - s = 0 (can't be negative since s ≤ t)
      have h_eq : t - s = 0 := by omega
      simp [show ¬(t - s > 0) from by omega, show ¬(t - s < 0) from by omega]
      have : s = t := by omega
      subst this
      rfl

/--
The canonical Omega: the set of world-histories from bundle families.

CanonicalOmega B = { tau | exists fam in B.families, tau = to_history fam }

This set is NOT necessarily ShiftClosed. ShiftClosed is not needed for
the TruthLemma (only for the connection to standard validity).
-/
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | ∃ fam ∈ B.families, tau = to_history fam }

/-!
## Phase 2-5: The Direct TruthLemma
-/

/--
The direct canonical truth lemma: MCS membership corresponds to truth_at evaluation.

This is THE KEY THEOREM connecting the BFMCS construction to standard TaskFrame semantics.
It eliminates the bmcs_truth_at intermediate entirely.

The proof proceeds by structural induction on phi, with cases:
- atom: domain is full (True.intro), valuation = MCS membership
- bot: MCS consistency vs False
- imp: MCS modus ponens + negation completeness (uses IH in both directions)
- box: modal_forward/backward + IH
- all_future (G): forward_G + temporal_backward_G via h_tc
- all_past (H): backward_H + temporal_backward_H via h_tc

**Note**: The truth lemma does NOT use task_rel in its proof — temporal
operators (G, H) use the strict order < on D directly, and the box operator
quantifies over histories in Omega (whose membership is determined by the
BFMCS families, not by respects_task filtering). The task_rel constrains
which functions qualify as `WorldHistory CanonicalTaskFrame` (only
CanonicalR-coherent trajectories), but CanonicalOmega is constructed to
ensure all its members satisfy respects_task.
-/
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi := by
  induction phi generalizing fam t with
  | atom p =>
    -- atom case: phi in fam.mcs t <-> exists ht, M.valuation (tau.states t ht) p
    -- Since domain = True, ht = True.intro
    -- valuation (fam.mcs t, is_mcs t) p = (atom p in fam.mcs t)
    simp only [truth_at, CanonicalTaskModel, to_history]
    constructor
    · intro h_atom
      exact ⟨True.intro, h_atom⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    -- bot case: bot in fam.mcs t <-> False
    simp only [truth_at]
    constructor
    · intro h_bot
      -- bot in MCS contradicts consistency
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_bot) ⟨h_deriv⟩
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- imp case: (psi -> chi) in MCS <-> (truth psi -> truth chi)
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · -- Forward: (psi -> chi) in MCS and truth psi -> truth chi
      intro h_imp h_psi_true
      -- By IH backward: psi in MCS
      have h_psi_mcs : psi ∈ fam.mcs t := (ih_psi fam hfam t).mpr h_psi_true
      -- By MCS modus ponens: chi in MCS
      have h_chi_mcs : chi ∈ fam.mcs t := set_mcs_implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi fam hfam t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases set_mcs_negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · -- neg(psi -> chi) in MCS - derive contradiction
        exfalso
        -- From neg(psi -> chi), we get psi in MCS and neg(chi) in MCS
        have h_psi_mcs : psi ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact set_mcs_closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact set_mcs_closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        -- By IH: psi is true
        have h_psi_true : truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t psi :=
          (ih_psi fam hfam t).mp h_psi_mcs
        -- By hypothesis: chi is true
        have h_chi_true : truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t chi :=
          h_truth_imp h_psi_true
        -- By IH: chi in MCS
        have h_chi_mcs : chi ∈ fam.mcs t := (ih_chi fam hfam t).mpr h_chi_true
        -- Contradiction: chi and neg(chi) in consistent MCS
        exact set_consistent_not_both (fam.is_mcs t).1 chi h_chi_mcs h_neg_chi_mcs
  | box psi ih =>
    -- box case: box psi in MCS <-> forall sigma in Omega, truth sigma t psi
    simp only [truth_at]
    constructor
    · -- Forward: box psi in MCS -> forall sigma in Omega, truth sigma t psi
      intro h_box sigma h_sigma_mem
      -- sigma in CanonicalOmega B means sigma = to_history fam' for some fam' in B.families
      obtain ⟨fam', hfam', h_eq⟩ := h_sigma_mem
      subst h_eq
      -- By modal_forward: psi in fam'.mcs t
      have h_psi_mcs : psi ∈ fam'.mcs t := B.modal_forward fam hfam psi t h_box fam' hfam'
      -- By IH: truth at fam'
      exact (ih fam' hfam' t).mp h_psi_mcs
    · -- Backward: forall sigma in Omega, truth sigma t psi -> box psi in MCS
      intro h_all
      -- For each fam' in B.families, to_history fam' is in CanonicalOmega
      -- By IH backward: psi in fam'.mcs t
      have h_psi_all_mcs : ∀ fam' ∈ B.families, psi ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_in_omega : to_history fam' ∈ CanonicalOmega B := ⟨fam', hfam', rfl⟩
        have h_truth := h_all (to_history fam') h_in_omega
        exact (ih fam' hfam' t).mpr h_truth
      -- By modal_backward: box psi in MCS
      exact B.modal_backward fam hfam psi t h_psi_all_mcs
  | all_future psi ih =>
    -- G case: G psi in MCS <-> forall s > t, truth tau s psi
    simp only [truth_at]
    constructor
    · -- Forward: G psi in MCS -> forall s > t, truth tau s psi
      intro h_G s hts
      -- By forward_G: psi in fam.mcs s
      have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts h_G
      -- By IH: truth at s
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s > t, truth tau s psi -> G psi in MCS
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: psi in fam.mcs s for all s > t
      have h_all_mcs : ∀ s : Int, t < s → psi ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s hts)
      -- Apply temporal_backward_G
      exact temporal_backward_G tcf t psi h_all_mcs
  | all_past psi ih =>
    -- H case: H psi in MCS <-> forall s < t, truth tau s psi
    simp only [truth_at]
    constructor
    · -- Forward: H psi in MCS -> forall s < t, truth tau s psi
      intro h_H s hst
      -- By backward_H: psi in fam.mcs s
      have h_psi_mcs : psi ∈ fam.mcs s := fam.backward_H t s psi hst h_H
      -- By IH: truth at s
      exact (ih fam hfam s).mp h_psi_mcs
    · -- Backward: forall s < t, truth tau s psi -> H psi in MCS
      intro h_all
      -- Extract forward_F and backward_P for this family from h_tc
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      -- Build a TemporalCoherentFamily
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      -- By IH backward: psi in fam.mcs s for all s < t
      have h_all_mcs : ∀ s : Int, s < t → psi ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s hst)
      -- Apply temporal_backward_H
      exact temporal_backward_H tcf t psi h_all_mcs

end Bimodal.Metalogic.Bundle.Canonical
