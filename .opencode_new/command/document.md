---
name: document
agent: orchestrator
description: "Update documentation to be complete, accurate, and concise"
---

You are updating documentation for a software project.

**Documentation Scope:** $ARGUMENTS

**Context Loaded:**
@context/common/standards/documentation.md
@context/project/

**Task:**

Execute the documentation workflow:

1. Route to @subagents/documenter with scope
2. Documenter will:
   - Analyze documentation gaps (via doc-analyzer)
   - Update documentation (via doc-writer)
   - Remove outdated/bloated content
   - Ensure completeness and accuracy
   - Create documentation summary
3. Present results with summary and files updated

Execute the documentation update now.
