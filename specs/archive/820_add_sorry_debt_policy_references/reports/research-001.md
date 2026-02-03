# Research Report: Task #820

**Task**: 820 - add_sorry_debt_policy_references
**Started**: 2026-02-03T12:00:00Z
**Completed**: 2026-02-03T12:05:00Z
**Effort**: trivial
**Dependencies**: Task 819 (creates the sorry-debt-policy.md file)
**Sources/Inputs**: Codebase exploration (Glob, Read)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- All three target files located and analyzed
- sorry-debt-policy.md exists at `.claude/context/project/lean4/standards/sorry-debt-policy.md`
- Both agent files have "Context References" sections with clear insertion points
- lean4.md rule file needs a new "Context References" section or reference line

## Context and Scope

Task 820 requires adding single-line references to the sorry-debt-policy.md context file in three locations:
1. lean-implementation-agent.md - Context References section
2. lean-research-agent.md - Context References section
3. .claude/rules/lean4.md - New reference to the context file

## Findings

### 1. Target File: lean-implementation-agent.md

**Path**: `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-implementation-agent.md`

**Context References Section** (lines 69-88):
```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-implementation-flow.md` - Detailed execution stages

**Load for Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Common tactic usage patterns
- `@.claude/context/project/lean4/style/lean4-style-guide.md` - Code style conventions
```

**Insertion Point**: Add after line 82 (under "Load for Implementation" section), as a new subsection "**Load for Sorry Handling**:" or directly in the "Load for Implementation" section.

**Recommended Insertion**: Add as a new subsection after "Load for Implementation" (after line 83):
```markdown
**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

### 2. Target File: lean-research-agent.md

**Path**: `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md`

**Context References Section** (lines 72-85):
```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load After Stage 0**:
- `@.claude/context/project/lean4/agents/lean-research-flow.md` - Detailed execution stages

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md` - Research report structure
```

**Insertion Point**: Add after line 85 (after "Load When Creating Report" section).

**Recommended Insertion**: Add as a new subsection after "Load When Creating Report" (after line 85):
```markdown

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

### 3. Target File: lean4.md

**Path**: `/home/benjamin/Projects/ProofChecker/.claude/rules/lean4.md`

**Current Structure**: The file has no "Context References" section. It contains:
- MCP Tools section
- Code Patterns section
- Error Handling section
- Project-Specific section
- Build Commands section
- Testing section

**Insertion Point**: Add a new "Context References" section after the frontmatter (after line 4) or at the end of the file before Testing.

**Recommended Insertion**: Add after line 180 (end of file, before closing):
```markdown
## Context References

For deeper understanding, load these context files as needed:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

**Alternative**: Add a single reference line in the "Project-Specific" section, since that section discusses architecture. After line 150 (after Import Patterns):
```markdown

### Sorry Debt Policy
See `@.claude/context/project/lean4/standards/sorry-debt-policy.md` for sorry handling guidelines.
```

## Recommendations

### Exact Edits

**Edit 1: lean-implementation-agent.md**

Insert after line 83 (after the lean4-style-guide.md line):
```markdown

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

**Edit 2: lean-research-agent.md**

Insert after line 85 (after the report-format.md line):
```markdown

**Load for Sorry Handling**:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

**Edit 3: lean4.md**

Insert after line 180 (at the end of the file, replacing the trailing newline):
```markdown

## Context References

For deeper understanding, load these context files as needed:
- `@.claude/context/project/lean4/standards/sorry-debt-policy.md` - Sorry remediation policy
```

## Decisions

1. **Use consistent subsection format**: Both agent files will use "**Load for Sorry Handling**:" as the subsection header to maintain consistency with existing subsection naming conventions.

2. **Add new section to lean4.md**: Since lean4.md has no Context References section, create a minimal one focused specifically on the sorry-debt-policy reference.

3. **Use same description text**: All three files will use "Sorry remediation policy" as the description for consistency.

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Inconsistent formatting | Use exact same reference text across all files |
| Wrong insertion point | Research identified exact line numbers for each edit |
| File changed since research | Edits use unique string matching, not line numbers |

## Appendix

### Verified File Existence

- `sorry-debt-policy.md` confirmed at `.claude/context/project/lean4/standards/sorry-debt-policy.md` (128 lines)
- File contains comprehensive policy with categories, remediation paths, discovery protocol

### Reference Text (Standard Form)

```
@.claude/context/project/lean4/standards/sorry-debt-policy.md - Sorry remediation policy
```

This is the exact text to use in all three target files.
