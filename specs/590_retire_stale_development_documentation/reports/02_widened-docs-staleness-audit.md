# Research Report: Task #590 (Round 2 — Widened Scope)

**Task**: 590 - Retire stale development documentation
**Started**: 2026-09-17T07:48:52Z
**Completed**: 2026-09-17T07:54:11Z
**Effort**: Large (planner note: split into phases; do not truncate)
**Dependencies**: 595 (durable-records-home) — completed; no records to protect from this round
**Sources/Inputs**:
- Codebase: `FormalSystem/Automation.lean`, `FormalSystem/Automation/Tactics/{Commands,UserTactics,Search}.lean`, `FormalSystem/Boneyard/RetiredTactics/`
- `docs/user-guide/{tutorial,examples,tactic-development,troubleshooting}.md`,
  `docs/project-info/{tactic-registry,FEATURE_REGISTRY,test-coverage,implementation-status,performance-targets}.md`,
  `docs/development/METAPROGRAMMING_GUIDE.md`, `docs/reference/API_REFERENCE.md`
- `docs/research/leansearch-*.md`, `docs/training/PIPELINE.md`, `docs/research/NONCOMPUTABLE.md`,
  `docs/project-info/MAINTENANCE.md`, `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md`
- `.claude/context/standards/task-reference-exemptions.md`, `scripts/check-module-invariants.sh`
  (C9D block, ~line 3527), `.github/workflows/ci.yml`, `docs/development/CI_CD_PROCESS.md`
- `specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md`
  (source of the widened-scope directive), `specs/595_establish_durable_records_home/` (dependency, completed),
  `specs/578_fix_api_documentation_ci_integration/` (package-name decision owner), `specs/583_wire_check_scripts_into_ci/` (ENFORCE-flip precedent)
- Round-1 report: `specs/590_retire_stale_development_documentation/reports/01_stale-docs-and-task-citations.md`
- `cloc`, `git`, `grep`
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md, task-reference-exemptions.md

## Executive Summary

- **Round 1** (report `01_...md`) already covers the original scope: the 142 citations,
  `PHASED_IMPLEMENTATION.md` (delete), `LATEX_STANDARDS.md` (decide `latex/`'s status). This
  report covers only the **WIDENED** scope added 2026-09-16: retired-tactic prose, the
  `leansearch-*.md` files, three `project-info` status docs, the naming inconsistency, and the
  `ENFORCE_C9_DOCS` CI-flip mechanics. Dependency 595 is **completed**; it already relocated the
  two durable-record families out of `specs/` and this round touches none of that content, so
  there is nothing 595 settled for this round to avoid disturbing.
- **Retired-tactic prose is real and worse than the dispatch's spot-check found.** `tm_auto`,
  `temporal_search`, and `propositional_search` were all removed in favor of a single
  `modal_search` entry point (`FormalSystem/Automation.lean:34-37`, boneyard note at
  `FormalSystem/Boneyard/RetiredTactics/AesopRules.lean:25`). Six of the nine named files present
  `tm_auto`/`temporal_search`/`propositional_search` as live, working tactics with runnable
  examples. `docs/reference/API_REFERENCE.md`'s tactic tables are the worst case: its
  "Operator-Specific Tactics" table (`modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`,
  `modal_b_tactic`, `temp_4_tactic`, `temp_a_tactic`) names **six tactics that do not exist
  anywhere in the current tree**, not just the three named in the dispatch.
- **`FEATURE_REGISTRY.md` and `test-coverage.md` (the two "no match" files) are not clean.**
  `FEATURE_REGISTRY.md`'s Custom Tactics file list cites `Helpers.lean`, which does not exist in
  `FormalSystem/Automation/Tactics/` (the real files are `Commands.lean`, `Deduction.lean`,
  `Meta.lean`, `PropDecide.lean`, `Search.lean`, `UserTactics.lean`) — a different staleness
  class than the three retired-tactic names, exactly as the dispatch anticipated.
  `test-coverage.md` is already dispositioned: it carries a top-of-file "Superseded" banner
  (added by an earlier task) pointing readers to `known-limitations.md` and
  `implementation-status.md`, and citing `Automation.AesopRules`/`Automation.Tactics.modal_basics`
  only inside that already-disclaimed snapshot — no further action needed there.
- **The four `leansearch-*.md` files (1,451 lines) are Mathlib-API research notes, not content
  about this logic**, already indexed in `docs/README.md` and `docs/research/README.md`. They
  read as design-provenance inputs to the `ProofSearch`/`SuccessPatterns` modules (best-first
  search, priority queues, proof caching) rather than active reference material — no evidence
  found that anything currently reads them as authoritative. Recommend: keep, but retitle/reframe
  as historical design-research provenance (not "current LeanSearch API"), OR retire under a
  `docs/research/archive/` tier with a one-line reason. Either is a recorded decision; deleting
  outright loses attributable design rationale for the search-strategy implementation.
- **`implementation-status.md` needs a genuine refresh**, not just a citation scrub: its
  "Overall Statistics" table is measurably wrong (539 files / 170,898 LOC / 96,290 comment lines
  vs. the current `cloc` measurement of 714 files / 182,556 LOC / 108,312 comment lines), its
  Layer 4 (Automation) section cites a `Tactics.lean` file that does not exist and omits
  `modal_search` (the actual unified entry point) from its "Working" list.
  **`performance-targets.md` is current** (re-measured 2026-09-16, matches the live API, no
  citations) — no action needed. **`test-coverage.md`** — see above, already dispositioned.
- **The naming inconsistency is confirmed 5-way**: Lake package `Logos` (`lakefile.lean:4`),
  library `FormalSystem`, test library `BimodalTest`, repository directory/remote `BimodalLogic`,
  and root `CLAUDE.md`'s title **"ProofChecker"** (matching none of the above; the README's own
  title is the purely descriptive "A Bimodal Logic for Tense and Modality", naming no package).
  The dispatch is explicit that the **package-name decision belongs to task 578's `lakefile.toml`
  migration** — this task's scope is narrower: align `CLAUDE.md`'s prose (title + body) with the
  actual names in use, without touching `lakefile.lean`.
- **`ENFORCE_C9_DOCS` needs no separate CI wiring step.** `.github/workflows/ci.yml`'s "Check
  module invariants" step (line 84) already runs `bash scripts/check-module-invariants.sh
  --no-build` with **no `ENFORCE_*` environment overrides anywhere in the workflow file** (`grep
  -n ENFORCE .github/workflows/ci.yml` is empty). Flipping the script's own default at
  `scripts/check-module-invariants.sh:528` (`ENFORCE_C9_DOCS=${ENFORCE_C9_DOCS:-0}` ->
  `${ENFORCE_C9_DOCS:-1}`) is both necessary and sufficient — CI inherits it automatically, the
  same way C9/C10 (both already `ENFORCE_*=1` by default) are enforced today with zero
  workflow-file changes. The one genuinely new step is documentation: add a row/note to
  `docs/development/CI_CD_PROCESS.md` recording the flip (that file currently has zero
  `ENFORCE`/`C9D` mentions), following 583's pattern of recording *why* a check went from
  soft-reported to gating, not adding a new workflow step.
- **One concrete "actively wrong" citation, found and verified dead**: ADR-004
  (`docs/architecture/ADR-004-Remove-Project-Level-State-Files.md:227-228`) cites
  `specs/276_investigate_remove_redundant_project_level_state_json/{reports/research-001.md,
  plans/implementation-001.md}`. That directory does not exist anywhere in the repository today
  — not in `specs/`, not in `specs/archive/`, not in `specs/vault/`. The number 276 has since been
  reused: `specs/archive/276_strong_release_trigger_operators` is a *different* task. This is the
  vault-operation collision the dispatch warned about, concretely instantiated.

## Context & Scope

Round 1 (report `01_stale-docs-and-task-citations.md`) is untouched and remains valid for its
scope (the 142 citations, `PHASED_IMPLEMENTATION.md`, `LATEX_STANDARDS.md`). This round
researches only the six widened-scope bullets added 2026-09-16 to the task description, sourced
from `specs/593_.../reports/01_cleanup-topic-reorganization.md`'s reorganization sweep. Dependency
595 (durable-records-home) is confirmed **completed**, moved two record families to
`docs/reference/` and `docs/architecture/`, and touches none of the files in this round's scope —
so the "do not move or delete records it has settled" constraint imposes no restriction here.

## Findings

### 1. Retired-tactic prose (`tm_auto`, `temporal_search`, `propositional_search`)

Confirmed retired in `FormalSystem/Automation.lean:34-37`: `modal_search` "replaced
`temporal_search`, `propositional_search` and `tm_auto`, which differed from it only in
`SearchConfig` weight fields that `searchProof` never read, and which have been removed." Only 3
`.lean` files under `FormalSystem/` still mention these names at all, and all three are
retirement records (`Automation.lean`'s docstring, `Boneyard/RetiredTactics/{AesopRuleSet,
AesopRules}.lean`, which are explicitly excluded from compilation/linting).

Per-file grep results (occurrence count, line numbers):

| File | Occurrences | Names present |
|---|---|---|
| `docs/user-guide/tutorial.md` | 1 (line 278) | `tm_auto` |
| `docs/user-guide/examples.md` | 1 (line 445) | `tm_auto` |
| `docs/user-guide/tactic-development.md` | 9 (392-420, 663, 737) | `tm_auto`, `temporal_search` |
| `docs/user-guide/troubleshooting.md` | 3 (272, 276, 281) | `tm_auto` |
| `docs/project-info/tactic-registry.md` | 11 (24-156) | `tm_auto`, `temporal_search`, `propositional_search` |
| `docs/project-info/FEATURE_REGISTRY.md` | 0 | none of the three, but see below |
| `docs/project-info/test-coverage.md` | 0 | none of the three, but see below |
| `docs/development/METAPROGRAMMING_GUIDE.md` | 3 (19, 436, 604) | `tm_auto` |
| `docs/reference/API_REFERENCE.md` | 5 (385-421, 905-907) | `tm_auto`, `temporal_search` |

**Severity varies by file** — this is not a uniform find-and-replace:
- `docs/user-guide/tutorial.md:278` and `examples.md:445` present `tm_auto` as a normal working
  example alongside `modal_t`/`modal_search`, with no caveat. These examples would fail to
  compile today.
- `docs/user-guide/troubleshooting.md` section 4.2 documents `tm_auto` as *buggy* ("aesop:
  internal error during proof reconstruction") and tells the reader to use `modal_search`
  instead — the workaround is correct, but the premise (that `tm_auto` still exists and merely
  errors on some inputs) is stale; the tactic is gone, not flaky. The section needs rewriting to
  say `tm_auto` was retired, not that it fails.
- `docs/reference/API_REFERENCE.md` is the worst case (see finding 2 below): beyond the 3 named
  retired tactics, its whole "Operator-Specific Tactics" table names 6 tactics with **zero**
  matches anywhere in `FormalSystem/Automation/Tactics/*.lean`
  (`modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic`, `temp_4_tactic`,
  `temp_a_tactic`). `temp_a_tactic`/`temp_4_tactic` are doubly stale: `performance-targets.md`'s
  own 2026-09-16 note already records that `temp_4` "is no longer an axiom constructor."
- `docs/project-info/tactic-registry.md` is the densest concentration (11 occurrences across a
  134-line file) and is explicitly the "Theory-Specific Registry" that `FEATURE_REGISTRY.md`
  points readers to for tactic detail — it needs the most substantial rewrite of the nine.
- `docs/development/METAPROGRAMMING_GUIDE.md` lines 19 and 436-438 use `tm_auto` as a worked
  example of "good error messages" style (`throwError "tm_auto: could not find proof..."`) —
  illustrative meta-programming prose, not a claim that the tactic is live, but it should cite a
  tactic that still exists (e.g. `modal_search`) so the guide's own example stays runnable advice.

**Current replacement surface** confirmed in `FormalSystem/Automation/Tactics/`:
`Commands.lean` (`modal_search`, with `depth`/named-parameter forms), `UserTactics.lean`
(`apply_axiom`, `modal_t`, `assumption_search`), `Deduction.lean`, `Meta.lean`, `PropDecide.lean`,
`Search.lean`. Every doc fix in this section should retarget prose/examples at this set.

### 2. `FEATURE_REGISTRY.md` and `test-coverage.md` — the "no match" files, re-examined

The dispatch flagged these two as needing a re-grep "for other retired names" since neither
matched the three canonical tactic names at reorganization time. Confirmed both, with different
outcomes:

- **`FEATURE_REGISTRY.md`** (97 lines): its "Custom Tactics" entry
  (`docs/project-info/FEATURE_REGISTRY.md:59-61`) lists `Key Files: FormalSystem/Automation/Tactics/`
  `(Commands.lean, Deduction.lean, Helpers.lean, PropDecide.lean)`. `Helpers.lean` does not exist
  in that directory (`ls FormalSystem/Automation/Tactics/` → `Commands.lean, Deduction.lean,
  Meta.lean, PropDecide.lean, README.md, Search.lean, UserTactics.lean`) — `Meta.lean`,
  `Search.lean`, and `UserTactics.lean` are all missing from the doc's list. This is a plain file-
  inventory staleness, independent of the three retired-tactic names; fix is a one-line list
  update.
- **`test-coverage.md`** (164 lines): already carries a "Superseded" banner
  (`docs/project-info/test-coverage.md:7-11`) added by an earlier task, stating the 2026-01-12
  snapshot is stale, the generating script no longer exists, and pointing to
  `known-limitations.md` / `implementation-status.md` for current status. Its
  `Automation.AesopRules` and `Automation.Tactics.modal_basics`/`temporal_basics` mentions
  (lines 55, 88-90, 98-99) sit entirely inside that disclaimed historical snapshot. **No further
  action recommended** — the file is already retired-in-place with a recorded reason, which is
  exactly the disposition the widened-scope bullet asks for.

### 3. `docs/research/leansearch-*.md` (four files, 1,451 lines)

`leansearch-api-specification.md` (553), `leansearch-best-first-search.md` (277),
`leansearch-priority-queue.md` (480), `leansearch-proof-caching-memoization.md` (141). All dated
December 2025 ("Research Date: December 21, 2025" / "Date: Sun Dec 21 2025"), last touched
2026-07-26 per the dispatch. Content is Mathlib/Lean-ecosystem API research (LeanSearch,
LeanStateSearch, Loogle services; `Mathlib.Deprecated.MLList.BestFirst`; Batteries heap
implementations; Mathlib memoization patterns) — not about the bimodal logic itself. Both
`docs/README.md:440-443` and `docs/research/README.md:108-111,174-198` already index them, so
they are discoverable, not orphaned.

These plausibly informed the design of `FormalSystem/Automation/ProofSearch/` (which implements
IDDFS/BoundedDFS/BestFirst strategies) and `SuccessPatterns.lean` (pattern learning/caching) — no
direct code comment cites them, but the topical match (best-first search, priority queue,
caching) to the implemented `ProofSearch`/`SuccessPatterns` modules is exact. Three honest
dispositions, none clearly forced by evidence found:
1. **Keep, reframed**: retitle as historical design-research provenance for the
   `ProofSearch`/`SuccessPatterns` implementation, with a one-line note in
   `docs/research/README.md` saying so (currently the index presents them as if reporting on
   live upstream API surface, which risks going stale relative to Mathlib itself, not this repo).
2. **Retire with a reason**: move to `docs/research/archive/` (or similar) with a short banner
   like `test-coverage.md`'s, recording that the design decisions they informed are now
   implemented and the files are kept only for provenance.
3. **Delete**: loses attributable design rationale; not recommended without a stronger case that
   the ~1,450 lines cost more than they're worth.
This task's plan should pick one and record why — the dispatch's own phrasing ("keep, move, or
retire with a recorded reason") anticipates exactly this three-way choice.

### 4. `docs/project-info/{implementation-status,performance-targets,test-coverage}.md`

- **`implementation-status.md`** (190 lines) — **needs a refresh**, not a citation fix (it has
  none). Two concrete defects found:
  - "Overall Statistics" table (`implementation-status.md:150-156`) states 539 Lean files /
    170,898 LOC / 96,290 comment lines / 0 sorries. Reproducing its own prescribed command
    (`cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .`) today measures
    **714 files / 182,556 code lines / 108,312 comment lines** (sorry count of 0 still holds,
    per C3). The doc itself says "Do not hardcode these figures elsewhere. Reproduce them" —
    good process, but the hardcoded copy in the doc itself is now wrong by ~33% on file count.
  - Layer 4 (Automation) section (`implementation-status.md:127-141`) lists `Tactics.lean` as a
    module with status ✅ "Core tactics working" — no such file exists (the real module is the
    `Automation/Tactics/` directory with six files, see finding 1). The "Working" bullet list
    (`modal_t`, `apply_axiom`, Aesop integration) omits `modal_search`, the actual unified
    proof-search entry point, and the "Issues" bullet ("Bounded search timeout issues") should
    be re-verified against current `ProofSearch` behavior rather than carried forward unchanged.
  - The `Examples/` module table (2 files: `BimodalProofs.lean`, `TemporalStructures.lean`)
    **does match** the current `FormalSystem/Examples/` directory — not everything in the file
    is stale, only the Automation section and the statistics table.
- **`performance-targets.md`** (103 lines) — **current, no action needed**. Dated "Last updated:
  2026-09-16" with a "History" entry recording the same date's re-measurement; explicitly notes
  `Axiom (Modal-Future)` replacing the retired `Axiom (Temporal 4)` row because `temp_4` "is no
  longer an axiom constructor," and that the semantic-evaluation suite was retired to
  `FormalSystem/Boneyard/SemanticBenchmarkToyEvaluator/` for testing nothing real. This file is
  itself a template for how the other two should read once refreshed.
- **`test-coverage.md`** — see finding 2; already dispositioned via its "Superseded" banner.

### 5. Naming inconsistency and the `CLAUDE.md` title

Confirmed 5 distinct names in live use:

| Surface | Name | Source |
|---|---|---|
| Lake package | `Logos` | `lakefile.lean:4` (`package Logos where`) |
| Library | `FormalSystem` | `lakefile.lean:17` (`lean_lib FormalSystem where`) |
| Test library | `BimodalTest` | `lakefile.lean:22-24` |
| Repository (dir/remote) | `BimodalLogic` | working-tree dirname; README's CI badge URL (`github.com/benbrastmckie/BimodalLogic`) |
| Root `CLAUDE.md` title | `ProofChecker` | `CLAUDE.md:1` (`# ProofChecker`) |
| README title (for contrast) | *(no proper name)* | `README.md:1`, `# A Bimodal Logic for Tense and Modality` |

`README.md:5` names the umbrella project explicitly: "This repository implements the **bimodal
fragment** of the [Logos](https://logos-labs.ai/)" — so `Logos` (the Lake package name) is not
arbitrary; it names the parent research programme this repository is one fragment of. `CLAUDE.md`'s
"ProofChecker" title matches none of the five surfaces and appears to be inherited boilerplate
(a generic name for "a Lean repo that checks proofs") rather than a considered choice.

Task 578 (`fix_api_documentation_ci_integration`, status `researching`) explicitly owns "settle
the package name as part of the [lakefile.toml] migration... Record the choice (keep `Logos`, or
rename to `FormalSystem`/`BimodalLogic`) and its downstream effect on doc URLs." This task's
scope is therefore: **fix `CLAUDE.md`'s title and any body prose that assumes "ProofChecker" as
the project's name**, aligning it with the actual names in use (most naturally, drop the generic
title, or retitle to something reflecting `BimodalLogic`/the bimodal-TM description that matches
`README.md`), **without** touching `lakefile.lean`'s `package Logos` line or pre-empting 578's
decision.

### 6. `ENFORCE_C9_DOCS` — flipping the flag and the CI-wiring question

`scripts/check-module-invariants.sh:520-528` shows the enforcement-flag block:
```
ENFORCE_C9=${ENFORCE_C9:-1}   # no task-number citations under FormalSystem/ (enforced)
ENFORCE_C10=${ENFORCE_C10:-1} # no stale docs/latex/typst paths (enforced)
...
ENFORCE_C9_DOCS=${ENFORCE_C9_DOCS:-0} # no task-number citations under docs/ (NOT yet enforced)
```
The C9D check itself (`scripts/check-module-invariants.sh:3527-3550`) computes the citation count
unconditionally every run and only the flag gates whether a nonzero count fails the script
(`fail` vs `soft`). This is intentional per the comment directly above it: "the computation runs
from the outset and is REPORTED at every gate, while only the flag controls whether it affects
the exit code... Do not flip the flag to 0 once it is 1."

`.github/workflows/ci.yml` invokes this script bare — `grep -n ENFORCE .github/workflows/ci.yml`
returns **nothing**; the "Check module invariants" step (`ci.yml:84-89`) is just
`bash scripts/check-module-invariants.sh --no-build` with no environment overrides. This means
**the only change needed to make CI gate on C9D is flipping the script's own default** from
`${ENFORCE_C9_DOCS:-0}` to `${ENFORCE_C9_DOCS:-1}` — CI already runs the script and will pick up
the new default automatically, exactly as it already does for `ENFORCE_C9`/`ENFORCE_C10` (both
default 1, no corresponding workflow-file entries either). No new CI step, job, or workflow edit
is required.

583's precedent (`docs/development/CI_CD_PROCESS.md`) documents wiring *new script invocations*
into CI as named steps — not applicable here, since `check-module-invariants.sh` is already
wired. The parallel worth following from 583 is **recording the change**: `grep -n
"ENFORCE\|C9D" docs/development/CI_CD_PROCESS.md` returns nothing today, so this task should add
a short note (a line or short paragraph, not a new "Wiring a New Check Script" subsection) stating
that C9D became gating on this date, once the citation count reaches zero. This is a
documentation-completeness step, not a functional CI change.

**Sequencing constraint carried forward from round 1**: flipping the default must happen *after*
the citation count is verified at zero (or only `task-ref-ok`-marked), including the
widened-scope work in this report — the ADR-004 dead citation (finding 7 below) and the
BimodalHarness/PIPELINE.md illustrative task-number examples (finding 8) are both in the C9D
scan's regex scope and must be resolved first.

### 7. Verified dead citation: ADR-004's task-276 references

`docs/architecture/ADR-004-Remove-Project-Level-State-Files.md` cites task 276 four times
(lines 25, 227, 228, 229, 251 — "Comprehensive analysis (Task 276, research-001.md)", two
`specs/276_investigate_remove_redundant_project_level_state_json/{reports/research-001.md,
plans/implementation-001.md}` paths, "Task: Task 276 in `specs/TODO.md`", "Author: Task 276
Implementation"). This directory **does not exist** anywhere in the repository:
`find specs -iname "*investigate_remove_redundant*"` and equivalent searches of `specs/archive/`
and `specs/vault/` all return empty. The number 276 has been reused post-vault-operation:
`specs/archive/276_strong_release_trigger_operators` is today's task 276, an unrelated topic.

This is exactly the scenario `.claude/rules/no-task-references-in-deliverables.md` and the
dispatch both warn about — a vault operation renumbered tasks, and this ADR's citations are now
not just opaque but **actively wrong** (they point at a task number that now means something
else). Per the exemption taxonomy, an ADR legitimately naming the task that produced it is
Category-eligible for a `task-ref-ok` marker, but marking a citation that is *factually
incorrect* would misrepresent provenance rather than preserve it. Recommended fix: replace the
task-number citations with the durable fact (the decision content is fully self-contained in the
ADR's own Context/Decision/Consequences sections) and drop the now-unresolvable path citations
entirely, or replace them with "historical implementation task, details not preserved after a
repository renumbering" if provenance-of-provenance is worth keeping at all.

### 8. Other exemption-taxonomy-relevant findings in the remaining 21 citations

Spot-checked the four "other" files (`PIPELINE.md` 11ish, `NONCOMPUTABLE.md` 5,
`MAINTENANCE.md` 5, `ADR-004` 5 — see finding 7 for ADR-004) for exemption-category fit before
handing this to planning, since round 1 flagged these as "per-citation" fixes:

- **`docs/training/PIPELINE.md`** — two distinct citation shapes:
  - `PIPELINE.md:4` ("Provenance: Tasks 201 (alphazero_proof_search_harness), 203
    (formula_enumerator_dataset_export), 209 (document_training_pipeline)") and `:10` ("task 313
    Phase 10") all **resolve correctly** — verified `specs/archive/{201_alphazero_proof_search_
    harness, 203_formula_enumerator_dataset_export, 209_document_training_pipeline,
    313_design_full_extent_bimodalreference_book}` all exist. These are not wrong, just citing an
    ephemeral identifier per the rule's own rationale — and since each already carries its slug
    in parens, the fix is mechanical: drop the bare numbers, keep the slugs
    (`alphazero_proof_search_harness`, etc.) as the durable anchor.
  - `PIPELINE.md:643-647`, a "Downstream Tasks Using Pipeline Output" table with rows "Task 4:
    Tokenizer", "Task 5: Text serializer", etc. — these are numbers from a **different
    repository's** task list (`BimodalHarness`, an external, artifact-only-integrated project per
    line 10's "Canonical narrative" note), not this repo's `specs/`. They will never resolve
    against `specs/state.json` and are not affected by this repo's vault operations, but the
    literal C9D/`check-task-references.sh` regex (`\btasks?[[:space:]]+#?[0-9]+\b`) matches them
    regardless of which repo they belong to. Simplest fix: drop the numbers from the table (the
    "Uses" column already fully describes each row; "Tokenizer" / "Text serializer" / etc. need
    no numeric prefix to be legible) rather than marking them `task-ref-ok` for a category that
    doesn't quite fit any of the seven listed.
- **`docs/project-info/MAINTENANCE.md`** — three shapes:
  - `MAINTENANCE.md:250,674` (`specs/025_soundness_automation_implementation`,
    `specs/007_emoji_removal`) and the surrounding `grep -r "Task 7" specs/*/summaries/` /
    `git log --all --grep="Task 7"` lines (:207, :238) are **illustrative example commands**
    inside a "Git Log Queries" / "Spec Summary Queries" section — the numbers are placeholders
    standing in for "some task," not real citations. This is Category 3 (command-usage examples)
    territory, but the cleaner fix (avoiding a marker entirely) is to swap the literal digits for
    the `{N}` placeholder convention already established in `.claude/rules/git-workflow.md`
    (`task {N}: {action}`) — e.g. `git log --all --grep="Task {N}"`,
    `cat specs/{NNN}_{slug}/summaries/...` — since `{N}`/`{NNN}` are not matched by the citation
    regex at all (Category 5, "placeholder-bearing prose," is explicitly never-matched).
  - `MAINTENANCE.md:587` ("Task 169: Implemented clean-break approach for /implement command...")
    — task 169 **does not resolve** (`specs/archive/169_*` not found), and no matching content
    was found in `specs/CHANGE_LOG.md` either. This is a second vault-operation casualty like
    ADR-004's task 276, just for a `.claude/` system-level fact rather than a math result.
    Recommended fix: drop the number, state the fact plainly ("The `/implement` command uses a
    clean-break approach — no backward-compatibility layers are maintained") since the number
    cannot currently be verified against anything in the repository.
- **`docs/research/NONCOMPUTABLE.md`** — all 5 occurrences are `task 192` (lines 18, 156, 163,
  616, 677), consistently citing the same task as the origin of the noncomputability analysis.
  Not independently verified for resolution in this pass (out of the per-line grep budget for
  this round); flag for the planner to verify `specs/archive/192_*` resolves before deciding
  between rewriting-with-durable-anchor vs. `task-ref-ok`-marking as an ADR-shaped provenance
  note (this file already has a "Related: ADR-001" pointer, so it plausibly deserves the same
  provenance treatment as an ADR).

## Decisions

- Scope this round strictly to the widened-scope bullets; leave round-1's citation/
  `PHASED_IMPLEMENTATION.md`/`LATEX_STANDARDS.md` work to round 1's own report and the plan that
  follows it.
- Recommend the `leansearch-*.md` files be **kept and reframed** as design-provenance documents
  rather than deleted, given the topical match to already-implemented `ProofSearch`/
  `SuccessPatterns` modules and the absence of any evidence they mislead a current reader about
  this repository's own API (they are honestly scoped to Mathlib/LeanSearch, not to `FormalSystem`).
  This is a recommendation, not a foreclosed decision — the plan should record whichever of the
  three dispositions in finding 3 it picks and why.
- `implementation-status.md` needs an actual refresh pass (stats + Automation section), not a
  citation-only touch; `performance-targets.md` needs nothing; `test-coverage.md` needs nothing
  further (already dispositioned).
- `CLAUDE.md`'s title/body-naming fix is in scope; `lakefile.lean`'s `package Logos` line and any
  final naming *decision* are explicitly out of scope (task 578's).
- `ENFORCE_C9_DOCS`'s CI "wiring" reduces to (a) flipping the script default once C9D is
  genuinely zero, verified across BOTH round 1's and this round's citation fixes, and (b) a short
  documentation note in `CI_CD_PROCESS.md` — no workflow-file edit is needed.

## Risks & Mitigations

- **Risk**: treating the nine retired-tactic files as a uniform "s/tm_auto/modal_search/" pass
  under-fixes `API_REFERENCE.md` and `tactic-registry.md`, which have structural tables naming
  tactics that never existed under any name captured by the three canonical retired names.
  **Mitigation**: the plan should budget a dedicated pass for `API_REFERENCE.md`'s two tactic
  tables and `tactic-registry.md`'s full body, not a mechanical substitution.
- **Risk**: deleting the `leansearch-*.md` files outright, as done for `PHASED_IMPLEMENTATION.md`
  in round 1, discards the only recorded rationale for design choices in `ProofSearch`/
  `SuccessPatterns` (best-first search, priority queue, caching strategy), none of which appear
  restated elsewhere. **Mitigation**: prefer reframe-or-archive over delete for this specific
  cluster; round 1's "delete a dead roadmap" precedent does not transfer cleanly.
- **Risk**: fixing ADR-004's and `MAINTENANCE.md`'s dead task-276/169 citations by simply deleting
  the numbers could read as erasing genuine provenance if a reader later needs "what task did
  this." **Mitigation**: this is judged acceptable here specifically because the citations are
  *unresolvable* (the vault operation already destroyed the provenance trail); keeping a broken
  pointer is strictly worse than stating the fact without it.
- **Risk**: flipping `ENFORCE_C9_DOCS`'s default before every widened-scope file (not just round
  1's five) is actually clean will make CI red on the very next run touching any of the nine
  retired-tactic files or the leansearch/project-info files if they still carry citations.
  **Mitigation**: this task's own plan should schedule the flip as its last phase, after a fresh
  C9D re-run over the full scope (round 1 + this round) confirms zero unmarked citations.

## Context Extension Recommendations

- None — this is a `markdown` task auditing existing docs; no gap in `.claude/context/` coverage
  was identified during this round.

## Appendix

### Search queries / commands used

```bash
grep -noE 'tm_auto|temporal_search|propositional_search' <each of the nine files>
grep -rn "tm_auto|temporal_search|propositional_search" FormalSystem/ --include=*.lean
grep -rln "tm_auto|temporal_search|propositional_search" FormalSystem/ --include=*.lean | wc -l
ls FormalSystem/Automation/Tactics/
grep -rn "modal_k_tactic|temporal_k_tactic|modal_4_tactic|modal_b_tactic|temp_4_tactic|temp_a_tactic|modal_search\b" FormalSystem/Automation/Tactics/*.lean
cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .
ls FormalSystem/Examples/
grep -rln "leansearch-" docs/ FormalSystem/ README.md
grep -n "leansearch-" docs/README.md docs/research/README.md
grep -n "^package\|name =" lakefile.lean; head -5 CLAUDE.md README.md
grep -n "ENFORCE" .github/workflows/ci.yml scripts/check-module-invariants.sh docs/development/CI_CD_PROCESS.md
find specs specs/archive specs/vault -iname "*investigate_remove_redundant*" -o -iname "276_*" -o -iname "169_*" -o -iname "007_*" -o -iname "025_*"
python3 -c "json.load(open('specs/state.json'))" (task 595/583/578 status and completion_summary lookups)
```

### References

- Round-1 report: `specs/590_retire_stale_development_documentation/reports/01_stale-docs-and-task-citations.md`
- Widened-scope source: `specs/593_revise_task_organization_codebase_cleanup/reports/01_cleanup-topic-reorganization.md`
- Dependency: `specs/595_establish_durable_records_home/summaries/01_durable-records-home-summary.md`
- Precedents: `specs/583_wire_check_scripts_into_ci/summaries/02_wire-check-scripts-ci-summary.md`,
  `specs/578_fix_api_documentation_ci_integration/` (package-name decision owner, `researching`)
