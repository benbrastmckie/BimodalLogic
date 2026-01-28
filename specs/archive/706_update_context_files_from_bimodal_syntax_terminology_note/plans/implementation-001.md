# Implementation Plan: Task #706

- **Task**: 706 - update_context_files_from_bimodal_syntax_terminology_note
- **Status**: [COMPLETED]
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: None (task created from NOTE tag)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Update .claude/context/project/logic/ files to document the terminology preference for "sentence letter" instead of "propositional atom" or "propositional variable". This convention applies to ALL logic syntax documentation, not just Bimodal TM. The key points are: (1) "sentence letter" is the preferred term over "propositional atom" in all logic documentation; (2) in languages with predicates, a sentence letter is equivalent to a zero-place predicate.

## Goals & Non-Goals

**Goals**:
- Add a terminology section to the logic README documenting the "sentence letter" preference
- Update notation-standards.md to use "sentence letter" terminology
- Update naming-conventions.md to reflect the preferred terminology
- Update proof-theory-concepts.md to use consistent terminology
- Ensure cross-references between files are maintained

**Non-Goals**:
- Updating Lean 4 source code (type names like `PropVar` remain unchanged)
- Updating lean4 context files (they document Lean implementation, not logic theory)
- Changing any formal definitions or proofs
- Renaming any code constructs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Inconsistent terminology | Low | Medium | Review all files after changes for consistency |
| Breaking cross-references | Low | Low | Check related documentation links remain valid |

## Implementation Phases

### Phase 1: Add Terminology Section to Logic README [COMPLETED]

**Goal**: Establish the canonical terminology preference in the main logic context README

**Tasks**:
- [ ] Add a "Terminology Conventions" section to `.claude/context/project/logic/README.md`
- [ ] Document "sentence letter" as preferred over "propositional atom"
- [ ] Note the zero-place predicate equivalence for languages with predicates

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/logic/README.md` - Add terminology section

**Verification**:
- Terminology section exists and is clearly written
- References the convention applies to ALL logic syntax

---

### Phase 2: Update Notation Standards [COMPLETED]

**Goal**: Update the notation-standards.md file to use "sentence letter" terminology

**Tasks**:
- [ ] Update the Propositional Operators table to use "Sentence letter" instead of "Atom"
- [ ] Update "Propositional atoms" to "Sentence letters" in the table
- [ ] Add a note about the terminology preference
- [ ] Update the Formula Variable Naming section

**Timing**: 15 minutes

**Files to modify**:
- `.claude/context/project/logic/standards/notation-standards.md` - Update terminology in tables and text

**Verification**:
- All references to "propositional atom" are updated
- Tables use "sentence letter" consistently

---

### Phase 3: Update Naming Conventions [COMPLETED]

**Goal**: Update naming-conventions.md to use "sentence letter" terminology

**Tasks**:
- [ ] Update Variable Naming section to use "sentence letters" instead of "atomic propositions"
- [ ] Update the table entry for p, q, r, s variables
- [ ] Ensure consistency with Lean code examples (constructor name `atom` remains)

**Timing**: 10 minutes

**Files to modify**:
- `.claude/context/project/logic/standards/naming-conventions.md` - Update terminology

**Verification**:
- Variable naming section uses "sentence letter" consistently
- Code examples remain valid (constructor names unchanged)

---

### Phase 4: Update Proof Theory Concepts [COMPLETED]

**Goal**: Update proof-theory-concepts.md to use "sentence letter" terminology

**Tasks**:
- [ ] Update "Propositional variables" comment to "Sentence letters"
- [ ] Add terminology note explaining the relationship to code constructs

**Timing**: 10 minutes

**Files to modify**:
- `.claude/context/project/logic/domain/proof-theory-concepts.md` - Update terminology

**Verification**:
- Documentation uses "sentence letter" terminology
- Code examples remain valid (type name `PropVar` unchanged)

---

### Phase 5: Verification and Cross-Reference Check [COMPLETED]

**Goal**: Verify consistency across all updated files

**Tasks**:
- [ ] Review all modified files for consistent terminology
- [ ] Verify cross-references between files are intact
- [ ] Check that code examples remain syntactically valid

**Timing**: 10 minutes

**Verification**:
- All files use "sentence letter" consistently
- No broken references or invalid code examples

## Testing & Validation

- [ ] Grep for remaining instances of "propositional atom" in logic context files
- [ ] Verify README terminology section is accessible and clear
- [ ] Confirm code examples in documentation still use valid Lean syntax

## Artifacts & Outputs

- `.claude/context/project/logic/README.md` - Updated with terminology section
- `.claude/context/project/logic/standards/notation-standards.md` - Updated terminology
- `.claude/context/project/logic/standards/naming-conventions.md` - Updated terminology
- `.claude/context/project/logic/domain/proof-theory-concepts.md` - Updated terminology
- `specs/706_update_context_files_from_bimodal_syntax_terminology_note/plans/implementation-001.md` - This plan

## Rollback/Contingency

If changes cause issues:
1. Use git to revert the specific file changes
2. All changes are documentation-only with no code impact
3. Re-read original files from git history if needed
