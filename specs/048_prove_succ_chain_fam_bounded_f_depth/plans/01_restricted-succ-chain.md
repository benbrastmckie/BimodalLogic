# Implementation Plan: Task #48

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 7 hours
- **Dependencies**: Task 47 (RestrictedMCS infrastructure - completed)
- **Research Inputs**: specs/048_prove_succ_chain_fam_bounded_f_depth/reports/01_bounded-f-depth.md
- **Artifacts**: plans/01_restricted-succ-chain.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the mathematically unsound claims in `f_nesting_is_bounded` and `p_nesting_is_bounded`. Research revealed that these theorems claim F/P-iteration boundedness for arbitrary MCS, which is false - an MCS can consistently contain all F-iterations without contradiction. The correct approach uses Task 47's `restricted_mcs_F_bounded` which proves boundedness only for RestrictedMCS (MCS bounded by a finite closure).

The implementation refactors the succ_chain_fam construction to use RestrictedMCS with the target formula's closure. This maintains the structure of the completeness proof while ensuring mathematical soundness.

### Research Integration

Key findings from `01_bounded-f-depth.md`:
- Task 47 provides `restricted_mcs_F_bounded` and `restricted_mcs_iter_F_bound`
- The completeness proof naturally has a target formula whose closure can bound the MCS
- Refactoring to use RestrictedMCS requires threading closure info through the construction
- Estimated effort is 6-8 hours for full implementation

## Goals & Non-Goals

**Goals**:
- Replace `f_nesting_is_bounded` with a mathematically sound version using RestrictedMCS
- Replace `p_nesting_is_bounded` with the symmetric P-version for RestrictedMCS
- Remove all sorries related to F/P boundedness
- Maintain completeness theorem structure with the updated construction
- Keep existing proofs working where possible through careful refactoring

**Non-Goals**:
- Proving finite model property (not required for this approach)
- Frame-based semantic arguments (more complex, not needed)
- Restructuring the entire completeness proof (minimal changes preferred)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted Lindenbaum needed for chain construction | Medium | Medium | Use `restricted_lindenbaum` from Task 47 which already exists |
| Closure formula propagation complexity | Low | Low | Clear typing via `RestrictedSerialMCS psi` enforces correctness |
| Completeness proof breaks during refactor | High | Low | Incremental changes with `lake build` after each edit |
| P-boundedness requires additional infrastructure | Medium | Medium | Symmetric to F-boundedness; Task 47 may already have P-version or we adapt |
| Type mismatches between SerialMCS and RestrictedSerialMCS | Medium | Medium | Define coercion functions and update call sites incrementally |

## Implementation Phases

### Phase 1: Define RestrictedSerialMCS and Restricted Chains [PARTIAL]

**Goal**: Create the core type and chain builders that carry closure restriction information.

**Completed**:
- [x] Add `RestrictedSerialMCS` structure to SuccChainFMCS.lean
- [x] Add P-nesting depth infrastructure to SubformulaClosure.lean and CanonicalTaskRelation.lean
- [x] Add `restricted_mcs_P_bounded` to RestrictedMCS.lean (symmetric to F-bounded)

**Not Completed** (requires more extensive restructuring):
- [ ] Define `restricted_forward_chain` with RestrictedMCS elements
- [ ] Define `restricted_backward_chain` with RestrictedMCS elements
- [ ] Prove chain elements are RestrictedMCS

**Reason**: Building restricted chains requires modifying the deferral seed construction
to use `restricted_lindenbaum` instead of standard `set_lindenbaum`. This is invasive.

**Original Tasks**:
- [x] Add `RestrictedSerialMCS` structure to SuccChainFMCS.lean (or new file)
  - Carries `closure_formula : Formula`
  - Contains `world : Set Formula` and proofs for MCS, seriality, and closure restriction
- [ ] Define `restricted_forward_chain : RestrictedSerialMCS psi -> Nat -> Set Formula`
  - Builds forward chain where each MCS is restricted to `closureWithNeg psi`
  - Uses `restricted_lindenbaum` from Task 47 instead of standard Lindenbaum
- [ ] Define `restricted_backward_chain : RestrictedSerialMCS psi -> Nat -> Set Formula`
  - Symmetric backward construction with closure restriction
- [ ] Prove `restricted_forward_chain_mcs`: Each chain element is a RestrictedMCS
- [ ] Prove `restricted_backward_chain_mcs`: Each chain element is a RestrictedMCS
- [ ] Prove `restricted_chain_F_top_preserved`: F_top membership persists through forward chain
- [ ] Prove `restricted_chain_P_top_preserved`: P_top membership persists through backward chain

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Add new types and chain builders

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- No new sorries introduced
- New definitions have clear documentation

---

### Phase 2: Adapt F/P Boundedness Lemmas [COMPLETED]

**Goal**: Replace the sorry-based boundedness theorems with versions that use RestrictedMCS.

**Completed**:
- [x] Define `f_nesting_is_bounded_restricted` using `restricted_mcs_F_bounded`
- [x] Define `f_nesting_boundary_restricted` using `restricted_mcs_F_bounded`
- [x] Add P-boundedness infrastructure:
  - `p_nesting_depth` in SubformulaClosure.lean
  - `max_P_depth_in_closure` in SubformulaClosure.lean
  - `iter_P_p_nesting_depth`, `closure_P_bound`, `iter_P_leaves_closure` in CanonicalTaskRelation.lean
  - `restricted_mcs_P_bounded` in RestrictedMCS.lean
- [x] Define `p_nesting_is_bounded_restricted` using `restricted_mcs_P_bounded`
- [x] Define `p_nesting_boundary_restricted` using `restricted_mcs_P_bounded`
- [x] Mark old `f_nesting_is_bounded` and `p_nesting_is_bounded` as @[deprecated]

**Note**: The old theorems remain with `sorry` for backward compatibility. Callers
should migrate to the restricted versions. Full migration requires Phase 3/4 work.

**Original Tasks**:
- [x] Define `f_nesting_is_bounded_in_closure` using `restricted_mcs_F_bounded` from Task 47
- [x] Update `f_nesting_boundary` to use the new bounded version
- [x] Check if Task 47 has P-version (`restricted_mcs_P_bounded`) or implement it
- [x] Define `p_nesting_is_bounded_in_closure` using restricted P-boundedness
- [x] Update `p_nesting_boundary` to use the new bounded version
- [x] Delete or deprecate the old arbitrary-MCS versions

**Timing**: 1.5 hours (actual: completed)

**Files modified**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` - Added p_nesting_depth, max_P_depth_in_closure
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - Added P-closure bounds
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Added restricted_mcs_P_bounded
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Added restricted versions, deprecated old

**Verification**:
- `lake build` succeeds for modified files
- New restricted boundedness lemmas are sorry-free
- Old versions deprecated with clear migration path

---

### Phase 3: Update Succ-Chain FMCS Construction [NOT STARTED]

**Goal**: Define the restricted FMCS family and prove coherence properties.

**Tasks**:
- [ ] Define `restricted_succ_chain_fam : (psi : Formula) -> RestrictedSerialMCS psi -> Int -> Set Formula`
  - Combines restricted forward and backward chains
  - Each MCS in the family is a RestrictedMCS over psi
- [ ] Prove `restricted_succ_chain_fam_mcs`: Each element is a RestrictedMCS
- [ ] Update `succ_chain_forward_F` to use closure-restricted boundedness
  - Now takes RestrictedSerialMCS and passes closure through to f_nesting_boundary
- [ ] Update `succ_chain_forward_F_neg` similarly
- [ ] Update `succ_chain_backward_P` to use closure-restricted P-boundedness
- [ ] Update `succ_chain_backward_P_neg` similarly
- [ ] Prove `RestrictedSuccChainFMCS` satisfies FMCS conditions
  - Seriality: Each MCS has F_top and P_top
  - F-coherence: Uses updated forward_F lemmas
  - P-coherence: Uses updated backward_P lemmas
- [ ] Add coercion from RestrictedSuccChainFMCS to SuccChainFMCS for compatibility

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Define restricted FMCS

**Verification**:
- `lake build` succeeds
- FMCS coherence proofs use no sorries
- RestrictedSuccChainFMCS has all required properties

---

### Phase 4: Update Completeness Theorem [NOT STARTED]

**Goal**: Modify the completeness proof to use restricted construction with target formula closure.

**Tasks**:
- [ ] Update `not_provable_implies_neg_set_consistent` to produce restricted consistency
  - When building M0 from {neg phi}, M0 should be RestrictedMCS phi
- [ ] Define `target_formula_restricted_lindenbaum`: Given consistent {neg phi}, produce RestrictedMCS phi
  - Uses `restricted_lindenbaum` from Task 47
- [ ] Update SerialMCS construction to produce RestrictedSerialMCS
  - Thread target formula through the construction
- [ ] Update `succ_chain_completeness` to use `restricted_succ_chain_fam`
  - Pass target formula phi as closure parameter
  - Use RestrictedSerialMCS built from {neg phi}
- [ ] Verify succ_chain_truth lemmas still apply (may need minor signature updates)
- [ ] Ensure no new sorries are introduced in completeness chain

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Update completeness proof

**Verification**:
- `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness` succeeds
- Completeness theorem has no new sorries
- Total sorry count in project decreases by 2 (f_nesting and p_nesting)

---

## Testing & Validation

- [ ] `lake build` succeeds with no new errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows 0 F/P boundedness sorries
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` shows no new sorries
- [ ] `lake build Bimodal.Metalogic.Completeness.SuccChainCompleteness` succeeds
- [ ] Documentation updated with rationale for restricted construction
- [ ] Type signatures clearly indicate closure dependencies

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Updated with RestrictedSerialMCS and restricted chains
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - P-boundedness if not already present
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Updated completeness proof
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/01_bounded-f-depth-summary.md` - Implementation summary

## Rollback/Contingency

If implementation proves more invasive than expected:

1. **Partial completion**: Mark task [PARTIAL] with phases completed, continue in new session
2. **Alternative approach**: If refactoring breaks too many downstream proofs, consider:
   - Mark the original sorries with more detailed documentation explaining semantic justification
   - Create a separate "RestrictedCompleteness" module that coexists with original
3. **Blocking condition**: If `restricted_lindenbaum` output doesn't integrate with deferral seed construction, may need to adapt seed construction to work within closure. Document blocker and spawn follow-up task.

## Notes

- Task 47's `restricted_mcs_F_bounded` is the key enabler - verify its exact signature before starting
- The deferral seed construction in SuccExistence.lean may need adjustment to stay within closure
- Consider whether `restricted_lindenbaum` preserves F_top/P_top membership
- The completeness proof's target formula (phi) provides a natural closure bound
