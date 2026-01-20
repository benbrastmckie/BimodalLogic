# Research Report: Task #650

**Task**: Implement completion_summary and claudemd_suggestions fields in /implement workflow
**Date**: 2026-01-20
**Session**: sess_1768942279_aa151d
**Focus**: completion_summary and claudemd_suggestions fields

## Summary

The `/implement` command workflow needs modifications to populate `completion_summary` and `claudemd_suggestions` fields in state.json when tasks are successfully completed. These fields are consumed by the `/todo` command to update ROAD_MAP.md (for non-meta tasks) and display CLAUDE.md modification suggestions (for meta tasks). The implementation spans three implementation skills (skill-implementer, skill-lean-implementation, skill-latex-implementation) and their postflight operations.

## Findings

### 1. Field Schemas are Well-Defined in state-management.md

The `.claude/rules/state-management.md` file (lines 102-196) provides comprehensive field schemas:

**completion_summary** (Required when status="completed"):
- Type: string
- Format: 1-3 sentence description of what was accomplished
- Used by: /todo command to match against ROAD_MAP.md items

**roadmap_items** (Optional, non-meta tasks only):
- Type: array of strings
- Purpose: Explicit list of ROAD_MAP.md item texts this task addresses
- Priority 1 matching in /todo's Step 3.5.3

**claudemd_suggestions** (Optional, meta tasks only):
- Type: object
- Schema:
  ```json
  {
    "action": "add|update|remove|none",
    "section": "Section Name",
    "rationale": "Why this change is needed",
    "content": "Text to add or updated text",
    "removes": "Text pattern being removed/replaced"
  }
  ```

### 2. Current Implementation Architecture

The /implement workflow follows this delegation chain:

```
/implement command (commands/implement.md)
    |
    v
skill-orchestrator (routes by language)
    |
    +-- skill-implementer (general/meta/markdown)
    |       |
    |       v
    |   general-implementation-agent
    |
    +-- skill-lean-implementation (lean)
    |       |
    |       v
    |   lean-implementation-agent
    |
    +-- skill-latex-implementation (latex)
            |
            v
        latex-implementation-agent
```

### 3. Where Status Transitions to "completed" Happen

Status transitions are handled in the **skill postflight** (not in the agents or command). Each skill has a Stage 7 (postflight status update):

**skill-implementer** (lines 219-264):
- Reads metadata from `.return-meta.json`
- If status is "implemented", updates state.json to "completed"
- Links artifacts to state.json

**skill-lean-implementation** (lines 205-252):
- Same pattern - updates to "completed" in postflight

**skill-latex-implementation** (lines 213-276):
- Same pattern - updates to "completed" in postflight

### 4. Where Completion Fields Should Be Populated

The fields should be populated at the **skill postflight level** (Stage 7 in each skill) because:

1. The skill has access to the full implementation result
2. The skill knows the task language (meta vs non-meta)
3. The skill already updates state.json during postflight
4. The skill can compose `completion_summary` from the artifact summary

**The `/implement` command's CHECKPOINT 2** (commands/implement.md lines 96-118) currently has a placeholder for this:
```bash
# Update state.json with completion_summary field
jq --arg num "$task_number" \
   --arg summary "$completion_summary" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) += {
     completion_summary: $summary
   }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

However, this is **redundant** since skills handle postflight internally. The command's CHECKPOINT 2 should verify the field was populated, not populate it.

### 5. Field Population Logic by Task Type

**For non-meta tasks (general, lean, latex, markdown)**:

```bash
# In skill postflight Stage 7 (if status == "implemented")
# Extract summary from metadata file
summary=$(jq -r '.artifacts[] | select(.type == "summary") | .summary' "$metadata_file")

# Or use the overall result summary
summary=$(jq -r '.summary // "Implementation completed successfully"' "$metadata_file")

# Update state.json with completion_summary
jq --arg summary "$summary" \
   '(.active_projects[] | select(.project_number == '$task_number')) += {
     completion_summary: $summary
   }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**For meta tasks only** (handled by skill-implementer for language="meta"):

```bash
# Determine if CLAUDE.md changes are warranted based on implementation
# This requires analysis of what was implemented

# Example: If the task added a new command
jq '(.active_projects[] | select(.project_number == '$task_number')) += {
  completion_summary: "'"$summary"'",
  claudemd_suggestions: {
    "action": "add",
    "section": "Command Workflows",
    "rationale": "New command added by this task",
    "content": "### /newcmd - Description\n..."
  }
}' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

### 6. When to Populate vs Not Populate

**Always populate completion_summary when**:
- status transitions to "completed" (result.status == "implemented")
- This is mandatory per the schema

**Populate roadmap_items when**:
- Task is NOT meta (language != "meta")
- Task explicitly addresses known roadmap items
- Can be derived from task description or implementation plan

**Populate claudemd_suggestions when**:
- Task is meta (language == "meta")
- Task affects user-visible behavior, commands, or patterns
- Use "action: none" when changes are purely internal

**Do NOT populate any completion fields when**:
- result.status == "partial" (incomplete implementation)
- result.status == "failed" (implementation failed)

### 7. Producer/Consumer Relationship

From `/todo` command documentation (lines 1016-1023):

> **Producer/Consumer Workflow**:
> - `/implement` is the **producer**: populates `completion_summary` and optional `roadmap_items`
> - `/todo` is the **consumer**: extracts these fields via jq and matches against ROAD_MAP.md

This confirms the fields must be populated during the /implement workflow, not later.

### 8. Implementation Gaps Identified

Current state analysis shows:

1. **No completion_summary in archive**: `jq '[.completed_projects[] | select(.completion_summary != null)] | length'` returns 0

2. **Skills don't populate completion fields**: The three implementation skills update status to "completed" but don't add completion_summary or claudemd_suggestions

3. **Agents don't generate these fields**: The agent metadata file schema (return-metadata-file.md) doesn't include completion_summary or claudemd_suggestions

4. **Command CHECKPOINT 2 has placeholder but incomplete logic**: The implement.md command has a placeholder for completion_summary but:
   - Relies on skill result having a summary (not guaranteed)
   - Doesn't handle meta tasks differently
   - Doesn't populate claudemd_suggestions

### 9. Where claudemd_suggestions Content Comes From

For meta tasks, the claudemd_suggestions content should come from:

1. **Implementation plan**: May specify documentation changes needed
2. **Agent analysis**: Agent can analyze what was implemented and suggest documentation
3. **Predefined mappings**: Certain meta task types always need certain documentation

The most practical approach is to have the **general-implementation-agent** generate `claudemd_suggestions` in its metadata file when the task language is "meta", and have the skill propagate it to state.json.

### 10. Summary Field in Metadata File

The return-metadata-file.md schema (line 22) shows the metadata file includes:
```json
{
  "status": "researched|planned|implemented|partial|failed|blocked",
  "artifacts": [...],
  ...
}
```

But the **summary** field at the root level is only mentioned in the artifact objects, not at the top level for the overall implementation. This is a gap - agents should include an overall `summary` field that can become `completion_summary`.

## Recommendations

### 1. Modify Implementation Agents to Generate Completion Data

Add to the metadata file schema for implementation agents:

```json
{
  "status": "implemented",
  "summary": "1-3 sentence completion summary for completion_summary field",
  "completion_data": {
    "completion_summary": "Same as summary, or more detailed",
    "roadmap_items": ["Optional array for non-meta"],
    "claudemd_suggestions": { "For meta tasks only" }
  },
  "artifacts": [...]
}
```

### 2. Modify Skills to Propagate Completion Data

In each skill's postflight (Stage 7), after setting status to "completed":

```bash
# Extract completion data from metadata
completion_summary=$(jq -r '.completion_data.completion_summary // .summary // ""' "$metadata_file")

# For non-meta tasks
roadmap_items=$(jq -c '.completion_data.roadmap_items // null' "$metadata_file")

# For meta tasks
claudemd_suggestions=$(jq -c '.completion_data.claudemd_suggestions // null' "$metadata_file")

# Update state.json with appropriate fields based on language
if [ "$language" = "meta" ]; then
  jq --arg summary "$completion_summary" \
     --argjson suggestions "$claudemd_suggestions" \
     '(.active_projects[] | select(.project_number == '$task_number')) += {
       completion_summary: $summary
     } | if $suggestions != null then
       (.active_projects[] | select(.project_number == '$task_number')) += {
         claudemd_suggestions: $suggestions
       }
     else . end' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
else
  jq --arg summary "$completion_summary" \
     --argjson items "$roadmap_items" \
     '(.active_projects[] | select(.project_number == '$task_number')) += {
       completion_summary: $summary
     } | if $items != null and ($items | length) > 0 then
       (.active_projects[] | select(.project_number == '$task_number)) += {
         roadmap_items: $items
       }
     else . end' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi
```

### 3. Update General-Implementation-Agent for Meta Tasks

Add logic to generate `claudemd_suggestions` when language is "meta":

1. Analyze what was implemented (new files created, patterns used)
2. Check if changes affect user-visible behavior
3. Generate appropriate action (add/update/remove/none)
4. Include in metadata file

### 4. Update Return Metadata File Schema

Extend `.claude/context/core/formats/return-metadata-file.md` to include:

```json
{
  "completion_data": {
    "completion_summary": "string (required for implemented status)",
    "roadmap_items": ["array of strings (optional, non-meta only)"],
    "claudemd_suggestions": { "object (optional, meta only)" }
  }
}
```

### 5. Remove Redundant Command Logic

Remove or simplify the completion_summary population in `/implement` command's CHECKPOINT 2, since skills handle this internally. Keep verification only.

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Agents forget to generate completion_summary | Add validation in skill postflight - require field for implemented status |
| claudemd_suggestions has wrong action type | Document clear criteria for each action type |
| jq escaping issues with suggestion content | Use two-step jq pattern and file-based filters per jq-escaping-workarounds.md |
| roadmap_items don't match ROAD_MAP.md text | Use exact text matching, provide examples in agent instructions |

## Files to Modify

1. **`.claude/agents/general-implementation-agent.md`** - Add completion_data generation logic
2. **`.claude/agents/lean-implementation-agent.md`** - Add completion_summary generation
3. **`.claude/agents/latex-implementation-agent.md`** - Add completion_summary generation
4. **`.claude/skills/skill-implementer/SKILL.md`** - Add postflight propagation of completion fields
5. **`.claude/skills/skill-lean-implementation/SKILL.md`** - Add postflight propagation
6. **`.claude/skills/skill-latex-implementation/SKILL.md`** - Add postflight propagation
7. **`.claude/context/core/formats/return-metadata-file.md`** - Extend schema with completion_data
8. **`.claude/commands/implement.md`** - Simplify CHECKPOINT 2 to verification only

## Next Steps

1. Run `/plan 650` to create a phased implementation plan
2. Phase 1: Update return-metadata-file.md schema
3. Phase 2: Update general-implementation-agent (includes meta task handling)
4. Phase 3: Update lean-implementation-agent and latex-implementation-agent
5. Phase 4: Update all three implementation skills' postflight logic
6. Phase 5: Verify with test implementation and /todo dry-run

## References

- `.claude/rules/state-management.md` - Field schemas (lines 102-196)
- `.claude/commands/todo.md` - Consumer logic (Steps 3.5, 3.6, 5.5, 5.6)
- `.claude/commands/implement.md` - Command workflow
- `.claude/skills/skill-implementer/SKILL.md` - General implementation skill
- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation skill
- `.claude/skills/skill-latex-implementation/SKILL.md` - LaTeX implementation skill
- `.claude/agents/general-implementation-agent.md` - General implementation agent
- `.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
