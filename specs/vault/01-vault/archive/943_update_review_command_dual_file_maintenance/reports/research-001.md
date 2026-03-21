# Research Report: Update /review Command Dual File Maintenance

- **Task**: 943 - update_review_command_dual_file_maintenance
- **Started**: 2026-02-26T12:00:00Z
- **Completed**: 2026-02-26T12:30:00Z
- **Effort**: 30 minutes
- **Dependencies**: Task 941 (CHANGE_LOG.md creation)
- **Sources/Inputs**:
  - `.claude/commands/review.md` - Current /review command implementation
  - `.claude/context/core/workflows/review-process.md` - Review workflow documentation
  - `specs/ROAD_MAP.md` - Current roadmap structure
  - `specs/CHANGE_LOG.md` - Recently created changelog file
  - `.claude/context/core/formats/changelog-format.md` - Changelog format standard
  - `.claude/context/core/formats/roadmap-format.md` - Roadmap format standard
- **Artifacts**: This report
- **Standards**: report-format.md, artifact-formats.md

---

## Executive Summary

- The /review command currently loads ROAD_MAP.md for strategic context (Step 1.6) but does not load CHANGE_LOG.md
- CHANGE_LOG.md was created by Task 941 and contains historical context valuable for reviews
- Two modifications needed: (1) Add Step 1.7 to load CHANGE_LOG.md, (2) Add Step 6.6 to update CHANGE_LOG.md with review findings
- The modification follows existing patterns for ROAD_MAP.md loading and can reuse the changelog-format.md schema
- Implementation is straightforward: ~80-100 lines of new content in review.md

---

## Context & Scope

### Problem Statement

Task 941 separated historical changelog content from ROAD_MAP.md into a dedicated specs/CHANGE_LOG.md file. The /review command currently:
- Loads ROAD_MAP.md for strategic context (Strategies, Ambitions) in Step 1.6
- Updates ROAD_MAP.md with annotations, strategy changes, and ambition proposals in Step 6.5
- Does NOT load or update CHANGE_LOG.md

The task requires:
1. Loading CHANGE_LOG.md for historical context during reviews
2. Adding a Step 6.6 to update CHANGE_LOG.md with review findings

### Scope Boundaries

**In Scope**:
- Adding Step 1.7 (Load CHANGE_LOG Context)
- Adding Step 6.6 (Update CHANGE_LOG.md)
- Updating commit message format in Step 7

**Out of Scope**:
- Changes to ROAD_MAP.md handling (already implemented)
- Changes to changelog-format.md (already finalized by Task 941)
- Changes to /todo command (already updates CHANGE_LOG.md)

---

## Findings

### 1. Current /review Command Structure

The command is located at `.claude/commands/review.md` (1344 lines) and follows an 8-step workflow:

| Step | Name | Current Function |
|------|------|------------------|
| 1 | Parse Arguments | Scope determination |
| 1.5 | Load Review State | `specs/reviews/state.json` |
| 1.6 | Load ROADMAP Context | Strategies and Ambitions from ROAD_MAP.md |
| 2 | Gather Context | File analysis (Lean, code, docs) |
| 2.5 | Roadmap Integration | Parse phases, checkboxes, status tables |
| 3 | Analyze Findings | Categorize by severity |
| 4 | Create Review Report | Write `specs/reviews/review-{DATE}.md` |
| 4.5 | Update Review State | `specs/reviews/state.json` |
| 5 | Task Proposal Mode | Auto-create or interactive selection |
| 5.5-5.6 | Issue Grouping & Task Creation | Group issues, create tasks |
| 6 | Update Registries | Domain-specific registries |
| 6.5 | Revise ROADMAP.md | Strategy/Ambition updates |
| 7 | Git Commit | Commit all changes |
| 8 | Output | Summary to user |

### 2. CHANGE_LOG.md Structure

Located at `specs/CHANGE_LOG.md`, created by Task 941:

```markdown
# ProofChecker Change Log

**Purpose**: Record of completed work with rationale and references...

---

## Changelog

### YYYY-MM-DD

- **Task {N}**: {summary}
  - *Rationale*: {reason}
  - *References*: [summary](path), [plan](path)
```

Key characteristics:
- Date headers in reverse chronological order (newest first)
- Task entries with summary, rationale, and references
- Schema documented in `changelog-format.md`

### 3. Existing ROAD_MAP.md Loading Pattern (Step 1.6)

Step 1.6 provides a template for CHANGE_LOG.md loading:

```markdown
### 1.6. Load ROADMAP Context (Strategies and Ambitions)

**Purpose**: Load Strategies and Ambitions sections from ROAD_MAP.md...

Parse `specs/ROAD_MAP.md` to extract Strategies and Ambitions sections:
...
Build `roadmap_context` structure:
{JSON structure}
...
Variables set for later sections:
- `roadmap_context`
- `review_focus_paths`
- `active_strategies`
```

### 4. Existing ROAD_MAP.md Update Pattern (Step 6.5)

Step 6.5 provides a template for CHANGE_LOG.md updates:

```markdown
### 6.5. Revise ROADMAP.md Based on Findings

**Purpose**: Update ROAD_MAP.md to reflect review findings...

**Precondition**: `roadmap_context` from Section 1.6 must exist...

#### 6.5.1. Strategy Status Updates
#### 6.5.2. Propose New Ambitions
#### 6.5.3. Update Active Tasks Section
#### 6.5.4. Add Gap Notes to Open Questions
#### 6.5.5. Summary Variables for Report
```

### 5. Relationship Between Files

| File | Focus | Updated By |
|------|-------|------------|
| ROAD_MAP.md | Strategic direction (forward-looking) | /review (Step 6.5) |
| CHANGE_LOG.md | Historical record (backward-looking) | /todo (Step 5.8), /review (proposed Step 6.6) |

### 6. What Historical Context Provides

Loading CHANGE_LOG.md enables:
- Understanding recent work patterns and priorities
- Identifying recurring issues or refactoring cycles
- Context for new strategy/ambition proposals
- Verification that proposed tasks don't duplicate recent work

---

## Decisions

### D1: Step Numbering

**Decision**: Add Step 1.7 for loading and Step 6.6 for updating CHANGE_LOG.md

**Rationale**: Maintains parallel structure with ROAD_MAP.md (1.6/6.5 for roadmap, 1.7/6.6 for changelog). Preserves existing step numbers for backward compatibility.

### D2: Historical Context Scope

**Decision**: Load recent 30 days of changelog entries by default

**Rationale**: Full changelog history may be large; recent history provides relevant context without overwhelming the review. Configurable via optional parameter.

### D3: Changelog Update Scope

**Decision**: Add entries for significant review findings only (Critical/High severity issues, major architectural observations)

**Rationale**: Reviews are frequent; not every review warrants a changelog entry. Only significant findings merit historical record.

---

## Recommendations

### R1: Add Step 1.7 (Load CHANGE_LOG Context)

Insert after Step 1.6:

```markdown
### 1.7. Load CHANGE_LOG Context (Historical Record)

**Purpose**: Load recent changelog entries from CHANGE_LOG.md to inform review with historical context about completed work.

**Context**: Load @.claude/context/core/formats/changelog-format.md for entry schema.

Parse `specs/CHANGE_LOG.md` to extract recent entries:

#### 1.7.1. Parse Changelog Entries

Extract entries from recent date sections:
```
# Look for "### YYYY-MM-DD" date headers
# Parse entries within 30-day window

For each entry:
  task_number = number after "**Task "
  summary = text after ": " until line end
  rationale = text after "*Rationale*:" if present
  references = links after "*References*:"
```

Build `changelog_context` structure:
```json
{
  "recent_entries": [
    {
      "date": "2026-02-26",
      "task_number": 933,
      "summary": "Archived CanonicalReachable stack to Boneyard",
      "rationale": "backward_P is blocked...",
      "references": ["specs/933_.../summaries/..."]
    }
  ],
  "entry_count": 12,
  "date_range": {"from": "2026-01-27", "to": "2026-02-26"},
  "loaded_successfully": true
}
```

#### 1.7.2. Fallback Behavior

If CHANGE_LOG.md doesn't exist or is empty:
```
changelog_context = {
  "recent_entries": [],
  "entry_count": 0,
  "loaded_successfully": false,
  "fallback_reason": "file_not_found_or_empty"
}
```

Variables set for later sections:
- `changelog_context` - For use in Section 4 (report) and Section 6.6 (updates)
- `recent_task_numbers` - List of recently completed task numbers (duplicate detection)
```

### R2: Add Step 6.6 (Update CHANGE_LOG.md)

Insert after Step 6.5:

```markdown
### 6.6. Update CHANGE_LOG.md Based on Findings

**Purpose**: Add significant review findings to CHANGE_LOG.md for historical record.

**Precondition**: Only add entries for Critical/High severity findings or major architectural observations.

#### 6.6.1. Determine Entry Worthiness

Check if review warrants changelog entry:
```
entry_worthy = (
  critical_issues_count > 0 OR
  high_issues_count >= 3 OR
  strategies_updated > 0 OR
  ambitions_approved > 0 OR
  major_architectural_finding
)
```

If not entry_worthy, skip this section.

#### 6.6.2. Compose Changelog Entry

Format entry per changelog-format.md:
```markdown
- **Review ({scope})**: {summary_of_findings}
  - *Rationale*: {why_this_review_was_significant}
  - *References*: [report](specs/reviews/review-{DATE}.md)
```

#### 6.6.3. Insert Entry

1. Check if today's date header exists in CHANGE_LOG.md
2. If exists, append entry after header
3. If not exists, create new date section at top of Changelog section

**Edit process:**
```
If date header exists:
  old_string: "### {DATE}\n\n- **Task"
  new_string: "### {DATE}\n\n- **Review ({scope})**: ...\n\n- **Task"

If date header does not exist:
  old_string: "## Changelog\n\n<!-- Schema"
  new_string: "## Changelog\n\n### {DATE}\n\n- **Review ({scope})**: ...\n\n<!-- Schema"
```

#### 6.6.4. Track Changes

```json
{
  "changelog_updated": true,
  "entry_added": "Review (all): 3 critical issues identified, 2 strategies paused"
}
```
```

### R3: Update Review Report Template (Step 4)

Add Changelog Context section to report template after "Roadmap Context":

```markdown
## Changelog Context

{If changelog_context.loaded_successfully:}

### Recent Completed Work

| Date | Task | Summary |
|------|------|---------|
| {entry.date} | {entry.task_number} | {entry.summary} |

**Entries reviewed**: {changelog_context.entry_count} from {date_range.from} to {date_range.to}

{If not changelog_context.loaded_successfully:}
*CHANGE_LOG.md not found or empty.*
```

### R4: Update Git Commit Message (Step 7)

Add changelog update tracking:

```markdown
```bash
git commit -m "$(cat <<'EOF'
review: {scope} code review

Roadmap: {annotations_made} items annotated
Changelog: {changelog_updated ? "1 entry added" : "no updates"}
Strategies: {strategies_updated} updated
...
EOF
)"
```

### R5: Update Output Section (Step 8)

Add changelog update status:

```markdown
Changelog Updates:
{If changelog_updated:}
- Entry added: "{entry_summary}"
{If not changelog_updated:}
- No significant findings warranting changelog entry
```

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Large changelog slows parsing | Medium | Limit to 30-day window by default |
| Duplicate detection false positives | Low | Use task number matching, not text matching |
| Review entries clutter changelog | Low | Entry worthiness criteria filter minor reviews |
| Edit conflicts with /todo updates | Low | Both commands use same edit pattern; conflicts rare |

---

## Appendix

### Files to Modify

1. `.claude/commands/review.md` - Main implementation
   - Insert Step 1.7 after Step 1.6 (~40 lines)
   - Insert Step 6.6 after Step 6.5 (~50 lines)
   - Update Step 4 report template (~15 lines)
   - Update Step 7 commit message (~3 lines)
   - Update Step 8 output (~5 lines)

### Related Documentation

- `.claude/context/core/formats/changelog-format.md` - Entry schema reference
- `.claude/context/core/formats/roadmap-format.md` - Parallel structure reference
- `.claude/commands/todo.md` - Step 5.8 shows /todo's changelog update pattern

### Implementation Estimate

- **Effort**: 45-60 minutes
- **Complexity**: Low (follows existing patterns)
- **Risk**: Low (additive changes only)
