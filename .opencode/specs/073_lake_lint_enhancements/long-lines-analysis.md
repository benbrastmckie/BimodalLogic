# Long Lines Analysis

**Date:** 2025-12-15  
**Total Issues:** 169 long lines across 17 files  
**Threshold:** 100 characters

## Summary by File

| File | Issues | Priority |
|------|--------|----------|
| Logos/Core/Theorems/Combinators.lean | 47 | High |
| Logos/Core/Semantics/Truth.lean | 32 | High |
| Logos/Core/Theorems/ModalS5.lean | 21 | High |
| Logos/Core/Theorems/Propositional.lean | 20 | High |
| Logos/Core/Theorems/GeneralizedNecessitation.lean | 8 | Medium |
| Logos/Core/Theorems/Perpetuity/Bridge.lean | 8 | Medium |
| Logos/Core/Theorems/ModalS4.lean | 6 | Medium |
| Logos/Core/Automation/AesopRules.lean | 5 | Medium |
| Logos/Core/Semantics/WorldHistory.lean | 5 | Medium |
| Logos/Core/Automation/Tactics.lean | 3 | Low |
| Logos/Core/ProofSystem/Axioms.lean | 3 | Low |
| Logos/Core/Metalogic/Soundness.lean | 3 | Low |
| Logos/Core/Semantics/TaskFrame.lean | 3 | Low |
| Logos/Core/Theorems/Perpetuity/Principles.lean | 2 | Low |
| Logos/Core/Theorems/Perpetuity/Helpers.lean | 1 | Low |
| Logos/Core/Metalogic/DeductionTheorem.lean | 1 | Low |
| Logos/Core/Semantics/TaskModel.lean | 1 | Low |

**Total:** 169 issues

## Pattern Analysis

After examining the long lines, they fall into these categories:

### Category 1: Long Proof Steps (Most Common - ~60%)

**Pattern:** Chained function applications in proofs

**Example:**
```lean
-- Line 90 (121 chars)
have h4 : ⊢ (A.imp B).imp (A.imp C) := Derivable.modus_ponens [] (A.imp (B.imp C)) ((A.imp B).imp (A.imp C)) k_axiom h3
```

**Characteristics:**
- Multiple nested function calls
- Long type signatures in `have` statements
- Chained `Derivable.modus_ponens` or similar
- Typically 105-140 characters

**Frequency:** ~100 instances

### Category 2: Documentation Comments (Second Most Common - ~20%)

**Pattern:** Long docstring lines or inline comments

**Example:**
```lean
-- Line 34 (130 chars)
* [Combinators.lean](Combinators.lean) - Combinator infrastructure (imp_trans, identity, b_combinator, theorem_flip, pairing, dni)
```

**Characteristics:**
- Markdown links with descriptions
- Lists of functions/theorems
- Explanatory text
- Typically 101-130 characters

**Frequency:** ~35 instances

### Category 3: Theorem Signatures (Third Most Common - ~15%)

**Pattern:** Long theorem declarations with multiple parameters

**Example:**
```lean
-- Hypothetical (not from actual code)
theorem very_long_theorem_name (φ ψ χ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) : Γ ⊢ φ ∧ ψ ∧ χ := by
```

**Characteristics:**
- Multiple parameters
- Long type annotations
- Complex return types
- Typically 105-125 characters

**Frequency:** ~25 instances

### Category 4: Import/Module References (~5%)

**Pattern:** Long import statements or module paths

**Characteristics:**
- Nested module paths
- Multiple imports on one line
- Typically 101-110 characters

**Frequency:** ~9 instances

## Severity Distribution

### Slightly Over (101-110 chars): 45 instances
- Easy to fix (minor adjustments)
- Often just need one line break

### Moderately Over (111-125 chars): 78 instances
- Require thoughtful refactoring
- May need intermediate variables

### Significantly Over (126-150 chars): 44 instances
- Require substantial refactoring
- Multiple line breaks needed
- Consider extracting helper lemmas

### Extremely Over (>150 chars): 2 instances
- Line 110 in GeneralizedNecessitation.lean (150 chars)
- Requires major refactoring

## Files Requiring Most Attention

### 1. Logos/Core/Theorems/Combinators.lean (47 issues)

**Analysis:**
- Mostly Category 1 (long proof steps)
- Many chained `Derivable.modus_ponens` calls
- Concentrated in lines 337-447 (proof-heavy section)

**Strategy:**
- Use intermediate `have` statements
- Extract common patterns into helper lemmas
- Break long chains into multiple steps

### 2. Logos/Core/Semantics/Truth.lean (32 issues)

**Analysis:**
- Mix of Categories 1 and 3
- Complex semantic definitions
- Long type signatures

**Strategy:**
- Break theorem signatures across multiple lines
- Use intermediate definitions
- Simplify complex expressions

### 3. Logos/Core/Theorems/ModalS5.lean (21 issues)

**Analysis:**
- Primarily Category 1
- Modal logic proofs with nested operators
- Long tactic applications

**Strategy:**
- Use `calc` blocks for equational reasoning
- Break proof steps into smaller pieces
- Extract repeated patterns

### 4. Logos/Core/Theorems/Propositional.lean (20 issues)

**Analysis:**
- Mix of Categories 1 and 2
- Documentation comments and proof steps
- Some very long lines (>120 chars)

**Strategy:**
- Break documentation into multiple lines
- Simplify proof steps
- Use helper lemmas

## Recommended Fix Order

Based on impact and difficulty:

1. **Combinators.lean** (47 issues) - Highest impact, moderate difficulty
2. **Truth.lean** (32 issues) - High impact, higher difficulty
3. **ModalS5.lean** (21 issues) - High impact, moderate difficulty
4. **Propositional.lean** (20 issues) - High impact, moderate difficulty
5. **GeneralizedNecessitation.lean** (8 issues) - Medium impact, includes 150-char line
6. **Perpetuity/Bridge.lean** (8 issues) - Medium impact, moderate difficulty
7. **ModalS4.lean** (6 issues) - Medium impact, low difficulty
8. **AesopRules.lean** (5 issues) - Low impact, low difficulty
9. **WorldHistory.lean** (5 issues) - Low impact, low difficulty
10. **Remaining 8 files** (17 issues total) - Low impact, low difficulty

## Common Refactoring Patterns Needed

### Pattern 1: Extract Intermediate Have

**Before:**
```lean
exact Derivable.modus_ponens [] (A.imp B) (A.imp C) (Derivable.axiom [] _ (Axiom.prop_k A B C)) h1
```

**After:**
```lean
have k_axiom : ⊢ (A.imp B).imp (A.imp C) := 
  Derivable.axiom [] _ (Axiom.prop_k A B C)
exact Derivable.modus_ponens [] (A.imp B) (A.imp C) k_axiom h1
```

### Pattern 2: Break Theorem Signature

**Before:**
```lean
theorem long_name (φ ψ χ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) : Γ ⊢ φ ∧ ψ := by
```

**After:**
```lean
theorem long_name
    (φ ψ χ : Formula)
    (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) :
    Γ ⊢ φ ∧ ψ := by
```

### Pattern 3: Break Documentation

**Before:**
```lean
* [File.lean](File.lean) - Long description with many items (item1, item2, item3, item4)
```

**After:**
```lean
* [File.lean](File.lean) - Long description with many items
  (item1, item2, item3, item4)
```

## Estimated Effort

- **Category 1 (Long Proof Steps):** ~100 lines × 2 min = 200 min (3.3 hours)
- **Category 2 (Documentation):** ~35 lines × 1 min = 35 min (0.6 hours)
- **Category 3 (Theorem Signatures):** ~25 lines × 2 min = 50 min (0.8 hours)
- **Category 4 (Imports):** ~9 lines × 1 min = 9 min (0.15 hours)

**Total Estimated Time:** ~4.85 hours

**With testing and verification:** ~5-6 hours

## Success Metrics

- ✅ All 169 long lines fixed
- ✅ `lake lint` shows 0 long line violations
- ✅ `lake build` succeeds
- ✅ `lake test` passes
- ✅ No functionality broken
- ✅ Code remains readable and maintainable

## Next Steps

1. Create refactoring guidelines document
2. Start with Combinators.lean (highest impact)
3. Fix files in priority order
4. Verify after each file
5. Commit after each file with descriptive message
