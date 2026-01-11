# Research Report: Task #371

**Task**: Refactor LaTeX reference manual titles
**Date**: 2026-01-11
**Focus**: Professional LaTeX title formatting for math, logic, and computer science manuals

## Summary

Research identified best practices for creating elegant, professional title pages for academic reference manuals. The recommended approach uses a custom `titlepage` environment with horizontal rules, hierarchical typography, and proper hyperlink formatting for author websites and paper references.

## Findings

### Current State

**BimodalReference.tex**:
- Uses simple `\maketitle` command
- Title: "Bimodal TM Logic: A Reference Manual"
- Author: "ProofChecker Project"
- No subtitle separation, no website links, no paper references

**LogosReference.tex**:
- Uses simple `\maketitle` command
- Title: "Logos: A Reference Manual"
- Author: "Benjamin Brast-McKie"
- No subtitle, no website links, no paper references

### Recommended Design Pattern

The formal book title page pattern from [LaTeX Templates](https://www.latextemplates.com/template/formal-book-title-page) is ideal for academic manuals:

1. **Horizontal rules** to frame the title section
2. **Main title** in large bold font
3. **Subtitle** in smaller italic or regular font
4. **Author name** centered with credentials
5. **Website link** using `\texttt{}` with `\href{}`
6. **Paper references** as a "Based on" or "See also" section

### Key LaTeX Techniques

**Horizontal Rule Command**:
```latex
\newcommand{\HRule}{\rule{\linewidth}{0.5mm}}
```

**Custom Title Page Structure**:
```latex
\begin{titlepage}
\begin{center}
    \vspace*{2cm}

    \HRule\\[0.4cm]
    {\Huge \bfseries Reference Manual}\\[0.2cm]
    \HRule\\[1cm]

    {\Large\itshape Bimodal Logic for Tense and Modality}\\[2cm]

    {\large Benjamin Brast-McKie}\\[0.3cm]
    \texttt{\href{https://www.benbrastmckie.com}{www.benbrastmckie.com}}\\[2cm]

    {\normalsize Based on:}\\[0.3cm]
    \href{URL}{Paper Title}\\[1cm]

    \vfill
    {\large \today}
\end{center}
\end{titlepage}
```

**Font Size Hierarchy** (largest to smallest):
- `\Huge` - Main title
- `\huge` - Alternative main title
- `\LARGE` - Section headers
- `\Large` - Subtitle
- `\large` - Author name, date
- `\normalsize` - Reference text
- `\small` - URLs, fine print

### Hyperlink Formatting

The `hyperref` package (already loaded via formatting.sty) provides:
- `\href{URL}{display text}` - Clickable links
- `\url{URL}` - Typeset URL as link
- `\texttt{}` - Monospace font for URLs (combines well with `\href`)

### Design Considerations for Logic Manuals

1. **Clean, formal appearance** - Befitting academic/mathematical content
2. **Clear hierarchy** - Main title prominent, subtitle explanatory
3. **Professional attribution** - Author name and website
4. **Scholarly context** - Links to foundational papers
5. **Consistent styling** - Both manuals should share design language

## Recommendations

### For BimodalReference.tex

1. **Main Title**: "Reference Manual" (in `\Huge \bfseries`)
2. **Subtitle**: "Bimodal Logic for Tense and Modality" (in `\Large\itshape`)
3. **Author**: "Benjamin Brast-McKie" with website link
4. **Paper Reference**: "The Construction of Possible Worlds" with PDF link

### For LogosReference.tex

1. **Main Title**: "Reference Manual" (in `\Huge \bfseries`)
2. **Subtitle**: "Logos: A Hyperintensional Logic System" (in `\Large\itshape`)
3. **Author**: "Benjamin Brast-McKie" with website link
4. **Paper References**: Both Springer papers with DOI links

### Implementation Approach

1. Define `\HRule` command in each document (or in shared formatting.sty)
2. Replace `\maketitle` with custom `titlepage` environment
3. Remove old `\title`, `\author`, `\date` commands
4. Keep abstract section after title page
5. Ensure hyperref color settings match document style

## References

- [LaTeX Templates - Formal Book Title Page](https://www.latextemplates.com/template/formal-book-title-page)
- [Overleaf - Customising Title Pages](https://www.overleaf.com/learn/latex/How_to_Write_a_Thesis_in_LaTeX_(Part_5)%3A_Customising_Your_Title_Page_and_Abstract)
- [LaTeX Wikibooks - Title Creation](https://en.wikibooks.org/wiki/LaTeX/Title_Creation)
- [CTAN - Title Page Examples (PDF)](https://tug.ctan.org/info/latex-samples/TitlePages/titlepages.pdf)

## Next Steps

1. Create implementation plan with specific LaTeX code for each document
2. Test compilation after changes
3. Verify hyperlinks work correctly in generated PDF
4. Ensure consistent styling between both reference manuals
