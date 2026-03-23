# Research Report: Task 29 Impact on Task 25 Plan

**Task**: 25 - rename_canonicalr_to_existstask
**Date**: 2026-03-22
**Session**: sess_1774243373_9f1bd6
**Focus**: Review task 29 changes to assess impact on v2 plan

## Executive Summary

Task 29's completion establishes the two-layer architecture as documented. The v2 plan at `plans/02_preorder-compatible-rename.md` is **still accurate** but Phase 1 scope needs expansion. The CanonicalIrreflexivity.lean file contains ~1300 lines of abandoned working notes that should be removed.

**Key Findings**:
1. Usage count is 1811, not ~800 as estimated (but plan complexity is similar)
2. CanonicalIrreflexivity.lean has extensive stale content (lines 200-1467)
3. Task 35 (SuccChain sorries) is fully independent - zero CanonicalR references
4. Plan Phase 1 needs to remove more content than anticipated

## Task 29 Completion Status

### What Was Delivered

| Item | Location | Status |
|------|----------|--------|
| `canonicalR_reflexive` | CanonicalIrreflexivity.lean:181 | Proven via T-axiom |
| `canonicalR_past_reflexive` | CanonicalIrreflexivity.lean:193 | Proven via T-axiom |
| CanonicalSerialFrameInstance.lean | (deleted) | Removed |
| Two-layer documentation | CanonicalIrreflexivity.lean:1468-1500 | Present |
| `canonicalR_irreflexive_axiom` | CanonicalIrreflexivity.lean:1502 | Preserved for Layer 2 |
| Deprecated wrapper | CanonicalIrreflexivity.lean:1505 | Added |

### Documentation Stale Areas

The file header (lines 11-52) still references "strict temporal semantics" and "Task 991 - Irreflexive Semantics Refactor" which is outdated. The historical context mentions Task 967 reflexive semantics but doesn't reflect Task 29's resolution.

## Usage Count Analysis

### Actual vs Estimated

| Metric | v2 Plan Estimate | Actual Count |
|--------|------------------|--------------|
| Total usages | ~800 | 1811 |
| Files affected | 49 | 63 |

### Breakdown by Directory

| Directory | Files | Usages |
|-----------|-------|--------|
| Bundle/ | 12 | ~300 |
| StagedConstruction/ | 18 | ~500 |
| Algebraic/ | 12 | ~200 |
| Canonical/ | 5 | ~50 |
| Domain/ | 3 | ~20 |
| Boneyard/ | 13 | ~700 |

**Note**: Boneyard files contain many usages but are non-critical (abandoned experiments). The plan's phased approach remains valid; only time estimates need adjustment.

### Plan Estimate Impact

The higher usage count affects Phase 2 timing:
- **v2 estimate**: 5 hours for rename
- **Revised estimate**: 6-7 hours (25-40% increase)

This is manageable since the rename is mechanical (search-replace with verification).

## Phase 1 Scope Expansion

### Current File Structure (1515 lines)

| Section | Lines | Content | Action |
|---------|-------|---------|--------|
| 1-65 | 65 | Imports, header, attributes | Keep but update header |
| 66-165 | 100 | Fresh atom infrastructure (atoms_of_set, fresh_for_set) | Keep (still useful) |
| 166-199 | 34 | Reflexivity theorems | **Keep (critical)** |
| 200-457 | 258 | Fresh G-atom approach (Task 25) | **Remove** (abandoned) |
| 458-507 | 50 | Per-construction strictness infrastructure | **Keep** |
| 508-1467 | 960 | Working notes, abandoned proofs, MCS analysis | **Remove** (stale) |
| 1468-1515 | 48 | Two-layer documentation + axiom | Keep |

### Target File Structure (~300 lines)

After Phase 1 cleanup:
1. Imports and header (~50 lines, updated for reflexive semantics)
2. Fresh atom infrastructure (~100 lines)
3. Reflexivity theorems (~40 lines)
4. Per-construction strictness infrastructure (~60 lines)
5. Two-layer documentation and axiom (~50 lines)

### Specific Removals

The following blocks should be removed:

1. **Lines 200-257**: "Fresh G-Atom Per-Witness Strictness" section - abandoned approach
2. **Lines 258-457**: `fresh_for_g_content_implies_not_always_neg` and `fresh_Gp_seed_consistent` - may be useful for future per-construction proofs but are currently unused
3. **Lines 508-1467**: Extensive working notes including:
   - `Gp_seed_consistent` (sorried, lines 600-900)
   - `Gneg_seed_consistent` (sorried, lines 900-1300)
   - Detailed MCS pathology analysis (lines 1000-1450)
   - Seed consistency condition analysis

**Decision point**: Lines 258-457 (`fresh_Gp_seed_consistent` etc.) ARE proven and MAY be useful for future per-construction strictness. The plan should either:
- A) Keep them (adds ~200 lines but preserves potentially useful infrastructure)
- B) Remove them (cleaner file, can be restored from git if needed)

**Recommendation**: Option B (remove). The proven theorems can be restored if needed. Keeping them suggests they're actively used when they're not.

## Task Independence Confirmation

### Task 35 (SuccChain Sorries)

Verified zero CanonicalR references in all SuccChain files:
- `SuccChainTaskFrame.lean`: 0 references
- `SuccChainFMCS.lean`: 0 references
- `SuccChainTruth.lean`: 0 references
- `SuccChainCompleteness.lean`: 0 references
- `SuccChainWorldHistory.lean`: 0 references

**Conclusion**: Task 35 can proceed in parallel with task 25 without any coordination.

### Why Independent

SuccChain files use:
- `Succ` relation (direct successor, not CanonicalR)
- `CanonicalTask` relation (n-step reachability)
- `p_content`/`g_content` sets

These are distinct from CanonicalR (existential accessibility).

## Plan Revision Recommendations

### Phase 1 Updates

**Original scope**: Reduce file to ~200 lines
**Revised scope**: Reduce file to ~300 lines (keeping fresh atom infrastructure)

**Revised tasks**:
- Task 1.1: Identify removable vs preserved declarations - **unchanged**
- Task 1.2: Delete unused infrastructure - **expand scope** (remove 1200+ lines, not 1300)
- Task 1.3: Update docstrings - **unchanged**

**Revised timing**: 2 hours (was 1.5 hours)

### Phase 2 Updates

**Original scope**: 49 files, ~800 usages
**Revised scope**: 63 files, 1811 usages

**Impact**: Mechanical work increases but approach unchanged. Add 1-2 hours buffer.

**Revised timing**: 6-7 hours (was 5 hours)

### Phase 3 Updates

No changes needed. Documentation and verification remain the same.

### Total Revised Estimate

| Phase | Original | Revised |
|-------|----------|---------|
| Phase 1 | 1.5h | 2h |
| Phase 2 | 5h | 6-7h |
| Phase 3 | 1.5h | 1.5h |
| **Total** | **6-8h** | **9.5-10.5h** |

## Blockers and Risks

### No New Blockers

Task 29's completion removes the previous blockers:
- Fresh G-atom proofs: No longer needed (reflexive semantics accepted)
- Universal strictness: Deferred to per-construction approach

### Existing Risks (Unchanged)

| Risk | Mitigation |
|------|------------|
| Breaking intermediate builds | Atomic commits per file group |
| Edge cases in rw tactics | Add `ExistsTask_def` simp lemma |
| Missing usages | Grep verification after each batch |

## Action Items

1. **Update plan document** with revised timing and Phase 1 scope
2. **Proceed with implementation** when ready - no blockers
3. **Do not coordinate with task 35** - fully independent

## References

### Files Analyzed
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (1515 lines)
- `/home/benjamin/Projects/ProofChecker/specs/025_rename_canonicalr_to_existstask/plans/02_preorder-compatible-rename.md`
- `/home/benjamin/Projects/ProofChecker/specs/035_prove_succ_chain_remaining_sorries/reports/01_team-research.md`

### Key Theorems (to preserve)
- `canonicalR_reflexive` (line 181) - Layer 1 core
- `canonicalR_past_reflexive` (line 193) - Layer 1 core
- `lt_of_canonicalR_and_not_reverse` (line 484) - per-construction helper
- `canonicalR_irreflexive_axiom` (line 1502) - Layer 2 axiom
