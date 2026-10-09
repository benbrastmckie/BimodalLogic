# Implementation Summary: Task #746

- **Task**: 746 - Requirement (S) of the ray-product verdict: Hit-level soundness — realize a presentation by a constructed regular ℤ-model (B2b)
- **Status**: [IN PROGRESS]
- **Started**: 2026-10-08T19:42:00Z
- **Completed**: (not complete — 1 of 8 phases)
- **Effort**: ~0.5 hour (Phase 1; plan budgeted 1 hour)
- **Dependencies**: None. (C) (task 745) is independent; (W) depends on this and on (C).
- **Artifacts**: plans/01_hit-level-soundness-b2b.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 1 of 8 only (single-phase dispatch, seq 13). It wires the research dispatch's
machine-checked frame-constructor findings into the tracked, rot-guarded evidence collection, so
that the plan's descoping of the carried 300-500 line "regular-frame constructor for finitely many
fibre shapes per time" prerequisite rests on a green compiled artifact rather than on a report
paragraph. No proof obligation was discharged and nothing under `FormalSystem/` was touched;
phases 2-8 (the `Cons` conditions, `BoxStabFree`, `modelOf`, `presented_modelOf`, the Hit-level
corollary and the acceptance statement) remain.

## What Changed

- `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean` — new wired
  evidence probe, 283 lines, 18 declarations carried verbatim from the research probe plus a
  91-line house header and a 27-line `#print axioms` foot. POSITIVE content:
  `fib_finite_of_finBranch` / `saturation_of_finBranch` replace
  `FormalSystem.Semantics.ofSlicedStep_fib_finite`'s `[Finite W]` by two-sided finite branching on
  the one-step relation with no carrier hypothesis, two-sided because `TaskFrame.Fib` at negative
  durations is the step relation's preimage and finiteness is not converse-stable;
  `shift_saturation` / `shift_slice_infinite` make it non-vacuous on the genuinely infinite slice
  `ℤ`. REFUTED content: `Rbad_fwd` / `Rbad_bwd_infinite` / `Rbad_fib_infinite` confirm the named
  reset-from-any-level hazard, and `Rok_bwd` / `Rok_fwd_infinite` refute the obvious repair —
  firing the reset only from level `0` merely swaps the failing side, so no reset placement
  rescues an unbounded nondeterministic deadline.
- `scripts/check-evidence-probes.sh` — the probe registered in `WIRED` (one entry appended at the
  end of the array) with its catalogue block in the house verdict-label / what-it-shows /
  what-it-does-not form. Append-only: 57 insertions, 0 deletions.
- `specs/746_hit_level_soundness_realize_presentation_b2b/plans/01_hit-level-soundness-b2b.md` —
  Phase 1 heading `[COMPLETED]`, its four checklist items checked, the stale probe-count
  prediction annotated as a deviation, and a measured Scope-Hypothesis outcome recorded.

## Decisions

- All 18 declarations were carried, including the three `def`s (`Rbad`, `Rok`, `Rshift`) and
  `Rshift_fwd`/`Rshift_bwd` that the plan's parenthetical 13-name list omits: "keeping every
  declaration" governs over the non-exhaustive list.
- The axiom foot was written fresh rather than copied — the source probe carried no
  `#print axioms` lines, despite the task text's assumption that it did.
- The header states the descoping claim literally ("the frame constructor is not a dependency of
  requirement (S)"), so the phase's criterion is met mechanically as well as in substance.
- The word `sorry` was kept out of the probe entirely; a first draft of the axiom-foot comment
  said `sorryAx`, which would have made `grep -c sorry` report 1.

## Plan Deviations

- **Scope Hypothesis** (Phase 1) altered: the predicted "14 pre-existing registered probes
  becoming 15" was stale — the gate script actually carried 21 `WIRED` plus 3 `WIRED_REPO`
  entries, so the count is 24 before and 25 after. The plan made that count the test for
  append-only editing; append-only was instead verified structurally from the diff (57 insertions,
  0 deletions, one `WIRED` entry at the end of the array).
- **Scope Hypothesis** (Phase 1) altered: line estimates were low in both files — 283 lines in the
  probe against 175-200 predicted, and 57 lines in the gate script against 12-18. The catalogue's
  comment column is 38 characters wide, so a house-format entry runs long; the two neighbouring
  entries are ~55 and ~60 lines, which is why 57 is in-house-norm and the estimate was the thing
  that was wrong.
- **Task 1** (Phase 1) altered: "keeping ... the `#print axioms` lines" could not be executed as
  written because the source has none; an axiom foot covering all 18 declarations was written, as
  the phase's own Verification criterion requires.

## Verification

- Build: N/A — no module under `FormalSystem/` was touched, so no `lake build` was run and none
  could regress. The probe lives outside the Lake target roots by construction and is compiled by
  the evidence gate via `lake env lean`.
- `bash scripts/check-evidence-probes.sh`: exit 0, `PASS  all 25 wired probe(s) compile`, with
  `seam-gluing-ray-product/b2b-frame-constructor-branching  PASS` and every pre-existing probe
  still PASS.
- Axiom profile: every theorem in the new probe reports exactly
  `[propext, Classical.choice, Quot.sound]` — including the two the phase names,
  `fib_finite_of_finBranch` and `saturation_of_finBranch`. The five `def`s report no axiom
  dependency.
- Sorry count: 0 (`grep -c sorry` on the new probe).
- Sorry inventory: None.
- Vacuous count: 0 — no `:= True`/`:= Unit`/`:= trivial` definition was written.
- Axiom count: unchanged — no `axiom` declaration exists in the new probe.
- Header-claim check: the probe contains the literal phrase "not a dependency of requirement (S)".
- Substrate claims in the header were re-resolved by name against the current tree, not by line:
  `ofSlicedStepRel_reflect`, `ofSlicedStep_compositional`, `ofSlicedStep_serial` and
  `ofSlicedStep_limit` carry no `[Finite W]`; `ofSlicedStep_fib_finite` bounds the fibre by
  `{p.1 + d} ×ˢ Set.univ` and never reads `R`; `TaskFrame.saturation_of_fib_finite` carries no
  carrier hypothesis; `[Finite W]` occurs across nine declarations of `SlicedFrame.lean`.

## Impacts

- The descoping of the carried frame-constructor prerequisite is now checkable: if the probe stops
  compiling, the evidence gate fails and the descoping claim is flagged for revisit.
- A successor record for the constructor inherits a proved fibre-finiteness/`Saturation` core plus
  two refutations that bound its design space — in particular, that a liveness-commitment encoding
  must finitize the deadline it commits to before two-sided finite branching is available.
- The evidence gate's covering count rises from 24 to 25 wired probes.

## Follow-ups

- Phases 2-8 of the plan remain; Phase 2 (`RaySummary/Realize.lean`, the `untl` half) and Phase 4
  (`PlusLanguage/Subformulas.lean`, `BoxStabFree`) are both unblocked and territory-disjoint.
- Phase 8 owes the successor-record description for the frame constructor itself, and the ROADMAP
  (S) paragraph rewrite that records the two refutations found here.
- No encoding is yet exhibited that defers an eventuality AND has two-sided finite branching; the
  refutations bound that design space without closing it. That question belongs to the successor.

## References

- `specs/746_hit_level_soundness_realize_presentation_b2b/plans/01_hit-level-soundness-b2b.md`
- `specs/746_hit_level_soundness_realize_presentation_b2b/reports/01_hit-level-soundness-b2b.md`
- `specs/746_hit_level_soundness_realize_presentation_b2b/evidence/01_fib-finite-generalization.lean`
- `specs/evidence/seam-gluing-ray-product/b2b-frame-constructor-branching.lean`
- `scripts/check-evidence-probes.sh`
