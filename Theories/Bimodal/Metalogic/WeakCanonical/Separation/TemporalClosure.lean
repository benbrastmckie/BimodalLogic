import Bimodal.Metalogic.WeakCanonical.Separation.Defs
import Bimodal.Metalogic.WeakCanonical.Separation.Eliminations
import Bimodal.Metalogic.WeakCanonical.Separation.Duality

/-!
# Temporal Closure Infrastructure

Infrastructure for proving the temporal closure properties (that temporal
operators preserve separability) without axioms.

## Key Results

- `replace_box_with_top`: Normalize formula by replacing degenerate `box` with `top`
- `replace_box_equiv`: Box-normalization preserves `int_equiv`
- `replace_box_preserves_separated`: Box-normalization preserves syntactic separation
- `replace_box_separated_no_S_nested`: Box-free separated formulas satisfy `no_S_nested_in_U`
- `no_U_nested_in_S`: Dual of `no_S_nested_in_U`
- `swap_no_U_nested_gives_no_S_nested`: Duality converts between the two predicates
- `separated_no_S_nested_snce`: Key lemma for `snce_separable`
- `separated_no_U_nested_untl`: Key lemma for `untl_separable`

## Strategy

The temporal closure axioms state that temporal operators preserve separability:
- `snce_separable`: `is_separable φ → is_separable ψ → is_separable (snce φ ψ)`
- `untl_separable`: `is_separable φ → is_separable ψ → is_separable (untl φ ψ)`
- `all_past_separable`: `is_separable φ → is_separable (all_past φ)`
- `all_future_separable`: `is_separable φ → is_separable (all_future φ)`

All four reduce to proving: given separated phi', psi' (from witnesses of `is_separable`),
the recomposed temporal formula is separable. After box-normalization, these formulas
satisfy `no_S_nested_in_U` (for snce/all_past) or `no_U_nested_in_S` (for untl/all_future).
The two directions are connected by `swap_temporal` duality.

The remaining challenge (Phase 6 blocker) is proving `no_S_nested_in_U → is_separable`
without axioms, which requires the full GHR94 junction-depth induction machinery.

## References

- GHR94, Lemmas 10.2.4-10.2.8
- Research reports 09, 10 (junction-depth approach)
-/

namespace Bimodal.Metalogic.WeakCanonical.Separation

open Bimodal.Syntax

/-! ## Box Normalization

Since `box` is semantically degenerate (always true) in our integer temporal
semantics, we can normalize separated formulas by replacing all `box` nodes
with `top` (= `imp bot bot`). This eliminates the `box` loophole where
syntactically separated formulas can contain arbitrary content inside `box`. -/

/-- Replace all `box` nodes in a formula with `top` (imp bot bot).
    Semantically equivalent since `int_truth M t (.box _) = True`. -/
def replace_box_with_top : Formula -> Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp phi psi => .imp (replace_box_with_top phi) (replace_box_with_top psi)
  | .box _ => .imp .bot .bot  -- top
  | .all_past phi => .all_past (replace_box_with_top phi)
  | .all_future phi => .all_future (replace_box_with_top phi)
  | .untl phi psi => .untl (replace_box_with_top phi) (replace_box_with_top psi)
  | .snce phi psi => .snce (replace_box_with_top phi) (replace_box_with_top psi)

/-- Box-normalization preserves semantic equivalence over integer time. -/
theorem replace_box_equiv (phi : Formula) : int_equiv phi (replace_box_with_top phi) := by
  intro M t
  induction phi generalizing t with
  | atom _ => simp [replace_box_with_top, int_truth]
  | bot => simp [replace_box_with_top, int_truth]
  | imp a b ih1 ih2 =>
    simp [replace_box_with_top, int_truth]
    exact ⟨fun h hp => (ih2 t).mp (h ((ih1 t).mpr hp)),
           fun h hp => (ih2 t).mpr (h ((ih1 t).mp hp))⟩
  | box _ => simp [replace_box_with_top, int_truth]
  | all_past a ih =>
    simp [replace_box_with_top, int_truth]
    exact ⟨fun h s hs => (ih s).mp (h s hs), fun h s hs => (ih s).mpr (h s hs)⟩
  | all_future a ih =>
    simp [replace_box_with_top, int_truth]
    exact ⟨fun h s hs => (ih s).mp (h s hs), fun h s hs => (ih s).mpr (h s hs)⟩
  | untl a b ih1 ih2 =>
    simp [replace_box_with_top, int_truth]
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih1 s).mp h1, fun r hr1 hr2 => (ih2 r).mp (h2 r hr1 hr2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih1 s).mpr h1, fun r hr1 hr2 => (ih2 r).mpr (h2 r hr1 hr2)⟩
  | snce a b ih1 ih2 =>
    simp [replace_box_with_top, int_truth]
    constructor
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih1 s).mp h1, fun r hr1 hr2 => (ih2 r).mp (h2 r hr1 hr2)⟩
    · rintro ⟨s, hs, h1, h2⟩
      exact ⟨s, hs, (ih1 s).mpr h1, fun r hr1 hr2 => (ih2 r).mpr (h2 r hr1 hr2)⟩

/-- Box-normalization preserves is_U_free. -/
theorem replace_box_preserves_U_free (phi : Formula) (h : is_U_free phi = true) :
    is_U_free (replace_box_with_top phi) = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [is_U_free] at h; simp [replace_box_with_top, is_U_free, ih1 h.1, ih2 h.2]
  | box _ => simp [replace_box_with_top, is_U_free]
  | all_past a ih => simp [is_U_free] at h; simp [replace_box_with_top, is_U_free, ih h]
  | all_future a ih => simp [is_U_free] at h; simp [replace_box_with_top, is_U_free, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce a b ih1 ih2 => simp [is_U_free] at h; simp [replace_box_with_top, is_U_free, ih1 h.1, ih2 h.2]

/-- Box-normalization preserves is_S_free. -/
theorem replace_box_preserves_S_free (phi : Formula) (h : is_S_free phi = true) :
    is_S_free (replace_box_with_top phi) = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 => simp [is_S_free] at h; simp [replace_box_with_top, is_S_free, ih1 h.1, ih2 h.2]
  | box _ => simp [replace_box_with_top, is_S_free]
  | all_past a ih => simp [is_S_free] at h; simp [replace_box_with_top, is_S_free, ih h]
  | all_future a ih => simp [is_S_free] at h; simp [replace_box_with_top, is_S_free, ih h]
  | untl a b ih1 ih2 => simp [is_S_free] at h; simp [replace_box_with_top, is_S_free, ih1 h.1, ih2 h.2]
  | snce _ _ => simp [is_S_free] at h

/-- Box-normalization preserves syntactic separation. -/
theorem replace_box_preserves_separated (phi : Formula)
    (h : is_syntactically_separated phi = true) :
    is_syntactically_separated (replace_box_with_top phi) = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, is_syntactically_separated, ih1 h.1, ih2 h.2]
  | box _ => simp [replace_box_with_top, is_syntactically_separated]
  | all_past a _ih =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, is_syntactically_separated, replace_box_preserves_U_free a h]
  | all_future a _ih =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, is_syntactically_separated, replace_box_preserves_S_free a h]
  | untl a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, is_syntactically_separated,
          replace_box_preserves_S_free a h.1, replace_box_preserves_S_free b h.2]
  | snce a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, is_syntactically_separated,
          replace_box_preserves_U_free a h.1, replace_box_preserves_U_free b h.2]

/-! ## no_S_nested_in_U for Box-Free Separated Formulas -/

/-- U-free formulas satisfy no_S_nested_in_U (vacuously: no untl nodes). -/
private theorem u_free_no_S_nested (phi : Formula) (h : is_U_free phi = true) :
    no_S_nested_in_U phi := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp a b ih1 ih2 => simp [is_U_free] at h; exact ⟨ih1 h.1, ih2 h.2⟩
  | box a ih => simp [is_U_free] at h; exact ih h
  | all_past a ih => simp [is_U_free] at h; exact ih h
  | all_future a ih => simp [is_U_free] at h; exact ih h
  | untl _ _ => simp [is_U_free] at h
  | snce a b ih1 ih2 => simp [is_U_free] at h; exact ⟨ih1 h.1, ih2 h.2⟩

/-- S-free formulas satisfy no_S_nested_in_U (untl args inherit S-freeness). -/
private theorem s_free_no_S_nested (phi : Formula) (h : is_S_free phi = true) :
    no_S_nested_in_U phi := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp a b ih1 ih2 => simp [is_S_free] at h; exact ⟨ih1 h.1, ih2 h.2⟩
  | box a ih => simp [is_S_free] at h; exact ih h
  | all_past a ih => simp [is_S_free] at h; exact ih h
  | all_future a ih => simp [is_S_free] at h; exact ih h
  | untl a b _ih1 _ih2 => simp [is_S_free] at h; exact h
  | snce _ _ => simp [is_S_free] at h

/-- A box-normalized separated formula satisfies no_S_nested_in_U.
    This is the key structural property enabling the temporal closure proof. -/
theorem replace_box_separated_no_S_nested (phi : Formula)
    (h : is_syntactically_separated phi = true) :
    no_S_nested_in_U (replace_box_with_top phi) := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_S_nested_in_U]
    exact ⟨ih1 h.1, ih2 h.2⟩
  | box _ =>
    simp [replace_box_with_top, no_S_nested_in_U]
  | all_past a _ih =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_S_nested_in_U]
    exact u_free_no_S_nested (replace_box_with_top a) (replace_box_preserves_U_free a h)
  | all_future a _ih =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_S_nested_in_U]
    exact s_free_no_S_nested (replace_box_with_top a) (replace_box_preserves_S_free a h)
  | untl a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_S_nested_in_U]
    exact ⟨replace_box_preserves_S_free a h.1, replace_box_preserves_S_free b h.2⟩
  | snce a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_S_nested_in_U]
    exact ⟨u_free_no_S_nested (replace_box_with_top a) (replace_box_preserves_U_free a h.1),
           u_free_no_S_nested (replace_box_with_top b) (replace_box_preserves_U_free b h.2)⟩

/-! ## Dual Predicate: no_U_nested_in_S -/

/-- The formula has no U (untl) nested within any S (snce) argument.
    This is the dual of `no_S_nested_in_U`. -/
def no_U_nested_in_S : Formula -> Prop
  | .atom _ => True
  | .bot => True
  | .imp phi psi => no_U_nested_in_S phi ∧ no_U_nested_in_S psi
  | .box phi => no_U_nested_in_S phi
  | .all_past phi => no_U_nested_in_S phi
  | .all_future phi => no_U_nested_in_S phi
  | .untl phi psi => no_U_nested_in_S phi ∧ no_U_nested_in_S psi
  | .snce phi psi => is_U_free phi = true ∧ is_U_free psi = true

/-- swap_temporal converts no_U_nested_in_S to no_S_nested_in_U. -/
theorem swap_no_U_nested_gives_no_S_nested (phi : Formula)
    (h : no_U_nested_in_S phi) : no_S_nested_in_U phi.swap_temporal := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp a b ih1 ih2 => exact ⟨ih1 h.1, ih2 h.2⟩
  | box a ih => exact ih h
  | all_past a ih => exact ih h
  | all_future a ih => exact ih h
  | untl a b ih1 ih2 =>
    -- swap(.untl a b) = .snce (swap a) (swap b)
    -- no_S_nested_in_U (.snce ..) = no_S_nested_in_U (swap a) ∧ no_S_nested_in_U (swap b)
    exact ⟨ih1 h.1, ih2 h.2⟩
  | snce a b _ih1 _ih2 =>
    -- swap(.snce a b) = .untl (swap a) (swap b)
    -- no_S_nested_in_U (.untl ..) = is_S_free (swap a) ∧ is_S_free (swap b)
    obtain ⟨ha, hb⟩ := h
    constructor
    · rw [dual_S_free_iff_U_free]; exact ha
    · rw [dual_S_free_iff_U_free]; exact hb

/-- swap_temporal converts no_S_nested_in_U to no_U_nested_in_S. -/
theorem swap_no_S_nested_gives_no_U_nested (phi : Formula)
    (h : no_S_nested_in_U phi) : no_U_nested_in_S phi.swap_temporal := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp a b ih1 ih2 => exact ⟨ih1 h.1, ih2 h.2⟩
  | box a ih => exact ih h
  | all_past a ih => exact ih h
  | all_future a ih => exact ih h
  | untl a b _ih1 _ih2 =>
    -- swap(.untl a b) = .snce (swap a) (swap b)
    -- no_U_nested_in_S (.snce ..) = is_U_free (swap a) ∧ is_U_free (swap b)
    obtain ⟨ha, hb⟩ := h
    constructor
    · rw [dual_U_free_iff_S_free]; exact ha
    · rw [dual_U_free_iff_S_free]; exact hb
  | snce a b ih1 ih2 =>
    -- swap(.snce a b) = .untl (swap a) (swap b)
    -- no_U_nested_in_S (.untl ..) = no_U_nested_in_S (swap a) ∧ no_U_nested_in_S (swap b)
    exact ⟨ih1 h.1, ih2 h.2⟩

/-- A box-normalized separated formula also satisfies no_U_nested_in_S. -/
theorem replace_box_separated_no_U_nested (phi : Formula)
    (h : is_syntactically_separated phi = true) :
    no_U_nested_in_S (replace_box_with_top phi) := by
  induction phi with
  | atom _ => trivial
  | bot => trivial
  | imp a b ih1 ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_U_nested_in_S]
    exact ⟨ih1 h.1, ih2 h.2⟩
  | box _ =>
    simp [replace_box_with_top, no_U_nested_in_S]
  | all_past a _ih =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_U_nested_in_S]
    exact u_free_no_U_nested (replace_box_with_top a) (replace_box_preserves_U_free a h)
  | all_future a _ih =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_U_nested_in_S]
    exact s_free_no_U_nested (replace_box_with_top a) (replace_box_preserves_S_free a h)
  | untl a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_U_nested_in_S]
    exact ⟨s_free_no_U_nested (replace_box_with_top a) (replace_box_preserves_S_free a h.1),
           s_free_no_U_nested (replace_box_with_top b) (replace_box_preserves_S_free b h.2)⟩
  | snce a b _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [replace_box_with_top, no_U_nested_in_S]
    exact ⟨replace_box_preserves_U_free a h.1, replace_box_preserves_U_free b h.2⟩
where
  u_free_no_U_nested (phi : Formula) (h : is_U_free phi = true) : no_U_nested_in_S phi := by
    induction phi with
    | atom _ => trivial
    | bot => trivial
    | imp a b ih1 ih2 => simp [is_U_free] at h; exact ⟨ih1 h.1, ih2 h.2⟩
    | box a ih => simp [is_U_free] at h; exact ih h
    | all_past a ih => simp [is_U_free] at h; exact ih h
    | all_future a ih => simp [is_U_free] at h; exact ih h
    | untl _ _ => simp [is_U_free] at h
    | snce a b _ih1 _ih2 => simp [is_U_free] at h; exact h
  s_free_no_U_nested (phi : Formula) (h : is_S_free phi = true) : no_U_nested_in_S phi := by
    induction phi with
    | atom _ => trivial
    | bot => trivial
    | imp a b ih1 ih2 => simp [is_S_free] at h; exact ⟨ih1 h.1, ih2 h.2⟩
    | box a ih => simp [is_S_free] at h; exact ih h
    | all_past a ih => simp [is_S_free] at h; exact ih h
    | all_future a ih => simp [is_S_free] at h; exact ih h
    | untl a b ih1 ih2 => simp [is_S_free] at h; exact ⟨ih1 h.1, ih2 h.2⟩
    | snce _ _ => simp [is_S_free] at h

/-! ## Key Structural Properties for Temporal Closure

These lemmas show that wrapping separated formulas in temporal operators
produces formulas with the no_S_nested_in_U (or dual) property. Combined
with a proof of `no_S_nested_in_U → is_separable` (the Phase 6 goal),
they would immediately yield the temporal closure theorems. -/

/-- snce of box-normalized separated formulas satisfies no_S_nested_in_U.
    This is the key structural reduction for `snce_separable`. -/
theorem snce_of_boxfree_sep_no_S_nested (phi psi : Formula)
    (h1 : is_syntactically_separated phi = true)
    (h2 : is_syntactically_separated psi = true) :
    no_S_nested_in_U (.snce (replace_box_with_top phi) (replace_box_with_top psi)) := by
  simp [no_S_nested_in_U]
  exact ⟨replace_box_separated_no_S_nested phi h1,
         replace_box_separated_no_S_nested psi h2⟩

/-- all_past of box-normalized separated formula satisfies no_S_nested_in_U. -/
theorem all_past_of_boxfree_sep_no_S_nested (phi : Formula)
    (h : is_syntactically_separated phi = true) :
    no_S_nested_in_U (.all_past (replace_box_with_top phi)) := by
  simp [no_S_nested_in_U]
  exact replace_box_separated_no_S_nested phi h

/-- untl of box-normalized separated formulas satisfies no_U_nested_in_S. -/
theorem untl_of_boxfree_sep_no_U_nested (phi psi : Formula)
    (h1 : is_syntactically_separated phi = true)
    (h2 : is_syntactically_separated psi = true) :
    no_U_nested_in_S (.untl (replace_box_with_top phi) (replace_box_with_top psi)) := by
  simp [no_U_nested_in_S]
  exact ⟨replace_box_separated_no_U_nested phi h1,
         replace_box_separated_no_U_nested psi h2⟩

/-- all_future of box-normalized separated formula satisfies no_U_nested_in_S. -/
theorem all_future_of_boxfree_sep_no_U_nested (phi : Formula)
    (h : is_syntactically_separated phi = true) :
    no_U_nested_in_S (.all_future (replace_box_with_top phi)) := by
  simp [no_U_nested_in_S]
  exact replace_box_separated_no_U_nested phi h

/-! ## Congruence Lemmas for Box Normalization -/

/-- snce preserves int_equiv under box normalization of arguments. -/
theorem snce_replace_box_equiv (phi psi : Formula) :
    int_equiv (.snce phi psi)
      (.snce (replace_box_with_top phi) (replace_box_with_top psi)) := by
  intro M t; constructor
  · rintro ⟨s, hst, h1, h2⟩
    exact ⟨s, hst, (replace_box_equiv phi M s).mp h1,
           fun r hr1 hr2 => (replace_box_equiv psi M r).mp (h2 r hr1 hr2)⟩
  · rintro ⟨s, hst, h1, h2⟩
    exact ⟨s, hst, (replace_box_equiv phi M s).mpr h1,
           fun r hr1 hr2 => (replace_box_equiv psi M r).mpr (h2 r hr1 hr2)⟩

/-- all_past preserves int_equiv under box normalization. -/
theorem all_past_replace_box_equiv (phi : Formula) :
    int_equiv (.all_past phi) (.all_past (replace_box_with_top phi)) := by
  intro M t; constructor
  · intro h s hs; exact (replace_box_equiv phi M s).mp (h s hs)
  · intro h s hs; exact (replace_box_equiv phi M s).mpr (h s hs)

/-- untl preserves int_equiv under box normalization of arguments. -/
theorem untl_replace_box_equiv (phi psi : Formula) :
    int_equiv (.untl phi psi)
      (.untl (replace_box_with_top phi) (replace_box_with_top psi)) := by
  intro M t; constructor
  · rintro ⟨s, hts, h1, h2⟩
    exact ⟨s, hts, (replace_box_equiv phi M s).mp h1,
           fun r hr1 hr2 => (replace_box_equiv psi M r).mp (h2 r hr1 hr2)⟩
  · rintro ⟨s, hts, h1, h2⟩
    exact ⟨s, hts, (replace_box_equiv phi M s).mpr h1,
           fun r hr1 hr2 => (replace_box_equiv psi M r).mpr (h2 r hr1 hr2)⟩

/-- all_future preserves int_equiv under box normalization. -/
theorem all_future_replace_box_equiv (phi : Formula) :
    int_equiv (.all_future phi) (.all_future (replace_box_with_top phi)) := by
  intro M t; constructor
  · intro h s hs; exact (replace_box_equiv phi M s).mp (h s hs)
  · intro h s hs; exact (replace_box_equiv phi M s).mpr (h s hs)

/-! ## Junction-Depth Helpers for Axiom Elimination

These lemmas establish the connection between junction_depth components and
syntactic predicates (is_U_free, is_S_free). They support the well-founded
induction approach to proving temporal closure without axioms.

Key facts:
- `junction_depth_S phi = 0` implies `is_U_free phi = true`
- `junction_depth_U phi = 0` implies `is_S_free phi = true`
- In a separated formula, `junction_depth_S` of any subformula is at most 1
  (and equals 1 only at untl nodes with S-free args)
- Therefore `junction_depth (.snce phi' psi')` ≤ 1 for separated phi', psi'
-/

/-- junction_depth_S = 0 implies the formula is U-free (no untl subterms). -/
theorem junction_depth_S_zero_imp_U_free (phi : Formula) (h : junction_depth_S phi = 0) :
    is_U_free phi = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [junction_depth_S] at h; simp [is_U_free, ih1 (by omega), ih2 (by omega)]
  | box a ih => simp [junction_depth_S] at h; simp [is_U_free, ih h]
  | all_past a ih => simp [junction_depth_S] at h; simp [is_U_free, ih h]
  | all_future a ih => simp [junction_depth_S] at h; simp [is_U_free, ih h]
  | untl _ _ => simp [junction_depth_S] at h
  | snce a b ih1 ih2 =>
    simp [junction_depth_S] at h; simp [is_U_free, ih1 (by omega), ih2 (by omega)]

/-- junction_depth_U = 0 implies the formula is S-free (no snce subterms). -/
theorem junction_depth_U_zero_imp_S_free (phi : Formula) (h : junction_depth_U phi = 0) :
    is_S_free phi = true := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [junction_depth_U] at h; simp [is_S_free, ih1 (by omega), ih2 (by omega)]
  | box a ih => simp [junction_depth_U] at h; simp [is_S_free, ih h]
  | all_past a ih => simp [junction_depth_U] at h; simp [is_S_free, ih h]
  | all_future a ih => simp [junction_depth_U] at h; simp [is_S_free, ih h]
  | untl a b ih1 ih2 =>
    simp [junction_depth_U] at h; simp [is_S_free, ih1 (by omega), ih2 (by omega)]
  | snce _ _ => simp [junction_depth_U] at h

/-- S-free formulas have junction_depth = 0. -/
theorem s_free_junction_depth_zero (phi : Formula) (h : is_S_free phi = true) :
    junction_depth phi = 0 := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_S_free] at h; simp [junction_depth, ih1 h.1, ih2 h.2]
  | box a ih => simp [is_S_free] at h; simp [junction_depth, ih h]
  | all_past a ih => simp [is_S_free] at h; simp [junction_depth, ih h]
  | all_future a ih => simp [is_S_free] at h; simp [junction_depth, ih h]
  | untl a b ih1 ih2 =>
    simp [is_S_free] at h
    simp [junction_depth, junction_depth_U]
    -- S-free args of untl means no snce anywhere, so junction_depth_U = 0
    have : junction_depth_U a = 0 := s_free_junction_depth_U_zero a h.1
    have : junction_depth_U b = 0 := s_free_junction_depth_U_zero b h.2
    omega
  | snce _ _ => simp [is_S_free] at h
where
  s_free_junction_depth_U_zero (phi : Formula) (h : is_S_free phi = true) :
      junction_depth_U phi = 0 := by
    induction phi with
    | atom _ => rfl
    | bot => rfl
    | imp a b ih1 ih2 =>
      simp [is_S_free] at h; simp [junction_depth_U, ih1 h.1, ih2 h.2]
    | box a ih => simp [is_S_free] at h; simp [junction_depth_U, ih h]
    | all_past a ih => simp [is_S_free] at h; simp [junction_depth_U, ih h]
    | all_future a ih => simp [is_S_free] at h; simp [junction_depth_U, ih h]
    | untl a b ih1 ih2 =>
      simp [is_S_free] at h; simp [junction_depth_U, ih1 h.1, ih2 h.2]
    | snce _ _ => simp [is_S_free] at h

/-- U-free formulas have junction_depth = 0. -/
theorem u_free_junction_depth_zero (phi : Formula) (h : is_U_free phi = true) :
    junction_depth phi = 0 := by
  induction phi with
  | atom _ => rfl
  | bot => rfl
  | imp a b ih1 ih2 =>
    simp [is_U_free] at h; simp [junction_depth, ih1 h.1, ih2 h.2]
  | box a ih => simp [is_U_free] at h; simp [junction_depth, ih h]
  | all_past a ih => simp [is_U_free] at h; simp [junction_depth, ih h]
  | all_future a ih => simp [is_U_free] at h; simp [junction_depth, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce a b ih1 ih2 =>
    simp [is_U_free] at h
    simp [junction_depth, junction_depth_S]
    have : junction_depth_S a = 0 := u_free_junction_depth_S_zero a h.1
    have : junction_depth_S b = 0 := u_free_junction_depth_S_zero b h.2
    omega
where
  u_free_junction_depth_S_zero (phi : Formula) (h : is_U_free phi = true) :
      junction_depth_S phi = 0 := by
    induction phi with
    | atom _ => rfl
    | bot => rfl
    | imp a b ih1 ih2 =>
      simp [is_U_free] at h; simp [junction_depth_S, ih1 h.1, ih2 h.2]
    | box a ih => simp [is_U_free] at h; simp [junction_depth_S, ih h]
    | all_past a ih => simp [is_U_free] at h; simp [junction_depth_S, ih h]
    | all_future a ih => simp [is_U_free] at h; simp [junction_depth_S, ih h]
    | untl _ _ => simp [is_U_free] at h
    | snce a b ih1 ih2 =>
      simp [is_U_free] at h; simp [junction_depth_S, ih1 h.1, ih2 h.2]

/-- The snce of two box-normalized separated formulas has junction_depth ≤ 1.
    This is the key bound showing that temporal closure only needs to handle
    junction_depth 1 (not arbitrary depth). -/
theorem snce_of_boxfree_sep_jd_le_one (phi psi : Formula)
    (h1 : is_syntactically_separated phi = true)
    (h2 : is_syntactically_separated psi = true) :
    junction_depth (.snce (replace_box_with_top phi) (replace_box_with_top psi)) ≤ 1 := by
  simp [junction_depth]
  constructor
  · exact replace_box_jdS_le_one phi h1
  · exact replace_box_jdS_le_one psi h2
where
  /-- Box-normalized separated formulas have junction_depth_S ≤ 1. -/
  replace_box_jdS_le_one (phi : Formula) (h : is_syntactically_separated phi = true) :
      junction_depth_S (replace_box_with_top phi) ≤ 1 := by
    induction phi with
    | atom _ => simp [replace_box_with_top, junction_depth_S]
    | bot => simp [replace_box_with_top, junction_depth_S]
    | imp a b ih1 ih2 =>
      simp [is_syntactically_separated] at h
      simp [replace_box_with_top, junction_depth_S]
      exact ⟨ih1 h.1, ih2 h.2⟩
    | box _ =>
      simp [replace_box_with_top, junction_depth_S]
    | all_past a _ih =>
      simp [is_syntactically_separated] at h
      simp [replace_box_with_top, junction_depth_S]
      have := u_free_junction_depth_zero.u_free_junction_depth_S_zero
        (replace_box_with_top a) (replace_box_preserves_U_free a h)
      omega
    | all_future a _ih =>
      simp [is_syntactically_separated] at h
      simp [replace_box_with_top, junction_depth_S]
      exact s_free_jdS_le_one (replace_box_with_top a) (replace_box_preserves_S_free a h)
    | untl a b _ih1 _ih2 =>
      simp [is_syntactically_separated] at h
      simp [replace_box_with_top, junction_depth_S]
      have ha := s_free_junction_depth_zero (replace_box_with_top a) (replace_box_preserves_S_free a h.1)
      have hb := s_free_junction_depth_zero (replace_box_with_top b) (replace_box_preserves_S_free b h.2)
      omega
    | snce a b _ih1 _ih2 =>
      simp [is_syntactically_separated] at h
      simp [replace_box_with_top, junction_depth_S]
      have ha := u_free_junction_depth_zero.u_free_junction_depth_S_zero
        (replace_box_with_top a) (replace_box_preserves_U_free a h.1)
      have hb := u_free_junction_depth_zero.u_free_junction_depth_S_zero
        (replace_box_with_top b) (replace_box_preserves_U_free b h.2)
      omega
  /-- S-free formulas have junction_depth_S ≤ 1. -/
  s_free_jdS_le_one (phi : Formula) (h : is_S_free phi = true) :
      junction_depth_S phi ≤ 1 := by
    induction phi with
    | atom _ => simp [junction_depth_S]
    | bot => simp [junction_depth_S]
    | imp a b ih1 ih2 =>
      simp [is_S_free] at h; simp [junction_depth_S]; exact ⟨ih1 h.1, ih2 h.2⟩
    | box a ih => simp [is_S_free] at h; simp [junction_depth_S]; exact ih h
    | all_past a ih => simp [is_S_free] at h; simp [junction_depth_S]; exact ih h
    | all_future a ih => simp [is_S_free] at h; simp [junction_depth_S]; exact ih h
    | untl a b _ih1 _ih2 =>
      simp [is_S_free] at h
      simp [junction_depth_S]
      have ha := s_free_junction_depth_zero a h.1
      have hb := s_free_junction_depth_zero b h.2
      omega
    | snce _ _ => simp [is_S_free] at h

/-! ## Expand Temporal: Eliminating all_past/all_future

On integer time, `all_past φ ≡ ¬(snce (¬φ) ⊤)` and `all_future φ ≡ ¬(untl (¬φ) ⊤)`.
By recursively replacing all_past/all_future with these equivalents, we get a formula
in the restricted fragment `{atom, bot, imp, snce, untl, box}`. In this fragment,
`no_S_nested_in_U` implies `is_syntactically_separated`, which enables proving temporal
closure without axioms. -/

/-- Top formula: uses canonical `Formula.top` from Formula.lean. -/
-- NOTE: Formula.top is now defined in Formula.lean as `Formula.bot.imp Formula.bot`

/-- Replace all `all_past φ` with `¬(snce (¬φ) ⊤)` and all `all_future φ` with
    `¬(untl (¬φ) ⊤)` throughout the formula. This is valid on integer time. -/
def expand_temporal : Formula → Formula
  | .atom a => .atom a
  | .bot => .bot
  | .imp φ ψ => .imp (expand_temporal φ) (expand_temporal ψ)
  | .box φ => .box φ  -- box is degenerate, leave as-is
  | .all_past φ => Formula.neg (.snce (Formula.neg (expand_temporal φ)) Formula.top)
  | .all_future φ => Formula.neg (.untl (Formula.neg (expand_temporal φ)) Formula.top)
  | .untl φ ψ => .untl (expand_temporal φ) (expand_temporal ψ)
  | .snce φ ψ => .snce (expand_temporal φ) (expand_temporal ψ)

/-- top is always true in integer semantics. -/
private theorem top_true (M : IntStructure) (t : ℤ) : int_truth M t Formula.top :=
  fun h => h

/-- Semantic equivalence of all_past with ¬(snce (¬φ) ⊤) on integer time.
    all_past φ at t ↔ ¬∃s<t.(¬φ(s) ∧ ∀r∈(s,t).⊤) ↔ ∀s<t.φ(s) -/
theorem all_past_equiv_neg_snce (φ : Formula) :
    int_equiv (.all_past φ) (Formula.neg (.snce (Formula.neg φ) Formula.top)) := by
  intro M t; constructor
  · -- (→): all_past φ → ¬(snce (¬φ) ⊤)
    intro hall hsnce
    obtain ⟨s, hst, hneg, _⟩ := hsnce
    exact hneg (hall s hst)
  · -- (←): ¬(snce (¬φ) ⊤) → all_past φ
    intro hnotsnce s hst
    by_contra hnotphi
    exact hnotsnce ⟨s, hst, hnotphi, fun _ _ _ => top_true M _⟩

/-- Semantic equivalence of all_future with ¬(untl (¬φ) ⊤) on integer time. -/
theorem all_future_equiv_neg_untl (φ : Formula) :
    int_equiv (.all_future φ) (Formula.neg (.untl (Formula.neg φ) Formula.top)) := by
  intro M t; constructor
  · intro hall huntl
    obtain ⟨s, hts, hneg, _⟩ := huntl
    exact hneg (hall s hts)
  · intro hnotuntl s hts
    by_contra hnotphi
    exact hnotuntl ⟨s, hts, hnotphi, fun _ _ _ => top_true M _⟩

/-- expand_temporal preserves semantic equivalence on integer time. -/
theorem expand_temporal_equiv (φ : Formula) : int_equiv φ (expand_temporal φ) := by
  induction φ with
  | atom _ => exact int_equiv_refl _
  | bot => exact int_equiv_refl _
  | imp a b iha ihb =>
    intro M t; simp only [expand_temporal, int_truth]; constructor
    · intro h hp; exact (ihb M t).mp (h ((iha M t).mpr hp))
    · intro h hp; exact (ihb M t).mpr (h ((iha M t).mp hp))
  | box _ => exact int_equiv_refl _
  | all_past a ih =>
    -- all_past a ≡ all_past (expand_temporal a) ≡ ¬(snce (¬(expand_temporal a)) ⊤)
    intro M t; constructor
    · intro hall hsnce
      obtain ⟨s, hst, hneg, _⟩ := hsnce
      exact hneg ((ih M s).mp (hall s hst))
    · intro hnotsnce s hst
      by_contra hnotphi
      exact hnotsnce ⟨s, hst, fun h => hnotphi ((ih M s).mpr h),
        fun _ _ _ => top_true M _⟩
  | all_future a ih =>
    intro M t; constructor
    · intro hall huntl
      obtain ⟨s, hts, hneg, _⟩ := huntl
      exact hneg ((ih M s).mp (hall s hts))
    · intro hnotuntl s hts
      by_contra hnotphi
      exact hnotuntl ⟨s, hts, fun h => hnotphi ((ih M s).mpr h),
        fun _ _ _ => top_true M _⟩
  | untl a b iha ihb =>
    intro M t; simp only [expand_temporal, int_truth]; constructor
    · rintro ⟨s, hts, ha, hb⟩
      exact ⟨s, hts, (iha M s).mp ha, fun r hr1 hr2 => (ihb M r).mp (hb r hr1 hr2)⟩
    · rintro ⟨s, hts, ha, hb⟩
      exact ⟨s, hts, (iha M s).mpr ha, fun r hr1 hr2 => (ihb M r).mpr (hb r hr1 hr2)⟩
  | snce a b iha ihb =>
    intro M t; simp only [expand_temporal, int_truth]; constructor
    · rintro ⟨s, hst, ha, hb⟩
      exact ⟨s, hst, (iha M s).mp ha, fun r hr1 hr2 => (ihb M r).mp (hb r hr1 hr2)⟩
    · rintro ⟨s, hst, ha, hb⟩
      exact ⟨s, hst, (iha M s).mpr ha, fun r hr1 hr2 => (ihb M r).mpr (hb r hr1 hr2)⟩

/-! ## Expanded formulas have no all_past/all_future -/

/-- Predicate: formula contains no `all_past` or `all_future` constructors. -/
def has_no_allpast_allfuture : Formula → Bool
  | .atom _ => true
  | .bot => true
  | .imp φ ψ => has_no_allpast_allfuture φ && has_no_allpast_allfuture ψ
  | .box _ => true  -- box body not relevant (degenerate)
  | .all_past _ => false
  | .all_future _ => false
  | .untl φ ψ => has_no_allpast_allfuture φ && has_no_allpast_allfuture ψ
  | .snce φ ψ => has_no_allpast_allfuture φ && has_no_allpast_allfuture ψ

/-- expand_temporal produces formulas with no all_past/all_future. -/
theorem expand_has_no_allpast_allfuture (φ : Formula) :
    has_no_allpast_allfuture (expand_temporal φ) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb => simp [expand_temporal, has_no_allpast_allfuture, iha, ihb]
  | box _ => rfl
  | all_past a ih =>
    simp [expand_temporal, Formula.neg, Formula.top, has_no_allpast_allfuture, ih]
  | all_future a ih =>
    simp [expand_temporal, Formula.neg, Formula.top, has_no_allpast_allfuture, ih]
  | untl a b iha ihb => simp [expand_temporal, has_no_allpast_allfuture, iha, ihb]
  | snce a b iha ihb => simp [expand_temporal, has_no_allpast_allfuture, iha, ihb]

/-! ## In the restricted fragment (no all_past/all_future), JD=0 implies separated

After `expand_temporal`, there are no `all_past`/`all_future` nodes.
In this restricted fragment, `junction_depth = 0` implies
`is_syntactically_separated = true`. This was the key finding from Report 03:
on integer time, the counterexample `all_past (untl a b)` has JD=0 but is not
separated -- but this pattern is eliminated by `expand_temporal`. -/

/-- In the restricted fragment (no all_past/all_future), a formula with junction_depth = 0
    is syntactically separated. -/
theorem expanded_jd_zero_imp_separated (φ : Formula)
    (hexp : has_no_allpast_allfuture φ = true)
    (hjd : junction_depth φ = 0) :
    is_syntactically_separated φ = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp [has_no_allpast_allfuture] at hexp
    simp [junction_depth] at hjd
    simp [is_syntactically_separated, iha hexp.1 (by omega), ihb hexp.2 (by omega)]
  | box _ => rfl
  | all_past _ => simp [has_no_allpast_allfuture] at hexp
  | all_future _ => simp [has_no_allpast_allfuture] at hexp
  | untl a b _iha _ihb =>
    -- JD of untl = max (JD_U a) (JD_U b). JD = 0 means JD_U a = 0 and JD_U b = 0.
    -- JD_U = 0 means S-free.
    simp [junction_depth] at hjd
    have ha := junction_depth_U_zero_imp_S_free a (by omega)
    have hb := junction_depth_U_zero_imp_S_free b (by omega)
    simp [is_syntactically_separated, ha, hb]
  | snce a b _iha _ihb =>
    -- JD of snce = max (JD_S a) (JD_S b). JD = 0 means JD_S a = 0 and JD_S b = 0.
    -- JD_S = 0 means U-free.
    simp [junction_depth] at hjd
    have ha := junction_depth_S_zero_imp_U_free a (by omega)
    have hb := junction_depth_S_zero_imp_U_free b (by omega)
    simp [is_syntactically_separated, ha, hb]

/-! ## expand_temporal preserves syntactic properties

Note: `expand_temporal` does NOT preserve `is_S_free` or `is_U_free` in general
because it replaces `all_past φ` with `neg(snce(neg(expand φ))(top))` (introducing
snce, breaking S-freeness) and `all_future φ` with `neg(untl(neg(expand φ))(top))`
(introducing untl, breaking U-freeness).

However, it DOES preserve these properties for formulas that have no all_past
(for S-free) or no all_future (for U-free), which is the case in separated
formulas: untl args are S-free (no snce, hence also no all_past in practice
since all_past is S-compatible), and snce args are U-free (no untl, hence also
no all_future in practice since all_future is U-compatible).

Actually, the precise statement is: S-free formulas CAN contain all_past
(since `is_S_free (.all_past a) = is_S_free a`), but expanding all_past
introduces snce, breaking S-freeness. So we need a restricted version. -/

/-- expand_temporal preserves is_U_free for formulas with no all_future.
    Since U-free formulas have no untl but CAN have all_future (which
    expand_temporal would replace with untl), we need to exclude all_future. -/
private theorem expand_preserves_U_free_no_allf (φ : Formula)
    (hu : is_U_free φ = true) (hnaf : has_no_allpast_allfuture φ = true) :
    is_U_free (expand_temporal φ) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp [is_U_free] at hu; simp [has_no_allpast_allfuture] at hnaf
    simp [expand_temporal, is_U_free, iha hu.1 hnaf.1, ihb hu.2 hnaf.2]
  | box _ => simp [expand_temporal, is_U_free] at hu ⊢; exact hu
  | all_past _ => simp [has_no_allpast_allfuture] at hnaf
  | all_future _ => simp [has_no_allpast_allfuture] at hnaf
  | untl _ _ => simp [is_U_free] at hu
  | snce a b iha ihb =>
    simp [is_U_free] at hu; simp [has_no_allpast_allfuture] at hnaf
    simp [expand_temporal, is_U_free, iha hu.1 hnaf.1, ihb hu.2 hnaf.2]

/-- expand_temporal preserves is_S_free for formulas with no all_past.
    Since S-free formulas have no snce but CAN have all_past (which
    expand_temporal would replace with snce), we need to exclude all_past. -/
private theorem expand_preserves_S_free_no_allp (φ : Formula)
    (hs : is_S_free φ = true) (hnap : has_no_allpast_allfuture φ = true) :
    is_S_free (expand_temporal φ) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp [is_S_free] at hs; simp [has_no_allpast_allfuture] at hnap
    simp [expand_temporal, is_S_free, iha hs.1 hnap.1, ihb hs.2 hnap.2]
  | box _ => simp [expand_temporal, is_S_free] at hs ⊢; exact hs
  | all_past _ => simp [has_no_allpast_allfuture] at hnap
  | all_future _ => simp [has_no_allpast_allfuture] at hnap
  | untl a b iha ihb =>
    simp [is_S_free] at hs; simp [has_no_allpast_allfuture] at hnap
    simp [expand_temporal, is_S_free, iha hs.1 hnap.1, ihb hs.2 hnap.2]
  | snce _ _ => simp [is_S_free] at hs

/-! ## Restricted Fragment: no_S_nested_in_U and U-free implies separated

In the restricted fragment (no `all_past`/`all_future` constructors),
a formula with `no_S_nested_in_U` and `is_U_free` has junction_depth = 0,
hence is syntactically separated. This is the base case for the
junction-depth approach to proving temporal closure without axioms. -/

/-- In the restricted fragment (no all_past/all_future), a U-free formula
    is syntactically separated. This is the base case for junction-depth
    induction: JD=0 after expansion means U-free, which means separated. -/
theorem restricted_u_free_separated (phi : Formula)
    (hrestr : has_no_allpast_allfuture phi = true)
    (huf : is_U_free phi = true) :
    is_syntactically_separated phi = true :=
  expanded_jd_zero_imp_separated phi hrestr (u_free_junction_depth_zero phi huf)

end Bimodal.Metalogic.WeakCanonical.Separation
