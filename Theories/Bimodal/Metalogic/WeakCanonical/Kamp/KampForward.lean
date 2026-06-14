import Bimodal.Metalogic.WeakCanonical.Kamp.VecEADecomp
import Bimodal.Metalogic.WeakCanonical.Kamp.ZoneBridge
import Bimodal.Metalogic.WeakCanonical.Kamp.NfToVecEA
import Bimodal.Metalogic.WeakCanonical.Kamp.NfCharFormula

/-!
# Forward VecEADecomp Pipeline for Kamp Bypass

Constructs temporal formulas for `∃ x, nf_eval_nf M 1 2 (x, t) sub_nf`
by composing sorry-free VecEADecomp zone theorems + VecEA2 translation,
instead of reverse-engineering formulas from NF booleans.

## Key Insight

For each 3-var depth-0 NF `ssn`, the VecEADecomp zone theorems give
sorry-free biconditionals:

  VecEA2.holds M atomMap z0 z1 ↔ ∃ y, nf_eval_nf M 0 3 (y, x, t) ssn

The VecEA2 translation (`translateLeft`/`translateRight`) converts
VecEA2.holds to temporal_truth, also sorry-free.

The composition gives temporal formulas whose correctness is TRIVIAL —
no manual NF reconstruction needed.

## Architecture

For the Until direction (t < x):
- Build a single VecEA2 with endpointLeft at t, endpointRight at x
- Bracket encodes positive between-zone (t < y < x) ssn conditions
- Endpoint conditions encode the remaining zones
- `translateLeft` at t gives the final temporal formula
- Correctness = composition of VecEADecomp zone theorems

## References

- Report 27: architectural insight (forward vs backward)
- VecEADecomp.lean: sorry-free zone theorems
- ZoneBridge.lean: sorry-free NF↔zone bridges
- VecEATranslation.lean: sorry-free VecEA2 → temporal translation
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (atom_literal atom_literal_correct
  formula_conjList formula_conjList_iff formula_disjList formula_disjList_iff
  nf_depth0_char_formula nf_depth0_char_formula_correct)

/-! ## Per-SSN temporal formula via VecEADecomp

For a single ssn : NormalForm sig 0 3, we construct a VecEA2 and
translate it to a temporal formula. The zone determines which
VecEADecomp construction to use. -/

/-- Classify the zone of y from order atoms of a depth-0 3-var NF.
    Variables: 0=y, 1=x, 2=t.
    Returns the pair (z0, z1) for VecEA2.holds and the VecEA2 itself. -/
inductive SSNZone where
  | bracket_tyx    -- t < y < x: bracket between t and x
  | bracket_xyt    -- x < y < t: bracket between x and t
  | zone_ytx       -- y < t < x: Since-witness at t
  | zone_txy       -- t < x < y: Until-witness at x
  | zone_yxt       -- y < x < t: Since-witness at x
  | zone_xty       -- x < t < y: Until-witness at t
  | eq_yt          -- y = t (both y<t and t<y false)
  | eq_yx          -- y = x (both y<x and x<y false)
  | inconsistent   -- contradictory order
  deriving DecidableEq, Repr

/-- Classify a 3-var depth-0 NF's zone from its order booleans. -/
noncomputable def classify_ssn_zone {sig : MonadicSignature}
    (ssn : NormalForm sig 0 3) : SSNZone :=
  let yx := ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide))
  let xy := ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
  let yt := ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
  let ty := ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide))
  let xt := ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide))
  let tx := ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide))
  -- Antisymmetry check
  if yx && xy then .inconsistent
  else if yt && ty then .inconsistent
  else if xt && tx then .inconsistent
  -- Equality cases
  else if !yx && !xy && !yt && !ty then .inconsistent  -- y=x=t needs separate handling
  else if !yt && !ty then .eq_yt
  else if !yx && !xy then .eq_yx
  -- Strict orderings (6 permutations of 3 distinct points)
  else if ty && yx && tx then .bracket_tyx  -- t < y < x
  else if xy && yt && xt then .bracket_xyt  -- x < y < t
  else if yt && tx && yx then .zone_ytx     -- y < t < x
  else if tx && xy && ty then .zone_txy     -- t < x < y
  else if yx && xt && yt then .zone_yxt     -- y < x < t
  else if xt && ty && xy then .zone_xty     -- x < t < y
  else .inconsistent

/-! ## Per-SSN VecEA2 construction

For each zone, we use the corresponding VecEADecomp definition. -/

/-- Build the VecEA2 for a single ssn based on its zone.
    Returns the VecEA2 and an orientation flag:
    - `true` means VecEA2.holds(t, x) (Until orientation)
    - `false` means VecEA2.holds(x, t) (Since orientation) -/
noncomputable def ssn_to_vecEA2 {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3) : SSNZone × (Σ n, VecEA2 n) :=
  let zone := classify_ssn_zone ssn
  match zone with
  | .bracket_tyx => (zone, ⟨1, nf_3var_bracket_tyx atomMap h_surj ssn⟩)
  | .bracket_xyt => (zone, ⟨1, nf_3var_bracket_xyt atomMap h_surj ssn⟩)
  | .zone_ytx => (zone, ⟨0, nf_3var_zone_ytx atomMap h_surj ssn⟩)
  | .zone_txy => (zone, ⟨0, nf_3var_zone_txy atomMap h_surj ssn⟩)
  | .zone_yxt => (zone, ⟨0, nf_3var_zone_yxt atomMap h_surj ssn⟩)
  | .zone_xty => (zone, ⟨0, nf_3var_zone_xty atomMap h_surj ssn⟩)
  | .eq_yt => (zone, ⟨0, VecEA2.mk TemporalPred.top TemporalPred.top
                            (BracketFormula.trivial TemporalPred.top)⟩)
  | .eq_yx => (zone, ⟨0, VecEA2.mk TemporalPred.top TemporalPred.top
                            (BracketFormula.trivial TemporalPred.top)⟩)
  | .inconsistent => (zone, ⟨0, VecEA2.mk TemporalPred.top TemporalPred.top
                                  (BracketFormula.trivial TemporalPred.top)⟩)

/-! ## Per-SSN temporal formula

For each ssn, produce a temporal formula evaluated at a point
that captures `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn`.

For the Until direction (t < x in the outer context):
- bracket_tyx (t < y < x): translate VecEA2.holds(t, x) → formula at t
  via translateLeft, but this quantifies over x. Instead, we use the
  VecEA2 as a BRACKET in the outer formula.
- zone_ytx (y < t < x): VecEA2.holds(t, x) with Since-witness at t
- zone_txy (t < x < y): VecEA2.holds(t, x) with Until-witness at x
- eq_yt: direct NF eval at (t, x, t)
- eq_yx: direct NF eval at (x, x, t)
- above_x: Until-witness beyond x

The key: we DON'T use translateLeft/Right on individual ssn VecEA2s.
Instead, we embed all ssn conditions into a SINGLE VecEA2 for the
outer ∃ x formula. The bracket zone ssns become bracket witnesses;
the endpoint zone ssns become endpoint conditions. -/

/-! ## Forward Enriched VecEA2

Build a VecEA2 for `∃ x > t, [all ssn conditions hold at (y, x, t)]`.
This is the forward version of enriched_vecEA2_until from KampBypass.

The key structural difference: the CORRECTNESS proof composes
VecEADecomp zone theorems instead of reconstructing NF from scratch. -/

/-- Build the forward enriched VecEA2 for Until direction (t < x).

    Structure:
    - endpointLeft(t): pred_t(t) ∧ conditions for y < t zone ∧ y = t zone
    - endpointRight(x): char_1(nf_x) ∧ pred_x(x) ∧ conditions for y = x, y > x zones
    - bracket(t, x): conditions for t < y < x zone

    For each ssn:
    - positive (sub_nf.2 ssn = true): the zone condition must HOLD
    - negative (sub_nf.2 ssn = false): the zone condition must NOT hold -/
noncomputable def forward_vecEA2_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (nf_x : NormalForm sig 1 1)
    (parent_atoms : AtomKind sig 1 → Bool) : Σ n, VecEA2 n :=
  -- Extract the depth-0 1-var NF for x's predicates
  let nf_x_1var : NormalForm sig 0 1 := fun a => match a with
    | .pred p _ => nf_x.1 (.pred p ⟨0, by omega⟩)
    | .order i j h => absurd (Fin.ext (by omega) : i = j) h
  -- Collect positive between_tx ssns (need bracket witnesses)
  let pos_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (classify_ssn_zone ssn == .bracket_tyx) &&
    sub_nf.2 ssn
  -- Collect negative between_tx ssns (need segment guards)
  let neg_between := (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filter fun ssn =>
    ssn_xt_compatible ssn nf_x_1var parent_atoms true false &&
    (classify_ssn_zone ssn == .bracket_tyx) &&
    !sub_nf.2 ssn
  -- Build the segment guard for the bracket
  let seg_guard : TemporalPred :=
    ⟨formula_conjList (neg_between.map fun ssn =>
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)).neg)⟩
  -- Build the bracket formula
  let n := pos_between.length
  let bracket : BracketFormula n :=
    { pointTypes := fun i =>
        nfPred atomMap h_surj (nf_y_proj (pos_between[i.val]'(by omega)))
      segmentTypes := fun _ => seg_guard }
  -- Build endpointLeft (at t): pred_t ∧ conditions for y < t and y = t zones
  let t_conjuncts :=
    (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
        let zone := classify_ssn_zone ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .zone_ytx =>
          -- y < t: ∃ y < t with pred_y → Since(pred_y, ⊤) at t
          if sub_nf.2 ssn then some (Formula.snce char_y Formula.top)
          else some (Formula.snce char_y Formula.top).neg
        | .eq_yt =>
          -- y = t: pred_y holds at t iff char_y at t
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | _ => none
      else none
  let endLeft : TemporalPred :=
    ⟨formula_conjList t_conjuncts⟩
  -- Build endpointRight (at x): char_1(nf_x) ∧ conditions for y = x, y > x
  let x_conjuncts :=
    (Fintype.elems (α := NormalForm sig 0 3)).val.toList.filterMap fun ssn =>
      if ssn_xt_compatible ssn nf_x_1var parent_atoms true false then
        let zone := classify_ssn_zone ssn
        let char_y := nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)
        match zone with
        | .eq_yx =>
          -- y = x: pred_y holds at x iff char_y at x
          if sub_nf.2 ssn then some char_y
          else some char_y.neg
        | .zone_txy =>
          -- t < x < y: ∃ y > x with pred_y → Until(pred_y, ⊤) at x
          if sub_nf.2 ssn then some (Formula.untl char_y Formula.top)
          else some (Formula.untl char_y Formula.top).neg
        | _ => none
      else none
  let endRight : TemporalPred :=
    ⟨Formula.and (char_1 nf_x) (formula_conjList x_conjuncts)⟩
  ⟨n, { endpointLeft := endLeft, endpointRight := endRight, bracket := bracket }⟩

/-! ## Forward bypass formula

Disjunction over compatible nf_x values, each giving a VecEA2
that is translated via translateLeft. -/

/-- The forward bypass formula for depth 1, Until direction (t < x).
    This is the forward version of enriched_bypass_until. -/
noncomputable def forward_bypass_until {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (char_1 : NormalForm sig 1 1 → Formula)
    (sub_nf : NormalForm sig 1 2)
    (parent_atoms : AtomKind sig 1 → Bool) : Formula :=
  let vvec : VVecEA2 :=
    { disjuncts := (Fintype.elems (α := NormalForm sig 1 1)).val.toList.filterMap fun nf_x =>
        if nf_x_compat_check sub_nf nf_x then
          some (forward_vecEA2_until atomMap h_surj char_1 sub_nf nf_x parent_atoms)
        else none }
  vvec.translateLeft

/-! ## Helper: extract y-predicate NF from 3-var NF evaluation

This is a local version of VecEADecomp's private `extract_y_nf`. -/

private theorem extract_y_nf_local {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
  intro a
  match a with
  | .pred p _ =>
    have := h_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, Fin.cons, nf_y_proj] at this ⊢
    exact this
  | .order i j h_neq => exact absurd (Fin.ext (by omega) : i = j) h_neq

/-! ## Helper: extract order relation from 3-var NF evaluation -/

private theorem extract_order_3var {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (ssn : NormalForm sig 0 3) (y x t : M.carrier)
    (h_nf : nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn)
    (i j : Fin 3) (h_ne : i ≠ j)
    (h_val : ssn (.order i j h_ne) = true) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) i <
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → M.carrier) j := by
  have h_ord := h_nf (.order i j h_ne)
  simp only [atom_eval] at h_ord
  exact h_ord.mpr h_val

/-! ## Correctness: Forward direction

The forward direction is: if nf_eval_nf holds, then the temporal formula holds.
This composes: NF eval → zone conditions → VecEADecomp → VecEA2.holds → translateLeft. -/

/-- Forward direction for a single ssn in the bracket_tyx zone:
    If `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn` holds,
    then the bracket witness condition is satisfied. -/
theorem ssn_bracket_tyx_forward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_tx : ssn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = true)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_xt : ssn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (t x : M.carrier)
    (h_exist : ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    ∃ y : M.carrier, t < y ∧ y < x ∧
      nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn) := by
  obtain ⟨y, h_nf⟩ := h_exist
  have h_y_nf := extract_y_nf_local M ssn y x t h_nf
  have h_ty_lt := extract_order_3var M ssn y x t h_nf ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide) h_ty
  have h_yx_lt := extract_order_3var M ssn y x t h_nf ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide) h_yx
  simp [Fin.cons] at h_ty_lt h_yx_lt
  exact ⟨y, h_ty_lt, h_yx_lt, h_y_nf⟩

/-- Forward direction for the zone_ytx case:
    If `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn` holds with y < t,
    then Since(pred_y, top) holds at t. -/
theorem ssn_zone_ytx_forward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h_exist : ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    temporal_truth M atomMap t
      (Formula.snce (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) := by
  obtain ⟨y, h_nf⟩ := h_exist
  have h_y_nf := extract_y_nf_local M ssn y x t h_nf
  have h_yt_lt := extract_order_3var M ssn y x t h_nf ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide) h_yt
  simp [Fin.cons] at h_yt_lt
  simp only [temporal_truth]
  refine ⟨y, h_yt_lt, ?_, ?_⟩
  · rw [nf_depth0_char_formula_correct]
    intro p
    have := h_y_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, nf_y_proj] at this
    exact this
  · intro z _ _
    simp [temporal_truth, Formula.top]

/-- Forward direction for the eq_yt case:
    If nf_eval_nf with y=t holds, then char_y holds at t. -/
theorem ssn_eq_yt_forward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_yt : ssn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false)
    (h_ty : ssn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h_exist : ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) := by
  -- y = t by nf_3var_eq_yt
  have h_iff := nf_3var_eq_yt ssn h_yt h_ty M x t
  have h_nf_at_t := h_iff.mp h_exist
  -- Extract predicates at y=t
  have h_y_nf := extract_y_nf_local M ssn t x t h_nf_at_t
  rw [nf_depth0_char_formula_correct]
  intro p
  have := h_y_nf (.pred p ⟨0, by omega⟩)
  simp only [atom_eval, nf_y_proj] at this
  exact this

/-- Forward direction for the eq_yx case:
    If nf_eval_nf with y=x holds, then char_y holds at x. -/
theorem ssn_eq_yx_forward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_yx : ssn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h_exist : ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) := by
  -- y = x by nf_3var_eq_yx
  have h_iff := nf_3var_eq_yx ssn h_yx h_xy M x t
  have h_nf_at_x := h_iff.mp h_exist
  -- Extract predicates at y=x
  have h_y_nf := extract_y_nf_local M ssn x x t h_nf_at_x
  rw [nf_depth0_char_formula_correct]
  intro p
  have := h_y_nf (.pred p ⟨0, by omega⟩)
  simp only [atom_eval, nf_y_proj] at this
  exact this

/-- Forward direction for the zone_txy case:
    If `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn` holds with x < y,
    then Until(pred_y, top) holds at x. -/
theorem ssn_zone_txy_forward {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ssn : NormalForm sig 0 3)
    (h_xy : ssn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (h_exist : ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons x (fun _ => t))) ssn) :
    temporal_truth M atomMap x
      (Formula.untl (nf_depth0_char_formula atomMap h_surj (nf_y_proj ssn)) Formula.top) := by
  obtain ⟨y, h_nf⟩ := h_exist
  have h_y_nf := extract_y_nf_local M ssn y x t h_nf
  have h_xy_lt := extract_order_3var M ssn y x t h_nf ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide) h_xy
  simp [Fin.cons] at h_xy_lt
  simp only [temporal_truth]
  refine ⟨y, h_xy_lt, ?_, ?_⟩
  · rw [nf_depth0_char_formula_correct]
    intro p
    have := h_y_nf (.pred p ⟨0, by omega⟩)
    simp only [atom_eval, nf_y_proj] at this
    exact this
  · intro z _ _
    simp [temporal_truth, Formula.top]

end Bimodal.Metalogic.WeakCanonical.Kamp
