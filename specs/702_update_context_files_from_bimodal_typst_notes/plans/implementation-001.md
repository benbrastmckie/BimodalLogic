# Implementation Plan: Task #702

- **Task**: 702 - Update context files from Bimodal Typst notes
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Low
- **Dependencies**: None
- **Research Inputs**: specs/702_update_context_files_from_bimodal_typst_notes/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create Typst-specific context documentation to capture formatting patterns learned from BimodalReference.typ. The research identified four key patterns (margins, URLblue hyperlinks, raw() URL formatting, heading spacing) that align with LaTeX conventions but need dedicated Typst documentation. A minimal two-file structure (README.md + typst-style-guide.md) will be created under `.claude/context/project/typst/`, and the context index will be updated to enable lazy loading for Typst tasks.

### Research Integration

Integrated from research-001.md:
- Four Typst formatting patterns identified from BimodalReference.typ
- No existing Typst context files exist - full directory needs creation
- Patterns already documented in LaTeX context can be adapted for Typst equivalents
- Recommended minimal structure: 2 files in new `project/typst/` directory

## Goals & Non-Goals

**Goals**:
- Create `.claude/context/project/typst/` directory structure
- Document Typst formatting patterns that match LaTeX conventions
- Update context index with Typst section for lazy loading
- Enable consistent formatting between LaTeX and Typst documents

**Non-Goals**:
- Creating a comprehensive Typst language tutorial
- Documenting all Typst features (only project-relevant patterns)
- Creating rules file for auto-loading (can be added later if needed)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Limited Typst usage in project | Low | High | Minimal structure, expand as needed |
| Pattern drift between LaTeX/Typst | Medium | Medium | Cross-reference shared conventions explicitly |
| Missing patterns | Low | Low | Document known patterns, add incrementally |

## Implementation Phases

### Phase 1: Create Typst Style Guide [NOT STARTED]

**Goal**: Create comprehensive Typst style guide documenting formatting patterns

**Tasks**:
- [ ] Create `.claude/context/project/typst/` directory
- [ ] Create `typst-style-guide.md` with documented patterns:
  - Page layout and margins (match LaTeX: 1.5in x 1.25in)
  - Typography settings (font, line spacing, paragraph indent)
  - Hyperlink styling (URLblue = rgb(0, 0, 150))
  - URL text formatting (raw() for monospace)
  - Heading spacing (above: 1.4em, below: 1em)
  - Theorem environments (thmbox integration reference)
  - Cross-references and links

**Timing**: 45 minutes

**Files to create**:
- `.claude/context/project/typst/typst-style-guide.md` - Comprehensive style guide (~150 lines)

**Verification**:
- File exists and contains all four patterns from task description
- Examples use actual code from BimodalReference.typ and template.typ
- Cross-references to LaTeX equivalents are included

---

### Phase 2: Create Directory README [NOT STARTED]

**Goal**: Create README.md for Typst context directory

**Tasks**:
- [ ] Create `README.md` with:
  - Brief overview of Typst context
  - File listing with descriptions
  - When to load guidance
  - Link to main LaTeX context for shared conventions

**Timing**: 15 minutes

**Files to create**:
- `.claude/context/project/typst/README.md` - Directory overview (~40 lines)

**Verification**:
- README follows project documentation conventions
- Accurately describes style guide contents
- Cross-references LaTeX context appropriately

---

### Phase 3: Update Context Index [NOT STARTED]

**Goal**: Add Typst section to context index for lazy loading

**Tasks**:
- [ ] Add new section to `.claude/context/index.md`:
  - Section header: "### Typst Context (project/typst/)"
  - Load condition: "Load for: Typst implementation tasks (Language: typst)"
  - File listing with descriptions and line counts
  - Context loading example for Typst workflows
- [ ] Place section after LaTeX context (alphabetical in project/ section)

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/index.md` - Add Typst section (~25 lines added)

**Verification**:
- Index entry follows existing format (see LaTeX and Lean4 sections)
- Load condition is clear and actionable
- Section is correctly positioned

---

### Phase 4: Verification and Cleanup [NOT STARTED]

**Goal**: Verify all files exist and are correctly linked

**Tasks**:
- [ ] Verify directory structure exists
- [ ] Verify all files contain expected content
- [ ] Verify index references are correct
- [ ] Run glob to confirm file creation

**Timing**: 10 minutes

**Verification**:
- `glob .claude/context/project/typst/**/*.md` returns expected files
- No broken links or references in index
- All files follow NO EMOJI policy

## Testing & Validation

- [ ] All new files created in correct locations
- [ ] Typst style guide contains all four patterns from task description
- [ ] Context index updated with Typst section
- [ ] No duplicate or conflicting documentation
- [ ] Follows documentation standards (no emojis, proper markdown)

## Artifacts & Outputs

- `.claude/context/project/typst/typst-style-guide.md` - Comprehensive Typst style guide
- `.claude/context/project/typst/README.md` - Directory overview
- `.claude/context/index.md` - Updated with Typst section
- `specs/702_update_context_files_from_bimodal_typst_notes/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Remove `.claude/context/project/typst/` directory entirely
2. Revert changes to `.claude/context/index.md`
3. No other files are modified, so rollback is straightforward
