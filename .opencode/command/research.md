---
agent: researcher
description: "Researches a specific topic in the Lean 4 ecosystem"
---

Researches a specified topic to gather information, best practices, and examples related to Lean 4.

**Request:** $ARGUMENTS

**Process:**
1. Receives a research topic.
2. Queries academic sources, documentation, and community forums.
3. Synthesizes the findings into a concise report.

**Syntax:**
```bash
/research <topic>
```

**Parameters:**
- `<topic>`: (Required) The topic to research.

**Examples:**

```bash
# Example 1: Researching best practices
/research "best practices for theorem proving in Lean 4"

# Example 2: Inquiring about a library
/research "how to use the mathlib4 library"

# Example 3: Getting advice for beginners
/research "common pitfalls for beginners in Lean 4"
```

**Output:**
```markdown
## Research Findings on: {topic}

{Synthesized report with findings, examples, and links to resources}
```
