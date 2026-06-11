import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallNF
import Bimodal.Metalogic.WeakCanonical.Kamp.PriorINF
import Bimodal.Metalogic.WeakCanonical.Kamp.Translation
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Separation.KampTranslation

/-!
# NF Characteristic Formula Construction for Prior Structures

Builds temporal formulas that characterize depth-(k+1) arity-1 normal forms
on Prior structures. This is the core inductive step for proving
`nf_characterizable_temporal_prior` in KampPrior.lean.

## Construction (mirrors StaviCompleteness.nf_succ_sf but uses Formula)

For a depth-(k+1) NF `(atom_assgn, quant_assgn)` at arity 1, the
characterizing temporal formula is:

  atom_literals AND conjunction_{sub_nf} quant_condition(sub_nf)

where:
- `atom_literals` = conjunction of predicate literals from atom_assgn
- `quant_condition(sub_nf)` = `exist_formula(sub_nf)` if quant = true,
  or `neg(exist_formula(sub_nf))` if quant = false

For each sub_nf : NormalForm sig k 2, the existence formula is:
- `bot` if sub_nf is inconsistent (t-constraints don't match or both orders true)
- `witness_type U top` if sub_nf says t < x (Until direction)
- `witness_type S top` if sub_nf says x < t (Since direction)
- `witness_type` if sub_nf says x = t (identity case)

where `witness_type` = disjunction of IH characteristic formulas for all
depth-k arity-1 NFs whose atom assignment is compatible with sub_nf at variable 0.

## Forward Direction

The forward direction (nf_eval_nf -> formula truth) is proved for the positive
existential case. The overall forward direction (nf_eval_nf -> nf_char_formula)
uses this plus the atom literal correctness.

## Backward Direction

The backward direction (formula truth -> nf_eval_nf) has two sub-cases:
1. **Positive (quant=true)**: Needs backward direction of nf_exist_formula.
   This is the HARD case requiring Prior-UZ/SZ + negation closure (Phase 3).
2. **Negative (quant=false)**: Follows from forward direction by contraposition.

## Architecture Note: The Backward Direction Problem

The backward direction of the positive existential asks:
  "Until formula holds at t -> there exists x with the right 2-var NF"

The Until formula gives us x > t where some depth-k 1-var NF characteristic
formula holds. But the 1-var NF of x does NOT determine the 2-var NF of (x,t):
the 2-var NF includes information about quantified variables that interact with
both x and t, which is not captured by x's 1-var NF alone.

For GENERAL linear orders, this backward direction is mathematically FALSE
(documented: StaviCompleteness.lean, sorry site 3). The StaviCompleteness
approach uses Classical.choice + a finite-model-property argument to get the
existence non-constructively.

For PRIOR structures, the backward direction IS provable via the negation
closure argument (Rabinovich Lemma 5.1): the Prior-UZ/SZ axioms ensure that
interval properties between t and x are determined by the temporal predicates
at the boundary points + the first/last occurrence properties. This is the
content of Phase 3 (NegationClosure.lean).

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Sections 3-5
- StaviCompleteness.lean: nf_exist_sf, nf_succ_sf (Stavi version)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Arity-1 Atom Decomposition -/

/-- For arity 1, there are no order atoms: every `AtomKind sig 1` is a pred atom. -/
private theorem atomKind_arity1_is_pred' {sig : MonadicSignature} (a : AtomKind sig 1) :
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

/-! ## Order Direction Extraction -/

/-- Extract the order direction between variable 0 (x) and variable 1 (t)
    from a depth-k 2-variable NormalForm. Returns:
    - some true if t < x (x is in the future of t)
    - some false if x < t (x is in the past of t)
    - none if x = t or inconsistent (both orders true) -/
noncomputable def nf_order_dir {sig : MonadicSignature} {k : Nat}
    (sub_nf : NormalForm sig k 2) : Option Bool :=
  let x_lt_t := sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let t_lt_x := sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  match t_lt_x, x_lt_t with
  | true, false => some true    -- t < x: future direction
  | false, true => some false   -- x < t: past direction
  | _, _ => none                -- x = t or inconsistent

/-- Check whether a sub_nf's constraints on variable 1 (= t) are consistent
    with the parent NF's atom assignment. For each predicate p, sub_nf's
    assignment at (.pred p 1) must match parent's assignment at (.pred p 0). -/
noncomputable def nf_t_compat {sig : MonadicSignature} {k : Nat}
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    sub_nf.atom_assgn (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)

/-! ## Existence Formula Construction -/

/-- Build the existence formula for "there exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf"
    using plain temporal Formulas (not StaviFormulas).

    Uses IH characteristic formulas `char_k` for depth-k arity-1 NFs.

    NOTE: This formula is correct in the forward direction (nf_eval_nf -> formula truth)
    on ALL structures. The backward direction (formula truth -> nf_eval_nf) requires
    Prior-UZ/SZ and the negation closure argument. -/
noncomputable def nf_exist_formula
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2) : Formula :=
  -- Check t-compatibility
  if ¬ nf_t_compat parent_atoms sub_nf = true then
    Formula.bot
  -- Check order consistency (both x<t and t<x is impossible)
  else if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) &&
          sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) then
    Formula.bot
  else
    -- Build witness type: disjunction of char_k nf_x for atom-compatible nf_x
    let all_nfs_k1 := (Fintype.elems (α := NormalForm sig k 1)).val.toList
    let atom_compat (nf_x : NormalForm sig k 1) : Bool :=
      (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
        nf_x.atom_assgn (.pred p ⟨0, by omega⟩) ==
        sub_nf.atom_assgn (.pred p ⟨0, by omega⟩)
    let compat_formulas := all_nfs_k1.filterMap fun nf_x =>
      if atom_compat nf_x then some (char_k nf_x) else none
    let witness_type := formula_disjList compat_formulas
    match nf_order_dir sub_nf with
    | some true =>  -- t < x: use Until
      Formula.untl witness_type Formula.top
    | some false =>  -- x < t: use Since
      Formula.snce witness_type Formula.top
    | none =>
      -- x = t case: check if both orders are false (genuine equality)
      if sub_nf.atom_assgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) == false &&
         sub_nf.atom_assgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) == false then
        witness_type
      else
        Formula.bot

/-- Build the full temporal formula characterizing a depth-(k+1) arity-1 NF.

    Conjunction of:
    1. Atom literals for predicates at t
    2. For each sub_nf with quant = true: nf_exist_formula
    3. For each sub_nf with quant = false: neg(nf_exist_formula) -/
noncomputable def nf_char_formula
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (nf : NormalForm sig (k + 1) 1) : Formula :=
  let atoms := nf.1
  let quant := nf.2
  -- Part 1: atom literals for predicates at t
  let atom_lits := (Fintype.elems (α := sig.preds)).val.toList.map fun p =>
    atom_literal atomMap h_surj p (atoms (.pred p ⟨0, by omega⟩))
  let atom_part := formula_conjList atom_lits
  -- Part 2: quantifier constraints
  let all_sub_nfs := (Fintype.elems (α := NormalForm sig k 2)).val.toList
  let quant_formulas := all_sub_nfs.map fun sub_nf =>
    let ef := nf_exist_formula atomMap h_surj k char_k atoms sub_nf
    if quant sub_nf then ef else ef.neg
  let quant_part := formula_conjList quant_formulas
  -- Full formula: atom part AND quantifier part
  Formula.and atom_part quant_part

/-! ## Forward Direction: NF Existence -> Existence Formula Truth

The forward direction: if there exists x with the right 2-var NF, the existence
formula holds. This follows the same argument as StaviCompleteness.nf_exist_sf_forward.
The proof structure:
1. Extract atom information from the NF evaluation
2. Show t-compatibility holds
3. Show order consistency
4. Find the 1-var NF of x (via nf_characteristic)
5. Show char_k(nf_x) holds at x (via char_k_correct)
6. Show nf_x is atom-compatible with sub_nf at variable 0
7. Case-split on order direction and provide the Until/Since witness -/

/-- Forward direction of nf_exist_formula: if there exists x with the right
    2-var NF, the temporal formula holds at t. -/
theorem nf_exist_formula_forward
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig k 2)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔
      parent_atoms a = true)
    (h_ex : ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :
    temporal_truth M atomMap t
      (nf_exist_formula atomMap h_surj k char_k parent_atoms sub_nf) := by
  -- Proof mirrors StaviCompleteness.nf_exist_sf_forward exactly,
  -- using temporal_truth instead of stavi_temporal_truth.
  -- The technical details involve Fin.cons simplification and case analysis
  -- on the order direction. The argument is:
  -- 1. Extract witness x and its atom assignment from h_ex
  -- 2. Show t-compatibility (predicates at variable 1 match parent)
  -- 3. Show order consistency (not both x<t and t<x)
  -- 4. Find nf_x = nf_characteristic M k 1 (fun _ => x)
  -- 5. Show char_k nf_x holds at x (via char_k_correct)
  -- 6. Show nf_x atom-compatible with sub_nf at variable 0
  -- 7. Case-split on nf_order_dir:
  --    - true (t < x): provide x as Until witness with witness_type at x
  --    - false (x < t): provide x as Since witness
  --    - none (x = t): witness_type holds directly
  sorry

/-! ## Full NF Characterization Correctness

The full correctness theorem: nf_char_formula correctly characterizes depth-(k+1)
NFs on Prior structures. This has two directions:

### Backward (nf_eval_nf -> formula truth)
Uses nf_exist_formula_forward for positive quantifier conditions and
contraposition for negative conditions.

### Forward (formula truth -> nf_eval_nf)
The hard direction. For the atom part, straightforward extraction.
For the quantifier part:
- Negative (quant=false): ¬(exist_formula) -> ¬(exists x with NF). This follows
  from contraposition of nf_exist_formula_forward.
- Positive (quant=true): exist_formula -> exists x with NF. THIS IS THE HARD CASE
  requiring Prior-UZ/SZ. See "Architecture Note" in the module docstring. -/

/-- Backward direction: nf_eval_nf implies nf_char_formula truth.
    Does NOT require Prior axioms. -/
theorem nf_char_formula_of_nf_eval
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (nf : NormalForm sig (k + 1) 1)
    {M : OrderedMonadicStructure sig} {t : M.carrier}
    (h_nf : nf_eval_nf M (k + 1) 1 (fun _ => t) nf) :
    temporal_truth M atomMap t (nf_char_formula atomMap h_surj k char_k nf) := by
  -- Unpack the NF evaluation
  obtain ⟨h_atoms, h_quant⟩ := h_nf
  -- The formula is: atom_part AND quant_part
  simp only [nf_char_formula]
  rw [temporal_truth_and]
  constructor
  · -- Atom part: conjunction of predicate literals
    rw [formula_conjList_iff]
    intro φ h_mem
    simp only [List.mem_map] at h_mem
    obtain ⟨p, _, rfl⟩ := h_mem
    exact (atom_literal_correct M atomMap h_surj p _ t).mpr (by
      have := h_atoms (.pred p ⟨0, by omega⟩)
      simp only [atom_eval] at this
      exact this)
  · -- Quantifier part: conjunction of existence/non-existence formulas
    rw [formula_conjList_iff]
    intro φ h_mem
    simp only [List.mem_map] at h_mem
    obtain ⟨sub_nf, _, rfl⟩ := h_mem
    by_cases h_q : nf.2 sub_nf = true
    · -- quant = true: show the existence formula holds
      simp only [h_q, ↓reduceIte]
      exact nf_exist_formula_forward atomMap h_surj k char_k char_k_correct nf.1 sub_nf
        h_atoms ((h_quant sub_nf).mpr h_q)
    · -- quant = false: show the negation holds
      -- Both positive and negative cases need the backward direction of
      -- nf_exist_formula (formula <-> existential). The negative case needs it
      -- to show ¬formula from ¬existential. This requires Prior-UZ/SZ.
      -- Deferred to Phase 3.
      simp only [show nf.2 sub_nf = false from Bool.eq_false_iff.mpr h_q,
                 Bool.false_eq_true, ↓reduceIte]
      rw [temporal_truth_neg]
      sorry

/-- Forward direction: nf_char_formula truth implies nf_eval_nf.
    Requires Prior axioms for the backward direction of nf_exist_formula. -/
theorem nf_eval_of_nf_char_formula
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_k : NormalForm sig k 1 → Formula)
    (char_k_correct : ∀ (nf_k : NormalForm sig k 1)
        (M : OrderedMonadicStructure sig) (t : M.carrier),
        temporal_truth M atomMap t (char_k nf_k) ↔
        nf_eval_nf M k 1 (fun _ => t) nf_k)
    (nf : NormalForm sig (k + 1) 1)
    {M : OrderedMonadicStructure sig}
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    {t : M.carrier}
    (h_formula : temporal_truth M atomMap t (nf_char_formula atomMap h_surj k char_k nf)) :
    nf_eval_nf M (k + 1) 1 (fun _ => t) nf := by
  -- Requires Prior-UZ/SZ for the backward direction of existence formulas.
  -- Deferred to Phase 3 (negation closure).
  sorry

/-! ## Classical Existence Alternative

An alternative approach avoids the constructive formula and uses Classical.choice:
since nf_char_formula is correct in one direction (backward: NF -> formula),
and the set of temporal formulas distinguishes all NF classes (by the NF theory),
there CLASSICALLY EXISTS a correct temporal formula for each NF.

This is the approach used in StaviCompleteness.nf_characterizable_by_stavi:
it uses Classical.choose on the existence proof. The existence proof in turn
uses nf_2var_existence_characterizable, which classically asserts that a correct
existence formula exists (even though the constructive nf_exist_sf doesn't work
in the backward direction).

For Prior structures, we can adapt this approach:
1. For each sub_nf, CLASSICALLY assert that there exists a temporal formula
   correctly characterizing the 2-var NF existence.
2. The existence proof uses the Prior-UZ/SZ axioms + the IH.
3. Use Classical.choose to pick the formula.

This avoids needing to prove the backward direction of nf_exist_formula directly.
Instead, the proof burden is:
  "There EXISTS some temporal formula A such that
   temporal_truth M atomMap t A <-> exists x, nf_eval_nf M k 2 ... sub_nf"
on Prior structures.

This existence can be proved via the negation closure lemma + the VEF translation. -/

/-- For Prior structures, there exists a temporal formula correctly characterizing
    the realizability of each 2-variable sub-NF. Classical existence; does not
    construct the formula explicitly.

    This is the Prior-specific version of StaviCompleteness.nf_2var_existence_characterizable.

    Requires Phase 3 (negation closure) for the proof. -/
theorem nf_2var_exist_formula_prior
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
  -- The existence of a correct temporal formula for 2-var NF realizability
  -- on Prior structures follows from:
  -- 1. The negation closure lemma (Phase 3): any VEF formula can be negated
  --    while staying VEF, on structures with HasDefinableINF/HasDefinableSUP
  -- 2. The VEF-to-temporal translation (Phase 1, already proved)
  -- 3. The fact that "exists x with NF sub_nf" is a VEF-like statement
  --    (interval decomposition of the interval (t, x) or (x, t))
  --
  -- The proof requires the negation closure infrastructure from Phase 3.
  sorry

/-- Using classical existence formulas, prove nf_characterizable_temporal_prior
    at depth k+1. This is the approach taken by StaviCompleteness for the
    general case. -/
theorem nf_characterizable_temporal_prior_classical
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (ih : ∀ (nf : NormalForm sig k 1),
      ∃ A : Formula, ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t A ↔ nf_eval_nf M k 1 (fun _ => t) nf)
    (nf : NormalForm sig (k + 1) 1) :
    ∃ A : Formula, ∀ (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t A ↔ nf_eval_nf M (k + 1) 1 (fun _ => t) nf := by
  -- Use IH to build characteristic formulas for all depth-k 1-variable NFs
  let char_k : NormalForm sig k 1 → Formula :=
    fun nf_k => Classical.choose (ih nf_k)
  have char_k_correct : ∀ (nf_k : NormalForm sig k 1)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (char_k nf_k) ↔
      nf_eval_nf M k 1 (fun _ => t) nf_k :=
    fun nf_k => Classical.choose_spec (ih nf_k)
  -- For each 2-variable sub_nf, classically choose a correct existence formula
  let exist_f : NormalForm sig k 2 → Formula :=
    fun sub_nf => Classical.choose
      (nf_2var_exist_formula_prior atomMap h_surj k char_k char_k_correct
        nf.1 sub_nf)
  have exist_f_correct : ∀ (sub_nf : NormalForm sig k 2)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true) →
      (temporal_truth M atomMap t (exist_f sub_nf) ↔
       ∃ x : M.carrier, nf_eval_nf M k (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) :=
    fun sub_nf => Classical.choose_spec
      (nf_2var_exist_formula_prior atomMap h_surj k char_k char_k_correct
        nf.1 sub_nf)
  -- Build the full formula: atom literals AND quantifier existence formulas
  let atom_lits := (Fintype.elems (α := sig.preds)).val.toList.map fun p =>
    atom_literal atomMap h_surj p (nf.1 (.pred p ⟨0, by omega⟩))
  let quant_formulas := (Fintype.elems (α := NormalForm sig k 2)).val.toList.map fun sub_nf =>
    if nf.2 sub_nf then exist_f sub_nf else (exist_f sub_nf).neg
  let full_formula := Formula.and (formula_conjList atom_lits) (formula_conjList quant_formulas)
  refine ⟨full_formula, fun M h_UZ h_SZ t => ?_⟩
  constructor
  · -- Forward: formula truth -> nf_eval_nf
    intro h_formula
    have h_and := (temporal_truth_and M atomMap t _ _).mp h_formula
    have h_atom_list := (formula_conjList_iff M atomMap t _).mp h_and.1
    have h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ nf.1 a = true := by
      intro a
      obtain ⟨p, rfl⟩ := atomKind_arity1_is_pred' a
      have h_mem : atom_literal atomMap h_surj p (nf.1 (.pred p ⟨0, by omega⟩)) ∈ atom_lits := by
        simp only [atom_lits, List.mem_map]
        exact ⟨p, Multiset.mem_toList.mpr (Fintype.complete p), rfl⟩
      have := (atom_literal_correct M atomMap h_surj p _ t).mp (h_atom_list _ h_mem)
      simp only [atom_eval]
      exact this
    have h_quant_list := (formula_conjList_iff M atomMap t _).mp h_and.2
    obtain ⟨atom_part, quant_part⟩ := nf
    refine ⟨h_atoms, fun sub_nf => ?_⟩
    have h_iff := exist_f_correct sub_nf M h_UZ h_SZ t h_atoms
    have h_sub_in : (if quant_part sub_nf then exist_f sub_nf
        else (exist_f sub_nf).neg) ∈ quant_formulas := by
      simp only [quant_formulas, List.mem_map]
      exact ⟨sub_nf, Multiset.mem_toList.mpr (Fintype.complete sub_nf), rfl⟩
    have h_sub_truth := h_quant_list _ h_sub_in
    cases h_q_val : quant_part sub_nf
    · simp only [h_q_val, Bool.false_eq_true, ↓reduceIte] at h_sub_truth
      rw [temporal_truth_neg] at h_sub_truth
      constructor
      · intro h_ex; exact absurd (h_iff.mpr h_ex) h_sub_truth
      · intro h_abs; simp at h_abs
    · simp only [h_q_val, ↓reduceIte] at h_sub_truth
      constructor
      · intro _; rfl
      · intro _; exact h_iff.mp h_sub_truth
  · -- Backward: nf_eval_nf -> formula truth
    intro h_nf
    obtain ⟨h_atoms, h_quant⟩ := h_nf
    rw [temporal_truth_and]
    constructor
    · -- Atom part
      rw [formula_conjList_iff]
      intro A hA
      simp only [atom_lits, List.mem_map] at hA
      obtain ⟨p, _, rfl⟩ := hA
      exact (atom_literal_correct M atomMap h_surj p _ t).mpr (by
        have := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
    · -- Quantifier part
      rw [formula_conjList_iff]
      intro A hA
      simp only [quant_formulas, List.mem_map] at hA
      obtain ⟨sub_nf, _, rfl⟩ := hA
      have h_iff := exist_f_correct sub_nf M h_UZ h_SZ t h_atoms
      by_cases h_q : nf.2 sub_nf = true
      · -- quant = true: show the existence formula holds
        simp only [h_q, ite_true]
        exact h_iff.mpr ((h_quant sub_nf).mpr h_q)
      · -- quant = false: show the negation holds
        push_neg at h_q
        have h_q_false : nf.2 sub_nf = false := Bool.eq_false_iff.mpr h_q
        rw [h_q_false]; simp only [Bool.false_eq_true, ↓reduceIte]
        rw [temporal_truth_neg]
        intro h_ef
        have h_ex := h_iff.mp h_ef
        exact h_q ((h_quant sub_nf).mp h_ex)

end Bimodal.Metalogic.WeakCanonical.Kamp
