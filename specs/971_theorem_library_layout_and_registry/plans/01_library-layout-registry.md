# Implementation Plan: Task #971

- **Task**: 971 - Theorem library: layout and registry
- **Status**: [NOT STARTED]
- **Effort**: 13 hours
- **Dependencies**: None
- **Research Inputs**: specs/971_theorem_library_layout_and_registry/reports/01_library-layout-registry.md
- **Artifacts**: plans/01_library-layout-registry.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Create the Lake library `BimodalLib` beside `BimodalTools`, outside `defaultTargets`, and give it
the five parts of milestone M18: fragment computation, a registry of the closed derivations
already proved under `FormalSystem/Theorems/`, a pairing command, conjecture registration, and a
generated index. The registry is a set of kernel-checked definitions generated from the type of
each registered declaration; there is no attribute and no environment extension. No file under
`FormalSystem/` is edited, so the generated library root, the module-inventory blocks and the
FormalSystem line count are untouched. Done when `lake build BimodalLib --wfail` passes locally
and as a CI step, the registration check fails on an unregistered derivation, the pairing command
is tested on one re-proof, a conjecture is registered, the index is produced by one named
command, and `ORGANISATION.md` has a row for the library.

### Research Integration

Integrated from `reports/01_library-layout-registry.md`:

- Registry design C: `register_theorem X` expands to a definition of type `TheoremEntry` built
  from the type of `X`, added with `addAndCompile`. The registry is the set of constants of that
  type.
- The completeness check keys on the declaring module, not the namespace, and its module imports
  the root `FormalSystem`, not `FormalSystem.Theorems`.
- Pairing is `def Y : type_of% @X := t` behind a `reprove X as Y := t` command.
- Conjecture statements are `Prop`s; the conservativity edges are stated over `within`,
  `DerivableIn` and `ConservativeEdge`.
- Commands carry no leading `#`, because `linter.hashCommand` is on for this library and CI
  builds with `--wfail`.
- The probes under `specs/971_theorem_library_layout_and_registry/probes/` are working
  prototypes of every command. They are reference material; their `def` names and `#` commands
  are not promoted verbatim (see Decisions).

**Premise re-validation.** The description's flagged line was checked against the report and
against the live tree at planning time:

| Claim in the description | Result |
|---|---|
| A user ruling on `defaultTargets` is needed and the plan stops for it | Stale. `records/theorem-library.md`, section Layout, reads "It is outside `defaultTargets`" and rejects the alternative; M18 in `records/proof-mode.md` repeats it. Open decision 1 of that record is now enumeration bounds. The plan does not stop. |
| `BimodalTools` is outside `defaultTargets`, built on request and in CI | Confirmed live: `lakefile.toml` has `defaultTargets = ["FormalSystem"]`; `.github/workflows/ci.yml` has the step "Compile BimodalTools (outside defaultTargets)". |
| Hard dependencies: none | Confirmed against M18 in `records/proof-mode.md`. |
| `BimodalLib` does not exist yet | Confirmed live: no `BimodalLib/` directory, no `BimodalLib` entry in `lakefile.toml`. |
| Four fragments; `⊡` in the Modal family | Confirmed against the record's Fragments section as quoted by the report. |
| Counts of 190 closed, 85 context-form, 56 rules | Carried from the report's compiled probes, not re-measured here. Treated as hypotheses; Phase 3 confirms them. |

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied in the dispatch. The task is milestone M18, lane Library, of
`records/proof-mode.md`.

## Goals & Non-Goals

**Goals**:
- A Lake library named BimodalLib, outside the default targets, that imports FormalSystem and is
  never imported by it, built in CI with warnings as errors.
- Fragment, modal operator set and frame class tag computed for both formula types, with the two
  computations proved to agree on the embedding of the smaller language.
- Every closed derivation under the Theorems directory of FormalSystem, outside its ProofMode
  directory, registered by reference as a kernel-checked row; a check that fails when one is
  unregistered.
- A pairing command that elaborates a second proof against the type of a registered declaration,
  tested on one re-proof and on one drifted re-proof.
- Conjecture registration with no proof field, seeded with the unproved conservativity edges and
  the collapse derivation in the extended language.
- An index by fragment and frame class, listing every box law with no declared diamond dual,
  produced by one named command.
- Documentation that describes the library as it exists, and the implemented parts cut from the
  design record.

**Non-Goals**:
- Editing any file under `FormalSystem/`, and in particular under either `ProofMode` directory.
- Registering the context-form derivations or the rules. The check prints their counts so the
  boundary is visible.
- Proving any conservativity edge, or the collapse derivation.
- Countermodel entries, tableau-pipeline entries, stability entries, diagnostics. Their
  directories are not created.
- A row type for `PlusDerivationTree` theorems. No closed one exists under the scanned directory;
  `profileP` and the substitution class exist for the later consumer.
- Adding the pattern note the report recommends under `.claude/context/`. The deployed tree is a
  disposable artifact and its source store is absent from this checkout.
- Putting `BimodalLib` in `defaultTargets`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `docBlame` and other environment linters fire on the generated rows | M | H | `register_theorem` attaches a generated docstring; Phase 7 runs `lake exe runLinter BimodalLib` and fixes findings at the generator, never with `runLinter --update` |
| A package-level syntax linter warning fails the `--wfail` build (file header, module docstring, `#` command, `show`, unused variable) | M | H | Every phase's gate is `lake build BimodalLib --wfail`; `#guard_msgs` and other `#` commands live only in `BimodalLibTest`, which carries the `hashCommand` opt-out |
| Adding files under `Tests/` moves `tests-file-count` and `tests-line-count` in `typst/generated/status.typ`, and the pre-commit hook blocks the commit | H | H | Phase 4 regenerates with `scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in the same phase |
| The module-invariants checks, once `BimodalLib` is in `LIB_ROOTS`, report findings on the new files (C5 module-path regex on dotted declaration names in `register_theorem` lines, C29/C30 on linter options, copyright headers, README health) | M | M | Phase 7 owns these; exemptions go in `scripts/module-invariants-allowlist.txt` as permanent entries; criteria are deltas against a baseline captured before the edit |
| The frame class of a row stated above Base is an upper bound, not a proved weakest class | L | H | The index labels those rows "stated at"; the docs say so |
| The dual listing is declarative: no mechanical test decides duality | L | H | The index lists every row with a universal operator and no declared dual; the first listing is long by design |
| The three conservativity seeds the report did not prototype do not elaborate as planned, in particular the edge between the two `ModalBoolean` cells, which is about the extended language | M | M | Phase 5 states the fallback: a `Prop` over `PlusDerivationTree` with a profile bound, without a `within` analogue; a seed that cannot be stated is reported, not dropped silently |
| A new file under `FormalSystem/Theorems/` not imported by the root would escape the check | L | L | The check module imports the root `FormalSystem`; C33 guards the root |
| The committed index goes stale when a theorem is added | L | M | The index script has a `--check` mode that CI runs; a new theorem already fails the completeness check, so both are fixed in one change |

## Decisions

- **No user decision is raised.** The `defaultTargets` question is decided in
  `records/theorem-library.md`, section Layout. The description's request for a ruling predates
  that text.
- **Zero Lean challenge statements.** The task's deliverables are definitions, commands and
  registration rows. Its one theorem, the agreement of `profileP` and `profileF` on the
  embedding, is stated over definitions this task creates, so no statement can be pinned in a
  module that type-checks against the tree as it stands. The theorem is still required; Phase 1
  verifies it by build and by `#print axioms` in the test library.
- **Probes are not promoted verbatim.** The prototypes name the check
  `#check_registry_complete` and may use snake_case `def` names. The library uses commands
  without `#` and lowerCamelCase `def`s, as C26 of `scripts/check-module-invariants.sh` requires.
- **Test code lives in a fifth test library, `BimodalLibTest`, under `Tests/`**, on the
  `BimodalToolsTest` pattern, with its own CI step. The failing direction of the completeness
  check is tested against a fixture module, so no published module ever fails to build.
- **The index is a committed generated file, `BimodalLib/INDEX.md`**, written by
  `scripts/library-index.sh`, which also has a `--check` mode. A committed file can be read
  without a build; the check mode keeps it honest.
- **`BimodalLib.lean` is a hand-maintained root**, as `BimodalTools.lean` is. Reachability of
  every module from it is covered once `BimodalLib` is in `LIB_ROOTS`.
- **Registration files are one per fragment and frame class**, seven in all, matching the cells
  of the report's tally. A file is split by theme only if it would otherwise be hard to read.
- **The one tested re-proof lives in the test library.** The record reserves
  `BimodalLib/ProofMode/<Fragment>/` for proofs written in the proof mode, which is the hard
  consumer's work, not this task's.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. The plan is sequential: every phase from 2
on edits the root `BimodalLib.lean`.

### Phase 1: Library scaffold and fragment computation [NOT STARTED]

**Goal**: `BimodalLib` exists as a Lake library and computes the fragment, modal operator set
and frame class tag for both formula types.

**Tasks**:
- [ ] Add `[[lean_lib]] name = "BimodalLib"` to `lakefile.toml` with the `leanOptions` of
  `BimodalTools`, leaving the `defaultTargets` line unchanged. Extend the header comment to name
  the library and say why it is outside the default targets.
- [ ] Create the root `BimodalLib.lean` with the repository's copyright header, importing
  `BimodalLib.Fragment`.
- [ ] Create `BimodalLib/Fragment.lean`: `Family` (Modal, Temporal); `Fragment` (Boolean,
  ModalBoolean, TemporalBoolean, ModalTemporalBoolean); `Profile` with fields for `□`, `⊡` and
  temporal occurrence, and an order by inclusion; `profileF : Formula → Profile` and
  `profileP : PlusFormula → Profile` by recursion on the primitives; `Profile.fragment`, mapping
  box-or-stab to Modal; the substitution class type; the agreement theorem
  `profileP (ofFormula φ) = profileF φ`. Take the definitions from
  `probes/registry-prototype.lean` and rename any `def` that has a non-trailing underscore.
- [ ] Give every definition a docstring and the file a module docstring.
- [ ] Create `BimodalLib/README.md` in the shape `docs/development/DIRECTORY_README_STANDARD.md`
  asks for.
- [ ] Run `lake build BimodalLib --wfail`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` covers the edit, since the new library
is outside `defaultTargets` and nothing imports it, and the `lakefile.toml` diff leaves the
`defaultTargets` line untouched.

**Files to modify**:
- `lakefile.toml` - new `lean_lib` entry and header comment
- `BimodalLib.lean` - new root
- `BimodalLib/Fragment.lean` - new
- `BimodalLib/README.md` - new

**Verification**:
- `lake build BimodalLib --wfail` exits 0.
- `git diff lakefile.toml` shows the `defaultTargets` line unchanged.
- `grep -rn 'sorry\|native_decide\|^axiom ' BimodalLib BimodalLib.lean` finds nothing.

---

### Phase 2: Registry row type, registration command and completeness command [NOT STARTED]

**Goal**: A declaration can be registered by one line, as a kernel-checked row read from its
type, and a command can tell whether every closed derivation in a module prefix is registered.

**Tasks**:
- [ ] Create `BimodalLib/Registry.lean` with `TheoremEntry` as the report gives it: `arity`,
  `frameClass`, `stmt`, `proof`, `profile`, `profile_eq`. Add the declared dual as an optional
  name field.
- [ ] Implement `register_theorem X` and `register_theorem X (dual := Y)`: read the type of `X`
  with `forallTelescope`; substitute `v 0, v 1, ...` for the formula binders; take the frame
  class from the binder shape (implicit class: Base; one `C ≤ fc` hypothesis: `C`; fixed class:
  that class, with `DerivationTree.lift`); build `profile_eq` as `Eq.refl`; add the row as
  `BimodalLib.Registry.<full name of X>` with `addAndCompile`; attach a generated docstring
  with `addDocStringCore`. Reject a declaration that is not a closed derivation with a clear
  error.
- [ ] Create `BimodalLib/Registry/Complete.lean` defining `assert_registry_complete` with the
  scanned module prefix and the excluded prefix as parameters, defaulting to
  `FormalSystem.Theorems` and `FormalSystem.Theorems.ProofMode`. It enumerates constants by
  declaring module (`Environment.getModuleIdxFor?`), classifies each derivation-typed constant
  as closed, context-form or rule as the census probe does, reads the registered name off each
  row's `proof` field, logs the three counts, and throws with the names of the unregistered
  closed derivations. This module defines the command and does not run it.
- [ ] Import both modules from `BimodalLib.lean`. Run `lake build BimodalLib --wfail`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` covers the edit: both files are new
modules inside a library nothing else imports.

**Files to modify**:
- `BimodalLib/Registry.lean` - new
- `BimodalLib/Registry/Complete.lean` - new
- `BimodalLib.lean` - two imports

**Verification**:
- `lake build BimodalLib --wfail` exits 0.
- A scratch file outside the repository tree, run with `lake env lean`, registers one
  declaration of each of the four binder shapes and prints `#print axioms` for a row showing no
  `sorryAx`. The scratch file is not committed.

---

### Phase 3: Register the closed derivations and run the check [NOT STARTED]

**Goal**: Every closed derivation under `FormalSystem/Theorems/` outside `ProofMode/` has a row,
filed by its computed fragment and frame class, and the build fails if one is missing.

**Tasks**:
- [ ] Generate the `register_theorem` lines from `probes/census.tsv`, one per closed
  declaration, into the seven registration files below, by the fragment and frame class the
  prototype computed. Each file imports only the `FormalSystem` modules that declare what it
  registers, and `BimodalLib.Registry`.
- [ ] Create `BimodalLib/Theorems/Complete.lean`, importing the root `FormalSystem` and all
  seven files, and invoking `assert_registry_complete`.
- [ ] Import `BimodalLib.Theorems.Complete` from `BimodalLib.lean`. Run
  `lake build BimodalLib --wfail`.
- [ ] Compare the three counts the command logs, and the per-file row counts, with the Scope
  Hypothesis. Record any difference in the issue log and in the summary; the live counts win.
- [ ] Confirm placement: for one row per file, a `decide` or `rfl` example in a scratch file
  shows the row's fragment and frame class are those of the file it sits in.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` covers the edit and is itself the
registration check, since `BimodalLib/Theorems/Complete.lean` throws on any unregistered closed
derivation.

**Scope Hypothesis**: The report's probes count 190 closed derivations (Boolean/Base 39,
ModalBoolean/Base 25, ModalTemporalBoolean/Base 29, TemporalBoolean/Base 81,
TemporalBoolean/ZTime 14, TemporalBoolean/Dense 1, TemporalBoolean/RTime 1), 85 context-form
derivations and 56 rules, and seven non-empty cells. These are hypotheses. The implementer
confirms them from the counts `assert_registry_complete` logs on the live tree and from
`grep -c '^register_theorem'` per file, not from the census file that generated the lines. If a
cell is empty or a new one appears, the file list changes accordingly; a file may also be split
by theme within its directory.

**Files to modify**:
- `BimodalLib/Theorems/Boolean/Base.lean` - new
- `BimodalLib/Theorems/ModalBoolean/Base.lean` - new
- `BimodalLib/Theorems/ModalTemporalBoolean/Base.lean` - new
- `BimodalLib/Theorems/TemporalBoolean/Base.lean` - new
- `BimodalLib/Theorems/TemporalBoolean/ZTime.lean` - new
- `BimodalLib/Theorems/TemporalBoolean/Dense.lean` - new
- `BimodalLib/Theorems/TemporalBoolean/RTime.lean` - new
- `BimodalLib/Theorems/Complete.lean` - new
- `BimodalLib.lean` - import

**Verification**:
- `lake build BimodalLib --wfail` exits 0.
- With one `register_theorem` line commented out, `lake build BimodalLib.Theorems.Complete`
  fails and names that declaration; the line is restored before commit.
- `git status --short FormalSystem FormalSystem.lean` is empty.

---

### Phase 4: Pairing command and the test library [NOT STARTED]

**Goal**: A second proof of a registered statement is elaborated against the registered
declaration's type, and the failing directions of the pairing and of the completeness check are
tested.

**Tasks**:
- [ ] Create `BimodalLib/Pairing.lean`: `ReproofEntry`, holding the row of `X` and the second
  proof at the row's statement; `reprove X as Y := t`, expanding to
  `def Y : type_of% @X := t` and adding a `ReproofEntry` constant with `addAndCompile` and a
  generated docstring. It fails if `X` has no row. Import it from `BimodalLib.lean`.
- [ ] Add `[[lean_lib]] name = "BimodalLibTest"` to `lakefile.toml` with `srcDir = "Tests"` and
  the `leanOptions` of `BimodalToolsTest`, including the `hashCommand` opt-out and its comment.
- [ ] Create the root `Tests/BimodalLibTest.lean` and three test modules:
  `Tests/BimodalLibTest/FragmentTest.lean` (fragment of sample formulas of both types by
  `decide`; `#print axioms` of the agreement theorem under `#guard_msgs`);
  `Tests/BimodalLibTest/PairingTest.lean` (`reprove perpetuity1 as ...` with a correct proof,
  and a drifted one, `fun φ => perpetuity2 φ`, rejected under `#guard_msgs`);
  `Tests/BimodalLibTest/RegistryCheckTest.lean` (imports the fixture, aims
  `assert_registry_complete` at the fixture prefix, expects the error under `#guard_msgs`; then
  registers the fixture declaration in the test module and expects the check to pass).
- [ ] Create the fixture `Tests/BimodalLibTest/Fixtures/UnregisteredDerivation.lean`, declaring
  one closed derivation and nothing else.
- [ ] Run `lake build BimodalLib --wfail` and `lake build BimodalLibTest --wfail`.
- [ ] Run `bash scripts/typst-sync-check.sh --fix`, then
  `bash scripts/typst-sync-check.sh --counts-only`, and stage `typst/generated/status.typ` with
  the phase's files. The new files under `Tests/` move `tests-file-count` and
  `tests-line-count`, and `.githooks/pre-commit` blocks a commit that stages a `.lean` file
  while those counts are stale.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` and `lake build BimodalLibTest --wfail`
cover the edit, with `bash scripts/typst-sync-check.sh --counts-only` covering the one generated
surface the new test files move.

**Scope Hypothesis**: That `perpetuity1` and `perpetuity2` are registered closed derivations
with the types the report shows, and that only the `Tests` counts in
`typst/generated/status.typ` move. Confirm the first by the test building; confirm the second
from the diff of `typst/generated/status.typ` after `--fix`, and report any other changed line.
If `--fix` rewrites lines unrelated to this task, they are a concurrent writer's drift: report
them and stage only what the counts check needs.

**Files to modify**:
- `BimodalLib/Pairing.lean` - new
- `BimodalLib.lean` - import
- `lakefile.toml` - `BimodalLibTest` entry
- `Tests/BimodalLibTest.lean` - new root
- `Tests/BimodalLibTest/FragmentTest.lean` - new
- `Tests/BimodalLibTest/PairingTest.lean` - new
- `Tests/BimodalLibTest/RegistryCheckTest.lean` - new
- `Tests/BimodalLibTest/Fixtures/UnregisteredDerivation.lean` - new
- `typst/generated/status.typ` - regenerated counts

**Verification**:
- Both builds exit 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `RegistryCheckTest.lean` contains the expected error text of the failing check, and
  `PairingTest.lean` the type mismatch of the drifted re-proof, each under `#guard_msgs`.

---

### Phase 5: Conjecture registration and the seed conjectures [NOT STARTED]

**Goal**: A conjecture is a registered statement with a fragment, frame class, status and note
and no proof term; the unproved conservativity edges and the collapse derivation are seeded.

**Tasks**:
- [ ] Create `BimodalLib/Conjecture.lean`: `ConjectureStatus`; `structure Conjecture` with
  `statement : Prop`, `fragment`, `ops : Profile`, `frameClass : Option FrameClass`, `status`,
  `note : String`, and no proof field.
- [ ] Create `BimodalLib/Conservativity.lean`: `within c d` (with the `conclOf` helper and the
  `e@(.necessitation _ d)` pattern form the report found necessary), `DerivableIn c fc φ`, and
  `ConservativeEdge c fc`.
- [ ] Create `BimodalLib/Conjectures/Conservativity.lean` with one conjecture per unproved row
  of the Conservativity table in `records/theorem-library.md`: `Boolean` into `ModalBoolean`;
  `Boolean` into `TemporalBoolean`; `ModalBoolean` with `□` into TM; `TemporalBoolean` into TM,
  one per frame class; the `ModalBoolean` cell with `□` into the cell with both. Each note says
  what the record says is missing. For the last edge, which concerns the extended language,
  state it over `PlusDerivationTree` with a profile bound on the formula; if a `within`
  analogue for `PlusDerivationTree` is needed and does not fit the phase, state the edge as
  derivability of `ofFormula φ` in the extended system implying `DerivableIn` in the base
  system, and say in the note which form was used.
- [ ] Create `BimodalLib/Conjectures/ModalBoolean/Collapse.lean` with the collapse conjecture
  `∀ fc φ, φ.StateLocal → Nonempty (PlusDerivationTree fc [] ((φ.imp φ.stab).and (φ.stab.imp φ)))`,
  its note citing `plusStateLocal_stab_iff` as the validity already proved.
- [ ] Import the new modules from `BimodalLib.lean`. Run `lake build BimodalLib --wfail`.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` covers the edit: four new modules in a
library nothing outside its own test library imports.

**Scope Hypothesis**: The report prototyped two edge seeds and the collapse seed; the other
edges, and the fragment directory of the collapse file, are planned from the record's table and
not compiled. The count of unproved edges is read from the live table in
`records/theorem-library.md` at implementation time, not from this plan. A seed that cannot be
stated in either form above is reported in the summary with the elaboration error; it is not
omitted without a record.

**Files to modify**:
- `BimodalLib/Conjecture.lean` - new
- `BimodalLib/Conservativity.lean` - new
- `BimodalLib/Conjectures/Conservativity.lean` - new
- `BimodalLib/Conjectures/ModalBoolean/Collapse.lean` - new
- `BimodalLib.lean` - imports

**Verification**:
- `lake build BimodalLib --wfail` exits 0.
- `grep -rn 'sorry\|native_decide\|^axiom ' BimodalLib` finds nothing.
- A scratch `#print axioms` on one seed shows no `sorryAx`.

---

### Phase 6: Index generation [NOT STARTED]

**Goal**: One named command writes an index of theorem rows, re-proofs and conjectures by
fragment and frame class, with every box law that has no declared diamond dual.

**Tasks**:
- [ ] Create `BimodalLib/Index.lean`: a polarity census per row for `□`/`◇`, `⊡`/`⟐`, `G`/`F`,
  `H`/`P` and always/sometimes, by pattern over the primitives in the shape of
  `extractOperatorProfile` in `BimodalTools/InterestingnessMetrics.lean`; and a command
  `library_index` that walks the constants of type `TheoremEntry`, `ReproofEntry` and
  `Conjecture`, evaluates their fields, and renders Markdown: entries by fragment and frame
  class (rows above Base labelled "stated at"), re-proofs per statement, conjectures with
  status and note, and, per operator pair, the rows whose statement has the universal operator
  and whose `dual` field is empty.
- [ ] Add `(dual := Y)` to registration lines only where the dual is evident from an existing
  declaration and both are registered; the command checks that `Y` has a row. The listing of
  laws with no dual is expected to be long.
- [ ] Create `scripts/library-index.sh`: builds `BimodalLib`, runs the command through a
  one-line driver with `lake env lean`, and writes `BimodalLib/INDEX.md`; with `--check` it
  writes to a temporary file and exits non-zero on a difference. Output is sorted so it is
  stable between runs.
- [ ] Generate and commit `BimodalLib/INDEX.md`. Import `BimodalLib.Index` from
  `BimodalLib.lean`.
- [ ] Run `lake build BimodalLib --wfail` and `bash scripts/library-index.sh --check`.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: `lake build BimodalLib --wfail` and
`bash scripts/library-index.sh --check` cover the edit: one new module, one new script and its
own output.

**Scope Hypothesis**: The report measured `□` only 21, `◇` only 17, both 16; `G` only 63, `F`
only 9, both 10; `H` only 68, `P` only 5, both 5. The `dual :=` link was not prototyped. The
implementer reads the live figures from the generated index and does not edit the index to
match these.

**Files to modify**:
- `BimodalLib/Index.lean` - new
- `scripts/library-index.sh` - new
- `BimodalLib/INDEX.md` - generated
- `BimodalLib.lean` - import
- `BimodalLib/Theorems/Boolean/Base.lean` - `dual :=` links where evident
- `BimodalLib/Theorems/ModalBoolean/Base.lean` - `dual :=` links where evident
- `BimodalLib/Theorems/ModalTemporalBoolean/Base.lean` - `dual :=` links where evident
- `BimodalLib/Theorems/TemporalBoolean/Base.lean` - `dual :=` links where evident

**Verification**:
- `lake build BimodalLib --wfail` exits 0.
- `bash scripts/library-index.sh --check` exits 0 immediately after generation, and exits
  non-zero after a hand edit to `BimodalLib/INDEX.md` (reverted before commit).
- The index has a section per fragment, a frame class within each, and a dual listing per
  operator pair; its total of theorem rows equals the count Phase 3 confirmed.

---

### Phase 7: CI and repository gates [NOT STARTED]

**Goal**: CI compiles the library and its tests with warnings as errors, and the repository's
own checks cover the new tree, including the import direction.

**Tasks**:
- [ ] Capture a baseline before editing: `bash scripts/check-module-invariants.sh --no-build`
  and `bash scripts/verify-all.sh`, output and exit status saved outside the repository tree.
- [ ] In `.github/workflows/ci.yml`, after the `BimodalToolsTest` step, add
  `lake build BimodalLib --wfail`, `lake build BimodalLibTest --wfail`, and
  `bash scripts/library-index.sh --check`; add `BimodalLib` to the roots passed to
  `check-copyright-headers.sh --strict` and `readme-lint.sh`.
- [ ] In `scripts/verify-all.sh`, add `BimodalLib` to the same two invocations and their
  comments.
- [ ] In `scripts/check-module-invariants.sh`: extend B3, or add a sibling check beside it, so
  that no `.lean` under `FormalSystem/` imports `BimodalLib` and the root `FormalSystem.lean`
  does not name it; add `BimodalLib` and `BimodalLibTest` to `LIB_ROOTS`; extend each scan that
  names `BimodalTools/` as a covered tree (B2, C29 to C32, the C7 inventory line) to cover
  `BimodalLib/`. Update the header comments that list what each check covers.
- [ ] Add `BimodalLib` and `BimodalLibTest` to the known-names list in
  `scripts/check-phantom-citations.sh`.
- [ ] Run `lake exe runLinter BimodalLib`. Fix findings at their source, in the generator for
  generated rows. If an exemption is unavoidable, hand-insert the row in `scripts/nolints.json`
  beside an existing row of the same linter; do not run `runLinter --update`.
- [ ] Add any permanent exemption the new files need (for instance C5 on a dotted declaration
  name) to `scripts/module-invariants-allowlist.txt`.
- [ ] Re-run both baseline commands and compare.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: interface

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` and
`bash scripts/verify-all.sh`, compared with the baseline captured at the start of the phase,
cover the edit, which changes what the repository's shared check scripts scan but no Lean
declaration.

**Scope Hypothesis**: That `LIB_ROOTS` occurs once in `scripts/check-module-invariants.sh`, that
the checks naming `BimodalTools/` as a covered tree are the ones listed above, and that
`scripts/nolints.json` and `scripts/module-invariants-allowlist.txt` need no change. Confirm
with `grep -n 'BimodalTools' scripts/check-module-invariants.sh scripts/*.sh .github/workflows/*.yml`
at implementation time and treat every hit as a candidate; the two ledger files stay in scope
whether or not they change.

**Files to modify**:
- `.github/workflows/ci.yml` - three steps, two root lists
- `scripts/verify-all.sh` - two root lists
- `scripts/check-module-invariants.sh` - import direction, `LIB_ROOTS`, covered trees
- `scripts/check-phantom-citations.sh` - known names
- `scripts/nolints.json` - only if an exemption row is unavoidable
- `scripts/module-invariants-allowlist.txt` - only if a permanent exemption is needed
- `BimodalLib/Registry.lean` - generator fixes from the linter run, if any

**Verification**:
- `lake exe runLinter BimodalLib` exits 0.
- `bash scripts/check-module-invariants.sh --no-build`: no finding that names a file under
  `BimodalLib/`, `Tests/BimodalLibTest/` or the scripts this phase edited, and no check that
  passed in the baseline fails now. Findings present in the baseline are listed in the summary
  and are not this phase's to fix.
- The import-direction check fails when a scratch `import BimodalLib` line is added to a file
  under `FormalSystem/` and passes when it is removed; the scratch line is never committed.
- `bash scripts/verify-all.sh`: exit status and failing set no worse than the baseline.
- `bash scripts/check-copyright-headers.sh --strict BimodalLib` and
  `bash scripts/readme-lint.sh BimodalLib` exit 0.

---

### Phase 8: Documentation and the design record [NOT STARTED]

**Goal**: The docs describe the library as it exists, and the design record no longer carries
what is implemented.

**Tasks**:
- [ ] `ORGANISATION.md`: add a row under "Everything else" for `BimodalLib/` and
  `Tests/BimodalLibTest/`.
- [ ] `docs/ARCHITECTURE.md` and `docs/development/MODULE_ORGANIZATION.md`: describe the
  library, its place above `FormalSystem`, its layout, and the registry as kernel-checked rows
  read back from the environment.
- [ ] `docs/development/CI_CD_PROCESS.md`: the new CI steps. `docs/development/MODULE_INVARIANTS.md`:
  the import-direction check and the widened coverage of the checks changed in Phase 7.
- [ ] `BimodalLib/README.md`: how to register a theorem, pair a re-proof, register a conjecture
  and regenerate the index; that a frame class above Base is the class a row is stated at; that
  the dual listing rests on declared links.
- [ ] `Tests/README.md`: the new test library.
- [ ] `records/theorem-library.md`: cut what now exists (the layout and `defaultTargets`
  decision, the registry and pairing paragraphs, the definition of a conjecture and its first
  entries) and leave a pointer to the docs for each; keep what is still design (countermodels,
  the pipeline, diagnostics, the proofs of the edges). `records/proof-mode.md`: bring M18 into
  line with whatever convention the record uses for a milestone that is done; read the record
  for that convention before editing.
- [ ] Deliverables state the current design only: no task numbers, no "previously" or
  "no longer", no version labels. Milestone names in `records/` stay as the record uses them.
- [ ] Run the checks under Verification.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:
- `ORGANISATION.md` - library row
- `docs/ARCHITECTURE.md` - library section
- `docs/development/MODULE_ORGANIZATION.md` - tree and description
- `docs/development/CI_CD_PROCESS.md` - CI steps
- `docs/development/MODULE_INVARIANTS.md` - check table rows
- `BimodalLib/README.md` - usage
- `Tests/README.md` - test library
- `records/theorem-library.md` - implemented parts cut
- `records/proof-mode.md` - M18 status

**Verification**:
- In this dispatch: the scoped touched-path check
  `bash .claude/scripts/verify-touched.sh` over this phase's files, together with
  `lake build BimodalLib --wfail`, `lake build BimodalLibTest --wfail`,
  `bash scripts/library-index.sh --check`, `bash scripts/readme-lint.sh FormalSystem BimodalTools BimodalLib`
  and `bash scripts/check-module-invariants.sh --no-build` compared with the Phase 7 baseline.
  A finding of `verify-touched.sh` that names none of this task's files and comes from a missing
  `agent-system/` fixture is the checkout's standing baseline; it is listed, not fixed.
- The complete gate set is deferred to the orchestration close under `/orchestrate`. In a
  standalone run with no orchestration close, the implementer runs the complete set directly:
  `bash .claude/scripts/verify-deploy.sh`, `lake build`, `lake test`, and
  `bash scripts/verify-all.sh`, each judged against the pre-task commit.
- `grep -n 'BimodalLib' ORGANISATION.md` shows the row.
- `git diff --stat` for the whole task shows no path under `FormalSystem/` and no change to
  `FormalSystem.lean`.

## Lean Challenge Statements

<!-- lean-challenge-statements:none -->

No statement is pinned. The grounds are under Decisions: the one theorem of this task is stated
over definitions the task itself creates, so a challenge module could not type-check against
the tree before implementation.

## Testing & Validation

- [ ] `lake build BimodalLib --wfail` and `lake build BimodalLibTest --wfail` exit 0.
- [ ] `lake build` with no target compiles nothing under `BimodalLib/`.
- [ ] The completeness check fails on the fixture's unregistered derivation and passes once it
  is registered (`Tests/BimodalLibTest/RegistryCheckTest.lean`).
- [ ] The pairing command accepts a correct re-proof and rejects a drifted one
  (`Tests/BimodalLibTest/PairingTest.lean`).
- [ ] A conjecture is registered with no proof term, and no seed depends on `sorryAx`.
- [ ] `bash scripts/library-index.sh` writes `BimodalLib/INDEX.md`, and `--check` detects a
  stale copy.
- [ ] No `sorry`, new `axiom` or `native_decide` under `BimodalLib/`.
- [ ] The import-direction check fails on an `import BimodalLib` under `FormalSystem/`.
- [ ] `lake exe runLinter BimodalLib` exits 0.
- [ ] `ORGANISATION.md` has a row for the library.
- [ ] No path under `FormalSystem/` is changed by the task.

## Artifacts & Outputs

- `BimodalLib.lean`, `BimodalLib/Fragment.lean`, `BimodalLib/Registry.lean`,
  `BimodalLib/Registry/Complete.lean`, `BimodalLib/Pairing.lean`, `BimodalLib/Conjecture.lean`,
  `BimodalLib/Conservativity.lean`, `BimodalLib/Index.lean`
- `BimodalLib/Theorems/<Fragment>/<FrameClass>.lean` (seven files) and
  `BimodalLib/Theorems/Complete.lean`
- `BimodalLib/Conjectures/Conservativity.lean`, `BimodalLib/Conjectures/ModalBoolean/Collapse.lean`
- `BimodalLib/README.md`, `BimodalLib/INDEX.md`
- `Tests/BimodalLibTest.lean` and `Tests/BimodalLibTest/` (three tests, one fixture)
- `scripts/library-index.sh`
- Edits to `lakefile.toml`, `.github/workflows/ci.yml`, `scripts/verify-all.sh`,
  `scripts/check-module-invariants.sh`, `scripts/check-phantom-citations.sh`,
  `typst/generated/status.typ`, `ORGANISATION.md`, four files under `docs/`, `Tests/README.md`,
  and the two records
- `specs/971_theorem_library_layout_and_registry/summaries/01_library-layout-registry-summary.md`

## Rollback/Contingency

Every phase is additive until Phase 7. The library is outside `defaultTargets` and nothing in
`FormalSystem` imports it, so a failed phase leaves the published build as it was. Each phase is
one commit; reverting the task is `git revert` of those commits in reverse order, followed by
`bash scripts/typst-sync-check.sh --fix` to restore the `Tests` counts. If a phase cannot be
made green, fix forward; do not discard uncommitted work to reach a passing build. If a rollback
of uncommitted work is ever needed, follow the rollback rung of
`.claude/context/contracts/recovery.md`, which takes a snapshot first.

If `register_theorem` cannot handle a binder shape found on the live tree, register the
declarations it can handle, list the rest by name in the summary, and leave the phase partial:
the completeness check must not be weakened to pass. If the environment linters cannot be
satisfied by generated docstrings, the fallback is a hand-inserted exemption per linter in
`scripts/nolints.json`, recorded in the summary.
