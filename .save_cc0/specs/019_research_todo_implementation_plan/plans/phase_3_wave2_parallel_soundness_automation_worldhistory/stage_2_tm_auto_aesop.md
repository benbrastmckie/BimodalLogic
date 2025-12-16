# Stage 2: Implement tm_auto with Aesop Integration

## Metadata

- **Stage Number**: 2 of 3
- **Parent Phase**: Sub-Phase 3B - Implement Core Automation (Task 7)
- **Parent Plan**: `.claude/specs/019_research_todo_implementation_plan/plans/001-research-todo-implementation-plan.md`
- **Dependencies**: Stage 1 complete (`apply_axiom` and `modal_t` working)
- **Estimated Hours**: 12-15 hours (revised from 15-20 with TACTIC_DEVELOPMENT.md Section 4)
- **Status**: [NOT STARTED]
- **Complexity**: Medium-High

## Objective

Implement `tm_auto` tactic with Aesop integration for comprehensive TM logic automation. Declare TMLogic rule set, mark TM axioms and rules as safe rules, configure Aesop search depth and heuristics, and test on complex TM proofs. Remove 1 sorry placeholder in `Tactics.lean`.

## Context

This stage implements Phase 2 of the three-phase automation roadmap:
- **Phase 1** (complete): `apply_axiom` + `modal_t` → Basic axiom application
- **Phase 2** (this stage): `tm_auto` with Aesop integration → Comprehensive automation
- **Phase 3**: `assumption_search` + helpers → Context search and helper tactics

**Documentation Available**:
- `TACTIC_DEVELOPMENT.md` Section 4 (lines 282-423): Complete Aesop integration patterns
- `CLAUDE.md` Section 10.1 (lines 304-320): Aesop integration quick reference
- Aesop Documentation: https://github.com/leanprover-community/aesop

**Time Savings**: TACTIC_DEVELOPMENT.md Section 4 eliminates 2-3 hours of Aesop API exploration.

## Success Criteria

- [ ] TMLogic Aesop rule set declared
- [ ] All 8 TM axioms marked as safe rules with `@[aesop safe [TMLogic]]`
- [ ] TM inference rules marked as safe rules (MP, MK, TK, TD)
- [ ] `tm_auto` macro implemented: `aesop (rule_sets [TMLogic])`
- [ ] Aesop search depth and heuristics configured appropriately
- [ ] Comprehensive test suite with complex TM proofs (≥8 tests)
- [ ] All tests pass: `lake test LogosTest.Automation.TacticsTest`
- [ ] 1 sorry removed from `Tactics.lean` (line 205)
- [ ] Zero #lint warnings
- [ ] Documentation updated with Aesop integration patterns

## Implementation Steps

### Step 1: Review Aesop Integration Documentation (30-45 minutes)

**Objective**: Understand Aesop rule attribution, custom rule sets, and integration patterns

**Resources to Review**:

1. **TACTIC_DEVELOPMENT.md Section 4** (20-30 minutes):
   - Lines 282-305: Aesop rule attribution (`@[aesop safe]`, `@[aesop norm simp]`)
   - Lines 306-340: Custom rule sets (declare_aesop_rule_sets, TMLogic rule set)
   - Lines 341-367: tm_auto macro implementation
   - Lines 368-415: Normalization rules and forward reasoning patterns

2. **CLAUDE.md Section 10.1** (10 minutes):
   - Lines 304-320: Complete TMLogic rule set example
   - Aesop integration pattern with safe rules

3. **Aesop GitHub Documentation** (Optional, 15 minutes):
   - https://github.com/leanprover-community/aesop#rule-sets
   - Custom rule set configuration
   - Search depth and heuristic options

**Action Items**:
- [ ] Read TACTIC_DEVELOPMENT.md Section 4 in detail
- [ ] Review CLAUDE.md Section 10.1 Aesop pattern
- [ ] Bookmark Aesop GitHub docs for reference
- [ ] Note which axioms to mark as safe rules (all 8 TM axioms)

**Output**: Clear understanding of `@[aesop safe [TMLogic]]` attribution and custom rule set declaration.

---

### Step 2: Declare TMLogic Aesop Rule Set (1-2 hours)

**Objective**: Create custom TM logic rule set for Aesop automation

**File**: `Logos/Automation/Tactics.lean` (add after imports)

**Implementation**:

```lean
-- After imports and namespace declaration

/-! ## Aesop Integration for TM Logic -/

/-- Custom Aesop rule set for TM (Tense and Modality) logic.

This rule set contains safe rules for:
- TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
- TM inference rules (MP, MK, TK, TD)
- Perpetuity principles (P1-P6, once implemented)

Safe rules are always applicable and preserve correctness.
Use `tm_auto` macro to invoke Aesop with this rule set.
-/
declare_aesop_rule_sets [TMLogic]
```

**Reference**: TACTIC_DEVELOPMENT.md lines 310-312

**Action Items**:
- [ ] Add `declare_aesop_rule_sets [TMLogic]` after namespace declaration
- [ ] Add comprehensive docstring explaining rule set purpose
- [ ] Document which rule categories will be included
- [ ] Verify compilation: `lake build Logos.Automation.Tactics`

**Expected Output**: TMLogic rule set declared, ready for rule attribution.

---

### Step 3: Mark TM Axioms as Safe Rules (2-3 hours)

**Objective**: Attribute all 8 TM axioms as safe Aesop rules in TMLogic rule set

**File**: `Logos/ProofSystem/Axioms.lean`

**Approach**: Add `@[aesop safe [TMLogic]]` to axiom validity theorems

**Current State**: Axioms are defined as inductive type constructors without Aesop attribution

**Implementation Strategy**:

Create helper theorems that convert axiom constructors to `Derivable` proofs, then mark as safe rules:

```lean
-- File: Logos/ProofSystem/Axioms.lean (add after axiom definitions)

import Lean.Elab.Tactic

namespace Logos.ProofSystem

/-! ## Aesop Safe Rules for TM Axioms -/

/-- Modal T axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem modal_t_derivable (φ : Formula) :
  Derivable [] (Formula.box φ).imp φ := by
  apply Derivable.axiom
  exact Axiom.modal_t φ

/-- Modal 4 axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem modal_4_derivable (φ : Formula) :
  Derivable [] (Formula.box φ).imp (Formula.box (Formula.box φ)) := by
  apply Derivable.axiom
  exact Axiom.modal_4 φ

/-- Modal B axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem modal_b_derivable (φ : Formula) :
  Derivable [] φ.imp (Formula.box (diamond φ)) := by
  apply Derivable.axiom
  exact Axiom.modal_b φ

/-- Temporal 4 axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem temporal_4_derivable (φ : Formula) :
  Derivable [] (Formula.future φ).imp (Formula.future (Formula.future φ)) := by
  apply Derivable.axiom
  exact Axiom.temporal_4 φ

/-- Temporal A axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem temporal_a_derivable (φ : Formula) :
  Derivable [] (Formula.future φ).imp φ := by
  apply Derivable.axiom
  exact Axiom.temporal_a φ

/-- Temporal L axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem temporal_l_derivable (φ ψ : Formula) :
  Derivable [] (Formula.future (φ.imp ψ)).imp ((Formula.past φ).imp (Formula.past ψ)) := by
  apply Derivable.axiom
  exact Axiom.temporal_l φ ψ

/-- Modal-Future axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem modal_future_derivable (φ : Formula) :
  Derivable [] (Formula.box (Formula.future φ)).imp (Formula.future (Formula.box φ)) := by
  apply Derivable.axiom
  exact Axiom.modal_future φ

/-- Temporal-Future axiom is derivable (safe rule for Aesop) -/
@[aesop safe [TMLogic]]
theorem temporal_future_derivable (φ : Formula) :
  Derivable [] (Formula.future (Formula.future φ)).imp (Formula.future (Formula.future φ)) := by
  apply Derivable.axiom
  exact Axiom.temporal_future φ

end Logos.ProofSystem
```

**Reference**: TACTIC_DEVELOPMENT.md lines 314-335

**Action Items**:
- [ ] Add Aesop safe rule theorems to `Axioms.lean`
- [ ] Create derivability wrapper for each axiom (8 theorems)
- [ ] Mark each with `@[aesop safe [TMLogic]]`
- [ ] Add docstrings explaining safe rule purpose
- [ ] Verify compilation: `lake build Logos.ProofSystem.Axioms`
- [ ] Check Aesop can see rules: Run simple test with `tm_auto`

**Expected Output**: 8 axiom safe rules registered in TMLogic rule set.

---

### Step 4: Mark TM Inference Rules as Safe Rules (1-2 hours)

**Objective**: Attribute modus ponens and modal/temporal K rules as safe Aesop rules

**File**: `Logos/ProofSystem/Derivation.lean`

**Implementation**:

```lean
-- File: Logos/ProofSystem/Derivation.lean (add after Derivable inductive)

/-! ## Aesop Forward Reasoning Rules -/

/-- Modus ponens forward rule for Aesop -/
@[aesop safe forward [TMLogic]]
theorem modus_ponens_forward (φ ψ : Formula) (Γ : Context)
    (h1 : Derivable Γ (φ.imp ψ)) (h2 : Derivable Γ φ) :
  Derivable Γ ψ :=
  Derivable.modus_ponens h1 h2

/-- Modal K rule forward for Aesop -/
@[aesop safe forward [TMLogic]]
theorem modal_k_forward (φ ψ : Formula) (Γ : Context)
    (h1 : Derivable Γ (Formula.box (φ.imp ψ)))
    (h2 : Derivable Γ (Formula.box φ)) :
  Derivable Γ (Formula.box ψ) :=
  Derivable.modal_k h1 h2

/-- Temporal K rule forward for Aesop -/
@[aesop safe forward [TMLogic]]
theorem temporal_k_forward (φ ψ : Formula) (Γ : Context)
    (h1 : Derivable Γ (Formula.future (φ.imp ψ)))
    (h2 : Derivable Γ (Formula.future φ)) :
  Derivable Γ (Formula.future ψ) :=
  Derivable.temporal_k h1 h2

/-- Temporal duality rule forward for Aesop -/
@[aesop safe forward [TMLogic]]
theorem temporal_duality_forward (φ : Formula) (Γ : Context)
    (h : Derivable Γ (neg (Formula.future (neg φ)))) :
  Derivable Γ (Formula.past φ) :=
  Derivable.temporal_duality h
```

**Reference**: TACTIC_DEVELOPMENT.md lines 405-415

**Forward Reasoning Explanation**:
- `@[aesop safe forward]` tells Aesop to apply rule when hypotheses match
- Enables forward chaining: if `Γ ⊢ φ → ψ` and `Γ ⊢ φ` exist, derive `Γ ⊢ ψ`
- Essential for multi-step proofs

**Action Items**:
- [ ] Add forward rule theorems to `Derivation.lean`
- [ ] Create forward wrapper for each inference rule (4 rules)
- [ ] Mark each with `@[aesop safe forward [TMLogic]]`
- [ ] Add docstrings explaining forward chaining
- [ ] Verify compilation: `lake build Logos.ProofSystem.Derivation`

**Expected Output**: 4 inference rule safe forward rules registered in TMLogic rule set.

---

### Step 5: Implement tm_auto Macro (2-3 hours)

**Objective**: Implement `tm_auto` macro that invokes Aesop with TMLogic rule set

**File**: `Logos/Automation/Tactics.lean`

**Current State** (Lines 195-205):
```lean
/-- Automated proof search for TM logic theorems. -/
syntax "tm_auto" : tactic

macro_rules
  | `(tactic| tm_auto) => `(tactic| sorry)
```

**Implementation**:

```lean
/-- Automated proof search for TM logic theorems using Aesop.

The `tm_auto` tactic invokes Aesop with the TMLogic custom rule set, which includes:
- All 8 TM axiom schemata (MT, M4, MB, T4, TA, TL, MF, TF)
- TM inference rules (MP, MK, TK, TD) as forward reasoning rules
- Perpetuity principles (P1-P6, once implemented)

Aesop performs bounded proof search using registered safe rules. If no proof
is found within the search depth limit, the tactic fails with an error message.

**Usage**:

```lean
-- Simple axiom application
theorem example_mt (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  tm_auto
  -- Automatically finds and applies MT axiom

-- Multi-step proof with modus ponens
theorem example_mp (P Q : Formula) :
    Derivable [Formula.box P, (Formula.box P).imp Q] (Formula.box Q) := by
  tm_auto
  -- Finds: 1) assumption for □P, 2) assumption for □P → Q, 3) applies MP

-- Modal K inference
theorem example_mk (P Q : Formula) :
    Derivable [Formula.box (P.imp Q), Formula.box P] (Formula.box Q) := by
  tm_auto
  -- Finds assumptions and applies modal K rule
```

**Limitations**:
- Search depth limit (default: 30 steps)
- May not find proof requiring deep search (>30 steps)
- Does not handle Layer 1+ operators (counterfactual, epistemic)
- Performance degrades on deeply nested formulas (>10 operators)

**Configuration**:
- Search depth: Configurable via `aesop (rule_sets [TMLogic]) (options := {maxRuleApplications := N})`
- Tracing: Enable with `set_option trace.aesop true`

**Error Messages**:
- "aesop: failed to prove goal" → No proof found within search depth
- Try manual tactics or increase search depth
-/
syntax "tm_auto" : tactic

macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))

/-- tm_auto with custom search depth configuration -/
macro "tm_auto_depth" n:num : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]) (options := {maxRuleApplications := $n}))

/-- tm_auto with tracing enabled for debugging -/
macro "tm_auto_trace" : tactic =>
  `(tactic| set_option trace.aesop true in aesop (rule_sets [TMLogic]))
```

**Reference**: TACTIC_DEVELOPMENT.md lines 341-367

**Action Items**:
- [ ] Replace lines 195-205 with full `tm_auto` implementation
- [ ] Add comprehensive docstring with usage examples
- [ ] Implement 3 macro variants (basic, depth-configurable, tracing)
- [ ] Document limitations and error messages
- [ ] Test compilation: `lake build Logos.Automation.Tactics`

**Expected Output**: `tm_auto` macro invokes Aesop with TMLogic rule set successfully.

---

### Step 6: Configure Aesop Search Depth and Heuristics (1-2 hours)

**Objective**: Tune Aesop configuration for optimal TM logic proof search

**Configuration Options**:

```lean
/-! ## Aesop Configuration for TM Logic -/

/-- Default search depth for tm_auto (30 rule applications) -/
def tmAutoDefaultDepth : Nat := 30

/-- Increased search depth for complex proofs (100 rule applications) -/
def tmAutoDeepSearchDepth : Nat := 100

/-- Configuration for deterministic proof search (no randomness) -/
def tmAutoDeterministicConfig : Aesop.Options := {
  maxRuleApplications := 30,
  terminal := true  -- Stop at first proof found
}

/-- Configuration for exhaustive search (find all proofs) -/
def tmAutoExhaustiveConfig : Aesop.Options := {
  maxRuleApplications := 100,
  terminal := false  -- Explore all proof branches
}
```

**Heuristic Selection**:
- **Default**: Breadth-first search (explore all rules at each depth level)
- **Performance**: Prefer axiom rules over forward reasoning (faster)
- **Completeness**: Include forward reasoning for multi-step proofs

**Action Items**:
- [ ] Add configuration definitions to `Tactics.lean`
- [ ] Test default depth (30) on simple proofs
- [ ] Test increased depth (100) on complex proofs
- [ ] Measure performance: time `tm_auto` on benchmark suite
- [ ] Adjust depth based on performance/completeness tradeoff

**Expected Output**: Optimal search depth configuration for TM proofs.

---

### Step 7: Create Comprehensive Test Suite (3-4 hours)

**Objective**: Test `tm_auto` on progressively complex TM proofs

**File**: `LogosTest/Automation/TacticsTest.lean` (extend)

**Test Categories**:

1. **Single Axiom Tests** (3 tests):
   - Modal T pattern: `□φ → φ`
   - Modal 4 pattern: `□φ → □□φ`
   - Temporal A pattern: `Fφ → φ`

2. **Multi-Step Proofs** (3 tests):
   - Modus ponens: `[φ → ψ, φ] ⊢ ψ`
   - Modal K inference: `[□(φ → ψ), □φ] ⊢ □ψ`
   - Temporal K inference: `[F(φ → ψ), Fφ] ⊢ Fψ`

3. **Complex Nested Formulas** (2 tests):
   - Nested boxes: `□□φ → □φ` (requires M4)
   - Bimodal interaction: `□Fφ → F□φ` (requires MF axiom)

**Implementation Template**:

```lean
-- File: LogosTest/Automation/TacticsTest.lean (extend automation_phase2_suite)

/-! ## tm_auto Tests (Phase 2) -/

/-- Test: tm_auto proves □φ → φ automatically (modal T) -/
theorem test_tm_auto_modal_t (P : Formula) :
    Derivable [] ((Formula.box P).imp P) := by
  tm_auto
  -- Expected: Aesop finds modal_t_derivable and applies it

/-- Test: tm_auto proves □φ → □□φ automatically (modal 4) -/
theorem test_tm_auto_modal_4 (P : Formula) :
    Derivable [] ((Formula.box P).imp (Formula.box (Formula.box P))) := by
  tm_auto
  -- Expected: Aesop finds modal_4_derivable and applies it

/-- Test: tm_auto proves Fφ → φ automatically (temporal A) -/
theorem test_tm_auto_temporal_a (P : Formula) :
    Derivable [] ((Formula.future P).imp P) := by
  tm_auto
  -- Expected: Aesop finds temporal_a_derivable and applies it

/-- Test: tm_auto proves modus ponens with assumptions -/
theorem test_tm_auto_modus_ponens (P Q : Formula) :
    Derivable [P.imp Q, P] Q := by
  tm_auto
  -- Expected: Aesop finds both assumptions and applies modus_ponens_forward

/-- Test: tm_auto proves modal K with assumptions -/
theorem test_tm_auto_modal_k (P Q : Formula) :
    Derivable [Formula.box (P.imp Q), Formula.box P] (Formula.box Q) := by
  tm_auto
  -- Expected: Aesop finds assumptions and applies modal_k_forward

/-- Test: tm_auto proves temporal K with assumptions -/
theorem test_tm_auto_temporal_k (P Q : Formula) :
    Derivable [Formula.future (P.imp Q), Formula.future P] (Formula.future Q) := by
  tm_auto
  -- Expected: Aesop finds assumptions and applies temporal_k_forward

/-- Test: tm_auto on nested boxes (requires M4) -/
theorem test_tm_auto_nested_boxes (P : Formula) :
    Derivable [] ((Formula.box (Formula.box P)).imp (Formula.box P)) := by
  tm_auto
  -- Expected: Aesop uses M4 to derive □□φ, then applies transitivity

/-- Test: tm_auto on bimodal interaction (requires MF) -/
theorem test_tm_auto_bimodal (P : Formula) :
    Derivable [] ((Formula.box (Formula.future P)).imp (Formula.future (Formula.box P))) := by
  tm_auto
  -- Expected: Aesop finds modal_future_derivable and applies it

/-- Test: tm_auto fails gracefully on unprovable goal -/
-- This test should fail with Aesop error message
-- theorem test_tm_auto_fail_unprovable (P Q : Formula) :
--     Derivable [] (P.imp Q) := by
--   tm_auto
--   -- Expected: Error: "aesop: failed to prove goal"
--   -- No axiom or rule can derive arbitrary implication

def automation_phase2_suite : TestSuite := {
  name := "Automation Phase 2 Tests (tm_auto with Aesop)"
  tests := [
    test_tm_auto_modal_t,
    test_tm_auto_modal_4,
    test_tm_auto_temporal_a,
    test_tm_auto_modus_ponens,
    test_tm_auto_modal_k,
    test_tm_auto_temporal_k,
    test_tm_auto_nested_boxes,
    test_tm_auto_bimodal
    -- test_tm_auto_fail_unprovable  -- Expected to fail (commented out)
  ]
}
```

**Action Items**:
- [ ] Add 8 tm_auto tests to TacticsTest.lean
- [ ] Include single-axiom, multi-step, and complex tests
- [ ] Document expected Aesop behavior in comments
- [ ] Run tests: `lake test LogosTest.Automation.TacticsTest`
- [ ] Verify all 8 tests pass
- [ ] Measure test execution time (should be <5 seconds per test)

**Expected Output**: All 8 tm_auto tests pass successfully.

---

### Step 8: Verify Implementation and Run Full Test Suite (1-2 hours)

**Objective**: Confirm Aesop integration works correctly and all tests pass

**Verification Commands**:

```bash
# 1. Verify TMLogic rule set declared
lake build Logos.Automation.Tactics
# Expected: Build succeeds, Aesop recognizes TMLogic rule set

# 2. Verify axiom safe rules registered
grep -c "@\[aesop safe \[TMLogic\]\]" Logos/ProofSystem/Axioms.lean
# Expected: 8 (one per axiom)

# 3. Verify inference rule forward rules registered
grep -c "@\[aesop safe forward \[TMLogic\]\]" Logos/ProofSystem/Derivation.lean
# Expected: 4 (MP, MK, TK, TD)

# 4. Run full Phase 2 test suite
lake test LogosTest.Automation.TacticsTest::automation_phase2_suite
# Expected: 8 tests pass

# 5. Verify sorry count decreased
grep -c "sorry" Logos/Automation/Tactics.lean
# Expected: 9 (down from 10)
# 1 sorry removed: tm_auto (line 205)

# 6. Run lint checks
lake exe lean --run Logos/Automation/Tactics.lean 2>&1 | grep -i "warning"
# Expected: Zero warnings

# 7. Test Aesop tracing (debugging)
# Enable tracing in a test:
# set_option trace.aesop true in tm_auto
# Verify trace output shows rule applications
```

**Performance Benchmarks**:

```bash
# Benchmark tm_auto performance on complex formula
time lake test LogosTest.Automation.TacticsTest::test_tm_auto_nested_boxes
# Expected: <2 seconds (Aesop bounded search is fast)

# Benchmark tm_auto with increased depth
# Test with tm_auto_depth 100 on complex proof
# Expected: <5 seconds (may take longer for deep search)
```

**Action Items**:
- [ ] Run all verification commands
- [ ] Confirm 8 axiom rules + 4 forward rules registered
- [ ] Ensure all 8 Phase 2 tests pass
- [ ] Verify sorry count decreased by exactly 1
- [ ] Check zero lint warnings
- [ ] Measure tm_auto performance (all tests <5 seconds)
- [ ] Test Aesop tracing for debugging

**Expected Output**: All verification checks pass, 1 sorry removed, zero lint warnings, good performance.

---

### Step 9: Update Documentation with Aesop Patterns (1-2 hours)

**Objective**: Document Aesop integration patterns and tm_auto usage

**Files to Update**:

1. **TACTIC_DEVELOPMENT.md** (Update Section 4):
   - Add "✅ Implemented" badge to Section 4 heading
   - Verify safe rule examples match implementation
   - Add link to TacticsTest.lean for working examples
   - Document tm_auto variants (basic, depth, trace)

2. **Tactics.lean Module Docstring**:
   - Mark `tm_auto` as "✅ Implemented" in status section
   - Update completion percentage: Phase 1+2 complete (3/12 tactics = 25%)

3. **Create Aesop Integration Guide** (Optional):
   - Document rule attribution workflow
   - Explain safe vs unsafe vs forward rules
   - Provide examples of custom rule set creation

**Documentation Template for TACTIC_DEVELOPMENT.md Section 4**:

```markdown
## 4. Aesop Integration for TM Logic ✅ Implemented

This section documents Aesop integration patterns for Logos's TM logic automation.

### Implementation Status

- ✅ TMLogic rule set declared
- ✅ 8 TM axioms marked as safe rules
- ✅ 4 TM inference rules marked as safe forward rules
- ✅ `tm_auto` macro implemented with Aesop integration
- ✅ Comprehensive test suite (8 tests passing)

### Usage Examples

See `LogosTest/Automation/TacticsTest.lean::automation_phase2_suite` for working examples.

**Simple Axiom Application**:
```lean
theorem example_mt (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  tm_auto
```

**Multi-Step Proof with Modus Ponens**:
```lean
theorem example_mp (P Q : Formula) :
    Derivable [P.imp Q, P] Q := by
  tm_auto
```

**Modal K Inference**:
```lean
theorem example_mk (P Q : Formula) :
    Derivable [Formula.box (P.imp Q), Formula.box P] (Formula.box Q) := by
  tm_auto
```

### Configuration Options

- **Default**: `tm_auto` (search depth 30)
- **Deep Search**: `tm_auto_depth 100` (increased depth)
- **Debugging**: `tm_auto_trace` (enable Aesop tracing)

### Performance

- Simple proofs: <1 second
- Multi-step proofs: <2 seconds
- Complex nested formulas: <5 seconds
```

**Action Items**:
- [ ] Update TACTIC_DEVELOPMENT.md Section 4 with "✅ Implemented" badge
- [ ] Add working examples from TacticsTest.lean
- [ ] Document tm_auto configuration options
- [ ] Update Tactics.lean module docstring (Phase 2 complete)
- [ ] Update completion percentage in module docstring
- [ ] Commit documentation updates with implementation

**Expected Output**: All documentation accurately reflects Aesop integration with working examples.

---

## Error Handling Patterns

### Common Errors and Solutions

**Error 1: Aesop fails to prove goal**
```
tm_auto
→ Error: "aesop: failed to prove goal"
```
**Solution**:
- Check if goal matches any axiom patterns
- Try manual tactics (`apply_axiom`, `modal_t`)
- Increase search depth: `tm_auto_depth 100`
- Enable tracing to see attempted rules: `tm_auto_trace`

**Error 2: Rule not found in rule set**
```
tm_auto
→ Warning: "no applicable rules found"
```
**Solution**:
- Verify axiom safe rules registered: `grep "@\[aesop safe \[TMLogic\]\]" Axioms.lean`
- Verify TMLogic rule set declared: Check `declare_aesop_rule_sets [TMLogic]`
- Rebuild: `lake build Logos`

**Error 3: Search depth exceeded**
```
tm_auto
→ Error: "aesop: maximum rule applications reached"
```
**Solution**:
- Goal requires deep proof (>30 steps)
- Increase depth: `tm_auto_depth 100`
- Simplify goal or use manual tactics

**Error 4: Performance degradation**
```
tm_auto takes >10 seconds on simple proof
```
**Solution**:
- Deeply nested formula (>10 operators)
- Use `tm_auto_trace` to identify bottleneck
- Consider manual tactics for performance-critical proofs
- Optimize rule set (remove expensive forward rules)

---

## Testing Strategy

### Test Coverage Requirements

**Unit Tests**: ≥8 tests covering:
- Single axiom applications (MT, M4, TA)
- Multi-step proofs (MP, MK, TK)
- Complex nested formulas (□□φ, □Fφ)
- Performance benchmarks (<5 seconds per test)

**Integration Tests**: 2-3 tests combining Aesop with manual tactics:
- `tm_auto` followed by manual proof step
- Manual tactic followed by `tm_auto`

**Performance Tests**: 2-3 benchmarks:
- Simple proof (<1 second)
- Multi-step proof (<2 seconds)
- Complex nested formula (<5 seconds)

### Test Execution

```bash
# Run all Phase 2 tests
lake test LogosTest.Automation.TacticsTest::automation_phase2_suite

# Run specific test
lake test LogosTest.Automation.TacticsTest::test_tm_auto_modal_k

# Run with timing
time lake test LogosTest.Automation.TacticsTest

# Expected: All 8 tests pass in <30 seconds total
```

---

## Completion Checklist

Before marking this stage complete, verify ALL items:

### Implementation
- [ ] TMLogic Aesop rule set declared
- [ ] 8 TM axiom safe rules implemented in Axioms.lean
- [ ] 4 TM inference forward rules implemented in Derivation.lean
- [ ] `tm_auto` macro implemented with Aesop integration
- [ ] tm_auto variants implemented (depth, trace)
- [ ] Aesop search depth configured (default 30)
- [ ] All components compile without errors

### Testing
- [ ] TacticsTest.lean extended with Phase 2 suite (8 tests)
- [ ] All single-axiom tests pass (3 tests)
- [ ] All multi-step tests pass (3 tests)
- [ ] All complex formula tests pass (2 tests)
- [ ] Test suite runs successfully
- [ ] Performance benchmarks meet targets (<5 seconds per test)
- [ ] Aesop tracing verified (debugging capability)

### Quality
- [ ] Zero lint warnings in Tactics.lean, Axioms.lean, Derivation.lean
- [ ] 1 sorry removed (line 205 in Tactics.lean)
- [ ] Sorry count verification: `grep -c "sorry" Tactics.lean` returns 9
- [ ] Aesop rule count verification: 8 safe + 4 forward = 12 total
- [ ] Error messages are informative and actionable

### Documentation
- [ ] TACTIC_DEVELOPMENT.md Section 4 marked "✅ Implemented"
- [ ] Working examples added to documentation
- [ ] tm_auto configuration options documented
- [ ] Tactics.lean module docstring updated (Phase 2 complete)
- [ ] Performance characteristics documented
- [ ] References to test suite included

### Verification
- [ ] Build succeeds: `lake build Logos`
- [ ] Tests pass: `lake test LogosTest.Automation.TacticsTest`
- [ ] Lint clean: Zero warnings across all files
- [ ] Performance meets targets: All tests <5 seconds
- [ ] Aesop integration verified: Rule set recognized

**Total Checklist Items**: 30
**Required for Completion**: 30/30 (100%)

---

## Next Steps

After completing Stage 2:

**Immediate**: Proceed to Stage 3 (assumption_search and helper tactics)
**Alternative**: Pause and assess time constraints or deploy Phase 1+2 for user testing

**Stage 3 Preview**: Implement `assumption_search` tactic with TacticM iteration and helper tactics (`modal_k`, `temporal_k`, `mp_chain`) for 7-14 hours estimated.

---

## Estimated Time Breakdown

| Task | Estimated Hours | Notes |
|------|----------------|-------|
| Aesop documentation review | 0.5-0.75 | TACTIC_DEVELOPMENT.md Section 4 + quick reference |
| TMLogic rule set declaration | 1-2 | Declare custom rule set |
| Mark axioms as safe rules | 2-3 | 8 axiom derivability theorems |
| Mark inference rules as forward | 1-2 | 4 forward reasoning wrappers |
| Implement tm_auto macro | 2-3 | 3 macro variants (basic, depth, trace) |
| Configure Aesop heuristics | 1-2 | Tune search depth and options |
| Create test suite | 3-4 | 8 comprehensive tests |
| Verification and testing | 1-2 | Run all checks, measure performance |
| Documentation updates | 1-2 | Update 3 files with Aesop patterns |
| **Total** | **12-15 hours** | Revised from 15-20 with documentation |

**Confidence Level**: Medium-High (Aesop integration has learning curve)
**Risk Factors**: Medium (Aesop configuration may require tuning)
**Blocker Potential**: Low (Stage 1 dependency clear, independent of other tasks)
