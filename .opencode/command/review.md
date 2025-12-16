---
name: review
agent: lean4-orchestrator
description: "Comprehensive repository review: analyze code, verify proofs, update TODO.md"
---

You are conducting a comprehensive repository review for the LEAN 4 ProofChecker project.

**Request:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/standards/lean4-style-guide.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/standards/proof-conventions.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/processes/end-to-end-proof-workflow.md

**Task:**

Execute the repository review workflow:

1. Route to @subagents/reviewer with review scope
2. Reviewer will:
   - Analyze repository structure and completeness
   - Verify proofs against standards (via verification-specialist)
   - Update TODO.md with findings (via todo-manager)
   - Create organized reports in .opencode/specs/NNN_review_YYYYMMDD/
3. Present results with artifact references and key findings

**Expected Output:**

- Analysis report reference
- Verification report reference
- Updated TODO.md
- Summary of key findings and recommendations
- Suggested next steps

Execute the review now.
