# Implementation Plan: Task #936

- **Task**: 936 - Port specialized research agents and skills
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/936_port_specialized_research_agents_skills/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Port three specialized research agents (`logic-research-agent`, `math-research-agent`, `latex-research-agent`) and their corresponding thin-wrapper skills from the Theory repository to ProofChecker. The agents provide domain-specific research capabilities for modal logic, mathematical structures, and LaTeX documentation. ProofChecker already has supporting context directories for these domains, making the port straightforward.

### Research Integration

Key findings from research-001.md:
- All Theory agents follow consistent structure with 10 core sections (Overview, Metadata, Allowed Tools, Context References, Decision Tree, Codebase Sources, External Sources, Execution Flow, Error Handling, Critical Requirements)
- Skills follow identical 11-stage thin-wrapper pattern to existing `skill-researcher`
- ProofChecker uses unpadded task directory format `{N}_{SLUG}` vs Theory's padded `{NNN}_{SLUG}`
- Context extension stages (4.x, 5.5) are valuable but not needed for initial port
- ProofChecker already has logic/, math/, latex/ context directories

## Goals & Non-Goals

**Goals**:
- Port three research agent files with ProofChecker adaptations
- Port three skill directories with thin-wrapper postflight pattern
- Update skill-agent-mapping.md with new mappings and language routing
- Ensure all agents reference ProofChecker-specific context paths
- Verify context directories exist and have README.md files

**Non-Goals**:
- Port context extension stages (4.x, 5.5) - can add later
- Create new context documentation files
- Add MCP tools to non-Lean research agents
- Port any implementation agents (only research agents in scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Context directory paths differ | Medium | Low | Verify paths before porting, update references |
| Missing context README files | Low | Medium | Create minimal README if missing |
| Language routing conflicts | Medium | Low | Test each language value in isolation |
| Skill invocation pattern differences | Medium | Low | Compare with existing skill-researcher structure |

## Implementation Phases

### Phase 1: Port Research Agents [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create three research agent files adapted for ProofChecker

**Tasks:**
- [ ] Copy `logic-research-agent.md` from Theory and adapt:
  - Update task directory format from `{NNN}_{SLUG}` to `{N}_{SLUG}`
  - Update context paths to ProofChecker structure
  - Remove context extension stages (4.x, 5.5)
  - Add `model: opus` frontmatter
  - Update codebase sources for ProofChecker file structure
- [ ] Copy `math-research-agent.md` from Theory and adapt:
  - Same adaptations as logic agent
  - Update math-specific context references
  - Update codebase sources (Theories/**/*.lean, etc.)
- [ ] Copy `latex-research-agent.md` from Theory and adapt:
  - Same adaptations as above
  - Update LaTeX-specific context references
  - Update codebase sources for ProofChecker docs/ structure

**Timing:** 1.5 hours

**Files to create:**
- `.claude/agents/logic-research-agent.md`
- `.claude/agents/math-research-agent.md`
- `.claude/agents/latex-research-agent.md`

**Verification:**
- All three agent files created
- No references to Theory-specific paths
- Task directory format uses `{N}_{SLUG}`
- Context references point to existing ProofChecker directories

---

### Phase 2: Port Research Skills [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Create three skill directories with thin-wrapper postflight pattern

**Tasks:**
- [ ] Create `skill-logic-research` directory structure:
  - Create `.claude/skills/skill-logic-research/SKILL.md`
  - Follow identical pattern to existing `skill-researcher`
  - Reference `logic-research-agent` as subagent
  - Use thin-wrapper postflight delegation pattern
- [ ] Create `skill-math-research` directory structure:
  - Create `.claude/skills/skill-math-research/SKILL.md`
  - Follow identical pattern to skill-logic-research
  - Reference `math-research-agent` as subagent
- [ ] Create `skill-latex-research` directory structure:
  - Create `.claude/skills/skill-latex-research/SKILL.md`
  - Follow identical pattern to above
  - Reference `latex-research-agent` as subagent

**Timing:** 1.5 hours

**Files to create:**
- `.claude/skills/skill-logic-research/SKILL.md`
- `.claude/skills/skill-math-research/SKILL.md`
- `.claude/skills/skill-latex-research/SKILL.md`

**Verification:**
- All three skill files created
- Each skill references correct agent
- All skills follow 11-stage execution pattern
- `allowed-tools` frontmatter includes Task, Bash, Edit, Read, Write

---

### Phase 3: Update Skill-Agent Mappings [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Register new skills and agents in mapping documentation

**Tasks:**
- [ ] Update Core Mappings table in skill-agent-mapping.md:
  - Add `skill-logic-research` -> `logic-research-agent`
  - Add `skill-math-research` -> `math-research-agent`
  - Add `skill-latex-research` -> `latex-research-agent`
- [ ] Update Language Routing table:
  - Add `logic` language routing to `skill-logic-research` for research
  - Add `math` language routing to `skill-math-research` for research
  - Update `latex` language routing to use `skill-latex-research` for research (instead of skill-researcher)
- [ ] Update Team Skill Model Defaults if needed:
  - Verify logic/math languages use appropriate model defaults

**Timing:** 30 minutes

**Files to modify:**
- `.claude/context/core/reference/skill-agent-mapping.md`

**Verification:**
- All three new skills appear in Core Mappings table
- Language routing covers logic, math, latex with new research skills
- No duplicate or conflicting entries

---

### Phase 4: Verify Context and Test [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify context directories and test skill invocation

**Tasks:**
- [ ] Verify context directories exist with README.md:
  - Check `.claude/context/project/logic/README.md`
  - Check `.claude/context/project/math/README.md` (or subdirectory READMEs)
  - Check `.claude/context/project/latex/README.md`
  - Create minimal README if missing
- [ ] Verify skill syntax by examining SKILL.md files:
  - Check frontmatter is valid YAML
  - Check stage numbering is consistent
  - Check references to agents are correct
- [ ] Document any context gaps found:
  - Note missing context files in task summary
  - Create follow-up task if significant gaps exist

**Timing:** 30 minutes

**Files to modify (if needed):**
- `.claude/context/project/logic/README.md` (if missing)
- `.claude/context/project/math/README.md` (if missing)
- `.claude/context/project/latex/README.md` (if missing)

**Verification:**
- All three context domains have at least README.md
- All skill files pass YAML syntax validation
- Agent references resolve to created files

---

## Testing & Validation

- [ ] All agent files created at correct paths
- [ ] All skill directories created with SKILL.md
- [ ] skill-agent-mapping.md updated with new entries
- [ ] No broken references to Theory repository paths
- [ ] Task directory format uses `{N}_{SLUG}` throughout
- [ ] Frontmatter valid in all agent and skill files
- [ ] Context directories verified to exist

## Artifacts & Outputs

- `.claude/agents/logic-research-agent.md` - Logic domain research agent
- `.claude/agents/math-research-agent.md` - Math domain research agent
- `.claude/agents/latex-research-agent.md` - LaTeX documentation research agent
- `.claude/skills/skill-logic-research/SKILL.md` - Logic research skill
- `.claude/skills/skill-math-research/SKILL.md` - Math research skill
- `.claude/skills/skill-latex-research/SKILL.md` - LaTeX research skill
- Updated `.claude/context/core/reference/skill-agent-mapping.md`
- `specs/936_port_specialized_research_agents_skills/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation causes issues:
1. Remove the three new agent files from `.claude/agents/`
2. Remove the three new skill directories from `.claude/skills/`
3. Revert changes to `skill-agent-mapping.md`
4. All changes are additive, so rollback is straightforward with `git checkout`
