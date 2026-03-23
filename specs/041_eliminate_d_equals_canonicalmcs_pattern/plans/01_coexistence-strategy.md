# Implementation Plan: Task #41 - Coexistence Strategy for D=CanonicalMCS

- **Task**: 41 - eliminate_d_equals_canonicalmcs_pattern
- **Status**: [NOT STARTED]
- **Effort**: 4 hours (immediate phases) + deferred work (blocked on Tasks 48, 36, 37)
- **Dependencies**: Tasks 48, 36, 37 (for D=Int path only; immediate phases have no dependencies)
- **Research Inputs**: specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/01_team-research.md, specs/041_eliminate_d_equals_canonicalmcs_pattern/reports/02_deep-research.md
- **Artifacts**: plans/01_coexistence-strategy.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true (zero-sorry policy compliance)

## Overview

The D=CanonicalMCS pattern is a **mathematically valid but architecturally problematic** technique that trivializes F/P witness obligations by making `mcs(w) = w.world` (identity mapping). Research confirms this pattern is **load-bearing** for the sorry-free completeness path via `temporal_coherent_family_exists_CanonicalMCS`. Simply removing it would reintroduce sorries.

**Strategy**: Establish a coexistence model where:
1. D=CanonicalMCS remains for proof-theoretic TruthLemma path (sorry-free, keep operational)
2. D=Int via FMCSTransfer added for semantic model (blocked until Tasks 48, 36, 37 complete)

**Immediate actions** (Phases 1-2): Archive dead code, update documentation
**Deferred actions** (Phases 3-4): Blocked on prerequisite tasks

### Research Integration

From deep research report:
- 16 active usages of D=CanonicalMCS pattern identified
- `temporal_coherent_family_exists_CanonicalMCS` is the only sorry-free existence theorem
- D=Int path blocked on `f_nesting_boundary` and `p_nesting_boundary` proofs (sorries at SuccChainFMCS.lean:728-735, 963-970)
- MultiFamilyBFMCS.lean contains documented dead ends (W=D conflation) ready for archival

## Goals & Non-Goals

**Goals**:
- Archive confirmed dead code to Boneyard (MultiFamilyBFMCS dead ends)
- Document architectural intent clearly (CanonicalMCS = proof-theoretic, Int = semantic)
- Establish tracking for deferred D=Int migration (depends on Tasks 48, 36, 37)
- Maintain zero-sorry policy throughout

**Non-Goals**:
- Remove D=CanonicalMCS entirely (would add sorries)
- Implement D=Int path now (blocked on prerequisite tasks)
- Attempt D=Int via linear chain (fundamentally impossible per IntBFMCS.lean)
- Add new axioms or sorries

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dead code archival breaks active imports | High | Low | Check lake build before/after |
| Documentation changes create confusion | Medium | Low | Clear architectural intent sections |
| Task 48 never completes, D=Int path abandoned | Low | Medium | D=CanonicalMCS remains functional |
| Premature D=Int attempt adds sorries | High | Low | Explicit blocking on Tasks 48, 36, 37 |

## Implementation Phases

### Phase 1: Archive Dead Code [NOT STARTED]

**Goal**: Remove documented dead-end code from MultiFamilyBFMCS.lean to Boneyard, reducing codebase confusion.

**Tasks**:
- [ ] Verify MultiFamilyBFMCS.lean dead-end sections (lines 213-289 `singletonCanonicalBFMCS`, lines 531-572 `canonical_modal_backward`)
- [ ] Create Boneyard archive file `Boneyard/MultiFamilyBFMCS_DeadEnds.lean`
- [ ] Move dead-end code with preservation header documenting why it was archived
- [ ] Update MultiFamilyBFMCS.lean to remove dead-end sections
- [ ] Run `lake build` to verify no breakage
- [ ] Review LogicVariants.lean line 155 usage and determine if removable

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/MultiFamilyBFMCS.lean` - Remove dead-end sections
- `Boneyard/MultiFamilyBFMCS_DeadEnds.lean` - Create archive (new file)
- `Theories/Bimodal/LogicVariants.lean` - Review and potentially update

**Verification**:
- `lake build` succeeds with no new sorries or errors
- Dead-end code preserved in Boneyard with documentation
- No active code references removed functions

---

### Phase 2: Documentation Clarification [NOT STARTED]

**Goal**: Add "Architectural Intent" sections to key files clarifying the dual-purpose design.

**Tasks**:
- [ ] Add architectural note to CanonicalFMCS.lean header explaining:
  - D=CanonicalMCS is proof-theoretic construction for TruthLemma
  - Identity mapping `mcs(w) = w.world` is intentional
  - Pattern provides sorry-free F/P witnesses via Lindenbaum
  - New semantic models should use D=Int via FMCSTransfer
- [ ] Update FMCSDef.lean docstrings (lines 20-31) to strengthen warning:
  - Clarify D=CanonicalMCS is valid for proof-theoretic path
  - Document that D=Int is preferred for semantic completeness
  - Reference FMCSTransfer as the bridge mechanism
- [ ] Add note to FMCSTransfer.lean explaining the coexistence architecture:
  - transferredFMCS enables D=Int with sorry-free F/P from CanonicalMCS
  - Requires chain completeness proof (Task 48)
- [ ] Update MultiFamilyBFMCS.lean header (after Phase 1 cleanup) to document what remains and why

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/CanonicalFMCS.lean` - Add header documentation
- `Theories/Bimodal/Metalogic/Core/FMCSDef.lean` - Strengthen docstrings
- `Theories/Bimodal/Metalogic/Transfer/FMCSTransfer.lean` - Add architecture note
- `Theories/Bimodal/Metalogic/Bundle/MultiFamilyBFMCS.lean` - Update header

**Verification**:
- Documentation clearly explains dual-purpose design
- New developers can understand why both patterns exist
- `lake build` still succeeds

---

### Phase 3: Prerequisites Tracking [NOT STARTED]

**Goal**: Document the dependency chain for D=Int migration and create tracking mechanism.

**Tasks**:
- [ ] Create specs/041_eliminate_d_equals_canonicalmcs_pattern/PREREQUISITES.md documenting:
  - Task 48: Prove succ_chain_fam MCS have bounded F-depth (RestrictedMCS evidence)
  - Task 36: Prove f_nesting_boundary without sorry (depends on 48)
  - Task 37: Prove p_nesting_boundary without sorry (depends on 36)
- [ ] Add cross-references in TODO.md linking Tasks 48, 36, 37 to Task 41
- [ ] Document the specific sorries that must be eliminated:
  - SuccChainFMCS.lean lines 728-735 (f_nesting_boundary)
  - SuccChainFMCS.lean lines 963-970 (p_nesting_boundary)

**Timing**: 0.5 hours

**Files to modify**:
- `specs/041_eliminate_d_equals_canonicalmcs_pattern/PREREQUISITES.md` - Create tracking file
- Cross-reference notes only (no TODO.md changes without user approval)

**Verification**:
- Prerequisites clearly documented with line numbers
- Dependency chain explicit: 48 -> 36 -> 37 -> 41 (D=Int path)

---

### Phase 4: Future D=Int Pathway [BLOCKED]

**Goal**: Document the implementation approach for D=Int once prerequisites are met.

**Status**: BLOCKED on Tasks 48, 36, 37

**Tasks** (deferred):
- [ ] Implement FMCSTransfer instantiation for D=Int once f_nesting_boundary is sorry-free
- [ ] Create `embed : CanonicalMCS -> Int` mapping chain MCSes to positions
- [ ] Create `retract : Int -> CanonicalMCS` mapping positions back to chain MCSes
- [ ] Prove chain completeness (every MCS appears at some index)
- [ ] Wire `transferredFMCS Int` for semantic completeness arguments
- [ ] Add architectural guards preventing W=D conflation in new code

**Timing**: Estimated 4-6 hours (after prerequisites complete)

**Blocked by**:
- Task 48: succ_chain_fam bounded F-depth
- Task 36: f_nesting_boundary sorry elimination
- Task 37: p_nesting_boundary sorry elimination

**Verification**:
- `transferredFMCS Int` exists with sorry-free F/P
- Semantic completeness can use D=Int model
- No new sorries introduced

## Testing & Validation

- [ ] `lake build` succeeds after Phase 1 (dead code archival)
- [ ] `lake build` succeeds after Phase 2 (documentation only, no logic changes)
- [ ] No new sorries introduced (grep for `sorry` in modified files)
- [ ] Dead code in Boneyard preserves full history
- [ ] Documentation clearly explains coexistence architecture

## Artifacts & Outputs

- `Boneyard/MultiFamilyBFMCS_DeadEnds.lean` - Archived dead-end code
- `specs/041_eliminate_d_equals_canonicalmcs_pattern/PREREQUISITES.md` - Dependency tracking
- Updated documentation in CanonicalFMCS.lean, FMCSDef.lean, FMCSTransfer.lean
- Summary report after Phases 1-3 completion

## Rollback/Contingency

**If Phase 1 breaks build**:
1. `git checkout` the modified files
2. Investigate which "dead" code is actually referenced
3. Remove only confirmed-dead sections

**If documentation creates confusion**:
1. Revert to simpler inline comments
2. Create separate ARCHITECTURE.md in Metalogic folder instead

**If D=Int path proves impossible**:
1. Document the mathematical limitation clearly
2. Keep D=CanonicalMCS as the permanent solution for TruthLemma
3. Close Task 41 with explanation

## Success Criteria

Task 41 is complete when:
- [ ] Dead code archived to Boneyard (Phase 1)
- [ ] Documentation updated with architectural intent (Phase 2)
- [ ] Prerequisites documented with explicit blockers (Phase 3)
- [ ] No new sorries introduced
- [ ] Build passes with zero axiom changes

**Note**: Phase 4 (D=Int implementation) is explicitly out of scope until Tasks 48, 36, 37 complete. Task 41 can be marked [COMPLETED] after Phases 1-3, with Phase 4 tracked as future work.
