/-!
# ARCHIVED: Dense Limit Domain Infrastructure

**Status**: Reference only — NOT imported by active modules.
**Origin**: Extracted from ChronicleConstruction.lean and ChronicleToCountermodel.lean (task 117).
**Purpose**: Preserve density-related theorems for potential future dense variant (F'T axiom).

This file contains:
- `limit_dom_dense`: The limit domain is dense (between any two domain points exists another)
- `limitDomSubtype_denselyOrdered`: DenselyOrdered instance for LimitDomSubtype
- `LimitAdjacent`: Adjacency definition for Set Rat (limit domain)
- `no_adjacent_in_dense`: No adjacent pairs in dense sets

These were removed because the natural inclusion approach (X ⊂ Q) does not
require density of the limit domain. The Cantor isomorphism pathway required
density to invoke `Order.iso_of_countable_dense`; the natural inclusion avoids
this entirely.

## Restore Instructions

To restore density support:
1. Add `| density` back to `PotentialCounterexampleKind` in CounterexampleElimination.lean
2. Add `density_witness` field back to `EliminationResult`
3. Add these definitions back to ChronicleConstruction.lean
4. Add `limitDomSubtype_denselyOrdered` back to ChronicleToCountermodel.lean
-/

-- THIS FILE DOES NOT BUILD. It is archived reference code only.
-- Do not add to any lakefile or import list.

#exit

/-
-- From ChronicleConstruction.lean (CC:746-776):

theorem limit_dom_dense (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x y : Rat) (hx : x ∈ limit_dom A h_mcs) (hy : y ∈ limit_dom A h_mcs)
    (hxy : x < y) :
    ∃ z ∈ limit_dom A h_mcs, x < z ∧ z < y := by
  obtain ⟨nx, hnx⟩ := hx
  obtain ⟨ny, hny⟩ := hy
  set n₀ := max nx ny with hn₀_def
  have hx_n₀ : x ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_left nx ny) hnx
  have hy_n₀ : y ∈ (omega_chain_val A h_mcs n₀).dom :=
    omega_chain_dom_mono_le A h_mcs (le_max_right nx ny) hny
  obtain ⟨n, hn_ge, hn_eq⟩ := counterexample_enum_surjective_above
    ⟨x, y, Formula.bot, Formula.bot, .density⟩ n₀
  have hx_n : x ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hx_n₀
  have hy_n : y ∈ (omega_chain_val A h_mcs n).dom :=
    omega_chain_dom_mono_le A h_mcs hn_ge hy_n₀
  have key := (omega_chain_elim_result A h_mcs n).density_witness
    (show (counterexample_enum (Nat.unpair n).2).kind = .density by rw [hn_eq])
    (show (counterexample_enum (Nat.unpair n).2).x ∈ (omega_chain_val A h_mcs n).dom
      by rw [hn_eq]; exact hx_n)
    (show (counterexample_enum (Nat.unpair n).2).y ∈ (omega_chain_val A h_mcs n).dom
      by rw [hn_eq]; exact hy_n)
    (show (counterexample_enum (Nat.unpair n).2).x < (counterexample_enum (Nat.unpair n).2).y
      by rw [hn_eq]; exact hxy)
  obtain ⟨z, hz_dom, hxz, hzy⟩ := key
  have hz_dom' : z ∈ (omega_chain_val A h_mcs (n + 1)).dom := by
    rw [omega_chain_dom_eq_elim]; exact hz_dom
  exact ⟨z, ⟨n + 1, hz_dom'⟩,
    by simp only [hn_eq] at hxz; exact hxz,
    by simp only [hn_eq] at hzy; exact hzy⟩

-- From ChronicleConstruction.lean (CC:975-987):

def LimitAdjacent (D : Set Rat) (x y : Rat) : Prop :=
  x ∈ D ∧ y ∈ D ∧ x < y ∧ ∀ z ∈ D, ¬(x < z ∧ z < y)

theorem no_adjacent_in_dense {D : Set Rat}
    (h_dense : ∀ x y : Rat, x ∈ D → y ∈ D → x < y → ∃ z ∈ D, x < z ∧ z < y)
    (x y : Rat) : ¬LimitAdjacent D x y := by
  intro ⟨hx, hy, hxy, h_no_between⟩
  obtain ⟨z, hz, hxz, hzy⟩ := h_dense x y hx hy hxy
  exact h_no_between z hz ⟨hxz, hzy⟩

-- From ChronicleToCountermodel.lean (lines 96-106):

instance limitDomSubtype_denselyOrdered (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    :
    DenselyOrdered (LimitDomSubtype A h_mcs) where
  dense := by
    intro ⟨a, ha⟩ ⟨b, hb⟩ hab
    obtain ⟨z, hz, haz, hzb⟩ := limit_dom_dense A h_mcs a b ha hb hab
    exact ⟨⟨z, hz⟩, haz, hzb⟩
-/
