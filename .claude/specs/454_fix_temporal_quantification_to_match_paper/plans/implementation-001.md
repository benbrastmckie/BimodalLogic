# Implementation Plan: Task #454

- **Task**: 454 - Fix temporal quantification to match paper
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .claude/specs/454_fix_temporal_quantification_to_match_paper/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The Lean implementation currently restricts temporal quantification to times in the world history's domain `dom(tau)`, but the JPL paper (lines 896-897, 1869-1870) quantifies over **all times** `y in D` (the entire temporal order). Additionally, the paper's atom semantics (line 892) explicitly checks domain membership inline, returning false for atoms at times outside the domain.

This plan restructures `truth_at` to remove the domain membership parameter from its signature, handle atoms by checking domain inline (returning `False` outside domain), and update temporal operators to quantify over all times `T`. The validity/consequence definitions must also be updated to quantify over all times, not just domain times.

### Research Integration

Key findings from research-001.md:
1. Paper quantifies temporal operators over `y in D` (all times), not `y in dom(tau)`
2. Atom semantics: `M,tau,x |= p_i` iff `x in dom(tau)` AND `tau(x) in V(p_i)`
3. Logical consequence also quantifies over all `x in D`
4. The `box` operator should lose its domain constraint for consistency

## Goals & Non-Goals

**Goals**:
- Remove `ht : tau.domain t` parameter from `truth_at` signature
- Change atom case to check domain membership inline (return False if outside domain)
- Change temporal operators (`all_past`, `all_future`) to quantify over all `T`, not just domain
- Change `box` operator to quantify over all histories (without domain constraint at evaluation time)
- Update `valid` and `semantic_consequence` to quantify over all times `t : T`
- Fix all downstream compilation errors in Bimodal module
- Preserve existing theorem validity (SP1, SP2, MF, TF axioms)

**Non-Goals**:
- Changes to Logos.SubTheories.Explanatory.Truth (Phase 4, separate later work)
- Adding new theorems or features beyond matching the paper
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing TimeShift proofs | High | High | Incremental changes with compilation checks; proofs should be similar without domain threading |
| Soundness proofs need restructuring | High | Medium | Time-shift invariance core insight remains valid; only mechanics change |
| Box operator semantics change impacts | Medium | Medium | Carefully verify MF/TF axiom proofs still work |
| Unexpected type mismatches | Low | Medium | Use lean_diagnostic_messages after each edit |

## Implementation Phases

### Phase 1: Core truth_at Signature Change [NOT STARTED]

**Goal**: Modify the `truth_at` function in `Bimodal.Semantics.Truth` to remove the domain membership parameter and handle atoms/temporal operators correctly.

**Tasks**:
- [ ] Remove `ht : tau.domain t` parameter from `truth_at` signature
- [ ] Change atom case to: `if ht : tau.domain t then M.valuation (tau.states t ht) p else False`
- [ ] Change `all_past` case to: `forall (s : T), s < t -> truth_at M tau s phi`
- [ ] Change `all_future` case to: `forall (s : T), t < s -> truth_at M tau s phi`
- [ ] Change `box` case to: `forall (sigma : WorldHistory F), truth_at M sigma t phi` (remove hs parameter)
- [ ] Update `truth_at` type signature in docstring

**Timing**: 1.5 hours

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` - Lines 95-106 (truth_at definition)

**Verification**:
- Run `lean_diagnostic_messages` to see compilation errors (expected: many downstream errors)
- Verify new definition matches paper's specification exactly

---

### Phase 2: Truth.lean Helper Theorems [NOT STARTED]

**Goal**: Update all helper theorems and lemmas in Truth.lean that depend on the old signature.

**Tasks**:
- [ ] Update `Truth.bot_false` - remove ht parameter
- [ ] Update `Truth.imp_iff` - remove ht parameter
- [ ] Update `Truth.atom_iff` - change to reflect new domain check semantics
- [ ] Update `Truth.box_iff` - remove hs parameter from quantifier
- [ ] Update `Truth.past_iff` - change to reflect all-times quantification
- [ ] Update `Truth.future_iff` - change to reflect all-times quantification
- [ ] Update `TimeShift.truth_proof_irrel` - signature and proof
- [ ] Update `TimeShift.truth_history_eq` - signature and proof
- [ ] Update `TimeShift.truth_double_shift_cancel` - signature and proof
- [ ] Update `TimeShift.time_shift_preserves_truth` - signature and proof
- [ ] Update `TimeShift.exists_shifted_history` - signature and proof

**Timing**: 2 hours

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` - Lines 107-585

**Verification**:
- Run `lean_diagnostic_messages` on Truth.lean - should compile cleanly
- Check `lean_goal` at key proof points to verify proof state

---

### Phase 3: Validity Definitions Update [NOT STARTED]

**Goal**: Update validity and semantic consequence definitions to quantify over all times.

**Tasks**:
- [ ] Update `valid` definition to: `forall ... (t : T), truth_at M tau t phi` (remove ht parameter)
- [ ] Update `semantic_consequence` definition similarly
- [ ] Update `satisfiable` definition similarly
- [ ] Update `satisfiable_abs` definition
- [ ] Update `Validity.valid_iff_empty_consequence` proof
- [ ] Update `Validity.consequence_monotone` proof
- [ ] Update `Validity.valid_consequence` proof
- [ ] Update `Validity.consequence_of_member` proof
- [ ] Update `Validity.unsatisfiable_implies_all` proof
- [ ] Update `Validity.unsatisfiable_implies_all_fixed` proof

**Timing**: 1 hour

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean` - All definitions and theorems

**Verification**:
- Run `lean_diagnostic_messages` on Validity.lean - should compile cleanly
- Verify definitions match paper's logical consequence (line 924, 2272-2273)

---

### Phase 4: Metalogic Soundness Proofs [NOT STARTED]

**Goal**: Fix soundness lemmas and main soundness theorem with new signatures.

**Tasks**:
- [ ] Update SoundnessLemmas.lean `is_valid` local definition
- [ ] Update all `swap_axiom_*_valid` lemmas for new signature
- [ ] Update all `axiom_*_valid` private theorems
- [ ] Update `axiom_swap_valid` and `axiom_locally_valid`
- [ ] Update rule preservation lemmas (`mp_preserves_swap_valid`, etc.)
- [ ] Update `derivable_implies_valid_and_swap_valid` proof
- [ ] Update Soundness.lean axiom validity proofs (prop_k_valid, modal_t_valid, etc.)
- [ ] Update main `soundness` theorem proof
- [ ] Verify MF and TF axiom proofs still work with time-shift

**Timing**: 1 hour

**Files to modify**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean`

**Verification**:
- Run `lean_diagnostic_messages` on both files - should compile cleanly
- Run `lake build Bimodal.Metalogic.Soundness` to verify full compilation

---

### Phase 5: Perpetuity and Remaining Files [NOT STARTED]

**Goal**: Fix any remaining downstream files in the Bimodal module.

**Tasks**:
- [ ] Check and fix `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Perpetuity/Helpers.lean`
- [ ] Check and fix `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Perpetuity/Bridge.lean`
- [ ] Check and fix `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/Perpetuity/Principles.lean`
- [ ] Check and fix `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability.lean` if affected
- [ ] Check and fix `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean` if affected
- [ ] Run full `lake build` to verify no remaining errors

**Timing**: 0.5 hours

**Files to modify**:
- Perpetuity directory files
- Any other files with compilation errors

**Verification**:
- Run `lake build` - should complete without errors
- Run `lean_diagnostic_messages` on any files that had errors

## Testing & Validation

- [ ] `lake build` completes without errors for entire Bimodal module
- [ ] Verify `truth_at` definition matches paper's def:BL-semantics (lines 1857-1872)
- [ ] Verify `valid` and `semantic_consequence` match paper's logical consequence (lines 924, 2272-2273)
- [ ] Verify atom semantics matches paper line 892 (domain check inline)
- [ ] Verify temporal operator semantics match lines 896-897, 1869-1870 (quantify over all D)
- [ ] MF axiom (`box phi -> box (future phi)`) still proven valid
- [ ] TF axiom (`box phi -> future (box phi)`) still proven valid
- [ ] Soundness theorem compiles and proves correctly

## Artifacts & Outputs

- Modified `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- Modified `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`
- Modified `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
- Modified `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean`
- Potentially modified Perpetuity theorem files
- `.claude/specs/454_fix_temporal_quantification_to_match_paper/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails or causes unforeseen issues:
1. Use `git checkout` to restore original files
2. The changes are isolated to Bimodal.Semantics and Bimodal.Metalogic modules
3. No changes to Logos module in this plan (reserved for future task)
4. All original proofs are preserved in git history
