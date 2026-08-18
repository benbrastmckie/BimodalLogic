# Phase 7 handoff — closed (dispatch 3)

- **Task**: 432, `specs/432_discharge_universeclosed_residual/`
- **Phase**: 7, "Clause (1), label dimension, per Phase 5's verdict" — was `[BLOCKED]`, now `[COMPLETED]`
- **Dispatch**: 3 (`sess_1787081671_9332d7`)
- **Baseline commit**: `88299bfb7`

## Immediate next action

None for this task. All nine phases are `[COMPLETED]` and the full `lake build` is green (2458
jobs). The task is ready for postflight.

## What closed the blocker

Task 434's `applyRule_emitted_time_dichotomy` (`MintBound.lean` section D1) supplied the missing
time-coordinate accounting the Phase 7 blocker specified, and 434 also lifted it to
`unorderedSuccessor_time_dichotomy`. Section C11 spends both.

## Current proof state

Section C11 of `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`, inserted
immediately before the C9 register:

- `unorderedSuccessor_world_dichotomy` — the world coordinate's engine-level lift (new here; only
  the `applyRule`-level `applyRule_emitted_world_dichotomy` existed)
- `FreshLabelHeadroom` + `freshWorldHeadroom_of_freshLabelHeadroom`
- `unorderedSuccessor_label_mem_of_headroom` — clause 1's label dimension, proved
- `unorderedSuccessor_confined_signedUniverse_of_freshLabelHeadroom` — clause 1 at
  `signedUniverse C L`, no residual
- `UnorderedSuccessorLabelClosedOrd`, `..._of_unorderedSuccessorLabelClosed`,
  `unorderedSuccessorLabelClosedOrd_of_headroom`, `unorderedSuccessorLabelClosedOrd_not_universal`
- `freshLabelHeadroom_not_universal`

All eight new theorems verified at axiom set `{propext, Classical.choice, Quot.sound}`.

## Key decisions

1. **The rectangle, not the world condition.** A label is a pair; the two per-coordinate dichotomies
   leave four quadrants and confinement of `b` covers none of them (it constrains the pairs `b`
   carries, not their cross product). `FreshWorldHeadroom` is one quadrant, so the blocker's
   phrasing "from `FreshWorldHeadroom`" was asking for something false. `FreshLabelHeadroom` is the
   correct hypothesis.
2. **The residual is not discharged, and that is the finding.**
   `freshLabelHeadroom_not_universal` refutes the reduced antecedent at every nonempty finite `L`.
   `UnorderedSuccessorLabelClosed` therefore stays on the terminus — now for a proved reason rather
   than a missing lemma. Phases 8 and 9 correctly keep it.
3. **`UnorderedSuccessorLabelClosedOrd` added beside the original rather than replacing it.** The
   original quantifies over an arbitrary `TimeOrdering` and is one hypothesis short of what the
   time dichotomy asks. Additivity constraint respected; the landed chain is untouched.

## Deviations

- Phase 7 branch (b) bullet 4: `altered` — delivered in two forms across two dispatches, and the
  headroom hypothesis strengthened from `FreshWorldHeadroom` to `FreshLabelHeadroom`. Annotated
  inline on the plan checklist item.

## Left for task 434

Section D1's heading note at `applyRule_emitted_time_mem` opens "Three docstrings in this file say
the same thing … there is no `applyRule_emitted_time_mem`". One of those three
(`UnorderedSuccessorLabelClosed`'s obligation map) was corrected here, so the count is now stale.
It sits in 434's territory and was deliberately not edited.
