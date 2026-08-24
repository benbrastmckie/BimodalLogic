# Phase 3 handoff — rows G and H added

**Next action**: Phase 4's Fuel.lean edits are already applied and its module builds; close
Phase 4, then run the Phase 5 gate.

**What changed**: `Tests/BimodalTest/CrossWorldPropagationProbe.lean`, pure addition of 46 lines:
- Row G — constructor tuple + `getCountermodel?.isSome` for row A's `(¬F p) → □(¬F p)`.
- Row H — the same for row C's `(¬P p) → □(¬P p)`.
- One module-docstring paragraph introducing them.

Both pin `((false, true, false, false, false), true)`, the Phase-1-measured value. Each new row's
`#eval` pins the countermodel flag alongside the tuple (the plan's optional strengthening), so no
claim in either docstring is asserted without being pinned.

**Verification**: `lake env lean` on the file is clean with all eight rows green; `git diff` shows
**zero** removed lines, so rows A-F are byte-identical to their pre-phase state.

**Deviations**: none.
