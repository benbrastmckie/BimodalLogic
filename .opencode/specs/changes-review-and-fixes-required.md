# Changes Review and Fixes Required

**Date**: 2026-01-05
**Purpose**: Detailed analysis of unintended changes with specific fix recommendations
**Related**: unintended-changes-report.md

---

## Executive Summary

After reviewing the 6 modified files, I've identified:
- **2 files with problematic changes** requiring fixes (cruft removal)
- **2 files with potentially breaking changes** requiring careful review
- **2 files with safe documentation additions** that can be kept

**Recommended Action**: Remove performance cruft, verify core logic changes against git history

---

## File-by-File Analysis

### 1. `.opencode/command/todo.md` - NEEDS FIXES

**Risk Level**: Medium
**Changes Made**: Stage 1 renamed, added state.json queries, added performance notes

#### Issues Identified

**Issue 1: Performance Cruft in Frontmatter**
```yaml
# Lines 19-22 - REMOVE THIS
optimization:
  phase: 2
  performance: "13x faster task scanning (200ms → 15ms)"
  approach: "Query state.json with jq instead of parsing TODO.md"
```

**Problem**: 
- Frontmatter should be minimal metadata, not performance documentation
- This information belongs in comments or documentation files, not YAML
- Adds unnecessary parsing overhead
- Not used by any system component

**Fix**: Remove lines 19-22 entirely

---

**Issue 2: Performance Cruft in Stage 1**
```markdown
# Lines 71-78 - REMOVE THIS
<performance>
  Total time: ~15ms (13x faster than TODO.md scanning)
  
  Comparison:
    - Old approach (TODO.md parsing): ~200ms
    - New approach (state.json query): ~15ms
    - Improvement: 13x faster
</performance>
```

**Problem**:
- Performance notes don't belong in workflow execution stages
- This is documentation, not executable logic
- Clutters the workflow definition
- If performance changes, this becomes stale/misleading

**Fix**: Remove lines 71-78 entirely

---

**Issue 3: Potentially Good Change - Stage 1 Optimization**

**Lines 54-70**: Stage renamed from "ScanTODO" to "ScanState" with state.json queries

**Assessment**: 
- ✅ **IF Phase 2 was not implemented**: This is a correct optimization
- ⚠️ **IF Phase 2 was already implemented**: This is redundant
- ⚠️ **IF partially implemented**: May cause inconsistency

**Required Action**: 
1. Check git history: `git log -p .opencode/command/todo.md | grep "ScanState"`
2. If "ScanState" already existed: **REVERT** to previous version
3. If "ScanTODO" was still there: **KEEP** the optimization but remove performance cruft

**How to Check**:
```bash
# Check if this was already optimized
git log --all --oneline --grep="Phase 2" -- .opencode/command/todo.md

# Check previous version of Stage 1
git show HEAD~1:.opencode/command/todo.md | grep -A 20 "stage id=\"1\""
```

---

**Issue 4: Comment Cruft in context_loading**
```yaml
# Line 13 - SIMPLIFY THIS
- "core/system/state-lookup.md"      # For fast state.json queries (Phase 2 optimization)
```

**Problem**:
- Comment is too verbose
- "Phase 2 optimization" is implementation detail, not useful for understanding
- Other files don't have this level of detail in comments

**Fix**: Simplify to:
```yaml
- "core/system/state-lookup.md"  # Fast state.json queries
```

---

**Issue 5: Redundant Comment in data_files**
```yaml
# Line 16 - SIMPLIFY THIS
- ".opencode/specs/state.json"       # State tracking (primary source for task scanning)
```

**Problem**:
- "(primary source for task scanning)" is redundant with the optimization section
- Too verbose

**Fix**: Simplify to:
```yaml
- ".opencode/specs/state.json"  # State tracking
```

---

#### Recommended Fixes for todo.md

**Fix 1**: Remove performance cruft from frontmatter
```bash
# Remove lines 19-22
sed -i '19,22d' .opencode/command/todo.md
```

**Fix 2**: Remove performance cruft from Stage 1
```bash
# Remove the <performance> block (lines 71-78 after Fix 1)
# Manual edit required - remove the entire <performance>...</performance> block
```

**Fix 3**: Simplify comments
```bash
# Line 13 (after previous deletions)
sed -i 's|# For fast state.json queries (Phase 2 optimization)|# Fast state.json queries|' .opencode/command/todo.md

# Line 16 (after previous deletions)
sed -i 's|# State tracking (primary source for task scanning)|# State tracking|' .opencode/command/todo.md
```

**Fix 4**: Verify Stage 1 optimization is needed
```bash
# Check git history first, then decide whether to keep or revert
git show HEAD~1:.opencode/command/todo.md | grep -A 30 "stage id=\"1\""
```

---

### 2. `.opencode/command/review.md` - NEEDS FIXES

**Risk Level**: Low
**Changes Made**: Added state-lookup.md reference, added optimization notes

#### Issues Identified

**Issue 1: Performance Cruft in Frontmatter**
```yaml
# Lines 28-31 - REMOVE THIS
optimization:
  phase: 2
  performance: "Fast task metadata access via state.json"
  approach: "Read next_project_number from state.json (already implemented)"
```

**Problem**: Same as todo.md - frontmatter should be minimal

**Fix**: Remove lines 28-31 entirely

---

**Issue 2: Verbose Comment**
```yaml
# Line 18 - SIMPLIFY THIS
- "core/system/state-lookup.md"  # For fast state.json queries (Phase 2 optimization)
```

**Fix**: Simplify to:
```yaml
- "core/system/state-lookup.md"  # Fast state.json queries
```

---

**Issue 3: Verbose Comment**
```yaml
# Line 22 - SIMPLIFY THIS
- ".opencode/specs/state.json"  # Primary source for next_project_number and task queries
```

**Fix**: Simplify to:
```yaml
- ".opencode/specs/state.json"  # State tracking
```

---

**Issue 4: Good Change - state-lookup.md Reference**

**Line 18**: Added state-lookup.md to required context

**Assessment**: ✅ **KEEP** - This is a useful reference if review command uses state.json

---

#### Recommended Fixes for review.md

**Fix 1**: Remove performance cruft
```bash
# Remove lines 28-31
sed -i '28,31d' .opencode/command/review.md
```

**Fix 2**: Simplify comments
```bash
sed -i 's|# For fast state.json queries (Phase 2 optimization)|# Fast state.json queries|' .opencode/command/review.md
sed -i 's|# Primary source for next_project_number and task queries|# State tracking|' .opencode/command/review.md
```

---

### 3. `.opencode/agent/subagents/reviewer.md` - NEEDS FIXES

**Risk Level**: Low
**Changes Made**: Added state-lookup.md reference, added optimization notes

#### Issues Identified

**Issue 1: Performance Cruft in Frontmatter**
```yaml
# Lines 32-34 (approximately) - REMOVE THIS
optimization:
  phase: 2
  note: "Use state.json for task queries (language-specific, status-based) instead of parsing TODO.md"
```

**Problem**: Same as above - frontmatter cruft

**Fix**: Remove the optimization section entirely

---

**Issue 2: Good Change - state-lookup.md Reference**

**Line ~30**: Added state-lookup.md to required context

**Assessment**: ✅ **KEEP** - Useful if reviewer uses state.json

---

#### Recommended Fixes for reviewer.md

**Fix 1**: Remove performance cruft
```bash
# Find and remove the optimization section in context_loading
# Manual edit required - remove the optimization: block
```

**Fix 2**: Keep state-lookup.md reference (no change needed)

---

### 4. `.opencode/agent/subagents/meta.md` - REQUIRES CAREFUL REVIEW

**Risk Level**: HIGH
**Changes Made**: Rewrote Stage 7 task creation logic, added state-lookup.md, added optimization notes

#### Issues Identified

**Issue 1: Performance Cruft in Frontmatter**
```yaml
# Lines 31-34 - REMOVE THIS
optimization:
  phase: 2
  performance: "Atomic task creation via status-sync-manager"
  approach: "Use status-sync-manager.create_task() for guaranteed consistency"
```

**Problem**: Frontmatter cruft

**Fix**: Remove lines 31-34

---

**Issue 2: CRITICAL - Changed Core Task Creation Logic**

**Lines 515-551**: Completely rewrote how meta creates tasks

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

**Assessment**:
- ⚠️ **BREAKING CHANGE** - Fundamentally different approach
- ⚠️ Changes from direct file manipulation to delegation
- ⚠️ Adds extra step (d) for plan artifact linking
- ⚠️ May not work if status-sync-manager doesn't support this pattern

**Required Action**:
1. **Check git history**: Was this already using status-sync-manager?
2. **Check status-sync-manager**: Does it support the create_task operation as described?
3. **Test thoroughly**: Does `/meta` still work?

**How to Check**:
```bash
# Check previous version
git show HEAD~1:.opencode/agent/subagents/meta.md | grep -A 50 "For each task, create"

# Check if status-sync-manager has create_task
grep -A 20 "create_task" .opencode/agent/subagents/status-sync-manager.md
```

**Recommendation**:
- **IF** status-sync-manager.create_task() exists and works: **KEEP** but remove cruft
- **IF** status-sync-manager.create_task() doesn't exist or doesn't work: **REVERT** entirely
- **IF** uncertain: **REVERT** to be safe, then implement properly with testing

---

**Issue 3: Added Plan Artifact Linking Step**

**Lines 537-551**: Added step (d) to link plan artifacts after task creation

**Problem**:
- This may be a new requirement not in original design
- Adds complexity
- May not be necessary if status-sync-manager handles it

**Assessment**: Depends on whether this is needed functionality or over-engineering

---

#### Recommended Fixes for meta.md

**Fix 1**: Remove performance cruft
```bash
# Remove lines 31-34
sed -i '31,34d' .opencode/agent/subagents/meta.md
```

**Fix 2**: Verify task creation logic
```bash
# Check git history
git show HEAD~1:.opencode/agent/subagents/meta.md | grep -A 50 "Stage 7"

# Compare with current
grep -A 50 "Stage 7" .opencode/agent/subagents/meta.md
```

**Fix 3**: Decision required
- **Option A**: REVERT Stage 7 to previous version (safest)
- **Option B**: KEEP if status-sync-manager.create_task() is confirmed working
- **Option C**: Test `/meta` command and decide based on results

---

### 5. `.opencode/agent/subagents/task-creator.md` - REQUIRES CAREFUL REVIEW

**Risk Level**: HIGH
**Changes Made**: Rewrote Step 3 task creation logic, added state-lookup.md, added optimization notes

#### Issues Identified

**Issue 1: Performance Cruft in Frontmatter**
```yaml
# Lines 32-35 - REMOVE THIS
optimization:
  phase: 2
  performance: "Atomic task creation via status-sync-manager"
  approach: "Use status-sync-manager.create_task() for guaranteed consistency"
```

**Problem**: Frontmatter cruft

**Fix**: Remove lines 32-35

---

**Issue 2: CRITICAL - Changed Core Task Creation Logic**

**Lines 260-318**: Completely rewrote Step 3

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

**Assessment**:
- ⚠️ **BREAKING CHANGE** - Contradicts original design decision
- ⚠️ Original NOTE explicitly said NOT to use status-sync-manager
- ⚠️ Changed from manual atomic updates to delegation
- ⚠️ May break if status-sync-manager.create_task() doesn't exist or work properly

**Required Action**:
1. **Check status-sync-manager**: Does it have create_task() operation?
2. **Check git history**: Was this already changed?
3. **Test**: Does `/task` command still work?

**How to Check**:
```bash
# Check previous version
git show HEAD~1:.opencode/agent/subagents/task-creator.md | grep -A 30 "step_3_update_files"

# Verify status-sync-manager has create_task
grep -A 50 "create_task_flow" .opencode/agent/subagents/status-sync-manager.md
```

**Recommendation**:
- **IF** status-sync-manager.create_task() exists and was tested: **KEEP** but remove cruft
- **IF** status-sync-manager.create_task() doesn't exist: **REVERT** immediately
- **IF** uncertain: **REVERT** to be safe

---

**Issue 3: Added Delegation to status-sync-manager**

**Lines 36-39**: Added status-sync-manager to can_delegate_to

**Problem**: This is consistent with the Step 3 changes, but may not be needed if we revert

**Fix**: If reverting Step 3, also revert this change

---

**Issue 4: Performance Cruft in Step 3**
```markdown
# Lines 311-317 - REMOVE THIS
<optimization>
  Phase 2 optimization: Use status-sync-manager.create_task() for:
  - Guaranteed atomic updates (both files or neither)
  - Automatic rollback on failure
  - Consistent task creation across all commands (/task, /meta)
  - Better error handling and validation
</optimization>
```

**Problem**: Documentation cruft in process flow

**Fix**: Remove lines 311-317

---

#### Recommended Fixes for task-creator.md

**Fix 1**: Remove performance cruft from frontmatter
```bash
# Remove lines 32-35
sed -i '32,35d' .opencode/agent/subagents/task-creator.md
```

**Fix 2**: Remove performance cruft from Step 3
```bash
# Remove the <optimization> block
# Manual edit required
```

**Fix 3**: Verify task creation logic
```bash
# Check git history
git show HEAD~1:.opencode/agent/subagents/task-creator.md | grep -A 80 "step_3_update_files"

# Check status-sync-manager
grep -A 100 "create_task_flow" .opencode/agent/subagents/status-sync-manager.md
```

**Fix 4**: Decision required
- **Option A**: REVERT Step 3 and delegation changes (safest)
- **Option B**: KEEP if status-sync-manager.create_task() is confirmed working
- **Option C**: Test `/task` command and decide based on results

---

### 6. `.opencode/context/core/system/state-lookup.md` - SAFE TO KEEP

**Risk Level**: Low
**Changes Made**: Added Phase 2 patterns (Pattern 5-10), updated version to 1.1

#### Assessment

**Changes Made**:
- Added 6 new patterns for Phase 2 optimizations
- Added performance improvement tables
- Updated version from 1.0 to 1.1
- All additive changes (no deletions)

**Issues**: None - this is pure documentation

**Recommendation**: ✅ **KEEP ALL CHANGES** - These are valuable documentation additions

---

## Summary of Required Fixes

### Priority 1: Remove Performance Cruft (All Files)

**Files Affected**: All 6 files

**What to Remove**:
1. `optimization:` sections in frontmatter (YAML)
2. `<performance>` blocks in workflow stages
3. `<optimization>` blocks in process flows
4. Verbose comments like "(Phase 2 optimization)"

**Why**: 
- Frontmatter should be minimal metadata
- Workflow definitions should be logic, not documentation
- Performance notes become stale and misleading
- Adds unnecessary parsing overhead

**Estimated Time**: 30 minutes

---

### Priority 2: Verify Core Logic Changes (High-Risk Files)

**Files Affected**: 
- `.opencode/agent/subagents/meta.md` (Stage 7)
- `.opencode/agent/subagents/task-creator.md` (Step 3)

**What to Check**:
1. Does status-sync-manager.create_task() exist?
2. Was this logic already changed in git history?
3. Do `/meta` and `/task` commands still work?

**Decision Matrix**:
| Condition | Action |
|-----------|--------|
| create_task() exists AND commands work | Keep logic, remove cruft |
| create_task() doesn't exist | REVERT immediately |
| Commands don't work | REVERT immediately |
| Uncertain | REVERT to be safe |

**Estimated Time**: 1-2 hours (includes testing)

---

### Priority 3: Simplify Comments (Low-Risk Files)

**Files Affected**:
- `.opencode/command/todo.md`
- `.opencode/command/review.md`

**What to Change**:
- Simplify verbose comments to be concise
- Remove implementation details from comments
- Keep only essential information

**Estimated Time**: 15 minutes

---

## Recommended Action Plan

### Step 1: Quick Verification (15 minutes)

```bash
# Check if status-sync-manager has create_task
grep -A 50 "create_task_flow" .opencode/agent/subagents/status-sync-manager.md

# Check git history for meta.md
git log --oneline -10 .opencode/agent/subagents/meta.md

# Check git history for task-creator.md
git log --oneline -10 .opencode/agent/subagents/task-creator.md
```

**Decision Point**: 
- If create_task_flow exists in status-sync-manager: Proceed to Step 2
- If create_task_flow doesn't exist: Skip to Step 4 (revert high-risk files)

---

### Step 2: Test Commands (30 minutes)

```bash
# Test /task command
/task "Test task creation after changes"

# Test /meta command (if applicable)
/meta "Test meta system"

# Test /todo command
/todo
```

**Decision Point**:
- If all commands work: Proceed to Step 3 (remove cruft only)
- If any command fails: Proceed to Step 4 (revert high-risk files)

---

### Step 3: Remove Cruft Only (30 minutes)

**If commands work**, remove only the performance cruft:

1. Remove `optimization:` sections from all frontmatter
2. Remove `<performance>` and `<optimization>` blocks
3. Simplify verbose comments
4. Keep all logic changes

**Files to Edit**:
- All 6 files (remove cruft)
- Keep state-lookup.md changes (documentation)

---

### Step 4: Revert High-Risk Files (15 minutes)

**If commands don't work or create_task doesn't exist**:

```bash
# Revert meta.md
git checkout HEAD~1 .opencode/agent/subagents/meta.md

# Revert task-creator.md
git checkout HEAD~1 .opencode/agent/subagents/task-creator.md

# Revert todo.md (if Stage 1 was already optimized)
git checkout HEAD~1 .opencode/command/todo.md
```

**Then** proceed with Step 3 for the low-risk files (review.md, reviewer.md)

---

### Step 5: Final Cleanup (15 minutes)

1. Remove cruft from any files not reverted
2. Test all commands again
3. Commit clean changes

---

## Detailed Fix Scripts

### Script 1: Remove Cruft from todo.md

```bash
# Backup first
cp .opencode/command/todo.md .opencode/command/todo.md.backup

# Remove optimization section from frontmatter (lines 19-22)
sed -i '19,22d' .opencode/command/todo.md

# Simplify comments (after line deletion, line numbers shift)
sed -i 's|# For fast state.json queries (Phase 2 optimization)|# Fast state.json queries|' .opencode/command/todo.md
sed -i 's|# State tracking (primary source for task scanning)|# State tracking|' .opencode/command/todo.md

# Manual: Remove <performance> block from Stage 1 (lines ~71-78 after deletions)
# Open in editor and delete the entire <performance>...</performance> block
```

---

### Script 2: Remove Cruft from review.md

```bash
# Backup first
cp .opencode/command/review.md .opencode/command/review.md.backup

# Remove optimization section from frontmatter (lines 28-31)
sed -i '28,31d' .opencode/command/review.md

# Simplify comments
sed -i 's|# For fast state.json queries (Phase 2 optimization)|# Fast state.json queries|' .opencode/command/review.md
sed -i 's|# Primary source for next_project_number and task queries|# State tracking|' .opencode/command/review.md
```

---

### Script 3: Remove Cruft from reviewer.md

```bash
# Backup first
cp .opencode/agent/subagents/reviewer.md .opencode/agent/subagents/reviewer.md.backup

# Manual: Remove optimization section from context_loading
# Open in editor and delete the optimization: block (lines ~32-34)
```

---

### Script 4: Remove Cruft from meta.md (if keeping logic changes)

```bash
# Backup first
cp .opencode/agent/subagents/meta.md .opencode/agent/subagents/meta.md.backup

# Remove optimization section from frontmatter (lines 31-34)
sed -i '31,34d' .opencode/agent/subagents/meta.md

# Note: Logic changes in Stage 7 are kept if commands work
```

---

### Script 5: Remove Cruft from task-creator.md (if keeping logic changes)

```bash
# Backup first
cp .opencode/agent/subagents/task-creator.md .opencode/agent/subagents/task-creator.md.backup

# Remove optimization section from frontmatter (lines 32-35)
sed -i '32,35d' .opencode/agent/subagents/task-creator.md

# Manual: Remove <optimization> block from Step 3 (lines ~311-317 after deletion)
# Open in editor and delete the entire <optimization>...</optimization> block
```

---

## Final Recommendations

### Immediate Actions (Required)

1. ✅ **Verify status-sync-manager.create_task() exists**
   - If NO: Revert meta.md and task-creator.md immediately
   - If YES: Proceed with testing

2. ✅ **Test commands**
   - Test `/task "Test"`
   - Test `/meta "Test"`
   - Test `/todo`
   - If any fail: Revert high-risk files

3. ✅ **Remove all performance cruft** (regardless of logic decisions)
   - Remove `optimization:` from frontmatter (all files)
   - Remove `<performance>` blocks (todo.md)
   - Remove `<optimization>` blocks (task-creator.md)
   - Simplify verbose comments (all files)

### Optional Actions (Recommended)

1. 📝 **Document optimizations properly**
   - Add to state-json-phase2-complete-summary.md (already exists)
   - Don't embed in code files

2. 🧪 **Add tests for atomic operations**
   - Test task creation atomicity
   - Test rollback on failure

3. 📊 **Benchmark performance**
   - Measure actual performance improvements
   - Document in separate performance report

---

## Conclusion

**Total Files Needing Fixes**: 6 files
**High-Risk Changes**: 2 files (meta.md, task-creator.md)
**Low-Risk Changes**: 4 files (todo.md, review.md, reviewer.md, state-lookup.md)

**Estimated Total Time**: 2-3 hours (including testing and verification)

**Critical Decision**: Whether to keep or revert the core logic changes in meta.md and task-creator.md depends on:
1. Existence of status-sync-manager.create_task()
2. Whether commands still work
3. Whether this was already implemented in git history

**Safest Approach**: Revert high-risk files, remove cruft from low-risk files, then re-implement optimizations properly with testing.

---

**End of Review Report**
