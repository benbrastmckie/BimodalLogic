# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem: the READ-OFF / CONSTRUCTION pair per ladder cell for all φ including box/stab letters
- **Status**: [IN PROGRESS]
- **Started**: 2026-11-17T01:15:00Z
- **Completed**: 2026-11-17T02:05:00Z
- **Effort**: ~50 minutes
- **Dependencies**: None open (decision 27 routes past the [BLOCKED] Phase 12.2)
- **Artifacts**: plans/34_readoff-construction-pair-restatement.md, records/round-34-readoff-construction-pair.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 21 — the CONSTRUCTION half of the adopted read-off/construction pair — was entered and
three of its four objects landed: the carrier, the frame and the valuation, together with the
FIRST conjunct of the pinned `ladderConstruct` statement, which is coverage. The fourth object,
the truth lemma, is open, and the phase is `[PARTIAL]` with its obstruction named and compiled
around rather than hidden. The round's principal finding is a compiled no-go that overturns the
phase's own orientation: the runs-based carrier the phase body expected cannot satisfy the pinned
cell equation at all, so the carrier is forced to be key-level.

**Which phase ran, and why it is not the one the dispatch named.** The Phase Mission named Phase
11.44, whose RE-ENTRY NOTICE is a rule rather than a number — execute the first open phase at or
after 11.48 in file order. Against the live plan that is Phase 12.2 `[BLOCKED]`, whose own
blocker states that what it needs is a route decision; decision 27 (cycle 2, 2026-11-17, the most
recent and the only unmarked entry in the dispatch's Prior Decisions block) IS that decision and
routes past it to Phase 21 by name. Recorded in the plan and in the record.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — APPENDED a new section,
  `## The CONSTRUCTION half's carrier, frame and model` (no landed declaration edited or
  re-proved; in-source `longFile` baseline raised 2300 → 2700 in place, module not split):
  - `ConKey` — the carrier: the KEYS `(q, κ)` realized in the certified set `R`, the closure-type
    coordinate projected away
  - `conKey_nonempty`, `conKeyMap` — inhabitation, and the key map the pinned statement asks for
  - `conStep`, `conStep_fwdFin`, `conStep_bwdFin`, `conStep_fwd`, `conStep_bwd` — the WEAK
    key-level step relation, two-sided finite branching, and **seriality discharged from
    `certAdmK`'s condition (2) alone** (no parameter condition, no object seriality hypothesis)
  - `conFrame`, `conModel` — the frame through `ofSlicedStepFinBranch`, and the valuation
  - `conKeyMap_covers` — **the pinned statement's first conjunct**
  - `sliced_step_detFwd`, `sliced_step_detBwd`, `cellAt_subsingleton_of_det`,
    `fibre_subsingleton_of_det_cell_eq` — the determinism no-go: a two-sided deterministic frame
    of this scheme has SUBSINGLETON cells, so the target cell equation at such a frame forces the
    fibre of `R` to be a singleton
  - `conStepStrong`, `conStep_of_strong` — the STRONG (uniform) candidate relation, and the fact
    that it refines the weak one
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — eleven `#print axioms` pins, all
  `[propext, Classical.choice, Quot.sound]`, plus one mechanical fidelity `example` instantiating
  `conKeyMap_covers` AT `(conFrame …).WorldState` (baseline raised 3900 → 4000 in place)
- `specs/761_ladder_realization_theorem/records/round-34-readoff-construction-pair.md` — §13-§20:
  which phase ran and why, the carrier statement with its slice count, the forced-key-level
  argument, the two candidate relations and the tension between them, the compiled inventory, the
  GKWZ Lemma 5.24 (⇐) clause map with the shape-transfer caveat, the width finding
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md` — the construction-direction paragraph, and regenerated inventory blocks
- `docs/theorem-index.md` — the construction direction recorded as a named open gap
- `typst/generated/status.typ` — regenerated counts

## Decisions

- **The carrier is key-level, not runs-based — and the departure rests on a theorem.** The phase
  body orients toward GKWZ's `W × R`. That does not survive the pinned equation: the cell at a
  world state is the set of types realized by the histories THROUGH it, and the equation demands
  the whole fibre, so a fibre with two types needs two histories through one state. The shift on
  runs is deterministic in both directions, and `cellAt_subsingleton_of_det` /
  `fibre_subsingleton_of_det_cell_eq` compile the consequence. In GKWZ the S5 dimension is a
  separate carrier coordinate (the cluster is a set of world states); here `⊡` ranges over
  histories through one state, so the published carrier cannot be transcribed.
- **The weak relation was taken for the landed frame**, because it is the one whose seriality
  `certBiInfK` supplies. The strong relation is landed as a definition beside it, with
  `conStep_of_strong`, so the next round attacks a stated object rather than designing one.
- **The construction is stated at an arbitrary `R` carrying `certAdmK`, never at `Dmax`**;
  `dmax_certStabK` and `dmax_certBoxK` still have no hits and attempting them is reported, not
  taken.

## Plan Deviations

- **Phase 21, task 3** altered: the frame, valuation and key map landed with `#print axioms` on
  each; the TRUTH LEMMA did not land and is the phase's open content. A second alteration,
  compiled rather than argued: the frame is built from the KEY-LEVEL projection of `relK` rather
  than from `relK` on the certified set itself, because a carrier whose points carry a closure
  type is refuted by `fibre_subsingleton_of_det_cell_eq`.
- No prohibited workaround was taken: no `frameOf`/`modelOf`/`presented_modelOf`, no statement at
  `Dmax`, no claim of isomorphism to `ladderModel`, no finite-fibre or finite-width ASSUMPTION,
  nothing under `ladderRealized` or `cellAt_const_of_kappa_eq`, no truth lemma weakened to the
  `BoxStabFree` fragment, and no `sorry`, `axiom`, `native_decide` or vacuous definition.

## Verification

- Build: Success — full `lake build` exit 0, 0 `error:` lines, `Build completed successfully
  (2976 jobs)`; `lake build BimodalTest` exit 0, 0 errors, 3044 jobs; both `.olean`s of the
  touched modules verified newer than their sources
- Sorry count: 0 (`lean-sorry-census.sh FormalSystem Tests`)
- Vacuous count: 0 attributable to this round (repository-wide grep count 1, unchanged, in
  `FormalSystem/Examples/TemporalStructures.lean`, untouched here)
- Axiom count: 0 attributable to this round (repository-wide `^axiom ` count 14, unchanged;
  both touched files carry 0)
- `scripts/check-module-invariants.sh` — ALL CHECKS PASSED
- `scripts/readme-lint.sh` — PASS
- `scripts/check-evidence-probes.sh` — PASS, probe total unchanged (no probe was edited)
- `grep -rnE '(theorem|lemma|def|abbrev) +(cellAt_const_of_kappa_eq|ladderRealized|ladderConstruct|ladderReadOff)\b' FormalSystem/ Tests/` returns nothing: all four pinned names stay unclaimed
- Axiom profiles: every landed declaration `[propext, Classical.choice, Quot.sound]`, pinned
- Tests: Passed (`BimodalTest` builds green, `#guard_msgs` pins included)
- Files verified: Yes

## Impacts

- The construction direction now exists in the tree in three of its four components, where
  `grep` at the plan's authoring found all four absent. The producer side of the task is no
  longer unwritten.
- The carrier question is settled by compilation rather than by orientation, which removes one
  degree of freedom from every future round of this phase: no round need re-propose a runs-based
  carrier.
- **The constructed model has FINITE width** — the slice `ConKey` is finite — so guardrail (b) is
  not met by this carrier. This is a property of the OUTPUT forced by the key-level carrier, not
  an assumption on an input, and it is recorded as a finding in the record (§19), the module
  docstring, the RaySummary README and `docs/theorem-index.md`. A model of this shape is not a
  candidate for a decidability consumer, and no record says it is.
- Phase 20's READ-OFF right-hand side can now be chosen with a constructed model in hand, which
  is the second half of decision 27's obligation.

## Follow-ups

- **Phase 21's truth lemma**, at the tension recorded in §16: the weak relation is serial but its
  paths need not lift into `R`; the strong relation lifts by choice but asks a seriality
  `certBiInfK` does not give. Both relations are now landed objects, so the next round attacks
  rather than designs.
- **Whether a carrier satisfying the pinned equation with INFINITE width exists** is open and is
  asserted nowhere. If guardrail (b) is to be met by half (ii), that is the question.
- `dmax_certStabK` / `dmax_certBoxK` remain open; instantiating the construction at `Dmax` waits
  on them.

## References

- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` — Phase 21
- `specs/761_ladder_realization_theorem/records/round-34-readoff-construction-pair.md` §13-§20
- `specs/761_ladder_realization_theorem/reports/31_gkwz-ptl-s5-quasimodels.md` — the sourced GKWZ
  §5.2 quotations the clause map is read against
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — the landed section
