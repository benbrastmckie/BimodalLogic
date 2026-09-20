# Research Report: Task #631

**Task**: 631 - Deliverable hygiene excluding specs
**Started**: 2026-09-20T21:20:00Z
**Completed**: 2026-09-20T21:43:00Z
**Effort**: general (no Lean change)
**Dependencies**: None
**Sources/Inputs**: Codebase (`docs/`, `typst/`, `scripts/`, `latex/`, `FormalSystem/README.md`,
`README.md`, `CITATION.cff`, `.gitignore`), `scripts/check-module-invariants.sh` and
`scripts/readme-lint.sh` live runs, `docs/development/PUBLICATION_REFACTOR.md` (the source
programme document this task's description is drawn from verbatim as Follow-up B / Phase 1),
`specs/TODO.md` entries for tasks 630, 637, 639
**Artifacts**: this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- This task is **Phase 1 ("Deliverable hygiene")** of `docs/development/PUBLICATION_REFACTOR.md`
  (Section 7), reproduced verbatim in that document's own "Follow-up B" (Section 9). Reading the
  full phase text and its neighbouring ADRs (ADR-009, ADR-010) resolves almost every ambiguity in
  the task's one-paragraph description — the plan phase should treat that document as the
  authoritative spec, not just the task description.
- **Baseline is green**: `scripts/check-module-invariants.sh` (all checks, including C10, C12,
  C13) and `scripts/readme-lint.sh` both currently pass with zero failures. Every change this
  task makes must preserve that.
- **`latex/` retirement is the highest-risk item.** 13 files outside `latex/` itself reference
  `latex/` paths; two of them (`README.md` and `FormalSystem/README.md`) contain literal
  markdown/relative links that will become **broken** the moment `latex/` is deleted, and
  `FormalSystem/README.md`'s broken links will fail `readme-lint.sh` Check 3 specifically (its
  default scan root is `FormalSystem/`, which is exactly where that file lives). One entire file,
  `docs/development/LATEX_STANDARDS.md`, exists only to document the directory being retired and
  should itself be removed, not merely edited.
- **The acceptance grep has a self-reference problem.** `grep -rn 'home/benjamin' docs typst`
  will never go fully empty while `docs/development/PUBLICATION_REFACTOR.md` exists, because that
  file quotes its own acceptance criterion in four places, each containing the literal substring
  `home/benjamin`. This is a false positive, not a real leak — flagged as a Decision below.
- **The Logos/ProofChecker naming scope is much smaller than the raw grep counts suggest.**
  `docs/research/` (9 files, ~90+ combined `Logos`/`ProofChecker` occurrences) is itself being
  removed from the deliverable by this same task, and `docs/development/PUBLICATION_REFACTOR.md`'s
  5 `Logos`/`ProofChecker` hits are the plan describing the rewrite, not instances of it. Doing
  the untrack/move/retire steps **before** the naming grep shrinks the real remaining scope by
  roughly half.
- **One real conflict with a currently-tracked design decision**: `docs/reference/paper-definitions-of-record.md`
  states that `scripts/swap_untl_snce.py` is "kept for output and history stability" — directly
  contradicting this task's instruction to delete it as a one-off script. This doc line must be
  updated in the same change that deletes the script, or the doc becomes internally
  self-contradictory.
- **`scripts/check-module-invariants.sh` and `scripts/readme-lint.sh` are the only two acceptance
  gates named**, and their exact scan mechanics (below) tell you precisely which of the many
  `latex/`-referencing files are gate-relevant and which are cosmetic-only.

## Context & Scope

Task 631 absorbs task 610 (verbatim, quoted in the dispatch) and is explicitly coordinated with
task 639 ("Readme accuracy and entry point fixes"), whose own description says: *"task 631 also
edits README.md (Logos/ProofChecker naming, latex retirement); land this first, and item (5)
becomes moot once 631 retires latex/."* No hard `Dependencies` edge exists (task 639 lists
`None`), but the two tasks touch overlapping README.md regions and 639's text explicitly expects
631 to land first. `specs/` is out of scope entirely (per the task title and Section 8 of the
programme document, which reserves `specs/` untracking for a decision the maintainer already
made: it stays tracked permanently).

Reconciliation notes on the dispatch file also record that task 637 (Follow-up H / Phase 8, "CI
parity, root collapse and publication gate") **repeats** the exact untrack instruction for
`CLAUDE.md`, `.claude-extensions.json`, `.syncprotect` and `.gitattributes` "at the gate" (Section
8's dependency-order narrative). This is a genuine duplication in the source programme document
between Phase 1 (this task) and the Phase-8 gate step — see Decisions below.

## Findings

### Codebase Patterns

**The programme document IS the spec.** `docs/development/PUBLICATION_REFACTOR.md` Section 7
("Phase 1: Deliverable hygiene") and Section 9 ("Follow-up B") both state this task's scope in
the same words as the dispatch description, but with additional detail the one-paragraph
description omits:
- Section 4 ("Target layout") states the removed set explicitly: `latex/` (frozen edition + PDF),
  `docs/research/`, `docs/training/` ("moves with the dataset project or into the tooling
  library's README" — i.e. its ultimate destination is outside this repository or into the
  not-yet-created `BimodalTools/` library, neither of which exists yet at task-631 time),
  `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, the empty `.gitattributes`, and the four
  one-off scripts.
- Section 5 ("Templates" → "`CITATION.cff` at publication") states the file needs **no**
  Logos/ProofChecker rewrite: "Keep the file... The file is otherwise clean." Confirmed by direct
  inspection — `CITATION.cff` contains zero occurrences of `Logos` or `ProofChecker` (only
  `email: benjamin@logos-labs.ai`, an author email domain, not a naming defect).
- Section 5 ("README lead") floats restructuring the "Logos / ProofChecker / ModelChecker
  architecture paragraph" into a "Related projects" section or dropping it — this reads as
  optional polish for a later phase, not a Phase-1 requirement; Phase 1's own text only commits
  to "rewrite the internal Logos / ProofChecker naming" (i.e. fix incorrect/stale usages), not to
  this restructuring.

**Baseline gate results** (both commands run against current `HEAD`, no local changes):

```
$ bash scripts/check-module-invariants.sh
... 30 check families (B0, C1-C30, C9D, C20-C30, INV) ...
ALL CHECKS PASSED

$ bash scripts/readme-lint.sh
Missing READMEs: 0   Broken file references: 0   RESULT: PASS
```

`check-module-invariants.sh`'s C12/C13 section confirmed live: `PASS C12 all slash-shaped source
paths in 83 markdown files resolve` and `PASS C13 all relative markdown links in 80 markdown
files resolve (3 file(s) allowlisted)`.

**What C10/C12/C13 actually scan** (read directly from `scripts/check-module-invariants.sh`,
lines ~1247-1360), because the dispatch text's shorthand "the C10/C12 references to it" does not
match these checks' literal regexes and the plan should not over-index on the label:
- **C10** (`grep -rnE 'FormalSystem/(docs|latex|typst)\b' ...`) checks for the **pre-relocation
  nested** paths `FormalSystem/latex`, `FormalSystem/docs`, `FormalSystem/typst` — a different,
  already-resolved historical layout. It does **not** match root-level `latex/...` references at
  all. Retiring root `latex/` has no effect on C10's pattern either way.
- **C12** (`slash_re = r"\b(?:FormalSystem|Tests|Logos|Bimodal)/[A-Za-z0-9_./-]+"`) only matches
  paths beginning with those four prefixes — never `latex/`, `typst/` or `docs/`. It will not
  fire on any `latex/`-referencing text either.
- **C13** ("every relative markdown link in `docs/` + `README.md` resolves") is the check that
  **will** fire on a broken `[text](latex/BimodalReference.pdf)`-style link once `latex/` is
  deleted, but its scan root is `docs/` (walked) plus the single top-level `README.md` — **not**
  `FormalSystem/**/README.md`, `typst/**` or `ORGANISATION.md`.
- `readme-lint.sh` Check 3 ("no broken relative file references") is the check that covers
  `FormalSystem/README.md`, because its default root is `FormalSystem/` and Check 3 scans every
  `README.md` under a Lean root (excluding `Boneyard/`).

Net effect: two *different* acceptance scripts jointly cover the two files that actually break —
`README.md` under C13 (via `check-module-invariants.sh`) and `FormalSystem/README.md` under
Check 3 (via `readme-lint.sh`). Neither C10 nor C12 is actually implicated by the `latex/`
retirement as coded today; the dispatch's "C10/C12" phrasing is closer to the doc's informal name
for "the invariant-harness path/link checks" as a group than to the two specific check IDs.

**Every file referencing `latex/` today** (`grep -rn 'latex/' <file>`, root-relative):

| File | Nature of reference | Gate-relevant? |
|---|---|---|
| `README.md:17` | prose + markdown link `[latex/BimodalReference.pdf](latex/BimodalReference.pdf)` | **Yes — C13** |
| `README.md:357` | markdown link `[Specification Document](latex/BimodalReference.pdf)` | **Yes — C13** |
| `FormalSystem/README.md:7` | markdown links `[tex](../latex/...)` \| `[pdf](../latex/...)` | **Yes — readme-lint.sh Check 3** |
| `docs/development/LATEX_STANDARDS.md` | entire file's subject is `latex/`; 5 internal refs/links to `latex/README.md`, `latex/BimodalReference.pdf` | Indirect (see below) |
| `docs/development/README.md:32` | link to `LATEX_STANDARDS.md` (not to `latex/` itself) | No (link target stays valid unless the file is deleted) |
| `docs/README.md:153` | same, link to `LATEX_STANDARDS.md` | No |
| `docs/development/CONTRIBUTING.md:143` | prose bullet in a project-structure list (this file also moves to root this task) | No (not a link) |
| `ORGANISATION.md:45` | table row `\| typst/, latex/ \| The paper sources \|` | No (root-level, outside both scan scopes) |
| `docs/architecture/ADR-009-...md:45` | prose, backtick code span, historical rationale bullet | No (not a link/slash-prefixed match) |
| `docs/architecture/ADR-010-...md:32` | prose, backtick code span, **already anticipates this exact retirement** | No |
| `typst/README.md:188,191` | prose, historical/comparative | No |
| `typst/SYNC-MAP.md:125,127` | Section "D3. latex/ mirror: declared divergence" — becomes moot once `latex/` is gone | No |
| `FormalSystem/Boneyard/README.md:680` | prose, plain text (not a markdown link) | No |
| `scripts/check-module-invariants.sh` (4 comment lines) | describes C10's own pattern; unaffected | No |
| `docs/development/MODULE_INVARIANTS.md:29` | documents C10; describes root layout ("`docs/`, `latex/` and `typst/` live at the project root") | No (informational, worth a word update, not gate-required) |

**`docs/architecture/ADR-010-Boneyard-At-Repository-Root.md` already accounts for this
retirement.** Its Context section states verbatim: *"One of ADR-009's three rationale bullets
cites a frozen artefact... `latex/README.md` now marks the whole LaTeX edition as a superseded
reference edition... A rationale that rests on a document the repository has itself frozen is not
a live rationale."* and its Decision item 4: *"the programme's deliverable-hygiene phase retires
the frozen edition from the tracked tree, and this record does not depend on it."* This means: no
edit to ADR-010 is required by this task — it was written anticipating exactly this change.
**ADR-009 itself** (still `Accepted`, until ADR-010 is accepted at task 630/Phase 2) still states
"the published prose depends on it" naming `latex/subfiles/04-Metalogic.tex` by path, as one of
three "why not cut [the Boneyard]" rationale bullets. After this task deletes `latex/`, that
sentence names a file that no longer exists in the tree — historically accurate (it was true when
ADR-009 was accepted) but no longer verifiable by a reader. This is not gate-enforced (ADRs are
outside both C13's and readme-lint's scan roots) and does not need to block this task; flagged
as an optional follow-up, not a blocker.

**`scripts/` inventory.** Current top-level `scripts/` holds 33 files (`ls scripts | wc -l`,
excluding `lib/` and `__pycache__`), of which the four named for deletion
(`migrate_schema_v2.py`, `swap_untl_snce.py`, `standardize_metadata.py`,
`add-copyright-headers.sh`) leave **29** remaining top-level scripts plus 4 helper modules under
`scripts/lib/` (`import_graph.py`, `lean_debug_artifacts.py`, `live_walk.py`,
`typst_axiom_report.py`). No other script or doc (outside `specs/` and the plan document itself)
references any of the four scripts by name — deletion is safe with one exception:
`docs/reference/paper-definitions-of-record.md:195` states `scripts/swap_untl_snce.py`'s
"migration pattern data" is "kept for output and history stability," which directly contradicts
deleting it (see Decisions). `specs/evidence/bi-lasso-decision-layer/phase12-check-not-compositional.lean`
also names it in a docstring, but that file is under `specs/` and explicitly out of scope.

**Logos/ProofChecker naming — real scope after accounting for concurrent removals.** Raw counts
(`grep -c`) in `docs/` + `README.md` + `CITATION.cff`:

| Bucket | Files | Approx. occurrences |
|---|---|---|
| Inside `docs/research/` (being removed by this same task) | 9 files | ~97 (Logos 70 + ProofChecker ~27, combined across `DUAL_VERIFICATION.md`, `PROPERTY_BASED_TESTING_LEAN4.md`, `NONCOMPUTABLE.md`, `BIMODAL_LOGIC.md`, `README.md`, `DEDUCTION_THEOREM_NECESSITY.md`, `temporal-logic-automation.md`, `proof-search-automation.md`, `modal-temporal-proof-search.md`, `leansearch-proof-caching-memoization.md`) | **moot — deleted, not rewritten** |
| `docs/development/PUBLICATION_REFACTOR.md` (the plan describing this rewrite) | 1 file | 5 | **not real instances — self-referential, do not edit** |
| Everywhere else in `docs/` + `README.md` + `CITATION.cff` | ~30 files | Logos ~65, ProofChecker ~75 | **real remaining scope**, dominated by `docs/user-guide/architecture.md` (18), `docs/development/LEAN_STYLE_GUIDE.md` (15+4), `docs/architecture/ADR-001-Classical-Logic-Noncomputable.md` (9 ProofChecker), `docs/research/DEDUCTION_THEOREM_NECESSITY.md` is already counted above |

Two distinct senses coexist and must be disambiguated per-occurrence, not blanket-replaced:
1. **Stale Lean-import-style `Logos`** (`import Logos`, `Logos.ProofSystem`, `Logos.Core.Automation.ProofSearch`,
   `open Logos.Syntax`) in `docs/user-guide/tutorial.md`, `tactic-development.md`, `examples.md` —
   these are factually wrong code examples; the library is `FormalSystem` today. This is the same
   category the absorbed task 610 flagged for stale `lakefile.lean` mentions and is a
   straightforward find-and-replace to `FormalSystem`/`import FormalSystem`.
2. **Legitimate external-project references** ("Logos Laboratories", "the broader Logos project",
   `https://logos-labs.ai/`) — accurate and should be preserved, per `CLAUDE.md`'s own "Names"
   section: *"`ProofChecker` is the project's role name in the Logos dual-verification
   architecture (paired with a ModelChecker), used throughout `README.md`... "* This sentence is
   the load-bearing precedent: `ProofChecker`-as-role-name in `README.md` is **intentional
   design**, not a defect, and `docs/README.md`'s own opening blockquote already states the
   correct disambiguation (`> **ProofChecker**, the Lake package is named **BimodalLogic**...`).
3. **`ProofChecker` used loosely as if it were a literal directory/package name** in
   instructional prose (e.g. `docs/user-guide/troubleshooting.md:53`: "Ensure you're in the
   ProofChecker root directory"; `docs/user-guide/quickstart.md:8`: "ProofChecker project cloned
   and built") — these should be normalized to the actual repository name (`BimodalLogic`) or
   generic phrasing ("the repository root"), consistent with `docs/README.md`'s own
   disambiguation box.

The plan should therefore split this into: (a) fix stale `Logos`-as-package-name code examples
(bucket 1, small and mechanical); (b) leave "Logos"/"Logos Laboratories" external-project
references untouched; (c) leave `README.md`'s and `docs/README.md`'s `ProofChecker` role-name
framing untouched (it matches `CLAUDE.md`'s documented convention); (d) normalize the
loosely-worded literal-name misuses in the remaining ~28 files to the actual project/repo names.
Given the file count (~30), this is likely its own implementation phase rather than a quick pass.

**`CONTRIBUTING.md` move.** Currently at `docs/development/CONTRIBUTING.md`; target layout
(Section 4) places it at the repository root alongside `README.md`, `ORGANISATION.md`,
`NOTATION.md`, `references.bib` (all four already exist at root today, confirming the convention
this task extends). 14 files reference it by its current path
(`docs/development/CONTRIBUTING.md`), most inside `docs/` (link-check relevant) plus `specs/`
(out of scope, leave as historical record).

**`docs/research/` and `docs/training/` disposition is a real open decision, not fully specified.**
Section 4 says these directories are "removed from the tracked deliverable" and that
`docs/training/` specifically "moves with the dataset project or into the tooling library's
README" — but neither the dataset project (external, unspecified) nor the tooling library
(`BimodalTools/`, not created until task 632/Phase 3) exists yet at task-631 time. The verb used
in the task description ("move ... out of the deliverable") differs from the verb used for
`CONTRIBUTING.md` ("move ... to the root") — the latter is a same-repo relocation (`git mv`,
stays tracked), the former parallels the phrasing used for `CLAUDE.md`/`.claude-extensions.json`/
`.syncprotect` ("untrack ... add to `.gitignore`"). The most literal reading consistent with
Section 4's "removed from the tracked deliverable" is: **untrack** `docs/research/` and
`docs/training/` (git rm --cached -r, keep the files on local disk, add both paths to
`.gitignore`), the same pattern as the four dotfiles, rather than deleting the content outright or
relocating it to an as-yet-nonexistent destination. This is presented as a finding, not a
decision — the plan phase should confirm this reading (see Decisions).

**Personal absolute paths (`home/benjamin`) — current state.** `typst/` is **already clean** (zero
occurrences; likely fixed incidentally by a recent commit — `git log` shows
`81905b9d7 latex: point the frozen edition's paper link at the published URL` touching this area).
`docs/` has exactly 3 files:
- `docs/development/DOC_QUALITY_CHECKLIST.md` (3 occurrences, lines 143, 238, 268): literal
  `cd /home/benjamin/Projects/BimodalLogic` in example shell blocks — trivial to genericize
  (drop the `cd` line, or use a relative/placeholder path).
- `docs/reference/paper-definitions-of-record.md` (5 occurrences, lines 4, 20, 21, 56, 2101):
  these reference a **different, unvendored repository**
  (`/home/benjamin/Philosophy/Papers/PossibleWorlds/...`, the JPL paper source), used as
  provenance documentation, not example commands. `scripts/check-paper-definitions.sh` itself
  contains no hardcoded reference to this path (confirmed by grep), so this is a docs-only,
  no-functional-risk fix — but the fix must preserve the provenance intent (paper repo location,
  commit hash, checksum) while dropping the absolute personal path, e.g. genericizing to `~/Philosophy/Papers/PossibleWorlds/...`
  or describing it as "the maintainer's local, unvendored checkout" without the literal path.
- `docs/development/PUBLICATION_REFACTOR.md` (4 occurrences, lines 310, 407, 476, 524): **all
  four are the acceptance-criterion text itself, quoted verbatim in backticks** — see Decisions,
  this is the self-reference problem, not a real personal-path leak.

### External Resources

Not applicable — this is a pure internal-repository hygiene task with no external library or API
surface; no web research was needed or performed.

### Recommendations

1. Sequence the work so cheap wins compound: do the untrack/delete/move steps first (four
   dotfiles, four scripts, `docs/research/`, `docs/training/`, `latex/`), *then* run the
   Logos/ProofChecker grep and the `home/benjamin` grep against the resulting (smaller) tree —
   this avoids editing files that are about to disappear.
2. Treat `docs/development/PUBLICATION_REFACTOR.md`'s Phase 1 section (lines 296-311) and Section
   4 (lines 74-119) as the authoritative elaboration of this task's one-paragraph description;
   the plan should cite them rather than re-deriving intent from the terse dispatch text alone.
3. For `latex/` retirement: delete the whole tracked `latex/` directory (`git rm -r latex/`,
   including `latex/build/` if tracked — confirmed `git ls-files latex/` shows `build/` outputs
   are **not** tracked, only source `.tex`/`.sty`/`.pdf`/`README.md` files are); delete
   `docs/development/LATEX_STANDARDS.md` outright (its entire subject is retired); fix the two
   broken-link sites (`README.md:17,357` and `FormalSystem/README.md:7`); update
   `docs/development/README.md:32` and `docs/README.md:153` to drop the now-dangling
   `LATEX_STANDARDS.md` link entries; update `typst/SYNC-MAP.md`'s "D3. latex/ mirror" section and
   `typst/README.md`'s two historical-comparison sentences to past tense / removed-tree framing;
   update `docs/development/CONTRIBUTING.md`'s project-structure bullet (dropping it, in the same
   move that relocates this file to the root); update `ORGANISATION.md:45`'s table row. Leave
   `ADR-009`, `ADR-010`, `MODULE_INVARIANTS.md`, `check-module-invariants.sh`'s comments, and
   `FormalSystem/Boneyard/README.md:680` untouched (none is gate-relevant, and ADR-010 already
   narrates the retirement as expected).
4. For the one-off scripts: delete all four, then fix
   `docs/reference/paper-definitions-of-record.md:195` (the "kept ... for history stability"
   line) in the same change so the doc does not contradict the tree.
5. Author `scripts/README.md` naming the 29 remaining top-level scripts plus the 4
   `scripts/lib/*.py` helpers; keep it free of task-number citations (C9 scans `scripts/`).
6. For `docs/research/`/`docs/training/`: recommend untrack-and-gitignore (matching the four
   dotfiles' treatment) unless the plan phase identifies a more specific destination; either way,
   confirm no live doc links into these trees survive from outside them (a link-scope check, not
   just deletion).
7. For Logos/ProofChecker: do NOT touch `CITATION.cff` (already clean), do NOT touch
   `docs/development/PUBLICATION_REFACTOR.md`'s self-referential mentions, do NOT remove
   `README.md`'s/`docs/README.md`'s intentional `ProofChecker`-as-role-name framing; DO fix the
   stale `import Logos`/`Logos.ProofSystem`-style code examples and the literal-name misuses
   enumerated above.
8. For the `home/benjamin` acceptance grep: resolve the self-reference in
   `docs/development/PUBLICATION_REFACTOR.md` by rewording its four quoted acceptance lines to
   avoid the literal substring (e.g. describe the check in prose — "no absolute path under the
   invoking user's home directory" — rather than quoting the exact `grep` invocation), so the
   acceptance command can genuinely return empty; fix the 3 `DOC_QUALITY_CHECKLIST.md` lines and
   the 5 `paper-definitions-of-record.md` lines as described above.
9. After all edits, run `bash scripts/check-module-invariants.sh` and
   `bash scripts/readme-lint.sh` (both green today) and `grep -rn 'home/benjamin' docs typst`
   (must be empty) as the final verification gate, exactly as the acceptance criterion states.

## Decisions

- **Scope boundary confirmed**: `specs/` is untouched by this task (title and Section 8 of the
  programme document agree); the four dotfiles' untracking is genuinely this task's job now
  (Phase 1), even though Section 8 and task 637 describe the *same* untrack action recurring "at
  the gate" — this is a duplication in the source document between Phase 1 and Phase 8, not an
  error in this task's dispatch. Recommendation: proceed with the untrack now (as the task
  description instructs); note for whoever plans/executes task 637 that `git rm --cached` on an
  already-untracked path is a no-op error unless guarded (e.g. `git rm --cached <path> || true`,
  or simply checking `git ls-files` first) — this task's research does not modify task 637, but
  flags the duplication so it is not treated as a surprise later.
- **`docs/research/`/`docs/training/` destination**: research recommends untrack + `.gitignore`
  (matching the CLAUDE.md-style dotfile treatment) rather than outright deletion or a relocation
  to a not-yet-existing destination, but this is presented as a recommendation for the plan phase
  to confirm, not a settled fact — the source document's own phrasing ("moves with the dataset
  project or into the tooling library's README") is genuinely underspecified at this point in the
  programme.
- **`home/benjamin` self-reference in `docs/development/PUBLICATION_REFACTOR.md`**: this is a
  structural property of quoting a grep-based acceptance criterion inside the document that
  states it, not a defect this task introduced. It needs a decision (reword the quoted criterion
  text) rather than a mechanical fix, since blindly deleting/obscuring the acceptance-criterion
  documentation would reduce the programme document's clarity for the very reason it exists.

## Risks & Mitigations

- **Risk**: deleting `latex/` before fixing its two link-bearing citers breaks `readme-lint.sh`
  and `check-module-invariants.sh` (C13) simultaneously, i.e. both acceptance gates named in this
  task's own criteria. **Mitigation**: fix `README.md:17,357` and `FormalSystem/README.md:7` in
  the same commit/step as the `latex/` deletion, not as a follow-up; re-run both scripts
  immediately after.
- **Risk**: deleting `scripts/swap_untl_snce.py` while `docs/reference/paper-definitions-of-record.md`
  still asserts it is "kept... for history stability" leaves the tree in a state where a careful
  reader finds a documented promise the tree does not keep. **Mitigation**: edit that doc line in
  the same change.
- **Risk**: a blanket find-and-replace of "Logos" → "FormalSystem" across `docs/` would corrupt
  the legitimate "Logos Laboratories" / external-project references and contradict `CLAUDE.md`'s
  own documented naming convention. **Mitigation**: handle per-occurrence per the two-bucket
  split above; do not script this as a single regex substitution.
- **Risk**: the Logos/ProofChecker rewrite scope (~30 files outside `docs/research/`) is large
  enough that attempting it in the same implementation pass as the `latex/`/scripts/dotfile work
  could overrun a single dispatch's practical size. **Mitigation**: the plan phase should consider
  splitting this task's plan into two or more phases (mechanical untrack/delete/move first;
  naming normalization second), while keeping both under this one task per the dispatch's scope.
- **Risk**: `docs/research/` and `docs/training/` removal could silently orphan inbound links
  from files that remain in the deliverable (e.g. `README.md:366` currently links to
  `docs/research/BIMODAL_LOGIC.md`). **Mitigation**: after untracking, re-run
  `check-module-invariants.sh` (C13 will catch any surviving link into the now-removed trees from
  `docs/` + `README.md`) and separately grep for `docs/research/` / `docs/training/` references
  across the remaining tracked tree, since C13's scan root would not catch a reference from, say,
  `FormalSystem/README.md` or `ORGANISATION.md`.

## Context Extension Recommendations

- **Topic**: non-Lean top-level directory README conventions.
- **Gap**: `docs/reference/readme-standard.md` documents the README convention enforced by
  `readme-lint.sh` for `FormalSystem/` (Lean) directories specifically; there is no equivalent
  template for a top-level tooling directory like the new `scripts/README.md` this task must
  author. `latex/README.md` and `typst/README.md` are the closest existing precedents but are not
  written up as a reusable pattern anywhere in `.claude/context/`.
- **Recommendation**: not urgent enough to block this task (informal, self-consistent content is
  sufficient), but worth a follow-up context note once `scripts/README.md` exists, so future
  top-level non-Lean READMEs (e.g. if `BimodalTools/` needs one after task 632) have a documented
  template to follow.

## Appendix

### Search queries / commands used

```
git ls-files | grep -E '^(CLAUDE\.md|\.claude-extensions\.json|\.syncprotect|\.gitattributes)$'
grep -rn 'home/benjamin' docs typst
grep -rn 'C10\b' / 'C12\b' docs/development/PUBLICATION_REFACTOR.md
sed -n '260,420p;431,542p' docs/development/PUBLICATION_REFACTOR.md   # Phase 1-9 + follow-up split
sed -n '1247,1360p' scripts/check-module-invariants.sh                # C10/C12/C13 implementation
bash scripts/check-module-invariants.sh                                # baseline: ALL CHECKS PASSED
bash scripts/readme-lint.sh                                            # baseline: RESULT: PASS
grep -rln 'latex/' --include='*.md' ...                                # 13 external citers found
grep -rlc 'Logos'/'ProofChecker' docs/ README.md CITATION.cff           # per-file occurrence counts
grep -n -A10 '### 639\.\|### 640\.' specs/TODO.md                      # coordination note confirmed
```

### Key references

- `docs/development/PUBLICATION_REFACTOR.md` — Sections 1, 4, 5, 7 (Phase 1), 8, 9 (Follow-up B)
- `docs/architecture/ADR-009-Boneyard-Retention.md` and `ADR-010-Boneyard-At-Repository-Root.md`
- `scripts/check-module-invariants.sh` lines 1247-1360 (C10/C12/C13), 538-560 (enforcement flags)
- `scripts/readme-lint.sh` lines 1-40 (scope selection), 154-190 (Check 3)
- `specs/TODO.md` entries for tasks 630, 637, 639 (coordination and duplication notes)
