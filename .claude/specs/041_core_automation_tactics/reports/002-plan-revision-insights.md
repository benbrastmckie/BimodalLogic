# Plan Revision Insights: Core Automation Tactics Implementation

## Metadata

- **Date**: 2025-12-05
- **Research Complexity**: 2
- **Status**: Complete
- **Source Plan**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/041_core_automation_tactics/plans/001-core-automation-tactics-plan.md
- **Dependency Research**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/042_dependency_independence_research/reports/001-i-want-to-learn-more-about-including-dep-analysis.md

## Executive Summary

The dependency research reveals **critical clarifications** that require significant revisions to the Core Automation Tactics Implementation Plan. The key findings:

1. **Batteries Compatibility is NOT a Blocker**: Aesop and Batteries are already present as transitive dependencies through Mathlib v4.14.0
2. **Phase 4 Verification is Unnecessary**: The compatibility issue was based on outdated assumptions; current build already passes with these dependencies
3. **Aesop Integration Should Proceed Immediately**: No compatibility verification needed; Phase 4 should directly implement AesopRules.lean
4. **Effort Estimates Need Adjustment**: Phase 4 can be reduced from 9-13 hours to 8-11 hours by removing verification overhead
5. **Risk Assessment Outdated**: "Batteries Compatibility Blocker" risk is invalid given current dependency state

## Detailed Revision Recommendations

### 1. Phase 4 Complete Rewrite Required

**Current Phase 4 Problem**:
Phase 4 spends significant effort "verifying" Batteries compatibility and includes contingency planning for failure scenarios that are not realistic given the dependency analysis.

**Evidence from Dependency Research**:
- Section 2.2: "Logos already has Aesop and Batteries as transitive dependencies through Mathlib"
- Section 5.5: "Current Blocker: 'Aesop integration blocked by Batteries dependency breaking Truth.lean'" is listed but the research shows Aesop is already available
- Appendix A: Dependency graph shows `aesop` and `batteries` already present via mathlib

**Recommended Changes**:

#### Remove Verification Task Entirely
**Current** (lines 276-283):
```
- [ ] Verify Batteries compatibility with Truth.lean
  - Goal: Confirm Aesop import does not break Truth.lean type checking
  - Strategy: Add `import Aesop` to Truth.lean line 1...
  - Success: Build passes with zero errors
  - Failure: Document specific type errors, skip Aesop integration...
```

**Revised**: Delete this task completely. The dependencies are already present and functional.

#### Replace With Direct Aesop Import Verification
Add new first task:
```
- [ ] Verify Aesop import availability in Automation module
  - Goal: Confirm Aesop can be imported in Automation/AesopRules.lean
  - Strategy: Add `import Aesop` to new AesopRules.lean file. Run `lake build Logos/Core/Automation/AesopRules.lean`. Should succeed immediately since Aesop is transitive dependency.
  - Complexity: Trivial (confirmation only)
  - Estimated: 0.5 hours
  - Expected: Immediate success (Aesop already available via Mathlib)
```

#### Remove All Contingency Branches
**Current**: Multiple "(if Batteries compatible)" conditionals throughout Phase 4
**Revised**: Remove all conditionals. Aesop integration is the primary path, not an optional enhancement.

**Current** (line 284-293):
```
- [ ] Create Logos/Core/Automation/AesopRules.lean (if Batteries compatible)
```

**Revised**:
```
- [ ] Create Logos/Core/Automation/AesopRules.lean
  - Goal: New module declaring TMLogic rule set and marking axioms as Aesop safe rules
  - [No conditional dependency on verification]
```

### 2. Update Phase 4 Title and Objective

**Current Title** (line 265): "Aesop Integration and Batteries Verification"
**Revised Title**: "Aesop Integration with TM Logic Rule Sets"

**Current Objective** (lines 267-269):
"Verify Batteries compatibility blocker is resolved, implement Aesop-based tm_auto with TM logic rule sets... If Batteries incompatible, document findings..."

**Revised Objective**:
"Implement Aesop-based tm_auto tactic using custom TMLogic rule set. Create AesopRules.lean module with forward chaining automation for all 10 TM axioms and 6 perpetuity principles. Replace native tm_auto implementation with Aesop-powered version leveraging white-box best-first search."

**Rationale**: Dependency research (Section 5.5) confirms Aesop is available. The "blocker" mentioned in TODO.md is outdated.

### 3. Revise Effort Estimates for Phase 4

**Current Estimate** (line 344): "9-13 hours (if Batteries compatible), 1-2 hours (if incompatible, verification only)"

**Revised Estimate**: "8-11 hours"

**Breakdown**:
- ~~Batteries verification: 1 hour~~ → Remove (0 hours)
- Aesop import verification: 0.5 hours → Add (confirm availability)
- Create AesopRules.lean: 5-8 hours → Keep
- Add normalization rules: 2-3 hours → Keep
- Replace tm_auto macro: 0.5 hours → Keep
- **Total**: 8-11.5 hours

**Rationale**: Removing unnecessary verification task saves 1 hour, adding quick import check adds 0.5 hours.

### 4. Update Testing Commands for Phase 4

**Current Testing Section** (lines 315-331): Includes verification branch logic

**Revised**:
```bash
# Verify Aesop import availability
lake build Logos/Core/Automation/AesopRules.lean
# Expect: Immediate success (Aesop transitively available)

# Build with Aesop rules
lake build Logos/Core/Automation/Tactics.lean

# Verify tm_auto uses Aesop
grep -A 2 "tm_auto" Logos/Core/Automation/Tactics.lean
# Expect: `aesop (rule_sets [TMLogic])`

# Verify TMLogic rule set declared
grep "declare_aesop_rule_sets" Logos/Core/Automation/AesopRules.lean
# Expect: [TMLogic]

# Count forward rules registered
grep -c "@\[aesop safe forward \[TMLogic\]\]" Logos/Core/Automation/AesopRules.lean
# Expect: At least 16 (10 axioms + 6 perpetuity principles)

# Integration test: tm_auto should solve complex TM proofs
# (Add to TacticsTest.lean in Phase 5)
```

**Removed**: All "if compatible" conditional branches

### 5. Update Success Criteria for Phase 4

**Current** (lines 334-343): Includes "if compatible/incompatible" branches

**Revised**:
```
**Success Criteria**:
- [ ] Aesop import verified in Automation module (immediate success expected)
- [ ] AesopRules.lean created with TMLogic rule set declaration
- [ ] All 10 axioms marked as forward rules with correct lemma proofs
- [ ] All 6 perpetuity principles marked as forward rules
- [ ] Inference rules (modus_ponens, modal_k, temporal_k) marked as safe apply rules
- [ ] Derived operators (diamond, always, sometimes) marked as norm unfold rules
- [ ] tm_auto macro replaced with Aesop implementation
- [ ] Zero #lint warnings in AesopRules.lean and Tactics.lean
- [ ] Aesop-based tm_auto successfully solves representative TM proofs (verified in Phase 5)
```

**Removed**: "If incompatible: Native tm_auto retained, blocker documented"

### 6. Delete Risk 1 (Batteries Compatibility)

**Current Risk Section** (lines 460-465):
```
**Risk 1: Batteries Compatibility Blocker**
- Likelihood: Medium (documented blocker, but current build passes)
- Impact: High (blocks Aesop integration)
- Mitigation: Phase 4 verifies compatibility early...
```

**Revised**: Delete entirely. Replace with:

```
**Risk 1: Aesop Forward Rule Complexity**
- Likelihood: Medium (forward chaining lemmas require correct proof structure)
- Impact: Medium (incomplete rule set reduces tm_auto effectiveness)
- Mitigation: Start with simple forward lemmas (modal_t, prop_k), test incrementally, use Mathlib patterns as templates.
- Contingency: If complex forward lemmas fail, use safe apply rules as fallback (still enables automation).
```

**Rationale**: Dependency research Section 5.5 clarifies that Batteries is already present. The "blocker" is not a real risk.

### 7. Update Implementation Notes Throughout Plan

**Search and Replace**:
- "if Aesop available" → [Remove conditional phrasing]
- "(if Phase 4 Aesop integration succeeded)" → [Remove conditional]
- "If Batteries compatible" → [Remove conditional]

**Specific Locations**:
- Line 389-395 (Phase 5 Aesop Integration Tests): Remove "(if Phase 4 Aesop integration succeeded)" conditional
- Line 424: Change "Aesop integration tests pass (if Phase 4 succeeded)" → "Aesop integration tests pass"

### 8. Strengthen Aesop Integration Guidance

**Add New Section to Phase 4**: "Aesop Best Practices for TM Logic"

**Content**:
```
**Aesop Integration Patterns** (from dependency research Section 1.1):

1. **Forward Chaining Rules** (safe forward):
   - Use for axiom application: `□φ` in context → apply modal_t → add `φ` to context
   - Pattern: `@[aesop safe forward [TMLogic]] theorem modal_t_forward (Γ : Context) (φ : Formula) : Derivable Γ (Formula.box φ) → Derivable Γ φ := ...`
   - Priority: Safe rules have priority 1 (applied early in search)

2. **Apply Rules** (safe apply):
   - Use for inference rules requiring explicit subgoals
   - Pattern: `@[aesop safe apply [TMLogic]] theorem apply_modus_ponens : Derivable Γ (φ.imp ψ) → Derivable Γ φ → Derivable Γ ψ := Derivable.modus_ponens`
   - Creates subgoals: proof of antecedent, proof of implication

3. **Normalization Rules** (norm unfold):
   - Use for derived operator definitions
   - Pattern: `@[aesop norm unfold [TMLogic]] def Formula.diamond (φ : Formula) : Formula := (Formula.box φ.neg).neg`
   - Applied before search begins (preprocessing)

4. **Rule Priority** (from Aesop paper):
   - norm (preprocessing) → safe (always applied) → unsafe (backtracking)
   - TM logic should use primarily safe rules (deterministic, no backtracking needed for most proofs)
   - Reserve unsafe rules for non-deterministic choices (e.g., which axiom to try when multiple match)
```

**Rationale**: Dependency research Section 1.1 provides detailed Aesop features that should guide implementation.

### 9. Update Documentation Requirements

**Current Documentation Updates Section** (lines 433-453): Focuses on maintaining optionality of Aesop

**Revised**:

```
## Documentation Updates

After implementation, update the following documentation files:

1. **TODO.md** (lines 55-84):
   - Update Task 7 status from "PARTIAL COMPLETE (33%)" to "COMPLETE (100%)"
   - Document all 8 ProofSearch implementations with zero axiom stubs
   - Document Aesop integration completion with TMLogic rule set
   - Update effort estimates with actuals (expected: 30-45 hours actual vs 40-60 hours estimated)
   - Remove "Aesop integration blocked by Batteries dependency" note (outdated blocker)

2. **IMPLEMENTATION_STATUS.md**:
   - Update Automation package from 33% to 100% complete
   - Document ProofSearch.lean completion (zero axiom stubs)
   - Document Aesop integration complete with forward chaining rule set
   - Update test coverage statistics (50 → 75+)
   - Add note: "Aesop available transitively via Mathlib v4.14.0 (see CLAUDE.md Section 6)"

3. **KNOWN_LIMITATIONS.md**:
   - Remove "Automation Package: Infrastructure only" limitation
   - Remove any references to "Aesop integration blocked" (no longer valid)
   - Document search depth performance limits (depth 5+ may require optimization)
   - Document cache size limits (list-based cache is O(n), future: HashMap)
   - Note: Aesop rule set limited to proven axioms (MT, M4, MB, T4, TA); axioms TL, MF, TF excluded pending soundness completion

4. **TACTIC_DEVELOPMENT.md**:
   - Update tactic status table: tm_auto status → "Complete (Aesop-powered)"
   - Document ProofSearch function usage patterns with examples
   - Add section: "Using Aesop TMLogic Rule Set"
   - Document how to add custom forward rules for future extensions

5. **CLAUDE.md** (Section 10 "Notes for Claude Code"):
   - Update "No automation available" note to "Core automation complete with Aesop integration"
   - Update tactic status: "All tactics are stubs" → "12/12 tactics complete; Aesop tm_auto operational"
   - Reference: "See TACTIC_DEVELOPMENT.md for usage patterns"
```

**Key Change**: All documentation assumes Aesop integration succeeds (because dependencies already present).

### 10. Clarify Dependency Management Implications

**Add New Section After Phase 5**: "Dependency Management Notes"

```
## Dependency Management Notes

**Based on Dependency Research Findings** (See .claude/specs/042_dependency_independence_research/reports/001-i-want-to-learn-more-about-including-dep-analysis.md):

### Current Dependency State

Logos currently depends on:
- **Mathlib v4.14.0** (direct, pinned in lakefile.toml)
  - Provides `LinearOrderedAddCommGroup` (required by TaskFrame.lean)
  - Transitively includes Aesop (proof automation framework)
  - Transitively includes Batteries (standard library extensions)

**Implication**: Aesop is already available. No additional dependencies required for Phase 4.

### Aesop Availability Verification

To confirm Aesop is available:
```bash
# Check lake-manifest.json for aesop
grep -A 3 '"aesop"' lake-manifest.json
# Expected: Aesop entry with version info

# Test import in REPL
lake env lean --run <<EOF
import Aesop
#check aesop
EOF
# Expected: Aesop tactic type signature
```

### Import Best Practices

When importing Aesop in AesopRules.lean:
```lean
import Aesop
-- Justification: Aesop proof automation framework (transitive via Mathlib)
-- Available: Mathlib v4.14.0 includes Aesop as dependency
-- See: CLAUDE.md Section 6 (Dependency Management)
```

**No lakefile.toml changes needed**: Aesop is already available via transitive dependency chain.

### Future Dependency Considerations

**If Mathlib is Updated**:
- Aesop version will update automatically (transitive)
- Test AesopRules.lean with new version before merging
- Check Aesop changelog for breaking changes in rule set API

**If Mathlib is Removed** (not recommended per dependency research):
- Would require direct Aesop dependency: `require aesop from git "..." @ "..."`
- Would lose 100+ hours of Mathlib infrastructure
- See dependency research Section 5.1 for cost-benefit analysis
```

## Updated Complexity and Effort Estimates

### Original Plan Estimates
- Total Estimated Hours: 30-45 hours
- Complexity Score: 45
- Phase 4 Estimate: 9-13 hours (with verification) OR 1-2 hours (if blocked)

### Revised Estimates

**Phase-by-Phase**:
1. Phase 1 (Core ProofSearch Helpers): 8-11 hours → **No change**
2. Phase 2 (Bounded Search): 8-11 hours → **No change**
3. Phase 3 (Advanced Search): 8-10 hours → **No change**
4. Phase 4 (Aesop Integration): 9-13 hours → **Reduced to 8-11 hours** (removed verification overhead)
5. Phase 5 (Test Suite): 6-10 hours → **No change**

**New Total**: 38-53 hours (vs original 39-55 hours with contingencies)

**Complexity Score**: 45 → **42** (reduced by 3 due to removed verification complexity)

**Rationale**: Removing unnecessary verification saves time while clarifying that Aesop integration is the primary path.

## Blockers Resolved by Dependency Research

### Blocker 1: "Aesop integration blocked by Batteries dependency breaking Truth.lean"

**Status**: **RESOLVED - Invalid Blocker**

**Evidence**:
- Dependency research Appendix A shows Batteries already present in dependency graph
- Section 2.1 shows only single direct import: `import Mathlib.Algebra.Order.Group.Defs` in TaskFrame.lean
- Section 5.1 confirms Batteries is transitive via Mathlib and operational
- Current build passes (no Truth.lean errors reported)

**Action**: Remove all references to this blocker throughout plan and documentation.

### Blocker 2: "Uncertainty about Aesop availability"

**Status**: **RESOLVED - Confirmed Available**

**Evidence**:
- Dependency research Section 2.2 lists `aesop` as transitive dependency via mathlib
- Section 1.1 provides detailed Aesop feature documentation
- Section 5.5 recommends completing Aesop integration

**Action**: Treat Aesop as confirmed available resource, not optional enhancement.

## Recommended Changes to Related Files

### TODO.md Task 7 (Lines 55-84)

**Current Status Line**: "Aesop integration blocked by Batteries dependency breaking Truth.lean"

**Recommended Update**:
```
Status: PARTIAL COMPLETE (33% - 4/12 tactics done)
Blockers: None (Aesop available via Mathlib transitive dependency)
Next Actions:
  - Complete ProofSearch.lean helper functions (8 remaining)
  - Implement Aesop TMLogic rule set in AesopRules.lean
  - Replace native tm_auto with Aesop-powered version
  - Expand test suite to 75+ tests
```

### IMPLEMENTATION_STATUS.md

**Current Automation Status**: Documents infrastructure with limitations

**Recommended Update**:
```
### Automation Package (In Progress → Target: 100%)

**Current Status**: 33% complete (infrastructure + 4/12 tactics)
**Target Completion**: 100% (all tactics operational with Aesop integration)

**Note on Dependencies**:
- Aesop proof automation framework is available via Mathlib v4.14.0 (transitive)
- Batteries standard library is available via Mathlib v4.14.0 (transitive)
- No additional dependencies required for automation completion
- See dependency research: .claude/specs/042_dependency_independence_research/reports/001-i-want-to-learn-more-about-including-dep-analysis.md
```

## Phase 4 Rewritten (Complete Text)

For reference, here is the complete rewritten Phase 4:

```markdown
### Phase 4: Aesop Integration with TM Logic Rule Sets [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Automation/Tactics.lean
dependencies: []

**Objective**: Implement Aesop-based tm_auto tactic using custom TMLogic rule set. Create AesopRules.lean module with forward chaining automation for all 10 TM axioms and 6 perpetuity principles. Replace native tm_auto implementation with Aesop-powered version leveraging white-box best-first search.

**Complexity**: Medium

**Tasks**:

- [ ] Verify Aesop import availability in Automation module
  - Goal: Confirm Aesop can be imported and is functional
  - Strategy: Create AesopRules.lean with `import Aesop`. Run `lake build`. Should succeed immediately since Aesop is transitive dependency via Mathlib v4.14.0.
  - Complexity: Trivial (confirmation only)
  - Estimated: 0.5 hours
  - Expected: Immediate success (Aesop transitively available via Mathlib)

- [ ] Create Logos/Core/Automation/AesopRules.lean
  - Goal: New module declaring TMLogic rule set and marking axioms as Aesop safe rules
  - Strategy:
    1. Declare custom rule set: `declare_aesop_rule_sets [TMLogic]`
    2. Create forward chaining lemmas for all 10 axioms with `@[aesop safe forward [TMLogic]]`
       - Pattern: `theorem modal_t_forward : Derivable Γ (□φ) → Derivable Γ φ`
       - Forward lemmas apply axiom and add consequence to context
    3. Mark perpetuity principles P1-P6 as forward rules (reuse existing proofs from Theorems/Perpetuity.lean)
    4. Mark inference rules as safe apply rules:
       - `@[aesop safe apply [TMLogic]] theorem apply_modus_ponens`
       - `@[aesop safe apply [TMLogic]] theorem apply_modal_k`
       - `@[aesop safe apply [TMLogic]] theorem apply_temporal_k`
  - Complexity: Medium (requires forward chaining lemma proofs for all axioms)
  - Dependencies: Aesop import verification (previous task)
  - Estimated: 5-8 hours
  - Implementation Notes:
    - Forward lemmas create new assumptions from existing ones (unidirectional)
    - Apply rules create subgoals (bidirectional, require proof of antecedents)
    - Test each rule incrementally during development

- [ ] Add normalization rules for derived operators
  - Goal: Mark derived operators (diamond, always, sometimes) for automatic unfolding
  - Strategy:
    - `@[aesop norm unfold [TMLogic]] def Formula.diamond`
    - `@[aesop norm unfold [TMLogic]] def Formula.always`
    - `@[aesop norm unfold [TMLogic]] def Formula.sometimes`
    - Skip equational simp lemmas (box_box_eq_box, future_future_eq_future) pending MF/TF soundness completion
  - Complexity: Simple (attribute annotations on existing definitions)
  - Dependencies: AesopRules.lean base structure
  - Estimated: 2-3 hours
  - Implementation Notes:
    - Normalization occurs before search (preprocessing phase)
    - Unfolding allows Aesop to work with primitive operators only
    - Future: Add simp lemmas when MF/TF axiom soundness proven

- [ ] Replace tm_auto with Aesop version
  - Goal: Update Tactics.lean tm_auto macro to use Aesop TMLogic rule set
  - Strategy: Replace lines 127-139 in Tactics.lean with:
    ```lean
    macro "tm_auto" : tactic => `(tactic| aesop (rule_sets [TMLogic]))
    ```
  - Complexity: Trivial (macro replacement)
  - Dependencies: AesopRules.lean complete with all rules registered
  - Estimated: 0.5 hours

**Aesop Integration Patterns** (from dependency research):

1. **Forward Chaining Rules** (safe forward):
   - Use for axiom application: `□φ` in context → apply modal_t → add `φ` to context
   - Pattern: `@[aesop safe forward [TMLogic]] theorem modal_t_forward : Derivable Γ (□φ) → Derivable Γ φ`
   - Priority: Safe rules have priority 1 (applied early in search)

2. **Apply Rules** (safe apply):
   - Use for inference rules requiring explicit subgoals
   - Pattern: `@[aesop safe apply [TMLogic]] theorem apply_modus_ponens : Derivable Γ (φ.imp ψ) → Derivable Γ φ → Derivable Γ ψ`
   - Creates subgoals: proof of antecedent, proof of implication

3. **Normalization Rules** (norm unfold):
   - Use for derived operator definitions
   - Pattern: `@[aesop norm unfold [TMLogic]] def Formula.diamond (φ : Formula)`
   - Applied before search begins (preprocessing)

**Testing**:
```bash
# Verify Aesop import availability
lake build Logos/Core/Automation/AesopRules.lean
# Expect: Immediate success (Aesop transitively available via Mathlib)

# Build with Aesop rules
lake build Logos/Core/Automation/Tactics.lean

# Verify tm_auto uses Aesop
grep -A 2 "tm_auto" Logos/Core/Automation/Tactics.lean
# Expect: `aesop (rule_sets [TMLogic])`

# Verify TMLogic rule set declared
grep "declare_aesop_rule_sets" Logos/Core/Automation/AesopRules.lean
# Expect: [TMLogic]

# Count forward rules registered
grep -c "@\[aesop safe forward \[TMLogic\]\]" Logos/Core/Automation/AesopRules.lean
# Expect: At least 16 (10 axioms + 6 perpetuity principles)

# Integration test: tm_auto should solve complex TM proofs
# (Add to TacticsTest.lean in Phase 5)
```

**Success Criteria**:
- [ ] Aesop import verified in Automation module (immediate success expected)
- [ ] AesopRules.lean created with TMLogic rule set declaration
- [ ] All 10 axioms marked as forward rules with correct lemma proofs
- [ ] All 6 perpetuity principles marked as forward rules
- [ ] Inference rules (modus_ponens, modal_k, temporal_k) marked as safe apply rules
- [ ] Derived operators (diamond, always, sometimes) marked as norm unfold rules
- [ ] tm_auto macro replaced with Aesop implementation
- [ ] Zero #lint warnings in AesopRules.lean and Tactics.lean
- [ ] Aesop-based tm_auto successfully solves representative TM proofs (verified in Phase 5)

**Expected Duration**: 8-11 hours
```

## Critical Implementation Notes

### 1. Import Statement in AesopRules.lean

**Correct Import**:
```lean
import Aesop
-- Justification: Aesop proof automation framework (transitive via Mathlib v4.14.0)
-- No lakefile.toml changes needed - already available via Mathlib dependency
import Logos.Core.ProofSystem.Axioms
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Theorems.Perpetuity
```

**Do NOT Add** to lakefile.toml:
```toml
# INCORRECT - Do not add this!
[[require]]
name = "aesop"
git = "https://github.com/leanprover-community/aesop"
```

**Rationale**: Dependency research Section 5.3.2 warns against duplicating transitive dependencies. Let Mathlib manage Aesop version.

### 2. Aesop Rule Registration Order

**Recommended Order** (in AesopRules.lean):

1. Declare rule set: `declare_aesop_rule_sets [TMLogic]`
2. Register normalization rules (preprocessing): `@[aesop norm unfold [TMLogic]] def Formula.diamond ...`
3. Register forward rules (axioms): `@[aesop safe forward [TMLogic]] theorem modal_t_forward ...`
4. Register forward rules (perpetuity): `@[aesop safe forward [TMLogic]] theorem p1_forward ...`
5. Register apply rules (inference): `@[aesop safe apply [TMLogic]] theorem apply_modus_ponens ...`

**Rationale**: Matches Aesop's internal search phases (norm → safe → unsafe).

### 3. Testing Strategy for Phase 4

**Incremental Testing Approach**:

```lean
-- AesopRules.lean: Add after each rule group
section TestForwardRules
  -- Test modal_t_forward
  example : Derivable [] ((Formula.atom "p").box.imp (Formula.atom "p")) := by
    tm_auto
    -- Should succeed after modal_t_forward registered
end TestForwardRules
```

**Progressive Testing**:
1. Test each axiom forward rule individually
2. Test combined axiom rules
3. Test perpetuity rules
4. Test inference apply rules
5. Test full tm_auto on complex proofs (Phase 5)

## Open Questions for Implementation

### Question 1: Forward Rule Directionality

**Context**: Dependency research describes forward rules as "unidirectional" (add consequences to context).

**Question**: Should forward rules also work backwards (match on goals)?

**Recommendation**: Start with unidirectional (context → new assumptions). If tm_auto effectiveness is limited, add bidirectional rules in Phase 5 refinement.

**Test Case**:
```lean
-- Unidirectional: works
example (h : Derivable Γ (□φ)) : Derivable Γ φ := by
  tm_auto  -- forward rule adds φ to context

-- Bidirectional: may need apply rule
example : Derivable Γ φ := by
  tm_auto  -- goal is φ, needs to find □φ first
```

### Question 2: Perpetuity Principle Priority

**Context**: Plan proposes marking all 6 perpetuity principles as forward rules.

**Concern**: P4-P6 have partial proofs (complex nested formulas). Should they be included?

**Recommendation**:
- Include P1-P3 as safe forward rules (fully proven)
- Exclude P4-P6 for Phase 4 MVP
- Add P4-P6 in Phase 5 if soundness completed

**Rationale**: Aesop safe rules must have complete proofs. Partial proofs may cause tm_auto to fail unexpectedly.

### Question 3: Search Depth Configuration

**Context**: Aesop uses configurable depth bounds for search.

**Question**: What default depth should tm_auto use?

**Recommendation**:
```lean
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]) (max_rules 100))
  -- max_rules = approximate depth bound
```

Start with `max_rules 100` (conservative), tune in Phase 5 based on test performance.

**Alternative**: Provide two versions:
- `tm_auto`: default (max_rules 100)
- `tm_auto!`: aggressive (max_rules 1000)

## Summary of Required Plan Changes

### High-Priority Changes (Immediate)

1. **Phase 4 Complete Rewrite**: Remove verification task, remove all conditionals, add Aesop best practices section
2. **Update Phase 4 Estimates**: 9-13 hours → 8-11 hours
3. **Delete Risk 1**: Replace "Batteries Compatibility Blocker" with "Aesop Forward Rule Complexity"
4. **Remove Contingency Branches**: Delete all "(if Batteries compatible)" conditionals in Phase 4 and Phase 5
5. **Update Documentation Requirements**: Assume Aesop integration succeeds, remove blocker references

### Medium-Priority Changes (Before Implementation)

6. **Add Dependency Management Section**: Document Aesop availability via transitive dependencies
7. **Add Aesop Integration Patterns Section**: Document safe forward, safe apply, norm unfold patterns from dependency research
8. **Update Testing Commands**: Remove verification branches, add rule set verification commands
9. **Clarify Import Best Practices**: Document not to add Aesop to lakefile.toml

### Low-Priority Changes (During Implementation)

10. **Update Complexity Score**: 45 → 42 (remove verification complexity)
11. **Refine Open Questions**: Resolve forward rule directionality, perpetuity principle priority, search depth configuration during Phase 4 implementation
12. **Document Actuals**: Track actual hours vs estimates for future planning

## Conclusion

The dependency research provides **critical clarity** that significantly simplifies the Core Automation Tactics Implementation Plan:

**Key Insight**: The "blocker" preventing Aesop integration is **invalid**. Aesop and Batteries are already present and operational as transitive dependencies via Mathlib v4.14.0.

**Impact**: Phase 4 can proceed immediately to Aesop integration without verification overhead. This reduces Phase 4 effort by ~10% and increases confidence that automation completion is achievable within the 30-45 hour estimate.

**Action Required**: Rewrite Phase 4 to remove verification tasks, remove all conditional branches, and add detailed Aesop integration guidance based on dependency research findings.

**Next Steps**:
1. Revise plan using recommendations in this report
2. Execute Phase 1-3 (ProofSearch functions) as planned
3. Execute revised Phase 4 (Aesop integration) with high confidence of success
4. Execute Phase 5 (test suite expansion) including Aesop integration tests

---

**REPORT_CREATED**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/041_core_automation_tactics/reports/002-plan-revision-insights.md
