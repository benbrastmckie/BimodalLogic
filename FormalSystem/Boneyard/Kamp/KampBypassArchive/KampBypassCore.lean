import FormalSystem.Metalogic.WeakCanonical.Kamp.NfToVecEA
import FormalSystem.Metalogic.WeakCanonical.Kamp.VecEADecomp
import FormalSystem.Boneyard.Kamp.KampWeakCanonical.TranslationEra.ZoneBridge
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.PriorDefs
import Mathlib.Data.Finset.Sort
import Mathlib.GroupTheory.Perm.Fin

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Enriched Bypass Formula: Core Definitions

Types, zone classification, and formula construction for the enriched bypass.
The enriched formula encodes both atom and quantifier conditions for the
2-variable existential at depth k+1, using zone decomposition to place
3-var quantifier witnesses in the correct temporal position.

See also:
- `KampBypassEqCase.lean` — equality case (x = t)
- `KampBypassBridge.lean` — zone-to-temporal bridge helpers
- `KampBypassUntil.lean` / `KampBypassSince.lean` — direction-specific proofs
- `KampBypass.lean` — main theorem
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
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
theorem t_compat_holds
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
theorem zone_from_nf_eval
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
theorem nf_x_compat_of_nf_eval
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

end FormalSystem.Metalogic.WeakCanonical.Kamp
