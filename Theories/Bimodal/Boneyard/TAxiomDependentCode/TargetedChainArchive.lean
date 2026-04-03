/-
  ARCHIVED: T-Axiom Dependent Code from TargetedChain.lean
  Date: 2026-04-03
  Reason: These functions depend on the T-axiom (G(phi) -> phi / H(phi) -> phi),
          which is NOT valid under strict temporal semantics.
  Source: Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean
  Task: 83 Phase 1

  This file does NOT compile. It is preserved for historical reference only.
-/

-- ORIGINAL: lines 236-271
/--
G(phi) in forward_chain(n) implies phi in forward_chain(m) for all m >= n.
-/
theorem targeted_forward_chain_forward_G
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n m : Nat) (phi : Formula)
    (h_le : n ≤ m)
    (h_G : Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets n) :
    phi ∈ targeted_forward_chain M0 h_mcs targets m := by
  -- G(phi) propagates forward: G(phi) → G(G(phi)) by temp_4, then G_step gives G(phi) at n+1
  -- So by induction G(phi) at n implies G(phi) at any m >= n.
  -- Then phi at m by T-axiom.
  suffices h_prop : ∀ j : Nat, Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets (n + j) by
    have h_at_m : Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets m := by
      have ⟨d, hd⟩ : ∃ d, m = n + d := ⟨m - n, by omega⟩
      rw [hd]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_forward_chain_mcs M0 h_mcs targets m)
      (theorem_in_mcs (targeted_forward_chain_mcs M0 h_mcs targets m)
        (sorry /- was: temp_t_future phi -/))
      h_at_m
  intro j
  induction j with
  | zero => simp; exact h_G
  | succ j ih =>
    have h_GG : Formula.all_future (Formula.all_future phi) ∈
        targeted_forward_chain M0 h_mcs targets (n + j) :=
      SetMaximalConsistent.implication_property
        (targeted_forward_chain_mcs M0 h_mcs targets (n + j))
        (theorem_in_mcs (targeted_forward_chain_mcs M0 h_mcs targets (n + j))
          (DerivationTree.axiom _ _ (Axiom.temp_4 phi)))
        ih
    show Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets (n + (j + 1))
    have : n + (j + 1) = (n + j) + 1 := by omega
    rw [this]
    exact targeted_forward_chain_g_step M0 h_mcs targets (n + j) h_GG

-- ORIGINAL: lines 343-375
/--
H(phi) in backward_chain(n) implies phi in backward_chain(m) for all m >= n.
-/
theorem targeted_backward_chain_backward_H
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n m : Nat) (phi : Formula)
    (h_le : n ≤ m)
    (h_H : Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets n) :
    phi ∈ targeted_backward_chain M0 h_mcs targets m := by
  suffices h_prop : ∀ j : Nat, Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets (n + j) by
    have h_at_m : Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets m := by
      have ⟨d, hd⟩ : ∃ d, m = n + d := ⟨m - n, by omega⟩
      rw [hd]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_backward_chain_mcs M0 h_mcs targets m)
      (theorem_in_mcs (targeted_backward_chain_mcs M0 h_mcs targets m)
        (sorry /- was: temp_t_past phi -/))
      h_at_m
  intro j
  induction j with
  | zero => simp; exact h_H
  | succ j ih =>
    have h_HH : Formula.all_past (Formula.all_past phi) ∈
        targeted_backward_chain M0 h_mcs targets (n + j) :=
      SetMaximalConsistent.implication_property
        (targeted_backward_chain_mcs M0 h_mcs targets (n + j))
        (theorem_in_mcs (targeted_backward_chain_mcs M0 h_mcs targets (n + j))
          (temp_4_past phi))
        ih
    show Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets (n + (j + 1))
    have : n + (j + 1) = (n + j) + 1 := by omega
    rw [this]
    exact targeted_backward_chain_h_step M0 h_mcs targets (n + j) h_HH

-- ORIGINAL: lines 475-541
/--
Forward G coherence: G(phi) at t implies phi at t' for all Int t' >= t.
-/
theorem targeted_fam_forward_G
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (t t' : Int) (phi : Formula)
    (h_le : t ≤ t') (h_G : Formula.all_future phi ∈ targeted_fam M0 h_mcs targets t) :
    phi ∈ targeted_fam M0 h_mcs targets t' := by
  -- Propagate G(phi) forward step by step, then apply T-axiom at t'
  suffices h_prop : ∀ j : Nat, Formula.all_future phi ∈ targeted_fam M0 h_mcs targets (t + j) by
    have h_at_t' : Formula.all_future phi ∈ targeted_fam M0 h_mcs targets t' := by
      obtain ⟨d, hd⟩ := Int.eq_ofNat_of_zero_le (show 0 ≤ t' - t by omega)
      have : t' = t + d := by omega
      rw [this]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_fam_mcs M0 h_mcs targets t')
      (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets t')
        (sorry /- was: temp_t_future phi -/))
      h_at_t'
  intro j
  induction j with
  | zero => simp; exact h_G
  | succ j ih =>
    have h_GG : Formula.all_future (Formula.all_future phi) ∈
        targeted_fam M0 h_mcs targets (t + j) :=
      SetMaximalConsistent.implication_property
        (targeted_fam_mcs M0 h_mcs targets (t + j))
        (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets (t + j))
          (DerivationTree.axiom _ _ (Axiom.temp_4 phi)))
        ih
    show Formula.all_future phi ∈ targeted_fam M0 h_mcs targets (t + (↑(j + 1)))
    have : t + (↑(j + 1) : Int) = (t + ↑j) + 1 := by omega
    rw [this]
    exact targeted_fam_G_step M0 h_mcs targets (t + j) (Formula.all_future phi) h_GG

/--
Backward H coherence: H(phi) at t implies phi at t' for all Int t' <= t.
-/
theorem targeted_fam_backward_H
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (t t' : Int) (phi : Formula)
    (h_le : t' ≤ t) (h_H : Formula.all_past phi ∈ targeted_fam M0 h_mcs targets t) :
    phi ∈ targeted_fam M0 h_mcs targets t' := by
  suffices h_prop : ∀ j : Nat, Formula.all_past phi ∈ targeted_fam M0 h_mcs targets (t - j) by
    have h_at_t' : Formula.all_past phi ∈ targeted_fam M0 h_mcs targets t' := by
      obtain ⟨d, hd⟩ := Int.eq_ofNat_of_zero_le (show 0 ≤ t - t' by omega)
      have : t' = t - d := by omega
      rw [this]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_fam_mcs M0 h_mcs targets t')
      (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets t')
        (sorry /- was: temp_t_past phi -/))
      h_at_t'
  intro j
  induction j with
  | zero => simp; exact h_H
  | succ j ih =>
    have h_HH : Formula.all_past (Formula.all_past phi) ∈
        targeted_fam M0 h_mcs targets (t - j) :=
      SetMaximalConsistent.implication_property
        (targeted_fam_mcs M0 h_mcs targets (t - j))
        (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets (t - j))
          (temp_4_past phi))
        ih
    show Formula.all_past phi ∈ targeted_fam M0 h_mcs targets (t - ↑(j + 1))
    have : (t : Int) - (↑(j + 1) : Int) = (t - ↑j) - 1 := by omega
    rw [this]
    exact targeted_fam_H_step M0 h_mcs targets (t - j) (Formula.all_past phi) h_HH

-- ORIGINAL: lines 547-559
noncomputable def TargetedFMCS
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula) :
    FMCS Int where
  mcs := targeted_fam M0 h_mcs targets
  is_mcs := targeted_fam_mcs M0 h_mcs targets
  forward_G := fun t t' phi h_le h_G =>
    targeted_fam_forward_G M0 h_mcs targets t t' phi h_le h_G
  backward_H := fun t t' phi h_le h_H =>
    targeted_fam_backward_H M0 h_mcs targets t t' phi h_le h_H

theorem TargetedFMCS_at_zero
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula) :
    (TargetedFMCS M0 h_mcs targets).mcs 0 = M0 := rfl
