# Implementation Plan: Optimize Self-Healing Context Bloat

**Project Number**: 199  
**Project Name**: optimize_self_healing_context_bloat  
**Type**: Optimization  
**Priority**: Medium  
**Complexity**: Low-Medium  
**Estimated Hours**: 4 hours  
**Phases**: 4

---

## Overview

Optimize the self-healing feature to reduce context overhead from 93 lines (in context-guide.md) to 20 lines, and reduce self-healing-guide.md from 438 lines to 120 lines. Move detailed implementation to a separate reference document that's only loaded when needed.

---

## Research Inputs

Research completed on 2025-12-27 identified the actual state of self-healing context:

**Key Findings**:
1. Commands do NOT load self-healing-guide.md (438 lines) - not as severe as originally thought
2. Actual bloat: 93 lines of self-healing content in context-guide.md (which IS loaded by commands)
3. self-healing-guide.md should be reduced to essential 120-line quick reference
4. Implementation details (300 lines) should move to separate reference file
5. Optimization target: 78% reduction in loaded context (93 → 20 lines)

**Files Analyzed**:
- self-healing-guide.md: 438 lines (comprehensive guide, not currently loaded)
- context-guide.md: 177 lines (includes 93 lines self-healing duplication, IS loaded)
- Commands: None load self-healing-guide.md (verified)

**Optimization Strategy**:
1. Reduce self-healing-guide.md: 438 → 120 lines (essential reference)
2. Consolidate context-guide.md: 177 → 104 lines (remove 73 lines duplication)
3. Create implementation-details.md: 300 lines (loaded only when debugging)
4. Move schema evolution to state-schema.md (belongs with schema docs)

**Impact**: 78% reduction in self-healing context overhead while maintaining full functionality.

---

## Phase 1: Reduce self-healing-guide.md to Essential Reference [NOT STARTED]

**Estimated Time**: 1.5 hours

**Objective**: Reduce self-healing-guide.md from 438 lines to 120-line quick reference.

**Tasks**:

1. **Extract essential content** (30 minutes)
   - Overview and file classification (30 lines)
   - Basic self-healing pattern (30 lines)
   - Command integration pattern (20 lines)
   - Error recovery (user-facing, 25 lines)
   - Best practices (10 lines)
   - References and links (5 lines)
   - **Total essential**: ~120 lines

2. **Create implementation-details.md** (45 minutes)
   - Move detailed pseudo-code (113 lines)
   - Move data extraction functions (94 lines)
   - Move testing scenarios (44 lines)
   - Move logging examples (36 lines)
   - Add clear navigation back to quick reference
   - **Location**: `.opencode/context/project/repo/self-healing-implementation-details.md`
   - **Total**: ~300 lines

3. **Update self-healing-guide.md** (15 minutes)
   - Replace with 120-line quick reference structure
   - Add link to implementation-details.md at bottom
   - Ensure all essential user-facing content preserved
   - Validate markdown formatting

**Acceptance Criteria**:
- self-healing-guide.md reduced to 120 lines
- implementation-details.md created with 300 lines
- Clear cross-references between quick reference and detailed docs
- All essential user-facing content preserved
- No functional changes, only reorganization

**Files Modified**:
- `.opencode/context/common/system/self-healing-guide.md` (438 → 120 lines)
- `.opencode/context/project/repo/self-healing-implementation-details.md` (new, 300 lines)

---

## Phase 2: Consolidate context-guide.md Self-Healing Content [NOT STARTED]

**Estimated Time**: 0.5 hours

**Objective**: Remove 73 lines of self-healing duplication from context-guide.md.

**Tasks**:

1. **Identify duplication** (10 minutes)
   - Lines 62-177 contain self-healing content (115 lines total)
   - ~93 lines duplicate self-healing-guide.md content
   - Auto-creation process, error handling, validation details

2. **Create concise summary** (15 minutes)
   - Replace 93 lines with 20-line summary
   - Key concept: "Self-healing auto-creates missing files"
   - Reference self-healing-guide.md for details
   - Keep only essential context organization info

3. **Update cross-references** (5 minutes)
   - Add reference to self-healing-guide.md
   - Update related documentation links
   - Ensure context organization narrative flows

**Acceptance Criteria**:
- context-guide.md reduced from 177 to 104 lines
- Self-healing content reduced from 93 to 20 lines
- Clear reference to self-healing-guide.md for details
- No loss of essential context organization information

**Files Modified**:
- `.opencode/context/common/system/context-guide.md` (177 → 104 lines, -73)

---

## Phase 3: Move Schema Evolution to state-schema.md [NOT STARTED]

**Estimated Time**: 0.5 hours

**Objective**: Move schema evolution content from self-healing-guide.md to state-schema.md where it belongs.

**Tasks**:

1. **Extract schema evolution section** (10 minutes)
   - Lines 419-430 in self-healing-guide.md (12 lines)
   - Content about updating state.json schema
   - Version bumping, backward compatibility

2. **Integrate into state-schema.md** (15 minutes)
   - Find appropriate location (likely end of file)
   - Add "Schema Evolution" section
   - Expand with schema-specific guidance
   - Update cross-references

3. **Update self-healing-guide.md** (5 minutes)
   - Remove schema evolution section (already moved to implementation-details.md)
   - Add reference to state-schema.md for schema evolution
   - Update related documentation links

**Acceptance Criteria**:
- Schema evolution moved to state-schema.md
- Integrated appropriately with existing schema docs
- self-healing-guide.md updated with reference
- No duplication between files

**Files Modified**:
- `.opencode/context/common/system/state-schema.md` (499 → ~510 lines, +11)
- `.opencode/context/common/system/self-healing-guide.md` (references updated)

---

## Phase 4: Testing and Validation [NOT STARTED]

**Estimated Time**: 1.5 hours

**Objective**: Verify context reduction and ensure no functional regression.

**Tasks**:

1. **Measure context reduction** (30 minutes)
   - Count lines in updated files
   - Verify self-healing-guide.md: 438 → 120 lines (-73%)
   - Verify context-guide.md: 177 → 104 lines (-41%)
   - Calculate loaded context reduction: 93 → 20 lines (-78%)
   - Document metrics in implementation summary

2. **Test self-healing functionality** (45 minutes)
   - **Test 1**: Remove state.json, verify auto-creation works
   - **Test 2**: Test with missing template, verify fallback
   - **Test 3**: Test normal operations (state.json present)
   - **Test 4**: Verify commands still work without regression
   - **Test 5**: Verify implementation-details.md is accessible

3. **Update documentation** (15 minutes)
   - Document optimization in implementation summary
   - Update cross-references if needed
   - Note metrics achieved
   - Document location of implementation-details.md

**Acceptance Criteria**:
- Context reduction verified: 78% reduction achieved
- Self-healing works on first run (state.json missing)
- Self-healing works after corruption
- Normal operations work without regression
- Commands load successfully without errors
- Documentation updated with metrics

**Testing Scenarios**:
```bash
# Test 1: Missing state.json
rm .opencode/specs/state.json
/research 199  # Should auto-create state.json

# Test 2: Normal operations
/research 199  # Should work normally (state.json exists)

# Test 3: Verify context files
cat .opencode/context/common/system/self-healing-guide.md | wc -l  # Should be ~120
cat .opencode/context/common/system/context-guide.md | wc -l       # Should be ~104
```

**Files Validated**:
- All modified files in Phases 1-3
- Commands that load context-guide.md
- Self-healing behavior in orchestrator

---

## Success Criteria

1. **Context Reduction**:
   - self-healing-guide.md: 438 → 120 lines (73% reduction) ✓
   - context-guide.md self-healing: 93 → 20 lines (78% reduction) ✓
   - Total loaded context: 93 → 20 lines (78% reduction) ✓

2. **Functional Preservation**:
   - Self-healing works on first run ✓
   - Self-healing works after corruption ✓
   - Normal operations work without regression ✓
   - Commands load successfully ✓

3. **Documentation Quality**:
   - Essential reference in self-healing-guide.md (120 lines) ✓
   - Detailed implementation in separate file (300 lines) ✓
   - Clear cross-references between files ✓
   - Schema evolution in appropriate location ✓

4. **Verification**:
   - All tests pass ✓
   - Metrics documented ✓
   - No functional regression ✓

---

## Risk Assessment

**Low Risks**:
- Documentation reorganization (low impact)
- Clear cross-references maintain discoverability
- Implementation details still available when needed

**Mitigation**:
- Thorough testing of self-healing functionality
- Verify all cross-references are correct
- Test with both missing and present state.json

**No High or Medium Risks Identified**

---

## Dependencies

**Internal**:
- Research completed (task 199)
- No code dependencies

**External**:
- None

---

## Rollback Plan

If issues discovered:

1. **Immediate**: Revert file changes via git
2. **Restore**: `git checkout HEAD -- .opencode/context/common/system/`
3. **Verify**: Test commands work with original files

---

## Related Tasks

- Task 199 Research: Identified context bloat issue
- No blocking or dependent tasks

---

## Notes

- This is purely documentation reorganization
- No functional changes to self-healing mechanism
- Focus is on reducing loaded context overhead
- Implementation details remain available for debugging
- Actual problem was less severe than described (93 lines vs 438 lines)
