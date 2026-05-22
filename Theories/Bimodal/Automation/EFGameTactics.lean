import Bimodal.Metalogic.WeakCanonical.EFGames
import Lean

/-!
# EF Game Automation Tactics

Custom tactics for automating repetitive proof patterns in the EF game
infrastructure (GHR93 expressive completeness proof).

## Components

- **Component B**: `simp_game_tuple` — simp rewrite set for game_tuple normalization
- **Component C**: `pivot_order` — auto-fill interval bounds for pivot_chain_order
- **Component D**: `winning_condition_tac` — 4-way index split for gap_point/formula agreement
- **Component A**: `same_order_type_grid` — N×N grid dispatch for same_order_type

## References

- GHR93 (Gabbay, Hodkinson, Reynolds, 1994), Chapter 9, Section 8
- Task 195: EF Game Automation Tactics
-/

namespace Bimodal.Metalogic.WeakCanonical

open Lean Elab Tactic

/-! ## Component B: game_tuple_simp -/

/-- `simp_game_tuple` simplifies `game_tuple` expressions using the four
    index-category lemmas: `game_tuple_zero_eq`, `game_tuple_b_eq`,
    `game_tuple_y_eq`, `game_tuple_sel_eq`.

    Usage:
    - `simp_game_tuple` — simplify the goal
    - `simp_game_tuple at h` — simplify hypothesis `h`
    - `simp_game_tuple at h1 h2` — simplify multiple hypotheses
    - `simp_game_tuple at *` — simplify goal and all hypotheses -/
macro "simp_game_tuple" loc:(Lean.Parser.Tactic.location)? : tactic =>
  match loc with
  | some loc =>
    `(tactic| simp only [game_tuple_zero_eq, game_tuple_b_eq,
        game_tuple_y_eq, game_tuple_sel_eq] $loc)
  | none =>
    `(tactic| simp only [game_tuple_zero_eq, game_tuple_b_eq,
        game_tuple_y_eq, game_tuple_sel_eq])

/-- `game_tuple_unfold` unfolds game_tuple via its definition (using dite)
    and resolves the conditional branches with `split_ifs` and `omega`.

    Usage:
    - `game_tuple_unfold` — unfold in the goal
    - `game_tuple_unfold at h` — unfold in hypothesis `h` -/
macro "game_tuple_unfold" loc:(Lean.Parser.Tactic.location)? : tactic =>
  match loc with
  | some loc =>
    `(tactic| (simp only [game_tuple] $loc; split_ifs <;> try omega))
  | none =>
    `(tactic| (simp only [game_tuple]; split_ifs <;> try omega))

/-! ## Component C: pivot_order -/

/-- `pivot_chain_order'` is a convenience wrapper around `pivot_chain_order` that
    takes the left and right ordering witnesses as pairs rather than as 4
    separate arguments. This matches the natural shape of hypotheses extracted
    from `same_order_type` sub-game results.

    Instead of:
    ```
    exact pivot_chain_order hap hpb ha'q hqb' hord_l.1 hord_l.2 hord_r.1 hord_r.2
    ```
    Write:
    ```
    exact pivot_chain_order' hap hpb ha'q hqb' hord_l hord_r
    ``` -/
theorem pivot_chain_order' {α β : Type*} [LinearOrder α] [LinearOrder β]
    {a p b : α} {a' q b' : β}
    (hap : a ≤ p) (hpb : p ≤ b) (ha'q : a' ≤ q) (hqb' : q ≤ b')
    (hord_l : (a < p ↔ a' < q) ∧ (a = p ↔ a' = q))
    (hord_r : (p < b ↔ q < b') ∧ (p = b ↔ q = b')) :
    (a < b ↔ a' < b') ∧ (a = b ↔ a' = b') :=
  pivot_chain_order hap hpb ha'q hqb' hord_l.1 hord_l.2 hord_r.1 hord_r.2

/-- `pivot_chain_order_rev'` is a convenience wrapper around `pivot_chain_order_rev`
    that takes the ordering witnesses as pairs. -/
theorem pivot_chain_order_rev' {α β : Type*} [LinearOrder α] [LinearOrder β]
    {a p b : α} {a' q b' : β}
    (hpa : p ≤ a) (hbp : b ≤ p) (hqa' : q ≤ a') (hb'q : b' ≤ q)
    (hord_l : (p < a ↔ q < a') ∧ (p = a ↔ q = a'))
    (hord_r : (b < p ↔ b' < q) ∧ (b = p ↔ b' = q)) :
    (a < b ↔ a' < b') ∧ (a = b ↔ a' = b') :=
  pivot_chain_order_rev hpa hbp hqa' hb'q hord_l.1 hord_l.2 hord_r.1 hord_r.2

/-- `order_refl` closes goals of the form
    `(a < a ↔ b < b) ∧ (a = a ↔ b = b)` — the diagonal case in the
    same_order_type grid where both indices refer to the same element. -/
theorem order_refl_pair {α β : Type*} [Preorder α] [Preorder β] (a : α) (b : β) :
    (a < a ↔ b < b) ∧ (a = a ↔ b = b) :=
  ⟨⟨fun h => absurd h (lt_irrefl _), fun h => absurd h (lt_irrefl _)⟩,
   ⟨fun _ => rfl, fun _ => rfl⟩⟩

/-- `order_refl` tactic closes goals of the form
    `(a < a ↔ b < b) ∧ (a = a ↔ b = b)`. -/
macro "order_refl" : tactic =>
  `(tactic| exact order_refl_pair _ _)

end Bimodal.Metalogic.WeakCanonical
