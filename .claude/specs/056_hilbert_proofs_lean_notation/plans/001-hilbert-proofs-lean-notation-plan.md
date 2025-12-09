# Implementation Plan: Hilbert Theorems Integration to TODO.md

## Metadata
- **Date**: 2025-12-09
- **Feature**: Integrate 25 unproven Hilbert theorems from LogicNotes.tex into TODO.md Medium Priority section using Lean notation
- **Scope**: Add 14 propositional logic theorems and 11 modal logic theorems from sec:PL-Hilbert-Proofs to TODO.md, formatted as actionable implementation tasks with Lean signatures, dependencies, and effort estimates
- **Status**: [COMPLETE]
- **Estimated Hours**: 6-8 hours
- **Complexity Score**: 45.0
- **Structure Level**: 0
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Research Report: Propositional Logic Hilbert Theorems](../reports/001-propositional-logic-hilbert-theorems.md)
  - [Research Report: Modal Logic Axiomatic Theorems](../reports/002-modal-logic-axiomatic-theorems.md)
  - [Research Report: TODO.md Integration and Documentation](../reports/003-todo-integration-documentation.md)

## Overview

This plan integrates 25 unproven theorems from the Hilbert axiomatic proofs section of LogicNotes.tex into the TODO.md Medium Priority Tasks section. The research phase identified 14 propositional logic theorems (RAA, EFQ, RCP, NE, NI, ECQ, LDI, RDI, LCE, RCE, DE, BI, LBE, RBE) and 11 modal logic theorems (t_box_to_diamond, box_conj_iff, diamond_disj_iff, s5_diamond_box, box_disj_intro, box_contrapose, t_box_consistent, s5_diamond_box_to_truth, s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond, s5_diamond_conj_diamond) that are not yet derived in the Logos project.

Six theorems were found to already exist: DNE and DNI (axioms), CP, HE, CI, and HS (theorems). These will be skipped during integration.

## Research Summary

The research phase produced three comprehensive reports:

**Propositional Logic Theorems**: Analyzed 20 theorems from sec:PL-Hilbert-Proofs in LogicNotes.tex (lines 377-398). Six theorems already exist in Logos (DNE, DNI, CP, HE, CI, HS). The remaining 14 theorems require derivation and include simple theorems (RAA, EFQ, LCE, RCE, LDI, RDI) suitable for immediate implementation, medium-complexity theorems requiring context manipulation (RCP, ECQ, NE, NI, DE), and biconditional reasoning theorems (BI, LBE, RBE).

**Modal Logic Theorems**: Analyzed modal axiom schemata (K, D, T, B, 4, 5) and 20 problem set theorems from lines 471-553 of LogicNotes.tex. Nine theorems/axioms already exist (K, T, B, 4, 5, box_mono, diamond_mono, diamond_4, mb_diamond). The remaining 11 theorems include simple S5 theorems (t_box_to_diamond, box_conj_iff, diamond_disj_iff, s5_diamond_box), medium-complexity modal reasoning theorems (box_disj_intro, box_contrapose, t_box_consistent, s5_diamond_box_to_truth), and complex S4-specific theorems (s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond, s5_diamond_conj_diamond).

**TODO.md Integration Strategy**: Defined formatting standards for task entries including task number (Tasks 21-41), effort estimate (2-9 hours per task), status (Not Started), priority (Medium/Low), dependencies, Lean signatures, and implementation file paths. Total estimated effort: 95-125 hours across all 25 theorems. Prioritization strategy: 7 high-priority tasks (21-24, 30-32), 9 medium-priority tasks (25-29, 33-37), 5 low-priority tasks (38-41).

## Success Criteria

- [ ] All 14 propositional logic theorems (Tasks 21-29) added to TODO.md Medium Priority section with complete task format
- [ ] All 11 modal logic theorems (Tasks 30-41) added to TODO.md Medium Priority section with complete task format
- [ ] Each task entry includes: task number, title, effort estimate, status, priority, blocking status, dependencies, description, Lean signature, and implementation file path
- [ ] Task numbering is sequential (Tasks 21-41) with no gaps or duplicates
- [ ] High-priority tasks (21-24, 30-32) clearly identified for immediate implementation focus
- [ ] TODO.md "Last Updated" date field updated to 2025-12-09
- [ ] TODO.md remains valid Markdown with proper formatting and structure
- [ ] All Lean signatures use correct Logos Formula syntax (`.imp`, `.neg`, `.box`, `.diamond`, `.and`, `.or`, `.iff`)
- [ ] No duplicate theorems added (verified against existing Perpetuity.lean and Axioms.lean theorems)

## Technical Design

### Integration Strategy

The integration follows a structured task entry format derived from research report 003:

**Task Entry Template**:
```markdown
**Task N: [Theorem Name] ([Abbreviation])**
**Effort**: X-Y hours
**Status**: Not Started
**Priority**: Medium/Low
**Blocking**: None
**Dependencies**: [List axioms and theorems used]

**Description**: [1-2 sentence theorem explanation with mathematical intuition]

**Lean Signature**:
theorem theorem_name (params) : [] ⊢ formula
```

**Files**: [Implementation file path]

### File Organization

**Propositional Theorems** (Tasks 21-29): Recommend creating `Logos/Core/Theorems/Propositional.lean` as a new file to house propositional logic theorems separate from the bimodal perpetuity theorems. Alternative: append to `Logos/Core/Theorems/Perpetuity.lean` if keeping single-file organization.

**Modal Theorems** (Tasks 30-37): Recommend creating `Logos/Core/Theorems/ModalS5.lean` for S5-specific theorems separate from core TM logic. Alternative: append to `Perpetuity.lean` with clear section headers.

**S4 Theorems** (Tasks 38-41): Recommend creating `Logos/Core/Theorems/ModalS4.lean` for S4-specific theorems (low priority, optional file creation).

### Prioritization Rationale

**High Priority (Tasks 21-24, 30-32)**: Simple theorems with short proofs (~2-5 hours each) that extend basic propositional and modal reasoning. These provide immediate value for proof automation and theorem library completeness.

**Medium Priority (Tasks 25-29, 33-37)**: Theorems requiring context manipulation or more sophisticated modal reasoning (~3-7 hours each). Useful for advanced reasoning patterns but not blocking immediate work.

**Low Priority (Tasks 38-41)**: Complex S4-specific theorems (~6-9 hours each) that may require S4 variant of Logos or substantial proof infrastructure. Deferred until core TM logic is more mature.

### Standards Compliance

All task entries follow the TODO.md format requirements identified in research report 003:
- Task description with clear objective
- Effort estimate (hours range)
- Status indicator (Not Started)
- Priority level (Medium/Low)
- Blocking/dependency information
- Lean signature for implementation clarity

Each theorem uses Lean 4 syntax compatible with Logos Formula type system as defined in `Logos/Core/Syntax/Formula.lean`:
- Implication: `A.imp B`
- Negation: `A.neg`
- Conjunction: `A.and B`
- Disjunction: `A.or B`
- Biconditional: `A.iff B`
- Box: `A.box`
- Diamond: `A.diamond`
- Derivability: `Γ ⊢ φ` or `Derivable Γ φ`

## Implementation Phases

### Phase 1: Verify TODO.md Current State [COMPLETE]
dependencies: []

**Objective**: Read TODO.md to verify Medium Priority section structure, identify insertion point for new tasks, and confirm no task numbering conflicts exist.

**Complexity**: Low

**Tasks**:
- [x] Read /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md using Read tool
- [x] Locate "## Medium Priority Tasks" section (approximately line 60)
- [x] Identify highest existing task number to avoid conflicts
- [x] Verify TODO.md uses Markdown format compatible with task additions
- [x] Note "Last Updated" date field location for Phase 4 update

**Testing**:
```bash
# Verify TODO.md is valid Markdown
grep -q "## Medium Priority Tasks" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md
echo $? # Should return 0 (section exists)

# Check for task numbering pattern
grep "^\*\*Task [0-9]" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md | tail -5
```

**Automation Metadata**:
- automation_type: automated
- validation_method: programmatic
- skip_allowed: false
- artifact_outputs: []

**Expected Duration**: 0.5 hours

---

### Phase 2: Add Propositional Logic Theorems (Tasks 21-29) [COMPLETE]
dependencies: [1]

**Objective**: Integrate 14 propositional logic theorems from research report 001 into TODO.md Medium Priority section using Edit tool, maintaining proper task numbering and format consistency.

**Complexity**: Medium

**Tasks**:
- [x] Prepare task entries for Tasks 21-24 (high priority: RAA, EFQ, LCE+RCE, LDI+RDI) using research report 001 specifications
- [x] Prepare task entries for Tasks 25-29 (medium priority: RCP, ECQ, NE+NI, DE, BI+LBE+RBE) using research report 001 specifications
- [x] Use Edit tool to insert Tasks 21-29 into TODO.md Medium Priority section after existing tasks
- [x] Verify all 9 task entries use consistent format (title, effort, status, priority, dependencies, description, Lean signature, files)
- [x] Verify Lean signatures use correct Logos Formula syntax from `Logos/Core/Syntax/Formula.lean`
- [x] Verify task descriptions accurately reflect theorem semantics from LogicNotes.tex
- [x] Verify file paths reference appropriate implementation files (Propositional.lean or Perpetuity.lean)

**Testing**:
```bash
# Verify Tasks 21-29 added successfully
for i in {21..29}; do
  grep -q "^\*\*Task $i:" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md || echo "ERROR: Task $i missing"
done

# Verify Lean signatures present
grep -c "```lean" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md
# Should increase by 9+ (one per task, some tasks have multiple theorems)

# Verify no syntax errors in Lean notation
grep -o "\.imp\|\.neg\|\.and\|\.or\|\.iff" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md | wc -l
# Should show significant usage of Formula operators
```

**Automation Metadata**:
- automation_type: automated
- validation_method: programmatic
- skip_allowed: false
- artifact_outputs: []

**Expected Duration**: 2-3 hours

---

### Phase 3: Add Modal Logic Theorems (Tasks 30-41) [COMPLETE]
dependencies: [2]

**Objective**: Integrate 11 modal logic theorems from research report 002 into TODO.md Medium Priority section using Edit tool, maintaining sequential task numbering after propositional theorems.

**Complexity**: Medium

**Tasks**:
- [x] Prepare task entries for Tasks 30-32 (high priority: t_box_to_diamond, box_conj_iff, diamond_disj_iff) using research report 002 specifications
- [x] Prepare task entries for Tasks 33-37 (medium priority: s5_diamond_box, box_disj_intro, box_contrapose, t_box_consistent, s5_diamond_box_to_truth) using research report 002 specifications
- [x] Prepare task entries for Tasks 38-41 (low priority: s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond, s5_diamond_conj_diamond) using research report 002 specifications
- [x] Use Edit tool to insert Tasks 30-41 into TODO.md Medium Priority section after Task 29
- [x] Verify all 12 task entries use consistent format matching Tasks 21-29 structure
- [x] Verify Lean signatures include modal operators (`.box`, `.diamond`) with correct syntax
- [x] Verify task descriptions distinguish S5 theorems from S4 theorems with appropriate priority markers
- [x] Verify file paths reference appropriate implementation files (ModalS5.lean or ModalS4.lean)

**Testing**:
```bash
# Verify Tasks 30-41 added successfully
for i in {30..41}; do
  grep -q "^\*\*Task $i:" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md || echo "ERROR: Task $i missing"
done

# Verify modal operators present in Lean signatures
grep -c "\.box\|\.diamond" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md
# Should increase significantly (modal theorems use these operators)

# Verify task numbering is sequential
grep "^\*\*Task [0-9]" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md | awk '{print $2}' | sed 's/://' | sort -n | uniq -d
# Should return empty (no duplicate task numbers)
```

**Automation Metadata**:
- automation_type: automated
- validation_method: programmatic
- skip_allowed: false
- artifact_outputs: []

**Expected Duration**: 2-3 hours

---

### Phase 4: Update TODO.md Metadata and Validate Format [COMPLETE]
dependencies: [3]

**Objective**: Update TODO.md "Last Updated" date, validate Markdown format integrity, and verify all 25 theorems are properly integrated with no formatting errors.

**Complexity**: Low

**Tasks**:
- [x] Use Edit tool to update "Last Updated" date field to 2025-12-09 in TODO.md header
- [x] Verify TODO.md is valid Markdown using Markdown linter or parser
- [x] Verify all task entries (21-41) follow consistent format structure
- [x] Verify no duplicate task numbers exist in TODO.md
- [x] Verify all Lean code blocks use correct syntax highlighting (```lean markers)
- [x] Verify all theorem names match LogicNotes.tex naming conventions (HS, RAA, EFQ, etc.)
- [x] Generate summary of added tasks: 14 propositional + 11 modal = 25 total theorems

**Testing**:
```bash
# Verify Last Updated date changed
grep -q "Last Updated.*2025-12-09" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md
echo $? # Should return 0

# Verify task count increased by 25
TASK_COUNT=$(grep -c "^\*\*Task [0-9]" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md)
echo "Total tasks: $TASK_COUNT" # Should show 41 or more

# Verify no Markdown syntax errors (basic check)
grep -c "^\*\*Task" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md
grep -c "^\*\*Effort" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md
# Counts should match (every task has an effort line)

# Verify Lean code blocks properly closed
OPEN_BLOCKS=$(grep -c "^```lean" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md)
CLOSE_BLOCKS=$(grep -c "^```$" /home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md)
test $OPEN_BLOCKS -eq $CLOSE_BLOCKS || echo "ERROR: Mismatched code blocks"
```

**Automation Metadata**:
- automation_type: automated
- validation_method: programmatic
- skip_allowed: false
- artifact_outputs: []

**Expected Duration**: 1-2 hours

---

## Testing Strategy

### Integration Testing

**Validation Approach**: Use grep and awk to verify task entries are properly formatted and numbered sequentially from 21-41. Check for required fields (task number, effort, status, priority, dependencies, description, Lean signature, files) in each entry.

**Format Validation**: Verify all Lean code blocks use `lean` syntax highlighting and contain valid Logos Formula syntax. Check that no backtick formatting errors exist (unclosed code blocks, missing language specifiers).

**Completeness Check**: Verify all 25 theorems identified in research reports are present in TODO.md. Cross-reference theorem names (RAA, EFQ, LCE, RCE, etc.) against research report lists to ensure no theorems are missed.

### Regression Testing

**TODO.md Structure Preservation**: Verify existing TODO.md sections (Overview, High Priority, Low Priority) remain unchanged after Medium Priority additions. Check that no existing task numbers are modified or removed.

**Markdown Validity**: Run Markdown parser or linter to verify TODO.md remains valid Markdown after additions. Check for common errors: mismatched headers, broken lists, unclosed code blocks.

### Quality Assurance

**Lean Syntax Correctness**: Verify all Lean signatures use correct Logos Formula operators (`.imp`, `.neg`, `.box`, `.diamond`, `.and`, `.or`, `.iff`). Cross-check syntax against `Logos/Core/Syntax/Formula.lean` definitions.

**Theorem Uniqueness**: Verify no duplicate theorems are added by cross-referencing task entries against existing theorems in `Logos/Core/Theorems/Perpetuity.lean` and `Logos/Core/ProofSystem/Axioms.lean`.

**Prioritization Accuracy**: Verify high-priority tasks (21-24, 30-32) are marked as such and appear before medium/low-priority tasks. Verify low-priority S4 theorems (38-41) are clearly marked for deferred implementation.

## Documentation Requirements

### TODO.md Updates

**Primary Documentation Target**: Update TODO.md Medium Priority Tasks section with 25 new theorem derivation tasks. This is the sole documentation artifact for this implementation plan.

**Format Requirements**:
- Maintain consistent task entry format throughout Medium Priority section
- Use standardized headers: "**Task N:**", "**Effort:**", "**Status:**", etc.
- Include Lean code blocks with proper syntax highlighting
- Update "Last Updated" metadata field after all additions

### Cross-Referencing

**Research Report Linkage**: This plan implements findings from three research reports. No bidirectional linking needed as research reports are input artifacts only.

**Implementation File References**: Each task entry includes "**Files:**" field referencing appropriate implementation file path (e.g., `Logos/Core/Theorems/Propositional.lean`). These file paths guide developers to correct implementation locations.

### No Additional Documentation

**Rationale**: This plan focuses solely on TODO.md integration. No changes to README.md, CLAUDE.md, or other documentation files are required. Theorem documentation will be added during implementation phase (separate from this planning task).

## Dependencies

### External Dependencies

**None**: This plan has no external dependencies. All required information is contained in the three research reports produced during the research phase.

### Internal Dependencies

**Research Reports** (already completed):
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/056_hilbert_proofs_lean_notation/reports/001-propositional-logic-hilbert-theorems.md` - Provides propositional theorem list, Lean signatures, and existing theorem identification
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/056_hilbert_proofs_lean_notation/reports/002-modal-logic-axiomatic-theorems.md` - Provides modal theorem list, Lean signatures, and existing theorem identification
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/056_hilbert_proofs_lean_notation/reports/003-todo-integration-documentation.md` - Provides task entry format template and prioritization strategy

**Source Material**:
- `/home/benjamin/Documents/Philosophy/Teaching/LogicNotes/LogicNotes.tex` - Original theorem source (already analyzed in research phase, not directly accessed during implementation)

**Target File**:
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md` - Documentation file to be updated with 25 new theorem tasks

### Blocking Relationships

**No Blockers**: This plan can be executed immediately. No prerequisite implementation work is required. All theorems to be added are future work items (not blocked by missing infrastructure).

**Phase Dependencies**: Phases are linearly dependent (each phase depends on previous phase completion). No parallel execution opportunities due to sequential Edit tool operations on single file.
