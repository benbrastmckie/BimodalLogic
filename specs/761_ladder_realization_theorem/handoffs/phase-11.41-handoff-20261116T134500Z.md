# Phase 11.41 handoff — the residue-carrying relation: REFUTED (outcome (a))

**Status**: Phase 11.41 `[COMPLETED]` (plan v25, dispatch 74). 54 of 66 phase headings closed.

**Immediate next action**: `/revise` on `records/round-25-residue-relation-verdict.md`. Do NOT
dispatch Phase 11.42 (conditional on outcome (b), not reached) or Phase 11.40 (depends on 11.42).

**Current state**:
- `LadderStepFrag.lean` (1,273 lines, no `longFile` baseline) ends with section `Residue`:
  `Srel P a b := Zrel a b ∧ countdowns congruent mod P + 1`, `Srel.toZrel/refl/symm/mono`.
- The wired probe `ladder-row-link-residue-obstruction.lean` (568 lines) carries, appended,
  `no_rowLinked_path_of_Srel`: on the pending `3`-cycle object `R4`, at every `P` and every row
  budget `(a, b + 1)` with `1 ≤ a + b`, two `Srel`-related states with no row-linked pair of paths.
- Failing coordinate: the residue, at the INTERMEDIATE positions. `Zrel`'s countdown threshold has
  a margin of `2` per forward unit, independent of the object; a cycle of length `3` has three
  residues to answer. `C3` (length `2`) does not break.
- All gates green after the last source edit.

**Key decisions**: library name `Srel`; `R4` authored; the pair stated at every `P`; no third
relation designed.

**Deviations**: see the summary's Plan Deviations. Generated README inventory blocks and
`typst/generated/status.typ` regenerated.

**Open, routed to `/revise`**: whether a countdown threshold with an object-dependent margin
(at least a cycle length per jump) survives a refutation attempt — not proved, not probed.
