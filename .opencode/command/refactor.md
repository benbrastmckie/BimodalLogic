---
agent: refactor
description: "Refactors a specific Lean 4 file"
---

Improves the structure, clarity, and efficiency of existing Lean 4 code without changing its functionality.

**Request:** $ARGUMENTS

**Process:**
1. Analyzes the specified `.lean` file.
2. Identifies areas for improvement (e.g., simplifying proofs, improving naming, reducing redundancy).
3. Applies refactoring patterns to the code.
4. If a line number is provided, focuses the refactoring efforts around that specific line.

**Syntax:**
```bash
/refactor <file> [--line <number>]
```

**Parameters:**
- `<file>`: (Required) The path to the `.lean` file to refactor.
- `--line <number>`: (Optional) The line number to focus the refactoring on.

**Examples:**

```bash
# Example 1: Refactoring an entire file
/refactor "src/my_theorem.lean"

# Example 2: Focusing on a specific line
/refactor "src/utils.lean" --line 42

# Example 3: Refactoring the main project file
/refactor "src/main.lean" --line 100
```

**Output:**
```diff
--- a/{file}
+++ b/{file}
{Git-style diff of the changes made}
```
