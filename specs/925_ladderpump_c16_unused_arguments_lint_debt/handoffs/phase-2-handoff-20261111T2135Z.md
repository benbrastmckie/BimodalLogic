# Phase 2 Handoff — Task 925 (dispatch_seq 22)

- **Phase**: 2 of 3, "Both LadderPump dispositions, under the net-zero line budget"
- **Outcome**: `[COMPLETED]` — the dispatch-21 blocker is resolved; both edits landed in one
  atomic commit and C16 is green.
- **Gates**: full `bash scripts/check-module-invariants.sh` exits **0**, `ALL CHECKS PASSED`,
  zero `FAIL` lines. Guarded `lake exe runLinter FormalSystem` exits **0**:
  `-- Linting passed for FormalSystem.`, **zero** `unusedArguments` findings.

## Immediate next action

Run Phase 3 (full gate, cascade confirmation, wrap-up). **Read the FORWARD NOTE now attached to
Phase 3's "Confirm no cascade" item before running it** — that item's premise is falsified and
annotated in place.

## The blocker is resolved — do not re-escalate

The dispatch-21 blocker (a term-level call site at `LadderWindow.lean:1294` tripping Phase 2's
"zero term-level applications" gate) was settled by the user decision recorded in
`specs/925_ladderpump_c16_unused_arguments_lint_debt/.decisions.json`, cycle 2. The gate is
amended to "zero term-level applications **that pass the binders positionally**". Re-run live
this dispatch: the one call site passes exactly the seven EXPLICIT arguments
`g₁ hg₁ α k hk hidle₁ hrep₁` and zero instance binders positionally, so the amended gate passes.

## All six decision obligations discharged

| # | Obligation | Result |
|---|-----------|--------|
| 1 | Delete `[Fintype Q] [Nonempty Q]` from `exists_idleSpliced_ladderPath` | done |
| 2 | Delete the `set_option linter.unusedFintypeInType false in` line and the rationale comment | done — **five** lines, not four; see correction below |
| 3 | Apply Edit B's `@[nolint unusedArguments]` per the verified-ready spec | done, verbatim; `PASS C29` first try |
| 4 | Commit A and B atomically in one commit | done — one commit, four files |
| 5 | Regenerate README's generated inventory to absorb the delta | done via `--emit-inventory`; 3 blocks |
| 6 | runLinter reports ZERO flagged declarations; invariants exit 0 incl. INV and C26 | done; `ALL CHECKS PASSED` |

## Carried-figure correction (obligation 2)

The decision specifies "the **four**-line rationale comment at **1820-1823**". Live source shows
a **five**-line block at **1819-1823**: line 1819 (``-- `linter.unusedFintypeInType`, scoped to
this declaration: the signature is pinned by the``) is the block's opening sentence fragment and
cannot stand alone once the `set_option` it explains is deleted. All five were deleted.

The decision's budget of "-4 comment / -1 code for A, 0 comment / +1 code for B" is therefore
corrected to **-5 comment / 0 code net**. This was confirmed empirically rather than argued: the
root `README.md` generated inventory moved `Live comment lines` **139,095 -> 139,090** (-5) with
`Live lines of code` **218,865 unchanged** (0). The code axis matches the decision exactly; only
the comment magnitude was off by one, and obligation (5) absorbs any magnitude by construction.

## New live figures (supersede the plan's)

| Figure | Was | Now |
|--------|-----|-----|
| `LadderPump.lean` line count | 1,931 | **1,926** |
| `RaySummary/README.md` LadderPump row | 1,931 | **1,926** |
| `FormalSystem/Metalogic/README.md` `Decidability/` lines | 118,937 | **118,932** |
| root `README.md` `Live comment lines` | 139,095 | **139,090** |
| root `README.md` `Live lines of code` | 218,865 | **218,865** (unchanged) |
| C26 in-source nolint pairs | 15 + 1 stale INFO | **16 + 0 stale INFO** |
| `runLinter` unusedArguments findings | 2 declarations | **0** |

**CORRECTION (post-commit).** The line above was written before the pre-commit gate ran and is
WRONG. `typst/generated/status.typ` **did** drift — `formalsystem-line-count`
**404,983 -> 404,978**, the same -5 — and was regenerated with `scripts/typst-sync-check.sh --fix`
(plus a mechanical `stamp-commit` refresh), then committed with the rest. It is inside task 925's
declared `file_scope`. This drift was INVISIBLE to `check-module-invariants.sh`, which reported
`ALL CHECKS PASSED` and `PASS INV` while `status.typ` was still stale; it surfaced only when
`git-commit-scoped.sh`'s pre-commit hook ran `typst-sync-check.sh --counts-only` and refused the
commit. **INV and typst-sync-check cover disjoint generated surfaces — a green invariants run is
not evidence that typst counts are current.**

## Evidence of record

- Guarded full `lake build`: guard exit **0**, `Build completed successfully (2974 jobs)`, zero
  `error:` lines. `.olean` newer than source confirmed for `LadderPump`, `LadderIdle`,
  `LadderWindow`.
- Guarded `lake exe runLinter FormalSystem`: exit **0**,
  `-- Linting passed for FormalSystem.`, zero `unusedArguments` matches in the whole output.
- Full `bash scripts/check-module-invariants.sh`: exit **0**, `ALL CHECKS PASSED`.
  `PASS INV`, `PASS C16` (env_linter batch), `PASS C26` (16 pairs), `PASS C29` (87 occurrences).

## Plan deviations recorded this dispatch

1. **Edit A's replacement comment: SKIPPED.** The user decision prescribes a net negative comment
   delta for Edit A and puts README regeneration in scope, which is only coherent if no
   replacement comment is written. With the `set_option` gone there is no suppression left to
   justify. The item is left `- [ ]` with a `skipped` annotation.
2. **The 1931 budget assertion: ALTERED.** Target is now 1,926; absorbed by regeneration, never
   by hand-editing a count.
3. **The commit: ALTERED.** One atomic commit covering FOUR files, not one — `LadderPump.lean`
   plus the three regenerated inventory blocks, which must ride along or the commit is red
   against `INV`.
4. **Scoped/dependent builds: ALTERED.** Subsumed by a guarded FULL `lake build`, this agent's
   mandated phase-end gate, which strictly subsumes both.

## Territory observations

- No foreign uncommitted modifications under `FormalSystem/` at any point. The pre-existing
  foreign dirt from dispatch 21 is still present and still untouched: `specs/893_.../issues.jsonl`,
  `specs/events.jsonl`, untracked `.pid`, `specs/893_.../stale-dispatch-2-plan-report.md`,
  `specs/evidence/history-morphism-saturation-audit/`.
- `README.md`, `FormalSystem/Metalogic/README.md` and `RaySummary/README.md` are all inside task
  925's own declared `file_scope`, so regenerating them is in territory. Several other tasks list
  `README.md` in `file_scope`, but all are `not_started` / `planned` / `hold` — none dispatched.
- `LadderWindow.lean` was read only, never edited. Task 918, which held it, is complete
  (`51faa61b9`).
