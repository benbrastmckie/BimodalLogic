# Phase 2 handoff — module docstring realigned

**Next action**: Phase 3 (add rows G and H to the same file). The full row text is staged at
`scratchpad/probe-phase3-full.lean`.

**What changed**: `Tests/BimodalTest/CrossWorldPropagationProbe.lean` module docstring only. The
"but neither does it positively refute — it exhausts its fuel / A wrong answer became no answer"
paragraph is replaced by an explicit three-step history (extractionFailed → fuelExhausted →
`.invalid` with a countermodel), the Phase-1-measured ceiling of 25 with its both-sided bracket,
attribution of the state-2→3 move to `Tableau.lean`'s `trivialEventWitnessed`, a pointer to the
`soundFuel'` record in `Fuel.lean`, and an explicit note that the branch reaches `.invalid` by
saturating (so the deleted temporal copy must not come back).

**Verification**: `lake env lean Tests/BimodalTest/CrossWorldPropagationProbe.lean` clean; diff
confined to the module `/-! … -/` block; no `#eval`/`#guard_msgs`/`info:` line added or removed;
`Phase 6 triage` string gone; no task-number reference introduced.

**Deviations**: none. **Second stale claim found**: none — the deletion narrative in the opening
sections is accurate and was left untouched, as the plan required.
