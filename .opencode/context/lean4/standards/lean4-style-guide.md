# LEAN 4 Style Guide

## Overview
This file defines the coding conventions for LEAN 4 to ensure consistency and readability.

## Quality Criteria

### Naming Conventions
- **Types**: `CamelCase`
- **Functions and Variables**: `camelCase`
- **Theorems**: `snake_case`

### Line Length
- Lines should not exceed 100 characters.

### Indentation
- Use 2 spaces for indentation.

## Validation Rules

### Naming Conventions
- **Rule**: All names must follow the naming conventions.
  **Check**: Use a linter to check for naming convention violations.
  **Failure Action**: Fix the naming convention violation.

### Line Length
- **Rule**: All lines must be less than 100 characters.
  **Check**: Use a linter to check for line length violations.
  **Failure Action**: Break the line into multiple lines.

## Examples

**Pass Example**:
```lean
def myFunctionName (myVariable : MyType) : MyOtherType :=
  -- ...
```

**Fail Example**:
```lean
def My_Function_Name (My_Variable : my_type) : my_other_type :=
  -- ...
```
