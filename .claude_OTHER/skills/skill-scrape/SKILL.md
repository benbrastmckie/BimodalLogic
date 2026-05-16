---
name: skill-scrape
description: PDF annotation extraction routing to scrape-agent
allowed-tools: Agent
---

# Scrape Skill

Thin wrapper that routes PDF annotation extraction to the `scrape-agent`, which extracts highlights, comments, notes, and other annotations from PDF files.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/formats/subagent-return.md`
- Purpose: Return validation
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:

### Direct Invocation
- User explicitly runs `/scrape` command
- User requests annotation extraction in conversation

### Implicit Invocation (during task implementation)

When an implementing agent encounters any of these patterns:

**Plan step language patterns**:
- "Extract annotations from [file].pdf"
- "Extract highlights from [file].pdf"
- "Extract comments from [file]"
- "Scrape notes from [file].pdf"
- "Collect annotations in [file]"
- "Export PDF comments to markdown"
- "Gather highlights and notes from [file]"

**File extension detection**:
- Source file has extension: `.pdf`
- Target mentions: "annotations", "highlights", "comments", "notes"

**Task description keywords**:
- "annotation extraction"
- "PDF scraping"
- "extract highlights"
- "collect comments"
- "gather notes from PDF"

### When NOT to Trigger

Do not invoke for:
- Non-PDF files (.docx, .html, .txt, etc.)
- General document conversion (use skill-filetypes)
- Reading PDF text content without annotation context (use skill-filetypes)
- Operations on spreadsheets or presentations (use skill-spreadsheet, skill-presentation)

---

## Execution

### 1. Input Validation

Validate required inputs:
- `pdf_path` - Must be provided, must exist, must be a .pdf file
- `output_path` - Optional, defaults to `{basename}_annotations.md` in same directory
- `annotation_types` - Optional array, defaults to all types
- `output_format` - Optional, defaults to "markdown"

```bash
# Validate source exists
if [ ! -f "$pdf_path" ]; then
  return error "PDF file not found: $pdf_path"
fi

# Validate source is a PDF
if [[ "${pdf_path##*.}" != "pdf" ]]; then
  return error "Source must be a .pdf file: $pdf_path"
fi

# Determine output path if not provided
if [ -z "$output_path" ]; then
  source_dir=$(dirname "$pdf_path")
  source_base=$(basename "$pdf_path" .pdf)
  output_path="${source_dir}/${source_base}_annotations.md"
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "pdf_path": "/absolute/path/to/document.pdf",
  "output_path": "/absolute/path/to/document_annotations.md",
  "annotation_types": ["highlights", "comments", "notes", "bookmarks"],
  "output_format": "markdown",
  "metadata": {
    "session_id": "sess_{timestamp}_{random}",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "scrape", "skill-scrape"]
  }
}
```

### 3. Invoke Agent

**CRITICAL**: You MUST use the **Agent** tool to spawn the scrape agent.

**Required Tool Invocation**:
```
Tool: Agent (NOT Skill, NOT Plan)
Parameters:
  - subagent_type: "scrape-agent"
  - prompt: [Include pdf_path, output_path, annotation_types, output_format, metadata]
  - description: "Extract annotations from {pdf_path} to {output_path}"
```

**DO NOT** use `Skill(scrape-agent)` - this will FAIL.
Agents live in `.claude/agents/` or extension agent directories, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The agent will:
- Open the PDF and enumerate all annotation objects
- Filter by requested annotation types
- Format annotations according to output_format
- Write structured output to output_path
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: scraped, partial, failed
- Summary is non-empty and <100 tokens
- Artifacts array present with output file path
- Metadata contains session_id, agent_type, delegation info

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "scraped",
  "summary": "Extracted 42 annotations from document.pdf: 28 highlights, 10 comments, 4 notes",
  "artifacts": [
    {
      "type": "implementation",
      "path": "/absolute/path/to/document_annotations.md",
      "summary": "Extracted annotations in markdown format"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "scrape-agent",
    "delegation_depth": 2,
    "delegation_path": ["orchestrator", "scrape", "skill-scrape", "scrape-agent"],
    "annotation_count": 42,
    "annotation_breakdown": {
      "highlights": 28,
      "comments": 10,
      "notes": 4
    }
  },
  "next_steps": "Review extracted annotations"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if PDF not found or not a .pdf file.

### Unsupported Format
Return failed status with clear message about supported annotation types.

### Agent Errors
Pass through the agent's error return verbatim.

### Tool Not Available
Return failed status with installation instructions for PDF annotation tools (e.g., pdfannots, PyMuPDF).

---

## MUST NOT

- Run the postflight step (git commit, status update) — that is the command's responsibility
- Modify the return from scrape-agent before propagating
- Load context files eagerly — only reference them when needed
- Use the Skill tool to invoke scrape-agent (use Agent tool instead)
