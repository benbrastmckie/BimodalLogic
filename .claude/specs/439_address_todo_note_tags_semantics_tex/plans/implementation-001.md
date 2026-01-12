# Implementation Plan: Task #439

**Task**: Address TODO and NOTE tags in 02-Semantics.tex
**Version**: 001
**Created**: 2026-01-12
**Language**: latex

## Overview

This plan addresses 23 TODO/NOTE tags in 02-Semantics.tex to ensure consistency with the source paper (possible_worlds.tex) and improve the document's role as a bridge between the Lean implementation and the academic paper.

The implementation is structured in 5 phases, progressing from foundational notation changes to content enrichment.

## Phases

### Phase 1: Notation Infrastructure

**Status**: [NOT STARTED]

**Objectives**:
1. Add new notation macros to bimodal-notation.sty
2. Establish consistent notation patterns before document restructuring

**Files to modify**:
- `Theories/Bimodal/latex/assets/bimodal-notation.sty`

**Steps**:

1. Add task relation notation:
   ```latex
   % Task relation: w \taskto{x} u means w transitions to u with duration x
   \newcommand{\taskto}[1]{\Rightarrow_{#1}}
   ```

2. Add metalanguage biconditional:
   ```latex
   % Metalanguage biconditional (distinct from object language \iff)
   \newcommand{\Iff}{~\textit{iff}~}
   ```

3. Add snake_case Lean identifier commands:
   ```latex
   % Lean identifier commands
   \newcommand{\leanTaskRel}{\texttt{task\_rel}}
   \newcommand{\leanTimeShift}{\texttt{time\_shift}}
   \newcommand{\leanRespTask}{\texttt{respects\_task}}
   \newcommand{\leanConvex}{\texttt{convex}}
   \newcommand{\leanDomain}{\texttt{domain}}
   \newcommand{\leanStates}{\texttt{states}}
   ```

4. Verify notation-standards.sty has `\model` defined (currently uses `\mathbf{M}`)

**Verification**:
- Build BimodalReference.tex with `pdflatex` to verify no errors
- Check new macros render correctly

---

### Phase 2: Critical Semantic Corrections

**Status**: [NOT STARTED]

**Objectives**:
1. Fix incorrect semantic clauses (box and tense operators)
2. Ensure alignment with both paper AND Lean implementation

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/02-Semantics.tex`

**Steps**:

1. **Fix Box (Necessity) Clause** (lines 145-147):
   - Remove the incorrect "states'(t) = states(t)" condition
   - Replace with: quantification over ALL world histories at time t
   ```latex
   \model, \tau, t \vDash \nec\varphi \Iff
     \model, \sigma, t \vDash \varphi \text{ for all } \sigma \in H_{\taskframe}
   ```

2. **Align Tense Operators with Lean** (lines 148-151):
   - The Lean code restricts to domain; keep this intentional design
   - Add note explaining domain restriction differs from paper
   - Current formulation is correct for Lean alignment:
   ```latex
   \model, \tau, t \vDash \allpast\varphi \Iff
     \model, \tau, s \vDash \varphi \text{ for all } s \in \domain(\tau) \text{ where } s < t
   ```
   Add explanatory note:
   ```latex
   % NOTE: This restricts quantification to the history's domain,
   % matching the Lean implementation. The paper quantifies over all D.
   ```

3. **Add glosses** after Truth at a Point definition (line 155):
   - Box: quantifies over all world histories at current time
   - Past: quantifies over earlier times within history's domain
   - Future: quantifies over later times within history's domain

**Verification**:
- Compare semantic clauses against Truth.lean:95-102
- Build LaTeX to verify formatting

---

### Phase 3: Definition Restructuring

**Status**: [NOT STARTED]

**Objectives**:
1. Reorder definitions for logical flow
2. Ensure dependencies are defined before use

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/02-Semantics.tex`

**Steps**:

1. **Move Convex Domain definition** (current lines 79-84):
   - Position immediately after Task Frame definition
   - Before World History

2. **Create Respects Task definition** (new):
   - Add after Convex Domain, before World History
   - Currently at lines 88-93, needs to precede World History

3. **Revise World History definition** (current lines 68-75):
   - Reference Convex Domain and Respects Task by name
   - Update to use `\tau` instead of `\history`

4. **Update Table at lines 44-54**:
   - Add type for compositionality (remove "see below")
   - Remove Description column
   - Verify all items already introduced

5. **Update Table at lines 97-108**:
   - Remove Description column
   - Replace "(see code)" with actual types
   - Verify all items already introduced

**New Definition Order**:
1. Task Frame (existing)
2. Convex Domain (moved up)
3. Respects Task (moved up)
4. World History (revised)
5. Task Model
6. Truth Conditions
7. Time-Shift
8. Validity

**Verification**:
- Read through document linearly; no forward references
- All table items previously introduced

---

### Phase 4: Content Enrichment

**Status**: [NOT STARTED]

**Objectives**:
1. Add intuitive explanations from paper
2. Improve accessibility for readers

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/02-Semantics.tex`

**Steps**:

1. **Add Task Relation Reading** (after line 27):
   Add paragraph explaining:
   - `w \taskto{x} u` reads "world state w can transition to u with duration x"
   - Abstracts from universal laws governing transitions
   - Reference paper line 860-861 for chess example

2. **Explain Sentence Letters** (before Task Model, line 112):
   Add paragraph:
   - Strings are treated as sentence letters
   - Sentence letters express propositions
   - Propositions are "instantaneous ways for the system"
   - Contrast with world states (unique configurations)

3. **Improve Time-Shift Definition** (lines 169-179):
   Rewrite to match paper's formal version:
   ```latex
   \begin{definition}[Time-Shift]
   World histories $\tau, \sigma \in H_{\taskframe}$ are \textbf{time-shifted from $y$ to $x$}
   (written $\tau \approx_y^x \sigma$) if there exists an order automorphism
   $\bar{a} : T \to T$ where:
   \begin{itemize}
     \item $y = \bar{a}(x)$
     \item $\domain(\sigma) = \bar{a}^{-1}(\domain(\tau))$
     \item $\sigma(z) = \tau(\bar{a}(z))$ for all $z \in \domain(\sigma)$
   \end{itemize}
   \end{definition}
   ```

4. **Add MF/TF Axiom Context** (after Time-Shift, line 194):
   Explain why time-shift is essential for proving MF and TF axioms
   Reference lem:history-time-shift-preservation from paper

5. **Improve Validity explanation** (lines 200-210):
   - Add type-theoretic specification matching Lean
   - Follow with intuitive explanation

**Verification**:
- Document remains concise (not verbose)
- Each addition helps reader understanding

---

### Phase 5: Cleanup and Consistency

**Status**: [NOT STARTED]

**Objectives**:
1. Replace variable names for consistency
2. Remove placeholders and unnecessary content
3. Finalize formatting

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/02-Semantics.tex`

**Steps**:

1. **Replace history variable names**:
   - `\history` → `\tau` (primary history)
   - `\history'` → `\sigma` (quantified history)
   - Update `\truthat` macro calls accordingly

2. **Replace valuation terminology**:
   - "valuation" → "interpretation function"
   - `V` → `I` where appropriate (or keep V with new name)

3. **Update task relation notation**:
   - `R(w, x, u)` → `w \taskto{x} u` throughout

4. **Shorten theorem names** (lines 183-194):
   - "Time-Shift Preserves Convexity" → "Convexity Preservation"
   - "Time-Shift Preserves Task Respect" → "Task Respect Preservation"

5. **Check for "Valid iff Empty Consequence" theorem**:
   - Verify in Bimodal/Semantics/Validity.lean
   - If not present, remove from LaTeX (lines 226-228)

6. **Remove all TODO/NOTE comments**:
   - Systematically delete addressed TODO comments
   - Convert any remaining NOTEs to proper \textit{Note:} paragraphs

7. **Final build and review**:
   - Build BimodalReference.pdf
   - Visual inspection for formatting issues
   - Verify no overfull hboxes

**Verification**:
- `grep -c "TODO" 02-Semantics.tex` returns 0
- `grep -c "NOTE" 02-Semantics.tex` returns 0 (or only proper notes)
- PDF builds without warnings

---

## Dependencies

- Phase 1 must complete before Phase 5 (notation macros needed)
- Phase 2 and Phase 3 can proceed in parallel
- Phase 4 depends on Phase 3 (definition order affects content placement)
- Phase 5 must be last (cleanup after all changes)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Tense semantics differ from paper | Medium | Document intentional difference, add note |
| Notation conflicts with existing macros | Low | Test build after each notation addition |
| Breaking cross-references | Low | Use cleveref, verify after restructure |
| Overly verbose after enrichment | Medium | Keep additions minimal, essential only |

## Success Criteria

- [ ] All 23 TODO/NOTE tags addressed or removed
- [ ] Semantic clauses match Lean implementation
- [ ] Notation consistent with possible_worlds.tex style
- [ ] Definitions in logical order (no forward references)
- [ ] BimodalReference.pdf builds without errors
- [ ] Document serves as effective bridge between Lean and paper
