---
name: refactor
agent: orchestrator
description: "Refactor code for improved readability and maintainability"
---

You are refactoring code for improved quality and maintainability.

**File(s) to Refactor:** $ARGUMENTS

**Context Loaded:**
@context/common/standards/code.md
@context/common/standards/patterns.md
@context/project/

**Task:**

Execute the refactoring workflow:

1. Route to @subagents/refactorer with file path(s)
2. Refactorer will:
   - Check style adherence (via style-checker)
   - Identify simplification opportunities
   - Apply improvements
   - Run tests to verify correctness
   - Git commit changes
   - Create refactoring report
3. Present results with report reference and improvements made

Execute the refactoring now.
