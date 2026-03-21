# Research Report: Task #822

**Task**: 822 - improve_syntax_term_algebra_structure
**Started**: 2026-02-03T12:00:00Z
**Completed**: 2026-02-03T12:30:00Z
**Effort**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis, web search for formal syntax best practices
**Artifacts**: specs/822_improve_syntax_term_algebra_structure/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The current structure of `02-ConstitutiveFoundation.tex` has a forward reference problem: Well-formed formulas (Definition 1, line 40) reference "terms" before Term Algebra is defined (Definition 7, line 202)
- Standard mathematical logic textbooks define terms before formulas, then distinguish open formulas (with free variables) from closed formulas/sentences (no free variables)
- The document is missing explicit definitions for open formulas and sentences (closed formulas)
- Recommended approach: Restructure Section 1.1 to define Term Algebra first, then WFFs, then add definitions for free variables in formulas and distinguish open/closed formulas

## Context and Scope

### Problem Statement

The task description identifies two TODO comments in `02-ConstitutiveFoundation.tex`:
1. **Line 38**: "This should be improved to specify the term algebra, then how formulas are defined, then open and closed sentences"
2. **Line 200**: "the term algebra should be integrated into the more purely syntactic definitions above in order to improve the definition of a formula, open sentence, and sentence above"

### Current Structure Analysis

The current document structure (Section 1: Constitutive Foundation) is:

| Subsection | Lines | Content |
|------------|-------|---------|
| 1.1 Syntactic Primitives | 17-36 | Lists primitive symbols (variables, constants, functions, predicates, connectives) |
| Definition 1: WFFs | 40-53 | Defines well-formed formulas, references "terms" ($t_i$) |
| 1.2 Derived Operators | 58-69 | Material conditional, biconditional, quantification notation |
| 1.3 Constitutive Frame | 78-103 | State lattice, temporal order, task relation |
| 1.4 State Modality | 109-122 | Possible, compatible, maximal, world-states |
| 1.5 Task Constraints | 128-147 | L/R-Parthood, containment, maximality |
| 1.6 Constitutive Model | 154-188 | Interpretation function for symbols |
| 1.7 Variable Assignment | 194-253 | **Term Algebra (Definition 7)**, variant assignment, term extension |
| 1.8 Verification/Falsification | 259-416 | Semantic clauses |
| ... | ... | Remaining subsections |

### The Forward Reference Problem

In Definition 1 (WFFs, line 40-53):
```latex
\metaA, \metaB \Define{}
  F(t_1, \ldots, t_n) \mid
  (\lambda v.\metaA)(t) \mid
  ...
```

The metavariables `$t_1, \ldots, t_n$` and `$t$` range over **terms**, but terms are not defined until Definition 7 (line 202-222). This violates the principle that definitions should only reference previously-defined concepts.

## Findings

### Standard Presentation Order (Mathematical Logic)

Based on research into standard textbook presentations of first-order logic syntax:

1. **Terms** are defined first:
   - Variables are terms
   - Constants (0-ary function symbols) are terms
   - If $f$ is an $n$-ary function symbol and $t_1, \ldots, t_n$ are terms, then $f(t_1, \ldots, t_n)$ is a term

2. **Atomic formulas** are defined next:
   - If $R$ is an $n$-ary predicate and $t_1, \ldots, t_n$ are terms, then $R(t_1, \ldots, t_n)$ is atomic
   - Equality: if $t_1, t_2$ are terms, then $t_1 = t_2$ is atomic

3. **Well-formed formulas** are built from atomic formulas:
   - Atomic formulas are WFFs
   - If $\metaA$, $\metaB$ are WFFs, then $\neg\metaA$, $\metaA \land \metaB$, etc. are WFFs
   - If $\metaA$ is a WFF and $v$ is a variable, then $\forall v. \metaA$ is a WFF

4. **Free variables** in formulas are defined:
   - Extends the definition from terms to formulas
   - Quantifiers bind variables, reducing free variable sets

5. **Open vs. Closed formulas** are distinguished:
   - **Open formula**: contains at least one free variable
   - **Closed formula** (sentence): no free variables, can be assigned a truth value

### Current Lean Implementation Structure

The Lean implementation in `Theories/Logos/SubTheories/Foundation/Syntax.lean` already follows the correct order:

1. Lines 38-66: `Term` inductive type (var, const, app)
2. Lines 52-55: `freeVars` for terms
3. Lines 60-64: `subst` (substitution) for terms
4. Lines 74-93: `ConstitutiveFormula` inductive type (uses `Term`)

The LaTeX documentation should mirror this structure.

### Missing Definitions

The current LaTeX document is missing:

1. **Free variables for formulas**: The document defines $\FV(t)$ for terms (line 209-214) but never extends this to formulas
2. **Open formula**: A formula with at least one free variable
3. **Closed formula/Sentence**: A formula with no free variables

These distinctions are important for:
- Defining when a formula can be evaluated for truth
- Understanding quantifier scope
- Distinguishing propositions (sentences) from predicates (open formulas)

### Related Content in Dynamical Foundation

The `03-DynamicsFoundation.tex` file (Section 2) extends the Constitutive syntax. If Section 1 properly defines open/closed formulas, Section 2 can reference these concepts when discussing dynamical formulas.

## Recommendations

### Proposed New Structure for Section 1.1

Restructure the "Syntactic Primitives" subsection as follows:

**1.1 Syntactic Primitives** (keep current content about alphabet/symbols)

**1.2 Term Algebra** (new subsection, moved from 1.7)
- Definition: Terms (move Definition 7, currently lines 202-222)
- Definition: Free variables of terms
- Definition: Substitution for terms
- Remark: Constants as 0-ary functions

**1.3 Well-Formed Formulas** (currently Definition 1)
- Definition: WFFs (now references previously-defined terms)
- Definition: Free variables of formulas (new)
- Definition: Open formula (new)
- Definition: Sentence/Closed formula (new)

**1.4 Derived Operators** (currently 1.2)
- Keep as is

**1.5 Constitutive Frame** (currently 1.3)
- Keep as is

...and so on, with subsequent subsections renumbered.

### Specific Changes Required

1. **Move Term Algebra** (Definition 7, lines 202-227) to immediately after Section 1.1 (after line 36)

2. **Update WFF Definition** (lines 40-53) to:
   - Reference the now-defined Term algebra
   - Add explicit atomic formula case
   - Keep the current structure but ensure terms are well-defined

3. **Add new definitions** after WFFs:
   ```latex
   \begin{definition}[Free Variables of Formulas]\label{def:fv-formula}
   The \emph{free variables} $\FV(\metaA)$ of a formula are defined by:
   \begin{align*}
     \FV(F(t_1, \ldots, t_n)) &= \bigcup_{i=1}^n \FV(t_i) \\
     \FV((\lambda v.\metaA)(t)) &= (\FV(\metaA) \setminus \{v\}) \cup \FV(t) \\
     \FV(\forall \metaA) &= \FV(\metaA) \\
     \FV(\top) = \FV(\bot) &= \emptyset \\
     \FV(\neg\metaA) &= \FV(\metaA) \\
     \FV(\metaA \land \metaB) = \FV(\metaA \lor \metaB) &= \FV(\metaA) \cup \FV(\metaB) \\
     \FV(\metaA \equiv \metaB) &= \FV(\metaA) \cup \FV(\metaB)
   \end{align*}
   \end{definition}

   \begin{definition}[Open and Closed Formulas]\label{def:open-closed}
   A formula $\metaA$ is:
   \begin{itemize}
     \item \emph{open} if $\FV(\metaA) \neq \emptyset$
     \item \emph{closed} (a \emph{sentence}) if $\FV(\metaA) = \emptyset$
   \end{itemize}
   \end{definition}
   ```

4. **Update Variable Assignment section** (1.7) to:
   - Remove Term Algebra definition (now in 1.2)
   - Keep Definition: Variable Assignment
   - Keep Definition: Variant Assignment
   - Keep Definition: Term Extension

5. **Update cross-references**: Ensure any `\Cref{def:term-algebra}` references work with new location

### Impact Assessment

- **Low risk**: Changes are structural reorganization, not semantic changes
- **No Lean code changes needed**: The Lean implementation already has the correct structure
- **Improved pedagogical flow**: Readers will encounter definitions in logical order
- **Better alignment**: LaTeX documentation will mirror Lean implementation structure

## Decisions

1. **Term Algebra placement**: Move to Section 1.2 (immediately after Syntactic Primitives)
2. **New definitions needed**: Free variables for formulas, open formula, closed formula (sentence)
3. **Subsection renumbering**: All subsections after 1.1 will be renumbered

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Cross-reference breakage | Carefully update all `\Cref` and `\cref` references |
| Definition numbering changes | LaTeX handles automatic renumbering; verify PDF output |
| Lean source links may need updates | Verify `\leansrc` commands point to correct locations |
| Large diff may be hard to review | Consider splitting into multiple phases if needed |

## Appendix

### Search Queries Used

1. "formal syntax presentation first-order logic term algebra formula definition order textbook"
2. '"term algebra" "well-formed formulas" "open formula" "closed formula" "sentence" definition order presentation'

### Key References

- [Well-formed formula - Wikipedia](https://en.wikipedia.org/wiki/Well-formed_formula)
- [Open formula - Wikipedia](https://en.wikipedia.org/wiki/Open_formula)
- [Sentence (mathematical logic) - Wikipedia](https://en.wikipedia.org/wiki/Sentence_(mathematical_logic))
- [First-Order Logic: Syntax, Semantics, Resolution (Yale)](https://www.cs.yale.edu/homes/piskac/teaching/decpro-729/fol.pdf)
- [Open Logic Project: Syntax of First-Order Logic](https://builds.openlogicproject.org/content/first-order-logic/syntax-and-semantics/syntax.pdf)

### Files Analyzed

- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` (555 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/SubTheories/Foundation/Syntax.lean` (193 lines)
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` (partial, 150 lines)
