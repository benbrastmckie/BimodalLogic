# Research Report: Task #755

**Task**: 755 - Plan files to modify unenforced
**Started**: 2026-10-10T00:00:00Z
**Completed**: 2026-10-10T00:00:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: - Codebase (source store at `/home/benjamin/.config/nvim/agent-system/extensions/core`), repo-wide sweep of `specs/*/plans/*.md`, live state.json/TODO.md inspection
**Artifacts**: - `specs/755_plan_files_to_modify_unenforced/reports/01_files-to-modify-unenforced.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- `validate-artifact.sh`'s plan mode has a per-phase loop (lines 307-328, the `**Verification
  Tier**` check) that is the exact, already-proven site to add a parallel `**Files to modify**`
  presence check — same `phase_line_nums`/`phase_block` iteration, same `log_warn`/`log_error`
  pattern, no new plumbing needed.
- A repo-wide sweep shows the blind spot is nearly closed already: of 16 active (non-archived)
  plans, exactly **one** — task #410's plan — lacks every "Files to modify" occurrence. All 131
  other missing-field hits are in `specs/archive/`. This is strong grounds to consider a tighter
  enforcement default than the `Verification Tier` precedent used (which started advisory because
  the legacy population was large at the time), though the final tier choice is a plan-phase
  decision, not a research-phase one.
- The "no block anywhere" vs. "block present, zero paths" distinction (SCOPE item 3) is not
  hypothetical: task #750's plan (`specs/750_.../plans/01_w-run-layer-ladder-scheme.md`, line
  525-526) has a live, legitimate "none planned" sentinel phase that already round-trips through
  `plan-file-scope-harvest.sh` as "contributes nothing," confirmed by direct invocation. Any new
  check must not flag this phase, only a phase (or whole plan) with no header at all.
- `scripts/backfill-file-scope.sh` already exists and is the natural vehicle for SCOPE item 4, but
  it cannot fix #410 as written: it calls the harvester, the harvester returns `[]` because #410's
  plan has zero "Files to modify" headers (it uses a `## Territory Contract` table instead), and
  `backfill-file-scope.sh`'s own skip logic treats harvester-`[]` identically to "no plan" —
  leaving `file_scope` untouched. The regression fixture therefore requires repairing #410's
  *plan* (adding per-phase "Files to modify" blocks sourced from its existing Territory Contract
  table) before a harvester re-run can produce a non-empty scope — confirming the dispatch's own
  phrasing ("a re-run of the harvest on a *repaired plan*") rather than a direct `file_scope`
  edit.

## Context & Scope

This task researches where and how to enforce `plan-format.md`'s REQUIRED per-phase `Files to
modify` field, which today has zero enforcement in `validate-artifact.sh`, so a plan can validate
clean while leaving a task's `file_scope` permanently `null` — invisible to the orchestrator's
admission overlap gate. The SCOPE items from the dispatch are: (1) where the check belongs, (2)
what severity tier it should start at, (3) whether the harvester should distinguish "no block"
from "block, no paths," and (4) backfilling #410 as the regression fixture. The edit target for
any resulting plan is the source store (`/home/benjamin/.config/nvim/agent-system/extensions/core`),
per `source-store-deploy-boundary.md`; the deployed `.claude/` tree was confirmed in sync with
this source store at research time (`source_git_head` matches `git rev-parse HEAD` in the
agent-system repo: `f86b736c2ae3c7be25ebf44104c02073b66e0b61`), so no redeploy was needed before
reasoning from the deployed copy.

## Findings

### Codebase Patterns

**Site for the check (SCOPE 1)**: `scripts/validate-artifact.sh`'s plan-specific block (lines
194-329) already has a template to copy almost verbatim. The per-phase Verification Tier check
(lines 298-328) does exactly the shape a Files-to-modify check needs:

```
mapfile -t phase_line_nums < <(grep -nE "$PHASE_HEADING_ERE" "$artifact_path" | cut -d: -f1)
...
for i in "${!phase_line_nums[@]}"; do
  ...
  phase_block=$(sed -n "${start_line},${end_line}p" "$artifact_path")
  tier_value=$(echo "$phase_block" | grep -oE '...')
  if [ -z "$tier_value" ]; then
    log_warn "Phase ${phase_num} missing **Verification Tier** field"
  ...
```

`phase_line_nums`, `phase_num` (via the shared `extract_phase_number` from
`scripts/lib/phase-heading-patterns.sh`, sourced earlier at line 224), and `phase_block` are
already computed in one loop; a Files-to-modify presence test is one more `grep -oE` against
`phase_block` for the header line, reusing the same two accepted header patterns the harvester
already recognizes (`\*\*Files to modify\*\*:` / `\*\*Files to modify:\*\*`, optionally
list-marker-prefixed per the "Field-punctuation tolerance" rule in plan-format.md:118-131). No new
library, no new sourcing — this loop is a single pass, so both checks can run in the same
iteration without a second file scan.

**Severity tier (SCOPE 2) — population data, not a research-phase decision**: The `Verification
Tier` field's own promotion-criterion note (plan-format.md:393-404) says: "promote the warning to
an error once no non-terminal plan under `specs/` lacks the field... recorded here for a future
task to execute." A repo-wide sweep run during this research (`grep -L -i "files to modify"` over
every `specs/*/plans/*.md` and `specs/archive/*/plans/*.md`) found:

- 131 of 1098 total plan files lack the literal string "files to modify" anywhere.
- Of those 131, **130 are under `specs/archive/`** (completed/abandoned legacy plans that predate
  the convention or were never touched again).
- Exactly **one** non-archived, active plan lacks it: `specs/410_.../plans/01_internalize-routine-admissibility.md`
  (confirmed: `specs/[0-9]*/plans/*.md` sweep of 16 active plan files found only this one miss).

This is a materially different starting position than `Verification Tier` had when it was
deliberately launched advisory-first — here the active-plan promotion criterion is almost already
met. The decision of exactly which tier to land on (warn vs. error, and whether "error" should
gate `--strict` only or default mode) belongs to the plan phase, but the population evidence
argues for not defaulting reflexively to the same advisory-first posture without re-examining it
against this much smaller gap. The field's own per-phase/whole-document distinction also matters
here, mirrored from the `PLAN_METADATA` comment at validate-artifact.sh:39-44: a whole-document
`grep -qF` existence check would pass as soon as the string appears once anywhere (e.g. phase 1
only), which under-enforces exactly the way that comment already warns against for `Verification
Tier` — so any new check must be the same per-phase loop, never a whole-document grep.

**Harvester no-block-vs-empty-block distinction (SCOPE 3)**: `plan-file-scope-harvest.sh`'s own
header (lines 12-19) documents returning `[]` as "a normal, exit-0 outcome, never an error" for
both cases today. A live, legitimate instance of the "block present, zero paths" case exists
right now: `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md` lines
525-526:

```
**Files to modify**:
- none planned — this phase edits nothing unless a gate fails, in which case the fix is forward
  (`context/contracts/recovery.md`) in the file the gate names and the phase that owns it is
  re-verified
```

Direct invocation (`bash plan-file-scope-harvest.sh specs/750_.../01_w-run-layer-ladder-scheme.md`)
confirms this phase correctly contributes no path (the "- none planned ..." line does not match
the entry pattern `^[ \t]*-[ \t]*\``), while the plan's *other* phases still populate a non-empty
aggregate scope — so at the harvester's current API (one JSON array per plan, no per-phase
breakdown) this legitimate case is indistinguishable in isolation from a phase with no header at
all; the two are distinguished only by inspecting whether the header string is present in that
phase's block. Any new distinguishing logic (a second script, a `--report-missing-blocks` flag,
or output structure change) needs to walk phase blocks the same way `validate-artifact.sh`'s loop
does — i.e., this is naturally the SAME per-phase-block mechanism as SCOPE 1/2, not a separate
one. The cleanest layering: `validate-artifact.sh` reports "no Files to modify block in phase N"
as its own finding (using the header-presence test above), while the harvester's contract stays
unchanged ("empty array is normal") since changing the harvester's return shape would ripple into
all seven of its callers (confirmed via `grep -rl plan-file-scope-harvest.sh`:
`reconcile-task-status.sh`, `orchestrate-batch-admit.sh`, `orchestrator-postflight.sh`,
`backfill-file-scope.sh`, `update-task-status.sh`, plus two test suites) — out of scope per the
dispatch's NON-GOALS ("no change to the union-merge semantics in `update-task-status.sh`").

**Backfill mechanics for #410 (SCOPE 4)**: `scripts/backfill-file-scope.sh` already exists,
already reuses the harvester (never re-implements path extraction, per its own header), and
already has test coverage (`scripts/tests/test-backfill-file-scope.sh`, 241 lines). Its skip
logic (lines "plan found ... but harvested nothing -- SKIP") treats a harvester return of `[]`
identically whether the cause is "no plan" or "plan exists but nothing harvestable" — so running
this tool today against #410 produces no change, because #410's plan
(`specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md`)
has a `## Territory Contract` table (lines 189-209) instead of per-phase `Files to modify`
blocks. The table's "Ownership" rows already enumerate the real file set:

| Ownership | Paths |
|---|---|
| Exclusive to this task (new) | `Verified/Internalize.lean`; `Verified/Refutation/Rules/TemporalAssets.lean`; `Verified/Refutation/Rules/Propositional.lean`; `Verified/Refutation/Rules/Modal.lean`; `Verified/Refutation/Rules/Temporal.lean` |
| Pre-authorized overflow (conditional) | `Verified/Internalize/*.lean` (only if `Internalize.lean` exceeds ~900 lines) |
| Shared, append-only | `FormalSystem/Metalogic/Decidability.lean` |
| Read-only (do not edit) | `Tableau.lean`, `SignedFormula.lean`, `Verified/RuleSpec.lean`, `Verified/Decidable.lean`, `FormalSystem/Theorems/**`, `FormalSystem/ProofSystem/**` |
| Other tasks' territory | (named boundary-note paths, not this task's) |

The dispatch's own phrasing — "confirm a re-run of the harvest on a *repaired plan* produces a
non-empty scope" — matches this: the regression fixture is retrofitting #410's plan with
per-phase `Files to modify` blocks (the five "Exclusive to this task" paths at minimum, plus the
append-only `Decidability.lean` import line, which is a real per-phase edit even though it is not
a "new" file), then re-running `plan-file-scope-harvest.sh` directly against the repaired file to
confirm non-empty output, and finally running `backfill-file-scope.sh` (or the equivalent
`update-task-status.sh` call) to actually write `file_scope` into `state.json`. The conditional
overflow path (`Verified/Internalize/*.lean`) is a judgment call for the plan phase: `file_scope`
is documented as "prospective, not filesystem-validated" (state-management-schema.md), so
including it is defensible, but it is genuinely conditional ("MAY split") rather than certain,
unlike the other five paths.

### External Resources

None consulted — this is a pure codebase-mechanics task with no external library or API surface
involved.

## Recommendations

1. Add a per-phase "Files to modify" presence check inside `validate-artifact.sh`'s existing
   plan-mode per-phase loop (lines 298-328), reusing `phase_line_nums`/`phase_block`/`phase_num`
   already computed there for the Verification Tier check — no new file-scan pass, no new shared
   library. Test the header-presence grep against both accepted punctuation forms
   (`**Files to modify**:` / `**Files to modify:**`), consistent with plan-format.md's
   "Field-punctuation tolerance" rule and the harvester's own accepted grammar.
2. Decide the severity tier against the measured population (1 of 16 active plans missing the
   field, vs. 130 of ~971 archived plans missing it) rather than defaulting reflexively to the
   `Verification Tier` precedent's advisory-first posture — that precedent was chosen specifically
   because its active-plan gap was large at the time; this field's active-plan gap is nearly
   closed already. Whatever tier is chosen, document an explicit "Enforcement level" /
   "Promotion criterion" note in plan-format.md mirroring the existing Verification Tier
   subsection, so a future reader does not need to re-derive the rationale.
3. Do not change `plan-file-scope-harvest.sh`'s return contract (`[]` stays a normal, non-error
   outcome for both "no block" and "block, no paths") — that keeps all seven existing callers and
   two test suites unaffected. Let `validate-artifact.sh`'s new check (recommendation 1) be the
   sole surface that distinguishes "no block in phase N" from the legitimate "none planned"
   sentinel case demonstrated live in task #750's plan.
4. Repair #410's plan by adding per-phase `Files to modify` blocks derived from its existing
   `## Territory Contract` table (the five "Exclusive to this task (new)" paths at minimum,
   `FormalSystem/Metalogic/Decidability.lean` on whichever phase adds the import line), then
   re-run `plan-file-scope-harvest.sh` directly against the repaired file to confirm non-empty
   JSON output, then write the result into `state.json#active_projects[].file_scope` via the
   existing `backfill-file-scope.sh` (real run, not `--dry-run`) or
   `update-task-status.sh --file-scope-add`, whichever the plan phase judges cleaner. Treat the
   conditional `Verified/Internalize/*.lean` overflow path as a plan-phase judgment call, not a
   pre-made decision.
5. Add fixtures to `scripts/tests/test-validate-artifact.sh` for the new check, following the
   existing `make_plan_fixture` pattern (lines 105-146): (a) a phase block with no `Files to
   modify` header at all → expect the new finding; (b) a phase block with the header and a "none
   planned" sentinel line (mirroring task #750's live shape) → expect no finding; (c) a phase
   block with the header and at least one `` - `path` `` entry → expect no finding (baseline
   pass). This exercises exactly the SCOPE-3 distinction without touching the harvester's test
   suite.

## Decisions

- Confirmed the check belongs in `validate-artifact.sh`'s existing per-phase loop, not as a new
  script or a new library — this was explicitly scoped as a "decide where" item and the codebase
  evidence makes the site unambiguous.
- Confirmed the harvester's `[]`-is-normal contract should NOT change; the no-block-vs-empty-block
  distinction is validate-artifact.sh's responsibility, consistent with keeping
  `update-task-status.sh`'s union-merge semantics untouched (an explicit NON-GOAL).
- Confirmed the regression fixture path is "repair #410's plan, then re-harvest" (per the
  dispatch's own wording), not a direct hand-edit of `file_scope` in `state.json` — the latter
  would bypass the very harvest mechanism this task is validating.

## Risks & Mitigations

- **Risk**: Landing the new check at `log_error` by default could newly fail #410's plan validation
  mid-fix, before the plan repair (recommendation 4) lands, if the two land in different commits.
  **Mitigation**: sequence the plan repair commit before (or atomically with) the validator change
  in the implementation plan's phase ordering, or land the validator change as `log_warn` first
  with the promotion documented as a fast-follow once #410 is the last offender.
- **Risk**: A future generator or hand-authored plan could render "Files to modify" under a
  heading depth or wrapping this research did not exercise (e.g., inside a nested list under a
  numbered sub-phase like `3a`). **Mitigation**: the new check should run inside the same
  `phase_block` window the Verification Tier check already uses, which is already proven against
  the plan corpus's actual heading variety (non-conforming headings are a separate, already-warned
  condition at lines 281-296).
- **Risk**: Backfilling #410 by editing its plan retroactively could be read as rewriting
  implementation history. **Mitigation**: this is explicitly sanctioned by the dispatch as "the
  regression fixture," and `no-record-versioning-in-deliverables.md`'s exemptions permit
  `specs/**` artifacts (task plans) as the primary exemption zone for this kind of edit.

## Context Extension Recommendations

- **Topic**: plan-format.md's "Enforcement level" pattern.
- **Gap**: The existing "Enforcement level" / "Promotion criterion" subsection pattern (used for
  `Verification Tier`) is a reusable template for any future REQUIRED-but-advisory field, but
  nothing currently documents it as a reusable pattern — each field's subsection is written as if
  novel.
- **Recommendation**: When this task's plan lands its own "Enforcement level" note for `Files to
  modify`, consider cross-referencing the `Verification Tier` subsection explicitly as "the same
  pattern" rather than restating the rationale from scratch, so a future third field can find both
  precedents in one place.

## Appendix

- Search queries / commands used:
  - `grep -n "files to modify\|files_to_modify" scripts/validate-artifact.sh` (zero hits, confirms EVIDENCE 2)
  - `for f in specs/*/plans/*.md specs/archive/*/plans/*.md; do grep -qi "files to modify" "$f" || echo "$f"; done` (131/1098 sweep)
  - `for f in specs/[0-9]*/plans/*.md; do grep -qi "files to modify" "$f" || echo "$f"; done` (1/16 active-plan sweep)
  - `bash scripts/plan-file-scope-harvest.sh specs/750_.../plans/01_w-run-layer-ladder-scheme.md` (confirmed live "none planned" phase contributes nothing while the plan's other phases still populate a non-empty result)
  - `grep -rl plan-file-scope-harvest.sh` (confirmed the harvester's seven callers plus two test suites)
- References: `context/formats/plan-format.md` (lines 95-160, 393-404), `scripts/validate-artifact.sh`
  (lines 36-62, 194-329), `scripts/plan-file-scope-harvest.sh` (full file), `scripts/backfill-file-scope.sh`
  (full file), `scripts/tests/test-validate-artifact.sh` (full file), `specs/410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md`
  (lines 189-258), `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md`
  (lines 520-530).
