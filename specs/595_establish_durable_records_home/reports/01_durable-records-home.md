# Research Report: Task #595

**Task**: 595 - Establish durable records home
**Started**: 2026-09-16T00:00:00Z
**Completed**: 2026-09-16T00:00:00Z
**Effort**: small
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Glob/Grep/Read), specs/reviews/review-2026-09-16.md, specs/593_revise_task_organization_codebase_cleanup artifacts, docs/architecture/README.md, scripts/check-module-invariants.sh, scripts/check-paper-definitions.sh
**Artifacts**: - specs/595_establish_durable_records_home/reports/01_durable-records-home.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The repository already has **one established decision-record convention**:
  `docs/architecture/` (ADRs). Its own README states explicitly: *"There is no
  `docs/decisions/`; a second location for the same genre would recreate exactly the
  duplicate-authority problem ADRs exist to remove."* This rules out one of the two
  candidate homes the task description names (`docs/decisions/`) as a destination —
  creating it would directly contradict a decision already on record.
- Recommended decision: move both record families out of `specs/` (the gitignored-adjacent,
  task-management tree) into `docs/`, split by genre:
  - `specs/paper-definitions-of-record.md` -> `docs/reference/paper-definitions-of-record.md`
    (it is reference/lookup data — a pinned anchor manifest — the same genre as
    `docs/reference/axiom-reference.md` and `docs/reference/operators.md` already there).
  - `specs/decisions/*.md` -> `docs/architecture/*.md`, added to `docs/architecture/README.md`'s
    existing "Specification Documents" table (non-ADR-numbered, same treatment as
    `BFMCS_ARCHITECTURE.md`) rather than forcing them into the numbered ADR-{NNN} template or
    creating a second decisions directory. This satisfies the "one ADR convention" rule without
    requiring the (heavier, out-of-scope-for-"small") work of reshaping them to the strict
    Context/Decision/Consequences ADR template and renumbering all 21 citation sites to new
    ADR-style filenames.
- `specs/paper-definitions-of-record.md` and `specs/decisions/*.md` are currently **tracked by
  git** and are not touched by any `.gitignore` rule (only `specs/archive/`, `specs/vault/`,
  `specs/tmp/`, and `specs/**/.*` dotfiles are ignored) — so the "one cleanup away from
  breaking" risk is about a future vault operation, archival pass, or contributor treating
  `specs/` as disposable task scaffolding, not a live gitignore hole today. Moving them under
  `docs/` removes that entire class of risk and additionally brings them under the C13
  (relative-link resolution) and C12 (path resolution) invariant checks that already gate
  `docs/` + root `README.md`, which they are outside of today.
- Two scripts hardcode the current `specs/` paths and MUST be repointed if moved:
  `scripts/check-paper-definitions.sh` (`RECORD_DEFAULT` variable) and
  `scripts/check-module-invariants.sh` (`C15_RECORD="specs/paper-definitions-of-record.md"`,
  line 1643).
- Measured now (2026-09-16), matching the dispatch's "re-measure before planning" instruction:
  raw citation line-count across the whole repo (live + `specs/evidence/` scratch `.lean` files)
  is **47** (26 for `paper-definitions-of-record.md`, 21 for `specs/decisions/`), not the 43
  named in the task description — the difference is almost certainly scope (the task's "from
  live Lean" figure likely excludes `Tests/` and/or `specs/evidence/` scratch spikes, which this
  grep does not). The planner/implementer should re-run the exact grep at plan/implementation
  time and treat post-move zero-remaining-old-path as the acceptance bar, not a specific count.

## Context & Scope

Task 595 is item **N2 `establish_durable_records_home`** from the `codebase-cleanup` topic
reorganization (`specs/593_.../reports/01_cleanup-topic-reorganization.md`), itself derived from
Finding H2 of `specs/reviews/review-2026-09-16.md` (the paper-vocabulary drift review). It is
explicitly a **wave-1, decision-first** task: task 584 (`reconcile_lean_tree_with_paper_vocabulary`,
which re-pins `paper-definitions-of-record.md`) and task 590 (docs staleness audit, widened)
both declare a dependency on 595 finishing first. `specs/TODO.md` carries live "RECORDS HOME:"
notes on both downstream tasks instructing them to "use whatever location [595] settles on" —
i.e. the location genuinely is not yet fixed anywhere else in the tree, and this report's
recommendation is the first concrete proposal.

Scope of this research: (1) confirm current locations, tracked/ignored status, and citation
counts of the two record families; (2) survey `docs/` for an existing precedent/genre fit;
(3) enumerate every consumer (scripts, Lean docstrings, other markdown, README catalogs) that
would need repointing on a move; (4) check whether moving into `docs/` introduces new
C12/C13/C15 exposure.

## Findings

### Codebase Patterns

**Current locations and git status**:
- `specs/paper-definitions-of-record.md` (143 KB) — tracked (`git ls-files` confirms), not
  gitignored.
- `specs/decisions/total-history-validity-decisions.md` (13 KB) and
  `specs/decisions/untl-snce-argument-order.md` (19 KB) — tracked, not gitignored.
- `.gitignore` only ignores `specs/archive/`, `specs/vault/`, `specs/tmp/`, and `specs/**/.*`
  (dotfiles). Both record files sit as **top-level `specs/` files/directories that are not task
  directories** (`specs/{NNN}_{SLUG}/` is the task convention; these two are siblings of
  `specs/TODO.md`, `specs/ROADMAP.md`, `specs/CHANGE_LOG.md`, etc.) — structurally anomalous:
  they are durable, cited-from-code artifacts sitting inside the directory whose whole *raison
  d'être* is ephemeral task management (see `.claude/CLAUDE.md`: "task management artifacts").

**Existing `docs/` genre precedents**:
- `docs/architecture/README.md` runs an explicit, numbered ADR catalog (ADR-001, ADR-004..009)
  and states in so many words that `docs/decisions/` must not be created as a second
  decision-record location. It also carries a **"Specification Documents"** table for
  non-ADR-numbered architectural documents (`BFMCS_ARCHITECTURE.md`), which is the closest
  existing shape for a "keep the filename, move the directory" treatment of
  `specs/decisions/*.md` without forcing an ADR-template rewrite.
- `docs/reference/` is "Project-wide reference materials" and already holds
  `axiom-reference.md`, `operators.md`, `comment-convention.md`, `docstring-standard.md` —
  reference/lookup documents in the same register as `paper-definitions-of-record.md` (a pinned
  anchor-to-text manifest consulted by both humans and a drift-check script, not a narrative
  decision record).

**Content check — no new C13 exposure from the files' own bodies**: neither
`specs/decisions/*.md` nor `specs/paper-definitions-of-record.md` contains any
`[text](relative/path)`-style markdown links (`grep -n '\]('` returns nothing in all three
files) — they cite other files exclusively via backtick-quoted paths in prose. Moving them under
`docs/` therefore introduces **no new C13-breakable links from inside these files themselves**;
the only new C13 surface is the catalog-entry links that `docs/README.md` /
`docs/architecture/README.md` / `docs/reference/README.md` would add pointing *at* them, which
is exactly the kind of link C13 already exists to keep honest.

**Consumers requiring repointing on a move**:

1. **Scripts (hardcoded paths, both MUST change)**:
   - `scripts/check-paper-definitions.sh`: `RECORD_DEFAULT="$(cd "$(dirname
     "${BASH_SOURCE[0]}")/.." && pwd)/specs/paper-definitions-of-record.md"` — this is the
     `--record` default consumed on every invocation.
   - `scripts/check-module-invariants.sh` line 1643 (C15 check):
     `C15_RECORD="specs/paper-definitions-of-record.md"` — the anchor-resolution source for the
     paper-anchor-citation invariant (C15) that the task's acceptance criteria names directly.
   - `specs/decisions/*.md` are not referenced by path from any script (only by Lean docstring
     prose and by `specs/paper-definitions-of-record.md` itself, which cross-references
     `specs/decisions/total-history-validity-decisions.md`).

2. **Lean docstring citations** (raw grep, 2026-09-16, re-measure before planning):
   - `specs/paper-definitions-of-record.md`: 26 occurrences across 17 files under
     `FormalSystem/` and `Tests/BimodalTest/` (e.g. `FormalSystem/Semantics.lean`,
     `FormalSystem/Metalogic/Conservativity.lean`,
     `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`,
     `FormalSystem/Syntax/Formula.lean`).
   - `specs/decisions/` (both files combined): 21 occurrences, including 2 in
     `specs/evidence/bi-lasso-decision-layer/*.lean` scratch/spike files (which are inside
     `specs/`, not `FormalSystem/`, and may or may not count as "live" scope for the task's
     citation figure) plus occurrences in `FormalSystem/Metalogic/Decidability/BiLasso/Unfold.lean`
     and `FormalSystem/Theorems/DiscreteUnfolding.lean`.
   - Combined raw total: **47**, vs. the task description's **43** ("25 paper-definitions-of-record,
     18 decisions") — the discrepancy is plausibly scope (live-tree vs. all-matching-lines) and
     should be re-measured at plan/implement time exactly as the dispatch instructs, not treated
     as a report defect to chase down further here.

3. **Other markdown referencing the current paths** (repo-wide grep, excluding `.git/` and
   `specs/archive/`):
   - `docs/development/MODULE_INVARIANTS.md`, `docs/theorem-index.md` — durable docs, will need
     path updates.
   - `FormalSystem/Metalogic/Decidability/BiLasso/README.md`,
     `FormalSystem/Semantics/Correspondence/README.md`,
     `FormalSystem/Boneyard/README.md`,
     `FormalSystem/Boneyard/Kamp/KampWeakCanonical/README.md` — in-library READMEs citing one or
     both record families.
   - `typst/SYNC-MAP.md` — cites `paper-definitions-of-record.md`.
   - `specs/paper-definitions-of-record.md` itself cross-references
     `specs/decisions/total-history-validity-decisions.md` (internal cross-link between the two
     record families — must be updated together, in the same commit, regardless of which
     destination is chosen, or the two moved files will cite each other's stale pre-move paths).
   - In-flight task artifacts under `specs/{NNN}_.../` (593, 580, 579, 584, and
     `specs/reviews/*`) also mention the current paths, but these are `specs/**` artifacts,
     exempt under `.claude/rules/no-task-references-in-deliverables.md`'s scope carve-out and
     under the "durable anchor" principle — they are historical snapshots of what was true when
     written and do not need retroactive editing as part of this task.
   - Root `README.md` does not mention either path (`grep` returned nothing) — no root-README
     change needed.

### External Resources

Not applicable — this is a pure internal repository-organization decision with no external
dependency or library research surface.

### Recommendations

1. **Decision** (to record in whichever README ends up hosting each family, per the task's WORK
   item 3): `specs/` is confirmed as the task-management tree per `.claude/CLAUDE.md`'s own
   "Project Structure" section (`specs/{NNN}_{SLUG}/` task directories) and per
   `.claude/rules/no-task-references-in-deliverables.md`'s framing of `specs/**` as inherently
   ephemeral/renumbering-prone. Both record families are cited from live Lean code as permanent
   ground truth and must not share that ephemeral tree. Move both to `docs/`.
2. Split the destination by genre rather than inventing one new "records" directory for both:
   - `paper-definitions-of-record.md` -> `docs/reference/` (reference-manifest genre, matching
     `axiom-reference.md`/`operators.md`). Update `docs/reference/README.md`'s catalog.
   - `specs/decisions/*.md` -> `docs/architecture/` (decision-record genre; folded into the
     existing "Specification Documents" table rather than a new `docs/decisions/`, per that
     README's explicit prohibition). Update `docs/architecture/README.md`'s catalog.
3. Repointing order for the implementer: (a) `git mv` both; (b) fix the two script hardcoded
   paths (`check-paper-definitions.sh`, `check-module-invariants.sh` C15); (c) fix the
   cross-reference from `paper-definitions-of-record.md` to
   `total-history-validity-decisions.md`; (d) sweep Lean docstrings (26+21 raw sites, re-grep to
   confirm final count) via a scoped find/replace of the literal old path strings — this is a
   pure string substitution (paths cited only in prose, never as Lean `import`s), not a semantic
   change; (e) fix the 6 other markdown consumers listed above; (f) add catalog entries to the
   two destination READMEs; (g) re-run `bash scripts/check-paper-definitions.sh`,
   `bash scripts/check-module-invariants.sh` (or `--no-build`), and
   `grep -rn "specs/paper-definitions-of-record\.md\|specs/decisions/" --include="*.lean" .`
   (excluding `.git/`) to confirm zero remaining old-path citations, satisfying the task's
   ACCEPTANCE bullet.
4. Do not touch `specs/**` artifact mentions of the old paths (exempt, historical).

## Decisions

- `docs/decisions/` is **not** a viable destination: `docs/architecture/README.md` already
  states this in an existing, on-record decision (quoted above). This report treats that as
  settled rather than re-litigating it.
- Recommend splitting the two record families across `docs/reference/` and `docs/architecture/`
  by genre, rather than a single new `docs/records/` directory, because both destinations
  already exist, already hold same-genre content, and already have a catalog-update
  procedure documented in their own READMEs — the lowest-risk path for a "small" task.
- Recommend keeping the `specs/decisions/*.md` filenames as-is (not renumbering into
  `ADR-{NNN}-*.md` form) and listing them under `docs/architecture/README.md`'s existing
  "Specification Documents" table, since full ADR-template conformance is out of scope for a
  small task and would multiply the citation-repoint surface (filename changes, not just
  directory changes) without changing the substance of the "durable home" decision.

## Risks & Mitigations

- **Cross-reference between the two moved files** (`paper-definitions-of-record.md` ->
  `total-history-validity-decisions.md`) must be updated in the same commit as the move, or the
  two new locations will cite each other's now-broken pre-move paths. Mitigation: explicit step
  (c) in Recommendations above; a plain grep of the destination content for the string
  `specs/decisions/` after the move will catch it.
- **Citation count discrepancy** (43 named vs. 47 raw-grepped here) could mean the planner
  undercounts remaining work if it trusts the task description's number over a fresh grep.
  Mitigation: this report already re-measures and explicitly flags re-measurement as the correct
  acceptance bar (zero-remaining-old-path via grep), not a fixed count.
- **`check-module-invariants.sh` C15 hardcodes the path outside the record file itself** — easy
  to miss because it looks like ordinary shell, not a "citation." Mitigation: called out
  explicitly above with the exact line number (1643).
- **Splitting the two record families across two destinations** (rather than one directory)
  could read as inconsistent. Mitigation: the genre distinction is real (reference manifest vs.
  decision record) and matches how `docs/` is already organized; recording the rationale
  explicitly in both destination READMEs' catalog entries closes this risk.

## Context Extension Recommendations

- **Topic**: `specs/` vs `docs/` placement criterion for durable, code-cited records.
- **Gap**: `.claude/context/repo/project-overview.md` and `.claude/CLAUDE.md` describe `specs/`
  as the task-management tree and `docs/` as the durable documentation tree, but nowhere states
  the rule this task is establishing ("if a `specs/` file is cited from live Lean code as ground
  truth, it does not belong in `specs/`").
- **Recommendation**: once this task's move lands, add a one-line rule to
  `docs/README.md` (or wherever the implementer records the WORK item 3 rationale) stating this
  placement criterion, so a future contributor creating a new durable record starts in `docs/`
  rather than `specs/` in the first place.

## Appendix

### Search queries / commands used

```
grep -rn "paper-definitions-of-record" --include="*.lean" .
grep -rn "specs/decisions" --include="*.lean" .
grep -rln "paper-definitions-of-record" --include="*.md" . | grep -v /.git/ | grep -v ^./specs/archive
grep -rln "specs/decisions" --include="*.md" . | grep -v /.git/ | grep -v ^./specs/archive
grep -n "C13\|C15" scripts/check-module-invariants.sh
git ls-files specs/paper-definitions-of-record.md specs/decisions/
grep -n "specs" .gitignore
grep -n '\](' specs/decisions/*.md specs/paper-definitions-of-record.md
```

### References

- `specs/reviews/review-2026-09-16.md` (Finding H2 — origin of the paper-vocabulary drift work
  this task precedes)
- `specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md`
  (N2 item definition, dependency DAG placing this task in wave 1)
- `docs/architecture/README.md` (ADR catalog, "one ADR convention" statement, Specification
  Documents table)
- `docs/reference/README.md`, `docs/README.md` (destination catalog precedents)
- `scripts/check-paper-definitions.sh`, `scripts/check-module-invariants.sh` (C15 hardcoded path)
- `.claude/CLAUDE.md` Project Structure section; `.claude/rules/no-task-references-in-deliverables.md`
  (specs/** exemption scope)
