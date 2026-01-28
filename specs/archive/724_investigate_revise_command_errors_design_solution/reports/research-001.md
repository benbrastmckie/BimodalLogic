# Research Report: Task #724

**Task**: 724 - Investigate /revise command errors and design solution
**Started**: 2026-01-28T12:00:00Z
**Completed**: 2026-01-28T12:15:00Z
**Effort**: 1 hour
**Priority**: High
**Dependencies**: None
**Sources/Inputs**:
- `.claude/output/revise.md` - Error transcript
- `.claude/commands/revise.md` - Command specification
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - Existing workaround documentation
- Various skill files and shell scripts
**Artifacts**:
- specs/724_investigate_revise_command_errors_design_solution/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- Root cause identified: Claude Code's Bash tool escapes `!=` as `\!=` when generating jq commands inline, causing `INVALID_CHARACTER` parse errors
- This is a **variant** of Issue #1132 (previously documented as pipe injection), but the escaping mechanism appears to also affect the `!=` operator
- 15+ files in `.claude/` contain vulnerable patterns that may fail when Claude generates similar commands
- Three proven workarounds exist: shell script encapsulation, file-based jq filters, and operator inversion with `del()`

## Context & Scope

The user reported errors in `/home/benjamin/Projects/ProofChecker/.claude/output/revise.md` when running the `/revise 681` command. The task was to identify the root cause and design solutions applicable to similar issues across the system.

## Findings

### 1. Error Analysis

The error transcript at `.claude/output/revise.md` shows two failed jq commands (lines 62-72 and 79-88):

```
jq: error: syntax error, unexpected INVALID_CHARACTER, expecting ';' or ')' at <top-level>, line 2, column 98:
        ([(.active_projects[] | select(.project_number == 681)).artifacts // [] | .[] | select(.type \!= "plan")] + ...
                                 ^
```

**Key observation**: The error shows `select(.type \!= "plan")` with a backslash before `!`. The original command in `revise.md` line 82 has `select(.type != "plan")` (no backslash).

### 2. Root Cause

Claude Code's Bash tool transforms certain characters when executing commands. In this case:
- **Input**: `select(.type != "plan")`
- **Output**: `select(.type \!= "plan")`

The backslash escaping of `!=` creates an invalid jq expression. This is similar to Issue #1132 which documented `< /dev/null` injection with pipe operators, but represents a distinct escaping behavior.

### 3. Affected Components

The following files contain `select(.type != ...)` patterns vulnerable to this issue:

**Commands** (1 file):
- `.claude/commands/revise.md` line 82

**Skills** (7 files):
- `.claude/skills/skill-typst-implementation/SKILL.md` line 250
- `.claude/skills/skill-lean-research/SKILL.md` line 296
- `.claude/skills/skill-latex-implementation/SKILL.md` line 251
- `.claude/skills/skill-planner/SKILL.md` line 212
- `.claude/skills/skill-researcher/SKILL.md` line 205
- `.claude/skills/skill-lean-implementation/SKILL.md` line 390
- `.claude/skills/skill-implementer/SKILL.md` line 306

**Context/Patterns** (2 files):
- `.claude/context/core/patterns/inline-status-update.md` lines 85, 110, 135
- `.claude/context/core/patterns/jq-escaping-workarounds.md` (documents workarounds but examples still contain vulnerable patterns)

**Shell Scripts** (3 files - NOT affected when run directly):
- `.claude/scripts/postflight-plan.sh` line 59
- `.claude/scripts/postflight-research.sh` line 59
- `.claude/scripts/postflight-implement.sh` line 59

**Note**: Shell scripts work correctly because they are executed directly by the system, not through Claude Code's Bash tool which performs the escaping.

### 4. Why Some Commands Work

The `/revise` command successfully executed the first jq command (status update, line 55-57) because it did not contain a `!=` operator. The failure occurred only on the artifact update step which used `select(.type != "plan")`.

### 5. Existing Workarounds

The `/todo` command (lines 1086-1113) documents three proven workarounds:

#### A. File-based Filters
```bash
# Instead of: jq 'select(.language != "meta")' file
cat > /tmp/filter_$$.jq << 'EOF'
select(.language != "meta")
EOF
jq -f /tmp/filter_$$.jq file && rm -f /tmp/filter_$$.jq
```

#### B. Use `has()` for Null Checks
```bash
# Instead of: jq 'select(.field != null)'
jq 'select(has("field"))'
```

#### C. Use `del()` for Exclusion (Operator Inversion)
```bash
# Instead of: jq '.array |= map(select(.status != "completed"))'
jq 'del(.array[] | select(.status == "completed"))'
```

### 6. Design Pattern: Shell Script Encapsulation

The existing `postflight-*.sh` scripts demonstrate the safest pattern:
1. Shell scripts contain the vulnerable jq patterns
2. Commands/skills call the shell script via `Bash(.claude/scripts/postflight-plan.sh $task_number $path)`
3. The script executes directly, bypassing Claude Code's escaping

This pattern:
- Centralizes jq logic in tested shell scripts
- Eliminates escaping issues entirely
- Provides reusable, version-controlled components
- Already partially implemented but not consistently used

## Recommendations

### Immediate Fix (Task 724)

1. **Update `/revise` command** to call `postflight-plan.sh` instead of inline jq:
   ```bash
   .claude/scripts/postflight-plan.sh {task_number} "{new_plan_path}" "Revised plan v{N}"
   ```

### Systematic Fix (Follow-up Tasks)

2. **Audit all skills** for inline jq with `!=` and refactor to use postflight scripts
3. **Update `jq-escaping-workarounds.md`** to document the `!=` escaping issue explicitly (currently only documents pipe injection)
4. **Create additional postflight scripts** if needed for specialized operations
5. **Add CI/linting** to detect `!=` in jq patterns within markdown command files

### Design Principles

For future commands and skills:

| Pattern | Risk Level | Recommendation |
|---------|------------|----------------|
| Inline jq with `!=` | HIGH | Avoid - use script or `del()` |
| Inline jq with `\|` in arrays | HIGH | Avoid - use two-step pattern |
| Call to postflight script | SAFE | Preferred approach |
| File-based jq filter | SAFE | Good for complex filters |
| `del()` instead of `select(!=)` | SAFE | Good inline alternative |

## Decisions

1. The `\!=` escaping is confirmed as root cause (not a Bash history expansion issue since we're using single quotes)
2. Shell script encapsulation is the most robust solution
3. Existing postflight scripts are correctly implemented and should be reused
4. The `/revise` command should be updated to use `postflight-plan.sh`

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Other commands have same issue | Medium | Audit complete - 7 skills affected |
| Script path changes break calls | Low | Use relative paths from project root |
| New developers add vulnerable patterns | Medium | Document in CLAUDE.md, add to code review checklist |

## Appendix

### Search Queries Used

1. `select(.type != ...)` pattern search across `.claude/`
2. `INVALID_CHARACTER` error pattern search
3. `jq.*!=` pattern to find all jq inequality operators
4. `postflight*.sh` to find existing safe implementations

### References

- Claude Code Issue #1132: Bash tool escaping bugs
- `.claude/context/core/patterns/jq-escaping-workarounds.md`
- `.claude/commands/todo.md` lines 1086-1113 (workaround documentation)
- `.claude/scripts/postflight-plan.sh` (working implementation)

### Files to Modify (Implementation Scope)

**Priority 1 (Blocking)**:
- `.claude/commands/revise.md` - Use postflight script

**Priority 2 (Preventive)**:
- `.claude/skills/skill-typst-implementation/SKILL.md`
- `.claude/skills/skill-lean-research/SKILL.md`
- `.claude/skills/skill-latex-implementation/SKILL.md`
- `.claude/skills/skill-planner/SKILL.md`
- `.claude/skills/skill-researcher/SKILL.md`
- `.claude/skills/skill-lean-implementation/SKILL.md`
- `.claude/skills/skill-implementer/SKILL.md`

**Priority 3 (Documentation)**:
- `.claude/context/core/patterns/jq-escaping-workarounds.md` - Add `!=` escaping documentation
- `.claude/context/core/patterns/inline-status-update.md` - Update examples
