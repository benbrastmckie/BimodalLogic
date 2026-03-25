# Implementation Plan: Task #55 (v5)

- **Task**: 55 - Prove SuccChain Temporal Coherence Directly
- **Status**: [PARTIAL]
- **Effort**: 2.5 hours
- **Dependencies**: None (supersedes tasks 36, 37, 53)
- **Research Inputs**: reports/13_team-research.md
- **Artifacts**: plans/05_canonical-construction-integration.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Supersedes**: plans/04_simplified-resolving-chain.md (blocked at Phase 3 by sorry chain)

## Overview

Plan v5 takes a fundamentally different approach from v1-v4. Rather than attempting to fix the mathematically impossible `f_nesting_is_bounded` or design workarounds, we **integrate the existing sorry-free canonical construction** into the `construct_bfmcs` function.

The research report (13_team-research.md) conclusively established:
1. `f_nesting_is_bounded` is **mathematically FALSE** for arbitrary MCS
2. Bundle-level coherence **breaks `backward_G`** (not viable)
3. The canonical construction (`CanonicalFrame.lean`, `CanonicalConstruction.lean`) **already has sorry-free `forward_F`**

### Key Architecture Insight

Two separate completeness paths exist in the codebase:

| Path | Files | Status | Used By |
|------|-------|--------|---------|
| **Canonical Construction** | `CanonicalFrame.lean`, `CanonicalConstruction.lean` | **Sorry-free** | `canonical_truth_lemma`, `shifted_truth_lemma` |
| **SuccChain Construction** | `SuccChainFMCS.lean`, `UltrafilterChain.lean` | **Has sorry chain** | `construct_bfmcs`, `boxClassFamilies_temporally_coherent` |

The canonical construction uses `ExistsTask M W := g_content M subseteq W`, which trivializes `forward_F` via per-obligation Lindenbaum witnesses. The SuccChain construction uses deterministic chains, which require `f_nesting_is_bounded` (impossible to prove).

**Resolution Strategy**: Replace the body of `construct_bfmcs` to delegate to canonical construction, or restructure `boxClassFamilies` to use canonical coherence.

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry chain in `construct_bfmcs`
- Use the proven canonical construction infrastructure
- Mark `f_nesting_is_bounded` and related theorems as FALSE
- Achieve sorry-free temporal coherence for the BFMCS

**Non-Goals**:
- Proving `f_nesting_is_bounded` (mathematically impossible)
- Fixing the SuccChain-based `succ_chain_forward_F` (wrong architecture)
- Preserving the SuccChain construction path (deprecated)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Type mismatch between canonical and construct_bfmcs | High | Medium | Phase 1 type analysis; adapt signatures if needed |
| BoxClassFamilies incompatible with canonical families | Medium | Low | Bridge lemma or restructure families definition |
| Truth lemma breaks with restructured BFMCS | High | Low | Canonical truth lemma already proven; verify integration |

## Implementation Phases

### Phase 1: Type Compatibility Analysis [COMPLETED]

**Goal**: Determine if `construct_bfmcs` can directly delegate to canonical construction.

**Tasks**:
- [ ] Read `construct_bfmcs` signature (UltrafilterChain.lean:1810-1813):
  ```lean
  noncomputable def construct_bfmcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent)
         (fam : FMCS Int) (hfam : fam in B.families) (t : Int),
         M = fam.mcs t
  ```
- [ ] Check canonical construction output types:
  - `canonical_truth_lemma` requires `BFMCS Int` with `temporally_coherent`
  - `canonical_forward_F` provides `ExistsTask M W` witnesses
- [ ] Identify type gaps:
  - Does canonical construction provide a BFMCS directly?
  - Does it provide an FMCS containing the input MCS?
- [ ] Document compatibility findings

**Timing**: 30 minutes

**Files to read**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (lines 1807-1835)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (main definitions)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` (ExistsTask, forward_F)

**Verification**:
- Type analysis document completed
- Decision on Option A (delegation) vs Option B (restructure) made

---

### Phase 2: Implement Canonical-Based BFMCS [BLOCKED]

**Goal**: Replace `boxClassFamilies_temporally_coherent` with canonical construction.

**Option A: Direct Delegation** (if types compatible)
- [ ] Create `canonical_bfmcs` function that builds BFMCS using canonical coherence:
  ```lean
  noncomputable def canonical_bfmcs (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
      Sigma' (B : BFMCS Int) (h_tc : B.temporally_coherent)
         (fam : FMCS Int) (hfam : fam in B.families) (t : Int),
         M = fam.mcs t
  ```
- [ ] The key insight: temporal coherence via `canonical_forward_F` instead of `succ_chain_forward_F`
- [ ] Replace `construct_bfmcs` body with delegation to `canonical_bfmcs`

**Option B: Restructure boxClassFamilies** (if types incompatible)
- [ ] Define `CanonicalCoherentFMCS` that uses `ExistsTask` for temporal accessibility
- [ ] Show `CanonicalCoherentFMCS` provides `forward_F` and `backward_P` via `canonical_forward_F`/`canonical_backward_P`
- [ ] Replace `boxClassFamilies` temporal coherence proof

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (construct_bfmcs, boxClassFamilies_temporally_coherent)

**Verification**:
- `lake build` succeeds
- No sorry in `construct_bfmcs` or `boxClassFamilies_temporally_coherent`

---

### Phase 3: Deprecate False Theorems [COMPLETED]

**Goal**: Mark mathematically false theorems as deprecated with clear documentation.

**Tasks**:
- [ ] Add deprecation annotations to:
  - `f_nesting_is_bounded` (SuccChainFMCS.lean) - FALSE for arbitrary MCS
  - `f_nesting_boundary` - depends on false theorem
  - `p_nesting_is_bounded` - symmetric FALSE theorem
  - `p_nesting_boundary` - depends on false theorem
  - `temporal_witness_f_step_general` (if present) - mathematically false

- [ ] Add module documentation explaining:
  ```lean
  /-!
  ## Deprecated Theorems (Mathematically False)

  The following theorems are marked deprecated because they are
  **mathematically FALSE** for arbitrary maximal consistent sets:

  - `f_nesting_is_bounded`: An MCS can contain {F^n(p) | n in Nat} without bound.
    Counterexample: The set is finitely consistent and extends to MCS M_inf
    satisfiable on Z with successor where point 0 satisfies all F^n(p).

  - `p_nesting_is_bounded`: Symmetric argument for past operators.

  See task #55 research reports for detailed analysis.
  -/
  ```

- [ ] Verify deprecated theorems are not used in any active proof path

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (deprecation annotations)
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (documentation)

**Verification**:
- `lake build` succeeds
- Deprecated theorems have `@[deprecated]` annotation
- No active proofs depend on deprecated theorems

---

### Phase 4: Verification and Cleanup [COMPLETED]

**Goal**: Verify the construction is sorry-free and document the architecture.

**Tasks**:
- [ ] Run `#print axioms construct_bfmcs` and verify no sorry-related axioms
- [ ] Run `lake build` and confirm no errors
- [ ] Grep for remaining sorries in the modified files
- [ ] Add architecture documentation explaining the canonical approach
- [ ] Update module-level comments to reflect the resolved architecture

**Timing**: 30 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

**Verification**:
- `#print axioms construct_bfmcs` shows only standard axioms (propext, Quot.sound, Classical.choice)
- No `sorry` in active proof paths
- Documentation is complete

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `#print axioms construct_bfmcs` shows no sorry-related axioms
- [ ] `#print axioms canonical_truth_lemma` shows no sorry-related axioms
- [ ] Deprecated theorems are properly annotated
- [ ] No grep hits for `sorry` in modified regions

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`:
  - Modified `construct_bfmcs` (sorry-free via canonical construction)
  - Modified `boxClassFamilies_temporally_coherent` (or replaced)

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`:
  - Deprecated `f_nesting_is_bounded`, `p_nesting_is_bounded`
  - Documentation explaining deprecation

## Rollback/Contingency

**If Phase 2 type analysis shows incompatibility**:
- Document the exact type mismatch
- Consider Option C: Create adapter layer between canonical and SuccChain types
- This is a valid outcome that advances understanding even if not fully resolving the sorry

**If canonical construction doesn't directly apply**:
- The canonical construction IS sorry-free and IS used by `canonical_truth_lemma`
- The issue is `construct_bfmcs` specifically using SuccChain architecture
- Worst case: document that `construct_bfmcs` should be deprecated in favor of canonical path

**Git safety**: Commit after each phase. All changes are additive (new function) or annotation-only (deprecation) until Phase 2 integration.

## Comparison: v4 vs v5

| Aspect | v4 | v5 |
|--------|----|----|
| Approach | Fix resolving seed | Use canonical construction |
| f_nesting dependency | Tried to bypass | Completely eliminated |
| Key insight | Per-obligation architecture | Canonical already sorry-free |
| Risk level | High (blocked at Phase 3) | Low (proven infrastructure) |
| Estimated effort | 3 hours (blocked) | 2.5 hours |
| Architecture change | Minor (seed simplification) | Major (construction path switch) |
