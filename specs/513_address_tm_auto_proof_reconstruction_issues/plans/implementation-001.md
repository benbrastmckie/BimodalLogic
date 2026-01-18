# Implementation Plan: Task #513

- **Task**: 513 - Address tm_auto proof reconstruction issues
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/513_address_tm_auto_proof_reconstruction_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the `tm_auto` tactic macro with a native implementation using the proven `modal_search` infrastructure. The current `tm_auto` implementation delegates to Aesop, which has fundamental proof reconstruction incompatibilities with the custom `DerivationTree` type used throughout the TM logic system. This causes internal errors during proof reconstruction ("goal was not normalised"). The solution is straightforward: redirect `tm_auto` to use `modal_search` which already works correctly with `DerivationTree`.

### Research Integration

Key findings from research-001.md:
- Root cause: Aesop's proof reconstruction expects standard Lean `Expr` types, but `DerivationTree` doesn't follow standard normalization patterns
- `modal_search` already provides reliable proof search without reconstruction issues
- Recommendation: Option 2 (Replace with Native Implementation) - simple, reliable, maintains API compatibility

## Goals & Non-Goals

**Goals**:
- Replace `tm_auto` macro implementation to eliminate proof reconstruction errors
- Maintain backward compatibility with existing `tm_auto` usage
- Add optional configuration parameters to `tm_auto` (depth, strategy)
- Update documentation to reflect the implementation change
- Ensure all existing tests pass with the new implementation

**Non-Goals**:
- Fixing the underlying Aesop integration (high effort, low value)
- Removing AesopRules.lean (may still be useful for other purposes)
- Changing the `modal_search` implementation
- Adding new tactic functionality beyond what `modal_search` already provides

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Different search behavior | M | L | modal_search already proven reliable; run comprehensive tests |
| Performance regression | L | L | modal_search is already optimized; benchmark if needed |
| Tests fail due to behavior difference | M | L | Tests already use explicit axiom applications; most should pass |
| Breaking change for edge cases | L | L | Keep documentation clear about the change |

## Implementation Phases

### Phase 1: Replace tm_auto Macro [NOT STARTED]

**Goal**: Replace the `tm_auto` macro definition to use `modal_search` instead of Aesop

**Tasks**:
- [ ] Modify `tm_auto` macro in `Theories/Bimodal/Automation/Tactics.lean`
- [ ] Change from `macro "tm_auto" : tactic => \`(tactic| aesop)` to delegation to `modal_search`
- [ ] Add optional depth parameter support to `tm_auto`
- [ ] Add optional strategy parameter support to `tm_auto`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics.lean` - Replace macro definition at line 135-136

**Verification**:
- `lake build Theories.Bimodal.Automation.Tactics` compiles without errors
- Basic `tm_auto` usage still works

---

### Phase 2: Update Documentation [NOT STARTED]

**Goal**: Update all documentation to reflect the implementation change and clarify tactic selection

**Tasks**:
- [ ] Update docstring for `tm_auto` in `Tactics.lean`
- [ ] Update module documentation in `Automation.lean`
- [ ] Update "Tactic Selection Guide" section to clarify when to use each tactic
- [ ] Remove or update warnings about Aesop proof reconstruction issues
- [ ] Add note about `tm_auto` now being an alias for `modal_search`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Automation/Tactics.lean` - Update docstrings (lines 112-136)
- `Theories/Bimodal/Automation.lean` - Update module documentation

**Verification**:
- Documentation is accurate and consistent
- No mentions of Aesop issues in `tm_auto` context

---

### Phase 3: Run Test Suite [NOT STARTED]

**Goal**: Verify all existing tests pass with the new implementation

**Tasks**:
- [ ] Run `lake build Tests.BimodalTest.Automation.TacticsTest`
- [ ] Run `lake build Tests.BimodalTest.Integration.AutomationProofSystemTest`
- [ ] Identify and fix any failing tests
- [ ] Verify tests that explicitly use `tm_auto` still pass

**Timing**: 1.5 hours

**Files to modify**:
- `Tests/BimodalTest/Automation/TacticsTest.lean` - Fix any failing tests if needed
- `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean` - Fix any failing tests if needed

**Verification**:
- All 150 tests in TacticsTest.lean pass
- All integration tests pass
- No new compilation errors

---

### Phase 4: Update Test Documentation [NOT STARTED]

**Goal**: Update test comments and documentation to reflect the change

**Tasks**:
- [ ] Update test file headers in TacticsTest.lean
- [ ] Update comments for tm_auto tests (Tests 13-18, 32-35)
- [ ] Clarify that tm_auto now uses modal_search internally
- [ ] Remove references to "Aesop integration" in test comments where applicable

**Timing**: 0.5 hours

**Files to modify**:
- `Tests/BimodalTest/Automation/TacticsTest.lean` - Update comments

**Verification**:
- Test documentation accurately describes current behavior

---

### Phase 5: Final Verification and Cleanup [NOT STARTED]

**Goal**: Complete final verification and perform any necessary cleanup

**Tasks**:
- [ ] Run full `lake build` to ensure project compiles
- [ ] Run `lake build Tests` to verify all tests pass
- [ ] Review AesopRules.lean to determine if deprecation notice is needed
- [ ] Add deprecation comment to AesopRules.lean if tm_auto no longer uses it
- [ ] Verify no sorries or admits were introduced

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Automation/AesopRules.lean` - Add deprecation notice if appropriate

**Verification**:
- `lake build` succeeds
- `lake build Tests` succeeds
- No new sorries introduced
- Codebase is clean and consistent

## Testing & Validation

- [ ] All 150 tests in TacticsTest.lean pass
- [ ] Integration tests in AutomationProofSystemTest.lean pass
- [ ] `lake build` completes without errors
- [ ] `lake build Tests` completes without errors
- [ ] Manual verification: `tm_auto` solves modal_t axiom goal
- [ ] Manual verification: `tm_auto` solves modus ponens goal
- [ ] No regression in proof search capabilities

## Artifacts & Outputs

- `Theories/Bimodal/Automation/Tactics.lean` - Modified with new `tm_auto` implementation
- `Theories/Bimodal/Automation.lean` - Updated documentation
- `Tests/BimodalTest/Automation/TacticsTest.lean` - Updated test documentation
- `Theories/Bimodal/Automation/AesopRules.lean` - Deprecation notice (if applicable)
- `specs/513_address_tm_auto_proof_reconstruction_issues/summaries/implementation-summary-YYYYMMDD.md` - Final summary

## Rollback/Contingency

If the implementation causes unexpected issues:
1. Revert `tm_auto` macro to original Aesop delegation
2. Document the specific failure case
3. Consider Option 3 from research (custom tactic implementation)

Rollback command:
```bash
git checkout HEAD~1 -- Theories/Bimodal/Automation/Tactics.lean
```
