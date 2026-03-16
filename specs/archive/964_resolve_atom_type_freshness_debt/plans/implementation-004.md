# Implementation Plan: Task #964 - Resolve Atom Type Freshness Debt

- **Task**: 964 - resolve_atom_type_freshness_debt
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**:
  - specs/964_resolve_atom_type_freshness_debt/reports/research-005.md
  - specs/964_resolve_atom_type_freshness_debt/reports/research-006.md
  - specs/964_resolve_atom_type_freshness_debt/reports/research-007.md
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan clarifies the archival scope and resolves the `canonicalR_irreflexive` technical debt. User focus "archive canonicalR_irreflexive" requires disambiguation between two files:

| File | Type | Status | Can Archive? |
|------|------|--------|--------------|
| `Canonical/CanonicalIrreflexivityAxiom.lean` | Axiom declaration | **USED** by 6 call sites | NO - breaks build |
| `Bundle/CanonicalIrreflexivity.lean` | Failed proof attempt | NOT IMPORTED anywhere | YES - safe to archive |

**Confirmed via code analysis:**
- `canonicalR_strict` (defined in CanonicalIrreflexivityAxiom.lean) is used by:
  - `CantorApplication.lean`: lines 152, 176, 218, 220
  - `DiscreteTimeline.lean`: lines 254, 276
- `Bundle/CanonicalIrreflexivity.lean` has zero imports in the codebase

**Plan approach:** Archive the unused failed proof attempt, update documentation in the axiom file to reflect research-007 findings (reflexive refactor NOT recommended), and verify build integrity.

### Research Integration

From research-007.md:
- Reflexive G/H refactor: **NOT RECOMMENDED** (40-100 hours, 20% failure risk)
- Current irreflexive architecture: **COMPLETE and SOUND**
- The `canonicalR_irreflexive` axiom documents a genuine frame property
- Irreflexivity is ALSO obtained via strict `<` on the CanonicalMCS preorder (definitionally irreflexive)
- Prior 3-month effort validates difficulty of alternative approaches

## Goals & Non-Goals

**Goals**:
- Archive the failed proof attempt (`Bundle/CanonicalIrreflexivity.lean`) - 65KB, 2 sorries
- Update axiom file docstring to reference research-007 recommendation
- Remove reference to failed proof from axiom file (line 71)
- Verify build passes after cleanup

**Non-Goals**:
- Archive `CanonicalIrreflexivityAxiom.lean` (it IS being used - would break build)
- Attempt to prove the axiom (research confirms unprovable with String atoms)
- Refactor to reflexive semantics (research-007 recommends against)
- Change the axiom declaration itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Hidden dependency on Bundle file | H | Very Low | grep confirmed zero imports |
| Build failure after archive | M | Very Low | Run lake build verification |
| Documentation becomes stale | L | Low | Reference research reports directly |

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `Canonical/CanonicalIrreflexivityAxiom.lean`: `canonicalR_irreflexive`

### Expected Resolution
- No change to axiom count. The axiom is mathematically sound but unprovable with String atoms.
- Research-007 confirms: current architecture is complete, reflexive refactor NOT recommended.

### New Axioms
- None.

### Remaining Debt
After this implementation:
- 1 axiom remains (`canonicalR_irreflexive`)
- Axiom is documented as architectural necessity (frame property assumption)
- Resolution path documented: change atom type from `String` to type with freshness property
- Reflexive refactor path explicitly closed (per research-007)

## Implementation Phases

### Phase 1: Verify No Imports [NOT STARTED]

- **Dependencies**: None
- **Goal**: Confirm `Bundle/CanonicalIrreflexivity.lean` has no imports (belt-and-suspenders check)

**Tasks**:
- [ ] Run `grep -r "Bundle\.CanonicalIrreflexivity" Theories/`
- [ ] Run `grep -r "Bundle/CanonicalIrreflexivity" Theories/`
- [ ] Confirm zero imports found
- [ ] If imports exist, mark phase [BLOCKED] - plan revision required

**Timing**: 5 minutes

**Verification**:
- grep returns no matches
- If matches found, STOP and revise plan

---

### Phase 2: Archive Failed Proof Attempt [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Move `Bundle/CanonicalIrreflexivity.lean` to Boneyard with documentation

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/`
- [ ] Move `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` to Boneyard directory
- [ ] Create `README.md` in Boneyard directory explaining:
  - Why file was archived (unprovable with String atoms)
  - Reference to research-007 (reflexive refactor NOT recommended)
  - Reference to research-002 (original obstacle analysis)
  - Note that irreflexivity is also obtained via strict `<` on preorder

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` -> move to Boneyard
- `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/README.md` -> create

**Verification**:
- File moved successfully
- README.md created
- No remaining copy in Bundle/

---

### Phase 3: Update Axiom Documentation [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Update axiom file docstring to reflect research-007 findings and remove stale reference

**Tasks**:
- [ ] Update `CanonicalIrreflexivityAxiom.lean` docstring:
  - Remove line 71 reference to `Bundle/CanonicalIrreflexivity.lean` (now archived)
  - Add reference to research-007 confirming reflexive refactor NOT recommended
  - Update "Resolution Path" section to note that alternative approaches have been analyzed and rejected
- [ ] Ensure no dangling references to the archived file

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - update module docstring

**Verification**:
- No reference to `Bundle/CanonicalIrreflexivity.lean` remains in axiom file
- Docstring reflects current research status

---

### Phase 4: Build Verification [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Verify project builds successfully after cleanup

**Tasks**:
- [ ] Run `lake build`
- [ ] Verify no new errors
- [ ] Verify `canonicalR_strict` still resolves in downstream files
- [ ] Verify no import failures

**Timing**: 10 minutes

**Verification**:
- `lake build` passes with no errors
- `grep -rn "\bsorry\b"` on modified files returns empty (no new sorries)
- No new axioms introduced

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` shows exactly 1 axiom (unchanged)
- [ ] No new axioms introduced

### General
- [ ] Boneyard README accurately describes archival rationale
- [ ] `grep -r "CanonicalIrreflexivity" Theories/` shows only:
  - Archived file in Boneyard
  - References to `CanonicalIrreflexivityAxiom.lean` (the axiom file)

## Artifacts & Outputs

- `specs/964_resolve_atom_type_freshness_debt/plans/implementation-004.md` (this plan)
- `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/README.md` (archival documentation)
- `Theories/Bimodal/Boneyard/Task964_IrreflexivityAttempt/CanonicalIrreflexivity.lean` (archived file)
- `specs/964_resolve_atom_type_freshness_debt/summaries/implementation-summary-20260314.md` (on completion)

## Rollback/Contingency

If changes break the build:
1. `git restore` the moved file from Boneyard back to original location
2. Investigate which files depend on it (should be none per Phase 1)
3. Revise plan to handle dependencies first

If unexpected dependencies found in Phase 1:
- Mark phase [BLOCKED]
- Document dependencies
- Plan revision required before proceeding
