# Research Report: Task #713

- **Task**: 713 - Create Lean build repair skill and /lake command
- **Started**: 2026-01-28T12:00:00Z
- **Completed**: 2026-01-28T12:45:00Z
- **Effort**: 45 minutes
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**:
  - Codebase: `.claude/skills/`, `.claude/commands/`, `.claude/agents/`
  - Codebase: `.claude/context/project/lean4/tools/mcp-tools-guide.md`
  - Codebase: `.claude/skills/skill-lean-implementation/SKILL.md`
  - Codebase: `.claude/skills/skill-refresh/SKILL.md` (direct execution pattern)
  - Lake build system documentation (local testing)
- **Artifacts**: specs/713_create_lean_build_repair_skill_and_command/reports/research-001.md
- **Standards**: report-format.md, artifact-formats.md

## Executive Summary

- A `/lake` command with automated build repair is feasible using direct execution skill pattern
- The `lean_build` MCP tool provides build functionality with clean option and log output
- Error parsing is straightforward: Lean errors follow `{file}:{line}:{col}: error: {message}` format
- Auto-fix strategies should focus on common, mechanically-fixable errors (missing cases, unused imports)
- Iterative repair loop should have max retry limit (3-5) and unfixable error detection
- Recommend direct execution pattern (like skill-refresh) to avoid MCP hanging issues in subagents

## Context & Scope

Task 713 requests creation of an automated Lean build repair skill with a `/lake` command that:
1. Runs `lake clean` and `lake build`
2. Parses build errors
3. Automatically fixes common errors
4. Retries build until success or max retries

This research explores existing patterns, error formats, and implementation strategies.

## Findings

### 1. Existing Skill Patterns

#### Direct Execution Skills (Recommended Pattern)

The codebase has moved toward direct execution skills due to MCP tool hanging issues in subagents (Claude Code bugs #15945, #13254, #4580). Key examples:

**skill-lean-implementation** (`.claude/skills/skill-lean-implementation/SKILL.md`):
- Uses direct execution with inline MCP tool calls
- Handles `lean_goal`, `lean_diagnostic_messages`, `lean_build` directly
- Includes MCP error recovery patterns (retry, fallback, continue with partial)

**skill-refresh** (`.claude/skills/skill-refresh/SKILL.md`):
- Simple direct execution skill
- Uses Bash to run cleanup scripts
- Good template for utility command skill

**skill-status-sync**:
- Direct execution for state updates
- Uses Bash (jq) and Edit tools

#### Thin Wrapper Pattern (Deprecated for MCP-heavy skills)

Skills that delegate to subagents via Task tool cannot reliably use MCP tools due to platform bugs. The thin wrapper pattern should be avoided for this skill.

### 2. Lake Build System

#### Available Commands

```bash
# Clean build artifacts
lake clean

# Build project
lake build

# Build specific module
lake build Bimodal.Semantics

# Build with output
lake build 2>&1 | tee build.log
```

#### MCP Tool: `lean_build`

The `lean_build` MCP tool provides integrated build functionality:

```
Parameters:
- lean_project_path: Path to Lean project (optional, defaults to current)
- clean: Run lake clean first (default: false) - SLOW
- output_lines: Return last N lines of build log (default: 20)
```

**Behavior**:
- Builds project and restarts LSP
- Returns last N lines of build output
- `clean: true` runs full rebuild (slow but thorough)

### 3. Lean Error Patterns and Auto-Fix Strategies

#### Error Message Format

Lean errors follow a consistent format:
```
{file}:{line}:{col}: error: {error_type}
{additional context}
```

Examples observed:
```
/path/to/file.lean:2:18: error: Type mismatch
  "hello"
has type
  String
but is expected to have type
  Nat

/path/to/file.lean:6:2: error: Missing cases:
Color.blue
Color.green
```

#### Common Error Types and Auto-Fix Strategies

| Error Type | Pattern | Auto-Fix Feasibility | Strategy |
|------------|---------|---------------------|----------|
| **Missing cases** | `error: Missing cases:\n{case1}\n{case2}` | HIGH | Generate `\| {case} => sorry` for each case |
| **Unknown identifier** | `error: unknown identifier '{name}'` | MEDIUM | Search imports, add if found |
| **Unused variable** | `unused variable` (warning) | HIGH | Add underscore prefix `_var` |
| **Type mismatch** | `error: Type mismatch` | LOW | Requires semantic understanding |
| **Failed to synthesize** | `failed to synthesize instance` | LOW | Requires instance discovery |
| **Unsolved goals** | `unsolved goals` | LOW | Requires proof development |

#### Recommended Auto-Fixable Errors

**Phase 1 (Implement)**:
1. **Missing pattern match cases**: Parse missing case names, generate placeholder branches
2. **Unused import warnings**: Remove unused imports
3. **Unused variable warnings**: Add underscore prefix

**Phase 2 (Future enhancement)**:
1. Unknown identifier with obvious import
2. Missing instance with standard derivation

### 4. Iterative Repair Loop Design

#### Recommended Architecture

```
┌────────────────────────────────────────┐
│           /lake command                │
│  (parse args: --clean, --max-retries)  │
└─────────────────┬──────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────┐
│        skill-lake-repair               │
│      (direct execution skill)          │
└─────────────────┬──────────────────────┘
                  │
                  ▼
┌────────────────────────────────────────┐
│     Stage 1: Initial Build             │
│  - lake clean (if --clean)             │
│  - lake build                          │
│  - Capture output                      │
└─────────────────┬──────────────────────┘
                  │
                  ▼
         ┌───────┴───────┐
         │ Build success?│
         └───────┬───────┘
           yes   │   no
            │    │
            ▼    ▼
        ┌────┐  ┌────────────────────────┐
        │Done│  │  Stage 2: Parse Errors │
        └────┘  │  - Extract file:line   │
                │  - Identify error type │
                │  - Check if auto-fixable│
                └──────────┬─────────────┘
                           │
                           ▼
                  ┌────────┴────────┐
                  │  Fixable errors? │
                  └────────┬────────┘
                    yes    │    no
                     │     │
                     ▼     ▼
  ┌─────────────────┐   ┌─────────────────┐
  │ Stage 3: Apply  │   │ Report unfixable│
  │   Auto-Fixes    │   │ errors and stop │
  │ - Edit files    │   └─────────────────┘
  │ - Track changes │
  └────────┬────────┘
           │
           ▼
  ┌─────────────────┐
  │ Stage 4: Retry  │
  │ build (up to N) │──┐
  └────────┬────────┘  │
           │           │
      success          │ max retries
           │           │
           ▼           ▼
       ┌────┐   ┌────────────────┐
       │Done│   │Return partial  │
       └────┘   │with progress   │
                └────────────────┘
```

#### Stop Conditions

1. **Build succeeds**: Return success
2. **Max retries reached**: Default 3-5 attempts
3. **No fixable errors**: All remaining errors are unfixable
4. **Same errors repeated**: Detect infinite loop (fix didn't work)
5. **Critical error**: Syntax error, corrupt file, etc.

#### User Interaction Model

**Fully Automatic (Default)**:
- Attempt auto-fixes without confirmation
- Report all changes made at end
- User can review and revert if needed

**Confirmation Mode (--confirm flag)**:
- Show each proposed fix
- Ask for confirmation before applying
- Useful for sensitive codebases

### 5. Command Design

#### Syntax

```
/lake [options]

Options:
  --clean         Run lake clean before build
  --max-retries N Maximum auto-fix attempts (default: 3)
  --confirm       Confirm each fix before applying
  --dry-run       Show what would be fixed without changing files
  --module NAME   Build specific module only
```

#### Example Usage

```bash
# Basic build with auto-repair
/lake

# Clean rebuild with auto-repair
/lake --clean

# Preview fixes without applying
/lake --dry-run

# Build specific module
/lake --module Bimodal.Semantics

# More retries for complex fix scenarios
/lake --max-retries 5
```

### 6. Integration with Existing Tools

#### MCP Tools to Use

| Tool | Purpose |
|------|---------|
| `lean_build` | Initial build, trigger rebuild after fixes |
| `lean_diagnostic_messages` | Get detailed error info for specific file/line |
| `lean_hover_info` | Get type info when analyzing fixes |
| `lean_local_search` | Find identifiers for unknown identifier fixes |

#### Bash Tools

```bash
# Parse error output
lake build 2>&1 | grep -E "^.*\.lean:[0-9]+:[0-9]+: error:"

# Count errors
lake build 2>&1 | grep -c ": error:"

# Extract file paths
lake build 2>&1 | grep -oE "^[^:]+\.lean" | sort -u
```

### 7. File Structure

```
.claude/
├── commands/
│   └── lake.md                    # Command specification
└── skills/
    └── skill-lake-repair/
        └── SKILL.md               # Direct execution skill
```

No separate agent needed due to direct execution pattern.

## Decisions

1. **Direct execution pattern**: Use skill-lake-repair with inline execution (no subagent)
2. **Phased auto-fix**: Start with missing cases only, expand later
3. **Conservative defaults**: max-retries=3, no clean by default
4. **Git safety**: No automatic commits; user reviews changes
5. **MCP fallback**: Use Bash `lake build` if `lean_build` MCP tool fails

## Recommendations

### Implementation Priority

1. **Phase 1: Core Infrastructure**
   - Create `/lake` command specification
   - Create `skill-lake-repair` direct execution skill
   - Implement basic build loop with error capture
   - Implement missing case auto-fix

2. **Phase 2: Error Parsing**
   - Build comprehensive error parser
   - Categorize errors by fixability
   - Track fix attempts and results

3. **Phase 3: Additional Auto-Fixes**
   - Unused import removal
   - Unused variable underscore prefix
   - Unknown identifier with import suggestion

4. **Phase 4: Polish**
   - Dry-run mode
   - Confirmation mode
   - Progress reporting
   - Integration with error tracking (errors.json)

### Key Implementation Notes

1. **Error Parsing Regex**:
   ```
   /^(.+\.lean):(\d+):(\d+): (error|warning): (.+)$/
   ```

2. **Missing Cases Fix Template**:
   ```lean
   | {CaseName} => sorry  -- TODO: implement
   ```

3. **Max Retry Logic**:
   ```
   retries = 0
   while retries < max_retries:
     build()
     if success: break
     errors = parse_errors()
     fixable = filter_fixable(errors)
     if not fixable: break
     if fixable == last_fixable: break  # prevent loop
     apply_fixes(fixable)
     retries++
   ```

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| MCP tool fails during build | Medium | High | Fallback to Bash `lake build`, apply MCP recovery pattern |
| Auto-fix breaks code | Low | Medium | Conservative fixes only (missing cases as sorry), git provides undo |
| Infinite fix loop | Low | Medium | Track fixed errors, detect same error repeated |
| Large project slow build | Medium | Low | Support `--module` for focused builds |
| Complex errors not fixable | High | Low | Report clearly, suggest manual fixes |

## Appendix

### A. Error Pattern Examples

**Missing cases**:
```
Theories/Bimodal/Syntax.lean:45:2: error: Missing cases:
Formula.implies
Formula.iff
```

**Type mismatch**:
```
Logos/Layer1/Soundness.lean:123:15: error: Type mismatch
  hValid
has type
  Model.Valid M φ
but is expected to have type
  Frame.Valid F φ
```

**Unknown identifier**:
```
Logos/Layer0/Basic.lean:67:10: error: unknown identifier 'Classical.em'
```

### B. Related Codebase Files

- `.claude/skills/skill-lean-implementation/SKILL.md` - Lean implementation patterns
- `.claude/context/project/lean4/tools/mcp-tools-guide.md` - MCP tool reference
- `.claude/context/core/patterns/mcp-tool-recovery.md` - Error recovery patterns
- `.claude/rules/lean4.md` - Lean development rules
- `.claude/commands/errors.md` - Error analysis command (pattern for error handling)

### C. References

- Lake documentation: https://github.com/leanprover/lake
- Lean 4 error messages: https://lean-lang.org/lean4/doc/
- MCP lean-lsp-mcp: lean-lsp MCP server documentation
