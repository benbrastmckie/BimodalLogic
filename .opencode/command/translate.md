---
agent: lean-latex-translator
description: "Translates a Lean 4 file into LaTeX format"
---

Converts a Lean 4 source file into a human-readable LaTeX document, suitable for academic papers or documentation.

**Request:** $ARGUMENTS

**Process:**
1. Parses the specified `.lean` file.
2. Maps Lean 4 syntax (theorems, proofs, definitions) to corresponding LaTeX environments.
3. Generates a `.tex` file with the translated content.
4. Preserves the logical structure and formatting.

**Syntax:**
```bash
/translate <file>
```

**Parameters:**
- `<file>`: (Required) The path to the `.lean` file to translate.

**Examples:**

```bash
# Example 1: Translating a theorem file
/translate "src/my_theorem.lean"

# Example 2: Translating a completed proof
/translate "src/final_proof.lean"

# Example 3: Translating a file with complex lemmas
/translate "src/complex_lemma.lean"
```

**Output:**
```latex
% Generated from: {file}
\documentclass{article}
\usepackage{amsmath}

\begin{document}
{Translated LaTeX content}
\end{document}
```
