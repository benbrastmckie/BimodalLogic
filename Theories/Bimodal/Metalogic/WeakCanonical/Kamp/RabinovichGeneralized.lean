import Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichTranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.RabinovichNegation

/-!
# Generalized P_n(k) Mutual Induction (Rabinovich 2014 Section 5)

The main remaining sorry in the Kamp theorem pipeline is
`nf_2var_exist_formula_prior` at depth k+1 (NfCharFormula.lean).
Its backward direction requires characterizing 3-var existentials
temporally, which requires 4-var existentials at lower depth, etc.

## Architecture

The proof proceeds by mutual induction on k (depth):

### CharPart(k)
Every arity-1 depth-k NF has a temporal characteristic formula.
- k=0: `nf_depth0_char_formula` (atom literals)
- k+1: from CharPart(k) + ExistPart(k) via
  `nf_characterizable_temporal_prior_classical`

### ExistPart(k)
For ALL n >= 1 and all (n+1)-var depth-k NFs, the existential
is temporally characterizable on Prior structures.
- k=0: depth-0 NFs are purely atomic; proved for n=1, sorry for n>=2
- k+1: requires ExistPart(k) at arity n+1 for quantifier conditions

### Dependency Chain
```
CharPart(0)    <-- nf_depth0_char_formula (sorry-free)
ExistPart(0)   <-- nf_2var_exist_formula_prior_neg (n=1, sorry-free)
                   + depth-0 multi-var (n>=2, sorry)
CharPart(k+1)  <-- CharPart(k) + ExistPart(k)
                   via nf_characterizable_temporal_prior_classical (sorry-free)
ExistPart(k+1) <-- CharPart(k+1) + ExistPart(k)
                   via arity-climbing + negation closure (sorry)
```

## Main Results

- `charPart_zero`: CharPart(0), sorry-free
- `charPart_succ`: CharPart(k+1) from CharPart(k) + ExistPart(k), sorry-free
- `existPart_zero`: ExistPart(0), sorry-free at n=1, sorry at n>=2
- `existPart_succ`: ExistPart(k+1), sorry
- `kamp_mutual_induction`: combined ∀ k, CharPart(k) ∧ ExistPart(k)
- `nf_2var_exist_formula_prior_filled`: fills nf_2var_exist_formula_prior

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 4-5
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Depth-0 n-var to 2-var reduction

When the base environment is constant `(fun _ => t)`, the (n+1)-var existential
at depth 0 reduces to the 2-var existential, provided the sub_nf is compatible
with all base variables being equal. We prove this via a forward projection
(n-var witness → 2-var witness) and a backward reconstruction
(2-var witness → n-var witness, given consistency from a satisfiability witness). -/

/-- Forward: any (n+1)-var depth-0 witness projects to a 2-var witness. -/
private theorem depth0_nvar_forward_2var {sig : MonadicSignature}
    {n'' : Nat} (sub_nf : NormalForm sig 0 (n'' + 3))
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf_2 : NormalForm sig 0 2)
    (h_snf2_pred0 : ∀ p, sub_nf_2 (.pred p ⟨0, by omega⟩) = sub_nf (.pred p ⟨0, by omega⟩))
    (h_snf2_pred1 : ∀ p, sub_nf_2 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (h_snf2_ord01 : sub_nf_2 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
        sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))))
    (h_snf2_ord10 : sub_nf_2 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
        sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))))
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_nvar : nf_eval_nf M 0 (n'' + 2 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf_2 := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    have h := h_nvar (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [h_snf2_pred0]; exact h
  | .pred p ⟨1, _⟩ =>
    have h := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [h_snf2_pred1]; exact h
  | .pred _ ⟨n + 2, h⟩ => exact absurd h (by omega)
  | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
    have h := h_nvar (.order ⟨0, by omega⟩ ⟨1, by omega⟩
      (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [h_snf2_ord01]; exact h
  | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
    have h := h_nvar (.order ⟨1, by omega⟩ ⟨0, by omega⟩
      (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [h_snf2_ord10]; exact h
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
  | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
  | .order ⟨0, _⟩ ⟨_ + 2, h⟩ _ => exact absurd h (by omega)
  | .order ⟨1, _⟩ ⟨_ + 2, h⟩ _ => exact absurd h (by omega)
  | .order ⟨_ + 2, h⟩ _ _ => exact absurd h (by omega)

/-- Backward: a 2-var depth-0 witness reconstructs to an (n+1)-var witness,
    given consistency conditions extracted from a satisfiability witness. -/
private theorem depth0_2var_backward_nvar {sig : MonadicSignature}
    {n'' : Nat} (sub_nf : NormalForm sig 0 (n'' + 3))
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf_2 : NormalForm sig 0 2)
    (h_snf2_pred0 : ∀ p, sub_nf_2 (.pred p ⟨0, by omega⟩) = sub_nf (.pred p ⟨0, by omega⟩))
    (h_snf2_ord01 : sub_nf_2 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
        sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))))
    (h_snf2_ord10 : sub_nf_2 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
        sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))))
    -- Consistency conditions (from h_sat)
    (hC1 : ∀ p i, sub_nf (.pred p ⟨i + 1, by omega⟩) =
        sub_nf (.pred p ⟨1, by omega⟩))
    (hC1' : ∀ p, sub_nf (.pred p ⟨1, by omega⟩) =
        parent_atoms (.pred p ⟨0, by omega⟩))
    (hC2 : ∀ (i j : Nat) (hi : i + 1 < n'' + 3) (hj : j + 1 < n'' + 3),
        i ≠ j → sub_nf (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩
          (by intro heq; exact ‹i ≠ j› (by omega))) = false)
    (hC3 : ∀ (i : Nat) (hi : i + 1 < n'' + 3),
        sub_nf (.order ⟨0, by omega⟩ ⟨i + 1, hi⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) =
        sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))))
    (hC4 : ∀ (i : Nat) (hi : i + 1 < n'' + 3),
        sub_nf (.order ⟨i + 1, hi⟩ ⟨0, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) =
        sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩
          (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))))
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_2var : nf_eval_nf M 0 2 (Fin.cons x (fun _ => t)) sub_nf_2) :
    nf_eval_nf M 0 (n'' + 2 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    have h := h_2var (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [← h_snf2_pred0]; exact h
  | .pred p ⟨i + 1, hi⟩ =>
    have h := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [hC1 p i, hC1' p]; exact h
  | .order ⟨0, _⟩ ⟨j + 1, hj⟩ _ =>
    have h := h_2var (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [hC3 j hj, ← h_snf2_ord01]; exact h
  | .order ⟨i + 1, hi⟩ ⟨0, _⟩ _ =>
    have h := h_2var (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h ⊢
    rw [hC4 i hi, ← h_snf2_ord10]; exact h
  | .order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h_neq =>
    have hij : i ≠ j := by intro heq; exact h_neq (Fin.ext (by omega))
    simp only [atom_eval, Fin.cons]
    rw [hC2 i j hi hj hij]
    constructor
    · intro h; exact absurd h (lt_irrefl t)
    · intro h; exact Bool.noConfusion h
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h

/-! ## Part Definitions -/

/-- CharPart(k): every arity-1 depth-k NF has a temporal characteristic formula
    correct on Prior structures. -/
abbrev CharPart {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (k : Nat) : Prop :=
  ∀ (nf : NormalForm sig k 1),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf

/-- ExistPart(k): for all n >= 1 and all (n+1)-var depth-k NFs, there exists
    a temporal formula characterizing the existential on Prior structures. -/
abbrev ExistPart {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) : Prop :=
  ∀ (n : Nat) (_ : n ≥ 1)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k (n + 1)),
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M k (n + 1) (Fin.cons x (fun _ => t)) sub_nf)

/-! ## CharPart: Base and Step -/

/-- CharPart(0): depth-0 characteristic formulas are atom literal conjunctions.
    Sorry-free. -/
theorem charPart_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    CharPart atomMap 0 := by
  intro nf
  exact ⟨nf_depth0_char_formula atomMap h_surj nf,
    fun M _ _ t => by
      rw [nf_depth0_char_formula_correct]
      constructor
      · intro h_preds a
        match a with
        | .pred p i =>
          have : i = ⟨0, by omega⟩ := Fin.ext (by omega)
          subst this; simp only [atom_eval]; exact h_preds p
        | .order i j h =>
          have hi : i = ⟨0, by omega⟩ := Fin.ext (by omega)
          have hj : j = ⟨0, by omega⟩ := Fin.ext (by omega)
          subst hi; subst hj; exact absurd rfl h
      · intro h_atoms p
        have h := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h⟩

/-- CharPart(k+1) from CharPart(k) + ExistPart(k).
    Sorry-free; delegates to nf_characterizable_temporal_prior_classical. -/
theorem charPart_succ {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (ih_char : CharPart atomMap k)
    (ih_exist : ExistPart atomMap h_surj k) :
    CharPart atomMap (k + 1) := by
  intro nf
  -- Extract depth-k characteristic formulas from ih_char
  let char_k : NormalForm sig k 1 → Formula :=
    fun nf_k => Classical.choose (ih_char nf_k)
  have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (char_k nf_k) ↔
      nf_eval_nf M k 1 (fun _ => t) nf_k :=
    fun nf_k => Classical.choose_spec (ih_char nf_k)
  -- Apply nf_characterizable_temporal_prior_classical
  exact nf_characterizable_temporal_prior_classical atomMap h_surj k
    (fun nf_k => ⟨char_k nf_k, char_k_correct nf_k⟩) nf

/-! ## ExistPart: Base Case

At depth 0, NFs are purely atomic. The n=1 case (2-variable) is
proved by nf_2var_exist_formula_prior_neg. For n >= 2, the same
structural argument applies but requires more case analysis on
order constraints (sorry for now). -/

/-- ExistPart(0): the existential is characterizable at depth 0.
    Sorry-free at n=1. At n >= 2, the satisfiable case is sorry
    (Fin bookkeeping for the n-var to 2-var reduction).
    The unsatisfiable case is sorry-free. -/
theorem existPart_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p) :
    ExistPart atomMap h_surj 0 := by
  intro n hn char_0 char_0_correct parent_atoms sub_nf
  cases n with
  | zero => omega
  | succ n' =>
    cases n' with
    | zero =>
      -- n=1, arity=2: the standard 2-var case.
      -- Delegates to the sorry-free nf_2var_exist_formula_prior_neg at k=0.
      exact nf_2var_exist_formula_prior_neg atomMap h_surj 0
        char_0 char_0_correct parent_atoms sub_nf
    | succ n'' =>
      -- n >= 2, arity >= 3: higher-arity depth-0 case.
      -- At depth 0, sub_nf : AtomKind sig (n''+3) -> Bool
      -- The existential ∃ x, nf_eval_nf M 0 (n''+3) (Fin.cons x (fun _ => t)) sub_nf
      -- means: ∃ x with right predicates and order relative to t.
      -- Since all base variables map to t, the n-var existential
      -- is equivalent to the 2-var existential (with a projection)
      -- whenever the NF is consistent with all base vars being equal.
      -- If inconsistent, no witness exists and formula is ⊥.
      --
      -- We use Classical.choice: either ∃ x works on SOME structure,
      -- or it never does. In the first case, the n-var NF projects
      -- to a consistent 2-var NF. In the second case, ⊥ works.
      --
      -- More precisely: the n-var existential with base (fun _ => t)
      -- is a first-order condition. By classical logic, there exists
      -- a formula (either the 2-var projection's formula or ⊥) that
      -- characterizes it. We use this classical approach to avoid
      -- the tedious Fin case analysis.
      --
      -- Note: at depth 0, no Prior-UZ/SZ is needed (purely atomic).
      -- The formula works on ALL structures.
      --
      -- Approach: use nf_exist_formula at depth 0 for n=1 as the base,
      -- then classically choose between it and ⊥ for the n-var case.
      -- This is sound because the n-var existential with base (fun _ => t)
      -- is determined by sub_nf (a finite function on finite types).
      --
      -- Classical existence: for any decidable property on structures,
      -- there exists a formula (from {⊥, the 2-var formula}) that
      -- captures the existential.
      --
      -- Actually, the cleanest approach: define a 2-var NF that projects
      -- the (n+1)-var constraints down to 2 variables, then use
      -- nf_2var_exist_formula_prior_neg. The projection may produce
      -- an inconsistent NF (e.g., if some base vars require strict
      -- order among themselves), which nf_exist_formula handles by
      -- returning ⊥.
      --
      -- Define the projection:
      --   var 0 (x) stays
      --   var 1 = first base var (all base vars are t)
      --   predicates: sub_nf(.pred p 0) for x, parent_atoms(.pred p 0) for t
      --   order(0,1): sub_nf(.order 0 1)
      --   order(1,0): sub_nf(.order 1 0)
      let sub_nf_2 : NormalForm sig 0 2 := fun a => match a with
        | .pred p ⟨0, _⟩ => sub_nf (.pred p ⟨0, by omega⟩)
        | .pred p ⟨1, _⟩ => parent_atoms (.pred p ⟨0, by omega⟩)
        | .pred _ ⟨_ + 2, h⟩ => absurd h (by omega)
        | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
            sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩
              (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
        | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
            sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩
              (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
        | .order ⟨0, _⟩ ⟨0, _⟩ h => absurd rfl h
        | .order ⟨1, _⟩ ⟨1, _⟩ h => absurd rfl h
        | .order ⟨0, _⟩ ⟨_ + 2, h⟩ _ => absurd h (by omega)
        | .order ⟨1, _⟩ ⟨_ + 2, h⟩ _ => absurd h (by omega)
        | .order ⟨_ + 2, h⟩ _ _ => absurd h (by omega)
      -- Get the 2-var formula
      obtain ⟨A_2, hA2⟩ := nf_2var_exist_formula_prior_neg atomMap h_surj 0
        char_0 char_0_correct parent_atoms sub_nf_2
      -- Case split: is sub_nf compatible with parent_atoms?
      -- If yes (some witness exists on a structure satisfying parent_atoms),
      -- then sub_nf is consistent and the n-var existential ↔ 2-var existential.
      -- If no, the n-var existential is always false and ⊥ works.
      rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
          (t : M.carrier) (x : M.carrier),
          nf_eval_nf M 0 (n'' + 2 + 1) (Fin.cons x (fun _ => t)) sub_nf ∧
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
            parent_atoms a = true)) with ⟨M₀, t₀, x₀, h_eval₀, h_atoms₀⟩ | h_no_compat
      · -- sub_nf is satisfiable on a structure where parent_atoms holds.
        -- Extract all consistency conditions from this combined witness.
        -- C1: all base pred atoms agree with base var 1
        have hC1 : ∀ p (i : Nat), sub_nf (.pred p ⟨i + 1, by omega⟩) =
            sub_nf (.pred p ⟨1, by omega⟩) := by
          intro p i
          have h_i := h_eval₀ (.pred p ⟨i + 1, by omega⟩)
          have h_1 := h_eval₀ (.pred p ⟨1, by omega⟩)
          simp only [atom_eval, Fin.cons] at h_i h_1
          have key_i : M₀.interp p t₀ → sub_nf (.pred p ⟨i + 1, by omega⟩) = true :=
            fun h => h_i.mp h
          have key_1 : M₀.interp p t₀ → sub_nf (.pred p ⟨1, by omega⟩) = true :=
            fun h => h_1.mp h
          have key_i' : sub_nf (.pred p ⟨i + 1, by omega⟩) = true → M₀.interp p t₀ :=
            fun h => h_i.mpr h
          have key_1' : sub_nf (.pred p ⟨1, by omega⟩) = true → M₀.interp p t₀ :=
            fun h => h_1.mpr h
          cases hsub_i : sub_nf (.pred p ⟨i + 1, by omega⟩) <;>
          cases hsub_1 : sub_nf (.pred p ⟨1, by omega⟩)
          · rfl
          · exact absurd (key_1' hsub_1) (fun h => by simp [key_i h] at hsub_i)
          · exact absurd (key_i' hsub_i) (fun h => by simp [key_1 h] at hsub_1)
          · rfl
        -- C1': base var 1 pred matches parent_atoms
        have hC1' : ∀ p, sub_nf (.pred p ⟨1, by omega⟩) =
            parent_atoms (.pred p ⟨0, by omega⟩) := by
          intro p
          have h_1 := h_eval₀ (.pred p ⟨1, by omega⟩)
          have h_pa := h_atoms₀ (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h_1 h_pa
          -- Both iffs connect M₀.interp p t₀ to the respective Bool values
          have fwd_1 : M₀.interp p t₀ → sub_nf (.pred p ⟨1, by omega⟩) = true :=
            fun h => h_1.mp h
          have bwd_1 : sub_nf (.pred p ⟨1, by omega⟩) = true → M₀.interp p t₀ :=
            fun h => h_1.mpr h
          have fwd_pa : M₀.interp p t₀ → parent_atoms (.pred p ⟨0, by omega⟩) = true :=
            fun h => h_pa.mp h
          have bwd_pa : parent_atoms (.pred p ⟨0, by omega⟩) = true → M₀.interp p t₀ :=
            fun h => h_pa.mpr h
          cases hsub : sub_nf (.pred p ⟨1, by omega⟩) <;>
          cases hpa : parent_atoms (.pred p ⟨0, by omega⟩)
          · rfl
          · exact absurd (fwd_1 (bwd_pa hpa)) (by simp [hsub])
          · exact absurd (fwd_pa (bwd_1 hsub)) (by simp [hpa])
          · rfl
        -- C2: base-base orders are false
        have hC2 : ∀ (i j : Nat) (hi : i + 1 < n'' + 3) (hj : j + 1 < n'' + 3),
            i ≠ j → sub_nf (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩
              (by intro heq; exact ‹i ≠ j› (by omega))) = false := by
          intro i j hi hj hij
          have h_ord := h_eval₀ (.order ⟨i + 1, by omega⟩ ⟨j + 1, by omega⟩
            (by intro heq; exact hij (by omega)))
          simp only [atom_eval, Fin.cons] at h_ord
          cases hsub : sub_nf (.order ⟨i + 1, by omega⟩ ⟨j + 1, by omega⟩
            (by intro heq; exact hij (by omega)))
          · rfl
          · simp at h_ord; exact absurd hsub (by rw [h_ord]; exact Bool.noConfusion)
        -- C3: x-base orders agree
        have hC3 : ∀ (i : Nat) (hi : i + 1 < n'' + 3),
            sub_nf (.order ⟨0, by omega⟩ ⟨i + 1, hi⟩
              (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) =
            sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩
              (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) := by
          intro i hi
          have h_i := h_eval₀ (.order ⟨0, by omega⟩ ⟨i + 1, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
          have h_1 := h_eval₀ (.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
          simp only [atom_eval, Fin.cons] at h_i h_1
          cases hsub_i : sub_nf (.order ⟨0, by omega⟩ ⟨i + 1, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) <;>
          cases hsub_1 : sub_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) <;>
          simp_all
        -- C4: base-x orders agree
        have hC4 : ∀ (i : Nat) (hi : i + 1 < n'' + 3),
            sub_nf (.order ⟨i + 1, hi⟩ ⟨0, by omega⟩
              (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) =
            sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩
              (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) := by
          intro i hi
          have h_i := h_eval₀ (.order ⟨i + 1, by omega⟩ ⟨0, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
          have h_1 := h_eval₀ (.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega)))
          simp only [atom_eval, Fin.cons] at h_i h_1
          cases hsub_i : sub_nf (.order ⟨i + 1, by omega⟩ ⟨0, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) <;>
          cases hsub_1 : sub_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩
            (by intro h; exact absurd (Fin.ext_iff.mp h) (by omega))) <;>
          simp_all
        -- Now use A_2 as the formula
        refine ⟨A_2, fun M h_UZ h_SZ t h_atoms => ?_⟩
        rw [hA2 M h_UZ h_SZ t h_atoms]
        constructor
        · -- 2-var → n-var
          rintro ⟨x, h2⟩
          exact ⟨x, depth0_2var_backward_nvar sub_nf parent_atoms sub_nf_2
            (fun p => rfl) (by rfl) (by rfl)
            hC1 hC1' hC2 hC3 hC4 M x t h_atoms h2⟩
        · -- n-var → 2-var
          rintro ⟨x, hn⟩
          exact ⟨x, depth0_nvar_forward_2var sub_nf parent_atoms sub_nf_2
            (fun p => rfl) (fun p => rfl) (by rfl) (by rfl)
            M x t h_atoms hn⟩
      · -- No witness exists on any structure satisfying parent_atoms.
        -- The n-var existential is always false given h_atoms, so ⊥ works.
        refine ⟨Formula.bot, fun M _ _ t h_atoms => ?_⟩
        simp only [temporal_truth]
        constructor
        · intro h; exact absurd h id
        · rintro ⟨x, hx⟩
          exact absurd ⟨M, t, x, hx, h_atoms⟩ h_no_compat

/-! ## ExistPart: Step Case

The step case requires the negation closure argument from
Rabinovich Section 5. At depth k+1, the (n+1)-var NF has
quantifier conditions involving (n+2)-var depth-k NFs.
By ExistPart(k), these are temporally characterizable.

However, the current ExistPart statement uses base environment
`(fun _ => t)`, while the quantifier conditions involve base
`(Fin.cons x (fun _ => t))`. This mismatch is the core
mathematical obstacle.

Resolution requires either:
(a) Generalizing ExistPart to arbitrary base environments, or
(b) Using the Prior negation closure argument to show that
    temporal truth at t determines the quantifier conditions
    even though x differs from t.

Option (b) is Rabinovich's approach. -/

/-- ExistPart(k+1) from CharPart(k+1) + ExistPart(k).
    Sorry: requires negation closure (Rabinovich Section 5). -/
theorem existPart_succ {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (ih_char_succ : CharPart atomMap (k + 1))
    (ih_exist : ExistPart atomMap h_surj k) :
    ExistPart atomMap h_surj (k + 1) := by
  intro n hn char_kp1 char_kp1_correct parent_atoms sub_nf
  -- sub_nf : NormalForm sig (k+1) (n+1) = (AtomKind sig (n+1) -> Bool) x (NormalForm sig k (n+2) -> Bool)
  --
  -- Need: ∃ A, temporal_truth t A <-> ∃ x, nf_eval_nf M (k+1) (n+1) (Fin.cons x (fun _ => t)) sub_nf
  --
  -- The forward direction (∃ x -> formula truth) follows from
  -- nf_exist_formula_forward for n=1, or an analogous construction for n >= 1.
  --
  -- The backward direction (formula truth -> ∃ x) at depth k+1 requires:
  -- 1. Extract witness x from Until/Since semantics
  -- 2. Verify atom conditions at x (from the temporal formula holding at x)
  -- 3. Verify quantifier conditions: for each ssn : NormalForm sig k (n+2),
  --    ∃ y, nf_eval_nf M k (n+2) (Fin.cons y (Fin.cons x (fun _ => t))) ssn
  --    must match sub_nf.2 ssn.
  --
  -- Step 3 is the hard part. The environment for y is
  --   Fin.cons y (Fin.cons x (fun _ => t))
  -- which has base (Fin.cons x (fun _ => t)), not (fun _ => t).
  --
  -- ExistPart(k) at arity n+1 gives formulas for
  --   ∃ y, nf_eval_nf M k (n+2) (Fin.cons y (fun _ => t)) ssn
  -- (base = (fun _ => t)), NOT for the base we need.
  --
  -- The negation closure argument (Rabinovich Lemma 5.1) bridges this gap:
  -- On Prior structures, the temporal properties at t + the position of x
  -- relative to t determine the existential properties in the interval.
  -- This uses Prior-UZ/SZ to find first/last occurrences.
  sorry

/-! ## Combined Induction -/

/-- The combined mutual induction: CharPart(k) ∧ ExistPart(k) for all k.

    CharPart is sorry-free for all k (given ExistPart at lower depths).
    ExistPart is sorry-free at k=0 for n=1; sorry at k=0 for n>=2
    and sorry at k>=1 for all n. -/
theorem kamp_mutual_induction {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) :
    CharPart atomMap k ∧ ExistPart atomMap h_surj k := by
  induction k with
  | zero => exact ⟨charPart_zero atomMap h_surj, existPart_zero atomMap h_surj⟩
  | succ k' ih =>
    have ih_char := ih.1
    have ih_exist := ih.2
    have char_succ := charPart_succ atomMap h_surj k' ih_char ih_exist
    have exist_succ := existPart_succ atomMap h_surj k' char_succ ih_exist
    exact ⟨char_succ, exist_succ⟩

/-! ## Filling the Original Sorry -/

/-- Fills the sorry in `nf_2var_exist_formula_prior` (NfCharFormula.lean).
    Extracts ExistPart(k) at n=1 from the combined induction. -/
theorem nf_2var_exist_formula_prior_filled
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
         ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
  (kamp_mutual_induction atomMap h_surj k).2 1 (by omega)
    char_k char_k_correct parent_atoms sub_nf

end Bimodal.Metalogic.WeakCanonical.Kamp
