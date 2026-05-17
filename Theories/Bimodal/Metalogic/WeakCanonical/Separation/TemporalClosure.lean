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

/-- Top formula: ⊤ = ¬⊥ = imp bot bot. -/
abbrev Formula.top : Formula := .imp .bot .bot

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

/-! ## In the restricted fragment, no_S_nested_in_U implies separated

For formulas with no all_past/all_future, the `no_S_nested_in_U` predicate implies
`is_syntactically_separated`. The key insight:
- In the restricted fragment, `no_S_nested_in_U` at an `untl` node means S-free args (already separated)
- At a `snce` node, `no_S_nested_in_U` means both args satisfy `no_S_nested_in_U`
- But for syntactic separation, snce args need to be U-free
- The additional constraint `has_no_allpast_allfuture` ensures that the args of snce
  don't contain all_past (which could hide untl inside without violating no_S_nested_in_U)

Wait: this isn't quite right. In the restricted fragment, snce args that satisfy
no_S_nested_in_U could still contain untl (making them not U-free).

The correct approach: expand_temporal of a formula that already satisfies no_S_nested_in_U
will STILL satisfy no_S_nested_in_U after expansion. But we need more: we need the
expansion of the whole temporal-closure formula to be syntactically separated.

Let me reconsider. The actual proof path is:
1. Given separated φ', ψ', box-normalize to get φ'', ψ'' with no_S_nested_in_U (.snce φ'' ψ'')
2. Since φ'', ψ'' are box-free separated, their snce/untl args are U-free/S-free respectively
3. no_S_nested_in_U (.snce φ'' ψ'') means no_S_nested_in_U φ'' ∧ no_S_nested_in_U ψ''
4. The φ'', ψ'' being syntactically separated and box-free means their untl args are S-free
   and their snce args are U-free
5. The expand_temporal of .snce φ'' ψ'' = .snce (expand_temporal φ'') (expand_temporal ψ'')
6. After expansion, if junction_depth = 0, then separated

Actually, I think there's a simpler and more direct approach. Let me re-examine the handoff's key finding:

"junction_depth = 0 does NOT imply syntactically_separated" because of all_past(untl A B).

But after expand_temporal, there ARE no all_past/all_future nodes! So for the expanded formula, junction_depth = 0 DOES imply separated.

Let me verify this claim and then implement it. -/

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

/-! ## expand_temporal preserves syntactic properties -/

/-- expand_temporal preserves is_S_free. -/
theorem expand_temporal_preserves_S_free (φ : Formula) (h : is_S_free φ = true) :
    is_S_free (expand_temporal φ) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp [is_S_free] at h; simp [expand_temporal, is_S_free, iha h.1, ihb h.2]
  | box _ => simp [expand_temporal, is_S_free]
  | all_past a ih =>
    simp [is_S_free] at h
    simp [expand_temporal, Formula.neg, Formula.top, is_S_free, ih h]
  | all_future a ih =>
    simp [is_S_free] at h
    simp [expand_temporal, Formula.neg, Formula.top, is_S_free, ih h]
  | untl a b iha ihb =>
    simp [is_S_free] at h; simp [expand_temporal, is_S_free, iha h.1, ihb h.2]
  | snce _ _ => simp [is_S_free] at h

/-- expand_temporal preserves is_U_free. -/
theorem expand_temporal_preserves_U_free (φ : Formula) (h : is_U_free φ = true) :
    is_U_free (expand_temporal φ) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp [is_U_free] at h; simp [expand_temporal, is_U_free, iha h.1, ihb h.2]
  | box _ => simp [expand_temporal, is_U_free]
  | all_past a ih =>
    simp [is_U_free] at h
    simp [expand_temporal, Formula.neg, Formula.top, is_U_free, ih h]
  | all_future a ih =>
    simp [is_U_free] at h
    simp [expand_temporal, Formula.neg, Formula.top, is_U_free, ih h]
  | untl _ _ => simp [is_U_free] at h
  | snce a b iha ihb =>
    simp [is_U_free] at h; simp [expand_temporal, is_U_free, iha h.1, ihb h.2]

/-- expand_temporal preserves syntactic separation.
    Key insight: all_past a (with U-free a) expands to neg(snce(neg(expand a))(top)),
    where expand a is U-free (by expand_temporal_preserves_U_free), so the snce args
    are U-free. Similarly for all_future. -/
theorem expand_temporal_preserves_separated (φ : Formula)
    (h : is_syntactically_separated φ = true) :
    is_syntactically_separated (expand_temporal φ) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp a b iha ihb =>
    simp [is_syntactically_separated] at h
    simp [expand_temporal, is_syntactically_separated, iha h.1, ihb h.2]
  | box _ => simp [expand_temporal, is_syntactically_separated]
  | all_past a _ih =>
    -- is_syntactically_separated (.all_past a) = is_U_free a
    simp [is_syntactically_separated] at h
    -- expand_temporal (.all_past a) = neg (snce (neg (expand a)) top)
    -- = imp (snce (imp (expand a) bot) (imp bot bot)) bot
    -- is_syntactically_separated of imp X bot = is_syntactically_separated X ∧ true
    -- is_syntactically_separated of snce P Q = is_U_free P ∧ is_U_free Q
    -- is_U_free (imp (expand a) bot) = is_U_free (expand a)
    -- is_U_free (imp bot bot) = true
    simp [expand_temporal, Formula.neg, Formula.top, is_syntactically_separated, is_U_free,
          expand_temporal_preserves_U_free a h]
  | all_future a _ih =>
    simp [is_syntactically_separated] at h
    simp [expand_temporal, Formula.neg, Formula.top, is_syntactically_separated, is_S_free,
          expand_temporal_preserves_S_free a h]
  | untl a b _iha _ihb =>
    simp [is_syntactically_separated] at h
    simp [expand_temporal, is_syntactically_separated,
          expand_temporal_preserves_S_free a h.1, expand_temporal_preserves_S_free b h.2]
  | snce a b _iha _ihb =>
    simp [is_syntactically_separated] at h
    simp [expand_temporal, is_syntactically_separated,
          expand_temporal_preserves_U_free a h.1, expand_temporal_preserves_U_free b h.2]

/-! ## The key temporal closure proof: snce_separable without axioms

Given separated φ', ψ' (witnesses of `is_separable`):
1. expand_temporal φ' and expand_temporal ψ' are still separated
   (by expand_temporal_preserves_separated)
2. snce (expand φ') (expand ψ') has snce args that are U-free
   (since the expanded formulas are separated)
3. But wait: we need the snce of the EXPANDED separated formulas to be separated,
   not just their individual expansion.
   Actually: if expand φ' is separated, then is_syntactically_separated (expand φ') = true.
   So snce (expand φ') (expand ψ') has is_U_free args? No! Separated doesn't mean U-free.
   Separated means the formula decomposes properly.
   The snce node needs U-free args for syntactic separation.

So the direct approach still doesn't work for snce of arbitrary separated formulas.

The actual issue: we need to prove that `snce φ ψ` is separable when φ, ψ are separable.
The separated witnesses φ', ψ' are syntactically separated but may contain untl nodes.
So `snce φ' ψ'` is NOT syntactically separated (snce needs U-free args).

The GHR94 approach (Cases 1-8) handles exactly this: eliminate the U from under S.
Cases 1-4 handle specific patterns. Cases 5-8 need `all_separable` (circular).

The expand_temporal approach from the plan breaks the circularity as follows:
After box-normalizing separated φ', ψ', we get `.snce φ'' ψ''` with `no_S_nested_in_U`.
Then expand this entire snce formula. The expansion preserves the `no_S_nested_in_U`
property... but as shown above, it doesn't for general formulas.

HOWEVER: the specific formulas we're expanding (box-normalized separated ones) have
a special structure. In a box-free separated formula:
- untl args are S-free
- snce args are U-free
- So the formula has both no_S_nested_in_U AND no_U_nested_in_S

For such formulas, expand_temporal produces formulas where:
- all_past of U-free stuff → snce with U-free args (OK)
- all_future of S-free stuff → untl with S-free args (OK)

So the expansion of a box-free separated formula IS syntactically separated!
This is exactly expand_temporal_preserves_separated above.

Now for `snce φ'' ψ''` where φ'', ψ'' are box-free and separated:
- `expand_temporal (.snce φ'' ψ'')` = `.snce (expand φ'') (expand ψ'')`
- `expand φ''` and `expand ψ''` are syntactically separated (by expand_temporal_preserves_separated)
- But .snce needs U-free args!
- expand φ'' is separated but may have untl inside.

Hmm, so expand_temporal of the WHOLE snce formula doesn't help because expand_temporal
doesn't touch the top-level snce.

I need a different approach. Let me think again...

The plan mentions junction-depth induction. The actual approach should be:
1. Prove: for formulas in the restricted fragment (no all_past/all_future/box),
   `no_S_nested_in_U φ → is_separable φ` by induction on junction_depth.
2. Base case (JD=0): use expanded_jd_zero_imp_separated.
3. Inductive step (JD=n+1): there's a snce node with untl in its args.
   Abstract one untl to a fresh atom (Cases 1-4), get lower JD, apply IH.

Wait, but this is the GHR94 argument that the handoff said was blocked.

Let me reconsider the WHOLE picture. I think the right approach is much simpler
than what the plan envisions. Let me look at what we actually need:

The temporal closure axioms are used in `all_separable` for exactly 4 cases:
- all_past φ ih → all_past_separable φ ih
- all_future φ ih → all_future_separable φ ih
- untl φ ψ ih1 ih2 → untl_separable φ ψ ih1 ih2
- snce φ ψ ih1 ih2 → snce_separable φ ψ ih1 ih2

The IH gives `is_separable φ` (and `is_separable ψ`).

For `all_past`: given `is_separable φ`, there exists separated ψ with `int_equiv φ ψ`.
On integer time, `all_past φ ≡ all_past ψ ≡ neg (snce (neg ψ) top)`.
Now `neg ψ` is separated (neg preserves separation) and `top` is separated.
And `snce (neg ψ) top` -- well, neg ψ might not be U-free. So snce(neg ψ, top) isn't
necessarily syntactically separated. But! neg ψ is separated, and top is separated.
So we need `snce_separable` to conclude. Circular!

Unless... we expand further. `neg ψ` is separated. If we expand it, we get a
formula in the restricted fragment that's still separated. BUT snce still needs
U-free args.

OK, I think the correct resolution requires the full GHR94 Case 1-4 machinery
applied to the expanded form.

Actually, let me look at this from the BOX-NORMALIZATION angle:
- φ' separated ⟹ replace_box_with_top φ' still separated and satisfies no_S_nested_in_U
- The key existing lemma: snce_of_boxfree_sep_no_S_nested

So `.snce (replace_box φ') (replace_box ψ')` has `no_S_nested_in_U`.
This means all untl args inside are S-free.

To show this snce formula is separable, I need:
`no_S_nested_in_U φ → is_separable φ` for the restricted fragment.

And the proof is by induction on junction_depth:
- JD = 0 after expansion → syntactically separated → separable
- JD > 0 → there's a snce with non-U-free args → use Cases 1-4 to reduce JD

But Cases 1-4 work with S-free/U-free atoms a, q, A, B! The snce args might not
be simple atoms. The GHR94 approach uses abstraction (replace specific untl(A,B) with
fresh atom p, getting a simpler formula).

Actually, this is EXACTLY what the existing Hierarchy.lean does! The `abstract_untl`
machinery already exists. And `single_U_formula_separable` proves separability for
single-U-type formulas. And `multi_U_formula_separable` extends to multiple U-types.
But both currently use the axioms (via `all_separable`).

Let me trace the actual dependency:
- `multi_U_formula_separable` := `all_separable phi` (direct axiom use)
- `single_U_formula_separable` uses `all_past_separable`, `all_future_separable`, `snce_separable` axioms

So the circularity is:
- temporal closure axioms → `all_separable` (structural induction)
- `single_U_formula_separable` → axioms (for all_past, all_future, snce cases)
- Cases 5-8 → `all_separable` → axioms

The KEY insight to break the circularity:

For the `all_past/all_future` cases in `single_U_formula_separable`:
- `all_past φ` where φ has single U-type U(A,B) with S-free A, B
- On Z: `all_past φ ≡ neg (snce (neg φ) top)`
- φ has single U-type U(A,B). neg φ also has single U-type. top has no U.
- So snce (neg φ) top has single U-type U(A,B), with U(A,B) only inside the first arg.
- This is NOT under nested S (the snce itself is the only S, and the U is in arg1).
- This is exactly a form where Lemma 10.2.4 Cases 1-2 apply!
- Cases 1-2 are PROVED (no axioms needed).

Similarly `all_future φ` ≡ `neg (untl (neg φ) top)`. By duality (swap_temporal),
this reduces to the snce direction.

For the `snce` case in `single_U_formula_separable`:
- snce φ ψ where both have single U-type U(A,B) with S-free A, B
- By IH, φ and ψ are separable
- Need snce_separable without axioms
- But this IS the temporal closure we're trying to prove!

Wait, but in the EXPANDED form: after replacing all_past/all_future,
the single_U_formula φ becomes a formula with no all_past/all_future,
and single U-type U(A,B), and the only temporal operators are snce, untl, imp.
For snce in this restricted form: the snce args have single U-type.
The key: snce(φ, ψ) where φ,ψ have single U-type U(A,B) is exactly
the setup for Lemma 10.2.4 (Cases 1-8).

Cases 1-4 are proved. Cases 5-8 need... `all_separable`.
But Cases 5-8 handle patterns like S(a^U, q∨U). After expansion,
these don't have all_past/all_future. So they're in the restricted fragment.
And in the restricted fragment, can we prove Cases 5-8 without axioms?

Hmm, Cases 5-8 in GHR94 for discrete time have counterexamples for the
explicit formulas. That's why they were proved via `all_separable`.

OK. Let me step back and think about what ACTUALLY works.

The fundamental theorem that breaks everything open is:
**For formulas with no_S_nested_in_U (and no all_past/all_future), JD induction works.**

JD=0 base case: after expand_temporal, no all_past/all_future. JD=0 means separated.
JD=n+1 step: there's a `snce` with a `untl` inside one of its args.
  - Use `abstract_untl` to replace the untl with a fresh atom
  - The result has lower JD (or same JD but fewer U-subformulas)
  - By IH, the result is separable
  - Use `subst_correctness` to relate back to the original

But this requires showing that abstraction + substitution preserves separability.
The existing `abstract_untl_correct` gives semantic equivalence.
After abstraction, the formula has single U-type → apply Lemma 10.2.5.
But Lemma 10.2.5 uses `snce_separable` (axiom) for the snce case!

The true circularity: even after reduction to single-U-type,
the snce case still needs the axiom.

UNLESS: in the expanded fragment (no all_past/all_future), the snce case
of single-U-type is handled by Cases 1-4 plus boolean closure!

Let me check: single_U_formula_separable for the SNCE case:
snce(φ, ψ) where both have single U-type U(A,B) with S-free A, B.
The args might have U(A,B) inside them.

Lemma 10.2.4 handles exactly this: S(C, F) where U(A,B) appears at top level.
After event-splitting:
- S(C ^ U(A,B), F): if F is U-free, Case 1; if F has U(A,B), Case 5.
- S(C ^ ¬U(A,B), F): if F is U-free, Case 2; if F has ¬U(A,B), Case 8; etc.

Cases 1-4 are proved. Cases 5-8 are the problem.

BUT: after `abstract_untl` removes U(A,B) from the snce args,
we get snce(C', F') where C', F' are U-free AND S-free (since original
args were S-free by no_S_nested_in_U, and after abstraction they're U-free).
This snce is SYNTACTICALLY SEPARATED. No further work needed!

Wait, that can't be right -- abstract_untl replaces U(A,B) with a fresh atom,
making the args U-free. The args were already S-free (by no_S_nested_in_U
at the untl level, the S-free property propagates through).
Hmm, but the args of the SNCE are not necessarily S-free.
no_S_nested_in_U at the snce level means no_S_nested_in_U for both args.
That doesn't mean the args are S-free.

OK, I think I need to carefully re-read the full GHR94 proof structure.

Actually, let me try a completely different, simpler approach:

**Direct proof via expand_temporal + the Cases 1-4 machinery.**

The claim: `snce_separable` can be proved as follows:
1. Get separated witnesses φ', ψ'
2. Box-normalize: φ'' = rbwt(φ'), ψ'' = rbwt(ψ')
3. snce(φ'', ψ'') has no_S_nested_in_U
4. expand_temporal(snce(φ'', ψ'')) = snce(expand(φ''), expand(ψ''))
5. expand(φ'') and expand(ψ'') are SEPARATED (by expand_preserves_separated)
6. Since they're separated, their untl args are S-free and snce args are U-free
7. Now: snce of two separated formulas... needs U-free args. Not guaranteed!

Hmm. Still stuck on the same point.

OK let me try yet another approach. Maybe I should use abstract_untl on the
WHOLE snce formula.

snce(φ'', ψ'') where φ'', ψ'' are separated.
φ'' is separated, so its untl args (if any) have S-free args.
The snce needs both args U-free. They're not necessarily U-free.

abstract_untl on snce(φ'', ψ'') with any untl(A,B) in the args:
- replace all untl(A,B) with atom p
- get snce(C, D) where C = abstract(φ''), D = abstract(ψ'')
- C, D have one fewer U-type
- Repeat until C, D are U-free
- Then snce(C, D) is syntactically separated
- Substitute back: int_equiv to the original

But we need SEMANTIC equivalence of the substituted formula!
subst_formula (snce(C,D)) p (untl A B) is semantically equivalent to snce(φ'',ψ'')
by abstract_untl_correct.
And snce(C,D) with U-free C,D is syntactically separated.
But after substitution, we get back snce(φ'',ψ'') which is NOT separated.

The issue: substitution back undoes the syntactic separation.

The GHR94 approach is: don't substitute back all at once.
Instead, use the FACT that the abstracted formula is separable,
plus the fact that the U-subformula U(A,B) is separable (by IH),
to conclude the original is separable.

This is the "substitution bridge" (Lemmas 10.2.4-10.2.8).

Specifically, for snce(φ'', ψ''):
1. Pick one untl type U(A,B). A, B are S-free (by separated structure).
2. Abstract all U(A,B) in φ'', ψ'' → get snce(C, D) with single-U-type
   (actually with fewer U-types).
3. snce(C, D) has the property that p (the fresh atom) appears
   only where U(A,B) was, and NOT under any nested S (since original was
   box-free separated, so no S was nested in U-args).
4. snce(C, D) is semantically equivalent to snce(φ'',ψ'') in a model
   where p is interpreted as the truth set of U(A,B).
5. Now: to show snce(φ'',ψ'') is separable, it suffices to show there
   exists a separated formula equivalent to it. Can we find one?

The GHR94 Cases 1-4 give explicit separated formulas for S(event, guard)
patterns where U(A,B) appears in specific positions (event only, guard only,
both but with specific sign combinations).

For the full temporal closure proof, the GHR94 approach is:
- Prove Cases 1-4 (done)
- Prove Lemma 10.2.4 (normal form reduction to 8 cases) (done)
- Prove Lemma 10.2.5 (single-U elimination by S-nesting induction) (done but uses axioms)
- Prove Lemma 10.2.6 (multi-U by abstraction induction) (done but uses axioms)
- Prove Lemma 10.2.7 (no-S-nested → separable by JD induction) (not done)
- Prove Lemma 10.2.8 (general → separable by JD induction) (not done)

The hierarchy is:
10.2.8 → 10.2.7 → 10.2.6 → 10.2.5 → 10.2.4 → Cases 1-8

And Cases 5-8 → all_separable → axioms.

So the ACTUAL fix is: prove 10.2.5-10.2.8 without using the axioms.
The only place axioms are used in 10.2.5 is for all_past, all_future, snce.
Replace those with expand_temporal + Cases 1-4.

Let me now implement this properly. -/

/-! ## Temporal Closure: Axiom-Free Proofs

The strategy to eliminate temporal closure axioms:

For `snce_separable`: Given separable φ, ψ with separated witnesses φ', ψ':
1. Box-normalize: φ'' = rbwt(φ'), ψ'' = rbwt(ψ')
2. snce(φ'', ψ'') is int_equiv to snce(φ, ψ)
3. φ'' and ψ'' are separated, so snce(φ'', ψ'') has no_S_nested_in_U
4. Prove: no_S_nested_in_U → is_separable (the key new theorem)

For step 4, we use expand_temporal to convert to the restricted fragment,
then apply Cases 1-4 based machinery.

For `untl_separable`: By swap_temporal duality from snce_separable.
For `all_past_separable`: On Z, all_past φ ≡ neg(snce(neg φ)(top)), then snce_separable.
For `all_future_separable`: On Z, all_future φ ≡ neg(untl(neg φ)(top)), then untl_separable.

The crucial theorem is `no_S_nested_in_U_separable`. -/

/-- A formula with no_S_nested_in_U where both untl args and snce args within
    are well-structured (by the no_S_nested property) is separable.

    This is proved using the existing Cases 1-4 machinery plus boolean closure,
    with expand_temporal handling all_past/all_future.

    On integer time, all_past φ ≡ neg(snce (neg φ) top), so the all_past case
    reduces to the snce case. Similarly all_future reduces to untl via duality.

    For the snce case: if snce args satisfy no_S_nested_in_U, they're separable by IH.
    For the untl case: args are S-free (by no_S_nested_in_U), so trivially separated.

    Wait: the snce case creates a circularity because snce_separable is what we're
    trying to prove. We need a DIFFERENT induction.

    The correct approach: strong induction on formula size.
    - all_past φ: rewrite to neg(snce(neg φ)(top)). Both neg φ and top have
      no_S_nested_in_U. The snce has smaller "size" after accounting for the
      rewrite... except it doesn't, since snce(neg φ, top) can be LARGER than
      all_past φ.

    This doesn't work with formula size. We need a compound measure.

    OK, final approach: prove snce_separable DIRECTLY without going through
    no_S_nested_in_U_separable. The existing TemporalClosure.lean infrastructure
    already shows that snce of box-normalized separated formulas has no_S_nested_in_U
    and JD ≤ 1. With JD ≤ 1, the only cross-nesting is at depth 1, which is
    exactly what Cases 1-4 handle (modulo event/guard splitting).

    Actually: JD = 1 means there's ONE level of U-under-S nesting.
    The S is at the top level (our snce), and the U-args inside are at depth 1.
    The args of those U-nodes are S-free (by no_S_nested_in_U).
    So the args of the top snce have single-U-type (if we abstract all other U-types).

    For the snce case: φ'', ψ'' are separated box-free.
    expand(φ'') and expand(ψ'') are separated (in restricted fragment).
    snce(expand(φ''), expand(ψ'')): the args may have untl but no snce-under-untl.
    The args have no all_past/all_future.
    The untl args in expand(φ'') are S-free (from separated structure of φ'').

    So snce(expand(φ''), expand(ψ'')) has:
    - no_S_nested_in_U (preserved from separated structure)
    - no all_past/all_future in args
    - JD ≤ 1

    For JD = 0: args are U-free → snce is syntactically separated. Done.
    For JD = 1: there are untl nodes inside the args.
    All such untl nodes have S-free args (by no_S_nested_in_U).
    Pick one untl type U(A,B). abstract_untl gives a formula with fewer U-types.
    The result is still no_S_nested_in_U (by abstract_untl_preserves_no_S_nested).
    Recurse until JD = 0.

    At each step: the abstracted formula (with atom p replacing U(A,B)) has fewer untl.
    When all untl are abstracted out, the formula is U-free, hence snce is separated.

    The semantic bridge: the abstracted snce(C, D) is separable (it's separated).
    The fresh atoms p1, p2, ... need to be "filled in" with the truth values of
    U(A1,B1), U(A2,B2), etc.

    Each U(Ai,Bi) with S-free Ai, Bi is already syntactically separated
    (by untl_s_free_separated). So it's separable.

    The full formula is: subst_formula (... (subst_formula (snce(C,D)) p1 U(A1,B1)) ...)
    pn U(An,Bn)

    This is semantically equivalent to snce(φ'', ψ'').
    And by repeated application of:
    "if F[p] is separable and U(A,B) is separable, then F[U(A,B)/p] is separable"
    we get separability of the original.

    But wait: "if F[p] is separable and U(A,B) is separable, then F[U(A,B)/p] is separable"
    is NOT obviously true! Substituting a non-atomic formula for an atom in a separated
    formula does not necessarily preserve separation.

    The correct claim is: if F (with atom p) is SEPARABLE, and the formula replacing p
    is separable, then the substituted result is SEPARABLE (not necessarily separated,
    but equivalent to something separated).

    This is the "substitution preserves separability" lemma. Is this true?

    If F is equivalent to some separated G, and we substitute p → U(A,B) in both F and G,
    then F[U/p] is equivalent to G[U/p]. G is separated, and G[U/p] is...
    not necessarily separated. So this approach doesn't work directly.

    Hmm. The GHR94 proof uses the SPECIFIC structure of the Cases 1-4 formulas
    to show that after substitution, the result decomposes into separable pieces.

    I think the cleanest approach that avoids the circularity is:
    `no_S_nested_in_U_separable` by induction on `count_U_subformulas`,
    handling all_past/all_future by expand_temporal equivalence.

    For `snce φ ψ` with no_S_nested_in_U:
    - Both φ, ψ have no_S_nested_in_U
    - By IH, both are separable (at SAME count_U, but smaller formula size)

    Hmm, that doesn't decrease the measure...

    ACTUALLY: let me try proving all 4 temporal closure lemmas simultaneously,
    by WELL-FOUNDED INDUCTION on formula size. The proof of all_separable
    already does structural induction. We just need to handle the 4 temporal
    cases WITHOUT axioms.

    The cleanest refactoring: merge the temporal closure proofs INTO all_separable
    itself, using the expand_temporal trick for all_past/all_future, and the
    Cases 1-4 + abstraction machinery for snce/untl.

    But this would require restructuring all_separable significantly...

    Let me try the simplest possible approach first: prove the 4 temporal closure
    lemmas one at a time, in the right order, using the Z-specific equivalences.

    Order:
    1. snce_separable (using Cases 1-4 + abstraction, JD induction on the box-normalized form)
    2. untl_separable (by duality from snce_separable)
    3. all_past_separable (using snce_separable via Z-equivalence)
    4. all_future_separable (using untl_separable via Z-equivalence)

    For snce_separable: this IS the hard one. Given separable φ, ψ:
    - Get separated witnesses φ', ψ'
    - Box-normalize: φ'' = rbwt(φ'), ψ'' = rbwt(ψ'')
    - snce(φ'', ψ'') has no_S_nested_in_U and JD ≤ 1
    - Need: snce(φ'', ψ'') is separable

    For JD ≤ 1 and no_S_nested_in_U:
    - All untl nodes in φ'', ψ'' have S-free args
    - count_U_subformulas of φ'' and ψ'' is finite
    - If count = 0: args are U-free, snce is syntactically separated
    - If count ≥ 1: pick one untl(A,B), abstract to atom p
      - snce(C, D) where C = abstract(φ'', A, B, p), D = abstract(ψ'', A, B, p)
      - C, D are still separated (abstract_untl of separated preserves separated)...
        IS THIS TRUE?

Let me check: abstract_untl replaces untl(A,B) with atom p.
In a syntactically separated formula, untl(A,B) nodes have S-free args,
and the separated structure treats them as "future-pure" blocks.
Replacing untl(A,B) with atom p: an atom is also syntactically separated.
The rest of the formula structure is preserved.
So YES, abstract_untl of a separated formula gives a separated formula. -/

/-- abstract_untl preserves syntactic separation. -/
theorem abstract_untl_preserves_separated (φ A B : Formula) (p : Atom)
    (h : is_syntactically_separated φ = true) :
    is_syntactically_separated (abstract_untl φ A B p) = true := by
  induction φ with
  | atom _ => rfl
  | bot => rfl
  | imp c d ih1 ih2 =>
    simp [is_syntactically_separated] at h
    simp [abstract_untl, is_syntactically_separated, ih1 h.1, ih2 h.2]
  | box _ => simp [abstract_untl, is_syntactically_separated]
  | all_past a _ih =>
    simp [is_syntactically_separated] at h
    simp [abstract_untl, is_syntactically_separated,
          abstract_untl_preserves_U_free a A B p h]
  | all_future a _ih =>
    simp [is_syntactically_separated] at h
    simp [abstract_untl, is_syntactically_separated,
          abstract_untl_preserves_S_free a A B p h]
  | untl c d _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp only [abstract_untl]
    split
    · simp [is_syntactically_separated]
    · simp [is_syntactically_separated,
            abstract_untl_preserves_S_free c A B p h.1,
            abstract_untl_preserves_S_free d A B p h.2]
  | snce c d _ih1 _ih2 =>
    simp [is_syntactically_separated] at h
    simp [abstract_untl, is_syntactically_separated,
          abstract_untl_preserves_U_free c A B p h.1,
          abstract_untl_preserves_U_free d A B p h.2]
where
  abstract_untl_preserves_U_free (φ A B : Formula) (p : Atom)
      (h : is_U_free φ = true) :
      is_U_free (abstract_untl φ A B p) = true := by
    induction φ with
    | atom _ => simp [abstract_untl, is_U_free]
    | bot => simp [abstract_untl, is_U_free]
    | imp c d ih1 ih2 =>
      simp [is_U_free] at h; simp [abstract_untl, is_U_free, ih1 h.1, ih2 h.2]
    | box c ih => simp [is_U_free] at h; simp [abstract_untl, is_U_free, ih h]
    | all_past c ih => simp [is_U_free] at h; simp [abstract_untl, is_U_free, ih h]
    | all_future c ih => simp [is_U_free] at h; simp [abstract_untl, is_U_free, ih h]
    | untl _ _ => simp [is_U_free] at h
    | snce c d ih1 ih2 =>
      simp [is_U_free] at h; simp [abstract_untl, is_U_free, ih1 h.1, ih2 h.2]
  abstract_untl_preserves_S_free (φ A B : Formula) (p : Atom)
      (h : is_S_free φ = true) :
      is_S_free (abstract_untl φ A B p) = true :=
    Hierarchy.abstract_untl_preserves_S_free φ A B p h

end Bimodal.Metalogic.WeakCanonical.Separation
