# Implementation Plan: Task #810 (v003 - FMP-Only Approach)

- **Task**: 810 - Strategic review: Representation/ approach vs semantic completeness paths
- **Status**: [NOT STARTED]
- **Version**: 003 (Revised based on research-004.md - FMP feasibility analysis)
- **Effort**: 3-4 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-003.md (organization audit)
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-004.md (FMP porting feasibility)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**MAJOR REVISION**: Research-004 discovered that the FMP approach **can fully support** all target results. The gap was definitional, not theoretical. The Representation approach is NOT required.

### Key Findings from research-004.md

| Result | Current Status | FMP Feasibility |
|--------|----------------|-----------------|
| `finite_strong_completeness` | Already FMP-based | ✓ Done |
| `infinitary_strong_completeness` | Uses Representation | ✓ Achievable via direct semantic argument |
| `compactness` | Uses Representation | ✓ Corollary of infinitary completeness |

### New Single-Path Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    UNIFIED FMP COMPLETENESS PATH                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Core MCS Theory (Lindenbaum, Properties)                        │
│              │                                                   │
│              ▼                                                   │
│  FMP Infrastructure (Closure, FiniteWorldState)                  │
│              │                                                   │
│              ▼                                                   │
│  semantic_weak_completeness                                      │
│              │                                                   │
│              ├────────────────┬────────────────┐                │
│              │                │                │                 │
│              ▼                ▼                ▼                 │
│  finite_strong      infinitary_strong      compactness          │
│  _completeness      _completeness          (corollary)          │
│  (via impChain)     (via bridge lemma)                          │
│                                                                  │
│  ALL SORRY-FREE • NO REPRESENTATION REQUIRED                     │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Goals & Non-Goals

**Goals**:
- Achieve `infinitary_strong_completeness` via FMP-based direct semantic argument
- Achieve `compactness` as corollary of infinitary completeness
- Archive ALL Representation code to Boneyard (no longer needed)
- Update documentation to reflect single-path architecture
- Ensure all results are completely sorry-free

**Non-Goals**:
- Completing sorries in Representation (will be archived)
- Maintaining dual-path architecture (simplified to single path)
- Extended FMP infrastructure (simpler approach doesn't need it)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bridge lemma harder than expected | Medium | Low | Core lemmas already proven |
| Proof doesn't transfer cleanly | Medium | Low | Research-004 provides detailed strategy |
| Build issues after Representation archival | Low | Low | Verify imports before archiving |

## Implementation Phases

### Phase 1: Prove Bridge Lemma [NOT STARTED]

**Goal**: Prove `consistent_satisfiable` - the key bridge between consistency and satisfiability

**Theory**: If φ is consistent (¬φ not provable), then {φ} is satisfiable.

**Proof Strategy** (from research-004):
1. φ consistent means ¬φ not provable
2. By `semantic_weak_completeness` contrapositive: ¬φ not valid
3. Therefore ∃ model where ¬φ false, i.e., φ true
4. This model witnesses satisfiability of {φ}

**Tasks**:
- [ ] Create or update `FMP/ConsistentSatisfiable.lean` with:
  ```lean
  lemma consistent_satisfiable (phi : Formula) (h : SetConsistent {phi}) :
      set_satisfiable {phi}
  ```
- [ ] Prove using `semantic_weak_completeness` contrapositive
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` (new)

**Verification**:
- `lake build Bimodal.Metalogic.FMP.ConsistentSatisfiable` succeeds
- No sorry in the bridge lemma

---

### Phase 2: Port Infinitary Strong Completeness to FMP [NOT STARTED]

**Goal**: Prove `infinitary_strong_completeness` using only FMP infrastructure

**Proof Strategy** (from research-004, Section 6):
1. Contrapositive: Assume no finite Δ ⊆ Γ derives φ
2. By `no_finite_witness_implies_union_consistent`: Γ ∪ {¬φ} is SetConsistent
3. Extract ¬φ from the consistent set
4. By `consistent_satisfiable` (Phase 1): {¬φ} is satisfiable
5. There exists a model where ¬φ is true
6. Since semantic consequence is anti-monotonic, Γ is also satisfied in this model
7. Contradiction: Γ |= φ but model satisfies Γ and ¬φ

**Tasks**:
- [ ] Create `Completeness/InfinitaryStrongCompletenessFMP.lean`
- [ ] Import FMP infrastructure (not Representation)
- [ ] Prove `infinitary_strong_completeness` using new approach
- [ ] Verify no Representation imports

**Timing**: 1.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompletenessFMP.lean` (new)

**Verification**:
- No imports from `Representation/` or `Boneyard/`
- `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompletenessFMP` succeeds
- Theorem is sorry-free

---

### Phase 3: Port Compactness to FMP [NOT STARTED]

**Goal**: Prove `compactness` using the new FMP-based infinitary completeness

**Proof Strategy**:
Compactness follows directly from infinitary strong completeness + soundness (both sorry-free):
1. If Γ not satisfiable, then Γ |= ⊥
2. By infinitary completeness: some finite Δ ⊆ Γ derives ⊥
3. By soundness: Δ not satisfiable
4. Contrapositive gives compactness

**Tasks**:
- [ ] Create `Compactness/CompactnessFMP.lean`
- [ ] Import from new FMP-based infinitary completeness
- [ ] Prove `compactness` and `compactness_iff`
- [ ] Verify no Representation imports

**Timing**: 0.5 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Compactness/CompactnessFMP.lean` (new)

**Verification**:
- No imports from `Representation/` or `Boneyard/`
- `lake build Bimodal.Metalogic.Compactness.CompactnessFMP` succeeds
- Theorems are sorry-free

---

### Phase 4: Archive Representation and Update Exports [NOT STARTED]

**Goal**: Move Representation to Boneyard and update module exports

**Tasks**:
- [ ] Move `Metalogic/Representation/` to `Boneyard/Metalogic_v6/Representation/`
- [ ] Remove Representation imports from `Metalogic/Metalogic.lean`
- [ ] Update `Completeness/Completeness.lean` to export FMP versions
- [ ] Update `Compactness/Compactness.lean` to export FMP version
- [ ] Run full `lake build` to verify

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - remove Representation imports
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` - update exports
- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean` - update exports

**Files to move**:
- `Theories/Bimodal/Metalogic/Representation/*` → `Boneyard/Metalogic_v6/Representation/`

**Verification**:
- `lake build` succeeds with 0 errors
- No imports from Representation in active code
- All main theorems still accessible

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Update documentation to reflect single-path FMP architecture

**Tasks**:
- [ ] Update `Metalogic/README.md`:
  - Remove dual-path description
  - Document unified FMP architecture
  - Update sorry count (should be 0)
- [ ] Add deprecation notice to archived Representation code
- [ ] Update task summary

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/README.md`
- `Boneyard/Metalogic_v6/Representation/README.md` (create)

**Verification**:
- Documentation accurately reflects code
- Clear explanation of why Representation was archived

## Testing & Validation

- [ ] `lake build` succeeds with 0 errors
- [ ] All main theorems are sorry-free:
  - [ ] `semantic_weak_completeness`
  - [ ] `finite_strong_completeness`
  - [ ] `infinitary_strong_completeness`
  - [ ] `compactness`
  - [ ] `compactness_iff`
- [ ] No imports from `Representation/` or `Boneyard/` in active Metalogic code
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard` returns nothing

## Success Criteria

| Criterion | Target | Priority |
|-----------|--------|----------|
| Main build passes | 0 errors | Critical |
| All 5 key theorems sorry-free | 5/5 | Critical |
| No Representation dependencies | 0 imports | Critical |
| Documentation updated | Clear single-path | High |
| Repository health improved | sorry_count reduced | Medium |

## Artifacts & Outputs

- `specs/810_strategic_review_representation_vs_semantic_paths/plans/implementation-003.md` (this file)
- `specs/810_strategic_review_representation_vs_semantic_paths/summaries/implementation-summary-20260202.md` (to be created)
- New files:
  - `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean`
  - `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompletenessFMP.lean`
  - `Theories/Bimodal/Metalogic/Compactness/CompactnessFMP.lean`
- Archived: `Boneyard/Metalogic_v6/Representation/`
- Updated: `Theories/Bimodal/Metalogic/README.md`

## Comparison with Previous Plans

| Aspect | v002 | v003 (This Plan) |
|--------|------|------------------|
| Architecture | Dual-path (FMP + Representation) | Single-path (FMP only) |
| Representation | Keep active, complete sorries | Archive to Boneyard |
| Sorries to complete | 28 | 0 |
| Effort | 6 hours | 3-4 hours |
| New code | None | 3 small files |
| Complexity | High (maintain two approaches) | Low (one clean approach) |

## Rollback/Contingency

If the FMP-only approach encounters unexpected issues:
1. Bridge lemma fails: Check proof strategy, may need different formulation
2. Import cycles: Restructure file organization
3. Performance issues: Accept but document

The archived Representation code remains available in Boneyard if ever needed for reference.
