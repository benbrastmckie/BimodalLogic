# Research Report: Task #475

**Task**: Create skill-document-converter thin wrapper
**Date**: 2026-01-17
**Focus**: Understand existing thin wrapper patterns and document-converter-agent requirements
**Session ID**: sess_1768683122_b7c6aa

## Summary

Research into ProofChecker's thin wrapper skill pattern reveals a well-established 5-step delegation model used by 10+ existing skills. The document-converter skill should follow this pattern exactly: validate inputs, prepare delegation context, invoke document-converter-agent via Task tool, validate JSON return, and propagate results. Key insight from Logos project's failed conversion attempt: external script dependencies and pip installation during conversion cause reliability issues. The ProofChecker implementation must embed all logic within the agent, not rely on external shell scripts.

## Findings

### 1. Thin Wrapper Skill Pattern (Established in ProofChecker)

All forked skills in ProofChecker follow an identical structure:

**Frontmatter Requirements**:
```yaml
---
name: skill-{name}
description: {Brief description}
allowed-tools: Task
context: fork
agent: {agent-name}
# Original context (now loaded by subagent):
#   - {context files}
# Original tools (now used by subagent):
#   - {tools list}
---
```

**Key Fields**:
- `allowed-tools: Task` - Only tool needed for delegation (NOT actual conversion tools)
- `context: fork` - Signals lazy context loading (subagent loads its own)
- `agent: {name}` - Target agent name (must exist in `.claude/agents/`)

**5-Step Execution Flow** (from thin-wrapper-skill.md):
1. **Input Validation** - Validate arguments, check task exists if task-bound
2. **Context Preparation** - Build delegation JSON with session_id
3. **Invoke Subagent** - Use Task tool (NOT Skill tool)
4. **Return Validation** - Verify JSON matches subagent-return.md schema
5. **Return Propagation** - Pass result through without modification

### 2. Existing Thin Wrapper Skills Examined

| Skill | Agent | Purpose | Timeout |
|-------|-------|---------|---------|
| skill-researcher | general-research-agent | General research | 3600s |
| skill-planner | planner-agent | Plan creation | 1800s |
| skill-implementer | general-implementation-agent | File implementation | N/A |
| skill-status-sync | status-sync-agent | State updates | 60s |
| skill-lean-research | lean-research-agent | Lean 4 research | N/A |

All follow the same pattern with only differences in:
- Agent name
- Trigger conditions
- Context references
- Timeout values

### 3. Issues from Logos document-converter (To Avoid)

The `/home/benjamin/Projects/Logos/.claude/outputs/convert.md` failure log reveals critical issues:

**Issue 1: External Script Dependencies**
```bash
source /home/benjamin/.config/.claude/lib/convert/convert-core.sh
# ERROR: No such file or directory
```
The Logos skill relied on external shell scripts in `~/.config/.claude/lib/convert/` that may not exist in the deployment environment.

**Issue 2: Pip Installation During Conversion**
The output shows 98 lines of pip installation output mixed with conversion results:
```
Setting up markitdown virtual environment...
Successfully installed markitdown-0.1.4 ...
```
This happens because the skill tried to auto-install tools on first run, causing output contamination and conversion failures.

**Issue 3: Model Specification Issues**
```
API Error: 404 {"type":"error","error":{"type":"not_found_error",
"message":"model: haiku-4.5"}}
```
Model specification in frontmatter (`model: haiku-4.5`) was invalid. ProofChecker skills don't specify models - they use the parent conversation's model.

**Issue 4: Heavy Inline Logic**
The Logos SKILL.md file is 370+ lines of conversion logic, tool detection, and workflow. ProofChecker thin wrappers are 100-160 lines max.

### 4. Subagent Return Format Requirements

From `subagent-return.md`, all agents must return:
```json
{
  "status": "converted|partial|failed",  // Contextual, not "completed"
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "implementation",
      "path": "path/to/output.md",
      "summary": "Converted document"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "document-converter-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "convert", "document-converter-agent"]
  },
  "errors": [...],  // If any
  "next_steps": "..."
}
```

**Anti-Stop Pattern**: Do NOT use `"status": "completed"` - use contextual values like `"converted"`, `"extracted"`, etc.

### 5. Agent Registration Requirements

From CLAUDE.md:
> Custom agents in `.claude/agents/` **require YAML frontmatter** to be recognized by Claude Code

Agent file MUST have:
```yaml
---
name: document-converter-agent
description: Convert documents between Markdown, DOCX, and PDF formats
---
```

Without frontmatter, agent won't be invokable.

### 6. Tool Detection Strategy (For Agent, Not Skill)

The document-converter-agent (Task 476) should handle tool detection, NOT the skill. Strategy:

**Detection via Bash in agent**:
```bash
# Check tool availability (within agent execution)
command -v markitdown && echo "markitdown available"
command -v pandoc && echo "pandoc available"
python3 -c "import pymupdf4llm" 2>/dev/null && echo "pymupdf4llm available"
```

**Fallback Chain**:
1. **PDF to Markdown**: markitdown > pandoc > Claude native Read (PDF reading)
2. **DOCX to Markdown**: markitdown > pandoc
3. **Markdown to PDF**: pandoc + typst > pandoc + xelatex
4. **Markdown to DOCX**: pandoc

### 7. Skill vs Agent Responsibility Division

| Responsibility | skill-document-converter | document-converter-agent |
|----------------|--------------------------|--------------------------|
| Input validation | Simple: file exists check | Thorough: file type, size |
| Tool detection | None | Full detection with fallbacks |
| Conversion logic | None | All conversion execution |
| Error handling | Pass-through | Full error capture/recovery |
| Context loading | None (fork) | Load as needed |
| Return format | Pass-through | Generate JSON |

## Recommendations

### 1. Create Minimal Thin Wrapper

skill-document-converter should be ~100 lines following the exact pattern of skill-researcher:

**Structure**:
```markdown
---
name: skill-document-converter
description: Convert documents between formats. Invoke for PDF/DOCX/Markdown conversion.
allowed-tools: Task
context: fork
agent: document-converter-agent
# Original tools (now used by subagent):
#   - Read, Write, Bash
---

# Document Converter Skill

Thin wrapper that delegates document conversion to `document-converter-agent` subagent.

## Trigger Conditions
- User requests document conversion
- PDF/DOCX to Markdown extraction needed
- Markdown to PDF/DOCX generation needed

## Execution

### 1. Input Validation
[Validate source_path and output_path arguments]

### 2. Context Preparation
[Build delegation context JSON]

### 3. Invoke Subagent
**CRITICAL**: Use Task tool to spawn document-converter-agent

### 4. Return Validation
[Validate return matches subagent-return.md]

### 5. Return Propagation
[Pass through result]

## Return Format
[Document expected returns]

## Error Handling
[Document error cases]
```

### 2. Do NOT Include in Skill

- Tool detection logic (agent's job)
- Conversion commands (agent's job)
- Model specification (parent controls)
- External script sourcing (not reliable)
- Pip installation logic (causes contamination)

### 3. Use Contextual Status Values

For document conversion, appropriate status values:
- `"converted"` - Successful conversion
- `"extracted"` - Text extraction succeeded
- `"partial"` - Some files converted, others failed
- `"failed"` - Conversion failed

### 4. Handle Both Task-Bound and Standalone Invocation

Unlike most skills that are task-bound (require task_number), document-converter can be standalone. Skill should support:
- Standalone: `source_path`, `output_path`, `format` arguments
- Task-bound (optional): `task_number` for integration with workflow

## Dependencies

- Task 476: Create document-converter-agent (dependency for this skill)
  - This task is blocked until 476 is complete
  - However, skill can be created with placeholder agent reference

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agent not yet created | Skill invocation fails | Create agent first (Task 476) OR create skill as placeholder |
| Model errors | 404 errors like Logos | Don't specify model in skill frontmatter |
| Tool unavailability | Conversion fails | Agent should fall back to Claude native reading |
| Large file timeout | Conversion hangs | Agent should set appropriate timeouts (300s for PDF) |

## References

- `/home/benjamin/Projects/ProofChecker/.claude/context/core/templates/thin-wrapper-skill.md` - Template
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/formats/subagent-return.md` - Return format
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-researcher/SKILL.md` - Reference implementation
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-status-sync/SKILL.md` - Recent implementation
- `/home/benjamin/Projects/Logos/.claude/skills/document-converter/SKILL.md` - Inspiration (but avoid issues)
- `/home/benjamin/Projects/Logos/.claude/outputs/convert.md` - Failure log (issues to avoid)

## Next Steps

1. Run `/plan 475` to create implementation plan
2. Create minimal thin wrapper skill following template
3. Ensure document-converter-agent exists (Task 476) before testing
4. Test with simple PDF/DOCX conversion

## Appendix: File Paths for Implementation

**Skill Location**: `.claude/skills/skill-document-converter/SKILL.md`
**Agent Location**: `.claude/agents/document-converter-agent.md`
**Template Reference**: `.claude/context/core/templates/thin-wrapper-skill.md`
