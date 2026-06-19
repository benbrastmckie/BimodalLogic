import Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass
import Bimodal.Metalogic.WeakCanonical.Kamp.NfComposition

/-!
# Generalized P_n(k) Mutual Induction (Rabinovich 2014 Section 5)

The main remaining sorry in the Kamp theorem pipeline is
`existPart_succ_n1_bypass` at depth k+1 for k>0 (KampBypass.lean).
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
ExistPart(0)   <-- nf_2var_exist_formula_prior (n=1, sorry-free)
                   + depth-0 multi-var (n>=2, sorry-free via bool_eq_of_iff_same)
CharPart(k+1)  <-- CharPart(k) + ExistPart(k)
                   via nf_characterizable_temporal_prior_classical (sorry-free)
ExistPart(k+1) <-- CharPart(k+1) + ExistPart(k)
                   via arity-climbing + negation closure (sorry at k>0)
```

## Main Results

- `charPart_zero`: CharPart(0), sorry-free
- `charPart_succ`: CharPart(k+1) from CharPart(k) + ExistPart(k), sorry-free
- `existPart_zero`: ExistPart(0), sorry-free for all n
- `existPart_succ`: ExistPart(k+1), sorry at k>0 (via existPart_succ_n1_bypass)
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
  exact nf_characterizable_temporal_prior_classical atomMap h_surj k
    (fun nf_k => ⟨char_k nf_k, char_k_correct nf_k⟩)
    (fun parent_atoms sub_nf => ih_exist 1 (by omega) char_k char_k_correct
      parent_atoms sub_nf)
    nf

/-! ## ExistPart: Base Case

At depth 0, NFs are purely atomic. The n=1 case (2-variable) is
proved by nf_2var_exist_formula_prior. For n >= 2, the
satisfiable case uses bool_eq_of_iff_same to show n-var and 2-var
constraints agree via the M₀ witness; the unsatisfiable case uses ⊥. -/

/-- ExistPart(0): the existential is characterizable at depth 0.
    Sorry-free for all n. At n=1, delegates to nf_2var_exist_formula_prior.
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
      -- Inline the k=0 case of nf_2var_exist_formula_prior to avoid sorry
      -- dependency. At depth 0, nf_2var_exist_depth0_tl is sorry-free.
      obtain ⟨A, hA⟩ := nf_2var_exist_depth0_tl atomMap h_surj sub_nf
      exact ⟨A, fun M _ _ t _ => hA M t⟩
    | succ n'' =>
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
      -- Inline the k=0 case to avoid sorry dependency
      obtain ⟨A_2, hA2_raw⟩ := nf_2var_exist_depth0_tl atomMap h_surj sub_nf_2
      have hA2 : ∀ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap)
          (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier),
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
          (temporal_truth M atomMap t A_2 ↔
           ∃ x : M.carrier, nf_eval_nf M 0 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf_2) :=
        fun M _ _ t _ => hA2_raw M t
      rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
          (t : M.carrier) (x : M.carrier),
          nf_eval_nf M 0 (n'' + 2 + 1) (Fin.cons x (fun _ => t)) sub_nf ∧
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
            parent_atoms a = true)) with ⟨M₀, t₀, x₀, h_eval₀, h_atoms₀⟩ | h_no_compat
      · refine ⟨A_2, fun M h_UZ h_SZ t h_atoms => ?_⟩
        rw [hA2 M h_UZ h_SZ t h_atoms]
        constructor
        · rintro ⟨x, h2⟩
          refine ⟨x, fun a => ?_⟩
          match a with
          | .pred p ⟨0, _⟩ =>
            have := h2 (.pred p ⟨0, by omega⟩)
            simp only [atom_eval, Fin.cons] at this ⊢; exact this
          | .pred p ⟨i + 1, hi⟩ =>
            have h_i₀ := h_eval₀ (.pred p ⟨i + 1, by omega⟩)
            have h_pa₀ := h_atoms₀ (.pred p ⟨0, by omega⟩)
            simp only [atom_eval, Fin.cons] at h_i₀ h_pa₀ ⊢
            have h_eq : sub_nf (.pred p ⟨i + 1, by omega⟩) =
                parent_atoms (.pred p ⟨0, by omega⟩) :=
              bool_eq_of_iff_same h_i₀ h_pa₀
            rw [h_eq]; exact h_atoms (.pred p ⟨0, by omega⟩)
          | .order ⟨0, _⟩ ⟨j + 1, hj⟩ _ =>
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
        · rintro ⟨x, hn⟩
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
      · refine ⟨Formula.bot, fun M _ _ t h_atoms => ?_⟩
        simp only [temporal_truth]
        constructor
        · intro h; exact absurd h id
        · rintro ⟨x, hx⟩
          exact absurd ⟨M, t, x, hx, h_atoms⟩ h_no_compat

/-! ## ExistPart: Step Case -/

/-- ExistPart(k+1) from CharPart(k+1) + ExistPart(k).
    Factored into two cases:
    - n=1 (arity 2): delegates to existPart_succ_n1_bypass.
    - n>=2 (arity >=3): sorry -- depends on n=1 case. -/
theorem existPart_succ {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (ih_char : CharPart atomMap k)
    (ih_char_succ : CharPart atomMap (k + 1))
    (ih_exist : ExistPart atomMap h_surj k)
    (ih_all_char : ∀ (d : Nat), d ≤ k →
        ∀ (nf_d : NormalForm sig d 1),
          ∃ (A : Formula),
            ∀ (M : OrderedMonadicStructure sig)
              (h_UZ : semantic_prior_UZ M atomMap)
              (h_SZ : semantic_prior_SZ M atomMap)
              (t : M.carrier),
              temporal_truth M atomMap t A ↔ nf_eval_nf M d 1 (fun _ => t) nf_d) :
    ExistPart atomMap h_surj (k + 1) := by
  intro n hn char_kp1 char_kp1_correct parent_atoms sub_nf
  cases n with
  | zero => omega
  | succ n' =>
    cases n' with
    | zero =>
      exact existPart_succ_n1_bypass atomMap h_surj k
        char_kp1 char_kp1_correct ih_char ih_exist
        ih_all_char parent_atoms sub_nf
    | succ n'' =>
      -- n>=2 case: arity n''+3. Constant parent env means
      -- the n-var NF is determined by the 2-var NF.
      rcases Classical.em (∃ (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
          (t : M.carrier) (x : M.carrier),
          nf_eval_nf M (k + 1) (n'' + 1 + 1 + 1) (Fin.cons x (fun _ => t)) sub_nf ∧
          (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
            parent_atoms a = true)) with ⟨M₀, h_UZ₀, h_SZ₀, t₀, x₀, h_eval₀, h_atoms₀⟩ | h_unsat
      · -- Satisfiable: use M₀ to reduce to 2-var via constenv_2var_determines
        let sub_nf_2 := nf_characteristic M₀ (k + 1) 2 (Fin.cons x₀ (fun _ => t₀))
        obtain ⟨A₂, hA₂⟩ := existPart_succ_n1_bypass atomMap h_surj k
          char_kp1 char_kp1_correct ih_char ih_exist
          ih_all_char parent_atoms sub_nf_2
        refine ⟨A₂, fun M h_UZ h_SZ t h_atoms => ?_⟩
        constructor
        · -- Forward: temporal → ∃ x, nf_eval_nf ... sub_nf
          intro h_temp
          -- From A₂ correctness: temporal → ∃ x, 2-var eval
          obtain ⟨x, h_eval_2⟩ := ((hA₂ M h_UZ h_SZ t h_atoms).mp h_temp)
          -- M and M₀ agree on 2-var NFs
          have h_agree_2 := nf_agreement_from_shared_nf M _ M₀ _ sub_nf_2 h_eval_2
            (nf_characteristic_satisfies M₀ (k + 1) 2 (Fin.cons x₀ (fun _ => t₀)))
          -- constenv_2var_determines lifts to n-var
          exact ⟨x, (constenv_2var_determines M M₀ (k + 1) (n'' + 1 + 1) x t x₀ t₀
            h_agree_2 sub_nf).mpr h_eval₀⟩
        · -- Backward: ∃ x, nf_eval_nf ... sub_nf → temporal
          intro ⟨x, h_eval_n⟩
          -- From n-var eval, build 2-var eval via constenv_2var_determines
          -- Both M and M₀ satisfy sub_nf → n-var agreement
          have h_agree_n := nf_agreement_from_shared_nf M _ M₀ _ sub_nf h_eval_n h_eval₀
          -- constenv_2var_determines: n-var agreement → 2-var NF eval
          -- From n-var agreement between M and M₀:
          -- constenv_2var_determines (M₀, M) with their 2-var agreement
          -- But we need 2-var agreement between M₀ and M, which is what we're deriving.
          -- Instead: M₀ satisfies sub_nf_2 at [x₀,t₀], and we need M to satisfy
          -- sub_nf_2 at [x,t].
          -- Key: n-var agreement implies sub_nf_2 is satisfied by M.
          -- sub_nf_2 = nf_characteristic M₀ (k+1) 2 [x₀,t₀].
          -- M₀ satisfies sub_nf_2. We need M to satisfy sub_nf_2.
          -- The n-var eval at M implies M has the same n-var char as M₀.
          -- The 2-var char is a function of the n-var char on constenvs.
          -- Use constenv_2var_determines with reversed M, M₀:
          -- Given 2-var agreement M₀→M (which we derive below), get n-var agreement.
          -- Since n-var agreement already known, the 2-var agreement is forced.
          -- This is still circular. Let's use a different approach.
          -- Use A₂ correctness in the backward direction:
          -- We need temporal_truth M atomMap t A₂.
          -- A₂ characterizes ∃ x, 2-var eval.
          -- We need ∃ x, 2-var eval. We have ∃ x, n-var eval.
          -- The x from n-var eval works for 2-var eval by constenv_2var_determines
          -- applied from M→M₀ to get n-var agreement, then project to 2-var.
          -- Project from n-var to 2-var: constenv_2var_determines M₀ M gives
          -- from M₀'s 2-var agreement with M, n-var agreement with M.
          -- Known: n-var agreement M↔M₀. Need: 2-var M satisfies sub_nf_2.
          -- Direct: from n-var eval h_eval_n + constenv_2var_determines
          apply (hA₂ M h_UZ h_SZ t h_atoms).mpr
          refine ⟨x, ?_⟩
          -- Use constenv_nvar_to_2var to project from n-var to 2-var
          exact (constenv_nvar_to_2var M M₀ (k + 1) (n'' + 1)
            x t x₀ t₀ h_agree_n sub_nf_2).mpr
            (nf_characteristic_satisfies M₀ (k + 1) 2 (Fin.cons x₀ (fun _ => t₀)))
      · -- Unsatisfiable: use ⊥
        exact ⟨Formula.bot, fun M _ _ t h_atoms => by
          simp only [temporal_truth]
          exact ⟨fun h => absurd h id, fun ⟨x, hx⟩ =>
            absurd ⟨M, ‹_›, ‹_›, t, x, hx, h_atoms⟩ h_unsat⟩⟩

/-! ## Combined Induction -/

/-- The combined mutual induction:
    CharPart(k) ∧ ExistPart(k) for all k.
    Uses strong induction to provide ih_all_char at all lower depths. -/
theorem kamp_mutual_induction {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat) :
    CharPart atomMap k ∧ ExistPart atomMap h_surj k := by
  exact Nat.strong_induction_on k fun k ih => by
    cases k with
    | zero =>
      exact ⟨charPart_zero atomMap h_surj,
             existPart_zero atomMap h_surj⟩
    | succ k' =>
      have ih_at_k' := ih k' (by omega)
      have ih_char := ih_at_k'.1
      have ih_exist := ih_at_k'.2
      have char_succ := charPart_succ atomMap h_surj k' ih_char ih_exist
      -- Build ih_all_char from strong IH
      have ih_all_char : ∀ (d : Nat), d ≤ k' →
          ∀ (nf_d : NormalForm sig d 1),
            ∃ (A : Formula),
              ∀ (M : OrderedMonadicStructure sig)
                (h_UZ : semantic_prior_UZ M atomMap)
                (h_SZ : semantic_prior_SZ M atomMap)
                (t : M.carrier),
                temporal_truth M atomMap t A ↔ nf_eval_nf M d 1 (fun _ => t) nf_d :=
        fun d hd => (ih d (by omega)).1
      have exist_succ := existPart_succ atomMap h_surj k' ih_char char_succ
        ih_exist ih_all_char
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
