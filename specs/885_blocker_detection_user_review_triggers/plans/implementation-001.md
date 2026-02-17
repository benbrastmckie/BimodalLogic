# Implementation Plan: Task #885

- **Task**: 885 - Blocker Detection and User Review Triggers
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/885_blocker_detection_user_review_triggers/reports/research-001.md, specs/885_blocker_detection_user_review_triggers/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implement blocker detection fields and guidance to distinguish hard blockers requiring user review from soft blockers that allow auto-continuation. The approach adds `requires_user_review` and `review_reason` fields to the return metadata schema, adds Blocker Detection sections to implementation agents, and enables skill postflight to check these fields before suggesting auto-resume.

### Research Integration

- **research-001.md**: Blocker taxonomy (soft vs hard blockers), schema change recommendations, decision tree for agent detection
- **research-002.md**: Context file optimization recommendations (deferred to follow-up task)

## Goals & Non-Goals

**Goals**:
- Add `requires_user_review` and `review_reason` fields to return-metadata-file.md schema
- Add Blocker Detection section to lean-implementation-agent.md with detection criteria and decision tree
- Add Blocker Detection section to general-implementation-agent.md with detection criteria and decision tree
- Ensure backward compatibility (fields are optional, existing metadata continues to work)

**Non-Goals**:
- Updating skill postflight to check the new fields (task 886 or follow-up)
- Creating metadata-quick-ref.md (optimization from research-002, separate task)
- Updating error-handling.md with new error types (low priority, can be deferred)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-flagging (agents flag too many blockers) | Medium | Medium | Clear criteria list with examples of what NOT to flag |
| Under-flagging (agents miss hard blockers) | Low | Low | Conservative default: flag uncertain cases, decision tree helps |
| Agent confusion on criteria | Medium | Medium | Concrete examples for each blocker type |
| Schema breaks existing metadata | High | Low | Fields are optional with sensible defaults |

## Implementation Phases

### Phase 1: Update return-metadata-file.md Schema [COMPLETED]

- **Dependencies:** None
- **Goal:** Add requires_user_review and review_reason fields to metadata schema

**Tasks**:
- [x] Add field specifications section for `requires_user_review` (boolean, optional, default false)
- [x] Add field specifications section for `review_reason` (string, required if requires_user_review)
- [x] Add example showing partial status with user review required
- [x] Add section documenting when to set these fields (soft vs hard blockers)
- [x] Update Related Documentation section if needed

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/core/formats/return-metadata-file.md` - Add new fields to schema and examples

**Verification**:
- Schema section includes both new fields with types and requirements
- At least one example shows requires_user_review: true with review_reason
- Blocker taxonomy (soft vs hard) is documented

**Progress:**

**Session: 2026-02-16, sess_1771309217_479a4b**
- Added: `requires_user_review` field specification to return-metadata-file.md
- Added: `review_reason` field specification with conditional requirement
- Added: Example "Implementation Partial (Requires User Review)" with mathematically_false blocker
- Added: "Blocker Taxonomy" section with soft vs hard blocker tables and decision tree

---

### Phase 2: Update lean-implementation-agent.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add Blocker Detection section with criteria and decision tree for Lean proofs

**Tasks**:
- [x] Add new section "## Blocker Detection" after Error Handling section
- [x] Document hard blocker criteria specific to Lean (mathematically false, proof impossible, build fails)
- [x] Document soft blocker criteria (timeout, context exhaustion, MCP transient)
- [x] Add decision tree for determining soft vs hard blockers
- [x] Add concrete examples for each blocker type
- [x] Update Critical Requirements MUST DO list to include blocker detection
- [x] Update Critical Requirements MUST NOT list to include over-flagging guidance

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/lean-implementation-agent.md` - Add Blocker Detection section and update Critical Requirements

**Verification**:
- Blocker Detection section exists with hard/soft blocker criteria
- Decision tree is present and actionable
- Lean-specific examples (counterexample found, proof impossible) included
- MUST DO includes "Set requires_user_review when encountering hard blockers"

**Progress:**

**Session: 2026-02-16, sess_1771309217_479a4b**
- Added: "Blocker Detection" section with soft/hard blocker tables
- Added: Decision tree for Lean proofs (is proof stuck -> can successor continue -> is theorem provable)
- Added: Lean-specific detection criteria (counterexample, type mismatch, missing axiom, etc.)
- Added: Metadata example for hard blocker with proof_impossible type
- Added: MUST DO #17 - Set requires_user_review when encountering hard blockers
- Added: MUST NOT #16-17 - Over-flagging guidance and soft blocker handling

---

### Phase 3: Update general-implementation-agent.md [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add Blocker Detection section with criteria and decision tree for general tasks

**Tasks**:
- [x] Add new section "## Blocker Detection" after Error Handling section
- [x] Document hard blocker criteria for general tasks (invalid spec, missing dependency, unresolvable build error)
- [x] Document soft blocker criteria (timeout, context exhaustion, transient failures)
- [x] Add decision tree (same structure as Lean agent, different examples)
- [x] Add concrete examples for each blocker type
- [x] Update Critical Requirements MUST DO list
- [x] Update Critical Requirements MUST NOT list

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Add Blocker Detection section and update Critical Requirements

**Verification**:
- Blocker Detection section exists with hard/soft blocker criteria
- Decision tree is present and actionable
- General task examples (build fails, missing dependency) included
- MUST DO includes blocker detection requirement

**Progress:**

**Session: 2026-02-16, sess_1771309217_479a4b**
- Added: "Blocker Detection" section with soft/hard blocker tables
- Added: Decision tree for general tasks
- Added: General task detection criteria (spec invalid, dependency missing, build fails, permission denied)
- Added: Metadata example for missing_dependency blocker (npm package not found)
- Added: MUST DO #14 - Set requires_user_review when encountering hard blockers
- Added: MUST NOT #12-13 - Over-flagging guidance and soft blocker handling

---

### Phase 4: Verification and Documentation Cross-Check [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Verify consistency across all modified files and update any cross-references

**Tasks**:
- [ ] Verify return-metadata-file.md schema matches what agents are instructed to write
- [ ] Verify both agent files use consistent terminology and decision tree structure
- [ ] Check that examples in schema match examples in agent guidance
- [ ] Verify no duplicate or conflicting guidance exists
- [ ] Review for any missing cross-references between files

**Timing**: 30 minutes

**Files to modify**:
- None (verification only, edits if inconsistencies found)

**Verification**:
- Schema and agent guidance are consistent
- Terminology is identical across files (requires_user_review, review_reason)
- Examples are complementary, not contradictory

---

## Testing & Validation

- [ ] Schema validates: requires_user_review is boolean, review_reason is string
- [ ] Schema validates: review_reason required only when requires_user_review is true
- [ ] Agent guidance includes complete decision tree
- [ ] Blocker taxonomy clearly distinguishes soft vs hard blockers
- [ ] All examples are syntactically valid JSON
- [ ] Cross-references between files are accurate

## Artifacts & Outputs

- `.claude/context/core/formats/return-metadata-file.md` (modified)
- `.claude/agents/lean-implementation-agent.md` (modified)
- `.claude/agents/general-implementation-agent.md` (modified)
- `specs/885_blocker_detection_user_review_triggers/plans/implementation-001.md` (this file)
- `specs/885_blocker_detection_user_review_triggers/summaries/implementation-summary-{DATE}.md` (created on completion)

## Rollback/Contingency

- All changes are additive (new optional fields, new sections)
- If issues arise, fields can be ignored (default false for requires_user_review)
- Git revert can restore previous versions if critical problems found
- No breaking changes to existing workflows
