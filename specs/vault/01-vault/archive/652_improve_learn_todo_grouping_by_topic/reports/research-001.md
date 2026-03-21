# Research Report: Task #652

**Task**: 652 - Improve /learn TODO grouping by topic
**Started**: 2026-01-20T22:08:50Z
**Completed**: 2026-01-20T22:45:00Z
**Effort**: 1 hour
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**:
  - `.claude/skills/skill-learn/SKILL.md` - Current skill implementation
  - `.claude/commands/learn.md` - User-facing command documentation
  - `.claude/docs/examples/learn-flow-example.md` - Flow example documentation
  - `specs/649_improve_learn_note_tag_dependency_handling/reports/research-001.md` - Related predecessor
  - `specs/651_simplify_learn_note_tag_workflow/reports/research-001.md` - Related predecessor
**Artifacts**: specs/652_improve_learn_todo_grouping_by_topic/reports/research-001.md (this file)
**Standards**: report-format.md, artifact-formats.md, state-management.md

## Executive Summary

- Current /learn command creates **one task per selected TODO: tag** with no topic grouping
- FIX: and NOTE: tags are grouped into single fix-it/learn-it tasks, but TODO: tags are not
- The task description states the problem: "creates one task per file or misses TODOs when grouping"
- Implementation requires adding a topic analysis step between TODO selection and task creation
- Recommended approach: cluster TODOs by semantic topic using file context and tag content analysis

## Context & Scope

The `/learn` command scans files for three tag types:
- `FIX:` tags - grouped into a single fix-it task
- `NOTE:` tags - grouped into fix-it AND learn-it tasks
- `TODO:` tags - currently creates **one task per selected item** (Step 8.4)

The task description identifies the issue: "Currently, /learn creates one task per file or misses TODOs when grouping."

**Current behavior** (from SKILL.md Step 8.4, lines 321-343):
```json
For each selected TODO item:
{
  "title": "{tag content, truncated to 60 chars}",
  "description": "{full tag content}\n\nSource: {file}:{line}",
  "language": "{detected from file type}",
  "priority": "medium",
  "effort": "1 hour"
}
```

**Desired behavior** (from task description):
1. Inventory ALL TODO: tags found
2. Analyze topics/themes among them
3. Create grouped tasks that minimize task count while maintaining logical separation

## Findings

### Finding 1: Current TODO Task Creation Logic

**Location**: `.claude/skills/skill-learn/SKILL.md`, Step 8.4 (lines 321-343)

The current implementation creates one task per selected TODO item with no grouping logic:
- User selects individual TODO items in Step 7
- Each selected item becomes a separate task
- No analysis of relationships between TODO items

This approach is inefficient when multiple TODO tags relate to the same topic.

### Finding 2: Example from 04-Metalogic.tex

The LaTeX file has 5 TODO: tags (currently, after some were addressed):

| Line | Content | Potential Topic |
|------|---------|-----------------|
| 123 | Integers make time discrete, need research on temporal order generalization | Canonical frame construction |
| 249 | Address infinite contexts/sets with compactness | Completeness proof scope |
| 264 | State strong formulations with contexts | Formulation style |
| 279 | Port syntactic approach from Boneyard | Alternative proof approach |
| 363 | Explain complexity calculation derivation | Documentation clarity |

A topic-aware grouping might create:
1. **Canonical frame research** (line 123) - standalone research task
2. **Proof scope and formulation** (lines 249, 264) - grouped task
3. **Alternative approaches and documentation** (lines 279, 363) - grouped or separate

### Finding 3: FIX:/NOTE: Grouping Already Exists

The fix-it and learn-it task creation (Steps 8.2a-8.3) already groups multiple tags:
- Fix-it task: "Address {N} items from embedded tags"
- Learn-it task: "Update {N} context files based on learnings"

This pattern can be adapted for TODO grouping by topic.

### Finding 4: Topic Analysis Approaches

Several approaches could identify topics among TODO tags:

**Approach A: File-based grouping**
- Group TODOs by source file
- Simple but doesn't capture cross-file topics
- May create too many tasks (one per file)

**Approach B: Directory-based grouping**
- Group TODOs by directory
- Better for large codebases
- Still misses semantic connections

**Approach C: Keyword/semantic clustering**
- Analyze tag content for common themes
- Uses terms like "proof", "completeness", "canonical", etc.
- More intelligent but requires analysis step

**Approach D: User-guided topic selection**
- After showing TODOs, ask user to group them
- Most flexible but adds interaction complexity
- Could use multi-select with grouping UI

**Recommended**: Hybrid of C and D
1. Auto-suggest topic groups based on content analysis
2. Present grouped suggestions to user
3. User confirms, adjusts, or creates custom groups

### Finding 5: Integration Point in Skill Flow

The grouping logic should be inserted between Steps 7 and 8:

**Current Flow**:
```
Step 7: Individual TODO Selection
  -> User picks which TODO items become tasks
Step 8: Task Creation
  -> One task per selected TODO
```

**Proposed Flow**:
```
Step 7: Individual TODO Selection
  -> User picks which TODO items to address
Step 7.5: Topic Grouping (NEW)
  -> Analyze selected TODOs for topics
  -> Suggest topic groups
  -> User confirms/adjusts groupings
Step 8: Task Creation
  -> One task per topic group
```

### Finding 6: Topic Group Task Template

Each topic group would become a single task:

```json
{
  "title": "{topic summary, derived from content analysis}",
  "description": "Address {N} TODO items related to {topic}:\n\n{list of items with file:line references}",
  "language": "{predominant language from source files}",
  "priority": "medium",
  "effort": "{scaled by item count}"
}
```

### Finding 7: Content Analysis Heuristics

For automated topic detection, consider:

1. **Common word extraction**: Find significant words shared across TODOs
2. **Section proximity**: TODOs in same file section likely related
3. **Language patterns**: "research", "implement", "fix", "document" indicate task types
4. **Domain terms**: "canonical", "completeness", "frame", "semantics" indicate topics

Example clustering for 04-Metalogic.tex:
- "canonical", "frame", "temporal" -> Canonical Frame topic
- "completeness", "contexts", "formulation" -> Completeness Scope topic
- "explain", "document", "check" -> Documentation topic

## Decisions

1. **Add topic grouping step**: Insert Step 7.5 between TODO selection and task creation
2. **Use content analysis**: Analyze TODO content for common themes/terms
3. **User confirmation**: Present suggested groups for user approval/adjustment
4. **Single-item bypass**: If only 1 TODO selected, skip grouping (no benefit)
5. **Preserve individual option**: Allow user to keep TODOs as separate tasks if preferred

## Recommendations

### Phase 1: Add Topic Analysis Infrastructure

**File**: `.claude/skills/skill-learn/SKILL.md`

Add new Step 7.5 after TODO selection:

```markdown
### Step 7.5: Topic Grouping (for multiple TODOs)

**Condition**: User selected "TODO tasks" AND selected more than 1 TODO item

#### 7.5.1: Extract Topic Indicators

For each selected TODO, extract:
- Key terms (nouns, technical terms)
- File section context (e.g., subsection name if available)
- Action type (research, implement, document, fix)

#### 7.5.2: Cluster by Topic

Group TODOs that share:
- 2+ significant terms in common
- Same file section
- Same action type AND related terms

#### 7.5.3: Present Topic Groups

```json
{
  "question": "How should these TODOs be grouped into tasks?",
  "header": "TODO Grouping",
  "multiSelect": false,
  "options": [
    {
      "label": "Accept suggested groups ({N} tasks)",
      "description": "Group 1: {topic1} (3 items), Group 2: {topic2} (2 items)"
    },
    {
      "label": "Keep as separate tasks ({M} tasks)",
      "description": "Create one task per TODO item"
    },
    {
      "label": "Create single combined task",
      "description": "All {total} TODOs in one task"
    }
  ]
}
```

If user selects "Accept suggested groups", proceed with grouped task creation.
```

### Phase 2: Modify Task Creation for Groups

**File**: `.claude/skills/skill-learn/SKILL.md`

Update Step 8.4 to handle topic groups:

```markdown
#### 8.4: Todo-Tasks (if selected)

**Condition**: User selected "TODO tasks" AND selected specific TODO items

**If grouped** (Step 7.5 produced groups):

For each topic group:
```json
{
  "title": "{topic summary from group analysis}",
  "description": "Address {N} TODO items:\n\n{list with file:line refs}",
  "language": "{predominant language}",
  "priority": "medium",
  "effort": "{scaled: 1h base + 30min per additional item}"
}
```

**If individual** (user chose separate tasks or only 1 TODO):

[existing per-item logic]
```

### Phase 3: Update Documentation

**Files to update**:
- `.claude/commands/learn.md` - Add TODO grouping section to workflow
- `.claude/docs/examples/learn-flow-example.md` - Add grouping example

### Phase 4: Implement Topic Extraction Logic

The topic extraction can use simple heuristics:

```
1. Tokenize each TODO content into words
2. Filter to significant terms (remove stopwords, keep domain terms)
3. Build term frequency across all TODOs
4. Group TODOs sharing 2+ high-frequency terms
5. Assign topic label from most common shared terms
```

For the 04-Metalogic.tex example:
- "canonical frame" appears in TODO 123 -> Group A
- "completeness", "contexts" appear in TODOs 249, 264 -> Group B
- Single-mention terms (279, 363) -> Separate or "Misc" group

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Over-grouping unrelated TODOs | Medium | User confirmation step allows adjustment |
| Under-grouping related TODOs | Low | User can manually combine via "single task" option |
| Adds interaction complexity | Medium | Skip grouping for single TODO, clear UI |
| Topic detection accuracy | Medium | Present groups clearly so user can override |
| Longer /learn execution | Low | Analysis is fast; main time is user decisions |

## Appendix

### Files to Modify

1. `.claude/skills/skill-learn/SKILL.md` - Add Step 7.5, update Step 8.4
2. `.claude/commands/learn.md` - Document TODO grouping workflow
3. `.claude/docs/examples/learn-flow-example.md` - Add grouping example

### Current TODO Task Creation (Reference)

From SKILL.md lines 321-343:
```markdown
#### 8.4: Todo-Tasks (if selected)

**Condition**: User selected "TODO tasks" AND user selected specific TODO items

For each selected TODO item:
{
  "title": "{tag content, truncated to 60 chars}",
  "description": "{full tag content}\n\nSource: {file}:{line}",
  "language": "{detected from file type}",
  "priority": "medium",
  "effort": "1 hour"
}

**Language Detection for Todo-Task**:
.lean -> "lean"
.tex  -> "latex"
.md   -> "markdown"
.py/.sh -> "general"
.claude/* -> "meta"
```

### Example Topic Groups for 04-Metalogic.tex

| Group | Topic | TODOs | Suggested Title |
|-------|-------|-------|-----------------|
| A | Canonical Frame | 123 | Research canonical frame temporal order generalization |
| B | Proof Scope | 249, 264 | Improve completeness proof formulation and scope |
| C | Documentation | 363 | Add complexity calculation explanation |
| D | Alternative | 279 | Research syntactic proof approach from Boneyard |

**Potential merged task** (B):
```json
{
  "title": "Improve completeness proof formulation and scope",
  "description": "Address 2 TODO items related to completeness proof structure:\n\n- line 249: Address infinite contexts/sets with compactness\n- line 264: State strong formulations with contexts\n\nSource: Theories/Bimodal/latex/subfiles/04-Metalogic.tex",
  "language": "latex",
  "priority": "medium",
  "effort": "2 hours"
}
```

### User Flow Comparison

**Before (current)**:
```
/learn path/
-> Display 5 TODO tags
-> User selects 4 TODOs
-> Create 4 separate tasks
```

**After (proposed)**:
```
/learn path/
-> Display 5 TODO tags
-> User selects 4 TODOs
-> Analyze topics, suggest 2 groups
-> User confirms grouping
-> Create 2 grouped tasks
```
