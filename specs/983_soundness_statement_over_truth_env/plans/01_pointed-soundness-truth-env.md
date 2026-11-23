# Implementation Plan: Task #983

- **Task**: 983 - State pointed soundness once over TruthEnv (milestone D4)
- **Status**: [IMPLEMENTING]
- **Effort**: 3.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/983_soundness_statement_over_truth_env/reports/01_pointed-soundness-truth-env.md
- **Artifacts**: plans/01_pointed-soundness-truth-env.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

TM and TM⁺ each have a context form of soundness (`soundness_in`, `plus_soundness_in`); TM⋆ has only the empty-context validity form. This plan adds `star_soundness_in` beside `star_soundness_validIn`, then states pointed soundness once in a new layer-3 module `FormalSystem/Metalogic/PointedSoundness.lean`: a `Prop`-valued mixin class `PointedSound L D` over `TruthEnv`, three instances (TM, TM⁺, TM⋆), and one generic theorem `truth_of_derivation`. Tests instantiate the generic theorem at all three languages. Done when the done-when of milestone D4 in `records/milestones.md` holds: the TM⋆ case is a new theorem, the statement is made once over `TruthEnv` with each language an instance, and no module restates a language's soundness theorem under another name.

### Research Integration

From `reports/01_pointed-soundness-truth-env.md` (all elaboration claims there are compiled probes, not LSP lookups):

- `star_soundness_in` is `plus_soundness_in` arm for arm with one extra fixed binder `v`; the induction generalizes `τ t` only. The three empty-context rules need nothing new. The full proof text is in the report's Recommendation 1 and compiled with axioms `[propext, Classical.choice, Quot.sound]`.
- The class is a `Prop`-valued mixin over an explicit relation `D : FrameClass → List L → L → Sort u`, base class `TruthEnv` (not `PointTruth`). Class, instances and generic theorem text are in Recommendation 2.
- `e` must be an explicit argument of `truth_of_derivation`; call sites pass `PUnit.unit` (not `⟨⟩`) for TM and TM⁺ and `v` for TM⋆.
- The `assert_not_exists` guard on the four `completeness_*` names elaborates with the three soundness imports.
- No native-vocabulary corollaries are added; the instances are the only place a language theorem is named.

Planner-side confirmation: the sorry-bodied block under "Lean Challenge Statements" below was compiled standalone with `lake env lean` against the built tree during planning (exit 0, two `sorry` warnings only).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` lists this task as ready, with C4 (the semantic mode and its adapter) waiting on it. The plan advances milestone D4 and join 7 of `records/milestones.md`. No roadmap phases are included (`roadmap_flag` not set).

## Goals & Non-Goals

**Goals**:
- `star_soundness_in` -- context form of TM⋆ soundness at one register environment `v`, in `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean`.
- `truth_of_derivation` -- generic pointed soundness over `TruthEnv`, from a derivation, frame-class evidence and truth of the premises, in `FormalSystem/Metalogic/PointedSoundness.lean`.
- The class `PointedSound` with instances at `DerivationTree`, `PlusDerivationTree` and `StarDerivationTree`, carrying one field and no data.
- Sound direction only: the new module is guarded by `assert_not_exists` on `completeness_base`, `completeness_dense`, `completeness_ztime`, `completeness_rtime` and imports nothing under `FormalSystem/Automation/ProofMode/`.
- Tests instantiating `truth_of_derivation` at all three languages.

**Non-Goals**:
- No tactic that applies the statement (that is C4).
- No restatement of `soundness_in`, `plus_soundness_in` or `star_soundness_in` under another name, and no `TruthAt`/`PlusTruthAt`/`StarTruthAt`-typed re-export of the generic theorem.
- No connective or object-level packaging in the class; `proof_mode_abstract_frontend_interface` owns that.
- No `*Derivable` (`Prop`-valued) instance; it is a one-liner C4 can add if it wants it.
- No deduction theorem for TM⋆.
- No edit to any file in the sibling task's scope (`FormalSystem/PlusLanguage/Formula.lean`, `FormalSystem/PlusLanguage/TemporalViews.lean`, `FormalSystem/StarLanguage/Formula.lean`, `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Tactic/FormulaSyntax.lean`).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pre-commit hook refuses a phase commit because `typst/generated/status.typ` drifted (any `.lean` line-count change, including under `Tests/`) | M | H | Every phase that stages a `.lean` file runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in that same phase |
| A sibling task's uncommitted `.lean` edits make the live counts disagree with this task's regenerated `status.typ` | M | M | Re-run `--fix` immediately before the commit. If the hook still refuses and the only disagreeing paths are foreign uncommitted files, stop and report per the dispatch's territory rule; do not edit or stage foreign files |
| C5 of `check-module-invariants.sh` reads `FormalSystem.Metalogic.PointedSound` in a `docs/theorem-index.md` row as an unresolved module path | M | H | Phase 2 adds the permanent exemption entry to `scripts/module-invariants-allowlist.txt` beside the existing `FormalSystem.StarLanguage.StarDerivationTree` entry, in the same phase as the row |
| C15: a theorem-index row whose declaration docstring lacks a `Paper:` line | L | M | Each new indexed declaration's docstring carries a `Paper:` line in the form `plus_soundness_in` uses (formalization-native) |
| C33 / `mk_all --check`: the new module is missing from the generated library root | L | H | Phase 2 runs `lake exe mk_all --lib FormalSystem` and stages `FormalSystem.lean` |
| Module-inventory blocks (`README.md`, `FormalSystem/Metalogic/README.md`) go stale after a file is added or line counts move | L | M | Phases 1 and 2 run `bash scripts/check-module-invariants.sh --emit-inventory` and stage whatever it rewrites |
| A linter warning (CI builds with `--wfail`): `show`, unused variables, missing docstrings on the class or its field | M | M | Treat any warning in a touched module as red. Use no `show`; give the class, its field, each instance and the theorem a docstring; fix forward |
| Red build in `StarSoundness.lean`'s import closure caused by the sibling's in-flight edits to the `Formula.lean` files | M | L | Check `git status` and `git log` for foreign changes before attributing the failure; stop and report a foreign change rather than editing it |
| Higher-order inference of `D` fails at a test call site built from an anonymous constructor | L | M | Name `(D := StarDerivationTree)` at that call site, as the research probe does |
| Documentation rules: a docstring that cites a task number, a branch, or describes the module by contrast with a rejected file | L | M | Docstrings state the current design only; cite `records/milestones.md` and `records/proof-mode-architecture.md` by filename |

## Decisions

- **Module name `FormalSystem/Metalogic/PointedSoundness.lean`, class name `PointedSound`, theorem name `truth_of_derivation`.** The research report left the module name open; none of the three names occurs in the tree.
- **Mixin over a relation parameter, not a class owning the relation.** A class with a data field for the derivation relation also compiles and lets `L` alone determine the instance. It is not used because it would make this class a second owner of each language's derivation relation, which the later object-level interface would then have to reconcile with its own.
- **`D` stays an ordinary parameter, not an `outParam`.** It can be made one later without changing any statement.
- **`v` is not generalized in the `star_soundness_in` induction**, matching the plus proof.
- **Registry and generated-surface updates land in the phase that causes them**, not in a closing phase, because the `status.typ` check blocks the commit of the phase that moves a line count.
- **Lean Challenge Statements declare the class verbatim ahead of the two theorems.** The snapshot tool harvests names from `theorem`/`lemma`/`def`/`instance` only, so the Goals bullets lead with exactly `star_soundness_in` and `truth_of_derivation`; the class is supporting context the second statement needs to type-check, and the challenge module declares the names at root for standalone checking while the tree declares them in `FormalSystem.Metalogic.Conservativity` and `FormalSystem.Metalogic`.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Context form of TM⋆ soundness [COMPLETED]

**Goal**: `star_soundness_in` proved in `StarSoundness.lean` directly after `star_soundness_validIn`, with its registry rows and generated surfaces current.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` immediately before editing (shared working tree).
- [x] Add `star_soundness_in` directly after `star_soundness_validIn`, with the signature in "Lean Challenge Statements" below and the proof from Recommendation 1 of the research report (`induction d generalizing τ t`, seven arms). Use no `show`.
- [x] Give it a docstring with a `Paper:` line in the form `plus_soundness_in`'s docstring uses; state that the register environment is one fixed `v` shared by premises and conclusion.
- [x] Add a `star_soundness_in` bullet to the "Main Results" list of the module docstring.
- [ ] Add a `docs/theorem-index.md` row for `FormalSystem.Metalogic.Conservativity.star_soundness_in` directly after the `star_soundness_validIn` row, following that row's column shape. If the tree's rows for the neighbouring context forms follow a different convention when the file is re-read, follow the file. *(deviation: skipped — every row on that page must be axiom-pinned in the C14 baseline pair inside `scripts/check-module-invariants.sh`, outside this plan's file list and the task file_scope; the neighbouring context forms `soundness_in` and `plus_soundness_in` carry no row, so the file's convention was followed)*
- [x] Confirm axioms: `#print axioms FormalSystem.Metalogic.Conservativity.star_soundness_in` in a scratch file gives `[propext, Classical.choice, Quot.sound]`.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and `bash scripts/check-module-invariants.sh --emit-inventory`; stage what they rewrite among the files listed below. *(deviation: altered — `--emit-inventory` also rewrote `FormalSystem/Metalogic/Conservativity/Star/README.md`, in file_scope; staged, with a hand-added `star_soundness_in` bullet in its results list)*
- [x] Commit this phase's own files by explicit path.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the file list below assumes the two regeneration commands rewrite only `typst/generated/status.typ`, `README.md` and `FormalSystem/Metalogic/README.md`. Confirm with `git status --short` after running them; a rewrite of any other file is recorded and staged only if it is this phase's own drift.

**Tier Justification**: `lake build FormalSystem.Metalogic.Conservativity.Star.StarSoundness` covers the edit, which adds one theorem and changes no existing signature.

**Files to modify**:
- `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` - new theorem `star_soundness_in`, docstring, "Main Results" bullet
- `docs/theorem-index.md` - row for `star_soundness_in`
- `typst/generated/status.typ` - regenerated line counts
- `README.md` - regenerated module-inventory block, if it changes
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory block, if it changes

**Verification**:
- `lake build FormalSystem.Metalogic.Conservativity.Star.StarSoundness` succeeds with no warning in that module.
- `#print axioms` on `star_soundness_in` shows `[propext, Classical.choice, Quot.sound]` and no `sorryAx`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit.
- `star_soundness_validIn` and every other declaration in the file is textually unchanged (`git diff` shows additions only, apart from the docstring list).

---

### Phase 2: One statement over TruthEnv [COMPLETED]

**Goal**: the new module `FormalSystem/Metalogic/PointedSoundness.lean` with the class, three instances, the generic theorem and the completeness guard, wired into the library root and the `Metalogic` aggregator.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/PointedSoundness.lean` with the repository's copyright header and a module docstring stating the current design: one class tying a derivation relation to the `TruthEnv` truth predicate of its language, the three instances, the generic theorem; cite `records/milestones.md` and `records/proof-mode-architecture.md` by filename.
- [x] Imports: exactly `FormalSystem.Metalogic.Soundness`, `FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness`, `FormalSystem.Metalogic.Conservativity.Star.StarSoundness`. Nothing under `FormalSystem/Automation/ProofMode/`.
- [x] Directly after the imports, add the `assert_not_exists` block on `FormalSystem.Metalogic.completeness_base`, `completeness_dense`, `completeness_ztime`, `completeness_rtime`, copied from `FormalSystem/Automation/ProofMode.lean`.
- [x] In `namespace FormalSystem.Metalogic`: the class `PointedSound` (one field `sound`, `Prop`-valued, `D : FrameClass → List L → L → Sort u`), the three instances at `Formula`/`DerivationTree`, `PlusFormula`/`PlusDerivationTree`, `StarFormula`/`StarDerivationTree`, each a one-line application of `soundness_in`, `Conservativity.plus_soundness_in`, `Conservativity.star_soundness_in`, and `truth_of_derivation` with `e` explicit. Text as in Recommendation 2 of the research report.
- [x] Docstrings on the class, its field, each instance and the theorem; `Paper:` lines on the declarations that get a theorem-index row.
- [x] Add no other theorem to the module.
- [x] Run `lake exe mk_all --lib FormalSystem` to regenerate `FormalSystem.lean`.
- [x] Add `import FormalSystem.Metalogic.PointedSoundness` to `FormalSystem/Metalogic.lean` and one entry for it in that aggregator's docstring.
- [ ] Add `docs/theorem-index.md` rows for `FormalSystem.Metalogic.truth_of_derivation` and `FormalSystem.Metalogic.PointedSound`, and add `FormalSystem.Metalogic.PointedSound` to `scripts/module-invariants-allowlist.txt` with a one-line comment that it is a class name, placed beside the `FormalSystem.StarLanguage.StarDerivationTree` entry. If the class is given no row and its dotted name appears in no non-specs markdown, add no allowlist entry. *(deviation: skipped — same cause as Phase 1: a row needs a C14 pin in `scripts/check-module-invariants.sh`, outside the file list and file_scope. The plan's own conditional then applies: the class has no row and its dotted name appears in no non-specs markdown, so no allowlist entry was added)*
- [x] Confirm axioms: `#print axioms FormalSystem.Metalogic.truth_of_derivation` contains no `sorryAx`.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and `bash scripts/check-module-invariants.sh --emit-inventory`; stage what they rewrite among the files listed below. *(deviation: altered — `--emit-inventory` also rewrote `FormalSystem/README.md`, in file_scope; staged. The generated `PointedSoundness.lean` row in `FormalSystem/Metalogic/README.md` got a hand-written description in place of the TODO placeholder)*
- [x] Commit this phase's own files by explicit path.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: the module is estimated at about 60 lines and the allowlist entry is assumed necessary because C5 matches dotted capitalized names in non-specs markdown. Confirm the second by running `bash scripts/check-module-invariants.sh --no-build` after adding the row and reading the C5 line; confirm the regenerated-file set with `git status --short` as in Phase 1.

**Tier Justification**: `lake build FormalSystem.Metalogic.PointedSoundness` plus `lake exe mk_all --lib FormalSystem --check` covers the edit: a new leaf module that no existing module's signature depends on, and two import-only additions to aggregators.

**Files to modify**:
- `FormalSystem/Metalogic/PointedSoundness.lean` - new module: guard, class, three instances, generic theorem
- `FormalSystem.lean` - regenerated library root
- `FormalSystem/Metalogic.lean` - aggregator import and docstring entry
- `docs/theorem-index.md` - rows for `truth_of_derivation` and `PointedSound`
- `scripts/module-invariants-allowlist.txt` - C5 exemption for the class name
- `typst/generated/status.typ` - regenerated file and line counts
- `README.md` - regenerated module-inventory block, if it changes
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory block, if it changes

**Verification**:
- `lake build FormalSystem.Metalogic.PointedSoundness` succeeds with no warning in that module; the `assert_not_exists` block elaborates.
- `lake exe mk_all --lib FormalSystem --check` exits 0.
- `grep -n '^import' FormalSystem/Metalogic/PointedSoundness.lean` shows exactly the three imports named above.
- The module declares exactly one `theorem` (`truth_of_derivation`), one `class` and three `instance`s; none of its declarations has the statement of `soundness_in`, `plus_soundness_in` or `star_soundness_in`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit.

---

### Phase 3: Tests at all three languages [COMPLETED]

**Goal**: a test module that derives native pointed truth from `truth_of_derivation` at TM, TM⁺ and TM⋆, registered in the test aggregator.

**Tasks**:
- [x] Create `Tests/BimodalTest/Metalogic/PointedSoundnessTest.lean` importing `FormalSystem.Metalogic.PointedSoundness`, with the header and docstring shape the neighbouring test modules use.
- [x] One `example` per language closing a native goal (`TruthAt`, `PlusTruthAt`, `StarTruthAt`) from an abstract derivation tree and premises via `truth_of_derivation`, passing `PUnit.unit` for TM and TM⁺ and `v` for TM⋆.
- [x] Two further TM⋆ examples: a register axiom at a point (`StarAxiom.recall_rigid_future` at `FrameClass.Base`, frame evidence by `inferInstance` under `[F.IsRegular]`, with `(D := StarDerivationTree)` named), and a two-premise modus ponens from the context.
- [x] Add `import BimodalTest.Metalogic.PointedSoundnessTest` to `Tests/BimodalTest.lean` beside the other `BimodalTest.Metalogic.*` imports.
- [x] Run `bash scripts/typst-sync-check.sh --fix`; stage `typst/generated/status.typ`.
- [x] Commit this phase's own files by explicit path.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: five examples, of the shapes the research probe compiled. The count is a floor for coverage of the three languages, not a ceiling; confirm each language has at least one example by reading the file.

**Tier Justification**: `lake build BimodalTest.Metalogic.PointedSoundnessTest` covers the edit, a new leaf test module plus one import line in the test aggregator.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/PointedSoundnessTest.lean` - new test module
- `Tests/BimodalTest.lean` - aggregator import
- `typst/generated/status.typ` - regenerated test-tree counts

**Verification**:
- `lake build BimodalTest.Metalogic.PointedSoundnessTest` succeeds with no warning in that module.
- The file contains at least one `truth_of_derivation` example at each of `Formula`, `PlusFormula` and `StarFormula`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before the commit.

---

### Phase 4: Gate sweep and done-when check [NOT STARTED]

**Goal**: the repository's gates observed on this task's touched files, the D4 done-when checked line by line, and any drift in this task's own generated surfaces repaired.

**Tasks**:
- [ ] `lake build FormalSystem.Metalogic BimodalTest` (the two aggregators that now import the new modules); no warning attributable to a file this task touched.
- [ ] `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/check-metalogic-cycles.sh`. Judge each as a delta: every finding that names a file this task touched is fixed; a finding that names only files outside this task's file list is recorded as pre-existing with its text, and is not edited.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check`, `lake exe mk_all --lib FormalSystem --check`, `bash scripts/typst-sync-check.sh --counts-only`. Repair drift in this task's own surfaces with the matching writer command and commit it.
- [ ] `bash scripts/check-copyright-headers.sh` on the two new files, if the script accepts a path; otherwise read its verdict for those two files from a bare run.
- [ ] Done-when check against `records/milestones.md` D4: (a) `star_soundness_in` exists beside `star_soundness_validIn`; (b) `PointedSound` has instances at all three languages; (c) `grep -rn 'soundness_in' FormalSystem/Metalogic/PointedSoundness.lean` shows the language theorems only inside the three instance bodies; (d) the module imports nothing under `FormalSystem/Automation/ProofMode/` and carries the `assert_not_exists` guard.
- [ ] Exact-name sweep: `grep -rn 'sorry' ` over the three touched `.lean` source files returns nothing.
- [ ] Record in the phase's verification notes that the complete gate set is deferred to the orchestration close.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Files to modify**:
- `typst/generated/status.typ` - only if drift in this task's own counts remains
- `README.md` - only if this task's inventory drift remains
- `FormalSystem/Metalogic/README.md` - only if this task's inventory drift remains
- `FormalSystem.lean` - only if the library root is stale

**Verification**:
- Under `/orchestrate`, this phase's own in-dispatch obligation is the scoped touched-path check: the commands in the task list above, each scoped to or judged against this task's touched files. `bash .claude/scripts/verify-touched.sh` maps no suite to these Lean, docs and generated paths, so the repository's own checks named above are run directly as the scoped discharge. The complete gate set is deferred to the orchestration close, not run independently here.
- In a standalone, non-orchestrated run, this phase instead runs the complete set directly: a full `lake build`, a bare `bash scripts/check-module-invariants.sh`, `bash scripts/check-metalogic-cycles.sh`, a bare `bash scripts/typst-sync-check.sh`, and `bash .claude/scripts/verify-deploy.sh`.
- All four D4 done-when checks (a) to (d) hold.

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Soundness
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
import FormalSystem.Metalogic.Conservativity.Star.StarSoundness

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.StarLanguage FormalSystem.Semantics FormalSystem.Metalogic

universe u

class PointedSound (L : Type) [TruthEnv L] (D : FrameClass → List L → L → Sort u) : Prop where
  sound : ∀ {fc : FrameClass} {Γ : List L} {φ : L}, D fc Γ φ →
    ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
      (e : TruthEnv.Env L F), (∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) → TruthEnv.T M τ t e φ

theorem star_soundness_in {fc : FrameClass} (Γ : StarContext) (φ : StarFormula)
    (d : StarDerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (t : F.Duration) (v : ℕ → F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, StarTruthAt M τ t v ψ) :
    StarTruthAt M τ t v φ := sorry

theorem truth_of_derivation {L : Type} [TruthEnv L] {D : FrameClass → List L → L → Sort u}
    [PointedSound L D] {fc : FrameClass} {Γ : List L} {φ : L} (d : D fc Γ φ)
    {F : TaskFrame} (hF : fc.Sat F) {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (e : TruthEnv.Env L F) (h : ∀ ψ ∈ Γ, TruthEnv.T M τ t e ψ) : TruthEnv.T M τ t e φ := sorry
```

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.Conservativity.Star.StarSoundness FormalSystem.Metalogic.PointedSoundness BimodalTest.Metalogic.PointedSoundnessTest` succeeds with no warning in those three modules
- [ ] `#print axioms` on `star_soundness_in` gives `[propext, Classical.choice, Quot.sound]`; on `truth_of_derivation`, no `sorryAx`
- [ ] The `assert_not_exists` guard in `PointedSoundness.lean` elaborates
- [ ] `truth_of_derivation` closes a native pointed-truth goal at `Formula`, `PlusFormula` and `StarFormula` in the test module
- [ ] `bash scripts/check-module-invariants.sh --no-build` and `bash scripts/check-metalogic-cycles.sh` report no finding that names a file this task touched
- [ ] `lake exe mk_all --lib FormalSystem --check`, `bash scripts/check-module-invariants.sh --emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only` exit 0, or their only remaining findings are attributable to foreign uncommitted files and are recorded as such

## Artifacts & Outputs

- `FormalSystem/Metalogic/Conservativity/Star/StarSoundness.lean` - `star_soundness_in`
- `FormalSystem/Metalogic/PointedSoundness.lean` - `PointedSound`, three instances, `truth_of_derivation`
- `Tests/BimodalTest/Metalogic/PointedSoundnessTest.lean` - tests at three languages
- Registry updates: `FormalSystem.lean`, `FormalSystem/Metalogic.lean`, `Tests/BimodalTest.lean`, `docs/theorem-index.md`, `scripts/module-invariants-allowlist.txt`
- Generated surfaces: `typst/generated/status.typ`, inventory blocks in `README.md` and `FormalSystem/Metalogic/README.md`
- `specs/983_soundness_statement_over_truth_env/summaries/01_pointed-soundness-truth-env-summary.md`

## Rollback/Contingency

Every change is additive: one theorem appended to an existing file, two new files, import lines and registry rows. Each phase is its own commit, so a phase is undone by `git revert` of that commit followed by re-running `bash scripts/typst-sync-check.sh --fix`, `bash scripts/check-module-invariants.sh --emit-inventory` and `lake exe mk_all --lib FormalSystem`. On a build error, fix forward. No step in this plan discards uncommitted work; if a genuine rollback of uncommitted changes becomes necessary, follow the rollback rung of `.claude/context/contracts/recovery.md` and never revert the shared tree while a sibling task has uncommitted edits.

If the proof of `star_soundness_in` fails in some arm despite the compiled probe (for instance after a sibling's edit to `FormalSystem/StarLanguage/Formula.lean` lands), Phase 1 stops as `[PARTIAL]` with the failing arm and goal recorded; Phases 2 and 3 do not start, because the TM⋆ instance needs the theorem.
