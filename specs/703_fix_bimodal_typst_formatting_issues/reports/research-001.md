# Research Report: Task #703

**Task**: 703 - fix_bimodal_typst_formatting_issues
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:15:00Z
**Effort**: Small
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, Typst official documentation, Typst Forum, WebSearch
**Artifacts**: specs/703_fix_bimodal_typst_formatting_issues/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Typst BimodalReference.typ requires 5 formatting fixes to match LaTeX reference document styling
- All issues have clear Typst solutions using page margins, show rules, raw text, and outline customization
- Current URLblue color (rgb(0, 0, 150)) is a dark blue, not "light blue" as mentioned in task; task likely wants to verify/adjust this
- LaTeX 11pt article class uses 1.75in margins by default; current Typst uses 1.5in x-margin and 1.25in y-margin

## Context & Scope

This research investigates Typst formatting solutions for BimodalReference.typ to achieve visual parity with the LaTeX reference documents (LogosReference.tex, BimodalReference.tex). The task description references specific line numbers with FIX: and NOTE: tags, though these tags were not found in the current file (they may have been addressed or described differently).

The five formatting issues to address:
1. Match margins to LogosReference.tex
2. Set hyperlink colors to light blue
3. Format website URL in texttt-equivalent (monospace)
4. Center Abstract header with spacing
5. Format Contents header with spacing and style chapter/section entries

## Findings

### 1. Page Margins Configuration

**Current State (BimodalReference.typ line 40-44)**:
```typst
#set page(
  numbering: "1",
  number-align: center,
  margin: (x: 1.5in, y: 1.25in),
)
```

**LaTeX Default Margins**:
- LaTeX 11pt article class default: 1.75in margins on all sides ([LaTeX Page Layout - Wikibooks](https://en.wikibooks.org/wiki/LaTeX/Page_Layout))
- Neither LogosReference.tex nor BimodalReference.tex use the geometry package, so they use these defaults

**Recommended Solution**:
```typst
#set page(
  numbering: "1",
  number-align: center,
  margin: 1.75in,  // Match LaTeX 11pt article class defaults
)
```

Or for more precise control:
```typst
#set page(
  margin: (top: 1.75in, bottom: 1.75in, left: 1.75in, right: 1.75in),
)
```

**Reference**: [Page Function - Typst Documentation](https://typst.app/docs/reference/layout/page/)

### 2. Hyperlink Colors

**Current State (template.typ line 18)**:
```typst
#let URLblue = rgb(0, 0, 150)
```

**Current Usage (BimodalReference.typ line 56)**:
```typst
#show link: set text(fill: URLblue)
```

**Analysis**:
- The current URLblue color `rgb(0, 0, 150)` is actually a dark blue (R=0, G=0, B=150)
- The task mentions "light blue" which would be brighter
- The LaTeX formatting.sty uses `\definecolor{URLblue}{RGB}{0,0,150}` (same dark blue)
- Both documents are currently consistent with each other

**Options**:
1. **Keep current** (matches LaTeX): `rgb(0, 0, 150)` - dark blue
2. **Light blue option**: `rgb(30, 144, 255)` - dodger blue
3. **Standard web blue**: `blue` - Typst's built-in blue

**Recommended Solution** (if changing to light blue):
```typst
// In template.typ
#let URLblue = rgb(30, 144, 255)  // Light blue (Dodger Blue)
// Or
#let URLblue = rgb(65, 105, 225)  // Royal blue (still readable)
```

**Reference**: [Link Function - Typst Documentation](https://typst.app/docs/reference/model/link/)

### 3. Website URL in Monospace (texttt-equivalent)

**Current State (BimodalReference.typ line 87)**:
```typst
#link("https://www.benbrastmckie.com")[#raw("www.benbrastmckie.com")]
```

**LaTeX Equivalent (BimodalReference.tex line 83)**:
```latex
\texttt{\href{https://www.benbrastmckie.com}{www.benbrastmckie.com}}
```

**Analysis**:
- The current implementation already uses `#raw()` which renders in monospace font
- This is the correct approach for texttt-equivalent formatting
- The `raw()` function uses DejaVu Sans Mono by default at 0.8em size

**Verified Solution** (already correct):
```typst
#link("https://www.benbrastmckie.com")[#raw("www.benbrastmckie.com")]
```

**Alternative** (if raw styling needs adjustment):
```typst
#show raw.where(block: false): set text(font: "New Computer Modern Mono")
```

**Reference**: [Raw Text Function - Typst Documentation](https://typst.app/docs/reference/text/raw/)

### 4. Abstract Header Centering with Spacing

**Current State (BimodalReference.typ lines 105-109)**:
```typst
#page(numbering: none)[
  #align(center)[
    #text(size: 14pt, weight: "bold")[Abstract]
  ]
  #v(0.5em)
```

**LaTeX Equivalent (BimodalReference.tex lines 97-104)**:
```latex
\begin{abstract}
\noindent
This reference manual...
```

**Analysis**:
- The current implementation is mostly correct but could use refinement
- LaTeX's abstract environment centers the "Abstract" title with specific spacing

**Recommended Solution**:
```typst
#page(numbering: none)[
  #v(1em)  // Add top spacing
  #align(center)[
    #text(size: 14pt, weight: "bold")[Abstract]
  ]
  #v(1em)  // Consistent spacing after title

  // Abstract content follows...
]
```

**Reference**: [Align Function - Typst Documentation](https://typst.app/docs/reference/layout/align/)

### 5. Contents Header and Entry Styling

**Current State (BimodalReference.typ lines 118-123)**:
```typst
#show outline.entry.where(level: 1): it => {
  v(0.5em)
  strong(it)
}
#outline(title: "Contents", indent: auto)
```

**LaTeX Equivalent (BimodalReference.tex lines 106-108)**:
```latex
\pagestyle{empty}
\tableofcontents
\cleardoublepage
```

**Analysis**:
- Current implementation makes level-1 entries bold with 0.5em spacing above
- The title "Contents" is passed but could be styled for centering
- Chapter entries should be bold; section entries should be normal weight

**Recommended Solution**:
```typst
// Style the outline title
#align(center)[
  #v(1em)
  #text(size: 14pt, weight: "bold")[Contents]
  #v(1em)
]

// Bold chapter entries (level 1), normal weight for sections
#show outline.entry.where(level: 1): it => {
  v(0.5em)
  strong(it)
}

// Section entries (level 2+) use default styling

// Generate outline without title (we styled it manually above)
#outline(title: none, indent: auto)
```

**Alternative** (using outline title with styling):
```typst
// Center the outline title using a show rule
#show outline: it => {
  align(center)[
    #text(size: 14pt, weight: "bold")[Contents]
  ]
  v(1em)
  it
}

#show outline.entry.where(level: 1): it => {
  v(0.5em)
  strong(it)
}

#outline(title: none, indent: auto)
```

**Reference**: [Outline Function - Typst Documentation](https://typst.app/docs/reference/model/outline/), [Typst Forum - Bold First-Level Entries](https://forum.typst.app/t/how-to-style-table-of-contents-with-bold-first-level-entries-and-no-dots/4795)

## Recommendations

### Implementation Order

1. **Margins** (simplest change, single line modification)
2. **URL formatting** (verify current implementation is correct)
3. **Abstract header** (add spacing adjustments)
4. **Contents header** (style title and verify entry formatting)
5. **Hyperlink colors** (decide if light blue is really wanted)

### Code Changes Summary

**File: BimodalReference.typ**

| Line | Current | Recommended |
|------|---------|-------------|
| 43 | `margin: (x: 1.5in, y: 1.25in)` | `margin: 1.75in` |
| 107-109 | Abstract header block | Add `#v(1em)` before and after header |
| 118-123 | Outline entry styling | Add manual centered title, set `title: none` |

**File: template.typ** (if changing color)

| Line | Current | Recommended |
|------|---------|-------------|
| 18 | `rgb(0, 0, 150)` | `rgb(30, 144, 255)` or keep current |

## Decisions

1. **Margins**: Use uniform 1.75in margins to match LaTeX 11pt article class defaults
2. **URL formatting**: Current `#raw()` implementation is correct texttt-equivalent
3. **Link color**: Clarify with user whether to change from dark blue (LaTeX-matching) to light blue
4. **Abstract spacing**: Add 1em spacing above and below header
5. **Contents**: Style title manually with centering, keep entry bold styling

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Margin change affects page breaks | Review document pagination after change |
| Color change reduces readability | Test with light blue variants; ensure sufficient contrast |
| TOC styling breaks with deep nesting | Test with actual document structure |

## Appendix

### Search Queries Used
- "Typst page margins configuration set-page 2026"
- "Typst hyperlink color set link text fill 2026"
- "Typst raw monospace inline code text formatting 2026"
- "Typst outline table of contents styling chapter section formatting 2026"
- "Typst centered heading abstract custom spacing 2026"
- "LaTeX article class 11pt default margins inches"

### References

1. [Page Function - Typst Documentation](https://typst.app/docs/reference/layout/page/)
2. [Link Function - Typst Documentation](https://typst.app/docs/reference/model/link/)
3. [Raw Text Function - Typst Documentation](https://typst.app/docs/reference/text/raw/)
4. [Outline Function - Typst Documentation](https://typst.app/docs/reference/model/outline/)
5. [Align Function - Typst Documentation](https://typst.app/docs/reference/layout/align/)
6. [Typst Forum - Bold First-Level TOC Entries](https://forum.typst.app/t/how-to-style-table-of-contents-with-bold-first-level-entries-and-no-dots/4795)
7. [LaTeX Page Layout - Wikibooks](https://en.wikibooks.org/wiki/LaTeX/Page_Layout)
8. [Page Size and Margins - Overleaf](https://www.overleaf.com/learn/latex/Page_size_and_margins)

### Files Examined
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/BimodalReference.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/template.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/typst/notation/bimodal-notation.typ`
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/latex/BimodalReference.tex`
- `/home/benjamin/Projects/ProofChecker/latex/formatting.sty`
