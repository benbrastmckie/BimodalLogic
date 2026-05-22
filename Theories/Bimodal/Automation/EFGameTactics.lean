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

end Bimodal.Metalogic.WeakCanonical
