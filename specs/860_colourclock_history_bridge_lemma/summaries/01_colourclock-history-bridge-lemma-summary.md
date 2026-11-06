# Implementation Summary: Task #860

- **Task**: 860 - colourclock_history_bridge_lemma
- **Status**: [COMPLETED]
- **Started**: 2026-11-06T07:35:00Z
- **Completed**: 2026-11-06T08:30:00Z
- **Effort**: ~1 hour
- **Dependencies**: None
- **Artifacts**: plans/01_colourclock-history-bridge-lemma.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The "every colour function is a history" step at `colourFibre` is now compiled rather than
stated. `colourClock` gained the `@[simp]` task-relation bridge it was missing, a history
constructor from a colour function plus a clock offset, and the free-relation form in which the
coherence hypothesis is discharged outright; `OpenFutureUndefinable.lean` gained the intended
marker valuation, the enough-worlds condition `colourFibre_hmarkers` proved at that valuation,
and a fixed-model variant of the reduction theorem through which the condition is supplied by
application. The non-definability verdict itself is untouched: `hinexpr` remains the paper step
of record, and the new reduction at `colourFibre` is conditional on it alone.

Implementation also corrected a false claim both affected docstrings carried. Read literally,
`ofut_not_plusDefinable_of_deltaProp_inexpressible`'s `hmarkers` quantifies over *every* model of
the frame, and in that form it is false at every frame — a valuation sending `markerAtom` to
`False` everywhere admits no history carrying the marker future. What holds at `colourFibre` is
the condition at the intended valuation, which is why the fixed-model variant was added beside
the original rather than the original's hypothesis being discharged.

## What Changed

- `FormalSystem/Semantics/Frames/TranslationProduct.lean` — seven new declarations in
  `section Bare`: `@[simp, nolint simpNF] colourClock_taskRel` (the bridge, proved by a bare
  `FrameOver.ofReflectiveRegular_taskRel` term), `colourClock_zero_self`,
  `colourClock_clock_eq`, `colourClock.ofColourFun`, `@[simp] colourClock.ofColourFun_state`,
  `colourClock.ofFreeColourFun`, `@[simp] colourClock.ofFreeColourFun_state`, plus module
  docstring entries and a `/-! ### Histories of the colour clock -/` subsection.
- `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` — nine new declarations:
  `ofut_not_plusDefinable_of_deltaProp_inexpressible_at` (the fixed-model reduction variant,
  beside the original and in the same `{F : TaskFrame}` scope),
  `@[simp] markerAtom_ne_dataAtom`, `markerValuation`, `markerModel`, `cRel_free`,
  `colourFibre.ofColourFun`, `@[simp] colourFibre.ofColourFun_state`, `colourFibre_hmarkers`,
  `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible`; plus three docstring
  corrections and extended module `## Main Results`.
- `docs/theorem-index.md` — two ledger rows, for `colourFibre_hmarkers` and
  `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible`. Neither reads as an
  unconditional verdict; the second names `hinexpr` as its remaining unformalized hypothesis.
- `scripts/check-module-invariants.sh` — two `C14LEAN` `#print axioms` lines and two
  `C14_BASELINE` lines at the matching relative position (values measured, not transcribed),
  and the narrative comment extended, including a paragraph stating that `hmarkers` is now
  discharged at one frame and one valuation and nowhere else, and that `hinexpr` remains
  undischarged everywhere.
- `scripts/nolint-attribute-allowlist.txt` — one entry, `simpNF:colourClock_taskRel`.
- `FormalSystem/Semantics/Frames/README.md`, `FormalSystem/Metalogic/Independence/README.md`,
  `FormalSystem/Metalogic/README.md`, `README.md` — stale generated inventory line counts,
  regenerated with `check-module-invariants.sh --emit-inventory`.
- `typst/generated/status.typ` — regenerated Lean line count.

## Decisions

- `colourClock_taskRel` needed none of the plan's three mitigation rungs: a bare
  `FrameOver.ofReflectiveRegular_taskRel` term closed it, because the `Nonempty (W × ↑D)`
  instance baked into `colourClock`'s own `haveI` unifies with the lemma's instance-implicit
  argument, exactly as `FrameOver.translationProduct_taskRel` already relies on.
- `colourClock.ofFreeColourFun` discharges coherence by `by_cases h : t - s = 0`, the zero branch
  through `colourClock_zero_self` and `sub_eq_zero.mp`, the nonzero branch through freeness.
- `@[simp, nolint simpNF]` on `colourClock_taskRel`. Batteries' `simpNF` env_linter adds every
  Prop-valued non-instance hypothesis of the lemma under test to the simp set by design
  (`simp [*]`, so a conditional simp lemma can apply to itself). This lemma's `hR` is the
  reflection condition `R w d u ↔ R u (-d) w`, an unconditional rewrite loop once `neg_neg`
  closes the cycle, so the linter aborts with `maximum recursion depth` without ever reaching a
  normal-form verdict. The declaration cannot conform while `colourClock` takes its four
  presentation conditions as explicit arguments, and `isCondition` exempts only
  instance-implicit binders. The repository's documented permanent-exemption route was used
  rather than weakening the pinned `@[simp]` statement: the reason is written at the attribute
  site and the pair is on `scripts/nolint-attribute-allowlist.txt`, which C26 then verifies.
  **This is a new permanent repository exemption that the plan did not anticipate.**
- A third docstring was corrected beyond the two the plan named: the module docstring's
  "What is not proved here" `hmarkers` bullet carried the same unqualified claim.

## Plan Deviations

- **Phase 3**, `colourFibre_hmarkers`: altered — the hypothesis BINDER is `_hm`, not the pinned
  `hm`. Its type is exactly as pinned and the proposition proved is unchanged; the hypothesis is
  genuinely unused (a marker-future witness exists at every `(τ, t)` of this frame), and Lean's
  `unusedVariables` linter emitted a `warning:` on `hm` that the phase's own "no warning"
  criterion forbids.
- **Phase 4**, `check-module-invariants.sh exits 0`: altered — C2, C14, C20 and C26 pass and the
  baseline pair is extended, but the script exits 1 on a pre-existing out-of-scope C16
  `unusedArguments` finding on `LadderChain.lean:2136`, which is sibling task 889's own declared
  subject and territory.
- **Phase 4**, `verify-deploy.sh`: deferred — the dispatch directive for this cycle replaces the
  phase's full tier with a scoped tier and defers the complete gate set to the batch stage.
- **Phase 4** also absorbed two unplanned repairs: the `simpNF` exemption above, and four stale
  generated README inventory blocks.

Phase 4 is marked `[COMPLETED WITH EXCLUSIONS]` with a full `#### Reasoned Exclusions` record in
the plan.

## Verification

- Build: Success — full guarded `lake build`, exit 0, 2957 jobs, zero `error:`, zero `warning:`.
  Both touched modules' `.olean` files are newer than their sources.
- Sorry count: 0 (`lean-sorry-census.sh` across all resolved source roots;
  `grep -rn 'sorry'` on both touched files returns nothing).
- Vacuous count: 1 — pre-existing and unchanged (`int_domain_universal` in
  `FormalSystem/Examples/TemporalStructures.lean`, outside this task's files; 1 at the pre-task
  baseline `b60824a77`, 1 now).
- Axiom count: 14, unchanged from the pre-task baseline `b60824a77`; zero `^axiom ` lines in
  either touched file.
- Measured `#print axioms` (via `lean_verify`): `colourClock.ofFreeColourFun`,
  `colourFibre_hmarkers`, `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible`, and
  the untouched `ofut_not_plusDefinable_of_deltaProp_inexpressible` all
  `[propext, Classical.choice, Quot.sound]`. The two new `C14_BASELINE` lines carry these
  measured values.
- `scripts/check-module-invariants.sh`: C1 (`lake build` and `lake build BimodalTest`), C2 (all
  fifty pinned axiom sets), C3 (structural sorry inventory zero), C14 (both halves), C20 and C26
  (all 9 in-source `nolint` pairs allowlisted) pass. Exit status 1, held there solely by the
  pre-existing out-of-scope C16 finding above.
- `lake exe runLinter FormalSystem.Semantics.Frames.TranslationProduct`: passed.
- `scripts/typst-sync-check.sh --fix`: PASS (status.typ, module map, machine appendix in sync).
- Full gate set: DEFERRED to the batch stage per the dispatch directive, not independently run.
  No `verify-deploy.sh` gate and no `run-all.sh` suite covers any file this task touched.
- Tests: `lake build BimodalTest` green via C1.
- Files verified: Yes.

## Impacts

- `colourClock_taskRel` is the `@[simp]` bridge any downstream proof over a colour clock can now
  rely on; its rewrite surface reaches every importer, and the three Lean modules naming
  `colourClock`/`colourFibre` (`TranslationProduct.lean`, `OpenFutureUndefinable.lean`,
  `Independence.lean`) all build green.
- `colourClock.ofFreeColourFun` makes "every colour function with a clock offset is a history"
  available to any construction over a finite, free-away-from-zero colour relation, not only to
  the marker gadget.
- `ofut_not_plusDefinable_of_deltaProp_inexpressible_at` gives the reduction a form a concrete
  frame can discharge. The all-models original is untouched, still pinned by C14, and still
  cited in `docs/theorem-index.md`.
- Three docstrings and one `C14` narrative paragraph no longer assert the all-models
  `hmarkers` claim, which was false as written.

## Follow-ups

- `hinexpr` remains the unformalized paper step at every frame, `colourFibre` included. Neither
  new ledger row moves the verdict from conditional to unconditional.
- The pre-existing C16 `unusedArguments` finding on `LadderChain.lean:2136` keeps
  `check-module-invariants.sh` at exit 1; it is sibling task 889's subject.
- The `simpNF:colourClock_taskRel` allowlist entry is a permanent repository exemption worth a
  reviewer's eye, since the allowlist's admission bar is deliberately strict.
- No round-trip theorem at `colourClock` (the analogue of `liftH_projH`) was added; the plan
  declared it a non-goal and `colourClock_clock_eq` supplies the only half consumed here.

## References

- `specs/860_colourclock_history_bridge_lemma/plans/01_colourclock-history-bridge-lemma.md`
- `specs/860_colourclock_history_bridge_lemma/handoffs/phase-1-handoff-20261106T074635Z.md`
- `specs/860_colourclock_history_bridge_lemma/handoffs/phase-2-handoff-20261106T080129Z.md`
- `specs/860_colourclock_history_bridge_lemma/handoffs/phase-3-handoff-20261106T080706Z.md`
- `specs/860_colourclock_history_bridge_lemma/issues.jsonl`
