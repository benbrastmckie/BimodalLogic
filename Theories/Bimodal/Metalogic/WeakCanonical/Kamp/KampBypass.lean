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
  -- Collect negative between_tx ssns (need segment guards)
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (ssn_zone_until ssn == .between_tx) &&
    !sub_nf.2 ssn
  -- Build the segment guard: conjunction of neg char_y for negative between_tx ssns
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  -- Bracket: n=0 with seg_guard on (t, x). No bracket witnesses needed.
  -- Positive between_tx conditions are moved to endpointRight as Since formulas.
  let bracket : BracketFormula 0 := BracketFormula.trivial seg_guard
  -- Build the endpoint left (at t): pre-conditions for y < t and y = t
  let endLeft : TemporalPred :=
    ⟨pre_conditions_at_t_until atomMap h_surj sub_nf nf_x_1var parent_atoms⟩
  -- Build the endpoint right (at x): char_1(nf_x) + conditions for y = x, y > x
  -- Also includes positive between_tx conditions as Since formulas (∃ y < x, char_y at y)
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
        | .between_tx =>
          -- Positive between_tx: Since formula at x gives ∃ y < x with char_y at y
          -- Negative between_tx: already handled by seg_guard in bracket
          if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
          else none
        | _ => none
      else none
  let endRight : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList right_conjuncts)⟩
  ⟨0, { endpointLeft := endLeft, endpointRight := endRight, bracket := bracket }⟩

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
        -- between_tx, positive: Since(char_y, top) at x
        · -- Need: ∃ y' < x, char_y at y' ∧ ∀ r ∈ (y', x), top at r
          have h_exists := (h_eval_quant ssn).mpr h_pos
          rw [between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t h_t_lt_x
            h_compat' h_zone
            (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                         have := h_atom (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)
            (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                         simp only [atom_eval] at this; exact this)] at h_exists
          obtain ⟨y', h_t_lt_y', h_y'_lt_x, h_y'_preds⟩ := h_exists
          simp only [Formula.snce, temporal_truth, Formula.top]
          exact ⟨y', h_y'_lt_x,
            (nf_depth0_char_formula_correct M atomMap h_surj (nf_y_proj ssn) y').mpr
              (fun p => by have := h_y'_preds p; simp only [nf_y_proj]; exact this),
            fun _ _ _ => id⟩
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
    -- With n=0 bracket (BracketFormula.trivial seg_guard), need:
    -- ∀ y ∈ (t, x), seg_guard holds at y
    -- i.e., for each negative between_tx SSN, its char_y is false at y
    show (BracketFormula.trivial _).holds M atomMap t x
    rw [BracketFormula.trivial_holds]
    intro y h_t_lt_y h_y_lt_x
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
    -- ssn is a negative between_tx SSN: sub_nf.2 ssn = false
    simp only [Formula.neg, temporal_truth]
    intro h_char_y
    -- Use between_tx_temporal_iff to bridge from temporal to 3-var existential
    have h_bridge := (between_tx_temporal_iff M atomMap h_surj ssn nf_x_1var parent_atoms x t
      h_t_lt_x h_compat' h_zone
      (fun p => by obtain ⟨h_atom, _⟩ := h_nf_x
                   have := h_atom (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)
      (fun p => by have := h_atoms (.pred p ⟨0, by omega⟩)
                   simp only [atom_eval] at this; exact this)).mpr
    -- h_eval_quant says: (∃ y, nf_eval_nf ...) ↔ sub_nf.2 ssn = true
    -- sub_nf.2 ssn = false, so the existential is false
    have h_no_witness : ¬ ∃ z, nf_eval_nf M 0 (1 + 1 + 1)
        (Fin.cons z (Fin.cons x fun _ => t)) ssn := by
      rw [h_eval_quant ssn]; simp [h_neg]
    -- But we can construct the witness from the char formula holding at y
    apply h_no_witness
    apply h_bridge
    -- Need: ∃ y', t < y' ∧ y' < x ∧ ∀ p, M.interp p y' ↔ ssn (.pred p ⟨0, ...⟩) = true
    refine ⟨y, h_t_lt_y, h_y_lt_x, ?_⟩
    -- Extract y predicate compatibility from nf_depth0_char_formula
    rw [nf_depth0_char_formula_correct] at h_char_y
    intro p
    have := h_char_y p
    simp only [nf_y_proj] at this
    exact this

set_option maxHeartbeats 1600000 in
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
    (h_atoms : ∀ (a : AtomKind sig 1), atom_eval M (fun _ => t) a ↔ parent_atoms a = true)
    (h_t_compat : ∀ p : sig.preds, sub_nf.1 (.pred p ⟨1, by omega⟩) = parent_atoms (.pred p ⟨0, by omega⟩))
    (h_ssn_compat : ∀ ssn : NormalForm sig 0 3, sub_nf.2 ssn = true →
        ssn_xt_compatible ssn (fun a => match a with
          | .pred p _ => sub_nf.1 (.pred p ⟨0, by omega⟩)
          | .order i j h => absurd (Fin.ext (by omega) : i = j) h) parent_atoms true false = true) :
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
    -- Step 1: Transfer vea to the enriched construction
    -- h_eq : enriched_vecEA2_until ... = ⟨n, vea⟩
    -- So vea'.2 = vea after appropriate transport through h_eq
    -- Simplify: since vea' is a let-binding, h_eq : vea' = ⟨n, vea⟩
    -- means enriched_vecEA2_until ... = ⟨n, vea⟩.
    -- Rather than transporting through HEq, use sorry for the forward direction
    -- (the bracket case at L2273 is BLOCKED anyway, so this whole block contains sorry)
    sorry
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
    · -- Both checks pass: use enriched_bypass_since
      exact ⟨enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms,
        fun M h_UZ h_SZ t h_atoms => by
        constructor
        · -- Forward: formula → ∃ x, nf_eval
          -- BLOCKED: same encoding flaw as Until forward direction.
          -- The between_xt zone uses Formula.untl char_y Formula.top at x,
          -- which gives y > x but not y < t.
          sorry
        · -- Backward: ∃ x, nf_eval → formula
          sorry⟩
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
