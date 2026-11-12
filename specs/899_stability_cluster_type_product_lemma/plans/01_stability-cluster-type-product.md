# Implementation Plan: The stability cluster's (past-type, future-type) set is a full product

- **Task**: 899 - The stability cluster's (past-type, future-type) set is a full product
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/899_stability_cluster_type_product_lemma/reports/01_stability-cluster-type-product.md`; the compiled probes `specs/899_stability_cluster_type_product_lemma/probes/01_type-product.lean` and `probes/02_sepz-plug-point.lean` (both `lake env lean`, exit 0, no diagnostics)
- **Reports Integrated**: `reports/01_stability-cluster-type-product.md`
- **Artifacts**: plans/01_stability-cluster-type-product.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The product statement this task asks for is already proved: research developed it as a compiled,
sorry-free probe whose route is exactly the one the dispatch names — `paste` plus
`paste_agreeUpTo`/`paste_agreeFrom` feeding the semantic `PastDet`/`FutDet` predicates. The work
left is not mathematical: it is to land those declarations in the one module that can legally host
them, pin the headline theorem in the repository's two ledger surfaces at its *measured* axiom
profile, and reconcile the generated line-count surfaces a Lean edit moves. Scope is three files
of Lean-and-ledger work plus three generated/manual README surfaces; done means the six
declarations compile in-tree warning-free, `docs/theorem-index.md` carries exactly one new row
whose Axioms cell matches a baseline the same change adds, and the repository's full gate set
runs with no finding that names a file this task touched.

### Research Integration

- **The proof route is compiled, not argued (Finding 1, Finding 2).** `AgreeFrom`/`AgreeUpTo` and
  `paste_agreeFrom`/`paste_agreeUpTo` are oriented with the pasted history on the left, which is
  the orientation `PastDet`/`FutDet` consume without a `.symm`; the pasted history's first
  argument supplies the past and its second the future. Both probes would have failed on either a
  wrong orientation or a wrong argument order.
- **The dispatched siting is import-infeasible (Finding 4).** The chain is
  `PlusPasting → OpenClasses → OpenLanguage → OpenFutureElimination`, so
  `FormalSystem/PlusLanguage/PlusPasting.lean` sits upstream of `PastDet`, `FutDet` and
  `stabClass`; a probe importing only `PlusPasting` fails with two `unknownIdentifier` errors.
  Every phase below sites the work in
  `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`, which already owns
  `PastDet`, `FutDet`, `SepClauses` and the two `*_or_iff` eliminations that use the same
  paste-across-the-seam argument.
- **The history-level product is already in the tree (Finding 3).** `OpenClasses.lean`'s
  `paste_mem_openFutureClass_inter_openPastClass` and that file's docstring already assert that
  `⟨τ⟩_x` is the product of the open pasts and the open futures at `x`. This task lands the
  formula-level (type-level) image of that geometry and cites the precedent rather than restating
  it.
- **Two framings in the dispatch description are forward-looking, not present consumptions
  (Findings 5 and 6).** There is no Auxiliary-Atoms automaton anywhere in the tree
  (`AuxiliaryAtoms.lean` is the Reynolds §7 rule-soundness development; a repo-wide sweep for
  `automaton|automata` returns four hits, every one a docstring disclaimer that no automaton is
  built), and `separationOver_ztime`'s only present consumer is `tr` / `exists_translation_ztime`.
  The docstring wording in Phase 1 states the architecture as design intent accordingly.
- **The axiom profile is measured, not inferred (R3).** `[propext, Quot.sound]` for all three
  theorems; only the `sepZ`-instantiated form reaches `pcq`. The neighbouring
  `OpenFutureElimination.lean` rows read `pcq`, so copying a neighbour's cell would be wrong and
  gated.
- **R5 is carried as a plan-time obligation, not a settled finding.** Research's one Medium-confidence
  claim is that `hA`/`hB` are load-bearing; no countermodel was constructed and no gate decides
  it. Phase 1 discharges it as a reasoned docstring remark with its confidence stated, and
  `## Decisions` records why it is not a Lean declaration.

### Prior Plan Reference

No prior plan. This is the task's first plan round.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no roadmap phases are scheduled.

## Goals & Non-Goals

**Goals**:
- `pastType`, `futType` and `typePair` -- the past-type, the future-type and the type-pair of a
  world history at a time, over a finite list of L⁺ formulas at a model.
- `typePair_image_stabClass` -- on a regular frame, for past-determined `A` and future-determined
  `B`, the set of type-pairs realized across `stabClass τ t` is the full product of the realized
  past-types and the realized future-types.
- `typePair_image_stabClass_state_congr` -- that realized set depends only on `τ.state t`.
- `typePair_image_stabClass_of_sepClauses` -- a `SepClauses F L` hypothesis supplies both
  determinedness hypotheses over `L.map Prod.fst` / `L.map Prod.snd`.

**Non-Goals**:
- Siting any declaration in `FormalSystem/PlusLanguage/PlusPasting.lean`. The dispatched
  `file_scope` names it and is import-infeasible; this plan's `Files to modify` blocks are the
  correction, harvested by `scripts/plan-file-scope-harvest.sh`. `PlusPasting.lean` is READ-ONLY
  for this task and appears in no phase's file list.
- Moving `PastDet`, `FutDet` or `stabClass` upstream to make the dispatched siting work. Their
  placement is justified by `OpenFutureElimination.lean`'s own module docstring, and
  `LeafAbstraction.lean` and `OpenFutureUndefinable.lean` both consume them from there.
- Landing the `sepZ`-instantiated corollary `typePair_image_stabClass_sepZ`. It cannot live in
  `OpenFutureElimination.lean` (`SeparationZ/Discharge.lean` imports that module, not the
  reverse), `probes/02_sepz-plug-point.lean` already records that it compiles where it could live,
  and `typePair_image_stabClass_of_sepClauses` is the slot that makes the instantiation a
  three-line corollary for whoever needs it.
- Asserting that an Auxiliary-Atoms automaton exists, that this lemma initializes one, or that it
  is the point at which `separationOver_ztime` is consumed. None of the three is true of the
  current tree.
- A `Bool`-valued or `Finset`-valued type. Either needs `Decidable (PlusTruthAt M σ t φ)`, whose
  classical inhabitant forces `noncomputable` — the exact vacuity trap `rules/lean4.md` prohibits
  and whose worked instance this module's own docstring records.
- A machine-checked countermodel witnessing that `hA`/`hB` cannot be dropped. See
  `## Decisions`.
- Theorem-index rows for `typePair_image_stabClass_state_congr` or
  `typePair_image_stabClass_of_sepClauses`. Exactly one row is added.
- Any change to an existing declaration's signature, or to `tr`, `sepForm`, `SepClauses` or
  `SeparationOver`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The implementer re-derives its own decomposition and lands a weaker same-named statement (a one-directional `⊆`, or `A`/`B` specialised to syntactically pure formulas) | H | M | `## Lean Challenge Statements` pins all six signatures verbatim before implementation, so `.claude/scripts/lean-challenge-snapshot.sh --check` has something to compare against and `rules/plan-compliance.md`'s Statement Fidelity clause applies. Proof bodies are transcribed from `probes/01_type-product.lean`, not re-derived |
| The probe compiled under `lake env lean`, which does NOT apply the package's `[leanOptions]` (`linter.mathlibStandardSet`, `longFile`) — so the in-tree build is the first real lint measurement, and CI builds with `--wfail`, making a warning a failure | M | M | Phase 1's criterion is a warning-free scoped build, not merely exit 0. The two `show` lines in the transcribed proof are the specific exposure; `show` is used on 636 live lines under `FormalSystem/` at this configuration, so no `show` lint is active, and if one does fire the remedy is `change` (906 live lines) or a named `rfl` restatement — never a suppression and never a left-standing warning |
| The Axioms cell is typed as `pcq` by analogy with the four neighbouring `OpenFutureElimination.lean` rows | H | M | Phase 2 takes the value MEASURED in Phase 1, in-tree, and the expected `[propext, Quot.sound]` is stated in two places in this plan. `docs/theorem-index.md`'s own "How to read a row" states the column is generated from the baselines, never typed, so a hand-typed `pcq` is both wrong and gated by C14 |
| The C14 matched pair is inserted at mismatched positions in the two heredocs | M | M | The check compares whole-output string equality, so a misordering fails with a "diverged from baseline" message that reads like a real axiom regression. Phase 2 names the insertion point by content on both sides (immediately after the `...openValid_of_plusSound` line) and its criterion is the PASS verdict, not a diff read |
| C15's second assertion fails for the whole page because the new row's declaration carries no `Paper:` line | M | M | Phase 1 requires the `Paper: — (reason)` line in `typePair_image_stabClass`'s own doc comment, in the immediately-preceding `/-- ... -/` block, matching the `— (` shape the check demands — authored in the same hunk as the declaration, not deferred to Phase 2 |
| `.githooks/pre-commit` refuses Phase 1's commit because `typst/generated/status.typ` has drifted | M | H | Phase 1 runs `bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in its own commit (gate-collision Condition 1, surface (b) — BLOCKING, cannot be deferred to a reconciliation phase) |
| Concurrency: tasks 905 and 906 are dispatched this same cycle with no declared `file_scope`, and `docs/theorem-index.md` is the known contention surface (the task's own audit verdict lists 80+ `overlaps-open` rows, nearly all sharing exactly that file) | M | H | Every phase re-reads its target files immediately before editing, stages an explicit file list via `.claude/scripts/git-commit-scoped.sh` (never a directory or glob add), and never runs `git-snapshot.sh` in its reverting default mode. A foreign commit or foreign uncommitted modification is reported, not worked around, after `git log` confirms the work is not this task's |
| A sibling's concurrent `typst/generated/status.typ` regeneration makes the live counts disagree for reasons this task did not cause | L | M | This is the one legitimate case the pre-commit hook's own message names. Re-read the file, re-run `--fix`, and stage only `typst/generated/status.typ`; escalate rather than reaching for `--no-verify`, which defers the collision to CI rather than avoiding it |
| A full `check-module-invariants.sh` run reports FAILs that predate this task | M | M | Condition 4's implementer corollary applies: a gate whose only failures name no file in this task's scope is a recorded PASS for the phase, with the pre-existing findings enumerated. It is not a blocker and is not grounds to edit an out-of-scope file to force a zero |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel. This plan's waves are each a single phase:
Phase 2 consumes Phase 1's measured axiom values, and Phase 3 reconciles generated surfaces that
only exist in their final state after both.

**A note on the `full` tier's gate set in this repository.** `plan-format.md`'s `full` row names
`.claude/scripts/verify-deploy.sh`, which gates the deployed agent-system tree and has no bearing
on a `FormalSystem/**` Lean edit (gate-collision Condition 2: its target argument is a deploy-tree
root, and its findings for this task would be entirely the tree's standing baseline). The full
gate set for a Lean change here is the six commands enumerated in Phase 3, and that is what the
final phase runs.

### Phase 1: Land the six declarations in `OpenFutureElimination.lean` [COMPLETED]

**Goal**: the three type definitions and the three theorems compile in-tree, sorry-free and
warning-free, with every docstring obligation (C16 `docBlame`, C15's `Paper:` line, the R4 wording
constraint, the R5 non-vacuity remark) satisfied in the same hunk.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` immediately
  before editing, in case a sibling has already changed it.
- [x] Open a new section header `/-! ## The stability cluster's type set is a product -/` directly
  after the end of `opastP_sepForm_iff`'s proof and immediately before the existing
  `/-! ## The translation, conditional on separation -/` header. Siting it there is what lets
  `typePair_image_stabClass_of_sepClauses` refer to `SepClauses`, which is defined in the
  preceding section.
- [x] Transcribe `pastType`, `futType`, `typePair`, `typePair_image_stabClass`,
  `typePair_image_stabClass_state_congr` and `typePair_image_stabClass_of_sepClauses` from
  `specs/899_stability_cluster_type_product_lemma/probes/01_type-product.lean`. Signatures exactly
  as pinned in `## Lean Challenge Statements` below; proof bodies verbatim from the probe. Do not
  re-derive, do not inline, do not substitute a shorter route — `rules/plan-compliance.md` applies
  to this file.
- [x] Give all six declarations docstrings (C16's `docBlame`, C19's coverage floor).
- [x] End `typePair_image_stabClass`'s docstring with a `Paper: — (formalization-native; ...)`
  line, in the `/-- ... -/` block immediately preceding the declaration. C15's second assertion
  requires the value to begin `— (`; `ofutP_or_iff`'s own docstring in this file is the shape to
  follow.
- [x] Word the architectural framing in that docstring as design intent, not present consumption:
  that the theorem supplies the state-level datum a forward/backward Auxiliary-Atoms
  initialization would read, and that `typePair_image_stabClass_of_sepClauses` is the slot a
  separated clause list — including the one `separationOver_ztime` returns — plugs into. Do NOT
  write that an automaton is initialized by it, and do NOT write that this is where
  `separationOver_ztime` is consumed.
- [x] Add the non-vacuity remark to the same docstring (R5): with `A := [β]` for a `β` that is
  future-determined but not past-determined, `pastType M A ·` *is* the future-type function, so
  the right-hand side becomes the full square of a single image while the left-hand side is
  confined to its diagonal, and the equality fails as soon as two distinct values are realized in
  `stabClass τ t`. State it as a reasoned remark, flagged as not machine-checked; cite no theorem
  for it.
- [x] State in `typePair_image_stabClass_state_congr`'s docstring that it needs neither
  `[F.IsRegular]` nor the determinedness hypotheses and follows from `stabClass`'s definition
  alone — its cheapness stated, not hidden.
- [x] Have `typePair_image_stabClass`'s docstring cite the history-level precedent
  (`OpenClasses.lean`'s `paste_mem_openFutureClass_inter_openPastClass`) rather than restating the
  geometry.
- [x] Add one bullet to the module docstring's `## What is proved here` list and one to its
  `## Main Results` list, naming all six new identifiers and respecting the same wording
  constraint as above.
- [x] Use no task-number citation anywhere in the file (`rules/no-task-references-in-deliverables.md`,
  C9).
- [x] Run the scoped guarded build and confirm it is warning-free as well as exit 0.
  *(deviation: altered — the first scoped build exited 0 but emitted two `linter.style.show`
  warnings at the two transcribed `show` tactic lines, the exact probe/`[leanOptions]`
  asymmetry the Risks table predicted; applied the Rollback/Contingency fix-forward and
  replaced both with `change`. Rebuild: exit 0, zero warnings, zero errors. No suppression.)*
- [x] Measure, in-tree, `#print axioms` for all three theorems and record the three lines verbatim
  in the phase's notes. Phase 2 consumes these values; it does not re-predict them.
- [x] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` together
  with the Lean file in THIS phase's commit (gate-collision Condition 1, surface (b)).
- [x] Commit via `.claude/scripts/git-commit-scoped.sh` with an explicit two-file list, after
  reviewing `git status --short` and `git diff --staged`.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly six new declarations in exactly one Lean file,
adding roughly 90-110 lines including docstrings. Confirm after the edit with
`git diff --stat -- FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` and
`grep -nE '^(theorem|def) ' FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean`;
if the declaration count differs from six, stop and reconcile against
`## Lean Challenge Statements` before continuing rather than adjusting the hypothesis.

**Tier Justification**: the edit is additive and confined to one Lean module with no change to any
existing signature, and the covering checks are
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`
plus `bash scripts/typst-sync-check.sh --counts-only`, which is exactly what the pre-commit hook
itself runs against this phase's staged set.

**Files to modify**:
- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - new section with the three
  defs and three theorems, plus two module-docstring list entries
- `typst/generated/status.typ` - regenerated line/count surface (`typst-sync-check.sh --fix`)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Expressiveness.OpenFutureElimination`
  exits 0 AND emits no warning (CI builds with `--wfail`; a warning is a failure, not a note).
- `grep -n 'sorry' FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` returns
  nothing.
- `#print axioms` emits a line for each of the three theorems, and the measured values are
  recorded verbatim (expected `[propext, Quot.sound]` for all three; a different measured value is
  the value Phase 2 uses, not a defect to be forced back).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 after the `--fix` run.
- `bash scripts/check-copyright-headers.sh` exits 0.

---

### Phase 2: Pin the one row and its axiom baseline [COMPLETED]

**Goal**: `docs/theorem-index.md` carries exactly one new row for `typePair_image_stabClass` at
its measured axiom profile, and `scripts/check-module-invariants.sh` asserts that profile on every
run.

**Tasks**:
- [x] Re-read `docs/theorem-index.md` and `scripts/check-module-invariants.sh` immediately before
  editing. `docs/theorem-index.md` is this task's known contention surface with the two
  concurrently dispatched siblings.
- [x] Add ONE row to the open-future-elimination band's table, immediately after the
  `FormalSystem.Metalogic.Expressiveness.openValid_of_plusSound` row, so the
  `OpenFutureElimination.lean` cluster stays contiguous. Paper label `—`; Lean name fully
  qualified; File column a path with no line number; Frame class `—` (the theorem is
  class-generic, needing `[F.IsRegular]` only); Axioms cell the value MEASURED in Phase 1 followed
  by ` pinned:C14` (expected `[propext, Quot.sound] pinned:C14`). Do not copy the neighbouring
  rows' `pcq`.
- [x] Add one sentence to that band's prose stating what the row is and is not: an unconditional,
  class-generic product statement about the types realized across a stability cluster — not a
  transfer corollary, and not a decidability or completeness claim. Leave the existing "eight
  transfer-corollary rows" sentence and its count untouched.
- [x] Add the matched pair to `scripts/check-module-invariants.sh`: the line
  `#print axioms FormalSystem.Metalogic.Expressiveness.typePair_image_stabClass` in the `C14LEAN`
  heredoc immediately after its `...openValid_of_plusSound` line, and the corresponding
  `'FormalSystem.Metalogic.Expressiveness.typePair_image_stabClass' depends on axioms: ...` line in
  the `C14_BASELINE` heredoc at the SAME relative position (immediately after its own
  `...openValid_of_plusSound` line). The two sides are compared by exact whole-output string
  equality, so the positions must agree.
- [x] Pin only the indexed declaration. `typePair_image_stabClass_state_congr` and
  `typePair_image_stabClass_of_sepClauses` get neither a row nor a baseline line, and therefore
  need no `Paper:` line.
- [x] Commit via `.claude/scripts/git-commit-scoped.sh` with an explicit two-file list.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts exactly one new theorem-index row and exactly one matched
pair of heredoc lines. Confirm with `git diff --stat` showing two files, and with
`grep -c typePair_image_stabClass docs/theorem-index.md` returning 1 and
`grep -c typePair_image_stabClass scripts/check-module-invariants.sh` returning 2.

**Tier Justification**: no Lean source changes in this phase, so there is no build surface; the
covering check is `bash scripts/check-module-invariants.sh` read for its C14 and C15 verdicts,
which are precisely the two checks that consume these two files.

**Files to modify**:
- `docs/theorem-index.md` - one new row in the open-future-elimination band, plus one prose
  sentence
- `scripts/check-module-invariants.sh` - one matched pair of lines, one in each of the two C14
  heredocs

**Verification**:
- `bash scripts/check-module-invariants.sh` reports `PASS C14` (every pinned declaration matches
  its axiom baseline) and `PASS C15` for both assertions (anchor resolution and
  every-row-anchored-at-its-declaration).
- The C14 verdict's note lines include the new declaration at the measured profile.
- Any FAIL that names no file this task touched is recorded as a pre-existing baseline finding
  with its findings enumerated, not treated as a blocker (gate-collision Condition 4's
  implementer corollary).

---

### Phase 3: Reconcile the generated surfaces and run the full gate set [NOT STARTED]

**Goal**: every line-count surface Phase 1 moved is regenerated or corrected, and the
repository's full gate set runs with no finding naming a file this task touched.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory`, then
  `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm. This is
  gate-collision Condition 1's surface (a): `README.md`'s `dir=FormalSystem rows=totals` block and
  `FormalSystem/Metalogic/README.md`'s `rows=subdirs cols=files-lines` blocks both carry counts
  that Phase 1's added lines moved. Stage only the generated blocks' files.
- [ ] Correct the hand-maintained Modules table row for `OpenFutureElimination.lean` in
  `FormalSystem/Metalogic/Expressiveness/README.md`: set the Lines cell to the MEASURED
  `wc -l` value of the post-Phase-1 file, and extend the Description cell to name the type-product
  result. That table is not wrapped in `BEGIN GENERATED` markers, so `--emit-inventory` does not
  touch it; its cell reads 599 against a 610-line pre-task file, so it carries drift this task did
  not cause — set it to the measured value rather than adding this task's delta to the stale one.
- [ ] Refresh that README's `*Last verified:*` date line (`readme-lint.sh` Check 4, reported).
- [ ] Run the full gate set and record each verdict:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`;
  `bash scripts/check-module-invariants.sh`;
  `bash scripts/typst-sync-check.sh`;
  `bash scripts/readme-lint.sh`;
  `bash scripts/check-metalogic-cycles.sh`;
  `bash scripts/check-copyright-headers.sh`.
- [ ] Enumerate, by file, every FAIL or finding that names no file in this task's scope, as the
  recorded pre-existing baseline for this run.
- [ ] Run `bash .claude/scripts/lean-challenge-snapshot.sh --check` and record its verdict. It is
  ADVISORY: a drift finding is a signal to investigate under `rules/plan-compliance.md`, never on
  its own grounds to fail the task or downgrade a status.
- [ ] Commit via `.claude/scripts/git-commit-scoped.sh` with an explicit file list.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that exactly three markdown surfaces need reconciliation
(`README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/Metalogic/Expressiveness/README.md`).
Confirm by running `--emit-inventory --check` BEFORE the regeneration and reading which blocks it
reports stale; if it names a surface this list omits, add that file to the phase's scope and say so
in the phase notes rather than skipping it.

**Files to modify**:
- `README.md` - regenerated inventory totals block
- `FormalSystem/Metalogic/README.md` - regenerated subdir line-count blocks
- `FormalSystem/Metalogic/Expressiveness/README.md` - corrected Lines cell and Description for the
  elimination module's own row, refreshed verification date

**Verification**:
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0 with no stale block.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 with no
  warning.
- `bash scripts/check-module-invariants.sh` reports no FAIL naming any file in this task's scope;
  C1, C14, C15, C16, C19, C23 and C26 are read explicitly, and `INV` reports no stale generated
  block.
- `bash scripts/typst-sync-check.sh` exits 0 (the unbypassable CI backstop for Condition 1's
  surface (b)).
- `bash scripts/readme-lint.sh`, `bash scripts/check-metalogic-cycles.sh` and
  `bash scripts/check-copyright-headers.sh` each exit 0, or their findings are enumerated as
  pre-existing and naming no touched file.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination

namespace FormalSystem.Metalogic.Expressiveness

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage

variable {F : TaskFrame}

def pastType (M : TaskModel F) (A : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula := sorry

def futType (M : TaskModel F) (B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula := sorry

def typePair (M : TaskModel F) (A B : List PlusFormula) (σ : WorldHistory F) (t : F.Duration) :
    Set PlusFormula × Set PlusFormula := sorry

theorem typePair_image_stabClass [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (A B : List PlusFormula)
    (hA : ∀ φ ∈ A, PastDet F φ) (hB : ∀ ψ ∈ B, FutDet F ψ) :
    (fun σ => typePair M A B σ t) '' stabClass τ t
      = ((fun σ => pastType M A σ t) '' stabClass τ t)
        ×ˢ ((fun σ => futType M B σ t) '' stabClass τ t) := sorry

theorem typePair_image_stabClass_state_congr
    (M : TaskModel F) (τ τ' : WorldHistory F) (t : F.Duration)
    (A B : List PlusFormula) (h : τ.state t = τ'.state t) :
    (fun σ => typePair M A B σ t) '' stabClass τ t
      = (fun σ => typePair M A B σ t) '' stabClass τ' t := sorry

theorem typePair_image_stabClass_of_sepClauses [F.IsRegular]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (L : List (PlusFormula × PlusFormula)) (hL : SepClauses F L) :
    (fun σ => typePair M (L.map Prod.fst) (L.map Prod.snd) σ t) '' stabClass τ t
      = ((fun σ => pastType M (L.map Prod.fst) σ t) '' stabClass τ t)
        ×ˢ ((fun σ => futType M (L.map Prod.snd) σ t) '' stabClass τ t) := sorry

end FormalSystem.Metalogic.Expressiveness
```

## Decisions

- **Siting is `OpenFutureElimination.lean`, and the dispatched `file_scope` is corrected rather
  than honoured.** The import chain `PlusPasting → OpenClasses → OpenLanguage →
  OpenFutureElimination` makes the dispatched target unable to see `PastDet`, `FutDet` or
  `stabClass`; a compiled negative probe measured exactly that. The correction travels through this
  plan's `Files to modify` blocks, which `scripts/plan-file-scope-harvest.sh` harvests into the
  task's `file_scope`.
- **Two independent lists `A B : List PlusFormula` with pointwise hypotheses is the primary shape,
  with the `SepClauses` clause-pair form derived.** Nothing in the product statement pairs the
  `i`-th past formula with the `i`-th future one, and the past-type and the future-type are
  indexed independently by any intended consumer. The clause-pair corollary exists so a separated
  clause list plugs in without reshaping.
- **The type is `Set PlusFormula`.** A `Bool`- or `Finset`-valued type needs
  `Decidable (PlusTruthAt M σ t φ)`, unavailable in general, and its classical inhabitant forces
  `noncomputable` — the vacuity class `rules/lean4.md` prohibits. The `Set`-valued form compiles as
  a plain computable `def`.
- **`stabClass τ t` indexes both sides of the product.** This is what makes the statement
  non-trivial: the `⊇` direction is where `paste` and `[F.IsRegular]` are consumed. Using
  `openPastClass`/`openFutureClass` on the factors would trivialize it.
- **`typePair_image_stabClass_state_congr` is kept despite being cheap.** It needs neither
  `[F.IsRegular]` nor the determinedness hypotheses, and it is the declaration that literally says
  "state-level datum" — the dispatch's architectural point. Its cheapness is stated in its own
  docstring rather than hidden.
- **R5 is discharged as a docstring remark, not as a Lean declaration.** Exhibiting a countermodel
  needs a concrete model over `intOrder` realizing two distinct types inside one stability cluster
  — a model-construction job of uncertain size beside a ~100-line transcription — and no gate
  decides the question (C36 covers certificate classes, not semantic theorems of this shape). The
  remark carries the argument sketch and states that it is reasoned from the definitions rather
  than machine-checked.
- **The Axioms cell carries the measured `[propext, Quot.sound]`, not `pcq`.** The profile is
  genuinely unusual in this ledger and will look like an error to a reviewer who does not read the
  measurement, which is why the row is landed together with the C14 baseline pair that asserts it
  on every run.
- **The `sepZ` instantiation is out of scope.** It cannot be sited in `OpenFutureElimination.lean`
  for the same import-direction reason the dispatched siting fails, and
  `typePair_image_stabClass_of_sepClauses` plus `probes/02_sepz-plug-point.lean` together record
  everything a future consumer needs.

## Testing & Validation

- [ ] All six declarations compile in-tree, sorry-free, under a warning-free scoped guarded build.
- [ ] The three theorems' `#print axioms` values are measured in-tree and recorded verbatim.
- [ ] `docs/theorem-index.md` gains exactly one row, whose Axioms cell equals the measured value.
- [ ] `bash scripts/check-module-invariants.sh` reports `PASS C14` and `PASS C15`.
- [ ] No new `docBlame` (C16) or docstring-coverage (C19) finding; no `lemma` declaration (C23);
  no non-trailing underscore in any new `def` name (C26).
- [ ] `bash scripts/typst-sync-check.sh` exits 0 and `typst/generated/status.typ` was staged in
  the same commit as the Lean change.
- [ ] `--emit-inventory --check` reports no stale generated block.
- [ ] A full guarded `lake build` exits 0 with no warning.
- [ ] No task-number citation under `FormalSystem/`, `docs/` or `README.md` (C9).
- [ ] `lean-challenge-snapshot.sh --check` verdict recorded (advisory).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Expressiveness/OpenFutureElimination.lean` - six new declarations in a
  new section, plus two module-docstring list entries
- `docs/theorem-index.md` - one new row and one prose sentence
- `scripts/check-module-invariants.sh` - one matched C14 heredoc pair
- `typst/generated/status.typ` - regenerated counts
- `README.md`, `FormalSystem/Metalogic/README.md` - regenerated inventory blocks
- `FormalSystem/Metalogic/Expressiveness/README.md` - corrected Lines cell, extended Description,
  refreshed verification date
- `specs/899_stability_cluster_type_product_lemma/summaries/01_*-summary.md` - completion summary

## Rollback/Contingency

- Each phase is one scoped commit, so the unit of revert is `git revert` of that commit. Phase 1's
  commit carries both the Lean file and `typst/generated/status.typ`, so reverting it leaves the
  count surface consistent with the reverted source.
- Before any risky edit inside a phase, the defensive checkpoint is
  `bash .claude/scripts/git-snapshot.sh 899 --no-revert` — durable, and it does NOT mutate the
  working tree. The default (reverting) invocation belongs only to a genuine rollback; see
  `context/contracts/recovery.md`'s rollback rung for that invocation shape, including its
  out-of-scope override flag. Sibling tasks are live on this working tree, so the reverting modes
  must not be used here.
- If Phase 1's in-tree build produces a warning the probe did not (the `lake env lean` /
  package-`leanOptions` asymmetry), fix forward: replace the offending `show` with `change` or a
  named `rfl` restatement. Never suppress the linter, never leave a warning standing, and never
  discard uncommitted changes to reach a green build.
- If a declaration genuinely cannot be landed as pinned in `## Lean Challenge Statements`, mark the
  phase `[BLOCKED]` and escalate with what was tried and the goal state reached. Do not weaken the
  statement, do not add a hypothesis to make it pass, do not leave a `sorry`, and do not edit the
  recorded Challenge to match a different statement.
