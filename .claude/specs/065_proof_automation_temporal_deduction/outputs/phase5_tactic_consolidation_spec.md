# Phase 5: Tactic Consolidation - Implementation Specification

## Metadata
- **Phase**: 5 (Tactic Consolidation)
- **Plan**: 065-001-proof-automation-completion-plan.md
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
- **Complexity**: MEDIUM (metaprogramming refactoring)
- **Estimated Duration**: 6-8 hours
- **Dependencies**: NONE (independent phase)

## Objective

Reduce tactic code duplication through factory patterns without changing functionality. All 110+ TacticsTest tests must continue passing.

## Current State Analysis

### Duplication Pattern 1: Operator K Tactics (52 lines → ~25 lines)

**modal_k_tactic** (lines 216-241):
```lean
elab "modal_k_tactic" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType
  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>
    match formula with
    | .app (.const ``Formula.box _) innerFormula =>
      let modalKConst := mkConst ``Derivable.modal_k
      let newGoals ← goal.apply modalKConst
      replaceMainGoal newGoals
    | _ => throwError "modal_k_tactic: expected goal formula to be □φ, got {formula}"
  | _ => throwError "modal_k_tactic: goal must be derivability relation Γ ⊢ φ, got {goalType}"
```

**temporal_k_tactic** (lines 260-285):
```lean
elab "temporal_k_tactic" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType
  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>
    match formula with
    | .app (.const ``Formula.all_future _) innerFormula =>
      let temporalKConst := mkConst ``Derivable.temporal_k
      let newGoals ← goal.apply temporalKConst
      replaceMainGoal newGoals
    | _ => throwError "temporal_k_tactic: expected goal formula to be Fφ, got {formula}"
  | _ => throwError "temporal_k_tactic: goal must be derivability relation Γ ⊢ φ, got {goalType}"
```

**Duplication Analysis**:
- 90% identical structure
- Only differences:
  1. Operator constant: `Formula.box` vs `Formula.all_future`
  2. Rule constant: `Derivable.modal_k` vs `Derivable.temporal_k`
  3. Error message strings

**Consolidation Strategy**: Create `mkOperatorKTactic` factory function

### Duplication Pattern 2: Axiom Tactics (129 lines → ~70 lines)

**modal_4_tactic** (lines 306-339): Matches `□φ → □□φ` pattern
**modal_b_tactic** (lines 354-385): Matches `φ → □◇φ` pattern (with diamond handling)
**temp_4_tactic** (lines 406-439): Matches `Fφ → FFφ` pattern
**temp_a_tactic** (lines 454-479): Matches `φ → F(sometime_past φ)` pattern

**Shared Structure**:
1. Extract goal and goal type
2. Match on `Derivable context formula`
3. Match on implication structure
4. Pattern match left/right sides
5. Apply axiom via `mkAppM`
6. Assign goal with proof

**Differences**:
- Pattern matching logic (nested operators, definitional equality checks)
- Axiom constant names
- Error messages

**Consolidation Strategy**: Create `mkAxiomTactic` factory with pattern abstraction

## Refactoring Tasks

### Task 1: Create `mkOperatorKTactic` Factory

**Location**: After line 192 (in Helper Functions section)

**Signature**:
```lean
/--
Factory function for operator K inference rule tactics.
Creates tactics that apply modal K or temporal K rules to goals of form `Γ ⊢ ◯φ`.

**Parameters**:
- `tacticName`: Name of tactic (for error messages)
- `operatorConst`: Formula operator constructor (e.g., ``Formula.box``)
- `ruleConst`: Derivable inference rule (e.g., ``Derivable.modal_k``)
- `operatorSymbol`: Unicode symbol for error messages (e.g., "□")

**Returns**: Elab tactic that applies the K rule for the specified operator.
-/
def mkOperatorKTactic (tacticName : String) (operatorConst : Name) (ruleConst : Name) (operatorSymbol : String) : TacticM Unit := do
  let goal ← getMainGoal
  let goalType ← goal.getType

  match goalType with
  | .app (.app (.const ``Derivable _) context) formula =>
    match formula with
    | .app (.const opConst _) innerFormula =>
      if opConst == operatorConst then
        let ruleConstExpr := mkConst ruleConst
        let newGoals ← goal.apply ruleConstExpr
        replaceMainGoal newGoals
      else
        throwError "{tacticName}: expected goal formula to be {operatorSymbol}φ, got {formula}"
    | _ =>
      throwError "{tacticName}: expected goal formula to be {operatorSymbol}φ, got {formula}"
  | _ =>
    throwError "{tacticName}: goal must be derivability relation Γ ⊢ φ, got {goalType}"
```

### Task 2: Refactor modal_k_tactic Using Factory

**Location**: Replace lines 216-241

**New Implementation**:
```lean
/--
`modal_k_tactic` applies the modal K inference rule.

Given a goal `Derivable (□Γ) (□φ)`, creates subgoal `Derivable Γ φ`
and applies `Derivable.modal_k`.

**Example**:
```lean
example (p : Formula) : Derivable [p.box] (p.box) := by
  modal_k_tactic
  assumption
```

**Implementation**: Uses `mkOperatorKTactic` factory.
-/
elab "modal_k_tactic" : tactic =>
  mkOperatorKTactic "modal_k_tactic" ``Formula.box ``Derivable.modal_k "□"
```

### Task 3: Refactor temporal_k_tactic Using Factory

**Location**: Replace lines 260-285

**New Implementation**:
```lean
/--
`temporal_k_tactic` applies the temporal K inference rule.

Given a goal `Derivable (FΓ) (Fφ)`, creates subgoal `Derivable Γ φ`
and applies `Derivable.temporal_k`.

**Example**:
```lean
example (p : Formula) : Derivable [p.all_future] (p.all_future) := by
  temporal_k_tactic
  assumption
```

**Implementation**: Uses `mkOperatorKTactic` factory.
-/
elab "temporal_k_tactic" : tactic =>
  mkOperatorKTactic "temporal_k_tactic" ``Formula.all_future ``Derivable.temporal_k "F"
```

**Line Count Savings**: 52 lines → ~30 lines (22 line reduction)

### Task 4: Enhance apply_axiom with Intelligent Detection

**Location**: Replace lines 73-74

**New Implementation**:
```lean
/--
`apply_axiom` tactic applies a TM axiom by matching the goal against axiom patterns.

Enhanced version attempts all axiom schemata via unification and provides diagnostic feedback.

**Example**:
```lean
example : Derivable [] (Formula.box p |>.imp p) := by
  apply_axiom  -- Detects and applies Axiom.modal_t
```

**Supported Axioms**:
- `prop_k`, `prop_s` - Propositional axioms
- `modal_t`, `modal_4`, `modal_b` - S5 modal axioms
- `temp_4`, `temp_a`, `temp_l` - Temporal axioms
- `modal_future`, `temp_future` - Bimodal axioms

**Implementation**: Iterates through axiom list with try-catch per axiom.
-/
elab "apply_axiom" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- List of axiom functions to try
  let axiomNames := [
    ``Axiom.modal_t, ``Axiom.modal_4, ``Axiom.modal_b,
    ``Axiom.temp_4, ``Axiom.temp_a, ``Axiom.temp_l,
    ``Axiom.modal_future, ``Axiom.temp_future,
    ``Axiom.prop_k, ``Axiom.prop_s
  ]

  -- Try each axiom via refine with error collection
  let mut errors : Array String := #[]

  for axiomName in axiomNames do
    try
      -- Attempt to apply axiom and let Lean infer parameters
      let axiomExpr := mkConst axiomName
      let proof ← mkAppM ``Derivable.axiom #[← mkAppM axiomName #[]]
      goal.assign proof
      return ()
    catch e =>
      errors := errors.push s!"{axiomName}: {e.toMessageData}"

  -- No axiom matched
  throwError "apply_axiom: no axiom matches goal {goalType}\n\nAttempted axioms:\n{errors.foldl (· ++ "\n" ++ ·) ""}"
```

**Note**: This may require adjustment based on unification behavior. If too complex, keep simple macro version.

### Task 5: (OPTIONAL) Create mkAxiomTactic Factory

**Status**: OPTIONAL - Only implement if time permits and pattern abstraction is clean

**Rationale**: Axiom tactics have more varied pattern matching logic (nested operators, definitional equality). Factory pattern may be more complex than duplication reduction benefit. Prioritize Tasks 1-3.

**If Implemented**: Document pattern abstraction in factory function, refactor modal_4, modal_b, temp_4, temp_a tactics.

## Testing Requirements

### Regression Testing

After each task:
```bash
lake build Logos.Core.Automation.Tactics
lake test
```

**Critical**: ALL 110+ tests in TacticsTest.lean MUST pass after refactoring.

### Test Files
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Automation/TacticsTest.lean`

### Specific Test Coverage
- `modal_k_tactic` tests: Lines testing modal K rule application
- `temporal_k_tactic` tests: Lines testing temporal K rule application
- Integration tests: Tactics used in proof chains

## Line Count Target

**Before Refactoring**: 528 lines
**After Refactoring**: 468-488 lines (40-60 line reduction)

**Breakdown**:
- Task 1 (Factory): +20 lines
- Task 2 (modal_k refactor): -16 lines (26 → 10)
- Task 3 (temporal_k refactor): -16 lines (26 → 10)
- Task 4 (apply_axiom enhance): +10 lines (basic → enhanced)
- Total: -22 to -42 lines net reduction

**Phase 5 Plan Target**: 60-80 line reduction
**Conservative Estimate**: 40-60 line reduction (Tasks 1-4 only)

## Success Criteria

- [ ] `mkOperatorKTactic` factory function implemented
- [ ] `modal_k_tactic` refactored using factory
- [ ] `temporal_k_tactic` refactored using factory
- [ ] All 110+ TacticsTest tests pass
- [ ] `lake build` succeeds with zero errors
- [ ] Line count reduced by 40-60 lines
- [ ] Docstrings preserved for all refactored tactics
- [ ] No functional changes (pure refactoring)

## Risk Mitigation

**Risk**: Factory pattern breaks existing tests
**Mitigation**: Test after each task, not in batch. Rollback individual task if tests fail.

**Risk**: Metaprogramming complexity increases maintenance burden
**Mitigation**: Keep factories simple. If factory is more complex than duplication, keep current implementation.

**Risk**: Time constraint (6-8 hours estimated)
**Mitigation**: Prioritize Tasks 1-3 (operator K consolidation). Task 4-5 are optional enhancements.

## Notes

- This phase is OPTIONAL for functionality (all tactics work)
- Value is code quality improvement and maintainability
- Phases 2-4 are blocked by architectural issues (documented in iteration 3 summary)
- Phase 5 provides immediate value while blocked phases await resolution
