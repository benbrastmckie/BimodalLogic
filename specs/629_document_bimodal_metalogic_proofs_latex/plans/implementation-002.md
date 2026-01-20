# Implementation Plan: Task #629

- **Task**: 629 - document_bimodal_metalogic_proofs_latex
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Priority**: Medium
- **Dependencies**: Task 620 (completed - refined Metalogic_v2 proofs)
- **Research Inputs**: specs/629_document_bimodal_metalogic_proofs_latex/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Previous Version**: plans/implementation-001.md (revised: ASCII diagrams → TikZ)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Restructure and expand `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` to document the Metalogic_v2 proofs with the Representation Theorem as the central result.
The current document treats completeness and representation at the same level; this plan reorganizes content to show how completeness follows as a corollary from the representation theorem.
The goal is to provide a clear narrative arc that guides readers through the theorem dependencies without providing full proofs, only proof remarks and discussion.

### Revision Notes (v002)

**Change from v001**: User feedback specified that ASCII/text diagrams are not sufficient.
TikZ diagrams should be used instead for:
- Core Infrastructure → Representation → Completeness dependency flow
- Import structure/file organization diagram

This adds approximately 30 minutes to the effort estimate for TikZ diagram creation.

### Research Integration

Key findings from research-001.md:
- Representation Theorem is the central bridge between syntax and semantics
- Completeness follows directly via contrapositive of representation
- Two canonical model approaches exist (syntactic and semantic); semantic is primary
- 3 non-blocking sorries remain in the codebase
- Import dependency graph shows clear layered structure

## Goals & Non-Goals

**Goals**:
- Restructure sections to make Representation Theorem the central result
- Add clear narrative showing how completeness follows from representation
- Include dependency/import structure for theorem organization
- Expand proof remarks (2-3 sentences per major theorem)
- Clarify semantic vs syntactic canonical model distinction
- Update implementation status tables for post-Task 620 state
- Follow semantic linefeeds convention (one sentence per line)
- **Create TikZ diagrams** for theorem dependencies and import structure

**Non-Goals**:
- Provide complete formal proofs (only remarks and discussion)
- Document decidability in detail (already well-covered)
- Modify Lean source code
- Address the 3 remaining sorries in code

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| LaTeX compilation errors | Medium | Low | Test compilation after each major section edit |
| Missing theorem coverage | Medium | Low | Cross-reference against research report's theorem list |
| Incorrect proof remarks | High | Low | Reference Lean source comments and research findings |
| Breaking existing cross-references | Low | Low | Check for `\ref` and `\cref` usage before restructuring |
| TikZ diagram complexity | Medium | Low | Use simple node-edge layouts; reference existing TikZ examples in project |

## Implementation Phases

### Phase 1: Section Restructuring [NOT STARTED]

**Goal**: Reorganize section structure to position Representation Theorem as the central result

**Tasks**:
- [ ] Read current section structure and identify reordering needs
- [ ] Add new Section: "Core Infrastructure" after Soundness (Deduction Theorem, MCS, Lindenbaum)
- [ ] Add new Section: "Representation Theory" as central section with subsections for:
  - Canonical World States
  - Canonical Frame and Model
  - Representation Theorem (main result)
  - Strong Representation Theorem
- [ ] Rename "Completeness" to "Completeness as Corollary" and reposition after Representation
- [ ] Move Consistency definitions into Core Infrastructure section
- [ ] Preserve Decidability and Implementation Status sections at end

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - section reordering

**Verification**:
- Document compiles without errors
- All sections present and in logical order: Soundness -> Core Infrastructure -> Representation Theory -> Completeness -> FMP -> Decidability -> Status

---

### Phase 2: Core Infrastructure and Representation Content [NOT STARTED]

**Goal**: Expand Core Infrastructure and add Representation Theory content with proof remarks; create TikZ dependency diagram

**Tasks**:
- [ ] Expand Deduction Theorem subsection with proof strategy remarks:
  - Well-founded recursion on derivation height
  - Key weakening case with `deduction_with_mem`
  - Why modal/temporal rules don't apply (empty context requirement)
- [ ] Expand Lindenbaum's Lemma with proof remarks:
  - Zorn's lemma application on consistent supersets
  - Chain union consistency via finite derivation argument
- [ ] Write Representation Theorem section:
  - State theorem formally: "Every consistent context is satisfiable in the canonical model"
  - Explain why it's central (links syntax to semantics)
  - Proof strategy: consistent G -> extend to MCS via Lindenbaum -> MCS as canonical world satisfies G
  - Mention MCS construction makes truth lemma trivial
- [ ] Add Strong Representation Theorem:
  - Statement and relation to base theorem
- [ ] Create TikZ dependency diagram showing:
  - Core Infrastructure (Deduction Theorem, MCS, Lindenbaum) at bottom
  - Representation Theorem in middle (fed by Core)
  - Completeness at top (derived from Representation)
  - Use arrows to show dependency flow

**Timing**: 1 hour 15 minutes (includes TikZ diagram creation)

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - content expansion and TikZ diagram

**Verification**:
- Representation Theorem clearly stated with proof remarks
- TikZ diagram renders correctly and shows dependency flow
- Document compiles without errors

---

### Phase 3: Completeness and Canonical Model Discussion [NOT STARTED]

**Goal**: Reframe completeness as following from representation; clarify two canonical model approaches

**Tasks**:
- [ ] Rewrite Completeness section intro to explicitly reference Representation Theorem
- [ ] Add Weak Completeness derivation explanation:
  - Contrapositive argument: not provable -> neg phi consistent -> satisfiable -> not valid
  - Reference representation theorem as the key step
- [ ] Add Strong Completeness derivation explanation:
  - Build implication chain from context
  - Apply weak completeness to chain
  - Unfold with modus ponens
- [ ] Add subsection: "Two Canonical Model Approaches"
  - Syntactic approach (MCS-based, archived in Boneyard)
  - Semantic approach (history-time equivalence classes, primary)
  - Why semantic approach is preferred: trivial truth lemma, easy compositionality, no negation-completeness proofs
- [ ] Update Truth Lemma discussion to clarify it follows from semantic construction

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - completeness section rewrite

**Verification**:
- Completeness explicitly derived from Representation Theorem
- Two approaches clearly distinguished
- Semantic approach identified as primary

---

### Phase 4: Import Structure, Status Updates, and Polish [NOT STARTED]

**Goal**: Add import structure documentation with TikZ diagram, update implementation status, final polish

**Tasks**:
- [ ] Add subsection: "File Organization and Dependencies" with:
  - Directory structure overview (Core, Soundness, Representation, Completeness, Applications, Decidability)
  - Create TikZ import dependency diagram showing:
    - Layer boxes for each directory
    - Arrows showing import relationships
    - Clear visual hierarchy
  - Brief description of what each directory contains
- [ ] Add note about sorry status:
  - 3 non-blocking sorries (list them)
  - Explain why they don't block core completeness results
- [ ] Update Implementation Status table:
  - Verify all theorems listed match current Lean codebase
  - Update status for any that changed in Task 620
  - Add Representation Theorem to table if missing
- [ ] Add cross-references to Lean theorem names using `\texttt{}`
- [ ] Final review: ensure semantic linefeeds throughout
- [ ] Verify document compiles cleanly

**Timing**: 45 minutes (includes TikZ import diagram)

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - final additions and polish

**Verification**:
- Import structure documented with TikZ diagram
- Status table accurate and complete
- No LaTeX warnings or errors
- One sentence per line formatting

---

## Testing & Validation

- [ ] Document compiles with `pdflatex 04-Metalogic.tex` (standalone subfile)
- [ ] Document compiles as part of main `BimodalReference.tex`
- [ ] All theorems from research report are documented
- [ ] Representation Theorem is clearly central
- [ ] TikZ diagrams render correctly (dependency flow, import structure)
- [ ] Proof remarks are accurate (cross-check with Lean source comments)
- [ ] No overfull hboxes in output
- [ ] Semantic linefeeds convention followed

## Artifacts & Outputs

- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - Updated LaTeX documentation
- `specs/629_document_bimodal_metalogic_proofs_latex/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

- Original file can be restored via `git checkout HEAD -- Theories/Bimodal/latex/subfiles/04-Metalogic.tex`
- Changes are incremental; each phase can be committed separately for easy partial rollback
- If compilation breaks, review pdflatex error output and fix before proceeding
- If TikZ diagrams prove problematic, fall back to simple `tikzpicture` with basic nodes/edges
