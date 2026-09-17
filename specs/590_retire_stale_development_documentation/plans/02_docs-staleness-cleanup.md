# Implementation Plan: Task #590

- **Task**: 590 - Retire stale development documentation (widened: `docs/` staleness audit)
- **Status**: [NOT STARTED]
- **Effort**: 9.5 hours
- **Dependencies**: 595 (durable-records-home, completed; settles nothing in this plan's file set)
- **Research Inputs**:
  - specs/590_retire_stale_development_documentation/reports/01_stale-docs-and-task-citations.md
  - specs/590_retire_stale_development_documentation/reports/02_widened-docs-staleness-audit.md
- **Artifacts**: plans/02_docs-staleness-cleanup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Clear every unmarked task-number citation under `docs/` (C9D currently reports 142), retire the
two stale development docs, correct retired-tactic prose across nine docs, dispose of the
LeanSearch research notes and the stale project-info status docs, align the naming prose, and
finally flip `ENFORCE_C9_DOCS` to default 1 so CI gates on it. The work is split into eight
phases, each sized to one agent run, with file territories kept disjoint so Wave 1 can run in
parallel. The flip is last and depends on everything else.

### Research Integration

- Report 01: C9D breakdown (`PHASED_IMPLEMENTATION.md` 100, `PIPELINE.md` 11,
  `NONCOMPUTABLE.md` 5, `MAINTENANCE.md` 5, ADR-004 5); delete `PHASED_IMPLEMENTATION.md`;
  decide what `latex/` is and rewrite `LATEX_STANDARDS.md` to match; update all referrers in the
  same change so C13 stays green.
- Report 02: retired-tactic occurrences per file (and six nonexistent operator-specific tactics in
  `API_REFERENCE.md`); `FEATURE_REGISTRY.md` lists a nonexistent `Helpers.lean`;
  `test-coverage.md` and `performance-targets.md` need no action; `implementation-status.md`
  needs a real refresh (statistics table, Automation section); `leansearch-*.md` keep-reframe
  recommendation; ADR-004's task-276 and MAINTENANCE's task-169 citations are vault casualties
  (unresolvable); `PIPELINE.md` provenance numbers resolve and carry slugs, and its downstream
  table uses another repository's numbering; the flip needs no workflow edit, because CI runs the
  script bare and inherits its default.

**Planner verification during this dispatch** (facts added beyond the reports):
- `NONCOMPUTABLE.md` cites "task 192" as the GeneralizedNecessitation termination fix, but
  `specs/archive/192_master_tactic_dispatch` is an unrelated task, so this is a third vault
  casualty. Rewrite it with a durable anchor (`GeneralizedNecessitation.lean`). Do not mark it
  `task-ref-ok`.
- `docs/development/MODULE_INVARIANTS.md:190-196` uses `ENFORCE_C9_DOCS` as "the live example"
  of a soft flag defaulting to 0, and names `PHASED_IMPLEMENTATION.md`. Once the flip happens this
  paragraph is false, so Phase 8 must rewrite it.
- "ProofChecker" is not only boilerplate in the `CLAUDE.md` title. It is the project's
  architecture-role name in the Logos dual-verification pairing (`README.md:368`,
  `typst/chapters/p4-dual-verification.typ:20`), and it appears about 150 times across `docs/`,
  `typst/`, `latex/` and a few `.lean` docstrings. See the Decisions section.
- `latex/` is tracked (18 files: `BimodalReference.{tex,pdf}`, `BimodalDemo.tex`, `assets/`,
  `subfiles/`, `latexmkrc`, READMEs), and `README.md:13` and `:351` link its PDF as a superseded
  edition that is not kept in sync.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consultation requested for this dispatch.

## Decisions

1. **`PHASED_IMPLEMENTATION.md`: delete.** Its goals (Tasks 1-11 of a Layer-0 roadmap) are all
   met. Before deleting, the implementer skims sections 6 and 7 plus References for anything
   durable that is not already restated elsewhere. The expected yield is nothing, and any real
   residue goes to `docs/development/MODULE_INVARIANTS.md` or the relevant README.
2. **`latex/`: a frozen historical edition, kept in place.** Archiving it would break `README.md`'s
   two PDF links and the "superseded edition" statement that has already been adopted.
   `LATEX_STANDARDS.md` is rewritten as a short note (about 2-4 paragraphs): what `latex/`
   contains, that it is frozen and not synced, that `typst/` is the maintained edition, and how to
   rebuild the PDF if ever needed (`latexmkrc` at `latex/`). The fictional `{Theory}/latex/`
   layout is removed.
3. **`leansearch-*.md`: keep and reframe as design-provenance** (report 02, disposition 1). Each
   file gets a short banner saying it is historical design research that informed
   `FormalSystem/Automation/ProofSearch/` and `SuccessPatterns.lean`, and is not a live API
   reference. `docs/research/README.md` gets a matching note. Reason recorded: they are the only
   written rationale for the best-first search, priority queue, and caching choices. Deleting them
   loses that rationale, and moving them would churn two index files for no reader benefit.
4. **Naming: record the mapping, do not mass-rename.** "ProofChecker" stays as the project's
   role name in the Logos architecture (paired with ModelChecker), which is how `README.md` and
   the Typst manual use it. `CLAUDE.md` gets a retitle and a short naming key: repository
   `BimodalLogic`, role name ProofChecker, Lake package `Logos` (decision owned by 578's toml
   migration), library `FormalSystem`, tests `BimodalTest`. Only concretely wrong usages are
   fixed, such as clone and `cd` paths in `docs/installation/` that name a `ProofChecker`
   directory when the repository is `BimodalLogic`. A repo-wide rename of the role name is out of
   scope. It would be a branding decision touching the Typst manual and `.lean` docstrings.
5. **Dead citations (tasks 276, 169, 192): replace with the durable fact, never mark.** A
   `task-ref-ok` marker on a citation that now resolves to a different task would misstate
   provenance.
6. **`PIPELINE.md` provenance (tasks 201/203/209/313): drop the numbers and keep the slugs** as
   the durable anchor. The downstream table's external-repository numbers ("Task 4: Tokenizer")
   lose their numeric prefix.
7. **`ENFORCE_C9_DOCS` "CI wiring" means flipping the script default plus a documentation note**
   in `CI_CD_PROCESS.md`. No workflow edit, because `ci.yml` invokes the script bare. This
   supersedes report 01's "hand to 583" step, which the widened scope reassigned to this task.

## Goals & Non-Goals

**Goals**:
- C9D reports 0 task-number citations under `docs/`, or only `task-ref-ok`-marked ones
- `ENFORCE_C9_DOCS` defaults to 1, `ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh --no-build` exits 0, and the change is documented
- No doc presents `tm_auto`, `temporal_search`, `propositional_search`, or the six nonexistent operator-specific tactics as live
- `PHASED_IMPLEMENTATION.md` deleted, `LATEX_STANDARDS.md` rewritten to match reality, and every referrer updated
- `leansearch-*.md` reframed, `implementation-status.md` refreshed, and `FEATURE_REGISTRY.md` file list corrected
- `CLAUDE.md` naming prose aligned, with a naming key

**Non-Goals**:
- Changing `lakefile.lean`'s `package Logos` or making the package-name decision (578)
- A repo-wide rename of "ProofChecker"
- Editing `typst/`, `latex/*.tex`, or any `.lean` file
- Touching `performance-targets.md` or `test-coverage.md` (already current or already dispositioned)
- Adding a CI workflow step

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting `PHASED_IMPLEMENTATION.md` misses a referrer, so C13/C5/C12 go red | M | M | `grep -rn PHASED_IMPLEMENTATION` over the repo excluding `specs/` before and after; run the full invariants script |
| Retired-tactic fixes done as a mechanical `s/tm_auto/modal_search/` under-fix the structural tables | M | M | Phase 4 is a dedicated rewrite of `API_REFERENCE.md` and `tactic-registry.md` against the actual tactic files; every named tactic is grepped in `FormalSystem/Automation/Tactics/` |
| Rewritten doc examples do not actually elaborate | M | M | Phases 4-5 check each changed runnable snippet with `lean_run_code` (or a scratch file with `lake env lean`) and mark any snippet left unverified as illustrative |
| New citations land under `docs/` from concurrent tasks before the flip, so CI goes red immediately | H | L | Phase 8 re-runs C9D fresh right before flipping, clears any newcomers, and flips only at exactly 0 |
| Concurrent sessions edit `docs/README.md` or other shared indexes | L | M | Targeted `git add -- <files>` per phase; re-read before editing; disjoint phase territories |
| `CLAUDE.md` naming edit conflicts with 578's later package decision | L | L | The naming key names 578 as owner of the package decision and states the current value only |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3, 4, 5, 6, 7 | -- |
| 2 | 2 | 1 |
| 3 | 8 | 1, 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel. Territory: each phase owns only the files
in its "Files to modify" list. Phase 2 follows Phase 1 because both edit `docs/README.md` and
`docs/development/README.md`. `docs/development/MODULE_INVARIANTS.md` belongs to Phase 8 alone.

### Phase 1: Retire PHASED_IMPLEMENTATION.md [NOT STARTED]

**Goal**: Delete the obsolete Layer-0 roadmap (100 of 142 citations) after folding forward
anything durable, and remove its index entries.

**Tasks**:
- [ ] Skim `docs/development/PHASED_IMPLEMENTATION.md` sections 6-7 and References for any content not restated elsewhere; fold any genuine residue into the appropriate README (expected: none; record the finding in the phase summary)
- [ ] `git rm docs/development/PHASED_IMPLEMENTATION.md`
- [ ] Remove its entries in `docs/README.md` (lines ~158 and ~246; renumber the reading-order list at ~246) and `docs/development/README.md` (~46)
- [ ] `grep -rn PHASED_IMPLEMENTATION --exclude-dir=specs --exclude-dir=.claude --exclude-dir=.git --exclude-dir=.lake .`: only `docs/development/MODULE_INVARIANTS.md:192` may remain (Phase 8 owns it)
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C5/C12/C13 PASS and C9D drops to about 42

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: C9D falls by exactly 100 and the only referrers are the three files named in
report 01. Confirm with the grep above and the C9D count before and after.

**Files to modify**:
- `docs/development/PHASED_IMPLEMENTATION.md` - delete
- `docs/README.md` - remove the two index entries
- `docs/development/README.md` - remove the table row

**Verification**:
- File gone; C5, C12, C13 PASS; `bash scripts/readme-lint.sh` PASS; C9D count reduced by 100

---

### Phase 2: Rewrite LATEX_STANDARDS.md for the frozen latex/ edition [NOT STARTED]

**Goal**: Replace the fictional `{Theory}/latex/` layout doc with an accurate short description of
`latex/` as a frozen, superseded edition (Decision 2).

**Tasks**:
- [ ] Read `latex/README.md`, `latex/latexmkrc`, and `README.md:13,351` to ground the description
- [ ] Rewrite `docs/development/LATEX_STANDARDS.md` (currently 170 lines) as a 2-4 paragraph note: contents of `latex/`, frozen and not synced, `typst/BimodalReference.typ` is maintained, and the rebuild command if ever needed. Remove the "ProofChecker"-specific boilerplate only where it describes the wrong layout
- [ ] Update descriptions in `docs/README.md` (~153) and `docs/development/README.md` (~32, ~84) to "frozen LaTeX edition" wording; drop it from any "read this first" ordering
- [ ] Update `docs/development/CONTRIBUTING.md:143` (`latex/` "LaTeX resources and templates") to "superseded LaTeX edition (frozen; see typst/)"
- [ ] Check `latex/README.md` agrees; if it prescribes a live workflow, add a one-line frozen banner (the only `latex/` edit allowed)

**Timing**: 45 minutes

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `docs/development/LATEX_STANDARDS.md` - rewrite
- `docs/README.md`, `docs/development/README.md`, `docs/development/CONTRIBUTING.md` - description updates
- `latex/README.md` - optional frozen banner

**Verification**:
- Every path named in the rewritten doc exists (`ls`); C5/C12/C13 PASS; readme-lint PASS

---

### Phase 3: De-cite the residual docs (PIPELINE, NONCOMPUTABLE, MAINTENANCE, ADR-004) [NOT STARTED]

**Goal**: Clear the remaining citations with durable anchors per
`.claude/context/standards/task-reference-exemptions.md` (read it first).

**Tasks**:
- [ ] Read `.claude/context/standards/task-reference-exemptions.md`
- [ ] `docs/training/PIPELINE.md`: line 4 provenance becomes slugs without numbers (`alphazero_proof_search_harness`, `formula_enumerator_dataset_export`, `document_training_pipeline`); line 10 "task 313 Phase 10" becomes a durable anchor (slug `design_full_extent_bimodalreference_book` or the reference-book chapter name); strip the numeric "Task N:" prefixes from the downstream table (~643-647); handle any remaining matches from `grep -niE` with the C9D regex
- [ ] `docs/research/NONCOMPUTABLE.md`: the 5 "task 192" mentions (3, 18, 156, 163, 616, 677; note line 3's `**Task**: 192` header) become references to the GeneralizedNecessitation.lean termination fix. The citation is a vault casualty (`specs/archive/192_*` is `master_tactic_dispatch`); do not mark it. Line 677's "Ready for implementation" status line goes (historical report)
- [ ] `docs/project-info/MAINTENANCE.md`: example commands (~207, ~238, ~250, ~674) become `{N}`/`{NNN}_{slug}` placeholders; line ~587 "Task 169: ..." becomes the plain fact without the number
- [ ] `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md`: lines ~25, ~227-229, ~251 drop the task-276 citations and dead `specs/276_...` paths; state that the implementation record was not preserved after a repository renumbering, or remove it entirely
- [ ] Re-run the C9D grep, restricted to these four files, and confirm 0

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 42 citations across these four files (11+5+5+5 per the breakdown, plus
C9D-regex matches such as `specs/NNN_` paths possibly counted separately). Confirm by running the
C9D regex against each file before editing, and fix whatever it actually returns.

**Files to modify**:
- `docs/training/PIPELINE.md`, `docs/research/NONCOMPUTABLE.md`, `docs/project-info/MAINTENANCE.md`, `docs/architecture/ADR-004-Remove-Project-Level-State-Files.md`

**Verification**:
- `grep -rniE '\b(tasks?[[:space:]]+#?[0-9]+|task-[0-9]+)\b|specs/[0-9]{3}_[A-Za-z0-9_]+'` over the four files returns nothing; C13 PASS

---

### Phase 4: Rewrite tactic reference tables (API_REFERENCE, tactic-registry, FEATURE_REGISTRY) [NOT STARTED]

**Goal**: Make the structural tactic references match the real `FormalSystem/Automation/Tactics/`
surface. This is a real rewrite, not a substitution.

**Tasks**:
- [ ] Inventory the live tactics: grep `syntax`/`elab`/`macro` declarations in `FormalSystem/Automation/Tactics/{Commands,UserTactics,Deduction,Meta,PropDecide,Search}.lean` and read `FormalSystem/Automation.lean:34-37` (retirement note)
- [ ] `docs/reference/API_REFERENCE.md`: rewrite the tactic tables (~385-421) and the "Operator-Specific Tactics" table (remove `modal_k_tactic`, `temporal_k_tactic`, `modal_4_tactic`, `modal_b_tactic`, `temp_4_tactic`, `temp_a_tactic` unless the inventory finds them), fix ~905-907; add a one-line note that `tm_auto`/`temporal_search`/`propositional_search` were consolidated into `modal_search`
- [ ] `docs/project-info/tactic-registry.md`: rewrite the body (11 occurrences) against the inventory
- [ ] `docs/project-info/FEATURE_REGISTRY.md:59-61`: replace `Helpers.lean` with the actual six-file list
- [ ] Every tactic name left in the three files must grep-match in `FormalSystem/`. Verify runnable snippets with `lean_run_code` (import `FormalSystem`) where practical

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Only the six operator-specific names plus the three retired names are stale
in these files. Confirm by extracting every backticked identifier ending in `_tactic`/`_search` or
appearing in a tactic table, and grepping each against `FormalSystem/Automation/`.

**Files to modify**:
- `docs/reference/API_REFERENCE.md`, `docs/project-info/tactic-registry.md`, `docs/project-info/FEATURE_REGISTRY.md`

**Verification**:
- `grep -nE 'tm_auto|temporal_search|propositional_search|modal_k_tactic|temporal_k_tactic|modal_4_tactic|modal_b_tactic|temp_4_tactic|temp_a_tactic'` finds only explicit "retired" mentions; C5/C12/C13 PASS

---

### Phase 5: Fix retired-tactic prose in user guides and METAPROGRAMMING_GUIDE [NOT STARTED]

**Goal**: Retarget examples and prose that present retired tactics as live.

**Tasks**:
- [ ] `docs/user-guide/tutorial.md:278`, `docs/user-guide/examples.md:445`: replace the `tm_auto` example with `modal_search`, and check the snippet elaborates
- [ ] `docs/user-guide/tactic-development.md` (~392-420, 663, 737): retarget `tm_auto`/`temporal_search` discussion to `modal_search`, and where the section is about how tm_auto was built, recast it as retired history or drop it
- [ ] `docs/user-guide/troubleshooting.md` section 4.2 (~272-281): rewrite from "tm_auto errors" to "tm_auto was retired; use modal_search"
- [ ] `docs/development/METAPROGRAMMING_GUIDE.md` (~19, ~436-438, ~604): change error-message worked examples to cite `modal_search`
- [ ] Re-grep all five files for the three retired names and the six nonexistent tactic names

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 17 occurrences across these five files (1+1+9+3+3 per report 02). Confirm
with `grep -nE 'tm_auto|temporal_search|propositional_search'` before editing.

**Files to modify**:
- `docs/user-guide/{tutorial,examples,tactic-development,troubleshooting}.md`, `docs/development/METAPROGRAMMING_GUIDE.md`

**Verification**:
- Grep finds only explicit "retired" mentions; changed runnable snippets verified or labelled illustrative; C13 PASS

---

### Phase 6: Reframe leansearch research notes and refresh implementation-status.md [NOT STARTED]

**Goal**: Apply Decision 3 to the four `leansearch-*.md` files, and refresh the stale sections of
`implementation-status.md`.

**Tasks**:
- [ ] Add a short "Historical design research" banner to each of `docs/research/leansearch-{api-specification,best-first-search,priority-queue,proof-caching-memoization}.md`: dated Dec 2025, informed `FormalSystem/Automation/ProofSearch/` and `SuccessPatterns.lean`, not a live API reference, and upstream services may have changed (verify both paths exist first)
- [ ] `docs/research/README.md` (~108-111, ~174-198): add a note giving the reframing and its reason (Decision 3)
- [ ] `docs/project-info/implementation-status.md`: re-run `cloc --include-lang=Lean --exclude-dir=.lake,lake-packages,Boneyard .` and update the statistics table (~150-156) with the date; rewrite the Layer 4 Automation section (~127-141) with the `Automation/Tactics/` directory instead of `Tactics.lean`, add `modal_search` to Working, and re-verify or drop the "Bounded search timeout" issue (grep ProofSearch for timeout/fuel handling; if unverifiable, remove the claim)
- [ ] Spot-check the rest of `implementation-status.md` for module paths that no longer exist (`ls` each named file)
- [ ] Confirm `performance-targets.md` and `test-coverage.md` need no change (no edit; note in summary)

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `docs/research/leansearch-*.md` (4 files, banners only), `docs/research/README.md`, `docs/project-info/implementation-status.md`

**Verification**:
- Every module path in `implementation-status.md` resolves; statistics match a fresh cloc run; C5/C12/C13 PASS

---

### Phase 7: Align naming prose (CLAUDE.md naming key, installation paths) [NOT STARTED]

**Goal**: Apply Decision 4. Fix the `CLAUDE.md` title/body and correct concretely wrong
"ProofChecker" directory usages, without a mass rename.

**Tasks**:
- [ ] Root `CLAUDE.md`: retitle (for example `# BimodalLogic (ProofChecker)`) and add a short "Names" list: repository `BimodalLogic`; ProofChecker = role name in the Logos dual-verification architecture; Lake package `Logos` (package-name decision tracked by the lakefile.toml migration, not by this file; no task number); library `FormalSystem`; test library `BimodalTest`
- [ ] `docs/installation/BASIC_INSTALLATION.md` (~82-123) and `docs/installation/README.md`: fix clone URL, `cd ProofChecker`, and `~/Documents/Projects/ProofChecker` paths to the `BimodalLogic` repository name; keep prose uses of the role name
- [ ] `grep -rn 'cd ProofChecker\|/ProofChecker\b\|ProofChecker.git' --exclude-dir={specs,.claude,.git,.lake} .` for other literal path usages and fix only those in `docs/` or root markdown (leave `typst/`, `latex/`, and `.lean` untouched and list them in the summary)

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Literal path or directory usages of "ProofChecker" are confined to
`docs/installation/`. Confirm with the grep above.

**Files to modify**:
- `CLAUDE.md`, `docs/installation/BASIC_INSTALLATION.md`, `docs/installation/README.md` (plus any literal-path hits found in `docs/` that no other phase owns; if a hit is in a Phase 4/5/6 file, leave it and note it)

**Verification**:
- No task number introduced into `CLAUDE.md` (the C9 hook blocks it anyway); readme-lint PASS; C13 PASS

---

### Phase 8: Flip ENFORCE_C9_DOCS and document the gate [NOT STARTED]

**Goal**: With C9D at 0, make it exit-code-affecting by default (CI inherits this) and update the
docs that describe the flag.

**Tasks**:
- [ ] Fresh `bash scripts/check-module-invariants.sh --no-build`: C9D must read 0 (or only `task-ref-ok`-marked). If new citations appeared from concurrent work, clear them first
- [ ] `scripts/check-module-invariants.sh:525-528`: change the default to `${ENFORCE_C9_DOCS:-1}`, update the trailing comment to "(enforced)", replace the comment block above it (which names `PHASED_IMPLEMENTATION.md`), and update the header list line ~70 ("soft by default" becomes "enforced"); leave the check block's "do not flip back to 0" comment intact
- [ ] `docs/development/MODULE_INVARIANTS.md:185-196`: rewrite the "live example" paragraph. State that `ENFORCE_C9_DOCS` is now enforced; if another soft flag still defaults to 0 (grep the flag block), cite it as the example, otherwise describe the pattern generically. Remove the `PHASED_IMPLEMENTATION.md` mention and the "exits 1, with a count" snippet
- [ ] `docs/development/CI_CD_PROCESS.md`: add a short note that C9D (no task-number citations under `docs/`) became gating via the script default, with no workflow change because the "Check module invariants" step runs the script bare. Date only, no task number
- [ ] Final gate: `ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh --no-build` exits 0 and the default run exits 0; C5, C12, C13 PASS; `bash scripts/readme-lint.sh` PASS; `bash .claude/scripts/check-task-references.sh` (if present) clean for `docs/`
- [ ] Confirm `grep -n ENFORCE .github/workflows/ci.yml` is still empty (no override masks the new default)

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Files to modify**:
- `scripts/check-module-invariants.sh` - default flip and comments
- `docs/development/MODULE_INVARIANTS.md` - rewrite the flag example paragraph
- `docs/development/CI_CD_PROCESS.md` - gating note

**Verification**:
- Both invocations of the invariants script exit 0 with C9D PASS; all listed gates PASS

## Testing & Validation

- [ ] C9D: `PASS C9D zero task-number citations under docs/`
- [ ] `ENFORCE_C9_DOCS=1 bash scripts/check-module-invariants.sh --no-build` exits 0 (and so does the default invocation after the flip)
- [ ] C5, C12, C13 PASS
- [ ] `bash scripts/readme-lint.sh` PASS
- [ ] `grep -rnE 'tm_auto|temporal_search|propositional_search' docs/` returns only explicit retirement mentions
- [ ] `grep -rn PHASED_IMPLEMENTATION --exclude-dir={specs,.git,.claude} .` returns nothing

## Artifacts & Outputs

- Deleted: `docs/development/PHASED_IMPLEMENTATION.md`
- Rewritten: `docs/development/LATEX_STANDARDS.md`, `docs/project-info/tactic-registry.md`, the tactic sections of `docs/reference/API_REFERENCE.md`, the stale sections of `docs/project-info/implementation-status.md`
- Edited: residual-citation docs, user guides, `METAPROGRAMMING_GUIDE.md`, `leansearch-*.md` banners, `docs/research/README.md`, installation docs, `CLAUDE.md`, `MODULE_INVARIANTS.md`, `CI_CD_PROCESS.md`, `scripts/check-module-invariants.sh`
- Summary: `specs/590_retire_stale_development_documentation/summaries/02_docs-staleness-cleanup-summary.md`

## Rollback/Contingency

Each phase commits separately with targeted `git add -- <files>`, so any phase can be reverted with
`git revert <sha>` on its own. If Phase 8's final gate fails because of citations introduced by
concurrent work that cannot be cleared inside this task, leave `ENFORCE_C9_DOCS` at default 0, mark
Phase 8 `[PARTIAL]` naming the offending files, and do not flip. Never flip to 1 with a nonzero
count.
