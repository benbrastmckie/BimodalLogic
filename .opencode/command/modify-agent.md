---
name: modify-agent
agent: lean4-orchestrator
description: "Modify an existing agent"
---

You are modifying an existing agent in the .opencode system.

**Agent Name and Modifications:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/builder-templates/BUILDER-GUIDE.md

**Task:**

Execute the agent modification workflow:

1. Route to @subagents/meta with agent name and modifications
2. Meta agent will:
   - Load existing agent file
   - Apply modifications using agent-generator
   - Validate structure
   - Preserve existing functionality
3. Present results with file path and summary of changes

Execute the agent modification now.
