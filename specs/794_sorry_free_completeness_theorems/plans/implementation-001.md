# Implementation Plan: Task #794

- **Task**: 794 - Establish sorry-free completeness theorems
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: Task 777 research
- **Research Inputs**: specs/794_sorry_free_completeness_theorems/reports/research-001.md, specs/777_complete_weak_completeness_sorry/reports/research-007.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This implementation establishes sorry-free `weak_completeness`, `strong_completeness`, and `compactness` theorems by leveraging the already sorry-free `semantic_weak_completeness` from the FMP path. The key insight from research is that two completeness architectures exist: the FMP path (sorry-free) and the Representation path (35+ sorries). We will create bridge lemmas to connect `semantic_weak_completeness` to the standard completeness API, then update the downstream theorems to use this sorry-free foundation.

### Research Integration

From research-001.md and research-007.md:
1. `semantic_weak_completeness` in `FMP/SemanticCanonicalModel.lean` is **already sorry-free**
2. The current `weak_completeness` in `WeakCompleteness.lean` has 1 sorry (soundness) plus depends on `representation_theorem` which has 2 sorries
3. The `InfinitaryStrongCompleteness.lean` actually contains a **sorry-free proof** that uses `set_lindenbaum` directly with G-bot/H-bot exclusion proven inline
4. `Compactness.lean` is sorry-free, depending only on `InfinitaryStrongCompleteness` and the sorried `soundness`
5. The main blocking sorry is the local `soundness` copy in `WeakCompleteness.lean` - the real soundness is proven in `Soundness.lean`

## Goals & Non-Goals

**Goals**:
- Establish a sorry-free `weak_completeness` theorem
- Ensure `strong_completeness` (finite and infinitary) are sorry-free
- Verify `compactness` becomes sorry-free once dependencies are fixed
- Remove redundant sorried code paths

**Non-Goals**:
- Archive the Representation module (separate task)
- Fix decidability sorries (separate concern, partial implementation acceptable)
- Create new theorem names/APIs - prefer fixing existing ones

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bridge lemma between `semantic_weak_completeness` and standard validity API is non-trivial | H | M | Research shows `semantic_truth_at_v2` operates on `SemanticWorldState` which has restricted domain; may need careful type-level work |
| Import cycle when importing `Soundness.lean` into `WeakCompleteness.lean` | M | L | Check import graph; Soundness.lean doesn't import WeakCompleteness |
| `InfinitaryStrongCompleteness` depends on `representation_theorem` | H | H | Research shows it actually proves G-bot/H-bot exclusion inline - verify this is complete |
| Type mismatches between FMP types and standard semantic types | M | M | Use careful coercion and wrapper functions |

## Implementation Phases

### Phase 1: Fix Soundness Import in WeakCompleteness [NOT STARTED]

**Goal**: Replace the sorried local `soundness` theorem with an import of the proven `Bimodal.Metalogic.soundness`

**Tasks**:
- [ ] Verify `Soundness.lean` exports `soundness : (Gamma : Context) (phi : Formula) : (Gamma vdash phi) -> (Gamma models phi)`
- [ ] Check type compatibility: `semantic_consequence Gamma phi` vs `Gamma models phi`
- [ ] Add import `Bimodal.Metalogic.Soundness` to `WeakCompleteness.lean`
- [ ] Replace the sorry'd `soundness` with a proof using the imported theorem
- [ ] Run `lake build` to verify no errors

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Replace lines 90-92

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.WeakCompleteness` succeeds
- The local `soundness` theorem has no sorry

---

### Phase 2: Verify InfinitaryStrongCompleteness is Actually Sorry-Free [NOT STARTED]

**Goal**: Confirm that `infinitary_strong_completeness` and its dependencies are completely sorry-free

**Tasks**:
- [ ] Verify that `construct_coherent_family` and related functions used in `InfinitaryStrongCompleteness` are sorry-free
- [ ] Check that the G-bot/H-bot exclusion proofs (lines 368-421) use only proven lemmas
- [ ] Verify `truth_lemma` from Representation module is sorry-free
- [ ] Run `lake build` and grep for sorries in the dependency chain

**Timing**: 1 hour

**Files to check**:
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean`
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Verification**:
- `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` shows no active sorries
- `grep -r "sorry" Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` shows no active sorries

---

### Phase 3: Fix Representation Module Sorries for InfinitaryStrongCompleteness [NOT STARTED]

**Goal**: Eliminate sorries in the `truth_lemma` and `construct_coherent_family` that `InfinitaryStrongCompleteness` depends on

**Tasks**:
- [ ] Identify which sorries in TruthLemma.lean are actually used by `infinitary_strong_completeness`
- [ ] Focus on sorries that affect the forward direction: `phi in MCS -> truth_at phi`
- [ ] Fill in proofs for G-bot/H-bot temporal boundary cases if needed
- [ ] Verify `construct_coherent_family_origin` is proven

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Fill sorries in forward direction
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` - Fill sorries if any

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.InfinitaryStrongCompleteness` succeeds
- No sorries in files that `infinitary_strong_completeness` imports

---

### Phase 4: Alternative Path - Create FMP-Based Strong Completeness [NOT STARTED]

**Goal**: If Phase 3 reveals too many sorries, create an alternative `strong_completeness_fmp` based directly on `semantic_weak_completeness`

**Tasks**:
- [ ] Create bridge lemma: `validity_implies_semantic_truth` connecting standard validity to `SemanticWorldState` truth
- [ ] Create `weak_completeness_fmp : valid phi -> |- phi` using `semantic_weak_completeness` + bridge
- [ ] Create `finite_strong_completeness_fmp : semantic_consequence Gamma phi -> ContextDerivable Gamma phi` using impChain approach
- [ ] Update `finite_strong_completeness` to use FMP path

**Timing**: 2 hours (if needed)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Add bridge lemmas
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Rewrite using FMP

**Verification**:
- New theorems have no sorry
- Type signatures match existing API

---

### Phase 5: Verify Compactness Becomes Sorry-Free [NOT STARTED]

**Goal**: Confirm compactness theorem is sorry-free once upstream dependencies are fixed

**Tasks**:
- [ ] Verify `Compactness.lean` only depends on `InfinitaryStrongCompleteness` and `soundness`
- [ ] After Phase 1-3, run `lake build Bimodal.Metalogic.Compactness.Compactness`
- [ ] Grep for any remaining sorries in the compactness module

**Timing**: 30 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/Compactness/Compactness.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Compactness.Compactness` succeeds
- `grep "sorry" Theories/Bimodal/Metalogic/Compactness/Compactness.lean` returns nothing

---

### Phase 6: Remove Obsolete Sorried Code [NOT STARTED]

**Goal**: Clean up redundant sorried theorems that are now superseded

**Tasks**:
- [ ] Remove or mark deprecated: `representation_theorem` sorries in `UniversalCanonicalModel.lean` (if not used)
- [ ] Remove `non_provable_satisfiable` and `completeness_contrapositive` sorries
- [ ] Update module documentation to reflect the FMP path as canonical
- [ ] Update `Metalogic/README.md` to document sorry-free architecture

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - Remove unused sorried theorems
- `Theories/Bimodal/Metalogic/README.md` - Update documentation

**Verification**:
- Grep for "sorry" in active metalogic files shows only decidability sorries (4 expected)
- Documentation accurately reflects architecture

---

## Testing & Validation

- [ ] `lake build` succeeds for entire project
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Completeness/` shows no sorries
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Compactness/` shows no sorries
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Soundness.lean` shows no sorries
- [ ] Key theorems compile without sorry:
  - `weak_completeness`
  - `finite_strong_completeness`
  - `infinitary_strong_completeness`
  - `compactness`

## Artifacts & Outputs

- Modified `WeakCompleteness.lean` with imported soundness
- Verified sorry-free `InfinitaryStrongCompleteness.lean`
- Verified sorry-free `Compactness.lean`
- Updated `README.md` documentation
- Possible new bridge lemmas in `SemanticCanonicalModel.lean`

## Rollback/Contingency

If the Representation path sorries prove too difficult:
1. Create new theorems with `_fmp` suffix based on FMP path
2. Keep existing theorems for API compatibility (mark as deprecated with sorry notes)
3. Create task to fully archive Representation module later

If type compatibility issues arise:
1. Create explicit coercion functions
2. Use definitional unfolding where possible
3. Document any API changes needed
