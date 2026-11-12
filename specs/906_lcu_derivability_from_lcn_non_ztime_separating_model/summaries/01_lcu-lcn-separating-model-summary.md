# Implementation Summary: Task #906

- **Task**: 906 - Settle whether `lcU` is derivable from TM⁺ + `LC_n` at `.ZTime` via a non-`.ZTime`
  separating model
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T05:30:00Z
- **Completed**: 2026-11-12T07:10:00Z
- **Effort**: 5 hours
- **Dependencies**: None blocking. Territory-serialized against task 899 on
  `docs/theorem-index.md`, resolved clear in Phase 4.
- **Artifacts**: plans/01_lcu-lcn-separating-model.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal

## Overview

**Verdict**: the deliverable's second branch was reached and compiled, not the first. `lcU α β`
is **not** a theorem of TM⁺ + `LC_n` + mirror `LC_n` at `FrameClass.Base` with `RuleSet.none`,
witnessed by the translation frame over ℚ — a regular, deterministic frame on a densely ordered
carrier where every `LC_n` axiom (mirror included) is valid while `lcU` is refuted. The result
extends for free to `.Dense` and `.RTime` (`Sat` antitonicity); only `.ZTime` escapes, and the
`.ZTime` question stays **open and unclaimed**, not settleable by any model: `lcN_plusValidZTime`
and `lcU_plusValidZTime` are both already compiled, so TM⁺+`LC_n` and TM⁺+`IsLCUAxiom` have the
same `.ZTime` models by construction, and only a proof-theoretic argument could separate or
connect them there. No completeness claim is made anywhere.

The five phases that followed the research dispatch were custodial, not mathematical: moving the
load-bearing half of the argument (the determinism collapse and the deterministic-class
soundness arm) from an untracked probe into the Lake-built library, recording the verdict where a
reader of `PlusLCSchema.lean` and `LCExtension.lean` would find it, reducing the probe to what is
genuinely probe-shaped and bringing it under version control and CI, and running the complete
gate set this repository defines.

## What Changed

- `FormalSystem/PlusLanguage/PlusDeterminism.lean` — new `dstab_iff_of_deterministic` (the `⟐`
  sibling of `stab_iff_of_deterministic`), transcribed verbatim from the probe; measured axiom
  profile `[propext, Classical.choice, Quot.sound]` (the non-`[propext]`-only branch); the C4
  axiom-pin block and the module docstring's "stable import surface" sentence amended to scope
  the original four-name `[propext]`-only claim correctly and record the fifth name on its own
  line.
- `FormalSystem/PlusLanguage/PlusLCSchema.lean` — the non-derivability verdict recorded where the
  module previously said only that "nothing here says … that `lcU` … follows from `lcN`"; the
  `.ZTime` no-separating-model statement; a guarded-until-form candidate note (Recommendation 3:
  `⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U ⟐α))` survives this countermodel and remains an open
  `.Base` candidate on the same Zorn-plus-Extension-Theorem footing as `lcN`'s own validity).
  Every `.Base` **validity** sentence still carries "open and unclaimed"; every new
  **derivability** sentence names its frame class and `RuleSet.none`.
- `FormalSystem/Metalogic/LCExtension.lean` — four new declarations forming the deterministic-class
  soundness arm: `lcAnte_iff_lcCons_of_deterministic`, `lcN_plusValidOn_of_deterministic`,
  `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn` (this module's third soundness arm, beside
  `ext_sound_ztime` and `ext_sound_validIn`); one new import
  (`FormalSystem.Metalogic.Deterministic.Validity`); a completeness-target paragraph recording
  that `LCComplete`'s `lcU` instance is unreachable from `IsLCAxiom` by this route and needs a
  `.ZTime`-only principle. All four measured `[propext, Classical.choice, Quot.sound]`.
- `Tests/BimodalTest/Metalogic/LCExtensionTest.lean` — four new `#guard_msgs`-gated `#print axioms`
  blocks pinning the measured profiles above as build-breaking.
- `docs/theorem-index.md` — four new ledger rows for the `LCExtension.lean` declarations
  (fully qualified name, file, frame class, `pcq` axioms cell), inserted after the
  `LCURulesComplete` row with no existing row reworded or reordered.
- `specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` — reduced from 189 to 113
  lines (within the Scope Hypothesis's 110-130 estimate): Part I (the determinism collapse and the
  deterministic-class soundness arm) deleted in favour of the promoted library names; Part II (the
  ℚ witness model: `QOrd`, `Alt`, `Mq`, `Hq`, `detFq`, `pa`, `dstab_pa_iff`, `lcU_refuted`,
  `detSat_base_Fq`) plus the headline `lcU_not_extDerivable_base` kept unchanged in statement, now
  referring to the library declarations. Newly tracked by git (`git add`, explicit pathspec) — it
  was untracked on disk at authoring time.
- `scripts/check-evidence-probes.sh` — the new `WIRED` entry
  `"lcu-lcn-separation/lcu-lcn-separating-model"` plus its comment-table row.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/PlusLanguage/README.md`, `README.md` —
  regenerated module-inventory blocks (`--emit-inventory`); exactly the three files the Scope
  Hypothesis predicted, confirmed live rather than assumed. `FormalSystem/README.md` (the fourth
  candidate on the ancestor chain) was left unchanged by the generator, as the Scope Hypothesis
  anticipated as a possibility.
- `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/summaries/01_lcu-lcn-separating-model-summary.md` —
  this file.

## Decisions

- **Non-`[propext]`-only branch taken for `dstab_iff_of_deterministic`** (Phase 1): the measured
  profile is `[propext, Classical.choice, Quot.sound]`, not `[propext]` alone. The existing
  four-name `[propext]`-only claim in `PlusDeterminism.lean`'s C4 block was left unwidened; the
  fifth name's wider profile is recorded on its own line with the classical `¬∀¬ ↔ ∃` step named
  as the cost, and the "Why this is choice-free" section now opens with an explicit four-only
  scoping sentence.
- **Lake-build-guard scoping for the Batch Gate Deferral** (Phase 5): this dispatch is one of
  several `implement`-phase dispatches inside one multi-task `/orchestrate` batch, and the
  dispatch's Batch Gate Deferral directive constrains this plan's final (`Verification Tier:
  full`) phase. None of the six repository-specific gates this plan's Phase 5 names
  (`lake-build-guard.sh`, `check-module-invariants.sh`, `check-metalogic-cycles.sh`,
  `typst-sync-check.sh`, `check-evidence-probes.sh`, `check-module-invariants.sh
  --emit-inventory --check`) map to a `run-all.sh --only SUITE` or `verify-deploy.sh
  --only-gate N` narrowing — those two tools gate the `.claude/` agent-system deploy tree, a
  wholly different domain from this Lean formalization project — so every one of Phase 5's
  criteria is the directive's UNMAPPABLE CRITERION case: run the named check directly, scoped to
  touched files where the check itself supports scoping, else run it as named. Only
  `lake-build-guard.sh` supports file/module scoping; it was scoped to the three modules this
  task's phases touched across the whole plan (`FormalSystem.PlusLanguage.PlusDeterminism`,
  `FormalSystem.Metalogic.LCExtension`, `BimodalTest.Metalogic.LCExtensionTest`) rather than
  independently re-running the full-project build this batch will already run once at its own
  end. The other five gates carry no scoping flag at all (no `--only`, no per-file mode) and were
  run in full as named — nothing was waived. All six were green with zero pre-existing findings
  to enumerate; see Verification below.
- **No change to `scripts/c20-declaration-baseline.txt`**: C20's declaration-span assertion
  reported its pre-existing 10 recorded mismatches (unchanged count, confirmed pre-existing
  residue predating this task) and zero new findings caused by this task's docstring line shifts.

## Plan Deviations

- **Phase 1, docstring shape** (recorded in the Phase 1 progress file): the plan's own task
  description suggested a separate `Paper:` anchor line for `dstab_iff_of_deterministic`'s
  docstring; the module's actual neighbouring declarations cite the paper label inline with no
  separate `Paper:` line, so that live shape was matched instead. Statement and proof were
  transcribed verbatim; only the docstring's citation shape was adapted.
- No other deviations. Phase 4 was not territory-blocked: task 899's `docs/theorem-index.md` edit
  was already committed and that task's `state.json` entry read `completed` before Phase 4 began,
  so the phase was entered normally rather than closed `[BLOCKED]`.

## Verification

All six gates this repository's Phase 5 declares were run and observed directly in this
dispatch, none trusted on sight, with zero pre-existing findings to enumerate (every gate was
unconditionally green):

- `lake-build-guard.sh build` scoped to `FormalSystem.PlusLanguage.PlusDeterminism`,
  `FormalSystem.Metalogic.LCExtension`, `BimodalTest.Metalogic.LCExtensionTest` (the modules this
  task's phases touched; the full-project build is deferred to the batch-end stage per the Batch
  Gate Deferral): **green**, warning-free, 2150/2150 jobs.
- `scripts/check-module-invariants.sh` (full run, including C1's own full `lake build` +
  `lake build BimodalTest`): **ALL CHECKS PASSED**, zero `FAIL` lines across 624 lines of output.
  C2 ("all fifty pinned axiom sets match baseline") and C14 ("no stale axiom or sorry counts …
  every pinned declaration matches its axiom baseline") — the plan's named hard stops — both
  **PASS**.
- `scripts/check-metalogic-cycles.sh`: **PASS** on all three assertions, with the Phase 3 import
  (`FormalSystem.Metalogic.Deterministic.Validity`) in place. The one reported cycle
  (`BXCanonical <-> WeakCanonical`) is the script's own pre-existing allowlisted cycle, unrelated
  to this task.
- `scripts/typst-sync-check.sh` (full run, not `--counts-only`): **PASS**, all 4 checks green.
- `scripts/check-evidence-probes.sh`: **PASS**, all 56 wired probes compile, including the new
  `lcu-lcn-separation/lcu-lcn-separating-model` entry. No pre-existing probe newly red (one
  pre-existing, unrelated `SKIP`).
- `scripts/check-module-invariants.sh --emit-inventory --check`: **PASS**, no stale generated
  inventory block.

Additionally:
- `git ls-files specs/evidence/lcu-lcn-separation/lcu-lcn-separating-model.lean` returns the path.
- An exact-name grep over `FormalSystem/` confirms all five Goals identifiers
  (`dstab_iff_of_deterministic`, `lcAnte_iff_lcCons_of_deterministic`,
  `lcN_plusValidOn_of_deterministic`, `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn`) are
  declared exactly once, each at the plan's pinned signature.
- The reduced probe contains zero `sorry` occurrences and compiles clean via `lake env lean`.
- `.claude/scripts/verify-deploy.sh` was not run: it gates the agent-system deploy tree, and this
  task touches no file under the source store (not on this filesystem). Recorded as a decision,
  not an omission.

**Measured axiom profiles** (all `sorryAx`-free, no custom axiom, no `native_decide`):

| Declaration | Axioms |
|---|---|
| `dstab_iff_of_deterministic` | `[propext, Classical.choice, Quot.sound]` |
| `lcAnte_iff_lcCons_of_deterministic` | `[propext, Classical.choice, Quot.sound]` |
| `lcN_plusValidOn_of_deterministic` | `[propext, Classical.choice, Quot.sound]` |
| `isLCAxiom_plusValidDetIn_base` | `[propext, Classical.choice, Quot.sound]` |
| `ext_sound_detIn` | `[propext, Classical.choice, Quot.sound]` |

## Impacts

- A reader of `PlusLCSchema.lean` or `LCExtension.lean` now finds the settled `.Base`/`.Dense`/
  `.RTime` non-derivability verdict stated where the open-question docstrings used to be silent
  about it, with the frame class and `RuleSet.none` named every time.
- The determinism collapse (`dstab_iff_of_deterministic`) and the deterministic-class soundness
  arm (`lcAnte_iff_lcCons_of_deterministic`, `lcN_plusValidOn_of_deterministic`,
  `isLCAxiom_plusValidDetIn_base`, `ext_sound_detIn`) are now reusable library facts rather than
  locked inside a one-off probe — `ext_sound_detIn` in particular is a soundness arm
  `LCExtension.lean` previously lacked (beside `ext_sound_ztime` and `ext_sound_validIn`), and is
  independently useful for `Metalogic/Deterministic/`'s own completeness work.
- The probe is now tracked, wired into `check-evidence-probes.sh`, and will fail loudly in CI if
  it ever rots, rather than silently drifting outside version control as it was at the start of
  this task.

## Follow-ups

- **Recommendation 4's converse question** (not pursued here): does `IsLCUAxiom` derive `lcN`?
  Finding 8 established that the missing ingredient for `lcU` must fail over a non-Archimedean
  discrete order (`ℤ ×ₗ ℤ`, argued but not compiled); the converse direction may admit a
  separating model of its own, and no model-theoretic obstruction to looking has been established.
- **The `formal`-extension pattern file recommended by the research report is not sited here.**
  Its natural home is a new pattern file under the `formal` extension's own context, which is a
  source-store path (`rules/source-store-deploy-boundary.md`'s Task Siting subsection) not present
  on this filesystem; a task whose declared edit target is a source-store path must be created in
  the repository that holds that `source_dir`, not here.
- **Argued-but-not-compiled items, left standing as prose, not Lean**: Finding 8's discrete
  counterexample over `ℤ ×ₗ ℤ` (the same construction over a non-Archimedean discrete order,
  reproducing Findings 1-4), Finding 9's `.Dense`/`.RTime` extensions (one-line consequences of
  `Sat` antitonicity over ℝ, field-generic so the probe's proof text would be unchanged), and
  Recommendation 3's guarded until-form candidate (`⊡G≤(⟐α → ⟐(⟐β U ⟐α)) → ⟐G≤(⟐α → (⟐β U
  ⟐α))`, which survives this countermodel and remains an open `.Base` candidate). None of these
  needed compiling to settle this task's deliverable, and none is claimed as compiled anywhere in
  the library or this summary.
- No phase closed `[BLOCKED]` on territory. Phase 4's territory gate against task 899 resolved
  clear before that phase began.

## References

- Plan: `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/plans/01_lcu-lcn-separating-model.md`
- Report: `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/reports/01_lcu-lcn-separating-model.md`
- Progress files: `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/progress/phase-{1,2,3,4,5}-progress.json`
- Handoffs: `specs/906_lcu_derivability_from_lcn_non_ztime_separating_model/handoffs/`
