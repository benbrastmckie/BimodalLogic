# Research Report: Task #424

**Task**: Complete the TODOs in 01-Syntax.tex
**Date**: 2026-01-11
**Focus**: LaTeX formatting best practices for syntax documentation

## Summary

The 01-Syntax.tex file contains 6 TODOs related to presentation style, notation consistency, and alignment issues.
Research focused on LaTeX BNF packages, standard temporal logic notation, and inductive definition formatting.
The main recommendations are to use tables following definitions, adopt standard temporal notation, and define semantic macros for better maintainability.

## Findings

### TODO 1 (Line 10): Formula Definition Presentation

**Current Issue**: The stacked `align*` presentation of the Formula definition looks cluttered.
User prefers inline BNF notation with a follow-up explanatory table.

**Research**:
- LaTeX packages [simplebnf](https://github.com/Zeta611/simplebnf) and [backnaur](https://ctan.math.washington.edu/tex-archive/macros/latex/contrib/backnaur/backnaur.pdf) support both inline and aligned BNF presentations
- The 02-Semantics.tex file in the same project uses tables effectively after definitions
- Inline BNF followed by explanatory tables is common in formal language documentation

**Recommendation**: Replace the stacked align* with inline BNF grammar notation, then provide a table explaining each constructor's name, Lean identifier, and intuitive reading.

**Example Format**:
```latex
\begin{definition}[Formula]
The type \texttt{Formula} is defined by:
\[
  \varphi, \psi ::= p \mid \falsum \mid \varphi \imp \psi \mid \nec\varphi \mid \allpast\varphi \mid \allfuture\varphi
\]
where $p$ ranges over propositional atoms (type \texttt{String}).
\end{definition}

\begin{center}
\begin{tabular}{@{}llll@{}}
\toprule
Symbol & Name & Lean & Reading \\
\midrule
$p$ & Atom & \texttt{atom s} & Propositional atom \\
$\falsum$ & Bottom & \texttt{bot} & Falsity \\
...
\end{tabular}
\end{center}
```

---

### TODO 2 (Line 27): Rename 'Falsity' to 'Bottom'

**Current Issue**: The notation table uses "Falsity" as the name for `\falsum`.

**Research**:
- In formal logic, "bottom" (⊥) is the standard name for the always-false proposition
- Lean uses `.bot` naming convention
- "Bottom" is more common in type theory and proof assistants

**Recommendation**: Simple text change: replace "Falsity" with "Bottom" in the Notation table at line 35.

---

### TODO 3 (Line 56): Alignment and Tables for Derived Operators

**Current Issue**: The '(possibility)' annotation doesn't align with annotations in adjacent definitions.
Tables would better explain the derived operators.

**Research**:
- The 02-Semantics.tex file uses tables after definitions with columns: Lean Field, Type, Description
- Consistent formatting across Modal and Temporal derived operators improves readability
- Separate the definition (math) from explanation (table)

**Recommendation**: For each derived operator definition (Propositional, Modal, Temporal):
1. Keep the align* block for the mathematical definitions
2. Follow each with a table explaining Symbol, Name, Lean accessor, and Reading

**Example for Modal**:
```latex
\begin{definition}[Modal]
\begin{align*}
  \poss\varphi &\coloneqq \lneg\nec\lneg\varphi
\end{align*}
\end{definition}

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

---

### TODO 4 (Line 64): The \sometimes Operator Symbol

**Current Issue**: The `\sometimes` operator (currently `\triangledown`) may not look right.
User previously used `\rotatebox[origin=c]{180}{$\triangle$}` which seems overly complex.

**Research**:
- Per [Stanford Encyclopedia of Philosophy](https://plato.stanford.edu/entries/logic-temporal/), standard temporal logic uses:
  - **F** (sometimes future / eventually)
  - **P** (sometimes past)
  - Combined "sometime" (any time): **E φ = P φ ∨ φ ∨ F φ**
  - Combined "always" (all times): **A φ = H φ ∧ φ ∧ G φ**
- The current bimodal-notation.sty defines `\triangledown` which produces ▽
- Using a rotated triangle via `\rotatebox` adds unnecessary complexity and dependency on graphicx
- Standard temporal logic doesn't typically use triangle symbols for "sometimes"

**Options**:
1. **Keep `\triangledown`**: Simple, visually dual to `\triangle` for "always"
2. **Use letter E**: More standard per temporal logic literature
3. **Use `\lozenge` or `\Diamond`**: Matches modal possibility convention

**Recommendation**: Keep `\triangledown` since it visually pairs with `\triangle` (always) and is already defined in bimodal-notation.sty.
Remove the TODO comment - the current definition is cleaner than the rotated version.
Add a note in the documentation explaining the notation choice.

---

### TODO 5 (Line 79): Replace \text{swap} with Semantic Macro

**Current Issue**: Using `\text{swap}` looks inelegant and lacks consistency.
User suggests defining `\swap` as `\langle S \rangle`.

**Research**:
- Semantic macros improve consistency and allow global style changes
- Angular brackets with letter is a common notation for operations in formal semantics
- The [modal logic typesetting guide](https://www.johndcook.com/blog/2018/10/29/typesetting-modal-logic/) recommends using consistent semantic commands

**Recommendation**: Add to bimodal-notation.sty:
```latex
\newcommand{\swap}{\langle S \rangle}
```

Then update the definition to use `\swap(\varphi)` instead of `\text{swap}(\varphi)`.

---

### TODO 6 (Line 81): Explicit Inductive Form for Temporal Swap

**Current Issue**: The swap definition should be more explicitly inductive to mirror Lean code structure.

**Research**:
- Looking at recursive definitions in formal logic (e.g., [Wikipedia: Recursive definition](https://en.wikipedia.org/wiki/Recursive_definition)), they typically separate base cases from recursive cases
- Lean's pattern matching naturally groups cases by constructor
- The 01-ConstitutiveFoundation.tex file uses itemize for structured definitions

**Recommendation**: Restructure using explicit case grouping:

**Option A - Labeled Groups**:
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

**Option B - Match-style**:
```latex
\begin{definition}[Temporal Swap]
\begin{align*}
  \swap(\varphi) &= \begin{cases}
    p & \text{if } \varphi = p \\
    \falsum & \text{if } \varphi = \falsum \\
    \swap(\psi_1) \imp \swap(\psi_2) & \text{if } \varphi = \psi_1 \imp \psi_2 \\
    \nec\swap(\psi) & \text{if } \varphi = \nec\psi \\
    \allfuture\swap(\psi) & \text{if } \varphi = \allpast\psi \\
    \allpast\swap(\psi) & \text{if } \varphi = \allfuture\psi
  \end{cases}
\end{align*}
\end{definition}
```

**Recommendation**: Use Option A (labeled groups) as it better mirrors the Lean `match` structure while remaining readable.

---

## Recommendations Summary

| TODO | Line | Action | Effort |
|------|------|--------|--------|
| 1 | 10 | Inline BNF + table | Medium |
| 2 | 27 | Rename Falsity → Bottom | Trivial |
| 3 | 56 | Add tables after derived operator definitions | Medium |
| 4 | 64 | Keep `\triangledown`, remove TODO | Trivial |
| 5 | 79 | Define `\swap` macro in .sty, update usage | Easy |
| 6 | 81 | Restructure with labeled groups | Medium |

## References

- [simplebnf LaTeX package](https://github.com/Zeta611/simplebnf) - BNF typesetting
- [backnaur LaTeX package](https://ctan.math.washington.edu/tex-archive/macros/latex/contrib/backnaur/backnaur.pdf) - BNF with inline support
- [Stanford Encyclopedia: Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) - Standard notation (H, G, P, F operators)
- [Typesetting Modal Logic in LaTeX](https://www.johndcook.com/blog/2018/10/29/typesetting-modal-logic/) - `\Box` and `\Diamond` recommendations
- [temporal-logic CTAN package](https://ctan.org/pkg/temporal-logic) - LTL/MTL operators
- Existing project files: 02-Semantics.tex, 01-ConstitutiveFoundation.tex - formatting patterns

## Next Steps

1. Add `\swap` macro to bimodal-notation.sty
2. Implement changes to 01-Syntax.tex following recommendations
3. Verify compilation with `pdflatex`
4. Review visual appearance and adjust table column widths if needed
