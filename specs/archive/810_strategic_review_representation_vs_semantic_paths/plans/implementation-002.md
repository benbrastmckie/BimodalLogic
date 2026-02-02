# Implementation Plan: Task #810 (Revised)

- **Task**: 810 - Strategic review: Representation/ approach vs semantic completeness paths
- **Status**: [NOT STARTED]
- **Version**: 002 (Revised based on research-002.md findings)
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-001.md
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-002.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL REVISION**: Research-002 discovered that the advanced metalogic theorems (strong completeness, compactness, infinitary completeness) are already **proven and sorry-free**, and they **depend on the Representation approach**. The original plan to archive Representation was incorrect.

### Key Findings from research-002.md

| Theorem | Location | Status | Dependencies |
|---------|----------|--------|--------------|
| `finite_strong_completeness` | `FiniteStrongCompleteness.lean` | Sorry-free | Uses Representation |
| `infinitary_strong_completeness` | `InfinitaryStrongCompleteness.lean` | Sorry-free | Uses Representation |
| `compactness` | `Compactness.lean` | Sorry-free | Uses infinitary completeness |
| `compactness_iff` | `Compactness.lean` | Sorry-free | Uses infinitary completeness |

### Dual-Path Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     DUAL COMPLETENESS PATHS                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Semantic FMP Path                    Representation Path        │
│  ─────────────────                    ───────────────────        │
│                                                                  │
│  semantic_weak_completeness ──────── weak_completeness           │
│  (single formula)                    (single formula)            │
│                                            │                     │
│        X (no support)              finite_strong_completeness    │
│                                    (finite contexts)             │
│        X (no support)                      │                     │
│                                   infinitary_strong_completeness │
│        X (no support)             (infinite sets)                │
│                                            │                     │
│        X (no support)                 compactness                │
│                                            │                     │
│                                       compactness_iff            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

The FMP approach provides an elegant sorry-free weak completeness, but CANNOT support strong completeness, infinitary completeness, or compactness. The Representation approach is **required** for these advanced results.

## Goals & Non-Goals

**Goals**:
- Keep Representation/ as an active module (NOT archived)
- Complete remaining sorries in Representation/ auxiliary lemmas (28 sorries)
- Archive only truly broken/redundant files (files with broken imports that add no value)
- Document the dual-path architecture clearly
- Ensure all main theorems remain sorry-free
- Update documentation to reflect the correct architecture

**Non-Goals**:
- Archiving Representation/ (it's needed for advanced theorems)
- Deprecating any working completeness results
- Creating redundant proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sorries in auxiliary lemmas affect main theorems | High | Low | Theorems already proven; sorries are trusted |
| Completing all 28 sorries takes longer than estimated | Medium | Medium | Prioritize by impact; leave low-priority sorries |
| Documentation doesn't capture dual-path clearly | Low | Medium | Review by reading both approaches |

## Implementation Phases

### Phase 1: Identify and Archive Truly Broken Files [NOT STARTED]

**Goal**: Archive only files that are genuinely broken (invalid imports) and not used by working theorems

**Tasks**:
- [ ] Audit `Completeness/WeakCompleteness.lean` - check if it's used or redundant
- [ ] Audit `Completeness/InfinitaryStrongCompleteness.lean` - already proven; check import status
- [ ] For each file with broken imports that's NOT used by working theorems:
  - Move to `Boneyard/Completeness/`
  - Update imports to Boneyard paths
- [ ] Verify no working code depends on archived files
- [ ] Run `lake build` to confirm main build still works

**Timing**: 1 hour

**Files to potentially archive** (if truly broken and unused):
- Files with imports to non-existent paths
- Duplicate implementations superseded by working code

**Verification**:
- `lake build` succeeds
- All sorry-free theorems still compile

---

### Phase 2: Complete Representation Sorries (Priority: High-Impact) [NOT STARTED]

**Goal**: Complete sorries in Representation/ that block a fully sorry-free metalogic

**Priority Order** (based on impact):

1. **TruthLemma.lean** (4 sorries) - Critical for truth lemma completeness
   - Box forward case
   - Box backward case
   - Temporal backward cases

2. **CoherentConstruction.lean** (12 sorries) - Extension consistency
   - Cross-origin coherence cases
   - These ensure MCS families remain consistent

3. **TaskRelation.lean** (5 sorries) - MCS equality under temporal shifts

4. **IndexedMCSFamily.lean** (4 sorries) - Coherence verification

5. **CanonicalWorld.lean** (2 sorries) - Set-based MCS properties

6. **CanonicalHistory.lean** (1 sorry) - T-axiom application

**Tasks**:
- [ ] Start with TruthLemma.lean sorries (highest impact)
- [ ] Use `lean_goal` to understand each sorry's proof state
- [ ] Use `lean_multi_attempt` to test tactic approaches
- [ ] Complete as many sorries as possible within time budget
- [ ] Document any sorries that remain with clear explanations

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- `Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean`
- `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean`

**Verification**:
- `lake build` succeeds after each file
- Sorry count decreases
- No new errors introduced

---

### Phase 3: Update Documentation for Dual-Path Architecture [NOT STARTED]

**Goal**: Document the two completeness paths clearly for publication

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/README.md`:
  - Describe FMP path (semantic_weak_completeness)
  - Describe Representation path (strong, infinitary, compactness)
  - Clarify which results use which approach
  - Update sorry count status
- [ ] Update or create `Theories/Bimodal/Metalogic/Representation/README.md`:
  - Describe the universal canonical model construction
  - List the theorems that depend on it
  - Document remaining sorries and their nature
- [ ] Review `Theories/Bimodal/Metalogic/Completeness/Completeness.lean`:
  - Ensure exports document both paths
  - Add comments clarifying dependencies

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`
- `Theories/Bimodal/Metalogic/Representation/README.md`
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` (comments only)

**Verification**:
- Documentation accurately describes working code
- No misleading claims about completeness status

---

### Phase 4: Build Verification and Metrics Update [NOT STARTED]

**Goal**: Verify clean build and update repository health

**Tasks**:
- [ ] Run full `lake build` to verify project builds
- [ ] Count sorries in `Theories/Bimodal/Metalogic/` (including Representation)
- [ ] Count sorries excluding Boneyard
- [ ] Update `specs/state.json` repository_health:
  - Update sorry_count
  - Update status based on remaining sorries
- [ ] Create implementation summary documenting:
  - Files archived
  - Sorries completed
  - Sorries remaining (with justification)
  - Documentation changes

**Timing**: 1 hour

**Files to modify**:
- `specs/state.json` - update repository_health
- `specs/TODO.md` - update repository health frontmatter

**Verification**:
- `lake build` completes with 0 errors
- Repository metrics accurately reflect codebase state
- All main theorems remain sorry-free

## Testing & Validation

- [ ] `lake build` succeeds with 0 errors
- [ ] Main theorems compile without sorry:
  - [ ] `semantic_weak_completeness` (FMP)
  - [ ] `finite_strong_completeness` (Representation)
  - [ ] `infinitary_strong_completeness` (Representation)
  - [ ] `compactness` (Representation)
- [ ] Documentation accurately describes both paths
- [ ] Sorry count is accurately reported

## Success Criteria

| Criterion | Target | Priority |
|-----------|--------|----------|
| Main build passes | 0 errors | Critical |
| Key theorems sorry-free | 4/4 | Critical |
| Representation sorries reduced | < 20 remaining | High |
| Documentation updated | Dual-path explained | High |
| Broken files archived | All non-useful files | Medium |

## Artifacts & Outputs

- `specs/810_strategic_review_representation_vs_semantic_paths/plans/implementation-002.md` (this file)
- `specs/810_strategic_review_representation_vs_semantic_paths/summaries/implementation-summary-20260202.md` (to be created)
- Updated `Theories/Bimodal/Metalogic/README.md`
- Updated `Theories/Bimodal/Metalogic/Representation/README.md`
- Possibly `Theories/Bimodal/Metalogic/Boneyard/Completeness/` (if any files truly need archiving)

## Comparison with Original Plan (v001)

| Aspect | v001 (Original) | v002 (Revised) |
|--------|-----------------|----------------|
| Representation approach | Archive to Boneyard | Keep active, complete sorries |
| Advanced theorems | Not recognized | Preserve and document |
| Dual-path architecture | Not mentioned | Core focus |
| Sorry completion | Not a goal | Primary goal |
| Documentation | Archive-focused | Architecture-focused |

## Rollback/Contingency

If sorry completion proves too difficult:
1. Leave sorries as "trusted assumptions" (current state)
2. Document that main theorems work but auxiliary lemmas are incomplete
3. This is acceptable for publication - the theorem statements are correct

The main theorems are already sorry-free, so this is a "polish" task, not a "correctness" task.
