# Implementation Plan: Task #784

- **Task**: 784 - Export Claude Directory to Markdown
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/784_export_claude_directory_to_markdown/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/formats/plan-format.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a shell script that exports the .claude/ directory contents to a single consolidated markdown file with a hierarchical table of contents. The script will process ~243 files, respect .gitignore exclusions, wrap non-markdown files in appropriate code blocks, and adjust header levels to preserve document hierarchy.

### Research Integration

Integrated findings from research-001.md:
- Option A (single concatenated file) selected as optimal approach
- Exclusion patterns identified: *.log, *.tmp, *.bak, *.backup, settings.local.json, logs/
- File processing order established: root files first, then alphabetically by directory
- Header adjustment: shift all headers down 2 levels
- Estimated output: ~68,000 lines

## Goals & Non-Goals

**Goals**:
- Create portable shell script at `.claude/scripts/export-to-markdown.sh`
- Generate single consolidated markdown file with full directory contents
- Include auto-generated table of contents from directory structure
- Respect .gitignore exclusion patterns plus backup file exclusions
- Wrap non-markdown files in appropriate code blocks (bash, json, yaml)
- Adjust header levels to maintain hierarchy under file section headers
- Include export timestamp for version tracking

**Non-Goals**:
- Interactive features or user prompts
- Collapsible HTML sections (optional future enhancement)
- Multi-file output options
- Real-time progress reporting

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large output file overwhelms viewers | Medium | Medium | Include TOC navigation; file is primarily for sharing/archival |
| Header level conflicts in nested content | Medium | Low | Consistent 2-level shift for all markdown files |
| Binary files in directory | Low | Low | Skip non-text files with warning |
| Special characters break markdown | Low | Low | Proper quoting and code block wrapping |

## Implementation Phases

### Phase 1: Script Foundation [NOT STARTED]

**Goal**: Create the base script structure with argument parsing and exclusion patterns

**Tasks**:
- [ ] Create script file at `.claude/scripts/export-to-markdown.sh`
- [ ] Add shebang and set strict mode (set -euo pipefail)
- [ ] Define default output path with command-line override option
- [ ] Define exclusion patterns array from research findings
- [ ] Implement `should_exclude()` function to check patterns
- [ ] Add usage help text

**Timing**: 30 minutes

**Files to modify**:
- `.claude/scripts/export-to-markdown.sh` - Create new file

**Verification**:
- Script is executable
- `--help` shows usage
- Exclusion function correctly filters test patterns

---

### Phase 2: File Discovery and TOC Generation [NOT STARTED]

**Goal**: Implement file discovery and table of contents generation

**Tasks**:
- [ ] Implement `discover_files()` to find all exportable files
- [ ] Sort files by processing order (root first, then directories alphabetically)
- [ ] Implement `generate_toc()` to create hierarchical TOC from file list
- [ ] Format TOC with proper markdown links (using path as anchor)
- [ ] Add file count summary to TOC header

**Timing**: 30 minutes

**Files to modify**:
- `.claude/scripts/export-to-markdown.sh` - Add discovery and TOC functions

**Verification**:
- File list excludes patterns from exclusion array
- TOC entries link to correct anchors
- Processing order matches research specification

---

### Phase 3: Content Processing [NOT STARTED]

**Goal**: Implement file content processing with code block wrapping and header adjustment

**Tasks**:
- [ ] Implement `get_file_type()` to determine markdown code block type by extension
- [ ] Implement `adjust_headers()` to shift markdown headers down 2 levels
- [ ] Implement `process_file()` to wrap non-markdown in code blocks
- [ ] Handle markdown files: adjust headers and include content
- [ ] Handle shell scripts: wrap in ```bash blocks
- [ ] Handle JSON/YAML: wrap in appropriate code blocks
- [ ] Add file path comment before each file section

**Timing**: 45 minutes

**Files to modify**:
- `.claude/scripts/export-to-markdown.sh` - Add content processing functions

**Verification**:
- Markdown headers are shifted correctly
- Shell scripts wrapped in bash code blocks
- JSON files wrapped in json code blocks
- File paths appear as section headers

---

### Phase 4: Output Assembly and Testing [NOT STARTED]

**Goal**: Assemble final output and verify complete functionality

**Tasks**:
- [ ] Implement `main()` function to orchestrate export
- [ ] Generate header with export timestamp
- [ ] Write TOC to output
- [ ] Process each file and append to output
- [ ] Add horizontal rules between major sections
- [ ] Test with actual .claude directory
- [ ] Verify output renders correctly in markdown viewer

**Timing**: 15 minutes

**Files to modify**:
- `.claude/scripts/export-to-markdown.sh` - Complete main function and finalize

**Verification**:
- Script runs without errors on full .claude directory
- Output file is valid markdown
- TOC links work in rendered markdown
- All expected files are included
- Excluded files are not present

## Testing & Validation

- [ ] Run script with `--help` to verify usage text
- [ ] Run script on .claude directory with default output path
- [ ] Verify exclusion of .log, .tmp, .bak files
- [ ] Verify exclusion of settings.local.json and logs/ directory
- [ ] Check that markdown headers are adjusted (h1 -> h3, h2 -> h4, etc.)
- [ ] Verify shell scripts have ```bash code fence
- [ ] Verify JSON files have ```json code fence
- [ ] Open output in markdown viewer to confirm rendering
- [ ] Verify TOC anchor links navigate correctly

## Artifacts & Outputs

- `.claude/scripts/export-to-markdown.sh` - Main export script (executable)
- `specs/784_export_claude_directory_to_markdown/plans/implementation-001.md` - This plan
- `specs/784_export_claude_directory_to_markdown/summaries/implementation-summary-YYYYMMDD.md` - Summary after completion

## Rollback/Contingency

If the script produces invalid output or cannot handle certain file types:
1. Revert `.claude/scripts/export-to-markdown.sh` via git
2. Consider alternative approaches from research (Option B: collapsible sections, Option C: multi-file)
3. Add problematic file types to exclusion list as temporary workaround
