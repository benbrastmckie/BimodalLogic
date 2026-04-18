/-!
# Boneyard: Round-Robin Chain (Dead Code Archive)

**Status**: ARCHIVED — confirmed dead after 40 rounds of research (task 93)

**Reason**: The round-robin chain approach (`rr_fwd_chain` / `enriched_fwd_step`) cannot
prove `forward_F`. The BX11 perpetual deferral obstruction (Report 26, Section 24 analysis)
blocks the depth-0 base case permanently:

- At each resolving step for target χ, the Lindenbaum extension of {χ} ∪ g_content(M)
  can choose G(¬ψ) over F(ψ), permanently killing any other F-obligation.
- Extended seed consistency fails in general when F(G(¬ψ)) ∈ M (Case 4).
- The enriched chain preserves F(ψ) at every step (rr_fwd_chain_F_obligation_persists),
  but at each resolving step the BX11 fold may perpetually defer ψ.

**Replacement**: The quasimodel-derived chain approach (Plan v30+) replaces this entirely.
The live sorry targets in RootScopedChain.lean are `dd_bfmcs_restricted_tc`,
`dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`, which will be proved
via the quasimodel bridge.

**Preserved for reference**: The mathematical infrastructure below is correct and
may be reusable. In particular, `enriched_fwd_step_preserves` and the BX11 fold
theorems are sound — the obstruction is specifically in `rr_fwd_chain_forward_F`
(depth-0 base case).
-/

import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.CanonicalModel

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Semantics
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Classical

/-! ## Round-Robin Schedule -/

/-- The round-robin schedule: cycle through formulas in a list. -/
def rrSchedule (L : List Formula) (n : Nat) : Formula :=
  if h : L.length > 0 then L.get ⟨n % L.length, Nat.mod_lt n h⟩
  else Formula.bot  -- dummy for empty list

/-- The round-robin schedule always returns an element of the list. -/
theorem rrSchedule_mem (L : List Formula) (n : Nat) (h : L.length > 0) :
    rrSchedule L n ∈ L := by
  simp only [rrSchedule, dif_pos h]
  exact List.getElem_mem (Nat.mod_lt n h)

/-- For any ψ ∈ L, there exists a visit step m > n where rrSchedule L m = ψ.
This follows from the modular arithmetic of the round-robin schedule. -/
theorem rrSchedule_visits (L : List Formula) (n : Nat) (ψ : Formula)
    (h_len : L.length > 0) (hψ : ψ ∈ L) :
    ∃ m : Nat, n < m ∧ rrSchedule L m = ψ := by
  obtain ⟨j, hj_lt, hj_eq⟩ := List.getElem_of_mem hψ
  -- Take m = (n + 1) * L.length + j. Then m > n and m % L.length = j.
  refine ⟨(n + 1) * L.length + j, ?_, ?_⟩
  · -- (n + 1) * L.length + j > n
    have : n + 1 ≤ (n + 1) * L.length := Nat.le_mul_of_pos_right _ h_len
    omega
  · -- rrSchedule L ((n + 1) * L.length + j) = ψ
    unfold rrSchedule
    simp only [dif_pos h_len]
    have h_mod : ((n + 1) * L.length + j) % L.length = j := by
      rw [Nat.mul_comm]
      rw [Nat.mul_add_mod_self_left]
      exact Nat.mod_eq_of_lt hj_lt
    simp only [h_mod, List.get_eq_getElem, hj_eq]

/-! ## Enriched Forward Step
(Uses `resolving_enriched_fwd_exists` from RootScopedChain.lean) -/

/-- Enriched forward step: at a resolving step, use resolving_enriched_fwd_exists
to protect ALL F-formulas from sigma_list AND guarantee at least one defect is
resolved. At a non-resolving step, use the standard fwd_succ (which preserves
f_carry). -/
noncomputable def enriched_fwd_step (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) : Set Formula :=
  if h_F : Formula.some_future target ∈ M then
    let others := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
    (resolving_enriched_fwd_exists h_mcs target h_F others (by
      intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose
  else
    fwd_succ M h_mcs target

private theorem enriched_fwd_step_spec (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) (h_F : Formula.some_future target ∈ M) :
    let others := sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))
    let M' := enriched_fwd_step M h_mcs target sigma_list
    SetMaximalConsistent M' ∧
    g_content M ⊆ M' ∧
    (target ∈ M' ∨ Formula.some_future target ∈ M') ∧
    (∀ χ, χ ∈ others → (χ ∈ M' ∨ Formula.some_future χ ∈ M')) ∧
    (∃ w, (w = target ∨ w ∈ others) ∧ Formula.some_future w ∈ M ∧ w ∈ M') := by
  simp only [enriched_fwd_step, dif_pos h_F]
  exact (resolving_enriched_fwd_exists h_mcs target h_F
    (sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))) (by
    intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose_spec

theorem enriched_fwd_step_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) :
    SetMaximalConsistent (enriched_fwd_step M h_mcs target sigma_list) := by
  unfold enriched_fwd_step; split
  · exact (resolving_enriched_fwd_exists h_mcs target ‹_›
      (sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))) (by
      intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose_spec.1
  · exact fwd_succ_mcs M h_mcs target

theorem enriched_fwd_step_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula) :
    g_content M ⊆ enriched_fwd_step M h_mcs target sigma_list := by
  unfold enriched_fwd_step; split
  · exact (resolving_enriched_fwd_exists h_mcs target ‹_›
      (sigma_list.filter (fun χ => decide (Formula.some_future χ ∈ M))) (by
      intro χ hχ; exact of_decide_eq_true ((List.mem_filter.mp hχ).2))).choose_spec.2.1
  · exact fwd_succ_g_content M h_mcs target

/-- The key property: at a resolving step, each formula from sigma_list
with F(χ) ∈ M has either χ ∈ M' or F(χ) ∈ M'. -/
theorem enriched_fwd_step_preserves (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula)
    (χ : Formula) (hχ_mem : χ ∈ sigma_list) (hFχ : Formula.some_future χ ∈ M) :
    χ ∈ enriched_fwd_step M h_mcs target sigma_list ∨
    Formula.some_future χ ∈ enriched_fwd_step M h_mcs target sigma_list := by
  unfold enriched_fwd_step; split
  case isTrue h_F =>
    have h_spec := (resolving_enriched_fwd_exists h_mcs target h_F
      (sigma_list.filter (fun ψ => decide (Formula.some_future ψ ∈ M))) (by
      intro ψ hψ; exact of_decide_eq_true ((List.mem_filter.mp hψ).2))).choose_spec
    have hχ_filtered : χ ∈ sigma_list.filter (fun ψ => decide (Formula.some_future ψ ∈ M)) := by
      exact List.mem_filter.mpr ⟨hχ_mem, decide_eq_true_eq.mpr hFχ⟩
    exact h_spec.2.2.2.1 χ hχ_filtered
  case isFalse h_not_F =>
    right; exact fwd_succ_f_carry M h_mcs target h_not_F ⟨hFχ, χ, rfl⟩

/-- At a resolving step where target ∈ sigma_list, at least one formula with
F-obligation is directly resolved (present in M', not just F-protected). -/
theorem enriched_fwd_step_resolves_one (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (target : Formula) (sigma_list : List Formula)
    (h_target_mem : target ∈ sigma_list)
    (h_F : Formula.some_future target ∈ M) :
    ∃ w, w ∈ sigma_list ∧ Formula.some_future w ∈ M ∧
      w ∈ enriched_fwd_step M h_mcs target sigma_list := by
  have h_spec := enriched_fwd_step_spec M h_mcs target sigma_list h_F
  obtain ⟨w, h_w_origin, h_w_F, h_w_in⟩ := h_spec.2.2.2.2
  refine ⟨w, ?_, h_w_F, h_w_in⟩
  rcases h_w_origin with rfl | h_in_others
  · exact h_target_mem
  · exact (List.mem_filter.mp h_in_others).1

/-! ## Round-Robin Forward and Backward Chains -/

/-- Forward step with BX11 fold protection.
At each step, the enriched seed protects all F-formulas from sigma_list. -/
noncomputable def rr_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := rr_fwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    ⟨enriched_fwd_step M hM target sigma_list,
     enriched_fwd_step_mcs M hM target sigma_list⟩

/-- Backward step symmetric. -/
noncomputable def rr_bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := rr_bwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    ⟨bwd_pred M hM target, bwd_pred_mcs M hM target⟩

/-! ## g_content propagation for rr_fwd_chain -/

theorem rr_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    g_content (rr_fwd_chain M₀ h₀ sigma_list n).val ⊆
      (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  show g_content (rr_fwd_chain M₀ h₀ sigma_list n).val ⊆
    enriched_fwd_step (rr_fwd_chain M₀ h₀ sigma_list n).val
      (rr_fwd_chain M₀ h₀ sigma_list n).property (rrSchedule sigma_list n) sigma_list
  exact enriched_fwd_step_g_content _ _ _ _

-- Transitive g_content propagation (same proof as fwd_chain_g_content_trans)
theorem rr_fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    g_content (rr_fwd_chain M₀ h₀ sigma_list m).val ⊆
      (rr_fwd_chain M₀ h₀ sigma_list n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ; exact SetMaximalConsistent.implication_property
      (rr_fwd_chain M₀ h₀ sigma_list 0).property
      (theorem_in_mcs (rr_fwd_chain M₀ h₀ sigma_list 0).property
        (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property
        (theorem_in_mcs (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property
          (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future
        (rr_fwd_chain M₀ h₀ sigma_list m).property hφ
      exact rr_fwd_chain_g_content_step M₀ h₀ sigma_list n
        (ih (Nat.lt_succ_iff.mp h_lt) h_GG)

-- Backward chain h_content propagation
theorem rr_bwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    h_content (rr_bwd_chain M₀ h₀ sigma_list n).val ⊆
      (rr_bwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  show h_content (rr_bwd_chain M₀ h₀ sigma_list n).val ⊆
    bwd_pred (rr_bwd_chain M₀ h₀ sigma_list n).val
      (rr_bwd_chain M₀ h₀ sigma_list n).property (rrSchedule sigma_list n)
  exact bwd_pred_h_content _ _ _

theorem rr_bwd_chain_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    h_content (rr_bwd_chain M₀ h₀ sigma_list m).val ⊆
      (rr_bwd_chain M₀ h₀ sigma_list n).val := by
  induction n with
  | zero =>
    have : m = 0 := Nat.eq_zero_of_le_zero h; subst this
    intro φ hφ; exact SetMaximalConsistent.implication_property
      (rr_bwd_chain M₀ h₀ sigma_list 0).property
      (theorem_in_mcs (rr_bwd_chain M₀ h₀ sigma_list 0).property
        (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le h with rfl | h_lt
    · exact fun φ hφ => SetMaximalConsistent.implication_property
        (rr_bwd_chain M₀ h₀ sigma_list (n + 1)).property
        (theorem_in_mcs (rr_bwd_chain M₀ h₀ sigma_list (n + 1)).property
          (DerivationTree.axiom [] _ (Axiom.temp_t_past φ))) hφ
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past
        (rr_bwd_chain M₀ h₀ sigma_list m).property hφ
      exact rr_bwd_chain_h_content_step M₀ h₀ sigma_list n
        (ih (Nat.lt_succ_iff.mp h_lt) h_HH)

/-! ## discharge_fwd_chain (alias for rr_fwd_chain) -/

/-- The discharge forward chain: iterate enriched_fwd_step for sigma_list.length steps,
then use identity (repeat terminal MCS). This is structurally the same as
rr_fwd_chain but with the important property that each step uses the enriched
seed that protects ALL F-formulas from sigma_list.

The chain is indexed by Nat: chain(0) = M₀, chain(n+1) = enriched_fwd_step(chain(n)).
The schedule cycles through sigma_list formulas as targets.
After sigma_list.length steps (one full cycle), every formula has been the target
at least once. The identity tail just repeats the terminal state. -/
noncomputable def discharge_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent M } :=
  rr_fwd_chain M₀ h₀ sigma_list

/-- The discharge chain has g_content propagation at each step. -/
theorem discharge_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    g_content (discharge_fwd_chain M₀ h₀ sigma_list n).val ⊆
      (discharge_fwd_chain M₀ h₀ sigma_list (n + 1)).val :=
  rr_fwd_chain_g_content_step M₀ h₀ sigma_list n

/-- The discharge chain has transitive g_content propagation. -/
theorem discharge_fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {m n : Nat} (h : m ≤ n) :
    g_content (discharge_fwd_chain M₀ h₀ sigma_list m).val ⊆
      (discharge_fwd_chain M₀ h₀ sigma_list n).val :=
  rr_fwd_chain_g_content_trans M₀ h₀ sigma_list h

/-! ## F-obligation constancy for rr_fwd_chain -/

/-- F-obligation persistence: F(ψ) ∈ chain(n) → F(ψ) ∈ chain(n+1).
Combines enriched_fwd_step_preserves (F(ψ) ∈ M → ψ ∈ M' ∨ F(ψ) ∈ M')
with phi_in_mcs_imp_F_phi (ψ ∈ M' → F(ψ) ∈ M'). -/
theorem rr_fwd_chain_F_obligation_persists (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  rcases enriched_fwd_step_preserves _ _ _ _ ψ hψ h_F with h | h
  · exact phi_in_mcs_imp_F_phi
      (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property ψ h
  · exact h

/-- F-obligation non-appearance: F(ψ) ∉ chain(n) → F(ψ) ∉ chain(n+1).
From no_new_f_defects: G(¬ψ) ∈ chain(n) implies F(ψ) ∉ chain(n+1). -/
theorem rr_fwd_chain_F_obligation_absent (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (h_not_F : Formula.some_future ψ ∉ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    Formula.some_future ψ ∉ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  have h_G : Formula.all_future (Formula.neg ψ) ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val := by
    rcases SetMaximalConsistent.negation_complete
      (rr_fwd_chain M₀ h₀ sigma_list n).property
      (Formula.some_future ψ) with h | h
    · exact absurd h h_not_F
    · exact SetMaximalConsistent.double_neg_elim
        (rr_fwd_chain M₀ h₀ sigma_list n).property _ h
  exact no_new_f_defects
    (rr_fwd_chain M₀ h₀ sigma_list n).property
    (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).property
    (enriched_fwd_step_g_content _ _ _ _) ψ h_G

/-- F-obligation constancy (forward): F(ψ) ∈ chain(n) → F(ψ) ∈ chain(m) for all m ≥ n. -/
theorem rr_fwd_chain_F_obligation_forward (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n m : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list) (h_le : n ≤ m)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val := by
  induction m with
  | zero => exact Nat.eq_zero_of_le_zero h_le ▸ h_F
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · exact h_F
    · exact rr_fwd_chain_F_obligation_persists M₀ h₀ sigma_list m ψ hψ
        (ih (Nat.lt_succ_iff.mp h_lt))

/-- F-obligation constancy (backward): F(ψ) ∈ chain(m) → F(ψ) ∈ chain(n) for all n ≤ m.
Contrapositive of F_obligation_absent iterated. -/
theorem rr_fwd_chain_F_obligation_backward (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n m : Nat) (ψ : Formula)
    (h_le : n ≤ m)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val) :
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val := by
  by_contra h_not
  suffices h_abs : ∀ k, n ≤ k →
      Formula.some_future ψ ∉ (rr_fwd_chain M₀ h₀ sigma_list k).val from
    h_abs m h_le h_F
  intro k h_nk
  induction k with
  | zero => exact Nat.eq_zero_of_le_zero h_nk ▸ h_not
  | succ k ih =>
    rcases Nat.eq_or_lt_of_le h_nk with rfl | h_lt
    · exact h_not
    · exact rr_fwd_chain_F_obligation_absent M₀ h₀ sigma_list k ψ
        (ih (Nat.lt_succ_iff.mp h_lt))

/-! ## WF-Induction Infrastructure for forward_F (dead - depth-0 blocked) -/

/-- If f_nesting_depth(ψ) ≥ 1, then ψ has the form some_future(ψ') for some ψ'. -/
theorem f_nesting_depth_pos_is_future_rr (ψ : Formula) (h : f_nesting_depth ψ ≥ 1) :
    ∃ ψ' : Formula, ψ = Formula.some_future ψ' := by
  cases ψ with
  | atom _ => simp [f_nesting_depth] at h
  | bot => simp [f_nesting_depth] at h
  | box _ => simp [f_nesting_depth] at h
  | all_future _ => simp [f_nesting_depth] at h
  | all_past _ => simp [f_nesting_depth] at h
  | untl _ _ => simp [f_nesting_depth] at h
  | snce _ _ => simp [f_nesting_depth] at h
  | imp a b =>
    cases a with
    | all_future c =>
      cases c with
      | imp inner d =>
        cases d with
        | bot =>
          cases b with
          | bot => exact ⟨inner, by simp [Formula.some_future, Formula.neg]⟩
          | _ => simp [f_nesting_depth] at h
        | _ => simp [f_nesting_depth] at h
      | _ => simp [f_nesting_depth] at h
    | _ => simp [f_nesting_depth] at h

/-- Depth ≥ 1 case of forward_F: reduces to IH at strictly lower depth.

Given F(ψ) ∈ chain(n) with f_nesting_depth(ψ) ≥ 1:
1. ψ = F(ψ') for some ψ' with f_nesting_depth(ψ') < f_nesting_depth(ψ)
2. F(F(ψ')) ∈ chain(n) → F(ψ') ∈ chain(n) by FF_imp_F_mcs
3. By IH (applied to ψ' at lower depth): ψ' ∈ chain(s) for some s > n
4. ψ' ∈ chain(s) → F(ψ') ∈ chain(s) by phi_in_mcs_imp_F_phi
5. F(ψ') = ψ, so ψ ∈ chain(s). Done. -/
theorem rr_fwd_chain_forward_F_depth_pos (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    -- sigma_list is closed under F-inner extraction (satisfied by deferralClosure)
    (h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val)
    (h_depth : f_nesting_depth ψ ≥ 1)
    -- IH: forward_F holds for all formulas of strictly lower f_nesting_depth
    (ih : ∀ (m : Nat) (χ : Formula), χ ∈ sigma_list →
      f_nesting_depth χ < f_nesting_depth ψ →
      Formula.some_future χ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val →
      ∃ s : Nat, m < s ∧ χ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val) :
    ∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val := by
  obtain ⟨ψ', rfl⟩ := f_nesting_depth_pos_is_future_rr ψ h_depth
  have h_Fψ' : Formula.some_future ψ' ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val :=
    FF_imp_F_mcs (rr_fwd_chain M₀ h₀ sigma_list n).property ψ' h_F
  have h_depth_lt : f_nesting_depth ψ' < f_nesting_depth (Formula.some_future ψ') := by
    rw [f_nesting_depth_some_future]; omega
  have hψ'_mem : ψ' ∈ sigma_list := h_closed ψ' hψ
  obtain ⟨s, h_lt, h_in⟩ := ih n ψ' hψ'_mem h_depth_lt h_Fψ'
  exact ⟨s, h_lt, phi_in_mcs_imp_F_phi
    (rr_fwd_chain M₀ h₀ sigma_list s).property ψ' h_in⟩

/-- F-preservation: F(ψ) ∈ chain(n) → ψ ∈ chain(n+1) ∨ F(ψ) ∈ chain(n+1). -/
theorem rr_fwd_chain_F_preserved (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val ∨
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val :=
  enriched_fwd_step_preserves _ _ _ _ ψ hψ h_F

/-- F(ψ) propagates through the forward chain: if F(ψ) ∈ chain(n),
then for all m ≥ n, either ψ ∈ chain(s) for some n < s ≤ m+1,
or F(ψ) ∈ chain(m+1). -/
theorem rr_fwd_chain_F_propagate (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val)
    (m : Nat) (h_le : n ≤ m) :
    (∃ s : Nat, n < s ∧ s ≤ m + 1 ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val) ∨
    Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list (m + 1)).val := by
  induction m with
  | zero =>
    have : n = 0 := Nat.eq_zero_of_le_zero h_le; subst this
    rcases rr_fwd_chain_F_preserved M₀ h₀ sigma_list 0 ψ hψ h_F with h | h
    · exact Or.inl ⟨1, Nat.zero_lt_one, le_refl 1, h⟩
    · exact Or.inr h
  | succ m ih =>
    rcases Nat.eq_or_lt_of_le h_le with rfl | h_lt
    · rcases rr_fwd_chain_F_preserved M₀ h₀ sigma_list (m + 1) ψ hψ h_F with h | h
      · exact Or.inl ⟨m + 2, by omega, le_refl _, h⟩
      · exact Or.inr h
    · rcases ih (Nat.lt_succ_iff.mp h_lt) with ⟨s, h_lt_s, h_le_s, h_in⟩ | h_F_m
      · exact Or.inl ⟨s, h_lt_s, by omega, h_in⟩
      · rcases rr_fwd_chain_F_preserved M₀ h₀ sigma_list (m + 1) ψ hψ h_F_m with h | h
        · exact Or.inl ⟨m + 2, by omega, le_refl _, h⟩
        · exact Or.inr h

/-! ## forward_F for rr_fwd_chain (BLOCKED — depth-0 sorry)

This theorem has the depth-0 base case blocked by the BX11 perpetual deferral
obstruction. See the header comment for details. -/

/-- Forward_F for the forward Nat chain: F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s).

**Status**: BLOCKED — depth-0 base case is unresolvable with this chain construction.
See `Boneyard/RoundRobinChain.lean` header for the precise obstruction. -/
theorem rr_fwd_chain_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    (h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    ∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val := by
  suffices h_ind : ∀ (d : Nat) (m : Nat) (χ : Formula), χ ∈ sigma_list →
      f_nesting_depth χ ≤ d →
      Formula.some_future χ ∈ (rr_fwd_chain M₀ h₀ sigma_list m).val →
      ∃ s : Nat, m < s ∧ χ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val from
    h_ind (f_nesting_depth ψ) n ψ hψ (le_refl _) h_F
  intro d
  induction d with
  | zero =>
    -- Base case: depth-0. Core mathematical obstruction (BX11 perpetual deferral).
    intro m χ _hχ_mem _hχ_depth _hχ_F
    sorry
  | succ d ih =>
    intro m χ hχ_mem hχ_depth hχ_F
    by_cases h_zero : f_nesting_depth χ = 0
    · exact ih m χ hχ_mem (by omega) hχ_F
    · have h_pos : f_nesting_depth χ ≥ 1 := by omega
      exact rr_fwd_chain_forward_F_depth_pos M₀ h₀ sigma_list h_nonempty h_closed
        m χ hχ_mem hχ_F h_pos (fun m' χ' hχ'_mem hχ'_lt hχ'_F =>
          ih m' χ' hχ'_mem (by omega) hχ'_F)

/-! ## dd_fmcs_forward_F and dd_fmcs_backward_P (BLOCKED — depend on rr_fwd_chain_forward_F) -/

/-- Forward_F for dd_fmcs: blocked because it relies on rr_fwd_chain_forward_F. -/
theorem dd_fmcs_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    (h_closed : ∀ χ : Formula, Formula.some_future χ ∈ sigma_list → χ ∈ sigma_list)
    (t : Int) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs t) :
    ∃ s : Int, t < s ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s := by
  simp only [dd_fmcs] at h_F ⊢
  rcases le_or_gt 0 t with h_nonneg | h_neg
  · simp only [dd_chain] at h_F
    rw [if_pos h_nonneg] at h_F
    obtain ⟨s, h_lt, h_in⟩ := rr_fwd_chain_forward_F M₀ h₀ sigma_list h_nonempty h_closed
      t.toNat ψ hψ h_F
    refine ⟨Int.ofNat s, ?_, ?_⟩
    · rw [show t = Int.ofNat t.toNat from (Int.toNat_of_nonneg h_nonneg).symm]
      exact Int.ofNat_lt.mpr h_lt
    · simp only [dd_chain, show (Int.ofNat s ≥ 0) from Int.natCast_nonneg s, ite_true]
      exact h_in
  · -- t < 0: backward chain case, also blocked
    sorry

/-- Backward_P for dd_fmcs: blocked pending resolution of the backward chain approach. -/
theorem dd_fmcs_backward_P (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_P : Formula.some_past ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs t) :
    ∃ s : Int, s < t ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s := by
  sorry

end Bimodal.Metalogic.BXCanonical
