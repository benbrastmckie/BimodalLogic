---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument-hint: TASK_NUMBER [FOCUS] [--lean|--logic|--math|--latex|--typst] [--team [--team-size N]]
model: claude-opus-4-5-20251101
---

# /research Command

Conduct research for a task by delegating to the appropriate research skill/subagent.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--lean` | Force routing to `skill-lean-research` | (auto) |
| `--logic` | Force routing to `skill-logic-research` | (auto) |
| `--math` | Force routing to `skill-math-research` | (auto) |
| `--latex` | Force routing to `skill-latex-research` | (auto) |
| `--typst` | Force routing to `skill-researcher` | (auto) |
| `--team` | Enable multi-agent parallel research with multiple teammates | false |
| `--team-size N` | Number of teammates to spawn (2-4) | 2 |

**Domain Override Flags**: The `--lean`, `--logic`, `--math`, `--latex`, and `--typst` flags override automatic language-based routing. Use when the task language does not match the research domain needed. Only one domain flag may be specified at a time; if multiple are given, the first match wins.

When `--team` is specified, research is delegated to `skill-team-research` which spawns multiple research agents working in parallel on different aspects of the task. Each teammate produces a research report, and the lead synthesizes findings into a final comprehensive report.

## Execution

**MCP Safety**: Do not call `lean_diagnostic_messages` or `lean_file_outline` - they hang. Delegate to skills.

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```
   session_id = sess_{timestamp}_{random}
   ```

2. **Lookup Task**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     specs/state.json)
   ```

3. **Validate**
   - Task exists (ABORT if not)
   - Status allows research: not_started, planned, partial, blocked, researched
   - If completed/abandoned: ABORT with recommendation

**ABORT** if any validation fails.

**On GATE IN success**: Task validated. **IMMEDIATELY CONTINUE** to STAGE 1.5 below.

### STAGE 1.5: PARSE DOMAIN FLAGS

**Parse arguments to determine domain override and focus prompt.**

1. **Extract Domain Override**
   Check remaining args (after task number) for domain flags:
   - `--lean` → `domain_override = "lean"`
   - `--logic` → `domain_override = "logic"`
   - `--math` → `domain_override = "math"`
   - `--latex` → `domain_override = "latex"`
   - `--typst` → `domain_override = "typst"`

   If no domain flag found: `domain_override = null`

   If multiple domain flags: Use first match (warn user in output).

2. **Extract Focus Prompt**
   Remove all recognized flags from remaining args:
   - Remove `--lean`, `--logic`, `--math`, `--latex`, `--typst`
   - Remove `--team`, `--team-size N`

   Remaining text is `focus_prompt`.

3. **Determine Effective Domain**
   ```
   effective_domain = domain_override ?? task_language
   ```

   Where `task_language` comes from `task_data.language` in state.json.

**On STAGE 1.5 success**: Domain determined. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After STAGE 1.5, immediately invoke the Skill tool.

**Domain-Based Routing** (use `effective_domain` from STAGE 1.5):

| Effective Domain | Skill to Invoke |
|------------------|-----------------|
| `lean` | `skill-lean-research` |
| `logic` | `skill-logic-research` |
| `math` | `skill-math-research` |
| `latex` | `skill-latex-research` |
| `typst`, `general`, `meta`, `markdown` | `skill-researcher` |

**Invoke the Skill tool NOW** with:
```
skill: "{skill-name from table above}"
args: "task_number={N} focus={focus_prompt} session_id={session_id} domain_override={domain_override}"
```

The `domain_override` parameter is passed to the skill so it can include the override context in its report. The skill will spawn the appropriate agent to conduct research and create a report.

**On DELEGATE success**: Research complete. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts

2. **Verify Artifacts**
   Check each artifact path exists on disk

3. **Verify Status Updated**
   The skill handles status updates internally (preflight and postflight).
   Confirm status is now "researched" in state.json.

**RETRY** skill if validation fails.

**On GATE OUT success**: Artifacts verified. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

**Note**: Use targeted staging to prevent race conditions with concurrent agents. See `.claude/context/core/standards/git-staging-scope.md`.

```bash
git add \
  "specs/${N}_${SLUG}/reports/" \
  "specs/${N}_${SLUG}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
git commit -m "$(cat <<'EOF'
task {N}: complete research

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

```
Research completed for Task #{N}

Report: {artifact_path from skill result}

Summary: {summary from skill result}

Status: [RESEARCHED]
Next: /plan {N}
```

## Error Handling

### GATE IN Failure
- Task not found: Return error with guidance
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [RESEARCHING], log error
- Timeout: Partial research preserved, user can re-run

### GATE OUT Failure
- Missing artifacts: Log warning, continue with available
- Link failure: Non-blocking warning
