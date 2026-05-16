---
name: skill-docx-edit
description: In-place DOCX editing routing to docx-edit-agent
allowed-tools: Agent
---

# DOCX Edit Skill

Thin wrapper that routes in-place DOCX editing requests to the `docx-edit-agent`, which edits documents using SuperDoc MCP with optional Word AppleScript integration for zero-friction workflow.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/formats/subagent-return.md`
- Purpose: Return validation
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:

### Direct Invocation
- User explicitly runs `/edit` command with a .docx file
- User requests document editing in conversation

### Implicit Invocation (during task implementation)

When an implementing agent encounters any of these patterns:

**Plan step language patterns**:
- "Edit [file].docx to [change]"
- "Replace [text] with [text] in [file].docx"
- "Update the Word document [file]"
- "Add tracked changes to [file].docx"
- "Modify [file].docx with [instruction]"
- "Create a new document [file].docx"

**File extension detection**:
- Target file has extension: `.docx`
- Operation type: edit, replace, update, modify, create

**Task description keywords**:
- "DOCX editing"
- "Word document editing"
- "tracked changes"
- "in-place document edit"

### When NOT to Trigger

Do not invoke for:
- Non-DOCX files (.xlsx, .pptx, .pdf, etc.)
- Document conversion (use skill-filetypes for /convert)
- PDF annotation extraction (use skill-scrape for /scrape)
- Spreadsheet table extraction (use skill-spreadsheet for /table)
- Reading document content without editing (use markitdown or /convert)

---

## Execution

### 1. Input Validation

Validate required inputs:
- `file_path` - Must be provided; for edit/batch must exist; for create mode may not exist yet
- `instruction` - Natural language editing instruction (required)
- `mode` - One of: "edit", "batch", "create" (inferred from file_path and flags)

```bash
# For edit mode: validate source exists and is .docx
if [ "$mode" = "edit" ]; then
  if [ ! -f "$file_path" ]; then
    return error "DOCX file not found: $file_path"
  fi
  if [[ "${file_path##*.}" != "docx" ]]; then
    return error "Source must be a .docx file: $file_path"
  fi
fi

# For batch mode: validate directory exists
if [ "$mode" = "batch" ]; then
  if [ ! -d "$file_path" ]; then
    return error "Directory not found: $file_path"
  fi
fi

# For create mode: validate .docx extension
if [ "$mode" = "create" ]; then
  if [[ "${file_path##*.}" != "docx" ]]; then
    return error "New file must have .docx extension: $file_path"
  fi
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "file_path": "/absolute/path/to/document.docx",
  "instruction": "Replace ACME Corp with NewCo Inc. using tracked changes",
  "mode": "edit",
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "edit", "skill-docx-edit"]
  }
}
```

### 3. Invoke Agent

**CRITICAL**: You MUST use the **Agent** tool to spawn the docx-edit agent.

**Required Tool Invocation**:
```
Tool: Agent (NOT Skill, NOT Plan)
Parameters:
  - subagent_type: "docx-edit-agent"
  - prompt: [Include file_path, instruction, mode, metadata]
  - description: "Edit {file_path}: {instruction}"
```

**DO NOT** use `Skill(docx-edit-agent)` - this will FAIL.
Agents live in `.claude/agents/` or extension agent directories, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The agent will:
- Check if Word has the file open (macOS only)
- Save partner's unsaved work if needed (macOS only)
- Perform SuperDoc editing operations
- Reload the document in Word if it was open (macOS only)
- Confirm edit results
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: edited, created, partial, failed
- Summary is non-empty and <100 tokens
- Artifacts array present with output file path
- Metadata contains session_id, agent_type, delegation info

**Status value rules**:
- `edited` - File successfully modified in place
- `created` - New file successfully created
- `partial` - Some edits applied, others failed (batch mode)
- `failed` - No edits applied, error occurred
- NEVER use "completed" (triggers Claude stop behavior)

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "edited",
  "summary": "Replaced 3 instances of 'ACME Corp' with 'NewCo Inc.' in contract.docx with tracked changes (author: Claude)",
  "artifacts": [
    {
      "type": "implementation",
      "path": "/absolute/path/to/contract.docx",
      "summary": "Edited DOCX with tracked changes"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "docx-edit-agent",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "edit", "skill-docx-edit", "docx-edit-agent"],
    "tool_used": "superdoc",
    "changes_count": 3,
    "tracked_changes": true,
    "word_was_open": true,
    "word_reloaded": true
  },
  "next_steps": "Review tracked changes in Word"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if file not found, not a .docx, or instruction is empty.

### Agent Errors
Pass through the agent's error return verbatim.

### Tool Not Available
Return failed status with installation instructions for SuperDoc MCP or python-docx.

---

## MUST NOT

- Run the postflight step (git commit, status update) -- that is the command's responsibility
- Modify the return from docx-edit-agent before propagating
- Load context files eagerly -- only reference them when needed
- Use the Skill tool to invoke docx-edit-agent (use Agent tool instead)
