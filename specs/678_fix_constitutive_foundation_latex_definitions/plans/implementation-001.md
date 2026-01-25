# Implementation Plan: Task #678

**Task**: Fix Constitutive Foundation LaTeX definitions  
**Version**: 001  
**Created**: 2026-01-25  
**Language**: latex  
**Session ID**: sess_1769376608_bbf804

## Overview

Add four missing definitions to `02-ConstitutiveFoundation.tex` with proper notation support. The key insight is using `\Define` (producing `::=`) for inductive/BNF definitions vs `\define` (producing `:=`) for definitional equations.

## Phases

### Phase 0: Add \Define Macro

**Estimated effort**: 15 minutes  
**Status**: [NOT STARTED]

**Objectives**:
1. Add `\Define` macro to `logos-notation.sty` for BNF-style definitions
2. Add `\FV` macro for free variables notation

**Files to modify**:
- `Theories/Logos/latex/assets/logos-notation.sty`

**Steps**:
1. Add after line 61 (Derived Relations section):
   ```latex
   % --- Inductive Definition Syntax ---
   \newcommand{\Define}{\Coloneq}         % BNF-style definition (::=)
   % Note: \define is \coloneqq (:=) from notation-standards.sty
   
   % --- Free Variables ---
   \newcommand{\FV}{\mathsf{FV}}           % Free variables function
   ```

**Verification**:
- Build LaTeX document to confirm no macro conflicts
- Verify `\Define` produces `::=` in output

---

### Phase 1: Add Term Algebra Definition

**Estimated effort**: 20 minutes  
**Status**: [NOT STARTED]

**Objectives**:
1. Add formal term algebra definition before line 132
2. Remove FIX comment at line 130

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` (line 130)

**Steps**:
1. Replace the FIX comment (line 130) with:
   ```latex
   \begin{definition}[Term Algebra]\label{def:term-algebra}
   The set $\Term$ of \emph{terms} is defined inductively:
   \[
     t \Define x \mid c \mid f(t_1, \ldots, t_n)
   \]
   where $x$ ranges over variables, $c$ over individual constants (0-place function symbols), and $f$ over $n$-place function symbols.

   The \emph{free variables} $\FV(t)$ of a term are defined by:
   \begin{align*}
     \FV(x) &= \{x\} \\
     \FV(c) &= \emptyset \\
     \FV(f(t_1, \ldots, t_n)) &= \bigcup_{i=1}^n \FV(t_i)
   \end{align*}

   \emph{Substitution} $t[s/x]$ (replacing $x$ with $s$ in $t$) is defined by:
   \begin{align*}
     y[s/x] &= \begin{cases} s & \text{if } y = x \\ y & \text{otherwise} \end{cases} \\
     c[s/x] &= c \\
     f(t_1, \ldots, t_n)[s/x] &= f(t_1[s/x], \ldots, t_n[s/x])
   \end{align*}
   \end{definition}

   \noindent
   See \leansrc{Logos.SubTheories.Foundation.Syntax}{Term} for the Lean implementation.
   ```

**Verification**:
- FIX comment removed
- def:term-algebra label works
- Matches Lean Term type structure

**Cross-references**:
- Update def:term-extension (line 136) to reference def:term-algebra

---

### Phase 2: Add Well-Formed Formulas Definition

**Estimated effort**: 20 minutes  
**Status**: [NOT STARTED]

**Objectives**:
1. Add WFF definition after line 30 (syntactic primitives list)
2. Remove FIX comment at line 32

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` (line 32)

**Steps**:
1. Replace the FIX comment (line 32) with:
   ```latex
   \begin{definition}[Well-Formed Formulas]\label{def:wff}
   The set of \emph{well-formed formulas} is defined inductively:
   \begin{align*}
     \metaA \Define{}& p \mid F(t_1, \ldots, t_n) \mid \top \mid \bot \\
     \mid{}& \neg\metaA \mid (\metaA \land \metaB) \mid (\metaA \lor \metaB) \\
     \mid{}& (\metaA \equiv \metaB) \mid (\lambda x.\metaA)(t)
   \end{align*}
   where $p$ ranges over sentence letters, $F$ over $n$-place predicates, $t, t_i$ over terms, and $x$ over variables.
   \end{definition}

   \noindent
   See \leansrc{Logos.SubTheories.Foundation.Syntax}{ConstitutiveFormula} for the Lean implementation.
   ```

**Verification**:
- FIX comment removed
- def:wff label works
- Uses `\Define` (not `\define`)
- Matches Lean ConstitutiveFormula type

---

### Phase 3: Add Reduction Operator

**Estimated effort**: 15 minutes  
**Status**: [NOT STARTED]

**Objectives**:
1. Add reduction operator definition after line 256 (def:essence-ground)
2. Remove FIX comment at line 249

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` (line 249)

**Steps**:
1. Remove the FIX comment at line 249
2. After the `\end{definition}` of def:essence-ground (line 256), add:
   ```latex
   \begin{definition}[Reduction]\label{def:reduction}
   \emph{Reduction} combines essence and ground:
   \[
     \metaA \Rightarrow \metaB \define (\metaA \essence \metaB) \land (\metaA \ground \metaB)
   \]
   This expresses that $\metaA$ is both a conjunctive part (essential to) and a disjunctive part (grounds) of $\metaB$.
   \end{definition}
   ```

**Verification**:
- FIX comment removed
- def:reduction label works
- Uses `\define` (not `\Define`) - this is a definitional equation

---

### Phase 4: Add Quantifier Clarification

**Estimated effort**: 15 minutes  
**Status**: [NOT STARTED]

**Objectives**:
1. Add remark clarifying quantifier notation after line 48 (biconditional def)
2. Remove FIX comment at line 34

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` (line 34)

**Steps**:
1. Remove the FIX comment at line 34
2. After def:biconditional (line 48), add:
   ```latex
   \begin{remark}[Quantifier Notation]
   First-order quantifiers are \textit{not} primitive in the Constitutive Foundation.
   Generalized quantification is expressed via lambda abstraction:
   \begin{itemize}
     \item Universal: $\forall x.\metaA$ abbreviates $\forall(\lambda x.\metaA)$ where $\forall$ is a second-order predicate on properties
     \item Existential: $\exists x.\metaA$ abbreviates $\exists(\lambda x.\metaA)$ where $\exists$ is a second-order predicate on properties
   \end{itemize}
   First-order quantification is introduced in the Dynamical Foundation layer.
   \end{remark}
   ```

**Verification**:
- FIX comment removed
- Clarifies intentional design decision
- No new Lean code needed (matches existing design)

---

### Phase 5: Build and Verify

**Estimated effort**: 15 minutes  
**Status**: [NOT STARTED]

**Objectives**:
1. Build PDF to verify all LaTeX compiles
2. Check cross-references resolve
3. Verify no overfull hboxes

**Commands**:
```bash
cd Theories/Logos/latex
pdflatex LogosReference.tex
pdflatex LogosReference.tex  # Second pass for refs
```

**Verification**:
- No LaTeX errors
- All new labels resolve
- PDF renders correctly

---

## Dependencies

- Phase 0 (macros) must complete before Phases 1-4
- Phases 1-4 can proceed in any order after Phase 0
- Phase 5 requires all previous phases

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| `\Coloneq` not available | High | Verify mathtools package loaded; fallback to `::=` literal |
| Macro conflicts | Medium | Use unique macro names; test in isolation first |
| Cross-reference cycles | Low | Add labels before referencing them |
| Overfull hboxes | Low | Adjust align environments; use `\allowbreak` |

## Success Criteria

- [ ] All 4 FIX comments removed from source file
- [ ] 4 new definitions added: def:term-algebra, def:wff, def:reduction, quantifier remark
- [ ] `\Define` macro added to logos-notation.sty
- [ ] PDF builds without errors
- [ ] Notation consistent: `\Define` for inductive, `\define` for equations

## Estimated Total Effort

- Phase 0: 15 minutes
- Phase 1: 20 minutes
- Phase 2: 20 minutes
- Phase 3: 15 minutes
- Phase 4: 15 minutes
- Phase 5: 15 minutes
- **Total**: ~1.5-2 hours
