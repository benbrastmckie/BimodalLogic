# Research Report: Task #430

**Task**: Refactor documentation to present ProofChecker as general framework
**Date**: 2026-01-12
**Focus**: Analyze current README.md and docs/README.md structure, identify how to present
ProofChecker as a general framework supporting multiple theories (Bimodal/ and Logos/)

## Summary

The current documentation heavily focuses on Logos as the primary product with Bimodal as an
implementation detail. To present ProofChecker as a general framework, documentation needs
restructuring to position the project as a framework for developing related theories with
formal semantics, proof systems, and metalogics, with Bimodal and Logos as two example theories.

## Current Documentation Analysis

### Root README.md Structure

The current README.md (444 lines) is Logos-centric:
- Title: "Logos: Verified Reasoning in a Formal Language of Thought"
- Focuses on Logos's layered architecture (Constitutive, Causal, Epistemic, Normative)
- Mentions Bimodal only indirectly as "TM bimodal logic" or "Core Layer"
- References "Theories/Logos/docs/" for research documents
- The "Layered Architecture" section describes Logos-specific layers

**Key Issues**:
1. Project is named "ProofChecker" but README emphasizes "Logos"
2. Bimodal is fully implemented but presented as a component of Logos
3. No clear framework narrative for supporting multiple theories
4. Table of Contents doesn't distinguish framework vs theory documentation

### docs/README.md Structure

The docs/README.md (289 lines) already has better framework framing:
- Title: "ProofChecker Documentation"
- Has "Theory-Specific Documentation" table referencing Bimodal and Logos
- Links to theory comparison document
- Organizes by audience (New Users, Contributors, Developers, Researchers)

**Strengths to preserve**:
1. Clear separation of theory-specific vs project-wide documentation
2. Good navigation by use case
3. References theory-comparison.md for understanding differences

**Issues**:
1. Still some Logos-centric language
2. Missing explicit "framework" framing
3. Could better explain the relationship between theories

### Theories/ Directory Structure

The project already has good theory separation:
```
Theories/
├── Bimodal/           # Fully implemented TM logic
│   ├── Bimodal.lean
│   └── docs/          # Complete theory documentation
├── Bimodal.lean       # Root module
├── Logos/             # Hyperintensional logic (partial)
│   ├── SubTheories/   # Foundation, Explanatory, etc.
│   └── docs/          # Theory documentation
├── Logos.lean         # Root module (currently re-exports Bimodal)
└── README.md          # Theory overview
```

### docs/research/theory-comparison.md

This document (167 lines) provides excellent theory differentiation:
- Clearly distinguishes Bimodal (propositional intensional) vs Logos (second-order hyperintensional)
- Tables comparing semantic primitives, interpretation, operators
- "When to Use Each" section
- Good theoretical background

**This document should be more prominently featured.**

## Recommendations

### 1. Restructure Root README.md

**Current Title**: "Logos: Verified Reasoning in a Formal Language of Thought"

**Proposed Title**: "ProofChecker: A Framework for Verified Formal Logic in Lean 4"

**New Structure**:
```
# ProofChecker: A Framework for Verified Formal Logic in Lean 4

## Overview
ProofChecker is an extensible framework for developing formal logic theories...

## Supported Theories
| Theory | Status | Type | Documentation |
|--------|--------|------|---------------|
| Bimodal | Active | Propositional intensional (TM logic) | Theories/Bimodal/docs/ |
| Logos | Partial | Hyperintensional (layered extensions) | Theories/Logos/docs/ |

## Framework Architecture
- Common infrastructure for syntax, proof systems, semantics, metalogic
- Task-based semantics model shared across theories
- Dual verification architecture (LEAN proofs + Model-Checker)

## Theory: Bimodal (TM Logic)
[Current "Core Layer (TM Logic)" section, expanded]

## Theory: Logos (Hyperintensional)
[Current layer architecture section]

## Adding New Theories
[Instructions from Theories/README.md "Adding a New Theory"]
```

### 2. Update docs/README.md

**Changes needed**:
1. Add explicit "Framework Overview" section
2. Strengthen "Theory-Specific Documentation" with implementation status
3. Add "Adding New Theories" link
4. Reframe as documentation hub for the framework

### 3. Key Messaging Changes

**From**: "Logos implements..." / "The Logos is an extensible formal language..."

**To**: "ProofChecker provides..." / "The ProofChecker framework supports..."

**Theory-specific messaging**:
- Bimodal: "A fully implemented propositional intensional logic combining S5 modal and
  linear temporal operators"
- Logos: "A hyperintensional logic with state-based semantics and layered extensions
  (Foundation complete, extensions in development)"

### 4. Documentation Cross-References

**Missing links to add**:
- Root README.md → docs/research/theory-comparison.md (prominent position)
- Root README.md → Theories/README.md (for adding theories)
- docs/README.md → Theories/README.md

### 5. Structural Changes to Consider

**Option A**: Keep current structure, update language
- Minimal disruption
- Clear that Logos is primary research direction
- Framework positioning through narrative

**Option B**: Rebalance to equal theory treatment
- More significant README restructuring
- Equal coverage for Bimodal and Logos sections
- More "framework" oriented

**Recommended**: Option A with strong framework framing
- Current structure reflects development priorities (Logos is research focus)
- Bimodal is mature and well-documented in its theory directory
- Framework narrative can be established without restructuring

## Implementation Guidelines

### Phase 1: Root README.md Refactoring

1. **New Opening Section**: Present ProofChecker as framework
   - What is ProofChecker?
   - What theories does it support?
   - What infrastructure does it provide?

2. **Theory Overview Table**: Early placement showing both theories
   - Theory name, status, type, link to docs
   - Clear that multiple theories are supported

3. **Preserve Logos Content**: Current detailed Logos content remains
   - It's the active research direction
   - Has more complex architecture worth documenting

4. **Add Bimodal Section**: Elevate from "Core Layer" to peer theory
   - Current status (complete)
   - What it provides
   - Link to Bimodal/docs/

### Phase 2: docs/README.md Updates

1. **Framework Overview**: New section explaining framework concept
2. **Theory Selection Guide**: Help users choose which theory
3. **Cross-references**: Ensure all theory docs are discoverable

### Phase 3: Theories/README.md Enhancement

Current Theories/README.md is good but could be enhanced:
1. More detailed "Adding a New Theory" guidance
2. Theory comparison summary
3. Shared infrastructure explanation

## Files to Modify

| File | Changes | Priority |
|------|---------|----------|
| README.md | Major restructure - framework framing | High |
| docs/README.md | Update framing, add framework section | High |
| Theories/README.md | Enhance theory guidance | Medium |
| docs/research/theory-comparison.md | Add to main navigation | Low |

## Success Criteria

1. Root README.md presents ProofChecker as a framework first, then introduces theories
2. Both Bimodal and Logos are clearly presented as supported theories
3. Users understand how theories relate to the framework
4. Path to adding new theories is documented
5. Existing Logos-focused content remains valuable for researchers

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Diluting Logos research focus | Medium | Keep detailed Logos sections, just reframe |
| Breaking existing links | High | Careful link audit during implementation |
| Confusing existing users | Low | Clear migration notes in commit |

## References

- `/home/benjamin/Projects/ProofChecker/README.md` - Current root README
- `/home/benjamin/Projects/ProofChecker/docs/README.md` - Current docs hub
- `/home/benjamin/Projects/ProofChecker/Theories/README.md` - Theory overview
- `/home/benjamin/Projects/ProofChecker/docs/research/theory-comparison.md` - Theory comparison
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/docs/README.md` - Bimodal docs
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/README.md` - Logos docs

## Next Steps

1. Run /plan 430 to create detailed implementation plan with specific edits
2. Phase 1: Refactor README.md with new structure
3. Phase 2: Update docs/README.md
4. Phase 3: Enhance Theories/README.md
5. Verify all cross-references work
