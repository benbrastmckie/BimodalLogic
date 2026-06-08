# Implementation Plan: Task #287

- **Task**: 287 - Add formula normalization pass before tableau expansion
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/287_formula_normalization_before_tableau/reports/01_normalization-research.md
- **Artifacts**: plans/01_normalization-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Add an explicit `normalizeFormula : Formula -> Formula` function that recursively traverses a formula and rebuilds it using only the 6 primitive constructors (atom, bot, imp, box, untl, snce). Since all derived operators are `def` abbreviations that Lean unfolds definitionally, this function is structurally the identity -- but it serves as a documented normalization contract, a guard against future non-`def` operator changes, and a normalization point for any formulas arriving from external sources. Wire the function into the `decide` entry point, prove it is the identity (so no proof transport is needed), and benchmark on c5/c6 to verify zero performance regression.

### Research Integration

Key findings from the research report:
- All 20+ derived operators (neg, top, and, or, diamond, always, sometimes, next, prev, weak_future, weak_past, release, weak_until, trigger, weak_since, strong_release, strong_trigger) are `def` abbreviations that Lean unfolds at elaboration time.
- Every formula in the codebase is already stored as a tree of the 6 primitive constructors.
- `normalizeFormula` is definitionally the identity function: `normalizeFormula phi = phi` by structural induction with `rfl` at every leaf/node.
- `DecisionResult phi` is parameterized by the original formula, so `DecisionResult (normalizeFormula phi) = DecisionResult phi` -- no proof transport needed.
- Existing `Normalization.lean` provides simp lemmas and `EnrichedFormula` infrastructure but no programmatic `normalizeFormula : Formula -> Formula` function.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Define `normalizeFormula : Formula -> Formula` that recurses over all 6 primitive constructors
- Prove `normalizeFormula_id : normalizeFormula phi = phi` by structural induction
- Wire `normalizeFormula` into the `decide` function before the fast-path axiom check
- Add unit tests verifying normalization on representative formulas
- Benchmark c5/c6 to confirm no performance regression

**Non-Goals**:
- NNF conversion or double-negation elimination (different semantic operation)
- Formula simplification or optimization (out of scope)
- Modifying the tableau rules or decomposition helpers
- Changing the `EnrichedFormula` fold/unfold infrastructure in `Normalization.lean`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Traversal adds measurable O(n) overhead | L | L | Benchmark confirms; for c5/c6 formulas this is negligible (~microseconds) |
| normalizeFormula_id proof does not close with rfl | L | L | Structural induction + simp should suffice; fallback to term-mode proof |
| Wiring into decide causes type mismatch | L | L | Since normalizeFormula is definitionally the identity, no type issues arise |
| Build regression from new import | L | L | Minimal import; verify with lake build |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Define normalizeFormula and prove identity theorem [COMPLETED]

**Goal**: Create the `normalizeFormula` function and prove it equals the identity.

**Tasks**:
- [x] Add `normalizeFormula : Formula -> Formula` to `Normalization.lean`, pattern-matching on all 6 primitive constructors and recursing into subformulas
- [x] Add `@[simp]` lemma `normalizeFormula_id (phi : Formula) : normalizeFormula phi = phi` proved by structural induction on `phi` with `rfl` at each case
- [x] Add docstring explaining that this function is the identity because all derived operators are `def` abbreviations, and its purpose is contract documentation and future-proofing
- [x] Verify with `lean_goal` that the proof closes cleanly
- [x] Run scoped build: `lake build Bimodal.Automation.Normalization`

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/Normalization.lean` - Add `normalizeFormula` function and `normalizeFormula_id` theorem

**Verification**:
- `normalizeFormula` compiles without errors
- `normalizeFormula_id` is sorry-free
- Scoped build passes

---

### Phase 2: Wire into decide and add tests [COMPLETED]

**Goal**: Integrate `normalizeFormula` into the decision procedure entry point and add unit tests.

**Tasks**:
- [x] Add `import Bimodal.Automation.Normalization` to `DecisionProcedure.lean` (if not already imported)
- [x] Insert `let phi_n := normalizeFormula phi` as the first line of `decide`, then use `phi_n` in place of `phi` for the fast-path and subsequent calls (since `phi_n` is definitionally equal to `phi`, `DecisionResult phi_n = DecisionResult phi`) *(deviation: altered -- used `let phi := normalizeFormula phi` with shadowing plus `have h_norm` for proof transport via `h_norm triangleright proof`, because Lean 4 let-bindings create distinct types requiring explicit rewriting)*
- [x] Verify that the `decide` function still type-checks with no changes to its return type
- [x] Create `Tests/BimodalTest/Automation/NormalizationTest.lean` with unit tests:
  - Test `normalizeFormula` on primitive formulas (atom, bot, imp, box, untl, snce)
  - Test on derived operator formulas (neg, and, or, diamond, always, sometimes, next, prev)
  - Test on nested combinations (e.g., `always (diamond p)`)
  - Verify `normalizeFormula phi == phi` for all test cases using `decide` or `native_decide`
- [x] Register the test file in `lakefile.lean` if needed (check existing test registration pattern) *(deviation: altered -- registered in BimodalTest.lean root imports rather than lakefile.lean, since BimodalTest already has its own lean_lib entry)*
- [x] Run scoped build: `lake build Bimodal.Metalogic.Decidability.DecisionProcedure`
- [x] Run test build: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Add import and wire `normalizeFormula` into `decide`
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - New test file

**Verification**:
- `decide` compiles with `normalizeFormula` wired in
- All existing tests still pass
- New normalization tests pass
- No new sorries or axioms introduced

---

### Phase 3: Benchmark c5/c6 and full build verification [NOT STARTED]

**Goal**: Confirm no performance regression via c5/c6 benchmarking and verify full project build.

**Tasks**:
- [ ] Run `lake build` for full project verification (zero errors expected)
- [ ] Run `lean_verify` on `normalizeFormula` and `normalizeFormula_id` to confirm no axioms
- [ ] Add `#eval` benchmark in the test file or `EnumBenchmark.lean`:
  - Generate c5 formulas and time `decide` on a representative sample (e.g., 100 formulas)
  - Compare with baseline (the normalization pass should add negligible overhead since it is the identity)
  - Print timing results
- [ ] Document benchmark results in a brief comment in the test file
- [ ] Verify `#print axioms normalizeFormula` shows no axioms
- [ ] Verify `#print axioms normalizeFormula_id` shows no axioms

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - Add benchmark `#eval` blocks

**Verification**:
- Full `lake build` passes with zero errors
- No new sorries or axioms anywhere in the project
- Benchmark shows no measurable regression (normalization overhead < 1% of total decide time)

## Testing & Validation

- [ ] `normalizeFormula` compiles and is well-typed
- [ ] `normalizeFormula_id` proof is sorry-free and axiom-free
- [ ] `decide` function compiles with `normalizeFormula` wired in
- [ ] All existing tests pass (no regressions)
- [ ] New unit tests cover primitive and derived operator formulas
- [ ] c5/c6 benchmark shows no performance regression
- [ ] Full `lake build` passes with zero errors
- [ ] `#print axioms` confirms no new axioms

## Artifacts & Outputs

- `Theories/Bimodal/Automation/Normalization.lean` - Extended with `normalizeFormula` and `normalizeFormula_id`
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - `decide` wired with normalization
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - New test and benchmark file
- `specs/287_formula_normalization_before_tableau/plans/01_normalization-plan.md` - This plan

## Rollback/Contingency

If the normalization pass introduces any issues:
1. Remove the `let phi_n := normalizeFormula phi` line from `decide` (single-line revert)
2. The `normalizeFormula` function and theorem can remain in `Normalization.lean` as documentation without being wired into the decision procedure
3. No other code depends on the normalization pass, so removal is clean
