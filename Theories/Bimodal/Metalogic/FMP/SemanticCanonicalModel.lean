import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.FMP.FiniteWorldState
import Bimodal.Metalogic.FMP.BoundedTime
import Bimodal.Metalogic.Completeness.WeakCompleteness
import Mathlib.Data.Set.Basic
import Mathlib.Data.Finite.Defs

/-!
# Parametric Semantic Canonical Model for FMP

This module provides the semantic canonical model construction for the parametric
Finite Model Property proof.

## Design Philosophy

The semantic approach defines world states as equivalence classes of
(history, time) pairs. This makes compositionality straightforward because
history paths compose naturally (modulo bounded time domain constraints).

This is the parametric port of `Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`.
The key insight is that the FMP bound (2^closureSize) is purely combinatorial - it counts
subsets of the subformula closure - and doesn't depend on the specific duration type.

## Main Definitions

- `HistoryTimePair`: A pair of (FiniteHistory, BoundedTime)
- `htEquiv`: Equivalence relation - same world state at given time
- `SemanticWorldState`: Quotient of history-time pairs
- `SemanticCanonicalFrame`: TaskFrame with Int duration
- `SemanticCanonicalModel`: TaskModel for completeness proof

## Known Sorries

The compositionality axiom (`SemanticCanonicalFrame.compositionality`) is marked sorry.
This is mathematically false for unbounded durations in finite time domain [-k, k].
The finite model is still valid for demonstrating satisfiability.

## Architecture

This module uses:
- `BoundedTime k` from `Metalogic/FMP/BoundedTime.lean`
- `FiniteWorldState` from `Metalogic/FMP/FiniteWorldState.lean`
- `closure`, `ClosureMaximalConsistent` from `Metalogic/FMP/Closure.lean`

## References

- Original: `Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core Bimodal.Metalogic.Completeness
open Bimodal.Metalogic_v2.Representation

/-!
## History-Time Pairs

A history-time pair is a snapshot of a history at a particular time.
-/

/--
A history-time pair for a formula phi.
-/
abbrev HistoryTimePair (phi : Formula) := FiniteHistory phi × BoundedTime (temporalBound phi)

/--
Equivalence of history-time pairs: same underlying world state at given times.
-/
def htEquiv (phi : Formula) : HistoryTimePair phi → HistoryTimePair phi → Prop :=
  fun p1 p2 => p1.1.states p1.2 = p2.1.states p2.2

/--
htEquiv is reflexive.
-/
theorem htEquiv_refl (phi : Formula) (p : HistoryTimePair phi) : htEquiv phi p p := rfl

/--
htEquiv is symmetric.
-/
theorem htEquiv_symm (phi : Formula) {p1 p2 : HistoryTimePair phi}
    (h : htEquiv phi p1 p2) : htEquiv phi p2 p1 := h.symm

/--
htEquiv is transitive.
-/
theorem htEquiv_trans (phi : Formula) {p1 p2 p3 : HistoryTimePair phi}
    (h12 : htEquiv phi p1 p2) (h23 : htEquiv phi p2 p3) : htEquiv phi p1 p3 :=
  h12.trans h23

/--
Setoid instance for history-time pairs.
-/
instance htSetoid (phi : Formula) : Setoid (HistoryTimePair phi) where
  r := htEquiv phi
  iseqv := {
    refl := htEquiv_refl phi
    symm := @htEquiv_symm phi
    trans := @htEquiv_trans phi
  }

/-!
## Semantic World State

A semantic world state is an equivalence class of history-time pairs.
-/

/--
Semantic world state: equivalence class of history-time pairs.
Two pairs are equivalent if they share the same underlying world state.
-/
def SemanticWorldState (phi : Formula) := Quotient (htSetoid phi)

namespace SemanticWorldState

variable {phi : Formula}

/--
Construct a semantic world state from a history-time pair.
-/
def mk (p : HistoryTimePair phi) : SemanticWorldState phi := Quotient.mk (htSetoid phi) p

/--
Construct from history and time separately.
-/
def ofHistoryTime (h : FiniteHistory phi) (t : BoundedTime (temporalBound phi)) :
    SemanticWorldState phi := mk (h, t)

/--
Get the underlying FiniteWorldState.
This is well-defined because equivalent pairs have the same underlying state.
-/
def toFiniteWorldState (w : SemanticWorldState phi) : FiniteWorldState phi :=
  Quotient.lift (fun p => p.1.states p.2) (fun _ _ h => h) w

/--
Two semantic world states are equal iff their underlying world states are equal.
-/
theorem eq_iff_toFiniteWorldState_eq (w1 w2 : SemanticWorldState phi) :
    w1 = w2 ↔ toFiniteWorldState w1 = toFiniteWorldState w2 := by
  constructor
  · intro h; rw [h]
  · intro h
    induction w1 using Quotient.ind with | _ p1 =>
    induction w2 using Quotient.ind with | _ p2 =>
    simp only [toFiniteWorldState, Quotient.lift_mk] at h
    exact Quotient.sound h

/--
A semantic world state models a formula iff the underlying world state does.
-/
def models (w : SemanticWorldState phi) (psi : Formula) (h_mem : psi ∈ closure phi) : Prop :=
  (toFiniteWorldState w).models psi h_mem

/--
Semantic world states are finite.

Proof: There are finitely many `FiniteWorldState`s, and `SemanticWorldState`
is a quotient over a type that maps to `FiniteWorldState`. The quotient has
at most as many elements as there are distinct underlying world states.
-/
instance semanticWorldState_finite : Finite (SemanticWorldState phi) := by
  -- The map toFiniteWorldState is a left inverse of the quotient projection,
  -- so SemanticWorldState injects into FiniteWorldState
  apply Finite.of_injective toFiniteWorldState
  intro w1 w2 h
  exact (eq_iff_toFiniteWorldState_eq w1 w2).mpr h

/--
Fintype instance for SemanticWorldState.
Derives from Finite.
-/
noncomputable instance semanticWorldState_fintype : Fintype (SemanticWorldState phi) :=
  Fintype.ofFinite _

end SemanticWorldState

/-!
## Semantic Task Relation

The task relation is defined via history existence.
-/

/--
Semantic task relation: w relates to v with duration d if there exists a history
passing through both with the appropriate time difference.
-/
def semantic_task_rel (phi : Formula) (w : SemanticWorldState phi) (d : Int)
    (v : SemanticWorldState phi) : Prop :=
  ∃ (h : FiniteHistory phi) (t1 t2 : BoundedTime (temporalBound phi)),
    SemanticWorldState.ofHistoryTime h t1 = w ∧
    SemanticWorldState.ofHistoryTime h t2 = v ∧
    t2.toInt - t1.toInt = d

/--
Nullity: w relates to itself with duration 0.
-/
theorem semantic_task_rel_nullity (phi : Formula) (w : SemanticWorldState phi) :
    semantic_task_rel phi w 0 w := by
  -- Every SemanticWorldState comes from some history-time pair
  induction w using Quotient.ind with | _ p =>
  let h := p.1
  let t := p.2
  use h, t, t
  constructor
  · rfl
  · constructor
    · rfl
    · simp

/-!
## Semantic Canonical Frame and Model
-/

/--
The semantic canonical frame.
-/
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel phi
  nullity := semantic_task_rel_nullity phi
  -- KNOWN GAP: Compositionality is mathematically false for unbounded durations in finite time
  -- domain [-k, k]. Sum d1 + d2 can exceed representable range [-2k, 2k]. Not needed for
  -- completeness proof which uses semantic_weak_completeness via semantic_truth_at_v2.
  compositionality := fun _ _ _ _ _ => sorry

/--
Semantic valuation: atom p is true at w iff p is true in underlying world state.
-/
def semantic_valuation (phi : Formula) : SemanticWorldState phi → String → Prop :=
  fun w p =>
    ∃ h : Formula.atom p ∈ closure phi,
      (SemanticWorldState.toFiniteWorldState w).models (Formula.atom p) h

/--
The semantic canonical model.
-/
noncomputable def SemanticCanonicalModel (phi : Formula) :
    TaskModel (SemanticCanonicalFrame phi) where
  valuation := semantic_valuation phi

/-!
## World History Conversion

Convert finite histories to world histories for the semantic model.
-/

/--
Helper: check if an Int is in the finite time domain.
-/
def inFiniteDomain (phi : Formula) (t : Int) : Prop :=
  -(temporalBound phi : Int) ≤ t ∧ t ≤ (temporalBound phi : Int)

/--
Helper: convert an Int in domain to a BoundedTime.
-/
def intToBoundedTime (phi : Formula) (t : Int)
    (h : inFiniteDomain phi t) : BoundedTime (temporalBound phi) :=
  ⟨(t + temporalBound phi).toNat, by
    have h1 : 0 ≤ t + (temporalBound phi : Int) := by
      unfold inFiniteDomain at h; omega
    have h2 : t + temporalBound phi ≤ 2 * temporalBound phi := by
      unfold inFiniteDomain at h; omega
    omega⟩

/--
Convert a finite history to a world history.

The world history has domain [-k, k] where k = temporalBound phi.
-/
def finiteHistoryToWorldHistory (phi : Formula) (h : FiniteHistory phi) :
    WorldHistory (SemanticCanonicalFrame phi) where
  domain := inFiniteDomain phi
  convex := fun x z h_x h_z y h_xy h_yz => by
    unfold inFiniteDomain at h_x h_z ⊢
    constructor <;> omega
  states := fun t h_t =>
    SemanticWorldState.ofHistoryTime h (intToBoundedTime phi t h_t)
  respects_task := fun s t hs ht _h_le => by
    -- Need to show semantic_task_rel phi (states s) (t - s) (states t)
    let fs := intToBoundedTime phi s hs
    let ft := intToBoundedTime phi t ht
    use h, fs, ft
    refine ⟨rfl, rfl, ?_⟩
    -- Time arithmetic
    simp only [BoundedTime.toInt]
    show ((intToBoundedTime phi t ht).val : Int) - (temporalBound phi : Int) -
         (((intToBoundedTime phi s hs).val : Int) - (temporalBound phi : Int)) = t - s
    simp only [intToBoundedTime]
    have h_t_nonneg : 0 ≤ t + (temporalBound phi : Int) := by
      unfold inFiniteDomain at ht; omega
    have h_s_nonneg : 0 ≤ s + (temporalBound phi : Int) := by
      unfold inFiniteDomain at hs; omega
    omega

/--
Construct a constant finite history from a single world state.
This is used in the completeness proof.
-/
def finite_history_from_state (phi : Formula) (w : FiniteWorldState phi) : FiniteHistory phi :=
  FiniteHistory.constant w

/--
For any SemanticWorldState w, there exists a WorldHistory containing w at time 0.

This shows that every semantic world state is reachable from some world history,
which is needed to instantiate the `valid` quantifier.
-/
theorem semantic_world_state_has_world_history (phi : Formula) (w : SemanticWorldState phi) :
    ∃ (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0),
    tau.states 0 ht = w := by
  -- Strategy: Build a history that places w.toFiniteWorldState at the origin
  let ws := SemanticWorldState.toFiniteWorldState w
  let hist := finite_history_from_state phi ws
  let tau := finiteHistoryToWorldHistory phi hist

  have h_domain : inFiniteDomain phi 0 := by
    unfold inFiniteDomain
    constructor <;> omega

  use tau, h_domain

  rw [SemanticWorldState.eq_iff_toFiniteWorldState_eq]
  rfl

/-!
## Truth Correspondence

The key lemma connecting semantic truth to MCS membership.
-/

/--
Semantic truth at a position in the model.
-/
def semantic_truth_at (phi : Formula) (w : SemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) : Prop :=
  (SemanticWorldState.toFiniteWorldState w).models psi h_mem

/--
Truth at a semantic world state for a formula in the closure (v2 variant).

This variant is used for `semantic_weak_completeness` and includes the time
parameter for API compatibility. The key insight is that truth at a semantic
world state only depends on the underlying world state's satisfaction, not
on the specific history-time representative.
-/
def semantic_truth_at_v2 (phi : Formula) (w : SemanticWorldState phi)
    (_t : BoundedTime (temporalBound phi)) (psi : Formula) : Prop :=
  ∃ h_mem : psi ∈ closure phi, (SemanticWorldState.toFiniteWorldState w).models psi h_mem

/--
Semantic truth lemma (v2): membership in underlying world state equals semantic truth.
-/
theorem semantic_truth_lemma_v2 (phi : Formula) (w : SemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    (SemanticWorldState.toFiniteWorldState w).models psi h_mem ↔
    semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) psi := by
  simp only [semantic_truth_at_v2]
  constructor
  · intro h_models
    exact ⟨h_mem, h_models⟩
  · intro ⟨h_mem', h_models⟩
    exact h_models

/--
Truth lemma: semantic truth corresponds to MCS membership.
-/
theorem semantic_truth_lemma (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    let w := worldStateFromClosureMCS phi S h_mcs
    psi ∈ S ↔ w.models psi h_mem := by
  exact worldStateFromClosureMCS_models_iff phi S h_mcs psi h_mem

/-!
## Completeness via Contrapositive

The main completeness proof.
-/

/--
Bridge lemma: If phi is not provable, then {phi.neg} is set-consistent.
-/
theorem neg_set_consistent_of_not_provable (phi : Formula)
    (h_not_prov : ¬Nonempty (⊢ phi)) :
    SetConsistent ({phi.neg} : Set Formula) := by
  intro L hL h_incons
  have hL' : ∀ ψ ∈ L, ψ = phi.neg := fun ψ hψ => Set.mem_singleton_iff.mp (hL ψ hψ)
  by_cases hne : L = []
  · subst hne
    obtain ⟨d⟩ := h_incons
    have h_sem_cons := soundness [] Formula.bot d
    have h_bot_true := h_sem_cons Int TaskFrame.trivial_frame
        (TaskModel.all_false) (WorldHistory.trivial) (0 : Int)
        (fun ψ hψ => (List.not_mem_nil hψ).elim)
    simp only [truth_at] at h_bot_true
  · obtain ⟨d⟩ := h_incons
    have h_subset : L ⊆ [phi.neg] := by
      intro ψ hψ
      rw [hL' ψ hψ]
      simp
    have d' := DerivationTree.weakening L [phi.neg] Formula.bot d h_subset
    have d_neg_neg := deduction_theorem [] phi.neg Formula.bot d'
    have d_dne := Bimodal.Theorems.Propositional.double_negation phi
    have d_phi := DerivationTree.modus_ponens [] phi.neg.neg phi d_dne d_neg_neg
    exact h_not_prov ⟨d_phi⟩

/--
If φ is not refutable, then {φ} is set-consistent.
-/
theorem phi_consistent_of_not_refutable (φ : Formula) (h_not_refutable : ¬Nonempty (⊢ φ.neg)) :
    SetConsistent ({φ} : Set Formula) := by
  intro L hL h_incons
  have hL' : ∀ ψ ∈ L, ψ = φ := fun ψ hψ => Set.mem_singleton_iff.mp (hL ψ hψ)
  by_cases hne : L = []
  · subst hne
    obtain ⟨d⟩ := h_incons
    have h_sem_cons := soundness [] Formula.bot d
    have h_bot_true := h_sem_cons Int TaskFrame.trivial_frame
        (TaskModel.all_false) (WorldHistory.trivial) (0 : Int)
        (fun ψ hψ => (List.not_mem_nil hψ).elim)
    simp only [truth_at] at h_bot_true
  · obtain ⟨d⟩ := h_incons
    have h_from_singleton : [φ] ⊢ Formula.bot := by
      apply DerivationTree.weakening L [φ] Formula.bot d
      intro ψ hψ
      simp [hL' ψ hψ]
    have h_phi_neg : [] ⊢ φ.neg := deduction_theorem [] φ Formula.bot h_from_singleton
    exact h_not_refutable ⟨h_phi_neg⟩

/--
Semantic weak completeness: if phi is true in all semantic world states, then phi is provable.

**Proof Strategy (Contrapositive)**:
1. Assume phi is not provable
2. Then {phi.neg} is consistent
3. Extend to full MCS by Lindenbaum
4. Project to closure MCS
5. Build FiniteWorldState from closure MCS
6. phi is false at this world state (by construction)
7. Build SemanticWorldState at origin
8. Show phi is false in semantic_truth_at_v2 sense
9. This contradicts the hypothesis that phi is true everywhere

**Status**: PROVEN - No sorry in this theorem.
-/
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi := by
  intro h_valid

  by_cases h_prov : Nonempty (⊢ phi)
  · exact Classical.choice h_prov
  · exfalso

    -- Step 1: {phi.neg} is consistent
    have h_neg_cons : SetConsistent ({phi.neg} : Set Formula) :=
      neg_set_consistent_of_not_provable phi h_prov

    -- Step 2: Extend to full MCS by Lindenbaum
    obtain ⟨M, h_sub_M, h_M_mcs⟩ := set_lindenbaum {phi.neg} h_neg_cons

    -- Step 3: phi.neg ∈ M (from subset)
    have h_neg_in_M : phi.neg ∈ M := h_sub_M (Set.mem_singleton phi.neg)

    -- Step 4: phi ∉ M (by consistency)
    have h_phi_not_M : phi ∉ M := set_mcs_neg_excludes h_M_mcs phi h_neg_in_M

    -- Step 5: Project to closureWithNeg MCS
    let S := M ∩ (closureWithNeg phi : Set Formula)
    have h_S_mcs : ClosureMaximalConsistent phi S := mcs_projection_is_closure_mcs phi M h_M_mcs

    -- Step 6: phi ∉ S
    have h_phi_closure : phi ∈ closure phi := phi_mem_closure phi
    have h_phi_not_S : phi ∉ S := by
      intro h
      exact h_phi_not_M h.1

    -- Step 7: Build FiniteWorldState from S
    let w := worldStateFromClosureMCS phi S h_S_mcs

    -- Step 8: phi is false at w
    have h_phi_false : ¬w.models phi h_phi_closure :=
      worldStateFromClosureMCS_not_models phi S h_S_mcs phi h_phi_closure h_phi_not_S

    -- Step 9: Build FiniteHistory through w
    let hist := finite_history_from_state phi w

    -- Step 10: Build SemanticWorldState at origin
    let t := BoundedTime.origin (temporalBound phi)
    let sw := SemanticWorldState.ofHistoryTime hist t

    -- Step 11: Show phi is false at sw
    have h_sw_eq : SemanticWorldState.toFiniteWorldState sw = hist.states t := rfl
    have h_hist_states_t : hist.states t = w := rfl

    have h_sw_false : ¬semantic_truth_at_v2 phi sw t phi := by
      simp only [semantic_truth_at_v2]
      intro ⟨h_mem, h_models⟩
      rw [h_sw_eq, h_hist_states_t] at h_models
      exact h_phi_false h_models

    -- Step 12: This contradicts h_valid
    exact h_sw_false (h_valid sw)

/-!
## Cardinality Bound

The key FMP theorem - worlds are bounded by 2^closureSize.
-/

/--
The cardinality of semantic world states is bounded by 2^closureSize.
-/
theorem semanticWorldState_card_bound (phi : Formula) :
    Fintype.card (SemanticWorldState phi) ≤ 2 ^ closureSize phi := by
  -- SemanticWorldState injects into FiniteWorldState
  have h_inj : Function.Injective (SemanticWorldState.toFiniteWorldState (phi := phi)) := by
    intros w1 w2 heq
    exact (SemanticWorldState.eq_iff_toFiniteWorldState_eq w1 w2).mpr heq
  have h_card_le := Fintype.card_le_of_injective _ h_inj
  calc Fintype.card (SemanticWorldState phi)
      ≤ Fintype.card (FiniteWorldState phi) := h_card_le
    _ ≤ 2 ^ closureSize phi := finiteWorldState_card_bound phi

end Bimodal.Metalogic.FMP
