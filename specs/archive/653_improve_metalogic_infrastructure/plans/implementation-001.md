# Implementation Plan: Task #653

- **Task**: 653 - improve_metalogic_infrastructure
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/653_improve_metalogic_infrastructure/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean
- **Lean Intent**: false

## Overview

This task addresses the documentation-implementation gap identified in the metalogic infrastructure. The research revealed that SemanticCanonicalFrame exists only in deprecated Boneyard code, while the active infrastructure uses the IndexedMCSFamily approach. The primary work is updating LaTeX documentation to reflect the current Lean implementation, creating architectural documentation, and adding appropriate deprecation notices.

### Research Integration

Key findings from research-001.md:
- SemanticCanonicalFrame is in Boneyard only (deprecated) - no renaming needed in active code
- Active infrastructure uses `IndexedMCSFamily D` with universal parametric canonical model
- Infinite contexts handled trivially: `Context = List Formula` (always finite by definition)
- LaTeX documentation (04-Metalogic.tex) references deprecated Metalogic_v2 architecture
- True compactness for infinite sets would require major refactoring with low benefit

## Goals & Non-Goals

**Goals**:
- Align LaTeX documentation with current IndexedMCSFamily-based Lean implementation
- Document the current metalogic architecture in a README for maintainability
- Add clear deprecation notices to Boneyard code to prevent accidental use
- Remove or resolve TODO comments in LaTeX that reference deprecated approaches
- Provide clear explanation of the finite context limitation and compactness triviality

**Non-Goals**:
- Implementing true compactness for infinite sets (major refactoring, low benefit)
- Migrating from List-based to Set-based contexts
- Modifying active Lean implementation in Metalogic/
- Renaming SemanticCanonicalFrame (only exists in deprecated code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| LaTeX compilation errors after changes | Medium | Low | Test LaTeX compilation after each modification |
| Documentation diverges from code again | Medium | Medium | Add comments linking documentation to specific Lean files |
| Boneyard code breaks in future | Low | Medium | Accept as standard for deprecated code; document in README |

## Implementation Phases

### Phase 1: Update LaTeX Documentation [COMPLETED]

**Goal**: Align 04-Metalogic.tex with current IndexedMCSFamily implementation

**Tasks**:
- [ ] Update lines 141-151: Replace SemanticCanonicalFrame definition with Universal Canonical Model definition using IndexedMCSFamily
- [ ] Update line 157-159: Change `semantic_truth_lemma_v2` footnote to reference `truth_lemma` in UniversalCanonicalModel.lean
- [ ] Update lines 169-170: Make Representation Theorem reference more specific, pointing to UniversalCanonicalModel.lean
- [ ] Update lines 252-253: Replace TODO comment with proper "Note on Infinite Contexts" subsection explaining list-based context limitation and trivial compactness
- [ ] Remove or resolve any remaining TODO comments that reference deprecated SemanticCanonicalFrame approach

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` - Primary documentation updates

**Verification**:
- LaTeX compiles without errors
- No references to SemanticCanonicalFrame, SemanticWorldState, or semantic_truth_lemma_v2 remain in active documentation context
- New documentation accurately describes IndexedMCSFamily approach

---

### Phase 2: Create Architecture Documentation [COMPLETED]

**Goal**: Document current metalogic architecture for maintainability

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/README.md` with:
  - Overview of IndexedMCSFamily approach
  - Explanation of why T-axiom is not valid in TM (irreflexive operators)
  - Description of temporal coherence conditions (forward_G, backward_H, forward_H, backward_G)
  - Component listing with file purposes
  - Duration parametricity explanation
  - Relation to Boneyard/deprecated code
- [ ] Verify README accurately reflects current implementation by cross-referencing with Lean files

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md` (new file)

**Verification**:
- README is comprehensive and accurate
- Key architectural decisions are documented
- References to actual Lean files are correct

---

### Phase 3: Deprecation Notices and Cleanup [COMPLETED]

**Goal**: Add clear deprecation notices and clean up resolved issues

**Tasks**:
- [ ] Add deprecation header to `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean`:
  ```lean
  /-!
  # DEPRECATED: Semantic Canonical Model (Metalogic_v2)

  **Status**: This file is in the Boneyard and should not be used for active development.
  **Deprecated**: 2026-01-19
  **Replacement**: Use `IndexedMCSFamily` approach in `Theories/Bimodal/Metalogic/`

  See `Boneyard/README.md` for deprecation rationale.
  -/
  ```
- [ ] Verify Boneyard/README.md adequately explains deprecation rationale
- [ ] Check that Compactness.lean in Boneyard has appropriate comment about triviality

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean` - Add deprecation header
- `Theories/Bimodal/Boneyard/Metalogic_v2/Applications/Compactness.lean` - Verify triviality comment

**Verification**:
- Deprecation notices are clear and visible
- References point to correct replacement locations
- No ambiguity about which code to use

---

### Phase 4: Final Verification [COMPLETED]

**Goal**: Ensure all changes are consistent and complete

**Tasks**:
- [ ] Run `latexmk` or equivalent to verify LaTeX compilation
- [ ] Verify no broken cross-references in documentation
- [ ] Confirm TODO items from original source (lines 142, 253) are resolved
- [ ] Review changes for consistency with research findings

**Timing**: 15 minutes

**Verification**:
- LaTeX compiles successfully
- All original TODO items addressed
- Documentation accurately reflects implementation

## Testing & Validation

- [ ] LaTeX compilation succeeds without errors or warnings about missing references
- [ ] Grep for `SemanticCanonicalFrame` in documentation returns only historical/deprecation contexts
- [ ] Grep for `semantic_truth_lemma_v2` in documentation returns no results
- [ ] README.md created and references valid file paths
- [ ] Boneyard deprecation notices present in relevant files

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `Theories/Bimodal/latex/subfiles/04-Metalogic.tex` (modified)
- `Theories/Bimodal/Metalogic/README.md` (new)
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/SemanticCanonicalModel.lean` (modified - deprecation header)
- `summaries/implementation-summary-YYYYMMDD.md` (upon completion)

## Rollback/Contingency

All changes are documentation-only and do not affect Lean compilation:
- LaTeX changes can be reverted via git
- README.md is additive and can be deleted
- Deprecation headers are comments only and don't affect code behavior

If LaTeX fails to compile after modifications:
1. Check for syntax errors in new LaTeX content
2. Verify itemize/enumerate environments are properly closed
3. Restore from git if necessary and make incremental changes
