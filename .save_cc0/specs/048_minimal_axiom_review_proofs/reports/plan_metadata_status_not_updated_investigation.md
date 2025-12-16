# Investigation: Plan Metadata Status Not Updated to COMPLETE

## Issue Summary

The plan file metadata `- **Status**: [IN PROGRESS]` was not updated to `[COMPLETE]` after Phase 4 was successfully completed.

## Root Cause

**The `/lean-implement` command does not call `update_plan_status` to mark the plan as COMPLETE after all phases finish.**

### Evidence

1. **Block 1a** (lines 340-342 in lean-implement.md) sets status to IN PROGRESS at workflow start:
   ```bash
   if type update_plan_status &>/dev/null; then
     if update_plan_status "$PLAN_FILE" "IN PROGRESS" 2>/dev/null; then
   ```

2. **Block 2** (lines 1256-1261) checks if all phases are complete:
   ```bash
   PLAN_COMPLETE=false
   if type check_all_phases_complete &>/dev/null; then
     check_all_phases_complete "$PLAN_FILE" && PLAN_COMPLETE=true || PLAN_COMPLETE=false
   fi
   ```

3. **Missing**: There is no subsequent call to update the plan status to COMPLETE:
   ```bash
   # This code does NOT exist in Block 2:
   if [ "$PLAN_COMPLETE" = "true" ]; then
     update_plan_status "$PLAN_FILE" "COMPLETE"
   fi
   ```

### Why This Happens

The `PLAN_COMPLETE` variable is computed but only used implicitly for logging metrics. The actual `update_plan_status` function is never called with "COMPLETE" status.

### Additional Context

- The `check_all_phases_complete` function (checkbox-utils.sh:679-715) correctly returns 0 when all phase headings have `[COMPLETE]` marker
- Phase 4's heading was correctly updated to `[COMPLETE]`
- The **phase-level** markers work correctly
- The **plan-level** metadata status is the missing piece

## Impact

- Plan metadata shows `[IN PROGRESS]` even when all phases are complete
- `/todo` command may incorrectly report plan as incomplete
- Workflow tracking inconsistency between phase markers and plan status

## Fix Required

Add to Block 2 of `/lean-implement` after the `PLAN_COMPLETE` check:

```bash
# Update plan metadata status if all phases complete
if [ "$PLAN_COMPLETE" = "true" ]; then
  if type update_plan_status &>/dev/null; then
    update_plan_status "$PLAN_FILE" "COMPLETE" 2>/dev/null && \
      echo "Plan metadata status updated to [COMPLETE]" || \
      echo "WARNING: Could not update plan metadata status" >&2
  fi
fi
```

## Immediate Workaround

Manually update the plan file:
```bash
sed -i 's/^\(- \*\*Status\*\*:\).*/\1 [COMPLETE]/' /path/to/plan.md
```

## Files Affected

- `.claude/commands/lean-implement.md` - Missing status update logic
- `.claude/lib/plan/checkbox-utils.sh` - Functions work correctly, not the issue

## Related Functions

| Function | Location | Purpose | Working? |
|----------|----------|---------|----------|
| `update_plan_status` | checkbox-utils.sh:621 | Update metadata status | Yes |
| `check_all_phases_complete` | checkbox-utils.sh:679 | Check phase markers | Yes |
| `add_complete_marker` | checkbox-utils.sh:495 | Add [COMPLETE] to phase | Yes |

---

**Investigation Date**: 2025-12-08
**Investigator**: Claude Code (via /lean-implement workflow)
