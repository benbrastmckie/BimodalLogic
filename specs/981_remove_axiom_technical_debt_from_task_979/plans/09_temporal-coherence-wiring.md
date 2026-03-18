# Implementation Plan: Task #981 - Temporal Coherence Wiring for Dense Completeness

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Dependencies**: None (all prerequisites are sorry-free)
- **Research Inputs**: specs/981_remove_axiom_technical_debt_from_task_979/reports/25_correct-truth-lemma-approaches.md
- **Artifacts**: plans/09_temporal-coherence-wiring.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan v9 supersedes plan v8 based on research findings in report 25. The core problem is filling the sorry at `TimelineQuotCompleteness.lean:127` (`timelineQuot_not_valid_of_neg_consistent`). The research conclusively shows:

1. **Forward-only approaches are dead ends** - The completeness proof requires the BACKWARD direction of the truth lemma
2. **The gap is precisely `forward_F` and `backward_P` for TimelineQuotFMCS** - These are existential witnesses: "F(phi) in mcs(t) implies exists s > t with phi in mcs(s)"
3. **DovetailedCoverage provides sorry-free witnesses** - `dovetailedTimeline_has_future` and `dovetailedTimeline_has_past` use the density argument to construct witnesses
4. **The work is wiring, not new mathematics** - Connect existing DovetailedCoverage theorems to prove temporal coherence for TimelineQuotFMCS

### Key Insight from Research

The `parametric_shifted_truth_lemma` (ParametricTruthLemma.lean) provides the full biconditional truth lemma BUT requires a `BFMCS` with `temporally_coherent` property. The `temporal_backward_G` theorem (TemporalCoherence.lean:166-179) uses `forward_F` to derive the witness via contraposition. The dovetailed construction proves exactly these F/P witnesses, but they haven't been connected to the TimelineQuot FMCS structure.

## Goals & Non-Goals

**Goals**:
- Prove `timelineQuotFMCS_forward_F` using `dovetailedTimeline_has_future`
- Prove `timelineQuotFMCS_backward_P` using `dovetailedTimeline_has_past`
- Construct `timelineQuotTemporalCoherentFamily` extending `timelineQuotFMCS` with F/P coherence
- Construct singleton `timelineQuotBFMCS` with `temporally_coherent` property
- Fill the sorry at `TimelineQuotCompleteness.lean:127` using the temporally coherent BFMCS
- Verify `dense_completeness_theorem` becomes sorry-free

**Non-Goals**:
- Removing `timelineQuotMCS_at_zero_eq_root` sorry (deprecated theorem, use `rootTime` instead)
- Building multi-family BFMCS (singleton suffices for completeness)
- Proving discrete completeness (dense completeness is the primary target)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DovetailedCoverage witnesses are for DovetailedPoint, not TimelineQuot | High | Medium | The mapping from TimelineQuot to DovetailedPoint via `ofAntisymmetrization` preserves MCS identity - established in `denseTimelineElem_mutual_le_implies_mcs_eq` |
| CanonicalR vs TimelineQuot ordering mismatch | Medium | Low | `timelineQuot_lt_implies_canonicalR` already bridges this - use the same approach |
| Modal coherence requirements for singleton BFMCS | Medium | Medium | T-axiom gives forward box direction; full modal saturation not needed for single-family |
| Type unification complexity | Low | Medium | Follow exact patterns from TimelineQuotCanonical.lean |

## Implementation Phases

### Phase 1: Prove forward_F for TimelineQuotFMCS [NOT STARTED]

**Goal**: Prove that if F(phi) is in timelineQuotMCS at time t, there exists s > t with phi in mcs(s).

**Tasks**:
- [ ] Add theorem `timelineQuotFMCS_forward_F` in TimelineQuotCanonical.lean
- [ ] Extract DovetailedPoint representation from TimelineQuot element via `ofAntisymmetrization`
- [ ] Use `dovetailedTimeline_has_future` to get CanonicalR witness
- [ ] Convert CanonicalR witness back to TimelineQuot ordering using `canonicalR_implies_timelineQuot_le`
- [ ] Extract phi membership from witness MCS

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`

**Proof Sketch**:
```lean
theorem timelineQuotFMCS_forward_F
    (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_F : Formula.some_future phi in (timelineQuotFMCS ...).mcs t) :
    exists s : TimelineQuot ..., t < s and phi in (timelineQuotFMCS ...).mcs s := by
  -- 1. Extract representative p := ofAntisymmetrization t
  -- 2. Show F(phi) in p.mcs (via MCS equality for representatives)
  -- 3. Find stage n where p is in dovetailedBuild
  -- 4. Apply dovetailedTimeline_has_future to get witness q with CanonicalR p.mcs q.mcs
  -- 5. Convert q to TimelineQuot element s := toAntisymmetrization q
  -- 6. Show t < s via CanonicalR -> strict order
  -- 7. Show phi in mcs(s) via CanonicalR semantics
```

**Key Lemmas Needed**:
- Bridge from TimelineQuot element to dovetailedTimelineUnion membership
- Extract phi from CanonicalR witness (already exists as `g_content` definition)

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical`
- No new sorries introduced

---

### Phase 2: Prove backward_P for TimelineQuotFMCS [NOT STARTED]

**Goal**: Prove that if P(phi) is in timelineQuotMCS at time t, there exists s < t with phi in mcs(s).

**Tasks**:
- [ ] Add theorem `timelineQuotFMCS_backward_P` in TimelineQuotCanonical.lean
- [ ] Mirror Phase 1 structure using `dovetailedTimeline_has_past`
- [ ] Use past direction of CanonicalR (CanonicalR w.mcs p.mcs for backward witness)

**Timing**: 1 hour (symmetric to Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`

**Proof Sketch**:
```lean
theorem timelineQuotFMCS_backward_P
    (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
    (h_P : Formula.some_past phi in (timelineQuotFMCS ...).mcs t) :
    exists s : TimelineQuot ..., s < t and phi in (timelineQuotFMCS ...).mcs s := by
  -- Symmetric to forward_F using dovetailedTimeline_has_past
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical`
- No new sorries introduced

---

### Phase 3: Construct Temporally Coherent BFMCS [NOT STARTED]

**Goal**: Build a singleton BFMCS over TimelineQuot with temporal coherence.

**Tasks**:
- [ ] Create `timelineQuotTemporalCoherentFamily` using Phase 1-2 results
- [ ] Create `timelineQuotBFMCS : BFMCS (TimelineQuot ...)` as singleton set containing the family
- [ ] Prove `timelineQuotBFMCS_temporally_coherent` from Phase 1-2 theorems
- [ ] Prove modal coherence (forward follows from T-axiom for singleton)

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`

**Definitions**:
```lean
-- Temporal coherent family extending timelineQuotFMCS
noncomputable def timelineQuotTemporalCoherentFamily :
    TemporalCoherentFamily (TimelineQuot root_mcs root_mcs_proof) where
  toFMCS := timelineQuotFMCS root_mcs root_mcs_proof
  forward_F := timelineQuotFMCS_forward_F root_mcs root_mcs_proof
  backward_P := timelineQuotFMCS_backward_P root_mcs root_mcs_proof

-- Singleton BFMCS
noncomputable def timelineQuotBFMCS : BFMCS (TimelineQuot root_mcs root_mcs_proof) where
  families := {timelineQuotFMCS root_mcs root_mcs_proof}
  nonempty := Set.singleton_nonempty _
  modal_forward := ... -- T-axiom: Box phi -> phi for singleton
  modal_backward := ... -- Trivial for singleton (universal quantifier over single element)

theorem timelineQuotBFMCS_temporally_coherent :
    (timelineQuotBFMCS root_mcs root_mcs_proof).temporally_coherent := ...
```

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical`
- Check `#print axioms timelineQuotBFMCS_temporally_coherent` for no non-standard axioms

---

### Phase 4: Fill the Completeness Sorry [NOT STARTED]

**Goal**: Remove the sorry at TimelineQuotCompleteness.lean:127.

**Tasks**:
- [ ] Apply `parametric_representation_from_neg_membership` (or similar) with temporally coherent BFMCS
- [ ] Show root MCS contains phi.neg (from Lindenbaum construction)
- [ ] Apply truth lemma to derive semantic falsity of phi
- [ ] Construct the countermodel witness (Frame, Model, Omega, history, time)

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Proof Structure**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    ... not valid_over D phi := by
  intro M0 h_M0_mcs D acg oam
  -- 1. Build temporally coherent BFMCS
  let B := timelineQuotBFMCS M0 h_M0_mcs
  have h_tc := timelineQuotBFMCS_temporally_coherent M0 h_M0_mcs

  -- 2. Apply parametric truth lemma
  let fam := timelineQuotFMCS M0 h_M0_mcs
  have h_fam_in : fam in B.families := Set.mem_singleton_iff.mpr rfl
  let tau := parametric_to_history fam
  let t := rootTime M0 h_M0_mcs

  -- 3. Show phi.neg in mcs(t) = M0
  have h_neg_in_M0 : phi.neg in M0 := lindenbaumMCS_contains_context [phi.neg] h_cons phi.neg (by simp)
  have h_mcs_eq := timelineQuotMCS_root_time_eq M0 h_M0_mcs
  have h_neg_in_t : phi.neg in fam.mcs t := h_mcs_eq.symm.subst h_neg_in_M0

  -- 4. Apply truth lemma backward direction
  have h_truth := (parametric_shifted_truth_lemma B h_tc phi.neg fam h_fam_in t).mpr h_neg_in_t

  -- 5. Extract not truth_at phi from truth_at phi.neg
  -- phi.neg = phi.imp bot, so truth_at phi.neg means truth_at phi -> False
  ...
```

**Verification**:
- `grep -c "sorry" TimelineQuotCompleteness.lean` returns 0
- `lake build Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness`

---

### Phase 5: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify dense completeness is axiom-free and update documentation.

**Tasks**:
- [ ] Run `#print axioms dense_completeness_theorem` to verify only standard axioms
- [ ] Verify no dependency on `discrete_Icc_finite_axiom` in dense path
- [ ] Update docstrings in TimelineQuotCompleteness.lean
- [ ] Mark plan v8 as superseded by v9 in the plan header
- [ ] Create implementation summary if successful

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - Update docstrings
- `specs/981_.../plans/08_truth-lemma-wiring.md` - Add superseded note

**Verification**:
- `#print axioms dense_completeness_theorem` shows only: propext, Quot.sound, Classical.choice
- `discrete_Icc_finite_axiom` does not appear in axiom trace

## Testing & Validation

- [ ] `lake build` passes with no new sorries in TimelineQuotCanonical.lean
- [ ] `lake build` passes with no sorries in TimelineQuotCompleteness.lean
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` returns empty
- [ ] `#print axioms dense_completeness_theorem` shows only standard axioms
- [ ] `#print axioms timelineQuotBFMCS_temporally_coherent` shows only standard axioms

## Artifacts & Outputs

- `specs/981_remove_axiom_technical_debt_from_task_979/plans/09_temporal-coherence-wiring.md` (this file)
- Modified: `TimelineQuotCanonical.lean` - forward_F, backward_P, TemporalCoherentFamily, BFMCS
- Modified: `TimelineQuotCompleteness.lean` - Sorry filled, docstrings updated
- `specs/981_.../summaries/10_implementation-summary.md` - Execution summary

## Rollback/Contingency

If the proof approach proves intractable:

1. **Phase 1-2 issues (F/P coherence)**: The key bridge lemma `timelineQuot_lt_implies_canonicalR` already exists and is sorry-free. If the DovetailedCoverage connection fails, investigate whether the representation of TimelineQuot elements as DovetailedPoints is precise enough - may need additional equivalence lemmas.

2. **Phase 3 issues (BFMCS construction)**: If modal coherence for singleton BFMCS fails, consider whether we need to use the full ParametricTruthLemma infrastructure differently - perhaps using separated history without full BFMCS.

3. **Phase 4 issues (completeness wiring)**: If the truth lemma application fails due to type mismatches, fall back to a direct semantic argument using forward truth only (though this would require proving the specific formula cases manually).

4. **Mathematical impossibility**: The research report confirms the mathematics is sound. If implementation fails, it's a mechanization gap, not a mathematical gap. Document precisely what type unification or infrastructure gap is blocking progress.

**Note**: The mathematical content is verified correct by research report 25. The remaining gap is purely Lean mechanization of existing infrastructure. All key components are sorry-free; the task is connecting them correctly.
