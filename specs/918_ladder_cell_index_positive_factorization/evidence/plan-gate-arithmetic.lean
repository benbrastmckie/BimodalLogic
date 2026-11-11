/-
PLAN-TIME GATE MEASUREMENT (task 918, plan round 01).

Layer A of Phase 1's decision gate, compiled at plan-authoring time rather than asserted.
Every declaration below is `sorry`-free and compiles through `lake env lean` against the
tree at plan time; the four statements are the ones pinned in the plan's
`## Lean Challenge Statements` block, verbatim.

WHAT THIS MEASURES.  In the ORDINARY WINDOW regime (`c <= n + 1`, the complement of the
pending-forever gap `n + 2 <= c` that all five landed depth-0 schemas carry), a `kappa`
collision at a FIXED register:

  (1) `kappa_collision_window_room` -- either pins the two countdowns equal, or exhibits a
      positive displacement by a multiple of `P + 1` AND upgrades the window hypothesis
      `c <= n + 1` to the strict room `c' <= n` for whichever countdown is the LARGER.  The
      upgrade is `clipIdx_regime_of_eq`'s own disjunction with the gap branch killed by the
      regime hypothesis -- it is the gap coordinate paying for the room, not an assumption.

  (2) `window_anchor_compat_of_room` -- that room is EXACTLY what the anchor clause of the
      z-anchored lift (`exists_ladderPath_of_walk_nxt_at`'s `hn0`) needs at the region start
      below `z`, once the in-region duplication has raised that start's countdown by the
      displacement.  `hlow : n <= c + 2 * d` is the original path's own pin equation plus
      1-Lipschitzness, not a new hypothesis.

  (3) `window_pin_compat_raise_of_gap` / (4) `window_pin_compat_lower_of_spacing` -- the pin
      PAIR clause against lower region starts, in the two directions.  Raising is free
      (the compensating idle insertion grows the distance by the same amount).  Lowering is
      free given the region-start spacing `W + 1 + jP <= DW`, i.e. given that the idle run
      being shortened is at least as long as the displacement.

`jP` is an opaque natural in (2)-(4): the arithmetic is scale-invariant and never reads
`j * (P + 1)` as such.  What these do NOT measure is the path-level construction itself --
that is Phase 1's layer B.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderCell
import FormalSystem.Metalogic.Decidability.RaySummary.LadderIdle

namespace FormalSystem.Metalogic.Decidability.RaySummary

theorem kappa_collision_window_room (Tc Tn P B c n c' : ℕ) (hB : 2 ≤ B)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n))
    (hwin : ¬ (n + 2 ≤ c)) (hwin' : ¬ (n + 2 ≤ c')) :
    c = c' ∨ ∃ j : ℕ, 0 < j ∧
      ((c' = c + j * (P + 1) ∧ c' ≤ n) ∨ (c = c' + j * (P + 1) ∧ c ≤ n)) := by
  obtain ⟨-, hrc, -, -, hcl⟩ := kappa_eq_components Tc Tn P B c n c' n hk
  rcases lt_trichotomy c c' with hlt | heq | hgt
  · have hn : c' ≤ n := by
      rcases clipIdx_regime_of_eq B c c' n hB hlt hcl with h | h
      · exact h
      · omega
    obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' (le_of_lt hlt)).mp hrc
    rw [Nat.mul_comm] at hj
    exact Or.inr ⟨j, by
      rcases Nat.eq_zero_or_pos j with hz | hp
      · subst hz; omega
      · exact hp, Or.inl ⟨by omega, hn⟩⟩
  · exact Or.inl heq
  · have hn : c ≤ n := by
      rcases clipIdx_regime_of_eq B c' c n hB hgt hcl.symm with h | h
      · exact h
      · omega
    obtain ⟨j, hj⟩ := (Nat.modEq_iff_dvd' (le_of_lt hgt)).mp hrc.symm
    rw [Nat.mul_comm] at hj
    exact Or.inr ⟨j, by
      rcases Nat.eq_zero_or_pos j with hz | hp
      · subst hz; omega
      · exact hp, Or.inr ⟨by omega, hn⟩⟩

theorem window_anchor_compat_of_room (c n d jP : ℕ) (hroom : c + jP ≤ n)
    (hlow : n ≤ c + 2 * d) :
    (((c + d + jP : ℕ) : ℤ) - (n : ℤ)).natAbs ≤ d := by
  omega

theorem window_pin_compat_raise_of_gap (c d W jP DW : ℕ)
    (horig : (((c + d : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW) :
    (((c + d + jP : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW + jP := by
  omega

theorem window_pin_compat_lower_of_spacing (c d W jP DW : ℕ)
    (hsp : W + 1 + jP ≤ DW)
    (horig : ((c + d + jP : ℕ) : ℤ) - (W : ℤ) ≤ (DW : ℤ)) :
    (((c + d : ℕ) : ℤ) - (W : ℤ)).natAbs ≤ DW - jP := by
  omega

end FormalSystem.Metalogic.Decidability.RaySummary
