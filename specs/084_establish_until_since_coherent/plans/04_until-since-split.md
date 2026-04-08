# Implementation Plan: Split Until/Since Coherence (v3)

- **Task**: 84 - Establish until_since_coherent for chain constructions
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (builds on completed Phase 1 and partial Phase 2 from plan v2)
- **Research Inputs**: specs/084_establish_until_since_coherent/reports/04_team-research.md
- **Artifacts**: plans/04_until-since-split.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Research across 4 rounds (including team research with 3 teammates) has conclusively shown that forward Until/Since coherence is blocked by a fundamental incompatibility between Lindenbaum extension freedom and Until formula persistence through chain steps. This plan accepts that finding and maximizes the sorry-free surface by: (1) splitting the `until_since_coherent` predicate into backward and forward halves, (2) refactoring the truth lemma and completeness theorems to accept split coherence, (3) closing backward coherence for all three construction paths, and (4) scoping the remaining forward sorry precisely. The result narrows 3 opaque `sorry` sites into 3 precisely documented forward-only `sorry` sites, with all backward Until/Since proved.

### Research Integration

Key findings from report 04 (team research):
- Forward Until/Since is blocked by G-lift incompatibility in enriched seed consistency (all 3 teammates, 95% confidence)
- All 7 alternative approaches converge on the same fundamental obstacle
- Backward Until/Since has 6 sorry-free parameterized theorems ready for assembly
- The completeness proof's backward direction (semantic to syntactic) uses backward Until coherence
- Bundle-level cross-family workaround blocked by Truth.lean:128 same-family semantics

## Goals & Non-Goals

**Goals**:
- Split `BFMCS.until_since_coherent` into `backward_until_since_coherent` and `forward_until_since_coherent`
- Refactor truth lemma infrastructure to accept split coherence parameters
- Close backward coherence sorry-free for all three construction paths (basic, restricted, dovetailed)
- Reduce the sorry surface from 3 opaque `sorry` to 3 precisely scoped forward-only `sorry`
- Document the forward blocker inline for future researchers

**Non-Goals**:
- Closing forward Until/Since coherence (proven blocked by research)
- Modifying the chain construction algorithms
- Changing the semantics of Until evaluation (Truth.lean)
- Investigating restricted forward Until (medium-term research direction)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Step transfer hypothesis not dischargeable for any construction | H | M | Use sorry for step transfer; still narrows sorry surface vs. current state |
| Refactoring truth lemma breaks downstream proofs | M | L | Incremental refactoring with `lake build` after each change |
| Type signature changes cascade through many files | M | M | Change predicate definition first, fix compilation errors systematically |
| Backward coherence needs step transfer from chain constructions | H | M | If step transfer is unavailable, use sorry-parameterized backward; still better than monolithic sorry |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Split the Predicate Definition [NOT STARTED]

**Goal**: Define `backward_until_since_coherent` and `forward_until_since_coherent` as separate predicates in TemporalCoherence.lean, and provide a recombination lemma showing their conjunction equals the original.

**Tasks**:
- [ ] Define `BFMCS.backward_until_since_coherent` (conjuncts 2 and 4 of the original)
- [ ] Define `BFMCS.forward_until_since_coherent` (conjuncts 1 and 3 of the original)
- [ ] Prove `split_until_since_coherent`: backward + forward implies original `until_since_coherent`
- [ ] Prove `until_since_coherent_backward`: original implies backward half
- [ ] Prove `until_since_coherent_forward`: original implies forward half
- [ ] Verify with `lake build`

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Add split predicate definitions and equivalence lemmas after line 479

**Verification**:
- `lake build` succeeds
- New definitions type-check
- Equivalence lemma compiles (backward + forward iff original)

---

### Phase 2: Refactor Truth Lemma to Accept Split Coherence [NOT STARTED]

**Goal**: Modify the parametric truth lemma, shifted truth lemma, and restricted shifted truth lemma to accept backward and forward coherence as separate parameters, threading them to the appropriate Until/Since cases.

**Tasks**:
- [ ] Modify `parametric_truth_lemma_core` in ParametricTruthLemma.lean to take `h_buc : B.backward_until_since_coherent` and `h_fuc : B.forward_until_since_coherent` instead of `h_uc : B.until_since_coherent`
- [ ] Update the `untl` case: forward direction uses `h_fuc`, backward direction uses `h_buc`
- [ ] Update the `snce` case: forward direction uses `h_fuc`, backward direction uses `h_buc`
- [ ] Update `shifted_truth_lemma` in CanonicalConstruction.lean to accept split parameters
- [ ] Update `restricted_shifted_truth_lemma` in CanonicalConstruction.lean to accept split parameters
- [ ] Provide wrapper versions that accept the original `until_since_coherent` and destructure it, preserving backward compatibility for callers not yet updated
- [ ] Fix all downstream compilation errors in BaseCompleteness.lean, DiscreteCompleteness.lean, DenseCompleteness.lean, ParametricRepresentation.lean
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Split h_uc into h_buc + h_fuc in core lemma (lines 221, 365-396)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Update shifted_truth_lemma signatures (lines 493, 677, 856)
- `Theories/Bimodal/Metalogic/BaseCompleteness.lean` - Update call sites (line 149, 164)
- `Theories/Bimodal/Metalogic/DiscreteCompleteness.lean` - Update call sites (line 163)
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Update call sites (lines 118, 133)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` - Update call sites (lines 186, 207, 257, 290)

**Verification**:
- `lake build` succeeds
- All truth lemma variants compile with split parameters
- Wrapper versions preserve backward compatibility

---

### Phase 3: Close Backward Coherence for All Construction Paths [NOT STARTED]

**Goal**: Provide sorry-free `backward_until_since_coherent` for all three BFMCS construction paths in Completeness.lean. This requires either discharging the step transfer hypothesis or using the existing parameterized backward theorems from UntilSinceCoherence.lean.

**Tasks**:
- [ ] Investigate step transfer availability for `construct_bfmcs_bundle` families (g_content-based chains): check whether `(phi U psi) in fam.mcs (r+1) /\ phi in fam.mcs r -> (phi U psi) in fam.mcs r` holds via g_content or h_content properties
- [ ] Investigate step transfer availability for `construct_dovetailed_bfmcs_bundle` families (dovetailed chains): check whether DovetailedFMCS chain properties give step transfer
- [ ] If step transfer is available: prove `backward_until_since_coherent` for each construction path using `backward_until_coherent` and `backward_since_coherent` from UntilSinceCoherence.lean
- [ ] If step transfer is NOT available: use `sorry` for step transfer but document precisely what is needed; this still narrows the sorry from "all 4 conjuncts" to "step transfer only"
- [ ] Prove `construct_bfmcs_backward_uc` for basic bundle path
- [ ] Prove `dovetailed_bfmcs_backward_uc` for dovetailed bundle path
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` - Add construction-specific backward coherence theorems
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Wire backward coherence into completeness proofs

**Verification**:
- `lake build` succeeds
- Backward coherence theorems compile (sorry-free or with precisely scoped sorry for step transfer)
- Each completeness theorem has backward coherence provided

---

### Phase 4: Replace Monolithic Sorry with Split Sorry [NOT STARTED]

**Goal**: Update the three completeness theorems to use split coherence, providing backward coherence from Phase 3 and leaving forward coherence as a precisely scoped, documented sorry.

**Tasks**:
- [ ] In `bundle_validity_implies_provability` (line 322): replace `have h_uc : B.until_since_coherent := sorry` with separate `have h_buc` (proved) and `have h_fuc` (sorry with docstring)
- [ ] In `restricted_bundle_validity_implies_provability` (line 356): same split
- [ ] In `dovetailed_bundle_validity_implies_provability` (line 450): same split
- [ ] Add docstring comments at each forward sorry explaining: (a) what it means, (b) why it is blocked, (c) what research direction might resolve it
- [ ] Update the shifted_truth_lemma calls to pass split parameters
- [ ] Verify with `lake build`
- [ ] Run `grep -c sorry` on Completeness.lean to confirm sorry count

**Timing**: 45 minutes

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Replace 3 monolithic sorry sites with split backward (proved) + forward (sorry with documentation)

**Verification**:
- `lake build` succeeds
- Each completeness theorem has `h_buc` (sorry-free or with narrow step-transfer sorry) and `h_fuc` (sorry)
- Forward sorry sites have inline documentation of the blocker
- Overall sorry count in Completeness.lean is the same or lower, but each sorry is precisely scoped

## Testing & Validation

- [ ] `lake build` succeeds after all phases
- [ ] All existing tests continue to pass
- [ ] No new `sorry` introduced beyond the scoped forward coherence sites
- [ ] `grep sorry Theories/Bimodal/FrameConditions/Completeness.lean` shows only forward_until_since_coherent sorry sites
- [ ] Backward coherence theorems are sorry-free (or have only step-transfer sorry, which is strictly narrower)
- [ ] Truth lemma accepts split parameters correctly
- [ ] Wrapper versions maintain backward compatibility for callers outside Completeness.lean

## Artifacts & Outputs

- `plans/04_until-since-split.md` (this file)
- Modified `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` - Split predicate definitions
- Modified `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - Split truth lemma
- Modified `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` - Split shifted truth lemma
- Modified `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean` - Construction-specific backward coherence
- Modified `Theories/Bimodal/FrameConditions/Completeness.lean` - Split sorry sites with documentation
- Multiple downstream files with updated call sites

## Rollback/Contingency

All changes are additive definitions and signature extensions. If the refactoring proves too disruptive:
1. Revert to the current branch state (`git stash` or `git checkout -- .`)
2. The existing 3 monolithic sorry sites remain functional
3. Backward coherence theorems in UntilSinceCoherence.lean are independent and can be preserved even if the split is reverted

If step transfer is unavailable for any construction path, the plan degrades gracefully: backward coherence gets a sorry for step transfer (still much narrower than the current monolithic sorry), and forward coherence remains sorry.

## Future Work (from research recommendations)

These are NOT in scope for this plan but are documented for future reference:
1. **Restricted forward Until**: Investigate restricting forward Until to the deferral closure to leverage sorry-free `restricted_forward_F` from SuccChainFMCS
2. **Simultaneous well-founded induction**: Prove forward_F and forward_Until simultaneously by induction on formula complexity
3. **Quasimodel replacement**: Replace Lindenbaum chain construction with constraint-satisfaction approach (~2000 LOC)
