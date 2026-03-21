# Research Report: Task #433

**Task**: Refine README title and consolidate Bimodal documentation
**Date**: 2026-01-12
**Focus**: Analyze current README.md structure, LogosReference.tex title, docs/research/theory-comparison.md content, and Bimodal section to plan consolidation into a single theory comparison document

## Summary

The current documentation presents Logos and Bimodal theories across multiple files with overlapping content. The README.md title ("Logos: A Framework for Verified Formal Logic in Lean 4") differs from LogosReference.tex subtitle ("A Logic for Interpreted and Verified AI Reasoning"). The Bimodal section in README.md contains substantial detail that would be better placed in a dedicated theory comparison document, allowing README.md to focus on the primary Logos theory.

## Findings

### 1. Current README.md Title and Structure

**Current Title**: "Logos: A Framework for Verified Formal Logic in Lean 4"

**LogosReference.tex Subtitle** (line 88): "A Logic for Interpreted and Verified AI Reasoning"

**Observation**: The LogosReference.tex subtitle better captures the project's focus on:
- Interpreted reasoning (semantic models provide interpretability)
- Verified reasoning (proof receipts ensure validity)
- AI reasoning (primary application domain)

The current README title emphasizes "Framework" and "Formal Logic" which is accurate but less distinctive than the AI reasoning focus.

**Recommendation**: Adopt "Logos: A Logic for Interpreted and Verified AI Reasoning" as the README.md title to align with the LaTeX reference manual and emphasize the AI application focus.

### 2. Bimodal Section in README.md (Lines 114-164)

**Current Content**:
- Classification as propositional intensional logic
- Full operator table (7 operators)
- Complete axiom listing (S5 Modal: MT, M4, MB; Temporal: T4, TA, TL; Bimodal Interaction: MF, TF)
- Perpetuity principles (P1-P6)
- Links to formal proofs

**Issues**:
1. **Length**: The Bimodal section (50+ lines) is disproportionately detailed compared to other README sections
2. **Redundancy**: Content duplicates information in:
   - `docs/research/theory-comparison.md` (182 lines)
   - `Theories/Bimodal/README.md` (234 lines)
   - `Theories/Bimodal/docs/reference/AXIOM_REFERENCE.md`
3. **Focus dilution**: Detailed Bimodal coverage dilutes the primary Logos narrative
4. **Future maintenance**: When Bimodal is extracted to its own repository, this section becomes orphaned content

**Recommendation**: Replace the detailed Bimodal section with a brief mention (5-10 lines) and link to the consolidated theory comparison document.

### 3. New Document: docs/research/bimodal-logic.md

**Strategy**: Replace `docs/research/theory-comparison.md` with a new document `docs/research/bimodal-logic.md` titled **"A Bimodal Logic for Tense and Modality"** that:

1. **Focuses primarily on presenting the Bimodal theory** in careful detail
2. **Links to existing Bimodal documentation** rather than duplicating:
   - `Theories/Bimodal/README.md` - Implementation details
   - `Theories/Bimodal/docs/README.md` - Technical documentation hub
   - `Theories/Bimodal/docs/reference/AXIOM_REFERENCE.md` - Axiom details
3. **Includes a comparison section** with Logos after the Bimodal presentation
4. **Notes the planned extraction** to a separate repository

**Rationale**: The current `theory-comparison.md` tries to serve two purposes (Bimodal presentation and comparison) without excelling at either. A Bimodal-focused document with a comparison section at the end better serves users who want to understand Bimodal, while also providing the comparison context.

**Recommendation**: Create `docs/research/bimodal-logic.md` as the canonical Bimodal presentation document, linking to existing detailed documentation in `Theories/Bimodal/`.

### 4. Content Overlap Analysis

| Content | README.md | theory-comparison.md | Bimodal/README.md |
|---------|-----------|---------------------|-------------------|
| Bimodal classification | Yes | Yes | Yes |
| Operator table | Detailed | Brief | Reference links |
| Axiom listing | Full list | None | Reference links |
| Perpetuity principles | Full list | None | Brief mention |
| Implementation status | Brief | Minimal | Detailed |
| Semantic primitives | Minimal | Good | Good |
| When to use | None | Good | None |
| Theoretical references | Minimal | Good | None |

### 5. Consolidation Strategy

**Goal**: Create `docs/research/bimodal-logic.md` titled **"A Bimodal Logic for Tense and Modality"** as the authoritative Bimodal presentation in the main docs/, replacing the generic `theory-comparison.md`.

**Proposed Structure for bimodal-logic.md**:

```markdown
# A Bimodal Logic for Tense and Modality

## Overview
Brief introduction to TM bimodal logic combining S5 modality and linear time.

## The Bimodal Theory
### Classification
- Propositional intensional logic (zeroth-order)
- Task-based Kripke semantics

### Operators
Full operator table (from README.md)

### Axiom Schemas
- S5 Modal axioms (MT, M4, MB)
- Temporal axioms (T4, TA, TL)
- Bimodal interaction axioms (MF, TF)
(Link to Theories/Bimodal/docs/reference/AXIOM_REFERENCE.md for details)

### Perpetuity Principles
P1-P6 principles (from README.md)

### Implementation Status
Current state with links to Theories/Bimodal/README.md

## Comparison with Logos
### Intensional vs Hyperintensional Semantics
Why Bimodal's purely intensional semantics cannot express certain distinctions

### Expressivity Boundaries
What Logos can express that Bimodal cannot (propositional attitudes, grounding, etc.)

### When to Use Each
Guidance on choosing between theories

## Future: Repository Separation
Note about planned Bimodal extraction to independent repository
```

**README.md Bimodal Section Replacement**:

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

### 6. File Operations

**Action**: Replace `docs/research/theory-comparison.md` with `docs/research/bimodal-logic.md`

**Rationale**:
1. The new name `bimodal-logic.md` clearly indicates the document's primary focus
2. The title "A Bimodal Logic for Tense and Modality" aligns with academic convention
3. Bimodal-focused content with a comparison section serves both audiences
4. Prepares for future extraction of Bimodal to its own repository

**Links to Update**:
- README.md line 12 (theory comparison link) → update to bimodal-logic.md
- docs/README.md theory table → update link
- Any other cross-references in docs/

## Recommendations

### Implementation Plan

**Phase 1: Create bimodal-logic.md**
1. Create new `docs/research/bimodal-logic.md` with title "A Bimodal Logic for Tense and Modality"
2. Write comprehensive Bimodal presentation (operators, axioms, perpetuity principles)
3. Add links to `Theories/Bimodal/README.md` and `Theories/Bimodal/docs/` for implementation details
4. Include comparison section with Logos at end
5. Add "Future: Repository Separation" note

**Phase 2: README.md Updates**
1. Change title to "Logos: A Logic for Interpreted and Verified AI Reasoning"
2. Replace detailed Bimodal section with brief summary (8-10 lines)
3. Update link to point to new `bimodal-logic.md`

**Phase 3: Remove theory-comparison.md and Update References**
1. Delete `docs/research/theory-comparison.md`
2. Update `docs/README.md` theory table to link to `bimodal-logic.md`
3. Search for and update any other cross-references

**Phase 4: Verification**
1. Ensure no orphaned internal links
2. Verify README.md narrative focuses on Logos
3. Confirm bimodal-logic.md is comprehensive with good links to Theories/Bimodal/

### Risk Assessment

| Risk | Mitigation |
|------|------------|
| Losing README.md Bimodal detail | All content preserved in bimodal-logic.md |
| Breaking internal links | Systematic search and update of all theory-comparison.md references |
| Confusion during transition | Clear commit messages; atomic file replacement |

## References

- `/home/benjamin/Projects/ProofChecker/README.md` - Current main README
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex` - LaTeX reference with target title
- `/home/benjamin/Projects/ProofChecker/docs/research/theory-comparison.md` - To be replaced
- `/home/benjamin/Projects/ProofChecker/docs/research/bimodal-logic.md` - New document (to create)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/README.md` - Bimodal implementation README
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/docs/README.md` - Bimodal documentation hub

## Next Steps

1. Run `/plan 433` to create detailed implementation plan
2. Implement in phases to maintain documentation consistency
3. Verify all cross-references after changes
