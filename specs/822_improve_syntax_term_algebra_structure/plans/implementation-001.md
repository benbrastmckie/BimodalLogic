# Implementation Plan: Task #822

- **Task**: 822 - Improve Syntax and Term Algebra Structure
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/822_improve_syntax_term_algebra_structure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Restructure Section 1 of `02-ConstitutiveFoundation.tex` to eliminate forward references by moving Term Algebra definition before Well-Formed Formulas.
The current document defines WFFs (Definition 1, line 40) that reference "terms" before Term Algebra is defined (Definition 7, line 202).
This reorganization follows standard mathematical logic presentation order: terms, then formulas, then distinguish open/closed sentences.
New definitions for free variables of formulas and open/closed formulas will be added.

### Research Integration

The research report confirms:
- Standard textbook order: Terms -> Atomic Formulas -> WFFs -> Free Variables -> Open/Closed
- The Lean implementation (`Theories/Logos/SubTheories/Foundation/Syntax.lean`) already follows correct order
- Missing definitions: free variables for formulas, open formula, closed formula (sentence)
- Low risk: structural reorganization, no semantic changes

## Goals & Non-Goals

**Goals**:
- Eliminate forward reference where WFF definition uses "terms" before terms are defined
- Add new subsection for Term Algebra between Syntactic Primitives and WFFs
- Define free variables of formulas (extending term free variables)
- Define open formulas (formulas with free variables) and closed formulas/sentences (no free variables)
- Maintain document compilation and cross-reference integrity

**Non-Goals**:
- Changing the semantic content or mathematical definitions
- Modifying the Lean implementation
- Restructuring other sections beyond Section 1.1-1.7
- Adding new theorems or proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-reference breakage | Medium | Medium | Search for all `\Cref{def:term-algebra}` and `\cref` references after move |
| Definition numbering changes | Low | High | LaTeX handles automatic renumbering; verify PDF output |
| Broken `\leansrc` links | Low | Low | Verify Lean source links point to correct locations |
| Large diff hard to review | Medium | Medium | Split into clear phases with verification at each step |

## Implementation Phases

### Phase 1: Create New Term Algebra Subsection [COMPLETED]

**Goal**: Extract Term Algebra from Variable Assignment section and place it after Syntactic Primitives

**Tasks**:
- [ ] Add new subsection heading `\subsection{Term Algebra}\label{sec:term-algebra}` after line 37 (after the Remark on Variable Naming)
- [ ] Move Definition `def:term-algebra` (lines 202-222) to new subsection
- [ ] Move the Remark on Constant Substitution (lines 224-227) to new subsection
- [ ] Move the `\leansrc` reference (lines 229-230) to new subsection
- [ ] Remove the TODO comment at line 38

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - restructure

**Verification**:
- Document compiles without errors
- Term Algebra definition appears in Section 1.2
- No duplicate definitions

---

### Phase 2: Update Variable Assignment Section [COMPLETED]

**Goal**: Clean up Variable Assignment section after Term Algebra extraction

**Tasks**:
- [ ] Remove the TODO comment at line 200 (now addressed)
- [ ] Verify Variable Assignment (Definition, lines 196-198) remains intact
- [ ] Verify Variant Assignment (Definition, lines 232-242) remains intact
- [ ] Verify Term Extension (Definition, lines 244-250) remains intact
- [ ] Add brief reference to Term Algebra section in Variable Assignment intro if needed

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - cleanup

**Verification**:
- Variable Assignment section is coherent without Term Algebra
- All definitions in section are self-contained
- Document compiles without errors

---

### Phase 3: Add Free Variables of Formulas Definition [COMPLETED]

**Goal**: Define free variables for formulas, extending the term definition

**Tasks**:
- [ ] Add new definition after WFF definition (after line 53)
- [ ] Define `\FV(\metaA)` for each syntactic form:
  - Predicate application: union of term free variables
  - Lambda application: `(\FV(\metaA) \setminus \{v\}) \cup \FV(t)`
  - Universal quantifier: `\FV(\metaA)`
  - Top/bottom: empty set
  - Negation: `\FV(\metaA)`
  - Conjunction/disjunction: union of subformula free variables
  - Propositional identity: union of subformula free variables
- [ ] Add label `\label{def:fv-formula}`

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - add definition

**Verification**:
- Definition follows semantic linefeed style (one sentence per line)
- All syntactic forms from WFF definition are covered
- Document compiles without errors

---

### Phase 4: Add Open and Closed Formula Definitions [COMPLETED]

**Goal**: Define open formulas and closed formulas (sentences)

**Tasks**:
- [ ] Add new definition after Free Variables of Formulas definition
- [ ] Define open formula: `\FV(\metaA) \neq \emptyset`
- [ ] Define closed formula (sentence): `\FV(\metaA) = \emptyset`
- [ ] Add label `\label{def:open-closed}`
- [ ] Add brief remark explaining the significance:
  - Open formulas cannot be evaluated for truth without assignment
  - Closed formulas (sentences) express complete propositions

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - add definition and remark

**Verification**:
- Definitions are clear and follow standard terminology
- Document compiles without errors

---

### Phase 5: Update WFF Definition Context [COMPLETED]

**Goal**: Ensure WFF definition properly references the now-defined Term Algebra

**Tasks**:
- [ ] Review WFF definition (lines 40-53) for clarity now that terms are defined earlier
- [ ] Add reference to Term Algebra section if helpful: "where $t_i$ range over terms (\Cref{sec:term-algebra})"
- [ ] Verify the Lean source link still applies

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - minor update

**Verification**:
- WFF definition reads naturally with prior Term Algebra definition
- Cross-reference works correctly

---

### Phase 6: Verify Cross-References and Build [IN PROGRESS]

**Goal**: Ensure all cross-references work and document builds cleanly

**Tasks**:
- [ ] Search for all `\Cref{def:term-algebra}` and `\cref{def:term-algebra}` references
- [ ] Search for all `\Cref{sec:variable-assignment}` references
- [ ] Build document with `pdflatex`
- [ ] Check for undefined reference warnings
- [ ] Check for overfull hbox warnings
- [ ] Verify section numbering is correct in PDF output

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - fix any broken references

**Verification**:
- No LaTeX warnings about undefined references
- PDF output shows correct section numbering
- All cross-references resolve correctly

---

### Phase 7: Final Review and Cleanup [NOT STARTED]

**Goal**: Ensure document quality and consistency

**Tasks**:
- [ ] Review entire Section 1 for coherence and flow
- [ ] Verify semantic linefeed style throughout new/moved content
- [ ] Check that notation macros are used consistently
- [ ] Ensure all new labels follow convention (`def:`, `sec:`)
- [ ] Verify alignment with Lean implementation structure

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - final polish

**Verification**:
- Document reads naturally with new structure
- All style guidelines from `.claude/rules/latex.md` followed
- TODOs removed from file

---

## Testing & Validation

- [ ] Document compiles without errors using `pdflatex`
- [ ] No undefined reference warnings
- [ ] No overfull hbox warnings
- [ ] Section numbering correct in output
- [ ] Term Algebra precedes WFF definition
- [ ] Free variables of formulas defined after WFFs
- [ ] Open/closed formula distinction present
- [ ] Both TODO comments (lines 38, 200) removed
- [ ] LaTeX source follows semantic linefeed style

## Artifacts & Outputs

- Modified: `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
- Implementation summary: `specs/822_improve_syntax_term_algebra_structure/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails or introduces problems:
1. Revert changes using `git checkout -- Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`
2. Document the specific issue encountered
3. Consider alternative approaches:
   - Add forward declaration of terms before WFF if full move is problematic
   - Keep Term Algebra in Variable Assignment but add explicit forward reference in WFF definition
