# Command Reference

Full reference for all available commands. For quick overview, see CLAUDE.md.

## Command Table

| Command | Usage | Description |
|---------|-------|-------------|
| `/task` | `/task "Description"` | Create new task with description |
| `/task` | `/task --recover N` | Recover a blocked/partial task |
| `/task` | `/task --expand N` | Break task into subtasks |
| `/task` | `/task --sync` | Synchronize TODO.md and state.json |
| `/task` | `/task --abandon N` | Abandon a task |
| `/research` | `/research N [focus]` | Research task, route by language |
| `/research` | `/research N --lean` | Force Lean research (skill-lean-research) |
| `/research` | `/research N --logic` | Force logic research (skill-logic-research) |
| `/research` | `/research N --math` | Force math research (skill-math-research) |
| `/research` | `/research N --latex` | Force LaTeX research (skill-latex-research) |
| `/research` | `/research N --typst` | Force Typst research (skill-researcher) |
| `/research` | `/research N --team` | Research with multiple agents |
| `/research` | `/research N --team --team-size M` | Research with M agents |
| `/plan` | `/plan N` | Create implementation plan |
| `/plan` | `/plan N --team` | Create plan with multiple agents |
| `/implement` | `/implement N` | Execute plan, resume from incomplete phase |
| `/implement` | `/implement N --team` | Implement with multiple agents |
| `/revise` | `/revise N` | Create new plan version |
| `/review` | `/review` | Analyze codebase, load ROADMAP.md, propose updates |
| `/todo` | `/todo` | Archive completed/abandoned tasks, sync metrics |
| `/errors` | `/errors` | Analyze error patterns, create fix plans |
| `/meta` | `/meta` | System builder for .claude/ changes |
| `/learn` | `/learn [PATH...]` | Scan for FIX:/NOTE:/TODO: tags |
| `/lake` | `/lake` | Build Lean project |
| `/lake` | `/lake --clean` | Clean build |
| `/lake` | `/lake --max-retries N` | Build with automatic error repair |
| `/refresh` | `/refresh` | Clean orphaned processes and old files |
| `/refresh` | `/refresh --dry-run` | Preview cleanup without executing |
| `/refresh` | `/refresh --force` | Force cleanup without confirmation |

## Command Lifecycle

All commands follow checkpoint-based execution:

1. **GATE IN (Preflight)**
   - Parse and validate arguments
   - Check task exists and status allows operation
   - Update status to "in progress" variant
   - Generate session ID

2. **DELEGATE**
   - Route to appropriate skill by language
   - Execute skill (skill owns preflight/delegate/postflight)

3. **GATE OUT (Postflight)**
   - Validate return structure
   - Update status to completed variant
   - Create/link artifacts

4. **COMMIT**
   - Git commit with session ID
   - Return results to user

## Language-Based Routing

| Language | Research Tools | Implementation Tools |
|----------|----------------|---------------------|
| `lean` | lean_leansearch, lean_loogle, lean_leanfinder | lean_goal, lean_hover_info, lean_multi_attempt |
| `latex` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash (pdflatex) |
| `typst` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash (typst compile) |
| `general` | WebSearch, WebFetch, Read | Read, Write, Edit, Bash |
| `meta` | Read, Grep, Glob | Write, Edit |

## Session ID

Format: `sess_{unix_timestamp}_{6_char_random}`

Generated at GATE IN, passed through delegation, included in commits.

## Team Mode

Team commands (`--team` flag) spawn multiple agents in parallel:
- Default team size varies by task complexity
- Use `--team-size N` to specify exact number of agents
- Team lead synthesizes results from all teammates

## Utility Scripts

- `.claude/scripts/export-to-markdown.sh` - Export .claude/ directory to consolidated markdown file
- `.claude/scripts/setup-lean-mcp.sh` - Configure lean-lsp MCP in user scope
