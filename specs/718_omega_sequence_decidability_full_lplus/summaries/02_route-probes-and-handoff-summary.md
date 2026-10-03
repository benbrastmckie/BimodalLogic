# Implementation Summary: Task #718

- **Task**: 718 - Find the correct methods, definitions and semantic basis for establishing
  decidability of full L⁺ with the stability operator in the language
- **Status**: [COMPLETED]
- **Started**: 2026-10-03T00:00:00Z
- **Completed**: 2026-10-03T05:30:00Z
- **Effort**: ~5 hours
- **Dependencies**: None (consumed 563/564/565/566/567/616/617/618 as read-only context; filed
  no work into them)
- **Artifacts**: plans/02_route-probes-and-handoff.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed all seven phases of the route-probes-and-handoff plan: promoted the keystone seam-
fibre-product probe into the CI-guarded `specs/evidence/` collection, wrote four new sorry-free
Lean probes testing R1's three falsification points and R2's amalgamation precondition,
corrected the one stale "open" claim in `FormalSystem/Metalogic/Decidability/FMP/README.md`
against the already-landed ℤ-time refutations, and wrote the follow-up scope specification
handing this round's findings to task 719 and to a new library-promotion task. All five
machine-checked probes landed **positive** outcomes — no route was refuted — and the
determinization-funding decision point closed with necessity demonstrated on the shared
fixture.

## What Changed

- `specs/evidence/seam-gluing-ray-product/stab-fibre-is-ray-product.lean` — promoted keystone
  probe (moved from the task directory; `git mv` plus header path correction)
- `specs/evidence/seam-gluing-ray-product/stab-depth-stratification.lean` — new probe (R1 probe
  1): `⊡`-depth stratification over the landed `atomize`/`plusTruthAt_iff_atomize` substrate.
  POSITIVE: licenses R1's automaton alphabet.
- `specs/evidence/seam-gluing-ray-product/finite-graph-stab-summary.lean` — new probe (R1 probe
  2): `⊡(Fp)` at a seam state is exactly "every forward root path meets `p`" on a total, finite
  fixture graph, proved via the bare `⊡` clause and `IntNormalForm.lean`'s step-path machinery
  (not the keystone's ray/ω-sequence `Equiv`s, since probes cannot import other probes).
  POSITIVE for the forward factor; backward dual recorded as a reasoned exclusion (symmetric
  fixture, no new machinery).
- `specs/evidence/seam-gluing-ray-product/mosaic-germ-amalgamation.lean` — new probe (R2 probe):
  mosaic germ amalgamation via the landed `PlusLanguage.paste`, choice-free, with uniqueness; the
  `⊡`-saturation question fixed as a `Prop` (`StabSaturated`) and proved only in the same-state
  corner.
- `specs/evidence/seam-gluing-ray-product/path-quantifier-alternation.lean` — new probe (R1 probe
  3): the existential summary is `True` everywhere the fixture's `⊡(Fp)` is `False` everywhere —
  necessity of a universal/complementation-shaped summary demonstrated.
- `scripts/check-evidence-probes.sh` — five new `WIRED` entries (the promoted keystone plus four
  new probes) and two new `WIRED_REPO` entries (the two FMP/width refutation theorems, deferred-
  move, named blockers)
- `FormalSystem/Metalogic/Decidability/FMP/README.md` — new subsection ("The finite-carrier
  route is refuted, not merely open") citing `Probe706.no_finite_carrier_sat` and
  `Probe710.not_finite_width_fmp` by declaration name, with stated ℤ/discrete-frame and
  `⊡`-free-witness limits; `*Last verified:*` re-stamped
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md` — new file: revised
  deliverables for task 719, a new-task specification for promoting the two refutations, the
  closed determinization-funding decision with Phase 5's evidence, and the two author-facing
  paper items verified but not actioned
- `specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md` —
  one-line promotion note in the Appendix (historical compile record left unchanged)
- `specs/718_omega_sequence_decidability_full_lplus/plans/02_route-probes-and-handoff.md` —
  phase status markers, checklist items, and the Phase 3 Reasoned Exclusions subsection

## Decisions

- Routed Phase 3 and Phase 5's probes through `PlusTruth.stab_iff` plus `IntNormalForm.lean`'s
  step-path machinery rather than the promoted keystone's `Probe718.plusStab_iff_omega`: probes
  in this collection import only `FormalSystem`, never another probe file (the collection's own
  convention, confirmed by grepping every existing wired probe's imports), so the keystone's
  bespoke ray/ω-sequence types are not importable here. This is an equivalent substitute route,
  not a re-derivation of the keystone's representation fact.
- Adapted Phase 4's "mosaic" definition to a total `WorldHistory` paired with a germ time rather
  than a bounded-interval `PartialHistory`, because the landed `PlusLanguage.paste` the phase
  must consume operates on total histories, not bounded intervals. Recorded as a deviation.
- Chose a concrete fixture (the complete/total graph on `Bool`) for Phases 3 and 5 rather than a
  fully generic finite-carrier theorem, matching the plan's "fix the fixture... state it once as
  a def" instruction and giving Phase 5 genuine branching to exhibit the existential/universal
  divergence on the same graph.
- Bypassed the `typst-sync-check.sh` pre-commit hook once (`--no-verify`), for a deletion-only
  commit completing a `git mv`, after diagnosing the drift as caused by sibling task 563's
  concurrently uncommitted new `.lean` files (file/line count mismatch), not by this commit —
  the hook's own documented exception for this exact scenario.

## Plan Deviations

- **Task 3.4** (backward dual for `⊡(Pp)`) skipped: the fixture's one-step relation is a constant
  total relation ignoring both its time and direction arguments, so the backward statement is
  the forward statement verbatim; proving it would exercise no new machinery. Recorded as a
  Reasoned Exclusion on Phase 3 (`[COMPLETED WITH EXCLUSIONS]`).
- **Task 4.2** (mosaic as a bounded-interval `PartialHistory`) altered to a total-`WorldHistory`-
  plus-germ-time mosaic, to match `PlusLanguage.paste`'s actual (total-history) signature rather
  than inventing an unlanded interval-pasting operator.

## Verification

- Build: N/A (no `FormalSystem/` source edited; the one README edit is prose, regression-checked
  by `lake build`'s separate green run during this session, caused by sibling activity, not this
  task's own phases)
- Tests: `bash scripts/check-evidence-probes.sh` reports `PASS` for all 14 wired probes (9
  pre-existing plus 5 from this round: 1 promoted, 4 new)
- Files verified: Yes — every new `.lean` file compiles sorry-free under `lake env lean`
  (`grep -rn sorry specs/evidence/seam-gluing-ray-product/` finds none); `readme-lint.sh` and
  `check-module-invariants.sh --no-build` show no finding attributable to this task's own edits;
  no new task-number citation outside `specs/**`

## Impacts

- The decidability programme's route ranking is reaffirmed, not changed: R1 first, R2 second
  (fallback), R3 folded into R1, R4 closed for ℤ-time (now recorded in the library), R5 unfunded.
- Task 719's filed scope is now informed by proved results for three of its five deliverables
  (ray layer answered, stab-fibre proved, gluing operator already landed as `paste`); Section 1
  of the follow-up spec recommends a `/revise 719` to carry this forward.
- The determinization-funding decision (`.decisions.json`) is discharged with evidence attached;
  reviving the blocked ω-automata substrate task (711) is now a filing decision for the
  orchestrator or the user, not a research question.

## Follow-ups

- `/revise 719` to carry Section 1's revised deliverables into the filed follow-up task.
- `/task` to file the new library-promotion task specified in Section 2 (move
  `Probe706.no_finite_carrier_sat` / `Probe710.not_finite_width_fmp` into `specs/evidence/`).
- A filing decision on reviving task 711 (ω-automata determinization substrate), informed by
  Phase 5's necessity evidence.
- The two author-facing paper items in Section 4 (FMP subsection, `app:gluing`-formalization
  sentence) and the `SU`→`US` re-pin in `docs/reference/paper-definitions-of-record.md` remain
  for the author/user to action; nothing inside the paper repository was written by this round.

## References

- `specs/718_omega_sequence_decidability_full_lplus/plans/02_route-probes-and-handoff.md`
- `specs/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md`
- `specs/718_omega_sequence_decidability_full_lplus/reports/01_gluing-route-seed.md`
- `specs/718_omega_sequence_decidability_full_lplus/followup-scope-spec.md`
- `specs/evidence/seam-gluing-ray-product/` (all five probe files)
- `scripts/check-evidence-probes.sh`
