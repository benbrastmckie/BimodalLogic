# Implementation Summary: Task #641

- **Task**: 641 - Worked example walkthrough for outside readers
- **Status**: [COMPLETED]
- **Started**: 2026-09-20
- **Completed**: 2026-09-20
- **Effort**: ~2 hours (plan estimate 6.5 hours; research had pre-compiled every leg)
- **Dependencies**: None
- **Artifacts**: plans/01_worked-example-walkthrough.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Added `FormalSystem/Examples/Walkthrough.lean`, a single 383-line page that carries two concrete
formulas through all six legs of the metatheory: a `DerivationTree` built by hand and again by
`modal_search`, `soundness_validIn` out to validity, `completeness_base` back to derivability,
the tableau `isValid` verdict with its `isValid_sound`/`sound_of_isValid` bridge, one density
instance derivable at `Dense` and refuted at both `Base` and `ZTime` by a single concrete ℤ
countermodel, and a restatement of `notStrongCompletenessZTime` with a gloss on what the failure
means. Every declaration is named so the kernel's axiom audit can address it, and the audits are
**asserted** — not merely printed — in a companion test file. The README demo pointer now leads
here rather than to `BimodalProofs.lean`.

## What Changed

- `FormalSystem/Examples/Walkthrough.lean` — Created. 25 named declarations in namespace
  `FormalSystem.Examples.Walkthrough`: `pAtom`, `pF`, `tFml`, `tByHand`, `boxedT`, `tByAuto`,
  `tValid`, `tDerivable`, `tIsValid`, `tValidViaTableau`, `ggFml`, `ggAtDense`, `Dz`,
  `instSuccDz`, `instNoMaxDz`, `blipF`, `blipFrame`, `gapStep`, `blipFrame_isZTime`,
  `blipRefutes`, `notValidGg`, `notValidZTimeGg`, `ggNotBase`, `ggNotZTime`,
  `zTimeStrongCompletenessFails`. Docstringed throughout, with connective prose between legs.
- `Tests/BimodalTest/WalkthroughAxioms.lean` — Created. One `#guard_msgs in #print axioms` row
  per named declaration, 25 in all.
- `FormalSystem/Examples.lean` — Aggregator import plus two docstring list entries.
- `Tests/BimodalTest.lean` — Test aggregator import.
- `README.md` — `**Demo**:` link repointed to `Walkthrough.lean` with a clause naming the six
  legs; regenerated `INV` inventory block.
- `FormalSystem/README.md` — Regenerated `INV` inventory block.
- `FormalSystem/Examples/README.md` — Contents row, extended Purpose bullets with a "start here"
  paragraph, `Last verified` bumped.
- `docs/project-info/known-limitations.md` — the "contains exactly two files" sentence now says
  three, resolved framing intact.
- `docs/user-guide/examples.md` — Walkthrough added to the Lean-source list and named in the
  canonical-import prose as the recommended starting point.

## Decisions

- **`pAtom` added to the declaration inventory.** The plan named 24 identifiers; this is the
  25th. `permissive_realizes` consumes an `Atom`, not a `Formula`, so the countermodel needed
  the atom by name. Defining it once and setting `pF := Formula.atom pAtom` — definitionally the
  research probe's `Formula.atomS "p"` — let the modal leg and the density leg share a single
  atom `p`, which also let `blipRefutes` be stated with `pF` directly instead of the probe's
  `Formula.atom pAtom`, with no extra unfolding needed.
- **`isValid_sound` as the declaration body, `sound_of_isValid` named in its docstring.** The
  task description asked for `sound_of_isValid` to be visible; `isValid_sound` is literally
  `sound_of_isValid _ h` and is the verified shape, so the wrapper is used and the docstring
  points at where the work happens.
- **`by decide` for the tableau verdict, with an in-file prohibition comment against
  `native_decide`** — the comment spells out that `native_decide` would inject
  `Lean.ofReduceBool` and break the axiom contract, so a later editor does not "optimize" it.
- **The axiom audit is asserted in `Tests/`, not printed in library code.** This keeps
  `Walkthrough.lean` free of debug directives (no `scripts/debug-artifact-allowlist.txt` entry
  needed) and turns a drift into a build failure. Verified adversarially: replacing one expected
  axiom set with `[propext, Lean.ofReduceBool]` fails the build with a diff, so the rows bite.

## Plan Deviations

- **Phase 1** altered: `pAtom` added to the declaration inventory (see Decisions above). The
  plan's Phase 4 Scope Hypothesis explicitly anticipated additions of this kind.
- **Phase 6** altered: the Scope Hypothesis sweep for further `BimodalProofs.lean` pointers
  found three sites outside the plan's file list. All three were recorded and deliberately left
  unedited — `docs/development/MODULE_ORGANIZATION.md:477` sits in an `Examples/` list already
  stale in ways predating this task (it names `ModalProofs.lean` and `TemporalProofs.lean`,
  neither of which exists), `docs/project-info/implementation-status.md:151` is a per-file
  status table rather than a demo pointer, and `typst/chapters/p4-dual-verification.typ`
  describes `BimodalProofs.lean`'s own content accurately rather than advertising it as the
  demo. None is a stale demo pointer; editing them would have been unreviewed scope.

Both Scope Hypotheses the plan attached to Phases 3 and 4 were confirmed rather than revised:
`by decide` on `isValid tFml = true` costs no measurable elaboration time (the module build
stayed at ~1.3 s against the plan's ~10 s abort threshold, so no formula shrink was needed), and
the countermodel needed exactly the plan's fourteen declarations with `blipRefutes` at the
predicted ~16 lines.

## Verification

- Build: Success — full `lake build` exit 0 (2667 jobs), `lake build BimodalTest` exit 0
  (2727 jobs), both detached through the build guard.
- Sorry count: 0 (the single `grep 'sorry'` hit in `Walkthrough.lean` is the prose word
  "sorry-free" in a docstring; a `\bsorry\b` token grep returns nothing)
- Vacuous count: 0
- Axiom count: 0 new axioms declared in either new file
- Harness: `bash scripts/check-module-invariants.sh` exit 0 — 42 checks passed, including C9
  (no task numbers), C14 (no stale literals), C16 (docstring coverage), C24, C26 (camelCase
  `def`/`abbrev`), C27 (no live debug directive in library code), C28 (0 warnings across 0
  files, baseline held), C9D (no task numbers under `docs/`)
- Inventory: `--emit-inventory` regenerated `README.md` and `FormalSystem/README.md`;
  `--emit-inventory --check` exit 0, so a second rewrite would change nothing
- `bash scripts/readme-lint.sh` exit 0 (RESULT: PASS)
- Axiom audit: all 25 declarations at `[propext]`, `[propext, Quot.sound]`,
  `[propext, Classical.choice, Quot.sound]`, or no axioms at all. Nothing outside the contract,
  and in particular no `Lean.ofReduceBool` anywhere.
- No `Kamp` or `WeakCanonical` citation in the new file, so the ADR-011 Expressiveness rename
  cannot reach it.
- Plan compliance: all 24 plan-named identifiers present, plus `pAtom`. Signature fidelity
  against the plan's `## Lean Challenge Statements` holds — `⊢ φ` is notation for
  `DerivationTree FrameClass.Base [] φ` and `⊨ φ` for `Valid φ`, and `isValid tFml = true` is
  the plan's `isValid tFml FrameClass.Base = true` written with `isValid`'s own
  `(fc : FrameClass := .Base)` default. Nothing was weakened.
- Files verified: Yes

## Impacts

- A reader arriving at the root README is now sent to a page that exercises the metatheory
  rather than to 247 lines of one-line perpetuity applications. `BimodalProofs.lean` is
  untouched and still linked, reclassified from demo to proof-system exercise.
- `Tests/BimodalTest/WalkthroughAxioms.lean` extends the repository's pinned-axiom discipline to
  the example layer: the walkthrough's axiom claims are now load-bearing build artifacts.
- The follow-on Examples expansion has a file to extend that already reaches soundness,
  completeness, the decision procedure and the frame hierarchy, rather than a perpetuity list.

## Follow-ups

- `docs/development/MODULE_ORGANIZATION.md`'s `Examples/` list is stale independently of this
  work (it names two files that do not exist and omits both that do). Worth a separate pass.
- The research report recommended adding a `context/project/lean4/operations/adding-a-module.md`
  checklist covering the obligations a new `FormalSystem/` file incurs — inventory regeneration,
  the C27 allowlist, camelCase `def`s with docstrings, the sibling README row and its
  `Last verified` bump. Every one of those was hit in Phase 6 and each is individually easy to
  miss. Still unwritten.

## References

- `specs/641_worked_example_walkthrough_for_outside_readers/plans/01_worked-example-walkthrough.md`
- `specs/641_worked_example_walkthrough_for_outside_readers/reports/01_worked-example-walkthrough.md`
- `specs/641_worked_example_walkthrough_for_outside_readers/handoffs/` — per-phase handoffs
- `FormalSystem/MainResults.lean` — the page whose axiom-audit contract this file mirrors
