# Implementation Plan: Task #964 - Resolve Atom Type Freshness Debt

- **Task**: 964 - resolve_atom_type_freshness_debt
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/964_resolve_atom_type_freshness_debt/reports/research-005.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan addresses the canonicalR_irreflexive axiom technical debt identified in research-005.md. The research concluded that pursuing reflexive G/H semantics refactoring is NOT recommended due to 5+ major blockers with HIGH risk.

**CRITICAL FINDING**: Code analysis reveals a discrepancy between the task description and actual code dependencies. The task description states the axiom is "UNUSED", but code analysis shows:

- `CantorApplication.lean` (lines 152, 176, 218, 220) uses `canonicalR_strict`
- `DiscreteTimeline.lean` (lines 254, 276) uses `canonicalR_strict`

The `canonicalR_strict` theorem depends on `canonicalR_irreflexive` axiom. **Archiving the axiom file would BREAK the build.**

**Revised Approach**: This plan does NOT archive CanonicalIrreflexivityAxiom.lean. Instead, it:
1. Archives ONLY the failed proof attempt (CanonicalIrreflexivity.lean in Bundle/)
2. Updates documentation to clarify the axiom's status and usage
3. Verifies build passes after cleanup

### Research Integration

From research-005.md:
- Reflexive refactor: NOT RECOMMENDED (87-167h, HIGH risk)
- Current approach: Sound and complete
- The axiom (CanonicalIrreflexivityAxiom.lean) expresses a mathematically true property that cannot be proven with String atoms

## Goals & Non-Goals

**Goals**:
- Archive the failed proof attempt (Bundle/CanonicalIrreflexivity.lean - 66KB, 2 sorries)
- Update documentation to clarify axiom status
- Remove dead imports of CanonicalIrreflexivity.lean (the failed proof)
- Verify build passes

**Non-Goals**:
- Archive CanonicalIrreflexivityAxiom.lean (it IS being used)
- Attempt to prove the axiom (research confirms it's unprovable with String atoms)
- Refactor to reflexive semantics (research recommends against)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports | H | L | Verify no imports of CanonicalIrreflexivity.lean before archiving |
| Incorrect documentation | M | L | Cross-reference with actual code usage |
| Build failure | H | L | Run lake build before committing |

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `Canonical/CanonicalIrreflexivityAxiom.lean`: `canonicalR_irreflexive`

### Expected Resolution
- No change to axiom count. The axiom is mathematically sound but unprovable with String atoms.
- Research confirms irreflexivity is also obtained via strict `<` on the preorder, so the axiom is not the ONLY source of irreflexivity.

### New Axioms
- None.

### Remaining Debt
After this implementation:
- 1 axiom remains (canonicalR_irreflexive)
- The axiom is documented as architectural necessity pending atom type refactor

## Implementation Phases

### Phase 1: Verify Dependencies [NOT STARTED]

- **Dependencies**: None
- **Goal**: Confirm CanonicalIrreflexivity.lean (the failed proof) has no imports

**Tasks**:
- [ ] Grep for imports of `Bimodal.Metalogic.Bundle.CanonicalIrreflexivity`
- [ ] Verify CanonicalIrreflexivity.lean is not imported anywhere
- [ ] Document any unexpected dependencies

**Timing**: 10 minutes

**Verification**:
- grep shows no imports of the failed proof file
- If imports exist, plan requires revision

---

### Phase 2: Archive Failed Proof Attempt [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Move CanonicalIrreflexivity.lean to Boneyard

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/` directory
- [ ] Move `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` to Boneyard
- [ ] Create README.md in Boneyard subdirectory explaining the archival

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` -> move to Boneyard
- `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/README.md` -> create

**Verification**:
- File moved successfully
- README.md created

---

### Phase 3: Update Documentation [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Update docstrings to clarify axiom status and irreflexivity sources

**Tasks**:
- [ ] Update CanonicalIrreflexivityAxiom.lean docstring to note failed proof was archived
- [ ] Update references in other files that mention CanonicalIrreflexivity.lean
- [ ] Clarify in documentation that irreflexivity comes from BOTH:
  1. The axiom `canonicalR_irreflexive` (explicitly assumed)
  2. The strict `<` on the preorder (definitionally irreflexive)

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - update references
- Files referencing CanonicalIrreflexivity.lean in comments

**Verification**:
- No dangling references to CanonicalIrreflexivity.lean

---

### Phase 4: Build Verification [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Verify project builds successfully after cleanup

**Tasks**:
- [ ] Run `lake build`
- [ ] Verify no new errors
- [ ] Verify no new warnings related to the archived file

**Timing**: 15 minutes

**Verification**:
- `lake build` passes
- No imports fail
- `grep -n "\bsorry\b"` on modified files returns empty (no new sorries)

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "CanonicalIrreflexivity" Theories/` shows only:
  - Archived file in Boneyard
  - References to CanonicalIrreflexivityAxiom.lean (not the failed proof)
- [ ] No new axioms introduced
- [ ] No new sorries introduced

### General
- [ ] Boneyard README accurately describes why the file was archived

## Artifacts & Outputs

- `specs/964_resolve_atom_type_freshness_debt/plans/implementation-003.md` (this plan)
- `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/README.md` (archival documentation)
- `specs/964_resolve_atom_type_freshness_debt/summaries/implementation-summary-20260314.md` (on completion)

## Rollback/Contingency

If changes break the build:
1. `git restore` the moved file from Boneyard back to original location
2. Investigate which files depend on it
3. Revise plan to handle dependencies first

If unexpected dependencies found:
- Mark task [BLOCKED]
- Document dependencies
- Create follow-up task to address dependencies before archival
