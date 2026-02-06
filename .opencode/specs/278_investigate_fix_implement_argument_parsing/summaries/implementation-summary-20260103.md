# Implementation Summary: Fix /implement Command Argument Parsing

**Date:** 2026-01-03  
**Task:** 278  
**Status:** Completed

## Changes Made

### 1. Added Explicit Command Type Lists
Added `<command_type_lists>` section to orchestrator.md defining:
- **Task-based commands**: research, plan, implement, revise (require task number)
- **Direct commands**: meta, review, todo, errors, task (optional arguments)

This removes ambiguity about which commands require task number parsing.

### 2. Strengthened Stage 1 (PreflightValidation)
Rewrote Stage 1, Step 2 with explicit, imperative instructions:
- Added "CRITICAL: You MUST execute ALL steps in order. Do NOT skip any step."
- Added detailed substeps for task-based command argument parsing:
  * Check if $ARGUMENTS is empty (abort if yes)
  * Extract first token as task_number
  * Validate task_number is positive integer using regex ^[1-9][0-9]*$
  * Store task_number for use in Stage 3
- Added logging checkpoints after each step
- Added validation checkpoint at end of Stage 1

### 3. Reinforced Stage 3 (RegisterAndDelegate)
Enhanced Stage 3 prompt formatting with:
- Pre-stage validation to verify task_number exists from Stage 1
- Explicit examples showing task_number usage:
  * /implement 271 → prompt = "Task: 271"
  * /research 258 → prompt = "Task: 258"
- Added validation that prompt matches pattern "Task: [0-9]+"
- Added post-delegation validation
- Emphasized DO NOT use $ARGUMENTS directly for task-based commands

### 4. Enhanced Validation Section
Updated `<validation>` section with:
- Explicit pre-flight validation requirements for Stage 1
- Explicit mid-flight validation requirements for Stage 3
- Clear abort conditions if validation fails

## Files Modified
- `.opencode/agent/orchestrator.md` - Added command type lists, strengthened Stage 1 and Stage 3 instructions, enhanced validation

## Root Cause
The orchestrator AI agent was not following its Stage 1 instructions to parse task numbers from $ARGUMENTS. The instructions were present but not explicit or imperative enough.

## Fix Strategy
Used "defense in depth" approach:
1. **Explicit lists**: Removed ambiguity about command types
2. **Imperative language**: Used "MUST" and "CRITICAL" to emphasize requirements
3. **Validation checkpoints**: Added multiple validation points to prevent skipping steps
4. **Detailed examples**: Showed exact formatting for common cases
5. **Logging**: Added logging to enable diagnosis

## Testing Recommendations
1. Test all task-based commands:
   - `/implement 271` (original failing case)
   - `/research 278`
   - `/plan 278`
   - `/revise 195`
2. Test direct commands to ensure no regression:
   - `/meta`
   - `/review`
   - `/todo`
3. Test edge cases:
   - Invalid task number (non-integer)
   - Missing task number
   - Extra arguments after task number

## Expected Behavior After Fix
- `/implement 271` should parse 271 as task_number in Stage 1
- Stage 3 should format prompt as "Task: 271"
- Orchestrator should delegate to implementer with correct prompt
- All task-based commands should work correctly
- No regression in direct command handling
