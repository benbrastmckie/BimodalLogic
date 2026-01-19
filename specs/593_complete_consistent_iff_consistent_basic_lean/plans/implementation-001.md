# Implementation Plan: Task #593

- **Task**: 593 - Complete consistent_iff_consistent' in Basic.lean
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: specs/593_complete_consistent_iff_consistent_basic_lean/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Eliminate duplicate consistency definitions by keeping only the "⊥ cannot be derived" definition. The current codebase has two definitions: `Consistent` (exists underivable formula) and `Consistent'` (does not derive ⊥), along with an incomplete equivalence proof. User guidance directs us to use the '⊥ cannot be derived' definition as the single source of truth and eliminate the other definition. This simplifies the codebase and removes confusion from having two equivalent definitions.

### Research Integration

Research report research-001.md confirms:
- Both definitions exist in Basic.lean (lines 38-47)
- The equivalence lemma has a sorry (line 56)
- Ex falso axiom (`⊥ → φ`) is available in the proof system
- The old Metalogic version has the identical sorry, confirming this is a longstanding gap

## Goals & Non-Goals

**Goals**:
- Eliminate `Consistent` definition (exists underivable formula)
- Rename `Consistent'` to `Consistent` (⊥ cannot be derived)
- Remove the equivalence lemma `consistent_iff_consistent'`
- Search for and update all references to these definitions across the codebase
- Verify all files compile after changes

**Non-Goals**:
- Proving soundness or completeness theorems
- Refactoring other metalogic definitions
- Updating documentation outside of code comments

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| References to old `Consistent` definition exist elsewhere | H | M | Comprehensive grep search before changes, update all found references |
| References to `consistent_iff_consistent'` lemma exist | M | L | Search for lemma name, replace with direct usage of new definition |
| Build failures in dependent modules | H | L | Run diagnostic messages after each change, fix errors incrementally |
| Old Metalogic version inconsistency | L | H | Update old version too if needed (separate task recommended) |

## Implementation Phases

### Phase 1: Search for All References [NOT STARTED]

**Goal**: Identify all files that reference the consistency definitions or equivalence lemma

**Tasks**:
- [ ] Search for `Consistent` definition references across codebase
- [ ] Search for `Consistent'` definition references
- [ ] Search for `consistent_iff_consistent'` lemma uses
- [ ] Document all findings with file paths and line numbers

**Timing**: 15 minutes

**Files to search**:
- All `.lean` files in `Theories/Bimodal/`

**Verification**:
- Complete list of files to update documented

---

### Phase 2: Update Basic.lean Definition [NOT STARTED]

**Goal**: Replace the two definitions with a single `Consistent` definition

**Tasks**:
- [ ] Remove `Consistent` definition (lines 38-39)
- [ ] Rename `Consistent'` to `Consistent` (update lines 46-47)
- [ ] Update docstring for new `Consistent` to be primary definition
- [ ] Remove `consistent_iff_consistent'` lemma and its docstring (lines 49-56)
- [ ] Run `lean_diagnostic_messages` on Basic.lean

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Core/Basic.lean` - Remove old Consistent (line 38-39), rename Consistent' to Consistent (line 46-47), remove equivalence lemma (lines 49-56)

**Verification**:
- Basic.lean has single `Consistent` definition
- Definition is "⊥ cannot be derived" formulation
- No compilation errors in Basic.lean

---

### Phase 3: Update References in Other Files [NOT STARTED]

**Goal**: Update all references found in Phase 1 to use new definition

**Tasks**:
- [ ] For each file with references, update to use `Consistent` (new name)
- [ ] Remove any uses of `consistent_iff_consistent'` lemma
- [ ] Run `lean_diagnostic_messages` on each modified file

**Timing**: 30 minutes

**Files to modify**:
- Files identified in Phase 1 search

**Verification**:
- All references use new `Consistent` definition
- No references to old names remain
- No compilation errors in modified files

---

### Phase 4: Full Build Verification [NOT STARTED]

**Goal**: Ensure entire project builds successfully

**Tasks**:
- [ ] Run `lake build Theories.Bimodal.Metalogic_v2.Core.Basic`
- [ ] Run `lake build` for full project
- [ ] Fix any remaining compilation errors
- [ ] Run `lean_diagnostic_messages` on all modified files

**Timing**: 20 minutes

**Files to modify**:
- Any files with build errors discovered

**Verification**:
- `lake build` succeeds with no errors
- All diagnostics show clean output

---

### Phase 5: Documentation and Summary [NOT STARTED]

**Goal**: Document changes and create implementation summary

**Tasks**:
- [ ] Create implementation summary with list of modified files
- [ ] Note the simplification achieved
- [ ] Document the final `Consistent` definition

**Timing**: 15 minutes

**Files to modify**:
- `specs/593_complete_consistent_iff_consistent_basic_lean/summaries/implementation-summary-YYYYMMDD.md` - Implementation summary

**Verification**:
- Summary file created
- All changes documented

## Testing & Validation

- [ ] Basic.lean compiles without errors
- [ ] All files with updated references compile
- [ ] Full project builds with `lake build`
- [ ] No remaining references to old definition names
- [ ] Grep confirms no `Consistent'` or `consistent_iff_consistent'` references

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- Modified: Theories/Bimodal/Metalogic_v2/Core/Basic.lean
- Modified: Any files with references (discovered in Phase 1)
- summaries/implementation-summary-YYYYMMDD.md

## Rollback/Contingency

If changes cause build failures that cannot be quickly resolved:
1. Use `git diff` to see all changes
2. Revert changes with `git checkout -- <files>`
3. Investigate failures more carefully
4. Create targeted fix plan
5. Re-attempt implementation

Alternatively, if only specific files fail:
1. Keep Basic.lean changes
2. Temporarily add back old definition as deprecated alias
3. Fix dependent files incrementally
4. Remove deprecated alias once all references updated
