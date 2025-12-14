---
agent: lean-dev-orchestrator
description: "Starts the main workflow to prove a given theorem"
---

Initiates the theorem-proving workflow, coordinating multiple agents to research, outline, and implement the proof.

**Request:** $ARGUMENTS

**Process:**
1. Receives a theorem to be proven.
2. Engages the `lean-researcher` to gather context.
3. Works with the user to create a proof outline.
4. Delegates implementation to the `lean-implementer`.
5. Manages the overall process until the proof is complete.

**Syntax:**
```bash
/prove <theorem>
```

**Parameters:**
- `<theorem>`: (Required) The theorem statement to be proven.

**Examples:**

```bash
# Example 1: Proving a famous theorem
/prove "Fermat's Last Theorem"

# Example 2: Tackling a complex hypothesis
/prove "the Riemann Hypothesis"

# Example 3: A more modern conjecture
/prove "the Poincaré conjecture"
```

**Output:**
```markdown
Starting proof process for: "{theorem}"
- Research phase initiated.
- Awaiting proof outline collaboration.
```
