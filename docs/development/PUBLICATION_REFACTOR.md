# Publication Refactor Programme

[Back to Development Documentation](README.md)

The dependency-ordered programme that brings this repository to the engineering standard of a
published Lean library, measured against `cslib` and Mathlib. It is a process document, like
[MODULE_ORGANIZATION.md](MODULE_ORGANIZATION.md) and [VERSIONING.md](VERSIONING.md); the two
decisions it depends on are recorded where decisions live, as
[ADR-010](../architecture/ADR-010-Boneyard-At-Repository-Root.md) and
[ADR-011](../architecture/ADR-011-Extract-Expressiveness.md). Every count below is regenerated
by `scripts/measure-refactor-partitions.py` (see [Measurements](#6-measurements)); none is typed.

## 1. Purpose and status

"Publication standard" here means the surface of upstream `leanprover/cslib` and of Mathlib: one
default library target with a single generated aggregator, tooling outside the default build,
Mathlib headers and docstring sections on every file, one bibliography in Mathlib's citation
form, a root-level archive, CI that asserts all of it, and a tracked tree that contains nothing a
reader of the formalization has no use for.

The fork `benbrastmckie/cslib` was the reference for the Lean-facing conventions (lakefile
shape, aggregator, `Init` module, headers, references, CI, root-level archive), and it is a
faithful model for those. It is **not** a model for the repository surface: it tracks its own
task-management, agent-configuration and memory trees. For that dimension the model is upstream
cslib's top-level file set.

Status: **proposed**, not started. No phase has run. `FormalSystem/` and `Tests/` are unchanged
by the work that produced this document; the only new artefacts are the measurement script, this
document and the two Proposed ADRs.

## 2. Path-naming convention for this document

The repository's markdown gates resolve every dotted module name (C5) and every slash-shaped
source path (C12) they see. A path that will exist only after a programme phase lands is not
stale, but the gates cannot know that. Every **not-yet-existing** path or module in this
document is therefore written **relative to the library root**: `Metalogic/Expressiveness/`
rather than the full slash path, `Metalogic.Expressiveness.Kamp` rather than the fully-qualified
module name. Existing paths are written in full where useful. Future test paths are written
relative to `Tests/` for the same reason, and the two new library targets are named bare
(`BimodalTools`, `BimodalToolsTest`).

## 3. Convention map

Disposition legend: **adopt**, **already matches**, **deliberately diverge** (with the reason).
The 23 rows are the cslib survey's eight dimensions plus the archive (e) and the deliverable
surface (g).

| # | cslib convention | Current state here | Disposition |
|---|---|---|---|
| 1a | One default `lean_lib`; test lib as `testDriver`; `lintDriver = batteries/runLinter` | Same | **Already matches** |
| 1b | Only infrastructure `lean_exe` (`checkInitImports`) | 12 ML/dataset exes rooted in the library | **Adopt**: new `lean_lib BimodalTools` outside `defaultTargets` owning the tooling and its exes; `import FormalSystem` no longer pulls training infrastructure (Phase 3) |
| 1c | Root aggregator imports every file; `mk_all --check` in CI | Two-level root (`FormalSystem.lean` -> `FormalSystem/FormalSystem.lean`); unreachable live modules tolerated through the C6 manifest | **Adopt**: collapse into one generated `FormalSystem.lean`; wire or archive the manifested modules; add `lake exe mk_all --check` once the archive is out of the library root (Phases 2, 8) |
| 1d | `Init.lean` plus a local lint/attribute module | `Init.lean` imports only Mathlib roots | **Adopt**: `Tactic/Attr.lean` holding the `register_*_attr` declarations, imported by `Init` (Phase 4) |
| 2a | Namespace follows path below a documented prefix | 279 equal-or-descendant, 187 ancestor, 24 unrelated | **Adopt** for the unrelated set: relocate files to where their namespace says they live (Phases 4-5; zero FQN churn for the 15 language-extension files) |
| 2b | Deliberate path/namespace split (`Logics/` vs `Logic`) | None | **Deliberately diverge**: one logic, no reason to introduce a split |
| 2c | Project-named root (`Cslib`) | Root `FormalSystem`, a recent deliberate rename | **Deliberately diverge (reaffirm)**: renaming again is churn with no structural benefit |
| 3a | Lean module system (`module` / `public import` / `@[expose]`) | Not used | **Deliberately diverge for now**: changes no citable name, so it can follow publication as its own programme (Phase 9) |
| 3b | No top-level automation layer; automation beside the logic it serves | `Automation/` as layer 4, imported from layers 0-2 | **Adopt partially**: attributes go down to `Tactic/`, `PropDecide` moves beside `Kalmar`; user tactics stay in `Automation/` (Phases 3-4) |
| 3c | Per-logic ordering Syntax -> ProofSystem -> Semantics -> Theorems -> Metalogic | ORGANISATION.md puts Metalogic below Theorems, but 29 Metalogic files import Theorems | **Adopt**: fix the layer table to the measured order and move `Core/DeductionTheorem.lean` into `Theorems/` (Phase 4) |
| 3d | `private` / `protected` in use | `private` widely used, `protected` unused | **Already matches** (`protected` optional) |
| 3e | No main-results page | `MainResults.lean` with pinned `#print axioms` (C2/C14/C21) | **Deliberately diverge**: this repository is stronger here; keep it |
| 4a | Mathlib module-docstring sections | Mostly matching; non-standard `## Paper Specification Reference`, `## Implementation Status`; `## Tags` | **Adopt**: fold paper references into `## References`; remove `Implementation Status`; keep `## Tags` (Phase 7) |
| 4b | Content-named files | 39 paper-numbered or history-suffixed names; declaration-free compatibility stubs | **Adopt**: content names, delete stubs, before publication (Phase 6.2) |
| 5 | One `references.bib`; `* [Author, *Title*][key]` citation form | Two bib files; `- [key], ...` form; internal-tooling notes in references | **Adopt**: one root `references.bib` shared with typst; Mathlib link form; strip tooling notes (Phase 7). Key style stays lowercase `authorYYYY` — a deliberate divergence, internally consistent and cited from typst |
| 6a | Mathlib Apache header on every file | Already on every live file; checked by `check-copyright-headers.sh` | **Already matches**; consider retiring the custom script if `linter.style.header` proves redundant (Phase 8) |
| 6b | `AUTHORS.md`, no `CITATION.cff` | `CITATION.cff`, no `AUTHORS.md` | **Deliberately diverge**: keep `CITATION.cff` (what GitHub and Zenodo read); a single author needs no `AUTHORS.md` |
| 7a | CI: build `--wfail`, test, lint, `mk_all --check`, `checkInitImports`, `lint-style` | build `--wfail`, test, lint, exe-root compile, invariants `--no-build`, headers, README lint, cycles, typst sync, paper definitions | **Adopt** `mk_all --check` and `lint-style-action`; keep the richer invariant harness (Phase 8) |
| 7b | Top-level `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, PR-title check, tag-triggered release, `scripts/README.md` | `CONTRIBUTING.md` under `docs/development/`; no release workflow; no scripts README | **Adopt**: top-level `CONTRIBUTING.md`, a `scripts/README.md` naming every script, a tag-triggered release workflow; PR-title check optional for a single maintainer (Phases 1, 8) |
| 7c | Module-size policy: split by dependency, never by line count | `longFile = 1500` with in-source baselines (stricter) | **Adopt the policy text**, keep the baselines; split only the two largest files, only along import-acyclic seams (Phase 9, optional) |
| 8 | Flat test directory | Mirrored subdirectories plus 12 loose root files | **Deliberately diverge** (mirroring scales better here); relocate the loose files only (Phases 3, 5) |
| e | Root-level `Boneyard/`, `#exit`, stale archived imports are cosmetic | `FormalSystem/Boneyard/`, `#exit` everywhere, C11 keeps imports resolvable | **Adopt the location** (Phase 2, ADR-010); **deliberately diverge** on C11 and keep it enforced |
| g | Clean upstream surface (the fork is not a model here) | `specs/`, `CLAUDE.md`, `.claude-extensions.json`, personal paths, internal naming, frozen LaTeX PDF, research and training notes, one-off scripts | **Adopt upstream's surface** (Phase 1 and the publication gate) |

## 4. Target layout

Tree lines are relative to the repository root; nothing under `FormalSystem/` carries the
library prefix, per Section 2.

```
BimodalLogic/
├── lakefile.toml, lean-toolchain, lake-manifest.json, LICENSE, CITATION.cff
├── README.md, CONTRIBUTING.md, ORGANISATION.md, NOTATION.md, references.bib
├── FormalSystem.lean               # single generated aggregator (mk_all --check)
├── FormalSystem/
│   ├── Init.lean                   # Mathlib.Init, Mathlib.Tactic.Common, Tactic.Attr
│   ├── Tactic/Attr.lean            # register_simp_attr / register_label_attr (from Automation/{TruthNormAttr,NormalizationAttr,LemmaDB})
│   ├── ForMathlib/                 # unchanged
│   ├── Syntax/                     # TM syntax only (Plus/Minus/Star moved out)
│   ├── ProofSystem/
│   ├── Semantics/                  # + Periodicity.lean (from Metalogic/Decidability/FMP/)
│   ├── PlusLanguage/, MinusLanguage/, StarLanguage/   # Syntax/X + Semantics/X merged; namespaces unchanged
│   ├── Theorems/                   # + DeductionTheorem.lean (from Metalogic/Core/)
│   ├── Metalogic/
│   │   ├── Core/ Bundle/ Algebraic/ BXCanonical/ SoundnessLemmas/ Conservativity/
│   │   ├── Decidability/           # + Propositional/Tactic.lean (PropDecide); − TraceExport
│   │   ├── Independence/ Deterministic/
│   │   ├── Expressiveness/         # NEW (ADR-011): Kamp/, EFGames/, GameTransfer/, Separation/, nine single modules
│   │   └── WeakCanonical/          # residual: weak canonical model + Z/R/group/dense constructions
│   ├── Automation/                 # library tactics only: Tactics/, ProofSearch/, Normalization, SuccessPatterns
│   ├── Examples/                   # imports specific Automation modules, never the tooling
│   └── MainResults.lean
├── BimodalTools/                   # NEW lean_lib, outside defaultTargets: dataset/ML/benchmark tooling + the 12 exe roots
├── Boneyard/                       # MOVED from under FormalSystem/ (ADR-010); module names Boneyard.*
├── Tests/
│   ├── BimodalTest.lean, BimodalTest/          # mirrored; loose Decidability probes under Metalogic/Decidability/
│   └── BimodalToolsTest.lean, BimodalToolsTest/  # tests of BimodalTools
├── scripts/                        # invariant harness + README.md; one-off migrations removed
├── docs/                           # user-guide, reference, architecture, development
└── typst/                          # maintained reference manual, using the root references.bib
```

Removed from the tracked deliverable at the publication gate: `latex/` (frozen edition and its
PDF), `docs/research/`, `docs/training/` (moves with the dataset project or into the tooling
library's README), the tracked paper PDF under `docs/papers/`, `CLAUDE.md`,
`.claude-extensions.json`, `.syncprotect`, the empty `.gitattributes`, `specs/`, and the one-off
scripts (`migrate_schema_v2.py`, `swap_untl_snce.py`, `standardize_metadata.py`,
`add-copyright-headers.sh`).

### Lakefile target shape

```toml
name = "BimodalLogic"
defaultTargets = ["FormalSystem"]
testDriver = "BimodalTest"
lintDriver = "batteries/runLinter"

[leanOptions]
weak.linter.mathlibStandardSet = true
weak.linter.style.longFile = 1500

[[lean_lib]]
name = "FormalSystem"

[[lean_lib]]
name = "BimodalTest"
srcDir = "Tests"

[[lean_lib]]            # NEW: never built by `lake build`, never imported by FormalSystem
name = "BimodalTools"

[[lean_lib]]            # NEW: built by an explicit CI step, not by testDriver
name = "BimodalToolsTest"
srcDir = "Tests"

[[lean_exe]]            # the 12 tooling exes keep their names; roots move under BimodalTools.*
name = "dataset_generator"
root = "BimodalTools.DatasetGeneratorMain"
supportInterpreter = true
# ...
[[lean_exe]]            # unchanged
name = "checkInitImports"
srcDir = "scripts"
root = "CheckInitImportsMain"
```

`machine_appendix` reads only library declarations, so it could sit beside `checkInitImports`;
it goes into `BimodalTools` for uniformity. C25 and C25N read roots from the lakefile through
`scripts/lake_targets.py`, so they follow the re-rooting automatically.

### Namespace map (rows that change)

| Current location | Current namespace | Target location | Target namespace | FQN churn |
|---|---|---|---|---|
| `Syntax/{Plus,Minus,Star}Language/*`, `Semantics/{Plus,Minus,Star}Language/*` (15 files) | `FormalSystem.{Plus,Minus,Star}Language` | `{Plus,Minus,Star}Language/*` | unchanged | none |
| `Metalogic/Decidability/FMP/Periodicity.lean` | `FormalSystem.Semantics` | `Semantics/Periodicity.lean` | unchanged | none |
| `Metalogic/Conservativity/MinusLanguageSoundness.lean` | `FormalSystem.Semantics` | `MinusLanguage/Soundness.lean` | `FormalSystem.MinusLanguage` | yes (small) |
| `Automation/{TruthNormAttr,LemmaDB,NormalizationAttr}` | attribute names only | `Tactic/Attr.lean` | attribute names unchanged | none |
| `Automation/Tactics/PropDecide.lean` | `...Decidability.Propositional.PropForm` (already) | `Metalogic/Decidability/Propositional/Tactic.lean` | unchanged | none |
| `Metalogic/Core/DeductionTheorem.lean` | `FormalSystem.Metalogic.Core` | `Theorems/DeductionTheorem.lean` | **keep** (recorded ancestor-style exception) | none; alternative: rename in Phase 6's FQN pass |
| `Metalogic/WeakCanonical/{Kamp,EFGames,Separation,...}` (141 files) | `...Metalogic.WeakCanonical.*` | `Metalogic/Expressiveness/...` | `Metalogic.Expressiveness.*` | **yes, citeable; two main-results entries** |
| `Metalogic/WeakCanonical/Expressiveness/*` | `...WeakCanonical.Expressiveness` | `Metalogic/Expressiveness/GameTransfer/*` | `...Expressiveness.GameTransfer` | yes |
| `Automation/<tooling>`, `Metalogic/Decidability/TraceExport.lean` (25 modules) | `FormalSystem.Automation.*`, `...Decidability` | `BimodalTools/*` | `BimodalTools.*` | yes (tooling only, not library API) |
| `FormalSystem/Boneyard/*` (169 files) | module names `FormalSystem.Boneyard.*` | `Boneyard/*` | `Boneyard.*` | module names only (never built) |
| Three files declaring a foreign namespace (`BXCanonical/Chronicle/ChronicleRealExtension.lean` in `Metalogic.Bundle`; `WeakCanonical/{DenseModelSurgery/ChronicleInstance,RealModel/ChronicleRealFlow}.lean` in `BXCanonical.Chronicle`) | foreign | unchanged | record, or move the declarations | decide per file in Phase 5 |

## 5. Templates

### Library file header and module docstring

```lean
/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/
import FormalSystem.Semantics.Truth

/-!
# Kamp's Theorem: expressive completeness of Since/Until over Dedekind-complete orders

One paragraph on what the file proves and where it sits in the development.

## Main definitions

* `Metalogic.Expressiveness.Kamp.ExistsForallFormula`: ...

## Main results

* `Metalogic.Expressiveness.Kamp.kampPriorExpressiveCompleteness`: ...

## Implementation notes

(Optional. Design choices a reader of the proof needs; never task history or tool notes.)

## References

* [A. Rabinovich, *A Proof of Kamp's Theorem*][rabinovich2014], Lemma 5.3
* [B. Brast-McKie, *The Construction of Possible Worlds*][brastmckie2026construction]
-/
```

Rules the template encodes:

- References use the `* [Author(s), *Title*][bibkey]` link form; keys resolve in the root
  `references.bib`. Theorem or lemma locators follow the link. Page-only citations are fine;
  notes about local transcriptions, tooling or task history are never.
- Paper anchors for the JPL paper (the `def:` / `thm:` forms C15 resolves against
  `docs/reference/paper-definitions-of-record.md`) go inside `## References` after the paper's
  link entry. This replaces the `## Paper Specification Reference` heading.
- `## Tags` stays (Mathlib-legal). `## Implementation Status` goes: status belongs to
  `MainResults.lean` and `docs/theorem-index.md`.

### Test file

Same header. cslib turns the header linter off for tests; this repository's tests already
comply, so no opt-out is needed. A test file's docstring says what it probes and which library
module it exercises; `#guard` / `#guard_msgs` for assertions, never bare `#eval`.

### `CITATION.cff` at publication

Keep the file. Set `version` and `date-released` to the actual tagged release (no tag exists
today although the file says otherwise); add `doi` once a Zenodo release is minted; keep
`repository-code`. The file is otherwise clean.

### README lead

Lead with what the library proves and a pointer to `MainResults.lean`; then install and build;
then "How to cite". Move the Logos / ProofChecker / ModelChecker architecture paragraph to a
short "Related projects" section or drop it.

## 6. Measurements

Every number in this document and in ADR-011 comes from:

```bash
python3 scripts/measure-refactor-partitions.py all          # markdown tables
python3 scripts/measure-refactor-partitions.py all --json   # machine-readable
python3 scripts/measure-refactor-partitions.py --check      # exit 1 if the Expressiveness set leaks
```

The script parses each file's *leading* `import` block only (`scripts/lib/import_graph.py`) and
excludes the archive by directory name, exactly as the invariant harness does. Measured on
commit `220e94ea4`:

| Measurement | Value |
|---|---|
| Expressiveness set | 141 files, 104,087 lines, 0 edges into the residual set or `BXCanonical` |
| Residual `WeakCanonical` | 38 files, 28,472 lines |
| `BXCanonical`-free by closure | 150 of 179 modules |
| Import lines from the five lower layers into `Automation` | 16, of which 11 into the attribute-only files |
| `Theorems` files importing `Metalogic` | 4, all `Metalogic.Core.DeductionTheorem` |
| `Metalogic` files importing `Theorems` | 29 files, 47 lines |
| Automation modules the library needs by closure | 9 (3,419 lines) |
| User-facing tactic modules (library API, imported by no library file) | 4 (1,238 lines) |
| Tooling modules, including `TraceExport` | 25 (14,747 lines); 12 are exe roots |
| Namespace vs directory | 279 equal-or-descendant, 187 ancestor, 24 unrelated, 43 without a namespace |
| C6 manifest (unreachable live modules) | 15 entries |
| Loose files at the `Tests/BimodalTest/` root | 12: 8 `*Probe.lean` and `TableauConformance.lean` (all importing only `Metalogic.Decidability.*`), 3 `Trace*` (importing `TraceExport`) |

Discrepancies against the source analysis this programme was drafted from, resolved in the
script's favour: the upward edges into `Automation` number 16 lines (11 attribute-only), not
17 (12); 15 of the 24 unrelated namespaces are the language-extension files, not 17; the C6
manifest carries 15 entries, not 26; there are 8 probe files, not 9; the convention map has 23
rows, not 26.

## 7. Phased programme

Legend: **[CITE]** marks a phase that changes a path, module name or fully-qualified name an
external reader would cite; every such phase lands before publication and before the first
release tag. Every phase ends with `lake build`, `lake build BimodalTest` and
`bash scripts/check-module-invariants.sh` green, plus the phase-specific check named below.

### Phase 0: Tooling for mechanical moves (no tree change)

- Write `scripts/move-modules.py`: takes an `old.module -> new.module` mapping plus an optional
  namespace mapping, and in one pass rewrites `import` lines in `FormalSystem/`, `Tests/` and
  the archive (keeping C11 green); dotted and slash paths in `docs/`, `typst/`, the `scripts/`
  manifests and allowlists, the READMEs and `ORGANISATION.md` (C4/C5/C12/C13/INV);
  `namespace` / `open` / fully-qualified occurrences when a namespace mapping is given; and the
  C2/C14 axiom baselines and `MainResults.lean`. It ends by running the harness `--no-build`.
- Deliverable: the script, a dry-run mode, and its first production use in Phase 2 (the
  archive move), which validates every rewrite class on a real move rather than a toy.
- **[CITE]**: no. **Acceptance**: dry run on the Phase 2 mapping reports every file it would
  touch and the harness passes on the applied result. **ADR**: none.

### Phase 1: Deliverable hygiene (no Lean change)

- Untrack `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect` and the empty
  `.gitattributes` (add to `.gitignore`). **`specs/` is not untracked here** — see Section 8.
- Remove personal absolute paths from `docs/` and `typst/` (two `docs/` files and one typst file
  today). The `.lean` occurrences are docstring edits and wait for Phase 7.
- Remove the one-off scripts; add `scripts/README.md` naming every remaining script.
- Move `CONTRIBUTING.md` to the repository root. Move `docs/research/` and `docs/training/` out
  of the deliverable. Retire `latex/` and its tracked PDF together with the C10/C12 references
  to it.
- Rewrite the internal Logos / ProofChecker naming in `README.md`, `docs/` and `CITATION.cff`
  (the `.lean` and test occurrences wait for Phase 7).
- **[CITE]**: not for Lean names, but it changes repository paths (`latex/`), so before
  publication. **Acceptance**: harness green; `scripts/readme-lint.sh` green;
  `grep -rn 'home/benjamin' docs typst` empty. **ADR**: none.

### Phase 2: Archive to the repository root — [CITE]

- `git mv` the archive from under `FormalSystem/` to a root-level `Boneyard/`; module names
  `FormalSystem.Boneyard.*` -> `Boneyard.*`. Rewrite the 538 archived imports and every citer
  (48 live docstrings, 43 markdown files, the scripts, 5 typst files) with the Phase 0 tool.
- Update B0's search root and C11's scan root; add the two new invariants ADR-010 names (no
  `Boneyard` in `lakefile.toml` or the root aggregator; no `import Boneyard.*` from live code).
- Accept **ADR-010**; move ADR-009's status pointer accordingly.
- **Acceptance**: harness green with the updated B0/C11; `lake build` produces no `.olean`
  under `Boneyard/`; the archive README's counts regenerate from the new location. Must precede
  Phase 8's `mk_all --check`.

### Phase 3: Split tooling into `BimodalTools` — [CITE] (tooling module names; exe names unchanged)

- Create `lean_lib BimodalTools` and `BimodalToolsTest`. Move the 25 tooling modules (Section 6)
  including `Metalogic/Decidability/TraceExport.lean`; re-root the 12 exes.
- Move the tooling tests (the 3 `Trace*` files at the test root and the `Tests/BimodalTest/Automation/`
  files that import tooling modules — the script's `automation-partition` lists them) into
  `BimodalToolsTest/`.
- `Examples/BimodalProofs.lean` imports specific Automation modules instead of the aggregator.
- Decide `SuccessPatterns`: if it is a data structure used only for heuristics, keep a minimal
  interface in the library and move learning/serialisation to the tooling; otherwise keep it and
  document why. `ProofSearch/Core.lean` importing it is the edge to inspect.
- Update the CI exe-root step, `scripts/typst-module-map.sh` and the automation-module-map
  generator.
- **Acceptance**: `lake build` (FormalSystem only) writes zero `.olean` under `BimodalTools/`;
  a new check asserts `FormalSystem` never imports `BimodalTools`; `lake build BimodalToolsTest`
  exits 0 as an explicit CI step. **ADR**: none.

### Phase 4: Remove the upward edges by relocation — [CITE] only for the `DeductionTheorem` path; FQNs preserved

- Create `Tactic/Attr.lean` (the three `register_*_attr` files merged) and import it from
  `Init.lean`; delete the 11 attribute edges.
- Move `PropDecide` (and `Tactics/Meta` if it needs it) to
  `Metalogic/Decidability/Propositional/Tactic.lean`, so `Algebraic -> Decidability` is a
  same-layer edge.
- Move `Metalogic/Core/DeductionTheorem.lean` to `Theorems/DeductionTheorem.lean`, keeping its
  namespace (recorded ancestor-style exception); this removes the 4 `Theorems -> Metalogic`
  lines.
- Move `Metalogic/Decidability/FMP/Periodicity.lean` to `Semantics/Periodicity.lean` (its
  namespace already says so).
- Re-document `Decidability -> ProofSearch / Normalization` as a legitimate "Decidability
  depends on library automation" edge, placing library automation *below* Decidability in the
  corrected layer table; cut `ProofSearch.Core -> SuccessPatterns` per Phase 3's decision.
- Rewrite ORGANISATION.md's layer table to the measured order (Syntax / ProofSystem / ForMathlib
  -> Semantics -> Theorems -> Metalogic -> Examples, with library automation beside Metalogic)
  and extend `check-metalogic-cycles.sh` into a layer-order assertion.
- **Acceptance**: `python3 scripts/measure-refactor-partitions.py upward-edges` reports zero
  lines into `Automation` from Syntax, Semantics, ProofSystem and Theorems, and zero
  `Theorems -> Metalogic`; the layer assertion passes. **ADR**: none (ADR-008's
  `Semantics -> ProofSystem` edge is untouched).

### Phase 5: Language-extension directories and namespace/path agreement — [CITE] (paths only; FQNs unchanged for the 15 files)

- Merge `Syntax/XLanguage/` and `Semantics/XLanguage/` into `XLanguage/` under the library root
  for Plus, Minus and Star; namespaces already match.
- `MinusLanguage/AxiomDischarge.lean`'s imports of Theorems and Metalogic become ordinary
  downward edges from an extension language to the base logic.
- Move `Metalogic/Conservativity/MinusLanguageSoundness.lean` to `MinusLanguage/Soundness.lean`.
- Settle the three foreign-namespace Chronicle files (Section 4's last namespace-map row).
- Move the 8 loose Decidability probes and `TableauConformance.lean` into
  `Tests/BimodalTest/Metalogic/Decidability/`.
- **Acceptance**: `namespace-audit` reports at most the recorded exceptions in the unrelated
  bucket (`ForMathlib/Order/PFilter.lean`, `PropDecide` until Phase 4 lands, the decided
  Chronicle files); no loose `.lean` at the test root except the `Property.lean` aggregator.
  **ADR**: none.

### Phase 6: Extract `Metalogic/Expressiveness/` — [CITE] (largest name change; two main-results entries)

Split into two green commits.

- **6.1 Scripted move plus namespace.** Run `python3 scripts/measure-refactor-partitions.py --check`
  and require exit 0 against the tree being moved. Move the 141-file set with the Phase 0 tool
  as path-plus-namespace mapping `...Metalogic.WeakCanonical.X -> ...Metalogic.Expressiveness.X`
  for every `X` in the set (`WeakCanonical/Expressiveness/` becomes
  `Expressiveness/GameTransfer/`); add the sibling aggregator `Metalogic/Expressiveness.lean`;
  regenerate `typst/generated/*`, `docs/theorem-index.md`, the C2/C14 baselines and
  `MainResults.lean` in the same commit.
- **6.2 Content renames and stub deletion.** Give the 39 paper-numbered or history-suffixed
  files content names (what each proves), and delete declaration-free compatibility stubs after
  confirming zero declarations in each.
- Accept **ADR-011**; move ADR-006's status pointer accordingly.
- **Acceptance**: `bash scripts/check-metalogic-cycles.sh` still reports exactly 1 cycle;
  `weakcanonical-partition` shows the residual set at 38 files; the full harness (with build)
  green after each commit.

### Phase 7: Docstring and citation normalisation (not [CITE]; visible in published docs)

- Convert every `## References` entry to the `* [Author, *Title*][key]` form; merge
  `typst/bibliography.bib` into the root `references.bib` and point typst at it.
- Fold the `## Paper Specification Reference` sections into `## References`; remove
  `## Implementation Status`.
- Strip internal-tooling notes, the personal paths in the `WeakCanonical/{Kamp,DenseModelSurgery}`
  docstrings, and the Logos / ProofChecker wording in `Examples/`, `Semantics/{TaskFrame,Truth}.lean`
  and the tests.
- **Acceptance**: C14, C15 and C19 green; `grep -rn 'home/benjamin' FormalSystem Tests` empty;
  typst compiles against the root bibliography. **ADR**: none.

### Phase 8: CI and contribution parity

- Collapse the root to one `FormalSystem.lean` generated by `lake exe mk_all`; absorb
  `FormalSystem/FormalSystem.lean`. Wire or archive the C6-manifested modules until the manifest
  is empty (archiving needs the `#exit` header convention).
- Add CI steps for `lake exe mk_all --check` (as a new harness check) and `lint-style-action`.
- Add a tag-triggered release workflow; adopt cslib's module-size policy text in
  ORGANISATION.md.
- Verify whether `linter.style.header` under `--wfail` already fails on a broken header; if it
  does, retire `check-copyright-headers.sh`.
- **[CITE]**: no. **Acceptance**: `mk_all --check` green; the C6 manifest empty; the release
  workflow dry-runs on a test tag. **ADR**: none.

### Phase 9 (optional, post-publication acceptable): size splits and the module system

- Split the two files over 4,500 lines (`EFGames/GapDetection.lean`, the split-point file)
  only along import-acyclic declaration families, keeping declaration namespaces.
- Evaluate the Lean module system (`module` / `public import`) as its own programme.
- **[CITE]**: no, provided splits keep namespaces. **ADR**: a new one if the module system is
  adopted.

## 8. Dependency order and the publication gate

```
0 -> 1 -> 2 -> {3, 4} -> 5 -> 6 -> 7 -> 8 -> 9
```

Phases 3 and 4 are independent after Phase 2. Phase 4 precedes Phase 6 so the Expressiveness
move does not also carry attribute-edge churn. Phase 8's `mk_all --check` requires Phase 2.

**Publication gate**: Phases 1-7 complete and Phase 8's root collapse done. Then, in one commit
immediately before the release tag, untrack the remaining non-deliverable set — `specs/`,
`CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, the empty `.gitattributes` — and add
them to `.gitignore`. Then the maintainer creates the `v1.0.0` tag and updates `CITATION.cff`
(`version`, `date-released`, later `doi`).

`specs/` stays tracked *while the programme runs*, deliberately: the task workflow that executes
the phases commits its provenance there (`.gitignore` already carves out the two provenance
files it must keep), and untracking it mid-programme would break that workflow. Untracking at
the gate, rather than deleting history, is enough for the published surface; keeping it on a
separate, unpublished branch is the alternative if the provenance should survive publication.

## 9. Follow-up task split

Nine self-contained follow-ups, one per programme phase group, in dependency order. Each
description is paste-ready and names its acceptance checks; none refers to this document's
provenance.

**A — Move tool and archive relocation (Phases 0 + 2, ADR-010)**
> Write `scripts/move-modules.py` (old-to-new module mapping plus optional namespace mapping;
> rewrites imports in FormalSystem/, Tests/ and the archive, dotted and slash paths in docs/,
> typst/ and the scripts/ manifests, namespace/open/FQN occurrences, the C2/C14 baselines and
> MainResults.lean; dry-run mode; ends by running check-module-invariants.sh --no-build). Then
> use it to move FormalSystem/Boneyard/ to a root-level Boneyard/ (module names Boneyard.*),
> update B0's search root and C11's scan root, add the two invariants ADR-010 names, and change
> ADR-010's status to Accepted with a pointer from ADR-009. Acceptance: lake build and lake build
> BimodalTest exit 0; check-module-invariants.sh green; no .olean under Boneyard/; the archive
> README's counts regenerate from the new location.

**B — Deliverable hygiene (Phase 1, excluding `specs/`)**
> Untrack CLAUDE.md, .claude-extensions.json, .syncprotect and the empty .gitattributes; remove
> personal absolute paths from docs/ and typst/; delete the one-off scripts
> (migrate_schema_v2.py, swap_untl_snce.py, standardize_metadata.py, add-copyright-headers.sh)
> and add scripts/README.md naming every remaining script; move CONTRIBUTING.md to the root;
> move docs/research/ and docs/training/ out of the deliverable; retire latex/ and its PDF with
> the C10/C12 references to it; rewrite Logos and ProofChecker naming in README.md, docs/ and
> CITATION.cff. Do not untrack specs/. Acceptance: check-module-invariants.sh and readme-lint.sh
> green; grep -rn 'home/benjamin' docs typst empty.

**C — `BimodalTools` split (Phase 3)**
> Create lean_lib BimodalTools (outside defaultTargets) and BimodalToolsTest; move the 25
> tooling modules that `python3 scripts/measure-refactor-partitions.py automation-partition`
> lists (including Metalogic/Decidability/TraceExport.lean) and re-root the 12 lean_exe targets
> under BimodalTools.*; move the tooling tests it lists into BimodalToolsTest; make
> Examples/BimodalProofs.lean import specific Automation modules; decide SuccessPatterns' split;
> update the CI exe-root step, typst-module-map.sh and the automation-module-map generator.
> Acceptance: lake build writes no .olean under BimodalTools/; a new check asserts FormalSystem
> never imports BimodalTools; lake build BimodalToolsTest exits 0 in CI; harness green.

**D — Upward edges by relocation (Phase 4)**
> Create Tactic/Attr.lean under the library root from Automation/{TruthNormAttr,
> NormalizationAttr,LemmaDB} and import it from Init.lean; move Tactics/PropDecide.lean to
> Metalogic/Decidability/Propositional/Tactic.lean; move Metalogic/Core/DeductionTheorem.lean to
> Theorems/ keeping its namespace; move Metalogic/Decidability/FMP/Periodicity.lean to
> Semantics/; cut ProofSearch.Core -> SuccessPatterns; rewrite ORGANISATION.md's layer table to
> the measured order and extend check-metalogic-cycles.sh into a layer-order assertion.
> Acceptance: `measure-refactor-partitions.py upward-edges` reports zero lines into Automation
> from Syntax, Semantics, ProofSystem and Theorems and zero Theorems -> Metalogic; harness green.

**E — Language-extension directories and probe tests (Phase 5)**
> Merge Syntax/XLanguage/ and Semantics/XLanguage/ into XLanguage/ under the library root for
> Plus, Minus and Star (namespaces already match); move Metalogic/Conservativity/
> MinusLanguageSoundness.lean to MinusLanguage/Soundness.lean; settle the three files declaring
> a foreign Chronicle/Bundle namespace; move the 8 *Probe.lean files and TableauConformance.lean
> from the Tests/BimodalTest/ root into Tests/BimodalTest/Metalogic/Decidability/. Acceptance:
> `measure-refactor-partitions.py namespace-audit` shows only the recorded exceptions as
> unrelated; harness green.

**F — Expressiveness extraction (Phase 6, ADR-011)**
> Run `python3 scripts/measure-refactor-partitions.py --check` (must exit 0), then move the
> 141-file Expressiveness set out of Metalogic/WeakCanonical/ into Metalogic/Expressiveness/
> with the namespace mapping WeakCanonical.X -> Expressiveness.X (WeakCanonical/Expressiveness/
> becomes Expressiveness/GameTransfer/), in one scripted commit that also regenerates
> typst/generated, docs/theorem-index.md, the C2/C14 baselines and MainResults.lean; then in a
> second commit rename the 39 paper-numbered files to content names and delete declaration-free
> stubs. Change ADR-011's status to Accepted with a pointer from ADR-006. Acceptance:
> check-metalogic-cycles.sh reports exactly 1; residual WeakCanonical at 38 files; full harness
> (with build) green after each commit.

**G — Docstring and citation normalisation (Phase 7)**
> Convert every `## References` entry in FormalSystem/**/*.lean to Mathlib's
> `* [Author, *Title*][key]` form resolving in the root references.bib; merge
> typst/bibliography.bib into it and point typst at the root file; fold `## Paper Specification
> Reference` into `## References` and remove `## Implementation Status`; strip tooling notes,
> personal paths and Logos and ProofChecker wording from library docstrings, Examples/ and tests.
> Acceptance: C14, C15, C19 green; grep -rn 'home/benjamin' FormalSystem Tests empty; typst
> compiles.

**H — CI parity, root collapse and publication gate (Phase 8)**
> Collapse the root to one FormalSystem.lean generated by lake exe mk_all (absorbing
> FormalSystem/FormalSystem.lean); wire or archive every C6-manifested module until the manifest
> is empty; add CI steps for mk_all --check (as a harness check) and lint-style-action; add a
> tag-triggered release workflow; adopt the module-size policy text; test whether
> linter.style.header under --wfail makes check-copyright-headers.sh redundant. Then, at the
> gate, untrack specs/, CLAUDE.md, .claude-extensions.json, .syncprotect and .gitattributes in
> one commit and hand off to the maintainer for the v1.0.0 tag and the CITATION.cff update.
> Acceptance: mk_all --check green; C6 manifest empty; release workflow dry-run passes.

**I — Post-publication (Phase 9, optional)**
> Split EFGames/GapDetection.lean and the split-point file only along import-acyclic declaration
> families, keeping namespaces; evaluate adopting the Lean module system as its own programme.
> Acceptance: no fully-qualified name changes; harness green.

## Related

- [ADR-010](../architecture/ADR-010-Boneyard-At-Repository-Root.md) and
  [ADR-011](../architecture/ADR-011-Extract-Expressiveness.md) — the two Proposed decisions
- [MODULE_INVARIANTS.md](MODULE_INVARIANTS.md) — the harness every phase must keep green, and
  the measurement script's catalogue entry
- [ORGANISATION.md](../../ORGANISATION.md) — the layer table Phase 4 corrects
- `scripts/measure-refactor-partitions.py` — the source of every count above

---

[Back to Development Documentation](README.md)
