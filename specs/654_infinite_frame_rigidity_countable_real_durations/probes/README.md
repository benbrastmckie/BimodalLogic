# Probes — infinite frame rigidity over countable carriers and real durations

Two probes, both compiled green against this tree with `lake env lean` (exit 0, no warnings,
no `sorry`), Lean v4.33.0-rc1 with Mathlib tag `v4.33.0-rc1`. They are scratch evidence for the
research report, not library modules; the planner sites any promoted module.

- `01_clock-frames.lean` — the clock witnesses. The rational clock and the real clock are
  `FormalSystem.Semantics.translationFrame` (`Semantics/Frames/Standard.lean`) at `ℚ` and `ℝ`;
  every field of the live `FrameOver` structure is exhibited by projection, both halves of
  *Compositionality* separately. Adds `paddedClock`, an uncountable non-static frame over *any*
  temporal order (a clock coordinate plus inert real ballast), which fills the uncountable row of
  the report's table at `ℤ`, `ℚ` and `ℚ ×ₗ ℚ`.
  Key results: `ratClock_not_static`, `realClock_not_static`, `paddedClock_not_static`,
  `paddedClock_uncountable`.
- `02_countable-real-rigidity.lean` — the headline. Section `Sierp` proves Sierpiński's theorem
  in the form "a map `ℝ → W` with `W` countable and all level sets closed is constant"
  (`Sierp.const_of_isClosed_levels`), which Mathlib does not carry. Section body spends it:
  `levels_closed` (*Limit*), `exists_history` (`thm:extension`), `constant_of_countable_range`,
  `static_of_countable` (**Q2**), `range_uncountable_of_nonconstant` and `exists_local_clock`
  (**Q3**).

Axioms, checked with `lean_verify` on `static_of_countable`, `Sierp.const_of_isClosed_levels`,
`levels_closed`, `exists_local_clock`, `ratClock_not_static` and `paddedClock_not_static`:
`[propext, Classical.choice, Quot.sound]` in every case, no `sorryAx`.

`02` uses `import Mathlib` for probe convenience. The narrowed import list for the `Sierp`
section was separately compiled green and is recorded in the report's promotion recommendation.
