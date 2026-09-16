# Implementation Plan: Task #600 (revised)

- **Task**: 600 - Rename dense extension to QTime (investigate first)
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours base (Phases 1, 2, 5, 6); up to 8 hours if both conditional Phases 3 and 4 run
- **Dependencies**: Task 603 (investigate ℚ-time frame predicate) -- its research report is the source of truth for the body, naming, and placement of the ℚ-time predicate
- **Research Inputs**: specs/600_rename_dense_extension_qtime/reports/01_dense-vs-qtime-naming.md; specs/603_investigate_qtime_frame_predicate/reports/ (latest report; not yet written at revision time)
- **Artifacts**: plans/02_dense-rationale-qtime-predicate.md (this file); supersedes plans/01_dense-naming-rationale.md (kept in place)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`FrameClass.Dense` keeps its name, and so does every name derived from it. This plan does two
things. First, it records in docstrings why the class is `Dense` and not `QTime`. Second, it adds
new Lean content that makes "the dense logic is the logic of ℚ-time" machine-checked. The new
content is a ℚ-time frame predicate `TaskFrame.IsQTime` with its inclusion lemma
`TaskFrame.isDense_of_isQTime`, a proof that frames over `TemporalOrder.of ℚ` satisfy it, a
validity notion `ValidQTime := ValidOnFrames TaskFrame.IsQTime` for this repository only, and the
theorem `validDense_iff_validQTime`. The docstring rationale then cites that theorem instead of
making the claim in prose alone. This plan does not choose the body of `IsQTime`. Task 603's
research report recommends the definition, its name, where it lives, and how much it costs to
prove that `ℚ` satisfies it. Every phase that writes `IsQTime` reads that report first. Done
means: no identifier renamed, the new declarations build with no `sorry` or `axiom`, the rationale
lives in one place (the `FrameClass` docstring) with pointers to it, `lake build` passes, and the
task-reference lint is clean.

### Research Integration

- **Report 01** (`01_dense-vs-qtime-naming.md`) is integrated in full, as in plan 01. The verdict
  is to keep `Dense`. The rationale has four points: `ZTime`/`RTime` are categorical and `Dense`
  is not; `Dense ≤ RTime` requires ℝ-frames to be in `Sat .Dense`; the paper uses the subscripts
  d/z/r for TM_d/TM_z/TM_r; and the paper says "ℚ-time" only where ℚ differs from the dense class
  (Kamp). The report said to add a docstring on `FrameClass` with a pointer on `IsDense`. It also
  flagged the Th(dense) = Th(ℚ-time) claim as needing precise wording. That caveat is now
  discharged by a theorem rather than by careful prose.
- **What changed from report 01.** The report marked the machine-checked corollary as optional
  and not recommended. Plan 01 therefore made it a non-goal. At the user's direction the corollary
  is now in scope, as `validDense_iff_validQTime` over a proper `IsQTime` predicate. It is not a
  bare "over `Rat`" statement.
- **No new research reports** were integrated in this revision. Task 603's report is an input
  that later phases must read. It is not integrated here.

### Prior Plan Reference

Plan 01 (`plans/01_dense-naming-rationale.md`) had 2 phases, both `[NOT STARTED]`, so no work
was completed and nothing needs preserving. Its Phase 1 (docstring rationale) becomes Phase 5
here. Phase 5 is rewritten to cite `validDense_iff_validQTime` in place of plan 01's prose-only
claim (c). Plan 01's Phase 2 (build and lints) becomes Phase 6. Phases 1-4 are new.

### Roadmap Alignment

A roadmap path was supplied (`specs/ROADMAP.md`). This revision does not change roadmap scope.
The work stays inside the frame-extensions topic.

## Goals & Non-Goals

**Goals**:
- Define the ℚ-time frame predicate `IsQTime` (as `TaskFrame.IsQTime`), using exactly the body, reducibility (def or abbrev), and placement from task 603's report. Default placement is FrameProperty.lean next to IsZTime and IsRTime.
- Prove the inclusion lemma `isDense_of_isQTime` (as `TaskFrame.isDense_of_isQTime`).
- Prove `isQTime_of_frameOver_rat`: every frame over TemporalOrder.of ℚ satisfies the predicate. The name is provisional; use task 603's naming if it recommends one, and update this Goals list and the Challenge block together.
- Define `ValidQTime` as ValidOnFrames TaskFrame.IsQTime, a repository-only notion that follows the ValidComplete precedent in Semantics/Validity.lean.
- Prove `derivable_of_validQTime`: QTime-valid implies derivable at FrameClass.Dense. This is the ℚ-time counterpart of the dense completeness engine.
- Prove `validDense_iff_validQTime`: dense-valid iff QTime-valid.
- Record the naming rationale once, on the FrameClass docstring in FormalSystem/ProofSystem/Axioms.lean, citing the equivalence theorem, with a short pointer on TaskFrame.IsDense.

**Non-Goals**:
- No renames. FrameClass.Dense, ValidDense, derivable_of_validDense, cantorBfmcsDense, StrongCompletenessDense, and every other Dense-derived identifier, file, and module stay as they are. Order-density identifiers (EpsilonDense, GoodDense, DenseModelSurgery, PriorExpressivenessDense, ...) are also untouched.
- No new FrameClass constructor. ValidQTime is not a ValidIn instance. FrameClass stays Base | Dense | ZTime | RTime, and FrameClass.Sat, the FrameClass order, and the Derivable index are all unchanged. There is no QTime proof-system class, and no axiom gets a QTime minFrameClass.
- Not choosing the body of IsQTime independently. The candidates are listed only for context: (a) divisible plus pairwise commensurable (rank-one divisible); (b) `Nonempty (F.Duration ≃+o ℚ)`; (c) countable plus dense; (d) another characterization, for example Archimedean plus divisible plus countable. The choice is task 603's.
- The characterization IsQTime → Nonempty (Duration ≃+o ℚ) is out of scope unless task 603's report says it is nearly free. If so, it runs as conditional Phase 3; otherwise it is excluded.
- Strong completeness over ℚ-time is out of scope unless task 603's report says it comes nearly free through the compactness route. If so, it runs as conditional Phase 4; otherwise it is excluded.
- No change to the signature or proof of derivable_of_validDense or soundness_dense. The only exception is an optional extraction of a shared helper that leaves both public signatures unchanged (see Phase 2).
- No sorry, no axiom, and no task-number references in deliverables.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 603's report is absent or has no clear recommendation when implementation starts | H | M | Hard gate at the start of Phases 1, 3, 4, and 5: if the report is missing, or it has no single recommended definition, stop with `[PARTIAL]` and do not pick a candidate. The task dependency on 603 should already prevent dispatch before then. |
| The recommended definition makes `isQTime_of_frameOver_rat` expensive (for example the ≃+o ℚ form, which needs an explicit isomorphism) | M | M | Use 603's cost estimate. If Phase 1 exceeds its budget, commit the definition and inclusion lemma (green), mark the phase `[PARTIAL]`, and resume. Do not weaken the definition to make the proof cheaper. |
| `isDense_of_isQTime` is not immediate from the chosen body (for example divisibility implies density only through a group argument) | M | L | Phase 1 owns this lemma. 603's report should name the Mathlib route; fall back to `lean_leansearch`/`lean_loogle` for divisible ordered groups being densely ordered. |
| Import cycle: soundness is not reachable from BXCanonical/Completeness.lean (checked at revision time), so the iff cannot live there | M | H | Split the work. `derivable_of_validQTime` goes in BXCanonical/Completeness.lean, next to `derivable_of_validDense`, and needs only completeness machinery. `validDense_iff_validQTime` goes in Metalogic/StrongCompleteness.lean, next to `completeness_dense`, which imports both Soundness and the BXCanonical chain. Recheck with a module-import walk before writing. |
| FrameProperty.lean has `assert_not_exists` for the proof system, and the chosen body needs new Mathlib imports | L | M | Mathlib imports are allowed there. Only `FormalSystem.ProofSystem.*` is forbidden. If 603 recommends a separate file, follow it. |
| Concurrent history-layer refactor (WorldHistory, task 602) renames `PartialHistory` / `IsTotal` in the countermodel's statement | M | M | The Challenge statements do not mention histories, so they stay stable. Adapt the proof of `derivable_of_validQTime` to whatever `countermodel_dense_enriched` and `ValidOnFrames.apply_total` look like at implementation time. Confirm them with `lean_hover_info` first. |
| Snapshot tooling cannot pin a statement whose predicate body is undecided | M | H | The Challenge section is marked provisional (see its note). It is finalized once 603's report exists and before implementation starts, or the task goes without a Challenge. Running the snapshot early fails loudly (exit 71) because the identifiers cannot be resolved. It never produces a wrong Challenge silently. |
| The rationale gets duplicated across several docstrings and drifts | L | M | The full argument lives only on `FrameClass`. `IsDense` and `IsQTime` get one-to-two-sentence pointers to it. |
| A task number slips into a Lean docstring | M | L | Refer to "the ℚ-time predicate investigation" only in specs/. Lean files cite declaration names only. Run `check-task-references.sh`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 2, 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 2 and 3 write to different files.
Phase 2 owns Validity.lean, BXCanonical/Completeness.lean, and StrongCompleteness.lean. Phase 3
owns FrameProperty.lean, or the file 603 names for the characterization.

**Report gate (applies to Phases 1, 3, 4, 5).** Before editing anything, locate the latest
`specs/603_investigate_qtime_frame_predicate/reports/*.md` and read it in full. If there is no
such report, or it gives no single recommended definition of `IsQTime`, stop at once. Mark the
phase `[PARTIAL]`, write partial status naming the missing report, and do not choose a definition
independently. Record in the phase's progress notes the report path and the recommendation used.

### Phase 1: ℚ-time predicate, inclusion lemma, and ℚ witness [NOT STARTED]

- **Goal:** Add `TaskFrame.IsQTime` exactly as task 603 recommends, prove `TaskFrame.isDense_of_isQTime`, and prove that frames over `TemporalOrder.of ℚ` satisfy it.
- **Tasks:**
  - [ ] Apply the report gate above. Extract the recommended body, the name (`IsQTime` unless the report says otherwise), reducibility (`def` vs `abbrev`, taking account of the instance-cache notes in FrameProperty.lean), file placement, and the recommended proof route for the ℚ witness and the inclusion.
  - [ ] Confirm the surrounding names with `lean_local_search` or grep: `TaskFrame.IsZTime`, `TaskFrame.IsRTime`, `TaskFrame.IsDense`, `TaskFrame.isDense_of_isRTime`, `TemporalOrder.of`, `FrameOver.toTaskFrame`. Confirm that `(F.toTaskFrame).Duration = TemporalOrder.of ℚ` holds by `rfl`.
  - [ ] Write `TaskFrame.IsQTime` in the recommended file, next to `IsZTime`/`IsRTime`. Its docstring should say what the predicate is, why this form was chosen (in the tree's own words, summarizing 603's comparison without citing the task), that it is repository-only (no paper clause and no `FrameClass` tag denotes it), and point to the `FrameClass` docstring for the naming argument. If the module's "Main Definitions" list names `IsZTime`/`IsRTime`, add `IsQTime` to it.
  - [ ] Prove `TaskFrame.isDense_of_isQTime {F : TaskFrame} (h : F.IsQTime) : F.IsDense` in the `namespace TaskFrame` block next to `isDense_of_isRTime`.
  - [ ] Prove `TaskFrame.isQTime_of_frameOver_rat (F : FrameOver (TemporalOrder.of ℚ)) : F.toTaskFrame.IsQTime`, or use 603's recommended name. If the name changes, update this plan's Goals and Challenge block together.
  - [ ] Run `lean_verify` on all three declarations and check that the only axioms are `propext`, `Classical.choice`, and `Quot.sound`.
- **Timing:** 1.5-2.5 hours (depends on how hard the ℚ witness is under the chosen body; use 603's estimate)
- **Depends on:** none
- **Verification Tier:** local
- **Scope Hypothesis:** One Lean file changes (FrameProperty.lean, or the file 603 names) and gains 1 definition and 2 theorems, with possibly one new Mathlib import. Confirm with `git diff --stat`. No existing declaration's signature changes.

**Files to modify**:
- `FormalSystem/Semantics/FrameProperty.lean` (default; or 603's recommended file)

**Verification**:
- `lean_diagnostic_messages` on the file shows no errors and no new warnings.
- `lake build FormalSystem.Semantics.FrameProperty` (or the named module) passes.
- The diff contains no `sorry` and no `axiom`.

---

### Phase 2: ValidQTime and the dense/ℚ-time validity equivalence [NOT STARTED]

- **Goal:** Define `ValidQTime`, prove the ℚ-time completeness engine `derivable_of_validQTime`, and prove `validDense_iff_validQTime` in three steps.
- **Tasks:**
  - [ ] Re-confirm with `lean_hover_info` or `lean_local_search` the exact current signatures of `ValidOnFrames`, `ValidOnFrames.mono`, `ValidOnFrames.apply_total`, `ValidDense`, `ValidIn`, `FrameClass.Sat`, `countermodel_dense_enriched`, `derivable_of_validDense`, `soundness_validIn`, `soundness_dense`, and `completeness_dense`. The history layer may have moved.
  - [ ] Check import reachability before choosing sites. At revision time `FormalSystem.Metalogic.Soundness` was not in the import closure of `BXCanonical/Completeness.lean`, and `StrongCompleteness.lean` imports both.
  - [ ] In `FormalSystem/Semantics/Validity.lean`, define `ValidQTime (φ : Formula) : Prop := ValidOnFrames TaskFrame.IsQTime φ` next to `ValidComplete`. The docstring must say: it is repository-only, like `ValidComplete`; no `FrameClass` constructor denotes its class, so it is `ValidOnFrames` at a bare predicate and not `ValidIn` at a tag; it is not a new frame class; and its theory equals `ValidDense`'s by `validDense_iff_validQTime`. Update any module-docstring list of the `ValidOnFrames` instances that names `ValidComplete` as the only non-tag instance.
  - [ ] In `FormalSystem/Metalogic/BXCanonical/Completeness.lean`, after `derivable_of_validDense`, prove `derivable_of_validQTime (φ : Formula) : ValidQTime φ → Derivable FrameClass.Dense [] φ`. The proof has the same shape as `derivable_of_validDense`: Lindenbaum, then a case split on `□(¬F'⊤)`. In the dense branch, `countermodel_dense_enriched` gives `F : FrameOver (TemporalOrder.of Rat)`, and `ValidOnFrames.apply_total h F.toTaskFrame (TaskFrame.isQTime_of_frameOver_rat F) …` contradicts it. The non-dense branch is the unchanged `dense_indicator` argument. If the two bodies duplicate more than about 15 lines, a private shared helper that takes "truth at every `Rat` countermodel" as its hypothesis is allowed, as long as the public signature of `derivable_of_validDense` does not change.
  - [ ] In `FormalSystem/Metalogic/StrongCompleteness.lean`, next to `completeness_dense`, prove `validDense_iff_validQTime (φ : Formula) : ValidDense φ ↔ ValidQTime φ`:
    - (→) dense-valid implies QTime-valid, because ℚ-time frames are dense: `ValidOnFrames.mono (fun F h => TaskFrame.isDense_of_isQTime h)`. `Sat .Dense` reduces to `IsDense`.
    - (←) QTime-valid implies derivable at `.Dense` by `BXCanonical.derivable_of_validQTime`. Derivable at `.Dense` implies dense-valid by soundness (`soundness_validIn` on the extracted `DerivationTree`, the empty-context form of `soundness_dense`).
    - The docstring states the three-step argument and cites the paper's `cor:tm-completeness` for context. It must not say "strong".
  - [ ] Run `lean_verify` on `ValidQTime`'s dependents, `derivable_of_validQTime`, and `validDense_iff_validQTime`. Only the standard three axioms may appear.
- **Timing:** 1.5 hours
- **Depends on:** 1
- **Verification Tier:** interface
- **Scope Hypothesis:** Three Lean files change (Validity.lean, BXCanonical/Completeness.lean, StrongCompleteness.lean), gaining 1 definition and 2 theorems plus docstrings. The one-hop dependents to build are those three modules and `FormalSystem.Metalogic` (the aggregator). Confirm with `git diff --stat`. No existing signature changes.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - `ValidQTime`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` - `derivable_of_validQTime`
- `FormalSystem/Metalogic/StrongCompleteness.lean` - `validDense_iff_validQTime`

**Verification**:
- `lake build FormalSystem.Metalogic.StrongCompleteness` passes. That build covers Validity and BXCanonical/Completeness.
- The diff contains no `sorry` and no `axiom`.

---

### Phase 3: Conditional -- characterization IsQTime → Nonempty (Duration ≃+o ℚ) [NOT STARTED]

- **Goal:** Only if task 603's report finds it nearly free, prove that `IsQTime` pins down ℚ up to order-and-group isomorphism.
- **Tasks:**
  - [ ] Apply the report gate. If the report does not recommend this characterization as nearly free, close the phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` row whose Evidence quotes the report's cost assessment. Do nothing else.
  - [ ] Otherwise, prove it under 603's recommended name and file. When the chosen body is itself `Nonempty (F.Duration ≃+o ℚ)`, the statement is trivial and this phase is exclusion-closed.
  - [ ] If the proof runs well past its budget, stop. Record an exclusion that cites the measured cost, and do not leave a `sorry`.
- **Timing:** 0-1.5 hours
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** Zero or one Lean file changes, gaining at most 1 theorem. Confirm with `git diff --stat`.

**Files to modify**:
- `FormalSystem/Semantics/FrameProperty.lean` (or 603's recommended file), only if the phase runs

**Verification**:
- The touched module builds, and `lean_verify` shows only the standard axioms.

---

### Phase 4: Conditional -- strong completeness over ℚ-time [NOT STARTED]

- **Goal:** Only if task 603's report finds that strong completeness over ℚ-time comes nearly free through the compactness route, state and prove it.
- **Tasks:**
  - [ ] Apply the report gate. If the report does not find it nearly free, close `[COMPLETED WITH EXCLUSIONS]` with a Reasoned Exclusions row that cites the report's assessment.
  - [ ] Otherwise, confirm the current names `StrongCompletenessDense`, `strongCompletenessDense`, and `SemanticConsequenceDense` (in Metalogic/SetConsequence.lean, Metalogic/Compactness.lean, and Metalogic/StrongCompleteness.lean). Add the ℚ-time analogue in the shape 603 recommends, for example via a consequence-level version of `validDense_iff_validQTime`. It must not introduce a `FrameClass` tag.
  - [ ] If this needs a new consequence notion or a reproof of the compactness route instead of transport, it is not nearly free. Exclude it with evidence.
- **Timing:** 0-1 hour
- **Depends on:** 2
- **Verification Tier:** interface
- **Scope Hypothesis:** Zero or one Lean file changes (Compactness.lean or StrongCompleteness.lean), gaining at most 1 definition and 1 theorem. Confirm with `git diff --stat`.

**Files to modify**:
- `FormalSystem/Metalogic/Compactness.lean` or `FormalSystem/Metalogic/StrongCompleteness.lean`, only if the phase runs

**Verification**:
- The touched module builds, and `lean_verify` shows only the standard axioms.

---

### Phase 5: Naming rationale in docstrings [NOT STARTED]

- **Goal:** Write the canonical "why `Dense`, not `QTime`" paragraph on `FrameClass`, citing `validDense_iff_validQTime`, plus the pointer docstrings.
- **Tasks:**
  - [ ] Apply the report gate, so the prose matches the definition that was actually chosen.
  - [ ] Confirm each declaration name to be cited with `lean_local_search` or grep: `FrameClass.Sat`, the `Sat` antitonicity lemma (currently referred to as `FrameClass.Sat.anti`; check its real name), `TaskFrame.IsDense`, `TaskFrame.IsQTime`, `TaskFrame.isDense_of_isQTime`, `ValidQTime`, `validDense_iff_validQTime`, `derivable_of_validQTime`, `derivable_of_validDense`, `countermodel_dense_enriched`, `soundness_dense`, `Semantics.complete_duration_discrete_or_dense`, and the characterization and strong-completeness names if Phases 3 and 4 added them.
  - [ ] In `FormalSystem/ProofSystem/Axioms.lean`, add a paragraph to the `FrameClass` docstring after the "Why `RTime` sits strictly above `Dense`" paragraph. Title it "**Why this class is named `Dense` and not `QTime`.**" It must cover:
    - (a) `ZTime`/`RTime` are named after their carriers because their classes are categorical.
    - (b) The dense class is not categorical (it contains ℚ, ℝ, ℚ ×ₗ ℚ, ...). It cannot be narrowed to ℚ, because `Dense ≤ RTime` needs ℝ-frames in `Sat .Dense`.
    - (c) Its logic is nevertheless the logic of ℚ-time, and this is machine-checked as `validDense_iff_validQTime` over the repository-only `TaskFrame.IsQTime`. The ℚ-time class is a predicate with its own validity notion (`ValidQTime`), not a `FrameClass` tag. That is a theorem about the class, not a definition of it. This replaces plan 01's prose-only claim.
    - (d) The name follows the paper's TM_d / BX_d and the Dense clause of `def:frame-properties`, so Dense/ZTime/RTime matches the paper's d/z/r.
    - (e) The paper uses "ℚ-time" only where ℚ differs from the dense class (Kamp's theorem).
  - [ ] In `FormalSystem/Semantics/FrameProperty.lean`, add a short note to the `TaskFrame.IsDense` docstring: this is a bare paper clause that is not narrowed, so it keeps the paper's name. Its ℚ-time narrowing is `IsQTime`, whose validity coincides with it (`validDense_iff_validQTime`). Point to the `FrameClass` docstring for the full argument. Make sure the `IsQTime` docstring from Phase 1 points back to it as well and does not repeat the argument.
  - [ ] Optional: one sentence on the `.Dense` bullet in `FormalSystem/Semantics/FrameClassValidity.lean`'s interpretation notes, and "The tree says `Dense`, not `QTime`; see `validDense_iff_validQTime`" in the TM_d row of `docs/theorem-index.md`, plus a row for the new theorem if that index lists theorems of this kind.
- **Timing:** 1 hour
- **Depends on:** 2, 3, 4
- **Verification Tier:** prose
- **Scope Hypothesis:** Changes are limited to 2 Lean docstrings (Axioms.lean and FrameProperty.lean), with up to 2 optional prose additions (FrameClassValidity.lean and docs/theorem-index.md). Confirm with `git diff --stat` that every hunk is inside a `/-- -/` or `/-! -/` block or is markdown prose.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - the canonical rationale paragraph on `FrameClass`
- `FormalSystem/Semantics/FrameProperty.lean` - pointer on `TaskFrame.IsDense`
- `FormalSystem/Semantics/FrameClassValidity.lean` - optional one-sentence pointer
- `docs/theorem-index.md` - optional naming note on the TM_d row

**Verification**:
- Read through the diff: every changed hunk is inside a comment, a docstring, or markdown prose.
- The prose cites declaration names, never line numbers.

---

### Phase 6: Full build and lint verification [NOT STARTED]

- **Goal:** Run the full gate set over all changes.
- **Tasks:**
  - [ ] Run `lake build` in full. Use `lean_diagnostic_messages` on the touched files first for fast feedback.
  - [ ] Run `bash .claude/scripts/check-task-references.sh` over the changed deliverables and confirm there are no task-number references.
  - [ ] Run the repository's paper-anchor lint (`scripts/check-paper-definitions.sh` or the C15 anchor check, whichever covers docstrings) so that `def:frame-properties`, `def:BX-d`, `def:TMplus`, and `cor:tm-completeness` resolve.
  - [ ] Grep the full diff for `sorry` and `axiom`: expect zero. Run `lean_verify` on every new theorem.
  - [ ] If `FormalSystem/MainResults.lean` or `Tests/BimodalTest/` holds `#check` / `#print axioms` pins for the dense completeness results, add matching pins for `validDense_iff_validQTime`, but only if that is the established convention.
  - [ ] Run `git diff` and confirm that no existing identifier was renamed.
- **Timing:** 45 minutes (mostly `lake build`)
- **Depends on:** 5
- **Verification Tier:** full

**Files to modify**:
- None, apart from optional pins. Fix-ups go back into the files of the owning phase.

**Verification**:
- `lake build` exits 0 with no new warnings in the touched files.
- The task-reference lint and the anchor lint pass.

## Lean Challenge Statements (provisional: pending the IsQTime body)

**Why provisional.** The statements of `isDense_of_isQTime`, `isQTime_of_frameOver_rat`,
`ValidQTime`, `derivable_of_validQTime`, and `validDense_iff_validQTime` are fixed here, apart from
the body of `IsQTime`. Their meaning depends on that body, which task 603 decides, so a Challenge
snapshot taken now would certify a placeholder. The heading suffix is deliberate:
`lean-challenge-snapshot.sh` recognizes only the exact heading `## Lean Challenge Statements`, so
this section is treated as absent. Running the snapshot now falls back to R2 and fails loudly
(exit 71) because none of the Goals identifiers exist in the tree yet. It never produces a wrong
Challenge silently.

**How to finalize.** Once 603's report exists, and while this task is still `planned`, run
`/revise 600` or edit the plan by hand:
1. Replace the placeholder body of `IsQTime` with the recommended one, change `def` to `abbrev` if
   recommended (the snapshot's declaration regex recognizes `def`/`theorem`/`lemma`/`instance`, but
   not `abbrev`), and apply any renames to both this block and the Goals list.
2. Drop the heading suffix.
3. Take the snapshot before `/implement`, because the status gate refuses after `planned`.

If implementation starts before this is done, the task goes ahead without a Challenge. The
implementation summary must record that.

**Tooling notes.** Declarations sit inside `namespace` blocks under short names, because both the
snapshot's declaration regex and its Goals regex match dot-free identifiers only.

```lean
import FormalSystem.Metalogic.StrongCompleteness

namespace FormalSystem.Semantics

open FormalSystem.Syntax

namespace TaskFrame

/-- PROVISIONAL BODY: replaced verbatim by the definition recommended in the ℚ-time predicate
investigation report before this block is snapshotted. -/
def IsQTime (F : TaskFrame) : Prop := sorry

theorem isDense_of_isQTime {F : TaskFrame} (h : F.IsQTime) : F.IsDense := sorry

theorem isQTime_of_frameOver_rat (F : FrameOver (TemporalOrder.of ℚ)) :
    F.toTaskFrame.IsQTime := sorry

end TaskFrame

def ValidQTime (φ : Formula) : Prop := ValidOnFrames TaskFrame.IsQTime φ

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics

theorem derivable_of_validQTime (φ : Formula) :
    ValidQTime φ → Derivable FrameClass.Dense [] φ := sorry

end FormalSystem.Metalogic.BXCanonical

namespace FormalSystem.Metalogic

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.Semantics

theorem validDense_iff_validQTime (φ : Formula) : ValidDense φ ↔ ValidQTime φ := sorry

end FormalSystem.Metalogic
```

The identifier set declared here, {`IsQTime`, `isDense_of_isQTime`, `isQTime_of_frameOver_rat`,
`ValidQTime`, `derivable_of_validQTime`, `validDense_iff_validQTime`}, equals the set of
backticked identifiers under Goals. If conditional Phase 3 or 4 is admitted by 603's report, add
its declaration to both places during finalization.

## Testing & Validation

- [ ] `lake build` passes.
- [ ] `lean_verify` on `TaskFrame.isDense_of_isQTime`, `TaskFrame.isQTime_of_frameOver_rat`, `BXCanonical.derivable_of_validQTime`, and `Metalogic.validDense_iff_validQTime` shows only `propext`, `Classical.choice`, and `Quot.sound`.
- [ ] The diff contains no `sorry` or `axiom`, and no existing identifier is renamed.
- [ ] `FrameClass` still has exactly four constructors, and `ValidQTime` is defined via `ValidOnFrames`, not `ValidIn`.
- [ ] `check-task-references.sh` is clean on the changed files.
- [ ] The paper anchors cited in the new prose resolve.
- [ ] Every declaration name cited in the new prose exists (checked with `lean_local_search`).
- [ ] The `IsQTime` body matches 603's recommendation word for word, and the implementation summary records the report path used.

## Artifacts & Outputs

- specs/600_rename_dense_extension_qtime/plans/02_dense-rationale-qtime-predicate.md (this plan)
- Modified: FormalSystem/Semantics/FrameProperty.lean, FormalSystem/Semantics/Validity.lean, FormalSystem/Metalogic/BXCanonical/Completeness.lean, FormalSystem/Metalogic/StrongCompleteness.lean, FormalSystem/ProofSystem/Axioms.lean
- Optionally modified: FormalSystem/Semantics/FrameClassValidity.lean, docs/theorem-index.md, FormalSystem/Metalogic/Compactness.lean (Phase 4), FormalSystem/MainResults.lean (pins)
- specs/600_rename_dense_extension_qtime/summaries/02_dense-rationale-qtime-predicate-summary.md

## Rollback/Contingency

- Each phase commits at every green sub-step. If a Lean addition turns out to be unprovable within
  budget, revert that phase's commits with `git revert`. Earlier green phases stay valid, because
  every phase only adds content.
- If Phase 2's equivalence does not go through (for example the countermodel's frame cannot be
  shown to satisfy `IsQTime`), stop and return `[PARTIAL]` with the exact failing goal. Do not
  weaken `IsQTime` or fall back to a statement "over `Rat`" without a revision.
- If 603's report concludes that no satisfactory ℚ-time predicate exists, Phases 1-4 cannot run.
  Return partial status and recommend a revision that goes back to plan 01's docstring-only scope.
- If implementation finds evidence that the dense class really is ℚ-only, which would contradict
  report 01, stop and recommend a revision. Do not start a rename under this plan.
