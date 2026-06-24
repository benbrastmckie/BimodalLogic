import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.Translation
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation
import Mathlib.Data.Fintype.Card

/-!
# Depth-0 All-Arity NF Existential Conversion

At depth 0, the n-variable existential over a depth-0 NF is TL-definable.
The proof reduces multi-variable existentials to nested Since/Until chains.

## Approach

The succ case proceeds in three sub-cases:
(a) NF order is inconsistent (has a pair cycle or non-transitive triple):
    existential is empty, return `Formula.bot`.
(b) NF has positions that must be equal (both order booleans false):
    check predicate compatibility. If incompatible, return bot. If compatible,
    merge equal positions and apply IH at reduced arity.
(c) NF order is a transitive tournament (strict total order):
    use `translateEF1` from Translation.lean to build a formula that handles
    all positions simultaneously, avoiding the cross-condition problem.

## References

- Rabinovich 2014, Section 5, Proposition 3.5
- Translation.lean (translateEF1, translateEF1_correct)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula
  nf_depth0_char_formula_correct)

/-! ## Environment insertion -/

/-- Insert t at position n, with env providing positions 0..n-1. -/
def insertEnv {α : Type*} {n : Nat} (env : Fin n → α) (t : α) :
    Fin (n + 1) → α :=
  fun i => if h : i.val < n then env ⟨i.val, h⟩ else t

theorem insertEnv_last {α : Type*} {n : Nat} (env : Fin n → α) (t : α) :
    insertEnv env t ⟨n, by omega⟩ = t := by
  simp [insertEnv]

theorem insertEnv_init {α : Type*} {n : Nat} (env : Fin n → α) (t : α)
    (i : Fin n) : insertEnv env t ⟨i.val, by omega⟩ = env i := by
  simp [insertEnv, i.isLt]

theorem insertEnv_zero {α : Type*} (t : α) :
    insertEnv (Fin.elim0 : Fin 0 → α) t = fun _ => t := by
  funext i; simp [insertEnv]

/-! ## Helper: Predicate conjunction at a position -/

/-- Build a TemporalPred from the predicate assignment at position `pos`
    in a depth-0 NF. -/
noncomputable def nfPredAtPos {sig : MonadicSignature} {arity : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 arity) (pos : Fin arity) : TemporalPred :=
  nfPred atomMap h_surj (fun a => match a with
    | .pred p _ => sub_nf (.pred p pos)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h)

/-- `nfPredAtPos` evaluates correctly. -/
theorem nfPredAtPos_correct {sig : MonadicSignature} {arity : Nat}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 arity) (pos : Fin arity) (t : M.carrier) :
    (nfPredAtPos atomMap h_surj sub_nf pos).eval_at M atomMap t ↔
    ∀ p : sig.preds, M.interp p t ↔ (sub_nf (.pred p pos) = true) := by
  simp only [nfPredAtPos]
  rw [nfPred_correct]
  simp only [nf_eval_nf]
  constructor
  · intro h p
    have := h (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at this
    exact this
  · intro h a
    match a with
    | .pred p _ => simp only [atom_eval]; exact h p
    | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-! ## Depth-0 NF inconsistency -/

theorem nf_depth0_pair_cycle_empty' {sig : MonadicSignature} {m : Nat}
    (sub_nf : NormalForm sig 0 m)
    {i j : Fin m} (h_ne : i ≠ j)
    (h_ij : sub_nf (.order i j h_ne) = true)
    (h_ji : sub_nf (.order j i (Ne.symm h_ne)) = true)
    (M : OrderedMonadicStructure sig)
    (env : Fin m → M.carrier) :
    ¬ nf_eval_nf M 0 m env sub_nf := by
  intro h_nf
  have h1 := (h_nf (.order i j h_ne)).mpr h_ij
  have h2 := (h_nf (.order j i (Ne.symm h_ne))).mpr h_ji
  simp only [atom_eval] at h1 h2
  exact absurd (lt_trans h1 h2) (lt_irrefl _)

/-! ## Succ case: translateEF1-based construction

For the strict+transitive case of the succ step, we build the formula
using `translateEF1`. The rank function maps each position to its rank
in the NF-determined total order, and the sorted permutation defines
the alpha/beta parameters.

The merge case handles NF-equal positions by reducing arity. -/

/-- The succ case of `nf_nvar_exist_depth0_tl`: given a depth-0 NF at
    arity n+2 and the IH for arity n+1, produce a temporal formula
    equivalent to the (n+1)-variable existential.

    This is the key lemma that was previously blocked by the cross-condition
    issue. The fix uses translateEF1 for the strict case instead of the
    IH-based Since/Until construction that can't capture cross-conditions. -/
private theorem nf_nvar_exist_depth0_tl_succ
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 2))
    (ih : ∀ (sub_nf' : NormalForm sig 0 (n + 1)),
      ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
        temporal_truth M atomMap t A ↔
        ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf') :
    ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ env : Fin (n + 1) → M.carrier,
        nf_eval_nf M 0 (n + 2) (insertEnv env t) sub_nf := by
  -- Check for pair cycle
  by_cases h_pair : ∃ (i j : Fin (n + 2)) (h : i ≠ j),
      sub_nf (.order i j h) = true ∧ sub_nf (.order j i (Ne.symm h)) = true
  · -- Pair cycle: existential is empty
    obtain ⟨i, j, h_ne, h_ij, h_ji⟩ := h_pair
    exact ⟨Formula.bot, fun M t => by
      constructor
      · exact False.elim
      · intro ⟨env, h_nf⟩
        exact nf_depth0_pair_cycle_empty' sub_nf h_ne h_ij h_ji M (insertEnv env t) h_nf⟩
  · push_neg at h_pair
    -- Check for NF-equal pair (both order booleans false)
    by_cases h_has_eq : ∃ (i j : Fin (n + 2)) (h : i ≠ j),
        sub_nf (.order i j h) = false ∧ sub_nf (.order j i (Ne.symm h)) = false
    · -- Case A: NF-equal pair exists.
      obtain ⟨i, j, h_ne, h_ij_false, h_ji_false⟩ := h_has_eq
      -- In any satisfying assignment, positions i and j get the same value.
      -- We merge: reduce to arity n+1 and use the IH.
      -- For this to work, all order/predicate conditions at j must be
      -- identical to those at i (otherwise the NF is unsatisfiable).
      --
      -- Check full compatibility: predicates AND orders at i and j agree.
      by_cases h_compat : (∀ p : sig.preds, sub_nf (.pred p i) = sub_nf (.pred p j)) ∧
          (∀ (k : Fin (n + 2)) (h_ki : k ≠ i) (h_kj : k ≠ j),
            sub_nf (.order i k (Ne.symm h_ki)) = sub_nf (.order j k (Ne.symm h_kj)) ∧
            sub_nf (.order k i h_ki) = sub_nf (.order k j h_kj))
      · -- Compatible: merge and use IH.
        -- We merge position j onto position i. The resulting NF at arity n+1
        -- has position i serving double duty for both original positions i and j.
        --
        -- Specifically, define merged NF by dropping position j:
        -- merged(.pred p k) = sub_nf(.pred p (skipFin j k))
        -- merged(.order k₁ k₂ _) = sub_nf(.order (skipFin j k₁) (skipFin j k₂) _)
        -- where skipFin j maps Fin (n+1) → Fin (n+2) skipping j.
        sorry
      · -- Incompatible: NF is unsatisfiable (positions forced equal but differ).
        -- Any satisfying env would force insertEnv env t i = insertEnv env t j
        -- (from both order bools being false), but then the differing conditions
        -- at i and j can't both be satisfied.
        push_neg at h_compat
        exact ⟨Formula.bot, fun M t => by
          constructor
          · exact False.elim
          · intro ⟨env, h_nf⟩
            -- Positions i and j get the same value
            have h_eq : insertEnv env t i = insertEnv env t j := by
              by_contra h_ne_vals
              rcases lt_or_gt_of_ne h_ne_vals with h_lt | h_gt
              · have := (h_nf (.order i j h_ne)).mp h_lt
                rw [h_ij_false] at this; exact Bool.noConfusion this
              · have := (h_nf (.order j i (Ne.symm h_ne))).mp h_gt
                rw [h_ji_false] at this; exact Bool.noConfusion this
            -- The incompatibility gives us a contradiction.
            -- h_compat says: either predicates disagree, or some order pair disagrees.
            -- In both cases, h_eq (value(i) = value(j)) gives a contradiction.
            --
            -- General principle: if value(i) = value(j) in a satisfying assignment,
            -- then ALL NF conditions at i and j must be identical.
            -- If any differ, the NF is unsatisfiable.
            --
            -- We prove this by showing all NF booleans involving i agree with j.
            -- Helper: when two Iff's share the same LHS, the RHS's are equal (for Bool).
            have iff_bool_eq : ∀ (P : Prop) (b₁ b₂ : Bool),
                (P ↔ b₁ = true) → (P ↔ b₂ = true) → b₁ = b₂ := by
              intro P b₁ b₂ h₁ h₂
              cases b₁ <;> cases b₂ <;> simp_all
            have h_pred_eq : ∀ p : sig.preds,
                sub_nf (.pred p i) = sub_nf (.pred p j) := by
              intro p
              have h_pi := h_nf (.pred p i)
              have h_pj := h_nf (.pred p j)
              simp only [atom_eval, h_eq] at h_pi h_pj
              exact iff_bool_eq _ _ _ h_pi h_pj
            have h_ord_eq : ∀ (k : Fin (n + 2)) (h_ki : k ≠ i) (h_kj : k ≠ j),
                sub_nf (.order i k (Ne.symm h_ki)) = sub_nf (.order j k (Ne.symm h_kj)) ∧
                sub_nf (.order k i h_ki) = sub_nf (.order k j h_kj) := by
              intro k h_ki h_kj
              constructor
              · have h_ik := h_nf (.order i k (Ne.symm h_ki))
                have h_jk := h_nf (.order j k (Ne.symm h_kj))
                simp only [atom_eval, h_eq] at h_ik h_jk
                exact iff_bool_eq _ _ _ h_ik h_jk
              · have h_ki' := h_nf (.order k i h_ki)
                have h_kj' := h_nf (.order k j h_kj)
                simp only [atom_eval, h_eq] at h_ki' h_kj'
                exact iff_bool_eq _ _ _ h_ki' h_kj'
            -- h_compat gives: predicates agree → ∃ k with order disagreement
            obtain ⟨k, h_ki, h_kj, h_fail⟩ := h_compat h_pred_eq
            exact absurd (h_ord_eq k h_ki h_kj).2 (h_fail (h_ord_eq k h_ki h_kj).1)⟩
    · -- Case B: All pairs are strictly ordered (no NF-equalities).
      push_neg at h_has_eq
      -- Every pair has exactly one order boolean true.
      -- Check transitivity.
      by_cases h_trans : ∀ (a b c : Fin (n + 2))
          (h_ab : a ≠ b) (h_bc : b ≠ c) (h_ac : a ≠ c),
          sub_nf (.order a b h_ab) = true →
          sub_nf (.order b c h_bc) = true →
          sub_nf (.order a c h_ac) = true
      · -- Transitive strict total order. Use translateEF1.
        -- The NF order defines a unique total ordering of n+2 positions.
        -- Position n+1 (= t, the free variable) has some rank k.
        -- translateEF1 (n+1) k alpha beta with alpha from nfPredAtPos
        -- and beta = TemporalPred.top gives the formula.
        sorry
      · -- Non-transitive: find 3-cycle, existential is empty.
        push_neg at h_trans
        obtain ⟨a, b, c, h_ab, h_bc, h_ac, h_ord_ab, h_ord_bc, h_not_ac⟩ := h_trans
        have h_ac_false : sub_nf (.order a c h_ac) = false := by
          cases h : sub_nf (.order a c h_ac) <;> simp_all
        -- From h_has_eq: since .order a c is false, .order c a must be true
        -- (otherwise both false, contradicting h_has_eq)
        have h_ca_true : sub_nf (.order c a (Ne.symm h_ac)) = true := by
          by_contra h_ca
          have h_ca_false : sub_nf (.order c a (Ne.symm h_ac)) = false := by
            cases sub_nf (.order c a (Ne.symm h_ac)) <;> simp_all
          exact h_has_eq a c h_ac h_ac_false h_ca_false
        exact ⟨Formula.bot, fun M t => by
          constructor
          · intro h_bot; exact absurd h_bot id
          · intro ⟨env, h_nf⟩
            have h1 := (h_nf (.order a b h_ab)).mpr h_ord_ab
            have h2 := (h_nf (.order b c h_bc)).mpr h_ord_bc
            have h3 := (h_nf (.order c a (Ne.symm h_ac))).mpr h_ca_true
            simp only [atom_eval] at h1 h2 h3
            exact absurd (lt_trans (lt_trans h1 h2) h3) (lt_irrefl _)⟩

/-! ## The main theorem -/

/-- At depth 0, the n-variable existential is TL-definable. -/
theorem nf_nvar_exist_depth0_tl
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1)) :
    ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf := by
  induction n with
  | zero =>
    exact ⟨Separation.nf_depth0_char_formula atomMap h_surj sub_nf,
      fun M t => by
        constructor
        · intro h_tt
          refine ⟨Fin.elim0, ?_⟩
          have : insertEnv (Fin.elim0 : Fin 0 → M.carrier) t = fun _ => t := insertEnv_zero t
          rw [this]
          rw [nf_depth0_char_formula_correct] at h_tt
          intro a
          match a with
          | .pred p ⟨0, _⟩ => simp only [atom_eval]; exact h_tt p
          | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq
        · intro ⟨env, h_nf⟩
          have : insertEnv env t = fun _ => t := by
            funext ⟨i, hi⟩; simp [insertEnv]
          rw [this] at h_nf
          rw [nf_depth0_char_formula_correct]
          intro p
          have := h_nf (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at this; exact this⟩
  | succ n ih =>
    exact nf_nvar_exist_depth0_tl_succ atomMap h_surj n sub_nf ih

/-- Convenience wrapper: extract just the formula. -/
noncomputable def nf_nvar_exist_depth0_tl_fn
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1)) : Formula :=
  (nf_nvar_exist_depth0_tl atomMap h_surj n sub_nf).choose

/-- Correctness of the convenience wrapper. -/
theorem nf_nvar_exist_depth0_tl_fn_correct
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1))
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    temporal_truth M atomMap t (nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub_nf) ↔
    ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf :=
  (nf_nvar_exist_depth0_tl atomMap h_surj n sub_nf).choose_spec M t

end Bimodal.Metalogic.WeakCanonical.Kamp
