# Research Report: Remove Performance Cruft from 6 Modified Files

**Task**: 305 - Remove optimization sections from frontmatter, performance blocks from workflow stages, and verbose comments from all 6 files (todo.md, review.md, reviewer.md, meta.md, task-creator.md, state-lookup.md). Keep state-lookup.md documentation changes.

**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 2 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**: .opencode/specs/changes-review-and-fixes-required.md  
**Artifacts**: research-001.md  
**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes the unintended changes made to 6 files during a previous optimization effort and identifies what performance cruft needs to be removed. The review document (changes-review-and-fixes-required.md) provides a comprehensive analysis of all issues. The key findings are:

- **6 files affected**: todo.md, review.md, reviewer.md, meta.md, task-creator.md, state-lookup.md
- **3 types of cruft to remove**: optimization sections in frontmatter, performance blocks in workflow stages, verbose comments
- **1 file to preserve**: state-lookup.md documentation changes should be kept (valuable documentation)
- **2 files with high-risk changes**: meta.md and task-creator.md have core logic changes that need verification

**Recommended Action**: Remove all performance cruft from frontmatter, workflow stages, and comments. Keep state-lookup.md documentation. Verify core logic changes in meta.md and task-creator.md separately (task 307).

---

## Context & Scope

### Background

During a previous optimization effort (Phase 2), performance-related metadata was added to 6 files:
1. `.opencode/command/todo.md` - TODO maintenance command
2. `.opencode/command/review.md` - Codebase review command  
3. `.opencode/agent/subagents/reviewer.md` - Review subagent
4. `.opencode/agent/subagents/meta.md` - Meta system builder
5. `.opencode/agent/subagents/task-creator.md` - Task creation subagent
6. `.opencode/context/core/system/state-lookup.md` - State lookup documentation

The review document identifies these changes as "performance cruft" that should be removed because:
- Frontmatter should be minimal metadata, not performance documentation
- Performance notes don't belong in workflow execution stages
- Verbose comments clutter the code
- Performance metrics become stale and misleading

### Research Objectives

1. Identify all performance cruft in each of the 6 files
2. Document exact line numbers and content to remove
3. Clarify what should be kept in state-lookup.md
4. Identify any core logic changes that need separate verification
5. Create clear action items for implementation

---

## Key Findings

### Finding 1: Performance Cruft in Frontmatter (5 files)

**Files Affected**: todo.md, review.md, reviewer.md, meta.md, task-creator.md

**Issue**: All 5 files have an `optimization:` section in their YAML frontmatter that documents Phase 2 performance improvements.

**Example from todo.md (lines 19-22)**:
```yaml
optimization:
  phase: 2
  performance: "13x faster task scanning (200ms → 15ms)"
  approach: "Query state.json with jq instead of parsing TODO.md"
```

**Why Remove**:
- Frontmatter should contain only essential metadata for command/agent execution
- Performance documentation belongs in separate documentation files
- Adds unnecessary parsing overhead
- Not used by any system component
- Becomes stale if performance changes

**Action**: Remove entire `optimization:` section from all 5 files

---

### Finding 2: Performance Blocks in Workflow Stages (1 file)

**File Affected**: todo.md

**Issue**: Stage 1 (ScanState) contains a `<performance>` block documenting timing comparisons.

**Location**: Lines 71-78 in todo.md

**Content**:
```xml
<performance>
  Total time: ~15ms (13x faster than TODO.md scanning)
  
  Comparison:
    - Old approach (TODO.md parsing): ~200ms
    - New approach (state.json query): ~15ms
    - Improvement: 13x faster
</performance>
```

**Why Remove**:
- Performance notes don't belong in workflow execution stages
- This is documentation, not executable logic
- Clutters the workflow definition
- Becomes stale/misleading if performance changes

**Action**: Remove entire `<performance>` block from todo.md Stage 1

---

### Finding 3: Verbose Comments (4 files)

**Files Affected**: todo.md, review.md, reviewer.md, meta.md

**Issue**: Comments contain verbose implementation details like "(Phase 2 optimization)" that are not essential for understanding.

**Examples**:

**todo.md line 13**:
```yaml
- "core/system/state-lookup.md"      # For fast state.json queries (Phase 2 optimization)
```
Should be:
```yaml
- "core/system/state-lookup.md"  # Fast state.json queries
```

**todo.md line 16**:
```yaml
- ".opencode/specs/state.json"       # State tracking (primary source for task scanning)
```
Should be:
```yaml
- ".opencode/specs/state.json"  # State tracking
```

**review.md line 18**:
```yaml
- "core/system/state-lookup.md"  # For fast state.json queries (Phase 2 optimization)
```
Should be:
```yaml
- "core/system/state-lookup.md"  # Fast state.json queries
```

**review.md line 22**:
```yaml
- ".opencode/specs/state.json"  # Primary source for next_project_number and task queries
```
Should be:
```yaml
- ".opencode/specs/state.json"  # State tracking
```

**Why Remove**:
- Comments should be concise and essential
- Implementation details like "Phase 2 optimization" are not useful for understanding
- Other files don't have this level of detail in comments
- Creates inconsistency across files

**Action**: Simplify all verbose comments to be concise and essential

---

### Finding 4: State-lookup.md Documentation Changes (KEEP)

**File**: .opencode/context/core/system/state-lookup.md

**Changes Made**:
- Added 6 new patterns for Phase 2 optimizations (Pattern 5-10)
- Added performance improvement tables
- Updated version from 1.0 to 1.1
- All additive changes (no deletions)

**Assessment**: [PASS] - KEEP ALL CHANGES

**Reasoning**:
- This is pure documentation, not code
- Provides valuable reference for state.json query patterns
- No performance cruft (this IS the performance documentation)
- Well-structured and useful
- No issues identified in review

**Action**: NO CHANGES to state-lookup.md - keep all documentation

---

### Finding 5: High-Risk Core Logic Changes (2 files)

**Files Affected**: meta.md, task-creator.md

**Issue**: Both files have significant changes to their core task creation logic, not just performance cruft.

**meta.md Changes**:
- Lines 515-551: Completely rewrote Stage 7 task creation logic
- Changed from direct file manipulation to delegation to status-sync-manager
- Added plan artifact linking step
- May break if status-sync-manager.create_task() doesn't exist

**task-creator.md Changes**:
- Lines 260-318: Completely rewrote Step 3 task creation logic
- Changed from manual atomic updates to delegation to status-sync-manager
- Contradicts original design decision (NOTE explicitly said NOT to use status-sync-manager)
- May break if status-sync-manager.create_task() doesn't exist

**Assessment**: [WARN] - REQUIRES SEPARATE VERIFICATION

**Reasoning**:
- These are breaking changes to core functionality
- Need to verify status-sync-manager.create_task() exists
- Need to test /meta and /task commands still work
- Should be handled in task 307 (verify or revert core logic changes)

**Action for Task 305**: Remove only the performance cruft from these files, NOT the core logic changes. Core logic verification is task 307.

---

## Detailed Analysis

### File 1: .opencode/command/todo.md

**Risk Level**: Medium  
**Changes Made**: Stage 1 renamed, added state.json queries, added performance notes

#### Cruft to Remove

**Issue 1: Performance Cruft in Frontmatter (lines 19-22)**
```yaml
optimization:
  phase: 2
  performance: "13x faster task scanning (200ms → 15ms)"
  approach: "Query state.json with jq instead of parsing TODO.md"
```
**Action**: Remove lines 19-22 entirely

**Issue 2: Performance Cruft in Stage 1 (lines 71-78)**
```xml
<performance>
  Total time: ~15ms (13x faster than TODO.md scanning)
  
  Comparison:
    - Old approach (TODO.md parsing): ~200ms
    - New approach (state.json query): ~15ms
    - Improvement: 13x faster
</performance>
```
**Action**: Remove lines 71-78 entirely

**Issue 3: Verbose Comment (line 13)**
```yaml
- "core/system/state-lookup.md"      # For fast state.json queries (Phase 2 optimization)
```
**Action**: Simplify to:
```yaml
- "core/system/state-lookup.md"  # Fast state.json queries
```

**Issue 4: Verbose Comment (line 16)**
```yaml
- ".opencode/specs/state.json"       # State tracking (primary source for task scanning)
```
**Action**: Simplify to:
```yaml
- ".opencode/specs/state.json"  # State tracking
```

#### Changes to Keep

**Stage 1 Optimization (lines 54-70)**: Stage renamed from "ScanTODO" to "ScanState" with state.json queries
- **Assessment**: Keep if this was a new optimization, verify separately if needed
- **Reasoning**: This is functional code, not documentation cruft
- **Note**: Review document suggests checking git history to verify if this was already implemented

---

### File 2: .opencode/command/review.md

**Risk Level**: Low  
**Changes Made**: Added state-lookup.md reference, added optimization notes

#### Cruft to Remove

**Issue 1: Performance Cruft in Frontmatter (lines 28-31)**
```yaml
optimization:
  phase: 2
  performance: "Fast task metadata access via state.json"
  approach: "Read next_project_number from state.json (already implemented)"
```
**Action**: Remove lines 28-31 entirely

**Issue 2: Verbose Comment (line 18)**
```yaml
- "core/system/state-lookup.md"  # For fast state.json queries (Phase 2 optimization)
```
**Action**: Simplify to:
```yaml
- "core/system/state-lookup.md"  # Fast state.json queries
```

**Issue 3: Verbose Comment (line 22)**
```yaml
- ".opencode/specs/state.json"  # Primary source for next_project_number and task queries
```
**Action**: Simplify to:
```yaml
- ".opencode/specs/state.json"  # State tracking
```

#### Changes to Keep

**state-lookup.md Reference (line 18)**: Added to required context
- **Assessment**: [PASS] - KEEP
- **Reasoning**: Useful reference if review command uses state.json

---

### File 3: .opencode/agent/subagents/reviewer.md

**Risk Level**: Low  
**Changes Made**: Added state-lookup.md reference, added optimization notes

#### Cruft to Remove

**Issue 1: Performance Cruft in Frontmatter (lines 32-35)**
```yaml
optimization:
  phase: 2
  note: "Use state.json for task queries (language-specific, status-based) instead of parsing TODO.md"
```
**Action**: Remove lines 32-35 entirely (the optimization section)

#### Changes to Keep

**state-lookup.md Reference (line ~30)**: Added to required context
- **Assessment**: [PASS] - KEEP
- **Reasoning**: Useful if reviewer uses state.json

---

### File 4: .opencode/agent/subagents/meta.md

**Risk Level**: HIGH  
**Changes Made**: Rewrote Stage 7 task creation logic, added state-lookup.md, added optimization notes

#### Cruft to Remove

**Issue 1: Performance Cruft in Frontmatter (lines 31-34)**
```yaml
optimization:
  phase: 2
  performance: "Atomic task creation via status-sync-manager"
  approach: "Use status-sync-manager.create_task() for guaranteed consistency"
```
**Action**: Remove lines 31-34 entirely

#### High-Risk Changes (DO NOT REMOVE IN TASK 305)

**Issue 2: CRITICAL - Changed Core Task Creation Logic (lines 515-551)**

**Original Approach** (likely):
```markdown
5. For each task, create task entry in TODO.md:
   a. Format: ### {number}. {title}
   b. Include required fields...

6. For each task, update state.json:
   a. Add to active_projects array...
   b. Increment next_project_number
```

**New Approach**:
```markdown
5. For each task, create task entry atomically using status-sync-manager:
   a. Prepare task metadata
   b. Delegate to status-sync-manager with operation="create_task"
   c. Receive return from status-sync-manager
   d. After task created, add plan artifact link atomically
```

**Assessment**: [WARN] - BREAKING CHANGE
- Fundamentally different approach (direct file manipulation → delegation)
- May not work if status-sync-manager doesn't support this pattern
- Needs verification in task 307

**Action for Task 305**: Remove only performance cruft, NOT core logic changes

---

### File 5: .opencode/agent/subagents/task-creator.md

**Risk Level**: HIGH  
**Changes Made**: Rewrote Step 3 task creation logic, added state-lookup.md, added optimization notes

#### Cruft to Remove

**Issue 1: Performance Cruft in Frontmatter (lines 32-35)**
```yaml
optimization:
  phase: 2
  performance: "Atomic task creation via status-sync-manager"
  approach: "Use status-sync-manager.create_task() for guaranteed consistency"
```
**Action**: Remove lines 32-35 entirely

**Issue 2: Performance Cruft in Step 3 (lines 311-317)**
```xml
<optimization>
  Phase 2 optimization: Use status-sync-manager.create_task() for:
  - Guaranteed atomic updates (both files or neither)
  - Automatic rollback on failure
  - Consistent task creation across all commands (/task, /meta)
  - Better error handling and validation
</optimization>
```
**Action**: Remove lines 311-317 entirely

#### High-Risk Changes (DO NOT REMOVE IN TASK 305)

**Issue 3: CRITICAL - Changed Core Task Creation Logic (lines 260-318)**

**Original Approach** (stated in NOTE):
```markdown
NOTE: We do NOT use status-sync-manager for task creation because:
- status-sync-manager expects task to already exist in TODO.md
- Task creation is a special case (adding new entry, not updating existing)
- We handle atomic updates manually with proper error handling
```

**New Approach**:
```markdown
NOTE: We NOW use status-sync-manager.create_task() for atomic task creation:
- status-sync-manager was enhanced in Phase 2 to support task creation
- Provides atomic updates with automatic rollback on failure
```

**Assessment**: [WARN] - BREAKING CHANGE
- Contradicts original design decision
- Original NOTE explicitly said NOT to use status-sync-manager
- May break if status-sync-manager.create_task() doesn't exist
- Needs verification in task 307

**Action for Task 305**: Remove only performance cruft, NOT core logic changes

---

### File 6: .opencode/context/core/system/state-lookup.md

**Risk Level**: Low  
**Changes Made**: Added Phase 2 patterns (Pattern 5-10), updated version to 1.1

#### Assessment

**Changes Made**:
- Added 6 new patterns for Phase 2 optimizations
- Added performance improvement tables
- Updated version from 1.0 to 1.1
- All additive changes (no deletions)

**Issues**: None - this is pure documentation

**Recommendation**: [PASS] - KEEP ALL CHANGES

**Reasoning**:
- This is the proper place for performance documentation
- Provides valuable reference for state.json query patterns
- Well-structured and useful
- No cruft to remove

**Action**: NO CHANGES to state-lookup.md

---

## Decisions

### Decision 1: Remove All Performance Cruft

**Decision**: Remove optimization sections, performance blocks, and verbose comments from all 5 files (todo.md, review.md, reviewer.md, meta.md, task-creator.md)

**Reasoning**:
- Frontmatter should be minimal metadata
- Performance notes don't belong in workflow definitions
- Verbose comments clutter the code
- Performance metrics become stale

**Impact**: Cleaner, more maintainable code with consistent comment style

---

### Decision 2: Keep state-lookup.md Documentation

**Decision**: Keep all changes to state-lookup.md

**Reasoning**:
- This is the proper place for performance documentation
- Provides valuable reference patterns
- Well-structured and useful
- No cruft identified

**Impact**: Preserves valuable documentation

---

### Decision 3: Defer Core Logic Verification

**Decision**: Do NOT remove core logic changes in meta.md and task-creator.md as part of task 305. Handle in task 307.

**Reasoning**:
- Core logic changes are high-risk
- Need separate verification that status-sync-manager.create_task() exists
- Need to test /meta and /task commands
- Requires decision: keep or revert

**Impact**: Task 305 focuses only on cruft removal, task 307 handles logic verification

---

## Recommendations

### Recommendation 1: Remove Performance Cruft (Priority: High)

**What**: Remove optimization sections, performance blocks, and verbose comments from 5 files

**Files**:
1. `.opencode/command/todo.md` - Remove frontmatter optimization, performance block, simplify comments
2. `.opencode/command/review.md` - Remove frontmatter optimization, simplify comments
3. `.opencode/agent/subagents/reviewer.md` - Remove frontmatter optimization
4. `.opencode/agent/subagents/meta.md` - Remove frontmatter optimization only
5. `.opencode/agent/subagents/task-creator.md` - Remove frontmatter optimization and Step 3 optimization block

**Estimated Effort**: 30 minutes

**Impact**: Cleaner code, consistent style, reduced maintenance burden

---

### Recommendation 2: Preserve state-lookup.md Documentation (Priority: High)

**What**: Keep all changes to state-lookup.md

**Reasoning**: This is valuable documentation in the proper location

**Estimated Effort**: 0 minutes (no changes)

**Impact**: Preserves useful reference documentation

---

### Recommendation 3: Verify Core Logic Separately (Priority: High)

**What**: Handle meta.md and task-creator.md core logic changes in task 307

**Steps**:
1. Check if status-sync-manager.create_task() exists
2. Test /meta and /task commands
3. Decide: keep or revert core logic changes

**Estimated Effort**: 1 hour (task 307)

**Impact**: Ensures commands still work correctly

---

## Risks & Mitigations

### Risk 1: Removing Wrong Content

**Risk**: Accidentally removing functional code instead of just cruft

**Likelihood**: Low  
**Impact**: High

**Mitigation**:
- Follow exact line numbers from review document
- Only remove optimization sections, performance blocks, and verbose comments
- Do NOT remove core logic changes (defer to task 307)
- Test commands after changes

---

### Risk 2: Breaking Commands

**Risk**: Changes break /meta or /task commands

**Likelihood**: Low (only removing documentation)  
**Impact**: Medium

**Mitigation**:
- Only remove documentation cruft, not logic
- Core logic changes handled separately in task 307
- Test commands after changes

---

### Risk 3: Inconsistent Changes

**Risk**: Missing some cruft or making inconsistent edits

**Likelihood**: Medium  
**Impact**: Low

**Mitigation**:
- Use exact patterns from review document
- Verify all 5 files updated consistently
- Check for any remaining "Phase 2 optimization" comments

---

## Appendix: Sources and Citations

### Primary Source

**changes-review-and-fixes-required.md** (804 lines)
- Comprehensive analysis of all 6 files
- Exact line numbers for all issues
- Detailed recommendations
- Created: 2026-01-05

### File Locations

1. `.opencode/command/todo.md` - TODO maintenance command
2. `.opencode/command/review.md` - Codebase review command
3. `.opencode/agent/subagents/reviewer.md` - Review subagent
4. `.opencode/agent/subagents/meta.md` - Meta system builder
5. `.opencode/agent/subagents/task-creator.md` - Task creation subagent
6. `.opencode/context/core/system/state-lookup.md` - State lookup documentation

### Related Tasks

- **Task 304**: Test commands after unintended changes (abandoned)
- **Task 307**: Verify or revert core logic changes in high-risk files
- **Task 308**: Final cleanup and comprehensive testing

---

## Summary of Action Items

### For Task 305 Implementation

**File 1: todo.md**
- [ ] Remove optimization section (lines 19-22)
- [ ] Remove performance block (lines 71-78)
- [ ] Simplify comment on line 13: "For fast state.json queries (Phase 2 optimization)" → "Fast state.json queries"
- [ ] Simplify comment on line 16: "State tracking (primary source for task scanning)" → "State tracking"

**File 2: review.md**
- [ ] Remove optimization section (lines 28-31)
- [ ] Simplify comment on line 18: "For fast state.json queries (Phase 2 optimization)" → "Fast state.json queries"
- [ ] Simplify comment on line 22: "Primary source for next_project_number and task queries" → "State tracking"

**File 3: reviewer.md**
- [ ] Remove optimization section (lines 32-35)

**File 4: meta.md**
- [ ] Remove optimization section (lines 31-34)
- [ ] DO NOT remove core logic changes (defer to task 307)

**File 5: task-creator.md**
- [ ] Remove optimization section (lines 32-35)
- [ ] Remove optimization block in Step 3 (lines 311-317)
- [ ] DO NOT remove core logic changes (defer to task 307)

**File 6: state-lookup.md**
- [ ] NO CHANGES - keep all documentation

**Total Files to Modify**: 5 files  
**Total Files to Keep Unchanged**: 1 file (state-lookup.md)  
**Estimated Effort**: 30 minutes

---

**End of Research Report**
