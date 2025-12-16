---
name: create-agent
agent: lean4-orchestrator
description: "Create a new agent using builder templates"
---

You are creating a new agent for the .opencode system.

**Agent Specification:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/builder-templates/subagent-template.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/builder-templates/BUILDER-GUIDE.md

**Task:**

Execute the agent creation workflow:

1. Route to @subagents/meta with agent specification
2. Meta agent will:
   - Use agent-generator specialist
   - Apply builder templates
   - Create XML-optimized agent file
   - Validate structure
3. Present results with file path and testing recommendations

Execute the agent creation now.
