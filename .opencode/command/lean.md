---
name: lean
agent: lean4-orchestrator
description: "Implement a LEAN 4 proof following an implementation plan"
---

You are implementing a LEAN 4 proof for the ProofChecker project.

**Project Number:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/domain/lean4-syntax.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/patterns/tactic-patterns.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/templates/proof-structure-templates.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/logic/domain/

**Task:**

Execute the implementation workflow:

1. Route to @subagents/proof-developer with project number
2. Proof developer will:
   - Load implementation plan from .opencode/specs/NNN_project/plans/
   - Implement each step using appropriate specialists
   - Verify using lean-lsp-mcp server
   - Git commit after substantial changes
   - Create implementation summary
3. Present results with summary and verification status

**Expected Output:**

- Implementation summary reference
- Files created/modified
- Verification status
- Git commits made
- Documentation needs identified

Execute the implementation now.
