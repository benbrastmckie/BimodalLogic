# Implementation Plan: Task #692

- **Task**: 692 - port_bimodal_latex_to_typst
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**:
  - specs/692_port_bimodal_latex_to_typst/reports/research-001.md (symbol mapping, conversion patterns)
  - specs/692_port_bimodal_latex_to_typst/reports/research-002.md (best practices, maintainability)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Port the Bimodal/latex/ documentation project to Typst format, creating a parallel Bimodal/typst/ directory structure. The conversion maintains identical formal notation and content while leveraging Typst's cleaner syntax and faster compilation. The LaTeX source remains unchanged for reference.

### Research Integration

Research reports identified:
- Complete LaTeX to Typst symbol mapping for modal logic notation (research-001.md)
- Recommended packages: great-theorems for theorem environments, CeTZ for TikZ diagrams
- Best practices: keep notation module lean, centralize configuration in main file
- Maintainability: avoid over-abstraction, use built-in symbols where possible

## Goals & Non-Goals

**Goals**:
- Create complete Typst port of BimodalReference document
- Maintain identical formal notation and mathematical content
- Port all 7 subfiles with proper includes
- Convert TikZ diagrams to CeTZ equivalents
- Create bimodal-notation.typ mirroring bimodal-notation.sty
- Ensure PDF output is visually comparable to LaTeX version

**Non-Goals**:
- Modifying the LaTeX source files
- Adding new content not in the LaTeX version
- Creating independently compilable subfiles (Typst limitation)
- Matching pixel-perfect layout (minor formatting differences acceptable)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| CeTZ cannot replicate TikZ diagrams | Medium | Low | Simplify diagrams or use static SVG if needed |
| great-theorems API differs from amsthm | Low | Low | Test theorem environments early in Phase 2 |
| Symbol rendering differences | Low | Low | Test notation module before converting content |
| Cross-reference system differences | Medium | Low | Use Typst label/ref system consistently |

## Implementation Phases

### Phase 1: Project Setup and Notation Module [COMPLETED]

**Goal**: Create the Typst project structure and notation modules

**Tasks**:
- [ ] Create directory structure: `Theories/Bimodal/typst/`, `typst/notation/`, `typst/chapters/`
- [ ] Create `notation/shared-notation.typ` with shared notation (mirrors notation-standards.sty)
- [ ] Create `notation/bimodal-notation.typ` with bimodal-specific notation
- [ ] Test notation module compiles and symbols render correctly

**Timing**: 45 minutes

**Files to create**:
- `Theories/Bimodal/typst/notation/shared-notation.typ`
- `Theories/Bimodal/typst/notation/bimodal-notation.typ`

**Verification**:
- Create minimal test document importing notation
- Verify all symbols render correctly

---

### Phase 2: Main Document and Theorem Environments [COMPLETED]

**Goal**: Create main document with all configuration and theorem environment setup

**Tasks**:
- [ ] Create `BimodalReference.typ` with document metadata
- [ ] Configure text settings (11pt, New Computer Modern font)
- [ ] Set up heading numbering and page layout
- [ ] Import great-theorems package and define theorem environments (definition, theorem, lemma, axiom, remark)
- [ ] Create title page matching LaTeX version
- [ ] Add abstract and table of contents
- [ ] Add include statements for all chapters (empty initially)

**Timing**: 45 minutes

**Files to create**:
- `Theories/Bimodal/typst/BimodalReference.typ`

**Verification**:
- Document compiles successfully
- Title page renders correctly
- Theorem environments work with sample content

---

### Phase 3: Content Chapters (Simple) [COMPLETED]

**Goal**: Port the simpler content files without complex diagrams

**Tasks**:
- [ ] Port `01-Syntax.tex` to `chapters/01-syntax.typ` (tables, lists, notation)
- [ ] Port `02-Semantics.tex` to `chapters/02-semantics.typ` (definitions, tables)
- [ ] Port `03-ProofTheory.tex` to `chapters/03-proof-theory.typ` (axiom tables, inference rules)
- [ ] Port `05-Theorems.tex` to `chapters/05-theorems.typ` (theorem statements)
- [ ] Port `06-Notes.tex` to `chapters/06-notes.typ` (status tables)

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/typst/chapters/01-syntax.typ`
- `Theories/Bimodal/typst/chapters/02-semantics.typ`
- `Theories/Bimodal/typst/chapters/03-proof-theory.typ`
- `Theories/Bimodal/typst/chapters/05-theorems.typ`
- `Theories/Bimodal/typst/chapters/06-notes.typ`

**Verification**:
- Each chapter compiles when included
- Tables render with proper formatting
- Mathematical notation displays correctly
- Cross-references work

---

### Phase 4: Content Chapters with Diagrams [COMPLETED]

**Goal**: Port chapters containing TikZ diagrams using CeTZ

**Tasks**:
- [ ] Port `00-Introduction.tex` to `chapters/00-introduction.typ`
  - Convert light cone TikZ diagram to CeTZ
  - Port project structure list and description
- [ ] Port `04-Metalogic.tex` to `chapters/04-metalogic.typ`
  - Convert theorem dependency diagram to CeTZ
  - Convert file organization diagram to CeTZ
  - Port all theorem/proof content
  - Port status tables

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/typst/chapters/00-introduction.typ`
- `Theories/Bimodal/typst/chapters/04-metalogic.typ`

**Verification**:
- Diagrams render with correct structure and colors
- Labels and annotations position correctly
- Visual appearance comparable to LaTeX versions

---

### Phase 5: Final Integration and Verification [COMPLETED]

**Goal**: Complete integration, test full document, verify output quality

**Tasks**:
- [ ] Compile complete document end-to-end
- [ ] Compare PDF output with LaTeX version
- [ ] Fix any rendering issues or inconsistencies
- [ ] Verify all cross-references resolve
- [ ] Check theorem numbering continuity
- [ ] Review mathematical notation consistency
- [ ] Add build instructions (typst compile command)

**Timing**: 30 minutes

**Files to modify**:
- All files as needed for fixes

**Verification**:
- Full document compiles without errors
- PDF output is readable and professional
- No missing content compared to LaTeX version
- Mathematical symbols match intended appearance

## Testing & Validation

- [ ] Each notation symbol renders correctly (box, diamond, turnstile, etc.)
- [ ] Theorem environments display with proper numbering and styling
- [ ] All 7 chapters include successfully
- [ ] Tables display with proper formatting (hlines, alignment)
- [ ] Light cone diagram renders with correct colors and shapes
- [ ] Theorem dependency diagram shows correct structure
- [ ] File organization diagram renders legibly
- [ ] Cross-references (figures, theorems, definitions) resolve
- [ ] Table of contents generates correctly
- [ ] `typst compile BimodalReference.typ` produces valid PDF

## Artifacts & Outputs

- `Theories/Bimodal/typst/BimodalReference.typ` - Main document
- `Theories/Bimodal/typst/notation/shared-notation.typ` - Shared notation module
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` - Bimodal notation module
- `Theories/Bimodal/typst/chapters/00-introduction.typ` - Introduction chapter
- `Theories/Bimodal/typst/chapters/01-syntax.typ` - Syntax chapter
- `Theories/Bimodal/typst/chapters/02-semantics.typ` - Semantics chapter
- `Theories/Bimodal/typst/chapters/03-proof-theory.typ` - Proof theory chapter
- `Theories/Bimodal/typst/chapters/04-metalogic.typ` - Metalogic chapter
- `Theories/Bimodal/typst/chapters/05-theorems.typ` - Theorems chapter
- `Theories/Bimodal/typst/chapters/06-notes.typ` - Notes chapter

## Rollback/Contingency

The LaTeX source remains unchanged throughout this task. If the Typst port proves problematic:
- Delete `Theories/Bimodal/typst/` directory
- No impact on existing LaTeX documentation

If specific diagrams cannot be converted to CeTZ:
- Use simplified diagram versions
- Or include as pre-rendered SVG images (last resort)
