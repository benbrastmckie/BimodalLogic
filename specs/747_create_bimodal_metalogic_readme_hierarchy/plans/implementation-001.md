# Implementation Plan: Task #747

- **Task**: 747 - Create Bimodal/Metalogic README hierarchy
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/747_create_bimodal_metalogic_readme_hierarchy/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Create README.md files for each subdirectory of Theories/Bimodal/Metalogic/ that lacks documentation. The research report identified 3 missing READMEs (Completeness, Algebraic, Compactness) plus 1 optional (Core). Each README follows the established format: Overview, Modules table, Key Definitions, Design Notes, Known Limitations.

### Research Integration

- Research report (research-001.md) provides complete directory structure, module details, and recommended README format
- Existing READMEs (Metalogic/README.md, Representation/README.md, FMP/README.md) serve as format templates
- Priority order: Completeness (HIGH) > Algebraic (MEDIUM) > Compactness (LOW) > Core (OPTIONAL)

## Goals & Non-Goals

**Goals**:
- Create Completeness/README.md documenting the completeness hierarchy
- Create Algebraic/README.md documenting the alternative algebraic approach
- Create Compactness/README.md documenting the compactness theorem
- Create Core/README.md documenting MCS foundations (optional but recommended)
- Follow consistent format matching existing Representation/README.md and FMP/README.md

**Non-Goals**:
- Modify existing READMEs (Metalogic/, Representation/, FMP/)
- Add documentation to individual .lean files (docstrings)
- Create top-level Theories/ or Bimodal/ READMEs (out of scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Documentation drift | READMEs become outdated | Medium | Include "Last updated" reference, focus on stable architecture |
| Inconsistent format | Harder to navigate | Low | Use FMP/README.md as template |
| Over-documentation | Duplication with docstrings | Low | Focus on architecture and relationships, not implementation details |

## Implementation Phases

### Phase 1: Create Completeness/README.md [NOT STARTED]

**Goal**: Document the completeness hierarchy (weak -> finite strong -> infinitary)

**Tasks**:
- [ ] Read Completeness/ source files to verify module details
- [ ] Create Completeness/README.md with Overview, Modules table, Key Definitions, Design Notes
- [ ] Include proof architecture showing the hierarchy: WeakCompleteness -> FiniteStrong -> Infinitary
- [ ] Document dependencies on Representation theorem and soundness

**Timing**: 30 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/README.md`

**Verification**:
- README exists and is non-empty
- Contains Overview, Modules, Key Definitions sections
- References correct file names matching directory contents

---

### Phase 2: Create Algebraic/README.md [NOT STARTED]

**Goal**: Document the alternative algebraic approach to the representation theorem

**Tasks**:
- [ ] Read Algebraic/ source files to verify module details
- [ ] Create Algebraic/README.md with Overview, Modules table, Key Definitions, Design Notes
- [ ] Document the algebraic proof path: Lindenbaum quotient -> Boolean algebra -> interior operators -> ultrafilter-MCS correspondence
- [ ] Note that this is an isolated, alternative approach

**Timing**: 30 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/README.md`

**Verification**:
- README exists and is non-empty
- Contains Overview, Modules, Key Definitions sections
- Clearly notes this is an alternative approach (isolated from main metalogic)

---

### Phase 3: Create Compactness/README.md [NOT STARTED]

**Goal**: Document the compactness theorem for TM bimodal logic

**Tasks**:
- [ ] Read Compactness/Compactness.lean to verify theorem details
- [ ] Create Compactness/README.md with Overview, Key Theorems, Proof Strategy, Dependencies
- [ ] Document the proof strategy via contraposition using infinitary strong completeness

**Timing**: 20 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Compactness/README.md`

**Verification**:
- README exists and is non-empty
- Documents main theorem: `set_satisfiable Gamma iff forall finite Delta subseteq Gamma, set_satisfiable Delta`
- References InfinitaryStrongCompleteness dependency

---

### Phase 4: Create Core/README.md [NOT STARTED]

**Goal**: Document MCS foundations (optional but recommended for completeness)

**Tasks**:
- [ ] Read Core/ source files to verify module details
- [ ] Create Core/README.md with Overview, Modules table, Key Definitions, Design Notes
- [ ] Document deduction theorem's well-founded recursion on derivation height
- [ ] Reference parent Metalogic/README.md for overall architecture context

**Timing**: 25 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Core/README.md`

**Verification**:
- README exists and is non-empty
- Documents MCS properties and deduction theorem
- Links to parent README for broader context

---

### Phase 5: Final Verification [NOT STARTED]

**Goal**: Verify all READMEs are consistent and properly linked

**Tasks**:
- [ ] Review all 4 new READMEs for consistent formatting
- [ ] Verify cross-references between READMEs are accurate
- [ ] Confirm module names match actual file names in directories
- [ ] Check that parent Metalogic/README.md is not modified

**Timing**: 15 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/Completeness/README.md`
- `Theories/Bimodal/Metalogic/Algebraic/README.md`
- `Theories/Bimodal/Metalogic/Compactness/README.md`
- `Theories/Bimodal/Metalogic/Core/README.md`

**Verification**:
- All 4 READMEs exist and follow consistent format
- No broken cross-references
- No modifications to existing READMEs

## Testing & Validation

- [ ] All 4 README files exist in their respective directories
- [ ] Each README contains required sections (Overview, Modules, Key Definitions)
- [ ] Module tables reference actual .lean files in each directory
- [ ] Cross-references to other Metalogic READMEs are accurate
- [ ] Format is consistent with existing FMP/README.md and Representation/README.md

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/README.md` - Completeness hierarchy documentation
- `Theories/Bimodal/Metalogic/Algebraic/README.md` - Algebraic approach documentation
- `Theories/Bimodal/Metalogic/Compactness/README.md` - Compactness theorem documentation
- `Theories/Bimodal/Metalogic/Core/README.md` - MCS foundations documentation
- `specs/747_create_bimodal_metalogic_readme_hierarchy/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

## Rollback/Contingency

If changes must be reverted:
1. Delete the 4 new README.md files (no existing files are modified)
2. Run `git checkout -- Theories/Bimodal/Metalogic/*/README.md` to restore any accidental modifications
3. No other files are affected
