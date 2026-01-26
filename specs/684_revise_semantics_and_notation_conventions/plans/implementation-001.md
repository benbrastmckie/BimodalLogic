# Implementation Plan: Task #684

- **Task**: 684 - Revise semantics and notation conventions
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/684_revise_semantics_and_notation_conventions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Revise `03-DynamicsFoundation.tex` to align dynamical semantics notation with the Lean implementation in `Truth.lean`. The primary changes involve: (1) adopting `\tau` uniformly for evolutions instead of the `\history` macro, (2) clarifying the 5-parameter evaluation scheme (M, tau, x, sigma, idx), and (3) separating syntactic sugar conventions from primitive semantic clauses for lambda abstraction and quantification. Research findings confirm notation inconsistency between LaTeX and Lean implementations.

### Research Integration

Key findings from research-001.md:
- LaTeX uses `\history` macro but Lean uses `tau` consistently
- Lambda/quantifier notation conflates syntactic sugar with semantic clauses
- Parameter naming diverges (LaTeX: x/y/z for times vs Lean: t/y)
- Quantifier binding needs clarification to match Lean's explicit binding

## Goals & Non-Goals

**Goals**:
- Adopt `tau` uniformly for evolutions in semantic clauses
- Revise 5-parameter evaluation header to be explicit about types
- Separate syntactic sugar (forall v.A := forall(lambda v.A)) from semantic clauses
- Document naming convention divergence between LaTeX and Lean
- Clarify quantifier binding to match Lean's explicit approach

**Non-Goals**:
- Changing the Lean implementation (this task focuses on LaTeX only)
- Redefining the underlying semantics (just notation/presentation)
- Modifying other LaTeX files beyond 03-DynamicsFoundation.tex
- Creating new LaTeX macros in logos-notation.sty

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking cross-references to definitions | Medium | Low | Use search to verify all references after changes |
| Reader confusion with new notation | Medium | Medium | Add transitional remark explaining the change |
| Macro replacement errors | High | Low | Keep `\history` macro available, use consistent find/replace |
| Inconsistency with other LaTeX files | Medium | Medium | Document this as normative for Dynamics layer |

## Implementation Phases

### Phase 1: Revise Truth Evaluation Header [COMPLETED]

**Goal**: Update the introductory text (lines 260-262) to explicitly list all 5 parameters with their types, matching the Lean `truthAt` function signature.

**Tasks**:
- [ ] Update introductory paragraph at line 262 to list 5 parameters explicitly
- [ ] Add parameter type descriptions (M: model, tau: world-history, x: time, sigma: assignment, idx: temporal index)
- [ ] Add notation summary: "M, tau, x, sigma, idx |= A"
- [ ] Maintain semantic linefeeds formatting

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - lines 260-262

**Verification**:
- New header clearly lists all 5 parameters
- Parameter types match Lean's `truthAt` signature
- Notation summary is present

---

### Phase 2: Update Semantic Clauses to Use tau [COMPLETED]

**Goal**: Replace `\history` with `tau` in all semantic clause definitions (atomic truth, lambda/quantification, actuality, extensional connectives, etc.).

**Tasks**:
- [ ] Replace `\history` with `\tau` in Definition~\ref{def:atomic-truth} (lines 267-271)
- [ ] Replace in Theorem~\ref{thm:bivalence} (lines 273-278)
- [ ] Replace in Remark after bivalence (line 281)
- [ ] Replace in Definition~\ref{def:lambda-quant-truth} (lines 290-295)
- [ ] Replace in Definition~\ref{def:actuality-truth} (lines 299-303)
- [ ] Replace in Remark on restricted quantification (lines 305-318)
- [ ] Replace in Definition~\ref{def:extensional-truth} (lines 324-331)
- [ ] Continue through remaining semantic definitions in file

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - multiple definitions

**Verification**:
- No remaining `\history` in semantic clause definitions
- All instances of `\tau` render correctly
- Cross-references still resolve

---

### Phase 3: Separate Syntactic Sugar from Semantic Clauses [COMPLETED]

**Goal**: Restructure lambda/quantifier presentation to clearly distinguish syntactic abbreviations from primitive semantic clauses, matching Lean's treatment.

**Tasks**:
- [ ] Add new Definition for Syntactic Conventions before line 290
  - Define `forall v.A := forall(lambda v.A)`
  - Define `exists v.A := exists(lambda v.A)` with `exists := neg forall neg`
  - Reference metalinguistic conventions from earlier in document
- [ ] Revise Definition~\ref{def:lambda-quant-truth} to focus on primitives only
  - Lambda application clause: `(lambda v.A)(t)` evaluates with substitution
  - Universal quantifier clause: `forall(P)` quantifies over all states
- [ ] Add explanatory remark showing reduction sequence:
  - `M, tau, x, sigma, idx |= forall v.A` expands via syntactic sugar
  - Then reduces via lambda and forall semantics

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - lines 284-296

**Verification**:
- Clear separation between syntactic sugar and semantic primitives
- Reduction sequence is documented
- Matches Lean's `Formula.all` and `Formula.lambdaApp` pattern

---

### Phase 4: Add Variable Naming Convention Remark [COMPLETED]

**Goal**: Document the intentional naming convention divergence between LaTeX presentation and Lean implementation.

**Tasks**:
- [ ] Convert NOTE comment (line 286) into a formal Remark environment
- [ ] Document LaTeX conventions:
  - Times: x, y, z in D
  - Variables: v, v_1, v_2, ... for object language
  - States: s, t, r in S
- [ ] Document Lean conventions:
  - Times: t, y as identifiers
  - Variables: x (String type)
  - States: s, t, r as identifiers
- [ ] Explain rationale for divergence

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - near line 286

**Verification**:
- Remark clearly explains naming conventions
- Divergence is documented with rationale
- No ambiguity about which conventions apply where

---

### Phase 5: Clean Up TODO Comments and Final Review [COMPLETED]

**Goal**: Remove resolved TODO/NOTE comments and perform final consistency check.

**Tasks**:
- [ ] Remove TODO at line 260 (resolved by Phase 1)
- [ ] Remove NOTE at line 286 (converted to Remark in Phase 4)
- [ ] Remove TODO at line 288 (resolved by Phase 3)
- [ ] Verify all `\tau` instances render correctly
- [ ] Verify cross-references resolve
- [ ] Check semantic linefeeds formatting throughout
- [ ] Verify document compiles without warnings

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex` - TODO/NOTE cleanup

**Verification**:
- No remaining TODO/NOTE comments related to this task
- Document compiles successfully
- No undefined references or overfull hboxes

## Testing & Validation

- [ ] `pdflatex 03-DynamicsFoundation.tex` compiles without errors
- [ ] No undefined reference warnings
- [ ] No overfull hbox warnings in changed sections
- [ ] All `\tau` instances display correctly in PDF
- [ ] Semantic clause definitions are consistent across document
- [ ] Syntactic sugar/semantic primitive separation is clear

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-{DATE}.md` (on completion)
- Modified: `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`

## Rollback/Contingency

If changes cause significant issues:
1. Use `git diff` to review specific changes
2. Revert individual hunks with `git checkout -p`
3. Keep `\history` macro defined in notation file for backward compatibility
4. Document any partial changes that are retained vs reverted
