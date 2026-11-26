# Implementation Plan: Task #977

- **Task**: 977 - connective_signature_layer_shared_primitives
- **Status**: [COMPLETED]
- **Effort**: 12.5 hours
- **Dependencies**: Split. Phases 1-6 depend on nothing outside this plan: the temporal contribution (PR #8, branch `feat/proof-mode-temporal`) edits no file they touch, which was checked at its head `5ecc91d63` -- that branch names no clause class, no `TruthClauses.*` operator, and neither `FormalSystem/Syntax/Formula.lean` nor `FormalSystem/PlusLanguage/Formula.lean`. The two `TemporalViews` tasks of Phase 5, and Phases 7-9 whole, depend on that contribution being merged to `main`, because they absorb its interval operators and repoint its view rows.
- **Research Inputs**: specs/977_connective_signature_layer_shared_primitives/reports/01_connective-signature-layer.md
- **Artifacts**: plans/01_connective-signature-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`Formula`, `PlusFormula` and `StarFormula` each restate the same derived operators, and
`Semantics/TruthClauses.lean` defines them a further time over the clause classes. This plan adds
a layer-0 signature module (one class per primitive operator, the derived operators written once
as `abbrev`s), makes every formula type an instance, generates the per-language definition bodies
from the signature so that no stored body changes, and restates the clause classes as `Prop`
mixins over the signature. The interval operators and the `next`/`prev` encoding get their one
definition on the signature, and operator recognition in `Tactic/FormulaSyntax.lean` reads the
signature so that it reaches L⋆. Done when `lake build`, `lake test` and `scripts/verify-all.sh`
are green and each derived-operator encoding appears once.

The plan lands in two parts. Phases 1-6 build the signature, the instances, the generated bodies
and the clause-class restatement, and run against `main` as it stands. Phases 7-9, with two tasks
of Phase 5, wait on the temporal contribution, since they are the parts that absorb its interval
operators and repoint its view rows; doing them first would mean rewriting those rows onto a
signature their author has not seen.

### Research Integration

The plan follows the report's ten recommendations. The ones that shape the phases:

- Option (i) for the first question: the signature sits at layer 0 and `TruthClauses.lean` loses
  its operator `abbrev`s to it (Phases 2 and 6).
- Clause classes become `Prop`-valued mixins over the signature, not `extends` (Phase 6).
- A per-language name is never defined as the bare signature operator; its body is generated in
  constructor form by a `sig%` elaborator (Phases 3 and 5). Prototype 2 found 63 of 63 generated
  bodies `Expr`-equal to the tree's.
- No per-language definition becomes `abbrev` (Phase 9 records the assessment).
- `reflectTime` and the other recursions on the inductive stay per language.

**Premise re-validation (carried figures checked at plan time, 2026-11-23).**

| Carried claim | Source | Live result |
|---|---|---|
| "Eighteen derived operators" doubled | task description | The description's own list has 17 names; the report measured 17. Corrected to 17, of which `reflectTime` is out of scope. |
| `TemporalIntervals.lean` "arrives with branch feat/pointed-semantic-lemmas" | task description | Re-derived: the file is on `main` (105 lines, six `*_iff` theorems), merged by `72de818a4`. |
| The temporal contribution has not merged | task description, report | Re-derived: PR #8 is open and `CONFLICTING`; `FormalSystem/PlusLanguage/TemporalViews.lean` and `FormalSystem/Tactic/TemporalFormulaViews.lean` are absent from `main`. Implementation still waits. |
| Clause-class rebase "confined to six library files and eight instance sites" | report | Re-derived differently: clause-class names occur in 19 tracked Lean files under `FormalSystem/` and `Tests/` (list in Phase 6). `GenericSchemata.lean` lives at `FormalSystem/Metalogic/SoundnessLemmas/`, and is 1440 lines, 60 below the `longFile` ceiling. |
| 8 `TruthEnv` instance sites | report | Re-derived: 7 language sites plus the `Toy` site in `ValidityLayerTest.lean`. Confirmed. |
| 63 of 63 generated bodies identical; 749 unfold sites; 7488 references | report | CARRIED-UNVERIFIED (report 01). Phase 1 re-runs the body comparison on the merged tree; the two reference counts are context only and drive no step. |
| `Language.operatorName` is a table of 20 name pairs | report | CARRIED-UNVERIFIED (report 01). Phase 8 reads the table before replacing it. |
| The temporal contribution defines eleven operators in `TemporalViews.lean` and registers 20 view rows | task description, report (head `5ecc91d63`) | CARRIED-UNVERIFIED; the branch is to be rebased by its author. Phase 1 re-counts on the merged tree. |

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied with this dispatch. The task is milestone D1 (Signature layer) of
`records/milestones.md`, and is a prerequisite of D2 (`proof_mode_abstract_frontend_interface`).

## Goals & Non-Goals

**Goals**:
- A signature module under FormalSystem/Syntax with one class per primitive operator (bot, imp, box, untl, snce, stab, allFuture, allPast) and every derived operator defined once over those classes.
- Signature instances for all nine formula types, with Formula, PlusFormula, StarFormula and USForm taking their derived-operator bodies from the signature by generation.
- The six interval operators (inclusive Until and Since, Release, Trigger, weak Until and Since) defined once on the signature, with the six clause lemmas of TemporalIntervals.lean stated about them.
- One next and prev encoding across Formula, PlusFormula, StarFormula, USForm and the semantic rules.
- Clause classes of TruthClauses.lean restated as Prop mixins over the signature.
- Operator recognition in Tactic/FormulaSyntax.lean driven by the signature, reaching L⋆.
- A recorded reducibility assessment in the architecture record.

**Non-Goals**:
- Changing the primitive set of any language, or adopting primitive diamond, allFuture or allPast for TM or TM+.
- Parameterizing any formula type over the atom type.
- Making any per-language definition reducible.
- Removing the per-language recursions (reflectTime, complexity, modalDepth, atoms).
- Regenerating the derived-operator bodies of OpenFormula, HybridFormula, QuantFormula, NomicFormula and MinusFormula; they receive instances only.
- Declaring notation on the signature.
- The object-level interface class of the proof mode.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The temporal contribution lands with a changed `TemporalViews.lean`, so the operator and row counts differ | M | M | Phase 1 re-counts and re-runs the body comparison on the merged tree before any edit; later phases read Phase 1's recorded figures, not this plan's |
| A generated body differs from the stored one, breaking `simp`/`rw`/`unfold` sites far downstream | H | L | Phase 3's generator raises when a signature constant survives in its output; Phase 3's test pins each body to a literal term; Phase 5 ends on a whole-library build |
| Definition order: the generator rewrites `Sig.neg` to `T.neg` only if `T.neg` already exists | M | M | Phase 5 keeps each file's current definition order and relies on the raise above to catch a violation at the definition site |
| The mixin rebase leaves the tree red between files | H | H | Phase 6 is one `atomic-batch` phase; nothing is committed until the whole library builds |
| `GenericSchemata.lean` (1440 lines) crosses the 1500-line `longFile` ceiling when binders are added | M | M | Phase 6 measures the file after the edit and, if it crosses, baselines it with `set_option linter.style.longFile N` at the value the linter names |
| Every `.lean` line-count change trips the commit-blocking `typst/generated/status.typ` check | M | H | Each phase that edits Lean runs `bash scripts/typst-sync-check.sh --fix` and `bash scripts/check-module-invariants.sh --emit-inventory` before its commit and stages the results |
| Two instance paths to one operator | M | L | Mixin form only; no clause class `extends` a signature class |
| L⁻ derives `someFuture` from a primitive `allFuture`, the reverse of the other languages | L | M | The signature carries both forms under distinct names (`someFuture'`, `somePast'`, `always'`), as `TruthClauses.lean` does now |
| `--wfail` CI turns any new linter warning into a failure (`show`, unused variables, unused arguments) | M | M | No `show` to exploit definitional equality: a named `rfl` lemma instead; `scripts/warning-budget.py` checked in Phase 9 as a delta |

## Decisions

- **No theorem deliverable is pinned.** The work is definitions, instances, an elaborator and
  restatements of six existing lemmas whose new statements mention classes this plan itself
  creates, so no statement can be written as a standalone Challenge module before Phase 2 exists.
  The `## Lean Challenge Statements` section therefore carries the zero-goal marker. The fidelity
  check that replaces it is structural: Phase 3's literal-body test and the `rfl` rows of Phase 7.
- **Operators live in namespace `FormalSystem.Syntax.Sig`; classes are `HasBot`, `HasImp`,
  `HasBox`, `HasUntl`, `HasSnce`, `HasStab`, `HasAllFuture`, `HasAllPast` in
  `FormalSystem.Syntax`.** Spelling follows the constructors (`untl`, `snce`), not cslib's
  `HasUntil`/`HasSince`, so a class name and its constructor read alike.
- **Derived operators are functions over the primitive classes, not defaulted class fields.** A
  defaulted field can be overridden by an instance, so the class would not fix the encoding.
- **Per-language names stay, as `def`s with generated bodies.** They carry dot notation, the
  notation declarations and the docstrings, and existing references name them.
- **Five languages get instances without regenerated bodies.** Prototype 2 measured `Formula`,
  `PlusFormula`, `StarFormula` and `USForm` only. Regenerating the other five without that
  measurement is outside what the research verified; the summary records it as follow-up work.
- **`HasStab` is its own class** whatever the stability-family investigation concludes; that
  ruling concerns which rule family `⊡` files under.
- **The mixin rebase is one atomic batch.** The classes, their eight instance sites and their
  generic clients cannot be changed one file at a time with a green tree in between.

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
| 9 | 9 | 8 |

The plan is sequential: every phase that edits Lean regenerates `typst/generated/status.typ` and
the inventory blocks, so no two phases can share a wave without colliding on those files.

### Phase 1: Landing Gate and Merged-Tree Baseline [COMPLETED]

**Goal**: Baseline the tree as it stands, re-measure every figure Phases 2-6 act on, and record whether the temporal contribution has merged.

**Tasks**:
- [x] Record whether `FormalSystem/PlusLanguage/TemporalViews.lean` and `FormalSystem/Tactic/TemporalFormulaViews.lean` exist on `main`. Their absence does NOT block this phase, and does not block Phases 2-6: those phases touch no file the temporal contribution edits. It gates only the two `TemporalViews` tasks of Phase 5 and the whole of Phases 7-9. Note which case holds and carry it forward. *(completed 2026-11-25: BOTH files are present. PR #8 merged at 2026-11-25T00:46:14Z as `72a375eea`, which is `origin/main` and an ancestor of the working branch `dev/m7-ladder-continuation` at `773b0ca6b`; the local `main` ref is stale at `f58325714` and lacks them. `TemporalViews.lean` is 222 lines, `TemporalFormulaViews.lean` 46. Consequence: the two `TemporalViews` tasks of Phase 5 and Phases 7-9 are no longer waiting on a merge.)*
- [x] Run `lake build` and `lake test` on the unmodified tree; record pass/fail and any pre-existing warning. *(completed: `lake build` exit 0, "Build completed successfully (3027 jobs)", 0 `error:` and 0 `warning:` lines; `lake test` exit 0, 0 `error:` and 0 `warning:` lines. Both through `lake-build-guard.sh` at `773b0ca6b`.)*
- [x] Record baselines for the delta criteria of later phases: `python3 scripts/warning-budget.py` output, `bash scripts/check-module-invariants.sh` exit status and findings, `bash scripts/check-metalogic-cycles.sh` exit status. *(completed: `warning-budget.py` exit 0, "0 warning(s) across 0 file(s)", 1317 traces. `check-metalogic-cycles.sh` exit 0. `check-module-invariants.sh` exit 1 with 55 PASS lines and 2 FAIL lines, both pre-existing and outside this plan: C14 axiom sets diverged (the baseline expects a row for `RaySummary.exists_kappa_collision_cellAt_ne_at_K4_clip` that the tree does not produce) and C16 other-roots env_linter (6 entries above `scripts/c16-roots-baseline.txt`, in `BimodalLibTest.DiagnosticsTest`, `BimodalTest.Automation.ProofModeTemporalTest` and four `BimodalTools` modules). Later phases gate on no finding beyond these two.)*
- [x] Copy `prototypes/02_generated-bodies.lean.txt` to a scratch `.lean` file outside the tracked tree and run it with `lake env lean`. Record, per type, how many bodies are `Expr`-equal. Extend the comparison list with the operators `TemporalViews.lean` defines only if that file is on `main`; otherwise record the extension as owed to Phase 7. *(completed: 63 of 63 identical -- `Formula` 20 of 20, `PlusFormula` 17 of 17, `StarFormula` 16 of 16, `USForm` 10 of 10. Extension run with `TemporalViews.lean` imported: `Formula` 5 of 5 (`strongRelease`, `strongTrigger`, `before`, `inclusiveUntil`, `inclusiveSince`) and `PlusFormula` 9 of 9 (`release`, `trigger`, `weakUntil`, `weakSince`, `strongRelease`, `strongTrigger`, `before`, `inclusiveUntil`, `inclusiveSince`), 77 of 77 in all. No body is handed to Phase 5 as hand-written. The prototype emits one deprecation warning, `Lean.levelZero` -> `Lean.Level.zero`, which Phase 3 must not carry into the tree under `--wfail`.)*
- [x] Count the entries of `Language.operatorName` and record it. Count the operator definitions in `TemporalViews.lean` and the view rows in `TemporalFormulaViews.lean` only if those files are on `main`; otherwise record both counts as owed to the phase that first needs them (7 and 8 respectively). *(completed: `Language.operatorName` has 20 entries -- 18 TM/TM+ pairs and 2 TM+-only (`stab`, `dstab`). `TemporalViews.lean` has 11 operator definitions (9 on `PlusFormula`, 2 on `Formula`). `TemporalFormulaViews.lean` has 20 `register_lview` rows, 10 per language. All three carried figures confirmed.)*
- [x] Check whether the report of `investigate_stability_as_modal_family` exists; if it does, read it and note any consequence for `HasStab` (the Decisions entry stands unless it shows `stab` is not a primitive). *(completed: the task directory is archived at `specs/archive/970_investigate_stability_as_modal_family/` and its record is `docs/development/stability-operator-family.md`. Verdict: one family, `⊡` in Modal, one `HasBox` per formula type. `stab` remains a primitive constructor, so the Decisions entry stands: `HasStab` is the operator-carrying class. The consequence for Phase 2 is a limit, not a change: no bundle or family class for stability apart from the modal one, and `dstab` is filed with the modal derived operators.)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: This phase edits no tracked file; `lake build` and `lake test` on the unmodified tree are the covering check, run as a baseline and not as a gate on an edit.

**Scope Hypothesis**: The report's figure of 63 of 63 identical generated bodies (20 `Formula`, 17 `PlusFormula`, 16 `StarFormula`, 10 `USForm`) is carried from report 01 and was measured before the temporal contribution merged; the eleven operators and 20 view rows are carried from head `5ecc91d63`. Confirm each by the re-run and the counts above. Any body that is not identical is listed by name and handed to Phase 5 as a definition to leave hand-written.

**Files to modify**:
- None planned; this phase reads and measures only.

**Verification**:
- Whether the two temporal modules are on `main` is recorded, with the consequence for Phase 5's two deferred tasks and for Phases 7-9. Their absence is not a block.
- The phase notes hold the build and test result, the three gate baselines, the per-type body-comparison result and the three counts.

---

### Phase 2: Signature Module [COMPLETED]

**Goal**: One layer-0 module holding the primitive-operator classes and every derived operator, defined once.

**Tasks**:
- [x] Create `FormalSystem/Syntax/Connectives.lean` importing `FormalSystem.Init` only, with the repository's copyright header and a module docstring stating the design: one class per primitive, derived operators as functions over the classes, no notation, no defaulted fields.
- [x] Declare the classes `HasBot`, `HasImp`, `HasBox`, `HasUntl`, `HasSnce`, `HasStab`, `HasAllFuture`, `HasAllPast`, each with the one operator field and a docstring.
- [x] In namespace `Sig`, define as `abbrev`s, each over the weakest class set that types it: `neg`, `top`, `and`, `or`, `diamond`, `someFuture`, `allFuture`, `kPlus`, `after`, `somePast`, `allPast`, `kMinus`, `always`, `sometimes`, `dstab`, `someFuture'`, `somePast'`, `always'`, `next`, `prev`. Bodies are the ones `TruthClauses.lean` and `TemporalRules.lean` state now, with `ImpClause.imp` read as `HasImp.imp` and so on; `sometimes` takes the body `Formula.sometimes` has.
- [x] Define the six interval operators: `inclusiveUntil` and `inclusiveSince` guard first, with the bodies `TemporalIntervals.inclusiveUntil_iff` and `inclusiveSince_iff` are stated about; `release`, `trigger`, `weakUntil`, `weakSince` event first, agreeing with `Formula.release`, `Formula.trigger`, `Formula.weakUntil` and `Formula.weakSince`. Carry the argument-order note of `Formula.release` into the docstrings.
- [x] Add the module to `FormalSystem/Syntax.lean`; run `lake exe mk_all --lib FormalSystem` and confirm the library root lists it.
- [x] Run `lake build FormalSystem.Syntax.Connectives`. *(deviation: altered — also ran a full `lake build` as the phase-end gate: exit 0, 3028 jobs, 0 errors, 0 warnings)*
- [x] Run `bash scripts/typst-sync-check.sh --fix` and `bash scripts/check-module-invariants.sh --emit-inventory`; stage the regenerated files with the phase commit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: The phase adds one module nothing yet imports beyond the aggregator; `lake build FormalSystem.Syntax.Connectives FormalSystem.Syntax` covers it.

**Scope Hypothesis**: Twenty operators plus six interval operators, 26 `abbrev`s, in a file of roughly 200 lines. The inventory regeneration is expected to rewrite `README.md`, `FormalSystem/README.md` and `FormalSystem/Syntax/README.md`; the real set is whatever `--emit-inventory` changes, confirmed by `git status` after the run, and every file it changes is staged.

**Files to modify**:
- `FormalSystem/Syntax/Connectives.lean` - new: classes and derived operators
- `FormalSystem/Syntax.lean` - import the new module
- `FormalSystem.lean` - regenerated library root
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `FormalSystem/Syntax/README.md` - regenerated inventory block

**Verification**:
- `lake build FormalSystem.Syntax.Connectives FormalSystem.Syntax` exits 0 with no warning.
- The module's import list is `FormalSystem.Init` alone.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 and `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- No `notation`, `infix`, `prefix` or `postfix` command appears in the module.

---

### Phase 3: Body Generator and Its Gate Test [COMPLETED]

**Goal**: A `sig%` term elaborator that turns a signature operator applied at a concrete formula type into the constructor-form body, with a test that fixes its output.

**Tasks**:
- [x] Create `FormalSystem/Syntax/ConnectivesElab.lean` importing `FormalSystem.Syntax.Connectives` and the Lean meta modules it needs. Port `oneLayer` from `prototypes/02_generated-bodies.lean.txt`: delta-unfold the head signature operator once, replace each remaining `Sig.op` application at type `T` by `T.op` when that constant exists, reduce each class projection of an instance to the constructor. *(deviation: altered — a class projection is reduced with `whnf` at instance transparency in place of the prototype's `whnfCore`/`unfoldDefinition?` sequence; a per-type name replaces `Sig.op` only when the two are definitionally equal on the arguments, otherwise an error names both)*
- [x] Add the check the prototype lacks: after generation, traverse the result and raise an error naming the surviving constant if any `Sig.*` operator or `Has*` projection remains.
- [x] Register the `sig%` term syntax so `def T.op (φ : T) : T := sig% Sig.op φ` elaborates to the generated body. *(deviation: altered — `sig%` also rejects a term whose head is not a `Sig` operator)*
- [x] Create `Tests/BimodalTest/Syntax/ConnectivesTest.lean` with a small toy inductive (bot, imp, box, untl, snce constructors) and its instances, and for each of the 26 signature operators an `example` asserting the generated body equals a literal constructor term by `rfl`, plus a check that the stored body contains no signature constant. *(deviation: altered — two toy inductives, not one: `Toy` adds `atom` and `stab` for `dstab`, and `Tense` carries primitive `allFuture`/`allPast` for the three primed operators, which cannot share a type with the Until-derived `allFuture`; three `#print` rows under `#guard_msgs` pin the one-layer form)*
- [x] Add one negative test: a definition generated before the per-type name it needs exists must raise, captured with `#guard_msgs`. *(deviation: altered — four negative tests: missing per-type name, disagreeing per-type name, and two non-signature heads)*
- [x] Add the test module to `Tests/BimodalTest.lean`.
- [x] Run `lake build FormalSystem.Syntax.ConnectivesElab BimodalTest.Syntax.ConnectivesTest`, then the regeneration pair (`typst-sync-check.sh --fix`, `check-module-invariants.sh --emit-inventory`) and `lake exe mk_all --lib FormalSystem`. *(deviation: altered — a full `lake build` and `lake build BimodalTest` were also run as the phase-end gate)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: The elaborator has no client yet except its own test; `lake build FormalSystem.Syntax.ConnectivesElab BimodalTest.Syntax.ConnectivesTest` covers both new modules.

**Scope Hypothesis**: The elaborator is about 20 lines in the prototype and is expected to be under 80 with the survival check and syntax registration. The test module path `BimodalTest.Syntax.ConnectivesTest` assumes the test library's module names mirror `Tests/BimodalTest/`; confirm against `lakefile.toml` and an existing import line in `Tests/BimodalTest.lean` before naming the build target.

**Files to modify**:
- `FormalSystem/Syntax/ConnectivesElab.lean` - new: `sig%` elaborator with survival check
- `FormalSystem/Syntax.lean` - import the new module
- `FormalSystem.lean` - regenerated library root
- `Tests/BimodalTest/Syntax/ConnectivesTest.lean` - new: literal-body gate test
- `Tests/BimodalTest.lean` - import the test module
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `FormalSystem/Syntax/README.md` - regenerated inventory block

**Verification**:
- Both build targets exit 0 with no warning.
- Every one of the 26 literal-body examples closes by `rfl`; the negative test's `#guard_msgs` matches.
- `bash scripts/typst-sync-check.sh --counts-only` and `--emit-inventory --check` exit 0.

---

### Phase 4: Signature Instances for the Nine Formula Types [COMPLETED]

**Goal**: Every formula type is an instance of the primitive classes it has constructors for. No definition body changes.

**Tasks**:
- [x] In each syntax file, import `FormalSystem.Syntax.Connectives` and declare the instances directly after the inductive, each field the constructor itself: `Formula` (bot, imp, box, untl, snce), `PlusFormula` (those five and stab), `StarFormula`, `OpenFormula`, `HybridFormula`, `QuantFormula`, `NomicFormula`, `MinusFormula` (bot, imp, box, allFuture, allPast), `USForm`. Give each type exactly the classes its constructors support; read each inductive before writing its instances. *(completed: all nine inductives read; class lists as stated, with `StarFormula`, `OpenFormula`, `HybridFormula` at bot, imp, box, untl, snce, stab; `QuantFormula`, `NomicFormula` at bot, imp, box, untl, snce; `USForm` at bot, imp, untl, snce. All nine types are declared at the listed paths.)*
- [x] Confirm `SeparationZ/Syntax.lean` can import the signature without a new upward import: the signature imports `FormalSystem.Init` only. *(completed: `Connectives.lean` imports `FormalSystem.Init` only; `check-metalogic-cycles.sh` exit 0)*
- [x] Run `lake build` on the nine syntax modules. *(deviation: altered — besides the scoped build (exit 0, 722 jobs, 0 warnings), a full `lake build` (3029 jobs) and `lake build BimodalTest` (3113 jobs) were run as the phase-end gate; both exit 0 with 0 errors and 0 warnings)*
- [x] Run `bash scripts/check-metalogic-cycles.sh` and compare with the Phase 1 baseline. *(completed: exit 0, as the Phase 1 baseline)*
- [x] Run the regeneration pair and stage the results. *(deviation: altered — `--emit-inventory` rewrote the line-count rows of eleven READMEs, not the two listed: `README.md`, `FormalSystem/Syntax/README.md`, the READMEs of the seven language directories besides `Syntax`, `FormalSystem/Metalogic/README.md` and `FormalSystem/Metalogic/Expressiveness/README.md`; `FormalSystem/README.md` was not changed. `--counts-only` and `--emit-inventory --check` exit 0.)*

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: interface

**Tier Justification**: The phase adds instances and one import to nine modules without changing any existing declaration; `lake build` of those nine modules plus `bash scripts/check-metalogic-cycles.sh` covers the new import edges, and the whole-library build of Phase 5 observes the dependents.

**Scope Hypothesis**: Nine formula types in nine files, as the report lists them. The constructor sets of `OpenFormula`, `HybridFormula`, `QuantFormula`, `NomicFormula` and `MinusFormula` were not read at plan time; the class list per type is confirmed by reading each inductive. The five files below whose paths end in `Formula.lean` under `OpenLanguage`, `HybridLanguage`, `QuantLanguage`, `NomicLanguage` and `MinusLanguage` are named from the report's type list; if a type is declared in a differently named file, edit that file and record the path in the phase notes. Inventory READMEs changed are whatever `--emit-inventory` rewrites.

**Files to modify**:
- `FormalSystem/Syntax/Formula.lean` - import and instances
- `FormalSystem/PlusLanguage/Formula.lean` - import and instances
- `FormalSystem/StarLanguage/Formula.lean` - import and instances
- `FormalSystem/OpenLanguage/Formula.lean` - import and instances
- `FormalSystem/HybridLanguage/Formula.lean` - import and instances
- `FormalSystem/QuantLanguage/Formula.lean` - import and instances
- `FormalSystem/NomicLanguage/Formula.lean` - import and instances
- `FormalSystem/MinusLanguage/Formula.lean` - import and instances
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Syntax.lean` - import and instances
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block

**Verification**:
- `lake build` of the nine syntax modules exits 0 with no warning.
- `bash scripts/check-metalogic-cycles.sh` exits with the Phase 1 baseline status; no new upward import edge.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 5: Generated Bodies for L, L+, L⋆ and USForm [COMPLETED]

**Goal**: The derived operators of `Formula`, `PlusFormula`, `StarFormula` and `USForm` take their bodies from the signature. Each stored body is unchanged. The operators of `TemporalViews.lean` are the two deferred tasks below, and are done at Phase 7 if that file is not yet on `main`.

**Tasks**:
- [x] In `FormalSystem/Syntax/Formula.lean`, import `FormalSystem.Syntax.ConnectivesElab` and rewrite each non-recursive shared operator and `release`, `trigger`, `weakUntil`, `weakSince` as `def Formula.op … := sig% Sig.op …`, keeping `def`, the docstring, the attributes and the position in the file. Skip any operator Phase 1 listed as not identical. *(completed: 20 definitions rewritten; before the edit the shipped generator was compared with each stored body and all 20 were `Expr`-equal; none skipped)*
- [x] Do the same in `FormalSystem/PlusLanguage/Formula.lean` (the shared operators and `dstab`), `FormalSystem/StarLanguage/Formula.lean`, and `SeparationZ/Syntax.lean` (its `next`, `prev` and the other operators Phase 1 found identical). *(completed: 17, 16 and 10 definitions; all `Expr`-equal to the stored bodies before the edit. `SeparationZ/Syntax.lean` imports `FormalSystem.Syntax.ConnectivesElab` directly and names `Sig` in full, since it does not open `FormalSystem.Syntax`)*
- [x] DEFERRED until the temporal contribution is on `main`: in `FormalSystem/PlusLanguage/TemporalViews.lean`, regenerate the operator definitions the same way, leaving every `*_expand` lemma as written. If the file is absent, skip this task, record it as owed to Phase 7, and do not create the file. *(deviation: altered — the file is present (Phase 1), so the task was done, for the eight definitions that have a signature operator: `release`, `trigger`, `weakUntil`, `weakSince`, `inclusiveUntil`, `inclusiveSince` on `PlusFormula` and `inclusiveUntil`, `inclusiveSince` on `Formula`, all `Expr`-equal before the edit. `PlusFormula.strongRelease`, `strongTrigger` and `before` stay hand-written: `Connectives.lean` defines no `Sig` operator for them and is not in this phase's file list. Every `*_expand` and `reflect_time_*` lemma is untouched and still closes by `rfl`)*
- [x] Leave `reflectTime`, `complexity`, `modalDepth`, `atoms` and every other recursion untouched. *(completed)*
- [x] Extend `Tests/BimodalTest/Syntax/ConnectivesTest.lean`: for each regenerated definition, one `example : T.op … = Sig.op … := rfl`, and for `Formula` one literal-constructor-term example per operator, so a change in generator output fails here. *(completed: 71 `rfl` ties (Formula 22, PlusFormula 23, StarFormula 16, USForm 10), 22 literal-constructor examples at `Formula`, three `#print` rows pinning the stored one-layer body, and a check that none of the 71 stored bodies mentions a signature constant. The test module now imports the three library syntax modules and `TemporalViews`)*
- [x] Run `lake build` (whole library) and `lake test`. *(completed: `lake build` exit 0, 3029 jobs, 0 `error:` and 0 `warning:` lines; `lake test` exit 0, 3112 jobs, 0 `error:` and 0 `warning:` lines; both through `lake-build-guard.sh`)*
- [x] DEFERRED on the same condition: confirm `FormalSystem/Tactic/TemporalFormulaViews.lean` still elaborates unchanged, repointing a view row only if it names a constant that no longer exists, and recording each such row. If the file is absent, skip and record it as owed to Phase 8. *(completed: the file is present and built unchanged in the full build; no view row was repointed)*
- [x] Run the regeneration pair and stage the results. *(deviation: altered — the regeneration rewrote `typst/generated/status.typ` and the line-count rows of four directory READMEs (`FormalSystem/Syntax`, `FormalSystem/PlusLanguage`, `FormalSystem/Metalogic`, `FormalSystem/Metalogic/Expressiveness`); `README.md` and `FormalSystem/README.md`, which the plan lists, did not change. `--counts-only` and `--emit-inventory --check` exit 0)*

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Tier Justification**: `Formula`, `PlusFormula` and `StarFormula` are core types every other module imports, and the claim under test is that no downstream `simp`, `rw` or `unfold` site sees a different body, which only a whole-library `lake build` plus `lake test` observes.

**Scope Hypothesis**: The report's Prototype 2 counts (20, 17, 16 and 10 operators for the four types, all identical) are carried from report 01 and re-measured by Phase 1; the number of definitions rewritten here is Phase 1's figure, not this one. The eleven `TemporalViews.lean` operators are carried from head `5ecc91d63`; they are counted and regenerated only on the tree where that file exists, so on a tree without it this phase's figure covers the four formula types alone. Zero downstream proof edits are expected; any that turns out to be needed is a sign a body changed, and is investigated at the definition, not patched at the use site.

**Files to modify**:
- `FormalSystem/Syntax/Formula.lean` - derived operators generated from the signature
- `FormalSystem/PlusLanguage/Formula.lean` - derived operators generated from the signature
- `FormalSystem/StarLanguage/Formula.lean` - derived operators generated from the signature
- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Syntax.lean` - next, prev and the shared operators generated
- `FormalSystem/PlusLanguage/TemporalViews.lean` - interval operators generated; touched only once the temporal contribution has merged, otherwise skipped and owed to Phase 7
- `FormalSystem/Tactic/TemporalFormulaViews.lean` - view rows repointed only where a named constant moved; same existence condition, otherwise owed to Phase 8
- `Tests/BimodalTest/Syntax/ConnectivesTest.lean` - `rfl` ties and literal-body examples
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block

**Verification**:
- `lake build` and `lake test` exit 0, with no warning that is not in the Phase 1 baseline.
- `git diff --stat` for this phase lists no file outside the list above (a downstream proof edit would show here).
- Every `rfl` tie and literal-body example closes.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 6: Clause Classes as Mixins over the Signature [COMPLETED]

**Goal**: The clause classes carry truth clauses only, stated about the signature operators; the operator `abbrev`s of `TruthClauses.lean` are gone in favour of `Sig`.

**Tasks**:
- [x] In `FormalSystem/Semantics/TruthClauses.lean`: import the signature; restate `BotClause`, `ImpClause`, `BoxClause`, `UntlClause`, `SnceClause`, `StabClause`, `AllFutureClause`, `AllPastClause` as `class XClause (L) [TruthEnv L] [HasX L] : Prop` holding the clause alone; restate the bundles `BoolClauses`, `UntlClauses`, `TenseClauses`, `StabClauses` as `Prop` classes extending the mixins with the signature classes as instance binders; delete the 17 operator `abbrev`s and restate each lemma about the `Sig` operator. Keep every lemma name. *(completed)*
- [x] Repoint the generic clients: `FormalSystem/Semantics/TemporalRules.lean` and `TemporalIntervals.lean` (projection renames and binders only in this phase; their restatement is Phase 7), `RankProgress.lean`, `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean`, `Conservativity/Open/OpenAxiomValidity.lean`, `Conservativity/Star/StarAxiomValidity.lean`. The change is `XClause.x` to `HasX.x`, `TruthClauses.op` to `Sig.op`, and an added `[HasX L]` binder beside each `[XClause L]`. *(deviation: altered — `OpenAxiomValidity.lean` and `StarAxiomValidity.lean` needed no edit and are unchanged; fifteen lemmas whose proofs no longer use `BotClause` carry `omit [BotClause L] in`, since the operator now comes from `HasBot`)*
- [x] Repoint the instance sites: `Semantics/Truth.lean`, `PlusLanguage/PlusTruth.lean`, `StarLanguage/StarTruth.lean`, `OpenLanguage/OpenTruth.lean`, `HybridLanguage/HybridTruth.lean`, `QuantLanguage/QuantTruth.lean`, `MinusLanguage/MinusTruth.lean`. Each clause-bundle instance drops its operator fields and keeps the clause proofs. *(completed)*
- [x] Repoint the tests: the `Toy` instances and the qualified `TruthClauses.*` rows of `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, and `Tests/BimodalTest/Semantics/PointTransportTest.lean`. *(deviation: altered — `PointTransportTest.lean` needed no edit; `TemporalRulesTest.lean`, found by the phase-start grep, also needed none)*
- [x] Check `FormalSystem/Semantics/PointTransport.lean`, `FormalSystem/Semantics.lean` and `FormalSystem/NomicLanguage/NomicTruth.lean`: they name `TruthEnv` or the clause layer in prose or binders; edit only if the build requires it. *(completed — none of the three needed an edit)*
- [x] Measure `GenericSchemata.lean` after the edit. If it exceeds 1500 lines, add `set_option linter.style.longFile N` directly after the module docstring with `N` the value the linter's message names. *(completed — 1455 lines, under 1500; no option added)*
- [x] Use no `show` to bridge a definitional equality; where one is needed, add a named `rfl` lemma. *(completed — no `show` added)*
- [x] Run `lake build` (whole library) and `lake test`; only then run the regeneration pair and commit the batch as one commit. *(completed — `lake build` 3029 jobs and `lake test` 3112 jobs, both exit 0 with 0 errors and 0 warnings)*

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Tier Justification**: The clause classes are the shared interface of seven languages' truth files and the generic soundness schemata, so a change to their shape is only observed green by a whole-library `lake build` plus `lake test`.

**Scope Hypothesis**: Clause-class names occur in 19 tracked Lean files under `FormalSystem/` and `Tests/` (measured at plan time by grep for `TruthEnv`, the four bundles, `BotClause` and `ImpClause`); 16 are listed for edit below and three are check-only. The report's figure of 139 projection references in 5 files is CARRIED-UNVERIFIED (report 01). Confirm the file set at phase start with a grep for the eight clause-class names and the string `TruthClauses.`, written independently of the plan-time pattern; any further file found is added to the batch and recorded. The files under `specs/**/probes/` that name the classes are evidence records and are not edited. `GenericSchemata.lean` is 1440 lines now; added binders that extend existing `variable` lines add no lines, so the file is expected to stay under 1500, and the task above covers the case where it does not.

**Files to modify**:
- `FormalSystem/Semantics/TruthClauses.lean` - mixin clause classes; operator `abbrev`s removed
- `FormalSystem/Semantics/TemporalRules.lean` - projections and binders repointed
- `FormalSystem/Semantics/TemporalIntervals.lean` - projections and binders repointed
- `FormalSystem/Semantics/RankProgress.lean` - binders and opened namespace repointed
- `FormalSystem/Metalogic/SoundnessLemmas/GenericSchemata.lean` - projections and binders repointed
- `FormalSystem/Metalogic/Conservativity/Open/OpenAxiomValidity.lean` - binders repointed
- `FormalSystem/Metalogic/Conservativity/Star/StarAxiomValidity.lean` - binders repointed
- `FormalSystem/Semantics/Truth.lean` - clause instance without operator fields
- `FormalSystem/PlusLanguage/PlusTruth.lean` - clause instance without operator fields
- `FormalSystem/StarLanguage/StarTruth.lean` - clause instance without operator fields
- `FormalSystem/OpenLanguage/OpenTruth.lean` - clause instance without operator fields
- `FormalSystem/HybridLanguage/HybridTruth.lean` - clause instance without operator fields
- `FormalSystem/QuantLanguage/QuantTruth.lean` - clause instance without operator fields
- `FormalSystem/MinusLanguage/MinusTruth.lean` - clause instance without operator fields
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` - `Toy` instances and qualified rows repointed
- `Tests/BimodalTest/Semantics/PointTransportTest.lean` - binders repointed
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block

**Verification**:
- `lake build` and `lake test` exit 0, with no warning outside the Phase 1 baseline.
- An exact-name search finds no declaration `TruthClauses.neg`, `TruthClauses.top`, `TruthClauses.and`, `TruthClauses.or`, `TruthClauses.diamond`, `TruthClauses.someFuture`, `TruthClauses.allFuture`, `TruthClauses.kPlus`, `TruthClauses.after`, `TruthClauses.somePast`, `TruthClauses.allPast`, `TruthClauses.kMinus`, `TruthClauses.always`, `TruthClauses.dstab` under `FormalSystem/` (checked with `#check` failing or `lean_local_search`, not by a prefix-anchored grep).
- No clause class has an operator field: each is declared `: Prop`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 7: Interval Lemmas and the One next/prev Encoding [COMPLETED]

**Goal**: The six interval clause lemmas are stated about the signature's interval operators, and every `next`/`prev` is the signature's or is tied to it by `rfl`.

**Tasks**:
- [x] In `FormalSystem/Semantics/TemporalIntervals.lean`, restate `inclusiveUntil_iff`, `inclusiveSince_iff`, `release_iff`, `trigger_iff`, `weakUntil_iff`, `weakSince_iff` with `Sig.inclusiveUntil g ev` and its siblings in place of the inline derived terms. Keep each lemma's name, argument order and proof; the `abbrev`s unfold to the same terms, so the proofs are expected to stand.
- [x] In `FormalSystem/Semantics/TemporalRules.lean`, delete the local `next` and `prev` and state the rules about `Sig.next` and `Sig.prev`.
- [x] In `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, add `rfl` rows: `Formula.next φ = Sig.next φ`, the same for `PlusFormula`, `StarFormula`, `USForm`, and for `prev`; `NomicFormula.next` if `NomicFormula` has the classes `Sig.next` needs; one row per interval operator at `Formula` and at `PlusFormula`. *(deviation: altered — five imports added so the rows can name `USForm`, `NomicFormula` and the inclusive pair; `NomicFormula` has `next` only, so it gets one row; no row names `TemporalRules.next`, which no longer exists)*
- [x] Add one test applying a restated interval lemma at `StarFormula`, to show the lemma reaches L⋆ through the signature. *(deviation: altered — two applications, `release_iff` and `inclusiveUntil_iff`)*
- [x] Run `lake build` of the two semantics modules and their direct dependents, then `lake test`; run the regeneration pair. *(deviation: altered — a full `lake build` was also run as the phase-end gate; the regeneration changed `README.md` and `typst/generated/status.typ`, not `FormalSystem/README.md`)*

**Timing**: 1 hour

**Depends on**: 6, and the temporal contribution being on `main` -- this phase owns the interval operators that branch defines, so it must not run before them

**Verification Tier**: interface

**Tier Justification**: Two modules change statements without changing lemma names or argument order; `lake build FormalSystem.Semantics.TemporalIntervals FormalSystem.Semantics.TemporalRules` plus `lake build BimodalTest` covers them and their enumerated dependents (the semantics aggregator and the test library).

**Scope Hypothesis**: Six lemmas and two deleted definitions. The report states `TemporalRules.next`/`prev` have 2 references and that the restated interval statements are the same terms as the inline ones; both are CARRIED-UNVERIFIED (report 01), and the second rested on reading because the module was not in the local build. Confirm by the build: if a proof no longer closes, the statement is not the same term, and the difference is recorded before the proof is adjusted. Dependents of the two modules are enumerated at phase start with a grep for their import lines.

**Files to modify**:
- `FormalSystem/Semantics/TemporalIntervals.lean` - six lemmas restated about signature operators
- `FormalSystem/Semantics/TemporalRules.lean` - local `next`/`prev` removed
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` - rfl rows for next, prev and the interval operators; an L⋆ application
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block

**Verification**:
- The named build targets and `lake test` exit 0 with no new warning.
- Every `rfl` row closes; the L⋆ application elaborates.
- `TemporalRules.lean` contains no `abbrev next` or `abbrev prev`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 8: Operator Recognition through the Signature [COMPLETED]

**Goal**: `FormulaSyntax.operatorArgs?` recognizes an operator at any formula type that has the instances, with no per-language name table.

**Tasks**:
- [x] Read `FormalSystem/Tactic/FormulaSyntax.lean` in full and list the callers of `Language.operatorName`, `formulaApp`, `operatorArgs?` and `rigidOperatorArgs?` in `FormalSystem/Tactic/` and `FormalSystem/Automation/ProofMode/`.
- [x] Rewrite `operatorArgs?` (and `rigidOperatorArgs?`) to take the formula's own type, build the signature operator at that type with fresh metavariable arguments, and unify by `isDefEq`, following `#recognize` in `prototypes/01_signature-mixin-recognition.lean.txt`. A missing instance (for example `HasStab Formula`) is reported as "operator not available at this type". *(deviation: altered — a type lacking the operator raises the error "operator X is not available at T", as the name table did for `stab` at TM, instead of returning a value; an operator with no signature declaration, such as `atom`, is unified with the declaration in the type's namespace)*
- [x] Keep the fast path that checks the head constant against the per-type name before falling back to `isDefEq`, deriving the per-type name from the type's namespace instead of the table.
- [x] Remove `Language.operatorName`'s table. Keep `Language` and `Language.ruleName`, which still select the TM or TM⁺ rule. Keep `formulaApp`'s result unchanged for `tm` and `plus`: it must build the per-language constant, not the signature term, so that goals display and rewrite as before. *(deviation: altered — its six direct callers now call `operatorConst`, which names the declaration in the type's namespace)*
- [x] Update each caller for the changed signatures. *(deviation: altered — three callers outside the file list were edited: `Automation/ProofMode/Carrying.lean`, `Automation/ProofMode/TemporalBoolean.lean`, `Tests/BimodalTest/Automation/ProofModeCarryingTest.lean`; `FormulaViews.lean` and `ModalBoolean.lean` call no changed function and were not edited)*
- [x] Add `Tests/BimodalTest/Syntax/FormulaSyntaxTest.lean`: recognition of `diamond`, `allFuture`, `dstab` and `next` at `StarFormula` with arguments recovered; `weakUntil` at `Formula`; `dstab` at `Formula` reported absent; `diamond` against a `neg` term rejected. Add it to `Tests/BimodalTest.lean`.
- [x] Run `lake build` of `FormalSystem.Tactic` and `FormalSystem.Automation.ProofMode` modules, `lake test`, and the regeneration pair. *(deviation: altered — a full `lake build` and `lake test` were run instead of the scoped targets; the regeneration also changed `FormalSystem/Tactic/README.md` and `FormalSystem/Automation/ProofMode/README.md` and left `FormalSystem/README.md` unchanged)*

**Timing**: 1.5 hours

**Depends on**: 7, and the temporal contribution being on `main` -- this phase repoints the view rows that branch registers

**Verification Tier**: interface

**Tier Justification**: The change alters the signatures of meta functions whose callers are the `Tactic/` and `Automation/ProofMode/` modules; `lake build` of those modules plus `lake build BimodalTest` covers the changed module, its enumerated callers and the tests that exercise the proof mode.

**Scope Hypothesis**: The report names the enum's consumers as `FormulaPositions.lean` and three `Automation/ProofMode/` modules (CARRIED-UNVERIFIED, report 01). A plan-time grep for `Language.` found eight candidate files under `FormalSystem/Tactic/` and `FormalSystem/Automation/ProofMode/` (listed below); some may match only `Language.ruleName`, which does not change. Confirm the real caller set in the first task and edit only those. If the temporal contribution's `TemporalFormulaViews.lean` or other new modules call these functions, add them.

**Files to modify**:
- `FormalSystem/Tactic/FormulaSyntax.lean` - recognition through the signature; name table removed
- `FormalSystem/Tactic/FormulaPositions.lean` - caller update
- `FormalSystem/Tactic/FormulaViews.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/Basic.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/Meta.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/Modal.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/ModalBoolean.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/Temporal.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/Discrete.lean` - caller update if it calls a changed function
- `FormalSystem/Automation/ProofMode/Rewriting.lean` - caller update if it calls a changed function
- `Tests/BimodalTest/Syntax/FormulaSyntaxTest.lean` - new: recognition tests including L⋆
- `Tests/BimodalTest.lean` - import the test module
- `typst/generated/status.typ` - regenerated counts (commit-blocking surface)
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block

**Verification**:
- The named build targets and `lake test` exit 0 with no new warning; the existing proof-mode tests pass unchanged.
- The seven recognition cases of the new test behave as listed.
- `Language.operatorName` no longer exists (exact-name check).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 9: Reducibility Assessment, Documentation and Closing Gates [COMPLETED]

**BLOCKER resolved** (Phase 9): `file_scope` was extended by the eleven paths and the three owed repairs were made in a further dispatch. C20 and C35 of `scripts/check-module-invariants.sh` pass; `scripts/readme-lint.sh` reports two stale stamps, both stale before this task touched their directories (`Metalogic/Conservativity/Star/README.md`, since 2026-11-23, and `Metalogic/WeakCanonical/README.md`, since 2026-11-24), and `scripts/check-paper-definitions.sh` reports the paper drift recorded at the Phase 1 baseline.

**Goal**: The records and READMEs describe the signature layer as it stands, the reducibility assessment is on record, and the repository's gate set is green.

**Tasks**:
- [x] In `records/proof-mode-architecture.md`, state in the views-tier section what the measurement showed: signature operators are reducible; per-language operators are `def`s, because reducible ones let the primitive `imp_iff` rewrite a term before `and_iff` can, changing the normal form of the truth simp set; view rows are obtained as one `rfl` row per signature operator per language. State the current design only, with the rejected alternative on its own merits.
- [x] In `records/milestones.md`, correct the D1 row's "eighteen" to seventeen if the row is still worded that way, and leave status wording to the task system.
- [x] Update `FormalSystem/Syntax/README.md`, `FormalSystem/Semantics/README.md` and `FormalSystem/Tactic/README.md` prose (outside the generated inventory blocks) and `ORGANISATION.md`'s layer-0 row to name the signature module and what reads it. *(deviation: altered — the `Tactic/README.md` `Last verified` stamp was also moved to 2026-11-25, a new `readme-lint.sh` finding)*
- [x] Check every new or changed docstring and document for task-number references and draft-history wording; none may appear outside `specs/**`.
- [x] Run `bash scripts/check-module-invariants.sh --emit-inventory` once more and `bash scripts/typst-sync-check.sh --fix` if any `.lean` file changed in this phase. *(deviation: altered — one `.lean` file changed, `Tests/BimodalTest/Syntax/ConnectivesTest.lean`, which gained 32 docstrings to clear a C16 `docBlame` finding this task introduced; `--fix` was run and moved `tests-line-count` in `typst/generated/status.typ`; no inventory block needed a rewrite)*
- [x] Run `lake build`, `lake test`, `lake lint`, then `bash scripts/verify-all.sh`. Compare `python3 scripts/warning-budget.py` and `bash scripts/check-module-invariants.sh` against the Phase 1 baselines: no new finding in a file this task touched. A finding that predates the task in an untouched file is recorded and not fixed here. *(deviation: altered — `lake build`, `lake test` and `lake lint` exit 0. `verify-all.sh` exits 1 on two checks, neither owed to this task: `readme-lint.sh` on two stamps stale since 2026-11-23 and 2026-11-24 from other work, and `check-paper-definitions.sh` on paper drift. `check-module-invariants.sh` with the build half exits 1 on C14 and C16, both equal to the Phase 1 baseline. `verify-touched.sh` exits 1 in agent-tooling suites; see the summary)*
- [x] Record in the summary the follow-up left by the Decisions: generated bodies for the five instance-only languages, and a derive handler for the per-language recursions.

**Timing**: 1.5 hours

**Depends on**: 8, and therefore the temporal contribution being on `main`, since it reports the closing gates over the whole signature

**Verification Tier**: full

**Scope Hypothesis**: `records/proof-mode-architecture.md`, `records/milestones.md` and `ORGANISATION.md` exist at plan time; the three READMEs are assumed to carry hand-written prose beside their generated blocks. If a named record lacks the section described, add the statement where the document discusses the views tier or layer 0, and say so in the summary. `lake lint` is assumed to be the sanctioned entry point for `lintDriver = "batteries/runLinter"` in `lakefile.toml`; if `scripts/verify-all.sh` already runs the environment linter, do not run it twice.

**Files to modify**:
- `records/proof-mode-architecture.md` - reducibility assessment in the views-tier section
- `records/milestones.md` - D1 operator count corrected
- `ORGANISATION.md` - layer-0 row names the signature module
- `FormalSystem/Syntax/README.md` - prose and regenerated inventory block
- `FormalSystem/Semantics/README.md` - prose and regenerated inventory block
- `FormalSystem/Tactic/README.md` - prose and regenerated inventory block
- `README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `typst/generated/status.typ` - regenerated counts if any Lean line count moved
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean`, `FormalSystem/Metalogic/Decidability/Tableau.lean`, `FormalSystem/Metalogic/WeakCanonical/DenseModelSurgery/NoGaps.lean`, `Tests/BimodalTest/Metalogic/Decidability/TableauConformance.lean` and, under `FormalSystem/Metalogic/Expressiveness/Kamp/`, `DedekindINFDense.lean`, `KMinusFaithfulRendering.lean`, `KPlusFaithful.lean`, `KPlusFaithfulRendering.lean` and `PriorINF.lean` - `Syntax/Formula.lean` line citations repaired
- `scripts/lean-citation-manifest.json` - regenerated
- `FormalSystem/Metalogic/Expressiveness/README.md`, `FormalSystem/Metalogic/Expressiveness/SeparationZ/README.md`, `FormalSystem/Metalogic/SoundnessLemmas/README.md`, `FormalSystem/NomicLanguage/README.md` - verified against their directories, corrected and restamped

**Verification**:
- Under `/orchestrate`: `bash .claude/scripts/verify-touched.sh` over this task's touched paths exits 0, and the complete agent-system gate set is deferred to the orchestration close; this phase does not run it independently. Outside `/orchestrate`, run `bash .claude/scripts/verify-deploy.sh` directly.
- The repository's own Lean gates, which no narrowing invocation expresses, are run directly: `lake build`, `lake test`, `lake lint` and `bash scripts/verify-all.sh` each exit 0, or each failure is shown to predate the task and lie outside its touched files, with the Phase 1 baseline as evidence.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` and `bash scripts/typst-sync-check.sh --counts-only` exit 0.
- `bash .claude/scripts/check-task-references.sh` reports nothing in a file this task touched.

## Lean Challenge Statements

This plan has no theorem deliverable: it adds classes, instances, definitions and an elaborator,
and restates six existing lemmas under their existing names. The rationale is under Decisions.

<!-- lean-challenge-statements:none -->

## Testing & Validation

- [ ] `lake build` and `lake test` green after Phases 5, 6 and 9
- [ ] Literal-body gate test: each of the 26 signature operators generates the expected constructor term (Phase 3)
- [ ] `rfl` ties between every regenerated per-language definition and its signature operator (Phase 5)
- [ ] No file outside the declared lists changes in Phase 5 (no downstream proof edit)
- [ ] `rfl` rows for `next`, `prev` and the interval operators in `ValidityLayerTest.lean` (Phase 7)
- [ ] An interval clause lemma applied at `StarFormula` (Phase 7)
- [ ] Recognition tests at `StarFormula`, including an absent operator and a rejected one (Phase 8)
- [ ] `bash scripts/verify-all.sh` green, or failures shown to be pre-existing and out of scope (Phase 9)
- [ ] Warning budget and module-invariant findings do not increase against the Phase 1 baseline

## Artifacts & Outputs

- `FormalSystem/Syntax/Connectives.lean` - primitive-operator classes and derived operators
- `FormalSystem/Syntax/ConnectivesElab.lean` - `sig%` body generator
- `Tests/BimodalTest/Syntax/ConnectivesTest.lean` - generator gate test and `rfl` ties
- `Tests/BimodalTest/Syntax/FormulaSyntaxTest.lean` - recognition tests
- Signature instances in nine syntax files; generated bodies in four of them and in `TemporalViews.lean`
- Mixin clause classes in `FormalSystem/Semantics/TruthClauses.lean` and repointed instance sites
- Restated interval lemmas and a single `next`/`prev`
- Signature-driven recognition in `FormalSystem/Tactic/FormulaSyntax.lean`
- Reducibility assessment in `records/proof-mode-architecture.md`
- `specs/977_connective_signature_layer_shared_primitives/summaries/01_connective-signature-layer-summary.md`

## Rollback/Contingency

Each phase ends in its own commit (Phase 6 in a single batch commit), so a phase is undone with
`git revert` of that commit; Phases 2 to 4 are additive and can stay in the tree if a later phase
is reverted. If Phase 5 finds a generated body that differs from the stored one, leave that
definition hand-written, record it, and continue with the rest. If Phase 6 cannot reach a green
whole-library build inside its budget, do not commit a partial batch: take a durable
non-reverting checkpoint with `bash .claude/scripts/git-snapshot.sh 977 --no-revert`, mark the
phase `[PARTIAL]` with the list of files still red, and resume from there. A rollback that
discards uncommitted work follows the rollback rung of `.claude/context/contracts/recovery.md`.
If Phase 1 finds the temporal contribution unmerged, the plan stops there with nothing edited.
