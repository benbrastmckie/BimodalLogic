# Implementation Plan: Task #461

**Task**: Expand Bimodal Theory README Section
**Version**: 001
**Created**: 2026-01-13
**Language**: general

## Overview

Expand the Bimodal Theory section in README.md (lines 163-172) to explain:
1. Bimodal captures the fundamental time-possibility relationship
2. It serves as a well-motivated intensional target for methodology development
3. The scaling strategy from simpler to more complex theory

## Research Summary

From research-001.md:
- Current section is ~80 words, functional but doesn't explain strategic purpose
- Need to add ~170-220 words explaining why Bimodal matters for Logos
- Key concepts: perpetuity principles, methodology testbed, scaling strategy

## Phases

### Phase 1: Draft Expanded Content

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Write expanded Bimodal Theory section
2. Preserve existing links and references
3. Match README.md style and tone

**Content Structure**:

**Paragraph 1** (existing intro + time-possibility):
- Keep first sentence about complete propositional intensional logic
- Add: captures fundamental relationship between time and possibility
- Mention perpetuity principles as key theoretical results

**Paragraph 2** (methodology testbed):
- Bimodal as simpler intensional target
- Same three-part methodology (proof system + semantics + metalogic)
- Validates approach before scaling to hyperintensional complexity

**Paragraph 3** (scaling to Logos):
- What transfers: task semantics, proof patterns, automation
- Why this matters: confidence in methodology at greater complexity

**Paragraph 4** (existing contrast + links):
- Keep existing content about intensional vs hyperintensional contrast
- Keep existing links to documentation

**Draft Text**:

```markdown
## Bimodal Theory

The project includes the **Bimodal** theory, a complete propositional intensional logic combining S5 modal and linear temporal operators. Bimodal captures a fundamental philosophical insight: the deep relationship between time and possibility. The present opens onto multiple possible futures (world-histories) that share a common past. This relationship is formalized through the **perpetuity principles** (P1-P6), which establish that what is necessary is perpetual and what occurs is possible.

Bimodal provides a well-motivated purely intensional target for developing the formal methodology—axiomatic proof system, recursive semantics, and metalogic—that will then be extended to Logos. By validating the methodology at a simpler complexity level (propositional, intensional, world-states as primitives), we gain confidence before scaling to the hyperintensional complexity of Logos (second-order, fine-grained states with parthood, layered extensions).

The patterns developed in Bimodal transfer directly to Logos: task semantics for relating states across time, proof system architecture for deriving valid inferences, soundness proof techniques, and automation strategies. This scaling approach ensures that the foundational machinery is robust before tackling the greater expressivity of hyperintensional reasoning.

The contrast between Bimodal's purely intensional semantics and Logos's hyperintensional foundation demonstrates the advantages of hyperintensional semantics for supporting a wider range of operators including explanatory, epistemic, and normative operators that require distinguishing necessarily equivalent propositions.

For the full presentation of Bimodal and its comparison with Logos, see [A Bimodal Logic for Tense and Modality](docs/research/bimodal-logic.md).

For implementation details, see [Theories/Bimodal/README.md](Theories/Bimodal/README.md).
```

**Verification**:
- Content covers all three key points from research
- Preserves existing links
- Word count ~260 words (within target expansion)

---

### Phase 2: Apply Edit to README.md

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Replace existing Bimodal Theory section with expanded version
2. Verify edit applied correctly

**Files to modify**:
- `README.md` - Lines 163-172 (Bimodal Theory section)

**Steps**:
1. Read current README.md to confirm exact section boundaries
2. Apply edit replacing old section with new content
3. Verify no formatting issues

**Verification**:
- Section header preserved
- Links still work
- Markdown renders correctly

---

### Phase 3: Verify and Commit

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Run quick verification
2. Commit changes

**Steps**:
1. Review the edited section in context
2. Count words to confirm target (~260)
3. Commit with task message

**Verification**:
- Section reads naturally in context
- No broken links
- Git commit succeeds

---

## Dependencies

- Research report: `specs/461_expand_bimodal_theory_readme_section/reports/research-001.md` (complete)
- Current README.md content (read during implementation)

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Section too long for README style | Low | Review in context; trim if needed |
| Breaks existing links | Low | Preserve all existing link text exactly |
| Inconsistent with other sections | Low | Match tone of surrounding sections |

## Success Criteria

- [ ] Bimodal Theory section expanded from ~80 to ~260 words
- [ ] Explains time-possibility relationship
- [ ] Explains methodology testbed purpose
- [ ] Explains scaling strategy to Logos
- [ ] Preserves existing links
- [ ] Maintains README.md style consistency

## Estimated Total Effort

| Phase | Effort |
|-------|--------|
| Phase 1: Draft Content | 15 min |
| Phase 2: Apply Edit | 5 min |
| Phase 3: Verify and Commit | 5 min |
| **Total** | **25 min** |
