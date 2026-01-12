# Implementation Plan: Task #422

**Task**: Complete TODOs in Introduction.tex
**Version**: 001
**Created**: 2026-01-12
**Language**: latex

## Overview

Restructure the Introduction.tex file by merging the "Implementation Status" and "Source Code" subsections into a single "Project Structure" subsection that explains each component with its implementation status inline. Add the deduction theorem to the metalogic items.

## Phases

### Phase 1: Restructure Introduction.tex

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Remove the separate "Implementation Status" subsection
2. Rename "Source Code" to "Project Structure"
3. Add brief explanations for each directory
4. Integrate implementation status into each item
5. Add Deduction Theorem to the metalogic items

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/00-Introduction.tex` - Complete restructure

**Steps**:

1. **Remove Implementation Status subsection** (lines 13-24):
   - Delete the `\subsection*{Implementation Status}` header and the TODO comment
   - Delete the itemize block with status bullets

2. **Rename and restructure Source Code subsection** (lines 26-37):
   - Change `\subsection*{Source Code}` to `\subsection*{Project Structure}`
   - Remove the TODO comment
   - Expand each item with:
     - Brief explanation for non-specialists
     - Implementation status (Complete/Partial/Infrastructure)

3. **New Project Structure content**:
   ```latex
   \subsection*{Project Structure}

   The Lean 4 implementation is in the \texttt{Bimodal/} directory:
   \begin{itemize}
     \item \texttt{Syntax/} -- Defines the formula language with 6 primitive constructors and derived operators.
     \textbf{Complete.}
     \item \texttt{ProofSystem/} -- Axioms (14 schemata) and inference rules (7 rules) forming a Hilbert-style proof system.
     \textbf{Complete.}
     \item \texttt{Semantics/} -- Task frames model possible worlds; world histories model time; truth conditions define meaning.
     \textbf{Complete.}
     \item \texttt{Metalogic/} -- Soundness theorem (proven: all axioms valid, rules preserve validity), deduction theorem (proven: enables assumption introduction), and completeness infrastructure (Lindenbaum lemma, canonical model axiomatized).
     \textbf{Soundness and deduction complete; completeness pending.}
     \item \texttt{Theorems/} -- Perpetuity principles and modal theorems derived from the axiom system.
     \textbf{Partial.}
   \end{itemize}
   ```

**Verification**:
- File compiles with pdflatex without errors
- No TODO comments remain in the file
- All subsections properly structured with semantic linefeeds

---

## Dependencies

- None (standalone LaTeX file edit)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| LaTeX syntax error | Low | Low | Verify with pdflatex after edit |
| Line break issues | Low | Low | Follow semantic linefeed convention |

## Success Criteria

- [ ] All 3 TODO comments removed
- [ ] "Implementation Status" subsection removed
- [ ] "Source Code" renamed to "Project Structure"
- [ ] Each directory has brief explanation
- [ ] Deduction theorem mentioned in Metalogic item
- [ ] File compiles successfully

## Rollback Plan

Restore original file from git: `git checkout -- Theories/Bimodal/latex/subfiles/00-Introduction.tex`
