# Research Report: Task #731

**Task**: 731 - Make plan-time file_scope harvest include the generated surfaces that any .lean edit forces
**Started**: 2026-10-10T00:00:00Z
**Completed**: 2026-10-10T00:00:00Z
**Effort**: ~1 research dispatch
**Dependencies**: None
**Sources/Inputs**: Codebase (`scripts/check-module-invariants.sh`, `scripts/typst-sync-check.sh`, `scripts/typst-status-counts.sh`, `scripts/typst-module-map.sh`, `scripts/lib/live_walk.py`, `.claude/scripts/plan-file-scope-harvest.sh`), task 749/750 plans/summaries/issue logs, `git log -p`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- A `.lean` edit that changes a file's line count (or adds/removes a file) forces staleness in
  two independent generated-surface families, discovered by reading the generators rather than
  by enumerating from memory: (1) `typst/generated/status.typ`, whose `FORMALSYSTEM_FILE/LINE_COUNT`,
  `TESTS_FILE/LINE_COUNT` and `TOOLS_FILE/LINE_COUNT` fields cover the *entirety* of `FormalSystem/`,
  `Tests/` and `BimodalTools/` respectively (not just `Metalogic/`, contrary to a narrower reading of
  one comment in the generator); and (2) the ~36 README.md files repo-wide that register
  `<!-- BEGIN GENERATED: inventory dir=X --> ... <!-- END GENERATED -->` blocks via
  `check-module-invariants.sh --emit-inventory`.
- The README-inventory surface is **not** a fixed 2-file set. It is directory-ancestor-chain
  dependent: for an edited `.lean` file at directory `D`, every README.md anywhere in the repo that
  registers `dir=A` for `A` in `{D, parent(D), grandparent(D), …, repo root}` can go stale — because
  `rows=subdirs`/`rows=totals` blocks aggregate line counts *recursively* over their `dir=`'s whole
  subtree (`live_walk.py`'s `live_files()` is `os.walk`-recursive), and because at least one block
  (`FormalSystem/README.md`'s `dir=FormalSystem rows=loose`) carries a hand-pinned row for a file
  *outside* its own scanned directory (`../FormalSystem.lean`, the repo-root Lake aggregator). A
  simple **ancestor-chain membership test** (collect every README registering `dir=A` for any `A` in
  the edited file's self-or-ancestor directory chain) reproduces, without needing to know *why*
  each block is sensitive, the exact 3-README set (`README.md`, `FormalSystem/README.md`,
  `FormalSystem/Metalogic/README.md`) that task 750 actually had to regenerate.
- Two further generated surfaces exist but are **narrowly, not universally, scoped** and should be
  appended conditionally rather than unconditionally: `typst/generated/automation-module-map.typ`
  (Check 2b — only `FormalSystem/Automation/{Tactics,ProofSearch}/*.lean` and
  `SuccessPatterns.lean`) and `typst/generated/machine-appendix.{jsonl,typ}` (Check 3 — tied to the
  `Axiom`/`DerivationTree` constructor blocks and requiring a Lean-interpreter run, not a plain
  line-count scan).
- Recommended mechanism: extend `plan-file-scope-harvest.sh` itself (the mechanical option the
  dispatch prefers), as a post-processing step that fires only when (a) the harvested path list
  contains at least one `.lean` path, and (b) `scripts/check-module-invariants.sh` and
  `scripts/typst-sync-check.sh` exist at the repo root (satisfying the "don't break sibling repos"
  non-goal). Because this script is the single subprocess four independent call sites already
  shell out to (`orchestrator-postflight.sh`, `reconcile-task-status.sh`, `skill-base.sh`,
  `skill-reviser/SKILL.md`), fixing it once propagates to all four without touching any of them.
- Verified against the two precedent tasks directly: running the **current, unmodified** harvester
  against both tasks' plans confirms the gap — neither output contains `status.typ` or any
  generated README — establishing the exact before-state the planning/implementation phase must
  turn into an after-state containing them.

## Context & Scope

Two independently completed tasks (749, 750) hit the same class of problem: a plan that touches
`.lean` files but does not declare the generated surfaces that `.lean` edits mechanically force,
tripping either the `typst-sync-check.sh --counts-only` pre-commit gate or
`check-module-invariants.sh`'s INV check mid-implementation. Task 731 asks for the generated-surface
set to be identified by reading the generators (not from memory), and for a mechanism — preferably
`plan-file-scope-harvest.sh` itself — to append these surfaces automatically whenever a plan's
harvested scope contains a `.lean` path. Non-goals: no change to the generators' behavior or output,
no change to the pre-commit gate, no retroactive edit to 749/750's own `file_scope`.

## Findings

### Codebase Patterns

**The harvester and its call sites.** `.claude/scripts/plan-file-scope-harvest.sh` is a pure
text-parsing script: given a plan file path, it unions every phase's `**Files to modify**` block
into a deduplicated, sorted JSON array, with zero filesystem access beyond the plan file itself (the
script's own test suite comments on this explicitly: "no REPO_ROOT dependency... no bogus-root
risk"). Four call sites shell out to it as a subprocess rather than re-implementing extraction:
`orchestrator-postflight.sh` (Stage 7, plan postflight, `--file-scope-add`), `reconcile-task-status.sh`,
`skill-base.sh` (plan postflight path), and `skill-reviser/SKILL.md` (Stage 8). All four invoke it
as `bash .claude/scripts/plan-file-scope-harvest.sh "$artifact_path"` from a repo-root-anchored
shell context. Extending the harvester itself — rather than any one caller — is therefore the
single-point fix the dispatch asks to prefer.

**Precedent 1 — task 749** (`specs/749_c_bound_half_model_a_presentation_size/`). Its plan's
`Files to modify` lists never mention `typst/generated/status.typ` or any README. Its own issue log
(`issues.jsonl`, dispatch_seq 4) records: *"INV's generated inventory blocks go stale with every
line-count change and must be re-emitted before the final gate"* — discovered live, mid-implementation.
The completion summary's "What Changed" section ends with: *"`README.md`,
`FormalSystem/Metalogic/README.md` — generated inventory blocks re-emitted;
`typst/generated/status.typ` regenerated by the pre-commit hook's remedy."* `git log -p -- FormalSystem/README.md`
confirms task 749's phase-8 commit (`5ce531788`) *also* touched `FormalSystem/README.md` (a pinned
`../FormalSystem.lean` line-count bump, 672→673) even though neither the dispatch's own ADVISORY
quote nor the summary's "What Changed" list names it — see the Risks section's open question.

**Precedent 2 — task 750** (`specs/750_w_run_layer_closure_wide_lift/`). Its issue log (dispatch_seq
6) records the *status.typ* side of the problem explicitly: *"Phase 1 commit blocked by the
typst-sync pre-commit gate (status.typ file/line counts drift from the new RunLayer.lean); remedied
by `scripts/typst-sync-check.sh --fix`... the plan's Files-to-modify list for Phase 1 omits this
generated file."* Its completion summary's "What Changed" section separately records the README
side: *"Generated files refreshed by their own generators because the gates demanded it:
`typst/generated/status.typ`... and the generated inventory blocks of `README.md`,
`FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`."* Its Plan Deviations section
explicitly calls out `typst/generated/status.typ` as "a generated file the plan's file lists omit."

**Reading the generators (scope item 1 — the complete surface set).**

1. `typst/generated/status.typ`, generated by `scripts/typst-status-counts.sh` and checked by
   `scripts/typst-sync-check.sh` Check 2 / `--counts-only` (the pre-commit gate). Its fields and
   their exact dependency scope, read directly from the generator:
   - Axiom-constructor and frame-class-tier counts (`AXIOM_COUNT`, `DENSE_ONLY_COUNT`,
     `ZTIME_ONLY_COUNT`, `RTIME_ONLY_COUNT`, `BASE_COUNT`) and the `DerivationTree` rule count
     (`RULE_COUNT`) — scoped to `FormalSystem/ProofSystem/Axioms.lean` and `.../Derivation.lean`
     only.
   - Sorry counts — scoped to `Metalogic/**/*.lean` (per the generator's own methodology comment).
   - `FORMALSYSTEM_FILE_COUNT`/`FORMALSYSTEM_LINE_COUNT` — **all** of `FormalSystem/`, recursively.
   - `TESTS_FILE_COUNT`/`TESTS_LINE_COUNT` — **all** of `Tests/`, recursively.
   - `TOOLS_FILE_COUNT`/`TOOLS_LINE_COUNT` — **all** of `BimodalTools/`, recursively.
   - `FORMALSYSTEM_IMPORT_COUNT` — `FormalSystem.lean`'s own import-line count.

   Because of the three whole-tree `FILE_COUNT`/`LINE_COUNT` pairs, `status.typ` is forced by **any**
   line-count-changing or file-count-changing edit under `FormalSystem/`, `Tests/`, or
   `BimodalTools/` — which in this repository is the near-totality of `.lean` edits a plan would
   ever declare. This fully supports the dispatch's claim for this surface specifically.

2. The README generated-inventory blocks, generated/checked by
   `scripts/check-module-invariants.sh --emit-inventory` (INV check). `grep -rl "BEGIN GENERATED:
   inventory" --include="*.md" .` finds **36 README.md files** carrying such blocks (plus one
   `INVENTORY: hand-maintained` opt-out at `FormalSystem/Semantics/README.md`), spanning the whole
   tree including `Boneyard/`, `BimodalTools/`, and `Tests/BimodalToolsTest/`. Each block's `dir=`
   option names the directory it covers; `rows=` selects `loose` (files directly in `dir=`),
   `subdirs` (one row per immediate subdirectory, with its line/file total computed by
   `live_files()` — confirmed **recursive**, via `os.walk`, in `scripts/lib/live_walk.py`), `both`,
   or `totals` (directory-wide rollup). The trailing hand-written description column is pinned by
   row key and survives regeneration, including rows that cite a path *outside* the scanned
   directory (the comment calls this out explicitly: `"../FormalSystem.lean"` is kept as a pinned
   row with its numbers refreshed) — this is exactly how `FormalSystem/README.md`'s `dir=FormalSystem
   rows=loose` block (which only lists files *directly inside* `FormalSystem/`) ends up sensitive to
   edits of the repo-root `FormalSystem.lean` aggregator file.

   The practical consequence: there is no fixed 2-file list. The correct superset for an edited
   `.lean` path `P` is every README registering `dir=A` for `A` ranging over `P`'s own directory and
   every ancestor directory up to the repo root. This research verified the heuristic directly: for
   `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (task 750's new file), the
   ancestor chain is `RaySummary → Decidability → Metalogic → FormalSystem → root`; grepping for
   `dir=` registrations at each level finds `FormalSystem/Metalogic/README.md` (`dir=FormalSystem/Metalogic`,
   three blocks), `FormalSystem/README.md` (`dir=FormalSystem`, one block, the pinned-row block
   above), and root `README.md` (`dir=FormalSystem rows=totals`) — **exactly** the three READMEs
   task 750's summary records as regenerated, with no false positives (no block exists for `dir=
   FormalSystem/Metalogic/Decidability` or `dir=FormalSystem/Metalogic/Decidability/RaySummary`, so
   the chain correctly stops contributing noise at the two innermost levels, which is also why
   `RaySummary/README.md` was already hand-declared in the plan rather than mechanically forced).

3. Two further generated surfaces exist, both read directly out of `typst-sync-check.sh`'s own
   Check 2b/Check 3, that the dispatch's "at minimum" list did not name and that are genuinely
   *not* forced by "any" `.lean` edit:
   - `typst/generated/automation-module-map.typ` (Check 2b), generated by
     `scripts/typst-module-map.sh`. Its own header comment states the glob scope explicitly:
     `FormalSystem/Automation/Tactics/*.lean`, `FormalSystem/Automation/ProofSearch/*.lean`, and
     `FormalSystem/Automation/SuccessPatterns.lean` only (never `Boneyard/`). A `.lean` edit outside
     that narrow glob cannot make this surface stale.
   - `typst/generated/machine-appendix.jsonl` / `.typ` (Check 3), generated by
     `scripts/typst-machine-appendix.sh`. Unlike the build-free generators above, this one runs the
     Lean *exporter* through `lake env lean --run` (needs a built `.olean` for
     `BimodalTools.MachineAppendixMain`) and recounts the `Axiom`/`DerivationTree` constructor
     blocks it serializes — the same structural dependency as `status.typ`'s axiom/rule counts, not
     a line-count dependency. It drifts only on axiomatization-structure changes, not on ordinary
     line-count edits, and is materially costlier to regenerate (a build, not a `wc -l`).

### External Resources

None consulted; this is a purely internal, codebase-mechanics question with no external
documentation surface.

## Recommendations

1. **Mechanism**: extend `.claude/scripts/plan-file-scope-harvest.sh` with a post-processing step
   appended after the existing `extract_paths | jq ... unique` pipeline — not a plan-template
   checklist item. The dispatch's own evidence (the checklist was tried once, on task 750, and did
   not prevent task 750's *other* generated surface from recurring) is a direct argument against
   relying on a checklist a second time. Because all four call sites subprocess this one script,
   fixing it here is the single point of leverage; no caller needs to change.
2. **Gate the whole addition** on repo capability, not on task type: before doing anything else, the
   added logic should check for `scripts/check-module-invariants.sh` and
   `scripts/typst-sync-check.sh` at the repo root (resolved relative to wherever the script
   determines "repo root" to be — see Risks below for why this is a new dependency the script does
   not have today). If either is missing, skip the addition entirely and return exactly what the
   harvester already returns — this satisfies the "do not break sibling repos lacking these
   generators" non-goal without needing any repo-identity flag or config file.
3. **Within that gate**, when the harvested array contains at least one path matching `*.lean`:
   - Append `typst/generated/status.typ` unconditionally (subject only to it existing on disk) —
     justified by the three whole-tree `FILE_COUNT`/`LINE_COUNT` pairs found in finding 1 above,
     which make this surface sensitive to virtually every `.lean` edit under `FormalSystem/`,
     `Tests/`, or `BimodalTools/`.
   - For each harvested `.lean` path, compute its directory and walk ancestors up to the repo root;
     for each ancestor `A` (self included), find every README.md anywhere in the repo whose
     `BEGIN GENERATED: inventory` marker's `dir=` value equals `A` (string equality on the `dir=`
     token, not a path-prefix test — `check-module-invariants.sh`'s own marker parsing is the
     reference implementation to mirror), and append the containing README's path. This needs no
     per-block `rows=` reasoning (finding 2's walkthrough shows the plain ancestor-chain test
     already reproduces the exact observed 3-README set, including the pinned-row edge case, without
     the extension needing to know that edge case exists).
   - Optionally, and lower-priority (neither precedent task's issue log mentions either), append
     `typst/generated/automation-module-map.typ` only when a harvested path matches
     `FormalSystem/Automation/Tactics/*.lean`, `FormalSystem/Automation/ProofSearch/*.lean`, or
     equals `FormalSystem/Automation/SuccessPatterns.lean`; and/or `typst/generated/machine-appendix.{jsonl,typ}`
     only when a harvested path is `FormalSystem/ProofSystem/Axioms.lean` or `.../Derivation.lean`.
     These two are genuinely conditional (narrow glob match, not "any `.lean` edit") and heavier to
     regenerate (machine-appendix needs a build); the planning phase should decide whether the
     marginal benefit (closing a theoretical third/fourth recurrence) justifies the added complexity
     given neither has actually recurred yet.
4. **Verification path for the plan/implementation phase** (mirrors the dispatch's scope item 4):
   re-run the updated harvester against
   `specs/749_c_bound_half_model_a_presentation_size/plans/01_c-bound-half-model-a.md` and
   `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md` and confirm the
   output now includes `typst/generated/status.typ`, `README.md`, `FormalSystem/README.md`, and
   `FormalSystem/Metalogic/README.md` for both (this research already confirms the **current**
   harvester output lacks all four for both plans — see Appendix). No retroactive edit to either
   task's own `file_scope` is in scope (non-goal); this is a harvester regression-fixture check,
   not a state mutation.
5. Add (or extend) a fixture case in `.claude/scripts/tests/test-plan-file-scope-harvest.sh`
   covering: a plan whose only `Files to modify` entry is a `.lean` path under a directory with a
   multi-level ancestor-chain of registered README blocks, asserting the exact expected append set;
   and a plan with no `.lean` path at all, asserting no surfaces are appended (regression guard
   against over-firing on `general`/`markdown`/`meta` tasks that happen to list a `.md` file).

## Decisions

- Prefer extending `plan-file-scope-harvest.sh` directly over a plan-template checklist item, per
  the dispatch's own stated preference and the task-750 evidence that the checklist approach, once
  tried, did not prevent the next occurrence.
- Treat the README generated-inventory surface as directory-ancestor-chain-dependent, not as a
  fixed file list — the two precedent tasks needed different-sized sets (749's own summary names
  2 READMEs in its "What Changed" prose though `git log` shows a 3rd was also touched; 750's summary
  names 3), and a fixed list would have been wrong for at least one of them.
- Treat `automation-module-map.typ` and `machine-appendix.{jsonl,typ}` as conditional, narrow-glob
  surfaces to be appended only on a path-glob match, not unconditionally alongside `status.typ` —
  neither is forced by "any" `.lean` edit, and neither has actually recurred as an undeclared-scope
  incident in the two precedents, unlike `status.typ` and the README blocks.
- Do not attempt to replicate `check-module-invariants.sh`'s full `rows=`/`cols=` semantics inside
  the harvester; the plain ancestor-chain `dir=` membership test is simpler, is proven against the
  two precedents in this report, and over-inclusion in `file_scope` is cost-free (the field is
  documented as prospective/non-validated, not filesystem-verified).

## Risks & Mitigations

- **New REPO_ROOT dependency.** `plan-file-scope-harvest.sh` currently has zero filesystem
  dependency beyond the single plan-file argument (its own test suite comments on this as a
  deliberate simplicity property: "no bogus-root risk"). Adding a repo-wide `grep` over README.md
  files and an existence check for two `scripts/*.sh` paths introduces a real repo-root resolution
  need. *Mitigation*: all four current call sites already invoke the harvester from a repo-root-anchored
  shell context (`bash .claude/scripts/plan-file-scope-harvest.sh "$artifact_path"`), so the simplest
  correct choice is to resolve repo root the same way sibling scripts in `.claude/scripts/` already
  do (`git rev-parse --show-toplevel`, falling back gracefully to "skip the addition" if that fails
  — consistent with the sibling-repo non-goal) rather than threading a new CLI flag through every
  caller.
- **Cost of a repo-wide grep on every harvest call.** Scanning ~36+ markdown files for `BEGIN
  GENERATED: inventory` markers on every plan-postflight/reconcile/reviser invocation is cheap
  (`grep -r` over markdown text, no build, sub-second) but is new work the script did not do before.
  *Mitigation*: the scan only runs when the harvested scope already contains a `.lean` path (most
  plans for `general`/`markdown`/`meta` tasks will short-circuit before it), and grep over text
  files at this repo's size is not a measurable performance concern relative to the lake-build-backed
  gates this harvester output ultimately feeds.
- **Open question, non-blocking**: this research could not fully reconcile why the dispatch's quoted
  postflight ADVISORY for the second precedent names only 2 files
  (`FormalSystem/Metalogic/README.md`, `README.md`) when `git log` shows 3 READMEs were actually
  touched in that task's commits (also recorded in a non-fatal issue-log entry for this dispatch).
  Plausible explanations include the ADVISORY comparing against the implementer's *self-reported*
  `modified_files` list rather than the actual git diff, or `FormalSystem/README.md` having entered
  declared scope through some other route by the time of that comparison. Does not affect the
  recommendation (the ancestor-chain heuristic safely produces the superset either way) but the
  planning phase should not treat "exactly 2 files" as a literal acceptance criterion if it chooses
  to mirror the ADVISORY's wording anywhere.

## Context Extension Recommendations

None — this is a `meta` task; per this agent's Stage 4.5 instruction, this section is set to none
for meta tasks.

## Appendix

### Search queries / commands used

- `grep -rl "BEGIN GENERATED: inventory" --include="*.md" .` / `grep -rl "INVENTORY: hand-maintained" --include="*.md" .`
- `grep -n "BEGIN GENERATED: inventory" README.md FormalSystem/README.md FormalSystem/Metalogic/README.md`
- `sed -n` ranges over `scripts/check-module-invariants.sh` (`--emit-inventory` header, `scan()`),
  `scripts/typst-sync-check.sh` (header, Check 2/2b/3 bodies), `scripts/typst-status-counts.sh`
  (field derivations), `scripts/typst-module-map.sh` (glob-scope header), `scripts/typst-machine-appendix.sh`
  (header), `scripts/lib/live_walk.py` (`live_files`/`live_loose_files`/`live_subdirs`)
- `bash .claude/scripts/plan-file-scope-harvest.sh specs/749_.../plans/01_c-bound-half-model-a.md`
  and the same for `specs/750_.../plans/01_w-run-layer-ladder-scheme.md` (current-behavior baseline,
  confirming neither output contains `status.typ` or any README)
- `git log --oneline --all -- FormalSystem/README.md` and `git log -p --follow -3 -- FormalSystem/README.md`
  (confirmed the pinned `../FormalSystem.lean` row mechanism and that task 749's and 750's commits
  both touched this file)
- `grep` over `specs/749.../issues.jsonl` and `specs/750.../issues.jsonl` for the two tasks'
  own live-discovered issue-log entries documenting each generated-surface gate collision

### Current (pre-fix) harvester output, for the record

- `specs/749_c_bound_half_model_a_presentation_size/plans/01_c-bound-half-model-a.md` →
  `["FormalSystem/Metalogic/Decidability/RaySummary.lean", "FormalSystem/Metalogic/Decidability/RaySummary/Compose.lean", "FormalSystem/Metalogic/Decidability/RaySummary/README.md", "FormalSystem/Metalogic/Decidability/RaySummary/Trace.lean", "FormalSystem/Metalogic/Decidability/RaySummary/Transport.lean", "Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean", "docs/theorem-index.md", "scripts/check-evidence-probes.sh", "scripts/check-module-invariants.sh", "specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean", "specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean"]`
  — no `status.typ`, no README.
- `specs/750_w_run_layer_closure_wide_lift/plans/01_w-run-layer-ladder-scheme.md` →
  `["FormalSystem.lean", "FormalSystem/Metalogic/Decidability/RaySummary.lean", "FormalSystem/Metalogic/Decidability/RaySummary/README.md", "FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean", "Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean", "docs/theorem-index.md", "scripts/check-evidence-probes.sh", "scripts/check-module-invariants.sh", "specs/evidence/seam-gluing-ray-product/deadline-ladder-branching.lean"]`
  — no `status.typ`, no generated README (only the hand-authored `RaySummary/README.md`).
