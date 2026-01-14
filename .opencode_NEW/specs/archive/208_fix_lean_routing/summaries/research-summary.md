# Research Summary: Fix Lean Routing in /implement and /research

**Task**: 208  
**Date**: 2025-12-28  
**Status**: Completed

---

## Key Findings

- **OpenCode is a Claude-based AI agent system** where markdown files serve as prompts/instructions, not executable code
- **Routing logic exists but is not consistently executed** - documented in command files and orchestrator but Claude skips or fails to execute it
- **Root cause is prompt execution consistency**, not missing features - Claude is not reliably following the documented routing instructions
- **Lean-specific agents are production-ready** - lean-implementation-agent and lean-research-agent are fully specified and waiting to be invoked
- **.mcp.json is correctly configured** - lean-lsp-mcp is ready for use
- **Language field exists in TODO.md** - tasks include `- **Language**: lean` but extraction is unreliable
- **Fix requires prompt engineering** - strengthen markdown instructions with validation, logging, and explicit routing logic

---

## Root Cause

The routing bug is a **prompt execution consistency issue** in a Claude-based AI agent system. The routing logic exists as documentation in three locations:

1. `/research` command (research.md, Stage 2: CheckLanguage)
2. `/implement` command (implement.md, Stage 2: DetermineRouting)  
3. Orchestrator (orchestrator.md, Stages 3-4: CheckLanguage and PrepareRouting)

**Problem**: Claude is not consistently executing these routing stages when processing commands. It may:
- Skip the CheckLanguage/DetermineRouting stages entirely
- Fail to extract the `Language: lean` field from TODO.md
- Default to simpler routing paths (general agents) when uncertain
- Not validate routing decisions before agent invocation

**Result**: Lean tasks route to general agents (researcher, implementer) instead of Lean-specific agents (lean-research-agent, lean-implementation-agent), bypassing lean-lsp-mcp and Loogle integration.

---

## Required Fixes

### Fix 1: Enhance research.md Stage 2 (CheckLanguage)

**File**: `.opencode/command/research.md` (lines 131-144)

**Changes**:
- Add explicit language extraction instructions with bash commands
- Add `<validation>` section requiring language extraction before proceeding
- Add routing decision logging: "Routing /research to {agent}"
- Emphasize CRITICAL and REQUIRED for Lean routing

### Fix 2: Enhance implement.md Stage 2 (DetermineRouting)

**File**: `.opencode/command/implement.md` (lines 165-183)

**Changes**:
- Add explicit IF/ELSE routing logic with all four cases
- Add `<validation>` section with MUST NOT skip requirement
- Add routing decision logging with language and plan status
- Provide exact bash commands for language extraction

### Fix 3: Enhance orchestrator.md Stage 3 (CheckLanguage)

**File**: `.opencode/agent/orchestrator.md` (lines 138-154)

**Changes**:
- Add specific bash command for language extraction
- Add validation with logging requirement
- Add clear default behavior if extraction fails
- Emphasize MUST extract before Stage 4

### Fix 4: Enhance orchestrator.md Stage 4 (PrepareRouting)

**File**: `.opencode/agent/orchestrator.md` (lines 158-210)

**Changes**:
- Add explicit IF/ELSE routing logic for all commands
- Add CRITICAL emphasis on using Stage 3 language
- Add routing decision logging for each case
- Add MUST NOT default to general agents for Lean tasks

### Fix 5: Add Pre-Invocation Validation

**All command files**

**Changes**:
- Add validation step before agent invocation
- Check language was extracted, routing was performed, agent matches language
- Abort if validation fails
- Log validation results

---

## Implementation Effort

**Estimated Time**: 2-3 hours

**Breakdown**:
- 1 hour: Enhance command files (research.md, implement.md)
- 1 hour: Enhance orchestrator.md (Stages 3-4)
- 1 hour: Testing and validation

**Complexity**: Low-Medium
- Changes are localized to specific stages
- No new features, only prompt strengthening
- Clear validation criteria

**Risk**: Low-Medium
- Prompt changes may not be sufficient (mitigation: multiple validation checkpoints)
- Backward compatibility with general tasks (mitigation: test non-Lean routing)
- Incomplete fix if not all locations updated (mitigation: fix all three files)

---

## Testing Strategy

### Test Cases

1. **Language Extraction**: Verify Language field extracted from TODO.md and logged
2. **Lean Research Routing**: Verify /research routes to lean-research-agent and uses Loogle
3. **Lean Implementation Routing (No Plan)**: Verify /implement routes to lean-implementation-agent in simple mode
4. **Lean Implementation Routing (With Plan)**: Verify /implement routes to lean-implementation-agent in phased mode
5. **General Task Routing**: Verify non-Lean tasks still route to general agents
6. **Routing Validation**: Verify validation catches missing language extraction

### Success Criteria

- Lean tasks consistently route to Lean-specific agents
- lean-lsp-mcp is used for Lean implementation
- Loogle is used for Lean research
- General tasks still route to general agents
- Routing decisions are logged for debugging
- Validation prevents incorrect routing

---

## Expected vs Actual Behavior

### /research 193 (Language: lean)

**Expected**:
- Extract `Language: lean` from TODO.md
- Route to lean-research-agent
- Initialize Loogle CLI client
- Execute Loogle queries for Lean libraries
- Create research report with Loogle findings

**Actual (Before Fix)**:
- Language extraction skipped or failed
- Route to researcher (general agent)
- Use web search only
- No Loogle integration
- Generic research report

### /implement 193 (Language: lean, with plan)

**Expected**:
- Extract `Language: lean` from TODO.md
- Detect plan file exists
- Route to lean-implementation-agent (phased mode)
- Check .mcp.json for lean-lsp-mcp
- Implement Lean code with compilation checking
- Iterate on type errors

**Actual (Before Fix)**:
- Language extraction skipped or failed
- Route to task-executor (general agent)
- Direct file modification without compilation checking
- No lean-lsp-mcp integration
- Potential type errors undetected

---

## Next Steps

1. **Create implementation plan** (Task 208 /plan)
   - Phase 1: Enhance research.md and implement.md
   - Phase 2: Enhance orchestrator.md
   - Phase 3: Add validation and logging
   - Phase 4: Testing and verification

2. **Execute implementation** (Task 208 /implement)
   - Modify command files with enhanced routing instructions
   - Modify orchestrator with validation requirements
   - Test with Lean tasks (193, 192, etc.)
   - Verify routing decisions are logged

3. **Verify fixes work**
   - Test /research with Lean task
   - Test /implement with Lean task (no plan)
   - Test /implement with Lean task (with plan)
   - Verify lean-lsp-mcp and Loogle are used
   - Verify general tasks still work

4. **Document routing behavior**
   - Add routing examples to QUICK-START.md
   - Add troubleshooting guide for routing issues
   - Document expected routing decisions

---

## Tool Status

### lean-lsp-mcp

**Status**: [PASS] Configured and ready
- Server name: "lean-lsp"
- Command: `uvx lean-lsp-mcp`
- Project path: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker`
- Configuration: `.mcp.json` lines 3-11

**Usage**: lean-implementation-agent checks for this in step_1 and uses it for compilation checking

### Loogle CLI

**Status**: [PASS] Integrated (Task 197)
- Binary: `/home/benjamin/.cache/loogle/.lake/build/bin/loogle`
- Index: `~/.cache/lean-research-agent/loogle-mathlib.index`
- Mode: Persistent interactive mode with JSON output

**Usage**: lean-research-agent initializes Loogle client in step_1 and uses it for type-based search

### LeanExplore

**Status**: [FAIL] Not yet integrated
- Future enhancement for browsing Lean libraries

### LeanSearch

**Status**: [FAIL] Not yet integrated
- Future enhancement for semantic search over Lean libraries

---

## Conclusion

The routing bug is **not a missing feature** but a **prompt execution consistency issue**. The routing logic exists in documentation but Claude is not reliably executing it. The fix involves **strengthening prompt instructions** with explicit validation, logging, and routing logic to ensure Claude consistently routes Lean tasks to Lean-specific agents.

**Impact**: Critical for Lean development workflow
- Without fix: Lean tasks use general agents, no lean-lsp-mcp, no Loogle
- With fix: Lean tasks use specialized agents, compilation checking, library search

**Confidence**: High
- Root cause clearly identified
- Fix approach is well-defined
- Lean agents are ready and tested
- Tools are configured and available
