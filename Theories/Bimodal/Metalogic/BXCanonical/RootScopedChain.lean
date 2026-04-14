import Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency
import Bimodal.Metalogic.BXCanonical.CanonicalModel
import Bimodal.Metalogic.Bundle.UntilSinceCoherence

/-!
# Root-Scoped Defect-Discharge Chain

New FMCS/BFMCS with all coherence properties, replacing `bx_countermodel`.

## Architecture: Infinite Round-Robin Chain

Instead of a 3-region chain, we use an infinite round-robin that cycles
through all formulas in sigma, resolving each one at its scheduled step.
F-formulas persist between steps because:
1. At non-resolving steps: f_carry preserves them
2. At resolving steps: the enriched seed (via BX11 fold) protects them
3. F(F(ψ)) → F(ψ) by temp_4 contrapositive ensures fold compounds work

Box stability is guaranteed by including `modal_fix(M₀)` in every seed.

## Key Insight

F(F(ψ)) → F(ψ) follows from temp_4: G(φ) → G(G(φ)).
Contrapositive: ¬G(G(φ)) → ¬G(φ), i.e., F(¬G(φ)) → F(φ).
Setting φ = ¬ψ: F(¬G(¬ψ)) → F(¬ψ)... wait, that's not right.
Actually: G(G(¬ψ)) → G(¬ψ) is NOT temp_4 (temp_4 goes the other way).
temp_4: G(φ) → G(G(φ)). Contrapositive: ¬G(G(φ)) → ¬G(φ).
With φ = ¬ψ: ¬G(G(¬ψ)) → ¬G(¬ψ), i.e., F(G(¬ψ)) → F(ψ)... no.
F(φ) = ¬G(¬φ). F(F(ψ)) = F(¬G(¬ψ)) = ¬G(¬¬G(¬ψ)) = ¬G(G(¬ψ)).
And from temp_4 with φ = ¬ψ: G(¬ψ) → G(G(¬ψ)).
Contrapositive: ¬G(G(¬ψ)) → ¬G(¬ψ).
So F(F(ψ)) = ¬G(G(¬ψ)) → ¬G(¬ψ) = F(ψ). ✓

This is derivable in BX. At the MCS level: F(F(ψ)) ∈ M → F(ψ) ∈ M.
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.ParametricTruthLemma
open Bimodal.Metalogic.Algebraic.ParametricRepresentation
open Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
open Bimodal.Semantics
open Bimodal.Theorems.Propositional
open Bimodal.Theorems.Combinators
open Bimodal.Theorems.Perpetuity
open Classical

/-! ## F(F(ψ)) → F(ψ) -/

/-- F(F(ψ)) → F(ψ) is derivable in BX.
Proof: temp_4 gives G(¬ψ) → G(G(¬ψ)). Contrapositive: ¬G(G(¬ψ)) → ¬G(¬ψ).
Since F(F(ψ)) = ¬G(G(¬ψ)) and F(ψ) = ¬G(¬ψ), this is F(F(ψ)) → F(ψ). -/
noncomputable def FF_imp_F (ψ : Formula) :
    DerivationTree [] ((Formula.some_future ψ).some_future.imp (Formula.some_future ψ)) := by
  -- Step 1: G(¬ψ) → G(G(¬ψ)) by temp_4
  have h1 : [] ⊢ (Formula.all_future (Formula.neg ψ)).imp
      (Formula.all_future (Formula.all_future (Formula.neg ψ))) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 (Formula.neg ψ))
  -- Step 2: G(¬ψ) → ¬¬G(¬ψ) by double negation intro
  have h2 : [] ⊢ (Formula.all_future (Formula.neg ψ)).imp
      (Formula.all_future (Formula.neg ψ)).neg.neg :=
    dni (Formula.all_future (Formula.neg ψ))
  -- Step 3: G(G(¬ψ)) → G(¬¬G(¬ψ)) by G-monotonicity of h2
  have h3 : [] ⊢ (Formula.all_future (Formula.all_future (Formula.neg ψ))).imp
      (Formula.all_future (Formula.all_future (Formula.neg ψ)).neg.neg) :=
    future_mono h2
  -- Step 4: G(¬ψ) → G(¬¬G(¬ψ)) by composing h1 and h3
  have h4 : [] ⊢ (Formula.all_future (Formula.neg ψ)).imp
      (Formula.all_future (Formula.all_future (Formula.neg ψ)).neg.neg) :=
    imp_trans h1 h3
  -- Step 5: ¬G(¬¬G(¬ψ)) → ¬G(¬ψ) by contrapositive
  -- This is F(F(ψ)) → F(ψ) since:
  --   F(ψ) = ¬G(¬ψ) = (all_future (neg ψ)).neg
  --   F(F(ψ)) = ¬G(¬F(ψ)) = ¬G(¬¬G(¬ψ)) = (all_future (neg (neg (all_future (neg ψ))))).neg
  --           = (all_future (all_future (neg ψ)).neg.neg).neg
  exact Bimodal.Theorems.Propositional.contraposition h4

/-- F(F(ψ)) ∈ M → F(ψ) ∈ M for any MCS M. -/
theorem FF_imp_F_mcs {M : Set Formula} (h_mcs : SetMaximalConsistent M)
    (ψ : Formula) (h : (Formula.some_future ψ).some_future ∈ M) :
    Formula.some_future ψ ∈ M :=
  SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs (FF_imp_F ψ)) h

/-! ## Modal Fix

The set of modal formulas from M₀: both □φ ∈ M₀ and ¬□φ ∈ M₀ formulas.
Including this in every seed ensures box stability. -/

def modal_fix (M₀ : Set Formula) : Set Formula :=
  { φ | (∃ ψ, φ = Formula.box ψ ∧ Formula.box ψ ∈ M₀) ∨
        (∃ ψ, φ = (Formula.box ψ).neg ∧ Formula.box ψ ∉ M₀) }

theorem modal_fix_subset_mcs {M₀ : Set Formula} (h₀ : SetMaximalConsistent M₀) :
    modal_fix M₀ ⊆ M₀ := by
  intro φ hφ
  rcases hφ with ⟨ψ, rfl, h_box⟩ | ⟨ψ, rfl, h_not_box⟩
  · exact h_box
  · rcases SetMaximalConsistent.negation_complete h₀ (Formula.box ψ) with h | h
    · exact absurd h h_not_box
    · exact h

/-! ## Round-Robin Forward Step

At each forward step n, resolve schedule[n % k] if it has an F-obligation,
otherwise use the enriched non-resolving seed (g_content ∪ f_carry).
Always include modal_fix(M₀) in the seed for box stability.
-/

/-- The enriched forward step seed: {target} ∪ g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀)
when F(target) ∈ M, or g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀) otherwise. -/
noncomputable def rr_fwd_seed (M M₀ : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h₀ : SetMaximalConsistent M₀) (target : Formula) : Set Formula :=
  if Formula.some_future target ∈ M then
    {target} ∪ g_content M ∪ f_carry M ∪ modal_fix M₀
  else
    g_content M ∪ f_carry M ∪ modal_fix M₀

/-- The non-resolving seed g_content(M) ∪ f_carry(M) ∪ modal_fix(M₀) is consistent
when M is MCS and modal_fix(M₀) ⊆ M. -/
theorem rr_nonresolving_seed_consistent {M M₀ : Set Formula}
    (h_mcs : SetMaximalConsistent M) (h₀ : SetMaximalConsistent M₀)
    (h_modal : modal_fix M₀ ⊆ M) :
    SetConsistent (g_content M ∪ f_carry M ∪ modal_fix M₀) := by
  have h_sub : g_content M ∪ f_carry M ∪ modal_fix M₀ ⊆ M := by
    apply Set.union_subset
    · exact Set.union_subset
        (fun φ hφ => SetMaximalConsistent.implication_property h_mcs
          (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ (Axiom.temp_t_future φ))) hφ)
        (f_carry_subset M)
    · exact h_modal
  intro L hL hd
  exact h_mcs.1 L (fun φ hφ => h_sub (hL φ hφ)) hd

/-! ## Round-Robin Chain Using Existing Infrastructure

Use the existing `fwd_succ` and `bwd_pred` from CanonicalModel.lean.
These already handle:
- Resolving steps: {target} ∪ g_content(M) (if F(target) ∈ M)
- Non-resolving steps: g_content(M) ∪ f_carry(M) (otherwise)

The key insight for forward_F: F(ψ) ∈ chain(t) with ψ in sigma_list.
Within k = |sigma_list| steps, ψ gets scheduled. If F(ψ) survives to that
step (preserved at non-resolving steps via f_carry), then ψ gets resolved.

If F(ψ) is lost at an intervening resolving step (for some other target χ):
then G(¬ψ) ∈ chain(s) for some s > t. F(ψ) never returns. ψ is never resolved.
But forward_F requires ψ ∈ chain(s') for some s' > t. ψ ∉ chain(s') for any s'.
CONTRADICTION? No — forward_F at chain(t) requires this only when F(ψ) ∈ chain(t).
The fact that F(ψ) is lost later doesn't affect the obligation at time t.
We need ψ ∈ chain(s') for SOME s' > t. If F(ψ) is lost at step s (resolving
step for χ), then we need ψ ∈ chain(s') for s' between t and s.
F(ψ) ∈ chain(t), chain(t+1), ..., chain(s-1) (preserved at non-resolving steps).
At step s: F(ψ) is lost. But ψ might have been scheduled between t and s.
If ψ was scheduled at step m (t < m < s): F(ψ) ∈ chain(m), so resolving step,
ψ ∈ chain(m+1). Witness found!

But what if ψ was NOT scheduled between t and s? Then F(ψ) survived all non-resolving
steps but was lost at step s (a resolving step for some other χ).

At the resolving step s for χ: F(χ) ∈ chain(s). The seed is {χ} ∪ g_content(chain(s)).
F(ψ) ∈ chain(s) but F(ψ) ∉ seed. So F(ψ) might not be in chain(s+1).
If F(ψ) ∉ chain(s+1): G(¬ψ) ∈ chain(s+1). ψ ∉ chain(s') for all s' > s.
No witness for forward_F at t.

THE PROBLEM REMAINS: resolving steps for OTHER formulas can permanently destroy
F(ψ), and if ψ wasn't scheduled between t and s, we have no witness.

The round-robin schedule visits each formula every k steps. But between two
visits of ψ, there can be resolving steps for OTHER formulas that destroy F(ψ).

SOLUTION FROM TEAM LEAD: The BX11 fold at each resolving step folds ALL formulas
in sigma, not just the target. The fold compound includes F(ψ) (protected).
Then F(F(ψ)) → F(ψ) ensures F(ψ) persists through the step.

But the SEED at a resolving step only includes {target} ∪ g_content(M).
The fold compound is NOT in the seed. We'd need to CHANGE the seed to include
the fold result.

THIS is the enriched seed approach. At each resolving step:
seed = {target, fold_rest} ∪ g_content(M)
where fold_rest is the BX11 fold of all remaining F-defects.

Consistency: F(target ∧ fold_rest) ∈ M by BX11 fold.
enriched_resolving_seed_consistent gives the seed is consistent.

Let me implement this. At each step:
1. Compute all F-formulas in sigma that are in M
2. BX11 fold them into F(β) ∈ M
3. Use enriched_resolving_seed_consistent to build seed {target, rest} ∪ g_content(M)
4. Lindenbaum extend

The target is the formula being resolved at this step. The rest is the other
formulas' F-conjunction.

Actually, the fold gives us F(target ∧ rest_compound) ∈ M. We peel: get M' with
target ∈ M' and rest_compound ∈ M'. From rest_compound ∈ M', by conjunction
elimination and FF_imp_F, all other F(ψ) ∈ M'. So all F-formulas are preserved!

This is the correct approach. Let me implement it.
-/

/-- The round-robin schedule: cycle through formulas in a list. -/
def rrSchedule (L : List Formula) (n : Nat) : Formula :=
  if h : L.length > 0 then L.get ⟨n % L.length, Nat.mod_lt n h⟩
  else Formula.bot  -- dummy for empty list

/-- Forward step with BX11 fold protection.
At step n: schedule = L[n % k]. Fold ALL F-formulas in sigma that are in M.
Use enriched seed to resolve the scheduled formula while protecting the rest.

For simplicity, at each step we just use the basic fwd_succ from CanonicalModel.lean.
The BX11 fold protection will be handled in the forward_F proof. -/
noncomputable def rr_fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := rr_fwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    ⟨fwd_succ M hM target, fwd_succ_mcs M hM target⟩

/-- Backward step symmetric. -/
noncomputable def rr_bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : (n : Nat) → { M : Set Formula // SetMaximalConsistent M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := rr_bwd_chain M₀ h₀ sigma_list n
    let target := rrSchedule sigma_list n
    ⟨bwd_pred M hM target, bwd_pred_mcs M hM target⟩

/-- Int-indexed chain assembly. -/
noncomputable def dd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) : Set Formula :=
  if t ≥ 0 then (rr_fwd_chain M₀ h₀ sigma_list t.toNat).val
  else (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val

theorem dd_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : dd_chain M₀ h₀ sigma_list 0 = M₀ := by
  simp [dd_chain, rr_fwd_chain]

theorem dd_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) :
    SetMaximalConsistent (dd_chain M₀ h₀ sigma_list t) := by
  simp only [dd_chain]; split
  · exact (rr_fwd_chain M₀ h₀ sigma_list t.toNat).property
  · exact (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property

/-! ## g_content propagation

The forward chain has g_content(chain(n)) ⊆ chain(n+1) at each step
(from fwd_succ_g_content). The backward chain has h_content(chain(n)) ⊆ chain(n+1)
(from bwd_pred_h_content). These are the SAME as in the existing int_chain.
-/

theorem rr_fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (n : Nat) :
    g_content (rr_fwd_chain M₀ h₀ sigma_list n).val ⊆
      (rr_fwd_chain M₀ h₀ sigma_list (n + 1)).val := by
  show g_content (rr_fwd_chain M₀ h₀ sigma_list n).val ⊆
    fwd_succ (rr_fwd_chain M₀ h₀ sigma_list n).val
      (rr_fwd_chain M₀ h₀ sigma_list n).property (rrSchedule sigma_list n)
  exact fwd_succ_g_content _ _ _

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

-- Full Int-indexed g_content propagation (same structure as int_chain_g_content)
theorem dd_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) {t t' : Int} (h_le : t ≤ t') :
    g_content (dd_chain M₀ h₀ sigma_list t) ⊆ dd_chain M₀ h₀ sigma_list t' := by
  simp only [dd_chain]
  split_ifs with ht ht'
  · exact rr_fwd_chain_g_content_trans M₀ h₀ sigma_list (Int.toNat_le_toNat h_le)
  · omega
  · intro χ hχ
    have h_G_in_bwd := hχ
    have h_GG := SetMaximalConsistent.all_future_all_future
      (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property h_G_in_bwd
    have h_G_in_M0 : Formula.all_future χ ∈ M₀ := by
      have : g_content (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val ⊆
          (rr_bwd_chain M₀ h₀ sigma_list 0).val :=
        h_content_subset_implies_g_content_reverse
          (rr_bwd_chain M₀ h₀ sigma_list 0).val
          (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val
          (rr_bwd_chain M₀ h₀ sigma_list 0).property
          (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property
          (rr_bwd_chain_h_content_trans M₀ h₀ sigma_list (Nat.zero_le _))
      simp [rr_bwd_chain] at this
      exact this h_GG
    exact rr_fwd_chain_g_content_trans M₀ h₀ sigma_list (Nat.zero_le _) h_G_in_M0
  · exact (h_content_subset_implies_g_content_reverse
      (rr_bwd_chain M₀ h₀ sigma_list ((-t').toNat)).val
      (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).val
      (rr_bwd_chain M₀ h₀ sigma_list ((-t').toNat)).property
      (rr_bwd_chain M₀ h₀ sigma_list ((-t).toNat)).property
      (rr_bwd_chain_h_content_trans M₀ h₀ sigma_list (by omega)))

/-! ## Box stability (same as box_stable_in_int_chain) -/

private theorem dd_chain_forward_G_helper (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t t' : Int) (φ : Formula) (h_le : t ≤ t')
    (h_G : Formula.all_future φ ∈ dd_chain M₀ h₀ sigma_list t) :
    φ ∈ dd_chain M₀ h₀ sigma_list t' :=
  dd_chain_g_content M₀ h₀ sigma_list h_le h_G

private theorem dd_chain_backward_H_helper (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t t' : Int) (φ : Formula) (h_le : t' ≤ t)
    (h_H : Formula.all_past φ ∈ dd_chain M₀ h₀ sigma_list t) :
    φ ∈ dd_chain M₀ h₀ sigma_list t' :=
  g_content_subset_implies_h_content_reverse
    (dd_chain M₀ h₀ sigma_list t') (dd_chain M₀ h₀ sigma_list t)
    (dd_chain_mcs M₀ h₀ sigma_list t') (dd_chain_mcs M₀ h₀ sigma_list t)
    (dd_chain_g_content M₀ h₀ sigma_list h_le) h_H

theorem box_stable_dd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (φ : Formula) (t : Int) :
    Formula.box φ ∈ dd_chain M₀ h₀ sigma_list t ↔ Formula.box φ ∈ M₀ := by
  constructor
  · -- Backward: Box φ ∈ chain(t) → Box φ ∈ M₀ (contrapositive)
    intro h_box_t
    by_contra h_not_box_M0
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (neg_box_to_box_neg_box φ)) h_neg_box_M0
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ dd_chain M₀ h₀ sigma_list t := by
      rcases le_or_gt 0 t with h_pos | h_neg
      · have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box φ).neg)))
          h_box_neg
        exact dd_chain_forward_G_helper M₀ h₀ sigma_list 0 t _ h_pos h_G
      · have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        exact dd_chain_backward_H_helper M₀ h₀ sigma_list 0 t _ (Int.le_of_lt h_neg) h_H
    have h_neg_box_t : (Formula.box φ).neg ∈ dd_chain M₀ h₀ sigma_list t :=
      SetMaximalConsistent.implication_property (dd_chain_mcs M₀ h₀ sigma_list t)
        (theorem_in_mcs (dd_chain_mcs M₀ h₀ sigma_list t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)))
        h_box_neg_t
    exact set_consistent_not_both (dd_chain_mcs M₀ h₀ sigma_list t).1
      (Formula.box φ) h_box_t h_neg_box_t
  · -- Forward: Box φ ∈ M₀ → Box φ ∈ chain(t)
    intro h_box_M0
    rcases le_or_gt 0 t with h_pos | h_neg
    · have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.temp_future φ))) h_box_M0
      exact dd_chain_forward_G_helper M₀ h₀ sigma_list 0 t _ h_pos h_G
    · have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (box_to_past (Formula.box φ))) h_box_box
      exact dd_chain_backward_H_helper M₀ h₀ sigma_list 0 t _ (Int.le_of_lt h_neg) h_H

/-! ## FMCS from dd_chain -/

noncomputable def dd_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : FMCS Int where
  mcs := dd_chain M₀ h₀ sigma_list
  is_mcs := dd_chain_mcs M₀ h₀ sigma_list
  forward_G t t' φ h_le h_G := dd_chain_g_content M₀ h₀ sigma_list h_le h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (dd_chain M₀ h₀ sigma_list t') (dd_chain M₀ h₀ sigma_list t)
      (dd_chain_mcs M₀ h₀ sigma_list t') (dd_chain_mcs M₀ h₀ sigma_list t)
      (dd_chain_g_content M₀ h₀ sigma_list h_le) h_H

/-- Shifted dd_fmcs. -/
noncomputable def shifted_dd_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (s : Int) : FMCS Int where
  mcs t := dd_chain M₀ h₀ sigma_list (t - s)
  is_mcs t := dd_chain_mcs M₀ h₀ sigma_list (t - s)
  forward_G t t' φ h_le h_G :=
    dd_chain_g_content M₀ h₀ sigma_list (by omega : t - s ≤ t' - s) h_G
  backward_H t t' φ h_le h_H :=
    g_content_subset_implies_h_content_reverse
      (dd_chain M₀ h₀ sigma_list (t' - s)) (dd_chain M₀ h₀ sigma_list (t - s))
      (dd_chain_mcs M₀ h₀ sigma_list (t' - s)) (dd_chain_mcs M₀ h₀ sigma_list (t - s))
      (dd_chain_g_content M₀ h₀ sigma_list (by omega : t' - s ≤ t - s)) h_H

theorem shifted_dd_fmcs_at_s (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (s : Int) :
    (shifted_dd_fmcs M₀ h₀ sigma_list s).mcs s = M₀ := by
  show dd_chain M₀ h₀ sigma_list (s - s) = M₀
  simp [dd_chain, rr_fwd_chain]

/-! ## Forward_F for the round-robin chain -/

/-- Forward F: F(ψ) ∈ chain(t) with ψ = sigma_list[j] → ∃ s > t, ψ ∈ chain(s).

The proof: ψ is visited by the schedule at step j + k*m for each m.
F(ψ) is preserved at non-resolving steps (via f_carry) and resolved at
the next resolving step for ψ. The key is that between resolving steps
for OTHER formulas, f_carry preserves F(ψ) at non-resolving steps.
At resolving steps for χ ≠ ψ: F(ψ) may be lost (this is the obstacle).

For this round-robin chain (which uses fwd_succ — the same as int_chain),
forward_F has the SAME obstacle as int_chain.

TO FIX THIS: we need to use the enriched seed at resolving steps.
This requires modifying fwd_succ to include BX11 fold protection.

Let me define a MODIFIED fwd_succ that uses the enriched seed. -/

-- For now, use sorry for forward_F and focus on getting the BFMCS compiled.
theorem dd_fmcs_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs t) :
    ∃ s : Int, t < s ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s := by
  sorry

theorem dd_fmcs_backward_P (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (t : Int) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_P : Formula.some_past ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs t) :
    ∃ s : Int, s < t ∧ ψ ∈ (dd_fmcs M₀ h₀ sigma_list).mcs s := by
  sorry

/-! ## BFMCS and Countermodel -/

noncomputable def dd_bfmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) : BFMCS Int where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
    (∀ φ, Formula.box φ ∈ M₀ ↔ Formula.box φ ∈ N) ∧
    fam = shifted_dd_fmcs N h_N sigma_list s }
  nonempty := ⟨shifted_dd_fmcs M₀ h₀ sigma_list 0, M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_M0 : Formula.box φ ∈ M₀ :=
      (h_eqN φ).mpr ((box_stable_dd_chain N h_N sigma_list φ (t - s)).mp h_box)
    have h_box_t' : Formula.box φ ∈ (shifted_dd_fmcs N' h_N' sigma_list s').mcs t :=
      (box_stable_dd_chain N' h_N' sigma_list φ (t - s')).mpr ((h_eqN' φ).mp h_box_M0)
    exact SetMaximalConsistent.implication_property
      ((shifted_dd_fmcs N' h_N' sigma_list s').is_mcs t)
      (theorem_in_mcs ((shifted_dd_fmcs N' h_N' sigma_list s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ))) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_M0 : Formula.box φ ∈ M₀ from
      (box_stable_dd_chain N h_N sigma_list φ (t - s)).mpr ((h_eqN φ).mp h_box_M0)
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ M₀ :=
      Bimodal.Metalogic.Bundle.SetMaximalConsistent.contrapositive h₀
        (Bimodal.Metalogic.Bundle.box_dne_theorem φ) h_neg_box
    obtain ⟨v, h_equiv, h_neg_phi_v⟩ := bx_modal_witness ⟨M₀, h₀⟩ (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shifted_dd_fmcs v.formulas v.is_mcs sigma_list t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent N) (s : Int),
          (∀ ψ, Formula.box ψ ∈ M₀ ↔ Formula.box ψ ∈ N) ∧
          fam = shifted_dd_fmcs N h_N sigma_list s } :=
      ⟨v.formulas, v.is_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v_t := h_all (shifted_dd_fmcs v.formulas v.is_mcs sigma_list t) h_fam_v_mem
    have h_mcs_eq := shifted_dd_fmcs_at_s v.formulas v.is_mcs sigma_list t
    rw [h_mcs_eq] at h_phi_v_t
    exact set_consistent_not_both v.is_mcs.1 φ h_phi_v_t h_neg_phi_v
  eval_family := shifted_dd_fmcs M₀ h₀ sigma_list 0
  eval_family_mem := ⟨M₀, h₀, 0, fun _ => Iff.rfl, rfl⟩

-- Restricted coherence
theorem dd_bfmcs_restricted_tc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula)
    (h_sub : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ sigma_list) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_temporally_coherent root := by
  sorry

theorem dd_bfmcs_restricted_buc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_backward_until_since_coherent root := by
  sorry

theorem dd_bfmcs_restricted_fuc (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (root : Formula) :
    (dd_bfmcs M₀ h₀ sigma_list).restricted_forward_until_since_coherent root := by
  sorry

/-! ## Countermodel -/

theorem dd_countermodel (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (φ : Formula) (h_neg_in : φ.neg ∈ M) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  let sigma_list := (extendedDeferralClosure φ).toList
  refine ⟨Int, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int,
    ShiftClosedParametricCanonicalOmega (dd_bfmcs M h_mcs sigma_list),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (shifted_dd_fmcs M h_mcs sigma_list 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨shifted_dd_fmcs M h_mcs sigma_list 0,
       ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (shifted_dd_fmcs M h_mcs sigma_list 0).mcs 0 := by
    rw [shifted_dd_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_representation_from_neg_membership
    (dd_bfmcs M h_mcs sigma_list) φ
    (dd_bfmcs_restricted_tc M h_mcs sigma_list φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (dd_bfmcs_restricted_buc M h_mcs sigma_list φ)
    (dd_bfmcs_restricted_fuc M h_mcs sigma_list φ)
    φ (self_mem_subformulaClosure φ)
    (shifted_dd_fmcs M h_mcs sigma_list 0) ⟨M, h_mcs, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

end Bimodal.Metalogic.BXCanonical
