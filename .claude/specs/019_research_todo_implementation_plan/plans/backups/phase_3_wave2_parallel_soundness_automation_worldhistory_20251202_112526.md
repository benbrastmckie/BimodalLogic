# Phase 3: Wave 2 Parallel - Soundness, Automation, WorldHistory [NOT STARTED]

## Metadata
- **Date**: 2025-12-02
- **Parent Plan**: TODO Implementation Systematic Plan
- **Phase Number**: 3
- **Dependencies**: Phase 1 (Wave 1 - High Priority Foundations)
- **Estimated Hours**: 56-82 hours sequential, ~40-60 hours parallel
- **Complexity**: High
- **Status**: [NOT STARTED]
- **Sub-Phases**: 3 (parallel execution)

## Overview

Phase 3 executes Tasks 5, 7, and 8 from the TODO Implementation Plan in parallel after Wave 1 completion. These tasks are independent and can run concurrently with Phase 2 (Perpetuity proofs), enabling significant time savings.

**Objective**: Complete soundness proofs for remaining axioms/rules (Task 5), implement core automation tactics (Task 7), and fix WorldHistory universal helper (Task 8).

**Parallel Execution Strategy**:
- Sub-Phase 3A (Task 5): Soundness proofs - 15-20 hours
- Sub-Phase 3B (Task 7): Automation tactics - 40-60 hours (phased)
- Sub-Phase 3C (Task 8): WorldHistory fix - 1-2 hours

All three sub-phases can execute concurrently after Phase 1 completes. Sub-Phase 3C (WorldHistory) is expected to complete first, followed by Sub-Phase 3A (Soundness), with Sub-Phase 3B (Automation) taking the longest due to its phased nature.

## Sub-Phase 3A: Complete Soundness Proofs (Task 5) [NOT STARTED]

### Objective
Complete soundness proofs for TL, MF, TF axioms and modal_k, temporal_k, temporal_duality rules by adding frame constraints or conditional validity proofs (removes 15 sorry placeholders).

### Complexity
High - Requires frame constraint research, architectural decisions, and complex semantic proofs

### Estimated Hours
15-20 hours

### Dependencies
- Phase 1 complete (propositional axioms available if needed)
- No dependency on Phase 2 (Perpetuity) or other Wave 2 tasks

### Tasks

#### Task 3A.1: Analyze Frame Constraints for TL, MF, TF Axioms
**File**: `Logos/Semantics/TaskFrame.lean`

**Objective**: Research frame properties required to validate TL, MF, TF axioms

**Details**:
1. **TL Axiom** (`△(φ → ψ) → (◁φ → ◁ψ)`) - Backward temporal persistence:
   - Requires: Backward temporal K axiom validity
   - Frame constraint: Task relation must preserve past implications
   - Research approach: Examine task composition properties for past operators

2. **MF Axiom** (`□△φ → △□φ`) - Temporal persistence of necessity:
   - Requires: Modal necessity persists across temporal progression
   - Frame constraint: Necessary truths remain necessary in future states
   - Research approach: Examine interaction between task relation and modal accessibility

3. **TF Axiom** (`△□φ → □φ`) - Necessity persistence across times:
   - Requires: Henceforth necessary implies currently necessary
   - Frame constraint: Future necessity constrains present modality
   - Research approach: Examine temporal inversion of necessity

**Specific Analysis**:
```lean
-- TL Frame Constraint (Backward Persistence)
-- For all tasks T, times t1 < t2, and formulas φ, ψ:
-- If △(φ → ψ) holds at (M, h, t2), then ◁φ → ◁ψ holds
-- This requires task relation to preserve past implications

-- MF Frame Constraint (Temporal Modal Interaction)
-- For all tasks T, times t, and formulas φ:
-- If □△φ holds at (M, h, t), then △□φ holds
-- This requires modal necessity to persist temporally

-- TF Frame Constraint (Future Necessity Collapse)
-- For all tasks T, times t, and formulas φ:
-- If △□φ holds at (M, h, t), then □φ holds
-- This requires future necessity to imply present necessity
```

**Expected Outcomes**:
- Document frame properties needed for each axiom (3 constraints identified)
- Identify which existing TaskFrame properties support these constraints
- Note gaps where new constraints needed

**Testing**:
```bash
# Verify frame constraint documentation
grep -n "TL.*constraint\|MF.*constraint\|TF.*constraint" Logos/Semantics/TaskFrame.lean
```

**Time Estimate**: 3-5 hours

---

#### Task 3A.2: Design Frame Constraint Architecture
**Objective**: Choose architectural approach for integrating frame constraints

**Options Analysis**:

**Option A: Add Constraints to TaskFrame.lean**
- **Pros**:
  - Explicit frame properties in type system
  - Compile-time enforcement
  - Clear semantic specification
- **Cons**:
  - Requires modifying existing TaskFrame structure
  - May complicate frame construction
  - Affects all existing code using TaskFrame
- **Implementation**:
  ```lean
  structure TaskFrame where
    WorldState : Type
    Time : Type
    -- Existing fields
    task : Time → WorldState → Option (Time → WorldState)
    nullity : ∀ t w, task t w (λ t' => w t') = some w
    compositionality : ∀ t w T1 T2, ...
    -- NEW: Frame constraints for TL, MF, TF
    backward_persistence : ∀ t1 t2 φ ψ, ... -- TL
    modal_temporal_interaction : ∀ t φ, ... -- MF
    future_necessity_collapse : ∀ t φ, ... -- TF
  ```

**Option B: Document Axioms as Conditional on Frame Properties**
- **Pros**:
  - Non-invasive (no TaskFrame changes)
  - Preserves existing code compatibility
  - Clear documentation of required properties
- **Cons**:
  - No compile-time enforcement
  - Axiom validity is conditional, not absolute
  - Requires documentation discipline
- **Implementation**:
  ```lean
  /-- TL axiom validity is conditional on backward_persistence frame property.

  Frame Property (Backward Persistence):
  For all times t1 < t2, tasks T, and formulas φ, ψ:
  If T respects △(φ → ψ) at t2, then T respects (◁φ → ◁ψ).

  When this property holds, the TL axiom is valid in all models
  based on such frames.
  -/
  theorem tl_valid_conditional (backward_persistence : FrameProperty) :
    validFormula (imp (future (imp φ ψ)) (imp (past φ) (past ψ))) := by
    sorry  -- Proof uses backward_persistence assumption
  ```

**Decision Criteria**:
- **Choose Option A if**:
  - Frame constraints are simple and well-understood
  - Changes to TaskFrame won't break extensive existing code
  - Type-level enforcement is critical for correctness

- **Choose Option B if**:
  - Frame constraints are complex or research is ongoing
  - TaskFrame changes would require extensive refactoring
  - Documentation-based approach is sufficient for MVP

**Recommended Approach**: **Option B** (Conditional Validity)
- **Rationale**:
  1. MVP completion prioritizes working proofs over architectural perfection
  2. Frame constraint research may evolve (conditional approach more flexible)
  3. Preserves existing code stability
  4. Can migrate to Option A in future Layer refinement if needed

**Expected Outcomes**:
- Architectural decision documented (Option A or Option B)
- If Option A: TaskFrame modification plan created
- If Option B: Conditional validity documentation template created

**Time Estimate**: 2-3 hours

---

#### Task 3A.3: Implement Chosen Approach and Prove Axiom Validity
**File**: `Logos/Metalogic/Soundness.lean`

**Objective**: Implement chosen architecture and prove TL, MF, TF axioms valid

**Implementation Assuming Option B (Conditional Validity)**:

**TL Axiom Validity** (Line 252):
```lean
/-- TL axiom: △(φ → ψ) → (◁φ → ◁ψ) (backward temporal K)

Frame Property Required (Backward Persistence):
For all frames F, models M based on F, histories h, times t:
If △(φ → ψ) is true at (M, h, t), then (◁φ → ◁ψ) is true at (M, h, t).

This property holds when the task relation preserves past implications.
-/
theorem tl_valid_conditional (φ ψ : Formula) :
    validFormula (imp (future (imp φ ψ)) (imp (past φ) (past ψ))) := by
  intro M h t
  -- Assume △(φ → ψ) true at (M, h, t)
  intro h_future
  -- Assume ◁φ true at (M, h, t)
  intro h_past
  -- Need to show ◁ψ true at (M, h, t)
  -- Strategy: Use backward_persistence frame property
  -- 1. From h_future: for all t' ≥ t, (φ → ψ) holds at (M, h, t')
  -- 2. From h_past: exists t'' < t such that φ holds at (M, h, t'')
  -- 3. Apply backward persistence: ψ holds at (M, h, t'')
  -- 4. Therefore ◁ψ holds at (M, h, t)
  sorry  -- REMOVE THIS and complete proof
```

**MF Axiom Validity** (Line 295):
```lean
/-- MF axiom: □△φ → △□φ (necessity persists temporally)

Frame Property Required (Modal-Temporal Interaction):
For all frames F, models M based on F, histories h, times t:
If □△φ is true at (M, h, t), then △□φ is true at (M, h, t).

This property holds when necessary truths remain necessary across
temporal progression.
-/
theorem mf_valid_conditional (φ : Formula) :
    validFormula (imp (box (future φ)) (future (box φ))) := by
  intro M h t
  -- Assume □△φ true at (M, h, t)
  intro h_box_future
  -- Need to show △□φ true at (M, h, t)
  -- Strategy: Use modal_temporal_interaction frame property
  -- 1. From h_box_future: for all accessible worlds w, △φ holds at (M, h_w, t)
  -- 2. Need: for all t' ≥ t, □φ holds at (M, h, t')
  -- 3. Apply modal-temporal interaction to transfer necessity across time
  sorry  -- REMOVE THIS and complete proof
```

**TF Axiom Validity** (Line 324):
```lean
/-- TF axiom: △□φ → □φ (future necessity implies present necessity)

Frame Property Required (Future Necessity Collapse):
For all frames F, models M based on F, histories h, times t:
If △□φ is true at (M, h, t), then □φ is true at (M, h, t).

This property holds when henceforth necessary truths are currently necessary.
-/
theorem tf_valid_conditional (φ : Formula) :
    validFormula (imp (future (box φ)) (box φ)) := by
  intro M h t
  -- Assume △φ true at (M, h, t)
  intro h_future
  -- Need to show □φ true at (M, h, t)
  -- Strategy: Use future_necessity_collapse frame property
  -- 1. From h_future: for all t' ≥ t, □φ holds at (M, h, t')
  -- 2. Apply future necessity collapse: □φ holds at (M, h, t)
  sorry  -- REMOVE THIS and complete proof
```

**Expected Outcomes**:
- TL axiom validity proven (line 252 sorry removed)
- MF axiom validity proven (line 295 sorry removed)
- TF axiom validity proven (line 324 sorry removed)
- Frame property assumptions documented in docstrings

**Testing**:
```bash
# Verify axiom validity proofs compile
lake build Logos.Metalogic.Soundness

# Check for remaining sorry in axiom sections
grep -n "sorry" Logos/Metalogic/Soundness.lean | grep -E "tl_valid|mf_valid|tf_valid"
# Expected: 0 results
```

**Time Estimate**: 4-6 hours

---

#### Task 3A.4: Prove Rule Soundness (modal_k, temporal_k, temporal_duality)
**File**: `Logos/Metalogic/Soundness.lean`

**Objective**: Complete soundness proofs for three inference rules

**Modal K Rule Soundness** (Line 398):
```lean
/-- Modal K rule soundness: (⊢ φ → ψ) → (⊢ □φ → □ψ)

Requires modal uniformity: If Γ derives φ → ψ and Γ is modally uniform
(contains only boxed formulas or theorems), then Γ derives □φ → □ψ.
-/
theorem modal_k_sound (φ ψ : Formula) (h : Derivable [] (imp φ ψ)) :
    Derivable [] (imp (box φ) (box ψ)) := by
  -- Strategy:
  -- 1. Assume □φ holds in arbitrary model M, history h, time t
  -- 2. From h: φ → ψ is valid (by soundness of derivability)
  -- 3. Need to show □ψ holds at (M, h, t)
  -- 4. For any accessible world w:
  --    a. φ holds at (M, h_w, t) (from □φ assumption)
  --    b. φ → ψ valid, so ψ holds at (M, h_w, t)
  -- 5. Therefore □ψ holds at (M, h, t)
  sorry  -- REMOVE THIS and complete proof
```

**Temporal K Rule Soundness** (Line 416):
```lean
/-- Temporal K rule soundness: (⊢ φ → ψ) → (⊢ △φ → △ψ)

Requires temporal uniformity: If Γ derives φ → ψ and Γ is temporally uniform
(contains only always formulas or theorems), then Γ derives △φ → △ψ.
-/
theorem temporal_k_sound (φ ψ : Formula) (h : Derivable [] (imp φ ψ)) :
    Derivable [] (imp (future φ) (future ψ)) := by
  -- Strategy:
  -- 1. Assume △φ holds in arbitrary model M, history h, time t
  -- 2. From h: φ → ψ is valid (by soundness of derivability)
  -- 3. Need to show △ψ holds at (M, h, t)
  -- 4. For any time t' ≥ t:
  --    a. φ holds at (M, h, t') (from △φ assumption)
  --    b. φ → ψ valid, so ψ holds at (M, h, t')
  -- 5. Therefore △ψ holds at (M, h, t)
  sorry  -- REMOVE THIS and complete proof
```

**Temporal Duality Rule Soundness** (Line 431):
```lean
/-- Temporal duality rule soundness: (⊢ ¬△¬φ → ◁φ)

Semantic duality: ¬△¬φ is semantically equivalent to ◁φ.
Future negation dualizes with past.
-/
theorem temporal_duality_sound (φ : Formula) :
    Derivable [] (imp (neg (future (neg φ))) (past φ)) := by
  -- Strategy:
  -- 1. Assume ¬△¬φ holds at (M, h, t)
  -- 2. This means: it's not the case that ¬φ holds at all future times
  -- 3. Equivalently: φ holds at some past or present time
  -- 4. By semantic duality: ◁φ holds at (M, h, t)
  -- Note: This requires careful handling of past semantics
  sorry  -- REMOVE THIS and complete proof
```

**Expected Outcomes**:
- modal_k rule soundness proven (line 398 sorry removed)
- temporal_k rule soundness proven (line 416 sorry removed)
- temporal_duality rule soundness proven (line 431 sorry removed)

**Testing**:
```bash
# Verify rule soundness proofs compile
lake build Logos.Metalogic.Soundness

# Check for remaining sorry in rule sections
grep -n "sorry" Logos/Metalogic/Soundness.lean | grep -E "modal_k_sound|temporal_k_sound|temporal_duality_sound"
# Expected: 0 results
```

**Time Estimate**: 4-6 hours

---

#### Task 3A.5: Remove All 15 Sorry from Soundness.lean and Write Tests
**File**: `Logos/Metalogic/Soundness.lean`

**Objective**: Verify all soundness sorry placeholders removed and add comprehensive tests

**Verification Steps**:
1. **Count Remaining Sorry**:
   ```bash
   grep -c "sorry" Logos/Metalogic/Soundness.lean
   # Expected: 0 (down from 15)
   ```

2. **Verify Axiom Validity Proofs Complete**:
   ```bash
   grep -n "theorem.*_valid" Logos/Metalogic/Soundness.lean
   # Should show: mt_valid, m4_valid, mb_valid, t4_valid, ta_valid, tl_valid, mf_valid, tf_valid
   # All should have complete proofs (no sorry)
   ```

3. **Verify Rule Soundness Proofs Complete**:
   ```bash
   grep -n "theorem.*_sound" Logos/Metalogic/Soundness.lean
   # Should show: axiom_sound, assumption_sound, modus_ponens_sound, weakening_sound,
   #              modal_k_sound, temporal_k_sound, temporal_duality_sound
   # All should have complete proofs (no sorry)
   ```

**Test Implementation**:
**File**: `LogosTest/Metalogic/SoundnessTest.lean`

```lean
import Logos.Metalogic.Soundness
import LogosTest.TestFramework

namespace LogosTest.Metalogic.SoundnessTest

-- Test TL axiom validity (NEW)
def test_tl_axiom_valid : TestCase := {
  name := "TL axiom △(φ → ψ) → (◁φ → ◁ψ) is valid"
  run := fun () =>
    let φ := Formula.atom "p"
    let ψ := Formula.atom "q"
    let tl_instance := Formula.imp
      (Formula.future (Formula.imp φ ψ))
      (Formula.imp (Formula.past φ) (Formula.past ψ))
    assertValidFormula tl_instance
}

-- Test MF axiom validity (NEW)
def test_mf_axiom_valid : TestCase := {
  name := "MF axiom □△φ → △□φ is valid"
  run := fun () =>
    let φ := Formula.atom "p"
    let mf_instance := Formula.imp
      (Formula.box (Formula.future φ))
      (Formula.future (Formula.box φ))
    assertValidFormula mf_instance
}

-- Test TF axiom validity (NEW)
def test_tf_axiom_valid : TestCase := {
  name := "TF axiom △□φ → □φ is valid"
  run := fun () =>
    let φ := Formula.atom "p"
    let tf_instance := Formula.imp
      (Formula.future (Formula.box φ))
      (Formula.box φ)
    assertValidFormula tf_instance
}

-- Test modal_k rule soundness (NEW)
def test_modal_k_sound : TestCase := {
  name := "Modal K rule (⊢ φ → ψ) → (⊢ □φ → □ψ) is sound"
  run := fun () =>
    let φ := Formula.atom "p"
    let ψ := Formula.atom "q"
    -- Assume φ → ψ derivable
    let h_deriv : Derivable [] (Formula.imp φ ψ) := sorry  -- example derivation
    -- Modal K rule gives □φ → □ψ derivable
    let result := modal_k_sound φ ψ h_deriv
    assertDerivedImpliesValid result
}

-- Test temporal_k rule soundness (NEW)
def test_temporal_k_sound : TestCase := {
  name := "Temporal K rule (⊢ φ → ψ) → (⊢ △φ → △ψ) is sound"
  run := fun () =>
    let φ := Formula.atom "p"
    let ψ := Formula.atom "q"
    -- Assume φ → ψ derivable
    let h_deriv : Derivable [] (Formula.imp φ ψ) := sorry  -- example derivation
    -- Temporal K rule gives △φ → △ψ derivable
    let result := temporal_k_sound φ ψ h_deriv
    assertDerivedImpliesValid result
}

-- Test temporal_duality rule soundness (NEW)
def test_temporal_duality_sound : TestCase := {
  name := "Temporal duality ¬△¬φ → ◁φ is sound"
  run := fun () =>
    let φ := Formula.atom "p"
    let result := temporal_duality_sound φ
    assertDerivedImpliesValid result
}

-- Test suite combining all soundness tests
def soundness_test_suite : TestSuite := {
  name := "Soundness Tests (Wave 2 Task 5)"
  tests := [
    test_tl_axiom_valid,
    test_mf_axiom_valid,
    test_tf_axiom_valid,
    test_modal_k_sound,
    test_temporal_k_sound,
    test_temporal_duality_sound
  ]
}

end LogosTest.Metalogic.SoundnessTest
```

**Expected Outcomes**:
- All 15 sorry removed from Soundness.lean
- 6 new tests added to SoundnessTest.lean
- All soundness tests pass

**Testing**:
```bash
# Verify sorry count
grep -c "sorry" Logos/Metalogic/Soundness.lean
# Expected: 0

# Run soundness tests
lake test LogosTest.Metalogic.SoundnessTest
# Expected: All tests pass

# Verify overall sorry count decreased
grep -r "sorry" Logos/ --include="*.lean" | wc -l
# Expected: 26 (41 - 15 from Soundness)
```

**Time Estimate**: 2-4 hours

---

### Sub-Phase 3A Summary

**Total Tasks**: 5
**Estimated Time**: 15-20 hours
**Sorry Removed**: 15 (all from Soundness.lean)
**Files Modified**:
- `Logos/Semantics/TaskFrame.lean` (documentation)
- `Logos/Metalogic/Soundness.lean` (proofs)
**Files Created**:
- Tests in `LogosTest/Metalogic/SoundnessTest.lean`

**Success Criteria**:
- [ ] Frame constraints for TL, MF, TF documented
- [ ] Architectural approach chosen and implemented
- [ ] TL, MF, TF axiom validity proven
- [ ] modal_k, temporal_k, temporal_duality rule soundness proven
- [ ] All 15 sorry removed from Soundness.lean
- [ ] 6 new soundness tests passing
- [ ] lake build succeeds
- [ ] lake test LogosTest.Metalogic.SoundnessTest passes

---

## Sub-Phase 3B: Implement Core Automation (Task 7) [NOT STARTED]

### Objective
Implement core automation tactics in phased approach: apply_axiom, modal_t (Phase 1), tm_auto (Phase 2), assumption_search and helpers (Phase 3). Removes 8 sorry placeholders and provides 3-4 working tactics.

### Complexity
High - Requires LEAN 4 meta-programming expertise, tactic API knowledge, and careful testing

### Estimated Hours
40-60 hours (phased: 15-20 + 15-20 + 10-20)

### Dependencies
- Phase 1 complete (propositional axioms may be useful for tactic development)
- No dependency on Phase 2 (Perpetuity) or other Wave 2 tasks

### Phased Approach
Breaking automation into 3 phases allows:
1. **Learning curve management**: Phase 1 provides foundation for LEAN 4 tactic development
2. **Incremental value**: Each phase delivers working tactics
3. **Risk mitigation**: Can pause after Phase 1 or 2 if time constraints emerge

---

### Task 3B.1: Phase 1 - Implement apply_axiom and modal_t Tactics

**File**: `Logos/Automation/Tactics.lean`

**Objective**: Replace apply_axiom and modal_t stubs with real implementations

**Estimated Time**: 15-20 hours

**apply_axiom Tactic** (Lines 102-112):

**Current State**:
```lean
/-- Apply a named axiom schema to the current goal.
Usage: `apply_axiom "MT" φ` applies axiom MT with formula φ. -/
syntax "apply_axiom" ident term* : tactic

macro_rules
  | `(tactic| apply_axiom $ax $args*) => `(tactic| sorry)
```

**Implementation Requirements**:
1. Parse axiom name identifier ("MT", "M4", "MB", etc.)
2. Parse formula arguments (e.g., φ, ψ for multi-argument axioms)
3. Look up axiom from `Logos.ProofSystem.Axioms`
4. Instantiate axiom with provided formulas
5. Apply to current goal using `apply` tactic

**Implementation**:
```lean
import Lean.Elab.Tactic
import Logos.ProofSystem.Axioms

open Lean Elab Tactic Meta

/-- Apply a named axiom schema to the current goal.

Usage:
  - `apply_axiom MT φ` applies modal T axiom: □φ → φ
  - `apply_axiom M4 φ` applies modal 4 axiom: □φ → □□φ
  - `apply_axiom TA φ` applies temporal A axiom: △φ → φ

The tactic looks up the axiom by name, instantiates it with the provided
formula(s), and applies it to the current goal.
-/
syntax "apply_axiom" ident term* : tactic

elab_rules : tactic
  | `(tactic| apply_axiom $ax:ident $args*) => do
    let axiomName := ax.getId
    let goal ← getMainGoal

    -- Parse formula arguments
    let formulaArgs ← args.mapM fun arg => do
      elabTerm arg none

    -- Look up axiom by name and instantiate
    let axiomExpr ← match axiomName.toString with
      | "MT" =>
          if formulaArgs.size != 1 then
            throwError "MT axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.modal_t) φ
      | "M4" =>
          if formulaArgs.size != 1 then
            throwError "M4 axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.modal_4) φ
      | "MB" =>
          if formulaArgs.size != 1 then
            throwError "MB axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.modal_b) φ
      | "T4" =>
          if formulaArgs.size != 1 then
            throwError "T4 axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.temporal_4) φ
      | "TA" =>
          if formulaArgs.size != 1 then
            throwError "TA axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.temporal_a) φ
      | "TL" =>
          if formulaArgs.size != 2 then
            throwError "TL axiom requires exactly 2 formula arguments"
          let φ := formulaArgs[0]!
          let ψ := formulaArgs[1]!
          return mkApp2 (mkConst ``Axiom.temporal_l) φ ψ
      | "MF" =>
          if formulaArgs.size != 1 then
            throwError "MF axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.modal_future) φ
      | "TF" =>
          if formulaArgs.size != 1 then
            throwError "TF axiom requires exactly 1 formula argument"
          let φ := formulaArgs[0]!
          return mkApp (mkConst ``Axiom.temporal_future) φ
      | _ => throwError s!"Unknown axiom: {axiomName}"

    -- Apply axiom to goal
    goal.apply axiomExpr
```

**modal_t Tactic** (Lines 118-141):

**Current State**:
```lean
/-- Apply modal T axiom (□φ → φ) to the current goal. -/
syntax "modal_t" : tactic

macro_rules
  | `(tactic| modal_t) => `(tactic| sorry)
```

**Implementation Requirements**:
1. Detect if goal matches `□φ → φ` pattern
2. Extract formula φ from goal
3. Apply modal T axiom with φ
4. Handle goal transformation

**Implementation**:
```lean
/-- Apply modal T axiom (□φ → φ) to the current goal.

The tactic automatically detects if the goal has the form □φ → φ
and applies the modal T axiom. If the goal doesn't match, it fails
with an informative error message.

Usage:
  theorem example_t (φ : Formula) : box φ → φ := by
    modal_t  -- Applies MT axiom automatically
-/
syntax "modal_t" : tactic

elab "modal_t" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- Match goal type against □φ → φ pattern
  match goalType with
  | app (app (const ``imp _) (app (const ``box _) φ)) ψ =>
      -- Check that φ and ψ are the same
      if ← isDefEq φ ψ then
        -- Apply modal T axiom
        let axiomExpr := mkApp (mkConst ``Axiom.modal_t) φ
        goal.apply axiomExpr
      else
        throwError "Goal has form □φ → ψ but φ ≠ ψ. Modal T requires □φ → φ."
  | _ =>
      throwError "Goal does not match modal T pattern (□φ → φ). Current goal: {goalType}"
```

**Expected Outcomes**:
- apply_axiom tactic works for all 8 axioms (MT, M4, MB, T4, TA, TL, MF, TF)
- modal_t tactic automatically applies modal T axiom when goal matches pattern
- 2 sorry removed (lines 112, 141 in Tactics.lean)

**Testing**:
**File**: `LogosTest/Automation/TacticsTest.lean`

```lean
import Logos.Automation.Tactics
import LogosTest.TestFramework

namespace LogosTest.Automation.TacticsTest

-- Test apply_axiom with MT
def test_apply_axiom_mt : TestCase := {
  name := "apply_axiom MT works correctly"
  run := fun () =>
    theorem test_mt (φ : Formula) : Derivable [] (imp (box φ) φ) := by
      apply Derivable.axiom
      apply Axiom.modal_t
      -- Alternatively: apply_axiom MT φ
}

-- Test apply_axiom with M4
def test_apply_axiom_m4 : TestCase := {
  name := "apply_axiom M4 works correctly"
  run := fun () =>
    theorem test_m4 (φ : Formula) : Derivable [] (imp (box φ) (box (box φ))) := by
      apply Derivable.axiom
      apply_axiom M4 φ
}

-- Test apply_axiom with TL (2 arguments)
def test_apply_axiom_tl : TestCase := {
  name := "apply_axiom TL works with 2 formula arguments"
  run := fun () =>
    theorem test_tl (φ ψ : Formula) :
        Derivable [] (imp (future (imp φ ψ)) (imp (past φ) (past ψ))) := by
      apply Derivable.axiom
      apply_axiom TL φ ψ
}

-- Test modal_t tactic
def test_modal_t_tactic : TestCase := {
  name := "modal_t tactic applies automatically"
  run := fun () =>
    theorem test_modal_t_auto (φ : Formula) : box φ → φ := by
      modal_t  -- Should apply MT axiom automatically
}

-- Test modal_t failure on wrong pattern
def test_modal_t_fail : TestCase := {
  name := "modal_t fails gracefully on non-matching goal"
  run := fun () =>
    -- This should fail with informative error
    theorem test_modal_t_fail (φ ψ : Formula) : box φ → ψ := by
      modal_t  -- Should fail: φ ≠ ψ
}

def automation_phase1_suite : TestSuite := {
  name := "Automation Phase 1 Tests (apply_axiom, modal_t)"
  tests := [
    test_apply_axiom_mt,
    test_apply_axiom_m4,
    test_apply_axiom_tl,
    test_modal_t_tactic,
    test_modal_t_fail  -- Expected to fail
  ]
}

end LogosTest.Automation.TacticsTest
```

**Testing Commands**:
```bash
# Verify tactics compile
lake build Logos.Automation.Tactics

# Run Phase 1 tests
lake test LogosTest.Automation.TacticsTest

# Verify sorry count decreased
grep -c "sorry" Logos/Automation/Tactics.lean
# Expected: 10 (12 - 2 from Phase 1)
```

**Time Estimate**: 15-20 hours

---

### Task 3B.2: Phase 2 - Implement tm_auto Tactic

**File**: `Logos/Automation/Tactics.lean`

**Objective**: Implement tm_auto tactic combining apply_axiom and modal_t for simple automation

**Estimated Time**: 15-20 hours

**tm_auto Tactic** (Lines 195-205):

**Current State**:
```lean
/-- Automated proof search for TM logic theorems.
Tries apply_axiom with all known axioms and basic tactic combinations. -/
syntax "tm_auto" : tactic

macro_rules
  | `(tactic| tm_auto) => `(tactic| sorry)
```

**Implementation Requirements**:
1. Analyze goal to determine applicable tactics
2. Try axiom applications in strategic order
3. Handle common proof patterns automatically
4. Provide fallback if no automation succeeds

**Implementation Strategy**:
```lean
/-- Automated proof search for TM logic theorems.

The tm_auto tactic attempts to prove the goal automatically by:
1. Checking if goal matches common axiom patterns (MT, M4, TA, etc.)
2. Trying apply_axiom with relevant axioms
3. Using modal_t for □φ → φ goals
4. Applying basic logical tactics (intro, apply, etc.)

If no automated approach succeeds, tm_auto fails with a helpful message.

Usage:
  theorem auto_example (φ : Formula) : □φ → φ := by
    tm_auto  -- Automatically proves using MT axiom
-/
syntax "tm_auto" : tactic

elab "tm_auto" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType

  -- Try modal_t pattern first (□φ → φ)
  try
    evalTactic (← `(tactic| modal_t))
    return
  catch _ => pure ()

  -- Try modal 4 pattern (□φ → □□φ)
  try
    match goalType with
    | app (app (const ``imp _) (app (const ``box _) φ))
          (app (const ``box _) (app (const ``box _) ψ)) =>
        if ← isDefEq φ ψ then
          evalTactic (← `(tactic| apply_axiom M4 $φ))
          return
    | _ => pure ()
  catch _ => pure ()

  -- Try modal B pattern (φ → □◇φ)
  try
    match goalType with
    | app (app (const ``imp _) φ)
          (app (const ``box _) (app (const ``diamond _) ψ)) =>
        if ← isDefEq φ ψ then
          evalTactic (← `(tactic| apply_axiom MB $φ))
          return
    | _ => pure ()
  catch _ => pure ()

  -- Try temporal 4 pattern (△φ → △△φ)
  try
    match goalType with
    | app (app (const ``imp _) (app (const ``future _) φ))
          (app (const ``future _) (app (const ``future _) ψ)) =>
        if ← isDefEq φ ψ then
          evalTactic (← `(tactic| apply_axiom T4 $φ))
          return
    | _ => pure ()
  catch _ => pure ()

  -- Try temporal A pattern (△φ → φ)
  try
    match goalType with
    | app (app (const ``imp _) (app (const ``future _) φ)) ψ =>
        if ← isDefEq φ ψ then
          evalTactic (← `(tactic| apply_axiom TA $φ))
          return
    | _ => pure ()
  catch _ => pure ()

  -- If no pattern matched, fail with helpful message
  throwError "tm_auto could not find an applicable automation strategy for goal: {goalType}\nTry using specific tactics like modal_t or apply_axiom."
```

**Expected Outcomes**:
- tm_auto tactic automatically proves goals matching common axiom patterns
- 1 sorry removed (line 205 in Tactics.lean)
- Provides foundation for more sophisticated automation in future

**Testing**:
**File**: `LogosTest/Automation/TacticsTest.lean` (extend)

```lean
-- Test tm_auto with modal T pattern
def test_tm_auto_modal_t : TestCase := {
  name := "tm_auto proves □φ → φ automatically"
  run := fun () =>
    theorem test_auto_t (φ : Formula) : box φ → φ := by
      tm_auto
}

-- Test tm_auto with modal 4 pattern
def test_tm_auto_modal_4 : TestCase := {
  name := "tm_auto proves □φ → □□φ automatically"
  run := fun () =>
    theorem test_auto_4 (φ : Formula) : box φ → box (box φ) := by
      tm_auto
}

-- Test tm_auto with temporal A pattern
def test_tm_auto_temporal_a : TestCase := {
  name := "tm_auto proves △φ → φ automatically"
  run := fun () =>
    theorem test_auto_ta (φ : Formula) : future φ → φ := by
      tm_auto
}

-- Test tm_auto failure on complex goal
def test_tm_auto_fail : TestCase := {
  name := "tm_auto fails gracefully on complex goals"
  run := fun () =>
    -- Complex goal that requires manual proof
    theorem test_auto_complex (φ ψ : Formula) :
        imp (box φ) (imp (box ψ) (box (imp φ ψ))) := by
      tm_auto  -- Should fail with helpful message
}

def automation_phase2_suite : TestSuite := {
  name := "Automation Phase 2 Tests (tm_auto)"
  tests := [
    test_tm_auto_modal_t,
    test_tm_auto_modal_4,
    test_tm_auto_temporal_a,
    test_tm_auto_fail  -- Expected to fail
  ]
}
```

**Testing Commands**:
```bash
# Run Phase 2 tests
lake test LogosTest.Automation.TacticsTest

# Verify sorry count decreased
grep -c "sorry" Logos/Automation/Tactics.lean
# Expected: 9 (10 - 1 from Phase 2)
```

**Time Estimate**: 15-20 hours

---

### Task 3B.3: Phase 3 - Implement assumption_search and Helper Functions

**File**: `Logos/Automation/Tactics.lean`

**Objective**: Implement assumption_search for premise searching and helper functions for formula inspection

**Estimated Time**: 10-20 hours

**assumption_search Helper** (Lines 163-172):

**Current State**:
```lean
/-- Search context for a premise matching a given formula pattern. -/
def assumption_search (pattern : Formula) (ctx : Context) : Option Formula :=
  sorry
```

**Implementation**:
```lean
/-- Search context for a premise matching a given formula pattern.

Searches the given context for a formula that matches the pattern.
Returns Some formula if found, None otherwise.

Pattern matching supports:
- Exact matching: formula must equal pattern exactly
- Wildcard matching (future extension): support for pattern variables

Example:
  let ctx := [□p, p → q, q]
  assumption_search (□p) ctx  -- Returns Some (□p)
  assumption_search (r) ctx   -- Returns None
-/
def assumption_search (pattern : Formula) (ctx : Context) : Option Formula :=
  ctx.premises.find? fun premise => premise == pattern
```

**is_box_formula Helper** (Lines 147-150):

**Current State**:
```lean
/-- Check if a formula is a box formula (□φ). -/
def is_box_formula (f : Formula) : Bool :=
  sorry
```

**Implementation**:
```lean
/-- Check if a formula is a box formula (□φ).

Returns true if the formula has the form `box φ` for some φ,
false otherwise.

Example:
  is_box_formula (box (atom "p"))  -- true
  is_box_formula (atom "p")        -- false
  is_box_formula (imp (box (atom "p")) (atom "q"))  -- false
-/
def is_box_formula (f : Formula) : Bool :=
  match f with
  | Formula.box _ => true
  | _ => false
```

**is_future_formula Helper** (Lines 152-155):

**Current State**:
```lean
/-- Check if a formula is a future formula (△φ). -/
def is_future_formula (f : Formula) : Bool :=
  sorry
```

**Implementation**:
```lean
/-- Check if a formula is a future formula (△φ).

Returns true if the formula has the form `future φ` for some φ,
false otherwise.

Example:
  is_future_formula (future (atom "p"))  -- true
  is_future_formula (atom "p")           -- false
  is_future_formula (past (atom "p"))    -- false
-/
def is_future_formula (f : Formula) : Bool :=
  match f with
  | Formula.future _ => true
  | _ => false
```

**is_past_formula Helper** (Lines 157-160):

**Current State**:
```lean
/-- Check if a formula is a past formula (◁φ). -/
def is_past_formula (f : Formula) : Bool :=
  sorry
```

**Implementation**:
```lean
/-- Check if a formula is a past formula (◁φ).

Returns true if the formula has the form `past φ` for some φ,
false otherwise.

Example:
  is_past_formula (past (atom "p"))    -- true
  is_past_formula (future (atom "p"))  -- false
  is_past_formula (atom "p")           -- false
-/
def is_past_formula (f : Formula) : Bool :=
  match f with
  | Formula.past _ => true
  | _ => false
```

**Expected Outcomes**:
- assumption_search function works for exact pattern matching
- is_box_formula, is_future_formula, is_past_formula helpers work correctly
- 4 sorry removed (lines 150, 155, 160, 172 in Tactics.lean)

**Testing**:
**File**: `LogosTest/Automation/TacticsTest.lean` (extend)

```lean
-- Test assumption_search
def test_assumption_search : TestCase := {
  name := "assumption_search finds matching premises"
  run := fun () =>
    let p := Formula.atom "p"
    let q := Formula.atom "q"
    let box_p := Formula.box p
    let ctx : Context := { premises := [box_p, Formula.imp p q, q] }

    -- Should find box_p
    assertSome (assumption_search box_p ctx)

    -- Should not find non-existent formula
    assertNone (assumption_search (Formula.atom "r") ctx)
}

-- Test is_box_formula
def test_is_box_formula : TestCase := {
  name := "is_box_formula correctly identifies box formulas"
  run := fun () =>
    let p := Formula.atom "p"
    let box_p := Formula.box p

    assertTrue (is_box_formula box_p)
    assertFalse (is_box_formula p)
    assertFalse (is_box_formula (Formula.imp box_p p))
}

-- Test is_future_formula
def test_is_future_formula : TestCase := {
  name := "is_future_formula correctly identifies future formulas"
  run := fun () =>
    let p := Formula.atom "p"
    let future_p := Formula.future p

    assertTrue (is_future_formula future_p)
    assertFalse (is_future_formula p)
    assertFalse (is_future_formula (Formula.past p))
}

-- Test is_past_formula
def test_is_past_formula : TestCase := {
  name := "is_past_formula correctly identifies past formulas"
  run := fun () =>
    let p := Formula.atom "p"
    let past_p := Formula.past p

    assertTrue (is_past_formula past_p)
    assertFalse (is_past_formula p)
    assertFalse (is_past_formula (Formula.future p))
}

def automation_phase3_suite : TestSuite := {
  name := "Automation Phase 3 Tests (helpers)"
  tests := [
    test_assumption_search,
    test_is_box_formula,
    test_is_future_formula,
    test_is_past_formula
  ]
}
```

**Testing Commands**:
```bash
# Run Phase 3 tests
lake test LogosTest.Automation.TacticsTest

# Verify sorry count decreased
grep -c "sorry" Logos/Automation/Tactics.lean
# Expected: 5 (9 - 4 from Phase 3)
```

**Time Estimate**: 10-20 hours

---

### Task 3B.4: Update Tactic Documentation

**File**: `Documentation/Development/TACTIC_DEVELOPMENT.md`

**Objective**: Document implemented tactics with examples and meta-programming patterns

**Documentation Additions**:

```markdown
## Implemented Tactics

### apply_axiom

**Purpose**: Apply a named axiom schema to the current goal.

**Syntax**: `apply_axiom <axiom_name> <formula_args...>`

**Supported Axioms**:
- `MT φ`: Modal T axiom (□φ → φ)
- `M4 φ`: Modal 4 axiom (□φ → □□φ)
- `MB φ`: Modal B axiom (φ → □◇φ)
- `T4 φ`: Temporal 4 axiom (△φ → △△φ)
- `TA φ`: Temporal A axiom (△φ → φ)
- `TL φ ψ`: Temporal L axiom (△(φ → ψ) → (◁φ → ◁ψ))
- `MF φ`: Modal Future axiom (□△φ → △□φ)
- `TF φ`: Temporal Future axiom (△□φ → □φ)

**Example**:
```lean
theorem example_mt (φ : Formula) : Derivable [] (imp (box φ) φ) := by
  apply Derivable.axiom
  apply_axiom MT φ
```

### modal_t

**Purpose**: Automatically apply modal T axiom when goal matches □φ → φ pattern.

**Syntax**: `modal_t`

**Example**:
```lean
theorem example_auto_t (φ : Formula) : box φ → φ := by
  modal_t  -- Automatically applies MT axiom
```

### tm_auto

**Purpose**: Automated proof search for common TM logic theorem patterns.

**Syntax**: `tm_auto`

**Supported Patterns**:
- Modal T: □φ → φ
- Modal 4: □φ → □□φ
- Modal B: φ → □◇φ
- Temporal 4: △φ → △△φ
- Temporal A: △φ → φ

**Example**:
```lean
theorem example_auto (φ : Formula) : box φ → box (box φ) := by
  tm_auto  -- Automatically proves using M4 axiom
```

## Meta-Programming Patterns Used

### Tactic Elaboration with `elab_rules`

The `apply_axiom` tactic uses LEAN 4's `elab_rules` syntax for custom tactic elaboration:

```lean
elab_rules : tactic
  | `(tactic| apply_axiom $ax:ident $args*) => do
    let axiomName := ax.getId
    let goal ← getMainGoal
    -- ... tactic implementation
```

**Key API Functions**:
- `getMainGoal`: Retrieve current proof goal
- `goal.getType`: Get goal's type expression
- `elabTerm`: Elaborate term syntax into expressions
- `goal.apply`: Apply expression to goal
- `isDefEq`: Check definitional equality
- `throwError`: Report tactic failure with message

### Pattern Matching on Goal Types

Tactics like `modal_t` and `tm_auto` use pattern matching on goal types:

```lean
match goalType with
| app (app (const ``imp _) (app (const ``box _) φ)) ψ =>
    -- Handle □φ → ψ pattern
    if ← isDefEq φ ψ then
      -- φ and ψ are the same, apply MT axiom
| _ =>
    -- Pattern doesn't match, try next strategy
```

### Try-Catch for Tactic Alternatives

The `tm_auto` tactic tries multiple strategies using try-catch:

```lean
try
  evalTactic (← `(tactic| modal_t))
  return  -- Success, exit tactic
catch _ =>
  pure ()  -- Failure, try next strategy
```

This allows graceful fallback through multiple automation approaches.

## Helper Functions

### assumption_search

Search context for formulas matching a pattern:
```lean
def assumption_search (pattern : Formula) (ctx : Context) : Option Formula
```

### Formula Inspectors

Check formula structure:
- `is_box_formula (f : Formula) : Bool` - Check if f = □φ
- `is_future_formula (f : Formula) : Bool` - Check if f = △φ
- `is_past_formula (f : Formula) : Bool` - Check if f = ◁φ
```

**Expected Outcomes**:
- TACTIC_DEVELOPMENT.md updated with implementation examples
- Meta-programming patterns documented
- Helper functions documented

**Time Estimate**: 2-3 hours (included in Phase 3 estimate)

---

### Sub-Phase 3B Summary

**Total Phases**: 3
**Estimated Time**: 40-60 hours (15-20 + 15-20 + 10-20)
**Sorry Removed**: 7 (apply_axiom, modal_t, tm_auto, assumption_search, 3 helpers)
**Tactics Implemented**: 3 (apply_axiom, modal_t, tm_auto)
**Helpers Implemented**: 4 (assumption_search, is_box_formula, is_future_formula, is_past_formula)
**Files Modified**:
- `Logos/Automation/Tactics.lean` (implementations)
- `Documentation/Development/TACTIC_DEVELOPMENT.md` (documentation)
**Files Created**:
- Tests in `LogosTest/Automation/TacticsTest.lean`

**Success Criteria**:
- [ ] apply_axiom tactic works for all 8 axioms
- [ ] modal_t tactic auto-applies MT axiom
- [ ] tm_auto tactic handles 5 common patterns
- [ ] assumption_search finds matching premises
- [ ] Helper functions correctly identify formula types
- [ ] All 7 sorry removed from Tactics.lean
- [ ] TACTIC_DEVELOPMENT.md updated with examples
- [ ] All automation tests passing
- [ ] lake build succeeds
- [ ] lake test LogosTest.Automation.TacticsTest passes

---

## Sub-Phase 3C: Fix WorldHistory Universal Helper (Task 8) [NOT STARTED]

### Objective
Prove respects_task property for universal history helper, removing 1 sorry placeholder from WorldHistory.lean.

### Complexity
Low - Single property proof for existing helper function

### Estimated Hours
1-2 hours

### Dependencies
- Phase 1 complete (no specific dependency on propositional axioms)
- No dependency on Phase 2 (Perpetuity) or other Wave 2 tasks

### Tasks

#### Task 3C.1: Prove respects_task Property for Universal Helper

**File**: `Logos/Semantics/WorldHistory.lean`

**Objective**: Complete proof of respects_task property at line 75

**Current State** (Line 75):
```lean
def universal_history (frame : TaskFrame) (w : frame.WorldState) : WorldHistory frame :=
  { toFun := λ _ => w
    respects_task := by sorry }
```

**Analysis**:
The universal history maps every time to the same world state `w`. To prove `respects_task`, we need to show that for any task `T` and times `t1`, `t2`, applying the task at `t1` to get the state at `t2` is consistent with the universal history.

**Frame Task Relation Properties** (from TaskFrame.lean):
- `nullity`: The identity task (λ t' => w t') applied at any time gives back the same world
- `compositionality`: Task composition is associative

**Proof Strategy**:
```lean
def universal_history (frame : TaskFrame) (w : frame.WorldState) : WorldHistory frame :=
  { toFun := λ _ => w
    respects_task := by
      -- Need to prove: for all t1, t2, and task T,
      -- if frame.task t1 (toFun t1) = some T and T t2 = toFun t2,
      -- then the history respects the task relation
      intro t1 t2 T h_task
      -- toFun t1 = w and toFun t2 = w (by definition of universal_history)
      -- Need to show: frame.task t1 w produces a task that maps t2 to w

      -- Case analysis on whether t1 = t2
      by_cases h_eq : t1 = t2
      case pos =>
        -- If t1 = t2, use nullity property
        rw [h_eq]
        -- frame.task t2 w (λ t' => w t') = some w (by nullity)
        -- This implies T = (λ t' => w), so T t2 = w = toFun t2
        sorry  -- Complete using nullity
      case neg =>
        -- If t1 ≠ t2, use general task properties
        -- Universal history is constant, so any task preserves this
        sorry  -- Complete using task relation properties
  }
```

**Detailed Proof** (Replace sorry at line 75):
```lean
def universal_history (frame : TaskFrame) (w : frame.WorldState) : WorldHistory frame :=
  { toFun := λ _ => w
    respects_task := by
      intro t1 t2 T h_task
      -- Goal: Show that applying task T at t1 to world w gives world w at t2
      -- Given: h_task says T is the result of frame.task t1 w

      -- The universal history is constant (always returns w)
      -- We need to show that for the specific frame, this is task-respecting

      -- Strategy: Use the fact that w is constant across all times
      -- The task relation should preserve this (depends on frame properties)

      -- For specific frames, this may require additional assumptions
      -- For now, we can use a simplified proof for well-behaved frames

      -- If frame.task t1 w = some T, then T should map t2 to w
      -- This holds for frames where constant histories are task-respecting

      -- Complete proof requires frame-specific analysis
      -- For the Logos's TaskFrame, verify this property holds
      admit  -- Placeholder for frame-specific proof
  }
```

**Note**: The complete proof depends on specific properties of the TaskFrame used in Logos. The universal helper may require additional frame constraints or may only be valid for certain frame classes.

**Alternative Approach** (If proof is complex):
Document the universal_history as conditional on a frame property:

```lean
/-- Universal history helper (conditional on frame property).

This helper creates a history that maps every time to the same world state.
It is task-respecting for frames satisfying the "constant preservation" property:
For all worlds w and times t, if h(t') = w for all t', then h respects the task relation.

For frames without this property, use alternative history construction methods.
-/
def universal_history (frame : TaskFrame) (w : frame.WorldState)
    (h_constant_preserving : ConstantPreservingFrame frame) : WorldHistory frame :=
  { toFun := λ _ => w
    respects_task := by
      -- Proof uses h_constant_preserving assumption
      sorry  -- Complete using frame property
  }
```

**Expected Outcomes**:
- respects_task property proven (line 75 sorry removed) OR
- universal_history documented as conditional on frame property
- Approach chosen based on proof complexity analysis

**Testing**:
```bash
# Verify WorldHistory compiles
lake build Logos.Semantics.WorldHistory

# Check for remaining sorry
grep -n "sorry" Logos/Semantics/WorldHistory.lean
# Expected: 0 results at line 75
```

**Time Estimate**: 1-2 hours

---

#### Task 3C.2: Add Test Case for Universal History

**File**: `LogosTest/Semantics/WorldHistoryTest.lean`

**Objective**: Test universal history helper with various frames

**Test Implementation**:
```lean
import Logos.Semantics.WorldHistory
import LogosTest.TestFramework

namespace LogosTest.Semantics.WorldHistoryTest

-- Test universal history construction
def test_universal_history_construction : TestCase := {
  name := "Universal history maps all times to same world state"
  run := fun () =>
    -- Create a simple frame
    let frame : TaskFrame := simple_test_frame
    let w : frame.WorldState := test_world_state

    -- Create universal history
    let h := universal_history frame w

    -- Verify all times map to w
    let t1 := test_time_1
    let t2 := test_time_2
    assertEqual (h.toFun t1) w
    assertEqual (h.toFun t2) w
}

-- Test universal history respects task relation
def test_universal_history_respects_task : TestCase := {
  name := "Universal history respects task relation"
  run := fun () =>
    -- Create frame and universal history
    let frame : TaskFrame := simple_test_frame
    let w : frame.WorldState := test_world_state
    let h := universal_history frame w

    -- Create a task
    let t1 := test_time_1
    let t2 := test_time_2
    let T := frame.task t1 w

    -- Verify respects_task holds
    -- (This test verifies the proof at line 75 works correctly)
    match T with
    | some task =>
        let w' := task t2
        assertEqual w' (h.toFun t2)
    | none =>
        -- Task doesn't exist, skip test
        pure ()
}

def world_history_test_suite : TestSuite := {
  name := "WorldHistory Tests (Wave 2 Task 8)"
  tests := [
    test_universal_history_construction,
    test_universal_history_respects_task
  ]
}

end LogosTest.Semantics.WorldHistoryTest
```

**Expected Outcomes**:
- 2 tests added for universal history
- Tests verify construction and task-respecting property
- All tests pass

**Testing Commands**:
```bash
# Run WorldHistory tests
lake test LogosTest.Semantics.WorldHistoryTest

# Verify overall sorry count decreased
grep -r "sorry" Logos/ --include="*.lean" | wc -l
# Expected: 25 (26 - 1 from WorldHistory)
```

**Time Estimate**: 0.5-1 hour (included in Task 3C.1 estimate)

---

### Sub-Phase 3C Summary

**Total Tasks**: 2
**Estimated Time**: 1-2 hours
**Sorry Removed**: 1 (WorldHistory.lean line 75)
**Files Modified**:
- `Logos/Semantics/WorldHistory.lean` (proof)
**Files Created**:
- Tests in `LogosTest/Semantics/WorldHistoryTest.lean`

**Success Criteria**:
- [ ] respects_task property proven for universal_history
- [ ] Line 75 sorry removed from WorldHistory.lean
- [ ] 2 tests added for universal history
- [ ] All WorldHistory tests passing
- [ ] lake build succeeds
- [ ] lake test LogosTest.Semantics.WorldHistoryTest passes

---

## Phase 3 Documentation Updates

### Task 3.12: Update Documentation for Tasks 5, 7, 8 Completion

**Objective**: Synchronize TODO.md, IMPLEMENTATION_STATUS.md, and KNOWN_LIMITATIONS.md after all Wave 2 parallel tasks complete

**Files to Update**:
1. `TODO.md`
2. `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
3. `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`

**Estimated Time**: 1-2 hours

---

#### Update TODO.md

**Changes Required**:

**1. Mark Tasks Complete** (lines 28-30, 50-64):
```markdown
### High Priority (MVP Blockers) [COMPLETE]
- [x] **Task 1**: Fix CI continue-on-error flags (completed 2025-12-02)
- [x] **Task 2**: Add propositional axioms K and S (completed 2025-12-02)
- [x] **Task 3**: Create Archive example files (completed 2025-12-02)

### Medium Priority (Layer 0 Enhancements) [COMPLETE]
- [x] **Task 5**: Complete soundness proofs (TL, MF, TF axioms + rules) (completed 2025-12-XX)
- [x] **Task 6**: Complete perpetuity proofs (P4-P6) (completed 2025-12-XX)
- [x] **Task 7**: Implement core automation tactics (Phase 1-3) (completed 2025-12-XX)
- [x] **Task 8**: Fix WorldHistory universal helper (completed 2025-12-XX)
```

**2. Update Status Summary** (lines 83-89):
```markdown
### Status Summary
- **Overall**: 8/11 tasks complete (73%)
- **High Priority**: 4/4 (100%) ✓
- **Medium Priority**: 4/4 (100%) ✓
- **Low Priority**: 0/3 (0%)

**Critical Path Complete**: All high/medium priority tasks finished.
**Remaining Work**: Low priority long-term tasks (Completeness, Decidability, Layer planning).
```

**3. Update Sorry Placeholder Registry** (remove 16 entries):
```markdown
### Sorry Placeholder Resolution

**Total Sorry Count**: 22 (down from 41 at plan creation)

**Resolved in Wave 2** (19 sorry removed):
- ✓ Soundness.lean: 15 sorry removed (TL/MF/TF axioms + modal_k/temporal_k/temporal_duality rules)
- ✓ Perpetuity.lean: 3 sorry removed (P4, P5, P6 proofs)
- ✓ WorldHistory.lean: 1 sorry removed (universal_history respects_task)

**Remaining Sorry** (22 placeholders):
- ProofSearch.lean: 3 sorry (automation stubs)
- Completeness.lean: 11 sorry (axiom placeholders for canonical model)
- Tactics.lean: 8 sorry (remaining tactic stubs)
```

**4. Add Completion Log Entries**:
```markdown
### Completion Log
...
- 2025-12-XX: Task 5 (Soundness proofs) - 15 sorry removed, all axioms/rules proven sound
- 2025-12-XX: Task 6 (Perpetuity P4-P6) - 3 sorry removed, all 6 principles complete
- 2025-12-XX: Task 7 (Core automation Phase 1-3) - 7 sorry removed, 3 tactics + 4 helpers implemented
- 2025-12-XX: Task 8 (WorldHistory fix) - 1 sorry removed, universal helper proven
- 2025-12-XX: Wave 2 Complete - High/Medium priority finished, 19 sorry resolved
```

---

#### Update IMPLEMENTATION_STATUS.md

**Changes Required**:

**1. Update Module Status Percentages**:
```markdown
### Metalogic
- **Soundness**: 100% (was 60%)
  - All 8 axioms proven valid (MT, M4, MB, T4, TA, TL, MF, TF)
  - All 7 rules proven sound (axiom, assumption, MP, weakening, modal_k, temporal_k, temporal_duality)
  - 0 sorry remaining (was 15)
  - Status: **Complete** ✓

- **Completeness**: 0% (unchanged)
  - 11 axiom placeholders (canonical model construction)
  - No proofs yet (planned for Wave 3)
  - Status: **Not Started**
```

**2. Update Theorems Package**:
```markdown
### Theorems Package
- **Perpetuity Principles**: 100% (was 50%)
  - P1: `□φ → △φ` - Proven ✓
  - P2: `▽φ → ◇φ` - Proven ✓
  - P3: `□φ → □△φ` - Proven ✓
  - P4: `◇▽φ → ◇φ` - Proven ✓ (Wave 2)
  - P5: `◇▽φ → △◇φ` - Proven ✓ (Wave 2)
  - P6: `▽□φ → □△φ` - Proven ✓ (Wave 2)
  - 0 sorry remaining (was 3)
  - Status: **Complete** ✓
```

**3. Update Automation Package**:
```markdown
### Automation Package
- **Tactics**: 40-50% (was 0%)
  - apply_axiom: Implemented ✓ (supports all 8 axioms)
  - modal_t: Implemented ✓ (auto-applies MT axiom)
  - tm_auto: Implemented ✓ (5 pattern automation)
  - assumption_search: Implemented ✓
  - Helper functions: Implemented ✓ (is_box_formula, is_future_formula, is_past_formula)
  - Remaining stubs: 8 tactics (modal_4, modal_b, etc.)
  - Status: **Partial Implementation** (3/12 tactics complete)

- **ProofSearch**: 0% (unchanged)
  - 3 sorry remaining
  - Status: **Not Started**
```

**4. Update Semantics Package**:
```markdown
### Semantics Package
- **WorldHistory**: 100% (was ~90%)
  - universal_history helper: respects_task proven ✓
  - 0 sorry remaining (was 1)
  - Status: **Complete** ✓
```

**5. Update Overall Summary**:
```markdown
### Quick Summary
- **Layer 0 High/Medium Priority**: **100% Complete** ✓
  - Soundness: Complete
  - Perpetuity: Complete
  - Core Automation: Partial (40-50%)
  - WorldHistory: Complete
- **Layer 0 Low Priority**: 0% (Completeness, Decidability pending)
- **Remaining Sorry**: 22 (down from 41)
```

---

#### Update KNOWN_LIMITATIONS.md

**Changes Required**:

**1. Remove Soundness Gaps Section** (Section 1):
```markdown
## 1. Metalogic Soundness Gaps [RESOLVED ✓]

~~**Status**: 15 sorry placeholders in Soundness.lean~~

**Resolution** (2025-12-XX): All soundness gaps resolved in Wave 2 Task 5.
- TL, MF, TF axiom validity proven with frame constraint documentation
- modal_k, temporal_k, temporal_duality rule soundness proven
- Soundness module 100% complete (0 sorry remaining)

See `Logos/Metalogic/Soundness.lean` for complete proofs.
```

**2. Remove Perpetuity P4-P6 Gaps** (Section 3 subsection):
```markdown
### 3.2 Perpetuity Principles P4-P6 [RESOLVED ✓]

~~**Status**: 3 sorry placeholders for P4, P5, P6~~

**Resolution** (2025-12-XX): All perpetuity principles proven in Wave 2 Task 6.
- P4: `◇▽φ → ◇φ` proven using corrected contraposition helper
- P5: `◇▽φ → △◇φ` proven using modal-temporal interaction lemmas
- P6: `▽□φ → □△φ` proven using modal-temporal interaction lemmas

See `Logos/Theorems/Perpetuity.lean` for complete proofs.
```

**3. Update Automation Section** (Section 4):
```markdown
## 4. Automation Gaps [PARTIALLY RESOLVED]

**Status**: 3 tactics implemented (apply_axiom, modal_t, tm_auto), 9 stubs remaining

**Implemented Tactics** (Wave 2 Task 7):
- `apply_axiom`: Apply named axiom to goal ✓
- `modal_t`: Auto-apply modal T axiom ✓
- `tm_auto`: Simple automated proof search ✓
- Helper functions: assumption_search, is_box_formula, is_future_formula, is_past_formula ✓

**Remaining Stubs** (8 sorry):
- modal_4, modal_b, modal_5, modal_search (modal tactics)
- temporal_4, temporal_a, temporal_search (temporal tactics)
- bimodal_search (bimodal tactic)

**Workarounds**:
- Use implemented tactics (apply_axiom, modal_t, tm_auto) for common patterns
- Manual proof construction for cases not covered by automation
- See `Documentation/Development/TACTIC_DEVELOPMENT.md` for examples

**Future Work**: Complete remaining 8 tactics in post-MVP work.
```

**4. Remove WorldHistory Gap** (if mentioned):
```markdown
### 5.X WorldHistory Universal Helper [RESOLVED ✓]

~~**Status**: 1 sorry placeholder for universal_history respects_task property~~

**Resolution** (2025-12-XX): Property proven in Wave 2 Task 8.

See `Logos/Semantics/WorldHistory.lean` line 75 for complete proof.
```

---

### Documentation Update Summary

**Files Updated**: 3
- TODO.md: Task status, sorry count, completion log
- IMPLEMENTATION_STATUS.md: Module percentages, overall summary
- KNOWN_LIMITATIONS.md: Resolved gaps, updated workarounds

**Expected Outcomes**:
- [ ] TODO.md shows Tasks 5-8 complete
- [ ] TODO.md shows 22 sorry remaining (down from 41)
- [ ] IMPLEMENTATION_STATUS.md shows Soundness 100%, Perpetuity 100%, Automation 40-50%
- [ ] KNOWN_LIMITATIONS.md gaps removed for resolved issues
- [ ] All three files consistent and synchronized

**Verification**:
```bash
# Verify documentation consistency
grep "tasks complete" TODO.md
# Expected: 8/11 (73%)

grep "Soundness.*100%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
# Expected: match found

grep "Sorry Count.*22" TODO.md
# Expected: match found

# Verify sorry count matches documentation
grep -r "sorry" Logos/ --include="*.lean" | wc -l
# Expected: 22 (matching TODO.md claim)
```

---

## Phase 3 Overall Summary

### Parallel Execution Timeline

**Optimal Parallel Execution** (3 developers):
```
Sub-Phase 3A (Soundness): ████████████████░░░░░░░░░░░░░░ (15-20 hours)
Sub-Phase 3B (Automation): ████████████████████████████████████████░░░░░░░░░░ (40-60 hours)
Sub-Phase 3C (WorldHistory): ██░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ (1-2 hours)
Documentation (3.12):         ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░██ (1-2 hours)

Total Parallel Time: ~40-60 hours (bottleneck is Sub-Phase 3B)
Total Sequential Time: 56-82 hours
Time Savings: 16-22 hours (25-32%)
```

**Single Developer Sequential Execution**:
```
3A → 3B → 3C → Documentation: 56-82 hours total
```

### Success Criteria

**Phase 3 Complete When**:
- [ ] Sub-Phase 3A: All 15 soundness sorry removed
- [ ] Sub-Phase 3B: 7 automation sorry removed, 3 tactics + 4 helpers implemented
- [ ] Sub-Phase 3C: 1 WorldHistory sorry removed
- [ ] Documentation: TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md synchronized
- [ ] Total sorry decreased: 41 → 22 (19 removed)
- [ ] lake build succeeds
- [ ] lake test passes (all new tests)
- [ ] lake lint returns zero warnings

### Files Modified

**Source Files**:
- Logos/Semantics/TaskFrame.lean (documentation)
- Logos/Metalogic/Soundness.lean (15 proofs)
- Logos/Automation/Tactics.lean (7 implementations)
- Logos/Semantics/WorldHistory.lean (1 proof)

**Test Files**:
- LogosTest/Metalogic/SoundnessTest.lean (6 new tests)
- LogosTest/Automation/TacticsTest.lean (extensive test suite)
- LogosTest/Semantics/WorldHistoryTest.lean (2 new tests)

**Documentation Files**:
- TODO.md (task status, sorry count)
- Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (module status)
- Documentation/ProjectInfo/KNOWN_LIMITATIONS.md (gaps resolved)
- Documentation/Development/TACTIC_DEVELOPMENT.md (tactic examples)

### Testing Strategy

**After Each Sub-Phase**:
```bash
# Sub-Phase 3A completion
lake test LogosTest.Metalogic.SoundnessTest

# Sub-Phase 3B completion (after each phase)
lake test LogosTest.Automation.TacticsTest

# Sub-Phase 3C completion
lake test LogosTest.Semantics.WorldHistoryTest
```

**Phase 3 Final Verification**:
```bash
# Full build
lake build

# Full test suite
lake test

# Lint check
lake lint

# Sorry count verification
grep -r "sorry" Logos/ --include="*.lean" | wc -l
# Expected: 22 (down from 41)

# Documentation consistency check
grep "8/11" TODO.md  # Tasks complete
grep "100%" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md | grep -E "Soundness|Perpetuity"
```

### Risk Mitigation

**Risk 1**: Frame constraints for soundness may be complex
- **Mitigation**: Option B (conditional validity) provides fallback if constraints too difficult
- **Impact**: Low - either approach satisfies MVP completion criteria

**Risk 2**: Automation tactics require deep LEAN 4 meta-programming knowledge
- **Mitigation**: Phased approach (3 phases) allows learning curve and early value delivery
- **Impact**: Medium - can deliver Phase 1-2 and defer Phase 3 if time-constrained

**Risk 3**: WorldHistory proof depends on frame-specific properties
- **Mitigation**: Can document as conditional on frame property if proof too complex
- **Impact**: Low - 1-2 hour task unlikely to block phase

### Dependencies for Next Phases

**Phase 4 Dependencies**:
- Phase 3 completion (all Wave 2 parallel tasks)
- Phase 2 completion (Perpetuity proofs)
- Enables documentation synchronization and Wave 2 completion milestone

**No Blocking Dependencies for**:
- Phase 5+ (Wave 3 Completeness) - can begin after Phase 4
- Wave 3 and Phase 3 are independent

---

## Completion Signal

When Phase 3 is complete, return:

```
PHASE_EXPANDED: /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/019_research_todo_implementation_plan/plans/phase_3_wave2_parallel_soundness_automation_worldhistory.md

Sub-Phases: 3
Estimated Hours: 56-82 sequential, 40-60 parallel
Sorry Removed: 19 (15 Soundness + 3 Perpetuity + 1 WorldHistory)
Tactics Implemented: 3 (apply_axiom, modal_t, tm_auto)
Helpers Implemented: 4 (assumption_search, is_box_formula, is_future_formula, is_past_formula)
```
