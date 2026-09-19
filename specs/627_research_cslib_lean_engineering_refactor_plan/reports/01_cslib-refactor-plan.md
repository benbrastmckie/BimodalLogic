# Research Report: Task #627

**Task**: 627 - Research cslib as a Lean engineering reference model and produce a publication-standard refactor plan for BimodalLogic / FormalSystem
**Started**: 2026-09-19T06:23:45Z
**Completed**: 2026-09-19T06:45:00Z
**Effort**: Research ~1 session; the refactor programme below is estimated at 9 phases / roughly 6-10 implementation dispatches
**Dependencies**: None (research only; FormalSystem/ and Tests/ were not modified)
**Sources/Inputs**: - Codebase (FormalSystem/, Tests/, scripts/, docs/, lakefile.toml, .github/), `github.com/benbrastmckie/cslib` shallow clone at `3bdf16d9` (2026-08-11), measured import-graph analysis (Python walk over live `import` headers), lean-lsp MCP not needed (no proof goals in scope)
**Artifacts**: - specs/627_research_cslib_lean_engineering_refactor_plan/reports/01_cslib-refactor-plan.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The `benbrastmckie/cslib` fork is only a partial model.** Its Lean-facing engineering matches upstream `leanprover/cslib`: the lakefile, `Cslib.lean` aggregator checked by `mk_all`, `Cslib/Init.lean`, headers, `## References` with bib keys, CI, root-level `Boneyard/`. Its repository surface does not: it tracks 3,528 `specs/` files plus `.claude/`, `.memory/` and `typst/`. For the deliverable-hygiene items (g), the model to follow is **upstream cslib's** top-level surface, not the fork's.
- **ADR-006's premise no longer holds for most of `WeakCanonical/`.** The measured import closure shows **141 files / 104,087 lines** of `Metalogic/WeakCanonical/` with **no path to `BXCanonical`** and **no import into the rest of `WeakCanonical/`**: Kamp/, EFGames/, Expressiveness/, Separation/, MonadicFO, NormalForm, StaviConnectives, Prior*, Table and EFGameTactics. They can move to a new sibling `Metalogic/Expressiveness/` without creating a new cycle. The `BXCanonical <-> WeakCanonical` cycle stays inside the remaining ~28.5k-line core (38 files), which the move leaves in place. ADR-006 should be superseded, not reaffirmed.
- **The upward-edge list in the task description is incomplete.** The measured edges number 17 lines across four classes: (i) **12 edges into attribute-only files** (`Automation/{TruthNormAttr,LemmaDB}`) from Syntax, Semantics, ProofSystem and Theorems; (ii) Algebraic -> `Tactics.PropDecide`; (iii) Decidability -> `ProofSearch.*`, `Normalization`, `DataExport`; (iv) `Syntax/MinusLanguage/AxiomDischarge.lean` -> Theorems and Metalogic, plus `Semantics/Extension/PeriodicExtension.lean` -> `Metalogic.Decidability.FMP.Periodicity`. Separately, Theorems and Metalogic import each other: 4 Theorems files import `Metalogic.Core.DeductionTheorem`, and 29 Metalogic files import Theorems. So the layer table in ORGANISATION.md is wrong, not just excepted.
- **Most of these edges disappear through moves that keep namespaces.** Move the `register_*_attr` files into `FormalSystem/Tactic/Attr.lean`, imported by Init, as cslib/Mathlib do. Move `DeductionTheorem` into `Theorems/`. Move `Periodicity.lean` into `Semantics/`, whose namespace it already declares. Move `{Plus,Minus,Star}Language` out of `Syntax/` and `Semantics/` into `FormalSystem/{Plus,Minus,Star}Language/`; their namespace is already `FormalSystem.PlusLanguage` and so on.
- **The Automation split is measured.** Library code (outside Examples and the MainResults page) needs only 9 Automation modules: 3 attribute files, Normalization, ProofSearch.Core/Strategies, SuccessPatterns, Tactics.Meta and Tactics.PropDecide. The dataset/ML modules plus the 13 `*Main` roots and `Metalogic/Decidability/TraceExport.lean` form a separate ~16k-line tooling library. It can be carved out as a new `lean_lib` outside `defaultTargets`.
- **Recommended programme: 9 phases, each keeping `lake build` and `check-module-invariants.sh` green.** Phases 2-7 change paths or fully-qualified names that external readers would cite, so they must all land before publication and before a v1.0.0 git tag. No tag exists yet, although CITATION.cff says `version: "1.0.0"`, `date-released: 2026-09-07`. Two headline results live in `FormalSystem.Metalogic.WeakCanonical.*` and will be renamed by Phase 6.

## Context & Scope

Two things were surveyed:

1. **cslib**: a shallow clone of `https://github.com/benbrastmckie/cslib` at `3bdf16d9` (lean-toolchain `v4.33.0-rc1`, the same as this repo). It has 821 `.lean` files and 204,743 lines under `Cslib/Logics/`. Both repos are written by the same author, and the fork's `Cslib/Logics/Bimodal/` (~57k lines) is a port of this repository's library. It is therefore a useful before/after for several structural questions.
2. **This repository** (`main` at `220e94ea4`): 533 live library files (`FormalSystem/` minus `Boneyard/`), 62 test files, 13 `lean_exe` targets, and the `check-module-invariants.sh` harness (B0, C1-C30, INV).

Constraints: no edits to `FormalSystem/` or `Tests/`. Every proposed phase must keep `lake build` and `scripts/check-module-invariants.sh` green. ADR-006 and ADR-009 must each be reaffirmed or superseded.

All line and file counts below were **measured on the live tree** in this session, not copied from READMEs. The import-graph numbers come from a closure walk over each file's leading `import` block. Docstring lines that begin with `import` are excluded, because two root docstrings contain `import FormalSystem`, which a naive grep turns into a false self-cycle.

## Findings

### Codebase Patterns

#### cslib survey (the eight requested dimensions)

**(1) Library/package layout and lakefile.** The package is `cslib` with `defaultTargets = ["Cslib"]`, `testDriver = "CslibTests"` and `lintDriver = "batteries/runLinter"`. There are two `lean_lib`s (`Cslib`, `CslibTests`, the latter with `weak.linter.style.header = false`) and exactly **one** `lean_exe` (`checkInitImports`, `srcDir = "scripts"`). Package-wide `[leanOptions]` set `weak.linter.mathlibStandardSet = true` and `weak.linter.flexible = true`, and explicitly turn off four Mathlib linters that do not work downstream. `Cslib.lean` is a `module` file with a `public import` of every file; `lake exe mk_all --check` in CI enforces completeness. `Cslib/Init.lean` imports `Mathlib.Init`, `Mathlib.Tactic.Common` and the local `Cslib.Foundations.Lint.Basic`, and `checkInitImports` asserts that every file reaches it.

**(2) Namespace discipline.** The directory is `Cslib/Logics/Bimodal`, but the namespace is `Cslib.Logic.Bimodal`. This is a deliberate, documented path/namespace split: ORGANISATION.md's "Namespace Convention" says `Cslib.Logic` spans both `Foundations/Logic/` and `Logics/`. Below that prefix, namespaces follow the path. Leaf-level namespaces can be per-file (for example `Cslib.Logic.Bimodal.Metalogic.Algebraic.BooleanStructure`).

**(3) Public API surface.** The whole library uses the Lean **module system**: `module`, `public import`, and `@[expose] public section`. cslib has 866 `private` and 71 `protected` declarations. Theorems outnumber lemmas 5,053 to 1,686; cslib uses both keywords. There is no "main results" page. The per-logic hierarchy is Syntax -> ProofSystem -> Semantics -> Theorems -> Metalogic, and automation lives next to the logic it serves (`Foundations/Logic/Automation/HilbertSearch.lean`), not in a top-level layer.

**(4) Docstrings.** Every file has a `/-! # Title ... -/` module docstring with Mathlib section headings. Counts: `## References` 426, `## Main Results` 176, `## Main Definitions` 141, plus `## Implementation Notes` and `## Notation`. CONTRIBUTING defers to the Mathlib style guide and asks contributors to "reference the resource in your documentation".

**(5) Citations.** One root `references.bib` (41.8 KB, DBLP-style entries). Docstrings use Mathlib's link-reference form: `* [P. Blackburn, M. de Rijke, Y. Venema, *Modal Logic*][Blackburn2001]`. Keys are `AuthorYear` in CamelCase, for example `Blackburn2001` and `ChagrovZakharyaschev1997`.

**(6) License and authorship.** Mathlib header: `Copyright (c) YYYY Name. All rights reserved.` / `Released under Apache 2.0 license as described in the file LICENSE.` / `Authors: ...`. This appears on all 715 library files. `AUTHORS.md` states that copyright is held by the individual authors named in each file header. There is **no CITATION.cff**. `GOVERNANCE.md` and `CODE_OF_CONDUCT.md` are at the root.

**(7) Linters, CI, contribution conventions.** `lean_action_ci.yml` runs `lake build --wfail --iofail`, `lake test`, `mk_all --check`, `checkInitImports`, `lint-style-action` (Mathlib text linters) and two ratchets (`check-sorry-suppressions.sh`, `check-axiom-census.sh`). `lake shake` is disabled and replaced by a local ratchet. Other workflows cover docs, releases (triggered by `v*` tags), PR-title prefixes (`feat|fix|doc|style|refactor|test|chore|perf`), weekly linting, shellcheck and TODO->issue. Top-level `CONTRIBUTING.md` covers style, the AI-use policy (inherited from Mathlib) and CI commands. `scripts/README.md` documents every script. ORGANISATION.md has a **module-size policy**: prefer files under ~1,500 lines; a file over ~3,000 needs a justifying note or a split plan; "split along the *dependency* structure, never by line count". cslib's own files reach 9,901 lines (`Propositional/Tableau/Intuitionistic/Scheme.lean`) and it sets no `longFile` baselines.

**(8) Tests.** `CslibTests/` is a **flat** directory of 29 files, including `*Probe.lean` and `*Regression.lean` files. The aggregator `CslibTests.lean` imports them all. There is no directory mirroring.

**Boneyard (relevant to e).** The fork has a **root-level** `Boneyard/`, a sibling of `Cslib/`. It ported this repository's own convention (`#exit` guard, `ARCHIVED (Boneyard)` header), but its README argues that **root-level placement is load-bearing**: `mk_all --check` scans every file under `Cslib/`, and a Boneyard under `Cslib/` would be demanded in the aggregator and pulled into build, lint and the censuses. Its policy is: "Import lines inside archived files are historical text, not build edges... stale imports... are cosmetic". A self-test, `check-boneyard-quarantine.sh`, backs this up.

#### This repository's current state (measured)

| Area | Measured state |
|---|---|
| Libraries | `FormalSystem` (default) and `BimodalTest` (`srcDir = "Tests"`), plus 13 `lean_exe`, 12 of which have roots in `FormalSystem.Automation.*Main` |
| Root aggregator | `FormalSystem.lean` imports only `FormalSystem.FormalSystem`, which is a second aggregator inside the directory, the one place the C8 "no `X/X.lean`" rule is broken |
| Root closure | 26 live modules are **not** reachable from any root (the `scripts/module-invariants-manifest.txt`, C6). cslib's `mk_all --check` would reject this |
| Module system | Not used (0 files with `module` / `public import`) |
| Namespaces | 490 files declare a namespace. 279 match their path exactly or with a deeper suffix, 187 use an ancestor-directory namespace (Mathlib-acceptable), and **24 use an unrelated namespace**, 17 of them `{Plus,Minus,Star}Language/*` whose namespace `FormalSystem.PlusLanguage` names a directory that does not exist |
| Headers | All live library and test files carry the Mathlib Apache header (C-script `check-copyright-headers.sh --strict` in CI) |
| Docstrings | `## References` 358, `## Main Results` 145, `## Main Definitions` 129, `## Tags` 93, plus non-standard `## Paper Specification Reference` (12) and `## Implementation Status` (4) |
| Citations | Root `references.bib` (27 lowercase keys, for example `rabinovich2014`) **and** a second `typst/bibliography.bib`. Docstrings use `- [rabinovich2014], ...` rather than Mathlib's `* [Author, *Title*][key]`, and several carry internal notes ("the companion markdown transcription is corrupt") |
| Metalogic size | 376 files, 235,727 lines, of which `WeakCanonical/` is 179 files / 132,559 lines and `WeakCanonical/Kamp/` alone is 116 files / 77,714 lines |
| Long files | 27 live files over 1,700 lines and 38 with a `linter.style.longFile` baseline. The largest are `EFGames/GapDetection.lean` (5,092) and `Expressiveness/SplitPoint.lean` (4,906) |
| Boneyard | `FormalSystem/Boneyard/`: 169 files, 91,983 lines, 42 subtrees. **Every file already has `#exit`**. 575 archived import lines are kept resolvable by C11. Referenced by 48 live `.lean` files, 43 markdown files, 12 scripts, 7 typst files and 1 (frozen) LaTeX file |
| Tests | Mirrored subdirectories, plus 12 loose root files. All 9 `*Probe.lean` files and `TableauConformance.lean` import only `Metalogic.Decidability.*`. The 3 `Trace*Test.lean` files test the TraceExport tooling |
| Tracked non-deliverables | `specs/` (192 tracked files), `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, an empty `.gitattributes`, `docs/research/` (15), `docs/training/` (4), `docs/papers/possible_worlds.pdf`, `latex/BimodalReference.pdf` (frozen edition), one-off scripts (`migrate_schema_v2.py`, `swap_untl_snce.py`, `standardize_metadata.py`, `add-copyright-headers.sh`) |
| Personal paths | `/home/benjamin/...` in `docs/reference/paper-definitions-of-record.md`, `docs/development/DOC_QUALITY_CHECKLIST.md`, `typst/notation/bimodal-notation.typ` and **14 live `.lean` files** under `WeakCanonical/{Kamp,DenseModelSurgery}` |
| Internal naming | "Logos"/"ProofChecker" appears in 81 tracked non-specs files, including `README.md` (lines 9, 366, 374-375), `Examples/*.lean`, `Semantics/{TaskFrame,Truth}.lean` and 11 test files |
| Paper-numbered file names | 39 live files are named `Lemma53Faithful`, `Prop42Vacuity`, `Theorem6`, `SubBracket2V`, `*K1`, `*Faithful` and so on. `Expressiveness/Theorem6.lean` is **declaration-free**, kept only "so that existing imports... continue to compile" |
| Release | No git tags, although CITATION.cff has `version: "1.0.0"` and `date-released: "2026-09-07"` |

#### Measured upward edges (complete list for the five lower layers)

```
Syntax/Formula                          -> Automation.TruthNormAttr        (register_simp_attr only)
Semantics/Truth                         -> Automation.TruthNormAttr        (register_simp_attr only)
ProofSystem/DerivedAxioms               -> Automation.LemmaDB              (register_label_attr only)
Theorems/{Combinators,ModalS5,TemporalDerived,Propositional/{Core,Connectives,Reasoning},
          Perpetuity/{Helpers,Principles}}  -> Automation.LemmaDB          (8 files)
Metalogic/Algebraic/BooleanStructure    -> Automation.Tactics.PropDecide   (propDecide x10; PropDecide itself
                                                                             imports Metalogic.Decidability.Propositional.Kalmar)
Metalogic/Decidability/Closure          -> Automation.ProofSearch.Core     (matchAxiom)
Metalogic/Decidability/DecisionProcedure-> Automation.ProofSearch.Strategies, Automation.Normalization
Metalogic/Decidability/TraceExport      -> Automation.DataExport           (only consumer: TraceExporterMain)
Syntax/MinusLanguage/AxiomDischarge     -> Theorems.* (5), Metalogic.Core.DeductionTheorem
Semantics/Extension/PeriodicExtension   -> Metalogic.Decidability.FMP.Periodicity (namespace: FormalSystem.Semantics)
Theorems/* (4 files)                    -> Metalogic.Core.DeductionTheorem (which imports Theorems.Combinators)
```

Also: `Automation/ProofSearch/Core.lean` imports `Automation.SuccessPatterns` (the ML pattern-learning store), so the decision procedure currently pulls ML tooling into the trusted library closure.

#### Measured WeakCanonical partition (the evidence against ADR-006)

The closure walk classifies each `WeakCanonical` module by whether `BXCanonical` appears anywhere in its transitive imports:

| Set | Files | Lines | Contents |
|---|---:|---:|---|
| **Expressiveness** (proposed move) | 141 | 104,087 | `Kamp/` (77,714), `EFGames/` (11,800), `Expressiveness/` (9,507), `Separation/` (926), `NormalForm`, `MonadicFO`, `StaviConnectives`, `PriorDefs`, `PriorDefsDense`, `PriorExpressiveness`, `PriorExpressivenessDense`, `Table`, `EFGameTactics` |
| Residual `WeakCanonical` | 38 | 28,472 | `ReflexiveCanonical`, `TruthLemma`, `FrameProperties`, `ChronicleExtraction`, `Transfer`, `NEquivalence`, `BackAndForth`, `ColourOrders`, `MixedSum`, `OrderedSum`, `IntegerModel/`, `RealModel/`, `GroupModel/`, `DenseModelSurgery/` |

The Expressiveness set has **zero** imports into residual `WeakCanonical` and **zero** into `BXCanonical`. That is closed by construction, and it was also checked edge by edge. Outside the set, the only importers are `BXCanonical/Chronicle/ChronicleMonadicBridge.lean` (4 lines), one Automation module, and the `WeakCanonical.lean` aggregator. The move therefore creates only one-way edges, `BXCanonical -> Expressiveness` and `WeakCanonical -> Expressiveness`. The single directory-level cycle `check-metalogic-cycles.sh` asserts (count = 1) survives unchanged, as `BXCanonical <-> WeakCanonical` over the 28k residual.

ADR-006 declined a regroup for two reasons: the cycle, and the risk of a partial move ("339 import lines across 137 files"). The first does not apply to the Expressiveness set. The second is a tooling question, and the scripted-move approach in Phase 6 answers it. Two headline results currently carry `WeakCanonical` in their fully-qualified names, as `MainResults.lean`'s `#print axioms` lines show: `FormalSystem.Metalogic.WeakCanonical.Kamp.*` and `FormalSystem.Metalogic.WeakCanonical.uSExpressivelyCompleteOverPrior`. The name "WeakCanonical" misdescribes both of them. This is the strongest pre-publication argument for the move.

#### Measured Automation partition

Excluding `Examples/` (which imports the whole `FormalSystem.Automation` aggregator) and the tooling-only `TraceExport`, the library needs these Automation modules: `TruthNormAttr`, `LemmaDB`, `NormalizationAttr` (three `register_*_attr`-only files, 44-58 lines each), `Normalization`, `ProofSearch.Core`, `ProofSearch.Strategies`, `SuccessPatterns`, `Tactics.Meta` and `Tactics.PropDecide`. The user-facing tactics `Tactics.{Commands,Deduction,Search,UserTactics}` are library content even though no library file imports them. Everything else is dataset/ML/benchmark tooling: `DataExport`, `DatasetGenerator`, `DatasetAssembly`, `FormulaEnumerator`, `InterestingnessMetrics`, `ProofStepExtractor`, `EnrichedCountermodel`, `ForwardProofGenerator`, `AtomCanonicalization`, `PrefilterSoundness`, `AxiomNames`, `ProofFirstBenchmark`, the 12 `*Main` roots, and `Metalogic/Decidability/TraceExport.lean`. That is about 16k lines.

### External Resources

- cslib `ORGANISATION.md` ("Namespace Convention", "Module Size"), `CONTRIBUTING.md` (style, AI policy, CI commands), `Boneyard/README.md` ("Why This Is Free"), `scripts/README.md`, `.github/workflows/lean_action_ci.yml`
- Mathlib style guide (header, docstring, and `* [..][key]` citation form), which cslib CONTRIBUTING references
- Mathlib `lake exe mk_all --check` and `lint-style`, both usable downstream; cslib runs both in CI on the same toolchain
- Upstream `leanprover/cslib` top-level surface (README, CONTRIBUTING, CODE_OF_CONDUCT, GOVERNANCE, AUTHORS, LICENSE, references.bib, NOTATION, ORGANISATION): the model for (g)

### Recommendations

#### Convention map (cslib convention -> this repo -> disposition)

| # | cslib convention | Current state here | Disposition |
|---|---|---|---|
| 1a | One default `lean_lib`; test lib as `testDriver`; `lintDriver = batteries/runLinter` | Same | **Already matches** |
| 1b | Only infrastructure `lean_exe` (`checkInitImports`) | 12 ML/dataset exes rooted in the library | **Adopt**: new `lean_lib BimodalTools` (not in `defaultTargets`) owning the tooling and its exes; `import FormalSystem` no longer pulls training infrastructure (Phase 3) |
| 1c | Root aggregator imports **every** file; `mk_all --check` in CI | Two-level root (`FormalSystem.lean` -> `FormalSystem/FormalSystem.lean`); 26 unreachable live modules tolerated via C6 manifest | **Adopt**: collapse into one generated `FormalSystem.lean`; wire or archive the 26; add `lake exe mk_all --check` (C31) once Boneyard is out of `FormalSystem/` (Phases 2, 8) |
| 1d | `Init.lean` + local lint/attribute module | `Init.lean` imports only Mathlib roots | **Adopt**: `FormalSystem/Tactic/Attr.lean` holding the `register_*_attr` declarations, imported by Init (Phase 4) |
| 2a | Namespace follows path below a documented prefix | Follows path (`FormalSystem.*`), 187 ancestor namespaces, 24 unrelated | **Adopt** for the 24: relocate files to where their namespace says they live (Phases 4-5, zero FQN churn for 18 of them) |
| 2b | Deliberate path/namespace split (`Logics/` vs `Logic`) | None | **Deliberately diverge**: no reason to introduce a split; this repo is one logic |
| 2c | Project-named root (`Cslib`) | Root `FormalSystem`, renamed deliberately from `Theories/Bimodal` in commits `5359fef7d`/`15c7ec977` | **Deliberately diverge (reaffirm)**: a recent, deliberate rename; renaming again is costly churn with no structural benefit |
| 3a | Lean module system (`module`/`public import`/`@[expose]`) | Not used | **Deliberately diverge for now**: it changes no citable path or name, so it can land after publication as its own programme |
| 3b | No top-level automation layer; automation beside the logic it serves | `Automation/` as "layer 4" imported from layers 0-2 | **Adopt partially**: attributes go down to `Tactic/`, and PropDecide moves beside Kalmar in `Metalogic/Decidability/Propositional/`; user tactics stay in `Automation/` (Phases 3-4) |
| 3c | Per-logic ordering Syntax -> ProofSystem -> Semantics -> Theorems -> Metalogic | ORGANISATION.md claims Metalogic(2) < Theorems(3), but 29 Metalogic files import Theorems | **Adopt**: fix the layer table to the real order and move `Core/DeductionTheorem.lean` into `Theorems/` (Phase 4) |
| 3d | `private`/`protected` in use | 1,268 `private`, 0 `protected` | **Already matches** (`protected` optional) |
| 3e | No main-results page | `MainResults.lean` with pinned `#print axioms` (C2/C14/C21) | **Deliberately diverge**: this repo is stronger here; keep it |
| 4a | Mathlib module docstring sections | Mostly matching; non-standard `## Paper Specification Reference`, `## Implementation Status`, `## Tags` | **Adopt**: fold the paper references into `## References`; remove `Implementation Status` (status belongs to MainResults/theorem-index); `## Tags` is Mathlib-legal, keep (Phase 7) |
| 4b | Content-named files | 39 paper-numbered or refactor-history names (`*Faithful`, `*K1`, `SubBracket2V`, `Theorem6`); declaration-free compatibility stubs | **Adopt**: rename to content names and delete stubs, **before** publication (Phase 6, together with the Expressiveness move) |
| 5 | Single `references.bib`; `* [A, *Title*][Key]` | Two bib files; `- [key], ...` form; internal-tooling notes in references | **Adopt**: one root `references.bib` shared by typst; Mathlib link form; strip notes about local transcriptions (Phase 7). Key style: keep lowercase `authorYYYY` (a deliberate divergence, internally consistent and cited from typst) |
| 6a | Mathlib Apache header on every file | Already on every live file; checked by a custom script | **Already matches**. Consider letting Mathlib's `linter.style.header` (on via `mathlibStandardSet`) carry the load and retiring the custom script if it is redundant (Phase 8) |
| 6b | `AUTHORS.md`, no CITATION.cff | CITATION.cff present, no AUTHORS | **Deliberately diverge**: keep CITATION.cff (single author; CFF is what GitHub/Zenodo read). AUTHORS.md not needed with one author |
| 7a | CI: build `--wfail`, test, lint, `mk_all --check`, `checkInitImports`, `lint-style` | build `--wfail`, test, lint, exe-root compile, invariants `--no-build`, headers, README lint, cycles, typst sync, paper defs | **Adopt** `mk_all --check` and `lint-style-action`; keep the richer invariant harness (Phase 8) |
| 7b | Top-level CONTRIBUTING, CODE_OF_CONDUCT, PR-title check, release-on-tag workflow, `scripts/README.md` | CONTRIBUTING under `docs/development/`; no release workflow; no scripts README | **Adopt**: top-level CONTRIBUTING.md (moved), a `scripts/README.md` for every script, and a tag-triggered release workflow. PR-title check optional (single maintainer) (Phase 8) |
| 7c | Module-size policy (split by dependency, never by line count) | `longFile = 1500` with in-source baselines (stricter) | **Adopt the policy text** and keep the baselines. Split only the two >4,500-line files, and only along verified import-acyclic seams (Phase 9, optional, not citation-critical if names are kept) |
| 8 | Flat test directory | Mirrored subdirectories plus 12 loose root files | **Deliberately diverge** (mirroring is better at this size). Move the 10 Decidability probes into `Metalogic/Decidability/`, and the 3 Trace tests into a `BimodalToolsTest` lib alongside the tooling (Phase 3/5) |
| e | Root-level `Boneyard/`, `#exit`, stale imports are cosmetic | `FormalSystem/Boneyard/`, `#exit` everywhere, C11 keeps imports resolvable | **Adopt the location** (Phase 2). **Deliberately diverge** on C11: keep it enforced, because the path-rename phases rewrite archive imports with the same script, which keeps the provenance pointers correct at near-zero cost |
| g | Clean upstream surface (fork is **not** a model: it tracks `specs/`, `.claude/`, `.memory/`) | `specs/`, `CLAUDE.md`, `.claude-extensions.json`, personal paths, internal naming, frozen LaTeX PDF, research/training notes, one-off scripts | **Adopt upstream's surface** (Phase 1) |

#### Target layout

```
BimodalLogic/
├── lakefile.toml
├── lean-toolchain, lake-manifest.json, LICENSE, CITATION.cff
├── README.md, CONTRIBUTING.md, ORGANISATION.md, NOTATION.md, references.bib
├── FormalSystem.lean                  # single generated aggregator (mk_all --check); absorbs FormalSystem/FormalSystem.lean
├── FormalSystem/
│   ├── Init.lean                      # imports Mathlib.Init, Mathlib.Tactic.Common, FormalSystem.Tactic.Attr
│   ├── Tactic/
│   │   └── Attr.lean                  # register_simp_attr truth_norm, reflect_time_norm, formula_unfold, formula_fold;
│   │                                  # register_label_attr tmLemma  (from Automation/{TruthNormAttr,NormalizationAttr,LemmaDB})
│   ├── ForMathlib/                    # unchanged (imports nothing from FormalSystem)
│   ├── Syntax/                        # TM syntax only (Plus/Minus/Star moved out)
│   ├── ProofSystem/
│   ├── Semantics/                     # + Periodicity.lean (from Metalogic/Decidability/FMP/, namespace already Semantics)
│   ├── PlusLanguage/                  # Syntax/PlusLanguage/* + Semantics/PlusLanguage/*  (namespace FormalSystem.PlusLanguage, unchanged)
│   ├── MinusLanguage/                 # Syntax/MinusLanguage/* + Semantics/MinusLanguage/*
│   ├── StarLanguage/                  # Syntax/StarLanguage/* + Semantics/StarLanguage/*
│   ├── Theorems/                      # + DeductionTheorem.lean (from Metalogic/Core/)
│   ├── Metalogic/
│   │   ├── Core/ Bundle/ Algebraic/ BXCanonical/ SoundnessLemmas/ Conservativity/
│   │   ├── Decidability/              # + Propositional/Tactic.lean (PropDecide, beside Kalmar); − TraceExport
│   │   ├── Independence/ Deterministic/
│   │   ├── Expressiveness/            # NEW: 141 files / 104k lines moved from WeakCanonical/
│   │   │   ├── Kamp/                  #   Kamp's theorem (files renamed to content names)
│   │   │   ├── EFGames/
│   │   │   ├── GameTransfer/          #   ex WeakCanonical/Expressiveness/ (GHR93 split-point chain)
│   │   │   ├── Separation/
│   │   │   └── MonadicFO, NormalForm, StaviConnectives, Prior*, Table, EFGameTactics
│   │   └── WeakCanonical/             # residual 38 files / 28k: reflexive weak canonical model + Z/R/Q×Z model constructions
│   ├── Automation/                    # library tactics only: Tactics/{Meta,Commands,Deduction,Search,UserTactics},
│   │                                  # ProofSearch/, Normalization, SuccessPatterns (see Risks)
│   ├── Examples/                      # imports specific Automation modules, never the tooling
│   └── MainResults.lean
├── BimodalTools/                      # NEW lean_lib, not in defaultTargets: dataset/ML/benchmark tooling
│   ├── DataExport, DatasetGenerator, DatasetAssembly, FormulaEnumerator, InterestingnessMetrics,
│   │   ProofStepExtractor, EnrichedCountermodel, ForwardProofGenerator, AtomCanonicalization,
│   │   PrefilterSoundness, AxiomNames, ProofFirstBenchmark, TraceExport
│   └── *Main.lean                     # the 12 exe roots (C25N naming preserved)
├── Boneyard/                          # MOVED from FormalSystem/Boneyard (169 files); module names Boneyard.*
├── Tests/
│   ├── BimodalTest.lean, BimodalTest/ # mirrored; loose Decidability probes moved under Metalogic/Decidability/
│   └── BimodalToolsTest.lean, BimodalToolsTest/   # tests of BimodalTools (Trace*, DatasetGenerator, ProofFirst, ...)
├── scripts/                           # invariant harness + README.md; one-off migrations removed
├── docs/                              # user-guide, reference, architecture, development (research/training removed or relocated)
└── typst/                             # maintained reference manual (uses root references.bib)
```

Removed from the tracked deliverable: `latex/` (frozen edition, including the tracked PDF), `docs/research/`, `docs/training/` (moves with the dataset project or into `BimodalTools/README.md`), `docs/papers/possible_worlds.pdf` (link to the published paper instead), `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect`, `specs/` (git-untracked or kept on a separate branch; see Decisions), and the one-off scripts.

#### lakefile targets (target shape)

```toml
name = "BimodalLogic"
defaultTargets = ["FormalSystem"]
testDriver = "BimodalTest"
lintDriver = "batteries/runLinter"

[leanOptions]
weak.linter.mathlibStandardSet = true
weak.linter.style.longFile = 1500

[[require]]  # mathlib, unchanged

[[lean_lib]]
name = "FormalSystem"
leanOptions = {pp.unicode.fun = true, autoImplicit = false}

[[lean_lib]]
name = "BimodalTest"
srcDir = "Tests"
leanOptions = {pp.unicode.fun = true, autoImplicit = false, weak.linter.hashCommand = false}

[[lean_lib]]            # NEW: tooling, never built by `lake build`, never imported by FormalSystem
name = "BimodalTools"
leanOptions = {pp.unicode.fun = true, autoImplicit = false}

[[lean_lib]]            # NEW: tooling tests (built by CI step, not by testDriver)
name = "BimodalToolsTest"
srcDir = "Tests"
leanOptions = {pp.unicode.fun = true, autoImplicit = false, weak.linter.hashCommand = false}

[[lean_exe]]  name = "dataset_generator"  root = "BimodalTools.DatasetGeneratorMain"  supportInterpreter = true
# ... the other 11 tooling exes, roots under BimodalTools.*
[[lean_exe]]  name = "checkInitImports"   srcDir = "scripts"  root = "CheckInitImportsMain"  supportInterpreter = true
```

Whether `machine_appendix` (it generates `typst/generated/machine-appendix.*`) belongs with the tooling or next to `checkInitImports` is a Phase 3 call. It reads only library declarations, so either works. Put it in `BimodalTools` for uniformity.

#### Namespace map (only rows that change)

| Current file location | Current namespace | Target location | Target namespace | FQN churn |
|---|---|---|---|---|
| `Syntax/{Plus,Minus,Star}Language/*`, `Semantics/{Plus,Minus,Star}Language/*` | `FormalSystem.{Plus,Minus,Star}Language` | `{Plus,Minus,Star}Language/*` | unchanged | **none** |
| `Metalogic/Decidability/FMP/Periodicity.lean` | `FormalSystem.Semantics` | `Semantics/Periodicity.lean` | unchanged | none |
| `Metalogic/Conservativity/MinusLanguageSoundness.lean` | `FormalSystem.Semantics` | `MinusLanguage/Soundness.lean` | `FormalSystem.MinusLanguage` | yes (small) |
| `Automation/{TruthNormAttr,LemmaDB,NormalizationAttr}` | (attribute names only) | `Tactic/Attr.lean` | attribute names unchanged | none (attributes are global names) |
| `Automation/Tactics/PropDecide.lean` | `FormalSystem.Metalogic.Decidability.Propositional.PropForm` (already!) | `Metalogic/Decidability/Propositional/Tactic.lean` | unchanged | none |
| `Metalogic/Core/DeductionTheorem.lean` | `FormalSystem.Metalogic.Core` | `Theorems/DeductionTheorem.lean` | keep or `FormalSystem.Theorems` | decide in Phase 4: **keep the namespace** for zero churn, recorded as an ancestor-style exception |
| `Metalogic/WeakCanonical/{Kamp,EFGames,Separation,...}` | `FormalSystem.Metalogic.WeakCanonical.*` | `Metalogic/Expressiveness/...` | `FormalSystem.Metalogic.Expressiveness.*` | **yes: citeable, includes two MainResults entries** |
| `Metalogic/WeakCanonical/Expressiveness/*` | `...WeakCanonical.Expressiveness` | `Metalogic/Expressiveness/GameTransfer/*` | `...Expressiveness.GameTransfer` | yes |
| `Automation/<tooling>`, `Metalogic/Decidability/TraceExport` | `FormalSystem.Automation.*`, `...Decidability` | `BimodalTools/*` | `BimodalTools.*` | yes (tooling only, not library API) |
| `FormalSystem/Boneyard/*` | `FormalSystem.Boneyard.*` module names | `Boneyard/*` | `Boneyard.*` module names | module names only (never built) |
| `BXCanonical/Chronicle/ChronicleRealExtension.lean`, `WeakCanonical/{DenseModelSurgery/ChronicleInstance,RealModel/ChronicleRealFlow}.lean` | foreign namespaces (`Metalogic.Bundle`, `...BXCanonical.Chronicle`) | unchanged location | leave as is and record, or move the declarations | decide per file in Phase 5 |

#### Header, license and citation templates

Library file (unchanged from current practice; this is the Mathlib/cslib header):

```lean
/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/
import FormalSystem.Semantics.Truth

/-!
# Kamp's Theorem: expressive completeness of Since/Until over Dedekind-complete orders

One-paragraph summary of what the file proves and where it sits in the development.

## Main definitions

* `FormalSystem.Metalogic.Expressiveness.Kamp.ExistsForallFormula`: ...

## Main results

* `FormalSystem.Metalogic.Expressiveness.Kamp.kamp_theorem`: ...

## Implementation notes

(Optional. Design choices a reader of the proof needs; never task history or tool notes.)

## References

* [A. Rabinovich, *A Proof of Kamp's Theorem*][rabinovich2014], Lemma 5.3
* [B. Brast-McKie, *The Construction of Possible Worlds*][brastmckie2026construction], Definition "frame"
-/
```

Rules the templates encode:
- References use the `* [Author(s), *Title*][bibkey]` link form, with keys resolving in the root `references.bib`. Theorem/lemma locators go after the link. Page-only citations are fine ("p. 8"), but **never** notes about local transcription files, tooling, or task history.
- Paper anchors for the JPL paper (`def:frame`, etc., checked by C15) go in `## References` as `[..][brastmckie2026construction], \`def:frame\``. This replaces the `## Paper Specification Reference` heading.
- Test files keep the same header (cslib turns the header linter off for tests; this repo's tests already comply, so no opt-out is needed).

CITATION.cff: keep. Updates needed at publication:
- Set `version` and `date-released` to the actual tagged release. The v1.0.0 tag does not exist yet.
- Add `doi` once a Zenodo release is minted.
- Keep `repository-code`.
- Replace any "ProofChecker" wording. The current file is clean except for the author's email domain, which is the author's own affiliation and is left to the author.

README: lead with what the library proves, a `MainResults` pointer, install and build instructions, and "How to cite". Move the "Logos/ProofChecker/ModelChecker" architecture paragraph (README lines 9, 366, 374-375) to a short "Related projects" footnote, or drop it.

#### Phased refactor programme (dependency-ordered; every phase ends with `lake build`, `lake build BimodalTest` and `bash scripts/check-module-invariants.sh` green)

Legend: **[CITE]** = changes a path, module name or fully-qualified name that external readers would cite. These phases must land before publication and the v1.0.0 tag.

**Phase 0: Tooling for mechanical moves (prerequisite, no tree change).**
- Write `scripts/move-modules.py`. It takes a `old.module -> new.module` mapping plus an optional namespace mapping, and in one pass rewrites:
  - `import` lines in `FormalSystem/`, `Tests/` **and `Boneyard/`** (keeping C11 green);
  - dotted and slash paths in `docs/`, `typst/`, `scripts/*.txt` manifests and allowlists, `README`s and `ORGANISATION.md` (C4/C5/C12/C13/INV);
  - `namespace`/`open`/FQN occurrences when a namespace mapping is given;
  - the C2/C14 axiom baselines and `MainResults.lean`.
- The script ends by running `check-module-invariants.sh --no-build`. The ADR-006 "partial-move risk" is answered here, by one audited tool rather than hand edits.
- Deliverable: script, a dry-run mode, and a self-test on a two-file toy move.

**Phase 1: Deliverable hygiene (g) (no Lean change).**
- Untrack `CLAUDE.md`, `.claude-extensions.json`, `.syncprotect` and the empty `.gitattributes` (add them to `.gitignore`).
- Remove personal absolute paths from `docs/` and `typst/`. The 14 `.lean` occurrences are docstring edits, so they wait for Phase 7, because this task may not edit FormalSystem/. List them in the plan.
- Remove the one-off scripts (`migrate_schema_v2.py`, `swap_untl_snce.py`, `standardize_metadata.py`, `add-copyright-headers.sh`, keeping the `check-` twin). Add `scripts/README.md`.
- Move `docs/development/CONTRIBUTING.md` to the root. Move `docs/research/` out of the deliverable. Retire `latex/` (frozen) and its tracked PDF, together with the C10/C12 references to it.
- Handle `specs/` as recorded in Decisions.
- Rewrite the internal "Logos/ProofChecker" naming in README, docs and CITATION. The `.lean` and test occurrences also wait for Phase 7.
- Not [CITE] for Lean names, but it changes repository paths (`latex/`), so do it before publication.

**Phase 2: Boneyard to repository root. [CITE] (module names `FormalSystem.Boneyard.*` -> `Boneyard.*`)**
- `git mv FormalSystem/Boneyard Boneyard`. Rewrite the 575 archived imports and all references (48 live `.lean` docstrings, 43 markdown files, 12 scripts, 7 typst files) with the Phase 0 tool.
- Update B0's pattern and C11's scan root. Add the cslib-style invariants to B0: no `Boneyard` in `lakefile.toml` or `FormalSystem.lean`, and no `import Boneyard.*` from live code.
- Write **ADR-010** (supersedes ADR-009's location clause; see Decisions).
- Order: this must precede Phase 8's `mk_all --check`.

**Phase 3: Split tooling into `BimodalTools`. [CITE] (tooling module names; exe names unchanged)**
- Create `lean_lib BimodalTools` and `BimodalToolsTest`. Move the ~16k lines listed above plus `Metalogic/Decidability/TraceExport.lean`. Re-root the 12 exes.
- Move the tooling tests (`Trace*Test`, `DatasetGeneratorTest`, `ProofFirstTests`, `FormulaMutatorTest`, `InterestingnessTest`, `C5SmokeTest`, and the rest, to be confirmed by import scan) into `BimodalToolsTest`.
- `Examples/BimodalProofs.lean` imports specific Automation modules instead of the aggregator.
- Update C25/C25N (roots read from lakefile, so they follow automatically), CI's exe-root step, `typst-module-map.sh`, and the `automation-module-map.typ` generator.
- Acceptance: `lake build` (FormalSystem only) produces zero `.olean` under `BimodalTools/`, and a new check asserts `FormalSystem` never imports `BimodalTools`.

**Phase 4: Remove upward edges (a) by relocation. [CITE] only for the DeductionTheorem path; FQNs preserved**
- Create `FormalSystem/Tactic/Attr.lean` (merge the three `register_*_attr` files) and import it from `Init.lean`. Delete the 12 upward edges.
- Move `PropDecide` (plus `Tactics/Meta` if needed, or `Meta` to `Tactic/Meta.lean`) to `Metalogic/Decidability/Propositional/Tactic.lean`. Algebraic -> Decidability then becomes a same-layer edge.
- Move `Metalogic/Core/DeductionTheorem.lean` to `Theorems/DeductionTheorem.lean`, keeping the namespace. This removes the Theorems -> Metalogic edges.
- Move `FMP/Periodicity.lean` to `Semantics/Periodicity.lean`.
- Decidability -> `ProofSearch`/`Normalization`: re-document these as a legitimate "Metalogic.Decidability depends on library automation" edge, placing `Automation` library tactics **below** Decidability in the corrected layer table. Also cut `ProofSearch.Core -> SuccessPatterns` (see Risks).
- Rewrite ORGANISATION.md's layer table to the measured order and add a check that recomputes it (extend `check-metalogic-cycles.sh` into a layer-order assertion).

**Phase 5: Language-extension directories and namespace/path agreement. [CITE] (paths only; FQNs unchanged for 18 files)**
- Merge `Syntax/XLanguage/` and `Semantics/XLanguage/` into `FormalSystem/XLanguage/` for Plus, Minus and Star. Their namespaces already match.
- `MinusLanguage/AxiomDischarge.lean`'s imports of Theorems/Metalogic become ordinary downward edges from an extension language to the base logic.
- Move `Conservativity/MinusLanguageSoundness.lean` to `MinusLanguage/Soundness.lean`.
- Settle the three foreign-namespace Chronicle files.
- Move the 10 loose Decidability probe tests into `Tests/BimodalTest/Metalogic/Decidability/`.

**Phase 6: Extract `Metalogic/Expressiveness/`, rename paper-numbered files, delete stubs. [CITE] (largest name change; includes two MainResults entries)**
- Move the measured 141-file set with the Phase 0 tool, as path plus namespace mapping `FormalSystem.Metalogic.WeakCanonical.X -> FormalSystem.Metalogic.Expressiveness.X` for X in the set.
- In the same phase, give the 39 paper-numbered or history-suffixed files content names (`Lemma53Faithful` -> what it proves), and delete declaration-free compatibility stubs (`Expressiveness/Theorem6.lean`), first confirming zero declarations.
- Before moving, re-run the closure script and require the set to still be BX-free; the partition is a measurement, not an assumption.
- `check-metalogic-cycles.sh` must still report exactly 1 cycle (`BXCanonical <-> WeakCanonical`).
- Write **ADR-011** superseding ADR-006.
- This phase is large (~104k lines moved, 342 files referencing `WeakCanonical`). Split it into 6a (move + namespace, a single scripted commit) and 6b (file renames), each green.

**Phase 7: Docstring and citation normalisation (4, 5, g-in-Lean).**
- Convert `## References` entries to the `* [..][key]` form. Merge `typst/bibliography.bib` into the root `references.bib` and point typst at it.
- Fold the 12 `## Paper Specification Reference` sections into `## References`, and remove `## Implementation Status`.
- Strip internal-tooling notes ("markdown transcription is corrupt"), the personal paths in 14 `.lean` files, and "Logos/ProofChecker" in `Examples/`, `Semantics/{TaskFrame,Truth}.lean` and tests.
- C15 (paper anchors), C14 and C19 must stay green.
- Not [CITE] (docstrings only), but it is visible to readers of the published docs, so land it before publication.

**Phase 8: CI and contribution parity (7).**
- Collapse the root to one `FormalSystem.lean` generated by `lake exe mk_all`. Wire or archive the 26 C6-manifest modules: each is either imported (and so built) or moved to `Boneyard/`. The target is an empty manifest.
- Add CI steps for `lake exe mk_all --check` (as C31 in the harness) and `lint-style-action`.
- Add a tag-triggered release workflow.
- Adopt ORGANISATION.md's module-size policy text.
- Consider retiring `check-copyright-headers.sh` if `linter.style.header` already enforces the same thing under `--wfail`. Verify first: a deliberately broken header should fail the build.

**Phase 9 (optional, post-publication acceptable): size splits and module system.**
- Split `GapDetection.lean` (5,092) and `SplitPoint.lean` (4,906) only along import-acyclic declaration families, per cslib's rule.
- Evaluate adopting the Lean module system (`module`/`public import`) as its own programme.
- Neither changes a citeable name, provided splits keep the declaration namespaces.

Dependency order: 0 -> 1 -> 2 -> {3, 4} -> 5 -> 6 -> 7 -> 8 -> 9. Phase 3 and Phase 4 are independent after Phase 2. Phase 4 should precede Phase 6 so that the Expressiveness move does not also carry attribute-edge churn. Phase 8's `mk_all --check` requires Phase 2.

**Publication gate**: Phases 1-7 complete, and Phase 8's root collapse done. Only then create the v1.0.0 tag and update CITATION.cff. Tagging is user-only, via `/tag`.

## Decisions

- **ADR-006: supersede (new ADR-011).** The measured partition shows the regroup ADR-006 declined is legal for 104k of the 132k lines, without touching the one directory cycle. ADR-011 should record: the closure measurement and how to re-run it; that the residual `BXCanonical <-> WeakCanonical` cycle is accepted (cslib and Mathlib both tolerate directory-level cycles because only the module graph must be acyclic, which is ADR-006's own observation); and that the residual keeps the name `WeakCanonical`, which now describes it (reflexive weak canonical model plus the model constructions that feed completeness). ADR-006's "regroup the three completeness routes under `Completeness/`" question stays declined. ADR-011 extracts expressiveness, which was never a completeness route.
- **ADR-009: reaffirm retention, supersede location and one rationale (new ADR-010).** Keep the archive (the 45+ live docstring references and the provenance argument stand). But: (i) move it to the repository root, citing cslib's "root-level placement is load-bearing" argument (a prerequisite for `mk_all --check`, and it keeps `FormalSystem.Boneyard.*` out of the library's module namespace and API docs); (ii) drop the "published prose depends on it" bullet, which cites `latex/subfiles/04-Metalogic.tex`, the frozen edition that Phase 1 retires. The maintained typst manual cites the archive in 7 files; that is the live justification. Keep C11 enforced (a divergence from cslib's "stale imports are cosmetic"), because Phase 0's tool keeps the archive's imports current as a side effect.
- **Library root name `FormalSystem`: keep.** It was chosen deliberately in a recent rename, and it follows the path. Renaming again would change every FQN for no structural gain.
- **Test layout: keep mirroring** (diverge from cslib's flat `CslibTests/`); only relocate the loose files.
- **Module system: defer.** It changes no citeable name, so it is kept out of the pre-publication critical path.
- **`specs/` in the published repo**: recommend untracking it on `main` before publication. It is task-management provenance (192 tracked files), and neither upstream cslib nor Mathlib ships anything like it. The fork's tracking of 3,528 specs files is itself a fork-local divergence, not an upstream practice. Deleting history is not required; untracking plus `.gitignore` is enough. This affects the agent workflow's own conventions (tracked `.return-meta.json` and handoffs), so the plan phase must confirm the agent system still works with `specs/` ignored, for example by keeping it on a separate branch or a non-published remote. This is recorded as the agent's recommendation; the plan should put it into Phase 1 only after that confirmation.

## Risks & Mitigations

- **Large-move breakage (Phase 6, ~104k lines).** *Mitigation*: the Phase 0 tool; one scripted commit per sub-phase; re-measure the closure partition right before moving; `check-module-invariants.sh` in full (not `--no-build`) as the gate.
- **FQN changes invalidate external links and the typst manual.** *Mitigation*: land all [CITE] phases before the first tag; regenerate `typst/generated/*` and `docs/theorem-index.md` in the same phase; C2/C14/C21 baselines are rewritten by the tool, not by hand.
- **`ProofSearch.Core -> SuccessPatterns`.** The trusted decision procedure imports the ML pattern store. *Mitigation*: in Phase 3/4, check whether `SuccessPatterns` is only a data structure used for heuristics. If so, keep a minimal, heuristic-free interface in the library and move the learning or serialisation parts to `BimodalTools`. If it cannot be cut cleanly, keep `SuccessPatterns` in the library and document it. This is a code-reading question for the plan and implementation phases; it does not block the plan.
- **Tests depend on tooling.** Some `BimodalTest` files import tooling modules. *Mitigation*: the `BimodalToolsTest` lib, built by an explicit CI step (`lake build BimodalToolsTest`), since `testDriver` names only `BimodalTest`.
- **Moving `DeductionTheorem` while keeping the namespace creates one more ancestor-style mismatch.** *Mitigation*: record it; alternatively rename the namespace in Phase 6's FQN pass if the user prefers exact agreement.
- **`mk_all` demands every file be imported.** The 26 unreachable modules must be dispositioned first. *Mitigation*: Phase 8 carries that work explicitly. Moving any of them to `Boneyard/` needs the `#exit` header convention.
- **C9 and the no-task-references rule.** New ADRs and READMEs must cite durable anchors (commit SHAs, file paths), never task numbers.
- **Zero-debt policy.** No phase introduces `sorry` or axioms. The C3 (zero structural sorry) and C2/C14 (axiom baselines) gates must stay green, so a pure move that changed an axiom set would fail immediately.

## Tactic Survey Results

- Not applicable (no tactic survey performed): this task is repository engineering, with no proof goals in scope.

## Context Extension Recommendations

- **Topic**: Lean library publication-readiness checklist (upstream-cslib/Mathlib surface)
- **Gap**: The lean4 context has no guidance separating a formalization's publishable surface from agent-system and task-management content, and it does not warn that `benbrastmckie/cslib` (a fork) tracks `specs/`/`.claude/`, so it should not be cited as a model for repository hygiene.
- **Recommendation**: add `context/project/lean4/standards/publication-surface.md` (in the source store `agent-system/extensions/lean/...`, not `.claude/`) covering: required root files, header/docstring/citation templates as above, `mk_all --check`, the root-level Boneyard, and "tooling in a separate `lean_lib`".

## Appendix

**Reproduction of the key measurements** (scripts kept in the session scratchpad; each is a short Python walk):
- *Header-import parse*: take only the file's leading `import` block, skipping the copyright comment. A naive `grep '^import'` also matches docstring usage examples (`import FormalSystem` inside `/-! ... -/`) and produces a false self-cycle.
- *WeakCanonical partition*: for each `FormalSystem.Metalogic.WeakCanonical.*` module, compute its transitive `FormalSystem.*` import closure. "Pure" means no `FormalSystem.Metalogic.BXCanonical*` in the closure. Result: 150 pure / 29 impure. The chosen Expressiveness subset has 141 files with zero edges into the other 38.
- *Automation partition*: the union of the closures of all non-Automation library modules (excluding `Examples/`, `MainResults`, `TraceExport`), intersected with `FormalSystem.Automation.*`.
- *Namespace audit*: compare each file's first `namespace` with its directory module path (equal/descendant, ancestor, or unrelated).

**cslib files read**: `lakefile.toml`, `README.md`, `AUTHORS.md`, `GOVERNANCE.md`, `ORGANISATION.md`, `CONTRIBUTING.md`, `Boneyard/README.md`, `scripts/README.md`, `scripts/check-boneyard-quarantine.sh`, `Cslib/Init.lean`, `Cslib.lean` (head), `CslibTests.lean`, `.github/workflows/{lean_action_ci,lint-hygiene,weekly-lints,release}.yml`, `docs/lint-suppression-policy.md`, `Cslib/Logics/Bimodal/Metalogic/Algebraic/BooleanStructure.lean` (the port imports no tactic module and proves the Boolean-algebra facts by explicit derivations, a precedent for Phase 4's PropDecide relocation).

**This repo's files read**: `lakefile.toml`, `ORGANISATION.md`, `CITATION.cff`, `.gitignore`, `FormalSystem.lean`, `FormalSystem/{FormalSystem,Init,MainResults}.lean`, `docs/architecture/ADR-006-*.md`, `ADR-009-*.md`, `docs/development/MODULE_INVARIANTS.md`, `scripts/check-module-invariants.sh` (check index), `scripts/module-invariants-manifest.txt`, `.github/workflows/{ci,docs}.yml`, `latex/README.md`, `Metalogic/WeakCanonical/README.md`, the Automation attribute files, and import headers across the tree.
