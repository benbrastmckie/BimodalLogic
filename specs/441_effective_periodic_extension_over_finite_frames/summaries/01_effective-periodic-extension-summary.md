# Implementation Summary: Effective Periodic Extension over Finite ℤ-Frames

- **Task**: 441 - effective_periodic_extension_over_finite_frames
- **Status**: [COMPLETED]
- **Started**: 2026-08-17T18:00:00Z
- **Completed**: 2026-08-17T23:30:00Z
- **Effort**: ~5 hours
- **Dependencies**: None blocking. Coordinated with task 417, whose `BiLasso/Basic.lean` freeze was honoured throughout.
- **Artifacts**: plans/01_effective-periodic-extension.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All ten plan phases are `[COMPLETED]`, sorry-free, with no new axiom and no vacuous definition.
The Extension Theorem is strengthened for the finite-`WorldState`, `D = ℤ` case from a Zorn-backed
existence result into an effective one at two independent tiers, and the agreement lemma that a
model checker would cite is delivered with the three limits on its use stated before it.

## What Changed

Six new files, ~1,600 lines. No pre-existing `.lean` file was modified.

- `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` — `PlacedBiLasso` (a bi-lasso plus an
  `origin : ℤ`), the decoding re-based at that origin, `isStepPath_shift`, and both periodicity
  lemmas restated at the offset.
- `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean` — choice-free, `#eval`-able
  `succOf` / `predOf` via `List.find?` over `List.finRange`, plus their orbits.
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` — a choice-free pigeonhole on `Fin`,
  the forward and backward rho decompositions, the window assembly discharging `coherent`, and
  **Tier A** `IntPresentation.extend_periodic` with its `PartialHistory`-on-an-interval wrapper.
- `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` — **Deliverable 3**:
  `PlacedBiLasso.extends_of_agrees` and `IntPresentation.extend_periodic_extends`, under a module
  docstring whose three limits precede every theorem.
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` — **Tier B**
  `TaskFrame.extend_periodic` over `{F : TaskFrame ℤ} [Finite F.WorldState]`, proved directly with
  no presentation, plus `extend_periodic_of_finite_domain` for the gapped case.
- `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` — thirteen `#guard_msgs`-gated
  `#print axioms` and `#eval` blocks making the ON CHOICE claims build-breaking rather than prose.

Edited: `scripts/module-invariants-manifest.txt` (six new unreachable modules, holding C6 at
baseline), `specs/paper-definitions-of-record.md` (an "Untracked sources" section),
`FormalSystem/Metalogic/Decidability/BiLasso/README.md` (four table rows and one section).

## Decisions

- **The certificate constructor takes the two orbit repeats as data.** `lassoOfWindow` receives
  the index pairs and their repeat proofs rather than extracting them from `orbit_repeat`'s
  `Prop`-level existential, which would have made it `noncomputable` and destroyed the point of
  the tier. The existentials are discharged once, in `extend_periodic`.
- **`coherent` is discharged through a named intended path** (`windowPath`) rather than by index
  arithmetic against the `Fin` window. The plan's per-segment adjacency lemmas and its three seams
  are exactly the five cases of `windowPath_step`; the two wrap-arounds live in
  `unrollOf_windowSegments`, which is where the repeat hypotheses are spent.
- **The optional Phase 9 was attempted and succeeded.** `exists_dup_lt` proves pigeonhole on `Fin`
  directly, choice-free, so `orbit_repeat` and `orbit_repeat_pred` are no longer classical. This
  does not change `extend_periodic`'s profile — as the plan predicted — but it removes finiteness
  from the list of reasons that result is classical.
- **The literature footnote is recorded as an untracked source, deliberately.** It carries no
  `\label`, and `check-paper-definitions.sh` resolves only `env` and `aitem` anchors, so a
  manifest row would be a dangling anchor. It is quoted verbatim in `Agreement.lean` and recorded
  in prose in `specs/paper-definitions-of-record.md`.

## Plan Deviations

- **Altered (flagged for review) — Phase 7, the revisit helper.** D-1's Tier B statement requires
  both periods `≤ Nat.card F.WorldState`, but the plan's named helper `exists_repeat_of_card_lt`
  takes `Nat.card W < n` and concludes `j ≤ a + n`, so its tightest instantiation yields a span of
  `Nat.card W + 1` — one more than the statement permits. The two plan clauses are not jointly
  satisfiable. Resolved in favour of the statement: `exists_repeat_of_card_le` is proved beside the
  theorem, routing through the same Mathlib pigeonhole and strictly strengthening the named helper.
  **This is the one deviation warranting review.**
- **Skipped — Phase 7's optional Tier-A-to-Tier-B corollary.** Not a corollary that needs writing:
  `Finite (Fin P.card)` is an instance, so `TaskFrame.extend_periodic` already applies verbatim at
  `P.toTaskFrame`. Recorded as unneeded rather than as undone.
- **Altered — Phase 3/4 ordering.** The backward mirror (Phase 4's first item) was written in the
  Phase 3 pass, since it is a line-for-line mirror of the forward half in the same file.
- **Altered — Phase 6 citation names.** The two box lemmas are `Truth.box_const` and
  `Truth.box_time_const`; the plan called them `TruthAt.*`. Cited under their real names.
- **Altered — Phase 5's "no Zorn" grep.** The literal
  `grep -c "exists_maximal_extension\|PartialHistory.extension"` returns 1 in `Orbit.lean` and 1 in
  the test module, both being prose inside the no-Zorn record itself. The structural check was run
  instead: the transitive import graph reaches `Semantics.PartialHistory` and does not reach
  `Semantics.Extension.Extension`.
- **Withdrawn mid-implementation.** An earlier Phase 7 note claimed importing
  `Metalogic/.../Periodicity.lean` into `Semantics/` would invert the layering. That is false —
  its namespace is `FormalSystem.Semantics` and its only local import is `Semantics.IntNormalForm`
  — and Phase 8 imports it. The claim is retracted in the plan file.

## Impacts

- `ModelChecker`-style consumers gain a certificate they can re-verify by `decide`: `coherent` is
  a `Fin` quantifier, and pointwise window agreement is a bounded `ℕ` quantifier.
- The ON CHOICE accounting is now machine-checked. Finiteness is no longer among the sources; the
  two that remain are `BiLasso.length_pos_int`'s numeric coercion and Mathlib's `List.getD`
  indexing lemmas.
- A silent hazard is documented for reuse: with the full library in scope, `==` at `Fin` resolves
  through a `LawfulBEq` route whose `beq_iff_eq` / `eq_of_beq` are choice-carrying. Comparing
  `Nat.beq` on `.val` avoids it.
- Nothing task 417 owns was touched. `Basic.lean` is byte-identical to HEAD, `Periodic.lean` was
  not created or modified, and no aggregator was edited.

## Follow-ups

- Register the six new modules in `FormalSystem/Metalogic/Decidability.lean` and
  `FormalSystem/Semantics.lean`, and delete their manifest lines, once the concurrent bi-lasso work
  has landed and the aggregator is safe to edit.
- Relax `exists_repeat_of_card_lt`'s hypothesis from `<` to `≤` in
  `Metalogic/Decidability/FMP/Periodicity.lean`, which would subsume `exists_repeat_of_card_le` and
  let it be deleted.
- A computable bounded-search gap filler, which is what a **gapped Tier A** certificate would
  need; the gapped case is currently frame-level only.
- Scrub `Classical.choice` from `BiLasso.length_pos_int` — requires unfreezing `Basic.lean`, so it
  cannot be done from this task. The `List.getD` source may be avoidable by restating the
  segment-readout lemmas in terms of `getElem` instead.
- Unify any arithmetic duplicated against the concurrent `Periodic.lean` once both have landed.
  Nothing was duplicated by this task, but the two `cyc` copies it inherits remain.

## References

- `specs/441_effective_periodic_extension_over_finite_frames/plans/01_effective-periodic-extension.md`
  — the plan, with per-phase notes recording every scope-hypothesis check and deviation
- `specs/441_effective_periodic_extension_over_finite_frames/reports/01_effective-periodic-extension.md`
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — directory-level orientation
