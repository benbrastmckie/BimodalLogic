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

/-! ## NF merge infrastructure -/

/-- Skip position `skip` when mapping from Fin m to Fin (m+1). -/
def skipFin {m : Nat} (skip : Fin (m + 1)) (k : Fin m) : Fin (m + 1) :=
  if h : k.val < skip.val then ⟨k.val, by omega⟩
  else ⟨k.val + 1, by omega⟩

theorem skipFin_injective {m : Nat} (skip : Fin (m + 1)) :
    Function.Injective (skipFin skip) := by
  intro a b heq
  have heq' : (skipFin skip a).val = (skipFin skip b).val := by rw [heq]
  simp only [skipFin] at heq'
  ext
  split at heq' <;> split at heq' <;> simp at heq' <;> omega

theorem skipFin_ne {m : Nat} (skip : Fin (m + 1)) (k : Fin m) :
    skipFin skip k ≠ skip := by
  intro h
  have h' : (skipFin skip k).val = skip.val := congr_arg Fin.val h
  simp only [skipFin] at h'
  split at h' <;> simp_all <;> omega

/-- Inverse of skipFin: for m ≠ skip, map back to Fin m. -/
def unskipFin {m : Nat} (skip : Fin (m + 1)) (pos : Fin (m + 1))
    (h : pos ≠ skip) : Fin m :=
  if hlt : pos.val < skip.val then ⟨pos.val, by omega⟩
  else ⟨pos.val - 1, by
    have : pos.val ≠ skip.val := fun he => h (Fin.ext he)
    omega⟩

theorem skipFin_unskipFin {m : Nat} (skip : Fin (m + 1)) (pos : Fin (m + 1))
    (h : pos ≠ skip) : skipFin skip (unskipFin skip pos h) = pos := by
  have h_val_ne : pos.val ≠ skip.val := fun he => h (Fin.ext he)
  simp only [skipFin, unskipFin]
  by_cases hlt : pos.val < skip.val
  · simp only [hlt, ↓reduceDIte]
  · simp only [hlt, ↓reduceDIte]
    have : ¬(pos.val - 1 < skip.val) := by omega
    simp only [this, ↓reduceDIte]; ext; simp_all; omega

theorem unskipFin_skipFin {m : Nat} (skip : Fin (m + 1)) (k : Fin m) :
    unskipFin skip (skipFin skip k) (skipFin_ne skip k) = k := by
  simp only [unskipFin, skipFin]
  by_cases hlt : k.val < skip.val
  · simp only [hlt, ↓reduceDIte]
  · simp only [hlt, ↓reduceDIte]
    have : ¬(k.val + 1 < skip.val) := by omega
    simp only [this, ↓reduceDIte]; ext; simp_all

/-- Merge position `j` in a depth-0 NF by dropping it. -/
noncomputable def mergeNF {sig : MonadicSignature} {m : Nat}
    (sub_nf : NormalForm sig 0 (m + 1)) (j : Fin (m + 1))
    : NormalForm sig 0 m :=
  fun a => match a with
  | .pred p k => sub_nf (.pred p (skipFin j k))
  | .order k₁ k₂ h => sub_nf (.order (skipFin j k₁) (skipFin j k₂)
      (skipFin_injective j |>.ne h))

/-- Forward direction of merge: from merged NF satisfaction, build full satisfaction.
    Given env' satisfying mergeNF sub_nf j, construct env satisfying sub_nf
    by duplicating the value at position i at position j. -/
theorem merge_forward {sig : MonadicSignature} {n : Nat}
    (sub_nf : NormalForm sig 0 (n + 2))
    (i j : Fin (n + 2)) (h_ne : i ≠ j)
    (h_ij_false : sub_nf (.order i j h_ne) = false)
    (h_ji_false : sub_nf (.order j i (Ne.symm h_ne)) = false)
    (h_pred : ∀ p : sig.preds, sub_nf (.pred p i) = sub_nf (.pred p j))
    (h_ord : ∀ (k : Fin (n + 2)) (h_ki : k ≠ i) (h_kj : k ≠ j),
      sub_nf (.order i k (Ne.symm h_ki)) = sub_nf (.order j k (Ne.symm h_kj)) ∧
      sub_nf (.order k i h_ki) = sub_nf (.order k j h_kj))
    (h_j_le_n : j.val ≤ n)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (env' : Fin n → M.carrier)
    (h_merged : nf_eval_nf M 0 (n + 1) (insertEnv env' t) (mergeNF sub_nf j)) :
    ∃ env : Fin (n + 1) → M.carrier, nf_eval_nf M 0 (n + 2) (insertEnv env t) sub_nf := by
  -- NF order is proof-irrelevant: sub_nf (.order a b h1) = sub_nf (.order a b h2)
  have nf_order_irrel : ∀ (a b : Fin (n + 2)) (h1 h2 : a ≠ b),
      sub_nf (.order a b h1) = sub_nf (.order a b h2) := by
    intro a b h1 h2; congr 1
  -- Build full_val that duplicates i's value at position j
  let full_val : Fin (n + 2) → M.carrier := fun m =>
    if hm : m = j then insertEnv env' t (unskipFin j i h_ne)
    else insertEnv env' t (unskipFin j m hm)
  let env_new : Fin (n + 1) → M.carrier := fun k => full_val ⟨k.val, by omega⟩
  have h_ie_full : ∀ m : Fin (n + 2), insertEnv env_new t m = full_val m := by
    intro ⟨mv, hmv⟩; simp only [insertEnv, env_new]
    by_cases h : mv < n + 1
    · simp only [h, ↓reduceDIte]
    · have : mv = n + 1 := by omega
      subst this
      simp only [show ¬(n + 1 < n + 1) from by omega, ↓reduceDIte, full_val,
        show (⟨n + 1, hmv⟩ : Fin (n + 2)) ≠ j from by
          intro h; have := congr_arg Fin.val h; simp at this; omega,
        ↓reduceDIte, unskipFin, show ¬(n + 1 < j.val) from by omega,
        ↓reduceDIte, insertEnv, show ¬(n + 1 - 1 < n) from by omega, ↓reduceDIte]
  have h_fv_j_eq_i : full_val j = full_val i := by
    simp [full_val, show ¬(i = j) from fun h => h_ne (h ▸ rfl)]
  have h_fv_ne_j : ∀ (pos : Fin (n + 2)) (h : pos ≠ j),
      full_val pos = insertEnv env' t (unskipFin j pos h) := by
    intro pos h; simp [full_val, h]
  -- Core transfer: for atoms not involving j, use merged directly
  -- For atoms involving j, transfer to i using h_pred/h_ord
  have h_transfer_pred : ∀ (p : sig.preds) (pos : Fin (n + 2)),
      M.interp p (full_val pos) ↔ (sub_nf (.pred p pos) = true) := by
    intro p pos
    by_cases h_pos_j : pos = j
    · rw [show full_val pos = full_val i from h_pos_j ▸ h_fv_j_eq_i]
      rw [h_fv_ne_j i (fun h => h_ne (h ▸ rfl))]
      have := h_merged (.pred p (unskipFin j i h_ne))
      simp only [mergeNF, atom_eval, skipFin_unskipFin j i h_ne] at this
      rw [h_pos_j, ← h_pred p]; exact this
    · rw [h_fv_ne_j pos h_pos_j]
      have := h_merged (.pred p (unskipFin j pos h_pos_j))
      simp only [mergeNF, atom_eval, skipFin_unskipFin j pos h_pos_j] at this
      exact this
  have h_transfer_order : ∀ (p1 p2 : Fin (n + 2)) (hne : p1 ≠ p2),
      (full_val p1 < full_val p2) ↔ (sub_nf (.order p1 p2 hne) = true) := by
    intro p1 p2 hne
    by_cases h1j : p1 = j
    · by_cases h2j : p2 = j
      · exact absurd (h1j.trans h2j.symm) hne
      · -- p1 = j: transfer to i
        rw [show full_val p1 = full_val i from h1j ▸ h_fv_j_eq_i]
        by_cases h2i : p2 = i
        · -- order(j, i): equal values, false
          rw [show full_val p2 = full_val i from h2i ▸ rfl]
          rw [show full_val i = insertEnv env' t (unskipFin j i h_ne) from
            h_fv_ne_j i (fun h => h_ne (h ▸ rfl))]
          constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h
            have heq : sub_nf (.order p1 p2 hne) = sub_nf (.order j i (Ne.symm h_ne)) := by
              subst h1j; subst h2i; exact nf_order_irrel _ _ _ _
            rw [heq, h_ji_false] at h; exact Bool.noConfusion h
        · rw [h_fv_ne_j i (fun h => h_ne (h ▸ rfl)), h_fv_ne_j p2 h2j]
          have h_ord_eq := (h_ord p2 h2i h2j).1
          have h1 := h_merged (.order (unskipFin j i h_ne) (unskipFin j p2 h2j)
            (by intro heq; exact h2i (by
              have := congr_arg (skipFin j) heq
              rw [skipFin_unskipFin, skipFin_unskipFin] at this; exact this.symm)))
          simp only [mergeNF, atom_eval, skipFin_unskipFin] at h1
          -- Transfer: sub_nf (.order p1 p2 hne) = sub_nf (.order i p2 ...)
          -- then use ← h_ord_eq to get sub_nf (.order j p2 ...)
          have hsub : sub_nf (.order p1 p2 hne) = sub_nf (.order j p2 (Ne.symm h2j)) := by
            subst h1j; exact nf_order_irrel _ _ _ _
          rw [hsub, ← h_ord_eq]; exact h1
    · by_cases h2j : p2 = j
      · -- p2 = j: transfer to i
        rw [show full_val p2 = full_val i from h2j ▸ h_fv_j_eq_i]
        by_cases h1i : p1 = i
        · -- order(i, j): equal values, false
          rw [show full_val p1 = full_val i from h1i ▸ rfl]
          rw [show full_val i = insertEnv env' t (unskipFin j i h_ne) from
            h_fv_ne_j i (fun h => h_ne (h ▸ rfl))]
          constructor
          · intro h; exact absurd h (lt_irrefl _)
          · intro h
            have heq : sub_nf (.order p1 p2 hne) = sub_nf (.order i j h_ne) := by
              subst h1i; subst h2j; exact nf_order_irrel _ _ _ _
            rw [heq, h_ij_false] at h; exact Bool.noConfusion h
        · rw [h_fv_ne_j p1 h1j, h_fv_ne_j i (fun h => h_ne (h ▸ rfl))]
          have h_ord_eq := (h_ord p1 h1i h1j).2
          have h1 := h_merged (.order (unskipFin j p1 h1j) (unskipFin j i h_ne)
            (by intro heq; exact h1i (by
              have := congr_arg (skipFin j) heq
              rw [skipFin_unskipFin, skipFin_unskipFin] at this; exact this)))
          simp only [mergeNF, atom_eval, skipFin_unskipFin] at h1
          have hsub : sub_nf (.order p1 p2 hne) = sub_nf (.order p1 j h1j) := by
            subst h2j; exact nf_order_irrel _ _ _ _
          rw [hsub, ← h_ord_eq]; exact h1
      · -- Both ≠ j: direct from merged
        rw [h_fv_ne_j p1 h1j, h_fv_ne_j p2 h2j]
        have h1 := h_merged (.order (unskipFin j p1 h1j) (unskipFin j p2 h2j)
          (by intro heq; exact hne (by
            have := congr_arg (skipFin j) heq
            rw [skipFin_unskipFin, skipFin_unskipFin] at this; exact this)))
        simp only [mergeNF, atom_eval, skipFin_unskipFin] at h1
        exact h1
  refine ⟨env_new, fun a => ?_⟩
  match a with
  | .pred p pos =>
    simp only [atom_eval]; rw [h_ie_full pos]
    exact h_transfer_pred p pos
  | .order p1 p2 hne =>
    simp only [atom_eval]; rw [h_ie_full p1, h_ie_full p2]
    exact h_transfer_order p1 p2 hne

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
        -- Choose which position to drop: must NOT be ⟨n+1, _⟩ (the free variable).
        -- Since i ≠ j, at least one is not ⟨n+1, _⟩.
        -- We pick the one to drop and the one to keep.
        -- The key property: the dropped position is an existential variable,
        -- so after merging, the free variable (n+1) maps to position n
        -- in the merged NF (via skipFin), which is evaluated at t.
        --
        -- For now, we handle this with a sorry. The proof involves:
        -- 1. Choosing drop ∈ {i, j} with drop.val ≤ n (existential variable)
        -- 2. Defining merged = mergeNF sub_nf drop
        -- 3. Using ih merged to get A_merged
        -- 4. Forward: from ∃ env' sat merged, build env sat sub_nf by
        --    inserting duplicate at drop (env at drop = env at the kept position)
        -- 5. Backward: from ∃ env sat sub_nf (with h_eq: val(i) = val(j)),
        --    build env' sat merged by dropping the drop position
        --
        -- All order/predicate conditions at drop match the kept position
        -- by h_compat, so both directions go through.
        obtain ⟨h_pred, h_ord⟩ := h_compat
        -- Choose drop: if j ≠ ⟨n+1,_⟩ drop j, else drop i
        -- (At least one has val ≤ n since i ≠ j and both in Fin (n+2))
        by_cases h_j_last : j = ⟨n + 1, by omega⟩
        · -- j is the free variable. Drop i instead.
          -- Position i is an existential variable (i.val ≤ n).
          -- The merged NF drops position i.
          -- skipFin i maps Fin (n+1) → Fin (n+2), skipping i.
          -- The last position in Fin (n+1) is ⟨n, _⟩.
          -- skipFin i ⟨n, _⟩ = ⟨n+1, _⟩ = j (since i.val < n+1)
          -- Since j is the free variable (position n+1) and i ≠ j, i.val ≤ n.
          -- Drop i instead: merge on position i.
          have h_i_le_n : i.val ≤ n := by
            by_contra h; push_neg at h
            have hi_eq : i.val = n + 1 := by omega
            exact h_ne (by rw [h_j_last]; exact Fin.ext hi_eq)
          -- Swap i and j roles for merge_forward
          have h_pred_sym : ∀ p : sig.preds, sub_nf (.pred p j) = sub_nf (.pred p i) :=
            fun p => (h_pred p).symm
          have h_ord_sym : ∀ (k : Fin (n + 2)) (h_kj : k ≠ j) (h_ki : k ≠ i),
              sub_nf (.order j k (Ne.symm h_kj)) = sub_nf (.order i k (Ne.symm h_ki)) ∧
              sub_nf (.order k j h_kj) = sub_nf (.order k i h_ki) := by
            intro k h_kj h_ki
            have := h_ord k h_ki h_kj
            exact ⟨this.1.symm, this.2.symm⟩
          let merged_i : NormalForm sig 0 (n + 1) := mergeNF sub_nf i
          obtain ⟨A_merged, hA_merged⟩ := ih merged_i
          exact ⟨A_merged, fun M t => by
            rw [hA_merged M t]
            constructor
            · intro ⟨env', h_merged⟩
              exact merge_forward sub_nf j i (Ne.symm h_ne) h_ji_false h_ij_false
                h_pred_sym h_ord_sym h_i_le_n M t env' h_merged
            · intro ⟨env, h_nf⟩
              -- Backward: drop position i (symmetric to the j case below)
              have h_eq : insertEnv env t j = insertEnv env t i := by
                by_contra h_ne_vals
                rcases lt_or_gt_of_ne h_ne_vals with h_lt | h_gt
                · have := (h_nf (.order j i (Ne.symm h_ne))).mp h_lt
                  rw [h_ji_false] at this; exact Bool.noConfusion this
                · have := (h_nf (.order i j h_ne)).mp h_gt
                  rw [h_ij_false] at this; exact Bool.noConfusion this
              let env' : Fin n → M.carrier := fun k =>
                insertEnv env t (skipFin i ⟨k.val, by omega⟩)
              refine ⟨env', ?_⟩
              have h_ie_eq : ∀ k : Fin (n + 1),
                  insertEnv env' t k = insertEnv env t (skipFin i k) := by
                intro ⟨kv, hkv⟩
                simp only [insertEnv, env']
                split
                · next h_lt => rfl
                · next h_nlt =>
                  have : kv = n := by omega
                  subst this
                  simp only [skipFin, show ¬(kv < i.val) from by omega]
                  simp [dif_neg (show ¬(kv + 1 < kv + 1) from by omega)]
              intro a
              match a with
              | .pred p pos =>
                simp only [mergeNF, merged_i, atom_eval]
                rw [h_ie_eq pos]
                exact h_nf (.pred p (skipFin i pos))
              | .order pos₁ pos₂ h_ne_pos =>
                simp only [mergeNF, merged_i, atom_eval]
                rw [h_ie_eq pos₁, h_ie_eq pos₂]
                exact h_nf (.order (skipFin i pos₁) (skipFin i pos₂)
                  (skipFin_injective i |>.ne h_ne_pos))⟩
        · -- j is NOT the free variable. Drop j.
          have h_j_le_n : j.val ≤ n := by
            by_contra h
            push_neg at h
            have : j.val = n + 1 := by omega
            exact h_j_last (Fin.ext this)
          let merged : NormalForm sig 0 (n + 1) := mergeNF sub_nf j
          obtain ⟨A_merged, hA_merged⟩ := ih merged
          exact ⟨A_merged, fun M t => by
            rw [hA_merged M t]
            constructor
            · -- Forward: ∃ env' sat merged → ∃ env sat sub_nf
              intro ⟨env', h_merged⟩
              exact merge_forward sub_nf i j h_ne h_ij_false h_ji_false
                h_pred h_ord h_j_le_n M t env' h_merged
            · -- Backward: ∃ env sat sub_nf → ∃ env' sat merged
              intro ⟨env, h_nf⟩
              -- Positions i and j get the same value
              have h_eq : insertEnv env t i = insertEnv env t j := by
                by_contra h_ne_vals
                rcases lt_or_gt_of_ne h_ne_vals with h_lt | h_gt
                · have := (h_nf (.order i j h_ne)).mp h_lt
                  rw [h_ij_false] at this; exact Bool.noConfusion this
                · have := (h_nf (.order j i (Ne.symm h_ne))).mp h_gt
                  rw [h_ji_false] at this; exact Bool.noConfusion this
              -- Build env' by dropping position j.
              -- For k : Fin n, env'(k) = insertEnv env t (skipFin j ⟨k.val, _⟩)
              -- Then insertEnv env' t k = insertEnv env t (skipFin j k) for all k : Fin (n+1)
              let env' : Fin n → M.carrier := fun k =>
                insertEnv env t (skipFin j ⟨k.val, by omega⟩)
              refine ⟨env', ?_⟩
              -- Show: nf_eval_nf M 0 (n+1) (insertEnv env' t) merged
              -- i.e., ∀ a, atom_eval M (insertEnv env' t) a ↔ merged a = true
              -- Key: insertEnv env' t k = insertEnv env t (skipFin j k) for all k
              have h_ie_eq : ∀ k : Fin (n + 1),
                  insertEnv env' t k = insertEnv env t (skipFin j k) := by
                intro ⟨kv, hkv⟩
                simp only [insertEnv, env']
                split
                · next h_lt =>
                  -- kv < n. env'(kv) = insertEnv env t (skipFin j ⟨kv, _⟩)
                  -- skipFin j ⟨kv, by omega⟩ and skipFin j ⟨kv, hkv⟩ are the same Fin value
                  -- because they have the same .val.
                  -- After insertEnv unfolds, we need:
                  -- if (skipFin j ⟨kv,_⟩).val < n+1 then env ⟨(skipFin j ⟨kv,_⟩).val,_⟩ else t
                  -- = if (skipFin j ⟨kv,hkv⟩).val < n+1 then env ⟨(skipFin j ⟨kv,hkv⟩).val,_⟩ else t
                  -- These are definitionally equal since the Fin values are the same.
                  rfl
                · next h_nlt =>
                  -- kv ≥ n, so kv = n.
                  have h_kv_n : kv = n := by omega
                  subst h_kv_n
                  -- LHS: t (since insertEnv env' t ⟨n, _⟩ = t when n ≥ n)
                  -- RHS: insertEnv env t (skipFin j ⟨n, hkv⟩)
                  -- skipFin j ⟨n, _⟩: since j.val ≤ n, ¬(n < j.val), so = ⟨n+1, _⟩
                  -- insertEnv env t ⟨n+1, _⟩: n+1 ≥ n+1, so = t
                  -- Goal: t = if (skipFin j ⟨kv,hkv⟩).val < kv+1 then env ... else t
                  -- skipFin j ⟨kv,_⟩: since j.val ≤ kv, ¬(kv < j.val), so = ⟨kv+1, _⟩
                  -- ⟨kv+1,_⟩.val = kv+1, and kv+1 < kv+1 is false, so else branch gives t
                  simp only [skipFin, show ¬(kv < j.val) from by omega]
                  simp [dif_neg (show ¬False from id), show ¬(kv + 1 < kv + 1) from by omega]
              intro a
              match a with
              | .pred p pos =>
                simp only [mergeNF, merged, atom_eval]
                rw [h_ie_eq pos]
                exact h_nf (.pred p (skipFin j pos))
              | .order pos₁ pos₂ h_ne_pos =>
                simp only [mergeNF, merged, atom_eval]
                rw [h_ie_eq pos₁, h_ie_eq pos₂]
                exact h_nf (.order (skipFin j pos₁) (skipFin j pos₂)
                  (skipFin_injective j |>.ne h_ne_pos))⟩
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
