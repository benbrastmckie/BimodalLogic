/-
Probe: the LOWERING direction's anchor clause at the region start, as pure arithmetic.

Context. `window_anchor_clause_of_pin_classification` discharges the RAISING direction's anchor
clause at the region start from exactly two inputs:

  * `hroom : c + jP ≤ n`      -- the collision's own room (`kappa_collision_window_room`)
  * `hlow  : n ≤ c + 2 * d + 1` -- the path's own arithmetic (`nxtAt_le_cntAt_region_start`)

with `c = cntAt g z`, `n = nxtAt g z`, `d = (z - (a + 1)).toNat` the in-region depth. The
mirror clause for the LOWERING direction -- in-region block DELETED, so the region start's
countdown FALLS by `jP` -- is `((c + d - jP : ℕ) : ℤ) - n).natAbs ≤ d + 1`, whose binding half is

  * REQUIRED: `n + jP ≤ c + 2 * d + 1`.

What the lowering branch of the collision supplies instead is `c ≤ n` (the branch
`c = c' + j * (P + 1) ∧ c ≤ n`), together with `jP ≤ c` (the countdown must cover the deletion)
and the SAME path bound `n ≤ c + 2 * d + 1`.

Assertion A below: the required half is NOT implied by those three. Assertion B: the deficit is
exactly `jP` -- the path's own bound is tight, so adding `jP` to its right-hand side is precisely
what the clause asks for and precisely what nothing supplies.
-/

import FormalSystem.Metalogic.Decidability.RaySummary.LadderWindow

-- ASSERTION A: the lowering branch's room, the deletion bound, and the path's own bound do NOT
-- imply the lowering anchor clause's binding half.
theorem lowering_anchor_not_implied :
    ¬ ∀ c n d jP : ℕ, jP ≤ c → c ≤ n → n ≤ c + 2 * d + 1 → n + jP ≤ c + 2 * d + 1 := by
  intro h
  have := h 1 2 0 1 (by omega) (by omega) (by omega)
  omega

-- ASSERTION B: the deficit is exactly `jP`, and the clause becomes derivable the instant the
-- required bound is assumed -- i.e. what is missing is one named hypothesis, not a proof.
theorem lowering_anchor_of_required (c n d jP : ℕ) (hjP : jP ≤ c) (hroom : c ≤ n)
    (hreq : n + jP ≤ c + 2 * d + 1) :
    (((c + d - jP : ℕ) : ℤ) - (n : ℤ)).natAbs ≤ d + 1 := by
  omega

-- ASSERTION C: with the path bound tight (`n = c + 2 * d + 1`), the lowering anchor clause FAILS
-- for every positive displacement -- so the obstruction is not an artefact of a loose witness.
theorem lowering_anchor_fails_at_tight_bound :
    ¬ ∀ c d jP : ℕ, 0 < jP → jP ≤ c →
      (((c + d - jP : ℕ) : ℤ) - ((c + 2 * d + 1 : ℕ) : ℤ)).natAbs ≤ d + 1 := by
  intro h
  have := h 1 0 1 (by omega) (by omega)
  omega
