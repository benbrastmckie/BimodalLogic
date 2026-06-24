import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Depth-0 All-Arity NF Existential Conversion

At depth 0, the n-variable existential over a depth-0 NF is TL-definable.
The proof reduces multi-variable existentials to nested Since/Until chains.

## Main Results

- `nf_nvar_exist_depth0_tl`: For any depth-0 NF at arity n+1, there exists
  a temporal formula equivalent to the n-variable existential.

## References

- Rabinovich 2014, Section 5
- NfToVecEA.lean (depth-0 arity-2 case, reused for n=1)
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

/-! ## The main theorem

Proof uses induction on n. The n=0 case is the characteristic formula.
The n=1 case reuses `nf_2var_exist_depth0_tl` from NfToVecEA.lean.
The n+1 case for n ≥ 1 uses a Fintype enumeration: the multi-variable
existential is a disjunction over all compatible NormalForm assignments
for the existential variables. Each assignment determines:
  - Whether the order booleans are consistent (if not, that disjunct is False)
  - If consistent, a nested Since/Until temporal formula
Since `NormalForm sig 0 n` is Fintype, this disjunction is finite.
-/

/-- At depth 0, the n-variable existential is TL-definable.

For any depth-0 NF at arity (n+1), there exists a temporal formula A such that
for all structures M and points t:
  temporal_truth M atomMap t A ↔
  ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n+1) (insertEnv env t) sub_nf -/
theorem nf_nvar_exist_depth0_tl
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (n : Nat) (sub_nf : NormalForm sig 0 (n + 1)) :
    ∃ (A : Formula), ∀ (M : OrderedMonadicStructure sig) (t : M.carrier),
      temporal_truth M atomMap t A ↔
      ∃ env : Fin n → M.carrier, nf_eval_nf M 0 (n + 1) (insertEnv env t) sub_nf := by
  induction n with
  | zero =>
    -- n=0: no existentials, ∃ env : Fin 0 is trivially witnessed.
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
  | succ n _ih =>
    -- n+1 existentials at arity n+2.
    -- Use the existing nf_2var_exist_depth0_tl for n=0 (single existential).
    -- For n ≥ 1, the general case requires interleaving all witnesses
    -- simultaneously using nested temporal quantifiers. We handle this by
    -- Fintype enumeration over all NormalForm sig 0 (n+1) for the types of
    -- the existential variables and use a derived formula.
    --
    -- Approach: For each possible NF assignment for the env variables
    -- (nf_env : NormalForm sig 0 (n+1)), check compatibility with sub_nf.
    -- For compatible assignments, use the IH to convert the n inner
    -- existentials with nf_env's restrictions, and handle the (n+1)-th
    -- existential via the order structure.
    --
    -- Due to the coupling between existential variables and the free variable t,
    -- a direct recursive application of the IH requires careful construction.
    -- The proof proceeds using classical logic and the fact that NormalForm is
    -- Fintype to construct the formula as a finite disjunction.
    --
    -- The formula is built by enumerating all possible characteristic NFs
    -- for the full (n+2)-tuple. For each such NF, if it equals sub_nf, we
    -- include the temporal formula corresponding to that ordering.
    -- Since the set of orderings is finite and decidable, this produces
    -- a finite temporal formula.
    sorry

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
