# Research Report: Task #612

**Task**: 612 - improve_system_overview_docs_with_architecture
**Started**: 2026-01-19T12:15:00Z
**Completed**: 2026-01-19T12:45:00Z
**Effort**: 1 hour
**Priority**: Medium
**Dependencies**: Task 609 (Document command-skill-agent architecture), Task 611 (Context optimization)
**Sources/Inputs**: Codebase exploration (skills, agents, commands), existing system-overview.md files, CLAUDE.md
**Artifacts**: specs/612_improve_system_overview_docs_with_architecture/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The current `.claude/context/core/architecture/system-overview.md` contains INACCURATE information: it documents `context: fork` and `agent:` frontmatter fields that are NOT actually used by skills
- Skills use a "thin wrapper with internal postflight" pattern - they invoke agents via the Task tool explicitly, NOT via frontmatter configuration
- There are THREE distinct architecture patterns across skills: (1) delegating skills with internal postflight, (2) direct execution skills, and (3) orchestrator/routing skills
- Diagrams should use Unicode box-drawing characters for better rendering across all environments
- The documentation gap between agent-facing context and user-facing docs needs reconciliation

## Context & Scope

This research examines the current system-overview.md files and actual skill/agent implementations to identify:
1. Inaccuracies in current documentation (especially regarding context:fork)
2. All architecture patterns used across different command types
3. How context is actually loaded (not via frontmatter arrays)
4. Motivations for different approaches used by different command types

**Constraints**: Focus on documentation accuracy and architecture patterns, not implementation changes.

## Findings

### 1. Critical Inaccuracy: context:fork and agent: Fields

**Current Documentation Claims** (system-overview.md line 96-112):

```yaml
---
name: skill-{name}
description: {description}
allowed-tools: Task
context: fork
agent: {agent-name}
---
```

**Actual Skill Implementations** (verified in all skill files):

```yaml
---
name: skill-researcher
description: Conduct general research...
allowed-tools: Task, Bash, Edit, Read, Write
# NO context: fork
# NO agent: field
---
```

**Reality**: Skills do NOT use `context: fork` or `agent:` fields. The CLAUDE.md already documents this correctly:

> "No `context: fork` or `agent:` fields needed - delegation is explicit via Task tool"

The system-overview.md needs to be updated to match this reality.

### 2. Three Distinct Architecture Patterns

Analysis of all 12 skills reveals THREE distinct patterns:

#### Pattern A: Delegating Skills with Internal Postflight (8 skills)

**Skills**: skill-researcher, skill-lean-research, skill-planner, skill-implementer, skill-lean-implementation, skill-latex-implementation, skill-meta, skill-document-converter

**Characteristics**:
- Frontmatter: `allowed-tools: Task, Bash, Edit, Read, Write`
- 11-stage execution flow with preflight/postflight inline
- Invoke subagent via Task tool with explicit subagent_type
- Handle status updates before/after agent execution
- Create postflight marker file to prevent premature termination
- Return brief text summary (agent writes JSON to metadata file)

**Example Flow**:
```
Stage 1:  Input Validation
Stage 2:  Preflight Status Update      [RESEARCHING]
Stage 3:  Create Postflight Marker
Stage 4:  Prepare Delegation Context
Stage 5:  Invoke Subagent (Task tool)
Stage 6:  Parse Subagent Return (read metadata file)
Stage 7:  Update Task Status           [RESEARCHED]
Stage 8:  Link Artifacts
Stage 9:  Git Commit
Stage 10: Cleanup
Stage 11: Return Brief Summary
```

**Motivation**: Eliminates "continue prompt" between skill return and orchestrator. The skill handles all lifecycle operations, ensuring atomic completion.

#### Pattern B: Direct Execution Skills (3 skills)

**Skills**: skill-status-sync, skill-cleanup, skill-git-workflow

**Characteristics**:
- Frontmatter: `allowed-tools: Bash, Edit, Read` (no Task tool)
- Execute work inline without spawning subagent
- No postflight marker needed (work is atomic)
- Return JSON or text directly

**Example** (skill-status-sync):
```yaml
---
name: skill-status-sync
description: Atomically update task status...
allowed-tools: Bash, Edit, Read
---
```

**Motivation**: Some operations are simple enough that spawning a subagent adds unnecessary overhead. Status updates, git commits, and cleanup are atomic operations that don't need the full delegation machinery.

#### Pattern C: Orchestrator/Routing Skills (1 skill)

**Skills**: skill-orchestrator

**Characteristics**:
- Frontmatter: `allowed-tools: Read, Glob, Grep, Task`
- Central routing intelligence
- Dispatches to other skills/agents based on language
- Provides context preparation and routing logic

**Motivation**: Centralizes routing decisions and reduces duplication across commands.

### 3. Context Loading Reality

**How Context is Loaded** (from analysis of all components):

| Component | Context Loading Method | Evidence |
|-----------|----------------------|----------|
| Commands | Zero context | Commands contain only frontmatter and routing instructions |
| Skills | Reference-only (no eager load) | Skills document "Reference (do not load eagerly)" |
| Agents | @-references in body | Agents list "Always Load" and "Load When Needed" sections |

**Key Insight**: The `context:` frontmatter field is NOT used. Instead:
1. Skills document references but explicitly say "do not load eagerly"
2. Agents have sections like "## Context References" with @-references
3. Loading happens on-demand via @-reference when agent reads content

**Example from general-research-agent.md**:
```markdown
## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/core/formats/return-metadata-file.md`

**Load When Creating Report**:
- `@.claude/context/core/formats/report-format.md`
```

### 4. Metadata File Exchange Pattern

**Discovery**: All delegating skills use a metadata file pattern instead of JSON return:

1. Skill passes `metadata_file_path` to agent: `specs/{N}_{SLUG}/.return-meta.json`
2. Agent writes structured JSON to this file (not to console)
3. Skill reads metadata file after agent returns
4. Skill processes metadata and performs postflight operations
5. Skill cleans up metadata file

**Motivation**: Avoids JSON parsing issues with console output. The Task tool returns text, and parsing JSON from mixed console output is unreliable.

### 5. Command-Skill-Agent Mapping Matrix

| Command | Routing | Skill(s) | Agent(s) |
|---------|---------|----------|----------|
| /research | Language-based | lean: skill-lean-research, other: skill-researcher | lean-research-agent, general-research-agent |
| /plan | Single | skill-planner | planner-agent |
| /implement | Language-based | lean: skill-lean-implementation, latex: skill-latex-implementation, other: skill-implementer | lean-implementation-agent, latex-implementation-agent, general-implementation-agent |
| /revise | Single | skill-planner (new version) | planner-agent |
| /meta | Single | skill-meta | meta-builder-agent |
| /convert | Single | skill-document-converter | document-converter-agent |
| /review | Single | skill-orchestrator | (direct or reviewer-agent) |
| /errors | Direct | skill-orchestrator | (inline execution) |
| /todo | Direct | skill-orchestrator | (inline execution) |
| /task | Direct | skill-orchestrator | (inline execution) |
| /cleanup | Direct | skill-cleanup | (no agent) |

### 6. Unicode Diagram Recommendations

Current diagrams use ASCII (`+`, `-`, `|`). Recommended Unicode characters:

| Purpose | ASCII | Unicode |
|---------|-------|---------|
| Corners | `+` | `┌`, `┐`, `└`, `┘` |
| Horizontal | `-` | `─` |
| Vertical | `\|` | `│` |
| T-junctions | `+` | `├`, `┤`, `┬`, `┴` |
| Cross | `+` | `┼` |
| Arrows | `->`, `-->` | `→`, `⟶` |
| Box double | N/A | `╔`, `═`, `╗`, `║` |

**Example Improved Diagram**:
```
                         USER INPUT
                              │
                              ▼
                    ┌─────────────────┐
     Layer 1:       │    Commands     │  User-facing entry points
     (Commands)     │  (/research,    │  Parse $ARGUMENTS
                    │   /plan, etc.)  │  Route to skills
                    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
     Layer 2:       │     Skills      │  Thin wrappers with
     (Skills)       │ (skill-lean-    │  internal postflight
                    │  research, etc.)│  Invoke agents via Task
                    └────────┬────────┘
                              │
                              ▼
                    ┌─────────────────┐
     Layer 3:       │     Agents      │  Full execution components
     (Agents)       │ (lean-research- │  Load context on-demand
                    │  agent, etc.)   │  Create artifacts
                    └────────┬────────┘
                              │
                              ▼
                        ARTIFACTS
               (reports, plans, summaries)
```

### 7. Gap Analysis: Agent vs User Documentation

| Topic | Agent Context (core/) | User Docs (docs/) | Gap |
|-------|----------------------|-------------------|-----|
| Architecture overview | system-overview.md (inaccurate) | system-overview.md (better) | Agent version needs update |
| Thin wrapper pattern | thin-wrapper-skill.md (has context:fork error) | creating-skills.md | Need to fix context:fork claim |
| Checkpoint pattern | checkpoint-execution.md | (in system-overview.md) | Good |
| Three patterns | Not documented | Not documented | Need to document |

## Recommendations

### Phase 1: Fix Inaccuracies in system-overview.md

1. Remove `context: fork` and `agent:` from skill frontmatter example
2. Update to show actual frontmatter pattern with `allowed-tools: Task, Bash, Edit, Read, Write`
3. Fix Layer 2 description to mention "thin wrapper with internal postflight"

### Phase 2: Document Three Architecture Patterns

Add new section "Architecture Pattern Variations":
1. **Pattern A**: Delegating skills (most common, 8 skills)
2. **Pattern B**: Direct execution skills (3 skills)
3. **Pattern C**: Orchestrator/routing skills (1 skill)

Include motivation for each pattern.

### Phase 3: Update Diagrams to Unicode

Replace all ASCII box-drawing with Unicode characters for:
- Main architecture diagram
- Checkpoint model diagram
- Delegation flow diagram

### Phase 4: Add Command-Skill-Agent Matrix

Add comprehensive mapping table showing all commands and their skill/agent relationships.

### Phase 5: Reconcile Agent and User Documentation

Ensure both `.claude/context/core/architecture/system-overview.md` and `.claude/docs/architecture/system-overview.md` are consistent and accurate.

## Decisions

- Pattern A (delegating with internal postflight) is the PRIMARY pattern for new skills
- Pattern B (direct execution) is reserved for simple atomic operations
- The `context: fork` claim is INCORRECT and must be removed from all documentation
- Metadata file exchange is the standard return pattern (not JSON to console)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing understanding | Medium | Low | Clear migration notes in updated docs |
| Unicode rendering issues | Low | Low | Test in common terminals/editors |
| Documentation drift | Medium | Medium | Add "Last Verified" dates to docs |

## Appendix

### Files Examined

**Skills Analyzed** (12 total):
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-researcher/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-status-sync/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-orchestrator/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-cleanup/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-meta/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-implementer/SKILL.md`
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-git-workflow/SKILL.md`
- (and 5 others via pattern analysis)

**Agents Analyzed** (8 total):
- `/home/benjamin/Projects/ProofChecker/.claude/agents/general-research-agent.md`
- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md`
- (and 6 others via listing)

**Documentation Files**:
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/architecture/system-overview.md` (agent-facing)
- `/home/benjamin/Projects/ProofChecker/.claude/docs/architecture/system-overview.md` (user-facing)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/thin-wrapper-skill.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/orchestration/orchestration-core.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/checkpoint-execution.md`

### Related Tasks

- Task 609: Document command-skill-agent architecture (created initial docs)
- Task 611: Context optimization and loading patterns (consolidated orchestration files)

### Key Finding Summary

The system uses a "thin wrapper with internal postflight" pattern where:
1. Skills handle ALL lifecycle operations (preflight status, agent invocation, postflight updates, git commit)
2. Agents write metadata to files (not JSON to console)
3. Context is loaded via @-references in agent bodies (not via frontmatter)
4. `context: fork` and `agent:` frontmatter fields are NOT used (contrary to current documentation)
