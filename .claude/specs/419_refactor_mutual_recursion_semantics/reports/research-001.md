# Research Report: Task #419

**Task**: Refactor mutual recursion in Foundation/Semantics.lean
**Date**: 2026-01-12
**Focus**: Evaluate approaches to eliminate mutual recursion performance overhead

## Summary

The `verifies`/`falsifies` mutual recursion can be refactored into a single function using a polarity flag (Bool or custom type). This eliminates Lean's internal `PSum`-based compilation of mutual recursion and enables true structural recursion on `ConstitutiveFormula`. The recommended approach uses an inductive `Polarity` type for type safety and clearer semantics, with wrapper definitions for backward compatibility.

## Findings

### 1. Current Mutual Recursion Structure

**Location**: `Theories/Logos/SubTheories/Foundation/Semantics.lean:47-139`

The mutual block contains two functions with 9 cases each:

| Function | Cases | Cross-Calls |
|----------|-------|-------------|
| `verifies` | 9 | Calls `falsifies` in `neg`, `ident` |
| `falsifies` | 9 | Calls `verifies` in `neg`, `ident` |

**Mutual call pattern**:
```lean
-- In verifies:
| ConstitutiveFormula.neg φ => falsifies M σ s φ  -- swap to falsifies
| ConstitutiveFormula.ident φ ψ =>
    ... (∀ t, verifies M σ t φ ↔ verifies M σ t ψ) ∧
        (∀ t, falsifies M σ t φ ↔ falsifies M σ t ψ)

-- In falsifies:
| ConstitutiveFormula.neg φ => verifies M σ s φ  -- swap to verifies
| ConstitutiveFormula.ident φ ψ => ... (similarly uses both)
```

### 2. How Lean Compiles Mutual Recursion

Per [Lean's documentation on recursive definitions](https://lean-lang.org/doc/reference/latest/Definitions/Recursive-Definitions/):

> An equivalent non-mutual function is constructed by combining the function's arguments using `PSum`, and pattern-matching on that sum type in the result type and the body.

This means `verifies` and `falsifies` are internally compiled as:
```lean
-- Pseudo-code of internal representation
def verifies_falsifies_combined
    (args : PSum VerifiesArgs FalsifiesArgs) : Prop :=
  match args with
  | .inl vArgs => -- verifies logic
  | .inr fArgs => -- falsifies logic
```

**Performance implications**:
- Extra pattern matching on `PSum` at every call
- Larger proof terms for well-founded recursion
- Reduced definitional equality opportunities

### 3. Refactoring Approach: Polarity Flag

#### Option A: Bool Flag

```lean
/-- Unified truthmaker evaluation with boolean flag -/
def truthmaker (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (isVerify : Bool) (s : M.frame.State) : ConstitutiveFormula → Prop
  | ConstitutiveFormula.neg φ =>
      truthmaker M σ (!isVerify) s φ  -- Flip the flag
  | ConstitutiveFormula.and φ ψ =>
      if isVerify then
        ∃ t u, s = M.frame.fusion t u ∧
          truthmaker M σ true t φ ∧ truthmaker M σ true u ψ
      else
        truthmaker M σ false s φ ∨ truthmaker M σ false s ψ ∨
        ∃ t u, s = M.frame.fusion t u ∧
          truthmaker M σ false t φ ∧ truthmaker M σ false u ψ
  -- ... other cases
```

**Pros**: Simple, uses built-in `Bool`
**Cons**: `if-then-else` in every case, less readable, Bool semantics unclear

#### Option B: Custom Polarity Type (Recommended)

```lean
/-- Polarity for verification vs falsification -/
inductive Polarity where
  | verify : Polarity
  | falsify : Polarity

/-- Swap polarity -/
def Polarity.swap : Polarity → Polarity
  | .verify => .falsify
  | .falsify => .verify

/-- Unified evaluation parameterized by polarity -/
def eval (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (pol : Polarity) (s : M.frame.State) : ConstitutiveFormula → Prop
  | ConstitutiveFormula.atom p =>
      match pol with
      | .verify => s ∈ (M.interp.getSentenceLetter p).verifiers
      | .falsify => s ∈ (M.interp.getSentenceLetter p).falsifiers
  | ConstitutiveFormula.neg φ =>
      eval M σ pol.swap s φ
  | ConstitutiveFormula.and φ ψ =>
      match pol with
      | .verify => ∃ t u, s = M.frame.fusion t u ∧
          eval M σ .verify t φ ∧ eval M σ .verify u ψ
      | .falsify => eval M σ .falsify s φ ∨ eval M σ .falsify s ψ ∨
          ∃ t u, s = M.frame.fusion t u ∧
            eval M σ .falsify t φ ∧ eval M σ .falsify u ψ
  -- ... other cases

/-- Verification as specialization -/
def verifies (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (s : M.frame.State) (φ : ConstitutiveFormula) : Prop :=
  eval M σ .verify s φ

/-- Falsification as specialization -/
def falsifies (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (s : M.frame.State) (φ : ConstitutiveFormula) : Prop :=
  eval M σ .falsify s φ
```

**Pros**:
- Type-safe polarity (can't confuse with other Bools)
- Self-documenting code
- Backward-compatible API via wrappers
- Clean pattern matching in each case

**Cons**:
- Introduces new type
- Slightly more verbose

### 4. Recursion Type Analysis

With the polarity flag approach:

| Recursion Type | Applicable? | Notes |
|----------------|-------------|-------|
| Structural | Yes | Recursion follows `ConstitutiveFormula` structure |
| Well-founded | Also works | But structural is cleaner |

The `eval` function recurses only on subformulas of `φ`:
- `neg φ` → recurses on `φ`
- `and φ ψ` → recurses on `φ` and `ψ`
- `ident φ ψ` → recurses on `φ` and `ψ`
- etc.

This is textbook structural recursion on `ConstitutiveFormula`.

### 5. Impact on Existing Theorems

The following theorems in `BasicTheorems` section would need updates:

| Theorem | Change Required |
|---------|----------------|
| `neg_verifies_iff_falsifies` | Becomes definitionally true via `Polarity.swap` |
| `neg_falsifies_iff_verifies` | Becomes definitionally true via `Polarity.swap` |
| `double_neg_verifies` | Proof simplifies (swap ∘ swap = id) |
| `bot_not_verified` | Minor adjustment to use `eval` |
| `top_verified` | Minor adjustment to use `eval` |
| `bot_falsified_iff_null` | Minor adjustment to use `eval` |
| `top_falsified_iff_full` | Minor adjustment to use `eval` |

### 6. The `ident` Case Complication

The `ident` case is special because it quantifies over all states for both verification and falsification:

```lean
| ConstitutiveFormula.ident φ ψ =>
    s = M.frame.null ∧
    (∀ t, verifies M σ t φ ↔ verifies M σ t ψ) ∧
    (∀ t, falsifies M σ t φ ↔ falsifies M σ t ψ)
```

With the polarity approach:
```lean
| ConstitutiveFormula.ident φ ψ =>
    match pol with
    | .verify =>
        s = M.frame.null ∧
        (∀ t, eval M σ .verify t φ ↔ eval M σ .verify t ψ) ∧
        (∀ t, eval M σ .falsify t φ ↔ eval M σ .falsify t ψ)
    | .falsify =>
        s = M.frame.null ∧
        (¬(∀ t, eval M σ .verify t φ ↔ eval M σ .verify t ψ) ∨
         ¬(∀ t, eval M σ .falsify t φ ↔ eval M σ .falsify t ψ))
```

This still calls `eval` with both polarities, but that's fine—it's still structural recursion on the formula.

### 7. Expected Performance Benefits

| Aspect | Before (Mutual) | After (Polarity) |
|--------|-----------------|------------------|
| Internal structure | `PSum`-based | Direct structural recursion |
| Definitional equality | Limited (well-founded) | Full structural |
| Proof term size | Larger (WF proofs) | Smaller |
| Unfolding cost | Higher | Lower |

## Recommendations

### Implementation Strategy

1. **Define `Polarity` type** with `verify`/`falsify` constructors and `swap` function

2. **Implement `eval`** as single recursive function on `ConstitutiveFormula`

3. **Define `verifies`/`falsifies` as abbreviations** to maintain API compatibility:
   ```lean
   abbrev verifies ... := eval M σ .verify s φ
   abbrev falsifies ... := eval M σ .falsify s φ
   ```

4. **Update theorems** in `BasicTheorems` section (most become simpler)

5. **Update `content` function** to use new definitions

6. **Add `@[simp]` lemmas** for `Polarity.swap`:
   ```lean
   @[simp] lemma swap_verify : Polarity.swap .verify = .falsify := rfl
   @[simp] lemma swap_falsify : Polarity.swap .falsify = .verify := rfl
   @[simp] lemma swap_swap (p : Polarity) : p.swap.swap = p := by cases p <;> rfl
   ```

### Alternative: Keep Mutual with `@[irreducible]`

If the refactoring is deemed too disruptive, a lighter fix is:
```lean
@[irreducible]
mutual
def verifies ...
def falsifies ...
end
```

This prevents unfolding during elaboration but doesn't address the underlying `PSum` overhead.

## References

- [Recursive Definitions in Lean](https://lean-lang.org/blog/2024-1-11-recursive-definitions-in-lean/) - Lean FRO blog
- [Lean 4 Reference: Recursive Definitions](https://lean-lang.org/doc/reference/latest/Definitions/Recursive-Definitions/)
- [Well-Founded Recursion](https://lean-lang.org/doc/reference/latest/Recursive-Definitions/Well-Founded-Recursion/)
- Task 400 research report - Parent performance investigation

## Next Steps

1. Create implementation plan with phased approach
2. Implement `Polarity` type and `eval` function
3. Update `verifies`/`falsifies` as abbreviations
4. Update theorems in `BasicTheorems`
5. Verify build performance improvement
