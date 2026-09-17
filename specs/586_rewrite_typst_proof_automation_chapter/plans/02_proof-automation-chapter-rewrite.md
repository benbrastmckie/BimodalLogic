# Implementation Plan: Task #586

- **Task**: 586 - Rewrite typst proof-automation chapter against the retired-tactics tree (widened: all non-`docs/` retired-tactic prose; final phase: CI wiring of `typst-sync-check.sh`)
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: None (task 591 module renames confirmed `completed`; no overlap with the rows below)
- **Research Inputs**: specs/586_rewrite_typst_proof_automation_chapter/reports/02_verified-tactic-surface-and-ci-wiring.md (primary); reports/01_retired-tactics-chapter-drift.md (superseded on numbers)
- **Artifacts**: plans/02_proof-automation-chapter-rewrite.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

The chapter `typst/chapters/p4-proof-automation.typ` describes three removed tactics
(`tm_auto`, `temporal_search`, `propositional_search`), an archived Aesop rule set, and a Module
Map whose rows name absent files with stale counts. The plan (1) builds a build-free generator for
the Automation module map and wires it into `typst-sync-check.sh` Check 2 so the table cannot
drift silently again, (2) rewrites the chapter against the live tree, rendering the Module Map
from the generated data with hand-written Role text keyed by path, (3) fixes the four other
live-tree retired-tactic prose sites plus a stale README table, and (4) wires
`typst-sync-check.sh` into CI once it exits 0.

### Research Integration

Report 02 re-measured everything on 2026-09-17: nine live modules (`Tactics/{Commands 163,
Deduction 182, Meta 99, PropDecide 158, Search 657, UserTactics 275}`, `ProofSearch/{Core 1,283,
Strategies 401}`, `SuccessPatterns 429`; 3,647 total, all sorry-free); `EFGameTactics.lean` is
331 lines under `Metalogic/WeakCanonical/` and stays out of the table; `apply_axiom`/`modal_t`/
`assumption_search` live in `UserTactics.lean`; the whole `== Aesop Integration` section should
become a retirement note citing `FormalSystem/Boneyard/RetiredTactics/README.md`; the two
`@[aesop ...]` whitelist entries become orphaned; the widened-scope sites are
`FormalSystem/Automation/README.md:84,137`, `FormalSystem/Automation/ProofSearch/README.md:19`,
`typst/chapters/p4-dual-verification.typ:36`; CI wiring is a plain step before `Report results`.

**Planner-verified correction the research did not flag (load-bearing for Phase 2).** The chapter
states `ProofSearch/Core.lean` is "the search engine `tm_auto` and its variants call into" and "what
the tactics above call". That is false in the live tree: `Tactics/Commands.lean` imports only
`Tactics/{Meta,Search,Deduction}`; `Tactics/Search.lean`'s docstring says `ProofSearch/` is "a
second, larger search engine ... only this one [`Search.lean`'s `searchProof`] is reachable from a
tactic". `ProofSearch/Core.lean`'s `boundedSearchWithProof` is consumed by
`Metalogic/Decidability/{DecisionProcedure,ProofExtraction,CancellableExpansion}.lean` (the
`decide` fast path). So the chapter describes **two** engines as one, and the "single-family
variants restrict candidate moves" paragraph in `=== Worked Invocations` describes behavior that
never existed (the weight presets were never read). `FormalSystem/Automation/ProofSearch/README.md`
"Used by: `FormalSystem.Automation.Tactics` (provides the `modal_search` search engine)" is the
same false claim and is corrected in Phase 3.

### Decision: machine-generate the Module Map (recorded)

Generate it. A hand fix has already drifted twice; the sibling
`FormalSystem/Automation/Tactics/README.md` generated inventory is accurate while the hand-written
`ProofSearch/README.md` table is 265 lines stale. Design choice (made here, documented in
`typst/SYNC-MAP.md` by Phase 1):

- **Separate generated file, separate build-free generator** — `scripts/typst-module-map.sh`
  writing `typst/generated/automation-module-map.typ`, with a `--json` mode. Rationale: the
  `status.typ` write path of `typst-status-counts.sh` requires a built library (`lake env lean` for
  the axiom report) and re-stamps the file; bolting the module map onto it would force a full
  build and a status.typ re-stamp for every module-map refresh. This mirrors the precedent of
  `generated/machine-appendix.typ` getting its own generator.
- **Rows are discovered by glob, not a fixed list**: `FormalSystem/Automation/Tactics/*.lean`,
  `FormalSystem/Automation/ProofSearch/*.lean`, `FormalSystem/Automation/SuccessPatterns.lean`
  (never `Boneyard/`). A new, renamed, or deleted module changes the live regeneration, so Check 2
  fails in CI; the chapter's Role dictionary lookup (`.at(path)`) plus a length assertion makes
  `typst compile` fail loudly locally.
- Generated columns: `(path, lines, sorry_free)`. The `Role` column stays hand-written in the
  chapter, keyed by the same path strings. Sorry detection reuses `typst-status-counts.sh`'s
  comment-stripped `\bsorry\b` methodology (factor or copy the stripping logic; do not invent a
  new one).

## Goals & Non-Goals

**Goals**:
- `bash scripts/typst-sync-check.sh` exits 0 (Checks 1, 2 incl. the new module-map sub-check, 3).
- `typst compile typst/BimodalReference.typ <scratch>.pdf` succeeds.
- Every module named in the chapter resolves to a live file whose `wc -l` matches what is printed.
- No archived declaration (`tm_auto`, `temporal_search`, `propositional_search`,
  `AesopRules.lean`, `AesopRuleSet.lean`, `Tactics/Helpers.lean`) described in the present tense
  anywhere outside `docs/` and `Boneyard/`.
- The chapter correctly distinguishes the tactic engine (`Tactics/Search.lean`) from the
  `ProofSearch/` engine used by `decide`.
- Module-map generation decision recorded in `typst/SYNC-MAP.md`.
- `typst-sync-check.sh` runs as a CI step in `.github/workflows/ci.yml`.

**Non-Goals**:
- `docs/` occurrences (owned by a separate task).
- Adding a `typst compile` CI gate (typst binary not installed in CI; out of scope).
- Merging the two search engines, or any Lean source change.
- Whitelisting any of the current violations.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line counts drift again between research and commit (Commands.lean already moved 586 -> 163 in one day) | M | M | Chapter prints counts only from the generated file; no hand-typed count survives. Header's "~4,300-line" figure is dropped in favor of prose. |
| Other chapter claims (e.g. `decide` tries the search engine first, `iddfsSearch` defaults, `SearchStats` fields) are also stale | M | M | Phase 2 verifies every retained technical claim against source (grep the named decl) before keeping it; drop rather than guess. |
| `FormalSystem/Automation/README.md:84` sits inside a `<!-- BEGIN GENERATED -->` block that a generator may rewrite | M | L | Before editing, find the block's generator (grep `BEGIN GENERATED: inventory` in `scripts/`); if the directory row is generator-emitted, fix it at the generator; run `check-module-invariants.sh` after. |
| Removing the two `@[aesop ...]` whitelist entries breaks Check 1 elsewhere | L | L | Grep `typst/` for both spans first; remove only if the chapter was the sole consumer; Check 1 run confirms. |
| Typst `.at()` / tuple-array rendering syntax errors | L | M | Model on `ax-machine-appendix.typ`'s consumption of `generated/machine-appendix.typ`; compile after each edit. |
| Task `file_scope` in state.json lists only the chapter and whitelist; this plan touches more files | L | H | Expected (widened scope). Use targeted `git add` with explicit file lists; do not use default-mode `git-snapshot.sh`. |
| CI step fails on runner due to missing python3/jq | L | L | Research confirmed both present on `ubuntu-latest`; mutation test in Phase 4 is local, CI result observed on next push by the user. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel (Phases 1 and 3 touch disjoint files).

### Phase 1: Module-map generator and Check 2 extension [NOT STARTED]

**Goal**: A build-free generator emits `typst/generated/automation-module-map.typ`, and
`typst-sync-check.sh` Check 2 fails when the committed file disagrees with a live regeneration.

**Tasks**:
- [ ] Create `scripts/typst-module-map.sh` (header comment in the style of
      `typst-status-counts.sh`): glob `FormalSystem/Automation/Tactics/*.lean`,
      `FormalSystem/Automation/ProofSearch/*.lean`, `FormalSystem/Automation/SuccessPatterns.lean`;
      for each emit path relative to `FormalSystem/Automation/`, `wc -l`, and sorry-free (comment-
      stripped `\bsorry\b` count == 0, same stripping as `typst-status-counts.sh`); sort rows
      deterministically (by path).
- [ ] Write mode: generate `typst/generated/automation-module-map.typ` with a GENERATED header,
      `#let automation-module-map = (("Tactics/Commands.lean", 163, true), ...)` and
      `#let automation-module-total = N`. No commit/date stamp (keeps the diff check exact and
      avoids stamp churn).
- [ ] `--json` mode: emit the same data to stdout only.
- [ ] Extend `scripts/typst-sync-check.sh` Check 2: if the generated file is missing -> VIOLATION
      naming the regenerate command; else parse the committed tuple array and diff against
      `typst-module-map.sh --json` (added/removed/changed rows each reported), contributing to
      `FAIL`. Update the script's header comment describing Check 2.
- [ ] Run the generator; commit the generated file.
- [ ] Record the decision in `typst/SYNC-MAP.md` (a short subsection: generated vs hand-written
      columns, why a separate build-free generator, glob-based discovery, regenerate command). No
      task-number references (durable anchors only).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The glob yields exactly the nine modules in report 02 section 2 with the
listed counts (3,647 total). Confirm by comparing generator output to a fresh `wc -l` over the
glob; if the set differs, the generator's output is authoritative and Phase 2's Role dictionary
must cover the actual set.

**Files to modify**:
- `scripts/typst-module-map.sh` - new generator
- `typst/generated/automation-module-map.typ` - new generated file
- `scripts/typst-sync-check.sh` - Check 2 module-map sub-check
- `typst/SYNC-MAP.md` - decision record

**Verification**:
- `bash scripts/typst-module-map.sh --json` runs without `lake` and matches `wc -l`.
- Check 2 of `bash scripts/typst-sync-check.sh` reports 0 mismatches (Check 1 still red until
  Phase 2 — expected).
- Mutation: hand-edit one count in the generated file -> Check 2 reports a VIOLATION; revert by
  re-running the generator.

---

### Phase 2: Rewrite the proof-automation chapter [NOT STARTED]

**Goal**: `typst/chapters/p4-proof-automation.typ` describes only the live tree, renders its
Module Map from generated data, and Check 1 goes to 0 violations.

**Tasks**:
- [ ] Header comment and `chapter-header` description: drop "~4,300-line" and "Aesop-
      integration"; describe the tactic surface and the two search engines in prose.
- [ ] `== Tactics`: user-authored tactics `apply_axiom`, `modal_t`, `assumption_search`
      (`Tactics/UserTactics.lean`); `modal_search` as the single proof-search entry point
      (`Tactics/Commands.lean`; forms `modal_search`, `modal_search n`, `modal_search (depth := n)
      (visitLimit := m)`; defaults depth 10, visitLimit 1000 — verify against `SearchConfig`);
      `deduction`/`undischarge` (`Tactics/Deduction.lean`); `propDecide`
      (`Tactics/PropDecide.lean`). One past-tense sentence that `tm_auto`, `temporal_search`,
      `propositional_search` were absorbed into `modal_search` (their presets differed only in
      weight fields `searchProof` never read), per `FormalSystem/Automation.lean`'s docstring. Each
      tactic's description verified against its declaration/docstring, not the old chapter.
- [ ] Replace `== Aesop Integration` with a short retirement section (e.g. `== A Retired Aesop
      Rule Set`): past tense; the rule set had zero consumers and was unreachable (dedicated rule
      set, no `aesop (rule_sets := ...)` call anywhere); the Prop/Type mismatch
      (`Axiom` Prop-valued, `DerivationTree` Type-valued) is why Aesop proof reconstruction does not
      work over these goals (per `Tactics/Search.lean` docstring); cite
      `Boneyard/RetiredTactics/README.md`. No bare `@[aesop ...]` spans.
- [ ] `== Bounded Proof Search`: split into the tactic engine (`Tactics/Search.lean`'s
      `searchProof`, strategies `tryAxiomMatch`, `tryLemmaMatch`, `tryAssumptionMatch`,
      `tryModusPonens`, `tryModalK`, `tryTemporalK` in order, bounded DFS under a visit counter)
      and the `ProofSearch/` engine (`boundedSearch`, `iddfsSearch`, `bestFirstSearch`,
      heuristics, memoization), stating that the latter is reached from `decide`'s fast path
      (`Metalogic/Decidability/DecisionProcedure.lean`), not from any tactic. Re-verify every
      retained numeric default (visit limit 500, IDDFS depth 100/limit 10000, etc.) and the
      Search-Space cascade / Heuristic Ordering prose against `ProofSearch/Core.lean`; keep them
      attached to the correct engine. Fix the tableau-relationship paragraph so "what the tactics
      above call" no longer claims the `ProofSearch/` engine.
- [ ] `=== Worked Invocations`: rewrite with `modal_search` against the engine it actually uses;
      delete the "single-family variants restrict candidate moves" paragraph. Verify the M4
      depth-1 claim against `tryAxiomMatch` behavior (or soften it); optionally point at
      `Tests/BimodalTest/Automation/TacticsTest.lean` examples.
- [ ] `== Learning and Game-Theoretic Tactics`: `SuccessPatterns.lean` count comes from generated
      data (or drop the inline count); `EFGameTactics.lean` 326 -> live `wc -l` (331 at research
      time), cited with its real path `Metalogic/WeakCanonical/EFGameTactics.lean`. Verify the
      claim that `patternAwareScore`/`searchWithLearning` consume `PatternDatabase` is within the
      `ProofSearch/` engine only.
- [ ] `== Module Map`: `#import "../generated/automation-module-map.typ": automation-module-map,
      automation-module-total`; a hand-written `roles` dictionary keyed by path (Role text from
      report 02 section 2, verified); `assert(roles.len() == automation-module-map.len())`;
      rows via `roles.at(path)`; lines formatted with thousands separator if the existing chapter
      style requires; caption drops "live line counts" claim wording that cannot be backed, or keeps
      it now that it is generated; sorry-free sentence derived from the generated boolean column
      (or rendered as a column) rather than asserted.
- [ ] Remove `@[aesop norm unfold]` and `@[aesop safe forward]` entries and their explanatory
      comment block from `typst/sync-check-whitelist.txt` after grepping `typst/` to confirm no
      other consumer.
- [ ] Update the `SYNC-MAP.md` entry for this chapter if it records chapter facts that changed.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Check 1's 4 violations are all resolved by this chapter rewrite plus
whitelist cleanup, and no new Check 1 candidates fail. Confirm by running
`bash scripts/typst-sync-check.sh` and reading `TOTAL_VIOLATIONS`.

**Files to modify**:
- `typst/chapters/p4-proof-automation.typ` - full rewrite of stale sections
- `typst/sync-check-whitelist.txt` - drop orphaned Aesop entries
- `typst/SYNC-MAP.md` - chapter entry, if affected

**Verification**:
- `bash scripts/typst-sync-check.sh` exits 0.
- `typst compile typst/BimodalReference.typ <scratchpad>/out.pdf` succeeds (pre-existing font
  warnings only).
- `grep -nE 'tm_auto|temporal_search|propositional_search|AesopRules|Helpers\.lean' typst/chapters/p4-proof-automation.typ`
  shows only past-tense retirement mentions.
- Every backticked `*.lean` path in the chapter exists under `FormalSystem/` (scripted loop).
- Mutation: temporarily delete one key from `roles` -> `typst compile` fails; restore.

---

### Phase 3: Widened retired-tactic prose outside the chapter [NOT STARTED]

**Goal**: No live-tree file outside `docs/` and `Boneyard/` describes a retired tactic or file as
present, and the ProofSearch README stops claiming it powers `modal_search`.

**Tasks**:
- [ ] Re-grep `tm_auto|temporal_search|propositional_search|AesopRules|Tactics/Helpers` across the
      repo excluding `docs/`, `Boneyard/`, `specs/`, `.claude/`, `agent-system/`; reconcile with
      the list below (line numbers are hypotheses).
- [ ] `typst/chapters/p4-dual-verification.typ:36`: `tm_auto`/`modal_search` -> `modal_search`.
      Also check whether "inside a proof, attempt `modal_search`" plus "the procedure tries ...
      bounded proof search" conflates the two engines; reword if needed.
- [ ] `FormalSystem/Automation/README.md:84` (Tactics/ directory row): drop `tm_auto` and
      `Helpers.lean`; list the six live `Tactics/` files. First determine whether this row is
      emitted by a generator (grep `BEGIN GENERATED` handling in `scripts/`); fix at the source if
      so.
- [ ] `FormalSystem/Automation/README.md:137`: replace the `tm_auto -- Uses Aesop with TMLogic
      rule set` usage example with a `modal_search` example consistent with
      `FormalSystem/Automation/Tactics/README.md`.
- [ ] `FormalSystem/Automation/ProofSearch/README.md`: line 19 `tm_auto` integration-point claim ->
      state the engine is used by `decide`'s fast path; "Used by" line corrected to
      `Metalogic/Decidability/` (not `Automation.Tactics` / `modal_search`); stale module table
      (`Core.lean` 1018 -> live, `Strategies.lean` 379 -> live, descriptions checked) — or convert
      it to the repo's `<!-- BEGIN GENERATED: inventory -->` convention if
      `check-module-invariants.sh` supports it for this directory; update "Last verified" date.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Exactly four prose sites (README.md x2, ProofSearch/README.md x1,
p4-dual-verification.typ x1) plus the ProofSearch README table/Used-by line. Confirm with the
re-grep in the first task.

**Files to modify**:
- `typst/chapters/p4-dual-verification.typ` - drop `tm_auto`
- `FormalSystem/Automation/README.md` - two lines (or its generator)
- `FormalSystem/Automation/ProofSearch/README.md` - integration claim, Used-by, module table

**Verification**:
- Re-grep returns no present-tense hits outside `docs/`/`Boneyard/` (past-tense removal notes in
  `Automation.lean`, `Automation/README.md:14`, `Tactics/README.md` remain).
- `bash scripts/check-module-invariants.sh` reports `ALL CHECKS PASSED` (use `--no-build` if a
  build is not available; note which was used).
- `bash scripts/readme-lint.sh` passes.

---

### Phase 4: Wire typst-sync-check.sh into CI [NOT STARTED]

**Goal**: CI runs `typst-sync-check.sh` on every push/PR, following the documented wiring pattern.

**Tasks**:
- [ ] Confirm `bash scripts/typst-sync-check.sh` exits 0 on the committed tree (gate for this
      phase).
- [ ] Append, directly before `- name: Report results` in `.github/workflows/ci.yml`, a step named
      `Typst sync check (scripts/typst-sync-check.sh)` with `set -euo pipefail` and
      `::group::`/`::endgroup::` wrapping, preceded by a short comment (build-free: jq/python/awk,
      no lake/typst binary). No task-number references in the comment.
- [ ] If `docs/development/CI_CD_PROCESS.md` enumerates wired check scripts, add this one (read the
      "Wiring a New Check Script" section first).
- [ ] Ensure the new generator `scripts/typst-module-map.sh` is executable/invoked via `bash` so
      the CI step needs no chmod.
- [ ] Local mutation test: temporarily reintroduce `` `tm_auto` `` in the chapter -> script exits
      1; restore -> exits 0. Do not commit the mutation.

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Verification Tier**: local

**Files to modify**:
- `.github/workflows/ci.yml` - new step
- `docs/development/CI_CD_PROCESS.md` - only if it lists wired scripts

**Verification**:
- YAML parses (`python3 -c 'import yaml,sys; yaml.safe_load(open(".github/workflows/ci.yml"))'`).
- Mutation test behaves as above.
- CI run itself is observed by the user after they push (agents do not push).

## Testing & Validation

- [ ] `bash scripts/typst-sync-check.sh` exits 0 with Checks 1, 2 (incl. module map), 3 passing
- [ ] `typst compile typst/BimodalReference.typ` succeeds
- [ ] Every module named in the chapter resolves to a live file; printed counts equal `wc -l`
      (guaranteed by generated rendering; spot-check the PDF table)
- [ ] No present-tense retired-tactic prose outside `docs/` and `Boneyard/`
- [ ] Chapter no longer claims tactics call `ProofSearch/Core.lean`
- [ ] `bash scripts/check-module-invariants.sh` and `bash scripts/readme-lint.sh` pass
- [ ] `bash scripts/check-task-references.sh` (or equivalent lint) clean on touched deliverables
- [ ] Decision recorded in `typst/SYNC-MAP.md`; CI step present

## Artifacts & Outputs

- `scripts/typst-module-map.sh`, `typst/generated/automation-module-map.typ`
- Updated `scripts/typst-sync-check.sh`, `typst/SYNC-MAP.md`, `typst/sync-check-whitelist.txt`
- Rewritten `typst/chapters/p4-proof-automation.typ`; fixed `typst/chapters/p4-dual-verification.typ`
- Fixed `FormalSystem/Automation/README.md`, `FormalSystem/Automation/ProofSearch/README.md`
- Updated `.github/workflows/ci.yml` (and possibly `docs/development/CI_CD_PROCESS.md`)
- `specs/586_rewrite_typst_proof_automation_chapter/summaries/02_proof-automation-chapter-rewrite-summary.md`

## Rollback/Contingency

All changes are text/scripts committed per green sub-step; revert individual commits with
`git revert`. If the generator approach proves unworkable in typst (rendering issues), fall back to
a hand-written table with counts verified at commit time AND keep Check 2's module-map diff
against a committed plain data file, recording the fallback and reason in `typst/SYNC-MAP.md`
(silence is not acceptable). If Phase 4's CI step cannot be made green locally, leave CI untouched
and mark the phase [BLOCKED] with the failing output.
