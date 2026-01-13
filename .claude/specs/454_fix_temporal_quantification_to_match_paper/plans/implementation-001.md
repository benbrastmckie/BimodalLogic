# Implementation Plan: Task #454

- **Task**: 454 - Fix temporal quantification to match paper
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .claude/specs/454_fix_temporal_quantification_to_match_paper/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

The Lean implementation currently restricts temporal quantification to times within the world history's domain (`tau.domain`), while the JPL paper quantifies over ALL times in the temporal order D. This discrepancy affects the semantics of the Past (H) and Future (G) operators, as well as the definitions of validity and semantic consequence.

The fix requires removing the domain membership proof parameter from `truth_at` and handling atoms by checking domain membership inline (atoms are false outside the domain). Temporal operators will quantify over all times, and validity definitions will be updated similarly.

### Research Integration

Key findings from research-001.md:
- Paper lines 896-897 and 1869-1870: Temporal operators quantify over all y in D (not tau.domain)
- Paper line 892: Atoms check domain membership inline (`x in dom(tau) and tau(x) in V(p)`)
- Paper line 924 and 2272-2273: Logical consequence quantifies over all times x in D
- The chess game example (lines 899-919) shows why times outside domain matter semantically

## Goals & Non-Goals

**Goals**:
- Modify `truth_at` to remove domain membership proof parameter
- Handle atoms by checking domain membership inline with decidable if
- Change temporal operators to quantify over all times T
- Update validity/semantic_consequence to quantify over all times
- Fix all downstream compilation errors
- Maintain correct semantics for all existing theorems

**Non-Goals**:
- Changing the underlying `WorldHistory` structure
- Modifying the proof system (axioms, derivation rules)
- Performance optimization beyond necessary changes

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing proofs (Soundness, TimeShift) | High | High | Incremental changes with `lake build` after each file |
| Box operator domain change complexity | Medium | Medium | Careful analysis of box semantics; may need to keep domain check |
| TimeShift proofs need restructuring | Medium | Medium | Core insight (time-shift preserves truth) remains valid; only mechanics change |
| Perpetuity principles may need updates | Medium | Low | These use derivability, not direct truth_at; should be unaffected |
| Decidability of domain membership | Low | Low | WorldHistory.domain is already decidable via Interval |

## Implementation Phases

### Phase 1: Core Truth Definition [NOT STARTED]

**Goal**: Modify `truth_at` signature and atom handling in Bimodal.Semantics.Truth

**Tasks**:
- [ ] Change `truth_at` signature to remove `ht : tau.domain t` parameter
- [ ] Modify atom case to use `if ht : tau.domain t then M.valuation (tau.states t ht) p else False`
- [ ] Modify temporal operators to quantify over all `s : T` without domain constraint
- [ ] Update box operator (analyze whether domain check should remain for the quantified history)
- [ ] Fix all simple lemmas in Truth namespace (bot_false, imp_iff, atom_iff, box_iff, past_iff, future_iff)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - Core `truth_at` definition and basic lemmas

**Verification**:
- File compiles without errors
- `lake build Bimodal.Semantics.Truth` succeeds

---

### Phase 2: TimeShift Theorems [NOT STARTED]

**Goal**: Update TimeShift theorems to work with new signature

**Tasks**:
- [ ] Update `truth_proof_irrel` - may be simplified or removed (no longer have proof parameter)
- [ ] Update `truth_history_eq` - may be simplified
- [ ] Update `truth_double_shift_cancel` - core logic should remain similar
- [ ] Update `time_shift_preserves_truth` - the key theorem; proof structure should be similar but without domain proof threading
- [ ] Update `exists_shifted_history` - corollary, should follow from above

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - TimeShift namespace

**Verification**:
- All TimeShift theorems compile
- `lake build Bimodal.Semantics.Truth` succeeds

---

### Phase 3: Validity Definitions [NOT STARTED]

**Goal**: Update validity and semantic consequence to quantify over all times

**Tasks**:
- [ ] Update `valid` definition to use `forall (t : T)` instead of `forall (t : T) (ht : tau.domain t)`
- [ ] Update `semantic_consequence` similarly
- [ ] Update `satisfiable` definition similarly
- [ ] Update `satisfiable_abs` if needed
- [ ] Fix all Validity namespace lemmas (valid_iff_empty_consequence, consequence_monotone, etc.)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Semantics/Validity.lean` - All validity-related definitions

**Verification**:
- File compiles without errors
- `lake build Bimodal.Semantics.Validity` succeeds

---

### Phase 4: SoundnessLemmas Updates [NOT STARTED]

**Goal**: Fix SoundnessLemmas.lean to work with new truth_at signature

**Tasks**:
- [ ] Update local `is_valid` definition to match new signature
- [ ] Update `valid_at_triple` theorem
- [ ] Update `truth_at_swap_swap` lemma - should be simplified
- [ ] Update all axiom swap validity lemmas (swap_axiom_mt_valid, swap_axiom_m4_valid, etc.)
- [ ] Update all rule preservation lemmas (mp_preserves_swap_valid, modal_k_preserves_swap_valid, etc.)
- [ ] Update `axiom_swap_valid` master theorem
- [ ] Update all local axiom validity lemmas (axiom_prop_k_valid through axiom_temp_future_valid)
- [ ] Update `axiom_locally_valid` and `derivable_implies_valid_and_swap_valid`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

**Verification**:
- File compiles without errors
- `lake build Bimodal.Metalogic.SoundnessLemmas` succeeds

---

### Phase 5: Soundness.lean Updates [NOT STARTED]

**Goal**: Fix main soundness theorem and all axiom validity proofs

**Tasks**:
- [ ] Update `and_of_not_imp_not` helper if needed
- [ ] Update all axiom validity lemmas (prop_k_valid through temp_future_valid)
- [ ] Verify MF and TF axioms still use time_shift correctly
- [ ] Update `axiom_valid` master theorem
- [ ] Update main `soundness` theorem - should have simplified signature in some cases

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean`

**Verification**:
- File compiles without errors
- `lake build Bimodal.Metalogic.Soundness` succeeds

---

### Phase 6: Full Build Verification [NOT STARTED]

**Goal**: Verify entire codebase compiles and verify semantic correctness

**Tasks**:
- [ ] Run `lake build` on entire project
- [ ] Fix any remaining compilation errors in other files
- [ ] Check Completeness.lean, Decidability files if affected
- [ ] Verify Perpetuity principles still compile (should be unaffected as they use derivability)
- [ ] Review all changes for semantic correctness against paper

**Timing**: 1 hour

**Files to modify**:
- Any remaining files with compilation errors

**Verification**:
- `lake build` succeeds with no errors
- All existing theorems still compile without sorry
- Semantic changes match JPL paper specification exactly

## Testing & Validation

- [ ] `lake build Bimodal.Semantics.Truth` succeeds after Phase 1-2
- [ ] `lake build Bimodal.Semantics.Validity` succeeds after Phase 3
- [ ] `lake build Bimodal.Metalogic.SoundnessLemmas` succeeds after Phase 4
- [ ] `lake build Bimodal.Metalogic.Soundness` succeeds after Phase 5
- [ ] Full `lake build` succeeds after Phase 6
- [ ] Perpetuity principles (P1-P6) still proven without sorry
- [ ] MF and TF axioms correctly use time_shift_preserves_truth
- [ ] Atoms are false outside history domain (matches paper line 892)

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- Modified files:
  - `Theories/Bimodal/Semantics/Truth.lean`
  - `Theories/Bimodal/Semantics/Validity.lean`
  - `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`
  - `Theories/Bimodal/Metalogic/Soundness.lean`
  - Possibly other downstream files
- `summaries/implementation-summary-YYYYMMDD.md` upon completion

## Rollback/Contingency

If implementation causes cascading issues:
1. Git revert to pre-implementation state
2. Consider alternative approach: Add a helper function `truth_at_ext` that extends truth evaluation to times outside domain, keeping original `truth_at` unchanged
3. The original implementation with domain restriction is semantically consistent (just different from paper); can document discrepancy as a design choice if necessary

## Technical Notes

### New truth_at Signature

```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : T) : Formula -> Prop
  | Formula.atom p =>
    if ht : tau.domain t then M.valuation (tau.states t ht) p else False
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : T), s < t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : T), t < s -> truth_at M tau s phi
```

### Box Operator Consideration

The box operator quantifies over all histories at time t. The paper (line 1863) shows:
```
M,tau,x |= Box phi iff M,sigma,x |= phi for all sigma in Omega
```

This suggests box should quantify over ALL histories, not just those with domain at t. However, if sigma doesn't have domain at t, evaluating atoms in phi at (sigma, t) will return False for all atoms. This is consistent with the paper's approach.

### Key Insight from Paper

From lines 899-919: The chess game example shows that evaluating formulas at times outside a history's domain is meaningful. The game beta ends at move 31, but we can still ask "was checkmate in the past?" at move 47 in beta - the answer is yes because checkmate occurred at move 31 (which is in dom(beta)).
