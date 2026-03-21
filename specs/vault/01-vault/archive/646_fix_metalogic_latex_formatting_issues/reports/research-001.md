# Research Report: Fix Metalogic LaTeX Formatting and Structure Issues

- **Task**: 646 - Fix Metalogic LaTeX formatting and structure issues
- **Started**: 2026-01-20T12:00:00Z
- **Completed**: 2026-01-20T12:15:00Z
- **Effort**: 15 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` (source file with tags)
  - `.claude/context/project/latex/standards/latex-style-guide.md` (LaTeX standards)
  - `.claude/context/project/latex/standards/notation-conventions.md` (notation macros)
  - `.claude/rules/latex.md` (LaTeX rules)
- **Artifacts**: This report
- **Standards**: report-format.md, artifact-formats.md, latex-style-guide.md

## Executive Summary

- Identified 14 FIX:/NOTE: tags in 04-Metalogic.tex requiring attention
- Tags span three categories: definitional ordering (4), explanatory content (5), and formatting/presentation (5)
- Project LaTeX standards require: theorem names in italics for prose references, `\texttt{}` for Lean names, definitions before first use
- Recommended phasing: Group 1 (formatting/consistency), Group 2 (structural reorganization), Group 3 (content additions)
- Several fixes are interdependent (e.g., reordering definitions affects multiple sections)

## Context & Scope

The file `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` contains embedded FIX:/NOTE: tags marking areas requiring improvement.
These tags were created by the project author to guide future revisions.
The task is to fix all 14 tagged issues while adhering to project LaTeX standards.

**Exclusions**: This task covers FIX: and NOTE: tags only.
TODO: tags (5 found) represent deeper research questions and are explicitly excluded from this task scope.

## Findings

### Category 1: Definitional Ordering and Structure (4 issues)

#### Issue 1: Negation Completeness Definition (Line 89)
- **Tag**: `FIX: make negation complete a definition and then state that MCSs are negation complete.`
- **Current State**: Negation-completeness is described in prose after the MCS definition (lines 91-93)
- **Required Change**: Create formal `\begin{definition}[Negation-Complete]` environment, then state that MCSs have this property as a separate statement
- **Standard Reference**: latex-style-guide.md - "Definitions must appear before their first use in prose"

#### Issue 2: Histories/Times Before Canonical World States (Line 116)
- **Tag**: `FIX: This is confusing since it should introduce how histories and times are defined FIRST, and then use these to define canonical world states.`
- **Current State**: Canonical World State defined (line 118-123) before explaining histories and times
- **Required Change**: Reorder subsection to introduce history/time definitions before using them in Canonical World State definition
- **Standard Reference**: latex-style-guide.md - "Definitions must appear before their first use"

#### Issue 3: Define Quotient Construction (Line 147)
- **Tag**: `FIX: define the quotient construction to avoid empty references that leave the reader unable to follow.`
- **Current State**: Truth lemma mentions "quotient construction" without defining it (line 149-150)
- **Required Change**: Add brief explanation of quotient construction before referencing it

#### Issue 4: Merge Finite Model Property into Decidability (Line 285)
- **Tag**: `FIX: I don't like how short this next subsection is. Instead, its content should be included in the following Decidability subsection.`
- **Current State**: Finite Model Property is its own subsection (lines 287-295) with only ~8 lines of content
- **Required Change**: Move FMP content into Decidability subsection as an introduction or opening paragraph

### Category 2: Explanatory Content Additions (5 issues)

#### Issue 5: Lindenbaum Footnote and Explanation Merge (Line 101)
- **Tag**: `FIX: it feels discontinuous to have both a footnote with a reference and then an explanation on the same thing.`
- **Current State**: Footnote on line 98 with `\texttt{set_lindenbaum}`, then separate explanation (lines 103-105)
- **Required Change**: Integrate the Lean reference into the prose explanation, remove footnote

#### Issue 6: Strong Representation Theorem Explanation (Line 171)
- **Tag**: `FIX: the following stronger theorem also needs some explanation following`
- **Current State**: Strong Representation Theorem stated (lines 173-175) with no following explanation
- **Required Change**: Add 2-3 sentences explaining significance and relationship to standard representation theorem

#### Issue 7: Provable iff Valid Explanation (Line 261)
- **Tag**: `FIX: some explanation is in order here to explain that this shows that the proof system and semantics align perfectly`
- **Current State**: Theorem stated (lines 257-259) with only footnote, no explanatory prose
- **Required Change**: Add explanation about alignment of proof system and semantics

#### Issue 8: Decision Procedure Return Values (Line 304)
- **Tag**: `FIX: It is not clear what it is for the decision procedure returns "valid" with proof π.`
- **Current State**: Vague reference to proof π without defining what this object is
- **Required Change**: Define what the proof object is (a derivation tree/term) before using it

#### Issue 9: Explain Tableau, Axiom Proof, Proof Search, and Lean 4 Context (Line 310)
- **Tag**: `FIX: it is also important to explain what 'Try direct axiom proof' actually amounts to here in the context of using LEAN 4...`
- **Current State**: Steps listed without explanation of concepts
- **Required Change**: Add brief explanatory text for each concept: direct axiom proof (matching formula to axiom schema), proof search (automated tactic application), tableau (systematic truth/falsity decomposition)

#### Issue 10: Complexity Values Context (Line 342)
- **Tag**: `FIX: some explanation would help readers here make sense of what these values mean`
- **Current State**: Complexity table (lines 344-354) lists values without interpretation
- **Required Change**: Add 2-3 sentences explaining what PSPACE-complete means practically and why exponential time is acceptable

#### Issue 11: Decidability Usefulness Despite Limitations (Line 367)
- **Tag**: `FIX: further explanation of why this is useful despite the computational limitations`
- **Current State**: Decision result types listed (lines 360-365) without explaining practical value
- **Required Change**: Add explanation of when decidability is useful (verification, small formulas, early rejection)

### Category 3: Formatting and Presentation (5 issues)

#### Issue 12: Theorem Names in Italics (Line 109)
- **Tag**: `NOTE: I want 'Representation Theorem' and other names of theorems to be in italics`
- **Current State**: "Representation Theorem" in normal text (line 111)
- **Required Change**: Change to `\emph{Representation Theorem}` for prose references
- **Standard Reference**: latex-style-guide.md - "Named theorems use italics in prose"
- **Scope**: Apply throughout file to all theorem name references in prose

#### Issue 13: Diagram Reorganization (Lines 181, 183)
- **Tags**:
  - `NOTE: dependency diagrams should always have the more fundamental results come above`
  - `FIX: I don't need the 'Corollaries', 'Central Result', and 'Core Infrastructure' labels`
- **Current State**: Diagram has labels on left side (lines 212-214), fundamental results at bottom
- **Required Changes**:
  1. Flip diagram orientation (Core Infrastructure at top, Corollaries at bottom)
  2. Remove left-side layer labels
  3. Add explanatory text following diagram instead
  4. Add `\label{fig:theorem-deps}` for cross-reference

#### Issue 14: Standardized `\texttt{}` for Lean Directories (Lines 371, 409)
- **Tags**:
  - `NOTE: use the standardized formatting for lean directories throughout, replacing 'Metalogic_v2' here with '\texttt{Metalogic_v2}'`
  - `FIX: it would be good if the following items were bold and in \texttt{} formatting`
- **Current State**:
  - Line 373: `Metalogic_v2` in plain text
  - Lines 414-419: Directory names (`Core/`, `Soundness/`, etc.) are bold but not `\texttt{}`
- **Required Change**:
  - Use `\texttt{Metalogic\_v2}` for directory names
  - Format directory items as `\texttt{Core/}` with bold via `\textbf{\texttt{Core/}}` or similar

## Decisions

1. **Exclude TODO tags**: The 5 TODO: tags (lines 125, 240, 255, 268, 356) raise deeper research questions about proof strategy and are out of scope for this formatting task
2. **Single file scope**: All changes are confined to `04-Metalogic.tex`
3. **Semantic linefeeds**: New prose additions should follow one-sentence-per-line convention per latex-style-guide.md
4. **Lean name escaping**: Underscores in Lean names must be escaped as `\_` in LaTeX

## Recommendations

### Phase 1: Formatting Consistency (Low Risk, Quick Wins)
1. Apply italics to theorem names in prose (Issue 12)
2. Apply `\texttt{}` formatting to directory names (Issue 14)
3. Remove diagram labels and add explanation (Issue 13 - partial)

### Phase 2: Content Additions (Medium Risk)
1. Add explanatory text after Strong Representation Theorem (Issue 6)
2. Add explanation for Provable iff Valid (Issue 7)
3. Add decision procedure terminology explanations (Issues 8, 9)
4. Add complexity interpretation (Issue 10)
5. Add decidability usefulness explanation (Issue 11)

### Phase 3: Structural Reorganization (Higher Risk)
1. Create Negation-Complete definition (Issue 1)
2. Merge Lindenbaum footnote with explanation (Issue 5)
3. Reorder histories/times before canonical world states (Issue 2)
4. Define quotient construction (Issue 3)
5. Merge Finite Model Property into Decidability (Issue 4)
6. Flip diagram orientation (Issue 13 - remaining)

### Rationale for Phasing

- **Phase 1** changes are mechanical find-replace operations with minimal risk
- **Phase 2** adds content without restructuring, allowing incremental review
- **Phase 3** involves moving and reordering content which could introduce compilation errors or break cross-references

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking LaTeX compilation | Medium | High | Compile after each phase, verify no errors |
| Inconsistent theorem name formatting | Low | Low | Grep for theorem names to ensure all converted |
| Cross-reference breakage from reordering | Medium | Medium | Check `\cref`/`\ref` usage after Phase 3 |
| TikZ diagram errors from flipping | Medium | Medium | Test diagram separately before integrating |
| Paragraph flow disruption from merges | Low | Medium | Read merged sections aloud for flow |

## Appendix

### All Tags in File (for reference)

| Line | Type | Summary |
|------|------|---------|
| 89 | FIX | Make negation completeness a definition |
| 101 | FIX | Merge Lindenbaum footnote with explanation |
| 109 | NOTE | Theorem names in italics |
| 116 | FIX | Define histories/times before canonical world states |
| 125 | TODO | (excluded) Time domain research |
| 127 | NOTE | (covered by Issue 2) Definition ordering |
| 147 | FIX | Define quotient construction |
| 154 | NOTE | Reference Lean names in theorem environment |
| 171 | FIX | Explain strong representation theorem |
| 181 | NOTE | Flip diagram orientation |
| 183 | FIX | Remove diagram labels, add explanation |
| 240 | TODO | (excluded) Infinite contexts/compactness |
| 255 | TODO | (excluded) Strong formulation preference |
| 261 | FIX | Explain provable iff valid |
| 268 | TODO | (excluded) Syntactic approach porting |
| 285 | FIX | Merge FMP into Decidability |
| 304 | FIX | Define decision procedure return values |
| 310 | FIX | Explain tableau/axiom proof/proof search |
| 342 | FIX | Explain complexity values |
| 356 | TODO | (excluded) Complexity calculation verification |
| 367 | FIX | Explain decidability usefulness |
| 371 | NOTE | Use `\texttt{}` for directories |
| 409 | FIX | Bold and `\texttt{}` for directory items |

### References

- LaTeX Style Guide: `.claude/context/project/latex/standards/latex-style-guide.md`
- Notation Conventions: `.claude/context/project/latex/standards/notation-conventions.md`
- LaTeX Rules: `.claude/rules/latex.md`
