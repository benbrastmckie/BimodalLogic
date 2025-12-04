# Unicode Symbol Standardization Implementation Plan

## Metadata
- **Date**: 2025-12-01
- **Feature**: Unicode Symbol Standardization and Documentation Improvements
- **Scope**: Fix Unicode corruption in README.md, enhance file tree formatting, create formal symbols glossary, update documentation standards
- **Estimated Phases**: 5
- **Estimated Hours**: 8
- **Structure Level**: 0 (single file)
- **Complexity Score**: 42.0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Research Reports**:
  - [Unicode Symbol Analysis](/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/009_unicode_symbol_standardization/reports/001-unicode-symbol-analysis.md)

## Overview

This implementation addresses critical Unicode corruption in README.md affecting 45+ logical operator symbols (□, ◇, →, φ) that currently display as replacement characters (�). The corruption makes the README unreadable for understanding TM logic specification. Additionally, this plan adds professional file tree formatting using Unicode box-drawing characters, creates a formal symbols glossary following Logos project patterns, and updates documentation standards to prevent future issues.

**Key Deliverables**:
1. Restored Unicode symbols in README.md (all logical operators readable)
2. Enhanced file tree visualization with box-drawing characters
3. Comprehensive logical operators glossary in docs/glossary/
4. Updated documentation standards for file tree formatting
5. Cross-referenced glossary in CLAUDE.md documentation index

## Research Summary

The research report identified extensive Unicode corruption in README.md through hexdump analysis, revealing 45+ replacement characters (U+FFFD, byte pattern `ef bf bd`) where modal/temporal logic symbols should be. Corrupted sections include modal operators (line 18), axiom schemas (lines 23-25), perpetuity principles (lines 28-33), and code examples (lines 61-75). The root cause is likely editing with a non-UTF-8 compliant editor or corrupted copy/paste operations.

The Logos project glossary provides an excellent pattern for formal operator documentation with: hierarchical category organization (propositional, modal, temporal, meta-logical), comprehensive entry structure (symbol, pronunciation, natural language description, formal definition, interdefinability, examples, cross-references), and consistent formatting standards. Logos's existing LEAN Style Guide already establishes Unicode variable conventions (φ, ψ, χ for formulas; Γ, Δ for contexts) that should be extended to README documentation.

Documentation standards analysis confirms Unicode box-drawing characters (U+2500-U+257F) are approved for technical documentation while emojis are prohibited. CLAUDE.md demonstrates proper file tree formatting (lines 41-99) that should be adopted in README.md to replace the current indentation-only approach.

## Success Criteria

- [ ] README.md contains zero replacement characters (� symbols)
- [ ] All logical operators in README.md display correctly: □, ◇, →, φ, ∧, ∨, ¬, ↔
- [ ] File encoding verified as UTF-8 (`file -b --mime-encoding README.md` returns "utf-8")
- [ ] Project structure section uses Unicode box-drawing characters (├, │, └, ─)
- [ ] Comprehensive glossary created at docs/glossary/logical-operators.md
- [ ] Glossary covers all TM logic operators: propositional, modal, temporal, meta-logical, perpetuity principles
- [ ] Glossary linked from README.md documentation section
- [ ] Glossary linked from CLAUDE.md documentation index
- [ ] Documentation standards updated with file tree formatting requirements
- [ ] All changes validated across multiple terminals/browsers
- [ ] Git diff confirms only intended Unicode changes made

## Technical Design

### Architecture Overview

This implementation consists of five independent phases targeting different documentation files:

1. **README.md Unicode Restoration**: Direct Edit tool operations replacing all `�` characters with correct Unicode symbols based on context (modal: □/◇, implication: →, variables: φ)
2. **README.md File Tree Enhancement**: Replace indentation-only tree (lines 94-107) with CLAUDE.md-style box-drawing format
3. **Glossary Creation**: New file docs/glossary/logical-operators.md following Logos structural patterns
4. **Documentation Integration**: Edit operations on README.md and CLAUDE.md to add glossary cross-references
5. **Standards Documentation**: Edit .claude/docs/reference/standards/documentation-standards.md to add file tree formatting requirements

### Unicode Symbol Mappings

Based on research analysis and LEAN Style Guide conventions:

**Modal Logic**:
- Necessity: `□` (U+25A1, WHITE SQUARE)
- Possibility: `◇` (U+25C7, WHITE DIAMOND)

**Propositional Logic**:
- Implication: `→` (U+2192, RIGHTWARDS ARROW)
- Biconditional: `↔` (U+2194, LEFT RIGHT ARROW)
- Negation: `¬` (U+00AC, NOT SIGN)
- Conjunction: `∧` (U+2227, LOGICAL AND)
- Disjunction: `∨` (U+2228, LOGICAL OR)

**Variables**:
- Formulas: `φ` (U+03C6, GREEK SMALL LETTER PHI), `ψ`, `χ`
- Contexts: `Γ` (U+0393, GREEK CAPITAL LETTER GAMMA), `Δ`

**Meta-logical**:
- Provability: `⊢` (U+22A2, RIGHT TACK)
- Semantic consequence: `⊨` (U+22A8, TRUE)

**Box-Drawing**:
- Vertical: `│` (U+2502), Horizontal: `─` (U+2500)
- Branch: `├─` (U+251C + U+2500), Last: `└─` (U+2514 + U+2500)

### File Tree Format Template

Following CLAUDE.md lines 41-99 pattern:
```
Directory/
├── subdirectory/           # Description
│   ├── file1.ext          # Description
│   └── file2.ext          # Description
└── last-item/             # Description
    └── file.ext           # Description
```

### Glossary Structure

Following Logos pattern with Logos-specific categories:

1. **Header Navigation**: Breadcrumb links to parent docs
2. **Purpose Statement**: Glossary scope and audience
3. **Operator Categories**:
   - Propositional Operators (¬, ∧, ∨, →, ↔, ⊥, ⊤)
   - Modal Operators (□, ◇)
   - Temporal Operators (Past, Future, past, future, always, sometimes)
   - Meta-logical Symbols (⊢, ⊨, ∀, ∃, ∈, ⊆, ∅)
   - Perpetuity Principles (P1-P6 derived theorems)
4. **Entry Structure**: Symbol + pronunciation, natural language description, formal definition, LEAN code reference, semantics, related operators, examples
5. **Variable Conventions**: LEAN Style Guide conventions reference
6. **Footer**: Related documentation links, last updated timestamp

### Edit Operations Strategy

**Phase 1 - README.md Unicode Fixes**: Multiple targeted Edit operations using context to identify correct replacements (e.g., "�� → �" in axiom context becomes "□φ → φ")

**Phase 2 - File Tree Enhancement**: Single large Edit operation replacing entire Project Structure section (lines 94-107) with formatted tree

**Phase 3 - Glossary Creation**: Write operation for new file (no existing content to preserve)

**Phase 4 - Documentation Links**: Two Edit operations adding glossary references to existing lists

**Phase 5 - Standards Update**: Single Edit operation adding file tree formatting section after Unicode box-drawing section (line 359)

### Validation Approach

**UTF-8 Encoding Verification**:
```bash
file -b --mime-encoding README.md
# Expected: utf-8

file -b --mime-encoding docs/glossary/logical-operators.md
# Expected: utf-8
```

**Symbol Presence Verification**:
```bash
# Verify no replacement characters remain
grep -n "�" README.md
# Expected: no output (exit code 1)

# Verify correct symbols present
grep -n "□\|◇\|→\|φ" README.md | wc -l
# Expected: 30+ matches across axioms, principles, examples
```

**Box-Drawing Verification**:
```bash
# Verify box-drawing characters in file tree
grep -n "├\|│\|└\|─" README.md
# Expected: 15+ matches in Project Structure section
```

**Cross-Reference Verification**:
```bash
# Verify glossary link in README.md
grep -n "glossary/logical-operators" README.md
# Expected: 1 match in documentation section

# Verify glossary link in CLAUDE.md
grep -n "glossary/logical-operators" CLAUDE.md
# Expected: 1 match in documentation index
```

### Risk Mitigation

**Risk**: Incorrect Unicode replacement (wrong symbol for context)
**Mitigation**: Use research report's detailed line-by-line mapping, test each edit against research analysis

**Risk**: UTF-8 encoding corruption during edit
**Mitigation**: Verify encoding after each phase, use UTF-8 compliant editor (VS Code default)

**Risk**: Breaking markdown rendering with box-drawing characters
**Mitigation**: Test markdown rendering in GitHub preview, validate against CLAUDE.md working example

**Risk**: Inconsistent symbol usage across documentation
**Mitigation**: Create glossary first (single source of truth), reference glossary in all subsequent edits

## Implementation Phases

### Phase 1: Fix README.md Unicode Corruption [COMPLETE]
dependencies: []

**Objective**: Replace all 45+ replacement characters (�) in README.md with correct Unicode logical operator symbols

**Complexity**: Medium

**Tasks**:
- [x] Create backup of README.md before editing (file: README.md.backup.20251201)
- [x] Fix line 18 modal operators definition: `�` → `□`, `�` → `◇`
- [x] Fix line 23 S5 axioms: MT (`�� � �` → `□φ → φ`), M4 (`�� � ���` → `□φ → □□φ`), MB (`� � ���` → `φ → □◇φ`)
- [x] Fix line 24 temporal axioms: T4 (`Future � → Future Future �` → `Future φ → Future Future φ`), TA (`� → Future past �` → `φ → Future past φ`), TL (`always � → Future Past �` → `always φ → Future Past φ`)
- [x] Fix line 25 bimodal axioms: MF (`�� � �Future �` → `□φ → □Future φ`), TF (`�� � Future ��` → `□φ → Future □φ`)
- [x] Fix lines 28-33 perpetuity principles P1-P6: Replace all `�` with appropriate symbols (□, ◇, →, φ)
- [x] Fix lines 61-75 code examples: `�p � p` → `□p → p`, `�"p" � "p"` → `□"p" → "p"`, variable names `�` → `φ`
- [x] Verify encoding: Run `file -b --mime-encoding README.md` (expect "utf-8")
- [x] Verify no replacement characters remain: Run `grep -n "�" README.md` (expect no output)
- [x] Test markdown rendering in VS Code preview and GitHub preview

**Testing**:
```bash
# Verify no replacement characters remain
grep -n "�" README.md
# Exit code should be 1 (no matches)

# Verify correct symbols present in key sections
grep -n "□φ → φ" README.md  # Should match MT axiom (line ~23)
grep -n "□φ → □□φ" README.md  # Should match M4 axiom (line ~23)
grep -n "φ → □◇φ" README.md  # Should match MB axiom (line ~23)

# Count total Unicode operator occurrences
grep -o "□\|◇\|→\|φ" README.md | wc -l
# Should be 60+ (multiple axioms, principles, examples)

# Verify UTF-8 encoding
file -b --mime-encoding README.md
# Should output: utf-8

# Visual validation
head -n 80 README.md | tail -n 30
# Lines 18-33 should display readable logical notation
```

**Expected Duration**: 2 hours

---

### Phase 2: Enhance Project Structure with Box-Drawing Characters [COMPLETE]
dependencies: []

**Objective**: Replace indentation-only file tree in README.md with professional Unicode box-drawing format following CLAUDE.md pattern

**Complexity**: Low

**Tasks**:
- [x] Read CLAUDE.md lines 41-99 to extract exact formatting pattern (file: CLAUDE.md)
- [x] Design Logos file tree with box-drawing characters matching project structure
- [x] Edit README.md lines 94-107 to replace current tree with formatted version (file: README.md)
- [x] Align comments at consistent column (column 40 for consistency with CLAUDE.md)
- [x] Add glossary directory entry: `docs/glossary/` with `logical-operators.md` file
- [x] Verify visual hierarchy is clear and unambiguous
- [x] Test rendering in multiple contexts: terminal `cat`, VS Code preview, GitHub preview
- [x] Validate box-drawing characters display correctly across UTF-8 terminals

**File Tree Content** (to replace lines 94-107):
```
Logos/
├── Logos.lean           # Library root (re-exports all public modules)
├── Logos/               # Main source directory
│   ├── Syntax/                 # Formula types, parsing, DSL
│   │   ├── Formula.lean        # Core formula inductive type
│   │   ├── Context.lean        # Proof context (premise lists)
│   │   └── DSL.lean            # Domain-specific syntax
│   ├── ProofSystem/            # Axioms and inference rules
│   │   ├── Axioms.lean         # TM axiom schemata
│   │   ├── Rules.lean          # Inference rules (MP, MK, TK, TD)
│   │   └── Derivation.lean     # Derivability relation
│   ├── Semantics/              # Task frame semantics
│   │   ├── TaskFrame.lean      # Task frame structure
│   │   ├── WorldHistory.lean   # World history definition
│   │   ├── TaskModel.lean      # Model with valuation
│   │   ├── Truth.lean          # Truth evaluation
│   │   └── Validity.lean       # Validity and consequence
│   ├── Metalogic/              # Soundness and completeness
│   │   ├── Soundness.lean      # Soundness theorem
│   │   ├── Completeness.lean   # Completeness theorem
│   │   └── Decidability.lean   # Decision procedures
│   ├── Theorems/               # Key theorems
│   │   └── Perpetuity.lean     # P1-P6 perpetuity principles
│   └── Automation/             # Proof automation
│       ├── Tactics.lean        # Custom tactics
│       └── ProofSearch.lean    # Automated proof search
├── LogosTest/           # Test suite
│   ├── LogosTest.lean   # Test library root
│   ├── Syntax/                 # Tests for formula construction
│   ├── ProofSystem/            # Tests for axioms and rules
│   ├── Semantics/              # Tests for semantics
│   ├── Integration/            # Cross-module tests
│   └── Metalogic/              # Soundness/completeness tests
├── Archive/                    # Pedagogical examples
│   ├── Archive.lean            # Archive library root
│   ├── ModalProofs.lean        # S5 modal logic examples
│   ├── TemporalProofs.lean     # Temporal reasoning examples
│   └── BimodalProofs.lean      # Combined examples
├── Counterexamples/            # Invalidity demonstrations
│   └── Counterexamples.lean    # Counterexamples library root
├── docs/                       # User documentation
│   ├── ARCHITECTURE.md         # System design and TM spec
│   ├── TUTORIAL.md             # Getting started guide
│   ├── EXAMPLES.md             # Usage examples
│   ├── CONTRIBUTING.md         # Contribution guidelines
│   ├── INTEGRATION.md          # Model-Checker integration
│   ├── VERSIONING.md           # Semantic versioning policy
│   ├── glossary/               # Formal symbols glossary
│   │   └── logical-operators.md # Modal, temporal, meta-logical symbols
│   └── development/            # Developer standards
│       ├── LEAN_STYLE_GUIDE.md     # Coding conventions
│       ├── MODULE_ORGANIZATION.md  # Directory structure
│       ├── TESTING_STANDARDS.md    # Test requirements
│       ├── TACTIC_DEVELOPMENT.md   # Custom tactic patterns
│       └── QUALITY_METRICS.md      # Quality targets
├── lakefile.toml               # LEAN 4 build configuration
├── lean-toolchain              # LEAN version pinning
├── .gitignore                  # Git exclusions
└── .github/workflows/ci.yml    # CI/CD pipeline
```

**Testing**:
```bash
# Verify box-drawing characters present
grep -n "├\|│\|└\|─" README.md | wc -l
# Should be 40+ (extensive file tree)

# Verify glossary directory included
grep -n "glossary/" README.md
# Should match in file tree section

# Visual validation in terminal
sed -n '94,140p' README.md
# Should display clear hierarchical tree

# Markdown rendering test
# Open README.md in GitHub preview - tree should be visually clear
```

**Expected Duration**: 1 hour

---

### Phase 3: Create Formal Symbols Glossary [COMPLETE]
dependencies: []

**Objective**: Create comprehensive logical operators glossary at docs/glossary/logical-operators.md following Logos project patterns

**Complexity**: Medium

**Tasks**:
- [x] Create docs/glossary/ directory (directory: /home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/)
- [x] Write logical-operators.md with complete structure (file: docs/glossary/logical-operators.md)
- [x] Add header navigation with breadcrumb links to parent documentation
- [x] Write purpose statement describing glossary scope for TM logic
- [x] Document propositional operators: ¬, ∧, ∨, →, ↔, ⊥, ⊤ with definitions, LEAN code, examples
- [x] Document modal operators: □, ◇ with S5 axioms, semantics, interdefinability
- [x] Document temporal operators: Past, Future, past, future, always, sometimes with semantics, axioms
- [x] Document meta-logical symbols: ⊢, ⊨, ∀, ∃, ∈, ⊆, ∅ with usage context
- [x] Document perpetuity principles P1-P6 with natural language, formal notation, LEAN theorem references
- [x] Add variable conventions section referencing LEAN Style Guide (φ, ψ, χ, Γ, Δ, τ, σ)
- [x] Include cross-references between related operators (e.g., □ ↔ ◇ duality)
- [x] Add footer with related documentation links and last updated timestamp
- [x] Verify all Unicode symbols display correctly
- [x] Test glossary rendering in markdown viewers

**Glossary Entry Template** (per operator):
```markdown
#### [Symbol] ([pronunciation])
Natural language description of operator meaning.

**Formal Definition**: Mathematical notation or interdefinability
**LEAN Code**: `Formula.operation` or derived definition
**Semantics**: Truth conditions in task frame models
**See also**: Links to related operators
**Examples**: Concrete usage in Logos context
```

**Testing**:
```bash
# Verify file created
test -f docs/glossary/logical-operators.md && echo "Glossary exists"

# Verify UTF-8 encoding
file -b --mime-encoding docs/glossary/logical-operators.md
# Should output: utf-8

# Verify all key operators documented
for symbol in "□" "◇" "→" "φ" "⊢" "⊨" "Past" "Future" "always" "sometimes"; do
  grep -q "$symbol" docs/glossary/logical-operators.md && echo "$symbol: ✓" || echo "$symbol: ✗"
done

# Verify perpetuity principles documented
for principle in "P1" "P2" "P3" "P4" "P5" "P6"; do
  grep -q "#### $principle" docs/glossary/logical-operators.md && echo "$principle: ✓" || echo "$principle: ✗"
done

# Verify cross-references present
grep -c "See also" docs/glossary/logical-operators.md
# Should be 10+ (each major operator has cross-refs)

# Verify LEAN code references
grep -c "LEAN Code" docs/glossary/logical-operators.md
# Should be 15+ (most operators have LEAN examples)

# Visual validation
head -n 50 docs/glossary/logical-operators.md
# Should show header, navigation, purpose, and start of operators
```

**Expected Duration**: 3 hours

---

### Phase 4: Integrate Glossary into Documentation Index [COMPLETE]
dependencies: [3]

**Objective**: Add glossary cross-references to README.md and CLAUDE.md documentation indexes

**Complexity**: Low

**Tasks**:
- [x] Edit README.md documentation section (lines 78-84) to add glossary link (file: README.md)
- [x] Insert glossary reference after Architecture Guide and before Tutorial for logical ordering
- [x] Edit CLAUDE.md documentation index (lines 110-116) to add glossary link (file: CLAUDE.md)
- [x] Insert glossary reference after Architecture Guide in User Documentation section
- [x] Verify both links use correct relative paths from file locations
- [x] Test links work in markdown preview (VS Code and GitHub)
- [x] Verify glossary appears in logical position in documentation flow

**README.md Edit** (after line 80):
```markdown
- [Architecture Guide](docs/ARCHITECTURE.md) - System design and TM logic specification
- [Logical Operators Glossary](docs/glossary/logical-operators.md) - Formal symbols reference
- [Tutorial](docs/TUTORIAL.md) - Getting started with Logos
```

**CLAUDE.md Edit** (after line 111):
```markdown
### User Documentation (docs/)
- [Architecture Guide](docs/ARCHITECTURE.md) - System design and TM logic specification
- [Logical Operators Glossary](docs/glossary/logical-operators.md) - Formal symbols reference
- [Tutorial](docs/TUTORIAL.md) - Getting started with Logos
```

**Testing**:
```bash
# Verify glossary link in README.md
grep -n "Logical Operators Glossary" README.md
# Should match once in documentation section (line ~81)

# Verify glossary link in CLAUDE.md
grep -n "Logical Operators Glossary" CLAUDE.md
# Should match once in User Documentation section (line ~112)

# Verify link targets exist
test -f docs/glossary/logical-operators.md && echo "Target exists: ✓"

# Verify relative path correctness (from project root)
ls docs/glossary/logical-operators.md
# Should display: docs/glossary/logical-operators.md

# Test markdown link rendering
# Open README.md in GitHub preview - glossary link should be clickable and functional
# Open CLAUDE.md in VS Code preview - glossary link should be clickable and functional
```

**Expected Duration**: 0.5 hours

---

### Phase 5: Update Documentation Standards for File Trees [COMPLETE]
dependencies: []

**Objective**: Add file tree formatting standards to documentation standards file to prevent future inconsistencies

**Complexity**: Low

**Tasks**:
- [x] Edit .claude/docs/reference/standards/documentation-standards.md after line 359 (file: .claude/docs/reference/standards/documentation-standards.md)
- [x] Add "File Tree Formatting Standards" section with requirements and templates
- [x] Document standard box-drawing characters with Unicode codepoints
- [x] Provide pattern template showing correct usage (├, │, └, ─)
- [x] Document anti-patterns (indentation-only, ASCII-only, inconsistent characters)
- [x] Add best practices: comment alignment, nesting levels, representative files
- [x] Reference CLAUDE.md lines 41-77 as canonical example
- [x] Include validation approach (visual inspection criteria)
- [x] Add tools section (tree utility, editor plugins)
- [x] Verify section integrates logically with existing Unicode standards (lines 340-359)

**Content to Add** (after line 359):
```markdown
### File Tree Formatting Standards

**Requirement**: All file trees in README.md and documentation must use Unicode box-drawing characters for clear visual hierarchy.

**Standard Characters**:
- Vertical line: `│` (U+2502, BOX DRAWINGS LIGHT VERTICAL)
- Horizontal line: `─` (U+2500, BOX DRAWINGS LIGHT HORIZONTAL)
- Branch (├─): Connects to item with siblings below
- Last branch (└─): Connects to final item in directory
- Continuation (│  ): Vertical line through sibling items

**Pattern Template**:
```
ProjectName/
├── directory/              # First item
│   ├── subdirectory/      # Nested item with siblings
│   │   ├── file1.ext      # File with sibling
│   │   └── file2.ext      # Last file in directory
│   └── another-subdir/    # Last subdir
├── another-directory/     # Middle item
│   └── file.ext           # Single item
└── last-directory/        # Last item (use └─)
    └── file.ext
```

**Anti-Patterns**:
```
# WRONG: Indentation only (ambiguous hierarchy)
ProjectName/
  directory/
    subdirectory/
      file1.ext

# WRONG: ASCII characters (not Unicode)
ProjectName/
|- directory/
|  |- file.ext

# WRONG: Inconsistent character usage
ProjectName/
+- directory/              # Mix of symbols
|  ├─ file.ext
```

**Best Practices**:
1. Align comments at consistent column (e.g., column 40 as in CLAUDE.md)
2. Use 4 spaces or equivalent for each nesting level with `│` continuation
3. Include only representative files (don't exhaustively list every file)
4. Group related items together for clarity
5. Add descriptive comments for non-obvious directories

**Tools**:
- Command-line: `tree -F --charset unicode` (requires tree utility)
- VS Code: "File Tree Generator" extension
- Manual construction using template above

**Validation**: Visual inspection - file tree hierarchy should be immediately clear and unambiguous.

**Reference Implementation**: See CLAUDE.md lines 41-99 for canonical Logos file tree.
```

**Testing**:
```bash
# Verify section added to documentation standards
grep -n "File Tree Formatting Standards" .claude/docs/reference/standards/documentation-standards.md
# Should match once (line ~360)

# Verify pattern template included
grep -n "Pattern Template" .claude/docs/reference/standards/documentation-standards.md
# Should match once in new section

# Verify anti-patterns documented
grep -n "Anti-Patterns" .claude/docs/reference/standards/documentation-standards.md
# Should match once in new section

# Verify reference to CLAUDE.md
grep -n "CLAUDE.md lines 41-99" .claude/docs/reference/standards/documentation-standards.md
# Should match once

# Context check - verify section flows logically after Unicode standards
sed -n '350,380p' .claude/docs/reference/standards/documentation-standards.md
# Should show: Unicode Box-Drawing section → File Tree Formatting Standards section
```

**Expected Duration**: 1.5 hours

---

## Testing Strategy

### Overall Approach

**Unit Testing**: Each phase validates its own deliverable (encoding checks, symbol verification, file existence)

**Integration Testing**: Phase 4 validates cross-references between files (README.md → glossary, CLAUDE.md → glossary)

**Visual Testing**: All phases include markdown rendering validation in multiple contexts (terminal, VS Code, GitHub)

**Regression Testing**: Final validation ensures no unintended changes to non-Unicode content

### Comprehensive Validation

**After Phase 1 Completion**:
```bash
# No replacement characters anywhere in README.md
! grep -q "�" README.md && echo "✓ No corruption" || echo "✗ Still corrupted"

# Specific axioms readable
grep -q "□φ → φ" README.md && echo "✓ MT axiom correct"
grep -q "□φ → □□φ" README.md && echo "✓ M4 axiom correct"
grep -q "φ → □◇φ" README.md && echo "✓ MB axiom correct"

# Perpetuity principles readable
grep -q "□φ → always φ" README.md && echo "✓ P1 correct"
grep -q "sometimes φ → ◇φ" README.md && echo "✓ P2 correct"
```

**After Phase 2 Completion**:
```bash
# Box-drawing characters present
grep -q "├\|│\|└\|─" README.md && echo "✓ File tree formatted"

# Glossary directory included
grep -q "docs/glossary/" README.md && echo "✓ Glossary in tree"

# Visual hierarchy test (manual inspection)
sed -n '94,150p' README.md
```

**After Phase 3 Completion**:
```bash
# Glossary file exists with correct encoding
test -f docs/glossary/logical-operators.md && file -b --mime-encoding docs/glossary/logical-operators.md | grep -q "utf-8" && echo "✓ Glossary created"

# All operator categories present
grep -q "Propositional Operators" docs/glossary/logical-operators.md && echo "✓ Propositional"
grep -q "Modal Operators" docs/glossary/logical-operators.md && echo "✓ Modal"
grep -q "Temporal Operators" docs/glossary/logical-operators.md && echo "✓ Temporal"
grep -q "Perpetuity Principles" docs/glossary/logical-operators.md && echo "✓ Perpetuity"
```

**After Phase 4 Completion**:
```bash
# Cross-references exist
grep -q "glossary/logical-operators" README.md && echo "✓ README link"
grep -q "glossary/logical-operators" CLAUDE.md && echo "✓ CLAUDE.md link"

# Link targets valid
for doc in README.md CLAUDE.md; do
  grep "glossary/logical-operators" "$doc" | while read -r line; do
    test -f docs/glossary/logical-operators.md && echo "✓ $doc link valid"
  done
done
```

**After Phase 5 Completion**:
```bash
# Standards section added
grep -q "File Tree Formatting Standards" .claude/docs/reference/standards/documentation-standards.md && echo "✓ Standards updated"

# Templates included
grep -q "Pattern Template" .claude/docs/reference/standards/documentation-standards.md && echo "✓ Templates present"
```

**Final Regression Test**:
```bash
# No unintended changes (git diff should show only Unicode/formatting changes)
git diff README.md | grep -v "^[-+].*[□◇→φ├│└─]" | wc -l
# Should be minimal (only metadata/context lines)

# All files still valid markdown
for file in README.md CLAUDE.md docs/glossary/logical-operators.md; do
  # Markdown linting if available, otherwise manual inspection
  test -f "$file" && echo "✓ $file exists"
done
```

### Performance Benchmarks

Not applicable - this is a documentation-only update with no runtime performance implications.

### Coverage Requirements

**Documentation Coverage**: 100% of corrupted Unicode instances must be corrected (45+ symbols in README.md)

**Standards Coverage**: File tree formatting standards must cover all use cases: nested directories, siblings, last items, comments

**Glossary Coverage**: All TM logic operators used in Logos must be documented (20+ operators across 5 categories)

## Documentation Requirements

### Files to Update

1. **README.md**: Fix Unicode corruption, enhance file tree, add glossary link
2. **CLAUDE.md**: Add glossary to documentation index
3. **docs/glossary/logical-operators.md**: Create new comprehensive glossary (NEW FILE)
4. **.claude/docs/reference/standards/documentation-standards.md**: Add file tree formatting section

### Documentation Standards Compliance

**README.md Changes**:
- Preserve existing structure and content (only fix Unicode and formatting)
- Maintain consistency with LEAN Style Guide variable conventions
- Follow markdown best practices (proper heading hierarchy, code blocks, lists)
- Ensure UTF-8 encoding throughout

**Glossary Creation**:
- Follow Logos glossary pattern (proven in production)
- Include navigation breadcrumbs for discoverability
- Provide comprehensive entries with LEAN code references
- Cross-reference related operators extensively
- Add "last updated" timestamp for maintenance tracking

**CLAUDE.md Updates**:
- Maintain existing documentation index structure
- Insert glossary in logical position (after Architecture, before Tutorial)
- Use consistent link format with other documentation references

**Documentation Standards Updates**:
- Integrate seamlessly after existing Unicode section
- Provide both positive examples (templates) and negative examples (anti-patterns)
- Reference existing canonical example (CLAUDE.md)
- Include practical tooling recommendations

### README Sections Affected

- **Line 18**: Modal operators definition (Unicode fix)
- **Lines 23-25**: Axiom schemas (Unicode fix)
- **Lines 28-33**: Perpetuity principles (Unicode fix)
- **Lines 61-75**: Code examples (Unicode fix)
- **Lines 78-84**: Documentation links (add glossary reference)
- **Lines 94-107**: Project structure (enhance with box-drawing)

### New Documentation

**docs/glossary/logical-operators.md** (NEW FILE, ~600 lines):
- Comprehensive catalog of TM logic operators
- Structured following Logos pattern with Logos-specific content
- Includes all operator categories: propositional, modal, temporal, meta-logical, perpetuity
- Extensive cross-references and LEAN code examples
- Variable conventions reference for consistency
- Related documentation links for context

## Dependencies

### External Dependencies

- **UTF-8 Compliant Editor**: VS Code (default), vim with UTF-8 encoding, or similar (for reliable Unicode editing)
- **Markdown Renderer**: VS Code markdown preview, GitHub preview (for validation)
- **Git**: Version control for tracking changes and creating backups

### Internal Dependencies

- **Phase 4 depends on Phase 3**: Glossary must exist before adding links (hard dependency)
- **Phases 1, 2, 5 are independent**: Can be executed in any order or parallel

### File Dependencies

- **README.md**: Main target file (Phases 1, 2, 4)
- **CLAUDE.md**: Documentation index target (Phase 4)
- **docs/glossary/logical-operators.md**: New glossary file (Phase 3)
- **.claude/docs/reference/standards/documentation-standards.md**: Standards documentation (Phase 5)
- **docs/development/LEAN_STYLE_GUIDE.md**: Reference for variable conventions (read-only, used in Phase 3)

### Prerequisite Knowledge

- Unicode character encoding fundamentals (UTF-8 byte sequences)
- Markdown syntax and rendering behavior
- Git workflow for creating backups and committing changes
- Logos TM logic fundamentals (for accurate glossary entries)
- LEAN 4 syntax basics (for LEAN code references in glossary)

### System Requirements

- **Operating System**: Linux/macOS/Windows with UTF-8 locale support
- **Terminal**: UTF-8 capable terminal emulator for box-drawing character display
- **Editor**: UTF-8 compliant text editor (VS Code recommended)
- **Shell**: Bash for validation scripts (grep, file, test commands)

---

## Notes

### Complexity Calculation

```
Score = Base(feature type) + Tasks/2 + Files*3 + Integrations*5
      = 10 (new glossary) + 40/2 + 4*3 + 0*5
      = 10 + 20 + 12 + 0
      = 42.0
```

**Tier Selection**: Score 42 < 50 → Tier 1 (single file structure)

### Standards Compliance

This plan adheres to Logos standards:

- **TDD Principles**: Each phase includes comprehensive testing strategies with specific validation commands
- **Documentation Requirements**: All changes include docstring-equivalent documentation (glossary entries, standards sections)
- **UTF-8 Encoding**: All files verified as UTF-8 throughout implementation
- **Fail-Fast Error Handling**: Validation commands designed to fail immediately on issues (e.g., `grep -q` with non-zero exit for missing symbols)
- **2-Space Indentation**: File tree examples use consistent indentation matching LEAN style guide
- **Comprehensive Docstrings**: Glossary entries provide LEAN code references, formal definitions, and natural language descriptions

### Implementation Tips

**Unicode Editing Best Practices**:
1. Set editor to UTF-8 encoding before opening files
2. Use Unicode input methods (copy/paste from character map, Alt codes, or editor shortcuts)
3. Verify visual rendering after each edit (symbols should be crisp and clear)
4. Test in multiple contexts (terminal, editor, browser) before committing

**Box-Drawing Construction**:
1. Start with root directory (no prefix)
2. For each item: last item uses `└─`, others use `├─`
3. For nested items: add `│   ` (vertical + 3 spaces) for each parent with siblings below
4. Align comments at consistent column (40 recommended)
5. Reference CLAUDE.md lines 41-99 when uncertain

**Glossary Writing**:
1. Start with propositional operators (foundational)
2. Add modal operators with S5 axiom references
3. Add temporal operators with linear temporal logic semantics
4. Add meta-logical symbols with soundness/completeness context
5. Add perpetuity principles with LEAN theorem references
6. Cross-reference extensively (every major operator should reference related operators)
7. Include concrete examples from Logos codebase when possible

**Quality Assurance**:
1. After each phase, run all phase-specific validation commands
2. Visually inspect changes in markdown preview (VS Code and GitHub)
3. Git diff to confirm only intended changes made
4. Test links by clicking in rendered markdown
5. Verify UTF-8 encoding with `file` command
6. Final full regression test after all phases complete

---

**Implementation Order**: Phases 1, 2, 5 can run in parallel. Phase 3 must complete before Phase 4 (glossary must exist before linking).

**Rollback Strategy**: Backup README.md in Phase 1 (README.md.backup.20251201). If corruption occurs, restore from backup and diagnose encoding issue before retrying.

**Post-Implementation**: Consider adding glossary references to ARCHITECTURE.md when defining operators (future enhancement, not in this plan scope).
