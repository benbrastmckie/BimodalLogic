# Implementation Summary: Task #925

- **Task**: 925 - Clear the C16 env_linter unusedArguments lint debt in RaySummary/LadderPump.lean
- **Status**: [COMPLETED]
- **Started**: 2026-11-11T18:40:00Z
- **Completed**: 2026-11-11T22:05:00Z
- **Effort**: ~3.5 hours across 3 phases and 4 dispatches (20, 21, 22, 23)
- **Dependencies**: None
- **Artifacts**: plans/01_ladderpump-c16-unusedarguments-clear.md, reports/01_ladderpump-c16-unusedarguments-clear.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md, lean4.md

## Overview

`check-module-invariants.sh`'s C16 `env_linter` group failed on two `unusedArguments` findings in
`FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean`, costing every other task in the
module an attribution step before it could read its own gate result. Both findings are now
cleared, by two deliberately different dispositions matched to the kind of binder each carries.
C16 is green, `runLinter FormalSystem` reports zero `unusedArguments` findings anywhere, and the
full non-`--no-build` invariants run ends `ALL CHECKS PASSED`.

## What Changed

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderPump.lean` — two dispositions:
  - **`exists_idleSpliced_ladderPath` was GENERALIZED**, not weakened. Its two dead
    instance-implicit binders `[Fintype Q]` and `[Nonempty Q]` were deleted outright, together
    with the now-pointless `set_option linter.unusedFintypeInType false in` line and the
    five-line rationale comment above it, whose central claim was verified **false** (it asserted
    `exists_ladderPath_of_walk_of_pins` "reads only `Finite Q`"; that declaration, at
    `LadderAgree.lean:1322`, sits in `section Path` under `variable {Q : Type} {step} {pend}` and
    takes no instance on `Q` at all). The new signature:

    ```lean
    theorem exists_idleSpliced_ladderPath {Q : Type}
        {step : Q → Q → Bool} {pend : Q → Bool}
        (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (a : ℤ) (l : ℕ) (hl : 0 < l)
        (hidle : ∀ i : ℕ, i < l → pend (objAt g (a + (i : ℤ))) = false)
        (hrep : objAt g a = objAt g (a + (l : ℤ))) :
        ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
          (∀ v : ℤ, objAt g' v = spliceObj g a l v) ∧
          (∀ v : ℤ, cntAt g' v = idleSpliceCnt g a l v) :=
    ```

    The statement now holds for an arbitrary `Q : Type` with no finiteness or nonemptiness
    assumption. Every prior consumer remains valid: instance arguments are supplied by synthesis,
    never positionally, so dropping them is invisible at each call site. The one term-level
    application (`LadderWindow.lean:1294`) passes exactly the seven explicit arguments
    `g₁ hg₁ α k hk hidle₁ hrep₁` and zero instance binders.
  - **`exists_idleTypeBlock_of_budget_le_run` KEPT its binders** and gained an in-source
    `@[nolint unusedArguments]`, paired with a reasoned entry in
    `scripts/nolint-attribute-allowlist.txt`. Its unused argument is the EXPLICIT hypothesis
    `hg : IsLadderPath step pend g`; deleting an explicit hypothesis would relocate the proof
    obligation onto every consumer, so suppression with a stated reason is the correct
    disposition. The adjacent comment was rewritten to name `linter.unusedVariables` literally
    and to explain why a scoped `set_option` cannot reach a Batteries `@[env_linter]` — that
    linter runs post-hoc over an imported environment, where no source-level `set_option` is in
    scope, which is exactly why the attribute and allowlist entry are needed alongside it.
- `scripts/nolint-attribute-allowlist.txt` — reasoned entry
  `unusedArguments:exists_idleTypeBlock_of_budget_le_run` landed in Phase 1, ahead of the
  attribute, so C26 never saw an attribute without its allowlist partner.
- `README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` — generated inventory blocks
  REGENERATED (never hand-edited) to absorb the −5 comment / 0 code delta.
- `typst/generated/status.typ` — regenerated via `scripts/typst-sync-check.sh --fix` for the same
  −5 (`formalsystem-line-count` 404,983 → 404,978) plus a mechanical `stamp-commit` refresh.

## Decisions

- **Disposition is chosen by binder kind, not by convenience.** Delete an unused
  INSTANCE-IMPLICIT binder, because synthesis makes the removal invisible to every call site;
  RETAIN an unused EXPLICIT hypothesis behind `nolint` + a reasoned allowlist entry, because
  deletion would relocate the obligation to consumers. This single principle produced both
  dispositions and reproduced Phase 1's independent call on the `hg` case.
- **A verified-false in-source rationale is deleted, not carried forward.** The
  `linter.unusedFintypeInType` comment was removed outright rather than reworded, because the
  `set_option` it justified was itself removed and its central claim did not survive checking.
- **Generated surfaces absorb drift by regeneration, never by hand-editing a count.** The line
  budget turned out to be two-dimensional (`Live lines of code` and `Live comment lines` are
  counted separately, and `INV` fails if either drifts), which a single total-line target cannot
  express.
- **The gate's wording, not its purpose, was what a new call site tripped.** Phase 2's
  "zero term-level applications" pre-edit gate was amended by user decision to "zero term-level
  applications **that pass the binders positionally**" — the original wording was a proxy for
  "no consumer breaks" and is the wrong instrument for instance-implicit binders.

## Plan Deviations

- **Phase 2, Edit A replacement comment** skipped: with the `set_option` deleted there is no
  suppression left to justify, so a reason comment would have nothing to explain. The user
  decision's negative comment budget is only coherent if no replacement is written.
- **Phase 2, the 1931 line budget** altered: superseded to **1,926** (−5 comment / 0 code).
  Absorbed by regeneration; `PASS INV` confirms.
- **Phase 2, the commit** altered: one atomic commit covering four files, not one — the
  generated surfaces must ride along or the commit is red against `INV`.
- **Phase 2/3, scoped and dependent builds** altered: subsumed by a guarded FULL `lake build`,
  this agent's mandated phase-end gate, which strictly subsumes all three scoped builds.
- **Phase 3, `verify-deploy.sh`** altered: discharged under the dispatch's Batch Gate Deferral.
  The narrowing is structurally empty — every gate lints the deployed `.claude/` tree or the
  `agent-system/extensions/` source store, and this task touched zero files under either — so
  `--only-gate 3,4` was run to record a real verdict rather than waive the criterion.
- **Phase 3, `lean-challenge-snapshot.sh --check`** altered: no Challenge manifest exists for
  this task (exit 71), so the anticipated drift was confirmed by direct comparison against task
  911's plan-text pin instead. Advisory-only; did not affect any verdict.
- **Phase 3, "no cascade" / "exactly two modified files"** altered: the item's premise was
  falsified by the user decision and was annotated in place by dispatch 22. Read against the
  amended figures, it passes.

## Verification

- Build: **Success** — guarded full `lake build`, guard exit 0, `Build completed successfully
  (2974 jobs)`, zero `error:` lines, `.olean` newer than source for `LadderPump`, `LadderIdle`
  and `LadderWindow`.
- Linter: guarded `lake exe runLinter FormalSystem` exit **0**,
  `-- Linting passed for FormalSystem.`, **zero** `unusedArguments` matches and zero
  `LadderPump` matches in the whole output.
- Invariants: full non-`--no-build` `scripts/check-module-invariants.sh` exit **0**,
  `ALL CHECKS PASSED`, zero `FAIL` lines. `PASS INV`, `PASS C16` (env_linter batch),
  `PASS C26` (16 in-source nolint pairs, up from 15, with **no** `INFO C26` stale line and no
  `exists_idleTypeBlock` occurrence anywhere), `PASS C29` (87 occurrences).
- Typst: `scripts/typst-sync-check.sh` exit **0**, all four checks green, `MISMATCH_COUNT=0`,
  `MODULE_MAP_MISMATCHES=0`, `MA_COUNT_MISMATCHES=0`, `CHECK4_VIOLATIONS=0`.
- Deploy aggregator: `verify-deploy.sh --only-gate 3,4` exit **0**,
  `PASS -- 1 check(s), 0 failure(s)`; gate 3 `[SKIP]` (deploy consumer, not source store),
  gate 4 task-reference lint `[PASS]`. Complete gate set deferred to the batch stage.
- Sorry count: **0**
- Vacuous count: **0** for this task's own work. One pre-existing match of the heuristic grep
  exists — `FormalSystem/Examples/TemporalStructures.lean:495`,
  `theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial` — confirmed
  byte-identical at the pre-task baseline `f7b64854b`, named OUT OF SCOPE by this task's own
  dispatch description, and outside its `file_scope`.
- Axiom count: **14**, identical to the pre-task baseline `f7b64854b`. Unchanged.
- Plan compliance: `COMPLIANCE_CHECK: passed` — both pinned names
  (`exists_idleSpliced_ladderPath`, `idleSpliceCnt`) found in the resolved source roots.
- Files verified: Yes.

## Impacts

- C16's `env_linter` group is green for `LadderPump.lean`, so every subsequent task in
  `RaySummary/` reads its own gate result directly instead of first attributing two inherited
  findings as pre-existing. This was the task's whole purpose.
- `exists_idleSpliced_ladderPath` is now available at arbitrary `Q : Type`. Any future consumer
  working over a non-finite or possibly-empty object type can apply it without first
  manufacturing `Fintype`/`Nonempty` instances it does not have. No existing consumer changed.
- C26's in-source `nolint` pair count rose 15 → 16 with zero stale entries, so the allowlist and
  the live attribute set agree exactly.

## Follow-ups

- The `:= trivial` proof at `FormalSystem/Examples/TemporalStructures.lean:495`
  (`int_domain_universal`) remains, explicitly out of scope here and pre-existing. It is the
  separate finding the sibling record enumerated; whether it is genuinely vacuous or a correct
  `trivial`-discharged domain obligation is unexamined by this task.
- `INV` and `typst-sync-check.sh` cover **disjoint** generated surfaces. A green
  `check-module-invariants.sh` is NOT evidence that typst counts are current — dispatch 22 hit
  exactly this, with `PASS INV` reported while `status.typ` was still stale, caught only by
  `git-commit-scoped.sh`'s pre-commit hook. Worth a gate that closes the gap.
- No Challenge manifest exists for this task, so `lean-challenge-snapshot.sh --check` had no pin
  to check the deliberate generalization against. If challenge pinning is meant to cover
  signature changes in this module, the snapshot needs taking at plan time.

## References

- `specs/925_ladderpump_c16_unused_arguments_lint_debt/plans/01_ladderpump-c16-unusedarguments-clear.md`
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/reports/01_ladderpump-c16-unusedarguments-clear.md`
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/handoffs/phase-1-handoff-20261111T1942Z.md`
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/handoffs/phase-2-handoff-20261111T2135Z.md`
- `specs/925_ladderpump_c16_unused_arguments_lint_debt/.decisions.json` (cycle 2 decision)
- `scripts/nolint-attribute-allowlist.txt:120,136`
- Precedent: archived record `ladderchain_c16_unusedarguments_clear` (same C16 class in
  `LadderChain.lean`)
