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

end Bimodal.Metalogic.WeakCanonical.Separation
