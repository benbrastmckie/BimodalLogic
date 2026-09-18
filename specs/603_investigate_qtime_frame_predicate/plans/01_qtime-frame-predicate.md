# Implementation Plan: Task #603

- **Task**: 603 - Investigate a ℚ-time frame predicate (`TaskFrame.IsQTime`)
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None (coordinate with in-flight task 588 edits under `Metalogic/`; see Risks)
- **Research Inputs**: specs/603_investigate_qtime_frame_predicate/reports/01_qtime-frame-predicate.md
- **Artifacts**: plans/01_qtime-frame-predicate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement the research report's recommended candidate (a): an intrinsic, `Prop`-valued
`TaskFrame.IsQTime` ("divisible + pairwise commensurable") in `Semantics/FrameProperty.lean`,
parallel to `IsZTime`/`IsRTime`, with the bridge `isDense_of_isQTime`; a validity notion
`ValidQTime := ValidOnFrames TaskFrame.IsQTime` in `Semantics/Validity.lean` beside
`ValidComplete`; ℚ membership `isQTime_rat` plus a completeness engine `derivable_of_validQTime`
in `Metalogic/BXCanonical/Completeness.lean` (with `derivable_of_validDense` reduced to a
one-liner through it); and the headline `validQTime_iff_validDense` wherever soundness and
completeness meet. No new `FrameClass` constructor, no `Sat` changes, no sorry, no new axioms.
All core code was already verified sorry-free by `lean_run_code` in the report's Appendix.

### Research Integration

- Definition, bridge, ℚ instance, and iff are transcribed from the report Appendix (verified;
  `#print axioms` = `[propext, Classical.choice, Quot.sound]`).
- `IsQTime` is a plain `def` (never a `Sat` target; consumed by projection), not `abbrev`, not
  `class`. The definition and bridge compile at `FrameProperty.lean`'s existing imports; the
  bridge proof must avoid `norm_num`/`abel`/`linarith` (unavailable/ineffective at that layer).
- `isQTime_rat` needs `field_simp` and therefore lives downstream (Completeness.lean).
- Candidates (b) `≃+o ℚ`, (c) countable+dense, (d1) Archimedean+divisible+countable are rejected
  with reasons the docstring must record (near-miss groups `ℤ`, `ℤ[1/2]`, `ℚ+ℚ√2`, `ℚ ×ₗ ℚ`).
- Set-based strong completeness over ℚ-time is NOT free (ultrapowers of ℚ are non-Archimedean);
  record as open in the `ValidQTime` docstring. `ratIso : IsQTime → Nonempty (≃+o ℚ)` is deferred.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap consulted (no roadmap_flag in this dispatch).

## Goals & Non-Goals

**Goals**:
- `TaskFrame.IsQTime` + `TaskFrame.isDense_of_isQTime` in `FrameProperty.lean`, with module
  docstring updated ("Main Definitions", "Why five predicates" -> six).
- `ValidQTime` and `validQTime_of_validDense` in `Validity.lean`.
- `isQTime_rat`, `derivable_of_validQTime` in `BXCanonical/Completeness.lean`;
  `derivable_of_validDense` re-proved through it.
- `validQTime_iff_validDense` (sorry-free, standard axioms only).
- A small test file exercising the new API; full `lake build` green.

**Non-Goals**:
- `ratIso` / `≃+o ℚ` classification in `DurationClassification.lean`, and a `ValidRat` transfer.
- Set-based strong completeness / compactness over ℚ-time (open research).
- Finite-context consequence completeness over ℚ-time (cheap but needs a P-indexed consequence
  layer; mention as a follow-up in the docstring only).
- Any `FrameClass` constructor or `FrameClass.Sat` change.
- Paper/manual edits (flag the `metalogic.tex` T^c = ℚ strong-completeness sketch to the
  paper-sync chain in the summary, do not edit it).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent task 588 edits to `Metalogic/` (incl. possibly `Completeness.lean`) | M | M | Before Phase 2, `git status`/`git log -3 -- <file>`; if dirty from another session, put `isQTime_rat`/`derivable_of_validQTime` in the new `Metalogic/QTime.lean` instead and leave `derivable_of_validDense` untouched |
| `validQTime_iff_validDense` needs `soundness_dense_valid` (in `Metalogic/Soundness.lean`), which `Completeness.lean` may not import | M | H | Place the iff in a new `FormalSystem/Metalogic/QTime.lean` importing both; register in `FormalSystem/Metalogic.lean` |
| Reusing `derivable_of_validDense` refactor breaks downstream consumers (Deterministic/Engines copies the script, StrongCompleteness refers by name) | L | L | Keep the name and signature identical; only the body changes; full build in Phase 4 |
| `nsmul`/`zsmul` coercion friction | L | L | Use the Appendix statements verbatim |
| Tactic unavailability at `FrameProperty` layer | L | M | Use the verified term-style proof (`two_nsmul`, `add_nonpos`, `add_sub_cancel`, `lt_add_of_pos_right`) |
| `assert_not_exists` guard in `FrameProperty.lean` | L | L | Add no imports to that file |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Define IsQTime and its density bridge [COMPLETED]

**Goal**: Add the intrinsic ℚ-time predicate and `isDense_of_isQTime` to `FrameProperty.lean`.

**Tasks**:
- [x] Insert `def TaskFrame.IsQTime` after `TaskFrame.IsRTime` (report Appendix, verbatim):
  divisibility clause `∀ n : ℕ, n ≠ 0 → Function.Surjective (fun x : F.Duration => n • x)` and
  commensurability clause `∀ a b, a ≠ 0 → ∃ (m : ℤ) (n : ℕ), n ≠ 0 ∧ (n : ℤ) • b = m • a`.
- [x] Docstring: why intrinsic rather than `≃+o ℚ` (IsZTime/intIso pattern, keeps ℚ out of the
  lower semantic layer); why no density conjunct (derivable, unlike `IsRTime`); which near-miss
  group each clause excludes (`ℤ`, `ℤ[1/2]` fail divisibility; `ℚ+ℚ√2`, `ℚ ×ₗ ℚ` fail
  commensurability); why candidate (c) fails (only `≃o`); that it is not a `FrameClass`
  constructor (precedent: `ValidComplete`); that the `≃+o ℚ` classification is deferred.
- [x] Add `theorem TaskFrame.isDense_of_isQTime` next to `isDense_of_isRTime` (verified proof).
- [x] Update module docstring "Main Definitions" and "Why five predicates" section (six frame
  predicates plus determinism), and mention `IsQTime` in "The two narrowed classes" section
  (now three narrowed classes, or add a sentence explaining ℚ-time as a class inside `IsDense`).
- [x] No task-number references in Lean docstrings.

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/FrameProperty.lean` - new def, bridge theorem, docstring updates

**Verification**:
- `lake build FormalSystem.Semantics.FrameProperty` succeeds with no new warnings.
- `lean_verify TaskFrame.isDense_of_isQTime` shows only standard axioms.
- No new imports added.

---

### Phase 2: ValidQTime and the ℚ completeness engine [COMPLETED]

**Goal**: Add `ValidQTime` and route the dense completeness engine through ℚ-time.

**Tasks**:
- [x] Pre-check: `git status --short` and `git log -3 --` on `Validity.lean` and
  `BXCanonical/Completeness.lean`; if another session has uncommitted edits there, apply the
  fallback in Risks (put the Completeness.lean items in `Metalogic/QTime.lean`).
- [x] `Validity.lean`, beside `ValidComplete`: `def ValidQTime (φ : Formula) : Prop :=
  ValidOnFrames TaskFrame.IsQTime φ`, docstring stating it equals `ValidDense`
  (`validQTime_iff_validDense`), that only weak (and finite-context) completeness transfers, and
  that set-based strong completeness over ℚ-time is open (ultrapowers of ℚ are non-Archimedean).
- [x] `Validity.lean`: `theorem validQTime_of_validDense {φ} (h : ValidDense φ) : ValidQTime φ :=
  ValidOnFrames.mono (fun F hF => TaskFrame.isDense_of_isQTime hF) h` (adjust if `ValidDense`
  must first be unfolded via `validDense_iff_validIn_dense`). *(deviation: altered — placed in `namespace Validity` beside `validRTime_of_validComplete`, per local convention; full name `Validity.validQTime_of_validDense`)*
- [x] `Completeness.lean`: `theorem isQTime_rat (F : FrameOver (TemporalOrder.of ℚ)) :
  F.toTaskFrame.IsQTime` (verified proof).
- [x] `Completeness.lean`: `theorem derivable_of_validQTime (φ) : ValidQTime φ → Derivable
  FrameClass.Dense [] φ` — body of current `derivable_of_validDense` with `isQTime_rat F` in
  place of `inferInstance`.
- [x] Re-prove `derivable_of_validDense` as `fun h => derivable_of_validQTime φ
  (validQTime_of_validDense h)`, keeping name, signature, and "Sorry Status" docstring accurate.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - `ValidQTime`, `validQTime_of_validDense`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` - `isQTime_rat`,
  `derivable_of_validQTime`, slimmed `derivable_of_validDense`

**Verification**:
- `lake build FormalSystem.Metalogic.BXCanonical.Completeness` plus direct downstream modules
  (`FormalSystem.Metalogic.Deterministic.Engines`, `FormalSystem.Metalogic.StrongCompleteness`)
  succeed.
- `lean_verify` on `derivable_of_validQTime` and `derivable_of_validDense`: standard axioms only.

---

### Phase 3: validQTime_iff_validDense [COMPLETED]

**Goal**: Close the loop: ℚ-time validity equals dense validity.

**Tasks**:
- [x] Check whether `Completeness.lean` transitively imports `Metalogic/Soundness.lean`
  (`soundness_dense_valid`). If yes, the iff may go at the end of `Completeness.lean`; otherwise
  (expected) create `FormalSystem/Metalogic/QTime.lean` importing
  `FormalSystem.Metalogic.BXCanonical.Completeness` and `FormalSystem.Metalogic.Soundness`,
  with a module docstring summarizing the ℚ-time class, the iff, and open questions.
- [x] Prove `theorem validQTime_iff_validDense (φ) : ValidQTime φ ↔ ValidDense φ` as
  forward direction: `obtain ⟨d⟩ := derivable_of_validQTime φ h; exact soundness_dense_valid d`;
  backward direction: `validQTime_of_validDense` (as in the report Appendix).
- [x] If a new file was created, add `import FormalSystem.Metalogic.QTime` to
  `FormalSystem/Metalogic.lean` and a one-line mention in its module docstring.

**Timing**: 45 minutes

**Depends on**: 2

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/QTime.lean` (new, expected) - the iff
- `FormalSystem/Metalogic.lean` - import registration

**Verification**:
- `lake build FormalSystem.Metalogic.QTime` (or the host module) succeeds.
- `lean_verify validQTime_iff_validDense`: exactly `propext`, `Classical.choice`, `Quot.sound`.

---

### Phase 4: Tests and full build [NOT STARTED]

**Goal**: Exercise the API and confirm the whole tree is green.

**Tasks**:
- [ ] Add `Tests/BimodalTest/Semantics/QTimeTest.lean` (or extend `SemanticPropertyTest.lean`,
  following local convention) with: `isQTime_rat` applied to a ℚ frame, `isDense_of_isQTime`
  usage, `validQTime_iff_validDense` usage, and `#print axioms` checks. Optionally a negative
  example (the ℤ duration group fails divisibility at `n = 2`) if cheap.
- [ ] Register the test file in the test library root if files are listed explicitly.
- [ ] Run full `lake build` (and the test target); fix any fallout.
- [ ] `grep -n "sorry" ` on all touched files returns nothing new; run the repo task-reference
  lint over touched non-specs files.

**Timing**: 30 minutes

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `Tests/BimodalTest/Semantics/QTimeTest.lean` (new) - API tests
- `Tests/BimodalTest/Semantics.lean` or equivalent root (if tests are enumerated)

**Verification**:
- `lake build` exits 0 with no new warnings or sorries.
- Test file compiles; `#print axioms` outputs show only standard axioms.

## Testing & Validation

- [ ] `lake build` green across the tree.
- [ ] `TaskFrame.isDense_of_isQTime`, `isQTime_rat`, `derivable_of_validQTime`,
  `derivable_of_validDense`, `validQTime_iff_validDense` all verify with standard axioms only.
- [ ] `FrameProperty.lean` import list unchanged; `assert_not_exists` guard intact.
- [ ] No `FrameClass` constructor added; `FrameClass.Sat` untouched.
- [ ] No task-number references in deliverable files.

## Artifacts & Outputs

- Modified: `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/Validity.lean`,
  `FormalSystem/Metalogic/BXCanonical/Completeness.lean`, `FormalSystem/Metalogic.lean`
- New: `FormalSystem/Metalogic/QTime.lean`, `Tests/BimodalTest/Semantics/QTimeTest.lean`
- Summary: `specs/603_investigate_qtime_frame_predicate/summaries/01_qtime-frame-predicate-summary.md`
  (note the `metalogic.tex` strong-completeness-over-ℚ sketch for the paper-sync chain)

## Rollback/Contingency

All changes are additive except the body of `derivable_of_validDense`; each phase is committed
separately, so reverting a phase's commit restores the previous state. If the refactor of
`derivable_of_validDense` causes unexpected downstream breakage, keep its original body and have
`derivable_of_validQTime` duplicate the script (as the report's verified snippet already does).
