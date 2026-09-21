# Research Report: Docstring and Citation Normalisation

**Task**: 636 - Docstring and citation normalisation
**Started**: 2026-09-21T00:00:00Z
**Completed**: 2026-09-21T00:00:00Z
**Effort**: large (295-file edit set; five gated invariants in the blast radius)
**Dependencies**: task 635 (landed at `eae409d04`)
**Sources/Inputs**:
- Codebase at HEAD `eae409d04`
- `docs/development/PUBLICATION_REFACTOR.md` §5 "Templates" and §Phase 7 (the task's own spec of record)
- `scripts/check-module-invariants.sh` (C14/C15/C19/C20/INV source text)
- `scripts/readme-lint.sh`, `scripts/typst-sync-check.sh` (adjacent baselines)
- `references.bib`, `typst/bibliography.bib`, `docs/reference/paper-definitions-of-record.md`
- Live measurement (no Mathlib search tools were needed: this task adds no mathematics)

**Artifacts**: - `specs/636_docstring_and_citation_normalisation/reports/01_docstring-citation-normalisation.md`
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every acceptance gate is already green at HEAD, including the literal `grep -rn 'home/benjamin' FormalSystem Tests`, which returns 0 hits.** The full build-inclusive `check-module-invariants.sh` passes (C1, C2, C14, C15 both assertions, C19 at 94.01%, C20 both tiers, INV), `lake build` exits 0 with 2651 jobs, and both typst documents compile. The acceptance criteria therefore **cannot be used as evidence that this task did anything**; the implementation must gate on the pre/post *delta*, not on the pass line. The personal paths the task actually targets are written `~/Projects/Literature/...` (14 occurrences in 14 files), which the literal grep does not match. Recommend the plan replace that acceptance line with `grep -rnE '(/home/|~/Projects/|/Users/)' FormalSystem Tests BimodalTools` empty.
- **The dominant regression risk is C20 tier 1, which is gated.** 582 of the 1028 resolvable `file.lean:NNN` citations point *into* the 295-file candidate edit set (66 distinct target files). 297 of the 298 target headings sit inside the module docstring at the head of the file, so every edit shifts every line below it by a single per-file delta. This is exactly mechanisable: for each edited file compute Δ = new_line_count − old_line_count and rewrite every citation `File.lean:N` with N past the docstring end to `N+Δ`. A plan that does not carry this repair step will go red on the first commit.
- **The `## References` blocks are not a bibliography.** Of 713 entries across 282 headings, only **181 are bibliographic** (`[bibkey], locator` form); the other **532 are module cross-references** (294 backticked paths, 119 markdown links, 119 bare prose). The task title says "convert every `## References` entry", but the target form `* [Author, *Title*][key]` is meaningless for a cross-reference. The repository's own gold standard — the L+/L⋆/L− blocks the first task of this run authored — keeps both kinds under `## References`, with modules as backticked repo-relative paths. Generalise that, do not delete 532 entries.
- **The bib merge is safe but must not be "root wins".** Only 4 keys collide (`doets1987`, `kamp1968`, `rabinovich2014`, `reynolds1992`) and all four differ. Measured by compiling each entry through typst: root's `kamp1968` (`@article` with a `school` field) and `doets1987`/`reynolds1992` render *worse* than typst's, while root's `rabinovich2014` renders better. Notes do **not** render under typst's IEEE default, so root's internal commentary notes are safe to carry into the shared file. Per-key direction is in Findings.
- **Two cited bibkeys resolve to nothing in either file**: `stavi1979` and `gabbay1980`, both in `FormalSystem/Metalogic/Expressiveness.lean` (lines 67, 69). The merge must add entries or re-point them.
- **27 Logos/ProofChecker occurrences, every one classifiable**, and 16 of them are simultaneously the broken-link defect (`../../../Logos/Core/...`, a path that has not existed for two renames). Nothing gates relative links inside `.lean` docstrings, which is why they survived. 37 genuine broken path links exist in total; all 37 targets resolve under a corrected path.

## Context & Scope

### What was researched

The five sub-tasks of the dispatch description, measured against HEAD `eae409d04` rather than against the task text (written before six predecessor tasks reshaped the tree):

1. `## References` citation-form conversion in `FormalSystem/**/*.lean`
2. Merging `typst/bibliography.bib` into the root `references.bib`
3. Folding `## Paper Specification Reference` into `## References`; removing `## Implementation Status`
4. Stripping tooling notes, personal paths and Logos/ProofChecker wording
5. The acceptance surface: C14, C15, C19, the `home/benjamin` grep, typst compilation

### Tree shape at HEAD (re-measured, not trusted from the dispatch note)

| Tree | `.lean` files | files with `## References` |
|---|---|---|
| `FormalSystem/` | 504 | 247 |
| `BimodalTools/` | 25 | 19 |
| `Tests/` | 65 | 16 |
| `Boneyard/` | 169 | (excluded — archived, `#exit`) |

Confirmed present: root-level `Boneyard/` and `BimodalTools/`, `FormalSystem/Tactic/`, the merged `FormalSystem/{Plus,Minus,Star}Language/`, and `FormalSystem/Metalogic/Expressiveness/` (372 modules under `Metalogic/`).

### Scope decision: BimodalTools/ is IN scope

The task text scopes the sweep to `FormalSystem/**/*.lean`. `git log --follow` shows every one of the 25 `BimodalTools/` modules was under `FormalSystem/` when the task was written (24 from `FormalSystem/Automation/`, one from `FormalSystem/Metalogic/Decidability/TraceExport.lean`), matching `PUBLICATION_REFACTOR.md:174`. They were inside the stated scope at writing time; the Phase 4 move is the only reason they read as outside it now. Two further reasons:

- C15's own live scope already walks `FormalSystem Tests BimodalTools typst docs README.md`, so a `BimodalTools/` citation is already gated by one of this task's acceptance criteria.
- `BimodalTools/` is *tooling*, and "strip tooling notes" is one of the five sub-tasks. Its docstrings hold the densest concentration of exactly the prose the task removes (`- Measured deduplication ratio: 4.58x at complexity 7`, `- Phase 2: foundational data structures (this file)`).

`Boneyard/` stays out: archived, `#exit`-headed, excluded from every harness walk, and its 17 provenance READMEs carry deliberately frozen historical stamps.

`Tests/` is explicitly named by the task for sub-task 4 ("Examples/ and tests") and carries 16 `## References` blocks, all of them cross-reference-only and 16 of whose entries are broken `Logos/Core/` links. Treat Tests as in scope for both 1 and 4.

## Findings

### Gate baseline at HEAD `eae409d04` (all measured, not assumed)

| Gate | State | Detail |
|---|---|---|
| `lake build` | **green** | exit 0, 2651 jobs, warm |
| C1 | PASS | plus `lake build BimodalTest` |
| C2 | PASS | four flagship axiom sets match baseline |
| C14 (content) | PASS | no stale axiom/sorry counts in `docs/` + `README.md` + `FormalSystem/**/*.lean` |
| C14 (`#print axioms`) | PASS | every pinned declaration matches |
| C15 (anchors) | PASS | **59** citations resolve against the record |
| C15 (theorem-index) | PASS | 76 rows carry their anchor |
| C19 | PASS | refined 10261/10915 = **94.01%** (floor 90%); unrefined 91.50% |
| C20 tier 1 | PASS | **1028** resolvable `file.lean:NNN` citations all land on a real non-blank line — **gated** |
| C20 tier 2 | PASS | zero in publication-facing scope |
| INV | PASS | every generated inventory block current — **gated** |
| typst | **green** | both `BimodalReference.typ` and `FormalFoundations.typ` exit 0 (pre-existing "new computer modern sans" font warnings only) |
| `grep -rn 'home/benjamin' FormalSystem Tests` | **already empty** | 0 hits; 0 in `BimodalTools/` too |

C19 is reporting-only (`never affects FAILURES`); "C19 green" means keeping the PASS line above the 90% floor, and the 4-point margin is comfortable. C20 tier 1 and INV are the two gates this task can actually break.

### Known-red adjacent baselines (pre-existing, not this task's to fix)

Both confirmed exactly as described, and both must be re-measured unchanged after the sweep rather than "fixed" opportunistically:

- **`scripts/readme-lint.sh`: FAIL, 21 broken references**, every one a `../Boneyard/…` link that is one `../` short (e.g. `FormalSystem/Metalogic/README.md -> ../Boneyard/README.md` resolves to `FormalSystem/Boneyard/README.md`). Distribution: `FormalSystem/README.md` 4, `Metalogic/Expressiveness/Kamp/README.md` 4, `Metalogic/README.md` 2, `Metalogic/Core/README.md` 2, `Metalogic/Expressiveness/Separation/README.md` 2, `Metalogic/WeakCanonical/README.md` 2, `Automation/README.md` 1, `Automation/Tactics/README.md` 1, `Metalogic/Bundle/README.md` 1, `Metalogic/Expressiveness/EFGames/README.md` 1, `Metalogic/Expressiveness/GameTransfer/README.md` 1. The same run also reports 30 STALE DATE and 2 MISSING DATE lines (informational).
- **`scripts/typst-sync-check.sh`: FAIL, Check 1 = 9 violations**, all `docs/training/PIPELINE.md` (with and without line suffixes) cited from `typst/chapters/p4-dataset-pipeline.typ`. The file is really at `training/PIPELINE.md`; `docs/training/` does not exist. Checks 2, 2b and 3 are all green (0 mismatches), so `typst/generated/status.typ` is currently fresh.

### 1. `## References` entry census

282 headings across 281 files (`BimodalTools/TraceExporterMain.lean` has two), 713 `-`/`*` entries:

| Shape | Count | Example |
|---|---|---|
| `` - `Module.lean`: description `` (backticked path/module) | **294** | ``- `DatasetGenerator.lean`: `labelFormula`, `LabeledFormula` `` |
| `- [bibkey], locator` | **181** | `- [gabbay1994], Chapter 9, Theorem 9.3.1` |
| `* [Text](relative/path)` (markdown link) | **119** | `* [Tactics.lean](Automation/Tactics.lean) - Custom proof tactics` |
| bare prose | **119** | `- Formula AST: FormalSystem/Syntax/Formula.lean` |
| **already in `* [text][key]` target form** | **0** | — |

Bibkeys cited in the bare form, by frequency: `rabinovich2014` 60, `reynolds1992` 21, `reynolds1994` 14, `burgess1984` 12, `doets1989` 12, `burgess1982` 10, `gabbay1994` 9, `doets1987` 9, `gore1999` 7, `blackburn2002` 7, `goldblatt1992` 3, `reynolds2001` 3, `yang2019` 2, `xu1988` 2, `kamp1968` 2, and one each of `korf1985`, `kaliszyk2018`, `verbrugge2004`, `reynolds2003`, `libal2016`, `venema1993`, **`stavi1979`**, **`gabbay1980`**.

**The last two resolve to nothing in either bib file.** Both are in `FormalSystem/Metalogic/Expressiveness.lean`:

```
67:- [stavi1979], the Stavi connectives completing the Dedekind-incomplete case
69:- [gabbay1980], the separation property
```

Neither is gated today (C15 only reads `def|thm|lem|cor|app|rmk:` anchors, not bracket bibkeys), which is why they have survived. The merge must either add entries or re-point them — `gabbay1980` is plausibly `gabbayhodkinsonreynolds1994` or Gabbay's 1981 expressive-completeness paper; `stavi1979` has no entry anywhere and needs a fresh one. **This needs a judgement call the artifacts cannot make** (see User Decision below).

**The 532 non-bibliographic entries are the real design question.** `PUBLICATION_REFACTOR.md:207-211`'s template shows `## References` holding only `* [Author, *Title*][key]` lines, but the repository's own most recently normalised files — the L+/L⋆/L− blocks authored by the first task of this run — keep both kinds:

```
## References

* JPL paper `possible_worlds.tex`: `def:BLstar-semantics` (the `⟨τ⟩_x` definition, the Stability
  clause, and its footnote) and `sub:RestrictedModalities` (the dual `⟐` and the defined modals)
* `FormalSystem/Semantics/Truth.lean` — the six L clauses being mirrored
* `FormalSystem/MinusLanguage/MinusTruth.lean` — the sibling native recursion for the base language
```

That is a three-way normal form already validated by the harness: bib citations as `* [Author, *Title*][key], locator`; paper anchors as `* JPL paper …: \`def:x\`, \`sub:y\``; module cross-references as `` * `Repo/Relative/Path.lean` — description ``. Generalising it converts all 713 entries without discarding 532 of them, and it simultaneously repairs the 119 markdown-link entries (of which 16 are broken) into a form no relative-path computation can get wrong.

`FormalSystem/PlusLanguage/PlusLimitClosure.lean` shows the conversion paying off: its prose entry "Thomason, *Combinations of Tense and Modality* (1984), §4" becomes `* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4` **only once the typst bib is merged** — `thomason1984` exists in `typst/bibliography.bib` and not in the root file. Sub-tasks 1 and 2 are therefore ordered: merge first, convert second.

### 2. The bibliography merge

| | root `references.bib` | `typst/bibliography.bib` |
|---|---|---|
| lines / entries | 276 / **26** | 644 / **62** |
| consumers | Lean docstrings, `README.md:466`, `docs/README.md:298` | `FormalFoundations.typ:1596`, `BimodalReference.typ:232` |

**Key collisions: exactly 4** — `doets1987`, `kamp1968`, `rabinovich2014`, `reynolds1992`. 22 keys are root-only, 58 typst-only. Union = 84 entries.

All four collisions differ under the same key. I compiled each version through typst to measure the rendered output rather than guessing:

| Key | Root renders | Typst renders | Direction |
|---|---|---|---|
| `kamp1968` | `H. Kamp, "Tense Logic…," 1968.` — the `@article` type with a `school` field **silently drops the institution** | `J. A. W. Kamp, "Tense Logic…," Doctoral dissertation, 1968.` | **Take typst's `@phdthesis` + `school`**; carry root's `note` |
| `doets1987` | `K. Doets, Completeness and Definability… University of Amsterdam, 1987.` (as a book) | `K. Doets, "Completeness…," Doctoral dissertation, 1987.` | **Take typst's `@phdthesis`**; carry root's `note`; drop `verify before print` |
| `reynolds1992` | `…Studia Logica, vol. 51. pp. 165–193, 1992.` — `@incollection` with `booktitle = {Studia Logica}` (Studia Logica is a journal) | `…Studia Logica, vol. 51, 1992.` — correct `@article` + `journal`, but no pages | **Take typst's `@article` + `journal`, add root's `pages` and `note`** |
| `rabinovich2014` | `…vol. 10, no. 1:14, pp. 1–16, 2014, doi: 10.2168/…` | `…vol. 10, no. 1, 2014.` (no pages, no doi) | **Take root's** |

**Measured and decisive: typst's IEEE default does not render the `note` field.** A test bib whose `note` read `INTERNAL COMMENTARY THAT MUST NOT BE PUBLISHED` rendered as `[1] A. Rabinovich, "A Proof of Kamp's Theorem," Logical Methods in Computer Science, vol. 10, 2014.` — the note is absent. Root's internal commentary notes (`The composition-method proof … the most-cited work in this development`, `Forthcoming. The paper this repository formalizes; its pinned definitions of record are in docs/reference/…`) are therefore safe to carry into the shared file and will not leak into either PDF. Both typst documents use IEEE (`BimodalReference.typ` names it; `FormalFoundations.typ` gets it as typst's default), so this holds for both.

**Same-work-different-key duplicates** are a second, softer collision class that a naive key-union will leave behind. Six pairs name the same work:

| Root key | Typst key | Same work? |
|---|---|---|
| `burgess1982` | `burgess1982axioms` | yes (NDJFL 1982) |
| `burgess1984` | `burgess1984basic` | yes (Handbook II) |
| `gabbay1994` | `gabbayhodkinsonreynolds1994` | yes (OUP 1994) |
| `prior1967` | `prior1967pastpresentfuture` | yes (OUP 1967) |
| `goldblatt1992` | `goldblatt1992logics` | yes (CSLI 1992) |
| `blackburn2002` | `blackburnderijkevenema2001` | same book, **2001 vs 2002** — a real edition question, not a typo |

Two look like duplicates and are **not**: `venema1993` ("Since and Until", AiML) vs `venema1993antiaxioms` ("Derivation Rules as Anti-Axioms", JSL); `xu1988` ("On Some U, S-Tense Logics", JPL) vs `xu1988until` ("Until and Since: Completeness and Decidability"). Do not collapse these.

Deduplicating the six real pairs means rewriting typst citation sites. Cost is bounded and measured: `burgess1982axioms` 9 sites, `blackburnderijkevenema2001` 4, `gabbayhodkinsonreynolds1994` 2, `burgess1984basic` 2, `goldblatt1992logics` 1, `prior1967pastpresentfuture` 0 (uncited) — **18 `.typ` citation edits total**. `PUBLICATION_REFACTOR.md:64` already decides the key style ("Key style stays lowercase `authorYYYY` — a deliberate divergence, internally consistent"), which is the root file's style, so the root keys win and the typst sites are the ones that move.

8 typst keys are cited by no `.typ` file: `derijke1995sahlqvist`, `fine1975elementarymodal`, `goldblatt2003ghv`, `halmos1962`, `kowalski1998`, `prior1967pastpresentfuture`, `rumberg2019firstorder`, `venema1993antiaxioms`. 4 root keys are cited nowhere in `FormalSystem`/`Tests`/`BimodalTools`/`docs`/`README.md`: `brastmckie2026bimodallogic` (the self-citation, legitimately uncited), `prior1967`, `cmiel2021`, `fischerLadner1979`. 15 typst entries carry `note = {verify before print}`, a maintainer TODO marker that does not render; strip on merge as a tooling note.

**Files that name the typst bibliography path** (all must be re-pointed or updated): `typst/FormalFoundations.typ:1596`, `typst/BimodalReference.typ:232`, `typst/README.md:35`, `typst/README.md:43`, `typst/README.md:205`, plus `docs/development/PUBLICATION_REFACTOR.md:476` and `:597` (the spec's own prose, which will become past-tense on completion). Typst's `#bibliography()` takes a path relative to the `.typ` file, so both become `#bibliography("../references.bib", …)`.

### 3. `## Paper Specification Reference` (12) and `## Implementation Status` (4)

**All 12 `## Paper Specification Reference` headings**, every one in `FormalSystem/`:

```
Metalogic/Soundness.lean:19            Semantics/Truth.lean:31
Metalogic/Algebraic/FlowFrame.lean:28  Semantics/FrameAxioms.lean:44
Semantics/TaskFrame.lean:67            Semantics/PartialHistoryOrder.lean:17
Semantics/Extension/Admissible.lean:21 Semantics/Extension/Extension.lean:24
Semantics/Extension/Step.lean:51       Semantics/Extension/Constraint.lean:21
Semantics/PartialHistory.lean:19       MinusLanguage/MinusTruth.lean:34
```

**All 4 `## Implementation Status`**: `Theorems/ModalS5.lean:27`, `Theorems/Perpetuity.lean:32`, `Theorems/ModalS4.lean:32`, `Automation/ProofSearch/Core.lean:142`.

**These sections are not citation lists and must not be folded wholesale.** `Semantics/TaskFrame.lean`'s runs ~50 lines and contains verbatim LaTeX transcription of `def:frame`'s four axioms, the nullity derivation argument, and a "**Known gaps relative to the paper**" block that says in terms: *"The two that stood here are now closed, and are recorded as closed rather than deleted, since both were long-lived."* `Metalogic/Soundness.lean`'s contains: *"There is **no `app:valid` anchor**, and there never was: earlier revisions of this module cited `app:valid` at 'line 1984', which in the live paper is an unrelated `Ddef`… The citation and its line number were both bogus."*

Both are **historical/provenance records deliberately preserved as written**, exactly the class the dispatch flagged as the recurring failure of this run. `app:valid` is recorded `DANGLING` in `docs/reference/paper-definitions-of-record.md` with the note `NEVER EXISTED; earlier revisions cited it at a bogus line number, corrected to cor:perpetuity-valid` — the record and the docstring are a matched pair. Deleting either half breaks the other's point.

What `PUBLICATION_REFACTOR.md:219-221` actually asks: *"Paper anchors … go inside `## References` after the paper's link entry. This replaces the `## Paper Specification Reference` heading."* So: the **anchors** move into `## References`; the **transcription prose** stays in the module body (under its own descriptive heading, or under `## Implementation notes` where it is a design record). Only the heading disappears.

The 4 `## Implementation Status` sections are different — the spec says outright *"status belongs to `MainResults.lean` and `docs/theorem-index.md`"*. Check each before deleting: `Metalogic/Soundness.lean`'s `## Implementation Notes` lists **Completed Proofs** by name, and those names are the C14/C21 pinned set. Removing a *status* claim is safe; removing a *name list* the baselines read is not.

### 4. Tooling notes, personal paths, Logos/ProofChecker wording

**Personal paths — 14 occurrences, 14 files, all tilde-form:**

| Path | Count |
|---|---|
| `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` | 10 |
| `~/Projects/Literature/sources/reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md` | 4 |

10 are under `FormalSystem/Metalogic/Expressiveness/Kamp/` (`VecEACombinators`, `KMinusFaithfulRendering`, `KPlusFaithfulRendering`, `DedekindINF`, `ContentfulFaithfulBridge`, `Section5Correspondence`, and four under `EANegationFixFaithful/`); 4 under `Metalogic/WeakCanonical/DenseModelSurgery/` (`BadIntervals`, `Lemma5`, `Lemma34`, `Defs`). This matches `PUBLICATION_REFACTOR.md`'s "the personal paths in the `WeakCanonical/{Kamp,DenseModelSurgery}` docstrings" exactly — the Kamp half simply moved to `Expressiveness/` in task 635.

A second, repo-relative form exists and is a different judgement: 17 occurrences of `literature/…` (`literature/Doets_1989_Monadic_Pi11_Theories.md` ×11, `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md` ×3, `literature/sources/reynolds_1992/sec04_7-separability.md` ×3). These are not under a home directory but they name a corpus this repository does not ship. Each should become the bib citation it stands in for (`[doets1989], Section 1, Lemma 1.1` already precedes the path in most cases, so the path is redundant).

Related: 20 occurrences of "the companion markdown transcription is corrupt" — a tooling note about the maintainer's local conversion pipeline, present-tense, and exactly the class to strip. The accompanying "Cited by PDF page" is *substantive* (it tells a reader the locator convention) and should stay.

**Logos/ProofChecker — 27 occurrences in 14 files, every one classified:**

| Class | Count | Sites | Disposition |
|---|---|---|---|
| Broken `../../../Logos/Core/**` markdown links in `## References` | **16** | 8 Tests files | Repath to the live module **and** convert to the backticked form |
| `ProofChecker/Automation/Tactics.lean` path + `ProofChecker.Automation.Tactics` namespace | 2 | `Tests/BimodalTest/Automation/TacticsTest.lean:16,55` | Wrong namespace too — live is `FormalSystem.Automation.Tactics` |
| Present-tense prose "the Logos proof checker" / "Logos types" | 2 | `Tests/BimodalTest/Property.lean:15`, `Tests/BimodalTest/Property/Generators.lean:18` | Strip |
| `**ProofChecker Implementation**:` / `**ProofChecker Implementation Alignment**:` headers | 2 | `Semantics/TaskFrame.lean:97`, `Semantics/Truth.lean:55` | Strip the wording; the blocks under them are substantive |
| Present-tense prose in Examples | 3 | `Examples/TemporalStructures.lean:16,24,38` | Strip |
| `ModelChecker` | **0** | — | already absent from the Lean trees |

**No occurrence is historical or provenance.** Every one is present-tense library prose or a stale path, so the whole set is strippable — a cleaner result than the dispatch's caution anticipated. The names must nonetheless stay in `README.md` and `typst/` (CLAUDE.md records ProofChecker as the project's role name in the Logos dual-verification architecture), and the task correctly scopes the stripping to library docstrings, `Examples/` and tests.

**All 37 genuine broken path links in `.lean` docstrings**, every target resolvable:

| Target shape | Count | Fix |
|---|---|---|
| `../../../Logos/Core/**` | 16 | live module path |
| `../../../docs/user-guide/architecture.md` | 10 | depth is one `../` too many from `FormalSystem/{Semantics,Syntax,ProofSystem,Theorems}/` |
| `../../../docs/Development/PROPERTY_TESTING_GUIDE.md` | 2 | case: `docs/development/` |
| `Propositional.lean` from `Theorems/{ModalS4,ModalS5,Combinators}.lean` | 3 | no such file; `Theorems/Propositional/` is a directory |
| `Automation/{Tactics,ProofSearch}.lean` from `FormalSystem/Automation.lean` | 2 | both are directories |
| `../../{ProofSystem/Derivation,Semantics/Validity}.lean` from `Metalogic/Soundness.lean` | 2 | one `../` too many |
| `../../../docs/development/LEAN_STYLE_GUIDE.md` | 1 | depth |
| `../../../../docs/user-guide/architecture.md` | 1 | depth |

Nothing gates these: C13 walks `docs/` + `README.md` only, C5 matches module-shaped `FormalSystem.*` paths in markdown only, and `readme-lint.sh` reads `README.md` files. Converting them to backticked repo-relative paths removes the whole failure mode, because a repo-relative path has no depth to get wrong.

**Other tooling-note markers inside `## References` blocks**: 22 markdown-transcription notes, 18 literature paths, 15 phase/report references (e.g. `- plan v39 Phase 11; Phase 10 "Re-scoped on resume" note` in `Kamp/NfZoneDepthK.lean`, and the "negfix-refactor design … Phase 13/14a/16a" family under `NfMultiAnchorBridge/`), 10 "Design provenance:" entries, 1 measured-benchmark line. The `Phase N` family is task history in a References block; C9 gates task *numbers* but not plan-version or phase citations, which is why it survived.

### 5. Blast radius and the gates that can actually break

**Candidate edit set: 295 files** (those carrying any of the three headings, or `Logos`/`ProofChecker`, or a `~/Projects/` path).

**C20 tier 1 (gated) — 582 of 1028 citations at risk.** 66 files in the edit set are themselves the *target* of a `file.lean:NNN` citation. Worst-exposed targets:

| Citations into it | Target |
|---|---|
| 72 | `Metalogic/Expressiveness/Kamp/KPlusFaithful.lean` |
| 39 | `Metalogic/Expressiveness/Kamp/PriorINF.lean` |
| 38 | `Metalogic/Expressiveness/Kamp/DedekindINF.lean` |
| 30 | `Metalogic/Expressiveness/Kamp/KampPrior.lean` |
| 27 | `Syntax/Formula.lean` |
| 22 | `Metalogic/Expressiveness/NormalForm.lean` |
| 20 | `Metalogic/Expressiveness/Kamp/KPlusFaithfulRendering.lean` |
| 18 | `ProofSystem/Axioms.lean`, `Metalogic/Decidability/Tableau.lean` |

**The structural fact that makes this mechanisable: 297 of the 298 target headings are inside the module docstring at the head of the file** (the single exception is `BimodalTools/TraceExporterMain.lean:80`). Every edit therefore shifts everything below the docstring by one per-file integer. The repair is exact:

```
for each edited file F:
    Δ = new_line_count(F) - old_line_count(F)
    docstring_end = last line of F's leading /-! … -/ block, BEFORE the edit
    for every citation "F.lean:N" anywhere in scope with N > docstring_end:
        rewrite to N + Δ
```

Run it per commit, then `bash scripts/check-module-invariants.sh --no-build` to confirm C20 tier 1 still reports 1028 resolvable citations all landing on non-blank lines. Note C20's own resolver matches on basename when the citation is unqualified, so an *ambiguous* basename is reported `unverifiable` rather than failed — do not let that mask a real shift.

**INV (gated).** Generated inventory blocks carry `cols=files-lines` and a `desc=` column sourced from module docstrings. `FormalSystem/README.md:247`, `FormalSystem/Metalogic/README.md` (4 blocks), `README.md:19`, `Tests/BimodalToolsTest/README.md:26` and the Boneyard set are all line-count- or description-sensitive. The dispatch note is confirmed: docstring edits stale these. Remedy is `bash scripts/check-module-invariants.sh --emit-inventory`, then `--emit-inventory --check` to confirm byte-stability.

**C15 — the `sub:` blind spot is real and must be left alone.** C15's regex is `\b(def|thm|lem|cor|app|rmk):[A-Za-z0-9][A-Za-z0-9_-]*`; it does not match `sub:`. Six `sub:` anchors are live in the tree across 55 occurrences (`sub:Extension` 19, `sub:Logic` 17, `sub:RestrictedModalities` 15, `sub:OpenFuture` 2, `sub:NecessarilyAlways` 1, `sub:Soundness` 1), several of them in the L+ blocks the first task authored. Rewriting a `sub:` citation into a `def:`/`app:` shape would make C15 see it for the first time and almost certainly fail, since none has a record row. **Leave every `sub:` citation verbatim.**

**C15 — do not re-break the label citations.** The first task of this run replaced manuscript line-number citations with label citations in the L+ files and pinned `def:BLstar-semantics` in the record (`docs/reference/paper-definitions-of-record.md:1704`, manifest hash at `:2029`). The current 59 resolving anchors are the state to preserve; the count may legitimately rise as `## Paper Specification Reference` anchors move into `## References`, but must never fall, and no *new* anchor may appear without a MANIFEST or KNOWN-ANCHORS row.

**C14.** Its content half scans `docs/` + `README.md` + `FormalSystem/**/*.lean` docstrings for stale axiom/sorry counts. Any rewording that touches a stated count (the tree has 404 `sorry`-mentioning lines and `allAxiomNames` is pinned twice by C22) must preserve the number. `Metalogic/Soundness.lean`'s "Completed Proofs" name list and its "**The time-shift consumer set**" section ("exactly **one schema** … exactly **two declarations**") are count-bearing prose inside a file this task edits.

**C19.** 94.01% against a 90% floor. The sweep removes prose from module `/-!` blocks, and C19's refinement gives *section credit* from `/-!` comments — so deleting a `/-!` section can demote declarations from documented to undocumented. Margin is ~440 declarations, which is ample, but re-measure the number rather than assuming.

**Not at risk**: C2/C14's `#print axioms` halves, C22, C21, C23, C26–C30 (all read declarations or `set_option` lines, none of which this task touches); typst Checks 2/2b/3 (axiom, rule and sorry counts, not line counts).

### Recommendations

1. **Order the work merge-first.** Sub-task 2 (bib merge) unblocks sub-task 1: 84 keys must exist in the root file before prose citations like `Thomason, *Combinations of Tense and Modality* (1984)` can become `[R. H. Thomason, …][thomason1984]`.
2. **Adopt the three-way `## References` normal form** already validated in the L+/L⋆/L− blocks, rather than the bibliography-only reading of the template. It converts 713 entries instead of deleting 532, and it repairs 37 broken links as a side effect.
3. **Make the C20 re-anchor script a phase deliverable, not a fix-up.** Write it before the first docstring edit, run it after every batch, and gate each commit on `--no-build` reporting 1028 resolvable citations still landing on non-blank lines.
4. **Phase by gate-safety, not by directory.** A sensible cut: (a) bib merge + typst re-point + 18 `.typ` key edits — touches no `.lean`, so C20/INV cannot move, and `typst compile` is the whole acceptance; (b) the Logos/ProofChecker/broken-link/personal-path strip in `Tests/` and `Examples/` — few citation targets; (c) the bulk `## References` conversion in `FormalSystem/` + `BimodalTools/`, batched with the re-anchor script; (d) the 12 `## Paper Specification Reference` folds and 4 `## Implementation Status` removals, hand-reviewed file by file because of the historical prose; (e) `--emit-inventory` + full harness + both typst compiles.
5. **Replace the acceptance grep.** `grep -rn 'home/benjamin' FormalSystem Tests` is vacuously green today. Use `grep -rnE '(/home/|~/Projects/|/Users/)' FormalSystem Tests BimodalTools` → empty, and separately assert the 17 repo-relative `literature/…` pointers are gone.
6. **Record, do not repair, the two red adjacent baselines.** `readme-lint.sh` (21 broken `../Boneyard/` refs) and `typst-sync-check.sh` Check 1 (9 `docs/training/PIPELINE.md` violations) belong to other work. Re-measure both at the end and assert the counts are unchanged, so the sweep is provably not the cause of a new one.
7. **Zero-debt note**: nothing here requires a `sorry`, an axiom, or a deferral. This is a documentation sweep over a green tree; every sub-task is mechanically completable, and the only genuine unknown is the two unresolved bibkeys (below).

## Decisions

- **`BimodalTools/` is in scope.** Git-verified: all 25 modules were under `FormalSystem/` when the task was written; C15 already gates them; they are tooling, and "strip tooling notes" is a named sub-task.
- **`Boneyard/` is out of scope.** Archived, `#exit`-headed, excluded from every harness walk; its 17 provenance READMEs carry frozen historical stamps.
- **`Tests/` is in scope for both the strip and the `## References` conversion** — named by the task for the strip, and holds 16 `## References` blocks including all 16 broken `Logos/Core/` links.
- **Bib merge direction is per-key, not per-file.** Take typst's entry *type and structural fields* for `kamp1968`, `doets1987` and `reynolds1992`; take root's whole entry for `rabinovich2014`; carry root's `note` fields throughout (measured: they do not render under typst's IEEE default). Root's lowercase `authorYYYY` key style wins for the six same-work-different-key pairs, costing 18 `.typ` citation edits.
- **`venema1993`/`venema1993antiaxioms` and `xu1988`/`xu1988until` are different works** and are not collapsed.
- **`sub:` anchors are left verbatim.** C15 does not read them, and rewriting one into a gated prefix would fail a green gate.
- **`## Paper Specification Reference` loses its heading, not its content.** Anchors move into `## References`; verbatim transcription and the recorded-history blocks (TaskFrame's "Known gaps … recorded as closed rather than deleted", Soundness's "`app:valid` … never existed") stay in the body.
- **Nothing in the 27 Logos/ProofChecker occurrences is historical**, so the whole set is strippable from `.lean`; `README.md` and `typst/` keep the names.

## Risks & Mitigations

| Risk | Evidence | Mitigation |
|---|---|---|
| C20 tier 1 (gated) goes red on the first commit | 582/1028 citations point into the 295-file edit set | Per-file Δ re-anchor script, run before each commit; 297/298 headings are in the leading docstring so Δ is a single integer per file |
| INV (gated) goes stale | inventory blocks carry `cols=files-lines` and docstring-sourced `desc=` | `--emit-inventory`, then `--emit-inventory --check` |
| Mechanical rewriting falsifies a historical statement | TaskFrame's closed-gaps record; Soundness's bogus-`app:valid` record; 17 Boneyard provenance READMEs; `typst/SYNC-MAP.md` | Hand-review the 12 + 4 section folds; never bulk-delete a block containing "earlier revisions", "recorded as", "used to", "now closed" |
| C15 breaks on a newly-visible anchor | C15 matches `def\|thm\|lem\|cor\|app\|rmk:` only; 55 live `sub:` citations have no record rows | Leave `sub:` verbatim; assert the resolving count never falls below 59; add a record row before introducing any new anchor |
| The green acceptance grep masks a no-op | `grep -rn 'home/benjamin' FormalSystem Tests` already returns 0 | Gate on the 14 `~/Projects/` occurrences and the 17 `literature/…` pointers instead |
| Typst regression from the merged bib | Both documents compile today; the four collisions render differently per source | Compile both `.typ` files after the merge and diff the rendered bibliography, not just the exit code |
| Two bibkeys resolve to nothing | `stavi1979`, `gabbay1980` in `Metalogic/Expressiveness.lean:67,69` | See User Decision |
| C14 count claims broken by rewording | 404 `sorry`-mentioning lines; `Soundness.lean`'s "one schema … two declarations" | Preserve every number verbatim; C14's content half runs under `--no-build`, so check after each batch |
| C19 drops below the floor | 94.01% vs 90%; deleting a `/-!` section removes its coverage credit | Re-measure per batch; ~440-declaration margin is ample but not unlimited |
| `lake build` green is mistaken for the gate | build is green today and stays green under comment-only edits | Gate on the build-inclusive `check-module-invariants.sh`, not on `lake build` |

## Tactic Survey Results

- Not applicable (no tactic survey performed). This task changes only comments and documentation; it introduces no proof obligation, so the LeanHammer portfolio has nothing to act on. `lake build` at HEAD is green (2651 jobs) and every edit in scope is comment-only, so build behaviour is invariant by construction.

## Context Extension Recommendations

- **Topic**: Relative markdown links inside `.lean` docstrings are ungated.
  **Gap**: C13 walks `docs/` + `README.md`, C5 matches module-shaped `FormalSystem.*` paths in markdown only, and `readme-lint.sh` reads `README.md` files. 37 broken path-shaped links have accumulated in `.lean` docstrings, 16 of them pointing at a `Logos/Core/` layout two renames old.
  **Recommendation**: after this task normalises them to backticked repo-relative paths, add a harness check (a natural C31, or an extension of C12's slash-path resolver to `.lean` docstrings) asserting every backticked repo-relative path in a live `.lean` docstring resolves. The `typst-sync-check.sh` Check 1 backtick resolver is a working prototype to lift.

- **Topic**: Bracket-bibkey citations are ungated.
  **Gap**: C15 resolves paper anchors against the record but nothing resolves `[bibkey]` against `references.bib`. `stavi1979` and `gabbay1980` have been dangling undetected.
  **Recommendation**: a C15-shaped companion assertion — every `[key]` in live `.lean`/`.md` scope has a `@type{key,` row in the root `references.bib` — becomes cheap the moment this task makes the root file the single bibliography.

- **Topic**: Plan-version and phase citations in library docstrings.
  **Gap**: C9 gates task-number citations under `FormalSystem/` but not `plan v39 Phase 11`, `Report 01`, or `the negfix-refactor design … Phase 16a`. 15 such entries sit inside `## References` blocks.
  **Recommendation**: extend `scripts/lib/task-reference-patterns.sh` with a plan-version/phase pattern class, so C9 covers the same deliverable-hygiene ground for both shapes.

## Appendix

### Commands run

```
bash scripts/check-module-invariants.sh --no-build        # structural baseline, ALL PASS
lake build                                                 # exit 0, 2651 jobs
bash scripts/check-module-invariants.sh                    # build-inclusive, ALL PASS
bash scripts/readme-lint.sh                                # FAIL, 21 broken refs (pre-existing)
bash scripts/typst-sync-check.sh                           # FAIL, Check 1 = 9 (pre-existing)
typst compile typst/BimodalReference.typ                   # exit 0
typst compile typst/FormalFoundations.typ                  # exit 0
git log --follow --name-status -- BimodalTools/*.lean      # BimodalTools provenance
```

Plus python passes (in-session, not committed) for: `## References` entry-shape classification; the heading-inside-module-docstring test; C20 target/citer exposure against the candidate edit set; relative-link resolution in `.lean` docstrings; bib key-set comparison. A typst round-trip on a synthetic bib established that the IEEE default does not render `note`.

### Reference locations

- Target template and Phase 7 acceptance: `docs/development/PUBLICATION_REFACTOR.md:182-221`, `:474-483`, `:594-602`
- C15 implementation and scope: `scripts/check-module-invariants.sh:1940-2022`
- C20 implementation and both tiers: `scripts/check-module-invariants.sh:2140-2302`
- C19 floor: `scripts/check-module-invariants.sh:3194-3362`
- Anchor record, `app:valid` DANGLING row: `docs/reference/paper-definitions-of-record.md:2082`
- `def:BLstar-semantics` pin: `docs/reference/paper-definitions-of-record.md:1704`, manifest hash `:2029`
- Gold-standard `## References` blocks: `FormalSystem/PlusLanguage/{PlusTruth,Formula,PlusStateLocal,PlusLimitClosure}.lean`
- Unresolved bibkeys: `FormalSystem/Metalogic/Expressiveness.lean:67,69`
- Typst bibliography call sites: `typst/FormalFoundations.typ:1596`, `typst/BimodalReference.typ:232`

### User decision pending

The two unresolved bibkeys need a judgement research cannot make from the artifacts:

- **`stavi1979`** — cited as "the Stavi connectives completing the Dedekind-incomplete case". No entry in either bib file. Almost certainly J. Stavi, "Functional completeness over the rationals" (1979), but the repository holds no bibliographic record of it, and `FormalSystem/Metalogic/Expressiveness/StaviConnectives.lean` cites `gabbay1994` Chapter 9 §3 for the same content rather than Stavi directly.
- **`gabbay1980`** — cited as "the separation property". Candidates include Gabbay's 1981 "Expressive functional completeness in tense logic" and `gabbayhodkinsonreynolds1994` Chapter 10, which the tree already cites for separation elsewhere.

Either add two new `references.bib` entries (needs the correct bibliographic data) or re-point both citations to existing keys (needs the maintainer's view on whether the secondary source is the intended citation). The plan can proceed on everything else regardless; this affects two lines in one file.
