# Documentation Standards

## Overview
This file specifies how to document definitions, theorems, and proofs in LEAN 4.

## Quality Criteria

### Definitions
- All definitions should have a docstring that explains what the definition is and how to use it.

### Theorems
- All theorems should have a docstring that explains the theorem and its significance.

### Proofs
- All non-trivial proofs should have comments that explain the proof strategy.

## Validation Rules

### Definitions
- **Rule**: All definitions must have a docstring.
  **Check**: Use a linter to check for missing docstrings.
  **Failure Action**: Add a docstring to the definition.

### Theorems
- **Rule**: All theorems must have a docstring.
  **Check**: Use a linter to check for missing docstrings.
  **Failure Action**: Add a docstring to the theorem.

## Examples

**Pass Example**:
```lean
/-- This is a docstring for a definition. -/
def myDefinition : Nat := 5

/-- This is a docstring for a theorem. -/
theorem myTheorem : True :=
  -- This is a comment explaining the proof.
  trivial
```

**Fail Example**:
```lean
def myDefinition : Nat := 5

theorem myTheorem : True :=
  trivial
```
