/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfToVecEA
import FormalSystem.Metalogic.WeakCanonical.Kamp.Translation
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import FormalSystem.Metalogic.WeakCanonical.Separation.KampTranslation
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

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula
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
noncomputable def nfPredAtPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {arity : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 arity) (pos : Fin arity) : TemporalPred :=
  nfPred atomMap h_surj (fun a => match a with
    | .pred p _ => sub_nf (.pred p pos)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h)

/-- `nfPredAtPos` evaluates correctly. -/
theorem nfPredAtPos_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {arity : Nat}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 0 arity) (pos : Fin arity) (t : M.carrier) :
    (nfPredAtPos atomMap h_surj sub_nf pos).eval_at M atomMap t ↔
    ∀ p : sig.preds, M.interp p t ↔ (sub_nf (.pred p pos) = true) := by
  simp only [nfPredAtPos]
  -- `rw` can no longer match `nfPred_correct`'s pattern: the anonymous NF lambda has the
  -- unfolded `AtomKind sig 1 → Bool` type rather than `NormalForm sig 0 1`. Term-level
  -- `Iff.trans` unifies the two at default transparency.
  refine Iff.trans (nfPred_correct M atomMap h_surj _ t) ?_
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

theorem nf_depth0_pair_cycle_empty' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {m : Nat}
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
  split at h' <;> simp_all
  omega

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

/-- Total retraction of `skipFin skip`: sends the dropped position `skip` to the
    image-preimage of the twin `keep`, and every other position back via `unskipFin`. -/
def totalUnskip {m : Nat} (skip : Fin (m + 1)) (keep : Fin m) :
    Fin (m + 1) → Fin m :=
  fun pos => if h : pos = skip then keep else unskipFin skip pos h

/-- `totalUnskip` is a left inverse (retraction) of `skipFin`: `r ∘ f = id`. -/
theorem totalUnskip_skipFin {m : Nat} (skip : Fin (m + 1)) (keep : Fin m)
    (k : Fin m) : totalUnskip skip keep (skipFin skip k) = k := by
  simp only [totalUnskip, dif_neg (skipFin_ne skip k)]
  exact unskipFin_skipFin skip k

/-- Merge position `j` in a depth-0 NF by dropping it. -/
noncomputable def mergeNF {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {m : Nat}
    (sub_nf : NormalForm sig 0 (m + 1)) (j : Fin (m + 1))
    : NormalForm sig 0 m :=
  fun a => match a with
  | .pred p k => sub_nf (.pred p (skipFin j k))
  | .order k₁ k₂ h => sub_nf (.order (skipFin j k₁) (skipFin j k₂)
      (skipFin_injective j |>.ne h))

/-- Forward direction of merge: from merged NF satisfaction, build full satisfaction.
    Given env' satisfying mergeNF sub_nf j, construct env satisfying sub_nf
    by duplicating the value at position i at position j. -/
theorem merge_forward {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
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

/-! ## Index-map renaming of normal forms (depth-general infrastructure)

PRESERVED & REUSABLE — DO NOT REMOVE. Sorry-free/axiom-free assets landed during
the v35 Phase 1 pass. Consumed by Route A′ (the revised zone-split from the
Phase-0 regate decision): the `mpr` direction of `renameNF_eval_iff`
and the `mergeNF_succ`/`mergeNF_succ_atom` merge definition below are reused to
assemble the in-situ x=t collapse at `KampPrior.lean:391`. These look like generic
plumbing but are load-bearing for the live `completeness_discrete` chain.

`renameNF f r` precomposes a normal form's atom/quant layers with an index map.
`f : Fin b → Fin a` is the forward map (relating positions of the *result* arity `b`
to the *source* arity `a`), and `r : Fin a → Fin b` is a retraction used to descend
through the contravariant quantifier layer.

PROVEN SORRY-FREE/AXIOM-FREE during v35 Phase 1.

Strike history (H6 three-strike cap on the abstract `merge_forward_succ` leaf — all
conclusive-negative, which is WHY the project pivoted to Route A′ rather than abandoning):
  • Strike 1: plain NF-precomposition — insufficient.
  • Strike 2: retraction-functor `renameNF_eval_iff` — the full bidirectional form needs
    BOTH sections (`f ∘ r = id` AND `r ∘ f = id`, i.e. a bijective index map); the merge
    `skipFin j` is injective-not-surjective, so only the `mpr` half (needs just `r ∘ f = id`,
    which `skipFin`/`unskipFin` satisfy) survives — and that half is what Route A′ uses.
  • Strike 3: value-duplication — proved the *abstract* leaf is a non-theorem (its quant
    `←` direction would manufacture a model witness from arbitrary `Bool` data). This
    obstruction DISSOLVES in situ at `KampPrior.lean:391`, where the model supplies the
    witness — exactly why depth-0 `merge_forward` is true. Hence Route A′. -/

/-- Lift an index map over a freshly-bound (`Fin.cons`) variable at position 0. -/
def liftIdx {a b : Nat} (f : Fin a → Fin b) : Fin (a + 1) → Fin (b + 1) :=
  Fin.cases 0 (fun i => (f i).succ)

theorem liftIdx_zero {a b : Nat} (f : Fin a → Fin b) : liftIdx f 0 = 0 := by
  simp [liftIdx]

theorem liftIdx_succ {a b : Nat} (f : Fin a → Fin b) (i : Fin a) :
    liftIdx f i.succ = (f i).succ := by
  simp [liftIdx]

theorem cons_comp_liftIdx {a b : Nat} {α : Type*} (f : Fin b → Fin a)
    (E : Fin a → α) (e : Fin b → α) (x : α)
    (h : ∀ i, e i = E (f i)) :
    ∀ i : Fin (b + 1), (Fin.cons x e : Fin (b+1) → α) i
      = (Fin.cons x E : Fin (a+1) → α) (liftIdx f i) := by
  intro i
  refine Fin.cases ?_ ?_ i
  · simp [liftIdx_zero, Fin.cons_zero]
  · intro j
    rw [liftIdx_succ]
    simp [Fin.cons_succ, h]

theorem liftIdx_comp {a b c : Nat} (g : Fin a → Fin b) (h : Fin b → Fin c) :
    ∀ i, liftIdx h (liftIdx g i) = liftIdx (fun x => h (g x)) i := by
  intro i
  refine Fin.cases ?_ ?_ i
  · rw [liftIdx_zero, liftIdx_zero, liftIdx_zero]
  · intro j; rw [liftIdx_succ, liftIdx_succ, liftIdx_succ]

theorem liftIdx_id {a : Nat} (g : Fin a → Fin a) (hg : ∀ i, g i = i) :
    ∀ i, liftIdx g i = i := by
  intro i
  refine Fin.cases ?_ ?_ i
  · rw [liftIdx_zero]
  · intro j; rw [liftIdx_succ, hg]

/-- Precompose a normal form with an index map. On colliding order atoms
    (`f i = f j`) returns `false`, making precomposition total along non-injective `f`. -/
def renameNF {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    {k a b : Nat} → (f : Fin b → Fin a) → (r : Fin a → Fin b) →
      NormalForm sig k a → NormalForm sig k b
  | 0, _, _, f, _, nf => fun atom => match atom with
      | .pred p i => nf (.pred p (f i))
      | .order i j _ => if hf : f i = f j then false else nf (.order (f i) (f j) hf)
  | _ + 1, _, _, f, r, nf =>
      ((fun atom => match atom with
        | .pred p i => nf.1 (.pred p (f i))
        | .order i j _ => if hf : f i = f j then false else nf.1 (.order (f i) (f j) hf)),
       (fun qnf => nf.2 (renameNF (liftIdx r) (liftIdx f) qnf)))

theorem renameNF_roundtrip {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    ∀ {k a b : Nat} (f : Fin b → Fin a) (r : Fin a → Fin b)
      (_hsec : ∀ i, f (r i) = i) (_hsec2 : ∀ i, r (f i) = i)
      (nf : NormalForm sig k a),
      renameNF r f (renameNF f r nf) = nf := by
  intro k
  induction k with
  | zero =>
    intro a b f r hsec hsec2 nf
    funext atom
    match atom with
    | .pred p i =>
      simp only [renameNF]
      rw [hsec i]
    | .order i j hij =>
      simp only [renameNF]
      by_cases hr : r i = r j
      · exact absurd (by rw [← hsec i, ← hsec j]; exact congrArg f hr) hij
      · simp only [dif_neg hr]
        by_cases hf : f (r i) = f (r j)
        · exact absurd (by rw [← hsec i, ← hsec j]; exact hf) hij
        · simp only [dif_neg hf]
          rw [show (AtomKind.order (f (r i)) (f (r j)) hf : AtomKind sig a)
                = AtomKind.order i j hij from by congr 1; exacts [hsec i, hsec j]]
  | succ k ih =>
    intro a b f r hsec hsec2 nf
    obtain ⟨na, nq⟩ := nf
    apply Prod.ext
    · funext atom
      match atom with
      | .pred p i =>
        simp only [renameNF]
        rw [hsec i]
      | .order i j hij =>
        simp only [renameNF]
        by_cases hr : r i = r j
        · exact absurd (by rw [← hsec i, ← hsec j]; exact congrArg f hr) hij
        · simp only [dif_neg hr]
          by_cases hf : f (r i) = f (r j)
          · exact absurd (by rw [← hsec i, ← hsec j]; exact hf) hij
          · simp only [dif_neg hf]
            rw [show (AtomKind.order (f (r i)) (f (r j)) hf : AtomKind sig a)
                  = AtomKind.order i j hij from by congr 1; exacts [hsec i, hsec j]]
    · funext qnf
      simp only [renameNF]
      have hs1 : ∀ i, (liftIdx f) ((liftIdx r) i) = i := by
        intro i; refine Fin.cases ?_ ?_ i
        · rw [liftIdx_zero, liftIdx_zero]
        · intro j; rw [liftIdx_succ, liftIdx_succ, hsec j]
      have hs2 : ∀ i, (liftIdx r) ((liftIdx f) i) = i := by
        intro i; refine Fin.cases ?_ ?_ i
        · rw [liftIdx_zero, liftIdx_zero]
        · intro j; rw [liftIdx_succ, liftIdx_succ, hsec2 j]
      rw [ih (liftIdx f) (liftIdx r) hs1 hs2 qnf]

theorem renameNF_eval_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) :
    ∀ {k a b : Nat} (f : Fin b → Fin a) (r : Fin a → Fin b)
      (E : Fin a → M.carrier) (e : Fin b → M.carrier)
      (_hcomp : ∀ i, e i = E (f i))
      (_hcomp2 : ∀ i, E i = e (r i))
      (_hsec : ∀ i, f (r i) = i)
      (_hsec2 : ∀ i, r (f i) = i)
      (nf : NormalForm sig k a),
      nf_eval_nf M k b e (renameNF f r nf) ↔ nf_eval_nf M k a E nf := by
  intro k
  induction k with
  | zero =>
    intro a b f r E e hcomp hcomp2 hsec hsec2 nf
    constructor
    · intro hren atomA
      match atomA with
      | .pred p i =>
        have h := hren (.pred p (r i))
        simp only [renameNF, atom_eval] at h ⊢
        rw [hcomp2 i, h, hsec i]
      | .order i j hij =>
        have hrij : r i ≠ r j := by
          intro heq; exact hij (by rw [← hsec i, ← hsec j, heq])
        have h := hren (.order (r i) (r j) hrij)
        simp only [renameNF, atom_eval] at h ⊢
        rw [hcomp2 i, hcomp2 j]
        rw [dif_neg (show ¬ (f (r i) = f (r j)) from by rw [hsec i, hsec j]; exact hij)] at h
        rw [show (AtomKind.order (f (r i)) (f (r j))
              (by rw [hsec i, hsec j]; exact hij) : AtomKind sig a)
              = AtomKind.order i j hij from by congr 1; exacts [hsec i, hsec j]] at h
        exact h
    · intro hnf atom
      match atom with
      | .pred p i =>
        simp only [renameNF, atom_eval]
        rw [hcomp i]
        exact hnf (.pred p (f i))
      | .order i j hij =>
        simp only [renameNF, atom_eval]
        by_cases hf : f i = f j
        · simp only [hf, dif_pos]
          rw [hcomp i, hcomp j, hf]; simp
        · simp only [hf, dif_neg, not_false_iff]
          rw [hcomp i, hcomp j]
          exact hnf (.order (f i) (f j) hf)
  | succ k ih =>
    intro a b f r E e hcomp hcomp2 hsec hsec2 nf
    have hsec_lift : ∀ i, (liftIdx r) ((liftIdx f) i) = i := by
      intro i
      refine Fin.cases ?_ ?_ i
      · rw [liftIdx_zero, liftIdx_zero]
      · intro j
        rw [liftIdx_succ, liftIdx_succ, hsec2 j]
    have hsec2_lift : ∀ i, (liftIdx f) ((liftIdx r) i) = i := by
      intro i
      refine Fin.cases ?_ ?_ i
      · rw [liftIdx_zero, liftIdx_zero]
      · intro j
        rw [liftIdx_succ, liftIdx_succ, hsec j]
    have quant_iff : ∀ (qnf : NormalForm sig k (b + 1)),
        (∃ x, nf_eval_nf M k (b + 1) (Fin.cons x e) qnf) ↔
        (∃ x, nf_eval_nf M k (a + 1) (Fin.cons x E)
          (renameNF (liftIdx r) (liftIdx f) qnf)) := by
      intro qnf
      constructor
      · rintro ⟨x, hx⟩
        exact ⟨x, (ih (liftIdx r) (liftIdx f) (Fin.cons x e) (Fin.cons x E)
          (cons_comp_liftIdx r e E x hcomp2)
          (cons_comp_liftIdx f E e x hcomp) hsec_lift hsec2_lift qnf).mpr hx⟩
      · rintro ⟨x, hx⟩
        exact ⟨x, (ih (liftIdx r) (liftIdx f) (Fin.cons x e) (Fin.cons x E)
          (cons_comp_liftIdx r e E x hcomp2)
          (cons_comp_liftIdx f E e x hcomp) hsec_lift hsec2_lift qnf).mp hx⟩
    have atom_iff : (∀ atom : AtomKind sig b, atom_eval M e atom ↔ (renameNF f r nf).1 atom = true)
        ↔ (∀ atomA : AtomKind sig a, atom_eval M E atomA ↔ nf.1 atomA = true) := by
      constructor
      · intro hren atomA
        match atomA with
        | .pred p i =>
          have h := hren (.pred p (r i))
          simp only [renameNF, atom_eval] at h ⊢
          rw [hcomp2 i, h, hsec i]
        | .order i j hij =>
          have hrij : r i ≠ r j := by
            intro heq; exact hij (by rw [← hsec i, ← hsec j, heq])
          have h := hren (.order (r i) (r j) hrij)
          simp only [renameNF, atom_eval] at h ⊢
          rw [hcomp2 i, hcomp2 j]
          rw [dif_neg (show ¬ (f (r i) = f (r j)) from by rw [hsec i, hsec j]; exact hij)] at h
          rw [show (AtomKind.order (f (r i)) (f (r j))
                (by rw [hsec i, hsec j]; exact hij) : AtomKind sig a)
                = AtomKind.order i j hij from by congr 1; exacts [hsec i, hsec j]] at h
          exact h
      · intro hatom atom
        match atom with
        | .pred p i =>
          simp only [renameNF, atom_eval]
          rw [hcomp i]
          exact hatom (.pred p (f i))
        | .order i j hij =>
          simp only [renameNF, atom_eval]
          by_cases hf : f i = f j
          · simp only [hf, dif_pos]
            rw [hcomp i, hcomp j, hf]; simp
          · simp only [hf, dif_neg, not_false_iff]
            rw [hcomp i, hcomp j]
            exact hatom (.order (f i) (f j) hf)
    have hLHS : nf_eval_nf M (k + 1) b e (renameNF f r nf) ↔
        (∀ atom : AtomKind sig b, atom_eval M e atom ↔ (renameNF f r nf).1 atom = true) ∧
        (∀ qnf : NormalForm sig k (b + 1),
          (∃ x, nf_eval_nf M k (b + 1) (Fin.cons x e) qnf) ↔
            nf.2 (renameNF (liftIdx r) (liftIdx f) qnf) = true) := by
      rfl
    have hRHS : nf_eval_nf M (k + 1) a E nf ↔
        (∀ atomA : AtomKind sig a, atom_eval M E atomA ↔ nf.1 atomA = true) ∧
        (∀ qnf : NormalForm sig k (a + 1),
          (∃ x, nf_eval_nf M k (a + 1) (Fin.cons x E) qnf) ↔ nf.2 qnf = true) := by
      rfl
    rw [hLHS, hRHS]
    constructor
    · rintro ⟨ha, hq⟩
      refine ⟨atom_iff.mp ha, ?_⟩
      intro qnf
      have rt : renameNF (liftIdx r) (liftIdx f)
          (renameNF (liftIdx f) (liftIdx r) qnf) = qnf :=
        renameNF_roundtrip (liftIdx f) (liftIdx r) hsec2_lift hsec_lift qnf
      rw [← rt, ← quant_iff]
      exact hq _
    · rintro ⟨ha, hq⟩
      refine ⟨atom_iff.mpr ha, ?_⟩
      intro qnf
      rw [quant_iff qnf]
      exact hq (renameNF (liftIdx r) (liftIdx f) qnf)

/-! ## Value-duplication congruence for the (non-bijective) merge

The full bidirectional `renameNF_eval_iff` requires a BIJECTIVE index map. The merge map
`skipFin j` is injective-not-surjective, so it lacks `f ∘ r = id`. The following one-directional
congruence drops the missing `hsec` (`f ∘ r = id`) and keeps only `hsec2` (`r ∘ f = id`), at the
cost of demanding the env-level compatibility `hcomp2` (`E = e ∘ r`) to hold on ALL positions —
which, for the merge, the *duplicating* environment `full_val` satisfies precisely because it
lives in the compatible (duplicated) subspace where a bare bijection would not. -/

/-- Depth-`(k+1)` position merge: drop position `j` from an arity-`(n+2)` NF, with `i'` the
    reduced-arity twin (the kept position in `Fin (n+1)`). The atom layer precomposes with
    `skipFin j` (= depth-0 `mergeNF`); the quant layer precomposes the depth-`k` sub-NF with the
    lifted retraction `(skipFin j, totalUnskip j i')`.

    PRESERVED & REUSABLE (Route A′ — the revised zone-split from the Phase-0 regate decision):
    this definition + `mergeNF_succ_atom` are the directly-reused merge assets for the in-situ
    x=t collapse at `KampPrior.lean:391`. DO NOT REMOVE as "unused": the consumer lands in a
    later dispatch. -/
noncomputable def mergeNF_succ {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k n : Nat}
    (sub_nf : NormalForm sig (k + 1) (n + 2)) (j : Fin (n + 2)) (i' : Fin (n + 1))
    : NormalForm sig (k + 1) (n + 1) :=
  renameNF (skipFin j) (totalUnskip j i') sub_nf

/-- The atom layer of `mergeNF_succ` equals the depth-0 `mergeNF` of the atom layer. -/
theorem mergeNF_succ_atom {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k n : Nat}
    (sub_nf : NormalForm sig (k + 1) (n + 2)) (j : Fin (n + 2)) (i' : Fin (n + 1))
    (a : AtomKind sig (n + 1)) :
    (mergeNF_succ sub_nf j i').1 a = mergeNF (sub_nf.1) j a := by
  cases a with
  | pred p k => rfl
  | order k₁ k₂ h =>
    simp only [mergeNF_succ, renameNF, mergeNF]
    rw [dif_neg (skipFin_injective j |>.ne h)]

/-! ## Helper: buildRight_spec / buildLeft_spec with all-top beta from monotone points -/

/-- If pts is strictly monotone and alpha holds at each pts r,
    then buildRight_spec holds for chains starting from base. -/
private theorem buildRight_top_of_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (alpha : Fin (n + 2) → TemporalPred)
    (pts : Fin (n + 2) → M.carrier)
    (h_pts_mono : ∀ r₁ r₂ : Fin (n + 2), r₁.val < r₂.val → pts r₁ < pts r₂)
    (h_alpha_pts : ∀ r : Fin (n + 2), (alpha r).eval_at M atomMap (pts r))
    (m : Nat) (base_rank : Nat)
    (h_bound : base_rank + m ≤ n + 1) :
    buildRight_spec M atomMap
      ((List.finRange m).map fun i =>
        (alpha ⟨base_rank + 1 + i.val, by omega⟩, TemporalPred.top))
      TemporalPred.top (pts ⟨base_rank, by omega⟩) := by
  induction m generalizing base_rank with
  | zero =>
    simp only [List.finRange]
    intro s _; exact temporal_truth_top M atomMap s
  | succ m ih =>
    -- The mapped list has the form (head :: tail)
    have h_list : (List.finRange (m + 1)).map (fun i =>
        (alpha ⟨base_rank + 1 + i.val, by omega⟩, TemporalPred.top)) =
      (alpha ⟨base_rank + 1, by omega⟩, TemporalPred.top) ::
      (List.finRange m).map (fun i =>
        (alpha ⟨base_rank + 2 + i.val, by omega⟩, TemporalPred.top)) := by
      rw [List.finRange_succ]
      simp only [List.map_cons, List.map_map, Function.comp_def, Fin.val_zero, Nat.add_zero]
      congr 1
      apply List.map_congr_left
      intro i _; congr 1; congr 1; simp [Fin.val_succ]; omega
    rw [h_list, buildRight_spec]
    have h_br1 : base_rank < n + 2 := by omega
    have h_br2 : base_rank + 1 < n + 2 := by omega
    have h_ih_bound : base_rank + 1 + m ≤ n + 1 := by omega
    refine ⟨pts ⟨base_rank + 1, h_br2⟩, ?_, ?_, ?_, ?_⟩
    · exact h_pts_mono _ _ (by simp)
    · exact h_alpha_pts ⟨base_rank + 1, h_br2⟩
    · exact fun r _ _ => temporal_truth_top M atomMap r
    · convert ih (base_rank + 1) h_ih_bound using 2

/-- Symmetric for buildLeft_spec. -/
private theorem buildLeft_top_of_mono {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (alpha : Fin (n + 2) → TemporalPred)
    (pts : Fin (n + 2) → M.carrier)
    (h_pts_mono : ∀ r₁ r₂ : Fin (n + 2), r₁.val < r₂.val → pts r₁ < pts r₂)
    (h_alpha_pts : ∀ r : Fin (n + 2), (alpha r).eval_at M atomMap (pts r))
    (m : Nat) (base_rank : Nat)
    (h_base : base_rank ≤ n + 1)
    (h_bound : m ≤ base_rank) :
    buildLeft_spec M atomMap
      ((List.finRange m).map fun i =>
        (alpha ⟨base_rank - 1 - i.val, by omega⟩, TemporalPred.top))
      TemporalPred.top (pts ⟨base_rank, by omega⟩) := by
  induction m generalizing base_rank with
  | zero =>
    simp only [List.finRange]
    intro s _; exact temporal_truth_top M atomMap s
  | succ m ih =>
    have h_list : (List.finRange (m + 1)).map (fun i =>
        (alpha ⟨base_rank - 1 - i.val, by omega⟩, TemporalPred.top)) =
      (alpha ⟨base_rank - 1, by omega⟩, TemporalPred.top) ::
      (List.finRange m).map (fun i =>
        (alpha ⟨base_rank - 2 - i.val, by omega⟩, TemporalPred.top)) := by
      rw [List.finRange_succ]
      simp only [List.map_cons, List.map_map, Function.comp_def, Fin.val_zero, Nat.sub_zero]
      congr 1
      apply List.map_congr_left
      intro i _; congr 1; congr 1; simp [Fin.val_succ]; omega
    rw [h_list, buildLeft_spec]
    have h_br1 : base_rank - 1 < n + 2 := by omega
    have h_br2 : base_rank < n + 2 := by omega
    refine ⟨pts ⟨base_rank - 1, h_br1⟩, ?_, ?_, ?_, ?_⟩
    · apply h_pts_mono; change base_rank - 1 < base_rank; omega
    · exact h_alpha_pts ⟨base_rank - 1, h_br1⟩
    · exact fun r _ _ => temporal_truth_top M atomMap r
    · convert ih (base_rank - 1) (by omega) (by omega) using 2
      simp only [show base_rank - 2 = base_rank - 1 - 1 from by omega]

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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
        (atomMap : Formula → sig.preds)
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
  · push Not at h_pair
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
            by_contra h; push Not at h
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
                  simp
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
            push Not at h
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
                  -- = if (skipFin j ⟨kv,hkv⟩).val < n+1 then env ⟨(skipFin j ⟨kv,hkv⟩).val,_⟩ else
                  -- t
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
                  simp
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
        push Not at h_compat
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
      push Not at h_has_eq
      -- Every pair has exactly one order boolean true.
      -- Check transitivity.
      by_cases h_trans : ∀ (a b c : Fin (n + 2))
          (h_ab : a ≠ b) (h_bc : b ≠ c) (h_ac : a ≠ c),
          sub_nf (.order a b h_ab) = true →
          sub_nf (.order b c h_bc) = true →
          sub_nf (.order a c h_ac) = true
      · -- Transitive strict total order. Use translateEF1.
        -- The NF determines exactly one direction for each pair.
        have h_exactly_one : ∀ (i j : Fin (n + 2)) (h : i ≠ j),
            (sub_nf (.order i j h) = true ∧ sub_nf (.order j i (Ne.symm h)) = false) ∨
            (sub_nf (.order i j h) = false ∧ sub_nf (.order j i (Ne.symm h)) = true) := by
          intro i j h_ne
          cases h_ij : sub_nf (.order i j h_ne) with
          | false =>
            right
            refine ⟨rfl, ?_⟩
            cases h_ji : sub_nf (.order j i (Ne.symm h_ne)) with
            | false => exact absurd h_ji (h_has_eq i j h_ne h_ij)
            | true => rfl
          | true =>
            left
            refine ⟨rfl, ?_⟩
            cases h_ji : sub_nf (.order j i (Ne.symm h_ne)) with
            | false => rfl
            | true => exact absurd h_ji (h_pair i j h_ne h_ij)
        -- Define rank: number of positions strictly before i in the NF order.
        -- Define the NF ordering as a Bool function for the rank filter
        -- NF order is proof-irrelevant: sub_nf (.order a b h1) = sub_nf (.order a b h2)
        have nf_order_irrel : ∀ (a b : Fin (n + 2)) (h1 h2 : a ≠ b),
            sub_nf (.order a b h1) = sub_nf (.order a b h2) := by
          intro a b h1 h2; congr 1
        -- Bool function for "j is strictly before i in NF order"
        let nf_lt_bool : Fin (n + 2) → Fin (n + 2) → Bool := fun j i =>
          if h : j = i then false
          else sub_nf (.order j i h)
        let nf_rank : Fin (n + 2) → Fin (n + 2) := fun i =>
          ⟨(Finset.univ.filter fun j => nf_lt_bool j i = true).card, by
            have h_sub := Finset.filter_subset (fun j => nf_lt_bool j i = true) Finset.univ
            have h_ssubset : Finset.univ.filter (fun j => nf_lt_bool j i = true) ⊂ Finset.univ := by
              rw [Finset.ssubset_iff_of_subset h_sub]
              exact ⟨i, Finset.mem_univ i, by simp [Finset.mem_filter, nf_lt_bool]⟩
            calc (Finset.univ.filter fun j => nf_lt_bool j i = true).card
                < Finset.univ.card := Finset.card_lt_card h_ssubset
              _ = Fintype.card (Fin (n + 2)) := rfl
              _ = n + 2 := Fintype.card_fin _⟩
        -- Proof-irrelevant acyclicity: for any proofs of inequality
        -- nf_lt_bool acyclicity: if nf_lt_bool i j = true then nf_lt_bool j i = false
        have h_lt_acyclic : ∀ (i j : Fin (n + 2)),
            nf_lt_bool i j = true → nf_lt_bool j i = false := by
          intro i j h_ij
          simp only [nf_lt_bool] at h_ij ⊢
          by_cases h_ij_eq : i = j
          · simp [h_ij_eq] at h_ij
          · simp only [h_ij_eq, ↓reduceDIte] at h_ij
            by_cases h_ji_eq : j = i
            · simp [h_ji_eq]
            · simp only [h_ji_eq, ↓reduceDIte]
              cases h_v : sub_nf (.order j i h_ji_eq) with
              | false => rfl
              | true =>
                exfalso
                have h_ji' : sub_nf (.order j i (Ne.symm h_ij_eq)) = true := by
                  rw [nf_order_irrel j i (Ne.symm h_ij_eq) h_ji_eq]; exact h_v
                exact h_pair i j h_ij_eq h_ij h_ji'
        -- Key property: rank is injective (hence bijective on Fin (n+2))
        have h_rank_inj : Function.Injective nf_rank := by
          intro a b h_eq
          by_contra h_ab
          have h_val_eq : (nf_rank a).val = (nf_rank b).val := congr_arg Fin.val h_eq
          simp only [nf_rank] at h_val_eq
          -- Helper: nf_lt_bool membership characterization
          have mem_filter : ∀ (c x : Fin (n + 2)),
              (c ∈ Finset.univ.filter (fun j => nf_lt_bool j x)) ↔ nf_lt_bool c x = true := by
            intro c x; simp [Finset.mem_filter]
          rcases h_exactly_one a b h_ab with ⟨h_ab_true, _⟩ | ⟨_, h_ba_true⟩
          · -- order(a,b) = true: rank(a) filter ⊊ rank(b) filter
            have h_sub : Finset.univ.filter (fun j => nf_lt_bool j a) ⊂
                Finset.univ.filter (fun j => nf_lt_bool j b) := by
              rw [Finset.ssubset_iff_of_subset]
              · refine ⟨a, ?_, ?_⟩
                · simp [nf_lt_bool, h_ab, h_ab_true]
                · simp [nf_lt_bool]
              · intro c hc
                simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hc ⊢
                simp only [nf_lt_bool] at hc ⊢
                by_cases h_ca : c = a
                · simp [h_ca] at hc
                · simp only [h_ca, ↓reduceDIte] at hc
                  by_cases h_cb : c = b
                  · -- c = b: nf_lt_bool c a = true, so nf_lt_bool a c should be false.
                    -- But nf_lt_bool a b = true (from h_ab_true), and c = b.
                    exfalso
                    -- nf_lt_bool a b = true
                    have h_lt_ab : nf_lt_bool a b = true := by
                      simp only [nf_lt_bool, h_ab, ↓reduceDIte]; exact h_ab_true
                    -- nf_lt_bool b a = false (acyclicity)
                    have h_lt_ba : nf_lt_bool b a = false := h_lt_acyclic a b h_lt_ab
                    -- nf_lt_bool c a = true (from hc, after dite reduction)
                    have h_lt_ca : nf_lt_bool c a = true := by
                      simp only [nf_lt_bool, h_ca, ↓reduceDIte]; exact hc
                    -- But c = b, so nf_lt_bool b a = true
                    rw [h_cb] at h_lt_ca
                    rw [h_lt_ba] at h_lt_ca
                    exact Bool.noConfusion h_lt_ca
                  · simp only [h_cb, ↓reduceDIte]
                    exact h_trans c a b h_ca h_ab h_cb hc h_ab_true
            exact absurd (Finset.card_lt_card h_sub) (by omega)
          · -- order(b,a) = true: symmetric
            have h_sub : Finset.univ.filter (fun j => nf_lt_bool j b) ⊂
                Finset.univ.filter (fun j => nf_lt_bool j a) := by
              rw [Finset.ssubset_iff_of_subset]
              · refine ⟨b, ?_, ?_⟩
                · simp [Finset.mem_filter, nf_lt_bool, Ne.symm h_ab, h_ba_true]
                · simp [Finset.mem_filter, nf_lt_bool]
              · intro c hc
                simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hc ⊢
                simp only [nf_lt_bool] at hc ⊢
                by_cases h_cb : c = b
                · simp [h_cb] at hc
                · simp only [h_cb, ↓reduceDIte] at hc
                  by_cases h_ca : c = a
                  · -- c = a: nf_lt_bool c b = true but nf_lt_bool a b = false (acyclicity)
                    exfalso
                    have h_lt_ba : nf_lt_bool b a = true := by
                      simp only [nf_lt_bool, Ne.symm h_ab, ↓reduceDIte]; exact h_ba_true
                    have h_lt_ab : nf_lt_bool a b = false := h_lt_acyclic b a h_lt_ba
                    have h_lt_cb : nf_lt_bool c b = true := by
                      simp only [nf_lt_bool, h_cb, ↓reduceDIte]; exact hc
                    rw [h_ca] at h_lt_cb
                    rw [h_lt_ab] at h_lt_cb
                    exact Bool.noConfusion h_lt_cb
                  · simp only [h_ca, ↓reduceDIte]
                    exact h_trans c b a h_cb (Ne.symm h_ab) h_ca hc h_ba_true
            exact absurd (Finset.card_lt_card h_sub) (by omega)
        -- rank is a bijection on Fin (n+2)
        have h_rank_surj : Function.Surjective nf_rank :=
          Finite.surjective_of_injective h_rank_inj
        have h_rank_bij : Function.Bijective nf_rank :=
          ⟨h_rank_inj, h_rank_surj⟩
        -- rank_inv: the inverse function
        let rank_inv : Fin (n + 2) → Fin (n + 2) :=
          Function.surjInv h_rank_surj
        have h_rank_inv : ∀ r, nf_rank (rank_inv r) = r :=
          Function.surjInv_eq h_rank_surj
        have h_inv_rank : ∀ i, rank_inv (nf_rank i) = i := by
          intro i; exact h_rank_inj (h_rank_inv (nf_rank i))
        -- rank preserves the NF order
        have h_rank_mono : ∀ (i j : Fin (n + 2)) (h : i ≠ j),
            sub_nf (.order i j h) = true → (nf_rank i).val < (nf_rank j).val := by
          intro i j h_ne h_ord
          simp only [nf_rank]
          apply Finset.card_lt_card
          rw [Finset.ssubset_iff_of_subset]
          · refine ⟨i, ?_, ?_⟩
            · simp [Finset.mem_filter, nf_lt_bool, h_ne, h_ord]
            · simp [Finset.mem_filter, nf_lt_bool]
          · intro c hc
            simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hc ⊢
            simp only [nf_lt_bool] at hc ⊢
            by_cases h_ci : c = i
            · simp [h_ci] at hc
            · simp only [h_ci, ↓reduceDIte] at hc
              by_cases h_cj : c = j
              · exfalso
                have h_lt_ij : nf_lt_bool i j = true := by
                  simp only [nf_lt_bool, h_ne, ↓reduceDIte]; exact h_ord
                have h_lt_ji : nf_lt_bool j i = false := h_lt_acyclic i j h_lt_ij
                have h_lt_ci : nf_lt_bool c i = true := by
                  simp only [nf_lt_bool, h_ci, ↓reduceDIte]; exact hc
                rw [h_cj] at h_lt_ci
                rw [h_lt_ji] at h_lt_ci
                exact Bool.noConfusion h_lt_ci
              · simp only [h_cj, ↓reduceDIte]
                exact h_trans c i j h_ci h_ne h_cj hc h_ord
        -- rank reflects the NF order
        have h_rank_reflect : ∀ (i j : Fin (n + 2)) (h : i ≠ j),
            (nf_rank i).val < (nf_rank j).val → sub_nf (.order i j h) = true := by
          intro i j h_ne h_lt
          rcases h_exactly_one i j h_ne with ⟨h_ij, _⟩ | ⟨_, h_ji⟩
          · exact h_ij
          · -- order(j,i) = true, so rank(j) < rank(i), contradicting h_lt
            have := h_rank_mono j i (Ne.symm h_ne) h_ji
            omega
        -- The free variable position
        let t_pos : Fin (n + 2) := ⟨n + 1, by omega⟩
        -- k = rank of the free variable within all n+2 positions
        -- We need k : Fin (n + 2) for translateEF1 (n+1) k
        -- translateEF1 takes n and Fin (n+1); here we use n+1 and Fin (n+2)
        -- Wait: translateEF1 n k has alpha : Fin (n+1) → TemporalPred
        -- We want n+2 positions total (n+1 existential + 1 free).
        -- So use translateEF1 (n+1) with Fin (n+2) alpha.
        -- But translateEF1 n k has alpha : Fin (n+1), so with n := n+1,
        -- alpha : Fin (n+2). YES, this matches.
        -- k : Fin (n+2) as Fin ((n+1)+1).
        let k : Fin (n + 2) := nf_rank t_pos
        -- alpha maps rank r to the predicate at position rank_inv r
        let alpha : Fin (n + 2) → TemporalPred := fun r =>
          nfPredAtPos atomMap h_surj sub_nf (rank_inv r)
        -- beta is all top (depth 0, no interval conditions)
        let beta : Fin (n + 3) → TemporalPred := fun _ => TemporalPred.top
        -- The formula
        let A := translateEF1 (n + 1) k alpha beta
        refine ⟨A, fun M t => ?_⟩
        -- Define pts : Fin (n+2) → M.carrier from a satisfying assignment
        -- (used in both directions)
        constructor
        · -- Forward: temporal formula → ∃ env satisfying NF
          intro h_tt
          rw [translateEF1_correct] at h_tt
          obtain ⟨h_alpha_k, h_right, h_left⟩ := h_tt
          -- Extract right witnesses from buildRight_spec
          -- We prove a general extraction lemma by induction on list length
          have h_extract_right : ∀ (m : Nat) (base : M.carrier)
              (pairs : List (TemporalPred × TemporalPred)) (rm : TemporalPred)
              (h_len : pairs.length = m)
              (h_spec : buildRight_spec M atomMap pairs rm base),
              ∃ ws : Fin m → M.carrier,
                (∀ i : Fin m, (pairs.get ⟨i.val, by omega⟩).1.eval_at M atomMap (ws i)) ∧
                (∀ i : Fin m, (if h : i.val = 0 then base else ws ⟨i.val - 1, by omega⟩) < ws
                    i) := by
            intro m
            induction m with
            | zero =>
              intro _ pairs _ h_len _
              exact ⟨Fin.elim0, fun i => absurd i.isLt (by omega),
                fun i => absurd i.isLt (by omega)⟩
            | succ m ih =>
              intro base pairs rm h_len h_spec
              match pairs, h_len with
              | (a_hd, b_hd) :: rest, h_len =>
                simp only [buildRight_spec] at h_spec
                obtain ⟨x, h_lt, h_alpha_x, _, h_rest⟩ := h_spec
                have h_rest_len : rest.length = m := by simp only
                    [List.length_cons, Nat.add_right_cancel_iff] at h_len; exact h_len
                obtain ⟨ws_rest, h_ws_alpha, h_ws_ord⟩ := ih x rest rm h_rest_len h_rest
                have h_mk_ws (j : Nat) (hj : j < m + 1) (h_pos : j ≠ 0) : j - 1 < m := by omega
                refine ⟨fun ⟨j, hj⟩ => if h : j = 0 then x else ws_rest ⟨j - 1, h_mk_ws j hj h⟩,
                    ?_, ?_⟩
                · intro ⟨i, hi⟩
                  dsimp only []
                  cases i with
                  | zero =>
                      simp only [List.length_cons, Fin.zero_eta, List.get_eq_getElem,
                          Fin.coe_ofNat_eq_mod, Nat.zero_mod, List.getElem_cons_zero, ↓reduceDIte];
                              exact h_alpha_x
                  | succ i =>
                    simp only [Nat.succ_ne_zero, ↓reduceDIte]
                    have := h_ws_alpha ⟨i, by omega⟩
                    convert this using 2
                    all_goals simp
                · intro ⟨i, hi⟩
                  dsimp only []
                  cases i with
                  | zero => simp only [↓reduceDIte, gt_iff_lt]; exact h_lt
                  | succ i =>
                    simp only [Nat.succ_ne_zero, ↓reduceDIte]
                    have := h_ws_ord ⟨i, by omega⟩
                    simp only at this
                    convert this using 2
                    all_goals (first | omega | congr 1)
          -- Extract left witnesses similarly
          have h_extract_left : ∀ (m : Nat) (base : M.carrier)
              (pairs : List (TemporalPred × TemporalPred)) (lm : TemporalPred)
              (h_len : pairs.length = m)
              (h_spec : buildLeft_spec M atomMap pairs lm base),
              ∃ ws : Fin m → M.carrier,
                (∀ i : Fin m, (pairs.get ⟨i.val, by omega⟩).1.eval_at M atomMap (ws i)) ∧
                (∀ i : Fin m, ws i < (if h : i.val = 0 then base else ws
                    ⟨i.val - 1, by omega⟩)) := by
            intro m
            induction m with
            | zero =>
              intro _ pairs _ h_len _
              exact ⟨Fin.elim0, fun i => absurd i.isLt (by omega),
                fun i => absurd i.isLt (by omega)⟩
            | succ m ih =>
              intro base pairs lm h_len h_spec
              match pairs, h_len with
              | (a_hd, b_hd) :: rest, h_len =>
                simp only [buildLeft_spec] at h_spec
                obtain ⟨x, h_lt, h_alpha_x, _, h_rest⟩ := h_spec
                have h_rest_len : rest.length = m := by simp only
                    [List.length_cons, Nat.add_right_cancel_iff] at h_len; exact h_len
                obtain ⟨ws_rest, h_ws_alpha, h_ws_ord⟩ := ih x rest lm h_rest_len h_rest
                have h_mk_ws (j : Nat) (hj : j < m + 1) (h_pos : j ≠ 0) : j - 1 < m := by omega
                refine ⟨fun ⟨j, hj⟩ => if h : j = 0 then x else ws_rest ⟨j - 1, h_mk_ws j hj h⟩,
                    ?_, ?_⟩
                · intro ⟨i, hi⟩
                  dsimp only []
                  cases i with
                  | zero =>
                      simp only [List.length_cons, Fin.zero_eta, List.get_eq_getElem,
                          Fin.coe_ofNat_eq_mod, Nat.zero_mod, List.getElem_cons_zero, ↓reduceDIte];
                              exact h_alpha_x
                  | succ i =>
                    simp only [Nat.succ_ne_zero, ↓reduceDIte]
                    have := h_ws_alpha ⟨i, by omega⟩
                    convert this using 2
                    all_goals simp
                · intro ⟨i, hi⟩
                  dsimp only []
                  cases i with
                  | zero => simp only [↓reduceDIte, gt_iff_lt]; exact h_lt
                  | succ i =>
                    simp only [Nat.succ_ne_zero, ↓reduceDIte]
                    have := h_ws_ord ⟨i, by omega⟩
                    simp only at this
                    convert this using 2
                    all_goals (first | omega | congr 1)
          -- Apply extraction to get right witnesses
          have h_right_len : ((List.finRange (n + 1 - k.val)).map fun i =>
              let idx := k.val + 1 + i.val
              (alpha ⟨idx, by omega⟩, beta ⟨idx, by omega⟩)).length = n + 1 - k.val := by
            simp [List.length_map, List.length_finRange]
          obtain ⟨right_ws, h_rw_alpha, h_rw_ord⟩ :=
            h_extract_right (n + 1 - k.val) t _ _ h_right_len h_right
          -- Apply extraction to get left witnesses
          have h_left_len : ((List.finRange k.val).map fun i =>
              let idx := k.val - 1 - i.val
              (alpha ⟨idx, by omega⟩, beta ⟨idx + 1, by omega⟩)).length = k.val := by
            simp [List.length_map, List.length_finRange]
          obtain ⟨left_ws, h_lw_alpha, h_lw_ord⟩ :=
            h_extract_left k.val t _ _ h_left_len h_left
          -- Now build pts : Fin (n+2) → M.carrier
          -- pts r = t if r = k
          -- pts r = right_ws ⟨r - k - 1, _⟩ if r > k
          -- pts r = left_ws ⟨k - 1 - r, _⟩ if r < k
          -- (left witnesses are in decreasing order of rank)
          let pts : Fin (n + 2) → M.carrier := fun r =>
            if h_eq : r = k then t
            else if h_gt : k.val < r.val then right_ws ⟨r.val - k.val - 1, by omega⟩
            else left_ws ⟨k.val - 1 - r.val, by omega⟩
          -- pts k = t
          have h_pts_k : pts k = t := by simp [pts]
          -- alpha holds at each pts r
          have h_pts_alpha : ∀ r : Fin (n + 2), (alpha r).eval_at M atomMap (pts r) := by
            intro r
            simp only [pts]
            split
            · next h_eq => subst h_eq; exact h_alpha_k
            · next h_ne =>
              split
              · next h_gt =>
                have := h_rw_alpha ⟨r.val - k.val - 1, by omega⟩
                simp only [Lean.Elab.WF.paramLet, List.get_eq_getElem, List.getElem_map,
                    List.getElem_finRange, Fin.cast_mk] at this
                convert this using 2
                · exact Fin.ext (by simp; omega)
              · next h_ngt =>
                have h_lt : r.val < k.val := by omega
                have := h_lw_alpha ⟨k.val - 1 - r.val, by omega⟩
                simp only [Lean.Elab.WF.paramLet, List.get_eq_getElem, List.getElem_map,
                    List.getElem_finRange, Fin.cast_mk] at this
                convert this using 2
                · exact Fin.ext (by simp; omega)
          -- Chain monotonicity helper: if each w_i < w_{i+1}, then w_i < w_j for i < j
          have chain_mono_right : ∀ (i j : Fin (n + 1 - k.val)),
              i.val < j.val → right_ws i < right_ws j := by
            intro i ⟨j_val, hj⟩ h_lt_ij
            induction j_val with
            | zero => simp at h_lt_ij
            | succ j' ih =>
              have h_step := h_rw_ord ⟨j' + 1, hj⟩
              simp only [
                dif_neg (Nat.succ_ne_zero j')] at h_step
              by_cases h_eq : i.val = j'
              · convert h_step using 1
                exact congrArg right_ws (Fin.ext h_eq)
              · have hj' : j' < n + 1 - k.val := by omega
                have h_jval : (⟨j' + 1, hj⟩ : Fin (n + 1 - k.val)).val = j' + 1 := rfl
                have h_ilt_nat : i.val < j' := by omega
                exact lt_trans (ih hj' h_ilt_nat) h_step
          have chain_mono_left : ∀ (i j : Fin k.val),
              i.val < j.val → left_ws j < left_ws i := by
            intro i ⟨j_val, hj⟩ h_lt_ij
            induction j_val with
            | zero => simp at h_lt_ij
            | succ j' ih =>
              have h_step := h_lw_ord ⟨j' + 1, hj⟩
              simp only [
                dif_neg (Nat.succ_ne_zero j')] at h_step
              by_cases h_eq : i.val = j'
              · convert h_step using 1
                exact congrArg left_ws (Fin.ext h_eq)
              · have hj' : j' < k.val := by omega
                have h_jval : (⟨j' + 1, hj⟩ : Fin k.val).val = j' + 1 := rfl
                have h_ilt_nat : i.val < j' := by omega
                exact lt_trans h_step (ih hj' h_ilt_nat)
          -- Right witnesses are all > t
          have h_rw_gt_t : ∀ i : Fin (n + 1 - k.val), t < right_ws i := by
            intro i
            have h_ne : n + 1 - k.val > 0 := Nat.pos_of_ne_zero
                (by intro h; exact absurd i.isLt (by omega))
            have h0 := h_rw_ord ⟨0, h_ne⟩
            simp only [dite_true] at h0
            rcases Nat.eq_or_lt_of_le (Nat.zero_le i.val) with h_eq | h_gt
            · convert h0 using 1; exact congrArg right_ws (Fin.ext h_eq.symm)
            · exact lt_trans h0 (chain_mono_right ⟨0, h_ne⟩ i h_gt)
          -- Left witnesses are all < t
          have h_lw_lt_t : ∀ i : Fin k.val, left_ws i < t := by
            intro i
            have h_ne : k.val > 0 := Nat.pos_of_ne_zero (by intro h; exact absurd i.isLt (by omega))
            have h0 := h_lw_ord ⟨0, h_ne⟩
            simp only [dite_true] at h0
            rcases Nat.eq_or_lt_of_le (Nat.zero_le i.val) with h_eq | h_gt
            · convert h0 using 1; exact congrArg left_ws (Fin.ext h_eq.symm)
            · exact lt_trans (chain_mono_left ⟨0, h_ne⟩ i h_gt) h0
          -- pts is strictly monotone
          have h_pts_mono : ∀ r₁ r₂ : Fin (n + 2), r₁.val < r₂.val → pts r₁ < pts r₂ := by
            intro r₁ r₂ h_lt_r
            simp only [pts]
            -- Case split on r₁ vs k and r₂ vs k
            split
            · next h_eq₁ =>
              -- r₁ = k: pts r₁ = t, and r₂ > k so pts r₂ = right_ws
              subst h_eq₁
              simp only [show ¬(r₂ = k) from by
                  intro h; exact absurd (congr_arg Fin.val h) (by omega),
                show k.val < r₂.val from by omega, ↓reduceDIte]
              exact h_rw_gt_t ⟨r₂.val - k.val - 1, by omega⟩
            · next h_ne₁ =>
              split
              · next h_gt₁ =>
                -- r₁ > k, r₂ > k: both right witnesses
                simp only [show ¬(r₂ = k) from by
                    intro h; exact absurd (congr_arg Fin.val h) (by omega),
                  show k.val < r₂.val from by omega, ↓reduceDIte]
                have hr₁ : r₁.val - k.val - 1 < n + 1 - k.val := by omega
                have hr₂ : r₂.val - k.val - 1 < n + 1 - k.val := by omega
                have hlt : r₁.val - k.val - 1 < r₂.val - k.val - 1 := by omega
                exact chain_mono_right ⟨r₁.val - k.val - 1, hr₁⟩
                  ⟨r₂.val - k.val - 1, hr₂⟩ hlt
              · next h_ngt₁ =>
                -- r₁ < k
                split
                · next h_eq₂ =>
                  -- r₂ = k: pts r₂ = t, pts r₁ = left_ws
                  subst h_eq₂
                  exact h_lw_lt_t ⟨k.val - 1 - r₁.val, by omega⟩
                · next h_ne₂ =>
                  split
                  · next h_gt₂ =>
                    -- r₁ < k < r₂: left_ws < t < right_ws
                    exact lt_trans (h_lw_lt_t ⟨k.val - 1 - r₁.val, by omega⟩)
                      (h_rw_gt_t ⟨r₂.val - k.val - 1, by omega⟩)
                  · next h_ngt₂ =>
                    -- Both < k: both left witnesses, opposite index order
                    have hr₂ : k.val - 1 - r₂.val < k.val := by omega
                    have hr₁ : k.val - 1 - r₁.val < k.val := by omega
                    have hlt : (k.val - 1 - r₂.val) < (k.val - 1 - r₁.val) := by omega
                    exact chain_mono_left ⟨k.val - 1 - r₂.val, hr₂⟩
                      ⟨k.val - 1 - r₁.val, hr₁⟩ hlt
          -- Build env from pts
          let env : Fin (n + 1) → M.carrier := fun i =>
            pts (nf_rank ⟨i.val, by omega⟩)
          refine ⟨env, fun a => ?_⟩
          match a with
          | .pred p pos =>
            simp only [atom_eval]
            have h_ie : insertEnv env t pos = pts (nf_rank pos) := by
              simp only [insertEnv, env]
              split
              · rfl
              · next h_nlt =>
                have : pos.val = n + 1 := by omega
                have h_pos_eq : pos = t_pos := Fin.ext this
                rw [h_pos_eq, show nf_rank t_pos = k from rfl, h_pts_k]
            rw [h_ie]
            have h_rinv : rank_inv (nf_rank pos) = pos := h_inv_rank pos
            have := h_pts_alpha (nf_rank pos)
            simp only [alpha, h_rinv] at this
            exact (nfPredAtPos_correct M atomMap h_surj sub_nf pos (pts (nf_rank pos))).mp this p
          | .order i j h_ne =>
            simp only [atom_eval]
            have h_ie_i : insertEnv env t i = pts (nf_rank i) := by
              simp only [insertEnv, env]
              split
              · rfl
              · next h_nlt =>
                have : i.val = n + 1 := by omega
                have h_pos_eq : i = t_pos := Fin.ext this
                rw [h_pos_eq, show nf_rank t_pos = k from rfl, h_pts_k]
            have h_ie_j : insertEnv env t j = pts (nf_rank j) := by
              simp only [insertEnv, env]
              split
              · rfl
              · next h_nlt =>
                have : j.val = n + 1 := by omega
                have h_pos_eq : j = t_pos := Fin.ext this
                rw [h_pos_eq, show nf_rank t_pos = k from rfl, h_pts_k]
            rw [h_ie_i, h_ie_j]
            constructor
            · intro h_lt_val
              exact h_rank_reflect i j h_ne (by
                have h_ne_rank := h_rank_inj.ne h_ne
                rcases Nat.lt_or_gt_of_ne (Fin.val_ne_of_ne h_ne_rank) with h | h
                · exact h
                · exact absurd (lt_trans h_lt_val (h_pts_mono (nf_rank j) (nf_rank i) h))
                    (lt_irrefl _))
            · intro h_ord
              exact h_pts_mono (nf_rank i) (nf_rank j) (h_rank_mono i j h_ne h_ord)
        · -- Backward: ∃ env satisfying NF → temporal formula
          intro ⟨env, h_nf⟩
          rw [translateEF1_correct]
          -- Define pts : Fin (n+2) → M.carrier from the satisfying assignment
          let pts : Fin (n + 2) → M.carrier := fun r =>
            insertEnv env t (rank_inv r)
          have h_pts_t : pts k = t := by
            simp only [pts, k]
            have : rank_inv (nf_rank t_pos) = t_pos := h_inv_rank t_pos
            rw [this]; exact insertEnv_last env t
          -- pts is strictly monotone (rank order = actual order)
          have h_pts_mono : ∀ r₁ r₂ : Fin (n + 2), r₁.val < r₂.val → pts r₁ < pts r₂ := by
            intro r₁ r₂ h_lt
            simp only [pts]
            have h_ne : rank_inv r₁ ≠ rank_inv r₂ := by
              intro h_eq
              have := congr_arg nf_rank h_eq
              rw [h_rank_inv, h_rank_inv] at this
              exact absurd (Fin.ext (congr_arg Fin.val this)) (Fin.ne_of_val_ne (by omega))
            have h_ord : sub_nf (.order (rank_inv r₁) (rank_inv r₂) h_ne) = true := by
              apply h_rank_reflect
              rw [h_rank_inv, h_rank_inv]
              exact h_lt
            have := (h_nf (.order (rank_inv r₁) (rank_inv r₂) h_ne)).mpr h_ord
            simp only [atom_eval] at this
            exact this
          -- alpha r holds at pts r
          have h_alpha_pts : ∀ r : Fin (n + 2), (alpha r).eval_at M atomMap (pts r) := by
            intro r
            simp only [alpha, pts]
            apply (nfPredAtPos_correct M atomMap h_surj sub_nf (rank_inv r)
              (insertEnv env t (rank_inv r))).mpr
            intro p
            have := h_nf (.pred p (rank_inv r))
            simp only [atom_eval] at this
            exact this
          refine ⟨?_, ?_, ?_⟩
          · -- alpha k holds at t
            have := h_alpha_pts k
            rw [h_pts_t] at this
            exact this
          · -- buildRight_spec: right chain
            -- General lemma: if pts is strictly monotone and alpha holds at each pts r,
            -- then buildRight_spec holds for any suffix with beta = top.
            suffices h_gen : ∀ (m : Nat) (base_rank : Nat)
                (h_bound : base_rank + m ≤ n + 1)
                (pairs : List (TemporalPred × TemporalPred))
                (h_pairs : pairs = (List.finRange m).map fun i =>
                  (alpha ⟨base_rank + 1 + i.val, by omega⟩,
                   TemporalPred.top)),
                buildRight_spec M atomMap pairs TemporalPred.top
                  (pts ⟨base_rank, by omega⟩) by
              convert h_gen (n + 1 - k.val) k.val (by omega) _ rfl using 2
              exact h_pts_t.symm
            intro m
            induction m with
            | zero =>
              intro base_rank _ pairs h_pairs
              subst h_pairs; simp only [List.finRange]
              intro s _
              simp only [TemporalPred.eval_at, TemporalPred.top]
              exact temporal_truth_top M atomMap s
            | succ m ih =>
              intro base_rank h_bound pairs h_pairs
              subst h_pairs
              rw [List.finRange_succ, List.map_cons, buildRight_spec]
              refine ⟨pts ⟨base_rank + 1, by omega⟩, ?_, ?_, ?_, ?_⟩
              · apply h_pts_mono; change base_rank < base_rank + 1; omega
              · simp only [Fin.coe_ofNat_eq_mod, Nat.zero_mod, add_zero]
                exact h_alpha_pts ⟨base_rank + 1, by omega⟩
              · intro r _ _
                simp only [TemporalPred.eval_at, TemporalPred.top]
                exact temporal_truth_top M atomMap r
              · have := ih (base_rank + 1) (by omega) _ rfl
                convert this using 1
                rw [List.map_map]
                apply List.map_congr_left
                intro i _
                simp only [Function.comp_def, Fin.val_succ]
                congr 1; congr 1
                apply Fin.ext; change base_rank + 1 + (i.val + 1) = base_rank + 1 + 1 + i.val; omega
          · -- buildLeft_spec: left chain
            suffices h_gen : ∀ (m : Nat) (base_rank : Nat)
                (h_base : base_rank ≤ n + 1)
                (h_bound : m ≤ base_rank)
                (pairs : List (TemporalPred × TemporalPred))
                (h_pairs : pairs = (List.finRange m).map fun i =>
                  (alpha ⟨base_rank - 1 - i.val, by omega⟩,
                   TemporalPred.top)),
                buildLeft_spec M atomMap pairs TemporalPred.top
                  (pts ⟨base_rank, by omega⟩) by
              convert h_gen k.val k.val (by omega) (by omega) _ rfl using 2
              exact h_pts_t.symm
            intro m
            induction m with
            | zero =>
              intro base_rank _ _ pairs h_pairs
              subst h_pairs; simp only [List.finRange]
              intro s _
              simp only [TemporalPred.eval_at, TemporalPred.top]
              exact temporal_truth_top M atomMap s
            | succ m ih =>
              intro base_rank h_base h_bound pairs h_pairs
              subst h_pairs
              rw [List.finRange_succ, List.map_cons, buildLeft_spec]
              refine ⟨pts ⟨base_rank - 1, by omega⟩, ?_, ?_, ?_, ?_⟩
              · apply h_pts_mono; change base_rank - 1 < base_rank; omega
              · simp only [Fin.coe_ofNat_eq_mod, Nat.zero_mod, tsub_zero]
                exact h_alpha_pts ⟨base_rank - 1, by omega⟩
              · intro r _ _
                simp only [TemporalPred.eval_at, TemporalPred.top]
                exact temporal_truth_top M atomMap r
              · have := ih (base_rank - 1) (by omega) (by omega) _ rfl
                convert this using 1
                rw [List.map_map]
                apply List.map_congr_left
                intro i _
                simp only [Function.comp_def, Fin.val_succ]
                congr 1; congr 1
                apply Fin.ext; change base_rank - 1 - (i.val + 1) = base_rank - 1 - 1 - i.val; omega
      · -- Non-transitive: find 3-cycle, existential is empty.
        push Not at h_trans
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
        (atomMap : Formula → sig.preds)
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
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
        (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1)) : Formula :=
  (nf_nvar_exist_depth0_tl atomMap h_surj n sub_nf).choose

/-- Correctness of the convenience wrapper. -/
theorem nf_nvar_exist_depth0_tl_fn_correct
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
        (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1))
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    temporal_truth M atomMap t (nf_nvar_exist_depth0_tl_fn atomMap h_surj n sub_nf) ↔
    ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf :=
  (nf_nvar_exist_depth0_tl atomMap h_surj n sub_nf).choose_spec M t

/-! ## Diagonal (value-duplication) congruence for the non-bijective merge

The full `renameNF_eval_iff` needs a *bijective* index map (both `f ∘ r = id` and `r ∘ f = id`).
The merge forward map `skipFin j` is injective-not-surjective, so `f ∘ r = id` (`hsec`) fails.
The lemmas below drop `hsec` and instead demand the *value-level* compatibilities `hcomp`
(`e = E ∘ f`) and `hcomp2` (`E = e ∘ r`) to hold on ALL positions — which the *duplicating*
(diagonal) environment satisfies precisely because it lives in the compatible subspace where a
bare bijection would not (see the NfDepth0Generalized:580-582 sketch). Together with the
retraction `hsec2` (`r ∘ f = id`, which `totalUnskip`/`skipFin` satisfy) and irreflexivity of
`M.lt`, this suffices for the atom layer at every depth. The evaluated NF is `renameNF r f nf`
(the *duplicated* form), so the backward atom transfer never needs the missing `hsec`. -/

/-- Depth-0 diagonal congruence: evaluating the duplicated atom layer `renameNF r f nf` on the
    compatible env `E` matches evaluating `nf` on `e`. Drops the `hsec` (`f ∘ r = id`) that the
    non-injective merge violates; uses only value compatibility + the retraction `hsec2`. -/
theorem renameNF_eval_diag0 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) {a b : Nat}
    (f : Fin b → Fin a) (r : Fin a → Fin b)
    (E : Fin a → M.carrier) (e : Fin b → M.carrier)
    (hcomp : ∀ i, e i = E (f i))
    (hcomp2 : ∀ i, E i = e (r i))
    (hsec2 : ∀ i, r (f i) = i)
    (nf : NormalForm sig 0 b) :
    nf_eval_nf M 0 a E (renameNF r f nf) ↔ nf_eval_nf M 0 b e nf := by
  simp only [nf_eval_nf]
  constructor
  · -- duplicated form on E  →  original on e
    intro hbig atom
    match atom with
    | .pred p k =>
      have h := hbig (.pred p (f k))
      simp only [renameNF, atom_eval] at h ⊢
      rw [hcomp k, h, hsec2 k]
    | .order k l hkl =>
      have hfkl : f k ≠ f l := by
        intro heq; exact hkl (by rw [← hsec2 k, ← hsec2 l, heq])
      have h := hbig (.order (f k) (f l) hfkl)
      simp only [renameNF, atom_eval] at h ⊢
      rw [hcomp k, hcomp l]
      rw [dif_neg (show ¬ (r (f k) = r (f l)) from by rw [hsec2 k, hsec2 l]; exact hkl)] at h
      rw [show (AtomKind.order (r (f k)) (r (f l))
            (by rw [hsec2 k, hsec2 l]; exact hkl) : AtomKind sig b)
            = AtomKind.order k l hkl from by congr 1; exacts [hsec2 k, hsec2 l]] at h
      exact h
  · -- original on e  →  duplicated form on E
    intro hnf atomA
    match atomA with
    | .pred p i =>
      simp only [renameNF, atom_eval]
      rw [hcomp2 i]
      exact hnf (.pred p (r i))
    | .order i j hij =>
      simp only [renameNF, atom_eval]
      by_cases hr : r i = r j
      · simp only [hr, dif_pos]
        rw [hcomp2 i, hcomp2 j, hr]; simp
      · simp only [hr, dif_neg, not_false_iff]
        rw [hcomp2 i, hcomp2 j]
        exact hnf (.order (r i) (r j) hr)

/-! ### Depth lift of the diagonal congruence is BLOCKED at the quant layer (Phase 10 divergence)

The depth-0 congruence `renameNF_eval_diag0` above does NOT lift to depth `K+1` as an
unconditional iff. Mirroring `renameNF_eval_iff`, after transferring the atom layer via
`renameNF_eval_diag0` the residual quant-layer obligation is (goal captured via `lean_goal`):

```
(∀ sub_nf : NormalForm sig K (a+1),
    (∃ x, nf_eval_nf M K (a+1) (Fin.cons x E) sub_nf) ↔ nq (renameNF (liftIdx f) (liftIdx r)
    sub_nf))
  ↔
(∀ sub_nf : NormalForm sig K (b+1),
    (∃ x, nf_eval_nf M K (b+1) (Fin.cons x e) sub_nf) ↔ nq sub_nf)
```

The `→` direction is provable (the round-trip
`renameNF (liftIdx f) (liftIdx r) (renameNF (liftIdx r) (liftIdx f) g) = g` holds because
`skipFin`/`liftIdx f` is *injective*, plus `IH`). The `←` direction is a genuine NON-theorem:
the LHS ranges over ALL `sub_nf : NormalForm sig K (a+1)`, but the collapse-then-expand
`renameNF (liftIdx r) (liftIdx f) (renameNF (liftIdx f) (liftIdx r) sub_nf)` does NOT recover
`sub_nf` because `liftIdx r` (= `liftIdx (totalUnskip …)`) is *non-injective*. Concretely, a
`sub_nf` that is not diagonal-invariant is unrealizable on the diagonal env `Fin.cons x E`
(so its `∃ x …` is false), yet `nq` of its collapse can be `true` — so the duplicated form
`renameNF r f nf` is generally NOT satisfied by `E` even when `nf` is satisfied by `e`.

This is exactly the realizability structure that Phase 11 (the depth-`k` two-anchor zone
converter / characteristic-NF machinery) is built to supply. The report-39 Phase-8a scoping
(x=t collapse "self-contained, before Phase 11") holds only at depth 0; at depth `k ≥ 1` the
x=t arm is NOT separable from the Phase-11 crux. See the Phase 10 blocker in
`plans/39_direct-nf-construction.md`. -/

/-! ## Shared arity-1 / quant-clause helpers (relocated from KampPrior, Phase 7)

These three small generic helpers were originally defined in `KampPrior.lean`. They are relocated
here — a module BOTH `KampPrior` and the multi-anchor bridge (`NfMultiAnchorBridge`, via
`NfZoneFlattenNavigable`) already import — so the bridge no longer needs to `import KampPrior`. This
breaks the import cycle that blocked wiring the bound-anchor converter into `KampPrior.lean:391`
. Both are unchanged; only their home module moved. -/

/-- For arity 1, there are no order atoms: every `AtomKind sig 1` is a pred atom. -/
theorem atomKind_arity1_is_pred {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (a : AtomKind sig 1) :
    ∃ (p : sig.preds), a = .pred p ⟨0, by omega⟩ := by
  match a with
  | .pred p i =>
    have : i = ⟨0, by omega⟩ := Fin.ext (by omega)
    subst this
    exact ⟨p, rfl⟩
  | .order i j h =>
    have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
    have hj : j = ⟨0, by omega⟩ := Fin.ext (by omega)
    subst hi; subst hj
    exact absurd rfl h

/-- Build the temporal formula for a single quantifier clause of a
    depth-(k+1) arity-1 NF: positive (existential) or negative (universal). -/
noncomputable def nf_quant_clause_tl
    (exist_tl : Formula)
    (is_positive : Bool) : Formula :=
  if is_positive then exist_tl
  else Formula.neg exist_tl

/-- Correctness of `nf_quant_clause_tl`. -/
theorem nf_quant_clause_tl_correct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (t : M.carrier)
    (exist_tl : Formula)
    (is_positive : Bool)
    (P : Prop)
    (h_exist : temporal_truth M atomMap t exist_tl ↔ P) :
    temporal_truth M atomMap t (nf_quant_clause_tl exist_tl is_positive) ↔
    (P ↔ (is_positive = true)) := by
  simp only [nf_quant_clause_tl]
  cases is_positive
  · simp only [ite_false, Bool.false_eq_true, iff_false]
    simp only [Formula.neg, temporal_truth]
    constructor
    · intro h hP; exact h (h_exist.mpr hP)
    · intro h htt; exact h (h_exist.mp htt)
  · simp only [ite_true, iff_true]
    exact h_exist

end FormalSystem.Metalogic.WeakCanonical.Kamp
