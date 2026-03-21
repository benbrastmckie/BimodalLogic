# Implementation Plan: Task #622

- **Task**: 622 - prove_applyRule_decreases_complexity
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: Task 490 (parent task - partial)
- **Research Inputs**: specs/622_prove_applyRule_decreases_complexity/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the `applyRule_decreases_complexity` theorem in Saturation.lean. This requires case analysis on all 16 tableau rules, showing that applying each rule produces formulas with strictly smaller total complexity. The proof follows a consistent pattern: unfold `totalComplexity`, simplify with `Formula.complexity` lemmas, and finish with `omega`. Existing complexity lemmas (`complexity_imp_sum`, `complexity_box`, `complexity_all_future`, `complexity_all_past`) provide the key inequalities.

### Research Integration

The research report identified:
- All 16 tableau rules and their input/output patterns
- Verified proof patterns for linear and branching cases
- Existing complexity lemmas at lines 234-255 of Saturation.lean
- Complexity calculations for compound patterns (And, Or, Neg, Diamond)

## Goals & Non-Goals

**Goals**:
- Complete the proof of `applyRule_decreases_complexity` theorem
- Remove all `sorry` placeholders from the proof
- Ensure the proof compiles without errors

**Non-Goals**:
- Refactoring existing complexity lemmas
- Optimizing proof performance (correctness over speed)
- Adding new helper lemmas beyond what is necessary

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pattern matching complexity for asAnd?, asOr?, etc. | Medium | Medium | Extract matched subformulas explicitly with `match` expressions |
| Goal state explosion with 16 cases | Low | Medium | Use `all_goals` and targeted tactics for similar cases |
| Unexpected complexity in branching cases | Medium | Low | Handle each branch membership case separately |

## Implementation Phases

### Phase 1: Simple Linear Rules (box, allFuture, allPast) [COMPLETED]

**Goal**: Prove the 6 simplest cases - rules that extract a single subformula from box/all_future/all_past.

**Tasks**:
- [ ] Prove `boxPos` case: `totalComplexity [pos A] < (A.box).complexity`
- [ ] Prove `boxNeg` case: `totalComplexity [neg A] < (A.box).complexity`
- [ ] Prove `allFuturePos` case: `totalComplexity [pos A] < (A.all_future).complexity`
- [ ] Prove `allFutureNeg` case: `totalComplexity [neg A] < (A.all_future).complexity`
- [ ] Prove `allPastPos` case: `totalComplexity [pos A] < (A.all_past).complexity`
- [ ] Prove `allPastNeg` case: `totalComplexity [neg A] < (A.all_past).complexity`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` (lines 328-338)

**Verification**:
- `lean_diagnostic_messages` shows no errors for these cases
- `lean_goal` at line 338 shows reduced `sorry` count

---

### Phase 2: Negation Linear Rules (negPos, negNeg) [COMPLETED]

**Goal**: Prove the 2 negation cases - rules that extract subformula from `A.imp .bot`.

**Tasks**:
- [ ] Prove `negPos` case: `totalComplexity [neg A] < (A.imp .bot).complexity`
- [ ] Prove `negNeg` case: `totalComplexity [pos A] < (A.imp .bot).complexity`

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`

**Verification**:
- Both negation cases compile without errors

---

### Phase 3: Implication Linear Rule (impNeg) [COMPLETED]

**Goal**: Prove the `impNeg` case - produces two formulas from implication.

**Tasks**:
- [ ] Prove `impNeg` case: `totalComplexity [pos A, neg B] < (A.imp B).complexity`
- [ ] Use `complexity_imp_sum` lemma to establish the inequality

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`

**Verification**:
- `impNeg` case compiles without errors

---

### Phase 4: Conjunction/Disjunction Linear Rules (andPos, orNeg) [COMPLETED]

**Goal**: Prove linear rules for And and Or patterns.

**Tasks**:
- [ ] Prove `andPos` case: `totalComplexity [pos A, pos B] < ((A.imp (B.imp .bot)).imp .bot).complexity`
- [ ] Prove `orNeg` case: `totalComplexity [neg A, neg B] < ((A.imp .bot).imp B).complexity`
- [ ] Handle `asAnd?` and `asOr?` pattern matching extraction

**Timing**: 40 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`

**Verification**:
- Both cases compile without errors
- Complexity arithmetic verified by `omega`

---

### Phase 5: Diamond Linear Rules (diamondPos, diamondNeg) [COMPLETED]

**Goal**: Prove diamond cases - extract subformula from `((A.imp .bot).box).imp .bot`.

**Tasks**:
- [ ] Prove `diamondPos` case: `totalComplexity [pos A] < (((A.imp .bot).box).imp .bot).complexity`
- [ ] Prove `diamondNeg` case: `totalComplexity [neg A] < (((A.imp .bot).box).imp .bot).complexity`
- [ ] Handle `asDiamond?` pattern matching extraction

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`

**Verification**:
- Both diamond cases compile without errors

---

### Phase 6: Branching Rules (impPos, andNeg, orPos) [COMPLETED]

**Goal**: Prove the 3 branching rules where goal becomes `forall branch in branches, ...`.

**Tasks**:
- [ ] Prove `impPos` case: both branches `[neg A]` and `[pos B]` have smaller complexity
- [ ] Prove `andNeg` case: both branches `[neg A]` and `[neg B]` have smaller complexity
- [ ] Prove `orPos` case: both branches `[pos A]` and `[pos B]` have smaller complexity
- [ ] Handle branch membership with `intro branch hmem` followed by case analysis

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`

**Verification**:
- All branching cases compile without errors
- `forall branch in branches` goals are fully discharged

---

### Phase 7: Final Verification and Cleanup [COMPLETED]

**Goal**: Verify complete proof compiles and clean up any redundant tactics.

**Tasks**:
- [ ] Run `lean_diagnostic_messages` on entire file
- [ ] Verify no `sorry` remains in `applyRule_decreases_complexity`
- [ ] Run `lake build` to confirm module compiles
- [ ] Review proof structure for potential simplification

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean`

**Verification**:
- `lake build` succeeds without errors
- No `sorry` in the theorem
- File compiles cleanly

## Testing & Validation

- [ ] `lean_diagnostic_messages` returns no errors for Saturation.lean
- [ ] `lean_goal` at theorem location shows "no goals" (proof complete)
- [ ] `lake build` compiles successfully
- [ ] Downstream theorems that depend on `applyRule_decreases_complexity` remain valid

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Decidability/Saturation.lean` - Modified with completed proof
- `specs/622_prove_applyRule_decreases_complexity/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the proof approach fails:
1. Preserve current partial proof with explicit `sorry` markers for failing cases
2. Document which specific cases are problematic
3. Consider creating helper lemmas for complex pattern matching
4. Fall back to term-mode proof for specific cases if tactic proof is difficult
