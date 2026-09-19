# Implementation Plan: Task #627

- **Task**: 627 - Research cslib as a Lean engineering reference model and produce a publication-standard refactor plan for BimodalLogic / FormalSystem
- **Status**: [IMPLEMENTING]
- **Effort**: 6.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/627_research_cslib_lean_engineering_refactor_plan/reports/01_cslib-refactor-plan.md
- **Artifacts**: plans/01_cslib-refactor-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research report already contains the deliverable the task description asks for: the
cslib convention map, the target layout, the lakefile target shape, the namespace map, the
header/citation templates, the nine-phase refactor programme, and the ADR-006/ADR-009
dispositions. What it does not yet have is a durable home: it lives under `specs/`, which is
ephemeral by the repository's own `docs/README.md` "Durable Records Placement" rule, and its
key measurements (the 141/38 `WeakCanonical` partition, the Automation partition, the 17-line
upward-edge list, the namespace audit) were produced by scratchpad scripts that no longer
exist. This plan lands the programme where the follow-up tasks will consume it: a committed,
re-runnable measurement script; a programme document under `docs/development/`; and the two
proposed ADRs (ADR-010, ADR-011). The task's own constraint stands throughout: **no file under
`FormalSystem/` or `Tests/` is modified**, and every phase leaves `lake build` and
`bash scripts/check-module-invariants.sh` green. Execution of programme Phases 0-9 is
explicitly out of scope here; the programme document ends with the follow-up task split.

### Research Integration

From `reports/01_cslib-refactor-plan.md`:

- The convention map (26 rows: adopt / already matches / deliberately diverge) and the target
  layout, lakefile targets, namespace map and header/citation templates are carried into the
  programme document verbatim in substance (Phase 2).
- The measured `WeakCanonical` partition (141 files / 104,087 lines BX-free vs. 38 / 28,472
  residual), the Automation partition (9 library modules vs. ~16k lines of tooling), the
  17-line upward-edge list, and the namespace audit (279 / 187 / 24) become the output of a
  committed script (Phase 1) so that programme Phase 6's "re-run the closure before moving"
  gate is executable.
- ADR-006 is superseded (not reaffirmed) for the Expressiveness set; ADR-009 keeps retention
  but moves the archive to the repository root and drops the frozen-LaTeX rationale bullet.
  Both become Proposed ADRs (Phase 3).
- The report's open `specs/` question (untrack before publication vs. keep) is resolved in
  this plan's Decisions below and surfaced as a non-blocking user decision.
- The report's Phase 0 tool (`scripts/move-modules.py`) is deliberately **not** built in this
  task: it is the first follow-up task, paired with its first production use (programme Phase
  2, the Boneyard move), so the tool is validated on a real move rather than a toy.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the dispatch context. `specs/ROADMAP.md` was consulted
read-only: its "Phase 5: Publication and Documentation" is the roadmap item the programme
advances. Not modified.

## Goals & Non-Goals

**Goals**:
- Commit a re-runnable measurement script (`scripts/measure-refactor-partitions.py`, backed
  by `scripts/lib/import_graph.py`) that reproduces every count the report relies on and has a
  `--check` mode asserting the Expressiveness set is `BXCanonical`-free.
- Land the refactor programme as `docs/development/PUBLICATION_REFACTOR.md`: convention map,
  target layout, lakefile target shape, namespace map, header/license/citation templates,
  the nine dependency-ordered phases with `[CITE]` markers, the publication gate, and the
  follow-up task split with paste-ready task descriptions.
- Write `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` and
  `docs/architecture/ADR-011-Extract-Expressiveness.md` with status Proposed, index them, and
  cross-link them from ADR-009 and ADR-006 without changing those records' Accepted status.
- Keep `lake build`, `lake build BimodalTest` and the full invariant harness green, with zero
  diffs under `FormalSystem/` and `Tests/`.

**Non-Goals**:
- Executing any programme phase (0-9): no module moves, no lakefile changes, no Boneyard
  relocation, no docstring edits, no untracking of `specs/`, `CLAUDE.md` or `latex/`.
- Building `scripts/move-modules.py` (follow-up task, see Decisions).
- Creating the follow-up tasks in `state.json`: the multi-task creation standard requires
  interactive selection, so the programme document supplies paste-ready `/task` descriptions
  and the user creates them.
- Adopting the Lean module system, splitting the two >4,500-line files, or any other
  programme Phase 9 item.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C5/C12 fail on target paths that do not exist yet (`FormalSystem.Metalogic.Expressiveness`, `FormalSystem/Tactic/Attr.lean`) named in the programme doc or ADRs | H | H | Write every not-yet-existing name relative to the library root (`Metalogic/Expressiveness/`, `Metalogic.Expressiveness.Kamp`), which the C5 regex (`FormalSystem.`-prefixed) and C12 regex (`FormalSystem/`-prefixed) do not match; state this convention once at the top of the doc. Where a fully-qualified slash path is unavoidable, add it to `scripts/markdown-slash-path-allowlist.txt` (its own header names deliberately hypothetical paths as the bar for an entry). Never add hypothetical modules to `module-invariants-allowlist.txt` (namespaces only). |
| C9 / write-time hook reject `specs/627_...` or "task 627" citations in `docs/` or `scripts/` | H | H | Cite the measured tree by commit SHA (`220e94ea4`) and the script that regenerates the numbers, never the report path or task number. |
| Measurement script disagrees with the report's counts | M | M | Counts are hypotheses (see Scope Hypothesis lines). The script is the source of truth; record any discrepancy in the programme doc's measurement section and in the summary. A disagreement on the 141/38 partition membership blocks nothing here but must be stated. |
| Script-side C9 (scripts/ is in scope) or shellcheck/lint noise | L | M | No task numbers in script comments; Python only (no shell) so shellcheck is not engaged; keep imports to stdlib. |
| `docs/` prose duplication (C18) or broken relative links (C13) from copying report text | M | M | Programme doc links to ADRs and `ORGANISATION.md` rather than restating them; run `bash scripts/check-module-invariants.sh --no-build` after every doc edit. |
| ADR status vocabulary: marking ADR-006/009 "Superseded" before ADR-010/011 are accepted would misstate the live decision | M | L | ADR-010/011 carry `**Proposed**`; ADR-006/009 keep `**Accepted**` and gain a one-line pointer "supersession proposed by ADR-0NN (Proposed)". The catalog table's Status column shows Proposed. |
| Implementer (lean-implementation-agent) treats this as a proof task | L | L | The plan's Lean Challenge Statements section states explicitly that no `.lean` file is in scope. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Committed measurement tooling [COMPLETED]

**Goal**: Replace the report's lost scratchpad scripts with a committed, re-runnable
measurement that reproduces every structural count the programme depends on and can serve
as the pre-move gate for programme Phase 6.

**Tasks**:
- [x] Create `scripts/lib/import_graph.py` (stdlib only), reusing `scripts/lib/live_walk.py`
      for Boneyard-excluding traversal. Provide: `module_of(path)` / `path_of(module)` for
      `FormalSystem.*` and `BimodalTest.*`; `leading_imports(path)` that parses ONLY the
      file's leading `import` block after the copyright comment (the report's Appendix
      documents why a naive `grep '^import'` yields a false self-cycle from docstring
      examples); `closure(module)` over `FormalSystem.*` imports; and a reverse-edge index.
- [x] Create `scripts/measure-refactor-partitions.py` with subcommands or flags producing,
      as markdown tables on stdout (and `--json` for machine use):
      - `upward-edges`: every import from `Syntax/`, `Semantics/`, `ProofSystem/`,
        `Theorems/`, `Metalogic/` into `Automation.*`, plus `Theorems <-> Metalogic` edges
        (report: 17 lines in four classes; 4 Theorems files -> `Metalogic.Core.DeductionTheorem`;
        29 Metalogic files -> Theorems).
      - `weakcanonical-partition`: classify each `Metalogic/WeakCanonical/**` module by
        whether `BXCanonical` appears in its transitive closure; print the proposed
        Expressiveness set (the report's 13 named subtrees/files) with file and line counts,
        the residual set, and every edge from the Expressiveness set into the residual or
        into `BXCanonical` (expected: zero).
      - `automation-partition`: the union of closures of all non-Automation library modules
        (excluding `Examples/`, `MainResults.lean`, `Metalogic/Decidability/TraceExport.lean`)
        intersected with `Automation.*` (report: 9 modules), and the complement (tooling).
      - `namespace-audit`: each live file's first `namespace` vs. its module path, bucketed
        equal-or-descendant / ancestor / unrelated (report: 279 / 187 / 24).
      - `--check`: exit non-zero if the Expressiveness set has any edge into the residual
        `WeakCanonical` set or into `BXCanonical`. This is programme Phase 6's gate.
- [x] Run each mode against the current tree; compare with the report's numbers; note every
      discrepancy in the script's `--help` epilogue or a short header comment ("measured on
      commit 220e94ea4: ...") without task numbers or `specs/` paths. *(completed — partition
      141/104,087 vs 38/28,472, 150/29 by closure, 0 leaks, 9 library-needed Automation modules
      and 279/187/24 namespaces all reproduce; discrepancies: 16 not 17 upward lines into
      Automation, 11 not 12 attribute-only lines, 15 not 17 language-extension files among the
      24 unrelated namespaces, C6 manifest has 15 entries not 26; recorded in the script header)*
- [x] Catalogue the script in `docs/development/MODULE_INVARIANTS.md` next to
      `check-metalogic-cycles.sh` (same "not wired into the harness, run directly" posture).
- [x] Run `bash scripts/check-module-invariants.sh --no-build` (C9 covers `scripts/`; C12/C13
      cover the MODULE_INVARIANTS.md edit). *(completed — exit 0, C9/C9D/C12/C13 PASS)*

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The report's counts (17 upward-edge lines; 141 files / 104,087 lines
BX-free vs. 38 / 28,472 residual; 9 library-needed Automation modules; 279 / 187 / 24
namespace buckets; 26 C6-unreachable modules) are hypotheses. Confirm by running the script;
the script's output supersedes the report wherever they differ, and the difference is recorded.

**Files to modify**:
- `scripts/lib/import_graph.py` - new: leading-import parser, module/path mapping, closure
- `scripts/measure-refactor-partitions.py` - new: the four measurements plus `--check`
- `docs/development/MODULE_INVARIANTS.md` - catalogue entry for the new script

**Verification**:
- `python3 scripts/measure-refactor-partitions.py --check` exits 0 on the current tree.
- `python3 scripts/measure-refactor-partitions.py weakcanonical-partition` lists an
  Expressiveness set with zero edges into residual `WeakCanonical` or `BXCanonical`.
- `bash scripts/check-module-invariants.sh --no-build` passes (C9, C12, C13 in particular).
- `git status --porcelain -- FormalSystem Tests` is empty.

---

### Phase 2: Programme document [COMPLETED]

**Goal**: Land the refactor programme as a durable `docs/` record that the follow-up tasks
and external readers can cite, satisfying the harness's markdown checks.

**Tasks**:
- [x] Create `docs/development/PUBLICATION_REFACTOR.md` with these sections, in order:
      *(completed — convention map transcribed at 23 rows, the report's actual count, not 26)*
      1. **Purpose and status** (what "publication standard" means here: upstream
         `leanprover/cslib` and Mathlib surface; the fork `benbrastmckie/cslib` is a partial
         model only, because it tracks `specs/`, `.claude/`, `.memory/`).
      2. **Path-naming convention for this document**: every not-yet-existing path or module
         is written relative to the library root (`Metalogic/Expressiveness/`,
         `Metalogic.Expressiveness.Kamp`), so C5/C12 are never asked to resolve a future path.
      3. **Convention map**: the report's 26-row table (cslib convention / current state /
         disposition with reason).
      4. **Target layout**: the directory tree (tree lines carry no `FormalSystem/` prefix),
         the lakefile target shape (`BimodalTools`, `BimodalToolsTest`, re-rooted exes,
         `checkInitImports` kept), and the namespace map (only rows that change, with the
         FQN-churn column).
      5. **Templates**: library-file header + module docstring with `* [Author, *Title*][key]`
         references; test-file note; `CITATION.cff` updates at publication; README lead
         structure.
      6. **Measurements**: how to regenerate every number
         (`python3 scripts/measure-refactor-partitions.py ...`), the commit measured
         (`220e94ea4`), and any Phase 1 discrepancies.
      7. **Phased programme**: Phases 0-9 from the report, each with: `[CITE]` marker where a
         citeable path/module/FQN changes, the per-phase acceptance (`lake build`,
         `lake build BimodalTest`, `bash scripts/check-module-invariants.sh`, plus the
         phase-specific check), and the ADR touched. Phase 6 is split as 6.1 (scripted move +
         namespace) and 6.2 (content renames, stub deletion). Move the `specs/` untracking
         from Phase 1 to the publication gate (see Decisions).
      8. **Dependency order and publication gate**: `0 -> 1 -> 2 -> {3, 4} -> 5 -> 6 -> 7 -> 8
         -> 9`; gate = Phases 1-7 done and Phase 8's root collapse done; then untrack the
         non-deliverable set in one commit, then the user's `/tag` creates v1.0.0 and
         `CITATION.cff` is updated.
      9. **Follow-up task split**: one paste-ready `/task` description per follow-up, with
         the consolidation recommended below and the dependency each carries:
         - Programme Phases 0 + 2 (move tool + Boneyard to root, ADR-010 acceptance)
         - Phase 1 (deliverable hygiene, excluding `specs/` untracking)
         - Phase 3 (`BimodalTools` split)
         - Phase 4 (upward edges by relocation; corrected layer table)
         - Phase 5 (language-extension directories; probe tests relocated)
         - Phase 6 (Expressiveness extraction 6.1/6.2, ADR-011 acceptance)
         - Phase 7 (docstring and citation normalisation)
         - Phase 8 (CI parity, root collapse, publication gate)
         - Phase 9 (optional, post-publication)
         Each description must be self-contained (no reference to this task's number) and
         name its acceptance checks.
- [x] Add a row for the document to `docs/development/README.md`'s table.
- [ ] If any fully-qualified `FormalSystem/...` hypothetical path is unavoidable, add it to
      `scripts/markdown-slash-path-allowlist.txt` with a comment naming the programme phase
      that makes it real. *(deviation: skipped — no hypothetical full path was needed; every
      future path is written relative to the library root, so the allowlist stays empty)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build`; fix every C5/C12/C13/C18
      finding before committing. *(completed — one C12 finding, `Logos/ProofChecker` matching
      the pre-merge `Logos/` root pattern, reworded; exit 0 afterwards; `readme-lint.sh` PASS)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: 26 convention-map rows, 9 programme phases and 9 follow-up tasks are the
report's counts; confirm the row count while transcribing and adjust if rows merge or split.

**Files to modify**:
- `docs/development/PUBLICATION_REFACTOR.md` - new: the programme
- `docs/development/README.md` - index row
- `scripts/markdown-slash-path-allowlist.txt` - only if a hypothetical fully-qualified path is unavoidable

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` passes (C5, C9, C12, C13, C18, INV).
- `grep -nE 'task[[:space:]]+#?[0-9]+|specs/[0-9]{3}_' docs/development/PUBLICATION_REFACTOR.md`
  returns nothing.
- Every programme phase names its acceptance checks and its `[CITE]` status.
- `git status --porcelain -- FormalSystem Tests` is empty.

---

### Phase 3: ADR-010 and ADR-011 (Proposed) [COMPLETED]

**Goal**: Record the two architectural decisions the programme depends on in the
repository's one ADR location, as Proposed records that the follow-up tasks accept when
their phases land.

**Tasks**:
- [x] Create `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` following the
      ADR-005/009 section shape (Status / Context / Decision / Consequences / Related):
      `**Proposed** - 2026-09-19`; keeps ADR-009's retention decision; moves the archive to
      the repository root citing cslib's "root-level placement is load-bearing" argument
      (`mk_all --check` scans everything under the library root; keeps `Boneyard.*` out of the
      library's module namespace and API docs); drops the rationale bullet that cites the
      frozen `latex/subfiles/04-Metalogic.tex` (the typst manual's 7 citing files are the live
      justification); keeps C11 enforced (a recorded divergence from cslib's "stale imports are
      cosmetic"); names the B0/C11 changes (B0 pattern, C11 scan root, new invariants: no
      `Boneyard` in `lakefile.toml` or the root aggregator, no `import Boneyard.*` from live
      code).
- [x] Create `docs/architecture/ADR-011-Extract-Expressiveness.md`: `**Proposed** -
      2026-09-19`; supersedes ADR-006 for the Expressiveness set only; records the closure
      measurement and the command that re-runs it
      (`python3 scripts/measure-refactor-partitions.py weakcanonical-partition` / `--check`);
      states that the residual `BXCanonical <-> WeakCanonical` cycle (over the ~28k-line
      residual) is accepted and that `check-metalogic-cycles.sh` must still report exactly 1;
      states that the residual keeps the name `WeakCanonical`, which now describes it; keeps
      ADR-006's "no `Completeness/` regroup" declined; names the two `MainResults.lean`
      entries whose FQNs change and why that is the pre-publication argument.
- [x] Add both to the catalog table in `docs/architecture/README.md` (Status: Proposed) and
      add "ADR Details" paragraphs matching the existing entries' style.
- [x] In `ADR-006-Metalogic-No-Physical-Regroup.md` and `ADR-009-Boneyard-Retention.md`, add
      one line under `## Status`: "Supersession of {clause} proposed by [ADR-0NN](...)
      (Proposed); this record remains in force until that ADR is accepted." Do not change
      `**Accepted**`.
- [x] Use relative target names (`Metalogic/Expressiveness/`, `Boneyard/` at root) per the
      Phase 2 convention; cite commit `220e94ea4` for the measurement, never the report path.
- [x] Run `bash scripts/check-module-invariants.sh --no-build`. *(completed — exit 0; Phase 3
      executed before Phase 2 per the phase-closure contract's cheapest-closure-first rule, so
      the ADRs name `PUBLICATION_REFACTOR.md` in backticks and Phase 2 links back to them)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Files to modify**:
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` - new
- `docs/architecture/ADR-011-Extract-Expressiveness.md` - new
- `docs/architecture/README.md` - catalog rows and details paragraphs
- `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md` - one-line Status pointer
- `docs/architecture/ADR-009-Boneyard-Retention.md` - one-line Status pointer

**Verification**:
- Both new ADRs render the five standard sections and a `**Proposed**` status line.
- `docs/architecture/README.md` catalog lists ADR-010 and ADR-011.
- `bash scripts/check-module-invariants.sh --no-build` passes (C5, C12, C13).
- No `task N` or `specs/NNN_` string in any touched file.
- `git status --porcelain -- FormalSystem Tests` is empty.

---

### Phase 4: Full gate and summary [NOT STARTED]

**Goal**: Prove the task's constraint held and the tree is green under the full harness,
reconcile the programme document's numbers with the Phase 1 script, and write the summary.

**Tasks**:
- [ ] `git status --porcelain -- FormalSystem Tests` must be empty; `git diff --stat` must
      list only `scripts/`, `docs/`, and (if used) the C12 allowlist.
- [ ] Run `lake build` and `lake build BimodalTest` (expected no-op rebuild; both must exit 0).
- [ ] Run the full `bash scripts/check-module-invariants.sh` (with build) and
      `bash scripts/check-metalogic-cycles.sh` (must still report exactly 1 cycle).
- [ ] Cross-check every count in `PUBLICATION_REFACTOR.md` and ADR-011 against
      `python3 scripts/measure-refactor-partitions.py` output; correct the documents to the
      script, not the other way round.
- [ ] Write `specs/627_research_cslib_lean_engineering_refactor_plan/summaries/01_cslib-refactor-plan-summary.md`
      listing the artifacts, the reconciled counts, any discrepancy against the report, and
      the follow-up task list for the user to create.

**Timing**: 1 hour

**Depends on**: 2, 3

**Verification Tier**: full

**Files to modify**:
- `specs/627_research_cslib_lean_engineering_refactor_plan/summaries/01_cslib-refactor-plan-summary.md` - new
- `docs/development/PUBLICATION_REFACTOR.md`, `docs/architecture/ADR-011-Extract-Expressiveness.md` - count corrections only, if any

**Verification**:
- Full harness green; cycle count 1; both builds exit 0.
- Summary written; zero diffs under `FormalSystem/` and `Tests/`.

## Lean Challenge Statements

No `.lean` file is in scope for this plan (the task forbids edits under `FormalSystem/` and
`Tests/`, and every deliverable is a script or a markdown record). There are therefore no
theorem statements to pin; the Goals section names no Lean identifiers.

```lean
-- No theorem statements: this plan modifies no .lean file.
```

## Decisions

- **`specs/` disposition (surfaced as a non-blocking user decision).** The report recommends
  untracking `specs/` before publication but asks the plan to confirm the agent system still
  works with it ignored. It does not, cleanly: the agent workflow commits task provenance
  under `specs/` (`.gitignore` already carves out `.orchestrator-handoff.json` and
  `.return-meta.json` as "durable provenance [that] must stay tracked"), and the nine
  follow-up tasks will run through that workflow. Decision: keep `specs/` tracked while the
  programme runs and untrack the whole non-deliverable set (`specs/`, `CLAUDE.md`,
  `.claude-extensions.json`, `.syncprotect`, the empty `.gitattributes`) in one commit at the
  publication gate, immediately before the v1.0.0 tag. Programme Phase 1 therefore excludes
  `specs/` untracking; the programme document records this. The user may prefer to keep
  `specs/` published or to move it to a separate branch; that preference is recorded in
  `.return-meta.json`'s `user_decision` (non-blocking, recommended: untrack at the gate).
- **`scripts/move-modules.py` is a follow-up, not part of this task.** Building the tool
  without a real move to validate it against gives a toy self-test only; pairing it with the
  Boneyard relocation (programme Phase 2, the smallest scripted move with the largest
  reference surface: 575 archived imports, 48 live docstrings, 43 markdown files, 12 scripts,
  7 typst files) validates every rewrite class the tool must support.
- **Programme document location: `docs/development/`.** It is a process document (like
  `MODULE_ORGANIZATION.md` and `VERSIONING.md`), not a decision record; the decisions it
  depends on live in `docs/architecture/` as ADR-010/011 per `docs/README.md`'s "Durable
  Records Placement".
- **Hypothetical paths are written relative to the library root.** This is a documented
  convention in the programme document, not an evasion: C5/C12 exist to catch stale paths,
  and a path that will exist only after a named phase lands is not stale.
- **`DeductionTheorem` keeps its namespace when moved (programme Phase 4)**, recorded as one
  more ancestor-style exception, for zero FQN churn; the programme document carries this as
  the report recommended, with the alternative (rename in Phase 6's FQN pass) noted.

## Testing & Validation

- [ ] `python3 scripts/measure-refactor-partitions.py --check` exits 0.
- [ ] `python3 scripts/measure-refactor-partitions.py weakcanonical-partition` shows zero
      Expressiveness-to-residual and Expressiveness-to-`BXCanonical` edges.
- [ ] `bash scripts/check-module-invariants.sh` (full) passes at the end of Phase 4;
      `--no-build` passes at the end of every phase.
- [ ] `bash scripts/check-metalogic-cycles.sh` reports exactly 1 cycle.
- [ ] `lake build` and `lake build BimodalTest` exit 0.
- [ ] `git status --porcelain -- FormalSystem Tests` is empty after every phase.
- [ ] No `task N` / `specs/NNN_` citation in any file under `docs/` or `scripts/`.

## Artifacts & Outputs

- `scripts/lib/import_graph.py`
- `scripts/measure-refactor-partitions.py`
- `docs/development/PUBLICATION_REFACTOR.md` (+ index row in `docs/development/README.md`)
- `docs/development/MODULE_INVARIANTS.md` (catalogue entry)
- `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md`
- `docs/architecture/ADR-011-Extract-Expressiveness.md` (+ catalog rows in
  `docs/architecture/README.md`; one-line pointers in ADR-006 and ADR-009)
- `specs/627_research_cslib_lean_engineering_refactor_plan/summaries/01_cslib-refactor-plan-summary.md`

## Rollback/Contingency

Every deliverable is additive (new scripts, new documents) or a one-line pointer in an
existing ADR, and no build input changes, so reverting is `git rm` of the new files plus
reverting the index/pointer edits; no snapshot is needed for that. If a phase must be abandoned
with uncommitted work in the tree, follow `context/contracts/recovery.md`'s rollback rung
(snapshot first, then the destructive command) rather than a bare reset. If the Phase 1 script
cannot reproduce the report's `WeakCanonical` partition (a non-empty edge set from the
Expressiveness set into the residual), do not weaken `--check`: record the offending edges in
the programme document and ADR-011, mark programme Phase 6 as blocked on a dependency-first
relocation of those edges, and complete the remaining phases unchanged.
