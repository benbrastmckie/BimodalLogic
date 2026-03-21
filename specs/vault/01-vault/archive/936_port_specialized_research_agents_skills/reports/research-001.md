# Research Report: Task #936

**Task**: 936 - Port specialized research agents and skills
**Started**: 2026-02-26T12:00:00Z
**Completed**: 2026-02-26T12:30:00Z
**Effort**: 30 minutes
**Dependencies**: None
**Sources/Inputs**: Theory repository `.claude/` directory, ProofChecker `.claude/` directory
**Artifacts**: specs/936_port_specialized_research_agents_skills/reports/research-001.md
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- Theory repository has 3 specialized research agents: `logic-research-agent`, `math-research-agent`, `latex-research-agent`
- Each agent has a corresponding thin-wrapper skill (`skill-logic-research`, `skill-math-research`, `skill-latex-research`)
- The skill-agent pattern follows identical structure to ProofChecker's existing `skill-researcher` -> `general-research-agent` pattern
- ProofChecker already has context directories for logic, math, and latex domains that can support these agents
- Port requires: 3 agent files, 3 skill directories, update to skill-agent-mapping.md, language routing updates

## Context & Scope

This research analyzes the Theory repository's specialized research agents and skills to understand:
1. Agent file structure and format
2. Skill integration patterns (thin-wrapper postflight pattern)
3. Tool configurations and allowed-tools
4. Context references needed
5. Differences requiring adaptation for ProofChecker

## Findings

### Agent File Structure

All three Theory agents follow a consistent structure:

#### Frontmatter
```yaml
---
name: {agent-name}
description: Research {domain} tasks using domain context and codebase exploration
---
```

#### Core Sections
1. **Overview** - Purpose, invocation pattern, return format
2. **Agent Metadata** - Name, Purpose, Invoked By, Return Format
3. **Allowed Tools** - File Operations, Build Tools, Web Tools
4. **Context References** - Always Load, Dynamic Context Discovery, Lazy Loading Pattern
5. **Research Strategy Decision Tree** - Domain-specific search approach
6. **Codebase Sources** - Tables of relevant source files
7. **External Research Sources** - Web resources with query examples
8. **Execution Flow** - Stages 0-7 (same as ProofChecker agents)
9. **Error Handling** - Standard patterns
10. **Critical Requirements** - MUST DO / MUST NOT lists

### Agent-Specific Characteristics

#### logic-research-agent.md
- **Domain**: Modal logic, temporal logic, mereology, topology, mathematical foundations
- **Codebase Sources**: LaTeX chapters (02-ConstitutiveFoundation.tex, 03-DynamicsFoundation.tex, 06-Spatial.tex), Lean modules (Bimodal/*)
- **External Resources**: Stanford Encyclopedia, Mathlib, LeanSearch/Loogle
- **Context Index**: `.claude/context/project/logic/README.md`
- **Context Extension**: Stage 4 includes context gap identification and Stage 5.5 for optional task creation

#### math-research-agent.md
- **Domain**: Algebra, lattice theory, order theory, topology, category theory
- **Codebase Sources**: Theories/**/*.lean, latex/subfiles/* chapters
- **External Resources**: Mathlib docs, nLab, LeanSearch/Loogle
- **Context Index**: `.claude/context/project/math/README.md`
- **Subdomains**: algebra/, lattice-theory/, order-theory/, topology/, category-theory/

#### latex-research-agent.md
- **Domain**: LaTeX documentation, document structure, theorem environments, cross-references
- **Codebase Sources**: latex/logos/*.tex, latex/subfiles/*.tex, *.sty files
- **External Resources**: CTAN, Overleaf, TeX StackExchange
- **Context Index**: `.claude/context/project/latex/README.md`
- **Key Packages**: amsmath, amsthm, hyperref, tikz-cd, thmtools, subfiles

### Skill Structure (Thin-Wrapper Pattern)

All three Theory skills follow identical structure to ProofChecker's `skill-researcher`:

#### Frontmatter
```yaml
---
name: skill-{domain}-research
description: Research {domain} tasks using domain context and codebase exploration
allowed-tools: Task, Bash, Edit, Read, Write
---
```

#### Execution Stages
1. **Stage 1: Input Validation** - Task lookup from state.json
2. **Stage 2: Preflight Status Update** - Update to "researching"
3. **Stage 3: Create Postflight Marker** - `.postflight-pending` file
4. **Stage 4: Prepare Delegation Context** - JSON delegation payload
5. **Stage 5: Invoke Subagent** - Task tool with subagent_type parameter
6. **Stage 6: Parse Subagent Return** - Read `.return-meta.json`
7. **Stage 7: Update Task Status** - Postflight status change
8. **Stage 8: Link Artifacts** - Add artifact to state.json
9. **Stage 9: Git Commit** - Commit with session ID
10. **Stage 10: Cleanup** - Remove marker files
11. **Stage 11: Return Brief Summary** - Text (not JSON)

### Differences Between Theory and ProofChecker

| Aspect | Theory | ProofChecker | Adaptation Needed |
|--------|--------|--------------|-------------------|
| Task dir format | `specs/{NNN}_{SLUG}/` (padded) | `specs/{N}_{SLUG}/` (unpadded) | Update printf patterns |
| Context paths | Same structure | Same structure | None |
| MCP tools | None in research agents | lean-lsp in lean-research-agent | Ensure agents don't use MCP |
| jq patterns | Issue #1132 workaround | Same workaround | None |
| Postflight pattern | Identical | Identical | None |
| Return format | Brief text + metadata file | Identical | None |
| Context extension | Stages 4.x and 5.5 | Not in existing agents | Port the pattern |
| Blocked tools | None | lean_diagnostic_messages, lean_file_outline | Add to lean-specific agents |

### ProofChecker Context Directory Status

ProofChecker already has supporting context directories:

| Domain | Path | Contents |
|--------|------|----------|
| logic | `.claude/context/project/logic/` | README.md, domain/, processes/, standards/ |
| math | `.claude/context/project/math/` | algebra/, lattice-theory/, order-theory/, topology/ |
| latex | `.claude/context/project/latex/` | Similar to Theory structure |

### Language Routing Updates Needed

Current ProofChecker routing (from skill-agent-mapping.md):

| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| `lean` | skill-lean-research | skill-lean-implementation |
| `latex` | skill-researcher | skill-latex-implementation |
| `logic` | (not defined) | (not defined) |
| `math` | (not defined) | (not defined) |

Proposed additions:

| Language | Research Skill | Implementation Skill |
|----------|---------------|---------------------|
| `logic` | skill-logic-research | skill-implementer (or specialized) |
| `math` | skill-math-research | skill-implementer (or specialized) |

### Context Extension Pattern (Theory Innovation)

Theory agents include a sophisticated context gap identification system in Stages 4.1-4.4 and optional task creation in Stage 5.5:

- **Stage 4.1**: Context File Discovery via index.json queries
- **Stage 4.2**: Concept Comparison Checklist
- **Stage 4.3**: Build Context Gaps List
- **Stage 4.4**: Determine Task Creation Eligibility
- **Stage 5.5**: Create Context Extension Tasks (skipped for meta tasks)

This pattern is valuable for surfacing documentation gaps but may not be necessary for initial port. Recommend implementing in Phase 2.

### Implementation Approach Recommendations

1. **Port agents first, test, then port skills** - Agents are standalone; skills depend on agents
2. **Use ProofChecker patterns for task directory format** - `{N}_{SLUG}` without padding
3. **Skip MCP tools in non-Lean agents** - These agents use web research, not lean-lsp
4. **Port thin-wrapper skill pattern exactly** - Same 11-stage execution flow
5. **Update skill-agent-mapping.md** - Add new mappings for logic/math languages
6. **Add new language values to state.json schema** - Ensure logic/math are valid

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Context Extension Pattern (Stages 4.x, 5.5) | Context Extension Pattern | No | new_file |
| Specialized research agent template | Agent File Structure | Partial | extension |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `context-extension-pattern.md` | `core/patterns/` | Document the Theory pattern for identifying context gaps during research | Low | No |

**Rationale for new files**:
- `context-extension-pattern.md`: Would be useful but not blocking for this port task. Consider adding after specialized agents are working.

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `skill-agent-mapping.md` | Core Mappings table | Add logic-research, math-research, latex-research | High | No (part of implementation) |
| `skill-agent-mapping.md` | Language Routing table | Add logic, math language entries | High | No (part of implementation) |

### Summary

- **New files needed**: 0 (optional pattern doc can wait)
- **Extensions needed**: 1 (skill-agent-mapping.md - part of implementation)
- **Tasks to create**: 0
- **High priority gaps**: 1 (mapping update - handled by implementation)

## Decisions

1. **Task directory format**: Use ProofChecker convention `{N}_{SLUG}` (unpadded) instead of Theory's `{NNN}_{SLUG}` (padded)
2. **Context extension stages**: Skip Stages 4.x and 5.5 in initial port (can add later)
3. **Skill postflight pattern**: Use identical pattern to existing skill-researcher
4. **MCP tools**: Do NOT add lean-lsp MCP tools to non-Lean research agents
5. **Agent model specification**: Add `model: opus` frontmatter to match lean-research-agent pattern

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Context directory differences | Low | Low | ProofChecker already has logic/math/latex dirs |
| Language routing conflicts | Low | Medium | Test each language in isolation |
| Skill invocation failures | Medium | Medium | Port skills one at a time, test each |
| Missing context README files | Medium | Low | Create minimal README if missing |

## Appendix

### Files Analyzed (Theory Repository)

- `/home/benjamin/Projects/Logos/Theory/.claude/agents/logic-research-agent.md` (738 lines)
- `/home/benjamin/Projects/Logos/Theory/.claude/agents/math-research-agent.md` (724 lines)
- `/home/benjamin/Projects/Logos/Theory/.claude/agents/latex-research-agent.md` (741 lines)
- `/home/benjamin/Projects/Logos/Theory/.claude/skills/skill-logic-research/SKILL.md` (311 lines)
- `/home/benjamin/Projects/Logos/Theory/.claude/skills/skill-math-research/SKILL.md` (311 lines)
- `/home/benjamin/Projects/Logos/Theory/.claude/skills/skill-latex-research/SKILL.md` (311 lines)

### Files Analyzed (ProofChecker Repository)

- `/home/benjamin/Projects/ProofChecker/.claude/agents/lean-research-agent.md` (existing pattern)
- `/home/benjamin/Projects/ProofChecker/.claude/skills/skill-researcher/SKILL.md` (existing pattern)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/reference/skill-agent-mapping.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/formats/return-metadata-file.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/postflight-control.md`
- `/home/benjamin/Projects/ProofChecker/.claude/context/project/logic/README.md`

### Implementation Checklist

1. [ ] Create `agents/logic-research-agent.md` (adapted from Theory)
2. [ ] Create `agents/math-research-agent.md` (adapted from Theory)
3. [ ] Create `agents/latex-research-agent.md` (adapted from Theory)
4. [ ] Create `skills/skill-logic-research/SKILL.md` (adapted from Theory)
5. [ ] Create `skills/skill-math-research/SKILL.md` (adapted from Theory)
6. [ ] Create `skills/skill-latex-research/SKILL.md` (adapted from Theory)
7. [ ] Update `context/core/reference/skill-agent-mapping.md`
8. [ ] Verify context directories exist (logic, math, latex)
9. [ ] Test each skill with sample task
