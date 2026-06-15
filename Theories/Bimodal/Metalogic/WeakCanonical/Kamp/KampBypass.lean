import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
import Bimodal.Metalogic.WeakCanonical.Kamp.ZoneBridge
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
    (parent_atoms : AtomKind sig 1 → Bool) : Σ n, VecEA2 n :=
  -- Collect positive between_tx ssns (need bracket witnesses)
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) &&
    sub_nf.2 ssn
  -- Collect negative between_tx ssns (need segment guards)
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) &&
    !sub_nf.2 ssn
  -- Build the segment guard: conjunction of neg char_y for negative between_tx ssns
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  -- Build the bracket formula
  let n := pos_between.length
  let bracket : BracketFormula n :=
    { pointTypes := fun i =>
        nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]'(by omega)))
      segmentTypes := fun _ => seg_guard }
  -- Build the endpoint left (at t): pre-conditions for y < t and y = t
  let endLeft : TemporalPred :=
    ⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  -- Build the endpoint right (at x): char_1(nf_x) + conditions for y = x, y > x
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
  ⟨n, { endpointLeft := endLeft, endpointRight := endRight, bracket := bracket }⟩

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
    { disjuncts := (Fintype.elems (α := NormalForm sig 1 1)).val.toList.filterMap fun nf_x =>
        if nf_x_compat_check sub_nf nf_x then
          let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
            | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h
          some (enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms)
        else none }
  vvec.translateLeft

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

/-! ## Equality Case (x = t) -/

set_option maxHeartbeats 800000 in
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
    · -- Compatible: build a depth-1 1-var NF for x = t and use char_1
      -- Build nf_x_eq: the unique depth-1 1-var NF such that
      -- nf_eval_nf M 1 1 [t] nf_x_eq captures the quantifier conditions
      -- at [t, t] (= at [x, t] with x = t).
      -- The quantifier part at depth 1 involves ∀ ssn, (∃ y, nf_eval_nf M 0 3 [y,t,t] ssn) ↔ sub_nf.2 ssn.
      -- Each (∃ y, nf_eval_nf M 0 3 [y,t,t] ssn) is a depth-0 3-var existential with vars 1,2 equal.
      -- We use classical choice to obtain temporal formulas for each.
      -- The formula: disjunction over compatible nf_x of char_1(nf_x) ∧ quant_profile.
      -- Use enriched_bypass_eq as the formula.
      exact ⟨enriched_bypass_eq atomMap h_surj char_1 sub_nf parent_atoms,
        fun M h_UZ h_SZ t h_atoms => by
        -- The enriched_bypass_eq formula is a disjunction over compatible nf_x values.
        -- For each nf_x, the conjunct is char_1(nf_x) ∧ quant_conjuncts.
        -- The equivalence with ∃ x, nf_eval at [x, t] where x = t
        -- follows from NF uniqueness + zone decomposition via eq_case_zone_{below,above,eq}.
        -- Both directions use witness_eq_t_of_no_order, nf_characteristic, and the zone bridges.
        sorry⟩
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

/-! ## Until Case: Forward and Backward Helper Lemmas -/

/-- Backward direction: ∃ x, nf_eval → holdsLeft for the enriched Until VVecEA2.
    Given a witness x > t with nf_eval_nf, construct holdsLeft by:
    1. Finding the right disjunct (nf_x = nf_characteristic of x)
    2. Showing endpointLeft (pre-conditions at t) holds
    3. Providing x as the Until witness with endpointRight + bracket -/
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
    ∃ vea ∈ (List.filterMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          some (enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms)
        else none) Fintype.elems.val.toList),
      VecEA2.holdsLeft M atomMap vea.snd t := by
  intro ⟨x, h_eval⟩
  -- Step 1: Get the characteristic NF of x and show compatibility
  let nf_x := nf_characteristic M 1 1 (fun _ => x)
  have h_nf_x : nf_eval_nf M 1 1 (fun _ => x) nf_x :=
    nf_characteristic_satisfies M 1 1 (fun _ => x)
  have h_compat : nf_x_compat_check sub_nf nf_x = true :=
    nf_x_compat_of_nf_eval M sub_nf t x h_eval nf_x h_nf_x
  -- Step 2: Build the VecEA2 for this nf_x
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  let vea := enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms
  -- Step 3: Show vea is in the disjunct list
  have h_mem_elems : nf_x ∈ Fintype.elems.val := Fintype.complete nf_x
  have h_vea_mem : vea ∈ List.filterMap
      (fun nf_x' => if nf_x_compat_check sub_nf nf_x' = true then
        some (enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x'
          (fun a => match a with
            | .pred p _ => nf_x'.1 (.pred p ⟨0, by omega⟩)
            | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
          parent_atoms)
      else none) Fintype.elems.val.toList := by
    rw [List.mem_filterMap]
    refine ⟨nf_x, Multiset.mem_toList.mpr h_mem_elems, ?_⟩
    simp only [h_compat, ite_true]
    rfl
  -- Step 4: Show holdsLeft for this VecEA2
  refine ⟨vea, h_vea_mem, ?_⟩
  -- holdsLeft = endpointLeft.eval_at t ∧ ∃ z1 > t, endpointRight.eval_at z1 ∧ bracket.holds t z1
  simp only [VecEA2.holdsLeft, enriched_vecEA2_until]
  -- We need t < x (from h_gt and h_eval)
  have h_t_lt_x : t < x := (zone_from_nf_eval M sub_nf t x h_eval).1 h_gt
  -- Decompose h_eval into atoms and quantifier parts
  obtain ⟨h_eval_atoms, h_eval_quant⟩ := h_eval
  -- Step 4a: endpointLeft (pre_conditions_at_t) holds at t
  -- Step 4b: x as witness with endpointRight and bracket
  refine ⟨?endLeft, x, h_t_lt_x, ?endRight, ?bracket⟩
  case endLeft =>
    -- pre_conditions_at_t_until holds at t
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
    -- char_1(nf_x) ∧ right_conjuncts holds at x
    simp only [TemporalPred.eval_at]
    show temporal_truth M atomMap x (Formula.and (char_1 nf_x) (formula_conjList _))
    rw [temporal_truth_and]
    constructor
    · -- char_1(nf_x) holds at x by char_1_correct + h_nf_x
      exact (char_1_correct nf_x M h_UZ h_SZ x).mpr h_nf_x
    · -- right_conjuncts: eq_x and above_x zone conditions
      rw [formula_conjList_iff]
      intro φ h_mem
      rw [List.mem_filterMap] at h_mem
      obtain ⟨ssn, h_ssn_mem, h_some⟩ := h_mem
      split_ifs at h_some with h_compat' h_pos
      · revert h_some
        rcases h_zone : ssn_zone_until ssn with _ | _ | _ | _ | _ | _
        all_goals simp
        all_goals intro h_eq; subst h_eq
        -- eq_x, positive
        · exact (eq_x_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_t_lt_x
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)).mpr
            ((h_eval_quant ssn).mpr h_pos)
        -- above_x, positive
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
        -- eq_x, negative
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
        -- above_x, negative
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
    -- bracket.holds t x = interval pattern holds on (t, x)
    -- Positive between_tx ssns need witnesses, negative need segment guards
    sorry

/-- Forward direction: holdsLeft for the enriched Until VVecEA2 → ∃ x, nf_eval.
    Given holdsLeft (some disjunct is satisfied), extract x and reconstruct nf_eval. -/
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
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true) :
    (∃ vea ∈ (List.filterMap
        (fun nf_x => if nf_x_compat_check sub_nf nf_x = true then
          some (enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x
            (fun a => match a with
              | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
              | .order i j h => absurd (Fin.ext (by omega) : i = j) h)
            parent_atoms)
        else none) Fintype.elems.val.toList),
      VecEA2.holdsLeft M atomMap vea.snd t) →
    ∃ x : M.carrier, nf_eval_nf M 1 (1 + 1) (Fin.cons x (fun _ => t)) sub_nf := by
  intro ⟨⟨n, vea⟩, h_mem, h_holds⟩
  -- Extract nf_x from the filterMap membership
  rw [List.mem_filterMap] at h_mem
  obtain ⟨nf_x, _, h_some⟩ := h_mem
  -- nf_x_compat_check must be true for h_some to produce some
  split_ifs at h_some with h_compat
  · -- Compatible case: h_some : some (...) = some ⟨n, vea⟩
    have h_eq := Option.some_injective _ h_some
    -- h_eq : enriched_vecEA2_until ... = ⟨n, vea⟩
    -- Rewrite h_holds using h_eq
    rw [show (⟨n, vea⟩ : Σ n, VecEA2 n).snd = vea from rfl] at h_holds
    -- Extract the VecEA2 structure
    let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
      | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
      | .order i j h => absurd (Fin.ext (by omega) : i = j) h
    -- The enriched_vecEA2_until gives a specific VecEA2
    let vea' := enriched_vecEA2_until atomMap h_surj char_1 sub_nf nf_x nf_x_1var parent_atoms
    -- h_eq tells us ⟨n, vea⟩ = vea' (definitionally via the lambda)
    -- From holdsLeft for vea, we get endpointLeft at t, and x > t with endpointRight and bracket
    simp only [VecEA2.holdsLeft] at h_holds
    obtain ⟨h_endLeft, x, h_t_lt_x, h_endRight, h_bracket⟩ := h_holds
    -- We have x > t with the VecEA2 conditions
    -- Need to reconstruct nf_eval_nf M 1 2 (x, t) sub_nf
    refine ⟨x, ?_⟩
    sorry

/-! ## Until Case (t < x) -/

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
  -- Strategy: use the enriched_bypass_until VVecEA2 construction.
  -- The formula is vvec.translateLeft. By VVecEA2.translateLeft_correct,
  -- temporal_truth ↔ holdsLeft. We then show holdsLeft ↔ ∃ x > t, nf_eval.
  --
  -- However, proving the semantic equivalence between holdsLeft and the
  -- existential directly is very complex (400+ lines). Instead, we use a
  -- classical existence argument that constructs the formula from components.
  --
  -- For each ssn : NormalForm sig 0 3, the depth-0 3-var existential
  -- ∃ y, nf_eval_nf M 0 3 [y,x,t] ssn has a temporal formula equivalent
  -- to a VecEA2 condition on (t, x) (zone theorems from VecEADecomp.lean).
  -- For the full Until existential:
  --   ∃ x > t, (atom conditions at x,t) ∧ (∀ ssn, quant condition)
  -- we combine char_1(nf_x) at x with these zone-based formulas.
  --
  -- The formula is: disjunction over compatible nf_x of
  --   Until(char_1(nf_x) ∧ positive_quant_profile(nf_x), guard)
  -- where guard handles negative between_tx conditions.
  -- positive_quant_profile handles y=x, y>x, and positive t<y<x via Since.
  -- Pre-conditions at t handle y<t (Since) and y=t (direct).
  --
  -- Use the VVecEA2 translateLeft for the formula construction.
  let vvec := enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms
  -- The formula is vvec (which is already a Formula via .translateLeft in enriched_bypass_until)
  -- enriched_bypass_until returns vvec.translateLeft where vvec is a VVecEA2
  -- Actually, enriched_bypass_until returns a Formula directly (it's the result of vvec.translateLeft)
  exact ⟨vvec, fun M h_UZ h_SZ t h_atoms => by
    -- vvec = enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms
    -- This is defined as translateLeft of a VVecEA2.
    -- By VVecEA2.translateLeft_correct: temporal_truth ↔ holdsLeft.
    -- holdsLeft = ∃ (n, vea) ∈ disjuncts, vea.holdsLeft M atomMap t
    -- vea.holdsLeft = endpointLeft.eval_at t ∧ ∃ x > t, endpointRight.eval_at x ∧ bracket.holds t x
    --
    -- Key correspondence:
    -- Forward (holdsLeft → ∃ x, nf_eval):
    --   From holdsLeft, get x > t with endpointRight (char_1(nf_x) ∧ conditions) and bracket.
    --   Reconstruct nf_eval from the characteristic + zone conditions.
    --
    -- Backward (∃ x, nf_eval → holdsLeft):
    --   Given x > t with nf_eval, determine nf_x = nf_characteristic M 1 1 [x].
    --   Show nf_x is compatible (nf_x_compat_check), find the right disjunct.
    --   Show endpointLeft (pre-conditions at t) and endpointRight (enriched at x).
    --   For bracket: positive between_tx ssns have witnesses between t and x by nf_eval.
    --
    -- This proof is deferred to a subsequent dispatch focused on the Until-case
    -- semantic equivalence between VecEA2.holdsLeft and nf_eval_nf.
    show temporal_truth M atomMap t (enriched_bypass_until atomMap h_surj char_1 sub_nf parent_atoms) ↔ _
    simp only [enriched_bypass_until]
    rw [VVecEA2.translateLeft_correct]
    simp only [VVecEA2.holdsLeft]
    constructor
    · -- Forward: holdsLeft → ∃ x, nf_eval
      exact forward_nf_eval_of_holdsLeft atomMap h_surj char_1 char_1_correct
        parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms
    · -- Backward: ∃ x, nf_eval → holdsLeft
      exact backward_holdsLeft_of_nf_eval atomMap h_surj char_1 char_1_correct
        parent_atoms sub_nf h_gt h_lt M h_UZ h_SZ t h_atoms⟩

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
  sorry

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
