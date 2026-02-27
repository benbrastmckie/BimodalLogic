# Research Report: Task #939

**Task**: 939 - upgrade_research_command_domain_routing
**Started**: 2026-02-26T12:00:00Z
**Completed**: 2026-02-26T12:30:00Z
**Effort**: 2-3 hours (implementation)
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (commands, skills, agents), routing tables, argument parsing patterns
**Artifacts**: specs/939_upgrade_research_command_domain_routing/reports/research-001.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- Current `/research` command routes based on task language, not explicit user flags
- Domain-specific research skills exist: `skill-lean-research`, `skill-logic-research`, `skill-math-research`, `skill-latex-research`
- No `skill-typst-research` exists; typst currently uses `skill-researcher` (general)
- Argument parsing patterns from `/implement`, `/task`, `/todo` provide templates for flag handling
- "Context Knowledge Task" pattern is referenced but template not yet created (context-knowledge-template.md)

## Context & Scope

The task requires upgrading the `/research` command to support explicit domain override flags (`--lean`, `--logic`, `--math`, `--latex`, `--typst`) that allow users to bypass automatic language-based routing. This enables:
1. Research with specialized tools even when task language differs
2. Cross-domain research (e.g., using Mathlib lookup for a "general" task)
3. Explicit control over which research agent/skill handles the task

Focus area: `domain_routing_flags` - understanding current routing and how to add override flags.

## Findings

### Current /research Command Structure

**Location**: `.claude/commands/research.md`

**Current Arguments**:
```
$1 - Task number (required)
Remaining args - Optional focus/prompt for research direction

Options:
--team - Enable multi-agent parallel research
--team-size N - Number of teammates to spawn (2-4)
```

**Current Routing Table (STAGE 2: DELEGATE)**:
| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-research` |
| `general`, `meta`, `markdown`, `latex` | `skill-researcher` |

**Gap**: No routing for `logic`, `math`, or `typst` despite existing skills.

### Existing Domain-Specific Skills

| Skill | Agent | Current Routing | Capabilities |
|-------|-------|-----------------|--------------|
| `skill-lean-research` | `lean-research-agent` | `lean` language | lean_leansearch, lean_loogle, lean_leanfinder, lean_local_search |
| `skill-logic-research` | `logic-research-agent` | **NOT ROUTED** | Mathlib lookup + web search + codebase |
| `skill-math-research` | `math-research-agent` | **NOT ROUTED** | Mathlib lookup + web search + codebase |
| `skill-latex-research` | `latex-research-agent` | **NOT ROUTED** | Web search + codebase (no Mathlib) |
| `skill-researcher` | `general-research-agent` | `general`, `meta`, `markdown`, `latex` | WebSearch, WebFetch, codebase |

**Finding**: `skill-logic-research`, `skill-math-research`, and `skill-latex-research` exist but are never invoked because the routing table doesn't include `logic`, `math` language mappings, and `latex` is mapped to `skill-researcher` instead of `skill-latex-research`.

### Skill-Agent Mapping Reference

**Location**: `.claude/context/core/reference/skill-agent-mapping.md`

The mapping reference shows the intended routing:
| Language | Research Skill |
|----------|---------------|
| `lean` | skill-lean-research |
| `logic` | skill-logic-research |
| `math` | skill-math-research |
| `latex` | skill-latex-research |
| `typst` | skill-researcher |
| `general` | skill-researcher |
| `meta` | skill-researcher |
| `markdown` | skill-researcher |

**Gap**: The `/research` command routing table is out of sync with the skill-agent-mapping reference.

### Routing Context File

**Location**: `.claude/context/core/routing.md`

Current routing table (also out of sync):
| Language | Research Skill |
|----------|---------------|
| lean | skill-lean-research |
| latex | skill-researcher |
| general | skill-researcher |
| meta | skill-researcher |
| markdown | skill-researcher |

**Missing**: `logic`, `math`, `typst` entries.

### Argument Parsing Patterns

**From /implement**:
```markdown
| Flag | Description | Default |
|------|-------------|---------|
| `--team` | Enable multi-agent parallel implementation | false |
| `--team-size N` | Number of teammates to spawn (2-4) | 2 |
| `--force` | Override status validation | false |
```

**From /task**:
```markdown
Check $ARGUMENTS for flags:
- `--recover RANGES` -> Recover tasks from archive
- `--expand N [prompt]` -> Expand task into subtasks
- `--sync` -> Sync TODO.md with state.json
- `--abandon RANGES` -> Archive tasks
- `--review N` -> Review task completion status
- No flag -> Create new task with description
```

**Pattern**: Flags are documented in a table at the top, then detected via substring check in $ARGUMENTS.

### Context Knowledge Task Pattern

**References Found**:
- `.claude/skills/skill-logic-research/SKILL.md` line 26
- `.claude/skills/skill-math-research/SKILL.md` line 26
- `.claude/skills/skill-latex-research/SKILL.md` line 25
- `.claude/agents/logic-research-agent.md` line 67
- `.claude/agents/math-research-agent.md` line 67
- `.claude/agents/latex-research-agent.md` line 48

All reference: `@.claude/context/core/templates/context-knowledge-template.md`

**Status**: This template file does NOT exist. The template is referenced but not yet created.

**Intended Purpose** (inferred from agent documentation):
The logic/math/latex research agents include a "Context Extension Recommendations" section in their reports that identifies:
1. Concepts discovered during research that should be documented
2. New context files that should be created
3. Extensions to existing context files

The "Context Knowledge Task" prompt would trigger after research to:
1. Review the Context Extension Recommendations
2. Prompt user to create tasks for high-priority documentation gaps
3. Accumulate domain-general findings into context files

### Typst Research Gap

**Current State**:
- `skill-typst-implementation` exists with `typst-implementation-agent`
- No `skill-typst-research` exists
- Typst research falls through to `skill-researcher` (general)

**Options**:
1. Create `skill-typst-research` + `typst-research-agent` (consistent with other domains)
2. Keep typst using `skill-researcher` (simpler, typst is similar to general)

**Recommendation**: Keep typst using `skill-researcher` with explicit `--typst` flag to document intent. Typst research doesn't need specialized MCP tools.

## Decisions

1. **Domain flags**: Add `--lean`, `--logic`, `--math`, `--latex`, `--typst` flags to override automatic routing
2. **Routing table update**: Update `/research` command to match skill-agent-mapping reference
3. **Typst handling**: Use `skill-researcher` for typst (no new skill needed)
4. **Context Knowledge Task**: Defer implementation until context-knowledge-template.md is created
5. **Flag precedence**: Explicit flags take precedence over task language

## Implementation Recommendations

### Phase 1: Update Routing Table

Update `/research` command STAGE 2 to include all domain mappings:

```markdown
**Language-Based Routing**:

| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-research` |
| `logic` | `skill-logic-research` |
| `math` | `skill-math-research` |
| `latex` | `skill-latex-research` |
| `typst`, `general`, `meta`, `markdown` | `skill-researcher` |
```

### Phase 2: Add Domain Override Flags

Add to Arguments section:

```markdown
## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Options

| Flag | Description | Default |
|------|-------------|---------|
| `--lean` | Force Lean research skill (Mathlib lookup, lean-lsp tools) | - |
| `--logic` | Force logic research skill (modal logic, Kripke semantics) | - |
| `--math` | Force math research skill (algebra, lattice theory) | - |
| `--latex` | Force LaTeX research skill (document structure, theorem envs) | - |
| `--typst` | Force general research for Typst documents | - |
| `--team` | Enable multi-agent parallel research with multiple teammates | false |
| `--team-size N` | Number of teammates to spawn (2-4) | 2 |

Domain flags (`--lean`, `--logic`, `--math`, `--latex`, `--typst`) override automatic language-based routing.
Only one domain flag may be specified at a time.
```

### Phase 3: Add Flag Parsing Logic

Add after CHECKPOINT 1 validation, before STAGE 2:

```markdown
### STAGE 1.5: PARSE DOMAIN FLAGS

Parse domain override from $ARGUMENTS:
```bash
# Check for domain override flags (mutually exclusive)
domain_override=""
if [[ "$ARGUMENTS" == *"--lean"* ]]; then
  domain_override="lean"
elif [[ "$ARGUMENTS" == *"--logic"* ]]; then
  domain_override="logic"
elif [[ "$ARGUMENTS" == *"--math"* ]]; then
  domain_override="math"
elif [[ "$ARGUMENTS" == *"--latex"* ]]; then
  domain_override="latex"
elif [[ "$ARGUMENTS" == *"--typst"* ]]; then
  domain_override="typst"
fi

# Extract focus prompt (remove all flags)
focus_prompt=$(echo "$ARGUMENTS" | sed 's/--lean//; s/--logic//; s/--math//; s/--latex//; s/--typst//; s/--team//; s/--team-size [0-9]*//; s/[0-9]*//; s/^ *//; s/ *$//')

# Determine effective domain
if [ -n "$domain_override" ]; then
  effective_domain="$domain_override"
else
  effective_domain="$task_language"
fi
```
```

### Phase 4: Update STAGE 2 to Use Effective Domain

```markdown
### STAGE 2: DELEGATE

**EXECUTE NOW**: After STAGE 1.5 parses flags, route based on `effective_domain`.

**Domain-Based Routing**:

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
args: "task_number={N} focus={focus_prompt} session_id={session_id} domain_override={domain_override or 'none'}"
```
```

### Phase 5: Context Knowledge Task (Deferred)

**Requirement**: Create `.claude/context/core/templates/context-knowledge-template.md` first.

**Implementation Location**: After CHECKPOINT 2: GATE OUT, before CHECKPOINT 3: COMMIT

**Sketch**:
```markdown
### STAGE 2.5: CONTEXT KNOWLEDGE PROMPT (Optional)

If research report contains Context Extension Recommendations with high-priority items:

1. Parse report for Context Extension Recommendations section
2. Extract high-priority items (priority: "high" or "Create Task? Yes")
3. If items found, prompt user:
   ```
   Research found {N} documentation gaps that could be added to context:
   1. {concept} -> {recommended_file}
   2. ...

   Create tasks for these? (yes/no/select)
   ```
4. Create tasks for selected items using /task command pattern
5. Add created task numbers to return metadata
```

**Note**: This phase should be implemented as a separate task after the context-knowledge-template.md is created.

### Files to Modify

1. `.claude/commands/research.md` - Main command file
2. `.claude/context/core/routing.md` - Update routing table for consistency
3. `.claude/context/core/reference/command-reference.md` - Document new flags

### Files to Create (Future Task)

1. `.claude/context/core/templates/context-knowledge-template.md` - Template for context knowledge extraction

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Flag conflicts (multiple domain flags) | First match wins, document as "only one domain flag at a time" |
| Breaking existing workflows | Domain flags are optional; default behavior unchanged |
| Context Knowledge Task complexity | Defer to separate task after template created |
| Typst research quality | General research agent handles typst adequately; no specialized skill needed |

## Appendix

### Files Examined

1. `.claude/commands/research.md` - Current /research implementation
2. `.claude/commands/implement.md` - Flag parsing patterns
3. `.claude/commands/task.md` - Mode detection patterns
4. `.claude/context/core/reference/skill-agent-mapping.md` - Authoritative routing reference
5. `.claude/context/core/routing.md` - Routing context (outdated)
6. `.claude/skills/skill-lean-research/SKILL.md` - Lean research skill
7. `.claude/skills/skill-logic-research/SKILL.md` - Logic research skill
8. `.claude/skills/skill-math-research/SKILL.md` - Math research skill
9. `.claude/skills/skill-latex-research/SKILL.md` - LaTeX research skill
10. `.claude/skills/skill-researcher/SKILL.md` - General research skill
11. `.claude/agents/logic-research-agent.md` - Context extension patterns

### Search Queries Used

- `Glob: .claude/commands/**/*research*`
- `Grep: /research` in .claude/
- `Glob: .claude/skills/skill-*-research/SKILL.md`
- `Grep: context-knowledge-template`
- `Grep: --lean|--logic|--math|--latex|--typst`
- `Grep: typst` in .claude/context/core/
