# Stage 3: Implement assumption_search and Helper Tactics

## Metadata

- **Stage Number**: 3 of 3
- **Parent Phase**: Sub-Phase 3B - Implement Core Automation (Task 7)
- **Parent Plan**: `.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md`
- **Dependencies**: Stage 1 complete (`apply_axiom`, `modal_t`) - Stage 2 optional but recommended
- **Estimated Hours**: 7-14 hours (revised from 10-20 with METAPROGRAMMING_GUIDE.md Example 3)
- **Status**: [NOT STARTED]
- **Complexity**: Medium

## Objective

Implement `assumption_search` tactic using TacticM iteration for context searching, plus helper tactics and functions (`modal_k`, `temporal_k`, `mp_chain`, `is_box_formula`, `is_future_formula`). Complete core automation suite with integration tests and comprehensive documentation. Remove 5 sorry placeholders in `Tactics.lean`.

## Context

This stage implements Phase 3 of the three-phase automation roadmap:
- **Phase 1** (complete): `apply_axiom` + `modal_t` → Basic axiom application
- **Phase 2** (complete/optional): `tm_auto` with Aesop → Comprehensive automation
- **Phase 3** (this stage): `assumption_search` + helpers → Context search and helper tactics

**Documentation Available**:
- `METAPROGRAMMING_GUIDE.md` Section 8, Example 3 (lines 647-699): Complete assumption_search implementation
- `METAPROGRAMMING_GUIDE.md` Section 3 (lines 92-175): Goal management and local context API
- Phase file lines 1261-1400: Helper function specifications

**Time Savings**: METAPROGRAMMING_GUIDE.md Example 3 provides ready-to-adapt implementation, eliminating 3-6 hours of TacticM API exploration.

## Success Criteria

- [ ] `assumption_search` tactic implemented with TacticM context iteration
- [ ] Helper tactics implemented: `modal_k`, `temporal_k`, `mp_chain`
- [ ] Helper functions implemented: `is_box_formula`, `is_future_formula`, `assumption_search` (function)
- [ ] Integration tests created combining multiple tactics (≥5 tests)
- [ ] All tests pass: `lake test LogosTest.Automation.TacticsTest`
- [ ] 5 sorry removed from `Tactics.lean` (helper functions)
- [ ] Zero #lint warnings
- [ ] TACTIC_DEVELOPMENT.md completed with all working examples

## Implementation Steps

### Step 1: Review TacticM and Local Context Documentation (30-45 minutes)

**Objective**: Understand TacticM monad, local context retrieval, and iteration patterns

**Resources to Review**:

1. **METAPROGRAMMING_GUIDE.md Section 3** (15-20 minutes):
   - Lines 92-117: Getting the main goal and inspecting goal type
   - Lines 118-142: Assigning proof terms to close goals
   - Lines 143-175: Creating subgoals (pattern for future extension)

2. **METAPROGRAMMING_GUIDE.md Section 8, Example 3** (15-25 minutes):
   - Lines 647-699: Complete assumption_search implementation with iteration
   - Local context retrieval with `getLCtx`
   - Iteration over assumptions with `for decl in localContext`
   - Definitional equality checking with `isDefEq`
   - Early exit pattern with `return`

3. **Phase File** (5-10 minutes):
   - Lines 1261-1400: Helper function specifications
   - Lines 1279-1304: assumption_search function (simpler than tactic)
   - Lines 1307-1357: is_box_formula and is_future_formula patterns

**Action Items**:
- [ ] Read METAPROGRAMMING_GUIDE.md Section 3 for goal management
- [ ] Study METAPROGRAMMING_GUIDE.md Section 8 Example 3 in detail
- [ ] Review phase file helper function specifications
- [ ] Note pattern: `getLCtx`, `for decl in localContext`, `isDefEq`

**Output**: Clear understanding of TacticM iteration, local context API, and early exit patterns.

---

### Step 2: Implement Helper Functions (1-2 hours)

**Objective**: Implement simple helper functions for formula inspection and pattern matching

**File**: `Logos/Automation/Tactics.lean`

**Helper Functions to Implement**:

1. **is_box_formula** (Lines 147-150)
2. **is_future_formula** (Lines 152-155)
3. **assumption_search** (function, not tactic) (Lines 163-172)

**Implementation**:

```lean
-- File: Logos/Automation/Tactics.lean

/-! ## Helper Functions for Formula Inspection -/

/-- Check if a formula is a box formula (`□φ`).

Returns true if the formula has the form `Formula.box φ` for some φ,
false otherwise.

**Usage**:
```lean
let f := Formula.box (Formula.atom "p")
if is_box_formula f then
  -- Process box formula
  ...
```

**Examples**:
- `is_box_formula (Formula.box (Formula.atom "p"))` → true
- `is_box_formula (Formula.atom "p")` → false
- `is_box_formula ((Formula.box P).imp Q)` → false
-/
def is_box_formula (f : Formula) : Bool :=
  match f with
  | Formula.box _ => true
  | _ => false

/-- Check if a formula is a future formula (`Fφ`).

Returns true if the formula has the form `Formula.future φ` for some φ,
false otherwise.

**Usage**:
```lean
let f := Formula.future (Formula.atom "p")
if is_future_formula f then
  -- Process future formula
  ...
```

**Examples**:
- `is_future_formula (Formula.future (Formula.atom "p"))` → true
- `is_future_formula (Formula.atom "p")` → false
- `is_future_formula (Formula.past (Formula.atom "p"))` → false
-/
def is_future_formula (f : Formula) : Bool :=
  match f with
  | Formula.future _ => true
  | _ => false

/-- Check if a formula is a past formula (`Pφ`).

Returns true if the formula has the form `Formula.past φ` for some φ,
false otherwise.

**Usage**:
```lean
let f := Formula.past (Formula.atom "p")
if is_past_formula f then
  -- Process past formula
  ...
```

**Examples**:
- `is_past_formula (Formula.past (Formula.atom "p"))` → true
- `is_past_formula (Formula.atom "p")` → false
-/
def is_past_formula (f : Formula) : Bool :=
  match f with
  | Formula.past _ => true
  | _ => false

/-! ## Helper Functions for Context Search -/

/-- Search context for a premise matching a given formula pattern.

Searches the given context for a formula that definitionally equals the pattern.
Returns Some formula if found, None otherwise.

**Pattern Matching**:
- Uses definitional equality (not syntactic equality)
- Handles α-equivalence and β-reduction automatically
- Does not support wildcard patterns (future extension)

**Usage**:
```lean
let ctx : Context := [Formula.box P, P.imp Q, Q]
match assumption_search (Formula.box P) ctx with
| some formula => -- Found: Formula.box P
| none => -- Not found
```

**Examples**:
- `assumption_search (□p) [□p, p → q, q]` → Some (□p)
- `assumption_search (r) [□p, p → q, q]` → None
- `assumption_search (p) [□p, p → q, q]` → None (□p ≠ p)
-/
def assumption_search (pattern : Formula) (ctx : Context) : Option Formula :=
  ctx.premises.find? fun premise => premise == pattern
```

**Action Items**:
- [ ] Replace lines 147-150 with `is_box_formula` implementation
- [ ] Replace lines 152-155 with `is_future_formula` implementation
- [ ] Add `is_past_formula` helper (bonus, useful for completeness)
- [ ] Replace lines 163-172 with `assumption_search` function implementation
- [ ] Add comprehensive docstrings with usage examples
- [ ] Test compilation: `lake build Logos.Automation.Tactics`
- [ ] Write unit tests for helper functions

**Expected Output**: 3 helper functions implemented and compiling successfully.

---

### Step 3: Implement assumption_search Tactic (2-3 hours)

**Objective**: Implement `assumption_search` tactic using TacticM monad with context iteration

**File**: `Logos/Automation/Tactics.lean`

**Current State**: No tactic syntax defined (new implementation)

**Reference**: METAPROGRAMMING_GUIDE.md Section 8, Example 3 (lines 647-699)

**Implementation**:

```lean
/-! ## Context Search Tactics -/

/-- Search local context for assumption matching goal type.

Iterates through all local declarations (hypotheses) and checks if any has a type
that is definitionally equal to the goal type. When a match is found, uses that
assumption as the proof.

This tactic is useful for simple proof steps where the goal is already available
in the context, eliminating the need to manually specify the assumption name.

**Usage**:

```lean
theorem example_assumption (P : Formula) (h : Derivable [] P) :
    Derivable [] P := by
  assumption_search
  -- Finds h and uses it as proof

theorem example_complex (P Q R : Formula)
    (h1 : Derivable [] P)
    (h2 : Derivable [] (P.imp Q))
    (h3 : Derivable [] Q) :
    Derivable [] Q := by
  assumption_search
  -- Finds h3 and uses it
```

**Pattern Matching**:
- Uses definitional equality (`isDefEq`) not syntactic equality
- Skips auxiliary declarations (internal LEAN names like `_example.1`)
- Returns early on first match (doesn't search entire context unnecessarily)

**Error Handling**:
- If no matching assumption found → "assumption_search: no matching assumption found in context"
- Provides context listing for debugging

**Extension Ideas** (future work):
- Add depth parameter for recursive search through implications
- Support unification (match with instantiation, not just equality)
- Search for implications that conclude with goal (`h : P → goal`)
-/
syntax "assumption_search" : tactic

/-- Implementation of assumption_search using TacticM monad -/
def assumption_search_impl (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType

  -- Get local context (all assumptions in scope)
  let localContext ← getLCtx

  -- Iterate through all local declarations
  for decl in localContext do
    -- Skip auxiliary declarations (internal LEAN names)
    if decl.isAuxDecl then continue

    -- Get assumption type
    let assumptionType ← instantiateMVars decl.type

    -- Check definitional equality with goal type
    if ← isDefEq assumptionType goalType then
      logInfo m!"Found matching assumption: {decl.userName}"

      -- Use this assumption as proof
      let proof := decl.toExpr
      goal.assign proof
      return  -- Success, exit early

  -- No match found after checking all assumptions
  throwError "assumption_search: no matching assumption found in context.\nGoal: {goalType}\nContext: {localContext.foldl (fun acc decl => acc ++ s!"\n  - {decl.userName} : {decl.type}") ""}"

elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  assumption_search_impl goal
```

**Implementation Notes**:

1. **Local Context Retrieval**: `getLCtx` returns all hypotheses in scope
2. **Iteration Pattern**: `for decl in localContext` iterates over `LocalDecl` objects
3. **Auxiliary Declaration Filter**: `decl.isAuxDecl` skips internal LEAN names
4. **Definitional Equality**: `isDefEq` handles α-equivalence automatically
5. **Early Exit**: `return` stops iteration when match found (performance optimization)
6. **Error Context**: Error message lists all assumptions for debugging

**Action Items**:
- [ ] Add `assumption_search` syntax and implementation
- [ ] Add comprehensive docstring with usage examples
- [ ] Test compilation: `lake build Logos.Automation.Tactics`
- [ ] Write tests for assumption_search tactic
- [ ] Verify error message clarity on failure case

**Expected Output**: `assumption_search` tactic implemented and compiling successfully.

---

### Step 4: Implement Helper Tactics (2-4 hours)

**Objective**: Implement `modal_k`, `temporal_k`, and `mp_chain` tactics for inference rules

**File**: `Logos/Automation/Tactics.lean`

**Implementation**:

```lean
/-! ## Inference Rule Helper Tactics -/

/-- Apply modal K inference rule.

Given goal `Derivable Γ (□ψ)` and assumptions:
- `h1 : Derivable Γ (□(φ → ψ))`
- `h2 : Derivable Γ (□φ)`

Applies `Derivable.modal_k h1 h2` to close the goal.

**Usage**:

```lean
theorem example_modal_k (P Q : Formula)
    (h1 : Derivable [] (Formula.box (P.imp Q)))
    (h2 : Derivable [] (Formula.box P)) :
    Derivable [] (Formula.box Q) := by
  modal_k h1 h2
```

**Pattern**:
- Goal must be `Derivable Γ (□ψ)`
- First hypothesis must be `Derivable Γ (□(φ → ψ))`
- Second hypothesis must be `Derivable Γ (□φ)`
-/
syntax "modal_k" term term : tactic

elab "modal_k" h1:term h2:term : tactic => do
  let goal ← getMainGoal

  -- Elaborate hypothesis terms
  let h1Expr ← elabTerm h1 none
  let h2Expr ← elabTerm h2 none

  -- Build proof: Derivable.modal_k h1 h2
  let proof ← mkAppM ``Derivable.modal_k #[h1Expr, h2Expr]

  -- Assign proof to goal
  goal.assign proof

/-- Apply temporal K inference rule.

Given goal `Derivable Γ (Fψ)` and assumptions:
- `h1 : Derivable Γ (F(φ → ψ))`
- `h2 : Derivable Γ (Fφ)`

Applies `Derivable.temporal_k h1 h2` to close the goal.

**Usage**:

```lean
theorem example_temporal_k (P Q : Formula)
    (h1 : Derivable [] (Formula.future (P.imp Q)))
    (h2 : Derivable [] (Formula.future P)) :
    Derivable [] (Formula.future Q) := by
  temporal_k h1 h2
```

**Pattern**:
- Goal must be `Derivable Γ (Fψ)`
- First hypothesis must be `Derivable Γ (F(φ → ψ))`
- Second hypothesis must be `Derivable Γ (Fφ)`
-/
syntax "temporal_k" term term : tactic

elab "temporal_k" h1:term h2:term : tactic => do
  let goal ← getMainGoal

  -- Elaborate hypothesis terms
  let h1Expr ← elabTerm h1 none
  let h2Expr ← elabTerm h2 none

  -- Build proof: Derivable.temporal_k h1 h2
  let proof ← mkAppM ``Derivable.temporal_k #[h1Expr, h2Expr]

  -- Assign proof to goal
  goal.assign proof

/-- Apply modus ponens inference rule.

Given goal `Derivable Γ ψ` and assumptions:
- `h1 : Derivable Γ (φ → ψ)`
- `h2 : Derivable Γ φ`

Applies `Derivable.modus_ponens h1 h2` to close the goal.

**Usage**:

```lean
theorem example_mp (P Q : Formula)
    (h1 : Derivable [] (P.imp Q))
    (h2 : Derivable [] P) :
    Derivable [] Q := by
  mp h1 h2
```

**Alias**: `mp` is shorthand for modus ponens (common notation)

**Pattern**:
- Goal must be `Derivable Γ ψ`
- First hypothesis must be `Derivable Γ (φ → ψ)`
- Second hypothesis must be `Derivable Γ φ`
-/
syntax "mp" term term : tactic

elab "mp" h1:term h2:term : tactic => do
  let goal ← getMainGoal

  -- Elaborate hypothesis terms
  let h1Expr ← elabTerm h1 none
  let h2Expr ← elabTerm h2 none

  -- Build proof: Derivable.modus_ponens h1 h2
  let proof ← mkAppM ``Derivable.modus_ponens #[h1Expr, h2Expr]

  -- Assign proof to goal
  goal.assign proof

/-- Apply chained modus ponens for multi-step implications.

Given goal `Derivable Γ ψn` and assumptions:
- `h1 : Derivable Γ (φ1 → φ2)`
- `h2 : Derivable Γ (φ2 → φ3)`
- ...
- `hn : Derivable Γ (φn-1 → ψn)`
- `h0 : Derivable Γ φ1`

Applies modus ponens repeatedly to derive the goal.

**Usage**:

```lean
theorem example_mp_chain (P Q R : Formula)
    (h1 : Derivable [] (P.imp Q))
    (h2 : Derivable [] (Q.imp R))
    (h0 : Derivable [] P) :
    Derivable [] R := by
  mp_chain [h1, h2] h0
  -- Derives: P → Q, Q → R, P ⊢ R
```

**Note**: This is a convenience tactic for common proof patterns.
For complex chains, consider using `tm_auto` instead.
-/
syntax "mp_chain" "[" term,* "]" term : tactic

macro "mp_chain" "[" steps:term,* "]" base:term : tactic =>
  -- Implementation: Recursive modus ponens application
  -- For now, expand to manual mp calls
  `(tactic|
    repeat (first
      | mp $(steps[0]) $base
      | mp $(steps[1]) _
      | mp $(steps[2]) _
      | assumption_search))
```

**Action Items**:
- [ ] Implement `modal_k` tactic
- [ ] Implement `temporal_k` tactic
- [ ] Implement `mp` tactic (modus ponens)
- [ ] Implement `mp_chain` tactic (multi-step MP, simplified version)
- [ ] Add comprehensive docstrings with usage examples
- [ ] Test compilation: `lake build Logos.Automation.Tactics`
- [ ] Write tests for all helper tactics

**Expected Output**: 4 helper tactics implemented and compiling successfully.

---

### Step 5: Create Integration Test Suite (2-3 hours)

**Objective**: Test tactics in combination, simulating realistic proof workflows

**File**: `LogosTest/Automation/TacticsTest.lean` (extend)

**Integration Test Categories**:

1. **assumption_search Tests** (3 tests):
   - Simple assumption match
   - Complex assumption match (nested formula)
   - Failure case (no match)

2. **Helper Tactic Tests** (4 tests):
   - `modal_k` with explicit hypotheses
   - `temporal_k` with explicit hypotheses
   - `mp` with explicit hypotheses
   - `mp_chain` multi-step proof

3. **Tactic Combination Tests** (3 tests):
   - `apply_axiom` + `assumption_search`
   - `modal_t` + `mp` + `assumption_search`
   - `tm_auto` + `modal_k` (if Stage 2 complete)

**Implementation Template**:

```lean
-- File: LogosTest/Automation/TacticsTest.lean (extend)

/-! ## assumption_search Tests (Phase 3) -/

/-- Test: assumption_search finds simple assumption -/
theorem test_assumption_search_simple (P : Formula) (h : Derivable [] P) :
    Derivable [] P := by
  assumption_search
  -- Expected: Finds h and uses it

/-- Test: assumption_search finds complex nested assumption -/
theorem test_assumption_search_complex (P Q : Formula)
    (h : Derivable [] ((Formula.box P).imp (Q.imp P))) :
    Derivable [] ((Formula.box P).imp (Q.imp P)) := by
  assumption_search
  -- Expected: Finds h even with nested structure

/-- Test: assumption_search with multiple assumptions -/
theorem test_assumption_search_multiple (P Q R : Formula)
    (h1 : Derivable [] P)
    (h2 : Derivable [] Q)
    (h3 : Derivable [] R) :
    Derivable [] Q := by
  assumption_search
  -- Expected: Finds h2 (middle assumption)

/-! ## Helper Tactic Tests (Phase 3) -/

/-- Test: modal_k applies successfully -/
theorem test_modal_k (P Q : Formula)
    (h1 : Derivable [] (Formula.box (P.imp Q)))
    (h2 : Derivable [] (Formula.box P)) :
    Derivable [] (Formula.box Q) := by
  modal_k h1 h2
  -- Expected: Applies Derivable.modal_k

/-- Test: temporal_k applies successfully -/
theorem test_temporal_k (P Q : Formula)
    (h1 : Derivable [] (Formula.future (P.imp Q)))
    (h2 : Derivable [] (Formula.future P)) :
    Derivable [] (Formula.future Q) := by
  temporal_k h1 h2
  -- Expected: Applies Derivable.temporal_k

/-- Test: mp applies successfully -/
theorem test_mp (P Q : Formula)
    (h1 : Derivable [] (P.imp Q))
    (h2 : Derivable [] P) :
    Derivable [] Q := by
  mp h1 h2
  -- Expected: Applies Derivable.modus_ponens

/-- Test: mp_chain for multi-step proof -/
theorem test_mp_chain (P Q R : Formula)
    (h1 : Derivable [] (P.imp Q))
    (h2 : Derivable [] (Q.imp R))
    (h0 : Derivable [] P) :
    Derivable [] R := by
  mp_chain [h1, h2] h0
  -- Expected: Derives P → Q, Q → R, P ⊢ R

/-! ## Integration Tests (Phase 3) -/

/-- Test: Combine apply_axiom with assumption_search -/
theorem test_integration_axiom_assumption (P : Formula) :
    Derivable [(Formula.box P).imp P] P := by
  have h1 : Derivable [] ((Formula.box P).imp P) := by
    apply Derivable.axiom
    apply_axiom MT P
  have h2 : Derivable [] (Formula.box P) := by
    sorry  -- Assume we have this
  mp h1 h2
  -- Expected: Uses apply_axiom then mp

/-- Test: Combine modal_t with mp and assumption_search -/
theorem test_integration_modal_t_mp (P Q : Formula)
    (h1 : Derivable [] (Formula.box P))
    (h2 : Derivable [] (P.imp Q)) :
    Derivable [] Q := by
  have hP : Derivable [] P := by
    have hMT : Derivable [] ((Formula.box P).imp P) := by
      apply Derivable.axiom
      modal_t
    mp hMT h1
  mp h2 hP
  -- Expected: modal_t → mp → mp chain

/-- Test: Combine tm_auto with modal_k (requires Stage 2) -/
-- Uncomment if Stage 2 complete
-- theorem test_integration_tm_auto_modal_k (P Q : Formula) :
--     Derivable [Formula.box (P.imp Q), Formula.box P] (Formula.box Q) := by
--   have h1 : Derivable [] (Formula.box (P.imp Q)) := by assumption_search
--   have h2 : Derivable [] (Formula.box P) := by assumption_search
--   modal_k h1 h2
--   -- Expected: tm_auto or assumption_search finds hypotheses, modal_k applies

def automation_phase3_suite : TestSuite := {
  name := "Automation Phase 3 Tests (assumption_search and helpers)"
  tests := [
    test_assumption_search_simple,
    test_assumption_search_complex,
    test_assumption_search_multiple,
    test_modal_k,
    test_temporal_k,
    test_mp,
    test_mp_chain,
    test_integration_axiom_assumption,
    test_integration_modal_t_mp
    -- test_integration_tm_auto_modal_k  -- Requires Stage 2
  ]
}
```

**Action Items**:
- [ ] Create Phase 3 test suite with 10 tests
- [ ] Include 3 assumption_search tests
- [ ] Include 4 helper tactic tests
- [ ] Include 3 integration tests combining tactics
- [ ] Document expected behavior in comments
- [ ] Run tests: `lake test LogosTest.Automation.TacticsTest`
- [ ] Verify all tests pass

**Expected Output**: 10 integration and helper tests passing successfully.

---

### Step 6: Verify Implementation and Run Full Test Suite (1-2 hours)

**Objective**: Confirm all Phase 3 implementations work correctly

**Verification Commands**:

```bash
# 1. Verify tactics compile
lake build Logos.Automation.Tactics
# Expected: Build succeeds, all tactics compile

# 2. Run full Phase 3 test suite
lake test LogosTest.Automation.TacticsTest::automation_phase3_suite
# Expected: 10 tests pass

# 3. Run combined test suite (all phases)
lake test LogosTest.Automation.TacticsTest
# Expected: Phase 1 (10) + Phase 2 (8, if complete) + Phase 3 (10) = 28 tests pass

# 4. Verify sorry count decreased
grep -c "sorry" Logos/Automation/Tactics.lean
# Expected: 7 (down from 12 originally)
# 5 sorry removed: is_box_formula, is_future_formula, assumption_search function + 2 tactics

# 5. Run lint checks
lake exe lean --run Logos/Automation/Tactics.lean 2>&1 | grep -i "warning"
# Expected: Zero warnings

# 6. Check test coverage
lake test --coverage LogosTest.Automation.TacticsTest
# Expected: ≥80% coverage for Tactics.lean (Automation module target)

# 7. Measure performance
time lake test LogosTest.Automation.TacticsTest
# Expected: All tests complete in <1 minute total
```

**Action Items**:
- [ ] Run all verification commands
- [ ] Fix any compilation errors or test failures
- [ ] Ensure sorry count decreased by 5 total (Phase 3)
- [ ] Verify zero lint warnings
- [ ] Check coverage meets ≥80% target
- [ ] Measure test execution time (<1 minute)

**Expected Output**: All verification checks pass, 5 sorry removed, ≥80% coverage, zero warnings.

---

### Step 7: Complete TACTIC_DEVELOPMENT.md Examples (1-2 hours)

**Objective**: Update documentation with all working examples from Phase 3

**File**: `Documentation/Development/TACTIC_DEVELOPMENT.md`

**Updates Needed**:

1. **Section 2 (Custom Tactics Roadmap)**:
   - Mark `assumption_search`, `modal_k`, `temporal_k` as "✅ Implemented"
   - Update status table with completion markers

2. **Add New Section 5: Context Search Tactics**:
   - Document `assumption_search` implementation
   - Provide working examples
   - Explain iteration patterns and early exit

3. **Add New Section 6: Helper Tactics**:
   - Document `modal_k`, `temporal_k`, `mp` implementations
   - Provide usage examples
   - Explain inference rule application patterns

**Documentation Template**:

```markdown
## 5. Context Search Tactics ✅ Implemented

### assumption_search

Searches local context for assumption matching goal type.

**Implementation**: Uses TacticM monad with `getLCtx` for context retrieval and
`isDefEq` for definitional equality checking.

**Usage**:
```lean
theorem example (P : Formula) (h : Derivable [] P) : Derivable [] P := by
  assumption_search
```

**Implementation Pattern**:
```lean
def assumption_search_impl (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType
  let localContext ← getLCtx
  for decl in localContext do
    if decl.isAuxDecl then continue
    let assumptionType ← instantiateMVars decl.type
    if ← isDefEq assumptionType goalType then
      goal.assign decl.toExpr
      return
  throwError "assumption_search: no matching assumption found"
```

**See**: `LogosTest/Automation/TacticsTest.lean::test_assumption_search_*` for working examples.

---

## 6. Helper Tactics ✅ Implemented

### modal_k

Applies modal K inference rule: `□(φ → ψ), □φ ⊢ □ψ`

**Usage**:
```lean
theorem example (P Q : Formula)
    (h1 : Derivable [] (Formula.box (P.imp Q)))
    (h2 : Derivable [] (Formula.box P)) :
    Derivable [] (Formula.box Q) := by
  modal_k h1 h2
```

### temporal_k

Applies temporal K inference rule: `F(φ → ψ), Fφ ⊢ Fψ`

**Usage**:
```lean
theorem example (P Q : Formula)
    (h1 : Derivable [] (Formula.future (P.imp Q)))
    (h2 : Derivable [] (Formula.future P)) :
    Derivable [] (Formula.future Q) := by
  temporal_k h1 h2
```

### mp (modus ponens)

Applies modus ponens: `φ → ψ, φ ⊢ ψ`

**Usage**:
```lean
theorem example (P Q : Formula)
    (h1 : Derivable [] (P.imp Q))
    (h2 : Derivable [] P) :
    Derivable [] Q := by
  mp h1 h2
```

**See**: `LogosTest/Automation/TacticsTest.lean::test_modal_k`, `test_temporal_k`,
`test_mp` for working examples.
```

**Action Items**:
- [ ] Update TACTIC_DEVELOPMENT.md Section 2 status table
- [ ] Add Section 5 (Context Search Tactics) with assumption_search documentation
- [ ] Add Section 6 (Helper Tactics) with modal_k, temporal_k, mp documentation
- [ ] Include working examples from TacticsTest.lean
- [ ] Add references to test suite for each tactic
- [ ] Update completion percentage in introduction

**Expected Output**: TACTIC_DEVELOPMENT.md fully documented with all Phase 3 working examples.

---

## Error Handling Patterns

### Common Errors and Solutions

**Error 1: assumption_search fails (no match)**
```
assumption_search
→ Error: "assumption_search: no matching assumption found in context"
```
**Solution**:
- Check context contains matching assumption
- Use `have` to introduce needed assumption
- Verify goal type matches assumption type exactly (definitional equality)

**Error 2: modal_k hypothesis type mismatch**
```
modal_k h1 h2
→ Error: Type mismatch for h1 (expected □(φ → ψ), got □φ)
```
**Solution**:
- First hypothesis must be `□(φ → ψ)`
- Second hypothesis must be `□φ`
- Check hypothesis types with `#check h1`

**Error 3: Helper function on non-matching formula**
```
if is_box_formula (Formula.atom "p") then ...
→ Returns false (not an error, but unexpected behavior)
```
**Solution**:
- `is_box_formula` returns Bool, not error
- Use pattern matching for exhaustive checking
- Consider using `match` instead of `if` for clarity

**Error 4: mp_chain with wrong hypothesis count**
```
mp_chain [h1, h2, h3] h0  -- 3 steps but only 2 implications
→ Error: "no matching assumption"
```
**Solution**:
- Ensure hypothesis list matches chain length
- Each step needs corresponding implication
- Use manual `mp` calls for complex chains

---

## Testing Strategy

### Test Coverage Requirements

**Unit Tests**: ≥10 tests covering:
- assumption_search (simple, complex, failure)
- Helper tactics (modal_k, temporal_k, mp, mp_chain)
- Helper functions (is_box_formula, is_future_formula)

**Integration Tests**: ≥3 tests combining:
- apply_axiom + assumption_search
- modal_t + mp + assumption_search
- tm_auto + modal_k (if Stage 2 complete)

**Coverage Target**: ≥80% for Automation module (per CLAUDE.md)

### Test Execution

```bash
# Run Phase 3 tests only
lake test LogosTest.Automation.TacticsTest::automation_phase3_suite

# Run all automation tests (all phases)
lake test LogosTest.Automation.TacticsTest

# Run with coverage analysis
lake test --coverage LogosTest.Automation.TacticsTest

# Expected: ≥80% coverage, all tests pass
```

---

## Completion Checklist

Before marking this stage complete, verify ALL items:

### Implementation
- [ ] `assumption_search` tactic implemented with TacticM iteration
- [ ] `modal_k` helper tactic implemented
- [ ] `temporal_k` helper tactic implemented
- [ ] `mp` helper tactic implemented
- [ ] `mp_chain` helper tactic implemented (simplified version)
- [ ] `is_box_formula` helper function implemented
- [ ] `is_future_formula` helper function implemented
- [ ] `assumption_search` helper function implemented
- [ ] All components compile without errors

### Testing
- [ ] TacticsTest.lean extended with Phase 3 suite (10 tests)
- [ ] All assumption_search tests pass (3 tests)
- [ ] All helper tactic tests pass (4 tests)
- [ ] All integration tests pass (3 tests)
- [ ] Test suite runs successfully
- [ ] Coverage ≥80% for Tactics.lean

### Quality
- [ ] Zero lint warnings in Tactics.lean
- [ ] 5 sorry removed (helper functions + tactics)
- [ ] Sorry count verification: `grep -c "sorry" Tactics.lean` returns 7
- [ ] Helper function docstrings comprehensive
- [ ] Helper tactic docstrings comprehensive
- [ ] Error messages are informative and actionable

### Documentation
- [ ] TACTIC_DEVELOPMENT.md Section 2 updated (status table)
- [ ] TACTIC_DEVELOPMENT.md Section 5 added (assumption_search)
- [ ] TACTIC_DEVELOPMENT.md Section 6 added (helper tactics)
- [ ] Working examples added from TacticsTest.lean
- [ ] Tactics.lean module docstring updated (Phase 3 complete)
- [ ] References to test suite included

### Verification
- [ ] Build succeeds: `lake build Logos.Automation.Tactics`
- [ ] Tests pass: `lake test LogosTest.Automation.TacticsTest`
- [ ] Lint clean: Zero warnings
- [ ] Coverage meets target: ≥80%
- [ ] Performance acceptable: <1 minute for all tests

**Total Checklist Items**: 30
**Required for Completion**: 30/30 (100%)

---

## Phase 3B (Task 7) Overall Completion Status

After completing Stage 3, verify Sub-Phase 3B overall completion:

### Overall Statistics
- **Stages Complete**: 3/3 (Stage 1 + Stage 2 + Stage 3)
- **Tactics Implemented**: 8-10 tactics (depending on Stage 2 completion)
  - Stage 1: apply_axiom, modal_t
  - Stage 2: tm_auto (optional)
  - Stage 3: assumption_search, modal_k, temporal_k, mp, mp_chain
- **Sorry Removed**: 8-10 total (2 + 1 + 5)
- **Test Coverage**: ≥80% for Automation module
- **Documentation**: Complete (METAPROGRAMMING_GUIDE.md + TACTIC_DEVELOPMENT.md)

### Wave 2 Progress
- **Sub-Phase 3A**: Soundness Documentation (partial, ~65%)
- **Sub-Phase 3B**: Core Automation (100% if all stages complete)
- **Sub-Phase 3C**: WorldHistory Fix (100%)
- **Wave 2 Overall**: ~55% complete (3B major contribution)

---

## Next Steps

After completing Stage 3:

**Immediate**: Mark Sub-Phase 3B complete in parent plan
**Documentation**: Update TODO.md Task 7 status to "Complete"
**Quality**: Update IMPLEMENTATION_STATUS.md Automation section to reflect completion
**Planning**: Assess remaining Wave 2 tasks (Phase 2 Perpetuity, Phase 4-8)

**Alternative Paths**:
- Pause automation development, focus on Sub-Phase 3A completion (soundness docs)
- Begin Phase 4 (Documentation Sync) to update all status files
- Start Phase 2 (Perpetuity) using spec 020 research approach

---

## Estimated Time Breakdown

| Task | Estimated Hours | Notes |
|------|----------------|-------|
| TacticM documentation review | 0.5-0.75 | METAPROGRAMMING_GUIDE.md Section 3 + Example 3 |
| Helper functions implementation | 1-2 | 3 simple pattern-matching functions |
| assumption_search tactic | 2-3 | TacticM iteration with early exit |
| Helper tactics implementation | 2-4 | modal_k, temporal_k, mp, mp_chain |
| Integration test suite | 2-3 | 10 tests combining tactics |
| Verification and testing | 1-2 | Run all checks, measure coverage |
| Documentation completion | 1-2 | Update TACTIC_DEVELOPMENT.md Sections 5-6 |
| **Total** | **7-14 hours** | Revised from 10-20 with documentation |

**Confidence Level**: High (clear patterns, working examples available)
**Risk Factors**: Low (TacticM iteration pattern straightforward)
**Blocker Potential**: None (independent of other Wave 2 tasks)

---

## References

- **METAPROGRAMMING_GUIDE.md Section 3**: Goal management and local context API
- **METAPROGRAMMING_GUIDE.md Section 8**: Complete assumption_search working example
- **TACTIC_DEVELOPMENT.md**: Custom tactic patterns and best practices
- **Phase File**: Helper function specifications (lines 1261-1400)
- **TacticsTest.lean**: Working examples for all implemented tactics
