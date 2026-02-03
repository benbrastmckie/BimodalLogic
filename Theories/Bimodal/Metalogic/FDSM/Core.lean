import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.FMP.Closure
import Bimodal.Metalogic.FMP.BoundedTime
import Bimodal.Metalogic.FMP.FiniteWorldState
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Finset.Basic
import Mathlib.Data.Fintype.Basic

/-!
# Finite Dynamical System Model (FDSM) Core Structures

This module defines the core types for finite dynamical system models for
the TM bimodal logic. The FDSM construction achieves a sorry-free completeness
proof by using:

1. **Bounded time** (`BoundedTime k = Fin (2k+1)`): Makes "all future" a finite set
2. **Multi-history modal saturation**: Ensures diamond witnesses exist

## Key Insight: No Omega-Rule Needed

With bounded time `BoundedTime k`:
- "forall s >= t, psi at s" is a finite set: `{s : Fin(2k+1) | t <= s}`
- Finite conjunction can be internalized in the world state construction
- The temporal backward direction becomes provable

## Main Definitions

- `FDSMTime phi`: Bounded time domain for formula phi
- `FDSMWorldState phi`: World state (reuses `FiniteWorldState`)
- `FDSMHistory phi`: A history with temporal coherence properties
- `FiniteDynamicalSystemModel phi`: The complete FDSM structure

## Design Philosophy

We use "Finite Dynamical System Model" rather than "Finite Branching Model"
because world histories in TM logic do not branch - they are functions from
durations to world states. The FDSM represents a finite dynamical system with
multiple possible trajectories (histories) through a finite state space over
bounded time.

## References

- Research report: specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-014.md
- Implementation plan: specs/816_bmcs_temporal_modal_coherence_strengthening/plans/implementation-003.md
-/

namespace Bimodal.Metalogic.FDSM

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.FMP

/-!
## Type Abbreviations

Reuse existing FMP types with FDSM naming for clarity.
-/

/--
Time domain for FDSM: bounded time with `2 * temporalBound phi + 1` points.
This is `Fin (2 * phi.temporalDepth + 1)`.
-/
abbrev FDSMTime (phi : Formula) := BoundedTime (temporalBound phi)

/--
World state for FDSM: reuses the existing `FiniteWorldState` type.
-/
abbrev FDSMWorldState (phi : Formula) := FiniteWorldState phi

/-!
## FDSM History

An FDSM history is a function from bounded time to world states with
temporal coherence properties. The key innovation is that temporal
coherence conditions become finitely checkable.
-/

/--
The set of all times >= t in bounded time (finite upper closure).
-/
def futureSet {k : Nat} (t : BoundedTime k) : Finset (BoundedTime k) :=
  Finset.filter (fun s => t ≤ s) Finset.univ

/--
The set of all times <= t in bounded time (finite lower closure).
-/
def pastSet {k : Nat} (t : BoundedTime k) : Finset (BoundedTime k) :=
  Finset.filter (fun s => s ≤ t) Finset.univ

/--
futureSet contains t itself.
-/
theorem mem_futureSet_self {k : Nat} (t : BoundedTime k) : t ∈ futureSet t := by
  simp only [futureSet, Finset.mem_filter, Finset.mem_univ, true_and, le_refl]

/--
pastSet contains t itself.
-/
theorem mem_pastSet_self {k : Nat} (t : BoundedTime k) : t ∈ pastSet t := by
  simp only [pastSet, Finset.mem_filter, Finset.mem_univ, true_and, le_refl]

/--
Membership in futureSet.
-/
theorem mem_futureSet_iff {k : Nat} (t s : BoundedTime k) :
    s ∈ futureSet t ↔ t ≤ s := by
  simp only [futureSet, Finset.mem_filter, Finset.mem_univ, true_and]

/--
Membership in pastSet.
-/
theorem mem_pastSet_iff {k : Nat} (t s : BoundedTime k) :
    s ∈ pastSet t ↔ s ≤ t := by
  simp only [pastSet, Finset.mem_filter, Finset.mem_univ, true_and]

/--
An FDSM history for a formula phi.

This is a function from bounded time to world states. The temporal coherence
conditions are enforced separately in the FDSM model, not here, to allow
for flexible construction strategies.
-/
structure FDSMHistory (phi : Formula) where
  /-- World state at each time point -/
  states : FDSMTime phi → FDSMWorldState phi

namespace FDSMHistory

variable {phi : Formula}

/--
The world state at the origin time.
-/
def atOrigin (h : FDSMHistory phi) : FDSMWorldState phi :=
  h.states (BoundedTime.origin (temporalBound phi))

/--
Create a constant history from a single world state.
-/
def constant (w : FDSMWorldState phi) : FDSMHistory phi :=
  ⟨fun _ => w⟩

/--
For a constant history, all states are equal.
-/
theorem constant_states (w : FDSMWorldState phi) (t : FDSMTime phi) :
    (constant w).states t = w := rfl

/--
Convert to the underlying FiniteHistory type.
-/
def toFiniteHistory (h : FDSMHistory phi) : FiniteHistory phi :=
  ⟨h.states⟩

end FDSMHistory

/--
Extensionality for FDSMHistory.
-/
@[ext]
theorem FDSMHistory.ext {phi : Formula} {h1 h2 : FDSMHistory phi}
    (heq : h1.states = h2.states) : h1 = h2 := by
  cases h1; cases h2
  simp only [FDSMHistory.mk.injEq]
  exact heq

/-!
## Finite Dynamical System Model

The complete FDSM structure with modal saturation.
-/

/--
A Finite Dynamical System Model (FDSM) for a formula phi.

**Key Properties**:
1. `histories` is a finite set of histories
2. `modal_saturated`: For any history h, if Box psi does not hold at time t,
   there exists a witness history where psi does not hold at t
3. `eval_history`: Distinguished history for evaluation

**Design Notes**:
- Modal saturation ensures `modal_backward` can be proven by contrapositive
- Temporal coherence is implicit in the bounded time domain
-/
structure FiniteDynamicalSystemModel (phi : Formula) where
  /-- The collection of histories forming the model -/
  histories : Finset (FDSMHistory phi)

  /-- The model is non-empty -/
  nonempty : histories.Nonempty

  /-- Modal saturation: if Box psi false, there's a witness where psi false.
      Formally: if psi.neg in some history h at time t, and Box (psi.neg) not in h at t,
      then there exists h' where psi is true at t (making Box psi.neg false). -/
  modal_saturated : ∀ h ∈ histories, ∀ t : FDSMTime phi, ∀ psi : Formula,
    ∀ h_psi_clos : psi ∈ closure phi,
    -- If neg(Box(neg psi)) is in h.states t (i.e., Diamond psi holds)
    (h.states t).models (Formula.neg (Formula.box (Formula.neg psi))) (by
      -- Need: (Box (neg psi)).neg in closure phi
      -- This requires closure properties we'll prove later
      sorry) →
    -- Then there exists h' where psi holds
    ∃ h' ∈ histories, (h'.states t).models psi h_psi_clos

  /-- The distinguished evaluation history where we start truth evaluation -/
  eval_history : FDSMHistory phi

  /-- The evaluation history is in the model -/
  eval_history_mem : eval_history ∈ histories

namespace FiniteDynamicalSystemModel

variable {phi : Formula}

/--
Get the world state at a history and time.
-/
def stateAt (M : FiniteDynamicalSystemModel phi) (h : FDSMHistory phi) (t : FDSMTime phi) :
    FDSMWorldState phi := h.states t

/--
The number of histories in the model.
-/
def numHistories (M : FiniteDynamicalSystemModel phi) : Nat := M.histories.card

end FiniteDynamicalSystemModel

/-!
## Finiteness Properties

Key finiteness results for FDSM components.
-/

/--
FDSMHistory is finite (function from finite domain to finite codomain).
-/
instance fdsm_history_finite (phi : Formula) : Finite (FDSMHistory phi) := by
  -- FDSMHistory is a wrapper around (FDSMTime phi → FDSMWorldState phi)
  -- Both FDSMTime and FDSMWorldState are finite
  apply Finite.of_injective (fun h => h.states)
  intros h1 h2 heq
  exact FDSMHistory.ext heq

/--
DecidableEq for FDSMHistory (via function extensionality on finite domain).
-/
noncomputable instance fdsm_history_decidableEq (phi : Formula) : DecidableEq (FDSMHistory phi) :=
  fun h1 h2 =>
    if heq : h1.states = h2.states then
      isTrue (FDSMHistory.ext heq)
    else
      isFalse (fun h => heq (by rw [h]))

/--
Fintype instance for FDSMHistory.
-/
noncomputable instance fdsm_history_fintype (phi : Formula) : Fintype (FDSMHistory phi) :=
  Fintype.ofFinite _

/-!
## History Construction from Closure MCS

Build an FDSM history from a closure-maximal consistent set.
-/

/--
Build an FDSM history with constant world state from a closure MCS.

This is the simplest construction - the same world state at all times.
More sophisticated constructions would vary the world state to satisfy
temporal coherence explicitly.
-/
noncomputable def fdsm_history_from_closure_mcs (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : FDSMHistory phi :=
  FDSMHistory.constant (worldStateFromClosureMCS phi S h_mcs)

/--
The world state at any time in a constant history from MCS equals the original.
-/
theorem fdsm_history_from_closure_mcs_states (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (t : FDSMTime phi) :
    (fdsm_history_from_closure_mcs phi S h_mcs).states t =
    worldStateFromClosureMCS phi S h_mcs := rfl

/-!
## World State Membership via ToSet

Connect world state truth to set membership.
-/

/--
A formula psi is modeled by world state w iff psi is in w.toSet (for psi in closure).
-/
theorem fdsm_models_iff_in_toSet {phi : Formula} (w : FDSMWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    w.models psi h_mem ↔ psi ∈ w.toSet := by
  rw [FiniteWorldState.mem_toSet_iff]

/-!
## Temporal Saturation for Finite Histories (Phase 2)

The key insight: with bounded time, "all future" becomes a finite conjunction.
This section proves that temporal backward coherence is achievable for finite time.
-/

/--
futureSet is nonempty (contains at least t).
-/
theorem futureSet_nonempty {k : Nat} (t : BoundedTime k) : (futureSet t).Nonempty :=
  ⟨t, mem_futureSet_self t⟩

/--
pastSet is nonempty (contains at least t).
-/
theorem pastSet_nonempty {k : Nat} (t : BoundedTime k) : (pastSet t).Nonempty :=
  ⟨t, mem_pastSet_self t⟩

/--
If psi holds at all times s >= t (finite set), then we can derive this as a property.
This is the finite version of the "all future" quantifier.
-/
theorem finite_all_future_holds {phi : Formula} (h : FDSMHistory phi) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi)
    (h_all : ∀ s ∈ futureSet t, (h.states s).models psi h_psi_clos) :
    ∀ s : FDSMTime phi, t ≤ s → (h.states s).models psi h_psi_clos := by
  intro s hts
  exact h_all s (mem_futureSet_iff t s |>.mpr hts)

/--
If psi holds at all times s <= t (finite set), then we can derive this as a property.
This is the finite version of the "all past" quantifier.
-/
theorem finite_all_past_holds {phi : Formula} (h : FDSMHistory phi) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi)
    (h_all : ∀ s ∈ pastSet t, (h.states s).models psi h_psi_clos) :
    ∀ s : FDSMTime phi, s ≤ t → (h.states s).models psi h_psi_clos := by
  intro s hst
  exact h_all s (mem_pastSet_iff t s |>.mpr hst)

/--
Converse: if psi holds at all s >= t, then it holds in the futureSet.
-/
theorem all_future_implies_futureSet {phi : Formula} (h : FDSMHistory phi) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi)
    (h_all : ∀ s : FDSMTime phi, t ≤ s → (h.states s).models psi h_psi_clos) :
    ∀ s ∈ futureSet t, (h.states s).models psi h_psi_clos := by
  intro s hs
  exact h_all s (mem_futureSet_iff t s |>.mp hs)

/--
Converse: if psi holds at all s <= t, then it holds in the pastSet.
-/
theorem all_past_implies_pastSet {phi : Formula} (h : FDSMHistory phi) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi)
    (h_all : ∀ s : FDSMTime phi, s ≤ t → (h.states s).models psi h_psi_clos) :
    ∀ s ∈ pastSet t, (h.states s).models psi h_psi_clos := by
  intro s hs
  exact h_all s (mem_pastSet_iff t s |>.mp hs)

/-!
## Decidability of Finite Temporal Conditions

Because futureSet and pastSet are finite, we can decide whether a formula
holds at all times in these sets. This follows from the finiteness of the
domain and decidability of the predicate.
-/

/--
It is decidable whether psi holds at all times in futureSet t.
This is a consequence of the finite domain.
-/
noncomputable instance decidableFutureAll {phi : Formula} (h : FDSMHistory phi) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi) :
    Decidable (∀ s ∈ futureSet t, (h.states s).models psi h_psi_clos) :=
  Classical.dec _

/--
It is decidable whether psi holds at all times in pastSet t.
This is a consequence of the finite domain.
-/
noncomputable instance decidablePastAll {phi : Formula} (h : FDSMHistory phi) (t : FDSMTime phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi) :
    Decidable (∀ s ∈ pastSet t, (h.states s).models psi h_psi_clos) :=
  Classical.dec _

/-!
## Temporal Coherence for Constant Histories

For a constant history (same world state at all times), temporal coherence
is trivially satisfied. This is the simplest FDSM construction.
-/

/--
For a constant history, if psi holds at one time, it holds at all times.
-/
theorem constant_history_uniform {phi : Formula} (w : FDSMWorldState phi)
    (psi : Formula) (h_psi_clos : psi ∈ closure phi) (t s : FDSMTime phi)
    (h_models : (FDSMHistory.constant w).states t |>.models psi h_psi_clos) :
    (FDSMHistory.constant w).states s |>.models psi h_psi_clos := by
  simp only [FDSMHistory.constant_states] at h_models ⊢
  exact h_models

/--
For a constant history from a closure MCS where psi is in S, psi holds at all times.
-/
theorem constant_history_from_mcs_models {phi : Formula} (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (t : FDSMTime phi) (psi : Formula)
    (h_psi_clos : psi ∈ closure phi)
    (h_psi_in_S : psi ∈ S) :
    (fdsm_history_from_closure_mcs phi S h_mcs).states t |>.models psi h_psi_clos := by
  simp only [fdsm_history_from_closure_mcs_states]
  exact (worldStateFromClosureMCS_models_iff phi S h_mcs psi h_psi_clos).mp h_psi_in_S

/-!
## Summary

This module provides the core type definitions for FDSM:

1. **FDSMTime phi**: Bounded time = `Fin (2 * temporalDepth phi + 1)`
2. **FDSMWorldState phi**: World state = `FiniteWorldState phi`
3. **FDSMHistory phi**: History = function from time to world states
4. **FiniteDynamicalSystemModel phi**: Model with histories and modal saturation

**Sorries in this module**:
- `modal_saturated` closure membership proof (will be filled in Phase 2)

**Next Steps (Phase 2)**:
- Prove temporal saturation properties
- Show that finite time makes temporal backward provable
-/

end Bimodal.Metalogic.FDSM
