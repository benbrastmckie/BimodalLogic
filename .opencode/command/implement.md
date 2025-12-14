---
agent: lean-implementer
description: "Implements Lean 4 code based on a provided outline file"
---

Takes a proof or implementation outline and generates the corresponding Lean 4 code.

**Request:** $ARGUMENTS

**Process:**
1. Reads the specified outline file.
2. Translates the logical steps into Lean 4 syntax.
3. Generates a `.lean` file with the implementation.
4. Ensures the code is well-structured and commented.

**Syntax:**
```bash
/implement <outline_file>
```

**Parameters:**
- `<outline_file>`: (Required) The path to the file containing the proof or implementation outline.

**Examples:**

```bash
# Example 1: Implementing a proof from a markdown file
/implement "proof_outline.md"

# Example 2: Using a text file as an outline
/implement "src/my_theorem_outline.txt"

# Example 3: Implementing from a lean file with stubs
/implement "docs/implementation_plan.lean"
```

**Output:**
```lean
-- Generated from: {outline_file}
-- Date: {current_date}

{Lean 4 code implementation}
```
