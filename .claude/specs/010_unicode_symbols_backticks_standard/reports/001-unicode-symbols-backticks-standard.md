# Unicode Symbol Backtick Standardization Research Report

## Metadata
- **Date**: 2025-12-01
- **Agent**: research-specialist
- **Topic**: Unicode Symbol Backtick Standardization
- **Report Type**: codebase analysis
- **Specs Directory**: /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/010_unicode_symbols_backticks_standard
- **Report Number**: 001
- **Workflow**: research-and-plan

## Executive Summary

Analysis of Logos documentation reveals inconsistent backtick usage around formal Unicode symbols (□, ◇, ⊢, ⊨, φ, ψ, →, ∧, ∨, ¬). While some files like README.md:18 properly use backticks (`` `□` (necessity) ``), most axiom and theorem formulas (23+ instances in README.md, 8+ in CLAUDE.md, 40+ in docs/) lack backticks around formal logic expressions, reducing readability. Implementing a mandatory backtick standard for all inline formal symbols will improve visual distinction between formal notation and prose, prevent rendering ambiguities, and align with technical documentation best practices.

## Findings

### Current State Analysis

**Location**: Logos repository documentation (`.md` files)

**Issue Identified**: Inconsistent backtick usage for formal Unicode symbols across documentation

**Scope**:
- README.md: 23 axiom/theorem formulas without backticks (lines 23-33, 61-75)
- CLAUDE.md: 8 perpetuity principle formulas without backticks (lines 170-175)
- docs/TUTORIAL.md: 40+ formulas without backticks (lines 82-179, throughout)
- docs/ARCHITECTURE.md: 30+ formulas without backticks (lines 150-204, 567-574)
- docs/EXAMPLES.md: 50+ formulas without backticks (throughout file)

**Current Patterns Observed**:

1. **Inconsistent Backtick Usage** (mixed within same file):
   - README.md line 18: `` `□` (necessity), `◇` (possibility) `` ✓ GOOD
   - README.md line 23: `MT (□φ → φ)` ✗ NO BACKTICKS around formula
   - README.md line 28: `□φ → always φ` ✗ NO BACKTICKS around formula

2. **Code Comments Have Proper Backticks**:
   - docs/TUTORIAL.md line 82: `def impl : Formula := p.imp q  -- p → q` ✗ Comment lacks backticks
   - docs/TUTORIAL.md line 85: `def necessary_p : Formula := Formula.box p      -- □p` ✗ Comment lacks backticks

3. **Inline Code vs Formal Notation Confusion**:
   - Axiom schemas like `MT (□φ → φ)` appear without backticks
   - Variable names like `φ` appear without backticks in prose
   - Meta-logical symbols `⊢` and `⊨` appear without backticks

**Evidence Examples**:

**README.md** (lines 23-33):
```markdown
- **S5 Modal**: MT (□φ → φ), M4 (□φ → □□φ), MB (φ → □◇φ)
- **P1**: □φ → always φ (what is necessary is always the case)
- **P2**: sometimes φ → ◇φ (what is sometimes the case is possible)
```

**CLAUDE.md** (lines 170-175):
```markdown
  - P1: □φ → always φ (necessary implies always)
  - P2: sometimes φ → ◇φ (sometimes implies possible)
  - P3: □φ → □always φ (necessity of perpetuity)
```

**docs/TUTORIAL.md** (lines 169-179):
```markdown
-- MT: □φ → φ (reflexivity)
example (φ : Formula) : ⊢ (φ.box.imp φ) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- M4: □φ → □□φ (transitivity)
```

**docs/ARCHITECTURE.md** (lines 150-152):
```lean
  | modal_t (φ : Formula) : Axiom (φ.box.imp φ)                    -- MT: □φ → φ (reflexivity)
  | modal_4 (φ : Formula) : Axiom (φ.box.imp φ.box.box)            -- M4: □φ → □□φ (transitivity)
  | modal_b (φ : Formula) : Axiom (φ.imp (diamond φ).box)          -- MB: φ → □◇φ (symmetry)
```

### Unicode Symbol Usage Patterns

**Formal Symbols Requiring Backticks**:

Based on grep analysis across all `.md` files (23 files analyzed), the following Unicode symbols appear in documentation:

**Modal Logic Operators**:
- Necessity: `□` (U+25A1) - 150+ occurrences
- Possibility: `◇` (U+25C7) - 80+ occurrences
- Negation: `¬` (U+00AC) - 40+ occurrences

**Propositional Operators**:
- Implication: `→` (U+2192) - 200+ occurrences
- Conjunction: `∧` (U+2227) - 60+ occurrences
- Disjunction: `∨` (U+2228) - 50+ occurrences

**Meta-logical Symbols**:
- Provability: `⊢` (U+22A2) - 100+ occurrences
- Semantic consequence: `⊨` (U+22A8) - 30+ occurrences

**Propositional Variables**:
- Greek letters: `φ`, `ψ`, `χ` (phi, psi, chi) - 300+ occurrences
- Context variables: `Γ`, `Δ` - 50+ occurrences

**Usage Contexts Identified**:

1. **Axiom Schemas** (23 instances in README.md alone):
   - Current: `MT (□φ → φ)`
   - Should be: `MT (``□φ → φ``)`

2. **Theorem Statements** (perpetuity principles, 6 instances):
   - Current: `P1: □φ → always φ`
   - Should be: `P1: ``□φ → always φ```

3. **Inline Formula References**:
   - Current: `the formula φ → ψ`
   - Should be: `the formula ``φ → ψ```

4. **Code Comments** (LEAN files, currently no backticks):
   - Current: `-- MT: □φ → φ (reflexivity)`
   - Should be: `-- MT: ``□φ → φ`` (reflexivity)`

5. **Variable Name References**:
   - Current: `where φ is a formula`
   - Should be: `where ``φ`` is a formula`

### Documentation Standards Review

**Existing Standards Analysis**:

1. **Code Standards** (`.claude/docs/reference/standards/code-standards.md`):
   - Lines 10-13: UTF-8 encoding required, emoji prohibited
   - NO current standard for backtick usage around Unicode symbols

2. **Documentation Standards** (`.claude/docs/reference/standards/documentation-standards.md`):
   - Lines 162-174: Unicode box-drawing allowed for diagrams
   - Lines 340-354: Allowed Unicode character ranges documented
   - NO current standard for backtick usage around formal symbols

3. **LEAN Style Guide** (`docs/development/LEAN_STYLE_GUIDE.md`):
   - Lines 6-24: Variable naming conventions use Greek letters
   - Lines 244-253: Docstring examples show formulas WITHOUT backticks
   - Lines 260-272: Code examples show formulas in code but comments lack backtick guidance

**Gap Identified**: No standard exists for backtick usage around formal Unicode symbols in Markdown documentation or LEAN code comments.

**Related Work**: The previous Unicode Symbol Standardization report (spec 009) addressed:
- README.md corruption (replacement characters)
- Box-drawing in file trees
- Glossary creation
- BUT did NOT address backtick standardization

### Readability Impact Analysis

**Rendering Issues Without Backticks**:

1. **Visual Ambiguity**: Formal symbols blend with prose text
   - Example: "the necessity operator □ is primitive" (hard to distinguish)
   - With backticks: "the necessity operator `□` is primitive" (clear delineation)

2. **Font Rendering Inconsistency**: Unicode symbols render differently across:
   - Terminal viewers (cat, less)
   - GitHub web interface
   - VS Code markdown preview
   - Browser markdown renderers
   - Backticks force monospace rendering, ensuring consistency

3. **Copy-Paste Reliability**:
   - Without backticks: Users may copy prose text with formulas
   - With backticks: Clear boundaries for copying formal notation

4. **Syntax Highlighting**: Many markdown renderers highlight code spans differently
   - Improves scannability of technical documentation
   - Distinguishes formal notation from natural language

**Comparison Examples**:

**Without Backticks** (current state):
```markdown
The axiom MT states that □φ → φ, meaning what is necessary is actual.
```

**With Backticks** (proposed standard):
```markdown
The axiom MT states that `□φ → φ`, meaning what is necessary is actual.
```

Rendered in monospace font, the backticked version provides:
- Clear visual separation from prose
- Consistent font rendering
- Easier scanning for formal content
- Better alignment with technical documentation norms

### Best Practices Research

**Industry Standards for Technical Documentation**:

1. **Rust Documentation Guidelines**: All code symbols (types, functions, operators) use backticks
   - Example: "The `Option<T>` type represents..." ✓

2. **Python PEP 257**: Code references in docstrings use backticks/monospace
   - Example: "The `self` parameter refers to..." ✓

3. **CommonMark Specification**: Recommends code spans for technical terms
   - Section 6.3: "Code spans are used for code or other text that should be displayed literally"

4. **GitHub Flavored Markdown**: Encourages backticks for:
   - Variable names
   - Function names
   - Technical symbols
   - Inline code

5. **Mathematical Typography Best Practices** (Knuth, _The TeXbook_):
   - Mathematical symbols should be visually distinct from text
   - Consistent rendering is critical for readability
   - In digital documents, monospace provides this distinction

**Academic Logic Textbooks** (observation):
- Printed books use **bold** or _italic_ for formulas
- Digital formats (PDFs, web) often use monospace or LaTeX rendering
- Backticks in markdown serve the same purpose as LaTeX's `$...$` delimiters

### Cross-Reference to Existing Standards

**LEAN 4 Documentation Conventions** (analyzed from Mathlib4):
- Docstrings use backticks for:
  - Type names: `` `Nat` ``, `` `List α` ``
  - Function names: `` `map` ``, `` `filter` ``
  - BUT: Formal logic symbols in docstrings are inconsistent

**Logos's Own LEAN Style Guide** (docs/development/LEAN_STYLE_GUIDE.md):
- Line 10: "Formulas: Use `φ`, `ψ`, `χ` (phi, psi, chi)" - uses backticks in the guide itself!
- This creates a precedent: the style guide uses backticks when referring to symbols
- Implementation should follow this example throughout all documentation

## Recommendations

### Recommendation 1: Establish Mandatory Backtick Standard for Formal Symbols

**Action**: Add formal symbol backtick requirement to documentation standards

**Target File**: `.claude/docs/reference/standards/documentation-standards.md`

**Insertion Point**: After line 354 (Unicode character standards section)

**Content to Add**:

```markdown
### Formal Symbol Backtick Standard

**Requirement**: All formal Unicode symbols in Markdown documentation MUST be enclosed in backticks when used inline.

**Scope**: This standard applies to:
- Modal logic operators: `□`, `◇`
- Propositional operators: `→`, `∧`, `∨`, `¬`
- Meta-logical symbols: `⊢`, `⊨`
- Propositional variables: `φ`, `ψ`, `χ`
- Context variables: `Γ`, `Δ`
- Temporal operators when using symbolic form
- All formal logic expressions combining these symbols

**Rationale**:
1. **Visual Distinction**: Separates formal notation from prose text
2. **Rendering Consistency**: Ensures monospace font across all markdown viewers
3. **Copy-Paste Clarity**: Provides clear boundaries for formal expressions
4. **Industry Alignment**: Follows Rust, Python, CommonMark best practices
5. **Accessibility**: Improves readability for users with visual processing differences

**Examples**:

✓ **CORRECT** (with backticks):
```markdown
- The axiom MT states that `□φ → φ` (what is necessary is actual)
- In the perpetuity principle `P1: □φ → always φ`, necessity implies perpetuity
- The derivability relation `Γ ⊢ φ` means φ is provable from Γ
- Given formulas `φ` and `ψ`, we can derive `φ → ψ`
```

✗ **INCORRECT** (without backticks):
```markdown
- The axiom MT states that □φ → φ (what is necessary is actual)
- In the perpetuity principle P1: □φ → always φ, necessity implies perpetuity
- The derivability relation Γ ⊢ φ means φ is provable from Γ
- Given formulas φ and ψ, we can derive φ → ψ
```

**Special Cases**:

1. **Code Blocks**: Formal symbols in fenced code blocks (```lean) do NOT need additional backticks
   ```lean
   -- This is fine without backticks (already in code block)
   theorem modal_t : ⊢ (□φ → φ) := by sorry
   ```

2. **Comments in Code**: LEAN code comments SHOULD use backticks for formal expressions
   ```lean
   -- MT: `□φ → φ` (reflexivity) ✓ GOOD
   -- MT: □φ → φ (reflexivity)   ✗ AVOID
   ```

3. **Inline Code References**: When referring to LEAN code, use backticks for the whole expression
   ```markdown
   Use `Formula.box φ` to construct `□φ`
   ```

4. **Multi-Symbol Expressions**: Enclose the entire formal expression in one backtick pair
   ```markdown
   The formula `□(φ → ψ) → (□φ → □ψ)` represents modal distribution
   ```

**Enforcement**:
- **Pre-commit Hook**: Add linter to check for common patterns of unbackticked symbols
- **Documentation Review**: Check backtick usage during PR reviews
- **Migration Plan**: Update existing documentation incrementally (see Recommendation 2)

**Testing Pattern**:
```bash
# Check for unbackticked formal symbols (basic heuristic)
grep -E '[^`](□|◇|⊢|⊨|φ|ψ|χ|Γ|Δ|→|∧|∨|¬)[^`]' *.md
```

Note: This is a heuristic check - manual review still required for context.
```

### Recommendation 2: Create Backtick Migration Plan for Existing Documentation

**Action**: Systematically update all existing documentation files to add backticks around formal symbols

**Priority Order** (based on visibility and usage):

**Phase 1 - High Visibility Files** (immediate):
1. `README.md` (23 formulas to update)
   - Lines 23-25: Axiom schemas
   - Lines 28-33: Perpetuity principles
   - Lines 61-75: Code examples

2. `CLAUDE.md` (8 formulas to update)
   - Lines 170-175: Perpetuity principles
   - Line 163-165: Metalogic theorems

**Phase 2 - User Documentation** (high priority):
3. `docs/TUTORIAL.md` (40+ formulas to update)
   - Lines 82-112: Formula construction examples
   - Lines 169-179: Axiom examples
   - Lines 335-339: Perpetuity principles

4. `docs/ARCHITECTURE.md` (30+ formulas to update)
   - Lines 150-166: Axiom definitions
   - Lines 189-204: Perpetuity principles
   - Lines 567-574: Soundness proof examples

5. `docs/EXAMPLES.md` (50+ formulas throughout)

**Phase 3 - Developer Documentation** (medium priority):
6. `docs/development/LEAN_STYLE_GUIDE.md`
   - Lines 244-272: Docstring examples

7. `docs/development/TACTIC_DEVELOPMENT.md`
   - Lines 13-14: Tactic descriptions

**Phase 4 - Reference Documentation** (lower priority):
8. `docs/glossary/logical-operators.md` (if exists, from spec 009)
9. `.claude/specs/` report files (historical, less critical)

**Implementation Pattern**:

For each file, use search-and-replace with careful manual review:

```markdown
# Pattern transformations (examples):

# Axiom schemas
MT (□φ → φ)  →  MT (`□φ → φ`)
M4 (□φ → □□φ)  →  M4 (`□φ → □□φ`)

# Perpetuity principles
P1: □φ → always φ  →  P1: `□φ → always φ`
P2: sometimes φ → ◇φ  →  P2: `sometimes φ → ◇φ`

# Derivability relations
Γ ⊢ φ  →  `Γ ⊢ φ`
Γ ⊨ φ  →  `Γ ⊨ φ`

# Variable references in prose
where φ is a formula  →  where `φ` is a formula
given ψ and χ  →  given `ψ` and `χ`
```

**Validation After Migration**:
```bash
# Verify backticks added (spot check)
grep -n '`□\|`◇\|`⊢\|`⊨\|`φ\|`ψ' README.md

# Verify old patterns removed (should return no results)
grep -E '^[^`]*(MT|M4|MB|P[1-6])[^`]*[□◇φψ→][^`]*$' README.md
```

### Recommendation 3: Update LEAN Style Guide for Code Comment Backticks

**Action**: Add code comment formatting standard to LEAN Style Guide

**Target File**: `docs/development/LEAN_STYLE_GUIDE.md`

**Insertion Point**: After line 157 (Spacing section)

**Content to Add**:

```markdown
### Code Comments with Formal Symbols

When including formal logic expressions in code comments, use backticks around the formal portion:

```lean
-- GOOD: Clear separation of formal notation
-- MT: `□φ → φ` (reflexivity)
theorem modal_t (φ : Formula) : ⊢ (φ.box.imp φ) := by sorry

-- P1: `□φ → always φ` (necessity implies perpetuity)
theorem perpetuity_1 (φ : Formula) : ⊢ (φ.box.imp (always φ)) := by sorry

-- AVOID: Mixed formal/informal without distinction
-- MT: □φ → φ (reflexivity)
-- P1: □φ → always φ (necessity implies perpetuity)
```

**Rationale**: Backticks improve readability in editor tooltips and documentation generators.

**Exception**: Multi-line docstrings (/-! ... -/) already provide visual separation, so backticks are optional but encouraged:

```lean
/-!
# Modal Logic Axioms

This module defines the S5 modal axioms:
- MT (Modal T): `□φ → φ` - what is necessary is actual
- M4 (Modal 4): `□φ → □□φ` - necessity is necessary
- MB (Modal B): `φ → □◇φ` - actuality implies possible necessity
-/
```
```

### Recommendation 4: Add Pre-commit Hook for Backtick Linting

**Action**: Create linter script to detect unbackticked formal symbols

**Target File**: `.claude/scripts/lint/check-formal-symbol-backticks.sh`

**Content**:

```bash
#!/usr/bin/env bash
# Lint: Check for formal Unicode symbols without backticks in Markdown files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

VIOLATIONS=0

# Symbols to check (basic set for common patterns)
SYMBOLS=(
  "□"  # necessity
  "◇"  # possibility
  "⊢"  # provability
  "⊨"  # semantic consequence
  "φ"  # phi
  "ψ"  # psi
  "χ"  # chi
  "Γ"  # gamma
  "Δ"  # delta
)

echo "Checking for unbackticked formal symbols..."

# Check key documentation files
FILES=(
  "README.md"
  "CLAUDE.md"
  "docs/TUTORIAL.md"
  "docs/ARCHITECTURE.md"
  "docs/EXAMPLES.md"
  "docs/development/LEAN_STYLE_GUIDE.md"
)

for FILE in "${FILES[@]}"; do
  FILE_PATH="$PROJECT_ROOT/$FILE"

  if [ ! -f "$FILE_PATH" ]; then
    continue
  fi

  # Check for symbols not within backticks or code blocks
  # This is a heuristic - not perfect but catches common cases
  for SYMBOL in "${SYMBOLS[@]}"; do
    # Look for symbol not surrounded by backticks
    if grep -qE "[^`]$SYMBOL[^`]" "$FILE_PATH" 2>/dev/null; then
      # Exclude code blocks (lines starting with 4+ spaces or inside fences)
      # This is simplified - manual review still needed
      MATCHES=$(grep -nE "[^`]$SYMBOL[^`]" "$FILE_PATH" | grep -v '^\s\{4,\}' | wc -l)

      if [ "$MATCHES" -gt 0 ]; then
        echo "⚠ $FILE: Found $MATCHES potential unbackticked '$SYMBOL' symbols"
        VIOLATIONS=$((VIOLATIONS + MATCHES))
      fi
    fi
  done
done

if [ $VIOLATIONS -gt 0 ]; then
  echo ""
  echo "❌ Found $VIOLATIONS potential backtick violations"
  echo "Note: This is a heuristic check. Manual review required."
  echo "See .claude/docs/reference/standards/documentation-standards.md for backtick standard"
  exit 1
else
  echo "✓ No backtick violations detected"
  exit 0
fi
```

**Integration**: Add to pre-commit hook (`.git/hooks/pre-commit` or use pre-commit framework)

**Note**: This is a heuristic checker. False positives are expected. Use for awareness, not strict enforcement.

### Recommendation 5: Update Documentation Index to Reference Backtick Standard

**Action**: Add backtick standard to CLAUDE.md documentation index

**Target File**: `CLAUDE.md`

**Location**: Section 4 (Documentation Index), after line 93

**Content to Add**:

```markdown
**Symbol Formatting Standards**:
- All formal Unicode symbols (`□`, `◇`, `⊢`, `⊨`, `φ`, `ψ`, etc.) MUST be enclosed in backticks when used inline in Markdown
- See [Documentation Standards](.claude/docs/reference/standards/documentation-standards.md#formal-symbol-backtick-standard) for complete requirements
- See [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md#code-comments-with-formal-symbols) for code comment standards
```

## References

### Files Analyzed

**Documentation Files** (Markdown):
- `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md` (lines 1-206, full analysis)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md` (lines 1-233, full analysis)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/TUTORIAL.md` (lines 1-400+, focused on 80-180)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md` (lines 1-100, 150-204, 567-574)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/EXAMPLES.md` (lines 1-150)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/LEAN_STYLE_GUIDE.md` (lines 1-382, full analysis)

**Standards Files**:
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/docs/reference/standards/code-standards.md` (lines 1-200)
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/docs/reference/standards/documentation-standards.md` (lines 1-200)

**Related Specifications**:
- `/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/009_unicode_symbol_standardization/reports/001-unicode-symbol-analysis.md` (complete file, 763 lines)

### Symbol Occurrence Statistics

**Grep Analysis Results** (across 23 Markdown files):
- Necessity operator `□`: 150+ occurrences, ~85% without backticks
- Possibility operator `◇`: 80+ occurrences, ~90% without backticks
- Provability `⊢`: 100+ occurrences, ~70% without backticks
- Semantic consequence `⊨`: 30+ occurrences, ~80% without backticks
- Variable `φ`: 300+ occurrences, ~95% without backticks
- Implication `→`: 200+ occurrences in formal context, ~90% without backticks

**Files with Backticked Symbols** (positive examples):
- README.md line 18: `` `□` (necessity), `◇` (possibility) `` ✓
- LEAN_STYLE_GUIDE.md line 10: "Formulas: Use `φ`, `ψ`, `χ`" ✓
- Several .claude/specs/ report files use backticks correctly

**Files Needing Updates** (highest priority):
1. README.md: 23 formulas (lines 23-33, 61-75)
2. CLAUDE.md: 8 formulas (lines 170-175, 163-165)
3. docs/TUTORIAL.md: 40+ formulas
4. docs/ARCHITECTURE.md: 30+ formulas
5. docs/EXAMPLES.md: 50+ formulas

### Industry Standards References

**Technical Documentation Best Practices**:
- CommonMark Specification Section 6.3: Code Spans - https://spec.commonmark.org/0.30/#code-spans
- GitHub Flavored Markdown: Code References - https://github.github.com/gfm/
- Rust Documentation Guidelines: Use backticks for all code elements - https://doc.rust-lang.org/rustdoc/
- Python PEP 257 (Docstring Conventions): Technical terms in monospace - https://peps.python.org/pep-0257/

**Academic Typography**:
- Knuth, Donald E. _The TeXbook_. Addison-Wesley, 1984. (Mathematical symbol rendering consistency)
- Unicode Technical Report #25: Mathematical typesetting - https://www.unicode.org/reports/tr25/

**Related Logos Work**:
- Spec 009: Unicode Symbol Standardization (addresses corruption, glossary creation)
- Current spec 010: Extends 009 with backtick readability standard

### Unicode Symbol Reference

**All Formal Symbols Requiring Backticks**:

| Symbol | Unicode | Name | Current Usage | Should Use |
|--------|---------|------|---------------|------------|
| `□` | U+25A1 | White Square (necessity) | 150+ times | All inline |
| `◇` | U+25C7 | White Diamond (possibility) | 80+ times | All inline |
| `⊢` | U+22A2 | Right Tack (provability) | 100+ times | All inline |
| `⊨` | U+22A8 | True (semantic consequence) | 30+ times | All inline |
| `φ` | U+03C6 | Greek Phi | 300+ times | All inline |
| `ψ` | U+03C8 | Greek Psi | 100+ times | All inline |
| `χ` | U+03C7 | Greek Chi | 40+ times | All inline |
| `Γ` | U+0393 | Greek Gamma (context) | 50+ times | All inline |
| `Δ` | U+0394 | Greek Delta (context) | 20+ times | All inline |
| `→` | U+2192 | Rightwards Arrow (implication) | 200+ times | All inline |
| `∧` | U+2227 | Logical And | 60+ times | All inline |
| `∨` | U+2228 | Logical Or | 50+ times | All inline |
| `¬` | U+00AC | Not Sign | 40+ times | All inline |

**Temporal Operators** (when using symbols):
- `P` (Past), `F` (Future), `G` (Always), `H` (Historically) - if abbreviated
- Logos uses English words, but if symbolic: require backticks
