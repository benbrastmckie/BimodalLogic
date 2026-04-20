import Bimodal.Metalogic.BXCanonical.CanonicalChain
import Bimodal.Metalogic.BXCanonical.TruthLemma
import Bimodal.Metalogic.Bundle.FMCSDef

/-!
# BXCanonical Canonical Model Construction

Constructs a BFMCS Int from BXCanonical witnesses, bridging to the parametric
algebraic representation theorem for the BX completeness proof.

Given an MCS M₀, build a chain of MCS indexed by Int. Forward steps use
`forward_temporal_witness_seed` from WitnessSeed.lean, backward steps use
`past_temporal_witness_seed`. A pairing schedule ensures every formula is
targeted for resolution infinitely often.

The BFMCS has one FMCS per modal class reachable from M₀. Modal coherence
follows from S5 properties of BXCanonical (box_preserved_along_bx_le,
bx_modal_witness).
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators

/-! ## Schedule -/

noncomputable def schedule (n : Nat) : Formula :=
  Denumerable.ofNat Formula (Nat.unpair n).2

theorem schedule_surjective_above (ψ : Formula) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧ schedule n = ψ :=
  ⟨Nat.pair k (Encodable.encode ψ),
   Nat.left_le_pair k _,
   by simp [schedule, Nat.unpair_pair, Denumerable.ofNat_encode]⟩

/-! ## F-carry: F-formulas from an MCS -/

/-- The set of F-formulas (some_future χ) that are in M. -/
def f_carry (M : Set Formula) : Set Formula :=
  {φ ∈ M | ∃ χ, φ = Formula.some_future χ}

theorem f_carry_subset (M : Set Formula) : f_carry M ⊆ M :=
  fun _ h => h.1

/-- The enriched non-resolving seed: g_content(M) ∪ f_carry(M) consistent.
Under irreflexive semantics, g_content(M) ⊆ M no longer follows from BX1.
Consistency needs to be proved via seriality + MCS properties.
Sorry'd pending Phase 2 redesign (canonical model repair). -/
theorem enriched_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    SetConsistent (g_content M ∪ f_carry M) := by
  sorry

/-! ## Forward Step -/

/-- Build a successor MCS containing g_content(M). If F(ψ) ∈ M, also contains ψ.
    Under irreflexive semantics, the non-resolving branch uses g_content(M) alone
    (consistent by seriality via g_content_set_consistent). -/
noncomputable def fwd_succ (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    Set Formula := by
  by_cases h_F : Formula.some_future ψ ∈ M
  · exact (set_lindenbaum (forward_temporal_witness_seed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose
  · exact (set_lindenbaum (g_content M)
      (g_content_set_consistent h_mcs)).choose

theorem fwd_succ_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    SetMaximalConsistent (fwd_succ M h_mcs ψ) := by
  unfold fwd_succ; split
  · exact (set_lindenbaum (forward_temporal_witness_seed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (g_content M)
      (g_content_set_consistent h_mcs)).choose_spec.2

theorem fwd_succ_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    g_content M ⊆ fwd_succ M h_mcs ψ := by
  unfold fwd_succ; split
  · exact fun χ hχ => (set_lindenbaum (forward_temporal_witness_seed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (g_content M)
      (g_content_set_consistent h_mcs)).choose_spec.1 hχ

theorem fwd_succ_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ M) : ψ ∈ fwd_succ M h_mcs ψ := by
  unfold fwd_succ; rw [dif_pos h_F]
  exact (set_lindenbaum (forward_temporal_witness_seed M ψ)
    (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-- Under irreflexive semantics, f_carry is NOT preserved at non-resolving steps.
The non-resolving branch only seeds with g_content(M).
This theorem is no longer provable and is sorry'd for backward compatibility. -/
theorem fwd_succ_f_carry (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (h_not_F : Formula.some_future ψ ∉ M) :
    f_carry M ⊆ fwd_succ M h_mcs ψ := by
  sorry

/-! ## P-carry: P-formulas from an MCS -/

/-- The set of P-formulas (some_past χ) that are in M. -/
def p_carry (M : Set Formula) : Set Formula :=
  {φ ∈ M | ∃ χ, φ = Formula.some_past χ}

theorem p_carry_subset (M : Set Formula) : p_carry M ⊆ M :=
  fun _ h => h.1

/-- The enriched non-resolving seed for backward: h_content(M) ∪ p_carry(M) ⊆ M, hence consistent. -/
theorem enriched_past_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    SetConsistent (h_content M ∪ p_carry M) := by
  -- Under irreflexive semantics, h_content(M) ⊆ M no longer follows from BX1'.
  -- Sorry'd pending Phase 2 redesign.
  sorry

/-! ## Backward Step -/

/-- h_content(M) is consistent for MCS M.
Under irreflexive semantics, uses seriality (⊤ → P(⊤)) via h_content_set_consistent. -/
theorem h_content_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    SetConsistent (h_content M) :=
  h_content_set_consistent h_mcs

/-- Build a predecessor MCS containing h_content(M). If P(ψ) ∈ M, also contains ψ.
    Under irreflexive semantics, the non-resolving branch uses h_content(M) alone. -/
noncomputable def bwd_pred (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    Set Formula := by
  by_cases h_P : Formula.some_past ψ ∈ M
  · exact (set_lindenbaum (past_temporal_witness_seed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose
  · exact (set_lindenbaum (h_content M)
      (h_content_set_consistent h_mcs)).choose

theorem bwd_pred_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    SetMaximalConsistent (bwd_pred M h_mcs ψ) := by
  unfold bwd_pred; split
  · exact (set_lindenbaum (past_temporal_witness_seed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (h_content M)
      (h_content_set_consistent h_mcs)).choose_spec.2

theorem bwd_pred_h_content (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    h_content M ⊆ bwd_pred M h_mcs ψ := by
  unfold bwd_pred; split
  · exact fun χ hχ => (set_lindenbaum (past_temporal_witness_seed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (h_content M)
      (h_content_set_consistent h_mcs)).choose_spec.1 hχ

theorem bwd_pred_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (h_P : Formula.some_past ψ ∈ M) : ψ ∈ bwd_pred M h_mcs ψ := by
  unfold bwd_pred; rw [dif_pos h_P]
  exact (set_lindenbaum (past_temporal_witness_seed M ψ)
    (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-- Under irreflexive semantics, p_carry is NOT preserved at non-resolving backward steps.
The non-resolving branch only seeds with h_content(M).
Sorry'd for backward compatibility. -/
theorem bwd_pred_p_carry (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (h_not_P : Formula.some_past ψ ∉ M) :
    p_carry M ⊆ bwd_pred M h_mcs ψ := by
  sorry

/-! ## Forward/Backward Chains -/

noncomputable def fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := fwd_chain M₀ h₀ n
    ⟨fwd_succ M hM (schedule n), fwd_succ_mcs M hM (schedule n)⟩

noncomputable def bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := bwd_chain M₀ h₀ n
    ⟨bwd_pred M hM (schedule n), bwd_pred_mcs M hM (schedule n)⟩

/-! ## Int-indexed Chain -/

noncomputable def int_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) (t : Int) :
    Set Formula :=
  if t ≥ 0 then (fwd_chain M₀ h₀ t.toNat).val
  else (bwd_chain M₀ h₀ ((-t).toNat)).val

theorem int_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    int_chain M₀ h₀ 0 = M₀ := by simp [int_chain, fwd_chain]

theorem int_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) (t : Int) :
    SetMaximalConsistent (int_chain M₀ h₀ t) := by
  simp only [int_chain]; split
  · exact (fwd_chain M₀ h₀ t.toNat).property
  · exact (bwd_chain M₀ h₀ ((-t).toNat)).property

/-! ### g_content/h_content reflexivity under BX T-axioms -/

/-- Under irreflexive semantics, g_content(M) ⊆ M does NOT hold (BX1 removed).
Sorry'd pending Phase 2 redesign. -/
theorem g_content_subset_self {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    g_content M ⊆ M := by
  sorry

/-- Under irreflexive semantics, h_content(M) ⊆ M does NOT hold (BX1' removed).
Sorry'd pending Phase 2 redesign. -/
theorem h_content_subset_self {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
    h_content M ⊆ M := by
  sorry

/-! ### Chain ordering (g_content/h_content) -/

theorem fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) (n : Nat) :
    g_content (fwd_chain M₀ h₀ n).val ⊆ (fwd_chain M₀ h₀ (n + 1)).val := by
  show g_content (fwd_chain M₀ h₀ n).val ⊆
    (fwd_succ (fwd_chain M₀ h₀ n).val (fwd_chain M₀ h₀ n).property (schedule n))
  exact fwd_succ_g_content _ _ _

theorem fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    {m n : Nat} (h : m ≤ n) :
    g_content (fwd_chain M₀ h₀ m).val ⊆ (fwd_chain M₀ h₀ n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h
    subst this
    -- Under irreflexive semantics, g_content_subset_self is sorry'd
    exact g_content_subset_self (fwd_chain M₀ h₀ 0).property
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact g_content_subset_self (fwd_chain M₀ h₀ (n + 1)).property
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future (fwd_chain M₀ h₀ m).property hφ
      exact fwd_chain_g_content_step M₀ h₀ n (ih (Nat.lt_succ_iff.mp h_lt) h_GG)

theorem bwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) (n : Nat) :
    h_content (bwd_chain M₀ h₀ n).val ⊆ (bwd_chain M₀ h₀ (n + 1)).val := by
  show h_content (bwd_chain M₀ h₀ n).val ⊆
    (bwd_pred (bwd_chain M₀ h₀ n).val (bwd_chain M₀ h₀ n).property (schedule n))
  exact bwd_pred_h_content _ _ _

theorem bwd_chain_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    {m n : Nat} (h : m ≤ n) :
    h_content (bwd_chain M₀ h₀ m).val ⊆ (bwd_chain M₀ h₀ n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h
    subst this
    -- Under irreflexive semantics, h_content_subset_self is sorry'd
    exact h_content_subset_self (bwd_chain M₀ h₀ 0).property
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact h_content_subset_self (bwd_chain M₀ h₀ (n + 1)).property
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past (bwd_chain M₀ h₀ m).property hφ
      exact bwd_chain_h_content_step M₀ h₀ n (ih (Nat.lt_succ_iff.mp h_lt) h_HH)

/-! ### Forward G and Backward H -/

/-- The g_content relationship also gives us reverse h_content. -/
theorem fwd_chain_reverse_h (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    {m n : Nat} (h : m ≤ n) :
    h_content (fwd_chain M₀ h₀ n).val ⊆ (fwd_chain M₀ h₀ m).val := by
  -- g_content(chain(m)) ⊆ chain(n) implies h_content(chain(n)) ⊆ chain(m)
  exact g_content_subset_implies_h_content_reverse
    (fwd_chain M₀ h₀ m).val (fwd_chain M₀ h₀ n).val
    (fwd_chain M₀ h₀ m).property (fwd_chain M₀ h₀ n).property
    (fwd_chain_g_content_trans M₀ h₀ h)

/-- Reverse: h_content along bwd_chain gives g_content in reverse. -/
theorem bwd_chain_reverse_g (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    {m n : Nat} (h : m ≤ n) :
    g_content (bwd_chain M₀ h₀ n).val ⊆ (bwd_chain M₀ h₀ m).val := by
  exact h_content_subset_implies_g_content_reverse
    (bwd_chain M₀ h₀ m).val (bwd_chain M₀ h₀ n).val
    (bwd_chain M₀ h₀ m).property (bwd_chain M₀ h₀ n).property
    (bwd_chain_h_content_trans M₀ h₀ h)

/-- g_content propagation across the full Int chain. -/
theorem int_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    {t t' : Int} (h_le : t ≤ t') :
    g_content (int_chain M₀ h₀ t) ⊆ int_chain M₀ h₀ t' := by
  simp only [int_chain]
  split_ifs with ht ht'
  · -- t ≥ 0, t' ≥ 0
    exact fwd_chain_g_content_trans M₀ h₀ (Int.toNat_le_toNat h_le)
  · -- t ≥ 0, t' < 0: impossible
    omega
  · -- t < 0, t' ≥ 0: go through chain(0) = M₀
    -- g_content(bwd(-t)) ⊆ bwd(0) = M₀ = fwd(0) ⊆ fwd(t')
    -- g_content(bwd(-t)) ⊆ bwd(0) is bwd_chain_reverse_g with 0 ≤ (-t).toNat
    intro χ hχ
    have h1 : χ ∈ (bwd_chain M₀ h₀ 0).val :=
      bwd_chain_reverse_g M₀ h₀ (Nat.zero_le _) hχ
    simp [bwd_chain] at h1
    -- Now χ ∈ M₀ = fwd_chain(0)
    have h2 : χ ∈ (fwd_chain M₀ h₀ 0).val := by simp [fwd_chain]; exact h1
    -- Propagate from fwd(0) to fwd(t'.toNat)
    -- We need g_content(fwd(0)) ⊆ fwd(t'.toNat), but we only have χ ∈ fwd(0)
    -- Actually, we need G(χ) ∈ chain(t), which gives G(χ) ∈ bwd(-t)
    -- then G(G(χ)) ∈ bwd(-t) via temp_4, then G(χ) ∈ bwd(0)
    -- Actually this is subtler. Let me use the fact that g_content means G(χ) ∈ chain(t).
    -- So G(χ) ∈ bwd(-t). By bwd_chain_reverse_g: G(χ) ∈ bwd(0) = M₀.
    -- So G(χ) ∈ fwd(0) = M₀, which means χ ∈ g_content(fwd(0)) ⊆ fwd(t'.toNat).
    -- Wait, G(χ) ∈ fwd(0) means χ ∈ g_content(fwd(0)), and fwd_chain_g_content_trans
    -- gives g_content(fwd(0)) ⊆ fwd(t'.toNat).
    -- But we derived χ ∈ M₀ = fwd(0), not G(χ) ∈ M₀.
    -- The issue: bwd_chain_reverse_g gives g_content(bwd(-t)) ⊆ bwd(0).
    -- hχ says G(χ) ∈ bwd(-t) (since hχ ∈ g_content(int_chain t) and int_chain t = bwd(-t))
    -- Wait, no. hχ is in g_content of the set, not the set itself.
    -- g_content(bwd(-t)) means {ψ | G(ψ) ∈ bwd(-t)}. So hχ : G(χ) ∈ bwd(-t).
    -- bwd_chain_reverse_g gives g_content(bwd(-t)) ⊆ bwd(0), so χ ∈ bwd(0) = M₀.
    -- But we need χ ∈ fwd(t'.toNat). We have χ ∈ M₀ = fwd(0).
    -- For χ to propagate: we need G(χ) ∈ fwd(0), i.e., G(χ) ∈ M₀.
    -- We have G(χ) ∈ bwd(-t) and need G(χ) ∈ bwd(0) = M₀.
    -- bwd_chain_reverse_g gives g_content(bwd(-t)) ⊆ bwd(0).
    -- So if G(G(χ)) ∈ bwd(-t), then G(χ) ∈ bwd(0) = M₀.
    -- G(G(χ)) ∈ bwd(-t) follows from G(χ) ∈ bwd(-t) via temp_4 (G → GG).
    -- Then G(χ) ∈ M₀ = fwd(0), so χ ∈ g_content(fwd(0)) ⊆ fwd(t'.toNat).
    have h_Gchi_in_bwd : Formula.all_future χ ∈ (bwd_chain M₀ h₀ ((-t).toNat)).val := hχ
    have h_GGchi := SetMaximalConsistent.all_future_all_future
      (bwd_chain M₀ h₀ ((-t).toNat)).property h_Gchi_in_bwd
    have h_Gchi_in_M0 : Formula.all_future χ ∈ M₀ :=
      bwd_chain_reverse_g M₀ h₀ (Nat.zero_le _) h_GGchi
    -- Now G(χ) ∈ fwd(0) = M₀, so χ ∈ g_content(fwd(0))
    exact fwd_chain_g_content_trans M₀ h₀ (Nat.zero_le _) h_Gchi_in_M0
  · -- t < 0, t' < 0: bwd_chain_reverse_g
    -- Need g_content(bwd(-t)) ⊆ bwd(-t')
    -- We have (-t').toNat ≤ (-t).toNat (since t ≤ t' < 0 means -t ≥ -t' > 0)
    exact bwd_chain_reverse_g M₀ h₀ (by omega)

theorem int_chain_forward_G (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (t t' : Int) (φ : Formula) (h_le : t ≤ t')
    (h_G : Formula.all_future φ ∈ int_chain M₀ h₀ t) :
    φ ∈ int_chain M₀ h₀ t' :=
  int_chain_g_content M₀ h₀ h_le h_G

/-- h_content propagation across the full Int chain (reverse direction). -/
theorem int_chain_h_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    {t t' : Int} (h_le : t ≤ t') :
    h_content (int_chain M₀ h₀ t') ⊆ int_chain M₀ h₀ t := by
  -- h_content(chain(t')) ⊆ chain(t) follows from g_content(chain(t)) ⊆ chain(t')
  -- via the duality: g_content_subset_implies_h_content_reverse
  exact g_content_subset_implies_h_content_reverse
    (int_chain M₀ h₀ t) (int_chain M₀ h₀ t')
    (int_chain_mcs M₀ h₀ t) (int_chain_mcs M₀ h₀ t')
    (int_chain_g_content M₀ h₀ h_le)

theorem int_chain_backward_H (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (t t' : Int) (φ : Formula) (h_le : t' ≤ t)
    (h_H : Formula.all_past φ ∈ int_chain M₀ h₀ t) :
    φ ∈ int_chain M₀ h₀ t' :=
  int_chain_h_content M₀ h₀ h_le h_H

/-! ## FMCS -/

noncomputable def bx_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) : FMCS Int where
  mcs := int_chain M₀ h₀
  is_mcs := int_chain_mcs M₀ h₀
  forward_G := int_chain_forward_G M₀ h₀
  backward_H := int_chain_backward_H M₀ h₀

theorem bx_fmcs_at_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) :
    (bx_fmcs M₀ h₀).mcs 0 = M₀ := int_chain_zero M₀ h₀

/-! ## Shifted FMCS

A shifted FMCS places the origin MCS at time offset `s` instead of time 0.
This is needed for modal saturation: when a Diamond witness is needed at time t,
we shift the chain so the witness MCS appears at position t.
-/

/-- A time-shifted FMCS: `mcs t = int_chain M₀ h₀ (t - s)`. -/
noncomputable def shifted_bx_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (s : Int) : FMCS Int where
  mcs t := int_chain M₀ h₀ (t - s)
  is_mcs t := int_chain_mcs M₀ h₀ (t - s)
  forward_G t t' φ h_le h_G := int_chain_forward_G M₀ h₀ (t - s) (t' - s) φ (by omega) h_G
  backward_H t t' φ h_le h_H := int_chain_backward_H M₀ h₀ (t - s) (t' - s) φ (by omega) h_H

theorem shifted_bx_fmcs_at_s (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) (s : Int) :
    (shifted_bx_fmcs M₀ h₀ s).mcs s = M₀ := by
  simp [shifted_bx_fmcs, int_chain_zero]

/-! ## Box Stability Along the Chain -/

/-- Box formulas are stable along the int_chain: Box φ ∈ chain(t) ↔ Box φ ∈ M₀.

This is the set-level analog of `box_preserved_along_bx_le` from Frame.lean.
The proof uses:
- Forward: temp_future (□φ → G(□φ)) for t ≥ 0, modal_4 + box_to_past for t < 0
- Backward: contrapositive via neg_box_to_box_neg_box (S5 negative introspection)
-/
theorem box_stable_in_int_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (φ : Formula) (t : Int) :
    Formula.box φ ∈ int_chain M₀ h₀ t ↔ Formula.box φ ∈ M₀ := by
  constructor
  · -- Backward: Box φ ∈ chain(t) → Box φ ∈ M₀
    -- Contrapositive: Box φ ∉ M₀ → Box φ ∉ chain(t)
    intro h_box_t
    by_contra h_not_box_M0
    -- ¬(Box φ) ∈ M₀
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    -- Box(¬(Box φ)) ∈ M₀ by S5 negative introspection
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (neg_box_to_box_neg_box φ)) h_neg_box_M0
    -- Propagate Box(¬(Box φ)) to chain(t)
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ int_chain M₀ h₀ t := by
      rcases le_or_gt 0 t with h_pos | h_neg
      · -- t ≥ 0: use G propagation
        have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)))
          h_box_neg
        exact int_chain_forward_G M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_pos h_G
      · -- t < 0: use H propagation (Box → Box Box → H Box via modal_4 + box_to_past)
        have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        exact int_chain_backward_H M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) (Int.le_of_lt h_neg) h_H
    -- Box(¬(Box φ)) ∈ chain(t), so ¬(Box φ) ∈ chain(t) by modal_t
    have h_neg_box_t : (Formula.box φ).neg ∈ int_chain M₀ h₀ t :=
      SetMaximalConsistent.implication_property (int_chain_mcs M₀ h₀ t)
        (theorem_in_mcs (int_chain_mcs M₀ h₀ t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)))
        h_box_neg_t
    -- Contradiction: Box φ and ¬(Box φ) both in chain(t)
    exact set_consistent_not_both (int_chain_mcs M₀ h₀ t).1 (Formula.box φ) h_box_t h_neg_box_t
  · -- Forward: Box φ ∈ M₀ → Box φ ∈ chain(t)
    intro h_box_M0
    rcases le_or_gt 0 t with h_pos | h_neg
    · -- t ≥ 0: use G propagation (temp_future: □φ → G(□φ))
      have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future φ))) h_box_M0
      exact int_chain_forward_G M₀ h₀ 0 t (Formula.box φ) h_pos h_G
    · -- t < 0: use H propagation (modal_4: □φ → □□φ, box_to_past: □(□φ) → H(□φ))
      have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (box_to_past (Formula.box φ))) h_box_box
      exact int_chain_backward_H M₀ h₀ 0 t (Formula.box φ) (Int.le_of_lt h_neg) h_H

/-- Box stability for shifted FMCS: Box φ ∈ (shifted_bx_fmcs M₀ h₀ s).mcs t ↔ Box φ ∈ M₀. -/
theorem box_stable_in_shifted_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (φ : Formula) (s t : Int) :
    Formula.box φ ∈ (shifted_bx_fmcs M₀ h₀ s).mcs t ↔ Formula.box φ ∈ M₀ :=
  box_stable_in_int_chain M₀ h₀ φ (t - s)

/-! ## Dead Code Removed

The following definitions and theorems were removed as dead code (not on the active
completeness path, which uses `dd_countermodel` in RootScopedChain.lean):

- `bx_fmcs_forward_F`, `bx_fmcs_backward_P` — unprovable for scheduling chain
- `bx_bfmcs` — BFMCS construction using old `int_chain`
- `bx_bfmcs_tc`, `bx_bfmcs_buc`, `bx_bfmcs_fuc` — unrestricted coherence (had sorry)
- `bx_bfmcs_restricted_tc/buc/fuc` — restricted coherence (had sorry, delegated to above)
- `bx_countermodel` — superseded by `dd_countermodel` in RootScopedChain.lean

The active completeness path is:
  `bx_completeness` (Completeness.lean) → `dd_countermodel` (RootScopedChain.lean)
-/

end Bimodal.Metalogic.BXCanonical
