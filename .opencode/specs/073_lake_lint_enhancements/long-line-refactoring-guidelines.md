# Long Line Refactoring Guidelines

**Date:** 2025-12-15  
**Purpose:** Standard patterns for fixing lines >100 characters  
**Target:** 169 long lines across 17 files

## General Principles

1. **Preserve Functionality:** Never change logic, only formatting
2. **Maintain Readability:** Refactored code should be easier to read
3. **Follow LEAN Conventions:** Use standard LEAN 4 formatting
4. **Test After Each Change:** Run `lake build` and `lake test`
5. **Commit Frequently:** One commit per file

## Category 1: Long Proof Steps

### Pattern 1.1: Extract Intermediate `have`

**When to Use:**
- Chained function applications
- Nested `Derivable.modus_ponens` calls
- Complex expressions in proof steps

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

**Benefits:**
- Clearer proof structure
- Named intermediate steps
- Easier to debug

### Pattern 1.2: Use `calc` for Equational Reasoning

**When to Use:**
- Multiple equality/equivalence steps
- Transitive chains
- Step-by-step derivations

**Before:**
```lean
have h : A = B := trans (trans (eq1 A) (eq2 B)) (eq3 C)
```

**After:**
```lean
have h : A = B := calc
  A = X := eq1 A
  _ = Y := eq2 B
  _ = B := eq3 C
```

**Benefits:**
- Shows reasoning steps clearly
- Easier to verify correctness
- Self-documenting

### Pattern 1.3: Break Long Tactic Applications

**When to Use:**
- Multiple tactic arguments
- Long tactic sequences
- Complex `by` blocks

**Before:**
```lean
theorem foo : A → B := by intro h; apply bar; exact baz h (qux h) (quux h)
```

**After:**
```lean
theorem foo : A → B := by
  intro h
  apply bar
  exact baz h (qux h) (quux h)
```

**Benefits:**
- One tactic per line
- Easier to step through
- Clear proof structure

## Category 2: Documentation Comments

### Pattern 2.1: Break Long Docstrings

**When to Use:**
- Docstrings >100 characters
- Lists of items
- Long descriptions

**Before:**
```lean
/-- This theorem proves that the modal operator distributes over implication in S5 modal logic --/
```

**After:**
```lean
/--
This theorem proves that the modal operator distributes over implication
in S5 modal logic.
--/
```

**Benefits:**
- Easier to read
- Standard docstring format
- Better for documentation generation

### Pattern 2.2: Break Inline Comments

**When to Use:**
- Long inline comments
- Lists in comments
- Multi-part explanations

**Before:**
```lean
-- This applies the K axiom, then uses modus ponens twice, and finally applies necessitation
```

**After:**
```lean
-- This applies the K axiom, then uses modus ponens twice,
-- and finally applies necessitation
```

**Benefits:**
- Maintains comment flow
- Easier to read
- Consistent formatting

### Pattern 2.3: Break Markdown Links

**When to Use:**
- Long file references
- Lists of links
- Descriptions with links

**Before:**
```lean
* [Combinators.lean](Combinators.lean) - Combinator infrastructure (imp_trans, identity, b_combinator, theorem_flip, pairing, dni)
```

**After:**
```lean
* [Combinators.lean](Combinators.lean) - Combinator infrastructure
  (imp_trans, identity, b_combinator, theorem_flip, pairing, dni)
```

**Benefits:**
- Link remains on first line
- Description continues on next line
- Maintains markdown formatting

## Category 3: Theorem Signatures

### Pattern 3.1: Break Parameter Lists

**When to Use:**
- Multiple parameters
- Long type annotations
- Complex parameter types

**Before:**
```lean
theorem long_name (φ ψ χ : Formula) (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) : Γ ⊢ φ ∧ ψ ∧ χ := by
```

**After:**
```lean
theorem long_name
    (φ ψ χ : Formula)
    (h1 : Γ ⊢ φ) (h2 : Γ ⊢ ψ) (h3 : Γ ⊢ χ) :
    Γ ⊢ φ ∧ ψ ∧ χ := by
```

**Indentation Rules:**
- Parameters: 4 spaces from `theorem`
- Return type: 4 spaces, on separate line
- `:=` on same line as return type

**Benefits:**
- Clear parameter grouping
- Easy to see return type
- Standard LEAN format

### Pattern 3.2: Break Long Return Types

**When to Use:**
- Complex return types
- Nested implications
- Long type expressions

**Before:**
```lean
theorem foo (A B C : Formula) : (A → B) → (B → C) → (A → C) := by
```

**After:**
```lean
theorem foo (A B C : Formula) :
    (A → B) → (B → C) → (A → C) := by
```

**Benefits:**
- Return type stands out
- Easier to parse
- Consistent formatting

### Pattern 3.3: Break `where` Clauses

**When to Use:**
- Long structure definitions
- Multiple `where` bindings
- Complex local definitions

**Before:**
```lean
def foo : Type where bar : Nat; baz : String; qux : Bool := { bar := 0, baz := "", qux := true }
```

**After:**
```lean
def foo : Type where
  bar : Nat
  baz : String
  qux : Bool := { bar := 0, baz := "", qux := true }
```

**Benefits:**
- Clear field definitions
- One field per line
- Standard structure format

## Category 4: Import/Module References

### Pattern 4.1: Break Long Imports

**When to Use:**
- Multiple imports from same module
- Long module paths
- Grouped imports

**Before:**
```lean
import Logos.Core.Syntax.Formula Logos.Core.Syntax.Context Logos.Core.ProofSystem.Axioms
```

**After:**
```lean
import Logos.Core.Syntax.Formula
import Logos.Core.Syntax.Context
import Logos.Core.ProofSystem.Axioms
```

**Benefits:**
- One import per line
- Easier to see dependencies
- Standard LEAN format

## Special Cases

### Special Case 1: Extremely Long Lines (>150 chars)

**Strategy:**
1. Identify the core issue (usually deeply nested calls)
2. Extract multiple intermediate steps
3. Consider creating a helper lemma
4. Break into 3+ lines if necessary

**Example:**
```lean
-- Before (150+ chars)
have h : ⊢ A := Derivable.modus_ponens [] X Y (Derivable.modus_ponens [] Z W (Derivable.axiom [] _ ax1) h1) (Derivable.axiom [] _ ax2)

-- After
have h_inner : ⊢ W := Derivable.modus_ponens [] Z W (Derivable.axiom [] _ ax1) h1
have h_outer : ⊢ Y := Derivable.modus_ponens [] X Y h_inner (Derivable.axiom [] _ ax2)
have h : ⊢ A := h_outer
```

### Special Case 2: Lines Just Over Limit (101-105 chars)

**Strategy:**
1. Look for simple breaks (after commas, operators)
2. Minimal changes preferred
3. Don't over-engineer

**Example:**
```lean
-- Before (102 chars)
theorem foo (A B : Formula) : A → B := by intro h; exact bar h

-- After (simple break)
theorem foo (A B : Formula) : A → B := by
  intro h; exact bar h
```

### Special Case 3: Proof-Heavy Sections

**Strategy:**
1. Fix all long lines in the section
2. Look for repeated patterns
3. Consider extracting common lemmas
4. Maintain proof flow

**Example:**
```lean
-- If you see this pattern repeated:
have h1 : ⊢ A := Derivable.modus_ponens [] X Y ax1 h
have h2 : ⊢ B := Derivable.modus_ponens [] X Y ax2 h
have h3 : ⊢ C := Derivable.modus_ponens [] X Y ax3 h

-- Consider extracting:
def apply_mp (ax : Axiom) (h : ⊢ X) : ⊢ Y :=
  Derivable.modus_ponens [] X Y ax h

have h1 : ⊢ A := apply_mp ax1 h
have h2 : ⊢ B := apply_mp ax2 h
have h3 : ⊢ C := apply_mp ax3 h
```

## Verification Checklist

After refactoring each file:

- [ ] Run `lake build <file>` - Must succeed
- [ ] Run `lake test` - All tests must pass
- [ ] Check `lake lint` - Long line count should decrease
- [ ] Review diff - Changes should be formatting only
- [ ] Verify readability - Code should be clearer
- [ ] Commit with message: `style: fix long lines in <file>`

## Common Mistakes to Avoid

### ❌ Mistake 1: Changing Logic

```lean
-- WRONG: Changed the proof
have h : ⊢ A := different_proof  -- Don't change the proof!

-- RIGHT: Only changed formatting
have h : ⊢ A := 
  same_proof_just_formatted
```

### ❌ Mistake 2: Breaking Indentation

```lean
-- WRONG: Inconsistent indentation
theorem foo
  (A : Formula)
    (B : Formula) :  -- Inconsistent!
  A → B := by

-- RIGHT: Consistent 4-space indentation
theorem foo
    (A : Formula)
    (B : Formula) :
    A → B := by
```

### ❌ Mistake 3: Over-Refactoring

```lean
-- WRONG: Made it harder to read
have h1 : ⊢ A := x
have h2 : ⊢ B := y
have h3 : ⊢ C := z
have h4 : ⊢ D := h1
have h5 : ⊢ E := h2  -- Too many intermediate steps!

-- RIGHT: Balance clarity and conciseness
have h_ab : ⊢ A ∧ B := ⟨x, y⟩
have h : ⊢ E := use_ab h_ab z
```

### ❌ Mistake 4: Breaking Semantic Groups

```lean
-- WRONG: Split related parameters
theorem foo
    (A : Formula)
    (B : Formula)  -- A and B should stay together
    (h : A → B) :
    ...

-- RIGHT: Keep related parameters together
theorem foo
    (A B : Formula)
    (h : A → B) :
    ...
```

## File-Specific Notes

### Combinators.lean (47 issues)
- Heavy use of `Derivable.modus_ponens`
- Extract intermediate `have` statements
- Lines 337-447 are proof-heavy
- Consider helper lemmas for repeated patterns

### Truth.lean (32 issues)
- Complex semantic definitions
- Break theorem signatures carefully
- Preserve semantic meaning
- Test thoroughly after changes

### ModalS5.lean (21 issues)
- Modal logic proofs
- Use `calc` for modal equivalences
- Break nested modal operators
- Maintain proof structure

### Propositional.lean (20 issues)
- Mix of documentation and proofs
- Fix documentation first (easier)
- Then tackle proof steps
- Watch for combinator usage

## Estimated Time per File

| File | Issues | Est. Time | Difficulty |
|------|--------|-----------|------------|
| Combinators.lean | 47 | 90 min | Medium |
| Truth.lean | 32 | 75 min | High |
| ModalS5.lean | 21 | 45 min | Medium |
| Propositional.lean | 20 | 40 min | Medium |
| GeneralizedNecessitation.lean | 8 | 20 min | Medium |
| Perpetuity/Bridge.lean | 8 | 20 min | Low |
| ModalS4.lean | 6 | 15 min | Low |
| Others (10 files) | 27 | 45 min | Low |

**Total:** ~5.5 hours

## Success Criteria

- ✅ All 169 long lines fixed
- ✅ Zero long line violations in `lake lint`
- ✅ All builds succeed
- ✅ All tests pass
- ✅ Code is more readable
- ✅ No functionality changed
- ✅ Commits are clean and descriptive

## Next Steps

1. Start with Combinators.lean (highest impact)
2. Work through files in priority order
3. Commit after each file
4. Run full test suite after every 3-4 files
5. Final verification with `lake lint` and `lake test`
