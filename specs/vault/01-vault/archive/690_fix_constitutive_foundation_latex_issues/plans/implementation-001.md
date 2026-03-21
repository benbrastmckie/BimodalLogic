# Implementation Plan: Task 690 - Fix Constitutive Foundation LaTeX Issues

- **Task**: 690 - Fix LaTeX formatting issues in 02-ConstitutiveFoundation.tex
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/690_fix_constitutive_foundation_latex_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

This plan addresses three LaTeX formatting issues identified via FIX: and NOTE: tags in `02-ConstitutiveFoundation.tex`. The changes involve: (1) completing variable notation updates from x/y/z to v/v_1/v_2/v_3, (2) consolidating three separate definition environments for derived operators into one unified definition, and (3) adding a precise definition for identity sentences before the logical consequence section. All changes are structural LaTeX formatting without semantic modifications to the formal system.

### Research Integration

Integrated findings from `reports/research-001.md`:
- Priority ordering: variable notation first (most pervasive), then derived operators, then identity sentences
- Variable notation partially complete: line 22 updated to `v_1, v_2, v_3` but line 27 still uses `x`
- Derived operators consolidation follows Definition 1.1 pattern with enumerated items
- Identity sentence definition clarifies that outermost connective is propositional identity (not syntactically atomic)

## Goals & Non-Goals

**Goals**:
- Complete variable notation migration from x/y/z to v/v_1/v_2/... for object-language variables
- Consolidate Definitions 3.2 (Material Conditional), 3.3 (Biconditional), and Quantifier Notation Remark into single Definition
- Add explicit Definition for identity sentences before Section 3.8 (Logical Consequence)
- Maintain semantic linefeeds convention (one sentence per line)
- Ensure document compiles without errors

**Non-Goals**:
- Changing semantic content or logical definitions
- Modifying Lean source code
- Updating cross-references in other documents
- Changing Greek letters (phi, psi, chi) which are metavariables for formulas

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking cross-references | Medium | Low | Search for `\ref{def:material-conditional}` and `\ref{def:biconditional}` before consolidating |
| Incomplete variable replacement | High | Medium | Systematic grep search for x/y/z as bound variables |
| LaTeX compilation errors | Medium | Low | Test compilation after each phase |
| Inconsistent notation | Medium | Low | Review all changes in context before final commit |

## Implementation Phases

### Phase 1: Complete Variable Notation Update [COMPLETED]

**Goal**: Replace remaining x/y/z object-language variables with v/v_i notation throughout the document.

**Tasks**:
- [ ] Update line 27: Change lambda abstraction example from `\lambda x.\metaA` to `\lambda v.\metaA`
- [ ] Update line 33: Change variable reference in WFF definition from `x` to `v`
- [ ] Update line 37: Change lambda application from `(\lambda x.\metaA)(t)` to `(\lambda v.\metaA)(t)`
- [ ] Update line 155: Change term algebra from `x` to `v` in inductive definition
- [ ] Update line 157: Change variable reference from `x` to `v`
- [ ] Update lines 161, 166, 168: Update free variables and substitution definitions
- [ ] Update line 178: Change variant assignment from `x` to `v`
- [ ] Update line 184: Change term extension variable case
- [ ] Update lines 213-214: Change lambda verification clauses
- [ ] Add Remark documenting variable naming convention (after Syntactic Primitives)
- [ ] Verify no stray x/y/z as bound variables remain

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Multiple line edits

**Verification**:
- Grep for `\\lambda x` and `\over variables` to ensure no instances remain
- Compile document to verify no errors

---

### Phase 2: Consolidate Derived Operators [COMPLETED]

**Goal**: Combine three separate environments (Definitions 3.2, 3.3, and Quantifier Remark) into single unified Definition.

**Tasks**:
- [ ] Search for cross-references to `def:material-conditional` and `def:biconditional`
- [ ] Create new consolidated Definition environment at line 49
- [ ] Include Material Conditional as enumerated item (1)
- [ ] Include Biconditional as enumerated item (2)
- [ ] Include Quantifier Notation as enumerated items (3) and (4) for universal and existential
- [ ] Remove old Definition 3.2 (lines 49-53)
- [ ] Remove old Definition 3.3 (lines 55-59)
- [ ] Remove old Remark (lines 61-69)
- [ ] Update label to `def:derived-operators`
- [ ] Preserve link to Lean source after consolidated definition

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 47-72

**LaTeX for consolidated definition**:
```latex
\begin{definition}[Derived Operators and Notation Conventions]\label{def:derived-operators}
The following notation conventions define syntactic sugar for the Constitutive Foundation language:
\begin{enumerate}
  \item \textbf{Material Conditional}: $\metaA \to \metaB := \neg\metaA \lor \metaB$
  \item \textbf{Biconditional}: $\metaA \leftrightarrow \metaB := (\metaA \to \metaB) \land (\metaB \to \metaA)$
  \item \textbf{Universal Quantification}: $\forall v.\metaA$ abbreviates $\forall(\lambda v.\metaA)$ where $\forall$ is a second-order predicate on properties
  \item \textbf{Existential Quantification}: $\exists v.\metaA$ abbreviates $\exists(\lambda v.\metaA)$ where $\exists$ is a second-order predicate on properties
\end{enumerate}
First-order quantifiers are \textit{not} primitive in the Constitutive Foundation; first-order quantification is introduced in the Dynamical Foundation layer.
\end{definition}
```

**Verification**:
- Compile document and check definition numbering
- Verify no broken cross-references

---

### Phase 3: Add Identity Sentences Definition [COMPLETED]

**Goal**: Add explicit definition of identity sentences before Logical Consequence section and update the consequence definition to reference it.

**Tasks**:
- [ ] Add new Definition for Identity Sentences before line 406 (Section 3.8)
- [ ] Update Definition 3.X (Logical Consequence) to reference new identity sentence definition
- [ ] Update the restriction text to use defined terminology
- [ ] Ensure Remark on Identity and Contingency uses consistent terminology

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Lines 402-418

**LaTeX for new definition**:
```latex
\begin{definition}[Identity Sentences]\label{def:identity-sentences}
An \emph{identity sentence} is a well-formed formula of the form $\metaA \equiv \metaB$ where the outermost connective is propositional identity.
The \textit{Constitutive Foundation} evaluates only identity sentences at the null state, as non-identity sentences require the contingent evaluation context provided by the \textit{Dynamical Foundation}.
\end{definition}
```

**Updated logical consequence definition**:
```latex
\begin{definition}[Logical Consequence]\label{def:consequence-foundation}
Let $\context$ be a set of identity sentences (\Cref{def:identity-sentences}) and $\metaA$ an identity sentence.
Then:
\begin{align*}
  \context \trueat \metaA \iff
    & \text{for any model } \model \text{ and assignment } \assignment : \\
    & \text{if } \model, \assignment, \nullstate \trueat \metaB \text{ for all } \metaB \in \context, \text{ then } \model, \assignment, \nullstate \trueat \metaA
\end{align*}
\end{definition}
```

**Verification**:
- Compile document and verify cross-reference resolves
- Check definition numbering sequence

---

### Phase 4: Final Verification [COMPLETED]

**Goal**: Comprehensive verification of all changes.

**Tasks**:
- [ ] Full document compilation with `pdflatex LogosReference.tex`
- [ ] Verify no compilation errors or warnings
- [ ] Check all definition numbers are sequential
- [ ] Verify all `\Cref` references resolve
- [ ] Confirm semantic linefeeds maintained throughout
- [ ] Visual review of PDF output for formatting issues
- [ ] Remove any remaining FIX:/NOTE: tags that were addressed

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Remove resolved tags

**Verification**:
- Clean compilation with no errors/warnings
- PDF renders correctly
- All three issues from task description addressed

## Testing & Validation

- [ ] Document compiles without errors: `cd Theories/Logos/latex && pdflatex LogosReference.tex`
- [ ] No undefined references in compilation output
- [ ] Definition numbering is sequential
- [ ] Variable notation is consistent (no stray x/y/z as bound variables)
- [ ] Derived operators consolidated into single definition
- [ ] Identity sentences have explicit definition
- [ ] Semantic linefeeds preserved (one sentence per line)

## Artifacts & Outputs

- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - Updated LaTeX source
- `specs/690_fix_constitutive_foundation_latex_issues/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If changes cause compilation failures:
1. Use git to restore original file: `git checkout -- Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
2. Apply changes incrementally, testing compilation after each phase
3. If cross-reference issues arise, add explicit labels for backward compatibility
