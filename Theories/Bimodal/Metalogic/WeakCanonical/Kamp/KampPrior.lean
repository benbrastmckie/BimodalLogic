import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.Prop43
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# Kamp's Theorem for Prior Structures (Rabinovich 2014)

Proves that {U,S} is expressively complete for Prior structures by
implementing Rabinovich 2014's proof chain: Lemma 5.1 -> Prop 4.2 ->
Prop 4.3 -> Theorem 4.4.

## Main Result

- `kamp_prior_expressive_completeness`: every `MonadicFormula sig 1` has
  an equivalent `Formula` (using only U,S) on Prior structures.
  Same type signature as `US_expressively_complete_over_prior`.

## Proof Architecture (Rabinovich Chain via Disjunction Construction)

The proof uses Rabinovich's faithful chain (plan v29):
1. Lemma 5.1: Model-independent negation closure via three-case disjunction
   construction (`NegationIndep.lean`)
2. Prop 4.2: Model-independent negation of V-EA formulas (`NegationIndep.lean`)
3. Prop 4.3: Every FO formula is equivalent to V-EA via structural formula
   induction (`Prop43.lean`)
4. Theorem 4.4: Prop 4.3 + Prop 3.5 (RabinovichTranslation) gives FO -> TL(U,S)

The NF infrastructure (`doets_lemma_1_1`, `nf_exists_unique`, etc.)
and the NF-to-Formula infrastructure (`nf_to_formula`, `nf_to_formula_correct`)
are all sorry-free and reused directly.

## Status

- k=0 (depth 0): sorry-free (`nf_depth0_char_formula`)
- k=1 (depth 1): sorry-free (`nf_succ_char_formula` + `nf_2var_exist_depth0_tl`)
- k>=2 (depth >= 2): sorry at arity tower (depth-k arity-2 existentials
  require depth-(k-1) arity-3 NF decomposition, Rabinovich Lemma 3.2.2)

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 3-5
- Reynolds 1994, Theorem 5
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Arity-1 Depth-0 NF Characterization

At arity 1, there are no order atoms (since `Fin 1` has only one element,
and `i ≠ j` can't hold). So a depth-0 NF is entirely determined by
predicate atoms. The existing `nf_depth0_char_formula` handles this. -/

/-- For arity 1, there are no order atoms: every `AtomKind sig 1` is a pred atom. -/
theorem atomKind_arity1_is_pred {sig : MonadicSignature} (a : AtomKind sig 1) :
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

/-- The depth-0 characteristic formula is correct for the full NF at arity 1.
    Bridges from predicate agreement to full atom agreement. -/
theorem nf_depth0_char_formula_correct_arity1
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (nf : NormalForm sig 0 1) (t : M.carrier) :
    temporal_truth M atomMap t (Separation.nf_depth0_char_formula atomMap h_surj nf) ↔
    nf_eval_nf M 0 1 (fun _ => t) nf := by
  rw [Separation.nf_depth0_char_formula_correct]
  simp only [nf_eval_nf]
  constructor
  · -- From predicate agreement to full atom agreement
    intro h_preds a
    obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred a
    simp only [atom_eval]
    exact h_preds p
  · -- From full atom agreement to predicate agreement
    intro h_atoms p
    have h := h_atoms (.pred p ⟨0, by omega⟩)
    simp only [atom_eval] at h
    exact h

/-! ## NF-to-Temporal Translation for Prior Structures

Core construction: translate a depth-k arity-1 normal form to a temporal
formula that characterizes it on Prior structures.

- **k = 0**: `nf_depth0_char_formula` (conjunction of atom literals).
- **k + 1**: Convert the NF to a `MonadicFormula sig 1` via `nf_to_formula`,
  then apply Prop 4.3 (`fo_to_vea`) to get a VVecEA2, then apply
  Prop 3.5 (`VVecEA2.translateLeft`) to get a temporal Formula.
-/

/-- For Prior structures, every depth-k arity-1 NF is characterizable
    by a temporal formula (using only U and S).

    This is the Prior-specific replacement for `nf_characterizable_by_stavi`.

    - k=0: `nf_depth0_char_formula` (atom literals)
    - k=1: `nf_succ_char_formula` with `nf_2var_exist_depth0_tl` (sorry-free)
    - k>=2: sorry (arity tower: requires Lemma 3.2.2 for arity-3 at depth > 0)
-/
noncomputable def nf_characterizable_temporal_prior
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (nf : NormalForm sig k 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔
        nf_eval_nf M k 1 (fun _ => t) nf } := by
  induction k with
  | zero =>
    -- Depth 0: conjunction of atom literals (no temporal operators needed)
    exact ⟨Separation.nf_depth0_char_formula atomMap h_surj nf,
      fun M _ _ t => nf_depth0_char_formula_correct_arity1 M atomMap h_surj nf t⟩
  | succ k _ih =>
    -- Depth k+1: use nf_succ_char_formula with a function converting
    -- depth-k arity-2 existentials to temporal formulas.
    match k with
    | 0 =>
      -- At k=0: depth-1 NF. The existentials involve depth-0 arity-2 NFs,
      -- which are handled by nf_2var_exist_depth0_tl (sorry-free).
      exact ⟨nf_succ_char_formula atomMap h_surj
              (nf_2var_exist_depth0_tl_fn atomMap h_surj) nf,
        fun M h_UZ h_SZ t =>
          nf_succ_char_formula_correct atomMap h_surj
            (nf_2var_exist_depth0_tl_fn atomMap h_surj)
            (fun sub_nf M' _ _ t' =>
              nf_2var_exist_depth0_tl_fn_correct atomMap h_surj sub_nf M' t')
            nf M h_UZ h_SZ t⟩
    | k' + 1 =>
      -- At k=k'+1 (depth k'+2): the existentials involve depth-(k'+1) arity-2
      -- NFs, which require depth-k' arity-3 decomposition (arity tower
      -- obstruction). This case is blocked pending generalization of V-EA
      -- formulas to arbitrary arity (Rabinovich Lemma 3.2.2).
      sorry

/-- Main theorem: {U,S} expressive completeness for Prior structures,
    proved via Kamp/Rabinovich 2014 (relativized from Dedekind completeness
    to semantic_prior_UZ/SZ).

    Every `MonadicFormula sig 1` has a `Formula` equivalent on Prior structures.
    Same type signature as `US_expressively_complete_over_prior`.

    Proof structure (mirrors `stavi_expressive_completeness`):
    1. Set k = quantifier_depth(psi)
    2. For each depth-k NF, get temporal formula via `nf_characterizable_temporal_prior`
    3. A NF is "good" if some (M, t) satisfies both the NF and psi
    4. Result = disjunction of characteristic formulas of good NFs
    5. Forward: if psi holds, the characteristic NF of (M, t) is good
    6. Backward: if some good NF's formula holds, use `doets_lemma_1_1` to transfer psi -/
noncomputable def kamp_prior_expressive_completeness
    {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (psi : MonadicFormula sig 1) :
    { A : Formula //
      ∀ (M : OrderedMonadicStructure sig)
        (_h_prior_UZ : semantic_prior_UZ M atomMap)
        (_h_prior_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        eval M (fun _ => t) psi ↔
        temporal_truth M atomMap t A } := by
  -- Step 1: Use the NF infrastructure (sorry-free)
  set k := psi.quantifier_depth with hk_def
  -- Step 2: For each NF, get a temporal characteristic formula (Prior-specific)
  have nf_char := fun nf => nf_characterizable_temporal_prior atomMap h_surj k nf
  let char_f : NormalForm sig k 1 → Formula :=
    fun nf => (nf_char nf).val
  have char_correct : ∀ (nf : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (char_f nf) ↔
      nf_eval_nf M k 1 (fun _ => t) nf :=
    fun nf M h_UZ h_SZ t => (nf_char nf).property M h_UZ h_SZ t
  -- Step 3: "good" predicate (NFs consistent with psi)
  let good_prop : NormalForm sig k 1 → Prop :=
    fun nf => ∃ (M : OrderedMonadicStructure sig) (t : M.carrier),
      nf_eval_nf M k 1 (fun _ => t) nf ∧ eval M (fun _ => t) psi
  -- Step 4: Build the disjunction over good NFs
  let all_nfs := (Fintype.elems (α := NormalForm sig k 1)).val.toList
  let good_formulas := all_nfs.filterMap (fun nf =>
    if @decide (good_prop nf) (Classical.dec _) then some (char_f nf) else none)
  -- Helper: good_formulas membership characterization
  have mem_good_iff : ∀ (f : Formula), f ∈ good_formulas ↔
      ∃ nf ∈ all_nfs, good_prop nf ∧ f = char_f nf := by
    intro f
    simp only [good_formulas, List.mem_filterMap]
    constructor
    · rintro ⟨nf, hnf_mem, h_ite⟩
      by_cases hg : good_prop nf
      · rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)] at h_ite
        exact ⟨nf, hnf_mem, hg, (Option.some.inj h_ite).symm⟩
      · rw [if_neg (mt (@decide_eq_true_eq _ (Classical.dec _)).mp hg)] at h_ite
        exact absurd h_ite (by simp)
    · rintro ⟨nf, hnf_mem, hg, rfl⟩
      exact ⟨nf, hnf_mem, by rw [if_pos (@decide_eq_true _ (Classical.dec _) hg)]⟩
  -- NF determines psi (from doets_lemma_1_1 + nf_exists_unique)
  have nf_determines_psi : ∀ (nf : NormalForm sig k 1)
      (M₁ M₂ : OrderedMonadicStructure sig) (t₁ : M₁.carrier) (t₂ : M₂.carrier),
      nf_eval_nf M₁ k 1 (fun _ => t₁) nf →
      nf_eval_nf M₂ k 1 (fun _ => t₂) nf →
      (eval M₁ (fun _ => t₁) psi ↔ eval M₂ (fun _ => t₂) psi) := by
    intro nf M₁ M₂ t₁ t₂ h₁ h₂
    apply doets_lemma_1_1 k 1 psi (hk_def ▸ le_refl _) M₁ M₂ (fun _ => t₁) (fun _ => t₂)
    intro nf'
    obtain ⟨c₁, hc₁, hu₁⟩ := nf_exists_unique M₁ k 1 (fun _ => t₁)
    obtain ⟨c₂, hc₂, hu₂⟩ := nf_exists_unique M₂ k 1 (fun _ => t₂)
    simp only at hu₁ hu₂
    have h_eq₁ : c₁ = nf := (hu₁ nf h₁).symm
    have h_eq₂ : c₂ = nf := (hu₂ nf h₂).symm
    subst h_eq₁; subst h_eq₂
    constructor
    · intro h'; have := hu₁ nf' h'; subst this; exact hc₂
    · intro h'; have := hu₂ nf' h'; subst this; exact hc₁
  -- Step 5: Result is the disjunction
  refine ⟨Separation.formula_disjList good_formulas, fun M h_UZ h_SZ t => ?_⟩
  rw [Separation.formula_disjList_iff]
  constructor
  · -- Forward: psi holds → some good NF's characteristic formula holds
    intro h_psi
    set nf_M := nf_characteristic M k 1 (fun _ => t)
    have h_nf_M := nf_characteristic_satisfies M k 1 (fun _ => t)
    have h_char_eval := (char_correct nf_M M h_UZ h_SZ t).mpr h_nf_M
    have h_good : good_prop nf_M := ⟨M, t, h_nf_M, h_psi⟩
    have h_in : char_f nf_M ∈ good_formulas := by
      rw [mem_good_iff]
      exact ⟨nf_M, Multiset.mem_toList.mpr (Fintype.complete nf_M), h_good, rfl⟩
    exact ⟨char_f nf_M, h_in, h_char_eval⟩
  · -- Backward: some good NF's characteristic formula holds → psi holds
    rintro ⟨A, hA_mem, hA_eval⟩
    rw [mem_good_iff] at hA_mem
    obtain ⟨nf, _, h_good, rfl⟩ := hA_mem
    have h_nf_eval := (char_correct nf M h_UZ h_SZ t).mp hA_eval
    obtain ⟨M', t', hM'_nf, hM'_psi⟩ := h_good
    exact (nf_determines_psi nf M' M t' t hM'_nf h_nf_eval).mp hM'_psi

end Bimodal.Metalogic.WeakCanonical.Kamp
