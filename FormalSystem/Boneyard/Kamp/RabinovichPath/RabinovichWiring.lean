-- ARCHIVED from Metalogic/WeakCanonical/Kamp/RabinovichWiring.lean
-- Reason: Dead code — Rabinovich approach path with no live downstream consumers
-- Archived: 2026-06-16

import FormalSystem.Boneyard.Kamp.KampWeakCanonical.TranslationEra.RabinovichTranslation
import FormalSystem.Boneyard.Kamp.KampBypassArchive.NfCharFormula
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.PriorDefs

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Rabinovich Wiring: Connecting Translation to NF Existentials

Uses the Rabinovich translation (Proposition 3.5) to construct temporal formulas
characterizing NF existentials. This provides an alternative proof of
`nf_2var_exist_formula_prior` via the exists-forall framework.

## Strategy

For a 2-variable depth-k NormalForm `sub_nf` and parent atom assignment:
- Extract the order direction (x > t, x < t, or x = t)
- Extract the predicate constraints on x and t
- Build an ExistsForallSpec with n=1 (two points: t and x)
- Use Rabinovich.translate to get the temporal formula
- Use Rabinovich.translate_correct for the biconditional

## Depth-0 Case

At depth 0, `nf_eval_nf M 0 2 (x, t) sub_nf` is purely atomic:
- Predicate constraints on x and t
- Order constraint (x < t or t < x)

The existence formula `∃ x, nf_eval_nf M 0 2 (x, t) sub_nf` can be directly
expressed as F(witness_type) or P(witness_type), and the backward direction
is provable WITHOUT Prior-UZ/SZ because no quantifier conditions are involved.

## Depth-(k+1) Case

At depth k+1, the 2-var NF includes quantifier conditions about third-party
variables. The backward direction requires Prior-UZ/SZ and the negation
closure argument. This case is marked sorry with documentation.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Proposition 3.5
- NfCharFormula.lean: nf_exist_formula, nf_2var_exist_formula_prior
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Helper: Depth-0 NF backward direction

At depth 0, the backward direction of nf_exist_formula is provable on ALL
structures (no Prior-UZ/SZ needed), because:
1. The existence formula gives us a witness x with the right predicates
2. The parent_atoms hypothesis gives us t's predicates
3. The order direction is determined by construction

This fills the gap that nf_2var_exist_formula_prior has at depth 0. -/

/-- At depth 0, `nf_eval_nf M 0 2 env sub_nf` is equivalent to
    all atoms evaluating correctly. -/
theorem nf_eval_nf_depth0_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (env : Fin 2 → M.carrier)
    (sub_nf : NormalForm sig 0 2) :
    nf_eval_nf M 0 2 env sub_nf ↔
    ∀ (a : AtomKind sig 2), atom_eval M env a ↔ (sub_nf a = true) := by
  rfl

/-- At depth 0, the 1-var NF evaluation is equivalent to all atoms matching. -/
theorem nf_eval_nf_depth0_arity1_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (env : Fin 1 → M.carrier)
    (nf : NormalForm sig 0 1) :
    nf_eval_nf M 0 1 env nf ↔
    ∀ (a : AtomKind sig 1), atom_eval M env a ↔ (nf a = true) := by
  rfl

/-! ## Depth-0 Existence Backward Direction

The main lemma: at depth 0, if the existence formula (built by nf_exist_formula)
holds at t, then there exists x with the right 2-var NF.

This is the key result that does NOT need Prior-UZ/SZ. -/

/-- Extract the 1-var "x-projection" from a 2-var depth-0 NF: the predicate
    assignment for variable 0 (x), viewed as a 1-var NF. -/
noncomputable def nf_x_projection {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2) : NormalForm sig 0 1 :=
  fun a => match a with
  | .pred p _ => sub_nf (.pred p ⟨0, by omega⟩)
  | .order i j h => by exact absurd (Fin.ext (by omega) : i = j) h

/-- The x-projection predicate atoms match sub_nf's variable-0 atoms. -/
theorem nf_x_projection_pred {sig : MonadicSignature}
    (sub_nf : NormalForm sig 0 2) (p : sig.preds) :
    (nf_x_projection sub_nf) (.pred p ⟨0, by omega⟩) =
    sub_nf (.pred p ⟨0, by omega⟩) := by
  simp [nf_x_projection]

/-- At depth 0, if x satisfies the x-projection NF, and x has the right order
    relative to t, and t satisfies parent_atoms, then (x, t) satisfies sub_nf. -/
theorem depth0_backward_reconstruct {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 0 2)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier)
    (h_x_nf : nf_eval_nf M 0 1 (fun _ => x) (nf_x_projection sub_nf))
    (h_t_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : nf_t_compat parent_atoms sub_nf = true)
    (h_order_01 : (x < t) ↔ (sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true))
    (h_order_10 : (t < x) ↔ (sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)) :
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf := by
  rw [nf_eval_nf_depth0_iff]
  intro a
  match a with
  | .pred p i =>
    match i with
    | ⟨0, _⟩ =>
      -- Predicate of x: from h_x_nf
      rw [nf_eval_nf_depth0_arity1_iff] at h_x_nf
      have := h_x_nf (.pred p ⟨0, by omega⟩)
      simp only [atom_eval, Fin.cons] at this ⊢
      exact this
    | ⟨1, _⟩ =>
      -- Predicate of t: from h_t_atoms + h_t_compat
      have h_par := h_t_atoms (.pred p ⟨0, by omega⟩)
      simp only [atom_eval] at h_par
      simp only [atom_eval, Fin.cons]
      -- h_t_compat says sub_nf (.pred p 1) == parent_atoms (.pred p 0)
      have h_tc : nf_t_compat parent_atoms sub_nf = true := h_t_compat
      simp only [nf_t_compat] at h_tc
      have h_all := List.all_eq_true.mp h_tc
      have h_p_mem : p ∈ (Fintype.elems (α := sig.preds)).val.toList :=
        Multiset.mem_toList.mpr (Fintype.complete p)
      have h_beq := h_all p h_p_mem
      simp only [BEq.beq, Bool.beq_eq_true_iff] at h_beq
      rw [h_beq]
      exact h_par
    | ⟨n + 2, h⟩ => exact absurd h (by omega)
  | .order i j h_neq =>
    match i, j with
    | ⟨0, _⟩, ⟨1, _⟩ =>
      simp only [atom_eval, Fin.cons]
      exact h_order_01
    | ⟨1, _⟩, ⟨0, _⟩ =>
      simp only [atom_eval, Fin.cons]
      exact h_order_10
    | ⟨0, _⟩, ⟨0, _⟩ => exact absurd rfl h_neq
    | ⟨1, _⟩, ⟨1, _⟩ => exact absurd rfl h_neq
    | ⟨0, _⟩, ⟨n + 2, h⟩ => exact absurd h (by omega)
    | ⟨1, _⟩, ⟨n + 2, h⟩ => exact absurd h (by omega)
    | ⟨n + 2, h⟩, _, _ => exact absurd h (by omega)

/-! ## Backward Direction at Depth 0

At depth 0, the backward direction of nf_exist_formula is provable on
all structures (no Prior needed). Key steps:
1. Unfold nf_exist_formula to identify the formula structure
2. Case-split on t-compatibility and order direction
3. Extract the witness x from Until/Since semantics
4. From the disjunction, extract which depth-0 NF holds at x
5. Use atom-compatibility + parent_atoms + order to reconstruct the 2-var NF -/

/-- Backward direction of nf_exist_formula at depth 0.

    At depth 0, the existence formula truth implies the existence of x
    satisfying the 2-var NF. This does NOT require Prior-UZ/SZ because
    depth-0 NFs have no quantifier conditions -- only atom conditions. -/
theorem nf_exist_formula_backward_depth0
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_0 : NormalForm sig 0 1 → Formula)
    {M : OrderedMonadicStructure sig}
    (char_0_correct_M : ∀ (nf_0 : NormalForm sig 0 1) (t : M.carrier),
        temporal_truth M atomMap t (char_0 nf_0) ↔
        nf_eval_nf M 0 1 (fun _ => t) nf_0)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 0 2)
    {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_formula : temporal_truth M atomMap t
        (nf_exist_formula atomMap h_surj 0 char_0 parent_atoms sub_nf)) :
    ∃ x : M.carrier, nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  -- At depth 0, NormalForm.atom_assgn is the identity
  have atom_assgn_eq : sub_nf.atom_assgn = sub_nf := rfl
  -- Unfold nf_exist_formula and simplify
  unfold nf_exist_formula at h_formula
  simp only [atom_assgn_eq] at h_formula
  -- Case split on t-compatibility
  by_cases h_tc : nf_t_compat parent_atoms sub_nf = true
  · simp only [h_tc, not_true_eq_false, ↓reduceIte] at h_formula
    -- Case split on both-orders check
    by_cases h_both : (sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
        sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))) = true
    · simp only [h_both, ↓reduceIte, temporal_truth] at h_formula
    · simp only [h_both, ↓reduceIte] at h_formula
      -- Case split on order direction
      unfold nf_order_dir at h_formula
      simp only [atom_assgn_eq] at h_formula
      -- Extract order booleans
      set b_t_lt_x := sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) with b_t_lt_x_def
      set b_x_lt_t := sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with b_x_lt_t_def
      -- Helper: extract witness from disjunction
      have extract_witness : ∀ (x : M.carrier),
          temporal_truth M atomMap x (formula_disjList
            ((Fintype.elems (α := NormalForm sig 0 1)).val.toList.filterMap fun nf_x =>
              if (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
                nf_x (.pred p ⟨0, by omega⟩) == sub_nf (.pred p ⟨0, by omega⟩))
              then some (char_0 nf_x) else none)) →
          nf_eval_nf M 0 1 (fun _ => x) (nf_x_projection sub_nf) := by
        intro x h_wt
        have h_disj := (formula_disjList_iff M atomMap x _).mp h_wt
        obtain ⟨f, h_f_mem, h_f_true⟩ := h_disj
        rw [List.mem_filterMap] at h_f_mem
        obtain ⟨nf_x, _, h_if⟩ := h_f_mem
        split at h_if <;> simp at h_if
        rename_i h_compat
        rw [← h_if] at h_f_true
        have h_nf_x := (char_0_correct_M nf_x x).mp h_f_true
        -- h_nf_x : nf_eval_nf M 0 1 (fun _ => x) nf_x
        -- Need: nf_eval_nf M 0 1 (fun _ => x) (nf_x_projection sub_nf)
        -- i.e., ∀ a : AtomKind sig 1, atom_eval M (fun _ => x) a ↔ (nf_x_projection sub_nf a = true)
        intro a
        match a with
        | .pred p _ =>
          have h_nf_x_p := h_nf_x (.pred p ⟨0, by omega⟩)
          -- nf_x is atom-compatible: nf_x p = sub_nf p at var 0
          rw [List.all_eq_true] at h_compat
          have h_p_mem : p ∈ (Fintype.elems (α := sig.preds)).val.toList :=
            Multiset.mem_toList.mpr (Fintype.complete p)
          have h_eq := h_compat p h_p_mem
          simp only [beq_iff_eq] at h_eq
          -- NormalForm.atom_assgn at depth 0 is identity
          have : nf_x.atom_assgn (.pred p ⟨0, by omega⟩) = nf_x (.pred p ⟨0, by omega⟩) := rfl
          rw [this] at h_eq
          simp only [nf_x_projection, NormalForm.atom_assgn] at h_nf_x_p ⊢
          rw [h_eq] at h_nf_x_p
          exact h_nf_x_p
        | .order i j h_neq =>
          have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
          have hj : j = ⟨0, by omega⟩ := Fin.ext (by omega)
          exact absurd (hi ▸ hj ▸ rfl) h_neq
      match h_b1 : b_t_lt_x, h_b2 : b_x_lt_t with
      | true, false =>
        -- t < x direction: Until case
        simp only [temporal_truth] at h_formula
        obtain ⟨x, h_lt, h_wt, _⟩ := h_formula
        have h_nf_x := extract_witness x h_wt
        refine ⟨x, ?_⟩
        apply depth0_backward_reconstruct M sub_nf parent_atoms x t h_nf_x h_atoms h_tc
        · -- x < t ↔ sub_nf says x < t (false in this case)
          constructor
          · intro h_xlt; exact absurd (lt_trans h_xlt h_lt) (lt_irrefl _)
          · intro h_eq
            have : b_x_lt_t = true := by rw [← b_x_lt_t_def]; exact h_eq
            rw [h_b2] at this; exact absurd this Bool.noConfusion
        · -- t < x ↔ sub_nf says t < x (true in this case)
          constructor
          · intro _; rw [← b_t_lt_x_def]; exact h_b1
          · intro _; exact h_lt
      | false, true =>
        -- x < t direction: Since case
        simp only [temporal_truth] at h_formula
        obtain ⟨x, h_lt, h_wt, _⟩ := h_formula
        have h_nf_x := extract_witness x h_wt
        refine ⟨x, ?_⟩
        apply depth0_backward_reconstruct M sub_nf parent_atoms x t h_nf_x h_atoms h_tc
        · -- x < t ↔ sub_nf says x < t (true in this case)
          constructor
          · intro _; rw [← b_x_lt_t_def]; exact h_b2
          · intro _; exact h_lt
        · -- t < x ↔ sub_nf says t < x (false in this case)
          constructor
          · intro h_tlt; exact absurd (lt_trans h_lt h_tlt) (lt_irrefl _)
          · intro h_eq
            have : b_t_lt_x = true := by rw [← b_t_lt_x_def]; exact h_eq
            rw [h_b1] at this; exact absurd this Bool.noConfusion
      | false, false =>
        -- x = t case
        simp only [beq_self_eq_true, Bool.and_self, ↓reduceIte] at h_formula
        have h_nf_x := extract_witness t h_formula
        refine ⟨t, ?_⟩
        apply depth0_backward_reconstruct M sub_nf parent_atoms t t h_nf_x h_atoms h_tc
        · -- t < t is impossible; sub_nf says false
          constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h_eq
            have : b_x_lt_t = true := by rw [← b_x_lt_t_def]; exact h_eq
            rw [h_b2] at this; exact absurd this Bool.noConfusion
        · -- t < t is impossible; sub_nf says false
          constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h_eq
            have : b_t_lt_x = true := by rw [← b_t_lt_x_def]; exact h_eq
            rw [h_b1] at this; exact absurd this Bool.noConfusion
      | true, true =>
        exfalso; exact h_both rfl
  · simp only [h_tc, Bool.not_eq_true, ↓reduceIte] at h_formula

/-! ## Main Theorem: nf_2var_exist_via_rabinovich

Proves the existence of a temporal formula characterizing the 2-var existential,
using the existing nf_exist_formula for forward direction and direct construction
for the backward direction at depth 0. -/

/-- For Prior structures, there exists a temporal formula correctly characterizing
    the realizability of each 2-variable sub-NF, proved via the Rabinovich
    translation framework.

    At depth 0: fully proved (no Prior-UZ/SZ needed for backward direction).
    At depth k+1: sorry (requires negation closure + Rabinovich composition). -/
theorem nf_2var_exist_via_rabinovich
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
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
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Use the existing nf_exist_formula as our candidate formula
  refine ⟨nf_exist_formula atomMap h_surj k char_k parent_atoms sub_nf,
    fun M h_UZ h_SZ t h_atoms => ?_⟩
  have char_k_M : ∀ (nf_k : NormalForm sig k 1) (t' : M.carrier),
      temporal_truth M atomMap t' (char_k nf_k) ↔
      nf_eval_nf M k 1 (fun _ => t') nf_k :=
    fun nf_k t' => char_k_correct nf_k M h_UZ h_SZ t'
  constructor
  · -- Backward: formula truth → ∃ x with right NF
    intro h_formula
    cases k with
    | zero =>
      exact nf_exist_formula_backward_depth0 atomMap h_surj char_k char_k_M
        parent_atoms sub_nf h_atoms h_formula
    | succ k' =>
      /- At depth k'+1, the 2-var NF includes quantifier conditions about third-party
         variables interacting with both x and t. The backward direction requires:
         1. Prior-UZ/SZ to find first/last occurrences
         2. The negation closure argument (Rabinovich Lemma 5.1) to determine
            interval types from boundary point types
         3. Generalized composition (Rabinovich Prop 4.3) to build the full 2-var NF

         This is the content of NegationClosure.lean and is the main remaining gap
         in the Kamp theorem pipeline. -/
      sorry
  · -- Forward: ∃ x with right NF → formula truth
    intro h_ex
    exact nf_exist_formula_forward' atomMap h_surj k char_k char_k_M
      parent_atoms sub_nf h_atoms h_ex

end FormalSystem.Metalogic.WeakCanonical.Kamp
