# Research Report: Task #465

**Task**: 465 - Convert Cosmos essay to LaTeX
**Started**: 2026-01-13T06:13:04Z
**Completed**: 2026-01-13T06:25:00Z
**Effort**: 3-4 hours
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (BimodalReference.tex, LogosReference.tex, formatting.sty, logos-notation.sty, latexmkrc)
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The cosmos-institute-essay.md is a 1500-word essay suitable for professional LaTeX formatting
- Title page should follow BimodalReference.tex/LogosReference.tex pattern with author info, date, and primary references
- Bibliography should include references from both manuals plus links to ModelChecker and ProofChecker GitHub repos
- XeLaTeX build chain is configured via shared latexmkrc; essay can use formatting.sty without needing notation packages

## Context & Scope

Convert `/home/benjamin/Projects/ProofChecker/docs/essays/cosmos-institute-essay.md` to a professionally formatted LaTeX document. The output should:

1. Use the same title page format as BimodalReference.tex and LogosReference.tex
2. Include references from those manuals in the bibliography
3. Link ModelChecker and ProofChecker to their GitHub repositories
4. Follow project LaTeX conventions (semantic linefeeds, shared formatting.sty)

## Findings

### 1. Source Document Structure

The markdown essay has the following structure:

```
# Teaching Machines to Prove They're Right (main title)
  - Introduction (2 paragraphs, ~200 words)
## The Problem (~300 words)
## Philosophical Logic as Conceptual Engineering (~400 words)
## The Innovation
  ### Machine-Verified Proofs (~150 words)
  ### A Language for Planning Under Uncertainty (~150 words)
  ### Unlimited Verified Training Data (~200 words)
## Why It Matters (~200 words)
## The Invitation (~150 words)
## Conclusion (~100 words)
--- Footer (Cosmos Institute acknowledgment)
```

Total: ~1500 words with 7 sections and 3 subsections.

### 2. Title Page Format (from BimodalReference.tex and LogosReference.tex)

Both reference manuals use a custom title page with:

```latex
\begin{titlepage}
\begin{center}
\vspace*{2cm}
\HRule\\[0.4cm]
{\Huge \bfseries Title}\\[0.2cm]
\HRule\\[1cm]
{\LARGE\itshape Subtitle}\\[1cm]
{\large\itshape Author Name}\\[0.15cm]
\texttt{\href{URL}{website}}\\[0.15cm]
{--- \today\ ---}\\[1cm]
\vfill
{\normalsize\bfseries Primary Reference(s):}\\[0.3cm]
\href{URL}{\textit{``Paper Title''}}, Author, \textit{Journal}, Year.\\[1cm]
\end{center}
\end{titlepage}
```

For the essay, adapt to:
- Title: "Teaching Machines to Prove They're Right"
- Subtitle: "Formal Verification for AI Reasoning"
- Author: Benjamin Brast-McKie
- Primary References: Include both from LogosReference.tex

### 3. References Required

**From LogosReference.tex** (line 97-99):
1. "Counterfactual Worlds", Brast-McKie, J. Phil. Logic, 2025
   - URL: https://link.springer.com/article/10.1007/s10992-025-09793-8
2. "Identity and Aboutness", Brast-McKie, J. Phil. Logic, 2021
   - URL: https://link.springer.com/article/10.1007/s10992-021-09612-w

**From BimodalReference.tex** (line 86):
3. "The Construction of Possible Worlds", Brast-McKie, (under review), 2025
   - URL: https://www.benbrastmckie.com/wp-content/uploads/2025/11/possible_worlds.pdf

**GitHub Repositories to Link**:
4. ProofChecker: https://github.com/benbrastmckie/ProofChecker
5. ModelChecker: https://github.com/benbrastmckie/ModelChecker

### 4. Package Requirements

**Essential packages from formatting.sty**:
- natbib (citations)
- hyperref (links)
- fontenc, lmodern, mathpazo (fonts)
- microtype (typography)

**Not needed** (essay has no formal logic):
- logos-notation.sty
- bimodal-notation.sty
- stmaryrd (math symbols)
- tikz (diagrams)

### 5. Build Configuration

From `/home/benjamin/Projects/ProofChecker/latex/latexmkrc`:
- Uses XeLaTeX ($pdf_mode = 5)
- Output to `build/` directory
- TEXINPUTS configured to find formatting.sty from `latex/` directory

**Recommended location**: `/home/benjamin/Projects/ProofChecker/docs/essays/latex/`

This requires:
- A local latexmkrc that loads the shared config
- The essay .tex file
- A simple bibliography file or inline references

### 6. Document Class and Structure

Use standard `article` class (11pt) as in the reference manuals:

```latex
\documentclass[11pt]{article}
\usepackage{formatting}  % shared formatting package
% ... other minimal packages
```

### 7. LaTeX Conventions (from .claude/rules/latex.md)

**Semantic linefeeds**: One sentence per line in source files. Example:
```latex
This is the first sentence.
This is the second sentence which may be longer.
```

**Cross-references**: Use \cref for automatic prefixes.

**Citations**: Use natbib commands (\citet, \citep).

## Recommendations

### Document Structure

```
docs/essays/latex/
  cosmos-essay.tex         # Main document
  cosmos-essay.bib         # Bibliography (or inline bibentry)
  latexmkrc                 # Stub loading shared config
  build/                    # Output directory (gitignored)
```

### Implementation Phases

**Phase 1: Setup** (30 min)
- Create directory structure
- Create latexmkrc stub loading shared config
- Create basic .tex file with preamble and title page

**Phase 2: Content Conversion** (1.5 hours)
- Convert markdown sections to LaTeX sections
- Apply semantic linefeeds
- Add hyperlinks for ModelChecker and ProofChecker mentions
- Create acknowledgment footer

**Phase 3: Bibliography** (30 min)
- Create .bib file with three academic references
- Add bibliography section to document
- Test citation rendering

**Phase 4: Polish and Build** (30 min)
- Verify XeLaTeX builds successfully
- Check hyperlinks work
- Review PDF output
- Fix any overfull hboxes

### Title Page References Section

On title page (like reference manuals):
```latex
{\normalsize\bfseries Primary References:}\\[0.3cm]
\href{URL1}{\textit{``Counterfactual Worlds''}}, Brast-McKie, \textit{J.~Phil.~Logic}, 2025.\\[0.2cm]
\href{URL2}{\textit{``Identity and Aboutness''}}, Brast-McKie, \textit{J.~Phil.~Logic}, 2021.\\[0.2cm]
\href{URL3}{\textit{``The Construction of Possible Worlds''}}, Brast-McKie, (under review), 2025.\\[1cm]
```

### In-Text GitHub Links

In the essay text where ModelChecker and ProofChecker are mentioned:
```latex
The \href{https://github.com/benbrastmckie/ProofChecker}{\texttt{ProofChecker}} implements...
...aligns with the \href{https://github.com/benbrastmckie/ModelChecker}{\texttt{ModelChecker}} which...
```

## Decisions

1. **Location**: Place in `docs/essays/latex/` to keep essays organized separately from theory documentation
2. **Bibliography**: Use inline \bibentry or minimal .bib file (essay doesn't heavily cite)
3. **Notation packages**: Skip logos-notation.sty since no formal logic notation needed
4. **Build system**: Reuse project's shared latexmkrc via stub file

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| XeLaTeX not installed | Build fails | Document pdflatex fallback, or use Nix shell |
| Long lines cause overfull hbox | Poor PDF rendering | Apply semantic linefeeds consistently |
| Bibliography setup complex | Wasted time | Use simple bibentry or hardcoded references |
| TEXINPUTS path issues | formatting.sty not found | Configure latexmkrc stub correctly |

## Appendix

### Search Queries Used
- Glob: `**/*Reference.tex`, `**/*.sty`, `**/*.bib`, `**/latexmkrc`, `**/essays/*.tex`
- Web: "ModelChecker benbrastmckie github"

### File Locations Referenced
- Essay source: `/home/benjamin/Projects/ProofChecker/docs/essays/cosmos-institute-essay.md`
- BimodalReference: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/BimodalReference.tex`
- LogosReference: `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex`
- Shared formatting: `/home/benjamin/Projects/ProofChecker/latex/formatting.sty`
- Shared latexmkrc: `/home/benjamin/Projects/ProofChecker/latex/latexmkrc`

### GitHub Repository URLs
- ProofChecker: https://github.com/benbrastmckie/ProofChecker
- ModelChecker: https://github.com/benbrastmckie/ModelChecker

## Next Steps

Run `/plan 465` to create a phased implementation plan based on these findings.
