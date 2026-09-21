# Changelog

All notable changes to BimodalLogic are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres
to [Semantic Versioning](https://semver.org/). The versioning policy and the release process are
in [docs/development/VERSIONING.md](docs/development/VERSIONING.md).

The version is recorded in three places that must agree at every release tag: the tag itself,
the `version:` field of `CITATION.cff`, and `FormalSystem.version` in `FormalSystem/Version.lean`.
The release workflow reads the section below that matches the tag and publishes it as the
release notes, so a release needs a `## [X.Y.Z]` section here before it is tagged.

## [Unreleased]

## [1.0.0] - 2026-09-07

The first public release: a Lean 4 formalization of TM, the bimodal logic of Tense and Modality,
which combines S5 modal operators with the Since/Until linear tense operators over task
semantics. Built against Lean `v4.33.0-rc1` and Mathlib at the matching tag.

### Added

- The object language, the Hilbert proof system with its axiom schemata at the base, dense and
  discrete frame classes, and task-frame semantics with world histories, truth and validity.
- Metatheory: machine-checked soundness, weak completeness and finite-context consequence
  completeness at all four frame classes; strong completeness and compactness at two of them;
  machine-checked refutations of strong completeness at the other two; and a one-directional
  tableau decision procedure. `FormalSystem/MainResults.lean` lists the headline results on one
  page, each followed by the kernel's own `#print axioms` audit, asserted on every build;
  `docs/theorem-index.md` is the per-theorem ledger.
- The extension languages L⁻, L⁺ and L⋆, each a self-contained directory carrying its syntax,
  proof system and semantics.
- Derived theorems (combinators, propositional, S4/S5, perpetuity, temporal), the `modal_search`
  proof-search tactic, and pedagogical examples.
- `FormalSystem/ForMathlib/`: the proper, maximal and prime-filter API for `Order.PFilter`, staged
  for upstreaming and importing nothing from the rest of the library.
- The tooling library `BimodalTools` (dataset generation, JSON export, benchmarks and the
  executable roots), outside `defaultTargets` and never imported by the library.
- A generated library root: `FormalSystem.lean` is the output of
  `lake exe mk_all --lib FormalSystem` and imports every module, so no library module is outside
  the build. `FormalSystem.version` lives in `FormalSystem/Version.lean`.
- Continuous integration: build, test and lint with compiler warnings as errors for the library
  and the tooling; the repository invariant suite `scripts/check-module-invariants.sh`; the
  generated-root check; and a tag-triggered release workflow.
