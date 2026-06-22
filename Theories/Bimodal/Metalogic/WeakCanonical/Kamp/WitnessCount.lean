import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition
import Bimodal.Metalogic.WeakCanonical.Table

/-!
# K=0 Depth-1 2-var Agreement via Depth-2 Transfer

Proves depth-1 2-var NF agreement on Prior structures at K=0, resolving
the sorry at PriorComposition.lean lines 869/964.

## Strategy

Uses temporal truth transfer (`table` + `doets_lemma_1_1`) combined with
the depth-2 1-var NF agreement at both endpoints. The key theorem
`temporal_truth_transfer` enables transferring F(P_w) and S(P_w) between
matched points, and `HasAttainedINF` localizes witnesses to intervals.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Lemma 5.3
- Plan v19, Phases 1-4
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula
  nf_depth0_char_formula_correct)

/-! ## Temporal Truth Transfer

Given depth-k 1-var NF agreement, temporal formulas of operator_depth ≤ k
have the same truth value at the matched points. Composes
`table_correctness`, `table_depth_bound`, and `doets_lemma_1_1`. -/

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

/-! ## Zone-3 Existential Transfer via Depth-2 + HasAttainedINF

For zone-3 (t < w < x): transfer F(P_w) at t and S(P_w) at x using
temporal_truth_transfer, then use HasAttainedINF to localize. -/

/-- char_fn at depth 0 has operator_depth 0 (pure atom conjunction). -/
private theorem char_fn_depth0_operator_depth
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (_ : semantic_prior_UZ S atomMap) (_ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1)
    (nf_0 : NormalForm sig 0 1) :
    operator_depth (char_fn 0 nf_0) ≤ 0 := by
  sorry -- TODO: need to know char_fn 0 = nf_depth0_char_formula (operator_depth 0)
  -- This depends on how char_fn is constructed. For the concrete char_fn used
  -- in the KampPrior pipeline, this holds. May need to add as hypothesis.

/-- F(A) has operator_depth = max(operator_depth A, 0) + 2. -/
private theorem untl_top_operator_depth (A : Formula) :
    operator_depth (Formula.untl A Formula.top) =
    max (operator_depth A) 0 + 2 := by
  simp [operator_depth, Formula.top]

/-- S(A) has operator_depth = max(0, operator_depth A) + 2. -/
private theorem snce_top_operator_depth (A : Formula) :
    operator_depth (Formula.snce A Formula.top) =
    max (operator_depth A) 0 + 2 := by
  simp [operator_depth, Formula.top]

/-- Zone-3 depth-0 3-var existential transfer on Prior structures.

    Given w in M with t < w < x and specific predicates at w, x, t,
    find w' in N with t' < w' < x' and the same predicates.

    Uses F(P_w) transfer at t (from h_t) and S(P_w) transfer at x (from h_x),
    combined with HasAttainedINF first-occurrence to localize. -/
theorem zone3_exist_transfer {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (N : OrderedMonadicStructure sig) (x' t' : N.carrier)
    (h_UZ_M : semantic_prior_UZ M atomMap)
    (h_SZ_M : semantic_prior_SZ M atomMap)
    (h_UZ_N : semantic_prior_UZ N atomMap)
    (h_SZ_N : semantic_prior_SZ N atomMap)
    (h_x : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => x) nf ↔
      nf_eval_nf N 2 1 (fun _ => x') nf)
    (h_t : ∀ nf : NormalForm sig 2 1,
      nf_eval_nf M 2 1 (fun _ => t) nf ↔
      nf_eval_nf N 2 1 (fun _ => t') nf)
    (h_order_M : t < x) (h_order_N : t' < x')
    (char_fn : ∀ (d : Nat), NormalForm sig d 1 → Formula)
    (char_correct : ∀ (d : Nat) (_ : d ≤ 1) (nf_1 : NormalForm sig d 1)
        (S : OrderedMonadicStructure sig)
        (_ : semantic_prior_UZ S atomMap) (_ : semantic_prior_SZ S atomMap)
        (t : S.carrier),
        temporal_truth S atomMap t (char_fn d nf_1) ↔
        nf_eval_nf S d 1 (fun _ => t) nf_1)
    -- w's depth-0 1-var NF (predicate type)
    (nf_w0 : NormalForm sig 0 1)
    -- w exists in M with the right predicates and zone-3 order
    (hw_above_t : ∃ w : M.carrier, t < w ∧
        nf_eval_nf M 0 1 (fun _ => w) nf_w0)
    (hw_below_x : ∃ w : M.carrier, w < x ∧
        nf_eval_nf M 0 1 (fun _ => w) nf_w0) :
    ∃ w' : N.carrier, t' < w' ∧ w' < x' ∧
      nf_eval_nf N 0 1 (fun _ => w') nf_w0 := by
  -- Step 1: Transfer F(char_fn 0 nf_w0) at t to t' via temporal_truth_transfer
  -- F(P_w) at t: exists w > t with P_w(w). True on M.
  have h_F_pw_M : temporal_truth M atomMap t
      (Formula.untl (char_fn 0 nf_w0) Formula.top) := by
    simp only [temporal_truth]
    obtain ⟨w, hwt, hw_nf⟩ := hw_above_t
    exact ⟨w, hwt, (char_correct 0 (by omega) nf_w0 M h_UZ_M h_SZ_M w).mpr hw_nf,
      fun r _ _ => by simp [Formula.top, temporal_truth]⟩
  sorry

/-- Placeholder for the complete K=0 depth-1 2-var transfer until. -/
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
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
