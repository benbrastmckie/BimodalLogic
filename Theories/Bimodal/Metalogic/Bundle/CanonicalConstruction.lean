import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Core.DeductionTheorem
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.Truth
import Bimodal.Syntax.Formula
import Bimodal.Theorems.Combinators
import Bimodal.Theorems.Propositional

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
- `ShiftClosedCanonicalOmega`: Shift-closed enlargement of CanonicalOmega (Task 968)
- `box_persistent`: Box phi at time t implies Box phi at all times (Task 968)
- `shifted_truth_lemma`: Truth lemma for shift-closed Omega (Task 968)

## Task Relation Design

The canonical task relation is forward-only with identity at zero:

- **d > 0**: `CanonicalR M N` (g_content M ⊆ N — forward temporal accessibility)
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
while avoiding the T-axiom obstruction (we never need g_content M ⊆ M).

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

## Main Results

```
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi

theorem shifted_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (phi : Formula) (fam : FMCS Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <->
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t phi
```

## Shift-Closure Infrastructure (Task 968)

The `shifted_truth_lemma` extends the canonical truth lemma to work with a shift-closed
Omega, which is required for connecting to standard validity definitions. The key insight
is that `box_persistent` (Box phi persists to all times via the TF axiom) enables the
box case to handle time-shifted histories via `time_shift_preserves_truth`.

Port from: `Boneyard/IntRepresentation/Representation.lean`

## References

- Task 945: Design canonical model construction for TruthLemma
- Task 968: Port shift-closure pattern to CanonicalConstruction
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
Canonical task relation: forward accessibility with converse for negative durations.

The task relation captures temporal coherence between MCSs along trajectories:
- **d > 0**: `CanonicalR M.val N.val` (g_content M ⊆ N) — N is forward-accessible from M
- **d = 0**: `M = N` — zero displacement means same world-state
- **d < 0**: `CanonicalR N.val M.val` — backward direction uses converse relationship

**Design rationale (Task 966/969)**: WorldState and D are fundamentally different types.
WorldStates (MCS pairs) form a vast unstructured space. D (Int) carries the
group structure. Histories pull totally ordered trajectories through the space
of worlds — the total order lives in D, not in WorldState.

The key insight from task 966 research: instead of making `d < 0 → False`, we
use `d < 0 → CanonicalR N.val M.val`. This allows us to prove the converse axiom
(`task_rel M d N ↔ task_rel N (-d) M`) because:
- If d > 0: LHS = CanonicalR M N, RHS (with -d < 0) = CanonicalR M N ✓
- If d = 0: LHS = M = N, RHS (with -0 = 0) = N = M ✓
- If d < 0: LHS = CanonicalR N M, RHS (with -d > 0) = CanonicalR N M ✓

Making d = 0 → (M = N) rather than vacuous True is the key insight: zero
time means no change. This gives the nullity_identity axiom (`task_rel M 0 N ↔ M = N`).

**WorldHistory restriction**: A valid history must satisfy: for s < t,
`CanonicalR (states s) (states t)`. Since respects_task uses s ≤ t (so d ≥ 0),
the d < 0 case is never tested by respects_task, but exists for converse.
-/
def canonical_task_rel (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0

/--
Nullity identity: `canonical_task_rel M 0 N` holds iff `M = N`.
-/
theorem canonical_task_rel_nullity_identity (M N : CanonicalWorldState) :
    canonical_task_rel M 0 N ↔ M = N := by
  simp [canonical_task_rel]

/--
Forward compositionality: `task_rel M x U → task_rel U y V → task_rel M (x+y) V`
when `0 ≤ x` and `0 ≤ y`.

Since we restrict to non-negative durations, only these cases apply:
- x = 0, y = 0: M = U ∧ U = V → M = V (transitivity of equality)
- x = 0, y > 0: M = U, substitute → CanonicalR M V
- x > 0, y = 0: U = V, substitute → CanonicalR M V
- x > 0, y > 0: chain via `canonicalR_transitive` (uses temp_4: G(φ) → G(G(φ)))
-/
theorem canonical_task_rel_forward_comp
    (M U V : CanonicalWorldState) (x y : Int)
    (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : canonical_task_rel M x U) (h2 : canonical_task_rel U y V) :
    canonical_task_rel M (x + y) V := by
  unfold canonical_task_rel at *
  -- With 0 ≤ x and 0 ≤ y, we have 0 ≤ x + y
  by_cases hx_pos : x > 0
  · -- x > 0: h1 gives CanonicalR M.val U.val
    have hx_neg : ¬(x < 0) := by omega
    rw [if_pos hx_pos] at h1
    by_cases hy_pos : y > 0
    · -- x > 0, y > 0: h2 gives CanonicalR U.val V.val, x + y > 0
      have hy_neg : ¬(y < 0) := by omega
      rw [if_pos hy_pos] at h2
      have hsum_pos : x + y > 0 := by omega
      rw [if_pos hsum_pos]
      exact canonicalR_transitive M.val U.val V.val M.property h1 h2
    · -- x > 0, y = 0: h2 gives U = V
      have hy_eq : y = 0 := by omega
      subst hy_eq
      have hy_neg : ¬((0 : Int) < 0) := by omega
      have hy_npos : ¬((0 : Int) > 0) := by omega
      rw [if_neg hy_npos, if_neg hy_neg] at h2
      subst h2  -- U = V
      have hsum_pos : x + 0 > 0 := by omega
      rw [if_pos hsum_pos]
      exact h1
  · -- x = 0: h1 gives M = U
    have hx_eq : x = 0 := by omega
    subst hx_eq
    have hx_neg : ¬((0 : Int) < 0) := by omega
    have hx_npos : ¬((0 : Int) > 0) := by omega
    rw [if_neg hx_npos, if_neg hx_neg] at h1
    subst h1  -- M = U
    simp only [zero_add]
    exact h2

/--
Converse axiom: `canonical_task_rel M d N ↔ canonical_task_rel N (-d) M`.

This holds because of how we defined `canonical_task_rel`:
- If d > 0: LHS = CanonicalR M N, RHS (with -d < 0) = CanonicalR M N ✓
- If d = 0: LHS = M = N, RHS (with -0 = 0) = N = M ✓
- If d < 0: LHS = CanonicalR N M, RHS (with -d > 0) = CanonicalR N M ✓
-/
theorem canonical_task_rel_converse
    (M : CanonicalWorldState) (d : Int) (N : CanonicalWorldState) :
    canonical_task_rel M d N ↔ canonical_task_rel N (-d) M := by
  unfold canonical_task_rel
  by_cases hd_pos : d > 0
  · -- d > 0: LHS = CanonicalR M.val N.val
    -- -d < 0: RHS = CanonicalR M.val N.val
    simp [hd_pos, show ¬(d < 0) from by omega, show -d < 0 from by omega, show ¬(-d > 0) from by omega]
  · by_cases hd_neg : d < 0
    · -- d < 0: LHS = CanonicalR N.val M.val
      -- -d > 0: RHS = CanonicalR N.val M.val
      simp [show ¬(d > 0) from by omega, hd_neg, show -d > 0 from by omega, show ¬(-d < 0) from by omega]
    · -- d = 0: LHS = M = N, RHS = N = M
      have hd_eq : d = 0 := by omega
      subst hd_eq
      simp [show ¬(0 > (0 : Int)) from by omega, show ¬(0 < (0 : Int)) from by omega]
      exact ⟨Eq.symm, Eq.symm⟩

/--
The canonical task frame for the direct TruthLemma.

- **WorldState** = `CanonicalWorldState` (MCS pairs) — the space of possible worlds
- **D** = `Int` — the group of temporal displacements
- **task_rel** = `canonical_task_rel` — forward accessibility with converse

The group structure lives in D (addition, ordering), NOT in WorldState.
Histories are trajectories through the unstructured space of MCSs, with the
total order on D inducing sequential ordering on each trajectory. The task_rel
constrains these trajectories to follow CanonicalR-chains in the forward direction.

**Axiomatization (Task 969)**:
- nullity_identity: d = 0 ↔ M = N (zero duration iff identical states)
- forward_comp: non-negative durations compose via CanonicalR transitivity
- converse: task_rel M d N ↔ task_rel N (-d) M (temporal symmetry)
-/
def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity_identity := canonical_task_rel_nullity_identity
  forward_comp := fun M U V x y hx hy h1 h2 =>
    canonical_task_rel_forward_comp M U V x y hx hy h1 h2
  converse := canonical_task_rel_converse

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
    show canonical_task_rel _ _ _
    unfold canonical_task_rel
    -- Goal: if (t - s > 0) then CanonicalR ... else if (t - s < 0) then CanonicalR ... else (M = N)
    by_cases h_pos : t - s > 0
    · -- t - s > 0: need CanonicalR (fam.mcs s) (fam.mcs t)
      rw [if_pos h_pos]
      intro phi h_G_phi
      exact fam.forward_G s t phi (by omega) h_G_phi
    · -- t - s ≤ 0, but s ≤ t means t - s ≥ 0, so t - s = 0
      have h_eq : t - s = 0 := by omega
      have h_neg : ¬(t - s < 0) := by omega
      rw [if_neg h_pos, if_neg h_neg]
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
## Shift-Closed Canonical Omega

The shift-closed enlargement of CanonicalOmega. This set contains all canonical
histories AND all their time-shifts, making it shift-closed by construction.
This is needed so that the completeness proof can provide an Omega satisfying
the ShiftClosed condition required by `valid`.

**Port from**: Boneyard/IntRepresentation/Representation.lean (lines 180-220)
-/

/-- The shift-closed canonical Omega: all time-shifts of canonical histories.

This is the enlargement of CanonicalOmega that includes all time-shifts.
For any family fam and any time offset delta, the shifted history
`WorldHistory.time_shift (to_history fam) delta` is in this set.
-/
def ShiftClosedCanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { σ | ∃ (fam : FMCS Int) (_ : fam ∈ B.families) (delta : Int),
    σ = WorldHistory.time_shift (to_history fam) delta }

/-- Time-shift of canonical histories composes: shifting by delta then delta'
equals shifting by delta + delta'.

This is the key lemma for proving shift-closure. -/
private theorem time_shift_to_history_compose
    (fam : FMCS Int)
    (delta delta' : Int) :
    WorldHistory.time_shift (WorldHistory.time_shift (to_history fam) delta) delta' =
    WorldHistory.time_shift (to_history fam) (delta + delta') := by
  -- WorldHistory equality is extensional: need to show domain and states agree
  have h_time_eq : ∀ t : Int, t + delta' + delta = t + (delta + delta') := fun t => by omega
  simp only [WorldHistory.time_shift, to_history]
  -- Need to show the WorldHistory structures are equal
  congr 1
  -- States: need to show the state functions are equal (domain was trivial)
  ext t ht
  -- Show: ⟨fam.mcs (t + delta' + delta), ...⟩ = ⟨fam.mcs (t + (delta + delta')), ...⟩
  simp only [Subtype.mk.injEq, Set.ext_iff]
  rw [h_time_eq t]

/-- A canonical history equals its time-shift by 0. -/
private theorem to_history_eq_time_shift_zero (fam : FMCS Int) :
    to_history fam = WorldHistory.time_shift (to_history fam) 0 := by
  simp only [WorldHistory.time_shift, to_history, add_zero]

/-- ShiftClosedCanonicalOmega is shift-closed. -/
theorem shiftClosedCanonicalOmega_is_shift_closed (B : BFMCS Int) :
    ShiftClosed (ShiftClosedCanonicalOmega B) := by
  intro σ h_mem Δ'
  obtain ⟨fam, hfam, delta, h_eq⟩ := h_mem
  refine ⟨fam, hfam, delta + Δ', ?_⟩
  subst h_eq
  exact time_shift_to_history_compose fam delta Δ'

/-- Every canonical history is in the shift-closed canonical Omega (take delta = 0). -/
theorem canonicalOmega_subset_shiftClosed (B : BFMCS Int) :
    CanonicalOmega B ⊆ ShiftClosedCanonicalOmega B := by
  intro σ h_mem
  obtain ⟨fam, hfam, h_eq⟩ := h_mem
  refine ⟨fam, hfam, 0, ?_⟩
  subst h_eq
  exact to_history_eq_time_shift_zero fam

/-!
## Box Persistence

The key lemma for the shifted truth lemma: Box phi at any time t implies
Box phi at ALL times, using the TF axiom and its temporal dual.

**Port from**: Boneyard/IntRepresentation/Representation.lean (lines 232-275)
-/

/-- Past analog of TF axiom: Box phi -> H(Box phi), derived via temporal duality.
TF is `(Box phi).imp (Box phi).all_future`. Applying temporal duality to
TF for `swap_past_future phi` yields `(Box phi).imp (Box phi).all_past`. -/
private def past_tf_deriv (φ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((Formula.box φ).imp (Formula.box φ).all_past) := by
  have h_tf_swap := Bimodal.ProofSystem.DerivationTree.axiom [] _
    (Bimodal.ProofSystem.Axiom.temp_future (Formula.swap_past_future φ))
  have h_dual := Bimodal.ProofSystem.DerivationTree.temporal_duality _ h_tf_swap
  have h_eq : Formula.swap_past_future ((Formula.box (Formula.swap_past_future φ)).imp
      (Formula.box (Formula.swap_past_future φ)).all_future) =
    (Formula.box φ).imp (Formula.box φ).all_past := by
    simp [Formula.swap_past_future, Formula.swap_temporal]
  rw [h_eq] at h_dual
  exact h_dual

/-- Box phi at time t implies Box phi at all times s, for any family in a BFMCS.

The proof uses:
1. TF axiom: Box phi -> G(Box phi) -- so Box phi persists to all future times
2. Temporal dual of TF: Box phi -> H(Box phi) -- so Box phi persists to all past times
3. forward_G and backward_H to extract Box phi at specific times
-/
theorem box_persistent
    (fam : FMCS Int)
    (φ : Formula) (t s : Int)
    (h_box : Formula.box φ ∈ fam.mcs t) :
    Formula.box φ ∈ fam.mcs s := by
  -- Step 1: G(Box phi) ∈ fam.mcs t via TF axiom
  have h_tf : (Formula.box φ).imp (Formula.box φ).all_future ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.temp_future φ))
  have h_G_box : (Formula.box φ).all_future ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_tf h_box
  -- Step 2: H(Box phi) ∈ fam.mcs t via past-TF
  have h_past_tf : (Formula.box φ).imp (Formula.box φ).all_past ∈ fam.mcs t :=
    theorem_in_mcs (fam.is_mcs t) (past_tf_deriv φ)
  have h_H_box : (Formula.box φ).all_past ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t) h_past_tf h_box
  -- Step 3: Case split on s vs t (three cases for irreflexive semantics)
  rcases lt_trichotomy t s with h_lt | h_eq | h_gt
  · -- s > t: use forward_G (strict)
    exact fam.forward_G t s (Formula.box φ) h_lt h_G_box
  · -- s = t: trivial from h_box
    rw [← h_eq]
    exact h_box
  · -- s < t: use backward_H (strict)
    exact fam.backward_H t s (Formula.box φ) h_gt h_H_box

/-!
## Phase 2-5: The Direct TruthLemma

Helper tautologies used by the imp case of `canonical_truth_lemma`:
-/

/-- Classical tautology: ¬(ψ → χ) → ψ -/
noncomputable def neg_imp_implies_antecedent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : Bimodal.ProofSystem.DerivationTree [] (ψ.neg.imp (ψ.imp χ)) :=
    Bimodal.Theorems.Propositional.efq_neg ψ χ
  have h_efq_ctx : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [ψ.neg, (ψ.imp χ).neg] _ h_efq (by intro; simp)
  have h_neg_psi : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_efq_ctx h_neg_psi
  have h_neg_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_bot : [ψ.neg, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_neg_psi : [(ψ.imp χ).neg] ⊢ ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] ψ.neg Formula.bot h_bot
  have h_deduct : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg ψ.neg.neg h_neg_neg_psi
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    Bimodal.Theorems.Propositional.double_negation ψ
  have h_b : [] ⊢ (ψ.neg.neg.imp ψ).imp (((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ)) :=
    Bimodal.Theorems.Combinators.b_combinator
  have h_step1 : [] ⊢ ((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ) :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_b h_dne
  exact Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_step1 h_deduct

/-- Classical tautology: ¬(ψ → χ) → ¬χ -/
noncomputable def neg_imp_implies_neg_consequent (ψ χ : Formula) :
    Bimodal.ProofSystem.DerivationTree [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.prop_s χ ψ)
  have h_prop_s_ctx : [χ, (ψ.imp χ).neg] ⊢ χ.imp (ψ.imp χ) :=
    Bimodal.ProofSystem.DerivationTree.weakening [] [χ, (ψ.imp χ).neg] _ h_prop_s (by intro; simp)
  have h_chi : [χ, (ψ.imp χ).neg] ⊢ χ :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_imp : [χ, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_prop_s_ctx h_chi
  have h_neg_imp : [χ, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)
  have h_bot : [χ, (ψ.imp χ).neg] ⊢ Formula.bot :=
    Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_chi : [(ψ.imp χ).neg] ⊢ χ.neg :=
    Bimodal.Metalogic.Core.deduction_theorem [(ψ.imp χ).neg] χ Formula.bot h_bot
  exact Bimodal.Metalogic.Core.deduction_theorem [] (ψ.imp χ).neg χ.neg h_neg_chi

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
      have h_chi_mcs : chi ∈ fam.mcs t := SetMaximalConsistent.implication_property h_mcs h_imp h_psi_mcs
      -- By IH forward: truth chi
      exact (ih_chi fam hfam t).mp h_chi_mcs
    · -- Backward: (truth psi -> truth chi) -> (psi -> chi) in MCS
      intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (psi.imp chi) with h_imp | h_neg_imp
      · exact h_imp
      · -- neg(psi -> chi) in MCS - derive contradiction
        exfalso
        -- From neg(psi -> chi), we get psi in MCS and neg(chi) in MCS
        have h_psi_mcs : psi ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_chi_mcs : chi.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent psi chi
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(psi.imp chi).neg]
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
    -- G case: G psi in MCS <-> forall s >= t, truth tau s psi
    -- Note: Reflexive semantics (t ≤ s) per Task 967
    simp only [truth_at]
    constructor
    · -- Forward: G psi in MCS -> forall s >= t, truth tau s psi
      intro h_G s hts
      -- Case split: t = s (use temporal T axiom) or t < s (use forward_G)
      rcases hts.lt_or_eq with hts_lt | hts_eq
      · -- t < s: use forward_G
        have h_psi_mcs : psi ∈ fam.mcs s := fam.forward_G t s psi hts_lt h_G
        exact (ih fam hfam s).mp h_psi_mcs
      · -- t = s: use temporal T axiom (Gφ → φ)
        rw [← hts_eq]
        have h_T : (psi.all_future).imp psi ∈ fam.mcs t :=
          theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
            (Bimodal.ProofSystem.Axiom.temp_t_future psi))
        have h_psi_mcs := SetMaximalConsistent.implication_property (fam.is_mcs t) h_T h_G
        exact (ih fam hfam t).mp h_psi_mcs
    · -- Backward: forall s >= t, truth tau s psi -> G psi in MCS
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
      -- (temporal_backward_G only needs strict inequality)
      have h_all_mcs : ∀ s : Int, t < s → psi ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s (le_of_lt hts))
      -- Apply temporal_backward_G
      exact temporal_backward_G tcf t psi h_all_mcs
  | all_past psi ih =>
    -- H case: H psi in MCS <-> forall s <= t, truth tau s psi
    -- Note: Reflexive semantics (s ≤ t) per Task 967
    simp only [truth_at]
    constructor
    · -- Forward: H psi in MCS -> forall s <= t, truth tau s psi
      intro h_H s hst
      -- Case split: s = t (use temporal T axiom) or s < t (use backward_H)
      rcases hst.lt_or_eq with hst_lt | hst_eq
      · -- s < t: use backward_H
        have h_psi_mcs : psi ∈ fam.mcs s := fam.backward_H t s psi hst_lt h_H
        exact (ih fam hfam s).mp h_psi_mcs
      · -- s = t: use temporal T axiom (Hφ → φ)
        rw [hst_eq]
        have h_T : (psi.all_past).imp psi ∈ fam.mcs t :=
          theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
            (Bimodal.ProofSystem.Axiom.temp_t_past psi))
        have h_psi_mcs := SetMaximalConsistent.implication_property (fam.is_mcs t) h_T h_H
        exact (ih fam hfam t).mp h_psi_mcs
    · -- Backward: forall s <= t, truth tau s psi -> H psi in MCS
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
      -- (temporal_backward_H only needs strict inequality)
      have h_all_mcs : ∀ s : Int, s < t → psi ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s (le_of_lt hst))
      -- Apply temporal_backward_H
      exact temporal_backward_H tcf t psi h_all_mcs

/-!
## Shifted Truth Lemma

The truth lemma extended to `ShiftClosedCanonicalOmega`. This is the key result
enabling the completeness proof: it relates MCS membership to truth in the canonical
model with a shift-closed set of histories.

The proof follows the same structure as `canonical_truth_lemma` but handles
the box case differently, using `box_persistent` and `time_shift_preserves_truth`
to handle shifted canonical histories.

**Port from**: Boneyard/IntRepresentation/Representation.lean (lines 438-553)
-/

/--
Shifted truth lemma: MCS membership iff truth at the canonical model with
shift-closed canonical Omega. The box forward case uses `box_persistent` to
show that Box phi persists to all times, enabling truth at shifted histories
via `time_shift_preserves_truth`.
-/
theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int) :
    φ ∈ fam.mcs t ↔
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t φ := by
  induction φ generalizing fam t with
  | atom p =>
    -- Identical to canonical_truth_lemma (atom case is Omega-independent)
    simp only [truth_at, CanonicalTaskModel, to_history]
    constructor
    · intro h_mem
      exact ⟨True.intro, h_mem⟩
    · intro ⟨_, h_val⟩
      exact h_val
  | bot =>
    simp only [truth_at]
    constructor
    · intro h_mem
      exfalso
      have h_cons := (fam.is_mcs t).1
      have h_deriv : Bimodal.ProofSystem.DerivationTree [Formula.bot] Formula.bot :=
        Bimodal.ProofSystem.DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by simp at hpsi; rw [hpsi]; exact h_mem) ⟨h_deriv⟩
    · intro h; exact h.elim
  | imp ψ χ ih_ψ ih_χ =>
    simp only [truth_at]
    have h_mcs := fam.is_mcs t
    constructor
    · intro h_imp h_ψ_true
      have h_ψ_mem := (ih_ψ fam hfam t).mpr h_ψ_true
      exact (ih_χ fam hfam t).mp (SetMaximalConsistent.implication_property h_mcs h_imp h_ψ_mem)
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : ψ ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_antecedent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.mcs t := by
          have h_taut := neg_imp_implies_neg_consequent ψ χ
          exact SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (Bimodal.ProofSystem.DerivationTree.modus_ponens _ _ _
              (Bimodal.ProofSystem.DerivationTree.weakening [] _ _ h_taut (by intro; simp))
              (Bimodal.ProofSystem.DerivationTree.assumption _ _ (by simp)))
        have h_ψ_true : truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t ψ :=
          (ih_ψ fam hfam t).mp h_ψ_mcs
        have h_χ_true : truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t χ :=
          h_truth_imp h_ψ_true
        have h_χ_mcs : χ ∈ fam.mcs t := (ih_χ fam hfam t).mpr h_χ_true
        exact set_consistent_not_both (fam.is_mcs t).1 χ h_χ_mcs h_neg_χ_mcs
  | box ψ ih =>
    constructor
    · -- Forward: Box ψ ∈ fam.mcs t → ∀ σ ∈ ShiftClosedCanonicalOmega B, truth_at ... σ t ψ
      intro h_box σ h_σ_mem
      -- σ ∈ ShiftClosedCanonicalOmega B means σ = time_shift (to_history fam') delta
      obtain ⟨fam', hfam', delta, h_σ_eq⟩ := h_σ_mem
      -- By box_persistent: Box ψ ∈ fam.mcs (t + delta)
      have h_box_shifted : Formula.box ψ ∈ fam.mcs (t + delta) :=
        box_persistent fam ψ t (t + delta) h_box
      -- By modal_forward: ψ ∈ fam'.mcs (t + delta)
      have h_ψ_fam' : ψ ∈ fam'.mcs (t + delta) :=
        B.modal_forward fam hfam ψ (t + delta) h_box_shifted fam' hfam'
      -- By IH at (fam', hfam', t + delta): truth_at ... (to_history fam') (t + delta) ψ
      have h_truth_canon := (ih fam' hfam' (t + delta)).mp h_ψ_fam'
      -- By time_shift_preserves_truth with shift-closed Omega:
      -- truth_at ... (time_shift (to_history fam') delta) t ψ ↔ truth_at ... (to_history fam') (t + delta) ψ
      have h_preserve := TimeShift.time_shift_preserves_truth
        CanonicalTaskModel (ShiftClosedCanonicalOmega B)
        (shiftClosedCanonicalOmega_is_shift_closed B) (to_history fam')
        t (t + delta) ψ
      -- time_shift_preserves_truth: truth_at ... (time_shift σ (y - x)) x φ ↔ truth_at ... σ y φ
      -- With x = t, y = t + delta: (t+delta) - t = delta
      have h_delta : (t + delta) - t = delta := by omega
      rw [h_σ_eq]
      rw [WorldHistory.time_shift_congr (to_history fam') ((t + delta) - t) delta h_delta] at h_preserve
      exact h_preserve.mpr h_truth_canon
    · -- Backward: (∀ σ ∈ ShiftClosedCanonicalOmega B, truth_at ... σ t ψ) → Box ψ ∈ fam.mcs t
      intro h_all_σ
      -- Only use canonical histories (delta = 0 case)
      have h_all_fam : ∀ fam' ∈ B.families, ψ ∈ fam'.mcs t := by
        intro fam' hfam'
        have h_mem := canonicalOmega_subset_shiftClosed B ⟨fam', hfam', rfl⟩
        exact (ih fam' hfam' t).mpr (h_all_σ (to_history fam') h_mem)
      exact B.modal_backward fam hfam ψ t h_all_fam
  | all_future ψ ih =>
    -- G case: same as canonical_truth_lemma (temporal cases are Omega-independent)
    simp only [truth_at]
    constructor
    · intro h_G s hts
      rcases hts.lt_or_eq with hts_lt | hts_eq
      · have h_psi_mcs : ψ ∈ fam.mcs s := fam.forward_G t s ψ hts_lt h_G
        exact (ih fam hfam s).mp h_psi_mcs
      · rw [← hts_eq]
        have h_T : (ψ.all_future).imp ψ ∈ fam.mcs t :=
          theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
            (Bimodal.ProofSystem.Axiom.temp_t_future ψ))
        have h_psi_mcs := SetMaximalConsistent.implication_property (fam.is_mcs t) h_T h_G
        exact (ih fam hfam t).mp h_psi_mcs
    · intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      have h_all_mcs : ∀ s : Int, t < s → ψ ∈ fam.mcs s := by
        intro s hts
        exact (ih fam hfam s).mpr (h_all s (le_of_lt hts))
      exact temporal_backward_G tcf t ψ h_all_mcs
  | all_past ψ ih =>
    -- H case: same as canonical_truth_lemma (temporal cases are Omega-independent)
    simp only [truth_at]
    constructor
    · intro h_H s hst
      rcases hst.lt_or_eq with hst_lt | hst_eq
      · have h_psi_mcs : ψ ∈ fam.mcs s := fam.backward_H t s ψ hst_lt h_H
        exact (ih fam hfam s).mp h_psi_mcs
      · rw [hst_eq]
        have h_T : (ψ.all_past).imp ψ ∈ fam.mcs t :=
          theorem_in_mcs (fam.is_mcs t) (Bimodal.ProofSystem.DerivationTree.axiom [] _
            (Bimodal.ProofSystem.Axiom.temp_t_past ψ))
        have h_psi_mcs := SetMaximalConsistent.implication_property (fam.is_mcs t) h_T h_H
        exact (ih fam hfam t).mp h_psi_mcs
    · intro h_all
      obtain ⟨h_forward_F, h_backward_P⟩ := h_tc fam hfam
      let tcf : TemporalCoherentFamily Int := {
        toFMCS := fam
        forward_F := h_forward_F
        backward_P := h_backward_P
      }
      have h_all_mcs : ∀ s : Int, s < t → ψ ∈ fam.mcs s := by
        intro s hst
        exact (ih fam hfam s).mpr (h_all s (le_of_lt hst))
      exact temporal_backward_H tcf t ψ h_all_mcs

end Bimodal.Metalogic.Bundle.Canonical
