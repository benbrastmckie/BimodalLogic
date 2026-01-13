# Implementation Plan: Task #465

- **Task**: 465 - Convert Cosmos essay to LaTeX
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/465_cosmos_essay_latex/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Convert the markdown essay `/home/benjamin/Projects/ProofChecker/docs/essays/cosmos-institute-essay.md` to a professionally formatted LaTeX document. The output will follow the title page format used in BimodalReference.tex and LogosReference.tex, include three academic references from those manuals, and add hyperlinks to the ModelChecker and ProofChecker GitHub repositories. The document will use the project's shared formatting.sty and XeLaTeX build chain.

### Research Integration

Key findings from research-001.md:
- Essay has ~1500 words with 7 sections and 3 subsections
- Title page format follows BimodalReference.tex/LogosReference.tex pattern
- Three primary references needed from the reference manuals
- GitHub repos: ProofChecker and ModelChecker
- Use shared formatting.sty; logos-notation.sty not needed (no formal logic notation)
- Output location: `docs/essays/latex/` with local latexmkrc stub

## Goals & Non-Goals

**Goals**:
- Create professionally formatted LaTeX document from markdown source
- Reproduce title page format from existing reference manuals
- Include three academic references on title page
- Add hyperlinks to GitHub repositories in essay text
- Use project's shared LaTeX infrastructure (formatting.sty, latexmkrc)
- Apply semantic linefeeds per project LaTeX conventions

**Non-Goals**:
- Use logos-notation.sty or bimodal-notation.sty (no formal notation in essay)
- Create complex bibliography with natbib (essay has minimal citations)
- Add tikz diagrams or figures (essay is prose-only)
- Modify shared formatting.sty

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| XeLaTeX not available | Build fails | Low | Document pdflatex fallback option |
| TEXINPUTS path issues | formatting.sty not found | Medium | Configure latexmkrc stub correctly with relative path |
| Long lines cause overfull hboxes | Poor PDF rendering | Medium | Apply semantic linefeeds consistently |
| Title page spacing differs from reference docs | Visual inconsistency | Low | Copy exact vspace/HRule commands from LogosReference.tex |

## Implementation Phases

### Phase 1: Directory Setup and Build Configuration [COMPLETED]

**Goal**: Create the output directory structure and configure the build system to use shared project resources.

**Tasks**:
- [ ] Create directory `docs/essays/latex/`
- [ ] Create `docs/essays/latex/latexmkrc` stub that loads shared config
- [ ] Verify TEXINPUTS path resolves to `latex/formatting.sty`
- [ ] Create minimal test document to verify build chain works

**Timing**: 30 minutes

**Files to create**:
- `docs/essays/latex/latexmkrc` - Build config stub loading shared config
- `docs/essays/latex/.gitignore` - Ignore build/ directory

**Verification**:
- `latexmk` command runs without errors in `docs/essays/latex/`
- Test document compiles with formatting.sty

---

### Phase 2: Document Structure and Title Page [IN PROGRESS]

**Goal**: Create the main LaTeX document with preamble, title page matching reference manuals, and document skeleton.

**Tasks**:
- [ ] Create `docs/essays/latex/cosmos-essay.tex` with article class (11pt)
- [ ] Add preamble with formatting package and hyperref configuration
- [ ] Create title page following BimodalReference.tex pattern:
  - Title: "Teaching Machines to Prove They're Right"
  - Subtitle: "Formal Verification for AI Reasoning"
  - Author: Benjamin Brast-McKie with website link
  - Date: \today
  - Primary References section with three papers
- [ ] Add hyperlink styling (colored links for screen viewing)
- [ ] Create document structure with empty sections

**Timing**: 1 hour

**Files to create**:
- `docs/essays/latex/cosmos-essay.tex` - Main document

**Verification**:
- Document compiles without errors
- Title page renders correctly with all three references
- Hyperlinks are clickable and styled

---

### Phase 3: Content Conversion [NOT STARTED]

**Goal**: Convert all markdown content to LaTeX with proper formatting and hyperlinks.

**Tasks**:
- [ ] Convert introduction (2 paragraphs)
- [ ] Convert "The Problem" section
- [ ] Convert "Philosophical Logic as Conceptual Engineering" section
- [ ] Convert "The Innovation" section with subsections:
  - Machine-Verified Proofs
  - A Language for Planning Under Uncertainty
  - Unlimited Verified Training Data
- [ ] Convert "Why It Matters" section
- [ ] Convert "The Invitation" section
- [ ] Convert conclusion
- [ ] Add Cosmos Institute acknowledgment footer
- [ ] Apply semantic linefeeds (one sentence per line)
- [ ] Add ProofChecker and ModelChecker hyperlinks where mentioned

**Timing**: 1.5 hours

**Files to modify**:
- `docs/essays/latex/cosmos-essay.tex` - Add content sections

**Verification**:
- All sections present and properly formatted
- Semantic linefeeds applied consistently
- GitHub links work for both repositories
- No overfull hboxes in log

---

### Phase 4: Polish and Final Build [NOT STARTED]

**Goal**: Review PDF output, fix any formatting issues, and ensure professional quality.

**Tasks**:
- [ ] Build final PDF with `latexmk`
- [ ] Review PDF for visual quality and consistency
- [ ] Check all hyperlinks are functional
- [ ] Verify title page matches reference manual style
- [ ] Fix any overfull/underfull box warnings
- [ ] Clean up auxiliary files
- [ ] Test with both XeLaTeX and pdflatex (if needed for fallback)

**Timing**: 30 minutes

**Files to verify**:
- `docs/essays/latex/build/cosmos-essay.pdf` - Final output

**Verification**:
- PDF opens and displays correctly
- All hyperlinks functional
- No compiler warnings
- Visual quality matches reference manuals

## Testing & Validation

- [ ] Build completes without errors: `latexmk` in `docs/essays/latex/`
- [ ] PDF opens in standard viewer
- [ ] Title page has correct format with three references
- [ ] All 7 sections present with proper hierarchy
- [ ] GitHub hyperlinks work for ProofChecker and ModelChecker
- [ ] Cosmos Institute acknowledgment visible
- [ ] No overfull hbox warnings in build log

## Artifacts & Outputs

- `docs/essays/latex/cosmos-essay.tex` - Main LaTeX document
- `docs/essays/latex/latexmkrc` - Build configuration stub
- `docs/essays/latex/.gitignore` - Ignore build outputs
- `docs/essays/latex/build/cosmos-essay.pdf` - Final PDF output
- `.claude/specs/465_cosmos_essay_latex/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation fails:
1. Delete `docs/essays/latex/` directory entirely
2. No changes to existing project files required
3. Markdown source remains unchanged at `docs/essays/cosmos-institute-essay.md`

If XeLaTeX unavailable:
1. Modify latexmkrc to use pdflatex instead
2. Remove any XeLaTeX-specific font commands
3. Test with pdflatex build chain
