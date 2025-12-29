# Content Mapping Document - Phase 3 Consolidation

**Task**: 246  
**Created**: 2025-12-29T09:02:55-08:00  
**Purpose**: Track where each section moved during consolidation

---

## Baseline Metrics

- **Total Lines**: 23,294 lines (actual baseline, not 8,093)
- **Total Files**: 76 markdown files
- **Key Files to Consolidate**:
  - subagent-return-format.md: 355 lines
  - subagent-delegation-guide.md: 648 lines
  - status-markers.md: 888 lines
  - state-schema.md: 686 lines
  - command-lifecycle.md: 1,138 lines
  - **Subtotal**: 3,715 lines

---

## Phase 2: Delegation Files Consolidation

### Source Files
- `.opencode/context/common/standards/subagent-return-format.md` (355 lines)
- `.opencode/context/common/workflows/subagent-delegation-guide.md` (648 lines)
- **Total**: 1,003 lines

### Target File
- `.opencode/context/core/standards/delegation.md` (~500 lines target)

### Section Mapping
| Original File | Section | New Location |
|--------------|---------|--------------|
| subagent-return-format.md | Return Format Schema | delegation.md#return-format |
| subagent-return-format.md | Field Specifications | delegation.md#return-format-fields |
| subagent-return-format.md | Validation Rules | delegation.md#validation-framework |
| subagent-return-format.md | Examples | delegation.md#examples |
| subagent-delegation-guide.md | Delegation Patterns | delegation.md#delegation-patterns |
| subagent-delegation-guide.md | Context Schema | delegation.md#delegation-context |
| subagent-delegation-guide.md | Best Practices | delegation.md#delegation-patterns |
| subagent-delegation-guide.md | Examples | delegation.md#examples (consolidated) |

**Status**: [NOT STARTED]

---

## Phase 3: State Management Files Consolidation

### Source Files
- `.opencode/context/common/system/status-markers.md` (888 lines)
- `.opencode/context/common/system/state-schema.md` (686 lines)
- **Total**: 1,574 lines

### Target File
- `.opencode/context/core/system/state-management.md` (~800 lines target)

### Section Mapping
| Original File | Section | New Location |
|--------------|---------|--------------|
| status-markers.md | Status Markers | state-management.md#status-markers |
| status-markers.md | Transition Rules | state-management.md#status-transitions |
| status-markers.md | Validation | state-management.md#validation |
| state-schema.md | State Schema | state-management.md#state-schema |
| state-schema.md | Archive Schema | state-management.md#archive-schema |
| state-schema.md | Timestamp Format | state-management.md#timestamp-format |
| Both | Examples | state-management.md#examples (consolidated) |

**Status**: [NOT STARTED]

---

## Phase 4: Command Lifecycle Removal

### Source File
- `.opencode/context/common/workflows/command-lifecycle.md` (1,138 lines)

### Action
- **Remove**: Entire file (obsolete after OpenAgents migration)
- **Extract**: Routing patterns (Stages 1-3) to command files
- **Verify**: Execution patterns (Stages 4-8) in agent files

### Routing Patterns Extraction
| Pattern | Destination |
|---------|-------------|
| Stage 1-3 (Routing) | Command files (already present) |
| Stage 4-8 (Execution) | Agent files (already present) |

**Status**: [NOT STARTED]

---

## Phase 5: Examples Consolidation

### Duplicate Examples Identified
- TBD during execution

### Consolidation Actions
- TBD during execution

**Status**: [NOT STARTED]

---

## Phase 6: Directory Reorganization

### File Moves
| Original Location | New Location |
|------------------|--------------|
| delegation.md | core/standards/delegation.md |
| state-management.md | core/system/state-management.md |
| artifact-management.md | core/system/artifact-management.md |
| git-commits.md | core/system/git-commits.md |
| review.md | core/workflows/review.md |
| task-breakdown.md | core/workflows/task-breakdown.md |

**Status**: [NOT STARTED]

---

## Final Metrics

- **Target Total Lines**: 2,000-2,500 lines
- **Target File Count**: ~15 files
- **Target Reduction**: 69-75%
- **Actual Results**: TBD

---

## Validation Checklist

- [ ] All critical information preserved
- [ ] All schemas validated
- [ ] All examples tested
- [ ] All internal links working
- [ ] All commands functional
- [ ] Context window usage <10%
