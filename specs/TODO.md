---
next_project_number: 1001
---

# TODO

## Task Order

*Updated 2026-11-26. Generated from state.json dependency graph.*

**Goal**: Close the residual repository-hygiene backlog

**Dependency Waves**:
| Wave | Tasks | Blocked by | Topics |
|------|-------|------------|--------|
| 1 | 178,257,298,428,481,502,570,604,664,713,734,761,831,890,935,960,962,986,988,994,997,999,1000 | -- | algebraic-representation, completeness, dataset-enhancement, ... |
| 2 | 231,282,296,429,497,763,869,944,954,955,969,995 | 298,428,502,604,761,960,962,986,994 | algebraic-representation, dataset-enhancement, decidability, ... |
| 3 | 410,498,499,500,873,932,945 | 429,497,869,944 | algebraic-representation, decidability, semantics, ... |
| 4 | 125,411,543,874,875,876,946 | 410,498,499,500,873,945,969 | algebraic-representation, decidability, metalogic, ... |
| 5 | 430,501,947 | 125,411,946,955 | algebraic-representation, decidability, proof-mode |
| 6 | 412,949,951,963,965 | 178,430,947,954 | decidability, proof-mode |
| 7 | 482,950,964 | 412,949,963 | decidability, proof-mode |
| 8 | 177,948 | 178,282,296,481,482,543,950 | formula-refactor, proof-mode |
| 9 | 952 | 948,951,964 | proof-mode |
| 10 | 953,956,966,968,974 | 952,962 | proof-mode |
| 11 | 957 | 956 | proof-mode |
| 12 | 967 | 957,966 | proof-mode |

**Grouped by Topic** (indented = depends on parent):

### Algebraic Representation

502 [NOT STARTED] — RESEARCH TASK. Ground the algebraic representation front in...
  └─ 497 [NOT STARTED] — Bring the Shift-closed Tense S5 Algebra class into live code...
    └─ 498 [NOT STARTED] — Phase 1 of the Jonsson-Tarski representation: the complex...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the...
        └─ 501 [NOT STARTED] — Phase 4 of the Jonsson-Tarski representation: extend STSA...
    └─ 499 [NOT STARTED] — HARD. Phase 2 of the Jonsson-Tarski representation: the...
      └─ 125 [NOT STARTED] — CAPSTONE of the algebraic representation front. Prove the... (see above)
    └─ 500 [NOT STARTED] — RESEARCH TASK. Prevent two parallel representation theorems...

### Completeness

935 [NOT STARTED] — ROUTE R3 -- THE DETERMINIZATION-FREE PROGRESS-MEASURE DESIGN....

### Dataset Enhancement

257 [BLOCKED] — Complete the Hugging Face Hub migration for large dataset...
298 [PARTIAL] — Fix c7 labeling bug at formula ~13750 that causes unbounded...
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset...
  └─ 282 [PARTIAL] — Flip complexity-9 dataset generation from stratified to...
  └─ 296 [PARTIAL] — Re-add the 6 derived binary temporal operators (release,...
604 [NOT STARTED] — Add zstd-compressed .jsonl dataset support across the data...
  └─ 231 [NOT STARTED] — Build comprehensive automation so that every dataset... (see above)

### Decidability

428 [PLANNED] — Engine totality at a quantified branch budget. Owns...
  └─ 429 [NOT STARTED] — Repair the truth-lemma side conditions. Owns obstructions O2...
    └─ 410 [PLANNED] — Track B part 1 for the TM tableau decidability program...
      └─ 411 [NOT STARTED] — Track B part 2 for the TM tableau decidability program...
        └─ 430 [NOT STARTED] — The semantic lift and the Track A assembly. Owns obstruction...
          └─ 412 [NOT STARTED] — Track B finish for the TM tableau decidability program...
            └─ 482 [NOT STARTED] — CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT...
481 [BLOCKED] — CLASSIFICATION: genuinely open -- the predicate is refuted as...
713 [NOT STARTED] — SCHEDULABLE AND LOAD-BEARING AS A CHECK. User ruling...
734 [HOLD] — Run experiment E4: decide StabSaturated on the Bool fixture's...
761 [PARTIAL] — AMENDED 2026-11-16 (statement replaced — the READ-OFF /...
  └─ 763 [NOT STARTED] — AMENDED 2026-10-11 (index deletion): the finite cell index...
831 [NOT STARTED] — RESEARCH TASK, verdict-first. State and attempt the...

### Formula Refactor

178 [NOT STARTED] — Expand Examples/ with publication-quality demonstrations of...
  └─ 177 [NOT STARTED] — Update README.md, docs/, and FormalSystem/ module-level...

### Literature

664 [NOT STARTED] — Acquire and ingest the Cmiel-Kuhlmann-Kuhlmann ball-space...

### Metalogic

570 [NOT STARTED] — OPEN RESEARCH QUESTION, not an implementation task. Is the...
890 [RESEARCHED] — Record the GHR94 Lemma 10.2.3 Case 5 erratum in the Typst...
543 [NOT STARTED] — Machine-check the principal new results from the MF...
875 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

### Repo Hygiene

988 [NOT STARTED] — Fix scripts/readme-lint.sh reporting PASS in CI without...
997 [NOT STARTED] — Make check-header-attribution.sh rename-aware and resolve...
999 [NOT STARTED] — Re-pin the stale Challenge.lean Comparator snapshot against...

### Semantics

994 [NOT STARTED] — Build the semantic evaluator: truth at a named point of a...
869 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 932 [NOT STARTED] — Land the four ofStepRel constraint lemmas and an ofStepPlain...

### Paper Alignment

1000 [NOT STARTED] — Reconcile docs/reference/paper-definitions-of-record.md with...

### Syntax

873 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 874 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...
  └─ 876 [NOT STARTED] — PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the...

### Proof Mode

960 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS...
  └─ 944 [NOT STARTED] — FAMILY LAYOUT REVISED (records/proof-mode-architecture.md): ⊡...
    └─ 945 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS...
      └─ 946 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS...
        └─ 947 [NOT STARTED] — REVISED: GATE ONE IS A SWEEP OVER A SELECTION OF LIBRARY...
          └─ 949 [NOT STARTED] — ARCHITECTURE (records/proof-mode-architecture.md): tier...
            └─ 950 [NOT STARTED] — ARCHITECTURE (records/proof-mode-architecture.md): tier...
              └─ 948 [NOT STARTED] — REVISED: GATE TWO IS A SWEEP OVER A SELECTION OF LIBRARY...
                └─ 952 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS...
                  └─ 953 [NOT STARTED] — With the interface as one class per operator family and...
                  └─ 956 [NOT STARTED] — ARCHITECTURE (records/proof-mode-architecture.md): tier...
                    └─ 957 [NOT STARTED] — MILESTONE M11 (records/proof-mode.md), STREAM: research and...
                      └─ 967 [NOT STARTED] — REVISED (records/proof-mode.md, M14b;...
                  └─ 966 [NOT STARTED] — MILESTONE M14a (records/proof-mode.md), STREAM: closure...
                    └─ 967 [NOT STARTED] — REVISED (records/proof-mode.md, M14b;... (see above)
                  └─ 968 [NOT STARTED] — STRUCTURE. Organize the chapter by...
                  └─ 974 [NOT STARTED] — MILESTONE M21 (records/proof-mode.md), LANE: library, then...
          └─ 951 [NOT STARTED] — ARCHITECTURE (records/proof-mode-architecture.md): tier...
            └─ 952 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS... (see above)
          └─ 963 [NOT STARTED] — ARCHITECTURE (records/proof-mode-architecture.md): tier...
            └─ 964 [NOT STARTED] — PATH REVISED: the gate-one scripts this record designs the...
              └─ 952 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS... (see above)
          └─ 965 [NOT STARTED] — REVISED (records/proof-mode.md, M12): where proof-mode proofs...
  └─ 954 [NOT STARTED] — COORDINATION WITH OPEN CONTRIBUTIONS. Three stacked pull...
    └─ 963 [NOT STARTED] — ARCHITECTURE (records/proof-mode-architecture.md): tier... (see above)
  └─ 955 [NOT STARTED] — MILESTONE M2 (records/proof-mode.md), STREAM: closure...
    └─ 947 [NOT STARTED] — REVISED: GATE ONE IS A SWEEP OVER A SELECTION OF LIBRARY... (see above)
  └─ 969 [NOT STARTED] — LOCATION (binding over any module path named below): the view...
    └─ 946 [NOT STARTED] — NO ModalTemporal MODULE OR CLASS... (see above)
962 [NOT STARTED] — MILESTONE M9b (records/proof-mode.md), STREAM: metatheory....
  └─ 953 [NOT STARTED] — With the interface as one class per operator family and... (see above)
986 [NOT STARTED] — Report the real cause when a view fails to apply. applyView...
  └─ 969 [NOT STARTED] — LOCATION (binding over any module path named below): the view... (see above)
995 [NOT STARTED] — State the semantic proof mode and its soundness adapter, and...

## Tasks

### 1000. Reconcile paper definitions of record
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: paper-alignment
- **Dependencies**: None

**Description**: Reconcile docs/reference/paper-definitions-of-record.md with the manuscript's operator-term restatement of lem:uniq and thm:s5. scripts/check-paper-definitions.sh reports both anchors drifting: the manuscript now carries % NEW CHANGE: comments restating each for operator terms T and U rather than the operator variable Q, with the recorded reason that leaving Q free lets the hypothesis generalize by I4 to every operator being objective, which comprehension at bottom refutes, so the variable form held only vacuously. The pinned record still carries the variable form. The gate is not a CI blocker: the manuscript lives in a separate repository that CI cannot see, so an absent paper is a neutral skip and this drift is visible only in a local run with the paper on disk. Decide whether the record is re-pinned to the operator-term statements and whether anything downstream cites the superseded variable form.

---

### 999. Repin challenge lean comparator snapshot
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: repo-hygiene
- **Dependencies**: None

**Description**: Re-pin the stale Challenge.lean Comparator snapshot against the connective signature layer, and decide how a non-elaborating snapshot gets detected. ORGANISATION.md records Challenge.lean as the git-pinned statement set produced by the lean extension's lean-challenge-snapshot.sh, its sorry bodies intentional because the module pins statement signatures rather than proofs. The committed copy predates the connective signature layer and no longer elaborates: lake env lean Challenge.lean reports six-plus errors because the restated theorems name clause-class fields that the signature refactor removed (UntlClause.untl, SnceClause.snce, AllFutureClause.allFuture, AllPastClause.allPast) and omit the new Has* binders, and because lines 40 onward reference Point, IffTransport and StarFormula without opening PointTransport or StarLanguage. All ten of its declarations are already landed and proved in the library (release_iff_forall and trigger_iff_forall in Semantics/TemporalIntervals.lean, the two persistence lemmas in Semantics/TemporalRules.lean, and the rest in Semantics/PointTransport.lean). The file is tracked but sits outside defaultTargets and every lean_lib root, so neither lake build nor any CI step observes it, and the snapshot --check comparison it feeds has no meaning while the whole file fails to elaborate. Decide whether re-pinning is a plain re-run of the snapshot step against the current tree and whether a staleness or elaboration check belongs anywhere; note that changing lean-challenge-snapshot.sh itself edits a source-store path under the nvim agent-system tree, so that half must be filed in the repository holding that source_dir, not here.

---

### 997. Gate coverage rename awareness and c16 roots
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: repo-hygiene
- **Dependencies**: None

**Description**: Make check-header-attribution.sh rename-aware and resolve C16's roots-batch ceiling, and rule on the --no-build blind spot that hides C14 and C16 from CI. The attribution gate's single git log --no-merges --name-only pass over four roots cannot take --follow (git requires exactly one pathspec for it), so commits before a rename report the old path and are dropped by the headed.txt filter; there are 404 rename records under FormalSystem/ alone. Measured today the gap costs nothing (only Automation/Tactics/Search.lean gains an author under --follow, and that author is the excluded Claude identity), but it is an unlisted false-negative channel: decide between a per-file --follow loop and another rename-recovery mechanism, weighed against the current one-pass cost model, and list the outcome among the script's STATED LIMIT holes. Separately, C16's roots batch in scripts/check-module-invariants.sh reports 6 entries above the pinned ceiling in scripts/c16-roots-baseline.txt: four are modules already baselined under other roots but carrying no row for the newer BimodalTools.TheoremLibraryPipelineMain root (CanonicalWire.Json defsWithUnderscore 3, ForwardProofGenerator defsWithUnderscore 1, JsonParse docBlame 8, TableauBridge docBlame 4), and two are new docBlame findings in test modules (BimodalLibTest.DiagnosticsTest, BimodalTest.Automation.ProofModeTemporalTest). Decide per entry whether to add the missing docstring or a justified baseline row; never a wholesale --update. Both halves sit in one blind spot worth ruling on: CI runs check-module-invariants.sh with --no-build, so C14's and C16's full-mode halves are checked by nothing automated, which is how a declaration pin naming a theorem that had been renamed survived unnoticed.

---

### 996. Standardize contributor attribution in headers
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: repo-hygiene
- **Dependencies**: None
- **Research**: [996_standardize_contributor_attribution_in_headers/reports/01_contributor-attribution-headers.md]
- **Plan**: [996_standardize_contributor_attribution_in_headers/plans/01_header-attribution-convention-gate.md]
- **Summary**: [996_standardize_contributor_attribution_in_headers/summaries/01_header-attribution-convention-gate-summary.md]

**Description**: Standardize contributor attribution in Lean copyright headers, and backfill the files already edited without it

=== THE MEASURED GAP ===

This repository uses the Mathlib-style file header: a `/- ... -/` block whose line 2 is `Copyright (c) YEAR HOLDER. All rights reserved.`, line 3 the Apache license line, and line 4 `Authors: NAMES`. Across FormalSystem/ and Tests/, 980 files carry `Authors: Benjamin Brast-McKie` and 54 carry `Authors: Tanner Duve`. ZERO files carry a joint `Authors:` line -- the multi-author form the header grammar supports is entirely unused.

Of the 54 Tanner-headed files, 24 ALREADY carry commits authored by someone else (`git log --format=%an` per file, excluding Tanner), and not one of those 24 had its `Authors:` line updated. Examples: FormalSystem/Semantics/TemporalRules.lean (5 of 6 commits), FormalSystem/Semantics/TemporalIntervals.lean (5 of 6), Tests/BimodalTest/Semantics/TemporalRulesTest.lean (3 of 4), FormalSystem/Automation/ProofMode/TemporalBoolean.lean (2 of 3). The merged temporal-rules and pointed-semantics follow-up work ran straight through those files.

NOTHING IN THE REPOSITORY OR THE AGENT SYSTEM ADDRESSES THIS:
- `scripts/check-copyright-headers.sh` is the CI gate (run as `--strict FormalSystem BimodalTools BimodalLib`). It validates header SHAPE only: the `/-` delimiter, the regex `^Copyright \(c\) 20[0-9]{2} .+\. All rights reserved\.$`, the exact license line, `^Authors: [^ ].*[^.]$` on line 4, comma-terminated continuation lines, and closure by line 12. It is IDENTITY-BLIND -- it never compares the names against anything. Adding a contributor passes; omitting one passes equally.
- `CONTRIBUTING.md` mentions only that every file has a module docstring and a copyright header -- no attribution policy.
- `docs/development/LEAN_STYLE_GUIDE.md` has a Documentation Requirements section covering module and declaration docstrings, with no copyright-header or authorship content.
- The agent system has nothing. A grep for `Authors:` across the whole deployed `.claude/` tree hits only literature-index templates. `rules/lean4.md` says nothing about headers. None of the registered PreToolUse hooks (task-references, record-versioning, destructive-git, bounded-waiter, task-creation-audit, python-state-write, git-push) touches file headers.

CONSEQUENCE, stated plainly: under an autonomous dispatch, header attribution will not happen. Implementation agents receive no instruction to update an `Authors:` line, and the only mechanical check would not notice whether they did.

=== WHAT THIS TASK DELIVERS ===

1. A DECIDED CONVENTION, RECORDED DURABLY. The Mathlib convention is the obvious default and is already accepted by the existing checker: leave the original `Copyright (c) YEAR HOLDER` line untouched and append to `Authors:` -- `Authors: Tanner Duve, Benjamin Brast-McKie` -- including the multi-line continuation form (continuation lines ending in commas) the checker already validates. The convention MUST also state the THRESHOLD: what size or kind of change earns an `Authors:` entry, versus a typo fix or a mechanical lint repair that does not. A threshold-free rule either under-attributes or turns every whitespace fix into a header edit. Record it in CONTRIBUTING.md's "What a Contribution Must Satisfy" section or in docs/development/LEAN_STYLE_GUIDE.md, whichever is judged the right home, with the grounds recorded.

2. A MECHANICAL BACKSTOP. A convention stated in prose is instruction-dependent, and this repository has already demonstrated what that yields: 24 files. Extend `scripts/check-copyright-headers.sh` with an identity check comparing each file's `Authors:` line against its distinct `git log --format=%an` committers, or add a separate lint beside it. Two design constraints: the check needs the same `--strict` / bucket-list / `--exclude` shape as the existing script so it composes with the CI step and `scripts/verify-all.sh`; and it needs a waiver mechanism, because a committer who only ran a mechanical fix must not be forced into an `Authors:` line (see the threshold in item 1). Mathlib's own `nolints.json` pattern and this repository's existing lint-suppression policy are the precedents to weigh.

3. THE BACKFILL. Apply the decided convention to the files that already carry commits from a second author, judged individually against the threshold from item 1 -- NOT a blind sed over all 24. Re-derive the file list at implementation time rather than trusting this description's count; it moves as commits land.

=== THE AGENT-INSTRUCTION HALF IS A ROUTE DECISION, DELIBERATELY NOT PRE-MADE ===

A mechanical check CATCHES a missing attribution; it does not make an agent add one. For agents to do it during a dispatch, the convention has to reach their context through a rule matching `**/*.lean`. There are two routes and they are not equivalent:

ROUTE A, repo-local. A rule at `.claude/rules/authorship-attribution.md`, protected from regeneration by an entry in `.syncprotect` (paths there are relative to the sync base directory, so the entry reads `rules/authorship-attribution.md`). Precedent: `.syncprotect` already protects `context/repo/project-overview.md` on exactly these grounds. Keeps a two-author convention naming specific people out of the shared source store.

ROUTE B, shared source store. A rule under the lean extension's own source directory (resolve `.extensions.lean.source_dir` from `.claude-extensions.json`), stating the generic principle -- append to `Authors:` when you materially edit a file someone else authored -- with no names in it. Reaches every repository deploying the extension. NOTE: a task whose declared edit target is a source-store path must be filed in the repository whose filesystem contains that `source_dir`, so Route B is NOT in this task's edit scope. If research settles on it, spawn that task rather than editing across the boundary from here.

The deliverable includes the route decision with its grounds, and Route A's implementation if that is the choice.

=== REQUIRED: AN IDENTITY MAP, OR DELIVERABLE 2 IS NOT IMPLEMENTABLE ===

Deliverable 2 above specifies the mechanical check as a comparison of each file's `Authors:` line against its `git log --format=%an` committers. That comparison CANNOT work as stated, and this is a material requirement on the check's design, not a caveat. The repository carries SIX distinct author name/email identity rows for THREE parties:

```
benbrastmckie <64314593+benbrastmckie@users.noreply.github.com>
benbrastmckie <benbrastmckie@gmail.com>
benbrastmckie <benjamin@logos-labs.ai>
Benjamin Brast-McKie <64314593+benbrastmckie@users.noreply.github.com>
Claude <noreply@anthropic.com>
Tanner Duve <122851174+tannerduve@users.noreply.github.com>
```

Commit counts by author name: `benbrastmckie` 17766, `Claude` 46, `Tanner Duve` 9, `Benjamin Brast-McKie` 5.

Two consequences follow, and the check must handle both:

(a) AN IDENTITY MAP IS MANDATORY, MAINTAINED AS DATA. The git author string `benbrastmckie` never matches the header display name `Benjamin Brast-McKie`. An unmapped comparison therefore flags essentially every one of the ~1034 headed files, which is indistinguishable from no check at all. The check REQUIRES an explicit mapping from git author identity to header display name. Weigh `.mailmap` FIRST: it is git's own native mechanism for exactly this problem, `git log` honors it automatically with no lookup code on the checker side, and `git shortlog -sne` enumerates the rows that need folding. A checker-side data file is the FALLBACK, to be adopted only if `.mailmap` proves insufficient, with the reason recorded.

(b) THE MAP NEEDS AN EXCLUSION SET, NOT MERELY A RENAME MAP. `Claude <noreply@anthropic.com>` authored 46 commits and is NOT a contributor that earns a header `Authors:` entry. A pure rename map cannot express that; an explicit exclusion set can. Further, agent-authored work also lands under the repository owner's own identity carrying `Co-Authored-By` trailers, which `%an` does not surface at all -- so the exclusion set cannot be derived from `%an` alone and must be stated deliberately.

=== SCOPE ADDITION: THE REVERSE DIRECTION, BENJAMIN-HEADED FILES WITH TANNER COMMITS ===

Deliverable 3's backfill, as scoped above, walks Tanner-headed files only. The reverse direction is also live. Six Benjamin-headed `.lean` files carry Tanner commits:

```
FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean     1 Tanner commit
FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean  1
Tests/BimodalTest.lean                                              4
FormalSystem/Theorems.lean                                          1
FormalSystem/Automation.lean                                        1
FormalSystem/Semantics.lean                                         1
```

THE DISCRIMINATION IS ALREADY MEASURED AND SETTLED -- do NOT re-derive it. The last four are import-only barrel roots: each file's entire body below the header block is an `import` list, so a commit touching one adds or reorders import lines and is not authorship. The two `RaySummary/` files are genuine content edits.

Accordingly: the two `RaySummary/` files are backfill candidates subject to the same per-file threshold as every other candidate, and the barrel-root exclusion is recorded as a REASONED exclusion with its grounds, not left as an oversight. The identity check must also not fire on barrel roots. Prefer achieving that through a rule that an import-only diff never earns attribution -- narrower and more durable than an enumerated exclusion list of filenames.

=== PRECISION LIMIT: THE CHECK REPORTS CANDIDATES, NEVER VERDICTS ===

This is a limit of the mechanism, not a gap in scope, and the check's contract must state it.

Tanner's 54-file header footprint arrived in only 9 commits, several of them PR-shaped (`Add pointed temporal semantics and transport lemmas (#11)`, `Add checked rewriting and bounded simplification (#7)`). Inspected samples support the forward direction: on `FormalSystem/Semantics/TemporalRules.lean` the log is one Tanner commit plus five `benbrastmckie` commits, and those five are substantive task phases -- interval lemmas and the one next/prev encoding; promoting the generic succ/pred pair; primitive-tense persistence reaching L-minus -- not merges. The forward count of 24 is therefore sound in direction.

But `%an` alone cannot distinguish a commit that MERGED someone's pull request from one that materially edited the file. The check therefore reports CANDIDATES, and the per-file threshold judgment from deliverable 1 settles each one. Design consequence: the check's exit status gates on UNREVIEWED CANDIDATES, not on a raw name mismatch -- a reviewed-and-waived candidate must not keep the gate red.

=== SCOPE ADDITION: SURFACES CARRYING NO HEADER AT ALL ===

Tanner has commits on roughly 30 non-`.lean` files, none of which carry a copyright header, so there is no `Authors:` line to repair: ten `docs/user-guide/proof-mode-*.md` guides, `docs/reference/tactic-reference.md`, ten `README.md` files including the repository root `README.md`, five `records/*.md` (`milestones.md`, `proof-mode.md`, `proof-mode-architecture.md`, `semantic-proof-mode.md`, `theorem-library.md`), and `scripts/measure-refactor-partitions.py`.

Two positions must be STATED rather than left unaddressed:

(a) WHETHER WRITTEN-RECORD AUTHORSHIP IS AN ATTRIBUTION SURFACE THIS REPOSITORY TRACKS AT ALL, covering `docs/`, `records/`, and `README` files. A defensible answer is no -- those files carry no header by convention and git history is their record -- but it must be stated, because the claim that attribution is fully repaired is otherwise false by omission.

(b) `CITATION.cff` CARRIES A RECORDED DECISION. It names only `Brast-McKie, Benjamin` in its `authors:` list. It is the repository's most externally-visible attribution surface, it is consumed by citation tooling, and nothing else in this task touches it. Decide and record whether a substantial contributor to the published library belongs in that list. This is the one item here with consequences outside the repository.

=== ALREADY CHECKED AND CLEARED, NOT TO BE RE-LITIGATED ===

Rename history is not a source of undercount. `git log --follow` and plain `git log` return identical commit counts on the sampled backfill files, so no pre-rename history is missed by the per-file committer derivation. The derivation needs no `--follow` handling on this evidence.

=== EDIT SCOPE ===

scripts/check-copyright-headers.sh (or a new sibling lint script under scripts/)
CONTRIBUTING.md and/or docs/development/LEAN_STYLE_GUIDE.md
.github/workflows/ci.yml and scripts/verify-all.sh (wiring the new check, if it gates)
.syncprotect and .claude/rules/authorship-attribution.md (Route A only)
The Tanner-headed .lean files under FormalSystem/ and Tests/ that the threshold selects (re-derived at implementation time; 24 candidates as measured)
.mailmap (the identity map, if `.mailmap` is the chosen mechanism)
CITATION.cff (if the recorded decision is to add a contributor)
FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean (reverse-direction candidate, judged against the threshold)
FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean (reverse-direction candidate, judged against the threshold)

NOT IN SCOPE: any path under the agent-system source store (see Route B above); the 980 Benjamin-headed files, except the two `RaySummary/` candidates named above; the four import-only barrel roots (`Tests/BimodalTest.lean`, `FormalSystem/Theorems.lean`, `FormalSystem/Automation.lean`, `FormalSystem/Semantics.lean`), excluded on the reasoned grounds recorded above; anything under Boneyard/, which is intentionally unheadered and already excluded by the checker's `*/Boneyard/*` glob.

=== DONE WHEN ===

The convention is recorded durably with its attribution threshold stated; a mechanical check enforces it with a waiver path and composes with the existing CI step; the selected backfill files carry correct joint `Authors:` lines and still pass `check-copyright-headers.sh --strict`; the agent-instruction route is decided with grounds, and implemented if Route A; and `lake build` plus the header checker are green.

AND, equally gating:

- An identity map exists -- `.mailmap` or the recorded fallback -- carrying its exclusion set, and the check runs CLEAN against the current tree: zero false positives across the ~1034 headed files.
- The check's exit status gates on unreviewed candidates rather than raw name mismatches, and its output is worded as candidates, not verdicts.
- The two `RaySummary/` files are each judged against the threshold with the judgment recorded, and the import-only barrel-root exclusion is recorded with its reason.
- The written-record question (`docs/`, `records/`, `README`) and the `CITATION.cff` question each carry a recorded decision, whichever way each goes.
- The claim "attribution is correct across this repository" is either TRUE, or accompanied by a stated, reasoned list of exactly what it excludes.

=== RELEVANT CONTEXT ===

`scripts/check-copyright-headers.sh`'s own header comment is unusually complete -- it explains why the script exists beside Mathlib's `linter.style.header` and exactly which trees that linter structurally cannot reach (the BimodalTools executable roots, each declaring a root-namespace `main`, and everything under Tests/, whose libraries declare `srcDir = "Tests"`). Read it before changing the predicate.

The repository runs the Mathlib standard syntax-linter set (`weak.linter.mathlibStandardSet = true`), `lake lint` via `lintDriver = "batteries/runLinter"` against scripts/nolints.json, `lake exe lint-style`, and `lake exe mk_all --lib FormalSystem --check`. The lint-suppression policy, including every permanent opt-out, lives in docs/development/LEAN_STYLE_GUIDE.md.

`git shortlog -sne` enumerates the six identity rows named above and is the command that regenerates them; `.mailmap`, if adopted, is read automatically by every later `git log` and `git shortlog` invocation, including the checker's own.

CONTEXT ON THE TWO BACKLOG NEAR-MISSES, checked and ruled non-covering at creation time: the closed record `add_apache_headers_to_test_files` added MISSING headers to test files (presence, not attribution), and the closed record `line_limit_compliance_and_publication_residue` reported a copyright-header COUNT as verified (331/331). Neither checks or records which contributors a file's `Authors:` line should name.

---

### 995. Semantic mode and soundness adapter
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 994

**Description**: State the semantic proof mode and its soundness adapter, and say which half of it this repository builds. Milestone M12's gate (records/milestones.md Goal C) requires a record for the mode WITH its adapter that names the division explicitly, and this is that record. THE DIVISION, which is the first thing to fix and the reason this record is separate from the evaluator record: the tactic language for the mode arrives as an OUTSIDE CONTRIBUTION, not as work this repository schedules. The contribution that first carried it was declined as sited -- it overloaded the derivation tactics onto truth goals -- and the posted closing decision re-sited rather than discarded it: its congruence kit and generic composition, its position and polarity planner, its view rows and its transport structures all survive the move and return as a fresh pull request against main. What this repository owes is therefore NOT the tactic implementation but (a) the adapter's statement and the acceptance criteria that contribution will be measured against, and (b) the thin-layer boundary the mode must respect. THE ADAPTER: native TM and TM-plus derivations enter the semantic side through a ONE-WAY soundness adapter requiring frame satisfaction (fc.Sat F) and truth of the full context. One-way is the design, not a limitation to fix: a semantic proof does not become a derivation. State it once, over TruthEnv, in the shape the already-merged pointed soundness statement uses, so it is proved once for every language rather than per language. THE THIN-LAYER BOUNDARY, from records/semantic-proof-mode.md's open decision 1: the mode is a thin layer over the evaluator, which sits under FormalSystem/Semantics/. The mode may therefore depend on the evaluator and must not invert that dependency, and the evaluator must stay usable by its library clients without the tactic layer. The views tier is relevant and is NOT this record's to build: it sits BELOW the derivation tactics and imports none of them, which is exactly what lets a semantic mode reuse it; proof_mode_views_tier owns it. WHAT THE GATE ALSO REQUIRES, and what makes this record more than a statement of division: the goal shape and the witness interface that records/semantic-proof-mode.md leaves OPEN must be settled. The witness interface's current answer is the clause-ordered pattern, reopened only by a client that repeats an operator on a branch or an error report showing the exchanged-binder fault is common. The goal shape is genuinely unsettled and is this record's to settle, against the evaluator's actual clients rather than in the abstract. DEPENDENCY ON THE EVALUATOR RECORD: the evaluator is the thing this mode is a layer over, so that record runs first; an edge is filed to that effect. Do not restate the evaluator's own deliverables here. OUT OF SCOPE, explicitly: implementing the tactic language, which the contribution brings; and re-deciding the adoption threshold, which stays provisional until the measurement's step 3 reports. DONE WHEN: the adapter is stated once over TruthEnv with frame satisfaction and full-context truth as explicit hypotheses and is proved; the division between repository-built and contributed halves is written where a reviewer of the incoming pull request will read it, not only in this record; the goal shape is settled with the evidence that settled it; and the acceptance criteria the incoming contribution is measured against are stated before it arrives rather than after.

---

### 994. Semantic evaluator for pointed truth
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: None

**Description**: Build the semantic evaluator: truth at a named point of a named model, checked rather than searched for. This is the half of Goal C (records/milestones.md, milestone M12) that THIS REPOSITORY BUILDS; the semantic proof mode and its soundness adapter are a separate record and arrive partly as an outside contribution. records/semantic-proof-mode.md is on main and is the design; it is the specification for this record, not background reading. SITING AND LAYERING, settled by that record's open decision 1: the evaluator sits beside the lemmas under FormalSystem/Semantics/ and the mode is a thin layer over it, NOT one module holding both. The alternative was considered and rejected there: a single module would buy one registry and one syntax at the cost of tying the evaluator's library clients to the tactic layer. OPERATOR RECOGNITION, settled by open decision 3: the evaluator imports NOTHING from FormalSystem/Automation/ProofMode/ and recognizes operators through its OWN rule registry, never FormalSystem/Tactic/FormulaSyntax.lean, which stops at TM-plus. CONSEQUENCE WORTH STATING because it is easy to get wrong: this record does NOT wait on the connective signature layer. The generic clause lemmas already apply at StarFormula, so the two L-star clients below are reachable today; the signature layer later merges the per-language keys, which is an improvement to this evaluator and not a precondition for it. THE FOUR INITIAL CLIENTS, from that record's own table, each an existing refutation whose model, witness data and statement stay FIXED -- measure the proofs of truth or falsity INSIDE the refutations first, then the complete declarations: FormalSystem/PlusLanguage/PlusNonValidities.lean refute_allFuture_stab (prove the universal premise, then refute stability at the supplied history and future time) and refute_stab_allFuture_past (compose stability, future and past clauses keeping the witness times explicit); FormalSystem/StarLanguage/StarNonValidities.lean refute_modal_future (evaluate the recall implication at the named history, future time and register environment) and refute_sentDet (use the existing witness theorem as a short control, measure the two atom obligations). Add an example exercising a clause only when an existing proof needs it. WHAT THE CLIENTS DO NOT EXERCISE, so do not build first: none of the four touches Until, Since or store. Their first rules wait for a client that does. Store and recall have NO clause class, so their rules are per-language registry entries rather than clause-generic ones, and refute_modal_future needs the recall entries. WITNESS INTERFACE: the clause-ordered pattern of records/semantic-proof-mode.md's own measurement, which that record's open decision 2 reopens only on a client that repeats an operator on a branch, or on an error report showing the exchanged-binder fault is common. Do not re-litigate it without one of those two triggers. ALREADY DECIDED ELSEWHERE, do not reopen: the grade of an evaluator-checked refutation (open decision 4) is decided by theorem_library_countermodels, which is COMPLETE -- read the grade off that record rather than deciding it here. The adoption threshold (open decision 5) is provisional until the measurement's step 3 reports and is not this record's to set. PIPELINE RELATION: the tableau finds a countermodel, the evaluator checks one it is given; the two form a pipeline where the tableau proposes and the evaluator certifies. The evaluator therefore has clients wherever the tableau has no verified verdict, today the stability operator and L-star. DONE WHEN: the evaluator is live under FormalSystem/Semantics/ with its own operator registry, it certifies the truth-or-falsity proofs inside all four named refutations, each client keeps its model and statement unchanged, lake build and lake test are green, and a #print axioms check on an evaluator-certified refutation shows no object-language axiom was involved.

---

### 993. Declare integration branch admission gate
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Topic**: agent-system
- **Dependencies**: None
- **Research**: [993_declare_integration_branch_admission_gate/reports/01_declare-integration-branch-admission-gate.md]
- **Plan**: [993_declare_integration_branch_admission_gate/plans/01_declare-integration-branch-admission-gate.md]
- **Summary**: [993_declare_integration_branch_admission_gate/summaries/01_declare-integration-branch-admission-gate-summary.md]

**Description**: Declare integration_branch in .claude-extensions.json so that orchestration admission arms instead of falling back. Every /orchestrate invocation in this repository currently prints "ADVISORY: integration_branch is not declared in .claude-extensions.json; admission falls back to the checked-out branch and tests neither the branch nor the tree", so the branch-and-tree admission gate is disarmed on every run -- including a run dispatched from a feature branch while main has moved ahead, which is the observed working pattern here. The file today carries exactly two keys, extensions and version. context/standards/repo-level-declarations.md documents integration_branch as the name of the branch the orchestrator's admission check verifies, and its "Why .claude-extensions.json Survives a Hand-Authored Sibling Key" section establishes that a hand-authored sibling key beside the deploy-managed extensions key is the sanctioned way to add one: this is an edit to the project-root manifest, NOT a write under .claude/**, so .claude/rules/source-store-deploy-boundary.md does not apply and the task is correctly sited in this repository. DELIVERABLES. (1) The key declared with the branch this repository actually integrates on, read from practice rather than assumed -- recent work dispatches from dev/* feature branches and merges to main, so a declaration naming main would refuse every ordinary run and a declaration naming the current feature branch would go stale at the next branch. State which semantics the consumer actually implements before choosing: whether the declared value is the integration target or the branch work is required to sit on. (2) A falsification check that admission now arms: dispatch from a branch the declaration excludes and confirm the refusal fires, rather than only confirming the advisory stopped printing. An advisory that disappears because the key parsed is not evidence that the gate works. (3) worktree_isolation assessed in the same pass, since repo-level-declarations.md names it as the sibling key read by the same two consumers; declare it or record why not. (4) A recorded decision on whether admission should refuse or merely warn when the checked-out branch is not the declared one, given that orchestrating from a feature branch is the normal practice here and a refusing gate would block it. DO NOT silence the advisory by any route other than a real declaration -- suppressing the message while the gate stays disarmed is strictly worse than the present state, which at least announces itself every run.

---

### 991. Depth zero gate verdict
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**: [991_depth_zero_gate_verdict/reports/01_depth-zero-gate-verdict.md]
- **Plan**: [991_depth_zero_gate_verdict/plans/01_depth-zero-gate-step-fragment-bridge.md]
- **Summary**: [991_depth_zero_gate_verdict/summaries/01_depth-zero-gate-step-fragment-bridge-summary.md]

**Description**: RESEARCH TASK, verdict-first; the deliverable is a verdict plus grounds, not a construction. specs/ROADMAP.md Stage 0 carries "Decide who owns the depth-0 gate" as its one unchecked blocking item, and no open task owns lifting it: the ladder realization theorem records that no dispatch can advance it. THE GATE LIFTS ON EXACTLY ONE OF TWO EVENTS, and this task must deliver one of them: cellLE_zero_const_of_kappa_eq lands as a sorryAx-free theorem, or CellLEZeroConstOfKappaEq is refuted under ParamsOk. THE CRUX, already narrowed: whether a ForwardSlackWitnessed hypothesis at a POSITIVE amount is satisfiable at any state the depth-0 induction reaches, in its EXISTENTIAL-over-paths form only. DO NOT RE-ATTEMPT the per-path form: it is already refuted by ClimbWitness.hasForwardSlack_refuted_unconditional. WHAT PRIOR WORK ESTABLISHED, read before any derivation and do not re-derive: the consumer-shape reachability probe (specs/evidence/forward-slack-pin-cascade/consumer-shape-witness.lean, with specs/archive/934_depth_zero_reachability_probe/summaries/01_consumer-shape-reachability-probe-summary.md) shows the existential over paths is doing real work -- climbC_isLadderPath and climbC_not_hasForwardSlack give a second ladder path through the same state with no forward slack at any positive amount, so the per-path form fails where the cell-level form holds -- and that probe explicitly disclaims deciding the gate or claiming a discharge. Also read the depth-0 gate rest-state plan and the "What would lift the depth-0 gate" section of the idle-insertion-cascade restatement plan under the ladder realization task directory. WHY THIS EXISTS: ten phases of the ladder realization theorem are NOT STARTED and three are BLOCKED behind this gate, and milestone M7 (L-plus at integer time) is active and parked on it. On a verdict either way, the ladder realization theorem is restated against it.

---

### 989. Pointed semantic lemmas after merge followups
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: None
- **Research**: [989_pointed_semantic_lemmas_after_merge_followups/reports/01_pointed-semantic-lemmas-followups.md]
- **Plan**: [989_pointed_semantic_lemmas_after_merge_followups/plans/01_pointed-semantic-lemmas-followups.md]
- **Summary**: [989_pointed_semantic_lemmas_after_merge_followups/summaries/01_pointed-semantic-lemmas-followups-summary.md]

**Description**: Three follow-ups named in the posted review of the pointed semantic lemmas contribution (branch feat/pointed-semantic-lemmas, milestone C1 of records/milestones.md) that no other record owns. None was a condition of merging. That contribution has merged, and FormalSystem/Semantics/TemporalRules.lean, FormalSystem/Semantics/PointTransport.lean and both of their test modules are on main, so this record is dispatchable. Re-read the merged tree first and drop whatever the contributor already did. (1) A POSITIVE READING for `release_iff` and `trigger_iff`: each is stated as the negation of an Until or Since clause; add the direct universal-existential form a refutation script uses, proved from the existing one. (2) DOCSTRINGS: module docstring titles for the three generic modules, and one spelling of the `assert_not_exists` lock (the directory uses `Axiom DerivationTree`). (3) LEMMAS: `allFuture_persist` and `allPast_persist` for L-minus, which has no `untl`; and star-language versions of the time-shift and state-local transport factories. Each new lemma is stated over the clause classes so it is proved once for every language, with a test, including one at the star language. Related and separate: `connective_signature_layer_shared_primitives` owns the named interval operators and the `next` and `prev` encoding; `promote_next_prev_covby_to_generic_lemmas` owns the `next_iff_covBy` promotion.

---

### 988. Readme lint stale date check on shallow clones
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: repo-hygiene
- **Dependencies**: None

**Description**: Fix scripts/readme-lint.sh reporting PASS in CI without checking stale dates. The stale-date arm of scripts/readme-lint.sh is skipped whenever `SHALLOW_CLONE=1` (lines 66-68, 250, 331), since a shallow clone has no history to date a directory against, and `actions/checkout` is shallow by default, so the step in .github/workflows/ci.yml reports `RESULT: PASS` regardless. Measured on one commit: CI passed while the same script with full history reported `FAIL (3 new stale dates)`. The three rows not in scripts/readme-date-baseline.txt are FormalSystem/Automation/ProofMode/README.md, FormalSystem/Tactic/README.md and FormalSystem/Theorems/ProofMode/README.md, stale on main today. DELIVERABLE: (1) the CI step either checks out enough history for the stale-date arm to run (`fetch-depth: 0` on that job) or the script fails loudly, not silently, when it cannot run the arm; state which and why; (2) the three stale rows on main are fixed by updating the README dates, not by widening the baseline; (3) the script prints a line naming any arm it skipped, so a pass that checked less is distinguishable from a full pass.

---

### 987. Temporal rules followups fold names and progress tests
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: None
- **Research**: [987_temporal_rules_followups_fold_names_and_progress_tests/reports/01_temporal-rules-followups.md]
- **Plan**: [987_temporal_rules_followups_fold_names_and_progress_tests/plans/01_temporal-rules-followups.md]
- **Summary**: [987_temporal_rules_followups_fold_names_and_progress_tests/summaries/01_temporal-rules-followups-summary.md]

**Description**: Follow-ups owed after the temporal rules contribution (the pull request adding compositional temporal rules and persistent scope capture) merges; none is a condition of merging it, and all are stated to the contributor as follow-ups. Every path below arrives with that contribution and is absent from main until it merges; re-read the merged tree first and drop whatever the contributor already did -- the status stamp of item (7) in particular may already be regenerated on the branch. OWNERSHIP CARVE-OUT: connective_signature_layer_shared_primitives owns the siting of the TM syntax that PlusLanguage/TemporalViews.lean declares under the TM-plus directory, and this record does not touch it. (1) FOLD AND UNFOLD NAMES. The user-facing keywords were renamed so that `lfold` and `lunfold` name views only, but one layer down FormalSystem/Automation/ProofMode/TemporalZTime.lean still carries `luntilFold`, `luntilUnfold` and `binaryFold`, and the pure rules are still `untilFoldRule`, `untilUnfoldRule`, `untilFold`, `untilUnfoldCases` and their Since and TM+ mirrors: the same collision the keywords had, now in the identifiers. Rename them to the expand and contract vocabulary settled in records/proof-mode-architecture.md, repointing every use. (2) TESTS. `lprogress` has exactly one example, exercising its `cases` form only; add tests for its other forms, for the past direction and for TM+, and a negative test with `#guard_msgs` for each `throwError` path the contribution added that has none. (3) INSTANCE-SYNTHESIS ORDERING IN applyDerivationProof, the one item with a behavioural consequence. In FormalSystem/Automation/ProofMode/Basic.lean the instance-synthesis loop runs BEFORE adaptProof and before the final isDefEq against the goal type, so at that point the rule's frame-class, context and formula metavariables are still unassigned except where the implication-chain match happened to assign them. An instance argument whose type mentions any of them therefore cannot be synthesized, and lapply hard-fails with "could not synthesize the required instance" where the previous code left an ordinary parameter goal the user could discharge. Move the loop after the conclusion unification, keeping the new diagnostic. THIS IS LATENT, NOT LIVE: a grep of FormalSystem/Theorems/ProofMode/ found no rule carrying an instance-implicit binder, so nothing in the tree triggers it today -- fix it as a regression guard, and add a test whose class type mentions a rule parameter, since the contribution's own ReviewInstance test uses a parameterless class and does not cover the path. (4) THE ORDERING CONTRACT IN THE DOCSTRING. applyDerivationProof is now public and its correctness depends on firstNewIndex being snapshotted BEFORE the proof term is elaborated; the docstring says only that holes created since firstNewIndex become new goals. A sibling caller reading the metavariable counter after elaborateProof -- the natural reading -- filters out every one of the rule's own parameter metavariables, so they never become goals and the surrounding by-block fails later with an opaque placeholder-synthesis error. State the ordering requirement in the doc comment. (5) THE BARE CATCH IN integerTimeGate. FormalSystem/Automation/ProofMode/Temporal.lean wraps resolveRuleParameters in a bare catch that rethrows a frame-class message, which swallows every exception rather than the frame-class ones: a maxRecDepth, an interrupt, or a Decidable-synthesis failure arising for some other reason is reported to the user as a frame-class problem, and resolveRuleParameters' own "incompatible concrete frame classes" diagnosis is discarded. Catch only the frame-class failure, or append the original message, so the pinned test text survives while the real cause reaches the user. THIS GATE IS ONE OF THE throwError PATHS ITEM (2) OWES A NEGATIVE TEST FOR: narrow the catch and write its `#guard_msgs` test together, as one piece of work in one module, rather than as two. (6) THREE WRONG MODULE DESCRIPTIONS. In FormalSystem/Automation/ProofMode/README.md the Carrying.lean row still holds a TODO-add-description placeholder; the Temporal.lean row still claims progress, which the contribution moved to TemporalBoolean.lean; and the Discrete.lean row still says Next/Previous scopes with explicit ZTime certificates, after that module gained linduction and after certificates became reused-or-decided rather than always explicit. The description column is hand-written and SURVIVES regeneration per scripts/check-module-invariants.sh, so --emit-inventory --check will not flag any of the three and they stay wrong until edited by hand. The sibling Theorems/ProofMode/README.md placeholder was filled in the same contribution, so the Carrying.lean row looks simply forgotten. (7) THE STATUS STAMP THAT CANNOT REPRODUCE ITS OWN COUNTS. typst/generated/status.typ records a stamp commit whose tree does not contain the nine new library files and four new test files its own counts include: it was regenerated while HEAD sat on another branch with the contribution's files in the working tree. Since scripts/typst-status-counts.sh sets the stamp from git rev-parse --short HEAD, regenerating it on the merged tree fixes both the stamp and the counts in one run. Verify the stamp commit's tree actually yields the recorded figures rather than only that the file changed. PROVENANCE: items (1) and (2) are the two follow-ups named in the posted review of the contribution; items (3) through (7) are the findings of the code review run against head af0cde818, none of which blocked the merge and none of which any other record owns. ORDER: proof_mode_until_since_intro_unfold_induction builds on the same modules and runs after this record. DONE WHEN: lake build and lake test are green; no identifier carries the old fold/unfold vocabulary; lprogress has coverage for its other forms, the past direction and TM+; every throwError path the contribution added has a #guard_msgs test; the instance-ordering test fails against the pre-fix ordering; each README description names what its module now contains; and the status stamp's commit reproduces the status counts.

---

### 986. Proof mode views report swallowed view error
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: None

**Description**: Report the real cause when a view fails to apply. `applyView` in FormalSystem/Tactic/FormulaViews.lean tries each registered row and on ANY error restores the saved state and moves on (`catch _ => saved.restore`, lines 106-107), then throws "view <name> does not match a formula in this location". So `lunfold` and `lfold` report a wrong-shape message whatever actually failed. No other open record reaches this: `proof_mode_error_message_coverage` is scoped by path to FormalSystem/Automation/ProofMode/, and `proof_mode_views_tier` obliges only a test of the message as it stands, which would freeze the wrong message in place. DELIVERABLE: the handler distinguishes a formula of the wrong shape from every other failure and reports the latter with its cause; one negative test per case asserts the message with `#guard_msgs`. ORDER: lands before `proof_mode_views_tier`, which edits the same file and then tests the corrected message. No statement or tactic syntax changes.

---

### 984. Promote next prev covby to generic lemmas
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: Task 989
- **Research**: [984_promote_next_prev_covby_to_generic_lemmas/reports/01_promote-next-prev-covby-generic.md]
- **Plan**: [984_promote_next_prev_covby_to_generic_lemmas/plans/01_promote-next-prev-covby-generic.md]
- **Summary**: [984_promote_next_prev_covby_to_generic_lemmas/summaries/01_promote-next-prev-covby-generic-summary.md]

**Description**: Promote next_iff_covBy and prev_iff_covBy of FormalSystem/SourceLanguage/SentenceTruth.lean onto the generic next_iff and prev_iff of FormalSystem/Semantics/TemporalRules.lean, now that that module is on main (it arrived with the pointed semantic lemmas contribution, milestone C1 of records/milestones.md, since merged). SentenceTruth.lean docstring calls the duplication deliberate and unresolved and names promotion of one shared lemma as the eventual fix, blocked because the other copy of the succ-form fact sits in FormalSystem/Metalogic/DiscreteNonCompactness.lean and the import would be upward. TemporalRules.lean is at layer 1, as is SentenceTruth.lean, so the promotion has no layering cost; next_iff (L := Formula) M τ t PUnit.unit φ was checked to inhabit the statement of next_iff_covBy. Deliverable: the base-language lemmas become instances or one-line corollaries of the generic ones (or are removed with their uses repointed), the copy in Metalogic/DiscreteNonCompactness.lean is repointed likewise, and the deliberate-and-unresolved note in the SentenceTruth.lean docstring is replaced by the current state. No statement changes for downstream users.

---

### 977. Connective signature layer shared primitives
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: Task 984, Task 987, Task 989
- **Research**: [977_connective_signature_layer_shared_primitives/reports/01_connective-signature-layer.md]
- **Plan**: [977_connective_signature_layer_shared_primitives/plans/01_connective-signature-layer.md]
- **Summary**: [977_connective_signature_layer_shared_primitives/summaries/02_connective-signature-layer-summary.md]

**Description**: Introduce a connective signature layer under FormalSystem so that TM and TM+ share one primitive signature and one set of derived operators instead of PlusFormula being a verbatim copy of Formula. PRIMITIVES STAY MINIMAL. Formula (FormalSystem/Syntax/Formula.lean) has six constructors (atom, bot, imp, box, untl, snce) and PlusFormula (FormalSystem/PlusLanguage/Formula.lean) restates all six and adds stab for the stability operator; that minimality is correct for TM and TM+ and is to be preserved. Do NOT adopt cslib's non-minimal expansion to primitive diamond, allFuture and allPast (cslib Cslib/Logics/Modal/Basic.lean has primitive and, or, box, diamond; Cslib/Logics/Temporal/Syntax/Formula.lean has primitive allFuture and allPast; the rationale and the 11-primitive target for the Bimodal layer are in cslib specs/181_bimodal_primitive_dia_always_historically/reports/01_bimodal-primitive-expansion-research.md, and cslib task 181 is still NOT STARTED so its own tree is inconsistent with that target). Non-minimality exists there to let one syntax serve minimal and intuitionistic propositional bases, since each classical interdefinability fails in a weaker logic; TM and TM+ are classical, so adopting it here would buy nothing and would move most of the views tier out of views and into the derivation tier as theorems. THE DEFECT IS DUPLICATION, NOT THE PRIMITIVE CHOICE. Eighteen derived operators are defined verbatim in both syntax files: after, allFuture, allPast, always, and, diamond, kMinus, kPlus, neg, next, or, prev, reflectTime, someFuture, somePast, sometimes and top. This is the syntax-layer root of the tmX / plusX name-pair duplication, and it violates principle 5 of records/proof-mode-architecture.md (languages are instances of an interface, not copies of a file). MODEL TO FOLLOW. cslib Cslib/Foundations/Logic/Connectives.lean (224 lines) is a working instance of the wanted shape and is directly portable: one class per primitive operator (HasBot, HasImp, HasBox, HasUntil, HasSince, HasNext), then PropositionalConnectives extending HasBot and HasImp and supplying neg := phi -> bot and top := bot -> bot as DEFAULT FIELD VALUES so the derived Boolean operators are written once, then a hierarchy of ModalConnectives, FutureTemporalConnectives, TemporalConnectives, LTLConnectives and BimodalConnectives with a bridge instance from BimodalConnectives to ModalConnectives. Four cslib languages share that one definition of neg and top. Note one tension to resolve rather than copy: cslib's ModalConnectives is box-only and minimal while its concrete Modal.Proposition carries a primitive diamond, so interface and inductive disagree there. DELIVERABLE. A signature layer under FormalSystem carrying one class per primitive operator including a stability class for the TM+ operator, a propositional class supplying the derived Boolean operators once, and a bimodal class, with Formula and PlusFormula as instances and the eighteen doubled definitions written once. ALSO ASSESS reducibility: all 35 definitions in FormalSystem/Syntax/Formula.lean are opaque defs and cslib uses abbrev for its Boolean and dual definitions, which unfold definitionally; making the pure Boolean and dual definitions here reducible would let part of the views tier be definitional rather than a table of view rows with unfolding lemmas, which bears directly on the views tier design in records/proof-mode-architecture.md. SEQUENCING. This sits BELOW the proof mode and is a prerequisite for proof_mode_abstract_frontend_interface, whose object-level class is to package the connectives among its members and which should require this signature rather than re-package it; a dependency edge is filed to that effect. Keep the Atom type fixed as it is; cslib parameterizes Formula over the atom type but that is a separate and larger change and is out of scope here. The stability operator shares the Modal class: the family layout is fixed with it in Modal, the shared statement is a K core with T, 4 and 5 as further members, and docs/development/stability-operator-family.md gives the grounds. LANDING WINDOW. ORDER: SPLIT, not whole-task deferral. The signature layer, the instances, the generated bodies for the four formula types and the clause-class restatement (plan phases 1-6) land BEFORE the temporal contribution merges: that branch, checked at head 5ecc91d63, names no clause class, no TruthClauses operator and neither FormalSystem/Syntax/Formula.lean nor FormalSystem/PlusLanguage/Formula.lean, so there is no overlap to serialize. What waits on the merge is the part that absorbs that branch's own work: the interval operators and the one next/prev encoding (deliverable (b), plan phase 7), operator recognition through the signature (deliverable (d), plan phase 8), the closing gates (plan phase 9), and the two TemporalViews tasks of plan phase 5. Those are deferred because they would otherwise repoint twenty view rows onto a signature the contribution's author has not seen -- design work landing on the wrong desk, not a conflict to resolve. On merging, that contribution adds FormalSystem/PlusLanguage/TemporalViews.lean, which declares `Formula.inclusiveUntil`, `Formula.inclusiveSince` and the TM expansions under the TM+ directory, and FormalSystem/Tactic/TemporalFormulaViews.lean, which registers twenty view rows about them. Deliverable (b) absorbs those definitions onto the signature, keeps the per-language names as instances, and repoints the view rows; it does not define the interval operators a second time. Research and planning are done; implementation of plan phases 1-6 may proceed now, and only the deferred parts named under LANDING WINDOW wait. ADDITIONAL DELIVERABLES (done-when of milestone D1 in records/milestones.md). (a) StarFormula (FormalSystem/StarLanguage) is an instance beside Formula and PlusFormula; it carries its own copy of next among others. (b) The interval operators are defined once on the signature: inclusiveUntil, inclusiveSince, release, trigger, weakUntil and weakSince, agreeing in argument order with Formula.release, Formula.trigger, Formula.weakUntil and Formula.weakSince (see the Argument-order trap note on Formula.release), and the clause lemmas of FormalSystem/Semantics/TemporalIntervals.lean (inclusiveUntil_iff, release_iff, weakUntil_iff and their past duals; that module arrives with branch feat/pointed-semantic-lemmas) are restated about them instead of about inline derived formulas. (c) One next and prev encoding: TemporalRules.next and prev of FormalSystem/Semantics/TemporalRules.lean, Formula.next, PlusFormula.next, StarFormula.next and the copy in FormalSystem/Metalogic/Expressiveness/SeparationZ/Syntax.lean are one definition or are tied by rfl rows in Tests/BimodalTest/Semantics/ValidityLayerTest.lean. (d) FormalSystem/Tactic/FormulaSyntax.lean, which matches TM and TM+ operator names only, reads the signature so that operator recognition reaches L⋆; the semantic evaluator of records/semantic-proof-mode.md has L⋆ clients. FIRST QUESTION FOR RESEARCH, to settle before any design: ONE HOME FOR THE DERIVED OPERATORS. FormalSystem/Semantics/TruthClauses.lean already defines the derived operators once, generically over the clause classes (TruthEnv, BotClause, ImpClause, BoxClause, UntlClause, SnceClause, StabClause and their bundles): neg, top, and, or, diamond, someFuture, allFuture, kPlus, after, somePast, allPast, kMinus, always, among others, as abbrevs, and every language (L, L-plus, L-star, L-minus, Open, Hybrid, Quant) instantiates those classes. A syntactic signature layer that defines the same operators again would be a second generic copy beside the per-language ones, which is the duplication this task exists to remove. Decide, with the options and the evidence for each stated: (i) the signature is the syntactic half of the clause classes, the clause classes extend it, and the operators of TruthClauses.lean move down to it; (ii) the clause classes stay the one generic home and the per-language syntax files take their operators from them; (iii) two layers tied by rfl rows, and why that would not be a wrapper to rip out later. The answer fixes where the interval operators and the next and prev encoding of deliverables (b) and (c) live, what the temporal rules of the proof mode are stated about, and how deliverable (d) recognizes L-star operators. State the import and layering consequences (TruthClauses.lean is at the semantics layer; syntax sits below it) and the cost to the open contributions that build on the current definitions.

---

### 974. Theorem library stability entries
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 944, Task 947, Task 952, Task 970, Task 971, Task 973

**Description**: MILESTONE M21 (records/proof-mode.md), LANE: library, then evaluation. Theorem library: entries for the stability operator. Populate and sweep the entries that name `⊡`, which the tableau does not reach. These entries are sections of the ModalBoolean and ModalTemporalBoolean fragments: the family layout is fixed with `⊡` in Modal, the shared statement is a K core with T, 4 and 5 as further members, and docs/development/stability-operator-family.md gives the grounds. ALSO read docs/development/proof-mode-adequacy-perpetuity.md; if its verdict is RE-PLAN, do the entries and stop before the sweep. (1) THE COLLAPSE: derive `φ ↔ ⊡φ` in TM⁺ for state-local `φ`, by induction on the formula (it is proved as a validity only, `plusStateLocal_stab_iff`, FormalSystem/PlusLanguage/PlusStateLocal.lean), and retire its conjecture. (2) S5 LAWS for `⊡` and for `⟐`, entered through the parameterized statement they share with `□` and `◇`; every law present for `□`/`◇` is present for `⊡`/`⟐`. (3) `□φ → ⊡φ` and its consequences. (4) The pasting schemata PS and US with their pure-future and pure-past side conditions, their consequences, and the principles for `Will`, `will`, `Could` and `could`. (5) Every entry states its SUBSTITUTION CLASS: schematic, or restricted to atoms or state-local formulas in named variables, since AS `p → ⊡p` makes TM⁺ not closed under uniform substitution. (6) Pair each refutation in FormalSystem/PlusLanguage/PlusNonValidities.lean with the theorem it bounds. (7) SWEEP: a selection of these entries, each chosen for a stated reason, is proved in the TM⁺ proof mode against its registered statement, with diagnostic records, and a report at docs/development/proof-mode-sweep-stability.md gives the measurements of the first gate and a missing-rule list, each item added or named with a proposed description. No verdict. DONE WHEN: the entries build, the collapse is a derivation, and the report exists. Hard dependencies: `theorem_library_layout_and_registry`, and `proof_mode_s5_aware_box_scopes` for the `⊡` scopes. Sequencing: `proof_mode_reprove_perpetuity` (so the gate can hold the sweep), `proof_mode_abstract_frontend_interface` (so the shared S5 statement is proved once), `theorem_library_countermodels` (for the pairing). The design is records/theorem-library.md; milestones, lanes and gates are in records/proof-mode.md. BimodalLib imports FormalSystem and FormalSystem never imports BimodalLib. Nothing in BimodalLib contains `sorry`, a new `axiom` or `native_decide`. When this record implements part of the design, revise docs/ to describe what now exists and cut that part from the record under records/.

---

### 973. Theorem library countermodels
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 971, Task 972
- **Research**: [973_theorem_library_countermodels/reports/01_theorem-library-countermodels.md]
- **Plan**: [973_theorem_library_countermodels/plans/01_theorem-library-countermodels.md]
- **Summary**: [973_theorem_library_countermodels/summaries/01_theorem-library-countermodels-summary.md]

**Description**: MILESTONE M20 (records/proof-mode.md), LANE: library. Theorem library: countermodels. Keep every refuted inference with a checked refutation. A countermodel entry records an inference `Γ ⊭ φ`, a frame class, a model, and a proof of non-validity at one of three grades: SEMANTIC (a Lean theorem by an explicit model), CERTIFICATE (a finite certificate accepted by a proved checker, the witness-family checkers at ZTime), GATED TABLEAU (an open saturated branch passing the gates, with the gate theorem applied). A fourth grade, EVALUATOR-CHECKED (a refutation checked by the evaluator of records/semantic-proof-mode.md against witnesses the caller supplies), is anticipated but not admitted by this record yet: its client is the evaluator milestone, C3 of records/milestones.md, and it waits on that evaluator and on records/semantic-proof-mode.md landing, neither of which exists on `main` today — do not assume this grade is as ready as the three above. (1) Define the entry type and its registration, filed by the fragment of the refuted inference and the strongest frame class at which the model lives. (2) Register the hand-built refutations already in the tree: FormalSystem/PlusLanguage/PlusNonValidities.lean, FormalSystem/StarLanguage/StarNonValidities.lean where the inference is statable in L or L⁺, and the independence results under FormalSystem/Metalogic/Independence/. (3) Admit the gated tableau refutations and accepted certificates produced by `theorem_library_tableau_pipeline`. An ungated `invalid` verdict stays a conjecture and is never admitted. (4) TRANSFER, each resting on a named theorem: a model at a stronger frame class refutes at every weaker class it belongs to; a countermodel in L refutes in L⁺ through `plusValidIn_ofFormula_iff`. (5) NEAR MISSES: where a refuted inference is the converse of a theorem entry or a schema with its side condition dropped, the two entries name each other; the five refutations bounding the `⊡` axiom set are the model. (6) LOOKUP: an inference can be looked up, up to renaming of atoms, for use by `proof_mode_countermodels_for_unclosed_leaves`. DONE WHEN: the three grades exist with at least one entry each, the existing refutations are registered, lookup is tested, and the reference page documents the grades. Hard dependency: `theorem_library_layout_and_registry`. Sequencing: after `theorem_library_tableau_pipeline`, which supplies the tableau-fed entries; parts (1), (2), (4) and (5) do not need it. The design is records/theorem-library.md; milestones, lanes and gates are in records/proof-mode.md. BimodalLib imports FormalSystem and FormalSystem never imports BimodalLib. Nothing in BimodalLib contains `sorry`, a new `axiom` or `native_decide`. When this record implements part of the design, revise docs/ to describe what now exists and cut that part from the record under records/.

---

### 972. Theorem library tableau pipeline
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 961, Task 971
- **Research**: [972_theorem_library_tableau_pipeline/reports/01_tableau-pipeline-into-library.md]
- **Plan**: [972_theorem_library_tableau_pipeline/plans/01_tableau-pipeline-into-library.md]
- **Summary**: [972_theorem_library_tableau_pipeline/summaries/02_tableau-pipeline-into-library-summary.md]

**Description**: MILESTONE M19 (records/proof-mode.md), LANE: library. Theorem library: tableau pipeline. Fill the fragments the tableau covers from its verdicts, reusing the dataset tooling and rebuilding none of it. One command enumerates the formulas of Boolean, ModalBoolean (with `□` only), TemporalBoolean and ModalTemporalBoolean (L) up to a stated complexity bound, one representative per renaming of atoms (BimodalTools/FormulaEnumerator.lean, BimodalTools/AtomCanonicalization.lean, with the fragment as a filter), at each frame class the tableau accepts, and runs the stages of records/theorem-library.md: enumerate, decide, extract, certify, admit. ADMISSION: a valid formula with an extracted `DerivationTree` is generalized from atoms to schema variables and admitted as a theorem entry unless it is a substitution instance of an entry already present; an `invalid` verdict is passed to the countermodel half only if its open branch passes the eight gates of `not_valid_of_hasOpen_int` (FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean) or, at ZTime, a witness-family certificate is accepted by `decidableCertifies`; every other outcome (`fuelExhausted`, `extractionFailed`, an ungated `invalid`) is registered as a conjecture with its verdict and is never admitted as a result. DIAGNOSTICS: each stage emits its records in the schema fixed by `proof_mode_axiom_audit_and_cost_baseline`. USER RULING NEEDED (open decision 3 of records/theorem-library.md): the complexity bound per fragment and frame class, and whether admission filters by an interestingness measure (BimodalTools/InterestingnessMetrics.lean) or keeps every non-subsumed theorem; research measures the yield at each bound (at complexity 4 over Base it is 17 valid, 669 invalid, 120 undetermined of 806, data/bmlogic-c4_metadata.json) and recommends. Until `theorem_library_countermodels` has landed, certified refutations are written in the form it will read and not yet admitted. DONE WHEN: the command runs end to end at the ruled bound, admitted entries build, the subsumption check is tested, and the stage records exist with the command that reproduces them. Hard dependencies: `theorem_library_layout_and_registry` (the registry) and `proof_mode_axiom_audit_and_cost_baseline` (the record schema). It adds no rule and edits no proof-mode file. The design is records/theorem-library.md; milestones, lanes and gates are in records/proof-mode.md. BimodalLib imports FormalSystem and FormalSystem never imports BimodalLib. Nothing in BimodalLib contains `sorry`, a new `axiom` or `native_decide`. When this record implements part of the design, revise docs/ to describe what now exists and cut that part from the record under records/.

---

### 969. Proof mode views tier
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 960, Task 977, Task 986

**Description**: LOCATION (binding over any module path named below): the view table and the pair `lunfold` and `lfold` are on main in FormalSystem/Tactic/FormulaViews.lean, below the derivation tactics and importing none of them. This tier is built there; there is no FormalSystem/Automation/ProofMode/Views.lean. The temporal contribution adds FormalSystem/Tactic/TemporalFormulaViews.lean beside it. ORDER: runs after `connective_signature_layer_shared_primitives`, so that each view row is registered once over the signature and not once per language, and after `proof_mode_views_report_swallowed_view_error`, which corrects the message this tier then tests. MILESTONE M16 (records/proof-mode.md), STREAM: views. ARCHITECTURE (records/proof-mode-architecture.md): tier Views; filed under every family; modules the views modules. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. Proof mode: views tier. Add the tactics that change only how a formula is written: folding and unfolding a defined operator (`¬`, `∧`, `∨`, `↔`, `◇`, `F`, `G`, `P`, `H`, `X`, `Y`, always, sometimes, the inclusive and weak Until and Since forms, and the TM⁺ counterparts) and replacing a formula by one that is equal as a Lean term. A view uses definitions and formula equalities ONLY: no axiom, no derivation rule, no object context, no frame class. It leaves the judgment unchanged up to definitional equality or a cast, and it can fail only because the formula has the wrong shape. Logical rewriting (replacing `A` by `B` because an implication or equivalence is derivable) is NOT a view and stays in the derivation tier. Deliverables: (1) the fold/unfold tactics, acting on the goal or on a named hypothesis, at the head or at a named position; (2) the expansion lemmas they rest on, each a `rfl` or a stated formula equality, filed with the syntax of the operator they expand; (3) the operator-matching helper the elaborators use (`operatorArgs?` and the occurrence views) expressed through the same table, so that what a tactic sees as an operator and what a view folds agree; (4) tests and a guide page stating the tier boundary. The plan settles the tactic names (one fold/unfold pair taking an operator name, or one tactic per view; open decision 1 of the architecture record) and where the tier lives: it must sit BELOW the derivation tactics and import none of them, so that a separate semantic mode can use it too. COORDINATION WITH OPEN CONTRIBUTIONS. The rewriting contribution has merged: extract the views already inside it — the seven rows already registered in FormalSystem/Tactic/FormulaViews.lean, the equality handler of `lrewrite`, and the view-preparation pass of `lsimp` — into this tier, and leave the logical rewriting where it is; do not write a second copy. The temporal contribution has not merged: its twenty further rows (ten Formula, ten PlusFormula, the extra pair being `after`) and its retirement of `ltemporal_dual` remain owed extraction once it lands — do not state them as already extractable; build this tier on the merged code today and record that extraction as owed. DONE WHEN: every defined operator in TM and TM⁺ has a fold and an unfold with a test in each direction; a `#print axioms` check on a views-only script shows no object-language axiom is involved; a negative test asserts the wrong-shape message; and the guide page exists. DEPENDENCIES. Hard: none. Sequencing: `proof_mode_split_shared_test_and_guide_files`, for the family layout. Consumers: `proof_mode_always_sometimes_scopes` (always and sometimes are defined operators), `proof_mode_abstract_frontend_interface` (the interface states rules about defined operators directly, which views make possible) and through it `proof_mode_leads_to_invariance_library` (present-inclusive leads-to is a defined form). The derivation proof mode lives in FormalSystem/Automation/ProofMode/ and FormalSystem/Theorems/ProofMode/; FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`).

---

### 968. Proof mode reference manual chapter
- **Status**: [NOT STARTED]
- **Task Type**: typst
- **Topic**: proof-mode
- **Dependencies**: Task 948, Task 952

**Description**: STRUCTURE. Organize the chapter by records/proof-mode-architecture.md: the three tiers first (views, derivation, and the one-way relation to semantic truth), then one section per operator family with its pure rules, then one per interaction, then the frame-specific rules. State the purity convention: a rule's statement names only the operators of its family. If logical rewriting has merged, state the congruence step each operator supplies and the polarity table. MILESTONE M15 (records/proof-mode.md), STREAM: writing. Task type: typst. Proof mode: reference-manual chapter. The paper sources under typst/ do not mention the derivation proof mode. Write a chapter (alongside typst/chapters/p4-proof-automation.typ) that states the derivation rules the tactics implement (context substitution, cut, generalized K for each universal operator, temporal bind and progress, integer-time invariance, and the rules added since: S5-aware and cross-modal scopes, always and sometimes, linearity cases, Until and Since introduction, unfolding and induction, the Dense and RTime rules), the scope-safety guarantee (a hypothesis keeps its source context in its type), and the frame restriction each rule carries. Ground every stated rule in a named declaration under FormalSystem/Theorems/ProofMode/. DONE WHEN: the chapter compiles and `bash .claude/scripts/chapter-quality-check.sh` reports no blocking finding for it. DEPENDENCIES. Hard: `proof_mode_reprove_temporal_slice`, so that the chapter documents the rule set after both adequacy measurements. Sequencing: after `proof_mode_abstract_frontend_interface`, which deletes the TM⁺ rule copies and restates every pure rule over one interface; a chapter grounded in declaration names written before that refactor would cite names it removes. That edge also places the chapter after the Dense and RTime rules it must state.

---

### 967. Proof mode countermodels for unclosed leaves
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 957, Task 966, Task 973

**Description**: REVISED (records/proof-mode.md, M14b; records/theorem-library.md, 'Countermodels'): the first source of a countermodel is this repository, not the ModelChecker. ORDER OF LOOKUP for a leaf no closer proves: (1) the countermodel half of BimodalLib, by `theorem_library_countermodels`' lookup; (2) failing that, the in-repository tableau, reporting a countermodel only at a stated grade (semantic, certificate, gated tableau) and reporting an ungated `invalid` verdict as heuristic; (3) only for a leaf outside the tableau's language (one naming `⊡`, or at a class the tableau does not accept), export in a form the ModelChecker accepts and report what it returns the same way. A countermodel is a diagnostic and never closes a goal. Parts (1) and (2) do not need the transition-systems report; part (3) follows its division of labour. HARD DEPENDENCY ADDED: `theorem_library_countermodels`. MILESTONE M14b (records/proof-mode.md), STREAM: closure automation / dual verification. Proof mode: countermodels for unclosed leaves. This repository is paired with a ModelChecker in a dual-verification design: derivations from one side, countermodels from the other. Build the bridge at the point where it is most useful: a proof-mode leaf that no closer proves. Export the leaf (context and goal formula) in a form the ModelChecker accepts, and report a returned countermodel against the leaf. A countermodel is a diagnostic only and never closes a goal. FIRST read docs/development/proof-mode-transition-systems.md, produced by `proof_mode_transition_systems_tm_specifications`, and follow its division of labour; also read the existing export tooling in BimodalTools/ and reuse its formula serialization where it fits. DONE WHEN: an export command exists with a test on a non-derivable leaf, and the guide's closing page documents the round trip. DEPENDENCIES. Hard: `proof_mode_transition_systems_tm_specifications`. Sequencing: after `proof_mode_decision_procedure_leaf_closers`, so that "no closer proves it" is measured against the full closer and the two records do not edit the closing tactic at once. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules); FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged. Milestones, lanes and gates are in records/proof-mode.md.

---

### 966. Proof mode decision procedure leaf closers
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 955, Task 952

**Description**: MILESTONE M14a (records/proof-mode.md), STREAM: closure automation (metatheory, then elaborators). Proof mode: leaf closers from the decision procedures. The leaf closer added by `proof_mode_close_leaves_with_automation` is propositional and TM-only. RESEARCH FIRST: for each decision procedure under FormalSystem/Metalogic/Decidability/, establish whether it returns a native derivation or only a validity verdict; only the former can close a proof-mode goal, because nothing semantic may stand in for a derivation. Starting points to re-verify against the tree, not to inherit: ProofExtraction.lean (`extractProof`, `findProofCombined`) returns `DerivationTree` terms when its search succeeds and is incomplete, which is acceptable for a closer that may fail; `decidableValidZTime` (the witness-family route) decides validity only and yields no derivation; the propositional procedure is the one the existing closer already uses. Completeness of proof extraction is open mathematics owned by `discharge_proof_extraction_completeness` and is NOT a prerequisite: a closer needs soundness-by-construction and a clear failure message, not completeness. Also settle whether any procedure serves TM⁺ goals. For each procedure that returns a derivation, extend the leaf closer to use it on goals in its fragment. DONE WHEN: a table in the guide's closing page classifies each procedure (derivation / verdict only / fragment / language), and each usable one closes at least one non-propositional leaf in the tests, yielding a native derivation, with no `native_decide` and no new axiom. DEPENDENCIES. Hard: `proof_mode_close_leaves_with_automation`, which provides the closing tactic to extend. Sequencing: after `proof_mode_abstract_frontend_interface`, which rewrites the closer's elaborator along with every other; the research half depends on neither and may be dispatched early. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules); FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged. Milestones, lanes and gates are in records/proof-mode.md.

---

### 965. Proof mode adoption after perpetuity verdict
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 178, Task 947

**Description**: REVISED (records/proof-mode.md, M12): where proof-mode proofs of library entries live is settled, BimodalLib/ProofMode/<Fragment>/, and this record does not decide it. The ruling still needed is what 'default' means, with candidates (a) new example and case-study modules must use the mode; (b) every new derived theorem is registered in BimodalLib with a proof-mode script beside it; (c) the mode stays optional outside the library's sweeps. ADDED TO DONE WHEN: the guide states that a theorem entering BimodalLib comes with a proof-mode script or a recorded failure class. The module proved in the mode must be outside both the tests and the library's sweeps, so FormalSystem/Examples/ProofMode/Adoption.lean stands. MILESTONE M12 (records/proof-mode.md), STREAM: evaluation and writing. Opens on a GO verdict, alongside the linear-time rules. Proof mode: adoption after the Perpetuity adequacy verdict. FIRST read docs/development/proof-mode-adequacy-perpetuity.md, produced by `proof_mode_reprove_perpetuity`; if its verdict is RE-PLAN, stop and report. On GO, decide and write down in docs/user-guide/derivation-proof-mode.md where proof-mode proofs live, which kinds of new derivation are to be written in the mode, and what "default" means given that FormalSystem/Theorems/ is below FormalSystem/Automation/ in the layer order (ORGANISATION.md) and cannot import it. Then prove at least one module in the mode that is neither a test nor an adequacy module, under FormalSystem/Examples/ProofMode/. USER RULING NEEDED BEFORE IMPLEMENTATION: the meaning of "default". The candidates are (a) new example and case-study modules must use the mode; (b) new derived theorems get a proof-mode companion under FormalSystem/Examples/; (c) the mode stays optional and this record only fixes where its proofs live. Research presents the three with their costs and the plan stops for the ruling. DONE WHEN: the guide section exists and the module builds. Hard dependency: `proof_mode_reprove_perpetuity` with a GO verdict. ADJACENCY: `publication_examples_and_demo` declares FormalSystem/Examples/ as a directory, and `proof_mode_reprove_temporal_slice` adds a sibling module and an import line to FormalSystem/Examples.lean; neither presupposes this record, so the overlap serializes dispatch and is not a dependency.

---

### 964. Proof mode goal display
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 963

**Description**: PATH REVISED: the gate-one scripts this record designs the display against live under BimodalLib/ProofMode/ (the sweep of `proof_mode_reprove_perpetuity`), not FormalSystem/Examples/ProofMode/Perpetuity.lean. MILESTONE M6c (records/proof-mode.md), STREAM: usability. Proof mode: compact goal display. Add a delaborator or custom goal view that shows named hypotheses and the object goal compactly. A hypothesis's object context may be elided ONLY when it equals the goal's context; a hypothesis whose source context differs must stay visibly marked, because that difference is exactly what makes `lexact` / `lapply` reject it inside a new scope. Design the view against the real scripts in FormalSystem/Examples/ProofMode/Perpetuity.lean, not against the small acceptance examples. DONE WHEN: the view is in place in a new module FormalSystem/Automation/ProofMode/Display.lean, `#guard_msgs` tests pin the rendering for a same-context goal and for a goal with a differing-context hypothesis, and a guide page documents it. DEPENDENCIES. Hard: none. Sequencing: stacked after `proof_mode_nested_intro_patterns` in the usability stream (and through it after the Perpetuity adequacy gate, which supplies the real scripts). It does not wait for the temporal adequacy report. `proof_mode_abstract_frontend_interface` depends on this record because it rewrites every elaborator. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules); FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged. Milestones, lanes and gates are in records/proof-mode.md.

---

### 963. Proof mode nested intro patterns
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 954, Task 947

**Description**: ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under Boolean; modules Boolean. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. Pattern destructuring is a Boolean-family feature; it must not reach into modal or temporal operators. MILESTONE M6b (records/proof-mode.md), STREAM: usability. Proof mode: nested introduction patterns for `lcases` and `lintro`. Today `lcases` takes exactly two names. Let both tactics accept nested patterns (conjunction and disjunction destructuring to any depth, with an anonymous/skip form), elaborating to the existing pure rules; add no rule that exists only to serve a pattern. DONE WHEN: both tactics accept nested patterns, with acceptance tests, a negative test asserting the message for every malformed-pattern error, and a section in the basic guide page. DEPENDENCIES. Hard: none. Sequencing: after `proof_mode_error_message_coverage`, whose coverage check this record's new error sites must pass, and after the Perpetuity adequacy gate `proof_mode_reprove_perpetuity` (FIRST read docs/development/proof-mode-adequacy-perpetuity.md; if its verdict is RE-PLAN, stop and report), which also places it after the bimodal scope chain that edits the same elaborators. It runs alongside the linear-time rules, which edit the temporal family files and not Basic.lean. `proof_mode_abstract_frontend_interface` depends on this record because it rewrites every elaborator. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules); FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged. Milestones, lanes and gates are in records/proof-mode.md.

---

### 962. Proof mode deduction theorems star open
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: None

**Description**: MILESTONE M9b (records/proof-mode.md), STREAM: metatheory. Independent of every other proof-mode record and of both adequacy gates: this is metatheory about two calculi and needs no proof-mode interface. Its consumer is `proof_mode_instances_other_languages`, which depends on it so that the per-language accounting there can cite a theorem or a written obstruction instead of deferring. Proof mode: deduction theorems for the Star and Open calculi. A proof-mode instance for an object language needs a deduction theorem, a generalized K rule per universal operator, and context substitution. TM has them in FormalSystem/Theorems/, TM⁺ in FormalSystem/Theorems/ProofMode/PlusRules.lean, and Minus in FormalSystem/Metalogic/Conservativity/MinusDeduction.lean. `StarDerivationTree` (FormalSystem/StarLanguage/Derivation.lean) and `OpenDerivationTree` (FormalSystem/OpenLanguage/OpenDerivation.lean) have none. Prove the three for each calculus, or, where one fails, write down the rule of the calculus that blocks it. Plan Star and Open as separate phases, Star first. SCHEDULING NOTE for the Open half: the L^▷ line is demoted by the user ruling of 2026-11-05 and is not to be dispatched ahead of L-plus critical-path work; the Open phase follows that ruling and may be left as a named follow-up if it is not small. It shares the aggregator FormalSystem/OpenLanguage.lean with `open_language_subformula_closure`, `open_language_substitution_closure` and `open_modal_invariance_ray_agreement_lifting`; none presupposes this record and this record presupposes none of them, so the overlap serializes dispatch and is not a dependency. `open_language_stability_primitive_removal` is a decision record only and leaves the calculus unchanged. DONE WHEN: each of Star and Open has the three results with no `sorry` and no new axiom, or a written obstruction naming the blocking rule in the language's README. Expected files: FormalSystem/StarLanguage/StarDeduction.lean and FormalSystem/OpenLanguage/OpenDeduction.lean. Hard dependencies: none.

---

### 961. Proof mode axiom audit and cost baseline
- **Status**: [COMPLETED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: None
- **Research**: [961_proof_mode_axiom_audit_and_cost_baseline/reports/01_axiom-audit-cost-baseline.md]
- **Plan**: [961_proof_mode_axiom_audit_and_cost_baseline/plans/01_axiom-audit-cost-baseline.md]
- **Summary**: [961_proof_mode_axiom_audit_and_cost_baseline/summaries/01_axiom-audit-cost-baseline-summary.md]

**Description**: REVISED: THIS RECORD ALSO FIXES THE DIAGNOSTICS STANDARD (records/theorem-library.md, 'Diagnostics'; records/proof-mode.md, M13), and the adequacy gate now depends on it HARD. In addition to the audit and baseline below: (a) define ONE record schema for every stage of the library pipeline (enumerate, decide, extract, certify, admit, re-prove, compare), a record keyed by statement identifier and stage and carrying fragment, frame class, commit and the command that produced it, with the per-stage fields the record lists; (b) implement the commands that emit the RE-PROVE and COMPARE records for a proof-mode script (outcome, failure class, tactic count and distinct tactics, size of any term-mode escape, elaboration time, size of the derivation built, script length against the hand proof), which the cost script below is the first use of; (c) document the schema and every field at docs/reference/diagnostics.md, since a stage is not complete until its fields are documented. The other stages' emitters are written by `theorem_library_tableau_pipeline` against this schema. Design the schema against the existing dataset records under data/ and BimodalTools/ so that one is not invented beside the other. CONSUMERS: `proof_mode_reprove_perpetuity` (hard), `theorem_library_tableau_pipeline` (hard). COORDINATION WITH OPEN CONTRIBUTIONS. Three stacked pull requests from a collaborator are open against this area: #7 (logical rewriting `lrewrite` / `lsimp`, the congruence kit), #8 (Until/Since introduction, folding and ZTime unfolding, `linduction`, whole-judgment time reflection, `keeping`, strict leads-to rules) and #9 (a semantic mode, asked to be re-proposed separately). If #7 has merged, add one nested logical rewrite to the cost baseline: composed congruence certificates are the terms most likely to be large, and the contribution promised a baseline and recorded none. Report the axiom audit and the cost per tier (views, derivation). MILESTONE M13 (records/proof-mode.md), STREAM: evaluation. Does not wait on the Perpetuity adequacy verdict: it changes no rule and no tactic. It is ordered BEFORE the adequacy gate (`proof_mode_reprove_perpetuity` depends on it) so that the gate report can quote a cost figure. Proof mode: axiom audit and cost baseline. No test states which axioms a proof-mode derivation depends on, and nothing measures the derivation terms the tactics build. (1) Add a test module, on the pattern of Tests/BimodalTest/WalkthroughAxioms.lean, that asserts the axiom set of at least one derivation per tactic family (basic, modal, temporal, discrete) in TM and in TM⁺. (2) Record a baseline: derivation-term size and elaboration time for each acceptance example and for one long script with at least five nested `lintro` steps, since `lintro` discharges through the deduction theorem, which transforms a whole derivation, so cost on long scripts is an open question. Write the figures and the command that reproduces them to docs/development/proof-mode-cost-baseline.md, with the measuring script checked in. DONE WHEN: the audit test passes in `lake test` and the baseline file exists with its reproduction command. Hard dependencies: none; the dependency on the file split is for the test directory layout only. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules); FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged. Milestones, lanes and gates are in records/proof-mode.md.

---

### 960. Proof mode split shared test and guide files
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: None

**Description**: NO ModalTemporal MODULE OR CLASS (records/proof-mode-architecture.md, Interactions; binding over the text below wherever they differ): every interaction includes Boolean and every class other than Boolean extends Boolean. Rules joining Modal and Temporal, including the scope rules whose statements name no connective, are filed in ModalTemporalBoolean (PlusModalTemporalBoolean for TM+), in its scope-rule section. FAMILY LAYOUT REVISED (records/proof-mode-architecture.md, binding over the family list below wherever they differ): the families are Boolean, Modal and Temporal. There is NO Stability family and NO StabilityModal module. Rules, tactics, tests and guide sections for `⊡` and `⟐` are filed in the Modal modules (and in ModalBoolean, ModalTemporal, ModalTemporalBoolean by what else their statements name), as a section after the rules for `□` alone, so that the part TM instantiates can be read off. Module names list families in the order Modal, Temporal, Boolean. The interactions are ModalBoolean, TemporalBoolean, ModalTemporal and ModalTemporalBoolean. The same names are the fragment names of BimodalLib (records/theorem-library.md). The family layout is fixed with `⊡` in Modal; the shared statement is a K core with T, 4 and 5 as further members, and docs/development/stability-operator-family.md gives the grounds. MILESTONE M0 (records/proof-mode.md), STREAM: layout. FIRST IN THE PROGRAMME: every other proof-mode record files its work into the layout this one produces. COORDINATION WITH OPEN CONTRIBUTIONS. The rewriting contribution has merged and filed its own rules, tests and guide pages by family. The semantic-mode contribution is recommended for closure, its content superseded by the semantic lemmas and the semantic record. The temporal contribution (feat/proof-mode-temporal) is the only still-open blocker: it edits files this record moves and, like the rewriting contribution, already splits its own additions into per-family modules, so what remains to move once it merges is narrower than originally scoped — chiefly the shared guide index (docs/user-guide/derivation-proof-mode.md), both ProofMode READMEs, and whatever of FormalSystem/Automation/ProofMode/Meta.lean, Modal.lean and Temporal.lean predates the family split. Do NOT dispatch the implementation of this record while the temporal contribution is open: run it after it is merged or declined, and move whatever it added into the same layout. This record is now held, so that its status carries the dispatch rule above rather than leaving it to this paragraph alone; `hold_reason` names the lift condition and `prior_status` holds the status to restore. Research and planning are still admissible, through an explicit `/orchestrate --research` or `--plan` override, which admits a held record for one dispatch and preserves the hold afterward. Proof mode: establish the operator-family layout. The architecture record (records/proof-mode-architecture.md) files every rule, tactic, test and guide page by the operators its statement names. Families: Boolean, Modal, Stability (TM⁺), and Temporal with its Future and Past halves. Interactions are separate modules named by the families they join, Boolean included: ModalBoolean, TemporalBoolean, ModalTemporal, ModalTemporalBoolean, StabilityModal. Frame class is a suffix on the family: TemporalZTime, TemporalDense, TemporalRTime. A pure family module contains no implication in any statement. (1) RULES. Move the existing pure rules in FormalSystem/Theorems/ProofMode/ into modules named by that scheme, statements and proofs unchanged: Basic.lean to Boolean.lean; Possibility.lean to Modal.lean; Temporal.lean to Temporal.lean and TemporalBoolean.lean; Discrete.lean to TemporalZTime.lean; the TM⁺ copies likewise with their `Plus` prefix, PlusRules.lean staying as the TM⁺ base. Where an existing rule's statement names an implication and a second family, it goes to that interaction's module; list every such classification in the summary. (2) TACTICS. Rename the elaborator modules in FormalSystem/Automation/ProofMode/ to match (Basic.lean to Boolean.lean, Discrete.lean to TemporalZTime.lean), Meta.lean unchanged. No tactic changes behaviour or syntax. (3) TESTS. Split the acceptance examples into one file per family or interaction under Tests/BimodalTest/Automation/ProofMode/ (BooleanTest.lean, ModalTest.lean, TemporalTest.lean, TemporalZTimeTest.lean, and so on), every example unchanged; keep ProofModeTest.lean as an aggregator that only imports them. (4) GUIDE. Keep docs/user-guide/derivation-proof-mode.md as index and foundations, and give each family or interaction that has tactics its own page under docs/user-guide/proof-mode/ (boolean.md, modal.md, temporal.md, temporal-ztime.md, and so on). The index states the three tiers and the family scheme in a paragraph and links to the architecture record. (5) READMES. One bounded inventory section per module in each ProofMode README. (6) SCOPES. Check the `file_scope` declared on every open record whose slug begins `proof_mode_` against the layout actually produced and correct any path that differs; they were written against the names above. DONE WHEN: `lake build` and `lake test` pass with every existing example unchanged in the family files; no statement, proof or tactic behaviour has changed; every module name follows the scheme; and every open proof-mode record's `file_scope` names paths that exist or that the record will create. Hard dependencies: none. FormalSystem/Theorems/ must not import FormalSystem/Automation/.

---

### 957. Proof mode transition systems tm specifications
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: proof-mode
- **Dependencies**: Task 956

**Description**: MILESTONE M11 (records/proof-mode.md), STREAM: research and writing. DEPENDENCIES AS FILED: `proof_mode_leads_to_invariance_library` (hard, for the assessment of which rules carry the arguments). The survey of Veil and of the ModelChecker's role depends on no rule: a research dispatch may draft it at any time, and only the rule assessment and the final recommendation wait. CONSUMER: `proof_mode_countermodels_for_unclosed_leaves` follows this report's division of labour, so the report must state that division concretely (what is exported, in what form, and what comes back). ORIGINAL DESCRIPTION FOLLOWS. Research: verifying transition systems against TM specifications. RESEARCH REPORT, no Lean required; the deliverable is the file docs/development/proof-mode-transition-systems.md. Investigate verifying a transition system against a TM specification using the derivation proof mode: how a transition system is presented as a TM theory or model, which proof-mode rules carry the safety and liveness arguments (the leads-to and invariance library, including its reflexive leads-to definition and finite well-founded progress rule), what the Veil integration that the proof-mode user guide names as separate work would involve, and the division of labour with the ModelChecker in the dual-verification architecture (countermodels from one side, derivations from the other). DONE WHEN: the report at the stated path gives a recommended architecture, the smallest worthwhile first case study, and proposed descriptions for the tasks that would follow. Source: research/NEW_DIRECTIONS.md, row PM-14. Context: the derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with the user guide at docs/user-guide/derivation-proof-mode.md and the adequacy reports at docs/development/proof-mode-adequacy-perpetuity.md and docs/development/proof-mode-adequacy-temporal.md.

---

### 956. Proof mode leads to invariance library
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 948, Task 950, Task 952

**Description**: ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under the Temporal-with-Boolean interaction for leads-to (its statement is an implication under a temporal operator), Temporal at ZTime for invariance and well-founded progress; modules TemporalBoolean, TemporalZTime; the user-facing tactic family and guide page are named liveness. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. COORDINATION WITH OPEN CONTRIBUTIONS. Three stacked pull requests from a collaborator are open against this area: #7 (logical rewriting `lrewrite` / `lsimp`, the congruence kit), #8 (Until/Since introduction, folding and ZTime unfolding, `linduction`, whole-judgment time reflection, `keeping`, strict leads-to rules) and #9 (a semantic mode, asked to be re-proposed separately). IF #8 HAS MERGED it supplies `leadsToConsequence`, `leadsToTrans` and `progressCases` on the STRICT form `G(A → F B)`. That does not settle definitional point (1) below: the present-inclusive leads-to is still to be defined, as a view from `proof_mode_views_tier`, and the strict rules become the layer underneath it, related to it by stated rules. Do not prove a second copy of the strict rules. MILESTONE M10 (records/proof-mode.md), STREAM: specification reasoning (rule theory, then elaborators). DEPENDENCIES AS FILED: `proof_mode_until_since_intro_unfold_induction` and `proof_mode_reprove_temporal_slice` (hard: the library builds on the induction rule and on the missing-rule list), and `proof_mode_abstract_frontend_interface` (sequencing: with the interface each rule is proved once for TM and TM⁺ instead of twice). The former edge on `proof_mode_instances_other_languages` is REMOVED: the done-state names TM and TM⁺ only and uses no other-language instance. Expected new modules: Liveness.lean in each ProofMode directory, LivenessTest.lean, guide page liveness.md. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: leads-to and invariance library. `lprogress` (composition of G(A → F B) guarantees) and `linvariant` (integer-time invariance) are leads-to and invariance rules in the TLA / UNITY sense. Extend them to the standard rule set for safety and liveness: invariance, leads-to transitivity and disjunction, and well-founded progress, each as a pure rule with a tactic. Two definitional points must be settled in the plan before any rule is proved. (1) G and F are STRICT here, so the existing `G(A → F B)` is irreflexive and says nothing about the present: standard rules such as `A ⇒ B` gives `A leads-to B`, or leads-to reflexivity, fail for it. Define leads-to as a named abbreviation with reflexive operators (present-inclusive always and eventually), state it explicitly, and relate it to the strict form `lprogress` uses. (2) The object language has no quantifiers, so well-founded progress is the FINITE-family (lattice) rule: a metalevel induction over a finite well-founded index (a `Fin n` or list-indexed family of formulas with a finite disjunction), not an ordinal-indexed schema. DONE WHEN: the rules exist for TM and TM⁺ with worked examples in the tests and a section in the user guide that states the leads-to definition. Source: research/NEW_DIRECTIONS.md, row PM-13. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 955. Proof mode close leaves with automation
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 958, Task 960

**Description**: MILESTONE M2 (records/proof-mode.md), STREAM: closure automation (elaborators). DEPENDENCIES AS FILED: `proof_mode_split_shared_test_and_guide_files` for the file layout, and the completed `modal_search` repair. The former edge on `proof_mode_always_sometimes_scopes` is REMOVED: the closer uses `propDecide` and deduction and no scope rule, so it runs in parallel with the bimodal scope chain; the adequacy gate still sees leaves automated because `proof_mode_reprove_perpetuity` depends on both. Expected new modules: FormalSystem/Automation/ProofMode/Close.lean, CloseTest.lean, guide page closing.md. `proof_mode_decision_procedure_leaf_closers` extends this closer later. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: close leaf goals with existing automation. Add a closing tactic so the proof mode handles structure and automation handles closure. The primary closer is `propDecide` (FormalSystem/Metalogic/Decidability/Propositional/Tactic.lean): reflective, complete for the propositional skeleton, treats □ / Until / Since subterms as opaque atoms, weakens into the goal's context, and yields a native derivation through the proved `tautologyDerivableFc'` using kernel `decide` only. Because it proves closed theorems and weakens, the tactic must first discharge the goal's object assumptions into implications (deduction, then modus ponens against the assumptions) so that leaves like `[A, A → B] ⊢ B` close. `modal_search` (FormalSystem/Automation/Tactics/) is documented in its own README as pedagogical, not library infrastructure; use it only as an optional bounded fallback for single-modality leaves, never as the default. Both are TM-only: on a TM⁺ goal the tactic must fail with a clear message unless a TM⁺ closer is built here (a TM⁺ reflection through `ofTMSubst` is welcome but not required). DONE WHEN: the tactic closes the propositional leaves arising in the acceptance tests, fails with a clear message otherwise, never produces anything but a native derivation, and adds no axiom (`native_decide` forbidden). Source: research/NEW_DIRECTIONS.md, row PM-12. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 954. Proof mode error message coverage
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 960

**Description**: COORDINATION WITH OPEN CONTRIBUTIONS. Three stacked pull requests from a collaborator are open against this area: #7 (logical rewriting `lrewrite` / `lsimp`, the congruence kit), #8 (Until/Since introduction, folding and ZTime unfolding, `linduction`, whole-judgment time reflection, `keeping`, strict leads-to rules) and #9 (a semantic mode, asked to be re-proposed separately). If #7 and #8 have merged before this record runs, the measured counts below are out of date: those two add about 90 `throwError` sites and no test asserting a message, and the reviews ask the contributor to add them. Re-measure first; this record backfills whatever is still uncovered and its check then holds the line. MILESTONE M6a (records/proof-mode.md), STREAM: usability. Head of the usability stream: `proof_mode_nested_intro_patterns` and then `proof_mode_goal_display` stack on it; those two parts were split out of this record and are no longer in its scope. Proof mode: error-message coverage. Add a negative test asserting the message (`#guard_msgs`, not bare `fail_if_success`, which checks nothing about the message) for every `throwError` path in FormalSystem/Automation/ProofMode/ that lacks one. Measured: 65 `throwError` sites (Modal 24, Temporal 18, Basic 12, Meta 9, Discrete 2) against two negative checks, neither asserting a message. Put the tests in a new file Tests/BimodalTest/Automation/ProofMode/ErrorTest.lean. Then add a regression check, a script under scripts/ wired into the local verification aggregator, that fails when a `throwError` site exists without a negative test or an entry in a short allow-list of unreachable sites, each with its reason; state in the plan how a site is matched to its test. DONE WHEN: every site is covered or listed as unreachable with a reason, the count is reported, and the check fails on a deliberately added uncovered site. DEPENDENCIES. Hard: none. Sequencing: `proof_mode_split_shared_test_and_guide_files` only, for the test layout. It does NOT wait on the adequacy gate: it tests the merged tactics and changes no rule and no tactic. It runs alongside the bimodal scope chain and the leaf closer; those records add their own negative tests under the standing rule, and whichever lands second must leave the check green. Once the check is in, every later proof-mode record's new error site is covered at the time it is added, so no second backfill is needed. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules); FormalSystem/Theorems/ must not import FormalSystem/Automation/. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged. Milestones, lanes and gates are in records/proof-mode.md.

---

### 953. Proof mode instances other languages
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 952, Task 962

**Description**: With the interface as one class per operator family and interaction, a language's instance is the set of classes for the operators it has; the per-language accounting states which classes each language instantiates and, for a missing one, which rule fails. MILESTONE M9a (records/proof-mode.md), STREAM: architecture / language reach. DEPENDENCIES AS FILED: `proof_mode_abstract_frontend_interface` (hard) and `proof_mode_deduction_theorems_star_open` (cross-milestone: that record owns the Star and Open deduction theorems, generalized K and context substitution, so here Star and Open are settled by citing its theorems or its written obstruction; do NOT prove that metatheory in this record). Minus is the expected first instance and sits where the interface record's ruling on its layer puts it. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: instances for the other object languages. Using the proof-mode interface, give each object language that has a native derivation calculus either a proof-mode instance with acceptance tests or a written reason, in the user guide, why it cannot support one. The three with a calculus are Star (`StarDerivationTree`), Minus (`MinusLanguage.DerivationTree`) and Open (`OpenDerivationTree`). Minus already has a deduction theorem (FormalSystem/Metalogic/Conservativity/MinusDeduction.lean), so it is the expected first instance. Star and Open have NO deduction theorem in the tree: an instance for either requires proving one first (plus generalized K and context substitution), which is new metatheory. Research must decide per language whether that is in scope; if it is not small, record the reason in the user guide and propose a follow-up task rather than expanding this one. Hybrid, Nomic, Quant and Source have no derivation calculus and get one line each in the user guide saying so. DONE WHEN: every object language under FormalSystem/*Language/ is accounted for one way or the other. Source: research/NEW_DIRECTIONS.md, row PM-10. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 952. Proof mode abstract frontend interface
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 948, Task 951, Task 963, Task 964, Task 969, Task 977

**Description**: NO ModalTemporal MODULE OR CLASS (records/proof-mode-architecture.md, Interactions; binding over the text below wherever they differ): every interaction includes Boolean and every class other than Boolean extends Boolean. Rules joining Modal and Temporal, including the scope rules whose statements name no connective, are filed in ModalTemporalBoolean (PlusModalTemporalBoolean for TM+), in its scope-rule section. FAMILY LAYOUT REVISED (records/proof-mode-architecture.md, binding over the INTERFACE SHAPE paragraph below wherever they differ): the families are Boolean, Modal and Temporal. There is NO Stability class and NO StabilityModal class. `⊡` and `⟐` belong to the Modal family: the S5 rules (scope introduction, T, 4, 5, the diamond rules) are stated once over a necessity operator given as a parameter and instantiated at `□` and at `⊡`. A language instantiates them at each necessity operator it has, TM at `□` only and TM⁺ at both, with the rule from `□` to `⊡` a member only a language with both provides. How that is carried, a structure taking the operator as a field or a class indexed by the operator, is open decision 5 of the architecture record and is settled in this record's plan: a class keyed on the formula type alone cannot hold two instances for TM⁺. Rules using `p → ⊡p` are not schematic and stay out of the shared statement. The interface classes are also the fragment interfaces of BimodalLib (records/theorem-library.md, 'How inheritance is realized'): after this record, library reference proofs are restated over them. The family layout is fixed with `⊡` in Modal; the shared statement is a K core with T, 4 and 5 as further members, and docs/development/stability-operator-family.md gives the grounds. INTERFACE SHAPE (records/proof-mode-architecture.md, binding). Not one class for the whole rule set: ONE CLASS PER OPERATOR FAMILY carrying that family's pure rules (Boolean, Modal, Stability, and Temporal with its Future and Past halves), and ONE CLASS PER INTERACTION extending exactly the families it joins (ModalBoolean, TemporalBoolean, ModalTemporal, ModalTemporalBoolean, StabilityModal), with frame-specific rules taking their certificate as a premise. A language is an instance of the classes for the operators it has: TM has no Stability instance, and a later language extension adds a family class and the interaction classes it needs without touching an existing class. The truth-clause classes on the semantic side (one per operator) are the model. Each class also carries its operators' congruence steps for logical rewriting. STARTING POINT IF PULL REQUEST #7 HAS MERGED: its `Kit` and `Step` structures in Congruence.lean are already generic over the language and are then instantiated twice (`tmBox` / `plusBox`, ...) and selected by name pairs; make them fields of these classes and delete the pairs. Views come from `proof_mode_views_tier`, on which this record now depends, and are not part of any class. MILESTONE M8 (records/proof-mode.md), STREAM: architecture (rule theory and elaborators together). THE SERIALIZATION POINT OF THE PROGRAMME: this record rewrites every pure-rule module and every elaborator, so nothing that edits either directory may run beside it, and its `file_scope` is the two directories on purpose. DEPENDENCIES AS FILED: `proof_mode_reprove_temporal_slice` (hard: extract the interface from the rule set as it stands after both adequacy tests); `proof_mode_dense_and_real_time_rules` (sequencing: the interface must have seen frame-certificate rules); `proof_mode_nested_intro_patterns` and `proof_mode_goal_display` (sequencing: both edit elaborators this record rewrites). DOWNSTREAM, each stated over the interface instead of twice: `proof_mode_instances_other_languages`, `proof_mode_leads_to_invariance_library`, `proof_mode_decision_procedure_leaf_closers`, `proof_mode_reference_manual_chapter`. DESIGN INPUT: decide where the Minus instance lives (its deduction theorem FormalSystem/Metalogic/Conservativity/MinusDeduction.lean is at layer 3 and imports only the Minus derivation module, so either the instance sits at layer 3 or that file moves down); this is open decision 6 of records/proof-mode.md and bears on the interface layout. If `proof_mode_deduction_theorems_star_open` has landed, read its statements so the class's fields fit Star and Open too; do not wait for it. Test and guide files keep their family layout and should need no change beyond what the acceptance suite's "passes unchanged" criterion allows. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: abstract the frontend over a proof-mode interface. Every rule is written once for TM and once for TM⁺ (FormalSystem/Theorems/ProofMode/Plus*.lean, about 620 lines of copies), and the elaborators dispatch through hard-coded name pairs (`Language.ruleName tm plus` in Automation/ProofMode/Meta.lean). The goal is rules PROVED ONCE, not merely a central table of names: introduce an OBJECT-LEVEL typeclass (over the formula type and its derivation family) packaging what the rules need (the connectives, assumption / modus ponens / weakening / lift, deduction, cut, context substitution, and a generalized K rule per universal operator), prove the pure rules once over that class, and have the elaborators resolve the instance from the goal. A meta-level registry of name pairs alone does not satisfy this task. Extract the interface from the rule set as it stands after the adequacy tests; do not design it ahead of them. Language-specific capabilities (the TM-only leaf closer, TM⁺ stability scopes) are optional members or separate classes, not exceptions written into elaborators. DONE WHEN: TM and TM⁺ are two instances, the duplicated TM⁺ rule proofs are deleted or reduced to instance fields, no elaborator names either language, and the full acceptance suite passes unchanged. Source: research/NEW_DIRECTIONS.md, row PM-9. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 951. Proof mode dense and real time rules
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 947

**Description**: ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under Temporal at Dense and at RTime; modules TemporalDense, TemporalRTime and their Plus copies. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. One frame-gate helper serves `lstep`, `linvariant` and these tactics, with one policy on local certificates. MILESTONE M7 (records/proof-mode.md), STREAM: frame coverage (rule theory, then elaborators). DEPENDENCIES AS FILED: `proof_mode_reprove_perpetuity` with a GO verdict only (FIRST read docs/development/proof-mode-adequacy-perpetuity.md; on RE-PLAN stop and report). The former edges on the Until/Since record and on the usability record are REMOVED as sequencing-only: `density` takes `Dense ≤ fc`, `coDerived` takes `RTime ≤ fc`, `prior_U_gap` and `sep` are axiom constructors at RTime, the certificate pattern is the one `lstep` has, and nothing here uses an Until or Since rule. Runs alongside the linear-time rules in its own family files. Rules are written for TM and TM⁺; `proof_mode_abstract_frontend_interface` depends on this record so that the interface is extracted having seen a Dense and an RTime rule. Expected new modules: Dense.lean, Real.lean and their Plus copies under FormalSystem/Theorems/ProofMode/, FormalSystem/Automation/ProofMode/Frame.lean, FrameTest.lean, guide page frames.md. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: dense and real-time rules. The proof mode's frame-specific rules cover ZTime only. Add rules and tactics exposing DN (`LinearityDerived.density`) at Dense and PU (`prior_U_gap`), SEP (`sep`) and CO (`DedekindDerived.coDerived`) at RTime. DONE WHEN: each has a pure rule and a tactic whose frame certificate (`Dense ≤ fc` / `RTime ≤ fc`) is solved when reflexive and otherwise surfaced as an ordinary Lean goal, with tests at a concrete and at an abstract frame class, in both TM and TM⁺. Source: research/NEW_DIRECTIONS.md, row PM-8. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 950. Proof mode until since intro unfold induction
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 949, Task 987

**Description**: ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under Temporal for introduction and monotonicity, Temporal at ZTime for unfolding and induction; modules Temporal, TemporalZTime and their Plus copies. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. COORDINATION WITH OPEN CONTRIBUTIONS. Three stacked pull requests from a collaborator are open against this area: #7 (logical rewriting `lrewrite` / `lsimp`, the congruence kit), #8 (Until/Since introduction, folding and ZTime unfolding, `linduction`, whole-judgment time reflection, `keeping`, strict leads-to rules) and #9 (a semantic mode, asked to be re-proposed separately). SCOPE IF #8 HAS MERGED: it delivers Until/Since introduction (`untilIntro`, `sinceIntro`), folding at every frame class and unfolding at ZTime (adopt that split in place of the single ZTime equivalence asked for below), and `linduction`, which exposes the backward-induction rule the library already had (`futureBackwardInduction`). What then REMAINS here is: (a) the general introduction form from `untl χ ψ` and `G(χ → φ)`; (b) the induction rule for Until and Since of which `forwardInvariantRule` is an instance, with `linvariant` expressed through it, which backward induction is not; (c) refiling the contributed rules into the family modules; (d) tests for every Since form, TM⁺ and the past direction, which the contribution lacks. SCOPE IF IT HAS NOT MERGED: as written below. MILESTONE M4 (part 2 of 2) (records/proof-mode.md), STREAM: linear time. DEPENDENCIES AS FILED: `proof_mode_linearity_case_tactic`. For introduction and unfolding this edge is sequencing only (both records edit the temporal elaborator and its tests; `left_mono_until_G`, `unfoldForward`, `unfoldBackward` and `unfoldBackwardSince` take no linearity premise). For the induction rule it is undetermined until the plan states the rule's formula: the plan MUST say whether the induction rule uses a linearity case split, which settles open decision 1 of records/proof-mode.md. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: Until/Since introduction, unfolding and induction. Until and Since currently support operand monotonicity only (`luntil`, `lsince`). Constructor arguments are guard first, event second, and the semantics is strict with an open guard. Add three things. (1) Introduction: a rule and tactic proving `untl φ ψ` from `Gφ` and `Fψ` (since `someFuture ψ` is by definition `untl ⊤ ψ`, this is UG, `left_mono_until_G`, at guard ⊤), plus the general form from `untl χ ψ` and `G(χ → φ)`; mirrors for Since. (2) One-step unfolding at ZTime from `DiscreteUnfolding.unfoldForward` / `unfoldBackward` / `unfoldBackwardSince`: `untl g e` iff `X e ∨ X(g ∧ untl g e)`. Those theorems are stated at the fixed class `FrameClass.ZTime` with no `…At` variant, so the pure rules must `.lift` them along a `ZTime ≤ fc` certificate, surfaced as a goal the way `lstep` does. (3) An induction rule for Until/Since at ZTime of which the existing `forwardInvariantRule` (`A → (A → X A) → G(A → X A) → G A`) is the special case; state the rule's formula explicitly in the plan before proving it. DONE WHEN: all three exist for both directions and both languages with pure rules and tests, and `linvariant` is re-expressed through, or proved to be an instance of, the induction rule. Read docs/development/proof-mode-adequacy-perpetuity.md first and follow any adjustment it recommends for this task. Source: research/NEW_DIRECTIONS.md, row PM-7. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 949. Proof mode linearity case tactic
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 947

**Description**: ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under Temporal (pure: a case rule with three premises names no disjunction); modules TemporalLinearity, PlusTemporalLinearity. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. Not covered by pull request #8. MILESTONE M4 (part 1 of 2) (records/proof-mode.md), STREAM: linear time (rule theory, then elaborators). DEPENDENCIES AS FILED: `proof_mode_reprove_perpetuity` with a GO verdict (hard). Runs alongside `proof_mode_dense_and_real_time_rules`, `proof_mode_nested_intro_patterns` and `proof_mode_adoption_after_perpetuity_verdict`, which edit other family files. Expected new modules: Linearity.lean and PlusLinearity.lean under FormalSystem/Theorems/ProofMode/. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: linearity case tactic. Add a tactic that, from two eventualities (F A and F B, or P A and P B) or two Until/Since facts, opens the three ordered cases licensed by TL (`LinearityDerived.tempLinearity` and its past mirror; `temp_linearity` / `temp_linearity_past` are primitive in TM⁺) and CN (`Axiom.linear_until` / `linear_since`). Present the cases in CN's disjunct order: both witnesses together, first witness earlier, second witness earlier. `tempLinearity`'s own disjuncts are in a DIFFERENT order (second earlier `F(Fφ ∧ ψ)`, together `F(φ ∧ ψ)`, first earlier `F(φ ∧ Fψ)`), so the pure rule behind the eventuality form must permute them; do not expose TL's order to the user. DONE WHEN: the tactic works in both time directions and in both TM and TM⁺, with pure rules behind it and acceptance tests for each shape. FIRST read docs/development/proof-mode-adequacy-perpetuity.md; if its verdict is RE-PLAN, stop and report instead of implementing, and otherwise follow any adjustment it recommends for this task. Source: research/NEW_DIRECTIONS.md, row PM-6. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 948. Proof mode reprove temporal slice
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 947, Task 949, Task 950, Task 972

**Description**: REVISED: GATE TWO IS A SWEEP OVER A SELECTION OF LIBRARY ENTRIES (records/theorem-library.md, 'Evaluating the proof mode'; records/proof-mode.md, M5). This supersedes the module location and measurement format in the original description below. SELECTION: theorem entries registered in BimodalLib from TemporalBoolean and the rest of ModalTemporalBoolean, at Base and at ZTime, fixed in the plan before any script is written with a stated reason for each entry, exercising every rule the linear-time records provide; the requirements below still hold (at least four entries registered from each of TemporalDerived.lean, ConnectDerived.lean and LinearityDerived.lean, `tempLinearity`, a US or UF proof, a Since-side mirror), and entries admitted by `theorem_library_tableau_pipeline` are included where they exercise something the hand proofs do not. LOCATION: scripts under BimodalLib/ProofMode/<Fragment>/, each elaborated against the type of its registered statement; nothing is added under FormalSystem/Examples/. RECORDS, OUTCOMES, FAILURE CLASSES and the hand-proofs-only length comparison are as in `proof_mode_reprove_perpetuity`. The sweep is re-runnable by one command, and the first gate's sweep is re-run with it: a fall in coverage on a fragment already swept is reported as a regression. DEPENDENCY ADDED (sequencing): `theorem_library_tableau_pipeline`. MILESTONE M5, GATE TWO (records/proof-mode.md), STREAM: evaluation. DEPENDENCIES AS FILED: `proof_mode_linearity_case_tactic` and `proof_mode_until_since_intro_unfold_induction` (hard: the slice includes a linearity proof and Until proofs), and the first gate. CONSUMERS of the missing-rule list and the rule set as it stands after this report: `proof_mode_abstract_frontend_interface`, `proof_mode_leads_to_invariance_library` and `proof_mode_reference_manual_chapter`. ORIGINAL DESCRIPTION FOLLOWS. Proof mode adequacy test: re-prove a temporal slice. Re-prove a slice of the Burgess-Xu layer in the proof mode, alongside the existing proofs, in a new module FormalSystem/Examples/ProofMode/Temporal.lean. The slice is fixed in advance so it cannot be chosen for ease: at least four declarations from each of FormalSystem/Theorems/TemporalDerived.lean, ConnectDerived.lean and LinearityDerived.lean, including `LinearityDerived.tempLinearity` (a CN-based proof), at least one proof that uses US (`enrichment_until`) or UF (`self_accum_until`), and at least one Since-side mirror. State the chosen list in the plan before proving anything. Scripts may not cite the declaration they re-prove. Write the report to docs/development/proof-mode-adequacy-temporal.md with the same per-declaration measurements as docs/development/proof-mode-adequacy-perpetuity.md and a list of every rule the temporal rule set still lacks. For each missing rule, either add it here (if small) or name it in the report's follow-up section with a proposed task description, so the list has a consumer. DONE WHEN: the module builds and the report exists with its missing-rule list and follow-up section. Source: research/NEW_DIRECTIONS.md, row PM-5. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 947. Proof mode reprove perpetuity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 946, Task 955, Task 961, Task 971, Task 973

**Description**: REVISED: GATE ONE IS A SWEEP OVER A SELECTION OF LIBRARY ENTRIES (records/theorem-library.md, 'Evaluating the proof mode'; records/proof-mode.md, M3). This supersedes the corpus, the module location and the measurement format in the original description below; the GO / RE-PLAN criteria are unchanged. (1) SELECTION: choose theorem entries registered in BimodalLib from the Boolean and ModalBoolean fragments and from the Perpetuity section of ModalTemporalBoolean, the six principles P1-P6 included, and fix the list in the plan before any script is written, with a stated reason for each entry: the rule, tactic or scope it exercises, or that it is a result people need to write. The selection must exercise every rule the scope chain and the leaf closer provide, and must not include an entry that repeats a measurement already taken; it is meant to be small enough to finish and is enlarged later only where a sweep shows something unexercised. (2) LOCATION: scripts live under BimodalLib/ProofMode/<Fragment>/, each elaborated against the TYPE of its registered statement by the pairing command of `theorem_library_layout_and_registry`, without citing the reference proof or any lemma that restates it. Nothing is added under FormalSystem/Examples/. (3) RECORDS: every attempt has a diagnostic record in the schema of `proof_mode_axiom_audit_and_cost_baseline`, with one of four outcomes (closed by the mode's rules alone; with leaf automation; with a term-mode escape; not closed) and, unless the first, one failure class (missing rule, missing tactic for an existing rule, automation too weak, script too awkward, too slow, defect in the mode). (4) LENGTH is compared against HAND proofs only; an entry whose only reference proof is tableau-extracted counts toward coverage and the missing-rule list. (5) The report at docs/development/proof-mode-adequacy-perpetuity.md opens with the verdict, states for each entry what it tests, and ends with the missing-rule list, each item added or named with a proposed description. The sweep is re-runnable by one command. DEPENDENCIES NOW: hard on `theorem_library_layout_and_registry` (the entries and the pairing) and on `proof_mode_axiom_audit_and_cost_baseline` (the records), in addition to the scope chain and the leaf closer. ON GO this also opens `theorem_library_stability_entries`. RULE SET UNDER MEASUREMENT. The gate measures the rules of the scope chain, the leaf closer and the views tier. Whether logical rewriting (pull request #7) and the contributed temporal rules (#8) may be used in the scripts is open decision 5 of records/proof-mode-architecture.md and needs the user's ruling before the plan fixes the allowed rule set; state the ruling at the top of the report. Report scripts' use of each tier separately (views, derivation). MILESTONE M3, GATE ONE (records/proof-mode.md), STREAM: evaluation. DEPENDENCIES AS FILED: `proof_mode_always_sometimes_scopes` and `proof_mode_close_leaves_with_automation` (hard: the gate measures exactly that rule set), and `proof_mode_axiom_audit_and_cost_baseline` (sequencing: quote its cost baseline in the report and re-run its measuring script on the new module). ON GO this opens five records: `proof_mode_linearity_case_tactic`, `proof_mode_dense_and_real_time_rules`, `proof_mode_nested_intro_patterns`, `proof_mode_adoption_after_perpetuity_verdict`, and through them the rest. ON RE-PLAN every one of those is held until its record is revised. ADJACENCY: `publication_examples_and_demo` declares FormalSystem/Examples/ as a directory; neither record presupposes the other. ORIGINAL DESCRIPTION FOLLOWS. Proof mode adequacy test: re-prove Theorems/Perpetuity. The P1-P6 scripts already exist as acceptance tests from the always/sometimes task; this task owns the SUPPORTING LEMMAS, the measurement and the verdict. Re-prove the supporting lemmas of FormalSystem/Theorems/Perpetuity/ (Helpers.lean, Principles.lean, MonotonicityDuality.lean: `boxToFuture`, `boxToPast`, `diamond4`, `modal5`, `boxConjIntro*`, `persistence`, `alwaysMono`, the duality lemmas, `bridge1`/`bridge2`, ...) in the proof mode, and collect them with the P1-P6 scripts in a new module FormalSystem/Examples/ProofMode/Perpetuity.lean, ALONGSIDE the existing proofs (do not delete or replace them; Theorems/ must not import Automation/). The scripts may use only axioms, native constructors, general proof-mode rules and one another; they must not cite the original Perpetuity declarations. Write the report to docs/development/proof-mode-adequacy-perpetuity.md recording, per declaration: non-blank proof lines and tactic/term-step count for the original and for the script, and every rule or tactic found missing or awkward. THIS IS A GATE: the report must open with an explicit GO or RE-PLAN verdict. GO requires the scripts to be shorter in aggregate and for a clear majority of declarations, with no declaration needing a raw term-mode escape longer than its original; otherwise the verdict is RE-PLAN, with a concrete recommendation for how each downstream proof-mode task should change. On RE-PLAN, finish with user review required (requires_user_review) so that no downstream proof-mode task is dispatched on the unrevised plan. DONE WHEN: the module builds and the report with its verdict exists at the stated path. Source: research/NEW_DIRECTIONS.md, row PM-4. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 946. Proof mode always sometimes scopes
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 945, Task 969

**Description**: NO ModalTemporal MODULE OR CLASS (records/proof-mode-architecture.md, Interactions; binding over the text below wherever they differ): every interaction includes Boolean and every class other than Boolean extends Boolean. Rules joining Modal and Temporal, including the scope rules whose statements name no connective, are filed in ModalTemporalBoolean (PlusModalTemporalBoolean for TM+), in its scope-rule section. ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under Temporal for always and sometimes themselves (they join Future and Past and name no modal operator), and Modal-with-Temporal for `□` facts entering an always scope; modules Temporal, PlusTemporal, ModalTemporal, PlusModalTemporal. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. Folding and unfolding always and sometimes is a VIEW and comes from `proof_mode_views_tier`, on which this record now depends; do not add unfolding to these tactics. The `Pφ ∨ φ ∨ Fφ` form of sometimes is a logical equivalence, not a view, and stays a pure rule here. The perpetuity principles as formulas belong to the Modal-with-Temporal-with-Boolean interaction and remain acceptance scripts only. MILESTONE M1 (part 3 of 3) (records/proof-mode.md), STREAM: bimodal scopes. DEPENDENCIES AS FILED: `proof_mode_cross_modal_scopes_mf_tf` (hard). Expected new modules: Perpetual.lean in each ProofMode directory, PlusPerpetual.lean, PerpetualTest.lean, guide page perpetual.md. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: scopes for always and sometimes. Add introduction, use and case rules and tactics for the perpetuity operators, in both TM and TM⁺. `always φ` is DEFINED as `Hφ ∧ (φ ∧ Gφ)`. `sometimes φ` is DEFINED as `¬ always ¬φ` (`φ.neg.always.neg`), NOT as a disjunction: the form `Pφ ∨ φ ∨ Fφ` is a derived equivalence that must be proved as a pure rule before a case rule can use it, and the elaborators' operator matching (`operatorArgs?`) will see `sometimes` as a negation, not as `or`. The deliverable is the general rules plus the P1-P6 scripts as acceptance tests. Integrity constraints, because these scripts feed the adequacy gate that follows: (a) no pure rule may restate one of P1-P6 or exist only to make one of them a one-liner; (b) the scripts may use only axioms, native constructors and general proof-mode rules, and must not cite anything in FormalSystem/Theorems/Perpetuity/. DONE WHEN: each of the perpetuity principles P1-P6 (`perpetuity1` .. `perpetuity6`) is re-derived by a short proof-mode script in the acceptance tests under constraints (a) and (b). Source: research/NEW_DIRECTIONS.md, row PM-3. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 945. Proof mode cross modal scopes mf tf
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 944

**Description**: NO ModalTemporal MODULE OR CLASS (records/proof-mode-architecture.md, Interactions; binding over the text below wherever they differ): every interaction includes Boolean and every class other than Boolean extends Boolean. Rules joining Modal and Temporal, including the scope rules whose statements name no connective, are filed in ModalTemporalBoolean (PlusModalTemporalBoolean for TM+), in its scope-rule section. ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under the Modal-with-Temporal interaction (pure: a `□` fact crossing into a `G` or `H` scope names no implication); modules ModalTemporal, PlusModalTemporal. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. MF and TF enter as rows of the carrying table `proof_mode_s5_aware_box_scopes` establishes, in the same pending shape asked of the temporal contribution there — a `CarryRule` keyed by `(source, target)` with a `framed` flag, not yet confirmed accepted — so this task waits on that one task's table, not on the temporal contribution's merge independently. MILESTONE M1 (part 2 of 3) (records/proof-mode.md), STREAM: bimodal scopes. DEPENDENCIES AS FILED: `proof_mode_s5_aware_box_scopes` (hard: extends the scope rules it adds). FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: cross-modal scopes from MF and TF. Let □ hypotheses cross into temporal scopes. `ltemporal_intro future|past` should accept □ hypotheses and deliver `□A` in the body, justified by MF (`modal_future`, □φ → □Gφ) and the derived TF (□φ → G□φ, `Combinators.temporalFutureDerived`) and their time-reflection mirrors. MF and TF are used nowhere in the proof mode today. The past mirrors and the TM⁺ versions must be derived in FormalSystem/Theorems/ProofMode/ (by `time_reflection`, and by `ofTMSubst` or directly from the TM⁺ axioms); do NOT import FormalSystem/Theorems/Perpetuity/ (`boxToPast`, `boxToBoxPast` and friends are lemmas the Perpetuity adequacy test re-proves). DONE WHEN: `lmodal_intro` composed with temporal scopes derives MF- and TF-shaped goals without leaving the mode, in both time directions and in both TM and TM⁺, with tests including a negative test that a non-□ current fact still cannot cross. Source: research/NEW_DIRECTIONS.md, row PM-2. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 944. Proof mode s5 aware box scopes
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: proof-mode
- **Dependencies**: Task 960

**Description**: FAMILY LAYOUT REVISED (records/proof-mode-architecture.md): `⊡` and its dual `⟐` are filed under the MODAL family beside `□` and `◇`; there is no Stability family and no Stability.lean module. State scope introduction, T, 4, 5 and the diamond rules ONCE over a necessity operator given as a parameter, and instantiate them at `□` and at `⊡`; give each rule in both polarities (`◇` beside `□`, `⟐` beside `⊡`). In each Modal module the rules for `□` alone come first and those naming `⊡` are a section of their own; the rule from a `□`-fact to a `⊡`-fact is a pure Modal rule. A rule that uses `p → ⊡p` is not schematic and says so in its statement. Where the text below says 'filed under Modal and Stability' or names a Stability module, read Modal. The family layout is fixed with `⊡` in Modal; the shared statement is a K core with T, 4 and 5 as further members, and docs/development/stability-operator-family.md gives the grounds. ARCHITECTURE (records/proof-mode-architecture.md): tier Derivation; filed under Modal and Stability (pure); modules Modal, PlusModal, Stability. A rule's statement names only the operators of the family or interaction it is filed under: pure family modules contain no implication, and an interaction with Boolean is its own module. State 4 and 5 as scope-carrying rules at the level of judgments (a `□A` or `◇A` fact enters a `□` scope intact), not as implications. CARRYING MECHANISM: build this on one mechanism shared by every scope, a table saying which fact shape may enter which scope by which rule; `proof_mode_cross_modal_scopes_mf_tf` adds rows to it. The temporal contribution, not yet merged, fixes this table's shape: a `CarryRule` keyed by `(source, target)` — the operator of the fact carried and the scope entered — with the `(TM, TM⁺)` rule pair as its value and a `framed` flag for a row taking a leading `FrameClass.ZTime ≤ fc` certificate, in a module both tactic families import (`Automation/ProofMode/Carrying.lean`, not private). This is a condition of merging the contributor has not yet confirmed accepting. Once that contribution merges, fold its `keeping [...]` clause (which carries `G` and `H` facts by temporal 4) into that one table as its first user, rather than building a parallel path. MILESTONE M1 (part 1 of 3) (records/proof-mode.md), STREAM: bimodal scopes (rule theory, then elaborators). DEPENDENCIES AS FILED: `proof_mode_split_shared_test_and_guide_files` only, for the file layout; no rule dependency. Head of the chain 944 -> 945 -> 946. FILE LAYOUT (binding, set by `proof_mode_split_shared_test_and_guide_files`): acceptance tests live one file per tactic family under Tests/BimodalTest/Automation/ProofMode/ (BasicTest, ModalTest, TemporalTest, DiscreteTest, and one new file per new family), aggregated by Tests/BimodalTest/Automation/ProofModeTest.lean, which only imports them; the guide is docs/user-guide/derivation-proof-mode.md as index plus one page per family under docs/user-guide/proof-mode/. Where the text below names the single test file or the single guide, read it as the family file this record's `file_scope` declares. Put new work in the declared family files; touch a shared file (the aggregators, the index, the two ProofMode READMEs) only for the one import or inventory line the change needs. ORIGINAL DESCRIPTION FOLLOWS. Proof mode: S5-aware box scopes. Extend `lmodal_intro necessity` so a □ scope can carry `□A` into the body as `□A` (via the derived modal 4, `Combinators.modal4`; `modal_4` is a primitive constructor in TM⁺) and `◇A` as `◇A` (via 5, `◇A → □◇A`), alongside the existing rule that strips the operator. Note that the axiom `modal_5_collapse` is `◇□A → □A`, not 5: derive `◇A → □◇A` from it inside FormalSystem/Theorems/ProofMode/ (or reuse a statement from ModalDerived / ModalS5). Do NOT import FormalSystem/Theorems/Perpetuity/ (its `modal5` is one of the lemmas the Perpetuity adequacy test re-proves, so importing it would make that test circular). Do the same for the stability scope `lmodal_intro settled` in TM⁺ using `stab_4` and `stab_5`. At present a scope admits only hypotheses carrying the scope's own operator, stripped of it, so □/◇ facts cannot enter a □ scope intact. Stripping stays the default so existing scripts keep their meaning; carrying is requested explicitly. DONE WHEN: both carrying rules exist as pure rules for TM and TM⁺, the tactic selects between stripping and carrying in a documented way (explicit `using [...]` stays the reusable form), and tests show a □ fact and a ◇ fact used intact inside a □ body while a merely current fact is still rejected. Source: research/NEW_DIRECTIONS.md, row PM-1. The derivation proof mode lives in FormalSystem/Automation/ProofMode/ (elaborators) and FormalSystem/Theorems/ProofMode/ (tactic-independent derivation-producing rules), with acceptance tests in Tests/BimodalTest/Automation/ProofModeTest.lean and the user guide at docs/user-guide/derivation-proof-mode.md. Every tactic must assemble native DerivationTree / PlusDerivationTree constructors and proved rules only; nothing semantic may stand in for a derivation. Add acceptance tests and update the user guide and both ProofMode READMEs for every tactic added or changed. Every new `throwError` path gets a negative test asserting its message (`#guard_msgs`). The existing acceptance tests must keep passing unchanged.

---

### 935. Determinization free progress measure design
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: completeness
- **Dependencies**: None

**Description**: ROUTE R3 -- THE DETERMINIZATION-FREE PROGRESS-MEASURE DESIGN. PAPER RESEARCH ONLY, FILE SCOPE: none, no Lean. Filed on the exact terms the completeness-line reopen decision record sets for this route (specs/archive/926_lean_completeness_line_reopen_decision_record/reports/01_completeness-line-reopen-ruling.md, the Reopening Terms table's R3 row and its recommendation 3), modeled on 879's P9 and on 901's own paper-only posture.

THE QUESTION. Does a determinization-free progress-measure argument for T3 (L-plus ZTime completeness of TM-plus + LC_n + mirror) exist, and what would it need? Deliverable is a VERDICT plus grounds and, on a positive verdict, a DESIGN -- never a theorem and never a Lean declaration.

WHY THIS ROUTE AND NOT THE OTHERS. The determinization obstruction (O1) is `Muller.toRabin_exists`, a `proof_wanted` at Cslib/Computability/Automata/DA/Conversions.lean:112 in the local CSLib fork, whose named consumer is the ban/lull mechanism. R1 -- proving it -- is KEEP CLOSED in this repository, and specifically on the CSLib `require` clause rather than on Recommendation 8's engine-content clause, because a general automata lemma is not sections 7-15 content. "File no task against R1 in this repository" is that record's recommendation 1. A determinization-free progress measure needs no Rabin determinization at all, so it is the one reopened route that bears on the completeness theorem itself while standing clear of both standing rulings.

WHAT A POSITIVE RESULT DOES NOT BUY, STATED UP FRONT. A positive design result does NOT authorize a Lean filing of the design, and this must be written into the report's own framing rather than discovered at its end. The engine-content clause is aimed at the RESULT, not at the lemmas used to reach it: a different construction reaching the same completeness result still trips it. Any Lean filing of whatever this task designs requires a separate, explicit Recommendation 8 reversal by the user, win or lose on the paper design.

DO NOT RE-DERIVE OR RE-MEASURE. (1) The determinization costing is settled: the construction of record is the APPEARANCE-RECORD (LAR) route, Thomas 1997 section 6.1 Theorem 6.5 with Remark 6.6 -- not Safra's and not Piterman's -- on the ground that the lemma's input `a : Muller State Symbol` is ALREADY deterministic, so no determinization construction is removing nondeterminism; the archived Safra/Piterman attribution is a misattribution as to this lemma, accurate only about the composite NBA-to-DRA step. Costed at roughly 1,000 lines over 4-7 phases. If a figure is ever needed, re-cost against those rather than re-measuring from scratch. (2) The acceptance-condition split is settled: a deterministic Muller automaton suffices for the Auxiliary-Atoms rule, which carries no acceptance condition, and does NOT suffice for the ban/lull mechanism, whose banned list is indexed by the automaton's accepting pairs and does not present as a Muller family without a walk-dependent choice only an LAR can make. (3) The architecture of record for the two-sided engine, including the level split, the eliminated cross-certification clauses, the chronicle seed lemma and the four-link Step 3-prime, is already written as a paper proof and is read, not re-derived.

WHERE THE PROGRESS MEASURE WOULD HAVE TO BITE. The ban/lull mechanism is the sole named consumer of the pair-indexed acceptance condition, so it is the component a progress measure must replace. Address, at minimum: what well-founded quantity decreases along a chronicle in place of the banned list; whether it can be read from the hue/type data the alphabet already carries, or demands new syntax the Auxiliary-Atoms rule's freshness side condition would have to admit; whether it survives the two-sidedness, where forward badness is prefix-invariant and backward badness is not; and whether the clock rule's canonical cut still supplies the anchor the level split relies on.

PROHIBITIONS, RULING-LEVEL AND NOT PREFERENCES. (a) NO Lean file is written, edited or filed, under any outcome. Sections 7-15 of the Reynolds engine -- the two-sided chronicle, ban preservation, lulls and hue scheduling, universal non-acceptance, the two-sided truth lemma, the final-frame assembly -- stay barred from any Lean filing under every reopened route, this one included. (b) NO `require` of CSLib in either form; no lakefile.toml edit, no lake-manifest.json edit; the `require` question is not re-opened on this route's account. (c) NO task is filed against R1, and no attempt is made on `Muller.toRabin_exists`, in this repository. (d) NO edit, commit or push in the CSLib fork at /home/benjamin/Projects/cslib. (e) NO upstream PR. (f) Do NOT amend specs/ROADMAP.md's existing Recommendation 8 sentence: the reopen record's recommendation 5 rules explicitly that no amendment is needed, because that sentence's truth is unchanged -- the ruling settles only which parts of each route are reachable without reversing it. (g) The assessment of why the chronicle quotient's OWN Saturation is doubtful -- countably infinite slices, the quotient is not an oriented forest -- is CORRECT and LOAD-BEARING, the reason the universal-cover route exists at all; it is read as a premise, not revisited. (h) No completeness claim lands from this task.

CONFLICT AVOIDANCE, STRUCTURAL RATHER THAN NEGOTIATED. FILE SCOPE is none: this task writes its own specs/ artifacts and touches nothing under FormalSystem/, Tests/, docs/, typst/ or any shared library file, so it collides with no live task's territory by construction -- not with the ladder-realization line, not with the final-frame tasks carrying R2, not with the algebraic chain. It also files nothing, so it cannot contend for a task number or a ruling with any sibling.

CONTINGENCY. A negative verdict is a COMPLETE outcome, not a failure: if no determinization-free progress measure is available, or one is available only at a cost exceeding the LAR route's own, record that with its grounds and with what the obstruction actually is. Either verdict leaves the CSLib `require` decision and Recommendation 8 exactly where they stand; neither is reversed, weakened or re-opened by this task's result.

---

### 932. Land the four ofStepRel constraint lemmas and an ofStepPlain constructor in IntNormalForm.lean
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: Task 869

**Description**: FRAME-PRESENTATION API ONLY. Land five declarations in FormalSystem/Semantics/IntNormalForm.lean, plus one equation lemma, and rewrite `ofStepSat`'s body to cite them instead of duplicating them.

THE DECLARATIONS. `ofStepRel_reflective`, `ofStepRel_compositional`, `ofStepRel_serial`, `ofStepRel_limit`, the `ofStepPlain` constructor, and the `ofStepPlain_taskRel` equation. Their statements and compiled proof bodies are transcribed VERBATIM in specs/927_final_frame_step_remeasure_against_landed_cover/reports/01_final-frame-step-remeasure.md, Appendix probe A. Cite them from there; do not restate or re-derive them here. All six elaborated sorry-free through `lean_run_code`, and the downstream composition reports axiom profile [propext, Classical.choice, Quot.sound].

WHY THIS IS A REFACTOR, NOT NEW MATHEMATICS. The four constraint proofs ALREADY EXIST in the library as inline lambdas inside `FrameOver.ofStepSat` (IntNormalForm.lean:563 at measurement time). This task names them. `ofStepSat` then becomes `ofStepPlain` wrapped by `ofReflectiveRegular`, so no existing signature changes and no proof body is duplicated -- which is the point: a duplicated transcription can diverge, a citation cannot.

THE IDIOM TO USE. The remeasurement report's Tactic Survey isolates it: prove each constraint as a BARE-RELATION lemma and transport with `|>`, never by rewriting a frame's `TaskRel` in place. Rewriting in place does not go through.

THIS FORMALIZES NO PART OF SECTIONS 7-15. It is frame-presentation API in IntNormalForm.lean. It formalizes no chronicle, no hue, no ban, no lull and no truth lemma. The 901 report's Recommendation 8, which bars formalizing sections 7-15 of the Reynolds engine paper proof, is UNTOUCHED by this task and must stay untouched. Landing these lemmas does not make T3 complete and is not a completeness claim; it discharges the single named condition the remeasurement report's Finding (4) attaches to its `conditionally discharged` verdict.

COUPLED GENERATED SURFACES -- inherited at filing time, not to be discovered at the first commit. A Lean line-count change moves two generated surfaces. (1) `typst/generated/status.typ` carries `formalsystem-line-count` and its check is PRE-COMMIT BLOCKING: regenerate via `bash .claude/scripts/typst-sync-check.sh --fix` in the SAME phase as the line-count change, not in a later reconciliation phase. (2) The module-inventory blocks in `README.md` and `FormalSystem/Metalogic/README.md` are checked later and may be deferred to a reconciliation phase: regenerate via `bash .claude/scripts/check-module-invariants.sh --emit-inventory`. All three are in this task's file_scope for that reason.

---

### 890. Ghr lemma 10 2 3 case5 erratum reference manual
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: typst
- **Topic**: metalogic
- **Dependencies**: None
- **Parent**: Task 867

**Description**: Record the GHR94 Lemma 10.2.3 Case 5 erratum in the Typst reference manual.

GHR94's printed Case 5 formula for Lemma 10.2.3 is refuted over integer time by an explicit counterexample: a(0), A(1), B identically false, q(1)=q(2). The LHS is true at t=3 while the RHS is false, because both printed disjuncts carry the conjunct [A or (B and U(A,B))] evaluated at t. The refutation was verified against the ch10 PDF layout, not only the markdown chunk -- the PDF carries the same conjunct on the second disjunct, so the defect is in the printed source and not an artifact of conversion.

The corrected rederivation is already landed in Lean. What is missing is the durable write-up: the erratum and its counterexample currently exist only in a task artifact under specs/, which is not where this repository keeps its account of the GHR material. The reference manual is.

Scope: state the printed formula, state the counterexample with its valuation, show which conjunct fails and why integer time (as against the dense time GHR assume) is what exposes it, and point at the landed corrected form. No Lean work -- the mathematics is done.

Evidence: originating issue entry iss_1793912463353_yZ5rLd, recorded during the formalization of GHR separation over Z-time.

---

### 876. Open language stability primitive removal
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: Task 856, Task 873

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise. SCOPE REVISED: DECISION RECORD ONLY. No removal is to be attempted, and no constructor of `OpenFormula` is to be deleted or re-expressed as notation: the stability modal stays primitive in both L-plus and L^▷. The deliverable is the Phase 1 gate alone, as a report: (1) whether any live consumer evaluates the stability modal off the regular class, where the backward half of the definability biconditional fails; (2) what losing state-locality would cost the decidability front and the atomization route; (3) a verdict on whether removal would be sound relative to this tree, recorded for a future ruling and not acted on. Every sentence below that names removal as a deliverable is superseded by this paragraph. Dependencies are reduced to the L^▷ proof-system task alone.

IMPLEMENTATION TASK WITH A DECISION GATE IN PHASE 1, and the gate is the point: remove the stability modal from `OpenFormula`'s primitive constructors, replacing it with notation for the open-past-of-open-future composite, OR record with compiled evidence why it cannot be removed. Entering this task committed to removal is the way to get it wrong; the removal is desired and must be attempted, but two specific obstructions are on record and the task is accountable to them.

THE REQUEST. The stability modal is definable in L^▷ -- the biconditional is landed, in both associations -- so carrying it as a tenth primitive constructor is redundant, and the maintainer's standing preference is that it go. This task owns that removal.

THE TWO OBSTRUCTIONS, BOTH ON RECORD AND NEITHER A GUESS. Read both before planning.
(1) THE BICONDITIONAL IS CLASS-RESTRICTED. The forward half holds on every regular task frame; the backward half needs `[F.IsRegular]`. So a syntactic abbreviation does not preserve the stability modal's truth conditions off the regular class -- it changes the language's meaning on exactly the frames where the two differ. Establish FIRST, as Phase 1's deliverable, whether any live consumer evaluates the stability modal off the regular class. If none does, removal is sound relative to this tree and the restriction is a documented precondition rather than a blocker. If one does, removal is refused on this ground and the task's outcome is that finding.
(2) STATE-LOCALITY IS LOST. The decidability front's one working anchor for the stability modal is that it is state-local -- one bit per cell, `stab_mem_tpOf_iff_cell` resting on `stab_state_only`. The open-future and open-past modals are not state-local; they quantify over agreement classes through the time of evaluation. Routing the stability modal through them discards that anchor. Phase 1 must measure what actually depends on it: enumerate the consumers of `stab_state_only`, `stab_mem_tpOf_iff_cell` and the cell-level stability reasoning, and say for each whether it is reachable from `OpenFormula` at all or lives purely on the other language's side of the embedding. The two languages are separate inductives, so a consumer that only ever sees the other language's stability constructor is NOT affected by removing this one -- establishing that is the cheapest possible route to a clean removal, and it may well be the actual situation. Do not assume it; measure it.

WHAT REMOVAL MEANS IF PHASE 1 CLEARS IT. Delete the stability constructor from `OpenFormula`; introduce the stability modal as notation or an abbreviation over the open-past and open-future composite; re-derive every landed stability result at `OpenFormula` from the composite form, including the pointwise S5 laws, the strength ordering, the reversal transport (the reflection operation fixes the stability modal and exchanges the two open modals, so the reflection arms change shape and must be re-proved rather than re-cited), and the stability arms of the truth recursion, the axiom type, the derivation tree and the soundness recursion. Both conservativity directions over the other language must be re-stated, since the embedding's stability clause is exactly what changes. The regularity precondition goes in the docstring of every result that now needs it, and in the theorem-index row's frame-class column.

ORDERING, AND IT IS A HARD GATE. This task must run AFTER the L^▷ proof system, the L^▷ substitution closure and the L^▷ incompleteness transfer have landed, and BEFORE the display-name rename. Rationale: each of those three lands new declarations that pattern-match on `OpenFormula`'s constructors, so removing a constructor first would force them to be written twice; and the rename should operate on a language whose constructor set is final. Declare all three as dependencies.

EXPLICITLY NOT IN SCOPE. Do not touch the other language's own stability constructor, its axiom type or its derivation tree -- the standing ruling against mutating those inductives is unaffected by this task and the landed incompleteness and independence results depend on them unchanged. No completeness claim. No decidability claim. Do not weaken a landed result to a regular-class-only form in order to make removal go through without saying so: any result whose frame class narrows is a recorded consequence of this task, listed in the summary, not a silent edit.

THE HONEST OUTCOMES, and all three are complete. (a) Removal lands, with the regularity precondition documented. (b) Removal is refused on obstruction (1) or (2), with the blocking consumer named and compiled evidence recorded under the evidence-probe convention. (c) Removal lands at the regular class only, with the off-regular behaviour change stated explicitly in the module docstring and the theorem-index rows. A refusal with a named cause is a complete outcome and must not be reported as a failure.

LAYERING AND GATES. Add any new file's row to the layer table in `scripts/measure-refactor-partitions.py` in the same phase as the file or the cycle checker FAILS naming it. One theorem-index row per changed result, with the frame class explicit -- a result whose class narrows and whose row does not say so is a defect. Re-run the module-invariants emitter rather than hand-editing a README inventory block.

VERIFICATION GATE. Guarded scoped build green, then the unscoped build; never bare `lake`. Zero `sorry`, zero vacuous definitions. The bare module-invariants check and the metalogic-cycles check both green. Axiom sets measured per declaration and diffed against the pre-removal baseline, captured in Phase 1 before any edit: the composite form routes through two operators whose own proofs may carry choice where the primitive's did not, and a widened axiom set is a recorded cost of this task, not a new baseline.

---

### 875. Open language incompleteness transfer
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 856, Task 871, Task 873

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise.

IMPLEMENTATION TASK, gated on the L^▷ proof system and its conservativity directions: transfer the landed L-plus incompleteness results to L^▷, and state the limit-closure schema in L^▷ form at the frame classes where the L-plus translation does not reach.

THE GAP, VERIFIED AT FILING. `plus_incomplete_base`, `not_plus_complete_base` and `blc_not_plusDerivable_base` are landed and cited from `FormalSystem/Metalogic.lean` and `FormalSystem/Metalogic/Independence.lean`. A tree-wide grep for an L^▷ counterpart (`open_incomplete`, `not_open_complete`) returns nothing, and no task in `specs/state.json` names one. The L^▷ proof-system task states in its own description that `plus_incomplete_base` "stands exactly as proved", that `blc` "stays a non-theorem", and that "an LC_n-style schema is still required in L^▷ exactly as in L-plus" -- it flags both items and scopes neither. Nobody owns them.

WHY THE TRANSFER IS AVAILABLE RATHER THAN OPEN. This is a corollary task, not a research task. The L^▷ proof-system work delivers conservativity over TM-plus in both directions; with both directions in hand, incompleteness transfers by composition: a formula valid at Base but not L-plus-derivable has an `ofPlus` image valid at Base (semantic conservativity, landed in `OpenValidity.lean`) whose L^▷-derivability would, by backward conservativity, give the L-plus derivation that does not exist. Write it in that shape -- as the composition of named landed results -- and do not reprove any underivability.

WHAT TO STATE. (1) The L^▷ incompleteness triple at Base: the `ofPlus`-image of the limit-closure countermodel formula is Base-valid and not L^▷-derivable, hence the L^▷ system is incomplete at Base. (2) The honest scope line: this says the particular L^▷ system is incomplete, not that no recursive axiomatization exists -- that question is open at every class for L-plus too and must not be overstated here. (3) The limit-closure schema in L^▷ form, at Base and Dense. At ZTime the translation already answers it, because `openValidIn_ztime_iff_tr` makes any L^▷ validity question at ZTime an L-plus question; at Base and Dense the open-future modal is a genuine expressive extension, the translation is unavailable, and the schema must be stated natively over `OpenFormula`. Cite the landed L-plus schema rather than re-deriving it: `PlusLanguage/PlusLCSchema.lean` and `PlusLanguage/PlusLimitClosure.lean`.

DEPENDENCIES, BOTH HARD. The L^▷ proof-system task (for `OpenDerivable` and both conservativity directions) and the corrective limit-closure repair task (which fixes the `PlusLCSchema` docstring and the `omega_chain` parameter this task would otherwise cite in its broken form). Do not enter before both land.

EXPLICITLY NOT IN SCOPE, each being a way to get this wrong. No positive completeness claim for L^▷ at any class, conditional or otherwise. No claim that no recursive axiomatization of L^▷ exists -- that is strictly stronger than incompleteness of one system and is not established for L-plus either. No new constructor anywhere, and no change to the landed L-plus underivability proofs: they are cited, never edited. Do not route the transfer through the ZTime translation at Base or Dense, where it does not apply.

LAYERING AND GATES. This is metalogic-layer work and belongs under `FormalSystem/Metalogic/`, beside the existing Independence block, not inside `OpenLanguage/`. Add any new file's row to the layer table in `scripts/measure-refactor-partitions.py` in the same phase as the file. One `docs/theorem-index.md` row per result, with the frame class stated explicitly -- a Base-only result recorded without its class is a defect. Re-run `bash scripts/check-module-invariants.sh --emit-inventory`.

VERIFICATION GATE. Guarded scoped build green, then the unscoped build; never bare `lake`. Zero `sorry`. `bash scripts/check-module-invariants.sh` (bare form) and `bash scripts/check-metalogic-cycles.sh` both green. Axiom sets measured per declaration and compared against the L-plus originals: the landed underivability results pin their own axiom sets and the transfer must not widen them.

---

### 874. Open language substitution closure
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: Task 856, Task 873

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise. RATIONALE CORRECTION: the paragraph below headed WHY IT MATTERS FOR THE END STATE is superseded. L-plus is not to be made dispensable. The value of this task is that L^▷ gains its own substitution closure and a direct embedding of L, as properties of L^▷ worth having on record.

IMPLEMENTATION TASK, gated on the L^▷ proof system: build `FormalSystem/OpenLanguage/Substitution.lean`, the L^▷ counterpart of `FormalSystem/PlusLanguage/Substitution.lean`. This is the substitution-closure half of the L^▷ proof system and it also lands the direct L-to-L^▷ embedding, which the tree currently reaches only by composing two maps.

THE GAP, VERIFIED AT FILING. `FormalSystem/OpenLanguage/` has no `Substitution.lean`; `OpenAxioms.lean` contains zero occurrences of "subst" and `OpenDerivation.lean` one. A tree-wide grep for `substOpen` returns nothing and no task names it. By contrast `PlusLanguage/Substitution.lean` carries `substPlus : (Atom -> PlusFormula) -> Formula -> PlusFormula`, `substCtxPlus`, `substPlus_atom` (which identifies the atom-substitution with `ofFormula`, making the base-language embedding a corollary rather than a separate definition), `substPlus_reflectTime`, `PlusAxiom.ofTMSubst`, `PlusAxiom.minFrameClass_ofTMSubst`, `PlusDerivationTree.ofTMSubst`, `plusDerivable_substPlus` and `plusDerivable_substPlus_nil`. None of this exists at L^▷.

WHY IT MATTERS FOR THE END STATE. `substPlus_atom : substPlus PlusFormula.atom phi = ofFormula phi` is the statement that makes L-plus a genuine extension of L's proof system rather than a parallel one: every TM axiom lifts to a TM-plus axiom under substitution, and every TM derivation lifts to a TM-plus derivation. Without the L^▷ mirror, L^▷ inherits L's proof system only through L-plus, so L-plus is load-bearing in the chain and cannot become internal. The mirror `substOpen_atom : substOpen OpenFormula.atom phi = ofFormula' phi` is the direct L-to-L^▷ embedding, and it is the structural step that leaves L and L^▷ as the two languages a reader needs.

WHAT TO BUILD, mirroring the L-plus file declaration for declaration. `substOpen : (Atom -> OpenFormula) -> Formula -> OpenFormula`; `substCtxOpen`; `substOpen_atom` together with whatever direct embedding `Formula -> OpenFormula` it identifies (introduce it in `Formula.lean` if it is not already there, and prove it equal to `ofPlus (ofFormula .)` so the two routes into L^▷ are provably the same map -- that equation is a deliverable, not an aside); `substOpen_reflectTime`, cheap because `reflectTime` fixes box and stab and exchanges ofut with opast (`OpenReversal.lean`); `OpenAxiom.ofTMSubst` with its `minFrameClass` companion; `OpenDerivationTree.ofTMSubst`; `openDerivable_substOpen` and its empty-context form.

DEPENDENCY, AND IT IS A HARD GATE. `OpenAxiom` and `OpenDerivationTree` must exist before `OpenAxiom.ofTMSubst` and `OpenDerivationTree.ofTMSubst` can be stated. Declare the L^▷ proof-system task as a dependency and do not enter this one before it lands. The `substOpen`/`substOpen_atom`/embedding-agreement part is pure syntax and could in principle be split out ahead of the gate; if the proof-system task is still open when this is dispatched, land the syntax half and record the axiom/derivation half as a reasoned exclusion rather than blocking.

EXPLICITLY NOT IN SCOPE. No completeness claim. No new constructor on `OpenFormula`, `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`. Do not define stab away as ofut-opast: it stays primitive, since the backward half of that biconditional needs `[F.IsRegular]`. Do not alter `substPlus` or anything under `PlusLanguage/` -- this task adds the L^▷ mirror and touches the L-plus original only to cite it.

LAYERING AND GATES. Syntax layer: no import from `FormalSystem/Semantics/` and no semantic module of any language. Add the new file's row to the `LANGUAGE_FILE_LAYERS` table in `scripts/measure-refactor-partitions.py` in the same phase as the file or `scripts/check-metalogic-cycles.sh` FAILS naming it. One `docs/theorem-index.md` row per result; re-run `bash scripts/check-module-invariants.sh --emit-inventory` rather than hand-editing the README inventory block.

VERIFICATION GATE. Guarded scoped build of `FormalSystem.OpenLanguage` green, then the unscoped build; never bare `lake`. Zero `sorry`, zero vacuous definitions. `bash scripts/check-module-invariants.sh` (bare form) and `bash scripts/check-metalogic-cycles.sh` both green. Axiom sets measured per declaration and compared against the L-plus originals being mirrored.

---

### 873. Open language subformula closure
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: syntax
- **Dependencies**: Task 869

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise.

IMPLEMENTATION TASK, small and fully templated: build `FormalSystem/OpenLanguage/Subformulas.lean`, the L^▷ counterpart of `FormalSystem/PlusLanguage/Subformulas.lean`. This is pure syntax, gated on nothing, and it is the one piece of L^▷ infrastructure that any native decision procedure over `OpenFormula` needs before it can be stated at all.

THE GAP, VERIFIED AT FILING. `FormalSystem/OpenLanguage/` holds nine files and no `Subformulas.lean`. A tree-wide grep for `openSubformulas`, `subformulasOpen`, `openSubformulaClosure` and `openComplexity` returns nothing, and no task in `specs/state.json` names any of them in a description or a `file_scope`. By contrast `PlusLanguage/Subformulas.lean` is 373 lines carrying `subformulas`, the per-constructor membership lemmas, `subformulas_trans`, `plusSubformulaClosure` as a `Finset`, `self_mem_plusSubformulaClosure`, the `decidableMemPlusSubformulaClosure` instance and the `plusClosure_*` closure lemmas one per constructor. L^▷ has none of it.

WHAT TO BUILD, mirroring that file constructor for constructor. `subformulas : OpenFormula -> List OpenFormula` over all nine constructors; the membership lemmas (`self_mem_subformulas`, `imp_left`/`imp_right`, `box_inner`, `untl_left`/`untl_right`, `snce_left`/`snce_right`, `stab_inner`, and the two new arms `ofut_inner_mem_subformulas` and `opast_inner_mem_subformulas`); transitivity; `openSubformulaClosure` as a `Finset OpenFormula` with its self-membership, its decidable-membership instance and one `openClosure_*` lemma per constructor. `OpenFormula` must have `DecidableEq` for the `Finset` layer -- check whether `Formula.lean` already derives it and derive it there if not, in the same phase.

THE AGREEMENT LEMMA THAT MAKES THIS A TRANSFER AND NOT A DUPLICATE. State `subformulas_ofPlus`: the subformulas of `ofPlus phi` are the `ofPlus`-images of the subformulas of `phi`, and the closure analogue. This is what lets a result proved by induction on L-plus subformula closure be re-read at L^▷ instead of re-proved, and it is the reason this file belongs to the transfer programme rather than being incidental library padding. Expect it to hold by `rfl` or a short induction, since `ofPlus` is constructor-to-constructor and every derived operator shares its `PlusFormula` namesake's right-hand side.

EXPLICITLY NOT IN SCOPE. No decision procedure, no decidability claim, no engine change. `clSig`, `LocalRun` and `Anchored` get no `ofut`/`opast` clause from this task -- the standing containment ruling keeps the L-plus decidability engine's own definitions untouched, and this task supplies a syntactic closure over `OpenFormula` that no existing engine consumes yet. Add no constructor to `OpenFormula`, `PlusFormula`, `PlusAxiom` or `PlusDerivationTree`.

LAYERING AND GATES. This is a syntax-layer file: it imports nothing from `FormalSystem/Semantics/` and no semantic module of any language. `scripts/check-metalogic-cycles.sh` enforces that edge and reads each file's layer from the per-file `LANGUAGE_FILE_LAYERS` table in `scripts/measure-refactor-partitions.py` -- add the row for the new file in the same phase as the file, or the gate FAILS naming it. Every result needs a `docs/theorem-index.md` row: statement, fully-qualified Lean name, file, frame class, pinned axiom set. The README inventory block is generated, not hand-edited: re-run `bash scripts/check-module-invariants.sh --emit-inventory`.

VERIFICATION GATE. Guarded scoped build of `FormalSystem.OpenLanguage` green, then the unscoped build; never bare `lake`. Zero `sorry`, zero vacuous definitions. `bash scripts/check-module-invariants.sh` (bare form) and `bash scripts/check-metalogic-cycles.sh` both green. Axiom sets measured per declaration; the L-plus original is choice-free, so picking up `Classical.choice` here is a regression rather than a new baseline.

---

### 869. Open modal invariance ray agreement lifting
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: semantics
- **Dependencies**: Task 743, Task 898, Task 962

**Description**: PRIORITY RULING (2026-11-05, user): DEMOTED. The aim of the repository is now completeness and decidability of the stability-modal language L-plus; L^▷ is a secondary line of investigation, kept and not abandoned. This task belongs to the L^▷ exploration stage of specs/ROADMAP.md, off both critical paths: do not dispatch it ahead of, or batch it with, L-plus critical-path work. Its content below stands except where this paragraph says otherwise.

IMPLEMENTATION TASK, small and self-contained: state and prove truth invariance for the open-future and open-past modals along a history morphism that lifts ray agreement, and derive such a lifting at ZTime from TwoWayBounded. This is the one formalization item recommended by the MSO-route research; it is independent of every unverified step in that route.

WHY THIS EXISTS, AND WHAT IT IS NOT. The MSO route argues on paper that ZTime validity of the open language is decidable, and the open modals were confirmed to ride step 4's encoding -- see specs/866_mso_route_open_modals_ztime_decidability/reports/01_mso-route-open-modals.md, recommendation R1. That route is NOT being formalized and is not to be: Mathlib has no MSO syntax, no omega-automata, no determinization, and no Rabin tree theorem, so step 5 would mean a multi-year project of a different kind. This task lands only the semantic invariance lemma the route's cover step needs, which is useful on its own terms wherever open-modal truth must be transported along a morphism. Claim no decidability result and no completeness result here.

WHAT TO STATE. Three pieces, in this order:

(1) A ray-agreement lifting hypothesis beside HistMap.lift in FormalSystem/Semantics/HistoryMorphism.lean, as a standalone hypothesis or a new field: a history of the image frame agreeing with the image of tau' up to x lifts to a history of the source agreeing with tau' up to x. Then its time-reflected mirror for the open-past modal. Note that HistoryMorphism.lean's own docstring already records that HistMap.lift is derivable from TwoWayBounded.step rather than primitive, and that step is strictly weaker than lift -- read that discussion before choosing between a field and a hypothesis, and record the choice.

(2) The ZTime derivation of both from TwoWayBounded.step/forth via the existing forward/backward sequence machinery in the same module. The research notes the lifted witness reuses the given history's past verbatim and needs only forward lifting from the basepoint at x, which is strictly weaker than the two-sided HistMap.lift that plus_invariance's stab case already uses -- so this should be easier than the landed two-sided case, not harder.

(3) An open_invariance theorem over OpenFormula, reusing plus_invariance's seven cases. OpenLanguage sits above Semantics (OpenTruth.lean imports Semantics.Truth; nothing under Semantics/ imports OpenLanguage), so a new FormalSystem/OpenLanguage/OpenInvariance.lean can import HistoryMorphism -- confirm the aggregator wiring in FormalSystem/OpenLanguage.lean, and confirm the layering still holds before committing to the module site.

SIZE: estimated 150-350 lines, one implementation phase. Independent of Gabbay separation (no SeparationOver hypothesis is needed), of the ladder/RaySummary front, and of the two gaps the MSO research located in report 03 section 1.3 (the step-1 fixpoint circularity and the step-3 forest-versus-tree mismatch). Nothing gates it.

GATES. Zero sorry, zero vacuous definitions. A docs/theorem-index.md row per landed result, with Paper: and a reason at the declaration or C15's second assertion fails. Re-measured axiom baselines pinned by scripts/check-module-invariants.sh, never typed by hand. Guarded scoped build green, then the unscoped build; check-module-invariants.sh and check-metalogic-cycles.sh both green against their pre-task baselines.

TWO KNOWN ENVIRONMENT FACTS, so they are not rediscovered. First, any task adding .lean lines in this repository must regenerate three files that a phase file list will not obviously name: the BEGIN GENERATED inventory blocks in README.md and the relevant FormalSystem README, via check-module-invariants.sh --emit-inventory, and typst/generated/status.typ via typst-sync-check.sh --fix, which a pre-commit hook enforces. They are in this task's file_scope for that reason. Second, check-module-invariants.sh's C16 group currently reports one pre-existing unusedArguments finding at FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136, last touched by an unrelated commit; it is not this task's to fix, and "green against pre-task baselines" means that finding and no other. scripts/check-paper-definitions.sh likewise exits 1 on manuscript drift outside this repository.

NAMING CONSTRAINT, which has already cost one round elsewhere: gate C26 and C16's defsWithUnderscore linter both reject a snake_case def or abbrev name in the live tree. Decidable-valued and other defs are camelCase; theorems keep snake_case. Name accordingly when writing the plan's challenge statements, not afterwards.

---

### 831. Dense time certificate dichotomy gate
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: RESEARCH TASK, verdict-first. State and attempt the logic-level dichotomy that gates the dense-time certificate route (L-R3).

CLASSIFICATION: RESEARCH, not implementation. The deliverable is a verdict plus grounds, not a landed theorem. Do not re-describe this as engineering, and do not budget it as a routine task.

WHY IT MATTERS. Every landed and in-flight decidability result in this tree is ZTime-shaped. L-R3 is the ONLY identified non-spine route to Base/Dense/RTime. The review `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` marks L-R3 "NEW, UNFILED"; this record is what makes that reference resolve.

STANDING INSTRUCTION -- RE-VERIFY BEFORE CITING. Re-read the followup-scope-spec and re-grep before citing any name below. The spec lives under `specs/archive/`; confirm the path still resolves before quoting it.

THE GATE, VERIFIED AT FILING (2026-11-02). L-R3 is blocked on a logic-level dichotomy of the shape

    Log(all) = Log(ZTime) INTERSECT Log(Dense)

and NO Lean declaration states it -- confirmed by grep over `FormalSystem/` at filing time. Re-confirm that absence before writing anything, and if a declaration has since appeared, say so and stop: the premise of this task would then be stale.

CHEAPEST HONEST FIRST INCREMENT. State the dichotomy as a Lean proposition and attempt it. A refutation is a complete outcome; so is a verdict that it is open with the obstruction named. What is NOT acceptable is a plan that assumes the dichotomy and builds the certificate class on top of it -- that is the shape this record exists to prevent.

RELATION TO THE TABLEAU SPINE. This is deliberately OFF the spine (428 / 429 / 430 / 412 / 482). 430's own record states the spine is no longer the critical path to a first decidability result, and 429 and 482 are both flagged open mathematics, multi-month. Do not fold this into any of them, and do not schedule it as a substitute for ROADMAP Stage 1 (`/orchestrate 761 --hard --lit`), which it does not advance.

ACCEPTANCE. A report recording (a) the dichotomy as stated in Lean, (b) the attempt and its outcome -- proved, refuted, or open with the obstruction named -- and (c) a verdict on whether L-R3 is worth filing as an implementation front at all. No Lean needs to land beyond the statement itself and whatever the attempt produces.

FILE SCOPE: research-only; no committed Lean required beyond a probe. Any probe goes under this task's own `specs/` directory, not into `FormalSystem/`.

PROVENANCE: `specs/reviews/review-2026-11-02.md`, Medium Priority Issues section.

---

### 763. Ladder lift decidability corollary
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 761, Task 762

**Description**: AMENDED 2026-10-11 (index deletion): the finite cell index this record assembled its object from is refuted and deleted below; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.

STATEMENT (library, research-first; new module `RaySummary/Lift.lean`). The (W) row's lift from one seam to validity — "one presentation-level object witnesses ¬ PlusValidZTime φ for some regular ℤ-model, history and time" — and obligation (3)'s second half ("every seam but the one"):
  `theorem not_plusValidZTime_iff_ladderRefutes (φ : PlusFormula) : ¬ PlusValidZTime φ ↔ ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab) (step) (pend) (fwd : ∀ t x, ∃ y, RladAdm step pend t x y) (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x), Fintype.card Q ≤ objBound φ ∧ LadderCons φ lab step pend ∧ LadderRefutes φ lab step pend` (`Adm` is a CARRIER restriction defined in `RaySummary/LadderModel.lean` — `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` — not an object-side hypothesis; the object ranges over the admissible carrier, with its seriality `fwd`/`bwd` stated over `RladAdm` on that carrier)
(→), completeness: a refuting regular ℤ-model has cells bounded by `anchorCells_ncard_le`, per-cell presentations by (C)'s general row (`exists_hitPresented`) — and the step from finitely many CELLS to finitely many ladder STATES per cell has NO support: `ladderCell_stabilizes` is REFUTED for every bound (`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`; the gap n − c is observable) and is DELETED from this assembly. How a refuting model's finitely many cells (`anchorCells_finite`, `anchorCells_ncard_le`, untouched) are assembled into ONE finite ladder object — a computable index of WHICH cell a ladder state has — is an OPEN SUB-PROBLEM of this record: recorded here, not solved, and never re-stated over a concrete substitute (the candidate carrying a clipped gap coordinate is research-level and unproved). (←), soundness: `ladderRealized` at the refuting cell gives a regular ℤ-model (`ladderFrameAdm_isRegular`, the frame on the admissible carrier; `ladderFrame` has no instances, `no_fwd`/`no_bwd_of_idle`), a history and a time where φ fails. Depth k = 1 throughout.

THE COROLLARY — THE AIM — IS STATED HERE AND NOWHERE EARLIER: `Decidable (PlusValidZTime φ)` by bounded enumeration over objects of size ≤ objBound φ (finitely many on `Fin n`; `LadderCons`/`LadderRefutes` decidable on a Fintype, as `decidableAnchorConsFin` already is on a concrete finite object). `Decidable (PlusValidZTime` has zero statement-level occurrences in the tree today (14 hits, all prose denials); no predecessor record may state it.

STATUS. Not costable until both predecessors have landed shapes and until the open index sub-problem above is resolved; the research phase re-derives the statement from `LadderRealize.lean` and `HitComplete.lean` as landed. Honest outcomes: landed; or [BLOCKED] on whichever predecessor did not close or on the open sub-problem — never sorry, axiom, vacuous definition, or a decidability claim from the semi-decidable ∃-object form without the bound (the README: without the bound the composition theorem is "at best semi-decidable — and NOT Decidable (PlusValidZTime φ)").

GUARDRAILS: (a) the ladder object is a time-axis object over the closure alphabet; (b) its slice is infinite — the object bounds cells and deadline classes, never the fibre, and no finite-fibre assumption may be introduced to make the enumeration finite (the bound comes from counts); (c) `objBound φ` is a count (its shape is part of the open sub-problem; no figure exists) and the corollary is a `Decidable` instance, not a complexity statement — the held 2EXPTIME ceiling is neither cited nor approached; (d) zero debt: the enumeration is the tree's own, no external decidability theorem, no cslib require; (e) if T4/T5 land forward-only the lift is forward-only and says so — nothing beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet` is claimed about ⊡(Pp). Dispatch with --lit (HWZ 2000 / GKWZ 2003 indexed, orientation only).

FILE SCOPE: new `Lift.lean` plus the shared library set. Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744, 410. Logical edges on T4 and T5.

NOT COSTABLE, and why: statement fixed by T4/T5. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections C, D and H6.

---

### 761. Ladder realization theorem
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 760, Task 775, Task 805, Task 806, Task 819, Task 820, Task 934, Task 991
- **Research**:
  - [761_ladder_realization_theorem/reports/18_clipped-register-block-nonvacuity.md]
  - [761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md]
  - [761_ladder_realization_theorem/reports/02_spawn-analysis.md]
  - [761_ladder_realization_theorem/reports/08_rk-bounded-representative-refutation.md]
  - [761_ladder_realization_theorem/reports/15_stab-bit-copy-pair-decision.md]
  - [761_ladder_realization_theorem/reports/29_row-link-route-viability.md]
  - [761_ladder_realization_theorem/reports/30_quasimodel-abstraction-literature.md]
  - [761_ladder_realization_theorem/reports/31_gkwz-ptl-s5-quasimodels.md]
  - [761_ladder_realization_theorem/reports/32_laddermodel-construction-falsifier.md]
  - [761_ladder_realization_theorem/reports/33_exponential-clip-cell-constancy.md]
- **Plan**: [761_ladder_realization_theorem/plans/35_construction-over-certified-subset.md]
- **Summary**: [761_ladder_realization_theorem/summaries/35_construction-remaining-obligation-named-summary.md]

**Description**: AMENDED 2026-11-16 (statement replaced — the READ-OFF / CONSTRUCTION PAIR): five research rounds (reports 29-33) refuted the filed single fibre equation over a pre-given `ladderModel` and the row-link route that served it, and decision 26 adopts in its place the PAIR the published quasimodel literature actually proves: (i) READ-OFF, `ladderReadOff` -- given model implies certified, hence the cell is CONTAINED IN the `Dmax` fibre (GKWZ Lemma 5.24 forward direction plus the maximal-set containment); and (ii) CONSTRUCTION, `ladderConstruct` -- certified set implies a model BUILT FROM IT (Lemma 5.24 converse). `ladderRealized` stays REFUTED under its pinned name and is never landed in any weakened, regime-narrowed or same-named form. The row-link route is STOPPED: `exists_rowLinked_path_K1_refuted` kills the path forth at its own signature with EQUAL countdowns of arbitrary size, so no countdown-side hypothesis helps, and `cell_agreement_over_Mrel_refuted` kills the route's own projected end result. The construction half is UNWRITTEN in all four of its components (no carrier, no frame, no valuation, no truth lemma; `ladderRealized` is declared nowhere; `Dmax` is not even known to be certified) and gets its own phase, declared NOT COSTABLE. Live route: specs/761_ladder_realization_theorem/plans/34_readoff-construction-pair-restatement.md.

AMENDED 2026-10-18 (presentation chosen): the cell presentation is (a), the set-valued per-state datum — the maximum certAdm-certified subset D of Q × ClType φ × K, with ladderRealized the fibre equation and the factorization lemma for K its corollary; no tuple index is to be stated at any parameters (K is a carrier coordinate whose parameters are outputs of the counter-lift lemma). The realization theorem now waits on the counter-lift lemma (obligations (2) and (3) jointly), filed as task 820, gated before any sufficiency attempt; the label-level results of the certificate rounds are region-interior (wired probe specs/evidence/seam-gluing-ray-product/no-pending-forever-ray.lean) and compose only through that lemma. Route A is not entered. See specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md. All six declared edges (760, 775, 805, 806, 819, 820) are DISCHARGED: 760/775 archived, 805/806 completed, 819 the presentation decision, 820 the counter-lift gate table — which compiled with BOTH decision gates COLLIDING (`gate9_col_cell_eq`, `gap_shift_cell_eq`), so the lemma's two halves are licensed in PUMPING form and no open edge remains. The positionwise statement shape is refuted for every finite counter quotient (`no_positionwise_lift`). Live route: specs/761_ladder_realization_theorem/plans/01_ladder-realization-presentation-a.md.

AMENDED 2026-10-12 (realization blocked): the realization theorem is [BLOCKED] on the open index sub-problem — `hitOf (truncate B …)` is a residue of the deleted index (`truncate` is defined nowhere; its only reading is `Q × Fin (B+1) × Fin (B+1)`) and is withdrawn from the statement line; every per-cell soundness statement presupposes a finite index of ladder states (`cell_ne`; the `Count` clause; the `stab` clause's collapse of any per-state labelling), and the `box`/`stab` acceptance clause presupposes it too; the ladder's structural liveness is FORWARD-ONLY (wired probe `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`: `gPast_isPath`), so a ladder bundle replaces `ulive` only and keeps `slive` — "`ulive`/`slive` replaced" reads `ulive` replaced, `slive` retained. No library module; the index-free run-layer half is a user option (R2) not taken. See specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md.

AMENDED 2026-10-11 (carrier repair): the frame this record is stated on is the admissible-carrier frame of RaySummary/LadderModel.lean; see specs/765_ladder_frame_carrier_repair_and_index_deletion/plans/01_ladder-carrier-repair-index-deletion.md.

STATEMENT (library; new module `RaySummary/LadderRealize.lean`). Run-layer phase 2's soundness half (object → model), the ladder analogue of `FormalSystem/Metalogic/Decidability/RaySummary/Realize.lean`'s `Cons` (:573) / `cons_localRun` (:643) / `presented_modelOf` (:916) -- note the `RaySummary/` segment; and note that `presented_modelOf` is NOT the construction half: it carries `hφ : φ.BoxStabFree`, its slice is the finite presentation, and it has no K coordinate, stated at the HIT level per ladder cell:
  `structure LadderCons (φ : PlusFormula) (lab) (step) (pend) : Prop`  -- `Cons`'s fields with the liveness fields `ulive`/`slive` replaced by the ladder's structural liveness (c strictly decreases while pending, by `Count`), and with the box/stab letters PINNED per cell by the anchor layer's equations: `lab q (box ψ)` is one global bit (`box_mem_tpOf_iff`), the stab letter at `(q, c, n)` is that cell's bit (`stab_mem_tpOf_iff`); `anchorCons_anchorCells` is the completeness side of exactly those equations
  `theorem ladderCons_localRun …`  -- every ladder run satisfies the run conditions
  `theorem ladderReadOff … : cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩) z ⊆ {T | ∃ S : ClType φ, typeOfCl S = T ∧ (q, S, κ (c, n)) ∈ Dmax …}`  -- half (i), READ-OFF: one CONTAINMENT into the fibre of the maximum certAdm-certified subset `Dmax` of `Q × ClType φ × K` (presentation (a)), for ALL φ, box/stab letters included.  `theorem ladderConstruct … (hR : certAdmK … R) : ∃ F M key, (∀ x ∈ R, ∃ u, key u = (x.1, x.2.2)) ∧ ∀ u, cellAt M φ u 0 = {T | ∃ S, typeOfCl S = T ∧ ((key u).1, S, (key u).2) ∈ R}`  -- half (ii), CONSTRUCTION: from a set carrying `certAdmK` as an EXPLICIT hypothesis (NOT stated at `Dmax`, whose `certStabK`/`certBoxK` are open -- `dmax_certStabK`/`dmax_certBoxK` have no hits, and the union defining `Dmax` does not preserve conditions (5) and (6)), a frame, a model and a key map whose cells are that set's fibres. The model is an OUTPUT and is NOT `ladderModel`.  THE FUSION OF THE TWO AT A FIXED MODEL AND A FIXED QUOTIENT KEY -- the single fibre equation `ladderRealized` this record filed until 2026-11-16 -- IS REFUTED and is never landed: `no_fibre_equation_over_kappa` (wired) at the filed clip; `gap_clip_below_exponential_refuted` (wired) below `2^(dBack φ + 1)`; `no_formula_only_clip`, quantified over ALL clip functions of the formula, at every formula-only clip, because the gap threshold a formula can read scales with the OBJECT; and `ladderModel_realizes_no_set`, which says `ladderModel`'s cells are the `(q, κ)`-fibres of NO set. Separating coordinate throughout: the cell as a function of the counter gap `n - c`, i.e. `kappa`'s clipped-gap coordinate. An OBJECT-dependent clip `B(Q, φ)` is the one unrefuted route and is an OPEN QUESTION, not a closed one: refuted up to `card Q - 2` by the chain family; the `card Q · 2^dBack` lower bound is INFERRED, not compiled; taking it would itself be a signature change, since `paramsOkK4` and `Bof` read the formula alone. The earlier `HitCl … = ↑(hitOf (truncate B …) … (clNow φ) k)` line is WITHDRAWN: `truncate` is defined nowhere and its only reading is the refuted index, so that line named no object. Per ladder cell, for ALL φ, box/stab letters INCLUDED, the cell being `cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩)` on the world state `ℤ × LadderState Q pend` (the `ℤ` component is invisible to `cellAt`, `cellAt_eq_cellAt`, but must be written). NO finite index of which cell a ladder state has is provided by any predecessor: the index `Q × Fin (B+1) × Fin (B+1)` is refuted (`ladder-cell-refutation.lean`: `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`) and is DELETED here; which cell a ladder state has is an OPEN SUB-PROBLEM, recorded and not re-stated over any substitute. The SET of cells stays finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`)
The box/stab clause is the acceptance criterion: it is where obligation (3)'s first half ("(S) beyond its landed corner": box/stab-bearing φ) lands, by the README's own assignment of that limitation to (W). No standalone (S) record exists for it (agent decision D1, re-openable by /revise).

WHY HIT-LEVEL, WHY THIS FRAME. Two machine-checked facts (wired probe `w-soundness-shape-refuted.lean`): WIDTH — `Probe747.modelOf_incomplete`: `modelOf` on any `Cons` presentation validates `Φ.neg` while `¬ PlusValidZTime Φ.neg`, whatever clauses are added, because `ofSlicedStep` on a Fintype has finite width; COLLAPSE — `Probe747.stab_iff_of_presented_nowUnique`: at a trace-level `Presented` seam with `nowUnique`, ψ ↔ ⊡ψ for every closure formula, so trace-level realization cannot witness any ⊡-refutation. Hence the hypothesis is `HitPresented`-shaped per cell and the frame is `ladderFrameAdm` on the admissible carrier `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` (`RaySummary/LadderModel.lean`; slice infinite — `(q, 0, n)` is admissible for every `n`, `Rlad_slice_infinite` one level down; regular by `ladderFrameAdm_isRegular`), with the model `ladderModel` reading the object component; `ladderFrame` itself has no instances (`no_fwd`, `no_bwd_of_idle`) and stays beside it, untouched. `presented_modelOf` is untouched and not re-proved.

DEPTH. `1 ≤ k` stated; the consumer depth is k = 1 (every landed bridge carries `1 ≤ k`; the closure alphabet makes nesting visible through letters).

CONTINGENCY. If the theorem does not close, mark [BLOCKED] with the goal state recorded; never sorry, axiom, vacuous definition, a trace-level hypothesis, or any finite-fibre/finite-width assumption. T3/T4 keep standalone value whatever T2 reports (the construction direction for this semantics. CORRECTED 2026-11-16 from sources actually read: HWZ 2000 Theorem 14 is a satisfiability iff for MONODIC FIRST-ORDER temporal logic and that paper has NO box and NO stab modality at all, so it names no published result about this semantics and is a pointer to a proof SHAPE only. The nearest published object is GKWZ 2003 §5.2 -- Theorem 5.22, Lemma 5.24, restated for a linear first component at Theorem 6.61 -- where `certStabK` IS the (qm1) clause, `cellAt` IS the quasistate read-off, and `Dmax` IS the maximal satisfying set by elimination. §13.2 / Theorem 13.6 is NOT the pointer: its proof is written for L = K with the S5 case left to the reader in one sentence. In every source read, quasistates are EXACT, only runs are existential, and EVERY converse direction CONSTRUCTS its model; the only quotient of a pre-given model is filtration. The transfer to this logic is by SHAPE: no theorem in either source applies to this semantics, and this setting is NOT PTL x S5 -- `stab_state_only` makes the stability modal state-keyed across times, so a time slice holds many clusters).

GUARDRAILS: (a) closure-indexed letters over the time axis, box/stab bits included; (b) infinite width, no fibre bound; (c) no upper bound — B and the presentation size are counts; (d) zero debt: no Büchi/MSO lemma cited in place of a proof, no cslib require; (e) if the landed form is forward-only, say so; no device-discrimination claim.

FILE SCOPE: new `LadderRealize.lean` plus the shared library set (`RaySummary.lean`, `FormalSystem.lean`, `KTypeSummaryAxiomTest.lean`, `check-module-invariants.sh`, `docs/theorem-index.md`, RaySummary README, `typst/generated/status.typ`). Durable anchors only outside specs/**. Cross-set collisions left to the admission gate: 744 (README, invariants), 410 (status.typ). Logical edge on T3.

NOT COSTABLE, and why: T3 landed no bound (its stabilization lemma is refuted); sized by the open index sub-problem and by how much of `Realize.lean` (1004 lines) transfers; the README records it has no figure. Design of record: `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` Sections A, C and H4.

FOLDED IN 2026-11-24 -- two separate records were closed into this one (their audit verdicts were subset-of-open and duplicate-of-open against this task; both carried a description only, no artifacts, and nothing referenced their directories). Both touch paths already inside this task's file scope. They are independent of the depth-0 gate and can be done at any time:

(i) THE ONE-SIDED REFUTATION TABLE ROW. Add the one-sided transport refutation row to the RaySummary refutation table in FormalSystem/Metalogic/Decidability/RaySummary/README.md, recording the NEGATIVE verdict that the probe specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean establishes: the one-sided open-modal factorization does not crack the transport condition. State the mechanism as the probe states it -- the ladder countdown and the closure eventualities read the same forward half-line, so freezing the future leaves nothing to transport and freeing it loses the realized type. Cite the probe file and its headline declarations by name. Scope: README.md only; no .lean edits. Do not claim any decidability consequence.

(ii) THE FORWARD PEND-COUNTDOWN RIGIDITY SHARPENING. Promote cntAt_eq_of_pend_eq_fwd from the same probe into FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean as a strict sharpening of the landed cntAt_eq_of_pend_eq. The landed theorem's own proof already reads its hypothesis only at positions at or above the compared one, so the forward-only hypothesis suffices -- the same proof at a weaker hypothesis, verified sorry-free in that probe. Land it beside the existing theorem, derive the existing theorem from the sharpening or state why that direction is not worth the churn, and keep the probe compiling. No sorry, no new axiom, axiom profile within [propext, Classical.choice, Quot.sound]; check-evidence-probes.sh and the full guarded lake build must both stay green.

---

### 734. E4 mosaic stabsaturated mixed germ probe
- **Status**: [HOLD]
- **Held**: 2026-10-17
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 733, Task 805
- **Research**: [734_e4_mosaic_stabsaturated_mixed_germ_probe/reports/01_e4-stabsaturated-mixed-germ-probe.md]
- **Plan**: [734_e4_mosaic_stabsaturated_mixed_germ_probe/plans/01_e4-stabsaturated-mixed-germ-probe.md]
- **Summary**: [734_e4_mosaic_stabsaturated_mixed_germ_probe/summaries/01_e4-stabsaturated-mixed-germ-probe-summary.md]

**Description**: Run experiment E4: decide StabSaturated on the Bool fixture's mosaic set, and acquire the Hodkinson-Reynolds Handbook sections

WHY THIS EXISTS. Route R2 -- mosaics and quasimodels -- is the rank-2 route to decidability of L+ over discrete time, behind the seam-gluing route R1 and ahead of the closed and low-ranked alternatives. Its amalgamation precondition is already FREE: `paste` glues two mosaics agreeing at a shared germ, choice-free and with uniqueness, exported as `amalgamate` and `amalgamate_unique`. What gates R2 is a single decidability question that the landed probe fixes as a `Prop` and proves only in a degenerate corner, plus two Handbook sections absent from the corpus. The review named this experiment E4 and left it "open for the next round to attack by name". It was never filed.

THE GATE, precisely. `Probe718Mosaic.StabSaturated` is proved only by `stabSaturated_of_sameState` -- the SAME-STATE corner. R2's hypothesis is that `StabSaturated` is decidable on finite mosaic sets with MIXED germ states, under `[F.IsRegular]`, and that a saturated-set existence theorem holds for L+. Neither is established. Re-verify both declaration names against the tree before relying on them; this description's reading is from 2026-10-05.

WHAT TO DELIVER, in two parts.
(1) The probe: decide `StabSaturated` on the two-state Bool fixture's mosaic set at `box-dot(Fp)`, with MIXED germ states rather than the same-state corner. This is the cheapest test of R2's load-bearing hypothesis.
(2) The sources: the Hodkinson-Reynolds Handbook of Modal Logic sections 5.10 and 5.11 bodies are ABSENT from the corpus, which is why R2 cannot be promoted on textual grounds no matter how the probe comes out. Acquire and ingest them. R2's standing cannot be settled by a probe alone.

THE FALSIFIER, which is a valid outcome. A finite mosaic set, with mixed germ states, on which `StabSaturated` is FALSE yet every finite coherence condition holds. That would close R2 the way filtration was closed, and closing a route on evidence is a complete result -- not a failed task. Record it rather than working around it; the no-weakening rule for wired probes applies.

HARD CONSTRAINTS. No complexity claim. Do not file a fourth certificate class on the strength of anything found here: any certificate class presenting finite fibres is already refuted by `Probe710.not_finite_width_fmp`, and R2 is a quasimodel route, not a certificate class. Do not promote R2 above R1 on probe evidence alone; ranking is the review's, and the Handbook sections are part of what any re-ranking would rest on.

LITERATURE. Part (2) is source acquisition; run with `--lit`.

SCHEDULING. Wiring into `scripts/check-evidence-probes.sh` collides with the declared file_scope of tasks 720 and 725, and with the two sibling probe tasks filed alongside this one. Run in a separate cycle from each of them.

ACCEPTANCE. One probe file under `specs/evidence/seam-gluing-ray-product/` compiling under `lake env lean` and wired into `scripts/check-evidence-probes.sh`, whose header states whether `StabSaturated` is decidable on mixed germ states and what that does to R2's standing; plus the two Handbook sections present in the Literature index with an index entry. Either half landing without the other is a [PARTIAL], not a completion.

---

### 713. Formalize ctl star reduction 2exptime lower bound
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None

**Description**: SCHEDULABLE AND LOAD-BEARING AS A CHECK. User ruling 2026-11-24: released from HOLD to not_started, on the grounds recorded in the next sentence. Dependencies [], nothing depends on it. What has changed since it was filed is the claim that "none of the L-plus programme's recommendations rest on it." That is no longer accurate. Its 2EXPTIME lower bound -- ARGUED, not formalized -- is the sanity ceiling that three live records cite against any proposed decision procedure for L-plus. It is load-bearing as a check even while unproved.

ITS ROLE: THE SANITY CEILING. Three records USE this task's argued lower bound as the bound-sanity check -- nothing cheaper than 2EXPTIME is a credible decision procedure. All three were re-verified against the tree on 2026-10-07 (task 738), at their archive locations:

1. specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md (archived), the "Complexity sanity check" bullet at line 258: "the CTL* 2EXPTIME-hardness reduction (filed, argued in both directions) is the lower bound; determinization-based upper bounds are doubly exponential, which is consistent. Any proposal cheaper than 2EXPTIME is prima facie wrong. No bound committed."

2. Task 719's description (ray layer, seam gluing and stab fibre; completed and archived at specs/archive/719_ray_layer_seam_gluing_and_stab_fibre, record in specs/archive/state.json -- now provenance rather than a live document), Deliverable 5: "DO NOT LAND A COMPLEXITY CLAIM; the CTL-star 2EXPTIME lower bound is the sanity check on any proposed bound."

3. specs/archive/721_decidability_programme_review_l_and_lplus/reports/01_decidability-programme-review.md (archived) section 3.1 (L-plus routes forward), line 147 -- its Section C ruling on this task is at line 183: "the CTL* 2EXPTIME-hardness argument (task 713, ARGUED) is the lower bound on any proposed procedure; nothing cheaper is credible; no bound is committed here."

ARGUED, NOT FORMALIZED -- AND EVERY CITING RECORD MUST SAY SO. The bound is an argument in prose, not a machine-checked theorem. No Lean declaration establishes it; there is no CTL-star syntax or semantics in the tree to state it against. Every record that cites it must describe it that way, with the ARGUED qualifier attached, exactly as the three records above do. A citation that presents the bound as established, or that drops the qualifier, is a defect in that record.

NO UPPER-BOUND CLAIM MAY LAND FROM THIS TASK. The programme commits to no complexity bound. This task's content is a LOWER bound used as a ceiling: it rules proposals out, it never certifies that any procedure achieves a cost. Deriving or landing an upper-bound claim from it -- in this task's artifacts, in a citing record, or in the write-up -- is a defect, not a result. The asymmetry is the point: a lower bound says "nothing cheaper is credible", it does not say "this much suffices."

GOAL. Raise the 2EXPTIME-hardness of L-plus Z-time validity from ARGUED to MACHINE-CHECKED. The argument is given in both directions in specs/archive/706_lplus_finite_model_property_and_completeness/reports/01_lplus-finite-model-property-research.md section Q4 ("The true order of the state bound"), completing what task 703's round-2 report argued in one direction only -- now archived at specs/archive/703_lplus_compression_and_completeness/reports/02_semantics-first-compression-research.md section 1.6 ("The complexity picture").

THE REDUCTION. Translate CTL-star by A |-> stab and X |-> bottom U ., with non-strict U rendered as e or (g and (g U e)). FORWARD: a rooted total Kripke structure becomes bi-serial by adding one fresh state with a self-loop and an edge to the root, which leaves forward paths from the original states unchanged; stab at (sigma, t) with sigma t = w ranges over histories through w, whose futures are exactly the forward paths from w, and the translation is pure-future so its truth depends only on the future (truth_congr_agreeFrom). BACKWARD: from a Z-model of the translation at (sigma, t), the Kripke structure of the state graph forward-reachable from sigma t satisfies the CTL-star formula at sigma t, by the same two facts read backwards. CTL-star satisfiability is over arbitrary, possibly infinite structures, so no finiteness is needed anywhere.

WHAT IT WOULD BUY. Formalization would turn the ceiling from an argued check into a theorem-backed one: the sharpest available limit on how good ANY certificate class can be. As task 706's Q4 and the archived 703 round-2 section 1.6 record the consequence, with the reduction a theorem no complete certificate class with singly exponential, polynomially checkable certificates could exist for full L-plus without a complexity-theoretic surprise.

CANONICAL WORDING OF THE CONSEQUENCE (quote this, verbatim, in any record that repeats it). L-plus Z-time validity -- equivalently, by negation, L-plus Z-time satisfiability -- is 2EXPTIME-hard by the CTL-star reduction. ARGUED, NOT FORMALIZED: no Lean declaration establishes it. CONSEQUENCE, stated for NON-VALIDITY: if every non-valid formula had a certificate of size singly exponential in the closure size, checkable in time polynomial in the certificate's size, then non-validity (satisfiability of the negation) would be in NEXPTIME and, equivalently, validity would be in co-NEXPTIME; hence 2EXPTIME would be contained in NEXPTIME, equivalently in co-NEXPTIME, since 2EXPTIME is closed under complement. That containment is not refuted but is widely disbelieved. The two class names are the same statement read from opposite sides of the complement: a record may name either, but must say which problem it is placing (NON-VALIDITY with NEXPTIME; VALIDITY with co-NEXPTIME). This is a LOWER bound used as a ceiling: nothing cheaper than 2EXPTIME is credible. It says nothing about any cost sufficing for L-plus and must never be restated as an upper bound. Sources: 706 Q4 (validity / co-NEXPTIME reading) and 703 round-2 section 1.6 (satisfiability / NEXPTIME reading), reconciled 2026-10-07 (task 738): the apparent divergence was one of presentation, not content.

WHAT IT COSTS. A CTL-star syntax and semantics must be added to the tree, which is substantial standalone work the programme otherwise has no need for. Task 706 rates the risk that the reduction has a gap as LOW (its R4) and records it as affecting the complexity picture only.

KEEP-OR-ABANDON WAS RULED ON 2026-11-24: KEEP AND SCHEDULE. The grounds are the ones this record already states -- the bound is load-bearing as a check even while unproved, and abandoning the record would leave the three citing documents pointing at nothing. The decidability-programme review's Section C (specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md, Section C at line 220) restates the choice as the user's: keep this as a write-up note, or abandon it. RECOMMENDATION ONLY, not a decision: keep it as a write-up note, because it is load-bearing as a check even while unproved -- abandoning the record would leave the three citing documents pointing at nothing. If the ruling is to abandon, the three citing records need their sanity-check bullets re-sourced to the argument's actual homes (706's Q4 and the archived 703 round-2 section 1.6) rather than to this task.

---

### 664. Ingest cmiel kuhlmann ball space source
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: literature
- **Dependencies**: None

**Description**: Acquire and ingest the Cmiel-Kuhlmann-Kuhlmann ball-space paper into the literature corpus, which currently has no copy of it.

Measured gap (verify rather than trust): the manuscript's def:frame carries a footnote citing \cite{Cmiel2021} for the claim that the nonempty fibers and segments form a BALL SPACE, and that Saturation is the downward-directed-intersection condition S_1^d of that hierarchy -- the nest condition S_1 with a directed system of balls in place of a nest. That citation has no local backing document: no entry matching Kuhlmann, ball space, spherically complete or ultrametric appears in ~/Projects/Literature/index.json or in specs/literature-index.json, and a filename search across ~/Projects/Literature/ returns nothing.

Why this matters rather than being bookkeeping. Research on the S1-versus-directedness question had to proceed without the primary source and was able to settle only part of it: S_1 provably suffices for the step lemma over every history with a countable domain (covering Z-time and Q-time), while directedness can only be forced over a non-archimedean duration type with an omega_1-coinitial positive cone. The converse direction S_1 -> S_1^d remains open, and the manuscript has already withdrawn its earlier "strictly stronger" wording in favour of "at least as strong as", so the strictness question is live rather than settled. Both the open direction and the ball-space framing route through the cited hierarchy, and neither can be grounded against the source while the source is absent. Note also that Mathlib has no spherical-completeness API at all, so there is no secondary formal reference to fall back on.

Scope: locate the paper (Cmiel, Kuhlmann and Kuhlmann, ball spaces; the manuscript's own bibliography entry is the starting point for exact title and venue), then run /literature to convert and index it so it is discoverable by future --lit dispatches. Record in the sub-index what the hierarchy's S_1 and S_1^d conditions are as the source states them, so later work can check the project's usage against the source's own definitions rather than against paraphrase.

Out of scope: any Lean change, and any edit to the manuscript.

---

### 604. Support zstd compressed jsonl datasets
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 631, Task 632

**Description**: Add zstd-compressed .jsonl dataset support across the data pipeline so large datasets can live on disk as .jsonl.zst. data/bmlogic-c7.jsonl was compressed to data/bmlogic-c7.jsonl.zst to reclaim disk space (17G -> 153M; lossless, sha256 of decompressed stream 4079d0a6b4310d417ae91999abcd581e5ebd9dacd4e9f3c33d1d9b3aa55f2704 verified identical; restore with `zstd -d data/bmlogic-c7.jsonl.zst`). Consumers that hardcode data/bmlogic-c7.jsonl are currently broken. Research first: (1) inventory every reader/writer of .jsonl datasets -- Python scripts (validate_benchmark.py, validate_datasets.py, verify_benchmark.py, migrate_schema_v2.py, standardize_metadata.py, curate_benchmark.py, curate_very_hard_plus.py, finalize_benchmark.py, validate_c5_dataset.py), shell scripts (run_dataset_generation.sh, export-training-data.sh, typst-machine-appendix.sh, typst-sync-check.sh), Lean executables under FormalSystem/Automation/*Main.lean, lakefile.lean, Tests/BimodalTest/Automation/ProofFirstTests.lean, data/hf-dataset/ tooling, and path fields in data/*_metadata.json; (2) choose the Python approach, e.g. one shared open_dataset() helper transparently handling .jsonl and .jsonl.zst (zstandard package vs zstd subprocess) and how that dependency is provided; (3) decide how Lean executables handle compressed data given Lean has no native zstd (IO.Process pipe through zstd, or shell-wrapper streaming via stdin/stdout) and whether generators should write .jsonl.zst directly; (4) reconcile with the Hugging Face Hub storage migration (task 257). Then implement, keeping plain .jsonl working, and verify every updated consumer against data/bmlogic-c7.jsonl.zst

Reconciliation note (task 629): depends on task 631 (deliverable hygiene, deletes migrate_schema_v2.py and standardize_metadata.py -- drop these two from this task's own script inventory step) and on task 632 (BimodalTools split -- write the Lean-executable inventory step against BimodalTools.* paths directly, avoiding a second rewrite).

POST-RELOCATION NOTE (2026-09-21). Dependency 632 is complete. The Lean executables this task names as 'FormalSystem/Automation/*Main.lean' are now BimodalTools/*Main.lean (root-level lean_lib BimodalTools, outside defaultTargets; lake exe target names unchanged), and Tests/BimodalTest/Automation/ProofFirstTests.lean is now Tests/BimodalToolsTest/ProofFirstTests.lean. Build and test with lake build BimodalTools and lake build BimodalToolsTest. typst-sync-check.sh now scans two Lean source roots (FormalSystem/, BimodalTools/).

---

### 570. C3 completeness question
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: metalogic
- **Dependencies**: Task 568

**Description**: OPEN RESEARCH QUESTION, not an implementation task. Is the logic of C3 -- the domain-restricted consequence relation -- equal to Burgess-Xu without the unboundedness assumption, plus S5?

WHAT IS ALREADY ESTABLISHED (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.2) is the CONTAINMENT: C3 includes classical propositional logic, S5 for box, the whole Burgess-Xu monotonicity, enrichment, accumulation, absorption and linearity block, and `modal_future`; and C3 excludes seriality and the uniformity layer. The study explicitly DECLINES the completeness claim. Establishing or refuting it is this task, and the honest starting position is that it is open.

THE FIRST OBSTACLE, which any canonical-model construction will hit immediately (`specs/553_decide_convex_history_layer_collapse/reports/01_convex-correlate-and-consequence.md` section 4.3): the germ constraint. Every C3-validity holds at every one-point germ, and `box (phi U psi)` and `box (phi S psi)` are C3-UNSATISFIABLE for every `phi` and `psi`. That is stronger than the loss of seriality: it constrains what any axiomatization of C3 could look like, since no boxed binary-tense formula can ever be a theorem. A canonical model for C3 must either accommodate germs in the box range or the box range must be cut back first.

SEQUENCING. Do not start before the box-range design choice recorded in the C3/C4 library task is settled by the author. If the box range is cut back, this task is about a DIFFERENT logic and this description must be revised before any work begins.

LITERATURE. Burgess 1982 and Xu 1988 axiomatize `U`/`S` over an arbitrary linear order BEFORE unboundedness is added, which is exactly the setting C3 lives in. Check the Literature/ index for both before starting; acquire them if absent.

---

### 543. Formalize mf correspondence rigidity
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: metalogic
- **Dependencies**: Task 500, Task 652, Task 656, Task 683

**Description**: Machine-check the principal new results from the MF frame-correspondence research conducted in the PossibleWorlds paper repository. SOURCE MATERIAL (read before starting; six reports, all outside this repository): /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/02_mf-substrate-weakening-definability.md (Theorem A), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/03_worlds-topological-categorical-characterization.md (rigidity, T1 converse), /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/04_dense-correspondent-and-rigidity.md (Theorems B and C, scope limits), and /home/benjamin/Philosophy/Papers/PossibleWorlds/specs/archive/136_rewrite_mf_paragraph_frame_correspondence/reports/05_lean-verification-and-formalization-program.md (THE ROADMAP -- effort estimates, elaborated statements, and Mathlib dependencies, all checked against this tree). VERIFIED BASELINE, established by that round-3 work against this repository: lake build FormalSystem green (2591 jobs); 20 lean_verify calls returning standard axioms with no sorryAx; and the claim that modal_future_valid discharges no frame field now verified at the proof-term level by a transitive constant-closure walk (696 of 703 constants, imported bodies loaded via findAsync?) finding no FrameOver or TaskFrame field projection and no hF_nonempty. TARGETS, in roadmap priority order. R1: the result that deterministic task frames determine the same BL-logic as all task frames. It is NOT the pure composition of reverse_repr and forward_repr that the originating report claimed -- it needs a third fact, S.frame.Deterministic, absent from this tree; with a one-line helper it typechecks in about 25 lines, reproduced in report 05 Appendix A.1 (elaborated in scratch only; nothing was written into this repository). R2 -- BEST EFFORT-TO-VALUE IN THE SET: the rigidity theorem (report 03 section 4.3.6): over a dense Archimedean temporal order a task frame is static iff it has a uniform dwell time, hence every task frame over such an order with finitely many world states is static. Approximately 100 lines, and the finite-W half ALREADY EXISTS here as exists_uniform_radius_of_finite. The proof uses only Limit and Compositionality; Mathlib supplies Archimedean and DenselyOrdered. The claim is surprising enough that machine-checking it before it enters the paper is the point. Note report 04's refinement: for time-indexed frames the boundary is Dedekind completeness rather than the Archimedean property. R3: the T1-converse witness (report 03 section 4.2.3), a 4-state structure refuting the converse of the paper's Limit-implies-T1 result. BLOCKER TO RESOLVE FIRST: this witness cannot currently even be STATED here, because WorldHistory requires a TaskFrame and the witness violates that structure's limit field; a structural workaround is needed, and this would introduce the first topology into the repository. R4: Theorem A (MF valid iff the task relation is stationary) over Z-time, medium-large; the TimeIndexed structure and the statement are elaborated in report 05. CRITICAL SCOPE CONSTRAINT from report 04 Theorem C: Theorem A's scope is EXACTLY D isomorphic to Z -- for every discrete D not isomorphic to Z (including Z x_lex Z) and every countable or divisible dense D, a non-affine order-automorphism yields a deterministic non-stationary MF-valid frame. Do not state it more generally. Also worth formalizing: Theorem B (report 04) -- MF valid iff its past mirror MP valid iff every box-sentence is globally constant in every model -- which is exact and uniform over every D and is flagged in report 04 as reachable via box_const. NOT RECOMMENDED: Theorem A-prime; report 05 judges the formalization cost unjustified and the paper statement fine unformalized. DEPENDENCY RATIONALE: this task depends on the ShiftSet representation-theorem reconciliation research task because Theorems A and B both touch FormalSystem/Semantics/ShiftSet.lean, and that task exists precisely to prevent two parallel representation theorems from being developed and having to be reconciled afterwards. Settle that question before landing R4. Land real proofs; no sorry. This repository already carries a task-relation correspondent the paper lacks, density_schema_iff_fwdRec over Z, which is a useful model for how to state these. Reconciliation notes (2026-09-21): R1 and R2 were split out into task 646 (they import but never edit FormalSystem/Semantics/ShiftSet.lean, so they do not need the ShiftSet reconciliation this task waits on). This task retains R3 (the T1-converse witness), R4 (Theorem A over Z-time) and Theorem B, and still depends on task 500. Do not re-do R1 or R2 here. Reconciliation notes (2026-09-22): task 646 has LANDED R1 and R2. R2 is FormalSystem/Semantics/Correspondence/Rigidity.lean (FrameOver.static_iff_uniformDwell, static_of_finite; the core chop lemma eq_of_rel_of_step needs only [Archimedean D], density enters once, the biconditional consumes Seriality and the reflection law) with compiled sharpness witnesses in RigiditySharpness.lean showing neither density nor the Archimedean property can be dropped (lexRatFrame_not_static over ℚ ×ₗ ℚ, lexRat_not_archimedean). R1 is FormalSystem/Metalogic/Deterministic/SameLogic.lean (validIn_iff_validDetIn, valid_iff_valid_deterministic) via the helper ShiftSet.frame_deterministic, which lives in SameLogic.lean, not in ShiftSet.lean. The Dedekind-completeness refinement for time-indexed frames noted in report 04 is now its own task, 652, which DEFINES the TimeIndexed structure per report 05 in FormalSystem/Semantics/TimeIndexed.lean; this task now depends on 652 and R4 (Theorem A over ℤ-time) MUST consume that structure rather than define a second one. Remaining scope here: R3, R4, Theorem B. R3 additionally depends on the general-task-frame refactor, which is what makes the four-state witness statable (a frame satisfying Compositionality, Seriality and Saturation but not Limit, with its own histories); do not attempt a structural workaround here.

---

### 502. Ground algebraic representation in goldblatt and brv
- **Effort**: 12-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: None

**Description**: RESEARCH TASK. Ground the algebraic representation front in the literature BEFORE the STSA axiom set is fixed and before Uf(A) is constructed. Gates the STSA port; the complex-algebra and ultrafilter-frame tasks inherit the gate transitively.

WHY THIS RUNS EARLY. Goldblatt 1989 is largely about which varieties of Boolean algebras with operators are complex algebras, and about canonicity. Those are design questions for the STSA axiomatization and for the Uf(A) construction, not questions the eta-embedding capstone can act on. On the pre-existing graph this paper was ingested in wave 1 and not opened until wave 4, by which point three tasks would have committed to designs it should have informed.

PRIMARY SOURCE, WITH A HARD READING CONSTRAINT. Goldblatt, R. "Varieties of complex algebras", Annals of Pure and Applied Logic 44 (1989) 173-242, doi 10.1016/0168-0072(89)90032-8. The acquired PDF is an Acrobat 3.0 Capture scan (70 pages) whose OCR text layer is UNRELIABLE ON MATHEMATICS: symbols mangle, lines drop and reorder, and even the title page renders New Zealand as "New 2Miand". READ THE PAGE IMAGES via the Read tool's pages parameter. Do NOT grep the text layer for definitions or theorem statements, and do NOT accept a pdftotext- or /literature --convert-derived markdown as a faithful source for any axiom or equation. The text layer is usable only as a rough locator.

PAGINATION. Journal page 173 is PDF page 1, so PDF page = journal page - 172. The paper's own table of contents is partly OCR-garbled in its page-number column; verify each section start against the actual page image rather than trusting the offsets below.

SECTIONS IN SCOPE (do not read the whole paper):
- 2.2 The dual space of a lattice (journal ~185) and 2.3 Bounded morphisms (~192) -- the duality machinery the eta embedding rests on.
- 3.1 Canonical structures (~198) -- the canonical extension / Uf(A) construction. Bears directly on the ultrafilter-frame task.
- 3.5 Canonical varieties (~208) -- IS THE STSA VARIETY CANONICAL? This is the single most load-bearing question for the STSA port, which must restate three Boneyard sorries against the current 45-constructor axiom set and should not do so blind.
- 3.6 The elementary case (~210) and 3.8 First-order definability -- bears on whether the Spherical frame condition is first-order definable and preserved, which is the ultrafilter-frame task's dominant and explicitly unattempted obligation, and one the paper's finite-W discharge pattern does not cover.
- 4.2 Preservation by bounded morphisms and inner substructures (~229) -- whether the TaskFrame axioms transfer along the constructions.
EXPLICITLY OUT OF SCOPE: 2.4 Heyting algebras (intuitionistic, not this signature).

CROSS-FRONT NOTE, RECORD BUT DO NOT PURSUE HERE: section 4.3 covers preservation by DISJOINT UNIONS, which may bear on the two-fibre structure named in Metalogic/Conservativity.lean as the CEB countermodel shape. That belongs to the TM-completeness research task on the metalogic front; if 4.3 looks relevant, record a pointer for that task rather than expanding this one.

SECONDARY SOURCE: Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002, born-digital, full text) is the standard Jonsson-Tarski reference and should be read alongside. CAVEAT: the corpus warns this entry is 365,868 tokens and exceeds a single context budget -- create a chapter-scoped sub-entry before an agent consumes it.

DELIVERABLE: a grounding report answering, with citations to specific pages read as images: (1) does the STSA axiom set as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean match the standard BAO presentation, and where does it diverge; (2) is the variety canonical, and what does that buy or cost the representation; (3) what the literature says about discharging a Spherical-style frame condition on an ultrafilter frame; (4) a concrete recommendation on how the three removed-axiom sorries (temp_a, temp_l) should be restated against the current axiom set. A finding that the literature does NOT settle one of these is a complete and valid answer for that item -- record it as unsettled rather than manufacturing a verdict.

---

### 501. Extend stsa with until since operators
- **Effort**: 20-32 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 125

**Description**: Phase 4 of the Jonsson-Tarski representation: extend STSA with the binary Until and Since operators. The STSA class as seeded in Boneyard/UltrafilterFrame/TenseS5Algebra.lean carries only the unary box, G, H and sigma. The live object language's primitives are untl and snce (Formula, Syntax/Formula.lean), with allFuture and allPast DERIVED from them (:167, :177) -- so an STSA over the unary fragment alone does not represent the actual logic, and the representation theorem is incomplete without this. SCOPE: add binary operators to the STSA signature with their algebraic laws, extend the complex algebra Cm(F) to interpret them from the frame relations, extend the ultrafilter frame Uf(A) correspondingly, and re-prove the eta embedding at the extended signature. SEQUENCING: this deliberately follows the unary capstone rather than being folded into it -- the unary representation is a standalone result worth landing first, and folding the binary case in would make a single task that cannot complete in one dispatch. LITERATURE: Blackburn/de Rijke/Venema 2002 Chapter 5 (in the corpus as blackburn_2002, full text) is the standard reference for Jonsson-Tarski and its extensions to n-ary operators. Note the corpus warns blackburn_2002 exceeds a single context budget at 365,868 tokens -- a chapter-scoped sub-entry should be created before an agent consumes it.

---

### 500. Reconcile shiftset representation with stsa route
- **Effort**: 10-16 hours
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: RESEARCH TASK. Prevent two parallel representation theorems from being developed and having to be reconciled after the fact. THE OBSERVATION: FormalSystem/Semantics/ShiftSet.lean -- landed by task 424 for the COMPACTNESS route -- is already a representation theorem. forward_repr (:263) and reverse_repr (:362) represent task models as shift sets, both directions, sorry-free. Separately, the STSA design report (specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md) identifies its key structural claim as: box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra, which is the algebraic encoding of OMEGA BEING SHIFT-CLOSED. That is the same shift structure ShiftSet.lean makes explicit. These look like two views of one representation. SCOPE: determine whether they are, and if so, specify the shared infrastructure so the algebraic route consumes ShiftSet rather than duplicating it. Concretely: (a) is Cm(F) expressible as an algebra of shift-invariant subsets of a ShiftSet carrier? (b) does ShiftSet's sep hypothesis correspond to an STSA axiom, and if so which? (c) can the eta embedding be factored through reverse_repr? DELIVERABLE: a report with a verdict and, if affirmative, a concrete refactor specification. A NEGATIVE VERDICT IS A COMPLETE OUTCOME -- if the two representations are genuinely different objects, say so with evidence and record it so the question is not reopened. TIMING: run this after the Los-lemma work and the STSA port have both landed, so both sides are concrete rather than projected.

---

### 499. Build ultrafilter frame and prove task frame axioms
- **Effort**: 24-40 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: HARD. Phase 2 of the Jonsson-Tarski representation: the ultrafilter frame Uf(A), and the proof that it is a TaskFrame. THE SEED: Boneyard/UltrafilterFrame/UltrafilterFrame.lean (1189 lines, behind #exit, 4 sorry hits) already has R_G (:82), R_Box (:90), R_H (:98) and a substantial body of proved structure -- R_Box_refl (:111), R_Box_euclidean (:127), R_Box_symm (:154), R_Box_trans (:164), R_G_R_H_converse (:179), the preimage and upward-closure lemmas (:229-251), R_G_trans (:281), R_H_trans (:304), and the F/P resolution lemmas (:515, :750). Port and revive rather than rebuild. THE GENUINELY NEW OBLIGATION, flagged in task 125's own FOUR-AXIOM EXPOSURE NOTE (2026-08-10): proving SPHERICAL for an ultrafilter frame is nontrivial and unattempted, and the paper's finite-W discharge pattern EXPLICITLY DOES NOT APPLY. Budget this as the dominant cost of the task; Compositionality, Seriality and Limit are expected to be far cheaper. MATHLIB HOOKS: Order/PrimeSeparator.lean:44 (DistribLattice.prime_ideal_of_disjoint_filter_ideal -- the Boolean prime ideal theorem in distributive-lattice form) is what a Zorn-free Uf(A)-nonemptiness argument should use; Order/Ideal.lean and Order/PrimeIdeal.lean (:156, :171) give the ultrafilter-as-prime-filter characterization. NOTE: Mathlib has NO Ultrafilter on an abstract Boolean algebra -- its Ultrafilter is Filter-on-Set-based. UltrafilterMCS.lean:44 rolls its own structure for exactly this reason, and its MCS-to-ultrafilter bijection (ultrafilter_correspondence :782) is available, though stated existentially rather than as a named Equiv. SHADOWING HAZARD: if Mathlib's Ultrafilter is opened in that namespace it collides with the bespoke one; keep them explicitly qualified.

---

### 498. Build complex algebra for task frames
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 497

**Description**: Phase 1 of the Jonsson-Tarski representation: the complex algebra Cm(F). Construct the powerset STSA over a TaskFrame -- carrier the powerset of the world-history space, with box, G, H and sigma defined from the frame relations -- and prove it satisfies every STSA axiom. GREENFIELD WARNING: Mathlib has NO Boolean algebras with operators, no complex algebras, no canonical extensions, and no modal-algebra machinery of any kind; a survey of the pinned v4.33.0-rc1 tree found nothing reusable for this. What Mathlib DOES supply and should be used: Order/BooleanAlgebra/ (already consumed by BooleanStructure.lean:421) and Order/CompleteBooleanAlgebra.lean:711 (CompleteAtomicBooleanAlgebra). CONSTRAINT FROM THE FOUR-AXIOM WORK (task 420, completed): TaskFrame (Semantics/TaskFrame.lean:474-577) now carries SEVEN fields, not five -- biconditional Compositionality, Seriality, Limit and Spherical plus a Nonempty WorldState field and [Nontrivial D]. The complex algebra must be built against the live seven-field structure, not the five-field shape the older design documents assume. ACCEPTANCE: Cm(F) defined, instance STSA (Cm F) proved, sorry-free, lake build green.

---

### 497. Port stsa class and add g operator
- **Effort**: 16-24 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: algebraic-representation
- **Dependencies**: Task 502

**Description**: Bring the Shift-closed Tense S5 Algebra class into live code and close the G-operator gap. Phase 1 groundwork for the Jonsson-Tarski representation. THE SEED: Boneyard/UltrafilterFrame/TenseS5Algebra.lean (361 lines, behind #exit) already contains the full class STSA extending BooleanAlgebra with fields box, G, H, sigma and axioms box_deflationary, box_monotone, box_idempotent, box_s5, G_monotone, H_monotone, sigma_involution, sigma_neg, sigma_sup, sigma_G, sigma_H, sigma_box, MF, TF, TA, TL. This is the exact algebraic signature the representation needs. IT CARRIES 3 SORRIES, AND THEY MUST NOT BE PROVED AS-IS: they are for temp_a and temp_l, axioms that have since been REMOVED or restructured; restate them against the current 45-constructor ProofSystem.Axiom set (Axioms.lean:115-464) rather than reviving the old shapes. THE G GAP: LindenbaumQuotient.lean supplies boxQuot (:305-ish), hQuot, and sigmaQuot (:346) with its four laws (sigma_quot_involution :353, sigma_quot_neg :362, sigma_quot_sup :373, sigma_quot_box :385) -- but there is NO gQuot. G on the Lindenbaum quotient must be constructed and its congruence proved before LindenbaumAlg can be an STSA instance. Boneyard/SorriedDeclExcisions/AlgebraicGQuotChain.lean is the excised prior attempt and should be consulted, not trusted. DESIGN REFERENCE: specs/archive/992_shift_closed_tense_s5_algebra/reports/01_stsa-algebraic-analysis.md (538 lines) gives the full axiom-to-equation translation table and the key structural claim that box a <= box(G a) meet G(box a) says the box-fixed points form a G-invariant subalgebra -- the algebraic encoding of Omega being shift-closed. It is stale on file names (references deleted AlgebraicRepresentation.lean and ParametricRepresentation.lean) but sound on the mathematics. ACCEPTANCE: STSA class live and sorry-free, gQuot constructed with congruence, instance STSA LindenbaumAlg, lake build green.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.

---

### 482. Discharge proof extraction completeness
- **Effort**: large
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 412

**Description**: CLASSIFICATION: OPEN MATHEMATICS, multi-month. This MUST NOT be re-described as engineering, and must not be scheduled or budgeted as a routine task.

STANDING INSTRUCTION — RE-VERIFY BEFORE CITING. Every declaration name, file path, and line number in this record must be re-verified against the tree before it is cited again, in a report, a plan, a dispatch prompt, or a revision of this description. This record previously asserted as established fact a declaration that does not exist (see CORRECTION below), and that false fact propagated into downstream planning. Do not inherit a name from this text; re-grep it. A citation that cannot be re-verified must be struck or re-stated as absent, not carried forward.

CORRECTION (2026-10-03) — THE VERIFIER THIS TASK WAS FILED AGAINST DOES NOT EXIST. This description previously stated that `verifyProof` is `fun _ _ => true` at `FormalSystem/Metalogic/Decidability/ProofExtraction.lean:345`, "honestly commented, misleadingly named". That was false in every part, and is withdrawn. Re-verified at revision time:

  - `grep -rn 'verifyProof' FormalSystem/` returns ZERO hits. `grep -rn --include='*.lean' 'verifyProof' .` over the whole repository also returns zero hits. There is no declaration of that name anywhere.
  - `FormalSystem/Metalogic/Decidability/ProofExtraction.lean` DOES exist (351 lines), but contains no verifier declaration under any name. Its complete declaration list is: `proofFromAxiom` (:66), `extractFromClosureReason` (:87), `tryAxiomProof` (:112), `buildCompositionalProof` (:148), `enhancedSearch` (:219), `ProofExtractionResult` (:236, an `inductive`), `extractProof` (:260), `findProofCombined` (:313), and the `ProofExtractionStats` structure (:342).
  - Line 345 — the anchor the old text gave for the stub — is the doc comment `/-- Method used (axiom, derived, closure, compositional, search). -/` belonging to the `method : String` field of `ProofExtractionStats` at :346. It is a statistics record, not a verifier.
  - There is a `## Proof Verification` doc-section header at :332 (its `/-!` opener at :331, closer at :333), and the section is EMPTY: the only line between it and the next doc block is blank :334, with that block opening at :335 and `## Statistics` at :336. No declaration occupies the section. The section that would have held a verifier is a heading with no content. That empty heading is the likely origin of the phantom citation.
  - `grep -n 'fun _ _ => true' FormalSystem/Metalogic/Decidability/ProofExtraction.lean` returns nothing. The six tree-wide matches for that term are all unrelated (`WitnessFamily/Sharing/Skeleton.lean:277`, `PlusSlicedCertificate/Check.lean:665`, `PlusSlicedCertificate/Fixture.lean:222/:228/:234`, `BiLasso/Examples.lean:74`).

THIS IS A STRONGER PROBLEM THAN A TRIVIAL STUB WOULD BE. A `verifyProof := fun _ _ => true` would at least be a named function with a type, so "this verifier is correct" would be a statable proposition and this task would have had a definite theorem to discharge. There is no such function. There is therefore nothing whose correctness could be stated, let alone proved. The task cannot begin by proving a verifier correct, because the subject of that proof is absent. What previously read as a vacuous-but-present obligation is in fact an absent one.

CONFIRMED-TRUE substance carried over from the old text (re-verified at revision time, not inherited):
  - `ProofExtraction.lean` has ZERO theorems and zero lemmas: `grep -nE '^\s*(theorem|lemma)' FormalSystem/Metalogic/Decidability/ProofExtraction.lean` returns nothing. Nothing in the file is proved about anything in the file.
  - No theorem anywhere establishes that a closed tableau ALWAYS yields an extractable Hilbert-system derivation.

DELIVERABLE, RE-STATED AGAINST WHAT IS ACTUALLY IN THE TREE. This task was filed to discharge proof-extraction completeness against a verifier that turns out not to exist, so its deliverable cannot be "prove the verifier correct". The first piece of work is a scoping decision between two routes, and THE EVIDENCE GATHERED SO FAR DOES NOT SETTLE WHICH IS RIGHT. Both are recorded honestly; do not treat either as pre-selected, and do not let a dispatch quietly default to one:

  ROUTE A — WRITE A VERIFIER, THEN STATE AND PROVE ITS CORRECTNESS. Introduce a verifier over extracted proof objects (the natural domain is `ProofExtractionResult` / the output of `extractProof` and `findProofCombined`), state its correctness against the refutation induction, and prove it. This creates the proposition the old description wrongly assumed already existed. Cost: the verifier's own design is unsettled — its type, what it consumes, and what "correct" means for it are all open, and a badly chosen signature would make the correctness statement either unprovable or vacuous. Choosing this route means owning that design, not just the proof.

  ROUTE B — RE-SCOPE TO THE EXTRACTION SIDE ALONE. Drop the verifier entirely and target only the extraction obligation: that a genuinely closed tableau yields a derivation, so that `.extractionFailed` is unreachable on one. On this route the task's content is the corollary off the refutation induction and nothing more; no verifier is written and no verifier-correctness theorem is stated. Cost: whatever downstream consumer motivated wanting a verifier (if any — this has NOT been established) goes unserved, and the question returns later as a separate task.

  WHAT TO DO FIRST: establish, from the tree and from the consumers of `extractProof`/`findProofCombined`, whether any caller actually needs a verifier, and record the finding. That evidence — not a preference — decides between A and B. Report the decision and its grounds before writing any Lean.

NEIGHBOURING FACTS, EACH RE-VERIFIED AT REVISION TIME:
  - `.extractionFailed` IS LIVE. It is a constructor of `DecisionResult`, declared `inductive DecisionResult (φ : Formula) : Type where` at `FormalSystem/Metalogic/Decidability/DecisionProcedure.lean:80`, with the constructor itself at :89. PRECISION NOTE: the outcome is DECLARED in `DecisionProcedure.lean`, not in `Correctness.lean`; what `Correctness.lean` carries is two proved theorems ABOUT it — `not_undecided_of_extractionFailed` (`Correctness.lean:264`) and `isKnownValid_of_extractionFailed` (`Correctness.lean:275`), both establishing that an `extractionFailed` verdict means the tableau closed and the formula is valid, with no proof term recovered. Cite the declaration and the theorems to their own files; do not merge them.
  - `FormalSystem/Metalogic/Decidability/Verified/Refutation/` DOES NOT EXIST. `ls` on that path fails. The parent `Verified/` directory does exist and contains `Bridge/`, `Decidable.lean`, `README.md`, `RuleSpec.lean`, and `Termination/` — no `Refutation/`. THIS TASK'S OWN `file_scope` NAMES THIS PATH, so that `file_scope` entry names an UNBUILT PATH: it is a destination, not an existing location, and any tooling or dispatch that reads `file_scope` as a list of files to open will fail on it. Do not create the directory as part of acting on this note.
  - `allClosed_derivable` DOES NOT EXIST IN THE TREE. `grep -rn 'allClosed_derivable' FormalSystem/` returns zero hits. It is task 412's target, not a landed theorem; `allClosed` itself is live as a tableau-result constructor (e.g. `ProofExtraction.lean:326`, `CancellableExpansion.lean:271`). Treat `allClosed_derivable` as a name for work not yet done.

PREREQUISITE AND SEQUENCING (substance preserved). The refutation induction (`allClosed → Derivable`, the content that would live under the unbuilt `Verified/Refutation/`) is a PREREQUISITE owned by task 412, which targets exactly that induction under the name `allClosed_derivable`. Task 412 is `not_started` with dependencies `[410, 411, 428, 430]`, and its description carries a paragraph naming this task as the owner of eliminating `.extractionFailed` as a live outcome on a genuinely closed tableau — verified present in 412's live description at revision time. This task is sequenced AFTER 412 rather than folded into 412's acceptance criteria, so that the research problem is not hidden behind 412's engineering-shaped description.

DO NOT schedule this as an independent parallel effort that would redundantly re-derive the refutation induction 412 already targets — consume 412's `allClosed_derivable` once it lands.

DEPENDENCIES: `[412]` (unchanged).

FILE SCOPE: `FormalSystem/Metalogic/Decidability/ProofExtraction.lean` (exists); `FormalSystem/Metalogic/Decidability/Verified/Refutation/` (DOES NOT EXIST — unbuilt path, see NEIGHBOURING FACTS; this task or a predecessor would have to create it, and only after the Route A/Route B decision is made).

ACCEPTANCE, RESTATED. The route decision (A or B) is recorded with the evidence that settled it, before any Lean is written. Then: `.extractionFailed` is unreachable on a genuinely closed tableau, stated and proved as a corollary of 412's `allClosed_derivable` or equivalent; `lake build` green; no regression to any currently-passing `scripts/check-module-invariants.sh` check (script verified present at that path). The old acceptance clause requiring `verifyProof` to be "either proved correct against the new theorem or replaced" is WITHDRAWN as unsatisfiable — there is no `verifyProof` to prove correct or to replace. On Route A it is superseded by the correctness theorem for the newly written verifier; on Route B it is dropped outright.

PROVENANCE (paths corrected 2026-10-03). Specced by task 468's realignment, whose artifacts have been ARCHIVED and are no longer at the live paths this description previously gave. Corrected locations, both verified present:
  - `specs/archive/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` — §5 is "Amendment-aware ADD list"; the spec for this task is "### New task spec 2 — proof-extraction completeness" at :272.
  - `specs/archive/468_realign_task_programme_from_proof_state_audit/plans/01_programme-realignment-execution.md` — "### Planner decisions taken here (not deferred to the implementer)" at :66, item 1 at :70-77, which is the decision to give proof-extraction completeness its own task with deps `[412]` rather than fold it into 412.
  The old description cited both of these under `specs/468_.../` (no `archive/`), where neither exists.
  MISATTRIBUTED CITATION, also corrected: the old text traced this task to "`specs/reviews/review-2026-08-24.md` amendment 10b's surviving ADD-list item". That file EXISTS, but contains NO "amendment 10b" — its sections are C-1, C-2, H-1 through H-6, M-1 through M-7, and L-1 through L-3. "Amendment 10b" is an amendment to task 468's CHARTER, referenced from 468's own artifacts (report 02 at :235, plan 01 at :47 and :388), not a section of the review. Cite it to 468's artifacts, not to the review file. The "per R4" tag is genuine and resolves to "### R4. Schedule the genuinely hard items honestly (months each)" at `specs/archive/468_realign_task_programme_from_proof_state_audit/reports/01_proof-state-audit-and-realignment-charter.md:347`.

ROADMAP ALIGNMENT. `specs/ROADMAP.md` has already been corrected to state this absence honestly: its proof-extraction line (:416-420) records that `Verified/Refutation/` does not exist and that no verifier declaration exists in `ProofExtraction.lean`, and its Open Risks row (:513) records that proof extraction has no verifier at all. This description is now consistent with both.

---

### 481. Discharge or replace unorderedsuccessorlabelclosed residual
- **Effort**: large
- **Status**: [BLOCKED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: None
- **Research**:
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/01_unorderedsuccessorlabelclosed-verdict.md]
  - [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/reports/02_spawn-analysis.md]
- **Plan**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/plans/01_sharpen-replace-labelclosed-residual.md]
- **Summary**: [481_discharge_or_replace_unorderedsuccessorlabelclosed_residual/summaries/01_sharpen-replace-labelclosed-residual-summary.md]

**Description**: CLASSIFICATION: genuinely open -- the predicate is refuted as stated, so this is a repair-or-replace problem, not routine discharge. This is the FIFTH termination residual; the four-residual framing used elsewhere in this programme (`UniverseClosed`, `DifficultyBounded`/`StepLengthBounded`, `MintPaysForTime`, `PostBlockingSettles`) is WRONG and must be corrected wherever it recurs.

TARGET: `UnorderedSuccessorLabelClosed` (`FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound/ClosureResidual.lean:836`) is carried as a live hypothesis by `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` (`ClosureResidual.lean:1139`) and has an in-tree refutation at `ClosureResidual.lean:889` (`¬ UnorderedSuccessorLabelClosed fc freshWorldLabels`) -- the same shape of problem `DifficultyBounded` presented before `StepLengthBounded` replaced it.

WHAT TO DO -- determine which of three outcomes applies:
(a) the predicate can be discharged at the frame classes/settings the surviving terminus theorems actually need (distinct from the setting `ClosureResidual.lean:889` refutes it in -- check precisely which); or
(b) it needs a `StepLengthBounded`-style weaker replacement, analogous to the `DifficultyBounded` -> `StepLengthBounded` repair pattern already in this file; or
(c) it is unclosable as stated and needs a C9 register entry (the file already has 24 such entries; this would be the 25th) plus an explicit statement of which theorem still carries it and at which frame classes.

A C9 REGISTER ENTRY IS A VALID, COMPLETE DELIVERABLE for this task -- do not treat "prove it" as the only acceptable outcome.

SEQUENCING NOTE (direct from `specs/reviews/review-2026-08-24.md` amendment 10e, re-affirmed by task 468's realignment): task 462 targets `MintPaysForTimeFixed` discharge at a NONEMPTY UNIVERSE, which is the same setting `ClosureResidual.lean:889`'s refutation applies in. If this task and 462 are not sequenced, 462 risks either duplicating the discovery of the refutation or, worse, building on an implicit assumption that this residual is harmless. This task should run BEFORE OR ALONGSIDE 462.

DEPENDENCIES: `[434]` (established the residual set this belongs to). Do NOT fold into 465 (the mechanical restatement-family task) -- 465 is explicitly scoped as "a one-line application of its family root" for SETTLED residuals; this residual is not settled, so folding it in would either force 465 to do research work outside its charter or produce a restatement of an unsettled predicate, which is exactly the kind of premature-closure risk this whole realignment exists to prevent.

VERIFIED at task-468 realignment time (2026-08-25): none of tasks 462, 463, 464, 465 mentions the symbol `UnorderedSuccessorLabelClosed` in its live description.

ACCEPTANCE: one of outcomes (a)/(b)/(c) above is reached and recorded; `lake build` green; no regression to any currently-passing check-module-invariants.sh check.

PROVENANCE: specced by task 468's realignment (report `specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md` §5, new-task-spec-3), itself descended from `specs/reviews/review-2026-08-24.md` amendment 10e.

POINTER REFRESH (2026-09-16 reorganization): `MintBound.lean` was split into the `MintBound/` directory (the monolithic `MintBound.lean` is now a 121-line aggregator). Line references above were re-confirmed against `MintBound/ClosureResidual.lean` (definition :836, in-tree refutation :889, carrying theorem :1139); "this file" in the text above now means that directory. The completed dependency numbers 434/483 were pruned from the dependency list; the blocked status and blockers are unchanged.

---

### 430. Semantic lift and track a assembly valid iff allclosed
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428, Task 429, Task 411
- **Parent**: Task 165

**Description**: The semantic lift and the Track A assembly. Owns obstruction O4 of the Phase 7.3 deadlock, then delivers what Phase 7.3 of task 165 was for. Grounding: specs/archive/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md (the report was archived with 165; the pre-archive path in earlier revisions of this description no longer resolves).

READ THIS FIRST: THIS TASK IS NO LONGER ON THE CRITICAL PATH TO A FIRST DECIDABILITY RESULT. ℤ-time validity of the base language is already decided, by a route that has nothing to do with this tableau spine. Verified against the tree on 2026-10-03 by `#check` and `#print axioms` under `import FormalSystem`:

  FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime
    : (φ : FormalSystem.Syntax.Formula) → Decidable (FormalSystem.Semantics.ValidZTime φ)
  axioms: [propext, Classical.choice, Quot.sound]
  FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean

It is a `def`, not an `instance` (a global instance would change instance resolution repository-wide; its own docstring says so). Its scope qualifiers are load-bearing and must be carried on every restatement: `FrameClass.ZTime` only; `φ : Formula`, the base-language syntax with no stability operator; empty premises. It is `decidable_of_iff` through `validZTime_iff_noCertifiedCandidate` (same file, same axiom set). The empty-premise consequence corollary `decidableSemanticConsequenceNil` covers `SemanticConsequenceIn FrameClass.ZTime [] σ` only; the general-premise case is unwritten. Do NOT restate any of this as "TM is decidable": that sentence drops every qualifier that makes the result true.

DISAMBIGUATION, because the name collides. `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` also declares defs of type `Decidable (ValidZTime φ)`, but they TAKE a finite-model-property hypothesis as an argument, and that hypothesis is refuted by `Probe476.fmp_false` (`specs/archive/476_box_faithful_small_model_theorem/evidence/fmp-hypothesis-is-false.lean`). The unconditional one is the `Compression`-sub-namespaced declaration above. Cite the full name, never the bare one.

WHAT THIS TASK'S DELIVERABLE ACTUALLY IS, GIVEN THAT. Not "the first decidability theorem". The spine's deliverable is the FOUR-CLASS statement: the biconditional `isValid φ fc = true ↔ ⊨ φ` together with the `Decidable (⊨ φ)` instances at all four `FrameClass` constructors -- `Base`, `Dense`, `ZTime`, `RTime` (verified: `inductive FrameClass` in `FormalSystem/ProofSystem/Axioms.lean` has exactly these four; earlier revisions of this description named them "Base, Dense, Discrete and Dedekind", which are the prose names, not the constructors). The spine is the only route FILED for Base, Dense and RTime. It is NOT the only route to any decidability result, and at ZTime it is not even the first: there it duplicates, by a different method, something already proved. Rank the work accordingly -- this is a four-class uniformity result and a tableau-correctness result, not a race to a first theorem.

WHAT THE SPINE HAS TODAY: THE SOUND DIRECTION ONLY. Verified:

  FormalSystem.Metalogic.Decidability.sound_of_isValid
    : ∀ {φ} (r : DecisionResult φ), r.isValid = true → ⊨ φ
  FormalSystem.Metalogic.Decidability.isValid_sound
    : ∀ (φ : Formula) (fc : FrameClass), isValid φ fc = true → ⊨ φ
  both axioms: [propext, Classical.choice, Quot.sound]
  FormalSystem/Metalogic/Decidability/Correctness.lean

Their conclusion is the UNRELATIVIZED `⊨ φ` whatever `fc` was passed, and that is forced by the types rather than chosen: `DecisionResult.valid` carries `⊢ φ` = `DerivationTree FrameClass.Base [] φ` for every `fc`. The frame-class-relative forms (`isValid_validDense`, `isValid_validZTime`, `isValid_validRTime`) are therefore weakenings obtained through the `Validity.valid_implies_*` monotonicity lemmas, not independent results. The siblings `isTautology_sound`, `isContradiction_sound`, `not_isSatisfiable_sound`, `decide_isValid_sound`, `decideBlocking_isValid_sound` and `decideAuto_isValid_sound` all factor through `sound_of_isValid`. The completeness direction `⊨ φ → isValid φ fc = true` is open, and it is the whole of what this task owes.

THE RETIRED-AS-VACUOUS RECORD, AND WHY IT IS A CONSTRAINT ON THIS TASK. `Correctness.lean` carries a section headed "`validity_decidable` / `validity_has_decision_procedure` -- Retired as vacuous". Two theorems once stood there and were retired rather than deleted quietly, because their NAMES claimed a decidability result their PROOFS did not contain. Faithfully, per that section:

  (i) `validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)` was proved by
      `exact Classical.em (⊨ φ)`. That is excluded middle for an arbitrary proposition. It
      holds of any predicate whatsoever and says nothing about `⊨` in particular, about
      tableaux, or about computation. It produces no procedure and no `Decidable` instance.
  (ii) `validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ`
      was proved by `by_cases h : (⊨ φ)` supplying `true` or `false` accordingly. The
      existential is witnessed non-constructively BY THE TRUTH VALUE ONE IS TRYING TO COMPUTE --
      `Classical.em` with a `Bool` wrapped around it. In particular it is not the statement that
      `isValid` (`DecisionProcedure.lean`) is that `decision`, which is the content one would want.

That section also records what is still owed and why it is deliberately not stated there: the completeness direction, hence the biconditional and the four `Decidable (⊨ φ)` instances, needs the fuel/termination side and the truth-lemma gate on top of the landed rule half, and must additionally account for the two rules scheduled outside `allRulesForFC`. Its closing sentence is the standing prohibition this task works under: stating an `isValid`-shaped `iff` before the obligation is discharged "would reproduce exactly the defect this retirement removes: a true-looking name over a proof that does not reach it."

O4 HAS TWO DISTINCT PIECES. The source is the docstring of the "7.2, the assembly" section of `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`, under the heading "What this does and does not deliver" (cited by section heading rather than line number; the line numbers in earlier revisions of this description have drifted):

(a) Two more `RuleSound`-analogues at the `expandOnce` level, for `serialityRule` and `timeLinearity`. These two are deliberately OUTSIDE `allRulesForFC` -- `mem_allRulesForFC_iff` (`Verified/RuleSpec.lean`) turns membership into `r ≠ .serialityRule ∧ r ≠ .timeLinearity ∧ ruleFrameClass r ≤ fc`, so the landed assembly provably does not cover them. They run as stages 2 and 3 of `expandOnce` and need their own obligations at the point where `expandOnce`, rather than `applyRule`, is the object.

(b) THE SEMANTIC LIFT: the induction lifting single-step satisfiability preservation to the whole recursion, so that `.allClosed` yields a contradiction. This is the LARGER of the two and is comparable in weight to a landed sub-phase, not to a wrapper. Naming it inside "the two outside rules" understates it.

THEN, and only after (a), (b) and both predecessors: the semantic lift's consequence at all four frame classes.

WHAT IS ALREADY LANDED (do not re-prove). The rule half is done. Verified:

  FormalSystem.Metalogic.Decidability.Verified.ruleSound_of_mem_allRulesForFC
    : ∀ (fc : FrameClass), ∀ r ∈ allRulesForFC fc, RuleSound (carrierForFC fc) r
  axioms: [propext, Classical.choice, Quot.sound]
  FormalSystem/Metalogic/Decidability/Verified/Decidable.lean

One induction over `mem_allRulesForFC_iff`, discharged case by case against a per-rule ledger complete at 34/34 `TableauRule` constructors; from task 165 Phase 7.2. Twenty-seven of the thirty-four travel through `ruleSound_base_mono` (`carrierBase` is `fun _ => True`); only two transports are non-trivial and both are one projection.

PLAN AGAINST SIX ROWS, NOT EIGHT. The truth-lemma gate hypothesis `hTW` is discharged on SIX accepted `TemporalWitnessProbe` rows (A, B, C, D, E, F), not the historical eight. Verified against the banner at the head of `Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean` (task 634 relocated the file there from the test root): "The eight rows this file repeatedly describes as 'the rows the gate accepts' -- A, B, C, D, E, F, I, K -- are now six: I and K, the two genuine negative-until/since rows, have joined H, J, M and N on the rejected side." The cause is the retirement of the PASSIVE co-decomposition arms of `.untlNeg`/`.snceNeg`; the banner calls it a deliberate, authorized completeness regression and notes it removes the last set of hand-built branches on which `hTW` was discharged. Read every "all eight rows the gate accepts" in that file's findings as "accepted before the retirement".

DO NOT write a conditional form carrying `hTW` as an explicit hypothesis. `Correctness.lean` refuses exactly this shape in two places -- the retirement section quoted above, and the docstring paragraph "`isKnownValid` is not a substitute hypothesis here" -- and the O4(b) hypothesis would BE the conclusion's forward direction, making the theorem vacuous. Four vacuous theorems were deleted in 165's Phase 8; do not land a fifth.

THE INDEPENDENT ORACLE FOR THE ZTIME INSTANCE. At ZTime this task's result must AGREE with a route already proved, and there is a cheap fixture that tests it. This is cross-check L-E3 of the ranking ratification in `specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (section "L -- the base language", entry L-R1). The target formula, verified by `#print` under `import FormalSystem` and NOT at the namespace the scope spec's shorthand suggests -- it lives in `FormalSystem.Metalogic.Decidability.WitnessFamilyExamples`, not directly in `FormalSystem.Metalogic.Decidability`:

  WitnessFamilyExamples.phiPos : Formula := occurs.box.and once.box
  WitnessFamilyExamples.occurs : Formula := pForm.or (fP.or pP)      -- p ∨ (Fp ∨ Pp)
  WitnessFamilyExamples.once   : Formula := pForm.imp pP.neg        -- p → ¬Pp
  with pForm = Formula.atom pA, fP = pForm.someFuture, pP = pForm.somePast
  FormalSystem/Metalogic/Decidability/WitnessFamily/Examples.lean

So the formula the scope spec writes as `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)` is `phiPos`, with the disjunction right-associated as `pForm.or (fP.or pP)`. `phiPos` is the sole member of `gammaPos`; `delPos = []`, so `posFamily` refutes no `σ` and instead exhibits a model of `gammaPos`.

The oracle is stronger than a mere certificate run, and this is worth knowing before building the fixture: `WitnessFamilyExamples.phiPos_satisfiable` is a landed theorem (axioms `[propext, Classical.choice, Quot.sound]`) producing a `FrameClass.ZTime.Sat` frame, model, history and duration at which every member of `gammaPos` is true -- assembled from `posFamily.joint_countermodel` and the four `by decide` facts `posFamily_localCoherent`, `posFamily_fulfilling`, `posFamily_boxFaithful`, `posFamily_target`. Hence `phiPos.neg` is NOT ZTime-valid, as a theorem and not as a computation.

THE CROSS-CHECK: run both routes on `phiPos.neg`.
  - `Compression.decidableValidZTime phiPos.neg` must decide NEGATIVELY (it is refuting a formula
    whose negation has a proved ZTime model).
  - `decide phiPos.neg searchDepth tableauFuel fc` (signature verified: `decide (φ : Formula) (searchDepth : Nat := 10) (tableauFuel : Nat := 1000) (fc : FrameClass := .Base)`)
    must NOT report `.valid` at `fc = .ZTime`. `.fuelExhausted` is an acceptable outcome;
    `.valid` is a soundness contradiction with `phiPos_satisfiable` and would mean the spine is
    broken, not merely incomplete.
  - `isValid phiPos.neg .ZTime` must not be `true`, for the same reason.
This is a cheap consistency witness the two routes have never been given, it needs none of O4, and it can be landed as a test fixture before (a) or (b). Doing it first is recommended: it either buys confidence in the engine at no cost or finds a soundness defect while the spine is still open.

OUT OF SCOPE. Do not reopen the C9 do-not-re-attempt register; it already holds the refuted forms (an unconditional `buildTableau_isSome`, and the decidable-branch-gate family that collapses to `false` on branches that mint a world). `gapPotential`'s density measure for `densityRule` is task 464's, genuinely open, and not this task's to attempt. `Decidable (Derivable .ZTime [] φ)` by the witness-family route is task 412's, not this one's (verified: `Decidable (Derivable` has zero occurrences anywhere in `FormalSystem/`).

DONE WHEN: (a) and (b) are landed unconditionally; the semantic lift's consequence is stated and proved at all four of `Base`, `Dense`, `ZTime`, `RTime` with no hypothesis standing in for its own forward direction; the L-E3 cross-check fixture is wired and green; sorry-free and axiom-clean outside Boneyard; `lake build` green.

VERIFICATION NOTE (2026-10-03, this revision). Every declaration name, type, axiom set and path cited above was re-derived from the tree by `#check`/`#print axioms`/`#print` under `import FormalSystem`, plus grep, not taken on trust. Three things the sources named did not survive that check and were corrected here: the grounding report path (archived under `specs/archive/165_.../`); the four frame classes (constructors are `Base`/`Dense`/`ZTime`/`RTime`); and the namespace of the L-E3 target (`...Decidability.WitnessFamilyExamples.phiPos`, which does not resolve as `...Decidability.phiPos`). Line-number citations were replaced by declaration names and section headings throughout, since the previously cited lines had drifted.

---

### 429. Repair truth lemma side conditions boxanchored and temporalwitness
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 428
- **Parent**: Task 165

**Description**: Repair the truth-lemma side conditions. Owns obstructions O2 and O3 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md. THIS IS THE TASK WITH GENUINE OPEN MATHEMATICS IN IT and should be budgeted accordingly.

READ FIRST: specs/418_*/artifacts/boxanchored-finding.md -- it carries the measurement, the full carrier list, and the repair options. Then TruthLemma.lean:399-404 and BoxSaturation.lean:430-435, :574-580.

O2 -- `hBA` (`boxAnchoredCheck`) is no longer dischargeable on multi-world branches. BoxSaturation.lean:430-435: the two copy blocks "have since been removed as unsound ... They were the ONLY route by which T(G phi)/T(H phi) could reach a freshly minted world ... `boxAnchoredCheck` is therefore expected to compute `false` on multi-world branches now." :574-580: "a caller can no longer expect to discharge that hypothesis from a real run." TruthLemma.lean:399-404 names the repair as "an open design decision with its own soundness obligations" and lists THREE candidate routes: (a) propagate T(box phi) itself; (b) copy T(G phi)/T(H phi) only when box-derived; (c) restructure the `box` case to need no anchor.

CRITICAL CONSTRAINT: this was caused by task 418 (completed) removing a GENUINE UNSOUNDNESS. It is the cost of a correct fix, not a regression to revert. TruthLemma.lean:404 says "Do NOT reinstate the removed copies." Any repair must re-establish the anchor WITHOUT reinstating them.

O3 -- `hTW` (`temporalWitnessCheck`) is no longer dischargeable on any branch carrying a negative until with a known future time. TemporalWitnessProbe.lean:66-73: `untlNegFuture` demands F(event) at every known future time of every negative until; the PASSIVE arm's branch 1 was the ONLY producer of `not event` at an EXISTING time; that arm was retired as unsound (user-authorized rank 2), so the producer is gone. Measured cost: fourteen probe rows moved check=true -> check=false; the accepted set went from EIGHT rows to SIX (rows A, B, C, D, E, F; I and K left). :86-88: "it was already `false` on the branches the engine actually builds. What it removes is the last set of hand-built branches on which the hypothesis was discharged."

DO NOT REOPEN (settled by 165): guardWitnessed in any variant; restoring sat_untl_neg / sat_snce_neg (they are FALSE against the current engine, not merely unproved); reinstating the retired PASSIVE arms or the removed box copy blocks.

GOAL: choose among the three documented BoxAnchored repair routes and land it with its soundness obligations discharged; and re-establish a producer for `not event` at existing future times. Both must hold on branches the engine ACTUALLY builds, measured by the probes, not on hand-built branches.

DONE WHEN: `boxAnchoredCheck` and `temporalWitnessCheck` are dischargeable on real engine output for the relevant branch classes, evidenced by probe rows moving back to check=true; no unsound copy block or retired arm is reinstated; lake build green.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- RECOMMENDED ROUTE, NAMED UP FRONT: of the three O2
repair routes listed above, route (a) -- propagate T(box phi) itself to the fresh world -- is the
RECOMMENDED route (per specs/reviews/review-2026-08-24.md amendment 10a and the box-anchor
artifact's own §5), so a dispatch need not re-derive the recommendation from
boxanchored-finding.md each time. It follows the S5 axiom-4/5 pattern, carries its own RuleSound
obligation, and has named fuel/termination consequences that Fuel.lean's bounds and the
subformula property must absorb -- all as already detailed in that artifact. Route (b) remains
available but reduces to route (a)'s obligation once branch provenance is tracked, per the
artifact. Route (c) stays recorded as CLOSED AS FORMULATED (boxGridCheck fails for the same
structural reason the anchor does, so weakening only the anchor buys nothing) -- do not
re-attempt it. This addendum names a recommendation; it does not narrow the task's own account of
all three routes and their obligations above, which stands as written.

Reconciliation note (task 629): task 634 (language-extension directories and probe tests) relocates this task's cited Tests/BimodalTest/TemporalWitnessProbe.lean to Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean (added to this task's file_scope above). No dependency edge in either direction: at execution time, check whether task 634 has landed and adjust the path accordingly.

POST-RELOCATION NOTE (2026-09-21). Task 634 has landed and moved Tests/BimodalTest/TemporalWitnessProbe.lean to Tests/BimodalTest/Metalogic/Decidability/TemporalWitnessProbe.lean together with the other seven probe files and TableauConformance.lean, with no follow-up move outstanding (this task was not_started with no uncommitted work under Tests/ when 634 checked). This task's file_scope already names the new path; any mention of the old path in the description above is historical.

---

### 428. Engine totality at a quantified branch budget
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 465
- **Parent**: Task 165
- **Summary**:
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/02_lexicographic-splitordered-measure-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/01_budget-totality-engine-repair-summary.md]
  - [428_engine_totality_at_a_quantified_branch_budget/summaries/04_ordtimesknown-strengthening-totality-summary.md]
- **Research**:
  - [428_engine_totality_at_a_quantified_branch_budget/reports/03_phase11-potential-obstruction.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/04_witness-preservation-machine-checked.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/01_budget-totality-refuted-and-repair.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/02_splitordered-measure-blocker.md]
  - [428_engine_totality_at_a_quantified_branch_budget/reports/05_spawn-analysis.md]
- **Plan**: [428_engine_totality_at_a_quantified_branch_budget/plans/06_residual-verdicts-and-closability.md]

**Description**: Engine totality at a quantified branch budget. Owns obstruction O1 of the Phase 7.3 deadlock recorded in specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md section "The four obstructions" (read it first; do not re-derive the refutation).

THE REFUTED THEOREM, SETTLED: `buildTableau_isSome` in unconditional form is FALSE, not merely unproved, and is on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine SIGNATURE, not a proof difficulty: `buildTableau` (Saturation.lean:928-951) calls `expandBranchWithFuel` at the default `maxBranches := 50000` (Saturation.lean:590), whose first line is `if branchesUsed >= maxBranches then none` (:594). A formula exploring more than 50000 branches returns `none` at ANY fuel whatsoever. Independently, `buildTableau`'s last arm returns `none` on a still-unsaturated branch (:950). Neither is fuel exhaustion, so no fuel figure rules them out. DO NOT attempt the unconditional form.

WHAT LANDED INSTEAD, and why it is unusable as-is: Verified/Termination/Fuel.lean:1587-1598 carries two hypotheses -- `(hP : NoSplit P fc)` and `(hbud : branchesUsed + fuel <= maxBranches)`. `NoSplit` excludes impPos, orPos, untlPos, untlNeg, sncePos, snceNeg, orderTrichotomy and every frame-class-gated splitting rule, i.e. it holds only on non-branching runs. 165's plan:1467-1468 records "Residual 2 (branching arms) -- isolated, not discharged."

GOAL: add a `maxBranches`-parameterised entry point ALONGSIDE `buildTableau` -- an ADDITION, never an edit to the existing default, because `maxBranches = 50000` is a deliberate runtime guard -- and prove totality against a quantified budget. Target shape:

  theorem buildTableau_isSome_of_budget (phi : Formula) (fc : FrameClass)
      (maxBranches : Nat) (hmb : <bound in phi> <= maxBranches) :
      (buildTableauAt phi (soundFuel' phi) fc maxBranches).isSome = true

THREE SUB-OBLIGATIONS:
1. Discharge the branching-arm residual that `NoSplit` currently hypothesises (Fuel.lean:1587, Saturation.lean:661-664, :686-689).
2. Supply the missing WORLD-COUNT dimension. 165's plan:1484-1488: "T1 bounds formulas and T2 bounds times; neither bounds worlds ... as defined, `soundFuel' = 2*n*2^(2n)` has no world factor at all." A branch bound that ignores worlds cannot bound branches.
3. Establish the `<bound in phi> <= maxBranches` side condition in a form callers can actually discharge.

COORDINATION: overlaps task 426's hypothesis (b) on the same file (Fuel.lean). Sequence with 426 or merge; do not both edit Fuel.lean concurrently. Task 412 consumes this theorem in place of the refuted `buildTableau_isSome`.

DONE WHEN: the budget-parameterised totality theorem is landed sorry-free with no `NoSplit` hypothesis, lake build green, and the world dimension is either supplied or its absence is proved harmless.

RETARGET DECISION (user-approved, post-research): the specified unconditional target shape is refuted (see reports/01_budget-totality-refuted-and-repair.md). Task WIDENED to own the validated certificate repair: swap findUnexpanded -> findUnexpandedUnblocked at resolveOpenArm's two decision points, discharge the accompanying soundness obligation on what .hasOpen certifies (shared with O2/O3), lift the proved saturateBlocked_isSome asset, close the world dimension via worldFuel'/WorldWitness, and land the budget-parameterised totality theorem against the repaired engine. The per-path budget finding (maxBranches >= 3*fuel linear invariant) supplies the side condition.

SECOND RETARGET DECISION (user-approved, post-research 03). The per-step framing of Phase 11 cannot be closed: reports/03_phase11-potential-obstruction.md section 4 is a proof about the SHAPE of the argument, not a report of a failed attempt. Route (a) (a lower bound on branch cardinality after identification) is DEAD by definition -- `Branch.identifyTime = (b.map relabel).eraseDups`, so all shrinkage comes from eraseDups and is bounded only by |U|. Route (b) (an independent mint bound) is the APPROVED path.

THE CHEAPER ALTERNATIVE IS EXPLICITLY REJECTED BY THE USER: do NOT carry the mint bound as a hypothesis in the shape `hT` has, and do NOT push the discharge obligation onto task 412. Do it the right way.

APPROVED WORK (route (b), ~6-7 phases, comparable in size to everything landed so far):
1. WITNESS PRESERVATION (~3 phases): the eight-rule case analysis of report 03 section 3 step 4, resting on the three lemmas already machine-checked in that report's section 1 (`mem_futureOf_of_mem_constraints`, `mem_pastOf_of_mem_constraints`, `identifyTime_no_collapse`).
2. RESTATEMENT (~1 phase): give `expandBranchWithFuel_isSome_of_budget` an explicit MINT-BUDGET PARAMETER, in the shape `branchesUsed`/`maxBranches` already establishes. This is what converts route (b)'s amortized bound into something the induction can carry; a per-step potential over (b, ord) provably cannot express it (report 03 section 4), and `maxTime` was checked and is not a usable proxy (arm 3 can lower it).
3. AMORTIZED INDUCTION (~2-3 phases): #mints <= 8*|U|; #identifications <= |knownTimes|_0 + #mints; total shrinkage <= #identifications * |U|; #extensions <= |U| + total shrinkage; then the terminus `buildTableauAt_isSome_of_budget`.

RESEARCH GATE -- MACHINE-CHECK BEFORE PLANNING. Report 03 marks two load-bearing claims UNCERTAIN, and the whole mint bound rests on both:
  (i) section 3 step 4, witness preservation across `.splitOrdered` arm 3 -- ARGUED, NOT MACHINE-CHECKED. The two modal rules are trivial (their witness sits at the same time as `sf`, so identification moves both together); THE SIX TEMPORAL ONES NEED THE REACHABILITY TRANSPORT and were not verified.
  (ii) section 3 step 3, "formulas are never deleted" -- read off the rule shapes, consistent with the landed `expandOnceUnblocked_card_lt` / `expandOnceUnblocked_split_card_lt`, but NOT PROVED.
Machine-check BOTH before any plan is written. This task has twice had a plan rest on an unverified lemma that later turned out FALSE (the unconditional `buildTableau_isSome`; then the `.splitOrdered` cardinality twin). A third occurrence is not acceptable. If witness preservation fails for any temporal rule, ROUTE (b) IS DEAD and that is a THIRD retarget decision requiring human approval -- report it plainly, do not work around it and do not substitute a weaker statement.

PRESERVED, DO NOT RE-PROVE: phases 1-10 of plans/02_lexicographic-splitordered-measure.md are landed, sorry-free, axiom-free, and green repo-wide. Consume those declarations. `buildTableau`, its `fuel := 1000` default, and `expandBranchWithFuel`'s `maxBranches := 50000` default stay BYTE-IDENTICAL. No `NoSplit` reintroduction; no admitted `WorldWitness` or `hT`; no `sorry`; no narrowing a statement into vacuity. The refuted unconditional `buildTableau_isSome` and the refuted `.splitOrdered` cardinality twin stay on the do-not-re-attempt register. `resolveOpenArmCancellable` in CancellableExpansion.lean remains a DECLARED, deliberately-unrepaired out-of-scope divergence. Task 412 must not be planned against `buildTableauAt_isSome_of_budget` until it lands; the Phase 3 assets (`BudgetedTableau`, `buildTableauAt`, `BudgetedTableau.upgrade`) are available and sorry-free meanwhile.

RESUME SEQUENCE: `/research 428` first (discharge the two uncertain claims above), then `/orchestrate 428`. The stale loop guard from the prior invocation has been removed so a restart gets a fresh cycle budget.
REALIGNMENT ADDENDUM (task 468, 2026-08-25) -- ASSESS-AND-C9-REGISTER ESCAPE CLAUSE FOR THE
SPLIT-ARM FUEL SCALING PROBLEM: the opening "THE REFUTED THEOREM, SETTLED" paragraph above is
unaffected by this addendum and gets a CURRENT verdict on that point -- do NOT touch it.

`Fuel.lean:1595-1610` documents that fuel adequate for a split run scales like
`beta ^ depth * worldFuel'`, and depth is not bounded by anything proved in that file -- this is,
in its own words, "a real property of a deliberate engine policy, not a gap in a proof," of the
same class as the already-settled `buildTableau_isSome` refutation. If, in the course of this
task's approved route (b) work, the split-arm fuel-adequacy question proves genuinely unclosable
as specified -- i.e. no depth bound can be established or supplied without weakening the engine's
own proportional-fuel policy -- the correct deliverable is an explicit ASSESS-and-C9-register
outcome: name the specific obstruction, add a C9 register entry (in
`Verified/Termination/MintBound.lean`, alongside its other entries) stating precisely which
theorem still carries the split-arm scaling exposure and under what hypothesis, and stop there.
This is a VALID, COMPLETE outcome for this sub-question -- do not treat "close it" as the only
acceptable result, and do not force a proof past this obstruction by weakening `NoSplit`,
reintroducing a hypothesis this task's own do-not-re-attempt register forbids, or narrowing a
statement into vacuity.

---

### 412. Prove refutation core and decidability of provability with completeness corollaries
- **Effort**: 10-15 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 410, Task 411, Task 428, Task 430
- **Parent**: Task 165

**Description**: Track B finish for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.1, 8.3, 8.5). Create Verified/Refutation/Core.lean proving allClosed_derivable as ONE induction over allRulesForFC fc, discharging each rule by its admissibility lemma (predecessor tasks) and its ruleFrameClass r <= fc hypothesis via the RuleSpec GATE lemmas — Dense/Discrete/Dedekind instantiate the generic theorem, they do not re-prove it. Then Verified/Provable.lean: Decidable (Derivable fc [] phi) combining allClosed_derivable with Track A's buildTableau_isSome and not_valid_of_hasOpen; the completeness corollaries ValidFor fc phi -> Derivable fc [] phi [PHANTOM NAME -- see STALE REFERENCES addendum below]; supply the Dedekind engine consumed by completeness_dedekind_of_engine (StrongCompleteness.lean:308, target ValidDedekindDense) [PHANTOM NAME -- see STALE REFERENCES addendum below]. Acceptance: zero sorries repo-wide outside Boneyard; lake build green; update typst/latex decidability chapters to record headline result 2.
RE-SCOPING ADDENDUM (2026-07-29, supersedes the buildTableau_isSome reference above): the scope text above depends on "Track A's buildTableau_isSome", which task 165 proved FALSE and placed on a do-not-re-attempt register (165's plan 01_tableau-decidability-two-track.md:1405-1420, :1489-1493). The refutation is a property of the engine signature, not a proof difficulty: buildTableau returns none whenever a formula explores more than maxBranches := 50000, at ANY fuel. Consequently this task's acceptance criterion "zero sorries repo-wide outside Boneyard" was UNREACHABLE AS SCOPED, independently of task 165's own status.

CORRECTED DEPENDENCE: consume the budget-parameterised totality theorem from task 428 (engine_totality_at_a_quantified_branch_budget) -- shape `buildTableau_isSome_of_budget phi fc maxBranches (hmb : <bound in phi> <= maxBranches)` -- in place of the unconditional buildTableau_isSome. Task 428 has been added as a predecessor. Do NOT attempt the unconditional form yourself.

ALSO NOTE: this task inherits obstructions O2 and O3 (the boxAnchoredCheck and temporalWitnessCheck truth-lemma side conditions) from Phase 7.3 of task 165 by way of not_valid_of_hasOpen. Those are owned by task 429. If your induction reaches a point where a truth-lemma gate hypothesis must be discharged on real engine output, that is 429's work, not this task's -- record it and coordinate rather than re-deriving it. Grounding for all of this: specs/165_establish_semantic_finite_model_property/reports/09_phase7-deadlock-blocker-research.md.

REALIGNMENT CORRECTION (task 468, 2026-08-25): the struck clause above ("discharge the
pre-existing sorry countermodel_discrete at Transfer.lean:1242") is STALE. That sorry no longer
exists -- countermodel_discrete is CLOSED, via tasks 477/478/479's k-equivalence/groupable-
companion route, and now lives sorry-free in
FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean, not Transfer.lean. Verified
fresh by scripts/check-module-invariants.sh C2/C3 at realignment time: C3 reports zero live
structural sorries tree-wide; C2 reports BXCanonical.completeness axiom-clean
([propext, Classical.choice, Quot.sound]). This task's remaining scope (allClosed_derivable, the
Decidable (Derivable fc [] phi) instance, the completeness corollaries, the Dedekind engine) is
UNCHANGED and still open.

New task 482 (discharge_proof_extraction_completeness, dependencies: [412]) is the owner of
eliminating .extractionFailed as a live outcome on a genuinely closed tableau -- it is gated on
this task's allClosed_derivable induction as a prerequisite and consumes it once landed. This
task's own acceptance criteria are unchanged by 482's existence; 482 is a downstream consumer,
not an addition to this task's scope.

DECIDABILITY-HALF NARROWING (2026-10-03, scope spec Section G item 2 of
specs/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md). This revision narrows
the decidability half of this task only. The refutation half -- Verified/Refutation/Core.lean and
allClosed_derivable -- is untouched and remains this task's core.

THE Z-TIME CLASS LEAVES THIS TASK. `Decidable (Derivable FrameClass.ZTime [] phi)` -- one of the
four frame classes the `Decidable (Derivable fc [] phi)` deliverable above was filed to cover --
is a FEW-LINE COROLLARY of a route that has already landed independently of the tableau spine, and
is being filed as its own follow-up task (scope spec Section H3) rather than done here. The route,
each declaration re-verified against the tree at revision time:

  - `FormalSystem.Metalogic.soundness_ztime_valid {phi : Formula}
    (d : DerivationTree FrameClass.ZTime [] phi) : ValidZTime phi`
    -- FormalSystem/Metalogic/Soundness.lean:1522.
  - `FormalSystem.Metalogic.BXCanonical.derivable_of_validZTime (phi : Formula) :
    ValidZTime phi -> Derivable FrameClass.ZTime [] phi`
    -- FormalSystem/Metalogic/BXCanonical/Completeness.lean:394.
  - Together these give `Derivable FrameClass.ZTime [] phi <-> ValidZTime phi`. `Derivable fc G p`
    is `Nonempty (DerivationTree fc G p)` (FormalSystem/ProofSystem/Derivable.lean:69), so the
    soundness direction is applied under a `Nonempty` elimination (the `h.elim fun d => ...`
    pattern already used at FormalSystem/Metalogic/StrongCompleteness.lean:309) -- still a few
    lines, not a new proof.
  - `decidable_of_iff` against
    `FormalSystem.Metalogic.Decidability.Compression.decidableValidZTime (phi : Formula) :
    Decidable (ValidZTime phi)`
    -- FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean:147, a `def`
    and deliberately not an `instance` -- finishes it.

UNWRITTEN, NOT ALREADY DONE. `grep -rn --include='*.lean' 'Decidable (Derivable' FormalSystem/`
returns zero hits at revision time; the only tree-wide match is the "not built" row at
FormalSystem/Metalogic/Decidability/Verified/README.md:62. So the corollary is genuinely unwritten.
Do not treat it as landed -- and do not write it here either, since it belongs to the Section H3
follow-up.

THIS TASK'S REMAINING DECIDABILITY CONTENT is therefore the OTHER THREE frame classes -- Base,
Dense and RTime -- plus the completeness corollaries through the tableau. The tableau spine remains
the only route FILED for Base, Dense and RTime; that is not the same as being the only route to any
decidability result. Two verified refinements of what "the other three classes" means:

  - At RTime the biconditional is already available by the same canonical-model route, not only by
    the spine: `FormalSystem.Metalogic.soundness_rtime_valid` (Soundness.lean:1565) and
    `FormalSystem.Metalogic.BXCanonical.completeness_rtime_engine (psi : Formula) :
    ValidRTime psi -> Derivable FrameClass.RTime [] psi`
    (FormalSystem/Metalogic/BXCanonical/CompletenessDedekind.lean:598). The open ingredient at
    RTime is therefore a decision procedure for `ValidRTime`, not the biconditional.
  - No `Decidable (ValidRTime ...)`, `Decidable (ValidDense ...)` or `Decidable (Valid ...)`
    declaration exists anywhere in FormalSystem/ at revision time (grep, Lean files only), so
    Base, Dense and RTime have no decision procedure for validity by any route today.

NEITHER THIS TASK NOR THE SPINE DELIVERS THE FIRST DECIDABILITY THEOREM. Z-time validity of the
base language is already decided by `Compression.decidableValidZTime`, with its qualifiers, which
every statement of the result must carry: frame class `FrameClass.ZTime` ONLY; `phi : Formula`, the
base language with no stability operator; EMPTY premises. The empty-premise consequence form
`FormalSystem.Metalogic.Decidability.decidableSemanticConsequenceNil (sigma : Formula) :
Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime [] sigma)` sits beside it at
Compression/Assembly.lean:161, also `Gamma = []` only. Nothing in any of this licenses an
unqualified "TM is decidable" claim, and NO COMPLEXITY BOUND is asserted or implied -- do not write
one into the Typst or LaTeX decidability chapters, and do not drop the ZTime / `Formula` /
empty-premise qualifiers when recording the result there.

REFUTATION HALF UNCHANGED. Verified/Refutation/Core.lean proving `allClosed_derivable` as ONE
induction over `allRulesForFC fc` (`FormalSystem/Metalogic/Decidability/Tableau.lean:1657`),
discharged per rule by its admissibility lemma and its `ruleFrameClass r <= fc` hypothesis through
the RuleSpec GATE lemmas, with Dense/Discrete/Dedekind instantiating the generic theorem rather
than re-proving it, is untouched scope and still the core of this task. Neither target file exists
yet: FormalSystem/Metalogic/Decidability/Verified/ currently holds `Bridge/`, `Decidable.lean`,
`README.md`, `RuleSpec.lean` and `Termination/`, with no `Refutation/` subdirectory and no
`Provable.lean`. Task 482 remains a downstream consumer of `allClosed_derivable`, not an addition
to this scope. The budget-parameterised totality correction (task 428) and the O2/O3 ownership
assignment (task 429) in the addenda above both stand.

STALE REFERENCES IN THE ORIGINAL SCOPE TEXT, now marked PHANTOM NAME inline above (sweep
task, 2026-10-04 revision) rather than left as a standing flag -- the names below were never
corrected at their point of citation in the first paragraph, which is itself the defect this
sweep targets. Three names the first paragraph cites could NOT be verified in
FormalSystem/**/*.lean at revision time: `completeness_dedekind_of_engine`, `ValidDedekindDense`,
and `ValidFor` (used in the phrase "completeness corollaries ValidFor fc phi -> Derivable fc
[] phi"). `completeness_dedekind` and `ValidDedekind` are likewise absent from Lean sources and
survive only in prose at FormalSystem/Metalogic/README.md, FormalSystem/Metalogic/BXCanonical/
README.md and FormalSystem/Metalogic/WeakCanonical/RealModel/README.md -- all three corrected by
the same sweep to cite their own live replacements rather than repeating these names. The cited
anchor StrongCompleteness.lean:308 is inside `soundness_consequence`, not a Dedekind engine.

RE-VERIFIED 2026-10-04, SHARPER MATCH FOUND. `completeness_dedekind_of_engine` has a precise
renamed counterpart, not just a "nearest" one: `completeness_rtime_of_engine`
(`FormalSystem/Metalogic/StrongCompleteness.lean:729`), signature
`(engine : WeakCompleteness FrameClass.RTime) (phi : Formula) (h : ValidRTime phi) :
Derivable FrameClass.RTime [] phi` -- the exact `_of_engine` shape the phantom name was reaching
for, with `ValidRTime` (`FormalSystem/Semantics/Validity.lean:655`) standing in for the phantom
`ValidDedekindDense`/`ValidFor`. Its engine hypothesis is discharged unconditionally by
`completeness_rtime_engine` (`CompletenessDedekind.lean:598`), consumed in turn via
`countermodel_dedekind_dense` (`CompletenessDedekind.lean:325`). Whoever picks this task up
should state the completeness corollaries against `completeness_rtime_of_engine`'s pattern at
RTime, and its `ValidZTime`/sibling analogues at the other three frame classes, rather than
re-deriving the shape from scratch.

---

### 411. Prove hard admissibility lemmas for until since trichotomy discrete and dedekind rules
- **Effort**: 15-20 hours
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 410
- **Parent**: Task 165

**Description**: Track B part 2 for the TM tableau decidability program (parent: task 165; grounding: reports/02_tableau-decidability-hard-research.md sections 3.2-3.3 and 10). First run a /literature acquisition pass for Reynolds 1992 and Reynolds 2003 (the untlNeg co-decomposition and the Dedekind gap axioms; report 02 section 10 flags in-repo literature as thin). Then prove the hard admissibility block in Verified/Refutation/Rules/{UntilSince,Trichotomy,Discrete,Dense,Dedekind}.lean: untlPos (branch 1 via until_F, branch 2 via self_accum_until — follow the axiom literally), untlNeg (Reynolds co-decomposition via absorb_until + left_mono_until_G; the single largest lemma — budget it its own dispatch), sncePos/snceNeg duals, orderTrichotomy (one-liner if Phase 2.2 kept branches syntactically equal to temp_linearity disjuncts — verify, do not assume), z1Rule (two-premise instance of z1 + two modus ponens, relies on same-label internalization from the predecessor task), densityRule/denseIndicatorClosure via density/dense_indicator, and the Dedekind rules via prior_U_gap/prior_S_gap/sep. Acceptance: all admissibility lemmas sorry-free; lake build green.

---

### 410. Internalize tableau branches and prove routine rule admissibility
- **Effort**: 12-18 hours
- **Status**: [PLANNED]
- **Task Type**: lean4
- **Topic**: decidability
- **Dependencies**: Task 429
- **Parent**: Task 165
- **Research**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/reports/01_internalize-routine-admissibility.md]
- **Plan**: [410_internalize_tableau_branches_and_prove_routine_rule_admissibility/plans/01_internalize-routine-admissibility.md]

**Description**: Track B part 1 for the TM tableau decidability program (parent: task 165, plan plans/01_tableau-decidability-two-track.md, research reports/02_tableau-decidability-hard-research.md sections 3.1-3.4). Create FormalSystem/Metalogic/Decidability/Verified/Internalize.lean defining Branch.internalize (world labels via box/diamond nesting, time labels via U/S guards realizing the branch TimeOrdering; SETTLED constraints: internalization design over substitution — no cut or uniform-substitution admissibility exists in the tree — and z1Rule's two premises must stay at the same label). Then prove the routine admissibility lemmas in Verified/Refutation/Rules/{Propositional,Modal,Temporal}.lean (~21 lemmas: 8 propositional, 4 S5 modal, 1 boxTemporal, 8 temporal universal/existential), each stated as rule_admissible per report 02 section 3.1 with hypothesis ruleFrameClass r <= fc, reusing Combinators.lean, ModalS5.lean, TemporalDerived.lean, GeneralizedNecessitation.lean, and DeductionTheorem.lean via DerivationTree.lift. Acceptance: all lemmas sorry-free, lake build green, RuleSpec GATE lemmas still green.

---

### 298. Fix c7 labeling bug and regenerate dataset
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [298_fix_c7_labeling_bug_and_regenerate_dataset/reports/01_c7-labeling-bug.md]
- **Plan**: [298_fix_c7_labeling_bug_and_regenerate_dataset/plans/01_c7-labeling-bug.md]
- **Summary**:
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]
  - [298_fix_c7_labeling_bug_and_regenerate_dataset/summaries/01_c7-labeling-bug-summary.md]

**Description**: Fix c7 labeling bug at formula ~13750 that causes unbounded memory growth in the decision procedure's timeout handling, then regenerate the full c7 dataset. During task 297 dataset regeneration, all 3 attempts to generate c7 stalled at exactly record 13,749 with RSS growing ~40MB/6s. The labeling function enters an apparent infinite loop or unbounded search for formula #13,750 in the sorted enumeration order. The timeout mechanism either does not fire or cannot interrupt the stuck state. Steps: (1) Identify the specific formula at position ~13,750 in the c7 enumeration. (2) Reproduce the hang in isolation with that formula. (3) Diagnose whether the decision procedure's timeout is failing to fire or the procedure is in an uninterruptible state. (4) Fix the timeout handling so it reliably terminates. (5) Regenerate the full c7 dataset (target: 77,272 records)

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25). Tasks 231, 282 and 296 depend on this task.

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task. Replaced with the specific paths this task actually touches per its own description (fixing the c7 labeling/timeout bug in the dataset generator and regenerating c7): BimodalTools/DatasetGenerator.lean, Tests/BimodalToolsTest/DatasetGeneratorTest.lean. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 296. Re add derived binary operators with dedup fix
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Research**: [296_re_add_derived_binary_operators_with_dedup_fix/reports/01_derived-binary-operators.md]
- **Plan**: [296_re_add_derived_binary_operators_with_dedup_fix/plans/01_derived-binary-operators-plan.md]
- **Summary**: [296_re_add_derived_binary_operators_with_dedup_fix/summaries/01_derived-binary-operators-summary.md]

**Description**: Re-add the 6 derived binary temporal operators (release, weak_until, trigger, weak_since, strong_release, strong_trigger) to the formula enumerator, adjusting canonicalization and/or the passesFilter gate so they survive deduplication and appear in the unique pipeline output. These operators were removed in task 295 because they inflated the enumeration space by ~40-60% without contributing unique formulas — their canonical representations collapsed with primitives. Potential approaches: (1) skip canonicalization for formulas containing derived binary operators, (2) canonicalize to the derived form instead of the primitive form, (3) lower or remove the passesFilter complexity gate for these operators, (4) add a fold-aware dedup stage that treats release(p,q) as distinct from neg(untl(neg p, neg q)). The goal is to have all 13 derived operators represented in the final dataset.

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25).

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task. Replaced with the specific paths this task actually touches per its own description (re-adding the 6 derived binary temporal operators to the enumerator/canonicalizer): BimodalTools/FormulaEnumerator.lean, BimodalTools/AtomCanonicalization.lean, Tests/BimodalToolsTest/EnumeratorCountsTest.lean. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 282. Exhaustive enumeration by default
- **Status**: [PARTIAL]
- **Task Type**: lean4
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298
- **Plan**: [282_exhaustive_enumeration_by_default/plans/01_exhaustive-enumeration-plan.md]
- **Research**: [282_exhaustive_enumeration_by_default/reports/01_exhaustive-enumeration-default.md]
- **Summary**: [282_exhaustive_enumeration_by_default/summaries/01_exhaustive-enumeration-summary.md]

**Description**: Flip complexity-9 dataset generation from stratified to exhaustive-by-default once feasibility is confirmed. Prior work (see plans/01_exhaustive-enumeration-plan.md, handoffs/phase-1-6-handoff-20260714.md) verified the 0-sentinel/.take-guard machinery is already correct and unlimited-capable, and corrected stale infeasibility claims in data/README.md and scripts/run_dataset_generation.sh. The next action is the deferred c9 feasibility probe (Plan Phase 2), followed -- pending a GO verdict and explicit user approval for the multi-hour compute -- by c8/c9 exhaustive regeneration and HF Hub republication (Phases 3, 4(rest), 5, 6(rest), 7).

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the 25 tooling modules (DatasetGenerator, DatasetAssembly, FormulaEnumerator, DataExport, ProofFirstBenchmark, the *Main exe roots and the rest) from FormalSystem/Automation/ to a root-level lean_lib BimodalTools, namespace BimodalTools, with tests under Tests/BimodalToolsTest/. This task's partial work was committed before the move (task 632 gated its move on a clean git status for FormalSystem/Automation/), so nothing was lost, but every path in this task's plan and handoff that names a tooling module is stale: re-derive before resuming. The library half (Tactics/, ProofSearch/, SuccessPatterns) stays under FormalSystem/Automation/. file_scope widened to include BimodalTools/ and Tests/BimodalToolsTest/. Build the tooling with lake build BimodalTools; a default lake build no longer compiles it, and a green lake build does not prove the exe roots compile (gate on the build-inclusive check-module-invariants.sh, C25).

SCOPE NARROWED (2026-09-28): file_scope's BimodalTools/, FormalSystem/Automation/ and Tests/BimodalToolsTest/ directory-wide entries were an inherited blanket widening from task 632's relocation note, not a derived surface for this task -- this task's own description names no BimodalTools/ module edit, only the deferred c9 feasibility probe and the dataset-generation mode flip. Dropped all three directory entries and added scripts/run_dataset_generation.sh, the mode-flip target this task's description names as its next action but never previously declared. Re-widen at this task's own research/plan time if the chosen approach implicates more files.

---

### 257. Large data storage huggingface
- **Status**: [BLOCKED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: None
- **Research**: [257_large_data_storage_huggingface/reports/01_large-data-storage.md]
- **Plan**: [257_large_data_storage_huggingface/plans/01_implementation-plan.md]
- **Summary**: [257_large_data_storage_huggingface/summaries/01_execution-summary.md]

**Description**: Complete the Hugging Face Hub migration for large dataset storage. Prior work (see plans/01_implementation-plan.md, summaries/01_execution-summary.md) removed Git LFS tracking from .gitattributes and rewrote data/README.md to point at HF Hub (logos-labs/bmlogic-bench) as the canonical source, but Phase 1 -- the actual upload to HF Hub via the existing data/hf-dataset/upload.py pipeline -- was never executed because it requires user HF authentication. This task is blocked on that credential; once supplied, run the upload, validate, and confirm data/hf-dataset/PUBLISHING.md's 'Migration Status' header reflects completion.

---

### 231. Dataset regeneration automation
- **Status**: [NOT STARTED]
- **Task Type**: general
- **Topic**: dataset-enhancement
- **Dependencies**: Task 298, Task 604

**Description**: Build comprehensive automation so that every dataset regeneration automatically updates all downstream artifacts and documentation fields. Supersedes task 227 scope. (1) Create data/scripts/sync-all.py master sync script that: (a) Scans all JSONL files and recomputes metadata JSON files (record counts, rule distributions, schema field lists, valid/invalid ratios, tier distributions, step statistics). (b) Updates specific fields in data/README.md: file inventory table (Records, Size columns), training record schema table (field count), proof steps statistics (records, theorems, rule distribution, steps per theorem), cross-logic split table (records, valid rates), NL paraphrase statistics. (c) Updates specific fields in data/dataset-card.md: overview table, all record counts, proof steps section, competitive position 'primary gaps' paragraph. (d) Recomputes SHA-256 hashes and contentSize for all distributions in croissant.json. (e) Regenerates bmlogic-bench-splits.json. (f) Validates all JSONL records against declared schemas (checks field presence, types, null patterns). (g) Checks train/benchmark formula overlap and reports contamination percentage. (h) Validates metadata key consistency (total_records not total_count). (2) Idempotent and safe to run after any regeneration command (lake exe dataset_generator, lake exe proof_extractor, lake exe benchmark_oracle, finalize_benchmark.py). (3) --dry-run mode that reports what would change. (4) --commit mode that creates structured git commit. (5) CI-friendly exit codes (0=clean, 1=staleness detected, 2=validation error). (6) Update data/README.md with pipeline documentation. (7) Integrate into agent context (.claude/context/project/dataset/) so /implement for dataset tasks runs sync-all as post-implementation step. Note: supersedes task 227 (dataset_pipeline_automation_croissant_sync) with broader scope covering README/dataset-card field updates and schema validation.
=== ITEM (7) TARGETS A DISPOSABLE DEPLOY ARTIFACT -- CORRECTED 2026-08-24 ===

Item (7) above says "Integrate into agent context (.claude/context/project/dataset/)". DO NOT WRITE
THERE. Verified 2026-08-24: `.claude/` in this repository is fully gitignored (`.gitignore:81`) with
zero tracked files, and is regenerated wholesale from a source store that is NOT in this repository
-- it lives at /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
`.claude/context/project/dataset/` will be silently destroyed on the user's next agent-system
reload.

Item (7) therefore CANNOT be completed from inside this repository. Two acceptable dispositions,
both of which require asking the user first:

  (a) DROP item (7) from this task's scope and record why. The other seven sub-targets of this task
      are ordinary repository work (`data/scripts/sync-all.py`, `data/README.md`,
      `data/dataset-card.md`, `croissant.json`, the splits file, schema validation, contamination
      check) and are unaffected. This is the recommended default -- it keeps the task in one repo.
  (b) Split item (7) into a task filed in the nvim repository's own tracker
      (/home/benjamin/.config/nvim/specs/state.json), targeting
      agent-system/extensions/<appropriate-extension>/context/, and committed there.

Do not silently satisfy item (7) by writing into `.claude/`.
=== ITEM (7) DROPPED FROM SCOPE -- 2026-08-24, user decision ===

Item (7) ("Integrate into agent context (.claude/context/project/dataset/) so /implement for
dataset tasks runs sync-all as post-implementation step") is REMOVED from this task's scope. It is
not a defect and not deferred -- it is out of scope here, permanently, and no successor task owns
it in this repository.

WHY. The disposition options recorded above were put to the user on 2026-08-24 and option (a) was
chosen. Three considerations decided it:

  1. `.claude/` here is gitignored (`.gitignore:81`, zero tracked files) and regenerated wholesale
     from /home/benjamin/.config/nvim/agent-system/, a separate git repo. A file written to
     `.claude/context/project/dataset/` is destroyed on the next agent-system reload.
  2. Filing it in the nvim tracker instead was considered and declined. There is no `dataset`
     extension in that source store (verified 2026-08-24: core, cslib, email, epidemiology,
     filetypes, formal, founder, latex, lean, literature, memory, nix, nvim, present, python,
     slidev, typst, web, z3), and a BimodalLogic-specific post-implementation hook placed in the
     shared global agent-system would deploy to every repository that loads it. It would have to be
     generalized into a repo-local hook mechanism first -- a different and larger piece of work
     than this task.
  3. The `.syncprotect` escape hatch (project root; honored by deploy-headless.sh and the picker's
     sync path) would survive a reload, but leaves the file untracked and unbacked-up in a repo
     where everything else is version-controlled.

WHAT REMAINS IN SCOPE. Items (1) through (6) and (8), unchanged and unaffected -- they are ordinary
repository work under `data/`: `data/scripts/sync-all.py`, `data/README.md`,
`data/dataset-card.md`, `croissant.json`, `bmlogic-bench-splits.json`, schema validation, the
train/benchmark contamination check, and the metadata-key consistency check. Do not treat the
removal of item (7) as reducing any of them.

IF THE HOOK IS WANTED LATER. `sync-all.py` is a plain script with CI-friendly exit codes (item 5).
Wire it from repository CI or run it manually after a regeneration. That reaches the same outcome
without depending on agent-system context at all.

POST-RELOCATION NOTE (2026-09-21). Task 632 moved the dataset tooling out of FormalSystem/Automation/ into a root-level lean_lib BimodalTools (outside defaultTargets) and re-rooted the 12 lean_exe targets under BimodalTools.*. The lake exe target NAMES are unchanged (benchmark_oracle, dataset_generator, proof_extractor and the rest), so command lines in this task still work, but every source path is now BimodalTools/<Module>.lean and every tooling test is under Tests/BimodalToolsTest/. A default lake build no longer compiles the tooling; build it with lake build BimodalTools.

---

### 178. Publication examples and demo
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 635, Task 641

**Description**: Expand Examples/ with publication-quality demonstrations of the full verified pipeline. Complete worked example showing soundness and completeness on a concrete formula, plus decidability of the propositional fragment (genuinely complete today, per the soundness/completeness metatheory's axiom-clean status). Examples exercising each frame class with FrameClass-parameterized DerivationTree. Examples of the expressive completeness result. Update BimodalProofs.lean and TemporalStructures.lean. All examples sorry-free.

REALIGNMENT CORRECTION (task 468, 2026-08-25, carried from specs/reviews/review-2026-08-24.md
amendment M-7, independently re-confirmed at realignment time): the struck original acceptance
criterion above ("Complete worked example showing soundness-completeness-decidability on a
concrete formula") is RESCOPED. Decidability of TM (the full bimodal logic) is still open --
re-confirmed fresh this dispatch: grep -rn "isValid" FormalSystem/Metalogic/Decidability/ shows no
declaration takes DecisionProcedure.isValid as its subject, and ruleSound_of_mem_allRulesForFC is
not lifted to any allClosed -> valid theorem. `truthAt_of_isValid`
(Verified/Decidable.lean:2412) is NOT evidence of decidability -- it concerns a different,
semantic-side `SoundnessLemmas.IsValid`, not the decision procedure's `DecisionProcedure.isValid`.
Do not cite it as such. This task's decidability example is therefore rescoped to the
propositional-fragment case (genuinely decidable today) rather than the full logic; a full-logic
decidability example remains gated on the decidability/tableau front (410-465,
480-482) landing.

Reconciliation note (task 629): depends on task 635 (Expressiveness extraction), which renames the Kamp-named results this task cites. Task 632 (BimodalTools split) also edits Examples/BimodalProofs.lean's imports; that overlap is covered transitively via task 635's own dependency chain (635 <- 634 <- {632,633}), so no separate edge to 632 is added here.

POST-RELOCATION NOTE (2026-09-21). Dependency 635 is complete. It moved 141 modules from FormalSystem/Metalogic/WeakCanonical/ to FormalSystem/Metalogic/Expressiveness/ with the namespace rename WeakCanonical.X -> Expressiveness.X (the Kamp development is at Metalogic/Expressiveness/Kamp/), renamed 12 paper-numbered files to content names, and deleted 2 declaration-free stubs. The old-to-new name table is in specs/635_expressiveness_extraction/summaries/01_expressiveness-extraction-move-summary.md: cite results by their new names. Kamp/Section5Correspondence.lean was deliberately NOT renamed, so that a reader searching 'Section 5' finds it. Task 636 then stripped Logos and ProofChecker wording and personal paths from FormalSystem/Examples/ docstrings and installed the ## References normal form (docs/development/REFERENCE_NORMAL_FORM.md, keys in the root references.bib): new example files follow it. Examples/BimodalProofs.lean and Examples/Walkthrough.lean now import specific Automation modules and not the aggregator, since the tooling half left for lean_lib BimodalTools.

---

### 177. Update readme and module docstrings
- **Status**: [NOT STARTED]
- **Task Type**: lean4
- **Topic**: formula-refactor
- **Dependencies**: Task 178, Task 282, Task 296, Task 298, Task 428, Task 429, Task 430, Task 464, Task 465, Task 481, Task 482, Task 534, Task 543, Task 568, Task 623, Task 628, Task 635, Task 636, Task 645, Task 646, Task 683, Task 684, Task 685, Task 696, Task 703, Task 706, Task 942

**Description**: Update README.md, docs/, and FormalSystem/ module-level docstrings to their final post-refactor state, once the decidability chain (426, 428, 429, 430, 432, 433, 434) lands. This is the final polish pass, distinct from and run after task 472's already-completed immediate correction pass. Explicitly excludes: every item task 472 already corrected (the Decidability.lean Status block, Verified/README.md, FMP/README.md, DecisionProcedure.lean's decideAuto docstring, Verified/Decidable.lean's Status docstring, WeakCanonical.lean, RealModel/ShuffleReal.lean, Soundness.lean, PriorExpressivenessDense.lean) and the two Kamp files task 473 already swept (Kamp/EANegationClosure.lean, NfMultiAnchorBridge/NavigatedSpine.lean). This task's residual content is: re-auditing all touched documentation for drift accumulated during the decidability chain's landing (472/473 audited a snapshot; the chain's remaining tasks will touch further files after 472/473 ran), and the Axiom Reference update the charter names as part of 177's original scope.

REALIGNMENT NOTE (task 468, 2026-08-25, verdict per specs/468_realign_task_programme_from_proof_state_audit/reports/02_stage1-verification-and-programme-realignment.md §6): DIVIDE, already half-executed exactly as specs/reviews/review-2026-08-24.md amendment 10f states -- tasks 472 (documentation correction pass) and 473 (Kamp vacuity deletion) already ran the ungated half; the description above is the remaining, gated half's text. `file_scope` (README.md, specs/ROADMAP.md, FormalSystem/, docs/) was already repaired by task 470 item (G) and is confirmed resolvable, no duplicate -- left unchanged here.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 530 (documentation single source of truth + theorem index, from specs/reviews/review-2026-09-01-lean-engineering.md) is the UN-GATED metalogic half of this charter and is now a dependency; this task remains the gated post-decidability-chain pass and its residual shrinks to re-auditing drift the decidability chain introduces plus the Axiom Reference update.

Reconciliation note (task 629): gains dependencies on task 635 (Expressiveness extraction) and task 636 (docstring and citation normalisation), in addition to its existing 428/429/430 dependencies. Kept separate from task 636 rather than merged: this task's residual scope (re-auditing documentation drift the decidability chain introduces, plus the Axiom Reference update) is materially different from task 636's citation-form/bibliography normalisation work.

POST-RELOCATION REVISION (2026-09-21, after tasks 626, 630 and 632-636 landed). Dependencies 635 and 636 are complete. (A) PATHS CHANGED under this task's description: the archive is a root-level Boneyard/; 25 tooling modules left FormalSystem/Automation/ (and Metalogic/Decidability/TraceExport.lean) for a root-level lean_lib BimodalTools; FormalSystem/Tactic/ is new; Syntax/ and Semantics/{Plus,Minus,Star}Language/ merged into FormalSystem/{X}Language/ with flat FormalSystem.{X}Language namespaces; 141 modules moved from Metalogic/WeakCanonical/ to Metalogic/Expressiveness/ (Kamp/, Separation/, GameTransfer/, EFGames/ are there now) and 12 files took content names. The Kamp files named in the exclusion list above live under Metalogic/Expressiveness/Kamp/. Re-derive every path. BimodalTools/ is in scope for module-docstring work; Boneyard/ is not. (B) CITATION FORM: write ## References in the normal form of docs/development/REFERENCE_NORMAL_FORM.md, each key resolving in the root references.bib; typst/bibliography.bib no longer exists. Historical and provenance statements are preserved verbatim, never rewritten to current paths (Semantics/TaskFrame.lean's 'Known gaps... recorded as closed' block, Metalogic/Soundness.lean's 'app:valid... never existed' block, Boneyard provenance READMEs, typst/SYNC-MAP.md, ADR histories). sub: anchors stay verbatim. (C) ITEMS FOLDED IN from the batch's recorded follow-ups, each outside the recording task's scope. Docstring and documentation edits only. (C1) FormalSystem/Theorems/TemporalDerived.lean's ### Removed section names two archive files that do not exist, Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean and Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean; both directories hold only a README.md. Repairing it needs knowledge of where those 27 definitions went; find out from git history. (C2) FormalSystem/Examples/TemporalStructures.lean:21 cites the JPL paper as 'The Perpetuity Calculus of Agency'; the paper this repository formalizes is 'The Construction of Possible Worlds'. Determine whether it names a different work; if the same, correct and cite by bibkey; if different, leave and report. (C3) BimodalTools/TraceExporterMain.lean carries a verbatim-duplicated leading module docstring (lines 16-49 repeated at 51-86, the second with one extra bullet); keep one copy with the extra bullet. (C4) Task-number citations survive in body prose outside ## References, notably Tests/BimodalTest/Automation/TacticsTest.lean's ## Test Coverage and ## Test Organization; the task-reference lint does not scan Tests/ or FormalSystem/, so they are ungated. Grep FormalSystem/, BimodalTools/ and Tests/ and replace each with a durable anchor. The lint lives under .claude/, a deploy artifact with no source store in this repository: do not edit it here; record the scan-root gap for an upstream fix. (C5) The 34 chunk_00NN citations in 15 files under FormalSystem/Metalogic/Expressiveness/Kamp/ (NfMultiAnchorBridge/ and neighbours) point into a corrupt markdown conversion. Kamp/Section5Correspondence.lean records that they 'should be re-cited by page as they are touched'. Re-cite by page from a sound copy of the source (run with --lit); where a page cannot be established, leave the citation and list it; never guess a page. (C6) FormalSystem/Metalogic/README.md's aggregator table has one '<!-- TODO: add description -->' for Deterministic.lean. (C7) docs/development/PUBLICATION_REFACTOR.md:476, the Phase 7 bullet, is still future-tense though task 636 closed that phase; past-tense it; line 597 stays verbatim, being a quoted task brief. (C8) USER DECISION, STILL OPEN, carried from task 636: at FormalSystem/Metalogic/Expressiveness.lean:67,69 the dangling keys stavi1979 and gabbay1980 were re-pointed to gabbay1994 (Ch.9 s.3 and Ch.10), a default the user never confirmed. The bibliography merge then brought in gpss1980 (Gabbay, Pnueli, Shelah and Stavi 1980), a plausible better match for the gabbay1980 site. Which source was intended is not derivable from the repository: ask the user; never author a bibliography entry whose details cannot be verified. SCHEDULING: C1-C8 do not depend on the decidability chain. If that chain stays open, split C1-C8 off with /task --expand instead of letting them wait.

SCOPE NARROWED (2026-09-21): file_scope previously named the whole of FormalSystem/ and docs/, which made every library task flag an overlap with this one at admission. It now names only the paths this description cites (C1-C8, the Axiom Reference, the decidability directory for the gated re-audit). The re-audit is open-ended by design: re-derive and widen file_scope at research time. Dependencies on 534, 543, 568, 628, 645 and 646 added because each also edits the root README.md and this task is the final pass that runs after them.

FURTHER EDGES (2026-09-21): dependencies on 178, 282, 296, 298, 464, 465, 481 and 482 added, each sharing a named path with this task (Examples/TemporalStructures.lean; BimodalTools/TraceExporterMain.lean; Metalogic/Decidability/). This task is the final pass and runs after them. Note 481 is blocked and 282, 296 and 298 are partial: if any of them is abandoned the edge is satisfied; if one stalls indefinitely, drop its edge rather than hold this task.

FURTHER EDGES (2026-09-28): the whole-directory FormalSystem/Metalogic/Decidability/ entry is retained, not narrowed, because this task's own description already defers that narrowing: "The re-audit is open-ended by design: re-derive and widen file_scope at research time." Narrowing it now, before the decidability chain lands, would be exactly the guessing this task's charter prohibits. scripts/validate-state.sh Check 8 currently reports this entry overlapping 8 non-terminal tasks (428,429,430,464,465,481,482,696); 7 of the 8 (428,429,430,464,465,481,482) were already dependency-gated. 696 was not -- it declares Decidability/PlusWitnessFamily/* and Decidability/WitnessFamily/Sharing/*, both under this directory -- so 696 is added to dependencies below to close that one real exposure. The existing "if one stalls indefinitely, drop its edge rather than hold this task" clause (see the 2026-09-21 FURTHER EDGES note above) extends to this new edge.

=== ADDENDUM (repo-health review, specs/reviews/review-2026-11-19.md) ===
README.md STRUCTURE-TREE DRIFT, folded in here rather than given its own task because this task already declares README.md in its file_scope and its residual scope is exactly "re-auditing all touched documentation for drift accumulated" after earlier passes.

The Project Structure diagram at README.md:103-138 omits three FormalSystem/ subdirectories that exist on disk: ForMathlib/, NomicLanguage/, and Tactic/. Every other entry in the tree matches reality.

This is drift accumulated SINCE the README correction recorded in specs/reviews/review-2026-08-25.md regenerated that tree from the filesystem -- Tactic/ is new (see this description's POST-RELOCATION REVISION note, which already records its creation), and the tree was not re-rendered when ForMathlib/ and NomicLanguage/ landed. It is not a regression of that earlier pass.

Fix: add the three directories to the tree with one-line descriptions matching the existing entries' style. ForMathlib/ in particular must not be omitted -- root CLAUDE.md and ORGANISATION.md both document it as a load-bearing subsystem (Mathlib-shaped extensions intended for upstreaming, importing nothing from FormalSystem.*), so its absence from the reader's map is a real gap rather than a stylistic one. Re-render the tree from the filesystem rather than hand-patching three lines, so any further drift is caught in the same pass.

Note: ORGANISATION.md is NOT stale on this point -- it already references Tactic/ and the other current subsystems. The drift is README.md's alone.

---

### 125. Jonsson tarski representation bimodal sus
- **Status**: [NOT STARTED]
- **Task Type**: formal
- **Topic**: algebraic-representation
- **Dependencies**: Task 498, Task 499

**Description**: CAPSTONE of the algebraic representation front. Prove the Jonsson-Tarski representation theorem for the bimodal logic: the embedding eta(a) = {U | a in U} is an injective STSA homomorphism A -> Cm(Uf(A)).

RE-SCOPED. This task's original four phases are now distributed: Phase 1 (complex algebra Cm(F)) and Phase 2 (ultrafilter frame Uf(A), including the Spherical obligation) are separately tasked and are this task's dependencies; Phase 4 (binary untl/snce operators) is separately tasked and depends on this one. What remains here is Phase 3 -- the embedding itself and its injectivity -- stated at the unary signature (box, G, H, sigma).

PREREQUISITE STATE, RE-VERIFIED 2026-08-26: the STSA class and the R_G/R_H/R_Box ultrafilter frame exist as Boneyard seeds behind #exit and are ported by the dependency tasks. The MCS-to-ultrafilter bijection is live at Algebraic/UltrafilterMCS.lean:782 (ultrafilter_correspondence), though stated existentially rather than as a named Equiv -- converting it to an Equiv may be worth doing here. The BooleanAlgebra LindenbaumAlg instance is at BooleanStructure.lean:421.

THE PRIOR PREREQUISITE LIST IN THIS DESCRIPTION IS STALE and is superseded: it named 'resolve 6 algebraic sorries in TenseS5Algebra/InteriorOperators/LindenbaumQuotient'. InteriorOperators.lean and LindenbaumQuotient.lean are sorry-free today; the remaining sorries are the 3 in the Boneyard TenseS5Algebra seed, and they are for REMOVED axioms (temp_a, temp_l) that must be restated against the current 45-constructor axiom set rather than proved as-is. That is the STSA port task's business, not this one's.

LITERATURE: Goldblatt 1989 'Varieties of complex algebras' (APAL 44, 173-242, doi 10.1016/0168-0072(89)90032-8) has been acquired. CAVEAT THAT MUST BE HONORED: the acquired PDF is an Acrobat 3.0 Capture scan with a badly degraded OCR text layer -- math-heavy pages yield mangled symbols, dropped and reordered lines. READ THE PAGE IMAGES DIRECTLY (the Read tool's pages parameter); do NOT rely on a pdftotext-derived conversion for any axiom statement or equation. Blackburn/de Rijke/Venema 2002 Chapter 5 (corpus entry blackburn_2002) is the primary reference and is born-digital.

MATHLIB HOOK: Order/Atoms.lean:710 (toSetOfIsAtom : alpha <-> Set {a // IsAtom a} for CompleteAtomicBooleanAlgebra) is the atom-structure half of Stone/Jonsson-Tarski for the complete atomic case and is the single most relevant Mathlib lemma here; supporting lemma eq_setOf_le_sSup_and_isAtom at :695. Mathlib has NO Stone duality for Boolean algebras and no BAO machinery -- the rest is greenfield.

SEE ALSO the reconciliation task on whether this embedding can be factored through ShiftSet.lean's reverse_repr rather than built independently; if it can, that supersedes part of this task's construction and this description should be revised again before implementation starts.

=== DEPENDENCY ADDED 2026-09-01 ===
Task 528 (Algebraic/ modernisation: propDecide in BooleanStructure.lean, SetMaximalConsistent.ultrafilterEquiv as a named Equiv, the bespoke `Ultrafilter` structure reconciled with Mathlib Order.PFilter/Ideal.IsPrime, Multiset.inf; from specs/reviews/review-2026-09-01-lean-engineering.md findings D-08, F-11, F-12, F-13) must land first so this task builds on the modernised algebra rather than inheriting a shadowed Ultrafilter name and ~430 lines of hand-built Boolean algebra.
