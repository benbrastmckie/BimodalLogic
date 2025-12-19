---
name: refactor
agent: orchestrator
description: "Refactor LEAN 4 code for improved readability and maintainability"
---

You are refactoring LEAN 4 code for the ProofChecker project.

**File(s) to Refactor:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/standards/lean4-style-guide.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/patterns/tactic-patterns.md

**Task:**

Execute the refactoring workflow:

1. Route to @subagents/refactorer with file path(s)
2. Refactorer will:
   - Check style adherence (via style-checker)
   - Identify simplification opportunities (via proof-simplifier)
   - Apply improvements
   - Verify with lean-lsp-mcp
   - Git commit changes
   - Create refactoring report
3. Present results with report reference and improvements made

Execute the refactoring now.
