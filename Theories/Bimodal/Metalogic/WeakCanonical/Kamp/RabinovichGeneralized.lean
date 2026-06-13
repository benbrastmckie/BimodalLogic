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
    Sorry-free at n=1, sorry at n >= 2. -/
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
      -- Since all base variables map to t, constraints among base vars
      -- (variables 1..n''+2) are vacuous if they require no strict orders.
      -- The existence reduces to the same Until/Since pattern as n=1
      -- after checking consistency of the multi-var order constraints.
      --
      -- The mathematical argument is the same as n=1. The proof requires
      -- extensive case analysis on Fin indices to reduce the (n+1)-var
      -- existential to the 2-var projection.
      sorry

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
