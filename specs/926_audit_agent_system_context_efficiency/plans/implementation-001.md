# Implementation Plan: Task #926

- **Task**: 926 - Audit Agent System Context Efficiency
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/926_audit_agent_system_context_efficiency/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The .claude/ directory currently loads ~25,000 tokens at session startup, contributing to 20% initial context usage. This plan restructures CLAUDE.md and rules files to reduce startup context to ~5,000 tokens (targeting ~5% initial usage) by extracting reference content to lazy-loaded context files and adding path scoping to rules.

### Research Integration

Key findings from research-001.md:
- CLAUDE.md at 227 lines exceeds recommended 100-150 lines
- Rules files total 1,647 lines, should be ~500 lines
- 3 of 7 rules lack path scoping (git-workflow.md, error-handling.md, workflows.md)
- Large tables and JSON examples inflate token count significantly

## Goals & Non-Goals

**Goals**:
- Reduce CLAUDE.md from 227 to ~80 lines
- Reduce rules files from 1,647 to ~500 total lines
- Add path scoping to all rules files
- Create lazy-loaded context files for extracted reference content
- Maintain all functionality through @-references

**Non-Goals**:
- Restructuring context/ directory (already lazy-loaded)
- Changing agent definitions or skill configurations
- Modifying task management workflows
- Cleaning logs/ or output/ directories (no context impact)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking agent workflows | High | Medium | Test each agent type after changes; keep old content accessible via @-references |
| Missing critical context | High | Low | Ensure all @-references resolve; keep behavioral rules in CLAUDE.md |
| Regression in task management | Medium | Low | Preserve state.json structure docs in accessible context file |
| Accidental information loss | Medium | Low | Create reference files before removing from originals |

## Implementation Phases

### Phase 1: Create Reference Context Files [COMPLETED]

- **Dependencies:** None
- **Goal:** Create new context files to hold extracted reference content before modifying CLAUDE.md and rules

**Tasks:**
- [ ] Create `.claude/context/core/reference/command-reference.md` with full command table, usage examples, and descriptions
- [ ] Create `.claude/context/core/reference/skill-agent-mapping.md` with skill-to-agent table and language routing details
- [ ] Create `.claude/context/core/reference/state-json-schema.md` with JSON schemas and examples from state-management.md
- [ ] Create `.claude/context/core/reference/artifact-templates.md` with full templates from artifact-formats.md
- [ ] Create `.claude/context/core/reference/error-recovery-procedures.md` with detailed recovery procedures from error-handling.md
- [ ] Update `.claude/context/index.md` to include new reference files

**Timing:** 1 hour

**Files to create:**
- `.claude/context/core/reference/command-reference.md`
- `.claude/context/core/reference/skill-agent-mapping.md`
- `.claude/context/core/reference/state-json-schema.md`
- `.claude/context/core/reference/artifact-templates.md`
- `.claude/context/core/reference/error-recovery-procedures.md`

**Files to modify:**
- `.claude/context/index.md` - add new reference section

**Verification:**
- All new files exist and contain extracted content
- index.md updated with references to new files
- No broken @-references in new files

---

### Phase 2: Slim Down CLAUDE.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Reduce CLAUDE.md from 227 to ~80 lines by replacing detailed content with @-references

**Tasks:**
- [ ] Keep: Project description (lines 1-11, ~11 lines)
- [ ] Keep: Project structure (lines 12-22, condensed to ~8 lines)
- [ ] Condense: Status markers to single-line list (lines 25-31 -> 2 lines)
- [ ] Remove: Artifact paths example (move to reference/artifact-templates.md)
- [ ] Remove: Language-Based Routing table (already in skill-agent-mapping.md)
- [ ] Condense: Command Reference to names only, add @-reference for details
- [ ] Remove: state.json Structure code block (move to reference/state-json-schema.md)
- [ ] Keep: Completion Workflow (condensed to 2 lines)
- [ ] Keep: Git Commit format (condensed to 1 line + @-reference)
- [ ] Keep: Blocked MCP Tools warning (critical, keep 4 lines)
- [ ] Condense: MCP Tools list to single line
- [ ] Remove: Search Decision Tree (move to mcp-tools-guide.md)
- [ ] Remove: Skill-to-Agent Mapping table (use @-reference)
- [ ] Remove: Team Skill Language Routing paragraph
- [ ] Remove: Team Skill Model Defaults table
- [ ] Condense: Rules References to compact list
- [ ] Condense: Context Imports to compact list
- [ ] Keep: Error Handling summary (4 lines)
- [ ] Keep: jq Command Safety warning (critical, 3 lines)
- [ ] Keep: Important Notes (4 lines)

**Timing:** 1 hour

**Files to modify:**
- `.claude/CLAUDE.md` - comprehensive restructure

**Verification:**
- CLAUDE.md is ~80 lines
- All removed content accessible via @-references
- Test: new session loads correctly
- Critical warnings (blocked MCP tools, jq safety) remain visible

---

### Phase 3: Trim Rules Files [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Reduce rules files from 1,647 to ~500 total lines

**Tasks:**
- [ ] **artifact-formats.md** (393 -> ~80 lines): Keep placeholder conventions table, remove full template examples (reference artifact-templates.md)
- [ ] **state-management.md** (271 -> ~80 lines): Keep status transitions and two-phase pattern, remove JSON examples (reference state-json-schema.md)
- [ ] **error-handling.md** (280 -> ~80 lines): Keep error categories and severity levels, remove detailed recovery procedures (reference error-recovery-procedures.md)
- [ ] **workflows.md** (224 -> ~60 lines): Keep workflow descriptions, remove ASCII diagrams
- [ ] **git-workflow.md** (163 -> ~50 lines): Keep commit format and actions table, remove examples
- [ ] **lean4.md** (185 -> ~80 lines): Keep critical warnings and tool list, reference mcp-tools-guide.md for details
- [ ] **latex.md** (131 -> ~70 lines): Already reasonably sized, minor trimming if possible

**Timing:** 1.5 hours

**Files to modify:**
- `.claude/rules/artifact-formats.md`
- `.claude/rules/state-management.md`
- `.claude/rules/error-handling.md`
- `.claude/rules/workflows.md`
- `.claude/rules/git-workflow.md`
- `.claude/rules/lean4.md`
- `.claude/rules/latex.md` (minor)

**Verification:**
- Total rules lines ~500 (down from 1,647)
- Each file retains core behavioral rules
- @-references to detailed content work
- No functionality lost

---

### Phase 4: Add Path Scoping and Final Verification [COMPLETED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Add path frontmatter to remaining rules and verify overall context reduction

**Tasks:**
- [ ] Add `paths:` frontmatter to git-workflow.md (applies to .git/*, specs/*)
- [ ] Add `paths:` frontmatter to error-handling.md (applies to .claude/**, specs/**)
- [ ] Add `paths:` frontmatter to workflows.md (applies to .claude/**)
- [ ] Verify existing path scoping on artifact-formats.md, state-management.md, lean4.md, latex.md
- [ ] Create verification script to measure total lines in CLAUDE.md + rules/
- [ ] Test: Start new Claude Code session, verify reduced context message
- [ ] Document final metrics in implementation summary

**Timing:** 30 minutes

**Files to modify:**
- `.claude/rules/git-workflow.md` - add paths frontmatter
- `.claude/rules/error-handling.md` - add paths frontmatter
- `.claude/rules/workflows.md` - add paths frontmatter

**Verification:**
- All 7 rules files have paths: frontmatter
- Total CLAUDE.md + rules < 600 lines (down from ~1,900)
- New session shows reduced initial context
- All agent workflows still function

---

## Testing & Validation

- [ ] Count total lines: `wc -l .claude/CLAUDE.md .claude/rules/*.md` shows < 600 total
- [ ] All @-references resolve: Check each reference in CLAUDE.md
- [ ] New session test: Start fresh Claude Code session, observe context usage
- [ ] Agent functionality: Run `/research`, `/plan`, `/implement` on test task
- [ ] Path scoping test: Work on .lean file, verify lean4.md loads but latex.md doesn't

## Artifacts & Outputs

- `specs/926_audit_agent_system_context_efficiency/plans/implementation-001.md` (this file)
- `specs/926_audit_agent_system_context_efficiency/summaries/implementation-summary-{DATE}.md`
- `.claude/context/core/reference/` directory with 5 new files
- Updated `.claude/CLAUDE.md`
- Updated `.claude/rules/*.md` (7 files)

## Rollback/Contingency

All original files are tracked in git. If restructuring causes issues:
1. `git checkout HEAD~1 -- .claude/CLAUDE.md .claude/rules/`
2. Identify which specific change caused the issue
3. Apply incremental changes with testing between each

Git provides full history for all changes. New context files can be removed if not needed.
