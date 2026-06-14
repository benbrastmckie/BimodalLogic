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

/-- (DEFECTIVE v1 — kept for reference, DO NOT USE)
    Build a temporal formula at x for the depth-0 3-var existential.
    UNSOUND: loses y-t order information. See depth0_3var_exist_formula_zone. -/
noncomputable def depth0_3var_exist_formula_v1 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : Formula :=
  let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
  let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  match y_lt_x, x_lt_y with
  | true, true => Formula.bot
  | true, false => Formula.snce char_y Formula.top
  | false, true => Formula.untl char_y Formula.top
  | false, false => char_y

/-! (Zone-aware v2 definitions are placed after the old v1 infrastructure below.) -/

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
        let phi := depth0_3var_exist_formula_v1 atomMap h_surj ssn
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

/-! ## Zone-Aware Enriched Formula (v2)

The v1 formula was defective: it encoded y-x order but NOT y-t order, causing
unsoundness when two ssn values differ only in y-t order but have different
sub_nf.2 values.

The fix distributes y-conditions across the Until/Since structure based on
y's zone relative to BOTH t and x:

For the Until case (t < x), the formula at t is:
  A = pre_conditions_at_t ∧ Until(enriched_point_type_x, interval_guard)

| Zone      | Position in formula    | Encoding                                |
|-----------|------------------------|-----------------------------------------|
| y < t     | pre_conditions_at_t    | P(char_0(nf_y)) or ¬P(char_0(nf_y))   |
| y = t     | pre_conditions_at_t    | char_0(nf_y) direct check               |
| t < y < x | interval_guard (neg)   | ¬char_0(nf_y)                           |
| t < y < x | enriched_pt_x (pos)    | S(char_0(nf_y), ⊤) at x               |
| y = x     | enriched_point_type_x  | char_0(nf_y) direct check               |
| y > x     | enriched_point_type_x  | F(char_0(nf_y)) or ¬F(char_0(nf_y))   |

Each zone maps to a UNIQUE temporal position, so y-t order is faithfully encoded. -/

/-- Zone classification for a 3-var depth-0 NF ssn (Until direction: t < x).
    Variables: 0=y, 1=x, 2=t. -/
inductive YZone where
  | below_t      -- y < t
  | eq_t         -- y = t
  | between_tx   -- t < y < x
  | eq_x         -- y = x
  | above_x      -- y > x
  | inconsistent -- contradictory order
  deriving DecidableEq, Repr

/-- Classify the zone of y from a 3-var depth-0 NF ssn (Until direction).
    Variables: 0=y, 1=x, 2=t. -/
noncomputable def ssn_zone_until {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : YZone :=
  let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  let y_lt_t := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
  let t_lt_y := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
  if y_lt_x && x_lt_y then .inconsistent
  else if y_lt_t && t_lt_y then .inconsistent
  else if y_lt_t then .below_t
  else if !y_lt_t && !t_lt_y then
    if y_lt_x || (!y_lt_x && !x_lt_y) then .eq_t
    else .inconsistent
  else if t_lt_y && y_lt_x then .between_tx
  else if t_lt_y && !y_lt_x && !x_lt_y then .eq_x
  else if t_lt_y && x_lt_y then .above_x
  else .inconsistent

/-- Pre-conditions at t for the Until direction.
    Handles y < t and y = t zones. -/
noncomputable def pre_conditions_at_t_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  formula_conjList
    ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
        let zone := ssn_zone_until ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .below_t =>
          if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
          else some (Formula.snce char_y Formula.top).neg
        | .eq_t =>
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | _ => none
      else none)

/-- Interval guard for the Until direction (between t and x).
    Handles negative conditions for t < y < x zone. -/
noncomputable def interval_guard_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  formula_conjList
    ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
        let zone := ssn_zone_until ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .between_tx =>
          if sub_nf.2 ssn then none
          else some char_y.neg
        | _ => none
      else none)

/-- Enriched point type at x for the Until direction.
    Handles y = x, y > x, and positive t < y < x zones. -/
noncomputable def enriched_point_type_x_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (nf_x : NormalForm sig 1 1)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  let quant_conjuncts :=
    (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
        let zone := ssn_zone_until ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .eq_x =>
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | .above_x =>
          if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
          else some (Formula.untl char_y Formula.top).neg
        | .between_tx =>
          if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
          else none
        | _ => none
      else none
  Formula.and (char_1 nf_x) (formula_conjList quant_conjuncts)

/-- Zone-aware enriched bypass formula for depth 1, Until direction (t < x).
    For each compatible nf_x:
      pre_conditions_at_t ∧ Until(enriched_point_type_x, interval_guard) -/
noncomputable def enriched_bypass_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  formula_disjList
    ((Fintype.elems (α := NormalForm sig 1 1)).val.toList.filterMap fun nf_x =>
      if nf_x_compat_check sub_nf nf_x then
        let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h
        let pre := pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms
        let guard := interval_guard_until atomMap h_surj sub_nf nf_x_1var parent_atoms
        let pt_x := enriched_point_type_x_until atomMap h_surj char_1 sub_nf nf_x
          nf_x_1var parent_atoms
        some (Formula.and pre (Formula.untl pt_x guard))
      else none)

/-- Zone-aware enriched bypass formula for depth 1, Since direction (x < t).
    Mirror of enriched_bypass_until. -/
noncomputable def enriched_bypass_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  -- For Since direction (x < t), the roles of t and x swap in the zone analysis.
  -- We reuse the VecEA2 framework: the existential ∃ x < t is captured by Since.
  -- The zone-aware encoding mirrors the Until direction with swapped endpoints.
  formula_disjList
    ((Fintype.elems (α := NormalForm sig 1 1)).val.toList.filterMap fun nf_x =>
      if nf_x_compat_check sub_nf nf_x then
        let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h
        -- For x < t: zones relative to x (left) and t (right)
        -- y < x: below_x -> handled at x via Since
        -- x < y < t: between -> interval guard
        -- y > t: above_t -> handled at t
        -- For now, use a simple encoding via pre_conditions + Since
        let pre_at_t :=
          formula_conjList
            ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
              if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
                let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
                let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
                let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
                let y_lt_t := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
                let t_lt_y := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
                -- y > t zone: handled at t
                if t_lt_y then
                  if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
                  else some (Formula.untl char_y Formula.top).neg
                -- y = t zone: handled at t
                else if !y_lt_t && !t_lt_y then
                  if sub_nf.2 ssn then some char_y
                  else some char_y.neg
                else none
              else none)
        let guard :=
          formula_conjList
            ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
              if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
                let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
                let y_lt_t := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
                let t_lt_y := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
                let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
                let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
                -- x < y < t zone: interval guard
                if x_lt_y && y_lt_t then
                  if sub_nf.2 ssn then none
                  else some char_y.neg
                else none
              else none)
        let pt_x :=
          let quant_conjuncts :=
            (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
              if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
                let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
                let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
                let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
                let y_lt_t := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
                let t_lt_y := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
                -- y = x zone
                if !y_lt_x && !x_lt_y then
                  if sub_nf.2 ssn then some char_y
                  else some char_y.neg
                -- y < x zone: below x
                else if y_lt_x then
                  if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
                  else some (Formula.snce char_y Formula.top).neg
                -- x < y < t: positive interval -> Until at x
                else if x_lt_y && y_lt_t then
                  if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
                  else none
                else none
              else none
          Formula.and (char_1 nf_x) (formula_conjList quant_conjuncts)
        some (Formula.and pre_at_t (Formula.snce pt_x guard))
      else none)

/-- Zone-aware enriched bypass formula for depth 1, equality direction (x = t). -/
noncomputable def enriched_bypass_eq {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  -- When x = t, the enriched point type is evaluated at t directly.
  -- All ssn zones collapse: y < t (Since), y = t (direct), y > t (Until).
  formula_disjList
    ((Fintype.elems (α := NormalForm sig 1 1)).val.toList.filterMap fun nf_x =>
      if nf_x_compat_check sub_nf nf_x then
        let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h
        let quant_conjuncts :=
          (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
            if ssn_xt_compatible ssn nf_x_1var parent_atoms false false then
              let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
              let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
              let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
              -- When x = t, y-x order = y-t order, so no ambiguity
              if y_lt_x then  -- y < x = t
                if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
                else some (Formula.snce char_y Formula.top).neg
              else if x_lt_y then  -- y > x = t
                if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
                else some (Formula.untl char_y Formula.top).neg
              else  -- y = x = t
                if sub_nf.2 ssn then some char_y
                else some char_y.neg
            else none
        some (Formula.and (char_1 nf_x) (formula_conjList quant_conjuncts))
      else none)

/-- The full zone-aware enriched bypass formula for depth 1.
    Handles all three x-t zones. -/
noncomputable def enriched_bypass_formula_zone {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  let t_compat := (Fintype.elems (α := sig.preds)).val.toList.all fun p =>
    sub_nf.1 (.pred p ⟨1, by omega⟩) == parent_atoms (.pred p ⟨0, by omega⟩)
  if ¬t_compat then Formula.bot
  else
  let x_gt_t := sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  let x_lt_t := sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  match x_gt_t, x_lt_t with
  | true, true => Formula.bot
  | true, false => enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms
  | false, true => enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms
  | false, false => enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms

/-! ## Main Bypass Theorem (Zone-Aware) -/

/-- Zone-aware enriched bypass for depth 1 (k=0): the 2-var existential at depth 1
    has a temporal formula characterization on Prior structures.

    At depth 1 (k=0 inner), the 3-var quantifier conditions are at depth 0
    (purely atomic), so the zone-aware encoding uses nf_depth0_char_formula
    for y's characteristic. The zone distribution across Until/Since avoids
    the y-t order loss of the v1 formula. -/
theorem existPart_succ_n1_bypass_k0
    {sig : MonadicSignature} (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (char_1_correct : ∀ (nf_1 : NormalForm sig 1 1)
        (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        temporal_truth M atomMap t (char_1 nf_1) ↔
        nf_eval_nf M 1 1 (fun _ => t) nf_1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Use the zone-aware enriched bypass formula
  refine ⟨enriched_bypass_formula_zone atomMap h_surj char_1 sub_nf parent_atoms, ?_⟩
  intro M h_UZ h_SZ t h_atoms
  sorry

/-- General enriched bypass for ExistPart(k+1) at n=1.
    Delegates to existPart_succ_n1_bypass_k0 for k=0 and uses sorry for k>0. -/
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
  cases k with
  | zero =>
    exact existPart_succ_n1_bypass_k0 atomMap h_surj char_kp1 char_kp1_correct parent_atoms sub_nf
  | succ k' =>
    -- General k > 0: requires depth-k' IH for 3-var conditions
    sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
