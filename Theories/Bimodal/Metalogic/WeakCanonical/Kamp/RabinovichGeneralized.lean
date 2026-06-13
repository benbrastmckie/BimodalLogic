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
- k=0: depth-0 NFs are purely atomic; proved for all n (sorry-free)
- k+1: requires ExistPart(k) at arity n+1 for quantifier conditions

### Dependency Chain
```
CharPart(0)    <-- nf_depth0_char_formula (sorry-free)
ExistPart(0)   <-- nf_2var_exist_formula_prior_neg (n=1, sorry-free)
                   + depth-0 multi-var (n>=2, sorry-free via bool_eq_of_iff_same)
CharPart(k+1)  <-- CharPart(k) + ExistPart(k)
                   via nf_characterizable_temporal_prior_classical (sorry-free)
ExistPart(k+1) <-- CharPart(k+1) + ExistPart(k)
                   via arity-climbing + negation closure (sorry)
```

## Main Results

- `charPart_zero`: CharPart(0), sorry-free
- `charPart_succ`: CharPart(k+1) from CharPart(k) + ExistPart(k), sorry-free
- `existPart_zero`: ExistPart(0), sorry-free for all n
- `existPart_succ`: ExistPart(k+1), sorry (factored: n=1 blocker + n>=2 depends on n=1)
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
with all base variables being equal. The proof is done inline in existPart_zero
using a Classical.em split on compatible satisfiability. -/

/-- Two bools that both encode the same proposition via `↔` must be equal. -/
private theorem bool_eq_of_iff_same {b₁ b₂ : Bool} {P : Prop}
    (h₁ : P ↔ b₁ = true) (h₂ : P ↔ b₂ = true) : b₁ = b₂ := by
  cases b₁ <;> cases b₂
  · rfl
  · exact h₁.mp (h₂.mpr rfl)
  · exact (h₂.mp (h₁.mpr rfl)).symm
  · rfl

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
proved by nf_2var_exist_formula_prior_neg. For n >= 2, the
satisfiable case uses bool_eq_of_iff_same to show n-var and 2-var
constraints agree via the M₀ witness; the unsatisfiable case uses ⊥. -/

/-- ExistPart(0): the existential is characterizable at depth 0.
    Sorry-free for all n. At n=1, delegates to nf_2var_exist_formula_prior_neg.
    At n >= 2, uses bool_eq_of_iff_same to equate n-var and 2-var existentials
    via the M₀ witness (satisfiable case) or ⊥ (unsatisfiable case). -/
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
      rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
          (t : M.carrier) (x : M.carrier),
          nf_eval_nf M 0 (n'' + 2 + 1) (Fin.cons x (fun _ => t)) sub_nf ∧
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
            parent_atoms a = true)) with ⟨M₀, t₀, x₀, h_eval₀, h_atoms₀⟩ | h_no_compat
      · -- Compatible: use A_2. Show the existentials are equivalent.
        refine ⟨A_2, fun M h_UZ h_SZ t h_atoms => ?_⟩
        rw [hA2 M h_UZ h_SZ t h_atoms]
        constructor
        · -- 2-var → n-var: given x satisfying 2-var, show it satisfies n-var
          rintro ⟨x, h2⟩
          refine ⟨x, fun a => ?_⟩
          match a with
          | .pred p ⟨0, _⟩ =>
            have := h2 (.pred p ⟨0, by omega⟩)
            simp only [atom_eval, Fin.cons] at this ⊢; exact this
          | .pred p ⟨i + 1, hi⟩ =>
            -- sub_nf(.pred p ⟨i+1,_⟩) = parent_atoms(.pred p ⟨0,_⟩)
            -- because the M₀ witness forces all base preds to agree.
            -- Key: Fin.cases x₀ (fun _ => t₀) ⟨i+1, _⟩ = t₀ definitionally,
            -- so h_i₀ and h_pa₀ both encode M₀.interp p t₀.
            have h_i₀ := h_eval₀ (.pred p ⟨i + 1, by omega⟩)
            have h_pa₀ := h_atoms₀ (.pred p ⟨0, by omega⟩)
            simp only [atom_eval, Fin.cons] at h_i₀ h_pa₀ ⊢
            have h_eq : sub_nf (.pred p ⟨i + 1, by omega⟩) =
                parent_atoms (.pred p ⟨0, by omega⟩) :=
              bool_eq_of_iff_same h_i₀ h_pa₀
            rw [h_eq]; exact h_atoms (.pred p ⟨0, by omega⟩)
          | .order ⟨0, _⟩ ⟨j + 1, hj⟩ _ =>
            -- sub_nf(.order 0 (j+1)) = sub_nf(.order 0 1) by M₀ witness.
            -- Both encode x₀ < t₀ (since Fin.cons at succ index = t₀).
            have h_j₀ := h_eval₀ (.order ⟨0, by omega⟩ ⟨j + 1, by omega⟩
              (by simp [Fin.ext_iff]))
            have h_1₀ := h_eval₀ (.order ⟨0, by omega⟩ ⟨1, by omega⟩
              (by simp [Fin.ext_iff]))
            simp only [atom_eval, Fin.cons] at h_j₀ h_1₀ ⊢
            have h_eq := bool_eq_of_iff_same h_j₀ h_1₀
            rw [h_eq]
            have := h2 (.order ⟨0, by omega⟩ ⟨1, by omega⟩
              (by simp [Fin.ext_iff]))
            simp only [atom_eval, Fin.cons] at this; exact this
          | .order ⟨i + 1, hi⟩ ⟨0, _⟩ _ =>
            -- Both encode t₀ < x₀ (Fin.cases at succ = t₀, at 0 = x₀).
            have h_i₀ := h_eval₀ (.order ⟨i + 1, by omega⟩ ⟨0, by omega⟩
              (by simp [Fin.ext_iff]))
            have h_1₀ := h_eval₀ (.order ⟨1, by omega⟩ ⟨0, by omega⟩
              (by simp [Fin.ext_iff]))
            simp only [atom_eval, Fin.cons] at h_i₀ h_1₀ ⊢
            have h_eq := bool_eq_of_iff_same h_i₀ h_1₀
            rw [h_eq]
            have := h2 (.order ⟨1, by omega⟩ ⟨0, by omega⟩
              (by simp [Fin.ext_iff]))
            simp only [atom_eval, Fin.cons] at this; exact this
          | .order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h_neq =>
            -- base-base order: t < t is False, sub_nf must be false
            have h_ord₀ := h_eval₀ (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h_neq)
            simp only [atom_eval, Fin.cons] at h_ord₀ ⊢
            constructor
            · intro h; exact False.elim (lt_irrefl t h)
            · intro hsub
              have : sub_nf (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h_neq) = false := by
                cases hv : sub_nf (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h_neq)
                · rfl
                · exact absurd (h_ord₀.mpr hv) (lt_irrefl t₀)
              rw [this] at hsub; exact Bool.noConfusion hsub
          | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
        · -- n-var → 2-var: project
          rintro ⟨x, hn⟩
          refine ⟨x, fun a => ?_⟩
          match a with
          | .pred p ⟨0, _⟩ =>
            have := hn (.pred p ⟨0, by omega⟩)
            simp only [atom_eval, Fin.cons] at this ⊢; exact this
          | .pred p ⟨1, _⟩ =>
            simp only [atom_eval, Fin.cons] at hn ⊢
            exact h_atoms (.pred p ⟨0, by omega⟩)
          | .pred _ ⟨n + 2, h⟩ => exact absurd h (by omega)
          | .order ⟨0, _⟩ ⟨1, _⟩ _ =>
            have := hn (.order ⟨0, by omega⟩ ⟨1, by omega⟩
              (by simp [Fin.ext_iff]))
            simp only [atom_eval, Fin.cons] at this ⊢; exact this
          | .order ⟨1, _⟩ ⟨0, _⟩ _ =>
            have := hn (.order ⟨1, by omega⟩ ⟨0, by omega⟩
              (by simp [Fin.ext_iff]))
            simp only [atom_eval, Fin.cons] at this ⊢; exact this
          | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
          | .order ⟨1, _⟩ ⟨1, _⟩ h => exact absurd rfl h
          | .order ⟨0, _⟩ ⟨_ + 2, h⟩ _ => exact absurd h (by omega)
          | .order ⟨1, _⟩ ⟨_ + 2, h⟩ _ => exact absurd h (by omega)
          | .order ⟨_ + 2, h⟩ _ _ => exact absurd h (by omega)
      · -- Incompatible: ⊥ works.
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
    Factored into two cases:
    - n=1 (arity 2): sorry -- the genuine mathematical blocker.
      Requires Rabinovich Section 5 negation closure to prove the backward
      direction of the 2-var existential at depth k+1.
    - n>=2 (arity >=3): sorry -- depends on n=1 case.
      Reduces to n=1 via 2-var projection (same constant-base argument as
      existPart_zero), but the quantifier part projection requires n=1
      at depth k+1 as a prerequisite. Once n=1 is filled, n>=2 follows
      by the Classical.em + bool_eq_of_iff_same pattern. -/
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
  -- Case split on n to separate the genuine blocker (n=1) from reducible cases (n>=2).
  cases n with
  | zero => omega
  | succ n' =>
    cases n' with
    | zero =>
      -- n=1, arity=2: the genuine mathematical blocker.
      -- At depth k+1 with 2 variables (x and t), the existential
      --   ∃ x, nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf
      -- requires both:
      --   (a) atom conditions on x and t (as at depth 0), AND
      --   (b) quantifier conditions: for each ssn : NormalForm sig k 3,
      --       (∃ y, nf_eval_nf M k 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn)
      --       ↔ sub_nf.2 ssn = true
      --
      -- The backward direction (formula truth → ∃ x) at depth k+1 requires
      -- the negation closure argument from Rabinovich Section 5.
      -- This is the same blocker as nf_2var_exist_formula_prior_neg at k+1.
      -- Filled in Phase 4.
      sorry
    | succ n'' =>
      -- n >= 2, arity >= 3: reduces to n=1 via 2-var projection.
      -- When all base variables equal t, the (n''+3)-var existential
      -- projects to a 2-var existential, provided the NF is compatible
      -- with all base vars being equal.
      --
      -- The atom part projects exactly as at depth 0 (via bool_eq_of_iff_same).
      -- The quantifier part projects similarly: the (n''+4)-var depth-k
      -- existentials ∃ y, nf_eval_nf M k (n''+4) env ssn with base (fun _ => t)
      -- reduce to 3-var depth-k existentials when base vars beyond position 1
      -- are all equal to t. This requires ExistPart(k+1) at n=1.
      --
      -- Strategy: first obtain ExistPart(k+1) at n=1 (the blocker from above),
      -- then project the n-var NF to a 2-var NF and apply the n=1 result.
      -- Both atom projection and quantifier projection use the constant-base
      -- argument. Once the n=1 sorry above is filled (Phase 4), this reduces
      -- to the same Classical.em + bool_eq_of_iff_same pattern as depth 0.
      --
      -- For now, this is sorry because it depends on the n=1 case.
      sorry

/-! ## Combined Induction -/

/-- The combined mutual induction: CharPart(k) ∧ ExistPart(k) for all k.

    CharPart is sorry-free for all k (given ExistPart at lower depths).
    ExistPart is sorry-free at k=0 for all n; sorry at k>=1 for all n. -/
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
