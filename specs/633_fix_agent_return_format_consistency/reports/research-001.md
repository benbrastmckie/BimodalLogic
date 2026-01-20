# Research Report: Task #633

**Task**: 633 - fix_agent_return_format_consistency
**Started**: 2026-01-19T12:00:00Z
**Completed**: 2026-01-19T12:30:00Z
**Effort**: Medium
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- Codebase analysis of .claude/agents/*.md files
- `.claude/context/core/formats/return-metadata-file.md`
- `.claude/context/core/formats/subagent-return.md`
- `.claude/skills/skill-implementer/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`
**Artifacts**:
- This report: specs/633_fix_agent_return_format_consistency/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- latex-implementation-agent.md contains contradictory return format instructions: v2 file-based metadata in Stages 7-8 but legacy v1 JSON console output in "Return Format Examples" and "Critical Requirements" sections
- The contradiction causes the agent to dump JSON to console (triggering "continue" prompts) instead of writing to .return-meta.json
- Other agents (lean-implementation-agent, general-research-agent) correctly implement v2 pattern consistently throughout
- general-implementation-agent.md ALSO has v1 legacy pattern and needs the same fix
- Recommended fix: Update both agents' "Return Format Examples" and "Critical Requirements" sections to match v2 file-based pattern

## Context & Scope

### Problem Statement

The task description identifies that latex-implementation-agent.md has contradictory return format instructions that cause JSON to be dumped to console instead of being written to the .return-meta.json file. This causes workflow interruption requiring user "continue" input.

### Research Scope

1. Identify the specific contradictions in latex-implementation-agent.md
2. Understand the v2 file-based metadata pattern
3. Compare with correctly-implemented agents
4. Identify patterns for postflight validation
5. Document the fix requirements

## Findings

### 1. Contradiction in latex-implementation-agent.md

The agent file contains TWO different return format patterns:

**V2 Pattern (Correct) - Stages 7-8 (Lines 210-267):**
```markdown
### Stage 7: Write Metadata File

**CRITICAL**: Write metadata to the specified file path, NOT to console.

Write to `specs/{N}_{SLUG}/.return-meta.json`:
[...JSON schema...]

Use the Write tool to create this file.

### Stage 8: Return Brief Text Summary

**CRITICAL**: Return a brief text summary (3-6 bullet points), NOT JSON.
...
**DO NOT return JSON to the console**. The skill reads metadata from the file.
```

**V1 Pattern (Outdated/Contradictory) - Return Format Examples (Lines 384-497):**
```markdown
## Return Format Examples

### Successful Implementation

```json
{
  "status": "implemented",
  ...full JSON structure dumped to console...
}
```
```

**V1 Pattern (Outdated/Contradictory) - Critical Requirements (Lines 500-522):**
```markdown
## Critical Requirements

**MUST DO**:
1. Always return valid JSON (not markdown narrative)  <-- CONTRADICTS Stage 8
...
**MUST NOT**:
1. Return plain text instead of JSON  <-- DIRECTLY CONTRADICTS Stage 8
```

The "Return Format Examples" section shows JSON being returned to console, and "Critical Requirements" explicitly says "Always return valid JSON" and "MUST NOT return plain text" - both directly contradicting the correct Stage 7-8 instructions.

### 2. V2 File-Based Metadata Pattern (Correct Pattern)

From `return-metadata-file.md` and `subagent-return.md`:

1. **Agent writes** metadata to `specs/{N}_{SLUG}/.return-meta.json` using the Write tool
2. **Agent returns** brief text summary (3-6 bullets) to console
3. **Skill reads** metadata file during postflight operations
4. **Skill handles** status updates, artifact linking, git commits
5. **Skill deletes** metadata file after processing

Key quote from `subagent-return.md`:
> **v2 Pattern (Current)**:
> 1. Agents write structured metadata to `specs/{N}_{SLUG}/.return-meta.json`
> 2. Agents return brief text summaries (3-6 bullets) to console
> 3. Skills read metadata file during postflight

### 3. Correctly-Implemented Agents (Reference Implementations)

**lean-implementation-agent.md** (Lines 203-254):
- Has Stage 7 "Write Metadata File" with explicit file write instructions
- Has Stage 8 "Return Brief Text Summary"
- Return Format Examples section shows TEXT summaries, not JSON:
```markdown
### Successful Implementation (Text Summary)

```
Lean implementation completed for task 259:
- All 3 phases executed, completeness theorem proven with 4 lemmas
- Lake build: Success
...
```
```
- Critical Requirements section says:
  - "Always write metadata to `specs/{N}_{SLUG}/.return-meta.json`"
  - "Always return brief text summary (3-6 bullets), NOT JSON"
  - "MUST NOT: Return JSON to the console"

**general-research-agent.md** (Correctly implemented - same v2 pattern)

### 4. Second Agent with Same Issue

**general-implementation-agent.md** (Lines 170-449):
- Has Stage 7 "Return Structured JSON" - this is the V1 pattern!
- Return Format Examples show JSON output to console
- Critical Requirements say "Always return valid JSON"
- This agent ALSO needs to be fixed to match v2 pattern

### 5. Skill Postflight Validation Patterns

From `skill-implementer/SKILL.md` (Stage 6):
```bash
metadata_file="specs/${task_number}_${project_name}/.return-meta.json"

if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    ...
else
    echo "Error: Invalid or missing metadata file"
    status="failed"
fi
```

The skill already validates:
1. File exists
2. File is valid JSON (via `jq empty`)

**Missing validation**: No check for accidental JSON console output.

### 6. Potential JSON Console Output Detection

A simple validation could detect if the subagent's text return looks like JSON:

```bash
# After receiving subagent text return
subagent_return="$(...)"

# Check if return starts with JSON indicators
if echo "$subagent_return" | head -c 1 | grep -q '[{[]'; then
    echo "Warning: Subagent appears to have returned JSON to console instead of text summary"
    echo "This may indicate outdated agent instructions. Check agent's Return Format section."
fi
```

Or more robust:
```bash
# Check if the return is valid JSON (it shouldn't be)
if echo "$subagent_return" | jq empty 2>/dev/null; then
    echo "Error: Subagent returned JSON to console. Expected text summary."
    echo "Agent may have outdated v1 return format instructions."
fi
```

## Decisions

Based on this research:

1. **Fix latex-implementation-agent.md**: Replace "Return Format Examples" section with text summary examples (matching lean-implementation-agent.md pattern). Update "Critical Requirements" to specify file-based metadata pattern.

2. **Fix general-implementation-agent.md**: Same fix - update Stage 7, Return Format Examples, and Critical Requirements to match v2 pattern.

3. **Add postflight validation**: Add a simple check in skill postflight to detect if subagent accidentally returned JSON to console instead of text summary.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing agent behavior | Low | Medium | Both agents already have correct Stage 7-8; fix just removes contradictions |
| Validation false positives | Low | Low | Only check if return starts with `{` or `[` AND parses as JSON |
| Missing edge cases | Medium | Low | Text summaries starting with bullet points won't trigger false positive |

## Implementation Recommendations

### Phase 1: Fix latex-implementation-agent.md

1. **Line 384-498**: Replace "Return Format Examples" section - change JSON examples to text summary examples
2. **Lines 502-522**: Update "Critical Requirements" section:
   - Change "Always return valid JSON" to "Always write metadata to `specs/{N}_{SLUG}/.return-meta.json`"
   - Change "MUST NOT return plain text" to "MUST NOT return JSON to console"

### Phase 2: Fix general-implementation-agent.md

1. **Lines 170-200**: Change Stage 7 from "Return Structured JSON" to "Write Metadata File" + "Return Brief Text Summary"
2. **Lines 328-426**: Replace "Return Format Examples" section with text summary examples
3. **Lines 428-449**: Update "Critical Requirements" to match v2 pattern

### Phase 3: Add Postflight Validation

In `.claude/skills/skill-implementer/SKILL.md` and `.claude/skills/skill-latex-implementation/SKILL.md`, add after Stage 5 (Invoke Subagent):

```markdown
### Stage 5a: Validate Subagent Return Format

After subagent returns, verify it returned text (not JSON):

\`\`\`bash
# If subagent return parses as valid JSON, warn about format issue
if echo "$subagent_return" | jq empty 2>/dev/null; then
    echo "WARNING: Subagent returned JSON to console instead of text summary"
    echo "This indicates the agent has outdated v1 return format instructions"
    # Continue processing - try to read metadata file anyway
fi
\`\`\`
```

## Appendix

### Search Queries Used

1. Glob: `.claude/agents/*.md` - Found 8 agent files
2. Read: latex-implementation-agent.md - Identified contradictions
3. Read: lean-implementation-agent.md - Found correct v2 implementation
4. Read: general-implementation-agent.md - Found second agent with v1 pattern
5. Read: return-metadata-file.md - Understood v2 schema
6. Read: subagent-return.md - Understood v1 vs v2 evolution
7. Read: skill-implementer/SKILL.md - Understood postflight validation
8. Read: postflight-control.md - Understood marker file protocol

### Files Requiring Changes

| File | Change Type | Priority |
|------|-------------|----------|
| `.claude/agents/latex-implementation-agent.md` | Update Return Format Examples + Critical Requirements | High |
| `.claude/agents/general-implementation-agent.md` | Update Stage 7 + Return Format Examples + Critical Requirements | High |
| `.claude/skills/skill-implementer/SKILL.md` | Add postflight validation | Medium |
| `.claude/skills/skill-latex-implementation/SKILL.md` | Add postflight validation | Medium |

### Reference Patterns

**Correct Return Format Examples (from lean-implementation-agent.md):**
```markdown
## Return Format Examples

### Successful Implementation (Text Summary)

```
Lean implementation completed for task 259:
- All 3 phases executed, completeness theorem proven with 4 lemmas
- Lake build: Success
- Key theorems: completeness_main, soundness_lemma, modal_truth
- Created summary at specs/259_completeness/summaries/implementation-summary-20260118.md
- Metadata written for skill postflight
```

### Partial Implementation (Text Summary)

```
Lean implementation partially completed for task 259:
- Phases 1-2 of 3 executed successfully
- Phase 3 stuck: induction case requires List.mem_append lemma
- Goal state documented in summary
- Partial summary at specs/259_completeness/summaries/implementation-summary-20260118.md
- Metadata written with partial status
- Recommend: Search Mathlib for missing lemma, then resume
```
```

**Correct Critical Requirements (from lean-implementation-agent.md):**
```markdown
## Critical Requirements

**MUST DO**:
1. Always write metadata to `specs/{N}_{SLUG}/.return-meta.json`
2. Always return brief text summary (3-6 bullets), NOT JSON
3. Always include session_id from delegation context in metadata
...

**MUST NOT**:
1. Return JSON to the console (skill cannot parse it reliably)
...
```
