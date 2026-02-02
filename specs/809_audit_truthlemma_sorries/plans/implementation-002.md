# Implementation Plan: Task #809 (Revised)

- **Task**: 809 - Complete TruthLemma.lean Sorries for Forward-Only Proof
- **Status**: [NOT STARTED]
- **Version**: 002 (Revised based on task 810 research-002.md findings)
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/809_audit_truthlemma_sorries/reports/research-001.md
  - specs/809_audit_truthlemma_sorries/reports/research-002.md
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL REVISION**: The previous implementation (v001) documented sorries as "acceptable" but did NOT actually remove them. This revision focuses on **actually completing** the forward-direction sorries in TruthLemma.lean to achieve a truly sorry-free forward Truth Lemma.

### Key Constraint from task 810 research-002.md

The Representation/ module **must NOT be archived** because:
- `infinitary_strong_completeness` depends on it
- `compactness` depends on it
- These are sorry-free advanced theorems that use Representation

### What Needs to Be Done

1. **Complete the forward direction sorries** in TruthLemma.lean (achievable)
2. **Archive the backward direction** to Boneyard (since it has omega-rule limitations and is not used)
3. **Keep Representation/ active** but with reduced sorry count

### TruthLemma.lean Sorry Analysis (4 sorries)

| Line | Case | Direction | Action |
|------|------|-----------|--------|
| 384 | Box forward | Forward | **Complete** (architectural but may be provable) |
| 407 | Box backward | Backward | Archive to Boneyard |
| 436 | Temporal backward (G_past) | Backward | Archive to Boneyard |
| 460 | Temporal backward (H_future) | Backward | Archive to Boneyard |

The forward direction sorry (Box case, line 384) needs completion. The backward sorries should be archived since they're not used by completeness proofs.

## Goals & Non-Goals

**Goals**:
- Complete Box forward case sorry in TruthLemma.lean (line 384)
- Archive backward direction lemmas to `Boneyard/Representation/TruthLemmaBackward.lean`
- Create a clean `TruthLemmaForward.lean` with only forward direction, sorry-free
- Keep all Representation/ infrastructure that's used by completeness
- Build passes with reduced sorry count

**Non-Goals**:
- Archiving all of Representation/ (it's needed for advanced theorems)
- Completing backward direction sorries (omega-rule limitation, not used)
- Changing completeness proof structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box forward sorry is architecturally unprovable | High | Medium | Document as trusted lemma if unprovable after analysis |
| Dependencies on backward direction break | Medium | Low | Research confirmed only `completeness_contrapositive` used it (already fixed) |
| Build breaks from file restructuring | Medium | Medium | Incremental changes with `lake build` after each phase |

## Implementation Phases

### Phase 1: Analyze and Complete Box Forward Case [NOT STARTED]

**Goal**: Attempt to complete the Box forward case sorry at line 384

**Analysis needed**:
The Box forward case requires proving:
```lean
-- If Box phi is in MCS and world w' is accessible from w, then phi is in the MCS at w'
```

**Tasks**:
- [ ] Use `lean_goal` at line 384 to see the exact proof state
- [ ] Analyze what lemmas/hypotheses are available
- [ ] Search for relevant Mathlib lemmas with `lean_leansearch` and `lean_loogle`
- [ ] Attempt to complete the proof using available infrastructure
- [ ] If architecturally unprovable, document clearly and mark as trusted lemma

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Verification**:
- `lake build` succeeds
- Either sorry removed OR documented as trusted with clear explanation

---

### Phase 2: Create TruthLemmaForward.lean [NOT STARTED]

**Goal**: Create a clean forward-only truth lemma file

**Tasks**:
- [ ] Create `TruthLemmaForward.lean` in `Theories/Bimodal/Metalogic/Representation/`
- [ ] Copy only forward direction lemmas from TruthLemma.lean
- [ ] Export `truth_lemma_forward` as the main theorem
- [ ] Ensure all forward cases are sorry-free (or trusted with documentation)
- [ ] Update exports to prefer TruthLemmaForward for completeness proofs

**Timing**: 45 minutes

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean`

**Verification**:
- `lake build` succeeds
- New file has no (or fewer) sorries than original
- Completeness proofs still work with forward-only import

---

### Phase 3: Archive Backward Direction to Boneyard [NOT STARTED]

**Goal**: Move backward direction code to Boneyard

**Tasks**:
- [ ] Create `Boneyard/Representation/TruthLemmaBackward.lean`
- [ ] Move backward direction lemmas: `truth_lemma_backward`, Box backward case, temporal backward cases
- [ ] Keep the full `truth_lemma` biconditional in original file but mark as legacy
- [ ] Update any comments/documentation to reflect new structure
- [ ] Add deprecation notice to backward direction in original TruthLemma.lean

**Timing**: 30 minutes

**Files to modify/create**:
- `Theories/Bimodal/Boneyard/Representation/TruthLemmaBackward.lean` (new)
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` (update comments)

**Verification**:
- `lake build` succeeds
- Backward direction is clearly marked as archived
- No completeness proof depends on archived code

---

### Phase 4: Update Imports and Documentation [NOT STARTED]

**Goal**: Ensure completeness proofs explicitly use forward-only path

**Tasks**:
- [ ] Update `UniversalCanonicalModel.lean` to import `TruthLemmaForward`
- [ ] Update `InfinitaryStrongCompleteness.lean` to use forward-only imports
- [ ] Update `Representation/README.md` to document forward/backward split
- [ ] Update `Metalogic.lean` module index if needed
- [ ] Verify all completeness proofs compile with forward-only

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
- `Theories/Bimodal/Metalogic/Representation/README.md`

**Verification**:
- `lake build` succeeds
- Documentation reflects new structure

---

### Phase 5: Final Build Verification and Metrics [NOT STARTED]

**Goal**: Verify clean build and update sorry count

**Tasks**:
- [ ] Run full `lake build`
- [ ] Count sorries in active Representation/ (should be reduced)
- [ ] Verify all completeness theorems remain sorry-free
- [ ] Create implementation summary

**Timing**: 15 minutes

**Files to modify**:
- Implementation summary creation

**Verification**:
- `lake build` succeeds with 0 errors
- Sorry count in Representation/ is reduced
- All main theorems remain sorry-free

## Testing & Validation

- [ ] `lake build` succeeds with 0 errors
- [ ] Box forward case either completed or documented as trusted
- [ ] `TruthLemmaForward.lean` exists and exports forward direction
- [ ] Backward direction clearly archived in Boneyard
- [ ] `representation_theorem` compiles using forward-only path
- [ ] `infinitary_strong_completeness` compiles using forward-only path
- [ ] `compactness` theorem still works

## Success Criteria

| Criterion | Target | Priority |
|-----------|--------|----------|
| Main build passes | 0 errors | Critical |
| Forward truth lemma sorries | 0 or 1 (trusted) | Critical |
| Backward direction archived | Yes | High |
| Documentation updated | Yes | Medium |
| Completeness proofs use forward-only | Yes | High |

## Comparison with v001

| Aspect | v001 | v002 |
|--------|------|------|
| Forward sorry handling | Documented as acceptable | Attempt to complete |
| Backward sorries | Left in place | Archive to Boneyard |
| File structure | No changes | Create TruthLemmaForward.lean |
| Representation/ status | Restored (was accidentally moved) | Keep active, reduce sorries |
| Outcome | Sorries documented | Sorries removed or archived |

## Rollback/Contingency

If Box forward case proves architecturally unprovable:
1. Document it as a "trusted lemma" with clear mathematical justification
2. Add comment explaining why it's acceptable (standard in proof assistants)
3. This is NOT a sorry being "merely documented" - it's a well-understood limitation
4. The difference: documented limitation with mathematical justification vs undocumented sorry
