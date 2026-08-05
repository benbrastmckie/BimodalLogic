# Phase 10 handoff (plan 02)

- **Landed** in `Fuel.lean`, new section 4.3d(iv) before the 4.3e `worldFuel'` section:
  `TimeBounded` (the `hT` invariant), `incompPairs_card_le`, `splitOrderedRank`,
  `orderedRunBound`, `splitOrderedRank_le`, `splitOrderedRank_lt_of_timeLinearity`,
  `splitPathBound`, `splitAwareFuel`, `splitPathBound_le_splitAwareFuel`.
- **Required deliverable 1 (R3)**: the `NoSplit`-vs-`hT` distinction is written into the
  in-source section docstring, not only into the plan.
- **Required deliverable 2**: the "why a naive combination fails" record is in-source, naming
  both directions of the failure (`.split` mints fresh times and resets the ordering measure;
  `.splitOrdered` arm 3 shrinks the branch and hands back universe budget).
- **DIVERGENCE, sanctioned by the phase's own Scope Hypothesis**: the plan wrote the
  ordered-run bound as `Tmax + Tmax²`. The required derivation gives
  `orderedRunBound Tmax = Tmax*(Tmax*Tmax+1) + Tmax*Tmax` = `Tmax³ + Tmax² + Tmax`. The two
  components compose MULTIPLICATIVELY: component 2 is reset, not continued, on every drop of
  component 1, so each of the ≤ Tmax drops of component 1 admits a fresh run of ≤ Tmax² drops
  of component 2. The derived figure is what is used; `splitOrderedRank_le` is the
  machine-checked range statement. The divergence is recorded on `orderedRunBound`'s docstring.
- `soundFuel'` and `worldFuel'` are unmodified (`git diff` shows zero deletions in the file);
  the literal `3` is not baked into `splitAwareFuel`, which carries `β`.
- **Verification**: scoped `lake build` green; `sorry` count 0; purely additive.
- **Next action**: Phase 11 — `NoSplit`-free totality. See the phase-9 handoff's risk note.
