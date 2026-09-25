# Research Report: Task #676

**Task**: 676 - Audit module inventory docs and export counts
**Started**: 2026-09-25T19:00:00Z
**Completed**: 2026-09-25T19:35:00Z
**Effort**: research (documentation audit, no `.lean` proof content)
**Dependencies**: None (follows the already-landed `MinusLanguageSoundness.lean` repoint)
**Sources/Inputs**: Codebase directory listings (`find`), `docs/user-guide/architecture.md`,
  `FormalSystem/Metalogic/Conservativity.lean`, `docs/project-info/implementation-status.md`,
  `docs/reference/API_REFERENCE.md`, `docs/development/PUBLICATION_REFACTOR.md`,
  `scripts/check-module-invariants.sh`
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Defect 1 (architecture.md source tree)**: the three confirmed errors are verified exactly as
  described. The unaudited remainder of the tree is drifted far beyond those three lines: **7
  entire top-level `FormalSystem/` subsystems are missing** (`ForMathlib/`, `HybridLanguage/`,
  `OpenLanguage/`, `PlusLanguage/`, `QuantLanguage/`, `StarLanguage/`, `Tactic/`), `Boneyard/` is
  drawn as the last child of `FormalSystem/` but is **actually a repo-root sibling directory**
  (`./Boneyard`, 41 subdirectories, confirmed to exist — this is a wrong-parent defect, not a
  nonexistent-entry defect), and every "fully expanded" directory in the tree (`Syntax/`,
  `ProofSystem/`, `MinusLanguage/`, `Semantics/`, `Metalogic/`) is missing files that exist today
  — in `Semantics/`'s case, more than 20 of them. Full per-directory diff tables are in Findings
  below.
- **Defect 2 (Conservativity re-export count)**: ground truth is **20 import lines** total in
  `Metalogic/Conservativity.lean` (19 from `Metalogic/Conservativity/` + 1
  `FormalSystem.MinusLanguage.Soundness`), all 19 files physically in `Conservativity/` are
  imported (no orphans), and the docstring's own bullet list currently has **18** entries, not
  the "14" the dispatch context guessed — 2 imported modules (`ChainBundleTruth.lean`,
  `DenseObstructionTransfer.lean`) are imported but never bulleted. The docstring prose says
  "nine"; `implementation-status.md` says "the five modules below" but only ever shows 2 rows
  below the aggregator row. **Recommendation: settle on 20 ("every import")** — see Decisions.
- **Defect 3 (row placement)**: `implementation-status.md` has no other `MinusLanguage/` rows for
  the `MinusLanguage/Soundness.lean` row to be grouped with — it is the *only* `MinusLanguage/`
  row in the entire table. The table is already organized by narrative "Layer" rather than strict
  directory (e.g. `Correspondence/Galois.lean` sits under "Layer 1: Semantics" despite living in
  `Semantics/Correspondence/`), which supports leaving the row in place with a one-line
  clarifying note rather than moving it.

## Context & Scope

Documentation-only audit of three named defects in module-inventory documentation, following the
already-landed `MinusLanguageSoundness.lean` -> `MinusLanguage/Soundness.lean` repoint (task 674's
predecessor work; not reopened here). Scope is exactly the files named in the dispatch:
`docs/user-guide/architecture.md` (source-tree block), `FormalSystem/Metalogic/Conservativity.lean`
(docstring only), `docs/project-info/implementation-status.md`. `docs/development/PUBLICATION_REFACTOR.md`
is explicitly excluded (historical record, old paths are correct there). No `.lean` statement,
definition, or theorem content changes; the only `.lean` edit contemplated is the Conservativity
aggregator's module docstring.

## Findings

### Defect 1: architecture.md source tree (docs/user-guide/architecture.md:1092-1157)

The three confirmed errors (MinusLanguage/ missing 6 files, MinusTruth.lean/MinusValidity.lean
wrongly placed under Semantics/, MinusLanguageSoundness.lean citing a nonexistent module) are
verified correct as stated in the dispatch and require no re-derivation. Below is the exhaustive
walk of the rest of the tree, directory by directory, comparing the documented entries against
`find FormalSystem/<dir> -maxdepth 1|2` output captured during this research pass.

**Top-level `FormalSystem/` entries** (doc lists 9 bullets under `FormalSystem/`: `Syntax/`,
`ProofSystem/`, `MinusLanguage/`, `Semantics/`, `Metalogic/`, `Theorems/`, `Automation/`,
`Examples/`, `Boneyard/`):

| Real top-level entry | In doc? | Note |
|---|---|---|
| `Syntax/`, `ProofSystem/`, `MinusLanguage/`, `Semantics/`, `Metalogic/`, `Theorems/`, `Automation/`, `Examples/` | yes | present, correct |
| `Boneyard/` | yes, but **under the wrong parent** | real directory (41 subdirectories of archived material, confirmed via `ls -d Boneyard/`), but it lives at the repo root (`./Boneyard`, a sibling of `FormalSystem/`, `Tests/`, `docs/`) — not nested inside `FormalSystem/` as the tree currently draws it (`└── Boneyard/` as the last child of `FormalSystem/`, right before the tree closes and `Tests/BimodalTest/` begins). Move the bullet out from under `FormalSystem/` to the repo-root level, alongside `Tests/BimodalTest/`, `docs/`, etc. |
| `ForMathlib/` | **missing** | real dir (`Order/`, `Topology/`, `README.md`); CLAUDE.md's own Project Structure section already names it, architecture.md does not |
| `HybridLanguage/` | **missing** | real dir, 7 files (`Formula.lean`, `HybridInvariance.lean`, `HybridRecurrence.lean`, `HybridTransposition.lean`, `HybridTruth.lean`, `HybridValidity.lean`, `README.md`) |
| `OpenLanguage/` | **missing** | real dir, 7 files (`Formula.lean`, `OpenClasses.lean`, `OpenOckhamist.lean`, `OpenReversal.lean`, `OpenTruth.lean`, `OpenValidity.lean`, `README.md`) |
| `PlusLanguage/` | **missing** | real dir, 12 files |
| `QuantLanguage/` | **missing** | real dir, 5 files (`Formula.lean`, `QuantInvariance.lean`, `QuantRecurrence.lean`, `QuantTruth.lean`, `README.md`) |
| `StarLanguage/` | **missing** | real dir, 10 files |
| `Tactic/` | **missing** | real dir, 3 files (`Attr.lean`, `Meta.lean`, `README.md`) |
| `Init.lean`, `MainResults.lean`, `Version.lean`, `README.md` (loose top-level files) | missing | loose files parallel to the directories; each top-level directory also has an `X.lean` re-export shim (e.g. `Automation.lean`) that the doc already omits for every directory — treat the shims as an established, acceptable omission, but `Init.lean`/`MainResults.lean`/`Version.lean`/`README.md` are not shims and are currently undocumented |

**`Syntax/`** (doc fully expands 4 files + 1 subdir pointer):

| Real file | In doc? |
|---|---|
| `Formula.lean`, `Atom.lean`, `Context.lean`, `Subformulas.lean` | yes |
| `SubformulaClosure/` | yes (pointer, not expanded — consistent with the tree's own style for subdirectories elsewhere) |
| `BigConj.lean` | **missing** |
| `README.md` | **missing** |
| `SubformulaClosure.lean` (re-export shim) | missing, but consistent with the shim-omission convention above |

**`ProofSystem/`** (doc fully expands 3 files):

| Real file | In doc? |
|---|---|
| `Axioms.lean`, `Derivable.lean`, `Derivation.lean` | yes |
| `DerivedAxioms.lean` | **missing** |
| `LinearityDerivedFacts.lean` | **missing** |
| `README.md` | **missing** |

**`MinusLanguage/`** (dispatch-confirmed; verified): doc lists `Formula.lean`, `Axioms.lean`,
`Derivation.lean`, `Translation.lean`, `AxiomDischarge.lean`. Real directory additionally has
`MinusFrame.lean`, `MinusSchemaValidity.lean`, `MinusTruth.lean`, `MinusValidity.lean`,
`Soundness.lean`, `README.md` — all 6 confirmed present on disk, all 6 confirmed absent from the
doc.

**`Semantics/`** (doc fully expands 7 files + 1 subdir pointer; 2 of the 7 are misplaced per the
confirmed defect): after removing `MinusTruth.lean`/`MinusValidity.lean` (which belong under
`MinusLanguage/`, not here), the doc correctly documents 5 files (`TaskFrame.lean`,
`PartialHistory.lean`, `TaskModel.lean`, `Truth.lean`, `Validity.lean`) plus one subdirectory
pointer (`Extension/`). The real directory has grown to **26 top-level files and 5
subdirectories**:

- Documented and correct: `TaskFrame.lean`, `PartialHistory.lean`, `TaskModel.lean`, `Truth.lean`,
  `Validity.lean`, `Extension/`
- **Missing top-level files** (21): `ConvexTruthCut.lean`, `ConvexTruth.lean`,
  `DeterministicBridge.lean`, `DurationClassification.lean`, `FrameAxioms.lean`,
  `FrameClassValidity.lean`, `FrameProperty.lean`, `HistoryMorphism.lean`, `IntNormalForm.lean`,
  `IntTransfer.lean`, `LexCarrier.lean`, `PartialHistoryOrder.lean`, `Periodicity.lean`,
  `README.md`, `ShiftSet.lean`, `StateLocalTransfer.lean`, `TemporalOrder.lean`,
  `TimeIndexed.lean`, `TimeIndexedSharpness.lean`, `TruthClauses.lean`, `TruthTransport.lean`,
  `ValidityLayer.lean`
- **Missing subdirectory pointers** (4): `Correspondence/` (9 files, already individually cited
  in `implementation-status.md`'s Layer 1 table — `Galois.lean`, `Indicator.lean`, etc.),
  `Frames/` (2 files + README), `StateTopology/` (4 files + README), `Ultraproduct/` (4 files +
  README)

This is the single largest concentration of drift in the tree. See Decisions below for the
recommended fix strategy (representative-file style vs. full expansion).

**`Metalogic/`** (doc fully expands 8 files + 7 subdir pointers, one file — `MinusLanguageSoundness.lean`
— is the confirmed-stale, nonexistent entry):

| Real top-level entry | In doc? | Note |
|---|---|---|
| `Soundness.lean`, `SoundnessLemmas.lean`, `StrongCompleteness.lean`, `SetConsequence.lean`, `Compactness.lean`, `DiscreteNonCompactness.lean`, `Conservativity.lean` | yes | correct |
| `MinusLanguageSoundness.lean` | yes, **does not exist** | confirmed stale — remove |
| `Core/`, `Bundle/`, `BXCanonical/`, `WeakCanonical/`, `Algebraic/`, `Independence/`, `Decidability/` | yes (pointers) | present, correct |
| `Conservativity/` (the directory, distinct from `Conservativity.lean`) | **missing** | real subdirectory of 19 files backing the aggregator (see Defect 2) — not pointed to anywhere in the tree |
| `ConvexConsequence/` | **missing** | real subdirectory |
| `Deterministic/` | **missing** | real subdirectory |
| `Expressiveness/` | **missing** | real subdirectory (cited individually in `implementation-status.md`'s Layer 2 table as `Expressiveness/Kamp/`) |
| `DedekindNonCompactness.lean` | **missing** | real top-level file |
| `QTime.lean` | **missing** | real top-level file |
| `README.md` | **missing** | real top-level file |

**`Theorems/`** (doc fully expands with a compressed `ModalS4.lean, ModalS5.lean` entry, plus
`Propositional/`, `TemporalDerived.lean`, `DedekindDerived.lean`):

| Real file | In doc? |
|---|---|
| `ModalS4.lean`, `ModalS5.lean`, `Propositional/`, `TemporalDerived.lean`, `DedekindDerived.lean` | yes |
| `Perpetuity/` | yes (doc lists it as a separate bullet above the compressed `ModalS4/S5` line — matches) |
| `Combinators.lean` | **missing** |
| `ContextualProofs.lean` | **missing** |
| `DeductionTheorem.lean` | **missing** |
| `DiscreteUnfolding.lean` | **missing** |
| `GeneralizedNecessitation.lean` | **missing** |
| `ModalDerived.lean` | **missing** |
| `README.md` | **missing** |

**`Automation/`** (doc: `Tactics/`, `ProofSearch/` pointers only):

Real directory additionally has `Normalization.lean`, `SuccessPatterns.lean`, `README.md` as
loose top-level files alongside the two documented subdirectory pointers. Both subdirectories
themselves are accurately named (verified `Tactics/` and `ProofSearch/` both exist with their own
`README.md` + implementation files, consistent with the pointer-only style used elsewhere).

**`Examples/`** (doc: bare pointer, "Pedagogical examples"): real directory has
`BimodalProofs.lean`, `README.md`, `TemporalStructures.lean`, `Walkthrough.lean` — the doc's
single-line pointer is not literally false (it is a directory, and it does contain pedagogical
examples), so no defect here; flagged only for completeness.

**`Tests/BimodalTest/`** (doc: pointer groupings `Syntax/, ProofSystem/, Semantics/`,
`Metalogic/, Theorems/, Automation/`, `Integration/`, `Property/`): all 7 named subdirectories
exist and are correctly named. Two loose root-level files are undocumented: `Property.lean`,
`WalkthroughAxioms.lean`, plus `README.md`. Minor relative to the `FormalSystem/` drift above.

**Bottom-level bullets** (`docs/`, `lakefile.toml`, `lean-toolchain`): accurate, not flagged.

### Defect 2: Conservativity re-export count

**Ground truth, verified by direct inspection of `FormalSystem/Metalogic/Conservativity.lean`
and `FormalSystem/Metalogic/Conservativity/`:**

- The aggregator's import block (`FormalSystem/Metalogic/Conservativity.lean` lines 7-26) has
  **20 import lines**: `Conservativity/Backward`, `MinusLanguage/Soundness`,
  `Conservativity/TMCompletenessReduction`, `Conservativity/SpWitness`,
  `Conservativity/Z1Countermodel`, `Conservativity/DenseObstructionTransfer`,
  `Conservativity/ChainBundleTruth`, `Conservativity/SpCountermodel`, `Conservativity/Fragment`,
  `Conservativity/FragmentCompactness`, `Conservativity/MinusExt`,
  `Conservativity/FragmentAxiomatization`, `Conservativity/MinusDeduction`,
  `Conservativity/MinusTemporalDerived`, `Conservativity/MinusMCS`,
  `Conservativity/MinusCanonicalFrame`, `Conservativity/MinusChronicle`,
  `Conservativity/MinusChainCompleteness`, `Conservativity/Plus`, `Conservativity/Star`.
- `FormalSystem/Metalogic/Conservativity/` (the directory) physically contains exactly **19
  `.lean` files** (excluding `README.md` and the `Plus/`/`Star/` sub-subdirectories, which
  `Plus.lean`/`Star.lean` themselves aggregate): every one of the 19 is imported by the
  aggregator (no orphaned directory file, no dangling import to a file that doesn't exist). So
  "every import" (20) = "every directory file" (19) + the one cross-directory import
  (`MinusLanguage/Soundness.lean`, 1) — the three candidate counts the dispatch names are not
  independent options so much as 20 = 19 + 1.
- The docstring's own bullet list (`## What this module is`, lines 369-417) currently has **18
  bullets**, not the "14" the dispatch context estimated (recount, not assumed — the miscount in
  the dispatch text does not bind the research findings; grep-counted at 18, cross-checked
  against a manual line-by-line read). The 18 bullets cover every import **except**
  `Conservativity/ChainBundleTruth.lean` and `Conservativity/DenseObstructionTransfer.lean`,
  which are imported (per the import block) but have no corresponding bullet — the current
  bullet list is already an *undercount relative to its own imports*, independent of what the
  prose number says.
- The docstring prose says "the nine modules" (line 373). `implementation-status.md`'s row for
  the aggregator (line 71) says "re-exports the five modules below" — but that table shows
  exactly **2** rows directly below the aggregator row (`Conservativity/Backward.lean` and
  `MinusLanguage/Soundness.lean`) before moving to an unrelated topic
  (`Metalogic/Independence/`); the table has never enumerated 5, 9, 18, 19, or 20 rows in that
  position within the current file — the "5" is stale relative to the table's own current
  content, not just relative to the aggregator.

### Defect 3: row placement in implementation-status.md

`MinusLanguage/Soundness.lean` (line 73) is the **only** `MinusLanguage/` row anywhere in
`implementation-status.md` — there is no other `MinusLanguage/` grouping in the table to move it
to. The document is organized into six `## Layer N: ...` sections by narrative role, not strictly
by source directory: e.g. `Correspondence/Galois.lean` and `Correspondence/Indicator.lean` (real
path `Semantics/Correspondence/*.lean`) already sit under `## Layer 1: Semantics` rather than a
literal `Correspondence/` grouping, and `Expressiveness/Kamp/` sits under `## Layer 2: Metalogic`
the same way. The `MinusLanguage/Soundness.lean` row's own placement — directly after
`Conservativity/Backward.lean`, directly before the doc's own prose (lines 83-87) that explains
it is obtained "by composing `Conservativity.translate` with the four theorems above" — already
follows this narrative-by-dependency convention rather than a directory convention.

## Decisions

- **Defect 2 count: recommend 20 ("every import").** Rationale: (1) the docstring's own framing
  — "the aggregator... re-exports the N modules" — most naturally means "the modules this file
  imports," and an aggregator's job is definitionally to re-export what it imports; (2)
  `MinusLanguage/Soundness.lean` is explicitly discussed in the surrounding narrative (the "left
  arrow" of the two-arrow bridge, lines 361-365) as integral to the same story the aggregator
  documents, so excluding it from the count (the 19-only reading) would be inconsistent with
  giving it a bullet; (3) 20 is the only one of the three candidate numbers that is mechanically
  checkable against the import block without further judgment calls, which is exactly the kind of
  self-verifying anchor the dispatch asks the fix to leave behind ("say ... which set is being
  counted so the next reader cannot re-introduce the ambiguity"). Implementation should: change
  "nine" to "20" in the docstring prose, add the 2 missing bullets (`ChainBundleTruth.lean`,
  `DenseObstructionTransfer.lean`) so the bullet list is complete relative to imports, and change
  `implementation-status.md` line 71 to state the same number rather than "the five modules
  below" — since that table's own local list is a 2-row illustrative sample, not a complete
  enumeration, the replacement wording should not imply completeness it doesn't have (e.g. "the
  aggregator... re-exports 20 modules across the L⁻-vs-TM⁻ and TM-vs-TM⁺ story (full list in
  `Metalogic/Conservativity.lean`'s docstring); shown below: the backward bridge and the
  base-language soundness composition" or equivalent — exact wording is an implementation
  decision, not a research one).
- **Defect 3: leave the row in place, add a one-line clarifying note.** Rationale above (no other
  `MinusLanguage/` grouping exists to move it to; the table's own convention is narrative
  grouping, and this row's current position already matches that convention). A one-sentence
  parenthetical noting "(lives under `MinusLanguage/`; grouped here with its Conservativity
  dependency)" would close the "reader might mistake this for misplacement" concern without
  fighting the table's established structure.
- **Defect 1 style question is left to implementation, not settled here**: whether
  `Semantics/`'s and `Metalogic/`'s now-25-30-entry-deep top levels should be (a) fully expanded
  (literal reading of "correct every entry... including files present on disk but absent from the
  tree") or (b) trimmed to a representative sample with subdirectory pointers, mirroring the
  style the tree already uses for `Metalogic/`'s own canonical-model subdirectories
  (`Core/`, `Bundle/`, `BXCanonical/`, etc., which are never expanded to file level). This
  research report supplies the full real-file listings needed for either choice (see Findings);
  the choice itself is a documentation-style call better made by whoever writes the final prose,
  since both are internally consistent with parts of the tree's existing style and the dispatch
  does not adjudicate between them.

## Risks & Mitigations

- **Risk**: full expansion of `Semantics/` and `Metalogic/` (Decision above, option (a)) would
  add roughly 60-70 new lines to the tree diagram, materially changing the file's shape.
  **Mitigation**: not a build-cost risk (architecture.md is Markdown, zero Lean rebuild cost per
  the dispatch's BUILD COST note) and not a gate risk (`check-module-invariants.sh`'s generated
  inventory blocks live in `FormalSystem/**/README.md`, not `docs/user-guide/architecture.md` —
  confirmed by inspecting `check-module-invariants.sh`'s own `--emit-inventory` target
  resolution, which walks `dir=` options inside `FormalSystem/`; `architecture.md` carries no such
  BEGIN/END GENERATED marker and is therefore outside INV's regenerate/diff scope entirely). Pick
  whichever style; neither trips a gate.
- **Risk**: `lake-build-guard.sh` lives at `.claude/scripts/lake-build-guard.sh`, not
  `scripts/lake-build-guard.sh` as the dispatch's BUILD COST paragraph writes it (bare
  `scripts/lake-build-guard.sh` does not exist; verified via `find`). `check-module-invariants.sh`
  and `readme-lint.sh`, by contrast, genuinely are at top-level `scripts/` as the dispatch states.
  **Mitigation**: implementation should invoke the build guard at its real path,
  `.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`.
- **Risk**: the inventory generator's pipe-character truncation (noted in the dispatch) could
  silently corrupt any new README description added while fixing Defect 1/2 if a prose edit
  elsewhere in this pass introduces a literal `|`. **Mitigation**: this task's in-scope edits
  (architecture.md, Conservativity.lean docstring, implementation-status.md) are not
  `--emit-inventory`-managed README blocks themselves, so this risk applies only if
  implementation also touches an actual `FormalSystem/**/README.md` inventory block as a side
  effect — not currently anticipated by this task's scope, but worth a final grep for `|`
  characters in any touched README table cell before running `--emit-inventory`.

## Context Extension Recommendations

- **Topic**: `.claude/CLAUDE.md`'s "Project Structure" section (repo overview, not the dispatch's
  target files) lists `FormalSystem/`'s subdirectories as `ForMathlib/, Syntax/, ProofSystem/,
  Semantics/, Metalogic/, Theorems/, Automation/, Examples/` — it also omits `MinusLanguage/`,
  `HybridLanguage/`, `OpenLanguage/`, `PlusLanguage/`, `QuantLanguage/`, `StarLanguage/`,
  `Tactic/`. **Gap**: this file is out of this task's declared scope (not named in STARTING
  POINTS, and the dispatch's DELIBERATE EXCLUSION / ALREADY DONE framing is specific to
  `docs/**`), but it has the same drift shape as Defect 1. **Recommendation**: a small follow-up
  task after this one lands, scoped explicitly to `.claude/CLAUDE.md`'s Project Structure
  section — note this is a source-store-governed file per
  `.claude/rules/source-store-deploy-boundary.md`, so any such follow-up edits the source store
  copy, not the deployed `.claude/CLAUDE.md` directly.

## Appendix

### Commands used

```bash
find FormalSystem/<dir> -maxdepth 1|2 | sort         # per-directory real listing
grep -n "MinusLanguageSoundness" -r --include="*.md" --include="*.lean" --include="*.typ" .
sed -n '369,417p' FormalSystem/Metalogic/Conservativity.lean | grep -c '^\* `'
grep -n "^## \|^### \|MinusLanguage" docs/project-info/implementation-status.md
ls -d Boneyard/ FormalSystem/Boneyard 2>&1   # confirms Boneyard is repo-root, not FormalSystem/-nested
```

### References

- `docs/user-guide/architecture.md:1092-1157` (source tree block)
- `FormalSystem/Metalogic/Conservativity.lean:7-26` (import block), `:368-417` ("What this module
  is" docstring section)
- `docs/project-info/implementation-status.md:59-87` (Layer 2: Metalogic table)
- `docs/development/PUBLICATION_REFACTOR.md` (excluded historical record; confirmed remaining
  `MinusLanguageSoundness` references there are all in-scope-exempt)
- `scripts/check-module-invariants.sh` (INV / C20 gate mechanics; confirmed `--emit-inventory`
  targets `FormalSystem/**/README.md` generated blocks, not `docs/user-guide/architecture.md`)
