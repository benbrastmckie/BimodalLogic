/-!
# ARCHIVED: Dense Counterexample Elimination

**Status**: Reference only — NOT imported by active modules.
**Origin**: Extracted from CounterexampleElimination.lean (task 117).
**Purpose**: Preserve density-related code for potential future dense variant (F'T axiom).

This file contains the `.density` counterexample kind, the `density_witness` field
of `EliminationResult`, and the `eliminate_density_counterexample` helper that was
used to insert midpoints between adjacent domain points.

The density pathway was removed because `SetConsistent (χ.g x y)` could not be
proven in the omega chain without additional architectural machinery (Zorn on CUD
sets producing SDC). The sorry at CE:3570 was the sole remaining sorry in the
completeness proof.

## Restore Instructions

To restore density support:
1. Add `| density` back to `PotentialCounterexampleKind`
2. Add `density_witness` field back to `EliminationResult`
3. Add density boilerplate discharges to all non-density branches
4. Add `.density =>` branch to `eliminate_potential_counterexample`
5. Prove `SetConsistent (χ.g x y)` or restructure to avoid it
-/

-- THIS FILE DOES NOT BUILD. It is archived reference code only.
-- Do not add to any lakefile or import list.

#exit

/-
-- Original PotentialCounterexampleKind with density variant:

inductive PotentialCounterexampleKind : Type where
  | c4_forward    : PotentialCounterexampleKind
  | c4_backward   : PotentialCounterexampleKind
  | c5_forward    : PotentialCounterexampleKind
  | c5_backward   : PotentialCounterexampleKind
  | density       : PotentialCounterexampleKind
  deriving DecidableEq, Countable

-- Original density_witness field in EliminationResult:

  density_witness : pc.kind = .density → pc.x ∈ χ.dom → pc.y ∈ χ.dom →
    pc.x < pc.y →
    ∃ z ∈ val.dom, pc.x < z ∧ z < pc.y

-- Density elimination helper (CE:520-561):

noncomputable def eliminate_density_counterexample {χ : Chronicle}
    (h_c0 : χ.c0)
    (x y : Rat)
    (h_x_mem : x ∈ χ.dom) (h_y_mem : y ∈ χ.dom)
    (h_adj : Adjacent χ.dom x y) :
    ∃ χ' : Chronicle,
      χ.dom ⊆ χ'.dom ∧
      (∀ q ∈ χ.dom, χ'.f q = χ.f q) ∧
      χ'.c0 ∧
      (∃ z ∈ χ'.dom, x < z ∧ z < y) ∧
      χ.dom ⊂ χ'.dom ∧
      (∀ a b, a ∈ χ.dom → b ∈ χ.dom → χ'.g a b = χ.g a b) ∧
      (∀ a b, χ'.g a b = χ.g a b) := by
  set z := (x + y) / 2 with hz_def
  have hxy := h_adj.2.2.1
  have hz_lt_y : z < y := by linarith
  have hx_lt_z : x < z := by linarith
  have hz_notin : z ∉ χ.dom := by
    intro h_mem; exact h_adj.2.2.2 z h_mem ⟨hx_lt_z, hz_lt_y⟩
  refine ⟨⟨fun q => if q = z then χ.f x else χ.f q, χ.g, insert z χ.dom⟩,
    Finset.subset_insert z χ.dom, ?_, ?_, ?_, Finset.ssubset_insert hz_notin,
    fun _ _ _ _ => rfl, fun _ _ => rfl⟩
  · intro q hq
    have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
    exact if_neg h_ne
  · intro q hq
    simp only [Finset.mem_insert] at hq
    rcases hq with rfl | hq
    · simp only [ite_true]; exact h_c0 x h_x_mem
    · have h_ne : q ≠ z := fun h => hz_notin (h ▸ hq)
      simp only [h_ne, ite_false]; exact h_c0 q hq
  · refine ⟨z, Finset.mem_insert_self z χ.dom, hx_lt_z, hz_lt_y⟩

-- Density branch of eliminate_potential_counterexample (CE:3535-3783):
-- This branch contained the sorry at CE:3570 for SetConsistent (χ.g pc.x pc.y).
-- The full branch handled:
--   1. h_actual case: x,y adjacent → split with lemma_2_6 → insert midpoint
--   2. ¬h_actual case: not adjacent → witness already exists between x,y
-- See git history for the complete code.
-/
