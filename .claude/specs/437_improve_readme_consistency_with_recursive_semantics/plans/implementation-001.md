# Implementation Plan: Task #437

**Task**: Improve README consistency with recursive-semantics.md
**Version**: 001
**Created**: 2026-01-12
**Language**: general
**Estimated Effort**: 2-3 hours

## Overview

This plan addresses the inconsistencies between README.md and recursive-semantics.md identified in research-001.md. The implementation focuses on five key areas: (1) terminology alignment ("Causal" to "Explanatory"), (2) overview/table consistency (4 layers to 6), (3) adding dependency structure, (4) strengthening ModelChecker integration, and (5) minor fixes (knowledge operator, hyperintensional descriptions).

The approach prioritizes consistency with the authoritative recursive-semantics.md specification while maintaining README accessibility for investors and researchers.

---

## Phases

### Phase 1: Terminology Alignment

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Change "Causal Layer" to "Explanatory Extension" for consistency with recursive-semantics.md
2. Update "Constitutive Layer" to "Constitutive Foundation" where appropriate
3. Maintain consistent use of "Layer" vs "Extension" terminology

**Files to modify**:
- `README.md` - Lines 35, 88-96, 101-106

**Steps**:
1. Update line 35: Change "Causal Layer" to "Explanatory Extension" with clarifying text about the scope (modal, temporal, counterfactual, and causal operators)
2. Update line 91 in the Layered Architecture table: Change "Causal" to "Explanatory"
3. Update the Constitutive Layer section header (line 101) and description to emphasize the "Foundation" aspect
4. Add a brief note near the table explaining that "Extensions" build on the Constitutive Foundation

**Verification**:
- Grep for "Causal Layer" in README.md should return 0 matches after update
- "Explanatory" terminology should be used consistently for the modal/temporal/counterfactual/causal layer

---

### Phase 2: Align Overview with Table

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Expand the Overview section (lines 32-37) to mention all 6 layers/extensions
2. Ensure consistency between Overview descriptions and the Layered Architecture table

**Files to modify**:
- `README.md` - Lines 32-38

**Steps**:
1. Rewrite the layer list in the Overview section to include all 6 extensions:
   - Constitutive Foundation
   - Explanatory Extension (was Causal)
   - Epistemic Extension
   - Normative Extension
   - Spatial Extension
   - Agential Extension
2. Ensure descriptions match the table content
3. Add brief mention of the dependency structure (Foundation required, others optional/composable)

**Verification**:
- Count of layers mentioned in Overview should equal 6
- Each layer description should be consistent with the corresponding table row

---

### Phase 3: Add Dependency Structure Diagram

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add a simplified ASCII dependency diagram showing the extension hierarchy
2. Clarify which extensions are required vs optional

**Files to modify**:
- `README.md` - Layered Architecture section (after line 86)

**Steps**:
1. Insert a simplified dependency diagram after the "See also" links and before the table:
```
Extension Dependency Structure:

    Constitutive Foundation (required)
              │
              ▼
    Explanatory Extension (required)
              │
     ┌────────┼────────┐
     ▼        ▼        ▼
 Epistemic Normative Spatial  (optional, composable)
     └────────┼────────┘
              ▼
      Agential Extension  (requires at least one above)
```
2. Add brief explanatory text about the dependency structure
3. Keep the diagram compact to maintain README scannability

**Verification**:
- Diagram renders correctly in GitHub markdown preview
- Dependencies match those specified in recursive-semantics.md

---

### Phase 4: Strengthen ModelChecker Integration

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Enhance the RL Training section to emphasize dual verification architecture
2. Improve the Related Projects section with clearer ModelChecker description
3. Add explicit link to ModelChecker repository in appropriate locations

**Files to modify**:
- `README.md` - RL Training section (lines 11-27), Related Projects section (lines 332-336)

**Steps**:
1. Enhance the RL Training section to explicitly state:
   - ModelChecker implements the same Logos semantic theory in Python/Z3
   - Together they form a dual verification system (LEAN proves validity, Z3 finds countermodels)
   - This provides complete RL training signals for AI reasoning
2. Update the Related Projects section:
   - Change ModelChecker description from brief mention to fuller explanation
   - Emphasize "parallel development" of Logos in both LEAN and Python/Z3
3. Add ModelChecker link to the Integration Guide reference in appropriate locations

**Verification**:
- "ModelChecker" appears in both RL Training and Related Projects sections with consistent messaging
- The dual verification concept is clearly articulated

---

### Phase 5: Minor Fixes and Polish

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add "knowledge" to the Epistemic layer operators
2. Enhance the Constitutive Foundation description to mention hyperintensionality
3. Final review for consistency and polish

**Files to modify**:
- `README.md` - Lines 92 (Epistemic operators), 101-106 (Constitutive description)

**Steps**:
1. Update line 92 (Epistemic layer in table):
   - Change "Belief, probability, indicative" to "Belief, knowledge, probability, indicative"
2. Update Constitutive Layer description (lines 101-106):
   - Add mention of hyperintensional semantics distinguishing propositions by exact verification/falsification conditions
   - Preserve existing content about predicates, functions, quantifiers
3. Review entire README for:
   - Consistent terminology (Extension vs Layer)
   - Accurate operator listings
   - Proper cross-references to recursive-semantics.md
4. Verify all internal links work correctly

**Verification**:
- "knowledge" appears in Epistemic layer operators
- "hyperintensional" appears in Constitutive Foundation description
- No broken internal links

---

## Dependencies

- Research report completed: `.claude/specs/437_improve_readme_consistency_with_recursive_semantics/reports/research-001.md`
- Task 434 (README refactor) completed: Provides baseline README structure
- No external dependencies

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing cross-references | Medium | Verify all internal links after changes |
| Terminology change confusion | Low | Use clear, consistent terminology throughout |
| Diagram rendering issues | Low | Test in GitHub markdown preview before committing |
| Inconsistency with recursive-semantics.md | High | Cross-reference during each phase |

## Success Criteria

- [ ] "Causal Layer" replaced with "Explanatory Extension" (or clarified)
- [ ] Overview section lists all 6 extensions
- [ ] Dependency structure diagram added
- [ ] ModelChecker integration emphasized in RL Training section
- [ ] "knowledge" added to Epistemic operators
- [ ] Hyperintensional semantics mentioned in Constitutive description
- [ ] All internal links verified working
- [ ] Terminology consistent with recursive-semantics.md

## Implementation Notes

### Terminology Decision

Per research recommendation, use Option A: Full alignment with recursive-semantics.md terminology. This means:
- "Constitutive Foundation" (not "Constitutive Layer")
- "Explanatory Extension" (not "Causal Layer")
- Consistent use of "Extension" for all six components

### Preservation of Content

This task focuses on consistency improvements, not content removal. Key existing sections should be preserved:
- RL Training section (lines 11-27)
- Motivations section (lines 68-79)
- Application Domains section (lines 117-145)

### Table of Contents

After changes, verify the Table of Contents links still work. The section names "Layered Architecture" and "Constitutive Layer" may be updated to "Constitutive Foundation" requiring TOC updates.
