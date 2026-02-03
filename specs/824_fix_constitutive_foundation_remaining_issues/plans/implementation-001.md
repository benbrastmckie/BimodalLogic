# Implementation Plan: Task #824

- **Task**: 824 - fix_constitutive_foundation_remaining_issues
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: Task 823 (verum/falsum notation conventions)
- **Research Inputs**: specs/824_fix_constitutive_foundation_remaining_issues/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

This task addresses 6 FIX/NOTE tags in `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex`. The changes involve: (1) making state modality definitions use consistent dependent type theory notation (line 181); (2) adding exclusivity and exhaustivity constraints generalized to n-place predicates (lines 245-246); (3) removing an outdated NOTE comment about verum/falsum notation (line 357); (4) adding verum/falsum definitions after the Essence and Ground section (line 481); and (5) adding homomorphism identities for top/bot elements (line 534). The task excludes line 295 (subsection restructuring) per the task description scope.

### Research Integration

The research report identified:
- Source material for exclusivity/exhaustivity at `/home/benjamin/Philosophy/Papers/Counterfactuals/JPL/counterfactual_worlds.tex` line 861
- Type annotation patterns from `Theories/Bimodal/latex/subfiles/02-Semantics.tex` (colon notation for dependent types)
- Task 823 conventions for `\ver` and `\fal` macros documented in `logos-notation.sty` and `notation-conventions.md`

## Goals & Non-Goals

**Goals**:
- Fix all 6 FIX/NOTE tags within scope (lines 181, 245, 246, 357, 481, 534)
- Apply consistent dependent type theory notation to state modality definitions
- Add exclusivity/exhaustivity constraints generalized to n-place predicates
- Define verum (`\ver`) and falsum (`\fal`) as negations of primitive bot/top
- Add homomorphism identities showing `\top` and `\bot` map to bilateral propositions
- Remove all fixed tags after implementation

**Non-Goals**:
- Converting subsection 2.7 to remark format (line 295 - explicitly out of scope)
- Modifying `logos-notation.sty` (task 823 already defined macros)
- Changing document structure beyond specified fixes

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type notation inconsistent with other Logos docs | Medium | Low | Follow established pattern from Bimodal/latex |
| Exclusivity/exhaustivity generalization incorrect | High | Medium | Cross-reference counterfactual_worlds.tex source |
| Verum/falsum definitions conflict with existing | Medium | Low | Task 823 defines macros; this adds semantic definitions |
| LaTeX compilation errors | Medium | Low | Verify compilation with pdflatex after each phase |

## Implementation Phases

### Phase 1: State Modality Dependent Type Notation [NOT STARTED]

**Goal**: Rewrite Definition 2.6 (State Modality) to use consistent dependent type theory notation with explicit type signatures.

**Tasks**:
- [ ] Read current state modality definition (lines 183-194)
- [ ] Rewrite using colon notation for type annotations: `\possible : \statespace \to \Prop`
- [ ] Add explicit type signatures for all predicates: `\possible`, `\compatible`, `Maximal`, `\worldstates`, `\connected`, `\necessary`
- [ ] Remove FIX comment at line 181
- [ ] Verify LaTeX syntax is correct

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - lines 181-194

**Verification**:
- Definition uses consistent `predicate : Type \to Prop` notation
- All predicates have explicit type signatures
- FIX comment removed
- Document compiles without errors

---

### Phase 2: Exclusivity and Exhaustivity Constraints [NOT STARTED]

**Goal**: Add exclusivity and exhaustivity constraints for n-place predicates, generalizing from the source material on state sets.

**Tasks**:
- [ ] Add exclusivity constraint item after line 244: for any verifier f and falsifier g, their outputs at same arguments are incompatible
- [ ] Add exhaustivity constraint item: for any arguments and possible state, some verifier or falsifier output is compatible with it
- [ ] Use LaTeX itemize format matching existing constraints
- [ ] Remove both FIX comments at lines 245-246
- [ ] Verify constraint formulations are mathematically correct

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - lines 244-247

**Verification**:
- Two new constraint items added in proper format
- Constraints correctly generalize exclusivity/exhaustivity to n-place functions
- Both FIX comments removed
- Itemize environment still valid

---

### Phase 3: Remove Verum/Falsum NOTE Comment [NOT STARTED]

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

### Phase 4: Add Verum and Falsum Definitions [NOT STARTED]

**Goal**: Add Definition 2.19 (Verum and Falsum) after Definition 2.18 (Essence and Ground) at line 481.

**Tasks**:
- [ ] Create new definition environment for verum and falsum
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

### Phase 5: Add Top/Bot Homomorphism Identities [NOT STARTED]

**Goal**: Add homomorphism identities showing how `\top` and `\bot` map to bilateral propositions in Remark 2.24.

**Tasks**:
- [ ] Locate Remark 2.24 (Propositional vs. Sentential Operators) around line 530
- [ ] Add itemize entries after the existing homomorphism items:
  - `\sem{\top} = \tuple{\statespace, \{\fullstate\}}`
  - `\sem{\bot} = \tuple{\{\nullstate\}, \statespace}`
- [ ] Remove FIX comment at line 534
- [ ] Ensure consistent notation with existing remark content

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` - around line 534

**Verification**:
- Homomorphism identities correctly specify bilateral propositions for `\top` and `\bot`
- Notation matches existing items in the remark
- FIX comment removed
- LaTeX compiles without errors

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify all FIX/NOTE tags are removed and document compiles correctly.

**Tasks**:
- [ ] Search for any remaining FIX or NOTE comments in scope
- [ ] Compile document with pdflatex to verify no errors
- [ ] Check for any overfull/underfull box warnings
- [ ] Verify cross-references resolve correctly

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `grep -n "FIX:" 02-ConstitutiveFoundation.tex` shows only line 295 (out of scope)
- `grep -n "NOTE:" 02-ConstitutiveFoundation.tex` returns empty
- Document compiles successfully
- No critical LaTeX warnings

## Testing & Validation

- [ ] All 6 in-scope FIX/NOTE tags removed (lines 181, 245, 246, 357, 481, 534)
- [ ] Document compiles with `pdflatex 02-ConstitutiveFoundation.tex`
- [ ] State modality definitions use consistent type notation
- [ ] Exclusivity/exhaustivity constraints are mathematically correct
- [ ] Verum/falsum definitions correctly reference `logos-notation.sty` macros
- [ ] Homomorphism identities for top/bot are present

## Artifacts & Outputs

- `specs/824_fix_constitutive_foundation_remaining_issues/plans/implementation-001.md` (this file)
- `specs/824_fix_constitutive_foundation_remaining_issues/summaries/implementation-summary-{DATE}.md` (upon completion)

## Rollback/Contingency

If implementation introduces LaTeX errors or incorrect mathematical content:
1. Use `git checkout` to restore `02-ConstitutiveFoundation.tex`
2. Re-read research report for correct formulations
3. Apply fixes incrementally with compilation checks between phases
