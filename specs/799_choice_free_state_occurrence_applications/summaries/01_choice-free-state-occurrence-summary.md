# Implementation Summary: Task #799

- **Task**: 799 - Choice-free `StateOccurs` for the state-set applications
- **Status**: [COMPLETED]
- **Started**: 2026-10-15T10:45:00Z
- **Completed**: 2026-10-15T11:20:00Z
- **Effort**: ~0.6 hours
- **Dependencies**: the state-set pin task (landed — `StateOccurs.of_isRegular` and the three
  `_of_isRegular` corollaries were already in the tree)
- **Artifacts**: plans/01_choice-free-state-occurrence.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The paper's cut footnote to `lem:state-set` claims its appeals to `cor:occurrence` — and hence to
Zorn's lemma — are inessential at the frames where the lemma is applied, because a possible world
through a given state at a given time is there exhibited explicitly as a translation. That second
route now exists in Lean, as one new leaf module carrying seventeen declarations in two layers:
an **absolutely choice-free** layer over an arbitrary duration group, routed through `ShiftSet`,
and the same results at `translationFrame D`, where the frame constant's own profile makes only a
**relative** pin available. A read-only audit of every consumer of the state-set results and a
three-route record in `StateSetTruth.lean`'s module docstring complete the four deliverables. The
general two-hypothesis originals, the Zorn-routed `_of_isRegular` forms,
`DeterminismUndefinable.lean` and `TaskFrame.limit_of_shift` are all untouched.

## What Changed

- `FormalSystem/Metalogic/Independence/TranslationStateSet.lean` — **new file, 418 lines,
  seventeen declarations.** Flow layer (ten): `selfShift` (`D` acting on itself as a `ShiftSet`,
  its structural obligation discharged from the order on `↑D` alone), `translationFlow` (its task
  frame), `translationFlow_taskRel`, `translationFlow_states_eq`, `translationFlow_orderFlow`
  (H1), `translationFlow_stateOccurs` (H2, by the orbit history through `-x + w`),
  `translationFlow_deterministic`, and the three corollaries
  `translationFlow_plusTruthAt_iff_mem_satSet`, `translationFlow_determined`,
  `translationFlow_plusValidOn_iff_satSet_univ`. Frame layer (seven): `translationState`,
  the `translationFrame_worldLinearOrder` instance, `translationFrame_orderFlow`,
  `translationFrame_stateOccurs` (H2 by the paper's own `σ_c` at `c = -x + w`), and the three
  `translationFrame_*` corollaries. The module docstring carries an `## Axiom pin` section with
  two commented-out `#print axioms` fences and the measured profiles. (The instance is
  `translationFrameWorldLinearOrder` — see Plan Deviations.)
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — **module docstring only** (one pure
  insertion hunk, inside the docstring): a `## Choice dependence` section with the four-row route
  table (route | hypotheses | (H2) from | choice cost | consumers), per-route prose, the two
  generic-argument profiles, and the consumer-audit verdict.
- `FormalSystem/Metalogic/Independence.lean` — one import line and one `## Contents` bullet. No
  numbered result and no change to the "thirteen results" count.
- `FormalSystem.lean` — one import line, in sorted position after
  `…Independence.TranslationProductCoarse`.
- `FormalSystem/Metalogic/Independence/README.md` — regenerated per-file inventory, plus the
  hand-written description cell for the new module and a `## Key Results` bullet for the two
  routes.
- `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`, `README.md` — regenerated
  inventory count rows only.
- `typst/generated/status.typ` — regenerated whole-tree file and line counts only.

## Decisions

- **Both layers landed, not just the absolutely choice-free one.** The headline is the absolute
  pin at the `ShiftSet` avatar, but the `*Sharpness` countermodels build on `translationFrame D`,
  so the results had to exist there too.
- **The `translationFrame` pin is recorded as relative, in exactly the words the measurement
  supports.** `#print axioms` traverses a declaration's type as well as its value, and
  `translationFrame` itself reports `Classical.choice` (through `TaskFrame.limit_of_shift`), so no
  statement mentioning the frame constant can report less. What the measurement does establish is
  that the five frame-layer theorems report *exactly* `translationFrame`'s own profile, so the
  (H2) discharge contributes nothing: no `cor:occurrence`, no `thm:extension`, no Zorn.
- **`TaskFrame.limit_of_shift` left alone**, per the settled prior decision carried in the
  dispatch: a choice-free rewrite is verified to exist, but shrinking an axiom set trips
  `check-module-invariants.sh`'s exact-string baseline and falsifies `MainResults.lean`'s prose
  contract.
- **No edit to `DeterminismUndefinable.lean`**, which is both the cheapest discharge of the
  dispatch's axiom-pin constraint and the honest outcome of the audit: nothing there is on the
  Zorn route, so nothing there has a choice-free route to move to.
- **Three proof-writing choices are load-bearing for the absolute pin** at an arbitrary
  `TemporalOrder`: witnesses written additively as `-(τ.state 0) + v`, `add_lt_add_right` rather
  than `add_lt_add_left`, and `by_contra` plus `abs_pos.mpr` rather than `abs_eq_zero`. `sub_pos`
  appears nowhere.
- **The `#print axioms` records are commented fences inside docstrings**, not live directives,
  on `DeterminismUndefinable.lean`'s `## Axiom pin (C4)` precedent — so no C27 allow-list row is
  incurred.

## Plan Deviations

- **Phase 3 altered: the `LinearOrder` instance is named `translationFrameWorldLinearOrder`, not
  the pinned `translationFrame_worldLinearOrder`.** `LinearOrder` is a data-valued class, so
  mathlib's `defsWithUnderscore` linter counts the declaration as a definition, and the pinned
  underscore name was its single new finding across 16536 declarations — failing C16. The tree's
  existing underscore-bearing instances (`translationFrame_isRegular`, `fibre_isRegular`,
  `limitDomSubtype_noMaxOrder`) all inhabit *Prop*-valued classes and are exempt, which is why
  they stand. `chroniclePriorDomainLinearOrder` (`WeakCanonical/ChronicleExtraction.lean`) is the
  house precedent for the camelCase form on exactly this shape, and camelCase is what the
  linter's own message prescribes. The instance's **type is unchanged**, its `inferInstanceAs`
  body is unchanged, and every consumer is unchanged: only the identifier differs from the pinned
  one, so no statement was weakened. Annotated inline on the Phase 3 checklist item.

Everything else in the plan's `## Lean Challenge Statements` block elaborated unchanged on the
first attempt, and all twenty measured axiom profiles matched the plan's recorded values.

Three further mechanical adaptations, none of which changed what was built:

- **Axiom profiles were measured by compiled probe, not by the `lean_verify` MCP tool.** That
  tool's schema takes a single `(file_path, theorem_name)` pair, and the `lean_run_code` server
  held a stale import snapshot after each scoped rebuild — reporting freshly added constants as
  unknown while the `.olean` on disk carried them. Profiles were therefore measured by running a
  scratch file of `#print axioms` lines through `lake env lean`, a compiled probe against the
  built oleans and a stronger evidence tier than the LSP route.
- **`typst/generated/status.typ` was regenerated once per phase commit** rather than once in the
  final phase: `git-commit-scoped.sh`'s pre-commit gate rejects a commit while the whole-tree
  file and line counts lag the tree, and a new module moves them on the very first phase.
- **Phase 3's "grep returns nothing" verification line was discharged against code positions.**
  A bare `grep -n 'PartialHistory.extension\|StateOccurs.of_isRegular'` over the new module
  returns two hits, both docstring prose naming the routes this module avoids — prose the same
  phase's own task list mandates. The intended property, zero *code* references, was verified by a
  comment-stripped scan, which reports zero for `PartialHistory.extension`,
  `PartialHistory.occurrence`, `StateOccurs.of_isRegular` and `limit_of_shift` alike.

## Verification

- Build: **Success** — `lake-build-guard.sh build --timeout 1800 -- build` (whole project,
  detached) exit 0, 2858/2858 jobs, `Build completed successfully`, zero `error:` lines over both
  captured streams, and `.olean` newer than source for every module this task touched
  (`TranslationStateSet`, `StateSetTruth`, `Independence`, the `FormalSystem` root).
- Sorry count: **0** (`lean-sorry-census.sh` over all resolved source roots; zero added `sorry`
  in the task's whole diff).
- Vacuous count: **0 attributable** — the single tree-wide grep hit is
  `FormalSystem/Examples/TemporalStructures.lean`'s `int_domain_universal`, pre-existing and in a
  file byte-identical to pre-task HEAD.
- Axiom count: **not increased** — zero `+axiom ` lines in the task's whole diff against pre-task
  HEAD.
- **The absolute pin** (measured against the fully built tree): `selfShift` and `translationFlow`
  `[propext]`; `translationFlow_taskRel`, `translationFlow_states_eq`,
  `translationFlow_orderFlow`, `translationFlow_stateOccurs`, `translationFlow_deterministic`,
  `translationFlow_plusTruthAt_iff_mem_satSet`, `translationFlow_determined` and
  `translationFlow_plusValidOn_iff_satSet_univ` all `[propext, Quot.sound]` — **no
  `Classical.choice` on any of the ten**, over an arbitrary `(D : TemporalOrder)`.
- **The relative pin**: `FormalSystem.Semantics.translationFrame`, `translationState`,
  `translationFrameWorldLinearOrder`, `translationFrame_orderFlow`,
  `translationFrame_stateOccurs`, `translationFrame_plusTruthAt_iff_mem_satSet`,
  `translationFrame_determined` and `translationFrame_plusValidOn_iff_satSet_univ` all
  `[propext, Classical.choice, Quot.sound]` — the identical string, which is what makes the pin
  relative and the (H2) discharge free.
- **Cross-checks**: `plusTruthAt_iff_mem_satSet` `[propext]` alone and `determined_of_orderFlow`
  `[propext, Quot.sound]`, so the generic argument is choice-free and only instantiation adds
  choice.
- **The existing axiom pin still passes**: `fzero_determined`, `fzero_plusValidOn_iff_f1` and
  `deterministic_not_plusDefinable` all still `[propext, Classical.choice, Quot.sound]`, with
  `DeterminismUndefinable.lean` and `FormalSystem/Semantics/TaskFrame.lean` both byte-identical to
  pre-task HEAD.
- `check-module-invariants.sh --emit-inventory --check` exit 0: every generated inventory block
  current.
- `typst-sync-check.sh` exit 0, `readme-lint.sh` exit 0, `check-phantom-citations.sh` exit 0,
  `export-lean-citations.py --check` exit 0.
- `check-module-invariants.sh --no-build` at each phase boundary: the only `FAIL` through Phases
  1-4 was `INV` (the four stale inventory blocks Phase 5 regenerates); C33, C8, C4, C5, C9, C14,
  C15, C18, C20, C21, C26, C27, C29, C30, C32, C34a, C34b and C35 all PASS throughout. **C16's
  `env_linter` batch is skipped under `--no-build`** and so reported nothing at those four
  boundaries; the build-backed Phase 5 run is what surfaced the `defsWithUnderscore` finding on
  the instance name, which the rename cleared. This is worth knowing for a future Lean phase: a
  `--no-build` gate reporting green does not cover the linter batch.
- `check-paper-definitions.sh`: the inherited drift wave is reported, not repaired — this task
  changes no `docs/**` and no `scripts/**` file (`git diff` against pre-task HEAD over both trees
  is empty), adds no drifted anchor of its own, and incurs no new `sha256:` commitment. All twelve
  paper anchors its docstrings cite already had a record row at plan time.
- Tests: N/A — no `Tests/BimodalTest/` axiom pin was added for the new declarations (a reasonable
  later addition, and a declared non-goal here).
- Files verified: Yes.
- `check-module-invariants.sh` **build-backed, after the rename: exit 0, `ALL CHECKS PASSED`,
  zero `FAIL` lines.** C16's `env_linter` batch (`defsWithUnderscore`, `docBlame`, `simpNF`,
  `structureInType`, `tacticDocs`, `unusedArguments`) PASSes with no un-nolisted finding, and
  `C16 dupNamespace`, C15 (both checks), C33 and C35 all PASS. The one residual C16 row is a
  pre-existing `TODO` — 226 findings across 15 of 18 non-`FormalSystem` lakefile roots, gated
  behind `ENFORCE_C16_ROOTS=1` and explicitly not yet enforced.
- `check-module-invariants.sh --emit-inventory --check` exit 0 and
  `typst-sync-check.sh --counts-only` `MISMATCH_COUNT=0`, both re-confirmed after the rename
  (which is length-preserving, so no count moved).
- **C35 cross-checked by seed inspection as well as by the gate**: `scripts/lean-citation-seeds.txt`
  has zero hits for every declaration family this task touched (`StateSetTruth`,
  `TranslationStateSet`, `satSet`, `plusTruthAt_iff_mem_satSet`, `plusValidOn_iff_satSet_univ`,
  `determined_of_orderFlow`, `StateOccurs`, `OrderFlow`), and `lean-citation-manifest.json` has
  zero. Both files are byte-identical to pre-task HEAD, so the 45 docstring lines added to
  `StateSetTruth.lean` shift no cited span and no regeneration is owed.
- **Full `verify-deploy.sh` deferred to the batch stage**, per this dispatch's Batch Gate
  Deferral directive: the complete gate set runs once for the whole batch at the end of the
  invocation. No narrowed invocation of it covers this task's files — all twenty-three of its
  gates concern the deployed `.claude/` tree, and this task's diff contains zero `.claude/**` and
  zero `agent-system/**` paths. The deploy tree is independently known stale for the `core`
  extension from a cause predating this dispatch. Recorded as a reasoned exclusion on Phase 5.

## Impacts

- `lem:state-set`'s three sentences are now available with **no `Classical.choice` at all**, at a
  translation flow over an arbitrary duration group — so any later result that needs the
  state-set bridge at a translation-shaped frame can reach it without paying for Zorn.
- `translationFlow_deterministic` generalises the corresponding fact about `F¹` off `ℝ` to an
  arbitrary duration group at no cost, which is what a reader consulting the choice record at a
  glance wants to see alongside the three sentences.
- A reader of `StateSetTruth.lean` can now tell, from its own module docstring, which of the four
  routes any given result takes and what that route costs — including that the three
  `_of_isRegular` forms have no consumer at all and exist to state `lem:state-set` at
  `def:flow`'s own hypotheses.

## Follow-ups

- A `Tests/BimodalTest/` axiom pin for the seventeen new declarations would make the absolute and
  relative profiles a compiler obligation rather than a dated docstring record.
- `rmk:choice`'s paper-side inventory and the `% PORT:` comment at `lem:state-set` are paper-side
  work in another repository, out of scope here.
- **A gate-blindness finding worth carrying beyond this task**: C16's `env_linter` batch is
  skipped under `--no-build`, so a naming defect in a *data-valued* instance is invisible to every
  cheap gate and surfaces only at the most expensive, build-backed run. Any later Lean phase
  introducing a data-valued instance (`LinearOrder`, `DecidableEq`, anything not Prop-valued)
  should use the camelCase house form — `chroniclePriorDomainLinearOrder` is the precedent — from
  the start rather than discovering it at the end. Prop-valued instances
  (`translationFrame_isRegular`, `limitDomSubtype_noMaxOrder`) are exempt and may keep underscores.
- A choice-free `TaskFrame.limit_of_shift` is verified to exist and would make `translationFrame`
  itself choice-free, promoting the relative pin to an absolute one. Taking it requires a decision
  about the repository-wide exact-string axiom baseline and `MainResults.lean`'s prose contract,
  not a decision about this module.

## References

- `specs/799_choice_free_state_occurrence_applications/plans/01_choice-free-state-occurrence.md`
- `specs/799_choice_free_state_occurrence_applications/reports/01_choice-free-state-occurrence.md`
- `specs/799_choice_free_state_occurrence_applications/handoffs/` — the four per-phase handoffs
- `specs/799_choice_free_state_occurrence_applications/issues.jsonl`
- JPL paper `lem:state-set`, `def:state-set`, `def:flow`, `rmk:choice`, `cor:occurrence`,
  `thm:extension`, `def:canonical-frames`, `lem:canonical-frames`, `def:deterministic`
