---
name: research
agent: orchestrator
description: "Research a topic using LeanExplore, Loogle, LeanSearch, and web sources"
---

You are conducting research for the LEAN 4 ProofChecker project.

**Research Topic:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/domain/lean4-syntax.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/domain/mathlib-overview.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/tools/mcp-tools-guide.md

**Task:**

Execute the research workflow:

1. Route to @subagents/researcher with research topic
2. Researcher will:
   - Coordinate specialist subagents (lean-search, loogle, web-research)
   - Gather information from multiple sources
   - Synthesize findings into comprehensive report
   - Create report in .opencode/specs/NNN_research_{topic}/reports/
3. Present results with artifact references and key findings

**Expected Output:**

- Research report reference
- Key findings summary
- Relevant LEAN definitions/theorems
- Implementation recommendations
- Further research needed (if any)

Execute the research now.
