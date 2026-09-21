# Implementation Summary: Task #636

- **Task**: 636 - Docstring and citation normalisation
- **Status**: [COMPLETED]
- **Started**: 2026-09-21
- **Completed**: 2026-09-21
- **Effort**: one dispatch, ten phases, ten commits
- **Dependencies**: 635 (landed at `eae409d04`)
- **Artifacts**: plans/01_docstring-citation-normalisation.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Merged `typst/bibliography.bib` into the repository-root `references.bib` so one bibliography
now serves both the Lean docstrings and both typst documents, normalised every `## References`
block in `FormalSystem/`, `BimodalTools/` and `Tests/` to a single three-way form, folded all 12
`## Paper Specification Reference` headings and removed all 4 `## Implementation Status`
headings, and stripped tooling notes, personal paths, repository-relative `literature/` pointers
and Logos/ProofChecker wording from the library docstrings, `Examples/` and the tests. The work
is comment-only: no proof, no definition and no `.lean` code outside comments was touched. All
ten plan phases are complete, each committed at a green boundary.

## What Changed

- `references.bib` — merged: 26 root entries plus 51 carried over from the typst file, 77
  entries with no duplicate key. Four exact-key collisions (`kamp1968`, `doets1987`,
  `reynolds1992`, `rabinovich2014`) resolved per the plan's measured per-key direction; seven
  same-work pairs deduplicated to the root's lowercase `authorYYYY` keys; 15
  `note = {verify before print}` maintainer markers stripped; the typst file's provenance
  comments, including the Lk embargo note, carried into the merged header.
- `typst/bibliography.bib` — deleted.
- `typst/{BimodalReference,FormalFoundations}.typ` — re-pointed at `../references.bib`; 20
  citation sites across 7 `.typ` files rewritten to the surviving keys.
- `typst/README.md`, `README.md` — bibliography paths updated and the `--root ..` flag both
  documents now need recorded.
- `typst/generated/automation-module-map.typ` — regenerated (three line counts moved).
- `scripts/reanchor-lean-citations.py` — new; the per-file C20 citation re-anchor tool, with a
  `--recompute` repair mode, an `--exact` mode and a `--selftest`.
- `docs/development/REFERENCE_NORMAL_FORM.md` — new; the three-way normal form, what does not
  belong under `## References`, the re-anchoring procedure and the recorded gate baselines.
  Indexed in `docs/development/README.md`.
- ~290 `.lean` files under `FormalSystem/`, `BimodalTools/` and `Tests/` — `## References` and
  `### References` blocks converted; 14 personal paths, 17 `literature/` pointers, 27
  Logos/ProofChecker occurrences, 12 `## Paper Specification Reference` headings and 4
  `## Implementation Status` headings all removed.
- `FormalSystem/Metalogic/Expressiveness.lean` — the two dangling bibkeys re-pointed (see
  Decisions).

## Decisions

- **Paper anchors are not qualified with a `.tex` filename.** The plan's normal form wrote
  ``JPL paper `possible_worlds.tex`: `def:x` ``, but several of these modules record in terms
  that `docs/reference/paper-definitions-of-record.md`, not the paper source, is the citation
  source of record, and it retains the last resolved text of anchors the paper has retired.
  The unqualified ``JPL paper `def:x` `` form — already the tree's dominant one — is used, and
  `REFERENCE_NORMAL_FORM.md` records why.
- **The two dangling bibkeys were re-pointed, per the plan's isolated default.** `stavi1979` and
  `gabbay1980` resolved to nothing. Before re-pointing, the existing key was checked against the
  cited content: `FormalSystem/Metalogic/Expressiveness/StaviConnectives.lean` already cites
  `gabbay1994` Ch. 9 §3 for exactly the Stavi connectives, and
  `Expressiveness/Separation/SemanticBridge.lean` already cites `gabbay1994` Ch. 10 for
  separation. Both re-points are therefore backed by the tree's own existing citations, not
  invented. Worth noting for the user: the merge brought in `gpss1980` (Gabbay, Pnueli, Shelah
  and Stavi 1980, *On the Temporal Analysis of Fairness*), whose date and author list make it a
  plausible better match for `gabbay1980` — that is a judgement about the intended source, not
  something derivable from the repository, so it was not acted on.
- **A citation to an artifact under `specs/` is task-management metadata and goes; a citation to
  an external repository's report is a citation of record and stays.** Applied uniformly in the
  Phase 9 residual sweep: the `01_tm-completeness-status.md` bullets were removed, while the
  PossibleWorlds `02_determinism-axiom-correspondence.md` citations stayed —
  `StarLanguage/StarDeterminism.lean` records in terms that the report is the citation of record
  for a result that is *not* manuscript text.
- **Named works with no verifiable bibliographic details were left as prose.** Wu's *Verified
  Decision Procedures for Modal Logics* (7 sites) and Hughes & Cresswell (2 sites) have no
  `references.bib` entry; authoring one is an explicit Non-Goal of the plan.
- **Historical records were preserved even where the mechanical rule would have removed them.**
  Two "the companion `.md` conversion is corrupt" notes were kept, in
  `Kamp/EANegationFix/OnBuilder.lean` and `Kamp/Section5Correspondence.lean`, because each is the
  antecedent of a record about `chunk_00NN` citations that pointed into that conversion.
- **`scripts/reanchor-lean-citations.py` is kept**, per the plan's Phase 10 default, with a header
  stating it is a maintenance tool and not a gate.

## Plan Deviations

Every deviation is annotated inline on the corresponding plan checklist item. Summarised:

- **Phase 1** altered: a seventh same-work pair (`brastmckie2026possibleworlds` vs
  `brastmckie2026construction`) was found at implementation time and deduplicated on the same
  rule, so the merged file carries no duplicate work. `PUBLICATION_REFACTOR.md:476` deferred to
  Phase 10 and `:597` skipped — `:597` is inside a verbatim blockquote of the recorded task
  brief, which is a historical record.
- **Phase 2** altered: the new document was named `REFERENCE_NORMAL_FORM.md` to match the
  UPPER_SNAKE convention of `docs/development/`.
- **Phase 3** altered: two `Examples/` files needed `--exact` re-anchoring; four `Task NNN`
  citations and three `(Task 277)` docstring titles were stripped under the plan's own
  task-metadata rule.
- **Phase 4** altered: `FormalSystem/Theorems.lean` is named in both this phase and Phase 6 and
  was converted here. `BimodalTools/TraceExporterMain.lean`'s two `## References` headings turn
  out to sit in two verbatim-duplicated leading docstrings; both were normalised and the
  duplication itself left alone.
- **Phase 5** altered: the hand-count the plan asked for gives **9** `## Paper Specification
  Reference` headings under `Semantics/`, not 6, reconciling against the research's 12-file
  total. Each heading was renamed to `## Paper specification, transcribed` with its body
  untouched, and its anchors added to the module's `## References`.
- **Phase 6** altered: `ModalS5.lean`'s status section was the only place naming `boxIffIntro`,
  `boxConjIff` and `diamondDisjIff`, so those names were moved into a `### Biconditionals`
  subsection rather than dropped. `ModalS4.lean`'s body heading `## Phase 4: Modal S4 Theorems
  (Not Started)` was renamed — "(Not Started)" was false of the implemented theorems below it.
- **Phase 7** altered: this set also carries `### References` blocks inside declaration
  docstrings, which the plan's heading-level assumption missed; those were converted too.
- **Phase 8** altered: the four `reynolds_1992` personal paths are prose inside CORRECTION
  records about the local corpus's own rendering, not `## References` entries, so each became
  "the local markdown corpus for [reynolds1992] §3.6" rather than a bibliographic citation. The
  two `../../` link repairs the plan names in `Soundness.lean` had already been made by the
  conversion pass; no such link remains.
- **Phase 9** altered: see the `specs/`-versus-external rule under Decisions.
- **Phase 10** altered: `typst/generated/automation-module-map.typ` needed regenerating — the
  sweep moved three Automation line counts, which turned `typst-sync-check.sh` Check 2b red. It
  is green again and the plan's Check 2b baseline of 0 holds.

Two mistakes were made and repaired during the run, both recorded on the plan:

- The re-anchor tool was run twice over one batch (Phase 4), doubly shifting 17 citations. C20
  still passed, because a doubly shifted citation usually lands on some other non-blank line.
  The affected citer files were restored from HEAD and the tool run once. A second occurrence in
  Phase 8 prompted the general fix: the tool grew an idempotent `--recompute` mode that rebuilds
  every citation from the base revision by content alignment, and both the tool's header and
  `REFERENCE_NORMAL_FORM.md` now document the hazard and the recovery.
- A colon-tidying pass stripped the trailing colon from 232 `**Bold heading**:` and list lines,
  including `Soundness.lean`'s pinned "Completed Proofs" heading. Every one was restored by
  diffing against HEAD; the `app:valid` history block and all count-bearing claims in that file
  are byte-identical to HEAD.

## Verification

Build-inclusive `bash scripts/check-module-invariants.sh`: **ALL CHECKS PASSED**.

- Build: Success (`lake build` exits 0; `lake build BimodalTest` exits 0 — C1 both halves)
- Sorry count: 0 (C3 asserts the structural-`sorry` inventory is zero by content, tree-wide)
- Vacuous count: 0
- Axiom count: unchanged (C2 all four flagship axiom sets match baseline; C14's `#print axioms`
  half green)
- Tests: Passed (C1's `BimodalTest` build)
- Files verified: Yes

Acceptance table, before and after:

| # | Check | Before | After | Target |
|---|-------|--------|-------|--------|
| A1 | entries in `* [Author, *Title*][key]` form | 0 | 146 line-leading (150 counting continuation lines) | >= 181 — see note |
| A2 | old bare `- [bibkey]` form | 197 | **0** | 0 |
| A3 | markdown-link cross-references | 121 | **0** | 0 |
| A4 | personal paths | 14 | **0** | 0 |
| A5 | repo-relative `literature/` pointers | 17 | **0** | 0 |
| A6 | Logos/ProofChecker in `.lean` | 27 | **0** | 0 |
| A7 | `## Paper Specification Reference` | 12 | **0** | 0 |
| A8 | `## Implementation Status` | 4 | **0** | 0 |
| A9 | dangling bibkeys | 2 | **0** | 0 |
| A10 | `grep -c '^@' references.bib` | 26 | **77** | the confirmed union |
| A11 | `typst/bibliography.bib` | present | **absent** | absent |
| A12 | ProofChecker in README/CLAUDE/typst | > 0 | **7** | unchanged, > 0 |

**A1 does not reach 181, and the target was wrong rather than the work.** The plan derived 181
from the research's count of bibliographic *citations*, which includes citations inline in prose.
After the sweep the tree holds 231 bibkey occurrences, of which 150 are in display form; the
remaining 81 are inline prose citations such as ``Cite [rabinovich2014] by **PDF page only**``,
which the normal form governs only inside `## References`. The operative evidence that no list
entry was missed is A2 = 0 together with A9 = 0: no list-form entry is left in the old bare form,
and every key in the tree resolves in `references.bib`.

**A10 is 77, not the plan's 84.** 84 is the union of the two key sets *before* deduplication;
84 minus the 6 pairs the plan itself names, minus the 7th found at implementation time, is 77.

Gates held at their recorded baselines:

- C20 tier 1: 1028 resolvable citations, every one on a real non-blank line, 0 `unverifiable` —
  unchanged
- C20 tier 2: 0 in publication-facing scope — unchanged
- C15: 59 paper anchors and 76 theorem-index rows — unchanged
- C19: 94.01% (10261/10915), floor 90% — unchanged
- C14: both halves PASS, every stated count and pinned declaration name preserved
- INV: `--emit-inventory --check` reports zero byte changes
- `typst compile --root . typst/BimodalReference.typ` and `typst/FormalFoundations.typ` both
  exit 0; the rendered text of both PDFs is byte-identical to the post-merge render taken in
  Phase 1, so nothing moved after the bibliography merge
- `scripts/readme-lint.sh`: still exactly **21** broken references — unchanged, not repaired
- `scripts/typst-sync-check.sh`: Check 1 still exactly **9** violations; Checks 2, 2b and 3 all
  at 0 mismatches — unchanged
- `git diff --stat -- Boneyard/` empty — Boneyard untouched
- `sub:` anchor census identical to its pre-sweep output: `sub:` 4, `sub:Extension` 8,
  `sub:Logic` 14, `sub:NecessarilyAlways` 1, `sub:OpenFuture` 2, `sub:RestrictedModalities` 11,
  `sub:Soundness` 1

## Impacts

- There is now one bibliography for the repository. A new citation in a Lean docstring and a new
  citation in either typst document resolve against the same file.
- Both typst documents now require `--root ..` (or `--root .` from the repository root). The
  build commands in `README.md` and `typst/README.md` were updated; any other caller must add it.
- `scripts/reanchor-lean-citations.py` gives future docstring sweeps a way to keep C20 green
  without hand-editing citations, and `--recompute` makes the repair idempotent.
- `docs/development/REFERENCE_NORMAL_FORM.md` fixes the convention that tasks 563-567 and
  616-618 were asked to adopt, and records the gate baselines a later sweep asserts against.

## Follow-ups

- **`FormalSystem/Theorems/TemporalDerived.lean` names two archive files that do not exist**:
  `Boneyard/OpenGuardInvalid/OpenGuardTemporalDerived.lean` and
  `Boneyard/ClosedGuardLegacy/ClosedGuardTemporalDerived.lean`. Both directories hold only a
  `README.md`. This is pre-existing drift; repairing it needs knowledge of where those 27
  definitions went, so the `### Removed` section was left as written. Task 177's drift re-audit.
- **`FormalSystem/Examples/TemporalStructures.lean:21` cites the JPL paper under the title "The
  Perpetuity Calculus of Agency"**, where the paper this repository formalizes is "The
  Construction of Possible Worlds". Left verbatim — it may name a different work.
- **`BimodalTools/TraceExporterMain.lean` carries a verbatim-duplicated leading module
  docstring** (lines 16-49 repeated at 51-86, the second with one extra bullet). Out of this
  task's scope; a structural deletion no acceptance row covers.
- **`chunk_00NN` citations remain** across `Kamp/NfMultiAnchorBridge/` and neighbours. They point
  into the corrupt markdown conversion; `Kamp/Section5Correspondence.lean` records that they
  "should be re-cited by page as they are touched". Converting them is its own task.
- **Task-number citations survive in body prose** outside `## References`, notably
  `Tests/BimodalTest/Automation/TacticsTest.lean`'s `## Test Coverage` and `## Test
  Organization` sections ("Task 315", "Task 319"). `.claude/scripts/check-task-references.sh`
  does not scan `Tests/` or `FormalSystem/`, so they are ungated.
- **`docs/development/PUBLICATION_REFACTOR.md:476` is still future-tense.** Its Phase 7 bullet
  covers this task's whole scope; past-tensing it is a one-line edit once the programme owner
  confirms Phase 7 is closed. `:597` stays verbatim, being a quoted task brief.

## References

- `specs/636_docstring_and_citation_normalisation/plans/01_docstring-citation-normalisation.md`
- `specs/636_docstring_and_citation_normalisation/reports/01_docstring-citation-normalisation.md`
- `docs/development/REFERENCE_NORMAL_FORM.md`
- `docs/development/PUBLICATION_REFACTOR.md`, Phase 7
- `scripts/check-module-invariants.sh` — C14, C15, C19, C20 and INV, the gates this asserts
