# Implementation Plan: Task #434

**Task**: Refactor README for investors and researchers
**Version**: 001
**Created**: 2026-01-12
**Language**: general

## Overview

Comprehensive refactoring of README.md to improve narrative arc and organization. The approach focuses on reordering content to lead with the RL training value proposition for investors while maintaining technical accuracy for researchers. Key changes include: promoting RL Training section, consolidating redundant content, improving TOC with descriptions, adding formal specification links, and relocating Bimodal comparison to appropriate position.

## Phases

### Phase 1: Restructure Opening and Value Proposition

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create new opening structure that leads with value proposition
2. Add formal specification links (LogosReference.tex/pdf, recursive-semantics.md)
3. Move RL Training section to immediately after introduction
4. Remove/consolidate the early Bimodal comparison table

**Files to modify**:
- `README.md` - Lines 1-75

**Steps**:
1. Preserve the title "Logos: A Logic for Interpreted and Verified AI Reasoning"
2. Replace lines 3-13 (early Bimodal comparison) with:
   - Brief 2-3 sentence value proposition focused on RL training potential
   - Formal specification links in format: **Name** ([tex](path) | [pdf](path))
3. Move RL Training content (lines 63-73) to immediately after the new introduction
4. Keep the four-layer architecture summary (lines 18-22) as brief technical overview
5. Retain the dual verification table (lines 23-29) in its condensed form

**Verification**:
- Opening flows: Hook -> Formal Specs -> RL Training -> Brief Architecture
- No redundant Bimodal comparison in opening
- Links to LogosReference.tex/pdf and recursive-semantics.md present

---

### Phase 2: Consolidate Redundant Sections

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Merge redundant content across RL Training, Core Capabilities, and Dual Verification
2. Create single consolidated "Dual Verification Architecture" section
3. Remove duplicate four-layer architecture descriptions
4. Eliminate repetitive Model-Checker descriptions

**Files to modify**:
- `README.md` - Lines 63-204

**Steps**:
1. Analyze overlap between:
   - RL Training (lines 63-73)
   - Core Capabilities (lines 126-159)
   - Dual Verification (lines 163-204)
2. Keep the strongest content from each:
   - From RL Training: Three key advantages (Unbounded, Clean, Justified)
   - From Core Capabilities: Four numbered capability categories
   - From Dual Verification: Architecture table
3. Merge into consolidated structure:
   - "Dual Verification" section with architecture overview
   - Subsections for Syntactic (Logos) and Semantic (Model-Checker) verification
   - Training Signal Generation subsection
4. Remove the redundant Core Capabilities section (absorbed into Dual Verification)
5. Update cross-references

**Verification**:
- No duplicate explanations of RL training benefits
- No duplicate Model-Checker descriptions
- No duplicate four-layer architecture tables
- Single authoritative Dual Verification section

---

### Phase 3: Improve Table of Contents and Navigation

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Add brief descriptions to each TOC entry
2. Update TOC to reflect new section order
3. Ensure all anchor links are correct

**Files to modify**:
- `README.md` - Lines 34-61

**Steps**:
1. Restructure TOC to reflect new section order:
   - **Value Proposition**: RL Training, Motivations
   - **Architecture**: Layered Architecture, Dual Verification, Application Domains
   - **Getting Started**: Installation, Documentation
   - **Reference**: Theoretical Foundations, Citation, License, Contributing
2. Add brief descriptions to each entry:
   ```markdown
   - [RL Training](#rl-training) - Dual verification for self-supervised learning
   - [Motivations](#motivations) - Philosophical foundations for formal reasoning
   ```
3. Verify all anchor links work after restructuring
4. Group entries logically with descriptive headers

**Verification**:
- All TOC links work
- Each entry has descriptive text
- Logical grouping reflects document flow

---

### Phase 4: Relocate Bimodal Section and Update Terminology

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Move Bimodal Theory section to after Theoretical Foundations
2. Update layer terminology to align with recursive-semantics.md
3. Add Spatial and Agential extensions to layer table as "Planned"

**Files to modify**:
- `README.md` - Lines 91-122 (Layered Architecture), 114-122 (Bimodal Theory)

**Steps**:
1. Move Bimodal Theory section (currently lines 114-122) to after Theoretical Foundations:
   - Position as "Related Theory" or within "Reference" section
   - Keep link to detailed bimodal-logic.md
2. Update Layered Architecture table:
   - Align terminology with recursive-semantics.md where appropriate
   - Consider "Explanatory Extension" vs "Causal Layer" (maintain accessibility)
   - Add Spatial and Agential as "Planned" entries
3. Update any cross-references affected by relocation
4. Ensure smooth narrative flow without Bimodal interrupting Logos introduction

**Verification**:
- Bimodal section appears after main Logos content
- Layer table includes Spatial and Agential extensions
- No orphaned cross-references

---

### Phase 5: Final Review and Polish

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Review complete narrative arc
2. Check for remaining redundancy
3. Verify all links work
4. Ensure balanced presentation for investors and researchers

**Files to modify**:
- `README.md` - Full document review

**Steps**:
1. Read document start to finish checking narrative flow:
   - Hook (value proposition) -> RL Training -> Motivations -> Applications
   - Architecture details -> Installation -> Documentation -> Theory -> Footer
2. Verify no redundant bullet point lists (task spec: "avoid endless bullet points")
3. Check all internal anchor links
4. Check all external links (docs/, Theories/, etc.)
5. Verify balance between:
   - Investor appeal (applications, value proposition, RL training)
   - Researcher accuracy (formal semantics, layer specifications, theoretical foundations)
6. Final spelling/grammar check
7. Ensure preserving engaging discussion sections (RL Training, Motivations)

**Verification**:
- Smooth narrative arc from hook to footer
- No redundant sections
- All links functional
- Balanced appeal to both audiences

---

## Dependencies

- Research report: `.claude/specs/434_refactor_readme_for_investors_and_researchers/reports/research-001.md`
- Formal specifications:
  - `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex`
  - `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.pdf`
  - `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/recursive-semantics.md`
- Related documentation: `docs/research/bimodal-logic.md`

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking anchor links | Users cannot navigate document | Verify all TOC links in Phase 3, test after each restructure |
| Losing important content | Gaps in documentation | Keep research report as reference, preserve all content during consolidation |
| Disrupting researcher access | Technical accuracy compromised | Ensure all formal specification links remain, maintain technical depth |
| Over-simplification for investors | Loss of academic credibility | Balance accessible framing with technical precision |
| Cross-reference breakage | External docs point to moved sections | Update anchor names carefully, maintain backward compatibility where possible |

## Success Criteria

- [ ] Opening leads with RL training value proposition, not Bimodal comparison
- [ ] Formal specification links present: LogosReference ([tex] | [pdf]) and recursive-semantics.md
- [ ] TOC includes brief descriptions for each entry
- [ ] No redundant sections (RL Training/Core Capabilities/Dual Verification consolidated)
- [ ] Bimodal section relocated to after main Logos content
- [ ] Layer table includes Spatial and Agential extensions as "Planned"
- [ ] All internal links functional
- [ ] Engaging discussion sections preserved (RL Training, Motivations)
- [ ] Narrative flows naturally for both investors and researchers
- [ ] No excessive bullet point lists

## Estimated Total Effort

| Phase | Description | Hours |
|-------|-------------|-------|
| 1 | Restructure Opening and Value Proposition | 1.5 |
| 2 | Consolidate Redundant Sections | 1.5 |
| 3 | Improve TOC and Navigation | 1.0 |
| 4 | Relocate Bimodal and Update Terminology | 1.0 |
| 5 | Final Review and Polish | 1.0 |
| **Total** | | **6.0** |
