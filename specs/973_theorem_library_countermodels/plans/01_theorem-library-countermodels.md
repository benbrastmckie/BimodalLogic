# Implementation Plan: Task #973

- **Task**: 973 - Theorem library: countermodels
- **Status**: [IMPLEMENTING]
- **Effort**: 14 hours
- **Dependencies**: `theorem_library_layout_and_registry` (landed); `theorem_library_tableau_pipeline` (landed, sequencing-only)
- **Research Inputs**: specs/973_theorem_library_countermodels/reports/01_theorem-library-countermodels.md
- **Artifacts**: plans/01_theorem-library-countermodels.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

M20 asks the results library to keep every refuted inference beside a checked refutation. This
plan lands the countermodel half of `BimodalLib`: one `PointTruth`-generic entry type whose
`refutation` field is what the kernel checks and whose `profile_eq` field makes the filing
fragment computed rather than asserted; the two TRANSFER theorems that let a single maximal-class
entry stand for every weaker reading; one landed entry at each of the three admitted grades
(SEMANTIC, CERTIFICATE, GATED TABLEAU); registration of the hand-built refutations already in the
tree; lookup of an inference up to renaming of atoms; and the index and reference-page coverage
that makes the half visible. Done when the three grades each carry at least one kernel-checked
entry, the hand-built refutations are registered, lookup is tested, and
`docs/reference/bimodal-lib.md` documents the grades — with `BimodalLib` free of `sorry`, of any
new `axiom`, and of `native_decide` throughout, and `FormalSystem` never importing `BimodalLib`.

### Research Integration

The research report is integrated in full and is this plan's primary input. Its ten
recommendations map onto the phases below: R1 (generic entry type over `PointTruth` plus a small
`HasProfile` class) is Phase 1; R5 (both TRANSFER theorems as one-liners) is Phase 2; R2 (the two
SEMANTIC first entries) and the hand-built corpus are Phase 3; R3 (the ZTime witness-family
certificate) is Phase 4; R4 (repackage the gate theorem on explicit branch data rather than
re-running `buildTableau` in the kernel) is Phase 5; R6 (`sameUpToRenaming` from mutual
`isSubstInstance`, plus a `PlusFormula` companion matcher) is Phase 6; R9 (`nearMiss` names a
declaration, with the asymmetry recorded) is Phases 3 and 7; R10 (a Countermodels section and a
per-grade census in the index) is Phase 7; and the closing documentation obligation is Phase 9.

R7 and R8 are the two recommendations that reshape scope rather than add work. R7 admits entries
at their maximal frame classes only and derives the weaker readings through the Phase 2 transfer
theorem, which is what keeps part (4) load-bearing instead of decorative. R8 is a measured FAIL
against the acceptance gate: the pipeline's data file carries `true_atoms`/`false_atoms` and not
the open branch or its `TimeOrdering`, so no kernel-checked gated entry can be generated from it
today; and at the measured ~70 generated lines per entry the 1,047 distinct statements come to
roughly 73,000 lines against a package-wide 1,500-line linter that CI enforces with `--wfail`.
Bulk admission is therefore a Non-Goal here, left in `records/theorem-library.md` as the part
that remains unimplemented. The report's single entry per grade is what the DONE WHEN clause
actually asks for.

### Premise Re-Validation (Carried-Figure Discipline)

Every figure and hard claim the dispatch description carries was checked against the report and
against live state. Results, stated even where they only confirm the description:

| Carried claim | Live check | Result |
|---|---|---|
| `FormalSystem/PlusLanguage/PlusNonValidities.lean` exists | `wc -l` | CONFIRMED, 205 lines |
| `FormalSystem/StarLanguage/StarNonValidities.lean` exists | `wc -l` | CONFIRMED, 197 lines |
| independence results under `FormalSystem/Metalogic/Independence/` | `find` | CONFIRMED: 30 files in the directory plus the `Independence.lean` root (the report's "31 files" counts the root; no discrepancy of substance) |
| `plusValidIn_ofFormula_iff` is a named theorem | `grep` | CONFIRMED in `FormalSystem/PlusLanguage/PlusValidity.lean`; it is the `Γ = []` case, so the premise-bearing transfer goes through `plusTruthAt_ofFormula` instead (report R5) |
| three grades are ready; EVALUATOR-CHECKED is not | `ls records/semantic-proof-mode.md` | CONFIRMED NOT PRESENT on `main`; the fourth grade stays out of scope exactly as the description warns |
| `theorem_library_tableau_pipeline` supplies tableau-fed entries | `wc -l data/theorem-library-countermodels.jsonl` | CONFIRMED, 2,981 rows — but the rows carry no branch, so they cannot feed a kernel-checked entry (report R8) |
| `theorem_library_layout_and_registry` is a hard dependency and has landed | `find BimodalLib -name '*.lean'` | CONFIRMED: `Registry.lean`, `Fragment.lean`, `Index.lean`, `Subsumption.lean`, `Conjecture.lean` all in tree |
| "an ungated `invalid` verdict stays a conjecture and is never admitted" | `BimodalLib/Conjecture.lean` | CONFIRMED as already-built machinery: `ConjectureStatus.heuristicallyRefuted` exists for exactly this, and `ConjectureStatus.refuted`'s own docstring already says it links to "the countermodel entry that answers it" |
| each named first-entry declaration exists | `grep` for the declaration | CONFIRMED: `not_validIn_dense_prior_UZ`, `refute_stab_box`, `not_consequence_ztime`, `botUntlFamily_certifies`, `not_valid_of_hasOpen_int` all resolve |
| `BimodalLib` imports `FormalSystem` and never the converse | `scripts/check-module-invariants.sh` B3 | CONFIRMED as a live gate, not a convention |

Two live measurements this plan adds beyond the report, because they change what a phase owes:

- **`typst/generated/status.typ` does not count `BimodalLib/`.** `scripts/typst-status-counts.sh`
  counts `.lean` files and lines under `FormalSystem/`, `Tests/` and `BimodalTools/` only. A
  `BimodalLib/`-only phase therefore moves no count on that surface. A phase touching
  `Tests/**/*.lean` does move `tests_file_count`/`tests_line_count`, and
  `.githooks/pre-commit` refuses that commit until `status.typ` is regenerated. Baseline checked
  clean: `bash scripts/typst-sync-check.sh --counts-only` reports `MISMATCH_COUNT=0`.
- **The narrowing selector's output for this plan's phases is MIXED, and only because the
  harvester auto-appends a surface none of the named files is.** Measured in two steps. The named
  paths alone — `BimodalLib/Countermodel.lean`,
  `Tests/BimodalLibTest/CountermodelTest.lean`, `docs/reference/bimodal-lib.md`, and
  `BimodalLib.lean` — map to no shell suite at all. But
  `scripts/plan-file-scope-harvest.sh` appends `typst/generated/status.typ` unconditionally to
  any phase carrying a `.lean` edit (this repository declares it as a coupled generated surface),
  and that path DOES map, to `test-plan-file-scope-harvest.sh` and `test-validate-artifact.sh`.
  Every non-final phase here carries a `.lean` edit, so every one of them has a mixed selector
  output and the honest Tier Justification names those two real suites rather than the
  no-suite sentinel. Each non-final Tier Justification below is written against that measured
  output, not a guess. One consequence worth stating: the auto-append is conservative, so
  `status.typ` lands in `file_scope` for every phase even though, per the measurement above,
  only Phase 8 actually moves a count on it.

### Prior Plan Reference

No prior plan. This is the first plan for this task.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context and `roadmap_flag` is not
set, so `specs/ROADMAP.md` was not consulted and this plan adds no roadmap-review or
roadmap-regeneration phase. The task's own milestone anchor is M20 of
`records/proof-mode.md`, Library lane, whose DONE WHEN clause this plan's Phase 9 closes against.

## Goals & Non-Goals

**Goals**:
- `GenericConsequenceIn` -- the premise-bearing consequence relation over `PointTruth`, which is
  what a countermodel entry refutes; `SemanticConsequenceIn` exists for `Formula` only and L⁺ has
  no premise-bearing consequence predicate at all.
- `genericConsequenceIn_nil` -- the empty-premise bridge, through which every existing
  `¬ Valid…`-shaped refutation in the tree becomes an entry without restatement.
- `not_genericConsequenceIn_of_le` -- TRANSFER downward in frame class: a model at a stronger
  class refutes at every weaker class it belongs to, with the order checked by the kernel.
- `not_genericConsequenceIn_ofFormula` -- TRANSFER of an L countermodel into L⁺.
- `gatesOK` -- the eight branch gates bundled as one decidable `Bool` over `FormalSystem`
  primitives only, so `BimodalLib` never reaches for `BimodalTools`' gate bundle.
- `not_genericConsequenceIn_of_gatesOK` -- the gate bridge: a gated open branch denying `φ`
  refutes `φ` as a consequence of the empty premise list.

**Non-Goals**:
- Bulk admission of the pipeline's 1,047 distinct gated-tableau statements. The data file carries
  no branch, and the measured line cost does not fit the package's linter under `--wfail`. One
  generated-shape entry stands as the grade's existence witness; the bulk stays in
  `records/theorem-library.md`.
- The EVALUATOR-CHECKED fourth grade. Its client is the evaluator milestone and it waits on
  `records/semantic-proof-mode.md`, which does not exist on `main` (confirmed above).
- Any `StarNonValidities` row. `StarValidOn` carries an extra binder (the stored-time vector), so
  L⋆ validity is not an instance of the L/L⁺ point shape and there is no `profileS`; the
  dispatch's own side condition ("where the inference is statable in L or L⁺") is not met.
- Derivability-level and definability-level independence results (`¬ Derivable`,
  `¬ PlusDerivable`, `¬ NaiveDerivable`, `¬ OfutPlusDefinable`, `¬ Separated`, `∉ Sat`). These are
  claims about a calculus or a frame class, not about an inference failing in a model.
- A completeness check for the countermodel half. An analogue of `assert_registry_complete`
  demanding a row for every `¬ Valid…`-shaped theorem in `FormalSystem` would indict around a
  hundred declarations across five incompatible tiers.
- Any edit under `FormalSystem/`. The new vocabulary lives in `BimodalLib/` (see Decisions),
  which keeps this task off the commit-blocking `formalsystem-line-count` surface and off the
  module-inventory blocks entirely.
- Reciprocal row-to-row near-miss pairing. The theorem side of the five `⊡` refutations has no
  registry row to point at, and cannot have one under `TheoremEntry`'s type (see Decisions).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `decide` on the gate bundle regresses on a larger branch than the 14-element case the research measured | H | M | Phase 5 measures elaboration time and the needed `maxRecDepth` on its own branch before committing the entry, and treats both as sized quantities. `native_decide` is barred and is not a fallback |
| ZTime/Dense-RTime incomparability invites a silent filing error: a ZTime model does NOT refute at Dense or RTime | H | M | Phase 2 states the transfer theorem with an `fc₁ ≤ fc₂` hypothesis rather than a "weaker class" convention, so the kernel checks the order. Phase 3's filing records the maximal class per entry, and an inference may legitimately need two maximal entries |
| A `Tests/**` edit is refused at commit by `.githooks/pre-commit` because `status.typ` drifted | M | H | Phase 8 is the only phase touching `Tests/`, declares `typst/generated/status.typ` in its own file list, and runs `bash scripts/typst-sync-check.sh --fix` in that same phase. Measured: `Tests/` IS counted by `typst-status-counts.sh`, `BimodalLib/` is not |
| `lake exe runLinter BimodalLib` fails on a declaration with no docstring | M | H | Every phase's tasks require a docstring on every new declaration, structure fields included, following `TheoremEntry`'s precedent |
| CI builds `BimodalLib` with `--wfail`, so any linter warning is a failure | M | M | Each phase's verification runs the guarded build with `--wfail` rather than a bare build; `show` is avoided in favour of named `rfl` lemmas; `List.contains_iff` is avoided (deprecated, and the deprecation warning is itself a `--wfail` failure) — `List.contains_iff_mem` is the live form |
| C26 flags a new `def`/`abbrev` whose last name component carries a non-trailing underscore (`theorem` is exempt, which misleads by analogy) | M | M | Every new `def` named in this plan is lowerCamelCase. A verbatim promotion of a research probe's own snake_case `def` names would fail on arrival, so promotion is explicitly non-verbatim: Phase 1 renames as it promotes |
| C5's module-path regex cannot tell a declaration name from a module path, so a docs citation of `FormalSystem.Semantics.PointTruth` reads as an unresolvable module | M | M | Phase 9 cites `PointTruth` by bare name beside its module file path rather than as a dotted string; if an entry proves necessary it goes in `scripts/module-invariants-allowlist.txt`, which already carries entries of exactly this shape, and that file is declared in Phase 9 |
| C20 gates any `file.lean:NNN` citation that is out of range or lands on a blank line, repo-wide | L | M | Phase 9's docs cite declaration names, never line numbers. (`specs/**` is outside C20's scan roots, so this plan's own citations are unaffected) |
| The generic entry type forces per-language branching in the index meta-code, because `evalExpr` is monomorphic | L | H | Accepted and recorded: Phase 7 writes the walk with an explicit branch over `CountermodelEntry Formula` and `CountermodelEntry PlusFormula`, following `renderConjectures`' projection-and-`ppExpr` style rather than `rowStatement?`'s `unsafe evalExpr` |
| `BimodalLib` and `BimodalTools` end up with two gate bundles that disagree | L | M | Phase 8 pins their agreement with a test. The `BimodalLib -> BimodalTools` import is forbidden by `lakefile.toml`, so duplication is the only route and a pinning test is the cheap insurance |
| `BimodalLib/INDEX.md` goes stale and `scripts/library-index.sh --check` fails in CI | M | M | Phase 7 declares `BimodalLib/INDEX.md` and regenerates it with `bash scripts/library-index.sh`; Phase 9 re-runs `--check`. The check is CI-side, not commit-blocking, so the regeneration legitimately sits in the phase that adds the renderer |
| A new `BimodalLib` module is left out of `BimodalLib.lean` and goes unreachable | L | M | Every phase adding a module adds its import to `BimodalLib.lean` in the same phase and names that file in its own file list |

## Decisions

- **One entry type, generic over `PointTruth`, not one per language.** `ValidIn fc φ` and
  `PlusValidIn fc φ` are definitionally equal to `GenericValidIn fc φ` (established by `rfl` in
  the research probes), so genericity costs nothing at the statement side and saves a second
  structure, a second set of filing conventions and a second index section. The price is paid in
  meta-code only, where `evalExpr` is monomorphic. Two concrete row types remain a legitimate
  fallback if the Phase 7 branching proves worse than the duplication; it would change no
  statement in the library.
- **`GenericConsequenceIn` is defined in `BimodalLib/Countermodel.lean`, not in
  `FormalSystem/Semantics/ValidityLayer.lean`.** A generic consequence relation is arguably
  semantics-layer vocabulary, and the honest trade-off is worth stating: siting it in
  `FormalSystem/` would make it available to the whole formalization, but it is consumed only by
  countermodel rows today, and the edit would move `formalsystem-line-count` — a surface
  `.githooks/pre-commit` refuses the commit over — and stale the module-inventory blocks, for no
  gain this task needs. If a later record needs it in the semantics layer, moving it is a
  one-file change, and the entry type's statements are unaffected either way.
- **The `refutation` field is `¬ GenericConsequenceIn`, not a model-exhibiting existential.**
  Every landed refutation in the tree has the `¬ Valid…` shape, and converting one into an
  explicit model needs classical choice, which discards exactly the explicit model the conversion
  was for. A `RefutesIn`-style field does pack the model constructively — `WitnessFamily.Refutes`
  and `PlusWitnessFamily.PlusRefutes` are that shape at ZTime — but adopting it as *the* field
  would require restating every hand-built refutation in model-exhibiting form. The record's "and
  a model" component is instead carried by an optional `model : Option String` naming the model's
  declaration, so the component is recorded without a new proof obligation.
- **Entries are registered as plain constants, not through a new command.** `register_theorem`
  exists because a theorem row must read its statement off a declaration's type and may not
  retype it. A countermodel entry has no such declaration to read from: its statement is the
  inference, which the author writes. The `Conjecture` convention is the right precedent —
  declare a constant of the type in a module under `BimodalLib/Countermodels/`, and let the index
  walk discover it. `profile_eq := rfl` keeps the filing computed rather than asserted, which is
  the invariant the command existed to protect.
- **Admission is at maximal frame classes only.** Registering a Base, a Dense and an RTime row
  for the same statement would make part (4)'s transfer theorem decorative. Entries are filed at
  maximal classes and the weaker readings are derived. Because the frame-class order is a tree
  (`Base < Dense < RTime` and `Base < ZTime`, with ZTime incomparable to both Dense and RTime),
  "the strongest frame class" is not always unique and an inference may carry two maximal entries.
- **`nearMiss` names a declaration, and the asymmetry is recorded rather than engineered away.**
  `TheoremEntry` is `Formula`-only by type, so the three laws the five `⊡` refutations bound — an
  axiom constructor, a semantic validity theorem, and a schema the paper states and the tree does
  not formalize — are not and cannot be registry rows. Reciprocal row-to-row pairing is therefore
  not constructible in this task, and the record that would add L⁺ theorem entries lists M20 as
  its own sequencing dependency, so it cannot be deferred there either. The disposition: a
  `nearMiss : Option Name` field pointing at the bounded declaration, a `note : String` field for
  a bound with no declaration at all, and a build invariant (Phase 7) that every `some nearMiss`
  resolves in the environment. The one-directional asymmetry is documented in Phase 9 rather than
  left for a reader to discover.
- **`CountermodelEntry` is not named under `- **Goals**:`.** The Goals list for a lean4 plan must
  equal the identifier set declared in `## Lean Challenge Statements`, and a `structure` cannot
  carry a `sorry` body. The six identifiers named are the definitions and theorems whose
  signatures a Challenge module can pin; the entry type's shape is pinned by Phase 1's task list
  instead, field by field.
- **The gated tableau grade is realized by repackaging the gate theorem on explicit branch data.**
  The alternative shape — a `gatedRefuted φ fc : Bool` matching on `buildTableau φ (soundFuel φ)
  fc`, discharged by `decide` — asks the kernel to evaluate the whole tableau construction per
  entry. It was not measured and is not assumed feasible. None of the four gate theorems requires
  that the branch came from `buildTableau`: soundness rests on the gates alone, which is what
  makes the explicit-branch form both cheap and the one the research actually verified.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 6 | 1 |
| 3 | 3, 4, 5 | 1, 2 |
| 4 | 7 | 3, 4, 5, 6 |
| 5 | 8 | 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel.

### Phase 1: The entry type and its vocabulary [COMPLETED]

**Goal**: `BimodalLib/Countermodel.lean` lands with the premise-bearing generic consequence
relation, the profile class, the grade enumeration, and the `CountermodelEntry` structure, and
`lake build BimodalLib --wfail` is green.

**Tasks**:
- [ ] Create `BimodalLib/Countermodel.lean` with the standard copyright header and a module
      docstring whose `## Main definitions` section names every declaration below, following
      `BimodalLib/Registry.lean`'s header shape.
- [ ] Define `GenericConsequenceIn {L : Type} [PointTruth L] (fc : FrameClass) (Γ : List L)
      (φ : L) : Prop` as the four-line quantification over frames satisfying `fc`, models,
      histories and durations, with every premise true at the point and the conclusion true
      there. It needs no `imp` on the language.
- [ ] Prove `genericConsequenceIn_nil (fc) (φ) : GenericConsequenceIn fc ([] : List L) φ ↔
      GenericValidIn fc φ`. The research probe closed the empty-premise side with `simp`
      discharging `∀ γ ∈ [], _`.
- [ ] Define `class HasProfile (L : Type) where profile : L → Profile`, with
      `instance : HasProfile Formula := ⟨profileF⟩` and
      `instance : HasProfile PlusFormula := ⟨profileP⟩`.
- [ ] Define `inferenceProfile {L} [HasProfile L] (Γ : List L) (φ : L) : Profile` as the right
      fold of `Profile.join` over the premises with the conclusion's profile as the seed.
- [ ] Define `inductive Grade | semantic | certificate | gatedTableau deriving DecidableEq, Repr`
      and `Grade.name : Grade → String`, mirroring `ConjectureStatus.name`.
- [ ] Define `structure CountermodelEntry (L : Type) [PointTruth L] [HasProfile L]` with fields
      `premises : List L`, `conclusion : L`, `frameClass : FrameClass`, `grade : Grade`,
      `refutation : ¬ GenericConsequenceIn frameClass premises conclusion`, `profile : Profile`,
      `profile_eq : inferenceProfile premises conclusion = profile`,
      `model : Option String := none`, `nearMiss : Option Name := none`, and
      `note : String := ""`. Each field carries its own docstring.
- [ ] Define `CountermodelEntry.fragment` as `e.profile.fragment` and
      `CountermodelEntry.cellName` from `Profile.cellName`, matching `TheoremEntry.fragment`.
- [ ] Promote the research probe's declarations NON-VERBATIM: rename any snake_case `def` or
      `abbrev` the probe used to lowerCamelCase before landing it, because C26 of
      `scripts/check-module-invariants.sh` flags a non-trailing underscore in a `def`/`abbrev`
      name and exempts only `theorem`.
- [ ] Add `import BimodalLib.Countermodel` to `BimodalLib.lean`, in the existing alphabetical
      position.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over this phase's harvested paths — its one new
Lean module and the root, plus the `typst/generated/status.typ` surface the harvester
auto-appends to any `.lean` edit — returns the real suites `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, so the covering checks are `bash .claude/scripts/verify-touched.sh
BimodalLib/Countermodel.lean BimodalLib.lean`, which runs that narrowed pass itself, plus
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail` for
the module this phase adds.

**Files to modify**:
- `BimodalLib/Countermodel.lean` - new: the generic consequence relation and its empty-premise bridge, the profile class and its two instances, the inference-profile fold, the grade enumeration, the entry structure, and the entry fragment projection
- `BimodalLib.lean` - add the new module's import line

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`
  exits 0, with no warning (CI treats a warning as a failure).
- `lake exe runLinter BimodalLib` reports no new docstring finding against
  `scripts/nolints.json`'s existing baseline — a delta, not an absolute zero.
- `bash .claude/scripts/verify-deploy.sh --skip-slow --only-gate 4 /home/benjamin/Projects/BimodalLogic`
  reports no task-reference finding naming either file this phase touched; pre-existing findings
  elsewhere in the tree are enumerated and are not this phase's blocker.

---

### Phase 2: The two TRANSFER theorems [COMPLETED]

**Goal**: both transfer claims of part (4) are named theorems over `GenericConsequenceIn`, with
entry-level companions that rebuild an entry at a weaker class and in L⁺.

**Tasks**:
- [ ] Create `BimodalLib/Countermodel/Transfer.lean` with the standard header and a module
      docstring that states the frame-class order is a TREE, not a chain — `Base ≤ everything`,
      `Dense ≤ {Dense, RTime}`, `RTime ≤ RTime`, `ZTime ≤ ZTime`, with ZTime incomparable to
      Dense and RTime — and that this is why the theorem takes an `fc₁ ≤ fc₂` hypothesis rather
      than relying on a "weaker class" convention.
- [ ] Prove `not_genericConsequenceIn_of_le {L} [PointTruth L] {fc₁ fc₂} (h : fc₁ ≤ fc₂) {Γ} {φ}
      (hr : ¬ GenericConsequenceIn fc₂ Γ φ) : ¬ GenericConsequenceIn fc₁ Γ φ` as an explicit term
      through `FormalSystem.Semantics.FrameClass.Sat.anti`. No tactic is needed.
- [ ] Prove `not_genericConsequenceIn_ofFormula {fc} {Γ : List Formula} {φ : Formula}
      (hr : ¬ GenericConsequenceIn fc Γ φ) : ¬ GenericConsequenceIn fc (Γ.map ofFormula)
      (ofFormula φ)` through `plusTruthAt_ofFormula` and `List.mem_map`. Note in the docstring
      that `plusValidIn_ofFormula_iff`, which the design record names, is the `Γ = []` case and
      does not carry premises.
- [ ] Define `CountermodelEntry.transferLe` : from an entry at `fc₂` and `h : fc₁ ≤ fc₂`, the
      entry at `fc₁`, with `profile` and `profile_eq` carried over unchanged.
- [ ] Define `CountermodelEntry.toPlus` : from a `CountermodelEntry Formula`, the
      `CountermodelEntry PlusFormula` at the same frame class and grade. Its `profile_eq` closes
      through `profileP_ofFormula` (`BimodalLib/Fragment.lean`), which already states
      `profileP (ofFormula φ) = profileF φ`.
- [ ] Add `import BimodalLib.Countermodel.Transfer` to `BimodalLib.lean`.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over this phase's harvested paths — its one new
Lean module and the root, plus the `typst/generated/status.typ` surface the harvester
auto-appends to any `.lean` edit — returns the real suites `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, so the covering checks are `bash .claude/scripts/verify-touched.sh
BimodalLib/Countermodel/Transfer.lean BimodalLib.lean`, which runs that narrowed pass itself, plus
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail` for
the module this phase adds.

**Files to modify**:
- `BimodalLib/Countermodel/Transfer.lean` - new: both transfer theorems and the two entry-level companions
- `BimodalLib.lean` - add the new module's import line

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`
  exits 0 with no warning.
- `#print axioms BimodalLib.not_genericConsequenceIn_of_le` and the `ofFormula` companion each
  report `[propext, Classical.choice, Quot.sound]` and nothing more — the same triple every other
  `BimodalLib` theorem measures. Record the measured output, do not assert it.
- A `lean_verify` (or an equivalent compiled probe) on both theorem names reports no `sorry`.

---

### Phase 3: The SEMANTIC grade -- the hand-built refutations [COMPLETED]

**Goal**: the refutations already in the tree that are statable in L or L⁺ are registered as
entries, filed by fragment and maximal frame class, with the near-miss links the `⊡` refutations
carry.

**Tasks**:
- [ ] Enumerate, by sweep rather than from this plan's estimate, the registrable refutations in
      two tiers: the class-tag `¬ ValidIn <class> φ` declarations under
      `FormalSystem/Metalogic/Independence/` (concentrated in `ZTimeSharpness.lean`,
      `DenseRTimeSharpness.lean` and `SepSharpness.lean`), and the `¬ PlusValid φ` declarations in
      `FormalSystem/PlusLanguage/PlusNonValidities.lean`. Record the enumeration in the phase's
      commit message.
- [ ] For a frame-level refutation (`¬ F.ValidOn φ` or `¬ ValidOnFrames P φ`), register only where
      a class-tag corollary already sits beside it; where none does, skip the declaration and
      record the reason. Do not manufacture a corollary — that is `FormalSystem/` work and this
      task touches no file there.
- [ ] Create the entry modules under `BimodalLib/Countermodels/<Fragment>/<FrameClass>.lean`,
      mirroring the `BimodalLib/Theorems/<Fragment>/<FrameClass>.lean` convention the layout
      record prescribes. Each entry is a documented `def` of type `CountermodelEntry Formula` or
      `CountermodelEntry PlusFormula` with `grade := .semantic`, `profile_eq := rfl`,
      `refutation := fun h => <existing theorem> _ ((genericConsequenceIn_nil _ _).mp h)`, and
      `model` naming the model the cited proof uses.
- [ ] File each entry at its MAXIMAL frame class only. Where the order's tree shape makes two
      classes maximal for one inference, land two entries and say so in their notes; do not land
      a weaker-class duplicate that `transferLe` already derives.
- [ ] Set `nearMiss` on the five `⊡` refutations in `PlusNonValidities.lean` to the declaration
      each bounds, and use `note` where the bounded object is not a declaration at all: the
      paper's *Determined* schema is not formalized (the module docstring says so), and the
      `P⊡p → ⊡Pp` refutation has no counterpart in the tree.
- [ ] Record, in the `BimodalLib/Countermodels/` modules' own docstrings, that no
      `StarNonValidities` row is registered and why: `StarValidOn` carries an extra binder, there
      is no `profileS`, and `sentDet`/`timeStore`/`timeRecall` are L⋆-only. `refute_erasure`'s
      content is L-statable but the declaration as written is over `StarFormula`.
- [ ] Add every new module's import to `BimodalLib.lean`.

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over this phase's harvested paths — its four new
entry modules and the root, plus the `typst/generated/status.typ` surface the harvester
auto-appends to any `.lean` edit — returns the real suites `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, so the covering checks are `bash .claude/scripts/verify-touched.sh`
over this phase's five declared paths, which runs that narrowed pass itself, plus
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`,
which elaborates every new entry module and its root import.

**Scope Hypothesis**: the registrable hand-built corpus is hypothesized to be about 16 class-tag
`¬ ValidIn` declarations across the three sharpness modules plus the 5 `¬ PlusValid` declarations
in `PlusNonValidities.lean`, around 21 entries in all, with every one carrying `Γ = []` because
`co_not_derives_prior_U_gap` is the directory's only `Γ`-indexed refutation and it is
derivability-level. Confirm by the enumerating sweep in this phase's first task — an exact-name
sweep per declaration, never a prefix-anchored one — and record the actual count against this
hypothesis. A number different from 21 is a finding to record, not a failure.

**Files to modify**:
- `BimodalLib/Countermodels/ModalBoolean/Base.lean` - new: entries whose inference sits in the ModalBoolean fragment at Base
- `BimodalLib/Countermodels/TemporalBoolean/Dense.lean` - new: the Dense-maximal entries of the sharpness corpus
- `BimodalLib/Countermodels/TemporalBoolean/RTime.lean` - new: entries maximal at RTime, where the sweep finds any
- `BimodalLib/Countermodels/ModalTemporalBoolean/Base.lean` - new: the five stability-operator refutations with their near-miss links
- `BimodalLib.lean` - add one import line per new module

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`
  exits 0 with no warning; every `profile_eq := rfl` therefore reduced.
- At least one `CountermodelEntry Formula` and one `CountermodelEntry PlusFormula` exist with
  `grade = .semantic`, confirmed by a compiled `#guard` or `#eval` probe over the entry names
  rather than by inspection.
- `grep -c 'sorry' BimodalLib/Countermodels/**/*.lean` is 0, and C3 of
  `scripts/check-module-invariants.sh` still reports a zero structural sorry inventory across
  `BimodalLib/`.

---

### Phase 4: The CERTIFICATE grade -- the ZTime witness family [COMPLETED]

**Goal**: one kernel-checked entry at `grade := .certificate`, from the accepted witness-family
certificate at ZTime — the only grade whose own theorem natively has the `Γ ⊭ φ` shape with a
non-empty `Γ`.

**Tasks**:
- [ ] Create `BimodalLib/Countermodels/TemporalBoolean/ZTime.lean`, whose docstring states that
      the certificate grade's population route is the ZTime witness-family checkers, and that the
      tableau pipeline structurally cannot feed this grade (`regionLabel` and `temporalWitness`
      return `false` on every formula at ZTime, so the gated grade is unavailable there by
      construction rather than merely rare).
- [ ] Land the entry for `⊥ U ⊥` at `FrameClass.ZTime` by applying
      `FormalSystem.Metalogic.Decidability.WitnessFamily.not_consequence_ztime` to `botUntlFamily`
      and the four projections of `botUntlFamily_certifies`, which is itself closed `by decide`.
- [ ] Bridge `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ` to
      `¬ GenericConsequenceIn FrameClass.ZTime Γ σ`. Prefer a named `rfl` lemma over an inline
      `show`: `show` is linted in this repository and CI builds with `--wfail`, so exploiting the
      definitional equality inline is a CI failure.
- [ ] Set `model` to the name of the model-exhibiting declaration behind the certificate
      (`WitnessFamily.Refutes`, or the `PlusRefutes` route through
      `PlusSlicedCertificate.plusRefutes_of_certifies` if the L⁺ reading is landed too).
- [x] Record in the entry's `note` that this entry's `premises` list is non-empty, and that it is
      the only landed entry for which that is true. *(deviation: altered — the premise is false as
      measured. `botUntlFamily : WitnessFamily ([] : Context) [botUntl]`
      (EmbedComplete.lean:813), so this entry's `premises` is `[]` like every other landed entry.
      The note records the TRUE fact instead: the certificate grade is the only grade whose
      underlying theorem, `not_consequence_ztime`, takes a premise list NATIVELY, which is what
      the research report actually established; the plan over-read that into a claim about this
      entry's own `Γ`.)*
- [ ] Add the module's import to `BimodalLib.lean`.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over this phase's harvested paths — its one new
entry module and the root, plus the `typst/generated/status.typ` surface the harvester
auto-appends to any `.lean` edit — returns the real suites `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, so the covering checks are `bash .claude/scripts/verify-touched.sh
BimodalLib/Countermodels/TemporalBoolean/ZTime.lean BimodalLib.lean`, which runs that narrowed
pass itself, plus `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
BimodalLib --wfail` for the entry module this phase adds.

**Files to modify**:
- `BimodalLib/Countermodels/TemporalBoolean/ZTime.lean` - new: the certificate-grade entry at ZTime, its definitional bridge lemma, and the population-route docstring
- `BimodalLib.lean` - add the new module's import line

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`
  exits 0 with no warning.
- `#print axioms` on the entry's refutation field reports `[propext, Classical.choice,
  Quot.sound]` and nothing more; record the measured output.
- A compiled probe confirms the entry's `grade` is `.certificate`, its `frameClass` is `.ZTime`,
  and its `premises` list is non-empty.

---

### Phase 5: The GATED TABLEAU grade -- gates as data [COMPLETED]

**Goal**: the eight branch gates are bundled as one decidable `Bool` over `FormalSystem`
primitives, the gate theorem is repackaged on explicit branch data, and one entry at
`grade := .gatedTableau` lands with its gates discharged by `decide`.

**Tasks**:
- [ ] Create `BimodalLib/Countermodel/Gates.lean` and define `gatesOK (φ : Formula)
      (fc : FrameClass) (b : Branch) (ord : TimeOrdering) : Bool` as the conjunction of
      `timeOrderTotal b ord`, `boxAnchoredCheck b`, `regionLabelCheck b ord`,
      `temporalWitnessCheck b ord`, `branchOrderValid b ord`,
      `(findUnexpanded b (timeOrd := ord)).isNone`, `(findClosure b fc).isNone`,
      `b.hasNegAt φ Label.initial` and `b.knownWorlds.contains Label.initial.world`.
- [ ] Prove `not_genericConsequenceIn_of_gatesOK {φ} {fc} {b} {ord} (h : gatesOK φ fc b ord = true)
      : ¬ GenericConsequenceIn FrameClass.Base ([] : List Formula) φ` by destructuring the bundle
      and applying `FormalSystem.Metalogic.Decidability.Verified.Bridge.not_valid_of_hasOpen_int`.
      The conclusion is at `Base` because that theorem concludes `¬ Valid χ`; the `fc` argument is
      the class fed to `findClosure`. Destructure with
      `simp only [Bool.and_eq_true, Option.isNone_iff_eq_none]` then an eight-deep left-nested
      `obtain`, and use `List.contains_iff_mem` for the `knownWorlds` conjunct —
      `List.contains_iff` is deprecated and its warning is a `--wfail` failure.
- [ ] Record in the module docstring that none of the four gate theorems requires the branch to
      have come from `buildTableau`: soundness rests on the gates alone, which is what makes an
      explicit-branch entry possible, and that the `gatedRefuted`-by-`decide`-on-`buildTableau`
      alternative is deliberately not taken.
- [ ] Record in the same docstring that `BimodalTools.TableauBridge`'s `BranchGates` is the other
      gate bundle in the tree, that `lakefile.toml` forbids the `BimodalLib -> BimodalTools` edge
      so duplication is the only route, and that Phase 8 pins their agreement.
- [ ] Create `BimodalLib/Countermodels/Boolean/GatedTableau.lean` holding the branch data for one
      refuted formula and the entry built on it, with `grade := .gatedTableau`, `model` naming the
      `ℤ` region model the gate theorem constructs, and `note` recording that this entry is the
      grade's existence witness and that bulk admission waits on the pipeline emitting branches.
- [ ] MEASURE before committing the entry: the branch's length, the number of distinct times, the
      `maxRecDepth` the `by decide` gate discharge actually needs, and whole-file elaboration
      wall-clock. Wrap every generated line on a token boundary, never inside a tactic block, to
      stay under the 100-character limit.
- [x] If the file crosses 1500 lines (it is not expected to), baseline it with
      `set_option linter.style.longFile N` directly after the module docstring, with `N` the value
      the linter's own `candidate` arithmetic accepts for the file's CURRENT length — never
      `longFile 0`, and never a single early bump to a final expected value. *(deviation: skipped
      — not triggered. Measured: `GatedTableau.lean` is 123 lines and `Gates.lean` is 99, both far
      under the 1500-line limit, so no baseline is warranted.)*
- [ ] Add both new modules' imports to `BimodalLib.lean`.

**Timing**: 2 hours

**Depends on**: 1, 2

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over this phase's harvested paths — its two new
Lean modules and the root, plus the `typst/generated/status.typ` surface the harvester
auto-appends to any `.lean` edit — returns the real suites `test-plan-file-scope-harvest.sh` and
`test-validate-artifact.sh`, so the covering checks are `bash .claude/scripts/verify-touched.sh`
over this phase's three declared paths, which runs that narrowed pass itself, plus
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`,
which elaborates the `decide` gate discharge — the only expensive step here.

**Scope Hypothesis**: the entry's branch is hypothesized to be on the order of 14 signed formulas
across 4 times with a 3-constraint ordering, discharged by `decide` under
`set_option maxRecDepth 10000`, costing roughly 70 wrapped source lines and about 11 seconds of
whole-file elaboration including imports — the research probe's measurement on `p → ⊥`, the
simplest refuted formula in the pipeline dataset. Confirm by the measurement task above before
the entry is committed; a materially larger branch or a `maxRecDepth` the gate discharge will not
accept is a finding to record and, if `decide` does not close, grounds to mark the phase
`[BLOCKED]` rather than to reach for `native_decide`, which is barred.

**Files to modify**:
- `BimodalLib/Countermodel/Gates.lean` - new: the bundled gate predicate and the gate bridge theorem
- `BimodalLib/Countermodels/Boolean/GatedTableau.lean` - new: the explicit branch data and the one gated-tableau entry built on it
- `BimodalLib.lean` - add one import line per new module

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`
  exits 0 with no warning, and the measured elaboration time is recorded.
- `#print axioms` on the entry's refutation field reports `[propext, Classical.choice,
  Quot.sound]` and nothing more.
- `grep -n 'native_decide' BimodalLib/` returns nothing, and C3 still reports a zero structural
  sorry inventory across `BimodalLib/`.
- Every line of both new files is at most 100 characters (`awk 'length > 100' <file>` is empty).

---

### Phase 6: LOOKUP up to renaming of atoms [COMPLETED]

**Goal**: an inference can be looked up in the countermodel library up to renaming of atoms, for
use by the proof mode's unclosed-leaf route, with a `PlusFormula` companion to the existing
matcher.

**Tasks**:
- [ ] Extend `BimodalLib/Subsumption.lean` with `matchSubstPAux`, `matchSubstP?`, `bindAtomP` and
      `isSubstInstanceP` over `PlusFormula`, structurally mirroring the existing `Formula`
      versions and adding the `⊡` case. The existing matcher is `Formula`-only.
- [ ] Define `sameUpToRenaming (x y : Formula) : Bool := isSubstInstance x y && isSubstInstance y x`
      and its `PlusFormula` companion, in `BimodalLib/Countermodel/Lookup.lean`. The strictness is
      the point: mutual instance-hood IS renaming, which `Subsumption.lean`'s own docstring
      already records, so no new recursion is needed.
- [ ] Define the lookup entry point over an inference: given `Γ` and `φ`, find a
      `CountermodelEntry` whose `premises`/`conclusion` match up to a single consistent renaming,
      with the premise list matched as a list (order-insensitively where the matcher allows it,
      and documented either way).
- [ ] Document in the module docstring that the lookup is the `proof_mode_countermodels_for_unclosed_leaves`
      consumer's entry point, that it never closes a goal, and that a hit is reported against the
      leaf rather than discharging it.
- [ ] Add `import BimodalLib.Countermodel.Lookup` to `BimodalLib.lean`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: `suite_selection_select` over this phase's harvested paths returns the
real suites `test-plan-file-scope-harvest.sh` and `test-validate-artifact.sh` (from the
`typst/generated/status.typ` surface the harvester auto-appends to any `.lean` edit; the Lean
paths themselves map to none), so the covering checks are
`bash .claude/scripts/verify-touched.sh` over this phase's three declared paths, which runs that
narrowed pass itself, plus `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
BimodalLib BimodalLibTest --wfail`, which elaborates both direct dependents of the existing
module this phase edits.

**Scope Hypothesis**: `matchSubst?` is hypothesized to be `Formula`-only, so a `PlusFormula`
companion is required work rather than optional, and the mutual-`isSubstInstance` test is
hypothesized to need no new recursion. Confirm the first by reading
`BimodalLib/Subsumption.lean`'s signatures before writing the companion, and the second by
reproducing the research probe's six `#eval` cases as the Phase 8 test: `p₀ → p₁` against
`p₁ → q` true; `p₀ → p₀` against `p₀ → p₁` false; `□p₀ → p₀` against `□p₁ → p₁` true; and
`p₀ → ⊥` against `□p₀ → ⊥` false while plain `isSubstInstance` on the same pair is true.

**Files to modify**:
- `BimodalLib/Subsumption.lean` - add the four-function PlusFormula companion matcher, mirroring the existing Formula versions
- `BimodalLib/Countermodel/Lookup.lean` - new: the renaming test, its PlusFormula companion, and the inference lookup entry point
- `BimodalLib.lean` - add the new module's import line

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib BimodalLibTest --wfail`
  exits 0 with no warning, so neither dependent of `Subsumption.lean` regressed.
- `assert_no_subsumed_entries BimodalLib.Theorems.Enumerated` in
  `BimodalLib/Theorems/Complete.lean` still passes — the one existing consumer of the matcher's
  behaviour, and the check that would notice a change to it.
- A compiled `#eval` probe reproduces all six renaming cases named in the Scope Hypothesis with
  the stated verdicts.

---

### Phase 7: The index, the per-grade census, and the near-miss invariant [COMPLETED]

**Goal**: `library_index` renders a Countermodels section with a per-grade census, every `some
nearMiss` is checked to resolve as a build invariant, and `BimodalLib/INDEX.md` is regenerated.

**Tasks**:
- [ ] Extend `BimodalLib/Index.lean` with a countermodel row type and a `renderCountermodels`
      section: entries by fragment and frame class, with grade, statement, model and near-miss
      columns, plus a per-grade census table. Follow `renderConjectures`' style — environment walk
      plus `mkAppM` projections plus `ppOneLine` — rather than `rowStatement?`'s `unsafe evalExpr`,
      because `evalExpr` is monomorphic and the entry type is generic.
- [ ] Write the walk with an explicit branch over `CountermodelEntry Formula` and
      `CountermodelEntry PlusFormula`. This per-language branching is the accepted price of the
      generic type and is recorded as such in the module docstring.
- [ ] Wire `renderCountermodels` into the `library_index` output beside the theorem, pairing,
      conservativity and conjecture sections.
- [ ] Create `BimodalLib/Countermodels/Complete.lean`, importing every countermodel entry module,
      and define plus run `assert_near_miss_targets_resolve`: the command fails the build when an
      entry's `nearMiss` is `some n` and `n` is not in the environment. This is the honest
      substitute for the record's "the two entries name each other" — the asymmetry is real and
      documented, so the invariant checks the one direction that is constructible.
- [ ] Add `import BimodalLib.Countermodels.Complete` to `BimodalLib.lean`.
- [ ] Regenerate the index with `bash scripts/library-index.sh` and commit the resulting
      `BimodalLib/INDEX.md` in this same phase.

**Timing**: 2 hours

**Depends on**: 3, 4, 5, 6

**Verification Tier**: interface

**Tier Justification**: `suite_selection_select` over this phase's harvested paths returns the
real suites `test-plan-file-scope-harvest.sh` and `test-validate-artifact.sh` (from the
`typst/generated/status.typ` surface the harvester auto-appends to any `.lean` edit), so the
covering checks are `bash .claude/scripts/verify-touched.sh` over this phase's four declared
paths, plus `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib
BimodalLibTest --wfail` and `bash scripts/library-index.sh --check` — the one check that reads the
generated artifact this phase moves.

**Scope Hypothesis**: the Countermodels section is hypothesized to render roughly 22 entries —
Phase 3's ~21 plus Phase 4's one plus Phase 5's one, less any the Phase 3 sweep finds
unregistrable — spread across the Boolean, ModalBoolean, TemporalBoolean and ModalTemporalBoolean
fragments and the Base, Dense, RTime and ZTime classes, with all three grades non-empty. Confirm
by reading the regenerated `BimodalLib/INDEX.md`'s own census table, not by counting source
`def`s.

**Files to modify**:
- `BimodalLib/Index.lean` - add the countermodel row type, the render section, the per-grade census, and the per-language branch
- `BimodalLib/Countermodels/Complete.lean` - new: the aggregator plus the near-miss resolution invariant and its invocation
- `BimodalLib/INDEX.md` - regenerated by the index script; the coupled generated surface this phase moves, and it moves ONLY here, because the index renders no countermodel row until the render section exists -- Phases 3-5 add entry constants that nothing yet reads
- `BimodalLib.lean` - add the new module's import line

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib BimodalLibTest --wfail`
  exits 0 with no warning, so `assert_near_miss_targets_resolve` passed.
- `bash scripts/library-index.sh --check` reports `BimodalLib/INDEX.md` current.
- The regenerated `INDEX.md` contains a Countermodels section whose census shows a non-zero count
  for each of `semantic`, `certificate` and `gatedTableau` — the DONE WHEN clause's "three grades
  with at least one entry each", read off the generated artifact.

---

### Phase 8: Tests, the gate-bundle agreement pin, and the count surface [COMPLETED]

**Goal**: lookup is tested, the three grades and the near-miss invariant are pinned in both
directions, the two gate bundles are pinned to agree, and `typst/generated/status.typ` is
regenerated so the commit is not refused.

**Tasks**:
- [ ] Create `Tests/BimodalLibTest/CountermodelTest.lean` with `#guard`/`#eval`/`#guard_msgs`
      probes: the six renaming cases from Phase 6's Scope Hypothesis; a positive lookup (an
      inference found up to renaming) and a negative one (a near-miss shape not found); the
      per-grade census being non-zero for all three grades; and `#print axioms` on one entry per
      grade.
- [ ] Add a fixture under `Tests/BimodalLibTest/Fixtures/` that pins
      `assert_near_miss_targets_resolve` FAILING on an entry whose `nearMiss` names a
      non-existent declaration, following the `UnregisteredDerivation.lean` and
      `UnrecordedProofFragment.lean` precedent — a command that stops failing where it should is
      what `lake build BimodalLibTest --wfail` exists to catch.
- [ ] Pin the agreement of `BimodalLib`'s `gatesOK` with `BimodalTools.TableauBridge`'s
      `BranchGates`/`evalBranchGates` on the Phase 5 branch. The test library may import both;
      `BimodalLib` itself may not.
- [ ] Add the new test modules' imports to `Tests/BimodalLibTest.lean`.
- [ ] Regenerate `typst/generated/status.typ` with `bash scripts/typst-sync-check.sh --fix` IN
      THIS PHASE and stage it with the test files. `Tests/` IS counted by
      `scripts/typst-status-counts.sh` (`tests_file_count`, `tests_line_count`), and
      `.githooks/pre-commit` refuses any commit staging a `.lean` path while `status.typ` has
      drifted. This cannot be deferred to Phase 9.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` over this phase's harvested paths returns the
real suites `test-plan-file-scope-harvest.sh` and `test-validate-artifact.sh` (mapped from
`typst/generated/status.typ`, which this phase declares outright rather than relying on the
harvester's auto-append), so the covering checks are `bash .claude/scripts/verify-touched.sh` over
this phase's five declared paths, plus `bash .claude/scripts/lake-build-guard.sh build --timeout
1800 -- build BimodalLibTest --wfail` and `bash scripts/typst-sync-check.sh --counts-only` — the
exact check the pre-commit hook runs over the generated surface this phase moves.

**Files to modify**:
- `Tests/BimodalLibTest/CountermodelTest.lean` - new: lookup, census, axiom and renaming probes
- `Tests/BimodalLibTest/Fixtures/UnresolvedNearMiss.lean` - new: the fixture pinning the near-miss invariant's failure direction
- `Tests/BimodalLibTest/GateAgreementTest.lean` - new: the gate-bundle agreement pin between the two bundles in the tree
- `Tests/BimodalLibTest.lean` - add one import line per new test module
- `typst/generated/status.typ` - regenerated: the Tests-tree file and line counts move because this phase adds Lean files under that tree, and the pre-commit hook is commit-blocking on that drift

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLibTest --wfail`
  exits 0 with no warning.
- `bash scripts/typst-sync-check.sh --counts-only` reports `MISMATCH_COUNT=0` with the new test
  files on disk (baseline before this phase was also 0, measured at plan time).
- The fixture fails to build on its own, confirming the near-miss invariant's failure direction,
  in the manner the existing `Fixtures/` tests use.

---

### Phase 9: Documentation, the record, and final verification [COMPLETED]

**Goal**: `docs/reference/bimodal-lib.md` documents the three grades and the whole countermodel
half, `BimodalLib/README.md`'s module table covers the new modules, the implemented part is cut
from `records/theorem-library.md`, and the task's verification obligation is discharged.

**Tasks**:
- [ ] Add a Countermodels section to `docs/reference/bimodal-lib.md`: the entry type and its two
      kernel-checked invariants (`refutation` and `profile_eq`), the three admitted grades with
      each grade's population route, the filing rule (fragment and maximal frame class, with the
      order a tree so an inference may carry two maximal entries), both transfer theorems, the
      lookup up to renaming, and the registration convention (a documented constant under
      `BimodalLib/Countermodels/`, not a new command).
- [ ] Record in the same section, explicitly rather than by omission: that an ungated `invalid`
      verdict is registered as a heuristically-refuted conjecture and is never an entry; that no
      `StarNonValidities` row is registered, with the reason; that derivability- and
      definability-level independence results are not countermodel entries; that the certificate
      grade's route is the ZTime witness-family checkers and the tableau pipeline structurally
      cannot feed it; and that near-miss naming is one-directional because `TheoremEntry` is
      `Formula`-only by type and the bounded laws cannot be registry rows.
- [ ] Add the new rows to `docs/reference/bimodal-lib.md`'s Layout table and to its "What checks
      the library" table (`assert_near_miss_targets_resolve`, and the new `BimodalLibTest`
      fixtures).
- [ ] Add the new modules to `BimodalLib/README.md`'s Modules table.
- [x] Cite every `FormalSystem` declaration by bare name beside its module file path, never as a
      dotted `FormalSystem.X.Y` string and never with a `file.lean:NNN` line number: C5's
      module-path regex cannot tell a declaration name from a module path, and C20 gates any
      out-of-range or blank-line line citation repo-wide. Where a dotted form is genuinely
      unavoidable, add the entry to `scripts/module-invariants-allowlist.txt`, which already
      carries entries of exactly this shape, and say so in the commit message. *(deviation:
      altered — the hand-written docs use bare names throughout and need no exemption, but the
      GENERATED `BimodalLib/INDEX.md` emits two dotted names from row field data
      (`FormalSystem.PlusLanguage.PlusAxiom` via `nearMiss`,
      `FormalSystem.Metalogic.Decidability.WitnessFamily.Refutes` via `model`), which cannot be
      rewritten by hand without staling `library-index.sh --check`. A concurrent writer
      allowlisted both, plus `BimodalLib.Grade`, while this phase ran; this dispatch's own
      duplicate append was removed, so its net change to the allowlist is zero lines.)*
- [ ] Cut the implemented part from `records/theorem-library.md`'s Countermodels section and from
      its Layout section's "directories still to come" block, leaving precisely two things: the
      bulk tableau-fed admission (with the measured reason — the data file carries no branch, and
      ~70 lines per entry against 1,047 statements and a 1,500-line linter) and the
      EVALUATOR-CHECKED fourth grade. Both targets were confirmed present at authoring time; if
      either section has moved by the time this phase runs, update the section that now carries
      the Countermodels design rather than inventing a target.
- [ ] Re-run `bash scripts/library-index.sh --check` and confirm `BimodalLib/INDEX.md` is still
      current after the documentation edits.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- `docs/reference/bimodal-lib.md` - new Countermodels section, plus Layout and check-table rows
- `BimodalLib/README.md` - Modules table rows for the three new module groups
- `records/theorem-library.md` - cut the implemented part of the Countermodels section and the realized half of the Layout block
- `scripts/module-invariants-allowlist.txt` - contingent: one entry only if a docs citation genuinely needs a dotted declaration name that C5 cannot resolve; no edit if every citation uses the bare-name form

**Verification**:
- In-dispatch obligation under `/orchestrate`: `bash .claude/scripts/verify-touched.sh
  docs/reference/bimodal-lib.md BimodalLib/README.md records/theorem-library.md` for the paths
  this phase touched, plus `bash .claude/scripts/verify-deploy.sh --only-gate 4 --skip-unchanged
  /home/benjamin/Projects/BimodalLogic` — the narrowed, scoped checks for a touched set the
  selector maps to no shell suite. The complete gate set is DEFERRED to the orchestration close
  (the once-per-invocation batch gate stage), not run independently here.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib BimodalLibTest --wfail`
  exits 0 with no warning.
- `bash scripts/library-index.sh --check` reports the index current.
- `bash scripts/check-module-invariants.sh` reports no NEW finding naming any file this task
  touched. C5, C20, C26 and C3 are each read as a delta against the pre-task baseline, captured
  before Phase 1; a red finding that names only pre-existing, out-of-scope files is a recorded
  PASS for this phase with those findings enumerated, not a blocker and not grounds to edit an
  out-of-scope file.
- `bash scripts/typst-sync-check.sh --counts-only` reports `MISMATCH_COUNT=0`.
- A final sweep confirms `BimodalLib/` contains no `sorry`, no new `axiom` and no
  `native_decide`, by exact-name grep over the task's own new declaration names rather than a
  prefix-anchored pattern.

## Lean Challenge Statements

```lean
import FormalSystem

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics
open FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace BimodalLib

/-- The premise-bearing consequence relation over `PointTruth`. -/
def GenericConsequenceIn {L : Type} [PointTruth L]
    (fc : FrameClass) (Γ : List L) (φ : L) : Prop := sorry

/-- The empty-premise case is generic validity. -/
theorem genericConsequenceIn_nil {L : Type} [PointTruth L] (fc : FrameClass) (φ : L) :
    GenericConsequenceIn fc ([] : List L) φ ↔ GenericValidIn fc φ := sorry

/-- TRANSFER downward in frame class: a refutation at a stronger class refutes at every weaker
class the model belongs to. -/
theorem not_genericConsequenceIn_of_le {L : Type} [PointTruth L] {fc₁ fc₂ : FrameClass}
    (h : fc₁ ≤ fc₂) {Γ : List L} {φ : L}
    (hr : ¬ GenericConsequenceIn fc₂ Γ φ) : ¬ GenericConsequenceIn fc₁ Γ φ := sorry

/-- TRANSFER of an L countermodel into L⁺, along the embedding. -/
theorem not_genericConsequenceIn_ofFormula {fc : FrameClass} {Γ : List Formula} {φ : Formula}
    (hr : ¬ GenericConsequenceIn fc Γ φ) :
    ¬ GenericConsequenceIn fc (Γ.map ofFormula) (ofFormula φ) := sorry

/-- The eight branch gates, bundled as one decidable `Bool` over `FormalSystem` primitives. -/
def gatesOK (φ : Formula) (fc : FrameClass) (b : Branch) (ord : TimeOrdering) : Bool := sorry

/-- The gate bridge: a gated open branch denying `φ` refutes `φ` from the empty premise list. -/
theorem not_genericConsequenceIn_of_gatesOK {φ : Formula} {fc : FrameClass}
    {b : Branch} {ord : TimeOrdering} (h : gatesOK φ fc b ord = true) :
    ¬ GenericConsequenceIn FrameClass.Base ([] : List Formula) φ := sorry

end BimodalLib
```

The two `def`s carry `sorry` bodies because this section pins statements only; their real bodies
are Phase 1's and Phase 5's work. `CountermodelEntry` is deliberately absent — a `structure`
cannot carry a `sorry` body, so its shape is pinned by Phase 1's field-by-field task list
instead (see Decisions).

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLib --wfail`
      exits 0 with no warning.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalLibTest --wfail`
      exits 0 with no warning.
- [ ] `bash scripts/library-index.sh --check` reports `BimodalLib/INDEX.md` current, and that
      index's Countermodels census is non-zero for each of the three grades.
- [ ] `bash scripts/typst-sync-check.sh --counts-only` reports `MISMATCH_COUNT=0`.
- [ ] `bash scripts/check-module-invariants.sh` reports no new finding naming a file this task
      touched, read as a delta against the pre-task baseline.
- [ ] `lake exe runLinter BimodalLib` reports no new finding beyond `scripts/nolints.json`'s
      existing baseline. If a pinned-but-unread hypothesis trips `unusedArguments`, the remedy is
      a hand-inserted row in `scripts/nolints.json`, placed beside an existing exemption of the
      same shape — never `lake exe runLinter --update`, which rewrites the whole ledger, and never
      a `set_option`, which the batch pass does not read.
- [ ] The six renaming cases, the positive and negative lookups, and the gate-bundle agreement all
      pass as compiled probes under `BimodalLibTest`.
- [ ] The `Fixtures/UnresolvedNearMiss.lean` fixture fails to build on its own.
- [ ] `BimodalLib/` contains no `sorry`, no new `axiom` and no `native_decide`; `FormalSystem/`
      imports nothing from `BimodalLib` (B3).

## Artifacts & Outputs

- `BimodalLib/Countermodel.lean` — the entry type, the generic consequence relation, `HasProfile`,
  `Grade`.
- `BimodalLib/Countermodel/Transfer.lean` — both TRANSFER theorems and their entry-level
  companions.
- `BimodalLib/Countermodel/Gates.lean` — `gatesOK` and the gate bridge theorem.
- `BimodalLib/Countermodel/Lookup.lean` — lookup up to renaming of atoms.
- `BimodalLib/Countermodels/<Fragment>/<FrameClass>.lean` — the entries, at all three grades.
- `BimodalLib/Countermodels/Complete.lean` — the near-miss resolution invariant.
- `BimodalLib/Subsumption.lean` — extended with the `PlusFormula` companion matcher.
- `BimodalLib/Index.lean`, `BimodalLib/INDEX.md` — the Countermodels section and per-grade census.
- `Tests/BimodalLibTest/CountermodelTest.lean`, `Tests/BimodalLibTest/GateAgreementTest.lean`,
  `Tests/BimodalLibTest/Fixtures/UnresolvedNearMiss.lean` — the tests, in both directions.
- `typst/generated/status.typ` — regenerated for the `Tests/` count change.
- `docs/reference/bimodal-lib.md`, `BimodalLib/README.md` — the countermodel half documented.
- `records/theorem-library.md` — reduced to what remains unimplemented.

## Rollback/Contingency

Every phase is additive: new modules plus one import line each, with the only edits to existing
Lean source being `BimodalLib/Subsumption.lean` (additive companion functions) and
`BimodalLib/Index.lean` (an additive render section). Reverting a phase is therefore a revert of
that phase's own commit, with no cross-phase entanglement beyond the import lines in
`BimodalLib.lean` and `Tests/BimodalLibTest.lean`.

If a phase must be abandoned mid-way with uncommitted work in the tree, take a durable,
non-reverting checkpoint first — `bash .claude/scripts/git-snapshot.sh 973 --no-revert` — and do
not reach for the default reverting form, which belongs only to a genuine rollback. For a genuine
rollback that must discard uncommitted work, follow `context/contracts/recovery.md`'s rollback
rung for the exact invocation shape, including its out-of-scope override flag, before running the
destructive command.

Two contingencies are worth naming in advance:

- **Phase 5's `decide` does not close the gate bundle** on the branch chosen. Mark the phase
  `[BLOCKED]` and raise it. Do not substitute `native_decide` (barred in `BimodalLib` by both the
  dispatch and `records/proof-mode.md`), and do not substitute a vacuous placeholder.
- **The Phase 7 per-language branching proves worse than duplication.** The recorded fallback is
  two concrete row types (`CountermodelEntry` over `Formula` and over `PlusFormula`) instead of
  one generic one. This changes no statement in the library and no entry's proof; it costs a
  second structure and a second index branch, and it is a legitimate retreat rather than a
  deviation to escalate.
