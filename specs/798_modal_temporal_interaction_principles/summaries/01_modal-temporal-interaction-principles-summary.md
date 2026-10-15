# Implementation Summary: Task #798

- **Task**: 798 - Port the eleven unported modal-temporal interaction principles Pthm:11 -- Pthm:22 from the paper's companion cut file, together with the duality lemma P8 that two of their proofs consume
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T17:11:30Z
- **Completed**: 2026-10-15T17:52:00Z
- **Effort**: ~40 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_modal-temporal-interaction-principles.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All four phases completed. One new module, `FormalSystem/Theorems/Interaction.lean`, now holds
sixteen proof-term `def`s: the duality P8 in both directions, two auxiliary derivations the
principles consume, the eleven unported interaction principles, and Pthm:20's forward half as its
own declaration. The twelfth item of the source block, Pthm:17, is not restated — it already
exists as `perpetuity4`, whose docstring now carries the cross-reference. The module is reachable
from both aggregators, every generated inventory surface is current, and the whole project builds
green with zero sorry and no new axiom.

## What Changed

- `FormalSystem/Theorems/Interaction.lean` — new module, 356 lines, sixteen `noncomputable def`s,
  every one docstringed with its source label and derivation route:
  - P8: `notSometimesToAlwaysNeg` (`⊢ ¬▽φ → △¬φ`), `alwaysNegToNotSometimes` (`⊢ △¬φ → ¬▽φ`)
  - helpers: `temporalPastDerived` (`⊢ □φ → H□φ`, the general TR mirror of TF),
    `boxToAlwaysBox` (`⊢ □φ → △□φ`, Pthm:14's reverse half factored out)
  - the eleven principles: `sometimesDiamondToDiamond` (Pthm:11),
    `alwaysDiamondToDiamond` (Pthm:12), `sometimesBoxIffBox` (Pthm:13),
    `alwaysBoxIffBox` (Pthm:14), `boxAlwaysIffAlwaysBox` (Pthm:15),
    `boxAlwaysIffBox` (Pthm:18), `diamondAlwaysToDiamond` (Pthm:19),
    `diamondIffDiamondSometimes` (Pthm:20), `sometimesDiamondToDiamondSometimes` (Pthm:21),
    `diamondSometimesToSometimesDiamond` (Pthm:22),
    `diamondSometimesIffSometimesDiamond` (Pthm:16)
  - plus `diamondToDiamondSometimes`, Pthm:20's forward half, named because Pthm:21 consumes it
- `FormalSystem.lean` — one sorted import line (exactly one line added, none removed)
- `FormalSystem/Theorems.lean` — one import line, one `## Submodules` bullet, a
  `### Modal-Temporal Interaction` entry under `## Status`
- `FormalSystem/Theorems/Perpetuity/Principles.lean` — `perpetuity4`'s docstring gains the
  Pthm:17 / Pthm:20 cross-reference. A pure insertion: zero removed lines, no term, signature,
  attribute or import change
- `FormalSystem/Theorems/README.md` — regenerated per-file inventory row plus one hand-written
  description cell, and one `## Key Categories` bullet outside every generated block
- `FormalSystem/README.md`, `README.md` — regenerated totals rows
- `typst/generated/status.typ` — regenerated file and line counts

## Decisions

- **The block's internal dependency chain was honoured, not re-proved from the axioms.** Pthm:21
  composes Pthm:11 with Pthm:20's forward half; Pthm:22 goes through P5; Pthm:20 pairs its
  forward half with `perpetuity4`; Pthm:16 takes the source's own route through P8, Pthm:15 at
  the negation and the P7 pair at the boxed negation.
- **Pthm:18 by the source's direct derivation**, not the 15+14 composition the task description
  names. The 15+14 attribution is the block's header redundancy note, not its proof; it is
  recorded in the docstring instead, together with the observation that the reverse half is
  extensionally `perpetuity3`.
- **Pthm:16 by the source's route, not the cheaper `iffIntro` of Pthm:22 and Pthm:21.** Both
  compile; the source's route is the only consumer of Pthm:15 and of the existing P7 pair in the
  whole block, so the shortcut would leave Pthm:15 consumed by nothing. The alternative is named
  in the docstring and not used.
- **P8 sited in the new module, not beside the P7 pair.** The user approved this departure from
  the task instruction: under this tree's `sometimes` encoding P8 is definitionally double
  negation (so P7's proof shape does not apply), and `MonotonicityDuality.lean`'s long
  `noncomputable section` would make a computable lemma noncomputable. Its docstrings cite the P7
  pair as the contrast and `fNegG` / `pNegH` as the precedent.
- **No rewrite-lemma claim for the five collapsing biconditionals.** The task description asks
  whether the normal-form and decidability modules can consume them. They cannot: each is a
  derivability fact `⊢[fc] iff A B`, not a `Formula` identity, and
  `Automation/Normalization.lean`'s `@[formula_unfold]` / `@[formula_fold]` sets hold only
  `rfl`-level identities. The docstrings state the honest precedent relation to
  `ModalS5.s5DiamondBox` and `ModalS4.s4DiamondBoxDiamond` and claim no consumer.
- **Nothing tagged `@[tmLemma]`**, including the two helpers, following the untagged P1--P6
  precedent. Tagging enlarges the label set `Automation/Tactics/Search.lean` collects, which is
  an automation behaviour change with no test coverage inside this task's scope.
- **Both aggregator lines landed in Phase 1**, against the research report's "isolate the import
  edit in a terminal phase" mitigation, because C33 requires `FormalSystem.lean` to be
  byte-identical to `mk_all` output and deferring the line would leave every intermediate commit
  C33-red.

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: Success. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (whole project, detached through the guard): guard exit 0, `Build completed successfully (2857
  jobs)`, zero `error:` across both captured streams, and `Interaction.olean` newer than its
  source. Scoped guard builds were green at each earlier phase boundary.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved source roots:
  `sorry_count: 0`, empty inventory; C3's structural sorry inventory likewise ZERO)
- Vacuous count: 0 for every file this task touched. One tree-wide match exists —
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal ... := trivial` — which
  is present verbatim before this task's first commit, is a genuine proof rather than a
  placeholder, and lies outside this task's scope.
- Axiom count: unchanged, 14 before and 14 after; zero `axiom` declarations in the new module.
  `lean_verify` on `boxToAlwaysBox`, `diamondSometimesIffSometimesDiamond`,
  `sometimesDiamondToDiamondSometimes` and `boxAlwaysIffBox`: standard trust, no non-standard
  axiom, no sorry.
- `bash scripts/check-module-invariants.sh` (full, with build): exit 0, `ALL CHECKS PASSED`, zero
  `FAIL` lines
- `bash scripts/check-module-invariants.sh --emit-inventory --check`: exit 0, `PASS INV every
  generated inventory block is current`
- `lake exe checkInitImports` (C24): exit 0. C33 PASS (`FormalSystem.lean` byte-for-byte the
  generated root, 691 import lines); C6 PASS with zero unreachable live modules, so
  `Interaction.lean` is not in that census
- `bash scripts/typst-sync-check.sh`: exit 0 (all 4 checks green)
- `bash scripts/readme-lint.sh`: exit 0, 0 broken file references
- `bash scripts/check-phantom-citations.sh`: exit 0
- `python3 scripts/export-lean-citations.py --check`: exit 0, 86 seeded names resolved
- `bash scripts/check-paper-definitions.sh`: exit 1 on **pre-existing drift this task neither
  caused nor can fix**. All ten drifted anchors (`CO`, `def:BX`, `def:BX-z` and seven others) are
  differences between the record and the live paper working tree at
  `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`, a file outside this
  repository. This task changed zero `.tex` files, zero `sha256` lines, and
  `docs/reference/paper-definitions-of-record.md` not at all — both of the check's inputs are
  byte-identical to their pre-task state, so its verdict is unchanged by this work.
- Plan compliance spot-check: passed. All sixteen declarations named in the plan's Goals resolve
  under the resolved source roots; no replacement targets are declared, so the integrity arm is
  vacuous.
- No line over 100 characters in any touched file; no `@[tmLemma]`, no `set_option`, no
  `warning-budget.txt` entry, no `file.lean:NNN` citation, no task number in any deliverable
- Tests: N/A — no `Tests/BimodalTest/` axiom pin was added for the new declarations, which the
  plan placed out of scope
- Files verified: Yes

### Verification tier and batch deferral

Phase 4 declares `**Verification Tier**: full`. This dispatch is one `implement`-phase dispatch
inside a multi-task `/orchestrate` batch, so per its dispatch directive the phase was discharged
against a **scoped** tier and **the complete gate set was deferred to the batch stage rather than
independently run here**. Every Lean-tree and generated-surface gate the plan names was run in
full and is recorded above; the narrowing applies only to the repository gate aggregator:

- `bash .claude/scripts/verify-deploy.sh --only-gate 4,10` returned exit 2 (`cannot attest: every
  gate selected skipped or was deferred -- 0 check(s) ran`): both gates are source-store-only and
  this repository is a deploy consumer with no `agent-system/extensions/` directory. That exit is
  reported as a failure to attest, never as a pass.
- `scripts/lib/suite-selection-lib.sh` resolves this phase's `.lean` paths to
  `__FULL_SWEEP__` — the library itself states no narrowing covers them, which is precisely why
  the full set belongs at the batch stage. The union of its mappable resolutions was run:
  `bash .claude/scripts/tests/run-all.sh --only test-check-record-versioning.sh,…` over eleven
  suites, exit 0, **10 passed, 0 failed, 1 skipped**.
- A selected-subset pass is not evidence that the full gate set holds. The un-narrowed
  `verify-deploy.sh` run the plan's Phase 4 verification asks for runs once for the whole batch at
  the end of this invocation, attributed back to this task by its `modified_files`.

### Gate collision worth recording

The pre-commit `typst-sync-check.sh` Check 2 gate blocked the **Phase 1** commit, not Phase 4: any
`.lean` addition moves `formalsystem-file-count` and `formalsystem-line-count`, so the staleness
gate fires at the first phase commit rather than where the plan sites the regeneration. Handled
exactly as the plan's Risks row prescribes — `scripts/typst-sync-check.sh --fix` run and
`status.typ` staged with that same commit, never a hand-patched count and never
`git commit --no-verify`. The same regeneration was repeated at each later phase commit.

## Impacts

- Sixteen new derivations are available to anything importing `FormalSystem.Theorems` or
  `FormalSystem`. The modal-temporal collapses (`▽□φ ↔ □φ`, `△□φ ↔ □φ`, `□△φ ↔ △□φ`,
  `□△φ ↔ □φ`, `◇φ ↔ ◇▽φ`, `◇▽φ ↔ ▽◇φ`) are now citable facts rather than results a reader has to
  reconstruct from P1--P6.
- `temporalPastDerived` generalizes a shape the tree previously had only instantiated at the
  diamond (`boxDiamondToPastBoxDiamond`), so any later derivation needing the TR mirror of TF at
  an arbitrary formula can cite it.
- `perpetuity4` now records its second identity (Pthm:17, and Pthm:20's reverse half), so a
  reader arriving at either name finds the other.

## Follow-ups

- An `docs/reference/API_REFERENCE.md` section for the new module is a reasonable later addition;
  the plan recorded it as out of scope, since no gate requires a row there for this addition and
  three of the four candidate surfaces were in a concurrent sibling's declared file scope.
- Tagging `temporalPastDerived` and `boxToAlwaysBox` `@[tmLemma]` is a reasonable follow-up once
  someone wants the proof search to use them; it needs automation test coverage this task did not
  have.
- The research report's two context-extension recommendations stand: a sentence in
  `docs/development/REFERENCE_NORMAL_FORM.md` recording that C15's anchor regex is
  word-boundary-anchored (so a `Pthm:NN` label is ungated), and a subsection in
  `FormalSystem/Theorems/README.md` distinguishing a definitional identity from a derivability
  biconditional and stating that only the former is simp-registrable.
- `scripts/check-paper-definitions.sh`'s ten drifted anchors need resolving against the paper
  working tree by whoever owns that drift; it is not this task's to fix.

## References

- `specs/798_modal_temporal_interaction_principles/plans/01_modal-temporal-interaction-principles.md` — the plan executed
- `specs/798_modal_temporal_interaction_principles/reports/01_modal-temporal-interaction-principles.md` — the research report whose Appendix A proof terms transferred verbatim modulo renaming
- `specs/798_modal_temporal_interaction_principles/.decisions.json` — the user's answered decision approving P8's siting
- `specs/798_modal_temporal_interaction_principles/handoffs/` — the three per-phase handoffs
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` — the source block, under "Twelve further interaction principles"
