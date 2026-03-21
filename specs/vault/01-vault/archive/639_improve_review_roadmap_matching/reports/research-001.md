# Research Report: Task #639

**Task**: improve_review_roadmap_matching
**Date**: 2026-01-25
**Effort**: 4-6 hours
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: /review command, /todo command, state.json schema, return-metadata-file.md, roadmap-update.md, task 637/638/641 artifacts
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- **Current roadmap matching is multi-layered**: /todo uses explicit roadmap_items (priority 1) and exact (Task N) matching (priority 2); /review uses fuzzy title matching
- **The explicit roadmap_items field already exists** in state.json schema and is populated by implementation agents via completion_data
- **The /todo command has comprehensive structured matching** (Step 3.5), implemented after tasks 638/641
- **The /review command has fuzzy title matching** (Step 2.5.2) which is unreliable per original task description
- **Primary gap**: /review matching needs to adopt the same structured approach as /todo (explicit items + exact references)
- **Secondary gap**: No utility for agents to easily specify roadmap_items during implementation

## Context & Scope

### Problem Statement

Task 639 was created to address unreliable ROAD_MAP.md checkbox matching in the /review command. The original description identified:
1. Fuzzy title matching is unreliable
2. No explicit task-to-roadmap mapping exists
3. Task 637 required manual checkbox fixes

However, subsequent development (tasks 638, 641) implemented explicit task-to-roadmap mapping via the `roadmap_items` field in state.json. This research re-evaluates the problem in light of those changes.

### Evolution of Roadmap Matching (Task Timeline)

| Task | Date | Achievement |
|------|------|-------------|
| 637 | 2026-01-19 | Manually fixed 10 roadmap checkboxes, demonstrating gap |
| 638 | 2026-01-20 | Proposed adding roadmap update to /todo command |
| 639 | 2026-01-20 | Created to improve /review matching reliability |
| 641 | 2026-01-20 | Implemented structured matching in /todo (Step 3.5) |

**Key insight**: Tasks 638/641 implemented the explicit roadmap_items solution that task 639 originally proposed. This research evaluates what remains to fix for /review.

## Findings

### Finding 1: roadmap_items Field Already Exists in Schema

**Location**: `.claude/context/core/formats/return-metadata-file.md` (lines 110-119)

The completion_data object includes:
```json
{
  "completion_summary": "1-3 sentence description",
  "roadmap_items": ["Explicit ROAD_MAP.md item texts"],
  "claudemd_suggestions": "Description of .claude/ changes (meta only)"
}
```

**Producer/Consumer Workflow**:
- **Producer**: Implementation agents populate completion_data in metadata file
- **Propagator**: Implementation skills (skill-implementer, skill-lean-implementation, skill-latex-implementation) extract completion_data and write to state.json (Stage 7)
- **Consumer**: /todo command extracts roadmap_items via jq and matches against ROAD_MAP.md (Step 3.5.2)

**Status**: FULLY IMPLEMENTED for /todo command.

### Finding 2: /todo Command Has Comprehensive Structured Matching

**Location**: `.claude/commands/todo.md` (lines 134-234)

The /todo command implements a sophisticated matching strategy:

**Step 3.5.1**: Separate meta and non-meta tasks (meta tasks use claudemd_suggestions, not roadmap_items)

**Step 3.5.2**: Extract non-meta completed tasks with summaries:
```bash
# Use file-based jq filter to avoid Issue #1132
cat > /tmp/todo_nonmeta_$$.jq << 'EOF'
.active_projects[] |
select(.status == "completed") |
select(.language != "meta") |
select(.completion_summary != null) |
{
  number: .project_number,
  name: .project_name,
  summary: .completion_summary,
  roadmap_items: (.roadmap_items // [])
}
EOF
```

**Step 3.5.3**: Three-tier matching strategy:

| Priority | Match Type | Confidence | Implementation |
|----------|------------|------------|----------------|
| 1 | Explicit roadmap_items | Highest | Direct text match via grep |
| 2 | Exact (Task N) reference | High | grep "(Task N)" pattern |
| 3 | Summary-based search | Optional | Placeholder for future enhancement |

**Annotation formats**:
- Completed with explicit match: `- [x] {item} *(Completed: Task {N}, {DATE})*`
- Completed with exact match: `- [x] {item} (Task {N}) *(Completed: Task {N}, {DATE})*`
- Abandoned tasks: `- [ ] {item} (Task {N}) *(Task {N} abandoned: {reason})*`

**Status**: Structured matching FULLY IMPLEMENTED in /todo.

### Finding 3: /review Command Still Uses Fuzzy Matching

**Location**: `.claude/commands/review.md` (lines 105-156)

The /review command implements Step 2.5.2 "Cross-Reference Roadmap with Project State":

**Current matching strategy** (per roadmap-update.md):
| Match Type | Confidence | Action |
|------------|------------|--------|
| Exact: Item contains (Task {N}) | High | Auto-annotate |
| Title: Item text matches task title (fuzzy) | Medium | Suggest annotation |
| File: Item references path that exists | Medium | Suggest annotation |

**Problem identified in task 639 description**: "Fuzzy title matching is unreliable"

**Gap**: /review does NOT use the explicit roadmap_items field that /todo uses. It relies on:
1. Exact (Task N) references (which are only added AFTER first annotation)
2. Fuzzy title matching (unreliable per task description)
3. File path checks (helpful but incomplete)

### Finding 4: Comparison of /todo vs /review Matching

| Aspect | /todo (Step 3.5) | /review (Step 2.5.2) |
|--------|------------------|----------------------|
| Uses roadmap_items field | ✅ Yes (priority 1) | ❌ No |
| Uses exact (Task N) refs | ✅ Yes (priority 2) | ✅ Yes (high confidence) |
| Uses fuzzy title matching | ❌ No | ✅ Yes (unreliable) |
| Uses file path checks | ❌ No | ✅ Yes (medium confidence) |
| Uses completion_summary | ✅ Placeholder for future | ❌ No |
| Confidence levels | Implicit (priority order) | Explicit (high/medium/low) |
| When executed | At archival time | At review time |

**Key observation**: /todo has MORE reliable matching (explicit roadmap_items) but LESS coverage (only archived tasks). /review has LESS reliable matching (fuzzy titles) but MORE coverage (all completed tasks).

### Finding 5: Current Roadmap Annotation Coverage Gap

**Scenario**: Task 666 (revise_lean_source_code_logos_theory_definitions) completed on 2026-01-25

**state.json entry**:
```json
{
  "project_number": 666,
  "status": "completed",
  "completion_summary": "Updated LaTeX documentation to acknowledge mathematically equivalent Set-based formulation...",
  "roadmap_items": []  // Empty - no explicit items specified
}
```

**Question**: How does this task get matched to ROAD_MAP.md?

**Answer**:
1. **If archived via /todo**: No match (roadmap_items empty, no (Task 666) ref exists in roadmap)
2. **If reviewed via /review**: Potential fuzzy match on title "revise lean source code" (unreliable)

**Result**: Task 666 likely won't get its roadmap checkbox marked despite completion.

### Finding 6: Agent-Side Gap - No Guidance for Populating roadmap_items

**Agent instructions** (general-implementation-agent.md, lean-implementation-agent.md, latex-implementation-agent.md):
- Agents are instructed to populate completion_summary (mandatory)
- Agents are instructed to populate claudemd_suggestions for meta tasks (mandatory)
- Agents are NOT given clear guidance on WHEN or HOW to populate roadmap_items

**Current guidance** (return-metadata-file.md line 112):
> `roadmap_items` - Explicit ROAD_MAP.md item texts this task addresses (non-meta tasks only)

**Missing guidance**:
1. How does agent know which roadmap items to reference?
2. Should agent read ROAD_MAP.md to find relevant items?
3. What if multiple items are relevant?
4. Should agent search for (Task N) references or add them?

**Consequence**: Agents rarely/never populate roadmap_items, falling back to unreliable fuzzy matching.

### Finding 7: Two Separate Use Cases for Roadmap Updates

| Use Case | Command | When | Purpose | Matching Strategy |
|----------|---------|------|---------|-------------------|
| **Archival-time annotation** | /todo | Task archived | Mark completed work to keep roadmap current | Explicit items + exact refs |
| **Periodic roadmap review** | /review | User-initiated | Identify all completed work, recommend next tasks | Should use explicit items + exact refs + task recommendations |

**Current problem**: /review isn't using the same reliable matching strategy as /todo, despite having access to the same data.

### Finding 8: Roadmap Task Recommendations Work Well

**Location**: `.claude/commands/review.md` (lines 327-380)

The /review command has a separate feature (Step 5.5 "Roadmap Task Recommendations") that:
1. Identifies incomplete roadmap items by phase priority
2. Scores items by priority, position, and context
3. Infers language from file paths
4. Prompts user to create tasks interactively

**Status**: This feature works well and is orthogonal to the matching issue.

### Finding 9: Documentation Inconsistency

**roadmap-update.md** says:
```markdown
### Matching Strategy
- **Exact**: Item contains `(Task {N})` reference
- **Title**: Item text matches completed task title (fuzzy)
- **File**: Item references file path that exists
```

**But /todo command actually implements**:
1. Explicit roadmap_items (priority 1) - NOT documented in roadmap-update.md
2. Exact (Task N) reference (priority 2)
3. Title matching is noted as "future enhancement"

**Gap**: roadmap-update.md doesn't document the explicit roadmap_items approach implemented in task 641.

## Recommendations

### 1. Update /review to Use Explicit roadmap_items Field (High Priority)

**Change**: Add roadmap_items extraction to /review Step 2.5.2

**Before** (current):
```bash
# Query state.json for completion data
jq '.active_projects[] | select(.status == "completed")' specs/state.json
```

**After** (proposed):
```bash
# Query state.json for completion data WITH roadmap_items
jq '.active_projects[] | select(.status == "completed") | {
  number: .project_number,
  name: .project_name,
  completed: .completed,
  completion_summary: .completion_summary,
  roadmap_items: (.roadmap_items // [])
}' specs/state.json
```

**Add matching logic** (same as /todo Step 3.5.3):
1. Priority 1: Match via explicit roadmap_items
2. Priority 2: Match via exact (Task N) reference
3. Priority 3 (optional): Fuzzy title matching for tasks without explicit items

**Impact**: /review will have same reliability as /todo for tasks with explicit roadmap_items.

### 2. Improve Agent Guidance for Populating roadmap_items (Medium Priority)

**Problem**: Agents don't know how/when to populate roadmap_items.

**Solution A**: Add guidance to agent instructions:
```markdown
### Populating roadmap_items

When completing a task, check if the work addresses specific ROAD_MAP.md items:

1. Read specs/ROAD_MAP.md (if not too large)
2. Search for items related to the implementation
3. Copy exact item text (without checkbox) to roadmap_items array

Example:
- ROAD_MAP.md contains: `- [ ] Prove completeness theorem for K modal logic`
- completion_data should include: `"roadmap_items": ["Prove completeness theorem for K modal logic"]`

If no clear roadmap items match, leave roadmap_items empty (fuzzy matching will be attempted).
```

**Solution B**: Create a helper skill/agent that:
- Takes task number and completion summary
- Searches ROAD_MAP.md for relevant items
- Suggests roadmap_items for user/agent approval

**Recommendation**: Start with Solution A (documentation), evaluate Solution B if adoption is low.

### 3. Update roadmap-update.md Documentation (Low Priority)

**Changes needed**:
1. Add "Explicit roadmap_items" as Priority 1 matching strategy
2. Document that exact (Task N) is Priority 2
3. Mark fuzzy title matching as "fallback for tasks without explicit items"
4. Add examples of each matching type

**Impact**: Developers and future agents have accurate documentation.

### 4. Consider Deprecating Fuzzy Title Matching in /review (Optional)

**Rationale**: If explicit roadmap_items and exact (Task N) matching cover most cases, fuzzy title matching adds:
- Complexity
- Unreliability (per task 639 description)
- Maintenance burden

**Alternative**: Keep fuzzy matching as "report only" (confidence: low) instead of "suggest annotation" (confidence: medium).

**Decision criteria**: After implementing recommendation 1, measure:
- % of completed tasks with explicit roadmap_items
- % of completed tasks with exact (Task N) refs
- % of completed tasks requiring fuzzy match

If fuzzy match usage < 5%, consider deprecation.

### 5. Consolidate Matching Logic into Shared Pattern (Optional Enhancement)

Both /todo and /review would benefit from a shared matching utility pattern.

**Create**: `.claude/context/core/patterns/roadmap-matching.md`

**Content**:
```markdown
# Roadmap Matching Pattern

## Matching Strategies (Priority Order)

1. **Explicit mapping** (roadmap_items field) - Highest confidence
2. **Exact reference** ((Task N) in roadmap) - High confidence
3. **Fuzzy title match** (2+ non-common keywords) - Low confidence (report only)

## Implementation Template

[Bash code template for matching logic]

## Common Keywords to Exclude

fix, add, update, implement, improve, create, remove, the, a, to, in, for, of, with
```

**Benefit**: Both commands use identical matching logic, easier to maintain.

## Decisions

1. **Scope**: Focus on /review matching (task 639's original scope), leave /todo as-is (already working)
2. **Approach**: Adopt /todo's structured matching (roadmap_items + exact refs) for /review
3. **Fuzzy matching**: Keep as low-confidence fallback, evaluate for deprecation later
4. **Documentation**: Update roadmap-update.md to reflect current implementation

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| roadmap_items rarely populated by agents | Medium | Add clear agent guidance (recommendation 2) |
| /review changes break existing workflow | Low | /review already has multi-strategy matching, adding priority 1 is additive |
| Documentation drift | Low | Update roadmap-update.md as part of implementation |
| Over-matching with fuzzy fallback | Medium | Use "report only" confidence for fuzzy matches |

## Appendix

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/commands/review.md` (449 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/commands/todo.md` (1114 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/formats/return-metadata-file.md` (397 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/roadmap-update.md` (101 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/formats/roadmap-format.md` (66 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-implementer/SKILL.md` (lines 210-258)
- `/home/benjamin/Projects/ProofChecker/specs/archive/637_fix_roadmap_checkboxes_not_updated/reports/research-001.md`
- `/home/benjamin/Projects/ProofChecker/specs/archive/638_add_roadmap_update_to_todo_command/reports/research-001.md`
- `/home/benjamin/Projects/ProofChecker/specs/archive/641_improve_todo_command_roadmap_update/reports/research-002.md`
- `/home/benjamin/Projects/ProofChecker/specs/state.json` (task 666 entry)

### State.json Schema Analysis

**Current schema** (lines 106-117 from rules/state-management.md):
```json
{
  "completion_summary": "Required when status=completed",
  "roadmap_items": ["Optional explicit roadmap item texts to match"],
  "claudemd_suggestions": "Description of .claude/ changes (meta only)"
}
```

**Usage by language**:
- `lean`, `general`, `latex`: Use completion_summary + roadmap_items
- `meta`: Use completion_summary + claudemd_suggestions

**Propagation flow**:
1. Agent writes completion_data to `.return-meta.json`
2. Skill reads metadata file (Stage 6)
3. Skill writes to state.json (Stage 7, lines 237-258)
4. /todo reads from state.json (Step 3.5.2)
5. /review SHOULD read from state.json (currently doesn't for roadmap_items)

### Matching Strategy Effectiveness Analysis

**Scenario 1**: Task with explicit roadmap_items
- /todo: ✅ Matched (priority 1)
- /review: ❌ Not matched (doesn't check roadmap_items)

**Scenario 2**: Task with (Task N) reference already in roadmap
- /todo: ✅ Matched (priority 2)
- /review: ✅ Matched (high confidence)

**Scenario 3**: Task without explicit items or task refs
- /todo: ❌ Not matched (no fallback)
- /review: ⚠️ Maybe matched (unreliable fuzzy)

**Conclusion**: Scenario 1 is the main gap. Fixing /review to check roadmap_items closes this gap.

## Next Steps

Run `/plan 639` to create implementation plan for updating /review command to use explicit roadmap_items matching.
