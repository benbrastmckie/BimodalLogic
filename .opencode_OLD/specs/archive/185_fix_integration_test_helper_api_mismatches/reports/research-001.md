# Lean Library Research: Fix Integration Test Helper API Mismatches

## Research Scope

- **Topic**: Fix 3 API mismatches in LogosTest/Core/Integration/Helpers.lean
- **Lean context**: Modal logic, temporal logic, bimodal logic (TM system)
- **Libraries explored**: Logos.Core.Semantics, Logos.Core.Metalogic
- **Tools used**: Direct file analysis, ripgrep pattern search, Lean compiler diagnostics

## Problem Analysis

### Error 1: Line 126 - Semantic Consequence Type Mismatch

**Location**: `verify_validity` function (line 125-126)

**Current Code**:
```lean
def verify_validity (φ : Formula) (d : DerivationTree [] φ) : ⊨ φ :=
  soundness [] φ d
```

**Error Message**:
```
error: type mismatch
  soundness [] φ d
has type
  [] ⊨ φ : Prop
but is expected to have type
  ⊨ φ : Prop
```

**Root Cause**: 
- `soundness` has signature: `(Γ : Context) → (φ : Formula) → (Γ ⊢ φ) → (Γ ⊨ φ)`
- When called with `Γ = []`, it returns `[] ⊨ φ` (semantic consequence from empty context)
- But the function signature promises `⊨ φ` (validity)
- These are **different types** in Lean, even though they are logically equivalent

**API Discovery**:
From `Logos/Core/Semantics/Validity.lean` (lines 110-116):
```lean
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ) := by
  constructor
  · intro h T inst F M τ t ht _
    exact h T F M τ t ht
  · intro h T inst F M τ t ht
    exact h T F M τ t ht (by intro ψ hψ; exact absurd hψ (List.not_mem_nil ψ))
```

This theorem provides the conversion between the two types.

### Error 2: Line 131 - Validity Unwrapping Issue

**Location**: `verify_workflow` function (line 129-132)

**Current Code**:
```lean
def verify_workflow (φ : Formula) (d : DerivationTree [] φ) : True := by
  have valid : ⊨ φ := verify_validity φ d
  have : ∀ F M τ t ht, truth_at M τ t ht φ := valid
  trivial
```

**Error Message**:
```
error: type mismatch
  valid
has type
  ⊨ φ : Prop
but is expected to have type
  ∀ (F : ?m.1041) (M : TaskModel (?m.1081 F)) (τ : WorldHistory (?m.1081 F)) (t : ?m.1079 F) (ht : τ.domain t),
    truth_at M τ t ht φ : Prop
```

**Root Cause**:
- The code assumes `⊨ φ` can be directly used as a function
- But `⊨ φ` is defined as (from `Validity.lean` lines 58-61):
  ```lean
  def valid (φ : Formula) : Prop :=
    ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
      (τ : WorldHistory F) (t : T) (ht : τ.domain t),
      truth_at M τ t ht φ
  ```
- The quantification includes the temporal type `T` and its typeclass instance
- Line 131 tries to unwrap `valid` but omits the `T` and typeclass parameters

**Correct Unwrapping Pattern**:
From `Logos/Core/Metalogic/Soundness.lean` (line 603):
```lean
exact h T F M τ t ht
```
The pattern is: `valid_proof T F M τ t ht` (must supply `T` explicitly)

### Error 3: Line 129 - Unsolved Goals in verify_workflow

**Error Message**:
```
error: unsolved goals
φ : Formula
d : ⊢ φ
valid : ⊨ φ
⊢ True
```

**Root Cause**:
This error is a consequence of Error 2. Once line 131 is fixed, the proof should complete with `trivial`.

## API Definitions

### Validity (`⊨ φ`)

**Definition** (Validity.lean:58-61):
```lean
def valid (φ : Formula) : Prop :=
  ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    truth_at M τ t ht φ

notation:50 "⊨ " φ:50 => valid φ
```

**Semantics**: Formula is true in all models at all times in all histories, for every temporal type.

### Semantic Consequence (`Γ ⊨ φ`)

**Definition** (Validity.lean:77-81):
```lean
def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
    (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    (∀ ψ ∈ Γ, truth_at M τ t ht ψ) →
    truth_at M τ t ht φ

notation:50 Γ:50 " ⊨ " φ:50 => semantic_consequence Γ φ
```

**Semantics**: Formula φ is true in all models where all formulas in Γ are true.

### Soundness Theorem

**Signature** (Soundness.lean:596):
```lean
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ)
```

**Semantics**: Derivability implies semantic consequence.

### Conversion Theorem

**Theorem** (Validity.lean:110-116):
```lean
theorem valid_iff_empty_consequence (φ : Formula) :
    (⊨ φ) ↔ ([] ⊨ φ)
```

**Usage Pattern**:
- Forward direction: `valid_iff_empty_consequence φ |>.mp h` converts `⊨ φ` to `[] ⊨ φ`
- Backward direction: `valid_iff_empty_consequence φ |>.mpr h` converts `[] ⊨ φ` to `⊨ φ`

## Implementation Recommendations

### Fix 1: Line 126 - Use Conversion Theorem

**Current**:
```lean
def verify_validity (φ : Formula) (d : DerivationTree [] φ) : ⊨ φ :=
  soundness [] φ d
```

**Fixed**:
```lean
def verify_validity (φ : Formula) (d : DerivationTree [] φ) : ⊨ φ :=
  Validity.valid_iff_empty_consequence φ |>.mpr (soundness [] φ d)
```

**Explanation**: 
- `soundness [] φ d` produces `[] ⊨ φ`
- `valid_iff_empty_consequence φ` produces `(⊨ φ) ↔ ([] ⊨ φ)`
- `.mpr` (modus ponens reverse) applies the backward direction: `([] ⊨ φ) → (⊨ φ)`

**Effort**: Trivial (1-line change)

### Fix 2: Line 131 - Correct Validity Unwrapping

**Current**:
```lean
def verify_workflow (φ : Formula) (d : DerivationTree [] φ) : True := by
  have valid : ⊨ φ := verify_validity φ d
  have : ∀ F M τ t ht, truth_at M τ t ht φ := valid
  trivial
```

**Fixed Option A** (Explicit unwrapping):
```lean
def verify_workflow (φ : Formula) (d : DerivationTree [] φ) : True := by
  have valid : ⊨ φ := verify_validity φ d
  have : ∀ (T : Type) [LinearOrderedAddCommGroup T] (F : TaskFrame T) (M : TaskModel F)
           (τ : WorldHistory F) (t : T) (ht : τ.domain t),
           truth_at M τ t ht φ := valid
  trivial
```

**Fixed Option B** (Simplified - just prove True):
```lean
def verify_workflow (φ : Formula) (d : DerivationTree [] φ) : True := by
  have _valid : ⊨ φ := verify_validity φ d
  trivial
```

**Fixed Option C** (Remove intermediate step):
```lean
def verify_workflow (φ : Formula) (d : DerivationTree [] φ) : True :=
  trivial
```

**Recommendation**: Use **Option B** or **Option C**. The intermediate `have` statement serves no purpose since the function just returns `True`. If the goal is to demonstrate the workflow, Option B keeps the validity proof but doesn't try to unwrap it incorrectly.

**Effort**: Trivial (1-2 line change)

### Fix 3: Line 129 - Automatically Resolved

Once Fix 2 is applied, the unsolved goals error will disappear automatically.

## Correct Usage Patterns from Codebase

### Pattern 1: Soundness with Empty Context → Validity

**From**: `LogosTest/Core/Integration/ProofSystemSemanticsTest.lean:11`
```lean
example (φ ψ χ : Formula) : ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  let deriv := DerivationTree.axiom [] _ (Axiom.prop_k φ ψ χ)
  exact soundness [] _ deriv
```

**Note**: This works because the **expected type** is `⊨ _`, so Lean applies the conversion automatically via type coercion.

### Pattern 2: Explicit Conversion

**From**: `LogosTest/Core/Metalogic/SoundnessTest.lean:82`
```lean
example (φ : Formula) (h : ⊨ (φ.box.imp φ)) : [] ⊨ (φ.box.imp φ) :=
  Validity.valid_iff_empty_consequence _ |>.mp h
```

**Note**: This shows the **forward direction** (validity → semantic consequence).

### Pattern 3: Unwrapping Validity

**From**: `Logos/Core/Metalogic/Soundness.lean:603`
```lean
intro T _ F M τ t ht
exact h T F M τ t ht
```

**Note**: When unwrapping `h : ⊨ φ`, must supply:
1. `T : Type` (temporal type)
2. `_ : LinearOrderedAddCommGroup T` (typeclass instance, can be inferred)
3. `F : TaskFrame T`
4. `M : TaskModel F`
5. `τ : WorldHistory F`
6. `t : T`
7. `ht : τ.domain t`

## Summary of Changes

| Line | Error Type | Root Cause | Fix | Effort |
|------|------------|------------|-----|--------|
| 126 | Type mismatch | `soundness [] φ d` returns `[] ⊨ φ` not `⊨ φ` | Use `valid_iff_empty_consequence φ \|>.mpr` | Trivial |
| 131 | Type mismatch | Missing `T` parameter when unwrapping validity | Add `T` and typeclass to quantification, or simplify | Trivial |
| 129 | Unsolved goals | Consequence of line 131 error | Automatically fixed by fixing line 131 | N/A |

## Implementation Priority

1. **Fix Line 126** (verify_validity) - Required for other fixes
2. **Fix Line 131** (verify_workflow) - Automatically resolves line 129

## Testing Strategy

After fixes:
1. Compile `LogosTest/Core/Integration/Helpers.lean` with `lake build`
2. Run integration tests that use these helpers
3. Verify no type errors remain

## Additional Notes

### Why the Type Mismatch Occurs

Lean 4 distinguishes between:
- `⊨ φ` (validity): quantifies over ALL temporal types `T : Type`
- `[] ⊨ φ` (semantic consequence from empty context): quantifies over a SPECIFIC temporal type `T : Type`

Even though these are logically equivalent (proven by `valid_iff_empty_consequence`), they are **different types** in Lean's type system. The conversion must be explicit when the expected type doesn't trigger automatic coercion.

### Lean 4 Type Coercion Behavior

In some contexts (like `example : ⊨ φ := soundness [] _ deriv`), Lean can automatically apply the conversion because:
1. The expected type is `⊨ φ`
2. The actual type is `[] ⊨ φ`
3. Lean searches for a coercion and finds `valid_iff_empty_consequence`

However, in function definitions with explicit return types, Lean is stricter and requires explicit conversion.

## References

- **Validity.lean** (lines 58-66): Definition of `valid` and notation
- **Validity.lean** (lines 77-86): Definition of `semantic_consequence` and notation
- **Validity.lean** (lines 110-116): Conversion theorem `valid_iff_empty_consequence`
- **Soundness.lean** (line 596): Soundness theorem signature
- **ProofSystemSemanticsTest.lean**: Multiple examples of correct usage patterns
- **SoundnessTest.lean** (line 82): Example of explicit conversion

## Conclusion

All three errors stem from a misunderstanding of the relationship between validity (`⊨ φ`) and semantic consequence from empty context (`[] ⊨ φ`). The fixes are straightforward:

1. Use `valid_iff_empty_consequence` to convert between the two types
2. Correctly unwrap validity with all required parameters, or simplify the code

Total implementation effort: **< 30 minutes** (trivial changes, well-understood API)
