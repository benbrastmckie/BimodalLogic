# Implementation Plan: Task #433

**Task**: Refine README title and consolidate Bimodal documentation
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

This plan refines the README.md title to align with the LaTeX reference manual and consolidates the detailed Bimodal documentation into a dedicated `bimodal-logic.md` document, replacing the generic `theory-comparison.md`. The README.md Bimodal section will be condensed to a brief summary with links.

## Phases

### Phase 1: Create bimodal-logic.md

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create the authoritative Bimodal presentation document
2. Include comprehensive operator and axiom coverage
3. Add comparison section with Logos
4. Note future repository separation

**Files to modify**:
- `docs/research/bimodal-logic.md` - Create new file

**Steps**:
1. Create new file `docs/research/bimodal-logic.md` with title "A Bimodal Logic for Tense and Modality"
2. Write Overview section introducing TM bimodal logic
3. Write "The Bimodal Theory" section with:
   - Classification (propositional intensional, zeroth-order)
   - Semantic primitives (world states, times, task relation)
   - Operators table (from README.md lines 120-127)
   - Axiom schemas (S5, Temporal, Bimodal Interaction from README.md lines 132-148)
   - Perpetuity principles P1-P6 (from README.md lines 151-161)
   - Implementation status with links to `Theories/Bimodal/README.md`
4. Write "Comparison with Logos" section covering:
   - Intensional vs hyperintensional semantics
   - Key differences table (from theory-comparison.md lines 89-97)
   - Hyperintensional advantages (from theory-comparison.md lines 109-118)
   - When to use each (from theory-comparison.md lines 127-148)
5. Write "Future: Repository Separation" section noting planned extraction
6. Add navigation links to related documentation

**Verification**:
- File exists at `docs/research/bimodal-logic.md`
- Contains all operator, axiom, and perpetuity content from README.md
- Contains comparison content from theory-comparison.md
- All internal links are valid

---

### Phase 2: Update README.md Title and Bimodal Section

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Align title with LogosReference.tex subtitle
2. Condense Bimodal section to brief summary
3. Update link to point to new bimodal-logic.md

**Files to modify**:
- `README.md` - Update title and Bimodal section

**Steps**:
1. Change title from "Logos: A Framework for Verified Formal Logic in Lean 4" to "Logos: A Logic for Interpreted and Verified AI Reasoning"
2. Update line 12 link from `docs/research/theory-comparison.md` to `docs/research/bimodal-logic.md` with text "Bimodal Logic"
3. Replace detailed Bimodal section (lines 114-164) with condensed version:
   ```markdown
   ## Bimodal Theory

   The project also includes **Bimodal**, a complete propositional intensional logic
   combining S5 modal and linear temporal operators. Developed in parallel with Logos,
   Bimodal provides an excellent starting point for understanding modal-temporal
   reasoning and demonstrates the boundaries of purely intensional semantics.

   For the full presentation of Bimodal and its comparison with Logos, see
   [A Bimodal Logic for Tense and Modality](docs/research/bimodal-logic.md).

   For implementation details, see [Theories/Bimodal/README.md](Theories/Bimodal/README.md).
   ```
4. Update Table of Contents to reflect removed detailed sections (remove Core Layer (TM Logic) if present, update Bimodal Theory entry)

**Verification**:
- Title matches LogosReference.tex subtitle
- Bimodal section is 8-12 lines (condensed from 50+)
- Link to bimodal-logic.md works
- Table of Contents is accurate

---

### Phase 3: Delete theory-comparison.md and Update All References

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Remove obsolete theory-comparison.md
2. Update all cross-references to point to bimodal-logic.md
3. Ensure no broken links

**Files to modify**:
- `docs/research/theory-comparison.md` - Delete
- `docs/research/README.md` - Update reference
- `docs/README.md` - Update references (lines 36, 79, 187, 202)
- `Theories/Logos/README.md` - Update references (lines 17, 209)
- `Theories/Logos/docs/README.md` - Update references (lines 23, 109)
- `Theories/Logos/docs/research/README.md` - Update reference (line 38)
- `Theories/Logos/docs/reference/EXTENSION_STUBS.md` - Update reference (line 123)
- `Theories/Logos/docs/reference/AXIOM_REFERENCE.md` - Update reference (line 63)
- `Theories/Logos/docs/project-info/ROADMAP.md` - Update references (lines 161, 168)
- `Theories/Logos/docs/user-guide/QUICKSTART.md` - Update references (lines 60, 65)
- `Theories/Logos/docs/user-guide/CURRENT_STATUS.md` - Update reference (line 119)
- `Theories/Bimodal/README.md` - Update references (lines 17, 219)
- `Theories/Bimodal/docs/README.md` - Update references (lines 17, 108)
- `Theories/Bimodal/docs/research/README.md` - Update reference (line 64)

**Steps**:
1. Delete `docs/research/theory-comparison.md`
2. Update `docs/research/README.md`:
   - Change `theory-comparison.md` to `bimodal-logic.md`
   - Update description to reflect Bimodal focus
3. Update `docs/README.md`:
   - Line 36: Change link to `bimodal-logic.md` with text "Bimodal Logic"
   - Line 79: Update filename and description
   - Lines 187, 202: Update link text and target
4. Update `Theories/Logos/README.md`:
   - Line 17: Change to bimodal-logic.md
   - Line 209: Update link target and text
5. Update `Theories/Logos/docs/README.md`:
   - Lines 23, 109: Update references
6. Update remaining Logos docs files:
   - `research/README.md`, `reference/EXTENSION_STUBS.md`, `reference/AXIOM_REFERENCE.md`
   - `project-info/ROADMAP.md`, `user-guide/QUICKSTART.md`, `user-guide/CURRENT_STATUS.md`
7. Update `Theories/Bimodal/README.md`:
   - Lines 17, 219: Update references
8. Update `Theories/Bimodal/docs/README.md`:
   - Lines 17, 108: Update references
9. Update `Theories/Bimodal/docs/research/README.md`:
   - Line 64: Update reference

**Verification**:
- `docs/research/theory-comparison.md` no longer exists
- `grep -r "theory-comparison.md"` returns no results (except archive files)
- All new links to `bimodal-logic.md` resolve correctly

---

### Phase 4: Verification and Cleanup

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify all internal links work
2. Ensure narrative coherence
3. Confirm no orphaned content

**Files to modify**:
- None (verification only)

**Steps**:
1. Run link check: `grep -r "bimodal-logic.md" docs/ Theories/` to verify all new links
2. Run broken link check: `grep -r "theory-comparison.md"` to ensure none remain (except archives)
3. Read through README.md to verify narrative flow focuses on Logos
4. Read through bimodal-logic.md to verify comprehensive Bimodal coverage
5. Verify Table of Contents in README.md matches actual headings

**Verification**:
- No broken internal links
- README.md narrative focuses on Logos as primary
- bimodal-logic.md is comprehensive with good links to Theories/Bimodal/
- All cross-references updated

---

## Dependencies

- Research report completed (research-001.md)
- Access to all files identified in Phase 3

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking internal links | Medium | Systematic grep search before/after, update all found references |
| Losing README.md content | Low | All Bimodal content preserved in bimodal-logic.md |
| Missing reference updates | Medium | Use grep to find all references; verify post-implementation |
| Archive file references | Low | Archive files intentionally unchanged (historical record) |

## Success Criteria

- [ ] New `docs/research/bimodal-logic.md` created with comprehensive Bimodal presentation
- [ ] README.md title changed to "Logos: A Logic for Interpreted and Verified AI Reasoning"
- [ ] README.md Bimodal section condensed to 8-12 lines with link to bimodal-logic.md
- [ ] `docs/research/theory-comparison.md` deleted
- [ ] All 20+ cross-references updated to bimodal-logic.md
- [ ] No broken links (verified by grep)
- [ ] README.md narrative focuses on Logos as primary theory
