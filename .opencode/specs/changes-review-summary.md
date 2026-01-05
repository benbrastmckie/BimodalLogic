# Changes Review Summary

**Date**: 2026-01-05
**Full Report**: changes-review-and-fixes-required.md

---

## Quick Summary

### Files Modified: 6

| File | Risk | Main Issue | Recommendation |
|------|------|------------|----------------|
| `command/todo.md` | Medium | Performance cruft + Stage 1 changes | Remove cruft, verify Stage 1 |
| `command/review.md` | Low | Performance cruft only | Remove cruft, keep logic |
| `subagents/reviewer.md` | Low | Performance cruft only | Remove cruft, keep logic |
| `subagents/meta.md` | **HIGH** | Rewrote Stage 7 task creation | Verify or REVERT |
| `subagents/task-creator.md` | **HIGH** | Rewrote Step 3 task creation | Verify or REVERT |
| `context/.../state-lookup.md` | Low | Documentation additions | KEEP all changes |

---

## Critical Issues

### Issue 1: Performance Cruft (All Files)

**What**: Added `optimization:` sections in YAML frontmatter, `<performance>` blocks in workflows

**Problem**: 
- Frontmatter should be minimal metadata
- Performance notes don't belong in code
- Becomes stale and misleading
- Unnecessary parsing overhead

**Fix**: Remove all performance cruft from all 6 files

**Estimated Time**: 30 minutes

---

### Issue 2: Breaking Changes (2 High-Risk Files)

**Files**: 
- `subagents/meta.md` - Stage 7 task creation
- `subagents/task-creator.md` - Step 3 task creation

**What**: Changed from manual file updates to status-sync-manager delegation

**Problem**:
- May not work if status-sync-manager.create_task() doesn't exist
- Contradicts original design (task-creator explicitly said NOT to use sync manager)
- Untested changes

**Fix**: 
1. Check if status-sync-manager.create_task() exists
2. Test `/meta` and `/task` commands
3. If broken: REVERT immediately
4. If working: Remove cruft, keep logic

**Estimated Time**: 1-2 hours (includes testing)

---

## Action Plan

### Step 1: Quick Check (5 minutes)

```bash
# Does create_task exist?
grep -A 50 "create_task_flow" .opencode/agent/subagents/status-sync-manager.md
```

**If NO**: Skip to Step 4 (revert high-risk files)
**If YES**: Continue to Step 2

---

### Step 2: Test Commands (15 minutes)

```bash
/task "Test task creation"
/meta "Test meta system"  
/todo
```

**If ANY fail**: Skip to Step 4 (revert high-risk files)
**If ALL work**: Continue to Step 3

---

### Step 3: Remove Cruft Only (30 minutes)

Remove performance cruft from all 6 files:
- Delete `optimization:` sections from frontmatter
- Delete `<performance>` and `<optimization>` blocks
- Simplify verbose comments
- Keep all logic changes

---

### Step 4: Revert High-Risk Files (15 minutes)

```bash
git checkout HEAD~1 .opencode/agent/subagents/meta.md
git checkout HEAD~1 .opencode/agent/subagents/task-creator.md
```

Then do Step 3 for the remaining low-risk files.

---

## Specific Fixes Required

### All Files: Remove Performance Cruft

**Remove from frontmatter**:
```yaml
optimization:
  phase: 2
  performance: "..."
  approach: "..."
```

**Remove from workflows**:
```xml
<performance>
  ...
</performance>

<optimization>
  ...
</optimization>
```

**Simplify comments**:
```yaml
# Before
- "core/system/state-lookup.md"  # For fast state.json queries (Phase 2 optimization)

# After
- "core/system/state-lookup.md"  # Fast state.json queries
```

---

### High-Risk Files: Verify or Revert

**meta.md - Stage 7**:
- Changed from manual TODO.md/state.json updates
- To status-sync-manager delegation
- **Action**: Verify create_task() exists and works, or REVERT

**task-creator.md - Step 3**:
- Changed from manual atomic updates
- To status-sync-manager delegation
- **Action**: Verify create_task() exists and works, or REVERT

---

## Decision Matrix

| Condition | Action |
|-----------|--------|
| create_task() exists AND commands work | Remove cruft, keep logic |
| create_task() doesn't exist | REVERT high-risk files |
| Commands don't work | REVERT high-risk files |
| Uncertain | REVERT high-risk files (safest) |

---

## Estimated Time

- **Quick verification**: 5 minutes
- **Testing**: 15 minutes
- **Remove cruft only**: 30 minutes
- **Revert + cleanup**: 45 minutes

**Total**: 1-2 hours depending on path taken

---

## Recommendation

**Safest Approach**:
1. Check if create_task() exists in status-sync-manager
2. If NO: Revert meta.md and task-creator.md immediately
3. If YES: Test commands thoroughly
4. If tests pass: Remove cruft, keep logic
5. If tests fail: Revert high-risk files
6. Always remove performance cruft from all files

---

**See full report for detailed fix scripts and line-by-line analysis**: 
`changes-review-and-fixes-required.md`
