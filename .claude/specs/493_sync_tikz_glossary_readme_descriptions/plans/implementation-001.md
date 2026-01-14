# Implementation Plan: Task #493

- **Task**: 493 - Sync TikZ diagram, GLOSSARY.md, and README.md descriptions
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .claude/specs/493_sync_tikz_glossary_readme_descriptions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan synchronizes three documentation sources (TikZ diagram, GLOSSARY.md, README.md) that describe the Logos extension architecture. Research identified structural inconsistencies (Agential/Reflection parallel vs sequential), missing extensions (Social), operator symbol differences (Perm/Forb vs FP/FF), and varying operator inventories. The approach is to use TikZ as the authoritative source, then propagate updates to GLOSSARY and README.

### Research Integration

Key findings from research-001.md:
- TikZ shows Agential/Social/Reflection as parallel in grey box; README shows sequential
- Social extension exists only in TikZ (decision needed on inclusion elsewhere)
- Choice operators differ: TikZ uses Perm/Forb/Ch, GLOSSARY uses FP/FF/Ch
- Agent indexing inconsistent: B vs B_a notation
- Store/recall, Since/Until, Mi/Mu operators missing from some sources

## Goals & Non-Goals

**Goals**:
- Synchronize layer structure descriptions across all three sources
- Standardize operator symbols and naming conventions
- Add missing operators to GLOSSARY and README
- Ensure consistent dependency descriptions for extensions
- Produce documentation that accurately reflects the Logos architecture

**Non-Goals**:
- Changing the actual Lean implementation
- Adding new features or extensions not already documented somewhere
- Redesigning the TikZ diagram layout
- Creating new documentation files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TikZ changes break PDF compilation | High | Medium | Test PDF build after TikZ changes |
| Symbol standardization breaks other LaTeX files | Medium | Medium | Search for affected references before changing |
| README diagram becomes too complex | Low | Low | Keep ASCII simple; reference LaTeX for detail |
| Social extension removal loses information | Low | Low | Document rationale in changes |

## Implementation Phases

### Phase 1: Decision Resolution & TikZ Updates [NOT STARTED]

**Goal**: Resolve research decisions and update TikZ as authoritative source

**Tasks**:
- [ ] Decision: Keep Social extension in TikZ only (theoretical, not operator-based)
- [ ] Decision: Standardize Choice operators to FP/FF/Ch (GLOSSARY notation)
- [ ] Decision: Use agent-indexed notation (B_a, K_a) in technical docs
- [ ] Update TikZ Choice extension: change Perm to FP, Forb to FF
- [ ] Update TikZ Since/Until symbols: ensure consistent with GLOSSARY (S, U already present - verify correct)
- [ ] Verify TikZ compiles after changes

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/latex/subfiles/00-Introduction.tex` - TikZ diagram updates

**Verification**:
- TikZ diagram renders correctly in PDF
- Choice operators show FP/FF/Ch
- No compilation errors

---

### Phase 2: GLOSSARY.md Synchronization [NOT STARTED]

**Goal**: Update GLOSSARY to match TikZ structure and add missing content

**Tasks**:
- [ ] Add Social extension section (mark as "theoretical, no operators")
- [ ] Add missing operators: Reduction (Rightarrow), dotcircleright (causal might)
- [ ] Verify Choice operators match TikZ (FP/FF/Ch - should already be correct)
- [ ] Add clarification for extension dependencies
- [ ] Ensure Explanatory Extension lists quantifiers (forall, exists)
- [ ] Verify Since/Until operators documented correctly

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Logos/docs/reference/GLOSSARY.md` - Add missing content, sync structure

**Verification**:
- All TikZ operators have GLOSSARY entries
- Extension dependency descriptions consistent with TikZ
- Social extension documented appropriately

---

### Phase 3: README.md Synchronization [NOT STARTED]

**Goal**: Update README to match authoritative TikZ/GLOSSARY content

**Tasks**:
- [ ] Update ASCII diagram to show Agential/Social/Reflection as parallel (grey box)
- [ ] Add Social extension to extension list
- [ ] Add missing operator mentions: Store/recall, Mi/Mu, Since/Until
- [ ] Update extension descriptions to match TikZ
- [ ] Clarify dependency requirements for Agential and Reflection extensions
- [ ] Keep ASCII diagram simple; add reference to LaTeX docs for details

**Timing**: 45 minutes

**Files to modify**:
- `README.md` - ASCII diagram and extension descriptions

**Verification**:
- ASCII diagram matches TikZ structure
- All extensions mentioned in README
- Dependency descriptions consistent

---

### Phase 4: Cross-Reference Validation [NOT STARTED]

**Goal**: Verify consistency across all three sources

**Tasks**:
- [ ] Create comparison checklist of key elements
- [ ] Verify layer structure matches in all three
- [ ] Verify operator symbols consistent
- [ ] Verify extension dependencies described consistently
- [ ] Test TikZ PDF compilation
- [ ] Review all changes for consistency

**Timing**: 45 minutes

**Files to modify**:
- None (validation only)

**Verification**:
- Side-by-side comparison shows no discrepancies
- PDF builds successfully
- No conflicting information between sources

## Testing & Validation

- [ ] TikZ diagram compiles to PDF without errors
- [ ] All extensions documented in all three sources (or explicitly marked as excluded)
- [ ] Operator symbols consistent across sources
- [ ] Extension dependency descriptions match
- [ ] ASCII diagram in README reflects TikZ structure
- [ ] No broken cross-references in documentation

## Artifacts & Outputs

- Updated `Theories/Logos/latex/subfiles/00-Introduction.tex`
- Updated `Theories/Logos/docs/reference/GLOSSARY.md`
- Updated `README.md`
- Implementation summary in `summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If changes cause documentation inconsistency or compilation failures:
1. Revert individual files using git: `git checkout HEAD -- <file>`
2. Changes are independent per phase; can rollback individual phases
3. TikZ diagram can be reverted without affecting GLOSSARY/README
4. Keep original research report as reference for re-implementation
