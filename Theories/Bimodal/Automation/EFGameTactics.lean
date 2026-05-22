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

end Bimodal.Metalogic.WeakCanonical
