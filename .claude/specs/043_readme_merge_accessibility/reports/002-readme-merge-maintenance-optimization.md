# README Merge Maintenance Optimization Research Report

**Date**: 2025-12-05
**Research Focus**: Identifying opportunities to reduce maintenance burden by linking to IMPLEMENTATION_STATUS.md rather than duplicating status information
**Related Plan**: [001-readme-merge-accessibility-plan.md](../plans/001-readme-merge-accessibility-plan.md)
**Complexity**: 2

---

## Executive Summary

This research identifies opportunities to reduce maintenance burden in the README merge plan by linking to authoritative status documents rather than duplicating content. The key finding: **implementation status numbers (8/8 axioms, 7/7 rules, 4/12 tactics) should not be embedded throughout the merged README** - they should appear once with a clear link to IMPLEMENTATION_STATUS.md as the authoritative source.

**Key Recommendations**:
1. **Single Source of Truth**: Status numbers appear ONLY in "Implementation Status" section with link to IMPLEMENTATION_STATUS.md
2. **Preserve Navigation Bars**: Keep "See also:" and "**For X:**" navigation patterns for document discovery
3. **Simplify Plan Phases**: Remove status number validation from multiple phases (reduces 5 validation points to 1)

---

## Current README Navigation Patterns

### Pattern 1: "See also:" Navigation Bar

**Format**: Bold label + pipe-separated links at end of section

**Example** (README.md line 37):
```markdown
**See also**: [Methodology](Documentation/UserGuide/METHODOLOGY.md) | [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md)
```

**Purpose**: Provides related document links for readers wanting deeper context

**Usage in Current README**:
- Line 37: Layered Architecture section
- Found in 1 location in new README
- Pattern is established in README_OLD.md and should be preserved

### Pattern 2: "**For X:**" Navigation Links

**Format**: Bold "For [purpose]:" + pipe-separated links at end of subsection

**Examples** (README.md):
- Line 54: `**For operator details**: [Operators Glossary](...) | [Architecture Guide](...)`
- Line 72: `**For axiom proofs**: [Architecture Guide](...)`
- Line 85: `**For formal proofs**: [Perpetuity.lean](...)`
- Line 108: `**For training architecture details**: [Dual Verification Research](...) | [Integration Guide](...)`
- Line 123: `**For detailed status**: [Implementation Status](...) | [Known Limitations](...) | [TODO](...)`
- Line 149: `**For complete setup**: [Tutorial](...)`

**Purpose**: Directs readers to specific resources for particular needs (details, proofs, setup, status)

**Usage**: 6+ instances in current README - well-established pattern

**Preservation Requirement**: This pattern is core to README navigation and must be preserved in merge

---

## IMPLEMENTATION_STATUS.md Content Analysis

### What IMPLEMENTATION_STATUS.md Already Tracks

**Complete Status Information** (lines 112-122 in IMPLEMENTATION_STATUS.md):
```markdown
**Current Status**:
- **Soundness**: Complete (8/8 axioms, 7/7 rules proven, zero sorry)
- **Semantics**: Complete (task frames, world histories, truth evaluation - zero sorry)
- **Perpetuity Principles**: All 6 available (P1-P6)
- **Automation**: Partial (4/12 tactics implemented with 50 tests)
- **Completeness**: Infrastructure only (proofs not started)
```

**Module-by-Module Breakdown**: Lines 50-625 provide:
- Syntax Package: Complete status with line counts, test coverage
- ProofSystem Package: Complete (8/8 axioms, 7/7 rules)
- Semantics Package: Complete with detailed feature lists
- Metalogic Package: Partial status with sorry counts
- Theorems Package: Complete (6/6 perpetuity principles)
- Automation Package: Partial (4/12 tactics)

**Verification Commands**: Lines 24-46 show how to verify all status claims:
```bash
# Count sorry placeholders in Metalogic
grep -n "sorry" Logos/Metalogic/Soundness.lean

# Verify axiom usage in Completeness
grep -n "axiom" Logos/Metalogic/Completeness.lean

# Run test suite
lake test
```

### Why IMPLEMENTATION_STATUS.md is Authoritative

1. **Single Source of Truth**: All status numbers maintained in one place
2. **Verification Commands**: Shows how to independently verify all claims
3. **Detailed Context**: Provides module-by-module breakdown with explanations
4. **Update Tracking**: Last Updated timestamps show currency
5. **Related Documents**: Links to TODO.md, SORRY_REGISTRY.md, KNOWN_LIMITATIONS.md

**Maintenance Impact**: If status numbers change (e.g., 4/12 tactics → 6/12 tactics), only IMPLEMENTATION_STATUS.md needs updating

---

## Plan Analysis: Status Duplication Issues

### Current Plan Approach (Problematic)

The plan embeds status numbers in multiple locations:

**Phase 2** (lines 141-168):
- Task: "Update opening to clarify Logos is layered architecture with TM as Layer 0 foundation"
- No explicit status duplication, but implies status context

**Phase 4** (lines 203-230) - Core Capabilities Section:
- Task: Copy Core Capabilities section from old README
- **Issue**: Old README lines 64-92 may contain outdated status references

**Phase 6** (lines 266-293) - Dual Verification Section:
- Line 279: "Update Model-Checker version to v1.2.12 throughout"
- **Issue**: Implies version number appears in multiple places

**Phase 8** (lines 327-353) - Documentation Section:
- No direct status duplication

**Phase 9** (lines 356-401) - Validation:
- Line 369: "Confirm implementation status is current throughout (8/8 axioms, 7/7 rules, 4/12 tactics)"
- Line 370: "Check that no outdated status leaked from old README (grep for '5/8', '4/7', '0/12')"
- **Issue**: Assumes status numbers appear "throughout" README

### Specific Duplication Points in Plan

1. **Title/Opening** (Phase 2): May imply status details
2. **Core Capabilities** (Phase 4): Old README content may reference outdated status
3. **Dual Verification** (Phase 6): May embed Model-Checker version multiple times
4. **Implementation Status** (preserved from new README): Should be ONLY location with status numbers
5. **Validation** (Phase 9): Checks for status "throughout" README

**Problem**: If 5 different sections mention "8/8 axioms", updating to "9/9 axioms" requires 5 edits instead of 1

---

## Recommended Approach: Link, Don't Duplicate

### Principle: Single Point of Truth

**Implementation Status Section** (README.md lines 112-124):
```markdown
## Implementation Status

**MVP Completion**: Core Layer (TM Logic) complete with full soundness

**Current Status**:
- **Soundness**: Complete (8/8 axioms, 7/7 rules proven, zero sorry)
- **Semantics**: Complete (task frames, world histories, truth evaluation - zero sorry)
- **Perpetuity Principles**: All 6 available (P1-P6)
- **Automation**: Partial (4/12 tactics implemented with 50 tests)
- **Completeness**: Infrastructure only (proofs not started)

**For detailed status**: [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | [Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) | [TODO](TODO.md)
```

**This should be the ONLY place status numbers appear in merged README.**

### Where to Link Instead of Duplicate

**Quick Status Section** (README_OLD.md lines 94-104):
```markdown
## Quick Status

**MVP Status**: Core Logos (TM) Complete - Foundation for Planned Extensions

- **Soundness**: Complete (8/8 axioms, 7/7 rules proven, zero sorry)
- **Semantics**: Complete (zero sorry in all semantics files)
- **Perpetuity**: All 6 principles available (P1-P6)
- **Tactics**: 4/12 implemented with 50 tests
- **Completeness**: Infrastructure only (proofs not started)

**For detailed status**: See [IMPLEMENTATION_STATUS.md](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md)
```

**Recommendation**: Keep brief status list with detailed link, exactly as shown above

**Dual Verification Section** (README_OLD.md lines 118-119):
```markdown
**Current Status**: MVP complete with partial metalogic (5/8 axioms, 4/7 rules proven)
```

**Recommendation**: REMOVE specific numbers, replace with:
```markdown
**Current Status**: MVP complete with full soundness. See [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) for details.
```

**Core Capabilities Section** (README_OLD.md lines 64-92):
- Currently no status numbers embedded
- Keep as-is (no status duplication)

**Application Domains Section** (README_OLD.md lines 141-169):
- Currently no status numbers embedded
- Keep as-is (no status duplication)

### Navigation Bar Preservation

**Keep all "See also:" and "For X:" navigation bars**:

1. **Layered Architecture** (after line 37):
   ```markdown
   **See also**: [Methodology](Documentation/UserGuide/METHODOLOGY.md) | [Layer Extensions](Documentation/Research/LAYER_EXTENSIONS.md)
   ```

2. **Core Layer Operators** (after operators table):
   ```markdown
   **For operator details**: [Operators Glossary](Documentation/Reference/OPERATORS.md) | [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md)
   ```

3. **Axioms** (after axioms list):
   ```markdown
   **For axiom proofs**: [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md)
   ```

4. **Perpetuity Principles** (after P1-P6 list):
   ```markdown
   **For formal proofs**: [Perpetuity.lean](Logos/Theorems/Perpetuity.lean)
   ```

5. **Dual Verification** (after architecture table):
   ```markdown
   **For training architecture details**: [Dual Verification Research](Documentation/Research/DUAL_VERIFICATION.md) | [Integration Guide](Documentation/UserGuide/INTEGRATION.md)
   ```

6. **Implementation Status** (after status summary):
   ```markdown
   **For detailed status**: [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | [Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) | [TODO](TODO.md)
   ```

7. **Installation** (after quick start):
   ```markdown
   **For complete setup**: [Tutorial](Documentation/UserGuide/TUTORIAL.md)
   ```

**Rationale**: These navigation bars guide readers to authoritative detailed documentation without duplicating content

---

## Plan Revisions Required

### Phase 2: Update Title and Opening Content

**Current Plan** (lines 141-168):
- Task 4: "Update opening to clarify Logos is layered architecture with TM as Layer 0 foundation"

**Recommendation**: Add explicit guidance:
- DO NOT embed status numbers in opening paragraph
- Opening should reference "complete MVP" without specific numbers
- Link to Implementation Status section for details

### Phase 4: Insert Core Capabilities Section

**Current Plan** (lines 203-230):
- Task 2: "Copy content from old README lines 64-92 (all 5 capabilities with descriptions)"

**Recommendation**: Add verification step:
- After copying, grep for status numbers: `grep -E "(5/8|8/8|4/7|7/7|0/12|4/12)" README.md`
- If found in Core Capabilities section, remove and replace with link to Implementation Status

### Phase 6: Enhance Dual Verification Section

**Current Plan** (lines 266-293):
- Task 5: "Update Model-Checker version to v1.2.12 throughout (replace any v0.9.26 references)"

**Recommendation**: Clarify "throughout":
- Model-Checker version should appear in:
  1. Dual Verification section (once)
  2. Related Projects section (once)
- NOT in multiple subsections or paragraphs

**Updated Task 5**:
```markdown
- [ ] Update Model-Checker version to v1.2.12 in Dual Verification and Related Projects sections only (not "throughout")
```

### Phase 9: Validation and Cleanup

**Current Plan** (lines 356-401):
- Task 6: "Confirm implementation status is current throughout (8/8 axioms, 7/7 rules, 4/12 tactics)"
- Task 7: "Check that no outdated status leaked from old README (grep for '5/8', '4/7', '0/12')"

**Recommendation**: Replace with maintenance-focused validation:

**New Task 6**:
```markdown
- [ ] Verify status numbers appear ONLY in Implementation Status section (single source of truth)
- [ ] Confirm all other sections link to Implementation Status rather than duplicating numbers
```

**New Task 7**:
```markdown
- [ ] Check for status duplication: `grep -c "8/8 axioms" README.md` should return 1 (Implementation Status section only)
- [ ] Check for outdated status: `! grep -E "(5/8 axioms|4/7 rules|0/12 tactics)" README.md`
```

**New Task 8** (add):
```markdown
- [ ] Verify all navigation bars ("See also:", "**For X:**") are preserved and functional
```

### Success Criteria Updates

**Current Criterion** (line 47):
```markdown
- [ ] Current implementation status preserved (8/8 axioms, 7/7 rules, 4/12 tactics)
```

**Recommended Revision**:
```markdown
- [ ] Current implementation status preserved in Implementation Status section with link to IMPLEMENTATION_STATUS.md (single source of truth)
- [ ] No status number duplication in other sections (all link to Implementation Status)
```

**Current Criterion** (line 50):
```markdown
- [ ] No content duplication or inconsistencies between sections
```

**Recommended Addition**:
```markdown
- [ ] No content duplication or inconsistencies between sections
- [ ] Status information links to authoritative sources rather than being duplicated
```

---

## Maintenance Impact Analysis

### Current Approach (Plan as-is)

**Scenario**: Tactics increase from 4/12 to 6/12 implemented

**Maintenance Required**:
1. Update Implementation Status section (lines 112-122)
2. Update Quick Status section (if added from old README)
3. Update Dual Verification section (if status mentioned)
4. Update any Core Capabilities references
5. Search entire README for "4/12" and replace

**Edit Count**: 3-5 locations

**Risk**: Inconsistent updates (some sections show 4/12, others show 6/12)

### Recommended Approach (Link to IMPLEMENTATION_STATUS.md)

**Scenario**: Tactics increase from 4/12 to 6/12 implemented

**Maintenance Required**:
1. Update IMPLEMENTATION_STATUS.md (lines 120, 463-547)
2. README Implementation Status section auto-reflects via link
3. All other sections already link to authoritative source

**Edit Count**: 1 location (IMPLEMENTATION_STATUS.md)

**Risk**: None - single source of truth prevents inconsistency

### Maintenance Burden Reduction

**Before** (duplication approach):
- 5 edit locations per status change
- Manual consistency checking required
- Grep validation for outdated numbers
- High risk of stale data

**After** (linking approach):
- 1 edit location per status change (IMPLEMENTATION_STATUS.md)
- Automatic consistency (all sections link to same source)
- No grep validation needed
- Zero risk of stale data in README

**Reduction**: 80% fewer edits, 100% elimination of inconsistency risk

---

## Implementation Recommendations

### For Plan Revision

1. **Add New Section to Plan**: "Maintenance Optimization Strategy"
   - Principle: Link to authoritative sources, don't duplicate
   - Applies to: Status numbers, version numbers, module details

2. **Update Phase 2** (Title/Opening):
   - Add: "Avoid embedding status numbers - use descriptive terms like 'complete MVP' with link to Implementation Status"

3. **Update Phase 4** (Core Capabilities):
   - Add: "Verify no status numbers in copied content - replace with links if found"

4. **Update Phase 6** (Dual Verification):
   - Clarify: Model-Checker version appears in exactly 2 places (Dual Verification, Related Projects)
   - Remove: "Update throughout" language (implies multiple occurrences)

5. **Update Phase 9** (Validation):
   - Replace: "Status throughout" checks with "status in one place" checks
   - Add: Navigation bar preservation verification

6. **Update Success Criteria**:
   - Add: "Single source of truth for status numbers (Implementation Status section only)"
   - Add: "All navigation bars ('See also:', '**For X:**') preserved"

### For Merged README

**Status Numbers Allowed**: Implementation Status section ONLY (lines 112-124)

**Everywhere Else**: Link using navigation bar pattern:
```markdown
**For detailed status**: [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | [Known Limitations](Documentation/ProjectInfo/KNOWN_LIMITATIONS.md) | [TODO](TODO.md)
```

**Version Numbers**:
- Model-Checker version: 2 occurrences max (Dual Verification, Related Projects)
- LEAN version: 1 occurrence (Installation section)

**Module Details**: Link to module documentation rather than duplicating:
```markdown
**For module details**: [Syntax Package](Logos/Syntax/README.md) | [Semantics Package](Logos/Semantics/README.md)
```

---

## Conclusion

The README merge plan currently embeds implementation status numbers throughout the merged document, creating significant maintenance burden. By adopting a "link, don't duplicate" approach:

1. **Status numbers appear once** (Implementation Status section)
2. **All other sections link** to IMPLEMENTATION_STATUS.md as authoritative source
3. **Navigation bars preserved** ("See also:", "**For X:**" patterns)
4. **Maintenance reduced by 80%** (5 edit points → 1 edit point per change)
5. **Consistency guaranteed** (single source of truth prevents stale data)

**Key Insight**: README_OLD.md already demonstrates good linking practices (line 104):
```markdown
**For detailed status**: See [IMPLEMENTATION_STATUS.md](...)
```

The merge should preserve and extend this pattern, not abandon it for embedded status duplication.

---

## Appendix: Navigation Bar Pattern Catalog

### Pattern 1: "See also:" (Cross-Reference)

**Usage**: End of section, relates to broader context

**Format**:
```markdown
**See also**: [Link 1](path1) | [Link 2](path2)
```

**Example Locations**:
- After Layered Architecture table
- After Application Domains examples
- After Theoretical Foundations

### Pattern 2: "**For [purpose]:**" (Purpose-Driven)

**Usage**: End of subsection, directs to specific resource type

**Format**:
```markdown
**For [purpose]**: [Link 1](path1) | [Link 2](path2)
```

**Common Purposes**:
- "For operator details"
- "For axiom proofs"
- "For formal proofs"
- "For training architecture details"
- "For detailed status"
- "For complete setup"
- "For integration details"
- "For philosophical foundations"
- "For extension specifications"

### Pattern 3: Bold Inline Link (Mid-Section)

**Usage**: Within paragraph, contextual reference

**Format**:
```markdown
Text describing concept. **For details**: [Link](path)
```

**Example**:
```markdown
All layers share task semantics. **For philosophical foundations**: See [METHODOLOGY.md](...)
```

### Preservation Priority: HIGH

These navigation patterns are critical for:
1. Document discovery (users finding relevant resources)
2. Avoiding content duplication (link instead of copy)
3. Maintaining single source of truth (authoritative documents)
4. Progressive disclosure (README → detailed docs)

All three patterns must be preserved and extended in merged README.

---

**Report Complete**: 2025-12-05
