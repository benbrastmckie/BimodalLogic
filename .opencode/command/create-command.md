---
name: create-command
agent: lean4-orchestrator
description: "Create a new command with proper routing"
---

You are creating a new command for the .opencode system.

**Command Specification:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/builder-templates/BUILDER-GUIDE.md

**Task:**

Execute the command creation workflow:

1. Route to @subagents/meta with command specification
2. Meta agent will:
   - Use command-generator specialist
   - Apply command patterns
   - Create command file with proper routing
   - Validate structure
3. Present results with file path and usage examples

Execute the command creation now.
