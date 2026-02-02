# Implementation Plan: Task #809 (v003)

- **Task**: 809 - Archive TruthLemma.lean Sorries to Boneyard
- **Status**: [IMPLEMENTING]
- **Version**: 003 (Actually archive sorries, not document them)
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/809_audit_truthlemma_sorries/reports/research-001.md
  - specs/809_audit_truthlemma_sorries/reports/research-002.md
  - specs/810_strategic_review_representation_vs_semantic_paths/reports/research-002.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Overview

**CRITICAL REVISION v003**: Previous implementations (v001, v002) only documented sorries with labels but left them in the active codebase. This revision **actually moves** the code containing sorries to Boneyard.

### Strategy: Archive Entire TruthLemma.lean

The simplest approach is to:
1. **Archive the entire TruthLemma.lean** to Boneyard (it contains 4 sorries)
2. **Keep TruthLemmaForward.lean** but have it NOT depend on the archived file
3. **Update dependent files** to either:
   - Use sorry-free alternatives (if they exist)
   - Be archived themselves (if they depend on sorried code)

### Key Insight from Research

From task 810 research-002.md:
- The main theorems (`infinitary_strong_completeness`, `compactness`) are already sorry-free
- BUT they use `truth_lemma_forward` which transitively depends on TruthLemma.lean
- The sorries in TruthLemma.lean are "trusted" but still present

**Decision**: If the completeness theorems REQUIRE the sorried truth lemma, then either:
1. Archive those theorems too (extreme but honest), OR
2. Create stub/axiom versions that explicitly declare the dependency

## Goals & Non-Goals

**Goals**:
- **Zero sorries** in active `Theories/Bimodal/Metalogic/Representation/` directory
- Move TruthLemma.lean (with its 4 sorries) to Boneyard
- Ensure builds pass without the sorried code in active path
- Document what was archived and why

**Non-Goals**:
- Proving the unprovable (Box cases, omega-rule cases)
- Keeping sorried code in active path with any label

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Completeness proofs break without truth lemma | High | High | May need to archive those too, or use axioms |
| Too much code gets archived | Medium | Medium | Careful dependency analysis first |
| Build breaks | Medium | Medium | Incremental changes with lake build |

## Implementation Phases

### Phase 1: Dependency Analysis [NOT STARTED]

**Goal**: Identify ALL files that depend on TruthLemma.lean

**Tasks**:
- [ ] Find all imports of TruthLemma
- [ ] Map the dependency chain
- [ ] Identify which files can be kept vs must be archived
- [ ] Document the full impact

**Expected files depending on TruthLemma.lean**:
- `TruthLemmaForward.lean` (wrapper)
- `UniversalCanonicalModel.lean` (uses truth_lemma_forward)
- `InfinitaryStrongCompleteness.lean` (uses representation_theorem)
- Possibly others

**Timing**: 30 minutes

**Verification**:
- Complete dependency map documented

---

### Phase 2: Archive TruthLemma.lean to Boneyard [NOT STARTED]

**Goal**: Move TruthLemma.lean to Boneyard

**Tasks**:
- [ ] Move `Representation/TruthLemma.lean` to `Boneyard/Metalogic_v5/Representation/TruthLemma.lean`
- [ ] Update any internal imports in the archived file
- [ ] Delete or update `TruthLemmaForward.lean` (it imports TruthLemma)

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` → Move to Boneyard
- `Theories/Bimodal/Metalogic/Representation/TruthLemmaForward.lean` → Delete or archive

**Verification**:
- TruthLemma.lean no longer in active Representation/
- Boneyard contains the archived file

---

### Phase 3: Handle Dependent Files [NOT STARTED]

**Goal**: Update or archive files that depended on TruthLemma

**Based on dependency analysis, for each dependent file**:

**Option A - If file can work without truth lemma**:
- Remove/comment out the import
- Remove/stub the code that used truth_lemma_forward

**Option B - If file fundamentally requires truth lemma**:
- Archive the entire file to Boneyard
- Document what was archived

**Likely candidates for archival**:
- `UniversalCanonicalModel.lean` (uses representation_theorem)
- Possibly `InfinitaryStrongCompleteness.lean`

**Timing**: 45 minutes

**Verification**:
- No active file imports archived TruthLemma
- `lake build` passes

---

### Phase 4: Update Module Index and Documentation [NOT STARTED]

**Goal**: Update Metalogic.lean and documentation

**Tasks**:
- [ ] Remove archived files from `Metalogic.lean` module index
- [ ] Update `Representation/README.md` to note what was archived
- [ ] Document in specs what theorems are now in Boneyard

**Timing**: 15 minutes

**Verification**:
- Module index compiles
- Documentation accurate

---

### Phase 5: Final Build and Sorry Count [NOT STARTED]

**Goal**: Verify clean build with zero Representation sorries

**Tasks**:
- [ ] Run `lake build`
- [ ] Count sorries: `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/`
- [ ] Verify count is significantly reduced (goal: zero in Representation/)
- [ ] Create implementation summary

**Timing**: 15 minutes

**Success Criteria**:
- `lake build` succeeds
- **Zero sorries** in `Theories/Bimodal/Metalogic/Representation/`
- All archived code is in Boneyard with clear documentation

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/` returns zero matches
- [ ] Archived files are in Boneyard/Metalogic_v5/
- [ ] Documentation explains what was archived

## Success Criteria

| Criterion | Target | Priority |
|-----------|--------|----------|
| Build passes | 0 errors | Critical |
| Representation/ sorry count | 0 | Critical |
| Archived code in Boneyard | Yes | Critical |
| Documentation updated | Yes | High |

## Comparison with Previous Versions

| Aspect | v001 | v002 | v003 (this) |
|--------|------|------|-------------|
| Sorries in active code | 4 | 4 | **0** (target) |
| Approach | Document as acceptable | Document with labels | **Archive to Boneyard** |
| Truth lemma status | Active | Active with wrapper | **Archived** |
| Honest about limitations | Partially | Better | **Fully honest** |

## Rollback/Contingency

If archiving breaks too many important theorems:
1. Consider archiving the entire Representation/ approach
2. Focus on FMP path for semantic_weak_completeness
3. Document that advanced theorems (strong completeness, compactness) are in Boneyard

This is acceptable because:
- The FMP path provides sorry-free weak completeness
- The archived theorems still exist and can be restored if the sorries are ever completed
