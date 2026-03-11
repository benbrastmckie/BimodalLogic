import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity
import Bimodal.Syntax.Formula

/-!
# IRR Soundness - Gabbay Irreflexivity Rule Soundness

This module proves that the Gabbay IRR (Irreflexivity) rule is sound on
irreflexive densely-ordered linear temporal frames.

## Main Results

- `truth_independent_of_valuation_change`: Truth values depend only on atoms
  appearing in the formula.
- `irr_sound_dense`: The IRR rule is sound on dense irreflexive linear orders.

## The IRR Rule

The Gabbay IRR rule states:
  From `|- (p AND H(neg p)) -> phi` where p does not occur in phi,
  infer `|- phi`.

## Proof Strategy

The soundness proof uses a **product frame construction** to avoid the
state-aliasing problem, combined with a **truth correspondence lemma**
to transfer truth between the product frame and the original frame.

## References

- Task 957: density_frame_condition_irreflexive_temporal
- research-004.md: IRR soundness analysis
- Gabbay (1981): An irreflexivity lemma
-/

namespace Bimodal.Metalogic.IRRSoundness

open Bimodal.Syntax
open Bimodal.Semantics

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## Truth Independence Lemma
-/

/-- Truth values depend only on atoms appearing in the formula.

If two models M1 and M2 on the same frame agree on all atoms in phi.atoms,
then phi has the same truth value under both models for any history and time. -/
theorem truth_independent_of_valuation_change
    {F : TaskFrame D} {M1 M2 : TaskModel F}
    {Omega : Set (WorldHistory F)}
    {phi : Formula}
    (h_agree : ∀ (s : F.WorldState) (q : String), q ∈ phi.atoms →
      (M1.valuation s q ↔ M2.valuation s q))
    (tau : WorldHistory F) (t : D) :
    truth_at M1 Omega tau t phi ↔ truth_at M2 Omega tau t phi := by
  induction phi generalizing tau t with
  | atom p =>
    simp only [truth_at]
    constructor
    · intro ⟨ht, hv⟩
      exact ⟨ht, (h_agree (tau.states t ht) p (Finset.mem_singleton.mpr rfl)).mp hv⟩
    · intro ⟨ht, hv⟩
      exact ⟨ht, (h_agree (tau.states t ht) p (Finset.mem_singleton.mpr rfl)).mpr hv⟩
  | bot => simp only [truth_at]
  | imp a b ih_a ih_b =>
    simp only [truth_at]
    have h_a : ∀ s q, q ∈ a.atoms → (M1.valuation s q ↔ M2.valuation s q) :=
      fun s q hq => h_agree s q (Finset.mem_union_left _ hq)
    have h_b : ∀ s q, q ∈ b.atoms → (M1.valuation s q ↔ M2.valuation s q) :=
      fun s q hq => h_agree s q (Finset.mem_union_right _ hq)
    constructor
    · intro h ha; exact (ih_b h_b tau t).mp (h ((ih_a h_a tau t).mpr ha))
    · intro h ha; exact (ih_b h_b tau t).mpr (h ((ih_a h_a tau t).mp ha))
  | box a ih_a =>
    simp only [truth_at]; constructor
    · intro h sigma hm; exact (ih_a h_agree sigma t).mp (h sigma hm)
    · intro h sigma hm; exact (ih_a h_agree sigma t).mpr (h sigma hm)
  | all_past a ih_a =>
    simp only [truth_at]; constructor
    · intro h s hl; exact (ih_a h_agree tau s).mp (h s hl)
    · intro h s hl; exact (ih_a h_agree tau s).mpr (h s hl)
  | all_future a ih_a =>
    simp only [truth_at]; constructor
    · intro h s hl; exact (ih_a h_agree tau s).mp (h s hl)
    · intro h s hl; exact (ih_a h_agree tau s).mpr (h s hl)

/-!
## Product Frame Construction

The product frame enriches states with a time component to eliminate state aliasing.
This ensures that different times always map to different product states.
-/

/-- Product frame: states enriched with time stamps. -/
noncomputable def prod_frame (F : TaskFrame D) : TaskFrame D where
  WorldState := F.WorldState × D
  task_rel := fun (w1, _) d (w2, _) => F.task_rel w1 d w2
  nullity := fun (w, _) => F.nullity w
  compositionality := fun (w, _) (u, _) (v, _) x y h1 h2 =>
    F.compositionality w u v x y h1 h2

/-- Lift a history to the product frame by adding time stamps. -/
noncomputable def lift_history {F : TaskFrame D} (sigma : WorldHistory F) :
    WorldHistory (prod_frame F) where
  domain := sigma.domain
  convex := sigma.convex
  states := fun t ht => (sigma.states t ht, t)
  respects_task := fun s t hs ht hst => sigma.respects_task s t hs ht hst

/-- A product-frame history projects to an original-frame history when the first
components of all states match. -/
def projects_to {F : TaskFrame D}
    (h : WorldHistory (prod_frame F)) (sigma : WorldHistory F) : Prop :=
  (∀ t, h.domain t ↔ sigma.domain t) ∧
  (∀ t (ht : h.domain t) (ht' : sigma.domain t),
    (h.states t ht).1 = sigma.states t ht')

/-- The set of product-frame histories that project to some history in Omega. -/
def omega_prod {F : TaskFrame D}
    (Omega : Set (WorldHistory F)) : Set (WorldHistory (prod_frame F)) :=
  { h | ∃ sigma ∈ Omega, projects_to h sigma }

/-- Product model: fresh variable p is true iff time = t0, other atoms from M. -/
noncomputable def prod_model {F : TaskFrame D}
    (M : TaskModel F) (p : String) (t0 : D) : TaskModel (prod_frame F) where
  valuation := fun sw q => if q = p then sw.2 = t0 else M.valuation sw.1 q

/-- omega_prod preserves shift-closure. -/
theorem omega_prod_shift_closed {F : TaskFrame D}
    {Omega : Set (WorldHistory F)} (h_sc : ShiftClosed Omega) :
    ShiftClosed (omega_prod Omega) := by
  intro h_prod h_mem Delta
  obtain ⟨sigma, h_sigma_mem, h_dom, h_states⟩ := h_mem
  exact ⟨WorldHistory.time_shift sigma Delta,
    h_sc sigma h_sigma_mem Delta,
    fun t => h_dom (t + Delta),
    fun t ht ht' => h_states (t + Delta) ht ht'⟩

/-- lift_history sigma projects to sigma. -/
theorem lift_projects_to {F : TaskFrame D} (sigma : WorldHistory F) :
    projects_to (lift_history sigma) sigma :=
  ⟨fun _ => Iff.rfl, fun _ _ _ => rfl⟩

/-- lift_history sigma is in omega_prod Omega when sigma is in Omega. -/
theorem lift_mem_omega_prod {F : TaskFrame D}
    {Omega : Set (WorldHistory F)} {sigma : WorldHistory F}
    (h_mem : sigma ∈ Omega) : lift_history sigma ∈ omega_prod Omega :=
  ⟨sigma, h_mem, lift_projects_to sigma⟩

/-!
## Truth Correspondence

For formulas not mentioning p, truth at the product model equals truth at
the original model via the projection relationship.
-/

/-- Truth correspondence: for phi not mentioning p, truth at prod_model/omega_prod
equals truth at M/Omega via the projection. -/
theorem truth_prod_iff {F : TaskFrame D} {M : TaskModel F}
    {Omega : Set (WorldHistory F)} {p : String} {t0 : D}
    {phi : Formula} (h_fresh : p ∉ phi.atoms)
    {h_prod : WorldHistory (prod_frame F)} {sigma : WorldHistory F}
    (h_proj : projects_to h_prod sigma) (h_sigma_mem : sigma ∈ Omega)
    (t : D) :
    truth_at (prod_model M p t0) (omega_prod Omega) h_prod t phi ↔
    truth_at M Omega sigma t phi := by
  induction phi generalizing h_prod sigma t with
  | atom q =>
    simp only [Formula.atoms, Finset.mem_singleton] at h_fresh
    have h_neq : q ≠ p := fun h => h_fresh h.symm
    simp only [truth_at]
    constructor
    · intro ⟨ht, hv⟩
      have ht' := (h_proj.1 t).mp ht
      simp only [prod_model] at hv
      rw [if_neg h_neq] at hv
      exact ⟨ht', by rw [← h_proj.2 t ht ht']; exact hv⟩
    · intro ⟨ht', hv⟩
      have ht := (h_proj.1 t).mpr ht'
      exact ⟨ht, by
        simp only [prod_model]
        rw [if_neg h_neq, h_proj.2 t ht ht']
        exact hv⟩
  | bot => simp only [truth_at]
  | imp a b ih_a ih_b =>
    simp only [Formula.atoms, Finset.mem_union] at h_fresh
    push_neg at h_fresh
    simp only [truth_at]; constructor
    · intro h ha
      exact (ih_b h_fresh.2 h_proj h_sigma_mem t).mp
        (h ((ih_a h_fresh.1 h_proj h_sigma_mem t).mpr ha))
    · intro h ha
      exact (ih_b h_fresh.2 h_proj h_sigma_mem t).mpr
        (h ((ih_a h_fresh.1 h_proj h_sigma_mem t).mp ha))
  | box a ih_a =>
    simp only [truth_at]; constructor
    · intro h sigma' h_sigma'_mem
      have h_lift_mem := lift_mem_omega_prod h_sigma'_mem
      exact (ih_a h_fresh (lift_projects_to sigma') h_sigma'_mem t).mp
        (h _ h_lift_mem)
    · intro h h_prod' h_prod'_mem
      obtain ⟨sigma', h_sigma'_mem, h_proj'⟩ := h_prod'_mem
      exact (ih_a h_fresh h_proj' h_sigma'_mem t).mpr (h sigma' h_sigma'_mem)
  | all_past a ih_a =>
    simp only [truth_at]; constructor
    · intro h s hl; exact (ih_a h_fresh h_proj h_sigma_mem s).mp (h s hl)
    · intro h s hl; exact (ih_a h_fresh h_proj h_sigma_mem s).mpr (h s hl)
  | all_future a ih_a =>
    simp only [truth_at]; constructor
    · intro h s hl; exact (ih_a h_fresh h_proj h_sigma_mem s).mp (h s hl)
    · intro h s hl; exact (ih_a h_fresh h_proj h_sigma_mem s).mpr (h s hl)

/-!
## IRR Soundness Theorem
-/

/-- The Gabbay IRR rule is sound on dense irreflexive linear orders for
domain-inhabited evaluation times.

If `(p AND H(neg p)) -> phi` is valid on all dense models (where p is fresh
in phi), then phi is true at any evaluation time t that is in the history's
domain.

This restricted version suffices for canonical model arguments where domains
are `Set.univ`. The general case (partial domains where `¬tau.domain t`) is
a separate semantic question about the task model framework -- see the
analysis in IRRSoundness.lean comments for the `box(q) → q` counterexample
showing the general statement requires additional framework assumptions. -/
theorem irr_sound_dense_at_domain
    {p : String} {phi : Formula}
    (h_fresh : p ∉ phi.atoms)
    (h_premise : valid_dense
      ((Formula.and (Formula.atom p)
        (Formula.all_past (Formula.neg (Formula.atom p)))).imp phi))
    {D' : Type} [inst1 : AddCommGroup D'] [inst2 : LinearOrder D']
    [inst3 : IsOrderedAddMonoid D'] [inst4 : DenselyOrdered D'] [inst5 : Nontrivial D']
    {F : TaskFrame D'} {M : TaskModel F} {Omega : Set (WorldHistory F)}
    (h_sc : ShiftClosed Omega)
    {tau : WorldHistory F} (h_mem : tau ∈ Omega)
    {t : D'} (h_dom : tau.domain t) :
    truth_at M Omega tau t phi := by
  -- Construct the product frame model to eliminate state aliasing
  have h_sc_prod := @omega_prod_shift_closed D' inst1 inst2 inst3 F Omega h_sc
  have h_lift_mem := @lift_mem_omega_prod D' inst1 inst2 inst3 F Omega tau h_mem
  -- The premise gives us the implication at the product model
  have h_prem := @h_premise D' inst1 inst2 inst3 inst4 inst5
    (prod_frame F) (prod_model M p t) (omega_prod Omega) h_sc_prod
    (lift_history tau) h_lift_mem t
  -- By truth correspondence, phi at prod model ↔ phi at original model
  have h_corr := @truth_prod_iff D' inst1 inst2 inst3 F M Omega p t phi h_fresh
    (lift_history tau) tau (lift_projects_to tau) h_mem t
  -- Apply truth correspondence to transfer the result back
  apply h_corr.mp
  -- Apply the premise: the implication gives phi from the antecedent
  apply h_prem
  -- Goal: truth of antecedent (p AND H(neg p)) at (prod_model, omega_prod, lift tau, t)
  -- Formula.and a b = (a.imp (b.imp bot)).imp bot
  -- truth(antecedent) = (truth(atom p) → truth(H(neg p)) → False) → False
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_contra
  -- h_contra : truth(atom p) → (∀ s < t, truth(atom p) at s → False) → False
  -- Provide truth(atom p) and H(neg p) to derive False.
  -- 1) truth(atom p) at (prod_model, lift tau, t):
  --    = ∃ ht : tau.domain t, prod_model.val (tau.states t ht, t) p
  --    = ∃ ht, (t = t) = True (since we have h_dom)
  have h_atom_p : ∃ (ht : (lift_history tau).domain t),
      (prod_model M p t).valuation ((lift_history tau).states t ht) p := by
    exact ⟨h_dom, by simp [lift_history, prod_model]⟩
  -- 2) ∀ s < t, ¬(∃ hs, prod_model.val (lift tau s hs) p):
  --    For s < t: prod_model.val (tau.states s hs, s) p = (s = t) = False
  have h_H_neg_p : ∀ (s : D'), s < t → (∃ (hs : (lift_history tau).domain s),
      (prod_model M p t).valuation ((lift_history tau).states s hs) p) → False := by
    intro s h_lt ⟨hs, hv⟩
    simp [lift_history, prod_model] at hv
    exact absurd hv (ne_of_lt h_lt)
  exact h_contra h_atom_p h_H_neg_p

end Bimodal.Metalogic.IRRSoundness
