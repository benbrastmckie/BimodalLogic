# Implementation Plan: Enhance Task Command with Description Improvement

- **Task**: 756 - enhance_task_command_with_description_improvement
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/756_enhance_task_command_with_description_improvement/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add a lightweight prompt engineering step (Step 2.5) to the `/task` command that transforms raw user input into well-structured task descriptions. The transformation handles three cases: slug expansion (converting snake_case to readable sentences), verb inference (prepending action verbs when missing), and formatting normalization (capitalization, whitespace). The change is contained entirely within `.claude/commands/task.md` in the "Create Task Mode (Default)" section.

### Research Integration

From research-001.md:
- Identified insertion point: between Step 2 (parse description) and Step 3 (detect language)
- Defined transformation algorithm with conservative rules to preserve user intent
- Documented edge cases and what NOT to transform (technical terms, file paths, quoted strings)
- Recommended priority: slug expansion (high), formatting (high), verb inference (medium)

## Goals & Non-Goals

**Goals**:
- Ensure action-oriented task descriptions with clear verbs
- Expand snake_case slugs into readable sentences
- Apply consistent formatting (capitalization, whitespace)
- Preserve ALL technical details from original input

**Non-Goals**:
- Adding external API calls or complex processing
- Changing user intent or adding information not in original
- Implementing a `--raw` flag (deferred to future enhancement)
- Logging before/after transformations (would add complexity)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Over-transformation changes meaning | High | Low | Conservative rules; preserve technical terms verbatim |
| Slug expansion misinterprets compound words | Medium | Medium | Keep CamelCase identifiers intact (e.g., CoherentConstruction) |
| Verb inference adds wrong verb | Medium | Low | Use "Implement" as safe default; rely on keyword matching |
| Breaks existing task creation flow | High | Low | Thorough verification with example inputs |

## Implementation Phases

### Phase 1: Add Step 2.5 - Description Improvement [COMPLETED]

**Goal:** Insert the description improvement step between Step 2 and Step 3 in task.md

**Tasks:**
- [ ] Read current task.md to identify exact insertion point
- [ ] Add Step 2.5 header and sub-steps (2.5.1, 2.5.2, 2.5.3)
- [ ] Document slug expansion rules (2.5.1)
- [ ] Document verb inference rules (2.5.2)
- [ ] Document formatting normalization rules (2.5.3)
- [ ] Add "Preserve exactly" section listing what NOT to transform

**Timing:** 45 minutes

**Files to modify:**
- `.claude/commands/task.md` - Add Step 2.5 between Steps 2 and 3

**Verification:**
- [ ] Step 2.5 appears between "Parse description" and "Detect language"
- [ ] All three sub-steps (2.5.1, 2.5.2, 2.5.3) are documented
- [ ] Preservation rules are clearly stated

---

### Phase 2: Add Examples and Edge Cases [COMPLETED]

**Goal:** Document transformation examples and edge cases for clarity

**Tasks:**
- [ ] Add transformation examples table showing before/after
- [ ] Document edge cases (already good input, quoted strings, CamelCase)
- [ ] Add action verb reference list

**Timing:** 30 minutes

**Files to modify:**
- `.claude/commands/task.md` - Add examples within or after Step 2.5

**Verification:**
- [ ] Examples cover slug expansion, verb inference, and no-change cases
- [ ] Edge cases are documented
- [ ] Action verb categories are listed

---

### Phase 3: Verification and Testing [COMPLETED]

**Goal:** Verify the implementation handles all documented cases correctly

**Tasks:**
- [ ] Test mental walk-through with slug input: `prove_sorries_in_coherentconstruction`
- [ ] Test mental walk-through with abbreviated input: "bug in modal evaluator"
- [ ] Test mental walk-through with already-good input: "Update TODO.md header metrics"
- [ ] Verify technical terms preservation: file paths, identifiers, numbers
- [ ] Review complete Step 2.5 section for clarity and consistency

**Timing:** 15 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- [ ] Slug input transforms to "Prove sorries in CoherentConstruction"
- [ ] Abbreviated input transforms to "Fix bug in modal evaluator"
- [ ] Good input remains unchanged
- [ ] No edge cases would incorrectly transform technical content

## Testing & Validation

- [ ] Verify task.md parses correctly (no syntax errors in markdown)
- [ ] Verify Step 2.5 instructions are clear and unambiguous
- [ ] Confirm preservation rules protect all listed technical content types
- [ ] Walk through 3+ example transformations mentally

## Artifacts & Outputs

- `.claude/commands/task.md` - Modified with Step 2.5
- `specs/756_enhance_task_command_with_description_improvement/plans/implementation-001.md` - This plan
- `specs/756_enhance_task_command_with_description_improvement/summaries/implementation-summary-{DATE}.md` - Post-implementation summary

## Rollback/Contingency

If the enhancement causes issues:
1. Revert the changes to task.md via git: `git checkout HEAD~1 -- .claude/commands/task.md`
2. The original task creation flow will be restored
3. No data loss possible since this only affects future task creation, not existing tasks
