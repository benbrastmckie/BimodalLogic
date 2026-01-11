# Implementation Plan: Task #347

**Task**: Revise Logos layer documentation for new layer organization
**Version**: 002
**Created**: 2026-01-09
**Revision of**: implementation-001.md
**Reason**: Remove Next (X) and Previous (Y) operators as they are only relevant for discrete theories of time, which is not assumed.

## Revision Summary

The original plan included Next (X) and Previous (Y) tense operators in both Phase 1 (RECURSIVE_SEMANTICS.md creation) and Phase 3 (GLOSSARY.md updates). These operators have been removed because they only have natural applications given a discrete frame, and the Logos framework does not assume discrete time.

### Previous Plan Status
- Phase 1: [NOT STARTED]
- Phase 2: [NOT STARTED]
- Phase 3: [NOT STARTED]
- Phase 4: [NOT STARTED]

### Key Changes
1. **Phase 1**: Removed Next (X) and Previous (Y) from extended tense operators list; only Since (S) and Until (U) remain as extended operators
2. **Phase 3**: Removed Next (X) and Previous (Y) from glossary entries to add
3. **General**: Clarified that the framework does not assume discrete time throughout

## Overview

This plan implements a comprehensive revision of the Logos layer documentation to reflect the new five-layer architecture: Constitutive, Causal, Epistemic, Normative, and Agential layers. The work involves three main deliverables:

1. **LAYER_EXTENSIONS.md**: Complete restructure from old Layer 0-3 format to new five-layer organization, incorporating the FIX tag content
2. **GLOSSARY.md**: Update layer architecture table and reassign operators to correct layers
3. **RECURSIVE_SEMANTICS.md**: New document with full hyperintensional and intensional semantic specifications

The approach preserves existing valuable content (examples, motivation) while reorganizing structure and adding detailed semantic clauses from research reports. The temporal structure assumes a totally ordered abelian group (not necessarily discrete).

## Phases

### Phase 1: Create RECURSIVE_SEMANTICS.md Foundation

**Estimated effort**: 2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create new RECURSIVE_SEMANTICS.md with complete document structure
2. Document Constitutive Layer hyperintensional semantics (frame, model, verification/falsification clauses)
3. Document Causal Layer intensional semantics (frame extensions, truth conditions, all operators)
4. Add placeholder sections for Epistemic, Normative, Agential layers with [DETAILS] tags

**Files to modify**:
- `docs/research/RECURSIVE_SEMANTICS.md` - Create new file

**Steps**:
1. Create document with frontmatter linking to LAYER_EXTENSIONS.md and METHODOLOGY.md
2. Write Introduction section explaining recursive semantic approach and layer progression
3. Write Constitutive Layer section:
   - Frame definition (complete lattice of states ordered by parthood)
   - Model components (interpretation function for predicates, function symbols)
   - Verification/falsification clauses for all formula types (atomic, negation, conjunction, disjunction, top, bottom, propositional identity)
   - Logical consequence for constitutive sentences
4. Write Causal Layer section:
   - Frame extensions (temporal order as totally ordered abelian group, task relation with nullity/compositionality)
   - State modality definitions (possible states, compatible states, maximal states, world-states)
   - World-history definition
   - Truth conditions for all operators:
     - Atomic sentences (parthood-based)
     - Extensional connectives (negation, conjunction, disjunction)
     - Modal operators (□, ◇)
     - Core tense operators (H, G, P, F)
     - Extended tense operators (Since S, Until U) - *note: no discrete-only operators*
     - Counterfactual conditional (mereological formulation)
     - Store/Recall operators (↑, ↓)
   - Bimodal interaction principles (P1-P6)
   - Temporal frame extensions (density, completeness, unboundedness - not discreteness)
   - Logical consequence for causal sentences
5. Write placeholder sections for remaining layers:
   - Epistemic Layer with [DETAILS] and [QUESTION: credence function structure?]
   - Normative Layer with [DETAILS] and [QUESTION: value ordering structure?]
   - Agential Layer with [DETAILS] and [QUESTION: multi-agent frame extensions?]
6. Add References section linking to academic sources

**Verification**:
- Document compiles without markdown errors
- All semantic clauses from research-002.md are included (except discrete-only operators)
- Placeholder sections clearly marked with [DETAILS] tags
- Cross-references to other documentation are valid
- No references to Next (X) or Previous (Y) operators

---

### Phase 2: Restructure LAYER_EXTENSIONS.md

**Estimated effort**: 2.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Replace Layer 0-3 structure with Constitutive/Causal/Epistemic/Normative/Agential structure
2. Incorporate FIX tag content into main document body
3. Remove FIX comment once content is properly integrated
4. Preserve and relocate valuable examples to appropriate new layers
5. Update all internal cross-references

**Files to modify**:
- `docs/research/LAYER_EXTENSIONS.md` - Major restructure

**Steps**:
1. Read current LAYER_EXTENSIONS.md to identify all sections to preserve
2. Create new document structure:
   ```
   # Logos Layer Extensions

   ## Overview
   ## The Five-Layer Architecture

   ### Constitutive Layer (Foundation)
   - Frame structure
   - Hyperintensional semantics summary
   - Link to RECURSIVE_SEMANTICS.md for full details

   ### Causal Layer
   - Frame extensions (temporal, task relation)
   - Key operators (modal, tense, counterfactual)
   - Planning applications
   - Link to RECURSIVE_SEMANTICS.md for full details

   ### Epistemic Layer
   - Frame extensions (credence functions)
   - Operators (belief, knowledge, probability)
   - Uncertainty reasoning applications
   - [DETAILS] for unspecified semantics

   ### Normative Layer
   - Frame extensions (value orderings)
   - Operators (obligation, permission, preference)
   - Multi-agent coordination applications
   - [DETAILS] for unspecified semantics

   ### Agential Layer
   - Multi-agent extensions
   - [DETAILS] for unspecified structure

   ## Layer Interaction and Composition
   ## Implementation Status
   ## Related Documentation
   ```
3. Migrate existing content from old Layer 0-3 sections to new structure:
   - Core TM content → Causal Layer
   - Counterfactual/causal content → Causal Layer
   - Epistemic content → Epistemic Layer
   - Normative content → Normative Layer
4. Incorporate FIX tag content for Constitutive Layer description
5. Preserve examples (medical treatment, legal evidence, negotiation) in appropriate sections
6. Remove the FIX comment block (lines 9-36) after integration
7. Update all internal links and cross-references
8. Add link to new RECURSIVE_SEMANTICS.md for detailed semantics

**Verification**:
- All content from FIX tag is integrated into main body
- FIX comment is removed
- Examples are preserved and appropriately located
- All internal links work correctly
- Document follows consistent formatting

---

### Phase 3: Update GLOSSARY.md

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Update Layer Architecture table to reflect five-layer organization
2. Reassign operators to correct layers
3. Add new terms for Constitutive Layer concepts
4. Ensure consistency with LAYER_EXTENSIONS.md and RECURSIVE_SEMANTICS.md

**Files to modify**:
- `docs/reference/GLOSSARY.md` - Update layer terminology

**Steps**:
1. Read current GLOSSARY.md to understand existing structure
2. Update Layer Architecture section:
   - Replace Layer 0/1/2/3 with Constitutive/Causal/Epistemic/Normative/Agential
   - Update operator assignments for each layer
3. Add new glossary entries for Constitutive Layer:
   - State space, parthood relation
   - Verification, falsification
   - Bilateral proposition
   - Propositional identity
   - Hyperintensional semantics
4. Update existing entries:
   - Frame → include mereological structure
   - World-history → include task relation constraints
   - Counterfactual → reference mereological semantics
5. Add new entries for operators:
   - Store operator (↑)
   - Recall operator (↓)
   - Since (S), Until (U)
   - *(Note: Next and Previous operators omitted - discrete time not assumed)*
6. Review all layer references throughout glossary for consistency
7. Update cross-references to LAYER_EXTENSIONS.md and RECURSIVE_SEMANTICS.md

**Verification**:
- Layer Architecture table matches LAYER_EXTENSIONS.md
- All operators assigned to correct layers
- New terms for Constitutive Layer are defined
- Cross-references are valid
- No references to discrete-only operators (Next, Previous)

---

### Phase 4: Cross-Reference Audit and Final Review

**Estimated effort**: 0.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Verify all cross-references between the three documents
2. Check for consistency in terminology and layer naming
3. Ensure [DETAILS] and [QUESTION: ...] tags are properly formatted
4. Final quality check on all modified files

**Files to modify**:
- `docs/research/LAYER_EXTENSIONS.md` - Minor fixes if needed
- `docs/reference/GLOSSARY.md` - Minor fixes if needed
- `docs/research/RECURSIVE_SEMANTICS.md` - Minor fixes if needed

**Steps**:
1. Verify all links from LAYER_EXTENSIONS.md to RECURSIVE_SEMANTICS.md work
2. Verify all links from GLOSSARY.md to both documents work
3. Check terminology consistency:
   - "Constitutive Layer" used consistently (not "Layer 0" or "Base Layer")
   - "Causal Layer" used consistently (not "Layer 1" or "Explanatory Layer")
   - Same for Epistemic, Normative, Agential
4. Verify [DETAILS] tag formatting is consistent
5. Verify [QUESTION: ...] tags include specific questions
6. Read through all three documents for coherence
7. Fix any broken links or inconsistencies found

**Verification**:
- All cross-document links resolve correctly
- Terminology is consistent across all three documents
- [DETAILS] and [QUESTION: ...] tags are properly formatted
- Documents read coherently as a unified documentation set

---

## Dependencies

- Research reports research-001.md and research-002.md must be available
- Academic source papers (possible_worlds.tex, counterfactual_worlds.tex) used for semantic clause verification
- No blocking dependencies on other tasks

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FIX tag content ambiguity | Medium | Low | Research reports clarify interpretation; use [QUESTION: ...] for remaining uncertainties |
| Breaking existing cross-references | Medium | Medium | Phase 4 audit specifically checks all links |
| Inconsistent terminology | Low | Medium | Use search/replace for systematic updates; Phase 4 verification |
| Missing semantic details for higher layers | Low | High | Expected - use [DETAILS] tags as specified in task requirements |

## Success Criteria

- [ ] RECURSIVE_SEMANTICS.md created with complete Constitutive and Causal layer semantics
- [ ] LAYER_EXTENSIONS.md restructured to five-layer organization
- [ ] FIX comment removed from LAYER_EXTENSIONS.md (content integrated)
- [ ] GLOSSARY.md updated with correct layer assignments
- [ ] All [DETAILS] tags in place for unspecified layer semantics
- [ ] All [QUESTION: ...] tags identify specific design decisions
- [ ] Cross-references between documents are valid
- [ ] Existing examples preserved in appropriate locations
- [ ] No references to discrete-only operators (Next, Previous)

## Rollback Plan

If implementation fails or introduces errors:
1. All three documents are under git version control
2. Revert to pre-implementation commit: `git checkout HEAD~1 -- docs/research/LAYER_EXTENSIONS.md docs/reference/GLOSSARY.md`
3. For new file RECURSIVE_SEMANTICS.md: simply delete if rollback needed
4. Research reports preserved regardless of implementation outcome
