# Implementation Plan: Task #704

- **Task**: 704 - create_typst_agent_and_skill
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Priority**: high
- **Dependencies**: None
- **Research Inputs**: specs/704_create_typst_agent_and_skill/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a Typst agent and skill that parallels the existing LaTeX infrastructure for handling Typst document implementation tasks. The project already has substantial Typst usage in `Theories/Bimodal/typst/` with established patterns including thmbox for theorem environments and New Computer Modern fonts. The Typst skill will follow the thin-wrapper delegation pattern, invoking a typst-implementation-agent that handles document creation, compilation via `typst compile`, and summary generation.

### Research Integration

Key findings from research-001.md:
- Typst compilation is simpler than LaTeX (single `typst compile` command, no multi-pass)
- Project uses thmbox package and CeTZ for diagrams
- Context files should mirror LaTeX structure at `.claude/context/project/typst/`
- No bibliography processing step needed (handled automatically)

## Goals & Non-Goals

**Goals**:
- Create skill-typst-implementation following thin-wrapper pattern
- Create typst-implementation-agent following 8-stage execution model
- Create Typst context files mirroring LaTeX structure
- Update CLAUDE.md with typst language routing
- Update context/index.md with typst references

**Non-Goals**:
- Creating new Typst template files (use existing in Theories/Bimodal/typst/)
- Modifying existing Typst documents
- Adding Typst MCP tools (not available)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Typst CLI not installed | Medium | Low | Document installation in compilation guide |
| Missing font handling | Low | Low | Use New Computer Modern (already in project) |
| Package version drift | Low | Medium | Pin versions in context docs |

## Implementation Phases

### Phase 1: Create Typst Context Files [COMPLETED]

**Goal**: Establish Typst-specific documentation mirroring LaTeX context structure

**Tasks**:
- [ ] Create `.claude/context/project/typst/README.md` with overview
- [ ] Create `.claude/context/project/typst/standards/typst-style-guide.md` covering document setup, typography, show rules
- [ ] Create `.claude/context/project/typst/standards/notation-conventions.md` documenting shared-notation.typ and theory modules
- [ ] Create `.claude/context/project/typst/standards/document-structure.md` for main document and chapter organization
- [ ] Create `.claude/context/project/typst/patterns/theorem-environments.md` covering thmbox setup
- [ ] Create `.claude/context/project/typst/patterns/cross-references.md` for labels, refs, Lean xrefs
- [ ] Create `.claude/context/project/typst/templates/chapter-template.md` with boilerplate
- [ ] Create `.claude/context/project/typst/tools/compilation-guide.md` for typst compile/watch

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/context/project/typst/README.md` - create new
- `.claude/context/project/typst/standards/typst-style-guide.md` - create new
- `.claude/context/project/typst/standards/notation-conventions.md` - create new
- `.claude/context/project/typst/standards/document-structure.md` - create new
- `.claude/context/project/typst/patterns/theorem-environments.md` - create new
- `.claude/context/project/typst/patterns/cross-references.md` - create new
- `.claude/context/project/typst/templates/chapter-template.md` - create new
- `.claude/context/project/typst/tools/compilation-guide.md` - create new

**Verification**:
- All context files exist and contain project-specific patterns from `Theories/Bimodal/typst/`
- Directory structure mirrors `.claude/context/project/latex/`

---

### Phase 2: Create Typst Implementation Agent [COMPLETED]

**Goal**: Create the implementation agent that executes Typst document creation and compilation

**Tasks**:
- [ ] Create `.claude/agents/typst-implementation-agent.md` with YAML frontmatter
- [ ] Define 8-stage execution flow (mirroring latex-implementation-agent)
- [ ] Adapt compilation loop for `typst compile` (simpler than LaTeX multi-pass)
- [ ] Document context references for Typst-specific files
- [ ] Include error handling for compilation failures
- [ ] Define return format (brief text summary + metadata file)

**Timing**: 1 hour

**Files to modify**:
- `.claude/agents/typst-implementation-agent.md` - create new

**Verification**:
- Agent file has valid YAML frontmatter (name, description)
- All 8 stages documented
- Compilation commands use `typst compile` not `latexmk`
- Context references point to Phase 1 files

---

### Phase 3: Create Typst Implementation Skill [COMPLETED]

**Goal**: Create the thin-wrapper skill that delegates to the typst-implementation-agent

**Tasks**:
- [ ] Create `.claude/skills/skill-typst-implementation/SKILL.md`
- [ ] Define trigger conditions (language: "typst")
- [ ] Implement preflight status update
- [ ] Configure Task tool delegation to typst-implementation-agent
- [ ] Implement postflight status update with completion_data handling
- [ ] Define git commit pattern
- [ ] Document return format

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-typst-implementation/SKILL.md` - create new

**Verification**:
- Skill file has valid YAML frontmatter
- Delegates to typst-implementation-agent via Task tool
- Preflight/postflight patterns match skill-latex-implementation

---

### Phase 4: Update System Documentation [IN PROGRESS]

**Goal**: Integrate Typst into the orchestration system

**Tasks**:
- [ ] Update CLAUDE.md Language-Based Routing table with typst row
- [ ] Update CLAUDE.md Skill-to-Agent Mapping table with skill-typst-implementation entry
- [ ] Update `.claude/context/index.md` with typst context file references

**Timing**: 30 minutes

**Files to modify**:
- `.claude/CLAUDE.md` - add typst to routing and mapping tables
- `.claude/context/index.md` - add typst context references

**Verification**:
- CLAUDE.md has typst row in Language-Based Routing
- CLAUDE.md has skill-typst-implementation in Skill-to-Agent Mapping
- context/index.md references all Phase 1 context files

---

### Phase 5: Verification and Testing [NOT STARTED]

**Goal**: Verify all components are properly integrated

**Tasks**:
- [ ] Verify agent file has valid YAML frontmatter (required for registration)
- [ ] Verify skill file has valid YAML frontmatter
- [ ] Verify all context file paths are correct and files exist
- [ ] Check cross-references between skill and agent are consistent
- [ ] Verify CLAUDE.md updates are syntactically correct

**Timing**: 15 minutes

**Files to modify**: None (verification only)

**Verification**:
- All YAML frontmatter is valid
- All file paths in context references exist
- Documentation is internally consistent

---

## Testing & Validation

- [ ] Agent file parses as valid Markdown with YAML frontmatter
- [ ] Skill file parses as valid Markdown with YAML frontmatter
- [ ] All 8 context files in `.claude/context/project/typst/` exist
- [ ] CLAUDE.md routing table includes typst
- [ ] CLAUDE.md skill mapping includes skill-typst-implementation
- [ ] context/index.md references all typst context files

## Artifacts & Outputs

- `.claude/agents/typst-implementation-agent.md` - Implementation agent
- `.claude/skills/skill-typst-implementation/SKILL.md` - Thin wrapper skill
- `.claude/context/project/typst/` - 8 context files (README + 7 topic files)
- `.claude/CLAUDE.md` - Updated with typst routing
- `.claude/context/index.md` - Updated with typst references
- `specs/704_create_typst_agent_and_skill/summaries/implementation-summary-{DATE}.md` - Summary

## Rollback/Contingency

If implementation fails:
1. Delete newly created files in `.claude/agents/`, `.claude/skills/`, `.claude/context/project/typst/`
2. Revert CLAUDE.md and context/index.md changes
3. Task remains in [IMPLEMENTING] status for retry
