# Research Report: Task #895 (Follow-up Investigation)

**Task**: 895 - Update phase status markers during implementation
**Date**: 2026-02-17
**Focus**: Verify whether `[IN PROGRESS]` phase updates are actually implemented or just documented

## Summary

The first research report (research-001.md) claimed that implementation agents already update phase status to `[IN PROGRESS]` before starting work. However, investigation reveals a **critical gap**: the agent documentation describes this behavior in natural language instructions but does NOT provide executable Edit tool invocation patterns. Agents are told to "Edit plan file: Change phase status to `[IN PROGRESS]`" but this is descriptive prose, not an actionable tool call example. There is no concrete Edit tool invocation shown anywhere in the agent definitions.

## Key Findings

### Finding 1: Documentation vs Implementation Gap

**What research-001.md claimed**:
> "Current behavior IS correct - phases are marked `[IN PROGRESS]` before work"

**What actually exists**:
The agent definitions contain **instructions** like:
```markdown
**A. Mark Phase In Progress**
Edit plan file: Change phase status to `[IN PROGRESS]`
```

This is **natural language direction**, not an executable pattern. Contrast with skill files which contain actual bash commands:
```bash
sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
```

### Finding 2: What Gets Updated vs What Doesn't

| Component | What It Updates | How |
|-----------|----------------|-----|
| Skills (postflight) | Plan **header** status (`- **Status**: [...]`) | `sed` command |
| Skills (postflight) | TODO.md task status | Edit tool |
| Skills (postflight) | state.json status | jq command |
| Agents | Phase status (`### Phase N: Name [STATUS]`) | **Natural language instruction only** |

The skills update the **plan header** (`- **Status**: [IMPLEMENTING]` -> `[PARTIAL]` -> `[COMPLETED]`).
The agents are **instructed** to update **individual phase markers** (`### Phase 1: Name [NOT STARTED]` -> `[IN PROGRESS]` -> `[COMPLETED]`) but no concrete example is provided.

### Finding 3: Evidence from Plan File Structure

Looking at `specs/892_modify_henkinstep_add_negations/plans/implementation-002.md`:
```markdown
- **Status**: [BLOCKED]  <- This is updated by skills via sed

### Phase 1: Modify henkinStep with negation fallback [COMPLETED]  <- This needs agent update
```

The skill's `sed` command matches: `s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/`
This regex targets the **header** line (`- **Status**: [...]`), NOT the phase headers (`### Phase N: Name [STATUS]`).

### Finding 4: Missing Edit Tool Example

The agent definitions say:
1. "Edit plan file: Change phase status to `[IN PROGRESS]`" (line 139 in general-implementation-agent.md)
2. "Update phase status to `[IN PROGRESS]` in plan file" (line 344, Phase Checkpoint Protocol)

But nowhere is there an example like:
```
Edit tool:
  file_path: specs/{N}_{SLUG}/plans/implementation-{NNN}.md
  old_string: "### Phase 1: {name} [NOT STARTED]"
  new_string: "### Phase 1: {name} [IN PROGRESS]"
```

### Finding 5: Why Screenshot Shows Direct NOT STARTED -> PARTIAL

The user observed:
- Plan header: Updated to `[IMPLEMENTING]` correctly
- Phase 2: Went from `[NOT STARTED]` directly to `[PARTIAL]`

This happened because:
1. Skill preflight updated header to `[IMPLEMENTING]` (works - has sed command)
2. Agent **skipped** marking phase as `[IN PROGRESS]` (no concrete instruction)
3. Agent failed/timed out, returned partial status
4. Skill postflight updated header to `[PARTIAL]` (works - has sed command)
5. Agent wrote `[PARTIAL]` to phase in Error Handling path but never wrote `[IN PROGRESS]`

The `[IN PROGRESS]` step was **documented but not executed** because the agent lacks a concrete Edit pattern.

## Analysis: What Needs to Change

### Root Cause

The agent definitions use **abstract instructions** ("Edit plan file: Change phase status") rather than **concrete tool invocation examples**. Claude Code agents interpret natural language instructions, but the Edit tool requires precise `old_string`/`new_string` patterns. Without an explicit example, agents may:
- Skip the step entirely
- Use incorrect patterns
- Fail silently

### Locations Requiring Concrete Edit Examples

1. **`.claude/agents/general-implementation-agent.md`** - Stage 4A needs explicit Edit example
2. **`.claude/agents/lean-implementation-agent.md`** - Delegates to flow file
3. **`.claude/context/project/lean4/agents/lean-implementation-flow.md`** - Stage 4A needs explicit Edit example
4. **`.claude/agents/latex-implementation-agent.md`** - Stage 4A needs explicit Edit example
5. **`.claude/agents/typst-implementation-agent.md`** - Stage 4A needs explicit Edit example

### Recommended Fix Pattern

Add explicit Edit tool example to Stage 4A:

```markdown
**A. Mark Phase In Progress**

Use the Edit tool to update the current phase's status marker:

```
Edit tool invocation:
  file_path: {plan_path}
  old_string: "### Phase {N}: {phase_name} [NOT STARTED]"
  new_string: "### Phase {N}: {phase_name} [IN PROGRESS]"
```

**Important**: Match the exact phase name and number from the plan file.
```

Similarly for Stage 4D (Mark Phase Complete) and error paths.

## Verification: Code Path for [PARTIAL]

**Question**: When the screenshot shows Phase 2 as `[PARTIAL]`, what code path wrote that?

**Answer**: Two possibilities:

1. **Agent wrote it in error handling** - The agent documentation says:
   > "Mark current phase `[PARTIAL]` in plan" (line 470, Error Handling - Timeout/Interruption)

   This is also abstract instruction. If the agent executed this, it used its own interpretation.

2. **Skill postflight wrote the header** - The skill has:
   ```bash
   sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
   ```

   But this updates the **header**, not the phase marker.

Most likely: The agent **did** update the phase to `[PARTIAL]` using an improvised Edit, but **skipped** the `[IN PROGRESS]` step because it wasn't emphasized as strongly.

## Corrected Analysis from research-001.md

| Claim in research-001.md | Reality |
|--------------------------|---------|
| "Current behavior already includes updating phases to `[IN PROGRESS]`" | Documented but not concretely implemented |
| "This happens within the implementation agent's Phase Checkpoint Protocol" | Protocol mentions it but provides no tool example |
| "Gap: Error paths don't explicitly handle `[PARTIAL]`" | Gap is broader: ALL paths lack explicit Edit examples |

## Recommendations

### Priority 1: Add Concrete Edit Examples to Agent Definitions

In each implementation agent, add explicit Edit tool patterns for:
- Stage 4A: `[NOT STARTED]` -> `[IN PROGRESS]`
- Stage 4D: `[IN PROGRESS]` -> `[COMPLETED]`
- Error paths: `[IN PROGRESS]` -> `[PARTIAL]` or `[BLOCKED]`

### Priority 2: Update Phase Checkpoint Protocol

The numbered list in Phase Checkpoint Protocol should include explicit tool calls, not just instructions:

```markdown
2. **Update phase status** to `[IN PROGRESS]` in plan file
   ```
   Edit:
     file_path: {plan_path}
     old_string: "### Phase {N}: {phase_name} [NOT STARTED]"
     new_string: "### Phase {N}: {phase_name} [IN PROGRESS]"
   ```
```

### Priority 3: Consider Regex Pattern for Edit

Since phase names vary, consider documenting a search strategy:
1. Read plan file
2. Find line matching `### Phase {N}:` where N is current phase number
3. Extract exact phase name
4. Use Edit with precise old_string including status marker

## Appendix: Search Evidence

### Grep for Edit invocations
No concrete Edit tool examples found for phase status updates:
- Skills use `sed` for header status
- Agents use natural language for phase status

### Grep for sed commands
All sed commands in skills target the **header** format (`^\- \*\*Status\*\*:`), not phase headers (`### Phase`).

## Next Steps

1. Update implementation plan (v002) to add concrete Edit examples to all agent definitions
2. Focus on Phase Checkpoint Protocol section where status updates are enumerated
3. Test that agents actually execute the Edit commands after changes

## References

- `.claude/agents/general-implementation-agent.md` - Lines 138-167 (Stage 4)
- `.claude/agents/lean-implementation-agent.md` - Delegates to flow file
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Lines 59-108 (Stage 4)
- `.claude/skills/skill-implementer/SKILL.md` - Lines 411-417 (sed for header)
- `specs/892_modify_henkinstep_add_negations/plans/implementation-002.md` - Example plan file structure
