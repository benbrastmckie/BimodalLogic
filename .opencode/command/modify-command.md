---
name: modify-command
agent: lean4-orchestrator
description: "Modify an existing command"
---

You are modifying an existing command in the .opencode system.

**Command Name and Modifications:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/builder-templates/BUILDER-GUIDE.md

**Task:**

Execute the command modification workflow:

1. Route to @subagents/meta with command name and modifications
2. Meta agent will:
   - Load existing command file
   - Apply modifications using command-generator
   - Validate routing and structure
3. Present results with file path and summary of changes

Execute the command modification now.
