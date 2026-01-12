# Command Routing Context

Token budget: ~200 tokens

## Language → Skill Routing

| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| lean | skill-lean-research | skill-lean-implementation |
| latex | skill-researcher | skill-latex-implementation |
| general | skill-researcher | skill-implementer |
| meta | skill-researcher | skill-implementer |
| markdown | skill-researcher | skill-implementer |

## Status Transitions

| Command | From Status | To Status (In-Progress) | To Status (Complete) |
|---------|-------------|------------------------|---------------------|
| /research | not_started | researching | researched |
| /plan | researched, not_started | planning | planned |
| /implement | planned, implementing, partial | implementing | completed |
| /revise | planned, implementing | planning | planned |

## Task Lookup

```bash
jq -r --arg num "$N" '.active_projects[] | select(.project_number == ($num | tonumber))' .claude/specs/state.json
```

## Session ID

```bash
sess_$(date +%s)_$(head -c 3 /dev/urandom | xxd -p)
```
