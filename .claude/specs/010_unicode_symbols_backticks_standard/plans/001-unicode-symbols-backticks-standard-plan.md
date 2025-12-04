# Unicode Symbol Backtick Standardization Implementation Plan

## Metadata
- **Date**: 2025-12-01
- **Feature**: Formal Unicode Symbol Backtick Standard
- **Scope**: Documentation standards, existing documentation updates, LEAN style guide revisions
- **Estimated Phases**: 5
- **Estimated Hours**: 8
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Complexity**: Low
- **Structure Level**: 0
- **Complexity Score**: 32.0
- **Research Reports**:
  - [Unicode Symbol Backtick Standardization Research Report](/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/010_unicode_symbols_backticks_standard/reports/001-unicode-symbols-backticks-standard.md)

## Overview

This plan implements a mandatory backtick standard for all formal Unicode symbols in Logos documentation. The research report identified 700+ instances of formal symbols (□, ◇, ⊢, ⊨, φ, ψ, →, ∧, ∨, ¬) used without backticks across 23 Markdown files, creating visual ambiguity and rendering inconsistency. This implementation will:

1. Establish formal symbol backtick requirements in documentation standards
2. Update LEAN style guide with code comment formatting standards
3. Migrate all existing documentation to use backticks consistently
4. Add reference to new standard in CLAUDE.md documentation index
5. Validate all changes and ensure consistency

**Goal**: Improve readability by enforcing backticks around all inline formal symbols, aligning with Rust, Python, and CommonMark technical documentation best practices.

## Research Summary

Based on comprehensive codebase analysis from the research report:

**Current State**:
- 700+ formal symbol occurrences across 23 Markdown files (README.md, CLAUDE.md, docs/)
- 85-95% of symbols lack backticks, causing visual ambiguity
- README.md: 23 axiom/theorem formulas without backticks
- CLAUDE.md: 8 perpetuity principles without backticks
- docs/TUTORIAL.md: 40+ formulas without backticks
- docs/ARCHITECTURE.md: 30+ formulas without backticks
- docs/EXAMPLES.md: 50+ formulas without backticks

**Gap Identified**: No existing standard for backtick usage around formal Unicode symbols in Markdown or LEAN code comments

**Readability Impact**:
- Without backticks: Formal symbols blend with prose, inconsistent font rendering
- With backticks: Clear visual separation, consistent monospace rendering, improved scannability

**Best Practices Alignment**:
- Rust documentation guidelines: All code symbols use backticks
- Python PEP 257: Code references in docstrings use monospace
- CommonMark Section 6.3: Code spans for technical terms
- GitHub Flavored Markdown: Encourages backticks for technical symbols

**Recommended Approach**: Establish mandatory backtick standard covering modal operators (`□`, `◇`), propositional operators (`→`, `∧`, `∨`, `¬`), meta-logical symbols (`⊢`, `⊨`), and propositional variables (`φ`, `ψ`, `χ`, `Γ`, `Δ`).

## Success Criteria

- [ ] Documentation standards file updated with formal symbol backtick requirements
- [ ] LEAN style guide updated with code comment formatting standards
- [ ] All 5 high-priority documentation files migrated (README.md, CLAUDE.md, TUTORIAL.md, ARCHITECTURE.md, EXAMPLES.md)
- [ ] CLAUDE.md documentation index references new backtick standard
- [ ] All migrated files pass validation (no unbackticked symbols in inline prose)
- [ ] Changes maintain markdown rendering correctness (no broken links/formatting)
- [ ] Project builds successfully after documentation changes (`lake build`)

## Technical Design

### Architecture Overview

This implementation involves **documentation-only changes** with no code modifications. The workflow follows a progressive update strategy:

1. **Standards Layer**: Establish formal requirements in `.claude/docs/reference/standards/documentation-standards.md`
2. **Style Guide Layer**: Add LEAN-specific guidance in `docs/development/LEAN_STYLE_GUIDE.md`
3. **Migration Layer**: Systematically update existing documentation files
4. **Index Layer**: Update CLAUDE.md to reference new standards
5. **Validation Layer**: Verify consistency across all updated files

### Standards Integration

**Alignment with Existing Standards**:
- **Documentation Standards** (`.claude/docs/reference/standards/documentation-standards.md`): Unicode character standards section (lines 340-354) already documents allowed Unicode ranges; new backtick standard extends this with formatting requirements
- **LEAN Style Guide** (`docs/development/LEAN_STYLE_GUIDE.md`): Variable naming section (lines 6-24) uses Greek letters; new standard adds backtick requirements for these symbols in comments
- **Code Standards** (`.claude/docs/reference/standards/code-standards.md`): UTF-8 encoding required (lines 10-13); backtick standard ensures consistent rendering of UTF-8 symbols

**No Divergence Detected**: This plan aligns with and extends existing standards without conflicts.

### File Update Strategy

**Phase Approach**:
1. **Phase 1-2**: Standards establishment (non-breaking, additive only)
2. **Phase 3**: High-visibility files (README.md, CLAUDE.md) for immediate impact
3. **Phase 4**: User and developer documentation for comprehensive coverage
4. **Phase 5**: Validation and documentation index update

**Search-and-Replace Patterns**:
```bash
# Axiom schemas: MT (□φ → φ) → MT (`□φ → φ`)
# Perpetuity principles: P1: □φ → always φ → P1: `□φ → always φ`
# Derivability relations: Γ ⊢ φ → `Γ ⊢ φ`
# Variable references: where φ is → where `φ` is
```

**Edge Cases**:
- Symbols already in code blocks (```lean) do NOT need additional backticks
- Symbols in URLs or raw HTML are excluded
- Symbols in file paths are excluded

### Testing Strategy

**Validation Approach**:
1. **Visual Inspection**: Sample 10 instances per file to verify backtick rendering
2. **Markdown Linting**: Ensure no broken links or malformed markdown after changes
3. **Build Verification**: Run `lake build` to confirm no inadvertent LEAN file changes
4. **Grep Validation**: Search for common unbackticked patterns to catch misses

**No Test Code Required**: Documentation-only changes require manual review, not automated tests.

## Implementation Phases

### Phase 1: Update Documentation Standards [COMPLETE]
dependencies: []

**Objective**: Establish formal symbol backtick requirement in `.claude/docs/reference/standards/documentation-standards.md`

**Complexity**: Low

**Tasks**:
- [x] Read documentation standards file (file: `.claude/docs/reference/standards/documentation-standards.md`)
- [x] Locate insertion point after line 354 (Unicode character standards section)
- [x] Add "Formal Symbol Backtick Standard" section with scope, rationale, examples, special cases
- [x] Include correct usage examples: `` The axiom MT states that `□φ → φ` ``
- [x] Include incorrect usage examples (without backticks) for comparison
- [x] Document special cases: code blocks don't need backticks, code comments should use backticks
- [x] Add enforcement section noting pre-commit hook potential (informational only)

**Testing**:
```bash
# Verify section added correctly
grep -A 20 "Formal Symbol Backtick Standard" /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/docs/reference/standards/documentation-standards.md

# Verify examples are properly formatted
grep '`□φ → φ`' /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/docs/reference/standards/documentation-standards.md
```

**Expected Duration**: 1 hour

### Phase 2: Update LEAN Style Guide [COMPLETE]
dependencies: [1]

**Objective**: Add code comment formatting standard to `docs/development/LEAN_STYLE_GUIDE.md`

**Complexity**: Low

**Tasks**:
- [x] Read LEAN style guide file (file: `docs/development/LEAN_STYLE_GUIDE.md`)
- [x] Locate insertion point after line 157 (Spacing section)
- [x] Add "Code Comments with Formal Symbols" section
- [x] Provide GOOD examples: `-- MT: ``□φ → φ`` (reflexivity)`
- [x] Provide AVOID examples (without backticks) for comparison
- [x] Document rationale: improves readability in editor tooltips and documentation generators
- [x] Add exception note for multi-line docstrings (/-! ... -/) where backticks are optional but encouraged

**Testing**:
```bash
# Verify section added
grep -A 15 "Code Comments with Formal Symbols" /home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/LEAN_STYLE_GUIDE.md

# Check for example code blocks
grep -A 3 '-- MT:' /home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/LEAN_STYLE_GUIDE.md | grep '`□φ → φ`'
```

**Expected Duration**: 1 hour

### Phase 3: Migrate High-Visibility Documentation [COMPLETE]
dependencies: [1, 2]

**Objective**: Update README.md and CLAUDE.md with backticks around formal symbols

**Complexity**: Medium

**Tasks**:
- [x] Migrate README.md (file: `README.md`)
  - [x] Update lines 23-25: Axiom schemas (MT, M4, MB, T4, TA, TL, MF, TF)
  - [x] Update lines 28-33: Perpetuity principles P1-P6
  - [x] Update lines 61-75: Code examples and inline formula references
  - [x] Verify line 18 already has backticks (`` `□` (necessity), `◇` (possibility) ``)
- [x] Migrate CLAUDE.md (file: `CLAUDE.md`)
  - [x] Update lines 170-175: Perpetuity principles P1-P6 in Theorems Package section
  - [x] Update lines 163-165: Metalogic theorems (`Γ ⊢ φ → Γ ⊨ φ`)
  - [x] Review entire file for any other unbackticked formal symbols
- [x] Visual inspection: Verify markdown renders correctly in preview

**Testing**:
```bash
# Verify backticks added to axiom schemas in README
grep -n '`MT.*`\|`M4.*`\|`MB.*`' /home/benjamin/Documents/Philosophy/Projects/Logos/README.md

# Verify perpetuity principles have backticks in both files
grep -n 'P[1-6]:.*`□.*`' /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
grep -n 'P[1-6]:.*`□.*`' /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md

# Verify metalogic theorems updated
grep -n '`Γ ⊢ φ.*Γ ⊨ φ`' /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md

# Check for remaining unbackticked symbols (should return no results)
grep -E '^[^`]*[MTPF][0-9]?:[^`]*(□|◇|φ|ψ)[^`]*$' /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
grep -E '^[^`]*P[1-6]:[^`]*(□|◇|φ)[^`]*$' /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
```

**Expected Duration**: 2 hours

### Phase 4: Migrate User and Developer Documentation [COMPLETE]
dependencies: [3]

**Objective**: Update TUTORIAL.md, ARCHITECTURE.md, EXAMPLES.md with backticks around formal symbols

**Complexity**: Medium

**Tasks**:
- [x] Migrate docs/TUTORIAL.md (file: `docs/TUTORIAL.md`)
  - [x] Update lines 82-112: Formula construction examples with inline comments
  - [x] Update lines 169-179: Axiom examples (MT, M4, M5, etc.)
  - [x] Update lines 335-339: Perpetuity principles
  - [x] Verify code blocks (```lean) are NOT modified (symbols already in code)
- [x] Migrate docs/ARCHITECTURE.md (file: `docs/ARCHITECTURE.md`)
  - [x] Update lines 150-166: Axiom definitions in comments
  - [x] Update lines 189-204: Perpetuity principles section
  - [x] Update lines 567-574: Soundness proof examples
  - [x] Review entire file for inline formula references
- [x] Migrate docs/EXAMPLES.md (file: `docs/EXAMPLES.md`)
  - [x] Systematically review all sections for inline formula references
  - [x] Update modal logic examples (S5 axioms)
  - [x] Update temporal logic examples
  - [x] Update bimodal examples
- [x] Spot check: Sample 10 instances per file to verify backtick rendering

**Testing**:
```bash
# Verify TUTORIAL.md updated
grep -c '`□\|`◇\|`⊢\|`⊨\|`φ\|`ψ' /home/benjamin/Documents/Philosophy/Projects/Logos/docs/TUTORIAL.md

# Verify ARCHITECTURE.md updated
grep -c '`□\|`◇\|`⊢\|`⊨\|`φ' /home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md

# Verify EXAMPLES.md updated
grep -c '`□\|`◇\|`φ' /home/benjamin/Documents/Philosophy/Projects/Logos/docs/EXAMPLES.md

# Visual inspection: Check markdown rendering
# (Manual review in VS Code or GitHub preview)
```

**Expected Duration**: 3 hours

### Phase 5: Update CLAUDE.md Index and Validate [COMPLETE]
dependencies: [4]

**Objective**: Add backtick standard reference to CLAUDE.md documentation index and validate all changes

**Complexity**: Low

**Tasks**:
- [x] Update CLAUDE.md documentation index (file: `CLAUDE.md`)
  - [x] Locate Section 4 (Documentation Index), after line 93
  - [x] Add "Symbol Formatting Standards" subsection
  - [x] Reference documentation standards file with anchor link
  - [x] Reference LEAN style guide with anchor link
- [x] Validate all changes across project
  - [x] Run grep validation: check for common unbackticked patterns
  - [x] Run markdown linter (if available) on modified files
  - [x] Visual inspection: Review markdown rendering in VS Code preview
  - [x] Build verification: Run `lake build` to ensure no inadvertent code changes
- [x] Update research report implementation status (file: `.claude/specs/010_unicode_symbols_backticks_standard/reports/001-unicode-symbols-backticks-standard.md`)
  - [x] Add "Implementation Status" section if not present
  - [x] Link to this plan file
  - [x] Update status to "Implementation Complete"

**Testing**:
```bash
# Verify CLAUDE.md index updated
grep -A 3 "Symbol Formatting Standards" /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md

# Comprehensive validation: Check all high-priority files
for FILE in README.md CLAUDE.md docs/TUTORIAL.md docs/ARCHITECTURE.md docs/EXAMPLES.md; do
  echo "Checking $FILE..."
  # Count backticked formal symbols (should be high)
  grep -c '`□\|`◇\|`⊢\|`⊨\|`φ\|`ψ' /home/benjamin/Documents/Philosophy/Projects/Logos/$FILE || echo "No backticked symbols found"
done

# Build verification (ensure no code changes)
cd /home/benjamin/Documents/Philosophy/Projects/Logos && lake build

# Expected result: Build succeeds with no errors (documentation changes are non-breaking)
```

**Expected Duration**: 1 hour

## Testing Strategy

### Overall Approach

This implementation involves **documentation-only changes** with no code modifications. Testing focuses on:

1. **Visual Validation**: Manual review of markdown rendering in VS Code and GitHub preview
2. **Pattern Detection**: Grep-based checks for unbackticked symbols after migration
3. **Build Verification**: Ensure `lake build` succeeds (no inadvertent code changes)
4. **Consistency Checks**: Verify all instances of same symbol use consistent backtick format

### File-by-File Testing

**README.md and CLAUDE.md**:
- Visual inspection: Check axiom schemas, perpetuity principles, metalogic theorems
- Grep validation: Ensure no unbackticked symbols in inline prose (exclude code blocks)

**TUTORIAL.md, ARCHITECTURE.md, EXAMPLES.md**:
- Spot check: Sample 10 instances per file
- Pattern detection: Search for common unbackticked patterns (`MT (□`, `P1: □`, `where φ`)

**Documentation Standards and LEAN Style Guide**:
- Verify examples are properly formatted with correct/incorrect usage comparisons
- Check special cases documented (code blocks, comments, multi-line docstrings)

### No Pre-commit Hook in Initial Implementation

Research report recommended a pre-commit hook for backtick linting. This plan **does not implement the hook** because:
- Heuristic checks have high false positive rate (symbols in URLs, code blocks)
- Manual review is more reliable for initial migration
- Hook can be added in future enhancement if needed

## Documentation Requirements

### Files to Update

**Standards Documentation**:
- `.claude/docs/reference/standards/documentation-standards.md`: Add formal symbol backtick standard section
- `docs/development/LEAN_STYLE_GUIDE.md`: Add code comment formatting standard

**Project Documentation**:
- `README.md`: Migrate 23 formulas to use backticks
- `CLAUDE.md`: Migrate 8 formulas and update documentation index
- `docs/TUTORIAL.md`: Migrate 40+ formulas
- `docs/ARCHITECTURE.md`: Migrate 30+ formulas
- `docs/EXAMPLES.md`: Migrate 50+ formulas

**Research Report**:
- `.claude/specs/010_unicode_symbols_backticks_standard/reports/001-unicode-symbols-backticks-standard.md`: Add implementation status section linking to this plan

### No New Documentation Creation

This plan updates existing documentation only. No new README files, guides, or references are created beyond the plan itself.

## Dependencies

### External Dependencies

**None**: This implementation is self-contained within the Logos repository.

### Internal Prerequisites

**Required Knowledge**:
- Markdown syntax and rendering behavior
- Logos formal symbol conventions (modal, temporal, meta-logical)
- Location of project documentation standards files

**Tool Requirements**:
- Text editor with markdown preview (VS Code recommended)
- `grep` for pattern validation
- `lake` for build verification

### No Code Changes

This plan involves **documentation-only changes**. No LEAN code, build configuration, or CI/CD pipeline modifications are required.

## Risk Assessment

### Low Risk Implementation

**Why Low Risk**:
1. Documentation-only changes (no code logic affected)
2. Non-breaking: Backticks only affect rendering, not semantics
3. Reversible: Changes can be reverted if issues found
4. Incremental: Phased approach allows validation at each step

**Potential Issues**:
1. **False positives in grep validation**: Symbols in URLs or code blocks may trigger warnings
   - Mitigation: Manual review of grep results, exclude code blocks with context filtering
2. **Markdown rendering edge cases**: Backticks inside inline code or links could break rendering
   - Mitigation: Visual inspection in VS Code preview before committing
3. **Inconsistent application**: Some symbols missed during migration
   - Mitigation: Comprehensive grep validation in Phase 5

## Rollback Plan

If issues are discovered after implementation:

1. **Immediate Rollback**: Use git to revert commits (documentation changes are tracked)
2. **Partial Rollback**: Revert specific files if rendering issues found
3. **Standards Rollback**: Remove backtick standard sections from standards files if consensus changes

**Git Workflow**:
```bash
# Revert all documentation changes
git revert <commit-sha>

# Revert specific file
git checkout HEAD~1 -- README.md
```

## Future Enhancements

**Not Included in This Plan**:

1. **Pre-commit Hook**: Automated linting for unbackticked symbols (research report recommendation 4)
   - Defer to future implementation due to false positive concerns
2. **Glossary Updates**: If logical operators glossary exists, add backtick examples
   - Out of scope: Glossary creation was handled in spec 009
3. **Archive Directory Migration**: Migrate `.claude/specs/` historical reports
   - Low priority: Archive documentation less critical for current development

**These enhancements can be addressed in separate specifications if desired.**
