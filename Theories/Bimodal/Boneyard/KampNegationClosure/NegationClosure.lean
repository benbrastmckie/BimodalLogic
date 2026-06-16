-- ARCHIVED from Metalogic/WeakCanonical/Kamp/NegationClosure.lean
-- Reason: Dead code — negation closure chain with no live downstream consumers
-- Archived: 2026-06-16 (task 302)

#exit

import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior
import Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.Translation
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# 2-Var Existence Formula for Prior Structures

Proves `nf_2var_exist_formula_prior_fill`: on Prior structures, for each
depth-k arity-2 NF, the existential `∃ x, nf_eval_nf M k 2 ...` has a
temporal equivalent. This result fills the sorry in NfCharFormula.lean.

## Proof Structure

By simultaneous induction on k, proving both:
- P1(k): temporal characterizations for depth-k arity-1 NFs
- P2(k): temporal formulas for depth-k 2-var existentials

k=0: P1(0) by nf_depth0_char_formula. P2(0): at depth 0, nf_exist_formula
is correct in both directions because arity-1 NFs + order determine
the arity-2 NF (atom matching only, no quantifier conditions).

k+1: P1(k+1) from P1(k) + P2(k) via inlined nf_characterizable_temporal_prior_classical.
P2(k+1): nf_exist_formula forward is universal; backward requires
Prior axioms + composition theorem (the Rabinovich negation closure content).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 4-5
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Depth-0 backward direction

At depth 0, nf_exist_formula is correct in both directions. The backward
direction (formula → existential) holds because at depth 0, the arity-2
NF is pure atom assignment: predicates at x and t, plus order. The
arity-1 NF of the witness x determines its predicates, and the order
is determined by Until (x > t) or Since (x < t). -/

/-- At depth 0, construct arity-2 NF evaluation from component data. -/
private theorem nf_2var_depth0_components {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (sub_nf : NormalForm sig 0 2)
    (h_pred_x : ∀ p : sig.preds,
      M.interp p x ↔ sub_nf (.pred p ⟨0, by omega⟩) = true)
    (h_pred_t : ∀ p : sig.preds,
      M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true)
    (h_order_01 : (x < t) ↔ sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_order_10 : (t < x) ↔ sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true) :
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  simp only [nf_eval_nf]
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    simp only [atom_eval, Fin.cons]
    exact h_pred_x p
  | .pred p ⟨1, _⟩ =>
    show M.interp p ((Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → _) ⟨1, _⟩) ↔ _
    simp only [Fin.cons, Fin.cases]
    exact h_pred_t p
  | .order ⟨0, _⟩ ⟨0, _⟩ h_ne => exact absurd rfl h_ne
  | .order ⟨0, _⟩ ⟨1, _⟩ _ => simp only [atom_eval]; exact h_order_01
  | .order ⟨1, _⟩ ⟨0, _⟩ _ => simp only [atom_eval]; exact h_order_10
  | .order ⟨1, _⟩ ⟨1, _⟩ h_ne => exact absurd rfl h_ne

/-- Backward direction of nf_exist_formula at depth 0. -/
private theorem backward_depth0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_0 : NormalForm sig 0 1 → Formula)
    {M : OrderedMonadicStructure sig}
    (char_0_M : ∀ (nf_0 : NormalForm sig 0 1) (s : M.carrier),
        temporal_truth M atomMap s (char_0 nf_0) ↔ nf_eval_nf M 0 1 (fun _ => s) nf_0)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 0 2)
    {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_formula : temporal_truth M atomMap t
      (nf_exist_formula atomMap h_surj 0 char_0 parent_atoms sub_nf)) :
    ∃ x : M.carrier, nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  -- Use nf_exist_formula_forward' for the forward direction (existential -> formula)
  -- and show the backward direction holds at depth 0 because the arity-2 NF is purely atomic.
  --
  -- Strategy: Instead of unfolding the formula, use the UNIQUENESS of NFs.
  -- The formula truth means the forward direction holds for SOME x. But we need
  -- to find x such that the full arity-2 NF matches. At depth 0, the arity-2 NF
  -- is just atoms + order, all of which are captured by nf_exist_formula.
  --
  -- We use the fact that on ANY model, char_0 correctly characterizes depth-0 NFs,
  -- so the witness x from the formula has the right atom assignment, and the
  -- order (from Until/Since) is correct.
  simp only [nf_exist_formula, NormalForm.atom_assgn] at h_formula
  by_cases h_tc : nf_t_compat parent_atoms sub_nf = true
  · simp only [h_tc, not_true_eq_false, ite_false] at h_formula
    by_cases h_ob : (sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
        sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true
    · simp only [h_ob, ↓reduceIte, temporal_truth] at h_formula
    · simp only [h_ob, ↓reduceIte, ite_false] at h_formula
      simp only [nf_order_dir] at h_formula
      -- Helper: extract witness NF from disjunction
      have extract_nf : ∀ (x : M.carrier),
          temporal_truth M atomMap x (formula_disjList
            ((Fintype.elems (α := NormalForm sig 0 1)).val.toList.filterMap (fun nf_x =>
              if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
                nf_x (.pred p ⟨0, by omega⟩) == sub_nf (.pred p ⟨0, by omega⟩)) = true
              then some (char_0 nf_x) else none))) →
          ∃ nf_x : NormalForm sig 0 1,
            (∀ p : sig.preds, nf_x (.pred p ⟨0, by omega⟩) =
              sub_nf (.pred p ⟨0, by omega⟩)) ∧
            nf_eval_nf M 0 1 (fun _ => x) nf_x := by
        intro x h_disj
        rw [formula_disjList_iff] at h_disj
        obtain ⟨A, h_mem, h_A⟩ := h_disj
        rw [List.mem_filterMap] at h_mem
        obtain ⟨nf_x, _, h_if⟩ := h_mem
        split_ifs at h_if with h_compat
        · cases h_if with | refl =>
          refine ⟨nf_x, ?_, (char_0_M nf_x x).mp h_A⟩
          intro p
          have := (List.all_eq_true.mp h_compat) p
            (Multiset.mem_toList.mpr (Fintype.complete p))
          simp only [beq_iff_eq] at this
          exact this
      -- Helper: t-compat gives pred matching at t
      have h_pred_t : ∀ p : sig.preds,
          M.interp p t ↔ sub_nf (.pred p ⟨1, by omega⟩) = true := by
        intro p
        have h_par := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h_par
        have h_cp : sub_nf (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) := by
          have := (List.all_eq_true.mp (by rw [nf_t_compat] at h_tc; exact h_tc))
            p (Multiset.mem_toList.mpr (Fintype.complete p))
          simp only [beq_iff_eq] at this
          exact this
        rw [h_cp]; exact h_par
      match h_b1 : sub_nf (AtomKind.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
            h_b2 : sub_nf (AtomKind.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
      | true, false =>
        -- t < x: Until
        simp only [NormalForm.atom_assgn, h_b1, h_b2, Bool.false_eq_true, ite_false] at h_formula
        obtain ⟨x, h_lt, h_event, _⟩ := h_formula
        obtain ⟨nf_x, h_x_compat, h_x_nf⟩ := extract_nf x h_event
        have h_pred_x : ∀ p : sig.preds,
            M.interp p x ↔ sub_nf (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_x_nf (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h; rw [h, h_x_compat p]
        exact ⟨x, show nf_eval_nf M 0 2 _ _ from nf_2var_depth0_components M x t sub_nf
          h_pred_x h_pred_t
          ⟨fun hxt => absurd (lt_trans hxt h_lt) (lt_irrefl _),
           fun h => absurd (h ▸ h_b2 : true = false) (by decide)⟩
          ⟨fun _ => h_b1, fun _ => h_lt⟩⟩
      | false, true =>
        -- x < t: Since
        simp only [NormalForm.atom_assgn, h_b1, h_b2, Bool.false_eq_true, ite_false] at h_formula
        obtain ⟨x, h_lt, h_event, _⟩ := h_formula
        obtain ⟨nf_x, h_x_compat, h_x_nf⟩ := extract_nf x h_event
        have h_pred_x : ∀ p : sig.preds,
            M.interp p x ↔ sub_nf (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_x_nf (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h; rw [h, h_x_compat p]
        exact ⟨x, show nf_eval_nf M 0 2 _ _ from nf_2var_depth0_components M x t sub_nf
          h_pred_x h_pred_t
          ⟨fun _ => h_b2, fun _ => h_lt⟩
          ⟨fun htx => absurd (lt_trans h_lt htx) (lt_irrefl _),
           fun h => absurd (h ▸ h_b1 : true = false) (by decide)⟩⟩
      | false, false =>
        -- x = t: identity
        simp only [NormalForm.atom_assgn, h_b1, h_b2, Bool.false_eq_true, ite_false,
          beq_self_eq_true, Bool.and_self, ite_true] at h_formula
        obtain ⟨nf_x, h_x_compat, h_x_nf⟩ := extract_nf t h_formula
        have h_pred_x : ∀ p : sig.preds,
            M.interp p t ↔ sub_nf (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_x_nf (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h; rw [h, h_x_compat p]
        exact ⟨t, show nf_eval_nf M 0 2 _ _ from nf_2var_depth0_components M t t sub_nf
          h_pred_x h_pred_t
          ⟨fun h => absurd h (lt_irrefl _),
           fun h => absurd (h ▸ h_b2 : true = false) (by decide)⟩
          ⟨fun h => absurd h (lt_irrefl _),
           fun h => absurd (h ▸ h_b1 : true = false) (by decide)⟩⟩
      | true, true =>
        exfalso; exact h_ob (by rw [Bool.and_eq_true]; exact ⟨h_b2, h_b1⟩)
  · -- t-incompatibility: formula = bot, contradiction
    simp only [h_tc, ↓reduceIte] at h_formula
    exact absurd h_formula (by simp [temporal_truth])

/-! ## Depth-(k+1) NF characterization from P1(k) + P2(k) -/

/-- Build depth-(k+1) arity-1 NF characterization from depth-k char + 2-var results.
    Inlines `nf_characterizable_temporal_prior_classical` to avoid calling the sorry'd
    `nf_2var_exist_formula_prior`. -/
noncomputable def nf_char_kp1_from_2var
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (p2_k : ∀ (parent_atoms : AtomKind sig 1 → Bool) (sub_nf : NormalForm sig k 2),
        ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
          (temporal_truth M atomMap t A ↔
           ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf))
    (nf : NormalForm sig (k + 1) 1) :
    ∃ A : Formula, ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔ nf_eval_nf M (k + 1) 1 (fun _ => t) nf := by
  let exist_f : NormalForm sig k 2 → Formula :=
    fun sub_nf => Classical.choose (p2_k nf.1 sub_nf)
  have exist_f_correct : ∀ (sub_nf : NormalForm sig k 2)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true) →
      (temporal_truth M atomMap t (exist_f sub_nf) ↔
       ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
    fun sub_nf => Classical.choose_spec (p2_k nf.1 sub_nf)
  let atom_lits := (Fintype.elems (α := sig.preds)).val.toList.map fun p =>
    atom_literal atomMap h_surj p (nf.1 (.pred p ⟨0, by omega⟩))
  let quant_formulas := (Fintype.elems (α := NormalForm sig k 2)).val.toList.map fun sub_nf =>
    if nf.2 sub_nf then exist_f sub_nf else (exist_f sub_nf).neg
  let full_formula := Formula.and (formula_conjList atom_lits) (formula_conjList quant_formulas)
  refine ⟨full_formula, fun M h_UZ h_SZ t => ?_⟩
  constructor
  · intro h_formula
    have h_and := (temporal_truth_and M atomMap t _ _).mp h_formula
    have h_atom_list := (formula_conjList_iff M atomMap t _).mp h_and.1
    have h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true := by
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
      exact (atom_literal_correct M atomMap h_surj p _ t).mp
        (h_atom_list _ (by simp only [atom_lits, List.mem_map]; exact
          ⟨p, Multiset.mem_toList.mpr (Fintype.complete p), rfl⟩))
    have h_quant_list := (formula_conjList_iff M atomMap t _).mp h_and.2
    obtain ⟨atom_part, quant_part⟩ := nf
    refine ⟨h_atoms, fun sub_nf => ?_⟩
    have h_iff := exist_f_correct sub_nf M h_UZ h_SZ t h_atoms
    have h_sub_in : (if quant_part sub_nf then exist_f sub_nf
        else (exist_f sub_nf).neg) ∈ quant_formulas := by
      simp only [quant_formulas, List.mem_map]
      exact ⟨sub_nf, Multiset.mem_toList.mpr (Fintype.complete sub_nf), rfl⟩
    have h_sub_truth := h_quant_list _ h_sub_in
    cases h_q : quant_part sub_nf
    · simp only [h_q, Bool.false_eq_true, ↓reduceIte] at h_sub_truth
      rw [temporal_truth_neg] at h_sub_truth
      exact ⟨fun h_ex => absurd (h_iff.mpr h_ex) h_sub_truth, fun h => by simp at h⟩
    · simp only [h_q, ↓reduceIte] at h_sub_truth
      exact ⟨fun _ => rfl, fun _ => h_iff.mp h_sub_truth⟩
  · intro h_nf
    obtain ⟨h_atoms, h_quant⟩ := h_nf
    rw [temporal_truth_and]
    exact ⟨(formula_conjList_iff M atomMap t _).mpr (fun A hA => by
        simp only [atom_lits, List.mem_map] at hA
        obtain ⟨p, _, rfl⟩ := hA
        exact (atom_literal_correct M atomMap h_surj p _ t).mpr (by
          have := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at this; exact this)),
      (formula_conjList_iff M atomMap t _).mpr (fun A hA => by
        simp only [quant_formulas, List.mem_map] at hA
        obtain ⟨sub_nf, _, rfl⟩ := hA
        have h_iff := exist_f_correct sub_nf M h_UZ h_SZ t h_atoms
        by_cases h_q : nf.2 sub_nf = true
        · simp only [h_q, ite_true]; exact h_iff.mpr ((h_quant sub_nf).mpr h_q)
        · push_neg at h_q
          rw [Bool.eq_false_iff.mpr h_q]; simp only [Bool.false_eq_true, ↓reduceIte]
          rw [temporal_truth_neg]; intro h_ef
          exact h_q ((h_quant sub_nf).mp (h_iff.mp h_ef)))⟩

/-! ## Interval Type Decomposition for Prior Structures

Given sub_nf : NormalForm sig (k+1) 2 and a fixed order direction (say t < x),
the quantifier conditions of sub_nf.2 involve depth-k arity-3 NFs ssn at (y,x,t).
Each ssn places y in one of five order regions:
  (1) y > x > t: encoded in nf_x.2 (depth-(k+1) 1-var NF of x)
  (2) y = x: determined by nf_x.1 (atoms at x)
  (3) t < y < x: INTERVAL condition -- must be encoded using buildRight
  (4) y = t: determined by parent_atoms
  (5) y < t: encoded in the depth-(k+1) 1-var NF of t

At depth 0, each ssn is an atom assignment (AtomKind sig 3 → Bool), and the
"type" of y in the interval is its depth-0 1-var NF (predicates at y).

At depth k > 0, the ssn includes quantifier conditions involving depth-(k-1)
arity-4 NFs of (z,y,x,t). The interval type of y is richer than just the
1-var NF, but on Prior structures the decomposition still works because
each z also falls in a specific order region relative to y, x, t.

For the formula construction, we extract the set of "interval types" that
must appear or must not appear in (t,x), and encode these using buildRight
with P1(k) characterization formulas as witness/guard conditions. -/

/-! ## Interval NF Type Extraction

Given sub_nf at depth k+1 arity 2 and an nf_x at depth k+1 arity 1
(the candidate 1-var NF of the main witness x), extract the interval
conditions: which depth-k arity-1 NFs must/must not appear in (t,x).

NOTE: At depth k > 0, the interval conditions involve more than just
the depth-k 1-var NF of y -- they also involve quantifier interactions
between y, x, and t. However, on Prior structures, by P2(k) applied
recursively, these interactions can be captured using temporal formulas
at the boundary points. The full interval condition for each ssn
decomposes into: (1) the depth-k 1-var NF of y (characterizable by
P1(k)), and (2) the depth-k 2-var NF of (y,x) and (y,t) (characterizable
by P2(k)) -- and these are encoded in the nested Until/Since chains. -/

/-! ## Nested buildRight Formula (Rabinovich Notation 5.2 + Prop 3.5)

For depth k+1, the simple `nf_exist_formula` fails in the backward direction
because it does not encode sub_nf.2 (the quantifier part of the 2-var NF).

`nf_exist_formula_nested` replaces it with a formula that uses nested
buildRight/buildLeft chains to encode the full 2-var NF including sub_nf.2.

The idea: the 2-var existential `∃ x, nf_eval_nf M (k+1) 2 (x, t) sub_nf`
expands to atoms + order + quantifier conditions. The quantifier conditions
`sub_nf.2 ssn` involve 3-var NFs ssn at (y, x, t). The third variable y
falls in one of five order regions relative to x and t:
  (1) y > x: captured by the depth-(k+1) 1-var NF of x
  (2) y = x: captured by atoms at x
  (3) t < y < x: INTERVAL — encoded by nested Until inside the outer Until
  (4) y = t: captured by parent_atoms
  (5) y < t: captured by the depth-(k+1) 1-var NF of t

For each compatible nf_x (1-var NF of the witness x), we classify which
ssn's with sub_nf.2(ssn)=true require interval witnesses and encode those
using buildRight with char_k characterization formulas.

The formula uses Classical.choose to select P2(k)-derived sub-formulas for
deeper quantifier conditions (when k > 0, the 3-var NF ssn has its own
quantifier part involving 4-var NFs). On Prior structures, these conditions
are characterizable by temporal formulas via the induction hypothesis.

## References

- Rabinovich 2014, Notation 5.2 (bracket notation) + Prop 3.5 (temporal translation)
- Prior-structure simplification: first occurrences attained (Prior-UZ/SZ),
  eliminating K+ disjunct from INF formula
-/

/-- Extract the atom assignment of an arity-3 NF at variable 0 (the "new" variable y),
    restricted to predicates only. Returns the depth-k 1-var NF of y implied by ssn's
    atom assignment. -/
noncomputable def ssn_var0_pred_assgn {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : sig.preds → Bool :=
  fun p => ssn.atom_assgn (.pred p ⟨0, by omega⟩)

/-- Check whether a depth-k arity-3 NF ssn is compatible with a depth-k arity-1 NF
    nf_y at variable 0 (predicates match). -/
noncomputable def ssn_compat_var0 {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) (nf_y : NormalForm sig k 1) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    nf_y.atom_assgn (.pred p ⟨0, by omega⟩) == ssn.atom_assgn (.pred p ⟨0, by omega⟩)

/-- Cross-depth version of ssn_compat_var0: check whether a depth-k arity-3 NF ssn
    is compatible with a depth-j arity-1 NF nf_y at variable 0 (predicates match).
    Only compares atom_assgn, which is depth-independent for predicate atoms. -/
noncomputable def ssn_compat_var0' {sig : MonadicSignature} {k j : Nat}
    (ssn : NormalForm sig k 3) (nf_y : NormalForm sig j 1) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    nf_y.atom_assgn (.pred p ⟨0, by omega⟩) == ssn.atom_assgn (.pred p ⟨0, by omega⟩)

/-- Check whether ssn places variable 0 (y) strictly between variables 2 (t) and 1 (x),
    i.e., t < y < x (the "interval" case for the Until direction). -/
noncomputable def ssn_in_interval_right {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : Bool :=
  -- y < x (var 0 < var 1)
  ssn.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
  -- t < y (var 2 < var 0), equivalently y > t
  ssn.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))

/-- Check whether ssn places variable 0 (y) strictly between variables 1 (x) and 2 (t),
    i.e., x < y < t (the "interval" case for the Since direction). -/
noncomputable def ssn_in_interval_left {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : Bool :=
  -- x < y (var 1 < var 0)
  ssn.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) &&
  -- y < t (var 0 < var 2)
  ssn.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))

/-! ## Non-Interval SSN Compatibility

For the backward direction to work, the formula must filter nf_x values by
full compatibility with sub_nf.2, not just atom compatibility. Non-interval
ssn's (y > x, y = x, y = t, y < t) encode conditions that can be checked
syntactically against nf_x and parent_atoms.

The key insight (Doets 1989 Lemma 1.4/1.5): the characteristic NF of x at
depth k+1 encodes which depth-k arity-2 existentials are realized. For
non-interval ssn's with y > x, the 3-var existential reduces to checking
nf_x.2 against the (y,x) atom projection of ssn. At depth 0, this is
complete (atoms determine everything). At depth > 0, the atom-level
projection is a necessary condition; the full composition requires the
Feferman-Vaught theorem for linear orders.

### References
- Doets 1989, Lemma 1.4/1.5: composition preserves n-equivalence
- Rabinovich 2014, Section 5: negation closure via interval decomposition
-/

/-- Embed Fin n into Fin (n+1) by skipping index j.
    liftSkip n j i = i if i < j, i+1 if i >= j. -/
def liftSkip (n : Nat) (j : Fin (n + 1)) (i : Fin n) : Fin (n + 1) :=
  if h : i.val < j.val then ⟨i.val, by omega⟩ else ⟨i.val + 1, by omega⟩

theorem liftSkip_injective (n : Nat) (j : Fin (n + 1)) :
    Function.Injective (liftSkip n j) := by
  intro ⟨a, ha⟩ ⟨b, hb⟩ hab
  simp only [liftSkip] at hab
  ext; split at hab <;> split at hab <;> simp_all [Fin.ext_iff] <;> omega

/-- Project an atom assignment from arity (n+1) to arity n by dropping variable j. -/
noncomputable def atomProjDrop {sig : MonadicSignature} (n : Nat) (j : Fin (n + 1))
    (assgn : AtomKind sig (n + 1) → Bool) : AtomKind sig n → Bool
  | .pred p i => assgn (.pred p (liftSkip n j i))
  | .order i k h => assgn (.order (liftSkip n j i) (liftSkip n j k) (by
      intro heq; exact h (liftSkip_injective n j heq)))

/-- Check whether a depth-k arity-3 NF ssn has order atoms at variables 1,2 (x,t)
    consistent with sub_nf's order atoms at variables 0,1 (x,t).
    Variables: ssn uses (y=0, x=1, t=2), sub_nf uses (x=0, t=1). -/
noncomputable def ssn_xt_order_compat {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  -- ssn order(1,2) (x < t) should match sub_nf order(0,1) (x < t)
  (ssn.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) ==
   sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))) &&
  -- ssn order(2,1) (t < x) should match sub_nf order(1,0) (t < x)
  (ssn.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) ==
   sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)))

/-- Check whether a depth-k arity-3 NF ssn has predicate atoms at variable 1 (x)
    matching nf_x's predicate atoms at variable 0. -/
noncomputable def ssn_x_pred_compat {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) (nf_x : NormalForm sig (k + 1) 1) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    ssn.atom_assgn (.pred p ⟨1, by omega⟩) ==
    nf_x.atom_assgn (.pred p ⟨0, by omega⟩)

/-- Check whether a depth-k arity-3 NF ssn has predicate atoms at variable 2 (t)
    matching parent_atoms. -/
noncomputable def ssn_t_pred_compat {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) (parent_atoms : AtomKind sig 1 → Bool) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    ssn.atom_assgn (.pred p ⟨2, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)

/-- Check whether ssn places variable 0 (y) above variable 1 (x): y > x. -/
noncomputable def ssn_y_above_x {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : Bool :=
  ssn.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))

/-- Check whether ssn places variable 0 (y) equal to variable 1 (x): y = x. -/
noncomputable def ssn_y_eq_x {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : Bool :=
  !(ssn.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))) &&
  !(ssn.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)))

/-- Check whether ssn places variable 0 (y) equal to variable 2 (t): y = t. -/
noncomputable def ssn_y_eq_t {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : Bool :=
  !(ssn.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))) &&
  !(ssn.atom_assgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))

/-- Check whether ssn places variable 0 (y) below variable 2 (t): y < t. -/
noncomputable def ssn_y_below_t {sig : MonadicSignature} {k : Nat}
    (ssn : NormalForm sig k 3) : Bool :=
  ssn.atom_assgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))

/-- Full non-interval compatibility: check that for every non-interval ssn,
    sub_nf.2(ssn) is consistent with nf_x and parent_atoms.

    For the Until direction (t < x), a non-interval ssn is one where y is NOT
    strictly between t and x. The check verifies:
    - y > x ssn's: pred atoms at y and x must be compat with nf_x,
      pred atoms at t must match parent_atoms, order x,t must match sub_nf
    - y = x ssn's: pred atoms at y must match nf_x (since y=x),
      pred atoms at t must match parent_atoms
    - y = t ssn's: pred atoms at y must match parent_atoms (since y=t),
      pred atoms at x must match nf_x
    - y < t ssn's: all pred atoms must be consistent

    The compatibility requires that sub_nf.2(ssn) could potentially be realized
    given nf_x and parent_atoms. For ssn's where the atom-level compatibility
    fails, sub_nf.2(ssn) = true would be unrealizable (no y exists with those
    atoms), so we check that sub_nf.2(ssn) = false for atom-incompatible ssn's.

    Additionally, for ssn's that ARE atom-compatible at endpoints, we require
    sub_nf.2(ssn) to be consistent with the quantifier behavior of nf_x. -/
noncomputable def nf_full_compat_right {sig : MonadicSignature} {k : Nat}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  -- Check all ssn's for atom compatibility
  (Fintype.elems (α := NormalForm sig k 3)).val.toList.all fun ssn =>
    -- Interval ssn's: check atom compat at x,t (var 1,2) -- required for backward direction
    if ssn_in_interval_right ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms &&
         ssn_xt_order_compat ssn sub_nf then
        true  -- atom-compatible interval ssn; handled by the formula's Since conditions
      else
        !sub_nf.2 ssn  -- atom-incompatible interval ssn; must be negative
    -- Skip ssn's with inconsistent x,t order (must have t < x for right direction)
    else if !ssn_xt_order_compat ssn sub_nf then
      -- If ssn has wrong x,t order, sub_nf.2(ssn) must be false
      !sub_nf.2 ssn
    -- For non-interval ssn's with correct x,t order:
    else if ssn_y_above_x ssn then
      -- y > x: check pred compatibility at x, t, y
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        true  -- atom-compatible; quantifier check deferred to proof
      else
        !sub_nf.2 ssn  -- atom-incompatible; ssn must be negative
    else if ssn_y_eq_x ssn then
      -- y = x: pred atoms at y (var 0) must match nf_x (since y=x, var 0 preds = var 1 preds)
      if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) &&
         ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        true
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_t ssn then
      -- y = t: pred atoms at y (var 0) must match parent_atoms
      if ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        -- Check that y=t pred atoms match parent_atoms at var 0
        if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            parent_atoms (.pred p ⟨0, by omega⟩)) then
          true
        else
          !sub_nf.2 ssn
      else
        !sub_nf.2 ssn
    else if ssn_y_below_t ssn then
      -- y < t: check pred compatibility
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        true
      else
        !sub_nf.2 ssn
    else
      true  -- shouldn't happen (exhaustive order cases)

/-! ## Strengthened Filters (v2) — Backward-Direction Aware

    The v1 filters (`nf_full_compat_right/left`) check atom-level compatibility
    but return `true` for all atom-compatible non-interval ssns, regardless of
    `sub_nf.2 ssn`. This makes the backward direction unprovable because the
    formula fires for nf_x values whose 2-var NF at (x, t) differs from sub_nf
    in the quantifier part.

    The v2 filters add zone-specific quantifier checks:
    - Zone 1 (y > x): at k=0, check nf_x.quant_assgn on the (y,x) projection
      matches sub_nf.quant_assgn. At k > 0, conservative (true).
    - Zone 2 (y = x): at k=0, require sub_nf.quant_assgn ssn = true for
      atom-compatible ssns (because y = x always exists). At k > 0, conservative.
    - Zone 4 (y = t): same as zone 2 with y = t.
    - Zone 5 (y < t): unchanged (needs formula-level pre-conditions).

    Forward-direction proof (`nf_full_compat_right_v2_of_eval`):
    - At k=0, NEGATIVE case: BLOCKED. The zone 1/2/4 quantifier checks
      are too strong when ssn has inconsistent y-t order atoms. An ssn with
      y > x (zone 1) but y < t (inconsistent with t < x < y) has no 3-var
      witness (sub_nf.2 ssn = false), but the (y,x) 2-var projection may
      still have witnesses (nf_x.2(proj) = true). The zone1_quant_check
      asserts equality, which fails in this case.
    - FIX NEEDED: Add ssn_yt_order_right_above/eq guards to zone 1/2/4
      branches so inconsistent ssns fall through to !sub_nf.2 ssn (= true).
      Same issue affects zones 2 and 4 symmetrically.
    - At k > 0: conservative (true), same closing as v1. No issue.
    - NOTE: nf_full_compat_right_v2 is NOT used by nf_exist_formula_nested.
      The actual formula uses nf_full_compat_right (v1). The v2 filter was
      designed for a potential future upgrade but has the above design flaw.

    Backward-direction proof:
    - At k=0: the strengthened filter (once fixed) would enable full recovery
      of sub_nf.2 for zones 1, 2, 4 from nf_x and parent_atoms.
-/

/-- Zone 1 (y > x) quantifier check. At k=0, projects the depth-0 3-var
    atom assignment to (y, x) by dropping variable 2 (t), then compares
    nf_x.quant_assgn on the projection against sub_nf.quant_assgn.
    At k > 0, conservatively returns true. -/
noncomputable def zone1_quant_check {sig : MonadicSignature}
    (k : Nat)
    (nf_x : NormalForm sig (k + 1) 1)
    (ssn : NormalForm sig k 3)
    (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  match k with
  | 0 =>
    nf_x.quant_assgn (atomProjDrop 2 ⟨2, by omega⟩ ssn) == sub_nf.quant_assgn ssn
  | _ + 1 => true

/-- Zone 2/4 quantifier check. At k=0, atom-compatible y=x (or y=t) ssns
    are uniquely determined, so sub_nf.quant_assgn ssn must be true.
    At k > 0, conservatively returns true. -/
noncomputable def zone24_quant_check {sig : MonadicSignature}
    (k : Nat)
    (ssn : NormalForm sig k 3)
    (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  match k with
  | 0 => sub_nf.quant_assgn ssn
  | _ + 1 => true

/-- Strengthened full compatibility check (v2) for the Until direction (t < x).
    Adds quantifier checks for zones 1, 2, 4 on top of the v1 atom checks.
    At k=0, the additional checks are exact; at k > 0, conservative (true). -/
noncomputable def nf_full_compat_right_v2 {sig : MonadicSignature} {k : Nat}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  (Fintype.elems (α := NormalForm sig k 3)).val.toList.all fun ssn =>
    if ssn_in_interval_right ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms &&
         ssn_xt_order_compat ssn sub_nf then
        true
      else
        !sub_nf.2 ssn
    else if !ssn_xt_order_compat ssn sub_nf then
      !sub_nf.2 ssn
    else if ssn_y_above_x ssn then
      -- Zone 1 (y > x): atom check + quantifier projection check
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        zone1_quant_check k nf_x ssn sub_nf
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_x ssn then
      -- Zone 2 (y = x): atom check + require sub_nf.2 ssn at k=0
      if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) &&
         ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        zone24_quant_check k ssn sub_nf
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_t ssn then
      -- Zone 4 (y = t): atom check + require sub_nf.2 ssn at k=0
      if ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            parent_atoms (.pred p ⟨0, by omega⟩)) then
          zone24_quant_check k ssn sub_nf
        else
          !sub_nf.2 ssn
      else
        !sub_nf.2 ssn
    else if ssn_y_below_t ssn then
      -- Zone 5 (y < t): unchanged from v1
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        true
      else
        !sub_nf.2 ssn
    else
      true

/-- Strengthened full compatibility check (v2) for the Since direction (x < t). -/
noncomputable def nf_full_compat_left_v2 {sig : MonadicSignature} {k : Nat}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  (Fintype.elems (α := NormalForm sig k 3)).val.toList.all fun ssn =>
    if ssn_in_interval_left ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms &&
         ssn_xt_order_compat ssn sub_nf then
        true
      else
        !sub_nf.2 ssn
    else if !ssn_xt_order_compat ssn sub_nf then
      !sub_nf.2 ssn
    else if ssn_y_above_x ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        zone1_quant_check k nf_x ssn sub_nf
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_x ssn then
      if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) &&
         ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        zone24_quant_check k ssn sub_nf
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_t ssn then
      if ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            parent_atoms (.pred p ⟨0, by omega⟩)) then
          zone24_quant_check k ssn sub_nf
        else
          !sub_nf.2 ssn
      else
        !sub_nf.2 ssn
    else if ssn_y_below_t ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        true
      else
        !sub_nf.2 ssn
    else
      true

/-- Symmetric full compatibility for the Since direction (x < t). -/
noncomputable def nf_full_compat_left {sig : MonadicSignature} {k : Nat}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) : Bool :=
  (Fintype.elems (α := NormalForm sig k 3)).val.toList.all fun ssn =>
    -- Interval ssn's: check atom compat at x,t (var 1,2) -- required for backward direction
    if ssn_in_interval_left ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms &&
         ssn_xt_order_compat ssn sub_nf then
        true  -- atom-compatible interval ssn; handled by the formula's Until conditions
      else
        !sub_nf.2 ssn  -- atom-incompatible interval ssn; must be negative
    else if !ssn_xt_order_compat ssn sub_nf then
      !sub_nf.2 ssn
    else if ssn_y_above_x ssn then
      -- For Since (x < t), y > x but below t means interval, handled above
      -- y > x AND y > t (above both) is non-interval
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        true
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_x ssn then
      if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) &&
         ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        true
      else
        !sub_nf.2 ssn
    else if ssn_y_eq_t ssn then
      if ssn_t_pred_compat ssn parent_atoms &&
         ssn_x_pred_compat ssn nf_x then
        if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
            ssn.atom_assgn (.pred p ⟨0, by omega⟩) ==
            parent_atoms (.pred p ⟨0, by omega⟩)) then
          true
        else
          !sub_nf.2 ssn
      else
        !sub_nf.2 ssn
    else if ssn_y_below_t ssn then
      if ssn_x_pred_compat ssn nf_x && ssn_t_pred_compat ssn parent_atoms then
        true
      else
        !sub_nf.2 ssn
    else
      true

/-- Build the nested formula for a single order direction (Until: t < x).

    For a given compatible nf_x : NormalForm sig (k+1) 1 (the 1-var NF of witness x),
    the formula encodes:
    1. char_{k+1}(nf_x) at x (places x and verifies its full depth-(k+1) 1-var NF)
    2. For each positive interval ssn: Since(char_{k+1}(nf_y), top) within (t,x)
       Using char_{k+1} (not char_k) so the backward direction can recover
       depth-k 2-var NFs of (y,x) and (y,t) via the composition lemma.
    3. Non-interval ssn conditions are verified by the nf_full_compat filtering

    The formula uses Until from t to place x, with guard = top.

    ### References
    - Rabinovich 2014 Notation 5.2 + Prop 3.5
    - Doets 1989 Lemma 1.4/1.5 (composition for non-interval filtering) -/
noncomputable def nf_exist_formula_nested
    {sig : MonadicSignature}
    (k : Nat)
    (char_kp1 : NormalForm sig (k + 1) 1 → Formula)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) : Formula :=
  -- Step 1: t-compatibility check (same as nf_exist_formula)
  if ¬ nf_t_compat parent_atoms sub_nf = true then
    Formula.bot
  -- Step 2: order consistency (both x<t and t<x is impossible)
  else if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
          sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) then
    Formula.bot
  else
    -- Step 3: Enumerate all depth-(k+1) arity-1 NFs compatible with sub_nf at var 0
    let all_nfs_kp1 := (Fintype.elems (α := NormalForm sig (k + 1) 1)).val.toList
    let atom_compat_x (nf_x : NormalForm sig (k + 1) 1) : Bool :=
      (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
        nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)
    -- Step 4: Full compatibility check including non-interval ssn conditions
    -- An nf_x is "fully compatible" with sub_nf if:
    -- (a) predicate atoms match at variable 0
    -- (b) non-interval ssn conditions from sub_nf.2 are consistent with nf_x
    -- Step 5: Helper to build interval condition formulas for a given nf_x
    let all_ssn := (Fintype.elems (α := NormalForm sig k 3)).val.toList
    -- Build the event and guard formulas for an Until direction (t < x),
    -- given nf_x and the list of all ssn's.
    let build_event_guard_right (nf_x : NormalForm sig (k + 1) 1) :
        Formula × Formula :=
      let x_char := char_kp1 nf_x
      -- Positive interval ssn's (sub_nf.2(ssn)=true, y in (t,x))
      let interval_positive := all_ssn.filter fun ssn =>
        sub_nf.2 ssn && ssn_in_interval_right ssn
      -- For each positive ssn, build disjunction of char_{k+1}(nf_y) for compatible nf_y
      -- Using char_kp1 (depth k+1) instead of char_k (depth k) so that the
      -- backward direction can recover 2-var NFs of (y,x) and (y,t) via composition.
      let witness_formulas := interval_positive.map fun ssn =>
        let compat_nf_ys := (Fintype.elems (α := NormalForm sig (k + 1) 1)).val.toList.filterMap
          fun nf_y => if ssn_compat_var0' ssn nf_y then some (char_kp1 nf_y) else none
        formula_disjList compat_nf_ys
      -- Each positive condition is existential: "∃ y < x with char_{k+1}(nf_y)"
      -- Encoded as Since(witness_formula, ⊤) at x (places y in past of x)
      let pos_at_x := witness_formulas.map fun wf => Formula.snce wf Formula.top
      -- Event: char_{k+1}(nf_x) AND all positive interval Since-formulas
      let event := Formula.and x_char (formula_conjList pos_at_x)
      -- Guard: Formula.top (trivially true).
      -- NOTE: The negative interval conditions (sub_nf.2(ssn)=false, y in (t,x))
      -- are NOT encoded in the guard. Previously the guard attempted to enforce
      -- "points in (t,x) must not have forbidden 1-var NF types", but this is
      -- too strong: sub_nf.2(ssn)=false only says no y has the full 3-var NF ssn
      -- at (y,x,t), not that no y has ssn-compatible predicates. The negative
      -- conditions are instead recovered in the backward direction from
      -- char_{k+1}(nf_x) which encodes x's full depth-(k+1) 1-var NF.
      let guard := Formula.top
      (event, guard)
    -- Symmetric: build event and guard for Since direction (x < t)
    let build_event_guard_left (nf_x : NormalForm sig (k + 1) 1) :
        Formula × Formula :=
      let x_char := char_kp1 nf_x
      -- Positive interval ssn's (sub_nf.2(ssn)=true, y in (x,t))
      let interval_positive := all_ssn.filter fun ssn =>
        sub_nf.2 ssn && ssn_in_interval_left ssn
      -- Using char_kp1 (depth k+1) for interval witnesses (symmetric with right case)
      let witness_formulas := interval_positive.map fun ssn =>
        let compat_nf_ys := (Fintype.elems (α := NormalForm sig (k + 1) 1)).val.toList.filterMap
          fun nf_y => if ssn_compat_var0' ssn nf_y then some (char_kp1 nf_y) else none
        formula_disjList compat_nf_ys
      -- Each positive condition: "∃ y > x with char_{k+1}(nf_y)"
      -- Encoded as Until(witness_formula, ⊤) at x (places y in future of x)
      let pos_at_x := witness_formulas.map fun wf => Formula.untl wf Formula.top
      let event := Formula.and x_char (formula_conjList pos_at_x)
      -- Guard: Formula.top (symmetric with right direction; see note above)
      let guard := Formula.top
      (event, guard)
    -- Step 6: Build the full disjunction over compatible nf_x
    -- Full compatibility: atom compat + non-interval ssn compat
    match nf_order_dir sub_nf with
    | some true =>  -- t < x: use Until
      let compat_formulas := all_nfs_kp1.filterMap fun nf_x =>
        if atom_compat_x nf_x && nf_full_compat_right nf_x parent_atoms sub_nf then
          let (event, guard) := build_event_guard_right nf_x
          some (Formula.untl event guard)
        else none
      formula_disjList compat_formulas
    | some false =>  -- x < t: use Since
      let compat_formulas := all_nfs_kp1.filterMap fun nf_x =>
        if atom_compat_x nf_x && nf_full_compat_left nf_x parent_atoms sub_nf then
          let (event, guard) := build_event_guard_left nf_x
          some (Formula.snce event guard)
        else none
      formula_disjList compat_formulas
    | none =>
      -- x = t or inconsistent
      if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) == false &&
         sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) == false then
        -- x = t: no interval, just witness_type
        let compat_formulas := all_nfs_kp1.filterMap fun nf_x =>
          if atom_compat_x nf_x then some (char_kp1 nf_x) else none
        formula_disjList compat_formulas
      else
        Formula.bot

/-- At k=0, if all 3-var atoms at (y, x, t) match ssn, then the 2-var
    projection (dropping variable 2 = t) matches at (y, x). Used for
    zone 1 (y > x) in nf_full_compat_right_v2_of_eval. -/
private theorem atomProjDrop_eval_of_3var {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig}
    {y x t_val : M.carrier}
    {ssn : AtomKind sig 3 → Bool}
    (hay : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons y (Fin.cons x (fun _ => t_val))) a ↔ ssn a = true) :
    nf_eval_nf M 0 2 (Fin.cons y (fun _ => x)) (atomProjDrop 2 ⟨2, by omega⟩ ssn) := by
  intro a
  have h_lift : ∀ (i : Fin 2), (Fin.cons y (fun _ : Fin 1 => x) : Fin 2 → _) i =
      (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t_val)) : Fin 3 → _) (liftSkip 2 ⟨2, by omega⟩ i) := by
    intro ⟨i, hi⟩
    simp only [liftSkip]
    split
    · next h => match i, hi with | 0, _ => simp [Fin.cons] | 1, _ => simp [Fin.cons]; rfl
    · next h => omega
  match a with
  | .pred p i =>
    simp only [atomProjDrop, atom_eval]
    exact (h_lift i) ▸ (hay (.pred p (liftSkip 2 ⟨2, by omega⟩ i)))
  | .order i j h_ne =>
    simp only [atomProjDrop, atom_eval]
    rw [h_lift i, h_lift j]
    exact hay (.order (liftSkip 2 ⟨2, by omega⟩ i) (liftSkip 2 ⟨2, by omega⟩ j)
      (fun h => h_ne (liftSkip_injective 2 ⟨2, by omega⟩ h)))

/-! ## Forward Direction: Witnesses → Formula Truth -/

/-- If any witness y matches all atoms of ssn, then ssn's x-pred, t-pred,
    and xt-order compat checks all pass (since these only reference vars 1,2). -/
private lemma ssn_compat_of_witness
    {sig : MonadicSignature} {k : Nat}
    {M : OrderedMonadicStructure sig}
    {x t y : M.carrier}
    {nf_x : NormalForm sig (k + 1) 1}
    {parent_atoms : AtomKind sig 1 → Bool}
    {sub_nf : NormalForm sig (k + 1) 2}
    {ssn : NormalForm sig k 3}
    (h_all : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔ ssn.atom_assgn a = true)
    (h_nfx : nf_eval_nf M (k + 1) 1 (fun _ => x) nf_x)
    (h_eval : nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
    (h_atoms_t : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) :
    ssn_x_pred_compat ssn nf_x = true ∧
    ssn_t_pred_compat ssn parent_atoms = true ∧
    ssn_xt_order_compat ssn sub_nf = true ∧
    (∀ p, ssn.atom_assgn (.pred p ⟨0, by omega⟩) = true ↔ M.interp p y) := by
  -- Extract model facts from h_all
  have hx : ∀ p, M.interp p x ↔ ssn.atom_assgn (.pred p ⟨1, by omega⟩) = true := by
    intro p; have := h_all (.pred p ⟨1, by omega⟩)
    rw [show atom_eval M (Fin.cons y (Fin.cons x (fun _ => t)))
      (.pred p ⟨1, by omega⟩) = M.interp p x from rfl] at this; exact this
  have ht : ∀ p, M.interp p t ↔ ssn.atom_assgn (.pred p ⟨2, by omega⟩) = true := by
    intro p; have := h_all (.pred p ⟨2, by omega⟩)
    rw [show atom_eval M (Fin.cons y (Fin.cons x (fun _ => t)))
      (.pred p ⟨2, by omega⟩) = M.interp p t from rfl] at this; exact this
  have hy : ∀ p, M.interp p y ↔ ssn.atom_assgn (.pred p ⟨0, by omega⟩) = true := by
    intro p; have := h_all (.pred p ⟨0, by omega⟩)
    rw [show atom_eval M (Fin.cons y (Fin.cons x (fun _ => t)))
      (.pred p ⟨0, by omega⟩) = M.interp p y from rfl] at this; exact this
  have x_pred_match : ∀ p, M.interp p x ↔ nf_x.atom_assgn (.pred p ⟨0, by omega⟩) = true := by
    intro p; exact h_nfx.1 (.pred p ⟨0, by omega⟩)
  have t_pred_match : ∀ p, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
    intro p; exact h_atoms_t (.pred p ⟨0, by omega⟩)
  -- Order facts
  have h_ord12 : (x < t) ↔ ssn.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    have := h_all (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
    rw [show atom_eval M (Fin.cons y (Fin.cons x (fun _ => t)))
      (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = (x < t) from rfl] at this; exact this
  have h_ord21 : (t < x) ↔ ssn.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    have := h_all (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
    rw [show atom_eval M (Fin.cons y (Fin.cons x (fun _ => t)))
      (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = (t < x) from rfl] at this; exact this
  have he_eval := h_eval.1
  have he12 : (x < t) ↔ sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    have h := he_eval (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    rw [show atom_eval M (Fin.cons x (fun _ => t))
      (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = (x < t) from rfl,
      show sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
        sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) from rfl] at h
    exact h
  have he21 : (t < x) ↔ sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
    have h := he_eval (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    rw [show atom_eval M (Fin.cons x (fun _ => t))
      (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = (t < x) from rfl,
      show sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
        sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) from rfl] at h
    exact h
  refine ⟨?_, ?_, ?_, fun p => ⟨(hy p).mpr, (hy p).mp⟩⟩
  · -- ssn_x_pred_compat
    simp only [ssn_x_pred_compat, List.all_eq_true, Bool.beq_to_eq]; intro p _
    cases hs : ssn.atom_assgn (.pred p ⟨1, by omega⟩) <;>
      cases hn : nf_x.atom_assgn (.pred p ⟨0, by omega⟩) <;> simp_all [hx, x_pred_match]
  · -- ssn_t_pred_compat
    simp only [ssn_t_pred_compat, List.all_eq_true, Bool.beq_to_eq]; intro p _
    cases hs : ssn.atom_assgn (.pred p ⟨2, by omega⟩) <;>
      cases hn : parent_atoms (.pred p ⟨0, by omega⟩) <;> simp_all [ht, t_pred_match]
  · -- ssn_xt_order_compat
    simp only [ssn_xt_order_compat, Bool.and_eq_true, Bool.beq_to_eq]; constructor
    · cases hs : ssn.atom_assgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) <;>
        cases hn : sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) <;>
        simp_all [h_ord12, he12]
    · cases hs : ssn.atom_assgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) <;>
        cases hn : sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;>
        simp_all [h_ord21, he21]

/-- The characteristic NF of x at depth k+1 passes nf_full_compat_right
    when x actually satisfies nf_eval_nf for sub_nf. This follows from the
    fact that atom-incompatible ssn's cannot be realized (no y satisfies
    atoms that don't match the actual structure). -/
private theorem nf_full_compat_right_of_eval
    {sig : MonadicSignature} {k : Nat}
    {M : OrderedMonadicStructure sig}
    {x t : M.carrier}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2)
    (h_nfx : nf_eval_nf M (k + 1) 1 (fun _ => x) nf_x)
    (h_eval : nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
    (h_atoms_t : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_lt : t < x) :
    nf_full_compat_right nf_x parent_atoms sub_nf = true := by
  simp only [nf_full_compat_right, List.all_eq_true]; intro ssn _
  have h_quant := h_eval.2
  -- Key helper: if sub_nf.2 ssn = true, there exists a witness y with all atoms matching
  have ssn_atoms_from_true : sub_nf.2 ssn = true →
      ∃ y, ∀ a : AtomKind sig 3,
        atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔ ssn.atom_assgn a = true := by
    intro hsub; obtain ⟨y, hy⟩ := (h_quant ssn).mpr hsub
    exact ⟨y, by cases k with | zero => exact hy | succ k' => exact hy.1⟩
  -- If no y satisfies all atoms, sub_nf.2 ssn = false
  have neg_from_no_witness : (∀ y, ∃ a : AtomKind sig 3,
      ¬(atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔ ssn.atom_assgn a = true)) →
      (!sub_nf.2 ssn) = true := by
    intro h_no; cases hsub : sub_nf.2 ssn with
    | false => rfl
    | true => obtain ⟨y, hay⟩ := ssn_atoms_from_true hsub
              obtain ⟨a, ha⟩ := h_no y; exact absurd (hay a) ha
  -- Prove by case analysis on sub_nf.2 ssn
  by_cases hsub : sub_nf.2 ssn = true
  · -- sub_nf.2 ssn = true: all atom compat checks pass (via the witness)
    obtain ⟨y, hay⟩ := ssn_atoms_from_true hsub
    have ⟨hxp, htp, hxt, hpreds⟩ := ssn_compat_of_witness hay h_nfx h_eval h_atoms_t
    have hns : (!sub_nf.2 ssn) = false := by rw [hsub]; rfl
    -- Helper: derive y = x when ssn_y_eq_x, then pred-0 match with nf_x
    have h_pred0_x : ssn_y_eq_x ssn = true →
        (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
          ssn.atom_assgn (.pred p ⟨0, by omega⟩) == nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) = true := by
      intro hyeq; rw [List.all_eq_true]; intro p _; rw [beq_iff_eq]
      have h_yx : y = x := by
        by_contra h_ne
        simp only [ssn_y_eq_x, Bool.and_eq_true, Bool.not_eq_true'] at hyeq
        rcases lt_or_gt_of_ne h_ne with hlt | hlt
        · have h_v := (hay (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyeq this; simp_all
        · have h_v := (hay (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyeq this; simp_all
      subst h_yx; exact Bool.eq_iff_iff.mpr ((hpreds p).trans (h_nfx.1 (.pred p 0)))
    -- Helper: derive y = t when ssn_y_eq_t, then pred-0 match with parent_atoms
    have h_pred0_t : ssn_y_eq_t ssn = true →
        ∀ p ∈ (Fintype.elems (α := sig.preds)).val.toList,
          (ssn.atom_assgn (.pred p ⟨0, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)) = true := by
      intro hyet p _; rw [beq_iff_eq]
      have h_yt : y = t := by
        by_contra h_ne
        simp only [ssn_y_eq_t, Bool.and_eq_true, Bool.not_eq_true'] at hyet
        rcases lt_or_gt_of_ne h_ne with hlt | hlt
        · have h_v := (hay (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨2, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyet this; simp_all
        · have h_v := (hay (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨2, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyet this; simp_all
      subst h_yt
      have h1 := (hpreds p).trans (h_atoms_t (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h1; exact Bool.eq_iff_iff.mpr h1
    -- Now simplify and close all branches
    simp only [hns, ite_false]
    split_ifs <;> first
      | rfl
      | (exfalso; simp_all [Bool.and_eq_true, List.all_eq_true, beq_iff_eq])
  · -- sub_nf.2 ssn = false: !sub_nf.2 ssn = true, every branch is true
    have hf : (!sub_nf.2 ssn) = true := by
      cases h : sub_nf.2 ssn <;> simp_all
    simp only [hf, ite_true, ite_self]

/-- Symmetric version for Since direction. -/
private theorem nf_full_compat_left_of_eval
    {sig : MonadicSignature} {k : Nat}
    {M : OrderedMonadicStructure sig}
    {x t : M.carrier}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2)
    (h_nfx : nf_eval_nf M (k + 1) 1 (fun _ => x) nf_x)
    (h_eval : nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
    (h_atoms_t : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_lt : x < t) :
    nf_full_compat_left nf_x parent_atoms sub_nf = true := by
  simp only [nf_full_compat_left, List.all_eq_true]; intro ssn _
  have h_quant := h_eval.2
  have ssn_atoms_from_true : sub_nf.2 ssn = true →
      ∃ y, ∀ a : AtomKind sig 3,
        atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔ ssn.atom_assgn a = true := by
    intro hsub; obtain ⟨y, hy⟩ := (h_quant ssn).mpr hsub
    exact ⟨y, by cases k with | zero => exact hy | succ k' => exact hy.1⟩
  by_cases hsub : sub_nf.2 ssn = true
  · obtain ⟨y, hay⟩ := ssn_atoms_from_true hsub
    have ⟨hxp, htp, hxt, hpreds⟩ := ssn_compat_of_witness hay h_nfx h_eval h_atoms_t
    have hns : (!sub_nf.2 ssn) = false := by rw [hsub]; rfl
    -- Helper: y=x pred match
    have h_pred0_x : ssn_y_eq_x ssn = true →
        (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
          ssn.atom_assgn (.pred p ⟨0, by omega⟩) == nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) = true := by
      intro hyeq; rw [List.all_eq_true]; intro p _; rw [beq_iff_eq]
      have h_yx : y = x := by
        by_contra h_ne
        simp only [ssn_y_eq_x, Bool.and_eq_true, Bool.not_eq_true'] at hyeq
        rcases lt_or_gt_of_ne h_ne with hlt | hlt
        · have h_v := (hay (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyeq this; simp_all
        · have h_v := (hay (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyeq this; simp_all
      subst h_yx; exact Bool.eq_iff_iff.mpr ((hpreds p).trans (h_nfx.1 (.pred p 0)))
    -- Helper: y=t pred match
    have h_pred0_t : ssn_y_eq_t ssn = true →
        ∀ p ∈ (Fintype.elems (α := sig.preds)).val.toList,
          (ssn.atom_assgn (.pred p ⟨0, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)) = true := by
      intro hyet p _; rw [beq_iff_eq]
      have h_yt : y = t := by
        by_contra h_ne
        simp only [ssn_y_eq_t, Bool.and_eq_true, Bool.not_eq_true'] at hyet
        rcases lt_or_gt_of_ne h_ne with hlt | hlt
        · have h_v := (hay (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨2, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyet this; simp_all
        · have h_v := (hay (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨2, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyet this; simp_all
      subst h_yt
      have h1 := (hpreds p).trans (h_atoms_t (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h1; exact Bool.eq_iff_iff.mpr h1
    simp only [hns, ite_false]
    split_ifs <;> first
      | rfl
      | (exfalso; simp_all [Bool.and_eq_true, List.all_eq_true, beq_iff_eq])
  · have hf : (!sub_nf.2 ssn) = true := by
      cases h : sub_nf.2 ssn <;> simp_all
    simp only [hf, ite_true, ite_self]

set_option maxHeartbeats 8000000 in
/-- The characteristic NF of x at depth k+1 passes nf_full_compat_right_v2
    when x actually satisfies nf_eval_nf for sub_nf. Like nf_full_compat_right_of_eval
    but for the strengthened v2 filter with zone 1/2/4 quantifier checks.

    At k=0: all zone checks are provable (atoms determine everything).
    At k > 0: zone checks are conservative (true), so same as v1. -/
private theorem nf_full_compat_right_v2_of_eval
    {sig : MonadicSignature} {k : Nat}
    {M : OrderedMonadicStructure sig}
    {x t : M.carrier}
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2)
    (h_nfx : nf_eval_nf M (k + 1) 1 (fun _ => x) nf_x)
    (h_eval : nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)
    (h_atoms_t : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_lt : t < x) :
    nf_full_compat_right_v2 nf_x parent_atoms sub_nf = true := by
  simp only [nf_full_compat_right_v2, List.all_eq_true]; intro ssn _
  have h_quant := h_eval.2
  -- Key helper: if sub_nf.2 ssn = true, there exists a witness y with all atoms matching
  have ssn_atoms_from_true : sub_nf.2 ssn = true →
      ∃ y, ∀ a : AtomKind sig 3,
        atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔ ssn.atom_assgn a = true := by
    intro hsub; obtain ⟨y, hy⟩ := (h_quant ssn).mpr hsub
    exact ⟨y, by cases k with | zero => exact hy | succ k' => exact hy.1⟩
  by_cases hsub : sub_nf.2 ssn = true
  · -- sub_nf.2 ssn = true: prove each zone check passes
    obtain ⟨y, hay⟩ := ssn_atoms_from_true hsub
    have ⟨hxp, htp, hxt, hpreds⟩ := ssn_compat_of_witness hay h_nfx h_eval h_atoms_t
    have hns : (!sub_nf.2 ssn) = false := by rw [hsub]; rfl
    -- Helper: derive y = x when ssn_y_eq_x, then pred-0 match with nf_x
    have h_pred0_x : ssn_y_eq_x ssn = true →
        (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
          ssn.atom_assgn (.pred p ⟨0, by omega⟩) == nf_x.atom_assgn (.pred p ⟨0, by omega⟩)) = true := by
      intro hyeq; rw [List.all_eq_true]; intro p _; rw [beq_iff_eq]
      have h_yx : y = x := by
        by_contra h_ne
        simp only [ssn_y_eq_x, Bool.and_eq_true, Bool.not_eq_true'] at hyeq
        rcases lt_or_gt_of_ne h_ne with hlt | hlt
        · have h_v := (hay (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyeq this; simp_all
        · have h_v := (hay (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyeq this; simp_all
      subst h_yx; exact Bool.eq_iff_iff.mpr ((hpreds p).trans (h_nfx.1 (.pred p 0)))
    -- Helper: derive y = t when ssn_y_eq_t, then pred-0 match with parent_atoms
    have h_pred0_t : ssn_y_eq_t ssn = true →
        ∀ p ∈ (Fintype.elems (α := sig.preds)).val.toList,
          (ssn.atom_assgn (.pred p ⟨0, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)) = true := by
      intro hyet p _; rw [beq_iff_eq]
      have h_yt : y = t := by
        by_contra h_ne
        simp only [ssn_y_eq_t, Bool.and_eq_true, Bool.not_eq_true'] at hyet
        rcases lt_or_gt_of_ne h_ne with hlt | hlt
        · have h_v := (hay (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨2, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyet this; simp_all
        · have h_v := (hay (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
          simp only [atom_eval] at h_v
          have := h_v (show (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨2, by omega⟩ <
            (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ from by
              simp [Fin.cons]; exact hlt)
          simp only [NormalForm.atom_assgn] at hyet this; simp_all
      subst h_yt
      have h1 := (hpreds p).trans (h_atoms_t (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h1; exact Bool.eq_iff_iff.mpr h1
    -- Helper: zone1 quantifier check passes in the positive case.
    -- From witness y with y > x (zone 1), we can show nf_x.2(proj) = true.
    have h_zone1_pos : ssn_y_above_x ssn = true →
        ssn_x_pred_compat ssn nf_x = true → ssn_t_pred_compat ssn parent_atoms = true →
        zone1_quant_check k nf_x ssn sub_nf = true := by
      intro hya _ _
      cases k with
      | succ k' => simp [zone1_quant_check]
      | zero =>
        simp only [zone1_quant_check, beq_iff_eq]
        -- At k=0: show nf_x.quant_assgn (proj) = sub_nf.quant_assgn ssn = true
        rw [show sub_nf.quant_assgn ssn = sub_nf.2 ssn from rfl, hsub]
        -- Need: nf_x.quant_assgn (atomProjDrop 2 ⟨2, ...⟩ ssn) = true
        -- From witness y with y > x, (y, x) satisfies proj, so nf_x.2(proj) = true
        rw [show nf_x.quant_assgn = nf_x.2 from rfl]
        have h_yx : y > x := by
          have := (hay (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr
          simp only [atom_eval] at this
          have hfc30 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨0, by omega⟩ = y := by simp [Fin.cons]
          have hfc31 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → _) ⟨1, by omega⟩ = x := by simp [Fin.cons]; rfl
          rw [hfc30, hfc31] at this
          simp only [ssn_y_above_x, NormalForm.atom_assgn] at hya
          exact this hya
        -- y witnesses nf_x.2(proj) = true at k=0.
        -- Use atomProjDrop_eval_of_3var to map 3-var atom match to 2-var.
        have h_proj := atomProjDrop_eval_of_3var hay
        have h_nfx2 := (h_nfx.2 (atomProjDrop 2 ⟨2, by omega⟩ ssn)).mp
        show nf_x.2 (atomProjDrop 2 ⟨2, by omega⟩ ssn) = true
        apply h_nfx2; exact ⟨y, h_proj⟩
    -- Helper: zone24 quantifier check passes in the positive case.
    have h_zone24_pos : zone24_quant_check k ssn sub_nf = true := by
      cases k with
      | succ k' => simp [zone24_quant_check]
      | zero =>
        simp only [zone24_quant_check]
        exact hsub
    -- Close all branches via split_ifs
    simp only [hns, ite_false]
    split_ifs with h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13 <;> first
      | rfl
      | exact h_zone24_pos
      | (apply h_zone1_pos <;> simp_all [Bool.and_eq_true])
      | (exfalso; simp_all [Bool.and_eq_true, List.all_eq_true, beq_iff_eq])
  · -- sub_nf.2 ssn = false: prove each branch returns true
    have hf : (!sub_nf.2 ssn) = true := by
      cases h : sub_nf.2 ssn <;> simp_all
    -- At k > 0: zone checks are all `true`, so same as v1
    -- At k = 0: need to show zone checks handle false correctly
    cases k with
    | succ k' =>
      -- k > 0: zone checks are true, same closing as v1
      simp only [zone1_quant_check, zone24_quant_check, hf, ite_true, ite_self]
    | zero =>
      -- k = 0: zone checks need special handling
      simp only [zone1_quant_check, zone24_quant_check]
      -- zone1: (nf_x.quant_assgn proj == false) must be true
      -- BLOCKER: zone1_quant_check design flaw (see docstring above).
      -- Zone 1 (y > x): nf_x.2(proj) == sub_nf.2(ssn) fails when ssn has
      --   inconsistent y-t order atoms (e.g., ssn says y < t but t < x < y).
      --   Such ssns have no 3-var witness but may have 2-var projection witnesses.
      -- Zone 2 (y=x): sub_nf.2(ssn) = true required but hsub says false.
      --   Would be contradiction IF we could construct witness x, but ssn
      --   may have inconsistent y-t order atoms preventing this.
      -- Zone 4 (y=t): same issue as zone 2.
      -- FIX: add ssn_yt_order guards to nf_full_compat_right_v2 definition.
      -- NOTE: this theorem is NOT on the critical path (formula uses v1 filter).
      simp only [hf]
      -- After simp, the branches with !sub_nf.2 ssn are true.
      -- The remaining branches are zone 1, zone 2 (compat), zone 4 (compat).
      split_ifs with h1 h2 h3 h4 h5 h6 h7 h8 h9 h10 h11 h12 h13
      all_goals (first | rfl | simp_all [Bool.and_eq_true, beq_iff_eq])
      -- Remaining goals should be zone 1, 2, 4 where simp_all can't close.
      -- Zone 2 (y=x): derive contradiction from sub_nf.2 ssn = false + witness y=x
      all_goals sorry

set_option maxHeartbeats 2000000 in
/-- Forward direction of nf_exist_formula_nested at depth k+1.
    Rabinovich 2014 Prop 3.5 correctness. -/
private theorem nf_exist_formula_nested_forward
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (_h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_kp1 : NormalForm sig (k + 1) 1 → Formula)
    (char_kp1_correct : ∀ (nf_1 : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig),
        semantic_prior_UZ M atomMap →
        semantic_prior_SZ M atomMap →
        ∀ (t : M.carrier),
          temporal_truth M atomMap t (char_kp1 nf_1) ↔
          nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2)
    {M : OrderedMonadicStructure sig}
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_ex : ∃ x : M.carrier,
        nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    temporal_truth M atomMap t
      (nf_exist_formula_nested k char_kp1 parent_atoms sub_nf) := by
  -- Use the existing forward proof infrastructure from nf_exist_formula_forward'.
  -- The key difference: nf_exist_formula_nested adds interval Since/Until in the event.
  -- With guard = Formula.top, the proof reduces to:
  --   1. Same as nf_exist_formula_forward' for t-compat, order, nf_x
  --   2. Additionally show each positive interval witness Since/Until at x
  obtain ⟨x, h_x⟩ := h_ex
  have h_x_atoms := h_x.1
  have h_x_quant := h_x.2
  -- t-compatibility (reuse the pattern from nf_exist_formula_forward')
  have h_t_compat : nf_t_compat parent_atoms sub_nf = true := by
    simp only [nf_t_compat, List.all_eq_true]; intro p _; simp only [beq_iff_eq]
    have h1 := h_x_atoms (.pred p ⟨1, by omega⟩); have h2 := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h1 h2
    have hfc : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
      simp [Fin.cons]; rfl
    rw [hfc] at h1
    -- h1 : M.interp p t ↔ sub_nf.1 (.pred p ⟨1, ...⟩) = true
    -- h2 : M.interp p t ↔ parent_atoms (.pred p ⟨0, ...⟩) = true
    -- goal: sub_nf.atom_assgn (.pred p ⟨1, ...⟩) = parent_atoms (.pred p ⟨0, ...⟩)
    -- These are the same by transitivity
    -- Both h1 and h2 relate M.interp p t to boolean values.
    -- If M.interp p t holds, both values are true; otherwise both false.
    exact Bool.eq_iff_iff.mpr (h1.symm.trans h2)
  -- Order
  have h_xlt := h_x_atoms (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  have h_tlx := h_x_atoms (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  simp only [atom_eval, Fin.cons] at h_xlt h_tlx
  have fc0 : Fin.cases x (fun _ : Fin 1 => t) (⟨0, by omega⟩ : Fin 2) = x := by simp [Fin.cases]
  have fc1 : Fin.cases x (fun _ : Fin 1 => t) (⟨1, by omega⟩ : Fin 2) = t := by simp [Fin.cases]; rfl
  rw [fc0, fc1] at h_xlt; rw [fc1, fc0] at h_tlx
  have h_oc : ¬(sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
      sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true := by
    intro hb; rw [Bool.and_eq_true] at hb
    exact absurd (lt_trans (h_xlt.mpr hb.1) (h_tlx.mpr hb.2)) (lt_irrefl _)
  -- Characteristic NF of x
  set nf_x := nf_characteristic M (k+1) 1 (fun _ => x)
  have h_nfx := nf_characteristic_satisfies M (k+1) 1 (fun _ => x)
  have h_cx : temporal_truth M atomMap x (char_kp1 nf_x) :=
    (char_kp1_correct nf_x M h_UZ h_SZ x).mpr h_nfx
  -- Atom compat
  have h_ac : ∀ p : sig.preds,
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) = sub_nf.atom_assgn (.pred p ⟨0, by omega⟩) := by
    intro p
    have h1 := h_nfx.1 (.pred p (0 : Fin 1)); have h2 := h_x_atoms (.pred p (0 : Fin 2))
    simp only [atom_eval] at h1 h2
    have : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) (0 : Fin 2) = x := by
      simp [Fin.cons]
    rw [this] at h2
    exact Bool.eq_iff_iff.mpr (h1.symm.trans h2)
  have h_acf : (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) = true := by
    rw [List.all_eq_true]; intro p _; simp only [beq_iff_eq]; exact h_ac p
  -- Unfold the formula
  unfold nf_exist_formula_nested
  simp only [h_t_compat, not_true, ↓reduceIte, ite_not, h_oc, ite_false]
  -- Case split on order direction
  match h_dir : nf_order_dir sub_nf with
  | some true =>
    have h_lt : t < x := by
      simp only [nf_order_dir] at h_dir
      split at h_dir <;> simp_all [NormalForm.atom_assgn]
    have h_fcr : nf_full_compat_right nf_x parent_atoms sub_nf = true :=
      nf_full_compat_right_of_eval nf_x parent_atoms sub_nf h_nfx h_x h_atoms h_lt
    have h_full : ((Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
        nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) &&
        nf_full_compat_right nf_x parent_atoms sub_nf) = true := by
      rw [Bool.and_eq_true]; exact ⟨h_acf, h_fcr⟩
    apply (formula_disjList_iff M atomMap t _).mpr
    refine ⟨_, List.mem_filterMap.mpr ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x),
      by rw [if_pos h_full]⟩, ?_⟩
    simp only [temporal_truth]
    refine ⟨x, h_lt, ?_, fun _ _ _ => temporal_truth_top M atomMap _⟩
    rw [temporal_truth_and]; refine ⟨h_cx, ?_⟩
    rw [formula_conjList_iff]; intro A hA
    rw [List.mem_map] at hA; obtain ⟨wf, hwf, rfl⟩ := hA
    rw [List.mem_map] at hwf; obtain ⟨ssn, hssn, rfl⟩ := hwf
    rw [List.mem_filter] at hssn; obtain ⟨_, hp⟩ := hssn
    rw [Bool.and_eq_true] at hp; obtain ⟨ht, hir⟩ := hp
    obtain ⟨y, hy⟩ := (h_x_quant ssn).mpr ht
    simp only [temporal_truth]
    have hay : ∀ a : AtomKind sig 3, atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔
        ssn.atom_assgn a = true := by cases k with | zero => exact hy | succ k' => exact hy.1
    have hyx : y < x := by
      simp only [ssn_in_interval_right, Bool.and_eq_true, NormalForm.atom_assgn] at hir
      have := hay (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
      simp only [atom_eval] at this
      have hfc30 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by simp [Fin.cons]
      have hfc31 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by simp [Fin.cons]; rfl
      rw [hfc30, hfc31] at this; exact this.mpr hir.1
    -- Use depth-(k+1) characteristic NF for interval witnesses (char_kp1 fix)
    set nf_y := nf_characteristic M (k + 1) 1 (fun _ => y)
    have h_ny := nf_characteristic_satisfies M (k + 1) 1 (fun _ => y)
    have hcy := (char_kp1_correct nf_y M h_UZ h_SZ y).mpr h_ny
    have hyc : ssn_compat_var0' ssn nf_y = true := by
      simp only [ssn_compat_var0', List.all_eq_true]; intro p _; simp only [beq_iff_eq]
      have h1 : atom_eval M (fun _ => y) (.pred p (0 : Fin 1)) ↔
          nf_y.atom_assgn (.pred p (0 : Fin 1)) = true := h_ny.1 (.pred p 0)
      have h2 := hay (.pred p (0 : Fin 3))
      simp only [atom_eval] at h1 h2
      have h2' : M.interp p y ↔ ssn.atom_assgn (.pred p (0 : Fin 3)) = true := by
        have := h2; simp only [Fin.cons] at this; convert this using 1
      exact Bool.eq_iff_iff.mpr (h1.symm.trans h2')
    exact ⟨y, hyx, (formula_disjList_iff M atomMap y _).mpr
      ⟨char_kp1 nf_y, List.mem_filterMap.mpr ⟨nf_y, Multiset.mem_toList.mpr (Fintype.complete nf_y),
        by rw [if_pos hyc]⟩, hcy⟩,
      fun _ _ _ => temporal_truth_top M atomMap _⟩
  | some false =>
    have h_lt : x < t := by
      simp only [nf_order_dir] at h_dir
      split at h_dir <;> simp_all [NormalForm.atom_assgn]
    have h_fcl : nf_full_compat_left nf_x parent_atoms sub_nf = true :=
      nf_full_compat_left_of_eval nf_x parent_atoms sub_nf h_nfx h_x h_atoms h_lt
    have h_full : ((Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
        nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)) &&
        nf_full_compat_left nf_x parent_atoms sub_nf) = true := by
      rw [Bool.and_eq_true]; exact ⟨h_acf, h_fcl⟩
    apply (formula_disjList_iff M atomMap t _).mpr
    refine ⟨_, List.mem_filterMap.mpr ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x),
      by rw [if_pos h_full]⟩, ?_⟩
    simp only [temporal_truth]
    refine ⟨x, h_lt, ?_, fun _ _ _ => temporal_truth_top M atomMap _⟩
    rw [temporal_truth_and]; refine ⟨h_cx, ?_⟩
    rw [formula_conjList_iff]; intro A hA
    rw [List.mem_map] at hA; obtain ⟨wf, hwf, rfl⟩ := hA
    rw [List.mem_map] at hwf; obtain ⟨ssn, hssn, rfl⟩ := hwf
    rw [List.mem_filter] at hssn; obtain ⟨_, hp⟩ := hssn
    rw [Bool.and_eq_true] at hp; obtain ⟨ht, hil⟩ := hp
    obtain ⟨y, hy⟩ := (h_x_quant ssn).mpr ht
    simp only [temporal_truth]
    have hay : ∀ a : AtomKind sig 3, atom_eval M (Fin.cons y (Fin.cons x (fun _ => t))) a ↔
        ssn.atom_assgn a = true := by cases k with | zero => exact hy | succ k' => exact hy.1
    have hxy : x < y := by
      simp only [ssn_in_interval_left, Bool.and_eq_true, NormalForm.atom_assgn] at hil
      have := hay (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval] at this
      have hfc30 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨0, by omega⟩ = y := by simp [Fin.cons]
      have hfc31 : (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) ⟨1, by omega⟩ = x := by simp [Fin.cons]; rfl
      rw [hfc30, hfc31] at this; exact this.mpr hil.1
    -- Use depth-(k+1) characteristic NF for interval witnesses (char_kp1 fix)
    set nf_y := nf_characteristic M (k + 1) 1 (fun _ => y)
    have h_ny := nf_characteristic_satisfies M (k + 1) 1 (fun _ => y)
    have hcy := (char_kp1_correct nf_y M h_UZ h_SZ y).mpr h_ny
    have hyc : ssn_compat_var0' ssn nf_y = true := by
      simp only [ssn_compat_var0', List.all_eq_true]; intro p _; simp only [beq_iff_eq]
      have h1 : atom_eval M (fun _ => y) (.pred p (0 : Fin 1)) ↔
          nf_y.atom_assgn (.pred p (0 : Fin 1)) = true := h_ny.1 (.pred p 0)
      have h2 := hay (.pred p (0 : Fin 3))
      simp only [atom_eval] at h1 h2
      have h2' : M.interp p y ↔ ssn.atom_assgn (.pred p (0 : Fin 3)) = true := by
        have := h2; simp only [Fin.cons] at this; convert this using 1
      exact Bool.eq_iff_iff.mpr (h1.symm.trans h2')
    exact ⟨y, hxy, (formula_disjList_iff M atomMap y _).mpr
      ⟨char_kp1 nf_y, List.mem_filterMap.mpr ⟨nf_y, Multiset.mem_toList.mpr (Fintype.complete nf_y),
        by rw [if_pos hyc]⟩, hcy⟩,
      fun _ _ _ => temporal_truth_top M atomMap _⟩
  | none =>
    match h_v1 : sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)),
          h_v2 : sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) with
    | false, false =>
      have h_eq : x = t := by
        by_contra h_ne; rcases lt_or_gt_of_ne h_ne with h | h
        · have h1 := h_xlt.mp h
          have h2 : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := h_v1
          exact absurd h1 (by rw [h2]; exact Bool.noConfusion)
        · have h1 := h_tlx.mp h
          have h2 : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := h_v2
          exact absurd h1 (by rw [h2]; exact Bool.noConfusion)
      simp only [h_v1, h_v2, beq_self_eq_true, Bool.and_self, ↓reduceIte, ite_false]
      apply (formula_disjList_iff M atomMap t _).mpr
      exact ⟨_, List.mem_filterMap.mpr ⟨nf_x, Multiset.mem_toList.mpr (Fintype.complete nf_x),
        by rw [if_pos h_acf]⟩, h_eq ▸ h_cx⟩
    | true, true =>
      exfalso; exact h_oc (by rw [Bool.and_eq_true]; exact ⟨h_v1, h_v2⟩)
    | true, false =>
      -- h_v1 says order(0,1) = true, h_v2 says order(1,0) = false
      -- this means nf_order_dir = some false, contradicting h_dir = none
      exfalso
      have h_ne : nf_order_dir sub_nf ≠ none := by
        simp only [nf_order_dir]; rw [h_v2, h_v1]; decide
      exact h_ne h_dir
    | false, true =>
      exfalso
      have h_ne : nf_order_dir sub_nf ≠ none := by
        simp only [nf_order_dir]; rw [h_v2, h_v1]; decide
      exact h_ne h_dir

/-! ## Composition Lemma for Linear Orders (Doets 1989 Lemma 1.4/1.5)

The NormalForm-setting composition: for an environment with a "split point" y
strictly between two other variables, the n-var NF is determined by the
sub-environment NFs and the 2-var NFs of y paired with each neighbor.

At depth 0, this is immediate: atoms involve at most 2 variables, so every
atom in AtomKind sig (n+1) either belongs to a pair not involving y (captured
by the sub-environment NF) or to a pair involving y (captured by y's NF with
that variable). The cross-pair (x,t) order is implied by transitivity.

At depth k+1, the quantifier part introduces a new variable z, increasing
arity by 1. The induction hypothesis at depth k for all arities handles this.

Reference: Doets 1989, Lemma 1.4 (ordered sum composition preserves
n-equivalence without rank loss). In the NormalForm setting, variables are
already named (part of env), so no rank drop occurs (contrast Libkin 3.7
where naming a new constant costs one EF-game round).
-/

/-- At depth 0, the arity-3 NF at (y, x, t) is determined by atoms, which
    split cleanly into pairs. Given the 2-var NFs of (y,x) and (y,t) match
    the projections, the full 3-var NF matches. -/
private theorem nf_composition_depth0 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (y x t_val : M.carrier)
    (ssn : NormalForm sig 0 3)
    (h_atoms : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons y (Fin.cons x (fun _ => t_val))) a ↔
      ssn a = true) :
    nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t_val))) ssn :=
  h_atoms

/-- The characteristic 2-var NF at (x, t) is determined at depth k+1 when
    we know the full depth-(k+1) 1-var NFs of x and t, the order, and the
    characteristic depth-k 3-var NF behavior (sub_nf.2).

    This is the key backward lemma: given x extracted from the formula with
    matching atoms and compatible quantifier filtering, show the actual
    characteristic 2-var NF at (x, t) equals sub_nf.

    The quantifier part sub_nf.2 ssn agreement requires showing that for
    EVERY ssn, (∃ y, nf_eval_nf M k 3 (y,x,t) ssn) ↔ sub_nf.2 ssn = true.
    This is the content the composition lemma + the formula together establish.
-/
private theorem backward_2var_nf_agreement {sig : MonadicSignature}
    {k : Nat}
    (M : OrderedMonadicStructure sig)
    (x t_val : M.carrier)
    (sub_nf : NormalForm sig (k + 1) 2)
    (nf_x : NormalForm sig (k + 1) 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_nfx : nf_eval_nf M (k + 1) 1 (fun _ => x) nf_x)
    (h_atoms_t : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t_val) a ↔
      parent_atoms a = true)
    (h_atom_compat : ∀ p : sig.preds,
      nf_x.atom_assgn (.pred p ⟨0, by omega⟩) =
      sub_nf.atom_assgn (.pred p ⟨0, by omega⟩))
    (h_t_compat : nf_t_compat parent_atoms sub_nf = true)
    (h_order_match : ∀ (i j : Fin 2) (h : i ≠ j),
      ((Fin.cons x (fun _ : Fin 1 => t_val) : Fin 2 → M.carrier) i <
       (Fin.cons x (fun _ : Fin 1 => t_val) : Fin 2 → M.carrier) j) ↔
      sub_nf.atom_assgn (.order i j h) = true)
    -- The quantifier hypothesis: for each ssn, existence of witness y
    -- with the right 3-var NF matches sub_nf.2 ssn.
    (h_quant : ∀ ssn : NormalForm sig k 3,
      (∃ y, nf_eval_nf M k 3
        (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t_val))) ssn) ↔
      sub_nf.2 ssn = true) :
    nf_eval_nf M (k + 1) (1 + 1)
      (Fin.cons x (fun _ : Fin 1 => t_val)) sub_nf := by
  -- Use nf_eval_unique: show the characteristic NF at (x, t) equals sub_nf.
  -- The characteristic NF satisfies nf_eval_nf by definition.
  -- We show sub_nf equals it by showing sub_nf also satisfies nf_eval_nf.
  -- It suffices to show atom + quantifier parts match.
  set env := (Fin.cons x (fun _ : Fin 1 => t_val) : Fin 2 → M.carrier)
  -- Show atom part
  have h_atom_part : ∀ a : AtomKind sig 2,
      atom_eval M env a ↔ sub_nf.1 a = true := by
    intro a
    match a with
    | .pred p i =>
      match i with
      | ⟨0, _⟩ =>
        have h1 := h_nfx.1 (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h1 ⊢
        show M.interp p (env ⟨0, by omega⟩) ↔ _
        simp only [env, Fin.cons]
        rw [show sub_nf.1 (.pred p ⟨0, by omega⟩) =
          sub_nf.atom_assgn (.pred p ⟨0, by omega⟩) from rfl]
        exact h1.trans (Bool.eq_iff_iff.mp (h_atom_compat p))
      | ⟨1, _⟩ =>
        have ht := h_atoms_t (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at ht
        have henv1 : env ⟨1, by omega⟩ = t_val := by
          simp only [env, Fin.cons]; rfl
        simp only [atom_eval]
        rw [henv1]
        -- sub_nf.1 = sub_nf.atom_assgn at depth k+1
        suffices h : sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) =
            parent_atoms (.pred p ⟨0, by omega⟩) by
          rw [show sub_nf.1 (.pred p ⟨1, _⟩) =
            sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) from rfl, h]
          exact ht
        simp only [nf_t_compat, List.all_eq_true, beq_iff_eq] at h_t_compat
        have := h_t_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
        simp only [NormalForm.atom_assgn] at this ⊢
        simp_all
      | ⟨n + 2, hn⟩ => exact absurd hn (by omega)
    | .order i j h => exact h_order_match i j h
  exact ⟨h_atom_part, h_quant⟩

/-! ## Backward Direction: Formula → Existential (Phase 5b) -/

set_option maxHeartbeats 4000000 in
/-- Extract witness from Until and verify atom compatibility.
    Given formula truth for the Until case, extracts x > t with
    char_{k+1}(nf_x) holding, atoms matching sub_nf, and interval
    Since conditions satisfied. -/
private theorem nf_exist_formula_nested_backward
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_kp1 : NormalForm sig (k + 1) 1 → Formula)
    (char_kp1_correct : ∀ (nf_1 : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig),
        semantic_prior_UZ M atomMap →
        semantic_prior_SZ M atomMap →
        ∀ (t : M.carrier),
          temporal_truth M atomMap t (char_kp1 nf_1) ↔
          nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1)
    (p2_k : ∀ (parent_atoms : AtomKind sig 1 → Bool)
        (sub_nf : NormalForm sig k 2),
      ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf))
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2)
    {M : OrderedMonadicStructure sig}
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_formula : temporal_truth M atomMap t
      (nf_exist_formula_nested k char_kp1 parent_atoms sub_nf)) :
    ∃ x : M.carrier, nf_eval_nf M (k + 1) (1 + 1)
      (Fin.cons x (fun _ : Fin 1 => t)) sub_nf := by
  -- The backward proof uses backward_2var_nf_agreement which requires:
  -- (a) nf_x with h_nfx, atom_compat, t_compat, order_match
  -- (b) h_quant: for each ssn, (exists y, nf_eval 3 (y,x,t) ssn) <-> sub_nf.2 ssn
  --
  -- The formula truth gives us (a) via the filterMap disjunction + char_kp1_correct.
  -- The hard part is (b), which requires the composition theorem.
  --
  -- BLOCKER on (b): The quantifier part (sub_nf.2) requires a composition argument
  -- for non-interval zones. This is the Feferman-Vaught composition theorem for
  -- linear orders. The formula uses nf_full_compat_right (v1 filter) which only
  -- checks atom compatibility, not quantifier conditions for non-interval ssns.
  --
  -- Interval zones (zone 3): positive from Since/Until witnesses in formula.
  -- Non-interval zones (1,2,4,5): require composition argument.
  --
  -- At k=0: depth-0 3-var NFs are purely atomic; the composition reduces
  -- to showing 3-var atom existentials are determined by endpoint 1-var NFs.
  -- At k>=1: requires full Feferman-Vaught composition for linear orders.
  sorry

/-! ## Master Simultaneous Induction -/

private abbrev P1 {sig : MonadicSignature} (atomMap : Formula → sig.preds) (k : Nat) : Prop :=
  ∀ nf : NormalForm sig k 1, ∃ A : Formula,
    ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf

private abbrev P2 {sig : MonadicSignature} (atomMap : Formula → sig.preds) (k : Nat) : Prop :=
  ∀ (parent_atoms : AtomKind sig 1 → Bool) (sub_nf : NormalForm sig k 2),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf)

/-- The master simultaneous induction. -/
noncomputable def master_induction
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    (k : Nat) → P1 atomMap k ∧ P2 atomMap k
  | 0 => ⟨
    -- P1(0): depth-0 char formula
    fun nf => ⟨nf_depth0_char_formula atomMap h_surj nf,
      fun M _ _ t => nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf t⟩,
    -- P2(0): nf_exist_formula at depth 0
    fun parent_atoms sub_nf =>
      ⟨nf_exist_formula atomMap h_surj 0
          (fun nf => nf_depth0_char_formula atomMap h_surj nf) parent_atoms sub_nf,
       fun M _h_UZ _h_SZ t h_atoms => ⟨
        backward_depth0 atomMap h_surj _ (fun nf_0 s =>
          nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf_0 s)
          parent_atoms sub_nf h_atoms,
        nf_exist_formula_forward' atomMap h_surj 0 _ (fun nf_0 s =>
          nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf_0 s)
          parent_atoms sub_nf h_atoms⟩⟩⟩
  | k + 1 =>
    let ⟨p1_k, p2_k⟩ := master_induction atomMap h_surj k
    let char_k : NormalForm sig k 1 → Formula := fun nf_k => Classical.choose (p1_k nf_k)
    have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k :=
      fun nf_k => Classical.choose_spec (p1_k nf_k)
    -- P1(k+1): built from P1(k) + P2(k), no sorry
    have p1_kp1 : P1 atomMap (k + 1) := fun nf =>
      nf_char_kp1_from_2var atomMap h_surj k char_k char_k_correct p2_k nf
    -- P2(k+1): Uses `nf_exist_formula_nested` which encodes the FULL 2-var NF
    -- including sub_nf.2 (the quantifier part) via nested Until/Since chains
    -- with char_{k+1} characterization formulas for interval witnesses.
    --
    -- The formula uses char_kp1 (depth k+1) rather than char_k (depth k) for
    -- interval witnesses. This is essential: the depth-(k+1) 1-var NF of y
    -- records all depth-k 2-var NFs at pairs involving y, enabling the
    -- backward direction to recover the 3-var NF at (y,x,t) via composition.
    --
    -- The nested formula places the main witness x via Until/Since and encodes
    -- interval quantifier conditions from sub_nf.2 using nested Since/Until
    -- from x into the interval (t, x) or (x, t), with char_{k+1}(nf_y) formulas
    -- characterizing the interval witnesses.
    --
    -- Forward: existential witnesses -> formula truth (Phase 4)
    -- Backward: formula truth -> existential witnesses (Phase 5)
    --   Uses Prior-UZ/SZ for witness extraction at each nesting level.
    --
    -- See plan v20 phases 3-5 and Rabinovich 2014 Notation 5.2 + Prop 3.5.
    have p2_kp1 : P2 atomMap (k + 1) := by
      intro parent_atoms sub_nf
      let char_kp1 : NormalForm sig (k + 1) 1 → Formula :=
        fun nf_1 => Classical.choose (p1_kp1 nf_1)
      have _char_kp1_correct : ∀ (nf_1 : NormalForm sig (k + 1) 1)
          (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          temporal_truth M atomMap t (char_kp1 nf_1) ↔
          nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1 :=
        fun nf_1 => Classical.choose_spec (p1_kp1 nf_1)
      refine ⟨nf_exist_formula_nested k char_kp1
          parent_atoms sub_nf,
        fun M h_UZ h_SZ t h_atoms => ?_⟩
      constructor
      · -- Backward: formula truth → existential (Phase 5)
        exact nf_exist_formula_nested_backward atomMap h_surj k char_kp1
          _char_kp1_correct p2_k parent_atoms sub_nf h_UZ h_SZ h_atoms
      · -- Forward: existential → formula truth (Phase 4)
        exact nf_exist_formula_nested_forward atomMap h_surj k char_kp1 _char_kp1_correct
          parent_atoms sub_nf h_UZ h_SZ h_atoms
    ⟨p1_kp1, p2_kp1⟩

/-- Extract P2 from the master induction. This has the same type as
    `nf_2var_exist_formula_prior` and can be used to fill the sorry.
    Currently sorry-free at k=0, sorry at k>=1. -/
noncomputable def nf_2var_exist_formula_prior_fill
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
  (master_induction atomMap h_surj k).2 parent_atoms sub_nf

end Bimodal.Metalogic.WeakCanonical.Kamp
