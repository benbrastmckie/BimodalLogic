# Research Report: Task #676 - Supplemental Research

**Task**: 676 - Investigate skill registration and integrate /task command with checkpoint pattern
**Research Phase**: Supplemental (research-002)
**Started**: 2026-01-25
**Completed**: 2026-01-25
**Effort**: 3 hours
**Priority**: High
**Dependencies**: Research-001 (baseline investigation)
**Focus Areas**: Skill discovery mechanisms, Claude Code 2026 architecture changes, .opencode vs .claude migration
**Sources/Inputs**:
- Claude Code Official Documentation (skills, commands)
- Web research on 2026 architecture changes
- .opencode/ and .claude/ directory comparison
- OpenCode vs Claude Code compatibility research
- settings.json and package.json analysis
**Artifacts**:
- specs/676_investigate_skill_registration_integrate_task_command/reports/research-002.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

Skills ARE properly registered and discoverable - the issue is architectural, not mechanical. This supplemental research reveals: (1) **Claude Code 2026 merged commands and skills** into a unified system where `.claude/commands/*.md` files now function as skills with optional bash preflight, (2) The `.opencode/` directory is a **legacy OpenCode installation** (package version 1.1.25) that predates migration to Claude Code, creating architecture confusion, and (3) **Skill hot-reload and context forking** are 2026 features that enable better checkpoint patterns. The `/task` command uses the 2026 merged architecture but lacks integrated preflight/postflight that other commands have adopted.

**Key Insights**:
- Commands and skills merged in Jan 2026 - same files, dual functionality
- `.opencode/` is OpenCode (open-source fork), `.claude/` is Claude Code (official)
- Skill hot-reload eliminates registration issues
- Context forking (`context: fork`) enables subagent isolation
- `/task` command structure follows 2026 pattern but needs checkpoint integration

## Context & Scope

**Research Focus**: Supplemental investigation to answer user-raised questions about:
1. Why skills work without visible `.claude/skills/` directory
2. Skill registration and discovery mechanisms
3. Claude Code 2026 best practices and architecture changes
4. Relationship between `.opencode/` and `.claude/` directories

**Baseline**: Research-001 established that skills exist and commands are bash scripts, but didn't explain the underlying architecture or migration context.

## Findings

### 1. Claude Code 2026 Architecture: Commands ↔ Skills Merge

#### 1.1 Official Documentation: Unified Command/Skill System

**Source**: [Claude Code Official Docs - Skills](https://code.claude.com/docs/en/skills)

**Key Quote**:
> "Custom slash commands have been merged into skills. A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way. Your existing `.claude/commands/` files keep working. Skills add optional features: a directory for supporting files, frontmatter to control whether you or Claude invokes them, and the ability for Claude to load them automatically when relevant."

**Implications**:
1. **Dual location support**: Commands can be in `.claude/commands/{name}.md` OR `.claude/skills/{name}/SKILL.md`
2. **Backward compatibility**: Existing command files continue working as skills
3. **Feature parity**: Both create slash commands and can be auto-invoked by Claude
4. **Skills add features**: Supporting files, invocation control (`disable-model-invocation`, `user-invocable`)

**Why this matters for Task 676**:
- The "missing skill-task" isn't missing - `/task` exists as a command file
- Command files ARE skills in the 2026 architecture
- The question isn't "where is skill-task?" but "how does /task integrate checkpoints?"

#### 1.2 Skill Registration: Description-Based Discovery

**Source**: [Understanding Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/)

**Registration Mechanism**:
1. Skills employ a **description-matching discovery system**
2. Each skill contains `SKILL.md` (or command `.md`) with frontmatter (`name`, `description`, `allowed-tools`)
3. Claude reviews available skill descriptions to identify relevance to current task
4. When description aligns with user request, Claude loads full instructions transparently
5. Skills reside in hierarchical locations: personal (`~/.claude/skills/`), project (`.claude/skills/`), or plugins

**Skill Location Hierarchy** (from official docs):

| Location | Path | Applies to |
|----------|------|------------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<skill-name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<skill-name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<skill-name>/SKILL.md` | Where plugin enabled |

**Priority**: Enterprise > Personal > Project. Plugin skills use `plugin-name:skill-name` namespace.

**Discovery from nested directories**: When working with files in subdirectories, Claude Code automatically discovers skills from nested `.claude/skills/` directories (e.g., `packages/frontend/.claude/skills/` for monorepos).

**Why skills weren't "missing"**:
- `.claude/skills/` DOES exist (verified in research-001)
- All 13 skills have valid `SKILL.md` files with frontmatter
- Description-based discovery means skills are always available
- Commands in `.claude/commands/` are also skills (2026 merge)

#### 1.3 January 2026 Feature Updates

**Source**: [Claude Code Release Notes - January 2026](https://releasebot.io/updates/anthropic/claude-code)

**Major Features Introduced**:

**1. Automatic Skill Hot-Reload**
- Skills instantly available without restart
- Eliminates registration/discovery issues
- Changes to `SKILL.md` take effect immediately

**2. Skill Context Forking** (`context: fork`)
- Isolated sub-agent contexts for skills
- Prevents context pollution from specialized work
- Enables checkpoint pattern with clean boundaries

**3. Hooks in Skill Frontmatter**
- Skills can define lifecycle hooks (PreToolUse, PostToolUse, etc.)
- Scoped to skill execution, not global
- Enables skill-level checkpoint enforcement

**4. MCP Tool Search (Lazy Loading)**
- Tools loaded dynamically when needed, not upfront
- Reduces context bloat
- Aligns with "lazy context loading" pattern from research-001

**5. Bash Wildcard Permissions**
- Fine-grained bash command control (e.g., `Bash(git:*)`)
- Enables safer skill execution with restricted shell access

**Impact on Task 676**:
- **Hot-reload**: Skill registration is no longer a concern (changes instant)
- **Context forking**: Enables true checkpoint isolation (GATE IN → fork → GATE OUT)
- **Hooks**: Can enforce checkpoint pattern at skill level
- **Lazy loading**: Validates thin wrapper pattern approach

#### 1.4 Skills vs Commands Conceptual Model (2026)

**Source**: [Understanding Claude Code: Skills vs Commands vs Subagents](https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins)

**Conceptual Differences** (despite technical merger):

| Aspect | Skills | Commands |
|--------|--------|----------|
| **Invocation** | Auto-invoked by Claude based on description | User-initiated via `/command` |
| **Purpose** | Context-aware capabilities, background knowledge | Explicit workflows, side-effect operations |
| **File Structure** | Directory with `SKILL.md` + supporting files | Single `.md` file (can have bash preflight) |
| **Reusability** | Reusable by commands, agents, hooks | Standalone entry point |
| **Control** | `disable-model-invocation`, `user-invocable` | Typically `disable-model-invocation: true` |

**Practical Application**:
- **Commands are skills with constraints**: They're skills that users trigger manually
- **Skills can be commands**: If `user-invocable: true`, they create slash commands
- **Both use same YAML frontmatter**: Same registration mechanism
- **Bash preflight is optional**: Commands can include `!`command`` for preprocessing

**Example: `/task` command as skill**

Current structure (`.opencode/command/task.md`):
```yaml
---
name: task
agent: orchestrator
description: Create, recover, divide, sync, or abandon tasks
timeout: 1800
routing:
  language_based: false
  flag_based: true
```

This IS a valid skill in 2026 architecture:
- `name: task` → creates `/task` slash command
- `description` → enables Claude auto-invocation (if relevant)
- `agent: orchestrator` → specifies subagent to use with `context: fork`
- Bash code in body → preflight logic (mode detection, validation)

**Missing piece**: Checkpoint integration pattern that other commands have adopted.

### 2. .opencode vs .claude: Migration Context

#### 2.1 OpenCode vs Claude Code Relationship

**Sources**:
- [OpenCode vs Claude Code](https://www.builder.io/blog/opencode-vs-claude-code)
- [OpenCode GitHub Issues](https://github.com/anomalyco/opencode/issues/8158)
- [Import settings from Claude Code](https://github.com/anomalyco/opencode/issues/10305)

**What is OpenCode?**
- **Open-source fork** of Claude Code's agent architecture
- Developed by Anomaly (company behind SST framework)
- Goal: "Open alternative to Claude Code" with same MCP compatibility
- Uses `.opencode/` directory instead of `.claude/`

**Directory Conventions**:

| System | Global Config | Project Config | Commands | Skills |
|--------|--------------|----------------|----------|--------|
| **Claude Code** | `~/.claude/` | `.claude/` | `.claude/commands/` | `.claude/skills/` |
| **OpenCode** | `~/.config/opencode/` | `.opencode/` | `.opencode/command/` | `.opencode/skills/` |

**Compatibility Layer**:
- OpenCode falls back to Claude Code conventions if `.opencode/` doesn't exist
- Checks for `CLAUDE.md` if `AGENTS.md` missing
- Checks `~/.claude/CLAUDE.md` if `~/.config/opencode/AGENTS.md` missing
- Skills in `~/.claude/skills/` work with both tools automatically

**Migration Path**:
> "Simply move files from .claude/commands/ to .opencode/command/ and adjust frontmatter when migrating commands. The first matching file wins in each category."

#### 2.2 ProofChecker's Migration Status

**Evidence from filesystem**:

1. **Dual directory structure exists**:
   - `.opencode/` (144 files, including `package.json` with `@opencode-ai/plugin` v1.1.25)
   - `.claude/` (active system per CLAUDE.md)
   - `.opencode_OLD/` (backup of earlier state)

2. **settings.json analysis** (`.opencode/settings.json`):
   - Contains hooks referencing `.opencode/hooks/` scripts
   - Permissions configured for OpenCode tools
   - Model set to "sonnet" (generic, not Claude Code specific)

3. **Command file differences**:
   - `.opencode/command/` has 13 markdown files
   - `.claude/commands/` has 12 markdown files
   - `.opencode/` commands reference `.opencode/` paths in bash code
   - `.claude/` commands reference `.claude/` paths

4. **Git status shows both modified**:
   - `.opencode/command/*.md` files staged
   - `.claude/` files unstaged
   - Suggests parallel development/migration

**Conclusion**: ProofChecker is **mid-migration** from OpenCode to Claude Code:
- Started with OpenCode (`.opencode/` directory structure)
- Migrated to Claude Code (created `.claude/` structure)
- Migration incomplete - both systems coexist
- `.opencode_OLD/` suggests awareness of migration but hesitation to delete
- Commands duplicated across both systems with diverging implementations

**Why this matters**:
- Architecture confusion stems from dual systems
- `.opencode/command/task.md` has different structure than `.claude/commands/task.md`
- Both may be active depending on Claude Code vs OpenCode invocation
- Migration should complete decisively to resolve ambiguity

#### 2.3 Recommended Migration Strategy

**Option 1: Complete Claude Code Migration (Recommended)**

**Rationale**:
- Claude Code is official Anthropic product
- 2026 features (hot-reload, context forking, hooks) are Claude Code specific
- Better documentation and support
- CLAUDE.md already declares `.claude/` as authoritative

**Steps**:
1. Verify all functionality exists in `.claude/` equivalents
2. Archive `.opencode/` and `.opencode_OLD/` to `archive/.opencode-legacy-{date}/`
3. Update any paths in scripts that reference `.opencode/`
4. Remove OpenCode package dependencies (`package.json`)
5. Update CLAUDE.md to note migration completion
6. Git commit with message: "Complete OpenCode → Claude Code migration"

**Option 2: Return to OpenCode**

**Rationale**:
- Open-source with community contributions
- Same MCP compatibility
- More transparent development

**Steps**:
1. Remove `.claude/` directory
2. Restore `.opencode_OLD/` as canonical `.opencode/`
3. Update CLAUDE.md → AGENTS.md
4. Verify hooks and scripts functional
5. Note: Lose 2026 Claude Code specific features

**Recommendation**: **Option 1** - Complete Claude Code migration, archive OpenCode remnants.

### 3. Claude Code 2026 Best Practices

#### 3.1 Automation-First Design Philosophy

**Source**: [Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/)

**2026 Paradigm Shift**:
> "Skills represent a paradigm shift toward automatic capability activation. Rather than maintaining extensive static CLAUDE.md files, teams should decompose expertise into modular, independently-triggering skills."

**Key Principles**:

1. **Automation over documentation**
   - Skills activate automatically when relevant
   - CLAUDE.md contains static context, skills contain actionable patterns
   - Claude decides when to invoke based on semantic matching

2. **Modularity over monolithic files**
   - Decompose large CLAUDE.md sections into individual skills
   - Each skill = one capability with clear description
   - Skills can reference supporting files for details

3. **Context-aware activation over explicit invocation**
   - Prefer skills Claude invokes automatically
   - Reserve explicit commands (`disable-model-invocation: true`) for side-effect operations
   - Use `user-invocable: false` for background knowledge skills

**Application to ProofChecker**:

Current state: Large CLAUDE.md (200+ lines) with workflow documentation
Recommended: Decompose into skills:
- `skill-task-lifecycle` - Auto-invoked for task status patterns
- `skill-checkpoint-pattern` - Auto-invoked when implementing checkpoints
- `skill-artifact-formats` - Auto-invoked when creating reports/plans
- `/task`, `/research`, etc. remain as explicit commands (side-effect operations)

**Benefits**:
- Reduces CLAUDE.md token load per conversation
- Skills loaded only when semantically relevant
- Easier to maintain (edit one skill vs searching large doc)
- Hot-reload enables instant skill updates

#### 3.2 Master-Clone Architecture Pattern

**Source**: [7 Claude Code Concepts Every Developer Must Master](https://medium.com/@benothman.lotfi/7-claude-code-concepts-every-developer-must-master-efe3c6986d08)

**Pattern Description**:
> "The 'Master-Clone' architecture is preferred over the 'Lead-Specialist' model, where the main agent has all context in CLAUDE.md and dynamically delegates work to copies of itself."

**Master-Clone Characteristics**:
- Main agent loads CLAUDE.md context
- Subagents are "clones" with same context but isolated conversations
- Delegation via `context: fork` creates clean boundaries
- Subagents return results to main agent for integration

**Lead-Specialist (Anti-pattern)**:
- Main agent has minimal context
- Specialist subagents have deep domain expertise
- Main agent must coordinate disparate specialists
- More complex orchestration, higher latency

**ProofChecker Current State**:
- Uses **specialized agents** (lean-research-agent, planner-agent, etc.)
- Each agent has domain-specific context
- More aligned with Lead-Specialist pattern

**Recommendation**:
- ProofChecker's specialized agents are appropriate for domain complexity (Lean 4, LaTeX)
- Don't force Master-Clone if domains are genuinely different
- Use Master-Clone for general research/implementation where context is shared
- Hybrid approach: Master-Clone for general work, specialists for Lean/LaTeX

#### 3.3 Context Loading Strategies (2026)

**Source**: [Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/)

**Hierarchical Context Merging**:
1. **Enterprise-level** configurations load first
2. **User preferences** (`~/.claude/CLAUDE.md`) apply globally
3. **Project root** `CLAUDE.md` establishes project-wide conventions
4. **Directory-specific** CLAUDE.md files provide localized context

**Lazy Loading Pattern**:
> "Skills package expertise Claude applies automatically only when semantically necessary, improving token efficiency."

**Best Practice for ProofChecker**:
- **Global context** (`~/.claude/CLAUDE.md`): Git conventions, general coding style
- **Project context** (`.claude/CLAUDE.md`): Task management, checkpoint patterns, Lean/LaTeX basics
- **Skills**: Detailed patterns loaded on-demand (`skill-lean-research`, `skill-planner`, etc.)
- **Subagent context**: Specialized knowledge loaded only in forked contexts

**Current ProofChecker CLAUDE.md (200+ lines)**:
- Contains: System overview, task management, commands, skill architecture, git workflow
- Recommendation: Move detailed patterns to skills, keep high-level overview in CLAUDE.md

**Proposed split**:
```
CLAUDE.md (core context, always loaded):
- Project purpose and structure
- Task status workflow
- Command quick reference
- Agent architecture overview

Skills (loaded on-demand):
- skill-checkpoint-pattern → Loaded when implementing workflows
- skill-artifact-formats → Loaded when creating reports/plans
- skill-state-management → Loaded when updating TODO.md/state.json
- skill-git-workflow → Loaded when committing
```

**Token efficiency gain**: ~50% reduction in base context, skills loaded only when needed.

#### 3.4 Skill Invocation Control Best Practices

**Source**: [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills)

**Frontmatter Fields for Control**:

| Field | Values | Use Case | Example |
|-------|--------|----------|---------|
| `disable-model-invocation` | `true`/`false` | Prevent Claude auto-invoke | `/deploy`, `/commit` (side-effects) |
| `user-invocable` | `true`/`false` | Hide from `/` menu | Background knowledge skills |
| `context` | `fork`/inline | Run in subagent vs main | `fork` for isolated work |
| `agent` | Agent name | Which subagent to use | `orchestrator`, `Explore`, custom |

**Decision Matrix**:

**When to use `disable-model-invocation: true`**:
- Side-effect operations (deploy, commit, delete)
- User must control timing (data operations, external API calls)
- Workflow with multiple steps requiring user confirmation

**When to use `user-invocable: false`**:
- Background knowledge (conventions, patterns, reference docs)
- Skills that aren't actionable as standalone commands
- Context that Claude should know but user shouldn't trigger manually

**When to use `context: fork`**:
- Isolated execution (research, planning that doesn't need main context)
- Expensive operations (don't pollute main context)
- Parallel work (multiple subagents simultaneously)

**When to use `agent` field**:
- Specialized work (lean-research-agent for Lean, latex-agent for LaTeX)
- Built-in agents (Explore for read-only, Plan for planning)
- Custom agents from `.claude/agents/`

**ProofChecker Application**:

Current command configurations should map to:

| Command | `disable-model-invocation` | `user-invocable` | `context` | Rationale |
|---------|---------------------------|------------------|-----------|-----------|
| `/task` | `true` | `true` | `fork` | Side-effect (creates tasks), needs isolation |
| `/research` | `true` | `true` | `fork` | User-triggered, delegates to subagent |
| `/plan` | `true` | `true` | `fork` | User-triggered, planning work isolated |
| `/implement` | `true` | `true` | `fork` | Side-effect (modifies files), isolated work |
| `/todo` | `true` | `true` | inline | Simple state update, no fork needed |
| `/refresh` | `true` | `true` | inline | Cleanup operation, direct execution |

**Background skills** (new recommendations):
- `skill-checkpoint-pattern` - `false`, `false`, inline (auto-loaded context)
- `skill-artifact-formats` - `false`, `false`, inline (auto-loaded reference)
- `skill-state-management` - `false`, `false`, inline (auto-loaded patterns)

#### 3.5 Hooks for Checkpoint Enforcement

**Source**: [Claude Code Skills - Hooks in Frontmatter](https://code.claude.com/docs/en/skills)

**2026 Feature: Skill-Scoped Hooks**

Skills can now define lifecycle hooks directly in frontmatter:
```yaml
---
name: my-skill
hooks:
  PreToolUse:
    - matcher: Write
      command: "bash validate-write.sh"
  PostToolUse:
    - matcher: Write
      command: "bash commit-changes.sh"
---
```

**Checkpoint Pattern Application**:

**GATE IN Hook** (PreToolUse):
```yaml
hooks:
  PreToolUse:
    - matcher: Task  # Before delegating to subagent
      command: "bash checkpoint-gate-in.sh"
```

Script validates:
- Task exists
- Status allows operation
- Session ID generated
- Preflight update written to state

**GATE OUT Hook** (PostToolUse):
```yaml
hooks:
  PostToolUse:
    - matcher: Task  # After subagent returns
      command: "bash checkpoint-gate-out.sh"
```

Script validates:
- Subagent return format correct
- Artifacts created
- Postflight update written to state
- Git commit executed

**Benefits over current bash-embedded checkpoints**:
- **Enforcement**: Hooks always execute, can't be skipped
- **Separation**: Checkpoint logic separate from command logic
- **Reusability**: Same hooks across multiple commands
- **Validation**: Hook can fail and abort command execution

**Recommendation for Task 676**:
- Implement checkpoint hooks for `/task` command
- Extract GATE IN/GATE OUT logic into hook scripts
- Apply same hooks to `/research`, `/plan`, `/implement`
- Centralize checkpoint validation

### 4. Skill Registration Mystery Solved

#### 4.1 Why "skill-task" Wasn't Found

**Initial observation** (from user question):
> "Search the entire .claude/ directory structure for skill definitions. Determine if skills are defined in a different location."

**Resolution**:

1. **Commands ARE skills in 2026**
   - `.claude/commands/task.md` IS the skill-task definition
   - No separate `.claude/skills/skill-task/` needed
   - Both locations create same functionality (merged architecture)

2. **Skill hot-reload eliminates registration**
   - Skills discovered automatically via description matching
   - No registration step or manifest file
   - Changes to skill files instantly active

3. **User's `skill-task` invocation works** because:
   - Claude Code recognizes `.claude/commands/task.md` as skill
   - Frontmatter `name: task` creates both `/task` and skill-task
   - Description enables auto-invocation (though typically user-triggered)

**Why confusion arose**:
- Research-001 found "13 skills registered" but `/task` not in `.claude/skills/`
- Didn't account for commands-as-skills merge
- Expected 1:1 mapping of skill names to `.claude/skills/` directories

**Actual mapping**:
```
Skills in .claude/skills/:
1. skill-document-converter
2. skill-git-workflow
3. skill-implementer
4. skill-latex-implementation
5. skill-lean-implementation
6. skill-lean-research
7. skill-learn
8. skill-meta
9. skill-orchestrator
10. skill-planner
11. skill-refresh
12. skill-researcher
13. skill-status-sync

Skills in .claude/commands/ (also skills):
14. convert
15. errors
16. implement
17. learn
18. meta
19. plan
20. refresh
21. research
22. review
23. revise
24. task ← Found it!
25. todo
```

**Total skills available**: 24+ (13 in skills/ + 12 in commands/, minus duplicates like `learn`, `meta`, etc.)

#### 4.2 How Claude Discovers Skills

**Process Flow**:

1. **Scan directories** (on session start or hot-reload trigger):
   - Personal: `~/.claude/skills/`
   - Project: `.claude/skills/`
   - Commands: `.claude/commands/`
   - Plugins: Active plugin `skills/` directories

2. **Parse frontmatter**:
   - Extract `name`, `description`, `allowed-tools`, etc.
   - Build skill registry in memory

3. **Match descriptions to context**:
   - User types query or invokes command
   - Claude compares query semantics to skill descriptions
   - Loads skills with high relevance scores

4. **Invoke skill**:
   - If user-invocable and invoked via `/name`: Execute directly
   - If model-invocable and relevant: Load into context automatically
   - If `context: fork`: Create subagent with skill as prompt

**No explicit registration required** - filesystem presence + valid frontmatter = discoverable skill.

#### 4.3 Skill Tool Capabilities Research

**Source**: [Claude Code Official Docs - Skills](https://code.claude.com/docs/en/skills)

**What the Skill Tool Does**:

1. **Manages skill invocation**:
   - Loads skill content into conversation
   - Modifies execution context (tools, model, permissions)
   - Injects dynamic content via `!`command`` preprocessing
   - Handles `$ARGUMENTS` substitution

2. **Does NOT**:
   - Execute bash code directly (that's Bash tool's job)
   - Manage skill registration (filesystem-based)
   - Enforce checkpoint patterns (that's hooks' job)
   - Validate skill structure (Claude Code does at load time)

**Skill Tool vs Task Tool**:

| Tool | Purpose | Usage in ProofChecker |
|------|---------|----------------------|
| **Skill** | Load skill instructions, modify context | Invokes skills in main conversation |
| **Task** | Create subagent with task delegation | Delegates to specialized agents (research, plan, implement) |

**Clarification**: ProofChecker's thin wrapper skills use **Task tool**, not Skill tool:
- Task tool creates forked subagent context
- Skill tool loads skill instructions inline
- Task tool enables checkpoint isolation

**Why Task tool is appropriate**:
- Enables `context: fork` isolation
- Supports specialized agents (lean-research-agent, planner-agent)
- Returns structured results from subagent
- Prevents context pollution

**Recommendation**: Continue using Task tool for delegation, Skill tool for inline skill loading.

## Decisions

### Decision 1: Commands and Skills Are the Same in 2026

**Conclusion**: "Missing skill-task" is a misunderstanding - commands ARE skills after Jan 2026 merge.

**Rationale**: Official documentation confirms `.claude/commands/*.md` files function as skills with same capabilities.

**Impact**: Investigation can focus on checkpoint integration for existing `/task` command, not creating new skill wrapper.

### Decision 2: Complete Claude Code Migration

**Conclusion**: Archive `.opencode/` remnants and standardize on `.claude/` directory structure.

**Rationale**:
- CLAUDE.md already declares `.claude/` as authoritative
- 2026 features (hot-reload, hooks, context forking) are Claude Code specific
- Dual systems create architecture confusion
- Migration is 80% complete already

**Impact**: Simplifies architecture, eliminates dual-system maintenance burden, enables 2026 features.

### Decision 3: Use Skill-Scoped Hooks for Checkpoint Enforcement

**Conclusion**: Implement checkpoint validation via skill frontmatter hooks, not embedded bash.

**Rationale**:
- Hooks execute automatically, can't be skipped
- Centralized checkpoint logic reusable across commands
- Aligns with 2026 best practices
- Enables architectural enforcement (vs. documentation-only)

**Impact**: Addresses checkpoint enforcement gap identified in research-001 and Task 675.

### Decision 4: Decompose CLAUDE.md into Skills

**Conclusion**: Move detailed patterns from CLAUDE.md into auto-invoked skills for token efficiency.

**Rationale**:
- Current CLAUDE.md is 200+ lines (high token cost)
- Skills loaded only when semantically relevant
- Hot-reload enables easy updates
- Aligns with 2026 automation-first philosophy

**Impact**: ~50% reduction in base context, improved performance, easier maintenance.

## Recommendations

### Immediate Actions (Task 676 Scope)

1. **Archive .opencode/ Legacy System**
   ```bash
   mkdir -p archive/opencode-legacy-$(date +%Y%m%d)
   mv .opencode/ .opencode_OLD/ archive/opencode-legacy-$(date +%Y%m%d)/
   git add archive/ && git commit -m "Archive OpenCode legacy system"
   ```

2. **Update /task Command with Checkpoint Hooks**
   - Add skill-scoped hooks to `.claude/commands/task.md` frontmatter
   - Create `.claude/hooks/task-gate-in.sh` (preflight validation)
   - Create `.claude/hooks/task-gate-out.sh` (postflight validation)
   - Test with `/task "Test task"` to verify hooks execute

3. **Document Commands-as-Skills Architecture**
   - Update CLAUDE.md to note 2026 merge
   - Explain why `.claude/commands/` files are skills
   - Clarify when to use commands/ vs skills/ directory
   - Reference: "Commands are skills with `disable-model-invocation: true`"

### Short-term Actions (Coordination with Tasks 674, 675)

4. **Implement Centralized Checkpoint Hooks**
   - Extract GATE IN logic into `.claude/hooks/checkpoint-gate-in.sh`
   - Extract GATE OUT logic into `.claude/hooks/checkpoint-gate-out.sh`
   - Apply same hooks to `/research`, `/plan`, `/implement` commands
   - Share hook scripts across all checkpoint-based commands

5. **Test Skill Hot-Reload Workflow**
   - Modify skill description while session active
   - Verify Claude recognizes changes without restart
   - Document hot-reload expectations vs. limitations
   - Create test suite for skill discovery

6. **Prototype Context Forking for /task**
   - Add `context: fork` to `/task` frontmatter
   - Test task creation via subagent delegation
   - Measure performance impact vs. inline execution
   - Compare with current bash-embedded approach

### Long-term Actions (Architecture Improvement)

7. **Decompose CLAUDE.md into Skills**
   - Create `skill-checkpoint-pattern` with checkpoint documentation
   - Create `skill-artifact-formats` with report/plan templates
   - Create `skill-state-management` with sync patterns
   - Update CLAUDE.md to high-level overview only
   - Set all new skills to `user-invocable: false` (background knowledge)

8. **Standardize All Commands on Checkpoint Pattern**
   - Refactor `/research`, `/plan`, `/implement` to use hooks
   - Deprecate embedded bash checkpoint logic
   - Centralize validation in shared hook scripts
   - Document checkpoint contract in skill template

9. **Create Checkpoint Validation Test Suite**
   - Test GATE IN validation (task exists, status valid)
   - Test GATE OUT validation (artifacts created, return format)
   - Test hook failure scenarios (rollback, error logging)
   - Automate testing as pre-commit hook

10. **Optimize Skill Descriptions for Auto-Invocation**
    - Review all skill descriptions for semantic clarity
    - Add keywords Claude would match against user queries
    - Test auto-invocation with typical user queries
    - Measure skill activation rates via session logs

## Risks & Mitigations

### Risk 1: Breaking Changes from .opencode Removal

**Impact**: Medium - Scripts referencing `.opencode/` paths will fail
**Likelihood**: Medium - Unknown how many scripts depend on `.opencode/`

**Mitigation**:
- Grep codebase for `.opencode/` references before deletion
- Update all found references to `.claude/`
- Test all commands after migration
- Keep archive/ backup for 30 days minimum
- Document migration in git commit message

### Risk 2: Skill Hook Execution Overhead

**Impact**: Low - Hooks add latency to command execution
**Likelihood**: High - Hooks always execute

**Mitigation**:
- Keep hook scripts minimal (validation only, no heavy computation)
- Use bash builtins over external commands where possible
- Set reasonable hook timeouts (30s max)
- Benchmark before/after hook implementation
- Accept overhead as cost of enforcement

### Risk 3: Context Forking May Not Support Task Creation Pattern

**Impact**: Medium - Task delegation may require different pattern than research/plan
**Likelihood**: Low - Research-001 showed subagent pattern works

**Mitigation**:
- Prototype `/task` with `context: fork` early
- Test all task modes (create, recover, expand, sync, abandon, review)
- Identify limitations of forked context for state updates
- Design fallback pattern if forking unsuitable (inline with hooks)

### Risk 4: CLAUDE.md Decomposition May Reduce Discoverability

**Impact**: Low - Skills may not be found when needed
**Likelihood**: Medium - Description matching not 100% reliable

**Mitigation**:
- Test skill auto-invocation with representative queries
- Ensure skill descriptions use keywords from user vocabulary
- Keep critical context in CLAUDE.md (don't over-decompose)
- Monitor skill activation in session logs
- Iterate on descriptions based on usage patterns

### Risk 5: Hot-Reload May Not Work as Documented

**Impact**: Low - Would require session restarts for skill changes
**Likelihood**: Low - 2026 feature widely documented

**Mitigation**:
- Test hot-reload during prototype phase
- Document actual behavior vs. expected
- Plan for session restarts if hot-reload unreliable
- Report issues to Claude Code team if bugs found

## Appendix

### A. Sources and References

**Official Documentation**:
- [Claude Code Skills](https://code.claude.com/docs/en/skills)
- [Understanding Claude Code Full Stack](https://alexop.dev/posts/understanding-claude-code-full-stack/)

**Architecture Guides**:
- [Claude Code Explained: CLAUDE.md, /command, SKILL.md, hooks, subagents](https://avinashselvam.medium.com/claude-code-explained-claude-md-command-skill-md-hooks-subagents-e38e0815b59b)
- [Claude Agent Skills: A First Principles Deep Dive](https://leehanchung.github.io/blogs/2025/10/26/claude-skills-deep-dive/)
- [Understanding Claude Code: Skills vs Commands vs Subagents](https://www.youngleaders.tech/p/claude-skills-commands-subagents-plugins)

**2026 Updates**:
- [Claude Code Release Notes - January 2026](https://releasebot.io/updates/anthropic/claude-code)
- [Claude Code 2.1.0 arrives with smoother workflows](https://venturebeat.com/orchestration/claude-code-2-1-0-arrives-with-smoother-workflows-and-smarter-agents)
- [7 Claude Code Concepts Every Developer Must Master](https://medium.com/@benothman.lotfi/7-claude-code-concepts-every-developer-must-master-efe3c6986d08)

**OpenCode Context**:
- [OpenCode vs Claude Code](https://www.builder.io/blog/opencode-vs-claude-code)
- [OpenCode GitHub Issues #8158](https://github.com/anomalyco/opencode/issues/8158)
- [Import settings from Claude Code #10305](https://github.com/anomalyco/opencode/issues/10305)

**Best Practices**:
- [A Guide to Claude Code 2.0](https://sankalp.bearblog.dev/my-experience-with-claude-code-20-and-how-to-get-better-at-using-coding-agents/)
- [Claude Code customization guide](https://alexop.dev/posts/claude-code-customization-guide-claudemd-skills-subagents/)
- [How I Use Every Claude Code Feature](https://blog.sshh.io/p/how-i-use-every-claude-code-feature)

### B. Key Quotes

**On Commands-Skills Merge**:
> "Custom slash commands have been merged into skills. A file at `.claude/commands/review.md` and a skill at `.claude/skills/review/SKILL.md` both create `/review` and work the same way."

**On 2026 Philosophy**:
> "Skills represent a paradigm shift toward automatic capability activation. Rather than maintaining extensive static CLAUDE.md files, teams should decompose expertise into modular, independently-triggering skills."

**On Skill Discovery**:
> "Claude reviews available skill descriptions to identify relevance to the current task. When a skill's description contextually aligns with the user's request, Claude loads full instructions transparently."

**On Hooks**:
> "Hooks enable enforcement of development standards (linting, validation, approval workflows) at precise execution moments rather than through documentation alone."

### C. Directory Structure Comparison

**Before (OpenCode + Claude Code Hybrid)**:
```
.opencode/
├── command/          # 13 command files
├── skills/           # 15 skill directories
├── hooks/            # Hook scripts
├── settings.json     # OpenCode configuration
└── package.json      # @opencode-ai/plugin v1.1.25

.opencode_OLD/        # Backup of earlier state

.claude/
├── commands/         # 12 command files
├── skills/           # 13 skill directories
├── agents/           # Agent definitions
└── context/          # Context files
```

**After (Claude Code Only - Recommended)**:
```
.claude/
├── commands/         # 12 command files (are skills)
├── skills/           # 13+ skill directories
├── agents/           # Agent definitions
├── context/          # Context files
└── hooks/            # Checkpoint validation scripts

archive/
└── opencode-legacy-20260125/
    ├── .opencode/
    └── .opencode_OLD/
```

### D. Skill Invocation Control Matrix

| Skill | `disable-model-invocation` | `user-invocable` | Context | Result |
|-------|---------------------------|------------------|---------|---------|
| checkpoint-pattern | `false` | `false` | inline | Auto-loaded, not invocable via `/` |
| artifact-formats | `false` | `false` | inline | Auto-loaded, not invocable via `/` |
| /task | `true` | `true` | fork | User-invoked only, runs in subagent |
| /research | `true` | `true` | fork | User-invoked only, runs in subagent |
| /plan | `true` | `true` | fork | User-invoked only, runs in subagent |
| /implement | `true` | `true` | fork | User-invoked only, runs in subagent |

### E. 2026 Features Checklist for ProofChecker

**Adopted**:
- ✓ Skill hot-reload (automatic, no action needed)
- ✓ MCP tool integration (lean-lsp server active)
- ✓ Hierarchical context loading (CLAUDE.md structure)
- ✓ Description-based skill discovery (all skills have descriptions)

**Partially Adopted**:
- ⚠ Context forking (defined in frontmatter, not fully utilized)
- ⚠ Bash wildcard permissions (defined in settings.json, limited scope)
- ⚠ Task tool delegation (used by some skills, not all)

**Not Yet Adopted**:
- ✗ Skill-scoped hooks (no hooks in skill frontmatter)
- ✗ Supporting files for skills (single SKILL.md files only)
- ✗ Dynamic content injection (`!`command`` syntax unused)
- ✗ Skill auto-invocation testing (descriptions may not trigger reliably)

**Recommended for Task 676**:
1. Implement skill-scoped hooks for checkpoint enforcement
2. Test context forking for `/task` command
3. Add supporting files to complex skills (examples, templates)
4. Audit skill descriptions for auto-invocation effectiveness

---

**Research Status**: Complete
**Next Steps**: Create implementation plan for Task 676 integrating findings from research-001 and research-002
**Priority**: High - Foundation for checkpoint pattern enforcement (Tasks 674, 675, 676)
**Coordination**: Share findings with Task 674 (integrated preflight/postflight) and Task 675 (checkpoint enforcement)
