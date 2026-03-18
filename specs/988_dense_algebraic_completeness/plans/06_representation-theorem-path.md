# Implementation Plan: Task #988

**Task**: dense_algebraic_completeness
**Version**: 006
**Created**: 2026-03-17
**Language**: lean4

## Overview

Plan v5 inverted the dependency. The representation theorem `dense_representation_conditional` (DenseInstantiation.lean) is ALREADY the path to completeness - it just needs a `construct_bfmcs_rat : (M : Set Formula) -> SetMaximalConsistent M -> BFMCS Rat` argument.

The completeness chain is:
1. `dense_representation_conditional` + `construct_bfmcs_rat` -> unprovable phi has countermodel in BFMCS Rat
2. Countermodel in BFMCS Rat -> `~valid_dense phi` (Rat IS a dense model)
3. Contrapositive: `valid_dense phi -> provable phi`

**The only missing piece is `construct_bfmcs_rat`.**

The transport path to construct it is almost complete:

```
timelineQuotFMCS (FMCS TimelineQuot, exists)
    | forward_F/backward_P/modal_backward (4 sorries in ClosureSaturation.lean)
    v
BFMCS TimelineQuot (temporally coherent)
    | cantor_isomorphism : TimelineQuot ~=o Rat (sorry-free, DFromCantor.lean:178)
    v
BFMCS Rat = construct_bfmcs_rat
    | dense_representation_conditional (sorry-free, DenseInstantiation.lean)
    v
countermodel
    | Rat is DenselyOrdered (trivial)
    v
~valid_dense phi
    | contrapositive
    v
valid_dense phi -> provable phi
```

The 4 sorries in ClosureSaturation.lean are the **entire bottleneck**. Everything else is already proven.

## Coordination with Task 982

Task 982 plans a dovetailing construction via new `DovetailedTimelineQuot` type (plan v10). Phase 1 here is the same work. Options:
- **Fix existing sorries directly** (ClosureSaturation.lean:659,664,679,724) - uses existing types
- **Adopt task 982's approach** (DovetailedTimelineQuot) - cleaner but new infrastructure

This plan assumes direct fix. If task 982 completes first, Phase 1 simplifies to importing its result.

## Phases

### Phase 1: Fix ClosureSaturation.lean Sorries [BLOCKED]

**Estimated effort**: 12-15h (main effort)

**Objectives**:
1. Resolve `timelineQuotFMCS_forward_F` sorry at line 659 (m > 2k case)
2. Resolve `timelineQuotFMCS_forward_F` sorry at line 664 (density point future q case)
3. Resolve `timelineQuotFMCS_backward_P` sorry at line 679 (symmetric backward case)
4. Resolve `modal_backward` sorry at line 724 (Box phi in MCS gap)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`

**The Core Problem**:
The staged construction processes formulas by Cantor-encoded priority. When F(phi) is in an MCS at stage k, but the witness stage is 2*encode(phi) > k, the witness may not yet be in the timeline. The documentation says "witnesses beget witnesses" via density, but the proof infrastructure doesn't capture this.

**Strategy (Cantor-pairing dovetailing)**:

The existing staged construction adds witnesses when `stage = 2 * encode(formula)`. This can leave gaps when F(phi) appears at high stage but low-index formulas took up earlier witness slots.

**Option A - Fix within existing types**:
1. Strengthen the inductive invariant to track "all F-obligations up to stage k have witnesses"
2. Use density + Cantor pairing: for any F(phi) in MCS at t, find rational s > t at a valid stage
3. Show transitivity: if witness W exists at some stage, and F(psi) in W, that obligation also resolves

**Option B - Use task 982's DovetailedTimelineQuot**:
Task 982 plan v10 defines a new `DovetailedTimelineQuot` type built from the ground up with correct witness placement. This is cleaner but means:
1. Create new type instead of fixing existing ClosureSaturation
2. Port the FMCS construction to new type
3. Prove temporal coherence for new type

**Key lemmas needed** (Option A approach):
```lean
-- For line 659: m > 2k case - F-witness eventually exists
lemma forward_F_eventual_witness
    (h_F_in : Formula.some_future phi in p.1.mcs)
    (h_m_gt : encoding phi > 2 * stage_index p) :
    exists s : TimelineQuot, s > p /\ phi in (timelineQuotFMCS ...).mcs s

-- For line 664: density point with existing future but phi not present
lemma forward_F_density_point_witness
    (h_F_in : Formula.some_future phi in p.1.mcs)
    (h_q_future : q > p /\ CanonicalR p.1.mcs q.mcs)
    (h_phi_not_in : phi notin q.mcs) :
    exists s : TimelineQuot, s > p /\ phi in (timelineQuotFMCS ...).mcs s

-- For line 679: symmetric backward
lemma backward_P_witness
    (h_P_in : Formula.some_past phi in p.1.mcs)
    (h_in_timeline : p in timeline) :
    exists s : TimelineQuot, s < p /\ phi in (timelineQuotFMCS ...).mcs s

-- For line 724: modal_backward Box phi issue
lemma modal_backward_box
    (h_sat : modal_saturation bundle)
    (h_box_valid : forall q >= p, phi in q.mcs) :
    Formula.box phi in p.mcs
```

**Steps**:
1. Read ClosureSaturation.lean fully to understand the staged construction invariants
2. Read task 982 plan v10 for the dovetailing insight (even if not using DovetailedTimelineQuot)
3. Identify which lemmas from existing infrastructure can help (DenseTimeline, StagedInvariants)
4. For each sorry, trace what the goal state needs and work backward
5. Use `lean_goal` at each sorry point to get exact state
6. Implement proofs or new lemmas as needed
7. Run `lake build` after each fix to confirm no regressions

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.ClosureSaturation` with no sorries
- `lean_goal` confirms all obligations discharged
- `lean_verify` on `timelineQuotFMCS_forward_F`, `timelineQuotFMCS_backward_P`, `modal_backward`

---

### Phase 2: Transport BFMCS TimelineQuot to BFMCS Rat [NOT STARTED]

**Estimated effort**: 3h

**Objectives**:
1. Use `cantor_isomorphism : TimelineQuot ~=o Rat` (DFromCantor.lean:178) to transport the BFMCS
2. Define `construct_bfmcs_rat` as the transported structure
3. Prove temporal coherence is preserved under order isomorphism

**Files to modify/create**:
- New: `Theories/Bimodal/Metalogic/StagedConstruction/RatTransport.lean`
- Or extend: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Key construction**:
```lean
-- Transport FMCS via order isomorphism
def fmcs_transport (iso : TimelineQuot ~=o Rat) (fam : FMCS TimelineQuot) : FMCS Rat where
  mcs := fun r => fam.mcs (iso.symm r)
  -- Properties transfer because iso is order-preserving

-- Transport BFMCS
def bfmcs_transport (iso : TimelineQuot ~=o Rat) (B : BFMCS TimelineQuot) : BFMCS Rat where
  families := B.families.map (fmcs_transport iso)
  -- Modal saturation preserved (same MCS content)
  -- Temporal coherence: forward_F at r in Rat
  --   -> forward_F at iso.symm r in TimelineQuot
  --   -> exists s > iso.symm r in TimelineQuot with phi
  --   -> iso s > r in Rat with phi (iso preserves order)

-- Main construction
def construct_bfmcs_rat
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Sigma' (B : BFMCS Rat) (h_tc : B.temporally_coherent)
           (fam : FMCS Rat) (hfam : fam in B.families) (t : Rat),
           M = fam.mcs t := by
  -- Get BFMCS over TimelineQuot from Phase 1 (sorry-free)
  obtain <B_tq, h_tc_tq, fam_tq, hfam_tq, t_tq, h_eq_tq> := construct_bfmcs_timeline M h_mcs
  -- Get the isomorphism
  obtain <iso> := cantor_isomorphism root_mcs root_mcs_proof
  -- Transport
  use bfmcs_transport iso B_tq
  use transport_temporally_coherent iso h_tc_tq
  use fmcs_transport iso fam_tq
  use transport_membership iso hfam_tq
  use iso t_tq
  exact transport_mcs_eq iso h_eq_tq
```

**Key lemmas to prove**:
```lean
-- Order isomorphism preserves temporal coherence
theorem transport_temporally_coherent
    (iso : TimelineQuot ~=o Rat)
    (h_tc : B.temporally_coherent) :
    (bfmcs_transport iso B).temporally_coherent := by
  -- forward_F: F(phi) in fam.mcs r
  --   = F(phi) in fam_tq.mcs (iso.symm r)
  --   -> exists s_tq > iso.symm r with phi in fam_tq.mcs s_tq (by h_tc)
  --   -> iso s_tq > r with phi in fam.mcs (iso s_tq) (by iso monotone)

-- Order isomorphism preserves modal saturation
theorem transport_modal_saturation ...
```

**Steps**:
1. Read DFromCantor.lean to understand `cantor_isomorphism` signature
2. Define `fmcs_transport` and `bfmcs_transport`
3. Prove temporal coherence transport (main work)
4. Prove modal saturation transport (should follow similarly)
5. Assemble into `construct_bfmcs_rat`

**Verification**:
- `lake build` on the new module
- `lean_verify` on `construct_bfmcs_rat`
- No sorries

---

### Phase 3: Wire Dense Algebraic Completeness [NOT STARTED]

**Estimated effort**: 2h

**Objectives**:
1. Call `dense_representation_conditional` with `construct_bfmcs_rat`
2. Prove the validity bridge: countermodel in BFMCS Rat -> ~valid_dense
3. Prove contrapositive: valid_dense -> provable

**Files to modify/create**:
- Modify: `Theories/Bimodal/Metalogic/Algebraic/DenseInstantiation.lean` (add final theorem)
- Or new: `Theories/Bimodal/Metalogic/Algebraic/DenseAlgebraicCompleteness.lean`
- Possibly: `Theories/Bimodal/Metalogic/DenseCompleteness.lean` (update to use new result)

**Key theorems**:
```lean
-- Countermodel in Rat implies not valid_dense
theorem bfmcs_rat_countermodel_implies_not_valid_dense
    (B : BFMCS Rat) (h_tc : B.temporally_coherent)
    (fam : FMCS Rat) (hfam : fam in B.families)
    (t : Rat) (phi : Formula)
    (h_neg : phi.neg in fam.mcs t) :
    ~valid_dense phi := by
  -- The BFMCS over Rat is itself a dense model (Rat is DenselyOrdered)
  -- phi.neg in fam.mcs t -> (by truth lemma) phi is false at (fam, t)
  -- -> exists dense model where phi is false
  -- -> ~valid_dense phi

-- Main completeness theorem
theorem dense_algebraic_completeness (phi : Formula) :
    valid_dense phi -> Nonempty (DerivationTree [] phi) := by
  intro h_valid
  by_contra h_not_prov
  -- Apply representation theorem
  obtain <B, h_tc, fam, hfam, t, h_neg> :=
    dense_representation_conditional phi h_not_prov construct_bfmcs_rat
  -- Get countermodel contradiction
  have h_not_valid := bfmcs_rat_countermodel_implies_not_valid_dense B h_tc fam hfam t phi h_neg
  exact h_not_valid h_valid
```

**Steps**:
1. Import `construct_bfmcs_rat` from Phase 2
2. Verify `dense_representation_conditional` signature matches
3. Prove `bfmcs_rat_countermodel_implies_not_valid_dense`
   - Use truth lemma for BFMCS over Rat (may need to adapt ParametricTruthLemma)
   - Show that BFMCS Rat IS a valid dense model (Rat is DenselyOrdered, BFMCS structure gives TaskFrame)
4. Combine into `dense_algebraic_completeness`
5. Update any imports/exports as needed

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.DenseAlgebraicCompleteness` (no sorries)
- `lake build Bimodal` (full clean build)
- `lean_verify` on `dense_algebraic_completeness`

---

## Dependencies

| Dependency | Source | Status |
|------------|--------|--------|
| `timelineQuotFMCS` | ClosureSaturation.lean | Exists (4 sorries) |
| `cantor_isomorphism : TimelineQuot ~=o Rat` | DFromCantor.lean:178 | Sorry-free |
| `dense_representation_conditional` | DenseInstantiation.lean | Sorry-free |
| `SetMaximalConsistent`, `lindenbaumMCS` | MaximalConsistent.lean | Sorry-free |
| Truth lemma for BFMCS | ParametricTruthLemma.lean | Exists (needs Rat instantiation) |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Phase 1 sorries require deep changes to staged construction | High | Consult task 982 plan v10; adopt DovetailedTimelineQuot if direct fix proves intractable |
| Order isomorphism doesn't cleanly transport BFMCS properties | Medium | Properties are order-based (s > t, phi in mcs s); isomorphism should preserve these directly |
| Truth lemma for Rat requires `AddCommGroup` not just `LinearOrder` | Medium | Check DenseInstantiation.lean instantiation; Rat IS an AddCommGroup so should work |
| `dense_representation_conditional` has unexpected constraints | Low | Read its signature carefully; it takes a `construct_bfmcs` function as argument |
| Phase 1 takes longer than 15h | Medium | This is the hard part; can parallelize with task 982 or scope to a subset of sorries |

## Success Criteria

- [ ] ClosureSaturation.lean: 0 sorries (currently 4)
- [ ] `construct_bfmcs_rat` defined with no sorries
- [ ] `dense_algebraic_completeness : valid_dense phi -> provable phi` proved with no sorries
- [ ] `lake build Bimodal` passes with no errors
- [ ] No new axioms introduced
- [ ] sorry count in Theories/ decreases by at least 4

## Comparison with Plan v5

| Aspect | Plan v5 | Plan v6 |
|--------|---------|---------|
| Route | Bypass representation theorem via CanonicalMCS | Use representation theorem directly |
| Main work | New CanonicalMCS truth lemma + semantic validity bridge | Fix existing sorries + transport |
| Risk | Semantic bridge may not type-check (DenselyOrdered on CanonicalMCS) | Sorries may require new lemma infrastructure |
| Estimated hours | 10h | 17-20h |
| Uses existing infra | Low (new approach) | High (completes existing approach) |
| Blocking issues | Unclear if CanonicalMCS satisfies DenselyOrdered | Known: 4 specific sorries |

Plan v6 is longer but **completes the existing design** rather than working around it.
