# Implementation Plan: Task #440

- **Task**: 440 - finite_frame_discharge_of_spherical_and_limit
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: specs/440_finite_frame_discharge_of_spherical_and_limit/reports/01_finite-spherical-limit-discharge.md
- **Artifacts**: plans/01_finite-spherical-discharge.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The task's core Lean deliverable has **already landed in the live tree since the round-1 report
was written**. `TaskFrame.sInter_nonempty_of_directed_of_minimal` and
`TaskFrame.spherical_of_finite` both exist in `FormalSystem/Semantics/TaskFrame.lean` with the two
required imports, full obstruction docstring, and the "do not re-derive the class helpers" note;
`cor:spherical-finite` is tracked in `specs/paper-definitions-of-record.md` with both a verbatim
prose entry and a manifest row. What remains is the **evidence and repair** half of the task: the
WLEM regression test that makes the impossible acceptance test permanently un-chaseable, the
build-breaking axiom-profile pins for the two facts the description declares assertable, and the
four stale docstring passages in `Extension.lean`. This plan does exactly that remainder, and
records the withdrawn Deliverable 2 as a reasoned exclusion rather than silently dropping it.

### Research Integration

The round-1 report (dated 2026-08-12) is integrated as follows:

| Report recommendation | Status against the live tree (verified at plan time, 2026-08-17) | Handled by |
|---|---|---|
| 1. Re-pin `cor:spherical-finite` in the record | **Already done** — prose entry and manifest row `76258a4c…` both present; residual-gap paragraph rewritten to say all three anchors are now tracked | Phase 1 confirms only |
| 2. Land the two-lemma decomposition + two imports | **Already done** — `sInter_nonempty_of_directed_of_minimal` and `spherical_of_finite` present; `Mathlib.Order.Minimal` and `Mathlib.Data.Fintype.Powerset` both imported | Phase 1 confirms only |
| 3. Replace the acceptance test (axiom-free core; exact profile; no Zorn) | **Not done** — no guard exists anywhere in `Tests/` | Phase 3 |
| 4. Land `wlem_of_spherical` in `Tests/` | **Not done** — the identifier appears nowhere in `Tests/` or `FormalSystem/` | Phase 2 |
| 5. Docstring obstruction note on `spherical_of_finite` | **Already done** — the full ZF-vs-ZFC / Diaconescu / WLEM note is in place | Phase 1 confirms only |
| 6. Do NOT re-derive `spherical_of_subsingleton` et al. | **Already recorded** in the docstring; still needs a mechanical tripwire | Phase 3 (tripwire), Phase 5 (re-check) |
| 7. Repair `Extension.lean`'s four stale passages + cost note | **Not done** — all four passages verified still present | Phase 4 |
| 8. Defer `extension_of_finite` / `occurrence_of_finite` | Deferred; no confirmation from the downstream consumers exists | Phase 5 (reasoned exclusion) |
| 9. Additive-only remit, no `TaskFrame` field changes | Binding constraint on every phase | all phases |

The report's §2.2 warning — that a sibling task's snippet calling `Set.Finite.exists_minimal` does
not compile against this Mathlib — is now moot: the landed proof uses
`exists_minimal_of_wellFoundedLT`, which is the corrected route.

### Prior Plan Reference

No prior plan. `plans/` was empty at dispatch.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

**Goals**:
- Land `wlem_of_spherical` in `Tests/` as permanent, axiom-pinned evidence that a
  `Classical.choice`-free proof of `spherical_of_finite` cannot exist.
- Pin, as build-breaking guards, the two facts the task declares assertable: that
  `sInter_nonempty_of_directed_of_minimal` is axiom-free, and that `spherical_of_finite` has
  exactly `[propext, Classical.choice, Quot.sound]`.
- Pin `spherical_of_subsingleton` at `[propext]` as the mechanical tripwire against a future
  "helpful" consolidation through `spherical_of_finite`.
- Repair the four stale passages in `Extension.lean`'s docstrings and add the cost note.
- Confirm — not redo — the already-landed lemma pair, imports, obstruction docstring, and
  `cor:spherical-finite` record entry.

**Non-Goals**:
- Re-proving, re-stating, or re-deriving `spherical_of_finite` or
  `sInter_nonempty_of_directed_of_minimal`; both are landed and green.
- Landing `extension_of_finite` / `occurrence_of_finite`. Withdrawn; they are contentless
  coercion wrappers absent confirmation from the downstream model-checker consumers.
- Any "Limit for finite Int frames" or finite-Int axiom-bundle work. `limit`, `serial`,
  `spherical`, and `comp` are `TaskFrame` fields; there is nothing to bundle.
- Changing any `TaskFrame` field, any extension-chain proof, or any signature. In particular
  `hF_nonempty`'s explicit `w` argument is **flagged only**, never changed here.
- Any edit under `/home/benjamin/Philosophy/Papers/`. The paper is read-only ground truth.
- Touching `Boneyard`, or re-tracking `lem:nesting` / `lem:nonempty`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer re-lands the already-present lemma pair, producing a duplicate declaration or churn | H | M | Phase 1 is a mandatory confirm-first gate that grep-verifies both lemmas and both imports before any write; Phases 2-4 touch no `TaskFrame.lean` declaration |
| `wlem_of_spherical`'s directedness proof drifts classical (`by_cases`, `tauto`, `Classical.*`), silently destroying the whole point | H | M | Phase 2 forbids those tactics by name; the phase does not close until `#print axioms` reports exactly `[propext, Quot.sound]` |
| `#guard_msgs in #print axioms` does not capture the info message in this toolchain | M | L | Phase 3 measures the real output first (Phase 1) and pins verbatim; documented fallback is a plain `#print axioms` plus a prose-recorded expected value if the guard form does not elaborate |
| "No Zorn dependency" is asserted via `#print axioms`, which cannot express it | M | M | Phase 3 records the import-graph argument instead: `TaskFrame.lean` does not import the extension chain, so a dependency on `exists_maximal_extension` is structurally impossible |
| A docstring repair in `Extension.lean` crosses out of the comment region and breaks elaboration | M | L | Phase 4 carries tier `local`, i.e. a build of that module, not a diff read-through |
| Re-deriving or consolidating the choice-free class helpers regresses their profiles | H | L | Phase 3's `spherical_of_subsingleton` tripwire plus Phase 5's re-measurement |
| Task numbers leak into `FormalSystem/**` or `Tests/**` docstrings | M | M | Every phase's docstring text cites `wlem_of_spherical`, `cor:spherical-finite`, or a filename — never a task number, per `.claude/rules/no-task-references-in-deliverables.md` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel. Territory is disjoint in wave 2: Phase 2
owns `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`, Phase 4 owns
`FormalSystem/Semantics/Extension/Extension.lean`.

### Phase 1: Baseline confirmation and test-module scaffold [NOT STARTED]

**Goal**: Establish, by measurement rather than assumption, exactly what is already landed; capture
the verbatim `#print axioms` output strings that Phase 3 will pin; and create the empty, wired test
module that Phases 2-3 fill.

**Tasks**:
- [ ] Run `bash scripts/check-paper-definitions.sh`; record the outcome case. Case (a) or (b): proceed. Case (c): STOP and report the drifted anchors.
- [ ] Confirm `specs/paper-definitions-of-record.md` carries both the `cor:spherical-finite` prose entry (verbatim `\begin{Cthm}` block) and the manifest row ending `76258a4c835d4fa0dde3fd037da52e706d0f20c9d7872ab523d3b81597b99b9d`. Do NOT re-add either.
- [ ] Confirm `FormalSystem/Semantics/TaskFrame.lean` declares both `sInter_nonempty_of_directed_of_minimal` and `spherical_of_finite`, and imports both `Mathlib.Order.Minimal` and `Mathlib.Data.Fintype.Powerset`. Do NOT re-add any of them.
- [ ] Confirm `spherical_of_finite`'s docstring already carries the obstruction note (ZF-vs-ZFC, Diaconescu, WLEM, no-Zorn) and the "do not re-derive the class helpers" note. Do NOT rewrite them.
- [ ] Measure and record verbatim, into the progress file, the exact output of `#print axioms` for: `FormalSystem.Semantics.TaskFrame.sInter_nonempty_of_directed_of_minimal`, `FormalSystem.Semantics.TaskFrame.spherical_of_finite`, `FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton`. These three strings are Phase 3's only source of expected text.
- [ ] Create `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`: license header, `import FormalSystem.Semantics.TaskFrame`, `import Mathlib.Algebra.Order.Group.Int`, namespace `BimodalTest.Semantics`, and a module docstring stating the file's purpose (permanent evidence that the choice-free acceptance test is unsatisfiable, plus the axiom-profile pins). No theorems yet.
- [ ] Wire the new module into `Tests/BimodalTest.lean` beside `import BimodalTest.Semantics.TaskFrameTest`.
- [ ] Verify `lake build BimodalTest` is green.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts that recommendations 1, 2, 5, and 6 of the research report
are already fully landed, and that recommendations 3, 4, and 7 are entirely absent. Confirm by the
greps above before writing anything. If any part of 1/2/5/6 is found *missing*, land only the
missing part and record the deviation; if any part of 3/4/7 is found already *present*, drop the
corresponding phase and record it as a reasoned exclusion rather than duplicating it.

**Files to modify**:
- `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` - new file, header and module docstring only
- `Tests/BimodalTest.lean` - one added import line

**Verification**:
- `bash scripts/check-paper-definitions.sh` reports case (a) or (b)
- `lake build BimodalTest` green
- Three `#print axioms` output strings recorded verbatim in the progress file

---

### Phase 2: Land `wlem_of_spherical` [NOT STARTED]

**Goal**: Land the constructive derivation of weak excluded middle from `Spherical` at the finite
carrier `Bool` over `D = Int`, as the permanent evidence that no `Classical.choice`-free proof of
`spherical_of_finite` can exist.

**Tasks**:
- [ ] In `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`, define `R : Bool → Int → Bool → Prop := fun w d u => (d = 0 ∧ w = u) ∨ (d = 3)`, with a docstring recording that `Fib R w 0 = {w}` and `Fib R w 3 = Set.univ`.
- [ ] Prove the family `S := {s | (s = {true} ∧ P) ∨ (s = {false} ∧ ¬P) ∨ s = Set.univ}` is directed, by `rintro` on the membership disjunctions. The two cross cases (`P` and `¬P` simultaneously assumed) discharge by `absurd`.
- [ ] Prove every member of `S` is a nonempty fiber of `R`, constructively.
- [ ] State and prove `theorem wlem_of_spherical (hSph : TaskFrame.Spherical R) (P : Prop) : ¬¬P ∨ ¬P`, closing by `cases` on the intersection witness `b : Bool` and `by decide` on the two `Bool` disequalities.
- [ ] Write the theorem's docstring: what it proves, and why it exists — a future dispatch reading it must understand that "fixing" `spherical_of_finite`'s axiom profile is provably impossible, not merely unattempted.
- [ ] Verify `#print axioms wlem_of_spherical` reports exactly `[propext, Quot.sound]`.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The report estimates the full derivation at roughly 50 lines with a nine-case
`rintro` for directedness. Confirm by writing it. If the constructive directedness proof needs more
cases than nine, that refines the estimate and is fine; it is **never** a licence to reach for
`by_cases`, `tauto`, `Classical.byCases`, `Classical.em`, or any `Classical.*` term. A proof that
elaborates but reports `Classical.choice` in its axiom profile has failed this phase, not passed it.

**MUST NOT**:
- Use any classical tactic or term anywhere in this file's proofs.
- Reference a task number in any docstring — cite `spherical_of_finite`, `cor:spherical-finite`, or the filename.

**Files to modify**:
- `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` - the relation, the directedness and nonemptiness lemmas, and `wlem_of_spherical`

**Verification**:
- `lake build BimodalTest` green
- `#print axioms wlem_of_spherical` reports exactly `[propext, Quot.sound]` — no `Classical.choice`

---

### Phase 3: Pin the axiom profiles as build-breaking guards [NOT STARTED]

**Goal**: Convert the three measured axiom profiles, plus the `spherical_of_subsingleton` tripwire,
into guards that break the build if any of them moves — replacing the unsatisfiable choice-free
acceptance test the task retracted.

**Tasks**:
- [ ] Add a `#guard_msgs in #print axioms` block for `FormalSystem.Semantics.TaskFrame.sInter_nonempty_of_directed_of_minimal`, pinning the axiom-free result, using the string measured in Phase 1.
- [ ] Add a `#guard_msgs in #print axioms` block for `FormalSystem.Semantics.TaskFrame.spherical_of_finite`, pinning exactly `[propext, Classical.choice, Quot.sound]` and no other axiom.
- [ ] Add a `#guard_msgs in #print axioms` block for `FormalSystem.Semantics.TaskFrame.spherical_of_subsingleton`, pinning `[propext]`. Docstring this one explicitly as the tripwire against re-deriving it through `spherical_of_finite`.
- [ ] Add the guard for `wlem_of_spherical`'s `[propext, Quot.sound]` profile from Phase 2.
- [ ] Record the no-Zorn claim as prose with import-graph evidence: `TaskFrame.lean` does not import `FormalSystem.Semantics.Extension.*`, so a dependency on `PartialHistory.exists_maximal_extension` is structurally impossible; state that `#print axioms` cannot express this and that the import direction is the evidence. Do not fabricate an axiom-based test for it.
- [ ] Add a short section docstring explaining how to react when one of these guards fires: the expected block is updated in the same commit as the change that moved it, with the move justified — never updated to make a red build green.

**Timing**: 1 hour

**Depends on**: 1, 2

**Verification Tier**: local

**Scope Hypothesis**: Four guarded declarations. Every expected block must be copied from the
Phase 1 / Phase 2 measured output, never hand-transcribed from the research report. If
`#guard_msgs in #print axioms` does not capture the info message in this toolchain, fall back to a
plain `#print axioms` plus the expected value recorded in the adjacent docstring, and record the
downgrade explicitly — a silently non-gating "guard" is worse than an honest comment.

**Files to modify**:
- `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` - the four guards plus the no-Zorn record

**Verification**:
- `lake build BimodalTest` green with all guards satisfied
- Each guard's expected block matches the Phase 1/2 measurement character for character

---

### Phase 4: Repair `Extension.lean`'s stale docstrings and add the cost note [NOT STARTED]

**Goal**: Bring `Extension.lean`'s docstrings back into agreement with the post-refactor tree they
already partly describe, and record what `spherical_of_finite` costs.

**Tasks**:
- [ ] Repair the module-docstring passage beginning "*Spherical* is **not** threaded into `extension`'s proof directly: it enters only as a hypothesis binder…the four binders are pass-through arguments to `step` alone." There are no binders; the axioms are `TaskFrame` fields reaching `step` as projections.
- [ ] Repair the module-docstring passage "…because the structure carries no `Nonempty WorldState` field yet." `TaskFrame.nonempty` exists.
- [ ] Repair `hF_nonempty`'s own docstring passage "This needs a world state…which `TaskFrame` does not [supply]". Same reason. Record that `w` remains an explicit argument by choice here, and that `Validity.lean`'s `hF_nonempty_of_frameAxioms` already feeds it `F.nonempty.some`.
- [ ] Reword `extension`'s docstring line "*Spherical* is not threaded in directly — it is handed to `step`" so it does not imply a hypothesis binder.
- [ ] Add the cost note: `spherical_of_finite` is the only discharge route for an arbitrary relation on a finite carrier; it costs no Zorn but unavoidably costs `Classical.choice`; the reason is the WLEM derivation, cited by the name `wlem_of_spherical` and its file.
- [ ] Do NOT change `hF_nonempty`'s signature. Record the "it could now drop `w`" observation as a flagged follow-up in the phase notes only.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Exactly four stale passages, confirmed present at plan time by direct read.
Anchor edits on the **quoted text**, not on line numbers — the report's line citations (45-48,
66-68, 181-182, 239-242) have already drifted once and will drift again. Re-grep each quoted phrase
immediately before editing. If a fifth stale passage is found, repair it and record the addition; if
one of the four is already repaired, record it as a reasoned exclusion.

**MUST NOT**:
- Change any declaration, signature, or proof in this file — docstring text only.
- Reference a task number anywhere in the file.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Extension.lean` - four docstring passages plus the added cost note

**Verification**:
- `lake build FormalSystem.Semantics.Extension.Extension` green
- `git diff` confirms every changed hunk lies inside a `/-! -/` or `/-- -/` region and no declaration line moved

---

### Phase 5: Final gate, deferral record, and summary [NOT STARTED]

**Goal**: Run the full gate set, confirm no regression to the choice-free class helpers, record the
withdrawn Deliverable 2 as a reasoned exclusion, and write the summary artifact.

**Tasks**:
- [ ] `lake build FormalSystem` green.
- [ ] `lake build BimodalTest` green.
- [ ] Re-run `bash scripts/check-paper-definitions.sh`; expect case (a) or (b).
- [ ] Re-measure `#print axioms` for `spherical_of_subsingleton`, `spherical_of_permissive`, and `spherical_of_eq`; confirm none moved from its Phase 1 baseline.
- [ ] Confirm the three `Unit`-carriered universal frames (`trivialFrame`, `intTimeFrame`, `genericTimeFrame`) are unaffected.
- [ ] Record the reasoned exclusion for `extension_of_finite` / `occurrence_of_finite`: not landed, because they are contentless coercion wrappers over the existing `Coe (FiniteTaskFrame D) (TaskFrame D)` instance and no downstream consumer has confirmed it wants a `FiniteTaskFrame`-named citation handle. Evidence: `extension` and `occurrence` take only `(F : TaskFrame D)`.
- [ ] Record the flagged-only follow-up: `hF_nonempty` could drop its explicit `w` argument now that `TaskFrame.nonempty` exists. Signature change, outside this task's additive-only remit.
- [ ] Write `summaries/01_finite-spherical-discharge-summary.md`.

**Timing**: 0.75 hours

**Depends on**: 3, 4

**Verification Tier**: full

**Files to modify**:
- `specs/440_finite_frame_discharge_of_spherical_and_limit/summaries/01_finite-spherical-discharge-summary.md` - new

**Verification**:
- Both `lake build` targets green
- Paper-definition lint case (a) or (b)
- No axiom-profile movement on any pre-existing declaration

---

## Testing & Validation

- [ ] `lake build FormalSystem` completes with no errors
- [ ] `lake build BimodalTest` completes with no errors, all `#guard_msgs` satisfied
- [ ] `bash scripts/check-paper-definitions.sh` reports case (a) or case (b)
- [ ] `#print axioms wlem_of_spherical` = `[propext, Quot.sound]`
- [ ] `#print axioms sInter_nonempty_of_directed_of_minimal` reports no axiom dependency
- [ ] `#print axioms spherical_of_finite` = `[propext, Classical.choice, Quot.sound]`, no other axiom
- [ ] `#print axioms spherical_of_subsingleton` = `[propext]`, unchanged from baseline
- [ ] No `sorry` and no custom axiom introduced anywhere
- [ ] No task-number reference in any file outside `specs/**`

## Artifacts & Outputs

- `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean` (new) — `wlem_of_spherical` plus four axiom-profile guards
- `Tests/BimodalTest.lean` (modified) — one import line
- `FormalSystem/Semantics/Extension/Extension.lean` (modified) — four docstring repairs plus the cost note
- `specs/440_finite_frame_discharge_of_spherical_and_limit/plans/01_finite-spherical-discharge.md` (this file)
- `specs/440_finite_frame_discharge_of_spherical_and_limit/summaries/01_finite-spherical-discharge-summary.md`

## Rollback/Contingency

Every change is additive and confined to two files plus one import line. Rollback is
`git revert` of the phase commits, in reverse order; nothing in `FormalSystem/` depends on the new
test module, and the `Extension.lean` changes are docstring-only, so reverting either cannot break
the library build.

If Phase 2's constructive derivation cannot be completed without classical reasoning, do **not**
land a classical version — a `Classical.choice`-carrying `wlem_of_spherical` proves nothing and
would actively mislead. Mark Phase 2 `[BLOCKED]`, land Phases 3 (minus the WLEM guard) and 4, and
report the obstruction. If `#guard_msgs` cannot gate `#print axioms` in this toolchain, Phase 3
downgrades to recorded expectations as described in its Scope Hypothesis; that is a documented
partial, not a silent pass.
