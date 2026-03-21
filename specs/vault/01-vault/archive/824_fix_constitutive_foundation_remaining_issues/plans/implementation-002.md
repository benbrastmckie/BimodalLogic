# Implementation Plan: Task #824 (Revised)

- **Task**: 824 - fix_constitutive_foundation_remaining_issues
- **Version**: 002
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: Task 823 (verum/falsum notation conventions)
- **Research Inputs**: specs/824_fix_constitutive_foundation_remaining_issues/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Revision Notes

**Changes from v001**:
1. **Added**: Phase 2 - Convert subsection 2.7 (Verification and Falsification) to extended remark format (line 295 FIX tag now in scope)
2. **Added**: Phase 4 now includes defining all four extremal bilateral propositions when propositional operators are defined (around line 517-528)
3. **Reordered**: Phases adjusted to place structural changes (subsection conversion) before content additions

## Overview

This task addresses 7 FIX/NOTE tags in `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`. The changes involve:
1. Making state modality definitions use consistent dependent type theory notation (line 181)
2. Converting subsection 2.7 (Verification and Falsification) to extended remark format (line 295)
3. Adding exclusivity and exhaustivity constraints generalized to n-place predicates (lines 245-246)
4. Removing an outdated NOTE comment about verum/falsum notation (line 357)
5. Defining all four extremal bilateral propositions alongside propositional operators (lines 517-528)
6. Adding verum/falsum definitions after Essence and Ground section (line 481)
7. Adding homomorphism identities for all extremal elements (line 534)

### Research Integration

The research report identified:
- Source material for exclusivity/exhaustivity at `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` line 861
- Type annotation patterns from `Theories/Bimodal/latex/subfiles/02-Semantics.tex` (colon notation for dependent types)
- Task 823 conventions for `\ver` and `\fal` macros documented in `logos-notation.sty` and `notation-conventions.md`

## Goals & Non-Goals

**Goals**:
- Fix all 7 FIX/NOTE tags now in scope (lines 181, 245, 246, 295, 357, 481, 534)
- Apply consistent dependent type theory notation to state modality definitions
- Convert subsection 2.7 to extended remark format matching other subsections
- Add exclusivity/exhaustivity constraints generalized to n-place predicates
- Define all four extremal bilateral propositions: `\top`, `\bot`, `\ver`, `\fal` as propositions
- Define verum (`\ver`) and falsum (`\fal`) as negations of primitive bot/top (sentential level)
- Add homomorphism identities showing all extremal elements map to bilateral propositions
- Remove all fixed tags after implementation

**Non-Goals**:
- Modifying `logos-notation.sty` (task 823 already defined macros)
- Changing document structure beyond specified fixes

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type notation inconsistent with other Logos docs | Medium | Low | Follow established pattern from Bimodal/latex |
| Exclusivity/exhaustivity generalization incorrect | High | Medium | Cross-reference counterfactual_worlds.tex source |
| Subsection-to-remark conversion loses content | High | Low | Preserve all content, only change environment |
| Verum/falsum definitions conflict with existing | Medium | Low | Task 823 defines macros; this adds semantic definitions |
| LaTeX compilation errors | Medium | Low | Verify compilation with pdflatex after each phase |

## Implementation Phases

### Phase 1: State Modality Dependent Type Notation [COMPLETED]

**Goal**: Rewrite Definition 2.6 (State Modality) to use consistent dependent type theory notation with explicit type signatures.

**Tasks**:
- [ ] Read current state modality definition (lines 183-194)
- [ ] Rewrite using colon notation for type annotations: `\possible : \statespace \to \Prop`
- [ ] Add explicit type signatures for all predicates: `\possible`, `\compatible`, `Maximal`, `\worldstates`, `\connected`, `\necessary`
- [ ] Remove FIX comment at line 181
- [ ] Verify LaTeX syntax is correct

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - lines 181-194

**Verification**:
- Definition uses consistent `predicate : Type \to Prop` notation
- All predicates have explicit type signatures
- FIX comment removed
- Document compiles without errors

---

### Phase 2: Convert Subsection 2.7 to Extended Remark [COMPLETED]

**Goal**: Convert subsection 2.7 (Verification and Falsification) to an extended remark format, matching the style of other subsections that use remarks for explanatory content.

**Tasks**:
- [ ] Read current subsection 2.7 structure (lines 301-314)
- [ ] Remove `\subsection{Verification and Falsification}` heading
- [ ] Convert the explanatory content into a `\begin{remark}[Hyperintensional Semantics]...\end{remark}` environment
- [ ] Preserve the itemized list of key consequences
- [ ] Ensure subsubsections (Atomic Formulas, Lambda Abstraction, etc.) follow the remark naturally
- [ ] Remove FIX comment at line 295
- [ ] Verify document structure remains coherent

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - lines 295-316

**Verification**:
- Subsection converted to extended remark
- All content preserved
- FIX comment at line 295 removed
- Document structure flows naturally
- LaTeX compiles without errors

---

### Phase 3: Exclusivity and Exhaustivity Constraints [COMPLETED]

**Goal**: Add exclusivity and exhaustivity constraints for n-place predicates, generalizing from the source material on state sets.

**Tasks**:
- [ ] Add exclusivity constraint item after line 244: for any verifier f and falsifier g, their outputs at same arguments are incompatible
- [ ] Add exhaustivity constraint item: for any arguments and possible state, some verifier or falsifier output is compatible with it
- [ ] Use LaTeX itemize format matching existing constraints
- [ ] Remove both FIX comments at lines 245-246
- [ ] Verify constraint formulations are mathematically correct

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - lines 244-247

**Verification**:
- Two new constraint items added in proper format
- Constraints correctly generalize exclusivity/exhaustivity to n-place functions
- Both FIX comments removed
- Itemize environment still valid

---

### Phase 4: Remove Verum/Falsum NOTE Comment [COMPLETED]

**Goal**: Remove the NOTE comment at lines 357-359 since the verum/falsum notation is now documented in task 823 artifacts.

**Tasks**:
- [ ] Remove the 3-line NOTE comment block (lines 357-359)
- [ ] Verify no orphaned blank lines remain

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - lines 357-359

**Verification**:
- NOTE comment removed
- Document flow unchanged
- No compilation errors

---

### Phase 5: Define Extremal Bilateral Propositions [COMPLETED]

**Goal**: Add definitions of all four extremal bilateral propositions alongside propositional operators in Definition 2.X (Propositional Operations).

**Tasks**:
- [ ] Locate Definition (Propositional Operations) around lines 517-528
- [ ] After the existing operations, add a new item defining the four extremal propositions:
  - `\top_\props = \tuple{\statespace, \{\fullstate\}}` (top for ground ordering)
  - `\bot_\props = \tuple{\{\nullstate\}, \statespace}` (bottom for ground ordering)
  - `\ver_\props = \tuple{\statespace, \{\nullstate\}}` (top for parthood ordering = verum)
  - `\fal_\props = \tuple{\{\fullstate\}, \statespace}` (bottom for parthood ordering = falsum)
- [ ] Add brief explanation distinguishing the two orderings
- [ ] Ensure notation is consistent with existing content

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - around lines 517-528

**Verification**:
- All four extremal propositions defined
- Definitions correctly specify bilateral propositions
- Clear distinction between ground and parthood orderings
- LaTeX compiles without errors

---

### Phase 6: Add Verum and Falsum Sentential Definitions [COMPLETED]

**Goal**: Add Definition 2.X (Verum and Falsum) after Definition 2.X (Essence and Ground) at line 481.

**Tasks**:
- [ ] Create new definition environment for verum and falsum sentential operators
- [ ] Define `\ver := \neg\bot` (top for parthood ordering)
- [ ] Define `\fal := \neg\top` (bottom for parthood ordering)
- [ ] Add brief explanation distinguishing from `\top` and `\bot` (ground ordering extremal elements)
- [ ] Add label `def:verum-falsum` for cross-reference
- [ ] Remove FIX comment at line 481

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - after line 480

**Verification**:
- New definition uses `\ver` and `\fal` macros from logos-notation.sty
- Mathematical content is correct
- FIX comment removed
- Integrates smoothly with surrounding text

---

### Phase 7: Add Extremal Homomorphism Identities [COMPLETED]

**Goal**: Add homomorphism identities showing how all four extremal elements map to their corresponding bilateral propositions in Remark 2.X.

**Tasks**:
- [ ] Locate Remark (Propositional vs. Sentential Operators) around line 530
- [ ] Add itemize entries after the existing homomorphism items:
  - `\sem{\top} = \top_\props = \tuple{\statespace, \{\fullstate\}}`
  - `\sem{\bot} = \bot_\props = \tuple{\{\nullstate\}, \statespace}`
  - `\sem{\ver} = \ver_\props = \tuple{\statespace, \{\nullstate\}}`
  - `\sem{\fal} = \fal_\props = \tuple{\{\fullstate\}, \statespace}`
- [ ] Remove FIX comment at line 534
- [ ] Ensure consistent notation with existing remark content and Phase 5 definitions

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - around line 534

**Verification**:
- Homomorphism identities correctly specify bilateral propositions for all four extremal elements
- Notation matches Phase 5 definitions and existing items in the remark
- FIX comment removed
- LaTeX compiles without errors

---

### Phase 8: Final Verification and Cleanup [COMPLETED]

**Goal**: Verify all FIX/NOTE tags are removed and document compiles correctly.

**Tasks**:
- [ ] Search for any remaining FIX or NOTE comments in scope
- [ ] Compile document with pdflatex to verify no errors
- [ ] Check for any overfull/underfull box warnings
- [ ] Verify cross-references resolve correctly
- [ ] Verify consistency between extremal proposition definitions (Phase 5) and homomorphism identities (Phase 7)

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `grep -n "FIX:" 02-ConstitutiveFoundation.tex` returns empty (all in-scope tags fixed)
- `grep -n "NOTE:" 02-ConstitutiveFoundation.tex` returns empty
- Document compiles successfully
- No critical LaTeX warnings
- All four extremal bilateral propositions consistently defined and referenced

## Testing & Validation

- [ ] All 7 in-scope FIX/NOTE tags removed (lines 181, 245, 246, 295, 357, 481, 534)
- [ ] Document compiles with `pdflatex 02-ConstitutiveFoundation.tex`
- [ ] State modality definitions use consistent type notation
- [ ] Subsection 2.7 converted to extended remark format
- [ ] Exclusivity/exhaustivity constraints are mathematically correct
- [ ] All four extremal bilateral propositions defined alongside propositional operators
- [ ] Verum/falsum definitions correctly reference `logos-notation.sty` macros
- [ ] Homomorphism identities for all four extremal elements are present and consistent

## Artifacts & Outputs

- `specs/824_fix_constitutive_foundation_remaining_issues/plans/implementation-001.md` (previous version)
- `specs/824_fix_constitutive_foundation_remaining_issues/plans/implementation-002.md` (this file)
- `specs/824_fix_constitutive_foundation_remaining_issues/summaries/implementation-summary-{DATE}.md` (upon completion)

## Rollback/Contingency

If implementation introduces LaTeX errors or incorrect mathematical content:
1. Use `git checkout` to restore `02-ConstitutiveFoundation.tex`
2. Re-read research report for correct formulations
3. Apply fixes incrementally with compilation checks between phases
