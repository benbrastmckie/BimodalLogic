# Unicode Triangle Operators Implementation Plan

## Metadata
- **Date**: 2025-12-01
- **Feature**: Replace 'always' and 'sometimes' temporal operators with Unicode triangle characters
- **Scope**: Add Unicode notation (△ for always, ▽ for sometimes) while maintaining backward compatibility
- **Estimated Phases**: 5
- **Estimated Hours**: 8
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Structure Level**: 0
- **Complexity Score**: 62.0
- **Complexity**: Medium
- **Research Reports**:
  - [Unicode Triangle Operators Research](../reports/001-unicode-triangle-operators.md)

## Overview

This plan implements Unicode triangle notation (△ for `always`, ▽ for `sometimes`) as an alternative syntax for temporal operators in the Logos bimodal logic system. The implementation adds prefix notation declarations using LEAN 4's notation system while maintaining full backward compatibility with existing function-based syntax. The plan addresses a critical semantic discrepancy between glossary documentation and actual implementation before proceeding with notation changes.

**Key Goals**:
1. Resolve semantic discrepancy between glossary and implementation
2. Add Unicode triangle prefix notation (△, ▽) to LEAN 4 codebase
3. Update all documentation to reflect dual notation
4. Maintain 100% backward compatibility with existing code
5. Follow established Unicode backtick standards for documentation

## Research Summary

Research analysis reveals:

**Current State** (from research report):
- `always` defined as alias to `future` in Formula.lean:98
- `sometimes` defined as dual using negation: `φ.neg.always.neg`
- No existing notation declarations for these operators
- Current access via dot notation: `φ.always`, `φ.sometimes`

**Critical Discrepancy Identified**:
- **Glossary definition**: `always φ := Past φ ∧ φ ∧ Future φ` (three-time quantifier)
- **Actual implementation**: `always φ := φ.future` (future only)
- **Impact**: Implementation is "henceforth" not "eternal truth"
- **Resolution approach**: Update glossary to match implementation (documentation fix, non-breaking)

**Unicode Symbol Selection**:
- **△** (U+25B3, WHITE UP-POINTING TRIANGLE) for `always` — visual universal quantification
- **▽** (U+25BD, WHITE DOWN-POINTING TRIANGLE) for `sometimes` — visual existential quantification
- **Rationale**: Triangles provide clear visual duality mirroring universal/existential logic operators

**LEAN 4 Notation Patterns** (from existing codebase):
- Validity.lean:52,68 shows successful Unicode notation usage (⊨, ⊢)
- Derivation.lean:128,133 demonstrates prefix notation pattern
- Precedence level 80 recommended for temporal operators (matches modal operators)

**Recommended Approach**:
1. Prefix notation pattern: `prefix:80 "△" => Formula.always`
2. Maintain existing function definitions unchanged
3. Phased documentation updates (core → tutorials → developer docs)
4. Comprehensive testing for notation parsing and equivalence

## Success Criteria

- [ ] Semantic discrepancy resolved (glossary matches implementation)
- [ ] Triangle notation (△, ▽) successfully parses in LEAN 4
- [ ] Notation equivalence verified: `△p = p.always` and `▽p = p.sometimes`
- [ ] All 28 LEAN source files remain compatible
- [ ] Core documentation updated (glossary, ARCHITECTURE.md, README.md, CLAUDE.md)
- [ ] All tutorial/example documentation updated with dual notation
- [ ] UTF-8 encoding verified for all modified files
- [ ] Zero lint warnings (`lake lint`)
- [ ] All tests pass (`lake test`)
- [ ] Build succeeds (`lake build`)

## Technical Design

### Architecture Overview

**Non-Breaking Additive Design**:
- Add notation declarations as syntactic sugar over existing functions
- No changes to underlying Formula inductive type
- No changes to proof system or semantics
- Maintain dot notation (`φ.always`) alongside new prefix notation (`△φ`)

### Component Changes

#### 1. LEAN 4 Notation System Integration

**File**: `Logos/Syntax/Formula.lean` (after line 106)

Add prefix notation declarations:
```lean
/-- Notation for temporal 'always' operator using upward triangle.
    Represents universal temporal quantification: φ holds at all future times.
-/
prefix:80 "△" => Formula.always

/-- Notation for temporal 'sometimes' operator using downward triangle.
    Represents existential temporal quantification: φ holds at some future time.
    Defined as dual: ¬△¬φ
-/
prefix:80 "▽" => Formula.sometimes
```

**Precedence**: Level 80 aligns with modal operators (□, ◇) for consistency
**Pattern**: Prefix notation matches modal logic convention (operators precede formulas)

#### 2. Documentation Semantic Fix

**File**: `docs/glossary/logical-operators.md` (lines 157-176)

**Current Incorrect Definition**:
```markdown
**Formal Definition**: `always φ := Past φ ∧ φ ∧ Future φ`
```

**Corrected Definition**:
```markdown
**Formal Definition**: `always φ := Future φ` (henceforth operator)
**Alternative Notation**: `△φ` (U+25B3 WHITE UP-POINTING TRIANGLE)
```

**Rationale**: Match actual implementation in Formula.lean:98 rather than introduce breaking semantic change

#### 3. Unicode Backtick Standard Compliance

All documentation updates must follow established backtick standard:
- Correct: "The `△` operator denotes..."
- Correct: "Perpetuity P1: `□φ → △φ`"
- Incorrect: "The △ operator..." (missing backticks)

**Reference**: `.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard`

### Testing Strategy

#### Test Categories
1. **Notation Parsing**: Verify LEAN 4 accepts △ and ▽ syntax
2. **Equivalence**: Verify `△p = p.always` using `rfl`
3. **UTF-8 Encoding**: Verify symbols preserve encoding after edits
4. **Backward Compatibility**: Verify existing dot notation still works
5. **Integration**: Verify notation works in proof contexts

#### Test File Updates
- `LogosTest/Syntax/FormulaTest.lean`: Add notation tests after line 97
- Keep existing tests (lines 85-97) to verify backward compatibility
- Add new examples demonstrating triangle notation

### Migration Path

**Phase 1**: Both notations equally valid
**Phase 2**: Documentation shows both: "always/△" and "sometimes/▽"
**Phase 3**: Community adoption determines primary usage
**Future**: Optional deprecation if symbols become overwhelmingly preferred

## Implementation Phases

### Phase 1: Semantic Resolution [COMPLETE]
dependencies: []

**Objective**: Resolve critical discrepancy between glossary definition and actual implementation before adding notation

**Complexity**: Low

**Tasks**:
- [x] Update `docs/glossary/logical-operators.md` line 160 to match implementation (file: docs/glossary/logical-operators.md)
  - Change from: `always φ := Past φ ∧ φ ∧ Future φ`
  - Change to: `always φ := Future φ` (henceforth operator)
  - Add clarifying note about "henceforth" vs "eternal truth" semantics
- [x] Update `docs/glossary/logical-operators.md` line 169 to clarify `sometimes` definition (file: docs/glossary/logical-operators.md)
  - Change from: `sometimes φ := past φ ∨ φ ∨ future φ`
  - Change to: `sometimes φ := ¬always¬φ` (dual of always)
- [x] Update `docs/ARCHITECTURE.md` lines 48-49 to match implementation (file: docs/ARCHITECTURE.md)
  - Ensure definitions align with Formula.lean:94-106
  - Remove three-time quantifier references
- [x] Add explanatory comment in `Logos/Syntax/Formula.lean` line 94 (file: Logos/Syntax/Formula.lean)
  - Clarify that `always` is "henceforth" (future only) not "eternal truth" (past+present+future)
  - Reference glossary for formal definition
- [x] Verify UTF-8 encoding preserved: `file -b --mime-encoding docs/glossary/logical-operators.md`

**Testing**:
```bash
# Verify glossary updated correctly
grep -q "always φ := Future φ" /home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md

# Verify ARCHITECTURE.md consistency
grep -q "def always (φ : Formula) : Formula := φ.future" /home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md

# Verify UTF-8 encoding
file -b --mime-encoding /home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md | grep -q "utf-8"
```

**Expected Duration**: 1.5 hours

---

### Phase 2: Add Triangle Notation to LEAN 4 [COMPLETE]
dependencies: [1]

**Objective**: Implement Unicode triangle prefix notation in Formula.lean with comprehensive documentation

**Complexity**: Medium

**Tasks**:
- [x] Add `△` prefix notation declaration after line 106 in Formula.lean (file: Logos/Syntax/Formula.lean)
  - Use pattern: `prefix:80 "△" => Formula.always`
  - Include docstring explaining △ symbol (U+25B3) and semantics
  - Set precedence to 80 (matches modal operators)
- [x] Add `▽` prefix notation declaration in Formula.lean (file: Logos/Syntax/Formula.lean)
  - Use pattern: `prefix:80 "▽" => Formula.sometimes`
  - Include docstring explaining ▽ symbol (U+25BD) and duality with △
  - Set precedence to 80 for consistency
- [x] Verify notation doesn't conflict with existing operators
  - Check no existing prefix/infix/postfix notation uses △ or ▽
  - Run `lake build` to catch syntax errors
- [x] Update module docstring in Formula.lean to mention new notation
- [x] Verify UTF-8 encoding: `file -b --mime-encoding Logos/Syntax/Formula.lean`

**Testing**:
```bash
# Build test - verify notation parses
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake build Logos.Syntax.Formula

# Verify zero lint warnings
lake lint Logos/Syntax/Formula.lean

# Verify UTF-8 encoding preserved
file -b --mime-encoding Logos/Syntax/Formula.lean | grep -q "utf-8"
```

**Expected Duration**: 2 hours

---

### Phase 3: Add Notation Tests [COMPLETE]
dependencies: [2]

**Objective**: Implement comprehensive test suite for triangle notation parsing and equivalence

**Complexity**: Medium

**Tasks**:
- [x] Add notation parsing tests in FormulaTest.lean after line 97 (file: LogosTest/Syntax/FormulaTest.lean)
  - Test: `example (p : Formula) : △p = p.always := rfl`
  - Test: `example (p : Formula) : ▽p = p.sometimes := rfl`
- [x] Add notation composition tests (file: LogosTest/Syntax/FormulaTest.lean)
  - Test: `example (p : Formula) : △(p.imp q) = (p.imp q).always := rfl`
  - Test: `example (p : Formula) : ▽p.neg = p.neg.sometimes := rfl`
- [x] Add backward compatibility tests (file: LogosTest/Syntax/FormulaTest.lean)
  - Verify existing tests on lines 85-97 still pass
  - Verify dot notation unchanged: `p.always`, `p.sometimes`
- [x] Add integration test with modal operators (file: LogosTest/Syntax/FormulaTest.lean)
  - Test: `example (p : Formula) : △(p.box) = p.box.always := rfl`
  - Test combination of temporal and modal notation
- [x] Document test structure in file header comment

**Testing**:
```bash
# Run syntax tests specifically
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake test LogosTest.Syntax.FormulaTest

# Run full test suite to verify no regressions
lake test

# Verify zero lint warnings
lake lint LogosTest/Syntax/FormulaTest.lean
```

**Expected Duration**: 2 hours

---

### Phase 4: Update Core Documentation [COMPLETE]
dependencies: [3]

**Objective**: Update primary documentation files with triangle notation following backtick standards

**Complexity**: Medium

**Tasks**:
- [x] Update glossary with triangle symbols (file: docs/glossary/logical-operators.md)
  - Add `△` to `always` entry (line ~157) with backticks: "`△`"
  - Add `▽` to `sometimes` entry (line ~167) with backticks: "`▽`"
  - Include Unicode codepoints (U+25B3, U+25BD) in glossary
  - Add examples: "`△p`" means "henceforth p"
- [x] Update ARCHITECTURE.md with triangle notation (file: docs/ARCHITECTURE.md)
  - Show both syntaxes: `always φ` and `△φ`
  - Update formal language grammar if present
  - Add notation section if needed
- [x] Update README.md perpetuity principles (file: README.md)
  - Update P1-P6 to show both notations: "P1: `□φ → △φ`"
  - Ensure all Unicode symbols use backticks
  - Verify rendering in markdown preview
- [x] Update CLAUDE.md quick reference (file: CLAUDE.md)
  - Add triangle operators to operator summary
  - Include in syntax examples
  - Reference glossary for details
- [x] Verify UTF-8 encoding for all modified files
  - Run: `file -b --mime-encoding docs/*.md`

**Testing**:
```bash
# Verify backtick compliance (all symbols in backticks)
grep -E '△|▽' /home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md | grep -v '`△`\|`▽`' && echo "ERROR: Symbols without backticks found" || echo "✓ Backtick standard verified"

# Verify UTF-8 encoding for all docs
cd /home/benjamin/Documents/Philosophy/Projects/Logos
for file in docs/glossary/logical-operators.md docs/ARCHITECTURE.md README.md CLAUDE.md; do
  encoding=$(file -b --mime-encoding "$file")
  [ "$encoding" = "utf-8" ] && echo "✓ $file: utf-8" || echo "✗ $file: $encoding"
done

# Verify Unicode codepoints documented
grep -q "U+25B3" /home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md
grep -q "U+25BD" /home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md
```

**Expected Duration**: 1.5 hours

---

### Phase 5: Update Tutorial and Developer Documentation [COMPLETE]
dependencies: [4]

**Objective**: Complete documentation update across tutorial, examples, and developer guides

**Complexity**: Low

**Tasks**:
- [x] Update TUTORIAL.md with triangle notation (file: docs/TUTORIAL.md)
  - Add section introducing `△` and `▽` notation
  - Show examples: "`△p`", "`▽(p.imp q)`"
  - Explain when to use symbols vs. text
  - Follow backtick standard for all symbols
- [x] Update EXAMPLES.md with triangle notation examples (file: docs/EXAMPLES.md)
  - Add temporal logic examples using `△` and `▽`
  - Update perpetuity principle examples
  - Show mixed modal-temporal notation: "`□△p`"
- [x] Update LEAN_STYLE_GUIDE.md (file: docs/development/LEAN_STYLE_GUIDE.md)
  - Add style guidelines for triangle operator usage
  - Recommend prefix notation: "`△p`" not "`p△`"
  - Clarify when to use symbols vs. function names
- [x] Update TESTING_STANDARDS.md if needed (file: docs/development/TESTING_STANDARDS.md)
  - Add examples using triangle notation in tests
  - Show notation equivalence test pattern
- [x] Run final validation checks
  - Verify build: `lake build`
  - Verify tests: `lake test`
  - Verify lint: `lake lint`
  - Verify UTF-8 encoding across all files

**Testing**:
```bash
# Final build verification
cd /home/benjamin/Documents/Philosophy/Projects/Logos
lake clean
lake build

# Final test suite verification
lake test

# Final lint verification (zero warnings required)
lake lint

# Verify UTF-8 encoding for all modified tutorial/dev docs
for file in docs/TUTORIAL.md docs/EXAMPLES.md docs/development/LEAN_STYLE_GUIDE.md docs/development/TESTING_STANDARDS.md; do
  encoding=$(file -b --mime-encoding "$file")
  [ "$encoding" = "utf-8" ] && echo "✓ $file: utf-8" || echo "✗ $file: $encoding"
done

# Verify backtick compliance across all documentation
find docs -name "*.md" -exec grep -l '△\|▽' {} \; | while read file; do
  if grep -E '△|▽' "$file" | grep -v '`△`\|`▽`' >/dev/null; then
    echo "✗ $file: Symbols without backticks"
  else
    echo "✓ $file: Backtick standard verified"
  fi
done
```

**Expected Duration**: 1 hour

---

## Testing Strategy

### Overall Test Approach

**Test-Driven Development (TDD)**:
1. Write failing notation tests first (Phase 3)
2. Implement notation (Phase 2)
3. Verify tests pass
4. Refactor documentation (Phases 4-5)

**Coverage Requirements**:
- Syntax module: ≥85% (per CLAUDE.md standards)
- Test new notation parsing paths
- Maintain existing test coverage for dot notation

**Test Types**:
1. **Unit Tests**: Notation parsing and equivalence (FormulaTest.lean)
2. **Integration Tests**: Mixed modal-temporal notation usage
3. **Documentation Tests**: UTF-8 encoding verification
4. **Regression Tests**: Existing dot notation still works

**Validation Commands**:
```bash
# Primary test suite
lake test

# Module-specific test
lake test LogosTest.Syntax.FormulaTest

# Lint verification (zero warnings)
lake lint

# Build verification
lake build

# UTF-8 encoding check
file -b --mime-encoding Logos/Syntax/Formula.lean
```

## Documentation Requirements

### Files Requiring Updates

**LEAN Source Files** (2 files):
1. `Logos/Syntax/Formula.lean` — Add notation declarations and clarifying comments
2. `LogosTest/Syntax/FormulaTest.lean` — Add notation tests

**Core Documentation** (4 files):
1. `docs/glossary/logical-operators.md` — Fix definitions, add triangle symbols
2. `docs/ARCHITECTURE.md` — Update formal definitions
3. `README.md` — Update perpetuity principles with symbols
4. `CLAUDE.md` — Add to quick reference

**Tutorial Documentation** (2 files):
1. `docs/TUTORIAL.md` — Introduce triangle notation
2. `docs/EXAMPLES.md` — Add triangle notation examples

**Developer Documentation** (2 files):
1. `docs/development/LEAN_STYLE_GUIDE.md` — Add style guidelines
2. `docs/development/TESTING_STANDARDS.md` — Update test examples

### Documentation Standards Compliance

**Backtick Standard** (mandatory):
- All Unicode symbols (△, ▽, □, ◇) must be in backticks in Markdown
- Reference: `.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard`

**UTF-8 Encoding** (mandatory):
- Verify encoding after all edits: `file -b --mime-encoding <file>`
- All files must be `utf-8` encoded

**Docstring Requirements** (LEAN 4):
- Every notation declaration requires `/--` docstring
- Include Unicode codepoint in docstring
- Explain operator semantics clearly

## Dependencies

### External Dependencies
None — uses existing LEAN 4 notation system and Unicode standard characters

### Internal Dependencies
- LEAN 4 toolchain (pinned version in `lean-toolchain`)
- Existing Formula module structure
- Existing notation patterns (Validity.lean, Derivation.lean)

### Prerequisite Knowledge
- LEAN 4 notation system syntax
- Unicode character encoding standards
- Logos temporal logic semantics

### Integration Points
- Formula.lean: Core syntax module
- FormulaTest.lean: Test suite integration
- Documentation system: Glossary, architecture, tutorials

## Risk Assessment

### Low Risks
- **Notation conflicts**: Unlikely (△, ▽ not used elsewhere)
- **Build failures**: Mitigated by incremental testing
- **Test regressions**: Prevented by maintaining existing tests

### Medium Risks
- **UTF-8 encoding corruption**: Mitigated by validation checks after each edit
- **Documentation inconsistencies**: Mitigated by phased systematic updates
- **Backtick standard violations**: Mitigated by explicit grep validation

### Mitigation Strategies
1. Validate UTF-8 encoding after every file modification
2. Run `lake build` after each LEAN file change
3. Use grep to verify backtick compliance before phase completion
4. Maintain both notations indefinitely for backward compatibility

## Notes

**Backward Compatibility Guarantee**:
- Existing dot notation (`φ.always`, `φ.sometimes`) remains fully supported
- No breaking changes to Formula inductive type
- No changes to proof system or semantics
- All existing proofs remain valid

**Future Extension Possibilities**:
- Add mixfix notation if community requests it
- Create ASCII alternatives (e.g., `/\` for △, `\/` for ▽)
- Consider deprecation policy if symbols overwhelmingly preferred

**Complexity Score Calculation**:
```
Score = Base(enhance=7) + Tasks(25)/2 + Files(10)*3 + Integrations(0)*5
      = 7 + 12.5 + 30 + 0
      = 49.5 ≈ 50
Tier: Borderline Tier 1/2 (using Tier 1 single-file structure)
```

**Related Specifications**:
- Spec 009: Unicode Symbol Standardization (precedent for Unicode work)
- `.claude/docs/reference/standards/documentation-standards.md`: Backtick standard
- `docs/development/LEAN_STYLE_GUIDE.md`: LEAN 4 coding conventions
