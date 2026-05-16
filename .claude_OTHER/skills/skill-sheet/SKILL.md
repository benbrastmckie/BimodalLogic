---
name: skill-sheet
description: XLSX creation, editing, and analysis routing to sheet-agent
allowed-tools: Agent
---

# XLSX Skill

Thin wrapper that routes XLSX creation, editing, and analysis requests to the `sheet-agent`, which manipulates spreadsheets using openpyxl and pandas via Bash.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/formats/subagent-return.md`
- Purpose: Return validation
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:

### Direct Invocation
- User explicitly runs `/sheet` command
- User runs `/edit` command with a .xlsx file

### Implicit Invocation (during task implementation)

When an implementing agent encounters any of these patterns:

**Plan step language patterns**:
- "Create spreadsheet [file].xlsx with [content]"
- "Create xlsx [file] with [columns/data]"
- "Edit [file].xlsx to [change]"
- "Edit spreadsheet [file] to [change]"
- "Add formulas to [file].xlsx"
- "Add formatting to [file].xlsx"
- "Update [file].xlsx with [data]"
- "Analyze [file].xlsx for [purpose]"

**File extension detection**:
- Target file has extension: `.xlsx`, `.xlsm`
- Operation type: create, edit, update, modify, analyze, add formulas, add formatting

**Task description keywords**:
- "XLSX creation"
- "spreadsheet creation"
- "xlsx editing"
- "spreadsheet editing"
- "add formulas"
- "add formatting"
- "xlsx analysis"

### When NOT to Trigger

Do not invoke for:
- Spreadsheet-to-table conversion (use skill-filetypes-spreadsheet for /table)
- Simple CSV/TSV reading (use Read tool directly)
- Grant budget creation (use skill-budget for /budget)
- PDF/DOCX operations (use other filetypes skills)
- Presentation operations (use skill-presentation)

---

## Execution

### 1. Input Validation

Validate required inputs:
- `file_path` - Must be provided; for edit/analyze must exist; for create mode may not exist yet
- `instruction` - Natural language instruction describing the desired operation (required)
- `mode` - One of: "create", "edit", "analyze" (inferred from context and file existence)

```bash
# For edit mode: validate source exists and is xlsx/xlsm
if [ "$mode" = "edit" ]; then
  if [ ! -f "$file_path" ]; then
    return error "XLSX file not found: $file_path"
  fi
  if [[ "${file_path##*.}" != "xlsx" && "${file_path##*.}" != "xlsm" ]]; then
    return error "Source must be a .xlsx or .xlsm file: $file_path"
  fi
fi

# For analyze mode: validate source exists
if [ "$mode" = "analyze" ]; then
  if [ ! -f "$file_path" ]; then
    return error "File not found for analysis: $file_path"
  fi
fi

# For create mode: validate xlsx extension
if [ "$mode" = "create" ]; then
  if [[ "${file_path##*.}" != "xlsx" && "${file_path##*.}" != "xlsm" ]]; then
    return error "New file must have .xlsx or .xlsm extension: $file_path"
  fi
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "file_path": "/absolute/path/to/spreadsheet.xlsx",
  "instruction": "Create a budget tracking spreadsheet with categories, monthly columns, and SUM formulas",
  "mode": "create",
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "xlsx", "skill-sheet"]
  }
}
```

### 3. Invoke Agent

**CRITICAL**: You MUST use the **Agent** tool to spawn the sheet-agent.

**Required Tool Invocation**:
```
Tool: Agent (NOT Skill, NOT Plan)
Parameters:
  - subagent_type: "sheet-agent"
  - prompt: [Include file_path, instruction, mode, metadata]
  - description: "{mode} {file_path}: {instruction}"
```

**DO NOT** use `Skill(sheet-agent)` - this will FAIL.
Agents live in `.claude/agents/` or extension agent directories, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The agent will:
- Detect available tools (openpyxl, pandas)
- Execute the requested operation (create, edit, or analyze)
- Validate the output file
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: created, edited, analyzed, partial, failed
- Summary is non-empty and <100 tokens
- Artifacts array present with output file path
- Metadata contains session_id, agent_type, delegation info

**Status value rules**:
- `created` - New file successfully created
- `edited` - Existing file successfully modified
- `analyzed` - File read and analysis returned
- `partial` - Some operations succeeded, others failed
- `failed` - No operations applied, error occurred
- NEVER use "completed" (triggers Claude stop behavior)

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "created",
  "summary": "Created budget.xlsx with 4 category rows, monthly columns Jan-Dec, SUM formulas for totals, and currency formatting.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "/absolute/path/to/budget.xlsx",
      "summary": "XLSX workbook with formulas and formatting"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "sheet-agent",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "xlsx", "skill-sheet", "sheet-agent"],
    "tool_used": "openpyxl",
    "mode": "create",
    "sheets": 1,
    "rows": 6,
    "columns": 14
  },
  "next_steps": "Open spreadsheet to verify formulas and formatting"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if file not found, not a .xlsx/.xlsm, or instruction is empty.

### Unsupported Format
Return failed status if file extension is not .xlsx or .xlsm (for create/edit). Suggest using /convert or /table for other spreadsheet operations.

### Agent Errors
Pass through the agent's error return verbatim.

### Tool Not Available
Return failed status with installation instructions for openpyxl and pandas.

---

## MUST NOT

- Run the postflight step (git commit, status update) -- that is the command's responsibility
- Modify the return from sheet-agent before propagating
- Load context files eagerly -- only reference them when needed
- Use the Skill tool to invoke sheet-agent (use Agent tool instead)
