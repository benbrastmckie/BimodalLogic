# Implementation Plan: Docstring and Citation Normalisation

- **Task**: 636 - Docstring and citation normalisation
- **Status**: [NOT STARTED]
- **Effort**: 15 hours
- **Dependencies**: 635 (landed at `eae409d04`)
- **Research Inputs**: `specs/636_docstring_and_citation_normalisation/reports/01_docstring-citation-normalisation.md`
- **Artifacts**: plans/01_docstring-citation-normalisation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Normalise every `## References` block in the live Lean trees (`FormalSystem/`, `BimodalTools/`,
`Tests/`) to a single three-way normal form, merge `typst/bibliography.bib` into the root
`references.bib` so one bibliography serves both Lean docstrings and both typst documents, fold
the 12 `## Paper Specification Reference` headings into `## References` and remove the 4
`## Implementation Status` headings, and strip tooling notes, personal paths and
Logos/ProofChecker wording from library docstrings, `Examples/` and tests. The work is
comment-only across roughly 295 files; it introduces no proof obligation and cannot change
elaboration behaviour, but it *can* break two gated invariants (C20 tier 1 and INV) because every
docstring edit shifts the line numbers that 582 of the tree's 1028 `file.lean:NNN` citations point
at. Done means: the per-form acceptance counts below have moved from their measured red baseline
to green, the full build-inclusive `scripts/check-module-invariants.sh` is ALL PASS, both typst
documents compile, and the two known-red adjacent baselines are re-measured *unchanged*.

### Research Integration

The report at `reports/01_docstring-citation-normalisation.md` is integrated throughout. Its four
load-bearing findings drive the phase structure:

1. **Every acceptance gate is already green at HEAD**, including the literal
   `grep -rn 'home/benjamin' FormalSystem Tests` (0 hits). The task's acceptance criteria as
   written cannot evidence that the work happened. This plan replaces them with per-form counts
   that are measurably red now (Testing & Validation, below), re-verified at the time of writing
   this plan: 0 entries in target citation form, 197 in the old bare form, 14 personal paths, 17
   repo-relative `literature/` pointers, 27 Logos/ProofChecker occurrences, 12 `## Paper
   Specification Reference`, 4 `## Implementation Status`.
2. **C20 tier 1 is the dominant regression risk and it is gated.** 582/1028 citations point into
   the edit set; 297 of the 298 target headings sit in the leading module docstring, so each
   edited file shifts everything below it by one integer Δ. The re-anchor tool is therefore a
   Phase 2 deliverable written *before* the first docstring edit, not a fix-up.
3. **`## References` is mostly not a bibliography**: 181 bibliographic entries against 532 module
   cross-references. The plan adopts the three-way normal form already validated in the
   L+/L⋆/L− blocks (`FormalSystem/PlusLanguage/PlusLimitClosure.lean:75-84`) rather than the
   bibliography-only reading of `PUBLICATION_REFACTOR.md`'s template. Cross-references are
   converted, never deleted.
4. **Merge-before-convert.** 58 typst-only bibkeys (e.g. `thomason1984`) must exist in the root
   file before prose citations can be converted to `* [Author, *Title*][key]` form.

`BimodalTools/` is in scope (git-verified: all 25 modules were under `FormalSystem/` when the
task was written; C15 already walks them; they hold the densest tooling-note prose).
`Boneyard/` is out of scope. `Tests/` is in scope for both the strip and the conversion.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` Phase 5 "Publication and Documentation". This task is the citation-form
normalisation half of that phase; Task 177 (README/docs/module-docstring final polish, drift
re-audit plus the Axiom Reference update) depends on it and is deliberately left separate. The
roadmap is consulted read-only; this plan does not modify it and adds no roadmap review/update
phases (no `roadmap_flag` in the delegation context).

## Goals & Non-Goals

**Goals**:
- Single bibliography: `typst/bibliography.bib` merged into root `references.bib` (union of 84
  entries, 6 same-work key pairs deduplicated to root's lowercase `authorYYYY` style), both
  `.typ` documents re-pointed at `../references.bib`.
- One `## References` normal form across `FormalSystem/`, `BimodalTools/` and `Tests/`:
  bibliographic entries as `* [Author, *Title*][key], locator`; paper anchors as
  `` * JPL paper `file.tex`: `def:x` ``; module cross-references as
  `` * `Repo/Relative/Path.lean` — description ``.
- Zero `## Paper Specification Reference` and zero `## Implementation Status` headings, with the
  substantive prose under them preserved in the module body.
- Zero personal paths, zero repo-relative `literature/…` pointers, zero Logos/ProofChecker
  occurrences, and zero broken relative path links in live `.lean` docstrings.
- C20 tier 1, INV, C14, C15 and C19 all still green at the end, re-measured build-inclusive.

**Non-Goals**:
- Any change under `Boneyard/` (archived, `#exit`-headed, frozen provenance stamps).
- Removing the ProofChecker/Logos names from `README.md`, `CLAUDE.md` or `typst/`, where
  ProofChecker is the project's recorded role name in the Logos dual-verification architecture.
- Fixing the two known-red adjacent baselines (`readme-lint.sh`'s 21 broken `../Boneyard/` refs;
  `typst-sync-check.sh` Check 1's 9 `docs/training/PIPELINE.md` violations). They belong to other
  work and are re-measured, not repaired.
- Any mathematics, any proof, any `sorry`, any axiom. No `.lean` code outside comments is touched.
- Authoring new bibliography entries whose bibliographic details cannot be verified from inside
  this repository (see Phase 1's isolated bibkey item).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C20 tier 1 (gated) goes red: 582/1028 citations point into the edit set | H | H | Phase 2 delivers the per-file Δ re-anchor tool before the first docstring edit. Run it at the END of each file-set phase, after all line-count-changing edits in that set, never interleaved. Gate each commit on `--no-build` reporting 1028 resolvable citations all landing on non-blank lines. |
| INV (gated) goes stale: inventory blocks carry `cols=files-lines` and docstring-sourced `desc=` | H | H | `bash scripts/check-module-invariants.sh --emit-inventory` then `--emit-inventory --check` at the close of each file-set phase. Never hand-edit a generated block. |
| Mechanical rewriting falsifies a historical or provenance statement | H | H | **This was the recurring failure of this run** (17 Boneyard provenance READMEs, `typst/SYNC-MAP.md`, several ADRs). Never bulk-delete a block containing "earlier revisions", "recorded as", "used to", "now closed", "never existed". The 12 PSR folds and 4 status removals are hand-reviewed file by file (Phases 5, 6, 8), and `Semantics/TaskFrame.lean`'s "Known gaps … recorded as closed rather than deleted" and `Metalogic/Soundness.lean`'s "`app:valid` … never existed" blocks are preserved verbatim in the module body. |
| C15 breaks on a newly-visible anchor | H | M | C15's regex is `\b(def\|thm\|lem\|cor\|app\|rmk):…` and does **not** match `sub:`. 6 `sub:` anchors are live across 55 occurrences, several in the L+ blocks the first task of this run authored. **Leave every `sub:` citation verbatim** — converting one to a gated prefix would turn a green gate red. Assert the resolving count never falls below 59. No new `def\|thm\|lem\|cor\|app\|rmk` anchor without a MANIFEST or KNOWN-ANCHORS row first. |
| The label citations the first task of this run wrote into the L+/L⋆/L− files are re-broken | H | M | Those files are the normal-form gold standard, not conversion targets. Treat their `## References` blocks as already-converted; diff-check them unchanged except where a bibkey gains its `[Author, *Title*][key]` wrapper. `def:BLstar-semantics` is pinned at `docs/reference/paper-definitions-of-record.md:1704` with a manifest hash at `:2029`. |
| The green acceptance grep masks a no-op | H | H (already true) | `grep -rn 'home/benjamin' FormalSystem Tests` returns 0 today. Gate on the widened grep and the per-form counts in Testing & Validation instead. |
| C14 count claims broken by rewording | M | M | 404 `sorry`-mentioning lines; `Metalogic/Soundness.lean`'s "exactly **one schema** … exactly **two declarations**" and its "Completed Proofs" name list (the C14/C21 pinned set) are count-bearing prose inside an edited file. Preserve every number and every declaration name verbatim. C14's content half runs under `--no-build`, so it is checked every batch. |
| C19 drops below the 90% floor | M | L | 94.01% today (10261/10915); C19 gives section credit from `/-!` comments, so deleting a `/-!` section can demote declarations. ~440-declaration margin. Re-measure the percentage per batch rather than assuming. |
| Typst regression from the merged bib | M | M | The 4 colliding keys render differently per source. After the merge, compile both documents AND diff the rendered bibliography pages, not just the exit code. |
| Two bibkeys resolve to nothing (`stavi1979`, `gabbay1980`) | L | Certain | Non-blocking user decision, unanswered. Phase 1 carries an isolated default; see that phase. |
| `lake build` green mistaken for the gate | M | M | The build is green today and stays green under comment-only edits, so it proves nothing. **Gate on the build-inclusive `scripts/check-module-invariants.sh`**, not on `lake build`. |
| Long commands never complete because the agent waited on a background job | M | M | Observed repeatedly in this run: agents that backgrounded a build or waited on a monitor were never woken. Run every long command as a **foreground blocking call with `timeout: 600000`**, re-invoked until it returns. Never background `lake build` or the invariants harness. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |

Phases within the same wave can execute in parallel. Phases 3-9 are deliberately serialized
despite touching disjoint file sets: each ends by running the re-anchor tool over the *whole*
tree (citers of an edited file live anywhere), so two concurrent batches would race on the same
citer files.

---

### Phase 1: Merge bibliographies and re-point typst [NOT STARTED]

- **Goal:** One bibliography at the repo root serving both Lean docstrings and both typst
  documents, with every key a later phase will cite already present.
- **Tasks:**
  - [ ] Union `typst/bibliography.bib` (62 entries) into root `references.bib` (26 entries).
        22 root-only keys and 58 typst-only keys carry over unchanged.
  - [ ] Resolve the 4 colliding keys per the measured per-key direction, not "root wins":
        `kamp1968` take typst's `@phdthesis` + `school`, carry root's `note`;
        `doets1987` take typst's `@phdthesis`, carry root's `note`, drop `verify before print`;
        `reynolds1992` take typst's `@article` + `journal`, add root's `pages` and `note`;
        `rabinovich2014` take root's entry whole (it alone has pages and a doi).
  - [ ] Deduplicate the 6 same-work-different-key pairs to root's lowercase `authorYYYY` style:
        `burgess1982axioms`→`burgess1982`, `burgess1984basic`→`burgess1984`,
        `gabbayhodkinsonreynolds1994`→`gabbay1994`, `prior1967pastpresentfuture`→`prior1967`,
        `goldblatt1992logics`→`goldblatt1992`, `blackburnderijkevenema2001`→`blackburn2002`
        (same book; keep the root key, keep whichever year field the surviving entry carries and
        note the 2001/2002 edition question in the entry's `note`).
  - [ ] Do **not** collapse `venema1993`/`venema1993antiaxioms` or `xu1988`/`xu1988until` —
        confirmed different works.
  - [ ] Rewrite the 18 `.typ` citation sites the dedup moves: `burgess1982axioms` 9,
        `blackburnderijkevenema2001` 4, `gabbayhodkinsonreynolds1994` 2, `burgess1984basic` 2,
        `goldblatt1992logics` 1, `prior1967pastpresentfuture` 0 (uncited).
  - [ ] Strip the 15 `note = {verify before print}` maintainer markers on merge (a tooling note).
        Carry root's substantive `note` fields through: measured, typst's IEEE default does not
        render `note`, so internal commentary cannot leak into either PDF.
  - [ ] Re-point `typst/FormalFoundations.typ:1596` and `typst/BimodalReference.typ:232` to
        `#bibliography("../references.bib", …)`; update `typst/README.md:35,43,205`. Delete
        `typst/bibliography.bib` once both documents compile against the root file.
  - [ ] **ISOLATED ITEM — user-overridable default.** The two dangling bibkeys at
        `FormalSystem/Metalogic/Expressiveness.lean:67,69` (`stavi1979`, `gabbay1980`) resolve to
        nothing in either bibliography. The user was asked and has not answered. **Default:
        re-point each to an existing, already-verified key for the same content** —
        `stavi1979` → `gabbay1994` Ch. 9 §3 (which
        `FormalSystem/Metalogic/Expressiveness/StaviConnectives.lean` already cites for exactly
        this content), `gabbay1980` → `gabbay1994` Ch. 10 (the tree's usual separation citation;
        note this is the same OUP 1994 volume the dedup above keeps under the root key).
        Rationale: a new entry's bibliographic details cannot be verified from inside this
        repository, and an invented citation is worse than a re-pointed one. **This item is
        isolated so it can be changed without touching the rest of the sweep.** If on inspection
        the existing keys do NOT cover the cited content, **leave both lines exactly as they are
        and report it** — do not invent an entry.
  - [ ] Update `docs/development/PUBLICATION_REFACTOR.md:476,597` (its own prose naming the typst
        bibliography path) to past tense.
- **Timing:** 1.5 hours
- **Depends on:** none
- **Verification Tier:** interface
- **Commit Mode:** atomic-batch
- **Scope Hypothesis:** Asserted: 26 + 62 entries union to 84; exactly 4 key collisions; exactly 6
  same-work pairs; exactly 18 `.typ` citation sites move; 15 `verify before print` markers.
  Confirm at implementation time with `grep -c '^@' references.bib typst/bibliography.bib`, a
  key-set diff of the two files, and `grep -rn '@burgess1982axioms\|@blackburnderijkevenema2001\|@gabbayhodkinsonreynolds1994\|@burgess1984basic\|@goldblatt1992logics\|@prior1967pastpresentfuture' typst/`
  before editing. Report any divergence rather than silently absorbing it.
- **Files to modify**:
  - `references.bib` — becomes the union of 84 entries
  - `typst/bibliography.bib` — deleted after both documents compile against the root file
  - `typst/FormalFoundations.typ`, `typst/BimodalReference.typ` — `#bibliography()` path + key sites
  - `typst/chapters/*.typ` — the remaining dedup'd citation sites
  - `typst/README.md` — 3 path references
  - `FormalSystem/Metalogic/Expressiveness.lean` — 2 lines, isolated item only
  - `docs/development/PUBLICATION_REFACTOR.md` — 2 prose lines
- **Verification**:
  - `grep -c '^@' references.bib` reports 84 (or the confirmed union count)
  - `typst compile typst/BimodalReference.typ` and `typst compile typst/FormalFoundations.typ`
    both exit 0 (pre-existing "new computer modern sans" font warnings only)
  - The rendered bibliography pages of both PDFs are diffed against a pre-merge render; every
    entry that changed is one of the 4 collisions or 6 dedups, and changed in the intended direction
  - No `.typ` file still cites a dedup'd key: the six-key grep above returns empty
  - `test ! -e typst/bibliography.bib`
  - Every bibkey cited anywhere in `FormalSystem/ Tests/ BimodalTools/` `.lean` docstrings resolves:
    `comm -23 <(grep -rhoE '\[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean | tr -d '[]' | sort -u) <(grep -oE '^@[a-z]+\{[^,]+' references.bib | sed 's/.*{//' | sort -u)`
    returns empty (today it returns `gabbay1980` and `stavi1979`)

---

### Phase 2: Build the re-anchor and normal-form toolchain [NOT STARTED]

- **Goal:** The C20 citation re-anchor tool exists, is validated against HEAD, and the `##
  References` normal form is written down once so all seven conversion batches are consistent.
- **Tasks:**
  - [ ] Write `scripts/reanchor-lean-citations.py`. Contract, per the research's measured
        structure (297 of 298 target headings are inside the leading `/-! … -/` module docstring,
        so each edited file shifts by a single integer):
        ```
        for each edited file F:
            Δ = new_line_count(F) - old_line_count(F)
            docstring_end = last line of F's leading /-! … -/ block, BEFORE the edit
            for every citation "F.lean:N" anywhere in scope with N > docstring_end:
                rewrite to N + Δ
        ```
        Scope for the rewrite is every `.lean` docstring and every `.md` under `docs/`, `README.md`
        and `typst/` — wherever C20 tier 1 resolves citations from.
  - [ ] Handle the one structural exception explicitly: `BimodalTools/TraceExporterMain.lean:80`
        is the single target heading NOT inside the leading docstring. Special-case or hand-repair it.
  - [ ] Make the tool refuse to run on a file whose leading-docstring boundary it cannot locate,
        rather than guessing.
  - [ ] Validate the tool against HEAD: run it with a synthetic Δ=0 over the whole tree and
        assert byte-identical output (a no-op must be a no-op).
  - [ ] Note C20's resolver quirk in the tool's header: an *unqualified* citation is matched on
        basename, and an ambiguous basename is reported `unverifiable` rather than failed. Do not
        let that status mask a real shift — the per-batch check asserts the *resolvable* count
        stays at 1028, not merely that nothing FAILED.
  - [ ] Write `docs/development/reference-normal-form.md` (or an equivalent section appended to
        `PUBLICATION_REFACTOR.md`) fixing the three-way normal form, with the L+ block at
        `FormalSystem/PlusLanguage/PlusLimitClosure.lean:75-84` quoted as the worked example:
        - bibliographic: `* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4`
        - paper anchor: `` * JPL paper `possible_worlds.tex`: `def:BLstar-semantics` `` — and the
          standing rule that **`sub:` anchors are copied verbatim, never reshaped**
        - module cross-reference: `` * `FormalSystem/Semantics/Truth.lean` — the six L clauses ``
          (repo-relative, backticked; a repo-relative path has no `../` depth to get wrong, which
          is what removes the 37-broken-link failure mode)
  - [ ] Record the baseline numbers the later phases assert against, measured fresh, in that same
        document or in the task's progress file: C20 tier 1 resolvable count, C15 resolving-anchor
        count, C19 refined percentage, `readme-lint.sh` broken-ref count, `typst-sync-check.sh`
        Check 1 violation count.
- **Timing:** 1.5 hours
- **Depends on:** none
- **Verification Tier:** local
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted: 1028 resolvable C20 tier-1 citations, 582 of them pointing into
  the ~295-file edit set across 66 distinct target files; 59 C15 resolving anchors; C19 at
  94.01% (10261/10915); `readme-lint.sh` 21 broken refs; `typst-sync-check.sh` Check 1 = 9.
  Confirm every one by running `bash scripts/check-module-invariants.sh --no-build`,
  `bash scripts/readme-lint.sh` and `bash scripts/typst-sync-check.sh` at the START of this phase
  and recording the actual figures. Every later phase asserts against the recorded figures, not
  against the numbers written here.
- **Files to modify**:
  - `scripts/reanchor-lean-citations.py` — new; the per-file Δ citation re-anchor tool
  - `docs/development/reference-normal-form.md` — new; the normal form and the recorded baselines
- **Verification**:
  - Δ=0 dry run over the whole tree produces zero byte changes
  - A synthetic single-file test (insert 3 lines into a scratch copy of a heavily-cited file,
    run the tool, confirm every citation into it moved by exactly 3 and no citation into any
    other file moved)
  - `bash scripts/check-module-invariants.sh --no-build` still ALL PASS after the phase (the tool
    and the new doc are additive; `docs/` is in C13/C14 scope so the new file must itself conform)
  - Note: `scripts/` is not in this task's declared `file_scope`. That field is descriptive, not
    enforced, but flag the addition in the phase commit message.

---

### Phase 3: Tests/ and FormalSystem/Examples/ [NOT STARTED]

- **Goal:** The smallest, most self-contained file set converted end to end, proving the toolchain
  and the normal form before the bulk batches commit to them.
- **Tasks:**
  - [ ] Convert the 16 `## References` blocks in `Tests/` to the normal form. All are
        cross-reference-only; all 16 of their `../../../Logos/Core/**` links are broken.
  - [ ] Repath those 16 links to the live modules AND convert them to the backticked
        repo-relative form (both changes in one edit — the repath alone leaves the depth-fragile
        markdown-link shape in place).
  - [ ] `Tests/BimodalTest/Automation/TacticsTest.lean:16,55` — the path
        `ProofChecker/Automation/Tactics.lean` and the namespace `ProofChecker.Automation.Tactics`
        are BOTH wrong; the live namespace is `FormalSystem.Automation.Tactics`.
  - [ ] Strip the present-tense Logos prose at `Tests/BimodalTest/Property.lean:15` and
        `Tests/BimodalTest/Property/Generators.lean:18`.
  - [ ] Strip the present-tense Logos/ProofChecker prose at
        `FormalSystem/Examples/TemporalStructures.lean:16,24,38` and convert the 3 `Examples/`
        `## References` blocks.
  - [ ] Repair the `../../../docs/Development/PROPERTY_TESTING_GUIDE.md` case error (it is
        `docs/development/`) as part of the backticked-path conversion.
  - [ ] Run `python scripts/reanchor-lean-citations.py` over this file set at the END of the
        phase, after all edits — not interleaved.
  - [ ] `bash scripts/check-module-invariants.sh --emit-inventory` then `--emit-inventory --check`.
- **Timing:** 1 hour
- **Depends on:** 1, 2
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted: 16 `## References` blocks in `Tests/`, 3 in
  `FormalSystem/Examples/`, 16 broken `Logos/Core/` links across 8 Tests files, 5 present-tense
  Logos/ProofChecker prose sites. Confirm with
  `grep -rlc '^## References' Tests FormalSystem/Examples --include=*.lean` and
  `grep -rn 'Logos\|ProofChecker' Tests FormalSystem/Examples --include=*.lean` before editing.
- **Files to modify**:
  - `Tests/BimodalTest/**/*.lean` — 16 files with `## References`, 8 of them with Logos links
  - `FormalSystem/Examples/*.lean` — 3 files
- **Verification**:
  - `grep -rn 'Logos\|ProofChecker' Tests FormalSystem/Examples --include=*.lean` returns empty
  - No `## References` entry in this set is still a markdown link to a `.lean` or `.md` path
  - `bash scripts/check-module-invariants.sh --no-build` ALL PASS, C20 tier 1 still reports the
    recorded resolvable count with every citation on a non-blank line, INV clean
  - `timeout 600000` foreground `lake build` exits 0 (comment-only edits; a failure here means an
    edit crossed out of a comment boundary)

---

### Phase 4: FormalSystem root modules, Syntax, ProofSystem, Automation, BimodalTools [NOT STARTED]

- **Goal:** Convert the first bulk file set, the one with the densest tooling-note prose.
- **Tasks:**
  - [ ] Convert the `## References` blocks in: the 6 `FormalSystem/*.lean` root modules
        (`FormalSystem.lean`, `Syntax.lean`, `Semantics.lean`, `ProofSystem.lean`,
        `Theorems.lean`, `Automation.lean`), `FormalSystem/Syntax/` (5),
        `FormalSystem/ProofSystem/` (4), `FormalSystem/Automation/` (4), `BimodalTools/` (18).
  - [ ] Strip `BimodalTools/`'s tooling-note prose: measured-benchmark lines
        (`Measured deduplication ratio: 4.58x at complexity 7`) and phase-history lines
        (`Phase 2: foundational data structures (this file)`). Keep any statement that tells a
        reader how to *use* the tool.
  - [ ] Remove `## Implementation Status` at `FormalSystem/Automation/ProofSearch/Core.lean:142`.
        **Check the section first**: remove a *status* claim, never a *name list* that C14/C21
        read. If it carries pinned declaration names, move the names under a descriptive heading
        in the body and remove only the status prose.
  - [ ] Repair the 2 broken directory-shaped links from `FormalSystem/Automation.lean`
        (`Automation/{Tactics,ProofSearch}.lean` are both directories) via the backticked
        repo-relative conversion.
  - [ ] `BimodalTools/TraceExporterMain.lean` has TWO `## References` headings and is the one
        C20 target heading outside a leading docstring — hand-verify its re-anchor.
  - [ ] Run the re-anchor tool over this file set at the END of the phase; then
        `--emit-inventory` and `--emit-inventory --check`.
- **Timing:** 1.5 hours
- **Depends on:** 3
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted ~40 files carrying `## References` in this set (6 root + 5 + 4 +
  4 + 18, with `TraceExporterMain.lean` contributing 2 headings). Confirm with
  `grep -rl '^## References' BimodalTools FormalSystem/Syntax FormalSystem/ProofSystem FormalSystem/Automation --include=*.lean; ls FormalSystem/*.lean`
  before editing.
- **Files to modify**:
  - `FormalSystem/{FormalSystem,Syntax,Semantics,ProofSystem,Theorems,Automation}.lean`
  - `FormalSystem/Syntax/*.lean`, `FormalSystem/ProofSystem/*.lean`, `FormalSystem/Automation/**/*.lean`
  - `BimodalTools/*.lean`
- **Verification**:
  - `grep -rn '^## Implementation Status' FormalSystem/Automation --include=*.lean` returns empty
  - `bash scripts/check-module-invariants.sh --no-build` ALL PASS; C20 resolvable count and C15
    anchor count both at or above their recorded baselines; INV clean
  - `timeout 600000` foreground `lake build` exits 0

---

### Phase 5: FormalSystem/Semantics/ — 6 Paper Specification Reference folds [NOT STARTED]

- **Goal:** The hand-review-heavy Semantics set, where the historical-record preservation risk is
  concentrated.
- **Tasks:**
  - [ ] Convert the 11 `## References` blocks under `FormalSystem/Semantics/`.
  - [ ] Fold the 6 `## Paper Specification Reference` headings here
        (`Truth.lean:31`, `FrameAxioms.lean:44`, `TaskFrame.lean:67`,
        `PartialHistoryOrder.lean:17`, `PartialHistory.lean:19`, and
        `Extension/{Admissible,Extension,Step,Constraint}.lean` — hand-count the actual set).
        **Only the heading disappears.** The paper *anchors* move into `## References`; the
        verbatim LaTeX transcription and the design-record prose stay in the module body under a
        descriptive heading or under `## Implementation notes`.
  - [ ] `Semantics/TaskFrame.lean` is the highest-risk file in the task. Its ~50-line PSR section
        holds verbatim transcription of `def:frame`'s four axioms, the nullity derivation, and a
        "**Known gaps relative to the paper**" block that states in terms: *"The two that stood
        here are now closed, and are recorded as closed rather than deleted, since both were
        long-lived."* **Preserve that block verbatim.** Deleting it is exactly the failure mode
        this run kept hitting.
  - [ ] Strip the `**ProofChecker Implementation**:` header wording at `TaskFrame.lean:97` and
        `**ProofChecker Implementation Alignment**:` at `Truth.lean:55`. The blocks *under* those
        headers are substantive — keep them, rename the header.
  - [ ] Repair the 10 `../../../docs/user-guide/architecture.md` links (one `../` too many from
        `FormalSystem/{Semantics,Syntax,ProofSystem,Theorems}/`) that fall in this set, via the
        backticked repo-relative conversion.
  - [ ] Leave every `sub:` anchor verbatim (`sub:Extension` and `sub:RestrictedModalities` are
        both live in this set).
  - [ ] Re-anchor, `--emit-inventory`, `--emit-inventory --check`.
- **Timing:** 1.5 hours
- **Depends on:** 4
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted: 11 `## References` blocks and 6 of the 12 PSR headings under
  `FormalSystem/Semantics/`. Confirm with
  `grep -rn '^## Paper Specification Reference' FormalSystem/Semantics --include=*.lean` and
  `grep -rlc '^## References' FormalSystem/Semantics --include=*.lean` before editing. If the PSR
  count here differs from 6, reconcile against the research's full 12-file list rather than
  proceeding on the assumption.
- **Files to modify**:
  - `FormalSystem/Semantics/*.lean`, `FormalSystem/Semantics/Extension/*.lean`
- **Verification**:
  - `grep -rn '^## Paper Specification Reference' FormalSystem/Semantics --include=*.lean` empty
  - `grep -rn 'ProofChecker\|Logos' FormalSystem/Semantics --include=*.lean` empty
  - `TaskFrame.lean`'s "Known gaps relative to the paper" text is byte-identical to HEAD
    (`git diff HEAD -- FormalSystem/Semantics/TaskFrame.lean` shows no deletion inside it)
  - C15 resolving-anchor count is at or above the recorded baseline (it may legitimately RISE as
    PSR anchors move into `## References`; it must never fall). Any newly-resolving anchor must
    already have a MANIFEST or KNOWN-ANCHORS row — add the row first if not.
  - `bash scripts/check-module-invariants.sh --no-build` ALL PASS; `lake build` exits 0

---

### Phase 6: Theorems/, PlusLanguage/, MinusLanguage/, StarLanguage/ [NOT STARTED]

- **Goal:** The L+/L⋆/L− normal-form gold standard preserved, the remaining `## Implementation
  Status` sections removed, `MinusTruth.lean`'s PSR folded.
- **Tasks:**
  - [ ] Convert the `## References` blocks under `FormalSystem/Theorems/` (12 + `Theorems.lean`),
        `PlusLanguage/` (11), `MinusLanguage/` (9), `StarLanguage/` (9).
  - [ ] **The L+/L⋆/L− blocks are the normal-form gold standard, not conversion targets.** The
        label citations the first task of this run wrote into them must survive. Touch them only
        to wrap a bare bibkey in its `[Author, *Title*][key]` form; leave every `sub:` anchor and
        every backticked module path exactly as written.
  - [ ] `PlusLanguage/PlusLimitClosure.lean` is the worked conversion:
        `Thomason, *Combinations of Tense and Modality* (1984), §4` becomes
        `* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4` — possible
        only because Phase 1 merged `thomason1984` into the root file.
  - [ ] Remove the 3 `## Implementation Status` headings at `Theorems/ModalS5.lean:27`,
        `Theorems/Perpetuity.lean:32`, `Theorems/ModalS4.lean:32`. Same rule as Phase 4: a status
        claim goes, a pinned name list does not.
  - [ ] Fold the `## Paper Specification Reference` at `MinusLanguage/MinusTruth.lean:34`.
  - [ ] Repair the 3 broken `Propositional.lean` links from
        `Theorems/{ModalS4,ModalS5,Combinators}.lean` (`Theorems/Propositional/` is a directory).
  - [ ] Re-anchor, `--emit-inventory`, `--emit-inventory --check`.
- **Timing:** 1.5 hours
- **Depends on:** 5
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted ~42 files with `## References` across these four directories
  (12+1 / 11 / 9 / 9), 3 `## Implementation Status`, 1 PSR. Confirm with
  `grep -rl '^## References' FormalSystem/Theorems FormalSystem/PlusLanguage FormalSystem/MinusLanguage FormalSystem/StarLanguage --include=*.lean | wc -l`
  before editing.
- **Files to modify**:
  - `FormalSystem/Theorems/**/*.lean`, `FormalSystem/Theorems.lean`
  - `FormalSystem/{Plus,Minus,Star}Language/*.lean`
- **Verification**:
  - `grep -rn '^## Implementation Status\|^## Paper Specification Reference' FormalSystem/Theorems FormalSystem/MinusLanguage --include=*.lean` empty
  - `git diff HEAD -- FormalSystem/PlusLanguage/` shows no removed `sub:` citation and no removed
    backticked module path
  - C15 at or above the recorded baseline; `--no-build` ALL PASS; `lake build` exits 0

---

### Phase 7: FormalSystem/Metalogic/Expressiveness/ [NOT STARTED]

- **Goal:** The largest and most C20-exposed file set: 68 files, 10 of the 14 personal paths, and
  the five heaviest citation targets in the tree.
- **Tasks:**
  - [ ] Convert the 67 `## References` blocks under `FormalSystem/Metalogic/Expressiveness/` plus
        `Metalogic/Expressiveness.lean`.
  - [ ] Remove the 10 `~/Projects/Literature/sources/rabinovich_2014/…` personal paths (under
        `Kamp/`: `VecEACombinators`, `KMinusFaithfulRendering`, `KPlusFaithfulRendering`,
        `DedekindINF`, `ContentfulFaithfulBridge`, `Section5Correspondence`, and four under
        `EANegationFixFaithful/`). Each becomes the bib citation it stands in for —
        `* [A. Rabinovich, *A Proof of Kamp's Theorem*][rabinovich2014], <locator>`.
  - [ ] Remove the repo-relative `literature/…` pointers in this set (the
        `literature/Doets_1989_Monadic_Pi11_Theories.md` family). In most cases a
        `[doets1989], Section 1, Lemma 1.1` citation already precedes the path, making the path
        redundant — delete the path, keep the citation, convert the citation to the target form.
  - [ ] Strip the "the companion markdown transcription is corrupt" tooling notes (20 occurrences
        tree-wide, concentrated here). **Keep** the accompanying "Cited by PDF page" note — it is
        substantive, telling a reader the locator convention.
  - [ ] Strip the `plan v39 Phase 11` / `Report 01` / `negfix-refactor design … Phase 13/14a/16a`
        task-history entries from `## References` blocks (the `NfZoneDepthK.lean` and
        `NfMultiAnchorBridge/` families). These are task-management metadata in a library
        docstring.
  - [ ] `Metalogic/Expressiveness.lean:67,69` should already be settled by Phase 1's isolated
        item; verify, do not re-decide.
  - [ ] **Re-anchor is critical here.** This set contains the five heaviest C20 targets:
        `Kamp/KPlusFaithful.lean` (72 citations into it), `Kamp/PriorINF.lean` (39),
        `Kamp/DedekindINF.lean` (38), `Kamp/KampPrior.lean` (30),
        `Kamp/KPlusFaithfulRendering.lean` (20). Run the tool once at the END of the phase over
        the whole set; then `--emit-inventory`, `--emit-inventory --check`.
- **Timing:** 2 hours
- **Depends on:** 6
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted: 68 files with `## References`, 10 personal paths, and the
  per-target citation counts above. Confirm with
  `grep -rl '^## References' FormalSystem/Metalogic/Expressiveness --include=*.lean | wc -l`,
  `grep -rn '~/Projects/' FormalSystem/Metalogic/Expressiveness --include=*.lean`, and a
  re-measurement of the citation counts into the five heavy targets before editing. If this phase
  proves larger than one agent run, split it at the `Kamp/` boundary and record the split.
- **Files to modify**:
  - `FormalSystem/Metalogic/Expressiveness/**/*.lean`, `FormalSystem/Metalogic/Expressiveness.lean`
- **Verification**:
  - `grep -rnE '(/home/|~/Projects/|/Users/)' FormalSystem/Metalogic/Expressiveness --include=*.lean` empty
  - `grep -rnE '(^|[^A-Za-z0-9_/-])literature/' FormalSystem/Metalogic/Expressiveness --include=*.lean` empty
  - `bash scripts/check-module-invariants.sh --no-build` ALL PASS; C20 tier 1 resolvable count at
    the recorded baseline with every citation on a non-blank line — **this is the phase most
    likely to break it**; if the count drops, the re-anchor missed a file, do not proceed
  - INV clean; C19 at or above 90%; `timeout 600000` foreground `lake build` exits 0

---

### Phase 8: Metalogic/WeakCanonical, BXCanonical, Deterministic, Bundle, Algebraic, Soundness [NOT STARTED]

- **Goal:** The second Metalogic set, carrying the remaining 4 personal paths and the two
  highest-risk historical-record files.
- **Tasks:**
  - [ ] Convert the `## References` blocks under `Metalogic/WeakCanonical/` (23 +
        `WeakCanonical.lean`), `Metalogic/BXCanonical/` (20), `Metalogic/Deterministic/` (7),
        `Metalogic/Bundle/` (2), `Metalogic/Algebraic/` (1).
  - [ ] Remove the 4 `~/Projects/Literature/sources/reynolds_1992/…` personal paths under
        `WeakCanonical/DenseModelSurgery/` (`BadIntervals`, `Lemma5`, `Lemma34`, `Defs`), each
        becoming `* [M. Reynolds, …][reynolds1992], <locator>`. Remove the 3 repo-relative
        `literature/sources/reynolds_1992/sec04_7-separability.md` pointers the same way.
  - [ ] Fold the `## Paper Specification Reference` at `Metalogic/Algebraic/FlowFrame.lean:28`.
  - [ ] `Metalogic/Soundness.lean` — the second-highest-risk file in the task. Fold its PSR
        heading (`:19`) but **preserve verbatim** the recorded-history block stating that
        *"There is no `app:valid` anchor, and there never was: earlier revisions of this module
        cited `app:valid` at 'line 1984', which in the live paper is an unrelated `Ddef`… The
        citation and its line number were both bogus."* That text and
        `docs/reference/paper-definitions-of-record.md:2082`'s `app:valid` DANGLING row are a
        matched pair; deleting either half breaks the other's point.
  - [ ] Also in `Soundness.lean`: its `## Implementation Notes` "Completed Proofs" list names the
        C14/C21 pinned set, and its "**The time-shift consumer set**" section says "exactly **one
        schema** … exactly **two declarations**". Preserve every declaration name and every number
        verbatim.
  - [ ] Repair the 2 `../../{ProofSystem/Derivation,Semantics/Validity}.lean` links from
        `Metalogic/Soundness.lean` (one `../` too many) via the backticked conversion.
  - [ ] Re-anchor, `--emit-inventory`, `--emit-inventory --check`.
- **Timing:** 2 hours
- **Depends on:** 7
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted ~55 files with `## References` across these directories, 4
  personal paths, 2 PSR headings. Confirm with
  `grep -rl '^## References' FormalSystem/Metalogic/WeakCanonical FormalSystem/Metalogic/BXCanonical FormalSystem/Metalogic/Deterministic FormalSystem/Metalogic/Bundle FormalSystem/Metalogic/Algebraic --include=*.lean | wc -l`
  and `grep -rn '~/Projects/' FormalSystem/Metalogic/WeakCanonical --include=*.lean` before editing.
- **Files to modify**:
  - `FormalSystem/Metalogic/WeakCanonical/**/*.lean`, `FormalSystem/Metalogic/WeakCanonical.lean`
  - `FormalSystem/Metalogic/BXCanonical/**/*.lean`, `FormalSystem/Metalogic/Deterministic/**/*.lean`
  - `FormalSystem/Metalogic/Bundle/**/*.lean`, `FormalSystem/Metalogic/Algebraic/*.lean`
  - `FormalSystem/Metalogic/Soundness.lean`
- **Verification**:
  - `git diff HEAD -- FormalSystem/Metalogic/Soundness.lean` shows no deletion inside the
    `app:valid` history block and no change to any "Completed Proofs" name or any stated count
  - C14 content half PASS (it is the gate that catches a broken count claim, and it runs under
    `--no-build`)
  - `grep -rnE '(/home/|~/Projects/|/Users/)' FormalSystem/Metalogic/WeakCanonical --include=*.lean` empty
  - `--no-build` ALL PASS; INV clean; `lake build` exits 0

---

### Phase 9: Metalogic/Conservativity, Independence, Decidability [NOT STARTED]

- **Goal:** The last bulk file set; after this phase every `## References` block in the live trees
  is in normal form.
- **Tasks:**
  - [ ] Convert the `## References` blocks under `Metalogic/Conservativity/` (18),
        `Metalogic/Independence/` (16), `Metalogic/Decidability/` (16).
  - [ ] Sweep any residual tooling notes, phase/report citations and "Design provenance:" entries
        in this set under the same rules as Phase 7.
  - [ ] Re-anchor, `--emit-inventory`, `--emit-inventory --check`.
  - [ ] Final residual sweep across ALL live trees for anything the per-directory batches missed:
        remaining bare-form `- [bibkey],` entries, remaining markdown-link entries pointing at
        `.lean`/`.md`, remaining `## Paper Specification Reference` / `## Implementation Status`
        headings, remaining `Logos`/`ProofChecker`, remaining personal or `literature/` paths.
- **Timing:** 1.5 hours
- **Depends on:** 8
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted ~50 files with `## References` across these three directories.
  Confirm with
  `grep -rl '^## References' FormalSystem/Metalogic/Conservativity FormalSystem/Metalogic/Independence FormalSystem/Metalogic/Decidability --include=*.lean | wc -l`
  before editing. The residual sweep is itself the confirmation that the 282-heading total was
  right: if it finds a directory the phase plan never named, record it.
- **Files to modify**:
  - `FormalSystem/Metalogic/{Conservativity,Independence,Decidability}/**/*.lean`
- **Verification**:
  - Every acceptance count in Testing & Validation below reaches its target value
  - `--no-build` ALL PASS; INV clean; `lake build` exits 0

---

### Phase 10: Final gate sweep and baseline re-measurement [NOT STARTED]

- **Goal:** Prove the sweep landed and prove it broke nothing, with the build-inclusive harness
  rather than `lake build`.
- **Tasks:**
  - [ ] `bash scripts/check-module-invariants.sh --emit-inventory` once more, then
        `bash scripts/check-module-invariants.sh --emit-inventory --check` — must report zero
        byte changes.
  - [ ] Run the **build-inclusive** `bash scripts/check-module-invariants.sh` as a foreground
        blocking call with `timeout: 600000`, re-invoked until it returns. Do not background it
        and do not substitute `lake build`. Expect ALL PASS: C1, C2, C14 both halves, C15 both
        assertions, C19 above the 90% floor, C20 both tiers, INV.
  - [ ] `typst compile typst/BimodalReference.typ` and `typst compile typst/FormalFoundations.typ`,
        both exit 0; diff the rendered bibliography pages against the Phase 1 post-merge render to
        confirm nothing moved since.
  - [ ] Run every acceptance check in Testing & Validation below and record the before/after pair
        for each, so the summary can evidence the delta rather than the pass line.
  - [ ] Re-measure both known-red adjacent baselines and assert the counts are **unchanged**:
        `bash scripts/readme-lint.sh` still exactly 21 broken references;
        `bash scripts/typst-sync-check.sh` Check 1 still exactly 9 violations, Checks 2/2b/3 still
        green. Neither is repaired here. A changed count means the sweep caused it — investigate.
  - [ ] Decide and record the fate of `scripts/reanchor-lean-citations.py`: keep it (the research
        recommends a future C31-style gate that would reuse it) or remove it. Default: keep, with
        a header note that it is a maintenance tool, not a gate.
  - [ ] Write the implementation summary at
        `specs/636_docstring_and_citation_normalisation/summaries/01_docstring-citation-normalisation-summary.md`.
- **Timing:** 1 hour
- **Depends on:** 9
- **Verification Tier:** full
- **Commit Mode:** per-substep
- **Scope Hypothesis:** Asserted: the full harness is ALL PASS, `readme-lint.sh` is exactly 21,
  `typst-sync-check.sh` Check 1 is exactly 9. All three are confirmed by running the commands;
  each was also recorded as a baseline in Phase 2, and this phase compares against the recorded
  figures, not against the numbers written here.
- **Files to modify**:
  - `specs/636_docstring_and_citation_normalisation/summaries/01_docstring-citation-normalisation-summary.md` — new
  - `scripts/reanchor-lean-citations.py` — header note only, if kept
- **Verification**:
  - Build-inclusive `scripts/check-module-invariants.sh` ALL PASS
  - Both typst documents compile
  - Every row of the acceptance table below shows its before value and its after value

## Lean Challenge Statements

None. This plan's `- **Goals**:` name no Lean identifiers, so the identifier set this section
would pin is empty. The task changes only comments, docstrings, markdown and bibliography data; it
introduces no theorem, no definition and no proof obligation, and `lake build` is invariant by
construction across every edit in scope.

## Testing & Validation

Each row is measured **before** the first edit and **after** Phase 10. The "Now" column was
re-measured at the time this plan was written, at HEAD `b668923b1`. These replace the task's
original acceptance line `grep -rn 'home/benjamin' FormalSystem Tests` empty, which is already
vacuously green and cannot evidence the work.

| # | Check | Now | Target |
|---|-------|-----|--------|
| A1 | `grep -rhoE '^[[:space:]]*\* \[[^]]+\]\[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean \| wc -l` | 0 | >= 181 |
| A2 | `grep -rhoE '^[[:space:]]*[-*] \[[a-z]+[0-9]{4}[a-z]*\]' FormalSystem Tests BimodalTools --include=*.lean \| wc -l` (old bare form) | 197 | 0 |
| A3 | `grep -rhoE '^[[:space:]]*[-*] \[[^]]+\]\([^)]*\.(lean\|md)\)' FormalSystem Tests BimodalTools --include=*.lean \| wc -l` (markdown-link cross-refs) | 119 | 0 |
| A4 | `grep -rnE '(/home/\|~/Projects/\|/Users/)' FormalSystem Tests BimodalTools --include=*.lean \| wc -l` | 14 | 0 |
| A5 | `grep -rnE '(^\|[^A-Za-z0-9_/-])literature/' FormalSystem Tests BimodalTools --include=*.lean \| wc -l` | 17 | 0 |
| A6 | `grep -rnE 'Logos\|ProofChecker' FormalSystem Tests BimodalTools --include=*.lean \| wc -l` | 27 | 0 |
| A7 | `grep -rn '^## Paper Specification Reference' FormalSystem --include=*.lean \| wc -l` | 12 | 0 |
| A8 | `grep -rn '^## Implementation Status' FormalSystem --include=*.lean \| wc -l` | 4 | 0 |
| A9 | Dangling bibkeys: `comm -23 <(cited keys) <(references.bib keys)` | 2 (`gabbay1980`, `stavi1979`) | 0 |
| A10 | `grep -c '^@' references.bib` | 26 | 84 (confirmed union) |
| A11 | `test -e typst/bibliography.bib` | present | absent |
| A12 | `grep -rn 'ProofChecker' README.md CLAUDE.md typst/ \| wc -l` (must NOT go to zero) | > 0 | unchanged, > 0 |

Gates that must remain green (measured build-inclusive, not via `lake build`):

- [ ] `bash scripts/check-module-invariants.sh` ALL PASS (foreground, `timeout: 600000`, re-invoked
      until it returns)
- [ ] C20 tier 1: resolvable citation count at its recorded baseline (1028 at HEAD), every one on
      a real non-blank line. `unverifiable` rows from C20's basename resolver do not count as pass.
- [ ] C15: resolving-anchor count at or above its recorded baseline (59 at HEAD). It may rise as
      PSR anchors move into `## References`; it must never fall.
- [ ] C19: refined percentage at or above the 90% floor (94.01% at HEAD)
- [ ] C14: both halves PASS, with every stated count and every pinned declaration name preserved
- [ ] INV: `--emit-inventory --check` reports zero byte changes
- [ ] `typst compile typst/BimodalReference.typ` exits 0
- [ ] `typst compile typst/FormalFoundations.typ` exits 0
- [ ] `bash scripts/readme-lint.sh`: still exactly 21 broken references (unchanged, NOT repaired)
- [ ] `bash scripts/typst-sync-check.sh`: Check 1 still exactly 9 violations, Checks 2/2b/3 green
      (unchanged, NOT repaired)
- [ ] `git diff HEAD --stat -- Boneyard/` empty (Boneyard is out of scope)
- [ ] No `sub:` citation removed or reshaped anywhere:
      `grep -rho 'sub:[A-Za-z]*' FormalSystem Tests BimodalTools --include=*.lean | sort | uniq -c`
      matches its pre-sweep output

## Artifacts & Outputs

- `specs/636_docstring_and_citation_normalisation/plans/01_docstring-citation-normalisation.md` (this file)
- `specs/636_docstring_and_citation_normalisation/summaries/01_docstring-citation-normalisation-summary.md`
- `references.bib` — merged, 84 entries, the single bibliography
- `typst/bibliography.bib` — deleted
- `scripts/reanchor-lean-citations.py` — new maintenance tool (fate decided in Phase 10)
- `docs/development/reference-normal-form.md` — new; the three-way normal form and recorded baselines
- ~295 `.lean` files under `FormalSystem/`, `BimodalTools/` and `Tests/` with normalised docstrings
- `typst/{FormalFoundations,BimodalReference}.typ`, `typst/chapters/*.typ`, `typst/README.md` — re-pointed

## Rollback/Contingency

Every phase commits per green sub-step, so the unit of rollback is a commit, not the working tree.

- **A phase turns a gate red and the cause is not obvious**: `git revert` that phase's commits.
  The re-anchor tool's changes are in the same commits as the edits that caused the shift, so a
  revert restores a consistent state.
- **A partially-applied phase must be abandoned mid-flight**: this is the one genuine rollback
  case. Take a snapshot first with the invocation shape in
  `.claude/context/contracts/recovery.md`'s rollback rung — pass the task number explicitly, and
  add `--allow-out-of-scope` for a whole-tree rollback, since `scripts/` and `docs/` fall outside
  this task's declared `file_scope`. Only then run the destructive command.
- **A defensive checkpoint before a risky batch** (Phases 7 and 8 are the candidates): use
  `bash .claude/scripts/git-snapshot.sh 636 --no-revert`, which is durable and does NOT revert the
  working tree. Never use the bare default form as a routine checkpoint.
- **The bib merge breaks typst rendering in a way the per-key direction did not anticipate**:
  Phase 1 is `atomic-batch`, so it is one commit. Revert it, restore `typst/bibliography.bib`, and
  re-do the merge key by key, compiling after each.
- **The two dangling bibkeys turn out not to be covered by the re-pointed keys**: leave
  `FormalSystem/Metalogic/Expressiveness.lean:67,69` exactly as they are, report it, and let the
  rest of the sweep proceed. The item is deliberately isolated for exactly this.
