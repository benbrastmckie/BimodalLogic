# Implementation Plan: Task 933 - Archive Boneyard Candidates

- **Task**: 933 - research_alternative_canonical_construction
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Dependencies**: None
- **Research Inputs**: specs/933_research_alternative_canonical_construction/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Archive the CanonicalReachable/CanonicalQuotient/CanonicalEmbedding construction stack to Boneyard and remove dead code from BFMCSTruth.lean. This cleanup task focuses on removing approaches that have been superseded by the all-MCS approach (canonicalMCSBFMCS) while ensuring nothing vital is removed. The research report (research-001.md) identifies these files as "intermediate approaches that are no longer on the critical path."

### Research Integration

- **research-001.md**: Identifies CanonicalReachable/CanonicalQuotient/CanonicalEmbedding as Boneyard candidates (Section 2.2.3-2.2.4)
- **research-001.md**: Identifies dead `eval_bmcs_*` code in BFMCSTruth.lean (Section 2.2.1)
- **research-001.md**: Recommends keeping DovetailingChain.lean and canonicalMCSBFMCS (Section 2.2.5, 4.1)

## Goals & Non-Goals

**Goals**:
- Archive CanonicalReachable.lean, CanonicalQuotient.lean, CanonicalEmbedding.lean to Boneyard
- Archive legacy section of CanonicalFMCS.lean (lines 297-398) to Boneyard
- Remove dead `bmcs_truth_eval` and `bmcs_truth_eval_of_all` from BFMCSTruth.lean
- Add appropriate Boneyard warnings explaining why each file was archived
- Ensure `lake build` passes after changes

**Non-Goals**:
- Do NOT move DovetailingChain.lean (still actively used despite sorries)
- Do NOT move CanonicalFrame.lean (contains active definitions used by canonicalMCSBFMCS)
- Do NOT move any sorry-free definitions from canonicalMCSBFMCS section (lines 1-296)
- Do NOT attempt to resolve existing sorries (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports in downstream files | High | Medium | Run `lake build` after each phase; grep for import statements |
| Removing code that appears dead but is used | High | Low | Verify with grep before removal; check lakefile imports |
| Accidentally removing the active canonicalMCS* definitions | High | Low | Clear phase boundaries; only touch legacy section (lines 297+) |

## Sorry Characterization

### Pre-existing Sorries
No sorries in scope for this cleanup task. The files being archived have no sorries.

### Expected Resolution
N/A - this is a cleanup task, not a proof task.

### New Sorries
None. This task only moves/removes code; no new sorries will be introduced.

### Remaining Debt
After this implementation, the existing 3 sorries in DovetailingChain.lean and TemporalCoherentConstruction.lean remain unchanged (out of scope).

## Implementation Phases

### Phase 1: Archive CanonicalReachable.lean [NOT STARTED]

- **Dependencies:** None
- **Goal:** Move CanonicalReachable.lean to Boneyard with appropriate warning header

**Tasks:**
- [ ] Create directory `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/`
- [ ] Copy `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean` to Boneyard location
- [ ] Add Boneyard warning header explaining why archived (CanonicalReachable backward_P is blocked)
- [ ] Update import statement in Boneyard copy to point to correct paths
- [ ] Remove original file
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify:**
- Create: `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/CanonicalReachable.lean`
- Remove: `Theories/Bimodal/Metalogic/Bundle/CanonicalReachable.lean`

**Verification:**
- `lake build` passes
- `grep -rn "CanonicalReachable" Theories/Bimodal/Metalogic/` returns no active references

---

### Phase 2: Archive CanonicalQuotient.lean [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move CanonicalQuotient.lean to Boneyard with appropriate warning header

**Tasks:**
- [ ] Copy `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean` to Boneyard location
- [ ] Add Boneyard warning header explaining why archived (superseded by all-MCS approach)
- [ ] Update import to reference Boneyard CanonicalReachable.lean
- [ ] Remove original file
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify:**
- Create: `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/CanonicalQuotient.lean`
- Remove: `Theories/Bimodal/Metalogic/Bundle/CanonicalQuotient.lean`

**Verification:**
- `lake build` passes
- `grep -rn "CanonicalQuotient" Theories/Bimodal/Metalogic/` returns only references in CanonicalFMCS.lean legacy section

---

### Phase 3: Archive CanonicalEmbedding.lean [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move CanonicalEmbedding.lean to Boneyard with appropriate warning header

**Tasks:**
- [ ] Copy `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean` to Boneyard location
- [ ] Add Boneyard warning header explaining why archived (infrastructure for superseded approach)
- [ ] Update imports in Boneyard copy
- [ ] Remove original file
- [ ] Run `lake build` to verify no breakage

**Timing:** 30 minutes

**Files to modify:**
- Create: `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/CanonicalEmbedding.lean`
- Remove: `Theories/Bimodal/Metalogic/Bundle/CanonicalEmbedding.lean`

**Verification:**
- `lake build` passes
- `grep -rn "CanonicalEmbedding" Theories/Bimodal/Metalogic/` returns no active references

---

### Phase 4: Archive Legacy Section of CanonicalFMCS.lean [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Extract and archive legacy definitions (lines 297-398) from CanonicalFMCS.lean

**Tasks:**
- [ ] Extract legacy section (lines 289-399) to separate Boneyard file
- [ ] Add Boneyard warning header to extracted file
- [ ] Remove legacy section from CanonicalFMCS.lean (keep lines 1-288)
- [ ] Remove imports of CanonicalQuotient from CanonicalFMCS.lean
- [ ] Run `lake build` to verify active code still works

**Timing:** 45 minutes

**Files to modify:**
- Create: `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/LegacyCanonicalFMCS.lean`
- Modify: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` (remove lines 289-399, update imports)

**Verification:**
- `lake build` passes
- CanonicalFMCS.lean only contains canonicalMCS* definitions
- `grep -rn "canonicalReachableBFMCS" Theories/Bimodal/Metalogic/` returns empty
- `grep -rn "canonicalBFMCS_mcs" Theories/Bimodal/Metalogic/` returns empty

---

### Phase 5: Remove Dead Code from BFMCSTruth.lean [NOT STARTED]

- **Dependencies:** None (can run in parallel with Phases 1-4)
- **Goal:** Remove unused `bmcs_truth_eval` and `bmcs_truth_eval_of_all` definitions

**Tasks:**
- [ ] Verify definitions have no external references via grep
- [ ] Remove `bmcs_truth_eval` (line 219) and its docstring
- [ ] Remove `bmcs_truth_eval_of_all` (lines 225-228) and its docstring
- [ ] Remove the now-empty `Monotonicity Properties` section header if appropriate
- [ ] Run `lake build` to verify no breakage

**Timing:** 15 minutes

**Files to modify:**
- Modify: `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` (remove lines 210-228)

**Verification:**
- `lake build` passes
- `grep -rn "bmcs_truth_eval" Theories/` returns empty

---

### Phase 6: Final Verification [NOT STARTED]

- **Dependencies:** Phase 4, Phase 5
- **Goal:** Verify all changes are correct and complete

**Tasks:**
- [ ] Run full `lake build` to verify project compiles
- [ ] Verify all Boneyard files have appropriate warning headers
- [ ] Verify no orphan imports referencing removed files
- [ ] Grep for any remaining references to archived definitions in active code
- [ ] Update lakefile.lean if necessary (remove archived files from build list if explicitly listed)

**Timing:** 15 minutes

**Verification:**
- `lake build` passes with no warnings about archived files
- `grep -rn "CanonicalReachable\|CanonicalQuotient\|CanonicalEmbedding\|canonicalReachableBFMCS\|canonicalBFMCS_mcs\|bmcs_truth_eval" Theories/Bimodal/Metalogic/` returns empty
- All Boneyard files contain "BONEYARD" and "ARCHIVED" in their headers

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` shows no NEW sorries
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] No new compilation warnings in modified files

### Cleanup Verification
- [ ] All 3 files (CanonicalReachable, CanonicalQuotient, CanonicalEmbedding) moved to Boneyard
- [ ] Legacy section of CanonicalFMCS.lean extracted to Boneyard
- [ ] Dead code removed from BFMCSTruth.lean
- [ ] No broken imports in any active file

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/CanonicalReachable.lean`
- `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/CanonicalQuotient.lean`
- `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/CanonicalEmbedding.lean`
- `Theories/Bimodal/Boneyard/Bundle/CanonicalQuotientApproach/LegacyCanonicalFMCS.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`
- `specs/933_research_alternative_canonical_construction/summaries/implementation-summary-20260226.md`

## Rollback/Contingency

All changes involve file moves/removals with no logic changes. Rollback strategy:

1. **If Phase N fails**: Restore removed file from git (`git checkout HEAD -- <file>`)
2. **If build breaks**: Use `git diff` to identify problematic change, revert that specific change
3. **If imports break**: Check for import cycles or missing dependencies; update import paths as needed

Full rollback: `git checkout HEAD -- Theories/Bimodal/Metalogic/Bundle/`
