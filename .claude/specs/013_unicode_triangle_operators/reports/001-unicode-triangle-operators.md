# Unicode Triangle Operators for Always/Sometimes Research Report

## Metadata
- **Date**: 2025-12-01
- **Agent**: research-specialist
- **Topic**: Replace 'always' and 'sometimes' operators with Unicode triangle characters
- **Report Type**: Codebase analysis and Unicode symbol research
- **Complexity**: 3

## Executive Summary

This report analyzes the feasibility and approach for replacing the temporal operators `always` and `sometimes` in Logos with Unicode triangle characters (△ for always, ▽ for sometimes). Current analysis shows these operators are defined as derived functions in `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean` with `always` aliasing `future` and `sometimes` defined as the dual. The replacement would require: (1) adding LEAN 4 notation declarations, (2) updating 28 LEAN source files, (3) revising 20+ documentation files, (4) updating the logical operators glossary, and (5) ensuring LEAN 4 notation system compatibility with Unicode mathematical operators U+25B3 and U+25BD.

## Findings

### 1. Current State Analysis

#### 1.1 Current Operator Definitions

**Location**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean:94-123`

The `always` and `sometimes` operators are currently defined as derived functions:

```lean
-- Line 94-98: always operator
/--
Temporal 'always' operator (Gφ, "for all future times φ").

In our system, this is the same as the future operator F.
-/
def always (φ : Formula) : Formula := φ.future

-- Line 100-106: sometimes operator
/--
Temporal 'sometimes' operator (Fφ, "exists a future time where φ").

Derived as: ¬G¬φ = ¬(always (¬φ)) (not always not φ).
This means: there exists a future time where φ is true.
-/
def sometimes (φ : Formula) : Formula := φ.neg.always.neg
```

**Key Observations**:
- `always` is currently just an alias for `future`
- `sometimes` is defined as the dual of `always` using negation
- No notation or syntax declarations currently exist for these operators
- They are accessed via dot notation: `φ.always`, `φ.sometimes`

#### 1.2 Documentation Definitions

**Location**: `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md:157-176`

The glossary defines these operators using text names:

```markdown
### always (eternal truth)
Combined modal-temporal operator - expresses that a formula holds at all times.

**Formal Definition**: `always φ := Past φ ∧ φ ∧ Future φ`
**LEAN Code**: Defined from conjunction of Past, present, and Future
**Semantics**: `M,h,t ⊨ always φ` iff for all times t' in domain(h), `M,h,t' ⊨ φ`
**See also**: [sometimes](#sometimes-eventual-truth)
**Perpetuity**: Used in P1-P6 to connect necessity and temporal truth
**Examples**: `always □p` means "at all times, p is necessary"

### sometimes (eventual truth)
Combined modal-temporal operator - expresses that a formula holds at some time.

**Formal Definition**: `sometimes φ := past φ ∨ φ ∨ future φ`
**LEAN Code**: Defined from disjunction of past, present, and future
**Semantics**: `M,h,t ⊨ sometimes φ` iff there exists time t' in domain(h) such that `M,h,t' ⊨ φ`
**See also**: [always](#always-eternal-truth)
**Perpetuity**: Used in P2, P4, P5, P6 perpetuity principles
**Duality**: `sometimes φ ↔ ¬always¬φ`
**Examples**: `sometimes □p` means "at some time, p is necessary"
```

**Discrepancy Noted**: The glossary definition of `always` shows `Past φ ∧ φ ∧ Future φ`, but the actual LEAN code implementation is just `φ.future`. This needs clarification.

#### 1.3 Architecture Documentation

**Location**: `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md:48-49`

```lean
def always (φ : Formula) : Formula := and (and (Formula.past φ) φ) (Formula.future φ)
def sometimes (φ : Formula) : Formula := or (or (sometime_past φ) φ) (sometime_future φ)
```

The ARCHITECTURE.md shows a different definition than the actual implementation—this is a three-time quantifier (past, present, future) vs. just future operator.

### 2. Unicode Triangle Character Research

#### 2.1 Temporal Logic Standard Notation

From web research on LTL (Linear Temporal Logic) notation standards:

**Standard LTL Operators**:
- **G** (Globally) or **□** (box) — "Always" / "Henceforth"
- **F** (Finally) or **◇** (diamond) — "Eventually" / "Sometimes"

**Unicode Alternatives**:
- White triangle pointing up: △ (U+25B3, WHITE UP-POINTING TRIANGLE)
- White triangle pointing down: ▽ (U+25BD, WHITE DOWN-POINTING TRIANGLE)
- Nabla: ∇ (U+2207, NABLA)

#### 2.2 Triangle Symbol Semantics

**Proposed Mapping**:
- **△** (upward triangle, U+25B3) for `always` — suggests universality, pointing to all future states
- **▽** (downward nabla/triangle, U+25BD) for `sometimes` — suggests existential, pointing to some state

**Alternative Consideration**:
- **∇** (nabla, U+2207) for `sometimes` — nabla is used in mathematical logic for indeterminacy and existential constructs

**Rationale**: The upward △ and downward ▽ provide visual duality mirroring the logical duality between universal (∀) and existential (∃) quantifiers.

#### 2.3 Unicode Mathematical Operator Support

The Unicode Mathematical Operators block (U+2200–U+22FF) contains:
- U+2200 ∀ FOR ALL (universal quantifier)
- U+2203 ∃ THERE EXISTS (existential quantifier)
- U+25A1 □ WHITE SQUARE (necessity)
- U+25C7 ◇ WHITE DIAMOND (possibility)

Triangles are in the Geometric Shapes block (U+25A0–U+25FF):
- U+25B3 △ WHITE UP-POINTING TRIANGLE
- U+25BD ▽ WHITE DOWN-POINTING TRIANGLE

These are well-established Unicode characters with broad font support.

### 3. Codebase Usage Analysis

#### 3.1 LEAN Source Files

Search results show **32 LEAN files** in the codebase, with **always** appearing in 10 LEAN files and **sometimes** in 5 LEAN files:

**Files with `always`**:
1. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean:98` (definition)
2. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean:103` (used in `sometimes` definition)
3. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Axioms.lean:25` (TL axiom comment)
4. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Axioms.lean:81` (comment)
5. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Axioms.lean:98-99` (comments)
6. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Axioms.lean:122` (comment)
7. `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:15` (test comment)
8. `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:85-86` (test cases)
9. `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:89-90` (test cases)

**Files with `sometimes`**:
1. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean:106` (definition)
2. `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean:121-123` (related operator)
3. `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:15` (test comment)
4. `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:88-90` (test cases)
5. `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:97` (test case)

#### 3.2 Test Coverage Analysis

**Location**: `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:85-97`

```lean
-- Test: Derived 'always' temporal operator (future for all times)
example (p : Formula) : p.always = p.future := rfl

-- Test: Derived 'sometimes' temporal operator (∃ future time)
-- Correctly defined as ¬G¬φ = (φ.neg).always.neg
example (p : Formula) : p.sometimes = p.neg.always.neg := rfl

-- Test: Derived 'sometime_future' alias
example (p : Formula) : p.sometime_future = p.sometimes := rfl
```

Tests validate the current definitions using propositional equality (`rfl`).

#### 3.3 Documentation Files

Search shows **always** in 93 files and **sometimes** in 28 files across documentation:

**Key Documentation Files**:
1. `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md` (multiple references)
2. `/home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md` (project overview)
3. `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md` (operator definitions)
4. `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md` (formal specification)
5. `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/TUTORIAL.md` (usage examples)
6. `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/EXAMPLES.md` (code examples)
7. `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/TESTING_STANDARDS.md`
8. `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/development/LEAN_STYLE_GUIDE.md`

### 4. LEAN 4 Notation System Requirements

#### 4.1 Existing Notation Patterns

**Location**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Validity.lean:52,68`

```lean
notation:50 "⊨ " φ:50 => valid φ
notation:50 Γ:50 " ⊨ " φ:50 => semantic_consequence Γ φ
```

**Location**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Derivation.lean:128,133`

```lean
notation:50 Γ " ⊢ " φ => Derivable Γ φ
notation:50 "⊢ " φ => Derivable [] φ
```

These examples show LEAN 4's notation system successfully handles Unicode symbols (⊨, ⊢) with precedence levels.

#### 4.2 Notation Design Options

**Option 1: Prefix Notation** (following modal operators pattern)
```lean
prefix:80 "△" => Formula.always
prefix:80 "▽" => Formula.sometimes
```
Usage: `△p`, `▽q`

**Option 2: Postfix Notation** (following current dot notation pattern)
```lean
postfix:80 "△" => Formula.always
postfix:80 "▽" => Formula.sometimes
```
Usage: `p△`, `q▽` (less intuitive)

**Option 3: Syntax Declaration** (more flexible)
```lean
syntax "△" term : term
syntax "▽" term : term

macro_rules
  | `(△ $φ) => `(Formula.always $φ)
  | `(▽ $φ) => `(Formula.sometimes $φ)
```
Usage: `△ p`, `▽ q`

**Recommendation**: Option 1 (prefix notation) aligns with modal logic convention where operators precede formulas (□p, ◇p).

#### 4.3 Integration with Existing Definitions

Key consideration: The current `always` and `sometimes` are **derived functions**, not primitive constructors. Adding notation will provide syntactic sugar but won't change the underlying representation.

**Implementation Strategy**:
1. Keep existing function definitions unchanged
2. Add notation declarations in `Formula.lean` after function definitions
3. Update documentation to show both notations: `always φ` and `△φ`
4. Maintain backward compatibility by keeping function names accessible

### 5. Related Work: Previous Unicode Standardization

**Reference**: Spec 009 (Unicode Symbol Standardization)

The project recently completed comprehensive Unicode standardization work:
- Fixed 45+ corrupted symbols in README.md
- Created logical operators glossary (`docs/glossary/logical-operators.md`)
- Established Unicode box-drawing standards for file trees
- Updated documentation standards for symbol usage

**Lessons Learned**:
1. UTF-8 encoding must be verified after all edits (`file -b --mime-encoding`)
2. Glossary should be single source of truth for symbol definitions
3. Documentation updates must be systematic across all files
4. Test files require updates to match notation changes

### 6. Semantic Considerations

#### 6.1 Definition Discrepancy

**Critical Issue Identified**: There is a mismatch between the glossary definition and implementation:

- **Glossary** (line 160): `always φ := Past φ ∧ φ ∧ Future φ` (three-time quantifier)
- **Implementation** (Formula.lean:98): `def always (φ : Formula) : Formula := φ.future` (future only)
- **ARCHITECTURE.md** (line 48): Shows three-time quantifier version

**Impact**: The current implementation is NOT "eternal truth" (all times including past and present) but only "henceforth" (all future times from now).

**Resolution Needed**: Either:
1. Update implementation to match glossary (breaking change), OR
2. Update glossary to match implementation (documentation fix)

This discrepancy must be resolved before proceeding with notation changes.

#### 6.2 Perpetuity Principles Impact

The perpetuity principles (P1-P6) use both `always` and `sometimes`:
- P1: `□φ → always φ` (necessity implies perpetuity)
- P2: `sometimes φ → ◇φ` (occurrence implies possibility)
- P3: `□φ → □always φ` (necessity of perpetuity)
- P4: `◇sometimes φ → ◇φ` (possibility of occurrence)
- P5: `◇sometimes φ → always ◇φ` (persistent possibility)
- P6: `sometimes □φ → □always φ` (occurrent necessity is perpetual)

These theorems would benefit from clearer notation, making their logical structure more visible.

## Recommendations

### Recommendation 1: Resolve Definition Discrepancy FIRST

**Priority**: Critical (blocking)

Before adding triangle notation, resolve the semantic mismatch between glossary and implementation:

**Action Items**:
1. Determine intended semantics: Is `always` meant to be "henceforth" (future only) or "eternal truth" (past+present+future)?
2. If "eternal truth" is intended, update implementation to match glossary
3. If "henceforth" is intended, update glossary to match implementation
4. Update ARCHITECTURE.md to reflect chosen semantics
5. Add clarifying comments in code explaining the choice

**Rationale**: Adding notation to an incorrectly defined operator will propagate the error.

### Recommendation 2: Use △ and ▽ with Prefix Notation

**Priority**: High

Implement Unicode triangle operators using prefix notation pattern:

```lean
-- In Logos/Syntax/Formula.lean (after line 106)

/-- Notation for temporal 'always' operator using upward triangle -/
prefix:80 "△" => Formula.always

/-- Notation for temporal 'sometimes' operator using downward triangle -/
prefix:80 "▽" => Formula.sometimes
```

**Rationale**:
- Visual duality: △/▽ mirrors the logical duality (universal/existential)
- Prefix pattern aligns with modal operators □/◇
- Precedence 80 matches modal operators for consistency
- Clear mathematical symbolism: △ suggests upward/universal, ▽ suggests downward/existential

### Recommendation 3: Systematic Documentation Update

**Priority**: High

Update all documentation files in phases:

**Phase 1: Core Documentation**
1. `docs/glossary/logical-operators.md`: Add △/▽ symbols to always/sometimes entries
2. `docs/ARCHITECTURE.md`: Update operator definitions with triangle notation
3. `README.md`: Add triangle symbols to perpetuity principles
4. `CLAUDE.md`: Update quick reference with new notation

**Phase 2: Tutorial and Examples**
5. `docs/TUTORIAL.md`: Show both text and symbol notation
6. `docs/EXAMPLES.md`: Add examples using △/▽ notation
7. `docs/development/LEAN_STYLE_GUIDE.md`: Add style guidelines for triangle operators

**Phase 3: Developer Documentation**
8. `docs/development/TESTING_STANDARDS.md`: Update test examples
9. `docs/development/TACTIC_DEVELOPMENT.md`: Update tactic examples with new notation

### Recommendation 4: Incremental Implementation Strategy

**Priority**: Medium

Implement in careful phases to maintain backward compatibility:

**Phase 1: Add Notation (Non-Breaking)**
- Add prefix notation declarations
- Keep existing function names
- Update only Formula.lean and FormulaTest.lean initially
- Verify build succeeds: `lake build`

**Phase 2: Documentation (Non-Breaking)**
- Update glossary first (source of truth)
- Update ARCHITECTURE.md and README.md
- Show both notations: "always/△" and "sometimes/▽"
- Add examples demonstrating new notation

**Phase 3: Gradual Adoption (Non-Breaking)**
- Update test files to use new notation alongside old
- Update example files in Archive/ directory
- Update tutorial examples
- Maintain both forms during transition period

**Phase 4: Complete Migration (Optional)**
- If desired, deprecate text-based notation
- Update all remaining references to use symbols
- Document migration path for external users

### Recommendation 5: Add Backtick Standards

**Priority**: Medium

Following the existing backtick standard for Unicode symbols (see `.claude/docs/reference/standards/documentation-standards.md`):

**Rule**: In Markdown documentation, all formal Unicode operator symbols must be enclosed in backticks.

**Examples**:
- Correct: "The `△` operator denotes universal temporal quantification"
- Correct: "Perpetuity P1 states `□φ → △φ`"
- Incorrect: "The △ operator denotes..." (missing backticks)
- Incorrect: "Perpetuity P1 states □φ → △φ" (missing backticks)

**Rationale**: Backticks ensure consistent rendering across platforms and clearly distinguish formal symbols from prose.

### Recommendation 6: Testing Requirements

**Priority**: High

Implement comprehensive testing for notation changes:

**Test Categories**:
1. **Notation Parsing Tests**: Verify △ and ▽ parse correctly
2. **Equivalence Tests**: Verify `△p = p.always` and `▽p = p.sometimes`
3. **Rendering Tests**: Verify Unicode symbols display correctly in VS Code
4. **Documentation Tests**: Verify markdown renders symbols correctly
5. **Encoding Tests**: Verify UTF-8 encoding preserved after edits

**Test File Updates Required**:
- `LogosTest/Syntax/FormulaTest.lean`: Add notation tests
- Update existing tests on lines 85-97 to include symbol notation
- Add examples: `example : △p = p.always := rfl`

### Recommendation 7: Consider Alternative: Gradual Introduction

**Priority**: Low (alternative approach)

If full replacement is too disruptive, consider gradual introduction:

**Phase 1: Dual Notation Period**
- Keep `always` and `sometimes` as primary
- Add △ and ▽ as alternative notation
- Document both forms as equally valid
- Let community/team decide preference over time

**Phase 2: Gather Feedback**
- Monitor which notation gets used more
- Collect feedback on readability
- Assess impact on theorem comprehension
- Measure adoption in new proofs

**Phase 3: Converge**
- Based on feedback, either:
  - Make symbols primary (update all docs)
  - Keep text primary (document symbols as optional)
  - Maintain both indefinitely (ensure consistency)

## References

### Codebase Files Analyzed

**LEAN Source Files** (with line numbers):
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Syntax/Formula.lean:94-123` — Current operator definitions
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Axioms.lean:25,81,98-99,122` — Axiom usage in comments
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Validity.lean:52,68` — Notation pattern examples
- `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/ProofSystem/Derivation.lean:128,133` — Notation pattern examples
- `/home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/Syntax/FormulaTest.lean:15,85-97` — Test cases for operators

**Documentation Files**:
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/glossary/logical-operators.md:157-176` — Operator glossary entries
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md:48-49` — Formal language definition
- `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md` — Project overview
- `/home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md` — Development guide
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/TUTORIAL.md` — Usage tutorial
- `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/EXAMPLES.md` — Code examples

**Previous Related Work**:
- `.claude/specs/009_unicode_symbol_standardization/reports/001-unicode-symbol-analysis.md` — Unicode standardization research
- `.claude/specs/009_unicode_symbol_standardization/plans/001-unicode-symbol-standardization-plan.md` — Implementation patterns

### External References

- [Linear temporal logic - Wikipedia](https://en.wikipedia.org/wiki/Linear_temporal_logic) — LTL operator conventions
- [Typesetting LTL in Unicode? - Computer Science Stack Exchange](https://cs.stackexchange.com/questions/115321/typesetting-ltl-in-unicode) — Unicode symbol discussion
- [Typesetting modal logic in LaTeX, Unicode, and HTML](https://www.johndcook.com/blog/2018/10/29/typesetting-modal-logic/) — Modal logic typesetting patterns
- [Mathematical Operators Range: 2200–22FF](https://www.unicode.org/charts/PDF/U2200.pdf) — Unicode operator block specification
- [Nabla symbol - Wikipedia](https://en.wikipedia.org/wiki/Nabla_symbol) — Nabla usage in mathematics

---

**Report Status**: Complete
**Next Steps**: Review recommendations and decide on semantic resolution (Recommendation 1) before proceeding with implementation planning
**Estimated Implementation Effort**: 6-8 hours (assuming semantic resolution favors documentation fix over implementation change)
