import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs

/-!
# Enriched Bypass Formula for ExistPart(k+1)

Constructs an "enriched" temporal formula that directly encodes both atom
conditions AND quantifier conditions for the 2-variable existential at
depth k+1. This bypasses the broken backward direction of `nf_exist_formula`
(NfCharFormula.lean) by encoding quantifier information in the formula
itself, making backward extraction trivial (conjunction elimination).

## Key Insight

The sorry at `nf_2var_exist_formula_prior` (NfCharFormula.lean:610) requires
only `∃ A` -- an existential over formulas. The enriched formula encodes
both atom AND quantifier conditions at the witness point x.

## Architecture

For `∃ x, nf_eval_nf M (k+1) 2 [x, t] sub_nf`, the depth-(k+1) 2-var NF
unfolds as:

  (∀ a, atom_eval M [x,t] a ↔ sub_nf.1 a) ∧
  (∀ ssn, (∃ y, nf_eval_nf M k 3 [y,x,t] ssn) ↔ sub_nf.2 ssn)

The enriched formula encodes BOTH conditions using:
1. `char_{k+1}(nf_x)` for x's 1-var type (atom + quantifier conditions
   involving only x's internal structure)
2. Explicit temporal conjuncts for each 3-var quantifier condition involving
   both x and t

At depth 0 (k=0 inner), the 3-var conditions are purely atomic and
can be encoded as temporal formulas using zone decomposition.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem", Section 5
- VecEADecomp.lean (depth-0 3-var zone decomposition)
- NfToVecEA.lean (depth-0 2-var bridge)
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Helper: t-compatibility check

Check whether a 2-var NF's variable-1 (t) atoms are compatible with
parent_atoms. This is needed to filter out sub_nf values whose t-constraints
don't match the actual t. -/

/-- Check t-compatibility: the sub_nf's variable-1 predicate atoms match parent_atoms. -/
noncomputable def nf_t_compat_check {sig : MonadicSignature}
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 0 2) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    sub_nf (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)

/-! ## Depth-0 3-var Existential Formula

At depth 0, `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` is purely atomic:
predicates at y,x,t plus order relations. We encode this as a temporal
formula evaluated at x, using Since/Until to find y in the right zone. -/

/-- For a depth-0 3-var NF ssn, check whether ssn's constraints on variables
    1 (x) and 2 (t) are compatible with a given 1-var NF for x, parent_atoms
    for t, and a specific x-t order (x > t, x < t, or x = t).

    x_gt_t = true means we require t < x (Until zone).
    x_lt_t = true means we require x < t (Since zone). -/
noncomputable def ssn_xt_compatible {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x_gt_t x_lt_t : Bool) : Bool :=
  -- Check x predicates match nf_x
  (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
    ssn (.pred p ⟨1, by omega⟩) == nf_x_1var (.pred p ⟨0, by omega⟩)) &&
  -- Check t predicates match parent_atoms
  (Fintype.elems (α := sig.preds)).val.toList.all (fun p =>
    ssn (.pred p ⟨2, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)) &&
  -- Check x-t order compatibility
  (ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) == x_gt_t) &&
  (ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) == x_lt_t)

/-- Build a temporal formula at x for the depth-0 3-var existential
    `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn`, given that x and t have
    known predicates and order.

    The formula depends on y's zone relative to x:
    - y < x: Since(char_0(nf_y_proj ssn), ⊤) at x
    - y > x: Until(char_0(nf_y_proj ssn), ⊤) at x
    - y = x: char_0(nf_y_proj ssn) at x (i.e., x itself serves as y)

    When ssn's orders are inconsistent: ⊥. -/
noncomputable def depth0_3var_exist_formula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : Formula :=
  let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
  -- Zone analysis based on y-x order atoms in ssn
  let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  match y_lt_x, x_lt_y with
  | true, true => Formula.bot  -- inconsistent: y < x and x < y
  | true, false => Formula.snce char_y Formula.top  -- y < x: Since at x
  | false, true => Formula.untl char_y Formula.top  -- y > x: Until at x
  | false, false => char_y  -- y = x: check at x itself

/-! ## Enriched Point Type

The enriched point type at x encodes:
1. char_{k+1}(nf_x): x's depth-(k+1) characteristic formula
2. Quantifier profile: conjunction of conditions for each ssn -/

/-- Build the quantifier-profile conjunction for a given nf_x and x-t zone.

    For each ssn : NormalForm sig 0 3 that is xt-compatible (matching nf_x's
    predicates at var 1, parent_atoms at var 2, and the x-t order):
    - If sub_nf.2(ssn) = true: include depth0_3var_exist_formula(ssn)
    - If sub_nf.2(ssn) = false: include ¬depth0_3var_exist_formula(ssn)

    For ssn that are NOT xt-compatible: the condition is vacuously satisfied
    (the atom conditions at x and t already rule out such ssn). -/
noncomputable def quant_profile_conj_depth0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x_gt_t x_lt_t : Bool) : Formula :=
  formula_conjList
    ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms x_gt_t x_lt_t then
        let phi := depth0_3var_exist_formula atomMap h_surj ssn
        if sub_nf.2 ssn then some phi
        else some phi.neg
      else none)

/-- Build the enriched point type for a specific nf_x (depth-1 1-var NF).

    enriched_pt(nf_x) = char_1(nf_x) ∧ quant_profile_conj

    The char_1 part captures x's atom AND quantifier conditions (1-var),
    while quant_profile_conj captures the 3-var conditions relative to t. -/
noncomputable def enriched_point_type_depth0 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool)
    (nf_x : NormalForm sig 1 1)
    (x_gt_t x_lt_t : Bool) : Formula :=
  -- Extract the depth-0 1-var NF from nf_x for predicate matching
  -- nf_x : NormalForm sig 1 1 = (AtomKind sig 1 → Bool) × (NormalForm sig 0 2 → Bool)
  -- nf_x.1 gives the predicate assignment
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  Formula.and (char_1 nf_x)
    (quant_profile_conj_depth0 atomMap h_surj sub_nf nf_x_1var parent_atoms x_gt_t x_lt_t)

/-! ## Enriched Bypass Formula (depth 1, n=1)

The enriched bypass formula for `∃ x, nf_eval_nf M 1 2 [x, t] sub_nf`:

  (∃ nf_x compatible with sub_nf for Until zone:
    Until(enriched_pt(nf_x), ⊤))
  ∨
  (∃ nf_x compatible with Since zone:
    Since(enriched_pt(nf_x), ⊤))
  ∨
  (∃ nf_x compatible with equality zone:
    enriched_pt(nf_x) at t) -/

/-- Check whether a depth-1 1-var NF nf_x is compatible with sub_nf at
    variable 0 (predicates of x must match). -/
noncomputable def nf_x_compat_check {sig : MonadicSignature}
    (sub_nf : NormalForm sig 1 2)
    (nf_x : NormalForm sig 1 1) : Bool :=
  (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    nf_x.1 (.pred p ⟨0, by omega⟩) == sub_nf.1 (.pred p ⟨0, by omega⟩)

/-- The enriched bypass formula for depth 1 (k=0 in the theorem), n=1.

    Disjunction over:
    1. Until zone (t < x): for each compatible nf_x, Until(enriched_pt(nf_x, future), ⊤)
    2. Since zone (x < t): for each compatible nf_x, Since(enriched_pt(nf_x, past), ⊤)
    3. Equality zone (x = t): for each compatible nf_x, enriched_pt(nf_x, eq)

    The zone is determined by sub_nf.1's order atoms (.order 0 1) and (.order 1 0). -/
noncomputable def enriched_bypass_formula_depth1 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  let t_compat := (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    sub_nf.1 (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)
  if ¬t_compat then Formula.bot  -- t's predicates don't match: unsatisfiable
  else
  -- Zone from sub_nf's order atoms
  let x_gt_t := sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))  -- t < x
  let x_lt_t := sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))  -- x < t
  -- Build enriched formulas for each compatible nf_x
  let enriched_for_nf_x := fun nf_x =>
    if nf_x_compat_check sub_nf nf_x then
      some (enriched_point_type_depth0 atomMap h_surj char_1 sub_nf parent_atoms
        nf_x x_gt_t x_lt_t)
    else none
  let enriched_list := (Fintype.elems (α := NormalForm sig 1 1)).val.toList.filterMap
    enriched_for_nf_x
  let enriched_disj := formula_disjList enriched_list
  match x_gt_t, x_lt_t with
  | true, true => Formula.bot  -- Both orders: inconsistent
  | true, false => Formula.untl enriched_disj Formula.top  -- t < x: Until
  | false, true => Formula.snce enriched_disj Formula.top  -- x < t: Since
  | false, false => enriched_disj  -- x = t: evaluate at t

/-! ## Helper lemmas for the correctness proof -/

/-- The t_compat check passes whenever t actually satisfies the parent_atoms
    and there exists x satisfying sub_nf (because sub_nf.1 records t's predicates
    at variable 1, and these must match parent_atoms when t satisfies them). -/
private theorem t_compat_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (t x : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_eval : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf) :
    ((Fintype.elems (α := sig.preds)).val.toList.all fun p =>
      sub_nf.1 (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)) = true := by
  rw [List.all_eq_true]
  intro p _
  rw [beq_iff_eq]
  obtain ⟨h_atom, _⟩ := h_eval
  have h1 := h_atom (.pred p ⟨1, by omega⟩)
  simp only [atom_eval, Fin.cons] at h1
  have h2 := h_atoms (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at h2
  -- Simplify: Fin.cons x (fun _ => t) at index 1 = t
  have h_env1 : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → M.carrier) ⟨1, by omega⟩ = t := by
    simp [Fin.cons]; rfl
  rw [show Fin.cases x (fun _ : Fin 1 => t) ⟨1, by omega⟩ = t from by simp [Fin.cases]; rfl] at h1
  cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
  cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;> simp_all

/-- When nf_eval_nf holds with sub_nf recording t < x (x_gt_t = true) and x < t false,
    the witness x must satisfy t < x. -/
private theorem zone_from_nf_eval
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 1 2)
    (t x : M.carrier)
    (h_eval : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf) :
    (sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true → t < x) ∧
    (sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true → x < t) ∧
    (sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true →
     sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true → False) := by
  obtain ⟨h_atom, _⟩ := h_eval
  refine ⟨fun h => ?_, fun h => ?_, fun h1 h2 => ?_⟩
  · have := (h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h
    simp only [atom_eval, Fin.cons] at this
    exact this
  · have := (h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mpr h
    simp only [atom_eval, Fin.cons] at this
    exact this
  · have ht_lt_x := (h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h1
    have hx_lt_t := (h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mpr h2
    simp only [atom_eval, Fin.cons] at ht_lt_x hx_lt_t
    exact absurd (lt_trans ht_lt_x hx_lt_t) (lt_irrefl t)

/-- The nf_x_compat_check passes for the characteristic NF of x. -/
private theorem nf_x_compat_of_nf_eval
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 1 2)
    (t x : M.carrier)
    (h_eval : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf)
    (nf_x : NormalForm sig 1 1)
    (h_nf_x : nf_eval_nf M 1 1 (fun _ => x) nf_x) :
    nf_x_compat_check sub_nf nf_x = true := by
  simp only [nf_x_compat_check]
  rw [List.all_eq_true]
  intro p _
  rw [beq_iff_eq]
  obtain ⟨h_atom_sub, _⟩ := h_eval
  obtain ⟨h_atom_x, _⟩ := h_nf_x
  have h_sub := h_atom_sub (.pred p ⟨0, by omega⟩)
  have h_x := h_atom_x (.pred p ⟨0, by omega⟩)
  simp only [atom_eval, Fin.cons] at h_sub h_x
  cases h1 : nf_x.1 (.pred p ⟨0, by omega⟩) <;>
  cases h2 : sub_nf.1 (.pred p ⟨0, by omega⟩) <;> simp_all

/-! ## Main Bypass Theorem -/

/-- Enriched bypass for ExistPart(k+1) at n=1: there exists a temporal formula
    characterizing the 2-variable existential at depth k+1 on Prior structures.

    This is the key theorem that fills the sorry at `existPart_succ` for n=1.

    **BLOCKER**: `depth0_3var_exist_formula` loses y-t order information.

    The formula encodes `∃ y, nf_eval_nf M 0 3 (y,x,t) ssn` as a temporal formula
    at x using ONLY y-x order (Since/Until relative to x) and y-predicates. It does
    NOT encode y-t order (y < t vs t < y vs y = t).

    Two ssn values differing only in y-t order produce the SAME temporal formula. If
    `sub_nf.2 ssn_a = true` and `sub_nf.2 ssn_b = false` for such a pair, the
    `quant_profile_conj_depth0` contains both φ and ¬φ, making the enriched formula
    unsound (evaluates to False at x even when sub_nf IS the characteristic of (x,t)).

    Encoding y-t order from position x is impossible with standard temporal operators:
    temporal formulas at x reference points relative to x, not relative to t. Nested
    formulas like `Since(parent_char ∧ Since(char_y, top), top)` find SOME z with
    parent_char (not necessarily t), so the backward direction remains unprovable.

    The fundamental issue: the backward direction requires a Feferman-Vaught composition
    property for Prior structures. This is the SAME blocker as `nf_exist_backward_prior`
    (NfCharFormula.lean:541). The enriched formula bypass does NOT avoid this.

    To resolve: either prove the Prior composition property (generalized Prop 4.2 from
    Rabinovich 2014 for 3-var decomposition), or find an alternative encoding that
    captures y-t order from position x using Prior-UZ/SZ properties. -/
theorem existPart_succ_n1_bypass
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (k : Nat)
    (char_kp1 : NormalForm sig (k + 1) 1 → Formula)
    (char_kp1_correct : ∀ (nf_1 : NormalForm sig (k + 1) 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_kp1 nf_1) ↔
        nf_eval_nf M (k + 1) 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig (k + 1) 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- BLOCKED: enriched_bypass_formula_depth1 is unsound due to y-t order loss.
  -- See BLOCKER documentation above.
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
