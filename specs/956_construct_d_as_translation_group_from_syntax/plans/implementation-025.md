# Implementation Plan: Task #956 - D Construction via Quotient-First Density (v025)

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [PLANNED]
- **Effort**: 4-5 hours (remaining)
- **Dependencies**: Task 957 (COMPLETE), Task 967 (COMPLETE), Task 968 (COMPLETE)
- **Research Inputs**: research-049.md (comprehensive audit), research-008.md (Task 961 obsolete)
- **Artifacts**: plans/implementation-025.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision Note**: v025 supersedes v024; reflects actual state - Phases 6-8 COMPLETE, Task 961 OBSOLETE

## Overview

**Major State Change**: Research-049 audit (2026-03-15) reveals:

1. **StagedConstruction/ has ZERO sorries** - the dense completeness path is FULLY PROVEN
2. **Task 961 is OBSOLETE** - the `canonicalR_irreflexive` theorem was proven in Task 967 via T-axiom approach
3. **Cantor prerequisites COMPLETE**:
   - `NoMaxOrder TimelineQuot` - PROVEN
   - `NoMinOrder TimelineQuot` - PROVEN
   - `DenselyOrdered TimelineQuot` - PROVEN
   - `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` - PROVEN

**How the problem was solved** (not by iteration):
- Task 967 proved `canonicalR_irreflexive` via Gabbay IRR with T-axiom for past
- This gives `canonicalR_strict`: if `CanonicalR M N` then `NOT CanonicalR N M`
- Strictness at quotient level follows automatically - no well-founded iteration needed
- The iteration approach from v024 is UNNECESSARY

**Plan Structure** (revised):
- Phases 0-8: [COMPLETED] - All StagedConstruction prerequisites proven
- Phase 9: D construction via cantor_iso (D := Q or TimelineQuot)
- Phase 10: TaskFrame + Completeness theorem
- Phase 11: Code cleanup and deprecated file archival

### Research Integration

**From research-049**:
- CantorApplication.lean: 0 sorries (was 6 in v024)
- Active Metalogic sorries: 0 in publication path
- Deprecated files with sorries (not blocking): DovetailingChain.lean, TemporalCoherentConstruction.lean, DiscreteTimeline.lean, ConstructiveFragment.lean
- Build status: Clean (743 jobs, 0 errors)

**From research-008 (Task 961)**:
- Task 961 is OBSOLETE - goal achieved via Task 967
- The iteration-based approach is NOT NEEDED
- Strictness follows from irreflexivity, not from formula content analysis

## Goals & Non-Goals

**Goals**:
- Complete D construction connecting cantor_iso to TaskFrame
- Prove completeness theorem for bimodal dense temporal logic
- Archive deprecated files to maintain clean publication codebase
- Zero sorries in final completeness path

**Non-Goals**:
- Well-founded iteration machinery (NOT NEEDED - solved by Task 967)
- MCS-level strict density (SOLVED via T-axiom irreflexivity)
- Discrete completeness path (separate task if desired)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| TaskFrame integration complexity | M | L | Existing TruthLemma provides foundation |
| Completeness theorem wiring | M | L | Follow established bundle pattern |
| Deprecated file archival breaks imports | M | M | Verify no active files import deprecated modules first |

## Sorry Characterization

### Pre-existing Sorries

**Publication Path (StagedConstruction/)**: 0 sorries

**Deprecated Code (not blocking)**:
- Bundle/DovetailingChain.lean: 2 sorries (DEPRECATED)
- Bundle/TemporalCoherentConstruction.lean: 2 sorries (DEPRECATED)
- Domain/DiscreteTimeline.lean: 5 sorries (discrete path only)
- Canonical/ConstructiveFragment.lean: 2 sorries (experimental)

### Expected Resolution

- **Phase 9-10**: No new sorries - wiring proven components
- **Phase 11**: Archived sorries moved to Boneyard

### New Sorries

- None. NEVER introduce new sorries.

### Remaining Debt

After this implementation:
- 0 sorries in publication path
- Deprecated sorries archived in Boneyard

## Implementation Phases

### Phases 0-5: [COMPLETED]

All prerequisite infrastructure phases completed with zero sorries.

---

### Phase 6: Boneyard Archival and Code Cleanup [COMPLETED]

**Completed**: DensityFrameCondition.lean trimmed to 278 lines, strict density attempts archived.

---

### Phase 7: Quotient-Level Density [COMPLETED - via Task 967]

**Original goal**: Well-founded iteration for DenselyOrdered.

**Actual resolution**: Task 967's `canonicalR_irreflexive` theorem provides strictness directly:
- `CanonicalR M N` + irreflexivity => `NOT CanonicalR N M`
- Quotient strictness follows from T4 transitivity contradiction
- No iteration needed

**Result**: CantorApplication.lean `DenselyOrdered` instance is PROVEN with 0 sorries.

---

### Phase 8: Complete CantorApplication [COMPLETED - via Task 967]

**Result**: All 3 instances proven:
- `NoMaxOrder TimelineQuot` - lines 144-161, 0 sorries
- `NoMinOrder TimelineQuot` - lines 168-185, 0 sorries
- `DenselyOrdered TimelineQuot` - lines 194-237, 0 sorries
- `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` - lines 239-243, PROVEN

---

### Phase 9: D and task_rel from Cantor [NOT STARTED]

- **Dependencies:** Phase 8 (COMPLETE)
- **Goal:** Define D := Q with canonical isomorphism, define task_rel from group action

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean`
- [ ] Define the canonical model domain:
  ```lean
  /-- The domain D is the timeline quotient, isomorphic to Q via Cantor -/
  abbrev D (root_mcs : Set Formula) (h : SetMaximalConsistent root_mcs) :=
    TimelineQuot root_mcs h
  ```
- [ ] Export `cantor_iso` as the Cantor isomorphism
- [ ] Define `task_rel : D -> D -> Prop` as the linear order:
  ```lean
  def task_rel {root_mcs} {h} (d d' : D root_mcs h) : Prop := d < d'
  ```
- [ ] Prove basic properties:
  - `task_rel_transitive` (from LinearOrder transitivity)
  - `task_rel_dense` (from DenselyOrdered)
  - `task_rel_serial` (from NoMaxOrder, NoMinOrder)
- [ ] Verify with `lake build`
- [ ] Verify zero sorries

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean` - new file (~100-150 lines)

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" DFromCantor.lean` returns empty

---

### Phase 10: TaskFrame + Completeness [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Complete staged_task_frame and staged_completeness

**Tasks:**
- [ ] Create or extend `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`
- [ ] Define `staged_task_frame : TaskFrame D`:
  ```lean
  def staged_task_frame (root_mcs : Set Formula) (h : SetMaximalConsistent root_mcs) :
      TaskFrame (D root_mcs h) where
    task_rel := task_rel
    -- temporal axioms from D properties
  ```
- [ ] Prove temporal axiom validity using D properties:
  - Seriality: from NoMaxOrder, NoMinOrder
  - Density: from DenselyOrdered
  - Transitivity: from LinearOrder
  - Irreflexivity: from canonicalR_irreflexive (via T-axiom)
- [ ] Wire to existing TruthLemma:
  ```lean
  -- From Bundle/TruthLemma.lean: truth_lemma exists
  ```
- [ ] Prove completeness theorem:
  ```lean
  theorem staged_completeness :
      forall (phi : Formula), ValidInBimodalFrames phi -> Provable phi
  ```
- [ ] Verify with `lake build`
- [ ] Verify zero sorries

**Timing:** 2-2.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` - new file (~150-200 lines)

**Verification:**
- `lake build` passes
- `grep -rn "\bsorry\b" Completeness.lean` returns empty
- Final completeness theorem type-checks

---

### Phase 11: Code Cleanup and Archival [NOT STARTED]

- **Dependencies:** Phase 10
- **Goal:** Archive deprecated files, ensure publication-ready codebase

**Tasks:**
- [ ] Verify no active files import deprecated modules:
  ```bash
  grep -rn "import.*DovetailingChain\|import.*TemporalCoherentConstruction" \
    Theories/Bimodal/Metalogic/
  ```
- [ ] Archive deprecated files to Boneyard:
  - `Bundle/DovetailingChain.lean` -> `Boneyard/Metalogic_v8/Bundle/`
  - `Bundle/TemporalCoherentConstruction.lean` -> `Boneyard/Metalogic_v8/Bundle/`
- [ ] Consider archiving (optional, lower priority):
  - `Canonical/ConstructiveFragment.lean` - experimental path
  - `Domain/DiscreteTimeline.lean` - discrete completeness (if not pursuing)
- [ ] Update state.json:
  - Remove Task 961 dependency (OBSOLETE)
  - Update blocked_reason (no longer blocked)
- [ ] Create README.md in Boneyard directory explaining archived code
- [ ] Verify `lake build` passes after archival
- [ ] Final sorry audit:
  ```bash
  grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/
  # Expected: 0 results
  ```

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Boneyard/Metalogic_v8/` - new Boneyard directory
- `specs/state.json` - update dependencies

**Verification:**
- `lake build` passes
- Zero sorries in StagedConstruction/
- Zero sorries in publication path
- No broken imports

---

## Testing & Validation

### For Lean Tasks (Required)

- [ ] `lake build` passes with no errors after each phase
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Phase-Specific Verification

- [ ] Phase 9: D construction compiles, task_rel properties proven
- [ ] Phase 10: `staged_completeness` compiles without sorry
- [ ] Phase 11: Archived files no longer in active build

### Final Verification

- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/` returns empty
- [ ] `cantor_iso : Nonempty (TimelineQuot ≃o Rat)` verified
- [ ] `staged_completeness` verified
- [ ] No new axioms beyond Mathlib

## Artifacts & Outputs

- `plans/implementation-025.md` (this file)
- `Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean` (new)
- `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean` (new)
- `Theories/Bimodal/Boneyard/Metalogic_v8/` (archived deprecated code)
- `summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

**If Phase 9 blocked**:
- D construction should be straightforward wiring
- Escape valve: Mark [BLOCKED] with `requires_user_review: true`

**If Phase 10 blocked**:
- Completeness may require careful TruthLemma integration
- Existing bundle pattern provides template

**If build errors**:
- `git checkout -- Theories/Bimodal/Metalogic/StagedConstruction/`
- Existing proven code preserved

**Phase Recovery**:
- Each phase is independently committable
- Partial progress preserved in git commits

## Summary

The dense completeness path is FULLY PROVEN through Phase 8 via Task 967's T-axiom approach. Remaining work (Phases 9-11) is primarily wiring and cleanup:

1. **Phase 9** (1.5h): Define D, export cantor_iso, prove task_rel properties
2. **Phase 10** (2.5h): Build TaskFrame, wire TruthLemma, prove completeness
3. **Phase 11** (1h): Archive deprecated files, final audit

**Total remaining**: 4-5 hours for publication-ready metalogic.
