# Implementation Plan: Task #80 - UltrafilterChain Dead Code Cleanup

- **Task**: 80 - ultrafilter_dead_code_audit
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**:
  - reports/01_dead-code-audit.md (initial audit: 24 sorries, 8 dead regions)
  - reports/02_medium-confidence-analysis.md (confirmation: all medium items ARCHIVE)
- **Artifacts**: plans/01_dead-code-cleanup.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

UltrafilterChain.lean (8,376 lines) contains ~2,925 lines of dead code across 8 regions from 4 abandoned approaches. This cleanup removes 23 of 24 sorries (96%) and reduces file size by 35%. Code is archived to Boneyard/ for historical reference before removal.

### Research Integration

- **01_dead-code-audit.md**: Identified 24 sorries, 8 dead regions, 4 abandoned approaches
- **02_medium-confidence-analysis.md**: Confirmed all medium-confidence items (Z_chain, omega F-persistence, P-preserving seed) as ARCHIVE candidates with no external dependencies

## Goals & Non-Goals

**Goals**:
- Archive dead code to `Theories/Bimodal/Boneyard/UltrafilterDeadCode/` for reference
- Remove dead code from UltrafilterChain.lean
- Reduce sorry count from 24 to 1
- Verify build passes after each phase
- Update ROADMAP.md to document cleanup

**Non-Goals**:
- Do not remove bundle-level coherence (still used by Completeness.lean with isolated sorry)
- Do not remove active completeness path infrastructure (BFMCS_Bundle, construct_bfmcs_bundle)
- Do not modify SuccChainFMCS.lean (separate module, active path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Break compilation | High | Low | `lake build` after each phase; revert on failure |
| Remove active code | High | Low | Research verified no external deps; grep before each removal |
| Incomplete archival | Low | Low | Archive before remove; preserve full context |

## Implementation Phases

### Phase 1: Create Archive Structure [NOT STARTED]

**Goal**: Set up Boneyard directory structure for archived dead code

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/UltrafilterDeadCode/` directory
- [ ] Create README.md documenting what was archived and why
- [ ] Create stub .lean files for each major archived region

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/README.md` - Create
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/FPreservingSeed.lean` - Stub
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/BidirectionalSeed.lean` - Stub
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/ZChain.lean` - Stub
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/CoherentZChain.lean` - Stub

**Verification**:
- Directory structure created successfully

---

### Phase 2: Archive and Remove F-Preserving Seed [NOT STARTED]

**Goal**: Remove the F-preserving seed construction (FALSE per Task #69)

**Tasks**:
- [ ] Copy lines 2509-3473 to `FPreservingSeed.lean` (with context comments)
- [ ] Verify no external references: `grep -r "f_preserving_seed\|F_unresolved_theory" Theories/`
- [ ] Delete lines 2509-3473 from UltrafilterChain.lean
- [ ] Run `lake build`

**Timing**: 25 minutes

**Line ranges**:
- Delete: 2509-3473 (~965 lines)
- Sorries eliminated: 3377, 3383 (2 sorries)

**Files to modify**:
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/FPreservingSeed.lean` - Archive code
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes
- `grep -c "sorry" UltrafilterChain.lean` shows 2 fewer sorries

---

### Phase 3: Archive and Remove Bidirectional Seed [NOT STARTED]

**Goal**: Remove bidirectional_temporal_box_seed (H(a)->G(H(a)) NOT derivable)

**Tasks**:
- [ ] Copy lines 3700-4309 to `BidirectionalSeed.lean` (adjusted line numbers after Phase 2)
- [ ] Verify no external references: `grep -r "bidirectional_temporal_box_seed\|bidirectional_seed" Theories/`
- [ ] Delete the bidirectional seed region
- [ ] Run `lake build`

**Timing**: 20 minutes

**Line ranges** (original):
- Delete: ~3700-4309 (~610 lines)
- Sorries eliminated: 3887, 4301 (2 sorries)

**Note**: Line numbers will shift after Phase 2. Use grep to find actual locations.

**Files to modify**:
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/BidirectionalSeed.lean` - Archive code
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes
- `grep -c "sorry" UltrafilterChain.lean` shows 2 fewer sorries

---

### Phase 4: Remove Deprecated SuccChain Constructs [NOT STARTED]

**Goal**: Remove deprecated `boxClassFamilies_temporally_coherent` and `construct_bfmcs`

**Tasks**:
- [ ] Locate deprecated constructs (marked with `@[deprecated]`)
- [ ] Verify no external references (deprecated = should not be called)
- [ ] Delete the deprecated region (~4680-4770 original, ~90 lines)
- [ ] Run `lake build`

**Timing**: 15 minutes

**Line ranges** (original):
- Delete: ~4680-4770 (~90 lines)
- Sorries eliminated: 4721, 4767 (2 sorries)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove deprecated code

**Verification**:
- `lake build` passes
- No deprecation warnings from removed code

---

### Phase 5: Archive and Remove Z_chain Construction [NOT STARTED]

**Goal**: Remove Z_chain region (structural gap in cross-direction G/H)

**Tasks**:
- [ ] Copy Z_chain region to `ZChain.lean`
- [ ] Verify no external refs: `grep -r "Z_chain\|OmegaFMCS" Theories/ | grep -v "^.*--"`
- [ ] Delete Z_chain region (~5088-5369 original, ~280 lines)
- [ ] Run `lake build`

**Timing**: 20 minutes

**Line ranges** (original):
- Delete: 5088-5369 (~280 lines)
- Sorries eliminated: 5251, 5273, 5287, 5352, 5369 (5 sorries)

**Files to modify**:
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/ZChain.lean` - Archive code
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes
- `grep -r "Z_chain" Theories/` shows only comments

---

### Phase 6: Remove Omega F-Persistence Theorems [NOT STARTED]

**Goal**: Remove dead omega chain F-resolution theorems (no external deps)

**Tasks**:
- [ ] Locate theorems: omega_forward_F_persistence_or_resolution, omega_forward_F_bounded_persistence, Z_chain_forward_F'
- [ ] Verify no external refs
- [ ] Delete region (~6377-6579 original, ~200 lines)
- [ ] Run `lake build`

**Timing**: 15 minutes

**Line ranges** (original):
- Delete: 6377-6579 (~200 lines)
- Sorries eliminated: 6487, 6510, 6551 (3 sorries)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes

---

### Phase 7: Remove P-Preserving Seed Construction [NOT STARTED]

**Goal**: Remove P_unresolved_theory and p_preserving_seed (symmetric to F-preserving)

**Tasks**:
- [ ] Locate P-preserving region
- [ ] Verify no external refs: `grep -r "P_unresolved_theory\|p_preserving_seed" Theories/`
- [ ] Delete region (~7116-7563 original, ~445 lines)
- [ ] Run `lake build`

**Timing**: 20 minutes

**Line ranges** (original):
- Delete: 7116-7563 (~445 lines)
- Sorries eliminated: 7426, 7448 (2 sorries)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes

---

### Phase 8: Archive and Remove CoherentZChain [NOT STARTED]

**Goal**: Remove CoherentZChain (same structural gaps, marked ARCHIVED)

**Tasks**:
- [ ] Copy CoherentZChain region to `CoherentZChain.lean`
- [ ] Verify no external refs: `grep -r "CoherentZChain" Theories/`
- [ ] Delete region (~7920-8170 original, ~250 lines)
- [ ] Run `lake build`

**Timing**: 20 minutes

**Line ranges** (original):
- Delete: 7920-8170 (~250 lines)
- Sorries eliminated: 8047, 8050, 8062, 8064, 8123, 8139 (6 sorries)

**Files to modify**:
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/CoherentZChain.lean` - Archive code
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes

---

### Phase 9: Remove omega_true_dovetailed [NOT STARTED]

**Goal**: Remove omega_true_dovetailed_forward_F_resolution (ARCHIVED, unfixable sorry)

**Tasks**:
- [ ] Locate omega_true_dovetailed region (~8330-8376)
- [ ] Verify no external refs
- [ ] Delete region (~45 lines)
- [ ] Run `lake build`

**Timing**: 10 minutes

**Line ranges** (original):
- Delete: 8330-8376 (~45 lines)
- Sorries eliminated: 8374 (1 sorry)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Remove code

**Verification**:
- `lake build` passes
- File ends cleanly with `end Bimodal.Metalogic.Algebraic.UltrafilterChain`

---

### Phase 10: Final Verification and Documentation [NOT STARTED]

**Goal**: Verify cleanup success and update documentation

**Tasks**:
- [ ] Run full `lake build` to verify compilation
- [ ] Count remaining sorries: `grep -c "sorry" UltrafilterChain.lean`
- [ ] Verify file line count reduced (~5,450 expected)
- [ ] Update ROADMAP.md to document cleanup
- [ ] Create implementation summary

**Timing**: 15 minutes

**Expected results**:
- File size: ~5,450 lines (was 8,376)
- Sorries: 1 (was 24)
- Build: Clean pass

**Files to modify**:
- `ROADMAP.md` - Add cleanup section
- Implementation summary artifact

**Verification**:
- `lake build` passes
- `wc -l UltrafilterChain.lean` shows ~5,450 lines
- `grep -c "sorry" UltrafilterChain.lean` shows 1

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] `grep -c "sorry" UltrafilterChain.lean` decreases progressively
- [ ] No external references to removed code (except comments)
- [ ] Archived code has sufficient context in Boneyard
- [ ] ROADMAP.md updated with cleanup notes

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/README.md` - Archival documentation
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/FPreservingSeed.lean` - Archived code
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/BidirectionalSeed.lean` - Archived code
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/ZChain.lean` - Archived code
- `Theories/Bimodal/Boneyard/UltrafilterDeadCode/CoherentZChain.lean` - Archived code
- `specs/080_ultrafilter_dead_code_audit/summaries/01_cleanup-summary.md` - Execution summary

## Rollback/Contingency

If any phase breaks compilation:
1. `git checkout -- Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
2. Investigate which removed code had unexpected dependencies
3. Use grep to find references: `grep -rn "function_name" Theories/`
4. Either adjust removal scope or update dependent code

For safe incremental rollback, commit after each successful phase.
