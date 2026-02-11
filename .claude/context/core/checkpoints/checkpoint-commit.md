# Checkpoint: COMMIT (Finalization)

The COMMIT checkpoint creates a git commit and completes the operation.

## Execution Steps

### 1. Stage Changes (Targeted Staging)

**IMPORTANT**: Do NOT use `git add -A`. Use targeted staging to prevent race conditions with concurrent agents.

See `.claude/context/core/standards/git-staging-scope.md` for agent-specific allowed files.

```bash
# Stage task-specific files (adjust based on agent type)
git add \
  "specs/${task_number}_${project_name}/" \
  "specs/TODO.md" \
  "specs/state.json"
# Add implementation files based on language (Theories/, docs/, .claude/, etc.)
```

### 2. Compose Commit Message

Format depends on operation:

**Research:**
```
task {N}: complete research

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Plan:**
```
task {N}: create implementation plan

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Implementation (complete):**
```
task {N}: complete implementation

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Implementation (partial):**
```
task {N}: partial implementation (phases 1-{M} of {total})

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

**Implementation (phase):**
```
task {N} phase {P}: {phase_name}

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```

### 3. Create Commit

```bash
git commit -m "$(cat <<'EOF'
{commit_message}
EOF
)"
```

### 4. Verify Commit

```bash
# Verify commit was created
if [ $? -eq 0 ]; then
  commit_hash=$(git rev-parse HEAD)
  echo "Commit created: $commit_hash"
else
  echo "WARNING: Commit failed (non-blocking)"
fi
```

### 5. Log Session Completion

Record in operation log (optional):
- session_id
- operation
- task_number
- commit_hash
- timestamp

## Error Handling

Git commit failures are **non-blocking**:
- Log the failure
- Do not roll back state updates
- Report to user that commit failed
- Continue with success return

## Output

Return to caller:
```json
{
  "status": "completed|partial|failed",
  "summary": "{operation summary}",
  "artifacts": [{artifact_list}],
  "metadata": {
    "session_id": "{session_id}",
    "commit_hash": "{hash or null}",
    "phases_completed": {N},
    "phases_total": {M}
  },
  "next_steps": "{guidance}"
}
```
