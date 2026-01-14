# Agent Rules

## NO EMOJI Standard

**Rule**: Do NOT use emoji characters in any artifacts, code, documentation, or output files.

**Rationale**: Emojis cause parsing issues in formal verification tools, break CLI workflows, and create accessibility barriers for screen readers.

**Text Alternatives**:
- Success: [PASS] or [OK]
- Failure: [FAIL] or [ERROR]
- Warning: [WARN] or [CAUTION]
- In Progress: [IN PROGRESS] or [RUNNING]
- Completed: [COMPLETED] or [DONE]

**Mathematical Symbols**: The following are NOT emojis and are allowed in Lean code:
- Logical operators: ∧ ∨ ¬ → ↔
- Modal operators: □ ◇
- Set theory: ∈ ∉ ⊆ ⊇ ∪ ∩

**Validation**: Use `grep -P "[\x{1F300}-\x{1F9FF}]" file.md` to scan for emoji unicode ranges.

**Enforcement**: This rule applies to all agents, commands, and artifacts. Violations should be corrected immediately.
