# Implementation Plan: Task #484

- **Task**: 484 - Sync TikZ diagram operators with GLOSSARY.md
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: None
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: latex
- **Lean Intent**: false

## Overview

Synchronize operators between the TikZ extension dependencies diagram in 00-Introduction.tex and the GLOSSARY.md reference document. This bidirectional sync ensures visual documentation matches the formal reference. Analysis reveals both files share core operators but each has unique entries that should be reflected in the other.

## Goals & Non-Goals

**Goals**:
- Add operators from GLOSSARY.md missing in TikZ diagram where appropriate
- Add operators from TikZ diagram missing in GLOSSARY.md
- Maintain visual clarity and space constraints in TikZ diagram
- Ensure GLOSSARY.md remains comprehensive reference

**Non-Goals**:
- Restructuring the TikZ diagram layout
- Adding operators not documented in either source
- Modifying operator semantics or definitions
- Updating Lean implementations

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TikZ box overflow from too many operators | Medium | Medium | Prioritize core operators, use abbreviated notation |
| LaTeX aux file corruption on rebuild | Low | Low | Clean aux files before build if errors occur |
| GLOSSARY.md format inconsistency | Low | Low | Follow existing table structure strictly |

## Implementation Phases

### Phase 1: Analyze Operator Gaps [NOT STARTED]

**Goal**: Document complete operator inventory and identify gaps in each direction

**Tasks**:
- [ ] Create comparison table of TikZ vs GLOSSARY operators by extension layer
- [ ] Identify operators in GLOSSARY.md missing from TikZ diagram
- [ ] Identify operators in TikZ diagram missing from GLOSSARY.md
- [ ] Prioritize operators for inclusion based on space/importance

**Timing**: 20 minutes

**Gap Analysis (from initial review)**:

Operators in GLOSSARY.md missing from TikZ diagram:
- Boolean operators (not in TikZ - appropriate since they are base logic)
- Relevance operator (included in Constitutive Foundation)
- Store/Recall operators (included in Explanatory Extension)
- Since/Until operators (included in Explanatory Extension)
- Probability (Pr) in Epistemic
- Epistemic might/must (Mi, Mu)
- Indicative conditional
- Preference ordering in Normative
- Ability operators (Can, Able, Cannot) in Agential
- Free choice operators (FP, FF, Ch) in Agential

Operators in TikZ diagram missing from GLOSSARY.md:
- Reflection I operator (mentioned but no formal entry)
- Spatial operators @, Near, Between (section exists but no operator table)

**Verification**:
- Gap analysis document is accurate and complete

---

### Phase 2: Update TikZ Diagram [NOT STARTED]

**Goal**: Add key missing operators to TikZ diagram boxes while maintaining visual balance

**Tasks**:
- [ ] Update Constitutive Foundation box: add relevance operator
- [ ] Update Explanatory Extension box: add Store/Recall, Since/Until
- [ ] Update Epistemic box: add probability or epistemic modals if space permits
- [ ] Update Normative box: add preference or keep minimal
- [ ] Update Agential box: add ability operators
- [ ] Verify TikZ compiles without errors
- [ ] Check visual balance and readability

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` - TikZ diagram

**Proposed Changes**:
1. Constitutive Foundation: add relevance symbol if space permits
2. Explanatory Extension: Already comprehensive; consider adding store/recall
3. Middle Extensions: Keep concise for readability
4. Agential: Add ability modals (Can_a)

**Verification**:
- `pdflatex 00-Introduction.tex` compiles without errors
- Diagram remains visually balanced and readable

---

### Phase 3: Update GLOSSARY.md [NOT STARTED]

**Goal**: Add missing operators from TikZ diagram to GLOSSARY.md

**Tasks**:
- [ ] Add Reflection Extension operator table with I operator
- [ ] Add Spatial Extension operator table with @, Near, Between
- [ ] Verify table formatting matches existing conventions
- [ ] Cross-reference with layer-extensions.md if needed

**Timing**: 25 minutes

**Files to modify**:
- `Theories/Logos/docs/reference/GLOSSARY.md` - Add operator tables for Spatial and Reflection

**Proposed Additions**:
1. Reflection Extension section with I operator table
2. Spatial Extension section with location and relation operators

**Verification**:
- Markdown renders correctly
- Tables follow existing format conventions

---

### Phase 4: Build Verification [NOT STARTED]

**Goal**: Verify all changes build correctly and are consistent

**Tasks**:
- [ ] Build full LaTeX document (LogosReference.tex)
- [ ] Review rendered PDF for diagram quality
- [ ] Verify no LaTeX warnings about overfull boxes
- [ ] Review GLOSSARY.md in rendered markdown

**Timing**: 15 minutes

**Verification**:
- `pdflatex LogosReference.tex` succeeds
- No overfull hbox warnings in diagram area
- GLOSSARY.md displays correctly

## Testing & Validation

- [ ] TikZ diagram compiles without LaTeX errors
- [ ] Full document (LogosReference.tex) builds successfully
- [ ] Diagram maintains visual balance and readability
- [ ] GLOSSARY.md tables render correctly in markdown
- [ ] All operators in diagram have corresponding GLOSSARY entries
- [ ] All major operators in GLOSSARY appear in appropriate diagram boxes

## Artifacts & Outputs

- `Theories/Logos/latex/subfiles/00-Introduction.tex` - Updated TikZ diagram
- `Theories/Logos/docs/reference/GLOSSARY.md` - Updated operator tables
- `specs/484_sync_tikz_diagram_operators_with_glossary/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

Both files are under git version control. If changes cause issues:
1. Revert 00-Introduction.tex with `git checkout HEAD -- Theories/Logos/latex/subfiles/00-Introduction.tex`
2. Revert GLOSSARY.md with `git checkout HEAD -- Theories/Logos/docs/reference/GLOSSARY.md`
3. Clean LaTeX auxiliary files if corruption occurs: `rm -f *.aux *.log *.out`
