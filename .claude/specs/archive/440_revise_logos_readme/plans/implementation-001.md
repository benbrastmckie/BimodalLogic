# Implementation Plan: Task #440

**Task**: Revise Logos README to reflect current structure and ambitions
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

Complete replacement of the outdated Logos README to accurately reflect the current hyperintensional logic implementation based on recursive-semantics.md. The current README describes a "re-export of Bimodal TM logic" with Layer 0-4 architecture that no longer matches the actual SubTheories/{Foundation,Explanatory,Epistemic,Normative,Spatial}/ structure.

The revision will transform the README from an inaccurate legacy document into an accurate, informative introduction to the Logos hyperintensional logic system.

## Phases

### Phase 1: Replace README structure and introduction

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Replace the misleading "re-export layer" framing with accurate hyperintensional logic description
2. Add philosophical context explaining hyperintensionality vs intensionality
3. Include the extension dependency diagram from recursive-semantics.md

**Files to modify**:
- `Theories/Logos/README.md` - Complete replacement of header and introduction sections

**Steps**:
1. Replace the opening section with "About Logos" describing it as a hyperintensional logic for truthmaker semantics
2. Add "Philosophy" section briefly explaining why hyperintensionality matters (distinguishing necessarily equivalent propositions)
3. Copy the extension dependency ASCII diagram from recursive-semantics.md
4. Remove all references to "re-exporting Bimodal" and "Layer 0-4" numbering

**Verification**:
- README opens with accurate description of Logos purpose
- Extension hierarchy diagram is present
- No references to obsolete architecture

---

### Phase 2: Document core concepts and implementation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add "Core Concepts" section explaining bilateral propositions, task relation, world-histories
2. Document the actual directory structure under SubTheories/
3. Add "Implementation Status" section accurately reflecting current state

**Files to modify**:
- `Theories/Logos/README.md` - Add core concepts, directory structure, and status sections

**Steps**:
1. Add "Core Concepts" section with subsections for:
   - Bilateral propositions (verifier/falsifier pairs)
   - Task relation (ternary relation with duration constraints)
   - World-histories (task-respecting functions over convex time subsets)
2. Add "Directory Structure" section showing:
   - SubTheories/Foundation/ - ConstitutiveFrame, Syntax, Semantics, Proposition
   - SubTheories/Explanatory/ - CoreFrame, Formula, truthAt evaluation
   - SubTheories/Epistemic/ - Stub
   - SubTheories/Normative/ - Stub
   - SubTheories/Spatial/ - Stub
3. Add "Implementation Status" table showing:
   - Foundation: Complete (ConstitutiveFrame, verifies/falsifies)
   - Explanatory: Complete except causal (truthAt for all operators)
   - Epistemic/Normative/Spatial: Stubs only

**Verification**:
- Core concepts match recursive-semantics.md terminology
- Directory structure matches actual SubTheories/ contents
- Implementation status is honest about stubs vs complete

---

### Phase 3: Add operators reference and building instructions

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add table of all operators with their readings
2. Update building and testing instructions for the actual structure
3. Link to recursive-semantics.md and other relevant documentation

**Files to modify**:
- `Theories/Logos/README.md` - Add operators table, build instructions, and references

**Steps**:
1. Add "Operators Reference" table covering:
   - Modal: box (necessity), diamond (possibility)
   - Temporal: H/G (always past/future), P/F (some past/future), Since/Until
   - Counterfactual: box-arrow (would-counterfactual)
   - Store/Recall: up-arrow/down-arrow for cross-temporal reference
2. Update "Building and Testing" section with:
   - `lake build Logos` command
   - Mention of SubTheories module structure
3. Add "Related Documentation" section linking to:
   - `docs/research/recursive-semantics.md` - Detailed semantic specification
   - Other relevant theory documentation
4. Remove obsolete references to files that no longer exist or are irrelevant

**Verification**:
- Operators table matches recursive-semantics.md operator inventory
- Build commands work with current project structure
- Links to documentation are valid

---

## Dependencies

- Research report research-001.md (completed) provides gap analysis
- recursive-semantics.md provides authoritative specification
- Actual SubTheories/ implementation provides ground truth for status

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Documentation links may be stale | Low | Verify each link before including |
| recursive-semantics.md may evolve | Low | Reference the document, don't copy verbatim |
| Build instructions may vary | Low | Test `lake build Logos` before finalizing |

## Success Criteria

- [ ] README accurately describes Logos as hyperintensional logic system
- [ ] Extension hierarchy diagram from recursive-semantics.md included
- [ ] Core concepts (bilateral propositions, task relation, world-histories) documented
- [ ] Directory structure matches actual SubTheories/ contents
- [ ] Implementation status honestly reflects stubs vs complete code
- [ ] Operators reference table present
- [ ] Building instructions accurate
- [ ] No references to obsolete "re-export Bimodal" or "Layer 0-4" architecture
- [ ] Links to recursive-semantics.md and other docs present
