# TM_Auto Proof Reconstruction Issues Research

**Task**: 513  
**Research Date**: 2026-01-16  
**Researcher**: Claude AI  

## Executive Summary

The `tm_auto` tactic in the Bimodal TM logic system has fundamental proof reconstruction issues when used with Aesop. The root cause is incompatibility between Aesop's proof reconstruction mechanism and the custom `DerivationTree` type used throughout the TM logic system. This research identifies the specific technical issues and provides concrete solutions.

## Problem Analysis

### 1. Current Implementation

`tm_auto` is defined as a simple macro that delegates to Aesop:

```lean
macro "tm_auto" : tactic =>
  `(tactic| aesop)
```

This macro uses the `TMLogic` rule set defined in `AesopRules.lean` which includes:
- Forward chaining rules for 7 axioms (modal_t, modal_4, modal_b, temp_4, temp_a, prop_k, prop_s)
- Safe apply rules for core inference (modus_ponens, modal_k, temporal_k)
- Normalization rules for derived operators

### 2. Root Cause: Aesop + DerivationTree Incompatibility

The fundamental issue is that Aesop's proof reconstruction expects standard Lean proof terms, but our TM logic system uses a custom `DerivationTree` inductive type:

```
error: aesop: internal error during proof reconstruction: goal 501 was not normalised
```

**Why this happens**:
1. **Type Mismatch**: Aesop builds proof trees using standard Lean `Expr` types
2. **Normalization Failure**: Aesop tries to normalize goals but `DerivationTree` doesn't follow standard normalization patterns
3. **Reconstruction Gap**: When Aesop finds a proof path, it cannot reconstruct the proof in `DerivationTree` form

### 3. Technical Details

#### Aesop Rule Configuration Issues
- `@[aesop safe apply]` attributes on functions returning `DerivationTree`
- `@[aesop safe forward]` attributes on functions expecting `DerivationTree` inputs
- Forward chaining rules create `DerivationTree` but Aesop expects `Expr`

#### Goal Normalization Problems
- Aesop normalizes goals using `whnf` (weak head normalization)
- `DerivationTree Γ φ` doesn't normalize to standard `Expr` forms
- Aesop's internal goal numbering (e.g., "goal 501") gets desynchronized

#### Proof Reconstruction Pipeline Failure
1. Aesop searches and finds proof path (successful)
2. Aesop attempts to reconstruct proof term (fails)
3. Error: "goal X was not normalised"
4. Tactic fails despite having found a valid proof strategy

## Current Workarounds

### Existing Solutions
The system already provides reliable alternatives:

1. **`modal_search`**: Native proof search without Aesop
   - Uses `BoundedDFS`, `IDDFS`, and `BestFirst` strategies
   - Works directly with `DerivationTree` type
   - No proof reconstruction issues

2. **`temporal_search`**: Optimized for temporal formulas
3. **`propositional_search`**: For purely propositional goals

### Documentation Recommendations
Current code already recommends alternatives:
```lean
-- In Tactics.lean:
**Recommendation**: Use `modal_search` instead of `tm_auto`/`aesop` for derivability goals.

-- In Automation.lean:
- `tm_auto`: Legacy Aesop wrapper, has proof reconstruction issues
```

## Solution Options

### Option 1: Fix Aesop Integration (High Effort)

**Approach**: Implement proper Aesop integration with `DerivationTree`

**Steps**:
1. Create custom `Aesop.Tree` conversion functions:
   ```lean
   def derivationTreeToAesopTree : DerivationTree Γ φ → Aesop.Tree 
   def aesopTreeToDerivationTree : Aesop.Tree → DerivationTree Γ φ
   ```

2. Implement custom normalization for `DerivationTree` goals
3. Create Aesop rule set that works with `Expr` but converts to/from `DerivationTree`
4. Handle Aesop's proof reconstruction pipeline

**Pros**:
- Keeps `tm_auto` as familiar interface
- Leverages Aesop's sophisticated search algorithms
- Maintains single tactic interface

**Cons**:
- Very complex implementation
- Requires deep Aesop internals knowledge
- High maintenance burden
- May still have edge cases

### Option 2: Replace tm_auto with Native Implementation (Recommended)

**Approach**: Replace `tm_auto` macro with native implementation using existing `ProofSearch` functions

**Implementation**:
```lean
macro "tm_auto" : tactic => 
  `(tactic| modal_search (max_depth := 100) (strategy := .bestFirst))
```

**Pros**:
- Simple, reliable implementation
- Uses proven `modal_search` infrastructure
- No proof reconstruction issues
- Maintains existing API
- Low maintenance

**Cons**:
- Loses Aesop's specific heuristics
- May have different performance characteristics

### Option 3: Implement Custom Tactic (Medium Effort)

**Approach**: Create specialized tactic that mimics Aesop's search but works with `DerivationTree`

**Key Components**:
1. Rule prioritization system
2. Forward chaining implementation
3. Safe apply with subgoal management
4. Best-first search with custom heuristics

**Implementation Sketch**:
```lean
elab "tm_auto_v2" : tactic => do
  let goal ← getMainGoal
  let goalType ← goal.getType
  -- Custom search implementation
  performTmAutoSearch goal goalType
```

## Recommendation

**Primary Recommendation**: Implement Option 2 (Replace with Native Implementation)

**Rationale**:
1. **Immediate Fix**: Resolves all proof reconstruction issues
2. **Low Risk**: Uses proven `modal_search` infrastructure  
3. **API Compatibility**: Maintains `tm_auto` interface
4. **Performance**: Already optimized for `DerivationTree`

**Implementation Priority**:
1. **Phase 1**: Replace `tm_auto` macro with `modal_search` call
2. **Phase 2**: Add configuration options (depth, strategy)
3. **Phase 3**: Update documentation and tests
4. **Phase 4**: Deprecate AesopRules.lean (if unused)

**Fallback**: If Option 2 proves insufficient, implement Option 3 as custom tactic.

## Implementation Plan

### Phase 1: Quick Fix (1 hour)
- Replace `tm_auto` macro definition in `Tactics.lean`
- Update documentation to reflect implementation change
- Test existing `tm_auto` usage

### Phase 2: Enhanced Configuration (2 hours)  
- Add optional parameters to `tm_auto`
- Map to `modal_search` configuration
- Update tactic documentation

### Phase 3: Validation (2 hours)
- Run comprehensive test suite
- Verify all existing `tm_auto` tests pass
- Performance comparison with old implementation

### Phase 4: Cleanup (Optional)
- Remove AesopRules.lean if no longer used
- Update imports and dependencies
- Clean up any remaining Aesop-specific code

## Risk Assessment

**Low Risk**: Options 2 and 3 have minimal risk
**Medium Risk**: Option 1 may introduce new bugs
**High Risk**: Doing nothing leaves broken functionality

## Testing Strategy

1. **Regression Testing**: Ensure all existing `tm_auto` tests pass
2. **Performance Testing**: Compare execution time and memory usage
3. **Edge Case Testing**: Test complex formulas that previously failed
4. **Integration Testing**: Verify compatibility with existing proof workflow

## Files to Modify

1. `Theories/Bimodal/Automation/Tactics.lean` - Replace macro definition
2. `Theories/Bimodal/Automation.lean` - Update documentation
3. `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean` - Verify tests
4. `Tests/BimodalTest/Automation/TacticsTest.lean` - Update test documentation

## Conclusion

The `tm_auto` proof reconstruction issues stem from fundamental incompatibility between Aesop's proof reconstruction pipeline and the custom `DerivationTree` type. The recommended solution is to replace the current `tm_auto` implementation with a native one using the proven `modal_search` infrastructure. This provides an immediate, reliable fix while maintaining API compatibility.