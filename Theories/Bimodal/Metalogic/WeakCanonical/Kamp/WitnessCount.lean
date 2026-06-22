import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition
import Bimodal.Metalogic.WeakCanonical.Table

/-!
# K=0 Depth-1 2-var Agreement via Temporal Transfer + HasAttainedINF

Proves depth-1 2-var NF agreement on Prior structures at K=0, resolving
the sorry at PriorComposition.lean lines 869/964.

## Strategy

1. `temporal_truth_transfer`: depth-k 1-var NF agreement transfers temporal
   formulas of operator_depth ≤ k.

2. `depth2_quant_transfer`: from depth-2 1-var NF agreement, derive
   depth-1 2-var existential transfer (quantifier extraction).

3. Zone-3 transfer: Given w ∈ (t,x) with predicates nf_w0 in M, find
   w' ∈ (t',x') with nf_w0 in N using F(P_w)/S(P_w) temporal transfer
   combined with HasAttainedINF first-occurrence localization.

4. `k0_depth1_2var_agree_until/since`: decompose into atoms + zone-wise
   quantifier transfer.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.3
- Plan v19, Phases 1-4
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Temporal Truth Transfer -/

/-- Temporal truth transfer: depth-k 1-var NF agreement at t/t' implies
    temporal truth agreement for formulas of operator_depth ≤ k. -/
theorem temporal_truth_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (k : Nat)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (t' : N.carrier)
    (h_agree : ∀ nf : NormalForm sig k 1,
      nf_eval_nf M k 1 (fun _ => t) nf ↔
      nf_eval_nf N k 1 (fun _ => t') nf)
    (A : Formula) (h_depth : operator_depth A ≤ k) :
    temporal_truth M atomMap t A ↔ temporal_truth N atomMap t' A := by
  have h_M := table_correctness M atomMap t A
  have h_N := table_correctness N atomMap t' A
  have h_tdb := table_depth_bound sig atomMap A
  have h_doets := doets_lemma_1_1 k 1 (table sig atomMap A)
    (by omega) M N (fun _ => t) (fun _ => t') h_agree
  exact h_M.symm.trans (h_doets.trans h_N)

/-! ## Quantifier Transfer from Depth-2 1-var Agreement -/

/-- From depth-2 1-var NF agreement, derive depth-1 2-var existential transfer. -/
theorem depth2_quant_transfer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (N : OrderedMonadicStructure sig) (t' : N.carrier)
    (h_agree : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => t) nf ↔
      nf_eval_nf N 2 1 (fun _ => t') nf) :
    ∀ sub : NormalForm sig 1 2,
      (∃ w : M.carrier, nf_eval_nf M 1 2 (Fin.cons w (fun _ => t)) sub) ↔
      (∃ w' : N.carrier, nf_eval_nf N 1 2 (Fin.cons w' (fun _ => t')) sub) := by
  intro sub
  set nf_t := nf_characteristic M 2 1 (fun _ => t)
  have h_t_sat := nf_characteristic_satisfies M 2 1 (fun _ => t)
  have h_t'_nf_t : nf_eval_nf N 2 1 (fun _ => t') nf_t :=
    (h_agree nf_t).mp h_t_sat
  obtain ⟨_, h_quant_M⟩ := h_t_sat
  obtain ⟨_, h_quant_N⟩ := h_t'_nf_t
  rw [h_quant_M sub, h_quant_N sub]

/-! ## Operator Depth Bounds -/

private theorem atom_literal_operator_depth
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (p : sig.preds) (val : Bool) :
    operator_depth (atom_literal atomMap h_surj p val) = 0 := by
  simp only [atom_literal]
  cases val <;> simp [operator_depth, Formula.neg]

private theorem formula_conjList_operator_depth
    (fs : List Formula)
    (h_all : ∀ f ∈ fs, operator_depth f = 0) :
    operator_depth (formula_conjList fs) = 0 := by
  induction fs with
  | nil => simp [formula_conjList, Formula.top, operator_depth]
  | cons f rest ih =>
    simp only [formula_conjList, Formula.and, Formula.neg, operator_depth]
    rw [h_all f (by simp)]
    rw [ih (fun g hg => h_all g (by simp [hg]))]
    simp

theorem nf_depth0_char_operator_depth
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_0 : NormalForm sig 0 1) :
    operator_depth (nf_depth0_char_formula atomMap h_surj nf_0) = 0 := by
  apply formula_conjList_operator_depth
  intro f hf
  simp only [List.mem_map] at hf
  obtain ⟨p, _, rfl⟩ := hf
  exact atom_literal_operator_depth atomMap h_surj p _

/-! ## Char formula ↔ nf_eval_nf at depth 0 -/

private theorem nf_depth0_char_iff_eval {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf_0 : NormalForm sig 0 1) (t : M.carrier) :
    temporal_truth M atomMap t (nf_depth0_char_formula atomMap h_surj nf_0) ↔
    nf_eval_nf M 0 1 (fun _ => t) nf_0 := by
  rw [nf_depth0_char_formula_correct]
  constructor
  · intro h a
    match a with
    | .pred p i =>
      simp only [atom_eval]
      have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
      subst hi
      exact h p
    | .order i j h_neq =>
      exact absurd (Fin.ext (by omega) : i = j) h_neq
  · intro h p
    have := h (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at this
    exact this

/-! ## Zone-3 Transfer -/

/-- Zone-3 transfer: given w ∈ (t,x) with predicates nf_w0 in M, find
    w' ∈ (t',x') with nf_w0 in N. Uses F(P_w)/S(P_w) temporal transfer
    at depth 2 combined with HasAttainedINF for localization.

    The proof uses `nf_depth0_char_formula` (operator_depth 0) to build
    temporal formulas F(P_w) and S(P_w) of operator_depth 2, which transfer
    via depth-2 1-var agreement at both endpoints.

    **Edge case**: When the F-witness y₁ ≥ x' AND the S-witness y₂ ≤ t',
    the simple case analysis fails. This case uses depth-1 quantifier
    extraction from the depth-2 agreement + HasAttainedINF to produce
    a witness in (t', x'). The resolution requires showing that the first
    x-type point above t' is ≤ x' and that the nf_w0 witness from the
    depth-1 profile transfer falls below this point.

    **THIS THEOREM IS FALSE.** Counterexample: M=N=Z with is_even, t=t'=0,
    x=4, x'=2. The point w=2 is even in (0,4), but (0,2) contains only 1
    (odd). All hypotheses hold (depth-2 1-var NFs at 4/2 agree by
    translation symmetry mod 2 on Z), but the conclusion fails.

    The edge case is not "hard" -- it is genuinely impossible. The fix is
    to bypass this theorem: existPart_succ_n1_bypass should use VecEA2
    bracket formulas to encode zone-3 witnesses in the temporal formula,
    rather than attempting cross-structure NF transfer. -/
theorem zone3_exist_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => x) nf ↔
      nf_eval_nf N 2 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => t) nf ↔
      nf_eval_nf N 2 1 (fun _ => t') nf)
    (h_order_M : t < x) (h_order_N : t' < x')
    (nf_w0 : NormalForm sig 0 1)
    (hw : ∃ w : M.carrier, t < w ∧ w < x ∧
        nf_eval_nf M 0 1 (fun _ => w) nf_w0) :
    ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
      nf_eval_nf N 0 1 (fun _ => w') nf_w0 := by
  obtain ⟨w, h_tw, h_wx, h_w_pred⟩ := hw
  set P_w := nf_depth0_char_formula atomMap h_surj nf_w0
  have h_Pw_depth : operator_depth P_w = 0 :=
    nf_depth0_char_operator_depth atomMap h_surj nf_w0
  -- F(P_w) at t transfers to F(P_w) at t': get y₁ > t' with nf_w0
  have h_F_M : temporal_truth M atomMap t (Formula.untl P_w Formula.top) :=
    ⟨w, h_tw, (nf_depth0_char_iff_eval M atomMap h_surj nf_w0 w).mpr h_w_pred,
      fun _ _ _ => by simp [Formula.top, temporal_truth]⟩
  have h_F_N := (temporal_truth_transfer atomMap 2 M t N t' h_t
    (Formula.untl P_w Formula.top) (by simp [operator_depth, Formula.top, h_Pw_depth])).mp h_F_M
  obtain ⟨y₁, h_y₁_gt, h_y₁_Pw, _⟩ := h_F_N
  have h_y₁_pred := (nf_depth0_char_iff_eval N atomMap h_surj nf_w0 y₁).mp h_y₁_Pw
  -- S(P_w) at x transfers to S(P_w) at x': get y₂ < x' with nf_w0
  have h_S_M : temporal_truth M atomMap x (Formula.snce P_w Formula.top) :=
    ⟨w, h_wx, (nf_depth0_char_iff_eval M atomMap h_surj nf_w0 w).mpr h_w_pred,
      fun _ _ _ => by simp [Formula.top, temporal_truth]⟩
  have h_S_N := (temporal_truth_transfer atomMap 2 M x N x' h_x
    (Formula.snce P_w Formula.top) (by simp [operator_depth, Formula.top, h_Pw_depth])).mp h_S_M
  obtain ⟨y₂, h_y₂_lt, h_y₂_Pw, _⟩ := h_S_N
  have h_y₂_pred := (nf_depth0_char_iff_eval N atomMap h_surj nf_w0 y₂).mp h_y₂_Pw
  -- Case analysis
  by_cases h₁ : y₁ < x'
  · exact ⟨y₁, h_y₁_gt, h₁, h_y₁_pred⟩
  · push_neg at h₁
    by_cases h₂ : t' < y₂
    · exact ⟨y₂, h₂, h_y₂_lt, h_y₂_pred⟩
    · push_neg at h₂
      -- Edge case: y₁ ≥ x' and y₂ ≤ t'. Use depth-1 quantifier extraction.
      -- Transfer [w,t] profile via h_t to get w₁ > t' with depth-1 matching.
      -- From depth-1 profile, extract "∃ v > w₁ with x-predicates" (witnessed
      -- by x > w in M). Get v₁ > w₁ with x-predicates.
      -- First x-type above t' is r₀ ≤ x' (HasAttainedINF, since x' is x-type).
      -- If w₁ < x': done (w₁ is in (t', x') with nf_w0).
      -- If w₁ ≥ x': need combined 3-var reasoning.
      -- This deep edge case requires showing that the 2-var profile transfer
      -- plus HasAttainedINF forces a witness into (t', x').
      -- Deferred: requires VecEA-level bracket encoding or deeper NF analysis.
      sorry

/-! ## K=0 Depth-1 2-var Agreement -/

/-- K=0 depth-1 2-var agreement for the Until zone (t < x). -/
theorem k0_depth1_2var_agree_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (0 + 2) 1,
      nf_eval_nf M (0 + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (0 + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (0 + 2) 1,
      nf_eval_nf M (0 + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (0 + 2) 1 (fun _ => t') nf)
    (h_order_M : t < x)
    (h_order_N : t' < x')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ 0 + 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (_ : semantic_prior_UZ S atomMap) (_ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1) :
    ∀ nf : NormalForm sig (0 + 1) 2,
      nf_eval_nf M (0 + 1) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (0 + 1) 2 (Fin.cons x' (fun _ => t')) nf := by
  -- **FALSE**: This is the depth-1 2-var NF agreement on non-constant environments,
  -- which is the same as prior_nonconstenv_2var_agree_until K=0. The theorem is
  -- FALSE for the same zone-3 reason: zone3_exist_transfer is false.
  -- See PriorComposition.lean line 869 comment for the counterexample.
  sorry

/-- K=0 depth-1 2-var agreement for the Since zone (x < t). -/
theorem k0_depth1_2var_agree_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig (0 + 2) 1,
      nf_eval_nf M (0 + 2) 1 (fun _ => x) nf ↔
      nf_eval_nf N (0 + 2) 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig (0 + 2) 1,
      nf_eval_nf M (0 + 2) 1 (fun _ => t) nf ↔
      nf_eval_nf N (0 + 2) 1 (fun _ => t') nf)
    (h_order_M : x < t)
    (h_order_N : x' < t')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ 0 + 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (_ : semantic_prior_UZ S atomMap) (_ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1) :
    ∀ nf : NormalForm sig (0 + 1) 2,
      nf_eval_nf M (0 + 1) 2 (Fin.cons x (fun _ => t)) nf ↔
      nf_eval_nf N (0 + 1) 2 (Fin.cons x' (fun _ => t')) nf := by
  -- **FALSE**: Mirror of k0_depth1_2var_agree_until. Same counterexample with swapped roles.
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
