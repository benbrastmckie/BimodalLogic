# Implementation Plan: Task #438

**Task**: Refactor Bimodal README for systematic documentation
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

Refactor the Theories/Bimodal/README.md to provide a systematic account of the Bimodal theory following the organizational structure of BimodalReference.tex. The refactored README will present concise inline summaries of syntax, semantics, proof theory, and metalogic while prominently linking to BimodalReference.pdf for detailed reference. Redundancy with other documentation will be reduced by consolidating information and linking rather than duplicating.

## Phases

### Phase 1: Add BimodalReference Link and Header Restructure

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add prominent link to BimodalReference.pdf and BimodalReference.tex at the top of README
2. Restructure the header section to position the reference link prominently
3. Clarify the one-line description of TM logic

**Files to modify**:
- `Theories/Bimodal/README.md` - Add reference links after title

**Steps**:
1. Add "Reference Document" section immediately after the title with links:
   - Format: **BimodalReference** ([tex](latex/BimodalReference.tex) | [pdf](latex/BimodalReference.pdf))
2. Keep the existing "About Bimodal Logic" section but move after reference link
3. Update the description to emphasize this is the README overview while BimodalReference is the detailed specification

**Verification**:
- Links to BimodalReference.tex and BimodalReference.pdf are valid
- Links appear prominently near the top of README

---

### Phase 2: Add Syntax Quick Reference Section

**Estimated effort**: 25 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add compact inline syntax reference table
2. Present primitives and key derived operators
3. Maintain link to BimodalReference for full details

**Files to modify**:
- `Theories/Bimodal/README.md` - Add new "Syntax Quick Reference" section

**Steps**:
1. Create new section "## Syntax Quick Reference" after "About Bimodal Logic"
2. Add primitives table:
   | Symbol | Lean | Reading |
   |--------|------|---------|
   | p | `atom n` | propositional variable |
   | bot | `bot` | falsity |
   | phi -> psi | `imp` | implication |
   | box phi | `box` | necessity |
   | G phi | `all_past` | always was |
   | H phi | `all_future` | always will be |

3. Add derived operators summary (single paragraph with key operators)
4. Reference BimodalReference Section 1 for complete details

**Verification**:
- Table displays correctly in markdown preview
- Operators match actual Lean implementation in Formula.lean

---

### Phase 3: Add Proof System Overview Section

**Estimated effort**: 25 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add condensed axiom table grouped by category
2. Add inference rules summary
3. Link to BimodalReference for full formal presentation

**Files to modify**:
- `Theories/Bimodal/README.md` - Add new "Proof System Overview" section

**Steps**:
1. Create new section "## Proof System Overview" after Syntax
2. Add axiom summary table grouped by category:
   | Category | Axioms | Description |
   |----------|--------|-------------|
   | Propositional | K, S, EFQ, Peirce | Classical propositional logic |
   | Modal S5 | T, 4, B, 5, K | Reflexive, transitive, symmetric |
   | Temporal | K, 4, A, L | Linear temporal structure |
   | Interaction | MF, TF | Modal-temporal bridge |

3. Add inference rules summary:
   - Modus Ponens, Necessitation, Temporal Necessitation
   - Temporal Duality, Axiom, Assumption, Weakening

4. Note that DerivationTree is Type (not Prop) for computability
5. Reference BimodalReference Section 3 for full presentation

**Verification**:
- Axiom groupings match Axioms.lean implementation
- Inference rules match Derivation.lean implementation

---

### Phase 4: Add Semantics Overview Section

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add concise semantics overview
2. Present task frame structure
3. Summarize truth conditions approach
4. Link to BimodalReference for formal definitions

**Files to modify**:
- `Theories/Bimodal/README.md` - Add new "Semantics Overview" section

**Steps**:
1. Create new section "## Semantics Overview" after Proof System
2. Add task frame structure explanation:
   - World states (W)
   - Times (T) with linear order
   - Task relation (R : W -> T -> W -> Prop)
   - Nullity and compositionality properties

3. Add truth conditions summary (prose, not formal):
   - Modal operators: accessibility across worlds
   - Temporal operators: quantification over times
   - Interaction axioms ensure coherence

4. Reference BimodalReference Section 2 for formal definitions

**Verification**:
- Structure matches TaskFrame.lean implementation
- Overview is accessible to newcomers

---

### Phase 5: Consolidate Implementation Status

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace verbose bullet list with compact status table
2. Remove redundancy with IMPLEMENTATION_STATUS.md
3. Add clear link to detailed status document

**Files to modify**:
- `Theories/Bimodal/README.md` - Refactor "Implementation Status" section

**Steps**:
1. Replace current verbose status section with compact table:
   | Layer | Component | Status |
   |-------|-----------|--------|
   | 0 | Syntax | Complete |
   | 1 | ProofSystem | Complete |
   | 2 | Semantics | Complete |
   | 3 | Metalogic | Partial (Soundness proven) |
   | 4 | Theorems | Partial (P1-P3 complete) |
   | 5 | Automation | Partial |

2. Remove detailed bullet points (they duplicate IMPLEMENTATION_STATUS.md)
3. Add single link to IMPLEMENTATION_STATUS.md for details

**Verification**:
- Status table matches current state of implementation
- No redundant detail with IMPLEMENTATION_STATUS.md

---

### Phase 6: Consolidate Documentation Links and Navigation

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Reorganize "Related Documentation" section for clarity
2. Reduce redundancy in documentation links
3. Simplify navigation section
4. Position BimodalReference as primary reference

**Files to modify**:
- `Theories/Bimodal/README.md` - Refactor documentation and navigation sections

**Steps**:
1. Reorganize "Related Documentation" into clear categories:
   - **Primary Reference**: BimodalReference.pdf (formal specification)
   - **User Guides**: Quickstart, Tutorial, Proof Patterns, Examples
   - **Reference Docs**: Axiom Reference, Tactic Reference, Operators
   - **Project Info**: Implementation Status, Known Limitations
   - **Research**: bimodal-logic.md (comparison with Logos)

2. Remove duplicate links that appear in multiple places
3. Simplify Navigation section to 3-4 essential links only:
   - Up (Project Root)
   - Theory Docs (docs/)
   - Examples
   - Tests

4. Remove overly complex navigation structure at bottom

**Verification**:
- All links are valid
- No duplicate links in different sections
- Navigation is simpler and clearer

---

### Phase 7: Final Review and Cleanup

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Review overall document flow and coherence
2. Verify all links work correctly
3. Ensure consistent formatting
4. Remove any remaining redundancy

**Files to modify**:
- `Theories/Bimodal/README.md` - Final cleanup

**Steps**:
1. Read through entire README for flow and coherence
2. Verify all internal links (docs/, latex/, etc.) are valid
3. Ensure consistent heading levels and formatting
4. Check that the document presents a coherent progression:
   - Reference link -> Overview -> Syntax -> Proof System -> Semantics -> Status -> Modules -> Docs

5. Verify BimodalReference is prominently positioned as the authoritative detailed reference
6. Remove any redundant sections or duplicate information

**Verification**:
- Document reads coherently from top to bottom
- All links work
- No redundant sections remain
- BimodalReference is clearly the primary detailed reference

---

## Dependencies

- BimodalReference.pdf must exist at `Theories/Bimodal/latex/BimodalReference.pdf` (verified present)
- BimodalReference.tex must exist at `Theories/Bimodal/latex/BimodalReference.tex` (verified present)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken links after reorganization | Medium | Verify all links in Phase 7 |
| Information loss during consolidation | Low | Only remove truly redundant info; link to detailed docs |
| Inconsistency with Lean code | Medium | Cross-reference Axioms.lean, Formula.lean during table creation |

## Success Criteria

- [ ] BimodalReference.pdf and .tex linked prominently at top
- [ ] Syntax quick reference table added with primitives and derived operators
- [ ] Proof system overview added with grouped axiom table
- [ ] Semantics overview added with task frame structure
- [ ] Implementation status consolidated into compact table
- [ ] Documentation links reorganized with BimodalReference as primary
- [ ] Navigation simplified
- [ ] All links verified working
- [ ] No redundant sections remain
