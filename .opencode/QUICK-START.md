# Quick Start Guide

Welcome to your new AI-powered LEAN 4 Development Suite! This guide will walk you through the two most important commands to get you started.

---

## Your First Task: Proving a Theorem

The most powerful feature of this system is its ability to handle the entire theorem-proving process from a single command. Let's try it out.

### Step 1: The Command

The `/prove` command is the main entry point for the entire system. It tells the AI to research, plan, implement, and document a proof for a given theorem.

**Action:**
Run the following command. You can copy and paste it directly.

```bash
/prove "For any natural number n, if n is even, then n * n is even"
```

### Step 2: What to Expect

The AI will now begin the 5-stage `end-to-end-theorem-proving` workflow. You will see it thinking as it:
1.  **Researches** the concepts of "natural number" and "even."
2.  **Plans** a proof strategy (likely a direct proof).
3.  **Implements** the plan in LEAN 4 code.
4.  **Documents** the new theorem with comments.

The end result will be a new or modified `.lean` file in your project containing the formal proof.

---

## Your Second Task: Refactoring a File

The second most common task is improving existing code. The `/refactor` command tells the AI to analyze a file and improve its structure, readability, and documentation.

### Step 1: Create a Sample File

First, create a file named `sample_proof.lean` in your project and add the following code. It's intentionally a bit messy.

```lean
import Mathlib.Data.Nat.Basic

theorem messy_proof (n : ℕ) (h : Even n) : Even (n * n) :=
  by
    cases h with
    | intro k hk =>
      exists (2 * k * k)
      rw [hk]
      ring
```

### Step 2: The Command

Now, ask the AI to refactor this file.

**Action:**
Run the following command:

```bash
/refactor "sample_proof.lean"
```

### Step 3: What to Expect

The AI will read the file and perform several improvements, such as:
-   Adding a docstring to explain the theorem.
-   Reformatting the tactics to be more readable.
-   Ensuring the code follows the style guidelines in the system's context.

The `sample_proof.lean` file will be modified in place. You can use `git diff` to see the changes the AI made.

---

## Next Steps

You've now used the two primary features of the system!

-   To see all available commands, check the **[Commands Reference](./docs/COMMANDS_REFERENCE.md)**.
-   To understand how the AI works, read the **[System Architecture](./docs/ARCHITECTURE.md)** guide.
