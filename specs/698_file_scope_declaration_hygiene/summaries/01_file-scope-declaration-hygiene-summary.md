# Implementation Summary: Task #698

- **Task**: 698 - file_scope_declaration_hygiene
- **Status**: [COMPLETED]
- **Started**: 2026-09-29T05:06:00Z
- **Completed**: 2026-09-29T05:35:00Z
- **Effort**: ~35 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_file-scope-declaration-hygiene.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Repaired `specs/state.json`'s `file_scope` declarations so that `scripts/validate-state.sh`'s
Check 8 (coarse whole-directory declarations) and Check 9 (intra-array duplicates) stop reporting
findings the cross-task admission gate silently tolerated. Fixed project 178's exact-duplicate
entry, narrowed the three inherited `BimodalTools/` blanket declarations on 282/296/298 to their
evidenced surfaces, justified project 177's remaining whole-directory claim and closed its one real
dependency gap (696), re-verified shared gate/tooling script declarations (no change needed), and
ran a full residue re-check reporting every remaining non-dependency-gated overlap and the named
out-of-repo enforcement follow-on.

## What Changed

- `specs/state.json` — project 178: doubled `FormalSystem/Examples/` collapsed to one entry.
- `specs/state.json` — projects 282, 296, 298: inherited `BimodalTools/` + `FormalSystem/Automation/`
  + `Tests/BimodalToolsTest/` triad replaced with each task's own evidenced surface (296:
  `FormulaEnumerator.lean`, `AtomCanonicalization.lean`, `EnumeratorCountsTest.lean`; 298:
  `DatasetGenerator.lean`, `DatasetGeneratorTest.lean`; 282: triad dropped, added
  `scripts/run_dataset_generation.sh`). Each description gained a dated `SCOPE NARROWED
  (2026-09-28)` note.
- `specs/state.json` — project 177: `FormalSystem/Metalogic/Decidability/` whole-directory entry
  retained with an inline `FURTHER EDGES (2026-09-28)` justification; `696` added to
  `dependencies`, closing the one un-gated overlap of the 8 Check 8 reported.
- `specs/698_file_scope_declaration_hygiene/plans/01_file-scope-declaration-hygiene.md` — every
  phase checklist item checked off with completion/deviation annotations; all 5 phase headings
  marked `[COMPLETED]`.
- `specs/698_file_scope_declaration_hygiene/progress/phase-{1..5}-progress.json` — created,
  recording objectives, deviations, and (Phase 4/5) classification and residue tables.
- `specs/698_file_scope_declaration_hygiene/handoffs/phase-{1..4}-handoff-*.md` — progressive
  phase-end handoffs.
- `specs/TODO.md` — regenerated from `specs/state.json` (not staged by this task's own commits;
  carries this cycle's concurrent-sibling rows).

## Decisions

- **`validate-state.sh --fix` is broken for the general case**: it crashed with `jq: error:
  Cannot iterate over null (null)` because its dedup filter runs `.file_scope |= (reduce .[]
  ...)` on every project with a `file_scope` key, unguarded against a `null` value — and 28
  non-terminal projects (e.g. 412, 125) have `file_scope: null`. This is a pre-existing defect in
  the deployed `.claude/scripts/validate-state.sh`, unrelated to this task's own edits, and out of
  scope to patch here (`.claude/**` is a disposable deploy artifact per
  `.claude/rules/source-store-deploy-boundary.md`). `state-write.sh` correctly aborted and left
  `specs/state.json` untouched — no corruption occurred. Substituted an equivalent,
  project-178-scoped, null-safe dedup filter applied directly via `state-write.sh` (still the
  sanctioned mutex-guarded writer, not a hand-edit), verified by Check 9 PASS and `jq empty`. This
  `--fix` null-guard bug itself is worth a small follow-up fix in the source store, separate from
  the postflight-enforcement follow-on this task's description names (see Follow-ups below).
- Applied Phase 2's three narrowings (282, 296, 298) in a single `state-write.sh` call using a
  project-number-branched `map(if .. elif .. elif .. else . end)` filter — still one
  mutex-guarded write, not three.
- Used `validate-state.sh --deep` (not the plain invocation) to confirm no dependency cycle after
  adding the 177→696 edge — the plain run has no cycle-detection check at all; it only exists
  under `--deep`.

## Plan Deviations

- **Phase 1, task 1.3** (altered): ran `validate-state.sh --fix` as written; it crashed on an
  unrelated null-value defect (see Decisions above). Applied the semantically identical,
  project-178-scoped filter via `state-write.sh` directly instead of the general `--fix` wrapper.
- **Phase 4, task 4.6** (skipped): no declaration needed to change after re-verification (all
  candidates besides 695/696, which already declare the shared script, are GATE relationships),
  so no commit was made — the phase's own hypothesized zero-change outcome, confirmed.
- **Phase 5, task 5.8** (skipped): the residue re-check surfaced one new, un-dependency-gated
  overlap (464 vs 481) but no research grounds a dependency edge between them the way 177→696 was
  grounded; reported as residue rather than repaired by guessing. No `specs/state.json` delta was
  pending, so no commit was made this phase.

## Verification

- Build: N/A (no Lean source touched)
- Tests: N/A
- Check 8 / Check 9: PASS as follows —

  | Check | Before | After |
  |-------|--------|-------|
  | Check 8 (coarse) | 4 findings: 177, 282, 296, 298 | 1 finding: 177 (justified inline) |
  | Check 9 (duplicate, Class A) | 1 finding: 178 | 0 findings — `No duplicate file_scope entries found` |

  Before/after diff of the Check 8 + Check 9 finding lines shows only 4 removals, zero additions.
- `validate-state.sh --deep`: `No dependency cycles detected among active_projects` (PASS), after
  adding the 177→696 edge.
- `jq empty specs/state.json` succeeded after every phase.
- The 10 pre-existing schema FAILs (unknown top-level/entry fields) are unchanged before/after —
  neither fixed nor worsened, as required.
- Non-terminal task count unchanged at 50 before/after.
- No declaration was widened: every touched project's post-state `file_scope` is a subset of its
  pre-state coverage, except the two named specific-file additions on named evidence (282's
  `scripts/run_dataset_generation.sh`; Phase 4 added nothing).
- `bash .claude/scripts/check-task-references.sh`: exits 1 on 198 pre-existing, unrelated
  occurrences repo-wide (zero attributable to this task's own commits — both touched paths,
  `specs/state.json` and `specs/698_.../**`, are `specs/**`-exempt by the lint's own carve-out).
  Pre-existing condition, not introduced or worsened by this task; matches the gap 177's own
  description (item C4) already names.
- Every commit's `git show --stat` lists only `specs/state.json` (state-mutating phases) or only
  this task's own `specs/698_.../**` artifacts (progress/handoff commits); every `state.json`
  commit body carries the `--honest-index-rows 698` addendum since concurrent siblings (695, 697,
  699, 700, 702) rode along in the same shared file this cycle.

## Phase 4 Classification Table (EDIT vs GATE for `scripts/check-module-invariants.sh`)

| Candidate | Verdict | Evidence | Action |
|-----------|---------|----------|--------|
| 695 | EDIT | Commits to pinning a C2 axiom-baseline row and a `docs/theorem-index.md` row | None needed — already declares both |
| 696 | EDIT | Commits to updating C2 axiom-baseline rows and `docs/theorem-index.md` rows for `Incompleteness.lean` | None needed — already declares both |
| 700 | GATE | Description discusses making a completeness obligation "visible in `docs/theorem-index.md`", but its landed plan's own Files-to-modify list (`plan-file-scope-harvest.sh`) is confined to `specs/700_.../notes/*`, `specs/TODO.md`, `specs/state.json` — no commitment to edit that file itself | None |
| 481 | GATE | Acceptance clause: "no regression to any currently-passing check-module-invariants.sh check" | None |
| 482 | GATE | Same acceptance-clause pattern as 481 | None |
| 563 | GATE | Cites C24 (module root-closure convention) as a constraint to satisfy, not content it edits | None |
| 298 | GATE | POST-RELOCATION NOTE: "gate on the build-inclusive check-module-invariants.sh, C25" | None |
| 296 | GATE | Same POST-RELOCATION NOTE boilerplate as 298 | None |
| 282 | GATE | Same POST-RELOCATION NOTE boilerplate as 298/296 | None |
| 412 | GATE | "Verified fresh by scripts/check-module-invariants.sh C2/C3 at realignment time" — a verified-by reference | None |
| 698 (self) | N/A | This task's own description discusses the shared-script problem generally (the motivating incident); not a file_scope candidate for itself | None |

Also re-checked landed sibling plans (695, 697, 699, 700 — all planned this same cycle) via
`plan-file-scope-harvest.sh` against their declared `file_scope`: 695's harvest is a subset of its
already-declared scope (both `scripts/check-module-invariants.sh` and `docs/theorem-index.md`
present); 697's and 699's harvests name neither file, consistent with their `file_scope`s; 700's
harvest confirmed no gap (above). No sibling plan surfaced an undeclared shared-script edit.

## Residue (reported, not silently absorbed)

**Non-dependency-gated overlapping pairs** (via the canonical `scopes_overlap_first` predicate
from `.claude/scripts/lib/file-scope-overlap.sh`, run against all 50 non-terminal tasks):

| Pair | Shared path | Classification |
|------|-------------|-----------------|
| 700 / 698 | `specs/TODO.md` (also `specs/state.json`) | Same-specific-file — sanctioned (territory contract's per-hunk staging is the designed mechanism) |
| 696 / 695 | `docs/theorem-index.md` (also `scripts/check-module-invariants.sh`) | Same-specific-file — sanctioned |
| 282 / 257 | `data/README.md` | Same-specific-file — sanctioned |
| 177 / 695 | `README.md` | Same-specific-file — sanctioned |
| 543 / 695 | `FormalSystem.lean` | Same-specific-file — sanctioned |
| **464 / 481** | `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean` | **Genuine residue**: 464 declares the whole `MintBound/` directory (which contains 481's exact file); this is a directory-vs-file overlap, not identical declarations, and sits below Check 8's default 3-distinct-task reporting threshold (only 1 other overlapping task), so it is invisible to the automated check. No research grounds a dependency edge between 464 and 481 the way 177→696 was grounded, so this is reported rather than repaired. |

- **Project 412's `file_scope` is `null`**, unchanged by this task. This outranks any coarse
  directory declaration in urgency: a missing/null declaration is invisible to
  `scopes_overlap_first` and to Check 8 alike, producing no signal at all — not even a WARN — for
  a headline tableau-decidability result (412) that is a plausible future editor of
  `check-module-invariants.sh` and `docs/theorem-index.md`.
- **28 missing-key/null-value `file_scope` visibility findings** (23 missing-key + 5 literal-null)
  remain, unchanged from research's count. This is a separately-tracked, larger class this task
  deliberately did not sweep (see Non-Goals in the plan).
- **Stale `data/*` filenames** on 282 (`data/bmlogic-c8.json`, `data/bmlogic-c9.json`) and 298
  (`data/bmlogic-c7.jsonl` vs. on-disk `data/bmlogic-c7.jsonl.zst`/`.jsonl`) are left uncorrected —
  correcting them would require guessing which artifact each task will actually write.
- **`validate-state.sh --fix`'s null-iteration crash** (see Decisions above) is itself a small,
  separate defect worth fixing in the source store, distinct from the postflight-enforcement
  follow-on below.

## Named Out-of-Repo Follow-On (must be filed in the other repository, not attempted here)

- **Repository**: `/home/benjamin/.config/nvim/agent-system` (a separate git repository with its
  own `specs/` tree).
- **File**: `extensions/core/scripts/orchestrate-cycle-postflight.sh`.
- **Block**: "WORK (h): modified_files vs file_scope excursion advisory (detection only)".
- **What's needed**: the excursion computation (comparing a dispatch's reported `modified_files`
  against the task's declared `file_scope`) already exists and is correct; only its *consequence*
  needs to change — from a stderr-only advisory with no gate, no exit-code effect, and no verdict
  effect, to an actual enforcement gate that can block or flag an overstep.
- **Constraint**: per `.claude/rules/source-store-deploy-boundary.md`, `.claude/**` in this
  repository is a disposable deploy artifact regenerated from that other repository's source
  store; this half of the fix must be raised as a task there and must not be attempted from here.

## Impacts

- The cross-task file_scope admission gate now has materially more accurate declarations to work
  from for 5 of the repository's non-terminal tasks (177 justified, 178 repaired, 282/296/298
  narrowed), directly reducing the kind of silent overstep the task description's motivating
  incident described.
- No behavior change to any script, build, or proof — this is a pure `specs/state.json` metadata
  repair task.

## Follow-ups

- File a task in `/home/benjamin/.config/nvim/agent-system` for the named postflight-enforcement
  follow-on above (the primary out-of-repo follow-on this task's description requires recording).
- Consider a small follow-up fix (in that same source-store repository, not here) for
  `validate-state.sh --fix`'s null-iteration crash: guard `.file_scope` with `// []` before the
  `reduce .[] ...` step so `--fix` works generally, not just when every project's `file_scope` is
  non-null.
- The 464/481 directory-vs-file overlap (residue, above) is a candidate for a future file_scope
  hygiene pass or for Check 8's threshold logic to also flag single-overlap directory-vs-file
  cases explicitly, since the current default-3 threshold is tuned for noise reduction on shared
  common-file overlaps, not for catching this class.
- The 28 missing-key/null-value `file_scope` findings (including 412) remain a separately-tracked,
  larger class for a future task.
- The stale `data/*` filenames on 282 and 298 remain unresolved, deferred to whichever task next
  regenerates those datasets.

## References

- Plan: `specs/698_file_scope_declaration_hygiene/plans/01_file-scope-declaration-hygiene.md`
- Research: `specs/698_file_scope_declaration_hygiene/reports/01_file-scope-hygiene-audit.md`
- Progress: `specs/698_file_scope_declaration_hygiene/progress/phase-{1..5}-progress.json`
- Handoffs: `specs/698_file_scope_declaration_hygiene/handoffs/phase-{1..4}-handoff-*.md`
