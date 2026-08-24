# Phase 4 handoff — ceiling recorded, F(G p) witness diagnosed

**Next action**: Phase 5 gate (full `lake build`, scope and prohibition assertions).

**What changed**: `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`, two
docstrings, 50 insertions / 1 deletion, every line inside a `/-- … -/` block. No `def`, `theorem`,
or bound touched.

1. **`soundFuel'`'s docstring** gains a "Measured headroom — an empirical witness, not a second
   bound" paragraph: the both-sided bracket for `(G p) → □(G p)` (`none` for `n ≤ 24`, stationary
   40-formula certified branch for `n ≥ 25`), the exclusion of the `maxBranches` arm, and a table
   of the measured 25 against `soundFuel = 2048`, `soundFuel' = 1 048 576` and
   `worldFuel' … 1 = 1 099 512 676 352`. Worded so the 25 is unmistakably measured and the other
   three computed-from-definition — adjacent facts, explicitly not commensurable.
2. **The `resolveOpenArm = none` note** keeps every existing claim and adds why no fuel figure can
   rescue the `F(G p)` witness: the inner loop is stationary at 21 formulas for every fuel
   25…4096, `findUnexpanded` is `some _` at all of them, and the residue after `saturateBlocked`
   is `T(F ¬p) @ (0,4)` — an unfulfilled eventuality at a blocked time, which
   `trivialEventWitnessed` correctly does not suppress since it keys on `event == Formula.top`.

**Verification**: `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel`
completed successfully (1358 jobs); `grep -c sorry` = 0 before and after; the diff's single
removed line is a doc-comment line.

**Deviations**: none. Anchors were confirmed by content, not line number (both had drifted:
`soundFuel'` is at `:155`, the note at `:2255`).
