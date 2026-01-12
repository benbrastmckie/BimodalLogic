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

### 3. Existing docs/research/theory-comparison.md Analysis

**Current State** (182 lines):
- Good overview structure (Bimodal vs Logos classification)
- Semantic primitives comparison
- Operator tables for both theories
- "When to Use Each" guidance section
- Theoretical background with references
- Navigation links

**Strengths**:
- Clear side-by-side comparison structure
- Appropriate level of technical detail
- Good "when to use" guidance

**Gaps**:
1. **Title**: "Theory Comparison" is generic; could be renamed for clarity
2. **Bimodal detail**: Less operator/axiom detail than README.md section
3. **Logos detail**: Marked as "Planned" with incomplete status
4. **Implementation status**: Could be more current

**Recommendation**: Expand theory-comparison.md to be the canonical Bimodal documentation in the main repository, incorporating the README.md Bimodal section content.

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

**Goal**: Single authoritative document for Bimodal theory comparison, replacing README.md duplication.

**Proposed Structure for Expanded theory-comparison.md**:

1. **Overview** (existing, keep)
2. **Bimodal Theory** (expanded from current)
   - Classification (existing)
   - Semantic primitives (existing)
   - Operators (incorporate README.md table)
   - Axiom schemas (incorporate README.md list)
   - Perpetuity principles (incorporate from README.md)
   - Implementation status (current)
3. **Logos Theory** (existing, update status)
4. **Comparison Tables** (new section)
   - Semantic grain comparison
   - Operator coverage
   - Expressivity boundaries
5. **When to Use Each** (existing, keep)
6. **Theoretical Background** (existing, keep)
7. **Future: Repository Separation** (new section)
   - Note about planned Bimodal extraction
   - Migration path

**README.md Bimodal Section Replacement**:

```markdown
## Bimodal Theory (TM Logic)

The Bimodal theory implements TM (Tense and Modality) logic as a complete,
self-contained intensional logic. Developed in parallel with Logos, Bimodal
serves as an excellent starting point for understanding modal-temporal
reasoning and as a comparison baseline demonstrating the boundaries of purely
intensional semantics.

Key characteristics:
- **Type**: Propositional intensional logic (zeroth-order)
- **Operators**: S5 modal (Box/Diamond) + linear temporal (Past/Future)
- **Status**: Complete (syntax, proof system, semantics, soundness proven)

For detailed Bimodal documentation, see [Theories/Bimodal/README.md](Theories/Bimodal/README.md).

For a comprehensive comparison of Bimodal and Logos theories, see
[Theory Comparison](docs/research/theory-comparison.md).
```

### 6. File Location Considerations

**Current**: `docs/research/theory-comparison.md`

**Alternatives Considered**:
1. `docs/research/bimodal-logos-comparison.md` - More specific but longer
2. `Theories/theory-comparison.md` - Closer to implementations but breaks docs structure
3. Keep current name - Adequate, already linked from README.md

**Recommendation**: Keep current location and name. The existing README.md link (line 12) already points to this document. Renaming would require updating multiple references.

## Recommendations

### Implementation Plan

**Phase 1: README.md Updates**
1. Change title to "Logos: A Logic for Interpreted and Verified AI Reasoning"
2. Replace detailed Bimodal section (lines 114-164) with brief summary (5-10 lines)
3. Ensure link to theory-comparison.md is prominent

**Phase 2: theory-comparison.md Expansion**
1. Add complete operator table from README.md
2. Add axiom schema list from README.md
3. Add perpetuity principles section from README.md
4. Update implementation status to current state
5. Add "Future: Repository Separation" note

**Phase 3: Verification**
1. Ensure no orphaned internal links
2. Verify README.md narrative flow without detailed Bimodal section
3. Confirm theory-comparison.md is comprehensive

### Risk Assessment

| Risk | Mitigation |
|------|------------|
| Losing README.md Bimodal detail | All content preserved in theory-comparison.md |
| Breaking internal links | Check all Bimodal section links move to new location |
| Confusion during transition | Clear commit messages; update all cross-references |

## References

- `/home/benjamin/Projects/ProofChecker/README.md` - Current main README
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/latex/LogosReference.tex` - LaTeX reference with target title
- `/home/benjamin/Projects/ProofChecker/docs/research/theory-comparison.md` - Existing comparison document
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/README.md` - Bimodal theory README
- `/home/benjamin/Projects/ProofChecker/Theories/Logos/docs/research/layer-extensions.md` - Logos layer documentation

## Next Steps

1. Run `/plan 433` to create detailed implementation plan
2. Implement in phases to maintain documentation consistency
3. Verify all cross-references after changes
