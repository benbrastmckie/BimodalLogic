# Implementation Plan: Upgrade /research Command Domain Routing

- **Task**: 939 - upgrade_research_command_domain_routing
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/939_upgrade_research_command_domain_routing/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation upgrades the `/research` command to support explicit domain override flags (`--lean`, `--logic`, `--math`, `--latex`, `--typst`) that allow users to bypass automatic language-based routing. The upgrade also fixes the outdated routing table to match the authoritative skill-agent-mapping reference.

### Research Integration

Integrated findings from `reports/research-001.md`:
- Routing table in `/research` is out of sync with skill-agent-mapping reference
- Logic, math, latex skills exist but are never invoked due to missing routes
- Argument parsing patterns from `/implement` and `/task` provide templates
- Context Knowledge Task deferred (template doesn't exist yet)

## Goals & Non-Goals

**Goals**:
- Add domain override flags (`--lean`, `--logic`, `--math`, `--latex`, `--typst`) to `/research`
- Update routing table to match skill-agent-mapping reference
- Document new flags in command-reference.md
- Maintain backward compatibility (default behavior unchanged)

**Non-Goals**:
- Create `skill-typst-research` (typst uses general researcher)
- Implement Context Knowledge Task (deferred until template exists)
- Modify research skills or agents themselves

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multiple domain flags specified | Low | Low | First match wins, document "one flag at a time" |
| Breaking existing workflows | Medium | Low | Flags are optional; default routing unchanged |
| Routing table drift | Low | Medium | Update routing.md to stay in sync |

## Implementation Phases

### Phase 1: Update Routing Table [NOT STARTED]

- **Dependencies:** None
- **Goal:** Fix the outdated routing table in `/research` command to match skill-agent-mapping reference

**Tasks:**
- [ ] Read current routing table in `.claude/commands/research.md` STAGE 2
- [ ] Update routing table to include all domain mappings:
  - `lean` -> `skill-lean-research`
  - `logic` -> `skill-logic-research`
  - `math` -> `skill-math-research`
  - `latex` -> `skill-latex-research`
  - `typst`, `general`, `meta`, `markdown` -> `skill-researcher`
- [ ] Update `.claude/context/core/routing.md` for consistency

**Timing:** 30 minutes

**Files to modify:**
- `.claude/commands/research.md` - Update STAGE 2 routing table
- `.claude/context/core/routing.md` - Add missing language entries

**Verification:**
- Routing table matches skill-agent-mapping reference
- All five domain skills are represented

---

### Phase 2: Add Domain Override Flags [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Add `--lean`, `--logic`, `--math`, `--latex`, `--typst` flags to Options section

**Tasks:**
- [ ] Add domain flags to Options table with descriptions
- [ ] Document that domain flags override automatic language-based routing
- [ ] Document that only one domain flag may be specified at a time
- [ ] Preserve existing `--team` and `--team-size` flags

**Timing:** 20 minutes

**Files to modify:**
- `.claude/commands/research.md` - Options section

**Verification:**
- Options table includes all five domain flags
- Flags documented with clear descriptions
- Mutual exclusivity noted

---

### Phase 3: Add Flag Parsing Logic [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Add STAGE 1.5 to parse domain flags and determine effective_domain

**Tasks:**
- [ ] Add new `### STAGE 1.5: PARSE DOMAIN FLAGS` section after CHECKPOINT 1
- [ ] Implement domain flag detection (mutually exclusive, first match wins)
- [ ] Extract focus_prompt by removing all flags from arguments
- [ ] Determine effective_domain (domain_override if set, else task_language)
- [ ] Update "On GATE IN success" to reference STAGE 1.5

**Timing:** 40 minutes

**Files to modify:**
- `.claude/commands/research.md` - Add STAGE 1.5 after CHECKPOINT 1

**Verification:**
- Flag parsing logic handles all five domain flags
- Focus prompt extraction removes all flags cleanly
- Effective domain determination is clear

---

### Phase 4: Update STAGE 2 for Effective Domain [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Update STAGE 2 to route based on effective_domain instead of task language

**Tasks:**
- [ ] Change heading from "Language-Based Routing" to "Domain-Based Routing"
- [ ] Update table to use "Effective Domain" column
- [ ] Update Skill invocation to pass domain_override parameter
- [ ] Add note about flag precedence in skill args

**Timing:** 30 minutes

**Files to modify:**
- `.claude/commands/research.md` - STAGE 2 section

**Verification:**
- Routing uses effective_domain, not task language
- Skill invocation includes domain_override parameter
- Clear connection between STAGE 1.5 and STAGE 2

---

### Phase 5: Update Command Reference [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Document new flags in command-reference.md

**Tasks:**
- [ ] Add domain flags to /research entry in command-reference.md
- [ ] Update argument-hint in command-reference.md to show domain flags
- [ ] Add usage examples showing domain override

**Timing:** 30 minutes

**Files to modify:**
- `.claude/context/core/reference/command-reference.md` - /research section

**Verification:**
- All five domain flags documented
- Usage examples clear and accurate
- Argument hint updated

---

### Phase 6: Context Knowledge Task [DEFERRED]

- **Dependencies:** Phase 5, context-knowledge-template.md creation
- **Goal:** Add Context Knowledge Task prompt after research completion

**Tasks:**
- [ ] Create STAGE 2.5: CONTEXT KNOWLEDGE PROMPT section
- [ ] Parse research report for Context Extension Recommendations
- [ ] Prompt user to create tasks for high-priority documentation gaps
- [ ] Add created task numbers to return metadata

**Timing:** Deferred

**Notes:**
- This phase is deferred until `.claude/context/core/templates/context-knowledge-template.md` is created
- Research identified that this template is referenced but does not exist
- Recommend creating template as separate task before implementing this phase
- Implementation location: After CHECKPOINT 2: GATE OUT, before CHECKPOINT 3: COMMIT

**Verification:**
- Template exists at expected path
- Context extension parsing works correctly
- User prompt is non-blocking (can skip)

---

## Testing & Validation

- [ ] Verify routing table matches skill-agent-mapping reference
- [ ] Test `/research N --lean` routes to skill-lean-research
- [ ] Test `/research N --logic` routes to skill-logic-research
- [ ] Test `/research N --math` routes to skill-math-research
- [ ] Test `/research N --latex` routes to skill-latex-research
- [ ] Test `/research N --typst` routes to skill-researcher
- [ ] Test `/research N` (no flag) uses task language as before
- [ ] Test `/research N focus prompt --lean` correctly extracts focus
- [ ] Verify backward compatibility (existing workflows unchanged)

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified `.claude/commands/research.md`
- Modified `.claude/context/core/routing.md`
- Modified `.claude/context/core/reference/command-reference.md`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If changes cause issues:
1. Revert `.claude/commands/research.md` to previous version via git
2. Revert routing.md and command-reference.md similarly
3. Default routing behavior is preserved (flags are additive)

The implementation is low-risk as:
- Domain flags are optional (default behavior unchanged)
- Changes are confined to three files
- No skill or agent modifications required
