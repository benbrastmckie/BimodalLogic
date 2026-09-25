# Implementation Summary: Task #674

- **Task**: 674 - Document the countermodel-construction kit and the frame-level refutation criterion in `FormalSystem/Metalogic/Independence/README.md`
- **Status**: [COMPLETED]
- **Started**: 2026-09-25
- **Completed**: 2026-09-25
- **Effort**: ~1.5 hours
- **Dependencies**: Task 671 (remaining-rows sharpness work; already landed, README read as reconciled)
- **Artifacts**: plans/01_countermodel-kit-refutation-criterion.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Two new `##` sections were added to `FormalSystem/Metalogic/Independence/README.md`, inserted
between `## Key Results` and `## Dependencies`, recording two durable techniques worked out
during the `.ZTime` sharpness round: the countermodel-construction kit (the translation-frame
default route, the L⁻ fallback, two validating dead-end frames, three hard-won specifics) and
the criterion for when frame-level refutation is obstructed. The work is Markdown-only — no
`.lean` file was edited, no theorem added or restated, and no `lake build` was run.

## What Changed

- `FormalSystem/Metalogic/Independence/README.md` — added
  `## Building a countermodel: what to reach for first` (default route via `translationFrame` /
  `translationHist` / `translationModel` and the `translation_realizes` bridges; the four-step
  recipe with the `noMaxOrder_of_duration` opener and the `realOrder` ambiguity hazard; the L⁻
  fallback with the `tr_ne_untl` obstruction; the static-frame and clock-frame dead ends stated
  asymmetrically; non-discreteness vs. non-Archimedean-ness, shape pinning, and `by decide`
  failing on `FrameClass` `<`) and
  `## When frame-level refutation is obstructed, and when it is not` (the `CoNotPriorU.lean`
  obstruction, the criterion that it bites only on refute-while-validating claims, and the
  operational consequence of choosing `¬ F.ValidOn φ` before the proof starts). Both trailing
  `Last verified` stamps bumped to 2026-09-25.

No theorem was proved, and no `.lean` file was modified.

## Decisions

- **No `file.lean:NNN` citations**, against the dispatch's literal "name line numbers"
  instruction. Check C20 tier 2 of `scripts/check-module-invariants.sh` is gated by default and
  its `publication_scope` predicate covers every `README.md` under `FormalSystem/`; the scope is
  at zero violations and a single `Foo.lean:NNN` token would turn it red. Citations are
  declaration names, bare file names and slash paths, plus docstring section headings where a
  section is the target — which serves the dispatch's actual requirement (actionable without
  opening task artifacts) and is more durable than a line range.
- **The clock frame is stated as a dead end for `z1` only.** The dispatch asked for a symmetric
  "both frames validate both targets" warning; the research round machine-checked that
  `clockFrame` validates `Axiom.z1` but *refutes* `Axiom.prior_UZ` via `CoNotPriorU.lean`'s own
  `clockModel` arc valuation. The symmetric claim would have installed a false warning, so the
  section states the asymmetry and rules the clock frame out for `prior_UZ` on cost, not
  validity.
- **The `z1` clock-frame validity is stated as a mechanism, not a theorem name.** The probe that
  established it was never landed (landing it would be a `.lean` edit, outside scope), so the
  section cites `clockFrame_looping`, `truthAt_add_period`, `truthAt_add_nsmul` and
  `clock_allPast_imp_allFuture` and describes the periodicity mechanism rather than naming a
  theorem that does not exist.
- **The fallback route cites `FormalSystem/MinusLanguage/Soundness.lean`**, not the
  `Metalogic/Conservativity/MinusLanguageSoundness.lean` path the dispatch names, which does not
  exist. `minus_soundness_ztime_succ` is declared in the former.
- **The "strictly stronger" claim in Section 2 was rephrased** relative to the plan's wording.
  A bare `¬ F.ValidOn φ` is not stronger than a model-fixed refutation of the same formula; what
  is stronger is the frame-level form of the *paired* claim, in which the validated side is
  asserted of the frame rather than only of a chosen `TaskModel`. The section says that, so the
  criterion stays correct as stated.

## Plan Deviations

- **Phase 3** altered: the "strictly stronger than the model-fixed form" justification was
  rewritten as described under Decisions, because the plan's literal clause would have asserted
  the comparison in the wrong direction for a bare non-validity claim.
- Phases 3 and 4 were committed together (one commit), since Phase 4 produced no file change of
  its own beyond confirming the inventory regeneration was a no-op.

## Verification

- Build: N/A — no `.lean` file was edited, so no rebuild was required or run. `C1 lake build
  exits 0` and `C1 lake build BimodalTest exits 0` both passed inside the full invariants run
  against the already-built tree.
- Sorry count: 0 (`lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: 1 — `int_domain_universal` in `FormalSystem/Examples/TemporalStructures.lean`,
  pre-existing on the baseline, untouched by this task, and a genuine proof (`domain t` reduces
  to `True`) rather than a placeholder. Not introduced here.
- Axiom count: 14, unchanged from the pre-edit baseline; no `.lean` file was modified.
- Gates: `scripts/check-module-invariants.sh` — `ALL CHECKS PASSED` (exit 0), with
  `PASS C20 tier 2: zero file.lean:NNN citations in publication-facing scope`, `PASS C9`,
  `PASS C5`. `scripts/readme-lint.sh` — `RESULT: PASS`.
  `scripts/check-module-invariants.sh --emit-inventory` — "no generated inventory block needed a
  rewrite", confirming the dispatch's INV coupling warning was a non-risk (generated blocks count
  `.lean` files only).
- Tests: N/A
- Files verified: Yes — `git diff --name-only` lists only the README under `FormalSystem/`.

## Impacts

- The next agent doing a refutation in this directory lands on a written-down default route and
  two named dead ends instead of re-deriving both, and can choose its statement form
  (`¬ F.ValidOn φ` versus model-fixed) before starting a proof rather than discovering the
  distinction mid-proof.
- The `CoNotPriorU.lean` caveat is no longer readable as a blanket prohibition on frame-level
  refutation; the README now states the narrow condition under which it actually bites.

## Follow-ups

- Two live docstrings (`Metalogic/Conservativity.lean` and `Metalogic.lean`) still cite the
  non-existent `Metalogic/Conservativity/MinusLanguageSoundness.lean`. Repointing them at
  `FormalSystem/MinusLanguage/Soundness.lean` requires `.lean` edits and was out of scope here;
  worth a separate small task.
- The research round's two probes (`clock_validates_z1`, `clock_refutes_prior_UZ`) elaborated
  cleanly but were deliberately not landed. Landing `clock_validates_z1` would let the clock-frame
  dead-end paragraph cite a theorem name instead of a mechanism.
- The C20 tier-2 convention ("cite names, not lines, in publication-facing surfaces") is written
  down only inside `scripts/check-module-invariants.sh`'s C20 header. It is repository-independent
  enough to be worth promoting into the Lean extension's documentation-conventions context via
  `/meta`.
- The Section 2 criterion could be promoted to the formal extension's logic domain if a second
  modal-logic repository needs it; the dispatch explicitly deferred that.

## References

- Plan: `specs/674_document_countermodel_kit_and_refutation_criterion/plans/01_countermodel-kit-refutation-criterion.md`
- Report: `specs/674_document_countermodel_kit_and_refutation_criterion/reports/01_countermodel-kit-refutation-criterion.md`
- Deliverable: `FormalSystem/Metalogic/Independence/README.md`
- Gate sources: `scripts/check-module-invariants.sh`, `scripts/readme-lint.sh`
