# Implementation Plan: DRM Negation Completeness Fix

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (standalone fix based on research)
- **Research Inputs**: reports/22_team-research.md
- **Artifacts**: plans/12_drm-negation-completeness.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan addresses the remaining sorries in SuccChainFMCS.lean by proving a DRM negation completeness lemma. Research report #22 established that the Lindenbaum Succ-lifting approach (Plan v11) is unprovable, but identified a simpler fix: prove `drm_negation_complete_within_dc` which, combined with existing `neg_FF_implies_GG_neg_in_mcs`, closes the critical sorries. Only 2 sorries are on the critical path (lines 2360, 3012); the 4 primed theorem sorries are dead code and can be deprecated.

### Research Integration

From reports/22_team-research.md:
- **Key finding**: Lindenbaum Succ lifting is fatal; do NOT pursue Plan v11 Phase 1
- **Solution**: Prove DRM negation completeness for formulas where both psi and psi.neg are in deferralClosure
- **Prerequisite verified**: closureWithNeg is closed under negation, so if FF(psi) is in deferralClosure, so is neg(FF(psi))
- **Critical path**: Only lines 2360 and 3012 block `restricted_bounded_witness`
- **Dead code identified**: Lines 3097, 3675, 3903, 3915 (primed theorems not on critical path)

## Goals & Non-Goals

**Goals**:
- Prove `drm_negation_complete_within_dc` lemma in RestrictedMCS.lean
- Fix critical sorries at lines 2360 and 3012 in SuccChainFMCS.lean
- Deprecate or remove dead code (primed theorems)
- Handle boundary cases (FF not in dc) appropriately
- Achieve zero-sorry build for task 48 scope

**Non-Goals**:
- Proving Lindenbaum Succ lifting (confirmed unprovable)
- Modifying the restricted_forward_chain construction
- Changing the DeferralRestrictedMCS definition
- Proving the deprecated f_nesting_is_bounded / p_nesting_is_bounded

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DRM negation completeness harder than expected | H | L | Proof strategy from research is validated; similar to existing restricted_mcs_negation_complete |
| Boundary case (FF not in dc) needs restructuring | M | M | Research indicates calling code handles this via induction; verify before marking unreachable |
| neg_FF_implies_GG_neg_in_mcs requires adaptation | M | L | Existing lemma works on MCS; DRM is MCS-like within deferralClosure |
| Primed theorems have hidden callers | L | L | Grep for usages before deprecating |

## Implementation Phases

### Phase 1: Prove DRM Negation Completeness [NOT STARTED]

**Goal**: Prove the key lemma that enables closing the critical sorries

**Tasks**:
- [ ] Add `drm_negation_complete_within_dc` lemma to RestrictedMCS.lean
- [ ] Verify prerequisite: `neg(FF(psi)) in deferralClosure` when `FF(psi) in deferralClosure`
- [ ] Verify the argument structure: insert psi inconsistent + psi.neg in dc implies psi.neg in u

**Lemma signature**:
```lean
lemma drm_negation_complete_within_dc (phi psi : Formula)
    (u : DeferralRestrictedMCS phi)
    (h_in_dc : psi ∈ deferralClosure phi)
    (h_neg_in_dc : psi.neg ∈ deferralClosure phi)
    (h_not_in_u : psi ∉ u.world) :
    psi.neg ∈ u.world
```

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - Add new lemma after existing `deferral_restricted_mcs_negation_complete`

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Core.RestrictedMCS` succeeds
- New lemma has no sorry

---

### Phase 2: Fix Critical Sorries [NOT STARTED]

**Goal**: Replace sorries at lines 2360 and 3012 with proofs using the new lemma

**Tasks**:
- [ ] Fix sorry at line 2360 in `restricted_single_step_forcing` (FF in dc case)
- [ ] Fix sorry at line 3012 in `restricted_succ_propagates_F_not` (FF in dc case)
- [ ] Apply `drm_negation_complete_within_dc` to get `neg(FF(psi)) in chain(k)`
- [ ] Use existing `neg_FF_implies_GG_neg_in_mcs` to derive `GG(neg psi) in chain(k)`
- [ ] Complete the proof following the unrestricted case pattern

**Proof outline for each sorry**:
1. `h_FF_dc : FF(psi) in deferralClosure`
2. `neg(FF(psi)) in deferralClosure` (prerequisite lemma or inline)
3. `neg(FF(psi)) in u` (by `drm_negation_complete_within_dc` since `FF(psi) not in u`)
4. `GG(neg psi) in u` (by `neg_FF_implies_GG_neg_in_mcs`)
5. `G(neg psi) in g_content(u)`
6. `G(neg psi) in v` (by g_persistence)
7. `F(psi) not in v` (G(neg psi) and F(psi) are negations in MCS)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fix sorries at lines 2360, 3012

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` shows reduced sorry count
- Lines 2360 and 3012 no longer have sorry

---

### Phase 3: Deprecate Dead Code [NOT STARTED]

**Goal**: Remove or mark as deprecated the primed theorems that are not on the critical path

**Tasks**:
- [ ] Grep for usages of `restricted_succ_propagates_F_not'` and `restricted_single_step_forcing'`
- [ ] Verify they are only called by `restricted_bounded_witness'` which is also dead
- [ ] Add deprecation comments to primed theorems (lines 3052-3115, 3600-3920)
- [ ] Optionally: Remove entirely if no external callers

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Deprecate/remove primed theorems

**Verification**:
- Build succeeds (no new errors from deprecation)
- grep confirms no active callers

---

### Phase 4: Handle Boundary Cases [NOT STARTED]

**Goal**: Address sorries at lines 2980 and 3026 (FF not in deferralClosure case)

**Tasks**:
- [ ] Analyze calling context in `restricted_bounded_witness` (lines 4007-4015)
- [ ] Determine if boundary case is reachable from calling code
- [ ] If unreachable: Add `False.elim` with proof that caller provides `FF in dc`
- [ ] If reachable: Document as known limitation with clear TODO

**Research guidance**: Teammate A indicated "this is handled by the induction in restricted_bounded_witness". Verify this claim.

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Handle lines 2980, 3026

**Verification**:
- Sorries reduced or replaced with clear documentation
- Build succeeds

---

### Phase 5: Build Verification and Cleanup [NOT STARTED]

**Goal**: Final build verification and summary

**Tasks**:
- [ ] Run full `lake build` on the module
- [ ] Count remaining sorries with `grep -n sorry`
- [ ] Verify only deprecated sorries remain (lines 736, 971)
- [ ] Create execution summary

**Timing**: 15 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` succeeds
- Only 2 deprecated sorries remain (f_nesting_is_bounded, p_nesting_is_bounded)
- `restricted_bounded_witness` has no sorry in its transitive closure

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Core.RestrictedMCS` - Phase 1 verification
- [ ] `lake build Theories.Bimodal.Metalogic.Bundle.SuccChainFMCS` - Full module build
- [ ] `grep -n sorry SuccChainFMCS.lean | wc -l` - Count sorries (target: 2 deprecated only)
- [ ] `lean_verify` on `restricted_bounded_witness` - No sorry in proof

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` - New `drm_negation_complete_within_dc` lemma
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Fixed critical sorries, deprecated dead code
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/13_drm-negation-summary.md` - Execution summary

## Rollback/Contingency

If Phase 1 lemma proves harder than expected:
1. Review proof of existing `deferral_restricted_mcs_negation_complete` for guidance
2. Check if additional infrastructure lemmas about deferralClosure negation closure exist
3. Consider alternative formulation with explicit `neg in dc` prerequisite

If boundary cases (Phase 4) are genuinely reachable:
1. Document limitation with clear explanation
2. Mark as future work requiring theorem signature changes
3. Ensure critical path is still complete (bounded_witness works)
