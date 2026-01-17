# Research Report: Task #475 (Supplemental)

**Task**: Create skill-document-converter thin wrapper
**Date**: 2026-01-17
**Focus**: Batch operations support, /task workflow integration, and tool-specific capabilities
**Session ID**: sess_1768684521_85f216

## Summary

Supplemental research addressing specific questions about batch conversion support and /task workflow integration. Key findings: (1) Pandoc natively supports multiple input files merged into one output, but batch directory processing requires shell scripting within the agent; (2) markitdown is single-file only; (3) The converter skill should be invokable both standalone via /convert command AND as a utility during task implementation when conversion is naturally needed - this is achieved through the Skill tool's trigger conditions mechanism.

## Findings

### 1. Tool-Specific Batch Support Analysis

**Pandoc**:
- **Multi-file input**: Pandoc natively accepts multiple files: `pandoc file1.md file2.md -o output.pdf`
- **Directory processing**: NOT built-in; requires shell loop
- **Merge capability**: Multiple inputs concatenate into single output
- **Batch pattern** (for agent to implement):
```bash
# Convert all markdown to PDF in directory
for f in *.md; do pandoc "$f" -o "${f%.md}.pdf"; done
```

**Markitdown**:
- **Single file only**: CLI accepts one file at a time
- **No directory processing**: No built-in batch
- **Stdin support**: Can pipe content, but still one document

**Typst**:
- **Single file**: `typst compile input.typ output.pdf`
- **Watch mode**: Can watch single file for changes
- **No batch**: Directory processing needs scripting

**Conclusion**: Batch/directory conversion is NOT inherent to the tools but can be implemented within the agent via shell loops. The agent should support both single-file and directory modes.

### 2. Workflow Integration: How Skills Get Invoked During Tasks

The ProofChecker architecture has two invocation paths:

**Path 1: Direct Command**
```
User: /convert document.pdf
  -> command/convert.md parses args
  -> Skill(skill-document-converter)
  -> document-converter-agent executes
```

**Path 2: Implicit During Task Implementation**
When a task implementation naturally requires document conversion, the implementing agent can invoke the converter skill. This is the "skill becomes available" pattern mentioned in the focus.

Example scenario:
```
Task: "Create documentation from research PDF"
Language: general
  -> /implement invokes skill-implementer
  -> general-implementation-agent reads plan
  -> Plan phase: "Extract content from research.pdf"
  -> Agent invokes Skill(skill-document-converter)
  -> Conversion happens
  -> Implementation continues
```

**Key insight**: Skills can be invoked by other agents during implementation if the agent has the Skill tool available. The trigger conditions in skill definitions document WHEN a skill activates, not who can call it.

### 3. Making Converter Naturally Available to Task Workflow

To make `/task` workflow naturally invoke conversion:

1. **Add converter to agent allowed-tools**: The general-implementation-agent would need `Skill` in its allowed-tools (already has it)

2. **Document trigger patterns**: The skill's trigger conditions should include:
   - "Implementation step requires PDF/DOCX to Markdown extraction"
   - "Implementation step requires Markdown to PDF generation"
   - "Task involves document format conversion"

3. **Plan detection**: When a plan includes steps like:
   - "Extract text from PDF"
   - "Convert documentation to PDF"
   - "Generate PDF from Markdown"

   The implementing agent can invoke the converter skill.

### 4. Recommended Trigger Conditions for skill-document-converter

```markdown
## Trigger Conditions

This skill activates when:
- User explicitly invokes /convert command
- Task implementation requires document format conversion
- PDF/DOCX content extraction is needed for a task
- Markdown needs to be converted to distributable format (PDF/DOCX)
- Implementation plan includes "convert", "extract", or "generate PDF" steps
```

### 5. Batch Mode Design for Agent

The document-converter-agent should support both modes:

**Single file mode** (default):
```
source: /path/to/file.pdf
output: /path/to/file.md
```

**Directory mode** (batch):
```
source: /path/to/directory/
output: /path/to/output_directory/
pattern: "*.pdf"  # Optional glob pattern
```

Agent implementation for directory mode:
```bash
# Detect if source is directory
if [ -d "$source" ]; then
  # Batch mode
  for f in "$source"/$pattern; do
    output_file="${output_dir}/$(basename "${f%.*}").md"
    markitdown "$f" -o "$output_file" || pandoc "$f" -o "$output_file"
  done
else
  # Single file mode
  markitdown "$source" -o "$output" || pandoc "$source" -o "$output"
fi
```

### 6. Integration with Existing /task Workflow

The converter skill integrates without modification to existing workflow commands:

| Command | Integration Point | Mechanism |
|---------|-------------------|-----------|
| /task | N/A | Task creation only |
| /research | N/A | Research doesn't typically convert |
| /plan | N/A | Planning doesn't convert |
| /implement | **Agent invokes skill** | skill-implementer -> Skill(skill-document-converter) |
| /convert | **Direct command** | Command invokes skill directly |

### 7. Return Format for Batch Operations

For batch conversions, the return should aggregate results:

```json
{
  "status": "converted",
  "summary": "Converted 5 of 5 PDF files to Markdown in /path/to/output/",
  "artifacts": [
    { "type": "converted", "path": "/path/to/output/doc1.md", "summary": "Converted doc1.pdf" },
    { "type": "converted", "path": "/path/to/output/doc2.md", "summary": "Converted doc2.pdf" },
    ...
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "document-converter-agent",
    "total_files": 5,
    "successful": 5,
    "failed": 0
  }
}
```

## Recommendations

### 1. Update implementation-002.md Phase 2 (Agent)

Add directory/batch mode support to agent specification:
- Accept source as file OR directory
- Support optional pattern parameter for filtering
- Return aggregated results for batch operations
- Fail gracefully per-file (don't abort on first error)

### 2. Update Trigger Conditions

The skill's trigger conditions should explicitly mention:
- Implicit invocation during task implementation
- Detection keywords in plans ("convert", "extract PDF", "generate PDF")

### 3. Consider Async for Large Batches

For directories with many files:
- Set reasonable timeout (5 min per file max)
- Return partial results if timeout
- Include progress tracking in metadata

### 4. Document Both Invocation Paths

In the skill's README and command help:
- Direct: `/convert source.pdf [output.md]`
- Implicit: "This skill can be invoked by other agents during implementation"

## Dependencies

- Task 476: Create document-converter-agent (implements batch logic)
- No changes needed to orchestrator or /implement command

## References

- Pandoc manual: multi-file input concatenation
- Markitdown help output (captured)
- Typst help output (captured)
- skill-implementer/SKILL.md - Shows agent can invoke other skills
- implement.md command - Shows delegation flow

## Next Steps

1. Incorporate batch mode into implementation-002.md (or create implementation-003.md)
2. Proceed with /plan 475 or /implement 475
3. Ensure document-converter-agent implements directory detection and loop logic
