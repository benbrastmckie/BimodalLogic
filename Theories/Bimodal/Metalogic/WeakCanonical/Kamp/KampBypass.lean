import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
import Bimodal.Metalogic.WeakCanonical.Kamp.ZoneBridge
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.PriorDefs
import Mathlib.Data.Finset.Sort
import Mathlib.GroupTheory.Perm.Fin

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

-- ssn_order_consistent and ssn_order_consistent_of_eval have been moved to
-- ZoneBridge.lean to break the circular import chain:
-- KampForward -> NfCharFormula -> KampBypass.
-- They are now available via `import ZoneBridge`.

/-! ## Depth-0 3-var Existential Formula

At depth 0, `∃ y, nf_eval_nf M 0 3 [y,x,t] ssn` is purely atomic:
predicates at y,x,t plus order relations. We encode this as a temporal
formula evaluated at x, using Since/Until to find y in the right zone. -/

/-- For a depth-0 3-var NF ssn, check whether ssn's constraints on variables
    1 (x) and 2 (t) are compatible with a given 1-var NF for x, parent_atoms
    for t, and a specific x-t order (x > t, x < t, or x = t).

    x_gt_t = true means we require t < x (Until zone).
    x_lt_t = true means we require x < t (Since zone).

    Also checks `ssn_order_consistent` to reject unrealizable 3-variable
    order assignments (antisymmetry, transitivity, equality consistency). -/
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
  (ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) == x_lt_t) &&
  -- Reject unrealizable 3-variable order assignments
  ssn_order_consistent ssn

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

/-- Build a VecEA2 for the Until direction (t < x) and a specific nf_x.

    Uses the VecEA2 bracket infrastructure to correctly handle the positive
    between_tx zone. Bracket witnesses are BETWEEN t and x by construction,
    avoiding the backward-direction issue of Since(char_y, top) at x.

    Structure:
    - endpointLeft(t) = pre_conditions (y < t, y = t zones)
    - endpointRight(x) = char_1(nf_x) ∧ conditions for y = x, y > x zones
    - bracket(t, x) = positive between_tx witnesses + negative segment guards -/
noncomputable def enriched_vecEA2_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (nf_x : NormalForm sig 1 1)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : List (Σ n, VecEA2 n) :=
  -- Collect negative between_tx ssns (need segment guards)
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) &&
    !sub_nf.2 ssn
  -- Collect positive between_tx ssns (become bracket witnesses)
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) &&
    sub_nf.2 ssn
  -- Build the segment guard: conjunction of neg char_y for negative between_tx ssns
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  -- Per-permutation bracket construction:
  -- For each permutation σ of Fin k, build a VecEA2 where pointTypes[i] = char_y(pos_between[σ(i)]).
  -- In the backward direction, the model determines which permutation to use (based on witness ordering).
  -- In the forward direction, any permutation gives per-SSN witnesses directly.
  let k := pos_between.length
  -- Build the endpoint left (at t): pre-conditions for y < t and y = t
  let endLeft : TemporalPred :=
    ⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  -- Build the endpoint right (at x): char_1(nf_x) + conditions for y = x, y > x
  -- Positive between_tx is handled by bracket witnesses, NOT Since formulas.
  let right_conjuncts :=
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
        | _ => none
      else none
  let endRight : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList right_conjuncts)⟩
  (Fintype.elems (α := Equiv.Perm (Fin k))).val.toList.map fun σ =>
    let bracket : BracketFormula k :=
      { pointTypes := fun i =>
          ⟨nf_depth0_char_formula atomMap h_surj (nf_y_proj (pos_between.get (σ i)))⟩
        segmentTypes := fun _ => seg_guard }
    ⟨k, VecEA2.mk endLeft endRight bracket⟩

/-- Zone-aware enriched bypass formula for depth 1, Until direction (t < x).
    Uses VecEA2 brackets for between_tx zone to ensure witnesses are between t and x.
    Disjunction over all compatible nf_x values. -/
noncomputable def enriched_bypass_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  let vvec : VVecEA2 :=
    { disjuncts := (Fintype.elems (α := NormalForm sig 1 1)).val.toList.flatMap fun nf_x =>
        if nf_x_compat_check sub_nf nf_x then
          let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h
          enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms
        else [] }
  vvec.translateLeft

/-- Classify the zone of y from a 3-var depth-0 NF ssn (Since direction).
    Variables: 0=y, 1=x, 2=t, with x < t.
    Mirror of ssn_zone_until with swapped endpoint roles. -/
noncomputable def ssn_zone_since {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : YZone :=
  let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  let y_lt_t := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
  let t_lt_y := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
  if y_lt_x && x_lt_y then .inconsistent
  else if y_lt_t && t_lt_y then .inconsistent
  -- Since direction: x < t, zones relative to x (left) and t (right)
  -- below_t = y < x (below the existential witness)
  else if y_lt_x then .below_t
  -- eq_t = y = x (at the existential witness)
  else if !y_lt_x && !x_lt_y then
    if y_lt_t || (!y_lt_t && !t_lt_y) then .eq_t
    else .inconsistent
  -- between_tx = x < y < t (between witness and evaluation point)
  else if x_lt_y && y_lt_t then .between_tx
  -- eq_x = y = t (at the evaluation point)
  else if !y_lt_t && !t_lt_y && x_lt_y then .eq_x
  -- above_x = y > t (above the evaluation point)
  else if t_lt_y then .above_x
  else .inconsistent

/-- Pre-conditions at t for the Since direction.
    Handles y > t and y = t zones (conditions checked at the evaluation point t). -/
noncomputable def pre_conditions_at_t_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  formula_conjList
    ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
        let zone := ssn_zone_since ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .above_x =>  -- y > t: handled via Until at t
          if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
          else some (Formula.untl char_y Formula.top).neg
        | .eq_x =>     -- y = t: direct check at t
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | _ => none
      else none)

/-- Build a VecEA2 for the Since direction (x < t) and a specific nf_x.

    Uses the VecEA2 bracket infrastructure to correctly handle the positive
    between_xt zone. Bracket witnesses are BETWEEN x and t by construction,
    avoiding the unbounded Until(char_y, top) flaw.

    Structure:
    - endpointRight(t) = pre_conditions (y > t, y = t zones)
    - endpointLeft(x) = char_1(nf_x) ∧ conditions for y = x, y < x zones
    - bracket(x, t) = positive between_xt witnesses + negative segment guards -/
noncomputable def enriched_vecEA2_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (nf_x : NormalForm sig 1 1)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) : List (Σ n, VecEA2 n) :=
  -- Collect negative between_xt ssns (need segment guards)
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms false true &&
    (ssn_zone_since ssn == .between_tx) &&
    !sub_nf.2 ssn
  -- Collect positive between_xt ssns (become bracket witnesses)
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms false true &&
    (ssn_zone_since ssn == .between_tx) &&
    sub_nf.2 ssn
  -- Build the segment guard: conjunction of neg char_y for negative between_xt ssns
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  let k := pos_between.length
  -- Build the endpoint right (at t): pre-conditions for y > t and y = t
  let endRight : TemporalPred :=
    ⟨pre_conditions_at_t_since atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  -- Build the endpoint left (at x): char_1(nf_x) + conditions for y = x, y < x
  -- Positive between_xt is handled by bracket witnesses, NOT Until formulas.
  let left_conjuncts :=
    (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms false true then
        let zone := ssn_zone_since ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .eq_t =>     -- y = x: direct check at x
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | .below_t =>  -- y < x: handled via Since at x
          if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
          else some (Formula.snce char_y Formula.top).neg
        | _ => none
      else none
  let endLeft : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList left_conjuncts)⟩
  (Fintype.elems (α := Equiv.Perm (Fin k))).val.toList.map fun σ =>
    let bracket : BracketFormula k :=
      { pointTypes := fun i =>
          ⟨nf_depth0_char_formula atomMap h_surj (nf_y_proj (pos_between.get (σ i)))⟩
        segmentTypes := fun _ => seg_guard }
    ⟨k, VecEA2.mk endLeft endRight bracket⟩

/-- Zone-aware enriched bypass formula for depth 1, Since direction (x < t).
    Uses VecEA2 brackets for between_xt zone to ensure witnesses are between x and t.
    Disjunction over all compatible nf_x values.
    Mirror of enriched_bypass_until using VVecEA2.translateRight. -/
noncomputable def enriched_bypass_since {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  let vvec : VVecEA2 :=
    { disjuncts := (Fintype.elems (α := NormalForm sig 1 1)).val.toList.flatMap fun nf_x =>
        if nf_x_compat_check sub_nf nf_x then
          let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h
          enriched_vecEA2_since atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms
        else [] }
  vvec.translateRight

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

/-! ## Helper: witness must equal t when both orders are false -/

private theorem witness_eq_t_of_no_order {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (sub_nf : NormalForm sig 1 2) (t x : M.carrier)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_eval : nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf) :
    x = t := by
  obtain ⟨h_atom, _⟩ := h_eval
  by_contra h_ne
  rcases lt_or_gt_of_ne h_ne with h' | h'
  · have := (h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))).mp
    simp only [atom_eval, Fin.cons] at this
    exact Bool.noConfusion (h_lt ▸ this h')
  · have := (h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mp
    simp only [atom_eval, Fin.cons] at this
    exact Bool.noConfusion (h_gt ▸ this h')

/-! ## Eq-case order consistency

When ssn_xt_compatible ... false false = true, the equality consistency
clause gives yx = yt and xy = ty. -/

set_option maxHeartbeats 1600000 in
private theorem eq_case_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true) :
    ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
      ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
      ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) := by
  -- Extract xt and tx from compatibility
  have h1 : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true := h_compat
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h1
  have h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := h1.1.2
  have h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := h1.1.1.2
  refine ⟨h_xt, h_tx, ?_, ?_⟩
  all_goals {
    have h_consist : ssn_order_consistent ssn = true := h1.2
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_consist
    have h_last := h_consist.2
    rcases h_last with ⟨h | h⟩ | h_eq
    · simp_all
    · simp_all
    · first | exact h_eq.1 | exact h_eq.2
  }

/-! ## Eq-case zone bridges (x = t)

When x = t, the 3-var existential ∃ y, nf_eval_nf M 0 3 [y,t,t] ssn
has three zones: y < t (Since), y = t (direct), y > t (Until).
Unlike the Until/Since zone bridges, these do NOT require t < x. -/

/-- Eq-case zone bridge for y < t: Since(char_y, top) at t ↔ ∃ y, nf_eval with y < t. -/
private theorem eq_case_zone_below
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (parent_atoms : AtomKind sig 1 → Bool)
    (t : M.carrier)
    -- ssn says y < x (= y < t since x=t)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    -- ssn says ¬(x < y)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    -- ssn says x = t orders
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- x-pred matches t-pred in ssn (from eq_case_orders)
    (h_yx_eq_yt : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
                  ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)))
    (h_xy_eq_ty : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
                  ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))
    -- t predicates match ssn at var 1 and var 2
    (h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) := by
  -- h_yx = true, so h_yt = true (from h_yx_eq_yt)
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    rw [← h_yx_eq_yt]; exact h_yx
  -- h_xy = false, so h_ty = false (from h_xy_eq_ty)
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    rw [← h_xy_eq_ty]; exact h_xy
  constructor
  · -- Forward: Since(char_y, top) at t → ∃ y, nf_eval
    intro ⟨y, h_y_lt_t, h_char_y, _⟩
    refine ⟨y, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    apply reconstruct_nf_eval_3var M ssn y t t
    · exact h_char_y
    · exact h_t_pred_1
    · exact h_t_pred_2
    · -- y < x (= t) ↔ true
      exact ⟨fun _ => h_yx, fun _ => h_y_lt_t⟩
    · -- y < t ↔ true
      exact ⟨fun _ => h_yt, fun _ => h_y_lt_t⟩
    · -- x (= t) < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · -- x < t ↔ false (x = t)
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ false
      constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · -- t < x ↔ false (x = t)
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
  · -- Backward: ∃ y, nf_eval → Since(char_y, top) at t
    intro ⟨y, h_nf⟩
    have h_y_lt_t : y < t := by
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_yt
    refine ⟨y, h_y_lt_t, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    rw [nf_depth0_char_formula_correct]
    exact extract_y_preds M ssn y t t h_nf

/-- Eq-case zone bridge for y > t: Until(char_y, top) at t ↔ ∃ y, nf_eval with y > t. -/
private theorem eq_case_zone_above
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (parent_atoms : AtomKind sig 1 → Bool)
    (t : M.carrier)
    -- ssn says x < y (= t < y since x=t)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    -- ssn says ¬(y < x)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- ssn says x = t orders
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- order consistency between vars 0,1 and vars 0,2 (from eq_case_orders)
    (h_yx_eq_yt : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
                  ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)))
    (h_xy_eq_ty : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
                  ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))
    -- t predicates match ssn at var 1 and var 2
    (h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) := by
  -- h_xy = true, so h_ty = true
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
    rw [← h_xy_eq_ty]; exact h_xy
  -- h_yx = false, so h_yt = false
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
    rw [← h_yx_eq_yt]; exact h_yx
  constructor
  · -- Forward: Until(char_y, top) at t → ∃ y, nf_eval
    intro ⟨y, h_t_lt_y, h_char_y, _⟩
    refine ⟨y, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    apply reconstruct_nf_eval_3var M ssn y t t
    · exact h_char_y
    · exact h_t_pred_1
    · exact h_t_pred_2
    · -- y < x (= t) ↔ false
      constructor
      · intro h; exact absurd (lt_trans h h_t_lt_y) (lt_irrefl _)
      · intro h; simp_all
    · -- y < t ↔ false
      constructor
      · intro h; exact absurd (lt_trans h h_t_lt_y) (lt_irrefl _)
      · intro h; simp_all
    · -- x (= t) < y ↔ true
      exact ⟨fun _ => h_xy, fun _ => h_t_lt_y⟩
    · -- x < t ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
    · -- t < y ↔ true
      exact ⟨fun _ => h_ty, fun _ => h_t_lt_y⟩
    · -- t < x ↔ false
      constructor
      · intro h; exact absurd h (lt_irrefl _)
      · intro h; simp_all
  · -- Backward: ∃ y, nf_eval → Until(char_y, top) at t
    intro ⟨y, h_nf⟩
    have h_t_lt_y : t < y := by
      have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_ty
    refine ⟨y, h_t_lt_y, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    rw [nf_depth0_char_formula_correct]
    exact extract_y_preds M ssn y t t h_nf

/-- Eq-case zone bridge for y = t: char_y at t ↔ ∃ y, nf_eval with y = t. -/
private theorem eq_case_zone_eq
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (parent_atoms : AtomKind sig 1 → Bool)
    (t : M.carrier)
    -- ssn says y = x (both orders false)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    -- ssn says x = t orders
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    -- order consistency
    (h_yx_eq_yt : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) =
                  ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)))
    (h_xy_eq_ty : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) =
                  ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)))
    -- t predicates match ssn at var 1 and var 2
    (h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true)
    (h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons t (fun _ => t))) ssn) := by
  -- y = t since ¬(y<x) ∧ ¬(x<y) and x=t
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
    rw [← h_yx_eq_yt]; exact h_yx
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    rw [← h_xy_eq_ty]; exact h_xy
  constructor
  · -- Forward: char_y at t → ∃ y, nf_eval (use y = t)
    intro h_char
    refine ⟨t, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char
    apply reconstruct_nf_eval_3var M ssn t t t
    · exact h_char
    · exact h_t_pred_1
    · exact h_t_pred_2
    · -- y < x (= t < t) ↔ h_yx = true: both sides false
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- y < t (= t < t) ↔ h_yt = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- x < y (= t < t) ↔ h_xy = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- x < t (= t < t) ↔ h_xt = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- t < y (= t < t) ↔ h_ty = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
    · -- t < x (= t < t) ↔ h_tx = true
      exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
  · -- Backward: ∃ y, nf_eval → char_y at t
    intro ⟨y, h_nf⟩
    -- y = t
    have h_not_yt : ¬(y < t) := by
      intro h
      have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_not_ty : ¬(t < y) := by
      intro h
      have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact absurd (h_ord.mp h) (by simp_all)
    have h_eq : y = t := le_antisymm (le_of_not_gt h_not_ty) (le_of_not_gt h_not_yt)
    subst h_eq
    rw [nf_depth0_char_formula_correct]
    exact extract_y_preds M ssn y y y h_nf

/-! ## Equality Case: Core Biconditional -/

/-- Extract t-predicate hypotheses for ssn from h_atoms and h_t_compat.
    Given that h_atoms : ∀ a, atom_eval M [t] a ↔ parent_atoms a = true
    and h_t_compat : sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)
    and ssn_xt_compatible ssn ... false false = true (which gives ssn (.pred p 2) = parent_atoms (.pred p 0)),
    we derive M.interp p t ↔ ssn (.pred p 1) = true and M.interp p t ↔ ssn (.pred p 2) = true. -/
private theorem eq_case_t_pred_1
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (parent_atoms : AtomKind sig 1 → Bool)
    (sub_nf : NormalForm sig 1 2)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (nf_x : NormalForm sig 1 1)
    (h_nf_x : nf_eval_nf M 1 1 (fun _ => t) nf_x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true)
    (h_nf_x_1var_def : ∀ p, nf_x_1var (.pred p ⟨0, by omega⟩) =
      nf_x.1 (.pred p ⟨0, by omega⟩)) :
    ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true := by
  intro p
  -- ssn_xt_compatible gives ssn (.pred p 1) = nf_x_1var (.pred p 0)
  have h1 : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true := h_compat
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h1
  have h_x_pred := h1.1.1.1.1 p (Multiset.mem_toList.mpr (Fintype.complete p))
  -- nf_x_1var (.pred p 0) = nf_x.1 (.pred p 0)
  rw [h_nf_x_1var_def p] at h_x_pred
  -- From h_nf_x: atom_eval M [t] (.pred p 0) ↔ nf_x.1 (.pred p 0) = true
  obtain ⟨h_atom_x, _⟩ := h_nf_x
  have h_eval_p := h_atom_x (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at h_eval_p
  simp only [h_x_pred]
  exact h_eval_p

private theorem eq_case_t_pred_2
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (parent_atoms : AtomKind sig 1 → Bool)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true) :
    ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
  intro p
  have h1 : ssn_xt_compatible ssn nf_x_1var parent_atoms false false = true := h_compat
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h1
  have h_t_pred := h1.1.1.1.2 p (Multiset.mem_toList.mpr (Fintype.complete p))
  have h_par := h_atoms (.pred p ⟨0, by omega⟩)
  simp only [atom_eval] at h_par
  simp only [h_t_pred]; exact h_par

set_option maxHeartbeats 12800000 in
/-- Core biconditional for the eq case: enriched_bypass_eq ↔ ∃ x, nf_eval with x = t. -/
private theorem eq_case_iff
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_pred_compat : ∀ p : sig.preds,
        sub_nf.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨1, by omega⟩))
    (h_t_compat : ∀ p : sig.preds,
        sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    -- All ssn with sub_nf.2 = true must be compatible with the reference nf_x_1var
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
        parent_atoms false false = true) :
    temporal_truth M atomMap t (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms) ↔
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  constructor
  · -- Forward (mp): formula truth → ∃ x, nf_eval
    -- We first reduce to showing ∃ x = t, then both atom and quant parts.
    -- The formula unfolding is done once:
    intro h_formula
    show ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
    -- For any realizable witness x, x = t (by witness_eq_t_of_no_order).
    -- So we provide t and prove nf_eval at [t, t].
    -- Unfold the formula to get the disjunct.
    have h_formula' := h_formula
    show ∃ x, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
    simp only [enriched_bypass_eq] at h_formula'
    rw [formula_disjList_iff] at h_formula'
    obtain ⟨φ, h_mem, h_truth⟩ := h_formula'
    rw [List.mem_filterMap] at h_mem
    obtain ⟨nf_x, _, h_some⟩ := h_mem
    split_ifs at h_some with h_compat_nfx
    · have h_eq_φ := Option.some_injective _ h_some; subst h_eq_φ
      rw [temporal_truth_and] at h_truth
      obtain ⟨h_char1, h_conj⟩ := h_truth
      have h_nf_x := (char_1_correct nf_x M h_UZ h_SZ t).mp h_char1
      -- Witness is t.
      refine ⟨t, ?_, ?_⟩
      · -- Atom part: ∀ a, atom_eval M [t,t] a ↔ sub_nf.1 a = true
        intro a
        match a with
        | .pred p ⟨0, _⟩ =>
          simp only [atom_eval, Fin.cons]
          have h_par := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h_par
          rw [h_pred_compat p, h_t_compat p]
          exact h_par
        | .pred p ⟨1, _⟩ =>
          simp only [atom_eval, Fin.cons]
          have h_par := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval] at h_par
          rw [h_t_compat p]
          exact h_par
        | .order ⟨0, _⟩ ⟨1, _⟩ h_ne =>
          simp only [atom_eval, Fin.cons]
          exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
        | .order ⟨1, _⟩ ⟨0, _⟩ h_ne =>
          simp only [atom_eval, Fin.cons]
          exact ⟨fun h => absurd h (lt_irrefl _), fun h => by simp_all⟩
        | .order ⟨0, _⟩ ⟨0, _⟩ h_ne => exact absurd rfl h_ne
        | .order ⟨1, _⟩ ⟨1, _⟩ h_ne => exact absurd rfl h_ne
      · -- Quant part: ∀ ssn, (∃ y, nf_eval 0 3 [y,t,t] ssn) ↔ sub_nf.2 ssn
        intro ssn
        -- nf_x_1var from nf_x agrees with ref_nf_x_1var from sub_nf via h_compat_nfx
        have h_nfx_eq : ∀ p : sig.preds,
            nf_x.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨0, by omega⟩) := by
          intro p
          have h := h_compat_nfx
          simp only [nf_x_compat_check, List.all_eq_true, beq_iff_eq] at h
          exact h p (Multiset.mem_toList.mpr (Fintype.complete p))
        -- So ssn_xt_compatible with nf_x_1var ↔ ssn_xt_compatible with ref_nf_x_1var
        have h_compat_equiv : ∀ ssn' : NormalForm sig 0 3,
            ssn_xt_compatible ssn' (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              parent_atoms false false =
            ssn_xt_compatible ssn' (fun a => match a with
              | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              parent_atoms false false := by
          intro ssn'
          congr 1
          funext a
          match a with
          | .pred q _ => exact h_nfx_eq q
          | .order i j h => rfl
        by_cases h_ssn_xt_compat : ssn_xt_compatible ssn
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms false false = true
        · -- Compatible ssn: use zone bridges via h_conj
          rw [formula_conjList_iff] at h_conj
          obtain ⟨h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty⟩ := eq_case_orders ssn
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms h_ssn_xt_compat
          have h_t_pred_1 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true :=
            eq_case_t_pred_1 M parent_atoms sub_nf ssn
              (fun a => match a with
                | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
                | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              t h_atoms nf_x h_nf_x h_ssn_xt_compat (fun _ => rfl)
          have h_t_pred_2 : ∀ p, M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true :=
            eq_case_t_pred_2 M parent_atoms ssn
              (fun a => match a with
                | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
                | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
              t h_atoms h_ssn_xt_compat
          -- Determine zone and apply appropriate bridge
          by_cases h_y_lt_x : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true
          · -- y < x zone: Since bridge
            have h_xy_false : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
              by_contra h_both
              push_neg at h_both
              simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq] at h_ssn_xt_compat
              have h_oc := h_ssn_xt_compat.2
              simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true',
                Bool.or_eq_true, Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_oc
              cases h_both_val : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;> simp_all
            have h_zone := eq_case_zone_below M atomMap h_surj ssn parent_atoms t
              h_y_lt_x h_xy_false h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2
            -- Extract the formula for this ssn from h_conj
            cases h_sub : sub_nf.2 ssn
            · -- sub_nf.2 ssn = false: formula is neg(Since), need ¬∃ y
              simp only [eq_iff_iff]; constructor
              · intro ⟨y, hy⟩
                apply absurd (h_zone.mpr ⟨y, hy⟩)
                show temporal_truth M atomMap t ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).snce Formula.top).neg
                apply h_conj
                apply List.mem_filterMap.mpr
                exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
              · intro h; simp_all
            · -- sub_nf.2 ssn = true: formula is Since, need ∃ y
              have h_formula_true : temporal_truth M atomMap t
                  ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).snce Formula.top) := by
                apply h_conj
                apply List.mem_filterMap.mpr
                exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
              simp only [eq_iff_iff, h_sub, iff_true]
              exact h_zone.mp h_formula_true
          · by_cases h_x_lt_y : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true
            · -- x < y zone: Until bridge
              have h_zone := eq_case_zone_above M atomMap h_surj ssn parent_atoms t
                h_x_lt_y (Bool.eq_false_iff.mpr h_y_lt_x)
                h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2
              cases h_sub : sub_nf.2 ssn
              · simp only [eq_iff_iff]; constructor
                · intro ⟨y, hy⟩
                  apply absurd (h_zone.mpr ⟨y, hy⟩)
                  show temporal_truth M atomMap t ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).untl Formula.top).neg
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                · intro h; simp_all
              · have h_formula_true : temporal_truth M atomMap t
                    ((nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).untl Formula.top) := by
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                simp only [eq_iff_iff, h_sub, iff_true]
                exact h_zone.mp h_formula_true
            · -- y = x zone: direct bridge
              have h_zone := eq_case_zone_eq M atomMap h_surj ssn parent_atoms t
                (Bool.eq_false_iff.mpr h_y_lt_x)
                (Bool.eq_false_iff.mpr h_x_lt_y)
                h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2
              cases h_sub : sub_nf.2 ssn
              · simp only [eq_iff_iff]; constructor
                · intro ⟨y, hy⟩
                  apply absurd (h_zone.mpr ⟨y, hy⟩)
                  show temporal_truth M atomMap t (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                · intro h; simp_all
              · have h_formula_true : temporal_truth M atomMap t
                    (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) := by
                  apply h_conj
                  apply List.mem_filterMap.mpr
                  exact ⟨ssn, Multiset.mem_toList.mpr (Fintype.complete ssn), by simp_all⟩
                simp only [eq_iff_iff, h_sub, iff_true]
                exact h_zone.mp h_formula_true
        · -- Incompatible ssn: both sides false
          constructor
          · -- ∃ y, nf_eval → sub_nf.2 ssn = true
            intro ⟨y, h_ssn_eval⟩
            -- From h_ssn_eval, derive ssn_xt_compatible, contradicting h_ssn_xt_compat
            exfalso; apply h_ssn_xt_compat
            simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
            refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
            · -- x-preds: ssn (.pred p 1) = nf_x.1 (.pred p 0)
              intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨1, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
              have h2 : M.interp p t ↔ nf_x.1 (.pred p ⟨0, by omega⟩) = true := by
                have h := h_nf_x.1 (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
              cases h1v : ssn (.pred p ⟨1, by omega⟩) <;>
              cases h2v : nf_x.1 (.pred p ⟨0, by omega⟩) <;> simp_all
            · -- t-preds: ssn (.pred p 2) = parent_atoms (.pred p 0)
              intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
              have h2 : M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
                have h := h_atoms (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
              cases h1v : ssn (.pred p ⟨2, by omega⟩) <;>
              cases h2v : parent_atoms (.pred p ⟨0, by omega⟩) <;> simp_all
            · -- t > x order: ssn (.order 2 1) = false (t < t)
              have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
              unfold atom_eval at h
              cases hv : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
              · rfl
              · exact absurd (h.mpr hv) (lt_irrefl _)
            · -- x > t order: ssn (.order 1 2) = false (t < t)
              have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
              unfold atom_eval at h
              cases hv : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
              · rfl
              · exact absurd (h.mpr hv) (lt_irrefl _)
            · exact ssn_order_consistent_of_eval ssn h_ssn_eval
          · -- sub_nf.2 ssn = true → ∃ y, nf_eval: contradict with h_ssn_compat
            intro h_sub_true
            -- h_ssn_compat gives ssn_xt_compatible ssn ref_nf_x_1var ... = true
            have h_ref_compat := h_ssn_compat ssn h_sub_true
            -- ref_nf_x_1var and nf_x_1var agree, so ssn_xt_compatible should agree
            rw [h_compat_equiv ssn] at h_ssn_xt_compat
            exact absurd h_ref_compat h_ssn_xt_compat
  · -- Backward (mpr): ∃ x, nf_eval → formula truth
    intro ⟨x, h_eval⟩
    have h_x_eq := witness_eq_t_of_no_order M sub_nf t x h_gt h_lt h_eval
    subst h_x_eq
    -- After subst: t eliminated, x survives. Goal: temporal_truth M atomMap x (enriched_bypass_eq ...)
    let nf_x := nf_characteristic M 1 1 (fun _ => x)
    have h_nf_x := nf_characteristic_satisfies M 1 1 (fun _ => x)
    have h_compat := nf_x_compat_of_nf_eval M sub_nf x x h_eval nf_x h_nf_x
    show temporal_truth M atomMap x (enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms)
    unfold enriched_bypass_eq
    rw [formula_disjList_iff]
    -- Show the disjunct for nf_x is in the list and true.
    -- Step 1: membership in filterMap via nf_x and h_compat
    refine ⟨(char_1 nf_x).and (formula_conjList
      ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
        if ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          parent_atoms false false = true then
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
          let y_lt_x := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
          let x_lt_y := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
          if y_lt_x = true then
            if sub_nf.2 ssn = true then some (char_y.snce Formula.top)
            else some (char_y.snce Formula.top).neg
          else if x_lt_y = true then
            if sub_nf.2 ssn = true then some (char_y.untl Formula.top)
            else some (char_y.untl Formula.top).neg
          else
            if sub_nf.2 ssn = true then some char_y
            else some char_y.neg
        else none)),
      List.mem_filterMap.mpr ⟨nf_x,
        Multiset.mem_toList.mpr (Fintype.complete nf_x),
        by simp_all⟩, ?_⟩
    -- Step 2: truth of (char_1 nf_x).and (formula_conjList quant_conjuncts)
    rw [temporal_truth_and]
    refine ⟨(char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x, ?_⟩
    -- Step 3: truth of formula_conjList quant_conjuncts
    rw [formula_conjList_iff]
    intro φ h_φ_mem
    rw [List.mem_filterMap] at h_φ_mem
    obtain ⟨ssn, h_ssn_in, h_ssn_some⟩ := h_φ_mem
    -- ssn passes the ssn_xt_compatible filter; split the outer if
    split_ifs at h_ssn_some with h_ssn_compat_nfx h_sub_nf_true
    -- Case: ssn_xt_compatible = true, sub_nf.2 ssn = true
    · -- Establish shared infrastructure for this ssn
      obtain ⟨h_atom_eval, h_quant_eval⟩ := h_eval
      have h_orders := eq_case_orders ssn
        (fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
        parent_atoms h_ssn_compat_nfx
      obtain ⟨h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty⟩ := h_orders
      have h_t_pred_1 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true :=
        eq_case_t_pred_1 M parent_atoms sub_nf ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms nf_x h_nf_x h_ssn_compat_nfx (fun _ => rfl)
      have h_t_pred_2 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨2, by omega⟩) = true :=
        eq_case_t_pred_2 M parent_atoms ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms h_ssn_compat_nfx
      simp only [] at h_ssn_some
      split_ifs at h_ssn_some with h_y_lt_x h_x_lt_y
      · -- y < x: Since(char_y, top) is true because ∃ y, nf_eval
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_xy_false : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
          obtain ⟨w, hw⟩ := (h_quant_eval ssn).mpr h_sub_nf_true
          have h_oc := ssn_order_consistent_of_eval ssn hw
          simp only [ssn_order_consistent] at h_oc
          revert h_oc; revert h_y_lt_x
          cases ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) <;>
          cases ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;> simp_all
        exact (eq_case_zone_below M atomMap h_surj ssn parent_atoms x
          h_y_lt_x h_xy_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mpr
          ((h_quant_eval ssn).mpr h_sub_nf_true)
      · -- x < y: Until(char_y, top) is true
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_yx_false : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false :=
          Bool.eq_false_iff.mpr h_y_lt_x
        exact (eq_case_zone_above M atomMap h_surj ssn parent_atoms x
          h_x_lt_y h_yx_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mpr
          ((h_quant_eval ssn).mpr h_sub_nf_true)
      · -- y = x: char_y is true
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        exact (eq_case_zone_eq M atomMap h_surj ssn parent_atoms x
          (Bool.eq_false_iff.mpr h_y_lt_x)
          (Bool.eq_false_iff.mpr h_x_lt_y)
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mpr
          ((h_quant_eval ssn).mpr h_sub_nf_true)
    -- Case: ssn_xt_compatible = true, sub_nf.2 ssn = false (neg formulas)
    · obtain ⟨h_atom_eval, h_quant_eval⟩ := h_eval
      have h_orders := eq_case_orders ssn
        (fun a => match a with
          | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
        parent_atoms h_ssn_compat_nfx
      obtain ⟨h_xt, h_tx, h_yx_eq_yt, h_xy_eq_ty⟩ := h_orders
      have h_t_pred_1 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true :=
        eq_case_t_pred_1 M parent_atoms sub_nf ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms nf_x h_nf_x h_ssn_compat_nfx (fun _ => rfl)
      have h_t_pred_2 : ∀ p, M.interp p x ↔ ssn (.pred p ⟨2, by omega⟩) = true :=
        eq_case_t_pred_2 M parent_atoms ssn
          (fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          x h_atoms h_ssn_compat_nfx
      have h_no_witness : ¬∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x fun _ => x)) ssn := by
        intro h_wit
        exact absurd ((h_quant_eval ssn).mp h_wit) (by simp_all)
      simp only [] at h_ssn_some
      split_ifs at h_ssn_some with h_y_lt_x h_x_lt_y
      · -- y < x: neg(Since(char_y, top)) is true because ¬∃ y
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_xy_false : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
          have h_oc := h_ssn_compat_nfx
          simp only [ssn_xt_compatible, Bool.and_eq_true] at h_oc
          have h_oc_cons := h_oc.2  -- ssn_order_consistent ssn = true
          simp only [ssn_order_consistent] at h_oc_cons
          revert h_oc_cons; revert h_y_lt_x
          cases ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) <;>
          cases ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) <;> simp_all
        rw [temporal_truth_neg]
        intro h_snce
        exact h_no_witness ((eq_case_zone_below M atomMap h_surj ssn parent_atoms x
          h_y_lt_x h_xy_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mp h_snce)
      · -- x < y: neg(Until(char_y, top))
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        have h_yx_false : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false :=
          Bool.eq_false_iff.mpr h_y_lt_x
        rw [temporal_truth_neg]
        intro h_untl
        exact h_no_witness ((eq_case_zone_above M atomMap h_surj ssn parent_atoms x
          h_x_lt_y h_yx_false
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mp h_untl)
      · -- y = x: neg(char_y)
        have h_eq_φ := Option.some_injective _ h_ssn_some; subst h_eq_φ
        rw [temporal_truth_neg]
        intro h_eq_zone
        exact h_no_witness ((eq_case_zone_eq M atomMap h_surj ssn parent_atoms x
          (Bool.eq_false_iff.mpr h_y_lt_x)
          (Bool.eq_false_iff.mpr h_x_lt_y)
          h_xt h_tx h_yx_eq_yt h_xy_eq_ty h_t_pred_1 h_t_pred_2).mp h_eq_zone)

/-! ## Equality Case (x = t) -/

set_option maxHeartbeats 3200000 in
/-- Equality case of the enriched bypass: when sub_nf says x = t,
    the existential reduces to nf_eval_nf M 1 2 [t, t] sub_nf. -/
private theorem existPart_succ_n1_bypass_k0_eq
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- When x = t, any witness x must equal t (by witness_eq_t_of_no_order).
  -- Check predicate compatibility: var-0 = var-1 (both are t's preds) and
  -- var-1 matches parent_atoms.
  by_cases h_pred_compat : ∀ p : sig.preds,
      sub_nf.1 (.pred p ⟨0, by omega⟩) = sub_nf.1 (.pred p ⟨1, by omega⟩)
  · by_cases h_t_compat : ∀ p : sig.preds,
        sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩)
    · -- Compatible: use enriched_bypass_eq and eq_case_iff helper.
      -- First check that all ssn with sub_nf.2 = true have compatible
      -- predicates. If not, the existential is impossible and we use Bot.
      -- Build a reference nf_x_1var from pred_compat + t_compat:
      -- nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0) (= sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0))
      let ref_nf_x_1var : NormalForm sig 0 1 := fun a => match a with
        | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
        | .order i j h => absurd (Fin.ext (by omega) : i = j) h
      by_cases h_ssn_compat : ∀ ssn : NormalForm sig 0 3,
          sub_nf.2 ssn = true →
          ssn_xt_compatible ssn ref_nf_x_1var parent_atoms false false = true
      · -- All ssn with sub_nf.2 = true are compatible: use enriched_bypass_eq
        exact ⟨enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms,
          fun M h_UZ h_SZ t h_atoms => by
          exact eq_case_iff atomMap h_surj char_1 char_1_correct parent_atoms
            sub_nf h_gt h_lt h_pred_compat h_t_compat M h_UZ h_SZ t h_atoms
            h_ssn_compat⟩
      · -- Some ssn with sub_nf.2 = true is NOT compatible: existential impossible
        refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
        simp only [temporal_truth]
        constructor
        · exact fun h => absurd h id
        · intro ⟨x, h_eval⟩
          have h_x_eq := witness_eq_t_of_no_order M sub_nf t₀ x h_gt h_lt h_eval
          subst h_x_eq
          apply h_ssn_compat
          intro ssn h_ssn_true
          obtain ⟨h_atom_2, h_quant_2⟩ := h_eval
          have ⟨y, h_ssn_eval⟩ := (h_quant_2 ssn).mpr h_ssn_true
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
          refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
          · -- x-preds: ssn (.pred p 1) = sub_nf.1 (.pred p 0)
            intro p _
            have h1 : M.interp p x ↔ ssn (.pred p ⟨1, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
            have h2 : M.interp p x ↔ sub_nf.1 (.pred p ⟨0, by omega⟩) = true := by
              have h := h_atom_2 (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
            cases hsub : sub_nf.1 (.pred p ⟨0, by omega⟩) <;>
            cases hssn : ssn (.pred p ⟨1, by omega⟩) <;>
            first | rfl | exact hsub.symm | (exfalso; simp_all)
          · -- t-preds: ssn (.pred p 2) = parent_atoms (.pred p 0)
            intro p _
            have h1 : M.interp p x ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
            have h2 : M.interp p x ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
              have h := h_atoms (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
            cases hssn : ssn (.pred p ⟨2, by omega⟩) <;>
            cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t > x order: ssn (.order ⟨2,_⟩ ⟨1,_⟩ _) = false (x < x is false)
            have h_ord : x < x ↔ ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
              have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
              unfold atom_eval at h; exact h
            cases h : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            · rfl
            · exact absurd (h_ord.mpr h) (lt_irrefl _)
          · -- x > t order: ssn (.order ⟨1,_⟩ ⟨2,_⟩ _) = false (x < x is false)
            have h_ord : x < x ↔ ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
              have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
              unfold atom_eval at h; exact h
            cases h : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            · rfl
            · exact absurd (h_ord.mpr h) (lt_irrefl _)
          · exact ssn_order_consistent_of_eval ssn h_ssn_eval
    · -- var-1 preds don't match parent_atoms: existential impossible
      refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
      simp only [temporal_truth]
      constructor
      · exact fun h => absurd h id
      · intro ⟨x, h_eval⟩
        have h_x_eq := witness_eq_t_of_no_order M sub_nf t₀ x h_gt h_lt h_eval
        subst h_x_eq
        push_neg at h_t_compat; obtain ⟨p, hp⟩ := h_t_compat
        obtain ⟨h_atom, _⟩ := h_eval
        have h_sub := (h_atom (.pred p ⟨1, by omega⟩))
        have h_par := (h_atoms (.pred p ⟨0, by omega⟩))
        simp only [atom_eval] at h_par
        -- After subst, derive M.interp p x ↔ sub_nf.1 (.pred p 1) from h_atom
        have h_sub' : M.interp p x ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
          have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h
          exact h
        cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
        cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
        simp_all
  · -- var-0 and var-1 predicates don't agree: existential impossible
    refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · exact fun h => absurd h id
    · intro ⟨x, h_eval⟩
      have h_x_eq := witness_eq_t_of_no_order M sub_nf t₀ x h_gt h_lt h_eval
      subst h_x_eq
      push_neg at h_pred_compat; obtain ⟨p, hp⟩ := h_pred_compat
      obtain ⟨h_atom, _⟩ := h_eval
      have h0 := (h_atom (.pred p ⟨0, by omega⟩))
      have h1 := (h_atom (.pred p ⟨1, by omega⟩))
      -- After subst, derive M.interp from h_atom with proper reduction
      have h0' : M.interp p x ↔ sub_nf.1 (.pred p ⟨0, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
      have h1' : M.interp p x ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h
        exact h
      cases h0v : sub_nf.1 (.pred p ⟨0, by omega⟩) <;>
      cases h1v : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
      simp_all

/-! ## Zone-to-Temporal Bridge Helpers

These helpers extract x and t predicates from ssn_xt_compatible and connect
zone bridge lemmas from ZoneBridge.lean to the temporal formula encoding. -/

/-- Extract x-predicate conditions from ssn_xt_compatible. -/
private theorem ssn_xt_compat_x_preds {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) (x_gt_t x_lt_t : Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms x_gt_t x_lt_t = true) :
    ∀ p : sig.preds, ssn (.pred p ⟨1, by omega⟩) = nf_x_1var (.pred p ⟨0, by omega⟩) := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  intro p
  exact h_compat.1.1.1.1 p (Multiset.mem_toList.mpr (Fintype.complete p))

/-- Extract t-predicate conditions from ssn_xt_compatible. -/
private theorem ssn_xt_compat_t_preds {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool) (x_gt_t x_lt_t : Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms x_gt_t x_lt_t = true) :
    ∀ p : sig.preds, ssn (.pred p ⟨2, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  intro p
  exact h_compat.1.1.1.2 p (Multiset.mem_toList.mpr (Fintype.complete p))

/-- Extract t < x order condition from ssn_xt_compatible (Until direction). -/
private theorem ssn_xt_compat_tx_order {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true) :
    ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  exact ⟨h_compat.1.1.2, h_compat.1.2⟩

/-! ## Zone order extraction from ssn_zone_until

These helpers extract the 6 order atom values from `ssn_zone_until ssn = zone`.
Combined with `ssn_xt_compatible ... true false = true`, they give all 6 order atoms
needed by the zone bridge theorems in ZoneBridge.lean. -/

set_option maxHeartbeats 400000 in
/-- Extract y < t from below_t zone. -/
private theorem zone_below_t_yt {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.below_t) :
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(t < y) from below_t zone. -/
private theorem zone_below_t_ty {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.below_t) :
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(y < t) and ¬(t < y) from eq_t zone. -/
private theorem zone_eq_t_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.eq_t) :
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(y < x) and ¬(x < y) from eq_x zone. -/
private theorem zone_eq_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.eq_x) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract x < y from above_x zone. -/
private theorem zone_above_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.above_x) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract order atoms from between_tx zone. -/
private theorem zone_between_tx_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_until ssn = YZone.between_tx) :
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_until] at h_zone
  revert h_zone; split_ifs <;> simp_all

/-! ## Below_t / eq_t bridge: temporal formula ↔ 3-var existential

These connect the temporal formulas (Since/char_y) used in pre_conditions_at_t_until
to the 3-var existentials tracked by h_eval_quant. -/

/-- For below_t zone with compatible ssn: Since(char_y, top) at t ↔ ∃ y, nf_eval_nf. -/
private theorem below_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.below_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have h_yt := zone_below_t_yt ssn h_zone
  have h_ty := zone_below_t_ty ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn : ∀ p, ssn (.pred p ⟨1, by omega⟩) = nf_x_1var (.pred p ⟨0, by omega⟩) :=
    ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn : ∀ p, ssn (.pred p ⟨2, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩) :=
    ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  -- Need y < x from ssn. below_t means y < t, and t < x in ssn,
  -- so by ssn_order_consistent + transitivity encoding, y < x should hold.
  -- From ssn_xt_compatible, ssn_order_consistent ssn = true.
  -- ssn_order_consistent checks transitivity: !(yt && tx) || yx.
  -- h_yt = true, h_tx_ord.1 = true, so yx must be true.
  have h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  -- Now use zone_bridge_below_t
  have h_bridge := zone_bridge_below_t M ssn x t h_tx h_yt h_yx h_ty h_xy h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · -- Forward: Since(char_y, top) at t → ∃ y, nf_eval
    intro ⟨y, h_yt_lt, h_char_y, _⟩
    rw [h_bridge]
    refine ⟨y, h_yt_lt, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · -- Backward: ∃ y, nf_eval → Since(char_y, top) at t
    intro h_exist
    rw [h_bridge] at h_exist
    obtain ⟨y, h_yt_lt, h_y_preds⟩ := h_exist
    exact ⟨y, h_yt_lt,
      (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds,
      fun z _ _ => by simp [temporal_truth, Formula.top]⟩

/-- For eq_t zone with compatible ssn: char_y at t ↔ ∃ y, nf_eval_nf. -/
private theorem eq_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.eq_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yt, h_ty⟩ := zone_eq_t_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  -- eq_t means y = t, so y < x (since t < x)
  -- We need h_yx from zone: eq_t in ssn_zone_until means !y_lt_t && !t_lt_y, and then
  -- y_lt_x || (!y_lt_x && !x_lt_y) for eq_t. Since ssn says t < x, transitivity + y=t
  -- gives y < x.
  -- From ssn_zone_until eq_t branch: it requires y_lt_x || (!y_lt_x && !x_lt_y).
  -- And eq_t is the case where y=t. In ssn_zone_until, this is after checking y_lt_t=false
  -- and t_lt_y=false. The next check: !y_lt_t && !t_lt_y, then if y_lt_x || (!y_lt_x && !x_lt_y).
  -- For eq_t, this is true. y_lt_x = ssn (.order 0 1). If y_lt_x=true, it becomes .eq_t
  -- directly. If y_lt_x=false but x_lt_y=false too, also .eq_t.
  -- We need to figure out y_lt_x for zone_bridge_eq_t.
  -- zone_bridge_eq_t requires h_yx_ssn : ssn (.order 0 1) = true (y < x)
  -- But in eq_t zone, y_lt_x could be false (if both are false → y=x=t).
  -- zone_bridge_eq_t needs y < x in its order profile. But that might not hold.
  -- Actually looking at zone_bridge_eq_t signature: it requires h_yx_ssn = true.
  -- But for the eq_t zone in ssn_zone_until, y=t and t < x in ssn,
  -- so by consistency, y_lt_x should be true (y=t < x).
  -- ssn_order_consistent checks: !(yt && tx) || yx. We have yt=false, so the
  -- antecedent is false, making the implication vacuously true. Not helpful.
  -- But consistency also checks: (yt || ty || (yx == tx && xy == xt)).
  -- yt=false, ty=false, so we need yx == tx && xy == xt.
  -- tx = h_tx_ord.1 = true, xt = h_tx_ord.2 = false.
  -- So yx = tx = true and xy = xt = false.
  have h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_bridge := zone_bridge_eq_t M ssn x t h_tx h_yt h_ty h_yx h_xy h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · -- Forward: char_y at t → ∃ y, nf_eval
    intro h_char_y
    rw [h_bridge]
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · -- Backward: ∃ y, nf_eval → char_y at t
    intro h_exist
    rw [h_bridge] at h_exist
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) t).mpr h_exist

set_option maxHeartbeats 800000 in
/-- For eq_x zone with compatible ssn: char_y at x ↔ ∃ y, nf_eval_nf. -/
private theorem eq_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.eq_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yx, h_xy, h_ty, h_yt⟩ := zone_eq_x_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_bridge := zone_bridge_eq_x M ssn x t h_tx h_yx h_xy h_ty h_yt h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  constructor
  · intro h_char_y
    rw [h_bridge]
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · intro h_exist
    rw [h_bridge] at h_exist
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) x).mpr h_exist

set_option maxHeartbeats 800000 in
/-- For above_x zone with compatible ssn: Until(char_y, top) at x ↔ ∃ y, nf_eval_nf. -/
private theorem above_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.above_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_xy, h_yx, h_ty, h_yt⟩ := zone_above_x_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_bridge := zone_bridge_above_x M ssn x t h_tx h_xy h_ty h_yx h_yt h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
  -- h_bridge : (∃ y, nf_eval ...) ↔ (∃ y, x < y ∧ ∀ p, M.interp p y ↔ ssn (.pred p 0) = true)
  constructor
  · -- Forward: Until(char_y, top) at x → ∃ y, nf_eval
    intro ⟨y, h_xy_lt, h_char_y, _⟩
    rw [h_bridge]
    refine ⟨y, h_xy_lt, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    exact h_char_y
  · -- Backward: ∃ y, nf_eval → Until(char_y, top) at x
    intro h_exist
    rw [h_bridge] at h_exist
    obtain ⟨y, h_xy_lt, h_y_preds⟩ := h_exist
    exact ⟨y, h_xy_lt,
      (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds,
      fun z _ _ => by simp [temporal_truth, Formula.top]⟩

/-- The pre_conditions_at_t_until formula holds at t when h_eval_quant
    guarantees the correct truth values for all zone-based ssn conditions. -/
private theorem pre_conditions_at_t_until_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true)
    (h_eval_quant : ∀ (ssn : NormalForm sig 0 3),
      (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
      sub_nf.2 ssn = true) :
    temporal_truth M atomMap t
      (pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms) := by
  simp only [pre_conditions_at_t_until]
  rw [formula_conjList_iff]
  intro φ h_mem
  rw [List.mem_filterMap] at h_mem
  obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
  split_ifs at h_some with h_compat h_pos
  · -- Compatible and positive: zone determines the formula
    revert h_some
    rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    -- pos.below_t
    · exact (below_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
    -- pos.eq_t
    · exact (eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
  · -- Compatible and negative: zone determines the negated formula
    revert h_some
    rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    -- neg.below_t
    · simp only [Formula.neg, temporal_truth]
      intro h_since
      have h_exist := (below_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mp h_since
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
    -- neg.eq_t
    · simp only [Formula.neg, temporal_truth]
      intro h_char
      have h_exist := (eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_tx
        h_compat h_zone h_x_pred h_t_pred).mp h_char
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
/-! ## Between_tx bridge and bracket helpers -/

set_option maxHeartbeats 800000 in
/-- For between_tx zone with compatible ssn: temporal bridge to 3-var existential. -/
private theorem between_tx_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_tx : t < x)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true)
    (h_zone : ssn_zone_until ssn = YZone.between_tx)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, t < y ∧ y < x ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  have ⟨h_ty, h_yx, h_yt, h_xy⟩ := zone_between_tx_orders ssn h_zone
  have h_tx_ord := ssn_xt_compat_tx_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms true false h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms true false h_compat
  exact zone_bridge_between_tx M ssn x t h_tx h_ty h_yx h_yt h_xy h_tx_ord.1 h_tx_ord.2
    (fun p => by constructor
                 · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                 · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
    (fun p => by constructor
                 · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                 · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))

private theorem between_tx_order_atoms {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (h : ssn_zone_until ssn = YZone.between_tx) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
  simp only [ssn_zone_until] at h
  revert h; split_ifs <;> simp_all [Bool.and_eq_true]

/-! ## Until Case: Forward and Backward Helper Lemmas -/

/-- Given k strictly increasing points in an open interval (lo, hi),
    the bracket formula with per-point pointTypes and constant segmentType holds,
    provided each point satisfies its pointType and the segmentType holds
    everywhere in (lo, hi). -/
private theorem bracket_from_sorted_witnesses {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier) (h_lo_hi : lo < hi)
    (pointTypes : Fin k → TemporalPred) (segType : TemporalPred)
    (witnesses : Fin k → M.carrier)
    (h_strict_mono : StrictMono witnesses)
    (h_in_interval : ∀ i, lo < witnesses i ∧ witnesses i < hi)
    (h_ptType : ∀ i, (pointTypes i).eval_at M atomMap (witnesses i))
    (h_segType : ∀ y, lo < y → y < hi → segType.eval_at M atomMap y) :
    (BracketFormula.mk pointTypes (fun _ : Fin (k + 1) => segType)).holds
      M atomMap lo hi := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
  match k, pointTypes, witnesses, h_strict_mono, h_in_interval, h_ptType with
  | 0, _, _, _, _, _ =>
    simp only [IntervalPattern.holds]
    exact h_segType
  | k' + 1, pointTypes, witnesses, h_strict_mono, h_in_interval, h_ptType =>
    simp only [IntervalPattern.holds]
    refine ⟨witnesses, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- Strict monotonicity
      intro i j h_ij; exact h_strict_mono h_ij
    · -- All in (lo, hi)
      exact h_in_interval
    · -- Point types hold at witnesses
      exact h_ptType
    · -- Segment type on (lo, witnesses 0)
      intro y h_lo_y h_y_w0
      exact h_segType y h_lo_y (lt_trans h_y_w0 (h_in_interval ⟨0, by omega⟩).2)
    · -- Segment type between consecutive witnesses
      intro i y h_wi_y h_y_wi1
      exact h_segType y (lt_trans (h_in_interval ⟨i.val, by omega⟩).1 h_wi_y)
        (lt_trans h_y_wi1 (h_in_interval ⟨i.val + 1, by omega⟩).2)
    · -- Segment type on (witnesses k', hi)
      intro y h_wk_y h_y_hi
      exact h_segType y (lt_trans (h_in_interval ⟨k', by omega⟩).1 h_wk_y) h_y_hi

/-- Given k distinct points in an open interval (lo, hi) of a linear order,
    the bracket formula with constant pointType and constant segmentType holds,
    provided each point satisfies the pointType and the segmentType holds
    everywhere in (lo, hi). -/
private theorem bracket_from_distinct_witnesses {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier) (h_lo_hi : lo < hi)
    (ptType segType : TemporalPred)
    (witnesses : Fin k → M.carrier)
    (h_in_interval : ∀ i, lo < witnesses i ∧ witnesses i < hi)
    (h_injective : Function.Injective witnesses)
    (h_ptType : ∀ i, ptType.eval_at M atomMap (witnesses i))
    (h_segType : ∀ y, lo < y → y < hi → segType.eval_at M atomMap y) :
    (BracketFormula.mk (fun _ : Fin k => ptType) (fun _ : Fin (k + 1) => segType)).holds
      M atomMap lo hi := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern]
  match k, witnesses, h_in_interval, h_injective, h_ptType with
  | 0, _, _, _, _ =>
    simp only [IntervalPattern.holds]
    exact h_segType
  | k' + 1, witnesses, h_in_interval, h_injective, h_ptType =>
    -- Sort the witnesses using Finset.orderEmbOfFin
    simp only [IntervalPattern.holds]
    let wit_set : Finset M.carrier := Finset.image witnesses Finset.univ
    have h_card : wit_set.card = k' + 1 := by
      rw [Finset.card_image_of_injective _ h_injective]
      simp
    -- Helper: each sorted element is a witness value
    have sorted_is_witness : ∀ i, ∃ j, witnesses j = (wit_set.orderEmbOfFin h_card) i := by
      intro i
      have h_mem := Finset.orderEmbOfFin_mem wit_set h_card i
      rw [Finset.mem_image] at h_mem
      obtain ⟨j, _, hj⟩ := h_mem
      exact ⟨j, hj⟩
    let sorted := wit_set.orderEmbOfFin h_card
    refine ⟨sorted, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · -- Strict monotonicity
      intro i j h_ij; exact sorted.strictMono h_ij
    · -- All in (lo, hi)
      intro i
      obtain ⟨j, hj⟩ := sorted_is_witness i
      rw [← hj]; exact h_in_interval j
    · -- Point types hold at sorted witnesses
      intro i
      obtain ⟨j, hj⟩ := sorted_is_witness i
      rw [← hj]; exact h_ptType j
    · -- Segment type on (lo, sorted 0)
      intro y h_lo_y h_y_w0
      obtain ⟨j, hj⟩ := sorted_is_witness ⟨0, by omega⟩
      exact h_segType y h_lo_y (by rw [← hj] at h_y_w0; exact lt_trans h_y_w0 (h_in_interval j).2)
    · -- Segment type between consecutive witnesses
      intro i y h_wi_y h_y_wi1
      obtain ⟨j_lo, hj_lo⟩ := sorted_is_witness ⟨i.val, by omega⟩
      obtain ⟨j_hi, hj_hi⟩ := sorted_is_witness ⟨i.val + 1, by omega⟩
      rw [← hj_lo] at h_wi_y; rw [← hj_hi] at h_y_wi1
      exact h_segType y (lt_trans (h_in_interval j_lo).1 h_wi_y)
        (lt_trans h_y_wi1 (h_in_interval j_hi).2)
    · -- Segment type on (sorted k', hi)
      intro y h_wk_y h_y_hi
      obtain ⟨j, hj⟩ := sorted_is_witness ⟨k', by omega⟩
      rw [← hj] at h_wk_y
      exact h_segType y (lt_trans (h_in_interval j).1 h_wk_y) h_y_hi

private theorem bracket_extract_witness {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier)
    (pointTypes : Fin k → TemporalPred) (segType : Fin (k + 1) → TemporalPred)
    (h : (BracketFormula.mk pointTypes segType).holds M atomMap lo hi)
    (i : Fin k) :
    ∃ w, lo < w ∧ w < hi ∧ (pointTypes i).eval_at M atomMap w := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  match k, pointTypes, segType, h, i with
  | k' + 1, pointTypes, segType, h, i =>
    simp only [IntervalPattern.holds] at h
    obtain ⟨witnesses, _, h_bounds, h_ptypes, _, _, _⟩ := h
    exact ⟨witnesses i, (h_bounds i).1, (h_bounds i).2, h_ptypes i⟩

private theorem bracket_constant_seg_dichotomy {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (k : Nat) (lo hi : M.carrier)
    (pointTypes : Fin k → TemporalPred) (segType : TemporalPred)
    (h : (BracketFormula.mk pointTypes (fun _ : Fin (k + 1) => segType)).holds
      M atomMap lo hi)
    (y : M.carrier) (h_lo_y : lo < y) (h_y_hi : y < hi) :
    segType.eval_at M atomMap y ∨ ∃ i : Fin k, (pointTypes i).eval_at M atomMap y := by
  simp only [BracketFormula.holds, BracketFormula.toIntervalPattern] at h
  match k, pointTypes, h with
  | 0, _, h =>
    simp only [IntervalPattern.holds] at h
    exact Or.inl (h y h_lo_y h_y_hi)
  | k' + 1, pointTypes, h =>
    simp only [IntervalPattern.holds] at h
    obtain ⟨witnesses, h_mono, h_bounds, h_ptypes, h_seg0, h_seg_mid, h_seg_last⟩ := h
    by_cases h_y_lt_w0 : y < witnesses ⟨0, by omega⟩
    · exact Or.inl (h_seg0 y h_lo_y h_y_lt_w0)
    · push_neg at h_y_lt_w0
      by_cases h_y_gt_wk : witnesses ⟨k', by omega⟩ < y
      · exact Or.inl (h_seg_last y h_y_gt_wk h_y_hi)
      · push_neg at h_y_gt_wk
        suffices ∃ i : Fin (k' + 1),
            y = witnesses i ∨
            (∃ j : Fin k', witnesses ⟨j.val, by omega⟩ < y ∧
              y < witnesses ⟨j.val + 1, by omega⟩) by
          obtain ⟨i, h_case⟩ := this
          rcases h_case with h_eq | ⟨j, h_wj_y, h_y_wj1⟩
          · exact Or.inr ⟨i, h_eq ▸ h_ptypes i⟩
          · exact Or.inl (h_seg_mid j y h_wj_y h_y_wj1)
        by_contra h_none; push_neg at h_none
        have h_le_all : ∀ i : Fin (k' + 1), witnesses i ≤ y := by
          intro ⟨i, hi⟩
          induction i with
          | zero => exact h_y_lt_w0
          | succ n ih =>
            have h_prev := ih (by omega)
            have h_ne := (h_none ⟨n, by omega⟩).1
            have h_lt : witnesses ⟨n, by omega⟩ < y := lt_of_le_of_ne h_prev h_ne.symm
            exact (h_none ⟨n + 1, hi⟩).2 ⟨n, by omega⟩ h_lt
        exact absurd (le_antisymm h_y_gt_wk (h_le_all ⟨k', by omega⟩))
          (h_none ⟨k', by omega⟩).1

set_option maxHeartbeats 3200000 in
/-- Backward direction: ∃ x, nf_eval → holdsLeft for the enriched Until VVecEA2.
    Given a witness x > t with nf_eval_nf, construct holdsLeft by:
    1. Finding the right disjunct (nf_x = nf_characteristic of x)
    2. Sorting between_tx witnesses to determine the permutation
    3. Showing endpointLeft (pre-conditions at t) holds
    4. Providing x as the Until witness with endpointRight + bracket -/
private theorem backward_holdsLeft_of_nf_eval
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) :
    (∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) →
    ∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsLeft M atomMap vea.snd t := by
  intro ⟨x, h_eval⟩
  -- Step 1: Get the characteristic NF of x and show compatibility
  let nf_x := nf_characteristic M 1 1 (fun _ => x)
  have h_nf_x : nf_eval_nf M 1 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M 1 1 (fun _ => x)
  have h_compat : nf_x_compat_check sub_nf nf_x = true :=
    nf_x_compat_of_nf_eval M sub_nf t x h_eval nf_x h_nf_x
  -- Step 2: Setup
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  have h_t_lt_x : t < x := (zone_from_nf_eval M sub_nf t x h_eval).1 h_gt
  obtain ⟨h_eval_atoms, h_eval_quant⟩ := h_eval
  -- Define pos_between and neg_between matching enriched_vecEA2_until's let bindings
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) && !sub_nf.2 ssn
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) && sub_nf.2 ssn
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  let k := pos_between.length
  -- Step 3: Get witnesses for each pos_between SSN
  have h_pos_witnesses : ∀ ssn ∈ pos_between, ∃ y, t < y ∧ y < x ∧
      ∀ p, M.interp p y ↔ (nf_y_proj ssn) (.pred p ⟨0, by omega⟩) = true := by
    intro ssn h_mem
    rw [List.mem_filter] at h_mem
    obtain ⟨_, h_filter⟩ := h_mem
    simp only [Bool.and_eq_true, beq_iff_eq] at h_filter
    obtain ⟨⟨h_compat', h_zone⟩, h_pos⟩ := h_filter
    have h_exists := (h_eval_quant ssn).mpr h_pos
    exact (between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
      h_t_lt_x h_compat' h_zone
      (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                   have := h_atom (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)
      (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)).mp h_exists
  let witness_fn : Fin k → M.carrier := fun i =>
    (h_pos_witnesses (pos_between.get i) (List.get_mem pos_between i)).choose
  have h_wit_spec : ∀ i, t < witness_fn i ∧ witness_fn i < x ∧
      ∀ p, M.interp p (witness_fn i) ↔ (nf_y_proj (pos_between.get i)) (.pred p ⟨0, by omega⟩) = true := by
    intro i
    exact (h_pos_witnesses (pos_between.get i) (List.get_mem pos_between i)).choose_spec
  -- Step 4: Prove witnesses are injective (same as before)
  have h_wit_injective : Function.Injective witness_fn := by
    intro i j h_eq
    have h_pred_eq' : ∀ p, nf_y_proj (pos_between.get i) (.pred p ⟨0, by omega⟩) =
        nf_y_proj (pos_between.get j) (.pred p ⟨0, by omega⟩) := by
      intro p
      have hi := (h_wit_spec i).2.2 p
      have hj := (h_wit_spec j).2.2 p
      rw [h_eq] at hi
      exact Bool.eq_iff_iff.mpr (hi.symm.trans hj)
    have hi_mem := List.get_mem pos_between i
    have hj_mem := List.get_mem pos_between j
    rw [List.mem_filter] at hi_mem hj_mem
    obtain ⟨_, hi_filt⟩ := hi_mem
    obtain ⟨_, hj_filt⟩ := hj_mem
    simp only [Bool.and_eq_true, beq_iff_eq] at hi_filt hj_filt
    obtain ⟨⟨hi_compat, hi_zone⟩, _⟩ := hi_filt
    obtain ⟨⟨hj_compat, hj_zone⟩, _⟩ := hj_filt
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at hi_compat hj_compat
    obtain ⟨⟨⟨⟨hi_x, hi_t⟩, hi_ord1⟩, hi_ord2⟩, hi_ocons⟩ := hi_compat
    obtain ⟨⟨⟨⟨hj_x, hj_t⟩, hj_ord1⟩, hj_ord2⟩, hj_ocons⟩ := hj_compat
    have h_ylx_i : (pos_between.get i) (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ylx_j : (pos_between.get j) (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_tly_i : (pos_between.get i) (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_tly_j : (pos_between.get j) (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_xly_i : (pos_between.get i) (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_xly_j : (pos_between.get j) (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ylt_i : (pos_between.get i) (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hi_zone; revert hi_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ylt_j : (pos_between.get j) (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false := by
      simp only [ssn_zone_until] at hj_zone; revert hj_zone
      split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all [Bool.and_eq_true]
    have h_ssn_eq : pos_between.get i = pos_between.get j := by
      funext a
      cases a with
      | pred p k =>
        match k with
        | ⟨0, _⟩ => simp only [nf_y_proj] at h_pred_eq'; exact h_pred_eq' p
        | ⟨1, _⟩ => rw [hi_x p (Multiset.mem_toList.mpr (Fintype.complete p)), hj_x p (Multiset.mem_toList.mpr (Fintype.complete p))]
        | ⟨2, _⟩ => rw [hi_t p (Multiset.mem_toList.mpr (Fintype.complete p)), hj_t p (Multiset.mem_toList.mpr (Fintype.complete p))]
      | order k l h_ne =>
        match k, l, h_ne with
        | ⟨0, _⟩, ⟨1, _⟩, _ => rw [h_ylx_i, h_ylx_j]
        | ⟨1, _⟩, ⟨0, _⟩, _ => rw [h_xly_i, h_xly_j]
        | ⟨0, _⟩, ⟨2, _⟩, _ => rw [h_ylt_i, h_ylt_j]
        | ⟨2, _⟩, ⟨0, _⟩, _ => rw [h_tly_i, h_tly_j]
        | ⟨1, _⟩, ⟨2, _⟩, _ => rw [hi_ord2, hj_ord2]
        | ⟨2, _⟩, ⟨1, _⟩, _ => rw [hi_ord1, hj_ord1]
        | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
        | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
        | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
    have h_nodup : pos_between.Nodup :=
      List.Nodup.filter _
        (Multiset.coe_nodup.mp (by rw [Multiset.coe_toList]; exact Finset.nodup _))
    exact Fin.ext
      ((h_nodup.getElem_inj_iff (hi := i.isLt) (hj := j.isLt)).mp h_ssn_eq)
  -- Step 5: Sort witnesses and determine the permutation
  -- Sort witness values using Finset.orderEmbOfFin
  let wit_set : Finset M.carrier := Finset.image witness_fn Finset.univ
  have h_card : wit_set.card = k := by
    rw [Finset.card_image_of_injective _ h_wit_injective]; simp
  -- sorted maps sorted positions to carrier elements
  let sorted := wit_set.orderEmbOfFin h_card
  -- Each sorted element corresponds to some original witness
  have sorted_is_witness : ∀ i : Fin k, ∃ j : Fin k, witness_fn j = sorted i := by
    intro i
    have h_mem := Finset.orderEmbOfFin_mem wit_set h_card i
    rw [Finset.mem_image] at h_mem
    obtain ⟨j, _, hj⟩ := h_mem
    exact ⟨j, hj⟩
  -- Build the sorting permutation: for each sorted position i, find the original index
  -- Use Classical.choice since we know the function is a bijection
  let sort_to_orig : Fin k → Fin k := fun i => (sorted_is_witness i).choose
  have h_sort_spec : ∀ i, witness_fn (sort_to_orig i) = sorted i := by
    intro i; exact (sorted_is_witness i).choose_spec
  -- sort_to_orig is injective (since witness_fn is injective and sorted is injective)
  have h_sort_inj : Function.Injective sort_to_orig := by
    intro i j h_eq
    have : sorted i = sorted j := by
      rw [← h_sort_spec i, ← h_sort_spec j, h_eq]
    exact sorted.injective this
  -- sort_to_orig is a bijection Fin k → Fin k, hence an Equiv.Perm
  have h_sort_surj : Function.Surjective sort_to_orig := by
    exact Finite.surjective_of_injective h_sort_inj
  let σ : Equiv.Perm (Fin k) := Equiv.ofBijective sort_to_orig ⟨h_sort_inj, h_sort_surj⟩
  -- Step 6: Build the specific VecEA2 for permutation σ and show it's in the list
  let endLeft : TemporalPred :=
    ⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  let right_conjuncts :=
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
        | _ => none
      else none
  let endRight : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList right_conjuncts)⟩
  let the_bracket : BracketFormula k :=
    { pointTypes := fun i =>
        ⟨nf_depth0_char_formula atomMap h_surj (nf_y_proj (pos_between.get (σ i)))⟩
      segmentTypes := fun _ => seg_guard }
  let the_vea : Σ n, VecEA2 n :=
    ⟨k, VecEA2.mk endLeft endRight the_bracket⟩
  -- Show the_vea is in the flatMap list
  have h_mem_elems : nf_x ∈ Fintype.elems.val := Fintype.complete nf_x
  have h_σ_mem : σ ∈ (Fintype.elems (α := Equiv.Perm (Fin k))).val := Fintype.complete σ
  have h_vea_mem : the_vea ∈ List.flatMap
      (fun nf_x' => if nf_x_compat_check sub_nf nf_x' = true then
        enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x'
          (fun a => match a with
            | .pred p _ => nf_x'.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          parent_atoms
      else []) Fintype.elems.val.toList := by
    rw [List.mem_flatMap]
    refine ⟨nf_x, Multiset.mem_toList.mpr h_mem_elems, ?_⟩
    simp only [h_compat, ite_true]
    -- Need: the_vea ∈ enriched_vecEA2_until ... = list of permutation VecEA2s
    simp only [enriched_vecEA2_until]
    rw [List.mem_map]
    exact ⟨σ, Multiset.mem_toList.mpr h_σ_mem, rfl⟩
  -- Step 7: Show holdsLeft for the_vea
  refine ⟨the_vea, h_vea_mem, ?_⟩
  simp only [VecEA2.holdsLeft]
  refine ⟨?endLeft, x, h_t_lt_x, ?endRight, ?bracket⟩
  case endLeft =>
    simp only [TemporalPred.eval_at]
    exact pre_conditions_at_t_until_holds M atomMap h_surj sub_nf nf_x_1var parent_atoms x t
      h_t_lt_x
      (fun p => by
        obtain ⟨h_atom, _⟩ := h_nf_x
        have := h_atom (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
      (fun p => by
        have := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at this
        exact this)
      h_eval_quant
  case endRight =>
    simp only [TemporalPred.eval_at]
    show temporal_truth M atomMap x (Formula.and (char_1 nf_x) (formula_conjList _))
    rw [temporal_truth_and]
    constructor
    · exact (char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x
    · rw [formula_conjList_iff]
      intro φ h_mem
      rw [List.mem_filterMap] at h_mem
      obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
      split_ifs at h_some with h_compat' h_pos
      · revert h_some
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        · exact (eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_t_lt_x
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
        · exact (above_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_t_lt_x
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
      · revert h_some
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        · simp only [Formula.neg, temporal_truth]
          intro h_char
          have h_exist := (eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mp h_char
          exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
        · simp only [Formula.neg, temporal_truth]
          intro h_until
          have h_exist := (above_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mp h_until
          exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
  case bracket =>
    -- BracketFormula with per-SSN pointTypes. Provide sorted witnesses.
    -- seg_guard holds everywhere in (t, x)
    have seg_guard_on_interval : ∀ y : M.carrier, t < y → y < x →
        seg_guard.eval_at M atomMap y := by
      intro y h_ty h_yx
      simp only [TemporalPred.eval_at]
      rw [formula_conjList_iff]
      intro φ h_φ_mem
      rw [List.mem_map] at h_φ_mem
      obtain ⟨ssn, h_ssn_mem, h_φ_eq⟩ := h_φ_mem
      subst h_φ_eq
      rw [List.mem_filter] at h_ssn_mem
      obtain ⟨_, h_filter⟩ := h_ssn_mem
      simp only [Bool.and_eq_true, beq_iff_eq, Bool.not_eq_eq_eq_not, Bool.not_true] at h_filter
      obtain ⟨⟨h_compat', h_zone⟩, h_neg⟩ := h_filter
      simp only [Formula.neg, temporal_truth]
      intro h_char_y
      have h_bridge := (between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
        h_t_lt_x h_compat' h_zone
        (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                     have := h_atom (.pred p ⟨0, by omega⟩)
                     simp only [atom_eval] at this; exact this)
        (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                     simp only [atom_eval] at this; exact this)).mpr
      have h_no_witness : ¬ ∃ z, nf_eval_nf M 0 (1 + 1 + 1)
          (Fin.cons z (Fin.cons x fun _ => t)) ssn := by
        rw [h_eval_quant ssn]; simp [h_neg]
      apply h_no_witness; apply h_bridge
      exact ⟨y, h_ty, h_yx, fun p => by
        rw [nf_depth0_char_formula_correct] at h_char_y
        have := h_char_y p; simp only [nf_y_proj] at this; exact this⟩
    -- The bracket has per-SSN pointTypes[i] = char_y(pos_between[σ(i)]).
    -- We provide sorted witnesses: sorted[i] = witness_fn(σ i).
    -- sorted is strictly monotone (from Finset.orderEmbOfFin).
    -- sorted[i] satisfies char_y(pos_between[σ(i)]) because
    -- witness_fn(σ i) satisfies char_y(pos_between.get(σ i)) by h_wit_spec.
    -- Construct the sorted witness function
    let sorted_fn : Fin k → M.carrier := fun i => sorted i
    have h_sorted_eq_wit : ∀ i, sorted_fn i = witness_fn (σ i) := by
      intro i; exact (h_sort_spec i).symm
    have h_sorted_mono : StrictMono sorted_fn := by
      intro i j h_ij; exact sorted.strictMono h_ij
    have h_sorted_in_interval : ∀ i, t < sorted_fn i ∧ sorted_fn i < x := by
      intro i
      rw [h_sorted_eq_wit i]
      exact ⟨(h_wit_spec (σ i)).1, (h_wit_spec (σ i)).2.1⟩
    have h_sorted_ptType : ∀ i, (the_bracket.pointTypes i).eval_at M atomMap (sorted_fn i) := by
      intro i
      simp only [TemporalPred.eval_at]
      rw [h_sorted_eq_wit i]
      rw [nf_depth0_char_formula_correct]
      exact fun p => (h_wit_spec (σ i)).2.2 p
    exact bracket_from_sorted_witnesses M atomMap k t x h_t_lt_x
      the_bracket.pointTypes seg_guard sorted_fn
      h_sorted_mono h_sorted_in_interval h_sorted_ptType seg_guard_on_interval

set_option maxHeartbeats 3200000 in
/-- Forward direction: holdsLeft for the enriched Until VVecEA2 → ∃ x, nf_eval.
    Given holdsLeft (some disjunct is satisfied), extract x and reconstruct nf_eval.
    With per-SSN pointTypes, each bracket witness directly identifies its SSN. -/
private theorem forward_nf_eval_of_holdsLeft
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : ∀ p : sig.preds, sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) parent_atoms true false = true) :
    (∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsLeft M atomMap vea.snd t) →
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  intro ⟨⟨n, vea⟩, h_mem, h_holds⟩
  -- Extract nf_x from the flatMap membership
  rw [List.mem_flatMap] at h_mem
  obtain ⟨nf_x, _, h_in_list⟩ := h_mem
  -- nf_x_compat_check must be true for non-empty list
  split_ifs at h_in_list with h_compat
  · -- Compatible case: ⟨n, vea⟩ ∈ enriched_vecEA2_until ...
    -- Extract the permutation σ from the list membership
    simp only [enriched_vecEA2_until] at h_in_list
    rw [List.mem_map] at h_in_list
    obtain ⟨σ, _, h_vea_eq⟩ := h_in_list
    -- h_vea_eq : ⟨k, { ... bracket with pointTypes = char_y(pos_between[σ(i)]) ... }⟩ = ⟨n, vea⟩
    let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
      | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
      | .order i j h => absurd (Fin.ext (by omega) : i = j) h
    let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
      ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
      (ssn_zone_until ssn == .between_tx) && sub_nf.2 ssn
    -- From h_vea_eq, n = pos_between.length
    have h_n_eq : n = pos_between.length := by
      have := congrArg Sigma.fst h_vea_eq; simp at this; exact this.symm
    -- Extract holdsLeft components
    rw [show (⟨n, vea⟩ : Σ n, VecEA2 n).snd = vea from rfl] at h_holds
    simp only [VecEA2.holdsLeft] at h_holds
    obtain ⟨h_endLeft, x, h_t_lt_x, h_endRight, h_bracket⟩ := h_holds
    -- x is the witness for the existential
    refine ⟨x, ?_⟩
    -- Extract char_1(nf_x) from endpointRight (shared by atom + quantifier parts)
    have h_vea_right : vea.endpointRight =
          (⟨Formula.and (char_1 nf_x) (formula_conjList
            ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
              if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
                let zone := ssn_zone_until ssn
                let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
                match zone with
                | .eq_x => if sub_nf.2 ssn then some char_y else some char_y.neg
                | .above_x =>
                  if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
                  else some (Formula.untl char_y Formula.top).neg
                | _ => none
              else none))⟩ : TemporalPred) := by
        have := congrArg (fun s => s.snd.endpointRight) h_vea_eq
        simp at this; exact this.symm
    simp only [TemporalPred.eval_at] at h_endRight
    rw [h_vea_right] at h_endRight
    simp only [TemporalPred.eval_at] at h_endRight
    have h_endRight_temporal := h_endRight
    rw [temporal_truth_and] at h_endRight_temporal
    have h_nf_x_eval := (char_1_correct nf_x M h_UZ h_SZ x).mp h_endRight_temporal.1
    obtain ⟨h_nf_x_atoms, _⟩ := h_nf_x_eval
    -- Reconstruct nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf
    constructor
    · -- Atom part
      intro a
      cases a with
      | pred p k =>
        match k with
        | ⟨0, _⟩ =>
          -- sub_nf.1 (.pred p 0) = nf_x.1 (.pred p 0) from h_compat
          have h := h_nf_x_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h ⊢
          simp only [nf_x_compat_check, List.all_eq_true] at h_compat
          have hc := h_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
          rw [beq_iff_eq] at hc
          rw [← hc]; exact h
        | ⟨1, _⟩ =>
          -- sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)
          -- atom_eval M (fun _ => t) (.pred p 0) ↔ parent_atoms (.pred p 0) = true
          have h := h_atoms (.pred p ⟨0, by omega⟩)
          simp only [atom_eval, Fin.cons] at h ⊢
          rw [h_t_compat p]; exact h
      | order k l h_ne =>
        match k, l, h_ne with
        | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
        | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
        | ⟨0, _⟩, ⟨1, _⟩, _ =>
          -- sub_nf.1 (.order 0 1 _) is the x < t order
          simp only [atom_eval, Fin.cons]
          constructor
          · intro h_x_lt_t; exact absurd (lt_trans h_t_lt_x h_x_lt_t) (lt_irrefl _)
          · intro h_eq; rw [h_eq] at h_lt; exact absurd h_lt (by simp)
        | ⟨1, _⟩, ⟨0, _⟩, _ =>
          -- sub_nf.1 (.order 1 0 _) = true means t < x
          simp only [atom_eval, Fin.cons]
          constructor
          · intro _; exact h_gt
          · intro _; exact h_t_lt_x
    · -- Quantifier part: ∀ ssn, (∃ y, nf_eval_nf M 0 3 [y,x,t] ssn) ↔ sub_nf.2 ssn = true
      -- Helper: x-predicates and t-predicates from h_nf_x_atoms and h_atoms
      have h_x_pred : ∀ p : sig.preds,
          M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
        intro p; have h := h_nf_x_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h
      have h_t_pred : ∀ p : sig.preds,
          M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
        intro p; have h := h_atoms (.pred p ⟨0, by omega⟩)
        simp only [atom_eval] at h; exact h
      -- Extract endpointLeft as pre_conditions_at_t_until
      have h_vea_left : vea.endpointLeft =
          (⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩ : TemporalPred) := by
        have := congrArg (fun s => s.snd.endpointLeft) h_vea_eq
        simp at this; exact this.symm
      simp only [TemporalPred.eval_at] at h_endLeft
      rw [h_vea_left] at h_endLeft
      simp only [TemporalPred.eval_at] at h_endLeft
      -- h_endLeft : temporal_truth M atomMap t (pre_conditions_at_t_until ...)
      -- h_endRight_temporal.2 : temporal_truth M atomMap x (formula_conjList right_conjuncts)
      have h_right_conj := h_endRight_temporal.2
      -- Helper: the filterMap function for pre_conditions
      let pre_fn := fun ssn' : NormalForm sig 0 3 =>
        if ssn_xt_compatible ssn' nf_x_1var parent_atoms true false then
          let zone := ssn_zone_until ssn'
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')
          match zone with
          | .below_t =>
            if sub_nf.2 ssn' then some (Formula.snce char_y Formula.top)
            else some (Formula.snce char_y Formula.top).neg
          | .eq_t =>
            if sub_nf.2 ssn' then some char_y
            else some char_y.neg
          | _ => none
        else none
      -- Helper: the filterMap function for right_conjuncts
      let right_fn := fun ssn' : NormalForm sig 0 3 =>
        if ssn_xt_compatible ssn' nf_x_1var parent_atoms true false then
          let zone := ssn_zone_until ssn'
          let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')
          match zone with
          | .eq_x =>
            if sub_nf.2 ssn' then some char_y
            else some char_y.neg
          | .above_x =>
            if sub_nf.2 ssn' then some (Formula.untl char_y Formula.top)
            else some (Formula.untl char_y Formula.top).neg
          | _ => none
        else none
      -- h_endLeft unfolds to formula_conjList of pre_fn applied to Fintype.elems
      have h_endLeft_conj : ∀ φ ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn,
          temporal_truth M atomMap t φ := by
        have : pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms =
            formula_conjList ((Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn) := rfl
        rw [this] at h_endLeft
        exact (formula_conjList_iff M atomMap t _).mp h_endLeft
      -- h_right_conj unfolds to formula_conjList of right_fn
      have h_right_conj_all : ∀ φ ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn,
          temporal_truth M atomMap x φ := by
        exact (formula_conjList_iff M atomMap x _).mp h_right_conj
      -- Helper: ref_nf_x_1var = nf_x_1var (since nf_x_compat_check says nf_x matches sub_nf)
      have h_ref_eq_nfx : (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) = nf_x_1var := by
        funext a; cases a with
        | pred p k =>
          simp only [nf_x_compat_check, List.all_eq_true] at h_compat
          have hc := h_compat p (Multiset.mem_toList.mpr (Fintype.complete p))
          rw [beq_iff_eq] at hc; exact hc.symm
        | order i j h_ne => exact absurd (Fin.ext (by omega) : i = j) h_ne
      -- Helper: membership in filterMap
      have h_ssn_in_elems : ∀ ssn' : NormalForm sig 0 3,
          ssn' ∈ (Fintype.elems (α := NormalForm sig 0 3)).val.toList :=
        fun ssn' => Multiset.mem_toList.mpr (Fintype.complete ssn')
      -- Per-ssn proof
      intro ssn
      by_cases h_ssn_xt : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true
      · -- xt-compatible case
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        · -- below_t: Since(char_y, ⊤) at t ↔ ∃ y
          have h_bridge := below_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_endLeft_conj _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_endLeft_conj _ h_in)
        · -- eq_t: char_y at t ↔ ∃ y
          have h_bridge := eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_endLeft_conj _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap pre_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .below_t => _ | .eq_t => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_endLeft_conj _ h_in)
        · -- between_tx: bracket handles this via per-SSN pointTypes
          have h_bridge := between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          -- Extract bracket from h_vea_eq via dependent type cast
          subst h_n_eq
          have h_vea_eq3 := eq_of_heq (Sigma.mk.inj h_vea_eq).2
          have h_bracket_eq := congrArg VecEA2.bracket h_vea_eq3
          rw [← h_bracket_eq] at h_bracket
          -- h_bracket now has the explicit bracket structure with per-SSN pointTypes
          -- Define neg_between and seg_guard for convenience
          let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn' =>
            ssn_xt_compatible ssn' nf_x_1var parent_atoms true false &&
            (ssn_zone_until ssn' == .between_tx) && !sub_nf.2 ssn'
          let seg_guard : TemporalPred :=
            ⟨formula_conjList (neg_between.map fun ssn' =>
              (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn')).neg)⟩
          constructor
          · -- → direction: ∃ y → sub_nf.2 ssn = true
            intro h_exist
            by_contra h_neg
            -- Get y via bridge
            obtain ⟨y, h_ty, h_yx, h_y_pred⟩ := h_bridge.mp h_exist
            -- ssn is in neg_between
            have h_ssn_in_neg : ssn ∈ neg_between := by
              rw [List.mem_filter]
              exact ⟨h_ssn_in_elems ssn, by simp [h_ssn_xt, h_zone, h_neg]⟩
            -- seg_guard includes ¬char_y(nf_y_proj ssn)
            -- From h_bracket, seg_guard holds on every segment of (t, x).
            -- y ∈ (t, x). We need: seg_guard holds at y.
            -- The bracket is: BracketFormula.holds with per-SSN pointTypes and constant seg_guard.
            -- Unfolding: there exist strictly increasing witnesses w_0 < ... < w_{k-1} in (t, x)
            -- with per-SSN pointTypes, and seg_guard on each segment.
            -- y is either a witness or in a segment.
            -- If y is a witness w_i: w_i satisfies char_y(pos_between[σ(i)]), which is a POSITIVE ssn.
            --   Since ssn is NEGATIVE, nf_y_proj ssn ≠ nf_y_proj pos_between[σ(i)].
            --   But char_y is determined by nf_y_proj. If y satisfies both char_y(nf_y_proj ssn) AND
            --   char_y(pos_between[σ(i)]), then nf_y_proj ssn = nf_y_proj pos_between[σ(i)] (by char_y injectivity).
            --   But they differ (positive vs negative) → contradiction... actually they could have
            --   the same y-proj but differ in other atoms. No, between_tx SSNs with same nf_y_proj
            --   and same x/t compatibility are identical. So nf_y_proj ssn ≠ nf_y_proj pos_between[σ(i)]
            --   means char_y(nf_y_proj ssn) can't hold at y if char_y(pos_between[σ(i)]) holds.
            rcases bracket_constant_seg_dichotomy M atomMap
              pos_between.length t x _ seg_guard h_bracket y h_ty h_yx with
              h_seg | ⟨i, h_pt⟩
            · -- Case 1: seg_guard holds at y — contradicts h_y_pred
              simp only [TemporalPred.eval_at] at h_seg
              rw [formula_conjList_iff] at h_seg
              have h_neg_char := h_seg _
                (List.mem_map.mpr ⟨ssn, h_ssn_in_neg, rfl⟩)
              simp only [Formula.neg, temporal_truth] at h_neg_char
              apply h_neg_char
              rw [nf_depth0_char_formula_correct]
              intro p; simp only [nf_y_proj]; exact h_y_pred p
            · -- Case 2: pointType i holds at y — ssn = pos_between.get (σ i)
              simp only [TemporalPred.eval_at] at h_pt
              rw [nf_depth0_char_formula_correct] at h_pt
              -- Extract compat/zone/pos info for pos_between.get (σ i) from membership
              have h_σi_mem : pos_between.get (σ i) ∈ pos_between := List.get_mem pos_between (σ i)
              rw [List.mem_filter] at h_σi_mem
              obtain ⟨_, h_σi_raw⟩ := h_σi_mem
              simp only [Bool.and_eq_true, beq_iff_eq] at h_σi_raw
              obtain ⟨⟨h_σi_compat_raw, h_σi_zone⟩, h_σi_pos⟩ := h_σi_raw
              -- Destructure ssn_xt_compatible for both SSNs
              have h1_compat := h_ssn_xt
              simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq,
                List.all_eq_true] at h1_compat h_σi_compat_raw
              obtain ⟨⟨⟨⟨h1_x, h1_t⟩, h1_ord1⟩, h1_ord2⟩, _⟩ := h1_compat
              obtain ⟨⟨⟨⟨h2_x, h2_t⟩, h2_ord1⟩, h2_ord2⟩, _⟩ := h_σi_compat_raw
              -- Derive y-pred equality from h_y_pred and h_pt
              have h_pred_eq : ∀ p, ssn (.pred p ⟨0, by omega⟩) =
                  (pos_between.get (σ i)) (.pred p ⟨0, by omega⟩) := by
                intro p
                have h1 := h_y_pred p
                have h2 := h_pt p
                simp only [nf_y_proj] at h2
                exact Bool.eq_iff_iff.mpr (h1.symm.trans h2)
              obtain ⟨h1_ylx, h1_xly, h1_ylt, h1_tly⟩ := between_tx_order_atoms ssn h_zone
              obtain ⟨h2_ylx, h2_xly, h2_ylt, h2_tly⟩ := between_tx_order_atoms _ h_σi_zone
              have h_ssn_eq : ssn = pos_between.get (σ i) := by
                funext a; cases a with
                | pred p k =>
                  match k with
                  | ⟨0, _⟩ => exact h_pred_eq p
                  | ⟨1, _⟩ =>
                    exact (h1_x p (Multiset.mem_toList.mpr (Fintype.complete p))).trans
                      (h2_x p (Multiset.mem_toList.mpr (Fintype.complete p))).symm
                  | ⟨2, _⟩ =>
                    exact (h1_t p (Multiset.mem_toList.mpr (Fintype.complete p))).trans
                      (h2_t p (Multiset.mem_toList.mpr (Fintype.complete p))).symm
                | order k l h_ne =>
                  match k, l, h_ne with
                  | ⟨0, _⟩, ⟨1, _⟩, _ => rw [h1_ylx, h2_ylx]
                  | ⟨1, _⟩, ⟨0, _⟩, _ => rw [h1_xly, h2_xly]
                  | ⟨0, _⟩, ⟨2, _⟩, _ => rw [h1_ylt, h2_ylt]
                  | ⟨2, _⟩, ⟨0, _⟩, _ => rw [h1_tly, h2_tly]
                  | ⟨1, _⟩, ⟨2, _⟩, _ => exact h1_ord2.trans h2_ord2.symm
                  | ⟨2, _⟩, ⟨1, _⟩, _ => exact h1_ord1.trans h2_ord1.symm
                  | ⟨0, _⟩, ⟨0, _⟩, h => exact absurd rfl h
                  | ⟨1, _⟩, ⟨1, _⟩, h => exact absurd rfl h
                  | ⟨2, _⟩, ⟨2, _⟩, h => exact absurd rfl h
              rw [h_ssn_eq] at h_neg
              exact absurd h_σi_pos h_neg
          · -- ← direction: sub_nf.2 ssn = true → ∃ y
            intro h_pos
            -- ssn ∈ pos_between
            have h_ssn_in_pos : ssn ∈ pos_between := by
              rw [List.mem_filter]
              exact ⟨h_ssn_in_elems ssn, by simp [h_ssn_xt, h_zone, h_pos]⟩
            -- Find j such that pos_between[j] = ssn
            obtain ⟨j, hj⟩ := List.get_of_mem h_ssn_in_pos
            obtain ⟨w, h_tw, h_wx, h_w_pt⟩ := bracket_extract_witness M atomMap
              pos_between.length t x _ _ h_bracket (σ.symm j)
            simp only [TemporalPred.eval_at] at h_w_pt
            rw [nf_depth0_char_formula_correct] at h_w_pt
            apply h_bridge.mpr
            refine ⟨w, h_tw, h_wx, fun p => ?_⟩
            have := h_w_pt p
            simp only [nf_y_proj, Equiv.apply_symm_apply] at this
            rw [← hj]; exact this
        · -- eq_x: char_y at x ↔ ∃ y
          have h_bridge := eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_right_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_right_conj_all _ h_in)
        · -- above_x: Until(char_y, ⊤) at x ↔ ∃ y
          have h_bridge := above_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
            h_t_lt_x h_ssn_xt h_zone h_x_pred h_t_pred
          constructor
          · intro h_exist
            by_contra h_neg
            have h_in : (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top).neg ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [show sub_nf.2 ssn = false from Bool.eq_false_iff.mpr h_neg]; rfl
            have := h_right_conj_all _ h_in
            simp only [Formula.neg, temporal_truth] at this
            exact this (h_bridge.mpr h_exist)
          · intro h_pos
            have h_in : (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ∈
                (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap right_fn := by
              rw [List.mem_filterMap]
              refine ⟨ssn, h_ssn_in_elems ssn, ?_⟩
              show (if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then _ else _) = _
              rw [h_ssn_xt]; show (match ssn_zone_until ssn with | .eq_x => _ | .above_x => _ | _ => _) = _
              rw [h_zone]; show (if sub_nf.2 ssn then _ else _) = _
              rw [h_pos]; rfl
            exact h_bridge.mp (h_right_conj_all _ h_in)
        · -- inconsistent zone: ssn_xt_compatible = true includes ssn_order_consistent = true,
          -- which is incompatible with ssn_zone_until = .inconsistent.
          exfalso
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_ssn_xt
          simp only [ssn_zone_until] at h_zone
          simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
            Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_ssn_xt
          revert h_zone; split_ifs <;> (intro h; try exact absurd h (by decide)) <;> simp_all
      · -- NOT xt-compatible: both sides false via h_ssn_compat
        constructor
        · -- ∃ y → sub_nf.2 ssn = true
          -- If ∃ y with nf_eval, ssn must be xt-compatible (semantic argument).
          intro h_exist; exfalso
          obtain ⟨y, h_ssn_eval⟩ := h_exist
          have h_xt_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms true false = true := by
            simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
            refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
            · intro p _
              have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
              cases hsub : (nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
              cases hssn : ssn (.pred p ⟨1, by omega⟩) <;>
              first | rfl | (exfalso; simp_all)
            · intro p _
              have h1 : M.interp p t ↔ ssn (.pred p ⟨2, by omega⟩) = true := by
                have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
              cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
              cases hssn : ssn (.pred p ⟨2, by omega⟩) <;>
              first | rfl | (exfalso; simp_all [h_t_pred])
            · have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by simp [Fin.ext_iff]))
              simp only [atom_eval, Fin.cons] at h; exact h.mp h_t_lt_x
            · have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by simp [Fin.ext_iff]))
              simp only [atom_eval, Fin.cons] at h
              cases hssn : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by simp [Fin.ext_iff]))
              · rfl
              · exact absurd (h.mpr hssn) (not_lt_of_gt h_t_lt_x)
            · exact ssn_order_consistent_of_eval ssn h_ssn_eval
          exact absurd h_xt_compat h_ssn_xt
        · intro h_pos
          exfalso
          have := h_ssn_compat ssn h_pos
          rw [h_ref_eq_nfx] at this
          exact absurd this h_ssn_xt
  · -- Incompatible case: empty list, contradiction
    simp at h_in_list
/-! ## Until Case (t < x) -/

set_option maxHeartbeats 1600000 in
/-- Until case of the enriched bypass: when sub_nf says t < x. -/
private theorem existPart_succ_n1_bypass_k0_until
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Syntactic compatibility checks for sub_nf.
  -- 1. t-predicate compatibility: sub_nf.1 (.pred p 1) = parent_atoms (.pred p 0)
  -- 2. ssn compatibility: all positive ssn match the canonical reference nf_x_1var
  -- Use a canonical reference nf_x_1var built from sub_nf.1 (same for all compatible nf_x):
  let ref_nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  by_cases h_t_compat : ∀ p : sig.preds,
      sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩)
  · by_cases h_ssn_compat : ∀ ssn : NormalForm sig 0 3,
        sub_nf.2 ssn = true →
        ssn_xt_compatible ssn ref_nf_x_1var parent_atoms true false = true
    · -- Both checks pass: use enriched_bypass_until with full biconditional
      let vvec := enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms
      exact ⟨vvec, fun M h_UZ h_SZ t h_atoms => by
        show temporal_truth M atomMap t (enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms) ↔ _
        simp only [enriched_bypass_until]
        rw [VVecEA2.translateLeft_correct]
        simp only [VVecEA2.holdsLeft]
        constructor
        · -- Forward: holdsLeft → ∃ x, nf_eval
          exact forward_nf_eval_of_holdsLeft atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms h_t_compat h_ssn_compat
        · -- Backward: ∃ x, nf_eval → holdsLeft
          exact backward_holdsLeft_of_nf_eval atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms⟩
    · -- ¬ssn_compat: some positive ssn is xt-incompatible → existential unsatisfiable
      push_neg at h_ssn_compat
      obtain ⟨ssn_bad, h_pos_bad, h_incompat_bad⟩ := h_ssn_compat
      refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
      simp only [temporal_truth]
      constructor
      · exact fun h => absurd h id
      · intro ⟨x, h_eval⟩
        obtain ⟨h_atom, h_quant⟩ := h_eval
        -- sub_nf.2 ssn_bad = true → ∃ y, nf_eval_nf M 0 3 (y,x,t₀) ssn_bad
        have ⟨y, h_ssn_eval⟩ := (h_quant ssn_bad).mpr h_pos_bad
        -- From h_ssn_eval + h_atom + h_atoms, derive ssn_xt_compatible
        -- But h_incompat_bad says it's NOT compatible → contradiction
        -- The key: ref_nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0)
        -- And h_atom says atom_eval M (Fin.cons x (fun _ => t₀)) (.pred p 0) ↔ sub_nf.1 (.pred p 0) = true
        -- So M.interp p x ↔ ref_nf_x_1var (.pred p 0) = true
        -- Similarly for t's atoms. So ssn_bad must be xt-compatible with ref_nf_x_1var.
        have h_x_pred : ∀ p : sig.preds,
            M.interp p x ↔ ref_nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atom (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
        have h_t_pred : ∀ p : sig.preds,
            M.interp p t₀ ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h; exact h
        have h_t_lt_x : t₀ < x := by
          have h := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
          unfold atom_eval at h; exact h.mpr h_gt
        -- From h_ssn_eval, ssn_bad's atoms at indices 1,2 must match x and t₀
        -- and its orders must be consistent. This forces ssn_xt_compatible = true.
        -- Derive contradiction with h_incompat_bad.
        have h_xt_compat : ssn_xt_compatible ssn_bad ref_nf_x_1var parent_atoms true false = true := by
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
          refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
          · -- x-preds: ssn_bad (.pred p 1) = ref_nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0)
            intro p _
            have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
            -- h1 : M.interp p x ↔ ssn_bad (.pred p 1) = true
            -- h_x_pred p : M.interp p x ↔ ref_nf_x_1var (.pred p 0) = true
            -- ref_nf_x_1var (.pred p 0) = sub_nf.1 (.pred p 0) by definition
            cases hsub : (ref_nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
            cases hssn : ssn_bad (.pred p ⟨1, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t-preds: ssn_bad (.pred p 2) = parent_atoms (.pred p 0)
            intro p _
            have h1 : M.interp p t₀ ↔ ssn_bad (.pred p ⟨2, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
            have h2 := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h2
            -- h2 : M.interp p t₀ ↔ parent_atoms (.pred p 0) = true
            cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
            cases hssn : ssn_bad (.pred p ⟨2, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t < x order: ssn_bad (.order ⟨2,_⟩ ⟨1,_⟩ _) = true
            have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            unfold atom_eval at h; exact h.mp h_t_lt_x
          · -- ¬(x < t) order: ssn_bad (.order ⟨1,_⟩ ⟨2,_⟩ _) = false
            have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            unfold atom_eval at h
            cases hssn : ssn_bad (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            · rfl
            · exact absurd (h.mpr hssn) (not_lt_of_gt h_t_lt_x)
          · exact ssn_order_consistent_of_eval ssn_bad h_ssn_eval
        exact absurd h_xt_compat h_incompat_bad
  · -- ¬t_compat: existential impossible (atom at index 1 can't match)
    refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · exact fun h => absurd h id
    · intro ⟨x, h_eval⟩
      push_neg at h_t_compat; obtain ⟨p, hp⟩ := h_t_compat
      obtain ⟨h_atom, _⟩ := h_eval
      have h_sub : M.interp p t₀ ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
      have h_par := (h_atoms (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h_par
      cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
      cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
      simp_all

/-! ## Since Direction Zone Order Extraction

Extract order atom values from `ssn_zone_since ssn = zone`.
Combined with `ssn_xt_compatible ... false true = true`, they give all 6 order atoms
needed for the Since-direction zone bridge lemmas. -/

/-- Extract x < t order condition from ssn_xt_compatible (Since direction). -/
private theorem ssn_xt_compat_xt_order {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true) :
    ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
  simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
  exact ⟨h_compat.1.1.2, h_compat.1.2⟩

set_option maxHeartbeats 400000 in
/-- Extract y < x from since below_t zone. -/
private theorem since_zone_below_t_yx {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.below_t) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(x < y) from since below_t zone. -/
private theorem since_zone_below_t_xy {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.below_t) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(y < x), ¬(x < y) from since eq_t zone. -/
private theorem since_zone_eq_t_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.eq_t) :
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract x < y, y < t from since between_tx zone. -/
private theorem since_zone_between_tx_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.between_tx) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract ¬(y < t), ¬(t < y), x < y from since eq_x zone. -/
private theorem since_zone_eq_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.eq_x) :
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

set_option maxHeartbeats 400000 in
/-- Extract t < y from since above_x zone. -/
private theorem since_zone_above_x_orders {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3)
    (h_zone : ssn_zone_since ssn = YZone.above_x) :
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false := by
  simp only [ssn_zone_since] at h_zone
  revert h_zone; split_ifs <;> simp_all

/-! ## Since Direction Zone Bridges

These connect the temporal formulas used in `enriched_vecEA2_since` to the 3-var
existentials for the Since direction (x < t). -/

/-- Since below_x: Since(char_y, top) at x ↔ ∃ y, nf_eval (y < x zone). -/
private theorem since_below_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.below_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have h_yx := since_zone_below_t_yx ssn h_zone
  have h_xy := since_zone_below_t_xy ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  constructor
  · intro ⟨y, h_yx_lt, h_char_y, _⟩
    refine ⟨y, ?_⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    apply reconstruct_nf_eval_3var M ssn y x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · exact ⟨fun _ => h_yx, fun _ => h_yx_lt⟩
    · exact ⟨fun _ => h_yt, fun _ => lt_trans h_yx_lt h_xt⟩
    · constructor
      · intro h; exact absurd (lt_trans h_yx_lt h) (lt_irrefl _)
      · intro h; simp_all
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · constructor
      · intro h; exact absurd (lt_trans h (lt_trans h_yx_lt h_xt)) (lt_irrefl _)
      · intro h; simp_all
    · constructor
      · intro h; exact absurd (lt_trans h_xt h) (lt_irrefl _)
      · intro h; simp_all
  · intro ⟨y, h_nf⟩
    have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord
    simp only [Fin.cons] at h_ord
    refine ⟨y, h_ord.mpr h_yx, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr
      (extract_y_preds M ssn y x t h_nf)

/-- Since eq_x: char_y at x ↔ ∃ y, nf_eval (y = x zone). -/
private theorem since_eq_x_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.eq_t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yx, h_xy⟩ := since_zone_eq_t_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  have h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
    simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true] at h_compat
    simp only [ssn_order_consistent, Bool.and_eq_true, Bool.not_eq_true', Bool.or_eq_true,
      Bool.not_eq_eq_eq_not, Bool.not_true, beq_iff_eq] at h_compat
    simp_all
  constructor
  · intro h_char_y
    rw [nf_depth0_char_formula_correct] at h_char_y
    refine ⟨x, ?_⟩
    apply reconstruct_nf_eval_3var M ssn x x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_yx ▸ h⟩
    · exact ⟨fun _ => h_yt, fun _ => h_xt⟩
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_xy ▸ h⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · exact ⟨fun h => absurd (lt_trans h_xt h) (lt_irrefl _), fun h => by cases h_ty ▸ h⟩
    · exact ⟨fun h => absurd (lt_trans h_xt h) (lt_irrefl _), fun h => by cases h_xt_ord.1 ▸ h⟩
  · intro ⟨y, h_nf⟩
    have h_y_preds := extract_y_preds M ssn y x t h_nf
    have h_ord_yx := h_nf (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
    have h_ord_xy := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord_yx h_ord_xy
    simp only [Fin.cons] at h_ord_yx h_ord_xy
    have h_y_eq_x : y = x := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact absurd (h_ord_yx.mp h_lt) (by rw [h_yx]; decide)
      · exact absurd (h_ord_xy.mp h_gt) (by rw [h_xy]; decide)
    subst h_y_eq_x
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds

set_option maxHeartbeats 800000 in
/-- Since between_xt: zone bridge for x < y < t (bracket zone). -/
private theorem since_between_xt_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.between_tx)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
    (∃ y, x < y ∧ y < t ∧ ∀ p, M.interp p y ↔ ssn (.pred p ⟨0, by omega⟩) = true) := by
  have ⟨h_xy, h_yt, h_yx, h_ty⟩ := since_zone_between_tx_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  constructor
  · intro ⟨y, h_nf⟩
    refine ⟨y, ?_, ?_, extract_y_preds M ssn y x t h_nf⟩
    · have h_ord := h_nf (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_xy
    · have h_ord := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
      simp only [atom_eval, Fin.cons] at h_ord
      exact h_ord.mpr h_yt
  · intro ⟨y, h_x_lt_y, h_y_lt_t, h_y_preds⟩
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t h_y_preds
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · constructor
      · intro h; exact absurd (lt_trans h_x_lt_y h) (lt_irrefl _)
      · intro h; simp_all
    · exact ⟨fun _ => h_yt, fun _ => h_y_lt_t⟩
    · exact ⟨fun _ => h_xy, fun _ => h_x_lt_y⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · constructor
      · intro h; exact absurd (lt_trans h_y_lt_t h) (lt_irrefl _)
      · intro h; simp_all
    · constructor
      · intro h; exact absurd (lt_trans h_xt h) (lt_irrefl _)
      · intro h; simp_all

/-- Since eq_t: char_y at t ↔ ∃ y, nf_eval (y = t zone). -/
private theorem since_eq_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.eq_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_yt, h_ty, h_xy, h_yx⟩ := since_zone_eq_x_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  constructor
  · intro h_char_y
    rw [nf_depth0_char_formula_correct] at h_char_y
    refine ⟨t, ?_⟩
    apply reconstruct_nf_eval_3var M ssn t x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · exact ⟨fun h => absurd h (not_lt_of_gt h_xt), fun h => by cases h_yx ▸ h⟩
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_yt ▸ h⟩
    · exact ⟨fun _ => h_xy, fun _ => h_xt⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · exact ⟨fun h => absurd h (lt_irrefl _), fun h => by cases h_ty ▸ h⟩
    · exact ⟨fun h => absurd h (not_lt_of_gt h_xt), fun h => by cases h_xt_ord.1 ▸ h⟩
  · intro ⟨y, h_nf⟩
    have h_y_preds := extract_y_preds M ssn y x t h_nf
    have h_ord_yt := h_nf (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    have h_ord_ty := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord_yt h_ord_ty
    simp only [Fin.cons] at h_ord_yt h_ord_ty
    have h_y_eq_t : y = t := by
      by_contra h_ne
      rcases lt_or_gt_of_ne h_ne with h_lt | h_gt
      · exact absurd (h_ord_yt.mp h_lt) (by rw [h_yt]; decide)
      · exact absurd (h_ord_ty.mp h_gt) (by rw [h_ty]; decide)
    subst h_y_eq_t
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr h_y_preds

set_option maxHeartbeats 800000 in
/-- Since above_t: Until(char_y, top) at t ↔ ∃ y, nf_eval (y > t zone). -/
private theorem since_above_t_temporal_iff
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_compat : ssn_xt_compatible ssn nf_x_1var parent_atoms false true = true)
    (h_zone : ssn_zone_since ssn = YZone.above_x)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true) :
    temporal_truth M atomMap t
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) ↔
    (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) := by
  have ⟨h_ty, h_yt, h_xy, h_yx⟩ := since_zone_above_x_orders ssn h_zone
  have h_xt_ord := ssn_xt_compat_xt_order ssn nf_x_1var parent_atoms h_compat
  have h_x_ssn := ssn_xt_compat_x_preds ssn nf_x_1var parent_atoms false true h_compat
  have h_t_ssn := ssn_xt_compat_t_preds ssn nf_x_1var parent_atoms false true h_compat
  constructor
  · intro ⟨y, h_ty_lt, h_char_y, _⟩
    rw [nf_depth0_char_formula_correct] at h_char_y
    refine ⟨y, ?_⟩
    apply reconstruct_nf_eval_3var M ssn y x t
      (fun p => by have := h_char_y p; simp only [nf_y_proj] at this; exact this)
      (fun p => by constructor
                   · intro h; rw [h_x_ssn p]; exact (h_x_pred p).mp h
                   · intro h; exact (h_x_pred p).mpr (by rw [← h_x_ssn p]; exact h))
      (fun p => by constructor
                   · intro h; rw [h_t_ssn p]; exact (h_t_pred p).mp h
                   · intro h; exact (h_t_pred p).mpr (by rw [← h_t_ssn p]; exact h))
    · constructor
      · intro h; exact absurd (lt_trans h (lt_trans h_xt h_ty_lt)) (lt_irrefl _)
      · intro h; simp_all
    · constructor
      · intro h; exact absurd (lt_trans h_ty_lt h) (lt_irrefl _)
      · intro h; simp_all
    · exact ⟨fun _ => h_xy, fun _ => lt_trans h_xt h_ty_lt⟩
    · exact ⟨fun _ => h_xt_ord.2, fun _ => h_xt⟩
    · exact ⟨fun _ => h_ty, fun _ => h_ty_lt⟩
    · constructor
      · intro h; exact absurd (lt_trans h_xt h) (lt_irrefl _)
      · intro h; simp_all
  · intro ⟨y, h_nf⟩
    have h_ord := h_nf (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval] at h_ord
    simp only [Fin.cons] at h_ord
    refine ⟨y, h_ord.mpr h_ty, ?_, fun z _ _ => by simp [temporal_truth, Formula.top]⟩
    exact (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y).mpr
      (extract_y_preds M ssn y x t h_nf)

private theorem since_between_xt_order_atoms {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) (h : ssn_zone_since ssn = YZone.between_tx) :
    ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
    ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
    ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false := by
  have ⟨h1, h2, h3, h4⟩ := since_zone_between_tx_orders ssn h
  exact ⟨h1, h3, h2, h4⟩

/-- The pre_conditions_at_t_since formula holds at t when h_eval_quant
    guarantees the correct truth values for all zone-based ssn conditions. -/
private theorem pre_conditions_at_t_since_holds
    {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (sub_nf : NormalForm sig 1 2)
    (nf_x_1var : NormalForm sig 0 1)
    (parent_atoms : AtomKind sig 1 → Bool)
    (x t : M.carrier) (h_xt : x < t)
    (h_x_pred : ∀ p : sig.preds, M.interp p x ↔ nf_x_1var (.pred p ⟨0, by omega⟩) = true)
    (h_t_pred : ∀ p : sig.preds, M.interp p t ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true)
    (h_eval_quant : ∀ (ssn : NormalForm sig 0 3),
      (∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) ↔
      sub_nf.2 ssn = true) :
    temporal_truth M atomMap t
      (pre_conditions_at_t_since atomMap h_surj sub_nf nf_x_1var parent_atoms) := by
  simp only [pre_conditions_at_t_since]
  rw [formula_conjList_iff]
  intro φ h_mem
  rw [List.mem_filterMap] at h_mem
  obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
  split_ifs at h_some with h_compat h_pos
  · revert h_some
    rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    · exact (since_eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
    · exact (since_above_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mpr ((h_eval_quant ssn).mpr h_pos)
  · revert h_some
    rcases h_zone : ssn_zone_since ssn with _ | _ | _ | _ | _ | _
    all_goals simp
    all_goals intro h_eq; subst h_eq
    · simp only [Formula.neg, temporal_truth]
      intro h_char
      have h_exist := (since_eq_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mp h_char
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos
    · simp only [Formula.neg, temporal_truth]
      intro h_untl
      have h_exist := (since_above_t_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_xt
        h_compat h_zone h_x_pred h_t_pred).mp h_untl
      exact absurd ((h_eval_quant ssn).mp h_exist) h_pos

/-! ## Since forward/backward proof lemmas -/

set_option maxHeartbeats 3200000 in
/-- Forward direction: holdsRight for the enriched Since VVecEA2 → ∃ x, nf_eval.
    Mirror of forward_nf_eval_of_holdsLeft for the Since direction. -/
private theorem forward_nf_eval_of_holdsRight
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : ∀ p : sig.preds, sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) parent_atoms false true = true) :
    (∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_since atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsRight M atomMap vea.snd t) →
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  sorry

set_option maxHeartbeats 3200000 in
/-- Backward direction: ∃ x, nf_eval → holdsRight for the enriched Since VVecEA2.
    Mirror of backward_holdsLeft_of_nf_eval for the Since direction. -/
private theorem backward_holdsRight_of_nf_eval
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap)
    (h_SZ : semantic_prior_SZ M atomMap)
    (t : M.carrier)
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) :
    (∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) →
    ∃ vea ∈ (List.flatMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          enriched_vecEA2_since atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms
        else []) Fintype.elems.val.toList),
      VecEA2.holdsRight M atomMap vea.snd t := by
  sorry

/-! ## Since Case (x < t) -/

/-- Since case of the enriched bypass: when sub_nf says x < t. -/
private theorem existPart_succ_n1_bypass_k0_since
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
    (sub_nf : NormalForm sig 1 2)
    (h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true) :
    ∃ (A : Formula),
      ∀ (M : OrderedMonadicStructure sig)
        (h_UZ : semantic_prior_UZ M atomMap)
        (h_SZ : semantic_prior_SZ M atomMap)
        (t : M.carrier),
        (∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) →
        (temporal_truth M atomMap t A ↔
         ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf) := by
  -- Mirror of existPart_succ_n1_bypass_k0_until for the Since direction (x < t).
  -- Syntactic compatibility checks for sub_nf.
  let ref_nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  by_cases h_t_compat : ∀ p : sig.preds,
      sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩)
  · by_cases h_ssn_compat : ∀ ssn : NormalForm sig 0 3,
        sub_nf.2 ssn = true →
        ssn_xt_compatible ssn ref_nf_x_1var parent_atoms false true = true
    · -- Both checks pass: use enriched_bypass_since with VecEA2 infrastructure
      let vvec := enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms
      exact ⟨vvec, fun M h_UZ h_SZ t h_atoms => by
        show temporal_truth M atomMap t (enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms) ↔ _
        simp only [enriched_bypass_since]
        rw [VVecEA2.translateRight_correct]
        simp only [VVecEA2.holdsRight]
        constructor
        · -- Forward: holdsRight → ∃ x, nf_eval
          exact forward_nf_eval_of_holdsRight atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms h_t_compat h_ssn_compat
        · -- Backward: ∃ x, nf_eval → holdsRight
          exact backward_holdsRight_of_nf_eval atomMap h_surj char_1 char_1_correct
            parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms⟩
    · -- ¬ssn_compat: some positive ssn is xt-incompatible → existential unsatisfiable
      push_neg at h_ssn_compat
      obtain ⟨ssn_bad, h_pos_bad, h_incompat_bad⟩ := h_ssn_compat
      refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
      simp only [temporal_truth]
      constructor
      · exact fun h => absurd h id
      · intro ⟨x, h_eval⟩
        obtain ⟨h_atom, h_quant⟩ := h_eval
        have ⟨y, h_ssn_eval⟩ := (h_quant ssn_bad).mpr h_pos_bad
        have h_x_pred : ∀ p : sig.preds,
            M.interp p x ↔ ref_nf_x_1var (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atom (.pred p ⟨0, by omega⟩); unfold atom_eval at h; exact h
        have h_t_pred : ∀ p : sig.preds,
            M.interp p t₀ ↔ parent_atoms (.pred p ⟨0, by omega⟩) = true := by
          intro p; have h := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h; exact h
        have h_x_lt_t : x < t₀ := by
          have h := h_atom (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
          unfold atom_eval at h; exact h.mpr h_lt
        have h_xt_compat : ssn_xt_compatible ssn_bad ref_nf_x_1var parent_atoms false true = true := by
          simp only [ssn_xt_compatible, Bool.and_eq_true, beq_iff_eq, List.all_eq_true]
          refine ⟨⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩, ?_⟩
          · -- x-preds
            intro p _
            have h1 := h_ssn_eval (.pred p ⟨1, by omega⟩); unfold atom_eval at h1
            cases hsub : (ref_nf_x_1var (.pred p ⟨0, by omega⟩) : Bool) <;>
            cases hssn : ssn_bad (.pred p ⟨1, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- t-preds
            intro p _
            have h1 : M.interp p t₀ ↔ ssn_bad (.pred p ⟨2, by omega⟩) = true := by
              have h := h_ssn_eval (.pred p ⟨2, by omega⟩); unfold atom_eval at h; exact h
            have h2 := h_atoms (.pred p ⟨0, by omega⟩); simp only [atom_eval] at h2
            cases hpar : parent_atoms (.pred p ⟨0, by omega⟩) <;>
            cases hssn : ssn_bad (.pred p ⟨2, by omega⟩) <;>
            first | rfl | (exfalso; simp_all)
          · -- ¬(t < x) order: ssn_bad (.order ⟨2,_⟩ ⟨1,_⟩ _) = false
            have h := h_ssn_eval (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            unfold atom_eval at h
            cases hssn : ssn_bad (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
            · rfl
            · exact absurd (h.mpr hssn) (not_lt_of_gt h_x_lt_t)
          · -- x < t order: ssn_bad (.order ⟨1,_⟩ ⟨2,_⟩ _) = true
            have h := h_ssn_eval (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
            unfold atom_eval at h; exact h.mp h_x_lt_t
          · exact ssn_order_consistent_of_eval ssn_bad h_ssn_eval
        exact absurd h_xt_compat h_incompat_bad
  · -- ¬t_compat: existential impossible (atom at index 1 can't match)
    refine ⟨Formula.bot, fun M _ _ t₀ h_atoms => ?_⟩
    simp only [temporal_truth]
    constructor
    · exact fun h => absurd h id
    · intro ⟨x, h_eval⟩
      push_neg at h_t_compat; obtain ⟨p, hp⟩ := h_t_compat
      obtain ⟨h_atom, _⟩ := h_eval
      have h_sub : M.interp p t₀ ↔ sub_nf.1 (.pred p ⟨1, by omega⟩) = true := by
        have h := h_atom (.pred p ⟨1, by omega⟩); unfold atom_eval at h; exact h
      have h_par := (h_atoms (.pred p ⟨0, by omega⟩))
      simp only [atom_eval] at h_par
      cases hsub : sub_nf.1 (.pred p ⟨1, by omega⟩) <;>
      cases hpar : parent_atoms (.pred p ⟨0, by omega⟩)
      · exact hp (by rw [hsub, hpar])
      · exact absurd (h_sub.mp (h_par.mpr hpar)) (by rw [hsub]; exact Bool.false_ne_true)
      · exact absurd (h_par.mp (h_sub.mpr hsub)) (by rw [hpar]; exact Bool.false_ne_true)
      · exact hp (by rw [hsub, hpar])

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
  -- Case split on order booleans in sub_nf.1 to determine the x-t zone.
  -- For each zone, construct the formula and prove it correct.
  -- This follows the structure of nf_2var_exist_depth0_tl.
  match h_gt : sub_nf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)),
        h_lt : sub_nf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) with
  | true, true =>
    -- Both orders true: existential impossible
    exact ⟨Formula.bot, fun M _ _ t h_atoms => by
      simp only [temporal_truth]
      exact ⟨fun h => absurd h id, fun ⟨x, h_eval⟩ =>
        absurd (lt_trans
          ((zone_from_nf_eval M sub_nf t x h_eval).1 h_gt)
          ((zone_from_nf_eval M sub_nf t x h_eval).2.1 h_lt))
          (lt_irrefl _)⟩⟩
  | true, false =>
    -- Until direction (t < x): enriched bypass via VecEA2
    exact existPart_succ_n1_bypass_k0_until atomMap h_surj char_1 char_1_correct
      parent_atoms sub_nf h_gt h_lt
  | false, true =>
    -- Since direction (x < t)
    exact existPart_succ_n1_bypass_k0_since atomMap h_surj char_1 char_1_correct
      parent_atoms sub_nf h_gt h_lt
  | false, false =>
    -- Equality direction (x = t)
    exact existPart_succ_n1_bypass_k0_eq atomMap h_surj char_1 char_1_correct
      parent_atoms sub_nf h_gt h_lt

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
