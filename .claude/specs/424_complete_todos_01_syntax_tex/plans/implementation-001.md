# Implementation Plan: Task #424

**Task**: Complete the TODOs in 01-Syntax.tex
**Version**: 001
**Created**: 2026-01-11
**Language**: latex

## Overview

This task addresses 6 TODOs in the Bimodal syntax documentation file. The changes improve presentation consistency by:
1. Using inline BNF notation with explanatory tables (matching 02-Semantics.tex style)
2. Adding a `\swap` macro to the notation package
3. Restructuring the temporal swap definition for clarity
4. Minor terminology updates

## Phases

### Phase 1: Add \swap Macro to Notation Package

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Define `\swap` macro in bimodal-notation.sty
2. Ensure it renders as `⟨S⟩` (angle brackets with S)

**Files to modify**:
- `Theories/Bimodal/latex/assets/bimodal-notation.sty` - Add macro definition

**Steps**:
1. Open bimodal-notation.sty
2. Add in the "Formula Syntax" section:
   ```latex
   \newcommand{\swap}{\langle S \rangle}
   ```
3. Save file

**Verification**:
- Macro is syntactically correct (no LaTeX errors)

---

### Phase 2: Reformat Formula Definition (TODO 1)

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Replace stacked align* with inline BNF notation
2. Merge the existing "Notation" subsection table into the definition
3. Remove the now-redundant Notation subsection

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/01-Syntax.tex` - Lines 6-43

**Steps**:
1. Replace Definition[Formula] (lines 12-23) with inline BNF:
   ```latex
   \begin{definition}[Formula]
   The type \texttt{Formula} is defined by:
   \[
     \varphi, \psi ::= p \mid \falsum \mid \varphi \imp \psi \mid \nec\varphi \mid \allpast\varphi \mid \allfuture\varphi
   \]
   where $p$ ranges over propositional atoms (type \texttt{String}).
   \end{definition}
   ```
2. Keep the explanatory table but update:
   - Remove separate "Notation" subsection header
   - Add "Reading" column
   - Rename "Falsity" to "Bottom" (TODO 2)
3. Remove TODO comments at lines 10 and 27

**Verification**:
- Definition is concise and on one line
- Table follows definition with all 6 constructors explained

---

### Phase 3: Add Tables for Derived Operators (TODO 3)

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add explanatory table after Propositional definition
2. Add explanatory table after Modal definition
3. Add explanatory table after Temporal definition

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/01-Syntax.tex` - Lines 44-73

**Steps**:
1. After Definition[Propositional] (line 54), add table:
   ```latex
   \begin{center}
   \begin{tabular}{@{}llll@{}}
   \toprule
   Symbol & Name & Lean & Reading \\
   \midrule
   $\lneg\varphi$ & Negation & \texttt{neg} & ``not $\varphi$'' \\
   $\varphi \land \psi$ & Conjunction & \texttt{and} & ``$\varphi$ and $\psi$'' \\
   $\varphi \lor \psi$ & Disjunction & \texttt{or} & ``$\varphi$ or $\psi$'' \\
   \bottomrule
   \end{tabular}
   \end{center}
   ```

2. After Definition[Modal] (line 62), add table:
   ```latex
   \begin{center}
   \begin{tabular}{@{}llll@{}}
   \toprule
   Symbol & Name & Lean & Reading \\
   \midrule
   $\poss\varphi$ & Possibility & \texttt{pos} & ``possibly $\varphi$'' \\
   \bottomrule
   \end{tabular}
   \end{center}
   ```

3. After Definition[Temporal] (line 73), add table:
   ```latex
   \begin{center}
   \begin{tabular}{@{}llll@{}}
   \toprule
   Symbol & Name & Lean & Reading \\
   \midrule
   $\somepast\varphi$ & Sometime past & \texttt{some\_past} & ``at some past time, $\varphi$'' \\
   $\somefuture\varphi$ & Sometime future & \texttt{some\_future} & ``at some future time, $\varphi$'' \\
   $\always\varphi$ & Always & \texttt{always} & ``at all times, $\varphi$'' \\
   $\sometimes\varphi$ & Sometimes & \texttt{sometimes} & ``at some time, $\varphi$'' \\
   \bottomrule
   \end{tabular}
   \end{center}
   ```

4. Remove TODO comments at lines 56 and 64

**Verification**:
- Each derived operator definition is followed by a consistent table
- All derived operators are documented with Lean names and readings

---

### Phase 4: Restructure Temporal Swap Definition (TODOs 5, 6)

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace `\text{swap}` with `\swap` macro
2. Restructure definition with labeled case groups
3. Update the involution theorem to use `\swap`

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/01-Syntax.tex` - Lines 75-96

**Steps**:
1. Replace Definition[Temporal Swap] (lines 83-92) with labeled groups:
   ```latex
   \begin{definition}[Temporal Swap]
   The function $\swap : \texttt{Formula} \to \texttt{Formula}$ is defined recursively:

   \textbf{Base cases:}
   \begin{align*}
     \swap(p) &= p \\
     \swap(\falsum) &= \falsum
   \end{align*}

   \textbf{Propositional case:}
   \begin{align*}
     \swap(\varphi \imp \psi) &= \swap(\varphi) \imp \swap(\psi)
   \end{align*}

   \textbf{Modal case:}
   \begin{align*}
     \swap(\nec\varphi) &= \nec\swap(\varphi)
   \end{align*}

   \textbf{Temporal cases (the essential swap):}
   \begin{align*}
     \swap(\allpast\varphi) &= \allfuture\swap(\varphi) \\
     \swap(\allfuture\varphi) &= \allpast\swap(\varphi)
   \end{align*}
   \end{definition}
   ```

2. Update Theorem[Involution] (lines 94-96):
   ```latex
   \begin{theorem}[Involution]
   $\swap(\swap(\varphi)) = \varphi$
   \end{theorem}
   ```

3. Remove TODO comments at lines 79 and 81

**Verification**:
- `\swap` macro renders correctly
- Definition shows clear case structure mirroring Lean code

---

### Phase 5: Verify and Clean Up

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify document compiles without errors
2. Review PDF output for visual appearance
3. Ensure all TODO comments are removed

**Files to modify**:
- None (verification only)

**Steps**:
1. Build the document:
   ```bash
   cd Theories/Bimodal/latex
   pdflatex BimodalReference.tex
   ```
2. Check for errors/warnings in build output
3. Open PDF and review 01-Syntax section visually
4. Verify no TODO comments remain:
   ```bash
   grep -n "TODO" subfiles/01-Syntax.tex
   ```

**Verification**:
- Build succeeds with no errors
- PDF renders tables correctly with proper alignment
- No overfull/underfull hbox warnings for modified sections
- Zero TODO comments in file

---

## Dependencies

- None (self-contained LaTeX changes)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Table column widths cause overfull hbox | Low | Medium | Adjust column widths or use `p{width}` columns |
| `\swap` macro conflicts with existing command | Low | Low | Check for existing definition before adding |
| Build fails due to missing package | Medium | Low | bimodal-notation.sty already loads required packages |

## Success Criteria

- [ ] All 6 TODOs addressed
- [ ] Document builds without errors
- [ ] Tables consistently formatted after all definitions
- [ ] `\swap` macro used throughout Temporal Swap section
- [ ] No TODO comments remain in 01-Syntax.tex

## Rollback Plan

If implementation causes issues:
1. `git checkout -- Theories/Bimodal/latex/subfiles/01-Syntax.tex`
2. `git checkout -- Theories/Bimodal/latex/assets/bimodal-notation.sty`
