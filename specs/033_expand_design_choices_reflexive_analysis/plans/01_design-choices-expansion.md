# Implementation Plan: Task #33

- **Task**: 33 - Expand design-choices section with comprehensive reflexive vs irreflexive semantics analysis
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (research completed)
- **Research Inputs**: specs/033_expand_design_choices_reflexive_analysis/reports/01_team-research.md
- **Artifacts**: plans/01_design-choices-expansion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal
- **Lean Intent**: false

## Overview

This plan expands the Design Choices section (sec:design-choices) in `Theories/Bimodal/typst/chapters/06-notes.typ` from ~75 lines to ~200 lines. The expansion transforms a basic comparison table and three remarks into a comprehensive six-section analysis of reflexive vs irreflexive temporal semantics, integrating findings from the 4-teammate research report covering algebraic classification, expressive power, representation theorems, and historical context.

### Research Integration

The team research report (01_team-research.md) provides all source material:
- **Teammate A**: Expressive power, frame class collapse table, S4.3.1 alignment
- **Teammate B**: Representation theorem challenges, canonical model construction, IRR rule limitations
- **Teammate C**: Algebraic perspective (interior operators, McKinsey-Tarski, Jonsson-Tarski)
- **Teammate D**: Historical context, 4 semantic switches, vault discoveries (Task 658, 958, 957)

## Goals & Non-Goals

**Goals**:
- Expand sec:design-choices from ~75 lines to ~200 lines with six coherent subsections
- Convert the existing content to align with reflexive semantics (current implementation)
- Add algebraic perspective (interior operators) as a unifying theoretical framework
- Document the expressive power / proof-elegance trade-off with technical detail
- Include historical context from Prior to CTL/LTL to TM's own switches
- Preserve Typst formatting conventions and cross-references

**Non-Goals**:
- Modifying Lean code (this is documentation only)
- Adding new cross-references beyond existing sec:truth
- Changing document structure outside sec:design-choices
- Including full proofs (this is a reference manual, not a textbook)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Typst compilation error | Medium | Low | Verify compile after each phase |
| Mathematical notation inconsistency | Medium | Medium | Cross-check with existing chapters |
| Content too dense for reference manual | Low | Medium | Keep each subsection focused, 20-40 lines |
| Cross-reference breaks | Low | Low | Only reference existing labels (sec:truth) |

## Implementation Phases

### Phase 1: Update Semantic Definitions [NOT STARTED]

**Goal**: Convert existing definitions from "strict (current)" to "reflexive (current)" and update the comparison table.

**Tasks**:
- [ ] Update Definition block for Strict Semantics (remove "(Current)" marker)
- [ ] Update Definition block for Reflexive Semantics (add "(Current)" marker, now the implemented approach)
- [ ] Update the truth conditions comment to note reflexive semantics is used
- [ ] Update the comparison table to show reflexive as the current choice
- [ ] Add note about T-axiom (Gφ → φ) being definitionally valid

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - lines 104-145

**Verification**:
- `typst compile main.typ` succeeds
- Definitions correctly identify reflexive as current implementation
- Table reflects current state

---

### Phase 2: Add Algebraic Classification Section [NOT STARTED]

**Goal**: Add new subsection covering interior operators, McKinsey-Tarski, and Jonsson-Tarski correspondence.

**Tasks**:
- [ ] Create new subsection `=== Algebraic Classification` after the definitions
- [ ] Define interior operator (deflationary, monotone, idempotent) with mathematical notation
- [ ] State that G, H, □ are interior operators under reflexive semantics
- [ ] Add remark on McKinsey-Tarski: S4 = logic of topological interior
- [ ] Add remark on Jonsson-Tarski: frame reflexivity ↔ operator deflationarity
- [ ] Note loss of interior structure under strict semantics

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - insert after line 145

**Verification**:
- `typst compile main.typ` succeeds
- Mathematical notation renders correctly
- Content aligns with Teammate C findings

---

### Phase 3: Add Expressive Power Section [NOT STARTED]

**Goal**: Add new subsection on frame definability, collapse under reflexive semantics, and inter-definability.

**Tasks**:
- [ ] Create new subsection `=== Expressive Power and Frame Definability`
- [ ] Add table showing DN/DF/SF/SP axioms under strict vs reflexive semantics
- [ ] Explain trivial validity under reflexive (using T-axiom for self-witness)
- [ ] Note that irreflexivity is not modally definable (cite Blackburn-de Rijke-Venema)
- [ ] Add remark on inter-definability: G' = φ ∧ Gφ recovers reflexive from strict
- [ ] Note S4.3.1 alignment for reflexive TM

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - insert after algebraic section

**Verification**:
- `typst compile main.typ` succeeds
- Table formatting matches existing tables in document
- Content aligns with Teammate A findings

---

### Phase 4: Add Representation Theorem Section [NOT STARTED]

**Goal**: Add new subsection on canonical model differences, IRR rule, and completeness architecture.

**Tasks**:
- [ ] Create new subsection `=== Representation Theorem Challenges`
- [ ] Describe canonical model under strict semantics (CanonicalR M N = g_content(M) ⊆ N)
- [ ] Explain Gabbay IRR rule and its dependence on T-axiom
- [ ] Describe canonical model under reflexive semantics (CanonicalR M M holds by T-axiom)
- [ ] Note the three-variant to single-variant completeness collapse
- [ ] Briefly mention antisymmetry approach as replacement for irreflexivity

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - insert after expressive power section

**Verification**:
- `typst compile main.typ` succeeds
- Technical content accurate (cross-check with research report)
- Content aligns with Teammate B findings

---

### Phase 5: Expand Historical Context and Design Rationale [NOT STARTED]

**Goal**: Expand existing remarks into full subsections with historical context and explicit design rationale.

**Tasks**:
- [ ] Expand Historical Context remark into full subsection with Prior's tradition, CS shift, S4.3.1
- [ ] Add brief note on TM's own semantic switches (4 switches, lessons learned)
- [ ] Update Design Rationale remark for reflexive semantics choice
- [ ] Document trade-offs accepted (frame class collapse, departure from strict tradition)
- [ ] Note mathematical necessity (indexed family coherence from Task 658)
- [ ] Note algebraic elegance (interior operator structure)
- [ ] Final verification of all changes

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/typst/chapters/06-notes.typ` - expand lines 147-173 and add content

**Verification**:
- `typst compile main.typ` succeeds with no errors
- All six subsections present and coherent
- Cross-references intact
- Content aligns with Teammate D findings

## Testing & Validation

- [ ] `typst compile Theories/Bimodal/typst/main.typ` succeeds
- [ ] All mathematical notation renders correctly
- [ ] Cross-reference to @sec:truth resolves
- [ ] Total expansion is approximately 150-200 lines
- [ ] Section structure follows Typst conventions (=== subsections)
- [ ] No orphaned content from original version

## Artifacts & Outputs

- `Theories/Bimodal/typst/chapters/06-notes.typ` (modified)
- `specs/033_expand_design_choices_reflexive_analysis/summaries/01_design-choices-summary.md` (created after implementation)

## Rollback/Contingency

- Git commit after each phase enables rollback to any prior state
- Original content is preserved in git history
- If Typst compilation fails, revert phase and diagnose
