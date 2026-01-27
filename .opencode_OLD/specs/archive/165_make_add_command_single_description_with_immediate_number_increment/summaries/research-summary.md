# Research Summary: /add Command Single-Description Design

**Project:** #165  
**Date:** 2025-12-24  
**Status:** Research Complete

## Key Findings

### 1. Current Implementation Analysis

**Strengths:**
- Atomic numbering already implemented via `atomic-task-number.sh`
- Lazy directory creation correctly enforced (never creates project dirs)
- State management follows best practices (fetch-and-add pattern)
- Supports multiple input formats (single, batch, file, plan artifacts)

**Weaknesses:**
- Requires 10+ metadata fields vs. 1 essential (description)
- Number allocation happens in subagent (should be in orchestrator for immediate feedback)
- Complex input parsing for simple use case
- Friction for quick task creation

### 2. Best Practices from Research

**Atomic Numbering:**
- Fetch-and-add pattern is optimal (already implemented)
- Immediate increment with no rollback (gaps acceptable)
- Hardware-optimized, no race conditions
- Current `atomic-task-number.sh` script is correct

**CLI Design:**
- Single required argument for primary action (description)
- Auto-populate metadata with sensible defaults
- Clear, immediate feedback to user
- Follows clig.dev CLI Guidelines principles

**State Management:**
- Immediate state updates (already implemented)
- State file is source of truth (already correct)
- TODO.md is eventually consistent (already correct)
- No rollback needed for counter (already correct)

### 3. Gap Analysis

**Current Behavior:**
```bash
/add "Implement feature"
# Requires: description + 10 metadata fields
# Number allocated in subagent
# Returns after full task creation
```

**Desired Behavior:**
```bash
/add "Implement feature"
# Requires: description only
# Number allocated immediately in orchestrator
# All metadata auto-populated with defaults
# Returns: "Task #168 created: Implement feature"
```

**Metadata Auto-Population Strategy:**

| Field | Current | Desired | Source |
|-------|---------|---------|--------|
| Number | From atomic service | From atomic service | Pre-allocated |
| Description | Required | Required | User input |
| Status | [NOT STARTED] | [NOT STARTED] | Default |
| Priority | Required | Medium | Default |
| Language | Required | markdown | Default |
| Effort | Required | Inferred | Description analysis |
| Files Affected | Required | TBD | Placeholder |
| Dependencies | Required | None | Default |
| Blocking | Required | None | Default |
| Acceptance Criteria | Required | Auto-generated | From description |
| Impact | Required | Auto-generated | From description |

### 4. Recommended Changes

**High Priority:**
1. Move number allocation to orchestrator (before delegation)
2. Simplify input to single description argument
3. Implement comprehensive metadata auto-population
4. Update documentation with new workflow

**Medium Priority:**
1. Add optional flags for overriding defaults (--priority, --language, etc.)
2. Separate commands for complex cases (/add-batch, /add-from-file)
3. Improve inference algorithms (effort estimation, criteria generation)

**Low Priority:**
1. ML-based effort estimation
2. Context-aware language detection
3. Smart file path inference

## Most Relevant Resources

**Research Reports:**
- `reports/research-001.md` - Atomic numbering and CLI design best practices
- `reports/research-002.md` - Current implementation analysis and gap analysis

**Key Context Files:**
- `.opencode/command/add.md` - Current command implementation
- `.opencode/agent/subagents/task-adder.md` - Task creation logic
- `.opencode/specs/state.json` - Numbering schema
- `.opencode/context/core/standards/tasks.md` - Metadata requirements

**External References:**
- clig.dev CLI Guidelines - Human-first design principles
- Herlihy & Wing (1990) - Linearizability and atomic operations
- Martin Fowler - Patterns of Distributed Systems

## Recommendations

**Immediate Action:**
Create implementation plan with three phases:
1. **Phase 1:** Orchestrator changes (number allocation, validation)
2. **Phase 2:** Task-adder changes (auto-population, inference)
3. **Phase 3:** Testing and documentation

**Expected Benefits:**
- 90% reduction in required user input (10+ fields → 1 field)
- Immediate number feedback (allocated before delegation)
- Frictionless task creation (matches CLI best practices)
- Maintains correctness (atomic operations preserved)
- Better user experience (follows clig.dev principles)

**Next Steps:**
Run `/plan 165` to create detailed implementation plan based on research findings.

## Full Reports

See comprehensive research reports for detailed analysis:
- `reports/research-001.md` - 582 lines of atomic numbering and CLI design research
- `reports/research-002.md` - 582 lines of current implementation analysis and recommendations
