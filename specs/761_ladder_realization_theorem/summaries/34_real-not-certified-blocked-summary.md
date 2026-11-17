# Implementation Summary: Task #761

- **Task**: 761 - Ladder realization theorem (READ-OFF / CONSTRUCTION pair)
- **Status**: [BLOCKED]
- **Started**: 2026-11-17T00:00:00Z
- **Completed**: 2026-11-17T01:30:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: Phases 12.1, 11.7, 12.5 (all closed)
- **Artifacts**: plans/34_readoff-construction-pair-restatement.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Phase 12.2 asked for three declarations — `real_certStabK`, `real_certAdmK_of_paramsOk` and
`real_subset_dmax` — all consuming the cell agreement on `kappa`-classes. None of the three is
landable: the agreement they consume is refuted, and the certificate condition they would assemble
is refuted ON `Real` itself at the gap clip `ParamsOk` admits. This dispatch landed the compiled
record of exactly which direction fails, in the library rather than in a probe appendix, and
closed the phase `[BLOCKED]` per its own Scope Hypothesis.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` — new
  `exists_paramsOk_real_not_certAdmK`: a finite object, a labelling, the formula `⊡ X ⊡ ¬ P ¬p`
  and the periodicity fixpoint's own four parameter outputs discharging `ParamsOk` at the `(K4)`
  clip `Bof` itself returns, at which `Real` fails `certStabK` (condition (5)) and hence
  `certAdmK`. Private witness `K4ClipWitness.real_not_certStabK` plus the membership helper
  `K4ClipWitness.mem_real_of_state`, both reusing the `K4ClipWitness` fixture already in the
  module. Module docstring corrected: the three unlanded declarations do NOT "wait on the
  agreement" — the route to them is closed.
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` — axiom-profile pin for
  `exists_paramsOk_real_not_certAdmK` plus a restriction check `example` forcing the `ParamsOk`
  conjunct and the `(K4)` clip to be read off the statement; `longFile` baseline raised to 3900.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `FormalSystem/Metalogic/README.md`,
  `README.md` — regenerated inventory blocks (`scripts/check-module-invariants.sh --emit-inventory`).
- `typst/generated/status.typ` — regenerated counts (`scripts/typst-status-counts.sh`).
- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` —
  Phase 12.2 `[NOT STARTED]` → `[BLOCKED]`, with a `**BLOCKER**` record and inline deviation
  annotations on its five checklist items.

## Decisions

- **The failing direction is `certStabK`'s `⟹` half.** The `⟸` half is landed unconditionally by
  `real_certStabK_mpr` and is not contradicted. The refutation is of the forward direction only,
  and the record says so rather than reporting "condition (5) fails" undifferentiated.
- **No conditional restatement under Phase 11.6's carried premise bundle was landed.** The bundle's
  regime premise `n + 2 ≤ c` HOLDS at the refuting pair `(Tc + 3, Tc)` against
  `(Tc + 3 + (P + 1), Tc)`, so it does not exclude the collision: a restatement under it would be
  vacuous rather than restrictive, which this plan's zero-debt gate forbids. The honest conditional
  already exists under its own name, `real_certStabK_of_cell_stab_transfer`, and was left untouched.
- **`Real ⊄ Dmax` is NOT claimed.** `Dmax` is a union over the certified subsets of the carrier, so
  a member of `Real` may lie in a certified set that does not contain all of `Real`. Only the
  `dmax_maximal` route to `Real ⊆ Dmax` is closed; the inclusion itself stays open and unclaimed.
- **The refutation was landed in the library, not left in a probe.** The equivalent probe-side
  object (`certStabK_fails_of_contains_realized`, `specs/evidence/seam-gluing-ray-product/
  ladder-cell-agreement-refutation.lean`) is quantified over any superset of the realized triples;
  the library declaration is at `Real` itself and at `certAdmK`, which is what the downstream
  phases actually read.

## Plan Deviations

- **Task 12.2.1** (`real_certStabK` from Phase 11.7's agreement) skipped: Phase 11.7 landed no
  agreement — it closed `[COMPLETED WITH EXCLUSIONS]` with its filed Goal refuted
  (`cellAt_const_of_kappa_eq_schema_refuted`, `repaired_clip_refuted`).
- **Task 12.2.2** (name the regime restriction) skipped: the regime premise does not exclude the
  refuting pair, so no honest restriction exists.
- **Task 12.2.3** (`real_certAdmK_of_paramsOk`) skipped: FALSE at its filed signature, by this
  dispatch's own `exists_paramsOk_real_not_certAdmK`.
- **Task 12.2.4** (`real_subset_dmax` by `dmax_maximal`) skipped: its route is closed with the
  assembly; the inclusion itself is left open.
- **Task 12.2.5** (do not state `Dmax ⊆ Real`) honoured: no such statement was written.

## Verification

- Build: Success — guarded full `lake build`, `GUARD_EXIT=0`, `Build completed successfully
  (2976 jobs)`, zero `error:` lines over both captured streams; both touched modules' `.olean`
  files are newer than their sources.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots, exit 0).
- Vacuous count: 1 — `FormalSystem/Examples/TemporalStructures.lean:495`, PRE-EXISTING and
  untouched by this dispatch (the diff adds no vacuous line); baseline unchanged.
- Axiom count: 14 `^axiom ` lines, unchanged — the diff adds none.
- `exists_paramsOk_real_not_certAdmK` axiom profile: `[propext, Classical.choice, Quot.sound]`;
  no `sorryAx`, no custom axiom, no `native_decide`.
- `bash scripts/check-module-invariants.sh` exits 0 with zero `FAIL` lines (the one initial
  `FAIL INV` for stale inventory blocks was resolved by `--emit-inventory`).
- Plan compliance spot-check: `skipped` — the plan's declared Goal Polarity is `mixed`, which the
  script's single global field cannot express.
- No theorem in `LadderRealize.lean` states `Dmax … ⊆ Real …` or any `Dmax … = Real …`; no union
  argument was added; `certAdmK … (Dmax …)` is claimed nowhere.
- Tests: Passed (`BimodalTest.Metalogic.KTypeSummaryAxiomTest` builds; its `#guard_msgs` pins and
  the new restriction `example` elaborate).
- Files verified: Yes.

## Carried-Figure Discipline

The dispatch's `## Description` lines were checked against live state rather than assumed:

- "`dmax_certStabK`/`dmax_certBoxK` have no hits" — CONFIRMED unchanged; neither name resolves to a
  declaration.
- "`ladderRealized` is declared nowhere" — CONFIRMED unchanged.
- "`certStabK_fails_of_contains_realized` shows the run-level soundness leg inherits the same
  defect (condition (5) fails on the realized set at the filed clip)" — CONFIRMED and now
  STRENGTHENED into the library at `Real` itself and at `certAdmK`.
- "`Dmax` is not even known to be certified" — CONFIRMED unchanged, and this dispatch adds that
  `Real` is now known NOT to be certified.
- Phase count "64 of 77" — the plan carries 77 `### Phase` headings; 64 were non-`[NOT STARTED]`
  at dispatch start. Unchanged by this dispatch, which closed its phase `[BLOCKED]` rather than
  `[COMPLETED]`.

## Impacts

- Phases 13 (`ladderSound`), 15.1 (`ladderLift`) and 20 (`ladderReadOff`) all read
  `real_subset_dmax` or the `Dmax`-fibre containment it would supply. Phase 20's READ-OFF half —
  the live statement adopted by decision 26 — is therefore gated: its right-hand side is the
  `Dmax` fibre, and the only route this plan named to reach it is now refuted.
- `real_certStabK_mpr` gains importance: it is the half of condition (5) that survives, landed
  unconditionally, and any repaired right-hand side should be stated so that it is still consumed.

## Follow-ups

- A `/revise` is owed. Two directions are open and neither is prejudged here: (a) a route to
  `Real ⊆ Dmax` that does not pass through certifying `Real` — each member covered by its own
  certified set rather than all of `Real` by one; or (b) a restatement of the READ-OFF half's
  right-hand side onto an object that `Real`'s non-certification does not kill.
- The object-dependent clip `B(Q, φ)` remains the one unrefuted parameter-side route and remains a
  named open question (Phase 22), untouched by this dispatch.

## References

- `specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md` — Phase 12.2
- `specs/evidence/seam-gluing-ray-product/ladder-cell-agreement-refutation.lean` —
  `certStabK_fails_of_contains_realized`, `cellAt_const_of_kappa_eq_schema_refuted`
- `specs/761_ladder_realization_theorem/reports/33_exponential-clip-cell-constancy.md`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean`
