# Implementation Plan: Task #713

- **Task**: 713 - Create Lean build repair skill and /lake command
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/713_create_lean_build_repair_skill_and_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create an automated Lean build repair system with a `/lake` command and `skill-lake-repair` direct execution skill. The skill will run `lake build`, parse errors, and automatically fix common mechanical errors (missing pattern match cases, unused variables, unused imports) in an iterative loop until the build succeeds or max retries are reached.

### Research Integration

Research report identifies:
- Direct execution skill pattern (like skill-refresh) is recommended to avoid MCP subagent hanging issues
- `lean_build` MCP tool available with clean option and log output
- Error parsing regex: `/^(.+\.lean):(\d+):(\d+): (error|warning): (.+)$/`
- Three auto-fixable error types: missing cases (HIGH), unused variables (HIGH), unused imports (HIGH)
- Max retry limit of 3-5 recommended with unfixable error detection

## Goals & Non-Goals

**Goals**:
- Create `/lake` command with `--clean`, `--max-retries`, `--dry-run`, `--module` options
- Create `skill-lake-repair` as a direct execution skill
- Implement core build loop with error capture and parsing
- Implement auto-fix for missing pattern match cases
- Support iterative repair with loop prevention (max retries, same-error detection)

**Non-Goals**:
- Auto-fix for type mismatches (requires semantic understanding)
- Auto-fix for failed instance synthesis (complex)
- Auto-fix for unsolved proof goals (requires proof development)
- Confirmation mode (`--confirm`) - future enhancement
- Integration with errors.json tracking - future enhancement

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCP lean_build tool fails | Medium | Medium | Fallback to Bash `lake build` |
| Auto-fix introduces new errors | Medium | Low | Conservative fixes (sorry placeholders), git provides undo |
| Infinite repair loop | Medium | Low | Max retries (3), track fixed errors to detect cycles |
| Complex error patterns not parsed | Low | Medium | Start with well-defined patterns, expand incrementally |

## Implementation Phases

### Phase 1: Command Specification [COMPLETED]

**Goal**: Create the `/lake` command specification file

**Tasks**:
- [ ] Create `.claude/commands/lake.md` with command syntax and options
- [ ] Document `--clean`, `--max-retries`, `--dry-run`, `--module` flags
- [ ] Add examples and expected output formats
- [ ] Follow structure from existing commands (refresh.md, errors.md)

**Timing**: 30 minutes

**Files to create**:
- `.claude/commands/lake.md` - Command specification

**Verification**:
- Command file follows established format
- All options documented with descriptions
- Examples cover common use cases

---

### Phase 2: Skill Core Structure [COMPLETED]

**Goal**: Create skill-lake-repair with basic build loop

**Tasks**:
- [ ] Create `.claude/skills/skill-lake-repair/SKILL.md` with YAML frontmatter
- [ ] Implement argument parsing for command flags
- [ ] Implement Stage 1: Run initial build (MCP lean_build with Bash fallback)
- [ ] Implement Stage 2: Parse build output and detect success/failure
- [ ] Implement Stage 3: Extract error information (file, line, column, message)

**Timing**: 1 hour

**Files to create**:
- `.claude/skills/skill-lake-repair/SKILL.md` - Direct execution skill

**Verification**:
- Skill executes without errors
- Build output is captured correctly
- Error parsing extracts file paths and line numbers
- Success case exits cleanly

---

### Phase 3: Auto-Fix Implementation [COMPLETED]

**Goal**: Implement auto-fix for missing pattern match cases

**Tasks**:
- [ ] Implement error classification (missing_cases, unused_variable, unused_import, other)
- [ ] Parse "Missing cases:" error pattern to extract case names
- [ ] Implement missing case fix: generate `| {CaseName} => sorry` branches
- [ ] Find correct insertion point in file (after last match arm)
- [ ] Implement unused variable fix: add underscore prefix
- [ ] Implement unused import fix: remove import line (with caution)

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/skills/skill-lake-repair/SKILL.md` - Add auto-fix logic

**Verification**:
- Missing cases correctly identified from error output
- Generated case branches compile
- Unused variable warnings resolved
- Original code backed up or easily recoverable via git

---

### Phase 4: Iteration Loop and Completion [COMPLETED]

**Goal**: Complete iterative repair loop with safety controls

**Tasks**:
- [ ] Implement retry loop with max_retries counter
- [ ] Implement fix tracking to detect same-error cycles
- [ ] Implement unfixable error detection (stop if no fixable errors)
- [ ] Implement `--dry-run` mode (show fixes without applying)
- [ ] Implement `--module` option for targeted builds
- [ ] Add progress reporting during iteration
- [ ] Update CLAUDE.md with /lake command documentation (if needed)
- [ ] Register skill in skill-to-agent mapping table

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-lake-repair/SKILL.md` - Add iteration loop
- `.claude/CLAUDE.md` - Add /lake to command documentation (brief mention)

**Verification**:
- Max retries prevents infinite loops
- Same-error cycles detected and stopped
- Dry-run shows proposed fixes without modifying files
- Module-specific builds work correctly
- Documentation updated

## Testing & Validation

- [ ] Run `/lake` on clean build - should succeed immediately
- [ ] Run `/lake` with missing case error - should auto-fix and rebuild
- [ ] Run `/lake --dry-run` with errors - should show fixes without applying
- [ ] Run `/lake --max-retries 1` with unfixable error - should stop after 1 retry
- [ ] Run `/lake --clean` - should execute lake clean before build
- [ ] Run `/lake --module Logos.Layer0.Basic` - should build specific module

## Artifacts & Outputs

- `.claude/commands/lake.md` - Command specification
- `.claude/skills/skill-lake-repair/SKILL.md` - Direct execution skill
- `specs/713_create_lean_build_repair_skill_and_command/summaries/implementation-summary-{DATE}.md` - Implementation summary

## Rollback/Contingency

If auto-fix causes issues:
1. Git provides full undo capability (`git checkout -- path/to/file`)
2. All fixes use `sorry` placeholders that compile but indicate incomplete work
3. Remove skill from CLAUDE.md and delete skill directory to disable
4. Users can always run `lake build` directly without the skill
