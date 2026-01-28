---
name: test-context-fork
description: Test skill to verify context:fork works for user-level direct execution skills. Run this skill to check if forked context isolation is functioning.
context: fork
allowed-tools: Read, Glob, Bash
user-invocable: true
---

# Test Context Fork Skill

This skill tests whether `context: fork` properly isolates the conversation context for user-level skills.

## Purpose

Verify that:
1. The skill runs in an isolated context (cannot see messages from before invocation)
2. The skill has access to the specified tools only
3. Results return cleanly to the main conversation

## Test Execution

When invoked, this skill will:

1. **Report Context State**
   - Confirm this skill is running
   - List what tools are available to it
   - Note whether any parent conversation history is visible

2. **Perform Simple File Operation**
   - Read a small file to verify Read tool works
   - List files in a directory to verify Glob works

3. **Return Test Results**

## Verification Criteria

If context:fork is WORKING:
- The skill should NOT see any messages from before `/test-context-fork` was invoked
- The skill should only have access to: Read, Glob, Bash (as specified in allowed-tools)
- The main conversation should not be polluted with skill execution details

If context:fork is NOT WORKING:
- The skill will run inline in the main conversation
- Previous context will be visible
- All tools from the main session will be available

---

## Execute Test

I am the test-context-fork skill. Let me verify the context isolation:

### Step 1: Context Visibility Check

I will now report what I can observe about my context:
- I am running as test-context-fork skill
- I was invoked with context: fork in my frontmatter
- My allowed-tools are: Read, Glob, Bash

### Step 2: File Operation Test

Let me perform a simple file read to verify my tools work.

Read the SKILL.md file I'm currently running from to confirm Read tool access:

```
File: .claude/skills/test-context-fork/SKILL.md
```

### Step 3: Report Results

**Test Results Summary:**

1. **Skill Execution**: Running
2. **Context Mode**: context: fork specified
3. **Tool Access**: Limited to Read, Glob, Bash (as specified)

**Conclusion**: The skill executed. To fully verify context isolation:
- Check if this skill's execution details polluted the main conversation
- Check if the skill could access messages from before invocation

Return this summary to the main conversation for the user to evaluate.
