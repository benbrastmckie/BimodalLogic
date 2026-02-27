# Implementation Plan: Task #936 (v2)

- **Task**: 936 - Port specialized research agents and skills
- **Status**: [NOT STARTED]
- **Effort**: 4.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/936_port_specialized_research_agents_skills/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Revision Notes (v2)

**Changed from v1:**
- Added Mathlib lookup MCP tools to math and logic research agents
- Math and logic agents now use `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_local_search` for theorem lookup
- LaTeX agent remains unchanged (no Lean MCP tools)
- Updated Non-Goals to clarify: no implementation tools, only lookup tools

## Overview

Port three specialized research agents (`logic-research-agent`, `math-research-agent`, `latex-research-agent`) and their corresponding thin-wrapper skills from the Theory repository to ProofChecker. The agents provide domain-specific research capabilities for modal logic, mathematical structures, and LaTeX documentation. ProofChecker already has supporting context directories for these domains, making the port straightforward.

**Key Change**: Math and logic research agents will have access to Mathlib lookup tools for theorem discovery, but NOT implementation tools. This enables finding relevant lemmas and theorems without the agents needing to write Lean code.

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
- **Add Mathlib lookup MCP tools to math and logic agents**

**Non-Goals**:
- Port context extension stages (4.x, 5.5) - can add later
- Create new context documentation files
- Port any implementation agents (only research agents in scope)
- ~~Add MCP tools to non-Lean research agents~~ (revised: add LOOKUP tools only)
- Add Lean implementation MCP tools (lean_goal, lean_code_actions, etc.)
- Enable math/logic agents to write or edit Lean files

## Mathlib Lookup Tools

The following MCP tools will be added to `logic-research-agent` and `math-research-agent`:

| Tool | Purpose | Rate Limit |
|------|---------|------------|
| `lean_leansearch` | Natural language → Mathlib lemmas | 3/30s |
| `lean_loogle` | Type pattern → Mathlib lemmas | 3/30s |
| `lean_leanfinder` | Semantic/conceptual search | 10/30s |
| `lean_local_search` | Fast local declaration search | none |

**Explicitly NOT included** (implementation tools):
- `lean_goal`, `lean_term_goal` - Proof state inspection
- `lean_hover_info`, `lean_completions` - IDE features
- `lean_code_actions` - Code modifications
- `lean_multi_attempt`, `lean_run_code` - Code execution
- `lean_build`, `lean_diagnostic_messages` - Build tools
- `lean_verify`, `lean_profile_proof` - Verification tools

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Context directory paths differ | Medium | Low | Verify paths before porting, update references |
| Missing context README files | Low | Medium | Create minimal README if missing |
| Language routing conflicts | Medium | Low | Test each language value in isolation |
| Skill invocation pattern differences | Medium | Low | Compare with existing skill-researcher structure |
| MCP tool rate limits | Low | Medium | Document rate limits in agent files |

## Implementation Phases

### Phase 1: Port Research Agents [COMPLETED]

**Progress:**

**Session: 2026-02-26, sess_1740567600_i936**
- Added: `logic-research-agent.md` - Logic domain research agent with Mathlib lookup tools
- Added: `math-research-agent.md` - Math domain research agent with Mathlib lookup tools
- Added: `latex-research-agent.md` - LaTeX documentation research agent (no MCP tools)

- **Dependencies:** None
- **Goal:** Create three research agent files adapted for ProofChecker

**Tasks:**
- [ ] Copy `logic-research-agent.md` from Theory and adapt:
  - Update task directory format from `{NNN}_{SLUG}` to `{N}_{SLUG}`
  - Update context paths to ProofChecker structure
  - Remove context extension stages (4.x, 5.5)
  - Add `model: opus` frontmatter
  - Update codebase sources for ProofChecker file structure
  - **Add Mathlib lookup MCP tools section**: `lean_leansearch`, `lean_loogle`, `lean_leanfinder`, `lean_local_search`
  - **Document rate limits in agent file**
- [ ] Copy `math-research-agent.md` from Theory and adapt:
  - Same adaptations as logic agent
  - Update math-specific context references
  - Update codebase sources (Theories/**/*.lean, etc.)
  - **Add same Mathlib lookup MCP tools as logic agent**
- [ ] Copy `latex-research-agent.md` from Theory and adapt:
  - Same adaptations as above (except MCP tools)
  - Update LaTeX-specific context references
  - Update codebase sources for ProofChecker docs/ structure
  - **No MCP tools** (LaTeX research doesn't need Lean lookup)

**Timing:** 2 hours (increased from 1.5 due to MCP tool integration)

**Files to create:**
- `.claude/agents/logic-research-agent.md`
- `.claude/agents/math-research-agent.md`
- `.claude/agents/latex-research-agent.md`

**Verification:**
- All three agent files created
- No references to Theory-specific paths
- Task directory format uses `{N}_{SLUG}`
- Context references point to existing ProofChecker directories
- **Math and logic agents include Mathlib lookup tools section**
- **Rate limits documented in math/logic agent files**

---

### Phase 2: Port Research Skills [COMPLETED]

**Progress:**

**Session: 2026-02-26, sess_1740567600_i936**
- Added: `skill-logic-research/SKILL.md` - Logic research skill with thin-wrapper pattern
- Added: `skill-math-research/SKILL.md` - Math research skill with thin-wrapper pattern
- Added: `skill-latex-research/SKILL.md` - LaTeX research skill with thin-wrapper pattern

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

### Phase 3: Update Skill-Agent Mappings [COMPLETED]

**Progress:**

**Session: 2026-02-26, sess_1740567600_i936**
- Added: skill-logic-research, skill-math-research, skill-latex-research to Core Mappings table
- Added: logic, math language routing to Language Routing table
- Updated: latex language to use skill-latex-research for research
- Added: logic, math to Team Skill Model Defaults (Opus model)
- Added: Mathlib Lookup Tool Availability section documenting MCP tool access

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
- [ ] **Add note about MCP tool availability**:
  - Document that math/logic research agents have Mathlib lookup tools
  - Document that these are lookup-only, not implementation tools

**Timing:** 30 minutes

**Files to modify:**
- `.claude/context/core/reference/skill-agent-mapping.md`

**Verification:**
- All three new skills appear in Core Mappings table
- Language routing covers logic, math, latex with new research skills
- No duplicate or conflicting entries
- **MCP tool capability documented**

---

### Phase 4: Verify Context and Test [COMPLETED]

**Progress:**

**Session: 2026-02-26, sess_1740567600_i936**
- Verified: logic and latex context directories have README.md
- Added: `math/README.md` (was missing)
- Verified: All skill YAML frontmatter is valid
- Verified: All agent references resolve correctly
- Verified: MCP lean_leansearch tool is accessible and working

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
- [ ] **Verify MCP tool configuration**:
  - Confirm lean-lsp MCP server is configured in settings
  - Test `lean_leansearch` invocation works

**Timing:** 30 minutes

**Files to modify (if needed):**
- `.claude/context/project/logic/README.md` (if missing)
- `.claude/context/project/math/README.md` (if missing)
- `.claude/context/project/latex/README.md` (if missing)

**Verification:**
- All three context domains have at least README.md
- All skill files pass YAML syntax validation
- Agent references resolve to created files
- **MCP tools accessible from agent context**

---

## Testing & Validation

- [ ] All agent files created at correct paths
- [ ] All skill directories created with SKILL.md
- [ ] skill-agent-mapping.md updated with new entries
- [ ] No broken references to Theory repository paths
- [ ] Task directory format uses `{N}_{SLUG}` throughout
- [ ] Frontmatter valid in all agent and skill files
- [ ] Context directories verified to exist
- [ ] **Math/logic agents include Mathlib lookup tools**
- [ ] **Math/logic agents do NOT include implementation tools**

## Artifacts & Outputs

- `.claude/agents/logic-research-agent.md` - Logic domain research agent (with Mathlib lookup)
- `.claude/agents/math-research-agent.md` - Math domain research agent (with Mathlib lookup)
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
