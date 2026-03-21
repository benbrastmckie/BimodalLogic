# Research Report: Task #595

**Task**: 595 - Remove Maintenance Directory and Fix Review State Management
**Started**: 2026-01-18T17:20:00Z
**Completed**: 2026-01-18T17:35:00Z
**Effort**: 2-4 hours
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, existing documentation
**Artifacts**: specs/595_remove_maintenance_dir_fix_review_state/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The `specs/maintenance/` directory exists but is unused by any active commands - it's a legacy artifact from earlier maintenance workflows
- The `/review` command currently creates review reports but does NOT maintain a `reviews/state.json` file for tracking review history
- 28 files reference `specs/maintenance/` or `maintenance/state.json` - most are in context documentation that needs cleanup
- Implementation requires removing directory references and adding state management to the review workflow

## Context & Scope

This task addresses two related issues:
1. Dead code/documentation: The `specs/maintenance/` directory and extensive documentation references describe a maintenance workflow that was never fully implemented or has been superseded
2. Missing feature: The `/review` command creates reports but lacks state tracking, unlike other commands that maintain state.json files

## Findings

### 1. specs/maintenance/ Directory Status

**Current Contents**:
```
specs/maintenance/
├── maintenance-report-20251224.md  (14470 bytes)
└── state.json                      (2098 bytes)
```

**Usage Analysis**:
- The directory exists with one old report and state file
- **No active command references or uses this directory**
- The maintenance state tracks one historical operation from 2025-12-24
- The extensive maintenance-workflow.md documentation describes a workflow that never became operational

**Files Referencing specs/maintenance/**:

| Location | Count | Type |
|----------|-------|------|
| `.claude/context/project/lean4/processes/maintenance-workflow.md` | 19 refs | Documentation |
| `.claude/context/project/lean4/templates/maintenance-report-template.md` | 2 refs | Template |
| `.claude/context/core/templates/state-template.json` | 2 refs | Template |
| `.claude/context/project/repo/self-healing-implementation-details.md` | 2 refs | Documentation |
| `specs/TODO.md` | 1 ref | Task reference (this task) |
| `specs/state.json` | 1 ref | Task reference (this task) |
| `.opencode*/` directories | 12 refs | Deprecated/backup copies |

### 2. /review Command Analysis

**Current Implementation** (`.claude/commands/review.md`):

The review command:
1. Parses scope arguments
2. Gathers context (Lean diagnostics, TODOs, code smells)
3. Analyzes and categorizes findings
4. Creates review report at `specs/reviews/review-{DATE}.md`
5. Optionally creates tasks with `--create-tasks`
6. Updates registries (if applicable)
7. Git commits changes

**What's Missing**:
- No `reviews/state.json` maintenance
- No tracking of review history
- No metadata about previous reviews
- No git commit after updates (Step 7 mentions it but details are incomplete)

**Current specs/reviews/ Contents**:
```
specs/reviews/
├── review-20260110-bimodal-mvp.md
├── review-20260110.md
└── review-2026-01-17.md
```

### 3. reviews/state.json Requirements

Based on the task description and existing patterns (e.g., `archive/state.json`), the new `reviews/state.json` should track:

**Proposed Schema**:
```json
{
  "_schema_version": "1.0.0",
  "_comment": "Review state tracking for code review history",
  "_last_updated": "ISO_TIMESTAMP",
  "reviews": [
    {
      "review_id": "review-YYYYMMDD",
      "date": "ISO_DATE",
      "scope": "all|path|file",
      "report_path": "specs/reviews/review-YYYYMMDD.md",
      "summary": {
        "files_reviewed": N,
        "critical_issues": N,
        "high_issues": N,
        "medium_issues": N,
        "low_issues": N
      },
      "tasks_created": [N1, N2],
      "registries_updated": ["file1.md", "file2.md"]
    }
  ],
  "statistics": {
    "total_reviews": N,
    "last_review": "ISO_DATE",
    "total_issues_found": N,
    "total_tasks_created": N
  }
}
```

### 4. Related Documentation Requiring Updates

Files that need maintenance/ references removed:

**High Priority** (active documentation):
1. `.claude/context/core/templates/state-template.json` - Remove `maintenance_state_path` reference
2. `.claude/context/project/lean4/processes/maintenance-workflow.md` - Delete or heavily revise
3. `.claude/context/project/lean4/templates/maintenance-report-template.md` - Consider deletion

**Medium Priority** (contextual docs):
4. `.claude/context/project/repo/self-healing-implementation-details.md` - Remove maintenance references

**Low Priority** (deprecated directories):
5. `.opencode/`, `.opencode_NEW/` - These appear to be deprecated backup directories; consider full removal

## Decisions

1. **Remove specs/maintenance/ directory entirely** - The contents are historical and unused
2. **Create new reviews/state.json** - Follow existing state.json patterns
3. **Update /review command** - Add state tracking and explicit git commit step
4. **Remove maintenance documentation** - Delete or mark as deprecated the maintenance-workflow.md and template
5. **Clean up state-template.json** - Remove maintenance_state_path reference

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking hidden dependencies | Medium | Grep confirmed no command uses maintenance/ |
| Loss of historical data | Low | Archive maintenance report before deletion |
| Incomplete state tracking | Medium | Design schema based on existing patterns |
| Review command instability | Medium | Update command incrementally, test each change |

## Appendix

### Search Queries Used

```bash
# Find maintenance references
grep -r "specs/maintenance" /home/benjamin/Projects/ProofChecker
grep -r "maintenance/" /home/benjamin/Projects/ProofChecker/.claude

# Find review command references
grep -ri "/review|review.md|review command" /home/benjamin/Projects/ProofChecker/.claude

# Check existing reviews directory
ls -la /home/benjamin/Projects/ProofChecker/specs/reviews/
```

### Files to Modify (Implementation Plan Input)

**Delete**:
- `specs/maintenance/` (entire directory)
- `.claude/context/project/lean4/processes/maintenance-workflow.md` (or mark deprecated)
- `.claude/context/project/lean4/templates/maintenance-report-template.md` (or mark deprecated)

**Create**:
- `specs/reviews/state.json`

**Modify**:
- `.claude/commands/review.md` - Add state management
- `.claude/context/core/templates/state-template.json` - Remove maintenance reference
- `.claude/context/project/repo/self-healing-implementation-details.md` - Remove maintenance references
- `.claude/context/core/workflows/review-process.md` - Add state management details

## Next Steps

1. Run `/plan 595` to create implementation plan with phases for:
   - Directory and file cleanup
   - State schema creation
   - Review command updates
   - Documentation updates
   - Verification and testing
