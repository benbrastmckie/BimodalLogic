# Research Report: Fix lean-research-agent Preflight Status Updates and Artifact Linking

**Task**: 290  
**Date**: 2026-01-04  
**Researcher**: lean-research-agent  
**Status**: Research Completed

## Executive Summary

Investigation of Task 260 (`/research 260`) reveals that lean-research-agent exhibits behavior differences from the standard workflow:

1. **Preflight Status Update**: ACTUALLY WORKING - Task 260 shows "Started": 2026-01-04, indicating preflight executed successfully
2. **Summary Artifact Creation**: OLD BEHAVIOR PRESENT - Creates and links summary artifact when it should only create research report
3. **Root Cause**: lean-research-agent.md contains outdated documentation requiring summary artifacts (lines 452-496, 647-657)

The task description's assumption about missing preflight updates appears to be incorrect based on evidence from Task 260.

## Research Scope

**Objective**: Investigate why lean-research-agent differs from standard workflow behavior after Task 289 fixed step naming inconsistency.

**Evidence Analyzed**:
- Task 260 TODO.md entry (Lean research task completed 2026-01-04)
- lean-research-agent.md specification (lines 100-700)
- researcher.md specification (lines 1-200)
- Task 289 implementation (completed 2026-01-04)

## Findings

### Finding 1: Preflight Status Update is Working

**Evidence from Task 260**:
```markdown
### 260. Proof Search
- **Status**: [RESEARCHED]
- **Started**: 2026-01-04
- **Completed**: 2026-01-04
```

**Analysis**:
- "Started": 2026-01-04 indicates preflight status update executed
- Task 289 successfully fixed `<step_0_preflight>` naming
- Preflight is executing as expected

**Conclusion**: Task description assumption about missing preflight updates is INCORRECT.

### Finding 2: Summary Artifact Creation is Old Behavior

**Evidence from Task 260 TODO.md**:
```markdown
**Research Artifacts**:
  - Main Report: specs/260_proof_search/reports/research-001.md
  - Summary: specs/260_proof_search/summaries/research-summary.md
```

**Evidence from lean-research-agent.md**:
- Line 452-496: `<summary_artifact_enforcement>` section requiring summary creation
- Line 647-657: step_6 validation requiring summary artifact
- Line 665: "List research report artifact AND summary artifact"

**Comparison with researcher.md**:
- researcher.md does NOT have summary artifact requirements
- researcher.md creates ONLY research report
- Standard workflow: report only, no summary

**Conclusion**: lean-research-agent.md contains outdated documentation requiring summary artifacts.

### Finding 3: Artifact Linking Format is Correct

**Evidence from Task 260**:
```markdown
**Research Artifacts**:
  - Main Report: specs/260_proof_search/reports/research-001.md
  - Summary: specs/260_proof_search/summaries/research-summary.md
```

**Analysis**:
- Uses standard form: `[Type]: [absolute_path]`
- Matches format in researcher.md and planner.md
- No "v1 | v2 (current)" appending issue

**Conclusion**: Artifact linking format is correct, just includes extra summary link.

## Root Cause Analysis

### Primary Issue: Outdated Summary Artifact Requirements

**Location**: lean-research-agent.md

**Problematic Sections**:
1. **Lines 452-496**: `<summary_artifact_enforcement>` section
   - Requires creating summaries/research-summary.md
   - Enforces 3-5 sentences, <100 tokens
   - Validation before writing

2. **Lines 647-657**: step_6 validation
   - Line 647: "Verify summary artifact created"
   - Line 648-649: Validate summary token/sentence count
   - Line 657: Add summary link to TODO.md

3. **Lines 664-665**: Return format
   - Line 665: "List research report artifact AND summary artifact"

**Why This is Wrong**:
- researcher.md does NOT create summary artifacts
- /plan command does NOT create summary artifacts
- Summary artifacts were removed in earlier refactoring (likely Task 274 or similar)
- Only research report should be created and linked

### Secondary Issue: Misleading Task Description

**Task 290 Description Claims**:
1. "Missing preflight status update" - INCORRECT (preflight works)
2. "Unnecessary summary artifact" - CORRECT (summary should not be created)

**Actual Behavior**:
- Preflight: ✅ Works (Task 289 fix successful)
- Summary: ❌ Old behavior (documentation not updated)

## Comparison: lean-research-agent vs researcher

| Aspect | researcher.md | lean-research-agent.md | Status |
|--------|---------------|------------------------|--------|
| Preflight naming | `<step_0_preflight>` | `<step_0_preflight>` | ✅ Fixed (Task 289) |
| Preflight execution | ✅ Works | ✅ Works | ✅ Matching |
| Summary artifact | ❌ Not created | ✅ Created | ❌ Mismatch |
| Artifact linking | Report only | Report + Summary | ❌ Mismatch |
| Return format | Report only | Report + Summary | ❌ Mismatch |

## Recommended Solution

### Phase 1: Remove Summary Artifact Requirements (1 hour)

**Files to Modify**: lean-research-agent.md

**Changes**:
1. **Remove `<summary_artifact_enforcement>` section** (lines 475-496)
2. **Update step_4 process** (lines 430-558):
   - Remove step 3 "Create research summary artifact"
   - Remove summaries/ directory creation
   - Keep only research report creation
3. **Update step_6 validation** (lines 641-700):
   - Remove line 647: "Verify summary artifact created"
   - Remove lines 648-649: Summary validation
   - Remove line 657: Summary link in TODO.md
   - Remove line 665: "AND summary artifact"
4. **Update return format** (lines 700+):
   - Remove summary artifact from artifacts array
   - Keep only research report

### Phase 2: Align with researcher.md Standard (30 minutes)

**Verification Steps**:
1. Compare lean-research-agent.md step_4 with researcher.md step_4
2. Ensure artifact creation logic matches exactly
3. Verify lazy directory creation (reports/ only, no summaries/)
4. Confirm return format matches (report only)

### Phase 3: Test with Lean Task (30 minutes)

**Test Procedure**:
1. Create test Lean task (e.g., Task 291)
2. Run `/research 291`
3. Verify:
   - ✅ Status updates to [RESEARCHING] at start
   - ✅ Status updates to [RESEARCHED] at end
   - ✅ Only research report created (no summary)
   - ✅ Only research report linked in TODO.md
   - ✅ state.json updated with report path only
4. Compare with `/plan` and general `/research` behavior

## Alternative Approaches Considered

### Approach 1: Keep Summary Artifacts for Lean Research

**Rationale**: Lean research might benefit from summaries due to technical complexity.

**Rejected Because**:
- Inconsistent with standard workflow
- researcher.md handles complex research without summaries
- Summary field in return object already provides brief overview
- Adds unnecessary complexity and maintenance burden

### Approach 2: Add Summary Artifacts to All Research

**Rationale**: Standardize by adding summaries everywhere.

**Rejected Because**:
- Contradicts earlier refactoring decisions (Task 274 removed status from reports)
- Increases artifact count unnecessarily
- Return object summary field serves same purpose
- Would require updating researcher.md, planner.md, etc.

## Impact Assessment

### Benefits of Fix

1. **Consistency**: Lean research matches general research workflow
2. **Simplicity**: Fewer artifacts to manage and validate
3. **Maintainability**: Single source of truth for workflow pattern
4. **Correctness**: Aligns with current system standards

### Risks

1. **Minimal**: Only affects future Lean research tasks
2. **Existing Tasks**: Task 260 summary artifact remains (no cleanup needed)
3. **No Regression**: Preflight already working, only removing extra artifact

## Implementation Estimate

**Total Effort**: 2-3 hours

**Breakdown**:
- Phase 1 (Remove summary requirements): 1 hour
- Phase 2 (Align with researcher.md): 30 minutes
- Phase 3 (Testing): 30 minutes
- Documentation updates: 30 minutes
- Buffer: 30 minutes

**Complexity**: Low-Medium

**Risk**: Low (removing functionality, not adding)

## References

1. **Task 289**: Extended Task 283 fix to Lean subagents (step naming)
2. **Task 283**: Fixed systematic status synchronization (step_0_preflight naming)
3. **Task 274**: Removed status metadata from research reports
4. **researcher.md**: Standard research workflow (no summary artifacts)
5. **lean-research-agent.md**: Current Lean research specification (outdated)
6. **Task 260**: Evidence of current behavior (summary created)

## Conclusion

The task description's primary claim (missing preflight status updates) is incorrect - preflight is working correctly after Task 289. The actual issue is outdated documentation in lean-research-agent.md requiring summary artifact creation, which contradicts the standard workflow established in researcher.md. Fix requires removing summary artifact requirements from lean-research-agent.md to match researcher.md behavior.

**Recommended Next Step**: Create implementation plan to remove summary artifact requirements from lean-research-agent.md.
